local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MiniMapPanel = Lplus.Extend(ECPanelBase, "MiniMapPanel")
local EC = require("Types.Vector3")
local MapUtility = require("Main.Map.MapUtility")
local MapModule = require("Main.Map.MapModule")
local NPCInterface = require("Main.npc.NPCInterface")
local NpcType = require("consts.mzm.gsp.npc.confbean.NpcType")
local ColorType = require("consts.mzm.gsp.map.confbean.ColorType")
local GUIUtils = require("GUI.GUIUtils")
local MiniMapMgr = require("Main.Map.MiniMapMgr")
local def = MiniMapPanel.define
def.const("string").MINI_MAP_ATLAS_NAME = RESPATH.MINIMAP_ATLAS
def.const("string").TRANSPORT_RES = RESPATH.PREFAB_MINI_TRANSPOINT
def.const("table").TRANSPORT_SPRITE_NAME_LIST = {
  [ColorType.NONE] = "csd_000",
  [ColorType.BLUE] = "csd_000",
  [ColorType.RED] = "csd_001",
  [ColorType.GREEN] = "csd_002"
}
def.const("table").NPC_POINT_SPRITE_NAME_LIST = {
  Normal = "NPC_Common",
  Function = "NPC_Function"
}
local Depths = require("Main.Map.data.MinimapUnitDepth")
def.const("table").Depths = Depths
def.const("number").NPC_NAME_OFFSET_Y = 16
def.const("number").NPC_POINT_SIZE = 14
def.field("number").PATH_POINT_DISTANCE = 20
def.field("userdata").miniMapTex = nil
def.field("table").mapCfg = nil
def.field("table").miniMapSize = nil
def.field("table").transferMap = nil
def.field("userdata").heroPrefab = nil
def.field("userdata").tracePointPrefab = nil
def.field("userdata").traceTargetPrefab = nil
def.field("userdata").transpointPrefab = nil
def.field("userdata").miniMapAtlas = nil
def.field("userdata").heroImage = nil
def.field("userdata").npcPointTemplate = nil
def.field("number").mini2WorldRatio = 1
def.field("table").mini2WorldOffset = nil
def.field("table").traceTargetPoint = nil
def.field("table").traceStartPos = nil
def.field("table").tracePointList = nil
def.field("number").tracePointIndex = 0
def.field("number").tracePointCount = 0
def.field("number").borderWidth = 0
def.field("number").borderHeight = 0
def.field("userdata").targetObj = nil
def.field("table").npcCfgList = nil
def.field("userdata").ui_Img_MapMini = nil
def.field("table").uiObjs = nil
def.field("boolean").showNPCPoint = false
def.field("boolean").m_isReady = false
local instance
def.static("=>", MiniMapPanel).Instance = function()
  if instance == nil then
    instance = MiniMapPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_TrigGC = true
  self.m_TryIncLoadSpeed = true
  require("Main.Map.ui.MiniMapWeddingCarriage").Instance():Init()
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.MINI_MAP_PANEL_RES, 1)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:InitUI()
  self.m_panel:SetActive(false)
  self:LoadMiniMapRes()
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, MiniMapPanel.OnMapChange)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.SYNC_HERO_MAP_POS, MiniMapPanel.OnSyncHeroMapPos)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_MOVE, MiniMapPanel.OnHeroMove)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_FINDPATH_FINISHED, MiniMapPanel.OnHeroFindPathFinished)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, MiniMapPanel.OnEnterFight)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MINI_MAP_NPC_CHANGED, MiniMapPanel.OnMiniMapNpcChanged)
end
def.override().OnDestroy = function(self)
  local camGO = GameObject.Find("/Homeland Minimap Camera")
  if camGO then
    GameObject.Destroy(camGO)
  end
  if self.npcPointTemplate then
    GameObject.Destroy(self.npcPointTemplate)
    self.npcPointTemplate = nil
  end
  Event.UnregisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, MiniMapPanel.OnMapChange)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.SYNC_HERO_MAP_POS, MiniMapPanel.OnSyncHeroMapPos)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_MOVE, MiniMapPanel.OnHeroMove)
  Event.UnregisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_FINDPATH_FINISHED, MiniMapPanel.OnHeroFindPathFinished)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, MiniMapPanel.OnEnterFight)
  Event.UnregisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MINI_MAP_NPC_CHANGED, MiniMapPanel.OnMiniMapNpcChanged)
  self.miniMapTex = nil
  self.heroPrefab = nil
  self.tracePointPrefab = nil
  self.traceTargetPrefab = nil
  self.targetObj = nil
  self.heroImage = nil
  self.transferMap = nil
  self.transpointPrefab = nil
  self.miniMapAtlas = nil
  self.uiObjs = nil
  self.npcCfgList = nil
  self.traceTargetPoint = nil
  self.traceStartPos = nil
  self.m_isReady = false
  Event.DispatchEvent(ModuleId.MAP, gmodule.notifyId.Map.MINI_MAP_DESTROYED, nil)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Label_NPC = self.uiObjs.Img_Bg0:FindDirect("Label_NPC")
  self.uiObjs.Label_Map = self.uiObjs.Img_Bg0:FindDirect("Label_Map")
  local go = self.uiObjs.Label_NPC
  local label = go:GetComponent("UILabel")
  label.transform:set_localPosition(EC.Vector3.new(0, 0, 0))
  go:AddComponent("BoxCollider")
  label:set_autoResizeBoxCollider(true)
  label:set_depth(Depths.NPCLabel)
  go:SetActive(false)
  self.ui_Img_MapMini = self.m_panel:FindDirect("Img_MapMini")
  self.ui_Img_MapMini:SetActive(true)
  self.traceTargetPrefab = self.m_panel:FindDirect("MiniMap_TraceTarget")
  self.tracePointPrefab = self.m_panel:FindDirect("MiniMap_TracePoint")
  self.heroPrefab = self.m_panel:FindDirect("MiniMap_HeroIamge")
  self.transpointPrefab = self.m_panel:FindDirect("MiniMap_Transpoint")
  self.tracePointPrefab:GetComponent("UIWidget").depth = Depths.TracePoint
  self.traceTargetPrefab:GetComponent("UIWidget").depth = Depths.TraceTarget
  self.heroPrefab:GetComponent("UIWidget").depth = Depths.HeroAvatar
  local Img_BgNpc = self.uiObjs.Img_Bg0:FindDirect("Img_BgNpc")
  Img_BgNpc:SetActive(false)
  Img_BgNpc:GetComponent("UIWidget").depth = Depths.Ceil
  local bgWidget = self.uiObjs.Img_Bg0:GetComponent("UIWidget")
  local imgWidget = self.ui_Img_MapMini:GetComponent("UIWidget")
  self.borderWidth = bgWidget.width - imgWidget.width
  self.borderHeight = bgWidget.height - imgWidget.height
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "TRANSFER_LABEL" or id == "TRANSFER_IMG" then
    local parentId = obj.transform.parent.gameObject.name
    local mapId = tonumber(string.sub(parentId, #"MINI_MAP_TRANSFER_" + 1, -1))
    self:OnTransferPointClick(mapId)
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Modal" then
    self:HidePanel()
  elseif id == "Btn_MapWorld" then
    self:OnWorldMapButtonClick()
  elseif id == "Btn_Search" then
    self:OnSearchButtonClick()
  elseif string.sub(id, 1, 11) == "Img_BgNpc01" then
    self:OnSearchNPCClick(id)
  elseif id == "Img_BgNpc" then
  elseif id == "Img_MapMini" then
    self:OnTouchMiniMap()
  elseif string.sub(id, 1, 10) == "NPC_LABEL_" then
    self:OnNpcLabelClick(id)
  elseif string.sub(id, 1, #"NPC_POS_POINT_") == "NPC_POS_POINT_" then
    self:OnNpcPosPointClick(id)
  end
end
def.method().OnWorldMapButtonClick = function(self)
  self:HidePanel()
  require("Main.Map.ui.WorldMapPanel").Instance():ShowPanel()
end
def.method().OnSearchButtonClick = function(self)
  local isActive = self.m_panel:FindDirect("Img_Bg0/Img_BgNpc").activeInHierarchy
  if isActive then
    self.m_panel:FindDirect("Img_Bg0/Img_BgNpc"):SetActive(false)
  else
    self.m_panel:FindDirect("Img_Bg0/Img_BgNpc"):SetActive(true)
    self:SetNPCSearchList()
  end
end
def.method("string").OnSearchNPCClick = function(self, id)
  self.m_panel:FindDirect("Img_Bg0/Img_BgNpc"):SetActive(false)
  if self.npcCfgList == nil then
    return
  end
  local index = tonumber(string.sub(id, 13, -1))
  local npcCfg = self.npcCfgList[index]
  self:HidePanel()
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_NPC, {
    npcCfg.NpcID
  })
end
def.method("string").OnNpcLabelClick = function(self, id)
  local npcId = tonumber(string.sub(id, 11, -1))
  self:HidePanel()
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_NPC, {npcId})
end
def.method("string").OnNpcPosPointClick = function(self, id)
  local npcId = tonumber(string.sub(id, #"NPC_POS_POINT_" + 1, -1))
  self:HidePanel()
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_NPC, {npcId})
end
def.method("number").OnTransferPointClick = function(self, targetMapId)
  local targetPos = self.transferMap[targetMapId]
  if targetPos == nil then
    return
  end
  self:MoveTo(targetPos.x, targetPos.y)
  self:HidePanel()
end
def.static("table", "table").OnMapChange = function()
  if instance == nil then
    return
  end
  instance:HidePanel()
end
def.static("table", "table").OnEnterFight = function()
  instance:HidePanel()
end
def.static("table", "table").OnSyncHeroMapPos = function(pos, p2)
  local x, y = pos.x, pos.y
  instance:SyncHeroMiniMapPos(x, y)
end
def.static("table", "table").OnHeroMove = function(pos, p2)
  instance:TraceRole()
end
def.static("table", "table").OnHeroFindPathFinished = function(params, context)
  local self = instance
  self:SyncHeroMiniMapPos(params.x, params.y)
  self:RemoveTraceTarget()
end
def.static("table", "table").OnMiniMapNpcChanged = function(params, context)
  local npcId = params.npcId
  local isShow = params.show
  local self = instance
  self:RemoveNPC(npcId)
  if isShow then
    self:AddNPCById(npcId)
    if self.showNPCPoint then
      self:AddNPCPosPointById(npcId)
    end
  end
  local isActive = self.m_panel:FindDirect("Img_Bg0/Img_BgNpc").activeInHierarchy
  if isActive then
    self:SetNPCSearchList()
  end
end
def.method().LoadMiniMapRes = function(self)
  local mapId = MapModule.Instance():GetMapId()
  local mapCfg = MapUtility.GetMapCfg(mapId)
  self.mapCfg = mapCfg
  if gmodule.moduleMgr:GetModule(ModuleId.HERO).isInHomeland then
    local renderTexture = RenderTexture.RenderTexture(1024, 512, 16)
    local camGO = GameObject.Find("/Homeland Minimap Camera")
    if camGO == nil then
      local cam = CommonCamera.game2DCamera
      camGO = GameObject.Instantiate(cam.gameObject)
      camGO.name = "Homeland Minimap Camera"
    end
    local camera = camGO:GetComponent("Camera")
    camera.aspect = world_width / world_height
    camGO.localPosition = EC.Vector3.new(world_width / 2, world_height / 2, camGO.localPosition.z)
    camera.orthographicSize = world_height / 2
    camera.targetTexture = renderTexture
    camera.backgroundColor = Color.clear
    self.miniMapTex = renderTexture
    print("mini map loaded renderTexture")
    local offsetX = 0
    local offsetY = 0
    self.mini2WorldOffset = {
      x = offsetX,
      y = offsetY,
      aspect = camera.aspect
    }
    if self.m_panel then
      self.m_panel:SetActive(true)
      local uiSprite = self.m_panel:FindDirect("Img_Bg0"):GetComponent("UISprite")
      uiSprite.enabled = false
      self:SetMiniMap()
    end
    return
  end
  local resPath = MapUtility.GetMiniMapResPath(mapId)
  print("mapId:", mapId, " resPath:", resPath)
  self:AsyncLoadMiniMap(resPath)
end
def.method("string").AsyncLoadMiniMap = function(self, resPath)
  self.mini2WorldOffset = {x = 0, y = 0}
  GameUtil.AsyncLoad(resPath, function(ass)
    local texture
    if ass and ass.bytes then
      local tex2d = Texture2D.Texture2D(0, 0, TextureFormat.RGBA32, false)
      local ret = tex2d:LoadImage(ass.bytes)
      if not ret then
        print("LoadImage for png error")
      end
      texture = tex2d
    elseif ass then
      texture = ass
    else
      warn(resPath .. "load fail")
    end
    self.miniMapTex = texture
    print("mini map loaded", resPath)
    if self.m_panel then
      self.m_panel:SetActive(true)
      self:SetMiniMap()
    end
  end)
end
def.method().SetMiniMap = function(self)
  local texture_minimap = self.ui_Img_MapMini:GetComponent("UITexture")
  texture_minimap:set_mainTexture(self.miniMapTex)
  local mapId = MapModule.Instance():GetMapId()
  local mapCfg = MapUtility.GetMapCfg(mapId)
  local msize = {w = 0, h = 0}
  if self.miniMapTex then
    msize.w = self.miniMapTex.width
    msize.h = self.miniMapTex.height
    if self.mini2WorldOffset.aspect then
      msize.w = self.mini2WorldOffset.aspect * 512
      local scale = 1
      if msize.w >= 850 then
        scale = 850 / msize.w
        msize.w = 850
      end
      msize.h = 512 * scale
    end
  end
  if msize.w == 2048 and msize.h == 2048 then
    self:HidePanel()
    return
  end
  self.mapCfg = nil
  self.miniMapSize = msize
  local mapSize = require("Main.Map.Interface").GetCurMapSize()
  self.mini2WorldRatio = self.miniMapSize.h / LuaMathSize.height(mapSize)
  texture_minimap:set_width(msize.w)
  texture_minimap:set_height(msize.h)
  texture_minimap:set_pivot(0)
  local boxCollider = self.ui_Img_MapMini:GetComponent("BoxCollider")
  boxCollider:set_center(EC.Vector3.new(msize.w / 2, -msize.h / 2))
  local base = self.m_panel:FindDirect("Img_Bg0"):GetComponent("UISprite")
  base:set_width(msize.w + self.borderWidth)
  base:set_height(msize.h + self.borderHeight)
  self:SetMapName(mapCfg.mapName)
  self:SetHeroImage()
  self:SetNPCS(mapId)
  self:SetMapRestriction(mapId)
  self:SetTransferPoint(mapId)
  self:UpdateAnchors()
  self.m_isReady = true
  Event.DispatchEvent(ModuleId.MAP, gmodule.notifyId.Map.MINI_MAP_READY, nil)
end
def.method("=>", "boolean").IsReady = function(self)
  if not self:IsLoaded() then
    return false
  end
  return self.m_isReady
end
def.method().UpdateAnchors = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  Img_Bg0:FindDirect("Btn_Close"):GetComponent("UIWidget"):UpdateAnchors()
  Img_Bg0:FindDirect("Btn_MapWorld"):GetComponent("UIWidget"):UpdateAnchors()
  Img_Bg0:FindDirect("Btn_Search"):GetComponent("UIWidget"):UpdateAnchors()
end
def.method("string").SetMapName = function(self, mapName)
  local Img_MapName = self.uiObjs.Img_Bg0:FindDirect("Img_MapName")
  if Img_MapName then
    Img_MapName:GetComponentInChildren("UILabel").text = mapName
  end
end
def.method("number").SetMapRestriction = function(self, mapId)
  self.ui_Img_MapMini:FindDirect("Img_BgTips"):SetActive(false)
end
def.method("number").SetTransferPoint = function(self, mapId)
  local transfer = MapUtility.GetMapTransfers(mapId)
  if transfer == nil then
    return
  end
  self.transferMap = {}
  local base = self.ui_Img_MapMini
  for i, transferPoint in ipairs(transfer) do
    local targetMapName = self:GetTargetMapName(transferPoint.default_target_map_id)
    local mapTranspointCfg = MapUtility.GetMapTransportCfg(transferPoint.default_target_map_id)
    local transferColor = mapTranspointCfg and mapTranspointCfg.color or ColorType.BLUE
    self:AddTransferPoint(base, transferPoint.default_target_map_id, targetMapName, {
      x = transferPoint.center_x,
      y = transferPoint.center_y
    }, transferColor)
  end
  self.m_msgHandler:Touch(base)
end
def.method("number", "=>", "string").GetTargetMapName = function(self, mapId)
  local homelandModule = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND)
  local homelandInfo = homelandModule:GetCurHomelandInfo()
  if homelandInfo then
    local HomelandUtils = require("Main.Homeland.HomelandUtils")
    if homelandModule:IsHouseMap(mapId) then
      local houseCfg = HomelandUtils.GetHouseCfg(homelandInfo.houseLevel)
      if houseCfg then
        mapId = houseCfg.mapId
      end
    elseif homelandModule:IsCourtyardMap(mapId) then
      local courtyardCfg = HomelandUtils.GetCourtyardCfg(homelandInfo.courtyardLevel)
      if courtyardCfg then
        mapId = courtyardCfg.mapId
      end
    end
  end
  local mapCfg = MapUtility.GetMapCfg(mapId)
  local mapName = mapCfg and mapCfg.mapName or ""
  return mapName
end
def.method("userdata", "number", "string", "table", "number").AddTransferPoint = function(self, base, mapId, mapName, pos, color)
  local go = GameObject.Instantiate(self.transpointPrefab)
  go:SetActive(true)
  go.name = "MINI_MAP_TRANSFER_" .. mapId
  local label = go:GetComponentInChildren("UILabel")
  label.gameObject.name = "TRANSFER_LABEL"
  label:set_depth(Depths.Transfer)
  label:set_text(mapName)
  local sprite = go:GetComponentInChildren("UISprite")
  sprite.gameObject.name = "TRANSFER_IMG"
  sprite.spriteName = self:GetTransferPointSpriteByColor(color)
  sprite.depth = Depths.Transfer
  self:AddUnitToMap(go, pos)
  self.transferMap[mapId] = pos
end
def.method("number", "=>", "string").GetTransferPointSpriteByColor = function(self, color)
  return MiniMapPanel.TRANSPORT_SPRITE_NAME_LIST[color] or "nil"
end
def.method().SetHeroImage = function(self)
  if self.heroPrefab == nil then
    return
  end
  local go = GameObject.Instantiate(self.heroPrefab)
  go:SetActive(true)
  local tween = go:GetComponent("TweenPosition")
  tween:set_worldSpace(true)
  local myRole = require("Main.Hero.HeroModule").Instance().myRole
  local pos = myRole:GetPos()
  self:AddUnitToMap(go, pos)
  self.heroImage = go
end
def.method("number").SetNPCS = function(self, mapId)
  local npcList = MiniMapMgr.Instance():GetMiniMapNPCs(mapId)
  if #npcList > 0 then
    if self.m_panel == nil then
      return
    end
    for i, npcId in ipairs(npcList) do
      self:AddNPCById(npcId)
    end
    self:SetNPCPosPoint()
  else
    local go_grid = self.m_panel:FindDirect("Img_Bg0/Img_BgNpc/Scroll View_Npc/Grid_Npc")
    local grid_list = go_grid:GetComponent("UIList")
    grid_list:set_itemCount(0)
    grid_list:Resize()
    self.npcCfgList = {}
  end
end
def.method("=>", "userdata").GetNPCLabelTemplate = function(self)
  return self.uiObjs.Label_NPC
end
def.method("userdata", "table").AddUnitToMap = function(self, go, pos)
  local parent = self.ui_Img_MapMini
  self:AddUnitToMapGO(go, parent, pos)
end
def.method("userdata", "table").AddUnitToMiniMap = function(self, go, mpos)
  local miniMapPos = mpos
  local parent = self.ui_Img_MapMini
  self:AddUnitToMiniMapGO(go, parent, miniMapPos)
end
def.method("userdata", "userdata", "table").AddUnitToMapGO = function(self, go, parent, pos)
  local miniMapPos = self:WorldPos2DToMiniMapPos(pos)
  self:AddUnitToMiniMapGO(go, parent, miniMapPos)
end
def.method("userdata", "userdata", "table").AddUnitToMiniMapGO = function(self, go, parent, mpos)
  local miniMapPos = mpos
  go.transform:set_parent(parent.transform)
  go.transform:set_localScale(EC.Vector3.one)
  go.transform:set_localPosition(EC.Vector3.new(miniMapPos.x, miniMapPos.y, 0))
end
def.method("userdata", "table").SetUnitByWorldPos2D = function(self, go, pos)
  local miniMapPos = self:WorldPos2DToMiniMapPos(pos)
  go:set_localPosition(EC.Vector3.new(miniMapPos.x, miniMapPos.y, 0))
end
def.method("userdata", "number", "table", "=>", "userdata").TweenToTargetByWorldPos2D = function(self, go, duration, pos)
  local miniMapPos = self:WorldPos2DToMiniMapPos(pos)
  return self:TweenToTargetByMinimapPos(go, duration, miniMapPos)
end
def.method("userdata", "number", "table", "=>", "userdata").TweenToTargetByMinimapPos = function(self, go, duration, miniMapPos)
  local targetPos = self:MiniMapPosToWorldPos3D(miniMapPos)
  return self:TweenToTargetByWorldPos3D(go, duration, targetPos)
end
def.method("userdata", "number", "table", "=>", "userdata").TweenToTargetByWorldPos3D = function(self, go, duration, targetPos)
  local tp = TweenPosition.Begin(go, duration, targetPos)
  tp:set_worldSpace(true)
  tp:SetStartToCurrentValue()
  return tp
end
def.method("number").AddNPCById = function(self, npcId)
  self.npcCfgList = self.npcCfgList or {}
  local npcCfg = NPCInterface.GetNPCCfg(npcId)
  self:AddNPCByCfg(npcCfg)
  table.insert(self.npcCfgList, npcCfg)
end
def.method("table").AddNPCByCfg = function(self, npcCfg)
  local base = self.ui_Img_MapMini
  local template = self:GetNPCLabelTemplate()
  self:AddNPC(base, template, npcCfg)
end
def.method("userdata", "userdata", "table").AddNPC = function(self, base, template, npcCfg)
  local npcDisplayName = npcCfg.miniMapName ~= "" and npcCfg.miniMapName or npcCfg.npcName
  local npcId, npcName, npcType, pos = npcCfg.NpcID, npcDisplayName, npcCfg.npcType, {
    x = npcCfg.x,
    y = npcCfg.y
  }
  local colorId = npcCfg.miniMapNameColor or 0
  local colorCfg
  if colorId ~= 0 then
    colorCfg = _G.GetNameColorCfg(colorId)
  end
  if colorCfg then
    local colorCode = string.format("%x%x%x", colorCfg.r, colorCfg.g, colorCfg.b)
    npcName = string.format("[%s]%s[-]", colorCode, npcName)
  end
  local go = GameObject.Instantiate(template)
  go:SetActive(true)
  go.name = "NPC_LABEL_" .. npcId
  local label = go:GetComponent("UILabel")
  local npcNameText = npcName
  label:set_text(npcNameText)
  local offset = {x = 0, y = 0}
  if self.showNPCPoint then
    offset.y = MiniMapPanel.NPC_NAME_OFFSET_Y
  end
  local miniMapPos = self:WorldPos2DToMiniMapPos(pos)
  miniMapPos.x = miniMapPos.x + offset.x
  miniMapPos.y = miniMapPos.y + offset.y
  self:AddUnitToMiniMap(go, miniMapPos)
  self.m_msgHandler:Touch(go)
end
def.method("userdata").RemoveUnit = function(self, go)
  if go then
    GameObject.Destroy(go)
  end
end
def.method("number").RemoveNPC = function(self, npcId)
  local base = self.ui_Img_MapMini
  local npcLabel = base:FindDirect(string.format("NPC_LABEL_%d", npcId))
  if npcLabel then
    GameObject.Destroy(npcLabel)
  end
  local npcPoint = base:FindDirect(string.format("NPC_POS_POINT_%d", npcId))
  if npcPoint then
    GameObject.Destroy(npcPoint)
  end
  if self.npcCfgList then
    for i, v in ipairs(self.npcCfgList) do
      if v.NpcID == npcId then
        table.remove(self.npcCfgList, i)
        break
      end
    end
  end
end
def.method().SetNPCPosPoint = function(self)
  local tmp_remove = not self.showNPCPoint
  if tmp_remove then
    return
  end
  AsyncLoadArray({
    MiniMapPanel.MINI_MAP_ATLAS_NAME
  }, function(assetArr)
    local textureList = {}
    for i, ass in ipairs(assetArr) do
      local texture
      if ass and ass.bytes then
        local tex2d = Texture2D.Texture2D(0, 0, TextureFormat.RGBA32, false)
        local ret = tex2d:LoadImage(ass.bytes)
        if not ret then
          print("LoadImage for png error")
        end
        texture = tex2d
      else
        if ass then
          texture = ass
        else
        end
      end
      table.insert(textureList, texture)
    end
    local obj = textureList[1]
    local atlas = obj:GetComponent("UIAtlas")
    self.miniMapAtlas = atlas
    if self:IsShow() then
      self:_SetNPCPosPoint()
    end
  end)
end
def.method()._SetNPCPosPoint = function(self)
  local npcCfgList = self.npcCfgList
  if self.npcPointTemplate == nil then
    local go = GameObject.GameObject("NPC_POS_POINT")
    go:SetLayer(ClientDef_Layer.UI)
    local uiSprite = go:AddComponent("UISprite")
    uiSprite:set_atlas(self.miniMapAtlas)
    local size = MiniMapPanel.NPC_POINT_SIZE
    uiSprite:set_width(size)
    uiSprite:set_height(size)
    local boxCollider = go:AddComponent("BoxCollider")
    boxCollider:set_size(EC.Vector3.new(size, size, 0))
    uiSprite:set_autoResizeBoxCollider(true)
    uiSprite:set_depth(Depths.NPCPoint)
    go:SetActive(false)
    self.npcPointTemplate = go
  end
  local template = self.npcPointTemplate
  local base = self.ui_Img_MapMini
  for i, npcCfg in ipairs(npcCfgList) do
    self:_AddNPCPosPointByCfg(base, template, npcCfg)
  end
end
def.method("number").AddNPCPosPointById = function(self, npcId)
  local npcCfg = NPCInterface.GetNPCCfg(npcId)
  local base = self.ui_Img_MapMini
  local template = self.npcPointTemplate
  self:_AddNPCPosPointByCfg(base, template, npcCfg)
end
def.method("userdata", "userdata", "table")._AddNPCPosPointByCfg = function(self, base, template, npcCfg)
  self:_AddNPCPosPoint(base, template, npcCfg.NpcID, npcCfg.npcName, npcCfg.npcType, {
    x = npcCfg.x,
    y = npcCfg.y
  })
end
def.method("userdata", "userdata", "number", "string", "number", "table")._AddNPCPosPoint = function(self, base, template, npcId, npcName, npcType, pos)
  if template == nil then
    return
  end
  local spriteName
  if npcType == NpcType.NORMAL then
    spriteName = MiniMapPanel.NPC_POINT_SPRITE_NAME_LIST.Normal
  else
    spriteName = MiniMapPanel.NPC_POINT_SPRITE_NAME_LIST.Function
  end
  local go = GameObject.Instantiate(template)
  go:SetActive(true)
  go.name = "NPC_POS_POINT_" .. npcId
  local uiSprite = go:GetComponent("UISprite")
  uiSprite:set_spriteName(spriteName)
  self:AddUnitToMap(go, pos)
  self.m_msgHandler:Touch(go)
end
def.method().SetNPCSearchList = function(self)
  local npcCfgList = self.npcCfgList
  local go_grid = self.m_panel:FindDirect("Img_Bg0/Img_BgNpc/Scroll View_Npc/Grid_Npc")
  local grid_list = go_grid:GetComponent("UIList")
  grid_list:set_itemCount(#npcCfgList)
  grid_list:Resize()
  local items = grid_list:get_children()
  for i, npcCfg in ipairs(npcCfgList) do
    local label = items[i]:GetComponentInChildren("UILabel")
    local npcDisplayName = npcCfg.miniMapName ~= "" and npcCfg.miniMapName or npcCfg.npcName
    label:set_text(npcDisplayName)
  end
  GameUtil.AsyncLoad(RESPATH.HEADATLAS, function(obj)
    if self.m_panel == nil then
      return
    end
    local atlas = obj:GetComponent("UIAtlas")
    for i, npcCfg in ipairs(npcCfgList) do
      local uiTexture = items[i]:FindDirect(string.format("Img_BgIcon01_%d/Img_Icon01_%d", i, i)):GetComponent("UITexture")
      local modelCfg = require("Main.Pubrole.PubroleInterface").GetModelCfg(npcCfg.monsterModelTableId)
      local iconId = modelCfg.headerIconId
      require("GUI.GUIUtils").FillIcon(uiTexture, iconId)
    end
  end)
  self.m_msgHandler:Touch(go_grid)
end
def.method().OnTouchMiniMap = function(self)
  local miniMapPos = self:TouchPos2MiniMapPos()
  local mapPos = self:MiniMapPosToWorldPos2D(miniMapPos)
  self:MoveTo(mapPos.x, mapPos.y)
  self.m_panel:FindDirect("Img_Bg0/Img_BgNpc"):SetActive(false)
end
def.method("number", "number").MoveTo = function(self, x, y)
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  heroModule.needShowAutoEffect = true
  heroModule:MoveTo(MapModule.Instance():GetMapId(), x, y, -1, 0, MoveType.AUTO, nil)
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, {x = x, y = y})
end
def.method("number").TransportToMap = function(self, mapId)
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  heroModule.needShowAutoEffect = true
  heroModule:MoveTo(mapId, mapCfg.defaultTransposX, mapCfg.defaultTransposY, -1, 0, MoveType.AUTO, nil)
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, {x = x, y = y})
end
def.method().TraceRole = function(self)
  if not self:IsShow() then
    return
  end
  local HeroModule = require("Main.Hero.HeroModule").Instance()
  if HeroModule.myRole == nil or HeroModule.myRole.movePath == nil or HeroModule.myRole.pathIdx == 0 then
    return
  end
  if self.tracePointPrefab == nil or self.traceTargetPrefab == nil then
    return
  end
  local totalKeyPoint = #HeroModule.myRole.movePath
  local tragetKeyPoint = HeroModule.myRole.movePath[totalKeyPoint]
  if self.traceTargetPoint ~= nil and self.traceTargetPoint.x == tragetKeyPoint.x and self.traceTargetPoint.y == tragetKeyPoint.y then
    return
  end
  self.traceTargetPoint = EC.Vector3.new(tragetKeyPoint.x, tragetKeyPoint.y, 0)
  print(string.format("Trace target (%d, %d)", tragetKeyPoint.x, tragetKeyPoint.y))
  self:ResetTraceState()
  local ratio = self.mini2WorldRatio
  local heroPos = HeroModule.myRole:GetPos()
  self.traceStartPos = EC.Vector3.new(heroPos.x, heroPos.y, 0)
  local heroPosV3 = EC.Vector3.new(heroPos.x * ratio, heroPos.y * -ratio, 0)
  local prePointV3 = EC.Vector3.new(heroPos.x * ratio, heroPos.y * -ratio, 0)
  local totalKeyPoint = #HeroModule.myRole.movePath
  local startKeyPoint = totalKeyPoint - HeroModule.myRole.pathIdx + 1
  for i = startKeyPoint, totalKeyPoint do
    local keyPoint = HeroModule.myRole.movePath[i]
    local keyPointV3 = EC.Vector3.new(keyPoint.x * ratio, keyPoint.y * -ratio, 0)
    local dis = GameUtil.Distance(prePointV3, keyPointV3)
    local xLen, yLen
    if dis > self.PATH_POINT_DISTANCE then
      local sx, sy = 1, 1
      if prePointV3.x > keyPointV3.x then
        sx = -1
      end
      if prePointV3.y > keyPointV3.y then
        sy = -1
      end
      local theta = math.atan((prePointV3.y - keyPointV3.y) / (prePointV3.x - keyPointV3.x))
      xLen = sx * math.abs(math.cos(theta)) * self.PATH_POINT_DISTANCE
      yLen = sy * math.abs(math.sin(theta)) * self.PATH_POINT_DISTANCE
    end
    local isSet = false
    local count = 1
    while dis > self.PATH_POINT_DISTANCE do
      local mX = prePointV3.x + xLen
      local mY = prePointV3.y + yLen
      self:AddTracePoint(i, {x = mX, y = mY}, count)
      prePointV3.x, prePointV3.y = mX, mY
      dis = GameUtil.Distance(prePointV3, keyPointV3)
      isSet = true
      count = count + 1
    end
    if isSet then
      prePointV3.x, prePointV3.y = keyPointV3.x, keyPointV3.y
    end
  end
  local tragetKeyPointMiniMapPos = self:WorldPos2DToMiniMapPos(tragetKeyPoint)
  self:AddTraceTarget(totalKeyPoint, tragetKeyPointMiniMapPos)
