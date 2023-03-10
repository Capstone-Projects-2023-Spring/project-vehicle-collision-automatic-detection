package edu.temple.vehiclecollisiondetection

import android.annotation.SuppressLint
import android.content.SharedPreferences
import android.graphics.Color
import android.os.Bundle
import android.os.Handler
import android.os.HandlerThread
import android.os.SystemClock
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.RecyclerView
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken


private const val SAVE_KEY = "save_key"

class MainActivity : AppCompatActivity() {

    //recycler view to hold contact list
    lateinit var recyclerView: RecyclerView
    lateinit var connectionText: TextView
    private lateinit var preferences: SharedPreferences

    private val bluetoothThread: HandlerThread = HandlerThread("MainActivity")
    private var threadHandler: Handler? = null
    //contact data class
    data class ContactObject(val phoneNumber: String, val name: String)

    @SuppressLint("SetTextI18n")//added for hello world
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        //start bluetooth thread
        bluetoothThread.start()
        threadHandler = Handler(bluetoothThread.getLooper())

        recyclerView = findViewById(R.id.contactRecyclerView)
        connectionText = findViewById(R.id.connectionText)
        connectionText.setTextColor(Color.parseColor("red"))

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
        //start bluetooth routine after app initializes
        threadHandler!!.post(bluetoothRunnable())

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

internal class bluetoothRunnable : Runnable {
    override fun run() {
        for (i in 0..3) {
            //do something
            Log.d("HIIIIIIIIII", "hi")
            SystemClock.sleep(1000)
        }
    }
}