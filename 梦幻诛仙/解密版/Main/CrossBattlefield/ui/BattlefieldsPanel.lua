local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BattlefieldsPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local CrossBattlefieldModule = require("Main.CrossBattlefield.CrossBattlefieldModule")
local crossBattlefieldModule = CrossBattlefieldModule.Instance()
local ItemUtils = require("Main.Item.ItemUtils")
local def = BattlefieldsPanel.define
def.const("number").AWARD_MAX_SHOW_NUM = 4
def.field("table").m_UIGOs = nil
def.field("number").m_selIndex = 0
def.field("table").m_battlefields = nil
def.field("table").m_awards = nil
local instance
def.static("=>", BattlefieldsPanel).Instance = function()
  if instance == nil then
    instance = BattlefieldsPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method().ShowPanel = function(self)
  if self:IsLoaded() then
    self:DestroyPanel()
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_CROSS_BATTLEFIELDS_PANEL, 1)
end
def.override().OnCreate = function(self)
  self:InitUI()
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  self.m_selIndex = 0
  self.m_battlefields = nil
  self.m_awards = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  local parentName = obj.parent.name
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_SingleMatch" then
    self:OnClickMatchBtn()
  elseif id == "Btn_Help" then
    self:OnClickTipsBtn()
  elseif id:find("Item_Battle_") then
    local strs = id:split("_")
    local index = tonumber(strs[3])
    if index then
      self:SelectBattlefieldByIndex(index)
    end
  elseif parentName == "List_Reward" then
    local index = tonumber(id:split("_")[2])
    if index then
      self:OnClickAwardItem(index, obj)
    end
  end
end
def.override("boolean").OnShow = function(self, s)
  if s then
    self:UpdateUI()
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_UIGOs.Group_Battle = self.m_UIGOs.Img_Bg:FindDirect("Group_Battle")
  self.m_UIGOs.Group_Details = self.m_UIGOs.Img_Bg:FindDirect("Group_Details")
  self.m_UIGOs.Scrollview_Battle = self.m_UIGOs.Group_Battle:FindDirect("Scrollview_Battle")
  self.m_UIGOs.List_Battle = self.m_UIGOs.Scrollview_Battle:FindDirect("List_Battle")
  self.m_UIGOs.Label_PointsNum = self.m_UIGOs.Group_Details:FindDirect("Group_Points/Label_PointsNum")
end
def.method().UpdateUI = function(self)
  self:UpdateBattlefields()
  self:UpdateBattlefieldAwards()
  if self.m_selIndex == 0 then
    self:SelectBattlefieldByIndex(1)
  end
  self:UpdateWeekScore()
end
def.method().UpdateWeekScore = function(self)
  local CrossBattlefieldSeasonMgr = require("Main.CrossBattlefield.CrossBattlefieldSeasonMgr")
  local seasonMgr = CrossBattlefieldSeasonMgr.Instance()
  local weekScore = seasonMgr:GetWeekPoint()
  self.m_UIGOs.Label_PointsNum:GetComponent("UILabel"):set_text(weekScore)
end
def.method().UpdateBattlefields = function(self)
  local battlefields = self:GetBattlefieldViewdatas()
  self.m_battlefields = battlefields
  self:SetBattlefields(battlefields)
end
def.method("table").SetBattlefields = function(self, battlefields)
  local uiList = self.m_UIGOs.List_Battle:GetComponent("UIList")
  local itemCount = #battlefields
  uiList.itemCount = itemCount
  uiList:Resize()
  for index, battlefield in ipairs(battlefields) do
    self:SetBattlefieldInfo(index, battlefield)
  end
end
def.method("number", "table").SetBattlefieldInfo = function(self, index, battlefield)
  local groupGO = self.m_UIGOs.List_Battle:FindDirect("Item_Battle_" .. index)
  local Group_Lock = groupGO:FindDirect("Group_Lock_" .. index)
  local Img_Battle = groupGO:FindDirect("Img_Battle_" .. index)
  local Group_Title = groupGO:FindDirect("Group_Title_" .. index)
  local Group_Num = groupGO:FindDirect("Group_Num_" .. index)
  local Label_BattleNum = Group_Num:FindDirect("Label_Battle_" .. index)
  GUIUtils.SetActive(Group_Num, not battlefield.comming)
  GUIUtils.SetActive(Group_Lock, battlefield.comming)
  if battlefield.comming then
    return
  end
  GUIUtils.SetText(Label_BattleNum, battlefield.numInfo)
  GUIUtils.SetTexture(Img_Battle, battlefield.icon)
