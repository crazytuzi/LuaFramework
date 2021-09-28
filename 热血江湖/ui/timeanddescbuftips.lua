module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_timeAndDescBuffTips = i3k_class("wnd_timeAndDescBuffTips",ui.wnd_base)
local LAYER_BUFFTIPS3T = "ui/widgets/bufftips3t"
local mSecondCounter = 0
function wnd_timeAndDescBuffTips:ctor()
	self._sc = nil
	self._timeTick = 0
end

function wnd_timeAndDescBuffTips:configure()
	self.scroll = self._layout.vars.scroll
	self.bg = self._layout.vars.bg
	self.root = self._layout.vars.root
end

function wnd_timeAndDescBuffTips:refresh(pos, icon, desc, endTime)
	local posX = pos.x - 20
	local posY = isOther and pos.y - 20 or pos.y + 20
	self.root:setPosition(posX, posY)

	self.scroll:stateToNoSlip()
	self.scroll:removeAllChildren()
	self:setScrollData(icon, desc, endTime)
end

function wnd_timeAndDescBuffTips:setScrollData(icon, desc, endTime)
	local remainTime = self:getRemainTime(endTime)

	local widget = require(LAYER_BUFFTIPS3T)()
	widget.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
	if not endTime  then
		widget.vars.des:setText(desc)
		widget.vars.icon:disable()
	else
		widget.vars.des:setText(desc.. "剩余：" .. remainTime)
	end
	self.scroll:addItem(widget)
	local nheight = widget.vars.des:getInnerSize().height
	local tSizeH = widget.vars.des:getSize().height

	local size = widget.rootVar:getContentSize()
	widget.vars.root:setPositionInScroll(self.scroll, size.width / 2, nheight > tSizeH and (nheight + 10) / 2 or (tSizeH + 10) / 2)

 	local bgwidth = self.bg:getContentSize().width
	self.bg:setContentSize(bgwidth, nheight > tSizeH and nheight + 15 or tSizeH + 15)
	
end

function wnd_timeAndDescBuffTips:onUpdate(dTime)
	mSecondCounter = mSecondCounter + dTime 
	if mSecondCounter > 3 then 
		mSecondCounter = 0
		self:closeSpirit()
	end
end

function wnd_timeAndDescBuffTips:closeSpirit()
	g_i3k_ui_mgr:AddTask(self, {}, function(ui)
		g_i3k_ui_mgr:CloseUI(eUIID_TimeAndDescBuffTips)
	end, 1)
end

function wnd_timeAndDescBuffTips:getRemainTime(endTime)
	if not endTime then return "0秒" end
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

function wnd_create(layout, ...)
	local wnd = wnd_timeAndDescBuffTips.new()
	wnd:create(layout, ...)
	return wnd;
end
