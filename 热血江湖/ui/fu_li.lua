-------------------------------------------------------
module(..., package.seeall)

local require = require;
require("ui/ui_funcs")

local ui = require("ui/base");
local activitySyncTbl = nil
local first_pay_gift = 1 -- 首充 10
local pay_gift = 2 --累积充值20
local consume_gift = 3 --50
local uograde_gift = 4  --60
local investment_fund = 5 --70
local growth_fund = 6 -- 80
local double_drop = 7 -- 110
local extra_drop = 8 -- 120
local exchange_gift = 9 -- 130
local logingift_gift = 10 -- 100
local gift_package = 11 -- 140
local charge_every_day = 12  --每日充值奖励类型30
local charge_continuity = 13  --连续充值奖励类型40
local battle_enjoy = 14  --连续充值奖励类型 90
local up_level  = 15  --升级特惠 135
local direct_purchase = 16 -- 直购礼包
local one_arm_bandit = 17 -- 老虎机
local advertisement = 18 -- 广告
local pay_rank = 19  --充值排行 6
local consume_rank = 20  --消费排行 7
local lucky_gift = 21  --新登录活动 8
local share_gift = 22  --共享好礼活动 9
local cycle_fund = 23  --循环基金 65
local buy_get = 24 --买赠活动 24
local useItems_reward = 25 --连续使用物品获得奖励 25
local giveMeRedPacket = 26 --红包拿来活动 26
local mobile_gift = 100  --手机验证奖励 135
local more_role_discount = 28 -- 拼多多，优惠团购
local schedule_gift = 29 -- 活跃领奖活动
local inheritDivinework = 30 -- 传世大酬宾
local backRoleDoubleDrop = 31 -- 回归玩家双倍掉落
local oppoActivity = 32 -- 活动

-- local l_nThreeDaySecond =  259200 	--3*24*60*60 --月卡学费最小间隔
--体力所需图片资源
local vit_bg_icon = {2872,2873,2902}
local vit_title_bg_icon = {2875,2874}
--月份
local monthNumber = {454,455,456,457,458,459,460,461,462,463,464,465,}
--Vip
local vipNumber = {466,467,468,469,470,471,472,473,474,475,476,477,478,479,480,}
local VIPDOUBLE = 2
local LAYER_QDT = "ui/widgets/qdt"
local RowitemCount = 6
local LAYER_MRCZSL = "ui/widgets/mrczsl"

-- 左侧
local SingInState			= 1
local LineState				= 2
-- local WeekCardState 		= 3
-- local MonthCardState		= 4
local VitState				= 3
-- local JiniandajiState 		= 6
-- local HuhushengfengState 	= 7


-------------------------------------------------------
wnd_fu_li = i3k_class("wnd_fu_li", ui.wnd_base)

function wnd_fu_li:ctor()
	self._canUse = false
	self._time = 0
	self._percent = 1
	self._activitiesList = {}
	self._index = 0
	self._current_bt = nil
	self._current_select_icon = nil
	self._chongji_auto_index   = 0
	self._lianxu_auto_index = 0
	self._luckyGift_auto_index = 0
	self._useItemReward_auto_index = 0
	self._scheduleGift_auto_index = 0
	self._firstFourRedPoints = {}
	self.isMonthShow = false
	self.isXiaoyaoShow = false
	self.isMonthToGet = false
	self.isXiaoyaoToGet = false
	--活动协议 跳表
	activitySyncTbl =
	{

		[first_pay_gift] =  	{sync = i3k_sbean.sync_activities_firstpaygift,		index = 0 ,	sort = 10},
		[pay_gift] = 	 		{sync = i3k_sbean.sync_activities_paygift,			index = 0, 	sort = 20},
		[consume_gift] = 		{sync = i3k_sbean.sync_activities_consumegift,		index = 0, 	sort = 50},
		[uograde_gift] = 		{sync = i3k_sbean.sync_activities_gradegift,		index = 0,	sort = 60},
		[investment_fund] = 	{sync = i3k_sbean.sync_activities_investmentfund,	index = 0, 	sort = 70},
		[growth_fund] = 		{sync = i3k_sbean.sync_activities_growthfund,		index = 0, 	sort = 80},
		[double_drop] = 		{sync = i3k_sbean.sync_activities_doubledrop,		index = 0, 	sort = 110},
		[extra_drop] = 			{sync = i3k_sbean.sync_activities_extradrop,		index = 0, 	sort = 120},
		[exchange_gift] = 		{sync = i3k_sbean.sync_activities_exchangegift,		index = 0, 	sort = 130},
		[logingift_gift] = 		{sync = i3k_sbean.sync_activities_logingift,		index = 0, 	sort = 100},
		[gift_package] = 		{sync = i3k_sbean.sync_activities_giftpackage,		index = 0, 	sort = 250},
		[charge_every_day] = 	{sync = i3k_sbean.pay_gift_everyday,				index = 0, 	sort = 30},
		[charge_continuity] = 	{sync = i3k_sbean.lastpaygift_sync,					index = 0, 	sort = 40},
		[battle_enjoy] = 		{sync = i3k_sbean.activitychallengegift_sync,		index = 0, 	sort = 90},
		[mobile_gift] = 		{sync = i3k_sbean.activitychallengegift_sync,		index = 0, 	sort = 135},
		[up_level] = 			{sync = i3k_sbean.upgradepurchase_sync,				index = 0, 	sort = 35},
		[direct_purchase] =		{sync = i3k_sbean.sync_direct_purchase,				index = 0, 	sort = 15},
		[one_arm_bandit]  =     {sync = i3k_sbean.sync_oneArmBandit,   				index = 0, 	sort = 16},
		[advertisement]   =     {sync = i3k_sbean.syncAdvertisement,   				index = 0,  sort = 5},
		[pay_rank]		  =		{sync = i3k_sbean.syncRechargeRank,   				index = 0,  sort = 6},
		[consume_rank]	  =		{sync = i3k_sbean.syncConsumeRank,   				index = 0,  sort = 7},
		[lucky_gift]	  =		{sync = i3k_sbean.syncLuckyGift,   					index = 0,  sort = 8},
		[share_gift]	  =		{sync = i3k_sbean.syncSharedGift,   				index = 0,  sort = 9},
		[cycle_fund] 	  = 	{sync = i3k_sbean.sync_activities_cyclefund,		index = 0, 	sort = 65},
		[buy_get]			=	{sync = i3k_sbean.extra_gift_sync,					index = 0,	sort = 24},
		[useItems_reward] = 	{sync = i3k_sbean.sync_activities_useItems_reward,	index = 0, 	sort = 25},
		[giveMeRedPacket] = 	{sync = i3k_sbean.redpack_sync,						index = 0, 	sort = 26},
		[more_role_discount] =  {sync = i3k_sbean.syncMoreRoleDiscount, 			index = 0, 	sort = 5},
		[schedule_gift]   =  	{sync = i3k_sbean.schdulegift_sync, 				index = 0, 	sort = 27},
		[inheritDivinework] =	{sync = i3k_sbean.requireInheritDivinework, 		index = 0, 	sort = 150},	
		[backRoleDoubleDrop] =  {sync = i3k_sbean.syncBackRoleDoubleDrop, 			index = 0, 	sort = 200},
		[oppoActivity]		= 	{sync = i3k_sbean.oppo_vip_reward_sync, 			index = 0, 	sort = 300},
	}

end
function wnd_fu_li:configure()

	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_fu_li:onCloseUI()
	-- g_i3k_game_context:SetIsOpenFirstPayUI(false)
	g_i3k_ui_mgr:CloseUI(eUIID_Fuli)
	if g_i3k_game_context.isNeedShowCallback then
		g_i3k_logic:OpenCallBack()
	end
end

function wnd_fu_li:refresh(info,checkinGift,dailyOnlineGift,monthlyCardReward,dailyVitReward, actName, bindPhoneReward)
	local firstNode = self:updateActivitiesList(info,checkinGift,dailyOnlineGift,monthlyCardReward,dailyVitReward, actName, bindPhoneReward)
end

function wnd_fu_li:onHide()
	if self.co1 then
		g_i3k_coroutine_mgr:StopCoroutine(self.co1)
		self.co1 = nil
	end
	if self.schedler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedler)
		self.schedler = nil
	end
	self._laohuji = nil
end

-- function wnd_fu_li:clearScorll()
-- 	self._layout.vars.ActivitiesList:removeAllChildren()
-- 	local width = self._layout.vars.ActivitiesList:getContainerSize().width
-- 	self._layout.vars.ActivitiesList:setContainerSize(width, 0)
-- end

function wnd_fu_li:updateActivitiesList(acts,checkinGift,dailyOnlineGift,monthGift,vitGift, actName, bindPhoneReward)
	self.fistfour = {
		[SingInState]		= {title = "签到",	  clickFun = self.onSingInbtn, 		 canget = checkinGift, 	      syncFuc = i3k_sbean.checkin_sync },
		[LineState]			= {title = "线上奖励",	clickFun = self.onLineBtn, 			canget = dailyOnlineGift, 	syncFuc = i3k_sbean.sync_activities_onlinegift },
		[VitState]			= {title = "每日体力",	clickFun = self.onVit, 				canget = vitGift, 			syncFuc = function() self:updateVitInfo()  end },
		-- [JiniandajiState]	= {title = "储值公测返还",	clickFun = self.openJiniandaji, 	canget = false, 			syncFuc = function() self:openJiniandaji()  end },
		-- [HuhushengfengState]= {title = "虎虎生风",	clickFun = self.openHuhushengfeng, 	canget = false, 			syncFuc = function() self:openHuhushengfeng()  end },
	}
	local activitiesList = self._layout.vars.ActivitiesList
	activitiesList:removeAllChildren()
	local isFirstPayUI = false --g_i3k_game_context:GetIsOpenFirstPayUI()
	local hadReq = false
	for i = 1 , #self.fistfour do
		local info = self.fistfour[i]
		local item = require("ui/widgets/czhdt")()
		activitiesList:addItem(item)
		item.vars.TitleName:setText(info.title)
		item.vars.bt:onClick(self, info.clickFun,item)
		item.vars.bt:setTag(i)
		item.vars.red_point:setVisible(info.canget == 1)
		if i == VitState then
			local need_lvl = self:getCurrentVitInfo()
			if need_lvl > g_i3k_game_context:GetLevel() then
				item.vars.red_point:hide()
			end
		end
		self._firstFourRedPoints[i] = item.vars.red_point
		if (actName == nil or actName == "") and (info.canget == 1 and hadReq == false and not isFirstPayUI) then
			item.vars.select_icon:show()
			item.vars.bt:stateToPressed()
			self._current_bt = item.vars.bt
			self._current_select_icon = item.vars.select_icon
			info.syncFuc()
			hadReq = true
		end
	end
	table.sort( acts, function(a , b)
		return activitySyncTbl[a.type].sort < activitySyncTbl[b.type].sort
	end )
	local tmp_index = 0
	for k = 1 , #acts do
		local v = acts[k]
		local item = require("ui/widgets/czhdt")()
		local red_point = item.vars.red_point
		item.vars.TitleName:setText(v.title)
		item.vars.bt:onClick(self, self.updateSelectedListItem,{type = v.type, id = v.id , item = item })
		activitiesList:addItem(item)
		red_point:setVisible(v.notice == 1)
		item.vars.bt:stateToNormal()
		item.vars.select_icon:hide()
		item.vars.bt:setTag(#self.fistfour + k)
		self._activitiesList[k] = {
			id = v.id,
			atype = v.type,
			notice = v.notice,
			red_point = item.vars.red_point
		}
		if isFirstPayUI and v.type == first_pay_gift or (v.notice == 1 and hadReq == false) then
			if actName == nil or actName == "" or actName == v.title then  --如果找不到对应活动则默认显示签到
				item.vars.select_icon:show()
				item.vars.bt:stateToPressed()
				self:syncActivity(v.type, v.id)
				tmp_index = k
				self._current_bt = item.vars.bt
				self._current_select_icon = item.vars.select_icon
				hadReq = true
			end
		end
	end
	if hadReq == false then
		local item = activitiesList:getAllChildren()[1]
		self._current_bt = item.vars.bt
		self._current_select_icon = item.vars.select_icon
		item.vars.select_icon:show()
		item.vars.bt:stateToPressed()
		self.fistfour[1].syncFuc()
	end
	if tmp_index > 0 then
		activitiesList:jumpToChildWithIndex(tmp_index + #self.fistfour)
	end
	if bindPhoneReward == 1 then
		local item = require("ui/widgets/czhdt")()
		item.vars.TitleName:setText("手机绑定")
		item.vars.bt:onClick(self, function()
			self:updateButtonState(item)
			i3k_sbean.phone_reward_sync()
		end)
		item.vars.red_point:setVisible(false)
		activitiesList:addItem(item)
	end
	
	self:updataLegendmakeNotice()
	self:updataBackRoleDoubleDropNotice()
	self:updateLeftRedPoint(acts)
	self:setOneArmBanditUIRedPoint()
	self:setDayFirstLoginRedPoint()
end

-- 每天首次登陆的时候，需要显示红点
function wnd_fu_li:setDayFirstLoginRedPoint()
	local firstPay = g_i3k_game_context:getDayFirstLoginFuliRedPoint(DAY_FIRST_LOGIN_FIRST_PAY)
	local purchase = g_i3k_game_context:getDayFirstLoginFuliRedPoint(DAY_FIRST_LOGIN_PURCHASE)
	if firstPay then
		self:showFuliRedPointByAtype(first_pay_gift, true)
	end
	if purchase then
		self:showFuliRedPointByAtype(direct_purchase, true)
	end
end
function wnd_fu_li:showFuliRedPointByAtype(atype, visible)
	for k, v in pairs(self._activitiesList) do
		if v.atype == atype then
			if visible then
				v.red_point:show()
			else
				v.red_point:hide()
			end
		end
	end
end
function wnd_fu_li:hideFuliPurchaseRedPoint()
	for k, v in pairs(self._activitiesList) do
		if v.atype == direct_purchase then
			v.red_point:hide()
		end
	end
end


function wnd_fu_li:updateButtonState(item)
	if self._current_bt then
		self._current_bt:stateToNormal()
		self._current_select_icon:hide()
	end
	item.vars.select_icon:show()
	item.vars.bt:stateToPressed()
	self._current_bt = item.vars.bt
	self._current_select_icon = item.vars.select_icon
end

function wnd_fu_li:updateSelectedListItem(sender,info)
	self.percent = self._layout.vars.ActivitiesList:getListPercent()
	g_i3k_game_context:SetDynamicActivityRedPointInfo(0)
	self:updateButtonState(info.item)
	self:syncActivity(info.type, info.id)

end
function wnd_fu_li:syncActivity(actType, actId, ...)
	local activityFunctions = activitySyncTbl[actType]
	if activityFunctions then
		activityFunctions.sync(actId,actType, ... )
	end
end
function wnd_fu_li:changeContentSize(control)
	local size = self._layout.vars.RightView:getContentSize()
	control.rootVar:setContentSize(size.width, size.height)
end
function wnd_fu_li:updateRightView(control)
	if self.co1 then
		g_i3k_coroutine_mgr:StopCoroutine(self.co1)
		self.co1 = nil
	end
	if self.schedler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedler)
		self.schedler = nil
	end
	self._laohuji = nil
	local AddChild = self._layout.vars.RightView:getAddChild()
	for i,v in ipairs (AddChild) do
		self._layout.vars.RightView:removeChild(v)
	end
	self._layout.vars.RightView:addChild(control)
end


--------签到begin -------------
function wnd_fu_li:updateSingInInfo(finishedDays,checkinId,monthCfg,canCheckIn, additional)
	local qianDaoUI = require("ui/widgets/qiandao")()
	self:updateRightView(qianDaoUI)
	self:changeContentSize(qianDaoUI)
	local scroll = qianDaoUI.vars.scroll
	local month = qianDaoUI.vars.month
	local extraSign = i3k_engine_check_channel_name(finishedDays);

	if extraSign then
		qianDaoUI.vars.extraAward:show()
		qianDaoUI.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(extraSign.itemId))
		qianDaoUI.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(extraSign.itemId,i3k_game_context:IsFemaleRole()))
		qianDaoUI.vars.item_desc:setText("x"..extraSign.itemCount)
	end
	self:refMonthNum(month,monthCfg)
	self:scrollinit(canCheckIn,checkinId,finishedDays,monthCfg,scroll, qianDaoUI, additional)
	if next(monthCfg.extraBonus1) then
	self:initbonus(qianDaoUI, checkinId, monthCfg, finishedDays, additional)
	else
		qianDaoUI.vars.bonus2:setVisible(false)
		qianDaoUI.vars.bonus1:setVisible(false)
		qianDaoUI.vars.sign_bg:setVisible(false)
	end
end

function wnd_fu_li:initbonus(qianDaoUI, checkinId, monthCfg, finishedDays, additional)--初始化额外奖励
	qianDaoUI.vars.month_lock:setVisible(monthCfg.extraBonus1.bonusItem > 0)
	qianDaoUI.vars.xiaoyao_lock:setVisible(monthCfg.extraBonus2.bonusItem > 0)
	qianDaoUI.vars.month_count:setText(string.format("x%s", monthCfg.extraBonus1.itemCount))
	qianDaoUI.vars.xiaoyao_count:setText(string.format("x%s", monthCfg.extraBonus2.itemCount))
	qianDaoUI.vars.month_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(monthCfg.extraBonus1.bonusItem,i3k_game_context:IsFemaleRole()))
	qianDaoUI.vars.xiaoyao_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(monthCfg.extraBonus2.bonusItem,i3k_game_context:IsFemaleRole()))
	qianDaoUI.vars.month_frame:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(monthCfg.extraBonus1.bonusItem))
	qianDaoUI.vars.xiaoyao_frame:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(monthCfg.extraBonus2.bonusItem))
	qianDaoUI.vars.month_txt:setText(string.format("本月签到%s次可领取", monthCfg.extraBonus1.signDays))
	qianDaoUI.vars.xiaoyao_txt:setText(string.format("本月签到%s次可领取", monthCfg.extraBonus2.signDays))
	self:initBonusState(qianDaoUI, checkinId, monthCfg, finishedDays, additional)
end

function wnd_fu_li:initBonusState(qianDaoUI, checkinId, monthCfg, finishedDays, additional)
	if finishedDays >= monthCfg.extraBonus2.signDays then	--超过奖励2的天数
		if not next(additional) then
			self.isMonthShow = true
			self.isXiaoyaoShow = true
		else
			if not additional[monthCfg.extraBonus1.signDays] then
				self.isMonthShow = true
			else
				if additional[monthCfg.extraBonus1.signDays] == 1 then
					if g_i3k_game_context:getRoleSpecialCards(MONTH_CARD).cardEndTime > i3k_game_get_time() then --月卡用户
						self.isMonthShow = true
						self.isMonthToGet = true
					else
						qianDaoUI.vars.month_got:show()
						qianDaoUI.vars.month_btn:disable()
					end
				else
					qianDaoUI.vars.month_got:show()
					qianDaoUI.vars.month_btn:disable()
				end
			end
			if not additional[monthCfg.extraBonus2.signDays] then
				self.isXiaoyaoShow = true
			else
				if additional[monthCfg.extraBonus2.signDays] == 1 then
					if g_i3k_game_context:getRoleSpecialCards(SUPER_MONTH_CARD).cardEndTime > i3k_game_get_time() then --逍遥卡用户
						self.isXiaoyaoShow = true
						self.isXiaoyaoToGet = true
					else
						qianDaoUI.vars.xiaoyao_got:show()
						qianDaoUI.vars.xiaoyao_btn:disable()
					end
				else
					qianDaoUI.vars.xiaoyao_got:show()
					qianDaoUI.vars.xiaoyao_btn:disable()
				end
			end
		end
	elseif finishedDays < monthCfg.extraBonus2.signDays and finishedDays >= monthCfg.extraBonus1.signDays then
		if not next(additional) then
			self.isMonthShow = true
		else
			if not additional[monthCfg.extraBonus1.signDays] then
				self.isMonthShow = true
			else
				if additional[monthCfg.extraBonus1.signDays] == 1 then
					if g_i3k_game_context:getRoleSpecialCards(MONTH_CARD).cardEndTime > i3k_game_get_time() then --月卡用户
						self.isMonthShow = true
						self.isMonthToGet = true
					else
						qianDaoUI.vars.month_got:show()
						qianDaoUI.vars.month_btn:disable()
					end
				else
					qianDaoUI.vars.month_got:show()
					qianDaoUI.vars.month_btn:disable()
				end
			end
		end
	end
	if self.isMonthShow then
		qianDaoUI.vars.lizi:show()
		qianDaoUI.vars.lizi2:show()
		qianDaoUI.vars.lizi3:show()
		qianDaoUI.vars.lizi4:show()
	else
		qianDaoUI.vars.lizi:hide()
		qianDaoUI.vars.lizi2:hide()
		qianDaoUI.vars.lizi3:hide()
		qianDaoUI.vars.lizi4:hide()
	end
	if self.isXiaoyaoShow then
		qianDaoUI.vars.lizi5:show()
		qianDaoUI.vars.lizi6:show()
		qianDaoUI.vars.lizi7:show()
		qianDaoUI.vars.lizi8:show()
	else
		qianDaoUI.vars.lizi5:hide()
		qianDaoUI.vars.lizi6:hide()
		qianDaoUI.vars.lizi7:hide()
		qianDaoUI.vars.lizi8:hide()
	end
	qianDaoUI.vars.month_btn:onClick(self,self.onMonthBonus, {isMonthToGet = self.isMonthToGet, signDays = monthCfg.extraBonus1.signDays, qianDaoUI = qianDaoUI, itemCount = monthCfg.extraBonus1.itemCount,itemID = monthCfg.extraBonus1.bonusItem, isMonthShow = self.isMonthShow, finishedDays = finishedDays})
	qianDaoUI.vars.xiaoyao_btn:onClick(self,self.onXiaoyaoBonus, {isXiaoyaoToGet = self.isXiaoyaoToGet, signDays = monthCfg.extraBonus2.signDays, qianDaoUI = qianDaoUI, itemCount = monthCfg.extraBonus2.itemCount, itemID = monthCfg.extraBonus2.bonusItem, isXiaoyaoShow = self.isXiaoyaoShow, finishedDays = finishedDays})
	self:updateQianDaoRedPoint()
