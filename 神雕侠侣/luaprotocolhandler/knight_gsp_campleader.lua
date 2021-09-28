local p = require "protocoldef.knight.gsp.campleader.scampaignlist"
function p:process()
	LogInfo("enter knight.gsp.campleader.scampaignlist process")
	local dlg = require "ui.camp.campleaderdlg"
	dlg.getInstanceAndShow():RefreshList(self.campaignroles)
end

local p = require "protocoldef.knight.gsp.campleader.sopensearch"
function p:process()
	LogInfo("enter knight.gsp.campleader.sopensearch process")
	local dlg = require "ui.camp.campleaderpowerdlg"
	dlg.getInstanceAndShow()
end

local p = require "protocoldef.knight.gsp.campleader.ssearchroleinfo"
function p:process()
	LogInfo("enter knight.gsp.campleader.ssearchroleinfo process")
	local dlg = require "ui.camp.campleaderpowerdlg"
	if dlg.getInstanceNotCreate() then
		dlg.getInstanceNotCreate():Init(self.searchrole)
	end
end

local p = require "protocoldef.knight.gsp.campleader.scampthreeopen"
function p:process()
	LogInfo("enter knight.gsp.campleader.scampthreeopen process")
	local dlg = require "ui.camp.camprichdlg"
	if self.isopen == 0 then
		if dlg.getInstanceNotCreate() then
			dlg.DestroyDialog()
		end
	else
		dlg.getInstanceAndShow()
	end
end

local p = require "protocoldef.knight.gsp.campleader.sfoundinfo"
function p:process()
	local CampLeaderMoneyDlg = require "ui.camp.campleadermoneydlg"
--	if CampLeaderMoneyDlg.getInstanceNotCreate() then
--		CampLeaderMoneyDlg.getInstanceNotCreate():Refresh(self.foundmoney, self.returnmoney)
--	end
	CampLeaderMoneyDlg.getInstanceAndShow():Refresh(self.foundmoney, self.returnmoney)
end

local p = require "protocoldef.knight.gsp.campleader.sconfirmvote"
function p:process()
	local CampLeaderDlgCell = require "ui.camp.campleaderdlgcell"
	CampLeaderDlgCell.ConfirmMoney(self.truemoney)
end

local p = require "protocoldef.knight.gsp.campleader.snotifyneedyuanbao"
function p:process()
	local CampBulletinDlg = require "ui.camp.campbulletindlg"
	CampBulletinDlg.getInstanceAndShow():Refresh(self.needyuanbao)
end
