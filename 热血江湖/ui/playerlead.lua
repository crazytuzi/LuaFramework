module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_playerLead = i3k_class("wnd_playerLead", ui.wnd_base)
local timeCounter = 0
local timeCounter2 = 0
local timeCounter3 = 0
local dialogueID = { 901, 902, 903, 904, 905 }
local anisList = { 20, 21, 22, 27} -- 动画id列表
local detTime = 0
-- local effectList = { 30738, 30739 } -- 指引特效id -- 已经弃用了
local guideTraps = { 3207, 3208, 3209 } -- 指引箭头

function wnd_playerLead:ctor()

end

function wnd_playerLead:configure()
	self._stage = 0
	self._jumpFlag = false
	self._addAnisAfterJump = false
	detTime = i3k_db_new_player_guide_lead[5].pauseTime
end

function wnd_playerLead:refresh(stage)
	self._stage = stage
	self:updateStage()
end

function wnd_playerLead:onShow()
	local hero = i3k_game_get_player_hero()
	hero:Play(i3k_db_common.engine.defaultStandAction, -1)
	self:hideAllGuideTraps()
end



function wnd_playerLead:onUpdate(dTime)
	if g_i3k_game_context:getStartJumpState() and not self._jumpFlag then
		timeCounter = timeCounter + dTime

		if timeCounter > detTime then
			self._jumpFlag = true
			timeCounter = 0
			local cfg = i3k_db_new_player_guide_lead[5]
			self.co = g_i3k_coroutine_mgr:StartCoroutine(function()
				while true do
					g_i3k_coroutine_mgr.WaitForNextFrame()
					g_i3k_game_handler:PauseAllEntities()
					i3k_game_pause()
					self:addSecondJumpUI(cfg.guideStr2)
					g_i3k_coroutine_mgr:StopCoroutine(self.co)
				end
			end)
		end
	end

	if self._addAnisAfterJump then
		-- 计时，然后播放动画
		timeCounter2 = timeCounter2  + dTime
		if timeCounter2 > detTime + 1 then
			timeCounter2 = 0
			self.co1 = g_i3k_coroutine_mgr:StartCoroutine(function()
				self._addAnisAfterJump = false
				g_i3k_coroutine_mgr.WaitForSeconds(0.5) --延时
				-- 二段跳落地，播放动画
				local func = function()
					local hero = i3k_game_get_player_hero()
					local targetPos = i3k_db_new_player_guide_lead[5].bossPos
					local _pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine((targetPos))));
					hero:SetPos(_pos)
					g_i3k_ui_mgr:OpenUI(eUIID_Yg)
				end
				if i3k_db_sceneFlash[anisList[2]] then
					i3k_game_play_scene_ani(anisList[2], func)
				end
				g_i3k_coroutine_mgr:StopCoroutine(self.co1)
			end)
		end
	end
	timeCounter3 = timeCounter3 + dTime
	if timeCounter3 > 1 then
		self:onSecondTask(dTime)
		timeCounter3 = 0
	end
end

function wnd_playerLead:onSecondTask(dTime)
	self:logHeroPos(dTime)
end

function wnd_playerLead:updateCoordInfo(coord)
	if self._stage == 5 and self:sqrtValue(coord) then
		local cfg = i3k_db_new_player_guide_lead[self._stage]
		local hero = i3k_game_get_player_hero()
		local targetPos = i3k_db_new_player_guide_lead[5].centerPos
		local faceTo = i3k_db_new_player_guide_lead[5].forceFaceTo -- {x = 0.0, y = -190.0, z = 0.0 }--
		-- g_i3k_ui_mgr:PopupTipMessage(coord.x .." ".. coord.z .. " | ".. targetPos.x .. " "..targetPos.z)
		g_i3k_ui_mgr:CloseUI(eUIID_Yg)
		hero:StopMove()
		-- 清空轻功CD
		local hero_id = hero._id
		local qinggongId = i3k_db_new_player_guide_init[hero_id].dodgeSkill
		hero:SetSkillCoolTick(qinggongId, 0)
		g_i3k_game_context:SetMoveState(false)
		local _pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine((targetPos))));
		-- hero:SetPos(_pos)
		hero:SetFaceDir(faceTo.x, faceTo.y, faceTo.z)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "showGundongBtn", true)
		self:addGuideUI(cfg.guideStr)
	end
end

function wnd_playerLead:sqrtValue(coord)
	local trigerLen = i3k_db_new_player_guide_lead[5].trigerLength / 100 -- 转换成“米”为单位
	local targetPos = i3k_db_new_player_guide_lead[5].centerPos
	local a = targetPos.x
	local b = targetPos.z
	local x = coord.x
	local z = coord.z
	return trigerLen * trigerLen > math.abs((a - x)*(a - x) + (b - z)*(b - z))
