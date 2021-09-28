local function getJianghuLable()
	return require "ui.label".getLabelById("jianghu")
end

local function afterRequestFactiondata()
--[[
	local dlg = ContactRoleDialog.getInstanceNotCreate()
	if dlg and dlg.invite_faction_co and coroutine.status(dlg.invite_faction_co) ~= "dead" then
		local status, error = coroutine.resume(dlg.invite_faction_co)
		if not status then
			LogErr(error)
			assert(false)
		end
	end
	--]]
	local dlg = CCharacterPropertyDlg:GetSingleton()
	if dlg then
		local datamanager = require "ui.faction.factiondatamanager"
		if datamanager.factionid and datamanager.factionid ~= 0 then
			dlg:SetFamilyName(CEGUI.String(datamanager.factionname))
		else
			local str = require "utils.mhsdutils".get_resstring(510)
			dlg:SetFamilyName(CEGUI.String(str))
		end
	end
	require "ui.rank.rankinglist"
	if RankingList.getInstanceNotCreate() then
		local datamanager = require "ui.faction.factiondatamanager"
		RankingList.getInstanceNotCreate().m_iFactionID = datamanager.factionid 
	end
end

local p = require "protocoldef.knight.gsp.faction.sopenfactionnocamp"
function p:process()
	local datamanager = require "ui.faction.factiondatamanager"
	datamanager.factionid = 0
	datamanager.campid = 0
	afterRequestFactiondata()
end

p = require "protocoldef.knight.gsp.faction.sopenfactionnofaction"
function p:process()
	local datamanager = require "ui.faction.factiondatamanager"
	datamanager.factionid = 0
	datamanager.campid = p.camp
	datamanager.factions = {}
	for i = 1, #self.factionlist do
		local faction = self.factionlist[i]
		local dfaction = {}
		dfaction.factionid = faction.factionid
		dfaction.factionlevel = faction.factionlevel
		dfaction.factionmasterid = faction.factionmasterid
		dfaction.factionmastername = faction.factionmastername
		dfaction.factionname = faction.factionname
		dfaction.membernum = faction.membernum
		dfaction.index = faction.index
		table.insert(datamanager.factions, dfaction)
	end
	table.sort(datamanager.factions, function(v1, v2) 
		return v1.index < v2.index
	end)
	afterRequestFactiondata()
end

p = require "protocoldef.knight.gsp.faction.sopenfaction"
function p:process()
	local datamanager = require "ui.faction.factiondatamanager"
	datamanager.campid = self.camp
	datamanager.factionid = self.factionid
	datamanager.factionname = self.factionname
	datamanager.factionlevel = self.factionlevel
	datamanager.membersum = self.membersum
	datamanager.factionmaster = self.factionmaster
	datamanager.factionaim = self.factionaim
	datamanager.buildlevel = self.buildlevel
	datamanager.index = self.index
	datamanager.members = {}
	if self.memberlist then
		for i = 1, #self.memberlist do
			local member = self.memberlist[i]
			table.insert(datamanager.members, member)
		end
	end
	table.sort(datamanager.members, function(v1, v2)
		if v1.lastonlinetime == 0 and v2.lastonlinetime ~= 0 then
			return true
		end
		if v2.lastonlinetime == 0 and v1.lastonlinetime ~= 0 then
			return false
		end
		return v1.position < v2.position
	end)

	local dlg = require "ui.faction.factionfoundcheck".getInstanceOrNot()
	if dlg and dlg.create_co and coroutine.status(dlg.create_co) ~= "dead" then
		coroutine.resume(dlg.create_co, true)
	end
	
	afterRequestFactiondata()
end

