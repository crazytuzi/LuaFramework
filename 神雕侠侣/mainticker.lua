require "ui.characterinfo.getroleinfomsg"
require "ui.vip.vipmanager"
require "ui.team.zhenfachoosedlg"
require "ui.task.tasktracingdialog"
require "ui.activity.activitydlg"
require "ui.bandit.bandit"
require "ui.xiake.quackfoundrare"
require "ui.offlineexp.offlineexp"
require "ui.camp.campvs"
require "ui.lottery.lotterycarddlg"
require "ui.specialeffect.specialeffectmanager"
require "utils.tween.tweennano"
require "ui.luckywheel.luckywheeldlg"

local gcTime = 0
--local serverStartTime = 0
--local nativeTime = -1
-- main tick 
function LuaMainTick(delta)
	--wp8
	if CDeviceInfo:GetDeviceType() == 3 then
		gcTime = gcTime + delta
		if gcTime >= 1000 then
			local curMem = CDeviceInfo:GetFreeMemSize()
			if curMem >= 150 then
				GCNow(0)
			end
			gcTime = 0
		end
	end
--	if nativeTime == -1 then
--		serverStartTime = GetServerTime()
--		nativeTime = 0
--	end
--	nativeTime = nativeTime + delta
--	if nativeTime > 6 * 60 * 1000 then
--		local serverTimeElapse = GetServerTime() - serverStartTime	
--		local maxtime = nativeTime * 2
--		local mintime = nativeTime / 2
--		if serverTimeElapse > maxtime or serverTimeElapse < mintime then
--			LogErr("nativeTime = " .. tostring(nativeTime))
--			LogErr("serverStartTime = " .. tostring(serverStartTime))
--			LogErr("serverTime = " .. tostring(GetServerTime()))
--			LogErr("serverTimeElapse = " .. tostring(serverTimeElapse))
--			LogErr("native:server = " .. tostring(nativeTime / serverTimeElapse))
--			if Config.MOBILE_ANDROID == 1 then
--				SDXL.ChannelManager:LogoutAndRelogin()
--			else
--				GetNetConnection():send(knight.gsp.CReturnToLogin())
--			end
--		end
--		nativeTime = -1
--	end

