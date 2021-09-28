module(..., package.seeall)

local require = require

local ui = require("ui/base")

wnd_forceWarLottery = i3k_class("forceWarLottery",ui.wnd_base)

function wnd_forceWarLottery:ctor()
end

function wnd_forceWarLottery:configure()
	local widget = self._layout.vars
	self.close_btn = widget.close_btn
	self.close_btn:onClick(self, self.onCloseUI)
	self.times = widget.times
	self.scroll = widget.scroll
	for i = 1, 3 do
		self['btn' .. i] = widget['btn' .. i]
		self['btn' .. i]:onClick(self, self.onBtnClick, i)
		self['c_bx' .. i] = self._layout.anis['c_bx' .. i + 8]
		self['c_bx' .. i]:stop()
	end
end

function wnd_forceWarLottery:refresh()
	self.scroll:removeAllChildren()
	for k, v in ipairs(i3k_db_forcewar_base.lotteryData.items) do
		local node = require("ui/widgets/shilizhanchoujiangt")()
		node.vars.rank:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(v.id)))
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id))
		node.vars.count:setText(string.format("x%d", v.count))
		node.vars.itemBtn:onClick(self, function ()
			g_i3k_ui_mgr:ShowCommonItemInfo(v.id)
		end)
		self.scroll:addItem(node)
	end
	local times = g_i3k_game_context:getForceWarLotteryNum()
	self.times:setText(i3k_get_string(18546, times, i3k_db_forcewar_base.lotteryData.maxNotice))
end

function wnd_forceWarLottery:onHide()
	if self._co then
		g_i3k_coroutine_mgr:StopCoroutine(self._co)
		self._co = nil
	end
end

function wnd_forceWarLottery:onBtnClick(sender, index)
	local times = g_i3k_game_context:getForceWarLotteryNum()
	if times > 0 and g_i3k_game_context:checkBagCanAddCell(i3k_db_forcewar_base.lotteryData.needBagCell, true) then
		i3k_sbean.forceWarLottery(index)
	elseif times < 1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18540))
	end
end

function wnd_forceWarLottery:openBoxCallback(rewards, index)
	self._co = g_i3k_coroutine_mgr:StartCoroutine(function ()
		self['c_bx' .. index]:play()
		g_i3k_coroutine_mgr.WaitForSeconds(i3k_db_forcewar_base.lotteryData.animationTime)
		g_i3k_ui_mgr:ShowGainItemInfo(rewards, function ()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_ForceWarLottery, "gainItemCallBack")
		end)
		local lotteryNum = g_i3k_game_context:getForceWarLotteryNum()
		g_i3k_game_context:setForceWarLotteryNum(lotteryNum - 1)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ForceWarLottery, "refresh")
		g_i3k_coroutine_mgr:StopCoroutine(self._co)
		self._co = nil
	end)
end

function wnd_forceWarLottery:gainItemCallBack()
	for i = 1, 3 do
		self['c_bx' .. i]:stop()
	end
end

function wnd_create(layout)
	local wnd = wnd_forceWarLottery.new()
	wnd:create(layout)
	return wnd
end