p = require "protocoldef.knight.gsp.faction.srequestapplicantlist2"
function p:process()
	local dlg = require "ui.faction.factionaccept".getInstanceOrNot()
	if dlg then
		dlg:ProcessList(self.applicantlist)
	end
	dlg = require "ui.maincontrol".getInstanceNotCreate()
	if dlg then
		dlg.m_pFactionMark:setVisible(require "utils.tableutil".tablelength(self.applicantlist)~=0)
	end
	dlg = require "ui.faction.factionmain".getInstanceOrNot()
	if dlg then
		dlg.m_pApplyMark:setVisible(require "utils.tableutil".tablelength(self.applicantlist)~=0)
	end
end

p = require "protocoldef.knight.gsp.faction.sleavefaction2"
function p:process()
  local p = require "protocoldef.knight.gsp.faction.copenfaction":new()
  require "manager.luaprotocolmanager".getInstance():send(p)
  
	local dlg = require "ui.faction.factionmain".getInstanceOrNot()
	if dlg and dlg.leavefaction_co and coroutine.status(dlg.leavefaction_co) ~= "dead" then
		local status, error = coroutine.resume(dlg.leavefaction_co)
		if not status then
			LogErr(error)
			assert(false)
		end
	end
end

p = require "protocoldef.knight.gsp.faction.sfiremember"
function p:process()
	local dlg = require "ui.faction.factionmain".getInstanceOrNot()
	if dlg then
		dlg:RemoveApplicant(self.memberroleid)
	end
end

p = require "protocoldef.knight.gsp.faction.sacceptapplication"
function p:process()
	local datamanager = require "ui.faction.factiondatamanager"
	datamanager.addMember(self.memberinfo)
	local dlg = require "ui.faction.factionaccept".getInstanceOrNot()
	if dlg then
		dlg:RemoveApplicant(self.memberinfo.roleid)
		local count = dlg.m_pApplyList:getRowCount()
		dlg = require "ui.maincontrol".getInstanceNotCreate()
		if dlg then
			dlg.m_pFactionMark:setVisible(count ~= 0)
		end
		dlg = require "ui.faction.factionmain".getInstanceOrNot()
		if dlg then
			dlg.m_pApplyMark:setVisible(count ~= 0)
		end
	end
	dlg = require "ui.faction.factionmain".getInstanceOrNot()
	if dlg then
		dlg:AddApplicant(self.memberinfo)
	end
end

p = require "protocoldef.knight.gsp.faction.srefuseapplication"
function p:process()
	local datamanager = require "ui.faction.factiondatamanager"
	datamanager.removeMember(self.applicantroleid)
	local dlg = require "ui.faction.factionaccept".getInstanceOrNot()
	if dlg then
		dlg:RemoveApplicant(self.applicantroleid)
		local count = dlg.m_pApplyList:getRowCount()
		dlg = require "ui.maincontrol".getInstanceNotCreate()
		if dlg then
			dlg.m_pFactionMark:setVisible(count ~= 0)
		end
		dlg = require "ui.faction.factionmain".getInstanceOrNot()
		if dlg then
			dlg.m_pApplyMark:setVisible(count ~= 0)
		end
	end
end

p = require "protocoldef.knight.gsp.faction.schangefactionaim"
function p:process()
	local datamanager = require "ui.faction.factiondatamanager"
	datamanager.factionaim = self.newaim
	local dlg = require "ui.faction.factionmain".getInstanceOrNot()
	if dlg then
		dlg.m_pFactionBroad:setText(datamanager.factionaim)
	end
end

p = require "protocoldef.knight.gsp.faction.sopenexchangefaction"
function p:process()
	local datamanager = require "ui.faction.factiondatamanager"
	datamanager.exchangemax = self.exchangemax
	datamanager.currentcontribution = self.currentcontribution
	datamanager.buildlevel = self.buildlevel
	local dlg = require "ui.faction.factiontrack".getInstanceAndShowIt()
	dlg:RefreshData()
end

p = require "protocoldef.knight.gsp.faction.sfactionmessage"
function p:process()
	local dlg = require "ui.faction.factionmessage".GetSingletonDialogAndShowIt()
