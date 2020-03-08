local MODULE_NAME = (...)
local Lplus = require("Lplus")
local FriendMarkContainer = Lplus.Class(MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local def = FriendMarkContainer.define
local FriendModule = Lplus.ForwardDeclare("FriendModule")
def.field("table").m_marks = nil
def.field("table").m_parentContainer = nil
def.method("table").Init = function(self, parentContainer)
  self.m_marks = {}
  self.m_parentContainer = parentContainer
end
def.method("table", "=>", "dynamic").AddFriendMark = function(self, mark)
  local go, roleId = mark.go, mark.roleId
  if _G.IsNil(go) then
    return nil
  end
  if roleId == nil then
    return nil
  end
  local markId = go:GetInstanceID()
  self.m_marks[markId] = mark
  self:UpdateFriendMarkInner(mark)
  return markId
end
def.method("userdata").RemoveFriendMark = function(self, markId)
  self.m_marks[markId] = nil
end
def.method().Destroy = function(self)
  self.m_marks = nil
  if self.m_parentContainer then
    self.m_parentContainer:RemoveContainer(self)
  end
end
def.method().UpdateAllFriendMarks = function(self)
  local removeMarkKeys = {}
  for k, v in pairs(self.m_marks) do
    if _G.IsNil(v.go) then
      table.insert(removeMarkKeys, k)
    else
      self:UpdateFriendMarkInner(v)
    end
  end
  for i, key in ipairs(removeMarkKeys) do
    self.m_marks[key] = nil
  end
end
def.method("table").UpdateFriendMarkInner = function(self, mark)
  local canShow = self:CanShowMark(mark.roleId)
  mark.go:SetActive(canShow)
end
def.method("userdata", "=>", "boolean").CanShowMark = function(self, roleId)
  local myRoleId = _G.GetMyRoleID()
  if myRoleId == roleId then
    return false
  end
  local isMyFriend = FriendModule.Instance():GetFriendInfo(roleId) ~= nil
  if isMyFriend then
    return true
  else
    return false
  end
end
return FriendMarkContainer.Commit()
