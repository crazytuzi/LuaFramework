-- 冥想

local tbUi = Ui:CreateClass("VitalityEffectPanel");
tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi:OnOpen(nLevel)
	local nMaxLevel = #House.tbMuseSetting;
	for i = 1, nMaxLevel do
		self.pPanel:SetActive("Level" .. i, false);
	end
	self.pPanel:SetActive("Level" .. nLevel, true);
	
	self.nTimerId = Timer:Register(Env.GAME_FPS * 3, function ()
		Ui:CloseWindow(self.UI_NAME);
		self.nTimerId = nil;
	end);
end

function tbUi:OnClose()
	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
	end
end


Ui:CreateClass("MuseEffectPanel");