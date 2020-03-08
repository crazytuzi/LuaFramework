Require("CommonScript/Help/StrongerDefine.lua")
Player.Stronger = Player.Stronger or {}
local Stronger = Player.Stronger
local StrongerUI = Ui:CreateClass("StrongerPanel");

StrongerUI.tbOnClick = StrongerUI.tbOnClick or {};

function StrongerUI.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end

function StrongerUI:OnOpen(nSelectedBaseId, nSelectedSubId)
	if not Stronger:CheckVisible()  then
		me.CenterMsg("少侠已经不再需要这里的指引")
		return
	end

	self.nSelectedBaseId = nSelectedBaseId or 1
	self.nSelectedSubId = nSelectedSubId or 1
	self.nGotoIndex = 0;
	self.bUseRecommend = (TimeFrame:GetTimeFrameState(Stronger.RECOMMEND_TIMEFRAME) == 1)
	if self.bUseRecommend then
		Stronger:CheckRecoomendData();
	end

	self:RefreshMainInfo()

	if nSelectedSubId then
		self:SetSubItem()
	else
		self:InitListLeft()
	end

	self:UpdateLeftListHeight();
	self:UpdateListLeft()
	if Stronger.detailList[self.nSelectedBaseId] and Stronger.detailList[self.nSelectedBaseId][self.nSelectedSubId]  then
		self:UpdateDetailList(Stronger.detailList[self.nSelectedBaseId][self.nSelectedSubId])
	else
		self:UpdateDetailList({})
	end

	Kin:UpdateBuildingData();
end

function StrongerUI:SetSubItem()
	local tbView = {}
	for _, v in ipairs(Stronger.baseList) do
		table.insert(tbView, v)
		if self.nSelectedBaseId == v.BaseId then
			for _, v2 in ipairs(Stronger.subList[v.BaseId]) do
				table.insert(tbView, v2)
			end
		end
	end
	self.tbLeftList = tbView
end

function StrongerUI:InitListLeft()
	self.tbLeftList = Lib:CopyTB1(Stronger.baseList)
end

function StrongerUI:RefreshMainInfo()
	local nFightPower = Stronger:GetPlayerFightPower();
	local _, nRecommendPower = Stronger:GetRecommendFP();

	self.pPanel:Label_SetText("SelfFightPower", tostring(nFightPower))

	self.pPanel:Label_SetText("FightPowerTitle2", string.format("%d级推荐战力：", me.nLevel))
	self.pPanel:Label_SetText("RecommendFightPower", tostring(nRecommendPower));
end

function StrongerUI:UpdateLeftListHeight()
	local tbHeight = {};
	self.nGotoIndex = 0;
	for _,v in ipairs(self.tbLeftList) do
		local nHeight = 76
		if v.SubId and v.SubId > 0 then
			nHeight = 60
			if v.SubId == self.nSelectedSubId then
				self.nGotoIndex = self.nSelectedBaseId + self.nSelectedSubId;
			end
		end
		table.insert(tbHeight, nHeight);
	end

	self.ScrollViewBtn:UpdateItemHeight(tbHeight);
end

