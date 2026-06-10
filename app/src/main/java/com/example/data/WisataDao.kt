package com.example.data

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface WisataDao {
    @Query("SELECT * FROM wisata_spots ORDER BY rating DESC")
    fun getAllWisata(): Flow<List<Wisata>>

    @Query("SELECT * FROM wisata_spots WHERE id = :id LIMIT 1")
    fun getWisataById(id: Int): Flow<Wisata?>

    @Query("SELECT * FROM wisata_spots WHERE id = :id LIMIT 1")
    suspend fun getWisataByIdSuspended(id: Int): Wisata?

    @Query("SELECT * FROM wisata_spots WHERE name LIKE :query OR category LIKE :query OR address LIKE :query ORDER BY rating DESC")
    fun searchWisata(query: String): Flow<List<Wisata>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertWisata(wisata: Wisata)

    @Update
    suspend fun updateWisata(wisata: Wisata)

    @Delete
    suspend fun deleteWisata(wisata: Wisata)
}
