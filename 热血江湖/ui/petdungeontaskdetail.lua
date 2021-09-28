module(...,package.seeall)

local require = require;
local ui = require("ui/base");

wnd_petDungeonTaskDetail = i3k_class("wnd_petDungeonTaskDetail", ui.wnd_base)

function wnd_petDungeonTaskDetail:ctor()

end 

function wnd_petDungeonTaskDetail:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
end

function wnd_petDungeonTaskDetail:refresh()
	local weight = self._layout.vars
	
	local scoll = weight.scroll
	scoll:removeAllChildren()
	
	local index = g_i3k_game_context:getpetDungeonMapIndex()
	
	if index == 0 then
		return 
	end

	for k, v in ipairs(i3k_db_PetDungeonTasks) do
		if not g_i3k_game_context:petDungeonIsFinish(k) and v.mapID == index then
			local node = require("ui/widgets/chongwushilianrwzyt")()
			local nodeWht = node.vars
			local npc = i3k_db_npc[v.npcID]
			nodeWht.npcName:setText(npc.remarkName)
			nodeWht.taskName:setText(v.name)
			nodeWht.gotoBt:onClick(self, self.walkToPos, v.npcID) 
			nodeWht.icon:setImage(g_i3k_db.i3k_db_get_monster_head_icon_path(npc.monsterID))
			scoll:addItem(node)
		end
	end
end

function wnd_petDungeonTaskDetail:walkToPos(sender, npcID)
	g_i3k_game_context:GotoNpc(npcID)
	self:onCloseUI()
end

function wnd_create(layout)
	local wnd = wnd_petDungeonTaskDetail.new();
	wnd:create(layout);
	return wnd;
end
