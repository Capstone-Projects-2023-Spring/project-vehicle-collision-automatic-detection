package edu.temple.vehiclecollisiondetection

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.Handler
import android.os.IBinder
import android.util.Log

class CountdownService: Service() {

    lateinit var countdownHandler: Handler
    var shouldStop = false

    inner class CountdownBinder: Binder(){
        fun tenSecondCountdown(){
            shouldStop = false
            runCountdown(10)
        }

        fun stopCountdown(){
            shouldStop = true
        }

        fun setHandler(handler: Handler){
            countdownHandler = handler
        }
    }

    override fun onBind(intent: Intent?): IBinder {
        return CountdownBinder()
    }

    fun runCountdown(startTime: Int){
        Thread{
            for(i in startTime downTo 1){
                if(shouldStop)break;
                Log.d("Countdown", i.toString())
                if (::countdownHandler.isInitialized){
                    countdownHandler.sendEmptyMessage(i)
                }
                //sleep 1 second
                Thread.sleep(1000)
            }
        }.start()
    }

    override fun onDestroy() {
        super.onDestroy()
        shouldStop = true
    }
}