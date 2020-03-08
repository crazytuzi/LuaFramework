local Lplus = require("Lplus")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local Network = require("netio.Network")
local ECMSDK = require("ProxySDK.ECMSDK")
local ECReplayKit = require("ProxySDK.ECReplayKit")
local FMShow = require("Main.Chat.ui.FMShow")
local ErrorCodes = require("netio.protocol.mzm.gsp.apollo.ErrorCodes")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
local CommonGuideTip = require("GUI.CommonGuideTip")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECApollo = Lplus.Class("ECApollo")
local def = ECApollo.define
def.const("table").ROOMTYPE = {GLOBAL = 1}
def.const("table").STATUS = {
  NORMAL = 0,
  CONNECTION = 1,
  JOIN = 2
}
def.field("boolean").m_IsInit = false
def.field("boolean").m_IsOpenMic = false
def.field("boolean").m_IsOpenSpeaker = false
def.field("number").m_CheckTimer = 0
def.field("number").m_VoipCheckTimer = 0
def.field("number").m_Status = 0
def.field("number").m_VoipStatus = 0
def.field("number").m_CurrentRoomType = 1
def.field(CommonGuideTip).m_GuideTip = nil
def.field(CommonGuideTip).m_VoipGuideTip = nil
def.field("table").m_VoipRoomInfo = function()
  return {}
end
def.field("table").m_ApolloInfo = function()
  return {}
end
local instance
def.static("=>", ECApollo).Instance = function()
  if not instance then
    instance = ECApollo()
  end
  return instance
end
def.static("=>", "boolean").IsNewPackage = function()
  if Apollo and Apollo.Dummy then
    return true
  end
  return false
end
def.static("=>", "boolean").IsNewPackageEX = function()
  if platform == 1 then
    return true
  end
  local version = GameUtil.GetProgramCurrentVersionInfo()
  return tonumber(version) > 108
end
def.static("=>", "boolean").IsJoinRoom = function()
  if not instance then
    return false
  end
  warn("IsJoinRoom", instance.m_Status)
  return instance.m_Status == ECApollo.STATUS.JOIN
end
def.static("number", "=>", "boolean").IsSpeaker = function(type)
  local speakerInfos = ECApollo.GetSpeakerInfo(type)
  local sdkInfo = ECMSDK.GetMSDKInfo()
  if speakerInfos and sdkInfo then
    local openID = sdkInfo.openId
    for k, v in pairs(speakerInfos) do
      if GetStringFromOcts(v.openid) == openID then
        return true
      end
    end
  end
  return false
end
def.static("=>", "number").GetStatus = function()
  if not instance then
    return 0
  end
  return instance.m_Status
end
def.static("=>", "number").GetVoipStatus = function()
  if not instance then
    return 0
  end
  return instance.m_VoipStatus
end
def.static("=>", "boolean").IsInit = function()
  if not instance then
    return false
  end
  return instance.m_IsInit
end
def.static("number", "=>", "table").GetSpeakerInfo = function(type)
  if not instance or not instance.m_ApolloInfo or not instance.m_ApolloInfo.global_room_speaker_info_lists then
    return nil
  end
  local speakerInfos
  for k, v in pairs(instance.m_ApolloInfo.global_room_speaker_info_lists) do
    if v.room_type == type then
      speakerInfos = v.speaker_infos
      break
    end
  end
  return speakerInfos
end
def.static("boolean").SetCurrentMicState = function(state)
  if not instance then
    return
  end
  instance.m_IsOpenMic = state
end
def.static("=>", "boolean").GetCurrentMicState = function()
  if not instance then
    return false
  end
  return instance.m_IsOpenMic
end
def.static("boolean").SetCurrentSpeakerState = function(state)
  if not instance then
    return
  end
  instance.m_IsOpenSpeaker = state
end
def.static("=>", "boolean").GetCurrentSpeakerState = function()
  if not instance then
    return false
  end
  return instance.m_IsOpenSpeaker
