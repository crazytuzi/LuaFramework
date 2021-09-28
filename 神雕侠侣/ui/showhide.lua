require "ui.pkdialog"
require "ui.teamlabel"
require "ui.yaoqianshuentrance"
require "ui.yaoqianshudlg"
require "ui.friendsdialog"
require "ui.friendentrance"
require "ui.pet.petlabel"
require "ui.wujueling.wujuelingexitmapdlg"
require "ui.fubenguidedialog"
require "ui.firstchargebtn"
require "utils.log"
require "ui.pkentrance"
require "ui.convertdlg"
require "ui.battlerewarddlg"
require "ui.richexptipdlg"
require "ui.vip.vipmanager"
require "ui.camp.pvpareabanner"
require "ui.binfengift.binfengiftbtn"
require "ui.advansettingdlg"
require "ui.camp.campvs"
require "ui.camp.campvsentrance"
require "ui.bandit.bandit"
require "ui.logo.logoinfodlg"
require "ui.searchfrienddlg"
require "ui.quickteam.quickteamdlg"
require "ui.bandit.banditrubdlg"
require "ui.flower.flowersend"
require "ui.flower.flowerreceived"
require "ui.flower.flowerthanks"
require "ui.flower.flowereffect"
require "ui.luntanentrance"
require "ui.koreanforumdlg"
require "ui.battleautofightdlg"
require "ui.battleautodlg"
require "ui.facebookbuttondlg"
require "ui.spring.springentrancebtn"
require "ui.spring.springentrancedlg"
require "ui.spring.chunliandlg"
require "ui.skill.wulinmijidlg"
require "ui.skill.upmijidlg"
require "ui.skill.wulintipsdlg"
require "ui.drawrole.drawrolereminder"
require "ui.drawrole.drawroledlg"
require "ui.pet.petamuletcompositedlg"
require "ui.welfare.welfarebtn"
require "ui.welfare.onlinegiftbtn"
require "ui.marry.invitationcardsmalldlg"
require "ui.jieyi.jieyipersontipsdlg"
require "ui.jieyi.jieyialltipsdlg"

---activityWeek entrance
-- local ActWeekEntrance = require "ui.actweek.actweekentrance"
local XingXiaZhangYiBtn = require "ui.xingxiazhangyibtn"
local YiZhanDaoDiBtn = require "ui.yizhandaodi.yizhandaodibtn"
local BingLinChengXiaBtn = require "ui.binglinchengxia.binglinchengxiabtn"
local XiangFuZhenShouBtn = require "ui.xiangfuzhenshoubtn"
local BinfenGiftBtn = require "ui.binfengift.binfengiftbtn"
local SDZhaJiEntranceBtn = require "ui.sdzhaji.sdzhajibtn"

local BeanConfigManager = require "manager.beanconfigmanager"

require "ui.crossserver.huashanzhidianbtn"

ShowHide = {}
ShowHide.UiCheckWhenEnterEndBattle = {"ui.gumumijing.gumumijinglarenbtn","ui.gumumijing.gumumijingbtn","ui.gumumijing.gumumijingtime", "ui.luckywheel.luckywheelentrance", 'ui.lotteryconsume.lotteryconsumebtn'}
function ShowHide.GetChatOutWndClosedSetChan()
    return 4
end

