local Lplus = require("Lplus")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local ECGUIMan = require("GUI.ECGUIMan")
local ECPanelBase = require("GUI.ECPanelBase")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local MathHelper = require("Common.MathHelper")
local ItemTips = Lplus.Extend(ECPanelBase, "ItemTips")
local def = ItemTips.define
local dlg
def.const("table").ItemState = {
  None = 0,
  Bind = 1,
  Proprietary = 2,
  Rarity = 3
}
def.const("table").ArrowState = {
  None = 0,
  Left = 1,
  Right = 2,
  Both = 3
}
def.const("number").CONTENTMAXHEIGHT = 400
def.static("table", "string", "number", "boolean", "number", "number", "string", "string", OperationBase, "table", "number", "number", "string", "table", "number", "=>", ItemTips).ShowTip = function(pos, title, iconId, isEquiped, state, level, equipType, desc, topOperation, bottomOperation, bagId, itemKey, panelName, extInfo, godWeaponStage)
  local tip = ItemTips()
  tip.position = pos
  tip.title = title
  tip.iconId = iconId
  tip.isEquiped = isEquiped
  tip.state = state
  tip.level = level
  tip.equipType = equipType
  tip.desc = desc
  tip.topOperation = topOperation
  tip.bottomOperation = bottomOperation
  tip.bagId = bagId
  tip.itemKey = itemKey
  tip.panelName = panelName
  tip.extInfo = extInfo
  tip.godWeaponStage = godWeaponStage
  tip:CreatePanel(RESPATH.ITEMTIPS, 2)
  tip:SetOutTouchDisappear()
  return tip
end
def.static("table", "string", "number", "boolean", "number", "number", "string", "string", OperationBase, "table", "number", "number", "string", "number", "function", "table", "=>", ItemTips).ShowTipWithArrow = function(pos, title, iconId, isEquiped, state, level, equipType, desc, topOperation, bottomOperation, bagId, itemKey, panelName, arrowState, cb, extInfo)
  local tip = ItemTips()
  tip.position = pos
  tip.title = title
  tip.iconId = iconId
  tip.isEquiped = isEquiped
  tip.state = state
  tip.level = level
  tip.equipType = equipType
  tip.desc = desc
  tip.topOperation = topOperation
  tip.bottomOperation = bottomOperation
  tip.bagId = bagId
  tip.itemKey = itemKey
  tip.panelName = panelName
  tip.arrowCallback = cb
  tip.arrowState = arrowState
  tip.extInfo = extInfo
  tip.godWeaponStage = 0
  tip:CreatePanel(RESPATH.ITEMTIPS, 2)
  tip:SetOutTouchDisappear()
  return tip
end
def.field("table").position = nil
def.field("string").title = ""
def.field("number").iconId = 0
def.field("boolean").isEquiped = false
def.field("number").state = 0
def.field("number").level = 0
def.field("string").equipType = ""
def.field("string").desc = ""
def.field(OperationBase).topOperation = nil
def.field("table").bottomOperation = nil
def.field("number").bagId = 0
def.field("number").itemKey = 0
def.field("string").panelName = ""
def.field("number").sameOperationUseTimes = 0
def.field(OperationBase).lastOperation = nil
def.field("function").allUseCallback = nil
def.field("table").context = nil
def.field("function").arrowCallback = nil
def.field("number").arrowState = 0
def.field("table").extInfo = nil
def.field("number").godWeaponStage = 0
def.override().OnCreate = function(self)
  local tipFrame = self.m_panel:FindDirect("Table_Tips")
  local screenHeight = ECGUIMan.Instance().m_uiRootCom:get_activeHeight()
  tipFrame:set_localPosition(Vector.Vector3.new(0, screenHeight / 2, 0))
  self:UpdateInfo()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, ItemTips.OnBagInfoSynchronized)
