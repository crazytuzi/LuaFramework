--跨服相关协议处理

local szhanbaolist = require "protocoldef.knight.gsp.cross.szhanbaolist"
function szhanbaolist:process()
	print("szhanbaolist process")
	local dlg = require "ui.crossserver.huashanzhidiandlg"
	dlg:getInstanceAndShow()

	for i = #self.zhanbaolist, 1, -1 do
		dlg:getInstance():PushZhanBao(self.zhanbaolist[i].msgid, self.zhanbaolist[i].parms)
	end
end

local sgradeteams = require "protocoldef.knight.gsp.cross.sgradeteams"
function sgradeteams:process()
	print("sgradeteams process")
	if self.gradeserverteams[1] == nil then
		print("Cross Grade not Start")
		GetGameUIManager():AddMessageTipById(145966)
		return
	end
	print("grade " ..tostring(self.grade))
    if self.grade == 1 or self.grade == 2 then
		require "ui.crossserver.crossfinaldlg"
		CrossFinalDlg.getInstanceAndShow():SetTeamInfo(self.gradeserverteams, self.grade)
	elseif self.grade == 3 then
		require "ui.crossserver.crossfinalsemidlg"
		CrossFinalSemiDlg.getInstanceAndShow():SetTeamInfo(self.gradeserverteams)
	else
		print("grade xuanzhan" ..tostring(self.grade))
		require "ui.crossserver.crossxuanzhandlg"
		CrossXuanZhanDlg.getInstanceAndShow():SetTeamInfo(self.gradeserverteams, self.grade)
	end
end

local sendwordmsg = require "protocoldef.knight.gsp.cross.sendwordmsg"
function sendwordmsg:process()
	print("sendwordmsg process")
	if self.flag == 1 then
		local dlg = require "ui.crossserver.huashanzhidiandlg"
		if dlg:getInstanceNotCreate() then
			dlg:getInstance():PushWorldMsg(self.rolename, self.servername, self.serverid, self.worldmsg)
		end
	end
end

local scrossteaminfo = require "protocoldef.knight.gsp.cross.scrossteaminfo"
function scrossteaminfo:process()
	print("scrossteaminfo process")
	require "ui.crossserver.crossteampvpinfodlg"

	CrossTeampvpInfoDlg.getInstanceAndShow():Process(self.zcflag, self.teammemberinfo, self.teamname , self.servername, 
		self.factionname, self.shenglv, self.score, self.zhzl, self.renqi, self.hassurportpoint, self.remainpoints, self.teamid)
end

local scrosswaitinfo = require"protocoldef.knight.gsp.cross.scrosswaitinfo"
function scrosswaitinfo:process()
  print("scrosswaitinfo:process")
  if GetBattleManager() and not GetBattleManager():IsInBattle() then
	  require "ui.crossserver.crossteampvpmatchdlg"
	  CrossTeampvpMatchDlg.getInstanceAndShow():Process(self.remaintime,self.server1name,self.server1wintimes
	  							,self.server2name,self.server2wintimes,self.currchangci,self.flag)
  end
end

local scrossfreshtime = require"protocoldef.knight.gsp.cross.scrossfreshtime"
function scrossfreshtime:process()
  print("scrossfreshtime:process")
  require "ui.crossserver.crossteampvpmatchdlg"
  CrossTeampvpMatchDlg.refresh(self.remaintime)
end


local swatchcrossbattlelist = require"protocoldef.knight.gsp.cross.swatchcrossbattlelist"
function swatchcrossbattlelist:process()
	print("swatchcrossbattlelist:process")
	if GetBattleManager() and not GetBattleManager():IsInBattle() then
		require "ui.crossserver.crossteampvpshowdlg"
		CrossTeampvpShowDlg.getInstanceAndShow():Process(self.teammemberinfo)
	end
end

local susedhuizhang = require"protocoldef.knight.gsp.item.susedhuizhang"
function susedhuizhang:process()
	print("susedhuizhang:process")
	require "ui.crossserver.huashanzhidianguanjun"
	HuaShanZhiDianGuanJun.getInstanceAndShow()
end