end
def.static("=>", "number").GetCurrentRoomType = function()
  if not instance then
    return ECApollo.ROOMTYPE.GLOBAL
  end
  return instance.m_CurrentRoomType or ECApollo.ROOMTYPE.GLOBAL
end
def.static("=>", CommonGuideTip).GetGuidTipPanel = function()
  if not instance then
    return nil
  end
  return instance.m_GuideTip
end
def.static().DestroyGuidPanel = function()
  local guideTip = ECApollo.GetGuidTipPanel()
  if guideTip then
    guideTip:DestroyPanel()
    guideTip = nil
  end
end
def.static().DestroyVoipGuidPanel = function()
  if instance and instance.m_VoipGuideTip then
    instance.m_VoipGuideTip:DestroyPanel()
    instance.m_VoipGuideTip = nil
  end
end
def.static("=>", "boolean").IsOpen = function()
  local open = FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_APOLLO)
  return open
end
def.static().InitApollo = function()
  if Apollo and Apollo.Init then
    Apollo.Init()
  end
end
local isInitVoiceEngine = false
def.static("=>", "boolean").CreateApolloVoiceEngine = function()
  local sdktype = ClientCfg.GetSDKType()
  if sdktype ~= ClientCfg.SDKTYPE.MSDK then
    return false
  end
  if Apollo and Apollo.CreateApolloVoiceEngine and not isInitVoiceEngine then
    local appid = ECMSDK.APPID.QQ
    local openID = ECMSDK.GetMSDKInfo().openId
    if openID then
      local ret = Apollo.CreateApolloVoiceEngine(appid, openID)
      isInitVoiceEngine = ret == 0
      return isInitVoiceEngine
    else
      warn("CreateApolloVoiceEngine openID doesn't exsit")
      return false
    end
  end
  return isInitVoiceEngine
end
def.static("number", "=>", "number").SetMode = function(mode)
  if not instance or not instance.m_IsInit then
    return -1
  end
  if Apollo and Apollo.SetMode then
    return Apollo.SetMode(mode)
  end
  return -1
end
def.static("table", "=>", "number").JoinRoom = function(params)
  if not instance or not instance.m_IsInit then
    return -1
  end
  if Apollo and Apollo.JoinRoom then
    local roomId = params[1]
    local voipRoomUserAccess = params[2]
    local url1 = "udp://" .. _G.GetStringFromOcts(voipRoomUserAccess.access_ip_list[1])
    local url2 = "udp://" .. _G.GetStringFromOcts(voipRoomUserAccess.access_ip_list[2])
    local url3 = "udp://" .. _G.GetStringFromOcts(voipRoomUserAccess.access_ip_list[3])
    local roomKey = voipRoomUserAccess.room_key
    local memberId = voipRoomUserAccess.member_id
    local openId = _G.GetStringFromOcts(voipRoomUserAccess.open_id)
    local timeOut = 30000
    warn(openId, "JoinRoom---------", url1, " ", url2, " ", url3, " ", roomId, " ", roomKey, " ", memberId, " ", timeOut)
    return Apollo.JoinRoom(url1, url2, url3, roomId, roomKey, memberId, openId, timeOut)
  end
  return -1
end
def.static("table", "=>", "number").JoinBigRoom = function(params)
  if Apollo and Apollo.JoinBigRoom then
    local urls = GetStringFromOcts(params.user_access)
    local role = ECApollo.IsSpeaker(ECApollo.GetCurrentRoomType()) and 1 or 2
    local businessID = instance.m_ApolloInfo.business_id
    local roomId = params.gid
    local roomKey = params.roomkey
    if not ECApollo.IsNewPackage() then
      roomId = params.gid:ToNumber()
      roomKey = params.roomkey:ToNumber()
    end
    local memberId = params.memberid
    local openID = _G.GetStringFromOcts(params.uuid)
    local timeOut = 30000
    warn(params.user_openid, "JoinBigRoom----------------------> : ", urls, " ", role, "  ", businessID, "  ", roomId, "  ", roomKey, "  ", memberId, "  ", openID, "  ", timeOut)
    return Apollo.JoinBigRoom(urls, role, businessID, roomId, roomKey, memberId, openID, timeOut)
  end
  return -1
