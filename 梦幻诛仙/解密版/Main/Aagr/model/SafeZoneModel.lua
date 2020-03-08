local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local ECModel = require("Model.ECModel")
local SafeZoneModel = Lplus.Extend(ECModel, "SafeZoneModel")
local def = SafeZoneModel.define
local RENDER_QUEUE = 3000
local TRANSPARENT_SHADER = "Particles/Alpha Blended"
def.field("number")._layer = 1
def.field("number")._originScale = 1
def.field("number")._circleIdx = 1
def.field("table")._circleCfg = nil
def.field("table")._mapCfg = nil
def.field("function")._callback = nil
def.field("table")._quadList = nil
def.final("table", "number", "table", "=>", SafeZoneModel).new = function(circleCfg, circleIdx, mapCfg)
  if nil == circleCfg then
    warn("[ERROR][SafeZoneModel:new] new fail! circleCfg nil.")
    return nil
  end
  if nil == mapCfg then
    warn("[ERROR][SafeZoneModel:new] new fail! mapCfg nil.")
    return nil
  end
  local obj = SafeZoneModel()
  obj.defaultLayer = ClientDef_Layer.Player
  obj.m_IsTouchable = false
  obj.m_create_node2d = true
  obj.defaultParentNode = gmodule.moduleMgr:GetModule(ModuleId.MAP).mapPlayerNodeRoot
  obj._layer = ClientDef_Layer.Default
  obj._originScale = 1
  obj._circleIdx = circleIdx
  obj._circleCfg = circleCfg
  obj._mapCfg = mapCfg
  obj:Init(circleCfg.circleModelId)
  obj.m_bUncache = true
  return obj
end
def.method("function", "=>", "boolean").LoadZone = function(self, callback)
  self._callback = callback
  if self.mModelId <= 0 then
    self:_DoCallback(false)
    return false
  end
  local modelpath, modelColor = GetModelPath(self.mModelId)
  if modelpath then
    self:_LoadQuads()
    return self:_LoadCircle(modelpath)
  else
    warn("[ERROR][SafeZoneModel:LoadZone] LoadZone fail! modelpath nil for modelId:", self.mModelId)
    self:_DoCallback(false)
    return false
  end
end
def.method("number").UpdateZone = function(self, circleIdx)
  self._circleIdx = circleIdx
  self:_UpdateCircle()
  self:_UpdateQuads()
end
def.method("boolean")._DoCallback = function(self, value)
  if self._callback then
    self._callback(value)
    self._callback = nil
  end
end
def.override().Destroy = function(self)
  self:DestroyQuads()
  ECModel.Destroy(self)
end
def.method("string", "=>", "boolean")._LoadCircle = function(self, modelpath)
  self:AddOnLoadCallback("safezone", function()
    if self.m_model and not self.m_model.isnil then
      self:SetLayer(self._layer)
      self.m_model.localPosition = EC.Vector3.new(self._circleCfg.circleCenterX, self._circleCfg.circleCenterY, 0)
      local renderer = self.m_model:GetComponentInChildren("MeshRenderer")
      local mat = renderer and renderer.material
      if not _G.IsNil(mat) then
        mat:SetTexture("_MainTex", nil)
        local color = Color.Color(self._circleCfg.circleModelR / 255, self._circleCfg.circleModelG / 255, self._circleCfg.circleModelB / 255, self._circleCfg.circleModelA / 255)
        mat:SetColor("_TintColor", color)
      else
        warn("[ERROR][SafeZoneModel:_LoadCircle] circle renderer or material nil:", renderer, mat)
      end
      self:_UpdateCircle()
      self:_UpdateQuads()
      self:_DoCallback(true)
    else
      self:_DoCallback(false)
    end
  end)
  return self:LoadModel(modelpath, self._circleCfg.circleCenterX, self._circleCfg.circleCenterY, 0)
end
def.method()._UpdateCircle = function(self)
  if self:IsInLoading() then
    return
  end
  local newScale = self:_CalcScale()
  self:SetScale(newScale)
