import 'package:revolt_bullseye/models.dart';
import 'package:revolt_bullseye/src/models/attachment.dart';
import 'package:revolt_bullseye/src/models/ulid.dart';
import 'package:revolt_bullseye/src/utils/enum.dart';

/// Message model
class Message {
  /// Message ID
  final Ulid id;

  /// Nonce value used to prevent double requests to create objects
  final String? nonce;

  /// Channel ID
  final Ulid channel;

  /// Author ID
  final Ulid author;

  /// Message content
  /// Can be a [String] or a subtype of [SystemContent] (if sent by the system user)
  final dynamic content;

  // System Message Indicator
  final System? system;

  /// Message attachments
  final List<Attachment>? attachments;

  /// Unix timestamp of when message was last edited
  final DateTime? edited;

  /// Message embeds
  final List<Embed>? embeds;

  /// Array of user IDs mentioned in message
  final List<Ulid>? mentions;

  /// Array of message IDs replied to
  final List<String>? replies;

  /// Masquerade displayed for a message, replaces user's name and avatar
  final Masquerade? masquerade;

  Message({
    required this.id,
    this.nonce,
    required this.channel,
    required this.author,
    required this.content,
    this.system,
    this.attachments,
    this.edited,
    this.embeds,
    this.mentions,
    this.replies,
    this.masquerade,
  });

  Message.fromJson(Map<String, dynamic> json)
      : id = Ulid(json['_id']),
        nonce = json['nonce'],
        channel = Ulid(json['channel']),
        author = Ulid(json['author']),
        content = json['content'] is String
            ? json['content']
            : SystemContent.define(json['content']),
        system = json['system'] == null
            ? null
            : System.fromJson(json['system']),
        attachments = json['attachments'] == null
            ? null
            : [for (final e in json['attachments']) Attachment.fromJson(e)],
        edited = json['edited'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(json['edited']['\$date']),
        embeds = json['embeds'] == null
            ? null
            : [for (final e in json['embeds']) Embed.define(e)],
        mentions = json['mentions'] == null
            ? null
            : [for (final e in json['mentions']) Ulid(e)],
        replies = json['replies'] == null
            ? null
            : [for (final e in json['replies']) e],
        masquerade = json['masquerade'] == null
            ? null
            : Masquerade.fromJson(json['masquerade']);
}

class Messages {
  /// Messages
  final List<Message> messages;

  /// Users
  final List<User>? users;

  /// Members
  final List<Member>? members;

  Messages({
    required this.messages,
    this.users,
    this.members
  });

  Messages.fromJson(Map<String, dynamic> json)
      : messages = json['messages'],
      users = json['users'] == null
        ? null
        : [for (final e in json['users']) e],
      members = json['members'] == null
        ? null
        : [for (final e in json['members']) e];
}

class EmbedType extends Enum<String> {
  static const website = EmbedType._create('Website');
  static const image = EmbedType._create('Image');
  static const text = EmbedType._create('Text');
  static const none = EmbedType._create('None');

  const EmbedType._create(String value) : super(value);
  EmbedType.from(String value) : super(value);
}

abstract class Embed {
  final EmbedType type;

  Embed({required this.type});

  Embed.fromJson(Map<String, dynamic> json)
      : type = EmbedType.from(json['type']);

  factory Embed.define(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'Website':
        return WebsiteEmbed.fromJson(json);
      case 'Image':
        return ImageEmbed.fromJson(json);
      case 'Text':
        return TextEmbed.fromJson(json);
      case 'None':
        return NoneEmbed.fromJson(json);
      default:
        return UnknownEmbed.fromJson(json);
    }
  }
}

class UnknownEmbed extends Embed {
  UnknownEmbed({required EmbedType type}) : super(type: type);
  UnknownEmbed.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}

class EmbedSpecialType extends Enum<String> {
  static const none = EmbedSpecialType._create('None');
  static const youtube = EmbedSpecialType._create('YouTube');
  static const twitch = EmbedSpecialType._create('Twitch');
  static const spotify = EmbedSpecialType._create('Spotify');
  static const soundcloud = EmbedSpecialType._create('Soundcloud');
  static const bandcamp = EmbedSpecialType._create('Bandcamp');

  EmbedSpecialType.from(String value) : super(value);
  const EmbedSpecialType._create(String value) : super(value);
}

abstract class WebsiteEmbedSpecial {
  final EmbedSpecialType type;