end

function wnd_fu_li:onXiaoyaoBonus(sender, info)	--14天奖励
	local tmp = {}
	local count = info.itemCount
	if g_i3k_game_context:getRoleSpecialCards(SUPER_MONTH_CARD).cardEndTime > i3k_game_get_time() then --月卡用户
		count = count * VIPDOUBLE
	end
	tmp[info.itemID] = count
	if info.finishedDays < info.signDays then
		g_i3k_ui_mgr:ShowCommonItemInfo(info.itemID)
	else
		if g_i3k_game_context:IsBagEnough(tmp) then
			--协议
			local callfunc = function()
				g_i3k_ui_mgr:OpenUI(eUIID_SignInExtraAward)
				g_i3k_ui_mgr:RefreshUI(eUIID_SignInExtraAward, {itemId = info.itemID, itemCount = info.itemCount, signDays = info.signDays, isToGet = info.isXiaoyaoToGet})
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateXiaoyaoState")
				if info.isXiaoyaoToGet then
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "hideQianDaoRedPoint")
				end
			end
			local data = i3k_sbean.checkin_take_additional_req.new()
			data.finishDay = info.signDays
			data.__callback = callfunc
			i3k_game_send_str_cmd(data,"checkin_take_additional_res")
			info.qianDaoUI.vars.xiaoyao_got:show()
			info.qianDaoUI.vars.xiaoyao_btn:disable()
			info.qianDaoUI.vars.lizi5:hide()
			info.qianDaoUI.vars.lizi6:hide()
			info.qianDaoUI.vars.lizi7:hide()
			info.qianDaoUI.vars.lizi8:hide()
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(288))
		end
	end
end

function wnd_fu_li:onMonthBonus(sender, info)	--7天奖励
	local tmp = {}
	local count = info.itemCount
	if g_i3k_game_context:getRoleSpecialCards(MONTH_CARD).cardEndTime > i3k_game_get_time() then --月卡用户
		count = count * VIPDOUBLE
	end
	tmp[info.itemID] = count
	if info.finishedDays < info.signDays then
		g_i3k_ui_mgr:ShowCommonItemInfo(info.itemID)
	else
		if g_i3k_game_context:IsBagEnough(tmp) then
			--协议
			local callfunc = function()
				g_i3k_ui_mgr:OpenUI(eUIID_SignInExtraAward)
				g_i3k_ui_mgr:RefreshUI(eUIID_SignInExtraAward, {itemId = info.itemID, itemCount = info.itemCount, signDays = info.signDays, isToGet = info.isMonthToGet})
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "updateMonthState")
				if info.isMonthToGet then
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "hideQianDaoRedPoint")
				end
			end
			local data = i3k_sbean.checkin_take_additional_req.new()
			data.finishDay = info.signDays
			data.__callback = callfunc
			i3k_game_send_str_cmd(data,"checkin_take_additional_res")
			info.qianDaoUI.vars.month_got:show()
			info.qianDaoUI.vars.month_btn:disable()
			info.qianDaoUI.vars.lizi:hide()
			info.qianDaoUI.vars.lizi2:hide()
			info.qianDaoUI.vars.lizi3:hide()
			info.qianDaoUI.vars.lizi4:hide()
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(288))
		end
	end
end

function wnd_fu_li:refMonthNum(month,monthCfg)--刷新几月份签到
	local cfgMonth = tonumber(string.sub(monthCfg.startDay,6,7))
	month:setImage(g_i3k_db.i3k_db_get_icon_path(monthNumber[cfgMonth]))
end

function wnd_fu_li:getdays(checkinId)--获取当月天数
	local days = 0
	for i=1,31 do
		local day = string.format("day%s",i+1)
		if i3k_db_sign[checkinId][day] == nil or i3k_db_sign[checkinId][day].itemId == nil then
			days = i
			break
		end
	end
	return days
end

function wnd_fu_li:scrollinit(canCheckIn,checkinId,finishedDays,monthCfg,scroll, qianDaoUI, additional)--初始化scroll界面
	local ary ={canCheckIn,finishedDays,monthCfg}
	local days = self:getdays(checkinId)
	local all_layer = scroll:addChildWithCount(LAYER_QDT,RowitemCount,days)
	local count = 0
	for k,v in ipairs(all_layer) do
		count = count + 1
		self:getItemdata(k,monthCfg)
		local day = string.format("day%s", k)
		local id = monthCfg[day].itemId
		local _layer = v
		local items = _layer.vars
		local grade = g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self.itemId)
		items.item_bg:setImage(grade)
		items.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self.itemId,i3k_game_context:IsFemaleRole()))
		items.item_count:setText(string.format("x%s", self.itemCount))
		items.item_btn:setTag(count)
		local tmp = {ary = ary,scroll = scroll, qianDaoUI = qianDaoUI, additional = additional, checkinId = checkinId}
		items.item_btn:onClick(self,self.onSureSign,tmp)
		self:ItemInit(k,items,canCheckIn,finishedDays, id)
	end
end

function wnd_fu_li:ItemInit(k,items,canCheckIn,finishedDays, id)---初始化每一个Item
	local item_btn = items.item_btn
	items.suo:setVisible(id>0)
	items.lizi:hide()
	items.lizi2:hide()
	items.lizi3:hide()
	items.lizi4:hide()
	if self.needVipLvl ~= 0 then
		items.vip_double:setImage(g_i3k_db.i3k_db_get_icon_path(vipNumber[self.needVipLvl]))
	else
		items.vip_double:hide()
	end
	if k <= finishedDays then
		items.is_sign:show()
		item_btn:disable()
		items.vip_double:setColorState(UI_COLOR_STATE_DARK)
	end
	if canCheckIn == 1 then
		if k == finishedDays+1 then
			items.lizi:show()
			items.lizi2:show()
			items.lizi3:show()
			items.lizi4:show()
		end
	end
end

function wnd_fu_li:onSureSign(sender,data)--点击签到相应事件
	local canCheckIn = data.ary[1]
	local finishedDays = data.ary[2]
	local monthCfg = data.ary[3]
	local qianDaoUI = data.qianDaoUI
	local additional = data.additional
	local checkinId = data.checkinId
	local tag = sender:getTag()
	local all_layer = data.scroll:getAllChildren()
	local vars = all_layer[tag].vars
	local vipLvl = g_i3k_game_context:GetVipLevel()
	local dayAward = self:getItemdata(tag,monthCfg)
	local awardarry = monthCfg[dayAward]
	local tmp = {}
	local count = tmp[self.itemId]
	if vipLvl >= awardarry.needVipLvl then
		self.itemCount = self.itemCount * VIPDOUBLE
	end
	count = count and count+self.itemCount or self.itemCount
	tmp[self.itemId] = count
	if  canCheckIn  == 1 then-- 1: 可以签到
		if tag ~= finishedDays+1 then
			g_i3k_ui_mgr:ShowCommonItemInfo(self.itemId)
		else
			self:isEnough(finishedDays,vars,tmp,awardarry, qianDaoUI, additional, checkinId, monthCfg)
		end
	else
		if tag >= finishedDays then
			g_i3k_ui_mgr:ShowCommonItemInfo(self.itemId)
		end
	end
end
function wnd_fu_li:getItemdata(num,monthCfg)--每一个签到物品的信息
	local day = string.format("day%s",num)
	self.itemId = monthCfg[day].itemId
	self.itemCount = monthCfg[day].itemCount
	self.needVipLvl = monthCfg[day].needVipLvl
	return day
end

function wnd_fu_li:isEnough(finishedDays,vars,tmp,awardarry, qianDaoUI, additional, checkinId, monthCfg)--判断背包是否满，并做相应修改
	local item = tmp
	local extraSign = i3k_engine_check_channel_name(finishedDays);
	local solartermIndex = self:getSolarTermInfo()
	
	if solartermIndex ~= 0 then
		local id = i3k_db_sign_solar_term[solartermIndex].solartermPackID
		local count = i3k_db_sign_solar_term[solartermIndex].solartermPackCount
		item[id] = item[id] and item[id] + count or count	
	end
	if extraSign then
		local id = extraSign.itemId
		item[id] = item[id] and item[id] + extraSign.itemCount or extraSign.itemCount
		end
	
	local is_enough = g_i3k_game_context:IsBagEnough(item)
	if is_enough then
		self:getAward(finishedDays,vars, awardarry, qianDaoUI, additional, checkinId, monthCfg, extraSign)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(288))
	end
end

function wnd_fu_li:getSolarTermInfo()
	local nowtime  = i3k_game_get_time()
	local nowYear, nowMonth, nowDay = g_i3k_get_YearAndDayAndTime1(nowtime)
	local solarIndex = 0
	for k,v in ipairs(i3k_db_sign_solar_term) do
		if tonumber(string.sub(v.solartermDay,1,4)) == nowYear and tonumber(string.sub(v.solartermDay,6,7)) == nowMonth and tonumber(string.sub(v.solartermDay,9,10)) == nowDay then
--			isSolarTerm = true
			solarIndex = k
			break
		end
	end
	return solarIndex
end
function wnd_fu_li:getAward(finishedDays,vars,awardarry, qianDaoUI, additional, checkinId, monthCfg, item)
	local solartermIndex = self:getSolarTermInfo()
	local solarTermCallfunc = function()
		g_i3k_ui_mgr:OpenUI(eUIID_SignInSolarTerm)
		if item then
			g_i3k_ui_mgr:RefreshUI(eUIID_SignInSolarTerm, awardarry, i3k_db_sign_solar_term[solartermIndex], item)
		else
			g_i3k_ui_mgr:RefreshUI(eUIID_SignInSolarTerm, awardarry, i3k_db_sign_solar_term[solartermIndex])
		end
		if next(monthCfg.extraBonus1) then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "initBonusState", qianDaoUI, checkinId, monthCfg, finishedDays + 1, additional)
		end
	end
	local callfunc = function()
		g_i3k_ui_mgr:OpenUI(eUIID_SignInAward)
		if item then
			g_i3k_ui_mgr:RefreshUI(eUIID_SignInAward,awardarry, item)
		else
			g_i3k_ui_mgr:RefreshUI(eUIID_SignInAward,awardarry)
		end
		if next(monthCfg.extraBonus1) then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli, "initBonusState", qianDaoUI, checkinId, monthCfg, finishedDays + 1, additional)
		end
	end
	local data = i3k_sbean.checkin_take_req.new()
	data.times = finishedDays + 1
	data.__callback = callfunc
	data.__solarTermCallback = solarTermCallfunc
	i3k_game_send_str_cmd(data,"checkin_take_res")
	vars.is_sign:show()
	vars.item_btn:disable()
	vars.lizi:hide()
	vars.lizi2:hide()
	vars.lizi3:hide()
	vars.lizi4:hide()
	if vars.vip_double then
		vars.vip_double:setColorState(UI_COLOR_STATE_DARK)
	end
end

--加两个函数设置额外奖励的状态
function wnd_fu_li:updateMonthState()
	self.isMonthShow = false
	self:updateQianDaoRedPoint()
end

function wnd_fu_li:updateXiaoyaoState()
	self.isXiaoyaoShow = false
	self:updateQianDaoRedPoint()
end

function wnd_fu_li:onSingInbtn(sender,item)
	i3k_sbean.checkin_sync()
	self:updateButtonState(item)
end

function wnd_fu_li:hideQianDaoRedPoint()
	self.fistfour[SingInState].canget = 0
	self:updateQianDaoRedPoint()
end

function wnd_fu_li:updateQianDaoRedPoint()
	local state = self.fistfour[SingInState].canget == 1 or self.isMonthShow or self.isXiaoyaoShow
	self._firstFourRedPoints[SingInState]:setVisible(state)
	if not state then
		g_i3k_game_context:RemoveFuliRedPointCount(1)
	end
end
-------------------签到end------------


-------------------在线奖励begin--------------
function wnd_fu_li:updateOnLineInfo(info,index)
	local onLineUI = require("ui/widgets/leijizaixian")()
	self:updateRightView(onLineUI)
	self:changeContentSize(onLineUI)
	local ActivitiesTime = onLineUI.vars.ActivitiesTime
	self:updateOnLineTime(ActivitiesTime,info)
	self._canopen = true
	local ExchangeGiftList = onLineUI.vars.ExchangeGiftList
	self:updateOnLineList(onLineUI,info,index)
end

function wnd_fu_li:updateOnLineTime(ActivitiesTime,info)
	local content = string.format("%s分钟",info.dayOnlineTime)
	ActivitiesTime:setText(content)
end

function wnd_fu_li:updateOnLineList(onLineUI,info,index)
	local ExchangeGiftList = onLineUI.vars.ExchangeGiftList
	ExchangeGiftList:removeAllChildren()
	local dailyActivity = i3k_db_little_activity
	for i, v in ipairs(dailyActivity) do
		self:appendOnlineGiftLevelItem( onLineUI,v.rewards,  v.keepTime, info.dayOnlineTime, info.rewards[v.keepTime],i)
	end
	if Index then
		ExchangeGiftList:jumpToListPercent(Index)
	else
		if next(info.rewards) ~= nil  then
			ExchangeGiftList:jumpToChildWithIndex(self._index )--跳到最近未领奖的控件
		else
			ExchangeGiftList:jumpToListPercent(0)
		end
	end
	local count = 0
	local num = 0
	local index = 0
	local have_count = 0
	for i, v in ipairs(dailyActivity) do
		if info.dayOnlineTime >= v.keepTime then
			have_count = have_count + 1
		end
	end
	for i, v in ipairs(dailyActivity) do
		if next(info.rewards) ~= nil then
			for k,e in pairs(info.rewards) do
				local count1 = table.nums(info.rewards)
				if k == v.keepTime then
					count = count + 1
					break
				else
					if count == table.nums(info.rewards) then
						if have_count == count then
							self:updateOnLineRedPoint(false)
						end
						return false
					end
				end
				num = num + 1--不满足相等时
			end
			index = index + 1---break后跳到这里
		end
	end
	if count == table.nums(dailyActivity) then
		self:updateOnLineRedPoint(false)
	end
end

function wnd_fu_li:appendOnlineGiftLevelItem(onLineUI,gifts, keepTime, dayOnlineTime,reward,id)
	local PayGiftLevelWidgets = require("ui/widgets/leijizaixiant")()
	self:updateOnlineGiftLevelItem(PayGiftLevelWidgets,  gifts, keepTime, dayOnlineTime,reward ,id,onLineUI.vars.ExchangeGiftList )
	local ExchangeGiftList = onLineUI.vars.ExchangeGiftList
	ExchangeGiftList:addItem(PayGiftLevelWidgets)
end

function wnd_fu_li:updateOnlineGiftLevelItem(item, gifts,keepTime, dayOnlineTime,reward ,id,ExchangeGiftList)
	local onlineGiftTb =
	{
		[1] = {root = item.vars.item_bg, icon = item.vars.item_icon, count = item.vars.item_count,suo = item.vars.item_suo,bg = item.vars.count_bg},
		[2] = {root = item.vars.item_bg2, icon = item.vars.item_icon2, count = item.vars.item_count2 ,suo = item.vars.item_suo2,bg = item.vars.count_bg2},
		[3] = {root = item.vars.item_bg3, icon = item.vars.item_icon3, count = item.vars.item_count3 ,suo = item.vars.item_suo3,bg = item.vars.count_bg3}
	}
	for k,v in ipairs(gifts) do
		if v.itemCount > 0 and v.itemid then
			onlineGiftTb[k].root:show()
			onlineGiftTb[k].root:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.itemid) )
			onlineGiftTb[k].icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.itemid,i3k_game_context:IsFemaleRole()))
			if v.itemCount >= 1 then
				onlineGiftTb[k].count:setText("x"..v.itemCount)
			else
				onlineGiftTb[k].bg:hide()
				onlineGiftTb[k].count:hide()
			end
			onlineGiftTb[k].icon:onClick(self, self.onTips,v.itemid)
		else
			onlineGiftTb[k].root:hide()
		end
		if v.itemid == 3 or v.itemid == 4 or v.itemid == 31 or v.itemid == 32 or v.itemid == 33 or v.itemid < 0 then
			onlineGiftTb[k].suo:hide()
		else
			onlineGiftTb[k].suo:show()
		end
	end
	local content = string.format("%s分钟",keepTime)
	item.vars.GoalContent:setText(content)
	if  dayOnlineTime >= keepTime then
		if reward then
			item.vars.GetImage:show()
			item.vars.alreadyGet1:show()
			item.vars.alreadyGet2:show()
			item.vars.alreadyGet3:show()
			item.vars.GetBtn:hide()
		else
			self._canGet = false

			if self._canopen then

				self._index = id
				self._canopen = false
			end
			item.vars.Whole:show()
			local TakePayGift = {Time = keepTime ,gifts = gifts,control = ExchangeGiftList}
			item.vars.GetBtn:onClick(self, self.onTakePayGiftReward, TakePayGift)
			self:updateOnLineRedPoint(true)
		end
	else
		if self._canopen then
			self._index = id
			self._canopen = false
		end
		item.vars.GetBtnText:setText("未达标")
		item.vars.GetBtn:disableWithChildren()
	end

end

function wnd_fu_li:onTakePayGiftReward(sender,needValue)
	local giftsTb = needValue.gifts
	local percent = needValue.control:getListPercent()
	local isEnoughTable = { }
	local gift = {}
	local index = 0
	for i,v in pairs(giftsTb) do
		if v.itemid ~= 0 then
			isEnoughTable[v.itemid] = v.itemCount
		end
	end
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	for i,v in pairs (isEnoughTable) do
		index = index + 1
		gift[index] = {id = i,count = v}
	end
	if isEnough then
		i3k_sbean.activities_onlinegift_take(needValue.Time,percent,gift,index)
	else
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
	end
end

function wnd_fu_li:onLineBtn(sender,item)
	i3k_sbean.sync_activities_onlinegift()
	self:updateButtonState(item)
end
function wnd_fu_li:updateOnLineRedPoint(state)
	if not state then
		g_i3k_game_context:RemoveFuliRedPointCount(1)
	end
	self._firstFourRedPoints[LineState]:setVisible(state)
end
---在线奖励end -----------------



------------------------------每日体力begin-----------------------------
function wnd_fu_li:updateVitInfo(is_award)
	if is_award then
		self.fistfour[VitState].canget = is_award
	end
	local vitUI = require("ui/widgets/tililingqu")()
	self:updateRightView(vitUI)
	self:changeContentSize(vitUI)
	self:updateVitIems(vitUI)
end

function wnd_fu_li:onVit(sender,item)
	self:updateVitInfo()
	self:updateButtonState(item)
end

function wnd_fu_li:updateVitRedPoint(state)
	self._firstFourRedPoints[VitState]:setVisible(state)
end

function wnd_fu_li:onGetEveryDayVit(sender,args)
	if g_i3k_game_context:GetLevel() < args.need_lvl then
		return g_i3k_ui_mgr:PopupTipMessage(string.format("不足%s级，不可领取",args.need_lvl))
	end
	i3k_sbean.take_daily_vit(args.vitId)
end

function wnd_fu_li:updateVitIems(vitLayer)
	local need_lvl, vitId, isInVitTime, tmp_items = self:getCurrentVitInfo()
	vitLayer.vars.titleBg:setImage(g_i3k_db.i3k_db_get_icon_path(vit_title_bg_icon[1]))
	if not isInVitTime then
		vitLayer.vars.vitBg:setImage(g_i3k_db.i3k_db_get_icon_path(vit_bg_icon[3]))
		self.fistfour[VitState].canget = 0
		vitLayer.vars.GetBtn:disableWithChildren()
	else
		if self.fistfour[VitState].canget == 1 then
			vitLayer.vars.GetBtn:enableWithChildren()
			vitLayer.vars.vitBg:setImage(g_i3k_db.i3k_db_get_icon_path(vit_bg_icon[2]))
			vitLayer.vars.titleBg:setImage(g_i3k_db.i3k_db_get_icon_path(vit_title_bg_icon[2]))
		else
			vitLayer.vars.vitBg:setImage(g_i3k_db.i3k_db_get_icon_path(vit_bg_icon[1]))
			vitLayer.vars.GetBtn:disableWithChildren()
		end
	end
	vitLayer.vars.GetBtn:onClick(self,self.onGetEveryDayVit,{vitId = vitId,need_lvl = need_lvl})
	local current_vit = 0
	for i,j in ipairs(tmp_items) do
		if j[1] == g_BASE_ITEM_VIT then
			current_vit  = j[2]
			break
		end
	end
	vitLayer.vars.current_title:setText(i3k_get_string(783,current_vit))
	for i=1,3 do
		local item_cfg = tmp_items[i]
		local tmp_bg = string.format("itemBg%s",i)
		local itemBg = vitLayer.vars[tmp_bg]
		if item_cfg and item_cfg[1] and item_cfg[1] ~= 0 and item_cfg[2] and item_cfg[2] ~= 0 then
			local tmp_btn = string.format("itemBtn%s",i)
			local itemBtn = vitLayer.vars[tmp_btn]
			local tmp_icon = string.format("itemIcon%s",i)
			local itemIcon = vitLayer.vars[tmp_icon]
			local tmp_count = string.format("itemCount%s",i)
			local itemCount = vitLayer.vars[tmp_count]
			itemBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item_cfg[1]))
			itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(item_cfg[1],i3k_game_context:IsFemaleRole()))
			itemCount:setText(string.format("×%s",item_cfg[2]))
			itemBtn:onClick(self,self.onTips,item_cfg[1])
		else
			itemBg:hide()
		end
	end
	if need_lvl > g_i3k_game_context:GetLevel() then
		self:updateVitRedPoint(false)
	else
	self:updateVitRedPoint(self.fistfour[VitState].canget == 1)
	end