--进入战斗 
function ShowHide.EnterBattle()
	LogInfo("showhide enterbattle")

	if CDeviceInfo:GetDeviceType() == 3 then
		local sizeMem = CDeviceInfo:GetTotalMemSize()
		if sizeMem <= 1024 then
			XiaoPang.GetEngine():EnableParticle(true)
		end
	end
    if DrawRoleReminder.getInstanceNotCreate() then
    	DrawRoleReminder.getInstanceNotCreate():SetVisible(false)
    end
    if DrawRoleDlg.getInstanceNotCreate() then
	DrawRoleManager:getInstance():hideDetail()
    end

    if InvitationCardSmallDialog.getInstanceNotCreate() then
    	InvitationCardSmallDialog.getInstanceNotCreate():SetVisible(false)
    end

    if HuashanzhidianBtn.getInstanceNotCreate() then
    	HuashanzhidianBtn.getInstanceNotCreate():SetVisible(false)
    end

	if PKDialog.getInstanceNotCreate() then
		PKDialog.getInstanceNotCreate():SetVisible(false)
	end
	
	if TeamLabel.getInstanceNotCreate() then
		TeamLabel.getInstanceNotCreate():SetVisible(false)
	end

	if YaoQianShuDlg.getInstanceNotCreate() then
		YaoQianShuDlg.getInstanceNotCreate():SetVisible(false)
	end
	
	if ContactRoleDialog.getInstanceNotCreate() then
		ContactRoleDialog.DestroyDialog()
	end
	
	if FriendsDialog.getInstanceNotCreate() then
		FriendsDialog.DestroyDialog()
	end

	if PetAmuletCompositeDlg.getInstanceNotCreate() then
		PetAmuletCompositeDlg.DestroyDialog()
	end
	
	--xiaolong added for bug 26477, do not close the chat dialog when enter in battle
	--[[local friendchatdlg=FriendChatDialog.getInstanceNotCreate()
	if  friendchatdlg then
		local roleID=friendchatdlg.m_ChatRoleID
		local minichatdlg=MiniFriendChatDialog.getInstanceAndShow()
	    if minichatdlg then
	        minichatdlg:SetChatRoleID(roleID)
	        friendchatdlg.DestroyDialog()
	    end
		FriendChatDialog.DestroyDialog()
	end]]
	if GetDataManager():GetMainCharacterLevel() > 3 then 	
		FriendEntranceDialog.getInstanceAndShow()
	end

	if PetLabel.getInstanceNotCreate() then 
		PetLabel.DestroyDialog()
	end
	
    if BattleRewardDlg.getInstanceNotCreate() then
       BattleRewardDlg.DestroyDialog()
    end

	if FubenGuideDialog.getInstanceNotCreate() then
		FubenGuideDialog.getInstanceNotCreate():SetVisible(false)
	end

	if MainControl.getInstanceNotCreate() then
		MainControl.getInstanceNotCreate():SetVisible(false)
	end

	LunTanEntrance.WantHide()
    KoreanForumDlg.WantHide()
	FacebookButtonDlg.WantHide()
    if RichExpTipDlg.getInstanceNotCreate() then
        RichExpTipDlg.getInstanceNotCreate():SetVisible(false)
    end
	if CTaskTracingDialog.getSingleton() then
		CTaskTracingDialog.getSingleton():SetVisible(false)
	end

    if PVPAreaBanner.getInstanceNotCreate() then
        PVPAreaBanner.getInstanceNotCreate():SetVisible(false)
    end
    
    if QuickTeamBtn.getInstanceNotCreate() then
        QuickTeamBtn.getInstanceNotCreate():SetVisible(false)
    end
    if QuickTeamDlg.getInstanceNotCreate() then
        QuickTeamDlg.getInstanceNotCreate():SetVisible(false)
    end
	if Bandit.getInstanceNotCreate() then
		Bandit.getInstanceNotCreate():SetVisible(false)
	end
    
    if BanditRubDlg.getInstanceNotCreate() then
        BanditRubDlg.getInstanceNotCreate():SetVisible(false)
    end

	if CampVS.getInstanceNotCreate() then
		CampVS.getInstanceNotCreate():SetVisible(false)
	end
	if CampVSEntrance.getInstanceNotCreate() then
		CampVSEntrance.getInstanceNotCreate():SetVisible(false)
	end
    
    --about flower
    if FlowerSendDlg.getInstanceNotCreate() then
        FlowerSendDlg.getInstanceNotCreate():SetVisible(false)
    end
    if FlowerReceivedDlg.getInstanceNotCreate() then
        FlowerReceivedDlg.getInstanceNotCreate():SetVisible(false)
    end
    if FlowerThanksDlg.getInstanceNotCreate() then
        FlowerThanksDlg.getInstanceNotCreate():SetVisible(false)
    end

	if SearchFriendDlg.getInstanceNotCreate() then
		SearchFriendDlg.getInstanceNotCreate().DestroyDialog()
	end 
	
    --about logo info dialog
    if LogoInfoDialog.getInstanceNotCreate() then
        LogoInfoDialog.getInstanceNotCreate():SetVisible(false)
    end
	if SettingMainFrame.peekInstance() then
		SettingMainFrame.DestroyDialog()
	end
	
	local jewelrylabel = require "ui.label".getLabelById("jewelry")
	if jewelrylabel then
		jewelrylabel:OnClose()
	end
	if WaringButtonDlg.getInstanceNotCreate() then
		WaringButtonDlg.getInstanceNotCreate():DestroyDialog()	
	end
	if BattleAutoDlg.getInstanceNotCreate() then
		BattleAutoDlg.getInstanceNotCreate():StartBattle()
	end
	require "ui.safelocksetdlg"
	if SafeLockSetDlg.getInstanceNotCreate() ~= nil then
		SafeLockSetDlg.DestroyDialog()
	end
	require "ui.safelockhelp"
	if SafeLockHelpDlg.getInstanceNotCreate() ~= nil then
		SafeLockHelpDlg.DestroyDialog()
	end
	require "ui.safelockchangedlg"
	if SafeLockChangeDlg.getInstanceNotCreate() ~= nil then
		SafeLockChangeDlg.DestroyDialog()
	end
	if SafeLockCancelAllDlg.getInstanceNotCreate() ~= nil then
		SafeLockCancelAllDlg.DestroyDialog()
	end
	if SafeUnlockDlg.getInstanceNotCreate() ~= nil then
		SafeUnlockDlg.DestroyDialog()
	end
	--自动关闭全到分枝后安全锁的两个模态窗改成自动关闭
	GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
    
    if WujuelingExitMapDlg.getInstanceNotCreate() then
        WujuelingExitMapDlg.getInstanceNotCreate():SetVisible(false)
    end

    if SpringEntranceBtn.getInstanceNotCreate() then
        SpringEntranceBtn.getInstanceNotCreate():SetVisible(false)
    end

    if SpringEntranceDlg.getInstanceNotCreate() then
        SpringEntranceDlg.DestroyDialog()
    end

    if ChunLianDlg.getInstanceNotCreate() then
        ChunLianDlg.DestroyDialog()
    end

	require "ui.loginreward.loginrewardentrancedlg"
	if LoginRewardEntranceDlg.getInstanceNotCreate() then
		LoginRewardEntranceDlg.getInstanceNotCreate():SetVisible(false)
	end

	require "ui.loginreward.loginrewarddlg"
	if LoginRewardDlg.getInstanceNotCreate() then
		LoginRewardDlg.getInstanceNotCreate():SetVisible(false)
	end


	ShowHide.TeamPvpDestroyDlg()

	local CampLeaderPowerDlg = require "ui.camp.campleaderpowerdlg"
	if CampLeaderPowerDlg.getInstanceNotCreate() then
		CampLeaderPowerDlg.getInstanceNotCreate():SetVisible(false)
	end

	local SearchBanFriendDlg = require "ui.searchbanfrienddlg"
	if SearchBanFriendDlg.getInstanceNotCreate() then
		SearchBanFriendDlg.getInstanceNotCreate().DestroyDialog()
	end 

	local CampRichDlg = require "ui.camp.camprichdlg"
	if CampRichDlg.getInstanceNotCreate() then
		CampRichDlg.getInstanceNotCreate():SetVisible(false)
	end 

	local PVPServiceSeasonEndDlg = require "ui.teampvp.pvpserviceseasonenddlg"
	if PVPServiceSeasonEndDlg.getInstanceNotCreate() then
		PVPServiceSeasonEndDlg.getInstanceNotCreate():SetVisible(false)
	end

    if CPvpservice:GetSingleton() ~= nil then
    	CPvpservice:GetSingleton():SetVisible(false)
    end

    if SkillLable.getInstanceNotCreate() ~= nil then
    	SkillLable.DestroyDialog()
    end
    if UpMijiDlg.getInstanceNotCreate() ~= nil then
    	UpMijiDlg.DestroyDialog()
    end
    if WulinTipsDlg.getInstanceNotCreate() ~= nil then
    	WulinTipsDlg.DestroyDialog()
    end
    
    if JieyiPersonTipsDialog.getInstanceNotCreate() ~= nil then
    	JieyiPersonTipsDialog.DestroyDialog()
    end

    if JieyiAllTipsDialog.getInstanceNotCreate() ~= nil then
    	JieyiAllTipsDialog.DestroyDialog()
    end

	local LuckyWheelDlg = require "ui.luckywheel.luckywheeldlg"
	if LuckyWheelDlg.getInstanceNotCreate() then
		LuckyWheelDlg.DestroyDialog()
	end

	local XiaGanYiDanBattleDlg = require "ui.xiaganyidan.xiaganyidanbattledlg"
	if XiaGanYiDanBattleDlg:getInstanceOrNot() then
		XiaGanYiDanBattleDlg:getInstanceOrNot():DestroyDialog()
	end
	local XiaGanYiDanMapDlg = require "ui.xiaganyidan.xiaganyidanmapdlg"
	if XiaGanYiDanMapDlg:getInstanceOrNot() then
		XiaGanYiDanMapDlg:getInstanceOrNot():SetVisible(false)
	end

	if SDZhaJiEntranceBtn:getInstanceNotCreate() then
		SDZhaJiEntranceBtn:getInstanceNotCreate():SetVisible(false)
	end

	if require "ui.shijuezhen.shijuezhendlg".getInstanceNotCreate() then
		require "ui.shijuezhen.shijuezhendlg".getInstanceNotCreate().DestroyDialog()
	end
	
	local LotteryConsumeDlg = require 'ui.lotteryconsume.lotteryconsumedlg'
	if LotteryConsumeDlg.getInstanceNotCreate() then
		LotteryConsumeDlg.DestroyDialog()
	end

	ShowHide.SetButtonsVisible(false)

	LuaBattleUIManager.CreateBattleUI()

	ShowHide.SetUiVisibleWhenEnterEndBattle(false)
