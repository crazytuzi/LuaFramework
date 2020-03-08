local Lplus = require("Lplus")
local ItemModule = require("Main.Item.ItemModule")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local DyeData = require("Main.Dyeing.data.DyeData")
local OccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local FashionData = require("Main.Fashion.FashionData")
local DyeingMgr = Lplus.Class("DyeingMgr")
local def = DyeingMgr.define
def.const("table").PARTINDEX = {CLOTH = 1, HAIR = 2}
def.const("table").ConsumeOrder = {2, 1}
local instance
def.static("=>", DyeingMgr).Instance = function()
  if not instance then
    instance = DyeingMgr()
  end
  return instance
end
def.static("table").OnRoleClothesListRes = function(p)
  DyeData.Instance():SetClothData(p)
  Event.DispatchEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.UPDATE_COLOR_DATA, nil)
end
def.static("table").OnAddClothesColorRes = function(p)
  Toast(textRes.Dyeing[19])
  Toast(textRes.Dyeing[20])
  DyeData.Instance():AddCloth(p)
  FashionData.Instance():PutOnFashionDress(DyeData.Instance():GetCurClothData().fashionDressCfgId)
  Event.DispatchEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.UPDATE_CLOSET, nil)
end
def.static("table").OnRoleDyeResult = function(p)
  local SRoleDyeResult = require("netio.protocol.mzm.gsp.roledye.SRoleDyeResult")
  local tooltipIndex = 1
  if p.resultcode == SRoleDyeResult.ERROR_DEL_DEFAULT_ID then
    tooltipIndex = 18
  elseif p.resultcode == SRoleDyeResult.ERROR_ADD_OVER_MAX then
    tooltipIndex = 17
  elseif p.resultcode == SRoleDyeResult.ERROR_ADD_NO_ENOUTH then
    tooltipIndex = 16
  elseif p.resultcode == SRoleDyeResult.ERROR_ADD_OVERLAP then
    tooltipIndex = 15
  elseif p.resultcode == SRoleDyeResult.ERROR_DEL_CUR_ID then
    tooltipIndex = 22
  elseif p.resultcode == SRoleDyeResult.ERROR_YUANBAO_NOT_ENOUGH then
    tooltipIndex = 30
  end
  Toast(textRes.Dyeing[tooltipIndex])
end
def.static("table").OnDelClothesColorRes = function(p)
  DyeData.Instance():DeleteCloth(p)
  Event.DispatchEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.UPDATE_CLOSET, nil)
end
def.static("table").OnUseClothesColorRes = function(p)
  DyeData.Instance():ReplaceCloth(p)
  Toast(textRes.Dyeing[23])
  Event.DispatchEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.UPDATE_CLOSET, nil)
end
def.static("table").Settle = function(p)
  local p = require("netio.protocol.mzm.gsp.roledye.CAddClothesColorReq").new(p.hairid, p.clothid, p.fashionDressCfgId, p.hairItemCfgId2useyuanbao, p.clothItemCfgId2useyuanbao)
  gmodule.network.sendProtocol(p)
end
def.static("table").Delete = function(p)
  warn("Delete,..........", p.colorid)
  local p = require("netio.protocol.mzm.gsp.roledye.CDelClothesColorReq").new(p.colorid)
  gmodule.network.sendProtocol(p)
end
def.static("table").Replace = function(p)
  local p = require("netio.protocol.mzm.gsp.roledye.CUseClothesColorReq").new(p.colorid)
  gmodule.network.sendProtocol(p)
end
def.static().RequestClothData = function()
  local p = require("netio.protocol.mzm.gsp.roledye.CGetRoleClothesListReq").new()
  gmodule.network.sendProtocol(p)
end
def.static("table", "table").OnNPCService = function(p1, p2)
  local serviceID = p1[1]
  local NPCID = p1[2]
  if serviceID == NPCServiceConst.Dyeing then
    local dyeingPanel = require("Main.Dyeing.ui.DyeingPanel")
    dyeingPanel.Instance():ShowPanel()
  end
end
def.static("table", "table").OnOpenClothPanel = function()
  local clothPanel = require("Main.Dyeing.ui.ClothPanel")
  clothPanel.Instance():ShowPanel()
end
def.static("table", "table").OnCloseClothPanel = function()
  local dyeingPanel = require("Main.Dyeing.ui.DyeingPanel")
  if dyeingPanel.Instance().m_panel then
    dyeingPanel.Instance():InitData()
    dyeingPanel.Instance():Update()
  end
end
def.static("table", "table").OnSEnterWorld = function(p1, p2)
  DyeingMgr.RequestClothData()
