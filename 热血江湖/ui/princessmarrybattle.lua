-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_princessMarryBattle = i3k_class("wnd_princessMarryBattle", ui.wnd_base)

local UISHOWTYPE_START = 1
local UISHOWTYPE_BOSS = 2
local UISHOWTYPE_MONSTER = 3
local UISHOWTYPE_REPAIR = 4
local UISHOWTYPE_FINAL = 5
local UISHOWTYPE_DESTROY = 6

local CHECKDISTANCETIME = 3
local SENDMESSAGETIME = 1

function wnd_princessMarryBattle:ctor()
	self._refreshTargetFun = {}
	self._curUIType = 0
	self._animFlag = true
	self._checkTime = CHECKDISTANCETIME
	self._startText = nil
	self._cfg = nil 
	self._startStageTime = 0
	self._sendMessageTime = SENDMESSAGETIME
	self._rankFlag = false
	self._listPercent = 0 	
end

function wnd_princessMarryBattle:configure()
	local widget = self._layout.vars
	widget.closeBtn:onClick(self, self.onCloseAnisBtn)
	widget.openBtn:onClick(self, self.onOpenAnisBtn)
	widget.scoreBtn:onClick(self, self.onScoreBtn)
	widget.rankBt:onClick(self, self.onRankBtn)
	widget.findwaybt:onClick(self, self.onGotoBtn)
	self._startText = widget.time_label2
	self._remindImage = widget.remindImage
	self._anis = self._layout.anis.c_jt
	self._rankScoll = widget.task_scroll
	
	self._refreshTargetFun = 
	{
		[UISHOWTYPE_START] = self.refreshStartText,
		[UISHOWTYPE_BOSS] = self.refreshBossText,
		[UISHOWTYPE_MONSTER] = self.refreshMonsterText,
		[UISHOWTYPE_REPAIR] = self.refreshRepairText,
		[UISHOWTYPE_FINAL] = self.refreshBossText,
		[UISHOWTYPE_DESTROY] = self.refreshBossText,
	}
end

function wnd_princessMarryBattle:refresh()
	self:refreshTaskText()
	self:refreshScoreText()
	self:updateBossBlood()
end

function wnd_princessMarryBattle:refreshTaskText()
	local widget = self._layout.vars
	local groupId, eventId = g_i3k_game_context:getPrincessMarryStage()
	local cfg = g_i3k_db.i3k_db_get_princess_marry_eventConfig(groupId, eventId)
	
	if not cfg then
		return
	end
	
	local uitype = cfg and cfg.uishowType or 3
	self._curUIType = uitype
	self._cfg = cfg
	local remain = cfg.showTips == 1
	
	if not remain then
		widget.remindImage:hide()
	end
	
	if self._rankFlag then return end
	self._rankScoll:removeAllChildren()
	widget.start:setVisible(uitype == UISHOWTYPE_START)
	widget.other:setVisible(uitype ~= UISHOWTYPE_START)
	widget.finalText:setVisible(uitype == UISHOWTYPE_FINAL)
	widget.gatherName:setVisible(uitype == UISHOWTYPE_REPAIR)
	widget.gatherValue:setVisible(uitype == UISHOWTYPE_REPAIR) 
	self._refreshTargetFun[uitype](self)
		
	
end

function wnd_princessMarryBattle:refreshTaskValue()
	self._refreshTargetFun[self._curUIType](self)
end

function wnd_princessMarryBattle:refreshScoreText()	
	self._layout.vars.scoreText:setText(g_i3k_game_context:getdPrincessMarryScore())
end

function wnd_princessMarryBattle:getStartLifeTime()
	local groupId = g_i3k_game_context:getPrincessMarryStage()
	
	for _, v in ipairs(i3k_db_princess_eventStage) do
		if groupId == v.groupId and v.uishowType == UISHOWTYPE_START then
			self._startStageTime = self._startStageTime + v.effectdelayTime
		end
	end
end

function wnd_princessMarryBattle:refreshStartText()
	local world = i3k_game_get_world()
	if not world or not self._cfg then return end
	
	if self._startStageTime == 0 then
		self:getStartLifeTime()
	end
	
	local worldStartTime = world:GetStartTime()
	local time = self._startStageTime / 1000 - i3k_game_get_time() + worldStartTime
	self._startText:setText(i3k_get_string(18045, i3k_get_show_rest_time(time)))
	
	if time <= 3 then
		if self._animFlag  then
			self._animFlag  = false
			g_i3k_ui_mgr:AddTask(self, {}, function(ui)
				g_i3k_ui_mgr:OpenUI(eUIID_BattleFight)
				g_i3k_ui_mgr:RefreshUI(eUIID_BattleFight)
			end, 1)		
		end
	end
end

