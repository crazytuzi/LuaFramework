local Lplus = require("Lplus")
local ECTerrainTile = Lplus.Class("ECTerrainTile")
local def = ECTerrainTile.define
local EC = require("Types.Vector")
def.field("userdata").mSpiteObj = nil
def.field("number").mWidth = 0
def.field("number").mHeight = 0
def.field("table").pos = nil
def.field("number").mZpass = 100
def.field("boolean").mToRelease = false
def.field("userdata").mTex2d = nil
local TerrainTileInst, MapNodeRoot, SpriteCacheRoot
def.final("=>", ECTerrainTile).new = function()
  local obj = ECTerrainTile()
  return obj
end
local _name_index = 0
_G.terrain_tile_loaded_per_frame = 0
_G.terrain_tile_to_load_per_frame = 0
_G.terrain_tile_max_per_frame = 1
local t_pos = EC.Vector3.new()
def.method("string", "=>", "boolean").Load2 = function(self, resname)
  print("resName = " .. resname)
  local res = GameUtil.SyncLoadPrefab(resname, true)
  if not res then
    error("ECSprite Load")
    return false
  end
  local tex2d = res
  if getmetatable(res).name ~= "Texture2D" then
    local data = res.bytes
    if not data then
      error("res.bytes is nil")
      return
    end
    tex2d = Texture2D.Texture2D(256, 256, TextureFormat.RGB24, false)
    local ret = tex2d:LoadImage(res.bytes)
    if not ret then
      error("LoadImage failed")
      return
    end
    res = tex2d
    tex2d.wrapMode = TextureWrapMode.Clamp
    tex2d.filterMode = 1
  end
  local w = res.width
  local h = res.height
  self.mWidth = w
  self.mHeight = h
  warn("w,h =", w, h)
  if not TerrainTileInst then
    TerrainTileInst = GameUtil.SyncLoadPrefab("Arts/Res/mapPlane.prefab")
  end
  if not TerrainTileInst then
    error("ECTerrainTile Load inst")
    return
  end
  local spr = Object.Instantiate(TerrainTileInst, "GameObject")
  spr.name = "TerrainTile" .. tostring(_name_index)
  _name_index = _name_index + 1
  spr:GetComponent("MeshRenderer").material.mainTexture = tex2d
  self.mTex2d = tex2d
  self.mSpiteObj = spr
  self.mSpiteObj.parent = gmodule.moduleMgr:GetModule(ModuleId.MAP).mapNodeRoot
  self.mSpiteObj.localRotation = Quaternion.Euler(EC.Vector3.new(0, 0, 0))
  self.mSpiteObj.localScale = EC.Vector3.new(w / 256, h / 256, 1)
  if self.pos ~= nil then
    self.mSpiteObj.localPosition = t_pos:Assign(self.pos.x, world_height - self.pos.y - self.mHeight, self.mZpass)
  end
  return self.mSpiteObj ~= nil
