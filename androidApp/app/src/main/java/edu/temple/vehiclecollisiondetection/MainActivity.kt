package edu.temple.vehiclecollisiondetection

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.*
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanFilter
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.Context
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.recyclerview.widget.RecyclerView
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.util.*


private const val SAVE_KEY = "save_key"


class MainActivity : AppCompatActivity() {

    //recycler view to hold contact list
    lateinit var recyclerView: RecyclerView
    lateinit var connectionText: TextView
    lateinit var characteristicData: TextView
    private lateinit var preferences: SharedPreferences

    //contact data class
    data class ContactObject(val phoneNumber: String, val name: String)



    @SuppressLint("SetTextI18n")//added for hello world
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        recyclerView = findViewById(R.id.contactRecyclerView)
        connectionText = findViewById(R.id.connectionText)
        connectionText.setTextColor(Color.parseColor("red"))
        characteristicData = findViewById(R.id.characteristicDataText)

        //ability to access shared preferences
        preferences = getPreferences(MODE_PRIVATE)

        //Gets list from storage
        val gson = Gson()
        val serializedList = preferences.getString(SAVE_KEY, null)
        Log.d("list on start", serializedList.toString())

        val myType = object : TypeToken<ArrayList<ContactObject>>() {}.type
        var contactObjects = gson.fromJson<ArrayList<ContactObject>>(serializedList, myType)
        if(contactObjects == null){
            contactObjects = arrayListOf(
                ContactObject("1234567890", "Placeholder")
            )
        }
        Log.d("ContactListFromMem", contactObjects.toString())

        recyclerView.adapter = ContactAdapter(contactObjects)

