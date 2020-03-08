local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local IDIPModule = Lplus.Extend(ModuleBase, "IDIPModule")
require("Main.module.ModuleId")
local KejuConst = require("Main.Keju.KejuConst")
local KejuUtils = require("Main.Keju.KejuUtils")
local ExamChoiceDlg = require("Main.Keju.ui.ExamChoiceDlg")
local ExamDlg = require("Main.Keju.ui.ExamDlg")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local ChatMsgBuilder = require("Main.Chat.ChatMsgBuilder")
local ItemIDIPData = require("Main.IDIP.data.ItemIDIPData")
local def = IDIPModule.define
local instance
def.static("=>", IDIPModule).Instance = function()
  if instance == nil then
    instance = IDIPModule()
    instance.m_moduleId = ModuleId.IDIP
  end
  return instance
end
def.override().Init = function(self)
  warn("IDIP, init")
  self:IDIPNameCheck()
  ItemIDIPData.Instance():Init()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.idip.SIdipBanRank", IDIPModule.onSIdipBanRank)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.idip.SIdipUnbanRank", IDIPModule.onSIdipUnbanRank)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.idip.SIdipBanPlay", IDIPModule.onSIdipBanPlay)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.idip.SIdipRoleBanPlayInfo", IDIPModule.onSIdipRoleBanPlay)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.idip.SIdipUnbanPlay", IDIPModule.onSIdipUnbanPlay)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.idip.SIdipAddZeroProfit", IDIPModule.onSIdipAddZeroProfit)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.idip.SIdipRemoveProfit", IDIPModule.onSIdipRemoveProfit)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.idip.SIdipMessage", IDIPModule.onSIdipMessage)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.idip.SIdipClearSay", IDIPModule.onSIdipClearSay)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.idip.SIdipBanRole", IDIPModule.onSIdipBanRole)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.idip.SIdipBanRoleAddFriend", IDIPModule.onSIdipBanRoleAddFriend)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.idip.SyncItemSwitches", IDIPModule.onSyncItemSwitches)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.idip.SItemSwitchChanged", IDIPModule.onSItemSwitchChanged)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, IDIPModule.OnLeaveWorld)
  ModuleBase.Init(self)
end
def.static("table").onSIdipBanRank = function(p)
  warn("onSIdipBanRank:", p.rankType, p.reason, p.unbanTime)
  local rankName = textRes.IDIP.ChartTypeName[p.rankType]
  local timeInt = p.unbanTime:ToNumber()
  local timeStr = os.date("%Y-%m-%d %H:%M", timeInt)
  local reasonStr = ChatMsgBuilder.Unmarshal(p.reason)
  if rankName and timeInt and timeStr and reasonStr then
    local tip = string.format(textRes.IDIP[1], reasonStr, rankName, timeStr)
    Toast(tip)
  end
end
def.static("table").onSIdipUnbanRank = function(p)
  warn("onSIdipUnbanRank:", p.rankType)
  local rankName = textRes.IDIP.ChartTypeName[p.rankType]
  if rankName then
    local tip = string.format(textRes.IDIP[2], rankName)
    Toast(tip)
  end
end
def.static("table").onSIdipBanPlay = function(p)
  warn("onSIdipBanPlay", p.playType, p.unbanTime, p.reason)
  local playName = textRes.IDIP.PlayTypeName[p.playType]
  local timeInt = p.unbanTime:ToNumber()
  local timeStr = os.date("%Y-%m-%d %H:%M", timeInt)
  local reasonStr = ChatMsgBuilder.Unmarshal(p.reason)
  if playName and timeInt and timeStr and reasonStr then
    local tip = string.format(textRes.IDIP[3], reasonStr, playName, timeStr)
    Toast(tip)
  end
end
def.static("table").onSIdipRoleBanPlay = function(p)
  warn("onSIdipBRoleanPlay", p.name, p.playType, p.unbanTime, p.reason)
  local roleName = ChatMsgBuilder.Unmarshal(p.name)
  local playName = textRes.IDIP.PlayTypeName[p.playType]
  if roleName and playName then
    local tip = string.format(textRes.IDIP[8], roleName, playName)
    Toast(tip)
  end
end
def.static("table").onSIdipUnbanPlay = function(p)
  warn("onSIdipUnbanPlay", p.playType)
  local playName = textRes.IDIP.PlayTypeName[p.playType]
  if playName then
    local tip = string.format(textRes.IDIP[4], playName)
    Toast(tip)
  end
