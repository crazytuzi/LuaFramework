local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PlayerWantedPanel = Lplus.Extend(ECPanelBase, "PlayerWantedPanel")
local GUIUtils = require("GUI.GUIUtils")
local def = PlayerWantedPanel.define
def.field("table").uiObjs = nil
def.field("number").curPage = 1
def.field("number").totalPage = 1
def.field("table").wantedPlayerData = nil
local instance
def.static("=>", PlayerWantedPanel).Instance = function()
  if instance == nil then
    instance = PlayerWantedPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_WANTED_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:QueryPlayerDataByPage(self.curPage)
  self:UpdatePageContent()
  Event.RegisterEvent(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.PlayerWanted.Receive_Wanted_Data, PlayerWantedPanel.OnReceiveWantedData)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, PlayerWantedPanel.OnEnterFight)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.curPage = 1
  self.totalPage = 1
  self.wantedPlayerData = nil
  Event.UnregisterEvent(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.PlayerWanted.Receive_Wanted_Data, PlayerWantedPanel.OnReceiveWantedData)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, PlayerWantedPanel.OnEnterFight)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Label_Tips = self.uiObjs.Img_Bg0:FindDirect("Label_Tips")
  self.uiObjs.Label_Tips1 = self.uiObjs.Img_Bg0:FindDirect("Label_Tips1")
  self.uiObjs.Group_Page = self.uiObjs.Img_Bg0:FindDirect("Group_Page")
  self.uiObjs.Group_NoData = self.uiObjs.Img_Bg0:FindDirect("Group_NoData")
  self.uiObjs.Img_NameList = self.uiObjs.Img_Bg0:FindDirect("Img_NameList/Scroll View/List")
  local uiList = self.uiObjs.Img_NameList:GetComponent("UIList")
  uiList.itemCount = 0
  uiList:Resize()
  GUIUtils.SetText(self.uiObjs.Label_Tips, string.format(textRes.PlayerPK.PlayerWanted[3], constant.CPKConsts.ARREST_LEVEL_DIFF))
  GUIUtils.SetText(self.uiObjs.Label_Tips1, textRes.PlayerPK.PlayerWanted[4])
end
def.method("number").QueryPlayerDataByPage = function(self, page)
  local WantedMgr = require("Main.PlayerPK.WantedMgr")
  WantedMgr.Instance():QueryPlayerWantedData(page)
end
def.method("table").SetWantedPlayerData = function(self, data)
  self.wantedPlayerData = data.players
  local players = data.players
  local uiList = self.uiObjs.Img_NameList:GetComponent("UIList")
  uiList.itemCount = #players
  uiList:Resize()
  if #players == 0 then
    GUIUtils.SetActive(self.uiObjs.Group_NoData, true)
    GUIUtils.SetActive(self.uiObjs.Group_Page, false)
    return
  else
    GUIUtils.SetActive(self.uiObjs.Group_NoData, false)
    GUIUtils.SetActive(self.uiObjs.Group_Page, true)
  end
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local uiItem = uiItems[i]
    self:FillPlayerInfo(i, uiItem, players[i])
  end
  self.curPage = data.curPage
  self.totalPage = data.totalPage
  self:UpdatePageContent()