end
def.method("number", "table", "number").AddTracePoint = function(self, traceKey, position, offset)
  if self.tracePointPrefab == nil then
    return
  end
  local go_tracePoint = GameObject.Instantiate(self.tracePointPrefab)
  go_tracePoint:SetActive(true)
  local go_base = self.ui_Img_MapMini:FindDirect("TracePointRoot")
  go_tracePoint.transform:set_parent(go_base.transform)
  go_tracePoint.transform:set_localScale(EC.Vector3.new(1, 1, 1))
  go_tracePoint.transform:set_localPosition(EC.Vector3.new(position.x, position.y, 0))
  self.tracePointList = self.tracePointList or {}
  self.tracePointCount = self.tracePointCount + 1
  table.insert(self.tracePointList, {
    key = traceKey,
    x = position.x,
    y = position.y,
    obj = go_tracePoint,
    offset = offset
  })
end
def.method("number", "table").AddTraceTarget = function(self, traceKey, position)
  if self.traceTargetPrefab == nil then
    return
  end
  local go_tracePoint = GameObject.Instantiate(self.traceTargetPrefab)
  go_tracePoint:SetActive(true)
  local go_base = self.ui_Img_MapMini
  go_tracePoint.transform:set_parent(go_base.transform)
  go_tracePoint.transform:set_localScale(EC.Vector3.new(1, 1, 1))
  go_tracePoint.transform:set_localPosition(EC.Vector3.new(position.x, position.y, 0))
  local ratio = self.mini2WorldRatio
  local displayPos = {
    x = math.floor(position.x / ratio / 16 + 0.5),
    y = math.floor(position.y / -ratio / 16 + 0.5)
  }
  local uiLabel = go_tracePoint:FindDirect("Label"):GetComponent("UILabel")
  uiLabel.text = string.format(textRes.Map[8], displayPos.x, displayPos.y)
  self.targetObj = go_tracePoint
