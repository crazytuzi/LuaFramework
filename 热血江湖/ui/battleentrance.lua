module(..., package.seeall)

local require = require;

local ui = require("ui/base");
local WIDGET_KJAT = "ui/widgets/kjat"
-------------------------------------------------------
wnd_battleEntrance = i3k_class("wnd_battleEntrance", ui.wnd_base)

local CanClickBtn = { --在帮派驻地中可以点击的功能
	[1]		= true,
	[2]		= true,
	[3]		= true,
	[4]		= true,
	[5]		= true,
	[6]		= true,
	[7]		= true,
	[11]	= true,
	[12]	= true,
	[14]	= true,
	[15]	= true,
}
local CanClickInSpring = { --在温泉场景可以点击的功能
	[1]		= true,
	[2]		= true,
	[3]		= true,
	[4]		= true,
	[5]		= true,
	[6]		= true,
	[7]		= true,
}
local CanClickInGlodCoast = { --在黄金海岸可以点击的功能
	[1]		= true,
	[2]		= true,
	[3]		= true,
	[4]		= true,
	[5]		= true,
	[6]		= true,
	[8]		= true,
	[12]	= true,
	[13]	= true,
	[14]	= true,
	[15]	= true,
}

function wnd_battleEntrance:ctor()
	self._curState = true
	self._curshouchongState = true
	self._canShow = true
	self._stop = true
	self.select_btn = {}
	self.btn_position = {}

	self.entranceTbl = {}
	self._timeCounter = 0
	self._newTimeCounter = 0
end

