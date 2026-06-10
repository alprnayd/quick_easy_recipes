import '../dao/category_dao.dart';
import '../models/category.dart';

class CategoryRepository {
  final CategoryDao categoryDao;

  CategoryRepository({
    CategoryDao? categoryDao,
  }) : categoryDao =
      categoryDao ?? CategoryDaoImpl();

  Future<List<Category>> getAllCategories() {
    return categoryDao.getAllCategories();
  }

  Future<Map<int, int>> getRecipeCounts() {
    return categoryDao.getRecipeCounts();
  }
}