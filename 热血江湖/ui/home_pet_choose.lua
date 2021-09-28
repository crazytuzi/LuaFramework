-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_home_pet_choose = i3k_class("wnd_home_pet_choose", ui.wnd_base)

local PETWIDGET = "ui/widgets/jiayuanshouhucwt"

function wnd_home_pet_choose:ctor()
	self._location = 1
	self._petId = 0
end

function wnd_home_pet_choose:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
	self._layout.vars.helpBtn:onClick(self, self.onHelpBtn)
end

function wnd_home_pet_choose:refresh(id)
	if id then
		self._location = id
		self._layout.vars.batchBtn:hide()
		self:setOwnedPet()
	else
		self:onCloseUI()
	end
end

function wnd_home_pet_choose:setOwnedPet()
	self._layout.vars.scroll:removeAllChildren()
	local pets = self:sortPetsInfo()
	local children = self._layout.vars.scroll:addChildWithCount(PETWIDGET, 5, #pets)
	for k, v in ipairs(pets) do
		local node = children[k]
		if v.petName and v.petName ~= "" then
			node.vars.name:setText(v.petName)
		else
			node.vars.name:setText(i3k_db_mercenaries[v.id].name)
		end
		if g_i3k_game_context:getPetWakenUse(v.id) then
			node.vars.petIcon:setImage(g_i3k_db.i3k_db_get_head_icon_path(i3k_db_mercenariea_waken_property[v.id].headIcon, true))
		else
			node.vars.petIcon:setImage(g_i3k_db.i3k_db_get_head_icon_path(i3k_db_mercenaries[v.id].icon, true))
		end
		node.vars.petIconBg:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_mercenaries[v.id].rank))
		if g_i3k_game_context:getPetIsInHome(v.id) then
			node.vars.chooseBtn:onClick(self, self.onWrongChange, 1)
			node.vars.state:setText(i3k_get_string(17864))
		elseif v.level >= i3k_db_home_pet.common.level then
			node.vars.chooseBtn:onClick(self, self.onChangeBtn, v.id)
			node.vars.state:setText(i3k_get_string(17863))
		else
			node.vars.chooseBtn:onClick(self, self.onWrongChange, 2)
			node.vars.state:setText(i3k_get_string(17865))
		end
	end
end

function wnd_home_pet_choose:sortPetsInfo()
	local petsInfo = {}
	local pets = g_i3k_game_context:GetAllYongBing()
	for k, v in pairs(pets) do
		if g_i3k_game_context:getPetIsInHome(v.id) then
			v.sortId = v.id + 1000
		elseif v.level >= i3k_db_home_pet.common.level then
			v.sortId = v.id
		else
			v.sortId = v.id + 10000
		end
		table.insert(petsInfo, v)
	end
	table.sort(petsInfo, function(a, b)
		return a.sortId < b.sortId
	end)
	return petsInfo
end

function wnd_home_pet_choose:onChangeBtn(sender, petId)
	i3k_sbean.homeland_pet_position_set(self._location, petId)
end

function wnd_home_pet_choose:onWrongChange(sender, reason)
	if reason == 1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17849))
	elseif reason == 2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17848))
	end
end

function wnd_home_pet_choose:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(17857))
end

function wnd_create(layout)
	local wnd = wnd_home_pet_choose.new()
	wnd:create(layout)
	return wnd
end