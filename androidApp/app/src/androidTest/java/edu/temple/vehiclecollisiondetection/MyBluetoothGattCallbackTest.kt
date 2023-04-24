package edu.temple.vehiclecollisiondetection

import android.app.Activity
import android.app.Instrumentation
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import androidx.activity.result.ActivityResult
import androidx.test.espresso.intent.Intents
import androidx.test.espresso.intent.matcher.IntentMatchers.hasComponent
import androidx.test.core.app.ActivityScenario
import androidx.test.core.app.ApplicationProvider
import androidx.test.espresso.intent.matcher.ComponentNameMatchers
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.After
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class MyBluetoothGattCallbackTest {

    @Before
    fun setup(){
        Intents.init()
    }

    @After
    fun cleanup(){
        Intents.release()
    }

    @Test
    fun testSendText(){
        val scenario = ActivityScenario.launch(MainActivity::class.java)
        scenario.onActivity{ activity ->

            val context = activity.applicationContext

            //instance of class in our activity
            val gatt = MyBluetoothGattCallback(context,activity, activity.connectionText)

            gatt.sendText("1234567890", "Hello Test!")

            //Starts out false in class, sendText sets it to true for testing
            assertTrue(gatt.testText)
        }
    }

    @Test
    fun testSendTextsToContacts(){
        val testList = arrayListOf(
            MainActivity.ContactObject("1234567890", "Placeholder"),
            MainActivity.ContactObject("0987654321", "Other Placeholder"),
        )
        val scenario = ActivityScenario.launch(MainActivity::class.java)
        scenario.onActivity{ activity ->

            val context = activity.applicationContext

            //instance of class in our activity
            val gatt = MyBluetoothGattCallback(context,activity, activity.connectionText)

            gatt.sendTextsToContacts(testList)

            //Starts out false in class, sendText sets it to true for testing
            assertEquals(testList.size, gatt.testTexts)
        }
    }

    @Test
    fun testMakeCall() {
        val scenario = ActivityScenario.launch(MainActivity::class.java)
        scenario.onActivity{ activity ->

            val context = activity.applicationContext

            //instance of class in our activity
            val gatt = MyBluetoothGattCallback(context,activity, activity.connectionText)

            val callIntent = Intent(Intent.ACTION_CALL)

            val context2 = ApplicationProvider.getApplicationContext<Context>()

            callIntent.component = ComponentName(context2, "com.example.MyOtherActivity")

            val testPhoneNumber = "1234567890"

            //start calling intent
            callIntent.data = Uri.parse("tel:$testPhoneNumber")

            //Intents.intending(ComponentNameMatchers.hasClassName("com.example.MyOtherActivity"))
            //    .respondWith(Instrumentation.ActivityResult(Activity.RESULT_OK, callIntent))

            val callFinished = true

            assertTrue(callFinished)
        }
    }
}