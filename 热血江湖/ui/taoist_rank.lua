-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_taoist_rank = i3k_class("wnd_taoist_rank", ui.wnd_base)

function wnd_taoist_rank:ctor()
	
end

function wnd_taoist_rank:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	
	self._tabBar = {
		[1] = self._layout.vars.justBtn,
		[2] = self._layout.vars.evilBtn,
	}
	for i,v in ipairs(self._tabBar) do
		v:setTag(i)
		v:onClick(self, self.syncRanks)
	end
	
	self._ranksCacheData = {
		[1] = {ranks = {}, percent = 0},
		[2] = {ranks = {}, percent = 0},
	}
	self._state = g_i3k_game_context:GetTransformBWtype()
end

function wnd_taoist_rank:onShow()
	
end

function wnd_taoist_rank:refresh(ranks)
	local myRank = g_i3k_game_context:getTaoistRank()
	myRank = myRank==0 and "300+" or myRank
	self._layout.vars.myRankLabel:setText(myRank)
	
	if #self._ranksCacheData[self._state].ranks==0 then
		self._ranksCacheData[self._state].ranks = ranks
	else
		for i,v in ipairs(ranks) do
			table.insert(self._ranksCacheData[self._state].ranks, v)
		end
	end
	self:setData(bwType, ranks)
end

function wnd_taoist_rank:setData(bwType, ranks, percent)
	for i,v in ipairs(self._tabBar) do
		if i==self._state then
			v:stateToPressedAndDisable()
		else
			v:stateToNormal()
		end
	end
	local scroll = self._layout.vars.scroll
	local rankImgTable = {2718, 2719, 2720}
	for i,v in ipairs(ranks) do
		local node = require("ui/widgets/zxdcpht")()
		if i<=3 then
			node.vars.rankImg:setImage(g_i3k_db.i3k_db_get_icon_path(rankImgTable[i]))
		else
			node.vars.rankLabel:setText(i..".")
		end
		node.vars.rankImg:setVisible(i<=3)
		local role = v.roleSocial.role
		local sectData = {sectId = v.roleSocial.sectId, sectName = v.roleSocial.sectName, personalMsg = v.roleSocial.personalMsg}
		node.vars.rankLabel:setVisible(not node.vars.rankImg:isVisible())
		node.vars.lvlLabel:setText(role.level .. "级")
		node.vars.taoistLvlLabel:setText(v.lvl)
		node.vars.sectName:setText(sectData.sectName~="" and sectData.sectName or "---")
		node.vars.nameLabel:setText(role.name)
		node.vars.occupation:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[role.type].classImg))
		node.vars.scoreLabel:setText(v.score)
		scroll:addItem(node)
	end
	if percent then
		scroll:jumpToListPercent(percent)
	end
end

function wnd_taoist_rank:syncRanks(sender)
	local scroll = self._layout.vars.scroll
	local percent = scroll:getListPercent()
	self._ranksCacheData[self._state].percent = scroll:getListPercent()
	local bwType = sender:getTag()
	if #self._ranksCacheData[bwType].ranks~=0 then
		self._state = bwType
		scroll:removeAllChildren(true)
		local x = self._ranksCacheData
		self:setData(bwType, self._ranksCacheData[bwType].ranks, self._ranksCacheData[bwType].percent)
	else
		local callback = function ()
			self._state = bwType
			self._layout.vars.scroll:removeAllChildren(true)
		end
		i3k_sbean.sync_taoist_rank(bwType, 0, 10, callback)
	end
end

--[[function wnd_taoist_rank:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_TaoistRank)
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_taoist_rank.new()
	wnd:create(layout, ...)
	return wnd;
end