end
function wnd_fu_li:getCurrentVitInfo()
	local nowtime  = i3k_game_get_time()
	local tmp_cfg = {}
	for k,v in pairs(i3k_db_month_card_award) do
		table.insert(tmp_cfg,v)
	end
	table.sort(tmp_cfg,function (a,b)
		return a.sortId < b.sortId
	end)
	local tmp_items = tmp_cfg[1].awardItems
	local vitId = 0
	local need_lvl = 0
	local isInVitTime = false
	for k,v in ipairs(tmp_cfg) do
		local endTime = g_i3k_get_day_time(v.endTime)
		if nowtime < endTime then
			tmp_items = v.awardItems
			break
		end
	end
	for k,v in ipairs(tmp_cfg) do
		if nowtime < g_i3k_get_day_time(v.endTime) then
			need_lvl = v.needLvl
			local startTime = g_i3k_get_day_time(v.startTime)
			if nowtime >= g_i3k_get_day_time(v.startTime) then
				vitId = v.id
				isInVitTime = true
				break
			end
		end
	end
	return need_lvl, vitId, isInVitTime, tmp_items
end
------------------------------每日体力end-----------------------------
----首冲
function wnd_fu_li:updateFirstPayGiftInfo(actType,actId,effectiveTime, cfg, log)
	g_i3k_game_context:setDayFirstLoginFuliRedPoint(DAY_FIRST_LOGIN_FIRST_PAY, false)
	local needValue = {actType = actType , actId = actId }
	local firstPayGiftUI = require("ui/widgets/shouchongsongli")()
	self:updateRightView(firstPayGiftUI)
	self:changeContentSize(firstPayGiftUI)
	self:updateFirstPayGiftMainInfo(firstPayGiftUI, cfg.time, log.pay)
	self:updatefirstpaygiftLevelItem(firstPayGiftUI,effectiveTime, log.id, cfg.gifts, log.reward ,cfg.biggift, log.pay,actType)
	self:setLeftRedPoint(actType, actId)
end

function wnd_fu_li:updateFirstPayGiftMainInfo(control, time, pay)
	local content = string.format("%d",pay)
end

function wnd_fu_li:updatefirstpaygiftLevelItem(item,effectiveTime, id, gifts, reward ,biggift,pay,actType)
	local firstPayGiftTb = {
		[1] = {root = item.vars.item_bg, icon = item.vars.item_icon ,btn = item.vars.Btn1, count = item.vars.item_count,suo = item.vars.Item_suo,bg = item.vars.count_bg},
		[2] = {root = item.vars.item_bg2, icon = item.vars.item_icon2 ,btn = item.vars.Btn2, count = item.vars.item_count2,suo = item.vars.Item_suo2,bg = item.vars.count_bg2},
		[3] = {root = item.vars.item_bg3, icon = item.vars.item_icon3 ,btn = item.vars.Btn3, count = item.vars.item_count3,suo = item.vars.Item_suo3,bg = item.vars.count_bg3},
		[4] = {root = item.vars.item_bg4, icon = item.vars.item_icon4 ,btn = item.vars.Btn4, count = item.vars.item_count4,suo = item.vars.Item_suo4,bg = item.vars.count_bg4},
		[5] = {root = item.vars.item_bg5, icon = item.vars.item_icon5 ,btn = item.vars.Btn5, count = item.vars.item_count5,suo = item.vars.Item_suo5,bg = item.vars.count_bg5},
		[6] = {root = item.vars.item_bg6, icon = item.vars.item_icon6,btn = item.vars.Btn6 , count = item.vars.item_count6,suo = item.vars.Item_suo6,bg = item.vars.count_bg6}
	}
	local _gift = {}
	for i,v in ipairs(gifts) do
		local curid = v.ids[g_i3k_game_context:GetRoleType()]
		firstPayGiftTb[i].root:show()
		firstPayGiftTb[i].root:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(curid) )
		firstPayGiftTb[i].icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(curid,i3k_game_context:IsFemaleRole()))
		if v.count > 0 then
			firstPayGiftTb[i].count:setText("x"..v.count)
		else
			firstPayGiftTb[i].bg:hide()
			firstPayGiftTb[i].count:hide()
		end
		firstPayGiftTb[i].btn:onClick(self, self.onTips,curid)
		if curid == 3 or curid == 4 or curid == 31 or curid == 32 or curid == 33 or curid < 0 then
			firstPayGiftTb[i].suo:hide()
		else
			firstPayGiftTb[i].suo:show()
		end
		table.insert(_gift,{id = curid,count = v.count})
	end
	item.vars.ExItem_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(biggift.id))
	item.vars.ExItem_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(biggift.id,i3k_game_context:IsFemaleRole()))
	item.vars.ExItem_name:setText(g_i3k_db.i3k_db_get_common_item_name(biggift.id))
	item.vars.ExItem_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(biggift.id)))
	if biggift.count >= 1 then
		item.vars.Exitem_count:setText("x"..biggift.count)
	else
		item.vars.Excount_bg:hide()
		item.vars.Exitem_count:hide()
	end
	if biggift.id == 3 or biggift.id == 4 or biggift.id == 31 or biggift.id== 32 or biggift.id == 33 or biggift.id < 0 then
		item.vars.ExItem_suo:hide()
	else
		item.vars.ExItem_suo:show()
	end
	item.vars.ExBtn:onClick(self, self.onTips,biggift.id)
	if pay > 0 then
		item.vars.topup:hide()
		if reward > 0 then
			item.vars.GetBtn:disableWithChildren()
			item.vars.GetBtnText:setText("已领取")
		else
			g_i3k_game_context:SetDynamicActivityRedPointInfo(1)
			local takeFirstPayGift = {Time = effectiveTime, index = id,gifts = _gift, actType = actType,giftEx = biggift,item=item}--key,value
			item.vars.GetBtn:onClick(self, self.onTakeGradeGiftReward,takeFirstPayGift)--领取
		end
	else
		item.vars.GetBtn:hide()
		item.vars.topup:onClick(self, self.onFirstPay)--充值--需要关闭当前
	end
end

function wnd_fu_li:onFirstPay(sender)
	local function callback()
		g_i3k_logic:OpenBattleUI()
		g_i3k_game_context:SetIsOpenFirstPayUI(true)
		g_i3k_logic:OpenPayActivityUI()
	end
	g_i3k_logic:OpenChannelPayUI(callback)
	-- g_i3k_ui_mgr:CloseUI(eUIID_Fuli)
end

function wnd_fu_li:onTakeGradeGiftReward(sender,needValue)
	self._percent = needValue.actType
	self._actID = needValue.index
	local giftsTb = needValue.gifts
	local giftsExTb = needValue.giftEx
	local isEnoughTable = { }
	local gift = {}
	local index = 0
	for i,v in pairs(giftsTb) do
		isEnoughTable[v.id] = v.count
	end
	isEnoughTable[giftsExTb.id] = giftsExTb.count
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	for i,v in pairs (isEnoughTable) do
		index = index + 1
		gift[index] = {id = i,count = v}

	end
	if isEnough then
		if needValue.actType == 1 then
			i3k_sbean.activities_firstpaygift_take(needValue.Time,needValue.index,gift,index,needValue.actType)
		elseif needValue.actType == 4 then
			local percent = needValue.control.vars.GradeGiftList:getListPercent()
			activitySyncTbl[needValue.actType].index = needValue.control.vars.GradeGiftList:getListPercent()
			i3k_sbean.activities_gradegift_take(needValue.Time,needValue.index,needValue.level,needValue.actType,gift,percent,index)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
	end
end

------------直购礼包活动begin--------------------
function wnd_fu_li:updateDirectPurchase(type, id, info)
	local purchase = g_i3k_game_context:getDayFirstLoginFuliRedPoint(DAY_FIRST_LOGIN_PURCHASE)
	if purchase then
		self:hideFuliPurchaseRedPoint()
	end
	g_i3k_game_context:setDayFirstLoginFuliRedPoint(DAY_FIRST_LOGIN_PURCHASE, false)
	local ui = require("ui/widgets/chaozhilibao")()
	self:updateRightView(ui)
	self:changeContentSize(ui)
	self:updateDirectPurchaseInfo(ui, id, type, info)
	self:updateDirectPurchaseTime(ui, info.cfg.time)
end

function wnd_fu_li:updateDirectPurchaseTime(ui, time)
	self:excessTime(ui, time)
	-- ui.vars.ActivitiesTime:setText(time)
end

function wnd_fu_li:updateDirectPurchaseInfo(ui, id, type, info)

	for i, v in ipairs(info.cfg.levelPurchases) do
		local widgets = require("ui/widgets/chaozhilibaot")()
		ui.vars.giftList:addItem(widgets)
		local rewards = {}
		local gifts = {}
		for k = 1, 3 do
			if v.gifts[k] then
				local q = v.gifts[k]
				widgets.vars["item_bg"..k]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(q.id) )
				widgets.vars["item_icon"..k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(q.id))
				widgets.vars["item_count"..k]:setText("x"..q.count)
				widgets.vars["item_suo"..k]:setVisible(q.id > 0)
				widgets.vars["bt"..k]:onClick(self, self.onTips, q.id)
				rewards[q.id] = q.count
				gifts[k] = {id = q.id, count = q.count}
			else
				widgets.vars["item_bg"..k]:hide()
			end
		end
		local price = info.info.payLevels[v.payLevel].priceShow
		widgets.vars.desc:setText("花费"..price.."USD可购买")
		if info.log.rewardTimes[v.payLevel] and info.log.rewardTimes[v.payLevel] > 0 then -- 领过奖了
			widgets.vars.buyBtnLabel:setText("领奖")
			widgets.vars.buyBtn:disableWithChildren()
		elseif info.info.leftRewardTimes[v.payLevel] > 0  then -- 领奖
			local callback = function ()
				widgets.vars.buyBtn:disableWithChildren()
			end
			local data = {id = id, effectiveTime = info.effectiveTime, payLevel = v.payLevel, rewards = rewards, gifts = gifts, callback = callback}
			widgets.vars.buyBtn:onClick(self, self.onTakeDirectPurchase, data)
			widgets.vars.buyBtnLabel:setText("领奖")
		else
			local callback = function()
				i3k_sbean.sync_direct_purchase(id, type)
			end
			local levelReq = v.levelReq
			local vipReq = v.vipReq
			local cardReq = v.cardReq
			local data = {info = info.info.payLevels[v.payLevel], id = info.info.id, callback = callback, levelReq = levelReq, vipReq = vipReq, cardReq = cardReq}
			widgets.vars.buyBtn:onClick(self, self.onBuyDirectPurchase, data)
		end
	end
end

function wnd_fu_li:onBuyDirectPurchase(sender, data)
	if g_i3k_game_context:GetLevel() < data.levelReq then
		g_i3k_ui_mgr:PopupTipMessage("等级不足，达到"..data.levelReq.."级可以购买")
		return
	end
	if g_i3k_game_context:GetVipLevel() < data.vipReq then
		g_i3k_ui_mgr:PopupTipMessage(string.format(i3k_get_string(15376, data.vipReq)))
		return
	end
	local state = g_i3k_game_context:checkSpecialCardCondition(data.cardReq)
	if not state then
		local StringID = 15376
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(StringID + data.cardReq))
	else
		self._directPurchaseCallback = data.callback
		i3k_sbean.goto_channel_pay(data.id, data.info, data.callback)
	end
end

-- InvokeUIFunction 直购礼包购买成功了，刷新一下
function wnd_fu_li:handleDirectPuschaseCallback()
	if self._directPurchaseCallback then
		self._directPurchaseCallback()
	end
	self._directPurchaseCallback = nil
end

function wnd_fu_li:onTakeDirectPurchase(sender, data)
	local isEnough = g_i3k_game_context:IsBagEnough(data.rewards)
	if isEnough then
		i3k_sbean.take_direct_purchase(data.id, data.effectiveTime, data.payLevel, data.gifts, data.callback)
	else
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
	end
end
------------直购礼包活动end--------------------

-- 广告
-- function wnd_fu_li:onAdvertisement(sender)
-- 	i3k_sbean.syncAdvertisement(id, actType)
-- end

function wnd_fu_li:updateAdvertisement(iconID, content)
	if not i3k_db_activity_imgs[iconID] then
		return
	end
	local ui = require("ui/widgets/flsz")()
	self:updateRightView(ui)
	self:changeContentSize(ui)
	local imgID = i3k_db_activity_imgs[iconID]
	ui.vars.img:setImage(g_i3k_db.i3k_db_get_icon_path(imgID))
	if content == "" then
		ui.vars.buyBtn:hide()
	else
		ui.vars.buyBtn:show()
	ui.vars.buyBtn:onClick(self, self.onJingDongShopBtn, content)
	end
end

function wnd_fu_li:onJingDongShopBtn(sender, content)
	local url = content
	i3k_open_url(url)
end



--------手机号绑定--begain-------------------
function wnd_fu_li:updateMobileGift(actType, actId,info)
	local MRCZSL = require("ui/widgets/shoujiyanzheng")()
	self.lianxuchongzhiInfo	 = {item = MRCZSL, info = info, actType = actType,actId = actId }
	self:updateRightView(MRCZSL)
	self:changeContentSize(MRCZSL)
	self:updateLastChargeInfo(MRCZSL,info,actType, actId,#info.log.reward+1)
	--self:setLeftRedPoint(actType, actId)
	--self:excessTime(MRCZSL,info.cfg.time)
end

function wnd_fu_li:updateMobileGiftInfo(item,info,actType,actId,index)
	for i = 1 , 6 do
		local gifts = info.cfg.gifts[i].gifts
		item.vars["reward_btn"..(i + 5)]:onClick(self, self.onShowLastChargeGift,i)--领取
		item.vars["reward_btn"..(i + 5)]:setTouchEnabled(true)
		if payDay[i] and dayPayNum[i] >= need_pay then --达到条件
			if info.log.reward[i] then -- 已领取
				item.vars["reward_get_icon"..(i + 5)]:show()
				item.vars["reward_icon"..(i + 5)]:hide()
				if i == curday then
					canget = 1
				end
			else -- 未领取
				item.vars.ChargeBtn:show()
				g_i3k_game_context:SetDynamicActivityRedPointInfo(1)
				if i == 1 then
					item.anis.c_bx.play()
				else
					item.anis[string.format("c_bx%s",i)].play()
				end
				item.vars["reward_get_icon"..(i + 5)]:hide()
				item.vars["reward_icon"..(i + 5)]:show()
				if i == curday then
					canget = 2
				end
			end
		else
			item.vars["reward_get_icon"..(i + 5)]:hide()
			item.vars["reward_icon"..(i + 5)]:show()
		end
		if i == curday then
	 		item.vars["select"..i]:show()
	 	else
	 		item.vars["select"..i]:hide()
	 	end
	end

	local gifts = info.cfg.gifts[curday].gifts

	if canget == 0 then
		item.vars.ChargeBtn:show()
		item.vars.ChargeBtn:onClick(self, self.onStore)--充值--需要关闭当前
		item.vars.GetBtnText2:setText("充值")
	elseif canget == 1 then
		item.vars.ChargeBtn:hide()
		item.vars.GetImage2:show()
	elseif canget == 2 then
		local takeFirstPayGift = {time = info.effectiveTime, id = actId,actType = actType, gifts = gifts, index = curday }
		item.vars.ChargeBtn:onClick(self, self.onTakeLastChargeGift,takeFirstPayGift)--领取
		item.vars.GetBtnText2:setText("领取")
	end
	item.vars.listview:removeAllChildren()
	for i = 1 , #gifts do
		if gifts[i] and  gifts[i].count >= 1 then
			local temp = require("ui/widgets/lianxuchongzhit")()
			temp.vars.item_bg4:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(gifts[i].id) )
			temp.vars.item_icon4:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(gifts[i].id,i3k_game_context:IsFemaleRole()))
			temp.vars.item_count4:setText("x"..gifts[i].count)
			temp.vars.Btn4:onClick(self, self.onTips,gifts[i].id)
			item.vars.listview:addItem(temp)
		end
	end

	item.vars.schedule2:setPercent(#payDay/#info.cfg.gifts*100)
	item.vars.fas:setText(string.format("已累积储值%d%s",#payDay,"天"))
	if need_pay > 0 then
		item.vars.GoalContent2:setText(string.format("每天储值%d%s",need_pay,"元宝即可领取奖励"))
	end
end

function wnd_fu_li:onShowLastChargeGift(sender , index )
	self:updateLastChargeInfo(self.lianxuchongzhiInfo.item,self.lianxuchongzhiInfo.info,self.lianxuchongzhiInfo.actType, self.lianxuchongzhiInfo.actId,index)
end

function wnd_fu_li:onTakeLastChargeGift(sender,needValue)
	local giftsTb = needValue.gifts
	local isEnoughTable = { }
	for i,v in pairs(giftsTb) do
		isEnoughTable[v.id] = v.count
	end
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	if isEnough then
		local gift = {}
		for i,v in pairs (isEnoughTable) do
			table.insert(gift,{id = i,count = v})
		end
		i3k_sbean.lastpaygift_take(needValue.time,needValue.index,gift,needValue.actType,needValue.id)
	else
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
	end
end
--------手机号绑定 -----end----------------------

--------征战天下活动--begain-------------------
function wnd_fu_li:updateActivitychallenge(actType, actId,info,index)
	local MRCZSL = require("ui/widgets/zhengzhantianxia")()
	g_i3k_game_context:SetDynamicActivityRedPointInfo(0)
	self:updateRightView(MRCZSL)
	self:changeContentSize(MRCZSL)
	self:updateActivitychallengeInfo(MRCZSL,info,actType, actId,index or 1)
	self:excessTime(MRCZSL,info.cfg.time)
	self.ActivitychallengeInfo	 = {item = MRCZSL, info = info, actType = actType,actId = actId ,index = index}
end

function wnd_fu_li:updateActivitychallengeInfo(item,info1,actType,actId,index)
	local current_time = i3k_game_get_time()
	local tmp_str = string.format(info1.cfg.content)
	item.vars.ActivitiesContent:setText(tmp_str)
	local gifts = info1.cfg.gifts
	item.vars.GradeGiftList:removeAllChildren()
	for i = 1 , 5 do
		local info = gifts[i]
		if info and i3k_db_activitychallenge[info.id] then
			item.vars["redpoint"..i]:hide()
			item.vars["button"..i]:show()
			item.vars["button"..i]:onClick(self, self.selectButton,i)
			item.vars["text"..i]:setText(i3k_db_activitychallenge[info.id].title)
			if i == index then
				local _gifts = info.gifts
				for j = 1 , #_gifts do
					local temp = require("ui/widgets/zztxt")()
					for k = 1 , 4 do
						local ___info = _gifts[j].gifts[k]
						if ___info then
							temp.vars["item_bg"..k]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(___info.id) )
							temp.vars["item_icon"..k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(___info.id, g_i3k_game_context:IsFemaleRole()))
							temp.vars["item_count"..k]:setText("x"..___info.count)
							temp.vars["tipbtn"..k]:onClick(self, self.onTips,___info.id)
						else
							temp.vars["item_bg"..k]:hide()
						end
					end
					temp.vars.GoalContent:setText(string.format("完成%s%d%s",i3k_db_activitychallenge[info.id].title,_gifts[j].times,"次"))
					temp.vars.Count:setText(self:getAllTimes(info.id,info1).."/".._gifts[j].times)
					if self:getAllTimes(info.id,info1) >= _gifts[j].times then
						temp.vars.Count:setTextColor(g_i3k_get_green_color())
						if self:rewardHadGet(info.id ,_gifts[j].times, info1) then
							temp.vars.yilingqu:show()
							temp.vars.GetBtn:hide()
							temp.vars.Count:hide()
						end
					else
						temp.vars.Count:setTextColor(g_i3k_get_red_color())
						temp.vars.GetBtn:disableWithChildren()
					end
					local minfo = {
						effectiveTime = info1.effectiveTime,
						id = info.id ,
						activityId = actId ,
						actType = actType ,
						times = _gifts[j].times,
						index = i,
						gift = _gifts[j].gifts
					}
					temp.vars.GetBtn:onClick(self, self.OnGetGift,minfo)
					item.vars.GradeGiftList:addItem(temp)
				end
				item.vars["button"..i]:stateToPressed(true)
			else
				item.vars["button"..i]:stateToNormal(true)
			end

		else
			item.vars["button"..i]:hide()
		end
	end
	self:updateActivitychallengeRedpoint(info1,item)
	self:setLeftRedPoint(actType, actId)
end

function wnd_fu_li:updateActivitychallengeRedpoint(info1,item)
	local gifts = info1.cfg.gifts
	for i = 1 , 5 do
		local info = gifts[i]
		if info and i3k_db_activitychallenge[info.id] then
			local _gifts = info.gifts
			for j = 1 , #_gifts do
				if self:getAllTimes(info.id,info1) >= _gifts[j].times then
					if not self:rewardHadGet(info.id ,_gifts[j].times, info1) then
						item.vars["redpoint"..i]:show()
						g_i3k_game_context:SetDynamicActivityRedPointInfo(1)
						break
					end
				end
			end
		end
	end
end

function wnd_fu_li:getAllTimes(id,info)
	for k,v in pairs(info.log.reward) do
		if v.id == id then
			return v.times
		end
	end
	return 0
end

function wnd_fu_li:rewardHadGet(id,index,info)
	for k,v in pairs(info.log.reward) do
		if v.id == id and  v.reward[index] then
			return true
		end
	end
	return false
end

function wnd_fu_li:selectButton(sender,index)
	for i = 1 , 5 do
		if index == i then
			self.ActivitychallengeInfo.item.vars["button"..i]:stateToPressed(true)
		else
			self.ActivitychallengeInfo.item.vars["button"..i]:stateToNormal(true)
		end
	end
	self:updateActivitychallengeInfo(self.ActivitychallengeInfo.item,self.ActivitychallengeInfo.info,self.ActivitychallengeInfo.actType,self.ActivitychallengeInfo.actId,index)
	self.ActivitychallengeInfo.index = index
end

function wnd_fu_li:OnGetGift(sender,minfo)
	local giftsTb = minfo.gift
	local isEnoughTable = { }
	for i,v in pairs(giftsTb) do
		isEnoughTable[v.id] = v.count
	end
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	if isEnough then
		local gift = {}
		for i,v in pairs (isEnoughTable) do
			table.insert(gift,{id = i,count = v})
		end
		i3k_sbean.activitychallengegift_take(minfo.effectiveTime,minfo.id,minfo.activityId,minfo.times,minfo.index,gift,minfo.actType)
	else
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
	end
end
--------征战天下活动 -----end----------------------


----[[ 刷新消费送礼
function wnd_fu_li:updateConsumeGiftInfo(actType, actId,effectiveTime, cfg, log,Index)
	local needValue = {actType = actType , actId = actId }
	local consumeGiftUI = require("ui/widgets/xiaofeisongli")()
	self:updateRightView(consumeGiftUI)
	self:changeContentSize(consumeGiftUI)
	self:updateCommonGiftMainInfo(consumeGiftUI, cfg.time, cfg.title, cfg.content)
	self:updateConsumeGiftLevelsInfo(consumeGiftUI, effectiveTime, cfg.levelGifts, log,actType,Index)
	self:setLeftRedPoint(actType, actId)
end

function wnd_fu_li:updateConsumeGiftLevelsInfo(control, effectiveTime, lvlGifts, log,actType,Index)
	local ConsumeGiftList = control.vars.giftList
	ConsumeGiftList:removeAllChildren()
	for i, e in ipairs(lvlGifts) do
		self:appendConsumeGiftLevelItem(control, effectiveTime, log.id, log.consume, e.gifts,e.consume, log.rewards[e.consume],actType)
	end
	local Index = activitySyncTbl[actType].index
	if Index ~= 0  then
		ConsumeGiftList:jumpToListPercent(Index)
	else
		ConsumeGiftList:jumpToListPercent(0)
	end
end

function wnd_fu_li:appendConsumeGiftLevelItem(control, effectiveTime, id, consume, gifts,needConsume, reward,actType)
	local ConsumeGiftwidgets = require("ui/widgets/xfslt")()
	self:updateConsumeGiftLevelItem(ConsumeGiftwidgets,effectiveTime, id, consume, gifts,needConsume, reward,actType,control)
	control.vars.giftList:addItem(ConsumeGiftwidgets)
end

function wnd_fu_li:updateConsumeGiftLevelItem(item, effectiveTime, id, consume, gifts, needConsume,reward,actType,control)
	local ConsumeGiftTb =
	{
		[1] = {root = item.vars.item_bg, icon = item.vars.item_icon, count = item.vars.item_count,suo = item.vars.item_suo,bg = item.vars.count_bg},
		[2] = {root = item.vars.item_bg2, icon = item.vars.item_icon2, count = item.vars.item_count2 ,suo = item.vars.item_suo2,bg = item.vars.count_bg2},
		[3] = {root = item.vars.item_bg3, icon = item.vars.item_icon3, count = item.vars.item_count3 ,suo = item.vars.item_suo3,bg = item.vars.count_bg3}
	}
	for k,v in ipairs(gifts) do
		ConsumeGiftTb[k].root:show()
		ConsumeGiftTb[k].root:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id) )
		ConsumeGiftTb[k].icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id,i3k_game_context:IsFemaleRole()))
		if v.count >= 1 then
			ConsumeGiftTb[k].count:setText("x"..v.count)
		else
			ConsumeGiftTb[k].bg:hide()
			ConsumeGiftTb[k].count:hide()
		end
		ConsumeGiftTb[k].icon:onClick(self, self.onTips,v.id)
		if v.id == 3 or v.id == 4 or v.id == 31 or v.id == 32 or v.id == 33 or v.id < 0 then
			ConsumeGiftTb[k].suo:hide()
		else
			ConsumeGiftTb[k].suo:show()
		end
	end
	local content = string.format("消费%s元宝可以获得",needConsume)
	content = g_i3k_make_color_string(content,g_i3k_get_blue_color() )
	item.vars.GoalContent:setText(content)
	local goal = string.format("(%d/%d)",consume, needConsume)
	item.vars.Count:setText(goal)
	if  consume >= needConsume then
		item.vars.Count:setTextColor(g_i3k_get_cond_color(true))
		if reward then
			item.vars.GetBtn:hide()
			item.vars.GetImage:show()
			item.vars.alreadyGet1:show()
			item.vars.alreadyGet2:show()
			item.vars.alreadyGet3:show()
			item.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2423))
			item.vars.Count:hide()
		else
			g_i3k_game_context:SetDynamicActivityRedPointInfo(1)
			item.vars.Whole:show()
			local TakeConsumeGift = {Time = effectiveTime , index = id , level = needConsume, gifts = gifts,actType = actType,control = control,item=item}
			item.vars.GetBtn:onClick(self, self.onTakeFirstPayGiftReward,  TakeConsumeGift)
			item.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2424))
		end
	else
		item.vars.GetBtnText:setText("未达标")
		item.vars.GetBtn:disableWithChildren()--disable()
		item.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2423))
	end
