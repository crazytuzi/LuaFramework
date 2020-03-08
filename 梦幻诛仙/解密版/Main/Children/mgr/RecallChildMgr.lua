local Lplus = require("Lplus")
local RecallChildMgr = Lplus.Class("RecallChildMgr")
local NPCInterface = require("Main.npc.NPCInterface")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local def = RecallChildMgr.define
local instance
def.static("=>", RecallChildMgr).Instance = function()
  if instance == nil then
    instance = RecallChildMgr()
  end
  return instance
end
def.method().Init = function(self)
  local npcInterface = NPCInterface.Instance()
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.ChildrenWelfare, RecallChildMgr.OnNPCService_RecallChild)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.children.SRealDeleteChild", RecallChildMgr.OnSRealDeleteChild)
end
def.static("number", "=>", "boolean").OnNPCService_RecallChild = function(serviceId)
  if serviceId == NPCServiceConst.ChildrenWelfare then
    local isOpen = require("Main.Children.ChildrenInterface").IsRecallOpen()
    if not isOpen then
      return false
    else
      return true
    end
  else
    return true
  end
end
def.static("table").OnSRealDeleteChild = function(p)
  local childId = p.child_id
  ChildrenDataMgr.Instance():RemoveChild(childId)
  ChildrenDataMgr.Instance():RemoveDiscardChild(childId)
  ChildrenDataMgr.Instance():RemoveDiscardContent(childId)
end
RecallChildMgr.Commit()
return RecallChildMgr