end
def.static("=>", "number").QuitBigRoom = function()
  if ECApollo.IsSpeaker(ECApollo.GetCurrentRoomType()) then
  end
  if Apollo and Apollo.QuitBigRoom then
    ECApollo.SetCurrentMicState(false)
    return Apollo.QuitBigRoom()
  end
  return -1
end
def.static("boolean", "=>", "number").QuitRoom = function(isReport)
  if Apollo and Apollo.QuitRoom then
    local params = instance.m_VoipRoomInfo
    local roomId = params.roomId
    local userAccess = params.userAccess
    local roomType = params.roomType
    if not roomId or not userAccess or not roomType then
      warn("QuitRoom roomId  doesn't exist", roomId, userAccess, roomType)
      return -1
    end
    local memberId = userAccess.member_id
    local openId = _G.GetStringFromOcts(userAccess.open_id)
    if isReport then
      ECApollo.ReportJoinAndExitVoipRoomReq({voip_room_type = roomType, action = 2})
    end
    ECApollo.SetCurrentMicState(false)
    ECApollo.SetCurrentSpeakerState(false)
    return Apollo.QuitRoom(roomId, memberId, openId)
  end
  return -1
end
def.static("=>", "number").OpenMic = function()
  ECApollo.SetMode(0)
  if Apollo and Apollo.OpenMic then
    return Apollo.OpenMic()
  end
  return -1
end
def.static("=>", "number").CloseMic = function()
  if Apollo and Apollo.CloseMic then
    return Apollo.CloseMic()
  end
  return -1
end
def.static("=>", "number").OpenSpeaker = function()
  ECApollo.SetMode(0)
  if Apollo and Apollo.OpenSpeaker then
    return Apollo.OpenSpeaker()
  end
  return -1
end
def.static("=>", "number").CloseSpeaker = function()
  if Apollo and Apollo.CloseSpeaker then
    return Apollo.CloseSpeaker()
  end
  return -1
end
def.static("=>", "number").Resume = function()
  if not instance or platform == 1 then
    return
  end
  if not instance.m_IsInit then
    warn("Apollo doesn't Init")
    return -1
  end
  if Apollo and Apollo.Resume then
    return Apollo.Resume()
  end
  return -1
end
def.static("=>", "number").Pause = function()
  if not instance or platform == 1 then
    return
  end
  if not instance.m_IsInit then
    warn("Apollo doesn't Init")
    return -1
  end
  if Apollo and Apollo.Pause then
    return Apollo.Pause()
  end
  return -1
end
def.static("number", "=>", "number").SetSpeakerVolume = function(vol)
  if not instance.m_IsInit then
    warn("Apollo doesn't Init")
    return -1
  end
  if Apollo and Apollo.SetSpeakerVolume then
    return Apollo.SetSpeakerVolume(vol)
  end
  return -1
end
def.static("=>", "number").GetSpeakerLevel = function()
  if not instance.m_IsInit then
    warn("Apollo doesn't Init")
    return -1
  end
  if Apollo and Apollo.GetSpeakerLevel then
    return Apollo.GetSpeakerLevel()
  end
  return -1
end
def.static("=>", "number").GetMicLevel = function()
  if not instance.m_IsInit then
    warn("Apollo doesn't Init")
    return -1
  end
  if Apollo and Apollo.GetMicLevel then
    return Apollo.GetMicLevel()
  end
  return -1