end

p = require "protocoldef.knight.gsp.faction.spositionresponse"
function p:process()
	local datamanager = require "ui.faction.factiondatamanager"
	if not datamanager.positions then datamanager.positions = {} end
	datamanager.positions[self.roleid] = self.position
	if self.roleid == GetDataManager():GetMainCharacterID() then
		local dlg = require "ui.faction.factionmain".getInstanceOrNot()
		if dlg then
			dlg:OnPositionChange()
		end
	end
end

p = require "protocoldef.knight.gsp.faction.changlong.srequestchanglong"
function p:process()
	local dlg = require "ui.faction.factiontask":GetSingletonDialogAndShowIt()
	dlg:initdata(self.starlevel, self.availnum, self.tasks, self.availtasknum)
end

p = require "protocoldef.knight.gsp.faction.changlong.sacceptchanglong"
function p:process()
	local dlg = require "ui.faction.factiontask":getInstanceOrNot()
	if dlg and dlg.accepttaskco and coroutine.status(dlg.accepttaskco) ~= "dead" then
		coroutine.resume(dlg.accepttaskco, self.result == 1)
	end
end

p = require "protocoldef.knight.gsp.faction.changlong.srefreshstartlevel"
function p:process()
	local dlg = require "ui.faction.factiontask":getInstanceOrNot()
	if dlg then
		dlg:AppendStar(self.starlevel, true)
		dlg:RefreshLeftnum(self.availnum)
		dlg:RefreshTaskReward(self.starlevel)
	end
end

p = require "protocoldef.knight.gsp.faction.sfactioninvitation"
local confirmtype, hostroleid
local function acceptfactioninvitation()
	if confirmtype then
		GetMessageManager():CloseConfirmBox(confirmtype, false)
		confirmtype = nil
	end
	if not hostroleid then
		return
	end
	local send = require "protocoldef.knight.gsp.faction.cacceptorrefuseinvitation":new()
	send.hostroleid = hostroleid
	send.accept = 1
	require "manager.luaprotocolmanager":send(send)
	hostroleid = nil
end
function p:process()
	local formatstr = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(145034).msg
	local sb = require "utils.stringbuilder":new()
	sb:Set("parameter1", self.hostrolename)
	sb:Set("parameter2", self.factionname)
	sb:SetNum("parameter3", self.factionlevel)
	hostroleid = self.hostroleid
	confirmtype = MHSD_UTILS.addConfirmDialog(sb:GetString(formatstr), acceptfactioninvitation)
    sb:delete()
end

p = require "protocoldef.knight.gsp.faction.sfactionaim"
function p:process()
	local datamanager = require "ui.faction.factiondatamanager"
	if not datamanager.factions then
		datamanager.factions = {}
	end
	local dfaction
	for i = 1, #datamanager.factions do
		if datamanager.factions[i].factionid == self.factionid then
			dfaction = datamanager.factions[i]
			break
		end
	end
	if not dfaction then
		dfaction = {factionid = self.factionid}
		table.insert(dfaction, datamanager.factions)
	end
	dfaction.aim = self.factionaim
	local dlg = require "ui.faction.familyfound":getInstanceOrNot()
	if dlg then
		dlg.m_pFactionIntroduce:setText(self.factionaim)
	end
end

p = require "protocoldef.knight.gsp.faction.srefreshfactiondata"
local function refreshFactionContribute(v)
	local datamanager = require "ui.faction.factiondatamanager"
	if datamanager.members then
		local roleid = GetDataManager():GetMainCharacterID()
		for i = 1, #datamanager.members do
			if datamanager.members[i].roleid == roleid then
				datamanager.members[i].rolecontribution = v
				break
			end
		end
	end
	local dlg = require "ui.faction.factionxiulian":getInstanceOrNot()
	if dlg then
		dlg.m_pContribute:setText(v)
	end
