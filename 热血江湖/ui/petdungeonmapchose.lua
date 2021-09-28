module(...,package.seeall)

local require = require;
local ui = require("ui/base");

wnd_petDungeonChoseMap = i3k_class("wnd_petDungeonChoseMap", ui.wnd_base)

function wnd_petDungeonChoseMap:ctor()

end

function wnd_petDungeonChoseMap:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
end

function wnd_petDungeonChoseMap:refresh()
	local weight = self._layout.vars
	
	local scoll = weight.scroll
	scoll:removeAllChildren()
	
	for k, v in ipairs(i3k_db_PetDungeonMaps) do
		local node = require("ui/widgets/chongwushiliandwt")()
		local nodeWht = node.vars
		local flag1 = v.rolelevel <= g_i3k_game_context:GetLevel()
		local flag2 = false 
		nodeWht.name:setText(v.name)
		nodeWht.level:setText(i3k_get_string(467, v.rolelevel))
		nodeWht.level:setTextColor(g_i3k_get_cond_color(flag1))
		nodeWht.des:setText(i3k_get_string(1503, v.skilllevel))
		flag2 = v.skilllevel == 0
		nodeWht.des:setVisible(not flag2)
		
		if not flag2 then
			flag2 = g_i3k_game_context:isPetDungeonAllSkillsSatisfy(v.skilllevel)
			nodeWht.des:setTextColor(g_i3k_get_cond_color(flag2))
		end
	
		--不算宠物装备 不算幸运事件 各个技能的和 
		nodeWht.join:onClick(self, self.onJoinBt, {index = k, value = v, flag = flag1 and flag2})
		scoll:addItem(node)
	end
end

function wnd_petDungeonChoseMap:onJoinBt(sender, info)
	if not info.flag then
		local fun = (function(ok)
			if ok then
				g_i3k_logic:OpenPetDungeonChosePetUI(info)
			end
		end)
		
		g_i3k_ui_mgr:ShowMidMessageBox2(i3k_get_string(1504), fun)
		return
	end
	
	g_i3k_logic:OpenPetDungeonChosePetUI(info)
end

function wnd_create(layout)
	local wnd = wnd_petDungeonChoseMap.new();
	wnd:create(layout);
	return wnd;
end