end
def.method().RemoveTraceTarget = function(self)
  if self.targetObj ~= nil then
    GameObject.Destroy(self.targetObj)
    self.targetObj = nil
  end
end
def.method("number", "number").RemoveTracePoint = function(self, x, y)
  if self.tracePointList == nil then
    return
  end
  local HeroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local ratio = self.mini2WorldRatio
  if HeroModule.myRole.movePath == nil then
    for k, tracePoint in pairs(self.tracePointList) do
      if tracePoint.obj ~= nil then
        GameObject.Destroy(tracePoint.obj)
        tracePoint.obj = nil
      end
      self.tracePointList[k] = nil
    end
    return
  end
  local totalKeyPoint = #HeroModule.myRole.movePath
  local startKeyPoint = totalKeyPoint - HeroModule.myRole.pathIdx
  local prePoint = HeroModule.myRole.movePath[startKeyPoint] or self.traceStartPos
  if prePoint == nil then
    return
  end
  local prePointV3 = EC.Vector3.new(prePoint.x * ratio, prePoint.y * -ratio, 0)
  local heroPosV3 = EC.Vector3.new(x * ratio, y * -ratio)
  local distance = GameUtil.Distance(prePointV3, heroPosV3)
  local curIndex = startKeyPoint + 1
  for k, tracePoint in pairs(self.tracePointList) do
    if curIndex > tracePoint.key or tracePoint.key == curIndex and tracePoint.offset * self.PATH_POINT_DISTANCE <= distance + 10 then
      if tracePoint.obj ~= nil then
        GameObject.Destroy(tracePoint.obj)
        tracePoint.obj = nil
      end
      self.tracePointList[k] = nil
    else
      break
    end
  end
