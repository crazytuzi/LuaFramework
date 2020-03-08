local Lplus = require("Lplus")
local ECObject = require("Model.ECObject")
local HomelandTouchController = Lplus.Extend(ECObject, "HomelandTouchController")
local def = HomelandTouchController.define
local EC = require("Types.Vector3")
def.field("userdata").m_go = nil
def.field("boolean").m_loading = false
def.field("boolean").m_touching = false
def.field("boolean").m_longtouching = false
def.field("table").m_beginPos = nil
def.field("table").m_lastPos = nil
def.field("boolean").m_dragging = false
def.field("userdata").m_delegateGO = nil
local instance
def.static("=>", HomelandTouchController).Instance = function()
  if instance == nil then
    instance = HomelandTouchController()
    instance:Init()
    instance.clickPriority = 0
  end
  return instance
end
def.method().Init = function(self)
end
def.method().OnTouchBegin = function(self)
  local touchPos = self:GetTouchPos()
  local camera = CommonCamera.game3DCamera
  local p = camera:ScreenToWorldPoint(EC.Vector3.new(touchPos.x, touchPos.y, camera.farClipPlane))
  local origin = camera:ScreenToWorldPoint(EC.Vector3.new(touchPos.x, touchPos.y, 0))
  local dir = p - origin
  local mask = bit.lshift(1, _G.ClientDef_Layer.Player)
  local isHit, hitInfo = Physics.RayCastByVec(origin, dir, 150, mask)
  if isHit then
    local go = hitInfo.collider.gameObject
    self.m_delegateGO = go
    self:PassthroughTouchEvent("OnTouchBegin", go)
    return
  end
  self.m_delegateGO = nil
  self.m_touching = true
  self.m_beginPos = Input.mousePosition
end
def.method().OnLongTouch = function(self)
  if self.m_touching == false then
    return
  end
  self.m_longtouching = true
  local map2dPos = self:GetTouchMap2DPos()
  gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):OnTouchMove(map2dPos.x, map2dPos.y)
end
def.method().ForceLongTouch = function(self)
  self.m_delegateGO = nil
  self.m_touching = true
  self.m_beginPos = Input.mousePosition
  self:OnLongTouch()
end
def.method().OnTouchEnd = function(self)
  if self.m_touching == false then
    self:PassthroughTouchEvent("OnTouchEnd", self.m_delegateGO)
    self.m_delegateGO = nil
    return
  end
  if self:IsDragging() then
    self:OnDragEnd()
  end
  self.m_touching = false
  self.m_longtouching = false
  self.m_beginPos = nil
end
def.method().OnClick = function(self)
end
def.method("number").OnUpdate = function(self, dt)
  if not self:IsActive() then
    return
  end
  if self:IsDragging() then
    self:OnDrag()
  elseif self.m_beginPos then
    local curPos = Input.mousePosition
    local diff = curPos - self.m_beginPos
    local distance = diff:get_Length()
    if distance > 10 then
      self:OnDragStart()
    end
  end
end
def.method().OnDragStart = function(self)
  self.m_dragging = true
  local map2dPos = self:GetTouchMap2DPos()
  gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):OnDragStart(map2dPos.x, map2dPos.y)
end
def.method().OnDrag = function(self)
  if gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):IsInEditMode() then
    local map2dPos = self:GetTouchMap2DPos()
    gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):OnTouchMove(map2dPos.x, map2dPos.y)
  end
end
def.method().OnDragEnd = function(self)
  self.m_dragging = false
  local map2dPos = self:GetTouchMap2DPos()
  gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):OnDragEnd(map2dPos.x, map2dPos.y)
end
def.method("=>", "table").GetTouchPos = function(self)
  return Input.mousePosition
end
def.method("=>", "table").GetTouchMap2DPos = function(self)
  local touchPos = self:GetTouchPos()
  local pos = ScreenToMap2DPos(touchPos.x, touchPos.y)
  pos.x = math.floor(pos.x)
  pos.y = math.floor(pos.y)
  return pos
end
def.method("=>", "boolean").IsTouching = function(self)
  return self.m_touching
end
def.method("=>", "boolean").IsLongTouching = function(self)
  if not self:IsTouching() then
    return false
  end
  return self.m_longtouching
end
def.method("=>", "boolean").IsDragging = function(self)
  if not self:IsTouching() then
    return false
  end
  return self.m_dragging
end
def.method().Load = function(self)
  local cam = CommonCamera.game3DCamera
  local cam3dObj = cam.gameObject
  if self.m_loading then
    return
  end
  if self.m_go and self.m_go.isnil == false then
    return
  end
  local EC = require("Types.Vector3")
  local go = GameObject.GameObject()
  go.name = "HomelandTouchController"
  go:AddComponent("BoxCollider")
  go:SetLayer(_G.ClientDef_Layer.Player)
  go.parent = cam3dObj
  go.localScale = EC.Vector3.new(cam.orthographicSize * 2 / Screen.height * Screen.width, cam.orthographicSize * 2, 1)
  go.localPosition = EC.Vector3.new(0, 0, 199)
  go.localRotation = Quaternion.Euler(EC.Vector3.zero)
  self.m_go = go
  GameUtil.AddECObjectComponent(self, go, false)
  Timer:RegisterIrregularTimeListener(self.OnUpdate, self)
end
def.method().Destroy = function(self)
  Timer:RemoveIrregularTimeListener(self.OnUpdate)
  if self.m_go and self.m_go.isnil == false then
    GameObject.DestroyImmediate(self.m_go)
  end
  self.m_go = nil
  self.m_loading = false
  self.m_touching = false
  self.m_longtouching = false
  self.m_beginPos = nil
  self.m_lastPos = nil
  self.m_dragging = false
  self.m_delegateGO = nil
end
def.method("boolean").SetActive = function(self, isActive)
  if self.m_go and self.m_go.isnil == false then
    self.m_go:SetActive(isActive)
  end
end
def.method("=>", "boolean").IsActive = function(self)
  if self.m_go and self.m_go.isnil == false and self.m_go.activeInHierarchy then
    return true
  else
    return false
  end
end
def.method("string", "userdata").PassthroughTouchEvent = function(self, eventName, go)
  if go == nil then
    return
  end
  local rolesMap = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE).rolesMap
  for k, role in pairs(rolesMap) do
    local model = role.m_model
    if model and model.isnil == false and model:IsEq(go) then
      if eventName == "OnTouchBegin" then
        role:OnTouchBegin()
        role:OnClick()
      elseif eventName == "OnTouchEnd" then
        role:OnTouchEnd()
      end
    end
  end
end
return HomelandTouchController.Commit()
