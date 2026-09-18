/// Network infrastructure for Blessing Share.
///
/// Provides Dio client factory, Retrofit APIs, DTOs, and network failures.
/// Domain entities live in the app; map DTOs at the data adapter boundary.
library blessing_network;

export 'package:dio/dio.dart'
    show
        CancelToken,
        Dio,
        DioException,
        DioExceptionType,
        Headers,
        HttpClientAdapter,
        Interceptor,
        LogInterceptor,
        RequestOptions,
        Response,
        ResponseBody,
        ResponseInterceptorHandler,
        ResponseType;

export 'src/api/blessing_api.dart';
export 'src/client/network_client.dart';
export 'src/dto/blessing_category_dto.dart';
export 'src/dto/blessing_item_dto.dart';
export 'src/dto/category_filter_dto.dart';
export 'src/dto/grid_theme_dto.dart';
export 'src/error/network_exceptions.dart';
export 'src/response/api_envelope.dart';
