local Lplus = require("Lplus")
local BaodianBasePanel = require("Main.Grow.ui.BaodianBasePanel")
local BaodianUtils = require("Main.Grow.BaodianUtils")
local GUIUtils = require("GUI.GUIUtils")
local BaodianXianLvPanel = Lplus.Extend(BaodianBasePanel, "BaodianXianLvPanel")
local def = BaodianXianLvPanel.define
def.field("number").mCurXianLvId = 0
def.field("table").mXianLvIcons = nil
def.field("table").mCurCfg = nil
def.field("table").mAllXianLvIds = nil
def.field("number").mCurSelectSkillIndex = 0
def.field("userdata").mParent = nil
local instance
def.static("=>", BaodianXianLvPanel).Instance = function()
  if instance == nil then
    instance = BaodianXianLvPanel()
  end
  return instance
end
def.override("userdata").ShowPanel = function(self, parentPanel)
  if self:IsShow() then
    return
  end
  self.mParent = parentPanel
  GameUtil.AddGlobalLateTimer(0, true, function()
    self:CreatePanel(RESPATH.PREFAB_BAODIAN_XIANLV, 2)
  end)
end
def.override().OnCreate = function(self)
  if self.mParent == nil or self.mParent.isnil == true then
    self:DestroyPanel()
    return
  end
  self:InitData()
  self:InitUI()
  self:UpdateDetaiView()
end
def.method().InitUI = function(self)
  local descLabel = self.m_panel:FindDirect("Group_BD_PengRen/Label_LongTip"):GetComponent("UILabel")
  local desc = BaodianUtils.GetBaodianDescByName("GROW_XIANLV_DESC")
  descLabel.text = desc
  local ListView = self.m_panel:FindDirect("Group_BD_PengRen/Scroll View/List")
  local listNum = #self.mXianLvIcons
  local listItems = GUIUtils.InitUIList(ListView, listNum)
  for i = 1, listNum do
    local item = listItems[i]
    local textureObj = item:FindDirect(string.format("Img_BgIcon_%d", i)):FindDirect(string.format("Texture_%d", i))
    GUIUtils.FillIcon(textureObj:GetComponent("UITexture"), self.mXianLvIcons[i])
    textureObj.name = string.format("XianLvId_%d", self.mAllXianLvIds[i])
    self.m_msgHandler:Touch(item)
  end
  GUIUtils.Reposition(ListView, "UIList", 0)
  ListView:GetComponent("UIList"):DragToMakeVisible(0, 100)
end
def.method().UpdateDetaiView = function(self)
  local infoTitle = self.m_panel:FindDirect("Group_BD_PengRen/Group_ItemInfo/Img_Icon")
  local skillListView = self.m_panel:FindDirect("Group_BD_PengRen/Group_ItemInfo/List_Skill")
  local texture = infoTitle:FindDirect("Texture"):GetComponent("UITexture")
  GUIUtils.FillIcon(texture, self.mCurCfg.headIconId)
  local nameLabel = infoTitle:FindDirect("Label_Name"):GetComponent("UILabel")
  nameLabel.text = self.mCurCfg.name
  local schoolLabel = infoTitle:FindDirect("Label_School"):GetComponent("UILabel")
  schoolLabel.text = self.mCurCfg.faction
  local skillList = self.mCurCfg.skillCfgList
  local skillNum = #skillList
  local items = GUIUtils.InitUIList(skillListView, skillNum)
  for i = 1, skillNum do
    local item = items[i]
    local skillIconId = skillList[i].iconId
    local texture = item:FindDirect(string.format("Img_BgIcon_%d/Texture_%d", i, i))
    local uitexture = texture:GetComponent("UITexture")
    GUIUtils.FillIcon(uitexture, skillIconId)
    GUIUtils.Toggle(texture, i == 1)
    self.m_msgHandler:Touch(item)
  end
  GUIUtils.Reposition()
  self:UpdateChannelView()
