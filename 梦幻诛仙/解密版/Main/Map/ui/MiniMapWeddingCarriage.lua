local MODULE_NAME = (...)
local Lplus = require("Lplus")
local MiniMapWeddingCarriage = Lplus.Class(ECPanelBase, MODULE_NAME)
local MiniMapPanel = Lplus.ForwardDeclare("MiniMapPanel")
local MapModule = require("Main.Map.MapModule")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local WeddingTourUtils = require("Main.WeddingTour.WeddingTourUtils")
local def = MiniMapWeddingCarriage.define
def.const("table").SpriteName = {
  PathPoint = "Point_Pink",
  PathHeart = "Point_Heart"
}
def.field("table").weddingMapIds = nil
local instance
def.static("=>", MiniMapWeddingCarriage).Instance = function()
  if instance == nil then
    instance = MiniMapWeddingCarriage()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MINI_MAP_READY, MiniMapWeddingCarriage.OnMiniMapReady)
end
def.static("table", "table").OnMiniMapReady = function(params)
  instance:CheckToShowWeddingCarriage()
end
def.method().LoadWeddingMapIds = function(self)
  if self.weddingMapIds then
    return
  end
  local modes = WeddingTourUtils.GetAllWeddingTourModes()
  local weddingMapIds = {}
  for i, v in ipairs(modes) do
    weddingMapIds[v.paradeMapid] = v.paradeMapid
  end
  self.weddingMapIds = weddingMapIds
end
def.method().CheckToShowWeddingCarriage = function(self)
  local mapId = MapModule.Instance():GetMapId()
  self:LoadWeddingMapIds()
  if self.weddingMapIds[mapId] == nil then
    return
  end
  gmodule.moduleMgr:GetModule(ModuleId.MARRIAGE):ReqParadePosition(function(pos, paradeCfgId)
    local panel = MiniMapPanel.Instance()
    if panel.m_panel == nil or panel.m_panel.isnil then
      return
    end
    if pos.x < 0 or 0 > pos.y then
      return
    end
    self:ShowWeddingCarriage(paradeCfgId, pos)
  end)