end
def.static("=>", "number").GetJoinRoomBigResult = function()
  if Apollo and Apollo.GetJoinRoomBigResult then
    return Apollo.GetJoinRoomBigResult()
  end
  return -1
end
def.static("=>", "number").GetJoinRoomResult = function()
  if Apollo and Apollo.GetJoinRoomResult then
    return Apollo.GetJoinRoomResult()
  end
  return -1
end
def.static("boolean").SetAnchorUsed = function(enable)
  if GameUtil.SetAnchorUsed then
    GameUtil.SetAnchorUsed(enable)
  end
end
def.static("table").ApolloJoinVoipRoomReq = function(params)
  warn(instance.m_VoipStatus, "ApolloJoinVoipRoomReq", params.voip_room_type)
  if instance.m_VoipStatus == ECApollo.STATUS.CONNECTION then
    Toast(textRes.Chat[49])
    return
  end
  Toast(textRes.Chat[42])
  local p = require("netio.protocol.mzm.gsp.apollo.CApolloJoinVoipRoomReq").new(params.voip_room_type)
  gmodule.network.sendProtocol(p)
end
def.static("table").ApolloExitVoipRoomReq = function(params)
  warn("ApolloExitVoipRoomReq", params.voip_room_type)
  local p = require("netio.protocol.mzm.gsp.apollo.CApolloExitVoipRoomReq").new(params.voip_room_type)
  gmodule.network.sendProtocol(p)
end
def.static("table").ReportJoinAndExitVoipRoomReq = function(params)
  warn("ReportJoinAndExitVoipRoomReq", params.voip_room_type, params.action)
  local p = require("netio.protocol.mzm.gsp.apollo.CReportJoinAndExitVoipRoomReq").new(params.voip_room_type, params.action)
  gmodule.network.sendProtocol(p)
end
def.static("table").ApolloEnterGlobalLargeRoomReq = function(params)
  if not instance then
    return
  end
  if ECReplayKit.GetStatus() == ECReplayKit.STATUS.START then
    Toast(textRes.Chat.ApolloError[13])
    return
  end
  warn(instance.m_Status, "ApolloEnterGlobalLargeRoomReq", params.room_type)
  if instance.m_Status == ECApollo.STATUS.CONNECTION then
    Toast(textRes.Chat[49])
    return
  end
  Toast(textRes.Chat[42])
  local p = require("netio.protocol.mzm.gsp.apollo.CApolloEnterGlobalLargeRoomReq").new(params.room_type)
  gmodule.network.sendProtocol(p)
end
def.static("table").ApolloEnterLargeRoomReq = function(params)
  warn("ApolloEnterLargeRoomReq", params.room_type, params.room_context_id)
  local p = require("netio.protocol.mzm.gsp.apollo.CApolloEnterLargeRoomReq").new(params.room_type, params.room_context_id)
  gmodule.network.sendProtocol(p)
end
def.static("table").ReportSpeakerMicStatusReq = function(params)
  warn("CReportSpeakerMicStatusReq", params.room_type, params.status)
  local p = require("netio.protocol.mzm.gsp.apollo.CReportSpeakerMicStatusReq").new(params.room_type, params.status)
  gmodule.network.sendProtocol(p)
