module(..., package.seeall)

local require = require;

local ui = require("ui/taskBase");
local BASE = ui.taskBase
-------------------------------------------------------
wnd_faction_garrison_summary = i3k_class("wnd_faction_garrison_summary", ui.taskBase)

function wnd_faction_garrison_summary:ctor()
	
end

function wnd_faction_garrison_summary:configure()
	BASE.configure(self)
    BASE.setTabState(self, 1)
	local widgets = self._layout.vars
	
	self.leftRoots = widgets.leftRoots
	self.titleName = widgets.titleName
	self.scroll = widgets.scroll
end

function wnd_faction_garrison_summary:refresh()
	self:loadScrollData()
	self.titleName:setText(i3k_get_string(16766, g_i3k_game_context:GetFactionZoneSectName()))
end

function wnd_faction_garrison_summary:loadScrollData()
	local destinyInfo = g_i3k_game_context:getSectDestiny()
	if #destinyInfo > 0 then
		self.leftRoots:show()
		self.scroll:removeAllChildren()
		local dragonInfo = i3k_db_faction_dragon.dragonInfo
		for i, e in ipairs(i3k_db_faction_dragon.dragonCfg.dragonIDs) do
			local node = require("ui/widgets/zdbpzdt")()
			local curPower = destinyInfo[i] or 0
			node.vars.name:setText(i3k_db_resourcepoint[e].name)
			node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(dragonInfo[e].iconID))
			node.vars.percentLabel:setText(string.format("%s / %s", curPower, i3k_db_faction_dragon.dragonCfg.maxPoint))
			node.vars.bar:setPercent(curPower / i3k_db_faction_dragon.dragonCfg.maxPoint * 100)
			self.scroll:addItem(node)
		end
	else
		self.leftRoots:hide()
	end
end

function wnd_faction_garrison_summary:updateScroll()
	local destinyInfo = g_i3k_game_context:getSectDestiny()
	if #destinyInfo > 0 then
		self.leftRoots:show()
		local all_child = self.scroll:getAllChildren()
		if #all_child > 0 then
			local dragonIDs = i3k_db_faction_dragon.dragonCfg.dragonIDs
			for i, e in ipairs(all_child) do
				local curPower = destinyInfo[i] or 0
				-- e.vars.name:setText(i3k_db_resourcepoint[dragonIDs[i]].name)
				e.vars.percentLabel:setText(string.format("%s / %s", curPower, i3k_db_faction_dragon.dragonCfg.maxPoint))
				e.vars.bar:setPercent(curPower / i3k_db_faction_dragon.dragonCfg.maxPoint * 100)
			end
		else
			self:loadScrollData()
		end
	else
		self.leftRoots:hide()
	end
end

--帧事件
function wnd_faction_garrison_summary:onUpdate(dTime)	
	self:openSpirit()		
end

function wnd_faction_garrison_summary:openSpirit()
	local isOpen = g_i3k_db.i3k_db_get_faction_spirit_is_open()
	local isEnd  = g_i3k_game_context:GetSpiritIsEnd()
	if isOpen and isEnd == 1 then
		g_i3k_ui_mgr:AddTask(self, {}, function(ui)
			g_i3k_logic:OpenGarrisonTeam()
		end, 1)
	end
end
function wnd_create(layout)
	local wnd = wnd_faction_garrison_summary.new()
	wnd:create(layout)
	return wnd
end
