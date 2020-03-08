local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgFunctionBtns = Lplus.Extend(ECPanelBase, "DlgFunctionBtns")
local def = DlgFunctionBtns.define
local GUIMan = require("GUI.ECGUIMan")
local FightUtils = require("Main.Fight.FightUtils")
local FuncType = require("consts.mzm.gsp.guide.confbean.FunType")
local EC = require("Types.Vector")
local dlg
def.field("table").funcBtns = nil
def.field("boolean").funcBtnSet = false
def.field("table").funcBtnMap = nil
def.static("=>", DlgFunctionBtns).Instance = function()
  if dlg == nil then
    dlg = DlgFunctionBtns()
  end
  return dlg
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:OnShow(true)
  else
    self:CreatePanel(RESPATH.DLG_FIGHT_MENU, 0)
    self:SetDepth(GUIDEPTH.BOTTOMMOST)
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, DlgFunctionBtns.OnCustomActivityOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, DlgFunctionBtns.OnCustomActivityOpenChange)
  Event.RegisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.UPDATE_RED_POINT, DlgFunctionBtns.OnUpdateCustomActivityRedPoint)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, DlgFunctionBtns.OnFunctionOpenChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, DlgFunctionBtns.OnCustomActivityOpenChange)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, DlgFunctionBtns.OnCustomActivityOpenChange)
  Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.UPDATE_RED_POINT, DlgFunctionBtns.OnUpdateCustomActivityRedPoint)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, DlgFunctionBtns.OnFunctionOpenChange)
  self.funcBtnSet = false
  self.funcBtnMap = nil
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  local btn_size = self.m_panel:FindDirect("Group_Menu/Group_Close/Btn_Menu"):GetComponent("UIWidget")
  local screenHeight = GUIMan.Instance().m_uiRootCom:get_activeHeight()
  local screenWidth = screenHeight / Screen.height * Screen.width
  self.m_panel.localPosition = EC.Vector3.new(-screenWidth / 2 + btn_size.width, screenHeight / 2 - btn_size.height - 30, 0)
end
def.method().Hide = function(self)
  if self.m_panel then
    self.m_panel:FindDirect("Group_Menu/Group_Open/Btn_Close"):GetComponent("UIPlayTween"):Play(true)
  end
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if string.find(id, "Btn_") then
    if id == "Btn_Menu" then
      self:ShowMenuBtn()
    elseif id ~= "Btn_Close" and self.funcBtns then
      local idx = tonumber(string.sub(id, string.len("Btn_") + 1))
      local cfg = self.funcBtns[idx]
      if cfg then
        self:OnClickFuncBtn(cfg.func, idx)
      end
    end
  end
end
def.method().ShowMenuBtn = function(self)
  if self.m_panel == nil then
    return
  end
  if self.funcBtns == nil then
    self.funcBtns = FightUtils.GetFuncBtnCfg()
  end
  if self.funcBtnSet then
    return
  end
  local tblbg = self.m_panel:FindDirect("Group_Menu/Group_Open/Img_BgBtn")
  local grid = tblbg:FindDirect("Grid")
  local uiGrid = grid:GetComponent("UIGrid")
  if self.funcBtnMap then
    for k, v in pairs(self.funcBtnMap) do
      if v.name ~= "Btn_01" then
        uiGrid:RemoveChild(v.transform)
        v.parent = nil
        v:Destroy()
      end
    end
  end
  self.funcBtnMap = {}
  local template = grid:FindDirect("Btn_01")
  local Img_Red = template:FindDirect("Img_Red")
  if Img_Red then
    local templateWidget = template:GetComponent("UIWidget")
    if templateWidget then
      Img_Red:GetComponent("UIWidget").depth = templateWidget.depth + 1
    end
  end
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local mylevel = heroProp and heroProp.level or 1
  for i = 1, #self.funcBtns do
    if mylevel >= self.funcBtns[i].level and (self.funcBtns[i].idip == 0 or _G.IsFeatureOpen(self.funcBtns[i].idip)) then
      local btnName = string.format("Btn_%02d", i)
      local btn = grid:FindDirect(btnName)
      if btn == nil then
        btn = Object.Instantiate(template)
        btn.name = btnName
        uiGrid:AddChild(btn.transform)
        btn.localScale = EC.Vector3.one
      end
      btn:GetComponent("UISprite").spriteName = self.funcBtns[i].iconName
      self.funcBtnMap[self.funcBtns[i].func] = btn
      if self.funcBtns[i].func == FuncType.OPERATION_ACTIVITY then
        if DlgFunctionBtns.IsCustomActivityOpen() then
          btn:SetActive(true)
          local ECGUIMan = require("GUI.ECGUIMan")
          local UIRoot = ECGUIMan.Instance().m_UIRoot
          local Btn_BingFen = UIRoot:FindDirect("panel_main/Pnl_BtnGroup_Top/BtnGroup_Top/Btn_BingFen")
          local Sprite = Btn_BingFen:FindDirect("Sprite")
          if Sprite then
            btn:GetComponent("UISprite").spriteName = Sprite:GetComponent("UISprite").spriteName
          end
          DlgFunctionBtns.OnUpdateCustomActivityRedPoint(nil, nil)
        else
          btn:SetActive(false)
        end
      end
    end
  end
  uiGrid:Reposition()
  tblbg:GetComponent("UITableResizeBackground"):Reposition()
  self.m_msgHandler:Touch(grid)
  self.funcBtnSet = true
