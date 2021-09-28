module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battleProcessBar = i3k_class("wnd_battleProcessBar", ui.wnd_base)
function wnd_battleProcessBar:ctor()
	self.args = 0
	self.flag = 0
	self.cancel = nil
	self.itemID = nil
	self.taskCat = nil
end
function wnd_battleProcessBar:configure()
    --采集相关界面
	local dig = {}
	dig.Digingpanel = self._layout.vars.DigingPanel
	dig.Digtipstext = self._layout.vars.Digtipstext
    self._widgets = {}
	self._widgets.dig = dig
	self._mineactiontime = 0
	self.isplayed = false
	self._layout.vars.Digcancel:onClick(self, self.onCancelClick)
end

function wnd_battleProcessBar:refresh(flag,args,cancel, itemID, taskCat)
	if flag and args then
		self.flag = flag
		self.args = args
	end
	self.cancel = cancel
	self.itemID = itemID
	self.taskCat = taskCat
	self:onUseItemAtPosition(cancel)
end

function wnd_battleProcessBar:onUpdate(dTime)
	self:onUpdateMine(dTime)
end

function wnd_battleProcessBar:onUseItemAtPosition(cancel)
	g_i3k_game_context:StopMove()
	if cancel == false then
		self._layout.vars.Digcancel:hide()
	end
	self._widgets.dig.Digingpanel:show()
	self._widgets.dig.Digtipstext:setText("使用中... ...")
	if self.flag == 1 then
		
		local world = i3k_game_get_world()
		if world._mapType == g_Life then
			local petID = g_i3k_game_context:GetLifeTaskRecorkPetID()
			if petID ~= 0 then
				local data = g_i3k_game_context:getLifeIdAndValueBytype(petID)
				local cfg = i3k_db_from_task[petID][data.id]
				g_i3k_game_context:CheckSceneTriggerEffect(cfg, SCENE_EFFECT_CONDITION.mining)
			end
		elseif world._mapType == g_BIOGIAPHY_CAREER then
			local id, value, state = g_i3k_game_context:getBiographyTask()
			if id ~= 0 then
				local careerId = g_i3k_game_context:getCurBiographyCareerId()
				local cfg = i3k_db_wzClassLand_task[careerId][id]
				g_i3k_game_context:CheckSceneTriggerEffect(cfg, SCENE_EFFECT_CONDITION.mining)
			end
		else
			local mId = g_i3k_game_context:getMainTaskIdAndVlaue()
			local main_task_cfg = g_i3k_db.i3k_db_get_main_task_cfg(mId)
			if main_task_cfg.type == g_TASK_COLLECT and g_i3k_game_context:getMineTaskType() == TASK_CATEGORY_MAIN then
				g_i3k_game_context:CheckSceneTriggerEffect(main_task_cfg, SCENE_EFFECT_CONDITION.mining)
			end
		end
		local MineInfo = g_i3k_game_context:GetMineInfo()
		local descText = MineInfo._gcfg.ShowTips
		self._widgets.dig.Digtipstext:setText(descText)
		if MineInfo._gcfg.heartWordID then
			local heartWord = i3k_db_dialogue[MineInfo._gcfg.heartWordID][1].txt
			g_i3k_ui_mgr:AddTask(self, {}, function(ui)
				if g_i3k_game_context:IsMineBubbleCanShow() then
					g_i3k_game_context:RecordMineBubbleLastTime()
					g_i3k_ui_mgr:PopTextBubble(true, i3k_game_get_player_hero(), heartWord)
				end
			end, i3k_db_common.mineBubbleDelay * 100)
		end
	elseif self.flag == 3 then
		local MineInfo = g_i3k_game_context:GetMineInfo()
		local descText = MineInfo._gcfg.ShowTips
		self._widgets.dig.Digtipstext:setText(descText)
	end
end

