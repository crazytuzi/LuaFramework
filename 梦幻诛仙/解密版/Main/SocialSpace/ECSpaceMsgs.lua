local Lplus = require("Lplus")
local ACCESS_TYPE = {
  EVERYBODY = 0,
  ONLY_FRINEDS = 1,
  NOBODY = 2
}
local ECSpaceBaseInfo = Lplus.Class("ECSpaceMsgs.ECSpaceBaseInfo")
do
  local def = ECSpaceBaseInfo.define
  def.field("userdata").roleId = Zero_Int64_Init
  def.field("string").playerName = ""
  def.field("number").serverId = 0
  def.field("number").level = 0
  def.field("number").gender = 0
  def.field("number").prof = 0
  def.field("number").race = 0
  def.field("number").idphoto = 0
  def.field("number").avatarFrameId = 0
  def.field("string").urlphoto = ""
  def.field("number").factionId = 0
  def.field("string").factionName = ""
  def.field("string").signature = ""
  def.field("number").lastWeekPopular = 0
  def.field("number").thisWeekPopular = 0
  def.field("number").totalPopular = 0
  def.field("number").gainGiftCount = 0
  def.field("number").giftCount = 0
  def.field("number").status = 0
  def.field("table").location = nil
  def.field("number").background = 0
  def.field("table").medals = BLANK_TABLE_INIT
  def.field("number").photoFrame = 0
  def.field("number").widget = 0
  def.field("boolean").remindNews = false
  def.field("number").commentType = ACCESS_TYPE.EVERYBODY
  def.field("number").messageType = ACCESS_TYPE.EVERYBODY
end
ECSpaceBaseInfo.Commit()
local ECReplyMsg = Lplus.Class("ECSpaceMsgs.ECReplyMsg")
do
  local def = ECReplyMsg.define
  def.field("userdata").roleId = Zero_Int64_Init
  def.field("number").serverId = 0
  def.field("string").playerName = ""
  def.field("number").idphoto = 0
  def.field("number").avatarFrameId = 0
  def.field("string").urlphoto = ""
  def.field("userdata").replyRoleId = Zero_Int64_Init
  def.field("string").replyRoleName = ""
  def.field("userdata").replyId = Zero_Int64_Init
  def.field("userdata").msgID = Zero_Int64_Init
  def.field("string").strPlainMsg = ""
  def.field("string").strRichMsg = ""
  def.field("string").strData = ""
  def.field("number").timestamp = 0
  def.field("table").atPlayerList = BLANK_TABLE_INIT
  def.field("number").voteSize = 0
  def.field("boolean").hasVoted = false
  ECReplyMsg.Commit()
end
local HOT_STATUS = {
  NORMAL = 0,
  NOT_RESERVE = 1,
  RESERVE = 2,
  HOT = 3,
  DELETE_HOT = 4
}
local MSG_TYPE = {
  NORMAL = 0,
  HOT = 1,
  HEADLINE = 2,
  TOPIC_HOT = 3
}
local ECSpaceMsg = Lplus.Class("ECSpaceMsgs.ECSpaceMsg")
do
  local def = ECSpaceMsg.define
  def.field("number").serverId = 0
  def.field("userdata").roleId = Zero_Int64_Init
  def.field("string").playerName = ""
  def.field("number").idphoto = 0
  def.field("number").avatarFrameId = 0
  def.field("string").urlphoto = ""
  def.field("string").strPlainMsg = ""
  def.field("string").strRichMsg = ""
  def.field("table").atPlayerList = BLANK_TABLE_INIT
  def.field("string").strData = ""
  def.field("number").timestamp = 0
  def.field("number").voteSize = 0
  def.field("boolean").hasVoted = false
  def.field("table").favorList = BLANK_TABLE_INIT
  def.field("number").replySize = 0
  def.field("table").replyMsgList = BLANK_TABLE_INIT
  def.field("userdata").ID = Zero_Int64_Init
  def.field("number").msgIdClient = 0
  def.field("string").pic1 = ""
  def.field("string").pic2 = ""
  def.field("string").pic3 = ""
  def.field("string").pic4 = ""
  def.field("number").hotStatus = HOT_STATUS.NORMAL
  def.field("number").hotTime = 0
  def.field("number").topicid = 0
  def.field("table").pics = nil
