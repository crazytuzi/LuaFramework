local magic = include("magic");

local magicSummon = class("magicSummon",magic)

function magicSummon:ctor(id)
	magicSummon.super.ctor(self,id)
end

magicSummon.APEAR_TIME = 1000;
magicSummon.AFFECT_TIME = 2000;

magicSummon.STATE = {
	['INVALID'] = -1,
	['APPEARING'] = 0,
	['LASTING'] = 1,
};

magicSummon.isMagic = true;

function magicSummon:initPosition()
	
	-- 设置国王的位置,从表格读取
	magicSummon.isMagic =  iskindof(cropsUnit,"kingClass")
	if(magicSummon.isMagic)then
		if self.caster then
			local data = dataConfig.configs.magicConfig[self.skillId].casterPosition;
			local position = LORD.Vector3(data[1],data[2],data[3]);		
			if self.caster_self_king ~= true then
				-- 敌方释放魔法，位置做镜像
				position.x = -position.x;
			end

			local targetPos = sceneManager.battlePlayer():getWorldPostion(self.targets[1].m_x, self.targets[1].m_y);
			position = targetPos + position;				
			
			print("magicSummon position x  "..position.x.."  y  "..position.y.."  z  "..position.z);
			self.caster:getActor():SetPosition(position);
		end	
	end

end

function magicSummon:enterStart()
		
	local targetPos = sceneManager.battlePlayer():getWorldPostion(self.targets[1].m_x, self.targets[1].m_y);
	sceneManager.battlePlayer().targetNull:getActor():SetPosition(targetPos);
	--print("targetPos x "..targetPos.x.." y "..targetPos.y.." z "..targetPos.z);
	
	self.timeStamp = 0;
	self.state = magicSummon.STATE.APPEARING;

	--self.caster:getActor():ClearAttackTargetActors();
	--self.caster:getActor():AddAttackTargetActors(sceneManager.battlePlayer().targetNull:getActor(),false)
	
	--local skillname = dataConfig.configs.magicConfig[self.skillId].gfxName	
	--self.m_SkillPlayedTime = self.caster:getActor():PlaySkill(skillname,false,false,1);
	--self.m_SkillPlayed = true
	
	-- call summon
	local force = nil
	if(self.casterIsKing)	then
		force = self.originAction._id
	else
		force = self.caster:getForces()	
	end
	
	self.summon = sceneManager.battlePlayer():createSUMMONcrops(self.targets,force);
	magicSummon.APEAR_TIME = self.summon:getActor():PlaySkill("appear", false, false, 1);
	
end

function magicSummon:OnTick(dt)
	-- return ture is end
	if self.state ==  magicSummon.STATE.APPEARING then
		if self.timeStamp > magicSummon.APEAR_TIME then
			self.state = magicSummon.STATE.LASTING;
			-- call summon
			--sceneManager.battlePlayer():createSUMMONcrops(self.targets,self.originAction._id);
					
			if magicSummon.isMagic then
				self.caster:getActor():ClearAttackTargetActors();
				self.caster:getActor():AddAttackTargetActors(sceneManager.battlePlayer().targetNull:getActor(),false);
				local skillname = dataConfig.configs.magicConfig[self.skillId].gfxName;
				print("magicSummon:OnTick  "..skillname.." self.skillId "..self.skillId);
				self.m_SkillPlayedTime = self.caster:getActor():PlaySkill(skillname,false,false,1, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, self.skillId);
			end
			self.summon:getActor():PlaySkill("idle", false, false, 1);
		else
			self.timeStamp = self.timeStamp + dt;
		end
	elseif self.state ==  magicSummon.STATE.LASTING then
		if self.timeStamp > magicSummon.AFFECT_TIME then
			-- action over
			self.state = magicSummon.STATE.INVALID;
			return true;
		else
			self.timeStamp = self.timeStamp + dt;
		end
	else
		return true;
	end
	
	return false;
end

return magicSummon;