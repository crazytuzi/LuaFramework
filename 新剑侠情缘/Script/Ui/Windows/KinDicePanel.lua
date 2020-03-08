local tbUi = Ui:CreateClass("KinDicePanel");

function tbUi:OnOpen(nTimeOut, szType, szTitle)
	self.nTimeOut = nTimeOut;
	self.szType = szType
	szTitle = szTitle or "幸运抛骰子";
	self.pPanel:Label_SetText("Title", szTitle)

	self.bShaked = false;

	self.pPanel:Button_SetText("BtnShake", "投抛");
	self.pPanel:SetActive("TimeBackground", true);
	self.nTimer = Timer:Register(Env.GAME_FPS, self.Update, self);
	self:Update();
end

function tbUi:OnClose()
	if self.nTimer then
		Timer:Close(self.nTimer);
		self.nTimer = nil;
	end
end

function tbUi:Update()
	local nLeftTime = self.nTimeOut - GetTime();
	if nLeftTime > 0 then
		self.pPanel:Label_SetText("TxtTime", nLeftTime .. "秒");
		return true;
	else
		self.pPanel:SetActive("TimeBackground", false);
		if not self.bShaked then
			self.tbOnClick.BtnShake(self);
		end
		self.nTimer = nil;
		return false;
	end
end

function tbUi:UpdateShakeDice()
	local tbScore = Kin:GetGatherDiceScore();
	if not tbScore then
		return true;
	end

	for i = 1, 3 do
		self.pPanel:SetActive("DiceShake" .. i, false);
		self.pPanel:Sprite_SetSprite("Dice" .. i, "Dice" .. tbScore[i]);
	end

	if self.nTimer then
		Timer:Close(self.nTimer);
		self.nTimer = nil;
	end
	self.pPanel:SetActive("TimeBackground", false);
	self.pPanel:Button_SetText("BtnShake", "关闭");
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnShake()
	if self.bShaked then
		Ui:CloseWindow("KinDicePanel");
		return;
	end

	self.bShaked = true;

	for i = 1, 3 do
		self.pPanel:SetActive("DiceShake" .. i, true);
	end

	self.nShakingTimer = Timer:Register(Env.GAME_FPS, self.UpdateShakeDice, self);
	Kin:GatherDiceShake(self.szType);	
end

function tbUi.tbOnClick:BtnClose()
	if self.bShaked or GetTime() > self.nTimeOut then
		Ui:CloseWindow("KinDicePanel");
		return;
	end
	
	local function fnAgree()
		Ui:CloseWindow("KinDicePanel");
	end

	Ui:OpenWindow("MessageBox", 
		"确定放弃本次幸运抛骰子?",
		{{fnAgree}, {}},
		{"确定", "取消"});
end