function wnd_battleEntrance:configure()
	self.entranceTbl =
	{
	   	[1] = { test = g_i3k_game_context.TestNilShowState,      icon = true, red = true, isFull = false, path = i3k_db_icons[2396].path, func = nil },        --空图片
		[2] = { test = g_i3k_game_context.TestBagShowState,      icon = true, red = true, isFull = false, path = i3k_db_icons[2632].path, func = self.onBag }, --背包
		[3] = { test = g_i3k_game_context.TestStoreShowState,    icon = true, red = true, isFull = false, path = i3k_db_icons[2637].path, func = self.onStore },  --商城
		[4] = { test = g_i3k_game_context.TestEmailShowState,    icon = true, red = true, isFull = false, path = i3k_db_icons[2634].path, func = self.ToEmail }, --邮件
		[5] = { test = g_i3k_game_context.TestFuLiShowState,     icon = true, red = true, isFull = false, path = i3k_db_icons[2636].path, func = self.onFuLi },  --福利
		[6] = { test = g_i3k_game_context.TestFirstPayShowState, icon = true, red = true, isFull = false, path = i3k_db_icons[2633].path, func = self.OnFirstPayGift}, --首冲
		[7] = { test = g_i3k_game_context.TestPayShowState, 	 icon = true, red = true, isFull = false, path = i3k_db_icons[2868].path, func = self.OnPayGift}, --充值入口
		--[8] = { test = g_i3k_game_context.TestFengCeShowState,   icon = true, red = true, isFull = false, path = i3k_db_icons[2638].path, func = self.onFengce },  --封测
		[9] = { test = g_i3k_game_context.TestScheduleShowState, icon = true, red = true, isFull = false, path = i3k_db_icons[2631].path, func = self.onSchedule }, --活动
		[10] = { test = g_i3k_game_context.TestStrengthenSelfShowState, icon = true, red = true, isFull = false, path = i3k_db_icons[2813].path, func = self.OnStrengthenSelf}, --我要变强
		[11] = { test = g_i3k_game_context.TestKeJuShowState,     icon = true, red = true, isFull = false, path = i3k_db_icons[8336].path, func = self.onXingJun }, --科举
		[12] = { test = g_i3k_game_context.TestGroupBuyState,     icon = true, red = true, isFull = false, path = i3k_db_icons[3318].path, func = self.onGroupBuy }, --限时团购
		-- [13] = { test = g_i3k_game_context.TestRewardTestState,     icon = true, red = true, isFull = false, path = i3k_db_icons[3259].path, func = self.onRewardTest }, -- 有奖调研
		[13] = { test = g_i3k_game_context.TestFlashSaleState,     icon = true, red = true, isFull = false, path = i3k_db_icons[3317].path, func = self.onFlashSale }, --限时特卖
		[14] = { test = g_i3k_game_context.TestDiscountBuyPowerState,  icon = true, red = false, isFull = false, path = i3k_db_icons[7179].path, func = self.onDiscountBuyPower }, --充值获得折扣礼包购买权
		[15] = { test = g_i3k_game_context.TestGoodLuckState,     icon = true, red = true, isFull = false, path = i3k_db_icons[3418].path, func = self.onluck }, --大转盘
		[16] = { test = g_i3k_game_context.TestFightNpcState,     icon = true, red = true, isFull = false, path = i3k_db_icons[3455].path, func = self.onFight }, --约战npc
		[17] = { test = g_i3k_game_context.testFactionFightState,  icon = true, red = true, isFull = false, path = i3k_db_icons[4026].path, func = self.onFactionFight },
		[18] = { test = g_i3k_game_context.fiveEndActivityState,  icon = true, red = true, isFull = false, path = i3k_db_icons[4132].path, func = self.onOpenFiveEnd },
		-- [19] = { test = g_i3k_game_context.testRoleReturnState,	icon = true, red = true, isFull = false, path = i3k_db_icons[4188].path, func = self.onRoleReturn }, --老玩家回归
		[20] = { test = g_i3k_game_context.testReturnFuli, icon = true, red = true, isFull = false, path = i3k_db_icons[4195].path, func = self.onReturnFuli }, --回归福利
		[21] = { test = g_i3k_game_context.TestGoldenEggState,     icon = true, red = true, isFull = false, path = i3k_db_icons[4296].path, func = self.onOpenGoldenEgg }, --砸金蛋
		[22] = { test = g_i3k_game_context.testGameEntranceState,     icon = true, red = true, isFull = false, path = i3k_db_icons[4742].path, func = self.onOpenGameEntranceUI }, -- 假期节日游戏入口
		[23] = { test = g_i3k_game_context.testCallBackState,     icon = true, red = true, isFull = false, path = i3k_db_icons[4987].path, func = self.onOpenCallBackUI }, -- 江湖回归
		[24] = { test = g_i3k_game_context.testActivityShow,      icon = true, red = true, isFull = false, path = i3k_db_icons[8681].path, func = self.onOpenActivityShow }, --节日活动公告
		[25] = { test = g_i3k_game_context.TestLuckyPackState,     icon = true, red = true, isFull = false, path = i3k_db_icons[5642].path, func = self.onLuckyPack }, --新春福袋
		[26] = { test = g_i3k_game_context.TestDengmi,     icon = true, red = true, isFull = false, path = i3k_db_icons[7442].path, func = self.onDengmi }, --灯谜
		--[27] = { test = g_i3k_game_context.TestMillionsAnswer,     icon = true, red = true, isFull = false, path = i3k_db_icons[5956].path, func = self.onMillionsAnswer }, --百万答题
		[29] = { test = g_i3k_game_context.TestRoleFestival,     icon = true, red = true, isFull = false, path = i3k_db_icons[6412].path, func = self.onRoleFestivalInfo}, -- 世界祝福
		[30] = { test = g_i3k_game_context.TestWorldCupShowState,		icon= true, red =  false, isFull =false, path= i3k_db_icons[6751].path, func= self.onWorldCupClick},--世界杯竞猜 TODO
		[31] = { test = g_i3k_game_context.TestDefenceWarShowState,		icon= true, red =  false, isFull =false, path= i3k_db_icons[7359].path, func= self.onDefenceWarClick},--城战入口
		[32] = { test = g_i3k_game_context.testGameTimingActivityState, icon= true, red =  false, isFull =false, path= i3k_db_icons[9662].path, func= self.onTimingActivityClick},--定时活动入口
		[33] = { test = g_i3k_game_context.TestJubileeActivityState, icon= true, red =  false, isFull =false, path= i3k_db_icons[8547].path, func= self.onJubileeActivityClick},--周年庆活动入口
		[34] = { test = g_i3k_game_context.TestOppoActivityState, icon= true, red =  false, isFull =false, path= i3k_db_icons[8875].path, func= self.onOppoActivityClick},--oppo 活动入口
		[35] = { test = g_i3k_game_context.TestGoodLuckStateNew, icon = true, red = false, isFull = false, path = i3k_db_icons[9566].path, func = self.onlucknew},-- 新转盘抽奖
		[37] = { test = g_i3k_game_context.TestSpringRoll, icon = true, red = false, isFull = false, path = i3k_db_icons[10596].path, func = self.onSpringRoll}, -- 春节灯券
	}
	local widgets = self._layout.vars
	self.show_red_point = widgets.show_red_point

	widgets.keepGift:onClick(self, self.onKeepGift)
	self.scroll = widgets.scroll
	self.keepRoot = widgets.keepRoot
	self.keepIcon = widgets.keepIcon
	self.keepDesc = widgets.keepDesc
	self.keepRed = widgets.keepRed

	self.closeBtn = self._layout.vars.close_btn
	self.closeBtn:onClick(self, self.onCloseBtn)
	self.closeBtn:show()
	self.openBtn = self._layout.vars.open_btn
	self.openBtn:onClick(self, self.onOpenBtn)
	self.openBtn:hide()

	self.PreViewUI = widgets.PreViewUI
	--self:JudgeIconIsHide()