end

function wnd_playerLead:updateStage()
	local widget = self._layout.vars
	local model = widget.model
	local baseStage = 0
	local stage = self._stage
	self:hideAllWidgets()
	local cfg = i3k_db_new_player_guide_lead[stage]
	if stage == baseStage + 1 then
		g_i3k_ui_mgr:CloseUI(eUIID_Yg)
		local hero = i3k_game_get_player_hero()
		local faceTo = i3k_db_new_player_guide_lead[1].forceFaceTo
		hero:SetFaceDir(faceTo.x, faceTo.y, faceTo.z) --初始朝向
		-- self:addDialogue(stage)
		local func = function()
			g_i3k_ui_mgr:OpenUI(eUIID_Yg)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_PlayerLead, "closeDialogue1Callback", 1)
		end
		if i3k_db_sceneFlash[anisList[4]] then
			i3k_game_play_scene_ani(anisList[4], func)
		end
	elseif stage == baseStage + 2 then
		self:addDialogue(stage)
	elseif stage == baseStage + 3 then
		self:addGuideUIWithoutMask(eUIID_BattleBase, "skill1")
	elseif stage == baseStage + 4 then
			if g_i3k_ui_mgr:GetUI(eUIID_GuideUI) then
				g_i3k_ui_mgr:CloseGuideUI()
			end

			local fun = function()
				i3k_game_resume()
                g_i3k_game_handler:ResumeAllEntities()
				local cfg = i3k_db_new_player_guide_lead[4]
				self:addGuideUIFirstJump(cfg.guideStr)
			end
			self:pauseAfterPlayAnis(anisList[1], fun)
	elseif stage == baseStage + 5 then
		local eventID = "引导关ID"
		DCEvent.onEvent("引导关", { eventID = 7})
		local world = i3k_game_get_world();
		world:OnManualReleaseTrap(3202)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "showGundongBtn", false)
		g_i3k_ui_mgr:CloseGuideUI()
		self:showGuideTrap(3)
	end
end

function wnd_playerLead:hideAllWidgets()
	local widget = self._layout.vars
	widget.leftRoot:hide()
	widget.rightRoot:hide()
end

-- 隐藏新手关地图里所有的坐标指引
function wnd_playerLead:hideAllGuideTraps()
	local world = i3k_game_get_world();
	for i,v in ipairs(guideTraps) do
		world:OnHideTrap(v, false) -- 隐藏
	end
	self:showGuideTrap(1) -- 3207 地图指引 一开始就有
end

function wnd_playerLead:showGuideTrap(id)
	local world = i3k_game_get_world();
	world:OnHideTrap(guideTraps[id], true) -- 显示
end

function wnd_playerLead:pauseGameWithDelay(callback)
	self.co2 = g_i3k_coroutine_mgr:StartCoroutine(function()
		local time = 0.1
		g_i3k_coroutine_mgr.WaitForSeconds(time) --延时
		g_i3k_game_handler:PauseAllEntities()
		i3k_game_pause()
		g_i3k_coroutine_mgr:StopCoroutine(self.co2)
		if callback then
			callback()
		end
	end)
end

-- InvokeUIFunction 对白关闭后，调用的方法，增加无遮罩的引导
function wnd_playerLead:closeDialogue1Callback( callbackStage )
	if callbackStage == 1 then
		local eventID = "引导关ID"
		DCEvent.onEvent("引导关", { eventID = 1})
		self:addGuideUIWithDelay(eUIID_Yg, "direct")
	elseif callbackStage == 2 then
		local eventID = "引导关ID"
		DCEvent.onEvent("引导关", { eventID = 3})
		self:addGuideUIWithoutMask(eUIID_BattleBase, "attack")
	elseif callbackStage == 4 then -- 躲避技能
		-- local cfg = i3k_db_new_player_guide_lead[callbackStage]
		-- self:addGuideUIFirstJump(cfg.guideStr)
	elseif callbackStage == -1 then -- 点击离开
		g_i3k_game_context:sendLeavePlayerLeadProtocol()
		g_i3k_game_context:resetStartJumpStage()
	end
end

-- 移动指引，自动消失
function wnd_playerLead:addGuideUIWithDelay(eUIID, widgetName)
	local eventID = "引导关ID"
	DCEvent.onEvent("引导关", { eventID = 2})
	local cfg = i3k_db_new_player_guide_lead[self._stage]
	local text = cfg.guideStr
	local ui = g_i3k_ui_mgr:GetUI(eUIID)
	if ui then
		if not g_i3k_ui_mgr:GetUI(eUIID_GuideUI) then
			local widget = ui:GetChildByVarName(widgetName)
			local radius = 50
			local arg = widgetName == "skill1" and {index = 1} or nil
			if widget then
				local Pos = widget:getParent():convertToWorldSpace(widget:getPosition())
				g_i3k_ui_mgr:ShowGuideUIAutoClosed(Pos, 0, function ()
					widget:sendTouchClick()
				end ,text,"step",1) -- 后面3个值非空无意义
			end
		end
	end
