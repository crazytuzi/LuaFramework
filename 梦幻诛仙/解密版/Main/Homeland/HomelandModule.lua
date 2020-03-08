local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local HomelandModule = Lplus.Extend(ModuleBase, "HomelandModule")
local ECGame = Lplus.ForwardDeclare("ECGame")
local LogicMap = require("Main.Homeland.data.LogicMap")
local EC = require("Types.Vector")
local Furniture = require("Main.Homeland.Furniture")
local ItemUtils = require("Main.Item.ItemUtils")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local HomelandProtocol = require("Main.Homeland.HomelandProtocol")
local HomelandTouchController = require("Main.Homeland.HomelandTouchController").Instance()
local HouseMgr = require("Main.Homeland.HouseMgr")
local CourtyardMgr = require("Main.Homeland.CourtyardMgr")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local MapEntityType = require("netio.protocol.mzm.gsp.map.MapEntityType")
local MapUtility = require("Main.Map.MapUtility")
local FurnitureAreaEnum = require("consts.mzm.gsp.item.confbean.FurnitureAreaEnum")
local def = HomelandModule.define
def.const("table").VisitType = {
  Owner = 1,
  ShareOwner = 2,
  Public = 4
}
def.const("table").Area = {
  NotHomeland = -1,
  House = FurnitureAreaEnum.ROOM,
  Courtyard = FurnitureAreaEnum.COURT_YARD
}
local instance
def.field("userdata").rootNode = nil
def.field("userdata").terrainobj = nil
def.field("table").furnitures = nil
def.field("boolean").m_canEdit = false
def.field("number").curEditId = 0
def.field("boolean").m_haveHome = false
def.field("boolean").m_playerIsOwner = false
def.field("table").m_houseMapCfgs = nil
def.field("table").m_courtyardMapCfgs = nil
def.field("table").m_serviceMap = nil
def.field("table").m_homelandInfo = nil
def.field("table").m_waitingHomelandInfo = nil
def.field("table").m_homeOffset = nil
def.field("table").myDisplayFurniture = nil
def.field("boolean").m_bGotoExplorerCat = false
def.field("boolean").m_isFirstMapChange = true
def.static("=>", HomelandModule).Instance = function()
  if instance == nil then
    instance = HomelandModule()
    instance.m_moduleId = ModuleId.HOMELAND
  end
  return instance
end
def.override().Init = function(self)
  self.rootNode = GameObject.GameObject("HomelandNodeRoot")
  self.rootNode.localPosition = EC.Vector3.zero
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, HomelandModule.OnChangeMap)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_INSTANCE_CHANGED, HomelandModule.OnChangeMapInstance)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.START_EDIT, HomelandModule.OnStartEdit)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.END_EDIT, HomelandModule.OnEndEdit)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.CANCEL_EDIT, HomelandModule.OnCancelEdit)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.OPPOSITE, HomelandModule.OnOpposite)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.EXPLORE_CAT_ENTER_VIEW, HomelandModule.OnExploreCatEnterView)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, HomelandModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, HomelandModule.OnAcceptNPCService)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, HomelandModule.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_RETURN_HOME_CLICK, HomelandModule.OnMainUIReturnHomeBtnClick)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, HomelandModule.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, HomelandModule.OnLeaveFight)
  Event.RegisterEvent(ModuleId.MARRIAGE, gmodule.notifyId.Marriage.Divorce, HomelandModule.OnDivorce)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_CHILD, HomelandModule.OnClickChild)
  Timer:RegisterIrregularTimeListener(self.OnUpdate, self)
  ModuleBase.Init(self)
  HomelandProtocol.Init()
  self:InitNPCServiceMap()
  HouseMgr.Instance():Init()
  CourtyardMgr.Instance():Init()
  require("Main.Homeland.HomelandGuideMgr").Instance():Init()
  require("Main.Homeland.homeVisitor.HomeVisitorMgr").Instance():Init()
end
def.method("table").LoadHome = function(self, resInfo)
  local resourcePath = resInfo.resourcePath
  local houseApperancePath = resInfo.houseApperancePath
  self:SetCameraOptions()
  HomelandTouchController:Load()
  gmodule.moduleMgr:GetModule(ModuleId.HERO).isInHomeland = true
  self.m_canEdit = self:IsInSelfHomeland()
  local terrain = self.terrainobj
  if terrain == nil or terrain.isnil or not string.find(terrain.name, resourcePath) then
    terrain = GameUtil.SyncLoad(resourcePath .. ".u3dext")
    if terrain then
      terrain.name = "HomelandTerrain_" .. resourcePath
    end
  end
  HomelandModule.OnLoadHomelandTerrain(terrain)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.ENTER_HOMELAND, nil)
  local mapId = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId()
  if houseApperancePath then
    GameUtil.AsyncLoad(houseApperancePath .. ".u3dext", HomelandModule.OnLoadHouseApperance)
  end
end
def.method("string").LoadLogicMap = function(self, mapPath)
  if mapPath and mapPath ~= "" then
    local logicMapPath = string.format("map/%s/logicdata.mld", mapPath)
    LogicMap.Instance():Load(logicMapPath)
  end
end
def.static("userdata").OnLoadHomelandTerrain = function(obj)
  local offsetX = instance.m_homeOffset and instance.m_homeOffset.x or 0
  local offsetY = instance.m_homeOffset and instance.m_homeOffset.y or 0
  local offSetZ = 2
  if obj and obj ~= instance.terrainobj then
    instance:DestroyTerrain()
    instance.terrainobj = Object.Instantiate(obj, "GameObject")
    instance.terrainobj.localPosition = EC.Vector3.new(offsetX, world_height - offsetY, offSetZ)
    instance.terrainobj.parent = instance.rootNode
  end
  instance.rootNode:SetActive(true)
  gmodule.moduleMgr:GetModule(ModuleId.MAP).mapNodeRoot:SetActive(false)
  instance:EndLoadingHomeland()