  WebsiteEmbedSpecial({required this.type});

  WebsiteEmbedSpecial.fromJson(Map<String, dynamic> json)
      : type = EmbedSpecialType.from(json['type']);

  factory WebsiteEmbedSpecial.define(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'None':
        return NoneEmbedSpecial.fromJson(json);
      case 'YouTube':
        return YoutubeEmbedSpecial.fromJson(json);
      case 'Twitch':
        return TwitchEmbedSpecial.fromJson(json);
      case 'Spotify':
        return SpotifyEmbedSpecial.fromJson(json);
      case 'Soundcloud':
        return SoundcloudEmbedSpecial.fromJson(json);
      case 'Bandcamp':
        return BandcampEmbedSpecial.fromJson(json);
      default:
        return UndefinedEmbedSpecial.fromJson(json);
    }
  }
}

class UndefinedEmbedSpecial extends WebsiteEmbedSpecial {
  UndefinedEmbedSpecial({required EmbedSpecialType type}) : super(type: type);
  UndefinedEmbedSpecial.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);
}

class NoneEmbedSpecial extends WebsiteEmbedSpecial {
  NoneEmbedSpecial({required EmbedSpecialType type}) : super(type: type);
  NoneEmbedSpecial.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}

class YoutubeEmbedSpecial extends WebsiteEmbedSpecial {
  final String id;
  final DateTime? timestamp;

  YoutubeEmbedSpecial({
    required EmbedSpecialType type,
    required this.id,
    this.timestamp,
  }) : super(type: type);

  YoutubeEmbedSpecial.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        timestamp = json['timestamp'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
        super.fromJson(json);
}

class TwitchContentType extends Enum<String> {
  static const channel = TwitchContentType._create('Channel');
  static const clip = TwitchContentType._create('Clip');
  static const video = TwitchContentType._create('Video');

  TwitchContentType.from(String value) : super(value);
  const TwitchContentType._create(String value) : super(value);
}

class TwitchEmbedSpecial extends WebsiteEmbedSpecial {
  final TwitchContentType contentType;
  final String id;

  TwitchEmbedSpecial({
    required EmbedSpecialType type,
    required this.contentType,
    required this.id,
  }) : super(type: type);

  TwitchEmbedSpecial.fromJson(Map<String, dynamic> json)
      : contentType = TwitchContentType.from(json['content_type']),
        id = json['type'],
        super.fromJson(json);
}

class SpotifyEmbedSpecial extends WebsiteEmbedSpecial {
  final String contentType;
  final String id;

  SpotifyEmbedSpecial({
    required EmbedSpecialType type,
    required this.contentType,
    required this.id,
  }) : super(type: type);

  SpotifyEmbedSpecial.fromJson(Map<String, dynamic> json)
      : contentType = json['content_type'],
        id = json['id'],
        super.fromJson(json);
}

class SoundcloudEmbedSpecial extends WebsiteEmbedSpecial {
  SoundcloudEmbedSpecial({required EmbedSpecialType type}) : super(type: type);
  SoundcloudEmbedSpecial.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);
}

class BandcampContentType extends Enum<String> {
  static const album = BandcampContentType._create('Album');
  static const track = BandcampContentType._create('Track');

  BandcampContentType.from(String value) : super(value);
  const BandcampContentType._create(String value) : super(value);
}

class BandcampEmbedSpecial extends WebsiteEmbedSpecial {
  final BandcampContentType contentType;
  final String id;

  BandcampEmbedSpecial({
    required EmbedSpecialType type,
    required this.contentType,
    required this.id,
  }) : super(type: type);

  BandcampEmbedSpecial.fromJson(Map<String, dynamic> json)
      : contentType = json['content_type'],
        id = json['id'],
        super.fromJson(json);
}

class EmbeddedImage {
  final Uri url;
  final int width;
  final int height;
  final ImageSize size;

  EmbeddedImage({
    required this.url,
    required this.width,
    required this.height,
    required this.size,
  });

  EmbeddedImage.fromJson(Map<String, dynamic> json)
      : url = Uri.parse(json['url']),
        width = json['width'],
        height = json['height'],
        size = ImageSize.from(json['size']);
}

class EmbeddedVideo {
  final Uri url;
  final int width;
  final int height;

  EmbeddedVideo({required this.url, required this.width, required this.height});

  EmbeddedVideo.fromJson(Map<String, dynamic> json)
      : url = Uri.parse(json['url']),
        width = json['width'],
        height = json['height'];
}

