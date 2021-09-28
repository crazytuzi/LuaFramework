-------------------------------------------------------------------------------------
-- 文件名:	HJW_ArenaKuaFu.lua
-- 版  权:	(C)深圳市美天互动有限公司
-- 创建人:	
-- 日  期:	2016-06-23
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  跨服战主界面
---------------------------------------------------------------------------------------

Game_ArenaKuaFu = class("Game_ArenaKuaFu")
Game_ArenaKuaFu.__index = Game_ArenaKuaFu

function Game_ArenaKuaFu:initWnd()
end

function Game_ArenaKuaFu:openWnd()	

	g_FormMsgSystem:RegisterFormMsg(FormMsg_ArenaKuaFuaOpenWnd, handler(self, self.openWndArena))
	if g_bReturn  then 
		if g_ArenaKuaFuData:getExitBalttleFlag() then 
			g_ArenaKuaFuData:setExitBalttleFlag(false)
			g_ArenaKuaFuData:requestSelfCrossRank()
		else
			self:openWndArena()
		end
		return  
	end

	self:openWndArena()
end

function Game_ArenaKuaFu:closeWnd()
	g_Timer:destroyTimerByID(self.efreshRemainTime)
	self.efreshRemainTime = nil	
	
	self:removeTiemObj(-1)
	g_ArenaKuaFuData:setViewPlayerKuaFuFlag(true)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_ArenaKuaFuaOpenWnd)
end

function Game_ArenaKuaFu:openWndArena()

	--领取奖励与昨天排名，刷新奖励倒计时
	self:getTheRewards()

	--是否冷却中 
	self:cooling()
	
	--挑战次数
	self:challengeCount()
	
	--当前排名与当天排名变化列表
	self:rankingList()
	
	--功能按钮
	self:functionButton()
	
	--被挑战者列表
	self:arenaPosList()
	
	--点击刷新被挑战者信息
	self:refreshArenaList()
end

--奖励预览
function Game_ArenaKuaFu:RewardsShow()
	local hsRank = g_ArenaKuaFuData:getHsRank()
	local rank = g_ArenaKuaFuData:returnRankArea(hsRank)
	local DropPackClientID = g_DataMgr:getCsvConfig("ArenaDailyRewardKuaFu")[rank].DropPackClientID
	local CSV_DropItem = g_DataMgr:getCsvConfig_SecondKeyTableData("DropSubPackClient", DropPackClientID)
	local tbData = {
		nRewardStatus = 2,
		tbParamentList = {},
		updateHeroResourceInfo = function() end,
	}
	for index = 1, #CSV_DropItem do
		table.insert(tbData.tbParamentList, CSV_DropItem[index])
	end                                                                                                  
	g_WndMgr:showWnd("Game_RewardBox", tbData)
end

--领取奖励与昨天排名，刷新奖励倒计时
function Game_ArenaKuaFu:getTheRewards()
	
	local rootWidget = self.rootWidget
	--领取奖励
	local Button_GetReward =  tolua.cast(rootWidget:getChildByName("Button_GetReward"), "Button")
	
	local function onReward(pSender, eventType)

		if g_ArenaKuaFuData:getHsRank() <= 0 then 
			g_ShowSysWarningTips({text = _T("您在跨服天榜里没有名次，请先参加比赛哟。")})
			return 
		end
		
		local rank = g_DataMgr:getGlobalCfgCsv("kuafu_arena_need_rank")
		if g_Hero.nRank <= 0 or g_Hero.nRank > rank then 
			g_ShowSysWarningTips({text = string.format(_T("挑战需要在本服天榜达到前%d名"), rank)})
			return 
		end
		
		if g_ArenaKuaFuData:getIsTodayReward() then 
			-- g_ShowSysWarningTips({text = _T("您今天已经领取了奖励")})
			self:RewardsShow()
			return 
		end
		
		g_ArenaKuaFuData:requestCrossRecvReward()
	end
	g_SetBtnWithPressImage(Button_GetReward, 1, onReward, true, 1)
	--您昨日排名为第%d名!
	local Label_RankYesterday =  tolua.cast(rootWidget:getChildByName("Label_RankYesterday"), "Label")
	Label_RankYesterday:setText(string.format(_T("您昨日排名为第%d名!"), g_ArenaKuaFuData:getHsRank()))
	local Label_RefreshRemainTimeLB =  tolua.cast(rootWidget:getChildByName("Label_RefreshRemainTimeLB"), "Label")
	--倒计时
	local Label_RefreshRemainTime =  tolua.cast(rootWidget:getChildByName("Label_RefreshRemainTime"), "Label")
	-- Label_RefreshRemainTime:setPositionX(Label_RefreshRemainTimeLB:getSize().width)
	local nServerTime = g_GetServerTime()
	local seconds = self:hoursOfTheCountdown24()
	local tbServerTime = SecondsToTable( seconds )
	Label_RefreshRemainTime:setText(TimeTableToStr(tbServerTime, ":"))
	
	self.efreshRemainTime = g_Timer:pushLoopTimer(1,function()
		local wnd = g_WndMgr:getWnd("Game_ArenaKuaFu")
		if wnd and wnd.rootWidget then
			local Label_RefreshRemainTime =  tolua.cast(wnd.rootWidget:getChildByName("Label_RefreshRemainTime"), "Label")
			local seconds = wnd:hoursOfTheCountdown24()
			local tbServerTime = SecondsToTable( seconds )
			Label_RefreshRemainTime:setText(TimeTableToStr(tbServerTime, ":"))
		end
	end)
	
	g_AdjustWidgetsPosition({Label_RefreshRemainTimeLB, Label_RefreshRemainTime}, 10)
	
