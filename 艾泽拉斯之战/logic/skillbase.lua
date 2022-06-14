local skill_base = class("skill_base")

function skill_base:ctor(id)
	self.caster = nil
	self.targets = nil
	self.skillId = id
	self.m_SkillPlayedTime = 0
	self.m_SkillPlayed = false
	self.palyAfterMainSkill = false	
	self.originAction = nil
	self.playEndIdle = false;
	self.preCameraTimer = 0;
	self.casterIsKing = false;
	self.preCameraStart = false;
	self.isSub = false		
end

function skill_base:Init(data)	
	self.caster = data.caster
	self.targets =  data.targets
	self.tickOver = false	
	self.subSkills = {} 
end

function skill_base:getConfig()
	if self.casterIsKing then
		return dataConfig.configs.magicConfig[self.skillId];
	else
		return dataConfig.configs.skillConfig[self.skillId];
	end
end

function skill_base:getPreCameraTimer()
	return self.preCameraTimer;
end

function skill_base:setPreCameraTimer(t)
	self.preCameraTimer = t;
end

function skill_base:getCaster()
	return self.caster 
end	

-- 获得特写镜头需要显示的actor列表，用|隔开
function skill_base:getCameraActorNames()
	local result = "";
	
	local casterActorName = "";
	
	if self.caster.actor then
		casterActorName = self.caster.actor:getActorNameID();
		result = casterActorName;
	end
	
	for k,v in ipairs(self.caster.m_Targets) do
		if v:getActor() then
			local actorName = v:getActor():getActorNameID();
			if not string.match(result, actorName) then
				result = result.."|"..actorName;
			end
		end
	end
	
	return result;
end

-- 从self.target中获得
function skill_base:getCameraActorNamesFromOrignal()
	local result = "";
	
	local casterActorName = "";
	
	if self.caster.actor then
		casterActorName = self.caster.actor:getActorNameID();
		result = casterActorName;
	end
	
	for k,v in ipairs(self.targets) do
		local targetUnit = sceneManager.battlePlayer():getCropsByIndex(v.target.id);
		if targetUnit and targetUnit:getActor() then
			local actorName = targetUnit:getActor():getActorNameID();
			if not string.match(result, actorName) then
				result = result.."|"..actorName;
			end
		end
	end
	
	return result;
end

--[[
function skill_base:isPlayCamera(damageFlag)

	if damageFlag == nil then
		-- 加buff，治疗，召唤，复活，都没有伤害flag，目前100%触发
		return true;
	end
	
	local frequent = math.random();
	--print("frequent "..frequent);
	--print(damageFlag);
	local isPlayCamera = false;
		
	if damageFlag == enum.DAMAGE_FLAG.DAMAGE_FLAG_NORMAL then
		isPlayCamera = frequent <= dataConfig.configs.ConfigConfig[0].skillCF;
		--print("skill DAMAGE_FLAG_NORMAL "..tostring(isPlayCamera));
	elseif damageFlag == enum.DAMAGE_FLAG.DAMAGE_FLAG_CRITICAL then
		isPlayCamera = frequent <= dataConfig.configs.ConfigConfig[0].skillCriticalCF;
		--print("skill DAMAGE_FLAG_CRITICAL ");
	end
	
	return isPlayCamera;
end
--]]

function skill_base:playSkill(caster, skillID, damageFlag, userdata1, userdata2, cameraActors)
	
	if cameraActors == nil then
		cameraActors = self:getCameraActorNamesFromOrignal();
	end
	
	local frequent = math.random();
	local isPlayCamera = false;
	local skillname = dataConfig.configs.skillConfig[skillID].actionName;
	local skillCritName = dataConfig.configs.skillConfig[skillID].actionName_crit;
	
	local playSkillName = skillname;
	
	local shiftRadio = sceneManager.battlePlayer():getCameraRadio();
	
	if damageFlag == enum.DAMAGE_FLAG.DAMAGE_FLAG_NORMAL then
		isPlayCamera = frequent <= dataConfig.configs.ConfigConfig[0].skillCF * shiftRadio;
	elseif damageFlag == enum.DAMAGE_FLAG.DAMAGE_FLAG_CRITICAL then
		if skillCritName == skillname or skillCritName == nil then
			-- 如果和普通技能动作一样，或者不填
			isPlayCamera = frequent <= dataConfig.configs.ConfigConfig[0].skillCriticalCF * shiftRadio;
		else
			playSkillName = skillCritName;
			isPlayCamera = frequent <= dataConfig.configs.ConfigConfig[0].skill_critCF * shiftRadio;
		end
	else
		isPlayCamera = frequent <= dataConfig.configs.ConfigConfig[0].skillCF * shiftRadio;
	end
	
	--print(" isPlayCamera "..tostring(isPlayCamera));
	if isPlayCamera then
		self.m_SkillPlayedTime = caster:getActor():PlaySkill(playSkillName,false,false,1, userdata1, userdata2, cameraActors);
	else
		self.m_SkillPlayedTime = caster:getActor():PlaySkill(playSkillName,false,false,1, userdata1, userdata2, "");
	end
	
