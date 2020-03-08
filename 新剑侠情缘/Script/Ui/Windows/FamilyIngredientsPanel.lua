local tbUi = Ui:CreateClass("FamilyIngredientsPanel");

tbUi.REFRESH_TIME = 5 

tbUi.szTab = "StageInformation";

tbUi.tbOnClick = {}

tbUi.tbOnClick = {
    BtnClose = function(self)
    	if self.nRegisterId then
			Timer:Close(self.nRegisterId)
		end
		self:StopTimer();
        Ui:CloseWindow(self.UI_NAME)
    end,

    StageInformation = function (self)
    	self.szTab = "StageInformation";
    	Activity.DumplingBanquetAct:UpdateCurrentStageData()
    	self.pPanel:SetActive("Panel1",false);
    	self.pPanel:SetActive("Panel2",true);
	end,

	FamilyRank = function (self)
		self:RefreshRank();
		self.szTab = "FamilyRank";
		Activity.DumplingBanquetAct:UpdateRankData()
		self.pPanel:SetActive("Panel1",true);
    	self.pPanel:SetActive("Panel2",false);
	end
}

function tbUi:RegisterEvent()
	return {
		{UiNotify.emNOTIFY_REFRESH_DUMPLINGBANQUET_CURRENTSTAGEINFO, self.Refresh, self},
		{UiNotify.emNOTIFY_REFRESH_DUMPLINGBANQUET_RANK, self.RefreshRank, self},
	}
end

function tbUi:OnOpen()
	Activity.DumplingBanquetAct:UpdateCurrentStageData()
	self:StartTimer();
	self:RefreshStageData();
	if self.szTab == "StageInformation" then
		self:RefreshStageData();
		Activity.DumplingBanquetAct:UpdateCurrentStageData()
		self.pPanel:SetActive("Panel1",false);
		self.pPanel:SetActive("Panel2",true);
	else
		Activity.DumplingBanquetAct:UpdateRankData()
	end
end

function tbUi:Refresh()
	local tbInfo = Activity.DumplingBanquetAct:GetCurrentStageData()
	if tbInfo then
		local fPercentage1 = 0;
		local fPercentage2 = 0;
		if tbInfo.nStageNum1 ~= 0 then
			fPercentage1 = tbInfo.nStageNum1 / tbInfo.nStageMaxNum;
		end
		if tbInfo.nStageNum2 ~= 0 then
			fPercentage2 = tbInfo.nStageNum2 / tbInfo.nStageMaxNum;
		end
		self.pPanel:SliderBar_SetValue("Bar1", fPercentage1)
		self.pPanel:Label_SetText("BarTxt1", tostring(tbInfo.nStageNum1));
		self.pPanel:SliderBar_SetValue("Bar2", fPercentage2)
		self.pPanel:Label_SetText("BarTxt2", tostring(tbInfo.nStageNum2));
	end
end

function tbUi:RefreshStageData()
	local tbInfo = Activity.DumplingBanquetAct:GetStageData()
	if tbInfo then
		local  szMsg = string.format("第%d阶段目标：", tbInfo.nStage)
		local szStageGoal = szMsg..tbInfo.szStageGoal1..tbInfo.szStageGoal2.."饺";
		local szNum = string.format("今日活动已做成饺子：%d", tbInfo.nTodayDumplingNum);
		self.pPanel:Label_SetText("Ingredients1", tbInfo.szStageGoal1);
		self.pPanel:Label_SetText("Ingredients2", tbInfo.szStageGoal2);
		self.pPanel:Label_SetText("Stage", szStageGoal)
		self.pPanel:Label_SetText("Number",szNum)
	end
end

function tbUi:RefreshRank()
	local tbData = Activity.DumplingBanquetAct:GetRankData()
	local fnSetItem = function (itemObj, nIdx)
		itemObj.pPanel:Label_SetText("Rank", nIdx)
		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbData.tbRankData[nIdx][3])
		if ImgPrefix and Atlas then
			itemObj.pPanel:SetActive("PlayerTitle", true);
			itemObj.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
		else
			itemObj.pPanel:SetActive("PlayerTitle", false);
		end
		itemObj.pPanel:Label_SetText("Name", tbData.tbRankData[nIdx][2])
		itemObj.pPanel:Label_SetText("Correct", tbData.tbRankData[nIdx][4])
		itemObj.pPanel:Label_SetText("Error", tbData.tbRankData[nIdx][5])
	end
	self.ScrollView:Update(tbData.tbRankData, fnSetItem);
	local tbAct = Activity.DumplingBanquetAct
	self.pPanel:SetActive("MyRank", false);
	local tbMyRank = Activity.DumplingBanquetAct:GetMyRank()
	if #tbData == 0 and #tbMyRank ~= 0 then
		self.pPanel:SetActive("MyRank", true);
		self.pPanel:Label_SetText("Rank", tostring(tbAct.nMyRank))
		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbMyRank[3])
		if ImgPrefix and Atlas then
			self.pPanel:SetActive("PlayerTitle", true);
			self.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
		else
			self.pPanel:SetActive("PlayerTitle", false);
		end
		self.pPanel:Label_SetText("Name", tbMyRank[2])
		self.pPanel:Label_SetText("Correct", tbMyRank[4])
		self.pPanel:Label_SetText("Error", tbMyRank[5])
	else
		self.pPanel:SetActive("MyRank", false);
	end
end

function tbUi:UpdateTime() 
	local tbData = Activity.DumplingBanquetAct:GetStageData()
	local nEndTime = tbData.nStageEndTime;
	local nTimeLeft = nEndTime - GetTime();
	self.pPanel:Label_SetText("Time", string.format("剩余时间：%s", Lib:TimeDesc3(math.max(0, nTimeLeft))))
end

function tbUi:StartTimer()
	self:StopTimer()
	self.nTimer = Timer:Register(math.floor(Env.GAME_FPS), function()
		self:UpdateTime()
		return true
	end)
end

function tbUi:StopTimer()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil
	end
end
