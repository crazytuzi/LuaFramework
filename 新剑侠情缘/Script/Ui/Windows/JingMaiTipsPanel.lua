
local tbUi = Ui:CreateClass("JingMaiTipsPanel");

tbUi.tbAddInfoUiSetting = 
{
	{
		szItemPanel = "AdditionalSkillTitle";
		szRangeItem = "SkillBgRange";
		szScrollView = "ScrollViewSkill";
	};
	{
		szItemPanel = "AdditionalSkillTitle2";
		szRangeItem = "SkillBgRange2";
		szScrollView = "ScrollViewSkill2";
	}
}

tbUi.tbAddInfoSetting = 
{
	{
		szFnSetItem = "SetSkillItem";
		szItemTitle = "附加技能";
	};
	{
		szFnSetItem = "SetJingMainLevelItem";
		szItemTitle = "周天等级";
	}
}

function tbUi:OnOpen(tbExtAttrib, tbSkillInfo, bHasNoPartner, bFromItemBox, tbJingMaiLevelInfo)
	tbJingMaiLevelInfo = self:FormatJingMainLevel(tbJingMaiLevelInfo)
	self.bFromItemBox = bFromItemBox;
	self.bHasNoPartner = bHasNoPartner;
	if self.bHasNoPartner then
		self.tbExtAttrib = {};
		self.tbSkillInfo = {};
		self.tbJingMaiLevelInfo = {}
	else
		self.tbExtAttrib = tbExtAttrib or {};
		self.tbSkillInfo = tbSkillInfo or {};
		self.tbJingMaiLevelInfo = tbJingMaiLevelInfo or {};
	end
	self:Update();
end

function tbUi:SetSkillItem(itemObj, index, tbSkillInfo)
	local function fnOnClickSkill(nSkillId, nSkillLevel, nMaxSkillLevel)
		local tbSubInfo = FightSkill:GetSkillShowTipInfo(nSkillId, nSkillLevel, nMaxSkillLevel);
		Ui:OpenWindow("SkillShow", tbSubInfo);
	end
	local nSkillId, nSkillLevel, nMaxSkillLevel = unpack(tbSkillInfo[index]);
	itemObj.pPanel:Label_SetText("Level", nSkillLevel);

	local tbValue = FightSkill:GetSkillShowInfo(nSkillId);
	itemObj.pPanel:Sprite_SetSprite("Icon", tbValue.szIconSprite, tbValue.szIconAtlas);

	itemObj.pPanel.OnTouchEvent = function ()
		fnOnClickSkill(nSkillId, nSkillLevel, nMaxSkillLevel);
	end
end

function tbUi:SetJingMainLevelItem(itemObj, index, tbJingMaiLevelInfo)
	local function fnOnClickSkill(nJingMaiId, nLevel)
		Ui:OpenWindow("ZhouTianShowPanel", nJingMaiId, nLevel);
	end
	local tbInfo = tbJingMaiLevelInfo[index] or {}
	local nLevel = tbInfo.nLevelIndex or 0
	local nJingMaiId = tbInfo.nJingMaiId or 0
	local tbJMSetting = JingMai.tbJingMaiSetting[nJingMaiId] or {}
	local nIcon  = tbJMSetting.nLevelIcon
    local szIconAtlas, szIconSprite = Item:GetIcon(nIcon);
	itemObj.pPanel:Sprite_SetSprite("Icon", szIconSprite, szIconAtlas)
	itemObj.pPanel:Label_SetText("Level", nLevel);
	itemObj.pPanel.OnTouchEvent = function ()
		fnOnClickSkill(nJingMaiId, nLevel);
	end
end

function tbUi:FormatJingMainLevel(tbJingMaiLevelInfo)
	local tbJingMaiLevel = {}
	for nJingMaiId, v in pairs(tbJingMaiLevelInfo or {}) do
		if (v.nLevelIndex or 0) > 0 then
			v.nJingMaiId = nJingMaiId
			table.insert(tbJingMaiLevel, v)
		end
	end
	if #tbJingMaiLevel > 1 then
		table.sort(tbJingMaiLevel, function (a, b) return a.nJingMaiId < b.nJingMaiId end )
	end
	return tbJingMaiLevel
end

function tbUi:Update()
	local tbAddInfo = {}
	if #self.tbSkillInfo > 0 then
		table.insert(tbAddInfo, {nSettingId = 1, tbData = self.tbSkillInfo})
	end
	if #self.tbJingMaiLevelInfo > 0 then
		table.insert(tbAddInfo, {nSettingId = 2, tbData = self.tbJingMaiLevelInfo})
	end 
	local nSLine = #tbAddInfo > 0 and (#tbAddInfo * 4) or 0;
	self.pPanel:Label_SetText("Anchor", #tbAddInfo > 0 and string.rep("\n", #tbAddInfo * 4) or "");

	for _, v in ipairs(self.tbAddInfoUiSetting) do
		self.pPanel:SetActive(v.szItemPanel, false)
	end
	-- scrollview要默认设置可见，如果scrollvierw默认设置不可见没有init第一次打开update的时候会报错
	if #tbAddInfo > 0 then
		for nIndex, v in ipairs(tbAddInfo) do
			local tbUiSetting = self.tbAddInfoUiSetting[nIndex]
			local tbInfoSetting = self.tbAddInfoSetting[v.nSettingId]
			local tbData = v.tbData
			if tbUiSetting and tbInfoSetting and tbData then
				local szItemPanel = tbUiSetting.szItemPanel
				local szRangeItem = tbUiSetting.szRangeItem
				local szScrollView = tbUiSetting.szScrollView
				local szItemTitle = tbInfoSetting.szItemTitle
				local szFnSetItem = tbInfoSetting.szFnSetItem
				self.pPanel:SetActive(szItemPanel, true);
				self.pPanel:SetActive(szRangeItem, #tbData > 5);
				self.pPanel:Label_SetText(szItemPanel, szItemTitle);
				local function fnSetItem(itemObj, index)
					if self[szFnSetItem] then
						self[szFnSetItem](self, itemObj, index, tbData)
					end
				end
				self[szScrollView]:Update(tbData, fnSetItem);
				
			end
		end
	end
	
	local szDesc, nLine = JingMai:GetAttribDesc(JingMai:GetAttribInfo(self.tbExtAttrib));
	nSLine = nSLine + nLine;
	if self.bHasNoPartner then
		szDesc = "当前无同伴上阵不享受属性加成";
	elseif szDesc == "" then
		szDesc = "尚未打通任何穴位！";
	end

	self.pPanel:SetActive("BtnGo", self.bFromItemBox and true or false);
	self.pPanel:Label_SetText("Attribute", szDesc ~= "" and szDesc or "无经脉属性加成");
	local nOneScrollViewSize = 40
	self.pPanel:ResizeScrollViewBound("ScrollView", #self.tbAddInfoSetting * nOneScrollViewSize - nSLine * 20, nOneScrollViewSize * (#self.tbAddInfoSetting + 2));
	self.pPanel:DragScrollViewGoTop("ScrollView");
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};
tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnGo = function (self)
	Ui:CloseWindow(self.UI_NAME);
	Ui:CloseWindow("ItemBox");
	Ui:OpenWindow("JingMaiPanel");
end