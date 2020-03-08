local Lplus = require("Lplus")
local BaodianBasePanel = require("Main.Grow.ui.BaodianBasePanel")
local EquipUtils = require("Main.Equip.EquipUtils")
local BaodianUtils = require("Main.Grow.BaodianUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local EquipMainPanel = require("Main.Equip.ui.EquipSocialPanel")
local BaodianEquipPanel = Lplus.Extend(BaodianBasePanel, "BaodianEquipPanel")
local def = BaodianEquipPanel.define
def.field("table").mChooseListData = nil
def.field("table").mEquipListData = nil
def.field("table").mEquipInfos = nil
def.field("number").mCurSelectId = 0
def.field("number").mCurEquipId = 0
def.field("boolean").mIsDownSelect = false
def.field("table").mUIObjs = nil
def.field("userdata").mParent = nil
local instance
def.static("=>", BaodianEquipPanel).Instance = function()
  if instance == nil then
    instance = BaodianEquipPanel()
  end
  return instance
end
def.override("userdata").ShowPanel = function(self, parentPanel)
  if self:IsShow() then
    return
  end
  self.mParent = parentPanel
  GameUtil.AddGlobalLateTimer(0, true, function()
    self:CreatePanel(RESPATH.PREFAB_BAODIAN_EQUIP, 2)
  end)
end
def.override().OnCreate = function(self)
  if self.mParent == nil or self.mParent.isnil == true then
    self:DestroyPanel()
    return
  end
  self:InitData()
  self:InitUI()
  self:UpdateView()
  self:SetChooseBtn()
end
def.method().InitUI = function(self)
  local GroupChoose = self.m_panel:FindDirect("Group_Choose")
  self.mUIObjs = {}
  self.mUIObjs.ChooseBtn = GroupChoose:FindDirect("Btn_EquipChoose")
  self.mUIObjs.UpSprite = self.mUIObjs.ChooseBtn:FindDirect("Img_Up")
  self.mUIObjs.DownSprite = self.mUIObjs.ChooseBtn:FindDirect("Img_Down")
  self.mUIObjs.EquipChoose = GroupChoose:FindDirect("Group_EquipChoose")
  self.mUIObjs.ChooseScrollView = GroupChoose:FindDirect("Group_EquipChoose/Scroll View")
  self.mUIObjs.ChooseListView = self.mUIObjs.ChooseScrollView:FindDirect("List_EquipChoose")
  self.mUIObjs.EquipBg = self.m_panel:FindDirect("Group_List")
  self.mUIObjs.EquipListView = self.mUIObjs.EquipBg:FindDirect("Scroll View/List")
end
def.method().InitData = function(self)
  if self.mChooseListData ~= nil and self.mEquipListData ~= nil then
    return
  end
  self.mChooseListData = BaodianUtils.GetAllSelectIdAndName()
  self.mChooseListData[0] = textRes.Grow[1]
  self.mCurSelectId = 0
  self.mEquipListData = BaodianUtils.GetAllEquipIdBySelectId(self.mCurSelectId)
  self.mCurEquipId = self.mEquipListData[1]
  self:SetEquipInfos()
  self.mCurSelectId = 1
  self.mEquipListData = BaodianUtils.GetAllEquipIdBySelectId(self.mCurSelectId)
end
def.method().SetEquipInfos = function(self)
  self.mEquipInfos = {}
  for _, v in pairs(self.mEquipListData) do
    local equipInfo = EquipUtils.GetEquipDetailsInfo(v)
    self.mEquipInfos[v] = equipInfo
  end
end
def.method().UpdateView = function(self)
  self:UpdateChooseListView()
  self:UpdateEquipListView()
  self:UpdateRightDetailView()
end
def.method().UpdateEquipListData = function(self)
  local equips = BaodianUtils.GetAllEquipIdBySelectId(self.mCurSelectId)
  if equips == nil then
    return
  end
  self.mEquipListData = equips
  self.mCurEquipId = self.mEquipListData[1]
end
def.method().SetChooseBtn = function(self)
  local chooseLabelName = self.mChooseListData[self.mCurSelectId]
  self.mUIObjs.ChooseBtn:FindDirect("Label_Btn"):GetComponent("UILabel").text = chooseLabelName
  self:SetDownUpSprite(false)
  self.mUIObjs.EquipChoose:SetActive(false)
end
def.method().UpdateChooseListView = function(self)
  local selectNum = self.mChooseListData and require("Common.MathHelper").CountTable(self.mChooseListData) or 0
  if selectNum > 60 then
    selectNum = 60
  end
  GUIUtils.Reposition(self.mUIObjs.ChooseListView, "UIList", 0)
  local selectItems = GUIUtils.InitUIList(self.mUIObjs.ChooseListView, selectNum)
  for i = 1, selectNum do
    local ListItem = selectItems[i]
    local labelName = "Label" .. string.format("_%d", i)
    local curSelectName = self.mChooseListData[i - 1]
    ListItem.name = string.format("SelectId_%d", i - 1)
    ListItem:FindDirect(labelName):GetComponent("UILabel").text = curSelectName
    self.m_msgHandler:Touch(ListItem)
  end
  GUIUtils.Reposition(self.mUIObjs.ChooseListView, "UIList", 0)
end
def.method().UpdateEquipListView = function(self)
  self.mUIObjs.EquipBg:SetActive(true)
  local equipNum = #self.mEquipListData
  local List = self.mUIObjs.EquipListView:GetComponent("UIList")
  List.itemCount = equipNum
  local equipItems = GUIUtils.InitUIList(self.mUIObjs.EquipListView, equipNum)
  List:Reposition()
  for i = 1, equipNum do
    local equipItem = equipItems[i]
    equipItem.name = string.format("equipItem_%d", self.mEquipListData[i])
    local equipInfo = self.mEquipInfos[self.mEquipListData[i]]
    local iconId = equipInfo.equipInfo.iconId
    local name = equipInfo.equipInfo.name
    local level = equipInfo.equipInfo.useLevel
    local textureName = string.format("Img_BgIcon_%d", i) .. string.format("/Texture_Icon_%d", i)
    local uiTexture = equipItem:FindDirect(textureName):GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, iconId)
    local nameLabel = equipItem:FindDirect(string.format("Label_Name_%d", i)):GetComponent("UILabel")
    nameLabel.text = name
    local levelLabel = equipItem:FindDirect(string.format("Label_Lv_%d", i)):GetComponent("UILabel")
    levelLabel.text = tostring(level) .. textRes.Grow[2]
    self.m_msgHandler:Touch(equipItem)
    if i == 1 then
      equipItem:GetComponent("UIToggle").value = true
    end
  end
  GUIUtils.Reposition(self.mUIObjs.EquipListView, "UIList", 0)
  self.mUIObjs.EquipListView:GetComponent("UIList"):DragToMakeVisible(0, 100)
