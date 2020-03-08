local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local EC = require("Types.Vector3")
local ChooseCharacterPanel = Lplus.Extend(ECPanelBase, "ChooseCharacterPanel")
local MultiOccupationData = require("Main.MultiOccupation.data.MultiOccupationData")
local MultiOccupationUtils = require("Main.MultiOccupation.MultiOccupationUtils")
local ItemModule = require("Main.Item.ItemModule")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemUtils = require("Main.Item.ItemUtils")
local def = ChooseCharacterPanel.define
local instance
local MIN_SHOW_GRID_COUNT = 6
def.field("number").npcId = 0
def.field("number").selectIndex = 0
def.field("number").ownOccupation = 0
def.field("number").lastCharacterGridNum = 1
def.field("table").uiTbl = nil
def.field("table").models = nil
def.field("table").occupationInfo = nil
def.field("boolean").useItem = false
def.static("=>", ChooseCharacterPanel).Instance = function()
  if not instance then
    instance = ChooseCharacterPanel()
    instance.m_TrigGC = true
    instance.m_HideOnDestroy = true
  end
  return instance
end
def.method("number").ShowPanel = function(self, npcId)
  if self:IsShow() then
    self:DestroyPanel()
  end
  Event.RegisterEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.OccupationChange, ChooseCharacterPanel.OnMultiOccupationInfo)
  Event.RegisterEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.MultiOccupationInfo, ChooseCharacterPanel.OnMultiOccupationInfo)
  self:CreatePanel(RESPATH.PREFAB_CHOOSECHARACTER, GUILEVEL.MUTEX)
  self:SetModal(true)
  self.npcId = npcId
end
def.method().Reset = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
end
def.override().OnCreate = function(self)
  if not self.models then
    self.models = {}
  end
  self:InitUI()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, ChooseCharacterPanel.OnBagInfoSynchronized)
