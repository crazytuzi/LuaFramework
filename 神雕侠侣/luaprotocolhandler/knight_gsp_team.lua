local sformationsmap = require "protocoldef.knight.gsp.team.sformationsmap"
function sformationsmap:process()
	LogInsane("sformationsmap process")
	local manager = FormationManager.getInstance()
	manager:updateFormations(self.formationmap)
end

local ssetmyformation = require "protocoldef.knight.gsp.team.ssetmyformation"
function ssetmyformation:process()
	LogInsane("ssetmyformation process")
	local manager = FormationManager.getInstance()
	manager:setMyFormation(self.formation, self.entersend)
end

local ssetteamformation = require "protocoldef.knight.gsp.team.ssetteamformation"
function ssetteamformation:process()
	LogInsane("ssetteamformation process")
	local manager = FormationManager.getInstance()
	manager:setTeamFormation(self.formation, self.formationlevel, self.msg)
end

local sbjdata = require "protocoldef.knight.gsp.team.bianjie.sbjdata"
function sbjdata:process()
    LogInfo("____sbjdata:process")
	require "ui.quickteam.quickteamdlg"
    
    local dlgQuickTeam = QuickTeamDlg.getInstanceNotCreate()
    if not dlgQuickTeam then
        dlgQuickTeam = QuickTeamDlg.getInstanceAndShow()
    end

    if dlgQuickTeam then
        dlgQuickTeam:RefreshListPage(self.serviceid, self.oldserviceid, self.totalnum, self.inqueue, self.startindex, self.bjdata)
    end
end
