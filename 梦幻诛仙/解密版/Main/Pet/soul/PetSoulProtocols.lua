local Lplus = require("Lplus")
local PetSoulData = require("Main.Pet.soul.data.PetSoulData")
local PetSoulUtils = require("Main.Pet.soul.PetSoulUtils")
local PetSoulProtocols = Lplus.Class("PetSoulProtocols")
local def = PetSoulProtocols.define
def.static().RegisterProtocols = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetSoulInitPropRes", PetSoulProtocols.OnSPetSoulInitPropRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetSoulInitPropErrorRes", PetSoulProtocols.OnSPetSoulInitPropErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetSoulRandomPropRes", PetSoulProtocols.OnSPetSoulRandomPropRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetSoulRandomPropErrorRes", PetSoulProtocols.OnSPetSoulRandomPropErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetSoulAddExpRes", PetSoulProtocols.OnSPetSoulAddExpRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetSoulAddExpErrorRes", PetSoulProtocols.OnSPetSoulAddExpErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetSoulExchangeRes", PetSoulProtocols.OnSPetSoulExchangeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetSoulExchangeErrorRes", PetSoulProtocols.OnSPetSoulExchangeErrorRes)
end
def.static("userdata", "number", "number").SendCPetSoulInitPropReq = function(petId, pos, propIndex)
  warn("[PetSoulProtocols:SendCPetSoulInitPropReq] Send CPetSoulInitPropReq:", Int64.tostring(petId), pos, propIndex)
  local p = require("netio.protocol.mzm.gsp.pet.CPetSoulInitPropReq").new(petId, pos, propIndex)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSPetSoulInitPropRes = function(p)
  warn("[PetSoulProtocols:OnSPetSoulInitPropRes] On SPetSoulInitPropRes!")
end
def.static("table").OnSPetSoulInitPropErrorRes = function(p)
  warn("[PetSoulProtocols:OnSPetSoulInitPropErrorRes] On SPetSoulInitPropErrorRes! p.ret:", p.ret)
  local SPetSoulInitPropErrorRes = require("netio.protocol.mzm.gsp.pet.SPetSoulInitPropErrorRes")
  local errString
  if SPetSoulInitPropErrorRes.ERROR_NO_PROP == p.ret then
    errString = textRes.Pet.Soul.INIT_FAIL_WRONG_POS
  else
    warn("[ERROR][PetSoulProtocols:OnSPetSoulInitPropErrorRes] unhandled p.ret:", p.ret)
  end
  if errString then
    Toast(errString)
  end
end
def.static("userdata", "number", "number", "number").SendCPetSoulAddExpReq = function(petId, pos, itemId, isUseAll)
  warn("[PetSoulProtocols:SendCPetSoulRandomPropReq] Send CPetSoulAddExpReq:", Int64.tostring(petId), pos, itemId, isUseAll)
  local p = require("netio.protocol.mzm.gsp.pet.CPetSoulAddExpReq").new(petId, pos, itemId, isUseAll)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSPetSoulAddExpRes = function(p)
  warn("[PetSoulProtocols:OnSPetSoulAddExpRes] On SPetSoulAddExpRes!")
end
def.static("table").OnSPetSoulAddExpErrorRes = function(p)
  warn("[PetSoulProtocols:OnSPetSoulAddExpErrorRes] On SPetSoulAddExpErrorRes! p.ret:", p.ret)
  local SPetSoulAddExpErrorRes = require("netio.protocol.mzm.gsp.pet.SPetSoulAddExpErrorRes")
  local errString
  if SPetSoulAddExpErrorRes.ERROR_ITEM_NOT_ENOUGH == p.ret then
    errString = textRes.Pet.Soul.LEVEL_UP_FAIL_LACK_ITEM
  elseif SPetSoulAddExpErrorRes.ERROR_NO_PROP == p.ret then
    errString = textRes.Pet.Soul.LEVEL_UP_FAIL_NO_PROP
  elseif SPetSoulAddExpErrorRes.ERROR_MAX_LEVEL == p.ret then
    errString = textRes.Pet.Soul.LEVEL_UP_FAIL_MAX_LEVEL
  elseif SPetSoulAddExpErrorRes.ERROR_NOT_OVER_PET_LEVEL == p.ret then
    errString = textRes.Pet.Soul.LEVEL_UP_FAIL_OVER_PET_LEVEL
  elseif SPetSoulAddExpErrorRes.ERROR_ITEM_TYPE == p.ret then
    errString = textRes.Pet.Soul.LEVEL_UP_FAIL_WRONG_ITEM
  else
    warn("[ERROR][PetSoulProtocols:OnSPetSoulAddExpErrorRes] unhandled p.ret:", p.ret)
  end
  if errString then
    Toast(errString)
  end
