-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_lucky_wheel = i3k_class("wnd_lucky_wheel", ui.wnd_base)

local allTypeLevelTbl = nil
local rewardID  = 0
local luckyDrawNum = i3k_db_common.luckyDrawNum
local numTb = {"一","二","三","四","五","六","七","八","九","十"}

function wnd_lucky_wheel:ctor()
	self._luckyWheel  = i3k_db_lucky_wheel
	self.select_btn = {}
	self.select_bg = {}
	self.select_content = {}
	self._vipfreeTimes = 0
	self._freeTimes = 0
end
function wnd_lucky_wheel:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_lucky_wheel:refresh(info)
	self.info = info
	self._layout.vars.wheel_index:setRotation(0)
	---判断当前等级是否满足 参与等级
	self:updateLuckyWheelMainInfo(info)
end

function wnd_lucky_wheel:updateLuckyWheelMainInfo(info)
	local widgets = self._layout.vars
	for i=1,8 do
		local item = info.cfg.gifts[i]
		local temp_select_bg = "item_bg"..i
		local temp_select_content = "item_icon"..i
		local temp_select_btn = "Btn"..i
		widgets[temp_select_content]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(item.gift.id,i3k_game_context:IsFemaleRole()))
		widgets[temp_select_bg]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item.gift.id) )
		widgets[temp_select_btn]:onClick(self, self.onTips,item.gift.id)--选项
		local str = string.format("X%d",item.gift.count)
		widgets["cnt"..i]:setText(str )
	end
	widgets.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(info.cfg.giftex.id,i3k_game_context:IsFemaleRole()))
	widgets.iconbg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(info.cfg.giftex.id) )
	widgets.btn:onClick(self, self.onTips,info.cfg.giftex.id)--选项

	widgets.listScroll:removeAllChildren()
	for i,v in ipairs(info.logs) do
		local item = require("ui/widgets/xyzpt")()
		widgets.listScroll:addItem(item)
		local tmp = info.cfg.gifts[v.id].gift
		item.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(tmp.id,i3k_game_context:IsFemaleRole()))
		item.vars.iconbg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(tmp.id) )
		local str = string.format("X%d",tmp.count)
		item.vars.cnt:setText(str )
		item.vars.dwa:setText(i3k_get_string(3026,v.name,g_i3k_db.i3k_db_get_common_item_name(tmp.id)))
	end
	widgets.listScroll:jumpToChildWithIndex(#info.logs)
	local str = string.format("X%d",info.cfg.giftex.count)
	local str1 = string.format("X%d",info.cfg.price.count)
	widgets.count:setText(str )
	widgets.price:setText( str1 )
	widgets.startGame:enableWithChildren()
	widgets.startGame:onClick(self, self.selectStart,info)
	widgets.buyBtn:onClick(self, self.toJumpPay, info.cfg.price.id)
	widgets.start:show()
	widgets.start:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(info.cfg.price.id, g_i3k_game_context:IsFemaleRole()))
	widgets.suo:setVisible(info.cfg.price.id > 0)
	self.diamond = widgets.diamond
	self.diamondLock = widgets.diamondLock
	self.root = widgets.root
	widgets.add_diamond:onClick(self, self.toBuyTime)

	self.coin = widgets.coin
	self.coinLock = widgets.coinLock
	self.root = widgets.root
	widgets.add_coin:onClick(self, self.addCoinBtn)

	widgets.des:setText(info.cfg.content)
	self._layout.vars.btn2_text:setText(string.format("%s连抽", self:toCharacterNum(luckyDrawNum)))
	widgets.btn_2:onClick(self, self.nLuckyDraw,info)

	self:updateCurMoney()
end

function wnd_lucky_wheel:updateCurMoney()
	self:updateMoney(g_i3k_game_context:GetDiamond(true), g_i3k_game_context:GetDiamond(false))
	self:updateMoney2(g_i3k_game_context:GetMoney(true), g_i3k_game_context:GetMoney(false))
end

function wnd_lucky_wheel:updateMoney(diamondF, diamondR)
	self.diamond:setText(diamondF)
	self.diamondLock:setText(diamondR)
end

function wnd_lucky_wheel:updateMoney2(coinF, coinR)
	self.coin:setText(i3k_get_num_to_show(coinF))
	self.coinLock:setText(i3k_get_num_to_show(coinR))
end

function wnd_lucky_wheel:addCoinBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_BuyCoin)
end

--活动结束 显示奖励
function wnd_lucky_wheel:updateLuckyWheelFinishInfo(index)
	--动画转完结束自动弹出奖励面板
	local gifts = {}
	table.insert(gifts,self.info.cfg.gifts[index].gift)
	table.insert(gifts,self.info.cfg.giftex)
	g_i3k_ui_mgr:ShowGainItemInfo(gifts,
		function()
			i3k_sbean.sync_activities_luckywheel()
		end
	)