end


--退出战斗
function ShowHide.EndBattle()
	LogInfo("showhide endbattle")
	
	if CDeviceInfo:GetDeviceType() == 3 then
		local sizeMem = CDeviceInfo:GetTotalMemSize()
		if sizeMem <= 1024 then
			XiaoPang.GetEngine():EnableParticle(false)
		end
	end

    if InvitationCardSmallDialog.getInstanceNotCreate() then
    	InvitationCardSmallDialog.getInstanceNotCreate():SetVisible(true)
    end

    if HuashanzhidianBtn.getInstanceNotCreate() and not GetScene():IsInFuben() then
    	HuashanzhidianBtn.getInstanceNotCreate():SetVisible(true)
    end

	if PKDialog.getInstanceNotCreate()  then
		PKDialog.getInstanceNotCreate():SetVisible(true)
	end
	
	if TeamLabel.getInstanceNotCreate() then
		TeamLabel.getInstanceNotCreate():SetVisible(true)
	end
	
	if YaoQianShuDlg.getInstanceNotCreate() then
		YaoQianShuDlg.getInstanceNotCreate():SetVisible(true)
	end
	
--	if CWaringbuttonDlg:GetSingleton() and GetScene():IsInFuben() then
--		CWaringbuttonDlg:GetSingleton():SetVisible(false)
--	end
	
	WelfareBtn.Refresh()

	if OnlineGiftBtn.getInstanceNotCreate() then
		OnlineGiftBtn.getInstanceNotCreate():SetVisible(true)
	end
	OnlineGiftBtn.Refresh()
   	
	FriendEntranceDialog.DestroyDialog()

	if CTaskTracingDialog.getSingleton() then
		CTaskTracingDialog.getSingleton():SetVisible(true)
	end
	if FubenGuideDialog.getInstanceNotCreate() then
		FubenGuideDialog.getInstanceNotCreate():SetVisible(true)
	end

	if MainControl.getInstanceNotCreate() then
		MainControl.getInstanceNotCreate():SetVisible(true)
        MainControl.RefreshFriendBtnFlashState()
	end

	LunTanEntrance.WantShow()
    KoreanForumDlg.WantShow()
	FacebookButtonDlg.WantShow()
    if RichExpTipDlg.getInstanceNotCreate() and g_bCurInRichExpState then
        RichExpTipDlg.getInstanceNotCreate():SetVisible(true)
    end

    if PVPAreaBanner.getInstanceNotCreate() then
        PVPAreaBanner.getInstanceNotCreate():SetVisible(true)
    end
    
    if QuickTeamBtn.getInstanceNotCreate() then
        QuickTeamBtn.getInstanceNotCreate():SetVisible(true)
        if QuickTeamDlg.getInstanceNotCreate() then
            QuickTeamDlg.getInstanceNotCreate():SetVisible(false)
        end
    else
        if QuickTeamDlg.getInstanceNotCreate() then
            QuickTeamDlg.getInstanceNotCreate():SetVisible(true)
        end
    end
	if Bandit.getInstanceNotCreate() then
		Bandit.getInstanceNotCreate():SetVisible(true)
		Bandit.getInstanceNotCreate():GetWindow():setAlpha(1)
	end
    
    if BanditRubDlg.getInstanceNotCreate() then
        BanditRubDlg.getInstanceNotCreate():SetVisible(true)
		BanditRubDlg.getInstanceNotCreate():GetWindow():setAlpha(1)
    end

	if CampVS.getInstanceNotCreate() then
		CampVS.getInstanceNotCreate():SetVisible(true)
		CampVS.getInstanceNotCreate():GetWindow():setAlpha(1)
	end
	if CampVSEntrance.getInstanceNotCreate() then
		CampVSEntrance.getInstanceNotCreate():SetVisible(true)
	end
    
    --about flower
    if FlowerSendDlg.getInstanceNotCreate() then
        FlowerSendDlg.getInstanceNotCreate():SetVisible(true)
    end
    if FlowerReceivedDlg.getInstanceNotCreate() then
        FlowerReceivedDlg.getInstanceNotCreate():SetVisible(true)
    end
    if FlowerThanksDlg.getInstanceNotCreate() then
        FlowerThanksDlg.getInstanceNotCreate():SetVisible(true)
    end

	if CWaringlistDlg:GetSingleton() then
		if CWaringlistDlg:GetSingleton():GetWarningManager() then
      if CWaringlistDlg:GetSingleton():GetWarningManager():HasWarning() then
        WaringButtonDlg.getInstanceAndShow()
      end
		end
	end	

    --about logo info dialog
    if LogoInfoDialog.getInstanceNotCreate() then
        LogoInfoDialog.getInstanceNotCreate():SetVisible(true)
    end

	if BattleAutoDlg.getInstanceNotCreate() then
		BattleAutoDlg.getInstanceNotCreate():EndBattle()
    end
	if SecurityLockSettingDlg.peekInstance() then 
		SecurityLockSettingDlg:EndBattle()
	end
    
    if WujuelingExitMapDlg.getInstanceNotCreate() then
        WujuelingExitMapDlg.getInstanceNotCreate():SetVisible(true)
    end

    if SpringEntranceBtn.getInstanceNotCreate() then
        SpringEntranceBtn.getInstanceNotCreate():SetVisible(true)
    end

	require "ui.loginreward.loginrewardentrancedlg"
	if LoginRewardEntranceDlg.getInstanceNotCreate() then
		LoginRewardEntranceDlg.getInstanceNotCreate():SetVisible(true)
	end

	local p = require "protocoldef.knight.gsp.faction.sdrawrole"
	if p.msgWin then
		 p.msgWin:setVisible(true)
		 p.msgWin = nil
    elseif p.reGumuShow then
        p:process()
        p.reGumuShow = nil
	end



	local CampLeaderPowerDlg = require "ui.camp.campleaderpowerdlg"
	if CampLeaderPowerDlg.getInstanceNotCreate() then
		CampLeaderPowerDlg.getInstanceNotCreate():SetVisible(true)
	end

	local CampRichDlg = require "ui.camp.camprichdlg"
	if CampRichDlg.getInstanceNotCreate() then
		CampRichDlg.getInstanceNotCreate():SetVisible(true)
	end 

	if GetScene():GetMapID() == 1425 then
		ShowHide.SetNormalVisible(false)
	end

	local PVPServiceSeasonEndDlg = require "ui.teampvp.pvpserviceseasonenddlg"
	if PVPServiceSeasonEndDlg.getInstanceNotCreate() then
		PVPServiceSeasonEndDlg.getInstanceNotCreate():SetVisible(true)
	end
    
    if not GetScene():IsInFuben() then
    	require("ui.zhaohuilaowanjia.daxiazhilubtn").CheckAndShow()
    end
    
    local p = require "protocoldef.knight.gsp.activity.gumumijing.sgumudrawaward"
    if p.reShow then
        p:process()
        p.reShow = nil
    end

    
    if require("ui.binglinchengxia.binglinchengxiadlg").getInstanceNotCreate() then
        require("ui.binglinchengxia.binglinchengxiadlg").getInstanceNotCreate():SetVisible(true)
    end

    if require("ui.gumumijing.gumumijinglarenbtn").reShow then
        require("ui.gumumijing.gumumijinglarenbtn").getInstanceAndShow()
        require("ui.gumumijing.gumumijinglarenbtn").reShow = nil
    end

    if DrawRoleReminder.getInstanceNotCreate() then
    	DrawRoleReminder.getInstanceNotCreate():SetVisible(true)
    end

    -- if CPvpservice:GetSingleton() ~= nil then
    -- 	CPvpservice:GetSingleton():SetVisible(true)
    -- end

	local XiaGanYiDanMapDlg = require "ui.xiaganyidan.xiaganyidanmapdlg"
	if XiaGanYiDanMapDlg:getInstanceOrNot() then
		XiaGanYiDanMapDlg:getInstanceOrNot():SetVisible(true)
	end

	if SDZhaJiEntranceBtn:getInstanceNotCreate() then
		SDZhaJiEntranceBtn:getInstanceNotCreate():SetVisible(true)
	end

	LuaBattleUIManager.DestoryBattleUI()
	BattlePetSummonDlg.EndBattle()

	if not GetScene():IsInFuben() then 
		ShowHide.SetButtonsVisible(true)
	end

    ShowHide.SetUiVisibleWhenEnterEndBattle(true)
