local battleTextBase = include("battleTextBase");
local battleTextCommon = class("battleTextCommon", battleTextBase);

battleTextCommon.STEP1_DURATION = 200;
battleTextCommon.STEP2_DURATION = 1300;
battleTextCommon.STEPX_DURATION = 1000;

function battleTextCommon:ctor(effectType, text, unitIndex, fontName, delayTime)
	battleTextCommon.super.ctor(self, effectType, text, unitIndex, fontName, delayTime);
	
	self.stepIndex = 1;
end

function battleTextCommon:update(dt)

		--返回是否删除 九 零  一 起 玩 ww w .9 0 1  7 5. com
		
		-- 因为摄像机可能变，所以每一帧都要算。。。
		self.initPos = self:calcInitPos();
		
		if self.stepIndex == 1 then
		
			local interpolation = 1.0;
			
			if self.timestamp < battleTextCommon.STEP1_DURATION then
				local percent = (self.timestamp * 1.0 / battleTextCommon.STEP1_DURATION);
				interpolation = getDecelerateInterpolation(percent);
				
				self.color.a = 1.0;
			else
				self.timestamp = 0;
				self.stepIndex = 2;
			end
			
			self.scale = 0.1 + 0.9 * interpolation; -- 0.1 ~ 1
			
			self.pos.x = self.initPos.x;
			self.pos.y = self.initPos.y;
			
			--print("battleTextCommon:stepIndex 1 ".." x "..self.pos.x.." y "..self.pos.y);
			
		elseif self.stepIndex == 2 then

			local interpolation = 1.0;
			if self.timestamp < battleTextCommon.STEP2_DURATION then
				local percent = self.timestamp / battleTextCommon.STEP2_DURATION;
				interpolation = getDecelerateInterpolation(percent);
			else
				self.timestamp = 0;
				self.stepIndex = 0;
			end
			
			self.scale = 1 - 0.2 * interpolation;  --1 ~ 0.8
			if self.timestamp>battleTextCommon.STEPX_DURATION then
				self.color.a = 1 - (self.timestamp-battleTextCommon.STEPX_DURATION)*1.0/(battleTextCommon.STEP2_DURATION-battleTextCommon.STEPX_DURATION); -- 1~0
			end
			--self.pos.x = self.initPos.x + 60 * interpolation;
			self.pos.x = self.initPos.x;
			self.pos.y = self.initPos.y - 60 * interpolation;
			--print("battleTextCommon:stepIndex 2 ".." x "..self.pos.x.." y "..self.pos.y);
		else
			return true;
		end

		self.timestamp = self.timestamp + dt;

		self:fitTextCenter();
					
		--print("after self.initPos "..self.initPos.x.." y "..self.initPos.y);
		
		return false;
end

return battleTextCommon;
