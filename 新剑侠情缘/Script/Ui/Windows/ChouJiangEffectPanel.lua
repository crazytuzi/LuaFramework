local tbUi = Ui:CreateClass("ChouJiangEffectPanel");

function tbUi:OnOpen()
	self.pPanel:Tween_Play("Zodiac")
	self.pPanel:SetActive("Effect", false)
	self.pPanel:SetActive("Effect", true)

end

function tbUi:OnOpenEnd( )

end



-- 最新消息
local tbNewInfoUi = Ui:CreateClass("NewInfo_NYLottery")

local Lottery_Type =  
{
	XiaoJiang = 1;
	DaJiang = 2;
}

local tbLotteryData = 
{
	[Lottery_Type.XiaoJiang] = 
	{
		szUiPanel = "item01";
		szDateUi = "Tip1";
		szTextUi = "Text1";
		szText = "使用奖券参与本轮抽奖，[FFFE0D]抽过奖的侠士[-]均参与[FFFE0D]7月3日盛夏[-]大抽奖；  [c8ff00]领取60活跃度宝箱和1元礼包可获得奖券[-]";
		szToggleUi = "BtnLottery";
		szToggleTxt = ChouJiang.bSummerOpen and "盛夏抽奖" or "新年抽奖";
		tbLotteryLabel = {"LotteryLabelLight", "LotteryLabelDark"};
		szSrollViewUi = "ScrollView1";
		fnAwardData = function () return ChouJiang:GetDayShowAward() end;
	};
	[Lottery_Type.DaJiang] = 
	{
		szUiPanel = "item02";
		szLotteryDay = "2019年7月3日22时开奖";
		szDateUi = "Tip2";
		szTextUi = "Text2";
		szText = "[FFFE0D]7月3日，使用过奖券抽奖的侠士[-]均参与大抽奖；  [c8ff00]领取60活跃度宝箱和1元礼包可获得奖券[-]";
		szToggleUi = "BtnLantern";
		szToggleTxt = ChouJiang.bSummerOpen and "盛夏大奖" or "元宵大奖";
		tbLotteryLabel = {"LanternLabelLight", "LanternLabelDark"};
		szSrollViewUi = "ScrollView2";
		fnAwardData = function () return ChouJiang:GetBigShowAward() end;
	};
}

function tbNewInfoUi:OnOpen()
	RemoteServer.ChouJiangClientCall("CheckData")
	self.nType = Lottery_Type.XiaoJiang
	local nLastExeDay = ChouJiang:GetLastExeDay(ChouJiang:GetStartTime())
    if not nLastExeDay or nLastExeDay == 0 then
    	self.nType = Lottery_Type.DaJiang
    end
    self:ShowUi(self.nType)
	self:RefreshUi()
end

function tbNewInfoUi:RefreshUi()

	for nLotteryType,tbData in pairs(tbLotteryData) do
		local szDate = tbData.szLotteryDay or ChouJiang:GetDayLotteryDate()
		self.pPanel:Label_SetText(tbData.szDateUi, szDate);
		local szText = tbData.szText or ""
		self[tbData.szTextUi]:SetLinkText(string.format(szText));
		local tbAwardData = tbData.fnAwardData()
		if tbAwardData then
			local nCount = #tbAwardData
			local fnSetItem = function(itemObj,nIdx)
				local tbInfo = tbAwardData[nIdx]
				local szRankSprite = tbInfo.szRankSprite
				local tbAward = tbInfo.tbAward
				local szEggSprite = tbInfo.szEggSprite
				if szRankSprite then
					itemObj.pPanel:SetActive("Title",true)
					itemObj.pPanel:Sprite_SetSprite("Reword",  szRankSprite);
					itemObj.pPanel:SetActive("Level04",false)
					itemObj.pPanel:Sprite_SetSprite("Egg",  szEggSprite);
				else
					itemObj.pPanel:SetActive("Title",false)
					itemObj.pPanel:SetActive("Level04",true)
					local szRank = ChouJiang:GetRankDes(nIdx)
					if nIdx == nCount then
						szRank = "幸运奖"
					end
					itemObj.pPanel:Label_SetText("Level04",szRank)
				end
				local szCount = tbInfo.szCount or ""
				itemObj.pPanel:Label_SetText("Num",szCount)
				itemObj["itemframe"]:SetGenericItem(tbAward)
				itemObj["itemframe"].fnClick = itemObj["itemframe"].DefaultClick
			end
			self[tbData.szSrollViewUi]:Update(nCount,fnSetItem);
		else
			self[tbData.szSrollViewUi]:Update(0,function () end);
		end
	end