end
def.static("userdata").OnLoadHouseApperance = function(obj)
  if instance.terrainobj == nil or obj == nil then
    return
  end
  local terrainobj = instance.terrainobj
  local housePoint = terrainobj:FindDirect("HousePoint")
  if housePoint == nil then
    warn(string.format("OnLoadHouseApperance: can not find a HousePoint!!!"))
    return
  end
  local childCount = housePoint.childCount
  for i = 0, childCount - 1 do
    local childGO = housePoint:GetChild(i)
    GameObject.Destroy(childGO)
  end
  local houseobj = Object.Instantiate(obj, "GameObject")
  houseobj.parent = housePoint
  houseobj.localScale = EC.Vector3.one
  houseobj.localPosition = EC.Vector3.zero
end
def.method().SetCameraOptions = function()
  CommonCamera.game2DCamera.clearFlags = CameraClearFlags.SolidColor
end
def.method("number", "userdata", "function", "=>", "table").LoadFurniture = function(self, fid, uuid, onloaded)
  local furnitureCfg = ItemUtils.GetFurnitureCfg(fid)
  if furnitureCfg == nil then
    return nil
  end
  local resId = furnitureCfg.picId
  local path = HomelandUtils.GetResPath(resId)
  if path == nil or path == "" then
    warn(string.format("furniture(%d) resPath is empty for resId = %d", fid, resId))
    return nil
  end
  local furniture = Furniture.new(path .. ".lua")
  furniture.m_itemId = fid
  furniture.m_uuid = uuid
  furniture:SetLayer(furnitureCfg.layer)
  if self.furnitures == nil then
    self.furnitures = {}
  end
  self.furnitures[furniture.m_id] = furniture
  furniture:Load(onloaded)
  return furniture
end
def.method("number", "userdata").LoadAndStartEditFurniture = function(self, fid, uuid)
  if self.curEditId ~= 0 then
    Toast(textRes.Homeland[55])
    return
  end
  local furniture = self:LoadFurniture(fid, uuid, function(furniture)
    if furniture == nil then
      return
    end
    furniture:StartEdit()
  end)
  if furniture == nil then
    return
  end
  self.curEditId = furniture.m_id
end
def.method().LeaveHome = function(self)
  gmodule.moduleMgr:GetModule(ModuleId.MAP).mapNodeRoot:SetActive(true)
  self:ReleaseHomelandMapData()
  self:DestroyTerrain()
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOMELAND, nil)
end
def.method().ReleaseHomelandMapData = function(self)
  HomelandTouchController:Destroy()
  gmodule.moduleMgr:GetModule(ModuleId.HERO).isInHomeland = false
  self.m_canEdit = false
  self.curEditId = 0
  LogicMap.Instance():Destroy()
  if self.furnitures then
    for k, v in pairs(self.furnitures) do
      v:Destroy()
    end
    self.furnitures = nil
  end
end
def.method().DestroyTerrain = function(self)
  if self.terrainobj then
    self.terrainobj:Destroy()
    self.terrainobj = nil
  end
end
def.method("=>", "boolean").IsTerrainRetain = function(self)
  if self.terrainobj and self.terrainobj.isnil == false then
    return true
  end
  return false
end
def.static("table", "table").OnChangeMap = function(p1, p2)
  local mapid = p1[1]
  local oldMapId = p1[2]
  if not instance.m_isFirstMapChange then
    return
  end
  instance.m_isFirstMapChange = false
  HomelandModule.OnChangeMapInstance({lastMapId = 0, mapId = mapid}, nil)
end
def.static("table", "table").OnChangeMapInstance = function(p1, p2)
  local lastMapId = p1.lastMapId
  local mapid = p1.mapId
  local mapcfg = MapUtility.GetMapCfg(mapid)
  local mapPath = mapcfg and mapcfg.mapResPath
  if instance:IsHomelandMap(lastMapId) then
    if instance:IsHouseMap(lastMapId) then
      Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOUSE, nil)
    else
      Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_COURTYARD, nil)
    end
    instance:LeaveHome()
    instance.m_homelandInfo = nil
    instance.m_waitingHomelandInfo = nil
  end
  if instance:IsHomelandMap(mapid) then
    instance:StartLoadingHomeland()
    if not MapScene.GetLogicMapData and instance:IsHomelandMap(mapid) then
      instance:LoadLogicMap(mapPath or "")
    end
    instance.m_waitingHomelandInfo = {mapid = mapid}
    instance:EnterHome()
  else
    instance:DestroyTerrain()
  end
end
def.method().EnterHome = function(self)
  if self.m_homelandInfo == nil then
    return
  end
  self.m_waitingHomelandInfo = nil
  local resInfo = {}
  local isHouse
  local mapId = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId()
  if self:IsHouseMap(mapId) then
    local houseLevel = self.m_homelandInfo.houseLevel
    local houseCfg = HomelandUtils.GetHouseCfg(houseLevel)
    resInfo.resourcePath = HomelandUtils.GetResPath(houseCfg.resourceId)
    isHouse = true
    self.m_homeOffset = {
      x = houseCfg.offSetX,
      y = houseCfg.offSetY
    }
  else
    local houseLevel = self.m_homelandInfo.houseLevel
    local courtyardLevel = self.m_homelandInfo.courtyardLevel
    local courtyardCfg = HomelandUtils.GetCourtyardCfg(courtyardLevel)
    resInfo.resourcePath = HomelandUtils.GetResPath(courtyardCfg.resourceId)
    self.m_homeOffset = {
      x = courtyardCfg.offSetX,
      y = courtyardCfg.offSetY
    }
    resInfo.houseApperancePath = string.format("Arts/Courtyard/Houses/House%02d/House%02d.prefab", houseLevel, houseLevel)
  end
  instance:LoadHome(resInfo)
  if isHouse then
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.ENTER_HOUSE, nil)
  else
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.ENTER_COURTYARD, nil)
  end
