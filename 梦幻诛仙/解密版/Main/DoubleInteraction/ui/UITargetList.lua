local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UITargetList = Lplus.Extend(ECPanelBase, "UITargetList")
local Cls = UITargetList
local def = UITargetList.define
local instance
local InteractionModule = require("Main.DoubleInteraction.DoubleInteractionModule")
local InteractionUtils = require("Main.DoubleInteraction.DoubleInteractionUtils")
local GUIUtils = require("GUI.GUIUtils")
local txtConst = textRes.DoubleInteraction
local const = constant.CInteractionConsts
def.field("table")._playerList = nil
def.field("table")._actionCfg = nil
def.field("table")._uiStatus = nil
def.static("=>", UITargetList).Instance = function()
  if instance == nil then
    instance = UITargetList()
  end
  return instance
end
def.override().OnCreate = function(self)
  self:_initTitle()
  self:_registerEvents()
end
def.override().OnDestroy = function(self)
  if self._uiStatus.timer ~= 0 then
    _G.GameUtil.RemoveGlobalTimer(self._uiStatus.timer)
  end
  self:_unregisterEvents()
  self._actionCfg = nil
  self._playerList = nil
  self._uiStatus = nil
end
def.method()._registerEvents = function(self)
  Event.RegisterEventWithContext(ModuleId.DOUBLE_INTERACTION, gmodule.notifyId.DoubleInteraction.GetRoleList, Cls.OnGetRolelist, self)
end
def.method()._unregisterEvents = function(self)
  Event.UnregisterEvent(ModuleId.DOUBLE_INTERACTION, gmodule.notifyId.DoubleInteraction.GetRoleList, Cls.OnGetRolelist)
end
def.override("boolean").OnShow = function(self, s)
  if s then
    self:_initTargetList()
  end
end
def.method()._initTitle = function(self)
  local lblActionName = self.m_panel:FindDirect("Img_Bg0/Label_Emoji")
  GUIUtils.SetText(lblActionName, self._actionCfg.name)
end
def.method()._pullNewList = function(self)
  InteractionModule.CSendPullRoleList(self._actionCfg.id)
end
def.method()._initTargetList = function(self)
  local ctrlScrollView = self.m_panel:FindDirect("Img_Bg0/Container_Players/Scroll View_Friend")
  local ctrlUIList = ctrlScrollView:FindDirect("List_Player")
  local numPlayers = #self._playerList
  local ctrlPlayList = GUIUtils.InitUIList(ctrlUIList, numPlayers)
  for i = 1, numPlayers do
    self:_fillPlayerInfo(ctrlPlayList[i], self._playerList[i], i)
  end
  if self._uiStatus.timer ~= 0 then
    _G.GameUtil.RemoveGlobalTimer(self._uiStatus.timer)
    self._uiStatus.timer = 0
  end
  local time = const.REFRESH_TARGET_LIST_CD
  local lblTime = self.m_panel:FindDirect("Img_Bg0/Btn_Refresh/Label_CountDown")
  GUIUtils.SetText(lblTime, txtConst[2]:format(time))
  self._uiStatus.timer = _G.GameUtil.AddGlobalTimer(1, false, function()
    time = time - 1
    GUIUtils.SetText(lblTime, txtConst[2]:format(time))
    if time <= 0 then
      self:_pullNewList()
      _G.GameUtil.RemoveGlobalTimer(self._uiStatus.timer)
      self._uiStatus.timer = 0
    end
  end)
end
def.method("userdata", "table", "number")._fillPlayerInfo = function(self, ctrl, cfg, idx)
  local imgOccup = ctrl:FindDirect("Img_PlayerSchool_" .. idx)
  local imgGender = ctrl:FindDirect("Img_PlayerSex_" .. idx)
  local imgHead = ctrl:FindDirect("Img_PlayerIconHead_" .. idx)
  local lblLv = imgHead:FindDirect("Label_Level_" .. idx)
  local lblName = ctrl:FindDirect("Label_Name_" .. idx)
  GUIUtils.SetSprite(imgOccup, GUIUtils.GetOccupationSmallIcon(cfg.occupation_id))
  GUIUtils.SetSprite(imgGender, GUIUtils.GetSexIcon(cfg.gender))
  _G.SetAvatarIcon(imgHead, cfg.avatar_id)
  GUIUtils.SetText(lblLv, cfg.role_level)
  GUIUtils.SetText(lblName, _G.GetStringFromOcts(cfg.role_name))
end
def.method("number", "table").ShowPanel = function(self, actionId, playerList)
  self._uiStatus = {}
  self._uiStatus.timer = 0
  self._actionCfg = InteractionUtils.GetCfgById(actionId)
  self._playerList = playerList
  self:CreatePanel(RESPATH.PREFAB_PLAYER_LIST, 1)
  self:SetModal(true)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if string.find(id, "Btn_Player_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[3])
    self:onClickPlayer(idx)
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  end
end
def.method("number").onClickPlayer = function(self, idx)
  local roleInfo = self._playerList[idx]
  InteractionModule.CSendInviteReq(roleInfo.role_id, self._actionCfg.id)
  self:DestroyPanel()
end
def.method("table").OnGetRolelist = function(self, p)
  self._playerList = p
  if self:IsShow() then
    self:_initTargetList()
  end
end
return UITargetList.Commit()
