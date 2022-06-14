local battleTextBase = include("battleTextBase");
local battleTextDebuff = class("battleTextDebuff", battleTextBase);

battleTextDebuff.HIT_RISE_SPEED = 50;
battleTextDebuff.HIT_RISE_TIME = 1000;
battleTextDebuff.HIT_RISE_STAYTIME = 700; --不透明时间，该值应小于总时间

function battleTextDebuff:ctor(effectType, text, unitIndex, fontName, delayTime)
	battleTextDebuff.super.ctor(self, effectType, text, unitIndex, fontName, delayTime);
end

function battleTextDebuff:update(dt)
		--print("battleTextDebuff:update(dt) "..dt);
		--返回是否删除

		-- 因为摄像机可能变，所以每一帧都要算。。。
		self.initPos = self:calcInitPos();
		
		if (self.timestamp <= battleTextDebuff.HIT_RISE_TIME) then
		
			local percent = (self.timestamp * 1.0 / battleTextDebuff.HIT_RISE_TIME);
			
			self.pos.y = self.initPos.y + self.timestamp*battleTextDebuff.HIT_RISE_SPEED*0.001;
			if (self.timestamp > battleTextDebuff.HIT_RISE_STAYTIME) then
				self.color.a = 1 - (self.timestamp-battleTextDebuff.HIT_RISE_STAYTIME) * 1.0 / (battleTextDebuff.HIT_RISE_TIME - battleTextDebuff.HIT_RISE_STAYTIME);
			end
		else
			return true;
		end

		self.timestamp = self.timestamp + dt;
		-- 数量变化信息位置
		local width = self.font:GetTextExtent(self.text, self.scale);
		local height = self.font:GetTextHigh(self.text, self.scale);
		self.pos.x = self.initPos.x - width / 2;

		return false;
end

return battleTextDebuff;