end
function p:process()
	local datatype = require "protocoldef.rpcgen.knight.gsp.faction.datatype":new()
	for k,v in pairs(self.data) do
		if k == datatype.MEMBER_CONTRI then
			refreshFactionContribute(v)
		end
	end
end

p = require "protocoldef.knight.gsp.faction.spreunfreezecontribution"
local confirmtype
local function confirmUnfreezeContribution()
	if confirmtype then
		GetMessageManager():CloseConfirmBox(confirmtype, false)
		confirmtype = nil
	end
	local send = require "protocoldef.knight.gsp.faction.crequnfreezecontribution":new()
	require "manager.luaprotocolmanager":send(send)
end
function p:process()
	local formatstr = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(145177).msg
	local sb = require "utils.stringbuilder":new()
	sb:Set("parameter1", self.yuanbaonum or "??")
	confirmtype = require "utils.mhsdutils".addConfirmDialog(sb:GetString(formatstr), confirmUnfreezeContribution)
    sb:delete()
end

p = require "protocoldef.knight.gsp.faction.sfreshfactionbiaoches"
function p:process()
	require "ui.bandit.bandit"	
	LogInfo("sfreshfactionbiaoches process")
	Bandit.getInstanceAndShow():InitBiaoCheList(self.yunbiaotimes, self.biaoches)
end

p = require "protocoldef.knight.gsp.faction.sfreshbiaoche"
function p:process()
	require "ui.bandit.bandit"
	LogInfo("sfreshbiaoche process")
	Bandit.getInstanceAndShow():freshBiaocheTeam(self.leaderid, self.biaochetype, self.biaoshis)
end

p = require "protocoldef.knight.gsp.faction.sfreshbiaostate"
function p:process()
	require "ui.bandit.bandit"
	LogInfo("sfreshbiaostate process")
	Bandit.getInstanceAndShow():FreshBiaoState(self.remiantime, self.biaochestate)
end

p = require "protocoldef.knight.gsp.faction.sexit"
function p:process()
	require "ui.bandit.bandit"
	require "ui.bandit.banditrubdlg"
	LogInfo("sexit process")
	if self.flag == 0 and Bandit.getInstanceNotCreate() then
		Bandit.getInstanceNotCreate().m_stat = 1
		Bandit.DestroyDialog()
	end
    
    local dlgBanditRub = BanditRubDlg.getInstanceNotCreate()
    if dlgBanditRub then
        dlgBanditRub:ClearDisplay()
    end
    BanditRubDlg.DestroyDialog()
end

local sfreshtotalbiaoches = require "protocoldef.knight.gsp.faction.sfreshtotalbiaoches"
function sfreshtotalbiaoches:process()
	require "ui.bandit.banditrubdlg"
    LogInfo("____sfreshtotalbiaoches:process")
    
    LogInfo("____self.startindex: " .. self.startindex .. " self.totalnum: " .. self.totalnum)
    LogInfo("____self.flag: " .. self.flag .. " self.jiebiaotimes: " .. self.jiebiaotimes)
    
    local dlgBanditRub = BanditRubDlg.getInstanceAndShow()
    if dlgBanditRub then
        dlgBanditRub:RefreshCarList(self.flag, self.totalnum, self.startindex, self.biaoches)
        if self.startindex == 0 then
            dlgBanditRub:RefreshCtRubToday(self.jiebiaotimes)
        end
    end
end

local sfreshfactionjbiaoteams = require "protocoldef.knight.gsp.faction.sfreshfactionjbiaoteams"
function sfreshfactionjbiaoteams:process()
	require "ui.bandit.banditrubdlg"
    LogInfo("____sfreshfactionjbiaoteams:process")
    
    LogInfo("____self.jiebiaotimes: " .. self.jiebiaotimes .. " self.startindex: " .. self.startindex .. " self.totalnum: " .. self.totalnum)
    
    local dlgBanditRub = BanditRubDlg.getInstanceAndShow()
    if dlgBanditRub then
        dlgBanditRub:RefreshRTList(self.totalnum, self.startindex, self.biaoches)
        if self.startindex == 0 then
            dlgBanditRub:RefreshCtRubToday(self.jiebiaotimes)
        end
    end
