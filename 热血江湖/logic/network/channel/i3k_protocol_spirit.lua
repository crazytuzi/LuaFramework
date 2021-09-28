------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

----------------------------------------------------
--心法学习
function i3k_sbean.goto_spirit_learn(spiritId, level,percent)
	local data = i3k_sbean.spirit_learn_req.new()
	data.spiritId = spiritId
	data.level = level
	data.percent = percent
	i3k_game_send_str_cmd(data,"spirit_learn_res")
end

function i3k_sbean.spirit_learn_res.handler(bean,req)
	if bean.ok ~= 0 then
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:SetXinfaUpLevlData(req.spiritId, req.level,req.percent)
		g_i3k_game_context:ShowPowerChange()
		g_i3k_game_context:LeadCheck();

		DCEvent.onEvent("气功学习", { ["气功ID"] = tostring(req.spiritId)})
	end
end

--心法研读
function i3k_sbean.goto_spirit_levelup(spiritId, level,percent)
	local data = i3k_sbean.spirit_levelup_req.new()
	data.spiritId = spiritId
	data.level = level
	data.percent = percent
	i3k_game_send_str_cmd(data,"spirit_levelup_res")
end

function i3k_sbean.spirit_levelup_res.handler(bean,req)
	if bean.ok ~= 0 then
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:SetXinfaUpLevlData(req.spiritId, req.level,req.percent)
		g_i3k_game_context:ShowPowerChange()

		DCEvent.onEvent("气功升级", { ["气功ID"] = tostring(req.spiritId)})
	end
end

--心法装备
function i3k_sbean.goto_spirit_install(spiritId,percent)--
	local data = i3k_sbean.spirit_install_req.new()
	data.spiritId = spiritId
	data.percent = percent
	i3k_game_send_str_cmd(data,"spirit_install_res") 
end

function i3k_sbean.spirit_install_res.handler(bean, req)
	if bean.ok ~= 0 then
		g_i3k_game_context:SetUseXinfaByType(req.spiritId, true,req.percent)--
		
		local role_all_skill,role_all_skill_use = g_i3k_game_context:GetRoleSkills()
		local passiveSkill = g_i3k_game_context:GetRolePassiveSkills()
		for i,v in ipairs(role_all_skill_use) do
			if passiveSkill[v] then 
				return
			end 
		end
		g_i3k_game_context:checkSkillPrePassive()
	end
end

-----------------------------------
--心法卸载
function i3k_sbean.goto_spirit_uninstall(id,percent)
	local data = i3k_sbean.spirit_uninstall_req.new()
	data.spiritId = id
	data.percent = percent
	i3k_game_send_str_cmd(data,"spirit_uninstall_res") 
end

function i3k_sbean.spirit_uninstall_res.handler(bean, req)
	if bean.ok ~= 0 then
		g_i3k_game_context:SetUseXinfaByType(req.spiritId, false,req.percent)
	end
end
-----------------------------------