end
local texcache = {}
local function load_tex_from_stream(obj)
  if not obj then
    error("res is nil")
    return nil
  end
  local tex2d
  if #texcache > 0 then
    tex2d = texcache[#texcache]
    texcache[#texcache] = nil
  else
    tex2d = Texture2D.Texture2D(0, 0, TextureFormat.RGB24, false)
  end
  local ret = GameUtil.LoadImageFromStream(tex2d, obj)
  if not ret then
    error("LoadImage failed")
    return nil
  end
  tex2d.wrapMode = TextureWrapMode.Clamp
  tex2d.filterMode = 1
  tex2d:Apply(false, true)
  return tex2d
end
local function load_jpg_from_data(obj)
  if not obj then
    error("res is nil")
    return nil
  end
  local width = obj.width
  local height = obj.height
  local data = obj.data
  local tex2d
  if #texcache > 0 and width == 256 and height == 256 then
    tex2d = texcache[#texcache]
    texcache[#texcache] = nil
  else
    tex2d = Texture2D.Texture2D(width, height, TextureFormat.RGB24, false)
    tex2d.wrapMode = TextureWrapMode.Clamp
    tex2d.filterMode = 1
  end
  local ret = GameUtil.LoadTerrainTileJpgFromData(tex2d, data, width, height)
  if not ret then
    error("LoadImage failed")
    return nil
  end
  tex2d:Apply(false, true)
  return tex2d
end
local vec3 = EC.Vector3.new(0, 0, 0)
def.method("string", "=>", "boolean").Load = function(self, resname)
  local function OnLoadedEnd(obj, sync)
    if not obj then
      return
    end
    local res
    if sync then
      res = load_tex_from_stream(obj)
    else
      res = load_jpg_from_data(obj)
    end
    if not res then
      return
    end
    local w = res.width
    local h = res.height
    self.mWidth = w
    self.mHeight = h
    if not TerrainTileInst then
      TerrainTileInst = GameUtil.SyncLoad(RESPATH.TERRAIN_TILE)
      if not TerrainTileInst then
        error("ECTerrainTile Load inst")
        return
      end
      SpriteCacheRoot = GameObject.GameObject("TerrainTileCacheRoot")
      SpriteCacheRoot:SetActive(false)
      MapNodeRoot = gmodule.moduleMgr:GetModule(ModuleId.MAP).mapNodeRoot
    end
    local spr
    if SpriteCacheRoot.childCount > 0 then
      spr = SpriteCacheRoot:GetChild(0)
    else
      spr = Object.Instantiate(TerrainTileInst, "GameObject")
    end
    spr.name = "TerrainTile" .. tostring(_name_index)
    _name_index = _name_index + 1
    spr:GetComponent("MeshRenderer").material.mainTexture = res
    self.mTex2d = res
    self.mSpiteObj = spr
    local mat = spr.renderer.material
    if mat then
      mat:SetFloat("_Lighten", mapAlpha)
    end
    spr.parent = MapNodeRoot
    vec3:Set(w / 256, h / 256, 1)
    spr.localScale = vec3
    if self.pos ~= nil then
      vec3:Set(self.pos.x, world_height - self.pos.y - self.mHeight, self.mZpass)
      spr.localPosition = vec3
    end
    if sync then
      GameUtil.FreeMapFileData(obj)
      obj:unbind()
    else
      GameUtil.FreeTerrainTileJpgData(obj.data, obj.width, obj.height)
    end
  end
  local function async_load_tile_per_frame(obj)
    if _G.terrain_tile_loaded_per_frame < _G.terrain_tile_max_per_frame then
      _G.terrain_tile_loaded_per_frame = _G.terrain_tile_loaded_per_frame + 1
      OnLoadedEnd(obj, false)
      if _G.IsLoadMap then
        if _G.MapNodeCount > 0 then
          if _G.MapNodeMax == 0 then
            _G.MapNodeMax = _G.MapNodeCount
          end
          _G.MapNodeCount = MapNodeCount - 1
        end
        if _G.MapNodeCount <= 0 then
          _G.IsLoadMap = false
          _G.MapNodeCount = 0
        end
      end
    else
      GameUtil.AddGlobalTimer(0, true, function()
        if self.mToRelease then
          if obj then
            GameUtil.FreeTerrainTileJpgData(obj.data, obj.width, obj.height)
          end
          return
        end
        async_load_tile_per_frame(obj)
      end)
    end
  end
  local function load_jpg_data_per_frame(resname)
    if _G.terrain_tile_to_load_per_frame < _G.terrain_tile_max_per_frame then
      _G.terrain_tile_to_load_per_frame = _G.terrain_tile_to_load_per_frame + 1
      GameUtil.AsyncLoadTerrainTileJpg(resname, function(data, width, height)
        if data then
          if self.mToRelease then
            GameUtil.FreeTerrainTileJpgData(data, width, height)
            return
          end
          local obj = {}
          obj.data = data
          obj.width = width
          obj.height = height
          async_load_tile_per_frame(obj)
        end
      end)
    else
      GameUtil.AddGlobalTimer(0, true, function()
        if not self.mToRelease then
          load_jpg_data_per_frame(resname)
        end
      end)
    end
  end
  if _G.IsMutilFrameLoadMap then
    load_jpg_data_per_frame(resname)
  else
    local obj = GameUtil.SyncReadMapFile(resname)
    OnLoadedEnd(obj, true)
  end
  return true
end
def.method().Release = function(self)
  if not self.mSpiteObj then
    self.mToRelease = true
    return
  end
  Object.DestroyImmediate(self.mTex2d, true)
  do break end
  texcache[#texcache + 1] = self.mTex2d
  self.mTex2d = nil
  self.mSpiteObj.parent = SpriteCacheRoot
  self.mSpiteObj = nil
end
local tpos = EC.Vector3.new()
def.method("number", "number").SetPos = function(self, _x, _y)
  if not self.pos then
    self.pos = {x = _x, y = _y}
  else
    self.pos.x = _x
    self.pos.y = _y
  end
  local sp = self.mSpiteObj
  if not sp then
    return
  end
  self.mSpiteObj.localPosition = tpos:Assign(_x, world_height - _y - self.mHeight, self.mZpass)
end
ECTerrainTile.Commit()
return ECTerrainTile
