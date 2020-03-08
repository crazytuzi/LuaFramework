local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local PitchItemOnShelfPanel = Lplus.Extend(ECPanelBase, "PitchItemOnShelfPanel")
local def = PitchItemOnShelfPanel.define
local instance
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemNode = require("Main.CommerceAndPitch.ui.OnShelf.ItemOnShelfNode")
local VigourNode = require("Main.CommerceAndPitch.ui.OnShelf.VigourOnShelfNode")
local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
local CommercePitchProtocol = require("Main.CommerceAndPitch.CommercePitchProtocol")
local LivingSkillData = require("Main.Skill.data.LivingSkillData")
local PitchData = require("Main.CommerceAndPitch.data.PitchData")
local MathHelper = require("Common.MathHelper")
def.field("function").callback = nil
def.field("table").tag = nil
def.const("table").NodeId = {ITEM = 1, VIGOUR = 2}
def.field("table").nodes = nil
def.field("number").curNode = 0
def.field("number").state = 0
def.const("table").StateConst = {Item = 1, Vigour = 2}
def.field("table").itemIdCanSell = nil
def.field("table").itemCanSell = nil
def.field("table").itemIds = nil
def.field("table").skillWeaponList = nil
def.field("table").enchantingSkill = nil
def.field("number").selectItemId = 0
def.field("number").selectItemKey = 0
def.field("boolean").m_pending = false
def.static("=>", PitchItemOnShelfPanel).Instance = function()
  if nil == instance then
    instance = PitchItemOnShelfPanel()
    instance.state = PitchItemOnShelfPanel.StateConst.Item
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
end
def.method().Reset = function(self)
  self.m_pending = false
end
def.override().OnCreate = function(self)
  self.nodes = {}
  local itemNode = self.m_panel:FindDirect("Img_Bg0/Group_Item")
  self.nodes[PitchItemOnShelfPanel.NodeId.ITEM] = ItemNode()
  self.nodes[PitchItemOnShelfPanel.NodeId.ITEM]:Init(self, itemNode)
  self.nodes[PitchItemOnShelfPanel.NodeId.ITEM]:SetCanUseNum(self.tag.canUseNum)
  local vigourNode = self.m_panel:FindDirect("Img_Bg0/Group_Active")
  self.nodes[PitchItemOnShelfPanel.NodeId.VIGOUR] = VigourNode()
  self.nodes[PitchItemOnShelfPanel.NodeId.VIGOUR]:Init(self, vigourNode)
  self.nodes[PitchItemOnShelfPanel.NodeId.VIGOUR]:SetCanUseNum(self.tag.canUseNum)
  if PitchItemOnShelfPanel.StateConst.Item == self.state then
    self:SwitchTo(PitchItemOnShelfPanel.NodeId.ITEM)
    local toggle = self.m_panel:FindDirect("Img_Bg0/Tab_Item"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif PitchItemOnShelfPanel.StateConst.Vigour == self.state then
    self:SwitchTo(PitchItemOnShelfPanel.NodeId.VIGOUR)
    local toggle = self.m_panel:FindDirect("Img_Bg0/Tab_Active"):GetComponent("UIToggle")
    toggle:set_value(true)
  end
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, PitchItemOnShelfPanel.OnEnergyChanged)
end
def.override().OnDestroy = function(self)
  self.m_pending = false
  self.selectItemId = 0
  self.selectItemKey = 0
  Event.UnregisterEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.ITEM_RECOMMEND_PRICE_RES, PitchItemOnShelfPanel.OnSSyncRecommandPriceChange)
  Event.UnregisterEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.FUMO_SKILL_PREVIEW_RES, PitchItemOnShelfPanel.OnEnchantRes)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, PitchItemOnShelfPanel.OnEnergyChanged)
end
def.static("table", "table").OnEnergyChanged = function(params, context)
  if PitchItemOnShelfPanel.Instance().curNode == PitchItemOnShelfPanel.NodeId.VIGOUR then
    PitchItemOnShelfPanel.Instance().nodes[PitchItemOnShelfPanel.Instance().curNode]:UpdateVigor()
  end
end
def.static("table", "table").OnSSyncRecommandPriceChange = function(params, context)
  PitchItemOnShelfPanel.Instance():UpdateItemRecommandPrice(params[1])
