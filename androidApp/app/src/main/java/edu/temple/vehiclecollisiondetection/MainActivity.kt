package edu.temple.vehiclecollisiondetection

import android.Manifest
import android.annotation.SuppressLint
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.os.CountDownTimer
import android.telephony.SmsManager
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.RecyclerView
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.util.*


private const val SAVE_KEY = "save_key"
val REQUEST_PHONE_CALL = 1
val REQUEST_SEND_SMS = 2

class MainActivity : AppCompatActivity() {

    //recycler view to hold contact list
    lateinit var recyclerView: RecyclerView
    lateinit var connectionText: TextView
    lateinit var characteristicData: TextView
    private lateinit var preferences: SharedPreferences
    private lateinit var callButton: Button


    //countdown timer object
    private var mCountDownTimer: CountDownTimer? = null
    private val countdownStartTime: Long = 11000 //timer duration for when crashes are detected, current set at 11 seconds (takes a second to popup)
    private var mTimeLeftInMillis = countdownStartTime //variable for tracking countdown duration remaining at a given time
    private var countdownValueInt: Int? = null

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

        //********
        // Testing crash popup
        callButton = findViewById(R.id.callTest)
        callButton.setOnClickListener{
            //set value to starting time
            mTimeLeftInMillis = countdownStartTime
            //if a crash is detected by the arduino device, initiate crash popup
            val crashDialogView = LayoutInflater.from(this).inflate(R.layout.crash_procedure_popup, null)
            val crashDialogBuilder = AlertDialog.Builder(this)
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
                    characteristicData.setText("Calling Emergency Services!")
                }
            }.start()
            //cancel button
            val cancelButton = crashDialogView.findViewById<Button>(R.id.crash_cancel_button)
            cancelButton.setOnClickListener {
                crashAlertDialog.dismiss()
                mCountDownTimer?.cancel()
            }
        }
        //********

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
            var btRunnable = BluetoothRunnable(this@MainActivity, this, connectionText)
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

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_PHONE_CALL)makeCall("+14846391351")
        if (requestCode == REQUEST_SEND_SMS)sendText("+14846391351", "Hello from android!")
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

    private fun sendText(phoneNumber: String, message: String){
        var smsManager: SmsManager? = null
        //var id = SmsManager.getDefaultSmsSubscriptionId()
        smsManager = this.getSystemService(SmsManager::class.java)

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
        startActivity(callIntent)
    }

}

