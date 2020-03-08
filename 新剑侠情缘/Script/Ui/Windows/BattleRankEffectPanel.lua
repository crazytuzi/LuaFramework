
local tbFBRankEffect = Ui:CreateClass("BattleRankEffectPanel");

tbFBRankEffect.tbSetting = 
{
	["Jinjiyuedusai"]	 = "Month";
	["Jinjijidusai"]	 = "Season";
	["jinjiniandusai"]	 = "Year";
}

function tbFBRankEffect:OnOpen(szType)
	for k,v in pairs(self.tbSetting) do
		self.pPanel:SetActive(k, v == szType)
	end
	
	self.nTimer = Timer:Register(Env.GAME_FPS * 3, self.OnTimer, self)
end

function tbFBRankEffect:OnTimer()
	self.nTimer = nil;
	Ui:CloseWindow(self.UI_NAME);
end

function tbFBRankEffect:OnClose()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil;
	end
end

