local Lplus = require("Lplus")
local RoleState = _G.RoleState
local IsPlayerInState = _G.PlayerIsInState
local function IsPlayerNotInState(state)
  return not IsPlayerInState(state)
end
local function IsPlayerOutOfDungeon()
  local DungeonModule = Lplus.ForwardDeclare("DungeonModule")
  return DungeonModule.Instance().State == DungeonModule.DungeonState.OUT
end
local HeroBehaviorDefine = {
  WorldMapTransfer = {
    errorMsg = textRes.Map[11],
    {
      func = IsPlayerNotInState,
      params = {
        RoleState.JZJX
      },
      errorMsg = nil
    },
    {
      func = IsPlayerNotInState,
      params = {
        RoleState.PHANTOMCAVE
      },
      errorMsg = nil
    },
    {
      func = IsPlayerOutOfDungeon,
      params = {},
      errorMsg = textRes.Map[10]
    },
    {
      func = IsPlayerNotInState,
      params = {
        RoleState.CROSS_BATTLE
      }
    },
    {
      func = function()
        return not require("Main.PlayerPK.PrisonMgr").Instance():IsInPrisonMap()
      end,
      params = {}
    }
  },
  OpenMiniMap = {
    errorMsg = textRes.Map[12],
    {
      func = IsPlayerNotInState,
      params = {
        RoleState.JZJX
      }
    },
    {
      func = IsPlayerNotInState,
      params = {
        RoleState.PHANTOMCAVE
      }
    },
    {
      func = IsPlayerOutOfDungeon,
      params = {},
      errorMsg = textRes.Map[13]
    },
    {
      func = IsPlayerNotInState,
      params = {
        RoleState.CROSS_BATTLE
      }
    }
  }
}
local HeroTransportState = {
  [RoleState.RUN] = {ALL = true},
  [RoleState.FLY] = {ALL = true},
  [RoleState.PVP] = {
    ["ALL"] = false,
    [RoleState.PVP] = true
  },
  [RoleState.PATROL] = {
    ["ALL"] = false,
    [RoleState.PATROL] = true
  },
  [RoleState.ESCORT] = {
    ["ALL"] = false,
    [RoleState.ESCORT] = true
  },
  [RoleState.BATTLE] = {
    ["ALL"] = false,
    [RoleState.BATTLE] = true
  },
  [RoleState.TXHW] = {
    ["ALL"] = false,
    [RoleState.TXHW] = true
  },
  [RoleState.WATCH] = {
    ["ALL"] = false,
    [RoleState.WATCH] = true
  },
  [RoleState.SXZB] = {
    ["ALL"] = false,
    [RoleState.SXZB] = true
  },
  [RoleState.JZJX] = {
    ["ALL"] = false,
    [RoleState.JZJX] = true
  },
  [RoleState.GANGBATTLE] = {
    ["ALL"] = false,
    [RoleState.GANGBATTLE] = true
  },
  [RoleState.PHANTOMCAVE] = {
    ["ALL"] = false,
    [RoleState.PHANTOMCAVE] = true
  },
  [RoleState.PROTECTED] = {ALL = true},
  [RoleState.FOLLOW] = {
    ["ALL"] = false,
    [RoleState.FOLLOW] = true
  },
  [RoleState.SOLODUNGEON] = {
    ["ALL"] = false,
    [RoleState.SOLODUNGEON] = true
  },
  [RoleState.TEAMDUNGEON] = {
    ["ALL"] = false,
    [RoleState.TEAMDUNGEON] = true
  },
  [RoleState.WEDDING] = {ALL = false},
  [RoleState.HULA] = {ALL = false},
  [RoleState.ZHUXIANJIANZHEN] = {ALL = false},
  [RoleState.CROSS_BATTLE] = {ALL = false},
  [RoleState.GANGCROSS_BATTLE] = {
    ["ALL"] = false,
    [RoleState.GANGCROSS_BATTLE] = true
  }
}
function HeroBehaviorDefine.IsAllowTo(behavior)
  local defs = HeroBehaviorDefine[behavior]
  if defs == nil then
    warn(string.format("Behavior[%s] not define.", tostring(behavior)), debug.traceback())
    return false
  end
  for i, def in ipairs(defs) do
    if def.func(unpack(def.params)) == false then
      return false, def.errorMsg or defs.errorMsg or "unknow error"
    end
  end
  return true
end
local function IsIdleState()
  local myRole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  for k, v in pairs(RoleState) do
    if myRole:IsInState(v) then
      return false
    end
  end
  return true
end
function HeroBehaviorDefine.CanTransport2TargetState(targetState)
  local myRole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if nil == myRole then
    return false
  end
  if IsIdleState() then
    return true
  end
  for k, v in pairs(RoleState) do
    if myRole:IsInState(v) then
      warn("tranState~~~~ ", k, v, myRole:IsInState(v))
      local tranState = HeroTransportState[v]
      if tranState and not tranState.ALL and not tranState[targetState] then
        return false
      end
    end
  end
  return true
end
return HeroBehaviorDefine
