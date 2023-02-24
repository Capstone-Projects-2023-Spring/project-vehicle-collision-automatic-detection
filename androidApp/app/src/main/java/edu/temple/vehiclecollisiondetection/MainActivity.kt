package edu.temple.vehiclecollisiondetection

import android.annotation.SuppressLint
import android.graphics.Color
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView

class MainActivity : AppCompatActivity() {

    //recycler view to hold contact list
    lateinit var recyclerView: RecyclerView
    lateinit var connectionText: TextView
    lateinit var helloWorldText: TextView //added for hello world

    //contact data class
    data class ContactObject(val phoneNumber: String, val name: String)

    @SuppressLint("SetTextI18n")//added for hello world
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        recyclerView = findViewById(R.id.contactRecyclerView)
        connectionText = findViewById(R.id.connectionText)
        helloWorldText = findViewById(R.id.HelloWorldView)

        connectionText.setTextColor(Color.parseColor("red"))

        val contactObjects = arrayListOf(
            ContactObject("4846391351", "Brad"),
            ContactObject("9999999999", "Test")
        )

        recyclerView.adapter = ContactAdapter(contactObjects)

       val addContactButton: View = findViewById(R.id.fab)
        addContactButton.setOnClickListener{
            helloWorldText.setText("Hello World!")//added for hello world
            helloWorldText.setTextColor(Color.parseColor("green"))//added for hello world
        }
    }
}

class ContactAdapter(_contactObjects: ArrayList<MainActivity.ContactObject>): RecyclerView.Adapter<ContactAdapter.ViewHolder>(){

    private var contactObjects = _contactObjects

    inner class ViewHolder (itemView: View):  RecyclerView.ViewHolder(itemView) {
        var textView: TextView
        lateinit var contactObject: MainActivity.ContactObject

        init {
            textView = itemView.findViewById(R.id.listItem)
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
    }

    override fun getItemCount(): Int {
        return contactObjects.size
    }
}