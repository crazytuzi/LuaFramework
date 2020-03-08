local Lplus = require("Lplus")
local ECManager = require("Main.ECManager")
local ECMatter = require("Object.ECMatter")
local matter_info = require("S2C.matter_info")
local matter_change_status = require("S2C.matter_change_status")
local Exptypes = require("Data.Exptypes")
local ECPanelMidmap = require("GUI.ECPanelMidmap")
local ECMatterMan = Lplus.Extend(ECManager, "ECMatterMan")
local def = ECMatterMan.define
def.field("userdata").Root = nil
def.final("=>", ECMatterMan).new = function()
  local obj = ECMatterMan()
  obj:Init(ECManager.EC_MAN_ENUM.MAN_MATTER)
  obj.Root = GameObject.GameObject("Matters")
  return obj
end
def.method(matter_info, "boolean").CreateMatter = function(self, info, bBornInSight)
  local matter = ECMatter.new()
  matter:Init(info)
  matter:Load()
  self.m_ObjMap[info.id] = matter
end
def.override("boolean").Release = function(self, bReleaseScene)
  ECManager.Release(self, bReleaseScene)
  if bReleaseScene then
    Object.Destroy(self.Root)
    self.Root = nil
  end
end
local MATTER_STATUS = ECMatter.MATTER_STATUS
def.method("number", "=>", ECMatter).FindNearestMatterByTid = function(self, tid)
  for _, id in ipairs(self.m_SortList) do
    local matter = self:GetMatter(id)
    if matter and matter.MatterInfo.tid == tid then
      local status = matter.MatterInfo.status
      if status ~= MATTER_STATUS.MS_DEAD then
        return matter
      end
    end
  end
  return nil
end
def.method(matter_change_status).OnCmd_MatterChangeStatus = function(self, cmd)
  local matter = self:GetMatter(cmd.id)
  if matter then
    matter.MatterInfo.status = cmd.status
    if cmd.status == ECMatter.MATTER_STATUS.MS_DEAD then
      matter:AddLoadedCallback(function(matter)
        local m = matter.m_ECModel
        m:Play(AnimationNameTable.NPC_Die)
      end)
    end
  end
end
def.method().Update = function(self)
  self:SortByDistToHost()
end
def.method("string", "=>", ECMatter).GetMatter = function(self, id)
  return self.m_ObjMap[id]
end
def.method().UpdateTransferMidmapMarks = function(self)
  local inst = ECPanelMidmap.Instance()
  local objmap = self.m_ObjMap
  for k, v in pairs(objmap) do
    if v.m_bReady and v:IsTransmitBox() then
      local m = v.m_RootObj
      local pos = m.position
      local tid = v.MatterInfo.tid
      inst:UpdateTransferMark(k, pos.x, pos.z)
    end
  end
end
ECMatterMan.Commit()
return ECMatterMan
