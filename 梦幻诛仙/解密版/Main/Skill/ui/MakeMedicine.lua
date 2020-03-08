local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MakeMedicine = Lplus.Extend(ECPanelBase, "MakeMedicine")
local LivingSkillUtility = require("Main.Skill.LivingSkillUtility")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local CommonDescDlg = require("GUI.CommonUITipsDlg")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local def = MakeMedicine.define
local dlg
def.field("table").materialsTbl = nil
def.field("table").costTbl = nil
def.field("function").callback = nil
def.field("table").tag = nil
def.field("number").costVigor = 0
def.field("number").skillBagId = 0
def.field("number").gridsNum = 12
def.field("number").makeDrugId = -1
def.static("=>", MakeMedicine).Instance = function(self)
  if nil == dlg then
    dlg = MakeMedicine()
  end
  return dlg
end
def.static("function", "table", "number", "number").ShowMakeMedicinePanel = function(callback, tag, costVigor, skillBagId)
  MakeMedicine.Instance().callback = callback
  MakeMedicine.Instance().tag = tag
  MakeMedicine.Instance().costVigor = costVigor
  MakeMedicine.Instance().skillBagId = skillBagId
  MakeMedicine.Instance():SetModal(true)
  MakeMedicine.Instance():CreatePanel(RESPATH.PREFAB_SKILL_DRUG_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:PrepareToShow()
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, MakeMedicine.OnEnergyChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, MakeMedicine.OnSilverMoneyChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, MakeMedicine.OnBagInfoSyncronized)
  Event.RegisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_DRUG_RES, MakeMedicine.SucceedMakeDrugItem)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOMELAND, MakeMedicine.OnLeaveHomeland)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, MakeMedicine.OnEnergyChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, MakeMedicine.OnSilverMoneyChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, MakeMedicine.OnBagInfoSyncronized)
  Event.UnregisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_DRUG_RES, MakeMedicine.SucceedMakeDrugItem)
  Event.UnregisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOMELAND, MakeMedicine.OnLeaveHomeland)
end
def.method().PrepareToShow = function(self)
  self.makeDrugId = -1
  self:Init()
  self:CreateGridObjects()
  self:UpdateInfo()
end
def.method().SetLastItemsNull = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Img_Bg1 = Img_Bg0:FindDirect("Img_Bg1")
  local Gride_Bag = Img_Bg1:FindDirect("Img_BgBag"):FindDirect("Scroll View_Bag"):FindDirect("Gride_Bag")
  for i = 1, #self.materialsTbl do
    local drug = Gride_Bag:GetChild(i)
    drug:FindDirect("Img_Icon"):SetActive(false)
    drug:FindDirect("Label_ItemNum"):SetActive(false)
  end
  local Group_Creat = Img_Bg0:FindDirect("Group_Creat")
  for i = 1, 4 do
    self:SetCostDrugItemIcon(i, 7008)
  end
end
def.method().Init = function(self)
  self.materialsTbl = {}
  local items = ItemModule.Instance():GetItems()
  local itemType = require("consts.mzm.gsp.item.confbean.ItemType")
  for k, v in pairs(items) do
    local itemBase = ItemUtils.GetItemBase(v.id)
    if itemType.DRUG_ITEM == itemBase.itemType then
      local drugInfo = {}
      drugInfo.id = itemBase.itemid
      drugInfo.iconId = itemBase.icon
      drugInfo.key = k
      drugInfo.count = v.number
      drugInfo.fillNum = drugInfo.count
      table.insert(self.materialsTbl, drugInfo)
    end
  end
  table.sort(self.materialsTbl, function(a, b)
    return a.id < b.id
  end)
  self.costTbl = {}
end
def.method().UpdateInfo = function(self)
  if nil == self.m_panel then
    return
  end
  self:FillDrugList()
  self:FillCostList()
  self:UpdateCostSilverMoney()
  self:UpdateVigorNum()
end
def.static("table", "table").OnEnergyChanged = function(params, context)
  local self = MakeMedicine.Instance()
  self:UpdateVigorNum()
