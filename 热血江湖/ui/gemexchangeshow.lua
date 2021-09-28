-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");

-------------------------------------------------------
wnd_gemExchange = i3k_class("wnd_gemExchange", ui.wnd_base) 

local WIDGET = "ui/widgets/hufuzht"
local DESCWIDGET = "ui/widgets/hufuzht2" 
local IMAGE = 8548

function wnd_gemExchange:ctor()

end

function wnd_gemExchange:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
end

function wnd_gemExchange:refresh()
	local widget = self._layout.vars
	widget.titleImage:setImage(g_i3k_db.i3k_db_get_icon_path(IMAGE))
	widget.scroll:removeAllChildren()
	local items = {}
	local index = 0
	
	for _, v in ipairs(i3k_db_gem_exchange) do
		if g_i3k_game_context:GetCommonItemCount(v.gemId) > 0 then
			index = index + 1
			items[index] = {lock = true, value = v}
		end
		
		if g_i3k_game_context:GetCommonItemCount(-v.gemId) > 0 then
			index = index + 1
			items[index] = {lock = false, value = v}		
		end
	end
	
	for _, v in ipairs(items) do
		local wid =  require(WIDGET)()
		local vas = wid.vars
		local id = v.value.gemId
		vas.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
		vas.equipBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		vas.suo:setVisible(v.lock)
		vas.name:setText(g_i3k_db.i3k_db_get_common_item_name(id))
		vas.power:setText(g_i3k_db.i3k_db_get_common_item_desc(id))
		vas.selectBtn:onClick(self, self.onClickItem, {gemId = id, falg = v.lock})
		widget.scroll:addItem(wid)
	end
	
	widget.desc_scroll:removeAllChildren()
	local layer = require(DESCWIDGET)()
	layer.vars.text:setText(i3k_get_string(18071))
	widget.desc_scroll:addItem(layer)

	g_i3k_ui_mgr:AddTask(self, {layer}, function(ui)
		local size = layer.rootVar:getContentSize()
		local height = layer.vars.text:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or height
		layer.rootVar:changeSizeInScroll(ui._layout.vars.desc_scroll, width, height, true)
	end, 1)
end


function wnd_gemExchange:onClickItem(sender, value)
	g_i3k_ui_mgr:OpenUI(eUIID_GemExchangeOperate)
	g_i3k_ui_mgr:RefreshUI(eUIID_GemExchangeOperate, value)
end

function wnd_create(layout, ...)
	local wnd = wnd_gemExchange.new()
	wnd:create(layout, ...)
	return wnd
end