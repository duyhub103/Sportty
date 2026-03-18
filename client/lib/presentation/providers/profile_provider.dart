import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  ProfileProvider(this._profileRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Trạng thái lưu tạm trong lúc điền form
  String? avatarPath;
  double? latitude;
  double? longitude;

  // --- LOGIC LẤY ẢNH ---
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      avatarPath = image.path;
      notifyListeners();
    }
  }

  // --- LOGIC LẤY TỌA ĐỘ GPS ---
  Future<bool> getCurrentLocation() async {
    _setLoading(true);
    try {
      // Kiểm tra quyền
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Quyền vị trí bị từ chối');
        }
      }

      // Lấy tọa độ
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      latitude = position.latitude;
      longitude = position.longitude;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // --- LOGIC GỌI API UPDATE ---
  Future<bool> submitProfileSetup({
    required String displayName,
    required String bio,
    required String sport,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      UserModel updatedUser = await _profileRepository.updateProfile(
        displayName: displayName,
        bio: bio,
        sport: sport,
        lat: latitude,
        lng: longitude,
        avatarPath: avatarPath,
      );
      
      // Thành công
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}