        val bluetoothThreadStart: View = findViewById(R.id.bluetoothTextBackground)
        bluetoothThreadStart.setOnClickListener {
            //start bluetooth thread
            var btRunnable = BluetoothRunnable()
            var btThread = Thread(btRunnable)
            btThread.start()
        }
        //Add Contact Button Functionality
        val addContactButton: View = findViewById(R.id.fab)
        addContactButton.setOnClickListener{
            //setting up 'add contact' pop-up menu
            val contactDialogView = LayoutInflater.from(this).inflate(R.layout.layout_dialog, null)
            val contactDialogBuilder = AlertDialog.Builder(this)
                .setView(contactDialogView)
                .setTitle("Add Contact")
            //show dialog
            val contactAlertDialog = contactDialogBuilder.show()
            //save/confirm button
            val saveButton = contactDialogView.findViewById<Button>(R.id.save_button)
            saveButton.setOnClickListener {
                contactAlertDialog.dismiss()
                //gets the input information
                val contactName = contactDialogView.findViewById<EditText>(R.id.contact_name).text.toString()
                val contactNumber = contactDialogView.findViewById<EditText>(R.id.contact_number).text.toString()
                //adds contact to the list of contactObjects
                addContact(contactObjects, contactName, contactNumber)

                //save contactObjects to shared preferences here
                saveContactList(contactObjects)

                recyclerView.adapter = ContactAdapter(contactObjects)
            }
            //cancel button
            val cancelButton = contactDialogView.findViewById<Button>(R.id.cancel_button)
            cancelButton.setOnClickListener {
                contactAlertDialog.dismiss()
            }
        }
        //delete contact button functionality
        val deleteButton: View = findViewById(R.id.deleteContactFab)
        deleteButton.setOnClickListener{
            val deleteContactView = LayoutInflater.from(this).inflate(R.layout.deletecontact_dialog, null)
            val deleteContactDialogBuilder = AlertDialog.Builder(this)
                .setView(deleteContactView)
                .setTitle("Delete Contact")
            //show dialog
            val deleteContactAlertDialog = deleteContactDialogBuilder.show()

            //delete/confirm button
            val confirmButton = deleteContactView.findViewById<Button>(R.id.delete_button)
            confirmButton.setOnClickListener {
                deleteContactAlertDialog.dismiss()
                //get input information
                val contactName = deleteContactView.findViewById<EditText>(R.id.contact_name).text.toString()
                //create new list using for loop, and put in contacts that DO NOT match the given name
                var newList = arrayListOf<ContactObject>()
                newList = deleteContact(contactObjects, contactName)
                //save new list (w/o deleted contacts)
                contactObjects = newList
                //save contactObjects to shared preferences here
                saveContactList(contactObjects)
                recyclerView.adapter = ContactAdapter(contactObjects)
            }
            val cancelButton = deleteContactView.findViewById<Button>(R.id.cancel_button)
            cancelButton.setOnClickListener {
                deleteContactAlertDialog.dismiss()
            }
        }

    }

    private fun addContact(contactList: ArrayList<MainActivity.ContactObject>, contactName: String, contactNum: String){
        contactList.add(ContactObject(contactNum, contactName))
    }
    private fun deleteContact(contactList: ArrayList<MainActivity.ContactObject>, contactName: String): ArrayList<MainActivity.ContactObject>{//returns a new arraylist w/o the specified contact
        var tempList = arrayListOf<ContactObject>()
        for (item in contactList){
            if(contactName.equals(item.name)){
                //don't add to new list
            }else{
                tempList.add(item)
            }
        }
        return tempList
    }

    private fun saveContactList(contactList: ArrayList<MainActivity.ContactObject>){
        val prefEditor = preferences.edit()
        val gson = Gson() //library used to serialize and deserialize objects

        val contactsString = gson.toJson(contactList)

        Log.d("list", contactsString)

        //saves the arrayList as a string in memory
        prefEditor.putString(SAVE_KEY, contactsString)
        prefEditor.apply()
    }

    inner class MyBluetoothGattCallback : BluetoothGattCallback() {

        @RequiresApi(Build.VERSION_CODES.S)
        override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
            if (ActivityCompat.checkSelfPermission(
                    this@MainActivity,
                    Manifest.permission.BLUETOOTH_CONNECT
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                requestPermissions(arrayOf(Manifest.permission.BLUETOOTH_CONNECT), 10)
                //return
            }
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                Log.d("tag1", "Connection Succeeded!")
                runOnUiThread(Runnable() {
                    Toast.makeText(applicationContext, "Device Connected!", Toast.LENGTH_LONG).show()
                    connectionText.setTextColor(Color.parseColor("green"))
                    connectionText.setText("Connected!")
                })
                gatt.discoverServices()
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                // handle disconnection
                Log.d("tag2", "Connection Disconnected!")
                runOnUiThread(Runnable() {
                    connectionText.setTextColor(Color.parseColor("red"))
                    connectionText.setText("Not Connected")
                })
            } else{
                Log.d("tag3", "Connection Attempt Failed!")
                gatt.close()
            }
        }

        @RequiresApi(Build.VERSION_CODES.S)
        override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
            val serviceUuid = UUID.fromString("0000181a-0000-1000-8000-00805f9b34fb")//acts like a 'password' for the bluetooth connection
            val characteristicUuid = UUID.fromString("00002A6D-0000-1000-8000-00805f9b34fb")//acts like a 'password' for the bluetooth connection
            if (ActivityCompat.checkSelfPermission(
                    this@MainActivity,
                    Manifest.permission.BLUETOOTH_CONNECT
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                requestPermissions(arrayOf(Manifest.permission.BLUETOOTH_CONNECT), 10)
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
            }
        }

        override fun onCharacteristicChanged(
            gatt: BluetoothGatt,
            characteristic: BluetoothGattCharacteristic,
            value: ByteArray
        ) {
            // handle received data
            Log.d("Characteristic Data", "Data Changed!")
            val data = value
            runOnUiThread(){
                characteristicData.text=data.toString()
            }

        }

    }

    @RequiresApi(Build.VERSION_CODES.S)
    private fun hasPermissions(): Boolean {
        if (applicationContext.checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(
                arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION),11)
        }
        if (applicationContext.checkSelfPermission(
                Manifest.permission.BLUETOOTH_CONNECT
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            requestPermissions(arrayOf(Manifest.permission.BLUETOOTH_CONNECT), 12)
        }
        if (applicationContext.checkSelfPermission(
                Manifest.permission.BLUETOOTH_SCAN
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            requestPermissions(arrayOf(Manifest.permission.BLUETOOTH_SCAN), 13)
        }
        if (applicationContext.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(
                arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),14)
        }
        return true
    }
    inner class BluetoothRunnable: Runnable{

        @RequiresApi(Build.VERSION_CODES.S)
        override fun run() {
            hasPermissions()
            var btAdapter: BluetoothAdapter? = null
            val bluetoothManager =
                this@MainActivity.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager?

            btAdapter = bluetoothManager?.adapter
            val gattCallback = MyBluetoothGattCallback()
            val bluetoothLeScanner = btAdapter?.bluetoothLeScanner
            val scanCallback = object : ScanCallback() {
                override fun onScanResult(callbackType: Int, result: ScanResult) {
                    if (ActivityCompat.checkSelfPermission(
                            this@MainActivity,
                            Manifest.permission.BLUETOOTH_SCAN
                        ) != PackageManager.PERMISSION_GRANTED
                    ) {
                        requestPermissions(arrayOf(Manifest.permission.BLUETOOTH_SCAN), 10)
                        //return
                    }
                    if(result.device.name != null){
                            Log.d("Device Found: ", result.device.name)
                    }
                    // Check if the scan result matches the target device UUID
                    if (result.device.address.equals("E6:EC:C4:09:52:F0")) {
                        Log.d("tag", "FOUND BLE DEVICE")
                        runOnUiThread(Runnable() {
                            Toast.makeText(applicationContext, "Device Found", Toast.LENGTH_LONG).show()
                        })

                        // Stop scanning
                        bluetoothLeScanner?.stopScan(this)
                        // Connect to the device
                        val device = result.device
                        // TODO: implement connection logic
                        var gatt: BluetoothGatt? = null
                        gatt = device?.connectGatt(this@MainActivity, false, gattCallback)
                    }
                }
            }
            // Create a ScanSettings to control the scan parameters
            val scanSettings = ScanSettings.Builder()
                .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
                .setMatchMode(ScanSettings.MATCH_MODE_AGGRESSIVE)
                .build()
            // Start scanning for devices that match the scan filter
            Log.d("tag", "LOOKING FOR BLE DEVICE")
            runOnUiThread(Runnable() {
                Toast.makeText(applicationContext, "Scanning for Device", Toast.LENGTH_LONG).show()
            })
            bluetoothLeScanner?.startScan(null, scanSettings, scanCallback)
        }
    }
}

class ContactAdapter(_contactObjects: ArrayList<MainActivity.ContactObject>): RecyclerView.Adapter<ContactAdapter.ViewHolder>(){

    private var contactObjects = _contactObjects

    inner class ViewHolder (itemView: View):  RecyclerView.ViewHolder(itemView) {
        var textView: TextView
        var textView2: TextView
        lateinit var contactObject: MainActivity.ContactObject

        init {
            textView = itemView.findViewById(R.id.listItem)
            textView2 = itemView.findViewById(R.id.listItem2)
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        //Inflate layout, defines UI of list item
        val view = LayoutInflater.from(parent.context).inflate(R.layout.recycler_view_layout, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.contactObject = contactObjects[position]

        //Sets contents of recycler view as the drawable provided in imageObject List
        holder.textView.text = contactObjects[position].name //Add phone numbers later
        holder.textView2.text = contactObjects[position].phoneNumber
    }

    override fun getItemCount(): Int {
        return contactObjects.size
    }
}