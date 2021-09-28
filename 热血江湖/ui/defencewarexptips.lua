
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_defenceWarExpTips = i3k_class("wnd_defenceWarExpTips",ui.wnd_base)
local LAYER_BUFFTIPS3T = "ui/widgets/bufftips3t"

function wnd_defenceWarExpTips:ctor()
	self._sc = nil
	self._timeTick = 0
end

function wnd_defenceWarExpTips:configure()
	self.scroll = self._layout.vars.scroll
	self.bg = self._layout.vars.bg
	self.root = self._layout.vars.root
end

function wnd_defenceWarExpTips:refresh(pos)
	if self._sc then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._sc)
		self._sc = nil
		self._timeTick = 0
	end

	local posX = pos.x - 20
	local posY = isOther and pos.y - 20 or pos.y + 20
	self.root:setPosition(posX, posY)

	self.scroll:stateToNoSlip()
	self.scroll:removeAllChildren()
	self:setScrollData()

	self._sc = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dTime)
		self._timeTick = self._timeTick + dTime
		if self._timeTick >= 3.0 then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._sc)
			g_i3k_ui_mgr:CloseUI(eUIID_DefenceWarExpTips)
		end
	end, 0.1, false)
end

function wnd_defenceWarExpTips:setScrollData()
	local lightTime = g_i3k_game_context:getDefenceWarCityLightTime()
	local cityID = g_i3k_game_context:getDefenceWarCityCity()

	local cityName = i3k_db_defenceWar_city[cityID].name
	local blessAdd = g_i3k_game_context:getDefenceWarExpAddRate() / 100
	local remainTime = self:getRemainTime(lightTime)

	local widget = require(LAYER_BUFFTIPS3T)()
	widget.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(7395))
	widget.vars.des:setText(i3k_get_string(5312, cityName, blessAdd, remainTime))
	widget.vars.des:setRichTextFormatedEventListener(function(sender)
		local nheight = widget.vars.des:getInnerSize().height
		local tSizeH = widget.vars.des:getSize().height

		local size = widget.rootVar:getContentSize()
		widget.vars.root:setPositionInScroll(self.scroll, size.width / 2, nheight > tSizeH and (nheight + 10) / 2 or (tSizeH + 10) / 2)

 		local bgwidth = self.bg:getContentSize().width
		self.bg:setContentSize(bgwidth, nheight > tSizeH and nheight + 15 or tSizeH + 15)
		widget.vars.des:setRichTextFormatedEventListener(nil)
	end)
	self.scroll:addItem(widget)
end

function wnd_defenceWarExpTips:getRemainTime(endTime)
	local timeNow = i3k_game_get_time()
	local remainTime = endTime - timeNow
	if remainTime <= 0 then
		return string.format("%d秒", 0)
	end
	if remainTime < 60 then --小于1分钟
		local sec = remainTime
		return string.format("%d秒", sec)
	elseif remainTime < 60*60 then --小于1小时
		local min =  math.floor(remainTime/60)
		return string.format("%d分", min)
	elseif remainTime < 60*60*24 then --小于1天
		local hour =  math.floor(remainTime/60/60)
		local min =  math.floor(remainTime/60) - hour * 60
		return string.format("%d小时%d分", hour, min)
	else
		local day =  math.floor(remainTime/60/60/24)
		return string.format("%d天", day)
	end
end

function wnd_defenceWarExpTips:onHide()
	if self._sc then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._sc)
		self._sc = nil
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_defenceWarExpTips.new()
	wnd:create(layout, ...)
	return wnd;
end
