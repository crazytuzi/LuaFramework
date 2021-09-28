-------------------------------------------------------
module(..., package.seeall)

local require = require;
require("ui/ui_funcs")
local ui = require("ui/base");

-------------------------------------------------------
wnd_home_pet_dialogue = i3k_class("wnd_home_pet_dialogue", ui.wnd_base)

local FUNCTIONBTN = "ui/widgets/db5t"

function wnd_home_pet_dialogue:ctor()
	self._locationId = 1
	self._petInfo = {}
end

function wnd_home_pet_dialogue:configure()
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self._operate = 
	{
		{onlyMine = false},
		{onlyMine = true},
	}
end

function wnd_home_pet_dialogue:refresh(petInfo)
	self._locationId = petInfo.iArgs[3]
	self._petInfo = petInfo
	self:setOperateScroll(petInfo)
	local modelId = i3k_db_mercenaries[petInfo.id].modelID
	if petInfo.iArgs[2] == 1 then
		modelId = i3k_db_mercenariea_waken_property[petInfo.id].modelID
	end
	ui_set_hero_model(self._layout.vars.npcmodule, modelId)
	self._layout.vars.npcName:setText(petInfo.vArgs[1] ~= "" and petInfo.vArgs[1] or i3k_db_mercenaries[petInfo.id].name)
end

function wnd_home_pet_dialogue:setOperateScroll(petInfo)
	self._layout.vars.btn_scroll:removeAllChildren()
	if g_i3k_game_context:isGetHomePetReward(petInfo.iArgs[3]) then
		self._layout.vars.dialogue:setText(i3k_get_string(17866))
		local children = self._layout.vars.btn_scroll:addChildWithCount(FUNCTIONBTN, 2, 1)
		local node = children[1]
		node.vars.name:setText(i3k_get_string(17867))
		node.vars.select1_btn:onClick(self, self.onRewardBtn)
	else
		if g_i3k_game_context:isInMyHomeLand() then
			self._layout.vars.dialogue:setText(i3k_get_string(17868))
			local children = self._layout.vars.btn_scroll:addChildWithCount(FUNCTIONBTN, 2, #self._operate)
			for k, v in ipairs(children) do
				v.vars.name:setText(i3k_db_home_pet_play[k].playName)
				v.vars.select1_btn:onClick(self, self.onOperateBtn, k)
			end
		else
			self._layout.vars.dialogue:setText(i3k_get_string(17880))
			local otherActions = {}
			for k, v in ipairs(self._operate) do
				if not v.onlyMine then
					table.insert(otherActions, k)
				end
			end
			local children = self._layout.vars.btn_scroll:addChildWithCount(FUNCTIONBTN, 2, #otherActions)
			for k, v in ipairs(children) do
				v.vars.name:setText(i3k_db_home_pet_play[otherActions[k]].playName)
				v.vars.select1_btn:onClick(self, self.onOperateBtn, otherActions[k])
			end
		end
	end
end

function wnd_home_pet_dialogue:onOperateBtn(sender, id)
	local name = self._petInfo.vArgs[1] ~= "" and self._petInfo.vArgs[1] or i3k_db_mercenaries[self._petInfo.id].name
	if g_i3k_game_context:isInMyHomeLand() then
		i3k_sbean.homeland_pet_position_action(self._locationId, id, self._petInfo.id, name)
	else
		if i3k_db_home_pet.common.isOwnHomeland == 1 and g_i3k_game_context:GetHomeLandData().level == 0 then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17845))
		end
		local data = g_i3k_game_context:getCurHomePetData()
		if g_i3k_game_context:getOtherPetActionTimes() >= i3k_db_home_pet.common.playOtherTimes then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17859, g_i3k_game_context:getOtherPetActionTimes(), i3k_db_home_pet.common.playOtherTimes))
		elseif i3k_game_get_time() - data[self._locationId].lastOtherActionTime < i3k_db_home_pet.common.otherPlayCD then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17858, i3k_db_home_pet.common.otherPlayCD - i3k_game_get_time() + data[self._locationId].lastOtherActionTime))
		else
			i3k_sbean.homeland_pet_position_action(self._locationId, id, self._petInfo.id, name)
		end
	end
end

function wnd_home_pet_dialogue:onRewardBtn(sender)
	if g_i3k_game_context:checkBagCanAddCell(i3k_db_home_pet.moodAwards.needBagSpace, true) then
		local name = i3k_db_mercenaries[self._petInfo.id].name
		if self._petInfo.vArgs[1] ~= "" then
			name = self._petInfo.vArgs[1]
		end
		i3k_sbean.homeland_pet_position_reward(self._locationId, name)
	end
end

function wnd_create(layout)
	local wnd = wnd_home_pet_dialogue.new()
	wnd:create(layout)
	return wnd
end