local Lplus = require("Lplus")
local ChildrenDataMgr = Lplus.Class("ChildrenDataMgr")
local ChildBean = require("netio.protocol.mzm.gsp.children.ChildBean")
local BabyData = require("Main.Children.data.BabyData")
local TeenData = require("Main.Children.data.TeenData")
local YouthData = require("Main.Children.data.YouthData")
local ChildPhase = require("consts.mzm.gsp.children.confbean.ChildPhase")
local def = ChildrenDataMgr.define
local instance
def.static("=>", ChildrenDataMgr).Instance = function()
  if instance == nil then
    instance = ChildrenDataMgr()
  end
  return instance
end
def.field("table").m_children = nil
def.field("table").m_discardContent = nil
def.field("table").m_discardChild = nil
def.field("userdata").m_showChildId = nil
def.field("number").m_showPeriod = 0
def.field("table").m_bagChildren = nil
def.field("userdata").m_inFightSceneChildId = nil
local conv2sec = function(time)
  local serverTime = _G.GetServerTime()
  local serverTimeScale = 10 * serverTime
  if time:gt(serverTimeScale) then
    return time / 1000
  else
    return time
  end
end
def.static("table", "=>", "table").MakeChild = function(bean)
  if bean.child_period == ChildPhase.INFANT then
    local data = BabyData.New()
    data:RawSet(bean)
    return data
  elseif bean.child_period == ChildPhase.CHILD then
    local data = TeenData.New()
    data:RawSet(bean)
    return data
  elseif bean.child_period == ChildPhase.YOUTH then
    local data = YouthData.New()
    data:RawSet(bean)
    return data
  end
  return nil
end
def.method().Reset = function(self)
  self.m_children = nil
  self.m_discardContent = nil
  self.m_discardChild = nil
  self.m_showChildId = nil
  self.m_showPeriod = 0
  self.m_bagChildren = nil
  self.m_inFightSceneChildId = nil
end
def.method("=>", "boolean").HasChildren = function(self)
  return self.m_children and next(self.m_children) ~= nil or false
end
def.method("userdata", "table").AddChild = function(self, cid, child)
  if self.m_children == nil then
    self.m_children = {}
  end
  self.m_children[cid:tostring()] = nil
  local data = ChildrenDataMgr.MakeChild(child)
  if data then
    self.m_children[cid:tostring()] = data
  end
end
def.method("userdata", "table").AddDiscardContent = function(self, cid, child)
  if self.m_discardContent == nil then
    self.m_discardContent = {}
  end
  self.m_discardContent[cid:tostring()] = nil
  local data = ChildrenDataMgr.MakeChild(child)
  if data then
    self.m_discardContent[cid:tostring()] = data
  end
end
def.method("userdata", "userdata").AddDiscardChild = function(self, cid, dtime)
  if self.m_discardChild == nil then
    self.m_discardChild = {}
  end
  self.m_discardChild[cid:tostring()] = conv2sec(dtime)
end
def.method("userdata").RemoveDiscardChild = function(self, cid)
  if self.m_discardChild then
    self.m_discardChild[cid:tostring()] = nil
  end
end
def.method("userdata").RemoveChild = function(self, cid)
  if self.m_children then
    self.m_children[cid:tostring()] = nil
  end
  self:RemoveBagChild(cid)
  if self.m_showChildId == cid then
    self.m_showChildId = nil
    self.m_showPeriod = 0
  end
end
def.method("userdata").RemoveDiscardContent = function(self, cid)
  if self.m_discardContent then
    self.m_discardContent[cid:tostring()] = nil
  end
  self:RemoveBagChild(cid)
  if self.m_showChildId == cid then
    self.m_showChildId = nil
    self.m_showPeriod = 0
  end
end
def.method("userdata").MoveToWelfare = function(self, cid)
  if self.m_children ~= nil and self.m_children[cid:tostring()] ~= nil then
    self:RemoveBagChild(cid)
    if self.m_showChildId == cid then
      self.m_showChildId = nil
      self.m_showPeriod = 0
    end
    self:AddDiscardChild(cid, conv2sec(Int64.new(_G.GetServerTime())))
    local child = clone(self.m_children[cid:tostring()])
    self.m_children[cid:tostring()] = nil
    if self.m_discardContent == nil then
      self.m_discardContent = {}
    end
    self.m_discardContent[cid:tostring()] = child
  end
