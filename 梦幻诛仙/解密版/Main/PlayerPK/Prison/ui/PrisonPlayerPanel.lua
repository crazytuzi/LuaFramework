local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PlayerPrisonPanel = Lplus.Extend(ECPanelBase, "PlayerPrisonPanel")
local GUIUtils = require("GUI.GUIUtils")
local def = PlayerPrisonPanel.define
def.field("table").uiObjs = nil
def.field("number").curPage = 1
def.field("number").totalPage = 1
def.field("table").prisonPlayerData = nil
local instance
def.static("=>", PlayerPrisonPanel).Instance = function()
  if instance == nil then
    instance = PlayerPrisonPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_PRISON_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:QueryPlayerDataByPage(self.curPage)
  self:UpdatePageContent()
  Event.RegisterEvent(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.Prison.Receive_Prison_Data, PlayerPrisonPanel.OnReceivePrisonData)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, PlayerPrisonPanel.OnEnterFight)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.curPage = 1
  self.totalPage = 1
  self.prisonPlayerData = nil
  Event.UnregisterEvent(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.Prison.Receive_Prison_Data, PlayerPrisonPanel.OnReceivePrisonData)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, PlayerPrisonPanel.OnEnterFight)
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
  GUIUtils.SetText(self.uiObjs.Label_Tips, textRes.PlayerPK.PlayerPrison[9])
  GUIUtils.SetText(self.uiObjs.Label_Tips1, textRes.PlayerPK.PlayerPrison[10])
end
def.method("number").QueryPlayerDataByPage = function(self, page)
  local PrisonMgr = require("Main.PlayerPK.PrisonMgr")
  PrisonMgr.Instance():QueryPrisonPlayerData(page)
end
def.method("table").SetPrisonPlayerData = function(self, data)
  self.prisonPlayerData = data.players
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
  local Label_Num = item:FindDirect(string.format("Label_Time_%d/Label_Num_%d", idx, idx))
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
  local endTime = player:GetPrisonEndTime()
  local curTime = _G.GetServerTime()
  local leftTime = math.max(0, endTime - curTime)
  local leftTimeTbl = _G.Seconds2HMSTime(leftTime)
  GUIUtils.SetText(Label_Num, string.format(textRes.PlayerPK.PlayerPrison[11], leftTimeTbl.h, leftTimeTbl.m, leftTimeTbl.s))
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
  if self.prisonPlayerData == nil or self.prisonPlayerData[idx] == nil then
    return
  end
  local player = self.prisonPlayerData[idx]
  local PrisonMgr = require("Main.PlayerPK.PrisonMgr")
  PrisonMgr.Instance():ResucuePlayer(player)
end
def.method().OnClickBtnTips = function(self)
  GUIUtils.ShowHoverTip(constant.CPKConsts.BOUNTY_BOARD_TIP_ID)
end
def.static("table", "table").OnReceivePrisonData = function(params, context)
  local self = instance
  self:SetPrisonPlayerData(params)
end
def.static("table", "table").OnEnterFight = function(params, context)
  local self = instance
  self:DestroyPanel()
end
PlayerPrisonPanel.Commit()
return PlayerPrisonPanel