end
def.method("number").OnUpdate = function(self, tick)
  if self.furnitures then
    for _, v in pairs(self.furnitures) do
      v:Update()
    end
    if self.curEditId ~= 0 and self.furnitures[self.curEditId] == nil then
      self.curEditId = 0
    end
  end
end
def.static("table", "table").OnStartEdit = function(p1, p2)
  local fid = p1[1]
  instance.curEditId = fid
  require("Main.MainUI.ui.MainUIPanel").Instance():ExpandAll(false)
end
def.static("table", "table").OnEndEdit = function(p1, p2)
  local fid = p1[1]
  instance:LayDown(fid)
end
def.static("table", "table").OnCancelEdit = function(p1, p2)
  local fid = p1[1]
  local curFurniture = instance.furnitures[fid]
  if curFurniture == nil then
    return
  end
  local uuid = curFurniture:GetUUID()
  if instance:HasFuriturePlaced(uuid) then
    if instance:IsMyDisplayFurniture(uuid) then
      HomelandProtocol.CUnDisplayFurnitureReq(uuid, nil)
    else
      local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
      local mateName = mateInfo and mateInfo.mateName or "$unknow"
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      local desc = textRes.Homeland[91]:format(mateName)
      CommonConfirmDlg.ShowConfirm("", desc, function(s)
        if s == 1 then
          HomelandProtocol.CUnDisplayFurnitureReq(uuid, nil)
        elseif s == 0 then
          local laydownpos = curFurniture:GetLayDownPos()
          if laydownpos then
            local cfgid = curFurniture:GetCfgID()
            local dir = curFurniture:GetLayDownDir()
            instance:PlaceFurniture(cfgid, uuid, laydownpos, dir, nil)
          end
        end
      end, nil)
    end
  else
    curFurniture:Destroy()
    instance.furnitures[fid] = nil
  end
end
def.static("table", "table").OnOpposite = function(p1, p2)
  local fid = p1[1]
  local curFurniture = instance.furnitures[fid]
  if curFurniture == nil then
    return
  end
  curFurniture:Opposite()
end
def.static("table", "table").OnExploreCatEnterView = function(p1, p2)
  if not instance.m_bGotoExplorerCat then
    return
  end
  instance.m_bGotoExplorerCat = false
  local entitiy = p1[1]
  if entitiy.ownerId == GetMyRoleID() then
    local npcmodel = entitiy.m_ecmodel
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      npcmodel.m_cfgId,
      {npc = npcmodel}
    })
  end
end
local Furniture_temp_pos = EC.Vector3.new(0, 0, 0)
def.method("number", "number", "=>", "boolean").OnTouchMove = function(self, x, y)
  if self.furnitures == nil then
    return false
  end
  if not self.m_canEdit then
    return false
  end
  if self.curEditId == 0 and HomelandTouchController:IsLongTouching() then
    local cell_x = math.floor(x / LogicMap.Instance().cellWidth)
    local cell_y = math.floor((world_height - y) / LogicMap.Instance().cellHeight)
    local maxRenderQueue = 0
    for k, v in pairs(self.furnitures) do
      if v.m_model then
        local f_x = math.floor(v.m_model.localPosition.x / LogicMap.Instance().cellWidth)
        local f_y = math.floor((world_height - v.m_model.localPosition.y) / LogicMap.Instance().cellHeight)
        local dir_data = v:GetCurDirData()
        local start_x = f_x + math.floor(dir_data.CellOffset[1] / 16)
        local start_y = f_y - math.floor(dir_data.CellOffset[2] / 16)
        if cell_x >= start_x and cell_x < start_x + dir_data.CellWidth and cell_y >= start_y and cell_y < start_y + dir_data.CellHeight then
          for j = 0, dir_data.CellHeight - 1 do
            for i = 1, dir_data.CellWidth do
              if 0 < dir_data.Cells[j * dir_data.CellWidth + i] and start_y + j == cell_y and start_x + i == cell_x then
                local renderQueue = v:GetRenderQueue()
                if maxRenderQueue < renderQueue then
                  self.curEditId = k
                  maxRenderQueue = renderQueue
                end
              end
            end
          end
        end
      end
    end
    if self.curEditId ~= 0 then
      self:TakeUp(self.curEditId)
    end
  end
  local curFurniture = self.furnitures[self.curEditId]
  if curFurniture and curFurniture:IsEditable() and curFurniture.m_model then
    local cell_x = math.floor(x / LogicMap.Instance().cellWidth)
    local cell_y = math.floor((world_height - y) / LogicMap.Instance().cellHeight)
    local dir_data = curFurniture:GetCurDirData()
    local start_x = cell_x + math.floor(dir_data.CellOffset[1] / 16)
    local start_y = cell_y - math.floor(dir_data.CellOffset[2] / 16)
    if LogicMap.Instance():CheckBlockInBound(start_x, start_y, dir_data.CellWidth, dir_data.CellHeight) then
      curFurniture:SetPos(x, world_height - y)
    end
    return true
  end
  return false
end
def.method("number", "number").OnDragStart = function(self, x, y)
  if self.furnitures == nil then
    return
  end
  if not self.m_canEdit then
    return
  end
  local cell_x = math.floor(x / LogicMap.Instance().cellWidth)
  local cell_y = math.floor((world_height - y) / LogicMap.Instance().cellHeight)
  local editId = 0
  local maxRenderQueue = 0
  for k, v in pairs(self.furnitures) do
    if v.m_model then
      local f_x = math.floor(v.m_model.localPosition.x / LogicMap.Instance().cellWidth)
      local f_y = math.floor((world_height - v.m_model.localPosition.y) / LogicMap.Instance().cellHeight)
      local dir_data = v:GetCurDirData()
      local start_x = f_x + math.floor(dir_data.CellOffset[1] / 16)
      local start_y = f_y - math.floor(dir_data.CellOffset[2] / 16)
      if cell_x >= start_x and cell_x < start_x + dir_data.CellWidth and cell_y >= start_y and cell_y < start_y + dir_data.CellHeight then
        for j = 0, dir_data.CellHeight - 1 do
          for i = 1, dir_data.CellWidth do
            if 0 < dir_data.Cells[j * dir_data.CellWidth + i] and start_y + j == cell_y and start_x + i == cell_x and v:IsEditable() then
              local renderQueue = v:GetRenderQueue()
              if maxRenderQueue < renderQueue then
                editId = k
                maxRenderQueue = renderQueue
              end
            end
          end
        end
      end
    end
  end
  if self.curEditId == 0 then
    self.curEditId = editId
  end
