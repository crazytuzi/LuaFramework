-------------------------------------------------------
module(..., package.seeall)

local require = require;
require("ui/ui_funcs")
local ui = require("ui/base");

-------------------------------------------------------
wnd_dialogue_base = i3k_class("wnd_dialogue_base", ui.wnd_base)

function wnd_dialogue_base:ctor()
	self._list_desc = {}
	self._root = {}
end
function wnd_dialogue_base:configure()
end

function wnd_dialogue_base:updateDesc(list_desc,items)
	self._layout.vars.dialogue:setText(list_desc.txt)
	local count = 0
	for k,v in pairs(items) do
		count = count + 1
		self._root[count].itemRoot:show()
		self._root[count].itemRoot:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(k))
		self._root[count].item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(k,i3k_game_context:IsFemaleRole()))
		self._root[count].itemRoot:onTouchEvent(self,self.onTips,k)
		self._root[count].suo:setVisible(k > 0)
		local tmp_str = string.format("×%s",v)
		self._root[count].item_count:setText(tmp_str)
	end
end

function wnd_dialogue_base:onTips(sender, eventType,id)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:ShowCommonItemInfo(id)
	end
end

--初始化模型
function wnd_dialogue_base:updateModule(id,moduleUI)
	local npcmodule = moduleUI
	if moduleUI==nil then
		npcmodule = self._layout.vars.npcmodule
	end
	if id == -1 then
		local equips = g_i3k_game_context:GetWearEquips()
		g_i3k_game_context:ResetTestFashionData() --清理时装试穿数据
		ui_set_hero_model(npcmodule, i3k_game_get_player_hero(),equips,g_i3k_game_context:GetIsShwoFashion())
	elseif id ==0 or id == 7 then
	else
		if id == 2006 or id == 134 or id == 31 or id == 32 or id == 2052 then
			local y = npcmodule:getPositionY()
			npcmodule:setPositionY(y*0.3)
		elseif id == 2018 then
			local y = npcmodule:getPositionY()
			npcmodule:setPositionY(y*-0.3)
		end
		ui_set_hero_model(npcmodule, id)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_dialogue_base.new();
		wnd:create(layout, ...);
	return wnd;
end

