local tbUi = Ui:CreateClass("ChangeName");

function tbUi:OnOpen()
	Client:SetFlag("ChangeNameRed")
	Ui:ClearRedPointNotify("ChanfeNameInfo")
	local nCost,bHasItem = ChangeName:GetChangePrice(me)
	self.nCost = nCost
	if nCost == 0 then
		self.pPanel:SetActive("TXT1", true)		
		self.pPanel:SetActive("TXT2", false)		
		if bHasItem then
			local tbItem = KItem.GetItemBaseProp(ChangeName.ITEM_ChangeName)
			self.pPanel:Label_SetText("TXT1", string.format("当前有 [FFFE0D]%s[-] 道具，本次改名免费", tbItem.szName))
		else
			self.pPanel:Label_SetText("TXT1", "[FFFE0D] 30级 [-]前可免费改名一次")
		end
	else
		self.pPanel:SetActive("TXT1", false)		
		self.pPanel:SetActive("TXT2", true)		
		self.pPanel:Label_SetText("TXT2", string.format("[FFFE0D]%d[-]", nCost))
	end

end

function tbUi:OnChangeName(...)
	ChangeName:OnChangeName(...)
end

tbUi.tbOnClick = {};

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnComfirm = function (self)
	local szNewName = self.pPanel:Input_GetText("TxtTitle")
	if not Login:CheckNameinValid(szNewName) then
		return
	end

	if szNewName == me.szName then
		me.CenterMsg("您的新名字没有任何变化哦")
		return
	end

	local nCost, bHasItem = ChangeName:GetChangePrice(me)
	if self.nCost ~= nCost then
		self:OnOpen()
	end

	if me.GetMoney("Gold") < self.nCost  then
		me.CenterMsg("您的元宝不足")
		Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
		return
	end

	local fnYes = function ()
		RemoteServer.RequestChangeName(szNewName)
	end
	local szMsg = string.format("是否确认花费 [FFFE0D]%d元宝[-] 改名为 [FFFE0D]%s[-]", self.nCost, szNewName)
	if bHasItem then
		szMsg = "是否确认消耗道具改名"
	elseif self.nCost == 0 then
		szMsg = "是否确认使用唯一的一次免费改名"
	end
	Ui:OpenWindow("MessageBox",
		szMsg,
	 { {fnYes},{} }, 
	 {"同意", "取消"});


end





function tbUi:RegisterEvent()
    return
    {
        { UiNotify.emNOTIFY_CHANGE_PLAYER_NAME,  self.OnChangeName},
    };
end