end

function wnd_fu_li:updateCommonGiftMainInfo(control, time, title, content)
	control.vars.ActivitiesTitle:setText(title)
	control.vars.ActivitiesContent:setText(content)
	self:excessTime(control,time)
end
--冲级送礼
function wnd_fu_li:updateGradeGiftInfo(actType, actId,effectiveTime, cfg, log,Index)
	local needValue = {actType = actType , actId = actId }
	local gradeGiftUI = require("ui/widgets/chongjisongli")()
	self:updateRightView(gradeGiftUI)
	self:changeContentSize(gradeGiftUI)
	self:updateCommonGiftMainInfo(gradeGiftUI, cfg.time, cfg.title, cfg.content)
	self:updateGradeGiftLevelsInfo(gradeGiftUI, effectiveTime, cfg.levelGifts, log,actType,Index,cfg)
	self:setLeftRedPoint(actType, actId)
end
function wnd_fu_li:updateGradeGiftLevelsInfo(control, effectiveTime, levelGifts, log,actType,Index,cfg)
	local GradeGiftList = control.vars.GradeGiftList
	GradeGiftList:removeAllChildren()
	self._chongji_auto_index = 0
	for i, e in ipairs(levelGifts) do
		self:appendGradeGiftLevelItem(control, effectiveTime, log.id, e.gifts, e.level, log.rewards[e.level],e.giftEx,actType,cfg,i)
	end
	local Index = activitySyncTbl[actType].index
	if Index ~= 0  then
		GradeGiftList:jumpToListPercent(Index)
	else
		GradeGiftList:jumpToListPercent(0)
	end
	GradeGiftList:jumpToChildWithIndex(self._chongji_auto_index)
end

function wnd_fu_li:appendGradeGiftLevelItem(control, effectiveTime, id, gift, needLevel,rewards,giftEx,actType,cfg,i)
	local GradeGiftwidgets = require("ui/widgets/cjslt")()
	self:updateGradeGiftLevelItem(GradeGiftwidgets,effectiveTime, id,gift, needLevel,rewards ,giftEx,control,actType,cfg.time,cfg.limitedTime,i)
	control.vars.GradeGiftList:addItem(GradeGiftwidgets)
end
function wnd_fu_li:updateGradeGiftLevelItem(item,effectiveTime, id, gift, needLevel,rewards ,giftEx,control,actType,time,limitedTime,auto_index)
	local gradeGiftTb =
	 {
		[1] = {root = item.vars.item_bg, icon = item.vars.item_icon, count = item.vars.item_count, buttomright = item.vars.buttomright1,suo = item.vars.item_suo,bg = item.vars.count_bg},
		[2] = {root = item.vars.item_bg2, icon = item.vars.item_icon2, count = item.vars.item_count2 ,buttomright = item.vars.buttomright2,suo = item.vars.item_suo2,bg = item.vars.count_bg2},
		[3] = {root = item.vars.item_bg3, icon = item.vars.item_icon3, count = item.vars.item_count3,buttomright = item.vars.buttomright3 ,suo = item.vars.item_suo3,bg = item.vars.count_bg3},
	}
	for k,v in ipairs(gift) do
		gradeGiftTb[k].root:show()
		gradeGiftTb[k].buttomright:hide()
		gradeGiftTb[k].root:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id) )
		gradeGiftTb[k].icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id,i3k_game_context:IsFemaleRole()))
		if v.count >= 1 then
			gradeGiftTb[k].count:setText("x"..v.count)
		else
			gradeGiftTb[k].bg:hide()
			gradeGiftTb[k].count:hide()
		end
		gradeGiftTb[k].icon:onClick(self, self.onTips,v.id)
		if v.id == 3 or v.id == 4 or v.id == 31 or v.id == 32 or v.id == 33 or v.id < 0 then
			gradeGiftTb[k].suo:hide()
		else
			gradeGiftTb[k].suo:show()
		end
	end
	if giftEx then
		local gradeExGiftIndex = giftEx.id
		item.vars.item_bg4:show()
		item.vars.item_bg4:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(gradeExGiftIndex) )
		item.vars.item_icon4:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(gradeExGiftIndex,i3k_game_context:IsFemaleRole()))
		if giftEx.count >= 1 then
			item.vars.item_count4:setText("x"..giftEx.count)
		else
			item.vars.item_bg4:hide()
			item.vars.item_count4:hide()
		end
		if gradeExGiftIndex == 3 or gradeExGiftIndex == 4 or gradeExGiftIndex == 31 or gradeExGiftIndex == 32 or gradeExGiftIndex == 33 or gradeExGiftIndex < 0 then
			item.vars.item_suo4:hide()
		else
			item.vars.item_suo4:show()
		end
		item.vars.ExBtn:onClick(self, self.onTips,gradeExGiftIndex)
	end
	local curtime = i3k_game_get_time()
	local role_createtime = g_i3k_game_context:GetRoleCreateTime()
	local havetime1 =(curtime - role_createtime)
	local cur_level = g_i3k_game_context:GetLevel()
	local content = string.format("达到%s级可以领取",needLevel)
	item.vars.GoalContent:setText(content)
	local goal = string.format("(%d/%d)",cur_level, needLevel)
	item.vars.Count:setText(goal)
	item.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2423))
	-- if havetime1 <= limitedTime then
		if  cur_level >= needLevel then
			item.vars.Count:setTextColor(g_i3k_get_cond_color(true))
			if rewards then
				item.vars.GetBtn:hide()
				item.vars.Text:show()
				item.vars.buttomright1:show()
				item.vars.buttomright2:show()
				item.vars.buttomright3:show()
				item.vars.buttomright4:show()
				item.vars.Count:hide()
				self:setGrayImg(havetime1, limitedTime, item)
			else
				g_i3k_game_context:SetDynamicActivityRedPointInfo(1)
				item.vars.Whole:show()
				if havetime1 > limitedTime then
					giftEx = nil
				end
				local TakeGradeGift = {Time = effectiveTime , index = id , level = needLevel,gifts = gift, giftEx = giftEx,control = control,actType =actType,item=item}
				item.vars.GetBtn:onClick(self, self.onTakeGradeGiftReward, TakeGradeGift)
				item.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2424))
				if self._chongji_auto_index == 0 then
					self._chongji_auto_index = auto_index
				end
				self:setGrayImg(havetime1, limitedTime, item)
			end
		else
			item.vars.GetBtn:disableWithChildren()
			self:setGrayImg(havetime1, limitedTime, item)
		end
	-- else
		-- item.vars.GetBtn:disableWithChildren()
	-- end
end

function wnd_fu_li:setGrayImg(havetime1, limitedTime, widgets)
	if havetime1 > limitedTime then
		widgets.vars.item_icon4:disableWithChildren()
		widgets.vars.item_bg4:disableWithChildren()
	end
end

----投资基金
function wnd_fu_li:updateInvestmentfundGiftInfo(actType, actId,effectiveTime, cfg, log,Index)
	local needValue = {actType = actType , actId = actId }
	local investmentfundUI = require("ui/widgets/jijin")()
	self:updateRightView(investmentfundUI)
	self:changeContentSize(investmentfundUI)
	self:updateCommonGiftMainInfo(investmentfundUI, cfg.time, cfg.title, cfg.content)
	self:updateInvestmentfundBuyInfo(investmentfundUI,effectiveTime, log, cfg,actType)
	self:updateInvestmentfundLevelsInfo(investmentfundUI,effectiveTime, cfg.returns, log, cfg.buyEndTime,actType,Index,cfg)
	self:setLeftRedPoint(actType, actId)
end

function wnd_fu_li:updateInvestmentfundBuyInfo(control,effectiveTime, log, cfg,actType)
	local content = string.format("投资%s元宝返5倍元宝",cfg.price)
	if log.buyTime > 0 then
		control.vars.BuyBtnText:setText("已投资")
		control.vars.BuyBtn:disableWithChildren()
		control.vars.BuyContent:setText(g_i3k_make_color_string(content,g_i3k_get_green_color() ) )
	else
		local roleLvl = g_i3k_game_context:GetLevel()
		local roleVipLvl = g_i3k_game_context:GetPracticalVipLevel()
		if roleLvl < cfg.levelNeed or roleVipLvl < cfg.vipLevelNeed then
			control.vars.BuyBtn:disableWithChildren()
		end
		control.vars.BuyContent:setText(content)
		control.vars.BuyBtnText:setText("投资")
		local fundBuy = {Time = effectiveTime, index = log.id, pay = cfg.price, buyendtime = cfg.buyEndTime,head = cfg.title,actType = actType,item=control}
		control.vars.BuyBtn:onClick(self, self.onOpenBuyfundGift, fundBuy)
	end
end

function wnd_fu_li:updateInvestmentfundLevelsInfo(control, effectiveTime, returns, log, buyEndTime,actType,Index,cfg)
	local InvestmentfundList = control.vars.fundGiftList
	InvestmentfundList:removeAllChildren()
	for i,v in ipairs(returns) do
		self:appendInvestmentfundLevelItem(control, effectiveTime,log.id,  v.levelReq,  log.rewards[v.daySeq], v.daySeq, v.fundReturn.count, log.buyTime, buyEndTime,actType,cfg)
	end
	local Index = activitySyncTbl[actType].index
	if Index ~= 0 then
		InvestmentfundList:jumpToListPercent(Index)
	else
		InvestmentfundList:jumpToListPercent(0)
	end
end

function wnd_fu_li:appendInvestmentfundLevelItem(control, effectiveTime, id,  levelReq, rewards, day, count,buyTime, buyEndTime,actType,cfg)
	local Investmentfundwidgets = require("ui/widgets/jjt")()
	self:updateInvestmentfundLevelItem(Investmentfundwidgets,effectiveTime, id, levelReq, rewards ,day, count,  buyTime,buyEndTime,control,actType,cfg)
	control.vars.fundGiftList:addItem(Investmentfundwidgets)
end

function wnd_fu_li:updateInvestmentfundLevelItem(item,effectiveTime, id, levelReq, rewards ,day, count,  buyTime,buyEndTime,control,actType,cfg)
	local content = string.format("购入基金第%s天返利",day+1)
	content = g_i3k_make_color_string(content,g_i3k_get_blue_color() )
	item.vars.GoalContent:setText(content)
	item.vars.Count:setText(count)
	local totalDay = g_i3k_get_day(i3k_game_get_time())
	local lastDay = g_i3k_get_day(buyTime)
	local days = totalDay - lastDay --+ 1
	item.vars.GetImage:hide()
	if buyTime > 0 then--购买时间
		if  days >= day  then
			if rewards then
				--已领取
				item.vars.GetImage:show()
				item.vars.GetBtn:hide()
			else
				g_i3k_game_context:SetDynamicActivityRedPointInfo(1)
				item.vars.Whole:show()
				local TakeInvestmentfund = {Time = effectiveTime , index = id , days = day, price = count, control = control,actType = actType,item=item,cfg = cfg}
				item.vars.GetBtn:onClick(self, self.onTakeInvestmentfundReward, TakeInvestmentfund)
			end
		else
			item.vars.GetBtnText:setText("未达标")
			item.vars.GetBtn:disableWithChildren()
		end
	else
		item.vars.GetBtnText:setText("未达标")
		item.vars.GetBtn:disableWithChildren()
	end
end

-------成长基金
function wnd_fu_li:updateGrowthfundGiftInfo(actType, actId,effectiveTime, cfg, log,Index)
	local needValue = {actType = actType , actId = actId }
	local growthfundUI = require("ui/widgets/chengzhangjijin")()
	self:updateRightView(growthfundUI)
	self:changeContentSize(growthfundUI)
	self:updateCommonGiftMainInfo(growthfundUI, cfg.time, cfg.title, cfg.content)
	self:updateGrowthfundBuyInfo(growthfundUI, effectiveTime,log,cfg,actType)
	self:updateGrowthfundLevelsInfo(growthfundUI, effectiveTime, cfg.returns, log,actType,Index,cfg)
	self:setLeftRedPoint(actType, actId)
end
function wnd_fu_li:updateGrowthfundBuyInfo(control, effectiveTime, log,cfg,actType)
	if log.buyCount > 0 then
		control.vars.BuyBtnText:setText("已投资")
		control.vars.BuyBtn:disableWithChildren()
		control.vars.BuyContent:setText(g_i3k_make_color_string(cfg.content,g_i3k_get_green_color()))
	else
		local roleLvl = g_i3k_game_context:GetLevel()
		local roleVipLvl = g_i3k_game_context:GetPracticalVipLevel()
		if roleLvl < cfg.levelNeed or roleVipLvl < cfg.vipLevelNeed then
			control.vars.BuyBtn:disableWithChildren()
		end
		control.vars.BuyBtnText:setText("投资")
		control.vars.BuyContent:setText(cfg.content)
		local growthfundBuy = {Time = effectiveTime, index = log.id, pay = cfg.price, buyendtime = cfg.buyEndTime,head = cfg.title,actType = actType,item=control}
		control.vars.BuyBtn:onClick(self, self.onOpenBuyfundGift, growthfundBuy)
	end
end
function wnd_fu_li:updateGrowthfundLevelsInfo(control, effectiveTime, returns, log,actType,Index,cfg)
	local GrowthfundGiftList = control.vars.fundGiftList
	GrowthfundGiftList:removeAllChildren()
	for i,v in ipairs(returns) do
		self:appendGrowthfundLevelItem(control, effectiveTime, log.id, v.levelReq, log.rewards[v.levelReq], v.fundReturn.count, log.buyCount,actType,cfg)
	end
	local Index = activitySyncTbl[actType].index
	if Index ~= 0 then
		GrowthfundGiftList:jumpToListPercent(Index)
	else
		GrowthfundGiftList:jumpToListPercent(0)
	end
end
function wnd_fu_li:appendGrowthfundLevelItem(control, effectiveTime, id, levelReq, rewards, count, buyCount,actType,cfg)
	local Growthfundwidgets = require("ui/widgets/chengzhangjijint")()
	self:updateGrowthfundLevelItem(Growthfundwidgets, effectiveTime, id, levelReq, rewards ,count, buyCount,actType,control,cfg)
	control.vars.fundGiftList:addItem(Growthfundwidgets)
end
function wnd_fu_li:updateGrowthfundLevelItem(item, effectiveTime, id,  levelReq, rewards, count, buyCount,actType,control,cfg)
	local cur_level = g_i3k_game_context:GetLevel()--当前等级
	local content = string.format("等级达到%d级返利", levelReq)
	content = g_i3k_make_color_string(content,g_i3k_get_blue_color() )
	item.vars.GoalContent:setText(content)--富文本
	item.vars.Count:setText(count)
	item.vars.GetImage:hide()
	if buyCount > 0 then
		if  cur_level >= levelReq then
			content = g_i3k_make_color_string(content,g_i3k_get_green_color() )
			item.vars.GoalContent:setText(content)
			if rewards then
				--已领取
				item.vars.GetImage:show()
				item.vars.GetBtn:hide()
			else
				g_i3k_game_context:SetDynamicActivityRedPointInfo(1)
				item.vars.Whole:show()
				local TakeGrowthfund = {Time = effectiveTime , index = id , level = levelReq, price = count,actType = actType,control = control,item=item,cfg = cfg}
				item.vars.GetBtn:onClick(self, self.onTakeInvestmentfundReward, TakeGrowthfund)
			end
		else
			item.vars.GetBtnText:setText("未达标")
			item.vars.GetBtn:disableWithChildren()
		end
	else
		item.vars.GetBtnText:setText("未达标")
		item.vars.GetBtn:disableWithChildren()
	end
