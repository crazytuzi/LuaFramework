
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_defenceWarResult = i3k_class("wnd_defenceWarResult",ui.wnd_base)

local CAPTURE_ICONS 	= 7015
local WINFAIL_ICONS 	= 7041
local FAIL_ICONS 		= 7028
local HOLDSUC_ICONS 	= 7030
local HOLDFAIL_ICONS 	= 7029

function wnd_defenceWarResult:ctor()
	self._timeCounter = 0
	--离开倒计时
	self._exitTime = 10
end

function wnd_defenceWarResult:configure()
	local widgets = self._layout.vars
	widgets.exitBtn:onClick(self, function()
		i3k_sbean.mapcopy_leave()
	end)
end

function wnd_defenceWarResult:refresh(info)
	self._layout.vars.leftTime:setText(i3k_get_format_time_to_show(self._exitTime))
	self:updateResultInfo(info)
end

function wnd_defenceWarResult:updateResultInfo(info)
	local widgets = self._layout.vars

	local sect = info.sect
	local useTime = info.useTime
	local cityID = info.cityId
	local isPvp = info.isPvp

	local factionId = g_i3k_game_context:GetFactionSectId()
	local fightTime = i3k_db_defenceWar_cfg.fightTotalTime

	local descText = ""
	local imgID = 0
	local cityName = i3k_db_defenceWar_city[cityID].name
	local timeStr = i3k_get_time_show_text_simple(useTime)
	if isPvp == 0 then  --PVE占城阶段
		if sect then
			if sect.sectId == factionId then
				descText = i3k_get_string(5313, cityName, timeStr)
				imgID = CAPTURE_ICONS
			else
				descText = i3k_get_string(5314, sect.name, cityName, timeStr)
				imgID = WINFAIL_ICONS
			end
		else
			descText = i3k_get_string(5199, cityName) --截止活动结束，没有帮派夺取%s的所有权，请继续努力
			imgID = FAIL_ICONS
		end
	else
		--说明守城方失败
		if useTime < fightTime then
			if sect.sectId == factionId then
				descText = i3k_get_string(5315, cityName, timeStr)
				imgID = CAPTURE_ICONS
			else
				local forceType = g_i3k_game_context:GetForceType()
				if forceType == 1 then  --守城方
					descText = i3k_get_string(5241) --很遗憾，我们丢失了城池，下次继续努力
					imgID = HOLDFAIL_ICONS
				else
					descText = i3k_get_string(5316, cityName)
					imgID = WINFAIL_ICONS
				end
			end
		else
			if sect.sectId == factionId then
				descText = i3k_get_string(5240) --我方获得了守城的胜利，可以继续占用城池
				imgID = HOLDSUC_ICONS
			else
				descText = i3k_get_string(5317, cityName)
				imgID = WINFAIL_ICONS
			end
		end
	end

	widgets.desc:setText(descText)
	widgets.titleImg:setImage(g_i3k_db.i3k_db_get_icon_path(imgID))
end

function wnd_defenceWarResult:onUpdate(dTime)
	self._timeCounter = self._timeCounter + dTime
	if self._timeCounter > 1 then
		self._exitTime = self._exitTime - 1
		self._layout.vars.leftTime:setText(i3k_get_format_time_to_show(self._exitTime))
		if self._exitTime <= 0 then
			i3k_sbean.mapcopy_leave(eUIID_DefenceWarResult)
		end
		self._timeCounter = 0
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_defenceWarResult.new()
	wnd:create(layout, ...)
	return wnd;
end
