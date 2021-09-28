-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
kill_number = i3k_class("kill_number",ui.wnd_base)
local animationList = {"c_combo","c_combo2","c_combo3"}
local numList = {1192,1193,1194,1195,1196,1197,1198,1199,1200,1201}
function kill_number:ctor()
	self.kill_count = 0
	self.mapid = 0
	self._is_show = false
end

function kill_number:refresh(mapid)
	self.mapid = mapid
	local cfg = i3k_db_activity_cfg[mapid]
	if cfg then
		local groupid = cfg.groupId
		local acfg = i3k_db_activity[groupid]
		if acfg and acfg.killshow == 1 then
			self.killPanel:setVisible(true)
		end
	end
end

function kill_number:configure(...)
	local screenSize = cc.Director:getInstance():getWinSize();
	local rootSize = self._layout.root:getContentSize();
	local widget = self._layout.vars
	self.killPanel = widget.killPanel
	self.num1 = widget.num1
	self.num2 = widget.num2
	self.num3 = widget.num3
	self.num4 = widget.num4
	self.num5 = widget.num5
	self.killPanel:setVisible(false)
	self.c_ru = self._layout.anis.c_zg
end

function kill_number:showInfo(killcount)
	local cfg = i3k_db_activity_cfg[self.mapid]
	if cfg then
		local lastCount = g_i3k_game_context:GetActivityKillMaxCount(cfg.groupId,self.mapid)
		if cfg.showMax == 1 and lastCount ~= 0 and  killcount > lastCount and not self._is_show  then
			self._is_show = true
			self.c_ru.play()
		end
	end 
	local animationnum = 1
	local num2 = 0
	local num3 = 0
	if killcount >= 100 then
		num3 = math.floor(killcount/100)
		animationnum = animationnum + 1
	end
	if killcount >= 10 then
		num2 = math.floor((killcount-100*num3)/10)
		animationnum = animationnum + 1
	end
	local num1 = killcount - 100*num3 - 10 *num2
	self.num1:setImage(g_i3k_db.i3k_db_get_icon_path(numList[num3+1]))
	self.num2:setImage(g_i3k_db.i3k_db_get_icon_path(numList[num2+1]))
	self.num3:setImage(g_i3k_db.i3k_db_get_icon_path(numList[num1+1]))
	self.num4:setImage(g_i3k_db.i3k_db_get_icon_path(numList[num2+1]))
	self.num5:setImage(g_i3k_db.i3k_db_get_icon_path(numList[num1+1]))
	if killcount < 10 then
		self.num2:setImage(g_i3k_db.i3k_db_get_icon_path(numList[num1+1]))
	end

	if killcount == 10 or killcount == 100 then
		self._layout.anis[animationList[animationnum-1]].stop()
	else	
		self._layout.anis[animationList[animationnum]].stop()
	end
	self._layout.anis[animationList[animationnum]].play()

end

function kill_number:onShow()

end

function kill_number:onHide()

end

function wnd_create(layout, ...)
	local wnd = kill_number.new()
	wnd:create(layout, ...)
	return wnd
end
