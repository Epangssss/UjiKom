package com.example

import android.app.Application
import com.example.data.AppDatabase
import com.example.data.AppRepository

class JemberGuideApplication : Application() {
    val database by lazy { AppDatabase.getDatabase(this) }
    val repository by lazy { AppRepository(database.userDao(), database.wisataDao()) }
}