end
def.method("number", "table").ShowWeddingCarriage = function(self, paradeCfgId, pos)
  local panel = MiniMapPanel.Instance()
  if panel.m_panel == nil or panel.m_panel.isnil then
    return
  end
  local weddingTourCfg = WeddingTourUtils.GetWeddingTourModeById(paradeCfgId)
  local iconId = weddingTourCfg and weddingTourCfg.rideIconid or 0
  local paradeMapid = weddingTourCfg and weddingTourCfg.paradeMapid or 0
  local mapId = MapModule.Instance():GetMapId()
  if mapId ~= paradeMapid then
    return
  end
  local WeddingCarriage = GameObject.GameObject("WeddingCarriage")
  WeddingCarriage:SetLayer(ClientDef_Layer.UI)
  local avatar = GameObject.GameObject("avatar")
  avatar:SetLayer(ClientDef_Layer.UI)
  avatar.parent = WeddingCarriage
  avatar.localScale = Vector.Vector3.one
  avatar.localPosition = Vector.Vector3.new(0, 30, 0)
  local uiTexture = avatar:AddComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, iconId)
  uiTexture.width = 32
  uiTexture.height = 54
  uiTexture.depth = MiniMapPanel.Depths.Floor + 5
  local name = GameObject.Instantiate(panel.uiObjs.Label_NPC)
  name.name = "name"
  name.parent = WeddingCarriage
  name.localScale = Vector.Vector3.one
  name.localPosition = Vector.Vector3.new(0, -10, 0)
  name:SetActive(true)
  name:GetComponent("UIWidget").depth = MiniMapPanel.Depths.Floor + 6
  GUIUtils.SetText(name, textRes.Map[16])
  panel:AddUnitToMap(WeddingCarriage, pos)
  local path = WeddingTourUtils.GetWeddingTourPath(paradeCfgId)
  local pathGO = GameObject.GameObject("WeddingTourPath")
  panel:AddUnitToMap(pathGO, {x = 0, y = 0})
  if #path == 0 then
    return
  end
  local PATH_POINT_DISTANCE = 22
  local ratio = panel.mini2WorldRatio
  local startKeyPoint = 1
  local totalKeyPoint = #path
  local startPoint = path[startKeyPoint]
  local prePointV3 = Vector.Vector3.new(startPoint.x * ratio, startPoint.y * -ratio, 0)
  local pointList = {}
  for i = startKeyPoint, totalKeyPoint do
    local keyPoint = path[i]
    local keyPointV3 = Vector.Vector3.new(keyPoint.x * ratio, keyPoint.y * -ratio, 0)
    local dis = GameUtil.Distance(prePointV3, keyPointV3)
    local xLen, yLen
    if PATH_POINT_DISTANCE < dis then
      local sx, sy = 1, 1
      if prePointV3.x > keyPointV3.x then
        sx = -1
      end
      if prePointV3.y > keyPointV3.y then
        sy = -1
      end
      local theta = math.atan((prePointV3.y - keyPointV3.y) / (prePointV3.x - keyPointV3.x))
      xLen = sx * math.abs(math.cos(theta)) * PATH_POINT_DISTANCE
      yLen = sy * math.abs(math.sin(theta)) * PATH_POINT_DISTANCE
    end
    local isSet = false
    local count = 1
    while PATH_POINT_DISTANCE < dis do
      local mX = prePointV3.x + xLen
      local mY = prePointV3.y + yLen
      local pointGO = self:CreateSpriteGO(MiniMapWeddingCarriage.SpriteName.PathPoint)
      pointGO.name = "point_" .. keyPoint.idx
      pointGO:GetComponent("UIWidget").depth = MiniMapPanel.Depths.Floor + 3
      local pos = {x = mX, y = mY}
      panel:AddUnitToMiniMapGO(pointGO, pathGO, pos)
      table.insert(pointList, {go = pointGO, pos = pos})
      prePointV3.x, prePointV3.y = mX, mY
      dis = GameUtil.Distance(prePointV3, keyPointV3)
      isSet = true
      count = count + 1
    end
    if isSet then
      prePointV3.x, prePointV3.y = keyPointV3.x, keyPointV3.y
    end
  end
  local preValue, preTheta
  local thresholdDegree = 30
  local thresholdTheta = thresholdDegree * math.pi / 180
  local pointCount = #pointList
  local lastHeartIndex = -1
  for i, v in ipairs(pointList) do
    local pointGO = v.go
    local pos = v.pos
    if preValue then
      local prePos = preValue.pos
      local theta = math.atan((prePos.y - pos.y) / (prePos.x - pos.x))
      if preTheta then
        local deltaTheta = math.abs(theta - preTheta)
        if thresholdTheta < deltaTheta and lastHeartIndex + 1 ~= i or i == pointCount then
          local prePointGO = preValue.go
          if i == pointCount then
            prePointGO = pointGO
          end
          GUIUtils.SetSprite(prePointGO, MiniMapWeddingCarriage.SpriteName.PathHeart)
          local uiWidget = prePointGO:GetComponent("UIWidget")
          uiWidget:MakePixelPerfect()
          uiWidget.depth = MiniMapPanel.Depths.Floor + 4
          local rotateDegree = theta * 180 / math.pi
          if prePos.x > pos.x then
            rotateDegree = rotateDegree + 180
          end
          rotateDegree = rotateDegree + 90
          prePointGO.localRotation = Quaternion.Euler(Vector.Vector3.new(0, 0, rotateDegree))
          lastHeartIndex = i
        end
      end
      preTheta = theta
    end
    preValue = v
  end
end
def.method("string", "=>", "userdata").CreateSpriteGO = function(self, spriteName)
  local panel = MiniMapPanel.Instance()
  if panel.m_panel == nil or panel.m_panel.isnil then
    return nil
  end
  local tempaateSprite = panel.tracePointPrefab:GetComponent("UISprite")
  local spriteGO = GameObject.GameObject(name)
  spriteGO:SetLayer(ClientDef_Layer.UI)
  local uiSprite = spriteGO:AddComponent("UISprite")
  uiSprite.atlas = tempaateSprite.atlas
  uiSprite.spriteName = spriteName
  uiSprite:MakePixelPerfect()
  return spriteGO
end
return MiniMapWeddingCarriage.Commit()
