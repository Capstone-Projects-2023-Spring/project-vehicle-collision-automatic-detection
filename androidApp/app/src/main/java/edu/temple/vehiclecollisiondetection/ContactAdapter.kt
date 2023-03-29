package edu.temple.vehiclecollisiondetection

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView

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