end
def.method("number").SelectBattlefieldByIndex = function(self, index)
  local battlefield = self.m_battlefields[index]
  if battlefield == nil then
    return
  end
  if battlefield.comming then
    local lastIndex = self.m_selIndex
    if lastIndex ~= 0 then
      local groupGO = self.m_UIGOs.List_Battle:FindDirect("Item_Battle_" .. lastIndex)
      GUIUtils.Toggle(groupGO, true)
    else
      local groupGO = self.m_UIGOs.List_Battle:FindDirect("Item_Battle_" .. index)
      GUIUtils.Toggle(groupGO, false)
    end
    return
  end
  self.m_selIndex = index
  self:SetBattlefieldDetailInfo(battlefield)
  local groupGO = self.m_UIGOs.List_Battle:FindDirect("Item_Battle_" .. index)
  GUIUtils.Toggle(groupGO, true)
end
def.method("table").SetBattlefieldDetailInfo = function(self, battlefield)
  self:SetBattlefieldDesc(battlefield.desc)
end
def.method("string").SetBattlefieldDesc = function(self, desc)
  local Label_Info = self.m_UIGOs.Group_Battle:FindDirect("Group_Info/Label_Info")
  GUIUtils.SetText(Label_Info, desc)
end
def.method().UpdateBattlefieldAwards = function(self)
  local awardItems = {}
  local function addAwardItem(itemId)
    if itemId > 0 then
      table.insert(awardItems, {itemId = itemId})
    end
  end
  addAwardItem(constant.CCrossFieldConsts.PREVIEW_ITEM_CFG_ID_1)
  addAwardItem(constant.CCrossFieldConsts.PREVIEW_ITEM_CFG_ID_2)
  addAwardItem(constant.CCrossFieldConsts.PREVIEW_ITEM_CFG_ID_3)
  addAwardItem(constant.CCrossFieldConsts.PREVIEW_ITEM_CFG_ID_4)
  self:SetBattlefieldAwards(awardItems)
end
def.method("table").SetBattlefieldAwards = function(self, awards)
  awards = awards or {}
  self.m_awards = awards
  local Group_Reward = self.m_UIGOs.Group_Details:FindDirect("Group_Reward")
  local List_Reward = Group_Reward:FindDirect("List_Reward")
  local uiList = List_Reward:GetComponent("UIList")
  local itemCount = math.min(BattlefieldsPanel.AWARD_MAX_SHOW_NUM, #awards)
  uiList.itemCount = itemCount
  uiList:Resize()
  local children = uiList.children
  for i = 1, itemCount do
    local groupGO = children[i]
    local awardInfo = awards[i]
    self:SetAwardItemInfo(groupGO, awardInfo)
  end
end
def.method("userdata", "table").SetAwardItemInfo = function(self, groupGO, itemInfo)
  local Img_Icon = groupGO:FindDirect("Img_Icon")
  local Label_Number = groupGO:FindDirect("Label_Number")
  local iconId = itemInfo.iconId
  if itemInfo.itemId then
    local itemBase = ItemUtils.GetItemBase(itemInfo.itemId)
    if itemBase then
      iconId = itemBase.icon
    end
  end
  GUIUtils.SetTexture(Img_Icon, iconId)
  GUIUtils.SetText(Label_Number, itemInfo.num or "")
end
def.method().OnClickMatchBtn = function(self)
  local battlefield = self.m_battlefields[self.m_selIndex]
  if battlefield == nil then
    print("no selected battlefield!")
    return
  end
  crossBattlefieldModule:StartMatch(battlefield.id)
end
def.method().OnClickTipsBtn = function(self)
  local battlefield = self.m_battlefields[self.m_selIndex]
  if battlefield == nil then
    print("no selected battlefield!")
    return
  end
  local tipId = battlefield.tipId
  GUIUtils.ShowHoverTip(tipId, 0, 0)
end
def.method("number", "userdata").OnClickAwardItem = function(self, index, obj)
  local awardItem = self.m_awards[index]
  if awardItem.itemId then
    local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(awardItem.itemId, obj, 0, false)
  end
end
def.method("=>", "table").GetBattlefieldViewdatas = function(self)
  local battlefieldCfgs = crossBattlefieldModule:GetVisibleBattlefields()
  local battlefields = {}
  for i, v in ipairs(battlefieldCfgs) do
    local battlefield = {}
    battlefield.id = v.id
    battlefield.name = v.field_name
    battlefield.desc = v.field_desc
    local halfRoleNum = v.role_num / 2
    battlefield.numInfo = string.format(textRes.CrossBattlefield[4], halfRoleNum, halfRoleNum)
    battlefield.icon = v.icon_id
    battlefield.tipId = v.tips_id
    table.insert(battlefields, battlefield)
  end
  table.insert(battlefields, {comming = true})
  return battlefields
end
return BattlefieldsPanel.Commit()
