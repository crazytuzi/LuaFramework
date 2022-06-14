local battleTextBase = include("battleTextBase");
local battleTextBuff = class("battleTextBuff", battleTextBase);

battleTextBuff.HIT_RISE_SPEED = 50;
battleTextBuff.HIT_RISE_TIME = 1000;
battleTextBuff.HIT_RISE_STAYTIME = 700; --不透明时间，该值应小于总时间

function battleTextBuff:ctor(effectType, text, unitIndex, fontName, delayTime)
	battleTextBuff.super.ctor(self, effectType, text, unitIndex, fontName, delayTime);
end

function battleTextBuff:update(dt)
		--print("battleTextBuff:update(dt) "..dt);
		--返回是否删除

		-- 因为摄像机可能变，所以每一帧都要算。。。
		self.initPos = self:calcInitPos();
		
		if (self.timestamp <= battleTextBuff.HIT_RISE_TIME) then
		
			local percent = (self.timestamp * 1.0 / battleTextBuff.HIT_RISE_TIME);
			
			self.pos.y = self.initPos.y - self.timestamp*battleTextBuff.HIT_RISE_SPEED*0.001;
			
			if (self.timestamp > battleTextBuff.HIT_RISE_STAYTIME) then
				self.color.a = 1 - (self.timestamp-battleTextBuff.HIT_RISE_STAYTIME) * 1.0 / (battleTextBuff.HIT_RISE_TIME - battleTextBuff.HIT_RISE_STAYTIME);
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

return battleTextBuff;