end
def.static("table", "table").OnEnchantRes = function(params, context)
  if PitchItemOnShelfPanel.Instance().enchantingSkill.id == params[1] then
    PitchItemOnShelfPanel.Instance().enchantingSkill.needVigor = params[2]
    PitchItemOnShelfPanel.Instance().enchantingSkill.itemId = params[3]
    PitchItemOnShelfPanel.Instance():RequireToItemNewPrice()
  end
end
def.method().InitItem = function(self)
  self.itemCanSell = {}
  self.itemIdCanSell = {}
  self.itemIds = {}
  local indexGen = 1
  local index = indexGen
  local expireItems = PitchData.Instance():GetExpireSellItems()
  for i, v in ipairs(expireItems) do
    local itemInfo = {}
    itemInfo.shoppingid = v.shoppingid
    itemInfo.price = v.price
    itemInfo.id = v.item.id
    local itemBase = ItemUtils.GetItemBase(itemInfo.id)
    itemInfo.itemBase = itemBase
    itemInfo.count = v.item.number
    itemInfo.isExpireItem = true
    itemInfo.item = v.item
    index = indexGen
    indexGen = indexGen + 1
    self.itemCanSell[index] = itemInfo
    table.insert(self.itemIdCanSell, {
      isExpireItem = true,
      index = index,
      id = itemInfo.id,
      type = itemBase.itemType
    })
    table.insert(self.itemIds, v.item.id)
  end
  local items = ItemModule.Instance():GetAllItems()
  local count = 0
  local tmpCount = 0
  for bagId, bagItems in pairs(items) do
    for k, v in pairs(bagItems) do
      local bCanSell = CommercePitchUtils.CanItemPitchToSell(v.id, v)
      if bCanSell then
        local itemInfo = {}
        itemInfo.key = k
        local price, minPrice, maxPrice = CommercePitchUtils.GetItemPitchInfo(v.id)
        itemInfo.price = price
        itemInfo.id = v.id
        local itemBase = ItemUtils.GetItemBase(v.id)
        itemInfo.itemBase = itemBase
        itemInfo.count = v.number
        itemInfo.bagId = bagId
        index = indexGen
        indexGen = indexGen + 1
        self.itemCanSell[index] = itemInfo
        table.insert(self.itemIdCanSell, {
          index = index,
          id = v.id,
          type = itemBase.itemType
        })
        table.insert(self.itemIds, v.id)
      end
    end
  end
  table.sort(self.itemIdCanSell, function(l, r)
    if l.isExpireItem and not r.isExpireItem then
      return true
    end
    if not l.isExpireItem and r.isExpireItem then
      return false
    end
    if l.type ~= r.type then
      return l.type < r.type
    else
      return l.id < r.id
    end
  end)
  for i, v in ipairs(self.itemIdCanSell) do
    self.itemIdCanSell[i] = v.index
  end
end
def.method().InitSkill = function(self)
  self.skillWeaponList = {}
  local skillBagList = LivingSkillData.Instance():GetBagList()
  local LifeSkillBagShowTypeEnum = require("consts.mzm.gsp.skill.confbean.LifeSkillBagShowTypeEnum")
  for k, v in pairs(skillBagList) do
    if v.showType == LifeSkillBagShowTypeEnum.type1 then
      local unlockSkill = LivingSkillData.Instance():GetUnLockSkill(v.id)
      v.unlockSkillInfo = {}
      if #unlockSkill > 0 then
        v.unlock = true
        for m, n in pairs(unlockSkill) do
          local price, minPrice, maxPrice = CommercePitchUtils.GetItemPitchInfo(n.id)
          n.price = price
          n.num = 1
          n.priceRate = 1
          n.gridNum = 1
          table.insert(v.unlockSkillInfo, n)
        end
      else
        v.unlock = false
      end
      table.insert(self.skillWeaponList, v)
    end
  end
  local SkillMgr = require("Main.Skill.SkillMgr")
  self.enchantingSkill = nil
  if SkillMgr.Instance():GetEnchantingSkill() then
    self.enchantingSkill = {}
    local skill = SkillMgr.Instance():GetEnchantingSkill()
    self.enchantingSkill.id = skill.id
    self.enchantingSkill.level = skill.level
    self.enchantingSkill.bagId = skill.bagId
    self.enchantingSkill.unlock = skill:IsUnlock()
  end
