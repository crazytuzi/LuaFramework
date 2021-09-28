-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_magicMachineBattle = i3k_class("wnd_magicMachineBattle", ui.wnd_base)
local MYSCORE = 0 --我的积分
local SCORETYPEMOVE = 1
local SCORETYPETOWER = 2
local SCORETYPEKILL = 3

function wnd_magicMachineBattle:ctor()
	self._des = 
	{
		[MYSCORE] = 18126,
		[SCORETYPEMOVE] = 18127,
		[SCORETYPETOWER] = 18128,
		[SCORETYPEKILL] = 18129,
	}
	
	self._time = 0
	self._moveScore = 0
end

function wnd_magicMachineBattle:configure()
	local widget = self._layout.vars
	widget.reverseBt:onClick(self, self.onReverseBt)
end

function wnd_magicMachineBattle:refresh()
	self:initScoll()
	self:refreshScoll()
	self:refreshInfoTxt()
	self:refreshMachineTime()
	self:refreshTipTxt()
end

function wnd_magicMachineBattle:initScoll()
	local widget = self._layout.vars
	widget.scoll:removeAllChildren()
	
	for i = MYSCORE, SCORETYPEKILL do	
		local layer = require("ui/widgets/zdshenjizanghait")()
		local wid = layer.vars
		wid.des:setText(i3k_get_string(self._des[i], 0))
		widget.scoll:addItem(layer)
	end
end

function wnd_magicMachineBattle:refreshScoll()
	local scoreInfo = g_i3k_game_context:getMagicMachineScorInfo()	
	if not scoreInfo then return end
	local widget = self._layout.vars	
	widget.scoll:removeAllChildren()
	
	for i = MYSCORE, SCORETYPEKILL do
		local layer = require("ui/widgets/zdshenjizanghait")()
		local wid = layer.vars
		local score = 0	
		
		if i == MYSCORE then
			score = self:getMyScore(scoreInfo)
		else
			score = scoreInfo[i] or 0
		end
	
		wid.des:setText(i3k_get_string(self._des[i], score))
		widget.scoll:addItem(layer)
	end
	
	self._moveScore = scoreInfo[SCORETYPEMOVE] or 0
end

function wnd_magicMachineBattle:getMyScore(scoreInfo)
	local scores = 0
	
	for _, v in pairs(scoreInfo) do
		if v then
			scores = scores + v
		end
	end
	
	return scores
end

function wnd_magicMachineBattle:refreshInfoTxt()
	local widget = self._layout.vars
	local areaId = g_i3k_game_context:gethCurMagicMachineArena()
	local cfg = i3k_db_magic_machine_area[areaId]
	
	if cfg then
		widget.areaTxt:setText(cfg.tips)
		widget.areaRoot:setVisible(true)
	else
		widget.areaRoot:setVisible(false)
	end
end

function wnd_magicMachineBattle:refreshTipTxt()
	local widget = self._layout.vars
		
	if self._time <= 0 or self._moveScore ~=  0 then
		widget.coutRoot:hide()
		return
	end
	
	widget.count:setText(i3k_get_string(18130, math.ceil(self._time)))
	widget.coutRoot:show()
end

function wnd_magicMachineBattle:refreshMachineTime()
	local info = g_i3k_game_context:gethMagicMachineInfo()
	local flag = info and info.npcStartTime and info.route
		
	if not flag then
		return 
	end
	
	local cfg = i3k_db_move_road_points[info.route]
	
	if not cfg then
		return
	end
	
	self._time = math.max((cfg.extTime + info.npcStartTime - i3k_game_get_time()), 0)
end

function wnd_magicMachineBattle:onUpdate(dTime)
	if self._time > 0 then
		self._time = math.max((self._time - dTime), 0)
		self:refreshTipTxt()
	end
end

function wnd_magicMachineBattle:onReverseBt()
	if g_i3k_game_context:IsInFightTime() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1310))
		return
	end
	
	local fun = (function(ok)
		if ok then
			i3k_sbean.magic_machine_reverse_pos()	
		end
	end)
		
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(18131), fun)
end

function wnd_create(layout, ...)
	local wnd = wnd_magicMachineBattle.new()
	wnd:create(layout, ...)
	return wnd;
end
