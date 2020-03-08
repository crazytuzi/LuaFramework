function Decoration:HasMe(tbRepInfo)
	local tbNpcIdInfo = (tbRepInfo.tbParam or {}).tbNpcIdInfo or {};
	local nPlayerCount = Lib:CountTB(tbNpcIdInfo);
	local bHasMe = false;
	for _, nNpcId in pairs(tbNpcIdInfo) do
		if nNpcId == me.GetNpc().nId then
			bHasMe = true;
			break;
		end
	end

	return bHasMe, nPlayerCount;
end
function Decoration:OnRepObjSimpleTap_XiangLu(nId, nRepId, tbRepInfo, tbTemplate)
	local nTypeId = 0;
	if tbRepInfo.tbParam and tbRepInfo.tbParam.nCmdType == 0 then
		nTypeId = -1;
	end

	local function fnUse()
		RemoteServer.OnClientCmd(nId, "ServerDoCmd", nTypeId);
	end

	local tbBtnInfo = {};
	if nTypeId == 0 then
		table.insert(tbBtnInfo, {"点香", fnUse});
	else
		table.insert(tbBtnInfo, {"灭香", fnUse});
	end
	Ui:OpenWindow("FurnitureOptUi", nRepId, tbBtnInfo);
end

function Decoration:OnRepObjSimpleTap_GuiZi(nId, nRepId, tbRepInfo, tbTemplate)
	local nTypeId = 0;
	if tbRepInfo.tbParam and tbRepInfo.tbParam.nCmdType == 0 then
		nTypeId = -1;
	end

	local function fnUse()
		RemoteServer.OnClientCmd(nId, "ServerDoCmd", nTypeId);
	end
	local function fnEnter()
		Decoration:EnterPlayerActState(me, nId, me.nFaction * (me.nSex == 1 and 1 or 100), 0);
		RemoteServer.OnClientCmd(nId, "ServerDoCmd", nTypeId);
	end

	local tbBtnInfo = {};

	if nTypeId == 0 then
		table.insert(tbBtnInfo, {"开柜", fnUse});
	elseif nTypeId == -1 then
		table.insert(tbBtnInfo, {"关柜", fnUse});
		table.insert(tbBtnInfo, {"躲入", fnEnter});
	end

	Ui:OpenWindow("FurnitureOptUi", nRepId, tbBtnInfo);
end

function Decoration:OnRepObjSimpleTap_QiuQian(nId, nRepId, tbRepInfo, tbTemplate)
	local bHasMe = self:HasMe(tbRepInfo);
	local function fnSit()
		Decoration:EnterPlayerActState(me, nId, me.GetNpc().nId, 0);
	end

	local function fnShake()
		RemoteServer.OnClientCmd(nId, "ServerDoCmd", 0);
	end

	local tbBtnInfo = {};
	if not bHasMe then
		table.insert(tbBtnInfo, {"坐下", fnSit});
	end

	table.insert(tbBtnInfo, {"摇摆", fnShake});
	Ui:OpenWindow("FurnitureOptUi", nRepId, tbBtnInfo);
end

local tbNormalAddResClass = Decoration:GetClass("NormalAddRes");
function Decoration:OnRepObjSimpleTap_Chuang(nId, nRepId, tbRepInfo, tbTemplate)
	local bHasMe, nPlayerCount = self:HasMe(tbRepInfo);
	local nCurrentType = (tbRepInfo.tbParam or {}).nType or -999;
	local tbAllType = {};
	local tbRandomType = {};
	for nType in pairs(tbNormalAddResClass.tbAllTypeActSetting[tbRepInfo.nTemplateId] or {}) do
		table.insert(tbAllType, nType);
		if nType ~= nCurrentType then
			table.insert(tbRandomType, nType);
		end
	end

	if bHasMe and (#tbAllType <= 1 or nPlayerCount < 2) then
		me.SendBlackBoardMsg("您已经在床上了哟~");
		return;
	end

	local function fnUse ()
		local nType = 0;
		if nPlayerCount >= 1 then
			nType = tbAllType[MathRandom(#tbAllType)];
		end
		Decoration:EnterPlayerActState(me, nId, me.nFaction * (me.nSex == 1 and 1 or 100), nType);
	end

	local function fnRandomType()
		local nType = 0;
		if nPlayerCount >= 1 then
			nType = tbRandomType[MathRandom(#tbRandomType)];
		end

		Decoration:DecorationChangeActType(me, nId, nType);
	end

	local tbBtnInfo = {{"躺下", fnUse}};

	if bHasMe and #tbAllType > 1 and nPlayerCount >= 2 then
		tbBtnInfo = {{"睡姿", fnRandomType}};
	end

	Ui:OpenWindow("FurnitureOptUi", nRepId, tbBtnInfo);
end

function Decoration:OnRepObjSimpleTap_DengZi(nId, nRepId, tbRepInfo, tbTemplate)
	local bHasMe = self:HasMe(tbRepInfo);
	if bHasMe then
		return;
	end

	local function fnSit()
		Decoration:EnterPlayerActState(me, nId, me.GetNpc().nId, 0);
	end

	Ui:OpenWindow("FurnitureOptUi", nRepId, {{"坐下", fnSit}});
end

function Decoration:OnRepObjSimpleTap_YuGang(nId, nRepId, tbRepInfo, tbTemplate)
	local bHasMe = self:HasMe(tbRepInfo);
	if bHasMe then
		return;
	end

	local function fnUse ()
		Decoration:EnterPlayerActState(me, nId, me.nFaction * (me.nSex == 1 and 1 or 100), 0);
	end

	Ui:OpenWindow("FurnitureOptUi", nRepId, {{"使用", fnUse}});
end

function Decoration:OnRepObjSimpleTap_JuBaoPen(nId, nRepId, tbRepInfo, tbTemplate)
	local bHasMe = self:HasMe(tbRepInfo);
	if bHasMe then
		return;
	end
	Ui:OpenWindow("MagicBowlPanel", nId)
end