end
def.method().ResetTraceState = function(self)
  local tracePointRoot = self.ui_Img_MapMini:FindDirect("TracePointRoot")
  if tracePointRoot ~= nil then
    GameObject.DestroyImmediate(tracePointRoot)
  end
  tracePointRoot = GameObject.GameObject("TracePointRoot")
  tracePointRoot.transform:set_parent(self.ui_Img_MapMini.transform)
  tracePointRoot.transform:set_localScale(EC.Vector3.new(1, 1, 1))
  tracePointRoot.transform:set_localPosition(EC.Vector3.new(0, 0, 0))
  self.tracePointIndex = 1
  self.tracePointCount = 0
  self.tracePointList = nil
  self.traceStartPos = nil
  if self.targetObj ~= nil then
    GameObject.Destroy(self.targetObj)
    self.targetObj = nil
  end
end
def.method("number", "number").SyncHeroMiniMapPos = function(self, x, y)
  if not self:IsShow() or self.heroImage == nil then
    return
  end
  local tween = self.heroImage:GetComponent("TweenPosition")
  local miniMapPos = self:WorldPos2DToMiniMapPos({x = x, y = y})
  local targetPos = self:MiniMapPosToWorldPos3D(miniMapPos)
  TweenPosition.Begin(self.heroImage, 0.25, targetPos)
  self:RemoveTracePoint(x, y)
