package com.example.ui.screens

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.theme.PrimaryGreen
import com.example.ui.viewmodel.JemberViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddEditWisataScreen(
    spotId: Int?, // if null, mode is Add; otherwise mode is Edit
    viewModel: JemberViewModel,
    onNavigateBack: () -> Unit
) {
    val context = LocalContext.current
    val allWisata by viewModel.allWisata.collectAsState()
    val crudMessage by viewModel.crudMessage.collectAsState()

    val existingSpot = remember(allWisata, spotId) {
        if (spotId != null) allWisata.find { it.id == spotId } else null
    }

    var name by remember { mutableStateOf("") }
    var selectedCategory by remember { mutableStateOf("Pantai") }
    var address by remember { mutableStateOf("") }
    var description by remember { mutableStateOf("") }
    var ticketPrice by remember { mutableStateOf("") }
    var openingHours by remember { mutableStateOf("") }
    var ratingStr by remember { mutableStateOf("") }
    var latitudeStr by remember { mutableStateOf("") }
    var longitudeStr by remember { mutableStateOf("") }
    var imageUrl by remember { mutableStateOf("") }

    var expandedCategory by remember { mutableStateOf(false) }
    val categories = listOf("Pantai", "Air Terjun", "Taman", "Edukasi", "Alam", "Keluarga")

    // Seed fields if editing
    LaunchedEffect(existingSpot) {
        existingSpot?.let {
            name = it.name
            selectedCategory = it.category
            address = it.address
            description = it.description
            ticketPrice = it.ticketPrice
            openingHours = it.openingHours
            ratingStr = it.rating.toString()
            latitudeStr = it.latitude.toString()
            longitudeStr = it.longitude.toString()
            imageUrl = it.imageUrl
        }
    }

    // React to success messages
    LaunchedEffect(crudMessage) {
        crudMessage?.let {
            Toast.makeText(context, it, Toast.LENGTH_SHORT).show()
            viewModel.clearCrudStates()
            onNavigateBack()
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = if (spotId == null) "Tambah Wisata Baru" else "Edit Tempat Wisata",
                        fontWeight = FontWeight.Bold
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Kembali")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = MaterialTheme.colorScheme.surface)
            )
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .background(MaterialTheme.colorScheme.background)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(20.dp)
                    .verticalScroll(rememberScrollState()),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Top
            ) {
                // Section Title indicator
                Text(
                    text = "Informasi Wisata Jember",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = PrimaryGreen,
                    modifier = Modifier
                        .align(Alignment.Start)
                        .padding(bottom = 16.dp)
                )

                // Spot Name Form text input
                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it },
                    label = { Text("Nama Wisata *") },
                    leadingIcon = { Icon(Icons.Default.DriveFileRenameOutline, contentDescription = null) },
                    singleLine = true,
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .testTag("form_name_input"),
                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = PrimaryGreen)
                )

                Spacer(modifier = Modifier.height(14.dp))

                // Custom drop-down for Category Selection
                Box(modifier = Modifier.fillMaxWidth()) {
                    OutlinedTextField(
                        value = selectedCategory,
                        onValueChange = {},
                        readOnly = true,
                        label = { Text("Kategori Wisata *") },
                        leadingIcon = { Icon(Icons.Default.Category, contentDescription = null) },
                        trailingIcon = {
                            Icon(
                                imageVector = if (expandedCategory) Icons.Default.ArrowDropUp else Icons.Default.ArrowDropDown,
                                contentDescription = "Dropdown Kategori",
                                modifier = Modifier.clickable { expandedCategory = !expandedCategory }
                            )
                        },
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { expandedCategory = !expandedCategory }
                            .testTag("form_category_dropdown"),
                        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = PrimaryGreen)
                    )

                    DropdownMenu(
                        expanded = expandedCategory,
                        onDismissRequest = { expandedCategory = false },
                        modifier = Modifier.fillMaxWidth(0.9f)
                    ) {
                        categories.forEach { category ->
                            DropdownMenuItem(
                                text = { Text(category) },
                                onClick = {
                                    selectedCategory = category
                                    expandedCategory = false
                                }
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(14.dp))

                // Short Location Address Input
                OutlinedTextField(
                    value = address,
                    onValueChange = { address = it },
                    label = { Text("Alamat Lengkap *") },
                    leadingIcon = { Icon(Icons.Default.LocationOn, contentDescription = null) },
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .testTag("form_address_input"),
                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = PrimaryGreen)
                )

                Spacer(modifier = Modifier.height(14.dp))

                // Complete description textbox (multiline)
                OutlinedTextField(
                    value = description,
                    onValueChange = { description = it },
                    label = { Text("Deskripsi Wisata *") },
                    leadingIcon = { Icon(Icons.Default.Description, contentDescription = null) },
                    minLines = 3,
                    maxLines = 5,
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .testTag("form_desc_input"),
                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = PrimaryGreen)
                )

                Spacer(modifier = Modifier.height(14.dp))

                // Operating schedules and price structures
                Row(modifier = Modifier.fillMaxWidth()) {
                    OutlinedTextField(
                        value = ticketPrice,
                        onValueChange = { ticketPrice = it },
                        label = { Text("Harga Tiket (cth: Rp 10.000)") },
                        leadingIcon = { Icon(Icons.Default.LocalActivity, contentDescription = null) },
                        singleLine = true,
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .weight(1f)
                            .testTag("form_price_input"),
                        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = PrimaryGreen)
                    )

                    Spacer(modifier = Modifier.width(10.dp))

                    OutlinedTextField(
                        value = openingHours,
                        onValueChange = { openingHours = it },
                        label = { Text("Jam Buka (cth: 08:00 - 17:00)") },
                        leadingIcon = { Icon(Icons.Default.Schedule, contentDescription = null) },
                        singleLine = true,
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .weight(1f)
                            .testTag("form_hours_input"),
                        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = PrimaryGreen)
                    )
                }

                Spacer(modifier = Modifier.height(14.dp))

                // Coordinates panel (latitude / longitude digits) & visual Rating stars
                Row(modifier = Modifier.fillMaxWidth()) {
                    OutlinedTextField(
                        value = latitudeStr,
                        onValueChange = { latitudeStr = it },
                        label = { Text("Latitude (misal: -8.441)") },
                        leadingIcon = { Icon(Icons.Default.Map, contentDescription = null) },
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .weight(1f)
                            .testTag("form_lat_input"),
                        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = PrimaryGreen)
                    )

                    Spacer(modifier = Modifier.width(10.dp))

                    OutlinedTextField(
                        value = longitudeStr,
                        onValueChange = { longitudeStr = it },
                        label = { Text("Longitude (misal: 113.55)") },
                        leadingIcon = { Icon(Icons.Default.Map, contentDescription = null) },
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .weight(1f)
                            .testTag("form_lng_input"),
                        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = PrimaryGreen)
                    )
                }

                Spacer(modifier = Modifier.height(14.dp))

                Row(modifier = Modifier.fillMaxWidth()) {
                    OutlinedTextField(
                        value = ratingStr,
                        onValueChange = { ratingStr = it },
                        label = { Text("Rating (1.0 - 5.0)") },
                        leadingIcon = { Icon(Icons.Default.Star, contentDescription = null) },
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .weight(1f)
                            .testTag("form_rating_input"),
                        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = PrimaryGreen)
                    )

                    Spacer(modifier = Modifier.width(10.dp))

                    OutlinedTextField(
                        value = imageUrl,
                        onValueChange = { imageUrl = it },
                        label = { Text("URL Gambar Wisata") },
                        leadingIcon = { Icon(Icons.Default.Image, contentDescription = null) },
                        singleLine = true,
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .weight(1.5f)
                            .testTag("form_image_input"),
                        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = PrimaryGreen)
                    )
                }

                Spacer(modifier = Modifier.height(32.dp))

                Button(
                    onClick = {
                        val parsedRating = ratingStr.toDoubleOrNull() ?: 4.5
                        val parsedLat = latitudeStr.toDoubleOrNull() ?: 0.0
                        val parsedLng = longitudeStr.toDoubleOrNull() ?: 0.0

                        if (name.isBlank() || address.isBlank() || description.isBlank()) {
                            Toast.makeText(context, "Nama, Alamat, dan Deskripsi wajib diisi!", Toast.LENGTH_SHORT).show()
                        } else {
                            if (spotId == null) {
                                viewModel.addWisata(
                                    name = name,
                                    category = selectedCategory,
                                    address = address,
                                    description = description,
                                    ticketPrice = ticketPrice,
                                    openingHours = openingHours,
                                    rating = parsedRating,
                                    latitude = parsedLat,
                                    longitude = parsedLng,
                                    imageUrl = imageUrl
                                )
                            } else {
                                viewModel.updateWisata(
                                    id = spotId,
                                    name = name,
                                    category = selectedCategory,
                                    address = address,
                                    description = description,
                                    ticketPrice = ticketPrice,
                                    openingHours = openingHours,
                                    rating = parsedRating,
                                    latitude = parsedLat,
                                    longitude = parsedLng,
                                    imageUrl = imageUrl
                                )
                            }
                        }
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp)
                        .testTag("submit_form_button"),
                    colors = ButtonDefaults.buttonColors(containerColor = PrimaryGreen),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Icon(
                        imageVector = if (spotId == null) Icons.Default.Save else Icons.Default.Check,
                        contentDescription = "Simpan",
                        tint = Color.White
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = if (spotId == null) "Daftarkan Destinasi" else "Simpan Perubahan Wisata",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                }

                Spacer(modifier = Modifier.height(48.dp))
            }
        }
    }
}
