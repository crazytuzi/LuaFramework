-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
local FUN = {
	[g_BASE_ITEM_SECT_MONEY] = function(refreshTimes, index, coinCnt, discount)
		local data = i3k_sbean.sect_shoprefresh_req.new()
		data.times = refreshTimes + 1
		data.isSecondType = index
		data.coinCnt = coinCnt
		data.discount = discount
		i3k_game_send_str_cmd(data,i3k_sbean.sect_shoprefresh_res.getName())
	end,
	[g_BASE_ITEM_TOURNAMENT_MONEY] = function(refreshTimes, index, coinCnt, discount)
		i3k_sbean.team_arena_refresh_store(refreshTimes+1, index, coinCnt, discount)
	end,
	[g_BASE_ITEM_ESCORTT_MONEY] = function(refreshTimes, index, coinCnt, discount)
	 	i3k_sbean.escort_store_refresh(coinCnt, refreshTimes+1, index, discount)
	end,
	[g_BASE_ITEM_ARENA_MONEY] = function (refreshTimes, index, coinCnt, discount)
			local refreshShop = i3k_sbean.arena_shoprefresh_req.new()
			refreshShop.times = refreshTimes + 1
			refreshShop.isSecondType = index
			refreshShop.coinCnt = coinCnt
			refreshShop.discount = discount
			i3k_game_send_str_cmd(refreshShop, "arena_shoprefresh_res")
	end,
	[g_BASE_ITEM_MASTER_POINT] = function(refreshTimes, index, coinCnt, discount)
	 	i3k_sbean.master_shop_refresh(coinCnt,refreshTimes+1, index, discount)
	end,
	[g_BASE_ITEM_PETCOIN] = function(refreshTimes, index, coinCnt, discount)
	 	i3k_sbean.refreshPetRaceShop(refreshTimes+1, index, coinCnt, discount)
	end,
	[g_BASE_ITEM_FAME] = function(refreshTimes, index, coinCnt, discount)
	 	local refreshShop = i3k_sbean.fame_shoprefresh_req.new()
			refreshShop.times = refreshTimes + 1
			refreshShop.isSecondType = index
			refreshShop.coinCnt = coinCnt
			refreshShop.discount = discount
			i3k_game_send_str_cmd(refreshShop, "fame_shoprefresh_res")
	end,
}

wnd_storeRefresh = i3k_class("wnd_storeRefresh", ui.wnd_base)

function wnd_storeRefresh:ctor()
	self.specCoinCnt = 0
	self.diamond = 0
	self.diamondSub = 0
	self.specCoinType = 0
	self.refreshTimes = 0
	self.index = 0
	self.specCoinEnough = nil
	self.discount = {}
end

function wnd_storeRefresh:configure()
	local vars = self._layout.vars
	vars.closeBtn:onClick(self, self.onCloseUI)
	vars.cancel:onClick(self, self.onCloseUI)
	vars.ok:onClick(self, self.onBuy)
	vars.cIconBtn1:onClick(self, self.onChangePay,0)
	vars.cIconBtn2:onClick(self, self.onChangePay,1)
	vars.gou2:hide()
end

function wnd_storeRefresh:refresh(specCoin, specCoinCnt, specCoinEnough, diamond, diamondSub, refreshTimes, discount)
	self.index = 0
	self.diamondSub = diamondSub
	self.refreshTimes = refreshTimes
	self.specCoinType = specCoin
	self.specCoinCnt = specCoinCnt
	self.diamond = diamond
	self.specCoinEnough = specCoinEnough
	self.discount = discount
	local vars = self._layout.vars
	vars.cIcon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(specCoin,i3k_game_context:IsFemaleRole()))
	vars.cTxt1:setText("x"..specCoinCnt)
	vars.cTxt2:setText("x"..diamond)
	if not specCoinEnough then
		--vars.cIconBtn1:disable()
		vars.gou2:show()
		vars.gou1:hide()
		self.index = 1
	end
end

function wnd_storeRefresh:onBuy()
	local coinCnt
	if self.index == 1 then
		coinCnt = self.diamond
		if self.diamondSub < 0 then
			local desc = string.format("绑定元宝不足，确定消耗<c=FF01A63A>%s元宝</c>刷新？（绑定元宝不足则会消耗元宝）", math.abs(self.diamondSub))
			g_i3k_ui_mgr:ShowMessageBox2(desc,function(ok)
				if ok then
					self:sendProt(self.refreshTimes,self.index,coinCnt)
				end
				self:onCloseUI()
			end)
			return
		end
	else
		coinCnt = self.specCoinCnt
	end
	self:sendProt(self.refreshTimes,self.index,coinCnt)
	self:onCloseUI()
end

function wnd_storeRefresh:sendProt(refreshTimes, index, coinCnt)
	FUN[self.specCoinType](self.refreshTimes, self.index, coinCnt, self.discount)
end

function wnd_storeRefresh:onChangePay(sender,args)
	if args == 0 and not self.specCoinEnough then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15186))
	end
	if self.index ~= args then
		self._layout.vars.gou2:hide()
		self._layout.vars.gou1:hide()
		self._layout.vars["gou"..(args+1)]:show()
		self.index = args
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_storeRefresh.new()
	wnd:create(layout, ...);

	return wnd
end
