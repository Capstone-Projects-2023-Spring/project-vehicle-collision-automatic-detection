package edu.temple.vehiclecollisiondetection

import android.graphics.Color
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView

class MainActivity : AppCompatActivity() {

    //recycler view to hold contact list
    lateinit var recyclerView: RecyclerView
    lateinit var connectionText: TextView

    //contact data class
    data class ContactObject(val phoneNumber: String, val name: String)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        recyclerView = findViewById(R.id.contactRecyclerView)
        connectionText = findViewById(R.id.connectionText)

        connectionText.setTextColor(Color.parseColor("red"))

        val contactObjects = arrayListOf(
            ContactObject("4846391351", "Brad"),
            ContactObject("9999999999", "Test")
        )

        recyclerView.adapter = ContactAdapter(contactObjects)
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