module(..., package.seeall)
local require = require
local ui = require("ui/base");
-------------------------------------------------------
wnd_spirit_skill = i3k_class("wnd_spirit_skill", ui.wnd_base)
--计时变量
local mSecondCounter = 0
function wnd_spirit_skill:ctor()
	
end

function wnd_spirit_skill:configure()
	local widgets = self._layout.vars
	widgets.gundong2:onTouchEvent(self, self.onSpiritTouch)
	widgets.descBtn:onClick(self, self.onSkillInfo)
end

function wnd_spirit_skill:refresh()
	self:updateRoleFactionGarrisonSkill()
end



--帧事件
function wnd_spirit_skill:onUpdate(dTime)
	local world = i3k_game_get_world()
	if world then
		local dis, state = world:ChangeSpiritGuideDir(i3k_db_faction_spirit.spiritCfg.searchRange/100, i3k_db_skills[i3k_db_faction_spirit.spiritCfg.skillId].scope.arg1/100)
		self:updateSceneGuideDir(dis, state)
	end
	mSecondCounter = mSecondCounter + dTime
	if mSecondCounter > 0.5 then
		mSecondCounter = 0
		self:closeSpirit()
		self:onUpdateFactionGarrisonSkill(dTime)
	end
end



--技能刷新
function wnd_spirit_skill:onUpdateFactionGarrisonSkill(dTime)
	local widgets = self._layout.vars
	local canUse = g_i3k_game_context:GetSpiritSkillIsCanUse()
	if not canUse then
		local totalTime, hasCoolTime = g_i3k_game_context:GetRoleSpiritSkillCoolLeftTime()
		local coolLeftTime = math.abs((totalTime - hasCoolTime)/1000)
		widgets.dodgeCoolWord2:setText(math.ceil(coolLeftTime))
		widgets.dodgeCoolWord2:show()
		widgets.dodgeCool2:show()
		local percent = 100*coolLeftTime/(totalTime/1000)
		local progressAction = widgets.dodgeCool2:createProgressAction(coolLeftTime, percent, 0)
		widgets.dodgeCool2:runAction(progressAction)
		self._spiritSkillAnis = true
	else
		if self._spiritSkillAnis then
			widgets.cool1:setOpacity(0)
			widgets.cool1:show()
			--self._layout.anis.chu.play()
			self._spiritSkillAnis = false
		end
		widgets.dodgeCool2:hide()
		widgets.dodgeCoolWord2:hide()
	end
end

--技能load
function wnd_spirit_skill:updateRoleFactionGarrisonSkill()
	local skillId = i3k_db_faction_spirit.spiritCfg.skillId
	local cfgSkill = i3k_db_skills[skillId] 
	local widgets = self._layout.vars
	widgets.dodgeCool2:hide()
	widgets.dodgeCoolWord2:hide()
	widgets.cool1:hide()
	if skillId ~= 0 then
		local hero = i3k_game_get_player_hero()
		if hero and not hero._missionMode.valid then
			widgets.gundong2:show()
		end
	else
		widgets.gundong2:hide()
	end
	widgets.dodgeIcon2:setImage(g_i3k_db.i3k_db_get_icon_path(cfgSkill.icon))
end

--使用技能
function wnd_spirit_skill:onSpiritTouch(sender, eventType)
	-- body
	if eventType == ccui.TouchEventType.began then
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		self:useSpiritSkill()		
	end
end

--技能使用
function wnd_spirit_skill:useSpiritSkill()
	local hero = i3k_game_get_player_hero();
	if hero then
		if not hero:SpiritSkill() then
			if hero._AutoFight then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(114))
			end
		end
	end
end

--是否结束
function wnd_spirit_skill:closeSpirit()
	local deathSpirit = g_i3k_game_context:GetFactionSpiritKillData()
	local cfgSpiritCount = i3k_db_faction_spirit.spiritCfg.monsterCount 
	local count = cfgSpiritCount - deathSpirit
	local isOpen = g_i3k_db.i3k_db_get_faction_spirit_is_open()
	if not isOpen or count == 0 then
		g_i3k_ui_mgr:AddTask(self, {}, function(ui)
			g_i3k_ui_mgr:CloseUI(eUIID_SpiritSkill)
		end, 1)
	end
end

function wnd_spirit_skill:onSkillInfo()
 	local skillId = i3k_db_faction_spirit.spiritCfg.skillId
	local cfgSkill = i3k_db_skills[skillId] 
	local msg = {
		desc = cfgSkill.desc,
		name = cfgSkill.name
	}
	g_i3k_ui_mgr:OpenUI(eUIID_SpiritSkillTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_SpiritSkillTips, msg)
end

function wnd_spirit_skill:updateSceneGuideDir(dir, state) 
	local guideArrow = self._layout.vars.guide
	guideArrow:show();
	local stateInfo = {
		[g_SPIRIT_SEARCH_SHOW] = {icon = 6264, dir = dir, setColorState = UI_COLOR_STATE_NORMAL },
		[g_SPIRIT_SEARCH_NONE] = {icon = 6264, dir = 0, setColorState = UI_COLOR_STATE_GRAY },
		[g_SPIRIT_SEARCH_SHILL] = {icon = 6263, dir = 0, setColorState = UI_COLOR_STATE_NORMAL },
	}
	if stateInfo[state] then
		local info = stateInfo[state]
		guideArrow:setColorState(info.setColorState)
		guideArrow:setImage(g_i3k_db.i3k_db_get_icon_path(info.icon))
		guideArrow:setRotation(math.deg(info.dir))
	end
end
function wnd_create(layout)
	local wnd = wnd_spirit_skill.new()
	wnd:create(layout)
	return wnd
end