end

function  wnd_battleEntrance:RefreshItem(id, icon, red, isFull)
	if not self.entranceTbl[id] then
		return
	end
	if self.entranceTbl[id].red ~= red or self.entranceTbl[id].icon ~= icon or ( isFull ~= nil and self.entranceTbl[id].isFull ~= isFull ) then
		local tmp_red = {}
		local red_count_tbl = {}
		for k, v in pairs(self.entranceTbl) do
			if k == id then
				v.red = red
				v.icon = icon
				v.isFull = isFull
			end
			if v.red then
				table.insert(red_count_tbl,k)
			end
			if v.icon then
				table.insert(tmp_red, k);
			end
		end
		self:createScrollItems(#tmp_red)
		self:setItem(tmp_red)
		self:SetHideRedPoint(red_count_tbl)
	end
end

function wnd_battleEntrance:RefreshAllItem()
	local tmp = {}
	local red_count_tbl = {}
	for k, v in pairs(self.entranceTbl) do
		v.icon, v.red, v.isFull = v.test(g_i3k_game_context)
		if v.red then
			table.insert(red_count_tbl, k)
		end
		if v.icon then
			table.insert(tmp, k);
		end
	end
	self:createScrollItems(#tmp)
	self:setItem(tmp)
	self:SetHideRedPoint(red_count_tbl)
end

function wnd_battleEntrance:createScrollItems(totalItemCnt)
	self.scroll:setAlignMode(g_UIScrollList_HORZ_ALIGN_RIGHT)
	self.scroll:addChildWithCount(WIDGET_KJAT, g_UIScrollList_HORZ_ALIGN_RIGHT, totalItemCnt)
end

function wnd_battleEntrance:setItem(tbl)
	-- 排序，需要让第一个为一个空的图标
	table.sort(tbl, function(a, b)
		return a < b
	end)
	for i, v in ipairs(tbl) do
		local item = self.scroll:getChildAtIndex(i).vars
		item.click_btn:setImage(self.entranceTbl[v].path, "")
		if not (g_i3k_game_context:GetNotEnterTips() or g_i3k_game_context:GetNotEnterMapIdTips()) then
			item.click_btn:onClick(self, self.entranceTbl[v].func)
		else
			if g_i3k_game_context:GetIsSpringWorld() then
				if CanClickInSpring[v] then
					item.click_btn:onClick(self, self.entranceTbl[v].func)
				else
					item.click_btn:onClick(self, self.onFactionZoneTips)
				end
			elseif g_i3k_game_context:GetIsGlodCoast() then
				if CanClickInGlodCoast[v] then
					item.click_btn:onClick(self, self.entranceTbl[v].func)
				else
					item.click_btn:onClick(self, self.onFactionZoneTips)
				end
			else
				if CanClickBtn[v] then
					item.click_btn:onClick(self, self.entranceTbl[v].func)
				else
					item.click_btn:onClick(self, self.onFactionZoneTips)
				end
			end
		end
		item.red_point:setVisible(self.entranceTbl[v].red)
		item.isFull:setVisible(self.entranceTbl[v].isFull)
	end
end

function wnd_battleEntrance:onCloseBtn(sender)
	self.closeBtn:hide()
	local scroll_pos = self.scroll:getPosition()
	local move = cc.MoveTo:create(0.2, cc.p(scroll_pos.x,scroll_pos.y + 200))
	local seq =	cc.Sequence:create(move, cc.CallFunc:create(function ()
		self.openBtn:show()
	end))
	self.scroll:runAction(seq)
	g_i3k_game_context:SetIconIsHide(true)
end

function wnd_battleEntrance:onOpenBtn(sender)
	-- if self.scroll:isVisible() == false then
	-- 	self.scroll:show()
	-- end
	self.openBtn:hide()
	local scroll_pos = self.scroll:getPosition()
	local move = cc.MoveTo:create(0.2, cc.p(scroll_pos.x,scroll_pos.y - 200))
	local seq =	cc.Sequence:create(move, cc.CallFunc:create(function ()
			self.closeBtn:show()
	end))
	self.scroll:runAction(seq)
	g_i3k_game_context:SetIconIsHide(false)
end

function wnd_battleEntrance:refresh()
	self:RefreshAllItem()
	self:onUpdatePreview()
	self:updateKeepUI()
	self:hideWidgetRoot()
	--因为刚进界面会有1s的延迟,所以在这里调一下
	self:UpdateState()
	--self:updateScheduleRedCallBack()
end

function wnd_battleEntrance:JudgeIconIsHide()
	local iconIsHide = g_i3k_game_context:GetIconIsHide()
	if iconIsHide then
		--self.scroll:hide()
		local scroll_pos = self.scroll:getPosition()
		local move = cc.MoveTo:create(0.0000001, cc.p(scroll_pos.x,scroll_pos.y + 200))
		self.scroll:runAction(move)
		--self.scroll:setPosition(scroll_pos.x,scroll_pos.y+200)
		self.closeBtn:hide()
		self.openBtn:show()
	end
end

function wnd_battleEntrance:SetHideRedPoint(tbl)
	if  next(tbl) == nil then
		self.show_red_point:hide()
	else
		self.show_red_point:show()
	end
end



function wnd_battleEntrance:updateScheduleRedCallBack()
	g_i3k_game_context:OnScheduleTimerTest()
end

function wnd_battleEntrance:onXingJun(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_XingJun)
	g_i3k_ui_mgr:RefreshUI(eUIID_XingJun)
end

function wnd_battleEntrance:onRewardTest(sender)
	-- g_i3k_logic:OpenRewardTestUI()
	i3k_sbean.sync_survey()
end

function wnd_battleEntrance:onGroupBuy(sender)
	i3k_sbean.groupbuy_sync(1)
end

function wnd_battleEntrance:onFlashSale(sender)
	i3k_sbean.flashsale_sync(1)
end

function wnd_battleEntrance:onluck(sender)
	i3k_sbean.sync_activities_luckywheel()--幸运转盘
end
function wnd_battleEntrance:onlucknew(sender)
	i3k_sbean.newluckyroll_sync()--新幸运转盘
end
function wnd_battleEntrance:onSpringRoll(sender)
	g_i3k_ui_mgr:OpenAndRefresh(eUIID_SpringRollTips)
end

function wnd_battleEntrance:OnFirstPayGift(sender)    -- 首冲
	-- g_i3k_game_context:SetIsOpenFirstPayUI(true)
	-- g_i3k_logic:OpenDynamicActivityUI()
	g_i3k_logic:OpenPayActivityUI()  -- 充值跳转到充值活动里，与onPayActivity逻辑相同
end

function wnd_battleEntrance:OnPayGift(sender)         -- 充值
	--  g_i3k_logic:OpenChannelPayUI()
	g_i3k_logic:OpenPayActivityUI()  -- 充值跳转到充值活动里，与onPayActivity逻辑相同
end

function wnd_battleEntrance:onStore(sender)
	g_i3k_logic:OpenVipStoreUI()
end

function wnd_battleEntrance:onFuLi(sender)
	g_i3k_logic:OpenDynamicActivityUI()
end


function wnd_battleEntrance:ToEmail(sender)
	local call = function(sectUnreadCount)
	local syncSys = i3k_sbean.mail_syncsys_req.new()
	syncSys.pageNO = 1
		syncSys.sectUnreadCount = sectUnreadCount
		syncSys.callback = function (sysUnreadCount, sectUnreadCount)
		local syncTemp = i3k_sbean.mail_synctmp_req.new()
		syncTemp.pageNO = 1
		syncTemp.notSetData = true
		syncTemp.sysUnreadCount = sysUnreadCount
			syncTemp.sectUnreadCount = sectUnreadCount
		i3k_game_send_str_cmd(syncTemp, "mail_synctmp_res")
	end
	i3k_game_send_str_cmd(syncSys, "mail_syncsys_res")
	end
	i3k_sbean.mail_syncsect(1, call)
	g_i3k_game_context:ClearNotice(g_NOTICE_TYPE_CAN_RECEIVE_NEW_MAIL)
end

function wnd_battleEntrance:onBag(sender)
	if i3k_db.i3k_db_get_is_bag_auto_sale_tips() then
		local desc = i3k_get_string(18713)
		local callback = function (isOk)
			if isOk then
				local cfg = g_i3k_game_context:GetUserCfg()
				cfg:SetAutoSaleEquip(true)
				i3k_sbean.syncAutoSaleEquip(true)
			end
	g_i3k_logic:OpenBagUI()
			g_i3k_ui_mgr:CloseUI(eUIID_MessageBox5)
		end
		local callbackRadioButton = function (randioButton,yesButton,noButton)
			if randioButton then
				g_i3k_game_context:setBagAutoSaleEquipTips(true)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox5(desc, i3k_get_string(18714),callback, callbackRadioButton)
	else
		g_i3k_logic:OpenBagUI()
	end
end

function wnd_battleEntrance:updateBagRedPoint()
	local iconShow, redShow = g_i3k_game_context:TestBagShowState()
	g_i3k_game_context:OnBagShowStateChangedHandler(iconShow, redShow)
end

function wnd_battleEntrance:updateRedPoint()
	local iconShow, redShow = g_i3k_game_context:TestEmailShowState()
	g_i3k_game_context:OnEmailShowStateChangedHandler(iconShow, redShow)
	local curtime = math.modf(i3k_game_get_time())
	local pushTime = g_i3k_get_day_time(i3k_db_answer_questions_activity.startTime) - i3k_db_answer_questions_activity.pushTime --����ʱ��
	local openTime = g_i3k_get_day_time(i3k_db_answer_questions_activity.startTime)
	local time = i3k_db_answer_questions_activity.itemCount * i3k_db_answer_questions_activity.limitTime + openTime
	local showTime = time + i3k_db_answer_questions_activity.showTime

	if g_i3k_game_context:GetNoticeState(g_NOTICE_TYPE_CAN_REWARD_FIRST_PAYGIFT ) then
	else
		self._curshouchongState = false
	end
end



function wnd_battleEntrance:UpdateState(dTime)--每秒检测一次


	if self._curshouchongState then
		self:updateRedPoint()
		self._curshouchongState = false
	end
	self:checkFactionFight(dTime)
	self:checkXingJun(dTime)
	self:checkMillionsAnswerTips(dTime)
	self:checkTimingActivity(dTime)
	self:checkJubileeActivity(dTime)
end

function wnd_battleEntrance:checkFactionFight(dTime)
	g_i3k_game_context:checkFactionFightState(dTime)
end
-------定时活动------------
function wnd_battleEntrance:checkTimingActivity(dTime)
	g_i3k_game_context:checkTimingActivity(dTime)
end
function wnd_battleEntrance:checkXingJun(dTime)
	g_i3k_game_context:checkAnswerState(dTime)
end

function wnd_battleEntrance:checkMillionsAnswerTips(dTime)
	g_i3k_game_context:checkMillionsAnswerTipsState(dTime)
end
function wnd_battleEntrance:checkJubileeActivity(dTime)
	g_i3k_game_context:checkJubileeActivityState()
end

function wnd_battleEntrance:onUpdate(dTime)
	self._timeCounter = self._timeCounter + dTime
	self._newTimeCounter = self._newTimeCounter + dTime
	if self._timeCounter > 1 then
		self:checkFactionFight(dTime)
		self._timeCounter = 0
	end

	if self._newTimeCounter > 60 then
		self:RefreshAllItem()
		self._newTimeCounter = 0
	end
end

function wnd_battleEntrance:onUpdatePreview()
	local widgets = self._layout.vars
	local id = g_i3k_game_context:getFuncPreviewId()
	local isShow = true
	if id == 0 then
		isShow = g_i3k_game_context:LeadCheckTri(1,args,3)
	end
	if isShow then
		local info = i3k_db_preView_cfg[id]
		if info then
			widgets.PreViewUI:show()
			widgets.PreIcon:setImage(g_i3k_db.i3k_db_get_icon_path(info.btnIconId))
			widgets.preLabel1:setText(info.btnTitle1)
			widgets.preLabel2:setText(info.btnTitle2)
			widgets.Prebtn:onClick(self,self.showView,info)
		end
	else
		widgets.PreViewUI:hide()
	end
	if self:getIsShowRoot() then --refresh 后其他地方还有调用，隐藏写到这里
		self.PreViewUI:hide()
	end
end

function wnd_battleEntrance:IsShowPreViewUI(isShow)
	self.PreViewUI:setVisible(isShow)
end

function wnd_battleEntrance:showView(sender,info)
	if info.showUItype == 1 then--大
		g_i3k_ui_mgr:OpenUI(eUIID_PreviewDetailone)
		g_i3k_ui_mgr:RefreshUI(eUIID_PreviewDetailone,info)
	elseif info.showUItype == 2 then--小
		g_i3k_ui_mgr:OpenUI(eUIID_PreviewDetailtwo)
		g_i3k_ui_mgr:RefreshUI(eUIID_PreviewDetailtwo,info)
	end
end

function wnd_battleEntrance:updateFengce(isShow)
	local hero = i3k_game_get_player_hero()
	if isShow and g_i3k_game_context:getIsFirstLogin() and hero._lvl>=i3k_db_fengce.baseData.needLvl then
		g_i3k_ui_mgr:OpenUI(eUIID_Fengce)
		g_i3k_ui_mgr:RefreshUI(eUIID_Fengce, g_i3k_game_context:getFengceRedCache())
	end
end

function wnd_battleEntrance:onFengce(sender)
	local hero = i3k_game_get_player_hero()
	if hero._lvl<i3k_db_fengce.baseData.needLvl then
		g_i3k_ui_mgr:PopupTipMessage(string.format("封测活动需要达到%d级才能进行", i3k_db_fengce.baseData.needLvl))
	else
		g_i3k_ui_mgr:OpenUI(eUIID_Fengce)
		g_i3k_ui_mgr:RefreshUI(eUIID_Fengce, g_i3k_game_context:getFengceRedCache())
	end
end

function wnd_battleEntrance:onKeepGift(sender)
	local isShow = g_i3k_game_context:isShowLoginReward()
		g_i3k_ui_mgr:OpenUI(eUIID_KeepActivity)
	g_i3k_ui_mgr:RefreshUI(eUIID_KeepActivity, isShow)
end

function wnd_battleEntrance:updateKeepUI()
	local pos = g_i3k_game_context:GetKeepActivityPos()
	local roleType = g_i3k_game_context:GetRoleType()
	local heirloom = g_i3k_game_context:getHeirloomData()
	if pos >= i3k_db_chuanjiabao.cfg.activityID and heirloom.isOpen ~= 1 then
		pos = i3k_db_chuanjiabao.cfg.activityID -1
	end
	--如果登录送大礼活动还在
	local isShowLoginRed = false
		self.keepRoot:show()
		local cfg = i3k_db_seven_keep_activity[pos+1]
	if cfg then
		local desc = cfg.type == 1 and string.format("达到%d%s" ,cfg.args,"级") or string.format("登入%d%s",cfg.args,"天")
		self.keepIcon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.entranceIcon[roleType]))
		self.keepDesc:setText(cfg.name)
		local condition = cfg.type == 1 and g_i3k_game_context:GetLevel() >= cfg.args or g_i3k_game_context:GetLoginDays() >= cfg.args
		if pos + 1 == i3k_db_chuanjiabao.cfg.activityID then
			if g_i3k_game_context:GetLevel() >= cfg.args and  i3k_db_chuanjiabao.cfg.haveTimes > heirloom.dayWipeTimes  or ( heirloom.isOpen ~= 1 and  heirloom.perfectDegree == i3k_db_chuanjiabao.cfg.topcount)  then
				condition = true
			else
				condition = false
			end
		end
		isShowLoginRed = condition
	else
		self.keepIcon:setImage(g_i3k_db.i3k_db_get_icon_path(7917))
		self.keepDesc:setText("限时宝箱")
	end
	self.keepRed:setVisible(isShowLoginRed or g_i3k_game_context:isShowWeekLimitBoxRed())
	if self:getIsShowRoot() then
		self.keepRoot:hide()
	end