end
def.method("number", "number").OnDragEnd = function(self, x, y)
  if not self.m_canEdit then
    return
  end
end
def.method("number").LayDown = function(self, fid)
  local curFurniture = self.furnitures[fid]
  if curFurniture == nil then
    return
  end
  local cell_x = math.floor(curFurniture.m_model.localPosition.x / LogicMap.Instance().cellWidth)
  local cell_y = math.floor((world_height - curFurniture.m_model.localPosition.y) / LogicMap.Instance().cellHeight)
  local dir_data = curFurniture:GetCurDirData()
  local start_x = cell_x + math.floor(dir_data.CellOffset[1] / 16)
  local start_y = cell_y - math.floor(dir_data.CellOffset[2] / 16)
  if LogicMap.Instance():CheckBlockData(start_x, start_y, dir_data.CellWidth, dir_data.CellHeight, dir_data.Cells) == false then
    Toast(textRes.Homeland[49])
    curFurniture:SetInvalid(true)
    return
  end
  local x = curFurniture.m_model.localPosition.x
  local y = world_height - curFurniture.m_model.localPosition.y
  local dir = curFurniture:GetDir()
  local itemId = curFurniture.m_itemId
  local uuid = curFurniture.m_uuid
  if self:HasFuriturePlaced(uuid) then
    HomelandProtocol.CMoveFurnitureReq({
      x = x,
      y = y,
      dir = dir,
      itemId = itemId,
      uuid = uuid
    }, nil)
  else
    local FurnitureBag = require("Main.Homeland.FurnitureBag")
    local nums = FurnitureBag.Instance():GetFurnitureNumbersById(itemId)
    if nums == 0 then
      Toast(textRes.Homeland[45])
      local ItemAccessMgr = require("Main.Item.ItemAccessMgr")
      local tip = ItemAccessMgr.Instance():ShowSource(itemId, 207, 153, 0, 0, 0)
      return
    end
    local furnitures = FurnitureBag.Instance():GetFurnituresById(itemId)
    local _, furniture = next(furnitures)
    uuid = furniture.uuid
    curFurniture.m_uuid = uuid
    HomelandProtocol.CDisplayFurnitureReq({
      x = x,
      y = y,
      dir = dir,
      itemId = itemId,
      uuid = uuid
    }, nil)
  end
end
def.method("number").TakeUp = function(self, fid)
  local curFurniture = self.furnitures[fid]
  if curFurniture then
    self:RemoveFurniture(fid)
    curFurniture:StartEdit()
    self.curEditId = fid
  end
end
def.method("number", "=>", "table").RemoveFurniture = function(self, fid)
  local curFurniture = self.furnitures[fid]
  if curFurniture == nil then
    return nil
  end
  if curFurniture.m_model and curFurniture.m_model.isnil == false then
    local cell_x = math.floor(curFurniture.m_model.localPosition.x / LogicMap.Instance().cellWidth)
    local cell_y = math.floor((world_height - curFurniture.m_model.localPosition.y) / LogicMap.Instance().cellHeight)
    local dir_data = curFurniture:GetCurDirData()
    local start_x = cell_x + math.floor(dir_data.CellOffset[1] / 16)
    local start_y = cell_y - math.floor(dir_data.CellOffset[2] / 16)
    LogicMap.Instance():ClearBlockData(start_x, start_y, dir_data.CellWidth, dir_data.CellHeight, dir_data.Cells)
  end
  return curFurniture
end
def.method("number").DestroyFurniture = function(self, fid)
  if self.furnitures == nil then
    return
  end
  local furniture = self:RemoveFurniture(fid)
  self.furnitures[fid] = nil
  if furniture then
    furniture:Destroy()
  end
end
def.method("number", "userdata", "table", "number", "table").PlaceFurniture = function(self, furnitureId, uuid, pos, dir, context)
  local curFurniture = self:FindFurnitureByUUID(uuid)
  if curFurniture == nil then
    curFurniture = self:LoadFurniture(furnitureId, uuid, nil)
  elseif not curFurniture:IsEditable() then
    self:RemoveFurniture(curFurniture.m_id)
  end
  if curFurniture == nil then
    return
  end
  curFurniture:SetDir(dir)
  curFurniture:SetPos(pos.x, pos.y)
  curFurniture:EndEdit()
  local cell_x = math.floor(pos.x / LogicMap.Instance().cellWidth)
  local cell_y = math.floor(pos.y / LogicMap.Instance().cellHeight)
  local dir_data = curFurniture:GetCurDirData()
  local start_x = cell_x + math.floor(dir_data.CellOffset[1] / LogicMap.Instance().cellWidth)
  local start_y = cell_y - math.floor(dir_data.CellOffset[2] / LogicMap.Instance().cellHeight)
  if LogicMap.Instance():CheckMapMask(start_x, start_y, dir_data.CellWidth, dir_data.CellHeight, dir_data.Cells) then
    curFurniture:SetTransparent(true)
  else
    curFurniture:SetTransparent(false)
  end
  LogicMap.Instance():SetBlockData(start_x, start_y, dir_data.CellWidth, dir_data.CellHeight, dir_data.Cells)
  if curFurniture.m_id == self.curEditId then
    self.curEditId = 0
  end
