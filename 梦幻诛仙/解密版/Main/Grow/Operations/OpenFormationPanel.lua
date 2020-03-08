local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenFormationPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenFormationPanel.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local teamData = require("Main.Team.TeamData").Instance()
  local formationId = -1
  if teamData:HasTeam() then
    formationId = teamData.formationId
  else
    local partnerInterface = require("Main.partner.PartnerInterface").Instance()
    local defaultLineUpNum = partnerInterface:GetDefaultLineUpNum()
    local LineUp = partnerInterface:GetLineup(defaultLineUpNum)
    if LineUp ~= nil then
      formationId = LineUp.zhenFaId
    end
  end
  gmodule.moduleMgr:GetModule(ModuleId.FORMATION):ShowFormationDlg(formationId, formationId, function(id)
    if id <= 0 then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CReqCloseZhenfa").new())
    else
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CReqOpenZhenfa").new(id))
    end
  end)
  return false
end
return OpenFormationPanel.Commit()