end


function wnd_playerLead:addGuideUIWithoutMask(eUIID, widgetName)
	local cfg = i3k_db_new_player_guide_lead[self._stage]
	local text = cfg.guideStr
	local ui = g_i3k_ui_mgr:GetUI(eUIID)
	if ui then
		if not g_i3k_ui_mgr:GetUI(eUIID_GuideUI) then
			local widget = ui:GetChildByVarName(widgetName)
			local radius = 50
			if widgetName == "attack" then
				local eventID = "引导关ID"
				DCEvent.onEvent("引导关", { eventID = 4})
				radius = 75
			end
			local arg = widgetName == "skill1" and {index = 1} or nil
			local eventID = "引导关ID"
			DCEvent.onEvent("引导关", { eventID = 5})
			if widget then
				local Pos = widget:getParent():convertToWorldSpace(widget:getPosition())
				g_i3k_ui_mgr:ShowGuideUIWithoutMask(Pos, radius, function ()
					if arg then
						widget:sendTouchClickWithArgs(arg)
					else
						widget:sendTouchClick()
					end
				end,text,"step",1) -- 后面3个值非空无意义
			end
		end
	end
end

-- 第一次轻功引导
function wnd_playerLead:addGuideUIFirstJump(text)
	local eventID = "引导关ID"
	DCEvent.onEvent("引导关", { eventID = 6})
	self.co3 = g_i3k_coroutine_mgr:StartCoroutine(function()
		-- g_i3k_coroutine_mgr.WaitForSeconds(0.5) --延时
		-- local hero = i3k_game_get_player_hero()
		-- local faceTo = i3k_db_new_player_guide_lead[4].forceFaceTo
		-- hero:SetFaceDir(faceTo.x, faceTo.y, faceTo.z) --初始朝向
		local ui = g_i3k_ui_mgr:GetUI(eUIID_BattleBase)
		if ui then
			if not g_i3k_ui_mgr:GetUI(eUIID_GuideUI) then
				local widget = ui:GetChildByVarName("gundong")
				if widget then
					local Pos = widget:getParent():convertToWorldSpace(widget:getPosition())
					g_i3k_ui_mgr:ShowGuideUIWithoutMask(Pos, 50, function ()
						widget:sendTouchClick(
						-- g_i3k_game_context:resumePausedGame()
					)
					end,text,"step",1) -- 后面两个值非空无意义
				end
			end
		end
		-- g_i3k_game_handler:PauseAllEntities()
		-- i3k_game_pause()
		g_i3k_coroutine_mgr:StopCoroutine(self.co3)
	end)
end

-- 轻功二段跳第一次引导
function wnd_playerLead:addGuideUI(text)
	local eventID = "引导关ID"
	DCEvent.onEvent("引导关", { eventID = 8})
	local ui = g_i3k_ui_mgr:GetUI(eUIID_BattleBase)
	if ui then
		if not g_i3k_ui_mgr:GetUI(eUIID_GuideUI) then
			local widget = ui:GetChildByVarName("gundong")
			if widget then
				local Pos = widget:getParent():convertToWorldSpace(widget:getPosition())
				g_i3k_ui_mgr:ShowGuideUI(Pos, 50, function ()
					widget:sendTouchClick(
					g_i3k_game_context:setStartJumpState(true)
				)
					g_i3k_game_context:SetMoveState(true)
				end,text,"step",1) -- 后面两个值非空无意义
			end
		end
	end
end

-- 轻功二段跳第二次引导
function wnd_playerLead:addSecondJumpUI(text)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "showGundongBtn", true)
	local ui = g_i3k_ui_mgr:GetUI(eUIID_BattleBase)
	if ui then
		if not g_i3k_ui_mgr:GetUI(eUIID_GuideUI) then
			local widget = ui:GetChildByVarName("gundong")
			if widget then
				local Pos = widget:getParent():convertToWorldSpace(widget:getPosition())
				g_i3k_ui_mgr:ShowGuideUI(Pos, 50, function ()
					widget:sendTouchClick(
					g_i3k_game_context:setStartJumpState(false)
				)
					g_i3k_game_context:SetMoveState(true)
				end,text,"step",1) -- 后面两个值非空无意义
			end
		end
	end
end

-- 在二段跳结束之后，设置一个状态，开始计时到落地，播放动画
function wnd_playerLead:setAddAnisAfterJump(bValue)
	self._addAnisAfterJump = bValue
