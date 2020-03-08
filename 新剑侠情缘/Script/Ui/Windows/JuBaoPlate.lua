local tbUi = Ui:CreateClass("JuBaoPlate");

function tbUi:OnOpen()
	RemoteServer.GetMyJuBaoPenMoney();
	self:Update(0)
end

function tbUi:Update(nMoney)
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil;
	end

	self.pPanel:Label_SetText("CoinNumber", nMoney)
	if nMoney == 0 then
		self.pPanel:SetActive("JubaopenCoin", false)
	else
		self.pPanel:SetActive("JubaopenCoin", true)
		if nMoney == JuBaoPen.MAX_MONEY then
			self.pPanel:Sprite_SetSprite("JubaopenCoin", "Jubaopen02")			
		else
			self.pPanel:Sprite_SetSprite("JubaopenCoin", "Jubaopen01")			
		end
	end

	local nCDTime = JuBaoPen:GetTakeMoneyCDTime(me)
	self.pPanel:Button_SetEnabled("BtnGet", false)
	if nCDTime > 0 then
		self.pPanel:SetActive("CDtime", true)
		self.pPanel:Label_SetText("CDtime", Lib:TimeDesc3(nCDTime))
		self.nTimer = Timer:Register(Env.GAME_FPS * 1, function ()
			nCDTime =  nCDTime - 1;
			if nCDTime > 0 then
				self.pPanel:Label_SetText("CDtime", Lib:TimeDesc3(nCDTime))
				return true
			else
				RemoteServer.GetMyJuBaoPenMoney();
				self.nTimer = nil;
				return false
			end
		end)
		
	else
		self.pPanel:SetActive("CDtime", false)
	end
	self.pPanel:Button_SetEnabled("BtnGet", (nCDTime <= 0 and nMoney > 0))
end


function tbUi:OnClose()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil;	
	end
end


tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnGet = function (self)
	RemoteServer.TakeJuBaoPenMoney()
end