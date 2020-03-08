local Lplus = require("Lplus")
local ECSprite = require("Sprite.ECSprite")
local EC = require("Types.Vector")
local ECSpriteAnimation = Lplus.Extend(ECSprite, "ECSpriteAnimation")
local def = ECSpriteAnimation.define
def.field("userdata").mSpiteAnim = nil
def.field("userdata").mTex2d = nil
def.field("userdata").mChildObj = nil
def.field("userdata").mPathComponent = nil
def.field("userdata").mAlphaComponent = nil
def.field("userdata").mScaleComponent = nil
def.field("userdata").mRotationComponent = nil
def.field("number").mAsyncLoadIndex = 0
def.field("table").mUpdateSpriteListParams = nil
def.field("table").mSetColorParams = nil
def.static("=>", ECSpriteAnimation).new = function()
  local obj = ECSpriteAnimation()
  obj:Init()
  return obj
end
local _spriteAnim_name_index = 0
def.method().Init = function(self)
  local name = "Sprite" .. tostring(_spriteAnim_name_index)
  _spriteAnim_name_index = _spriteAnim_name_index + 1
  self.mSpiteObj = GameObject.GameObject("spriteAnim" .. tostring(_spriteAnim_name_index))
  self.mChildObj = GameObject.GameObject("spriteAnimChild" .. tostring(_spriteAnim_name_index))
  self.mChildObj.transform.parent = self.mSpiteObj.transform
  self.mSpiteObj.transform.parent = gmodule.moduleMgr:GetModule(ModuleId.MAP).mapEffectNodeRoot.transform
  self.mChildObj:AddComponent("SpriteRenderer")
  self.mSpiteAnim = self.mChildObj:AddComponent("SpriteAnimation")
  self.mPathComponent = self.mChildObj:AddComponent("CommonSpriteMovePath")
  self.mAlphaComponent = self.mChildObj:AddComponent("CommonSpriteAlphaEffect")
  self.mScaleComponent = self.mChildObj:AddComponent("CommonSpriteScaleEffect")
  self.mRotationComponent = self.mChildObj:AddComponent("CommonSpriteRotationEffect")
end
def.method("string").LoadXml = function(self, xmlName)
  if self.mSpiteAnim == nil then
    return
  end
  self.mSpiteAnim:LoadXml(xmlName)
end
def.method("string", "number", "boolean").PlayAnim = function(self, xmlName, sec, loop)
  if self.mSpiteAnim == nil then
    return
  end
  self.mSpiteAnim:PlayAction_2(xmlName, sec, loop)
end
def.method("string", "=>", "boolean").LoadAnimFile = function(self, resname)
  local res = GameUtil.SyncLoad(resname, true)
  if not res then
    error("ECSpriteAnimation LoadAnimFile")
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
  end
  self.mTex2d = res
  return true
end
def.method("string", "=>", "boolean").AsyncLoadAnimFile = function(self, resname)
  self.mAsyncLoadIndex = self.mAsyncLoadIndex + 1
  local asyncLoadIndex = self.mAsyncLoadIndex
  GameUtil.AsyncLoad(resname, function(res)
    if self.mSpiteAnim == nil or self.mSpiteAnim.isnil then
      return
    end
    if self.mAsyncLoadIndex ~= asyncLoadIndex then
      return
    end
    if not res then
      error("ECSpriteAnimation LoadAnimFile")
      return
    end
    if getmetatable(res).name ~= "Texture2D" then
      local data = res.bytes
      if not data then
        error("res.bytes is nil")
        return
      end
      local tex2d = Texture2D.Texture2D(0, 0, TextureFormat.RGB24, false)
      local ret = tex2d:LoadImage(res.bytes)
      if not ret then
        error("LoadImage failed")
        return
      end
    end
    self.mTex2d = res
    local p = self.mUpdateSpriteListParams
    if p then
      self:UpdateSpriteList(p[1], p[2], p[3], p[4], p[5])
    end
    p = self.mSetColorParams
    if p then
      self:SetColor(p[1], p[2], p[3], p[4])
    end
    self.mUpdateSpriteListParams = nil
    self.mSetColorParams = nil
  end)
  return true
