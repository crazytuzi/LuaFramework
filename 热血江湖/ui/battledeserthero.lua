------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/profile')
------------------------------------------------------
wnd_battle_desert_hero = i3k_class("wnd_battle_desert_hero",ui.wnd_profile)

local HERO_ITEM = "ui/widgets/juezhanhuangmoyxt"
local HERO_ITEM_TXT = "ui/widgets/juezhanhuangmoyxt2"

function wnd_battle_desert_hero:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self,self.onCloseUI)
	self.skills = {}
	for i=1,4 do
		self.skills[i] = {
			skill_bg = widgets['skill'..i..'_bg'],
			skill_btn = widgets['skill'..i..'_btn'],
			skill_select = widgets['skill'..i..'_select'],
		}
	end
	widgets.goBtn:onClick(self, self.onBattleBtnClick)
	self.scroll = widgets.descScroll
	self.hero_module = self._layout.vars.hero_module
	self.revolve = widgets.rotateBtn
	widgets.rotateBtn:onTouchEvent(self, self.onRotateBtn)
end

function wnd_battle_desert_hero:refresh(selectedId, battlingId)
	if selectedId then
		self.selectedId = selectedId
	else
		if g_i3k_game_context:getBattleDesertRoleInfo().curHero == 0 then
			self.selectedId = i3k_db_desert_generals[math.random(#i3k_db_desert_generals)].id
		else
			self.selectedId = g_i3k_game_context:getBattleDesertRoleInfo().curHero
		end
	end
	self.battlingId = battlingId or  g_i3k_game_context:getBattleDesertRoleInfo().curHero

	local widgets = self._layout.vars
	self.heroWidgets = {}
	widgets.heroScroll:removeAllChildren()
	for i, v in ipairs(i3k_db_desert_generals) do
		local heroWidget = require(HERO_ITEM)()
		local vars = heroWidget.vars
		vars.skillIcon:setImage(g_i3k_db.i3k_db_get_icon_path(v.classImg))
		vars.battling:setVisible(self.battlingId == v.id)
		vars.selected:setVisible(self.selectedId == v.id)
		vars.btn:onClick(self, self.onHeroClick, v.id)
		widgets.heroScroll:addItem(heroWidget)
		self.heroWidgets[v.id] = heroWidget
	end
	local heroCfg = i3k_db_desert_generals[self.selectedId]
	widgets.heroName:setText(heroCfg.name)
	ui_set_hero_model(widgets.hero_module, heroCfg.modelID)
	widgets.heroDes:setText(heroCfg.desc)
	for i, v in ipairs(self.skills) do
		local skillId = heroCfg.skills[i] or heroCfg.dodgeSkill
		local skillCfg = i3k_db_skills[skillId]
		v.skill_bg:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg.icon))
		v.skill_btn:onClick(self, self.onSkillBtnClick, i)
		v.skill_btn:setTag(skillId)
	end
	self:onSkillBtnClick(self.skills[1].skill_btn, 1)
	widgets.goBtn:SetIsableWithChildren(self.selectedId ~= self.battlingId)
end

function wnd_battle_desert_hero:onHeroClick(sender, id)
	if id ~= self.selectedId then
		self:refresh(id, self.battlingId)
	end
end

function wnd_battle_desert_hero:onSkillBtnClick(sender, index)
	local vars = self._layout.vars
	local skillId = sender:getTag()
	local skillCfg = i3k_db_skills[skillId]
	vars.skillName:setText(skillCfg.name)
	vars.skillDes:hide()
	-- vars.skillDes:setText(skillCfg.desc)
	self.scroll:removeAllChildren()
	g_i3k_ui_mgr:AddTask(self, {}, function(ui)
		local annText = require(HERO_ITEM_TXT)()
		annText.vars.text:setText(skillCfg.desc)
		self.scroll:addItem(annText)
		g_i3k_ui_mgr:AddTask(self, {annText}, function(ui)
			local textUI = annText.vars.text
			local size = annText.rootVar:getContentSize()
			local height = textUI:getInnerSize().height
			local width = size.width
			height = size.height > height and size.height or height
			annText.rootVar:changeSizeInScroll(self.scroll, width, height, true)
		end, 1)
	end, 1)
	for i, v in ipairs(self.skills) do
		v.skill_select:setVisible(i == index)
	end
end

function wnd_battle_desert_hero:onBattleBtnClick(sender)
	if self.selectedId ~= self.battlingId then
		i3k_sbean.selectBattleHero(self.selectedId)
	end
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_battle_desert_hero.new()
	wnd:create(layout,...)
	return wnd
end