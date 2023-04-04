package edu.temple.vehiclecollisiondetection


import android.Manifest
import android.app.Activity
import android.bluetooth.*
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.os.CountDownTimer
import android.telephony.SmsManager
import android.util.Log
import android.view.LayoutInflater
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat.startActivity
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.util.*
private const val SAVE_KEY = "save_key"
private const val emergencyServiceNum = "+14846391351"
class MyBluetoothGattCallback(currentContext: Context, currentActivity: Activity, connectionText: TextView) : BluetoothGattCallback() {
    val activeContext = currentContext
    val activeActivity = currentActivity
    val connectionStatusText = connectionText

    //countdown timer object
    private var mCountDownTimer: CountDownTimer? = null
    private val countdownStartTime: Long = 11000 //timer duration for when crashes are detected, current set at 11 seconds (takes a second to popup)
    private var mTimeLeftInMillis = countdownStartTime //variable for tracking countdown duration remaining at a given time
    private var countdownValueInt: Int? = null

    private lateinit var preferences: SharedPreferences

    @RequiresApi(Build.VERSION_CODES.S)
    override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
        if (ActivityCompat.checkSelfPermission(
                activeContext,
                Manifest.permission.BLUETOOTH_CONNECT
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            activeActivity.requestPermissions(arrayOf(Manifest.permission.BLUETOOTH_CONNECT), 10)
            //return
        }
        if (newState == BluetoothProfile.STATE_CONNECTED) {
            Log.d("tag1", "Connection Succeeded!")
            activeActivity.runOnUiThread(Runnable() {
                Toast.makeText(activeContext, "Device Connected!", Toast.LENGTH_LONG).show()
                connectionStatusText.setTextColor(Color.parseColor("green"))
                connectionStatusText.setText("Connected!")
            })
            gatt.discoverServices()
        } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
            // handle disconnection
            Log.d("tag2", "Connection Disconnected!")
            activeActivity.runOnUiThread(Runnable() {
                connectionStatusText.setTextColor(Color.parseColor("red"))
                connectionStatusText.setText("Not Connected")
                Toast.makeText(activeContext, "Device Disconnected!", Toast.LENGTH_LONG).show()
            })
        } else{
            Log.d("tag3", "Connection Attempt Failed!")
            gatt.close()
        }
    }

    @RequiresApi(33)
    override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
        val serviceUuid = UUID.fromString("00110011-4455-6677-8899-aabbccddeeff")//acts like a 'password' for the bluetooth connection
        val characteristicUuid = UUID.fromString("00112233-4455-6677-8899-abbccddeefff")//acts like a 'password' for the bluetooth connection
        if (ActivityCompat.checkSelfPermission(
                activeContext,
                Manifest.permission.BLUETOOTH_CONNECT
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            activeActivity.requestPermissions(arrayOf(Manifest.permission.BLUETOOTH_CONNECT), 10)
            //return
        }
        if (status == BluetoothGatt.GATT_SUCCESS) {
            val service1 = gatt.getService(serviceUuid)
            val characteristic1 = service1.getCharacteristic(characteristicUuid)//characteristic uuid here
            if(service1 == null){
                Log.d("Invalid service:", "service is null!")
                Log.d("Service UUid:", serviceUuid.toString())
            }else{
                Log.d("Service Found:", serviceUuid.toString())
            }
            if(characteristic1 == null){
                Log.d("Invalid characteristic:", "characteristic is null!")
                Log.d("Characteristic UUid:", characteristicUuid.toString())
            }else{
                Log.d("Characteristic Found:", characteristicUuid.toString())
            }
            gatt.setCharacteristicNotification(characteristic1, true)

            val desc: BluetoothGattDescriptor = characteristic1.getDescriptor(UUID.fromString("00002902-0000-1000-8000-00805f9b34fb"))
            Log.d("Descriptor Found:", "00002902-0000-1000-8000-00805f9b34fb")
            gatt.writeDescriptor(desc, BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE)
        }
    }

    override fun onCharacteristicChanged(
        gatt: BluetoothGatt,
        characteristic: BluetoothGattCharacteristic,
        value: ByteArray
    ) {
        // handle received data
        Log.d("Characteristic Data", "Data Changed!")
        val data = String(value)
        if(data == "B" || data =="F") {
            mTimeLeftInMillis = countdownStartTime
            activeActivity.runOnUiThread(){
                //if a crash is detected by the arduino device, initiate crash popup
                val crashDialogView = LayoutInflater.from(activeContext).inflate(R.layout.crash_procedure_popup, null)
                val crashDialogBuilder = AlertDialog.Builder(activeContext)
                    .setView(crashDialogView)
                    .setTitle("")
                //show dialog
                val crashAlertDialog = crashDialogBuilder.show()
                //countdown
                val countdownTimerText = crashDialogView.findViewById<TextView>(R.id.countdownText)
                mCountDownTimer = object : CountDownTimer(mTimeLeftInMillis, 1000) {
                    override fun onTick(millisUntilFinished: Long) { //countdown interval
                        mTimeLeftInMillis = millisUntilFinished
                        countdownValueInt = ((mTimeLeftInMillis / 1000) % 60).toInt()
                        countdownTimerText.setText(countdownValueInt.toString())
                    }
                    override fun onFinish() { //countdown goes to 0
                        mCountDownTimer?.cancel()
                        crashAlertDialog.dismiss()
                        //get list of saved emergency contacts and text them w/ emergency message
                        preferences = activeActivity.getPreferences(AppCompatActivity.MODE_PRIVATE)
                        val gson = Gson()
                        val serializedList = preferences.getString(SAVE_KEY, null)
                        val myType = object : TypeToken<ArrayList<MainActivity.ContactObject>>() {}.type
                        sendTextsToContacts(gson.fromJson<ArrayList<MainActivity.ContactObject>>(serializedList, myType))
                        //make call to emergency services
                        makeCall(emergencyServiceNum)
                    }
                }.start()
                //cancel button
                val cancelButton = crashDialogView.findViewById<Button>(R.id.crash_cancel_button)
                cancelButton.setOnClickListener {
                    mCountDownTimer?.cancel()
                    crashAlertDialog.dismiss()
                }
            }
        }
    }
    private fun sendText(phoneNumber: String, message: String){
        var smsManager: SmsManager? = null
        //var id = SmsManager.getDefaultSmsSubscriptionId()
        smsManager = activeActivity.getSystemService(SmsManager::class.java)

        smsManager?.sendTextMessage(phoneNumber, null, message, null, null)
        Log.d("sendText", "$message sent to $phoneNumber")
    }

    private fun sendTextsToContacts(contactObjects: ArrayList<MainActivity.ContactObject>){
        for(obj in contactObjects) {
            //This is for American numbers only!
            val numWithCountryCode = "+1" + obj.phoneNumber

            //Add user variable rather than "someone", add location variable
            sendText(
                numWithCountryCode, "Hello ${obj.name}, I'm sorry to inform you that " +
                        "someone has been in a serious crash. Here is their location: "
            )
        }
    }

    private fun makeCall(phoneNumber: String){

        Log.d("Call output", "App is calling $phoneNumber")

        val callIntent = Intent(Intent.ACTION_CALL)
        //start calling intent
        callIntent.data = Uri.parse("tel:$phoneNumber")
        activeContext.startActivity(callIntent)
    }
}