end
def.method().UpdateInfo = function(self)
  self:UpdateTitle()
  self:TouchGameObject(self.m_panel, self.m_parent)
  self:UpdateContent()
  self:UpdateButton()
  if self.panelName ~= "" then
    self.m_panelName = self.panelName
    self.m_panel.name = self.panelName
  end
  self:SetLayer(ClientDef_Layer.Invisible)
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if self.m_panel == nil then
      return
    end
    local tipFrame = self.m_panel:FindDirect("Table_Tips")
    if tipFrame == nil then
      return
    end
    local uiTable = tipFrame:GetComponent("UITableResizeBackground")
    uiTable:Reposition()
    if self.position.auto then
      local bg = tipFrame:GetComponent("UISprite")
      local computeTipsAutoPosition = MathHelper.ComputeTipsAutoPosition
      if self.position.tipType == "y" then
        computeTipsAutoPosition = MathHelper.ComputeTipsAutoPositionY
      end
      local x, y = computeTipsAutoPosition(self.position.sourceX, self.position.sourceY, self.position.sourceW, self.position.sourceH, bg:get_width(), bg:get_height(), self.position.prefer)
      tipFrame:set_localPosition(Vector.Vector3.new(x, y + bg:get_height() / 2, 0))
    else
      local screenHeight = require("GUI.ECGUIMan").Instance().m_uiRootCom:get_activeHeight()
      local bg = tipFrame:GetComponent("UISprite")
      local top = self.position.y
      if self.position.vAlign and string.lower(self.position.vAlign) == "center" then
        top = top + bg:get_height() / 2
        if top > 0.5 * screenHeight then
          top = top + 0.5 * screenHeight - bottom
        end
      end
      local bottom = top - bg:get_height()
      local adjustY = top
      if bottom < -0.5 * screenHeight then
        adjustY = adjustY + -0.5 * screenHeight - bottom
      end
      tipFrame:set_localPosition(Vector.Vector3.new(self.position.x, adjustY, 0))
    end
    self:SetLayer(ClientDef_Layer.UI)
    local scroll = tipFrame:FindDirect("Widget_Scroll/ScrollView")
    local pnl = scroll:GetComponent("UIPanel")
    pnl.enabled = false
    pnl.enabled = true
  end)
