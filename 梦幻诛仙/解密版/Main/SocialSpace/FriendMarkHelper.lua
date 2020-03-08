local MODULE_NAME = (...)
local Lplus = require("Lplus")
local FriendMarkHelper = Lplus.Class(MODULE_NAME)
local def = FriendMarkHelper.define
local FriendMarkContainer = require("Main.SocialSpace.FriendMarkContainer")
local instance
def.static("=>", FriendMarkHelper).Instance = function()
  if instance == nil then
    instance = FriendMarkHelper()
    instance:Init()
  end
  return instance
end
def.field("table").m_containers = nil
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.FRIEND, gmodule.notifyId.Friend.Friend_OnFriendChanged, FriendMarkHelper.OnFriendChanged)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, FriendMarkHelper.OnLeaveWorld)
end
def.method("=>", FriendMarkContainer).CreateContainer = function(self)
  local container = FriendMarkContainer()
  container:Init(self)
  self:AddContainer(container)
  return container
end
def.method("table").AddContainer = function(self, container)
  self.m_containers = self.m_containers or {}
  self.m_containers[container] = container
end
def.method("table").RemoveContainer = function(self, container)
  if self.m_containers == nil then
    return
  end
  self.m_containers[container] = nil
  if table.nums(self.m_containers) == 0 then
    self.m_containers = nil
  end
end
def.method().UpdateAllContainers = function(self)
  if self.m_containers == nil then
    return
  end
  for _, container in pairs(self.m_containers) do
    container:UpdateAllFriendMarks()
  end
end
def.method().Clear = function(self)
  self.m_containers = nil
end
def.static("table", "table").OnFriendChanged = function(params, context)
  instance:UpdateAllContainers()
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  instance:Clear()
end
return FriendMarkHelper.Commit()
