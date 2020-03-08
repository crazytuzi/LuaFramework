Npc.NpcShow = Npc.NpcShow or {};
local NpcShow = Npc.NpcShow;

function NpcShow:LoadData()
	local tbShowData = LoadTabFile("Setting/Npc/NpcShowInfo.tab", "dsssssdd", "nTemplateId", {"nTemplateId", "szAction", "nDist", "szInfo", "nRX", "nHeightPercent", "nMoveTime", "nStayTime"});

	assert(tbShowData[0], "NpcShow default info is nil !!");

	self.tbShowData = {};
	self.tbShowData[0] = {};
	local tbDefault = self.tbShowData[0];
	tbDefault.szInfo = "";
	tbDefault.nDist = tonumber(tbShowData[0].nDist) or -20;
	tbDefault.szAction = tbShowData[0].szAction == "" and "st" or tbShowData[0].szAction;
	tbDefault.nRX = tonumber(tbShowData[0].nRX) or 0.1;
	tbDefault.nHeightPercent = tonumber(tbShowData[0].nHeightPercent) or 0.8;
	tbDefault.nMoveTime = tbShowData[0].nMoveTime;
	tbDefault.nStayTime = tbShowData[0].nStayTime;

	tbShowData[0] = nil;
	for nNpcTemplateId, tbInfo in pairs(tbShowData) do
		self.tbShowData[nNpcTemplateId] = {};
		self.tbShowData[nNpcTemplateId].szAction = tbInfo.szAction == "" and tbDefault.szAction or tbInfo.szAction;
		self.tbShowData[nNpcTemplateId].szInfo = tbInfo.szInfo;
		self.tbShowData[nNpcTemplateId].nDist = tonumber(tbInfo.nDist) or tbDefault.nDist;
		self.tbShowData[nNpcTemplateId].nRX = tonumber(tbInfo.nRX) or tbDefault.nRX;
		self.tbShowData[nNpcTemplateId].nHeightPercent = tonumber(tbInfo.nHeightPercent) or tbDefault.nHeightPercent;
		self.tbShowData[nNpcTemplateId].nMoveTime = tbInfo.nMoveTime == 0 and tbDefault.nMoveTime or tbInfo.nMoveTime;
		self.tbShowData[nNpcTemplateId].nStayTime = tbInfo.nStayTime == 0 and tbDefault.nStayTime or tbInfo.nStayTime;
	end

	self.tbShowBooldNpcSetting = {};
	local tbFileData = Lib:LoadTabFile("Setting/Npc/Npc_ShowBlood.tab", {NpcTID = 1});
	for _, tbInfo in pairs(tbFileData) do
		self.tbShowBooldNpcSetting[tbInfo.NpcTID] = 1;
	end		
end
NpcShow:LoadData();

function NpcShow:GetShowName(szName)
	local szFirstName = Lib:CutUtf8(szName, 1);
	local szSecondName = string.gsub(szName, "^" .. szFirstName, "");
	return szFirstName, szSecondName;
end

function NpcShow:LookToNpc(nNpcId, fnCallback, bConfirm)
	local bAdjustState = Operation:CheckAdjustView()
	if bAdjustState then
		Operation:QuiteAssistUiState()
		UiNotify.OnNotify(UiNotify.emNOTIFY_LOCK_TO_NPC)
	end
	if not bConfirm and bAdjustState then
		Timer:Register(10, function ()
			NpcShow:LookToNpc(nNpcId, fnCallback, true);
		end)
		return
	end
	if self.fnCallback then
		assert(false, "LookToNpc Repeat !!!!");
		return;
	end

	self.fnCallback = fnCallback;
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		self:OnPlayEnd(true, bConfirm);
		return;
	end

	local tbAngle = Ui.CameraMgr.GetCameraDirAngle();
	local nRY = tbAngle.y + 180;
	if nRY < 0 then
		nRY = nRY + 360 * math.floor((-nRY + 360) / 360);
	end

	local nDir = math.floor(nRY * 64 / 360) % 64;

	pNpc.SetDir(nDir);

	local tbShowInfo = self.tbShowData[pNpc.nTemplateId] or self.tbShowData[0];

	Timer:Register(tbShowInfo.nMoveTime, function (nNpcId, szAction, nStayTime, szInfo)
		local pNpc = KNpc.GetById(nNpcId);
		if not pNpc then
			NpcShow:OnPlayEnd(false, bConfirm);
			return;
		end

		local szFirstName, szSecondName = NpcShow:GetShowName(pNpc.szName);
		Ui:OpenWindow("BossReferral", szFirstName, szSecondName, szInfo, true);
		local rep = Ui.Effect.GetNpcRepresent(nNpcId);
		local nTime = rep:ForcePlayAnimation(szAction, 1, 1, 1);
		Timer:Register(nStayTime, function ()
			NpcShow:OnPlayEnd(false, bConfirm);
		end)
	end, nNpcId, tbShowInfo.szAction, tbShowInfo.nStayTime, tbShowInfo.szInfo);

	NpcShow:HideAll(nNpcId);
	local nHeight = Ui.Effect.GetNpcHeight(nNpcId) * tbShowInfo.nHeightPercent;
	local _, x, y = pNpc.GetWorldPos();
	-- 先把旋转动画停止
	Ui.CameraMgr.StopCameraCrossRoate()
	Ui.CameraMgr.MoveCameraToPositionWhithRotation(tbShowInfo.nMoveTime / Env.GAME_FPS, x, y, tbShowInfo.nDist, nHeight, tbShowInfo.nRX);
end

function NpcShow:HideAll(nNpcId)
	Ui:SetAllUiVisable(false);
	Ui.Effect.ShowAllRepresentObj(0);
	Ui.Effect.ShowNpcRepresentObj(nNpcId, true);
end

function NpcShow:ShowAll()
	Ui:SetAllUiVisable(true);
	Ui.Effect.ShowAllRepresentObj(1);
end

function NpcShow:OnLogin()
	NpcShow.fnCallback = nil;
end

function NpcShow:OnPlayEnd(bWait, bConfirm)
	if bWait then
		Timer:Register(1, function ()
			self:OnPlayEnd(false);
		end)
		return;
	end

	Ui.CameraMgr.RestoreCameraRotation();
	Ui.CameraMgr.LeaveCameraAnimationState();
	Ui:CloseWindow("BossReferral");
	self:ShowAll();

	if NpcShow.fnCallback then
		NpcShow.fnCallback();
		NpcShow.fnCallback = nil;
	end

	if bConfirm then
		UiNotify.OnNotify(UiNotify.emNOTIFY_LOCK_TO_NPC_CONFIRM)
	end
end

function NpcShow:GetShowBooldUI(nNpcTID)
	return self.tbShowBooldNpcSetting[nNpcTID];
end

function NpcShow:ShowNpcBooldUI(pNpc)
	if not pNpc then
		return;
	end

	local tbShowInfo = self:GetShowBooldUI(pNpc.nTemplateId);
	if not tbShowInfo then
		return;
	end

	if Ui:WindowVisible("BloodPanel") ~= 1 then
		Ui:OpenWindow("BloodPanel", {[pNpc.nId] = 1});
	else
		Ui("BloodPanel"):AddCampNpcID(pNpc.nId);
	end	
end

PlayerEvent:RegisterGlobal("OnLogin",                       NpcShow.OnLogin, NpcShow);