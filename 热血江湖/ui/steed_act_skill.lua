-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_steed_act_skill = i3k_class("wnd_steed_act_skill", ui.wnd_base)

function wnd_steed_act_skill:ctor()
	self._needValue = {}
end

function wnd_steed_act_skill:configure()
	
end

function wnd_steed_act_skill:onShow()
	
end

function wnd_steed_act_skill:refresh(steedId, skillId, needItem)
	local id = 0
	local count = 0
	for i,v in pairs(needItem) do
		id = i
		count = v
	end
	local rank = g_i3k_db.i3k_db_get_common_item_rank(id)
	self._layout.vars.nameLabel:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	self._layout.vars.nameLabel:setTextColor(g_i3k_get_color_by_rank(rank))
	self._layout.vars.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	self._layout.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	self._layout.vars.countLabel:setText("x"..count)
	
	self._needValue = {steedId = steedId, skillId = skillId, needItem = needItem, callfunc = callfunc}
	self._layout.vars.ok:onClick(self, self.onConfirm, self._needValue)
	self._layout.vars.cancel:onClick(self, function ()
		g_i3k_ui_mgr:CloseUI(eUIID_SteedActSkill)
	end)
end

function wnd_steed_act_skill:onConfirm(sender)
	i3k_sbean.learn_skill(self._needValue.steedId, self._needValue.skillId)
end

function wnd_steed_act_skill:onSuccess(info)
	for i,v in pairs(self._needValue.needItem) do
			g_i3k_game_context:UseHorseBooks(i, v)
		end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkill, "actCallbackFunc", info)
		g_i3k_ui_mgr:CloseUI(eUIID_SteedActSkill)
end

function wnd_create(layout, ...)
	local wnd = wnd_steed_act_skill.new()
	wnd:create(layout, ...)
	return wnd;
end