-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_today_tips = i3k_class("wnd_today_tips", ui.wnd_base)

function wnd_today_tips:ctor()
	self.canSelect = true
	self.tipsType = g_NPC_EXCHANGE_TYPE
end

function wnd_today_tips:configure()
	self._layout.vars.ok:onClick(self,self.onSureBtn)
	self._layout.vars.cancel:onClick(self,self.onCloseUI)
	self._layout.vars.markBtn:onClick(self,self.selectNotShow)

	self._layout.vars.desc:setText(i3k_get_string(15469))
	self._layout.vars.desc_1:setText(i3k_get_string(15470))

	self._layout.vars.markImg:hide()
end

function wnd_today_tips:refresh(tipsType,arg)
	self.tipsType = tipsType
	self.arg = arg  --发送兑换协议所需要的参数
	if tipsType == g_DRAGON_TASK_REFRESH then
		self._layout.vars.desc:setText(i3k_get_string(16974))
		self._layout.vars.desc_1:setText(i3k_get_string(16975))
	end
end

function wnd_today_tips:onSureBtn(sender)
	local cfg = g_i3k_game_context:GetUserCfg()
	local tipsType = self.tipsType
	if cfg then
		if not self.canSelect then
			cfg:SetTipNotShowDay(tipsType, g_i3k_get_day(i3k_game_get_time()))
		end
		if tipsType == g_NPC_EXCHANGE_TYPE then  --NPC兑换
			self:requestNpcExchange()
		elseif tipsType == g_FULI_EXCHANGE_TYPE then  --福利活动兑换
			self:requestFuliExchange()
		elseif tipsType == g_LUCKY_WHELL_TYPE then  --幸运大转盘
			self:requestLuckyWheel()
		elseif tipsType == g_REFRESH_GOLDEN_EGG_TYPE then  --刷新砸金蛋活动
			self:requestRefreshGoldenEgg()
		elseif tipsType == g_GOLDEN_EGG_TYPE then  --砸金蛋
			self:requestGoldenEgg()
		elseif tipsType == g_DEBRIS_RECYCLE_TYPE then  --碎片兑换
			self:requestDebrisRecycle()
		elseif tipsType == g_DONATE_GETFAME_TYPE then  --捐赠获得武林声望
			self:requestDonateGetFame()
		elseif tipsType == g_DRAGON_TASK_REFRESH then	--龙穴任务刷新
			self:requestDragonTaskRefresh()
		end
	end
	self:onCloseUI()
end

--请求NPC物物兑换
function wnd_today_tips:requestNpcExchange()
	local tbl = self.arg
	if tbl then
		if tbl.npcId then
			i3k_sbean.exchange_goods(tbl.npcId, tbl.id, 1)
		else
			--对对碰兑换
			i3k_sbean.exchange_words_req(tbl.rewardId)
		end
	end
end

--请求福利活动兑换
function wnd_today_tips:requestFuliExchange()
	local tbl = self.arg
	if tbl then
		local needValue = tbl.needValue
		local gift = tbl.gift
		local percent = tbl.percent
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
end

--请求幸运大转盘N连抽
function wnd_today_tips:requestLuckyWheel()
	local tbl = self.arg
	if tbl then
		local effectiveTime = tbl.effectiveTime
		local id = tbl.id
		local cost = tbl.cost
		if g_i3k_game_context:GetCommonItemCanUseCount(cost.id) < cost.count then
			g_i3k_ui_mgr:PopupTipMessage("道具数量不足")
		else
			i3k_sbean.activities_mul_luckywheel_take(effectiveTime, id, cost)  --连抽
		end
	end
end

--请求刷新砸金蛋活动
function wnd_today_tips:requestRefreshGoldenEgg()
	local tbl = self.arg
	if tbl then
		i3k_sbean.activities_goldenEgg_refresh(tbl.effectiveTime, tbl.id, tbl.curtimes, tbl.cost)
	end
end

--请求砸金蛋
function wnd_today_tips:requestGoldenEgg()
	local tbl = self.arg
	if tbl then
		i3k_sbean.activities_goldenEgg_smash(tbl.effectiveTime, tbl.id, tbl.curtimes, tbl.playtimes, tbl.costId, tbl.cost, tbl.recordEgg, tbl.num, tbl.leftTimes)
	end
end

function wnd_today_tips:requestDebrisRecycle()
	local tbl = self.arg   
	if tbl then
		i3k_sbean.debrisRecycle_req(tbl.order, tbl.itemOrder, tbl.itemId, tbl.itemCount, tbl.coinCost)
	end
end

--请求捐赠物品获得武林声望
function wnd_today_tips:requestDonateGetFame()
	
end

--龙穴刷新
function wnd_today_tips:requestDragonTaskRefresh()
	local tbl = self.arg
	if tbl then
		i3k_sbean.dragon_hole_task_refresh(tbl)
	end
end

function wnd_today_tips:selectNotShow(sender)
	if self.canSelect then
		self._layout.vars.markImg:show()
		self.canSelect = false
	else
		self._layout.vars.markImg:hide()
		self.canSelect = true
	end
end

function wnd_today_tips:setTipsContent(content)
	self._layout.vars.desc:setText(content)
end

function wnd_create(layout, ...)
	local wnd = wnd_today_tips.new()
	wnd:create(layout, ...)
	return wnd;
end