end
def.method().UpdateVigorNum = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Group_Make = Img_Bg0:FindDirect("Group_Make")
  local Label_UseNum = Group_Make:FindDirect("Label_UseNum")
  Label_UseNum:GetComponent("UILabel"):set_text(self.costVigor)
  local Label_HaveNum = Group_Make:FindDirect("Label_HaveNum")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  Label_HaveNum:GetComponent("UILabel"):set_text(heroProp.energy)
  Label_HaveNum:GetComponent("UILabel"):set_textColor(Color.Color(0.30980392156862746, 0.18823529411764706, 0.09411764705882353))
  if self.costVigor > heroProp.energy then
    Label_UseNum:GetComponent("UILabel"):set_textColor(Color.red)
  else
    Label_UseNum:GetComponent("UILabel"):set_textColor(Color.Color(0.30980392156862746, 0.18823529411764706, 0.09411764705882353))
  end
end
def.method().CreateGridObjects = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Img_Bg1 = Img_Bg0:FindDirect("Img_Bg1")
  local Gride_Bag = Img_Bg1:FindDirect("Img_BgBag"):FindDirect("Scroll View_Bag"):FindDirect("Gride_Bag")
  local drugTemplate = Gride_Bag:FindDirect("Img_BgItem")
  drugTemplate:SetActive(false)
  local NUM_PER_ROW = 3
  local num = self.gridsNum
  if #self.materialsTbl > self.gridsNum then
    local lackNum = #self.materialsTbl - self.gridsNum
    local rowNum = math.floor((lackNum - 1) / NUM_PER_ROW) + 1
    num = num + rowNum * NUM_PER_ROW
  end
  for i = 1, num do
    LivingSkillUtility.AddLastGroup(i, "Img_BgItem%d", Gride_Bag, drugTemplate)
    local drug = Gride_Bag:GetChild(i)
    drug:FindDirect("Label_ItemNum"):SetActive(false)
    drug:FindDirect("Img_Icon"):SetActive(false)
  end
  local uiGrid = Gride_Bag:GetComponent("UIGrid")
  uiGrid.repositionNow = true
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().FillDrugList = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Img_Bg1 = Img_Bg0:FindDirect("Img_Bg1")
  local Gride_Bag = Img_Bg1:FindDirect("Img_BgBag"):FindDirect("Scroll View_Bag"):FindDirect("Gride_Bag")
  local childCount = Gride_Bag.childCount
  local count = math.min(childCount - 1, #self.materialsTbl)
  for i = 1, count do
    local drug = Gride_Bag:GetChild(i)
    self:FillDrugInfo(i, drug, Gride_Bag)
  end
end
def.method("number", "userdata", "userdata").FillDrugInfo = function(self, index, drug, gridTemplate)
  local drugInfo = self.materialsTbl[index]
  local Img_Icon = drug:FindDirect("Img_Icon"):GetComponent("UITexture")
  drug:FindDirect("Img_Icon"):SetActive(true)
  GUIUtils.FillIcon(Img_Icon, drugInfo.iconId)
  drug:FindDirect("Label_ItemNum"):SetActive(true)
  drug:FindDirect("Label_ItemNum"):GetComponent("UILabel"):set_text(drugInfo.count)
end
def.method().FillCostList = function(self)
  local index = 1
  for i = 1, 4 do
    local drugInfo = self.materialsTbl[index]
    if index <= #self.materialsTbl then
      if 1 > drugInfo.count then
        index = index + 1
      end
      self:OnSelectDrugItem(index)
    else
      break
    end
  end
end
def.method("number").OnSelectDrugItem = function(self, index)
  local drugInfo = self.materialsTbl[index]
  if nil == drugInfo then
    return
  end
  local num = self:GetCostDrugItemNum()
  if num >= LivingSkillUtility.GetMakeDrugConst("NEED_ITEM_NUM") then
    Toast(textRes.Skill[55])
    return
  end
  for i = 1, 4 do
    if nil == self.costTbl[i] and drugInfo.count > 0 then
      self.costTbl[i] = index
      self:SetCostDrugItemIcon(i, drugInfo.iconId)
      break
    end
  end
  if drugInfo.count > 0 then
    self:SetDrugItemNum(-1, index)
  end
  self:UpdateCostSilverMoney()
end
def.method("number", "number").SetCostDrugItemIcon = function(self, index, iconId)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Group_Creat = Img_Bg0:FindDirect("Group_Creat")
  local costDrug = Group_Creat:FindDirect(string.format("Img_ItemCreat%d", index))
  costDrug:FindDirect("Icon_ItemCreat"):SetActive(true)
  local Icon_ItemCreat = costDrug:FindDirect("Icon_ItemCreat"):GetComponent("UITexture")
  GUIUtils.FillIcon(Icon_ItemCreat, iconId)
end
def.method("number").OnSelectCostItem = function(self, index)
  if nil == self.costTbl[index] then
    return
  end
  local drugItemIndex = self.costTbl[index]
  self.costTbl[index] = nil
  self:SetDrugItemNum(1, drugItemIndex)
  self:SetCostDrugItemIcon(index, 7008)
  self:UpdateCostSilverMoney()
end
def.method("number", "number").SetDrugItemNum = function(self, num, index)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Img_Bg1 = Img_Bg0:FindDirect("Img_Bg1")
  local Gride_Bag = Img_Bg1:FindDirect("Img_BgBag"):FindDirect("Scroll View_Bag"):FindDirect("Gride_Bag")
  self.materialsTbl[index].count = self.materialsTbl[index].count + num
  Gride_Bag:GetChild(index):FindDirect("Label_ItemNum"):GetComponent("UILabel"):set_text(self.materialsTbl[index].count)
  local textColor = Color.Color(1, 1, 1, 1)
  local remainNum = self:GetCostDrugByItemIndex(index)
  if remainNum > 0 then
    textColor = Color.green
  end
  Gride_Bag:GetChild(index):FindDirect("Label_ItemNum"):GetComponent("UILabel"):set_textColor(textColor)
end
def.method("number", "=>", "number").GetCostDrugByItemIndex = function(self, index)
  local num = 0
  for k, v in pairs(self.costTbl) do
    if index == v then
      num = num + 1
    end
  end
  return num
end
def.method("=>", "number").GetCostDrugItemNum = function(self)
  local num = 0
  for k, v in pairs(self.costTbl) do
    if nil ~= v then
      num = num + 1
    end
  end
  return num
end
def.static("table", "table").OnSilverMoneyChanged = function(params, context)
  local self = MakeMedicine.Instance()
  self:UpdateCostSilverMoney()
end
def.method().UpdateCostSilverMoney = function(self)
  local silver = LivingSkillUtility.GetMakeDrugConst("NEED_SILVER_PER_GRID")
  local num = self:GetCostDrugItemNum()
  local gridNum = LivingSkillUtility.GetMakeDrugConst("NEED_ITEM_NUM")
  local cost = silver * (gridNum - num)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Label_CreatTips = Img_Bg0:FindDirect("Group_Creat"):FindDirect("Label_CreatTips")
  local haveSilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  local color = "ffffff"
  local text = cost
  if Int64.gt(cost, haveSilver) then
    color = "ff0000"
    text = string.format(textRes.Skill[54], color, cost)
  end
  Label_CreatTips:GetComponent("UILabel"):set_text(text)
end
def.static("table", "table").SucceedMakeDrugItem = function(params, context)
  local itemKey = params[3]
  local itemId = params[2]
  local itemBase = ItemUtils.GetItemBase(itemId)
  if itemBase == nil then
    return
  end
  MakeMedicine.Instance().makeDrugId = itemId
  MakeMedicine.Instance():SetCostDrugItemIcon(5, itemBase.icon)
end
def.static("table", "table").OnBagInfoSyncronized = function(params, context)
  MakeMedicine.Instance():SetLastItemsNull()
  MakeMedicine.Instance():Init()
  MakeMedicine.Instance():UpdateInfo()
end
def.static("table", "table").OnLeaveHomeland = function(params, context)
  if dlg then
    dlg:DestroyPanel()
  end
end
def.method().RequireToMakeMedicine = function(self)
  local itemsKeyTbl = {}
  for i = 1, 4 do
    local drugItemIndex = self.costTbl[i]
    if nil ~= drugItemIndex then
      local drugInfo = self.materialsTbl[drugItemIndex]
      if nil ~= drugInfo then
        table.insert(itemsKeyTbl, drugInfo.key)
      end
    end
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.lifeskill.CLianYaoReq").new(self.skillBagId, itemsKeyTbl))
end
def.static("number", "table").BuySilverCallback = function(i, tag)
  if i == 1 then
    local dlg = tag.id
  end
end
def.method().OnMakeBtnClick = function(self)
  local silver = LivingSkillUtility.GetMakeDrugConst("NEED_SILVER_PER_GRID")
  local num = self:GetCostDrugItemNum()
  local gridNum = LivingSkillUtility.GetMakeDrugConst("NEED_ITEM_NUM")
  local cost = silver * (gridNum - num)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Label_CreatTips = Img_Bg0:FindDirect("Group_Creat"):FindDirect("Label_CreatTips")
  local haveSilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  local color = "ffffff"
  local text = tostring(cost)
  if Int64.gt(cost, haveSilver) then
    color = "ff0000"
    text = string.format(textRes.Skill[54], color, cost)
  end
  Label_CreatTips:GetComponent("UILabel"):set_text(text)
  if Int64.lt(haveSilver, cost) then
    local tag = {id = self}
    CommonConfirmDlg.ShowConfirm("", textRes.Skill[57], MakeMedicine.BuySilverCallback, tag)
    return
  end
  local bBagFull = ItemModule.Instance():IsBagFull(ItemModule.BAG)
  if bBagFull then
    Toast(textRes.Skill.LivingSkillMakeRes[1])
    return
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if self.costVigor > heroProp.energy then
    Toast(textRes.Skill.LivingSkillMakeRes[0])
    return
  end
  self:RequireToMakeMedicine()
end
def.method().OnInfoTipsClick = function(self)
  local desc = textRes.Skill[58]
  local tmpPosition = {x = 0, y = 0}
  CommonDescDlg.ShowCommonTip(desc, tmpPosition)
end
def.method("number").ShowTips = function(self, index)
  local drugInfo = self.materialsTbl[index]
  if nil == drugInfo then
    return
  end
  local itemId = drugInfo.id
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Img_Bg1 = Img_Bg0:FindDirect("Img_Bg1")
  local Gride_Bag = Img_Bg1:FindDirect("Img_BgBag"):FindDirect("Scroll View_Bag"):FindDirect("Gride_Bag")
  local obj = Gride_Bag:GetChild(index)
  local position = obj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = obj:GetComponent("UISprite")
  ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
end
def.method("string").onLongPress = function(self, id)
  if string.find(id, "Img_BgItem") then
    local index = tonumber(string.sub(id, #"Img_BgItem" + 1, -1))
    self:ShowTips(index)
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.find(id, "Img_BgItem") then
    local index = tonumber(string.sub(id, #"Img_BgItem" + 1, -1))
    self:OnSelectDrugItem(index)
  elseif "Img_ItemCreat5" == id then
    if self.makeDrugId == -1 then
      return
    end
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(self.makeDrugId, clickobj, 0, false)
  elseif string.find(id, "Img_ItemCreat") then
    local index = tonumber(string.sub(id, #"Img_ItemCreat" + 1, -1))
    if index <= 4 and index >= 1 then
      self:OnSelectCostItem(index)
    end
  elseif "Btn_Creat" == id then
    self:OnMakeBtnClick()
  elseif "Btn_Tips" == id then
    self:OnInfoTipsClick()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_panelName
    })
  elseif "Btn_Close" == id then
    self:DestroyPanel()
    self = nil
  elseif id == "Modal" then
    self:DestroyPanel()
    self = nil
  end
end
MakeMedicine.Commit()
return MakeMedicine
