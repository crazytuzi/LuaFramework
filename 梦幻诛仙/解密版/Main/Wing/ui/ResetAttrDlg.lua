local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ResetAttrDlg = Lplus.Extend(ECPanelBase, "ResetAttrDlg")
local WingModule = require("Main.Wing.WingModule")
local WingUtils = require("Main.Wing.WingUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local def = ResetAttrDlg.define
local instance
def.static("=>", ResetAttrDlg).Instance = function()
  if instance == nil then
    instance = ResetAttrDlg()
  end
  return instance
end
def.field("number").wingId = 0
def.field("table").curProps = nil
def.field("table").resetProps = nil
def.field("boolean").useYuanbao = false
def.field("boolean").locked = false
def.field("number").lockTimer = 0
def.static().PlayEffect = function()
  local self = ResetAttrDlg.Instance()
  if self:IsShow() then
    local effect = self.m_panel:FindDirect("UITexiao")
    effect:SetActive(false)
    effect:SetActive(true)
  end
end
def.static("number", "table", "table").ResetAttr = function(wingId, curProps, resetProps)
  if curProps == nil then
    return
  end
  local self = ResetAttrDlg.Instance()
  if self:IsShow() then
    if wingId == self.wingId then
      self.curProps = curProps
      self.resetProps = resetProps
      self:Unlock()
      self:UpdateCompare()
    end
  else
    self.useYuanbao = false
    self.wingId = wingId
    self.curProps = curProps
    self.resetProps = resetProps
    self:Unlock()
    self:CreatePanel(RESPATH.PANEL_WINGRESETATTR, 2)
    self:SetModal(true)
  end
end
def.method().Unlock = function(self)
  self.locked = false
  GameUtil.RemoveGlobalTimer(self.lockTimer)
  self.lockTimer = 0
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, ResetAttrDlg.OnItemChange, self)
  self:UpdateCompare()
  self:UpdateResetBtn()
end
def.override("boolean").OnShow = function(self, isShow)
end
def.override().OnDestroy = function(self)
  self:Unlock()
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, ResetAttrDlg.OnItemChange)
end
def.method("table").OnItemChange = function(self, parms)
  self:UpdateResetBtn()
end
def.method().UpdateCompare = function(self)
  local left = self.m_panel:FindDirect("Img_Bg/Group_Current/Attr")
  local desc = WingUtils.PropsToString(self.wingId, self.curProps, "")
  left:GetComponent("UILabel"):set_text(desc)
  local right = self.m_panel:FindDirect("Img_Bg/Group_Result/Attr")
  local replaceBtn = self.m_panel:FindDirect("Img_Bg/Gruop_Btn/Btn_Replace")
  if self.resetProps then
    local desc = WingUtils.PropsToString(self.wingId, self.resetProps, "")
    right:GetComponent("UILabel"):set_text(desc)
    replaceBtn:GetComponent("UIButton"):set_isEnabled(true)
  else
    right:GetComponent("UILabel"):set_text(textRes.Wing[4])
    replaceBtn:GetComponent("UIButton"):set_isEnabled(false)
  end
end
def.method().UpdateResetBtn = function(self)
  local ItemModule = require("Main.Item.ItemModule")
  local wingCfg = WingUtils.GetWingCfg(self.wingId)
  local needItem = wingCfg.resetProItemId
  local needNum = wingCfg.resetProItemNum
  local hasNum = ItemModule.Instance():GetItemCountById(needItem)
  local itemUI = self.m_panel:FindDirect("Img_Bg/Img_Item")
  local itemBase = ItemUtils.GetItemBase(needItem)
  local tex = itemUI:FindDirect("Texture_Item")
  local uiTex = tex:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTex, itemBase.icon)
  local numlbl = itemUI:FindDirect("Label")
  numlbl:GetComponent("UILabel"):set_text(string.format("%d/%d", hasNum, needNum))
  local nameLbl = itemUI:FindDirect("Label_ItemName")
  nameLbl:GetComponent("UILabel"):set_text(itemBase.name)
  self:SetUseYuanbao(self.useYuanbao)
end
def.method("boolean").SetUseYuanbao = function(self, use)
  local ItemModule = require("Main.Item.ItemModule")
  local wingCfg = WingUtils.GetWingCfg(self.wingId)
  local needItem = wingCfg.resetProItemId
  local needNum = wingCfg.resetProItemNum
  local hasNum = ItemModule.Instance():GetItemCountById(needItem)
  if use and needNum <= hasNum then
    Toast(textRes.Wing[28])
    use = false
  end
  self.useYuanbao = use
  local btn_useGold = self.m_panel:FindDirect("Img_Bg/Img_Item/Btn_UseGold")
  btn_useGold:GetComponent("UIToggle"):set_value(self.useYuanbao)
  local washBtn = self.m_panel:FindDirect("Img_Bg/Gruop_Btn/Btn_Wash")
  local noyuanbao = washBtn:FindDirect("Label_Wash")
  local yuanbao = washBtn:FindDirect("Group_Yuanbao")
  if use then
    noyuanbao:SetActive(false)
    yuanbao:SetActive(true)
    do
      local yuanbaoLbl = yuanbao:FindDirect("Label_Money"):GetComponent("UILabel")
      yuanbaoLbl:set_text("----")
      require("Main.Item.ItemConsumeHelper").Instance():GetItemYuanBaoPrice(needItem, function(result)
        if yuanbaoLbl.isnil then
          return
        end
        yuanbaoLbl:set_text(tostring(result * (needNum - hasNum)))
      end)
    end
  else
    noyuanbao:SetActive(true)
    yuanbao:SetActive(false)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Wash" then
    if CheckCrossServerAndToast() then
      return
    end
    if self.locked then
      Toast(textRes.Wing[42])
      return
    end
    local ret = WingModule.Instance():WashAttr(self.wingId, self.useYuanbao, function()
      self.locked = true
      GameUtil.AddGlobalTimer(3, true, function()
        self.locked = false
      end)
    end)
    if ret == -1 then
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      CommonConfirmDlg.ShowConfirm(textRes.Wing[38], textRes.Wing[39], function(select)
        if select == 1 then
          self:SetUseYuanbao(true)
        end
      end, nil)
    elseif ret == 0 then
      self.locked = true
      GameUtil.AddGlobalTimer(3, true, function()
        self.locked = false
      end)
    end
  elseif id == "Btn_Replace" then
    if CheckCrossServerAndToast() then
      return
    end
    WingModule.Instance():ReplaceAttr(self.wingId)
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Tips" then
    WingUtils.ShowQA(constant.WingConsts.WING_PRO_RESET_TIP_ID)
  elseif id == "Texture_Item" then
    local wingCfg = WingUtils.GetWingCfg(self.wingId)
    local needItem = wingCfg.resetProItemId
    local go = self.m_panel:FindDirect("Img_Bg/Img_Item/" .. id)
    if go then
      require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithGO(needItem, go, 0, true)
    end
  elseif id == "Btn_AttPre" then
    WingUtils.ShowPropPreView(self.wingId)
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if id == "Btn_UseGold" then
    if active then
      self:SetUseYuanbao(true)
    else
      self:SetUseYuanbao(false)
    end
  end
end
return ResetAttrDlg.Commit()