end
def.method().UpdateTitle = function(self)
  local uiTexture = self.m_panel:FindDirect("Table_Tips/Title/Img_Item/Img_Icon"):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, self.iconId)
  local itemInfo = ItemModule.Instance():GetItemByBagIdAndItemKey(self.bagId, self.itemKey)
  local itemBase
  if itemInfo then
    itemBase = ItemUtils.GetItemBase(itemInfo.id)
  end
  if nil == itemBase and self.extInfo and self.extInfo.itemId then
    itemBase = ItemUtils.GetItemBase(self.extInfo.itemId)
  end
  local SpriteObj = self.m_panel:FindDirect("Table_Tips/Title/Img_Item")
  local itemId = itemBase and itemBase.id or 0
  GUIUtils.SetSprite(SpriteObj, ItemUtils.GetItemFrameByGodWeaponStage(self.godWeaponStage, itemId, itemBase))
  local title = self.m_panel:FindDirect("Table_Tips/Title")
  local titleLabel = title:FindDirect("Label_Name"):GetComponent("UILabel")
  titleLabel:set_text(self.title)
  local zhenPinImg = title:FindDirect("Img_ZhenPin")
  if self.state == ItemTips.ItemState.None then
    title:FindDirect("Img_Zhuan"):SetActive(false)
    title:FindDirect("Img_Bang"):SetActive(false)
    GUIUtils.SetActive(zhenPinImg, false)
  elseif self.state == ItemTips.ItemState.Bind then
    title:FindDirect("Img_Zhuan"):SetActive(false)
    title:FindDirect("Img_Bang"):SetActive(true)
    GUIUtils.SetActive(zhenPinImg, false)
  elseif self.state == ItemTips.ItemState.Proprietary then
    title:FindDirect("Img_Zhuan"):SetActive(true)
    title:FindDirect("Img_Bang"):SetActive(false)
    GUIUtils.SetActive(zhenPinImg, false)
  elseif self.state == ItemTips.ItemState.Rarity then
    title:FindDirect("Img_Zhuan"):SetActive(false)
    title:FindDirect("Img_Bang"):SetActive(false)
    GUIUtils.SetActive(zhenPinImg, true)
  end
  local levelLabel = title:FindDirect("Label_Lv"):GetComponent("UILabel")
  local levelLabelTitle = title:FindDirect("Label_LvTitle"):GetComponent("UILabel")
  local upSprite = self.m_panel:FindDirect("Table_Tips/Title/Img_Up")
  local downSprite = self.m_panel:FindDirect("Table_Tips/Title/Img_Down")
  upSprite:SetActive(false)
  downSprite:SetActive(false)
  if 0 <= self.level then
    levelLabel:set_text(self.level .. textRes.Item[128])
    levelLabelTitle:set_text(textRes.Item[8003])
    if self.extInfo then
      local myLevel = self.extInfo.myLevel
      local compareLevel = self.extInfo.compareLevel
      if myLevel and compareLevel then
        if myLevel > compareLevel then
          upSprite:SetActive(true)
        elseif myLevel < compareLevel then
          downSprite:SetActive(true)
        end
      end
    end
  else
    levelLabelTitle:set_text("")
    levelLabel:set_text("")
  end
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if itemBase ~= nil and itemBase.itemType == ItemType.FASHION_DRESS_ITEM then
    local FashionUtils = require("Main.Fashion.FashionUtils")
    local fashionItem = FashionUtils.GetFashionItemByUnlockItemId(itemBase.itemid)
    levelLabelTitle:set_text(textRes.Item[10012])
    if 0 >= fashionItem.effectTime then
      levelLabel:set_text(textRes.Fashion[3])
    else
      levelLabel:set_text(FashionUtils.ConvertHourToSentence(fashionItem.effectTime))
    end
  elseif itemBase ~= nil and itemBase.itemType == ItemType.FABAO_ARTIFACT_ITEM then
    local FabaoSpiritUtils = require("Main.FabaoSpirit.FabaoSpiritUtils")
    local LQItmeCfg = FabaoSpiritUtils.GetItemCfgByItemId(itemBase.itemid)
    if LQItmeCfg ~= nil and 0 >= LQItmeCfg.durationHour then
      levelLabel:set_text(textRes.FabaoSpirit[31])
      levelLabelTitle:set_text(textRes.FabaoSpirit[33])
    elseif LQItmeCfg ~= nil then
      local day = LQItmeCfg.durationHour / 24
      local hour = math.floor(LQItmeCfg.durationHour % 24)
      if day <= 0 then
        levelLabel:set_text(textRes.FabaoSpirit[32]:format(hour, textRes.FabaoSpirit[8]))
      else
        levelLabel:set_text(textRes.FabaoSpirit[32]:format(day, textRes.FabaoSpirit[7]))
      end
      levelLabelTitle:set_text(textRes.FabaoSpirit[33])
    end
  end
  local typeLabel = title:FindDirect("Label_Type"):GetComponent("UILabel")
  typeLabel:set_text(self.equipType)
  local equipImg = title:FindDirect("Img_Present")
  if self.isEquiped then
    equipImg:SetActive(true)
  else
    equipImg:SetActive(false)
  end
end
def.method().UpdateContent = function(self)
  local scrollwidget = self.m_panel:FindDirect("Table_Tips/Widget_Scroll")
  local scroll = scrollwidget:FindDirect("ScrollView")
  local HTML = scroll:FindDirect("Label_Describe"):GetComponent("NGUIHTML")
  local convert = string.gsub(self.desc, "\\n", "<br/>")
  HTML:ForceHtmlText(convert)
  local height = HTML:get_height()
  if height <= ItemTips.CONTENTMAXHEIGHT then
    scrollwidget:GetComponent("UIWidget"):set_height(height)
    scroll:GetComponent("UIPanel"):UpdateAnchors()
  else
    scrollwidget:GetComponent("UIWidget"):set_height(ItemTips.CONTENTMAXHEIGHT)
    scroll:GetComponent("UIPanel"):UpdateAnchors()
  end
end
def.method("string").AppendContent = function(self, strContent)
  self.desc = self.desc .. strContent
  if self.m_panel and not self.m_panel.isnil then
    self:UpdateContent()
    local tipFrame = self.m_panel:FindDirect("Table_Tips")
    local uiTable = tipFrame:GetComponent("UITableResizeBackground")
    uiTable:Reposition()
  end
