--------------------------------------------------------------------------------------
-- 文件名:	HF_Arena.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  flamehong
-- 日  期:	2014-9-10 10:24
-- 版  本:	1.0
-- 描  述:	竞技场界面
-- 应  用:  

---------------------------------------------------------------------------------------
Game_Arena = class("Game_Arena")
Game_Arena.__index = Game_Arena

local timeid = 0
local timeid2 = nil

local tbArenaData = nil	-- 竞技场数据
local tbArenaWidget = nil -- 竞技场界面控件

local is_open = true

Arena_Left 	= 0
Arena_Right = 0

local function cardAction(widget, nMovePosX, callFunc)
	if not widget then return end
	
	local nMovePosX = nMovePosX or 300
	local nTag = widget:getTag()
	local actionMove1 = CCMoveBy:create(0.4, CCPointMake(nMovePosX, 0))
	local actionMove2 = CCMoveBy:create(0.4, CCPointMake(-nMovePosX, 0))
	local actionEasing1 = CCEaseInOut:create(actionMove1,3) 
	local actionEasing2 = CCEaseInOut:create(actionMove2,3) 
	local arrAct = CCArray:create()
	arrAct:addObject(actionEasing1)
	arrAct:addObject(CCDelayTime:create(0.1))
	local function finishAction()
		callFunc(nTag)
		if nTag == 4 then
			if g_PlayerGuide:checkCurrentGuideSequenceNode("ActionEventEnd", "Game_Arena") then
				g_PlayerGuide:showCurrentGuideSequenceNode()
			end
		end
		g_MsgNetWorkWarning:closeNetWorkWarning()
	end
	if(callFunc)then
		arrAct:addObject(CCCallFuncN:create(finishAction))
	end	 
	arrAct:addObject(actionEasing2)
	local action = CCSequence:create(arrAct)
	widget:runAction(action)
end

