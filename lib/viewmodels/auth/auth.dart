import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockmateapp/models/user_model.dart';
import 'package:stockmateapp/repositories/auth_repository.dart';
import 'package:stockmateapp/utils/exceptions/database_error_mapper.dart';
import 'package:stockmateapp/utils/forms/forms.dart';
import 'package:stockmateapp/utils/helpers/session_service.dart';

part 'auth_viewmodel.dart';
part 'auth_state.dart';
