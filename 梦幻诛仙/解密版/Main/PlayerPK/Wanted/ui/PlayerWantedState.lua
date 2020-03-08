local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PlayerWantedState = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Cls = PlayerWantedState
local def = Cls.define
local instance
local WantedMgr = require("Main.PlayerPK.WantedMgr")
local GUIUtils = require("GUI.GUIUtils")
local txtConst = textRes.PlayerPK.PlayerWanted
def.field("table")._uiGOs = nil
def.field("table")._roleInfo = nil
def.static("=>", Cls).Instance = function()
  if instance == nil then
    instance = Cls()
  end
  return instance
end
def.override().OnCreate = function(self)
  self._uiGOs = {}
  self._uiGOs.lblPower = self.m_panel:FindDirect("Img_Bg0/Group_Info/Label_Num01")
  self._uiGOs.lblLocation = self.m_panel:FindDirect("Img_Bg0/Group_Info/Label_Num02")
  self._uiGOs.lblTeam = self.m_panel:FindDirect("Img_Bg0/Group_Info/Label_Num03")
  self._uiGOs.imgHeadFrame = self.m_panel:FindDirect("Img_Bg0/Img_Head")
  self._uiGOs.imgHead = self.m_panel:FindDirect("Img_Bg0/Img_Head/Img_BigHead")
  self._uiGOs.lblName = self.m_panel:FindDirect("Img_Bg0/Group_Name/Label_Name")
  self._uiGOs.lblLv = self.m_panel:FindDirect("Img_Bg0/Group_Name/Label_Level")
  self._uiGOs.imgOccup = self.m_panel:FindDirect("Img_Bg0/Group_Name/Img_MenPai")
  self._uiGOs.imgSex = self.m_panel:FindDirect("Img_Bg0/Group_Name/Img_Sex")
  Event.RegisterEventWithContext(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.PlayerWanted.RcvWantedStateData, Cls.OnRcvQueryData, self)
  WantedMgr.QueryPlayerWantedState(self._roleInfo.roleId)
  self:_initUI()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.PlayerWanted.RcvWantedStateData, Cls.OnRcvQueryData)
  self._uiGOs = nil
  self._roleInfo = nil
end
def.method()._initUI = function(self)
  local roleInfo = self._roleInfo
  local uiGOs = self._uiGOs
  _G.SetAvatarIcon(uiGOs.imgHead, roleInfo.avatarId)
  _G.SetAvatarFrameIcon(uiGOs.imgHeadFrame, roleInfo.avatarFrameId)
  GUIUtils.SetText(uiGOs.lblName, roleInfo.name)
  GUIUtils.SetText(uiGOs.lblLv, roleInfo.level)
  GUIUtils.SetSprite(uiGOs.imgOccup, GUIUtils.GetOccupationSmallIcon(roleInfo.occup))
  GUIUtils.SetSprite(uiGOs.imgSex, GUIUtils.GetGenderSprite(roleInfo.sex))
  self:_updateUI()
end
def.method()._updateUI = function(self)
  local roleInfo = self._roleInfo
  local uiGOs = self._uiGOs
  if roleInfo.power == nil then
    GUIUtils.SetText(uiGOs.lblPower, txtConst[32])
  else
    GUIUtils.SetText(uiGOs.lblPower, roleInfo.power)
  end
  if roleInfo.mapId == nil then
    GUIUtils.SetText(uiGOs.lblLocation, txtConst[32])
  else
    local mapCfg = require("Main.Map.MapUtility").GetMapCfg(roleInfo.mapId)
    if mapCfg then
      GUIUtils.SetText(uiGOs.lblLocation, mapCfg.mapName)
    else
      GUIUtils.SetText(uiGOs.lblLocation, txtConst[32])
    end
  end
  if roleInfo.teamMemberCount == nil then
    GUIUtils.SetText(uiGOs.lblTeam, txtConst[32])
  elseif roleInfo.teamMemberCount == 0 then
    GUIUtils.SetText(uiGOs.lblTeam, txtConst[33])
  else
    GUIUtils.SetText(uiGOs.lblTeam, roleInfo.teamMemberCount .. "/5")
  end
end
def.method("table").ShowPanel = function(self, roleInfo)
  if roleInfo == nil then
    return
  end
  self._roleInfo = roleInfo
  self:CreatePanel(RESPATH.PREFAB_WANTED_STATE, 2)
  self:SetOutTouchDisappear()
end
def.method("string").onClick = function(self, id)
  if id == "Img_State" then
    WantedMgr.QueryPlayerWantedState(self._roleInfo.roleId)
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  end
end
def.method("table").OnRcvQueryData = function(self, p)
  self._roleInfo.mapId = p.mapId
  self._roleInfo.power = p.power
  self._roleInfo.teamMemberCount = p.teamMemberCount
  self:_updateUI()
end
return Cls.Commit()