class WebsiteEmbed extends Embed {
  /// Website URL
  final Uri? url;

  /// A special 3rd party embed
  final WebsiteEmbedSpecial? special;

  /// Embed title
  final String? title;

  /// Embed description
  final String? description;

  /// Embedded image
  final EmbeddedImage? image;

  /// Embedded viedo
  final EmbeddedVideo? video;

  /// Website name
  final String? siteName;

  /// Website icon URL
  final Uri? iconUrl;

  /// Valid HTML colour
  final String? colour;

  WebsiteEmbed({
    required EmbedType type,
    required this.url,
    required this.special,
    required this.title,
    required this.description,
    required this.image,
    required this.video,
    required this.siteName,
    required this.iconUrl,
    required this.colour,
  }) : super(type: type);

  WebsiteEmbed.fromJson(Map<String, dynamic> json)
      : url = json['url'] == null ? null : Uri.parse(json['url']),
        special = json['special'] == null
            ? null
            : WebsiteEmbedSpecial.define(json['special']),
        title = json['title'],
        description = json['description'],
        image = json['image'] == null
            ? null
            : EmbeddedImage.fromJson(json['image']),
        video = json['video'] == null
            ? null
            : EmbeddedVideo.fromJson(json['video']),
        siteName = json['siteName'],
        iconUrl = json['icon_url'] == null ? null : Uri.parse(json['icon_url']),
        colour = json['colour'],
        super.fromJson(json);
}

class ImageSize extends Enum<String> {
  static const large = ImageSize._create('Large');
  static const preview = ImageSize._create('Preview');

  ImageSize.from(String value) : super(value);
  const ImageSize._create(String value) : super(value);
}

class ImageEmbed extends Embed {
  final Uri url;
  final int width;
  final int height;
  final ImageSize size;

  ImageEmbed({
    required EmbedType type,
    required this.url,
    required this.width,
    required this.height,
    required this.size,
  }) : super(type: type);

  ImageEmbed.fromJson(Map<String, dynamic> json)
      : url = Uri.parse(json['url']),
        width = json['width'],
        height = json['height'],
        size = ImageSize.from(json['size']),
        super.fromJson(json);
}

class TextEmbed extends Embed {
  final Uri? iconUrl;
  final Uri? url;
  final String? title;
  final String? description;
  final Attachment? media;
  final String? colour;

  TextEmbed({
    required EmbedType type,
    this.iconUrl,
    this.url,
    this.title,
    this.description,
    this.media,
    this.colour,
  }) : super(type: type);

  TextEmbed.fromJson(Map<String, dynamic> json)
      : iconUrl = json['icon_url'] == null ? null : Uri.parse(json['icon_url']),
        url = json['url'] == null ? null : Uri.parse(json['url']),
        title = json['title'],
        description = json['description'],
        media =
            json['media'] == null ? null : Attachment.fromJson(json['media']),
        colour = json['colour'],
        super.fromJson(json);
}

class NoneEmbed extends Embed {
  NoneEmbed({required EmbedType type}) : super(type: type);
  NoneEmbed.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}

class UndefinedEmbed extends Embed {
  UndefinedEmbed({required EmbedType type}) : super(type: type);
  UndefinedEmbed.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}

class System {
  final String? type;
  final String? content;

  System({required this.type, required this.content});

  System.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        content = json['content'];
}

class SystemContentType extends Enum<String> {
  static const text = SystemContentType._create('text');
  static const userAdded = SystemContentType._create('user_added');
  static const userRemove = SystemContentType._create('user_remove');
  static const userJoined = SystemContentType._create('user_joined');
  static const userLeft = SystemContentType._create('user_left');
  static const userKicked = SystemContentType._create('user_kicked');
  static const userBanned = SystemContentType._create('user_banned');
  static const channedRenamed = SystemContentType._create('channel_renamed');
  static const channelDescriptionChanged =
      SystemContentType._create('channel_description_changed');
  static const channelIconChanged =
      SystemContentType._create('channel_icon_changed');

  const SystemContentType._create(String value) : super(value);
  SystemContentType.from(String value) : super(value);
}

abstract class SystemContent {
  final SystemContentType type;

  SystemContent({required this.type});

  SystemContent.fromJson(Map<String, dynamic> json)
      : type = SystemContentType.from(json['type']);

