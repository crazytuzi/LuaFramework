
local srolevipinfo = require "protocoldef.knight.gsp.battle.srolevipinfo"
function srolevipinfo:process()
	require "ui.vip.vipmanager"
	LogInsane("srolevipinfo process")
	local vipcdtime = {}
	local vipFlag = {}
	vipFlag["vip1"] = self.flag1
	vipFlag["vip2"] = self.flag2
	vipFlag["vip3"] = self.flag3
	vipcdtime["vip1"] = self.vip1cdtime
	vipcdtime["vip2"] = self.vip2cdtime
	vipcdtime["vip3"] = self.vip3cdtime

	VipManager.getInstance():SetInfo(self.level, self.vipremaintime, vipFlag, vipcdtime)
end

local svipbuy = require "protocoldef.knight.gsp.battle.svipbuy"
function svipbuy:process()
	require "ui.vip.vipmanager"
	LogInsane("svipbuy process")
	VipManager.getInstance():BuyFubenTime(self.serverid, self.yuanbao)
end

local saskvipdrop = require "protocoldef.knight.gsp.battle.saskvipdrop"
function saskvipdrop:process()
	require "ui.vip.vipmanager"
	LogInsane("saskvipdrop process")
	VipManager.getInstance():AskVipDrop(self.yuanbao, self.viplevel)	
end

local saskvipproduct = require "protocoldef.knight.gsp.battle.saskvipproduct"

function saskvipproduct:process()
	require "ui.vip.vipmanager"
	LogInsane("saskvipproduct process")
	VipManager.getInstance():AskVipProduct(self.yuanbao, self.productid)

end 

local scampbattlescore = require "protocoldef.knight.gsp.battle.scampbattlescore"
function scampbattlescore:process()
	require "ui.camp.campvs"	
	CampVS.getInstance():FreshScore(self.tribescore, self.leaguescore, self.remaintime)
end

local scampbattlerank = require "protocoldef.knight.gsp.battle.scampbattlerank"
function scampbattlerank:process()
	require "ui.camp.campvs"	
	CampVS.getInstance():FreshRank(self.triberecordlist, self.leaguerecordlist)
end

local scampbattlereadyfight = require "protocoldef.knight.gsp.battle.scampbattlereadyfight"
function scampbattlereadyfight:process()
	LogInsane("scampbattlereadyfight process")
	require "ui.camp.campvs"	
	if CampVS.getInstanceNotCreate() then
		CampVS.getInstanceNotCreate():FreshJoinBtn(self.ready)
	end
end

local scampbattlestart = require "protocoldef.knight.gsp.battle.scampbattlestart"
function scampbattlestart:process()
	LogInsane("scampbattlestart process")
	require "ui.camp.campvsentrance"
	require "ui.camp.campvsmessage"
	if self.flag == 1 then
		CampVSEntrance.getInstanceAndShow()
		if GetBattleManager():IsInBattle() then
			CampVSEntrance.getInstanceNotCreate():GetWindow():setVisible(false)
		end
	elseif self.flag == 2 then
		CampVSMessage.Destroy()
		CampVSEntrance.DestroyDialog()
	end
end

local scampbattledrag = require "protocoldef.knight.gsp.battle.scampbattledrag"
function scampbattledrag:process()
	LogInsane("scampbattledrag process")
	require "ui.camp.campvsentrance"
	GetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_msgtipstring(145257),CampVSEntrance.HandleStart, self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
end

local scampbattleselfinfo = require "protocoldef.knight.gsp.battle.scampbattleselfinfo"
function scampbattleselfinfo:process()
	LogInsane("scampbattleselfinfo process")
	require "ui.camp.campvs"	
	CampVS.getInstance():FreshSelfInfo(self.wintimes, self.losttimes, self.comwin, self.score, self.encouragepercent)
end

local ssendcampbattleinfo = require "protocoldef.knight.gsp.battle.ssendcampbattleinfo"
function ssendcampbattleinfo:process()
	LogInsane("ssendcampbattleinfo process")
	require "ui.camp.campvsmessage"
	CampVSMessage.getInstance():AddMessage(self.ismine, self.flag, self.rolename1, self.camp1, self.rolename2, self.camp2, self.comwin)
end

local sracebattleresult = require "protocoldef.knight.gsp.battle.sracebattleresult"
function sracebattleresult:process()
	LogInsane("sracebattleresult process")
	local PVPServiceSeasonEndDlg = require "ui.teampvp.pvpserviceseasonenddlg"
	if PVPServiceSeasonEndDlg.getInstanceNotCreate() then
		PVPServiceSeasonEndDlg.getInstanceNotCreate():Refresh(self.wintimes, self.losetimes)
	end
end

local sRaceRemainNumbers = require "protocoldef.knight.gsp.battle.sraceremainnumbers"
function sRaceRemainNumbers:process()
	LogInsane("sraceremainnumbers process")
	local PVPServiceSeasonEndDlg = require "ui.teampvp.pvpserviceseasonenddlg"
	if self.flag == 0 then -- refresh ui
		if PVPServiceSeasonEndDlg.getInstanceNotCreate() then
			PVPServiceSeasonEndDlg.getInstanceNotCreate():RefreshRemainNumber(self.rolenum)
		end
	elseif self.flag == 1 then -- confirm dlg
		local str = MHSD_UTILS.get_msgtipstring(145951)
		local sb = StringBuilder.new()
		sb:SetNum("parameter1", self.rolenum)
		GetMessageManager():AddConfirmBox(eConfirmNormal, sb:GetString(str), self.handleExit
			, self, CMessageManager.HandleDefaultCancelEvent, CMessageManager)
	end
end

function sRaceRemainNumbers:handleExit()
	local p = require "protocoldef.knight.gsp.battle.cexitscence" : new()
    require "manager.luaprotocolmanager":send(p)
    GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end

