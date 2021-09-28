-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
local UI_WIDGET = "ui/widgets/lyjftipst"
-------------------------------------------------------
wnd_unlockHunyuTips = i3k_class("wnd_unlockHunyuTips", ui.wnd_base)

function wnd_unlockHunyuTips:ctor()

end

function wnd_unlockHunyuTips:configure()

end

function wnd_unlockHunyuTips:onShow()

end

function wnd_unlockHunyuTips:refresh(id)
	self:setScrollData(id)
	local info = g_i3k_game_context:getRoleSealAwaken()
	local isUnlocked = info.rank > id
	if isUnlocked then
		self:setShowLabel()
	end
end

function wnd_unlockHunyuTips:setHideLabel()
	self._layout.vars.unavalible:hide()
end

function wnd_unlockHunyuTips:setShowLabel()
	self._layout.vars.unavalible:show()
	self._layout.vars.unavalible:setText("此祝福已生效")
	self._layout.vars.unavalible:setTextColor(g_i3k_get_cond_color(true))
end

function wnd_unlockHunyuTips:setScrollData(id)
	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren()
	local cfg = g_i3k_db.i3k_db_get_longyin_ban(id)
	for k, v in ipairs(cfg.wish) do
		if v.type > 0 then
			local widget = require(UI_WIDGET)()
			local propName = g_i3k_db.i3k_db_get_property_name(v.type)
			widget.vars.propertyName:setText(propName)
			widget.vars.propertyValue:setText(i3k_get_prop_show(v.type, v.value))
			scroll:addItem(widget)
		end
	end
	local widget = require(UI_WIDGET)()
	widget.vars.propertyName:setText("魂玉基础属性+"..cfg.propPercent / 10000 * 100 .."%")
	widget.vars.propertyValue:hide()
	scroll:addItem(widget)
end

function wnd_create(layout, ...)
	local wnd = wnd_unlockHunyuTips.new()
		wnd:create(layout, ...)
	return wnd
end
