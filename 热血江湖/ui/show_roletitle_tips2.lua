-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_show_roleTitles_tips2 = i3k_class("wnd_show_roleTitles_tips2",ui.wnd_base)


local SYDJJL_WIDGET = "ui/widgets/chtst"
local RowitemCount = 3

function wnd_show_roleTitles_tips2:ctor()
	
end

function wnd_show_roleTitles_tips2:configure()
	local widgets = self._layout.vars

	widgets.ok:onClick(self, self.onCloseUI)
end

function wnd_show_roleTitles_tips2:refresh(id, callback)
	self._callback = callback
	local delay = cc.DelayTime:create(0.15)--序列动作 动画播了0.15秒后显示奖励
	local seq =	cc.Sequence:create(cc.CallFunc:create(function ()
		self._layout.anis.c_dakai.play()
	end), delay, cc.CallFunc:create(function ()
		self:updateScroll(id)
	end))
	self:runAction(seq)
end

function wnd_show_roleTitles_tips2:updateScroll(id)
	local info = i3k_db_title_base[id]
	self._layout.vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(info.iconbackground))
	self._layout.vars.icon:setImage(g_i3k_db.i3k_db_get_title_icon_path(info.name))
	local times
	if info.time > 0 then
		local nowTime = info.time
		local hour = math.modf(nowTime/(3600*24) * 24)
		local min = math.fmod(math.floor(nowTime/60), 60)
		local sec = math.fmod(nowTime, 60)
		if hour >= 1 then
			times = string.format("剩余%s小时%s分钟",hour,min)
		elseif hour < 1 then
			times = string.format("剩余%s分钟%s秒", min, sec)
		end
	else
		times = "永久"
	end
	local str = string.format("时效：%s", times)
	self._layout.vars.time:setText(str)
	
	self._layout.vars.scroll:removeAllChildren()
	for i=1, 5 do
		if info["attribute"..i] ~= 0 then
			local value = info["value"..i]
			local attribute = info["attribute"..i]
			local layer = require(SYDJJL_WIDGET)()
			local widget = layer.vars
			widget.propertyName:setText(g_i3k_db.i3k_db_get_property_name(attribute))
			widget.propertyValue:setText(i3k_get_prop_show(attribute, value))
			self._layout.vars.scroll:addItem(layer)
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_show_roleTitles_tips2.new()
	wnd:create(layout)
	return wnd
end
