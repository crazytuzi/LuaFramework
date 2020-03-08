local tbUi = Ui:CreateClass("WeddingWelcomePanel");
local NpcViewMgr = luanet.import_type("NpcViewMgr");
tbUi.tbPos = { {-100.8, -46.5, 100, 0, 180, 0}, {190.7, -46.3, 100, 0, 180, 0} }
tbUi.tbRes = {
	[Wedding.Level_1] = {601,602};
	[Wedding.Level_2] = {590,603};
	[Wedding.Level_3] = {591,604};
}
function tbUi:OnCreate()
	self.tbViewModelIds = {} -- {id1,id2}
	self.tbAllResId = {}
end

function tbUi:OnOpen(tbWelcomeInfo)
	local tbPlayer = tbWelcomeInfo.tbPlayer or {}

	self.nMapId = tbWelcomeInfo.nMapId
	local nWeddingLevel = tbWelcomeInfo.nLevel

	local tbMapSetting = Wedding.tbWeddingLevelMapSetting[nWeddingLevel]
	if not tbMapSetting then
		return
	end
	local szWeddingName = tbMapSetting.szWeddingName or "-"
	local szContent = string.format("在天愿作比翼鸟，在地愿为连理枝！\n我们即将举行[FFFE0D]%s[-]婚礼，快来祝福我们吧！", szWeddingName)
	self.pPanel:Label_SetText("Txt", szContent)

	local tbResId = self.tbRes[nWeddingLevel]
	for i, v in ipairs(tbPlayer) do
		local tbPlayerInfo = tbPlayer[i] or {}
		local szName = tbPlayerInfo.szName or "-"
		self.pPanel:Label_SetText("Name" ..i, szName)
		--模型的显示
		local nX, nY, nZ, rX, rY, rZ = unpack(self.tbPos[i])
		self.tbViewModelIds[nWeddingLevel] = self.tbViewModelIds[nWeddingLevel] or {}
		local nShowId = self.tbViewModelIds[nWeddingLevel][i]
		local bCreated = self.tbViewModelIds[nWeddingLevel][i]
		if nShowId then
			NpcViewMgr.SetUiViewFeatureActive(nShowId, true)
			NpcViewMgr.SetModePos(nShowId, nX, nY, nZ)
			NpcViewMgr.ChangeAllDir(nShowId, rX, rY, rZ, false)
		else
			nShowId = NpcViewMgr.CreateUiViewFeature(nX, nY,nZ, rX, rY, rZ)
			self.tbViewModelIds[nWeddingLevel][i] = nShowId
		end
		self.tbAllResId[nShowId] = nWeddingLevel
		NpcViewMgr.SetScale(nShowId, ViewRole:GetScale(self))
		NpcViewMgr.ChangePartBody(nShowId, tbResId[i], true);
	end
end

function tbUi:LoadBodyFinish(nViewId)
	if not self.tbAllResId[nViewId] then
		return
	end
	NpcViewMgr.AddEffectRendQueToNode(nViewId, "WeddingWelcomePanel","Bg")
end

function tbUi:OnClose()
	for nId in pairs(self.tbAllResId) do
		NpcViewMgr.SetUiViewFeatureActive(nId, false)
	end
	self.nMapId = nil
end

function tbUi:OnDestroyUi()
	for nId in pairs(self.tbAllResId) do
		NpcViewMgr.DestroyUiViewFeature(nId)
	end
end

function tbUi:RegisterEvent()
    return
    {
        { UiNotify.emNOTIFY_LOAD_RES_FINISH,           self.LoadBodyFinish},
    };
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end;
	BtnEnter = function (self)
		if not self.nMapId then
			me.CenterMsg("未知婚礼")
			return
		end
		RemoteServer.OnWeddingRequest("GoWeddingFuben", self.nMapId);
	end;
}
