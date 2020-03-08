local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubrolePlayerPK = Lplus.Extend(PubroleOperationBase, "PubrolePlayerPK")
local def = PubrolePlayerPK.define
local PKMgr = require("Main.PlayerPK.PKMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local const = constant.CPKConsts
local txtConst = textRes.PlayerPK.PK
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  if not PKMgr.IsFeatureOpen() then
    return false
  end
  if roleInfo.level < const.ENABLE_PK_LEVEL then
    return false
  end
  local teamData = require("Main.Team.TeamData").Instance()
  local teamMems = teamData:GetAllTeamMembers()
  for _, memInfo in pairs(teamMems) do
    if memInfo.roleid:eq(roleInfo.roleId) then
      return false
    end
  end
  local pubroleModule = require("Main.Pubrole.PubroleModule").Instance()
  local role = pubroleModule:GetRole(roleInfo.roleId)
  if role ~= nil then
    local bCanPK = not role:IsInState(_G.RoleState.BATTLE)
    return bCanPK
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.PlayerPK.PK[37]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  if not PKMgr.IsFeatureOpen() then
    return true
  end
  local role = require("Main.Pubrole.PubroleModule").Instance():GetRole(roleInfo.roleId)
  if role == nil then
    Toast(textRes.PlayerPK.PK[38])
    return true
  end
  local mapId = require("Main.Map.MapModule").Instance():GetMapId()
  local mapCfg = require("Main.Map.MapUtility").GetMapCfg(mapId)
  if not mapCfg.canPK then
    Toast(txtConst[15])
    return true
  end
  if _G.PlayerIsInState(_G.RoleState.BATTLE) then
    Toast(txtConst[40])
    return true
  elseif _G.PlayerIsInState(_G.RoleState.PLAYER_PK_FORCE_PROTECTION) then
    Toast(txtConst[41])
    return true
  elseif not _G.PlayerIsInState(_G.RoleState.PLAYER_PK_ON) then
    Toast(txtConst[42])
    return true
  end
  local teamData = require("Main.Team.TeamData").Instance()
  if teamData:HasTeam() and not teamData:MeIsCaptain() then
    local teamMems = teamData:GetAllTeamMembers()
    local idx = teamData:GetMemberIndex(require("Main.Hero.HeroModule").Instance().roleId)
    local mine = teamMems[idx]
    if mine.status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_NORMAL then
      Toast(txtConst[76])
      return true
    end
  end
  local strContent = txtConst[39]:format(roleInfo.name)
  CommonConfirmDlg.ShowConfirm(txtConst[37], strContent, function(select)
    if select == 1 then
      PKMgr.GetProtocols().SendCStartPKReq(roleInfo.roleId)
    end
  end, nil)
  return true
end
return PubrolePlayerPK.Commit()