end
def.method("number", "userdata", "table").FillPlayerInfo = function(self, idx, item, player)
  local Img_Head = item:FindDirect(string.format("Img_Head_%d", idx))
  local Img_BigHead = Img_Head:FindDirect(string.format("Img_BigHead_%d", idx, idx))
  local Img_Coin = item:FindDirect(string.format("Label_Cost_%d/Img_Coin_%d", idx, idx))
  local Label_Cost = item:FindDirect(string.format("Label_Cost_%d/Label_Num_%d", idx, idx))
  local Label_Name = item:FindDirect(string.format("Group_Name_%d/Label_Name_%d", idx, idx))
  local Label_Level = item:FindDirect(string.format("Group_Name_%d/Label_Level_%d", idx, idx))
  local Img_MenPai = item:FindDirect(string.format("Group_Name_%d/Img_MenPai_%d", idx, idx))
  local Img_Sex = item:FindDirect(string.format("Group_Name_%d/Img_Sex_%d", idx, idx))
  Img_Head:GetComponent("UISprite").enabled = false
  _G.SetAvatarIcon(Img_BigHead, player:GetAvatarId(), player:GetAvatarFrameId())
  GUIUtils.SetText(Label_Name, player:GetName())
  GUIUtils.SetText(Label_Level, string.format(textRes.Common[3], player:GetLevel()))
  GUIUtils.SetSprite(Img_MenPai, GUIUtils.GetOccupationSmallIcon(player:GetOccupation()))
  GUIUtils.SetSprite(Img_Sex, GUIUtils.GetGenderSprite(player:GetSex()))
  local CurrencyFactory = require("Main.Currency.CurrencyFactory")
  local moneyData = CurrencyFactory.Create(constant.CPKConsts.ARREST_MONEY_TYPE)
  GUIUtils.SetSprite(Img_Coin, moneyData:GetSpriteName())
  GUIUtils.SetText(Label_Cost, constant.CPKConsts.ARREST_PRICE)
end
def.method().UpdatePageContent = function(self)
  local Label_Page = self.uiObjs.Group_Page:FindDirect("Img_BgPage/Label_Page")
  GUIUtils.SetText(Label_Page, string.format("%d/%d", self.curPage, self.totalPage))
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Next" then
    self:OnClickBtnNext()
  elseif id == "Btn_Back" then
    self:OnClickBtnBack()
  elseif string.find(id, "Img_Btn_") then
    local idx = tonumber(string.sub(id, #"Img_Btn_" + 1))
    self:OnClickBtnFight(idx)
  elseif id == "Btn_Tip" then
    self:OnClickBtnTips()
  elseif string.find(id, "Img_State_") then
    local idx = tonumber(string.sub(id, #"Img_State_" + 1))
    self:onClickCheckState(idx)
  end
end
def.method().OnClickBtnNext = function(self)
  if self.curPage >= self.totalPage then
    Toast(textRes.PlayerPK.PlayerWanted[2])
    return
  end
  self.curPage = self.curPage + 1
  self:QueryPlayerDataByPage(self.curPage)
  self:UpdatePageContent()
end
def.method().OnClickBtnBack = function(self)
  if self.curPage <= 1 then
    Toast(textRes.PlayerPK.PlayerWanted[1])
    return
  end
  self.curPage = self.curPage - 1
  self:QueryPlayerDataByPage(self.curPage)
  self:UpdatePageContent()
end
def.method("number").OnClickBtnFight = function(self, idx)
  if self.wantedPlayerData == nil or self.wantedPlayerData[idx] == nil then
    return
  end
  local player = self.wantedPlayerData[idx]
  local WantedMgr = require("Main.PlayerPK.WantedMgr")
  WantedMgr.Instance():FightWithWantedPlayer(player)
end
def.method("number").onClickCheckState = function(self, idx)
  if self.wantedPlayerData == nil or self.wantedPlayerData[idx] == nil then
    return
  end
  local player = self.wantedPlayerData[idx]
  local roleInfo = {}
  roleInfo.avatarId = player:GetAvatarId()
  roleInfo.avatarFrameId = player:GetAvatarFrameId()
  roleInfo.name = player:GetName()
  roleInfo.level = player:GetLevel()
  roleInfo.occup = player:GetOccupation()
  roleInfo.sex = player:GetSex()
  roleInfo.roleId = player:GetPlayerId()
  require("Main.PlayerPK.Wanted.ui.PlayerWantedState").Instance():ShowPanel(roleInfo)
end
def.method().OnClickBtnTips = function(self)
  GUIUtils.ShowHoverTip(constant.CPKConsts.BOUNTY_BOARD_TIP_ID)
end
def.static("table", "table").OnReceiveWantedData = function(params, context)
  local self = instance
  self:SetWantedPlayerData(params)
end
def.static("table", "table").OnEnterFight = function(params, context)
  local self = instance
  self:DestroyPanel()
end
PlayerWantedPanel.Commit()
return PlayerWantedPanel
