
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_weekBoxGetTips = i3k_class("wnd_weekBoxGetTips",ui.wnd_base)

function wnd_weekBoxGetTips:ctor()

end

function wnd_weekBoxGetTips:configure()
	local widgets = self._layout.vars
	widgets.ok:onClick(self, self.onCloseUI)
end

function wnd_weekBoxGetTips:refresh(boxID, boxData)
	local widgets = self._layout.vars
	local rewardCfg = i3k_db_week_limit_reward_cfg[boxID]
	widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(rewardCfg.icon))

	local timeStr = self:getRemainTime(boxData.rewardTime)
	widgets.desc:setText(i3k_get_string(17524, rewardCfg.name, timeStr))
end

function wnd_weekBoxGetTips:getRemainTime(endTime)
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
	local wnd = wnd_weekBoxGetTips.new()
	wnd:create(layout, ...)
	return wnd;
end