end
local count = 0
def.static("table").OnApolloJoinVoipRoomRsp = function(p)
  warn("OnApolloJoinVoipRoomRsp", p.retcode, p.voip_room_type, p.room_id, p.user_access)
  if p.retcode == ErrorCodes.ERROR_SUCCEED then
    ECApollo.SetMode(0)
    local ret = ECApollo.JoinRoom({
      p.room_id,
      p.user_access
    })
    warn("JoinRoom Retcode ################: ", ret)
    instance:ClearVoipCheckTimer()
    instance.m_VoipRoomInfo = {
      roomId = p.room_id,
      userAccess = p.user_access,
      roomType = p.voip_room_type
    }
    if ret == 0 then
      ECApollo.QuitBigRoom()
      instance.m_VoipStatus = ECApollo.STATUS.CONNECTION
      instance.m_VoipCheckTimer = GameUtil.AddGlobalTimer(3, false, function()
        local result = ECApollo.GetJoinRoomResult()
        warn("Check JoinRoom Result: ", result)
        if result == 51 then
          Toast(textRes.Chat[39])
          Toast(textRes.Chat.ApolloError[12])
          instance.m_Status = ECApollo.STATUS.NORMAL
          instance.m_VoipStatus = ECApollo.STATUS.JOIN
          instance:ClearVoipCheckTimer()
          ECApollo.OpenSpeaker()
          ECApollo.SetCurrentSpeakerState(true)
          Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.JOIN_VOCIE_ROOM, nil)
          ECApollo.TryVoipShowGuid()
          ECApollo.ReportJoinAndExitVoipRoomReq({
            voip_room_type = p.voip_room_type,
            action = 1
          })
          Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.NotifySpeakerStatus, nil)
        elseif result == 50 then
          instance.m_VoipStatus = ECApollo.STATUS.NORMAL
          instance:ClearVoipCheckTimer()
          Toast(textRes.Chat[40])
        elseif result == 52 then
          count = count + 1
          if count == 10 then
            instance:ClearVoipCheckTimer()
            count = 0
          end
        end
      end)
    elseif ret == 6 then
      instance.m_VoipStatus = ECApollo.STATUS.NORMAL
      ECApollo.CloseSpeaker()
      if ECApollo.QuitRoom(false) ~= -1 then
        GameUtil.AddGlobalLateTimer(1, true, function()
          ECApollo.ApolloJoinVoipRoomReq({voip_room_type = 1})
        end)
      end
    end
  elseif p.retcode == ErrorCodes.ERROR_LARGE_ROOM_REQ_TIMEOUT or p.retcode == ErrorCodes.ERROR_LARGE_ROOM_ERROR_SESSION_TIMEOUT then
    Toast("\232\175\183\230\177\130\230\136\191\233\151\180\232\182\133\230\151\182")
  elseif p.retcode == ErrorCodes.ERROR_ERROR_REQ_CMD_CHECK_ROOM_EXIST then
    Toast("\232\175\183\230\177\130\230\136\191\233\151\180\229\143\183\228\184\141\229\173\152\229\156\168")
  elseif p.retcode == ErrorCodes.ERROR_LARGE_ROOM_ERROR_FAILED_TO_SEND_REQ_FOR_NO_CONNECTION_AVAIBLE then
    Toast("\232\175\183\230\177\130\229\143\145\233\128\129\229\164\177\232\180\165")
  end
end
def.static("table").OnApolloExitVoipRoomRsp = function(p)
  warn("OnApolloExitVoipRoomRsp", p.retcode, p.voip_room_type, p.room_id, p.member_id)
  if p.retcode == ErrorCodes.ERROR_SUCCEED then
    local ret = ECApollo.QuitRoom(false)
    if ret then
      warn("Reset VoipRoom Status")
      instance.m_VoipStatus = ECApollo.STATUS.NORMAL
      instance.m_VoipRoomInfo = {}
      Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.JOIN_VOCIE_ROOM, nil)
    end
  end
end
def.static("table").OnSynVoipRoomOnlineMembers = function(p)
  warn("OnSynVoipRoomOnlineMembers", p.voip_room_type, p.online_member_list)
  instance.m_VoipRoomInfo.onlineMemberList = p.online_member_list
  Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_ROOM_STATE, {
    p.online_member_list
  })
