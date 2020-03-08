local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleAddFriendToQQ = Lplus.Extend(PubroleOperationBase, "PubroleAddFriendToQQ")
local FriendModule = Lplus.ForwardDeclare("FriendModule")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local def = PubroleAddFriendToQQ.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  if ClientCfg.GetSDKType() ~= ClientCfg.SDKTYPE.MSDK then
    return false
  end
  local ECMSDK = require("ProxySDK.ECMSDK")
  if not ECMSDK.IsAddGameFriendToQQAvailable() then
    return false
  end
  if FriendModule.Instance():GetFriendInfo(roleInfo.roleId) and roleInfo.deleteState == RoleDeleteStatus.STATE_NORMAL then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.PubRole[1000]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  local ECMSDK = require("ProxySDK.ECMSDK")
  local openid = roleInfo.openId
  if openid == nil then
    warn("Need target's openid!!!")
    return true
  end
  local desc = string.format(textRes.PubRole[7], roleInfo.name)
  local myHeroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local message = string.format(textRes.PubRole[8], roleInfo.name, myHeroProp.name)
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.ADDQQFRIEND, {
    openid,
    roleInfo.roleId:tostring(),
    roleInfo.level
  })
  ECMSDK.AddGameFriendToQQ(openid, desc, message)
  return true
end
PubroleAddFriendToQQ.Commit()
return PubroleAddFriendToQQ
