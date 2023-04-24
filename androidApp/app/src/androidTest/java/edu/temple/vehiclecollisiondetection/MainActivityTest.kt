package edu.temple.vehiclecollisiondetection

import android.graphics.Color
import android.util.Log
import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import androidx.test.core.app.ActivityScenario
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.util.ArrayList


class MainActivityTest{

    @Test
    fun testAddContact(){
        //launch activity
        val scenario = ActivityScenario.launch(MainActivity::class.java)
        scenario.onActivity{ activity ->
            val contactObjs = arrayListOf(
                MainActivity.ContactObject("1234567890", "Placeholder")
            )
            val initLen = contactObjs.size

            //adding new contact
            activity.addContact(contactObjs, "TestAdd", "1234567890")

            //comparing initial size to new size
            assertEquals(initLen + 1, contactObjs.size)

        }
    }

    @Test
    fun testDeleteContact(){
        //launch activity
        val scenario = ActivityScenario.launch(MainActivity::class.java)
        scenario.onActivity{ activity ->
            val contactObjs = arrayListOf(
                MainActivity.ContactObject("1234567890", "Placeholder")
            )
            val initLen = contactObjs.size

            //deleting contact by name
            val newList = activity.deleteContact(contactObjs, "Placeholder")

            //comparing initial size to new size
            assertEquals(initLen - 1, newList.size)

        }
    }

    @Test
    fun testSaveContactList(){
        //launch activity
        val scenario = ActivityScenario.launch(MainActivity::class.java)
        scenario.onActivity{ activity ->
            val contactObjs = arrayListOf(
                MainActivity.ContactObject("1234567890", "Placeholder"),
                MainActivity.ContactObject("0987654321", "Other Placeholder"),
                )

            activity.saveContactList(contactObjs)

            val listFromMem = activity.getContactList()

            assertEquals(contactObjs, listFromMem)
        }
    }

    @Test
    fun testGetLocation(){
        val scenario = ActivityScenario.launch(MainActivity::class.java)
        scenario.onActivity{ activity ->

            activity.getLocation()

            assertNotNull(activity.textLat)
        }
    }

    @Test
    fun testDisconnectedIsRed(){
        val scenario = ActivityScenario.launch(MainActivity::class.java)
        scenario.onActivity{ activity ->
            assertEquals(Color.parseColor("red"), activity.connectionText.currentTextColor)
        }
    }

    @Test
    fun testHasPermissions(){
        val scenario = ActivityScenario.launch(MainActivity::class.java)
        scenario.onActivity{ activity ->
            assertTrue(activity.hasPermissions())
        }
    }

}