-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_cardPacketDesc = i3k_class("wnd_cardPacketDesc", ui.wnd_base)

-- 图鉴卡牌详情
-- [eUIID_CardPacketDesc]	= {name = "cardPacketDesc", layout = "tujian3", order = eUIO_TOP_MOST,},
-------------------------------------------------------

function wnd_cardPacketDesc:ctor()

end

function wnd_cardPacketDesc:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.oncloseBtn)
end

function wnd_cardPacketDesc:refresh(cardID)
	local cfg = g_i3k_db.i3k_db_cardPacket_get_card_cfg(cardID)
	self:setLabels( cfg.words, cfg.desc)
	self:setScrolls(cfg.props)
	self:setImage(cfg)
end



function wnd_cardPacketDesc:setLabels(text, desc)
	local widgets = self._layout.vars
	widgets.word:setText(text)
	-- widgets.desc:setText(desc)
	self:setDescScroll(desc)
end


function wnd_cardPacketDesc:oncloseBtn(sender)
	self:onCloseUI()
end

function wnd_cardPacketDesc:setImage(cfg)
	local widgets = self._layout.vars
	widgets.img:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.imageID))
	widgets.back:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.coverImageID))
	widgets.descImg:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.backBoardID))
end

function wnd_cardPacketDesc:setScrolls(list)
	local widgets = self._layout.vars
	local scroll = widgets.scroll1
	scroll:removeAllChildren()
	for k, v in ipairs(list) do
		local ui = require("ui/widgets/tujian3t")()
		-- ui.vars.btn:onClick()
		ui.vars.propertyName:setText(g_i3k_db.i3k_db_get_property_name(v.id))
		ui.vars.propertyValue:setText(i3k_get_prop_show(v.id, v.count))
		local icon = g_i3k_db.i3k_db_get_property_icon(v.id)
		ui.vars.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
		scroll:addItem(ui)
	end
end

function wnd_cardPacketDesc:setDescScroll(desc)
	local widgets = self._layout.vars
	local scroll = widgets.scroll2
	scroll:removeAllChildren()
	local layer = require("ui/widgets/tujian3t2")()
	layer.vars.txt:setText(desc)
	g_i3k_ui_mgr:AddTask(self, {layer}, function(ui)
		local size = layer.rootVar:getContentSize()
		local height = layer.vars.txt:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or height
		layer.rootVar:changeSizeInScroll(ui._layout.vars.scroll2, width, height, true)
	end, 1)
	scroll:addItem(layer)
end

function wnd_create(layout, ...)
	local wnd = wnd_cardPacketDesc.new()
	wnd:create(layout, ...)
	return wnd;
end
