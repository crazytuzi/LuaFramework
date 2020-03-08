local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIBindPKPlayer = Lplus.Extend(ECPanelBase, "UIBindPKPlayer")
local instance
local def = UIBindPKPlayer.define
local PKMgr = require("Main.PlayerPK.PKMgr")
local GUIUtils = require("GUI.GUIUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local txtConst = textRes.PlayerPK.PK
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.static("=>", UIBindPKPlayer).Instance = function()
  if instance == nil then
    instance = UIBindPKPlayer()
  end
  return instance
end
def.override().OnCreate = function(self)
  self._uiStatus = self._uiStatus or {}
  self._uiGOs = {}
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, UIBindPKPlayer.OnBagChg, self)
  Event.RegisterEventWithContext(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.BindPlayerFailed, UIBindPKPlayer.OnBindFailed, self)
  self:_initUI()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, UIBindPKPlayer.OnBagChg)
  Event.UnregisterEvent(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.BindPlayerFailed, UIBindPKPlayer.OnBindFailed)
end
def.method()._initUI = function(self)
  self._uiGOs.comInput = self.m_panel:FindDirect("Img_Bg0/Img_BgInput"):GetComponent("UIInput")
  self._uiGOs.lblWarning = self.m_panel:FindDirect("Img_Bg0/Label_Warning")
  self._uiGOs.lblWarning:SetActive(false)
end
def.method("number", "number").ShowPanel = function(self, bagId, itemKey)
  if self:IsLoaded() then
    return
  end
  self._uiStatus = self._uiStatus or {}
  self._uiStatus.bagId = bagId
  self._uiStatus.itemKey = itemKey
  self:CreatePanel(RESPATH.PREFAB_BINDPLAYER, 1)
  self:SetModal(true)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Cancel" then
    self:DestroyPanel()
  elseif id == "Btn_Confirm" then
    self:OnClickConfirm()
  end
end
local ChatUtils = require("Main.Chat.ChatUtils")
def.method().OnClickConfirm = function(self)
  local inputVal = self._uiGOs.comInput:get_value()
  inputVal = ChatUtils.ChatContentTrim(inputVal)
  if inputVal == "" then
    Toast(txtConst[73])
    return
  end
  local strContent = txtConst[51]:format(inputVal)
  local tmpstrContent = string.match(inputVal, "^%d+$")
  if tmpstrContent ~= nil then
    inputVal = Int64.new(tmpstrContent)
    inputVal = require("Main.Hero.HeroUtility").Instance():DisplayIDToRoleID(inputVal)
    inputVal = inputVal:tostring()
  end
  CommonConfirmDlg.ShowConfirm(txtConst[29], strContent, function(select)
    if select == 1 then
      PKMgr.GetProtocols().SendBindTargetRoleReq(self._uiStatus.bagId, self._uiStatus.itemKey, inputVal)
    end
  end, nil)
end
def.method("string", "userdata").onSubmit = function(self, id, ctrl)
  self:OnClickConfirm()
end
def.method("table").OnBagChg = function(self, p)
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local ItemModule = require("Main.Item.ItemModule")
  local bagId, itemKey = self._uiStatus.bagId, self._uiStatus.itemKey
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return
  end
  local roleId_l = item.extraMap[ItemXStoreType.PK_REVENGE_ITEM_BIND_LOW]
  if roleId_l ~= nil then
    Toast(txtConst[28])
    self:DestroyPanel()
  end
end
def.method("table").OnBindFailed = function(self, p)
  self._uiGOs.lblWarning:SetActive(true)
  local FAILED = require("netio.protocol.mzm.gsp.pk.SRevengeItemAssignRoleFail")
  if p.retcode == FAILED.TARGET_NOT_FOUND then
    GUIUtils.SetText(self._uiGOs.lblWarning, txtConst[47])
  elseif p.retcode == FAILED.CANNOT_ASSIGN_SELF then
    GUIUtils.SetText(self._uiGOs.lblWarning, txtConst[48])
  elseif p.retcode == FAILED.ALREADY_ASSIGNED then
    GUIUtils.SetText(self._uiGOs.lblWarning, txtConst[49])
  end
end
return UIBindPKPlayer.Commit()
