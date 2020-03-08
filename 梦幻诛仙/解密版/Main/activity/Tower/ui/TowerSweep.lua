local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TowerSweep = Lplus.Extend(ECPanelBase, "TowerSweep")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local TowerMgr = Lplus.ForwardDeclare("TowerMgr")
local ItemModule = require("Main.Item.ItemModule")
local def = TowerSweep.define
local instance
def.static("=>", TowerSweep).Instance = function(self)
  if instance == nil then
    instance = TowerSweep()
  end
  return instance
end
def.field("number").m_activityId = 0
def.field("number").m_openId = 0
def.field("number").m_high = 0
def.field("number").m_start = 0
def.field("number").m_end = 0
def.field("boolean").m_useYuanBao = false
def.field("number").m_costYuanBao = 0
def.field("number").m_cost = 0
def.field("number").m_have = 0
def.static("number").ShowTowerSweep = function(activityId)
  local self = TowerSweep.Instance()
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.m_activityId = activityId
  local actCfg = TowerMgr.Instance():GetTowerActivityCfg(self.m_activityId)
  if actCfg then
    self.m_openId = actCfg.sweepSwithId
    self:CreatePanel(RESPATH.PREFAB_TOWER_SWEEP, 2)
    self:SetModal(true)
  else
    self.m_activityId = 0
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, TowerSweep.OnFunctionOpenChange, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, TowerSweep.OnBagChange, self)
  self:UpdateDesc()
  self:UpdateItem()
  self:UpdateSweep()
  self:UpdateCost()
  self:SetUseYuanbao(false)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, TowerSweep.OnFunctionOpenChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, TowerSweep.OnBagChange)
  self.m_activityId = 0
  self.m_openId = 0
  self.m_high = 0
  self.m_start = 0
  self.m_end = 0
  self.m_useYuanBao = false
  self.m_costYuanBao = 0
  self.m_cost = 0
  self.m_have = 0
end
def.method().UpdateDesc = function(self)
  local descLbl = self.m_panel:FindDirect("Img_Bg0/Group_SetLevel/Label_Title")
  local noSweepFloors = TowerMgr.Instance():GetNoSweepFloor(self.m_activityId)
  if #noSweepFloors > 0 then
    descLbl:GetComponent("UILabel"):set_text(textRes.activity[935] .. string.format(textRes.activity[936], table.concat(noSweepFloors, ",")))
  else
    descLbl:GetComponent("UILabel"):set_text(textRes.activity[935])
  end
end
def.method().UpdateItem = function(self)
  local itemGroup = self.m_panel:FindDirect("Img_Bg0/Group_Item")
  local nameLbl = itemGroup:FindDirect("Label_Name")
  local bg = itemGroup:FindDirect("Img_Item")
  local tex = bg:FindDirect("Img_Icon")
  local actCfg = TowerMgr.Instance():GetTowerActivityCfg(self.m_activityId)
  if actCfg then
    local itemBase = ItemUtils.GetItemBase(actCfg.sweepCostItemId)
    if itemBase then
      nameLbl:GetComponent("UILabel"):set_text(itemBase.name)
      bg:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", itemBase.namecolor))
      GUIUtils.FillIcon(tex:GetComponent("UITexture"), itemBase.icon)
    end
  end
end
def.method().UpdateSweep = function(self)
  local highFloor, startFloor, endFloor = TowerMgr.Instance():GetSweepData(self.m_activityId)
  self.m_high = highFloor
  self:UpdateHighFloor()
  self:UpdateFrom(startFloor)
  self:UpdateTo(endFloor)
end
def.method().UpdateHighFloor = function(self)
  local lbl = self.m_panel:FindDirect("Img_Bg0/Group_SubTitle/Label_SweepNum")
  lbl:GetComponent("UILabel"):set_text(tostring(self.m_high))
end
def.method("number").UpdateFrom = function(self, from)
  self.m_start = from
  local lbl = self.m_panel:FindDirect("Img_Bg0/Group_SetLevel/Group_CurLevel/Label_Level")
  lbl:GetComponent("UILabel"):set_text(tostring(from))
  self:UpdateCost()
end
def.method("number").UpdateTo = function(self, to)
  self.m_end = to
  local lbl = self.m_panel:FindDirect("Img_Bg0/Group_SetLevel/Group_NextLevel/Label_Level")
  lbl:GetComponent("UILabel"):set_text(tostring(to))
  self:UpdateCost()
