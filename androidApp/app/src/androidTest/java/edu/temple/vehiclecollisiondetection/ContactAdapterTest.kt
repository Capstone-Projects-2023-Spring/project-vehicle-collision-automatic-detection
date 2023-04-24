package edu.temple.vehiclecollisiondetection

import org.junit.Assert.*
import org.junit.Test

class ContactAdapterTest{

    val testList = arrayListOf(
        MainActivity.ContactObject("1234567890", "Placeholder"),
        MainActivity.ContactObject("0987654321", "Other Placeholder"),
    )

    private val adapter = ContactAdapter(testList)

    @Test
    fun testContactAdapterItemSize(){
        assertEquals(testList.size, adapter.itemCount)
    }

}