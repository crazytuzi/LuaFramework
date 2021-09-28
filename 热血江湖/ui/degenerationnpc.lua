-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_degenerationNpc = i3k_class("wnd_degenerationNpc", ui.wnd_base)

function wnd_degenerationNpc:ctor()
	
end

function wnd_degenerationNpc:configure()
	local widgets = self._layout.vars;
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.exit_Btn:onClick(self, self.onCloseUI)
	widgets.ok_Btn:onClick(self, self.Confirm)
	self.desText = widgets.desText;
	self.npcName = widgets.npcName;
	self.itemIcon = widgets.itemIcon;
	self.itemCount = widgets.itemCount;
	self.npcmodule = widgets.npcmodule;
	
end

function wnd_degenerationNpc:refresh(id)
	local npcName = i3k_db_npc[id].remarkName
	self.npcName:setText(npcName);
	self.desText:setText(i3k_db_string[4100]);
	self.itemIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_common.changeGender.itemId));
	self.itemCount:setText("x "..i3k_db_common.changeGender.itemCount)
	local modelId = g_i3k_db.i3k_db_get_npc_modelID(id)
	if modelId then
		ui_set_hero_model(self.npcmodule, modelId);
	end
end

function wnd_degenerationNpc:Confirm(sender)
	local haveDiamond = g_i3k_game_context:GetBaseItemCount(-g_BASE_ITEM_DIAMOND)
	local lvl = g_i3k_game_context:GetLevel()
	if lvl then
		if g_i3k_game_context:IsInFightTime() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(4102))
		elseif g_i3k_game_context:GetTeamId() ~= 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(4103))
		elseif g_i3k_game_context:IsOnHugMode() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17038))
		elseif g_i3k_game_context:IsInRoom() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(4104))
		elseif haveDiamond < i3k_db_common.changeGender.itemCount then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(4109))
		elseif g_i3k_game_context:IsInMissionMode() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(4114))
		elseif g_i3k_game_context:IsInSuperMode() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(4110))
		elseif g_i3k_game_context:GetMarryLevel()~= 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(4101))
		elseif g_i3k_game_context:IsMulMemberState() or g_i3k_game_context:IsLeaderMemberState() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(4112))
		elseif lvl >= i3k_db_common.changeGender.changeLvl then
			g_i3k_ui_mgr:OpenUI(eUIID_DegenerationConfirm)
			g_i3k_ui_mgr:RefreshUI(eUIID_DegenerationConfirm)
		elseif lvl < i3k_db_common.changeGender.changeLvl then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(4107,i3k_db_common.changeGender.changeLvl))
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(4113))
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_degenerationNpc.new();
		wnd:create(layout);
	return wnd;
end