end
def.method().UpdateCost = function(self)
  local itemGroup = self.m_panel:FindDirect("Img_Bg0/Group_Item")
  local numLbl = itemGroup:FindDirect("Label_Num")
  local actCfg = TowerMgr.Instance():GetTowerActivityCfg(self.m_activityId)
  if actCfg then
    self.m_have = ItemModule.Instance():GetItemCountById(actCfg.sweepCostItemId)
    self.m_cost = TowerMgr.Instance():GetSweepCost(self.m_activityId, self.m_start, self.m_end)
  end
  local color = self.m_have >= self.m_cost and "[00ff00]" or "[ff0000]"
  numLbl:GetComponent("UILabel"):set_text(string.format("%s%d/%d[-]", color, self.m_have, self.m_cost))
end
def.method("boolean").SetUseYuanbao = function(self, value)
  if value then
    if self.m_have >= self.m_cost then
      Toast(textRes.activity[926])
      self.m_useYuanBao = false
      self.m_costYuanBao = 0
    else
      self.m_useYuanBao = true
      local actCfg = TowerMgr.Instance():GetTowerActivityCfg(self.m_activityId)
      if actCfg then
        do
          local left = self.m_cost - self.m_have
          require("Main.Item.ItemConsumeHelper").Instance():GetItemYuanBaoPrice(actCfg.sweepCostItemId, function(price)
            if self.m_panel and not self.m_panel.isnil and self.m_useYuanBao then
              self.m_costYuanBao = price * left
              local btn = self.m_panel:FindDirect("Img_Bg0/Group_Btn/Btn_Sweep")
              btn:FindDirect("Label_Name"):SetActive(false)
              local yuanbaoCostLbl = btn:FindDirect("Group_MoneyMake")
              yuanbaoCostLbl:SetActive(true)
              yuanbaoCostLbl:FindDirect("Label_MoneyMake"):GetComponent("UILabel"):set_text(tostring(self.m_costYuanBao))
            end
          end)
        end
      end
    end
  else
    self.m_useYuanBao = value
    self.m_costYuanBao = 0
  end
  local toggle = self.m_panel:FindDirect("Img_Bg0/Group_Btn/Btn_YuanbaoUse"):GetComponent("UIToggle")
  toggle.value = self.m_useYuanBao
  if not self.m_useYuanBao then
    local btn = self.m_panel:FindDirect("Img_Bg0/Group_Btn/Btn_Sweep")
    btn:FindDirect("Label_Name"):SetActive(true)
    local yuanbaoCostLbl = btn:FindDirect("Group_MoneyMake")
    yuanbaoCostLbl:SetActive(false)
  end
end
def.method("table").OnFunctionOpenChange = function(self, param)
  if param.feature == self.m_openId then
    local open = IsFeatureOpen(self.m_openId)
    if not open then
      self:DestroyPanel()
    end
  end
end
def.method("table").OnBagChange = function(self, param)
  if param.bagId == ItemModule.BAG then
    self:UpdateCost()
    self:SetUseYuanbao(self.m_useYuanBao)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Img_CurLevel" then
    local NumberPad = require("GUI.CommonDigitalKeyboard")
    NumberPad.Instance():ShowPanelEx(self.m_high, function(num)
      if self:IsShow() then
        self:UpdateFrom(num)
        self:SetUseYuanbao(self.m_useYuanBao)
      end
    end, nil)
    NumberPad.Instance():SetPos(100, 0)
  elseif id == "Img_NextLevel" then
    local NumberPad = require("GUI.CommonDigitalKeyboard")
    NumberPad.Instance():ShowPanelEx(self.m_high, function(num)
      if self:IsShow() then
        self:UpdateTo(num)
        self:SetUseYuanbao(self.m_useYuanBao)
      end
    end, nil)
    NumberPad.Instance():SetPos(-100, 0)
  elseif id == "Btn_Sweep" then
    if self.m_useYuanBao then
      local curYuanBao = ItemModule.Instance():GetAllYuanBao()
      if curYuanBao:lt(self.m_costYuanBao) then
        GotoBuyYuanbao()
        return
      end
    elseif self.m_cost > self.m_have then
      require("GUI.CommonConfirmDlg").ShowConfirm("", textRes.activity[933], function(sel)
        if sel == 1 then
          self:SetUseYuanbao(true)
        end
      end, nil)
      return
    end
    local ret = TowerMgr.Instance():SweepFloor(self.m_activityId, self.m_start, self.m_end, self.m_useYuanBao, self.m_costYuanBao)
    if ret then
      self:DestroyPanel()
    end
  elseif id == "Img_Item" then
    local itemGroup = self.m_panel:FindDirect("Img_Bg0/Group_Item")
    local bg = itemGroup:FindDirect("Img_Item")
    local actCfg = TowerMgr.Instance():GetTowerActivityCfg(self.m_activityId)
    if actCfg then
      require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithGO(actCfg.sweepCostItemId, bg, -1, true)
    end
  end
end
def.method("string", "boolean").onToggle = function(self, id, value)
  if id == "Btn_YuanbaoUse" then
    self:SetUseYuanbao(value)
  end
end
TowerSweep.Commit()
return TowerSweep
