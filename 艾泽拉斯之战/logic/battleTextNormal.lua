local battleTextBase = include("battleTextBase");
local battleTextNormal = class("battleTextNormal", battleTextBase);

battleTextNormal.HIT_RISE_SPEED = 80;
battleTextNormal.HIT_RISE_TIME = 300;
battleTextNormal.HIT_STAY_TIME = 700;
battleTextNormal.HIT_FADE_OUT_TIME = 400;

function battleTextNormal:ctor(effectType, text, unitIndex, fontName, delayTime)
	battleTextNormal.super.ctor(self, effectType, text, unitIndex, fontName, delayTime);
end

function battleTextNormal:update(dt)
		--print("battleTextNormal:update(dt) "..dt);
		--返回是否删除

		-- 因为摄像机可能变，所以每一帧都要算。。。
		-- self.initPos = self:calcInitPos();
		self.initPos = self:calcInitPos2();
		if (self.timestamp <= battleTextNormal.HIT_RISE_TIME) then
		
			-- self.pos.y = self.initPos.y - self.timestamp*battleTextNormal.HIT_RISE_SPEED*0.001;

			local percent = (self.timestamp * 1.0 / battleTextNormal.HIT_RISE_TIME);

			if (percent < 0.5) then
			
				self.scale = 0.2 + 1.8 * (1.0 - (0.5 - percent)/0.5);
			
			else
			
				self.scale = 2.0 - 1.0 * (percent - 0.5)/0.5;
				
			end
		elseif self.timestamp <= battleTextNormal.HIT_RISE_TIME + battleTextNormal.HIT_STAY_TIME then
		
			self.scale = 1.0;
		
		elseif self.timestamp <= battleTextNormal.HIT_RISE_TIME + battleTextNormal.HIT_STAY_TIME + battleTextNormal.HIT_FADE_OUT_TIME then
		
			self.color.a = (battleTextNormal.HIT_STAY_TIME - self.timestamp + 
										battleTextNormal.HIT_RISE_TIME + battleTextNormal.HIT_FADE_OUT_TIME)*1.0 / battleTextNormal.HIT_FADE_OUT_TIME;
		else
			return true;
		end

		self.timestamp = self.timestamp + dt;
		-- 数量变化信息位置
		-- local width = self.font:GetTextExtent(self.text, self.scale);
		-- local height = self.font:GetTextHigh(self.text, self.scale);
		-- self.pos.x = self.initPos.x - width / 2;
		self.pos.x = self.initPos.x ;
		self.pos.y = self.initPos.y ;
		return false;
end

return battleTextNormal;
