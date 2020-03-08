Require("CommonScript/Npc/NpcDefine.lua");

if (not Npc.tbClassBase) then	-- 防止文件重载时破坏已有数据
	-- Npc基础模板，详细的在default.lua中定义
	Npc.tbClassBase	= {};
end;

if not Npc.tbClass then
	-- Npc模板库
	Npc.tbClass	= {
		-- 默认模板，可以提供直接使用
		default	= Npc.tbClassBase,
		[""]	= Npc.tbClassBase,
	};
end

function Npc:Init()
	Npc:LoadNpcFace();
	Npc:LoadNpcTalks();
	Npc:LoadModelPos();
	self:LoadPlayerLevelAddExpP();
	self:LoadNpcAction();
end

function Npc:LoadNpcAction()
    self.tbAllNpcActionInfo = {};
    local tbFileData = Lib:LoadTabFile("Setting/Npc/Action/ActionName.tab", {ActId = 1});
    for _, tbInfo in pairs(tbFileData) do
    	self.tbAllNpcActionInfo[tbInfo.ActId] = tbInfo;
    end
end

function Npc:GetNpcActionInfo(nActId)
    return self.tbAllNpcActionInfo[nActId];
end

function Npc:LoadPlayerLevelAddExpP()
    self.tbPlayerLevelAddExpP = {};

    local tbFileData = Lib:LoadTabFile("Setting/Player/PlayerLevelAddExpP.tab", {});
    for _, tbInfo in pairs(tbFileData) do
    	local szTimeFrame = tbInfo["TimeFrame"];

    	if not Lib:IsEmptyStr(szTimeFrame) then
	    	self.tbPlayerLevelAddExpP[szTimeFrame] = {};
	    	local tbLevelData = self.tbPlayerLevelAddExpP[szTimeFrame];
	    	for nNpcLevel = 1, Npc.MAX_NPC_LEVEL do
	    		local szPercent = tbInfo[tostring(nNpcLevel)]
	    		if not Lib:IsEmptyStr(szPercent) then
	    			tbLevelData[nNpcLevel] = tonumber(szPercent);
	    		end
	    	end
	    end
    end
end

function Npc:UpdateLevelAddExpP()
    local tbInfo = self:GetPlayerLevelAddExpP();
    if not tbInfo then
    	return;
    end

    KPlayer.ResetPlayerLevelAddExpP();
    for nLevel, nAddExpP in pairs(tbInfo) do
    	KPlayer.SetPlayerLevelAddExpP(nLevel, nAddExpP);
    end
end

function Npc:GetPlayerLevelAddExpP()
    local szCurTimeFrame = Lib:GetMaxTimeFrame(self.tbPlayerLevelAddExpP);
    if not szCurTimeFrame then
    	return;
    end

    return self.tbPlayerLevelAddExpP[szCurTimeFrame];
end

function Npc:LoadModelPos()
	local tbModelPos = LoadTabFile("Setting/Task/TaskDialogModelPos.tab", "dssssss", "nNpcResId", {"nNpcResId", "x", "y", "z", "dx", "dy", "dz"});
	self.tbTaskDialogModelPos = {};
	self.tbTaskDialogModelPos[0] = {0, 0, -550};

	self.tbDialogModelPos = {};
	self.tbDialogModelPos[0] = {0, 0, -800};
	for nNpcResId, tbInfo in pairs(tbModelPos) do
		self.tbTaskDialogModelPos[nNpcResId] = {};
		table.insert(self.tbTaskDialogModelPos[nNpcResId], tonumber(tbInfo.x) or 0);
		table.insert(self.tbTaskDialogModelPos[nNpcResId], tonumber(tbInfo.y) or 0);
		table.insert(self.tbTaskDialogModelPos[nNpcResId], tonumber(tbInfo.z) or 0);

		self.tbDialogModelPos[nNpcResId] = {};
		table.insert(self.tbDialogModelPos[nNpcResId], tonumber(tbInfo.dx) or 0);
		table.insert(self.tbDialogModelPos[nNpcResId], tonumber(tbInfo.dy) or 0);
		table.insert(self.tbDialogModelPos[nNpcResId], tonumber(tbInfo.dz) or 0);
	end
end