end
def.static("table").OnApolloEnterGlobalLargeRoomRsp = function(p)
  warn("OnApolloEnterGlobalLargeRoomRsp", p.retcode, p.rsp_infos)
  if p.retcode == ErrorCodes.ERROR_SUCCEED then
    local ret = ECApollo.JoinBigRoom(p.rsp_infos[1])
    warn("JoinBigRoom Retcode !!!!: ", ret)
    instance:ClearCheckTimer()
    if ret == 0 then
      ECApollo.QuitRoom(true)
      ECApollo.DestroyVoipGuidPanel()
      instance.m_Status = ECApollo.STATUS.CONNECTION
      instance.m_CheckTimer = GameUtil.AddGlobalTimer(3, false, function()
        local result = ECApollo.GetJoinRoomBigResult()
        warn("Check JoinBigRoom Result: ", result)
        if result == 51 then
          Toast(textRes.Chat[39])
          Toast(textRes.Chat.ApolloError[12])
          ECApollo.OpenSpeaker()
          if ECApollo.IsSpeaker(ECApollo.GetCurrentRoomType()) then
            ECApollo.SetAnchorUsed(true)
          end
          instance.m_Status = ECApollo.STATUS.JOIN
          instance:ClearCheckTimer()
          Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.Join_Global_Large_Room, nil)
          local ECMSDK = require("ProxySDK.ECMSDK")
          ECMSDK.SendTLogToServer(_G.TLOGTYPE.APOLLOSTATUS, {1})
        elseif result == 50 then
          instance.m_Status = ECApollo.STATUS.NORMAL
          instance:ClearCheckTimer()
          Toast(textRes.Chat[40])
        end
      end)
    elseif ret == 6 then
      instance.m_Status = ECApollo.STATUS.NORMAL
      ECApollo.CloseSpeaker()
      ECApollo.QuitBigRoom()
    end
  elseif p.retcode == ErrorCodes.ERROR_LARGE_ROOM_REQ_TIMEOUT or p.retcode == ErrorCodes.ERROR_LARGE_ROOM_ERROR_SESSION_TIMEOUT then
    Toast("\232\175\183\230\177\130\230\136\191\233\151\180\232\182\133\230\151\182")
  elseif p.retcode == ErrorCodes.ERROR_ERROR_REQ_CMD_CHECK_ROOM_EXIST then
    Toast("\232\175\183\230\177\130\230\136\191\233\151\180\229\143\183\228\184\141\229\173\152\229\156\168")
  elseif p.retcode == ErrorCodes.ERROR_LARGE_ROOM_ERROR_FAILED_TO_SEND_REQ_FOR_NO_CONNECTION_AVAIBLE then
    Toast("\232\175\183\230\177\130\229\143\145\233\128\129\229\164\177\232\180\165")
  end
end
def.static("table").OnApolloEnterLargeRoomRsp = function(p)
  warn("OnApolloEnterLargeRoomRsp", p.retcode, p.rsp_infos)
  if p.retcode == ErrorCodes.ERROR_SUCCEED then
    ECApollo.JoinBigRoom(p.rsp_infos[1])
  end
end
def.static("table").OnSyncApolloInfo = function(p)
  warn("OnSyncApolloGlobalLargeRoomInfo: ", p.business_id, " : ", p.global_room_speaker_info_lists)
  instance.m_ApolloInfo.business_id = p.business_id
  instance.m_ApolloInfo.global_room_speaker_info_lists = p.global_room_speaker_info_lists
  for k, v in pairs(p.global_room_speaker_info_lists) do
    warn("Set CurrentRoomType : ", instance.m_CurrentRoomType)
    instance.m_CurrentRoomType = v.room_type
    break
  end