end
def.method("number", "number").OnClickFuncBtn = function(self, funcId, idx)
  if funcId == FuncType.MALL then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_SHOP_CLICK, nil)
  elseif funcId == FuncType.XIANLV then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_PARTNER_CLICK, nil)
  elseif funcId == FuncType.RANK then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_RANKLIST_CLICK, nil)
  elseif funcId == FuncType.TRADE then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_TRADING_CENTER_CLICK, nil)
  elseif funcId == FuncType.ACTIVITY then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_ACTIVITY_CLICK, nil)
  elseif funcId == FuncType.BAG then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_BAG_CLICK, nil)
  elseif funcId == FuncType.EQUIP then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_EQUIPMENT_CLICK, nil)
  elseif funcId == FuncType.SETTING then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_SYSTEM_SETTING_CLICK, nil)
  elseif funcId == FuncType.AWARD then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_AWARD_CLICK, nil)
  elseif funcId == FuncType.ADVANCE then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_GUIDE_UP_CLICK, nil)
  elseif funcId == FuncType.GUAJI then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_AUTOFIGHT_CLICK, nil)
  elseif funcId == FuncType.GUIDE then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_GROW_GUIDE_CLICK, nil)
  elseif funcId == FuncType.FABAO then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_FABAO_CLICK, nil)
  elseif funcId == FuncType.SKILL then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_SKILL_CLICK, nil)
  elseif funcId == FuncType.GANG then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_GANG_CLICK, nil)
  elseif funcId == FuncType.WING then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_WINGS_CLICK, nil)
  elseif funcId == FuncType.MOUNT then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_MOUNTS_CLICK, nil)
  elseif funcId == FuncType.HOMELAND then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_RETURN_HOME_CLICK, nil)
  elseif funcId == FuncType.GODWEAPON then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_GODWEAPON_CLICK, nil)
  elseif funcId == FuncType.XIAOHUI_RUSH then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_MONKEYRUN_CLICK, nil)
  elseif funcId == FuncType.GAME_COMMUNITY then
    local anchorGO = self.m_panel:FindDirect("Group_Menu/Group_Open/Img_BgBtn/Grid/Btn_" .. string.format("%02d", idx))
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_GAME_COMMUNITY_CLICK, {anchorGO})
  elseif funcId == FuncType.OPERATION_ACTIVITY then
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.FEEDBACK, {})
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_CUSTOM_ACTIVITY, nil)
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if dlg == nil or not dlg.funcBtnSet or not dlg.funcBtns then
    return
  end
  local feature = p1 and p1.feature
  local has = false
  for k, v in pairs(dlg.funcBtns) do
    if v.idip == feature then
      has = true
      break
    end
  end
  if not has then
    return
  end
  dlg.funcBtnSet = false
  local tblbg = dlg.m_panel:FindDirect("Group_Menu/Group_Open/Img_BgBtn")
  if not tblbg.activeInHierarchy then
    return
  end
  dlg:ShowMenuBtn()
end
def.static("table", "table").OnCustomActivityOpenChange = function(p1, p2)
  if dlg then
    dlg.funcBtnSet = false
    dlg:ShowMenuBtn()
  end
end
def.static("=>", "boolean").IsCustomActivityOpen = function()
  local CustomActivityPanel = require("Main.CustomActivity.ui.CustomActivityPanel")
  local isOpen = CustomActivityPanel.isOwnOpendActivity()
  return isOpen
end
def.static("table", "table").OnUpdateCustomActivityRedPoint = function()
  if dlg.funcBtnMap == nil then
    return
  end
  local btn = dlg.funcBtnMap[FuncType.OPERATION_ACTIVITY]
  if btn == nil then
    return
  end
  local Img_Red = btn:FindDirect("Img_Red")
  local CustomActivityInterface = require("Main.CustomActivity.CustomActivityInterface")
  local flag = CustomActivityInterface.Instance():isOwnRedPoint()
  Img_Red:SetActive(flag)
end
DlgFunctionBtns.Commit()
return DlgFunctionBtns