end

-- 家园默认隐藏留存活动 默认关闭scroll
function wnd_battleEntrance:hideWidgetRoot()
	if self:getIsShowRoot() then
		self.keepRoot:hide()
		self:onCloseBtn()
	end
end

function wnd_battleEntrance:getIsShowRoot()
	local hideMap = { --可后续添加，亦可改为策划配置
		[g_HOME_LAND]		= true,
	}
	local mapType = i3k_game_get_map_type()
	if mapType and hideMap[mapType] then
		return true
	end
	return false
end

function wnd_battleEntrance:onSchedule(sender)
	local heroLvl = g_i3k_game_context:GetLevel()
	if heroLvl < i3k_db_common.schedule.openLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(630,i3k_db_common.schedule.openLvl))
	else
		local callback = function ()
			g_i3k_ui_mgr:OpenUI(eUIID_Schedule)
			g_i3k_ui_mgr:RefreshUI(eUIID_Schedule)
		end
		i3k_sbean.bottle_exchange_sync(callback)
	end
end

function wnd_battleEntrance:OnStrengthenSelf(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_StrengthenSelf)
end

function wnd_battleEntrance:onFight(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_FightNpc)
	g_i3k_ui_mgr:RefreshUI(eUIID_FightNpc)
end

function wnd_battleEntrance:onFactionFight(sender)
	local role_lvl = g_i3k_game_context:GetLevel()
	if role_lvl < i3k_db_faction_fightgroup.common.joinLevel then
		g_i3k_ui_mgr:PopupTipMessage("等级不足,不可参与帮派战")
	else
		g_i3k_logic:OpenFactionFightStateUI()
	end