end
def.static("=>", "table").GetAllColorFormula = function()
  return DyeData.GetAllColorFormula()
end
def.static("number", "=>", "userdata").GetColorFormula = function(id)
  local cfg = DyeData.GetColorFormula(id)
  if cfg then
    return Color.Color(cfg.r / 255, cfg.g / 255, cfg.b / 255, cfg.a / 255)
  else
    return Color.Color(1, 1, 1, 1)
  end
end
def.static("=>", "number").GetClothMaxCount = function()
  return DyeData.Instance():GetClothMaxCount()
end
def.static("=>", "number").GetClothCurCount = function(self)
  return DyeData.Instance():GetClothCurCount()
end
def.static("=>", "number").GetClothCurIndex = function()
  return DyeData.Instance():GetClothCurIndex()
end
def.static("=>", "table").GetClothListData = function()
  return DyeData.Instance():GetClothListData()
end
def.static("number", "number", "=>", "boolean").IsDyeingExist = function(hairid, clothid)
  local clothListData = DyeingMgr.GetClothListData()
  for i = 1, #clothListData do
    local data = clothListData[i]
    if data.hairid == hairid and data.clothid == clothid then
      return true
    end
  end
  return false
end
def.static("=>", "table").GetCurClothData = function()
  return DyeData.Instance():GetCurClothData()
end
def.static("number", "table", "userdata").ChangeModelColor = function(partIndex, model, color)
  if not model then
    return
  end
  local curColor = {}
  for k, v in pairs(model.m_color or {}) do
    curColor[k] = v
  end
  if partIndex == DyeingMgr.PARTINDEX.CLOTH then
    curColor.clothes = color
  elseif partIndex == DyeingMgr.PARTINDEX.HAIR then
    curColor.hair = color
  end
  model:SetModelColor(curColor)
end
def.static("boolean", "table").ChangeModelScale = function(expand, model)
  if model then
    local scaler = expand and 0.1 or -0.1
    local curScale = model.m_model.localScale.x
    local newScale = curScale + scaler
    if newScale > 1 then
      newScale = 1
      Toast(textRes.Dyeing[24])
    elseif newScale < 0.3 then
      newScale = 0.3
      Toast(textRes.Dyeing[25])
    end
    model:SetScale(newScale)
  end
end
def.static("table", "table").OnCurrentFashionChanged = function(params, context)
  DyeingMgr.RequestClothData()
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.BTN_OPEN_CLOSET_CLICK, DyeingMgr.OnOpenClothPanel)
  Event.RegisterEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.CLOSET_PANEL_CLOSE, DyeingMgr.OnCloseClothPanel)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, DyeingMgr.OnNPCService)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, DyeingMgr.OnSEnterWorld)
  Event.RegisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.DressFashionChanged, DyeingMgr.OnCurrentFashionChanged)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.roledye.SRoleClothesListRes", DyeingMgr.OnRoleClothesListRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.roledye.SAddClothesColorRes", DyeingMgr.OnAddClothesColorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.roledye.SRoleDyeResult", DyeingMgr.OnRoleDyeResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.roledye.SDelClothesColorRes", DyeingMgr.OnDelClothesColorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.roledye.SUseClothesColorRes", DyeingMgr.OnUseClothesColorRes)
end
def.method("=>", "table").GetDyeShowModelInfo = function(self)
  local fakeModelInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRoleModelInfo(gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId)
  if fakeModelInfo == nil then
    return nil
  end
  local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
  fakeModelInfo.extraMap[ModelInfo.EXTERIOR_ID] = 0
  fakeModelInfo.extraMap[ModelInfo.MAGIC_MARK] = 0
  fakeModelInfo.extraMap[ModelInfo.CHANGE_MODEL_CARD_CFGID] = 0
  local dyeData = DyeingMgr.GetCurClothData()
  if dyeData ~= nil then
    fakeModelInfo.extraMap[ModelInfo.FASHION_DRESS_ID] = dyeData.fashionDressCfgId
    fakeModelInfo.extraMap[ModelInfo.HAIR_COLOR_ID] = dyeData.hairid
    fakeModelInfo.extraMap[ModelInfo.CLOTH_COLOR_ID] = dyeData.clothid
  end
  return fakeModelInfo
end
def.method().Reset = function(self)
end
def.static("=>", "boolean").IsUseYBFeatureOpen = function()
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
  local bOpen = FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_ROLE_MODLE_DYE_OPTIMIZATION)
  return bOpen
end
return DyeingMgr.Commit()
