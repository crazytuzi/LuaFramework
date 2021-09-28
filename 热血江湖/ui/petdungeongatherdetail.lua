module(...,package.seeall)

local require = require;
local ui = require("ui/base");

wnd_petDungeonGatherDetail = i3k_class("wnd_petDungeonGatherDetail", ui.wnd_base)

local SKILLITEM = "ui/widgets/chongwushiliancjzyt"

function wnd_petDungeonGatherDetail:ctor()

end

function wnd_petDungeonGatherDetail:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
end

function wnd_petDungeonGatherDetail:refresh()
	local weight = self._layout.vars	
	local scoll = weight.scroll
	scoll:removeAllChildren()
	local gathers = g_i3k_db.i3k_db_get_PetDungeonGathers_By_MapID(g_i3k_game_context:getpetDungeonMapIndex())
	local items = scoll:addChildWithCount(SKILLITEM, 2, #gathers, true)
	
	for k, v in ipairs(items) do
		local node = v.vars
		local gather = gathers[k]	
		node.name:setText(gather.name)
		node.level:setText(i3k_get_string(467, gather.gatherlevel))
		node.icon:setImage(i3k_db_icons[gather.icon].path)
		node.bt:onClick(self, self.onChoseBt, gather)
		-- 算宠物装备 算幸运事件)(不算强制) 和各个技能的和 
		node.canDo:setVisible(g_i3k_game_context:getPetDungeonGatherState(gather.id) == 1)--0 不可采集 1 可采集 2 强制采集
	end
	
	local value = g_i3k_game_context:getPetDungeonGatherCount()
	weight.count:setText(i3k_get_string(1505, value, i3k_db_PetDungeonBase.gatherAllCount))
	weight.count:setTextColor(g_i3k_get_cond_color(value < i3k_db_PetDungeonBase.gatherAllCount))
end

function wnd_petDungeonGatherDetail:onChoseBt(sender, info)
	g_i3k_logic:OpenPetDungeonGatherOperationUI(info, true)
end

function wnd_create(layout)
	local wnd = wnd_petDungeonGatherDetail.new();
	wnd:create(layout);
	return wnd;
end
