class HomeService{
  final String name;
  final String imageUrl;

  HomeService({
    required this.name, 
    required this.imageUrl, 

  });


  factory HomeService.fromFirestore(Map<String,dynamic>data){
    return HomeService(
      name: data['name'] ?? '', 
      imageUrl: data['imageUrl'] ?? ''
      );
  }
}