end
def.method("=>", "number")._CalcScale = function(self)
  local curRadius = 0
  if 0 < self._circleIdx then
    local cricleLevelCfg = self._circleCfg.levelCfgs[self._circleIdx]
    if cricleLevelCfg then
      curRadius = cricleLevelCfg.circleRadius
    else
      warn("[ERROR][SafeZoneModel:_CalcScale] cricleLevelCfg nil at idx:", self._circleIdx)
      curRadius = 0
    end
  else
    curRadius = self._circleCfg.initRadius
  end
  local modelRadius = self._circleCfg.circleModelRawRadius
  return self._originScale * curRadius / modelRadius
end
def.method()._LoadQuads = function(self)
  self:DestroyQuads()
  self._quadList = {}
  for i = 1, 4 do
    local quad = GameObject.CreatePrimitive(PrimitiveType.Quad)
    quad.parent = gmodule.moduleMgr:GetModule(ModuleId.MAP).mapPlayerNodeRoot
    quad:SetLayer(self._layer)
    local renderer = quad:GetComponent("MeshRenderer")
    local mat = renderer and renderer.material
    if mat then
      local shader = Shader.Find(TRANSPARENT_SHADER)
      mat.shader = shader
      local color = Color.Color(self._circleCfg.circleModelR / 255, self._circleCfg.circleModelG / 255, self._circleCfg.circleModelB / 255, self._circleCfg.circleModelA / 255)
      mat:SetColor("_TintColor", color)
      mat.renderQueue = RENDER_QUEUE
    else
      warn("[ERROR][SafeZoneModel:_LoadQuads] quad renderer or material nil:", renderer, mat)
    end
    table.insert(self._quadList, quad)
  end
end
def.method()._UpdateQuads = function(self)
  if nil == self._quadList then
    return
  end
  local curCircleRadius = 0
  if 0 < self._circleIdx then
    local cricleLevelCfg = self._circleCfg.levelCfgs[self._circleIdx]
    if nil == cricleLevelCfg then
      warn("[ERROR][SafeZoneModel:_UpdateQuads] cricleLevelCfg nil at idx:", self._circleIdx)
      return
    end
    curCircleRadius = cricleLevelCfg.circleRadius
  else
    curCircleRadius = self._circleCfg.initRadius
  end
  local mapWidth = self._mapCfg.width
  local mapHeight = self._mapCfg.height
  local upGap = math.max(0, self._circleCfg.circleCenterY - curCircleRadius)
  local downGap = math.max(0, mapHeight - self._circleCfg.circleCenterY - curCircleRadius)
  local leftGap = math.max(0, self._circleCfg.circleCenterX - curCircleRadius)
  local rightGap = math.max(0, mapWidth - self._circleCfg.circleCenterX - curCircleRadius)
  local upQuad = self._quadList[1]
  if not _G.IsNil(upQuad) then
    upQuad.localPosition = EC.Vector3.new(mapWidth / 2, upGap / 2, 0)
    upQuad.localScale = EC.Vector3.new(mapWidth, upGap, 1)
  end
  local rightQuad = self._quadList[2]
  if not _G.IsNil(rightQuad) then
    rightQuad.localPosition = EC.Vector3.new(mapWidth - rightGap / 2, self._circleCfg.circleCenterY, 0)
    rightQuad.localScale = EC.Vector3.new(rightGap, curCircleRadius * 2, 1)
  end
  local downQuad = self._quadList[3]
  if not _G.IsNil(downQuad) then
    downQuad.localPosition = EC.Vector3.new(mapWidth / 2, mapHeight - downGap / 2, 0)
    downQuad.localScale = EC.Vector3.new(mapWidth, downGap, 1)
  end
  local leftQuad = self._quadList[4]
  if not _G.IsNil(leftQuad) then
    leftQuad.localPosition = EC.Vector3.new(leftGap / 2, self._circleCfg.circleCenterY, 0)
    leftQuad.localScale = EC.Vector3.new(leftGap, curCircleRadius * 2, 1)
  end
end
def.method().DestroyQuads = function(self)
  if self._quadList then
    for _, quad in ipairs(self._quadList) do
      quad:Destroy()
    end
    self._quadList = nil
  end
end
return SafeZoneModel.Commit()