end

function skill_base:OnTick(dt)
		
	local res = nil	
	if(self.tickOver == false) then	
		if(self.m_SkillPlayed )then		
			local skillname =  "skillName"			
			local casteName   = self.caster.m_name			
			skillname = dataConfig.configs.skillConfig[self.skillId].name			
			sceneManager.battlePlayer().debuginfo = string.format("cast name: %s, skill name: %s, skill id: %d ", casteName, skillname, self.skillId);				
			self.m_SkillPlayedTime  = self.m_SkillPlayedTime - dt			
			--[[
			if (not self.playEndIdle) and self.m_SkillPlayedTime <= 0 then
				if(self.caster and iskindof(self.caster,"cropsUnit") )then	
					self.caster:getActor():PlaySkill("idle",false,false,1, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON)	
				end
				self.playEndIdle = true;
			end
			]]--
			if(self.m_SkillPlayedTime <= 0 and ___targertHurtEnd(self:getCaster()))then
				  
				  self:PlayAfterMainSkill()
				  res = true

			else
				res = false		 
			end
																	
		else
			if( ___targertHurtEnd(self:getCaster()) )then
			  	self:PlayAfterMainSkill()
				res = true		
			else
				res = false		
			end
		 
		end								
	else				
		res = true	
	end
	
	local sub = true
	for i ,v in pairs(self.subSkills) do
		 if( v:OnTick(dt) == false or ( ___targertHurtEnd(v:getCaster())  == false))then
			sub = false
		 end		
	end
	if(res and sub)then
		self:enterEnd()	
	end
	
	return res and sub
end

function skill_base:enterStart()	
end

function skill_base:initPosition()
	
end

function skill_base:enterProcess()
end	
function skill_base:PlayAfterMainSkill()
	self.tickOver = true
	self.m_SkillPlayed = false	
	self.m_SkillPlayedTime = 0
		
	for i ,v in pairs(self.subSkills) do
		 if(  v.handle ~= true and v.palyAfterMainSkill == true)then
			 v:play()
			 v.handle = true
		  end		
	end				
end	
function skill_base:enterEnd()
	self.tickOver = true
	self.m_SkillPlayed = false	
	self.m_SkillPlayedTime = 0	
	if(self.caster)then
		self.caster.m_Targets = {};
		self.caster.m_TargetsDamage = {};
		self.caster:enterStateIdle()
	end
	table.removeWithValue(skillSys.allSkill,self)
	self.caster = nil
	self.targets = nil			
	return true
end

function skill_base:onStartPreCamera()
	self.preCameraStart = true;
end

function skill_base:onEndPreCamera()
	if self.preCameraStart == true then
		self:initPosition();
		self:enterStart();
		self.preCameraStart = false;
	end
end

function skill_base:play()
	-- 标记结束时是否已经切过idle了
	self.playEndIdle = false;
	
	-- 前置摄像机
	self:onStartPreCamera();

	if self:getPreCameraTimer() <= 0 then
		self:onEndPreCamera();
	end
end

function skill_base:isSubSkill()
	return self.isSub;
end

function skill_base:displayname()
	if self.skillId > 0 and self.caster then
		local displayName = dataConfig.configs.skillConfig[self.skillId].displayName			
		if(displayName)then
			battleText.addHitText(displayName, self.caster.index, "skillword", "skill")
		end
	end
end

return skill_base;