module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_buy_private_warehouse = i3k_class("wnd_buy_private_warehouse", ui.wnd_base)

function wnd_buy_private_warehouse:ctor()
	
end

function wnd_buy_private_warehouse:configure()
	local widgets = self._layout.vars
	self.tst = widgets.tst;
	self.buyNum = widgets.buyNum;
	widgets.cancel_btn:onClick(self,self.onCloseUI);
	widgets.buy_btn:onClick(self, self.onBuy);
	widgets.marry_btn:onClick(self, self.onMarry);
	
end

function wnd_buy_private_warehouse:onBuy()
	if g_i3k_game_context:GetLevel() >= i3k_db_common.warehouse.freeUnlockLevel then
		i3k_sbean.unlock_private_warehouse(0)
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_IsBuyWareHouse);
	g_i3k_ui_mgr:RefreshUI(eUIID_IsBuyWareHouse)
end

function wnd_buy_private_warehouse:onMarry()
	if g_i3k_game_context:getMarryType() == 1 then
		g_i3k_ui_mgr:CloseUI(eUIID_BuyPrivateWareHouse)
		g_i3k_ui_mgr:CloseUI(eUIID_Bag)
		g_i3k_game_context:gotoYueLaoNpc()
	end
end

function wnd_buy_private_warehouse:refresh()
	local needMoney = i3k_db_common.warehouse.unlockExpense
	--免费开启
	if g_i3k_game_context:GetLevel() >= i3k_db_common.warehouse.freeUnlockLevel then
		self._layout.vars.buyCost:setVisible(false)
		self._layout.vars.buy_title:setText("免费开启");
	end
	self.buyNum:setText(needMoney);
	self.tst:setText(i3k_get_string(3060, i3k_db_common.warehouse.unlockLvl, needMoney, i3k_db_common.warehouse.freeUnlockLevel));
end

function wnd_create(layout)
	local wnd = wnd_buy_private_warehouse.new();
		wnd:create(layout);
	return wnd;
end