end

function tbNewInfoUi:ShowUi(nType)
	self.nType = nType or self.nType
	local nType = self.nType
	self.pPanel:SetActive("LotteryQualification1", false)
	self.pPanel:SetActive("LotteryQualification2", false)
	local nStartTime = ChouJiang:GetStartTime()
	local tbItem = Item:GetClass("JiangQuan")
	local nNewYearUseDay = me.GetUserValue(tbItem.SAVE_GROUP, tbItem.KEY_NEW_YEAR_USE_DAY);
	local nLastExeDay = ChouJiang:GetLastExeDay(nStartTime)
	if nType == Lottery_Type.XiaoJiang then
		if nLastExeDay and nLastExeDay ~= 0 and nNewYearUseDay == nLastExeDay then
			self.pPanel:SetActive("LotteryQualification1", true)
		end
	elseif nType == Lottery_Type.DaJiang then
		if nStartTime ~= 0 and nNewYearUseDay > 0 then
			self.pPanel:SetActive("LotteryQualification2", true)
		end
	end
	
	for nLotteryType,tbData in pairs(tbLotteryData) do
		local szUiPanel = tbData.szUiPanel
		if nType == nLotteryType then
			self.pPanel:SetActive(szUiPanel, true)
			self.pPanel:Toggle_SetChecked(tbData.szToggleUi, true);
		else
			self.pPanel:SetActive(szUiPanel, false)
			self.pPanel:Toggle_SetChecked(tbData.szToggleUi, false);
		end
		for _, szToggleTxtUi in ipairs(tbData.tbLotteryLabel) do
			self.pPanel:Label_SetText(szToggleTxtUi, tbData.szToggleTxt)
		end
	end
end

tbNewInfoUi.tbOnClick = {
	BtnLottery = function (self) 
		self:ShowUi(Lottery_Type.XiaoJiang)
	end;
	BtnLantern = function (self) 
		self:ShowUi(Lottery_Type.DaJiang)
	end;
};

-- 中奖结果最新消息
local tbNewInfoResultUi = Ui:CreateClass("NewInfo_NYLotteryResult")
tbNewInfoResultUi.tbDes = 
{
	[1] = "本次抽奖的幸运儿已经诞生，恭喜诸位中奖的侠士！",
	[2] = "本次抽奖的幸运儿已经诞生，恭喜诸位，侠士们不要气馁，[FFFE0D]7月3日[-]还有大奖等着你！",
}
function tbNewInfoResultUi:OnOpen(tbData)
	if not tbData then
		return
	end
	self.tbData = tbData
	--Lib:ShowTB(tbData)
	self:RefreshUi()
end

