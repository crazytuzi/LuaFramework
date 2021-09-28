module(..., package.seeall)

local ui = require("ui/base");

wnd_npcHotelDetail = i3k_class("wnd_npcHotelDetail", ui.wnd_base)

local WIDGET_DETAIL = "ui/widgets/jhkzt3"

function wnd_npcHotelDetail:ctor()
end

function wnd_npcHotelDetail:configure()
	local layout = self._layout.vars
	--江湖客栈名字
	self.hotelName = layout.hotelName
	--物品显示列表
	self.scroll = layout.scroll
	--关闭按钮
	self.close_btn = layout.close_btn
	self.close_btn:onClick(self, self.onCloseUI)
end

function wnd_npcHotelDetail:refresh(npcID)
	npcID = npcID or 1
	self.scroll:removeAllChildren(true)
	self.hotelName:setText(i3k_get_string(18163, i3k_db_hostel_npc[npcID].name))
	local length = 5
	local m_data = i3k_db_hostel_npc[npcID].chipsList8
	local nodes = self.scroll:addChildWithCount(WIDGET_DETAIL, length, #m_data)
	for k,v in ipairs(m_data) do
		local widget = nodes[k].vars
		local chipCfg = i3k_db_treasure_chip[v]
		widget.img:setImage(g_i3k_db.i3k_db_get_icon_path(chipCfg.iconID))
		widget.rank_img:setImage(g_i3k_get_icon_frame_path_by_rank(chipCfg.rank))
		widget.name:setText(chipCfg.name)
		widget.name:setTextColor(g_i3k_get_color_by_rank(chipCfg.rank))
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_npcHotelDetail.new()
	wnd:create(layout, ...)
	return wnd;
end