end

function ShowHide.SetButtonsVisible( show )
	LogInfo("ShowHide SetButtonsVisible "..tostring(show))
	if GetScene() then
		bVisible = bVisible and (GetScene():GetMapInfo().id ~= 1426) --跨服地图不显示
	end
	require "ui.buttons.buttondlg".getInstance():SetVisible(show)
end

function ShowHide.SetUiVisibleWhenEnterEndBattle(b)
    for i = 1 ,#ShowHide.UiCheckWhenEnterEndBattle do
        if require(ShowHide.UiCheckWhenEnterEndBattle[i]).getInstanceNotCreate() then
            require(ShowHide.UiCheckWhenEnterEndBattle[i]).getInstanceNotCreate():SetVisible(b)
        end
    end
end

function ShowHide.TeamPvpDestroyDlg()

	require "ui.teampvp.teampvpinfodlg"
	if  TeampvpInfoDlg.getInstanceNotCreate() then
		 TeampvpInfoDlg.getInstanceNotCreate().DestroyDialog()
	end


	require "ui.teampvp.teampvplistdlg"
	if TeampvpListDlg.getInstanceNotCreate() then
		TeampvpListDlg.getInstanceNotCreate().DestroyDialog()
	end


	require "ui.teampvp.teampvpmaindlg"
	if TeampvpMainDlg.getInstanceNotCreate() then
		TeampvpMainDlg.getInstanceNotCreate().DestroyDialog()
	end


	require "ui.teampvp.teampvpmatchdlg"
	if TeampvpMatchDlg.getInstanceNotCreate() then
		TeampvpMatchDlg.getInstanceNotCreate().DestroyDialog()
	end

	require "ui.teampvp.teampvpshowdlg"
	if  TeampvpShowDlg.getInstanceNotCreate() then
		 TeampvpShowDlg.getInstanceNotCreate().DestroyDialog()
	end


	require "ui.teampvp.teampvpsignupdlg"
	if TeampvpSignupDlg.getInstanceNotCreate() then
		TeampvpSignupDlg.getInstanceNotCreate().DestroyDialog()
	end


	require "ui.teampvp.teampvpsupportpointdlg"
	if  TeampvpSupportPointDlg.getInstanceNotCreate() then
		 TeampvpSupportPointDlg.getInstanceNotCreate().DestroyDialog()
	end


	require "ui.teampvp.teampvptimeinfodlg"
	if TeampvpTimeInfoDlg.getInstanceNotCreate() then
		TeampvpTimeInfoDlg.getInstanceNotCreate().DestroyDialog()
	end


	require "ui.crossserver.crossteampvpmatchdlg"
	if CrossTeampvpMatchDlg.getInstanceNotCreate() then
		CrossTeampvpMatchDlg.getInstanceNotCreate().DestroyDialog()
	end


	require "ui.crossserver.crossteampvpinfodlg"
	if  CrossTeampvpInfoDlg.getInstanceNotCreate() then
		 CrossTeampvpInfoDlg.getInstanceNotCreate().DestroyDialog()
	end

	require "ui.crossserver.crossfinaldlg"
	if  CrossFinalDlg.getInstanceNotCreate() then
		 CrossFinalDlg.getInstanceNotCreate().DestroyDialog()
	end

	require "ui.crossserver.crossfinalsemidlg"
	if  CrossFinalSemiDlg.getInstanceNotCreate() then
		 CrossFinalSemiDlg.getInstanceNotCreate().DestroyDialog()
	end

	require "ui.crossserver.crossxuanzhandlg"
	if  CrossXuanZhanDlg.getInstanceNotCreate() then
		 CrossXuanZhanDlg.getInstanceNotCreate().DestroyDialog()
	end

	require "ui.crossserver.crossteampvpsupportpointdlg"
	if  CrossTeampvpSupportPointDlg.getInstanceNotCreate() then
		 CrossTeampvpSupportPointDlg.getInstanceNotCreate().DestroyDialog()
	end

	require "ui.crossserver.huashanzhidiandlg"
	if  HuaShanZhiDianDlg.getInstanceNotCreate() then
		 HuaShanZhiDianDlg.getInstanceNotCreate().DestroyDialog()
	end

	require "ui.crossserver.crossteampvpshowdlg"
	if  CrossTeampvpShowDlg.getInstanceNotCreate() then
		 CrossTeampvpShowDlg.getInstanceNotCreate().DestroyDialog()
	end

	require "ui.crossserver.huashanzhidianguanjun"
	if  HuaShanZhiDianGuanJun.getInstanceNotCreate() then
		 HuaShanZhiDianGuanJun.getInstanceNotCreate().DestroyDialog()
	end
