local tbUi = Ui:CreateClass("CardPickRecordPanel");

local szCardPickProbTip = [[

[73cbd5]1)同伴招募-银两购买[-]
招募[ff42c7]乙级[-]同伴概率：[c8ff00]5%[-]
招募[42ccff]丙级[-]同伴概率：[c8ff00]27.5%[-]
招募[42ff58]丁级[-]同伴概率：[c8ff00]67.5%[-]

[73cbd5]2)同伴招募-元宝购买[-]
招募[ff5f63]甲级[-]同伴概率：[c8ff00]1%[-]
招募[ff42c7]乙级[-]同伴概率：[c8ff00]12.5%[-]
招募[42ccff]丙级[-]同伴概率：[c8ff00]30.61%[-]
招募洗髓丹的概率：[c8ff00]55.89%[-]
[73cbd5]除此之外游戏内设定每十次招募必出甲级或甲级以上同伴，此次招募概率如下：[-]
招募[ffa23e]地级[-]同伴概率：[c8ff00]8%[-]
招募[ff5f63]甲级[-]同伴概率：[c8ff00]92%[-]

[73cbd5]3)摇钱树[-]
普通摇钱概率：[c8ff00]72%[-]
双倍暴击概率：[c8ff00]24%[-]
十倍暴击概率：[c8ff00]4%[-]

[73cbd5]4)黄金宝箱[-]
开出银两概率约为：[c8ff00]20%[-]
开出2阶传承装备的概率为：[c8ff00]20%[-]
开出3阶传承装备的概率为：[c8ff00]10%[-]
开出4阶传承装备碎片的概率为：[c8ff00]24%[-]
开出5阶传承装备碎片的概率为：[c8ff00]12%[-]
开出6阶传承装备碎片的概率为：[c8ff00]10%[-]
开出7阶传承装备碎片的概率为：[c8ff00]6%[-]
开出8阶传承装备碎片的概率为：[c8ff00]4.8%[-]
开出9阶传承装备碎片的概率为：[c8ff00]4.2%[-]
开出10阶传承装备碎片的概率为：[c8ff00]3%[-]
开出1级魂石的概率约为：[c8ff00]10%[-]
开出2级魂石的概率约为：[c8ff00]2%[-]
开出3级魂石的概率约为：[c8ff00]0.6%[-]
开出4级魂石的概率约为：[c8ff00]0.1%[-]

[73cbd5]5)每日礼包-1元超值礼包[-]
必然获得白水晶*6、20元宝、2000银两、黄金宝箱。
开出头衔令牌概率约为：[c8ff00]0.2%[-]
开出稀有装备概率约为：[c8ff00]0.5%[-]
开出随机魂石概率约为：[c8ff00]0.8%[-]

[73cbd5]6)每日礼包-3元超值礼包[-]
[73cbd5]开放69级上限前：[-]
必然获得白水晶*6、随机1级魂石*1、洗髓丹*1、30元宝、200贡献。
开出头衔令牌概率约为：[c8ff00]0.2%[-]
开出稀有装备概率约为：[c8ff00]0.5%[-]
开出随机魂石概率约为：[c8ff00]0.8%[-]
[73cbd5]开放69级上限后：[-]
必然获得绿水晶*2、元气道具*1、30元宝、200贡献。
开出头衔令牌概率约为：[c8ff00]0.1%[-]
开出稀有装备概率约为：[c8ff00]0.1%[-]
开出随机魂石概率约为：[c8ff00]0.15%[-]

[73cbd5]7)每日礼包-6元超值礼包[-]
[73cbd5]开放79级上限前：[-]
必然获得随机2级魂石*1、60元宝、500贡献。
开出头衔令牌概率约为：[c8ff00]0.2%[-]
开出稀有装备概率约为：[c8ff00]0.5%[-]
开出随机魂石概率约为：[c8ff00]0.8%[-]
[73cbd5]开放79级上限至开放99级上限前：[-]
必然获得元气道具*1、蓝水晶*1、60元宝、400贡献。
开出头衔令牌概率约为：[c8ff00]0.6%[-]
开出稀有装备概率约为：[c8ff00]0.08%[-]
开出随机魂石概率约为：[c8ff00]1.2%[-]
[73cbd5]开放99级上限后：[-]
必然获得元气道具*1、蓝水晶*1、60元宝、任务卷轴*1、黄金宝箱*2。
开出头衔令牌概率约为：[c8ff00]0.2%[-]
开出稀有装备概率约为：[c8ff00]0.01%[-]
开出随机魂石概率约为：[c8ff00]0.6%[-]

]]

function tbUi:OnOpen(szType)
	if szType == "History" then
		CardPicker:Ask4CardPickHistory();
	end
end

function tbUi:OnOpenEnd(szType)
	self.szType = szType;
	self:Update();
end

function tbUi:Update()
	if self.szType ~= "History" then
		self.pPanel:Label_SetText("Title", "随机概率公示");
		self.pPanel:Label_SetText("Content", szCardPickProbTip);
		self.pPanel:Label_SetText("Tip", "");
	else
		local szHistory = CardPicker:GetLatestPickHistory();
		self.pPanel:Label_SetText("Title", "本服招募记录");
		self.pPanel:Label_SetText("Content", szHistory);
		self.pPanel:Label_SetText("Tip", "＊招募记录只显示最近50条。");
	end

	local tbTextSize = self.pPanel:Label_GetPrintSize("Content");
	local tbSize = self.pPanel:Widget_GetSize("datagroup");
	self.pPanel:Widget_SetSize("datagroup", tbSize.x, tbTextSize.y + 50);
	self.pPanel:DragScrollViewGoTop("datagroup");
	self.pPanel:UpdateDragScrollView("datagroup");
end


function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_CARD_PICKING, self.Update },
	};
	return tbRegEvent;
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end