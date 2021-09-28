module(..., package.seeall)

local require = require

local ui = require("ui/base")

wnd_spyStoryHelp = i3k_class("wnd_spyStoryHelp", ui.wnd_base)

local SHOW_HELP = 1
local SHOW_SKILL = 2

function wnd_spyStoryHelp:ctor()
	self._state = 0
end

function wnd_spyStoryHelp:configure()
	local widget = self._layout.vars
	
	self.close_btn = widget.close_btn
	self.close_btn:onClick(self, self.onCloseUI)
	
	self.help_btn = widget.help_btn
	self.help_btn:onClick(self, self.onHelpBtnClick)
	
	self.skill_btn = widget.skill_btn
	self.skill_btn:onClick(self, self.onSkillBtnClick)
	
	self.root1 = widget.root1
	self.root2 = widget.root2
	
	self.scroll1 = widget.scroll1
	self.scroll2 = widget.scroll2
end

function wnd_spyStoryHelp:refresh()
	self:initScrolls()
	self:changeState(SHOW_HELP)
end

function wnd_spyStoryHelp:initScrolls()
	self.scroll1:removeAllChildren()
	local node = require("ui/widgets/mitanfengyunsmt1")()
	node.vars.desc:setText(i3k_get_string(18657))
	node.vars.desc:setRichTextFormatedEventListener(function ()
		local textUI = node.vars.desc
		local rootSize = node.vars.rootVar:getSize()
		local height = textUI:getInnerSize().height
		local width = rootSize.width
		height = rootSize.height > height and rootSize.height or height
		node.vars.rootVar:changeSizeInScroll(self.scroll1, width, height, true)
	end)
	self.scroll1:addItem(node)
	self.scroll2:removeAllChildren()
	local cfg = i3k_db_spy_story_generals[1][1]
	local skillID = cfg.attacks[1] or 0
	if skillID ~= 0 then
		local node = require("ui/widgets/mitanfengyunsmt")()
		node.vars.name:setText(i3k_db_skills[skillID].name)
		node.vars.desc:setText(i3k_db_skills[skillID].desc)
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_skills[skillID].icon))
		self.scroll2:addItem(node)
	end
	for i = 1, #cfg.skills do
		local skillID = cfg.skills[i]
		if skillID ~= 0 then
			local node = require("ui/widgets/mitanfengyunsmt")()
			node.vars.name:setText(i3k_db_skills[skillID].name)
			node.vars.desc:setText(i3k_db_skills[skillID].desc)
			node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_skills[skillID].icon))
			self.scroll2:addItem(node)
		end
	end
end

function wnd_spyStoryHelp:changeState(state)
	if state == self._state then
		return
	end
	self._state = state
	self.root1:setVisible(state == SHOW_HELP)
	self.root2:setVisible(state == SHOW_SKILL)
	if state == SHOW_HELP then
		self.help_btn:stateToPressed()
		self.skill_btn:stateToNormal()
	else
		self.help_btn:stateToNormal()
		self.skill_btn:stateToPressed()
	end
end

function wnd_spyStoryHelp:onHelpBtnClick(sender)
	self:changeState(SHOW_HELP)
end

function wnd_spyStoryHelp:onSkillBtnClick(sender)
	self:changeState(SHOW_SKILL)
end

function wnd_create(layout, ...)
	local wnd = wnd_spyStoryHelp.new()
	wnd:create(layout)
	return wnd
end