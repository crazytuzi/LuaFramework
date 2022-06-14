local skill_base = include("skillbase")
local skillInternalConflict = class("skillInternalConflict",skill_base)

function skillInternalConflict:ctor(id)
	skillInternalConflict.super.ctor(self,id)	
	self.startEd = false
end



function skillInternalConflict:enterStart()
		self.startEd = true	  
		self.__caster = sceneManager.battlePlayer().m_AllCrops[self.targets.target.casterId]
 			
		local damage = self.targets.target					 
		self.__caster.m_Targets = {}
		self.__caster.m_TargetsDamage = {}	
 
		local action ={}		
		action._param = {targetNum = 1,targets ={ id = damage.id, hurt ={server_action_type = self.targets.server_action_type, target ={hitToDead = damage.hitToDead, deadFlag = damage.deadFlag, damageFlag = damage.damageFlag,damage = damage.damage,damageSource = damage.damageSource}}}}	
		
		 
		local t = { 154,155,188,189,68}  ---GM天使联盟 为了部落
		
		if(table.find(t,self.skillId ))then
			self.__caster:enterStateAttack(action._param.targets)
		else
		
			table.insert(self.__caster.m_TargetsDamage,action._param.targets.hurt)			
			table.insert(self.__caster.m_Targets,sceneManager.battlePlayer():getCropsByIndex(action._param.targets.id))	
			__directDanmage(self.__caster)	
		end
		
 
end

function skillInternalConflict:OnTick(dt)
	 local res = true	
			if(self.startEd == true)then					
				res =  self.__caster:IsActionFinish() and  ___targertHurtEnd(self.__caster)	
			else
				res = false
			end								
	return res			
end
function skillInternalConflict:getCaster()
	return self.caster 
end	

return skillInternalConflict