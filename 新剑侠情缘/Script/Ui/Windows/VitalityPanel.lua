local tbUI = Ui:CreateClass("VitalityPanel")

tbUI.tbOnClick = 
{
    BtnMake = function(self)
    	if not self.nSelIndex or self.bCanNotMake then
    		return
    	end
    	local tbSetting = self.tbCanMakeList[self.nSelIndex]
    	if not tbSetting then
    		return
    	end
    	local nSelLevel = tbSetting.nLevel
    	local bRet, szMsg = Item.tbZhenYuan:CanMakeZhenYuan(me, nSelLevel);
    	if not bRet then
    		me.CenterMsg(szMsg)
    		return
    	end
    	self.bCanNotMake = true;
    	RemoteServer.MakeZhenYuan(nSelLevel)
    end,
};



function tbUI:Update()
	self.pPanel:SetActive("Zhenyuan_CX", true)
	self.pPanel:SetActive("Zhenyuan_NJ", false)
	self.pPanel:SetActive("Ningjuchenggong", false)

	self.pPanel:SetActive("FinalEquip", false)
	
	if not self.nSelIndex then
		self.nSelIndex = 1;
	end
	local tbCanMakeList = Item.tbZhenYuan:GetCanMakeLevelSettingList();
	self.tbCanMakeList = tbCanMakeList
	self:UpdateList();
	self:SelectItem(self.nSelIndex)
end

function tbUI:OnClose()
	self.bCanNotMake = nil;
end

function tbUI:UpdateList()
	local fnSetItem = function (pGrid, index)
		local tbItem = self.tbCanMakeList[index]
		local nItemPT = tbItem.nItemPT
		local tbInfo = KItem.GetItemBaseProp(nItemPT)
		local szName = Item:GetItemTemplateShowInfo(nItemPT, me.nFaction, me.nSex)
		pGrid.pPanel:Label_SetText("Name", szName)
		pGrid.pPanel:Label_SetText("Level", tbInfo.nRequireLevel)
		pGrid.itemframe:SetItemByTemplate(nItemPT, nil, me.nFaction)
		pGrid.itemframe.fnClick = pGrid.itemframe.DefaultClick
		pGrid.pPanel:Toggle_SetChecked("Main", index == self.nSelIndex)

		pGrid.pPanel.OnTouchEvent = function()
			self:SelectItem(index)
		end
	end
	self.ScrollView:Update(self.tbCanMakeList, fnSetItem)
end

function tbUI:SelectItem(nLevel)
	self.nSelIndex = nLevel
	local tbSetting = self.tbCanMakeList[nLevel]
	local tbItemTypes = { "nItemPT", "nItemCC", "nItemXY" };
	for i,v in ipairs(tbItemTypes) do
		local pItemFrame = self["itemframe" .. i];
		pItemFrame:SetItemByTemplate(tbSetting[v], nil, me.nFaction)
		pItemFrame.fnClick = pItemFrame.DefaultClick
	end
	
	local szIcon, szAtlas = Shop:GetMoneyIcon(tbSetting.szMoneyType)
	self.pPanel:Sprite_SetSprite("CostMoneyIcon", szIcon, szAtlas)
	self.pPanel:Sprite_SetSprite("HaveMoneyIcon", szIcon, szAtlas)
	self.pPanel:Label_SetText("TxtCostMoney", tbSetting.nPrice)
	self:RefreshMoney();
end

function tbUI:RefreshMoney()
	local tbSetting = self.tbCanMakeList[self.nSelIndex]
	self.pPanel:Label_SetText("TxtHaveMoney", me.GetMoney(tbSetting.szMoneyType))
end

function tbUI:OnMakeResult(nItemId)
	self.pPanel:SetActive("Zhenyuan_CX", false)
	self.pPanel:SetActive("Zhenyuan_NJ", true)
	self.pPanel:SetActive("Ningjuchenggong", false)	
	self.pPanel:SetActive("FinalEquip", false)

	if self.nTimerQH then
		Timer:Close(self.nTimerQH);
	end
	self.nTimerQH = Timer:Register(30, function ()
		self.nTimerQH = nil;
		self.bCanNotMake = nil;
		self.pPanel:SetActive("Ningjuchenggong", true)	
		self.pPanel:SetActive("Zhenyuan_CX", true)
		self.pPanel:SetActive("Zhenyuan_NJ", false)
		local szEquipName = Item:GetItemTemplateShowInfo(nItemId, me.nFaction, me.nSex)
	    me.CenterMsg(string.format("恭喜您凝聚了一件[FFFE0D]%s[-]", szEquipName))
	    self.pPanel:SetActive("FinalEquip", true)
		self.Equipitemframe:SetItemByTemplate(nItemId)
		self.Equipitemframe.fnClick = self.Equipitemframe.DefaultClick
	end)

end