end

--进入恩仇录场景
function ShowHide.EnterEnChouScene()
	LogInfo("showhide enterenchouscene")
	PKDialog.DestroyDialog()
	TeamLabel.DestroyDialog()
	YaoQianShuEntrance.DestroyDialog()
	YaoQianShuDlg.DestroyDialog()
	PetLabel.DestroyDialog()
	PKEntrance.DestroyDialog()
	ActivityEntrance.DestroyDialog()
	LunTanEntrance.DestroyDialog()
    KoreanForumDlg.DestroyDialog()
	WaringButtonDlg.DestroyDialog()
	FacebookButtonDlg.DestroyDialog()
	if SpringEntranceBtn.getInstanceNotCreate() then
		SpringEntranceBtn.getInstanceNotCreate():SetVisible(false)
	end
	SpringEntranceDlg.DestroyDialog()
	ChunLianDlg.DestroyDialog()
    require("ui.zhaohuilaowanjia.daxiazhilubtn").DestroyDialog()
    WelfareBtn.DestroyDialog()
    OnlineGiftBtn.DestroyDialog()
    ShowHide.SetButtonsVisible(false)
end

--恩仇录场景中战斗结束
function ShowHide.EnChouBattleEnd()
	LogInfo("showhide enchoubattleend")
	ShowHide.SetButtonsVisible(false)
end

--进入武道会场景
function ShowHide.EnterPVPScene()
	LogInfo("showhide enterpvpscene")
	PKDialog.DestroyDialog()
	TeamLabel.DestroyDialog()
	YaoQianShuEntrance.DestroyDialog()
	YaoQianShuDlg.DestroyDialog()
	PetLabel.DestroyDialog()
	PKEntrance.DestroyDialog()
	ActivityEntrance.DestroyDialog()
	LunTanEntrance.DestroyDialog()
    KoreanForumDlg.DestroyDialog()
	FacebookButtonDlg.DestroyDialog()
	if SpringEntranceBtn.getInstanceNotCreate() then
		SpringEntranceBtn.getInstanceNotCreate():SetVisible(false)
	end
    require("ui.zhaohuilaowanjia.daxiazhilubtn").DestroyDialog()
    WelfareBtn.DestroyDialog()
    OnlineGiftBtn.DestroyDialog()
    ShowHide.SetButtonsVisible(false)
end

--离开恩仇录或武道会场景
function ShowHide.ExitEnChouPVPScene()
	LogInfo("showhide exitenchoupvpscene")
	if GetNewRoleGuideManager() and (not GetScene():IsInFuben()) then 
		if GetNewRoleGuideManager():isGuideFinish(30037) and GetYaoQianShuManager() then
			if not GetYaoQianShuManager():getNoMoreTimes()  then 
				YaoQianShuEntrance.getInstanceAndShow()
			end
		end
	end


	if GetNewRoleGuideManager() and (not GetScene():IsInFuben()) then
		if GetNewRoleGuideManager():isGuideFinish(30038) then 
			PKEntrance.getInstanceAndShow()
		end
	end

	if GetNewRoleGuideManager() and (not GetScene():IsInFuben()) then
		if GetNewRoleGuideManager():isGuideFinish(30033) then 
			ActivityEntrance.getInstanceAndShow()
		end
	end

	if GetNewRoleGuideManager() and (not GetScene():IsInFuben()) then
		LunTanEntrance.getInstanceAndShow()
        KoreanForumDlg.getInstanceAndShow()
		FacebookButtonDlg.getInstanceAndShow()
	end

	if SpringEntranceBtn.getInstanceNotCreate() and GetNewRoleGuideManager() and (not GetScene():IsInFuben()) then
		SpringEntranceBtn.getInstanceAndShow()
	end

	if CWaringlistDlg:GetSingleton() then
		if CWaringlistDlg:GetSingleton():GetWarningManager() then
      if CWaringlistDlg:GetSingleton():GetWarningManager():HasWarning() then
        WaringButtonDlg.getInstanceAndShow()
      end
		end
	end	
    
	if GetNewRoleGuideManager() and (not GetScene():IsInFuben()) then
		require("ui.zhaohuilaowanjia.daxiazhilubtn").CheckAndShow()
	end

	if GetWelfareManager() then
        WelfareBtn.getInstanceAndShow():refresh()
        OnlineGiftBtn.Refresh()
    end

    ShowHide.SetButtonsVisible(true)
end