end

function wnd_playerLead:addDialogue(stage)
	local id = dialogueID[stage]
	local desc = i3k_db_dialogue[id][1].txt
	self.co4 = g_i3k_coroutine_mgr:StartCoroutine(function()
		g_i3k_coroutine_mgr.WaitForSeconds(0.5) --延时
		g_i3k_ui_mgr:OpenUI(eUIID_Dialogue1)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Dialogue1, "playerLead", desc, stage)
		if stage ~= 1 then
			g_i3k_game_handler:PauseAllEntities()
			i3k_game_pause()
		end
		g_i3k_coroutine_mgr:StopCoroutine(self.co4)
	end)
end

function wnd_playerLead:addLastBossAndAnis()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "showGundongBtn", false)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleBossHp)
	local eventID = "引导关ID"
	DCEvent.onEvent("引导关", { eventID = 9})

	local fun = function()
		g_i3k_game_handler:ResumeAllEntities()
		i3k_game_resume()
		--最后boss需要改变视角，杀死之后恢复视角
		self:UpdateBossCamera()
		self:addLastBossBlocks()
	end
	self:pauseAfterPlayAnis(anisList[3], fun)
end

function wnd_playerLead:UpdateBossCamera()
	local hero = i3k_game_get_player_hero()
	hero:DetachCamera()

	local camera = i3k_db_new_player_guide_cfg.camera;
	g_i3k_mmengine:UpdateCamera2("MainCamera", i3k_vec3_to_engine(camera.dir), i3k_vec3_to_engine(camera.right), i3k_vec3_to_engine(camera.pos));
	-- 打boss设置玩家坐标
	local targetPos = i3k_db_new_player_guide_cfg.lastBossPos.pos
	local _pos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine((targetPos))));
	hero:SetPos(_pos)
	local x = _pos.x
	local y = _pos.y
	local z = _pos.z
	i3k_log("playerLead.UpdateBossCamera: x="..x.."| y="..y.."| z="..z)
end

-- 在最后的boss哪里添加阻挡
function wnd_playerLead:addLastBossBlocks()
	local block = require("logic/battle/i3k_dyn_obstacle");
	local trapCfg = i3k_db_traps_base[35]
	local modelId = trapCfg.modelID
	local modelPath = i3k_db_models[modelId].path

	for i = 1, 5 do
		local cfg = i3k_db_new_player_guide_cfg.blocks[i]
		local pos = cfg.pos
		local dir = cfg.dir
		local type = trapCfg.obstacleType
		local args = trapCfg.obstacleArgs
		block.i3k_dyn_obstacle:Create(modelPath, pos, dir, type, args)
	end
end


function wnd_playerLead:onLeavePlayerLead()
	local eventID = "引导关ID"
	DCEvent.onEvent("引导关", { eventID = 10})
	local desc = i3k_db_dialogue[905][1].txt
	g_i3k_ui_mgr:OpenUI(eUIID_Dialogue1)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Dialogue1, "playerLead", desc)
	g_i3k_game_context:onKillLastPlayerLeadBoss()
	g_i3k_game_context:setLeavePlayerLeadPlayAnisFlag(true)
	self.co6 = g_i3k_coroutine_mgr:StartCoroutine(function()
		g_i3k_coroutine_mgr.WaitForSeconds(5) --延时
		g_i3k_game_context:addLeaveDialogue()
		g_i3k_coroutine_mgr:StopCoroutine(self.co6)
	end)
end

-------------------- 优化部分封装的函数-------------------------
-- 先播放动画，然后在播放动画的过程中暂停逻辑,最后执行回调函数
function wnd_playerLead:pauseAfterPlayAnis(anisID, callbackFunc)
	self.co7 = g_i3k_coroutine_mgr:StartCoroutine(function()
		if i3k_db_sceneFlash[anisID] then
			g_i3k_coroutine_mgr.WaitForSeconds(0.5);
			g_i3k_effect_mgr:StopAll()
			g_i3k_game_handler:PauseAllEntities()
			i3k_game_pause()
			i3k_game_play_scene_ani(anisID, callbackFunc)
		end
		g_i3k_coroutine_mgr:StopCoroutine(self.co7)
	end)
end

------------------debug functions-------------------------

function wnd_playerLead:logHeroPos(dTime)
	local hero = i3k_game_get_player_hero()
	local x = hero._curPosE.x
	local y = hero._curPosE.y
	local z = hero._curPosE.z
	i3k_log("playerLead: x="..x.."| y="..y.."| z="..z)
end

--------------------------------------------------------

function wnd_create(layout)
	local wnd = wnd_playerLead.new();
		wnd:create(layout);
	return wnd;
end
