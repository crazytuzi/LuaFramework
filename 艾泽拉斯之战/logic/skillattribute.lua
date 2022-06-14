local skillbase = include("skillbase");
local skill_ATTRIBUTE = class("skill_ATTRIBUTE",skillbase)


function skill_ATTRIBUTE:ctor(id)
	skill_ATTRIBUTE.super.ctor(self,id)	
end

function skill_ATTRIBUTE:enterStart()
	sceneManager.battlePlayer():_AttributeChange(self.targets)		
		
end

return skill_ATTRIBUTE