end

---双倍掉落
function wnd_fu_li:updateDoubleDropInfo(actType, actId,time, content, title,Index)
	local needValue = {actType = actType , actId = actId }
	local doubleDropUI = require("ui/widgets/shuangbeidiaoluo")()
	self:updateRightView(doubleDropUI)
	self:changeContentSize(doubleDropUI)
	doubleDropUI.vars.ActivitiesTitle:setText(title)
	doubleDropUI.vars.ActivitiesContent:setText(content)
	self:excessTime(doubleDropUI,time)
end
--额外掉落
function wnd_fu_li:updateExtraDropInfo(actType, actId,info,index)
	local needValue = {actType = actType , actId = actId }
	local extraDropUI = require("ui/widgets/ewaidiaoluo")()
	self:updateRightView(extraDropUI)
	self:changeContentSize(extraDropUI)
	self:updateCommonGiftMainInfo(extraDropUI, info.time ,info.title, info.content)
	self:updateExtraDropLevelsInfo(extraDropUI, info.drops)
end
function wnd_fu_li:updateExtraDropLevelsInfo(control, drops)
	local ExtraDropList = control.vars.ExtraDropList
	ExtraDropList:removeAllChildren()
	for i, v in ipairs(drops) do
		self:appendExtraDropLevelItem(control, v)
	end
end

function wnd_fu_li:appendExtraDropLevelItem(control, id )
	local ExtraDropwidgets= require("ui/widgets/ewaidiaoluot")()
	self:updateExtraDropLevelItem(ExtraDropwidgets, id)
	control.vars.ExtraDropList:addItem(ExtraDropwidgets)
end
function wnd_fu_li:updateExtraDropLevelItem(item, id)
	item.vars.grade_icon:show()
	item.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id) )
	item.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	if id == 3 or id == 4 or id == 31 or id== 32 or id == 33 or id < 0 then
		item.vars.item_suo:hide()
	else
		item.vars.item_suo:show()
	end
	item.vars.item_icon:onClick(self, self.onTips,id)
end
--收集兑换 收集送礼，植树节奖励兑换
function wnd_fu_li:updateExchangeGiftInfo(actType, actId,effectiveTime, cfg, log,Index)
	local needValue = {actType = actType , actId = actId }
	local exchangeGiftUI = require("ui/widgets/shoujisongli")()
	self:updateRightView(exchangeGiftUI)
	self:changeContentSize(exchangeGiftUI)
	self:updateCommonGiftMainInfo(exchangeGiftUI, cfg.time, cfg.title, cfg.content)
	self:updateExchangeGiftLevelsInfo(exchangeGiftUI, effectiveTime, cfg.itemGifts, log,actType,Index)
	self:setLeftRedPoint(actType, actId)
end
function wnd_fu_li:updateExchangeGiftLevelsInfo(control, effectiveTime, itemGifts, log,actType,Index)
	local exchangeGiftList = control.vars.ExchangeGiftList
	exchangeGiftList:removeAllChildren()
	for i,v in ipairs(itemGifts) do
		self:appendExchangeGiftLevelItem(control, effectiveTime, v.items, v.gift, v.seq, v.maxExchange, log.exchangeCount[i], log.id,actType)
	end
	local Index = activitySyncTbl[actType].index
	if Index ~= 0  then
		exchangeGiftList:jumpToListPercent(Index)
	else
		exchangeGiftList:jumpToListPercent(0)
	end
end
function wnd_fu_li:appendExchangeGiftLevelItem(control, effectiveTime,items, gift,seq, maxExchange, exchangeCount, id ,actType)
	local exchangeGiftwidgets= require("ui/widgets/shoujisonglit")()
	self:updateExchangeGiftLevelItem(exchangeGiftwidgets,effectiveTime,items, gift, seq, maxExchange, exchangeCount, id,control,actType)
	control.vars.ExchangeGiftList:addItem(exchangeGiftwidgets)
end
function wnd_fu_li:updateExchangeGiftLevelItem(item,effectiveTime, items, gift, seq, maxExchange, exchangeCount, id,control,actType)
	local exchangeGiftTb =
	{
		[1] = {root = item.vars.item_bg, icon = item.vars.item_icon, count = item.vars.item_count,suo = item.vars.item_suo},
		[2] = {root = item.vars.item_bg2, icon = item.vars.item_icon2, count = item.vars.item_count2 ,suo = item.vars.item_suo2},
		[3] = {root = item.vars.item_bg3, icon = item.vars.item_icon3, count = item.vars.item_count3,suo = item.vars.item_suo3},
	}
	--点击的时候用全局变量记下来getListPercent()的值，刷新时调用jumpToListPercent(percent)点击位置 取scroll的percent
	----[[把当前第几个位置记下来index，重新填完数据之后，找到之前的位置jumpToChildWithIndex(seq)控件
	local isItemEnough = false  --单个物品数量是否满足
	local isCanExchange = true  --可以兑换物品的标记
	for k,v in ipairs(items) do
		exchangeGiftTb[k].root:show()
		exchangeGiftTb[k].root:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id) )
		exchangeGiftTb[k].icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id,i3k_game_context:IsFemaleRole()))
		local cur_Count = g_i3k_game_context:GetCommonItemCount(v.id)
		cur_Count = cur_Count + g_i3k_game_context:GetCommonItemCount(-v.id)
		local count = string.format("(%d/%d)",cur_Count,v.count)
		exchangeGiftTb[k].count:setText(count)
		exchangeGiftTb[k].icon:onClick(self, self.onTips,v.id)
		if v.id == 3 or v.id == 4 or v.id == 31 or v.id == 32 or v.id == 33 or v.id < 0 then
			exchangeGiftTb[k].suo:hide()
		else
			exchangeGiftTb[k].suo:show()
		end
		item.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2424))
		if maxExchange == 0 then
			item.vars.Text:setText("不限次数")
			if  cur_Count >= v.count then--
				isItemEnough = true
				exchangeGiftTb[k].count:setTextColor(g_i3k_get_cond_color(true))
				item.vars.Whole:show()
				local TakeExchangeGift = {Time = effectiveTime , index = id , sequencer = seq,gifts = gift,items =items, actType = actType,control=control,item = item}
				item.vars.GetBtn:onClick(self, self.onTakeExchangeGiftReward, TakeExchangeGift)--扣除
				item.vars.Text:setTextColor(g_i3k_get_cond_color(true))
			else
				isItemEnough = false
				exchangeGiftTb[k].count:setTextColor(g_i3k_get_cond_color(false))
				item.vars.Whole:hide()
				item.vars.GetBtnText:setText("未达标")
				item.vars.GetBtn:disableWithChildren()
				item.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2423))
			end
		elseif  exchangeCount then
			local content = string.format("(%d/%d)",exchangeCount,maxExchange)
			item.vars.Text:setText(content)
			if exchangeCount < maxExchange then
				if  cur_Count >= v.count then--
					isItemEnough = true
					exchangeGiftTb[k].count:setTextColor(g_i3k_get_cond_color(true))
					local TakeExchangeGift = {Time = effectiveTime , index = id , sequencer = seq,gifts = gift,items =items, actType = actType,control=control,item = item}
					item.vars.GetBtn:onClick(self, self.onTakeExchangeGiftReward, TakeExchangeGift)--扣除
					item.vars.Text:setTextColor(g_i3k_get_cond_color(true))
				else
					isItemEnough = false
					exchangeGiftTb[k].count:setTextColor(g_i3k_get_cond_color(false))
					item.vars.Whole:hide()
					item.vars.GetBtnText:setText("未达标")
					item.vars.GetBtn:disableWithChildren()
					item.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2423))
				end
			else
				item.vars.GetBtn:hide()
				item.vars.GetImage:show()
				item.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2423))
				if  cur_Count >= v.count then--
					exchangeGiftTb[k].count:setTextColor(g_i3k_get_cond_color(true))
				else
					exchangeGiftTb[k].count:setTextColor(g_i3k_get_cond_color(false))
				end
			end
		else
			local content = string.format("(0/%d)",maxExchange)
			item.vars.Text:setText(content)
			if  cur_Count >= v.count then--
				isItemEnough = true
				exchangeGiftTb[k].count:setTextColor(g_i3k_get_cond_color(true))
				item.vars.Whole:show()
				local TakeExchangeGift = {Time = effectiveTime , index = id , sequencer = seq,gifts = gift,items =items, actType = actType,control=control,item = item}
				item.vars.GetBtn:onClick(self, self.onTakeExchangeGiftReward, TakeExchangeGift)--扣除
				item.vars.Text:setTextColor(g_i3k_get_cond_color(true))
			else
				isItemEnough = false
				exchangeGiftTb[k].count:setTextColor(g_i3k_get_cond_color(false))
				item.vars.Whole:hide()
				item.vars.GetBtnText:setText("未达标")
				item.vars.GetBtn:disableWithChildren()
				item.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2423))
			end
		end
		if isItemEnough == false then
			isCanExchange = false
		end
	end
	if isCanExchange then
		g_i3k_game_context:SetDynamicActivityRedPointInfo(1)
	end
	item.vars.item_bg4:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(gift.id) )
	item.vars.item_icon4:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(gift.id,i3k_game_context:IsFemaleRole()))
	if gift.count >= 1 then
			item.vars.item_count4:setText("x"..gift.count)
		else
			item.vars.count_bg4:hide()
			item.vars.item_count4:hide()
		end
	if gift.id == 3 or gift.id == 4 or gift.id == 31 or gift.id == 32 or gift.id == 33 or gift.id < 0 then
			item.vars.item_suo4:hide()
		else
			item.vars.item_suo4:show()
		end
	item.vars.ExBtn:onClick(self, self.onTips,gift.id)

end
---连续登陆
function wnd_fu_li:updateLoginGiftInfo(actType, actId,effectiveTime, cfg, log,Index)
	local needValue = {actType = actType , actId = actId }
	local loginGiftUI = require("ui/widgets/lianxudenglu")()
	self:updateRightView(loginGiftUI)
	self:changeContentSize(loginGiftUI)
	self:updateCommonGiftMainInfo(loginGiftUI, cfg.time, cfg.title, cfg.content)
	self:updateloginGiftLevelsInfo(loginGiftUI, effectiveTime, cfg.dayGifts, log,actType,Index,cfg.time)
	self:setLeftRedPoint(actType, actId)
end
function wnd_fu_li:updateloginGiftLevelsInfo(control, effectiveTime, dayGifts, log,actType,Index,time)
	local loginGiftList = control.vars.ExchangeGiftList
	loginGiftList:removeAllChildren()
	self._lianxu_auto_index = 1 -- 默认第一个条
	for i,v in ipairs(dayGifts) do
		self:appendloginGiftLevelItem(control, effectiveTime, v.dayReq, v.gifts, log.id,log.loginDays,log.rewards[v.dayReq],log.lastLoginTime,actType,log,time,i)
	end
	local Index = activitySyncTbl[actType].index
	if Index ~= 0  then
		loginGiftList:jumpToListPercent(Index)
	else
		loginGiftList:jumpToListPercent(0)
	end
	if #dayGifts > self._lianxu_auto_index then -- 超过列表的数量，那么就不给跳转

		loginGiftList:jumpToChildWithIndex(self._lianxu_auto_index)
	end
end
function wnd_fu_li:appendloginGiftLevelItem(control, effectiveTime, dayReq,gift,id,loginDays,rewards,lastLoginTime,actType,log,time,auto_index)
	local loginGiftwidgets = require("ui/widgets/lianxudenglut")()
	self:updateLoginGiftLevelItem(loginGiftwidgets,effectiveTime,dayReq, gift, id, loginDays,rewards,lastLoginTime,actType,control,log,time,auto_index)
	control.vars.ExchangeGiftList:addItem(loginGiftwidgets)
end
function wnd_fu_li:updateLoginGiftLevelItem(item,effectiveTime,dayReq, gift, id, loginDays,rewards,lastLoginTime,actType,control,log,time,auto_index)
	local loginGiftTb =
	{
		[1] = {root = item.vars.item_bg, icon = item.vars.item_icon, count = item.vars.item_count,suo = item.vars.item_suo,bg = item.vars.count_bg},
		[2] = {root = item.vars.item_bg2, icon = item.vars.item_icon2, count = item.vars.item_count2 ,suo = item.vars.item_suo2,bg = item.vars.count_bg2},
		[3] = {root = item.vars.item_bg3, icon = item.vars.item_icon3, count = item.vars.item_count3 ,suo = item.vars.item_suo3,bg = item.vars.count_bg3}
	}
	for k,v in ipairs(gift) do
		loginGiftTb[k].root:show()
		loginGiftTb[k].root:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id) )
		loginGiftTb[k].icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id,i3k_game_context:IsFemaleRole()))
		local cur_Count = g_i3k_game_context:GetCommonItemCount(v.id)
		if v.count >= 1 then
				loginGiftTb[k].count:setText("x"..v.count)
			else
				loginGiftTb[k].bg:hide()
				loginGiftTb[k].count:hide()
			end
		if v.id == 3 or v.id == 4 or v.id == 31 or v.id == 32 or v.id == 33 or v.id < 0 then
			loginGiftTb[k].suo:hide()
		else
			loginGiftTb[k].suo:show()
		end
		loginGiftTb[k].icon:onClick(self, self.onTips,v.id)
	end
	local content = string.format("第%s天",dayReq)
	item.vars.GoalContent:setText(content)
	item.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2424))
	--最后登录时间在活动截止时间之前lastLoginTime
	if lastLoginTime <= time.endTime then
		if  loginDays >= dayReq then
			item.vars.GoalContent:setTextColor(g_i3k_get_cond_color(true))
			if rewards then

				item.vars.GetBtn:hide()
				item.vars.GetImage:show()
				item.vars.alreadyGet1:show()
				item.vars.alreadyGet2:show()
				item.vars.alreadyGet3:show()
				item.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2423))
			else
				if dayReq == 1 then
					--self.red_point:show()
					g_i3k_game_context:SetDynamicActivityRedPointInfo(1)
					item.vars.Whole:show()
					local TakeLoginGift = {Time = effectiveTime , index = id , days = dayReq, gifts = gift,actType = actType,control = control,item=item}
					item.vars.GetBtn:onClick(self, self.onTakeFirstPayGiftReward,  TakeLoginGift)
					if self._lianxu_auto_index == 0 then
						self._lianxu_auto_index = auto_index
					end
				else
					if log.rewards[dayReq-1] then
						--self.red_point:show()
						g_i3k_game_context:SetDynamicActivityRedPointInfo(1)
						item.vars.Whole:show()
						local TakeLoginGift = {Time = effectiveTime , index = id , days = dayReq, gifts = gift,actType = actType,control = control,item=item}
						item.vars.GetBtn:onClick(self, self.onTakeFirstPayGiftReward,  TakeLoginGift)
						if self._lianxu_auto_index == 0 then
							self._lianxu_auto_index = auto_index
						end
					else
						item.vars.GoalContent:setTextColor(g_i3k_get_cond_color(false))
						item.vars.GetBtnText:setText("未达标")
						item.vars.GetBtn:disableWithChildren()--disable()
						item.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2423))
					end
				end

			end
		else
			item.vars.GoalContent:setTextColor(g_i3k_get_cond_color(false))
			item.vars.GetBtnText:setText("未达标")
			item.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2423))
			item.vars.GetBtn:disableWithChildren()--disable()
		end
	end
end
------礼包兑换码
function wnd_fu_li:updateGiftPackageInfo(actType, actId,effectiveTime, Index)
	local needValue = {actType = actType , actId = actId }
	local giftPackageUI = require("ui/widgets/duihuanma")()
	self:updateRightView(giftPackageUI)
	self:changeContentSize(giftPackageUI)
	self.editBox = giftPackageUI.vars.editBox
	self.editBox:setPlaceHolder("请输入兑换码")
	giftPackageUI.vars.GetBtn:onClick(self,self.exchange,{id = actId,effectiveTime = effectiveTime,actType = actType})
end
function wnd_fu_li:exchange(sender,needValue)
	local content =	self.editBox:getText()
	if content then
		if content == "" then
			g_i3k_ui_mgr:PopupTipMessage("输入不能为空")
		else
			if self:checkKey(content) then
				i3k_sbean.activities_giftpackage_take(needValue.effectiveTime,needValue.id,content,needValue.actType)
			else
				g_i3k_ui_mgr:PopupTipMessage("请输入正确的数位元元和字母的组合")
			end
		end
	end
end

function wnd_fu_li:checkKey(keycode)---/^(?=.*?[a-zA-Z])(?=.*?[0-9])[a-zA-Z0-9]$/
	--return string.len(keycode) == 16 and string.find(keycode,"^[%d%a]+$")
	return string.find(keycode,"^[%d%a]+$")
end

function wnd_fu_li:onStore(sender)
	-- if true then
	-- 	return i3k_get_string(829)
	-- end
	g_i3k_logic:OpenChannelPayUI()
	g_i3k_ui_mgr:CloseUI(eUIID_Fuli)   --关闭当前
end

