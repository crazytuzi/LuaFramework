local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIPKConds = Lplus.Extend(ECPanelBase, "UIPKConds")
local instance
local def = UIPKConds.define
local GUIUtils = require("GUI.GUIUtils")
local PKInterface = require("Main.PlayerPK.PK.PKInterface")
local PKMgr = require("Main.PlayerPK.PKMgr")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local ItemModule = require("Main.Item.ItemModule")
local txtConst = textRes.PlayerPK.PK
local const = constant.CPKConsts
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.field("table")._conds = nil
def.const("table").EnumCondType = {
  LEVEL_NOT_ENOUGH = 1,
  MONEY_NOT_ENOUGH = 2,
  MERIT_NOT_ENOUGH = 3
}
def.static("=>", UIPKConds).Instance = function()
  if instance == nil then
    instance = UIPKConds()
  end
  return instance
end
def.override().OnCreate = function(self)
  self._uiGOs = {}
  self._uiStatus = {}
  Event.RegisterEventWithContext(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.EnablePKResult, UIPKConds.OnEnableResult, self)
  self._conds = self:_getConds()
  self:_initUI()
  self:UpdateUI()
end
def.method()._initUI = function(self)
  self._uiGOs.lblTips = self.m_panel:FindDirect("Img_Bg/Label_Tips")
  self._uiGOs.groupList = self.m_panel:FindDirect("Img_Bg/Group_Center/Group_List")
  self._uiGOs.btnConfirm = self.m_panel:FindDirect("Img_Bg/Group_Bottom/Btn_Confirm")
end
def.override().OnDestroy = function(self)
  self._uiGOs = nil
  self._uiStatus = nil
  self._conds = nil
  Event.UnregisterEvent(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.EnablePKResult, UIPKConds.OnEnableResult)
end
def.method().UpdateUITips = function(self)
  GUIUtils.SetText(self._uiGOs.lblTips, txtConst[3])
end
def.method().UpdateUIConds = function(self)
  local ctrlScrollView = self._uiGOs.groupList:FindDirect("Scroll View")
  local ctrlUIList = ctrlScrollView:FindDirect("List_Member")
  local conds = self._conds
  local heroProp = _G.GetHeroProp()
  local ctrlCondList = GUIUtils.InitUIList(ctrlUIList, #conds)
  local bAllCondMeet = true
  for i = 1, #ctrlCondList do
    self:_fillCondInfo(ctrlCondList[i], conds[i], i)
    if not conds[i].bMeet then
      bAllCondMeet = false
    end
  end
  GUIUtils.EnableButton(self._uiGOs.btnConfirm, bAllCondMeet)
end
def.method("userdata", "table", "number")._fillCondInfo = function(self, ctrl, condInfo, idx)
  local lblCond = ctrl:FindDirect("Label_TermName_" .. idx)
  local imgRoot = ctrl:FindDirect("Group_Result_" .. idx)
  local imgRight = imgRoot:FindDirect("Img_Right_" .. idx)
  local imgWrong = imgRoot:FindDirect("Img_Wrong_" .. idx)
  local txt = ""
  local EnumCondType = UIPKConds.EnumCondType
  if condInfo.type == EnumCondType.LEVEL_NOT_ENOUGH then
    txt = txtConst[4]:format(const.ENABLE_PK_LEVEL)
  elseif condInfo.type == EnumCondType.MONEY_NOT_ENOUGH then
    local moneyData = CurrencyFactory.Create(const.ENABLE_PK_MONEY_TYPE)
    txt = txtConst[5]:format(const.ENABLE_PK_PRICE, moneyData:GetName())
  elseif condInfo.type == EnumCondType.MERIT_NOT_ENOUGH then
    txt = txtConst[6]:format(const.ENABLE_PK_MORAL_VALUE)
  end
  GUIUtils.SetText(lblCond, txt)
  imgRight:SetActive(condInfo.bMeet)
  imgWrong:SetActive(not condInfo.bMeet)
end
def.method().ShowPanel = function(self)
  if self:IsLoaded() then
    self:Show()
    self:UpdateUI()
    return
  end
  self:CreatePanel(RESPATH.PREFAB_TONGJI_START, 1)
  self:SetModal(true)
end
def.method().UpdateUI = function(self)
  self:UpdateUITips()
  self:UpdateUIConds()
end
def.method("=>", "table")._getConds = function(self)
  local conds = {}
  local heroProp = _G.GetHeroProp()
  local EnumCondType = UIPKConds.EnumCondType
  conds[1] = {
    type = EnumCondType.LEVEL_NOT_ENOUGH,
    bMeet = heroProp.level >= const.ENABLE_PK_LEVEL
  }
  local curMerit = Int64.ToNumber(ItemModule.Instance():GetCredits(TokenType.MORAL_VALUE) or Int64.new(0))
  conds[2] = {
    type = EnumCondType.MERIT_NOT_ENOUGH,
    bMeet = Int64.lt(const.ENABLE_PK_MORAL_VALUE, curMerit)
  }
  local owndMoney = PKInterface.GetMoneyNumByType(const.ENABLE_PK_MONEY_TYPE)
  conds[3] = {
    type = EnumCondType.MONEY_NOT_ENOUGH,
    bMeet = Int64.lt(const.ENABLE_PK_PRICE, owndMoney)
  }
  return conds
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Cancel" then
    self:DestroyPanel()
  elseif id == "Btn_Confirm" then
    self:OnClickConfirm()
  end
end
def.method().OnClickConfirm = function(self)
  for i = 1, #self._conds do
    local cond = self._conds[i]
    if not cond.bMeet then
      if cond.type == UIPKConds.EnumCondType.LEVEL_NOT_ENOUGH then
        Toast(txtConst[4]:format(const.ENABLE_PK_LEVEL))
      elseif cond.type == UIPKConds.EnumCondType.MERIT_NOT_ENOUGH then
        Toast(txtConst[6]:format(const.ENABLE_PK_MORAL_VALUE))
      elseif cond.type == UIPKConds.EnumCondType.MONEY_NOT_ENOUGH then
        local moneyData = CurrencyFactory.Create(const.ENABLE_PK_MONEY_TYPE)
        Toast(txtConst[5]:format(const.ENABLE_PK_PRICE))
      end
      return
    end
  end
  if _G.PlayerIsInState(_G.RoleState.PLAYER_PK_ON) then
    Toast(txtConst[23])
    return
  end
  local owndMoney = PKInterface.GetMoneyNumByType(const.ENABLE_PK_MONEY_TYPE)
  PKMgr.GetProtocols().SendCEnablePKReq(owndMoney)
end
def.method("table").OnEnableResult = function(self, p)
  if p.ok then
    Toast(txtConst[22])
  end
  self:DestroyPanel()
end
return UIPKConds.Commit()
