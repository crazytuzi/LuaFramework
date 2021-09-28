local newSkillConfigHandler = {}

newSkillConfigHandler["SkillConfig"] = function(skillId)
	--print("newSkillConfigHandler")
	local canRegister = getConfigItemByKey("SkillCfg","skillID",skillId,"canRegister")
	if canRegister then
		if canRegister == 0 then
			return 
		else
			if MRoleStruct and MRoleStruct:getAttr(ROLE_LEVEL) < 10 then
				return
			end
			
			local layer = require("src/layers/skillToConfig/newSkillConfigLayer").new(skillId)
			G_MAINSCENE.base_node:addChild(layer, 190)
		end
	end
end

return newSkillConfigHandler