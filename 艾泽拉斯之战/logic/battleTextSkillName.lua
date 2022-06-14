local battleTextBase = include("battleTextBase");
local battleTextSkillName = class("battleTextSkillName", battleTextBase);

battleTextSkillName.STEP1_DURATION = 1200;
battleTextSkillName.STEP15_DURATION = 300;
battleTextSkillName.STEP2_DURATION = 600;
battleTextSkillName.STEPX_DURATION = 250;

function battleTextSkillName:ctor(effectType, text, unitIndex, fontName, delayTime)
	battleTextSkillName.super.ctor(self, effectType, text, unitIndex, fontName, delayTime);
	
	self.stepIndex = 1;
end

function battleTextSkillName:update(dt)

		--返回是否删除
		
		-- 因为摄像机可能变，所以每一帧都要算。。。
		self.initPos = self:calcInitPos();
		
		if self.stepIndex == 1 then
		
			local interpolation = 1.0;
			
			if self.timestamp < battleTextSkillName.STEP1_DURATION then
				if	self.timestamp < battleTextSkillName.STEP1_DURATION - battleTextSkillName.STEP15_DURATION then
					local percent = (self.timestamp * 1.3 / (battleTextSkillName.STEP1_DURATION - battleTextSkillName.STEP15_DURATION));
					interpolation = getDecelerateInterpolation(percent);
					self.color.a = 1.0;
				else
					local percent = (battleTextSkillName.STEP1_DURATION -self.timestamp)*0.3/battleTextSkillName.STEP15_DURATION + 1
					interpolation = getDecelerateInterpolation(percent);
					self.color.a = 1.0;
				end
			else
				self.timestamp = 0;
				self.stepIndex = 2;
			end
			
			--self.scale = 0.1 + 0.9 * interpolation; -- 0.1 ~ 1
			self.scale = 0.01+0.99*interpolation;
			self.pos.x = self.initPos.x;
			self.pos.y = self.initPos.y;
			
			--print("battleTextSkillName:stepIndex 1 ".." x "..self.pos.x.." y "..self.pos.y);
			
		elseif self.stepIndex == 2 then

			local interpolation = 1.0;
			if self.timestamp < battleTextSkillName.STEP2_DURATION then
				local percent = self.timestamp / battleTextSkillName.STEP2_DURATION;
				interpolation = getDecelerateInterpolation(percent);
			else
				self.timestamp = 0;
				self.stepIndex = 0;
			end
			
			self.scale = 1 - 0.2 * interpolation;  --1 ~ 0.8
			if self.timestamp>battleTextSkillName.STEPX_DURATION then
				self.color.a = 1 - (self.timestamp-battleTextSkillName.STEPX_DURATION)*1.0/(battleTextSkillName.STEP2_DURATION-battleTextSkillName.STEPX_DURATION); -- 1~0
			end
			--self.pos.x = self.initPos.x + 60 * interpolation;
			self.pos.x = self.initPos.x;
			self.pos.y = self.initPos.y - 30 * interpolation;
			--print("battleTextSkillName:stepIndex 2 ".." x "..self.pos.x.." y "..self.pos.y);
		else
			return true;
		end

		self.timestamp = self.timestamp + dt;

		self:fitTextCenter();
					
		--print("after self.initPos "..self.initPos.x.." y "..self.initPos.y);
		
		return false;
end

return battleTextSkillName;
