local SRefreshActivityListFinishTimes = require "protocoldef.knight.gsp.task.activelist.srefreshactivitylistfinishtimes"
function SRefreshActivityListFinishTimes:process()
	ActivityDlg.refreshList(self.activities, self.activevalue, self.chesttake,self.remainactivevalue)
end

local SDrawGiftBox = require "protocoldef.knight.gsp.task.activelist.sdrawgiftbox" 
function SDrawGiftBox:process()
	LogInfo("enter sdrawgiftbox process")
	ActivityManager.refreshGiftBox()
end

local SActivityOpen = require "protocoldef.knight.gsp.task.activelist.sactivityopen"
function SActivityOpen:process()
	LogInfo("enter sactivityopen process")
	ActivityManager.openActivity(self.activityid)	
end

local SWujuelingvote = require "protocoldef.knight.gsp.task.swujuelingvote"
function SWujuelingvote:process()
    LogInfo("enter SWujuelingvote:process")
	require "ui.wujueling.wujuelingcheck"
    
    if WujuelingCheckDlg.IsShow() then
    
    else
        WujuelingCheckDlg.getInstanceAndShow()
    end
    
    local dlgWujueCheck = WujuelingCheckDlg.getInstanceNotCreate()
    if dlgWujueCheck then
       dlgWujueCheck:SetLevel(self.level)
    end
end

local p = require "protocoldef.knight.gsp.task.smrystaskinfo"
function p:process()
	if self.taskstate == 1 then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(341113)
        end
		return
	end
	require "ui.activity.npctipsdialog":getInstance():ParseCommitScenarioQuest(self.taskid)
end

local swujuelingtimestask = require "protocoldef.knight.gsp.task.swujuelingtimestask"
function swujuelingtimestask:process()
    require "ui.wujueling.wujuelingdlg"
    local dlgWujueling = WujuelingDlg.getInstanceAndShow()
    if dlgWujueling then
        dlgWujueling:SetTimes(self.finishedtimes, self.totaltimes)
    end
end

local scopydestroytime = require "protocoldef.knight.gsp.task.scopydestroytime"
function scopydestroytime:process()
    require "ui.wujueling.wujuelingexitmapdlg"
    
    if GetScene() then
        GetScene():SetWujueMapCopyDestroyLeftTime(self.destroytime)
	end
    
    local dlgWJLExitMap = WujuelingExitMapDlg.getInstanceNotCreate()
    if dlgWJLExitMap then
        dlgWJLExitMap:ResetWujueLeftTime(self.destroytime)
    end
end

local squestion = require "protocoldef.knight.gsp.task.squestion"
function squestion:process()
	local NormalDaTiDlg = require "ui.dati.normaldatidlg"
	NormalDaTiDlg.getInstanceAndShow():Refresh(self.lastresult, self.npckey, self.flag, self.questionid)
end

local srefreshnianhuotaskinfo = require "protocoldef.knight.gsp.task.srefreshnianhuotaskinfo"
function srefreshnianhuotaskinfo:process()
    require "ui.task.tasktracingdialog"

    local taskid = self.taskid
    local num = self.step

    local taskTracingDlg = CTaskTracingDialog.getSingleton()
    if taskTracingDlg == nil then 
        return
    end

    local quest = taskTracingDlg:GetTaskTrackCell(taskid)
    if quest == nil then 
        return
    end
    local tt = quest.pTitle:getText()
    local newTitle = string.gsub(quest.pTitle:getText(), "%$Number%$", tostring(num))
    quest.pTitle:setText(newTitle)
end

local sopenchunlian = require "protocoldef.knight.gsp.task.sopenchunlian"
function sopenchunlian:process()
    require "ui.spring.chunliandlg"
    local dlgChunLian = ChunLianDlg.getInstanceAndShow()
    if dlgChunLian ~= nil then
        dlgChunLian:ShowText()
    end
end

local sshijuezhen = require "protocoldef.knight.gsp.task.shijuezhen.sshijuezhen"
function sshijuezhen:process()
    print("sshijuezhen process")
    local dlg = require "ui.shijuezhen.shijuezhendlg".getInstanceAndShow()
    dlg:SetData(self)
end