function wnd_fu_li:excessTime(control,time)
	----[[倒计时每个板子上写一个回调函数，把self 放到onupdate里（小于三天的时候，三天到一年内显示截至时间，否则显示不限时）
	local cur_Time = i3k_game_get_time()
	local totalDay = g_i3k_get_day(i3k_game_get_time())
	local lastDay = g_i3k_get_day(time.endTime)
	local days = lastDay - totalDay   --+ 1
	local havetime =(time.endTime - cur_Time- self._time)
	local min = math.floor(havetime / 60 %60)
	local hour = math.floor(havetime/3600%24)
	local day = math.floor(havetime/3600/24)
	if days <=  3  then--
		local time1 = havetime - self._time
		local str = string.format("%d天%d时%d分",day,hour,min)
		control.vars.ActivitiesTime:setText(str )
	else
		local finitetime =  g_i3k_get_ActDateRange(time.startTime, time.endTime)
		control.vars.ActivitiesTime:setText(finitetime)
	end
end
function wnd_fu_li:OnUpdate(dTime)
	if self._time ~= 0 then
		self._time = self._time + dTime
	end
end
function wnd_fu_li:updateLeftRedPoint(acts)
	self._notice = true
	for k,v in ipairs (acts) do
		if v.notice ~= 0 then
			self._notice = false
		end
	end
	if self._notice then
		g_i3k_game_context:SetFuliOther(0)
	end
end
function wnd_fu_li:setLeftRedPoint(atype,id)
	self._notice = true
	for i, e in ipairs(self._activitiesList) do
		if id == e.id and atype == e.atype then
			if g_i3k_game_context:GetDynamicActivityRedPointInfo() == 1 then---
				e.red_point:show()
			else
				e.red_point:hide()
				e.notice = 0
			end
		end
		if e.notice ~= 0 then
			self._notice = false
		end
	end
	if self._notice then
		g_i3k_game_context:SetFuliOther(0)
	end
end

function wnd_fu_li:onOpenBuyfundGift(sender,needValue)
	self._percent = needValue.actType
	self._actID = needValue.index
	local function callback(isOk)
		if isOk then
			local haveDiamond = g_i3k_game_context:GetDiamond(true)--true非绑定
			if haveDiamond >= needValue.pay then
				if needValue.actType == 5 then
					needValue.item.vars.BuyBtn:disableWithChildren()
					i3k_sbean.activities_investmentfund_buy(needValue.Time,needValue.index,needValue.pay,needValue.buyendtime,needValue.actType)
				elseif needValue.actType == 6 then
					needValue.item.vars.BuyBtn:disableWithChildren()
					i3k_sbean.activities_growthfund_buy(needValue.Time,needValue.index,needValue.pay,needValue.buyendtime,needValue.actType)
				elseif needValue.actType == 23 then
					local callFun = function()
						needValue.item.vars.BuyBtn:disableWithChildren()
					end
					if self:checkCanBuyCircleFund(needValue) then
						i3k_sbean.activities_cyclefund_buy(needValue.Time,needValue.index,needValue.pay,needValue.actType, callFun)
					end
				end
			else
				local tips = string.format("%s", "您的元宝不足，购买失败")
				g_i3k_ui_mgr:PopupTipMessage(tips)
			end
		end
	end
	local desc = string.format("确定花费[<c=green>%d%s%s%s",needValue.pay,"</c>]元宝,购买" ,needValue.head,"?")
	g_i3k_ui_mgr:ShowMessageBox2(desc,callback)
end
function wnd_fu_li:onTakeFirstPayGiftReward(sender,needValue)
	self._percent = needValue.actType
	self._actID = needValue.index
	local giftsTb = needValue.gifts
	local isEnoughTable = { }
	local index = 0
	for i,v in pairs(giftsTb) do
		index = index + 1
		isEnoughTable[v.id] = v.count
	end
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	if isEnough then
		needValue.item.vars.GetBtn:disableWithChildren()
		if needValue.actType == 2 then
			local percent = needValue.control.vars.giftList:getListPercent()
			activitySyncTbl[needValue.actType].index = needValue.control.vars.giftList:getListPercent()
			i3k_sbean.activities_paygift_take(needValue.Time,needValue.index, needValue.level,needValue.actType ,needValue.gifts,percent,index)
		elseif needValue.actType == 3 then
			local percent = needValue.control.vars.giftList:getListPercent()
			activitySyncTbl[needValue.actType].index = needValue.control.vars.giftList:getListPercent()
			i3k_sbean.activities_consumegift_take(needValue.Time, needValue.index,needValue.level,needValue.actType,needValue.gifts,percent,index)

		elseif needValue.actType == 10 then
			local percent = needValue.control.vars.ExchangeGiftList:getListPercent()
			activitySyncTbl[needValue.actType].index = needValue.control.vars.ExchangeGiftList:getListPercent()
			i3k_sbean.activities_logingift_take(needValue.Time,needValue.index, needValue.days,needValue.actType,needValue.gifts,percent,index)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
	end
end
 -- ?
function wnd_fu_li:onTakeGradeGiftReward(sender,needValue)
	self._percent = needValue.actType
	self._actID = needValue.index
	local giftsTb = needValue.gifts
	local giftsExTb = needValue.giftEx
	local isEnoughTable = { }
	local gift = {}
	local index = 0
	for i,v in pairs(giftsTb) do
		isEnoughTable[v.id] = v.count
	end
	if giftsExTb then
		isEnoughTable[giftsExTb.id] = giftsExTb.count
	end
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	for i,v in pairs (isEnoughTable) do
		index = index + 1
		gift[index] = {id = i,count = v}

	end
	if isEnough then
		if needValue.actType == 1 then
			i3k_sbean.activities_firstpaygift_take(needValue.Time,needValue.index,gift,index,needValue.actType)
		elseif needValue.actType == 4 then
			local percent = needValue.control.vars.GradeGiftList:getListPercent()
			activitySyncTbl[needValue.actType].index = needValue.control.vars.GradeGiftList:getListPercent()
			i3k_sbean.activities_gradegift_take(needValue.Time,needValue.index,needValue.level,needValue.actType,gift,percent,index)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
	end
end

function wnd_fu_li:onTakeInvestmentfundReward(sender, needValue)
	local roleLvl = g_i3k_game_context:GetLevel()
	local roleVipLvl = g_i3k_game_context:GetPracticalVipLevel()
	if roleLvl < needValue.cfg.levelNeed then
		return g_i3k_ui_mgr:PopupTipMessage("角色等级不足")
	end
	if roleVipLvl < needValue.cfg.vipLevelNeed then
		return g_i3k_ui_mgr:PopupTipMessage("角色贵族等级不足")
	end
	self._percent = needValue.actType
	self._actID = needValue.index
	needValue.item.vars.GetBtn:disableWithChildren()
	activitySyncTbl[needValue.actType].index = needValue.control.vars.fundGiftList:getListPercent()
	if needValue.actType == 5 then
		i3k_sbean.activities_investmentfund_take(needValue.Time,needValue.index,needValue.days, needValue.price,needValue.actType,percent)
	elseif needValue.actType == 6 then
		i3k_sbean.activities_growthfund_take(needValue.Time,needValue.index,needValue.level,needValue.price,needValue.actType,percent)
	elseif needValue.actType == 23 then
		i3k_sbean.activities_cyclefund_take(needValue.Time,needValue.index,needValue.seq,needValue.actType)
	end
end
function wnd_fu_li:onTakeExchangeGiftReward(sender,needValue)
	self._percent = needValue.actType
	self._actID = needValue.index
	local giftsTb = needValue.gifts

	local isEnoughTable = { }
	local gift = {}
	local index = 0
	activitySyncTbl[needValue.actType].index = needValue.control.vars.ExchangeGiftList:getListPercent()
	isEnoughTable[giftsTb.id] = giftsTb.count
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	for i,v in pairs (isEnoughTable) do
		index = index + 1
		gift[index] = {id = i,count = v}
	end
	if isEnough then
		if g_i3k_game_context:IsExcNeedShowTip(g_FULI_EXCHANGE_TYPE) then
			local tbl = {needValue = needValue, gift = gift, percent = percent}  --与正常情况协议传输字段一致
			g_i3k_ui_mgr:OpenUI(eUIID_Today_Tip)
			g_i3k_ui_mgr:RefreshUI(eUIID_Today_Tip, g_FULI_EXCHANGE_TYPE, tbl)
		else
			local flag = true
			for k, v  in pairs(gift) do
				if not g_i3k_db.i3k_db_prop_gender_qualify(v.id) then
					flag = false
				end
			end
			if not flag then
				local callfunction = function(ok)
					if ok then
						needValue.item.vars.GetBtn:disableWithChildren()
						i3k_sbean.activities_exchangegift_take(needValue.Time,needValue.index,needValue.sequencer,needValue.items,needValue.actType,gift,percent)
					end
				end
				g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(50068), callfunction)
				return
			end
			needValue.item.vars.GetBtn:disableWithChildren()
			i3k_sbean.activities_exchangegift_take(needValue.Time,needValue.index,needValue.sequencer,needValue.items,needValue.actType,gift,percent)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
	end
end
function wnd_fu_li:onTips(sender,itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end
function wnd_fu_li:setCanUse(canUse)
	self._canUse = canUse
end

-- function wnd_fu_li:openHuhushengfeng(sender, item )
-- 	local monthCardUI = require("ui/widgets/huhushengfeng")()
-- 	self:updateRightView(monthCardUI)
-- 	self:changeContentSize(monthCardUI)
-- 	monthCardUI.vars.chongzhi:onClick(self, self.onStore)
--
-- 	ui_set_hero_model(monthCardUI.vars.model, 321)
-- 	local path = i3k_db_models[321].path
-- 	local uiscale = i3k_db_models[321].uiscale
-- 	monthCardUI.vars.model:setSprite(path)
-- 	monthCardUI.vars.model:setSprSize(uiscale)
-- 	monthCardUI.vars.model:playAction("stand",-1)
-- 	self:updateButtonState(item)
-- 	monthCardUI.vars.model:setRotation(2)
-- end

-- function wnd_fu_li:openJiniandaji(sender, item )
-- 	local monthCardUI = require("ui/widgets/jiniandaji")()
-- 	self:updateRightView(monthCardUI)
-- 	self:changeContentSize(monthCardUI)
-- 	monthCardUI.vars.chongzhi:onClick(self, self.onStore)
-- 	self:updateButtonState(item)
-- 	ui_set_hero_model(monthCardUI.vars.model, 2151)
-- 	local path = i3k_db_models[2151].path
-- 	local uiscale = i3k_db_models[2151].uiscale
-- 	monthCardUI.vars.model:setSprite(path)
-- 	monthCardUI.vars.model:setSprSize(uiscale)
-- 	monthCardUI.vars.model:playAction("stand",-1)
-- 	monthCardUI.vars.model:setRotation(2)
-- end

--------升级特惠活动--begain-------------------
function wnd_fu_li:updateUpgradepurchase(actType, actId,info)
	local MRCZSL = require("ui/widgets/xianshilibao")()
	g_i3k_game_context:SetDynamicActivityRedPointInfo(0)
	MRCZSL.vars.needDiamond:setText("x"..(info.cfg.levelPurchases.price))
	self:updateRightView(MRCZSL)
	self:changeContentSize(MRCZSL)
	self:updateUpgradepurchaseInfo(MRCZSL,info,actType, actId)
	self:excessTime(MRCZSL,{startTime = info.endTime - info.cfg.levelPurchases.limitedTime , endTime = info.endTime})
	--self.ActivitychallengeInfo	 = {item = MRCZSL, info = info, actType = actType,actId = actId ,index = index}
end

function wnd_fu_li:updateUpgradepurchaseInfo(item,info1,actType,actId)
	local tmp_str = string.format(info1.cfg.content)
	item.vars.ActivitiesContent:setText(tmp_str)
	local gifts = info1.cfg.levelPurchases.goods
	local bannerImg = info1.cfg.levelPurchases.icon

	for i,v in ipairs(gifts) do
		local temp = require("ui/widgets/xianshilibaot")()
		item.vars.GradeGiftList:addItem(temp)
		temp.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id) )
		temp.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id))
		temp.vars.item_count:setText("x"..v.count)
		temp.vars.bt:onClick(self, self.onTips,v.id)
	end

	if bannerImg ~= 0 then
		local iconId = i3k_db_activity_icons[bannerImg]
		if iconId then
			item.vars.ActivitiesBanner:setImage(g_i3k_db.i3k_db_get_icon_path(iconId))
		end
	end

	item.vars.chongzhi:onClick(self, self.onStore)
	local minfo = {
		effectiveTime = info1.effectiveTime,
		id = info1.id ,
		activityId = actId ,
		actType = actType ,
		gift = gifts,
		level = info1.cfg.levelPurchases.level,
		price = info1.cfg.levelPurchases.price
	}
	item.vars.buyBtn:onClick(self, self.onBuy,minfo)
	item.vars.cnt1:setImage( "czt#"..info1.cfg.levelPurchases.level/10)
	item.vars.cnt2:setImage("czt#"..info1.cfg.levelPurchases.level%10)
	if info1.log.reward and info1.log.reward == 1 then
		item.vars.buyBtn:disableWithChildren()
	end
	self:updateUpgradepurchaseRedpoint(info1,item)
	self:setLeftRedPoint(actType, actId)
end
function wnd_fu_li:updateUpgradepurchaseRedpoint(info1,item)
	local reward = info1.log.reward or 0
	if reward == 0 and g_i3k_game_context:GetLevel() >= info1.cfg.levelPurchases.level then
		g_i3k_game_context:SetDynamicActivityRedPointInfo(1)
	end
end
function wnd_fu_li:onBuy(sender,minfo)
	local text = string.format("确定花费%s元宝购买？", minfo.price)
	local callback = function(is_ok)
		if is_ok then
			if g_i3k_game_context:GetDiamond(true) < minfo.price then
				local tips = string.format("%s", "元宝不足，请储值后购买")
				return g_i3k_ui_mgr:PopupTipMessage(tips)
			end
			local giftsTb = minfo.gift
			local isEnoughTable = { }
			for i,v in pairs(giftsTb) do
				isEnoughTable[v.id] = v.count
			end
			local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
			if isEnough then
				local gift = {}
				for i,v in pairs (isEnoughTable) do
					table.insert(gift,{id = i,count = v})
				end
				i3k_sbean.upgradepurchase_buy(minfo.effectiveTime,minfo.id,minfo.activityId,gift,minfo.actType, minfo.price)
			else
				g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
			end
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(text, callback)
end
--------升级特惠活动 -----end----------------------


---------------老虎机 begin---------------------
function wnd_fu_li:updateOneArmBandit(type, id, info)
	g_i3k_game_context:setOneArmBanditIDType(id, type)
	local ui = require("ui/widgets/laohuji")()
	self:updateRightView(ui)
	self:changeContentSize(ui)
	self:updateOneArmBanditInfo(ui, id, info)
	self:updateOneArmBanditLeftTime(ui, info)
	self:onPlayOneArmBanditAnis(0, ui) -- 初始化显示为000
end
function wnd_fu_li:updateOneArmBanditInfo(widgets, id, info)
	local useTimes = info.log.useTimes
	local canUseTimes = 0
	if g_i3k_game_context:GetLevel() >= info.cfg.levelTimesReq then
		canUseTimes = canUseTimes + 1
	end
	if info.log.pay > 0 then
		canUseTimes = canUseTimes + 1
	end

	self._oneArmBanditLeftTimes = canUseTimes - useTimes
	widgets.vars.leftTimes:setText("剩余"..(self._oneArmBanditLeftTimes).."次")
	g_i3k_game_context:setOneArmBanditRedPoint(true)
	if self._oneArmBanditLeftTimes <= 0 then
		widgets.vars.GetBtn:disableWithChildren()
		g_i3k_game_context:setOneArmBanditRedPoint(false)
	end
	self._laohuji = widgets
	self:setOneArmBanditUIRedPoint()
	local data = {id = id, effectiveTime = info.effectiveTime, times = canUseTimes - useTimes, endTime = info.cfg.time.endTime}
	widgets.vars.GetBtn:onClick(self, self.onTakeOneArmBandit, data)

	-- 显示模型
	local npcmodule = widgets.vars.model
	local modelID = 1302
	-- ui_set_hero_model(npcmodule, modelID)
	local mcfg = i3k_db_models[modelID];
	if mcfg then
		npcmodule:setSprite(mcfg.path);
		npcmodule:setSprSize(mcfg.uiscale);
		npcmodule:playAction("zhiyin01")
	end

	widgets.vars.desc:setText(string.format(i3k_get_string(15373, info.cfg.levelTimesReq)))
end
-- InvokeUIFunction
function wnd_fu_li:onTakeOneArmBanditCallback(value)
	if self._laohuji then
		local widgets = self._laohuji
		self:onPlayOneArmBanditAnis(value, widgets)
		self:updateOneArmBanditLabel(widgets)
	end
end

function wnd_fu_li:setOneArmBanditUIRedPoint()
	local bValue = g_i3k_game_context:getOneArmBanditRedPoint()
	local id, type = g_i3k_game_context:getOneArmBanditIDType()
	if id and type then
		for i, e in ipairs(self._activitiesList) do
			if id == e.id and type == e.atype then
				e.red_point:setVisible(bValue or false)
			end
		end
	end
end

-- 显示剩余时间和元宝
function wnd_fu_li:updateOneArmBanditLeftTime(widgets, info)
	local toDay = g_i3k_get_day(i3k_game_get_time())
	local startDay = g_i3k_get_day(info.cfg.time.startTime)
	local endDay = g_i3k_get_day(info.cfg.time.endTime)
	local leftDays = endDay - toDay > 0 and endDay - toDay - 1 or 0 -- 剩余几天
	local longDays = toDay - startDay > 0 and toDay - startDay + 1 or 1 -- 持续了几天
	widgets.vars.daysLabel:setText(leftDays.."天")
	if info.cfg.dayLeft[longDays] then
		local leftDiamond = info.cfg.dayLeft[longDays].left
		widgets.vars.leftDiamond:setText(leftDiamond)
	else
		local leftDiamond = info.cfg.dayLeft[#info.cfg.dayLeft].left
		widgets.vars.leftDiamond:setText(leftDiamond)
	end
end

function wnd_fu_li:onTakeOneArmBandit(sender, data)
	if data.times <= 0 then
		g_i3k_ui_mgr:PopupTipMessage("抽奖次数不足")
		return
	end
	if data.endTime < i3k_game_get_time() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15381))
		return
	end
	i3k_sbean.take_oneArmBandit(data.id, data.effectiveTime)
end
-- 老虎机播放动画
function wnd_fu_li:onPlayOneArmBanditAnis(value, widgets)
	local a = value % 10 -- 个位
	local b = ((value - a) / 10) % 10
	local c = ((value - a - 10*b)/100) % 10

	if value == 0 then
		widgets.vars.num1:show()
		widgets.vars.num2:show()
		widgets.vars.num3:show()
		widgets.vars.num1:setImage(i3k_db_icons[self:getOneArmBanditImg(c)].path)
		widgets.vars.num2:setImage(i3k_db_icons[self:getOneArmBanditImg(b)].path)
		widgets.vars.num3:setImage(i3k_db_icons[self:getOneArmBanditImg(a)].path)
	else
		widgets.vars.num1:hide()
		widgets.vars.num2:hide()
		widgets.vars.num3:hide()
	end

	if value > 0 then
		widgets.vars.num1:setImage(i3k_db_icons[self:getOneArmBanditImg(c)].path)
		widgets.vars.num2:setImage(i3k_db_icons[self:getOneArmBanditImg(b)].path)
		widgets.vars.num3:setImage(i3k_db_icons[self:getOneArmBanditImg(a)].path)
		self.co1 = g_i3k_coroutine_mgr:StartCoroutine(function()
			g_i3k_coroutine_mgr.WaitForSeconds(1.3) --延时
			widgets.vars.num1:show()
			g_i3k_coroutine_mgr.WaitForSeconds(0.5) --延时
			widgets.vars.num2:show()
			g_i3k_coroutine_mgr.WaitForSeconds(0.5) --延时
			widgets.vars.num3:show()
			g_i3k_ui_mgr:PopupTipMessage(string.format(i3k_get_string(15374, value)))
			g_i3k_coroutine_mgr:StopCoroutine(self.co1)
			self.co1 = nil
		end)
		widgets.anis.c_dh1.play()
		widgets.anis.c_dh2.play()
		widgets.anis.c_dh3.play()
	end
end
function wnd_fu_li:getOneArmBanditImg(value) -- 必须是个位数
	local offset = 3554
	return offset + value
end
function wnd_fu_li:updateOneArmBanditLabel(widgets)
	self._oneArmBanditLeftTimes = self._oneArmBanditLeftTimes - 1
	widgets.vars.leftTimes:setText("剩余"..(self._oneArmBanditLeftTimes).."次")
	if self._oneArmBanditLeftTimes <= 0 then
		widgets.vars.GetBtn:disableWithChildren()
		g_i3k_game_context:setOneArmBanditRedPoint(false)
	end
	self:setOneArmBanditUIRedPoint()
end


---------------老虎机end--------------------


--------充值排行-----begin--------------------
function wnd_fu_li:updatePayRank(type, id, info)
	local ui = require("ui/widgets/chongzhipaihang")()
	self:updateRightView(ui)
	self:changeContentSize(ui)
	self:updatePayRankInfo(ui, id, info)
	self:excessTime(ui, info.cfg.time)
	self:setLeftRedPoint(type, id)
end

function wnd_fu_li:updatePayRankInfo(widgets, id, info)
	local content = info.cfg.content
	widgets.vars.ActivitiesContent:setText(content)
	local pay_rank_btn = widgets.vars.pay_rank_btn
	pay_rank_btn:onClick(self, self.onPayRank, id)
end

function wnd_fu_li:onPayRank(sender, actId)
	i3k_sbean.syncRechargeRank(actId, actType, true)
end

---------------充值排行--------end-----------

--------消费排行-----begin--------------------
function wnd_fu_li:updateConsumeRank(type, id, info)
	local ui = require("ui/widgets/xiaofeipaihang")()
	self:updateRightView(ui)
	self:changeContentSize(ui)
	self:updateConsumeRankInfo(ui, id, info)
	self:excessTime(ui, info.cfg.time)
	self:setLeftRedPoint(type, id)
end

function wnd_fu_li:updateConsumeRankInfo(widgets, id, info)
	local content = info.cfg.content
	widgets.vars.ActivitiesContent:setText(content)
	local consume_rank_btn = widgets.vars.consume_rank_btn
	consume_rank_btn:onClick(self, self.onConsumeRank, id)
end

function wnd_fu_li:onConsumeRank(sender, actId)
	i3k_sbean.syncConsumeRank(actId, actType, true)
end

---------------消费排行--------end-----------

--不带title
function wnd_fu_li:updateCommonGiftMainInfo2(control, time, content)
	control.vars.ActivitiesContent:setText(content)
	self:excessTime(control,time)
end

---------------新登录活动------START---------
function wnd_fu_li:updateLuckyGift(actType, actId, info)
	local ui = require("ui/widgets/kaigongli")()
	self:updateRightView(ui)
	self:changeContentSize(ui)
	self:updateCommonGiftMainInfo2(ui, info.cfg.time, info.cfg.content)  --时间，活动内容
	self:updateLuckyGiftInfo(ui, actId, actType, info)
	self:setLeftRedPoint(actType, actId)
end

function wnd_fu_li:updateLuckyGiftInfo(control, actId, actType, info)
	local luckyGiftList = control.vars.LuckyGiftList
	luckyGiftList:removeAllChildren()
	self._luckyGift_auto_index = 0
	for i,v in ipairs(info.cfg.luckyGifts) do
		self:appendLuckyGiftItem(control, actId, actType, info, v.dayReq, v.gifts, i)
	end

	if #info.cfg.luckyGifts > self._luckyGift_auto_index then
		luckyGiftList:jumpToChildWithIndex(self._luckyGift_auto_index)
	end
end

function wnd_fu_li:appendLuckyGiftItem(control, actId, actType, info, dayReq, gifts, auto_index)
	local luckyGiftwidgets= require("ui/widgets/kaigonglit")()
	self:updateLuckyGiftItem(luckyGiftwidgets, control, actId, actType, info, dayReq, gifts, auto_index)
	control.vars.LuckyGiftList:addItem(luckyGiftwidgets)
end

function wnd_fu_li:updateLuckyGiftItem(ui, control, actId, actType, info, dayReq, gifts, auto_index)
	local roleVipLvl = g_i3k_game_context:GetVipLevel()
	local vipLvlReq = info.cfg.vipLvlReq
	local dayNow = g_i3k_get_day(i3k_game_get_time())
	local dayStart = g_i3k_get_day(info.cfg.time.startTime) + dayReq

	for k = 1, 3 do
		if gifts[k] then
			local q = gifts[k]
			ui.vars["item_bg"..k]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(q.id))
			ui.vars["item_icon"..k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(q.id), g_i3k_game_context:IsFemaleRole())
			ui.vars["item_count"..k]:setText("x"..q.count)
			ui.vars["item_suo"..k]:setVisible(q.id > 0)
			ui.vars["item_btn"..k]:onClick(self, self.onTips, q.id)
			ui.vars["item_bg"..k]:show()
		else
			ui.vars["item_bg"..k]:hide()
		end
	end

	local time = info.cfg.time.startTime + dayReq*86400 --秒
	ui.vars.dayNum:setText(g_i3k_get_ActDateStr(time))

	if dayNow < dayStart then  --时间限制
		ui.vars.takeRewardLabel:setText("时间未到")
		ui.vars.takeRewardBtn:disableWithChildren()
	else
		if info.log.rewards[dayReq] then  --领过奖了
			ui.vars.GetImage:setVisible(true)
			ui.vars.takeRewardBtn:setVisible(false)
		else
			if roleVipLvl < vipLvlReq then  --vip限制
				ui.vars.takeRewardLabel:setText("领取")
				ui.vars.takeRewardBtn:onClick(self, function ()
					g_i3k_ui_mgr:PopupTipMessage(string.format("vip等级需要达到%s级方可领取", vipLvlReq))
				end)
			else
				local callback = function ()
					ui.vars.GetImage:setVisible(true)
					ui.vars.takeRewardBtn:setVisible(false)
					g_i3k_game_context:SetDynamicActivityRedPointInfo(0)
					i3k_sbean.syncLuckyGift(actId, actType) --领完奖励也要同步一下
				end
				local data = {actId = actId, actType = actType, effectiveTime = info.effectiveTime, dayReq = dayReq, gifts = gifts, control = control, callback = callback}
				ui.vars.takeRewardBtn:onClick(self, self.onTakeLuckyGift, data)
				ui.vars.takeRewardLabel:setText("领取")

				g_i3k_game_context:SetDynamicActivityRedPointInfo(1)
				if self._luckyGift_auto_index == 0 then
					self._luckyGift_auto_index = auto_index
				end
			end
		end
	end
