-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_transfrom_skill_tips = i3k_class("wnd_transfrom_skill_tips", ui.wnd_base)

function wnd_transfrom_skill_tips:ctor()
	self._skillID = nil
end



function wnd_transfrom_skill_tips:configure(...)
	local arg = { ... };
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self._skillID = arg[1]
end

function wnd_transfrom_skill_tips:onShow()

end

function wnd_transfrom_skill_tips:refresh(skillID)
	self._skillID = skillID
	self:updateBaseData()
end

function wnd_transfrom_skill_tips:updateBaseData()
	self._layout.vars.scroll:removeAllChildren()
	local skill_name = self._layout.vars.skill_name
	--local skill_desc = self._layout.vars.skill_desc
	local skill_desc = ""
	if g_i3k_db.i3k_db_get_five_trans_is_skill(self._skillID) then
		if skill_name then
			skill_name:setText(i3k_db_skills[self._skillID].name)
		end
		skill_desc = i3k_db_skills[self._skillID].desc
	else -- 心法
		local xinfaID = g_i3k_db.i3k_db_get_five_trans_xinfa_ID(self._skillID)
		local xinfaCfg = i3k_db_xinfa[xinfaID]
		skill_desc = xinfaCfg.effectDesc[1]
		local xinfaName = xinfaCfg.name
		skill_name:setText(xinfaName)
	end
	local node = require("ui/widgets/hyjnt")()
	node.vars.text:setText(skill_desc)
	g_i3k_ui_mgr:AddTask(self, {node}, function(ui)
		local size = node.rootVar:getContentSize()
		local height = node.vars.text:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or height
		node.rootVar:changeSizeInScroll(ui._layout.vars.scroll, width, height, true)
	end, 1)
	self._layout.vars.scroll:addItem(node)
end

--[[function wnd_transfrom_skill_tips:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_TransfromSkillTips)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_transfrom_skill_tips.new();
		wnd:create(layout, ...);

	return wnd;
end