end
def.static("table").OnNotifyReportSpeakerMicStatus = function(p)
  warn("OnNotifyReportSpeakerMicStatus", p.room_type, p.openid, p.status)
  if not instance or not instance.m_ApolloInfo or not instance.m_ApolloInfo.global_room_speaker_info_lists then
    return
  end
  for _, v in pairs(instance.m_ApolloInfo.global_room_speaker_info_lists) do
    if v.room_type == p.room_type then
      for _, info in pairs(v.speaker_infos) do
        if GetStringFromOcts(info.openid) == GetStringFromOcts(p.openid) then
          info.is_open_mic = p.status
          break
        end
      end
      break
    end
  end
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.NotifySpeakerStatus, nil)
end
def.static("table", "table").OnLoginAccountSuccess = function(p)
end
def.static("table", "table").OnSettingChanged = function(p)
  warn("ECApollo OnSettingChanged", p[1])
  if not ECApollo.IsOpen() then
    return
  end
  local id = p[1]
  if id == SystemSettingModule.SystemSetting.ANCHOR_SPEAKER then
    local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.ANCHOR_SPEAKER)
    local volume = setting.mute and 0 or setting.volume
    ECApollo.SetSpeakerVolume(volume * 100)
  elseif id == SystemSettingModule.SystemSetting.ANCHOR then
    local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.ANCHOR)
    if not setting.isEnabled then
      instance.m_Status = ECApollo.STATUS.NORMAL
      ECApollo.CloseSpeaker()
      ECApollo.QuitBigRoom()
    else
      Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.NotifySpeakerStatus, nil)
    end
    Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.OnToggle, {
      switch = setting.isEnabled
    })
  end
end
def.static("table", "table").OnInitApollo = function(p)
  warn("OnInitApollo--------------------", p.switch)
  if p.switch then
    if not instance.m_IsInit then
      ECApollo.InitApollo()
    else
      warn("Apollo Component is already Inited ")
    end
    if ECApollo.CreateApolloVoiceEngine() then
      instance.m_IsInit = true
      ECApollo.SetMode(1)
      ECApollo.SetMode(1)
      ECApollo.SetAnchorUsed(true)
      ECApollo.InitSystemSetting()
      ECApollo.Instance():TryJoinRoom()
      ECReplayKit.EnableSoftAec(true)
      warn("Create Apollo Voice Engine")
    else
      warn("Fail to Create Apollo Voice Engine")
    end
  end
end
def.static("table", "table").OnFeatureOpenChange = function(p)
  warn("OnFeatureOpenChange--------------------", p.feature, p.open)
  local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.ANCHOR)
  if p.feature == 25 and not p.open and setting.isEnabled then
    instance.m_Status = ECApollo.STATUS.NORMAL
    ECApollo.CloseSpeaker()
    ECApollo.QuitBigRoom()
  end
end
def.static("table", "table").OnRoleLvUp = function(p)
  local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.ANCHOR)
  local curLevel = p.level
  if curLevel == 6 and ECApollo.IsOpen() and setting.isEnabled then
    local panel = FMShow.Instance().m_panel
    if panel and not panel.isnil and panel.activeSelf then
      local bg = panel:FindDirect("Group_Console/Img_Bg")
      instance.m_GuideTip = CommonGuideTip.ShowGuideTip(textRes.Chat[43], bg, CommonGuideTip.StyleEnum.RIGHT)
    end
  end
end
def.static().TryVoipShowGuid = function()
  local PlayerPref = require("Main.Common.LuaPlayerPrefs")
  warn(PlayerPref.HasRoleKey("TeamVoipGuid"), "ECApollo TryShowGuid")
  if not PlayerPref.HasRoleKey("TeamVoipGuid") and FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_TEAM_VOIP_ROOM) then
    local panel = require("Main.MainUI.ui.MainUIPanel").Instance().m_panel
    if panel and not panel.isnil and panel.activeInHierarchy then
      local groupMic = panel:FindDirect("Pnl_TaskTeam/TaskTeamMenu/Group_Open/Team/Team_Apollo/Group_Right/Group_Mic")
      local bg = groupMic:FindDirect("Btn_CloseMic")
      if groupMic.activeInHierarchy and bg.activeInHierarchy then
        instance.m_VoipGuideTip = CommonGuideTip.ShowGuideTip(textRes.Chat[75], bg, CommonGuideTip.StyleEnum.LEFT)
      end
    end
    PlayerPref.SetRoleInt("TeamVoipGuid", 1)
    PlayerPref.Save()
  end