--进入游戏，创建需要的控件
function ShowHide.OnGameStart()
	LogInfo("ShowHide OnGameStart Lua")
	--get faction info
    local p = require "protocoldef.knight.gsp.faction.copenfaction":new()
	require "manager.luaprotocolmanager".getInstance():send(p)

	if CDeviceInfo:GetDeviceType() == 3 then
		setGCCooldown(1000)
	end
	ResetServerTimer()
	--SDXL.GetSDXLLogger():setLoggingLevel(SDXL.Insane)
	--if CEGUI.Logger:getSingleton() then
	--	CEGUI.Logger:getSingleton():setLoggingLevel(CEGUI.Errors)
	--end

	if CDeviceInfo:GetDeviceType() == 3 then
		local sizeMem = CDeviceInfo:GetTotalMemSize()
		if sizeMem <= 1024 then
			XiaoPang.GetEngine():EnableParticle(false)
			GetChatManager():SetPerFrameProcessMsgNum(3)
		end
	end

	MainControl.getInstanceAndShow()
	ActivityManager.getInstance()
	VipManager.getInstance()
	FormationManager.getInstance()
	LogoInfoDialog.GetSingletonDialogAndShowIt()
	if GetNewRoleGuideManager() and (not GetScene():IsInFuben()) then 
		if GetNewRoleGuideManager():isGuideFinish(30037) and GetYaoQianShuManager() then
			if not GetYaoQianShuManager():getNoMoreTimes()  then 
				YaoQianShuEntrance.getInstanceAndShow()
			end
		end
	end

	if GetNewRoleGuideManager() and (not GetScene():IsInFuben()) then 
		if GetNewRoleGuideManager():isGuideFinish(30038) then
			PKEntrance.getInstanceAndShow()
		end
	end

	if GetNewRoleGuideManager() and (not GetScene():IsInFuben()) then
		if GetNewRoleGuideManager():isGuideFinish(30033) then 
			ActivityEntrance.getInstanceAndShow()
		end
	end
    
	if GetNewRoleGuideManager() and (not GetScene():IsInFuben()) then
		LunTanEntrance.getInstanceAndShow()
        KoreanForumDlg.getInstanceAndShow()
		FacebookButtonDlg.getInstanceAndShow()
	end

    local dangweiDev = AdvanSettingDlg.GetDevEffectPlayLevel()
    if dangweiDev == 1 then
        CT_MAX_FLOWER_EFFECT = 1
    elseif dangweiDev == 2 then
        CT_MAX_FLOWER_EFFECT = 2
    else
        CT_MAX_FLOWER_EFFECT = 3
    end

	if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "ysuc" then
		require "luaj"
		luaj.callStaticMethod("com.wanmei.mini.condor.uc.UcPlatform", "testUCVIP", nil, nil)
	end
	if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "azhi" then
		local luaj = require "luaj"
		local tempTable = {}
		tempTable[1] = GetDataManager():GetMainCharacterName()
		tempTable[2] = GetDataManager():GetMainCharacterLevel()
		tempTable[3] = GetDataManager():GetMainCharacterName()
		tempTable[4] = ""
		luaj.callStaticMethod("com.wanmei.mini.condor.anzhi2.AnzhiPlatform", "setDate", tempTable, nil)
		luaj.callStaticMethod("com.wanmei.mini.condor.anzhi2.AnzhiPlatform", "AnZhiUploadUserDate", nil, nil)
	end

	require "ui.specialeffect.specialeffectmanager"
	SpecialEffectManager.getInstance()
	if SpecialEffectManager.getInstanceNotCreate() then
		SpecialEffectManager.getInstanceNotCreate():InitScreenEffect()
	end

	local cfgSpringBtnOpen = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cspringentranceopen"):getRecorder(1)
	if cfgSpringBtnOpen and cfgSpringBtnOpen.open == 1 then
		SpringEntranceBtn.getInstanceAndShow()
	end

	if WaringButtonDlg.getInstanceNotCreate() then
    	WaringButtonDlg.DestroyDialog()
	end

	require "ui.skill.wulinmijimanager".getInstance()
	if not GetScene():IsInFuben() then
    	require("ui.zhaohuilaowanjia.daxiazhilubtn").CheckAndShow()
    end

    local req = require "protocoldef.knight.gsp.friends.csearchenemy".Create()
    LuaProtocolManager.getInstance():send(req)

	-- 是否显示行侠仗义按钮 start
	local actXingXiaZhangYiInfo = knight.gsp.timer.GetCScheculedActivityTableInstance():getRecorder(148009) -- 行侠仗义
	local actstarttime = {}
	actstarttime.year, actstarttime.month, actstarttime.day, actstarttime.hour, actstarttime.min, actstarttime.sec = string.match(actXingXiaZhangYiInfo.startTime, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
	local actendtime = {}
	actendtime.year, actendtime.month, actendtime.day, actendtime.hour, actendtime.min, actendtime.sec = string.match(actXingXiaZhangYiInfo.endTime, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
	local svrtime = GetServerTime() / 1000
	if svrtime > os.time(actstarttime) and svrtime < os.time(actendtime) then
		XingXiaZhangYiBtn.getInstanceAndShow()
	end
	-- 是否显示行侠仗义按钮 end

	WelfareBtn.getInstanceAndShow()
	-- 神雕札记入口按钮
	if GetDataManager():GetMainCharacterLevel() >= 80 then
		SDZhaJiEntranceBtn.getInstanceAndShow()
	end

	require "ui.qiandaosongli.qiandaosonglibtn".getInstanceAndShow()

 	ShowHide.CheckAndroidNotity()
end


function ShowHide.CheckAndroidNotity()
	--安卓本地推送
	if Config.androidNotifyAll == true or Config.CUR_3RD_LOGIN_SUFFIX == "lemn" then
		require "luaj"
		local param = {}
		param[1] = 2
		luaj.callStaticMethod("com.wanmei.mini.condor.LocalNotificationManager", "enableNotification", param, "(I)V")
	end	

end




--新手引导刷新需要显示的控件
function ShowHide.NewRoleGuide()
	LogInfo("showhide newroleguide")
	if MainControl.getInstanceNotCreate() then
		MainControl.getInstanceNotCreate():ShowBtnByGuide()
	end
	if (not GetBattleManager():IsInBattle()) and (not GetScene():IsInFuben()) and GetNewRoleGuideManager() then
		if GetNewRoleGuideManager():isGuideFinish(30037) and GetYaoQianShuManager() then
			if not GetYaoQianShuManager():getNoMoreTimes()  then 
				YaoQianShuEntrance.getInstanceAndShow()
			end
		end
	end
	
	if (not GetBattleManager():IsInBattle()) and (not GetScene():IsInFuben()) and GetNewRoleGuideManager() then
		if GetNewRoleGuideManager():isGuideFinish(30038) then 
			PKEntrance.getInstanceAndShow()
		end
	end
	if (not GetBattleManager():IsInBattle()) and (not GetScene():IsInFuben()) and GetNewRoleGuideManager() then
		if GetNewRoleGuideManager():isGuideFinish(30033) then 
			ActivityEntrance.getInstanceAndShow()
		end
	end
end


--进入五绝副本
function ShowHide.EnterFuben()
	LogInfo("showhide enter fuben")
	PKDialog.DestroyDialog()
	TeamLabel.DestroyDialog()
	YaoQianShuEntrance.DestroyDialog()
	YaoQianShuDlg.DestroyDialog()
	PetLabel.DestroyDialog()
	PKEntrance.DestroyDialog()
	ActivityEntrance.DestroyDialog()
	LunTanEntrance.DestroyDialog()
    KoreanForumDlg.DestroyDialog()
	FacebookButtonDlg.DestroyDialog()
    if SpringEntranceBtn.getInstanceNotCreate() then
        SpringEntranceBtn.getInstanceNotCreate():SetVisible(false)
    end
	SpringEntranceDlg.DestroyDialog()
	ChunLianDlg.DestroyDialog()
    require("ui.zhaohuilaowanjia.daxiazhilubtn").DestroyDialog()

    if SDZhaJiEntranceBtn:getInstanceNotCreate() then
		SDZhaJiEntranceBtn:getInstanceNotCreate():SetVisible(false)
	end

--	if CWaringbuttonDlg:GetSingleton() then
--		CWaringbuttonDlg:GetSingleton():SetVisible(false)
--	end
    WaringButtonDlg.DestroyDialog() 
    ShowHide.SetButtonsVisible(false)

	local curMapid = GetScene():GetMapInfo().id
	if curMapid == 1401 then
		local dlg = require "ui.faction.factionmain".getInstanceOrNot()
		if dlg then
			dlg.DestroyDialog()
		end
		local co = require "ui.useitemhandler".useMsItemCo
		if co and coroutine.status(co) ~= "dead" then
			local status, error = coroutine.resume(co)
			if not status then
				LogErr(error)
				assert(false)
			end
		end
	end
end

--离开五绝副本
function ShowHide.ExitFuben()
	LogInfo("showhide exit fuben")
	if GetNewRoleGuideManager() then 
		if GetNewRoleGuideManager():isGuideFinish(30037) and GetYaoQianShuManager() and (not GetBattleManager():IsInBattle()) and (not GetScene():IsInFuben()) then
			if not GetYaoQianShuManager():getNoMoreTimes()  then 
				YaoQianShuEntrance.getInstanceAndShow()
			end
		end
	end

	if GetNewRoleGuideManager() and (not GetBattleManager():IsInBattle()) and (not GetScene():IsInFuben()) then 
		if GetNewRoleGuideManager():isGuideFinish(30038) then 
			PKEntrance.getInstanceAndShow()
		end
	end

	if GetNewRoleGuideManager() and (not GetBattleManager():IsInBattle()) and (not GetScene():IsInFuben()) then 
		if GetNewRoleGuideManager():isGuideFinish(30033) then 
			ActivityEntrance.getInstanceAndShow()
		end
	end

	if GetNewRoleGuideManager() and (not GetScene():IsInFuben()) then
		LunTanEntrance.getInstanceAndShow()
        KoreanForumDlg.getInstanceAndShow()
		FacebookButtonDlg.getInstanceAndShow()
	end

	if GetWelfareManager() then
        WelfareBtn.getInstanceAndShow():refresh()
        OnlineGiftBtn.Refresh()
    end
--[[	if CWaringbuttonDlg:GetSingleton() and CWaringlistDlg:GetSingleton() then
		if CWaringlistDlg:GetSingleton():GetWarningManager() then
			if CWaringlistDlg:GetSingleton():GetWarningManager():HasWarning() then
				CWaringbuttonDlg:GetSingleton():SetVisible(true)
			end
		end
	end
	local dlg = require "ui.task.tasktracingdialog".getSingleton()
	if dlg and not dlg:IsVisible() then
		dlg:SetVisible(true)
	end
	--]]
	if CWaringlistDlg:GetSingleton() then
		if CWaringlistDlg:GetSingleton():GetWarningManager() then
      if CWaringlistDlg:GetSingleton():GetWarningManager():HasWarning() then
        WaringButtonDlg.getInstanceAndShow()
      end
		end
	end	

	if SDZhaJiEntranceBtn:getInstanceNotCreate() then
		SDZhaJiEntranceBtn:getInstanceNotCreate():SetVisible(true)
	end

	if SpringEntranceBtn.getInstanceNotCreate() and GetNewRoleGuideManager() and (not GetBattleManager():IsInBattle()) and (not GetScene():IsInFuben()) then
		SpringEntranceBtn.getInstanceAndShow()

	    require("ui.zhaohuilaowanjia.daxiazhilubtn").CheckAndShow()
	end

	ShowHide.SetButtonsVisible(true)
end

function ShowHide.EnterLeavePVPArea()
	LogInfo("showhide enterleave pvp area")
	local camp = GetMainCharacter():GetCamp()
	if camp ~= 1 and camp ~= 2 then
		local num = GetScene():GetSceneCharNum()
		for i = 1, num do
			local character = GetScene():GetSceneCharacter(i)
			character:SetNameColour(0xff33ffff) 			--yellow
		end
	else
		if GetMainCharacter():IsInPVPArea() then
			local num = GetScene():GetSceneCharNum()
			for i = 1, num do
				local character = GetScene():GetSceneCharacter(i)
				if character:GetCamp() == camp then
					character:SetNameColour(0xff33ff33) 	--green
				elseif character:GetCamp() ~= 1 and character:GetCamp() ~= 2 then
					character:SetNameColour(0xff33ffff) 	--yellow
				else
					character:SetNameColour(0xff3333ff) 	--red
				end
			end
		else
			local num = GetScene():GetSceneCharNum()
			for i = 1, num do
				local character = GetScene():GetSceneCharacter(i)
				if character:GetCamp() == camp then
					character:SetNameColour(0xff33ff33) 	--green
				else
					character:SetNameColour(0xff33ffff) 	--yellow
				end
			end
		end
	end

	if GetMainCharacter():IsInPVPArea() then
		PVPAreaBanner.getInstanceAndShow()
			
    	if GetBattleManager():IsInBattle() then
        	PVPAreaBanner.getInstanceNotCreate():SetVisible(false)
    	end
	else
		PVPAreaBanner.DestroyDialog()
	end
end

function ShowHide.SetNormalVisible(show)
	LogInfo("ShowHide.SetNormalVisible ---> " .. tostring(show))
	local CTaskTracingDialog = require "ui.task.tasktracingdialog"
	local SpringEntranceBtn = require "ui.spring.springentrancebtn"
	local LunTanEntrance = require "ui.luntanentrance"
	local BinfenGiftBtn = require "ui.binfengift.binfengiftbtn"
    local KoreanForumDlg = require "ui.koreanforumdlg"
	local LuckyWheelEntrance = require "ui.luckywheel.luckywheelentrance"

	CTaskTracingDialog.getSingletonDialog():SetVisible(show)
	if show then
		OnlineGiftBtn.Refresh()
	else
		OnlineGiftBtn.DestroyDialog()
	end
	if show then
		WelfareBtn:getInstance():refresh()
	else
		WelfareBtn.DestroyDialog()
	end

	if SpringEntranceBtn.getInstanceNotCreate() then
		SpringEntranceBtn.getInstanceNotCreate():SetVisible(show)
	end
	if LunTanEntrance.getInstanceNotCreate() then
		LunTanEntrance.getInstanceNotCreate():SetVisible(show)
	end
    if KoreanForumDlg.getInstanceNotCreate() then
		KoreanForumDlg.getInstanceNotCreate():SetVisible(show)
	end
    
    if show then
        require("ui.zhaohuilaowanjia.daxiazhilubtn").CheckAndShow()
    else
        require("ui.zhaohuilaowanjia.daxiazhilubtn").DestroyDialog()
    end

	ShowHide.SetButtonsVisible(show)
	print("ShowHide.SetNormalVisible------------>" .. tostring(show))
end

function ShowHide.LeaveYiZhanDaoDi()
	print("ShowHide.LeaveYiZhanDaoDi")
	ShowHide.SetNormalVisible(true)

	local YiZhanDaoDiLookDlg = require "ui.yizhandaodi.yizhandaodicontrol"
	local YiZhanDaoDiTimeDlg = require "ui.yizhandaodi.yizhandaoditime"
	local YiZhanDaoDiAnswerDlg = require "ui.yizhandaodi.yizhandaodianswer"
	YiZhanDaoDiLookDlg.DestroyDialog()
	YiZhanDaoDiTimeDlg.DestroyDialog()
	YiZhanDaoDiAnswerDlg.DestroyDialog()
end

function ShowHide.EnterYiZhanDaoDi()
	print("ShowHide.EnterYiZhanDaoDi")
	ShowHide.SetNormalVisible(false)

	local YiZhanDaoDiLookDlg = require "ui.yizhandaodi.yizhandaodicontrol"
--	local YiZhanDaoDiTimeDlg = require "ui.yizhandaodi.yizhandaoditime"
	YiZhanDaoDiLookDlg.getInstanceAndShow()
--	YiZhanDaoDiTimeDlg.getInstanceAndShow()
	local CCountdown = require "protocoldef.knight.gsp.activity.yzdd.ccountdown"
	local req = CCountdown.Create()
	LuaProtocolManager.getInstance():send(req)
end

function ShowHide.SHJiHouSai(hasenter)
	print("ShowHide.SHJiHouSai .. " .. tostring(hasenter))
	ShowHide.SetNormalVisible(not hasenter)
	local PVPServiceSeasonEndDlg = require "ui.teampvp.pvpserviceseasonenddlg"
	if hasenter then
		PVPServiceSeasonEndDlg.getInstanceAndShow()
	else
		PVPServiceSeasonEndDlg.DestroyDialog()
	end
end

function ShowHide.ChangeMap(LastMapID, CurMapID)
	LogInfo("ShowHide ChangeMap " .. tostring(LastMapID) .. " " .. tostring(CurMapID))
	--应该先处理 LastMapID 再处理 CurMapID，避免以后可能从副本跳转到另一个副本界面显示冲突

    CampVS.DestroyDialog()
    
	require "ui.specialeffect.specialeffectmanager"
	if SpecialEffectManager.getInstanceNotCreate() then
		SpecialEffectManager.getInstanceNotCreate():InitLocationEffect()
	end

	-- 离开yizhandaodi
	if LastMapID == 1569 and LastMapID ~= CurMapID then
		ShowHide.LeaveYiZhanDaoDi()
	end

	-- leave jihousai
	if LastMapID == 1425 and LastMapID ~= CurMapID then
		ShowHide.SHJiHouSai(false)
	end
    
	-- leave marry, must close marry window
	if LastMapID == 1579 and LastMapID ~= CurMapID then
		local _ins = require "ui.marry.weddingmiddlg".getInstanceNotCreate()
		if _ins then
			_ins.DestroyDialog()
		end
	end

    -- add by kyle ****** start ******
    -- 2014 五一活动<是大侠一百层活动>, 进入副本动态地图 绝情谷密室，隐藏副本倒计时
    if CurMapID == 1578 then
    	WujuelingExitMapDlg.SetTimeLabelVisible(false)
    else
    	WujuelingExitMapDlg.SetTimeLabelVisible(true)
    end
    -- add by kyle ****** end ********

	if CurMapID == 1401 then
		WujuelingExitMapDlg.DestroyDialog()
		FubenGuideDialog.DestroyDialog()
	end

	if CurMapID == 1421 then
		ShowHide.EnterEnChouScene()
	end

	-- 进入yizhandaodi
	if CurMapID == 1569 and LastMapID ~= CurMapID then
		ShowHide.EnterYiZhanDaoDi()
	end

    if CurMapID == 1426 then
    	--cross server
    	ShowHide.SetNormalVisible(false)
    	CTaskTracingDialog.getSingletonDialog():SetVisible(true)
    end

	-- enter jihousai
	if CurMapID == 1425 and LastMapID ~= CurMapID then
		ShowHide.SHJiHouSai(true)
	end

	if LastMapID ~= CurMapID then
		require("ui.gumumijing.gumumijinglarenbtn").CheckAndOpen()	
		if require("ui.gumumijing.gumumijinglarenbtn").getInstanceNotCreate() then
			require("ui.gumumijing.gumumijinglarenbtn"):Changmap(CurMapID)
		end
	end		
end

function ShowHide.IsSpecialFuben(id)
	if id == 1426 then
		return 1
	else
		return 0
	end
end

return ShowHide