end

function wnd_battleEntrance:onOpenFiveEnd()
	i3k_sbean.five_goals_syncReq()
	g_i3k_game_context:ClearNotice(g_NOTICE_TYPE_FIVE_END_ACT)
end

function wnd_battleEntrance:onRoleReturn()
	i3k_sbean.sync_regression(function()
		g_i3k_ui_mgr:OpenUI(eUIID_RoleReturn)
		g_i3k_ui_mgr:RefreshUI(eUIID_RoleReturn)
	end)
end

function wnd_battleEntrance:onReturnFuli()
	i3k_sbean.sync_regression(function()
		g_i3k_ui_mgr:OpenUI(eUIID_RoleReturnActivity)
		g_i3k_ui_mgr:RefreshUI(eUIID_RoleReturnActivity)
	end)
end

function wnd_battleEntrance:onOpenGoldenEgg()
	--打开砸金蛋界面
	i3k_sbean.activities_goldenEgg()
	--g_i3k_ui_mgr:PopupTipMessage("打开砸金蛋介面")
end

function wnd_battleEntrance:onOpenGameEntranceUI(btn)
	g_i3k_ui_mgr:OpenUI(eUIID_GameEntrance)
	g_i3k_ui_mgr:RefreshUI(eUIID_GameEntrance, btn)