function StrongerUI:UpdateListLeft()
	local fnClickClass = function (buttonObj)
		self.pPanel:SpringPanel_SetEnabled("ScrollViewBtn",false);
		local cfg = buttonObj.cfg
		if cfg.SubId and cfg.SubId > 0 then
			self.nSelectedSubId = cfg.SubId
			--显示详细信息
			if Stronger.detailList[cfg.BaseId] and Stronger.detailList[cfg.BaseId][self.nSelectedSubId] then
				self:UpdateDetailList(Stronger.detailList[cfg.BaseId][self.nSelectedSubId])
			else
				self:UpdateDetailList({})
			end
		else
			self.nSelectedSubId = nil

			if not Stronger.subList[cfg.BaseId] or #Stronger.subList[cfg.BaseId] <= 0 then
				--当前大类没有小类列表
				if cfg.BaseId ~= self.nSelectedBaseId then
					self.nSelectedBaseId = cfg.BaseId
					self.tbLeftList = Lib:CopyTB1(Stronger.baseList)
					self:UpdateDetailList(Stronger.detailList[cfg.BaseId][1])
				end
			else
				if cfg.BaseId == self.nSelectedBaseId then ----选中当前大类时 收起来
					self.tbLeftList = Lib:CopyTB1(Stronger.baseList)
					self.nSelectedBaseId = nil
				else
					self.nSelectedBaseId = cfg.BaseId
					self:SetSubItem()
					--self.ScrollViewBtn.pPanel:ScrollViewGoTop();
				end
			end

			self:UpdateLeftListHeight();
			self:UpdateListLeft();
			self.ScrollViewItem.pPanel:ScrollViewGoTop();
		end
	end

	local fnSetItem = function (itemObj, index)
		local cfg = self.tbLeftList[index]

		if cfg.SubId and cfg.SubId > 0 then
			itemObj.pPanel:SetActive("BaseClass", false)
			itemObj.pPanel:SetActive("SubClass", true)

			itemObj.SubClass.pPanel:Label_SetText("Label", cfg.Name);
			itemObj.SubClass.pPanel:Toggle_SetChecked("Main", self.nSelectedSubId == cfg.SubId) 
			itemObj.SubClass.cfg = cfg;
			itemObj.SubClass.pPanel.OnTouchEvent = fnClickClass;
		else
			itemObj.pPanel:SetActive("BaseClass", true)
			itemObj.pPanel:SetActive("SubClass", false)
			local tbNextData = self.tbLeftList[index + 1]
			if  tbNextData and  tbNextData.SubId and tbNextData.SubId > 0 then
				itemObj.BaseClass.pPanel:SetActive("BtnDownS", false)
				itemObj.BaseClass.pPanel:SetActive("Checked", true)
				itemObj.BaseClass.pPanel:SetActive("BtnUpS", true)
				itemObj.BaseClass.pPanel:SetActive("LabelLight", true)
				itemObj.BaseClass.pPanel:Button_SetSprite("Main", "BtnListMainPress", 1)

			else
				if Stronger.subList[cfg.BaseId] and #Stronger.subList[cfg.BaseId] > 0 then
					itemObj.BaseClass.pPanel:SetActive("BtnDownS", true)
					itemObj.BaseClass.pPanel:SetActive("Checked", false)
				else
					itemObj.BaseClass.pPanel:SetActive("BtnDownS", false)
					itemObj.BaseClass.pPanel:SetActive("Checked", self.nSelectedBaseId == cfg.BaseId)
					itemObj.BaseClass.pPanel:SetActive("BtnUpS", false)
					itemObj.BaseClass.pPanel:SetActive("LabelLight", true)
				end

				if self.nSelectedBaseId == cfg.BaseId then
					itemObj.BaseClass.pPanel:Button_SetSprite("Main", "BtnListMainPress", 1)
				else
					itemObj.BaseClass.pPanel:Button_SetSprite("Main", "BtnListMainNormal", 1)
				end
			end

			itemObj.BaseClass.pPanel:Label_SetText("LabelLight", cfg.Name);
			itemObj.BaseClass.pPanel:Label_SetText("LabelDark", cfg.Name);

			itemObj.BaseClass.cfg = cfg;
			itemObj.BaseClass.pPanel.OnTouchEvent = fnClickClass;
		end
	end

	if self.nGotoIndex > 0 then
		self.ScrollViewBtn.pPanel:ScrollViewGoToIndex("Main", self.nGotoIndex);
	end
	self.ScrollViewBtn:Update(self.tbLeftList, fnSetItem);
end

