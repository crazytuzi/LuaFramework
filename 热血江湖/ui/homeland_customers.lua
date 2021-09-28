-- zengqingfeng
-- 2018/6/4
--eUIID_HomelandCustomer --家园访客
-------------------------------------------------------
-- i3k_logic:OpenHomelandCustomersUI()

module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
local LAYER_TIPS = "ui/widgets/jiayuantrt"

homeland_customers = i3k_class("homeland_customers", ui.wnd_base)

function homeland_customers:ctor()
	self._requestTime = 0
	self._requestCD = 7.0
	self._players = {}
end

function homeland_customers:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseAnisBtn)
	widgets.openBtn:onClick(self, self.onOpenAnisBtn)
	self._scrollView = widgets.task_scroll
	
	widgets.bossBtn:onClick(self, self.refresh)
	widgets.homePetBtn:onClick(self, self.onHomePetBtn)
end

function homeland_customers:onUpdate(dTime)
	if g_i3k_game_context:isInMyHomeLand() then
	self._requestTime = self._requestTime - dTime
	if self._requestTime < 0 then 
		self._requestTime = self._requestCD
		i3k_sbean.homeland_query_roles()
		end
	end
end 

function homeland_customers:refresh()
	if g_i3k_game_context:isInMyHomeLand() then
	self._players = g_i3k_game_context:getHomeLandPlayers()
	self:refreshScrollView()
	else
		self._layout.vars.openBtn:hide()
		self._layout.vars.closeBtn:hide()
		self._layout.vars.task_scroll:hide()
		self._layout.vars.bossBtn:hide()
		self._layout.vars.recordRoot:hide()
	end
end

function homeland_customers:refreshScrollView()
	local scrollView = self._scrollView
	scrollView:removeAllChildren()
	for index, info in ipairs(self._players) do 
		local itemView = require(LAYER_TIPS)()
		self:setItemData(itemView, info, index)
		scrollView:addItem(itemView)
	end
end 

function homeland_customers:setItemData(itemView, itemInfo, index)
	local widgets = itemView.vars 
	widgets.kickBtn:onClick(self, self.kickPlayer, itemInfo)
	widgets.playerName:setText(itemInfo.name)
end 

function homeland_customers:kickPlayer(sender, itemInfo)
	g_i3k_logic:kickOut(itemInfo.id, function()
		self._requestTime = 0.2
	end)
end 

function homeland_customers:onCloseAnisBtn(sender)
	self._layout.vars.closeBtn:hide()
	self._layout.anis.c_ru.play(
	function()
		self._layout.vars.openBtn:show()
	end)
end
function homeland_customers:onOpenAnisBtn(sender)
	self._layout.vars.openBtn:hide()
	self._layout.anis.c_chu.play(
	function()
		self._layout.vars.closeBtn:show()
	end)
end

function homeland_customers:onHomePetBtn(sender)
	if g_i3k_game_context:isInMyHomeLand() then
		g_i3k_ui_mgr:OpenUI(eUIID_HomePetOperate)
		g_i3k_ui_mgr:RefreshUI(eUIID_HomePetOperate)
	else
		i3k_sbean.homeland_pet_position_ask()
	end
end
function wnd_create(layout)
	local wnd = homeland_customers.new();
	wnd:create(layout);
	return wnd;
end
