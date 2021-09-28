require "Core.Role.Skill.Scripts.AbsScript";
-- 隐身脚本
VanishScript = class("VanishScript", AbsScript)

local pi = math.pi;
local sin = math.sin;
local cos = math.cos;

VanishScript.script = {};

function VanishScript:New(skillStage)
	if(skillStage and skillStage.role) then
		local script = VanishScript.script[skillStage.role.id];
		if(script) then
			script:SetVanishTime((tonumber(skillStage.info.para[1]) + tonumber(skillStage.info.para[2])) / 1000);
			return nil;
		end
		self = {};
		setmetatable(self, {__index = VanishScript});
		self:SetStage(skillStage);
		VanishScript.script[skillStage.role.id] = self;
		return self;
	end
	return nil
end

function VanishScript:SetVanishTime(time)	
	if(self._vanishtime < time) then		
		self._vanishtime = time;
	end
end

function VanishScript:_Init(role, para)
	self._vanishprocess = tonumber(para[1]) / 1000;
	self._currVanishprocess = self._vanishprocess
	self._vanishtime = tonumber(para[2]) / 1000;
	
	self:_InitTimer(0, - 1);
	if(self._role) then
		self._role:SetEquipAndWeaponeEffectActive(false)
	end
	self:_OnTimerHandler();
end



function VanishScript:_OnTimerHandler()
	local deltaTime = Time.fixedDeltaTime;
	local role = self._role;
	if(role and(not role:IsDie())) then
		if(self._currVanishprocess > 0) then
			self._currVanishprocess = self._currVanishprocess - deltaTime;
			local r = self._currVanishprocess / self._vanishprocess;
			if(r < 0) then
				r = 0;
			end
			role:SetAlpha(r)
		else
			if(self._vanishtime > 0) then
				self._vanishtime = self._vanishtime - deltaTime;
			else
				self:Dispose();
			end
		end
	else
		self:Dispose();
	end
end


function VanishScript:_OnDisposeHandler()
	if not self._role then return end
	VanishScript.script[self._role.id] = nil;
	if(self._role) then
		self._role:SetEquipAndWeaponeEffectActive(true)
		self._role:SetAlpha(1);
	end	
end 