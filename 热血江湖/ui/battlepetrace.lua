-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------
local INDEX_ONE = 1
local INDEX_TWO = 2

wnd_battlePetRace = i3k_class("wnd_battlePetRace",ui.wnd_base)

function wnd_battlePetRace:ctor()
	self._timeCounter = 0
end

function wnd_battlePetRace:configure()
	local widgets = self._layout.vars
	widgets.descBtn:onClick(self, self.onDescBtn)
	widgets["btn"..INDEX_ONE]:onClick(self, self.onItem, INDEX_ONE)
	widgets["btn"..INDEX_TWO]:onClick(self, self.onItem, INDEX_TWO)
end

function wnd_battlePetRace:refresh()
	self:setUI()
end

function wnd_battlePetRace:onShow()
	self:updateCD(dTime)
end



function wnd_battlePetRace:onUpdate(dTime)
	self._timeCounter = self._timeCounter + dTime
	if self._timeCounter > 0.1 then
		self:updateCD(dTime)
		self._timeCounter = 0
	end
end

function wnd_battlePetRace:setUI()
	local widgets = self._layout.vars
	local items = i3k_db_common.petRace.useItems
	for k, v in ipairs(items) do
		widgets["itemIcon"..k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v, i3k_game_context:IsFemaleRole()))
		local count = g_i3k_game_context:GetBagItemCanUseCount(v)
		widgets["count"..k]:setText("x"..count)
	end
end

function wnd_battlePetRace:updateCD(dTime)
	local leftTime = g_i3k_game_context:getPetRaceUseSkillLeftTime()
	local widgets = self._layout.vars
	local maxTime = i3k_db_common.petRace.useItemsCD
	local items = i3k_db_common.petRace.useItems
	for k, _ in ipairs(items) do
		widgets["cd"..k]:setPercent(leftTime / maxTime * 100)
	end
end

function wnd_battlePetRace:onItem(sender, index)
	local items = i3k_db_common.petRace.useItems
	local itemID = items[index]
	local count = g_i3k_game_context:GetBagItemCanUseCount(itemID)
	if count > 0 then
		if g_i3k_game_context:getCanThrowItem() then
			local hero = i3k_game_get_player_hero()
			if hero and not hero:IsOnRide() then
				local selEntity = i3k_game_get_select_entity()
				local petID = selEntity._id
				i3k_sbean.petRunThrowItems(itemID, petID)
			else
				g_i3k_ui_mgr:PopupTipMessage("骑乘状态下无法扔道具")
			end
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("道具数量不足")
	end
end


function wnd_battlePetRace:onDescBtn(sender)
	-- g_i3k_ui_mgr:PopupTipMessage("描述按钮")
	g_i3k_ui_mgr:OpenUI(eUIID_PetRaceSkillDesc)
end

function wnd_create(layout)
	local wnd = wnd_battlePetRace.new()
	wnd:create(layout)
	return wnd
end