end
def.method("userdata", "=>", "table").FindFurnitureByUUID = function(self, uuid)
  if self.furnitures == nil then
    return nil
  end
  local furniture
  for fid, v in pairs(self.furnitures) do
    if v.m_uuid == uuid then
      furniture = v
      break
    end
  end
  return furniture
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  local isOpen = feature:CheckFeatureOpen(Feature.TYPE_HOME)
  return isOpen
end
def.method("=>", "boolean").IsLevelUnlock = function(self)
  local heroLevel = require("Main.Hero.Interface").GetBasicHeroProp().level
  return heroLevel >= constant.CHomelandCfgConsts.MIN_ROLE_LEVEL
end
def.method("=>", "boolean").IsFunctionOpen = function(self)
  return self:IsFeatureOpen() and self:IsLevelUnlock()
end
def.method("=>", "boolean").HaveHome = function(self)
  return self.m_haveHome
end
def.method("=>", "boolean").IsInEditMode = function(self)
  return self.curEditId ~= 0
end
def.method("=>", "boolean").ReturnHome = function(self)
  if self:CheckAllowEnterStatus() == false then
    return false
  end
  HomelandProtocol.CReturnHomeReq()
  return true
end
def.method("number", "number", "=>", "boolean").GotoHomelandNPC = function(self, mapId, npcId)
  local HomelandNPCNavigator = require("Main.Homeland.helper.HomelandNPCNavigator")
  return HomelandNPCNavigator.Instance():GotoHomelandNPC(mapId, npcId)
end
def.method().ReturnHomeWithVerify = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if not self:HaveHome() then
    local text = string.format(textRes.Homeland[48], constant.CHomelandCfgConsts.MIN_ROLE_LEVEL)
    Toast(text)
    self:GotoCreateHomelandNPC()
  else
    self:ReturnHome()
  end
end
def.method("=>", "boolean").CheckAllowEnterStatus = function(self)
  local TeamData = require("Main.Team.TeamData")
  local teamData = TeamData.Instance()
  if gmodule.moduleMgr:GetModule(ModuleId.DUNGEON):IsInDungeon() then
    Toast(textRes.Homeland[80])
    return false
  end
  local isNotTmpLeave = teamData:GetStatus() ~= require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE
  if teamData:HasTeam() and not teamData:MeIsCaptain() and isNotTmpLeave then
    Toast(textRes.Homeland[77])
    return false
  end
  if _G.IsWatchingMoon() then
    Toast(textRes.Homeland[81])
    return false
  end
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  if pubMgr:IsInFollowState(heroModule:GetMyRoleId()) == true then
    Toast(textRes.Homeland[77])
    return false
  end
  if pubMgr:IsInWedding() then
    Toast(textRes.Homeland[78])
    return false
  end
  if pubMgr:IsInWeddingParade() then
    Toast(textRes.Homeland[78])
    return false
  end
  local myRole = heroModule.myRole
  if myRole and (myRole:IsInState(RoleState.UNTRANPORTABLE) or myRole:IsInState(RoleState.BATTLE) or myRole:IsInState(RoleState.HUG)) then
    Toast(textRes.Homeland[76])
    return false
  end
  heroModule:StopPatroling()
  return true
end
def.method().GoToMyExplorerCat = function(self)
  self.m_bGotoExplorerCat = true
  self:ReturnHomeWithVerify()
end
def.method("userdata").VisitHome = function(self, roleid)
  if self:CheckAllowEnterStatus() == false then
    return
  end
  HomelandProtocol.CVisitHomeReq(roleid)
end
def.method().GotoCreateHomelandNPC = function(self)
  local npcId = constant.CHomelandCfgConsts.CREATE_HOMELAND_NPC
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_NPC, {npcId})
end
def.method("number", "=>", "boolean").IsHomelandMap = function(self, mapId)
  if self:IsHouseMap(mapId) then
    return true
  end
  if self:IsCourtyardMap(mapId) then
    return true
  end
  return false
end
def.method("number", "=>", "boolean").IsHouseMap = function(self, mapId)
  return self:GetHouseCfgByMapId(mapId) ~= nil
end
def.method("number", "=>", "table").GetHouseCfgByMapId = function(self, mapId)
  if self.m_houseMapCfgs == nil then
    self:InitHouseMapCfgs()
  end
  return self.m_houseMapCfgs[mapId]
end
def.method("number", "=>", "boolean").IsCourtyardMap = function(self, mapId)
  return self:GetCourtyardCfgByMapId(mapId) ~= nil
end
def.method("number", "=>", "table").GetCourtyardCfgByMapId = function(self, mapId)
  if self.m_courtyardMapCfgs == nil then
    self:InitCourtyardMapCfgs()
  end
  return self.m_courtyardMapCfgs[mapId]
end
def.method("=>", "boolean").IsInHouseMap = function(self)
  local mapId = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId()
  return self:IsHouseMap(mapId)
end
def.method("=>", "boolean").IsInCourtyardMap = function(self)
  local mapId = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId()
  return self:IsCourtyardMap(mapId)
end
def.method("=>", "number").GetCurHomelandArea = function(self)
  if self:IsInHouseMap() then
    return HomelandModule.Area.House
  elseif self:IsInCourtyardMap() then
    return HomelandModule.Area.Courtyard
  else
    return HomelandModule.Area.NotHomeland
  end
end
def.method("userdata", "=>", "boolean").HasFuriturePlaced = function(self, uuid)
  return gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntity(MapEntityType.MET_FURNITURE, uuid) ~= nil
end
def.method("table").SetCurHomelandInfo = function(self, homelandInfo)
  self.m_homelandInfo = homelandInfo
end
def.method("=>", "table").GetCurHomelandInfo = function(self)
  return self.m_homelandInfo
end
def.method("=>", "boolean").IsInSelfHomeland = function(self)
  local homelandInfo = self.m_homelandInfo
  if homelandInfo == nil then
    return false
  end
  local myRoleId = _G.GetMyRoleID()
  if homelandInfo.createrInfo and homelandInfo.createrInfo.id == myRoleId then
    return true
  end
  if homelandInfo.partnerInfo and homelandInfo.partnerInfo.id == myRoleId then
    return true
  end
  return false