function StrongerUI:UpdateDetailList(tbDetailList)
	--过滤条件
	self.tbDetailList = {}

	for _,tbDetail in ipairs(tbDetailList) do
		if (not tbDetail.Level or me.nLevel >= tbDetail.Level) and
			(not tbDetail.TimeFrame or tbDetail.TimeFrame == "" or GetTimeFrameState(tbDetail.TimeFrame) == 1) then

			--检查推荐战力数据是否存在
			local nFPType = Stronger.Type[tbDetail.Desc]
			if nFPType then
				local nFP = Stronger:GetFightPowerByType(nFPType)
				local _, nRecommendFP, _ = Stronger:GetRecommendDataByType(nFPType)
				tbDetail.nFP = nFP
				tbDetail.nRecommendFP = nRecommendFP
			end
			table.insert(self.tbDetailList, tbDetail)
		end
	end

	table.sort(self.tbDetailList, function (a, b)
		if a.nFP and b.nFP then
			return (a.nFP/a.nRecommendFP) < (b.nFP/b.nRecommendFP)
		end
		return a.DetailId < b.DetailId;
	end)

	local fnNormalClick = function (buttonObj)
		local action = buttonObj.cfg.Action
		if action and action ~= "" then
			action =  string.gsub(action, "\"", "");
			loadstring("return " .. action)();
		end
	end

	local fnRecommendClick = function (buttonObj)
		local cfg = buttonObj.cfg
		local nType = Stronger.Type[cfg.Desc]
		if nType then
			Ui:OpenWindow("StrongerDetailsPanel", cfg)
		end
	end

	local fnSetItem = function (itemObj, index)
		local cfg = self.tbDetailList[index]
		local nFPType = Stronger.Type[cfg.Desc]

		if cfg.Icon and cfg.Icon ~= "" then
			itemObj.pPanel:Sprite_SetSprite("Icon",cfg.Icon, (cfg.IconAtlas ~= "" and cfg.IconAtlas) or nil);
		end

		itemObj.pPanel:Label_SetText("TitleName", cfg.Name or "");

		if nFPType then
			--itemObj.pPanel:SetActive("State",true);
			itemObj.pPanel:SetActive("BarBg",true);
			itemObj.pPanel:SetActive("starrank",false);
			itemObj.pPanel:SetActive("Content",false);

			--itemObj.pPanel:Label_SetText("State1",desc);
			--itemObj.pPanel:Label_SetColor("State1",stateColor.r, stateColor.g, stateColor.b);
			itemObj.pPanel:Sprite_SetFillPercent("Bar", math.min(1, cfg.nFP/cfg.nRecommendFP))
			itemObj.BtnGo.pPanel.OnTouchEvent = fnRecommendClick
		else
			--itemObj.pPanel:SetActive("State",false);
			itemObj.pPanel:SetActive("BarBg",false);
			itemObj.pPanel:SetActive("starrank",true);
			itemObj.pPanel:SetActive("Content",true);

			itemObj.pPanel:Label_SetText("Content",cfg.Desc or "");

			local stars = cfg.Stars or 0

			for i=1,5 do
				itemObj.pPanel:SetActive(string.format("SprStar%d",i), i <= stars);
			end

			itemObj.BtnGo.pPanel.OnTouchEvent = fnNormalClick
		end

		itemObj.BtnGo.cfg = cfg;
	end


	self.ScrollViewItem:Update(self.tbDetailList, fnSetItem);
end

function StrongerUI:OnFightPowerChange()
	self:RefreshMainInfo()
	self:UpdateDetailList(self.tbDetailList)
end

function StrongerUI:OnRecommendDataRefresh()
	self:RefreshMainInfo()
	print("OnRecommendDataRefresh")
	if Stronger.detailList[self.nSelectedBaseId] and Stronger.detailList[self.nSelectedBaseId][self.nSelectedSubId]  then
		self:UpdateDetailList(Stronger.detailList[self.nSelectedBaseId][self.nSelectedSubId])
	else
		self:UpdateDetailList(self.tbDetailList)
	end
end

function StrongerUI:OnEnterMap()
	Ui:CloseWindow(self.UI_NAME);
end

function StrongerUI:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_FIGHT_POWER_CHANGE, self.OnFightPowerChange, self},
		{ UiNotify.emNOTIFY_FIGHT_POWER_RECOMMEND, self.OnRecommendDataRefresh, self},
		{UiNotify.emNOTIFY_MAP_ENTER, self.OnEnterMap},
	};

	return tbRegEvent;
end
