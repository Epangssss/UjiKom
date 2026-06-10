package com.example.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.data.AppRepository
import com.example.data.User
import com.example.data.Wisata
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

class JemberViewModel(private val repository: AppRepository) : ViewModel() {

    // Auth State
    private val _currentUser = MutableStateFlow<User?>(null)
    val currentUser: StateFlow<User?> = _currentUser.asStateFlow()

    private val _authError = MutableStateFlow<String?>(null)
    val authError: StateFlow<String?> = _authError.asStateFlow()

    private val _registrationSuccess = MutableStateFlow(false)
    val registrationSuccess: StateFlow<Boolean> = _registrationSuccess.asStateFlow()

    // Wisata State
    val allWisata: StateFlow<List<Wisata>> = repository.getAllWisata()
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )

    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()

    @OptIn(ExperimentalCoroutinesApi::class)
    val searchResults: StateFlow<List<Wisata>> = _searchQuery
        .flatMapLatest { query ->
            repository.searchWisata(query)
        }
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )

    // CRUD State
    private val _crudMessage = MutableStateFlow<String?>(null)
    val crudMessage: StateFlow<String?> = _crudMessage.asStateFlow()

    fun clearAuthStates() {
        _authError.value = null
        _registrationSuccess.value = false
    }

    fun clearCrudStates() {
        _crudMessage.value = null
    }

    // --- Authentication Actions ---

    fun login(username: String, emailOrPhone: String, passwordText: String) {
        viewModelScope.launch {
            _authError.value = null
            if (username.isBlank() || passwordText.isBlank()) {
                _authError.value = "Username dan Password tidak boleh kosong"
                return@launch
            }
            val user = repository.getUserSuspended(username)
            if (user == null) {
                _authError.value = "Username tidak ditemukan"
            } else if (user.password != passwordText) {
                _authError.value = "Password salah"
            } else {
                _currentUser.value = user
                _authError.value = null
            }
        }
    }

    fun signUp(username: String, passwordText: String, fullName: String, email: String, phone: String, address: String) {
        viewModelScope.launch {
            _authError.value = null
            _registrationSuccess.value = false
            
            if (username.isBlank() || passwordText.isBlank() || fullName.isBlank() || email.isBlank() || phone.isBlank()) {
                _authError.value = "Semua kolom wajib diisi, kecuali alamat"
                return@launch
            }

            val existingUser = repository.getUserSuspended(username)
            if (existingUser != null) {
                _authError.value = "Username sudah digunakan"
                return@launch
            }

            val newUser = User(
                username = username,
                password = passwordText,
                fullName = fullName,
                email = email,
                phone = phone,
                address = address
            )
            repository.insertUser(newUser)
            _registrationSuccess.value = true
        }
    }

    fun logOut() {
        _currentUser.value = null
        clearAuthStates()
    }

    fun updateProfile(fullName: String, email: String, phone: String, address: String) {
        val user = _currentUser.value ?: return
        viewModelScope.launch {
            val updatedUser = user.copy(
                fullName = fullName,
                email = email,
                phone = phone,
                address = address
            )
            repository.updateUser(updatedUser)
            _currentUser.value = updatedUser
            _crudMessage.value = "Profil berhasil diperbarui!"
        }
    }

    // --- Wisata CRUD Actions ---

    fun updateSearchQuery(query: String) {
        _searchQuery.value = query
    }

    fun addWisata(
        name: String,
        category: String,
        address: String,
        description: String,
        ticketPrice: String,
        openingHours: String,
        rating: Double,
        latitude: Double,
        longitude: Double,
        imageUrl: String
    ) {
        viewModelScope.launch {
            if (name.isBlank() || address.isBlank() || description.isBlank()) {
                _crudMessage.value = "Kolom nama, alamat, dan deskripsi wajib diisi!"
                return@launch
            }

            val validatedImageUrl = if (imageUrl.isBlank()) {
                // Default placeholder based on category
                when (category.lowercase()) {
                    "pantai" -> "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80"
                    "air terjun" -> "https://images.unsplash.com/photo-1432406186267-5c2c140a5a6e?auto=format&fit=crop&w=800&q=80"
                    "taman" -> "https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?auto=format&fit=crop&w=800&q=80"
                    "alam" -> "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80"
                    "edukasi" -> "https://images.unsplash.com/photo-1447933601403-0c6688de566e?auto=format&fit=crop&w=800&q=80"
                    else -> "https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=800&q=80"
                }
            } else {
                imageUrl
            }

            val newSpot = Wisata(
                name = name,
                category = category,
                address = address,
                description = description,
                ticketPrice = ticketPrice.ifBlank { "Gratis" },
                openingHours = openingHours.ifBlank { "24 Jam" },
                rating = if (rating <= 0) 4.5 else rating,
                latitude = latitude,
                longitude = longitude,
                imageUrl = validatedImageUrl
            )

            repository.insertWisata(newSpot)
            _crudMessage.value = "Destinasi wisata berhasil ditambahkan!"
        }
    }

    fun updateWisata(
        id: Int,
        name: String,
        category: String,
        address: String,
        description: String,
        ticketPrice: String,
        openingHours: String,
        rating: Double,
        latitude: Double,
        longitude: Double,
        imageUrl: String
    ) {
        viewModelScope.launch {
            if (name.isBlank() || address.isBlank() || description.isBlank()) {
                _crudMessage.value = "Kolom nama, alamat, dan deskripsi wajib diisi!"
                return@launch
            }

            val existingSpot = repository.getWisataByIdSuspended(id)
            if (existingSpot == null) {
                _crudMessage.value = "Destinasi tidak ditemukan!"
                return@launch
            }

            val updatedSpot = existingSpot.copy(
                name = name,
                category = category,
                address = address,
                description = description,
                ticketPrice = ticketPrice.ifBlank { "Gratis" },
                openingHours = openingHours.ifBlank { "24 Jam" },
                rating = if (rating <= 0) 4.5 else rating,
                latitude = latitude,
                longitude = longitude,
                imageUrl = imageUrl.ifBlank { existingSpot.imageUrl }
            )

            repository.updateWisata(updatedSpot)
            _crudMessage.value = "Destinasi wisata berhasil diubah!"
        }
    }

    fun deleteWisata(wisata: Wisata) {
        viewModelScope.launch {
            repository.deleteWisata(wisata)
            _crudMessage.value = "Destinasi wisata berhasil dihapus!"
        }
    }
}

class ViewModelFactory(private val repository: AppRepository) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(JemberViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return JemberViewModel(repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
