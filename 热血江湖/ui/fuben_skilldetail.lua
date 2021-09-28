
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_fuBen_SkillDetail = i3k_class("wnd_fuBen_SkillDetail",ui.wnd_base)

local STATE_NORMAL = 1
local STATE_HOMELAND = 2
function wnd_fuBen_SkillDetail:ctor()
	self.widgets = nil
	self.skillState = 1
end

function wnd_fuBen_SkillDetail:configure()
	local widgets = self._layout.vars
	self.widgets = widgets
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_fuBen_SkillDetail:refresh(skillCfg, dType)
	local scroll = self.widgets.scroll
	scroll:setBounceEnabled(false)

	local skillIDs = {}
	local shareTime = 0
	if dType == g_FUBEN_SKILL_NORMAL then
		for _,v in ipairs(skillCfg.skill) do
			table.insert(skillIDs, v.id)
		end
		shareTime = skillCfg.shareTime / 1000
		self.state = STATE_NORMAL
	elseif dType == g_FUBEN_SKILL_HOMELAND then
		for _,v in ipairs(skillCfg) do
			table.insert(skillIDs, v)
		end
		shareTime = i3k_db_homeland_guard_cfg.skillShareTime
		self.state = STATE_HOMELAND
	end
	self:setTitleText(shareTime)
	local itemHeight = 0
	for _,v in ipairs(skillIDs) do
		local item = require("ui/widgets/zdxjnt2")()
		local _skill_data = i3k_db_skills[v]
		self:setSkillBtnState( item, i3k_db_icons[_skill_data.icon].path, self.state)
		item.vars.name:setText(_skill_data.name)
		item.vars.desc:setText(_skill_data.desc)
		itemHeight = item.rootVar:getSize().height + itemHeight
		scroll:addItem(item)
	end
	self:setScrollABSize(itemHeight)

end
function wnd_fuBen_SkillDetail:setTitleText(shareTime)
	local strTem = {}
	if self.state == STATE_NORMAL then
		strTem = { i3k_get_string(973), }
		if shareTime > 0 then
			table.insert(strTem, 1, i3k_get_string(974, shareTime))
		end
	elseif self.state == STATE_HOMELAND then
		strTem = { i3k_get_string(5549, shareTime), }
	end
	for i,v in ipairs(strTem) do
		self:addWord(v)
	end
end
function wnd_fuBen_SkillDetail:setSkillBtnState(item, icon)
	if self.state == STATE_NORMAL then
		item.vars.skillBG1:show()
		item.vars.skillBG2:hide()
		item.vars.skill_icon:setImage(icon)
	elseif self.state == STATE_HOMELAND then
		item.vars.skillBG1:hide()
		item.vars.skillBG2:show()
		item.vars.skill_icon2:setImage(icon)
	end
end

function wnd_fuBen_SkillDetail:addWord(str)
	local scroll = self.widgets.scroll
	local node = require("ui/widgets/zdxjnt3")()
	node.vars.oneword:setText(str)
	node.vars.oneword:setRichTextFormatedEventListener(function(sender)
		local nheight = node.vars.oneword:getInnerSize().height
		local tSizeH = node.vars.oneword:getSize().height
		
		local rSize = node.rootVar:getContentSize()
		if nheight > tSizeH then
			local size = node.rootVar:getContentSize()
			rSize.height = rSize.height + nheight - tSizeH
			node.rootVar:changeSizeInScroll(scroll, rSize.width, rSize.height, true)
	 	end

	 	local scrSize = self.widgets.scroll:getContentSize()
		self:setScrollABSize(scrSize.height + rSize.height)
		node.vars.oneword:setRichTextFormatedEventListener(nil)
	end)
	scroll:insertChildToIndex(node,1)
end

function wnd_fuBen_SkillDetail:setScrollABSize(height)
	local scroll = self.widgets.scroll
	local scrSize = scroll:getContentSize()
	scroll:setContentSize(scrSize.width, height)
	self.widgets.scrRoot:setContentSize(scrSize.width+24, height+48)
	scroll:setContainerSize(scrSize.width,height)
	scroll:update()
end

function wnd_create(layout, ...)
	local wnd = wnd_fuBen_SkillDetail.new()
	wnd:create(layout, ...)
	return wnd;
end