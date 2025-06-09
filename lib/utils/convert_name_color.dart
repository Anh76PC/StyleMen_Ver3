String convertColorToVietnamese(String color) {
  switch (color.toLowerCase()) {
    case 'red':
      return 'Đỏ';
    case 'blue':
      return 'Xanh dương';
    case 'green':
      return 'Xanh lá';
    case 'yellow':
      return 'Vàng';
    case 'black':
      return 'Đen';
    case 'white':
      return 'Trắng';
    case 'gray':
    case 'grey':
      return 'Xám';
    case 'pink':
      return 'Hồng';
    case 'purple':
      return 'Tím';
    case 'brown':
      return 'Nâu';
    case 'orange':
      return 'Cam';
    case 'beige':
      return 'Be';
    case 'navy':
      return 'Xanh navy';
    case 'cyan':
      return 'Xanh ngọc';
    default:
      return color; // Trả nguyên nếu không khớp
  }
}
