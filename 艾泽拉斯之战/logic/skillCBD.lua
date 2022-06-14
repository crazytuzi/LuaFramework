local skill_base = include("skillbase")
local skill_CBD = class("skill_CBD",skill_base)

function skill_CBD:ctor(id)
	skill_CBD.super.ctor(self,id)	
end



function skill_CBD:enterStart()
	
	self.caster:getActor():ClearAttackTargetActors()		
	self.caster.m_Targets = {}
	self.caster.m_TargetsDamage = {}
	--echoInfo("  --skill---   id  = %d     ",  self.skillId )	
	--print("skill_CBD:enterStart() "..self.skillId.." caster index "..self.caster.index.." HIT_CALLBACK_FINISH "..self.caster.HIT_CALLBACK_FINISH);
	
	--self.caster.HIT_CALLBACK_FINISH = 0;
	
	local skillname = dataConfig.configs.skillConfig[self.skillId].actionName
	local attName = dataConfig.configs.skillConfig[self.skillId].aoeAttName;
	--echoInfo("  --skill---   id  = %d     ",  self.skillId )	
	 
	local _target = {}  
	--dump(self.targets)	 	
	local AddAttackTargetActors = false
 
	local damage = {}
	local cure = {}
	 
	local size = #(self.targets)
	local addTarget = false
	
	local damageFlag = nil;
	
	local buffTargetCount = 0;
		
	local _target_ = nil
	for i = 1 , size do		
		local v = self.targets[i]
		addTarget = false
		if(v.server_action_type == SERVER_ACTION_TYPE.DAMAGE)then	
 
 			--print("v.target.damageSource"..v.target.damageSource);
			if(v.target.damageSource == enum.SOURCE.SOURCE_FORCE_SKILL)then
				--dump(v);
				local skillInstance = skillSys.createSkill(true,skillSys.skilltype.INTERNAL_CONFLICT,self.skillId,v, sceneManager.battlePlayer().m_AllCrops[v.target.casterId ],self.originAction)									
				table.insert(self.subSkills,skillInstance)								
				skillInstance.palyAfterMainSkill = true                 ---内讧
				--dump(skillInstance.targets);
			else				
				_target_ = 	sceneManager.battlePlayer():getCropsByIndex(v.target.id)
				sceneManager.battlePlayer():signGrid(_target_.m_PosX,_target_.m_PosY,"r")	
				table.insert(self.caster.m_TargetsDamage,v)	
				table.insert(self.caster.m_Targets,_target_)						
				damage[v.target.id] = 1				
				addTarget = true		
				-- 根据是否暴击决定是否播放摄像机动画
				if damageFlag == nil then
					damageFlag = v.target.damageFlag;
				end
			end			
		elseif (v.server_action_type == SERVER_ACTION_TYPE.ATTRIBUTE  ) then			
				local actions =  self.targets[i]	
				local tar = actions.target
				local skillInstance = skillSys.createSkill(true,skillSys.skilltype.ATTRIBUTE, -1,tar)	
				table.insert(self.subSkills,skillInstance)				
				skillInstance.palyAfterMainSkill = false	
				skillInstance:play()		
		elseif(v.server_action_type == SERVER_ACTION_TYPE.CURE)then			
			_target_ = 	sceneManager.battlePlayer():getCropsByIndex(v.target.id)		
			sceneManager.battlePlayer():signGrid(_target_.m_PosX,_target_.m_PosY,"b")
			table.insert(self.caster.m_TargetsDamage,v)			
			table.insert(self.caster.m_Targets,_target_)	
				
			cure[v.target.id] = 1		
			addTarget = true	
		elseif(v.server_action_type == SERVER_ACTION_TYPE.BUFF)then
			_target_ = 	sceneManager.battlePlayer():getCropsByIndex(v.target.id)		
			sceneManager.battlePlayer():signGrid(_target_.m_PosX,_target_.m_PosY,"r")		
			table.insert(self.caster.m_TargetsDamage,v)	
			table.insert(self.caster.m_Targets,_target_)
			buffTargetCount = buffTargetCount + 1;	
			addTarget = true
			
			-- 天神下凡技能需要创建子技能
			if v.target.skillId == enum.SKILL_TABLE_ID.TianShenXiaFan and v.target.bufferId == enum.BUFF_TABLE_ID.TianShenXiaFan then
			
				--print("enum.SKILL_TABLE_ID.TianShenXiaFan self.caster self.skillId "..self.skillId);
				--dump(self.caster);
				local skillInstance = skillSys.createSkill(true,skillSys.skilltype.TIAN_SHEN_XIA_FAN, self.skillId, 
							v, sceneManager.battlePlayer().m_AllCrops[v.target.casterId], self.originAction);
				table.insert(self.subSkills,skillInstance)								
				skillInstance.palyAfterMainSkill = true;
			end					
		elseif(v.server_action_type == SERVER_ACTION_TYPE.SUMMON)then				
			local actions =  self.targets[i]		
			local tar = actions.target
			local action ={}  
			action._param ={}
			action._param.targets = {}
			action._param.targets[1] = {       summon_Source = tar.summon_Source, m_targetID = tar.m_targetID,m_targetIndex = tar.m_targetIndex, m_count = tar.m_count, m_x = tar.pos.x, m_y = tar.pos.y, casterId = tar.casterId }

			action._param.targets[1] .shipAttack = tar.shipAttack;
			action._param.targets[1] .shipDefence = tar.shipDefence;
			action._param.targets[1] .shipCritical = tar.shipCritical;
			action._param.targets[1] .shipResilience = tar.shipResilience;



			--print(" action._param.targets[1].casterId "..action._param.targets[1].casterId);
			local skillInstance = skillSys.createSkill(true,skillSys.skilltype.SKILL_SUMMON, tar.skillId,action._param.targets,sceneManager.battlePlayer().m_AllCrops[action._param.targets[1].casterId],self.originAction)						
	 	
			table.insert(self.subSkills,skillInstance)
			
			if enum.SKILL_TABLE_ID.DeadSummon == self.skillId then
				skillInstance.palyAfterMainSkill = true;
			else
				skillInstance:play();
			end

		elseif(v.server_action_type == SERVER_ACTION_TYPE.REVIVE)then		
								
				local actions =  self.targets[i]	
				local tar = actions.target
				local skillInstance = skillSys.createSkill(true,skillSys.skilltype.REVIVE, tar.skillId,tar, sceneManager.battlePlayer().m_AllCrops[tar.casterId],self.originAction)						
	 	
				table.insert(self.subSkills,skillInstance)
				
				
				if(tar.casterId == tar.target ) then --- 自己复活自己
						skillInstance.palyAfterMainSkill = true
						
					if self.skillId == enum.SKILL_TABLE_ID.YongHengShiXiang then
						self.caster.m_bAlive = true;
					end				
				else
						skillInstance.palyAfterMainSkill = true	
						--skillInstance:play()	
				end	
				
				-- 加一个空目标
				if sceneManager.battlePlayer().targetNull:getActor() and tar.x and tar.y then
					local position =  sceneManager.battlePlayer():getWorldPostion(tar.x, tar.y);
					sceneManager.battlePlayer().targetNull:getActor():SetPosition(position);
					
					self.caster:getActor():AddAttackTargetActors(sceneManager.battlePlayer().targetNull:getActor(),false);
				end
									
		end					

	    if( addTarget == true	)then
			--self.caster.m_Targets[i]:getActor():FreeAllSkillAttack()
			--print("_target_.HIT_CALLBACK_FINISH ".._target_.HIT_CALLBACK_FINISH.." _target_.index ".._target_.index);				
			_target_.HIT_CALLBACK_FINISH = _target_.HIT_CALLBACK_FINISH + 1		
			--print(self.caster.m_Targets[i]:getActor())
			--print(self.caster.m_Targets[i].index)		
			--print(" skillId "..self.skillId)
			--echoInfo("  --skill---  self.caster.m_Targets[%d]  index %d   = %d ",i,  self.caster.m_Targets[i].index, self.caster.m_Targets[i].HIT_CALLBACK_FINISH  )		
			if(AddAttackTargetActors == false)then			
				AddAttackTargetActors = true
				self.caster:getActor():AddAttackTargetActors(_target_:getActor(),false)				
			end		
		
		end		
	end		
	
	-- 显示名称移到外面
	self:displayname();
	
	if(skillname ~= nil)then
		
		local cameraActors = self:getCameraActorNames();
		if(table.nums(damage) > 1 or table.nums(cure) > 1 or buffTargetCount > 1)then
			self.caster.skillIsAoe =  true
		end
		
		self.m_SkillPlayed = true
		
		self:playSkill(self.caster, self.skillId, damageFlag, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, self.skillId, cameraActors);
		
		if self.m_SkillPlayedTime <= 0 then
			__directDanmage(self.caster, true);
		end
			
	else
		self.caster:getActor():ClearAttackTargetActors()		
		__directDanmage(self.caster, true)
		
		if attName then
			for k,v in pairs(self.caster.m_Targets) do
				if v:getActor() then
					v:getActor():AddSkillAttack(attName, self.caster:getActor(),false);
				end
			end
		end
		
	end
	
end

return skill_CBD