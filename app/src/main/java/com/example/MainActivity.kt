package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.example.ui.screens.*
import com.example.ui.theme.JemberGuideTheme
import com.example.ui.viewmodel.JemberViewModel
import com.example.ui.viewmodel.ViewModelFactory

class MainActivity : ComponentActivity() {

    // Retrieve JemberViewModel with Repository initialized at Application
    private val viewModel: JemberViewModel by viewModels {
        ViewModelFactory((application as JemberGuideApplication).repository)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            JemberGuideTheme {
                val navController = rememberNavController()

                NavHost(
                    navController = navController,
                    startDestination = "splash"
                ) {
                    // 1. Splash Screen
                    composable("splash") {
                        SplashScreen(
                            onNavigateToLogin = {
                                navController.navigate("login") {
                                    popUpTo("splash") { inclusive = true }
                                }
                            }
                        )
                    }

                    // 2. Login Screen
                    composable("login") {
                        LoginScreen(
                            viewModel = viewModel,
                            onNavigateToRegister = {
                                navController.navigate("register")
                            },
                            onLoginSuccess = {
                                navController.navigate("home") {
                                    popUpTo("login") { inclusive = true }
                                }
                            }
                        )
                    }

                    // 3. Register/SignUp Screen
                    composable("register") {
                        RegisterScreen(
                            viewModel = viewModel,
                            onNavigateToLogin = {
                                navController.navigate("login") {
                                    popUpTo("register") { inclusive = true }
                                }
                            }
                        )
                    }

                    // 4. Home Screen (Dashboard, Lists, Search, Category Chips)
                    composable("home") {
                        HomeScreen(
                            viewModel = viewModel,
                            onNavigateToDetail = { spotId ->
                                navController.navigate("detail/$spotId")
                            },
                            onNavigateToAddWisata = {
                                navController.navigate("add_wisata")
                            },
                            onNavigateToEditProfil = {
                                navController.navigate("edit_profil")
                            },
                            onNavigateToLogout = {
                                navController.navigate("login") {
                                    popUpTo("home") { inclusive = true }
                                }
                            }
                        )
                    }

                    // 5. Tourism Detail Screen (Includes routing maps)
                    composable(
                        route = "detail/{id}",
                        arguments = listOf(navArgument("id") { type = NavType.IntType })
                    ) { backStackEntry ->
                        val id = backStackEntry.arguments?.getInt("id") ?: 0
                        DetailScreen(
                            spotId = id,
                            viewModel = viewModel,
                            onNavigateToEditSpot = { spotId ->
                                navController.navigate("edit_wisata/$spotId")
                            },
                            onNavigateBack = {
                                navController.popBackStack()
                            }
                        )
                    }

                    // 6. Add Wisata Form Screen
                    composable("add_wisata") {
                        AddEditWisataScreen(
                            spotId = null,
                            viewModel = viewModel,
                            onNavigateBack = {
                                navController.popBackStack()
                            }
                        )
                    }

                    // 7. Edit Wisata Form Screen
                    composable(
                        route = "edit_wisata/{id}",
                        arguments = listOf(navArgument("id") { type = NavType.IntType })
                    ) { backStackEntry ->
                        val id = backStackEntry.arguments?.getInt("id") ?: 0
                        AddEditWisataScreen(
                            spotId = id,
                            viewModel = viewModel,
                            onNavigateBack = {
                                navController.popBackStack()
                            }
                        )
                    }

                    // 8. Edit Profile Screen
                    composable("edit_profil") {
                        EditProfileScreen(
                            viewModel = viewModel,
                            onNavigateBack = {
                                navController.popBackStack()
                            }
                        )
                    }
                }
            }
        }
    }
}