--[[
	local jiuguan = XiakeJiuguan.peekInstance(); 
	if jiuguan ~= nil then
		if jiuguan.m_pFindWnd:isVisible() then
			if jiuguan.m_i10Time ~= nil and jiuguan.m_i10Time >= 0 then
				jiuguan.m_i10Time = jiuguan.m_i10Time - delta;
				if jiuguan.m_i10Time < 0 then jiuguan.m_i10Time = 0; end
				jiuguan:SetTime(jiuguan.m_pLblTime10, jiuguan.m_i10Time);
			end
			if jiuguan.m_i100Time ~= nil and jiuguan.m_i100Time >= 0 then
				jiuguan.m_i100Time = jiuguan.m_i100Time - delta;
				if jiuguan.m_i100Time < 0 then jiuguan.m_i100Time = 0; end
				jiuguan:SetTime(jiuguan.m_pLblTime100, jiuguan.m_i100Time);
			end
			if jiuguan.m_i1000Time ~= nil and jiuguan.m_i1000Time >= 0 then
				jiuguan.m_i1000Time = jiuguan.m_i1000Time - delta;
				if jiuguan.m_i1000Time < 0 then jiuguan.m_i1000Time = 0; end
				jiuguan:SetTime(jiuguan.m_pLblTime1000, jiuguan.m_i1000Time);
			end
		end
	end
]]--
	--Because of some old wrong code, there are two timer in the program for xiake jiuguan
	--They are in XiakeMng and MainControl
	XiakeMng.run(delta)

	if MainControl.getInstanceNotCreate() then
		MainControl.getInstanceNotCreate():run(delta)
	end
	if ActivityManager.getInstanceNotCreate() then
		ActivityManager.getInstanceNotCreate():run(delta)
	end 
	if VipManager.getInstanceNotCreate() then
		VipManager.getInstanceNotCreate():run(delta)
	end
	GetRoleInfoMsg.run(delta)

	if ZhenfaChooseDlg.getInstanceNotCreate() then
		ZhenfaChooseDlg.getInstanceNotCreate():Run(delta)
	end

	if CTaskTracingDialog.getSingleton() then
		CTaskTracingDialog.getSingleton():Run(delta)		
	end	

	if ActivityDlg.getInstanceNotCreate() then
		ActivityDlg.getInstanceNotCreate():Run(delta)
	end
	
	if Bandit.getInstanceNotCreate() then
		Bandit.getInstanceNotCreate():run(delta / 1000)
	end

	if QuackFoundRare.getInstanceNotCreate() then
		QuackFoundRare.getInstanceNotCreate():run(delta / 1000)
	end
	
	if OfflineExp.getInstanceNotCreate() then
		OfflineExp.getInstanceNotCreate():run(delta / 1000)
	end

	if CampVS.getInstanceNotCreate() then
		CampVS.getInstanceNotCreate():Run(delta)
	end

	if LotteryCardDlg.getInstanceNotCreate() then
		LotteryCardDlg.getInstanceNotCreate():run(delta / 1000)
	end

	if LuckyWheelDlg.getInstanceNotCreate() then
		LuckyWheelDlg.getInstanceNotCreate():run(delta / 1000)
	end
	
	require "luaprotocolhandler.knight_gsp_npc"(delta / 1000)
	if SpecialEffectManager.getInstanceNotCreate() then
		SpecialEffectManager.getInstanceNotCreate():run(delta)
	end 
	require "ui.teampvp.teampvpmatchdlg"
	if TeampvpMatchDlg.getInstanceNotCreate() then
		TeampvpMatchDlg.getInstanceNotCreate():run(delta)
	end
	require "ui.crossserver.crossteampvpmatchdlg"
	if CrossTeampvpMatchDlg.getInstanceNotCreate() then
		CrossTeampvpMatchDlg.getInstanceNotCreate():run(delta)
	end
	require "ui.battleautodlg"
	BattleAutoDlg.CGameUIManagerRun(delta / 1000)
    
    if require("ui.gumumijing.gumumijingbtn").getInstanceNotCreate() then
        require("ui.gumumijing.gumumijingbtn").getInstanceNotCreate():run(delta)
    end

    if require("ui.binglinchengxia.binglinchengxiadlg").getInstanceNotCreate() then
		require("ui.binglinchengxia.binglinchengxiadlg").getInstanceNotCreate():run(delta)
	end

	if require("ui.fanfanle.fanfanlemanager").getInstanceNotCreate() then
		require("ui.fanfanle.fanfanlemanager").getInstanceNotCreate():run(delta)
	end

	if require("ui.drawrole.drawrolemanager").getInstanceNotCreate() then
		require("ui.drawrole.drawrolemanager").getInstanceNotCreate():run(delta)
	end

	if require("ui.crossserver.huashanzhidiandlg").getInstanceNotCreate() then
		require("ui.crossserver.huashanzhidiandlg").getInstanceNotCreate():run(delta)
	end
    
    local gumumijingtime = require("ui.gumumijing.gumumijingtime").getInstanceNotCreate()
    if gumumijingtime then
        gumumijingtime:run(delta)
    end

    if require("ui.skill.qijingbamaidlg").getInstanceNotCreate() then
		require("ui.skill.qijingbamaidlg").getInstanceNotCreate():run(delta)
	end

	if require("ui.laohuji.laohujidlg").getInstanceNotCreate() then
		require("ui.laohuji.laohujidlg").getInstanceNotCreate():run(delta)
	end

	if TweenNano then
		TweenNano.run(delta)
	end

	LuaBattleUIManager.Tick(delta)

    Tick1Minute(delta)
end

local tick1min = 0
function Tick1Minute(delta)
    tick1min = tick1min + delta
    if tick1min >= 60000 then
       tick1min = tick1min - 60000
        if GetDataManager() and GetDataManager():GetMainCharacterLevel() >= 60 and not GetScene():IsInFuben() and not GetBattleManager():IsInBattle() then
            require("ui.zhaohuilaowanjia.daxiazhilubtn").CheckAndHide()
        end
    end
end

function ResetServerTimer()
--	nativeTime = -1
end

