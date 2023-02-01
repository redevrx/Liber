import 'package:get_it/get_it.dart';
import 'package:liber/core/api/base_api.dart';
import 'package:liber/core/api/endpoint/auth_endpoint/auth_endpoint.dart';
import 'package:liber/data/models/friend/friend_request.dart';
import 'package:liber/data/models/friend/request_friend_response.dart';
import 'package:liber/data/models/wrapper_result.dart';

abstract class IFriendService {
  void checkIsFriend();
  Future<WrapperValue<RFriendResponse?>> requestFriend(FriendRequest request);
  Future<WrapperValue<FriendRequest?>> accept(String friendId);
  void block();
  void friendList();
  void friend();
}

class FriendService extends IFriendService {
  final _client = GetIt.instance.get<BaseAPI>();

  @override
  Future<WrapperValue<FriendRequest?>> accept(String friendId) async {
    final raw = await _client.post(path: "$friendAccept$friendId", request: null);
    return raw.copy(
        raw.isSuccess() ? FriendRequest.fromJson(raw.value) : FriendRequest());
  }

  @override
  void block() {
    // TODO: implement block
  }

  @override
  void checkIsFriend() {
    // TODO: implement checkIsFriend
  }

  @override
  void friend() {
    // TODO: implement friend
  }

  @override
  void friendList() {
    // TODO: implement friendList
  }

  @override
  Future<WrapperValue<RFriendResponse?>> requestFriend(
      FriendRequest request) async {
    final raw = await _client.post(path: friendRequest, request: request.toJson());
    return raw.copy(raw.isSuccess()
        ? RFriendResponse.fromJson(raw.value)
        : RFriendResponse());
  }
}