function wnd_battleProcessBar:onUpdateMine(dTime)
	local MineInfo = g_i3k_game_context:GetMineInfo()
	local loadingbar = self._layout.vars.Digloadingbar
	if self.flag == 1 then
		self._mineactiontime = self._mineactiontime + dTime*1000
		if self._mineactiontime < MineInfo._gcfg.ActionTime then
			loadingbar:setPercent((self._mineactiontime/MineInfo._gcfg.ActionTime)*100)
		else
			loadingbar:setPercent(100)
			self.flag = 0
		end
	elseif self.flag == 2 then
		self._mineactiontime = self._mineactiontime + dTime*100;
		loadingbar:setPercent(self._mineactiontime)
		local percent = loadingbar:getPercent()
		
		if percent == 100 and not self.isplayed then
			self.flag = 0
			self._mineactiontime = 0
			loadingbar:setPercent(0)
			self:UseTaskItem()

			g_i3k_coroutine_mgr:StartCoroutine(function() --使用协程
				g_i3k_coroutine_mgr.WaitForNextFrame()
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleProcessBar, "playEffect")
				g_i3k_ui_mgr:CloseUI(eUIID_BattleProcessBar)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"onUpdateBatterEquipShow") -- 进度条之后检测有无新装备
			end)
		end
	elseif self.flag == 3 then
		self._mineactiontime = self._mineactiontime + dTime*100;
		loadingbar:setPercent(self._mineactiontime)
		local percent = loadingbar:getPercent()
		
		if percent == 100 then
			self.flag = 0
			self._mineactiontime = 0
			loadingbar:setPercent(0)

			g_i3k_coroutine_mgr:StartCoroutine(function() --使用协程
				g_i3k_coroutine_mgr.WaitForNextFrame()
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleProcessBar, "startPlaceSceneMine")
				g_i3k_ui_mgr:CloseUI(eUIID_BattleProcessBar)
			end)
		end
	end
end

function wnd_battleProcessBar:startPlaceSceneMine()
	g_i3k_game_context:playPlayerStandAction()
	local mineTaskInfo = g_i3k_game_context:getMineTaskInfo()
	if mineTaskInfo then
		i3k_sbean.task_log_point(mineTaskInfo.taskPointId, mineTaskInfo.index)
	end
end

function wnd_battleProcessBar:playEffect()
	self.isplayed = true
	if self.taskCat == TASK_CATEGORY_MAIN then
		local mId = g_i3k_game_context:getMainTaskIdAndVlaue()
		local main_task_cfg = g_i3k_db.i3k_db_get_main_task_cfg(mId)
		g_i3k_game_context:CheckSceneTriggerEffect(main_task_cfg, SCENE_EFFECT_CONDITION.useItem)
	elseif self.taskCat == i3k_get_MrgTaskCategory() then
		local data = g_i3k_game_context:GetMarriageTaskData()
		local cfg = g_i3k_db.i3k_db_marry_task(data.id, data.groupID)
	elseif self.taskCat == TASK_CATEGORY_LIFE then
		local petID = g_i3k_game_context:GetLifeTaskRecorkPetID()
		if petID ~= 0 then
			local data = g_i3k_game_context:getLifeIdAndValueBytype(petID)
			local id = data.id == 0 and 1 or data.id
			local cfg = i3k_db_from_task[petID][id]
			g_i3k_game_context:CheckSceneTriggerEffect(cfg, SCENE_EFFECT_CONDITION.useItem)
		end
	elseif self.taskCat == TASK_CATEGORY_SUBLINE then
	end
	if not self.itemID then
		return
	end
	local daojudata = g_i3k_db.i3k_db_get_other_item_cfg(self.itemID)
	if not daojudata then
		return
	end
	
	local effectId = daojudata.args1
	if effectId and effectId >= 0 then
		local posx = daojudata.args2
		local posy = daojudata.args3
		local posz = daojudata.args4
		local pos = nil
		if posx ==0 and posy==0 and posz == 0 then
			local logic	= i3k_game_get_logic()
			local player = logic:GetPlayer()
			local rolePos = player:GetHeroPos()
			pos = {x = rolePos.x/100,y = rolePos.y/100,z = rolePos.z/100}
		else
			pos = {x = posx,y = posy,z = posz}
		end
		if pos then
			g_i3k_logic:PlaySceneEffect(effectId,pos)
		end
	end
end

function wnd_battleProcessBar:UseTaskItem()
	local data = i3k_sbean.task_useitem_req.new()
	data.ItemId = self.itemID
	data.taskCat = self.taskCat
	i3k_game_send_str_cmd(data,i3k_sbean.task_useitem_res.getName())
end

function wnd_battleProcessBar:onCancelClick(sender)
	if self.flag == 1 then
		local hero = i3k_game_get_player_hero()
		if hero then
			hero:DigMineCancel()
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"onUpdateBatterEquipShow") -- 进度条之后检测有无新装备
	elseif self.flag == 3 then
		g_i3k_game_context:playPlayerStandAction()
	end
	g_i3k_ui_mgr:CloseUI(eUIID_BattleProcessBar)
end


function wnd_create(layout)
	local wnd = wnd_battleProcessBar.new();
		wnd:create(layout);
	return wnd;
end