end
def.method().UpdateButton = function(self)
  local TitleGO = self.m_panel:FindDirect("Table_Tips/Title")
  local infoBtn = self.m_panel:FindDirect("Table_Tips/Title/Btn_Info")
  if self.topOperation ~= nil then
    infoBtn:SetActive(true)
  else
    infoBtn:SetActive(false)
  end
  local fitBtn = self.m_panel:FindDirect("Table_Tips/Title/Btn_Try")
  if self.topOperation ~= nil then
    if self.topOperation:GetOperationName() == textRes.Item[9500] then
      infoBtn:SetActive(false)
      fitBtn:SetActive(true)
    else
      infoBtn:SetActive(true)
      fitBtn:SetActive(false)
    end
  else
    fitBtn:SetActive(false)
  end
  local Btn_Connect = TitleGO:FindDirect("Btn_Connect")
  local Btn_Share = TitleGO:FindDirect("Btn_Share")
  if self.topOperation ~= nil and self.topOperation:GetOperationName() == textRes.Item[9520] then
    local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
    local needConnect = false
    GUIUtils.SetActive(Btn_Connect, needConnect)
    GUIUtils.SetActive(Btn_Share, true)
    GUIUtils.SetActive(infoBtn, false)
  else
    GUIUtils.SetActive(Btn_Connect, false)
    GUIUtils.SetActive(Btn_Share, false)
  end
  local use = self.bottomOperation
  local count = #use
  if count == 0 then
    self.m_panel:FindDirect("Table_Tips/Container_Btn"):SetActive(false)
  elseif count == 1 then
    self.m_panel:FindDirect("Table_Tips/Container_Btn/Panel_Btn/Btn_More"):SetActive(false)
    self.m_panel:FindDirect("Table_Tips/Container_Btn/Panel_Btn/Btn_Use"):SetActive(false)
    self.m_panel:FindDirect("Table_Tips/Container_Btn/Panel_Btn/Btn_Sell"):SetActive(false)
    local oneButton = self.m_panel:FindDirect("Table_Tips/Container_Btn/Panel_Btn/Btn_Channel")
    oneButton:SetActive(true)
    local label = oneButton:FindDirect("Label_Channel"):GetComponent("UILabel")
    label:set_text(use[1]:GetOperationName())
  elseif count == 2 then
    local rightButton = self.m_panel:FindDirect("Table_Tips/Container_Btn/Panel_Btn/Btn_Use")
    rightButton:SetActive(true)
    rightButton:FindDirect("Label_Use"):GetComponent("UILabel"):set_text(use[1]:GetOperationName())
    local leftButton = self.m_panel:FindDirect("Table_Tips/Container_Btn/Panel_Btn/Btn_Sell")
    leftButton:SetActive(true)
    leftButton:FindDirect("Label_Sell"):GetComponent("UILabel"):set_text(use[2]:GetOperationName())
    self.m_panel:FindDirect("Table_Tips/Container_Btn/Panel_Btn/Btn_More"):SetActive(false)
    self.m_panel:FindDirect("Table_Tips/Container_Btn/Panel_Btn/Btn_Channel"):SetActive(false)
  elseif count > 2 then
    local rightButton = self.m_panel:FindDirect("Table_Tips/Container_Btn/Panel_Btn/Btn_Use")
    rightButton:SetActive(true)
    rightButton:FindDirect("Label_Use"):GetComponent("UILabel"):set_text(use[1]:GetOperationName())
    local leftButton = self.m_panel:FindDirect("Table_Tips/Container_Btn/Panel_Btn/Btn_More")
    leftButton:SetActive(true)
    local popup = leftButton:GetComponent("UIPopupButton")
    local items = {}
    for i = 2, #use do
      table.insert(items, use[i]:GetOperationName())
    end
    popup:set_items(items)
    self.m_panel:FindDirect("Table_Tips/Container_Btn/Panel_Btn/Btn_Sell"):SetActive(false)
    self.m_panel:FindDirect("Table_Tips/Container_Btn/Panel_Btn/Btn_Channel"):SetActive(false)
  end
  self:ShowArrow(self.arrowState)