end
function wnd_lucky_wheel:setRotateTo(seq)

	--旋转 传过来几 就转到第几个礼物
	local angle = 180*seq/4-22.5
	local btn = self._layout.vars.wheel_index
	local callbackFunc = function ()
		self:updateLuckyWheelFinishInfo(seq)
	end
	local rotate = btn:createRotateBy(5, 360*8+angle)
	local easeInOut = btn:createEaseInOut(rotate, 2)--大于2是匀加再匀减
	local seq1 =  btn:createSequence(easeInOut, cc.CallFunc:create(callbackFunc))
	btn:runAction(seq1)
end

--开始按钮
function wnd_lucky_wheel:selectStart(sender,info)
	if g_i3k_game_context:GetCommonItemCanUseCount(info.cfg.price.id) < info.cfg.price.count then
		g_i3k_ui_mgr:PopupTipMessage("道具数量不足")
		return
	end
	if info.dayPlayTimes >= info.cfg.dayMaxPlayTimes then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15392, info.cfg.dayMaxPlayTimes))
		return
	end
	if g_i3k_game_context:GetLevel() < info.cfg.levelReq then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(220, info.cfg.levelReq))
		return
	end
	--选中
	self._layout.vars.startGame:disableWithChildren()
	i3k_sbean.activities_luckywheel_take(info.effectiveTime,info.cfg.id,info.cfg.price)
end

--N连抽
function wnd_lucky_wheel:nLuckyDraw(sender,info)
	local num = luckyDrawNum  --连抽次数
	local dayPlayTimes = info.dayPlayTimes  --每日已抽奖次数
	local dayMaxPlayTimes = info.cfg.dayMaxPlayTimes  --每日总抽奖次数

	if dayPlayTimes >= dayMaxPlayTimes then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15392, dayMaxPlayTimes))
		return
	else
		if dayPlayTimes + num > dayMaxPlayTimes then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15481))
			return
		end
	end
	if g_i3k_game_context:GetLevel() < info.cfg.levelReq then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(220, info.cfg.levelReq))
		return
	end

	local needCnt = num*info.cfg.price.count  --消耗道具数
	local cost = {id = info.cfg.price.id, count = needCnt}

	if g_i3k_game_context:IsExcNeedShowTip(g_LUCKY_WHELL_TYPE) then
		local str = g_i3k_db.i3k_db_get_common_item_name(info.cfg.price.id)
		local tipsContent = i3k_get_string(15482, needCnt .. str, num)
		local tbl = {effectiveTime = info.effectiveTime, id = info.cfg.id, cost = cost}
		g_i3k_ui_mgr:OpenUI(eUIID_Today_Tip)
		g_i3k_ui_mgr:RefreshUI(eUIID_Today_Tip, g_LUCKY_WHELL_TYPE, tbl)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Today_Tip, "setTipsContent", tipsContent)
	else
		if g_i3k_game_context:GetCommonItemCanUseCount(info.cfg.price.id) < needCnt then
			g_i3k_ui_mgr:PopupTipMessage("道具数量不足")
			return
		end
		i3k_sbean.activities_mul_luckywheel_take(info.effectiveTime, info.cfg.id, cost)  --连抽
	end
end

--N连抽奖励
function wnd_lucky_wheel:popLuckyDrawGifts(gifts)
	if gifts then
		g_i3k_ui_mgr:ShowGainItemInfo(gifts,
			function()
				i3k_sbean.sync_activities_luckywheel()
			end
		)
	end
end

function wnd_lucky_wheel:setStartState()
	self._layout.vars.start:hide()
end
--购买次数 不需要考虑剩余次数
function wnd_lucky_wheel:toBuyTime(sender)
	i3k_sbean.sync_channel_pay()
end

function wnd_lucky_wheel:toJumpPay(sender, id)
	if math.abs(id) == g_BASE_ITEM_DRAGON_COIN then
		--g_i3k_logic:OpenPayActivityUI(4)
		g_i3k_logic:OpenChannelPayUI() 
	else
		i3k_sbean.sync_channel_pay()
	end
end

function wnd_lucky_wheel:onTips(sender,itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

--仅限转换小于100的数
function wnd_lucky_wheel:toCharacterNum(num)
	if num >= 1 and num <= 10 then
		return numTb[num]
	elseif num > 10 then
		local unit = num % 10
		local decade = (num - unit)/10
		local a = ""  --个位
		local b = ""  --十位
		if unit ~= 0 then
			a = numTb[unit]
		end
		if decade == 1 then
			b = numTb[10]
		else
			b = string.format("%s%s", numTb[decade], numTb[10])
		end
		return string.format("%s%s", b , a)
	elseif num < 1 then
		return numTb[1]
	end
end

function wnd_create(layout)
	local wnd = wnd_lucky_wheel.new();
	wnd:create(layout);
	return wnd;
end
