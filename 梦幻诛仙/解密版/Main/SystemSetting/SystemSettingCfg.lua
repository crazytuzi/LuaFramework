local SystemSettingCfg = {}
SystemSettingCfg.CUR_SETTING_VERSION = 0.952
local SettingDataType = {
  Toggle = 1,
  Sound = 2,
  Choice = 3,
  Num = 4
}
local SystemSetting = {
  RefuseFriendApplies = 1,
  MakeFriendVarify = 2,
  FlyingTrace = 3,
  LowRoleNumbers = 4,
  LowFXNumbers = 5,
  BGMusic = 6,
  EffectSound = 7,
  VoiceSound = 8,
  HideOtherPlayers = 9,
  DrakScreen = 10,
  HighFPS = 11,
  CirculateZhenYaoNotice = 12,
  FPS_HIGH = 14,
  FPS_MEDIUM = 15,
  FPS_LOW = 16,
  NO_SKILL_VOICE = 17,
  NOT_SHARE_EQUIP_INFO = 18,
  ANCHOR_SPEAKER = 19,
  ANCHOR = 20,
  ChatWithFriendShrinkUI = 21,
  AUTO_JOIN_TEAM_VOICE = 22,
  ADD_FRIEND_LV = 23,
  BLOCK_STRANGER_INVITE = 24,
  ADD_FRIEND_LV_NUMBER = 25,
  CloseTouchListPanel = 26
}
local SystemSettingDefaults = {
  [SystemSetting.RefuseFriendApplies] = {
    SettingDataType.Toggle,
    false
  },
  [SystemSetting.MakeFriendVarify] = {
    SettingDataType.Toggle,
    false
  },
  [SystemSetting.FlyingTrace] = {
    SettingDataType.Toggle,
    true
  },
  [SystemSetting.LowRoleNumbers] = {
    SettingDataType.Toggle,
    true
  },
  [SystemSetting.LowFXNumbers] = {
    SettingDataType.Toggle,
    false
  },
  [SystemSetting.BGMusic] = {
    SettingDataType.Sound,
    1,
    false
  },
  [SystemSetting.EffectSound] = {
    SettingDataType.Sound,
    1,
    false
  },
  [SystemSetting.VoiceSound] = {
    SettingDataType.Sound,
    1,
    false
  },
  [SystemSetting.HideOtherPlayers] = {
    SettingDataType.Toggle,
    false
  },
  [SystemSetting.DrakScreen] = {
    SettingDataType.Toggle,
    true
  },
  [SystemSetting.HighFPS] = {
    SettingDataType.Toggle,
    false
  },
  [SystemSetting.CirculateZhenYaoNotice] = {
    SettingDataType.Toggle,
    true
  },
  [SystemSetting.FPS_HIGH] = {
    SettingDataType.Toggle,
    false
  },
  [SystemSetting.FPS_MEDIUM] = {
    SettingDataType.Toggle,
    true
  },
  [SystemSetting.FPS_LOW] = {
    SettingDataType.Toggle,
    false
  },
  [SystemSetting.NO_SKILL_VOICE] = {
    SettingDataType.Toggle,
    false
  },
  [SystemSetting.NOT_SHARE_EQUIP_INFO] = {
    SettingDataType.Toggle,
    false
  },
  [SystemSetting.ANCHOR_SPEAKER] = {
    SettingDataType.Sound,
    1,
    false
  },
  [SystemSetting.ANCHOR] = {
    SettingDataType.Toggle,
    true
  },
  [SystemSetting.AUTO_JOIN_TEAM_VOICE] = {
    SettingDataType.Toggle,
    true
  },
  [SystemSetting.ChatWithFriendShrinkUI] = {
    SettingDataType.Toggle,
    false
  },
  [SystemSetting.ADD_FRIEND_LV] = {
    SettingDataType.Toggle,
    false
  },
  [SystemSetting.BLOCK_STRANGER_INVITE] = {
    SettingDataType.Toggle,
    false
  },
  [SystemSetting.ADD_FRIEND_LV_NUMBER] = {
    SettingDataType.Num,
    require("Main.friend.FriendUtils").GetAddFriendLevel(),
    function(num)
      if num <= 0 then
        Toast(textRes.Friend[70])
        return false
      else
        local serverLevelInfo = require("Main.Server.ServerModule").Instance():GetServerLevelInfo()
        local limitWithServerLevel = require("Main.friend.FriendUtils").GetAddFriendLevelLimit()
        local levelLimit = math.huge
        if serverLevelInfo then
          levelLimit = serverLevelInfo.level - limitWithServerLevel
        end
        if num > levelLimit then
          if limitWithServerLevel > 0 then
            Toast(string.format(textRes.Friend[72], levelLimit, limitWithServerLevel))
          else
            Toast(string.format(textRes.Friend[71], levelLimit))
          end
          return false
        else
          return true
        end
      end
    end
  },
  [SystemSetting.CloseTouchListPanel] = {
    SettingDataType.Toggle,
    false
  }
}
local SystemSettingBean = require("netio.protocol.mzm.gsp.systemsetting.SystemSetting")
local CSSettingMap = {
  [SystemSetting.MakeFriendVarify] = SystemSettingBean.VALID_FRIEND,
  [SystemSetting.NOT_SHARE_EQUIP_INFO] = SystemSettingBean.QUERY_EQUIPINFO,
  [SystemSetting.ADD_FRIEND_LV] = SystemSettingBean.VALIDATE_ADD_FRIEND_LV,
  [SystemSetting.BLOCK_STRANGER_INVITE] = SystemSettingBean.FORBID_STRANGER_TEAM_INVITE,
  [SystemSetting.ADD_FRIEND_LV_NUMBER] = SystemSettingBean.ADD_FRIEND_REQUIRED_LV
}
SystemSettingCfg.SettingDataType = SettingDataType
SystemSettingCfg.SystemSetting = SystemSetting
SystemSettingCfg.SystemSettingDefaults = SystemSettingDefaults
SystemSettingCfg.CSSettingMap = CSSettingMap
return SystemSettingCfg
