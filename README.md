[![Open in Codespaces](https://classroom.github.com/assets/launch-codespace-f4981d0f882b2a3f0472912d15f9806d57e124e0fc890972558857b51b24a6f9.svg)](https://classroom.github.com/open-in-codespaces?assignment_repo_id=10185894)
<div align="center">

# Vehicle Collision Automatic Detection
[![Report Issue on Jira](https://img.shields.io/badge/Report%20Issues-Jira-0052CC?style=flat&logo=jira-software)](https://temple-cis-projects-in-cs.atlassian.net/jira/software/c/projects/DT/issues)
[![Deploy Docs](https://github.com/ApplebaumIan/tu-cis-4398-docs-template/actions/workflows/deploy.yml/badge.svg)](https://github.com/ApplebaumIan/tu-cis-4398-docs-template/actions/workflows/deploy.yml)
[![Documentation Website Link](https://img.shields.io/badge/-Documentation%20Website-brightgreen)](https://applebaumian.github.io/tu-cis-4398-docs-template/)


</div>


## Keywords

Section 3, Kotlin, Swift, Android, iOS, Arduino, Bluetooth, App, Accelerometer, Android Studio, Xcode, 

## Project Abstract

This  document  proposes  a  device  with  a  companion  smartphone  app,  which  in  combination,  will  alert emergency services or other individuals in the event of a vehicle collision. The device is attached to the user’s vehicle and connects to their phone via Bluetooth when in range. When the device detects a severe collision (indicated by rapid acceleration/deceleration), the device communicates with the app on the user’s phone, and the app initiates calls or text messages with a brief notification that an car accident has occurred at the user’s location. The user’s location is determined from the GPS coordinates of the user’s smartphone, and the contact numbers can be set by the user through the app. Unlike existing smartphone apps which send alerts based on acceleration of the phone itself, the accelerometer in this product is securely fixed to the vehicle. This will lead to fewer of the false positives that the smartphone apps are prone to.

## Software Requirements:
Android: Requires Android Version 13+ <br />
iOS: iOS 15.5+ <br />
*Note: If your mobile device does not meet these software requirements, the app may not work as expected. <br />

## High Level Requirement

The product consists of two parts: a physical device and a smartphone app. The device is attached to the user’s vehicle and connects to the user’s phone via Bluetooth. When the device detects a vehicle collision, the app on the user’s phone calls or texts predetermined phone numbers with a brief message explaining that an accident has occurred along with GPS coordinates of the user’s phone.

## Conceptual Design

The hardware will consist of a microcontroller with Bluetooth and accelerometer modules attached. The smartphone app will simply run in the background, and when it receives a signal from the device it initiates calls or text messages. In the event that a call is placed, text-to-speech technology can be utilized to create an audible message. The software for the microcontroller will likely be programmed in C or C++ as these are the languages commonly used for embedded systems. The programming language(s) used for the smartphone app will depend on the target operating system; an app for Android would be programmed in Kotlin or Java, and an app for iOS would be programmed in Swift.

## Background

Several similar products already exist. One example of these existing products are smartphone apps or built-in features (such as on the iPhone 14) that work by detecting rapid acceleration or deceleration. The drawback to this is that smartphones are occasionally subjected to these forces outside of car crashes, such as by being dropped or by the user riding a rollercoaster, which can cause false positives and waste emergency resources (Roth). With a device securely attached to a vehicle, many of these false positives would no longer occur. Another example was OnStar, a service in some GM vehicles that would contact emergency services when sensors in the vehicle detected a collision. However, OnStar was discontinued due to the sunsetting of 2G by cellular service providers (LaChance).

## Required Resources

The required hardware will likely include a microcontroller as well as Bluetooth and accelerometer modules. Required software will include IDEs for programming the microcontroller and smartphone app. Specific software may vary depending on the microcontroller model as well as smartphone operating system. An Android app could be developed with Android Studio, and an iOS app could be developed with Xcode. Required background information will be a reasonable threshold for acceleration at which it can be assumed that a car collision has occurred, rather than the user simply driving over a bumpy road or braking sharply. 

## References
Roth, Emma. “The IPhone 14 Keeps Calling 911 on Rollercoasters.” The Verge, The Verge, 9 Oct. 2022, https://www.theverge.com/2022/10/9/23395222/iphone-14-calling-911-rollercoasters-apple-crash-detection.
LaChance, Dave. “Older GM Vehicles to Lose Connection to Onstar with Sunset of 2G Network.” Repairer Driven News, 30 Nov. 2022, https://www.repairerdrivennews.com/2022/11/30/130475/.


## Collaborators

[//]: # ( readme: collaborators -start )
<table>
<tr>
    <td align="center">
        <a href="https://github.com/Capstone-Projects-2023-Spring/project-vehicle-collision-automatic-detection">
            <br />
            <sub><b>Evan Noyes</b></sub>
        </a>
    </td>
    <td align="center">
        <a href="https://github.com/AFoster414">
            <br />
            <sub><b>Austin Foster</b></sub>
        </a>
    </td>
    <td align="center">
        <a href="https://github.com/thanhnguyen46">
            <br />
            <sub><b>Thanh Nguyen</b></sub>
        </a>
    </td>
    <td align="center">
        <a href="https://github.com/Braddinger13">
            <br />
            <sub><b>Bradley Dinger</b></sub>
        </a>
    </td>
     <td align="center">
        <a href="https://github.com/ayarcia1">
            <br />
            <sub><b>Arif Ayarci</b></sub>
        </a>
    </td>
    <td align="center">
        <a href="https://github.com/NathanAdiam">
            <br />
            <sub><b>Nathan Adiam</b></sub>
        </a>
    </td>
    <td align="center">
        <a href="https://github.com/qwertyist12">
            <br />
            <sub><b>Justice Chang</b></sub>
        </a>
    </td>    
    </tr>
</table>

[//]: # ( readme: collaborators -end )
