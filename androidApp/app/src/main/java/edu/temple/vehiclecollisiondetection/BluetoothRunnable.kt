package edu.temple.vehiclecollisiondetection

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothManager
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import android.widget.TextView
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.app.ActivityCompat.requestPermissions
import androidx.core.content.ContextCompat.startActivity

class BluetoothRunnable(currentContext: Context, currentActivity: Activity, connectionText: TextView): Runnable{

    val activeContext = currentContext
    val activeActivity = currentActivity
    val activeTextView = connectionText
    @RequiresApi(Build.VERSION_CODES.S)
    override fun run() {
        hasPermissions()
        var btAdapter: BluetoothAdapter? = null

        //ask user to turn on bluetooth if it isn't already
        if (btAdapter?.isEnabled == false) {
            val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
            activeContext.startActivity(enableBtIntent)
        }

        val bluetoothManager =
            activeContext.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager?

        btAdapter = bluetoothManager?.adapter


        val gattCallback = MyBluetoothGattCallback(activeContext, activeActivity, activeTextView)
        val bluetoothLeScanner = btAdapter?.bluetoothLeScanner
        val scanCallback = object : ScanCallback() {
            override fun onScanResult(callbackType: Int, result: ScanResult) {
                if (ActivityCompat.checkSelfPermission(
                        activeContext,
                        Manifest.permission.BLUETOOTH_SCAN
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    requestPermissions(activeActivity, arrayOf(Manifest.permission.BLUETOOTH_SCAN), 10)
                    //return
                }
                if(result.device.name != null){
                    Log.d("Device Found: ", result.device.name)
                }
                // Check if the scan result matches the target device UUID
                if (result.device.address.equals("E6:EC:C4:09:52:F0")) {
                    Log.d("tag", "FOUND BLE DEVICE")
                    activeActivity.runOnUiThread(Runnable() {
                        Toast.makeText(activeContext, "Device Found", Toast.LENGTH_LONG).show()
                    })

                    // Stop scanning
                    bluetoothLeScanner?.stopScan(this)
                    // Connect to the device
                    val device = result.device
                    var gatt: BluetoothGatt? = null
                    gatt = device?.connectGatt(activeContext, false, gattCallback)
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
        activeActivity.runOnUiThread(Runnable() {
            Toast.makeText(activeContext, "Scanning for Device", Toast.LENGTH_LONG).show()
        })
        bluetoothLeScanner?.startScan(null, scanSettings, scanCallback)
    }
    @RequiresApi(Build.VERSION_CODES.S)
    private fun hasPermissions(): Boolean {
        if (activeContext.checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(
                activeActivity, arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION),11)
        }
        if (activeContext.checkSelfPermission(
                Manifest.permission.BLUETOOTH_CONNECT
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            requestPermissions( activeActivity, arrayOf(Manifest.permission.BLUETOOTH_CONNECT), 12)
        }
        if (activeContext.checkSelfPermission(
                Manifest.permission.BLUETOOTH_SCAN
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            requestPermissions( activeActivity, arrayOf(Manifest.permission.BLUETOOTH_SCAN), 13)
        }
        if (activeContext.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(
                activeActivity, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),14)
        }
        if (activeContext.checkSelfPermission(Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(
                activeActivity, arrayOf(Manifest.permission.CALL_PHONE),15)
        }
        if (activeContext.checkSelfPermission(Manifest.permission.SEND_SMS) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(
                activeActivity, arrayOf(Manifest.permission.SEND_SMS),16)
        }
        return true
    }
}