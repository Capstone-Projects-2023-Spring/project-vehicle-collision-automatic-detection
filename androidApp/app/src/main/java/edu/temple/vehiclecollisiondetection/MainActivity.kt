package edu.temple.vehiclecollisiondetection

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.*
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.graphics.Color
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.CountDownTimer
import android.telephony.SmsManager
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import com.android.volley.Request
import com.android.volley.Response
import com.android.volley.toolbox.JsonObjectRequest
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.util.*


private const val SAVE_KEY = "save_key"
val REQUEST_PHONE_CALL = 1
val REQUEST_SEND_SMS = 2
class MainActivity : AppCompatActivity(), LocationListener {

    //recycler view to hold contact list
    lateinit var recyclerView: RecyclerView
    lateinit var connectionText: TextView
    lateinit var characteristicData: TextView
    private lateinit var preferences: SharedPreferences

    //DELETE
    private lateinit var locationManager: LocationManager
    private var textLat: Double? = 39.981991 //variable used to record Latitude & defaulted to avoid null errors
    private var textLong: Double? = -75.153053 //variable used to record Longitude & defaulted to avoid null errors
    val API_KEY = "AIzaSyAMxe8n3-KtX3cRs-4BKSd7lXovPlTvEZE" //Move later
    private lateinit var locButton: Button


    //countdown timer object
    private var mCountDownTimer: CountDownTimer? = null
    private val countdownStartTime: Long = 11000 //timer duration for when crashes are detected, current set at 11 seconds (takes a second to popup)
    private var mTimeLeftInMillis = countdownStartTime //variable for tracking countdown duration remaining at a given time
    private var countdownValueInt: Int? = null

    //contact data class
    data class ContactObject(val phoneNumber: String, val name: String)

    @RequiresApi(Build.VERSION_CODES.S)
    @SuppressLint("SetTextI18n")//added for hello world
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        hasPermissions()
        recyclerView = findViewById(R.id.contactRecyclerView)
        connectionText = findViewById(R.id.connectionText)
        connectionText.setTextColor(Color.parseColor("red"))
        characteristicData = findViewById(R.id.characteristicDataText)

        //DELETE
        locButton = findViewById(R.id.locationButton)
        locButton.setOnClickListener{
            getLocation()
        }

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
            hasPermissions()
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
            hasPermissions()
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
        if (applicationContext.checkSelfPermission(Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(
                arrayOf(Manifest.permission.CALL_PHONE),15)
        }
        if (applicationContext.checkSelfPermission(Manifest.permission.SEND_SMS) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(
                arrayOf(Manifest.permission.SEND_SMS),16)
        }
        return true
    }

    //TEST GETTING ADDRESS DELETE LATER
    private fun getLocation(){
        this.runOnUiThread{
            locationManager = this.getSystemService(Context.LOCATION_SERVICE) as LocationManager

            if ((ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED)) {
                ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), 3)
            }
            locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 5000, 5f, this)
        }
    }

    @RequiresApi(33)
    override fun onLocationChanged(location: Location) {
        Log.d("Location", "Lat: ${location.latitude}, Long:${location.longitude}")

        textLat = location.latitude
        textLong = location.longitude

        getStreetAddress(textLat!!, textLong!!)
    }


     fun getStreetAddress(latitude: Double, longitude: Double){
        val queue = Volley.newRequestQueue(this)
        val url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${latitude},${longitude}&key=${API_KEY}"

        Log.d("volley", "Starting volley")
        // Request a string response from the provided URL.
        val jsonObjectRequest = JsonObjectRequest(
             Request.Method.GET, url, null,
            { response ->
                val address = response.getJSONArray("results")
                    .getJSONObject(0)
                    .getString("formatted_address")
                Log.d("res", address.toString())
            },
            { Log.d("error", "That didn't work") })

// Add the request to the RequestQueue.
        queue.add(jsonObjectRequest)
    }

}