end
def.method("=>", "boolean").IsInSelfCourtyard = function(self)
  if not self:IsInSelfHomeland() then
    return false
  end
  return self:IsInCourtyardMap()
end
def.method("=>", "boolean").IsInSelfHouse = function(self)
  if not self:IsInSelfHomeland() then
    return false
  end
  return self:IsInHouseMap()
end
def.method("=>", "boolean").IsCurHomelandCreater = function(self)
  local homelandInfo = self.m_homelandInfo
  if homelandInfo == nil then
    return false
  end
  local myRoleId = _G.GetMyRoleID()
  if homelandInfo.createrInfo and homelandInfo.createrInfo.id == myRoleId then
    return true
  end
  return false
end
def.method("=>", "boolean").IsThereABedInMyHouse = function(self)
  if not self:IsInSelfHomeland() then
    print("Not in self homeland! return false")
    return false
  end
  if not self:IsInHouseMap() then
    print("Not in house! return false")
    return false
  end
  local entites = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntitiesByType(MapEntityType.MET_FURNITURE)
  if entites == nil then
    return false
  end
  local FurnitureTypeEnum = require("consts.mzm.gsp.item.confbean.FurnitureTypeEnum")
  for k, v in pairs(entites) do
    local furnitureId = v.cfgid
    local furnitureCfg = ItemUtils.GetFurnitureCfg(furnitureId)
    if furnitureCfg and furnitureCfg.furnitureType == FurnitureTypeEnum.BED then
      return true
    end
  end
  return false
end
def.method("number", "=>", "boolean").CheckAuthority = function(self, visitType)
  return self:CheckAuthorityEx(visitType, {silence = false})
end
def.method("number", "table", "=>", "boolean").CheckAuthorityEx = function(self, visitType, params)
  local _Toast = Toast
  local function Toast(...)
    local params = params or {}
    if not params.silence then
      _Toast(...)
    end
  end
  if visitType == HomelandModule.VisitType.Owner then
    if not self:IsCurHomelandCreater() then
      Toast(textRes.Homeland[41])
      return false
    end
  elseif visitType == HomelandModule.VisitType.ShareOwner and not self:IsInSelfHomeland() then
    Toast(textRes.Homeland[46])
    return false
  end
  return true
end
def.method().InitHouseMapCfgs = function(self)
  local cfgs = HomelandUtils.GetAllHouseCfgs()
  self.m_houseMapCfgs = {}
  for i, v in ipairs(cfgs) do
    if self.m_houseMapCfgs[v.mapId] == nil then
      self.m_houseMapCfgs[v.mapId] = v
    end
  end
end
def.method().InitCourtyardMapCfgs = function(self)
  local cfgs = HomelandUtils.GetAllCourtyardCfgs()
  self.m_courtyardMapCfgs = {}
  for i, v in ipairs(cfgs) do
    if self.m_courtyardMapCfgs[v.mapId] == nil then
      self.m_courtyardMapCfgs[v.mapId] = v
    end
  end
end
def.method().InitNPCServiceMap = function(self)
  self.m_serviceMap = {
    [NPCServiceConst.BuildHomeService] = HouseMgr.BuildHomeService,
    [NPCServiceConst.CleanHouseService] = HouseMgr.CleanHouseService,
    [NPCServiceConst.HouseManagerService] = HouseMgr.HouseManagerService,
    [NPCServiceConst.HouseUpgradeService] = HouseMgr.HouseUpgradeService,
    [NPCServiceConst.ReturnHome] = HouseMgr.ReturnHomeService,
    [NPCServiceConst.RenameServant] = HouseMgr.RenameServantService,
    [NPCServiceConst.ViewHouseState] = HouseMgr.ViewHouseStateService,
    [NPCServiceConst.BuyFurniture] = HomelandModule.BuyFurnitureService,
    [NPCServiceConst.ServantComeToMe] = HomelandModule.ServantComeToMeService
  }
  local npcInterface = require("Main.npc.NPCInterface").Instance()
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.BuildHomeService, HomelandModule.CanDisplayBuildHomeService)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.CleanHouseService, HomelandModule.CanDisplayShareOwnerService)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.HouseManagerService, HomelandModule.CanDisplayShareOwnerService)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.HouseUpgradeService, HomelandModule.CanDisplayOwnerService)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.ReturnHome, HomelandModule.CanDisplayReturnHomeService)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.RenameServant, HomelandModule.CanDisplayShareOwnerService)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.ViewHouseState, HomelandModule.CanDisplayShareOwnerService)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.HomelandDesc, HomelandModule.CanDisplayPublicService)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.BuyFurniture, HomelandModule.CanDisplayShareOwnerService)
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.ServantComeToMe, HomelandModule.CanDisplayShareOwnerService)
end
local _loadingHomeland = false
local _loadingTimeoutTimer = 0
def.method().StartLoadingHomeland = function(self)
  if instance.terrainobj and not instance.terrainobj.isnil then
    return
  end
  local prefab = GameUtil.SyncLoad(RESPATH.PREFAB_LODING_PANEL_RES)
  local LoadingMgr = require("Main.Common.LoadingMgr")
  if LoadingMgr.Instance().loadingType == 0 then
    LoadingMgr.Instance():StartLoading(LoadingMgr.LoadingType.Other, {
      [1] = 1
    }, nil, nil)
    _loadingHomeland = true
    _loadingTimeoutTimer = GameUtil.AddGlobalTimer(10, true, function(...)
      if _loadingHomeland then
        self:AbortLoadingHomeland()
      end
    end)
  end
