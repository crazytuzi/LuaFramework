local SceneMgr = luanet.import_type("UnityEngine.SceneManagement.SceneManager");

function Loading:DoStartLoading(nMapTemplateId, nType)
	local nCurMapTemplateId = self.nDstMaptemplateId or 0;
	self.nDstMaptemplateId = nMapTemplateId;
	if Map.tbMapList[nCurMapTemplateId] and Map.tbMapList[self.nDstMaptemplateId] and
		Map.tbMapList[nCurMapTemplateId].ResName == Map.tbMapList[self.nDstMaptemplateId].ResName then
		Ui.CameraMgr.SetMainCameraActive(true);
		Ui.CameraMgr.Reset(Ui.CameraMgr.s_CurSceneCameraName);
	end
	
	PreloadResource:OnChangeMap(nMapTemplateId);
	DoLoadMap(nMapTemplateId, nType);
	Ui:ShowAllRepresentObj(true);
	self.nLoadingTimerId = nil;
end

function Loading:StartLoadData(nMapTemplateId, nType)
	self.bLoadMapFinish = false;
	Ui:SetForbiddenOperation(false);
	Ui:SetAllUiVisable(true);
	SetGameWorldScale(1.0);
	Operation:SetGuidingJoyStick(false);
	
	self.nType = nType;

	if self.nLoadingTimerId then
		Timer:Close(self.nLoadingTimerId);
		self.nLoadingTimerId = nil;
	end
	
	self.nLoadingTimerId = Timer:Register(3, self.DoStartLoading, self, nMapTemplateId, nType);
	Ui:OpenWindow("MapLoading", nMapTemplateId or -1, self.nDstMaptemplateId or 0);
	Log("Loading StartLoadData", nMapTemplateId, nType);
end

function Loading:StartLoadScene(bFinish)
	if self.nUpdateTimerId then
		Timer:Close(self.nUpdateTimerId);
		self.nUpdateTimerId = nil;
	end

	if bFinish then
		self:LoadingFinish(true);
		return;
	end

	self.nRealPercent = 0.5;
	local nDebugCount = 0
	local bDebugLoged = false
	local function fnUpdatePercent()
		if self.nRealPercent < 1.0 then
			nDebugCount = nDebugCount + 1
			self.nRealPercent = math.max(Ui.ToolFunction.GetLoadMapPercent(), self.nRealPercent);
			local fPreloadPer = (1 - PreloadResource:GetLoadPercent()) * 0.3;
			self.nRealPercent = self.nRealPercent - fPreloadPer;
			if fPreloadPer >= 0.001 and self.nRealPercent > 1.0 then
				self.nRealPercent = self.nRealPercent - 0.01;
		    end
		    if nDebugCount >= 100 and not bDebugLoged then
		    	Log("[Loading Debug] Client Stop Here", self.nRealPercent, fPreloadPer)
		    	bDebugLoged = true
		    end
		end

		if self.nRealPercent >= 1.0 then
			self.nUpdateTimerId = nil;
			self:LoadingFinish();
			return;
		end
		return true;
	end

	self.nUpdateTimerId = Timer:Register(1, fnUpdatePercent);
end

function Loading:LoadingFinish(bDealyOk)
	ResetLogicFrame();
	XinShouLogin:OnMapLodingEnd();

	if not bDealyOk then
		Timer:Register(8, self.LoadingFinish, self, true);
		return;
	end
	self.bLoadMapFinish = true;
	if self.nDstMaptemplateId ~= 0 then
		Operation:OnMapLoaded();
	end

	local szSceneName = SceneMgr.GetActiveScene().name
	local nMapTemplateId = me.nMapTemplateId and me.nMapTemplateId > 0 and me.nMapTemplateId or self.nDstMaptemplateId
	local szMapResName = Map:GetMapResName(nMapTemplateId)
	if szSceneName == szMapResName then
		Ui:CloseWindow("MapLoading");
	else
		Timer:Register(5 * Env.GAME_FPS, function () 
				if Ui:WindowVisible("MapLoading") then
					Ui:CloseWindow("MapLoading")
				end
			end)
		Log("[Loading] SceneName is Not same as MapResName !!!", szSceneName, szMapResName, me.nMapTemplateId)
	end
	Map:OnMapLoaded(self.nDstMaptemplateId);
end

function Loading:IsLoadMapFinish()
	return self.bLoadMapFinish;
end