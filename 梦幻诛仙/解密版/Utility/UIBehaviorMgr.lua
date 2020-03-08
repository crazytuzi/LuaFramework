local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local UIBehaviorBase = Lplus.ForwardDeclare("UIBehaviorBase")
local UIBehaviorMgr = Lplus.Class("UIBehaviorMgr")
local def = UIBehaviorMgr.define
local instance
def.static("=>", UIBehaviorMgr).Instance = function()
  if instance == nil then
    instance = UIBehaviorMgr()
    instance:Init()
  end
  return instance
end
def.field("table")._behaviorList = nil
def.field("boolean")._done = false
def.field("boolean")._doing = false
def.field("boolean")._notify = false
def.method().Init = function(self)
  self._behaviorList = {}
end
def.method(UIBehaviorBase).AddBehavior = function(self, behaviorBase)
  table.insert(self._behaviorList, behaviorBase)
end
def.method().Do = function(self)
  if self._doing == true then
    return
  end
  local oldList = self._behaviorList
  self._behaviorList = {}
  for k, behaviorBase in pairs(oldList) do
    behaviorBase:Prepare()
  end
  for k, behaviorBase in pairs(oldList) do
    behaviorBase:OnFrame()
    if behaviorBase:IsReady() == true then
      behaviorBase:Do()
      if behaviorBase:IsDone() == false then
        table.insert(self._behaviorList, behaviorBase)
      end
    else
      table.insert(self._behaviorList, behaviorBase)
    end
  end
  self._done = #self._behaviorList <= 0
  if self._done == false and self._notify == false then
    Timer:RegisterIrregularTimeListener(self.OnFrame, self)
    Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.GAME_PAUSE, UIBehaviorMgr.OnGamePause)
    self._notify = true
  end
end
def.method("=>", "boolean").IsDone = function(self)
  return self._done
end
def.method("number").OnFrame = function(self, dt)
  local oldList = self._behaviorList
  self._behaviorList = {}
  for k, behaviorBase in pairs(oldList) do
    behaviorBase:OnFrame()
    if behaviorBase:IsReady() == true then
      behaviorBase:Do()
      if behaviorBase:IsDone() == false then
        table.insert(self._behaviorList, behaviorBase)
      end
    else
      table.insert(self._behaviorList, behaviorBase)
    end
  end
  self._done = #self._behaviorList <= 0
  if self._done == true then
    self:Clear()
  end
end
def.method().Clear = function(self)
  Timer:RemoveIrregularTimeListener(self.OnFrame)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.GAME_PAUSE, UIBehaviorMgr.OnGamePause)
  self._behaviorList = {}
  self._notify = false
  self._doing = false
end
def.static("table", "table").OnGamePause = function(p1, p2)
  instance:Clear()
end
UIBehaviorMgr.Commit()
return UIBehaviorMgr