end

local sfreshjbiaoteam = require "protocoldef.knight.gsp.faction.sfreshjbiaoteam"
function sfreshjbiaoteam:process()
	require "ui.bandit.banditrubdlg"
    LogInfo("____sfreshjbiaoteam:process")
    
    LogInfo("____self.leaderid: " .. self.leaderid)

    local dlgBanditRub = BanditRubDlg.getInstanceNotCreate()
    if dlgBanditRub then
        dlgBanditRub:RefreshMyTeam(self.leaderid, self.teamroles)
    end
end

local snotifybaoming = require "protocoldef.knight.gsp.faction.snotifybaoming"
function snotifybaoming:process()
  LogInfo("snotifybaoming:process")
  require "ui.teampvp.teampvpsignupdlg"
  TeampvpSignupDlg.getInstanceAndShow()
end



local sfeefactionteam = require "protocoldef.knight.gsp.faction.sfeefactionteam"
function sfeefactionteam:process()
  require "utils.mhsdutils"
--args.fee .. "   " .. args.teamname .. "  " .. args.teamName .. " " .. args.leadername
GetMessageManager():AddMessageBox("",MHSD_UTILS.get_msgtipstring(145599),sfeefactionteam.JoinitHandler,sfeefactionteam,sfeefactionteam.RejectitHandler,sfeefactionteam,eMessageNormal,20000,0,0,nil,MHSD_UTILS.get_resstring(1556),MHSD_UTILS.get_resstring(1557))
end

function sfeefactionteam:JoinitHandler(args)
	local p = require "protocoldef.knight.gsp.faction.cagreejoinfactionteam" : new()
	p.result = 0
	require "manager.luaprotocolmanager":send(p)
	if CEGUI.toWindowEventArgs(args).handled ~= 1 then
		GetMessageManager():CloseCurrentShowMessageBox()
	end
end

function sfeefactionteam:RejectitHandler(args)
	local p = require "protocoldef.knight.gsp.faction.cagreejoinfactionteam" : new()
	p.result = 1
	require "manager.luaprotocolmanager":send(p)
	if CEGUI.toWindowEventArgs(args).handled ~= 1 then
		GetMessageManager():CloseCurrentShowMessageBox()
	end
end

local factionteampowerlist = require "protocoldef.knight.gsp.faction.factionteampowerlist"
function factionteampowerlist:process()
  LogInfo("factionteampowerlist:process")
  require "ui.teampvp.teampvplistdlg"
  TeampvpListDlg.getInstanceAndShow():Process(self.trimbleteampowers,self.leagueteampowers,self.selffightpower)
end

local squeryteams = require "protocoldef.knight.gsp.faction.squeryteams"
function squeryteams:process()
  LogInfo("squeryteams:process")
  require "ui.teampvp.teampvpmaindlg"
  TeampvpMainDlg.getInstanceAndShow():Process(self.trimbleteams,self.leagueteams,self.nexttime,self.leagueteamid,self.trimbleteamid,self.leaguescore ,self.trimblescore,self.guanjunteamid)
end


local sfactionteaminfo = require "protocoldef.knight.gsp.faction.sfactionteaminfo"
function sfactionteaminfo:process()
  LogInfo("SFactionTeamInfo:process",self.teamid)
  require "ui.teampvp.teampvpinfodlg"
  TeampvpInfoDlg.getInstanceAndShow():Process(self.zcflag,self.teammemberinfo,self.teamname,self.factionname,self.shenglv,self.score,self.zhzl,self.renqi,self.hassurportpoint,self.remainpoints,self.teamid)
