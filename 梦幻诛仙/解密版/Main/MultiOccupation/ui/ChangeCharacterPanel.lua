local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local EC = require("Types.Vector3")
local ChangeCharacterPanel = Lplus.Extend(ECPanelBase, "ChangeCharacterPanel")
local MultiOccupationData = require("Main.MultiOccupation.data.MultiOccupationData")
local MultiOccupationUtils = require("Main.MultiOccupation.MultiOccupationUtils")
local ItemModule = require("Main.Item.ItemModule")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local def = ChangeCharacterPanel.define
local instance
local MIN_SHOW_GRID_COUNT = 6
def.field("number").npcId = 0
def.field("number").selectIndex = 0
def.field("number").lastCharacterGridNum = 1
def.field("table").uiTbl = nil
def.field("table").models = nil
def.field("table").occupationInfo = nil
def.static("=>", ChangeCharacterPanel).Instance = function()
  if not instance then
    instance = ChangeCharacterPanel()
    instance.m_TrigGC = true
    instance.m_HideOnDestroy = true
  end
  return instance
end
def.method("number").ShowPanel = function(self, npcId)
  if self:IsShow() then
    self:DestroyPanel()
  end
  Event.RegisterEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.OccupationChange, ChangeCharacterPanel.OnMultiOccupationInfo)
  Event.RegisterEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.MultiOccupationInfo, ChangeCharacterPanel.OnMultiOccupationInfo)
  self:CreatePanel(RESPATH.PREFAB_CHANGECHARACTER, GUILEVEL.MUTEX)
  self:SetModal(true)
  self.npcId = npcId
end
def.method().Reset = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
  if not self.models then
    self.models = {}
  end
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
  self.selectIndex = 0
  Event.UnregisterEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.OccupationChange, ChangeCharacterPanel.OnMultiOccupationInfo)
  Event.UnregisterEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.MultiOccupationInfo, ChangeCharacterPanel.OnMultiOccupationInfo)
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
  elseif id == "Btn_Change" then
    self:onBtnChangeClick()
  elseif id == "Btn_Tips" then
    self:onBtnTipsClick()
  else
    warn("ChangeCharacterPanel btn:", id)
  end
end
def.method().InitUI = function(self)
  if not self.uiTbl then
    self.uiTbl = {}
  end
  local uiTbl = self.uiTbl
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Label_1 = Img_Bg0:FindDirect("Label_1")
  local Label_Tips = Img_Bg0:FindDirect("Label_Tips")
  local Label_OwnNum = Img_Bg0:FindDirect("Label_Own/Img_BgCost/Label_CostNum")
  local Label_CostNum = Img_Bg0:FindDirect("Label_Cost/Img_BgCost/Label_CostNum")
  uiTbl.Label_1 = Label_1
  uiTbl.Label_Tips = Label_Tips
  uiTbl.Label_OwnNum = Label_OwnNum
  uiTbl.Label_CostNum = Label_CostNum
  local Character_Bar = Img_Bg0:FindDirect("Container/Panel/Bar")
  local Group_Character = Img_Bg0:FindDirect("Container/Scroll View/Group_Character")
  local Img_Character_1 = Group_Character:FindDirect("Img_Character_1")
  uiTbl.Group_Character = Group_Character
  uiTbl.Img_Character_1 = Img_Character_1
  uiTbl.Character_Bar = Character_Bar
