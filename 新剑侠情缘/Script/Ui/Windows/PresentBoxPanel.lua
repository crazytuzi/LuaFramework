local tbUi = Ui:CreateClass("PresentBoxPanel");
local tbAct = Activity.RechargeSumOpenBox;

function tbUi:OnOpen(  )
	self.pPanel:Label_SetText("Label",tbAct.szUiDesc1)
	self.pPanel:Label_SetText("Label2",tbAct.szUiDesc2)
	local tbUiData, tbActData = Activity:GetActUiSetting("RechargeSumOpenBox") 
	if tbActData then
		local tbStartTime    = os.date("*t", tbActData.nStartTime);
		local tbEndTime    = os.date("*t", tbActData.nEndTime);
		self.pPanel:Label_SetText("LabelTime", string.format("购买期限：%s年%s月%s日-%s月%s日", tbStartTime.year, tbStartTime.month,tbStartTime.day, tbEndTime.month,tbEndTime.day))
	end
	self:Update()
end

function tbUi:Update(  )
	local nAwardId = tbAct.nAwardKey;
	local tbAwardSetting = tbAct.tbRechargeItemBoxAwardSetting[nAwardId];
	local tbPlayerData = tbAct:GetPlayerData( )
	local fnSetItem = function ( itemObj, index )
		local nProdIndex = tbAct.tbOpenLevelToGoldIndex[index]
		local tbProdInfo = Recharge.tbSettingGroup.BuyGold[nProdIndex]
		itemObj.pPanel:Label_SetText("ItemLabel", string.format("充值%s额外获得",Recharge:GetShowBuyPriceDesc(tbProdInfo.nMoney, tbProdInfo.szMoneyType)))
		local tbAwardGroup = tbAwardSetting[index]
		for i=1,2 do
			local tbGrid = itemObj["itemframe" .. i];
			local tbAward = tbAwardGroup[i]
			if tbAward then
				tbGrid.pPanel:SetActive("Main", true)
				tbGrid:SetGenericItem(tbAward)
				tbGrid.fnClick = tbGrid.DefaultClick
			else
				tbGrid.pPanel:SetActive("Main", false)
			end
		end
		local nBuyState = tbPlayerData[index];
		if not nBuyState then
			itemObj.pPanel:SetActive("BuyBTN", true)
			itemObj.pPanel:SetActive("Received", false)
			itemObj.pPanel:SetActive("Bought", false)
			itemObj.pPanel:SetActive("ReceiveBTN", false)
			itemObj.BuyBTN.pPanel.OnTouchEvent = function ()
				Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
			end
			
		elseif nBuyState == 0 then
			itemObj.pPanel:SetActive("BuyBTN", false)
			itemObj.pPanel:SetActive("Bought", true)
			itemObj.pPanel:SetActive("Received", false)
			itemObj.pPanel:SetActive("ReceiveBTN", true)
			itemObj.ReceiveBTN.pPanel.OnTouchEvent = function ()
				tbAct:TryTakeAward(index)
			end;
		elseif nBuyState == 1 then
			itemObj.pPanel:SetActive("BuyBTN", false)
			itemObj.pPanel:SetActive("Bought", true)
			itemObj.pPanel:SetActive("Received", true)
			itemObj.pPanel:SetActive("ReceiveBTN", false)
		end
	end
	self.ScrollView:Update(tbAct.tbOpenLevelToGoldIndex, fnSetItem)
end