end

local sdrawrole = require "protocoldef.knight.gsp.faction.sdrawrole"
function sdrawrole:process()
  LogInfo("SDrawRole:process")

  require "ui.drawrole.drawrolemanager"
  DrawRoleManager:getInstance():drawRole(self.flag)

end

local swaitinfo = require"protocoldef.knight.gsp.faction.swaitinfo"
function swaitinfo:process()
  LogInfo("SWaitInfo:process")
  if GetBattleManager() and not GetBattleManager():IsInBattle() then
	  require "ui.teampvp.teampvpmatchdlg"
	  TeampvpMatchDlg.getInstanceAndShow():Process(self.remaintime,self.team1name,self.team1wintimes,self.team2name,self.team2wintimes,self.currchangci,self.dzxl,self.flag)
  end
end

local sfreshtime = require"protocoldef.knight.gsp.faction.sfreshtime"
function sfreshtime:process()
  LogInfo("sfreshtime:process")
  require "ui.teampvp.teampvpmatchdlg"
  TeampvpMatchDlg.refresh(self.remaintime)
end

local swatchbattlelist = require"protocoldef.knight.gsp.faction.swatchbattlelist"
function swatchbattlelist:process()
  LogInfo("swatchbattlelist:process")
  if GetBattleManager() and not GetBattleManager():IsInBattle() then
	  require "ui.teampvp.teampvpshowdlg"
	  TeampvpShowDlg.getInstanceAndShow():Process(self.teammemberinfo)
 end
end

local sbattletable = require"protocoldef.knight.gsp.faction.sbattletable"
function sbattletable:process()
  LogInfo("sbattletable:process")
  require "ui.teampvp.TeampvpTimeInfoDlg"
  TeampvpTimeInfoDlg.getInstanceAndShow():Process(self.firstpreliminarytime,self.secondpreliminarytime,self.thirdpreliminarytime,self.finaltime)
end


local snotifyexit = require"protocoldef.knight.gsp.faction.snotifyexit"
function snotifyexit:process()
  LogInfo("sbattletable:process")
  local s = MHSD_UTILS.get_msgtipstring(145558)
  GetMessageManager():AddConfirmBox(eConfirmNormal,s, snotifyexit.CancelTeamConfirm,snotifyexit,snotifyexit.CancelTeamCancel,snotifyexit)
end
function snotifyexit.CancelTeamConfirm()
  local p = require "protocoldef.knight.gsp.faction.cdismissfactionteam" : new()
  require "manager.luaprotocolmanager":send(p)
  GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end

function snotifyexit.CancelTeamCancel()
  GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end

local snotifyzhichiscore = require"protocoldef.knight.gsp.faction.snotifyzhichiscore"
function snotifyzhichiscore:process()
  LogInfo("snotifyzhichiscore:process")
  local s = MHSD_UTILS.get_msgtipstring(146472)
  local sb = require "utils.stringbuilder":new()
  sb:Set("parameter1", self.score)
  sb:Set("parameter2", self.score)
  s = sb:GetString(s)
  GetMessageManager():AddConfirmBox(eConfirmNormal,s, snotifyzhichiscore.Confirm,snotifyzhichiscore,
  	CMessageManager.HandleDefaultCancelEvent,CMessageManager)
end

function snotifyzhichiscore.Confirm()
	local p = require "protocoldef.knight.gsp.faction.cexchangezhichiscore" : new()
  	require "manager.luaprotocolmanager":send(p)
  	GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end

local sopenguardbeast = require "protocoldef.knight.gsp.faction.guardbeast.sopenguardbeast"
function sopenguardbeast:process()
	LogInfo("sopenguardbeast:process")
	local dlg = require "ui.faction.factionbeastdlg".getInstanceAndShow()
	dlg:initData(self.beastlevel, self.trainlevel, self.msglist, self.lefttimes)
end
