
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_shakeTree = i3k_class("wnd_shakeTree",ui.wnd_base)

function wnd_shakeTree:ctor()
	self._data = nil
	self._cfg = nil
	self._poptick = 0
	self._isCountDown = false
end

function wnd_shakeTree:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
	widgets.helpBtn:onClick(self, function()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(1610))
	end)
	widgets.shakeBtn:onClick(self, self.onShakeTree)
end

function wnd_shakeTree:refresh(data)
	local widgets = self._layout.vars
	self._data = data

	local moneyTreeId = data.moneyTreeId
	local cfg = i3k_db_shake_tree[moneyTreeId]
	self._cfg = cfg

	local startTimeStr = g_i3k_get_YearAndMonthAndDayTime(cfg.startTime)
	local endTimeStr = g_i3k_get_YearAndMonthAndDayTime(cfg.endTime)
	widgets.actTime:setText(i3k_get_string(5186, startTimeStr, endTimeStr))

	widgets.haveShakeTimes:setText(i3k_get_string(1664, data.totalGetCnt))

	self:updateCDTime()
	self:updateShakeBtnState()
	self:updateExtraRewardUI(cfg, data)
	self:updateModel(cfg)
end

function wnd_shakeTree:onUpdate(dTime)
	if self._isCountDown then
		self._poptick = self._poptick + dTime
		if self._poptick >= 1 then
			self:updateCDTime()
			self._poptick = 0
		end
	end
end

function wnd_shakeTree:updateCDTime()
	local widgets = self._layout.vars

	local curTime = i3k_game_get_time()
	local remainCDTime = self._cfg.shakeCD - (curTime - self._data.lastGetTime)

	widgets.CDLabel:setTextColor(g_i3k_get_red_color())
	if self._data.lastGetTime > 0 and remainCDTime > 0 then
		widgets.CDLabel:setText(i3k_get_string(1608, i3k_get_format_time_to_show(remainCDTime)))
		self._isCountDown = true
	else
		local remainTimes = self._cfg.dayShakeTimes - self._data.dayCnt
		widgets.CDLabel:setText(i3k_get_string(1609, remainTimes))
		if remainTimes > 0 then
			widgets.CDLabel:setTextColor(g_i3k_get_green_color())
		end
		self._isCountDown = false
		self:updateShakeBtnState()
	end
end

function wnd_shakeTree:updateShakeBtnState()
	local widgets = self._layout.vars
	local remainTimes = self._cfg.dayShakeTimes - self._data.dayCnt
	widgets.shakeBtn:SetIsableWithChildren(not self._isCountDown and remainTimes > 0)
end

function wnd_shakeTree:updateExtraRewardUI(cfg, data)
	local widgets = self._layout.vars
	widgets.scroll:removeAllChildren()

	local extraRewards = cfg.extraRewards
	for i, v in ipairs(extraRewards) do
		local node = require("ui/widgets/yaoqianshut")()
		node.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.itemID))
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.itemID))
		node.vars.count:setText(v.itemCount)
		node.vars.suo:setVisible(v.itemID > 0)
		node.vars.btn:onClick(self, self.onShowItemInfo, v.itemID)

		local isEnoughCond = data.totalGetCnt >= v.times
		local nowNeedTimes = isEnoughCond and v.times or data.totalGetCnt

		node.vars.shakeDesc:setText(i3k_get_string(1603, nowNeedTimes, v.times))
		node.vars.shakeDesc:setTextColor(g_i3k_get_cond_color(isEnoughCond))

		if not data.addUpRewards[v.times] then
			if not isEnoughCond then
				node.vars.getLabel:setText(i3k_get_string(1605))
				node.vars.getBtn:disableWithChildren()
			else
				node.vars.getLabel:setText(i3k_get_string(1605))
				node.vars.getBtn:onClick(self, self.onGetReward, {addUpCnt = v.times, rewards = {{id = v.itemID, count = v.itemCount}}})
			end
		else
			node.vars.getLabel:setText(i3k_get_string(1606))
			node.vars.getBtn:disableWithChildren()
		end
		widgets.scroll:addItem(node)
	end
end

function wnd_shakeTree:onShowItemInfo(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_shakeTree:onGetReward(sender, data)
	local addUpCnt = data.addUpCnt
	local rewards = data.rewards
	local getRewards = {}
	for _, v in ipairs(rewards) do
		getRewards[v.id] = v.count
	end
	if not g_i3k_game_context:IsBagEnough(getRewards) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1607))
	end
	i3k_sbean.money_tree_get_add_up(self._data.moneyTreeId, addUpCnt, rewards)
end

function wnd_shakeTree:updateModel(cfg)
	local widgets = self._layout.vars
	local modelID = cfg.modelID

	local path = i3k_db_models[modelID].path
	local uiscale = i3k_db_models[modelID].uiscale
	widgets.model:setSprite(path)
	widgets.model:setSprSize(uiscale)
	widgets.model:setSprSize(uiscale)
	widgets.model:playAction("stand")
end

function wnd_shakeTree:playShakeAction()
	local widgets = self._layout.vars
	widgets.model:playAction("dianji")
end

function wnd_shakeTree:onShakeTree(sender)
	local cfg = self._cfg
	if not g_i3k_game_context:checkBagCanAddCell(cfg.needBagCell, false) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1604, cfg.needBagCell))
	end
	i3k_sbean.money_tree_shake(self._data.moneyTreeId, cfg.npcID)
end

function wnd_shakeTree:setUIBtnState(canClick)
	local widgets = self._layout.vars
	widgets.close:setTouchEnabled(canClick)
	widgets.helpBtn:setTouchEnabled(canClick)
	widgets.shakeBtn:setTouchEnabled(canClick)
	local allbars = widgets.scroll:getAllChildren()
	for _, v in ipairs(allbars) do
		v.vars.btn:setTouchEnabled(canClick)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_shakeTree.new()
	wnd:create(layout, ...)
	return wnd;
end

