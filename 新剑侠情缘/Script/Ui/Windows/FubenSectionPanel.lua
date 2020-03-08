
local tbUi = Ui:CreateClass("FubenSectionPanel");


function tbUi:OnOpen(szType)
	if szType and szType ~= "ExplorationFuben" then
		Log(debug.traceback())
		return 0;
	end

	if me.nLevel < MapExplore.MIN_LEVEL then
		me.CenterMsg(string.format("%d级才能参与地图探索", MapExplore.MIN_LEVEL))
		return 0;
	end
	self:RequestUpdateMapExplore();
end

function tbUi:Clear()
	self.ScrollView.pPanel:SetActive("Main", false);
	self.ScrollViewExplore.pPanel:SetActive("Main", false);
	self.pPanel:SetActive("MapExploreTimes", false)
end

function tbUi:RequestUpdateMapExplore()
	if MapExplore:GetMapStepInfo() then
		self:UpdateMapExplore();
	end
end

function tbUi:UpdateMapExplore()
	self:Clear();

	self.pPanel:SetActive("MapExploreTimes", true)
	local nDegree = DegreeCtrl:GetDegree(me, "MapExplore")
	self.pPanel:Label_SetText("RemainingNumber", nDegree)
	-- self.pPanel:SetActive("BtnPlus", nDegree <= 0)
	
	self.nFubenLevel = nil;

	self.ScrollViewExplore.pPanel:SetActive("Main", true);

	local fnOnSelect = function (itemObj)
		if not itemObj.nStep then
			local tbSelInfo = MapExplore.tbSectionMap[itemObj.nIndex]
			me.CenterMsg(string.format("%d级才能探索该地图", tbSelInfo.nNeedLevel))
			return
		end

		local bFinish = itemObj.nStep >= MapExplore.MAX_STEP
		local bCanRestSet = MapExplore:CanResetMap(itemObj.nMapTemplateId, MapExplore.tbMapStepInfo, MapExplore.tbResetInfo) 

		if bFinish and not bCanRestSet then
			me.CenterMsg("该地图今天已经探索完了")
			return
		end

		if not MapExplore:CheckTimes() then
			return
		end

		if bCanRestSet then
			MapExplore:ClentRequeestReset(itemObj.nMapTemplateId)
			return
		end

		RemoteServer.RequestMapExplore(itemObj.nMapTemplateId);
	end

	local nMeLevel = me.nLevel
	local fnSetItem = function (itemObj, nIndex)
		itemObj.pPanel.OnTouchEvent = fnOnSelect;

		local tbSelInfo = MapExplore.tbSectionMap[nIndex]
		local nMapTemplateId = tbSelInfo.nMapTemplateId
		local szMapName = Map:GetMapName(nMapTemplateId)

		itemObj.pPanel:Label_SetText("FubenTitle", "探索".. szMapName)
		itemObj.pPanel:Sprite_SetSprite("SpriteBg", tbSelInfo.szUiSpriteName, tbSelInfo.szUiAtlas)


		itemObj.nIndex = nIndex;
		itemObj.nStep = nil;
		if nMeLevel >= tbSelInfo.nNeedLevel  then
			itemObj.pPanel:SetActive("Lock", false)
			-- 每天  默认都是0 
			local nStep = 0
			local bCanReset = false
			if MapExplore.tbMapStepInfo then
				
				itemObj.nMapTemplateId = nMapTemplateId
				nStep = MapExplore.tbMapStepInfo[nMapTemplateId] or 0
				bCanReset = MapExplore:CanResetMap(nMapTemplateId, MapExplore.tbMapStepInfo, MapExplore.tbResetInfo) 
			end
			itemObj.nStep = nStep;

			if bCanReset then
				itemObj.pPanel:SetActive("ExplorationProgress", false)
				itemObj.pPanel:SetActive("ExplorationProgressSlider", false)
				itemObj.pPanel:SetActive("Reset", true)
			else
				itemObj.pPanel:SetActive("ExplorationProgress", true)
				itemObj.pPanel:SetActive("ExplorationProgressSlider", true)
				itemObj.pPanel:SetActive("Reset", false)
				itemObj.pPanel:ProgressBar_SetValue("ExplorationProgressSlider", nStep / MapExplore.MAX_STEP)
				itemObj.pPanel:Label_SetText("LabelProg", string.format("%d/%d", nStep, MapExplore.MAX_STEP))
			end
		else
			itemObj.pPanel:SetActive("Lock", true)
			itemObj.pPanel:Label_SetText("limite", string.format("%d级", tbSelInfo.nNeedLevel))

			itemObj.pPanel:SetActive("ExplorationProgress", true)
			itemObj.pPanel:SetActive("ExplorationProgressSlider", true)
			itemObj.pPanel:SetActive("Reset", false)
			itemObj.pPanel:ProgressBar_SetValue("ExplorationProgressSlider", 0)
			itemObj.pPanel:Label_SetText("LabelProg", string.format("%d/%d", 0, MapExplore.MAX_STEP))
		end
	end

	self.ScrollViewExplore:Update(MapExplore.tbSectionMap, fnSetItem)

	local nNowMaxIndex = 1;
	for i, tbSelInfo in ipairs(MapExplore.tbSectionMap) do
		if nMeLevel >= tbSelInfo.nNeedLevel then
			nNowMaxIndex = i;
		else
			break;
		end
	end
	nNowMaxIndex = math.min(#MapExplore.tbSectionMap, nNowMaxIndex + 1)
	self.ScrollViewExplore.pPanel:ScrollViewGoToIndex("Main", nNowMaxIndex)
end

function tbUi:OnNotify(szFunc, ...)
	if not self[szFunc] then
		return;
	end

	self[szFunc](self, ...);
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_FUBEN_SECTION_PANEL,      	self.OnNotify},
        { UiNotify.emNOTIFY_BUY_DEGREE_SUCCESS,      	self.UpdateMapExplore},
        { UiNotify.emNOTIFY_CHANGE_PLAYER_LEVEL,        self.UpdateMapExplore},
    };

    return tbRegEvent;
end

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow("FubenSectionPanel");
end