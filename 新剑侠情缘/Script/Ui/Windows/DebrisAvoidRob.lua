
local tbUi = Ui:CreateClass("DebrisAvoidRob");

--todo 如果购买配置要改，就直接改成动态的了
function tbUi:OnOpen()
	for i = 1, 2 do
		local tbBuyInfo = Debris.tbBuyAvoidRobSet[i]
		local nItemId = tbBuyInfo[3]
		local tbGrird = self["MSJPMini" .. i]
		tbGrird:SetItemByTemplate(nItemId)
		tbGrird.fnClick = tbGrird.DefaultClick

		local nCount = me.GetItemCountInAllPos(nItemId)
		self.pPanel:Label_SetText("Label" .. i, nCount)
	end

	local tbBuyInfo = Debris.tbBuyAvoidRobSet[3]
	self.nGoldCost = Lib.Calc:Link(me.nLevel, tbBuyInfo[3]);
	self.pPanel:Label_SetText("Label3", self.nGoldCost)
end

function tbUi:Buy(nIndex)
	local tbBuyInfo = Debris.tbBuyAvoidRobSet[nIndex]
	local szCostName = ""
	if tbBuyInfo[1] == "item" then
		local nCount = me.GetItemCountInAllPos(tbBuyInfo[3])
		local tbBaseInfo = KItem.GetItemBaseProp(tbBuyInfo[3]);
		szCostName = tbBaseInfo.szName
		if nCount < tbBuyInfo[4] then
			me.CenterMsg(string.format("您的%s道具不足", szCostName))
			return
		end
	elseif tbBuyInfo[1] == "Gold" then --其他货币
		szCostName = self.nGoldCost .. "元宝"
		if me.GetMoney("Gold") < self.nGoldCost then
			me.CenterMsg("您的元宝不足")
			Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
			return
		end
	end

	local nLeftTime = Debris:GetMyAvoidRobLeftTime();
	if nLeftTime >= 24 * 3600 then
		me.CenterMsg("开启失败，当前免战时间超过了24小时")
		return
	end

	local fnYes = function ()
		RemoteServer.BuyDebrisAvoidRobTime(nIndex)
		Ui:CloseWindow(self.UI_NAME);
	end

	Ui:OpenWindow("MessageBox", string.format("确认消耗 [FFFE0D]%s[-] 开启免战吗", szCostName),
	{{fnYes},{} })

end


tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnBuy1()
	self:Buy(1)
end

function tbUi.tbOnClick:BtnBuy2()
	self:Buy(2)
end

function tbUi.tbOnClick:BtnBuy3()
	self:Buy(3)
end