function Npc:LoadNpcTalks()
	local tbFile = LoadTabFile("Setting/Npc/NpcTalk.tab", "sdssdddddddsd", nil, {"Index", "TemplateID", "Name", "Content", "MapID", "IntervalMin", "IntervalMax", "Duration", "Distance", "ActID", "Action", "Desc", "nSoundId"})
	self.tbTalks = {}
	for _, tbRow in pairs(tbFile) do
		self.tbTalks[tbRow.TemplateID] = self.tbTalks[tbRow.TemplateID] or {}
		self.tbTalks[tbRow.TemplateID][tbRow.MapID] = self.tbTalks[tbRow.TemplateID][tbRow.MapID] or {}
		table.insert(self.tbTalks[tbRow.TemplateID][tbRow.MapID], tbRow)
	end
end

function Npc:GetRandomTalk(nNpcTemplateId, nMapTemplateId)
	while true do
		local tbNpcTalks = self.tbTalks[nNpcTemplateId]
		if not tbNpcTalks then break end

		local tbMapTalks = tbNpcTalks[nMapTemplateId]
		if not tbMapTalks or #tbMapTalks<=0 then break end

		local tbRand = tbMapTalks[MathRandom(#tbMapTalks)]
		return tbRand.Content, tbRand.nSoundId
	end

	return
end

function Npc:GetRandomSound(nNpcTemplateId, nMapTemplateId)
	local tbSounds = {}
	while true do
		local tbNpcTalks = self.tbTalks[nNpcTemplateId]
		if not tbNpcTalks then break end

		local tbMapTalks = tbNpcTalks[nMapTemplateId]
		if not tbMapTalks or #tbMapTalks<=0 then break end

		for _,v in ipairs(tbMapTalks) do
			if v.nSoundId and v.nSoundId>0 then
				table.insert(tbSounds, v.nSoundId)
			end
		end

		break
	end
	return tbSounds[MathRandom(#tbSounds)]
end

function Npc:LoadNpcFace()
	self.tbNpcFace = LoadTabFile("Setting/Npc/NpcFace.tab", "dss", "FaceId", {"FaceId", "Atlas", "Sprite"});
	if not self.tbNpcFace then
		Log("Load Npc Face Failed!!!!")
		return;
	end
end

function Npc:GetFace(nFaceId)
	local tbFace = self.tbNpcFace[nFaceId] or self.tbNpcFace[999];
	if not tbFace then
		return;
	end

	return tbFace.Atlas, tbFace.Sprite;
end

function Npc:GetFaceResourceByNpcTemplateId(nNpcTemplateId)
	local nFaceId = KNpc.GetNpcShowInfo(nNpcTemplateId);
	return Npc:GetFace(nFaceId);
end

-- 取得特定类名的Npc模板
function Npc:GetClass(szClassName, bNotCreate)
	local tbClass	= self.tbClass[szClassName];
	-- 如果没有bNotCreate，当找不到指定模板时会自动建立新模板
	if (not tbClass and bNotCreate ~= 1) then
		-- 新模板从基础模板派生
		tbClass	= Lib:NewClass(self.tbClassBase);
		-- 加入到模板库里面
		self.tbClass[szClassName]	= tbClass;
	end
	return tbClass;
end

function Npc:OnCreate(szClassName, szParam, pNpc)
	local tbClass	= self.tbClass[szClassName];
	if (tbClass) then
		GameSetting:SetGlobalObj(me, pNpc, it);
		Lib:CallBack({tbClass.OnCreate, tbClass, szParam});
		GameSetting:RestoreGlobalObj();
	end
end

-- 任何Npc对话，系统都会调用这里
Npc.tbDialogTitle = {
	["CommerceTask"] = "我要进行商会任务",
	["SwornFriendsNpc1"] = "结拜",
	["SwornFriendsNpc2"] = "结拜",
}
function Npc:OnDialog(szClassName, szParam)
	if not MODULE_GAMESERVER then
		self:NotifyOnDialog()
		return self:ShowDefaultDialog(szClassName, szParam);
	end

	me.CallClientScript("Npc:NotifyOnDialog")
	local bTaskFlag = false;
	local szDefaultText = Lib:IsEmptyStr(him.szDefaultDialogInfo) and "你找我什么事？" or him.szDefaultDialogInfo
	local tbDialogInfo = {Text = szDefaultText, NpcTemplateId = him.nTemplateId, OptList = {}};
	if Task.GetDialogInfo then
		local tbTaskDialog = Task:GetDialogInfo(me, him);
		if tbTaskDialog and #tbTaskDialog > 0 then
			Lib:MergeTable(tbDialogInfo.OptList, tbTaskDialog);
			bTaskFlag = true;
		end
	end

	if ActivityQuestion:IsCurQuestionNpc(me.nMapTemplateId, him.nTemplateId) then
		if bTaskFlag then
			table.insert(tbDialogInfo.OptList, {Text = "答题", Type = "Script", Callback = ActivityQuestion.BeginAnswer, Param = {ActivityQuestion, me.nMapTemplateId, him.nTemplateId}})
		else
			ActivityQuestion:BeginAnswer(me.nMapTemplateId, him.nTemplateId)
			return
		end
	end

	local tbDirectOptList = Npc:GetDirectOptList(szClassName)
	Lib:MergeTable(tbDialogInfo.OptList, tbDirectOptList)
	Activity:OnNpcDialog(him.nTemplateId, szClassName, tbDialogInfo.OptList)

	if next(tbDialogInfo.OptList) then
		local szText = self.tbDialogTitle[him.szClass] or "我要做其它事情"
		tbDialogInfo.OptList[#tbDialogInfo.OptList + 1] = {Text = szText, Type = "Script", Callback = self.ShowDefaultDialog, Param = {self, szClassName, szParam}};
		Dialog:Show(tbDialogInfo, me, him);
	else
		self:ShowDefaultDialog(szClassName, szParam);
	end
end

function Npc:GetDirectOptList(szClassName)
	if Lib:IsEmptyStr(szClassName) or not self.tbClass[szClassName] or not self.tbClass[szClassName].GetDirectOptList then
		return {}
	end
	return self.tbClass[szClassName]:GetDirectOptList() or {}
end

function Npc:OnGeneralDialog(szClassName, szParam)
	if Lib:IsEmptyStr(szClassName) or not self.tbClass[szClassName] or not self.tbClass[szClassName].OnGeneralDialog then
		return
	end
	self.tbClass[szClassName]:OnGeneralDialog(szParam)
end

function Npc:ShowDefaultDialog(szClassName, szParam)
	if  Lib:IsEmptyStr(szClassName) or not self.tbClass[szClassName] then
		local szText, nSoundId = Npc:GetRandomTalk(him.nTemplateId, me.nMapTemplateId)
		if not szText then
			szText = Lib:IsEmptyStr(him.szDefaultDialogInfo) and "你找我什么事？" or him.szDefaultDialogInfo;
		end
		local tbDialogInfo = {Text=szText, NpcTemplateId=him.nTemplateId, SoundId=nSoundId, OptList={}};
		Dialog:Show(tbDialogInfo, me, him);
		return;
	end

	self.tbClass[szClassName]:OnDialog(szParam);
end

-- 注册特定Npc死亡回调
function Npc:RegNpcOnDeath(pNpc, fnCallback, ...)
	if pNpc.tbOnDeath then
		Log("too many OnDeath registrer on npc:"..pNpc.szName);
		return;
	end
	pNpc.tbOnDeath	= {fnCallback, ...};
end;

-- 取消特定Npc死亡回调
function Npc:UnRegNpcOnDeath(pNpc)
	pNpc.tbOnDeath	= nil;
end;

function Npc:OnFindEnemy(pNpc, pTarget)
	if not pNpc.fnOnFindEnemy then
		return;
	end

	Lib:CallBack({pNpc.fnOnFindEnemy, pNpc, pTarget});
end

Npc.AI_EVENT_ATTACK_ENTER = 0
Npc.AI_EVENT_ATTACK_DEATH = 1
Npc.AI_EVENT_ATTACK_BY_PLAYER = 2
function Npc:OnAiNotify(pNpc, nEvent, nParam1, nParam2)
	if not pNpc.fnOnAiNotify then
		return;
	end

	Lib:CallBack({pNpc.fnOnAiNotify, pNpc, nEvent, nParam1, nParam2});
end

function Npc:OnDeath(szClassName, szParam, pKiller)
	if Npc.CalcNpcDeath then
		local bOk, pMainNpc = Lib:CallBack({Npc.CalcNpcDeath, Npc, him, pKiller});
		if bOk and pMainNpc then
			pKiller = pMainNpc;
		end
	end

	local tbOnDeath	= him.tbOnDeath;
	if (tbOnDeath) then
		local tbCall	= {unpack(tbOnDeath)};
		local tbArg = {pKiller}
		Lib:MergeTable(tbCall, tbArg);
		local bOk, nRet	= Lib:CallBack(tbCall);	-- 调用回调
		if (not bOk or nRet ~= 1) then
			him.tbOnDeath	= nil;
		end
	end
	local tbClass = self.tbClass[szClassName];
	if tbClass then
		tbClass:OnDeath(pKiller, szParam);
	end
	if Task.OnNpcDeath then
		Lib:CallBack({Task.OnNpcDeath, Task, him, pKiller});
	end
end

function Npc:OnEarlyDeath(szClassName, szParam, ...)
	local tbClass = self.tbClass[szClassName];
	if tbClass then
		tbClass:OnEarlyDeath(...);
	end
end

local tbAiEvent =
{
	NpcShowDialog = function (pNpc, szParam)
		if MODULE_GAMESERVER then
			return;
		end
		pNpc.BubbleTalk(szParam, "5");
	end,
	BlackMsg = function (pNpc, szParam)
		if MODULE_GAMESERVER then
			local tbPlayer = KNpc.GetAroundPlayerList(pNpc.nId, 2000);
			for _, pPlayer in ipairs(tbPlayer) do
				pPlayer.SendBlackBoardMsg(szParam);
			end
			return;
		else
			me.SendBlackBoardMsg(szParam)
		end
	end,
	DropBuffer = function (pNpc, szParam)
		local nMapId, nX, nY = pNpc.GetWorldPos();
		Item.Obj:DropBuffer(nMapId, nX, nY, szParam);
	end,
	FleeRate = function (pNpc, szParam)
		pNpc.AI_SetFleeByNear(tonumber(szParam))
	end
}

function Npc:OnAiEvent(szClassName, szEvent, szParam)
	if tbAiEvent[szEvent] then
		tbAiEvent[szEvent](him, szParam);
	end
end

function Npc:OnAIPathArrive(pNpc)
	local tbOnArrive = pNpc.tbOnArrive;
	GameSetting:SetGlobalObj(me, pNpc, it)
	if (tbOnArrive) then
		Lib:CallBack(tbOnArrive);
	end
	GameSetting:RestoreGlobalObj()
end

function Npc:RegisterNpcHpPercent(pNpc, nPercent, fnCallBack)
	pNpc.tbHpChangeEvent = pNpc.tbHpChangeEvent or {};
	local tbHpChangeEvent = pNpc.tbHpChangeEvent;
	local nId = tbHpChangeEvent.nCurId or 1;

	tbHpChangeEvent.nCurId = nId + 1;
	tbHpChangeEvent.tbPercentEvent = tbHpChangeEvent.tbPercentEvent or {};

	local nIdx = 1;
	for i, tbInfo in ipairs(tbHpChangeEvent.tbPercentEvent) do
		if nPercent > tbInfo.nPercent then
			break;
		end

		nIdx = i + 1;
	end

	table.insert(tbHpChangeEvent.tbPercentEvent, nIdx, {fnCallBack = fnCallBack, nId = nId, nPercent = nPercent});
	pNpc.SetNotifyHpInfo(1);
	return nId;
end

function Npc:RegisterNpcHpChange(pNpc, fnCallBack)
	pNpc.tbHpChangeEvent = pNpc.tbHpChangeEvent or {};

	local tbHpChangeEvent = pNpc.tbHpChangeEvent;
	local nId = tbHpChangeEvent.nCurId or 1;
	tbHpChangeEvent.nCurId = nId + 1;
	tbHpChangeEvent.tbEvent = tbHpChangeEvent.tbEvent or {};

	pNpc.SetNotifyHpInfo(1);
	table.insert(tbHpChangeEvent.tbEvent, {fnCallBack = fnCallBack, nId = nId});
	return nId;
end

function Npc:UnRegisterNpcHpEvent(nNpcId, nId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end

	local tbEvent = (pNpc.tbHpChangeEvent or {}).tbEvent or {};
	local tbPercentEvent = (pNpc.tbHpChangeEvent or {}).tbPercentEvent or {};

	for nIdx, tbInfo in pairs(tbEvent) do
		if tbInfo.nId == nId then
			table.remove(tbEvent, nIdx);
			break;
		end
	end

	for nIdx, tbInfo in pairs(tbPercentEvent) do
		if tbInfo.nId == nId then
			table.remove(tbPercentEvent, nIdx);
			break;
		end
	end

	if #tbEvent == 0 and #tbPercentEvent == 0 then
		pNpc.SetNotifyHpInfo(0);
	end
end

function Npc:OnNpcHpChange(pNpc, nOldHp, nNewHp, nMaxHp)
	local tbEvent = (pNpc.tbHpChangeEvent or {}).tbEvent or {};
	local tbPercentEvent = Lib:CopyTB((pNpc.tbHpChangeEvent or {}).tbPercentEvent or {});

	GameSetting:SetGlobalObj(me, pNpc, it);
	local nCurPercent = 100 * nNewHp / nMaxHp;
	local tbnIdxToRemove = {};
	for nIdx, tbInfo in ipairs(tbPercentEvent or {}) do
		if tbInfo.nPercent < nCurPercent then
			break;
		end

		Lib:CallBack({tbInfo.fnCallBack, tbInfo.nPercent, nCurPercent});
		table.insert(tbnIdxToRemove, 1, nIdx);
	end

	tbPercentEvent = (pNpc.tbHpChangeEvent or {}).tbPercentEvent or {};
	for _, nIdx in ipairs(tbnIdxToRemove) do
		table.remove(tbPercentEvent, nIdx);
	end

	for _, tbInfo in pairs(tbEvent) do
		Lib:CallBack({tbInfo.fnCallBack, nOldHp, nNewHp, nMaxHp});
	end
	GameSetting:RestoreGlobalObj();
end

function Npc:RegisterHideEvent(fnCallBack, ...)
	local tbParam = {...};
	local tbCallBack = function (nNpcId, dwPlayerID, dwKinId)
		fnCallBack(nNpcId, dwPlayerID, dwKinId, unpack(tbParam));
	end
	Npc.tbHideEvent = tbCallBack;
end

function Npc:UnRegisterHideEvent()
	Npc.tbHideEvent = nil;
end

function Npc:OnNpcLoadFinish()
	if not him then
		return;
	end

	local tbNpcClass = Npc:GetClass(him.szClass or "");
	if tbNpcClass and tbNpcClass.OnNpcLoadFinish then
		tbNpcClass:OnNpcLoadFinish(him);
	end

	for _, tbCallBack in ipairs(him.__tbCacheCmd or {}) do
		Lib:CallBack(tbCallBack);
	end

	him.nLoadFinishTime = os.clock();

	if self.NpcShow and self.NpcShow.ShowNpcBooldUI then
		self.NpcShow:ShowNpcBooldUI(him);
	end

	if self.tbHideEvent then
		Lib:CallBack({self.tbHideEvent, him.nId, him.dwPlayerID, him.dwKinId})
	end
end

function Npc:DoCmdWhenNpcLoadFinish(nNpcId, fnFunc, ...)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end

	local tbParam = {...};
	if type(fnFunc) == "string" then
		if string.find(fnFunc, ":") then
			local szTable, szfnFunc = string.match(fnFunc, "^(.*):(.*)$");
			local tb = loadstring("return " .. szTable)();
			assert(tb[szfnFunc]);
			fnFunc = tb[szfnFunc]
			tbParam = {tb, ...};
		else
			fnFunc = loadstring("return " .. fnFunc)();
			assert(fnFunc);
		end
	end

	local tbCallBack = {function ()
		fnFunc(unpack(tbParam));
	end}

	if pNpc.nLoadFinish == 1 then
		Lib:CallBack(tbCallBack)
		return;
	end

	pNpc.__tbCacheCmd = pNpc.__tbCacheCmd or {};
	table.insert(pNpc.__tbCacheCmd, tbCallBack);
end

function Npc:ACTION_TYPE_ID(nType, nAct)
	return math.floor(nType * 100000 + nAct);
end

function Npc:ACTION_TYPE_TYPE(nActID)
	return math.floor(nActID / 100000);
end

function Npc:ACTION_TYPE_ACT(nActID)
	return math.floor(nActID % 100000);
end

Npc:Init();

