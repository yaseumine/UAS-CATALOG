import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    // Kalau 'id' kosong, coba cari 'ID', kalau masih kosong kasih nilai 0
    id: json['id'] ?? json['ID'] ?? 0,

    // Ubah ke teks dengan aman, kalau kosong kasih nama default
    name: json['name']?.toString() ?? 'Produk Tanpa Nama',

    // Amankan angka desimal, mau Golang ngirim huruf atau angka tetep aman
    price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,

    // Kalau gambar kosong, kasih gambar abu-abu biar UI gak hancur
    imageUrl:
        json['image_url']?.toString() ?? 'https://via.placeholder.com/150',

    // Kalau kategori kosong, masukin ke Uncategorized
    category: json['category']?.toString() ?? 'Uncategorized',
  );

  @override
  List<Object?> get props => [id, name, price];
}
