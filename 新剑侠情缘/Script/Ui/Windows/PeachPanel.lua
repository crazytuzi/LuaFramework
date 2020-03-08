local tbUi = Ui:CreateClass("PeachPanel");

function tbUi:OnOpenEnd()
	self:Update();
end


function tbUi:Update()
	if me.nMapTemplateId == House.tbPeach.FAIRYLAND_MAP_TEMPLATE_ID then
		self:UpdateFairylandPeach();
	elseif House:IsInNormalHouse(me) then
		self:UpdateHousePeach();
	end
end

function tbUi:UpdateHousePeach()
	local tbPeachData = House.tbPeach:GetPeachData() or {};

	self.pPanel:SetActive("Peach1", false);
	self.pPanel:SetActive("Peach2", false);
	self.pPanel:SetActive("Peach3", false);

	local nPercent = 1;
	local nWater = tbPeachData.nWater or 0;
	if nWater < House.tbPeach.WATER_STATE_MATRUE_COUNT then
		nPercent = nWater/House.tbPeach.WATER_STATE_MATRUE_COUNT;
	end
	self.pPanel:Sprite_SetFillPercent("Bar", nPercent);

	if not tbPeachData.nFertilizerId then
		self.pPanel:Label_SetText("BtnTxt", "施肥");
		self.pPanel:Label_SetText("Title", "桃花树");
	elseif nWater < House.tbPeach.WATER_STATE_MATRUE_COUNT then
		self.pPanel:Label_SetText("BtnTxt", "浇水");
		self.pPanel:Label_SetText("Title", "桃花树");
	else
		self.pPanel:Label_SetText("BtnTxt", "幻境");
		self.pPanel:Label_SetText("Title", "桃花幻境");
	end
end

function tbUi:UpdateFairylandPeach()
	local tbPeachData = House.tbPeach:GetPeachData() or {};
	local nWater = tbPeachData.nWater or 0;
	local nTree = math.floor(nWater / House.tbPeach.WATER_STATE_MATRUE_COUNT);
	self.pPanel:Sprite_SetFillPercent("Bar", nTree / House.tbPeach.FAIRYLAND_MAX_TREE_COUNT);

	local nAwardIdx = House.tbPeach:GetMyAwardIdx();
	local bMyFairyLand = House.tbPeach:InMyFairyland();
	local nIdx = 1;
	for nTreeCount = 1, House.tbPeach.FAIRYLAND_MAX_TREE_COUNT do
		if House.tbPeach.FAIRYLAND_TREE_MATRUE_AWARD[nTreeCount] then
			local szPeachName = "Peach" .. nIdx;
			self.pPanel:SetActive(szPeachName, true);

			local bReach = nTree >= nTreeCount;
			local bTaked = nAwardIdx >= nTreeCount;

			self.pPanel:Sprite_SetGray(szPeachName, not bReach);
			self.pPanel:SetActive(string.format("texiao_%d%d", nIdx, 1), bReach and not bTaked and bMyFairyLand);
			self.pPanel:SetActive(string.format("texiao_%d%d", nIdx, 2), bReach and not bTaked and bMyFairyLand);
			nIdx = nIdx + 1;
		end
	end

	self.pPanel:Label_SetText("BtnTxt", "护持");
	self.pPanel:Label_SetText("Title", "桃花幻境");
end

function tbUi:Close()
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnClose()
	self:Close();
end

function tbUi.tbOnClick:Btn()
	if me.nMapTemplateId == House.tbPeach.FAIRYLAND_MAP_TEMPLATE_ID then
		House.tbPeach:BringUp();
	elseif House:IsInNormalHouse(me) then
		local tbPeachData = House.tbPeach:GetPeachData() or {};
		if not tbPeachData.nFertilizerId then
			House.tbPeach:Fertilizer();
		elseif tbPeachData.nWater < House.tbPeach.WATER_STATE_MATRUE_COUNT then
			House.tbPeach:Water();
		else
			House.tbPeach:GoFairyland();
		end
	end
end

local nIdx = 1;
for nTreeCount = 1, House.tbPeach.FAIRYLAND_MAX_TREE_COUNT do
	if House.tbPeach.FAIRYLAND_TREE_MATRUE_AWARD[nTreeCount] then
		local szPeachName = "Peach" .. nIdx;
		tbUi.tbOnClick[szPeachName] = function (self, ...)
			local tbPeachData = House.tbPeach:GetPeachData() or {};
			local nWater = tbPeachData.nWater or 0;
			local nTree = math.floor(nWater / House.tbPeach.WATER_STATE_MATRUE_COUNT);
			local nAwardIdx = House.tbPeach:GetMyAwardIdx();

			local bReach = nTree >= nTreeCount;
			local bTaked = nAwardIdx >= nTreeCount;
			local bMyFairyLand = House.tbPeach:InMyFairyland();

			if not bReach or not bMyFairyLand then
				local tbAward = House.tbPeach.FAIRYLAND_TREE_MATRUE_AWARD[nTreeCount];
				Item:ShowItemDetail({nTemplate = tbAward[1][2]});
			elseif not bTaked then
				House.tbPeach:TakeTreeAward(nTreeCount);
			else
				me.CenterMsg("奖励已领取");
			end
		end
		nIdx = nIdx + 1;
	end
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_HOUSE_PEACH_SYNC_DATA, self.Update},
		{ UiNotify.emNOTIFY_MAP_LEAVE, self.Close},
	};
	return tbRegEvent;
end
