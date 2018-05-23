package com.example.entreco.tamenori

import android.app.Application
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import com.google.firebase.database.*


class Tamenori : Application(), ChildEventListener {

    private val API_KEY = "AIzaSyA7ruSb75KcdYojOy4UDX-JNC_vagp01no"
    private val APPLICATION_ID = "reversi-wars"
    private val DATABASE_URL = "https://reversi-wars.firebaseio.com"

    override fun onCreate() {
        super.onCreate()

        FirebaseApp.initializeApp(this, FirebaseOptions.Builder()
                .setApiKey(API_KEY)
                .setApplicationId(APPLICATION_ID)
                .setDatabaseUrl(DATABASE_URL)
                .build())


        // Signin - optionally or just create new bot
        val players = FirebaseDatabase.getInstance().getReference("players")
        val yourPlayerRef = players.push()

        // Add your bot with {"name":"<your bot name>"}
        yourPlayerRef.child("public").child("name").setValue("TamenoriAndroid")

        // Now Proove you're online by playing PingPong
        yourPlayerRef.child("public").child("ping").addValueEventListener(object : ValueEventListener {
            override fun onCancelled(p0: DatabaseError?) {}

            override fun onDataChange(p0: DataSnapshot?) {
                yourPlayerRef.child("public").child("ping").setValue("pong")
            }
        })

        // Listen for Game participation
        yourPlayerRef.child("matches").addChildEventListener(this)
    }

    override fun onChildAdded(p0: DataSnapshot?, p1: String?) {
        // Yeah, I'm starting in a match
        val moveRef = p0?.ref?.child("move")!!
        val turnRef = p0.ref?.child("board")!!
        turnRef.addValueEventListener(object : ValueEventListener {
            override fun onCancelled(p0: DatabaseError?) {}

            override fun onDataChange(p0: DataSnapshot?) {
                submitMove(moveRef)
            }
        })

        moveRef.addValueEventListener(object : ValueEventListener {
            override fun onCancelled(p0: DatabaseError?) {}

            override fun onDataChange(p0: DataSnapshot?) {
                if (p0?.value != null && p0.value.toString().isNotBlank()) {
                    if (p0.value.toString() == "rejected") {
                        submitMove(moveRef)
                    }
                }
            }
        })
    }

    private fun submitMove(moveRef: DatabaseReference) {
        val row: Int = (Math.random() * 8).toInt()
        val col: Int = (Math.random() * 8).toInt()
        moveRef.setValue("{\"row\":$row, \"col\":$col}")
    }


    override fun onCancelled(p0: DatabaseError?) {}

    override fun onChildMoved(p0: DataSnapshot?, p1: String?) {}

    override fun onChildChanged(p0: DataSnapshot?, p1: String?) {}

    override fun onChildRemoved(p0: DataSnapshot?) {}
}
