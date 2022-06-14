local skill_base = include("skillbase");

local magicCDB = class("magicCDB",skill_base)

function magicCDB:ctor(id)
	magicCDB.super.ctor(self,id)
end

function magicCDB:initPosition()
	if(self.skillId <= 0) then
		return 
	end
	-- 设置国王的位置,从表格读取
	if self.caster then
		local data = dataConfig.configs.magicConfig[self.skillId].casterPosition;
		local position = LORD.Vector3(data[1],data[2],data[3]);
		
		if self.caster_self_king ~= true then
			-- 敌方释放魔法，位置做镜像
			position.x = -position.x;
		end
		
--[[
		if #self.targets > 0 then
				local x,y = castMagic.selectGridX,castMagic.selectGridY
				for i,v in ipairs (self.targets)do							
					if(v.server_action_type == SERVER_ACTION_TYPE.REVIVE)then
						x,y = v.target.x ,v.target.y
						break
					end
				end					
				local targetPos = sceneManager.battlePlayer():getWorldPostion(x, y);
				position = targetPos + position;				
				sceneManager.battlePlayer().targetNull:getActor():SetPosition(targetPos);				
		end
		]]---
		
		local targetPos = sceneManager.battlePlayer():getWorldPostion(self.originAction._param.posx, self.originAction._param.posy);		
		if #self.targets > 0 then
				local x,y = nil,nil
				for i,v in ipairs (self.targets)do							
					if(v.server_action_type == SERVER_ACTION_TYPE.REVIVE)then
						x,y = v.target.x ,v.target.y
						break
					end
				end		
				if(x and y)then
					targetPos = sceneManager.battlePlayer():getWorldPostion(x, y);		
				end								
		end				
		
		sceneManager.battlePlayer().targetNull:getActor():SetPosition(targetPos);	
			
		local skilltype = dataConfig.configs.magicConfig[self.skillId].targetType;
		-- 全屏以中心为目标
		if skilltype == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_NONE then
			sceneManager.battlePlayer().targetNull:getActor():SetPosition(battlePrepareScene.centerPosition);
			targetPos.x = battlePrepareScene.centerPosition.x;
			targetPos.y = battlePrepareScene.centerPosition.y;
			targetPos.z = battlePrepareScene.centerPosition.z;
		end
		
		position = targetPos + position;
		print("magic_DAMAGE position x  "..position.x.."  y  "..position.y.."  z  "..position.z);
		self.caster:getActor():SetPosition(position);
				
	end
end

function magicCDB:onStartPreCamera()

	magicCDB.super.onStartPreCamera(self);
	
	local shiftRadio = sceneManager.battlePlayer():getCameraRadio();
	local frequent = math.random();
	
	if frequent < shiftRadio then
		local configData = self:getConfig();
		if configData and self.caster and configData.cameraGfxName then
			local skillName = configData.cameraGfxName;
			
			self.caster:getActor():SetPosition(LORD.Vector3(configData.cameraPosition[1],configData.cameraPosition[2],configData.cameraPosition[3]));
			--local cameraActor = self:getCameraActorNamesFromOrignal();
			local timer = self.caster:getActor():PlaySkill(skillName,false,false,1, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, self.skillId, self.caster:getActor():getActorNameID());
			print("onStartPreCamera timer"..timer);
			self:setPreCameraTimer(timer);
		end	
	end

end