end

function wnd_fu_li:onTakeLuckyGift(sender, data)
	local giftsTb = data.gifts
	local isEnoughTable = { }
	for i,v in pairs(giftsTb) do
		isEnoughTable[v.id] = v.count
	end
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	if isEnough then
		i3k_sbean.take_luckyGift(data.actId, data.actType, data.effectiveTime, data.dayReq, data.gifts, data.callback)
	else
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
	end
end
---------------新登录活动------END-----------

---------------共享好礼活动------START---------
function wnd_fu_li:updateSharedGift(actType, actId, info)
	local ui = require("ui/widgets/gongxianghaoli")()
	self:updateRightView(ui)
	self:changeContentSize(ui)
	self:updateCommonGiftMainInfo2(ui, info.cfg.time, info.cfg.content)  --设置时间，活动内容
	self:updateSharedGiftInfo(ui, actId, actType, info)
	self:setLeftRedPoint(actType, actId)
end

function wnd_fu_li:updateSharedGiftInfo(control, actId, actType, info)
	local sharedGiftList = control.vars.SharedGiftList
	sharedGiftList:removeAllChildren()

	for _, v in ipairs(info.cfg.gifts) do
		self:appendSharedGiftItem(control, actId, actType, info, v.payReq, v.lvlReq, v.levelGifts)
	end
end

function wnd_fu_li:appendSharedGiftItem(control, actId, actType, info, payReq, lvlReq, levelGifts)
	local sharedGiftwidgets= require("ui/widgets/gongxianghaolit")()
	self:updateSharedGiftItem(sharedGiftwidgets, control, actId, actType, info, payReq, lvlReq, levelGifts)
	control.vars.SharedGiftList:addItem(sharedGiftwidgets)
end

function wnd_fu_li:updateSharedGiftItem(ui, control, actId, actType, info, payReq, lvlReq, levelGifts)
	local takedRewards = {}
	if info.log.takedRewards and info.log.takedRewards[payReq] then
		takedRewards = info.log.takedRewards[payReq].takedRewards
	end

	local myPayNum = info.log.totalPay
	local payRoleCnt = info.payRoleCnt
	local maxPayRoles = levelGifts[#levelGifts].payroles

	if payReq == 0 then
		ui.vars.condition_desc:setText(i3k_get_string(16369))
	else
		ui.vars.condition_desc:setText(i3k_get_string(16370, payReq))
	end

	local percent = payRoleCnt/maxPayRoles*100
	ui.vars.progress_bar:setPercent(percent < 100 and percent or 100)

	local boxAni = {[1] = ui.anis.c_bx, [2] = ui.anis.c_bx3, [3] = ui.anis.c_bx5}

	for k = 1, 3 do
		local gifts = levelGifts[k].gifts
		local payRoles = levelGifts[k].payroles

		ui.vars["reward_icon_"..k]:setVisible(not takedRewards[payRoles])
		ui.vars["reward_get_icon_"..k]:setVisible(takedRewards[payRoles])
		ui.vars["value_"..k]:setText(string.format("%s", payRoles))

		if payRoleCnt >= payRoles then
			local callback = function()
				i3k_sbean.syncSharedGift(actId, actType)
			end
			if not takedRewards[payRoles] then
				boxAni[k].play()
			end
			ui.vars["reward_btn_"..k]:onClick(self, self.onTakeSharedGift, {actId = actId, actType = actType, effectiveTime = info.effectiveTime, payReq = payReq, myPayNum = myPayNum, payRoles = payRoles, lvlReq = lvlReq, gifts = gifts, takedRewards = takedRewards[payRoles], callback = callback})
		else
			boxAni[k].stop()
			ui.vars["reward_btn_"..k]:onClick(self, self.onShowSharedGiftInfo, gifts)
		end
	end
end

function wnd_fu_li:onTakeSharedGift(sender, data)
	local giftsTb = data.gifts
	local levelReq = data.lvlReq
	local payReq = data.payReq

	if data.takedRewards then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16371))
	end

	if data.myPayNum >= payReq then
		if g_i3k_game_context:GetLevel() >= levelReq then
			local isEnoughTable = { }
			for _, v in ipairs(giftsTb) do
				isEnoughTable[v.id] = v.count
			end
			local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
			if isEnough then
				i3k_sbean.take_sharedGift(data.actId, data.actType, data.effectiveTime, data.payReq, data.payRoles, data.gifts, data.callback)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16372))
			end
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16373, levelReq))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16374, payReq))
	end
end

function wnd_fu_li:onShowSharedGiftInfo(sender, gifts)
	local gift = {}
	for i = 1, #gifts do
		gift[i] = {ItemID = gifts[i].id, count = gifts[i].count}
	end
	g_i3k_ui_mgr:OpenUI(eUIID_RewardTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_RewardTips, gift)
end

------------共享好礼活动end--------------------


------------循环基金活动begin--------------------
function wnd_fu_li:updateCycleFundGiftInfo(actType, actId, effectiveTime, cfg, log)
	local cycleFundUI = require("ui/widgets/lianxujijin")()
	self:updateRightView(cycleFundUI)
	self:changeContentSize(cycleFundUI)
	self:excessTime(cycleFundUI, cfg.time)
	self:updateCycleFundBuyInfo(cycleFundUI, effectiveTime, log, cfg, actType)
	self:updateCycleFundLevelsInfo(cycleFundUI, effectiveTime, cfg, log, actType)
	self:setLeftRedPoint(actType, actId)
end

function wnd_fu_li:updateCycleFundBuyInfo(control, effectiveTime, log, cfg, actType)
	local levelReq = cfg.levelNeed
	local vipReq = cfg.vipLevelNeed
	local cardReq = cfg.cardNeed

	control.vars.BuyContent:setText(i3k_get_string(16809))
	if log.seq >= 0 then
		control.vars.BuyBtnText:setText("已投资")
		control.vars.BuyBtn:disableWithChildren()
	else
		control.vars.BuyBtnText:setText("投资")
		local fundBuy = {Time = effectiveTime, index = cfg.id, pay = cfg.price, buyendtime = cfg.buyEndTime, head = cfg.title, actType = actType, item = control, levelReq = levelReq, vipReq = vipReq, cardReq = cardReq}
		control.vars.BuyBtn:onClick(self, self.onOpenBuyfundGift, fundBuy)
	end
end

function wnd_fu_li:updateCycleFundLevelsInfo(control, effectiveTime, cfg, log, actType)
	local cycleFundList = control.vars.fundGiftList
	cycleFundList:removeAllChildren()
	for _, v in ipairs(cfg.returns) do
		self:appendCycleFundLevelItem(control, effectiveTime, cfg, log, actType, v.seq, v.fundReturn)
	end
	local Index = activitySyncTbl[actType].index
	if Index ~= 0 then
		cycleFundList:jumpToListPercent(Index)
	else
		cycleFundList:jumpToListPercent(0)
	end
end

function wnd_fu_li:appendCycleFundLevelItem(control, effectiveTime, cfg, log, actType, seq, fundReturn)
	local cycleFundWidgets = require("ui/widgets/lianxujijint")()
	self:updateCycleFundLevelItem(cycleFundWidgets, control, effectiveTime, cfg, log, actType, seq, fundReturn)
	control.vars.fundGiftList:addItem(cycleFundWidgets)
end

function wnd_fu_li:updateCycleFundLevelItem(item, control, effectiveTime, cfg, log, actType, seq, fundReturn)
	item.vars.GoalContent:setText(i3k_get_string(16810, seq))
	item.vars.Count:setText(fundReturn.count)
	item.vars.GetImage:hide()
	item.vars.Whole:hide()

	local totalDay = g_i3k_get_day(i3k_game_get_time())
	local lastDay = g_i3k_get_day(log.lastTakeRewardTime)

	if log.seq >= 0 then
		if seq <= log.seq then
			if totalDay >= lastDay then
				--已领取
				item.vars.GetImage:show()
				item.vars.GetBtn:hide()
			end
		else
			if seq == log.seq + 1 and totalDay > lastDay then
				g_i3k_game_context:SetDynamicActivityRedPointInfo(1)
				item.vars.Whole:show()
				local cycleFund = {Time = effectiveTime, index = cfg.id, seq = seq, control = control, actType = actType, item = item, cfg = cfg}
				item.vars.GetBtn:onClick(self, self.onTakeInvestmentfundReward, cycleFund)
			else
				item.vars.GetBtnText:setText("未达标")
				item.vars.GetBtn:disableWithChildren()
			end
		end
	else
		item.vars.GetBtnText:setText("未达标")
		item.vars.GetBtn:disableWithChildren()
	end
end

function wnd_fu_li:checkCanBuyCircleFund(data)
	if g_i3k_game_context:GetLevel() < data.levelReq then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16805))
		return false
	end

	if g_i3k_game_context:GetVipLevel() < data.vipReq then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16806, data.vipReq))
		return false
	end

	if data.cardReq ~= 0 then  --如果有月卡周卡需求
		local state = g_i3k_game_context:checkSpecialCardConditionImpl(data.cardReq)
		if not state then
			if data.cardReq == MONTH_CARD then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15378))
			elseif data.cardReq == WEEK_CARD then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15377))
			end
			return false
		end
	end

	return true
end
------------循环基金活动end--------------------

------------连续使用道具送礼begin--------------
function wnd_fu_li:updateUseItemsRewardInfo(actType, actId, effectiveTime, cfg, log)
	local useItemsRewardUI = require("ui/widgets/xiaohaosongli")()
	self:updateRightView(useItemsRewardUI)
	self:changeContentSize(useItemsRewardUI)
	self:updateCommonGiftMainInfo2(useItemsRewardUI, cfg.time, cfg.content)  --设置活动时间及内容
	self:updateUseItemsInfo(useItemsRewardUI, actType, actId, effectiveTime, cfg, log)
	self:setLeftRedPoint(actType, actId)
end

function wnd_fu_li:updateUseItemsInfo(control, actType, actId, effectiveTime, cfg, log)
	control.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(cfg.levels[1].uid))
	control.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(cfg.levels[1].uid))
	control.vars.item_icon:onClick(self, self.onTips, cfg.levels[1].uid)
	self:updateUseItemsScrollInfo(control, actType, actId, effectiveTime, cfg, log)
	local Index = activitySyncTbl[actType].index
	if Index ~= 0 then
		control.vars.GradeGiftList:jumpToListPercent(Index)
	else
		control.vars.GradeGiftList:jumpToListPercent(0)
	end
	if self._useItemReward_auto_index > 0 then
		control.vars.GradeGiftList:jumpToChildWithIndex(self._useItemReward_auto_index)
	end
end

function wnd_fu_li:updateUseItemsScrollInfo(control, actType, actId, effectiveTime, cfg, log)
	local jumpFlag = false
	local scroll = control.vars.GradeGiftList
	scroll:removeAllChildren()
	g_i3k_game_context:SetDynamicActivityRedPointInfo(0)
	for i, v in ipairs(cfg.levels) do
		local rewardInfoUI = require("ui/widgets/xiaohaosonglit")()
		if #v.gifts == 1 then
			rewardInfoUI.vars.item2_bg:hide()
			rewardInfoUI.vars.item1_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.gifts[1].id))
			rewardInfoUI.vars.item1_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.gifts[1].id))
			rewardInfoUI.vars.item1_count:setText("x"..v.gifts[1].count)
			rewardInfoUI.vars.item1_suo:setVisible(v.gifts[1].id > 0)
			rewardInfoUI.vars.item1_btn:onClick(self, self.onTips, v.gifts[1].id)
		else
		    rewardInfoUI.vars.item2_bg:show()
			for k = 1, 2 do
				rewardInfoUI.vars["item"..k.."_icon"]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.gifts[k].id))
				rewardInfoUI.vars["item"..k.."_bg"]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.gifts[k].id))
				rewardInfoUI.vars["item"..k.."_count"]:setText("x"..v.gifts[k].count)
				rewardInfoUI.vars["item"..k.."_suo"]:setVisible(v.gifts[k].id > 0)
				rewardInfoUI.vars["item"..k.."_btn"]:onClick(self, self.onTips, v.gifts[k].id)
			end
		end

		local getReward = {time = effectiveTime, id = actId, level = v.levelid, gifts = v.gifts, act_type = actType}
		rewardInfoUI.vars.GetBtn:onClick(self, self.getUseItemsReward, getReward)
		if log.log[v.uid] then
			rewardInfoUI.vars.count_info:setText(i3k_get_string(1155, log.log[v.uid].."/"..v.ucount))
			rewardInfoUI.vars.count_info:setTextColor(g_i3k_get_cond_color(log.log[v.uid] >= v.ucount))
		else
			rewardInfoUI.vars.count_info:setText(i3k_get_string(1155, "0".."/"..v.ucount))
			rewardInfoUI.vars.count_info:setTextColor(g_i3k_get_cond_color(false))
		end

		if next(log.takedRewards) and table.indexof(log.takedRewards, v.levelid) then
			rewardInfoUI.vars.GetBtn:hide()
			rewardInfoUI.vars.got_icon:show()
		else
		    rewardInfoUI.vars.GetBtn:show()
			rewardInfoUI.vars.got_icon:hide()
			if log.log[v.uid] then
				if log.log[v.uid] >= v.ucount then
					rewardInfoUI.vars.GetBtn:enableWithChildren()
					rewardInfoUI.vars.GetBtnText:setText("领取")
					g_i3k_game_context:SetDynamicActivityRedPointInfo(1)
					if not jumpFlag then
						self._useItemReward_auto_index = v.levelid
						jumpFlag = true
					end
				else
					rewardInfoUI.vars.GetBtn:disableWithChildren()
					rewardInfoUI.vars.GetBtnText:setText("未达标")
				end
			else
				rewardInfoUI.vars.GetBtn:disableWithChildren()
				rewardInfoUI.vars.GetBtnText:setText("未达标")
			end
		end
		scroll:addItem(rewardInfoUI)
	end
end

function wnd_fu_li:getUseItemsReward(sender, getReward)
	local reward = {}
	for i, v in ipairs(getReward.gifts) do
		reward[v.id] = v.count
	end
	if not g_i3k_game_context:IsBagEnough(reward) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
	else
	    i3k_sbean.sync_activities_getUseItems_reward(getReward.time, getReward.id, getReward.level, getReward.gifts, getReward.act_type)
	end
end
------------连续使用道具送礼end--------------

------------买赠活动begin--------------
function wnd_fu_li:updataBuyItemGetItem(extraGift)
	local control = require("ui/widgets/youmaiyouzeng")()
	self:updateRightView(control)
	self:changeContentSize(control)
	self:showBuyGetInfo(control, extraGift.gifts)
	self:updateCommonGiftMainInfo(control, extraGift.time, extraGift.title, extraGift.content)
end

function wnd_fu_li:showBuyGetInfo(control, gifts)
	control.vars.desc:setText(string.format("注：%s", i3k_get_string(1158)))
	local giftList = {}
	for k, v in pairs(gifts) do
		table.insert(giftList, v)
	end
	table.sort(giftList, function (a, b)
		return a.gid < b.gid
	end)
	for k, v in ipairs(giftList) do
		local widget = require("ui/widgets/youmaiyouzengt")()
		control.vars.gradeGiftList:addItem(widget)
		widget.vars.buyItemBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.gitem.id))
		widget.vars.buyItemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.gitem.id))
		widget.vars.buyItemCount:setText(string.format("x%s", v.gitem.count))
		widget.vars.buyItemSuo:hide()
		widget.vars.buyItemBtn:onClick(self, self.onTips, v.gitem.id)
		widget.vars.getItemBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.iid))
		widget.vars.getItemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.iid))
		widget.vars.getItemCount:setText(string.format("x%s", v.icount))
		widget.vars.getItemSuo:setVisible(v.iid > 0)
		widget.vars.getItemBtn:onClick(self, self.onTips, v.iid)
		widget.vars.buyBtn:onClick(self, self.gotoVipStore, v.gitem.id)
	end
end

function wnd_fu_li:gotoVipStore(sender, id)
	local itemCfg = g_i3k_db.i3k_db_get_isShow_btn(id)
	if itemCfg and itemCfg.showBuyBtn == 1 and g_i3k_game_context:GetLevel() >= itemCfg.showLevel then
		local callback = function (itemId)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_VipStore, "transIdToIndex", itemId)
		end
		g_i3k_logic:OpenVipStoreUI(itemCfg.showType, itemCfg.isBound, itemCfg.id, callback)
	else
		g_i3k_logic:OpenVipStoreUI(3)
	end
end
------------买赠活动end--------------

------------红包拿来活动start--------------
function wnd_fu_li:updateRedPack(actType, actId, effectiveTime, cfg, log)
	local redPackUI = require("ui/widgets/xinnianhongbao")()
	self:updateRightView(redPackUI)
	self:changeContentSize(redPackUI)
	self:updateRedPackInfo(redPackUI, effectiveTime, cfg, log, actType, actId)
	self:updateRedPackTime(redPackUI, cfg)
	self:setLeftRedPoint(actType, actId)
end

function wnd_fu_li:updateRedPackInfo(control, effectiveTime, cfg, log, actType, actId)
	local redPackList = control.vars.redPackList
	redPackList:removeAllChildren()

	control.vars.des:setText(cfg.content)
	control.vars.helpBtn:onClick(self, function()
		local diamondRate = cfg.rewardConf.diamondRate/100
		g_i3k_ui_mgr:OpenUI(eUIID_RedPacketHelp)
		g_i3k_ui_mgr:RefreshUI(eUIID_RedPacketHelp, i3k_get_string(17021, diamondRate))
	end)

	local function getTypeInfo(cfg)
		local curTime = i3k_game_get_time()

		local saveStartTime = cfg.saveConf.saveTime.startTime
		local saveEndTime = cfg.saveConf.saveTime.endTime

		local rewardStartTime = cfg.rewardConf.rewardTime.startTime
		local rewardEndTime = cfg.rewardConf.rewardTime.endTime

		local redPackCnt = g_i3k_get_day(rewardEndTime) - g_i3k_get_day(rewardStartTime) + 1
		local day = 0

		if curTime >= saveStartTime and curTime <= saveEndTime then  --消费时间段
			redPackCnt = g_i3k_get_day(curTime) - g_i3k_get_day(saveStartTime) + 1
			day = redPackCnt
			return e_Type_Cost, redPackCnt, day
		elseif curTime >= rewardStartTime and curTime <= rewardEndTime then  --返利时间段
			day = g_i3k_get_day(curTime) - g_i3k_get_day(rewardStartTime) + 1
			return e_Type_Cashback, redPackCnt, day
		else
			return e_Type_Show, redPackCnt, day
		end
	end

	local showType, redPackCnt, day = getTypeInfo(cfg)

	if day == 0 then  --活动处于预览阶段
		control.vars.des2:setText(i3k_get_string(17016))
	else
		if showType == e_Type_Cost then
			control.vars.des2:setText(i3k_get_string(17017, day))
		elseif showType == e_Type_Cashback then
			control.vars.des2:setText(i3k_get_string(17018, day))
		end
	end
	local allBars = redPackList:addChildWithCount("ui/widgets/xinnianhongbao2t", 5, redPackCnt)
	local data = {showType = showType, actType = actType, actId = actId, effectiveTime = effectiveTime, log = log, saveConf = cfg.saveConf, rewardConf = cfg.rewardConf}
	for k, v in ipairs(allBars) do
		local rewardDay = g_i3k_get_day(data.rewardConf.rewardTime.startTime) + k - 1
		v.vars.img:setImage(g_i3k_db.i3k_db_get_icon_path(data.log.takedRewards[rewardDay] and 5585 or 5584))  --红包的状态
		v.vars.btn:onClick(self, function()
			if cfg then
				local vipLvl = g_i3k_game_context:GetVipLevel()
				local lvl = g_i3k_game_context:GetLevel()
				if vipLvl < cfg.vipReq or lvl < cfg.levelReq then
					return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17020, cfg.levelReq, cfg.vipReq))
				end
			end
			if data.showType ~= e_Type_Show then
				if data.showType == e_Type_Cost and k == day then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17019))
				else
					g_i3k_ui_mgr:OpenUI(eUIID_RedPacketTips)
					g_i3k_ui_mgr:RefreshUI(eUIID_RedPacketTips, k, data)
				end
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17016))
			end
		end)
	end
end

function wnd_fu_li:updateRedPackTime(control, cfg)
	local saveStartTime = g_i3k_get_ActDateStr(cfg.saveConf.saveTime.startTime)
	local saveEndTime = g_i3k_get_ActDateStr(cfg.saveConf.saveTime.endTime)
	local rewardStartTime = g_i3k_get_ActDateStr(cfg.rewardConf.rewardTime.startTime)
	local rewardEndTime = g_i3k_get_ActDateStr(cfg.rewardConf.rewardTime.endTime)
	control.vars.actTime:setText(i3k_get_string(17022, saveStartTime, saveEndTime, rewardStartTime, rewardEndTime))