end

function Game_ArenaKuaFu:removeTiemObj(nTime)
	if nTime < 0 then 
		if self.downTime then 
			g_Timer:destroyTimerByID(self.downTime)
			self.downTime = nil
		end
		return false
	end
	return true
end

--是否冷却中 
function Game_ArenaKuaFu:cooling()
	local rootWidget = self.rootWidget
	local Image_CoolDown =  tolua.cast(rootWidget:getChildByName("Image_CoolDown"), "ImageView")
	local Image_Tip =  tolua.cast(Image_CoolDown:getChildByName("Image_Tip"), "ImageView")
	
	local function onTip(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			local types = VipType.VipBuyOpType_CrossArenaChallegeCD
			local gold = g_VIPBase:getVipLevelCDGold(types)
			local txt = string.format(_T("清除冷却时间需要花费%d元宝，您的元宝不够是否前往充值？"), gold)
			if not g_CheckYuanBaoConfirm(gold, txt) then
				return 
			end
			local function onRemoveCD()
				local function removeCdFunc()
					g_ArenaKuaFuData:setLoseTime(0)
					local txt = string.format(_T("冷却时间清除成功，下一VIP等级将减少消耗的元宝"))
					g_ShowSysWarningTips({text = txt})
					
					local wnd = g_WndMgr:getWnd("Game_ArenaKuaFu")
					if wnd and wnd.rootWidget then
						local Image_CoolDown =  tolua.cast(wnd.rootWidget:getChildByName("Image_CoolDown"), "ImageView")
						local Image_Tip =  tolua.cast(Image_CoolDown:getChildByName("Image_Tip"), "ImageView")
						Image_Tip:setTouchEnabled(false)
						Image_CoolDown:setVisible(false)
					end
					gTalkingData:onPurchase(TDPurchase_Type.TDP_ARENA_KUA_FU_REMOVE_CD, 1, gold)
				end
				
				g_VIPBase:responseFunc(removeCdFunc)
				g_VIPBase:requestVipBuyTimesRequest(types)
				
			end
			local txt = string.format(_T("是否花费%d元宝清除冷却时间？"), gold)
			g_ClientMsgTips:showConfirm(txt, onRemoveCD, nil)
			
		end
	end
	Image_Tip:addTouchEventListener(onTip)	
	
	local times =  g_ArenaKuaFuData:getLoseTime() - g_GetServerTime()
	local flag = self:removeTiemObj(times)
	Image_Tip:setTouchEnabled(flag)
	Image_CoolDown:setVisible(flag)
	
	local function showDownTime(coolDownTime, imageObj)
		local cooldown = SecondsToTable(coolDownTime)
		local timeTable = TimeTableToStr(cooldown,":",true)
		--冷却时间
		local Label_CoolDown =  tolua.cast(imageObj:getChildByName("Label_CoolDown"), "Label")
		Label_CoolDown:setText(timeTable)
	end
	showDownTime(times, Image_CoolDown)
	
	--战斗失败冷却倒计时
	self.downTime = g_Timer:pushLoopTimer(1,function()
		local wnd = g_WndMgr:getWnd("Game_ArenaKuaFu")
		if not wnd or not wnd.rootWidget then 
			self:removeTiemObj(-1)
			return 
		end
		local Image_CoolDown =  tolua.cast(wnd.rootWidget:getChildByName("Image_CoolDown"), "ImageView")
		local coolDownTime =  g_ArenaKuaFuData:getLoseTime() - g_GetServerTime()
		if self:removeTiemObj(coolDownTime) then 
			--冷却时间
			showDownTime(coolDownTime, Image_CoolDown)
		else
			local Image_Tip =  tolua.cast(Image_CoolDown:getChildByName("Image_Tip"), "ImageView")
			Image_Tip:setTouchEnabled(false)
			Image_CoolDown:setVisible(false)
		end
	end)
	
end

--挑战次数
function Game_ArenaKuaFu:challengeCount()
	local rootWidget = self.rootWidget
	local Button_AddTimes =  tolua.cast(rootWidget:getChildByName("Button_AddTimes"), "Button")
	
	local function onAddTimes(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			-- echoj("增加挑战次数")	
			local types = VipType.VipBuyOpType_CrossArenaChallegeTimes
			local cntNum = g_VIPBase:getVipLevelCntNum(types)--当前vip等级下可以购买的次数
			if cntNum - g_VIPBase:getAddTableByNum(types) == 0 then 
				g_ShowSysTips({text=_T("您今日跨服天榜的购买次数已用完，下一VIP等级可以增加购买次数上限")})
				return
			end
	
			local gold = g_VIPBase:getVipLevelCntGold(types)
			local txt = string.format(_T("购买跨服天榜次数需要花费%d元宝，您的元宝不够是否前往充值？"), gold)
			if not g_CheckYuanBaoConfirm(gold, txt) then
				return
			end
			
			local str = string.format(_T("是否花费%d元宝购买1次跨服天榜次数？"), gold)
			g_ClientMsgTips:showConfirm(str, function() 
				local function serverResponseCall(tiems)			
					g_ArenaKuaFuData:setLeavelTimes(g_ArenaKuaFuData:getLeavelTimes() + 1 )
					local wnd = g_WndMgr:getWnd("Game_ArenaKuaFu")
					if wnd and wnd.rootWidget then
						wnd.BitmapLabel_RemainNum_:setText(g_ArenaKuaFuData:getLeavelTimes())
						local txt = string.format(_T("成功购买1次跨服天榜次数，您还可购买%d次。"), cntNum - tiems)
						g_ShowSysTips({text = txt})
						g_adjustWidgetsRightPosition({wnd.BitmapLabel_RemainNum_, Button_AddTimes}, -12)
					end
					gTalkingData:onPurchase(TDPurchase_Type.TDP_ARENA_KUA_FU_BUY_NUM, 1, gold)
				end
				g_VIPBase:responseFunc(serverResponseCall)
				g_VIPBase:requestVipBuyTimesRequest(VipType.VipBuyOpType_CrossArenaChallegeTimes)
			end)
		end
	end
	Button_AddTimes:setTouchEnabled(true)
	Button_AddTimes:addTouchEventListener(onAddTimes)	
	
	local BitmapLabel_RemainNum =  tolua.cast(rootWidget:getChildByName("BitmapLabel_RemainNum"), "LabelBMFont")
	BitmapLabel_RemainNum:setText(g_ArenaKuaFuData:getLeavelTimes())
	self.BitmapLabel_RemainNum_ = BitmapLabel_RemainNum
	
	local Image_RemainNum2 =  tolua.cast(rootWidget:getChildByName("Image_RemainNum2"), "ImageView")
	
	g_adjustWidgetsRightPosition({BitmapLabel_RemainNum, Button_AddTimes}, -12)
end


--被挑战者列表
function Game_ArenaKuaFu:arenaPosList()
	
	local rootWidget = self.rootWidget	
	
	local rankListData = g_ArenaKuaFuData:getRankList()	
	for key = 1, #rankListData do 
	
		local rankList = rankListData[key]
		
		local CSV_CardBase = g_DataMgr:getCardBaseCsv(rankList.main_card_cfg_id, rankList.main_card_star)
		
		local Button_ArenaPos =  tolua.cast(rootWidget:getChildByName("Button_ArenaPos"..key), "Button")
		
		local function onArenaPos(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				-- 点击后判断玩家在本服天榜的排名是否大于%d名
				local rank = g_DataMgr:getGlobalCfgCsv("kuafu_arena_need_rank")
				if g_Hero.nRank <= 0 or g_Hero.nRank > rank then 
					local txt = string.format(_T("挑战需要在本服天榜达到前%d名"), rank)
					g_ShowSysWarningTips({text = txt})
					return 
				end
				
				-- 判断次数是否已经用完
				if g_ArenaKuaFuData:getLeavelTimes() == 0 then 
					local txt = string.format(_T("您的挑战次数已用完"))
					g_ShowSysWarningTips({text = txt})
					return 
				end
				
				--判断是否在冷却中
				local times =  g_ArenaKuaFuData:getLoseTime() - g_GetServerTime()
				if not (times < 0) then 
					g_ShowSysWarningTips({text = string.format(_T("您刚挑战失败了，处于冷却中，请稍等片刻。"))})
					return 
				end
		
				--判断是否是自己
				if rankList.role_uin == g_MsgMgr:getUin() then 
					g_ShowSysWarningTips({text = string.format(_T("您不能挑战自己!"))})
					return 
				end
				
				local tagRank = pSender:getTag()
				g_ArenaKuaFuData:requestChallege(tagRank)
			end
		end
		Button_ArenaPos:setTouchEnabled(true)
		Button_ArenaPos:addTouchEventListener(onArenaPos)	
		Button_ArenaPos:setTag(rankList.rank)
		Button_ArenaPos:setAnchorPoint(ccp(0.5, 0.0))
		Button_ArenaPos:setSize(CCSize(CSV_CardBase.CardWidth, CSV_CardBase.CardHeight))
				
		local Panel_Pos =  tolua.cast(Button_ArenaPos:getChildByName("Panel_Pos"), "Layout")
		local Image_Shadow =  tolua.cast(Panel_Pos:getChildByName("Image_Shadow"), "ImageView")
		
		local Image_Card =  tolua.cast(Panel_Pos:getChildByName("Image_Card"), "ImageView")
		
		local CCNode_Skeleton = g_CocosSpineAnimation(CSV_CardBase.SpineAnimation, 1)
		Image_Card:removeAllNodes()
		Image_Card:setPositionXY(CSV_CardBase.Pos_X, CSV_CardBase.Pos_Y)
		Image_Card:addNode(CCNode_Skeleton)
		g_runSpineAnimation(CCNode_Skeleton, "idle", true)
		
		--玩家名字
		local Label_Name =  tolua.cast(Panel_Pos:getChildByName("Label_Name"), "Label")
		Label_Name:setText(getFormatSuffixLevel(rankList.role_name, g_GetCardEvoluteSuffixByEvoLev(rankList.breach_lv))..".s"..rankList.world_id)
		g_SetCardNameColorByEvoluteLev(Label_Name, rankList.breach_lv)
		Label_Name:setPositionXY(CSV_CardBase.HPBarX, CSV_CardBase.HPBarY + 30)
	
		--星级
		local AtlasLabel_StarLevel =  tolua.cast(Panel_Pos:getChildByName("AtlasLabel_StarLevel"), "LabelAtlas")
		AtlasLabel_StarLevel:setValue(g_ArenaKuaFuData:getStarAtlasLable(rankList.main_card_star))
		AtlasLabel_StarLevel:setPositionXY(CSV_CardBase.HPBarX, CSV_CardBase.HPBarY)
		
		--排名
		local Label_Rank = tolua.cast(Panel_Pos:getChildByName("Label_Rank"), "Label")
		Label_Rank:setText(string.format(_T("第%d名"), rankList.rank))
		
		--战斗力
		local Image_PersonalStrength = tolua.cast(Button_ArenaPos:getChildByName("Image_PersonalStrength"), "ImageView")
		local BitmapLabel_PersonalStrength = tolua.cast(Image_PersonalStrength:getChildByName("BitmapLabel_PersonalStrength"), "LabelBMFont")
		BitmapLabel_PersonalStrength:setText(tostring(rankList.fighting_point))
	end
end

--当前排名与当天排名变化列表
function Game_ArenaKuaFu:rankingList()
	local rootWidget = self.rootWidget
	local Image_RankPNL =  tolua.cast(rootWidget:getChildByName("Image_RankPNL"), "ImageView")
	--排名
	local function onInfo(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			g_WndMgr:showWnd("Game_ArenaKuaFuRank")
		end
	end
	Image_RankPNL:setTouchEnabled(true)
	Image_RankPNL:addTouchEventListener(onInfo)
	

	-- 当前排名
	local Label_MyPoints =  tolua.cast(Image_RankPNL:getChildByName("Label_MyPoints"), "Label")
	Label_MyPoints:setText(string.format(_T("您当前在跨服天榜排名第%d"), g_ArenaKuaFuData:getSelfRank()))
	
	-- 显示玩家当前的排名。
	-- 以及当前跨服排行榜的榜单前5名。
	for rankIndex = 1, 5 do
		local rankListData = g_ArenaKuaFuData:getRankTopFive(rankIndex)
		if not rankListData then return end
		 
		local rank = rankListData.rank
		local name = rankListData.name

		local Label_Name =  tolua.cast(Image_RankPNL:getChildByName("Label_Name"..rankIndex), "Label")
		Label_Name:setText(string.format(_T("%d. %s"), rank, name))

		local Label_Rank =  tolua.cast(Label_Name:getChildByName("Label_Rank"), "Label")
		Label_Rank:setText(string.format(_T("第%d名"), rank))
	end
	
end

--功能按钮
function Game_ArenaKuaFu:functionButton()
	local rootWidget = self.rootWidget
	--奖励
	local Button_ArenaReward =  tolua.cast(rootWidget:getChildByName("Button_ArenaReward"), "Button")
	local function onArenaReward(pSender, nTag)
		g_WndMgr:showWnd("Game_ArenaReward", Game_ArenaReward_Type.ArenaRewardKuaFu)
	end
	g_SetBtnWithPressImage(Button_ArenaReward, 1, onArenaReward, true, 1)
	--段位
	local Button_RankClass =  tolua.cast(rootWidget:getChildByName("Button_RankClass"), "Button")
	local function onRankClass(pSender, nTag)
		g_WndMgr:showWnd("Game_ArenaRankClass")
	end
	g_SetBtnWithPressImage(Button_RankClass, 1, onRankClass, true, 1)
	
	--阵容
	local Button_BuZhen =  tolua.cast(rootWidget:getChildByName("Button_BuZhen"), "Button")
	local function onBuZhen(pSender, nTag)
		g_WndMgr:showWnd("Game_PublicBuZhen", handler(self, self.zhenFa))
	end
	g_SetBtnWithPressImage(Button_BuZhen, 1, onBuZhen, true, 1)
	
	--战报
	local Button_Report =  tolua.cast(rootWidget:getChildByName("Button_Report"), "Button")
	local function onReport(pSender, nTag)
		echoj("战报")	
		g_WndMgr:showWnd("Game_ArenaReortKuaFu")
	end
	g_SetBtnWithPressImage(Button_Report, 1, onReport, true, 1)
end

function Game_ArenaKuaFu:refreshArenaList()
	local rootWidget = self.rootWidget
	local Button_Refresh =  tolua.cast(rootWidget:getChildByName("Button_Refresh"), "Button")
	local function onArenaReward(pSender, nTag)
		local refreshYuanbao = g_DataMgr:getGlobalCfgCsv("kuafu_arena_refresh_yuanbao")
		local txt = string.format(_T("刷新对手需要花费%d元宝，您的元宝不够是否前往充值？"), refreshYuanbao)
		if not g_CheckYuanBaoConfirm(refreshYuanbao, txt) then
			return
		end
		
		local function onRefresh()
			g_ArenaKuaFuData:requestRefreshChallege()
		end
		
		local txt = string.format(_T("是否花费%d元宝刷新对手？"), refreshYuanbao)
		g_ClientMsgTips:showConfirm(txt, onRefresh, nil)
	end
	g_SetBtnWithPressImage(Button_Refresh, 1, onArenaReward, true, 1)
end

--[[24小时倒计时
	return seconds 倒计时秒数 如果为零 刷新
]]
function Game_ArenaKuaFu:hoursOfTheCountdown24()
	-- local times = os.date("*t", os.time() )
	local times = os.date("*t", g_GetServerTime() )
	local h = (24 - times.hour) * 3600
	local m = (60 - times.min) * 60
	local s = 60 - times.sec	
	local seconds = h + m + s
	return seconds
end

local function onClick_Button_Confirm(pSender, nTag)
    if gUI_PublicBuzhen == nil then return end
	g_ArenaKuaFuData:requestCrossBuzhen(gUI_PublicBuzhen.ZF_info)
end

function Game_ArenaKuaFu:zhenFa(rootWidget)
	local Button_Confirm = tolua.cast(rootWidget:getChildAllByName("Button_StartBattle"), "Button") 
    Button_Confirm:setVisible(false)--借用Button_Confirm变量设置Button_StartBattle不可见
    Button_Confirm = tolua.cast(rootWidget:getChildAllByName("Button_Confirm"), "Button") 
    Button_Confirm:setVisible(true)

    g_SetBtnWithEvent(Button_Confirm, 1, onClick_Button_Confirm, true)
	gUI_PublicBuzhen:UpdataBuZhenView(g_ArenaKuaFuData.kuaFuCardBuZhen_)	
end


