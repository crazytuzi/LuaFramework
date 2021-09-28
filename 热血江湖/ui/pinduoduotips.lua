-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_pinduoduoTips = i3k_class("wnd_pinduoduoTips", ui.wnd_base)

function wnd_pinduoduoTips:ctor()

end

function wnd_pinduoduoTips:configure()
    self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_pinduoduoTips:onShow()

end

function wnd_pinduoduoTips:refresh(info)
    self:setUI(info)
end

function wnd_pinduoduoTips:setUI(info)
    local widgets = self._layout.vars
    widgets.label1:setText("当前参团人数:"..info.logCfg.curRoleSize)
    widgets.label2:setText(i3k_get_string(17091))

    local scroll = widgets.scroll
    scroll:removeAllChildren()

    for k, v in ipairs(info.info.discounts) do
        local widget = require("ui/widgets/pinduoduotipst")()
        widget.vars.labelDesc:setText("参团人数达到"..v.roleCount)
        widget.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(info.info.costItem, g_i3k_game_context:IsFemaleRole()))
        widget.vars.labelCount:setText(v.price)

        scroll:addItem(widget)
    end

end


function wnd_create(layout, ...)
	local wnd = wnd_pinduoduoTips.new()
	wnd:create(layout, ...)
	return wnd;
end
