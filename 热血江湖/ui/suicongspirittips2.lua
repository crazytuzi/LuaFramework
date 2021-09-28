-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_suicongSpiritTips2= i3k_class("wnd_suicongSpiritTips2",ui.wnd_base)


function wnd_suicongSpiritTips2:ctor()

end

function wnd_suicongSpiritTips2:configure()
	local widgets = self._layout.vars
end

function wnd_suicongSpiritTips2:refresh(petID, oldSpiritID, newSpiritID, newSpiritLvl, index)
	local spirits = g_i3k_game_context:getPetSpiritsData(petID)
	local oldSpiritLvl = 0
	for k,v in pairs(spirits) do
		if v.id == oldSpiritID then
			oldSpiritLvl = v.level
		end
	end
	local temp = {}
	local item = g_i3k_game_context:getPetAllSpirits()
	temp[1] = {id = oldSpiritID, level = oldSpiritLvl, maxLevel = 0}
	temp[2] = {id = newSpiritID, level = newSpiritLvl, maxLevel = 0}
	for k,v in pairs(item) do
		if oldSpiritID == k then
			temp[1].maxLevel = v
		end
		if newSpiritID == k then
			temp[2].maxLevel = v
		end
	end
	for i=1, 2 do
		local str = i3k_get_string(797, temp[i].maxLevel)
		if temp[i].level == temp[i].maxLevel then
			str = string.format("(最大级别)")
		end
		self._layout.vars["level".. i]:setText(temp[i].level .. "级" .. str)
		self._layout.vars["icon" .. i]:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_suicong_spirits[temp[i].id][1].icon))
		self._layout.vars["name" .. i]:setText(i3k_db_suicong_spirits[temp[i].id][1].name)
		local info = i3k_db_suicong_spirits[temp[i].id][temp[i].level]
		local str 
		if info.tips1 == "" then
			str = info.desc
		else
			local petLevel = g_i3k_game_context:getPetLevel(petID)
			local temp1 = g_i3k_game_context:GetPetAttributeValue(petID, petLevel, info.effectArgs1)
			local temp2 = g_i3k_game_context:GetPetAttributeValue(petID, i3k_db_server_limit.sealLevel, info.effectArgs1)
			local AddTips1 = temp1[info.effectArgs1].value * (1 + info.effectArgs3/10000) - temp1[info.effectArgs1].value
			local AddTips2 = temp2[info.effectArgs1].value * (1 + info.effectArgs3/10000) - temp2[info.effectArgs1].value
			local tip1 = string.format(info.tips1, math.modf(AddTips1))
			local tip2 = string.format(info.tips2, math.modf(AddTips2))
			str = info.desc .."\n" .. tip1 .."\n" .. tip2
		end
		self._layout.vars["desc" .. i]:setText(str)
	end
	self._layout.vars.loseBtn:onClick(self, self.loseBtn)
	self._layout.vars.saveBtn:onClick(self, self.saveBtn, {petID = petID, id = newSpiritID, level = newSpiritLvl, index = index})
end

function wnd_suicongSpiritTips2:loseBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_SpiritTips2)
end

function wnd_suicongSpiritTips2:saveBtn(sender, data)
	i3k_sbean.petspirit_replace(data)
end

function wnd_create(layout)
	local wnd = wnd_suicongSpiritTips2.new()
		wnd:create(layout)
	return wnd
end
