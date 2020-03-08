local config = require("Main.SocialSpace.data.social_space_cfg")
local DECO_TYPE = {
  BACK_GROUND = 1,
  MEDAL = 2,
  PHOTO_FRAME = 3,
  WIDGET = 4
}
local g_DecorateCfgs
local Lplus = require("Lplus")
local ECSocialSpaceConfig = Lplus.Class("ECSocialSpaceConfig")
do
  local def = ECSocialSpaceConfig.define
  def.static("=>", "number").getOpenLevelLimit = function()
    return constant.CFriendsCircleConsts.friends_circle_open_role_level
  end
  def.static("=>", "number").getMaxPlayerDataCacheCount = function()
    return config.MaxPlayerDataCacheCount
  end
  def.static("=>", "number").getStatusOnePageShowCount = function()
    return config.StatusOnePageShowCount
  end
  def.static("=>", "number").getHeadlienOnePageShowCount = function()
    return config.HeadlienOnePageShowCount
  end
  def.static("=>", "number").getStatusMaxSaveCount = function()
    return config.StatusMaxSaveCount
  end
  def.static("=>", "number").getTopicStatusMaxSaveCount = function()
    return config.TopicStatusMaxSaveCount
  end
  def.static("=>", "number").getStatusMaxShowReplyCount = function()
    return config.StatusMaxShowReplyCount
  end
  def.static("=>", "number").getStatusMaxShowFavorCount = function()
    return config.StatusMaxShowFavorCount
  end
  def.static("=>", "number").getLeaveOnePageShowCount = function()
    return config.LeaveOnePageShowCount
  end
  def.static("=>", "number").getLeaveMsgMaxSaveCount = function()
    return config.LeaveMsgMaxSaveCount
  end
  def.static("=>", "number").getMaxPlaceBoxCount = function()
    return constant.CFriendsCircleConsts.place_treasure_box_max_num
  end
  def.static("=>", "number").getSpaceBoxPrice = function()
    return constant.CFriendsCircleConsts.treasure_box_gold_price
  end
  def.static("=>", "number").getSpaceBoxItemId = function()
    return config.SpaceBoxItemId
  end
  def.static("=>", "number").getBlacklistSizeLimit = function()
    return constant.CFriendsCircleConsts.max_black_role_num_limit or 1
  end
  def.static("=>", "table").getCoolDownCfg = function()
    return config.RequestCoolDownTime
  end
  def.static("=>", "number").getAddPopularLevelLimit = function()
    return ECSocialSpaceConfig.getOpenLevelLimit()
  end
  def.static("=>", "number").getAddFavorLevelLimit = function()
    return ECSocialSpaceConfig.getOpenLevelLimit()
  end
  def.static("=>", "number").getReplyLevelLimit = function()
    return constant.CFriendsCircleConsts.tread_open_role_level
  end
  def.static("=>", "number").getLeaveMsgLevelLimit = function()
    return constant.CFriendsCircleConsts.tread_open_role_level
  end
  def.static("=>", "number").getUploadPicLevelLimit = function()
    return config.UploadPicLevelLimit
  end
  def.static("=>", "number").getUploadVideoLevelLimit = function()
    return config.UploadVideoLevelLimit
  end
  def.static("=>", "number").getSendGiftLevelLimit = function()
    return constant.CFriendsCircleConsts.give_gift_open_role_level
  end
  def.static("=>", "number").getSignatureCharLimit = function()
    return constant.CFriendsCircleConsts.personallized_signature_max_length
  end
  def.static("=>", "number").getMsgCharLimit = function()
    return constant.CFriendsCircleConsts.release_dynamic_max_length
  end
  def.static("=>", "number").getReplyMsgCharLimit = function()
    return constant.CFriendsCircleConsts.comment_max_length
  end
  def.static("=>", "number").getLeaveMsgCharLimit = function()
    return constant.CFriendsCircleConsts.comment_max_length
  end
  def.static("=>", "number").getGiftLeaveMsgCharLimit = function()
    return constant.CFriendsCircleConsts.present_message_character_max_num
  end
  def.static("=>", "number").getNewMsgMaxSaveCount = function()
    return config.NewMsgMaxSaveCount
  end
  def.static("=>", "number").getGuestHistoryMaxSaveCount = function()
    return config.GuestHistoryMaxSaveCount
  end
  def.static("=>", "number").getGiftHistoryMaxSaveCount = function()
    return config.GiftHistoryMaxSaveCount
  end
  def.static("=>", "number").getEnterSpaceLevelLimit = function()
    return config.EnterSpaceLevelLimit
  end
  def.static("=>", "string").getSpaceTips = function()
    return config.Tips
  end
  def.static("=>", "number").getOpenActivityID = function()
    return config.ActivityID
  end
  def.static("=>", "string").getServerDomain = function()
    return config.ServerDomain
  end
  def.static("=>", "string").getDefaultServerDomain = function()
    return config.DefaultServerDomain
  end
  def.static("=>", "number").getSystemPhotoId = function()
    return config.SystemPhotoId
  end
  def.static("=>", "number").getHeadlineScoreRepuId = function()
    return config.HeadLineScore
  end
  def.static("=>", "number").getReportActId = function()
    return config.ReportActId
  end
  def.static("=>", "table").getHeadlienPicUrls = function()
    return config.headlienPicUrls
  end
  def.static("=>", "number").getReportCooldown = function()
    return config.ReportCooldown
  end
  def.static("=>", "number").getHotActId = function()
    return config.hot_act_id
  end
  def.static("=>", "number").getHeadlineActId = function()
    return config.headline_act_id
  end
  def.static("=>", "number").getTopicHotActId = function()
    return config.topic_hot_act_id
  end
end
ECSocialSpaceConfig.Commit()
return ECSocialSpaceConfig
