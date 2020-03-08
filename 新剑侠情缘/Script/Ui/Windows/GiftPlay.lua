local tbUi = Ui:CreateClass("GiftPlay");
tbUi.szRoseIconName = "Rose";
tbUi.szCloverIconName = "Clover";

function tbUi:OnOpen(nItemId)
	self:CloseTimer();
	self:ShowAnim(nItemId);
	self.CloseId = Timer:Register(Env.GAME_FPS*3, self.CloseAnim,self)
end

function tbUi:ShowAnim(nItemId)
	self.pPanel:SetActive("songcao",false)
	self.pPanel:SetActive("songhua",false) 
	if nItemId == Gift.nRoseId then
		self.pPanel:Sprite_SetSprite("Goods", self.szRoseIconName);
		self.pPanel:SetActive("songhua",true)
	else
		self.pPanel:Sprite_SetSprite("Goods", self.szCloverIconName);
		 self.pPanel:SetActive("songcao",true)
	end
end

function tbUi:CloseAnim()
	self.CloseId = nil;
	Ui:CloseWindow("GiftPlay");
end

function tbUi:CloseTimer()
	if self.CloseId then
		Timer:Close(self.CloseId);
		self.CloseId = nil;
	end
end