end
def.method().CreateStaticPicSprite = function(self)
  if self.mSpiteAnim == nil then
    return
  end
  if self.mTex2d == nil then
    return
  end
  self.mSpiteAnim:CreateStaticPicSprite(self.mTex2d)
end
def.method("number", "number", "number", "number", "number", "number").AddRectInfo = function(self, x, y, w, h, offX, offY)
  self.mSpiteAnim:AddRectInfo(x, y, w, h, offX, offY)
  self.mHeight = h
end
def.method("number", "boolean", "number", "number", "number").UpdateSpriteList = function(self, sec, loop, frameCount, playMode, blendOp)
  if self.mTex2d == nil then
    self.mUpdateSpriteListParams = {
      sec,
      loop,
      frameCount,
      playMode,
      blendOp
    }
    return
  end
  self.mSpiteAnim:CreateSpriteAnimList(self.mTex2d, sec, loop, frameCount, playMode, blendOp)
  self.mSpiteAnim:PlayAction_3()
end
def.method("number", "number", "number", "number").SetColor = function(self, r, g, b, a)
  if self.mTex2d == nil then
    self.mSetColorParams = {
      r,
      g,
      b,
      a
    }
    return
  end
  self.mSpiteAnim:SetColor(r, g, b, a)
end
local t_pos = EC.Vector3.new()
def.override("number", "number").SetPos = function(self, x, y)
  local sp = self.mSpiteObj
  if not sp then
    error("ECSprite SetPos")
    return
  end
  sp.localPosition = t_pos:Assign(x, world_height - y - self.mHeight, -1)
end
def.method("number", "number").SetAbsPos = function(self, x, y)
  local sp = self.mSpiteObj
  if not sp then
    error("ECSprite SetPos")
    return
  end
  sp.localPosition = t_pos:Assign(x, y, -1)
end
def.method("number", "number", "number", "number", "number", "number").AddPath = function(self, x, y, frame, endFrame, frameCount, startFrame)
  self.mPathComponent:AddPathNode(x, y, frame, endFrame, frameCount, startFrame)
end
def.method().BeginPath = function(self)
  self.mPathComponent:StartEffect()
end
def.method("number", "number", "number", "number", "number").AddPathAlpha = function(self, alpha, frame, endFrame, frameCount, startFrame)
  self.mAlphaComponent:AddPathAlpha(alpha, frame, endFrame, frameCount, startFrame)
end
def.method("number", "number", "number", "number", "number", "number").AddPathScale = function(self, x, y, frame, endFrame, frameCount, startFrame)
  self.mScaleComponent:AddPathScale(x, y, frame, endFrame, frameCount, startFrame)
end
def.method("number", "number", "number", "number", "number").AddRotationPath = function(self, z, frame, endFrame, frameCount, startFrame)
  self.mRotationComponent:AddPathRotation(z, frame, endFrame, frameCount, startFrame)
end
def.method().BeginAlphaPath = function(self)
  self.mAlphaComponent:StartEffect()
end
def.method().BeginRotationPath = function(self)
  self.mRotationComponent:StartEffect()
end
def.method().BeginScalePath = function(self)
  self.mScaleComponent:StartEffect()
end
def.method("number").SetRotationZ = function(self, ang)
  self.mSpiteObj.localRotation = Quaternion.Euler(EC.Vector3.new(0, 0, ang))
end
def.method("boolean").SetEnable = function(self, enabled)
  self.mSpiteObj:SetActive(enabled)
end
def.method("number", "number").SetChildScale = function(self, x, y)
  local sp = self.mChildObj
  if sp ~= nil then
    sp.localScale = EC.Vector3.new(x, y, 1)
  end
end
ECSpriteAnimation.Commit()
return ECSpriteAnimation
