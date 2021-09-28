
local m = require "protocoldef.knight.gsp.npc.scommontask"

function m:process()
	LogInfo("enter scommontask process")
	
	require "ui.fubenguidedialog"
	local fubenDlg=FubenGuideDialog.getInstanceAndShow()
	if fubenDlg then
	   
	   fubenDlg:ClearNpcList()
	   
	   for k,v in pairs(self.npclist) do
	       fubenDlg:AddNpc(v.npcid,v.npckey,v.posx,v.posy) 
	   end
	
	   fubenDlg:RefreshTask(self.taskid,self.mapid,self.currenttimes,self.defaulttimes)
	end
	local dlg = require "ui.legend.entrance":getInstanceOrNot()
	if dlg then
		dlg:DestroyDialog()
	end
	dlg = require "ui.activity.npctipsdialog":getInstanceOrNot()
	if dlg and dlg.m_iMode == 2 then
		dlg:DestroyDialog()
	end
end

local m_removenpc = require "protocoldef.knight.gsp.npc.sremovenpc"

function m_removenpc:process()
	LogInfo("enter sremovenpc process")
	
	require "ui.fubenguidedialog"
	local fubenDlg=FubenGuideDialog.getInstanceAndShow()
	if fubenDlg then
       fubenDlg:RemoveNpc(self.npckey) 
	 end

end

local m_notifyProcess = require "protocoldef.knight.gsp.npc.snotifytaskprocess"

function m_notifyProcess:process()
	LogInfo("enter snotifytaskprocess process")

	require "ui.fubenguidedialog"
     FubenGuideDialog.NotifyTaskProcess(self.tasktype,self.step) 

end

local m_FinishFuben = require "protocoldef.knight.gsp.npc.scommontaskend"

function m_FinishFuben:process()
	LogInfo("enter scommontaskend process")

	require "ui.fubenguidedialog"
    local fubenDlg=FubenGuideDialog.getInstanceAndShow()
	if fubenDlg then
       fubenDlg:NotifyFubenEnd() 
	 end 
	
end

local m_songbaoquestion = require "protocoldef.knight.gsp.npc.ssendyunyouquestionl"
function m_songbaoquestion:process()
	LogInfo("enter ssendyunyouquestionl process")
	require "ui.yunyousongbao.yunyoudlg"
	YunYouSongBaoDlg.getInstanceAndShow():initQuestion(self.npcid, self.npckey, self.questiontype, self.questionid)
end

local m_songbaoresult = require "protocoldef.knight.gsp.npc.syunyouanswerresultl"

function m_songbaoresult:process()
	LogInfo("enter syunyouanswerresultl process")
	require "ui.yunyousongbao.yunyoudlg"
	if YunYouSongBaoDlg.getInstanceNotCreate() then
		YunYouSongBaoDlg.getInstanceNotCreate():results(self.right, self.tipsid)
	end
end

local p = require "protocoldef.knight.gsp.npc.sreqtgbdquestion"
function p:process()
	local dlg = require "ui.activity.npctipsdialog":getInstance()
	if dlg then
		dlg:ParseServerSendQuestion(self.lastresult, self.questionid, self.npckey)
	end
end

p = require "protocoldef.knight.gsp.npc.stgbdvote"
local confirmtype, curtime
local endtime = 10
local function confirm()
	if confirmtype then
		GetMessageManager():CloseConfirmBox(confirmtype, false)
		confirmtype = nil
	end
	local p = require "protocoldef.knight.gsp.npc.ctgbdvote":new()
	p.result = 0
	require "manager.luaprotocolmanager":send(p)
end
local function reject()
	if confirmtype then
		GetMessageManager():CloseConfirmBox(confirmtype, false)
		confirmtype = nil
	end
	local p = require "protocoldef.knight.gsp.npc.ctgbdvote":new()
	p.result = 1
	require "manager.luaprotocolmanager":send(p)
end
local function tryCloseBox(eslaped)
	if not confirmtype then
		return
	end
	curtime = curtime and curtime + eslaped or eslaped
	if curtime >= endtime then
		GetMessageManager():CloseConfirmBox(confirmtype, false)
		confirmtype = nil
		local p = require "protocoldef.knight.gsp.npc.ctgbdvote":new()
		p.result = 0
		require "manager.luaprotocolmanager":send(p)
	end
end
function p:process()
	 local formatstr = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(145330).msg
	 local sb = require "utils.stringbuilder":new()
	sb:Set("parameter1", self.level or "??")
	confirmtype = eConfirmTeamLeaderEnterFuben + 1
	curtime = 0
	GetMessageManager():AddConfirmBox(confirmtype, sb:GetString(formatstr), confirm, 0,
	     reject,0,0,0,nil,"","")
    sb:delete()
end

p = require "protocoldef.knight.gsp.npc.stgbdinfo"
function p:process()
	local dlg = require "ui.legend.entrance":getInstanceOrNot()
	if dlg then
		dlg.m_pFinishTime:setText(self.todaytimes.."/1")
	end
end

local sreqfortunewheel = require "protocoldef.knight.gsp.npc.sreqfortunewheel"
function sreqfortunewheel:process()
    LogInfo("____sreqfortunewheel:process")
    require "ui.wujueling.wujuelingcarddlg"
    require "ui.lottery.lotterycarddlg"

    print("____self.flag: " .. self.flag)

    if self.flag == 0 then
        LotteryCardDlg.getInstanceAndShow():initdlg(self.itemids, self.index, self.npckey, self.serviceid)
    elseif self.flag == 1 then
        local dlgWujuelingCard = WujuelingCardDlg.getInstanceAndShow()
        if dlgWujuelingCard then
            dlgWujuelingCard:InitCards(self.itemids, self.index, self.npckey, self.serviceid)
        else
            print("____error not get instance of dlgwujuelingcard")
        end
    else
        print("____error flag not 0 or 1")
    end
end

local spingji = require "protocoldef.knight.gsp.npc.spingji"
function spingji:process()
    LogInfo("____spingji:process")
    require "ui.wujueling.wujuelingcarddlg"

    local dlgWujuelingCard = WujuelingCardDlg.getInstanceAndShow()
    if dlgWujuelingCard then
        dlgWujuelingCard:InitScore(self.grade, self.exp)
    else
        print("____error not get instance of dlgwujuelingcard")
    end
end


return tryCloseBox
