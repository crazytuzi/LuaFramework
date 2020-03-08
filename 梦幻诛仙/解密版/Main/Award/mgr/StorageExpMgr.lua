local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local AwardMgrBase = require("Main.Award.mgr.AwardMgrBase")
local StorageExpMgr = Lplus.Extend(AwardMgrBase, CUR_CLASS_NAME)
local def = StorageExpMgr.define
local CResult = {SUCCESS = 0}
def.const("table").CResult = CResult
def.field("userdata").exp = nil
def.field("boolean").needNotice = false
def.field("userdata").changeExp = nil
local instance
def.static("=>", StorageExpMgr).Instance = function()
  if instance == nil then
    instance = StorageExpMgr()
  end
  return instance
end
def.method().Init = function(self)
  self.exp = Int64.new(0)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, StorageExpMgr.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, StorageExpMgr.OnLeaveWorld)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.award.SSyncStorageExp", StorageExpMgr.OnSSyncStorageExp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.award.SSyncStorageExpChange", StorageExpMgr.OnSSyncStorageExpChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.award.SSyncStorageExpReachLimit", StorageExpMgr.OnSSyncStorageExpReachLimit)
end
def.method("=>", "userdata").GetStorageExp = function(self)
  return self.exp
end
def.method().NoticeGetStorageExp = function(self)
  if self.changeExp == nil then
    return
  end
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  local personAward = {}
  table.insert(personAward, {
    PersonalHelper.Type.Text,
    textRes.AnnounceMent[8]
  })
  table.insert(personAward, {
    PersonalHelper.Type.StorageExp,
    self.changeExp
  })
  PersonalHelper.CommonTableMsg(personAward)
end
def.static("table").OnSSyncStorageExp = function(p)
  instance.exp = p.newStorageExp
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.STORAGE_EXP_UPDATE, {
    instance.exp
  })
end
def.static("table").OnSSyncStorageExpChange = function(p)
  if p.newStorageExp:le(0) then
    return
  end
  instance.changeExp = p.newStorageExp
  if _G.IsEnteredWorld() then
    instance:NoticeGetStorageExp()
  else
    instance.needNotice = true
  end
end
def.static("table").OnSSyncStorageExpReachLimit = function(p)
  Toast(textRes.Award[10])
end
def.static("table", "table").OnEnterWorld = function(params)
  if instance.needNotice then
    instance:NoticeGetStorageExp()
  end
end
def.static("table", "table").OnLeaveWorld = function(params)
  instance.needNotice = false
  instance.exp = Int64.new(0)
end
return StorageExpMgr.Commit()
