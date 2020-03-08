local tbUi = Ui:CreateClass("ThreeChoosePanel");
function tbUi:OnOpen(szType)
	self.szType = szType or "KinFoKuBattle";
	self:UpdateContent();
end


tbUi.tbOnClick = {
	BtnClose = function()
		Ui:CloseWindow("ThreeChoosePanel");
	end,
	BtnApply = function()
		KinBattle.Foku:TryApply();
		Ui:CloseWindow("ThreeChoosePanel");
	end,
	BtnJoin = function()
		KinBattle.Foku:TryEnterZone(1);
		Ui:CloseWindow("ThreeChoosePanel");
	end,
	BtnCurrent = function()
		KinBattle.Foku:TryAskMemberMsg()
		Ui:OpenWindow("FKTeamPanel");
		--Ui:CloseWindow("ThreeChoosePanel");
	end,
}

function tbUi:RegisterEvent()
	local tbRegEvent = 
	{
		{UiNotify.emNoTIFY_SYNC_FOKU_BATTLE, self.OnNotify, self},
	};
	return tbRegEvent;
end


function tbUi:OnNotify(...)
	self:_OnNotify(...)
end

function tbUi:_OnNotify(...)
	self:UpdateContent();
end

tbUi.Update = {
	["KinFoKuBattle"] = function (self)
		local tbInfo = KinBattle.Foku.tbKinData;
		local bNeedApply = true;
		if tbInfo and tbInfo.tbAgreePlayer and 
			tbInfo.tbAgreePlayer[me.dwID] then
			bNeedApply = false;
		end
		self.pPanel:Button_SetEnabled("BtnApply", bNeedApply);
		self.pPanel:Button_SetEnabled("BtnJoin", not bNeedApply);
		self.pPanel:Sprite_SetGray("BtnJoin", bNeedApply);
		self.pPanel:Sprite_SetGray("BtnApply", not bNeedApply);
	end
}

function tbUi:UpdateContent()
	Lib:Tree(self.szType);
	self.Update[self.szType](self,self);
end