end

function wnd_battleEntrance:onFactionZoneTips(sender)
	local tips = g_i3k_game_context:GetNotEnterTips() or g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		g_i3k_ui_mgr:PopupTipMessage(tips)
	end
end

function wnd_battleEntrance:onOpenCallBackUI()
	g_i3k_logic:OpenCallBack();
end

function wnd_battleEntrance:onOpenActivityShow()
	g_i3k_logic:checkAndOpenActivityShowUI()
	self:RefreshAllItem()
end

function wnd_battleEntrance:onLuckyPack()
	g_i3k_logic:OpenLuckyPack()
end

function wnd_battleEntrance:onDengmi()
	i3k_sbean.request_light_secret_sync_req()
end



function wnd_battleEntrance:onRoleFestivalInfo(sender)
	g_i3k_logic:OpenMyFriendsUI()


end

function wnd_battleEntrance:onWorldCupClick()
	i3k_sbean.world_cup_inquiry()
end

function wnd_battleEntrance:onDefenceWarClick()
	g_i3k_logic:OpenDefenceWarUI()
end
--定期活动

function wnd_battleEntrance:onTimingActivityClick()
	g_i3k_logic:OpenTimingActivity()
end
function wnd_battleEntrance:onJubileeActivityClick()
	i3k_sbean.jubilee_activity_process_sync()
end
-- oppo活动
function wnd_battleEntrance:onOppoActivityClick()
	local activityId = g_i3k_game_context:GetOppoActivityId()
	i3k_sbean.oppo_vip_reward_sync(activityId, g_OPPO_OPEN_STATE)
end

--折扣礼包购买权
function wnd_battleEntrance:onDiscountBuyPower()
	i3k_sbean.discount_buy_power_sync()
end
--end
-------------------------------------
function wnd_create(layout)
	local wnd = wnd_battleEntrance.new();
		wnd:create(layout);
	return wnd;
end
