local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local VigourOnShelfNode = Lplus.Extend(TabNode, "VigourOnShelfNode")
local def = VigourOnShelfNode.define
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
local GUIUtils = require("GUI.GUIUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local PitchItemOnShelfPanel = Lplus.ForwardDeclare("PitchItemOnShelfPanel")
local LivingSkillData = require("Main.Skill.data.LivingSkillData")
local PitchData = require("Main.CommerceAndPitch.data.PitchData")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local PitchSellNode = Lplus.ForwardDeclare("PitchSellNode")
local LivingSkillUtility = require("Main.Skill.LivingSkillUtility")
def.field("table").uiTbl = nil
def.field("boolean").bIsSkillListInit = false
def.field("table").selectSkillIndex = nil
def.field("number").canUseNum = 0
def.field("number").lastSkillListNum = 0
def.field("number").ONSELL_MAX_NUM_PER_GRID = 5
def.field("table").levelSelectTbl = nil
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self.uiTbl = CommercePitchUtils.FillPitchVigorOnShelfUI(self.uiTbl, self.m_node)
  self.ONSELL_MAX_NUM_PER_GRID = CommercePitchUtils.GetOnSellMaxNumPerGrid()
end
def.override().OnShow = function(self)
  if false == self.bIsSkillListInit then
    self.selectSkillIndex = {}
    self.levelSelectTbl = {}
    self:FillVigorPanel()
  end
  self:UpdateVigorNum()
end
def.override().OnHide = function(self)
end
def.method().FillVigorPanel = function(self)
  local skillNum = #PitchItemOnShelfPanel.Instance().skillWeaponList
  if PitchItemOnShelfPanel.Instance().enchantingSkill then
    skillNum = skillNum + 1
  end
  if 0 == skillNum then
    self.uiTbl.Group_Skill01:SetActive(false)
  else
    self.uiTbl.Group_Skill01:SetActive(true)
    self:UpdateSkillObjects(skillNum)
    self:FillSkillList()
    self:FillRight(false)
  end
  self:UpdateGridNum()
  self:UpdateVigorNum()
  self.bIsSkillListInit = true
end
def.method("boolean").FillRight = function(self, bShowInfo)
  if false == bShowInfo then
    self.uiTbl.Group_Right:SetActive(false)
    self.uiTbl.Group_None:SetActive(true)
  else
    self.uiTbl.Group_Right:SetActive(true)
    self.uiTbl.Group_None:SetActive(false)
    self:FillSelectSkillInfo()
  end
end
def.method("number").SetCanUseNum = function(self, canUseNum)
  self.canUseNum = canUseNum
end
def.method("=>", "number").NeedGridNum = function(self)
  local count = 0
  for k, v in pairs(self.selectSkillIndex) do
    if v <= #PitchItemOnShelfPanel.Instance().skillWeaponList then
      local skill2 = PitchItemOnShelfPanel.Instance().skillWeaponList[v]
      local itemIndex2 = self.levelSelectTbl[v]
      local itemInfo2 = skill2.unlockSkillInfo[itemIndex2]
      count = count + itemInfo2.gridNum
    else
      count = count + PitchItemOnShelfPanel.Instance().enchantingSkill.gridNum
    end
  end
  return count
end
def.method("=>", "number").NeedVigorNum = function(self)
  local costVigor = 0
  for k, v in pairs(self.selectSkillIndex) do
    if v <= #PitchItemOnShelfPanel.Instance().skillWeaponList then
      local skill = PitchItemOnShelfPanel.Instance().skillWeaponList[v]
      local itemIndex = self.levelSelectTbl[v]
      local itemInfo = skill.unlockSkillInfo[itemIndex]
      costVigor = costVigor + LivingSkillUtility.GetCostVigor(skill.id, itemInfo.openLevel) * itemInfo.num
    else
      local skill = PitchItemOnShelfPanel.Instance().enchantingSkill
      costVigor = costVigor + skill.needVigor * skill.num
    end
  end
  return costVigor
end
def.method("userdata", "string").OnSkillSelect = function(self, clickobj, id)
  if self:NeedGridNum() >= self.canUseNum and clickobj:GetComponent("UIToggle"):get_isChecked() then
    clickobj:GetComponent("UIToggle"):set_isChecked(false)
    Toast(string.format(textRes.Pitch[29], self.canUseNum))
    return
  end
  local bSelect = clickobj:GetComponent("UIToggle"):get_isChecked()
  local index = tonumber(string.sub(id, string.len("Group_Skill0") + 1))
  if index <= #PitchItemOnShelfPanel.Instance().skillWeaponList then
    if false == PitchItemOnShelfPanel.Instance().skillWeaponList[index].unlock and bSelect then
      clickobj:GetComponent("UIToggle"):set_isChecked(false)
      Toast(textRes.Pitch[36])
      return
    end
  elseif false == PitchItemOnShelfPanel.Instance().enchantingSkill.unlock and bSelect then
    clickobj:GetComponent("UIToggle"):set_isChecked(false)
    Toast(textRes.Pitch[36])
    return
  end
  if bSelect then
    table.insert(self.selectSkillIndex, index)
  else
    for k, v in pairs(self.selectSkillIndex) do
      if v == index then
        local index = self.selectSkillIndex[#self.selectSkillIndex]
        if index <= #PitchItemOnShelfPanel.Instance().skillWeaponList then
          local skill = PitchItemOnShelfPanel.Instance().skillWeaponList[index]
          local itemIndex = self.levelSelectTbl[index]
          local itemInfo = skill.unlockSkillInfo[itemIndex]
          itemInfo.num = 1
        else
          local skill = PitchItemOnShelfPanel.Instance().enchantingSkill
          skill.num = 1
        end
        table.remove(self.selectSkillIndex, k)
      end
    end
    if #self.selectSkillIndex > 0 then
      bSelect = true
    end
  end
  self:UpdateGridNum()
  self:UpdateVigorNum()
  self:FillRight(bSelect)
end
def.method().FillSelectSkillInfo = function(self)
  local Texture_RightIcon = self.uiTbl.Group_Right:FindDirect("Scroll View/Group_Info/Img_BgRightItem/Texture_RightIcon")
  local Label_Describe = self.uiTbl.Group_Right:FindDirect("Scroll View/Label_Describe")
  local Label_RightName = self.uiTbl.Group_Right:FindDirect("Scroll View/Group_Info/Label_RightName")
  local Label_LvTitle = self.uiTbl.Group_Right:FindDirect("Scroll View/Group_Info/Label_LvTitle")
  local Label_Type = self.uiTbl.Group_Right:FindDirect("Scroll View/Group_Info/Label_Type")
  local Label_TypeTitle = self.uiTbl.Group_Right:FindDirect("Scroll View/Group_Info/Label_TypeTitle")
  local Label_Lv = self.uiTbl.Group_Right:FindDirect("Scroll View/Group_Info/Label_Lv")
  Label_LvTitle:SetActive(false)
  Label_Type:SetActive(false)
  Label_TypeTitle:SetActive(false)
  Label_Lv:SetActive(false)
  local index = self.selectSkillIndex[#self.selectSkillIndex]
  local price = 0
  local num = 0
  local priceRate = 0
  if index <= #PitchItemOnShelfPanel.Instance().skillWeaponList then
    local skill = PitchItemOnShelfPanel.Instance().skillWeaponList[index]
    local itemIndex = self.levelSelectTbl[index]
    local itemInfo = skill.unlockSkillInfo[itemIndex]
    local itemBase = ItemUtils.GetItemBase(itemInfo.id)
    GUIUtils.FillIcon(Texture_RightIcon:GetComponent("UITexture"), itemBase.icon)
    Label_Describe:GetComponent("UILabel"):set_text(itemBase.desc)
    Label_RightName:GetComponent("UILabel"):set_text(itemBase.name)
    price = itemInfo.price
    num = itemInfo.num
    priceRate = itemInfo.priceRate
  else
    local skill = PitchItemOnShelfPanel.Instance().enchantingSkill
    local itemBase = ItemUtils.GetItemBase(skill.itemId)
    GUIUtils.FillIcon(Texture_RightIcon:GetComponent("UITexture"), itemBase.icon)
    Label_Describe:GetComponent("UILabel"):set_text(itemBase.desc)
    Label_RightName:GetComponent("UILabel"):set_text(itemBase.name)
    price = skill.price
    num = skill.num
    priceRate = skill.priceRate
  end
  self:UpdatePriceLabel(0)
  local Group_Num = self.uiTbl.Group_Right:FindDirect("Group_Num")
  local Img_BgNum = Group_Num:FindDirect("Img_BgNum")
  local Label_Num = Img_BgNum:FindDirect("Label_Num")
  Label_Num:GetComponent("UILabel"):set_text(num)
end
def.method("number", "number").UpdateRight = function(self, itemIndex, skillIndex)
  local Texture_RightIcon = self.uiTbl.Group_Right:FindDirect("Scroll View/Group_Info/Img_BgRightItem/Texture_RightIcon")
  local Label_Describe = self.uiTbl.Group_Right:FindDirect("Scroll View/Label_Describe")
  local Label_RightName = self.uiTbl.Group_Right:FindDirect("Scroll View/Group_Info/Label_RightName")
  local skill = PitchItemOnShelfPanel.Instance().skillWeaponList[skillIndex]
  local itemInfo = skill.unlockSkillInfo[itemIndex]
  local itemBase = ItemUtils.GetItemBase(itemInfo.id)
  GUIUtils.FillIcon(Texture_RightIcon:GetComponent("UITexture"), itemBase.icon)
  Label_Describe:GetComponent("UILabel"):set_text(itemBase.desc)
  Label_RightName:GetComponent("UILabel"):set_text(itemBase.name)
  local serviceMoney, _ = math.modf(itemInfo.price * 0.05)
  itemInfo.gridNum = 1
  itemInfo.num = 1
  itemInfo.priceRate = 1
  local Group_Num = self.uiTbl.Group_Right:FindDirect("Group_Num")
  local Img_BgNum = Group_Num:FindDirect("Img_BgNum")
  local Label_Num = Img_BgNum:FindDirect("Label_Num")
  Label_Num:GetComponent("UILabel"):set_text(itemInfo.num)
  local Group_Price = self.uiTbl.Group_Right:FindDirect("Group_Price")
  local Img_BgPrice = Group_Price:FindDirect("Img_BgPrice")
  local Label_Price = Img_BgPrice:FindDirect("Label_Price")
  local showPrice = require("Common.MathHelper").Ceil(itemInfo.price)
  local priceText = CommercePitchUtils.GetPitchColoredPriceText(showPrice)
  Label_Price:GetComponent("UILabel"):set_text(priceText)
  local Label_PriceCompare = Group_Price:FindDirect("Label_PriceCompare")
  Label_PriceCompare:GetComponent("UILabel"):set_text(textRes.Pitch[52])
  Label_PriceCompare:GetComponent("UILabel"):set_textColor(Color.white)
  local Group_Tax = self.uiTbl.Group_Right:FindDirect("Group_Tax")
  local Img_BgTax = Group_Tax:FindDirect("Img_BgTax")
  local Label_Tax = Img_BgTax:FindDirect("Label_Tax")
  Label_Tax:GetComponent("UILabel"):set_text(serviceMoney)
  self:UpdateGridNum()
  self:UpdateVigorNum()
end
def.method("number", "number").UpdateLeft = function(self, itemIndex, skillIndex)
  local gridTemplate = self.uiTbl.Grid_Skill
  local skill = gridTemplate:GetChild(skillIndex - 1)
  local skillBag = PitchItemOnShelfPanel.Instance().skillWeaponList[skillIndex]
  local Img_SkillItem = skill:FindDirect("Img_SkillItem")
  local Texture_SkillIcon = Img_SkillItem:FindDirect("Texture_SkillIcon")
  local itemInfo = skillBag.unlockSkillInfo[itemIndex]
  local itemBase = ItemUtils.GetItemBase(itemInfo.id)
  GUIUtils.FillIcon(Texture_SkillIcon:GetComponent("UITexture"), itemBase.icon)
end
def.method().UpdateGridNum = function(self)
  local sellListNum = #PitchData.Instance():GetSellList() + self:NeedGridNum()
  local sellGridNum = PitchData.Instance():GetSellGridNum()
  local str = sellListNum .. "/" .. sellGridNum
  self.uiTbl.Label_ActiveAddNum:GetComponent("UILabel"):set_text(str)
end
def.method().UpdateVigorNum = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local cost = self:NeedVigorNum()
  local have = heroProp.energy
  local str = cost .. "/" .. have
  self.uiTbl.Label_ActiveNum:GetComponent("UILabel"):set_text(str)
end
def.method("number").UpdateSkillObjects = function(self, skillNum)
  local itemDVal = skillNum - self.lastSkillListNum
  local itemGridTemplate = self.uiTbl.Grid_Skill
  local itemTemplate = self.uiTbl.Group_Skill01
  if itemDVal > 0 then
    for i = 1, itemDVal do
      self.lastSkillListNum = self.lastSkillListNum + 1
      CommercePitchUtils.AddLastGroup(self.lastSkillListNum, "Group_Skill0%d", itemGridTemplate, itemTemplate)
    end
  elseif itemDVal < 0 then
    local num = math.abs(itemDVal)
    for i = 1, num do
      CommercePitchUtils.DeleteLastGroup(self.lastSkillListNum, "Group_Skill01", itemGridTemplate, itemTemplate)
      self.lastSkillListNum = self.lastSkillListNum - 1
    end
  end
  local uiGrid = itemGridTemplate:GetComponent("UIGrid")
  uiGrid:Reposition()
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method().FillSkillList = function(self)
  local gridTemplate = self.uiTbl.Grid_Skill
  local itemTemplate = self.uiTbl.Group_Skill01
  for i = 1, #PitchItemOnShelfPanel.Instance().skillWeaponList do
    local skill = gridTemplate:GetChild(i - 1)
    local skillInfo = PitchItemOnShelfPanel.Instance().skillWeaponList[i]
    self:FillLivingSkill(skillInfo, i, skill)
  end
  if PitchItemOnShelfPanel.Instance().enchantingSkill then
    local index = #PitchItemOnShelfPanel.Instance().skillWeaponList + 1
    local skill = gridTemplate:GetChild(index - 1)
    self:FillEnchantSkill(PitchItemOnShelfPanel.Instance().enchantingSkill, index, skill)
  end
end
def.method("table", "number", "userdata").FillLivingSkill = function(self, skillInfo, index, skill)
  local Img_SkillItem = skill:FindDirect("Img_SkillItem")
  local Texture_SkillIcon = Img_SkillItem:FindDirect("Texture_SkillIcon")
  local Label_SkillNum = Img_SkillItem:FindDirect("Label_SkillNum")
  Label_SkillNum:GetComponent("UILabel"):set_text(skillInfo.level)
  local Label_SkillItemName = skill:FindDirect("Label_SkillItemName")
  Label_SkillItemName:GetComponent("UILabel"):set_text(skillInfo.name)
  if #skillInfo.unlockSkillInfo > 0 then
    skill:FindDirect("Img_BgSkillLv"):SetActive(true)
    skill:FindDirect("Img_BgSkillLv/Label_BgSkillLv"):GetComponent("UILabel"):set_text(skillInfo.unlockSkillInfo[#skillInfo.unlockSkillInfo].openLevel)
    self.levelSelectTbl[index] = #skillInfo.unlockSkillInfo
  else
    skill:FindDirect("Img_BgSkillLv"):SetActive(false)
  end
  local skillBag = PitchItemOnShelfPanel.Instance().skillWeaponList[index]
  local itemInfo = skillBag.unlockSkillInfo[#skillBag.unlockSkillInfo]
  if itemInfo ~= nil then
    local itemBase = ItemUtils.GetItemBase(itemInfo.id)
    GUIUtils.FillIcon(Texture_SkillIcon:GetComponent("UITexture"), itemBase.icon)
  else
    GUIUtils.FillIcon(Texture_SkillIcon:GetComponent("UITexture"), skillInfo.iconId)
  end
end
def.method("table", "number", "userdata").FillEnchantSkill = function(self, skillInfo, index, skill)
  local SkillUtility = require("Main.Skill.SkillUtility")
  local cfg = SkillUtility.GetEnchantingSkillCfg(skillInfo.id)
  local Img_SkillItem = skill:FindDirect("Img_SkillItem")
  local Texture_SkillIcon = Img_SkillItem:FindDirect("Texture_SkillIcon")
  local Label_SkillNum = Img_SkillItem:FindDirect("Label_SkillNum")
  GUIUtils.FillIcon(Texture_SkillIcon:GetComponent("UITexture"), cfg.iconId)
  Label_SkillNum:GetComponent("UILabel"):set_text(skillInfo.level)
  local Label_SkillItemName = skill:FindDirect("Label_SkillItemName")
  Label_SkillItemName:GetComponent("UILabel"):set_text(cfg.name)
  skill:FindDirect("Img_BgSkillLv"):SetActive(false)
end
def.method("number").UpdatePriceLabel = function(self, rate)
  local Group_Price = self.uiTbl.Group_Right:FindDirect("Group_Price")
  local Img_BgPrice = Group_Price:FindDirect("Img_BgPrice")
  local Label_Price = Img_BgPrice:FindDirect("Label_Price")
  local Label_PriceCompare = Group_Price:FindDirect("Label_PriceCompare")
  local Group_Tax = self.uiTbl.Group_Right:FindDirect("Group_Tax")
  local Img_BgTax = Group_Tax:FindDirect("Img_BgTax")
  local Label_Tax = Img_BgTax:FindDirect("Label_Tax")
  local _Toast = Toast
  local function Toast(...)
    if rate ~= 0 then
      _Toast(...)
    end
  end
  local index = self.selectSkillIndex[#self.selectSkillIndex]
  local itemId = 0
  local expInfo
  if index <= #PitchItemOnShelfPanel.Instance().skillWeaponList then
    local skill = PitchItemOnShelfPanel.Instance().skillWeaponList[index]
    local itemIndex = self.levelSelectTbl[index]
    expInfo = skill.unlockSkillInfo[itemIndex]
    itemId = expInfo.id
  else
    expInfo = PitchItemOnShelfPanel.Instance().enchantingSkill
    itemId = expInfo.itemId
  end
  local _, minPrice, maxPrice = CommercePitchUtils.GetItemPitchInfo(itemId)
  local expRate = expInfo.priceRate + rate
  local minRate = CommercePitchUtils.GetAdjustPriceRateMin() / 10000
  local maxRate = CommercePitchUtils.GetAdjustPriceRateMax() / 10000
  if expRate <= maxRate + 1.0E-6 and expRate >= minRate then
    local expPrice = expRate * expInfo.price
    if maxPrice < expPrice then
      expPrice = maxPrice
      expRate = expPrice / price
      Toast(textRes.Pitch[22])
    elseif minPrice > expPrice then
      expPrice = minPrice
      expRate = expPrice / price
      Toast(textRes.Pitch[23])
    end
    local showPrice = require("Common.MathHelper").Ceil(expPrice)
    local priceText = CommercePitchUtils.GetPitchColoredPriceText(showPrice)
    Label_Price:GetComponent("UILabel"):set_text(priceText)
    local str = textRes.Pitch[52]
    local textColor = Color.white
    local percent = expRate * 100
    if percent > 100 then
      local tmp = percent - 100
      str = str .. "+" .. tmp .. "%"
      textColor = Color.red
    elseif percent < 100 then
      local tmp = 100 - percent
      str = str .. "-" .. tmp .. "%"
      textColor = Color.green
    end
    Label_PriceCompare:GetComponent("UILabel"):set_text(str)
    Label_PriceCompare:GetComponent("UILabel"):set_textColor(textColor)
    expInfo.priceRate = expRate
    local serviceMoney, _ = math.modf(expPrice * 0.05 * expInfo.num)
    Label_Tax:GetComponent("UILabel"):set_text(serviceMoney)
  elseif minRate > expRate then
    Toast(textRes.Pitch[16])
  elseif expRate > maxRate + 1.0E-6 then
    Toast(textRes.Pitch[15])
  end
end
def.method("number").UpdateItemNum = function(self, addNum)
  local Group_Num = self.uiTbl.Group_Right:FindDirect("Group_Num")
  local Img_BgNum = Group_Num:FindDirect("Img_BgNum")
  local Label_Num = Img_BgNum:FindDirect("Label_Num")
  local curNum = tonumber(Label_Num:GetComponent("UILabel"):get_text())
  local expNum = curNum + addNum
  if expNum < 1 then
    expNum = 1
    Toast(textRes.Pitch[18])
  end
  local price = 0
  local index = self.selectSkillIndex[#self.selectSkillIndex]
  if index <= #PitchItemOnShelfPanel.Instance().skillWeaponList then
    local skill = PitchItemOnShelfPanel.Instance().skillWeaponList[index]
    local itemIndex = self.levelSelectTbl[index]
    local itemInfo = skill.unlockSkillInfo[itemIndex]
    local itemBase = ItemUtils.GetItemBase(itemInfo.id)
    local onSellMaxNum = math.min(self.ONSELL_MAX_NUM_PER_GRID, itemBase.pilemax)
    if expNum > onSellMaxNum then
      local int, point = math.modf(expNum / onSellMaxNum)
      if point > 0 then
        int = int + 1
      end
      local count = int
      for k, v in pairs(self.selectSkillIndex) do
        if v ~= index then
          if v <= #PitchItemOnShelfPanel.Instance().skillWeaponList then
            local skill2 = PitchItemOnShelfPanel.Instance().skillWeaponList[v]
            local itemIndex2 = self.levelSelectTbl[v]
            local itemInfo2 = skill2.unlockSkillInfo[itemIndex2]
            count = count + itemInfo2.gridNum
          else
            count = count + PitchItemOnShelfPanel.Instance().enchantingSkill.gridNum
          end
        end
      end
      if count > self.canUseNum then
        Toast(string.format(textRes.Pitch[29], self.canUseNum))
        return
      end
      itemInfo.gridNum = int
    else
      itemInfo.gridNum = 1
    end
    price = itemInfo.price * itemInfo.priceRate
    itemInfo.num = expNum
  else
    local skill = PitchItemOnShelfPanel.Instance().enchantingSkill
    local itemBase = ItemUtils.GetItemBase(skill.itemId)
    local onSellMaxNum = math.min(self.ONSELL_MAX_NUM_PER_GRID, itemBase.pilemax)
    if expNum > onSellMaxNum then
      local int, point = math.modf(expNum / onSellMaxNum)
      if point > 0 then
        int = int + 1
      end
      local count = int
      for k, v in pairs(self.selectSkillIndex) do
        if v ~= index then
          if v <= #PitchItemOnShelfPanel.Instance().skillWeaponList then
            local skill2 = PitchItemOnShelfPanel.Instance().skillWeaponList[v]
            local itemIndex2 = self.levelSelectTbl[v]
            local itemInfo2 = skill2.unlockSkillInfo[itemIndex2]
            count = count + itemInfo2.gridNum
          else
            count = count + PitchItemOnShelfPanel.Instance().enchantingSkill.gridNum
          end
        end
      end
      if count > self.canUseNum then
        Toast(string.format(textRes.Pitch[29], self.canUseNum))
        return
      end
      skill.gridNum = int
    else
      skill.gridNum = 1
    end
    skill.num = expNum
    price = skill.price * skill.priceRate
  end
  Label_Num:GetComponent("UILabel"):set_text(expNum)
  local Group_Tax = self.uiTbl.Group_Right:FindDirect("Group_Tax")
  local Img_BgTax = Group_Tax:FindDirect("Img_BgTax")
  local Label_Tax = Img_BgTax:FindDirect("Label_Tax")
  local serviceMoney, _ = math.modf(price * 0.05 * expNum)
  Label_Tax:GetComponent("UILabel"):set_text(serviceMoney)
  self:UpdateGridNum()
  self:UpdateVigorNum()
end
def.method("number", "userdata").OnLeftButtonClick = function(self, index, lvLabel)
  local skill = PitchItemOnShelfPanel.Instance().skillWeaponList[index]
  local itemIndex = self.levelSelectTbl[index]
  if 1 <= itemIndex - 1 then
    itemIndex = itemIndex - 1
    self:UpdateBoth(index, itemIndex, skill, lvLabel)
  end
end
def.method("number", "userdata").OnRightButtonClick = function(self, index, lvLabel)
  local skill = PitchItemOnShelfPanel.Instance().skillWeaponList[index]
  local itemIndex = self.levelSelectTbl[index]
  local itemInfo = skill.unlockSkillInfo
  if itemIndex + 1 <= #skill.unlockSkillInfo then
    itemIndex = itemIndex + 1
    self:UpdateBoth(index, itemIndex, skill, lvLabel)
  end
end
def.method("number", "number", "table", "userdata").UpdateBoth = function(self, index, itemIndex, skill, lvLabel)
  self.levelSelectTbl[index] = itemIndex
  lvLabel:GetComponent("UILabel"):set_text(skill.unlockSkillInfo[itemIndex].openLevel)
  self:UpdateLeft(itemIndex, index)
  for k, v in pairs(self.selectSkillIndex) do
    if v == index then
      self:UpdateRight(itemIndex, index)
      break
    end
  end
end
def.method().OnShelfItemsClick = function(self)
  local level = require("Main.Hero.Interface").GetHeroProp().level
  if level < CommercePitchUtils.GetPitchOpenLevel() then
    Toast(string.format(textRes.Commerce[19], CommercePitchUtils.GetPitchOpenLevel()))
    return
  end
  if 0 == #self.selectSkillIndex then
    Toast(textRes.Pitch[28])
    return
  end
  local serviceMoney = 0
  local costVigor = 0
  for k, v in pairs(self.selectSkillIndex) do
    if v <= #PitchItemOnShelfPanel.Instance().skillWeaponList then
      local skill = PitchItemOnShelfPanel.Instance().skillWeaponList[v]
      local itemIndex = self.levelSelectTbl[v]
      local itemInfo = skill.unlockSkillInfo[itemIndex]
      local sellPrice = itemInfo.price * itemInfo.priceRate
      serviceMoney = serviceMoney + sellPrice * 0.05 * itemInfo.num
      costVigor = costVigor + LivingSkillUtility.GetCostVigor(skill.id, itemInfo.openLevel) * itemInfo.num
    else
      local skill = PitchItemOnShelfPanel.Instance().enchantingSkill
      local sellPrice = skill.price * skill.priceRate
      serviceMoney = serviceMoney + sellPrice * 0.05 * skill.num
      costVigor = costVigor + skill.needVigor * skill.num
    end
  end
  if ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER):lt(serviceMoney) == true then
    Toast(textRes.Pitch[26])
    return
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if costVigor > heroProp.energy then
    Toast(textRes.Pitch[35])
    return
  end
  for k, v in pairs(self.selectSkillIndex) do
    if v <= #PitchItemOnShelfPanel.Instance().skillWeaponList then
      local skill = PitchItemOnShelfPanel.Instance().skillWeaponList[v]
      local itemIndex = self.levelSelectTbl[v]
      local itemInfo = skill.unlockSkillInfo[itemIndex]
      local sellPrice = itemInfo.price * itemInfo.priceRate
      local CommercePitchProtocol = require("Main.CommerceAndPitch.CommercePitchProtocol")
      CommercePitchProtocol.CWuQIFuVigorSellReq(skill.id, itemInfo.id, sellPrice, itemInfo.num)
    else
      local skill = PitchItemOnShelfPanel.Instance().enchantingSkill
      local sellPrice = skill.price * skill.priceRate
      local CommercePitchProtocol = require("Main.CommerceAndPitch.CommercePitchProtocol")
      PitchData.Instance().itemPriceRecord[skill.itemId] = sellPrice
      CommercePitchProtocol.CFuMoSkillVigorSellReq(skill.id, skill.bagId, sellPrice, skill.num)
    end
  end
  self.m_base:DestroyPanel()
  self.m_base = nil
end
def.method().ShowServiceTips = function(self)
  local tipsId = CommercePitchUtils.GetPitchServiceTipsId()
  GUIUtils.ShowHoverTip(tipsId, 0, 0)
end
def.method().OnAddGridClick = function(self)
  local sellGridNum = PitchData.Instance():GetSellGridNum()
  local gridShowNum = sellGridNum + 1
  if gridShowNum >= CommercePitchUtils.GetStallMax() then
    Toast(textRes.Pitch[20])
  else
    CommonConfirmDlg.ShowConfirm(textRes.Pitch[9], string.format(textRes.Pitch[10], CommercePitchUtils.GetExpendStallCostYuanBao()), function(s)
      if s == 1 then
        if self.m_base then
          self.m_base:DestroyPanel()
        end
        PitchSellNode.ExtendGridCallback(s, nil)
      end
    end, nil)
  end
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.find(id, "Group_Skill0") then
    self:OnSkillSelect(clickobj, id)
  elseif "Btn_Left" == id then
    local index = tonumber(string.sub(clickobj.parent.parent.name, string.len("Group_Skill0") + 1))
    local obj = clickobj.parent:FindDirect("Label_BgSkillLv")
    self:OnLeftButtonClick(index, obj)
  elseif "Btn_Right" == id then
    local index = tonumber(string.sub(clickobj.parent.parent.name, string.len("Group_Skill0") + 1))
    local obj = clickobj.parent:FindDirect("Label_BgSkillLv")
    self:OnRightButtonClick(index, obj)
  elseif "Btn_MinusIP" == id then
    local rate = CommercePitchUtils.GetOnceAdjustPriceRate() / 10000
    self:UpdatePriceLabel(-rate)
  elseif "Btn_AddIP" == id then
    local rate = CommercePitchUtils.GetOnceAdjustPriceRate() / 10000
    self:UpdatePriceLabel(rate)
  elseif "Btn_MinusIN" == id then
    self:UpdateItemNum(-1)
  elseif "Btn_AddIN" == id then
    self:UpdateItemNum(1)
  elseif "Btn_Confirm" == id then
    self:OnShelfItemsClick()
  elseif "Btn_ActiveAdd" == id then
    self:OnAddGridClick()
  elseif "Btn_Tips" == id then
    self:ShowServiceTips()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_node.name
    })
  end
end
VigourOnShelfNode.Commit()
return VigourOnShelfNode
