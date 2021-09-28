-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_home_pet_other = i3k_class("wnd_home_pet_other", ui.wnd_base)

local OTHERPET = "ui/widgets/jiayuanshouhu2t"

function wnd_home_pet_other:ctor()
	self._petInfo = {}
end

function wnd_home_pet_other:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
end

function wnd_home_pet_other:refresh(petInfo)
	self._petInfo = petInfo
	if i3k_db_home_pet.common.isOwnHomeland == 1 and g_i3k_game_context:GetHomeLandData().level == 0 then
		self._layout.vars.otherActTimes:setText(i3k_get_string(17882))
	else
		self._layout.vars.otherActTimes:setText(i3k_get_string(17881, g_i3k_game_context:getOtherPetActionTimes(), i3k_db_home_pet.common.playOtherTimes))
	end
	self:setOtherPetScroll()
end

function wnd_home_pet_other:setOtherPetScroll()
	self._layout.vars.scroll:removeAllChildren()
	for k, v in pairs(self._petInfo) do
		local node = require(OTHERPET)()
		if v.iArgs[2] == 1 then
			node.vars.petHead:setImage(g_i3k_db.i3k_db_get_head_icon_path(i3k_db_mercenariea_waken_property[v.id].headIcon, true))
		else
			node.vars.petHead:setImage(g_i3k_db.i3k_db_get_head_icon_path(i3k_db_mercenaries[v.id].icon, true))
		end
		if v.vArgs[1] ~= "" then
			node.vars.name:setText(v.vArgs[1])
		else
			node.vars.name:setText(i3k_db_mercenaries[v.id].name)
		end
		node.vars.petHeadBg:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_mercenaries[v.id].rank))
		node.vars.findwayBtn:onClick(self, self.onFindwayBtn, v.iArgs[3])
		self._layout.vars.scroll:addItem(node)
	end
end

function wnd_home_pet_other:onFindwayBtn(sender, id)
	local targetMapId = g_i3k_game_context:GetWorldMapID()
	local pos = i3k_db_home_pet_pos[id].pos
	g_i3k_game_context:SeachPathWithMap(targetMapId, pos, nil, nil,nil, nil, nil, nil, nil)
end

function wnd_create(layout)
	local wnd = wnd_home_pet_other.new()
	wnd:create(layout)
	return wnd
end