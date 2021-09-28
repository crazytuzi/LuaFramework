-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_shen_bing_skill_tips = i3k_class("wnd_shen_bing_skill_tips", ui.wnd_base)

function wnd_shen_bing_skill_tips:ctor()
	
end



function wnd_shen_bing_skill_tips:configure(...)
	
end
function wnd_shen_bing_skill_tips:refresh( skillID, weaponID, tag)
	
	if skillID and weaponID and tag then
		
		local bgRoot = self._layout.vars.bgRoot 
		local pos = bgRoot:getPosition()
		pos.y = pos.y +10
		bgRoot:setPosition(pos)
		local skillName = self._layout.vars.skillName 
		
		local skillLevel = self._layout.vars.skillLevel 
		
		local skillDesc2 = self._layout.vars.skillDesc2 
		
		local skillDesc1 = self._layout.vars.skillDesc1 
		
		local name = i3k_db_skills[skillID].name 
		
		local allShenbing ,useShenbing = g_i3k_game_context:GetShenbingData()
		local id = tonumber(weaponID)
	
		local starlvl = tonumber(allShenbing[id].slvl or 0)
		local index = tag
		local temp = "skill"..index.."lvl"
		
		local lvl = i3k_db_shen_bing_upstar[id][starlvl][temp]
		--local desc = i3k_db_skill_datas[skillID][lvl].desc
		local spArgs1 = i3k_db_skill_datas[skillID][lvl].spArgs1
		local spArgs2 = i3k_db_skill_datas[skillID][lvl].spArgs2
		local spArgs3 = i3k_db_skill_datas[skillID][lvl].spArgs3
		local spArgs4 = i3k_db_skill_datas[skillID][lvl].spArgs4
		local spArgs5 = i3k_db_skill_datas[skillID][lvl].spArgs5
		local commonDesc = i3k_db_skills[skillID].common_desc
		local tmp_str = string.format(commonDesc,spArgs1,spArgs2,spArgs3,spArgs4,spArgs5)
		if skillName then
			skillName:setText(name)
		end
		if skillLevel then
			skillLevel:setText("等级："..lvl)
		end
		if skillDesc1 then
			skillDesc1:setText(tmp_str)
		end
		
		if skillDesc2 then
			skillDesc2:setText("无冷却，使用神兵时自动施放武功")
		end
		
	end
	
end

--[[function wnd_shen_bing_skill_tips:onClose(sender,eventType)
	if eventType ==ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_ShenBingSkillTips)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_shen_bing_skill_tips.new();
		wnd:create(layout, ...);

	return wnd;
end