end
def.static("table", "table").OnHasTeam = function(p)
  local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.AUTO_JOIN_TEAM_VOICE)
  warn("ECApollo OnHasTeam", setting.isEnabled)
  if setting.isEnabled and FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_TEAM_VOIP_ROOM) and ECApollo.IsNewPackageEX() then
    ECApollo.ApolloJoinVoipRoomReq({voip_room_type = 1})
  end
end
def.static().InitSystemSetting = function()
  local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.ANCHOR)
  warn("ECApollo InitSystemSetting", setting.isEnabled)
  if setting.isEnabled then
    local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.ANCHOR_SPEAKER)
    local volume = setting.mute and 0 or setting.volume
    ECApollo.SetSpeakerVolume(volume * 100)
  end
end
def.method().TryJoinRoom = function(self)
  local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.AUTO_JOIN_TEAM_VOICE)
  if setting.isEnabled and FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_TEAM_VOIP_ROOM) and ECApollo.IsNewPackageEX() then
    local roomId = self.m_VoipRoomInfo.roomId
    local teamData = require("Main.Team.TeamData").Instance()
    warn(teamData:HasTeam(), "ECApollo TryJoinRoom ---------------------", roomId)
    if roomId and teamData:HasTeam() then
      ECApollo.ApolloJoinVoipRoomReq({voip_room_type = 1})
    end
  end
end
def.method().ClearCheckTimer = function(self)
  if self.m_CheckTimer ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_CheckTimer)
    self.m_CheckTimer = 0
  end
end
def.method().ClearVoipCheckTimer = function(self)
  if self.m_VoipCheckTimer ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_VoipCheckTimer)
    self.m_VoipCheckTimer = 0
  end
end
def.method().ClearData = function(self)
  if self.m_IsInit then
    ECApollo.DestroyGuidPanel()
    ECApollo.DestroyVoipGuidPanel()
    ECApollo.CloseSpeaker()
    ECApollo.QuitBigRoom()
    ECApollo.QuitRoom(false)
  end
  self:ClearCheckTimer()
  self.m_Status = ECApollo.STATUS.NORMAL
  self.m_VoipStatus = ECApollo.STATUS.NORMAL
  self.m_ApolloInfo = {}
  self.m_VoipRoomInfo = {}
end
def.method().Init = function(self)
  if ZLUtil and ZLUtil.initApollo then
    ZLUtil.initApollo()
  end
  Event.RegisterEvent(ModuleId.SYSTEM_SETTING, gmodule.notifyId.SystemSetting.SETTING_CHANGED, ECApollo.OnSettingChanged)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:ClearData()
  end)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ECApollo.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.InitApollo, ECApollo.OnInitApollo)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_JOIN_TEAM, ECApollo.OnHasTeam)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_CREATE_TEAM, ECApollo.OnHasTeam)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.SYNC_TEAM_INFO, ECApollo.OnHasTeam)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.apollo.SApolloEnterLargeRoomRsp", ECApollo.OnApolloEnterLargeRoomRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.apollo.SApolloEnterGlobalLargeRoomRsp", ECApollo.OnApolloEnterGlobalLargeRoomRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.apollo.SSyncApolloInfo", ECApollo.OnSyncApolloInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.apollo.SNotifyReportSpeakerMicStatus", ECApollo.OnNotifyReportSpeakerMicStatus)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.apollo.SApolloJoinVoipRoomRsp", ECApollo.OnApolloJoinVoipRoomRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.apollo.SApolloExitVoipRoomRsp", ECApollo.OnApolloExitVoipRoomRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.apollo.SSynVoipRoomOnlineMembers", ECApollo.OnSynVoipRoomOnlineMembers)
end
ECApollo.Commit()
return ECApollo