end
def.method().UpdateRightDetailView = function(self)
  if self.mCurEquipId <= 0 then
    return
  end
  local DetailBg = self.m_panel:FindDirect("Group_Detail")
  local iconTexture = DetailBg:FindDirect("Group_Equip/Img_BgIcon/Texture_Icon"):GetComponent("UITexture")
  local levelLabel = DetailBg:FindDirect("Group_Equip/Label_Lv"):GetComponent("UILabel")
  local nameLabel = DetailBg:FindDirect("Group_Equip/Label_Name"):GetComponent("UILabel")
  local typeLabel = DetailBg:FindDirect("Group_Equip/Label_Type"):GetComponent("UILabel")
  local equipInfo = self.mEquipInfos[self.mCurEquipId]
  GUIUtils.FillIcon(iconTexture, equipInfo.equipInfo.iconId)
  levelLabel.text = tostring(equipInfo.equipInfo.useLevel) .. textRes.Grow[2]
  nameLabel.text = equipInfo.equipInfo.name
  typeLabel.text = ItemUtils.GetItemBase(self.mCurEquipId).itemTypeName
  local lingTable, hunTable, hunNum = BaodianUtils.GetEquipDetaiInfo(self.mCurEquipId)
  local qilinMaxLevel = EquipUtils.GetQiLingMaxLevel(equipInfo.equipInfo.useLevel)
  self:UpdateLingView(DetailBg, lingTable, qilinMaxLevel)
  self:UpdateHunView(DetailBg, hunTable, hunNum)
  self:UpdateChannel(DetailBg)
end
def.method("userdata", "table", "number").UpdateLingView = function(self, DetailBg, lingTable, qilinMaxLevel)
  local lingName1 = DetailBg:FindDirect("Group_Ling/Label_Ling1"):GetComponent("UILabel")
  local lingAttr1 = DetailBg:FindDirect("Group_Ling/Label_LingNum1"):GetComponent("UILabel")
  local lingName2 = DetailBg:FindDirect("Group_Ling/Label_Ling2"):GetComponent("UILabel")
  local lingAttr2 = DetailBg:FindDirect("Group_Ling/Label_LingNum2"):GetComponent("UILabel")
  local lingMaxLabel = DetailBg:FindDirect("Group_Ling/Label_LingLimit/Label_Num"):GetComponent("UILabel")
  local ling1 = lingTable[1]
  if ling1[1] == ":" then
    ling1[1] = ""
    ling1[2] = ""
  end
  lingName1.text = ling1[1]
  lingAttr1.text = ling1[2]
  local ling2 = lingTable[2]
  if ling2[1] == ":" then
    ling2[1] = ""
    ling2[2] = ""
  end
  lingName2.text = ling2[1]
  lingAttr2.text = ling2[2]
  lingMaxLabel:set_text(" " .. qilinMaxLevel)