  factory SystemContent.define(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'text':
        return TextContent.fromJson(json);
      case 'user_added':
        return UserAddedContent.fromJson(json);
      case 'user_remove':
        return UserRemoveContent.fromJson(json);
      case 'user_joined':
        return UserJoinedContent.fromJson(json);
      case 'user_left':
        return UserLeftContent.fromJson(json);
      case 'user_kicked':
        return UserKickedContent.fromJson(json);
      case 'user_banned':
        return UserBannedContent.fromJson(json);
      case 'channel_renamed':
        return ChannelRenamedContent.fromJson(json);
      case 'channel_description_changed':
        return ChannelDescriptionChangedContent.fromJson(json);
      case 'channel_icon_changed':
        return ChannelIconChangedContent.fromJson(json);
      default:
        return UnknownContent.fromJson(json);
    }
  }
}

class UnknownContent extends SystemContent {
  UnknownContent({required SystemContentType type}) : super(type: type);
  UnknownContent.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}

class TextContent extends SystemContent {
  final String content;

  TextContent({
    required SystemContentType type,
    required this.content,
  }) : super(type: type);

  TextContent.fromJson(Map<String, dynamic> json)
      : content = json['content'],
        super.fromJson(json);
}

class UserAddedContent extends SystemContent {
  final Ulid id;
  final Ulid by;

  UserAddedContent({
    required SystemContentType type,
    required this.id,
    required this.by,
  }) : super(type: type);

  UserAddedContent.fromJson(Map<String, dynamic> json)
      : id = Ulid(json['id']),
        by = Ulid(json['by']),
        super.fromJson(json);
}

class UserRemoveContent extends SystemContent {
  final Ulid id;
  final Ulid by;

  UserRemoveContent({
    required SystemContentType type,
    required this.id,
    required this.by,
  }) : super(type: type);

  UserRemoveContent.fromJson(Map<String, dynamic> json)
      : id = Ulid(json['id']),
        by = Ulid(json['by']),
        super.fromJson(json);
}

class UserJoinedContent extends SystemContent {
  final Ulid id;

  UserJoinedContent({
    required SystemContentType type,
    required this.id,
  }) : super(type: type);

  UserJoinedContent.fromJson(Map<String, dynamic> json)
      : id = Ulid(json['id']),
        super.fromJson(json);
}

class UserLeftContent extends SystemContent {
  final Ulid id;

  UserLeftContent({
    required SystemContentType type,
    required this.id,
  }) : super(type: type);

  UserLeftContent.fromJson(Map<String, dynamic> json)
      : id = Ulid(json['id']),
        super.fromJson(json);
}

class UserKickedContent extends SystemContent {
  final Ulid id;

  UserKickedContent({
    required SystemContentType type,
    required this.id,
  }) : super(type: type);

  UserKickedContent.fromJson(Map<String, dynamic> json)
      : id = Ulid(json['id']),
        super.fromJson(json);
}

class UserBannedContent extends SystemContent {
  final Ulid id;

  UserBannedContent({
    required SystemContentType type,
    required this.id,
  }) : super(type: type);

  UserBannedContent.fromJson(Map<String, dynamic> json)
      : id = Ulid(json['id']),
        super.fromJson(json);
}

class ChannelRenamedContent extends SystemContent {
  final String name;
  final Ulid by;

  ChannelRenamedContent({
    required SystemContentType type,
    required this.name,
    required this.by,
  }) : super(type: type);

  ChannelRenamedContent.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        by = Ulid(json['by']),
        super.fromJson(json);
}

class ChannelDescriptionChangedContent extends SystemContent {
  final Ulid by;

  ChannelDescriptionChangedContent({
    required SystemContentType type,
    required this.by,
  }) : super(type: type);

  ChannelDescriptionChangedContent.fromJson(Map<String, dynamic> json)
      : by = Ulid(json['by']),
        super.fromJson(json);
}

class ChannelIconChangedContent extends SystemContent {
  final Ulid by;

  ChannelIconChangedContent({
    required SystemContentType type,
    required this.by,
  }) : super(type: type);

  ChannelIconChangedContent.fromJson(Map<String, dynamic> json)
      : by = Ulid(json['by']),
        super.fromJson(json);
}

class Masquerade {
  final String? nickname;
  final String? avatar;

  Masquerade({required this.nickname, required this.avatar});

  Masquerade.fromJson(Map<String, dynamic> json)
      : nickname = json['nickname'],
        avatar = json['avatar'];
}
