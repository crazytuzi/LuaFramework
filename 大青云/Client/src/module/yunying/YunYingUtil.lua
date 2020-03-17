--[[
jiayong
2016年9月27日20:51:50
]]

_G.YunYingUti = {};


function YunYingUti:GetBtnPos(btn)
	for i, list in ipairs(YunYingConsts.BtnPosMap) do
		for j, id in ipairs(list) do
			if id == btn then
				local button = YunYingBtnManager:GetBtn(id);
				if button then
					return button:GetButton();
				end
			end
		end
	end
end

function YunYingUti:CountDownTimes( )
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end
	self.timerKey = TimerManager:RegisterTimer(function()
		if _G.GetLocalTime() > CTimeFormat:GetThisTimeMsec(2016, 12, 25, 0, 0, 0) then
			UIMainYunYingFunc:DrawLayout()
			if self.timerKey then
				TimerManager:UnRegisterTimer(self.timerKey)
				self.timerKey = nil;
			end
		end
	end,1000,0); 
end