end
def.method("number").ShowArrow = function(self, arrowState)
  local arrows = self.m_panel:FindDirect("Group_Btn")
  local leftArrow = arrows:FindDirect("Btn_Left")
  local rightArrow = arrows:FindDirect("Btn_Right")
  if self.arrowState == ItemTips.ArrowState.None then
    arrows:SetActive(false)
  elseif self.arrowState == ItemTips.ArrowState.Both then
    arrows:SetActive(true)
    leftArrow:SetActive(true)
    rightArrow:SetActive(true)
    UIDelayShow.DelayShow(arrows, 3)
  elseif self.arrowState == ItemTips.ArrowState.Left then
    arrows:SetActive(true)
    leftArrow:SetActive(true)
    rightArrow:SetActive(false)
    UIDelayShow.DelayShow(arrows, 3)
  elseif self.arrowState == ItemTips.ArrowState.Right then
    arrows:SetActive(true)
    leftArrow:SetActive(false)
    rightArrow:SetActive(true)
    UIDelayShow.DelayShow(arrows, 3)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Use" then
    local ope = self.bottomOperation[1]
    local canAllUse = self:tryAllUse(ope)
    if not canAllUse then
      local close = ope:Operate(self.bagId, self.itemKey, self.m_panel, self.context)
      if close then
        self:DestroyPanel()
        self = nil
      else
        self:CheckExist()
      end
    else
      self:CheckExist()
    end
  elseif id == "Btn_Channel" then
    local ope = self.bottomOperation[1]
    local canAllUse = self:tryAllUse(ope)
    if not canAllUse then
      local close = ope:Operate(self.bagId, self.itemKey, self.m_panel, self.context)
      if close then
        self:DestroyPanel()
        self = nil
      else
        self:CheckExist()
      end
    else
      self:CheckExist()
    end
  elseif id == "Btn_Sell" then
    local ope = self.bottomOperation[2]
    local close = ope:Operate(self.bagId, self.itemKey, self.m_panel, self.context)
    if close then
      self:DestroyPanel()
      self = nil
    else
      self:CheckExist()
    end
  elseif id == "Btn_Info" then
    local ope = self.topOperation
    local close = ope:Operate(self.bagId, self.itemKey, self.m_panel, self.context)
    if close then
      self:DestroyPanel()
      self = nil
    else
      self:CheckExist()
    end
  elseif id == "Btn_More" then
  elseif string.find(id, "sp_") then
    local skillId = tonumber(string.sub(id, 4))
    local source = self.m_panel:FindDirect("Table_Tips")
    local position = source:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = self.m_panel:FindDirect("Table_Tips"):GetComponent("UISprite")
    require("Main.Skill.SkillTipMgr").Instance():ShowPetTip(skillId, screenPos.x, screenPos.y - sprite:get_height() / 2, sprite:get_width(), sprite:get_height(), 0)
  elseif string.find(id, "se_") then
    local skillId = tonumber(string.sub(id, 4))
    local source = self.m_panel:FindDirect("Table_Tips")
    local position = source:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = self.m_panel:FindDirect("Table_Tips"):GetComponent("UISprite")
    require("Main.Skill.SkillTipMgr").Instance():ShowTipById(skillId, screenPos.x, screenPos.y - sprite:get_height() / 2, sprite:get_width(), sprite:get_height(), 0)
  elseif string.find(id, "item_") then
    local itemId = tonumber(string.sub(id, 6))
    local source = self.m_panel:FindDirect("Table_Tips")
    local position = source:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = self.m_panel:FindDirect("Table_Tips"):GetComponent("UISprite")
    local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
    ItemTipsMgr.Instance():ShowBasicTipsRename(itemId, screenPos.x, screenPos.y - sprite:get_height() / 2, sprite:get_width(), sprite:get_height(), 0, true, "embed")
  elseif string.find(id, "fashionskill_") then
    local skillId = tonumber(string.sub(id, 14))
    local source = self.m_panel:FindDirect("Table_Tips")
    local position = source:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = self.m_panel:FindDirect("Table_Tips"):GetComponent("UISprite")
    require("Main.Skill.SkillTipMgr").Instance():ShowTipById(skillId, screenPos.x, screenPos.y - sprite:get_height() / 2, sprite:get_width(), sprite:get_height(), 0)
  elseif string.find(id, "jewel_") then
    local strs = string.split(id, "_")
    local jewelId = tonumber(strs[2])
    local source = self.m_panel:FindDirect("Table_Tips")
    local position = source:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = self.m_panel:FindDirect("Table_Tips"):GetComponent("UISprite")
    local tips = require("Main.Item.ItemTipsMgr").Instance():ShowJewelPropTips(jewelId, screenPos.x, screenPos.y - sprite:get_height() / 2, sprite:get_width(), sprite:get_height(), "JewelPropTips", true)
  elseif id == "Btn_Right" then
    self.arrowCallback(1)
    self:DestroyPanel()
  elseif id == "Btn_Left" then
    self.arrowCallback(-1)
    self:DestroyPanel()
  elseif id == "Btn_Try" then
    local hpInterface = require("Main.Hero.Interface")
    local heroProp = hpInterface.GetHeroProp()
    local herogender = heroProp.gender
    local heroOccupation = heroProp.occupation
    local topOpe = self.topOperation
    if ItemUtils.CanOpenFitRoom(topOpe.mItemType, herogender, heroOccupation) then
      topOpe:Operate(self.bagId, self.itemKey, self.m_panel, self.context)
    else
      Toast(textRes.Item[9501])
    end
  elseif id == "Btn_Share" then
    local topOpe = self.topOperation
    local context = self.context or {}
    context.id = id
    topOpe:Operate(self.bagId, self.itemKey, self.m_panel, context)
  elseif id == "Btn_Connect" then
    local topOpe = self.topOperation
    local context = self.context or {}
    context.id = id
    topOpe:Operate(self.bagId, self.itemKey, self.m_panel, context)
    self:DestroyPanel()
  else
    self:DestroyPanel()
    self = nil
  end