end
def.method().EndLoadingHomeland = function(self)
  local LoadingMgr = require("Main.Common.LoadingMgr")
  if LoadingMgr.Instance().loadingType == LoadingMgr.LoadingType.Other then
    LoadingMgr.Instance():UpdateTaskProgress(1, 1)
  end
  if _loadingTimeoutTimer ~= 0 then
    GameUtil.RemoveGlobalTimer(_loadingTimeoutTimer)
    _loadingTimeoutTimer = 0
  end
  _loadingHomeland = false
  instance.rootNode:SetActive(true)
end
def.method().AbortLoadingHomeland = function(self)
  self:EndLoadingHomeland()
  self:ForceLeaveHomeland()
  local title = textRes.Homeland[82]
  local promoteText = textRes.Homeland[83]
  require("GUI.CommonConfirmDlg").ShowCerternConfirm(title, promoteText, "", function()
  end, nil)
end
def.method().ForceLeaveHomeland = function(self)
  local mapId = 330000001
  gmodule.moduleMgr:GetModule(ModuleId.MAP):TransportToMap(mapId)
end
def.method("userdata", "table").AddMyDisplayFurniture = function(self, uuid, furnitureInfo)
  self.myDisplayFurniture = self.myDisplayFurniture or {}
  self.myDisplayFurniture[tostring(uuid)] = furnitureInfo
end
def.method("userdata").RemoveMyDisplayFurniture = function(self, uuid)
  if self.myDisplayFurniture == nil then
    return
  end
  self.myDisplayFurniture[tostring(uuid)] = nil
end
def.method("userdata", "=>", "boolean").IsMyDisplayFurniture = function(self, uuid)
  if self.myDisplayFurniture == nil then
    return
  end
  return self.myDisplayFurniture[tostring(uuid)] ~= nil
end
def.method("table").SetWallpaper = function(self, resInfo)
  if self.terrainobj == nil then
    return
  end
  local Grid = self.terrainobj:FindDirect("Grid")
  if Grid == nil then
    return
  end
  local meshRenderer = Grid:GetComponentInChildren("MeshRenderer")
  if meshRenderer == nil then
    warn(string.format("SetWallpaper failed because of no MeshRender find!"))
    return
  end
  GameUtil.AsyncLoad(resInfo.materialPath .. ".u3dext", function(asset)
    if asset == nil then
      return
    end
    if Grid.isnil then
      return
    end
    local meshRenderers = Grid:GetRenderersInChildren()
    for i, v in ipairs(meshRenderers) do
      v.sharedMaterial = asset
    end
  end)
end
def.method("table").SetFloorTitle = function(self, resInfo)
  if self.terrainobj == nil then
    return
  end
  local Floor = self.terrainobj:FindDirect("Floor")
  if Floor == nil then
    warn(string.format("SetFloorTitle failed because of no Floor GameObject find!"))
    return
  end
  local FloorSide = self.terrainobj:FindDirect("FloorSide")
  if FloorSide == nil then
    warn(string.format("SetFloorTitle failed because of no FloorSide GameObject find!"))
    return
  end
  AsyncLoadArray({
    resInfo.groundPath .. ".u3dext",
    resInfo.sidePath .. ".u3dext"
  }, function(assets)
    if assets[1] == nil or assets[2] == nil then
      return
    end
    if Floor.isnil then
      return
    end
    local GUIUtils = require("GUI.GUIUtils")
    local floorRenderer = Floor:GetComponent("MeshRenderer")
    floorRenderer.material.mainTexture = GUIUtils.ConvertTexture2DAssets(assets[1])
    local floorSideRenderer = FloorSide:GetComponent("MeshRenderer")
    floorSideRenderer.material.mainTexture = GUIUtils.ConvertTexture2DAssets(assets[2])
  end)
end
def.method("table").SetCourtyardFence = function(self, resInfo)
  if self.terrainobj == nil then
    return
  end
  local Wall01 = self.terrainobj:FindDirect("Wall01")
  if Wall01 == nil then
    warn(string.format("SetCourtyardFence failed because of no Wall01 GameObject find!"))
    return
  end
  local Wall02 = self.terrainobj:FindDirect("Wall02")
  if Wall02 == nil then
    warn(string.format("SetCourtyardFence failed because of no Wall02 GameObject find!"))
    return
  end
  GameUtil.AsyncLoad(resInfo.materialPath .. ".u3dext", function(asset)
    if asset == nil then
      return
    end
    if Wall01.isnil then
      return
    end
    local meshRenderers = {}
    table.insert(meshRenderers, Wall01:GetComponent("MeshRenderer"))
    table.insert(meshRenderers, Wall02:GetComponent("MeshRenderer"))
    for i, v in ipairs(meshRenderers) do
      v.sharedMaterial = asset
      warn("@Fence seted")
    end
  end)
end
def.method("table").SetCourtyardGround = function(self, resInfo)
  if self.terrainobj == nil then
    return
  end
  local Ground = self.terrainobj:FindDirect("Ground")
  if Ground == nil then
    warn(string.format("SetCourtyardGround failed because of no Ground GameObject find!"))
    return
  end
  local Ground_Sp = self.terrainobj:FindDirect("Ground_Sp")
  if Ground_Sp == nil then
    warn(string.format("SetCourtyardGround failed because of no Ground_Sp GameObject find!"))
    return
  end
  AsyncLoadArray({
    resInfo.groundPath .. ".u3dext",
    resInfo.groundDecoPath .. ".u3dext"
  }, function(assets)
    if assets[1] == nil or assets[2] == nil then
      return
    end
    if Ground.isnil then
      return
    end
    local GUIUtils = require("GUI.GUIUtils")
    local groundRenderer = Ground:GetComponent("MeshRenderer")
    groundRenderer.sharedMaterial = assets[1]
    local groundSpRenderer = Ground_Sp:GetComponent("MeshRenderer")
    groundSpRenderer.sharedMaterial = assets[2]
    warn("@Ground seted")
  end)