end
def.method().UpdateData = function(self)
  local occupationInfo = MultiOccupationData.Instance():getOccupationInfo()
  local prop = Lplus.ForwardDeclare("HeroModule").Instance():GetHeroProp()
  local curOccupationId = prop.occupation
  self.occupationInfo = {}
  for id, occupation in pairs(occupationInfo) do
    if occupation.own and id ~= curOccupationId and not MultiOccupationUtils.Instance():IsOccupationHided(id) then
      occupation.sort = occupation.id
      table.insert(self.occupationInfo, occupation)
    end
  end
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
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local gold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  self.uiTbl.Label_OwnNum:GetComponent("UILabel"):set_text(tostring(gold))
  self.uiTbl.Label_CostNum:GetComponent("UILabel"):set_text(constant.CMultiOccupConsts.SwitchNeedGold)
  self.uiTbl.Character_Bar:SetActive(#self.occupationInfo > 6)
  if gold:ToNumber() >= constant.CMultiOccupConsts.SwitchNeedGold then
    self.uiTbl.Label_CostNum:GetComponent("UILabel"):set_textColor(Color.Color(1, 1, 1, 1))
  else
    self.uiTbl.Label_CostNum:GetComponent("UILabel"):set_textColor(Color.Color(1, 0, 0, 1))
  end
  self:UpdateCharacterGridListCount()
  local Group_Character = self.uiTbl.Group_Character
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
  self.uiTbl.Label_1:GetComponent("UILabel"):set_text(textRes.MultiOccupation[3])
end
def.method("number", "userdata", "table", "number").FillOccupationInfo = function(self, idx, uiItemGo, info, gender)
  if not uiItemGo then
    return
  end
  local occupation = info.id
  local Img_Grey = uiItemGo:FindDirect("Img_Grey")
  Img_Grey:SetActive(false)
  local Img_Selected = uiItemGo:FindDirect("Img_Selected")
  Img_Selected:SetActive(idx == self.selectIndex)
  local Model = uiItemGo:FindDirect("Model")
  Model:SetActive(true)
  local Model_Grey = uiItemGo:FindDirect("Model_Grey")
  Model_Grey:SetActive(false)
  local file = string.format("Arts/Image/Icons/Functions/ChangeCharacter_%d_%d.png.u3dext", occupation, gender)
  local tex = GameUtil.SyncLoad(file)
  Model:GetComponent("UITexture").mainTexture = tex
end
def.method("userdata").ClearOccupationInfo = function(self, uiItemGo)
  if not uiItemGo then
    return
  end
  local Img_Grey = uiItemGo:FindDirect("Img_Grey")
  Img_Grey:SetActive(true)
  local Img_Selected = uiItemGo:FindDirect("Img_Selected")
  Img_Selected:SetActive(false)
  local Model = uiItemGo:FindDirect("Model")
  local Model_Grey = uiItemGo:FindDirect("Model_Grey")
  Model:SetActive(false)
  Model_Grey:SetActive(false)
end
def.method().onBtnChangeClick = function(self)
  local SwitchCoolDownHours = constant.CMultiOccupConsts.SwitchCoolDownHours
  local SwitchCoolDownTimes = SwitchCoolDownHours * 3600
  local time = GetServerTime() - MultiOccupationData.Instance():getSwitchTime()
  if SwitchCoolDownTimes > time then
    local strIime = MultiOccupationUtils.Instance():MakeTimeStr(SwitchCoolDownTimes - time) or ""
    Toast(string.format(textRes.MultiOccupation[14], strIime))
    return
  end
  if self.selectIndex <= 0 then
    Toast(textRes.MultiOccupation[4])
    return
  end
  local occupation = self.occupationInfo[self.selectIndex]
  if not occupation then
    Toast(textRes.MultiOccupation[4])
    return
  end
  local newOccupationId = occupation.id
  local prop = Lplus.ForwardDeclare("HeroModule").Instance():GetHeroProp()
  local curOccupationId = prop.occupation
  local gold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
  local needGold = constant.CMultiOccupConsts.SwitchNeedGold
  if needGold <= gold:ToNumber() then
    CommonConfirmDlg.ShowConfirm("", string.format(textRes.MultiOccupation[10], needGold, occupation.name, SwitchCoolDownHours), function(i, tag)
      if i == 1 then
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.multioccupation.CSwitchOccupationReq").new(newOccupationId, curOccupationId, gold, self.npcId))
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
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(701609917)
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
def.method("number").SelectOccupation = function(self, idx)
  local occupation = self.occupationInfo[idx]
  if not occupation then
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
  local self = ChangeCharacterPanel.Instance()
  if self.m_panel and not self.m_panel.isnil then
    self:UpdateData()
    self:UpdateUI()
  end
end
return ChangeCharacterPanel.Commit()
