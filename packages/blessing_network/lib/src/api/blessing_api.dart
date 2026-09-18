import 'package:dio/dio.dart';
import 'package:blessing_network/src/dto/blessing_category_dto.dart';
import 'package:blessing_network/src/dto/blessing_item_dto.dart';
import 'package:blessing_network/src/dto/grid_theme_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'blessing_api.g.dart';

@RestApi()
abstract class BlessingApi {
  factory BlessingApi(Dio dio, {String baseUrl}) = _BlessingApi;

  @GET('/categories')
  Future<List<BlessingCategoryDto>> getCategories();

  @GET('/featured')
  Future<List<BlessingItemDto>> getFeatured();

  @GET('/categories/{id}/items')
  Future<List<BlessingItemDto>> getByCategory(@Path('id') String categoryId);

  @GET('/items/{id}')
  Future<BlessingItemDto> getById(@Path('id') String id);

  @GET('/grid-themes')
  Future<List<GridThemeDto>> getGridThemes();
}
