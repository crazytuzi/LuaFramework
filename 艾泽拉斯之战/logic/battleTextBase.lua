local battleTextBase = class("battleTextBase");

function battleTextBase:ctor(effectType, text, unitIndex, fontName, delayTime)
	
	-- Ëæ»úÎ»ÖÃÆ«ÒÆ
	self.xoffset = 0 --math.randomFloat(-0.5, 0.5);
	self.yoffset = math.randomFloat(-0.2, 0.2);
	self.zoffset = 0 --math.randomFloat(-0.5, 0.5);
	
	self.effectType = effectType;
	self.text = text;
	self.initPos = LORD.Vector2(0, 0);
	self.unitIndex = unitIndex;
	self.initPos = self:calcInitPos();
	self.fontName = fontName;
	self.scale = 1;
	self.color = LORD.Color(1, 1, 1, 1);
	self.font = LORD.GUIFontManager:Instance():GetFont(fontName);
	local width = self.font:GetTextExtent(text);
	local x = self.initPos.x-width/2;
	local y = self.initPos.y;
	self.pos = LORD.Vector2(x, y);
	self.timestamp = 0;
	
	self.delayTime = delayTime;
	self.play = false;
end

function battleTextBase:calcInitPos()
	
	local initPos = LORD.Vector2(0, 0);
	if sceneManager.battlePlayer() and sceneManager.battlePlayer():getCropsByIndex(self.unitIndex) then
		--print("self.unitIndex  "..self.unitIndex);
		
		local unitInstance = sceneManager.battlePlayer():getCropsByIndex(self.unitIndex);
		if unitInstance and unitInstance:getActor() then
			local worldPos = unitInstance:getActor():GetTextWorldPosition();
			worldPos.x = worldPos.x + self.xoffset;
			worldPos.y = worldPos.y + self.yoffset;
			worldPos.z = worldPos.z + self.zoffset;
			
			if LORD.GUISystem:Instance() then
				initPos = LORD.GUISystem:Instance():WorldPostionToScreen(worldPos);
			end
			
		end
	end
	
	return initPos;
end

function battleTextBase:calcInitPos2()
	
	local initPos = LORD.Vector2(0, 0);
	if sceneManager.battlePlayer() and sceneManager.battlePlayer():getCropsByIndex(self.unitIndex) then
		--print("self.unitIndex  "..self.unitIndex);
		
		local unitInstance = sceneManager.battlePlayer():getCropsByIndex(self.unitIndex);
		if unitInstance and unitInstance:getActor() then
			local screenpos = unitInstance:getActor():GetTextScreenPosition();
			local uisize = unitInstance.headInfoUI:GetPixelSize();
			initPos.x = screenpos.x + uisize.x/2
			initPos.y = screenpos.y + 8
		end
	end
	
	return initPos;
end

function battleTextBase:fitTextCenter()
	
	local width = self.font:GetTextExtent(self.text, self.scale);
	self.pos.x = self.pos.x - width / 2;

	local height = self.font:GetTextHigh(self.text, self.scale);
	self.pos.y = self.pos.y - height / 2;
			
end

function battleTextBase:isplay()
	return self.play;
end

function battleTextBase:checkDelay(dt)
	
	do
		self.play = true;
		return true;
	end
	
	if self.delayTime <= 0 then
		self.play = true;
		return true;
	else
		self.play = false;
		self.delayTime = self.delayTime - dt;
		return false;
	end
end

return battleTextBase;
