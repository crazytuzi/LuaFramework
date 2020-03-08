local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIGetOrUpgradeHint = Lplus.Extend(ECPanelBase, MODULE_NAME)
local def = UIGetOrUpgradeHint.define
local instance
local DecorationUtils = require("Main.GodWeapon.Decoration.DecorationUtils")
local DecorationMgr = require("Main.GodWeapon.DecorationMgr")
local GUIUtils = require("GUI.GUIUtils")
local txtConst = textRes.GodWeapon.Decoration
def.field("table")._uiGOs = nil
def.field("table")._uiModel = nil
def.field("table")._modelInfo = nil
def.field("table")._WSInfo = nil
def.field("table")._WSLvUpInfo = nil
def.field("boolean").isDrag = false
def.static("=>", UIGetOrUpgradeHint).Instance = function()
  if instance == nil then
    instance = UIGetOrUpgradeHint()
  end
  return instance
end
def.override().OnCreate = function(self)
  self._uiGOs = {}
  self:InitUI()
  self:UpdateUI()
end
def.method().InitUI = function(self)
  local groupGet = self.m_panel:FindDirect("Img_Bg0/Group_Get")
  local groupLvUp = self.m_panel:FindDirect("Img_Bg0/Group_Upgrade")
  self._uiGOs.groupGet = groupGet
  self._uiGOs.groupLvUp = groupLvUp
  groupGet:SetActive(self._WSInfo ~= nil)
  groupLvUp:SetActive(self._WSInfo == nil)
  if self._WSInfo ~= nil then
    self._uiGOs.uiModel = groupGet:FindDirect("Model")
    self._uiGOs.fx = groupGet:FindDirect("Fx")
  else
    self._uiGOs.uiModel = groupLvUp:FindDirect("Model")
    self._uiGOs.fx = groupLvUp:FindDirect("Fx")
  end
end
def.override().OnDestroy = function(self)
  self._uiGOs = nil
  if self._uiModel ~= nil then
    self._uiModel:Destroy()
  end
  self._uiModel = nil
  self._WSInfo = nil
  self._WSLvUpInfo = nil
  self._modelInfo = nil
  self.isDrag = false
end
local SUseWuShiItemResponse = require("netio.protocol.mzm.gsp.superequipment.SUseWuShiItemResponse")
def.method().UpdateUI = function(self)
  local heroProp = _G.GetHeroProp()
  if self._WSInfo ~= nil then
    local cfgId = self._WSInfo.wuShiCfgId
    local wsBasicCfg = DecorationUtils.GetWSBasicCfgById(cfgId)
    local wsDisplayCfg = DecorationMgr.GetData():GetDisplayCfg(wsBasicCfg.displayTypeId, heroProp.occupation, heroProp.gender)
    self:UpdateUIModel(wsDisplayCfg)
    self:UpdateUIProp(wsBasicCfg)
  else
    local wsBasicCfg = DecorationUtils.GetWSBasicCfgById()
    local wsDisplayCfg = DecorationMgr.GetData():GetDisplayCfg(wsBasicCfg.displayTypeId, heroProp.occupation, heroProp.gender)
    self:UpdateUIModel(wsDisplayCfg)
    self:UpdateUIPreProps()
    self:UpdateUICurProps()
  end
end
def.method("table").UpdateUIProp = function(self, wsBasicCfg)
  local groupGet = self._uiGOs.groupGet
  local lblName = groupGet:FindDirect("Label_Name")
  local lblProp = groupGet:FindDirect("Label_Middle")
  local lblTips = groupGet:FindDirect("Label_Tips")
  local strProps = ""
  local arrProps = wsBasicCfg and wsBasicCfg.arrProps or {}
  local numProps = #arrProps
  for i = 1, numProps do
    local prop = arrProps[i]
    local propName = DecorationUtils.GetProName(prop.propType)
    strProps = strProps .. txtConst[1]:format(propName, prop.propVal) .. "\n"
  end
  GUIUtils.SetText(lblName, wsBasicCfg.name)
  GUIUtils.SetText(lblProp, strProps)
  GUIUtils.SetText(lblTips, txtConst[21])
end
def.method().UpdateUIPreProps = function(self)
  local wsBasicCfg = self._WSLvUpInfo.pre.basicCfg
  local arrProps = {}
  if wsBasicCfg ~= nil then
    arrProps = wsBasicCfg.arrProps
  end
  local numProps = #arrProps
  local str = ""
  for i = 1, numProps do
    local prop = arrProps[i]
    local propName = DecorationUtils.GetProName(prop.propType)
    str = str .. txtConst[1]:format(propName, prop.propVal) .. "\n"
  end
  local lblLeft = self._uiGOs.groupLvUp:FindDirect("Label_Left")
  GUIUtils.SetText(lblLeft, str)