end
def.static("userdata", "number", "number", "number", "userdata").SendCPetSoulRandomPropReq = function(petId, pos, isUseYuanbao, useYuanBaoNum, totalYuanBaoNum)
  warn("[PetSoulProtocols:SendCPetSoulRandomPropReq] Send CPetSoulRandomPropReq:", Int64.tostring(petId), pos, isUseYuanbao, useYuanBaoNum, Int64.tostring(totalYuanBaoNum))
  local p = require("netio.protocol.mzm.gsp.pet.CPetSoulRandomPropReq").new(petId, pos, isUseYuanbao, useYuanBaoNum, totalYuanBaoNum)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSPetSoulRandomPropRes = function(p)
  warn("[PetSoulProtocols:OnSPetSoulRandomPropRes] On SPetSoulRandomPropRes!")
end
def.static("table").OnSPetSoulRandomPropErrorRes = function(p)
  warn("[PetSoulProtocols:OnSPetSoulRandomPropErrorRes] On SPetSoulRandomPropErrorRes! p.ret:", p.ret)
  local SPetSoulRandomPropErrorRes = require("netio.protocol.mzm.gsp.pet.SPetSoulRandomPropErrorRes")
  local errString
  if SPetSoulRandomPropErrorRes.ERROR_ITEM_NOT_ENOUGH == p.ret then
    errString = textRes.Pet.Soul.RANDOM_FAIL_LACK_ITEM
  elseif SPetSoulRandomPropErrorRes.ERROR_MONEY_NOT_ENOUGH == p.ret then
    errString = textRes.Pet.Soul.RANDOM_FAIL_LACK_YB
  elseif SPetSoulRandomPropErrorRes.ERROR_DO_DO_NOT_HAS_OTHER_PROP == p.ret then
    errString = textRes.Pet.Soul.RANDOM_FAIL_NO_OTHER_PROP
  else
    warn("[ERROR][PetSoulProtocols:OnSPetSoulRandomPropErrorRes] unhandled p.ret:", p.ret)
  end
  if errString then
    Toast(errString)
  end
end
def.static("userdata", "userdata", "number", "number", "userdata").SendCPetSoulExchangeReq = function(petAId, petBId, isUseYuanbao, useYuanBaoNum, totalYuanBaoNum)
  warn("[PetSoulProtocols:SendCPetSoulExchangeReq] Send CPetSoulExchangeReq:", Int64.tostring(petAId), Int64.tostring(petBId), isUseYuanbao, useYuanBaoNum, Int64.tostring(totalYuanBaoNum))
  local p = require("netio.protocol.mzm.gsp.pet.CPetSoulExchangeReq").new(petAId, petBId, isUseYuanbao, useYuanBaoNum, totalYuanBaoNum)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSPetSoulExchangeRes = function(p)
  warn("[PetSoulProtocols:OnSPetSoulExchangeRes] On SPetSoulExchangeRes!")
  require("Main.Pet.soul.PetSoulMgr").Instance():PlayExchangeEffect()
end
def.static("table").OnSPetSoulExchangeErrorRes = function(p)
  warn("[PetSoulProtocols:OnSPetSoulExchangeErrorRes] On SPetSoulExchangeErrorRes! p.ret:", p.ret)
  local SPetSoulExchangeErrorRes = require("netio.protocol.mzm.gsp.pet.SPetSoulExchangeErrorRes")
  local errString
  if SPetSoulExchangeErrorRes.ERROR_MONEY_NOT_ENOUGH == p.ret then
    errString = textRes.Pet.Soul.EXCHANGE_FAIL_LACK_YB
  elseif SPetSoulExchangeErrorRes.ERROR_NOT_OVER_PET_LEVEL == p.ret then
    errString = textRes.Pet.Soul.EXCHANGE_FAIL_OVER_PET_LEVEL
  elseif SPetSoulExchangeErrorRes.ERROR_ITEM_NOT_ENOUGH == p.ret then
    errString = textRes.Pet.Soul.EXCHANGE_FAIL_LACK_ITEM
  else
    warn("[ERROR][PetSoulProtocols:OnSPetSoulExchangeErrorRes] unhandled p.ret:", p.ret)
  end
  if errString then
    Toast(errString)
  end
end
PetSoulProtocols.Commit()
return PetSoulProtocols
