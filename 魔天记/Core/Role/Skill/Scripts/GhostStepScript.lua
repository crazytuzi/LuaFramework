require "Core.Role.Skill.Scripts.AbsScript";
-- 鬼步脚本
GhostStepScript = class("GhostStepScript", AbsScript)

local pi = math.pi;
local sin = math.sin;
local cos = math.cos;
local atan2 = math.atan2;

function GhostStepScript:New(skillStage)
	self = {};
	setmetatable(self, {__index = GhostStepScript});
	self:SetStage(skillStage);
	return self;
end

function GhostStepScript:_Init(role, para)
	self._roleTarget = role.target;
	self._delay = tonumber(para[1]) / 1000;
	self._speed = tonumber(para[2]) / 100;
	self._distance = tonumber(para[3]) / 100;
	if(self._roleTarget and self._roleTarget.transform) then
		self._distance = self._distance + self._roleTarget.info.radius / 100;
	end
	self._targetPt = self._roleTarget.transform.position;
	self._r =(self._roleTarget.transform.rotation.eulerAngles.y - 180) / 180 * pi;
	self._toPt = self._roleTarget.transform.position;
	
	self._toPt.x = self._toPt.x + sin(self._r) * self._distance;
	self._toPt.z = self._toPt.z + cos(self._r) * self._distance;
	
	self:_InitTimer(0, - 1);
	self:_OnTimerHandler();
end

function GhostStepScript:_OnTimerHandler()
	if(self._delay <= 0) then
		local role = self._role;
		local roleTransform = role.transform;
		local rolePt = roleTransform.position;
		local target = role.target;
		local speed = self._speed * FPSScale;
		if(target and target.transform and(not target:IsDie())) then
			local targetTransform = target.transform;
			self._targetPt = targetTransform.position;
			self._r =(targetTransform.rotation.eulerAngles.y - 180) / 180 * pi;
			self._toPt = targetTransform.position;
			self._toPt.x = self._toPt.x + sin(self._r) * self._distance;
			self._toPt.z = self._toPt.z + cos(self._r) * self._distance;
		end
		
		if(Vector3.Distance2(rolePt, self._toPt) <= speed * 1.1) then
		 
			roleTransform.rotation = Quaternion.Euler(0,(self._r * 180 / pi) + 180, 0);
			if(GameSceneManager.mpaTerrain:IsWalkable(self._toPt)) then
				MapTerrain.SampleTerrainPositionAndSetPos(roleTransform, self._toPt)
				
				-- 			roleTransform.position = MapTerrain.SampleTerrainPosition(self._toPt);
			end
			self:Dispose();
		else
			 
			local toR = atan2(self._toPt.x - rolePt.x, self._toPt.z - rolePt.z);			
			rolePt.x = rolePt.x + sin(toR) * speed;
			rolePt.z = rolePt.z + cos(toR) * speed;
			if(GameSceneManager.mpaTerrain:IsWalkable(rolePt)) then
                --这里加180和其他代码同步 解决瞬魔杀特效反转的问题
				roleTransform.rotation = Quaternion.Euler(0,(toR * 180 / pi) +180, 0);
				MapTerrain.SampleTerrainPositionAndSetPos(roleTransform, rolePt) 
			else
             		
				if(Vector3.Distance2(roleTransform.position, self._toPt) < Vector3.Distance2(self._targetPt, self._toPt)) then
			 		
					roleTransform.rotation = Quaternion.Euler(0,(self._r * 180 / pi) + 180, 0);
				end
				self:Dispose();
			end
		end
	else
		self._delay = self._delay - Time.fixedDeltaTime;
		if(self._delay <= 0) then
			
		end
		-- self:Dispose();
	end
end 