end
def.override().OnDestroy = function(self)
  if self.models then
    for k, model in pairs(self.models) do
      if model then
        model:Destroy()
        model = nil
      end
    end
    self.models = nil
  end
  self.useItem = false
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, ChooseCharacterPanel.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.OccupationChange, ChooseCharacterPanel.OnMultiOccupationInfo)
  Event.UnregisterEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.MultiOccupationInfo, ChooseCharacterPanel.OnMultiOccupationInfo)
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow then
    self:UpdateData()
    self:UpdateUI()
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if string.sub(id, 1, #"Img_Character_") == "Img_Character_" then
    local index = tonumber(string.sub(id, #"Img_Character_" + 1, -1))
    self:SelectOccupation(index)
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Open" then
    self:onBtnOpenClick()
  elseif id == "Btn_Tips" then
    self:onBtnTipsClick()
  else
    warn("ChooseCharacterPanel btn:", id)
  end
end
def.method().InitUI = function(self)
  if not self.uiTbl then
    self.uiTbl = {}
  end
  local uiTbl = self.uiTbl
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Label_1 = Img_Bg0:FindDirect("Label_1")
  local Label_OpenNumber = Img_Bg0:FindDirect("Label_OpenNumber")
  local Group_Money = Img_Bg0:FindDirect("Group_Money")
  local Label_Tips = Img_Bg0:FindDirect("Label_Tips")
  local Label_OwnNum = Group_Money:FindDirect("Label_Own/Img_BgCost/Label_CostNum")
  local Own_MoneyIcon = Group_Money:FindDirect("Label_Own/Img_BgCost/Img_MoneyIcon")
  local Own_GoldIcon = Group_Money:FindDirect("Label_Own/Img_BgCost/Img_GoldIcon")
  local Label_CostNum = Group_Money:FindDirect("Label_Cost/Img_BgCost/Label_CostNum")
  local Cost_MoneyIcon = Group_Money:FindDirect("Label_Cost/Img_BgCost/Img_MoneyIcon")
  local Cost_GoldIcon = Group_Money:FindDirect("Label_Cost/Img_BgCost/Img_GoldIcon")
  uiTbl.Label_1 = Label_1
  uiTbl.Label_OpenNumber = Label_OpenNumber
  uiTbl.Group_Money = Group_Money
  uiTbl.Label_Tips = Label_Tips
  uiTbl.Label_OwnNum = Label_OwnNum
  uiTbl.Label_CostNum = Label_CostNum
  uiTbl.Own_MoneyIcon = Own_MoneyIcon
  uiTbl.Own_GoldIcon = Own_GoldIcon
  uiTbl.Cost_MoneyIcon = Cost_MoneyIcon
  uiTbl.Cost_GoldIcon = Cost_GoldIcon
  local Character_Bar = Img_Bg0:FindDirect("Container/Panel/Bar")
  local Group_Character = Img_Bg0:FindDirect("Container/Scroll View/Group_Character")
  local Img_Character_1 = Group_Character:FindDirect("Img_Character_1")
  uiTbl.Group_Character = Group_Character
  uiTbl.Img_Character_1 = Img_Character_1
  uiTbl.Character_Bar = Character_Bar
end
def.method().UpdateData = function(self)
  local ownCount = 0
  local occupationInfo = MultiOccupationData.Instance():getOccupationInfo()
  self.occupationInfo = {}
  for id, occupation in pairs(occupationInfo) do
    if not MultiOccupationUtils.Instance():IsOccupationHided(id) then
      if occupation.own then
        ownCount = ownCount + 1
        occupation.sort = occupation.id + 100
      else
        occupation.sort = occupation.id
      end
      table.insert(self.occupationInfo, occupation)
    end
  end
  self.ownOccupation = ownCount
  table.sort(self.occupationInfo, function(a, b)
    return a.sort < b.sort
  end)
end
def.method().UpdateCharacterGridListCount = function(self)
  local lastCount = self.lastCharacterGridNum
  local curCount = #self.occupationInfo
  local Group_Character = self.uiTbl.Group_Character
  local gridTemplate = self.uiTbl.Img_Character_1
  local uiGrid = Group_Character:GetComponent("UIGrid")
  if curCount < MIN_SHOW_GRID_COUNT then
    curCount = MIN_SHOW_GRID_COUNT
  end
  if lastCount < curCount then
    for i = lastCount + 1, curCount do
      local uiGoName = string.format("Img_Character_%d", i)
      local uiGridGo = Group_Character:FindDirect(uiGoName)
      if not uiGridGo then
        uiGridGo = Object.Instantiate(gridTemplate)
        uiGridGo.name = uiGoName
        uiGrid:AddChild(uiGridGo.transform)
        uiGridGo.localScale = EC.Vector3.one
        uiGridGo:SetActive(true)
      end
    end
  else
    for i = lastCount, curCount + 1, -1 do
      local uiGridGo = Group_Character:GetChild(i - 1)
      if uiGridGo then
        Object.Destroy(uiGridGo)
      end
    end
  end
  self.lastCharacterGridNum = curCount
end
def.method().UpdateUI = function(self)
  self.uiTbl.Own_MoneyIcon:SetActive(false)
  self.uiTbl.Own_GoldIcon:SetActive(true)
  self.uiTbl.Cost_MoneyIcon:SetActive(false)
  self.uiTbl.Cost_GoldIcon:SetActive(true)
  local gold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  local needGold = MultiOccupationData.Instance():getNewOccupationNeedGold()
  self.uiTbl.Label_OwnNum:GetComponent("UILabel"):set_text(tostring(gold))
  self.uiTbl.Label_CostNum:GetComponent("UILabel"):set_text(needGold)
  if needGold <= gold:ToNumber() then
    self.uiTbl.Label_CostNum:GetComponent("UILabel"):set_textColor(Color.Color(1, 1, 1, 1))
  else
    self.uiTbl.Label_CostNum:GetComponent("UILabel"):set_textColor(Color.Color(1, 0, 0, 1))
  end
  self.uiTbl.Character_Bar:SetActive(#self.occupationInfo > 6)
  self:UpdateCharacterGridListCount()
  local Group_Character = self.uiTbl.Group_Character
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  for idx, occupation in pairs(self.occupationInfo) do
    local uiGoItem = Group_Character:FindDirect(("Img_Character_%d"):format(idx))
    if uiGoItem then
      self:FillOccupationInfo(idx, uiGoItem, occupation, heroProp.gender)
    end
  end
  for i = #self.occupationInfo + 1, MIN_SHOW_GRID_COUNT do
    local uiGoItem = Group_Character:FindDirect(("Img_Character_%d"):format(i))
    if uiGoItem then
      self:ClearOccupationInfo(uiGoItem)
    end
  end
  local uiGrid = Group_Character:GetComponent("UIGrid")
  uiGrid.repositionNow = true
  uiGrid:Reposition()
  self:SetImgCharacterSelect(self.selectIndex, false)
  self.uiTbl.Label_1:GetComponent("UILabel"):set_text(textRes.MultiOccupation[1])
  self.uiTbl.Label_OpenNumber:GetComponent("UILabel"):set_text(string.format(textRes.MultiOccupation[2], self.ownOccupation))
  self:UpdateItemInfo()
end
def.method().UpdateItemInfo = function(self)
  local cfgInfo = MultiOccupationData.Instance():getCurNewOccupationCfg()
  if not cfgInfo then
    return
  end
  local itemId = cfgInfo.itemid
  local itemCount = cfgInfo.itemNumber
  local useItem = false
  if itemId > 0 and itemCount > 0 then
    local count = ItemModule.Instance():GetItemCountById(itemId)
    if itemCount <= count then
      useItem = true
    end
  end
  self.useItem = useItem
  GUIUtils.SetActive(self.uiTbl.Group_Money, not useItem)
  GUIUtils.SetActive(self.uiTbl.Label_Tips, useItem)
  if useItem then
    GUIUtils.SetText(self.uiTbl.Label_Tips, textRes.MultiOccupation[23])
  end
end
def.method("number", "userdata", "table", "number").FillOccupationInfo = function(self, idx, uiItemGo, info, gender)
  if not uiItemGo then
    return
  end
  local occupation = info.id
  local Img_Grey = uiItemGo:FindDirect("Img_Grey")
  Img_Grey:SetActive(info.own)
  local Img_Opened = uiItemGo:FindDirect("Img_Opened")
  Img_Opened:SetActive(info.own)
  local Img_Selected = uiItemGo:FindDirect("Img_Selected")
  Img_Selected:SetActive(idx == self.selectIndex)
  local Model = uiItemGo:FindDirect("Model")
  local Model_Grey = uiItemGo:FindDirect("Model_Grey")
  if info.own then
    Model:SetActive(false)
    Model_Grey:SetActive(true)
    local file = string.format("Arts/Image/Icons/Functions/ChangeCharacterGrey_%d_%d.png.u3dext", occupation, gender)
    local tex = GameUtil.SyncLoad(file)
    Model_Grey:GetComponent("UITexture").mainTexture = tex
  else
    Model:SetActive(true)
    Model_Grey:SetActive(false)
    local file = string.format("Arts/Image/Icons/Functions/ChangeCharacter_%d_%d.png.u3dext", occupation, gender)
    local tex = GameUtil.SyncLoad(file)
    Model:GetComponent("UITexture").mainTexture = tex
  end
end
def.method("userdata").ClearOccupationInfo = function(self, uiItemGo)
  if not uiItemGo then
    return
  end
  local Img_Grey = uiItemGo:FindDirect("Img_Grey")
  Img_Grey:SetActive(true)
  local Img_Opened = uiItemGo:FindDirect("Img_Opened")
  Img_Opened:SetActive(false)
  local Img_Selected = uiItemGo:FindDirect("Img_Selected")
  Img_Selected:SetActive(false)
  local Model = uiItemGo:FindDirect("Model")
  local Model_Grey = uiItemGo:FindDirect("Model_Grey")
  Model:SetActive(false)
  Model_Grey:SetActive(false)
end
def.method().onBtnOpenClick = function(self)
  local ActiveCoolDownHours = constant.CMultiOccupConsts.ActiveCoolDownHours
  local ActiveCoolDownTime = ActiveCoolDownHours * 3600
  local time = GetServerTime() - MultiOccupationData.Instance():getActivateTime()
  if ActiveCoolDownTime > time then
    local strIime = MultiOccupationUtils.Instance():MakeTimeStr(ActiveCoolDownTime - time) or ""
    Toast(string.format(textRes.MultiOccupation[13], strIime))
    return
  end
  if self.selectIndex <= 0 then
    Toast(textRes.MultiOccupation[6])
    return
  end
  local occupation = self.occupationInfo[self.selectIndex]
  if not occupation then
    Toast(textRes.MultiOccupation[6])
    return
  end
  if occupation.own then
    Toast(textRes.MultiOccupation[7])
    return
  end
  local newOccupationId = occupation.id
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local curOccupationId = heroProp.occupation
  if heroProp.level < constant.CMultiOccupConsts.LevelLimit then
    Toast(string.format(textRes.MultiOccupation[11], constant.CMultiOccupConsts.LevelLimit))
    return
  end
  if self.useItem then
    self:ActiveOccupationUseItem(occupation, curOccupationId)
  else
    self:ActiveOccupationUseMoney(occupation, curOccupationId)
  end
end
def.method("table", "number").ActiveOccupationUseItem = function(self, occupation, curOccupationId)
  local ActiveCoolDownHours = constant.CMultiOccupConsts.ActiveCoolDownHours
  local newOccupationId = occupation.id
  local cfgInfo = MultiOccupationData.Instance():getCurNewOccupationCfg()
  local itemId = cfgInfo.itemid
  local itemCount = cfgInfo.itemNumber
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local coloredItemName = HtmlHelper.GetColoredItemName(itemId)
  local coloredItemName = HtmlHelper.ConvertHtmlColorToBBCode(coloredItemName)
  CommonConfirmDlg.ShowConfirm("", string.format(textRes.MultiOccupation[22], coloredItemName, itemCount, occupation.name, ActiveCoolDownHours), function(i, tag)
    if i == 1 then
      local haveItemCount = ItemModule.Instance():GetItemCountById(itemId)
      if haveItemCount < itemCount then
        Toast(textRes.MultiOccupation[24])
        return
      end
      local gold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.multioccupation.CActiveNewOccupationReq").new(newOccupationId, curOccupationId, gold, self.npcId))
      self:DestroyPanel()
    end
  end, nil)
end
def.method("table", "number").ActiveOccupationUseMoney = function(self, occupation, curOccupationId)
  local ActiveCoolDownHours = constant.CMultiOccupConsts.ActiveCoolDownHours
  local newOccupationId = occupation.id
  local gold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  local needGold = MultiOccupationData.Instance():getNewOccupationNeedGold()
  if needGold <= gold:ToNumber() then
    CommonConfirmDlg.ShowConfirm("", string.format(textRes.MultiOccupation[19], needGold, occupation.name, ActiveCoolDownHours), function(i, tag)
      if i == 1 then
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.multioccupation.CActiveNewOccupationReq").new(newOccupationId, curOccupationId, gold, self.npcId))
        self:DestroyPanel()
      end
    end, nil)
  else
    CommonConfirmDlg.ShowConfirm("", textRes.MultiOccupation[5], function(i, tag)
      if i == 1 then
        GoToBuyGold(false)
      end
    end, nil)
  end
end
def.method().onBtnTipsClick = function(self)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(701609916)
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
def.method("number").SelectOccupation = function(self, idx)
  local occupation = self.occupationInfo[idx]
  if not occupation or occupation.own then
    return
  end
  self:SetImgCharacterSelect(self.selectIndex, false)
  self.selectIndex = idx
  self:SetImgCharacterSelect(self.selectIndex, true)
end
def.method("number", "boolean").SetImgCharacterSelect = function(self, idx, active)
  if self.selectIndex <= 0 then
    return
  end
  local uiGridGo = self.uiTbl.Group_Character:GetChild(idx - 1)
  if uiGridGo then
    local Img_Selected = uiGridGo:FindDirect("Img_Selected")
    Img_Selected:SetActive(active)
  end
end
def.static("table", "table").OnMultiOccupationInfo = function(params, context)
  local self = ChooseCharacterPanel.Instance()
  if self.m_panel and not self.m_panel.isnil then
    self:UpdateData()
    self:UpdateUI()
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(params, context)
  local self = ChooseCharacterPanel.Instance()
  if self.m_panel and not self.m_panel.isnil then
    self:UpdateItemInfo()
  end
end
return ChooseCharacterPanel.Commit()