end
def.method().UpdateUICurProps = function(self)
  local wsBasicCfg = self._WSLvUpInfo.cur.basicCfg
  local arrProps = {}
  if wsBasicCfg ~= nil then
    arrProps = wsBasicCfg.arrProps
  end
  local numProps = #arrProps
  local str = ""
  for i = 1, numProps do
    local prop = arrProps[i]
    local propName = DecorationUtils.GetProName(prop.propType)
    str = str .. txtConst[1]:format(propName, prop.propVal) .. "\n"
  end
  local lblRight = self._uiGOs.groupLvUp:FindDirect("Label_Right")
  GUIUtils.SetText(lblRight, str)
end
local ECUIModel = require("Model.ECUIModel")
def.method("table").UpdateUIModel = function(self, weaponModelInfo)
  local comUIModel = self._uiGOs.uiModel:GetComponent("UIModel")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local ocp = _G.GetHeroProp().occupation
  local modelId = DecorationMgr.GetData():GetOccupationModelId(ocp)
  if self._uiModel then
    self._uiModel:Destroy()
  end
  self._uiModel = ECUIModel.new(modelId)
  if self._modelInfo == nil then
    local ocp = _G.GetHeroProp().occupation
    self._modelInfo = DecorationMgr.GetData():GetOccupationModelInfo(ocp)
  end
  local modelInfo = self._modelInfo
  modelInfo.modelid = modelId
  _G.LoadModelWithCallBack(self._uiModel, modelInfo, false, false, function()
    if self.m_panel == nil or self.m_panel.isnil then
      if self._uiModel then
        self._uiModel:Destroy()
        self._uiModel = nil
      end
      return
    end
    if self._uiModel == nil or self._uiModel.m_model == nil or self._uiModel.m_model.isnil or comUIModel == nil or comUIModel.isnil then
      return
    end
    self._uiModel:SetDir(180)
    self._uiModel:Play(ActionName.Stand)
    comUIModel.modelGameObject = self._uiModel:GetMainModel()
    if comUIModel.mCanOverflow ~= nil then
      comUIModel.mCanOverflow = true
      local camera = comUIModel:get_modelCamera()
      if camera then
        camera:set_orthographic(true)
      end
    end
    self._uiModel:SetWeaponModel(weaponModelInfo)
    self:PlayAttackThenStand()
  end)
end
def.method().PlayAttackThenStand = function(self)
  if self._uiModel == nil then
    return
  end
  self._uiModel:CrossFade(ActionName.Idle1, 0.2)
  self._uiModel:CrossFadeQueued(ActionName.Stand, 0.2)
end
def.method("string").onDragStart = function(self, id)
  if id == "Model" then
    self.isDrag = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self.isDrag = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  self._uiModel:SetDir(self._uiModel.m_ang - dx / 2)
end
def.method("table").ShowPanelGet = function(self, WSInfo)
  if self:IsLoaded() then
    return
  end
  self._WSInfo = WSInfo or {}
  self._WSLvUpInfo = nil
  self:CreatePanel(RESPATH.PREFAB_GODWEAPON_LVUP, 1)
  self:SetModal(true)
end
def.method("table").ShowPanelUpgrade = function(self, WSInfo)
  if self:IsLoaded() then
    return
  end
  self._WSInfo = nil
  self._WSLvUpInfo = WSInfo or {}
  self:CreatePanel(RESPATH.PREFAB_GODWEAPON_LVUP, 1)
  self:SetModal(true)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("UIGetOrUpgradeHint id", id)
  if id == "Btn_Conform" then
    if self._WSInfo ~= nil then
      local UIGodWeaponBasic = require("Main.GodWeapon.ui.UIGodWeaponBasic")
      UIGodWeaponBasic.Instance():ShowWithParams(UIGodWeaponBasic.NodeId.Decoration, {
        cfgId = self._WSInfo.wuShiCfgId
      })
    else
      Event.DispatchEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.WS_UPGRADE_SUCCESS, nil)
    end
    self:DestroyPanel()
  elseif id == "Modal" then
    self:PlayAttackThenStand()
  end
end
return UIGetOrUpgradeHint.Commit()