end
def.method("table").SetCourtyardRoad = function(self, resInfo)
  if self.terrainobj == nil then
    return
  end
  local Road = self.terrainobj:FindDirect("Road")
  if Road == nil then
    warn(string.format("SetCourtyardRoad failed because of no Road GameObject find!"))
    return
  end
  GameUtil.AsyncLoad(resInfo.materialPath .. ".u3dext", function(asset)
    if asset == nil then
      return
    end
    if Road.isnil then
      return
    end
    local meshRenderers = {}
    table.insert(meshRenderers, Road:GetComponent("MeshRenderer"))
    for i, v in ipairs(meshRenderers) do
      warn("@Road seted")
      v.sharedMaterial = asset
    end
  end)
end
def.method("userdata").ServantComeToMe = function(self, instanceid)
  local heroPos = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetPos()
  if heroPos == nil then
    print(string.format("ServantComeToMe: hero pos is nil"))
    return
  end
  local entites = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntitiesByType(MapEntityType.MGT_SERVANT)
  if entites == nil then
    print(string.format("ServantComeToMe: servant(%s) not in view", tostring(instanceid)))
    return
  end
  local _, servant = next(entites)
  if servant == nil then
    print(string.format("ServantComeToMe: servant(%s) not in view", tostring(instanceid)))
    return
  end
  local findpath = servant:FindPath(heroPos.x, heroPos.y, 0)
  if findpath == nil or #findpath == 0 then
    print("no path found for servant")
    return
  end
  HomelandProtocol.CMoveServantReq(findpath)
end
def.method("=>", "table").GetMyHouse = function(self)
  return HouseMgr.Instance():GetMyHouse()
end
def.method("=>", "table").GetMyCourtyard = function(self)
  return CourtyardMgr.Instance():GetMyCourtyard()
end
def.static("number", "=>", "boolean").CanDisplayOwnerService = function(serviceID)
  if not instance:IsFeatureOpen() then
    return false
  end
  return instance:CheckAuthorityEx(HomelandModule.VisitType.Owner, {silence = true})
end
def.static("number", "=>", "boolean").CanDisplayShareOwnerService = function(serviceID)
  if not instance:IsFeatureOpen() then
    return false
  end
  return instance:CheckAuthorityEx(HomelandModule.VisitType.ShareOwner, {silence = true})
end
def.static("number", "=>", "boolean").CanDisplayBuildHomeService = function(serviceID)
  if not instance:IsFeatureOpen() then
    return false
  end
  if not instance:IsLevelUnlock() then
    return false
  end
  return not instance:HaveHome()
end
def.static("number", "=>", "boolean").CanDisplayReturnHomeService = function(serviceID)
  if not instance:IsFeatureOpen() then
    return false
  end
  return instance:HaveHome()
end
def.static("number", "=>", "boolean").CanDisplayPublicService = function(serviceID)
  if not instance:IsFeatureOpen() then
    return false
  end
  return true
end
def.static("number").BuyFurnitureService = function(npcID)
  require("Main.Homeland.ui.FurnitureShopPanel").ShowPanel()
end
def.static("number").ServantComeToMeService = function(npcID)
  instance:ServantComeToMe(nil)
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  instance:ReleaseHomelandMapData()
  instance.m_haveHome = false
  instance.m_playerIsOwner = false
  instance.m_houseMapCfgs = nil
  instance.m_canEdit = false
  instance.m_homelandInfo = nil
  instance.m_bGotoExplorerCat = false
  instance.myDisplayFurniture = nil
  instance.m_isFirstMapChange = true
  require("Main.Homeland.FurnitureBag").Instance():Clear()
  instance:EndLoadingHomeland()
end
def.static("table", "table").OnAcceptNPCService = function(params)
  local serviceID = params[1]
  local npcID = params[2]
  local serviceFunc = instance.m_serviceMap[serviceID]
  if serviceFunc then
    if _G.CheckCrossServerAndToast() then
      return
    end
    serviceFunc(npcID)
  end
end
def.static("table", "table").OnFeatureOpenChange = function(params)
  if params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_HOME then
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.FunctionOpenChange, nil)
  end
end
def.static("table", "table").OnMainUIReturnHomeBtnClick = function(params)
  if _G.IsCrossingServer() then
    Toast(textRes.Homeland[88])
    require("Main.Children.ChildrenInterface").OpenChildrenBag(nil)
    return
  end
  if not instance:HaveHome() then
    local text = string.format(textRes.Homeland[48], constant.CHomelandCfgConsts.MIN_ROLE_LEVEL)
    Toast(text)
    instance:GotoCreateHomelandNPC()
  else
    require("Main.Homeland.ui.BackToHomePanel").ShowPanel()
  end
end
def.static("table", "table").OnEnterFight = function(params)
  HomelandTouchController:SetActive(false)
  if instance:IsTerrainRetain() then
    instance.rootNode:SetActive(false)
  end
end
def.static("table", "table").OnLeaveFight = function(params)
  HomelandTouchController:SetActive(true)
  if instance:IsTerrainRetain() then
    instance.rootNode:SetActive(true)
    gmodule.moduleMgr:GetModule(ModuleId.MAP).mapNodeRoot:SetActive(false)
  end
end
def.static("table", "table").OnDivorce = function(params)
  if not gmodule.moduleMgr:GetModule(ModuleId.HERO).isInHomeland then
    return
  end
  if instance:IsCurHomelandCreater() then
    return
  end
  if instance:IsInSelfHomeland() then
    instance.m_homelandInfo.partnerInfo = nil
    Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LoseHomelandControl, nil)
  end
end
def.static("table", "table").OnClickChild = function(params)
  if not gmodule.moduleMgr:GetModule(ModuleId.HERO).isInHomeland then
    return
  end
  if not instance:IsInSelfHomeland() then
    local entity = params[2] and params[2].entity
    if entity then
      require("Main.Children.ChildrenInterface").RequestChildInfo(params[1])
    end
  else
    local entity = params[2] and params[2].entity
    print("OnClickChild", tostring(params[1]), entity)
    if entity then
      entity:ShowInteractiveUI()
    end
  end
end
HomelandModule.Commit()
return HomelandModule