end
def.static("table").onSIdipAddZeroProfit = function(p)
  warn("onSIdipAddZeroProfit", p.unbanTime, p.reason)
  local timeInt = p.unbanTime:ToNumber()
  local timeStr = os.date("%Y-%m-%d %H:%M", timeInt)
  local reasonStr = ChatMsgBuilder.Unmarshal(p.reason)
  if timeInt and timeStr and reasonStr then
    local tip = string.format(textRes.IDIP[5], reasonStr, timeStr)
    Toast(tip)
  end
end
def.static("table").onSIdipRemoveProfit = function(p)
  warn("onSIdipRemoveProfit")
  local tip = textRes.IDIP[6]
  Toast(tip)
end
def.static("table").onSIdipMessage = function(p)
  warn("onSIdipUnbanPlay", p.message)
  local tip = ChatMsgBuilder.Unmarshal(p.message)
  if tip then
    Toast(tip)
  end
end
def.static("table").onSIdipClearSay = function(p)
  local roleId = p.roleid
  warn("onSIdipClearSay roleId", roleId)
  local uniques = require("Main.Chat.ChatMsgData").Instance():DeleteAllMsgFromRole(roleId)
  require("Main.Chat.ui.ChannelChatPanel").Instance():UpdateContent()
  local SocialDlg = require("Main.friend.ui.SocialDlg")
  SocialDlg.Instance():UpdateContent()
  require("Main.MainUI.ui.MainUIChat").Instance():RemoveMsgs(uniques)
end
def.static("table").onSIdipBanRole = function(p)
  warn("onSIdipBanRole", p.unbanTime, p.reason)
  local timeInt = p.unbanTime:ToNumber()
  if timeInt and timeInt > 0 then
    local timeStr = os.date("%Y-%m-%d %H:%M", timeInt)
    local reasonStr = ChatMsgBuilder.Unmarshal(p.reason)
    if timeStr and reasonStr then
      local tip = string.format(textRes.IDIP[9], reasonStr, timeStr)
      Toast(tip)
    end
  else
    local reasonStr = ChatMsgBuilder.Unmarshal(p.reason)
    if reasonStr then
      local tip = string.format(textRes.IDIP[14], reasonStr)
      Toast(tip)
    end
  end
end
def.static("table").onSIdipBanRoleAddFriend = function(p)
  warn("onSIdipBanRoleAddFriend", p.unbanTime, p.reason)
  local timeInt = p.unbanTime:ToNumber()
  local timeStr = os.date("%Y-%m-%d %H:%M", timeInt)
  local reasonStr = ChatMsgBuilder.Unmarshal(p.reason)
  if timeInt and timeStr and reasonStr then
    local tip = string.format(textRes.IDIP[13], reasonStr, timeStr)
    Toast(tip)
  end
end
def.static("table").onSyncItemSwitches = function(p)
  warn("[IDIPModule:onSyncItemSwitches] On SyncItemSwitches!")
  ItemIDIPData.Instance():SyncItemIDIPs(p.infos)
end
def.static("table").onSItemSwitchChanged = function(p)
  warn("[IDIPModule:onSItemSwitchChanged] On SItemSwitchChanged!")
  ItemIDIPData.Instance():SetItemIDIP(p.info)
end
def.static("table", "table").OnLeaveWorld = function(param, context)
  IDIPModule.Instance():Reset()
  ItemIDIPData.Instance():OnLeaveWorld(param, context)
end
def.override().OnReset = function(self)
end
def.method().IDIPNameCheck = function(self)
  if Application.platform == RuntimePlatform.WindowsPlayer or Application.platform == RuntimePlatform.WindowsEditor then
    do
      local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
      local min = ModuleFunSwitchInfo.MIN_TYPE_ID
      local max = ModuleFunSwitchInfo.MAX_TYPE_ID
      local noName = {}
      for i = min, max do
        local switchName = textRes.IDIP.PlayTypeName[i]
        if switchName == nil then
          table.insert(noName, i)
        end
      end
      if #noName > 0 then
        do
          local nonames = table.concat(noName, ",")
          local index = 1
          GameUtil.AddGlobalTimer(1, false, function()
            local id = noName[index]
            if id == nil then
              index = 1
              id = noName[index]
            end
            index = index + 1
            local tip = "Switch " .. "<font color=#ff0000>" .. id .. "</font>" .. " has NO NAME"
            Toast(tip)
          end)
          print("<color=red>Module init will stop there, please add a name for IDIP switch: " .. nonames .. "</color>")
          warn("<color=red>Module init will stop there, please add a name for IDIP switch: " .. nonames .. "</color>")
          error("<color=red>Module init will stop there, please add a name for IDIP switch: " .. nonames .. "</color>")
        end
      end
    end
  end
end
IDIPModule.Commit()
return IDIPModule
