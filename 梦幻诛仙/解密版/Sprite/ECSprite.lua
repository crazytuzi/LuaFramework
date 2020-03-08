local Lplus = require("Lplus")
local ECSprite = Lplus.Class("ECSprite")
local def = ECSprite.define
local EC = require("Types.Vector")
def.field("userdata").mSpiteObj = nil
def.field("number").mWidth = 0
def.field("number").mHeight = 0
def.final("=>", ECSprite).new = function()
  local obj = ECSprite()
  return obj
end
local _name_index = 0
def.method("string", "=>", "boolean").Load = function(self, resname)
  local res = GameUtil.SyncLoad(resname, true)
  if not res then
    error("ECSprite Load")
    return false
  end
  if getmetatable(res).name ~= "Texture2D" then
    local data = res.bytes
    if not data then
      error("res.bytes is nil")
      return false
    end
    local tex2d = Texture2D.Texture2D(0, 0, TextureFormat.RGB24, false)
    local ret = tex2d:LoadImage(res.bytes)
    if not ret then
      error("LoadImage failed")
      return false
    end
    res = tex2d
    tex2d.wrapMode = TextureWrapMode.Clamp
    tex2d.filterMode = 1
  end
  local w = res.width
  local h = res.height
  local RECT = require("Types.Rect")
  local sp = Sprite.Create_4(res, RECT.Rect.new(0, 0, w, h), EC.Vector2.new(0, 0), 1)
  self.mWidth = w
  self.mHeight = h
  local spri = GameUtil.SyncLoad(RESPATH.SPRITE_INST, false)
  if not spri then
    error("ECSprite Load spri")
    return false
  end
  local spr = Object.Instantiate(spri, "GameObject")
  spr.name = "Sprite" .. tostring(_name_index)
  _name_index = _name_index + 1
  spr:GetComponent("SpriteRenderer").sprite = sp
  self.mSpiteObj = spr
  self.mSpiteObj.transform.parent = gmodule.moduleMgr:GetModule(ModuleId.MAP).mapNodeRoot.transform
  return self.mSpiteObj ~= nil
end
def.method().Release = function(self)
  if not self.mSpiteObj then
    return
  end
  Object.Destroy(self.mSpiteObj)
  self.mSpiteObj = nil
end
local t_pos = EC.Vector3.new()
def.virtual("number", "number").SetPos = function(self, x, y)
  local sp = self.mSpiteObj
  if not sp then
    error("ECSprite SetPos")
    return
  end
  sp.localPosition = t_pos:Assign(x, world_height - y - self.mHeight, 0)
end
local t_scale = EC.Vector3.new()
def.virtual("number", "number").SetScale = function(self, x, y)
  local sp = self.mSpiteObj
  if not sp then
    error("ECSprite SetPos")
    return
  end
  sp.localScale = t_scale:Assign(x, y, 1)
end
ECSprite.Commit()
return ECSprite
