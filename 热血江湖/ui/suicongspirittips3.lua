-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_suicongSpiritTips3= i3k_class("wnd_suicongSpiritTips3",ui.wnd_base)


function wnd_suicongSpiritTips3:ctor()

end

function wnd_suicongSpiritTips3:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

function wnd_suicongSpiritTips3:refresh(data)
	local item = g_i3k_game_context:getPetAllSpirits()
	local maxLevel = 0
	for k,v in pairs(item) do
		if data.id == k then
			maxLevel = v
		end
	end
	local str = i3k_get_string(797, maxLevel)
	if data.level == maxLevel then
		str = string.format("(最大级别)")
	end
	self._layout.vars.level:setText(data.level .. "级" .. str)
	self._layout.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_suicong_spirits[data.id][1].icon))
	self._layout.vars.name:setText(i3k_db_suicong_spirits[data.id][1].name)
	local info = i3k_db_suicong_spirits[data.id][data.level]
	local str 
	if info.tips1 == "" then
		str = info.desc
	else
		local petLevel = g_i3k_game_context:getPetLevel(data.petID)
		local temp1 = g_i3k_game_context:GetPetAttributeValue(data.petID, petLevel, info.effectArgs1)
		local temp2 = g_i3k_game_context:GetPetAttributeValue(data.petID, i3k_db_server_limit.sealLevel, info.effectArgs1)
		local AddTips1 = temp1[info.effectArgs1].value * (1 + info.effectArgs3/10000) - temp1[info.effectArgs1].value
		local AddTips2 = temp2[info.effectArgs1].value * (1 + info.effectArgs3/10000) - temp2[info.effectArgs1].value
		local tip1 = string.format(info.tips1, math.modf(AddTips1))
		local tip2 = string.format(info.tips2, math.modf(AddTips2))
		str = info.desc .."\n" .. tip1 .."\n" .. tip2
	end
	self._layout.vars.desc:setText(str)
	self._layout.vars.ok:onClick(self, self.onCloseBtn)
end

function wnd_suicongSpiritTips3:onCloseBtn()
	g_i3k_ui_mgr:CloseUI(eUIID_SpiritTips3)
	g_i3k_ui_mgr:CloseUI(eUIID_StudySpirit)
end

function wnd_create(layout)
	local wnd = wnd_suicongSpiritTips3.new()
		wnd:create(layout)
	return wnd
end