function wnd_princessMarryBattle:refreshMonsterText()
	self._layout.vars.target:setText(i3k_get_string(18046))
end

function wnd_princessMarryBattle:refreshRepairText()
	self._layout.vars.target:setText(i3k_get_string(18047))
	self:updateRequireCount()
end

function wnd_princessMarryBattle:refreshBossText()
	if self._cfg then
		local widget = self._layout.vars
		local name = g_i3k_db.i3k_db_get_monster_name(self._cfg.taskArgs[1]) or ""
		if self._curUIType == UISHOWTYPE_DESTROY then
			widget.target:setText(i3k_get_string(18057) .. name)
		else
		widget.target:setText(i3k_get_string(18048) .. name)
		end
		
		if self._curUIType == UISHOWTYPE_FINAL then
			widget.finalText:setText(i3k_get_string(18053, name))
		end
	end
end

function wnd_princessMarryBattle:onUpdate(dTime)
	if self._curUIType ==  UISHOWTYPE_START then
		self:refreshStartText()
	end
	
	self._checkTime = self._checkTime - dTime
	self._sendMessageTime = self._sendMessageTime - dTime
	
	if self._sendMessageTime <= 0 then
		self._sendMessageTime = SENDMESSAGETIME
		i3k_sbean.princess_marry_require_pos(false, g_i3k_game_context:GetWorldMapID())
		
		if self._rankFlag then
			self._listPercent = self._rankScoll:getListPercent()
			i3k_sbean.princess_marry_require_rank()	
		end
	end
	
	if self._checkTime <= 0 then	
		self._checkTime = CHECKDISTANCETIME
		
		if self._cfg and self._cfg.showTips == 1 then
			local pos = g_i3k_game_context:getPrincessMarryPosAndRotation()
			local hero = i3k_game_get_player_hero()
		
			if not hero or not pos then
				return
			end
		
			local rolePos = g_i3k_game_context:GetPlayerPos()		
	
			if not g_i3k_game_context:Caculator(rolePos, pos, i3k_db_princess_marry.validDistance / 100) then
				if not self._remindImage:isVisible() then
					self._remindImage:show()
					self._anis.play()
				end
				
				g_i3k_ui_mgr:AddTask(self, {}, function(ui)
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18049))
				end, 1)	
			else
				if self._remindImage:isVisible() then
					self._remindImage:hide()
					self._anis.stop()
				end
			end	
		end
	end
end

function wnd_princessMarryBattle:onScoreBtn()
	self._rankFlag = false
	self._listPercent = 0 
	self:refresh()
end

function wnd_princessMarryBattle:onRankBtn()
	self._rankFlag = true
	i3k_sbean.princess_marry_require_rank()	
end

function wnd_princessMarryBattle:refreshRankLayer(ranks)
	local widget = self._layout.vars
	widget.start:setVisible(false)
	widget.other:setVisible(false)
	self._rankScoll:removeAllChildren()
	
	for _, v in ipairs(ranks) do
		local layer = require("ui/widgets/zdgongzhuchujiat")()
		local wid = layer.vars
		wid.name:setText(v.role.name)
		wid.score:setText(v.rankKey)
		self._rankScoll:addItem(layer)
	end
	
	self._rankScoll:jumpToListPercent(self._listPercent)
end

function wnd_princessMarryBattle:onGotoBtn()
	g_i3k_game_context:gotoPrincessPos()
end

function wnd_princessMarryBattle:updateRequireCount()
	local widget = self._layout.vars
	local cfg = i3k_db_resourcepoint[self._cfg.taskArgs[1]]
	local name = cfg and cfg.name or ""
	widget.gatherName:setText(i3k_get_string(18050, name))
	widget.gatherValue:setText(g_i3k_game_context:getPrincessGather() .. "/" .. self._cfg.taskArgs[2])
end

function wnd_princessMarryBattle:updateBossBlood()
	local weight = self._layout.vars
	local curHp, maxHp = g_i3k_game_context:getPrincessBlood()	
	weight.slider:setPercent(curHp / maxHp * 100)
	weight.princessHp:setText(curHp .. "/" .. maxHp)
end

function wnd_princessMarryBattle:onCloseAnisBtn()
	local widget = self._layout.vars	
	widget.closeBtn:hide()
	self._layout.anis.c_ru.play(
	function()
		widget.openBtn:show()
	end)
end

function wnd_princessMarryBattle:onOpenAnisBtn()
	local widget = self._layout.vars
	widget.openBtn:hide()
	self._layout.anis.c_chu.play(
	function()
		widget.closeBtn:show()
	end)
end

function wnd_create(layout, ...)
	local wnd = wnd_princessMarryBattle.new()
	wnd:create(layout, ...)
	return wnd;
end