end
def.method("table", "=>", "table").WorldPos2DToMiniMapPos = function(self, pos)
  local ratio = self.mini2WorldRatio
  local offset = self.mini2WorldOffset
  return {
    x = (pos.x - offset.x) * ratio,
    y = -(pos.y - offset.y) * ratio
  }
end
def.method("table", "=>", "table").MiniMapPosToWorldPos2D = function(self, pos)
  local ratio = self.mini2WorldRatio
  local offset = self.mini2WorldOffset
  return {
    x = pos.x / ratio + offset.x,
    y = -pos.y / ratio + offset.y
  }
end
def.method("=>", "table").TouchPos2MiniMapPos = function(self)
  return self:WorldPos3DToMiniMapPos({
    x = UICamera.lastWorldPosition.x,
    y = UICamera.lastWorldPosition.y,
    z = 0
  })
end
def.method("table", "=>", "table").WorldPos3DToMiniMapPos = function(self, worldPos)
  local screenPos = WorldPosToScreen(worldPos.x, worldPos.y)
  local miniMap = self.ui_Img_MapMini
  local originalPos = WorldPosToScreen(miniMap.transform.position.x, miniMap.transform.position.y)
  local xOffset = screenPos.x - originalPos.x
  local yOffset = screenPos.y - originalPos.y
  return {x = xOffset, y = yOffset}
end
def.method("table", "=>", "table").MiniMapPosToWorldPos3D = function(self, miniMapPos)
  local miniMap = self.ui_Img_MapMini
  local originalPos = WorldPosToScreen(miniMap.position.x, miniMap.position.y)
  local targetPosX = originalPos.x + miniMapPos.x
  local targetPosY = originalPos.y + miniMapPos.y
  return ScreenPosToWorld(targetPosX, targetPosY)
end
MiniMapPanel.Commit()
return MiniMapPanel
