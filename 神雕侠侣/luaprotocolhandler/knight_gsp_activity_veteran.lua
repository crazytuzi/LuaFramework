local p = require "protocoldef.knight.gsp.activity.veteran.smasterroad"
function p:process()
	require("ui.zhaohuilaowanjia.heroeswaysdlg").getInstanceAndShow():process(self.veteran,self.tasks)
end

local p = require "protocoldef.knight.gsp.activity.veteran.sveteran"
function p:process()
	if not GetBattleManager():IsInBattle() then
		require("ui.zhaohuilaowanjia.characterreturninsetdlg").getInstanceAndShow():process(self.status)
	end
end

local p = require "protocoldef.knight.gsp.activity.veteran.ssummonveteran"
function p:process()
	require("ui.zhaohuilaowanjia.armsrecalldlg").getInstanceAndShow():process(self.invitations,self.invitationsawards)
end


local p = require "protocoldef.knight.gsp.activity.veteran.sveteranaward"
function p:process()
	if self.taskid == 0 then
		if 	require("ui.zhaohuilaowanjia.characterreturninsetdlg").getInstanceNotCreate() then
			require("ui.zhaohuilaowanjia.characterreturninsetdlg").getInstanceNotCreate():process(2)
		end
	else
		require("ui.zhaohuilaowanjia.heroeswaysdlg").getInstanceAndShow():processGetAwardNotify(self.taskid)
	end
end


local p = require "protocoldef.knight.gsp.activity.veteran.sinvitationaward"
function p:process()
    if require("ui.zhaohuilaowanjia.armsrecalldlg").getInstanceNotCreate() then
				require("ui.zhaohuilaowanjia.armsrecalldlg").getInstanceNotCreate():respond(self.sn) 
    end
end