function tbNewInfoResultUi:RefreshUi()
	local tbRankSprite = ChouJiang:GetRankSprite(1)
	if tbRankSprite then
		local szRankSprite,szEggSprite = unpack(tbRankSprite)
		self["LotteryItem"].pPanel:Sprite_SetSprite("Reword",szRankSprite)
		self["LotteryItem"].pPanel:Sprite_SetSprite("Egg",szEggSprite)
	end
	local nType = self.tbData.nType
	local tbRankData = self.tbData.tbRankData
	local szText = tbNewInfoResultUi.tbDes[nType] or "抽奖名单"
	self.pPanel:Label_SetText("Details2",szText)
	if not tbRankData then
		self.pPanel:SetActive("LotteryItem", false)
		self.pPanel:SetActive("LotteryEmpty", true)
		self.ScrollViewNYLottery:Update(0,function () end)
		return
	end

	local nCount = 0
	for _,tbInfo in pairs(tbRankData) do
		for k,v in pairs(tbInfo) do
			nCount = nCount + 1
		end
	end

	if nCount == 0 then
		self.pPanel:SetActive("LotteryItem", false)
		self.pPanel:SetActive("LotteryEmpty", true)
		self.ScrollViewNYLottery:Update(0,function () end)
		return
	end

	self.pPanel:SetActive("LotteryItem", false)
	self.pPanel:SetActive("LotteryEmpty", false)

	local tbSpecialData = tbRankData[1]
	if tbSpecialData then
		local tbSpecialInfo = tbSpecialData[1]
		if tbSpecialInfo then
			self.pPanel:SetActive("LotteryItem", true)
			local szName = tbSpecialInfo.tbPlayerInfo and tbSpecialInfo.tbPlayerInfo.szName
			local szKinName = tbSpecialInfo.tbPlayerInfo and tbSpecialInfo.tbPlayerInfo.szKinName
			self["LotteryItem"].pPanel:Label_SetText("PlayerName",szName or "-")
			self["LotteryItem"].pPanel:Label_SetText("FamilyName",szKinName or "")
			self["LotteryItem"].pPanel:SetActive("itemframe", true)
			local tbAward = tbSpecialInfo.tbAward
			local tbItem = tbAward and tbAward[1]
			if tbItem then
				self["LotteryItem"]["itemframe"]:SetGenericItem(tbItem)
				self["LotteryItem"]["itemframe"].fnClick = self["LotteryItem"]["itemframe"].DefaultClick
			end
		end
	else
		self.pPanel:Label_SetText("PlayerName", "无人中奖")
		self.pPanel:Label_SetText("FamilyName", "")
		self.pPanel:SetActive("itemframe", false)
	end
	local tbRankInfo = self:GetFormatData(tbRankData)
	local fnSetItem = function(itemObj,nIdx)
		local tbRankData = tbRankInfo[nIdx]
		local nRank = tbRankData.nRank
		local tbPlayerInfo = tbRankData.tbPlayerData and tbRankData.tbPlayerData.tbPlayerInfo
		local szName = tbPlayerInfo and tbPlayerInfo.szName
		local szKinName = tbPlayerInfo and tbPlayerInfo.szKinName
		itemObj.pPanel:Label_SetText("PlayerName",szName or "-")
		itemObj.pPanel:Label_SetText("FamilyName",szKinName or "-")
		local tbAward = tbRankData.tbPlayerData and tbRankData.tbPlayerData.tbAward
		local tbItem = tbAward and tbAward[1]
		if tbItem then
			itemObj["itemframe"]:SetGenericItem(tbItem)
			itemObj["itemframe"].fnClick = itemObj["itemframe"].DefaultClick
		end

		local tbRankSprite = ChouJiang:GetRankSprite(nRank)
		if tbRankSprite then
			local szRankSprite,szEggSprite = unpack(tbRankSprite)
			itemObj.pPanel:Sprite_SetSprite("Reword",  szRankSprite);
			itemObj.pPanel:Sprite_SetSprite("Egg",  szEggSprite);
		end
	end 
	self.ScrollViewNYLottery:Update(#tbRankInfo,fnSetItem);
end

function tbNewInfoResultUi:GetFormatData(tbRankData)
	
	local tbRankInfo = {}
	local nCount = 0
	for nRank,tbInfo in pairs(tbRankData) do
		if nRank ~= 1 then
			for i,tbPlayerData in ipairs(tbInfo) do
				local tbTemp = {}
				tbTemp.nRank = nRank
				tbTemp.tbPlayerData = tbPlayerData
				table.insert(tbRankInfo,tbTemp)
			end
		end
	end
	return tbRankInfo
end