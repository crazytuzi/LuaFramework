local skill_base = include("skillbase")
local skillHuoJianJiZhong = class("skillHuoJianJiZhong",skill_base)

function skillHuoJianJiZhong:ctor(id)
	skillHuoJianJiZhong.super.ctor(self,id)
end

function skillHuoJianJiZhong:enterStart()

	self.caster:getActor():ClearAttackTargetActors();
	self.caster.m_Targets = {};
	self.caster.m_TargetsDamage = {};	 
	local size = #(self.targets);	
	
	local hasDamage = false;
	local targetList = {};
	
	local targetGridX = nil;
	local targetGridY = nil;
	
	for i = 1 , size do		
		local v = self.targets[i]
		
		local _target_ = nil;
		
		if(v.server_action_type == SERVER_ACTION_TYPE.DAMAGE)then	
			
			hasDamage = true;
			
			_target_ = 	sceneManager.battlePlayer():getCropsByIndex(v.target.id);
			sceneManager.battlePlayer():signGrid(_target_.m_PosX,_target_.m_PosY,"r");
			table.insert(self.caster.m_TargetsDamage,v);
			table.insert(self.caster.m_Targets,_target_);						

		elseif(v.server_action_type == SERVER_ACTION_TYPE.BUFF)then
		
			_target_ = 	sceneManager.battlePlayer():getCropsByIndex(v.target.id);
			sceneManager.battlePlayer():signGrid(_target_.m_PosX,_target_.m_PosY,"r");
			table.insert(self.caster.m_TargetsDamage,v);
			table.insert(self.caster.m_Targets,_target_);

		end
		
		if _target_ then
			targetList[_target_] = 1;
		end
		
	end

	-- 加target
  --播放时间
  self.m_SkillPlayedTime = 1000;
  self.m_SkillPlayed = true;
  
	for k,v in pairs(targetList) do
		self.caster:getActor():AddAttackTargetActors(k:getActor(),false);
	end
		  
  if hasDamage == false then
  
		-- 没有伤害，认为只是删buff
		-- 设置位置
		
		local buffInstance = bufferSys.GetBuffer(enum.BUFF_TABLE_ID.HuoJianYinDao, self.caster.index, self.caster);
		
		if buffInstance then
			local layer = buffInstance:GetLayer();
			if layer > 0 then
				targetGridX = math.fmod((layer - 1), 7);
				targetGridY = math.floor((layer - 1)/7);
				
				print("layer "..layer);
				print("targetGridX "..targetGridX);
				print("targetGridY "..targetGridY);
			end
		end
			
		-- 没有伤害，往空地放个att，然后把buff相关的删除掉

		local attName = dataConfig.configs.skillConfig[self.skillId].aoeAttName;
		
		if attName then
			if sceneManager.battlePlayer().targetNull:getActor() and targetGridX and targetGridY then
				local position =  sceneManager.battlePlayer():getWorldPostion(targetGridX, targetGridY);
				sceneManager.battlePlayer().targetNull:getActor():SetPosition(position);
				sceneManager.battlePlayer().targetNull:getActor():AddSkillAttack(attName, self.caster:getActor(), false);
			end
		end
		
		__directDanmage(self.caster, true);
			
	else
		
		__directDanmage(self.caster, true);
			
		-- 有伤害，把att加上
		local attName = dataConfig.configs.skillConfig[self.skillId].aoeAttName;
		
		if attName then
			for k,v in pairs(self.caster.m_Targets) do
				if v:getActor() and v ~= self.caster then
					v:getActor():AddSkillAttack(attName, self.caster:getActor(),false);
				end
			end
		end
			
	end
	
end

return skillHuoJianJiZhong