end
ECSpaceMsg.Commit()
local NEW_MSG_TYPE = {
  NONE = 0,
  AT_STATUS = 1,
  AT_IN_REPLY = 2,
  AT_IN_LEAVE_MSG = 3,
  REPLIED_STATUS = 4,
  REPLIED_IN_REPLY = 5,
  GET_LEAVE_MSG = 6,
  REPLIED_IN_LEAVE_MSG = 7,
  ADDED_POPULAR = 8,
  GOTTEN_GIFT = 9,
  DELETED_STATUS = 10,
  DELETED_LEAVEMSG = 11,
  DELETED_REPLY = 12,
  DELETED_SIGNATURE = 13,
  DELETED_PORTRAIT = 14,
  FAVOR_ON_MSG = 15,
  CANCEL_FAVOR_ON_MSG = 16,
  HAS_NEW_HEADLINE = 101
}
local NEW_MSG_SOURCE_TYPE = {
  NONE = 0,
  TEXT = 1,
  PICTURE = 2
}
local ECNewMsg = Lplus.Class("ECSpaceMsgs.ECNewMsg")
do
  local def = ECNewMsg.define
  def.field("number").newMsgType = NEW_MSG_TYPE.NONE
  def.field("userdata").msgID = Zero_Int64_Init
  def.field("userdata").replyId = Zero_Int64_Init
  def.field("userdata").leaveMsgId = Zero_Int64_Init
  def.field("string").strPlainMsg = ""
  def.field("string").strRichMsg = ""
  def.field("string").strData = ""
  def.field("number").sourceType = NEW_MSG_SOURCE_TYPE.NONE
  def.field("string").sourceContent = ""
  def.field("string").sourceSupplement = ""
  def.field("userdata").roleId = Zero_Int64_Init
  def.field("string").playerName = ""
  def.field("number").idphoto = 0
  def.field("number").avatarFrameId = 0
  def.field("string").urlphoto = ""
  def.field("number").timestamp = 0
end
ECNewMsg.Commit()
local LEAVE_MSG_STATUS = {
  NORMAL = 0,
  SELF_VISIBLE = 1,
  ANONYMITY = 2,
  SELF_DELETE = 3,
  SYSTEM_DELETE = 4
}
local ECLeaveMsg = Lplus.Class("ECSpaceMsgs.ECLeaveMsg")
do
  local def = ECLeaveMsg.define
  def.field("userdata").roleId = Zero_Int64_Init
  def.field("number").serverId = 0
  def.field("string").playerName = ""
  def.field("userdata").targetMsgId = Zero_Int64_Init
  def.field("userdata").targetId = Zero_Int64_Init
  def.field("string").targetName = ""
  def.field("userdata").replyRoleId = Zero_Int64_Init
  def.field("string").replyRoleName = ""
  def.field("number").idphoto = 0
  def.field("number").avatarFrameId = 0
  def.field("string").urlphoto = ""
  def.field("string").strPlainMsg = ""
  def.field("string").strRichMsg = ""
  def.field("table").atPlayerList = BLANK_TABLE_INIT
  def.field("string").strData = ""
  def.field("number").timestamp = 0
  def.field("table").favorList = BLANK_TABLE_INIT
  def.field("userdata").ID = Zero_Int64_Init
  def.field("boolean").deleted = false
  def.field("number").status = LEAVE_MSG_STATUS.NORMAL
end
ECLeaveMsg.Commit()
local HistoryType = {ADD_POPULAR = 1, GET_GIFT = 2}
local ECSpaceHistory = Lplus.Class("ECSpaceMsgs.ECSpaceHistory")
do
  local def = ECSpaceHistory.define
  def.field("userdata").roleId = Zero_Int64_Init
  def.field("number").serverId = 0
  def.field("string").playerName = ""
  def.field("userdata").hostId = Zero_Int64_Init
  def.field("number").idphoto = 0
  def.field("number").avatarFrameId = 0
  def.field("string").urlphoto = ""
  def.field("number").level = 0
  def.field("number").timestamp = 0
  def.field("number").historyType = 0
end
ECSpaceHistory.Commit()
local ECFavorer = Lplus.Class("ECSpaceMsgs.ECFavorer")
do
  local def = ECFavorer.define
  def.field("number").serverId = 0
  def.field("userdata").id = Zero_Int64_Init
  def.field("string").name = ""
  def.field("number").idphoto = 0
  def.field("number").avatarFrameId = 0
  def.field("string").urlphoto = ""
end
ECFavorer.Commit()
local ECGetGiftHistory = Lplus.Class("ECSpaceMsgs.ECGetGiftHistory")
do
  local def = ECGetGiftHistory.define
  def.field("userdata").roleId = Zero_Int64_Init
  def.field("string").playerName = ""
  def.field("userdata").receiverId = Zero_Int64_Init
  def.field("string").receiverName = ""
  def.field("number").idphoto = 0
  def.field("number").avatarFrameId = 0
  def.field("string").urlphoto = ""
  def.field("number").level = 0
  def.field("number").timestamp = 0
  def.field("number").giftId = 0
  def.field("number").giftCount = 0
  def.field("string").content = ""
