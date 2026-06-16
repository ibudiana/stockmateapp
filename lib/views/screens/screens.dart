import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:stockmateapp/models/product_model.dart';
import 'package:stockmateapp/models/stock_transaction_model.dart';
import 'package:stockmateapp/models/transaction_detail_model.dart';
import 'package:stockmateapp/viewmodels/auth/auth.dart';
import 'package:stockmateapp/utils/theme/app_colors.dart';
import 'package:stockmateapp/utils/theme/app_typography.dart';
import 'package:stockmateapp/utils/theme/app_dimensions.dart';
import 'package:stockmateapp/viewmodels/product_viewmodel.dart';
import 'package:stockmateapp/viewmodels/report_viewmodel.dart';
import 'package:stockmateapp/views/widgets/widgets.dart';

part 'auth/register_screen.dart';
part 'auth/login_screen.dart';
part 'auth/reset_password_screen.dart';
part 'product/product_list_screen.dart';
part 'product/stock_adjustment_dialog.dart';
part 'product/product_form_screen.dart';
part 'report/report_screen.dart';