function magicCDB:enterStart()
			
    self.caster:getActor():ClearAttackTargetActors()		
	self.caster.m_Targets = {}
	self.caster.m_TargetsDamage = {}	
	
	if(self.skillId <= 0) then
		return 
	end	
	
	local buffTargetCount = 0;
	
	-- 用虚拟的受击者作为目标
	local targetActor = self:GetTargetActor();
	if targetActor then
		self.caster:getActor():AddAttackTargetActors(targetActor,false);
	end
		
	local damage = {}
	local cure = {}
	local _target_ = nil 	
	for i,v in ipairs (self.targets)do			
			
		if(v.server_action_type == SERVER_ACTION_TYPE.DAMAGE)then		
			_target_= 	sceneManager.battlePlayer():getCropsByIndex(v.target.id)
			sceneManager.battlePlayer():signGrid(_target_.m_PosX,_target_.m_PosY,"r")	
			damage[v.target.id] = 1	
			table.insert(self.caster.m_TargetsDamage,v)	
			table.insert(self.caster.m_Targets,_target_)	
			
		elseif (v.server_action_type == SERVER_ACTION_TYPE.ATTRIBUTE  ) then			
				local actions =  self.targets[i]	
				local tar = actions.target
				local skillInstance = skillSys.createSkill(true,skillSys.skilltype.ATTRIBUTE, -1,tar)						
				table.insert(self.subSkills,skillInstance)				
				skillInstance.palyAfterMainSkill = false	
				skillInstance:play()	
				_target_ = nil 	
		elseif(v.server_action_type == SERVER_ACTION_TYPE.CURE)then			
			_target_= 	sceneManager.battlePlayer():getCropsByIndex(v.target.id)		
			sceneManager.battlePlayer():signGrid(_target_.m_PosX,_target_.m_PosY,"b")
			cure[v.target.id] = 1	
			table.insert(self.caster.m_TargetsDamage,v)		
			table.insert(self.caster.m_Targets,_target_)	
		elseif(v.server_action_type == SERVER_ACTION_TYPE.BUFF)then
			_target_ = 	sceneManager.battlePlayer():getCropsByIndex(v.target.id)		
			sceneManager.battlePlayer():signGrid(_target_.m_PosX,_target_.m_PosY,"r")	
			table.insert(self.caster.m_TargetsDamage,v)	
			table.insert(self.caster.m_Targets,_target_)
			buffTargetCount = buffTargetCount + 1;	
		elseif(v.server_action_type == SERVER_ACTION_TYPE.SUMMON)then	
			local actions =  self.targets[i]		
			local tar = actions.target
			local action ={}  
			action._param ={}
			action._param.targets = {}
			action._param.targets[1] = {summon_Source = tar.summon_Source, m_targetID = tar.m_targetID,m_targetIndex = tar.m_targetIndex, m_count = tar.m_count, m_x = tar.pos.x, m_y = tar.pos.y}
			action._param.targets[1] .shipAttack = tar.shipAttack;
			action._param.targets[1] .shipDefence = tar.shipDefence;
			action._param.targets[1] .shipCritical = tar.shipCritical;
			action._param.targets[1] .shipResilience = tar.shipResilience;
 
			local skillInstance = skillSys.createSkill(true,skillSys.skilltype.SKILL_SUMMON, tar.skillId,action._param.targets, sceneManager.battlePlayer().casterKing,self.originAction)		
			table.insert(self.subSkills,skillInstance)
			--skillInstance.palyAfterMainSkill = false    			
			--skillInstance:play()
			skillInstance.palyAfterMainSkill = true   
			
		elseif(v.server_action_type == SERVER_ACTION_TYPE.REVIVE)then					
				local actions =  self.targets[i]	
				local tar = actions.target
				local skillInstance = skillSys.createSkill(true,skillSys.skilltype.REVIVE, tar.skillId,tar, sceneManager.battlePlayer().casterKing,self.originAction,self.originAction)						
				table.insert(self.subSkills,skillInstance)				
				skillInstance.palyAfterMainSkill = false	
				skillInstance:play()	
 	
		end			
					
		if(_target_ and v.server_action_type ~= SERVER_ACTION_TYPE.SUMMON and v.server_action_type ~= SERVER_ACTION_TYPE.REVIVE)then										
			_target_.HIT_CALLBACK_FINISH = _target_.HIT_CALLBACK_FINISH + 1									
			--echoInfo(" --magic--- self.caster.m_Targets[%d]  index %d   = %d ",i,  self.caster.m_Targets[i].index, self.caster.m_Targets[i].HIT_CALLBACK_FINISH  )	
		end			
	end		
	local skillname = dataConfig.configs.magicConfig[self.skillId].gfxName	
	
	if(skillname ~= nil)then
			
		if(table.nums(damage) > 1 or table.nums(cure) > 1 or buffTargetCount > 1 )then
			self.caster.skillIsAoe =  true
		end
		
		local frequent = math.random();
		local shiftRadio = sceneManager.battlePlayer():getCameraRadio();
		local isPlayCamera = frequent <= 1.0 * shiftRadio;
		
		if isPlayCamera then
			local targetActor = self:GetTargetActor();
			local cameraName = "";
			
			if self.caster.actor then
				cameraName = self.caster.actor:getActorNameID();
			end
			
			if targetActor then
				cameraName = cameraName.."|"..targetActor:getActorNameID();
			end
			
			local skilltype = dataConfig.configs.magicConfig[self.skillId].targetType;
			-- 全屏以中心为目标
			if skilltype == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_NONE or
				skilltype == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_ANY then
				for k,v in pairs (sceneManager.battlePlayer().m_AllCrops) do
					 if(v ~= nil and v.actor )	then	
					 	cameraName = cameraName.."|"..v.actor:getActorNameID();
					 end			
				end
			end
		
			self.m_SkillPlayedTime = self.caster:getActor():PlaySkill(skillname,false,false,1, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, self.skillId, cameraName);
		else
			self.m_SkillPlayedTime = self.caster:getActor():PlaySkill(skillname,false,false,1, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, self.skillId, "");
		end
		
		self.m_SkillPlayed = true
	else
		self.caster:getActor():ClearAttackTargetActors()		
		__directDanmage(self.caster)	
	end		
end


function magicCDB:GetTargetActor()
	local targetType = dataConfig.configs.magicConfig[self.skillId].targetType;
	if targetType == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_ENEMY 
		or targetType == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_FRIEND 
		or targetType == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_UNIT then
			-- 如果不能选空地，就以目标actor为target
			if #self.targets > 0 then
				local unit = sceneManager.battlePlayer():getCropsByIndex(self.targets[1].target.id);
				return unit:getActor();
			else
				print("magicCDB:GetTargetActor error, no target to get!");
				return nil;
			end
	else
			-- 可以选空地，以nullactor为目标
			return sceneManager.battlePlayer().targetNull:getActor();
	end

end
return magicCDB;