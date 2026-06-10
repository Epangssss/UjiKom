package com.example.data

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "wisata_spots")
data class Wisata(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val name: String,
    val category: String, // Pantai, Air Terjun, Taman, Edukasi, Alam, Keluarga
    val address: String,
    val description: String,
    val openingHours: String,
    val ticketPrice: String,
    val rating: Double,
    val latitude: Double,
    val longitude: Double,
    val imageUrl: String
)
