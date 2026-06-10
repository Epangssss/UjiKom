package com.example.data

import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

class AppRepository(
    private val userDao: UserDao,
    private val wisataDao: WisataDao,
    private val externalScope: CoroutineScope = CoroutineScope(Dispatchers.IO)
) {
    init {
        // Automatically seed the database if it is currently empty
        externalScope.launch {
            try {
                val existingList = wisataDao.getAllWisata().first()
                if (existingList.isEmpty()) {
                    Log.d("AppRepository", "Database is empty. Seeding initial Jember attractions...")
                    getInitialWisataData().forEach { spot ->
                        wisataDao.insertWisata(spot)
                    }
                }
            } catch (e: Exception) {
                Log.e("AppRepository", "Error seeding database: ${e.message}", e)
            }
        }
    }

    // User Operations
    fun getUser(username: String): Flow<User?> = userDao.getUser(username)
    suspend fun getUserSuspended(username: String): User? = userDao.getUserSuspended(username)
    suspend fun insertUser(user: User) = userDao.insertUser(user)
    suspend fun updateUser(user: User) = userDao.updateUser(user)

    // Wisata Operations
    fun getAllWisata(): Flow<List<Wisata>> = wisataDao.getAllWisata()
    fun getWisataById(id: Int): Flow<Wisata?> = wisataDao.getWisataById(id)
    suspend fun getWisataByIdSuspended(id: Int): Wisata? = wisataDao.getWisataByIdSuspended(id)
    fun searchWisata(query: String): Flow<List<Wisata>> {
        val searchQuery = "%$query%"
        return wisataDao.searchWisata(searchQuery)
    }
    suspend fun insertWisata(wisata: Wisata) = wisataDao.insertWisata(wisata)
    suspend fun updateWisata(wisata: Wisata) = wisataDao.updateWisata(wisata)
    suspend fun deleteWisata(wisata: Wisata) = wisataDao.deleteWisata(wisata)

    private fun getInitialWisataData(): List<Wisata> {
        return listOf(
            Wisata(
                name = "Pantai Papuma",
                category = "Pantai",
                address = "Desa Lojejer, Kecamatan Wuluhan, Jember",
                description = "Pantai dengan pasir putih yang sangat indah dan deretan batu karang yang menjulang tinggi di tengah laut. Terkenal dengan pemandangan matahari terbit dan tenggelam yang memukau serta perahu nelayan yang bersandar estetis.",
                openingHours = "24 Jam",
                ticketPrice = "Rp 15.000",
                rating = 4.8,
                latitude = -8.4419,
                longitude = 113.5539,
                imageUrl = "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80"
            ),
            Wisata(
                name = "Teluk Love",
                category = "Pantai",
                address = "Kawasan Pantai Payangan, Ambulu, Jember",
                description = "Teluk unik berbentuk hati (Love) yang terbentuk secara alami dari garis tebing dan deburan ombak. Pengunjung dapat menaiki Bukit Domba untuk menyaksikan lekukan bentuk hati ini secara sempurna.",
                openingHours = "05:00 - 18:00",
                ticketPrice = "Rp 10.000",
                rating = 4.6,
                latitude = -8.4352,
                longitude = 113.6190,
                imageUrl = "https://images.unsplash.com/photo-1519046904884-53103b34b206?auto=format&fit=crop&w=800&q=80"
            ),
            Wisata(
                name = "Puncak Rembangan",
                category = "Alam",
                address = "Dusun Rembangan, Kemuning Lor, Arjasa, Jember",
                description = "Destinasi dataran tinggi pegunungan sejuk di lereng Gunung Argopuro. Menyuguhkan pemandangan bentang kota Jember dari ketinggian, perkebunan buah naga, susu sapi segar khas, dan sejuknya kolam renang alami peninggalan Belanda.",
                openingHours = "07:00 - 22:00",
                ticketPrice = "Rp 12.000",
                rating = 4.5,
                latitude = -8.0827,
                longitude = 113.7121,
                imageUrl = "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80"
            ),
            Wisata(
                name = "Air Terjun Tancak",
                category = "Air Terjun",
                address = "Desa Suco Pangepok, Jelbuk, Jember",
                description = "Air terjun tertinggi di kabupaten Jember dengan ketinggian mencapai 82 meter yang mengalir deras di lereng perbukitan hijau. Dikelilingi hutan yang asri dan hamparan wangi perkebunan kopi robusta.",
                openingHours = "07:00 - 16:30",
                ticketPrice = "Rp 5.000",
                rating = 4.4,
                latitude = -8.0401,
                longitude = 113.7259,
                imageUrl = "https://images.unsplash.com/photo-1432406186267-5c2c140a5a6e?auto=format&fit=crop&w=800&q=80"
            ),
            Wisata(
                name = "Taman Botani Sukorambi",
                category = "Taman",
                address = "Jl. Mujahir, Sukorambi, Jember",
                description = "Taman botani rekreasi edukatif terlengkap di Jember. Sempurna untuk rekreasi keluarga dengan koleksi ratusan jenis tanaman obat, bunga cantik, kebun buah hewan ternak kecil, kolam renang, dan outbound.",
                openingHours = "08:00 - 16:00",
                ticketPrice = "Rp 20.000",
                rating = 4.5,
                latitude = -8.1565,
                longitude = 113.6655,
                imageUrl = "https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?auto=format&fit=crop&w=800&q=80"
            ),
            Wisata(
                name = "Puslit Kopi dan Kakao",
                category = "Edukasi",
                address = "Desa Nogosari, Rambipuji, Jember",
                description = "Satu-satunya Pusat Penelitian Kopi dan Kakao di Indonesia. Memberikan edukasi menarik tentang pembibitan, modernisasi pengolahan kopi dan cokelat, berkeliling menaiki kereta kayu tradisional, serta kafe cokelat premium.",
                openingHours = "08:00 - 15:30",
                ticketPrice = "Rp 15.000",
                rating = 4.7,
                latitude = -8.2435,
                longitude = 113.6111,
                imageUrl = "https://images.unsplash.com/photo-1447933601403-0c6688de566e?auto=format&fit=crop&w=800&q=80"
            )
        )
    }
}