end
def.method("function").SetAllUseCallback = function(self, callback)
  self.allUseCallback = callback
end
def.method("table").SetOperateContext = function(self, ctx)
  self.context = ctx
end
def.method(OperationBase, "=>", "boolean").tryAllUse = function(self, ope)
  local bRet = false
  if self.lastOperation == ope then
    self.sameOperationUseTimes = self.sameOperationUseTimes + 1
  else
    self.lastOperation = ope
    self.sameOperationUseTimes = 1
  end
  if self.sameOperationUseTimes == 3 then
    local item = ItemModule.Instance():GetItemByBagIdAndItemKey(self.bagId, self.itemKey)
    if item == nil or 1 >= item.number then
      return false
    end
    if self.allUseCallback ~= nil then
      self.allUseCallback(item.id, self.bagId, self.itemKey)
      bRet = true
    end
    if ope:OperateAll(self.bagId, self.itemKey, self.m_panel, self.context) then
      function ope.UserOperation()
        self:CheckExist()
        ope.UserOperation = nil
      end
      bRet = true
    end
  end
  return bRet
end
def.method().CheckExist = function(self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, ItemTips.OnBagInfoSynchronized, self)
end
def.method()._CheckExist = function(self)
  if self.bagId ~= 0 then
    local item = ItemModule.Instance():GetItemByBagIdAndItemKey(self.bagId, self.itemKey)
    if item == nil then
      self:DestroyPanel()
    end
  end
end
def.method("string", "string", "number").onSelect = function(self, id, selected, index)
  if id == "Btn_More" and index ~= -1 then
    GameUtil.AddGlobalLateTimer(0.1, true, function()
      local ope = self.bottomOperation[index + 2]
      local close = ope:Operate(self.bagId, self.itemKey, self.m_panel, self.context)
      if close then
        self:DestroyPanel()
        self = nil
      else
        self:CheckExist()
      end
    end)
  end
end
def.method("table").OnBagInfoSynchronized = function(self, params)
  self:_CheckExist()
end
ItemTips.Commit()
return ItemTips