end
ECGetGiftHistory.Commit()
local BlacklistStatus = {ACTIVE = 1, PASSIVE = 2}
local ECBlacklistRoleInfo = Lplus.Class("ECSpaceMsgs.ECBlacklistRoleInfo")
do
  local def = ECBlacklistRoleInfo.define
  def.field("userdata").roleId = Zero_Int64_Init
  def.field("string").name = ""
  def.field("number").idphoto = 0
  def.field("number").avatarFrameId = 0
  def.field("string").urlphoto = ""
  def.field("number").lastUpdateTime = 0
  def.field("number").status = 0
end
ECBlacklistRoleInfo.Commit()
local FocusStatus = {ACTIVE = 4, PASSIVE = 8}
local ECFocusRoleInfo = Lplus.Class("ECSpaceMsgs.ECFocusRoleInfo")
do
  local def = ECFocusRoleInfo.define
  def.field("userdata").roleId = Zero_Int64_Init
  def.field("number").createTime = 0
  def.field("number").lastUpdateTime = 0
  def.field("number").status = 0
  def.method("number").AddStatus = function(self, status)
    self.status = bit.bor(self.status, status)
  end
  def.method("number").RemoveStatus = function(self, status)
    self.status = bit.bxor(self.status, status)
  end
  def.method("number", "=>", "boolean").HasStatus = function(self, status)
    return bit.band(self.status, status) ~= 0
  end
  def.method("=>", "boolean").HasAnyStatus = function(self)
    for k, v in pairs(FocusStatus) do
      if self:HasStatus(v) then
        return true
      end
    end
    return false
  end
end
ECFocusRoleInfo.Commit()
local ECRoleProfile = Lplus.Class("ECSpaceMsgs.ECRoleProfile")
do
  local def = ECRoleProfile.define
  def.field("userdata").roleId = Zero_Int64_Init
  def.field("string").name = ""
  def.field("number").level = 0
  def.field("number").prof = 0
  def.field("number").gender = 0
  def.field("number").avatarId = 0
  def.field("number").avatarFrameId = 0
end
ECRoleProfile.Commit()
local ParsePhoto = function(idphoto)
  local json = require("Utility.json")
  local avatarId = 0
  local avatarFrameId = 0
  local url = ""
  local function parseAvatarJsonStr(str)
    local isSuccess, avatar = pcall(json.decode, str)
    if isSuccess and type(avatar) == "table" then
      return avatar.avatar or 0, avatar.avatarFrameId or 0
    else
      Debug.LogError(string.format("idphoto(\"%s\") invalid, a valid json string is expected.", str))
      return tonumber(str), 0
    end
  end
  if idphoto and #idphoto > 0 then
    local idx = string.find(idphoto, "|", 1)
    if idx then
      local strid = string.sub(idphoto, 1, idx - 1)
      avatarId, avatarFrameId = parseAvatarJsonStr(strid)
      url = string.sub(idphoto, idx + 1, -1)
    else
      avatarId, avatarFrameId = parseAvatarJsonStr(idphoto)
    end
  end
  return avatarId, avatarFrameId, url
end
return {
  ECSpaceBaseInfo = ECSpaceBaseInfo,
  ECSpaceMsg = ECSpaceMsg,
  ECReplyMsg = ECReplyMsg,
  ECLeaveMsg = ECLeaveMsg,
  ECNewMsg = ECNewMsg,
  ECSpaceHistory = ECSpaceHistory,
  ECGetGiftHistory = ECGetGiftHistory,
  NEW_MSG_TYPE = NEW_MSG_TYPE,
  NEW_MSG_SOURCE_TYPE = NEW_MSG_SOURCE_TYPE,
  ParsePhoto = ParsePhoto,
  HOT_STATUS = HOT_STATUS,
  MSG_TYPE = MSG_TYPE,
  ECFavorer = ECFavorer,
  LEAVE_MSG_STATUS = LEAVE_MSG_STATUS,
  ACCESS_TYPE = ACCESS_TYPE,
  HistoryType = HistoryType,
  ECBlacklistRoleInfo = ECBlacklistRoleInfo,
  BlacklistStatus = BlacklistStatus,
  ECFocusRoleInfo = ECFocusRoleInfo,
  FocusStatus = FocusStatus,
  ECRoleProfile = ECRoleProfile
}
