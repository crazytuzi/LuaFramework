-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_christmas_wishes_list = i3k_class("wnd_christmas_wishes_list", ui.wnd_base)

local LAYER_SHENGDANSHUT = "ui/widgets/shengdanshut"

function wnd_christmas_wishes_list:ctor()
	self._wishesInfo = {}
end

function wnd_christmas_wishes_list:configure()
	local widget = self._layout.vars
	widget.close_btn:onClick(self, self.onCloseUI)
	widget.change_btn:onClick(self, self.onChangeBtn)

	self.scroll = widget.scroll
end

function wnd_christmas_wishes_list:refresh(wishesInfo)
	self._wishesInfo = wishesInfo
	self:updateWishList()
end

function wnd_christmas_wishes_list:updateWishList()
	self.scroll:removeAllChildren()

	--如果愿望条数小于4，则添加npc愿望
	if #self._wishesInfo < i3k_db_christmas_wish_cfg.show_count then
		self:addNpcWishInfo()
	end

	for i, v in ipairs(self._wishesInfo or {}) do
		local ui = require(LAYER_SHENGDANSHUT)()
		ui.vars.name:setText(string.format("%s的贺卡", v.roleName))
		ui.vars.brick_num:setText(string.format("x%s", v.brick))
		ui.vars.flower_num:setText(string.format("x%s", v.flower))
		ui.vars.btn:onClick(self, self.onItemClick, v)
		ui.vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_christmas_wish_bgImg[v.background].treeBgID))

		self.scroll:addItem(ui)
	end
end

function wnd_christmas_wishes_list:addNpcWishInfo()
	local need_add_num = i3k_db_christmas_wish_cfg.show_count - #self._wishesInfo
	if need_add_num <= #i3k_db_npc_christmas_wish then  --防止随机方法陷入死循环
		local indexList = g_i3k_db.i3k_db_get_no_repeat_randrom_number(need_add_num, #i3k_db_npc_christmas_wish)
		for _, v in ipairs(indexList) do
			local overview = self:getWishOverview(i3k_db_npc_christmas_wish[v])
			table.insert(self._wishesInfo, overview)
		end
	end
end

function wnd_christmas_wishes_list:getWishOverview(npcWishInfo)
	local overview = i3k_sbean.ChristmasCardOverview.new()
	overview.rid = nil
	overview.text = npcWishInfo.wishText
	overview.roleName = npcWishInfo.npcName
	overview.flower = 0
	overview.brick = 0
	overview.background = npcWishInfo.bgID
	return overview
end

function wnd_christmas_wishes_list:onItemClick(sender, overview)
	g_i3k_ui_mgr:OpenUI(eUIID_ChristmasWish)
	g_i3k_ui_mgr:RefreshUI(eUIID_ChristmasWish, i3k_game_get_time(), overview, g_TYPE_Comment)
end

function wnd_christmas_wishes_list:onChangeBtn(sender)
	i3k_sbean.christmas_cards_get_list()
end

function wnd_create(layout, ...)
	local wnd = wnd_christmas_wishes_list.new();
	wnd:create(layout, ...);
	return wnd;
end