end
def.method().UpdateChannelView = function(self)
  local unlockLabel = self.m_panel:FindDirect("Group_BD_PengRen/Group_ItemInfo/Label_Lock")
  local xianlvView = self.m_panel:FindDirect("Group_BD_PengRen/Group_ItemInfo/Img_Icon_Expend")
  local texture = xianlvView:FindDirect("Texture_Icon")
  local LabelName = xianlvView:FindDirect("Label_Name")
  local itemNumLabel = xianlvView:FindDirect("Label_Num")
  local unlockItemNum = self.mCurCfg.unlockItemNum
  local unlockItem = self.mCurCfg.unlockItem
  local unlockItemType = require("consts.mzm.gsp.partner.confbean.UnlockItem")
  local unlockId = constant.PartnerConstants.Partner_ITEM_ID
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemName, itemIconId
  if unlockItemType.UL_YUANBAO == unlockItem then
    itemName = textRes.Grow.UnlockItem[unlockItem]
    itemIconId = GUIUtils.GetIconIdYuanbao()
  elseif unlockItemType.UL_GOLD == unlockItem then
    itemName = textRes.Grow.UnlockItem[unlockItem]
    itemIconId = GUIUtils.GetIconIdGold()
  elseif unlockItemType.UL_SILVER == unlockItem then
    itemName = textRes.Grow.UnlockItem[unlockItem]
    itemIconId = GUIUtils.GetIconIdSilver()
  else
    local unlockItemId = self.mCurCfg.unlockItemId
    local itemBase = ItemUtils.GetItemBase(unlockItemId)
    itemName = itemBase.name
    itemIconId = itemBase.icon
  end
  GUIUtils.FillIcon(texture:GetComponent("UITexture"), itemIconId)
  unlockLabel:GetComponent("UILabel").text = string.format(textRes.Grow[18], self.mCurCfg.unlockLevel)
  LabelName:GetComponent("UILabel").text = itemName
  itemNumLabel:GetComponent("UILabel").text = unlockItemNum
end
def.method().InitData = function(self)
  self.mXianLvIcons = {}
  self.mAllXianLvIds = {}
  local allcfg = BaodianUtils.GetAllXianLvCfg()
  for k, v in pairs(allcfg) do
    if self.mCurXianLvId == 0 and self.mCurCfg == nil then
      self.mCurXianLvId = v.id
      self.mCurCfg = v
    end
    table.insert(self.mXianLvIcons, v.headIconId)
    table.insert(self.mAllXianLvIds, v.id)
  end
  self.mCurSelectSkillIndex = 1
end
def.method().UpdateData = function(self)
  self:SetXianLvCfgById(self.mCurXianLvId)
  self.mCurSelectSkillIndex = 1
end
def.method("number").SetXianLvCfgById = function(self, id)
  self.mCurCfg = BaodianUtils.GetXianLvCfg(id)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if string.find(id, "XianLvId_") then
    local strs = string.split(id, "_")
    local id = tonumber(strs[2])
    self.mCurXianLvId = id
    self:UpdateData()
    self:UpdateDetaiView()
  elseif string.find(id, "Texture_") then
    local strs = string.split(id, "_")
    local skillIndex = tonumber(strs[2])
    if type(skillIndex) ~= "number" then
      return
    end
    local skillList = self.mCurCfg.skillCfgList
    local skillId = skillList[skillIndex].id
    self.mCurSelectSkillIndex = skillIndex
    local skillTipMgr = require("Main.Skill.SkillTipMgr")
    local skillTipInstance = skillTipMgr.Instance()
    skillTipInstance:ShowTipByIdEx(skillId, obj, 0)
  end
end
def.override().ReleaseUI = function(self)
end
def.override().OnDestroy = function(self)
  self.mCurXianLvId = 0
  self.mXianLvIcons = nil
  self.mCurCfg = nil
  self.mCurSelectSkillIndex = 0
  self.mAllXianLvIds = nil
  self.mParent = nil
end
BaodianXianLvPanel.Commit()
return BaodianXianLvPanel
