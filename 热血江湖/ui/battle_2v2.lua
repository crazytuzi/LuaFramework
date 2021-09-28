-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_battle_2v2 = i3k_class("wnd_battle_2v2", ui.wnd_base)

function wnd_battle_2v2:ctor()
	
end

function wnd_battle_2v2:configure()
	
end

function wnd_battle_2v2:onShow()
	
end

function wnd_battle_2v2:refresh()
	
end

function wnd_battle_2v2:setData(results)
	local times = #results+1
	local timesLabel = {
		[1] = "第一场",
		[2] = "第二场",
		[3] = "第三场"
	}
	self._layout.vars.timesLabel:setText(timesLabel[times])
	local winTimes = 0
	local drawTimes = 0
	local loseTimes = 0
	for i,v in ipairs(results) do
		if v==0 then
			loseTimes = loseTimes + 1
		elseif v==1 then
			winTimes = winTimes + 1
		elseif v==2 then
			drawTimes = drawTimes + 1
		end
	end
	self._layout.vars.winLabel:setText(winTimes)
	self._layout.vars.loseLabel:setText(loseTimes)
	self._layout.vars.drawLabel:setText(drawTimes)
	--[[if results[1] then
		local str1 = "平"
		if results[1]==0 then
			str1 = "负"
		elseif results[1]==1 then
			str1 = "胜"
		end
		self._layout.vars.resultLabel1:setText(str1)
		if results[2] then
			local str2 = "平"
			if results[2]==0 then
				str2 = "负"
			elseif results[2]==1 then
				str2 = "胜"
			end
			self._layout.vars.resultLabel2:setText(str2)
			if results[3] then
				local str3 = "平"
				if results[3]==0 then
					str3 = "负"
				elseif results[3]==1 then
					str3 = "胜"
				end
				self._layout.vars.resultLabel3:setText(str3)
			else
				self._layout.vars.resultLabel3:setText("无")
			end
		else
			self._layout.vars.resultLabel2:setText("无")
			self._layout.vars.resultLabel3:setText("无")
		end
	else
		self._layout.vars.resultLabel1:setText("无")
		self._layout.vars.resultLabel2:setText("无")
		self._layout.vars.resultLabel3:setText("无")
	end--]]
end

function wnd_create(layout, ...)
	local wnd = wnd_battle_2v2.new()
	wnd:create(layout, ...)
	return wnd;
end
