package edu.temple.vehiclecollisiondetection

import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mock
import org.mockito.MockitoAnnotations
import org.robolectric.RobolectricTestRunner

class MainActivityTest{

    @Mock
    private lateinit var mainActivity: MainActivity

    @Before
    fun setup(){
        MockitoAnnotations.openMocks(this)
    }



}