end
def.method("table").UpdateItemRecommandPrice = function(self, tbl)
  local minRate = CommercePitchUtils.GetAdjustPriceRateMin() / 10000
  local maxRate = CommercePitchUtils.GetAdjustPriceRateMax() / 10000
  for k, v in pairs(self.itemCanSell) do
    local itemId = v.id
    if tbl[itemId] and tbl[itemId] > 0 then
      warn("UpdateItemRecommandPrice", itemId, v.price, tbl[itemId])
      v.recommandPrice = tbl[itemId]
      if not v.isExpireItem then
        v.price = v.recommandPrice
      end
    end
  end
  for k, v in pairs(self.skillWeaponList) do
    if 0 < #v.unlockSkillInfo then
      for m, n in pairs(v.unlockSkillInfo) do
        if tbl[n.id] then
          n.price = tbl[n.id]
        end
        if PitchData.Instance().itemPriceRecord[n.id] then
          local price = PitchData.Instance().itemPriceRecord[n.id]
          local priceRate = price / n.price
          priceRate = MathHelper.Clamp(priceRate, minRate, maxRate)
          n.priceRate = priceRate
        end
      end
    end
  end
  if self.enchantingSkill then
    local itemId = self.enchantingSkill.itemId
    local recommandPrice = 0
    local price = 0
    if tbl[self.enchantingSkill.itemId] then
      recommandPrice = tbl[self.enchantingSkill.itemId]
    else
      local price, minPrice, maxPrice = CommercePitchUtils.GetItemPitchInfo(self.enchantingSkill.itemId)
      recommandPrice = price
    end
    if PitchData.Instance().itemPriceRecord[itemId] then
      price = PitchData.Instance().itemPriceRecord[itemId]
    else
      price = recommandPrice
    end
    local priceRate = price / recommandPrice
    priceRate = MathHelper.Clamp(priceRate, minRate, maxRate)
    self.enchantingSkill.num = 1
    self.enchantingSkill.gridNum = 1
    self.enchantingSkill.priceRate = priceRate
    self.enchantingSkill.price = recommandPrice
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_PITCH_TAN_PANEL, 0)
end
def.method().RequireToItemNewPrice = function(self)
  local ids = self.itemIds
  for k, v in pairs(self.skillWeaponList) do
    if #v.unlockSkillInfo > 0 then
      for m, n in pairs(v.unlockSkillInfo) do
        table.insert(ids, n.id)
      end
    end
  end
  if self.enchantingSkill then
    table.insert(ids, self.enchantingSkill.itemId)
  end
  CommercePitchProtocol.CRecommendPriceChangeReq(ids)
end
def.method().RequireToEnchantInfo = function(self)
  if self.enchantingSkill then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.skill.CFuMoSkillPreviewReq").new(self.enchantingSkill.id, self.enchantingSkill.bagId))
  else
    self:RequireToItemNewPrice()
  end
end
def.static("function", "table", "number", "number").ShowItemOnShelf = function(callback, tag, selectItemId, selectItemKey)
  local dlg = PitchItemOnShelfPanel.Instance()
  if dlg.m_pending then
    return
  end
  dlg.m_pending = true
  dlg.callback = callback
  dlg.tag = tag
  dlg.state = PitchItemOnShelfPanel.StateConst.Item
  dlg.selectItemId = selectItemId
  dlg.selectItemKey = selectItemKey
  dlg:InitItem()
  dlg:InitSkill()
  dlg:RequireToEnchantInfo()
  Event.RegisterEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.ITEM_RECOMMEND_PRICE_RES, PitchItemOnShelfPanel.OnSSyncRecommandPriceChange)
  Event.RegisterEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.FUMO_SKILL_PREVIEW_RES, PitchItemOnShelfPanel.OnEnchantRes)
end
def.method("number").SwitchTo = function(self, nodeId)
  self.curNode = 0
  for k, v in pairs(self.nodes) do
    if nodeId == k then
      self.curNode = nodeId
      v:Show()
    else
      v:Hide()
    end
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
    self = nil
  elseif "Modal" == id then
    self:DestroyPanel()
    self = nil
  elseif "Tab_Item" == id then
    self:SwitchTo(PitchItemOnShelfPanel.NodeId.ITEM)
  elseif "Tab_Active" == id then
    self:SwitchTo(PitchItemOnShelfPanel.NodeId.VIGOUR)
  else
    self.nodes[self.curNode]:onClickObj(clickobj)
  end
end
PitchItemOnShelfPanel.Commit()
return PitchItemOnShelfPanel
