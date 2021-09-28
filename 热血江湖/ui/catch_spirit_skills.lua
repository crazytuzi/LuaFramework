-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_catch_spirit_skills = i3k_class("wnd_catch_spirit_skills", ui.wnd_base)

function wnd_catch_spirit_skills:ctor()
	self._monsterId = 0
	self._monsterGuid = 0
	self._count = 1
end

function wnd_catch_spirit_skills:configure()
	--[[self._layout.vars.scroll1:setAlignMode(g_UIScrollList_HORZ_ALIGN_LEFT)
	self._layout.vars.scroll2:setAlignMode(g_UIScrollList_HORZ_ALIGN_LEFT)
	self._layout.vars.scroll3:setAlignMode(g_UIScrollList_HORZ_ALIGN_LEFT)--]]
	self._scrollList =
	{
		[3] = self._layout.vars.scroll1,
		[4] = self._layout.vars.scroll2,
		[5] = self._layout.vars.scroll3,
	}
	self._scrollBg =
	{
		[3] = self._layout.vars.bg1,
		[4] = self._layout.vars.bg2,
		[5] = self._layout.vars.bg3,
	}
end

function wnd_catch_spirit_skills:refresh()
	local _, monsterGuid = g_i3k_game_context:GetSelectMonsterId()
	local classType = g_i3k_game_context:GetRoleType()
	if self._monsterGuid == monsterGuid then
		
	else
		self._monsterId, self._monsterGuid = g_i3k_game_context:GetSelectMonsterId()
		self._count = #i3k_db_catch_spirit_monster[self._monsterId].skillList
		self._scrollList[self._count]:removeAllChildren()
		for k, v in ipairs(i3k_db_catch_spirit_monster[self._monsterId].skillList) do
			local node = require("ui/widgets/gdyljnt")()
			node.vars.arrow:setVisible(k ~= self._count)
			node.vars.last:setVisible(k == self._count)
			node.vars.skillIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_catch_spirit_skills[classType].skillUnAct[v]))
			node.vars.skillBtn:hide()
			self._scrollList[self._count]:addItem(node)
		end
	end
	local children = self._scrollList[self._count]:getAllChildren()
	for k, v in pairs(self._scrollBg) do
		if k == self._count then
			v:show()
		else
			v:hide()
		end
	end
	local monsters = g_i3k_game_context:getCatchSpiritMonsterSkill()
	for k, v in ipairs(children) do
		local skill = i3k_db_catch_spirit_monster[self._monsterId].skillList[k]
		if monsters.count then
			if k <= monsters.count then
				v.vars.skillIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_catch_spirit_skills[classType].skillAct[skill]))
			else
				v.vars.skillIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_catch_spirit_skills[classType].skillUnAct[skill]))
			end
		else
			v.vars.skillIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_catch_spirit_skills[classType].skillUnAct[skill]))
		end
	end
end

function wnd_catch_spirit_skills:updateSkillEffect(index)
	self._layout.anis.c_boom.stop()
	local child = self._scrollList[self._count]:getChildAtIndex(index)
	if child then
		local position = child.rootVar:getPositionInScroll(self._scrollList[self._count])
		--local worldPos = self._scrollList[self._count]:getParent():convertToWorldSpace(position)
		local worldPos = child.rootVar:getParent():convertToWorldSpace(position)
		local parent = self._layout.vars.animate:getParent()
		self._layout.vars.animate:setPosition(parent:convertToNodeSpace(cc.p(worldPos.x, worldPos.y)))
		self._layout.anis.c_boom.play()
	end
end

function wnd_create(layout)
	local wnd = wnd_catch_spirit_skills.new()
	wnd:create(layout)
	return wnd
end