end
------------红包拿来活动end--------------

---------------+13 拼多多-----------
function wnd_fu_li:updateMoreRoleDiscount(id, type, info)
	local ui = require("ui/widgets/pinduoduo")()
	self:updateRightView(ui)
	self:changeContentSize(ui)
	self:updateMoreRoleDiscountInfo(ui, id, type, info)
	self:updateMoreRoleDiscountTime(ui, info.cfg.time)
end

function wnd_fu_li:updateMoreRoleDiscountInfo(ui, id, type, info)
	ui.vars.ActivitiesContent:setText(info.cfg.content)
	ui.vars.helpBtn:onClick(self, self.onMoreRoleDiscountHelpBtn, info)
	self._moreRoleDiscountUI = ui
	self:updateDragonCoinCount()
	ui.vars.addBtn:onClick(self, self.onUpdateMoreRoleDiscountBtn)
	local scroll = ui.vars.scroll
	local percent = scroll:getListPercent()
	scroll:removeAllChildren()
	local infoList = info.cfg.gift.goods
	table.sort(infoList, function(a, b)
		return a.id < b.id
	end)
	for k, v in pairs(infoList) do
		local widget = require("ui/widgets/pinduoduot")()
		local itemID = v.itemId
		local itemCount = g_i3k_game_context:GetCommonItemCanUseCount(itemID)

		local logCfg = info.log[k]
		if not logCfg then
			logCfg ={ isJoin = 0, buyTime = 0, curRoleSize = 0 }
		end

		widget.vars.itemBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
		widget.vars.itemName:setText(g_i3k_db.i3k_db_get_common_item_name(itemID))
		widget.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID, g_i3k_game_context:IsFemaleRole()))
		widget.vars.itemBtn:onClick(self, self.onTips, itemID)
		widget.vars.itemLock:setVisible(itemID > 0)
		widget.vars.itemCount:setText(v.itemCount)

		local curPrice, curRoleCount = self:getCurPrice(v.discounts, v.baseCost, logCfg.curRoleSize)
		widget.vars.nowPrice:setText("x"..curPrice)
		if curPrice == v.baseCost then
			widget.vars.lineImg:hide()
		end
		widget.vars.processBar:setPercent(logCfg.curRoleSize / curRoleCount * 100)
		widget.vars.processLabel:setText(logCfg.curRoleSize.."/"..curRoleCount)

		local cur_Time = i3k_game_get_time()
		local joinTime = info.cfg.gift.joinTime
		if cur_Time > joinTime.startTime and cur_Time < joinTime.endTime then
			local btnInfo = {gid = v.id, id = id, type = type, effectiveTime = info.effectiveTime, levelReq = info.cfg.gift.levelReq,
			 vipReq = info.cfg.gift.vipReq , costItem = v.costItem, price = v.baseCost}
			widget.vars.buyBtn:onClick(self, self.onJoinMoreRoleDiscount, btnInfo)
			widget.vars.GetBtnText:setText("参团")
			if logCfg.isJoin == 1 then
				widget.vars.buyBtn:disableWithChildren()
				widget.vars.GetBtnText:setText("已参团")
			end
		elseif cur_Time > joinTime.endTime then
			local btnInfo = {gid = v.id, id = id, type = type, effectiveTime = info.effectiveTime, levelReq = info.cfg.gift.levelReq,
				vipReq = info.cfg.gift.vipReq, costItem = v.costItem, price = curPrice, getItem ={ [1] = {id = v.itemId, count = v.itemCount}} }
			widget.vars.buyBtn:onClick(self, self.onBuyMoreRoleDiscount, btnInfo)
			widget.vars.GetBtnText:setText("购买")
			if logCfg.buyTime >= v.buyTime then
				widget.vars.buyBtn:disableWithChildren()
				widget.vars.GetBtnText:setText("已购买")
			end
			if logCfg.isJoin == 0 then
				widget.vars.buyBtn:disableWithChildren()
			end
		end

		widget.vars.buyCount:setText("已购买"..logCfg.buyTime.."/"..v.buyTime)
		widget.vars.needItem1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.costItem, g_i3k_game_context:IsFemaleRole()))
		widget.vars.needItem2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.costItem, g_i3k_game_context:IsFemaleRole())) -- 同上图标
		widget.vars.oriPrice:setText("x"..v.baseCost)


		widget.vars.helpBtn:onClick(self, self.onMoreRoleDiscountHelp, {info = v, logCfg = logCfg})
		scroll:addItem(widget)
	end
	scroll:jumpToListPercent(percent)
end

-- InvokeUIFunction
function wnd_fu_li:updateDragonCoinCount()
	if self._moreRoleDiscountUI then
		local ui = self._moreRoleDiscountUI
		local coinType = g_BASE_ITEM_DRAGON_COIN
		local coinCount = g_i3k_game_context:GetCommonItemCanUseCount(coinType)
		ui.vars.needImg:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(coinType, g_i3k_game_context:IsFemaleRole()))
		ui.vars.countLabel:setText(coinCount)
	end
end

function wnd_fu_li:getCurPrice(list, oriPrice, curCount)
	table.sort(list, function(a, b) return a.roleCount < b.roleCount end)
	-- 两个边界
	if curCount < list[1].roleCount then
		return oriPrice, list[1].roleCount
	end
	if curCount >= list[#list].roleCount then
		return list[#list].price, list[#list].roleCount
	end

	for i = 1, #list do
		if list[i].roleCount <= curCount and list[i+1].roleCount > curCount then
			return list[i].price, list[i+1].roleCount
		end
	end
end

-- 参团
function wnd_fu_li:onJoinMoreRoleDiscount(sender, data)
	local vipLvl = g_i3k_game_context:GetVipLevel()
	local roleLevel = g_i3k_game_context:GetLevel()
	if vipLvl < data.vipReq then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17101, data.vipReq))
		return
	end
	if roleLevel < data.levelReq then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17100, data.levelReq) )
		return
	end

	local costItem = data.costItem
	local count = data.price
	local coinCount = g_i3k_game_context:GetCommonItemCanUseCount(costItem)
	if coinCount < count then
		local func = function(ok)
			if ok then
				--g_i3k_logic:OpenPayActivityUI(4)
				g_i3k_logic:OpenChannelPayUI() 
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(17102), func)
		return
	end
	i3k_sbean.joinMoreRoleDiscount(data)
end

-- 购买
function wnd_fu_li:onBuyMoreRoleDiscount(sender, data)
	local vipLvl = g_i3k_game_context:GetVipLevel()
	local roleLevel = g_i3k_game_context:GetLevel()
	if vipLvl < data.vipReq then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17101, data.vipReq))
		return
	end
	if roleLevel < data.levelReq then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17100, data.levelReq) )
		return
	end
	local costItem = data.costItem
	local count = data.price
	local coinCount = g_i3k_game_context:GetCommonItemCanUseCount(costItem)
	if coinCount < count then
		local func = function(ok)
			if ok then
				--g_i3k_logic:OpenPayActivityUI(4)
				g_i3k_logic:OpenChannelPayUI()
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(17102), func)
		return
	end

	i3k_sbean.buyMoreRoleDiscount(data)
end

function wnd_fu_li:onMoreRoleDiscountHelp(sender, v)
	g_i3k_ui_mgr:OpenUI(eUIID_PinDuoDuoTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_PinDuoDuoTips, v)
end

function wnd_fu_li:updateMoreRoleDiscountTime(ui, time)
	self:excessTime(ui, time)
end

-- 加号按钮
function wnd_fu_li:onUpdateMoreRoleDiscountBtn(sender)
	g_i3k_game_context:setPinduoduoDragonCoinOpen(true)
	g_i3k_logic:OpenChannelPayUI(nil, g_CHANNEL_LONGHUNBI_TYPE) 
end

function wnd_fu_li:onMoreRoleDiscountHelpBtn(sender, info)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(17081, info.cfg.gift.levelReq, info.cfg.gift.vipReq))
end

------手机绑定start--------
function wnd_fu_li:updateMobileBindInfo(lastTime, phoneNumber)
	local bindUI = require("ui/widgets/bangdingshouji")()
	self:updateRightView(bindUI)
	self:changeContentSize(bindUI)

	self.myBindNumber = phoneNumber

	self:setEditBoxContent(bindUI)
	self:updateCodeBtnState(bindUI, lastTime)
	self:updateRewardBtnState(bindUI, phoneNumber)
	self:updateBindRewardScroll(bindUI)
end

function wnd_fu_li:setEditBoxContent(bindUI)
	self.phoneNumber = ""
	bindUI.vars.number:setText(i3k_get_string(1358))

	local numberBox = bindUI.vars.editBox1
	numberBox:setMaxLength(11)  --手机号限定11个数字
	numberBox:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	numberBox:addEventListener(function(eventType)
		if eventType == "ended" then
			local str = numberBox:getText()
			if str ~= "" then
				bindUI.vars.number:setText(str)
				self.phoneNumber = str
				numberBox:setText("")
			else
				self.phoneNumber = ""
				bindUI.vars.number:setText(i3k_get_string(1358))
			end
		end
	end)

	self.verifyCode = ""
	bindUI.vars.verifyCode:setText("")
	local codeBox = bindUI.vars.editBox2
	codeBox:setMaxLength(4)  --验证码限定4个数字
	codeBox:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	codeBox:addEventListener(function(eventType)
		if eventType == "ended" then
			local str = codeBox:getText()
			if str ~= "" then
				bindUI.vars.verifyCode:setText(str)
				self.verifyCode = str
				codeBox:setText("")
			else
				self.verifyCode = ""
				bindUI.vars.verifyCode:setText("")
			end
		end
	end)
end

function wnd_fu_li:updateBindRewardScroll(bindUI)
	bindUI.vars.scroll:removeAllChildren()
	for _, v in ipairs(i3k_db_common.mobileBindReward) do
		if v.id ~=0 and v.count > 0 then
			local widget = require("ui/widgets/bangdingshoujit")()
			widget.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
			widget.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
			widget.vars.num:setText("x" .. v.count)
			widget.vars.lock:setVisible(v.id > 0)
			widget.vars.btn:onClick(self, function()
				g_i3k_ui_mgr:ShowCommonItemInfo(v.id)
			end)
			bindUI.vars.scroll:addItem(widget)
		end
	end
end

function wnd_fu_li:updateCodeBtnState(bindUI, lastTime)
	local curTime = i3k_game_get_time()
	local endTime = lastTime + 60
	local isCountDown = lastTime ~= 0 and endTime > curTime

	if isCountDown then
		local function update(dTime)
			bindUI.vars.codeBtnText:setText(string.format("%ss", endTime - i3k_game_get_time()))
			if endTime - i3k_game_get_time() <= 0 then
				bindUI.vars.codeBtnText:setText("获取")
				bindUI.vars.codeBtn:enableWithChildren()
				bindUI.vars.codeBtn:onClick(self, self.onGetVerifyingCode, bindUI)
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedler)
				self.schedler = nil
			end
		end
		if not self.schedler then
			self.schedler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 1, false)
		end
		bindUI.vars.codeBtnText:setText(string.format("%ss", endTime - i3k_game_get_time()))
		bindUI.vars.codeBtn:disableWithChildren()
	else
		bindUI.vars.codeBtnText:setText("获取")
		bindUI.vars.codeBtn:enableWithChildren()
		bindUI.vars.codeBtn:onClick(self, self.onGetVerifyingCode, bindUI)
	end
end

function wnd_fu_li:onGetVerifyingCode(sender, bindUI)
	if self.myBindNumber ~= "" then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1359))
	end
	local number = string.trim(self.phoneNumber)
	if number then
		if number == "" then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1360))
		else
			if string.len(number) == 11 then
				i3k_sbean.send_phone_msg(tonumber(number), bindUI)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1358))
			end
		end
	end
end

function wnd_fu_li:updateRewardBtnState(bindUI)
	local isBind = self.myBindNumber ~= ""
	if isBind then
		bindUI.vars.getBtnText:setText("已绑定")
		bindUI.vars.getBtn:disableWithChildren()
	else
		bindUI.vars.getBtnText:setText("绑定")
		bindUI.vars.getBtn:enableWithChildren()
		bindUI.vars.getBtn:onClick(self, self.onBindMobile)
	end
end

function wnd_fu_li:onBindMobile(sender, phoneNumber)
	if self.myBindNumber ~= "" then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1359))
	end
	local gifts = i3k_db_common.mobileBindReward
	local code = string.trim(self.verifyCode)
	if code then
		if code == "" then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1361))
		else
			if string.len(code) == 4 then
				i3k_sbean.take_bind_phone_reward(tonumber(code), gifts)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1362))
			end
		end
	end
end

------手机绑定end--------

---------------活跃领奖活动------START---------
function wnd_fu_li:updateScheduleGift(actType, actId, info)
	local ui = require("ui/widgets/huoyuelingjiang")()
	self:updateRightView(ui)
	self:changeContentSize(ui)
	--self:updateCommonGiftMainInfo2(ui, info.cfg.time, info.cfg.content)  --时间，活动内容
	self:excessTime(ui, info.cfg.time)
	self:updateScheduleGiftInfo(ui, actId, actType, info)
	self:setLeftRedPoint(actType, actId)
end

function wnd_fu_li:updateScheduleGiftInfo(control, actId, actType, info)
	local scheduleGiftList = control.vars.scheduleGiftList
	scheduleGiftList:removeAllChildren()
	self._scheduleGift_auto_index = 0
	for i,v in ipairs(info.cfg.levelGifts) do
		self:appendScheduleGiftItem(control, actId, actType, info, v.needSchdule, v.gifts, i)
	end
	control.vars.activePoint:setText(string.format("%s", info.log.schdule))
	if #info.cfg.levelGifts >= self._scheduleGift_auto_index then
		scheduleGiftList:jumpToChildWithIndex(self._scheduleGift_auto_index)
	end
end

function wnd_fu_li:appendScheduleGiftItem(control, actId, actType, info, needSchdule, gifts, auto_index)
	local scheduleGiftwidgets= require("ui/widgets/huoyuelingjiangt")()
	self:updateScheduleGiftItem(scheduleGiftwidgets, control, actId, actType, info, needSchdule, gifts, auto_index)
	control.vars.scheduleGiftList:addItem(scheduleGiftwidgets)
end

function wnd_fu_li:updateScheduleGiftItem(ui, control, actId, actType, info, needSchdule, gifts, auto_index)
	for k = 1, 3 do
		if gifts[k] then
			local q = gifts[k]
			ui.vars["item_bg"..k]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(q.id))
			ui.vars["item_icon"..k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(q.id), g_i3k_game_context:IsFemaleRole())
			ui.vars["item_count"..k]:setText("x"..q.count)
			ui.vars["item_suo"..k]:setVisible(q.id > 0)
			ui.vars["item_btn"..k]:onClick(self, self.onTips, q.id)
			ui.vars["item_bg"..k]:show()
		else
			ui.vars["item_bg"..k]:hide()
		end
	end

	local mySchdulePoint = info.log.schdule

	ui.vars.GoalContent:setText(string.format("%s", needSchdule))
	if mySchdulePoint < needSchdule then  --活跃点数不足
		ui.vars.GetBtn:disableWithChildren()
	else
		if info.log.rewards[needSchdule] then  --领过奖了
			ui.vars.GetImage:show()
			ui.vars.GetBtn:hide()
		else
			local callback = function ()
				ui.vars.GetImage:show()
				ui.vars.GetBtn:hide()
				g_i3k_ui_mgr:ShowGainItemInfo(gifts)
				g_i3k_game_context:SetDynamicActivityRedPointInfo(0)
				i3k_sbean.schdulegift_sync(actId, actType)
			end
			local data = {actId = actId, actType = actType, effectiveTime = info.effectiveTime, needSchdule = needSchdule, gifts = gifts, callback = callback}
			ui.vars.GetBtn:onClick(self, self.onTakeScheduleGift, data)
			g_i3k_game_context:SetDynamicActivityRedPointInfo(1)
			if self._scheduleGift_auto_index == 0 then
				self._scheduleGift_auto_index = auto_index
			end
		end
	end
end

function wnd_fu_li:onTakeScheduleGift(sender, data)
	local giftsTb = data.gifts
	local isEnoughTable = { }
	for i,v in pairs(giftsTb) do
		isEnoughTable[v.id] = v.count
	end
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	if isEnough then
		i3k_sbean.schudulegift_take(data.actId, data.actType, data.effectiveTime, data.needSchdule, data.gifts, data.callback)
	else
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
	end
end
---------------活跃领奖活动------END-----------

-----传世大酬宾Start--------
function wnd_fu_li:updataLegendmakeNotice()
	for _, v in pairs(self._activitiesList) do
		if v.atype == inheritDivinework then
			v.notice = g_i3k_game_context:getLegendmakeFlag()
			v.red_point:setVisible(v.notice == 1) 
		end
	end
end

function wnd_fu_li:updateInheritDivinework(actId, actType, info)
	local CHOUBIN = require("ui/widgets/chuanshichoubin")()
	self:updateRightView(CHOUBIN)
	self:changeContentSize(CHOUBIN)
	self:updateInheritDivineworkInfo(CHOUBIN, info.cfg)
	self:excessTime(CHOUBIN, {startTime = info.cfg.time.startTime, endTime = info.cfg.time.endTime})
	self:setLeftRedPoint(actType, actId)
	g_i3k_game_context:setLegendmakeFlag(0)
	local weight = CHOUBIN.vars
	local mcfg = i3k_db_models[2590]
	weight.model:setSprite(mcfg.path)
	weight.model:setSprSize(mcfg.uiscale)
	weight.model:playAction("stand")
end

function wnd_fu_li:updateInheritDivineworkInfo(item, cfg)
	item.vars.content:setText(cfg.content)
end
---传世大酬宾End------

-- 回归玩家双倍掉落
function wnd_fu_li:updataBackRoleDoubleDropNotice()
	for _, v in pairs(self._activitiesList) do
		if v.atype == backRoleDoubleDrop then
			v.notice = g_i3k_game_context:getBackRoleDoubleDropFlag()
			v.red_point:setVisible(v.notice == 1)
		end
	end
end
function wnd_fu_li:updateBackRoleDoubleDrop(actId, actType, cfg)
	local widget = require("ui/widgets/huiguidiaoluo")()
	self:updateRightView(widget)
	self:changeContentSize(widget)
	self:setLeftRedPoint(actType, actId)
	-- self:excessTime(widget, {startTime = cfg.time.startTime, endTime = cfg.endTime})
	widget.vars.title:setText("截止日期：")
	widget.vars.ActivitiesTime:setText(g_i3k_get_YearMonthAndDayTime(cfg.endTime))
	widget.vars.content:setText(cfg.content)
	g_i3k_game_context:setBackRoleDoubleDropFlag(0)
end
-------------------oppo--------------------------------
--oppo 充值
function wnd_fu_li:updateOppoActivity(info, log, id)
	local red = false
	local widget = require("ui/widgets/oppoflt5")()
	self:updateRightView(widget)
	self:changeContentSize(widget)
	--self:setLeftRedPoint(actType, id)
	widget.vars.coinNum:setText(log.payNum)
	local infoSort = self:sortOpenInfo(info)
	local maxNeed = 0
	for i, j in pairs(infoSort) do
		local node = require("ui/widgets/oppoflt4")()
		local count = log.payNum >= j.count and j.count or log.payNum
		maxNeed = j.count
		node.vars.coinDesc:setText(count.."/"..j.count)
		node.vars.coinPercent:setPercent((count/j.count) * 100)
		node.vars.rewareBtn:onClick(self,self.onOppoReward, {id = id, payNum = j.count, items = j.gifts} )
		if count < j.count or  log.payReward[j.count] then
			node.vars.rewareBtn:disable()
		end
		node.vars.countTitle:setText(count)
		node.vars.countTitle:setText(j.count)
		node.vars.reward:setVisible(log.payReward[j.count])
		node.vars.rewareBtn:setVisible(not log.payReward[j.count])
		if count == j.count and not log.payReward[j.count] then
			red = true
		end
		for k = 1,2 do
			local v = j.gifts[k]
			if node.vars["item_bg"..k] and v then
				node.vars["item_bg"..k]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
				node.vars["item_icon"..k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id,g_i3k_game_context:IsFemaleRole()))
				node.vars["cnt"..k]:setText("x"..v.count)
				node.vars["Btn"..k]:onClick(self,function(id) g_i3k_ui_mgr:ShowCommonItemInfo(v.id) end)
				node.vars["suo"..k]:setVisible(v.id > 0)
			elseif node.vars["item_bg"..k] then
				node.vars["item_bg"..k]:hide()
			end
		end
		widget.vars.scroll:addItem(node) 
	end
	widget.vars.title:setText(i3k_get_string(5533,maxNeed))
	self:showFuliRedPointByAtype(oppoActivity, red)
end
function wnd_fu_li:sortOpenInfo(info)
	local tableInfo = {}
	for i, j in pairs(info.payReward) do
		j.count = i
		table.insert(tableInfo, j)
	end
	table.sort(tableInfo, function(a, b) return a.count < b.count end)
	return tableInfo
end
--充值领取
function wnd_fu_li:onOppoReward(sender, data)
	local isEnough = g_i3k_game_context:checkBagCanAddCell( #data.items)
	i3k_sbean.oppo_vip_level_pay_reward_take(data.id, data.payNum, data.items)
end
---------------------oppo end--------------------------------
function wnd_create(layout)
	local wnd = wnd_fu_li.new();
	wnd:create(layout);
	return wnd;
end