--获得排名档次
local function getInterval(nRank)
	if not tbArenaData or not tbArenaData.tbInterval then return end
	local Interval = 1
	local value = 1
	if  nRank == 0 then
		Interval = #tbArenaData.tbInterval
		value = tbArenaData.tbInterval[#tbArenaData.tbInterval]
		return value
	end 
	for i,v in ipairs(tbArenaData.tbInterval) do
		if nRank > tbArenaData.tbInterval[Interval] then
			Interval = Interval + 1
        else
            break
		end
	end
	value = tbArenaData.tbInterval[Interval]
	return value,Interval
end

function getArenaIntervalValue(nRank)
	local value,Interval = getInterval(nRank)
	return value
end

function getArenaInterval(nRank)
	local value,Interval = getInterval(nRank)
	return Interval
end

--设置单个排行榜listview
local function setRankListItem(Button_PlayerItem, tbRankInfo, nTag)
	if not tbRankInfo then return end
	
	local Label_Name = tolua.cast(Button_PlayerItem:getChildByName("Label_Name"),"Label")
	if tbRankInfo.role_name == "小语" then
		tbRankInfo.role_name = _T("小语")
	end
	Label_Name:setText(getFormatSuffixLevel(tbRankInfo.role_name, g_GetCardEvoluteSuffixByEvoLev(tbRankInfo.breach_lv)))
	g_SetCardNameColorByEvoluteLev(Label_Name, tbRankInfo.breach_lv)
	
	local LabelBMFont_Rank = tolua.cast(Button_PlayerItem:getChildByName("LabelBMFont_Rank"),"LabelBMFont")
	LabelBMFont_Rank:setText(tbRankInfo.rank)
	local Label_Level = tolua.cast(Button_PlayerItem:getChildByName("Label_Level"),"Label")
	Label_Level:setText(_T("Lv.")..tbRankInfo.role_lv)
	
	local function onChallenge(pSender, nTag)
		local nLeavelTimes = g_Hero:getArenaTimes()
		local nArenaNeedLevel = g_DataMgr:getGlobalCfgCsv("arena_challenge_level")
		if g_Hero:getMasterCardLevel() < nArenaNeedLevel then
			g_ClientMsgTips:showMsgConfirm(_T("等级未到")..nArenaNeedLevel.._T("级")) 
		elseif  nLeavelTimes <= 0  then
			local types = VipType.VipBuyOpType_ArenaChallegeTimes
			-- local nBuyPrice = g_VIPBase:getVipLevelCntGold(types)
			g_ClientMsgTips:showMsgConfirm(_T("挑战次数已用完"))	
		elseif timeid2 then
			g_ClientMsgTips:showMsgConfirm(_T("您刚挑战失败了，竞技场冷却中，请稍等片刻。"))
		elseif tbRankInfo.role_uin == g_MsgMgr:getUin() then
			g_ClientMsgTips:showMsgConfirm(_T("不能挑战自己"))
		else
			g_MsgMgr:requestArenaChallenge(tbRankInfo.rank)
			g_Hero.otherLeaderName = tbRankInfo.role_name
		end
	end
	g_SetBtnWithGuideCheck(Button_PlayerItem, nil, onChallenge, true)
	
	--查看玩家信息
	local function clickHeadCallBack()
		g_MsgMgr:requestViewPlayer(uin)
	end
	
	local Image_Head = tolua.cast(Button_PlayerItem:getChildByName("Image_Head"),"ImageView")
	local Image_Icon = tolua.cast(Image_Head:getChildByName("Image_Icon"),"ImageView")
	local Image_Frame = tolua.cast(Image_Head:getChildByName("Image_Frame"),"ImageView")
	local LabelBMFont_VipLevel = tolua.cast(Image_Head:getChildByName("LabelBMFont_VipLevel"),"LabelBMFont")
	
	local CSV_CardBase = g_DataMgr:getCardBaseCsv(tbRankInfo.main_card_cfg_id, tbRankInfo.main_card_star)
    
	Image_Frame:loadTexture(getCardFrameByEvoluteLev(tbRankInfo.breach_lv))
	Image_Head:loadTexture(getCardBackByEvoluteLev(tbRankInfo.breach_lv))
	LabelBMFont_VipLevel:setText(_T("VIP")..tbRankInfo.vip_lev)
	
	local Image_TitleIcon = tolua.cast(Button_PlayerItem:getChildByName("Image_TitleIcon"),"ImageView")
	local Interval = 10000  --区间
	for key, value in ipairs(tbArenaData.tbInterval) do  
		if tbRankInfo.rank <= value then  
			Interval = value
			break   
		end  
	end 
	local CSV_ArenaDailyReward = g_DataMgr:getArenaDailyRewardCsv(Interval)
	Image_TitleIcon:loadTexture(getArenaImg(CSV_ArenaDailyReward.ClassIcon))
	
	local BitmapLabel_TeamStrength = tolua.cast(Button_PlayerItem:getChildByName("BitmapLabel_TeamStrength"),"LabelBMFont")
	BitmapLabel_TeamStrength:setText(tbRankInfo.fighting_point)
	
	local function onClick_Image_Head(pSender, nTag)
		g_Hero.otherLeaderName = tbRankInfo.role_name
		g_MsgMgr:requestViewPlayer(tbRankInfo.role_uin)
	end
	
	g_SetBtn(Button_PlayerItem, "Image_Head", onClick_Image_Head, true)
	
	if tbRankInfo.role_uin ==  g_MsgMgr:getUin() then
		Button_PlayerItem:loadTextureNormal(getUIImg("Frame_Arena_Item1"))
		Button_PlayerItem:loadTexturePressed(getUIImg("Frame_Arena_Item1_Press"))
		Button_PlayerItem:loadTextureDisabled(getUIImg("Frame_Arena_Item1"))
	else
		Button_PlayerItem:loadTextureNormal(getUIImg("Frame_Arena_Item2"))
		Button_PlayerItem:loadTexturePressed(getUIImg("Frame_Arena_Item2_Press"))
		Button_PlayerItem:loadTextureDisabled(getUIImg("Frame_Arena_Item2"))
	end
	
	if not CSV_CardBase then
       return
    end

	Image_Icon:loadTexture(getIconImg(CSV_CardBase.SpineAnimation))
end

--刷新排行榜
local function freshRankListView(nTag)
	if not tbArenaData then return end
	if not tbArenaData.tbRankListData then return end

	local wndInstance = g_WndMgr:getWnd("Game_Arena")
	if wndInstance and wndInstance.rootWidget then
		local Image_ChallengePNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_ChallengePNL"),"ImageView")
		if Image_ChallengePNL then
			local Button_PlayerItem = tolua.cast(Image_ChallengePNL:getChildByName("Button_PlayerItem"..nTag),"Button")
			if Button_PlayerItem then
				setRankListItem(Button_PlayerItem, tbArenaData.tbRankListData[nTag], nTag)
			end
		end
	end
	
	if nTag == 4 then
		local wndInstance = g_WndMgr:getWnd("Game_Arena")
		if wndInstance then
			local Button_Return = tolua.cast(wndInstance.rootWidget:getChildByName("Button_Return"),"Button")
			Button_Return:setTouchEnabled(true)
		end
	end
end

local function PlayCoolingTime()
	-- if not tbArenaData.bOpen then
		-- return true
	-- end
	
	if not timeid2 then return end
	
	local Image_CoolDown = tolua.cast(tbArenaWidget.layer:getChildByName("Image_CoolDown"),"ImageView")
	local Label_CoolDown = tolua.cast(Image_CoolDown:getChildByName("Label_CoolDown"),"Label")
	
	local tNow = g_GetServerTime()
	local types = VipType.VipBuyOpType_ArenaChallegeTimes
	local cd = g_VIPBase:getVipLevelCD(types)
	local coolingTime = (tbArenaData.tbRoleArenaInfo.lose_time + cd) - tNow
	if coolingTime < 0 then
		if timeid2 then 
			g_Timer:destroyTimerByID(timeid2)
			timeid2 = nil
		end
		Image_CoolDown:setVisible(false)
		return true
	else
		Image_CoolDown:setVisible(true)
		local cooldown = SecondsToTable(coolingTime)
		Label_CoolDown:setText(TimeTableToStr(cooldown,":",true))
		Label_CoolDown:setColor(ccc3(255, 69, 0))
	end
end

local function freshCdTime()
	if (not tbArenaWidget.layer) or (not tbArenaWidget.layer:isExsit()) then return end
	
	local Image_CoolDown = tolua.cast(tbArenaWidget.layer:getChildByName("Image_CoolDown"),"ImageView")
	Image_CoolDown:setVisible(false)
	local Image_Tip = tolua.cast(Image_CoolDown:getChildByName("Image_Tip"),"ImageView")
	
	local tNow = g_GetServerTime()
	local cd = g_VIPBase:getVipLevelCD(VipType.VipBuyOpType_ArenaChallegeTimes)
	local coolingTime = ((tbArenaData.tbRoleArenaInfo.lose_time or 0) + cd) - tNow
	
	local types = VipType.VipBuyOpType_ArenaChallegeCD
	if coolingTime > 0 then
		timeid2 = g_Timer:pushLoopTimer(1, PlayCoolingTime)
	end
	
	local function onClickCD(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
			local gold = g_VIPBase:getVipLevelCDGold(VipType.VipBuyOpType_ArenaChallegeTimes)
			if not g_CheckYuanBaoConfirm(gold, _T("清除冷却时间需要花费")..gold.._T("元宝，您的元宝不够是否前往充值？")) then
				return
			end
			
			local str = _T("是否花费")..gold.._T("元宝清除冷却时间？")
			g_ClientMsgTips:showConfirm(str, function() 
				local function f()
					local Image_CoolDown = tolua.cast(tbArenaWidget.layer:getChildByName("Image_CoolDown"),"ImageView")
					Image_CoolDown:setVisible(false)
					if timeid2 then 
						g_Timer:destroyTimerByID(timeid2)
						timeid2 = nil
					end
					g_ShowSysTips({text = _T("冷却时间清除成功")})
					gTalkingData:onPurchase(TDPurchase_Type.TDP_LOTTERY_NUM, 1, gold)
					
				end
				g_VIPBase:responseFunc(f)
				g_VIPBase:requestVipBuyTimesRequest(types)
			end)
		end
	end
	Image_Tip:setTouchEnabled(true)
	Image_Tip:addTouchEventListener(onClickCD)
end

function Game_Arena:closeWnd(tbData)
	tbArenaData.tbRankListData = nil
	g_Timer:destroyTimerByID(timeid)
	if timeid2 then 
		g_Timer:destroyTimerByID(timeid2)
		timeid2 = nil
	end
	g_Timer:destroyTimerByID(self.coolTimeID)
end

local function ActionCountTimer()
	local wndInstance = g_WndMgr:getWnd("Game_Arena")
	if wndInstance and wndInstance.rootWidget then
		local Button_Return = tolua.cast(wndInstance.rootWidget:getChildByName("Button_Return"),"Button")
		Button_Return:setTouchEnabled(false)
	end
	
	local ButtonIndex = 0
	local move = -700
	local function BtnRunAction()
		ButtonIndex = ButtonIndex % 4 + 1
		
		local wndInstance = g_WndMgr:getWnd("Game_Arena")
		if wndInstance and wndInstance.rootWidget then
			local Image_ChallengePNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_ChallengePNL"),"ImageView")
			if Image_ChallengePNL then
				local Button_RankListItem1 = tolua.cast(Image_ChallengePNL:getChildByName("Button_PlayerItem"..ButtonIndex),"Button")
				if Button_RankListItem1 then
					Button_RankListItem1:setTag(ButtonIndex)
					cardAction(Button_RankListItem1, move, freshRankListView)
				end
				
				local Button_RankListItem2 = tolua.cast(Image_ChallengePNL:getChildByName("Button_PlayerItem"..ButtonIndex+4),"Button")
				if Button_RankListItem2 then
					Button_RankListItem2:setTag(ButtonIndex+4)
					cardAction(Button_RankListItem2, -move, freshRankListView)
				end
			end
		end
	end
	
	BtnRunAction()
	timeid = g_Timer:pushLimtCountTimer(3,0.08, BtnRunAction)
end

----------------竞技场布阵相关 add by wb
local function onClick_Button_BuZhen()
    g_WndMgr:showWnd("Game_PublicBuZhen", handler(g_Arena_ZhenXing, g_Arena_ZhenXing.OnShowWndCallBack))
end


function Game_Arena:initWnd(widget)
	tbArenaData = {}
	tbArenaData.tbRoleArenaInfo = {}
	tbArenaWidget = {}
	tbArenaWidget.layer = widget
	
	--点击天梯
	local Image_RankClass = tolua.cast(self.rootWidget:getChildByName("Image_RankClass"),"ImageView")
	local Button_RankClass = tolua.cast(Image_RankClass:getChildByName("Button_RankClass"),"Button")
	local function showRankClass(pSender, nTag)
		g_WndMgr:showWnd("Game_ArenaRankClass")
	end
	g_SetBtnWithPressImage(Button_RankClass, 1, showRankClass, true, 1)
	
	--点击战报
	local Image_Report = tolua.cast(self.rootWidget:getChildByName("Image_Report"),"ImageView")
	local Button_Report = tolua.cast(Image_Report:getChildByName("Button_Report"),"Button")
	local function showReport(pSender, nTag)
		g_WndMgr:showWnd("Game_ArenaReport")
	end
	g_SetBtnWithPressImage(Button_Report, 1, showReport, true, 1)
	
	--点击排行榜
	local Image_RankList = tolua.cast(self.rootWidget:getChildByName("Image_RankList"),"ImageView")
	local Button_RankList = tolua.cast(Image_RankList:getChildByName("Button_RankList"),"Button")
	local function showRankList(pSender, nTag)
		g_WndMgr:showWnd("Game_ArenaRank")
	end
	g_SetBtnWithPressImage(Button_RankList, 1, showRankList, true, 1)
	
	--点击查看每日奖励
	local Image_ArenaReward = tolua.cast(self.rootWidget:getChildByName("Image_ArenaReward"),"ImageView")
	local Button_ArenaReward = tolua.cast(Image_ArenaReward:getChildByName("Button_ArenaReward"),"Button")
	local function openPromote(pSender, nTag)
		g_WndMgr:showWnd("Game_ArenaReward", Game_ArenaReward_Type.ArenaReward)
	end
	g_SetBtnWithPressImage(Button_ArenaReward, 1, openPromote, true, 1)
	
	--点击查看历史战绩
	local function openViewHistory()
		g_WndMgr:showWnd("Game_ArenaHistory") 
	end
	g_SetBtnAndPressWithString(self.rootWidget, "Button_ViewHistory", openViewHistory, true)
	
	tbArenaData.tbInterval = {}
	local CSV_ArenaDailyReward = g_DataMgr:getCsvConfig("ArenaDailyReward")
	for k,v in pairs(CSV_ArenaDailyReward) do
		table.insert(tbArenaData.tbInterval, k)
	end
	table.sort(tbArenaData.tbInterval)

	--刷新排名 add by zgj
	local Button_Refresh = tolua.cast(self.rootWidget:getChildByName("Button_Refresh"),"Button")
	local function refreshRank(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			if not g_CheckMoneyConfirm(25000, _T("刷新排名25000铜钱, 您的铜钱不足是否进行招财？")) then
				return
			end
			g_MsgMgr:sendMsg(msgid_pb.MSGID_ARENA_REFRESH_CHALLENGE_REQUEST)
			g_MsgNetWorkWarning:showWarningText()
		end
	end
	Button_Refresh:addTouchEventListener(refreshRank)
	
	local Image_NeedMoney = tolua.cast(self.rootWidget:getChildByName("Image_NeedMoney"),"ImageView")
	local BitmapLabel_NeedMoney = tolua.cast(Image_NeedMoney:getChildByName("BitmapLabel_NeedMoney"),"LabelBMFont")
	BitmapLabel_NeedMoney:setText(g_DataMgr:getGlobalCfgCsv("arena_refresh_challenge_price"))
	
	Button_Refresh:addTouchEventListener(refreshRank)

    --竞技场阵形设置按钮 add by wb
	local Image_BuZhen = tolua.cast(self.rootWidget:getChildByName("Image_BuZhen"),"ImageView")
	local Button_BuZhen = tolua.cast(Image_BuZhen:getChildByName("Button_BuZhen"),"Button")
	g_SetBtnWithPressImage(Button_BuZhen, 1, onClick_Button_BuZhen, true, 1)
end

function Game_Arena:checkData()
	if not tbArenaData.tbRankListData then
		g_MsgMgr:requestArenaInfo()
		return false 
	end
	return true
end

local function setRoleArenaReports(tbRoleArenaReports)
	local tb_ArenaReport1 = {}
	tb_ArenaReport1.role_name = tbRoleArenaReports.arena_report1.role_name
	tb_ArenaReport1.fightpoint = tbRoleArenaReports.arena_report1.fightpoint
	tb_ArenaReport1.rank_old = tbRoleArenaReports.arena_report1.rank_old
	tb_ArenaReport1.rank_new = tbRoleArenaReports.arena_report1.rank_new
	local tb_ArenaReport2 = {}
	tb_ArenaReport2.role_name = tbRoleArenaReports.arena_report2.role_name
	tb_ArenaReport2.fightpoint = tbRoleArenaReports.arena_report2.fightpoint
	tb_ArenaReport2.rank_old = tbRoleArenaReports.arena_report2.rank_old
	tb_ArenaReport2.rank_new = tbRoleArenaReports.arena_report2.rank_new
	
	local tb_ArenaReport = {}
	tb_ArenaReport.tb_ArenaReport1 = tb_ArenaReport1
	tb_ArenaReport.tb_ArenaReport2 = tb_ArenaReport2
	tb_ArenaReport.result = tbRoleArenaReports.result
	
	table.insert(tbArenaData.tbRoleArenaReports,tb_ArenaReport)
end

local function setRoleArenaInfo(tbRoleArenaInfo)
	tbArenaData.tbRoleArenaInfo.self_rank = tbRoleArenaInfo.self_rank
	tbArenaData.tbRoleArenaInfo.wins = tbRoleArenaInfo.wins
	tbArenaData.tbRoleArenaInfo.loses = tbRoleArenaInfo.loses
	tbArenaData.tbRoleArenaInfo.lose_time = tbRoleArenaInfo.lose_time
	tbArenaData.tbRoleArenaInfo.win_time_today = tbRoleArenaInfo.win_time_today
	tbArenaData.tbRoleArenaInfo.challenge_times = tbRoleArenaInfo.challenge_times
	tbRankReportsData = tbRoleArenaInfo.arena_reports
	
	if tbRoleArenaInfo.win_time_today then
		-- local nswap = tbRoleArenaInfo.win_time_today % 1000
		-- local nBuyTims = math.floor(nswap / 10)
		-- if nBuyTims <= 0 then
			-- nBuyTims = 0
		-- end
		-- g_Hero:setBuyArenaTimes(nBuyTims)
	end
	tbArenaData.tbRoleArenaReports = {}
	if tbRankReportsData then
		for key ,value in ipairs(tbRankReportsData) do
			setRoleArenaReports(value)
		end
	end
	
    --add wb竞技场阵形信息
    if tbRoleArenaInfo.buzhen_info then
        g_Arena_ZhenXing.Arena_BuZhen.zhen_fa_id = tbRoleArenaInfo.buzhen_info.zhen_fa_id
        g_Arena_ZhenXing.Arena_BuZhen.card_list = {}
        for i = 1, #tbRoleArenaInfo.buzhen_info.card_list  do
            table.insert(g_Arena_ZhenXing.Arena_BuZhen.card_list, 
            {Cell_index = tbRoleArenaInfo.buzhen_info.card_list[i].zhenxin_id, 
             Card_index = tbRoleArenaInfo.buzhen_info.card_list[i].card_index+1})
        end
    end

end 

local function setSingleRankInfo(tbRankData,nIndex)
	tbArenaData.tbRankListData[nIndex] = {}
	tbArenaData.tbRankListData[nIndex].role_uin = tbRankData.role_uin
	tbArenaData.tbRankListData[nIndex].role_name = tbRankData.role_name
	tbArenaData.tbRankListData[nIndex].fighting_point = tbRankData.fighting_point
	tbArenaData.tbRankListData[nIndex].official_rank = tbRankData.official_rank
	tbArenaData.tbRankListData[nIndex].main_card_cfg_id = tbRankData.main_card_cfg_id
	tbArenaData.tbRankListData[nIndex].main_card_star = tbRankData.main_card_star
	tbArenaData.tbRankListData[nIndex].vip_lev = tbRankData.vip_lev
	tbArenaData.tbRankListData[nIndex].rank = tbRankData.rank
	tbArenaData.tbRankListData[nIndex].role_lv = tbRankData.role_lv
	tbArenaData.tbRankListData[nIndex].breach_lv =  tbRankData.breach_lv
end

--更新竞技场表。。。
local function setArenaListViewData()
	tbArenaData.tbListViewData = {}
	for key, value in pairs(tbArenaData.tbRankListData) do
		table.insert(tbArenaData.tbListViewData, key)
	end
	table.sort(tbArenaData.tbListViewData)
end

function Game_Arena:getArenaReports()
	if tbArenaData and tbArenaData.tbRoleArenaReports then
		return tbArenaData.tbRoleArenaReports
	end
	return nil
end

--更新信息
function onRecvArenaData(msgData)
    --防止该窗口没有打开过的时候就调用的bug
    if not tbArenaData then return end

	--竞技场个人信息
	if msgData.arena_info then
		setRoleArenaInfo(msgData.arena_info)
		freshCdTime()
		--g_ArenaSystem:setArenaCD(tbArenaData.tbRoleArenaInfo.lose_time)
	end
	
	if not tbArenaData.tbRankListData then
		tbArenaData.tbRankListData = {}
	end
	
    if msgData.leavel_times then
		tbArenaData.tbRoleArenaInfo.leavel_times = msgData.leavel_times
		g_Hero:setArenaTimes(tbArenaData.tbRoleArenaInfo.leavel_times)
	end

	local bNeedFreshListView = nil
	--竞技场排行信息
	local tbRankData = msgData.rank_list
	if tbRankData then
		for key, value in ipairs(tbRankData) do
			setSingleRankInfo(value,key)
			bNeedFreshListView = true
		end
	end
	
	if bNeedFreshListView then
		setArenaListViewData()
	end
	
	if msgData.gain_prestige_times then
		tbArenaData.tbRoleArenaInfo.gain_prestige_times = msgData.gain_prestige_times
	end

	--add by zgj
	if msgData.update_coin then
		g_Hero:setCoins(msgData.update_coin)
		ActionCountTimer()
	end

    --add by wb

end

g_AniParamsArena = {}

function showArenaWinAnimation(funcCallBack, bIsWin)
	local function onClickClose()
		ActionCountTimer()
		if funcCallBack then
			funcCallBack()
		end
	end
	
	if bIsWin then
		local wndInstance = g_WndMgr:getWnd("Game_Arena")
		if wndInstance then
			local tbReports = wndInstance:getArenaReports()
			if tbReports then
				local tbData = tbReports[#tbReports]
				--[[
					tb_ArenaReport1 == arena_info
					属性名称和消息的名称在getArenaReports() 中修改了
				]]
				
				if tbData then
					g_AniParamsArena = {}
					
					if tbData.tb_ArenaReport1 then
						g_AniParamsArena.name = tbData.tb_ArenaReport1.role_name or "" --名称
						g_AniParamsArena.rank = tbData.tb_ArenaReport1.rank_old or 0 --排名
						g_AniParamsArena.reamStrength = tbData.tb_ArenaReport1.fightpoint or 0 --战力
						g_AniParamsArena.rankChange = tbData.tb_ArenaReport1.rank_new or 0 --上升名次
					else
						g_AniParamsArena.name = "" --名称
						g_AniParamsArena.rank = 0 --排名
						g_AniParamsArena.reamStrength = 0 --战力
						g_AniParamsArena.rankChange = 0 --上升名次
					end
					
					if tbData.tb_ArenaReport2 then
						g_AniParamsArena.back_Name = tbData.tb_ArenaReport2.role_name or "" --名称
						g_AniParamsArena.back_Rank = tbData.tb_ArenaReport2.rank_old or 0 --排名
						g_AniParamsArena.back_ReamStrength = tbData.tb_ArenaReport2.fightpoint or 0 --战力
						g_AniParamsArena.back_RankChange = tbData.tb_ArenaReport2.rank_new or 0 --上升名次
					else
						g_AniParamsArena.back_Name = "" --名称
						g_AniParamsArena.back_Rank = 0 --排名
						g_AniParamsArena.back_ReamStrength = 0 --战力
						g_AniParamsArena.back_RankChange = 0 --上升名次
					end
					
					g_AniParamsArena.funcEndCallBack = onClickClose
					
					g_ShowRankLevelUpAnimation(g_AniParamsArena)
				end
			end
		end
	else
		onClickClose()
	end
	
end

function BuyChallengeTimesResponse(msgData)
	local function BuyChallengeTimescallback()
		local WndVisible = g_WndMgr:isVisible("Game_Assistant") 
		if WndVisible == true then
			g_WndMgr:openWnd("Game_Assistant",true) 
		end
	end
	
	if tbArenaData and tbArenaData.tbRoleArenaInfo and tbArenaData.tbRoleArenaInfo.leavel_times then
		tbArenaData.tbRoleArenaInfo.leavel_times = msgData.leavel_times
	end 
	g_ShowRewardMsgConfrim(macro_pb.ITEM_TYPE_ARENA_TIME, 1, BuyChallengeTimescallback)
end

function GainPrestigeResponse(msgData)
	tbArenaData.tbRoleArenaInfo.gain_prestige_times = msgData.gain_prestige_times
	local nGainPrestige = msgData.updated_prestige - g_Hero:getPrestige()

	g_Hero:setPrestige(msgData.updated_prestige)
	g_ShowRewardMsgConfrim(macro_pb.ITEM_TYPE_PRESTIGE, nGainPrestige)
end

function getTbRoleArenaInfo()
	if tbArenaData and tbArenaData.tbRoleArenaInfo then
		return tbArenaData.tbRoleArenaInfo
	end
	return nil
end

function getTbInterval()
	return tbArenaData.tbInterval
end

function Game_Arena:openWnd(tbData)
	if g_bReturn then
		return
	end

	local wndInstance = g_WndMgr:getWnd("Game_Arena")
	if wndInstance then
		if 0 == Arena_Left and  0 == Arena_Right then 
			local Image_ChallengePNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_ChallengePNL"),"ImageView")
			if Image_ChallengePNL then
				local RankListItem = tolua.cast(Image_ChallengePNL:getChildByName("Button_PlayerItem"..1),"Button")
				if RankListItem then
					Arena_Left = RankListItem:getPositionX()
				end

				RankListItem = tolua.cast(Image_ChallengePNL:getChildByName("Button_PlayerItem"..5),"Button")
				if RankListItem then
					Arena_Right = RankListItem:getPositionX()
				end
			end
			
		end
		if 0 ~= Arena_Left and  0 ~= Arena_Right then  
			for i=1, 8 do
				local Image_ChallengePNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_ChallengePNL"),"ImageView")
				local Button_RankListItem = tolua.cast(Image_ChallengePNL:getChildByName("Button_PlayerItem"..i),"Button")
				if not Button_RankListItem then break end

				local SrcPos = Button_RankListItem:getPosition()
				if i < 5 then
					Button_RankListItem:setPosition(ccp(Arena_Left,SrcPos.y))
				else
					Button_RankListItem:setPosition(ccp(Arena_Right,SrcPos.y))
				end
			end
		end
	end
	
	
	timeid2 = nil
	
	freshCdTime()
	ActionCountTimer()
end

function Game_Arena:ModifyWnd_viet_VIET()
	for i = 1, 8 do 
		local Button_PlayerItem = self.rootWidget:getChildAllByName("Button_PlayerItem"..i)
    	local Label_TeamStrengthenLB = Button_PlayerItem:getChildAllByName("Label_TeamStrengthenLB")
		local BitmapLabel_TeamStrength = Button_PlayerItem:getChildAllByName("BitmapLabel_TeamStrength")
    	g_AdjustWidgetsPosition({Label_TeamStrengthenLB, BitmapLabel_TeamStrength},1)
    end
    local BitmapLabel_NeedMoneyLB = self.rootWidget:getChildAllByName("BitmapLabel_NeedMoneyLB")
    BitmapLabel_NeedMoneyLB:setPositionX(-30)
end

----------------竞技场阵形------------------------
Class_Arena_ZhenXing = class("Class_Arena_ZhenXing")
Class_Arena_ZhenXing.__index = Class_Arena_ZhenXing

function Class_Arena_ZhenXing:ctor()
    self.Arena_BuZhen = {	
            zhen_fa_id = 1,		-- 阵型ID
	        card_list = {}      -- 上阵卡牌的格子信息，（ZhenXinInfo_Cell）
        }
end

local function onClick_Button_Confirm(pSender, nTag)
    if gUI_PublicBuzhen == nil then return end
    g_MsgNetWorkWarning:showWarningText(true)
    local msg = zone_pb.ArenaBuZhenRequest()

    msg.buzhen_info.zhen_fa_id = gUI_PublicBuzhen.ZF_info.zhen_fa_id

    for i = 1, #gUI_PublicBuzhen.ZF_info.card_list  do
    	local tmpInfo = common_pb.GeneralZhenXinInfo()
		tmpInfo.zhenxin_id = gUI_PublicBuzhen.ZF_info.card_list[i].Cell_index
		tmpInfo.card_index = gUI_PublicBuzhen.ZF_info.card_list[i].Card_index -1

        table.insert(msg.buzhen_info.card_list, tmpInfo)
    end
    g_MsgMgr:sendMsg(msgid_pb.MSGID_ARENA_BUZHEN_REQUEST,msg)
end

--布阵界面打开是的回调
function Class_Arena_ZhenXing:OnShowWndCallBack(rootWidget)
    local Button_Confirm = tolua.cast(rootWidget:getChildAllByName("Button_StartBattle"), "Button") 
    Button_Confirm:setVisible(false)--借用Button_Confirm变量设置Button_StartBattle不可见
    Button_Confirm = tolua.cast(rootWidget:getChildAllByName("Button_Confirm"), "Button") 
    Button_Confirm:setVisible(true)

    g_SetBtnWithEvent(Button_Confirm, 1, onClick_Button_Confirm, true)
    self:InitZhenxin()
end

function Class_Arena_ZhenXing:InitZhenxin()
    gUI_PublicBuzhen:UpdataBuZhenView(self.Arena_BuZhen)
end

--布阵信息的返回
function Class_Arena_ZhenXing:ResponseBuZhen(tbMsg)
    g_MsgNetWorkWarning:closeNetWorkWarning()
	cclog("Class_Arena_ZhenXing:ResponseBuZhen")
	local msgDetail = zone_pb.ArenaBuZhenResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

    self.Arena_BuZhen.zhen_fa_id = msgDetail.buzhen_info.zhen_fa_id
    self.Arena_BuZhen.card_list = {}
    for i = 1, #msgDetail.buzhen_info.card_list  do
        table.insert(self.Arena_BuZhen.card_list, 
        {Cell_index = msgDetail.buzhen_info.card_list[i].zhenxin_id, 
         Card_index = msgDetail.buzhen_info.card_list[i].card_index+1})
    end

    g_WndMgr:closeWnd("Game_PublicBuZhen")
end 
----------------------------------------------------
g_Arena_ZhenXing = Class_Arena_ZhenXing.new()
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ARENA_BUZHEN_RESPONSE, handler(g_Arena_ZhenXing,g_Arena_ZhenXing.ResponseBuZhen)) --布阵返回