end
def.method("userdata").MoveFromWelfare = function(self, cid)
  if self.m_discardChild ~= nil and self.m_discardContent ~= nil and self.m_discardChild[cid:tostring()] ~= nil and self.m_discardContent[cid:tostring()] ~= nil then
    local child = clone(self.m_discardContent[cid:tostring()])
    self.m_discardChild[cid:tostring()] = nil
    self.m_discardContent[cid:tostring()] = nil
    if self.m_children == nil then
      self.m_children = {}
    end
    self.m_children[cid:tostring()] = nil
    self.m_children[cid:tostring()] = child
  end
end
def.method("=>", "table").GetAllChildren = function(self)
  if self.m_children then
    return self.m_children
  else
    return nil
  end
end
def.method("=>", "table").GetAllDiscardContent = function(self)
  if self.m_discardContent then
    return self.m_discardContent
  else
    return nil
  end
end
def.method("=>", "table").GetAllDiscardChild = function(self)
  if self.m_discardChild then
    return self.m_discardChild
  else
    return nil
  end
end
def.method("userdata", "=>", "table").GetChildById = function(self, cid)
  if cid == nil then
    return nil
  end
  if self.m_children == nil then
    return nil
  end
  return self.m_children[cid:tostring()]
end
def.method("userdata", "=>", "table").GetDiscardContentById = function(self, cid)
  if cid == nil then
    return nil
  end
  if self.m_discardContent == nil then
    return nil
  end
  return self.m_discardContent[cid:tostring()]
end
def.method("=>", "userdata", "number").GetShowChildId = function(self)
  return self.m_showChildId, self.m_showPeriod
end
def.method("userdata", "number").SetShowChildId = function(self, scid, period)
  self.m_showChildId = scid
  self.m_showPeriod = period
end
def.method("=>", "table").GetChildrenInBagSort = function(self)
  local ret = {}
  for k, v in pairs(self.m_bagChildren or {}) do
    table.insert(ret, k)
  end
  table.sort(ret, function(a, b)
    local aChild = self.m_children[a]
    local bChild = self.m_children[b]
    if not aChild or not bChild then
      return true
    end
    return aChild:GetStatus() < bChild:GetStatus()
  end)
  for k, v in ipairs(ret) do
    ret[k] = Int64.new(v)
  end
  return ret
end
def.method("userdata").AddBagChild = function(self, cid)
  if self.m_bagChildren == nil then
    self.m_bagChildren = {}
  end
  if self.m_children and self.m_children[cid:tostring()] then
    self.m_bagChildren[cid:tostring()] = true
  end
end
def.method("userdata").RemoveBagChild = function(self, cid)
  if self.m_bagChildren then
    self.m_bagChildren[cid:tostring()] = nil
  end
  if self.m_showChildId == cid then
    self.m_showChildId = nil
    self.m_showPeriod = 0
  end
end
def.method("userdata", "=>", "boolean").IsInBag = function(self, cid)
  if self.m_bagChildren then
    return self.m_bagChildren[cid:tostring()] and true or false
  else
    return false
  end
end
def.method("userdata", "=>", "number").GetChildrenCountByRoleId = function(self, roleId)
  if self.m_children == nil then
    return 0
  end
  local count = 0
  for k, child in pairs(self.m_children) do
    if child.owner == roleId then
      count = count + 1
    end
  end
  return count
end
def.method("number", "=>", "table").GetChildrenByStatus = function(self, status)
  if self.m_children == nil then
    return {}
  end
  local children = {}
  for k, child in pairs(self.m_children) do
    if child.status == status then
      table.insert(children, child)
    end
  end
  return children
end
def.method("=>", "table").GetFightChildren = function(self)
  if self.m_children == nil then
    return nil
  end
  local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId
  local children = {}
  for _, child in pairs(self.m_children) do
    if child:IsYouth() and child.info and child.owner:eq(myId) and self:IsInBag(child.id) then
      table.insert(children, child)
    end
  end
  return children
end
def.method("userdata").SetInFightSceneChildId = function(self, childId)
  if self:GetChildById(childId) then
    self.m_inFightSceneChildId = childId
  end
end
def.method("=>", "table").GetInFightSceneChild = function(self)
  if self.m_inFightSceneChildId == nil then
    return nil
  end
  return self:GetChildById(self.m_inFightSceneChildId)
end
def.method().ClearInFightSceneChild = function(self)
  self.m_inFightSceneChildId = nil
end
ChildrenDataMgr.Commit()
return ChildrenDataMgr