end
def.method("userdata", "table", "string").UpdateHunView = function(self, DetailBg, hunTable, hunRanNum)
  local ListView = DetailBg:FindDirect("Group_Hun/Scroll View/List")
  local hunNum = #hunTable
  local HunItems = GUIUtils.InitUIList(ListView, hunNum)
  for i = 1, hunNum do
    local hunItem = HunItems[i]
    local hunName = hunItem:FindDirect(string.format("Label_Name_%d", i)):GetComponent("UILabel")
    local hunAttr = hunItem:FindDirect(string.format("Label_Num_%d", i)):GetComponent("UILabel")
    local hunInfo = hunTable[i]
    hunName.text = hunInfo[1]
    hunAttr.text = hunInfo[2]
  end
  GUIUtils.Reposition(ListView, "UIList", 0)
  local hunTip = DetailBg:FindDirect("Group_Hun/Label_Tip"):GetComponent("UILabel")
  hunTip.text = string.format(textRes.Grow[3], hunRanNum)
end
def.method("userdata").UpdateChannel = function(self, DetailBg)
  local channel1 = DetailBg:FindDirect("Group_Chanel/Btn_Chanel1/Label")
  if self.mCurSelectId < 5 then
    DetailBg:FindDirect("Group_Chanel/Btn_Chanel1"):SetActive(true)
    local npcId = BaodianUtils.GetNpcId(self.mCurSelectId, self.mCurEquipId)
    local shopname = BaodianUtils.GetNPCShopName(npcId)
    channel1:GetComponent("UILabel").text = shopname
  elseif self.mCurSelectId < 8 then
    DetailBg:FindDirect("Group_Chanel/Btn_Chanel1"):SetActive(true)
    channel1:GetComponent("UILabel").text = textRes.Grow[6]
  else
    DetailBg:FindDirect("Group_Chanel/Btn_Chanel1"):SetActive(false)
  end
end
def.method("number").SetCurSelectId = function(self, select)
  self.mCurSelectId = select
end
def.method("number").SetCurEquipId = function(self, equip)
  self.mCurEquipId = equip
end
def.method("string").onClick = function(self, id)
  if id == "Btn_EquipChoose" then
    if self.mIsDownSelect then
      self:SetChooseBtn()
      self:SetDownUpSprite(false)
    else
      self.mUIObjs.EquipChoose:SetActive(true)
      self:SetDownUpSprite(true)
    end
  elseif string.find(id, "SelectId_") then
    local strs = string.split(id, "_")
    local newSelectId = tonumber(strs[2])
    self:SetCurSelectId(newSelectId)
    self:UpdateEquipListData()
    self:SetChooseBtn()
    self:UpdateEquipListView()
    self:UpdateRightDetailView()
  elseif string.find(id, "equipItem_") then
    local strs = string.split(id, "_")
    local newEquipId = tonumber(strs[2])
    self:SetCurEquipId(newEquipId)
    self:UpdateRightDetailView()
  elseif id == "Btn_Chanel2" then
    local hp = require("Main.Hero.HeroModule").Instance()
    local heroLevel = hp:GetHeroProp().level
    local openLevel = EquipUtils.GetEquipOpenMinLevel()
    if heroLevel < openLevel then
      Toast(string.format(textRes.Grow[4], openLevel))
    else
      EquipMainPanel.ShowSocialPanel(EquipMainPanel.StateConst.EquipMake)
    end
  elseif id == "Btn_Chanel1" then
    self:DestroyPanel()
    require("Main.Grow.ui.GrowGuidePanel").Instance():DestroyPanel()
    if self.mCurSelectId < 5 then
      local npcId = BaodianUtils.GetNpcId(self.mCurSelectId, self.mCurEquipId)
      Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npcId})
    else
      Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {150100198})
    end
  end
end
def.method("boolean").SetDownUpSprite = function(self, setUp)
  if setUp then
    self.mIsDownSelect = true
    self.mUIObjs.UpSprite:SetActive(true)
    self.mUIObjs.DownSprite:SetActive(false)
  else
    self.mIsDownSelect = false
    self.mUIObjs.UpSprite:SetActive(false)
    self.mUIObjs.DownSprite:SetActive(true)
  end
end
def.override().ReleaseUI = function(self)
  if self.mUIObjs then
    for k, v in pairs(self.mUIObjs) do
      k = nil
    end
    self.mUIObjs = nil
  end
end
def.override().OnDestroy = function(self)
  self:ReleaseUI()
  self.mChooseListData = nil
  self.mEquipListData = nil
  self.mEquipInfos = nil
  self.mCurSelectId = 0
  self.mCurEquipId = 0
  self.mIsDownSelect = false
  self.mParent = nil
end
BaodianEquipPanel.Commit()
return BaodianEquipPanel
