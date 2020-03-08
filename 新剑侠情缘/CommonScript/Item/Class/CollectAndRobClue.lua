Require("CommonScript/Item/Class/CangBaoTu.lua")

local tbItem = Item:GetClass("CollectAndRobClue");
local tbCangBaoTu = Item:GetClass("CangBaoTu");

-- 第一个是概率
tbItem.tbRandEventRateRaw = {
	{ 5576, "FnGetRandAward", 1, 3};  --获得随机数量随机碎片，后面的是随机数量范围
	{ 164, "FnOpenPosion"};  --打开毒箱
	{ 1640, "FnFindAttackNpc", 3157, 5, 5, 7};  --發現攻击npc，npcId,nNpcCount，奖励随机数量范围， NpcId 需要是没有class的
	{ 820, "FnFindAttackNpc", 3158, 1, 11, 13, "家族成员「%s」在探寻线索时战胜了强大的碎片护卫，获得了[FFFE0D]%d张分卷碎片[-]。#49"};  --發現npc，npcId,nNpcCount，奖励随机数量范围
	--对话npc，npcId, 道具id， 获得个数，价格，延迟删除时间， 对话内容, 家族频道提示   对话npc 的className 需要是CollectAndRobClueDialog
	{ 1440, "FnFindDialogNpc", 3159, 6414, 5, 58, 180, "少侠我看你非等闲之辈，是否在寻找神州大地宝卷？我这里有[FFFE0D]5张乾坤分卷碎片[-]，便宜点卖给你，就58元宝怎么样？遇到我可是你的幸运哦！", "家族成员「%s」在探寻线索时遇到了游走四方的江湖行商，幸运的买到了[FFFE0D]%d张乾坤分卷碎片[-]！" };  
	{ 360, "FnFindDialogNpc", 3160, 6414, 20, 218, 180, "少侠我这里有[FFFE0D]20张乾坤分卷碎片[-]，这可不是普通的宝贝，就218元宝不能再便宜了。", "「%s」在探寻线索时惊喜的遇见了出售[FFFE0D]大量乾坤分卷碎片[-]的江南富贾，果断买了[FFFE0D]%d张[-]！", true};  
};

tbItem.tbNpcAppearBlackMsg = {
	[3159] = "遇到了行走四方的[FFFE0D]江湖行商[-]，快问问看他这次带着什么宝贝。";
	[3160] = "竟然遇到了梗迹萍踪的[FFFE0D]江南富贾[-]，他肯定有不少好东西！";
}

tbItem.szBlackMsgOpenPosion = "头晕眼花的你感到有人偷偷打开了你的华夏残卷收纳盒，却浑身无力动弹不得。"
tbItem.szBlackMsgOpenPosion2 = "头晕眼花的你浑身无力动弹不得。" -- 身上沒有碎片時的黑條提示

tbItem.RandGetSelectItemRate = 1000; -- 随机获取乾坤残卷碎片的几率，总值是1万
tbItem.nRandGetSelectItem = 6414; -- 随机获取乾坤残卷碎片

tbItem.nActStartSendItem = 6468; --收纳盒道具id
tbItem.nDelayDelItemTime = 3600 * 24 * 7; --道具延迟活动一周后删除，中间可以玩家自行卖店

tbItem.COMBIE_COUNT = 10; --合成时需要的碎片数

tbItem.SELL_BASE = 1000; --出售时基础价SELL_BASE + 碎片数* SELL_PRICE
tbItem.SELL_PRICE = 1000;

tbItem.CLUE_SELL_PRICE  = 5000; --线索活动结束时可出售银两

tbItem.nLastCombineItemId = 6386; --最终合成的宝图道具id 大号
tbItem.nLastCombineItemId2 = 6553; --最终合成的宝图道具id 小号

--线索碎片道具id -- class CollectClueDebris
tbItem.tbAllClueDebris = {
	6495,6470,6496,6497,6498,
	6499,6500,6501,6502,6503,
	6504,6505,6506,6507,6508,
	6509,6510,6511,6512,6513,
	6514,6515,6516,6517,6518,
}
--碎片合成的残卷对应 -- class CollectClueCombie
tbItem.tbAllClueCombine = {
    6469,6471,6472,6473,6474,
	6475,6476,6477,6478,6479,
	6480,6481,6482,6483,6484,
	6485,6486,6487,6488,6489,
	6490,6491,6492,6493,6494,
}


tbItem.IntKeyDebrisCount = 1; --碎片数key 

function tbItem:GetAct()
	local tbAct = MODULE_GAMESERVER and Activity:GetClass("CollectAndRobClue") or Activity.CollectAndRobClue
	return tbAct
end

function tbItem:GetTip(it)
	if not it.dwId then
		return "";
	end

	local nMapTemplateId,nPosX,nPosY = 0,0,0

	if it.GetIntValue(tbCangBaoTu.PARAM_MAPID) == 0 then
		nMapTemplateId,nPosX,nPosY = tbCangBaoTu:RandomPosFromType(it, me, tbCangBaoTu.TYPE_NORMAL)
		local tbMsg = 
		{
			nItemType = tbCangBaoTu.TYPE_NORMAL,
			nMapTemplateId = nMapTemplateId,
			nPosX = nPosX,
			nPosY = nPosY,
		}
		RemoteServer.NotifyItem(it.dwId,tbMsg)
	else
		nMapTemplateId,nPosX,nPosY = tbCangBaoTu:GetCangBaoTuPos(it)
	end

	if not nMapTemplateId then
		Log("CangBaoTu GetTip nMapTemplateId is null!!",nMapTemplateId)
		return "";
	end
	local tbMapSetting = Map:GetMapSetting(nMapTemplateId);
	if not tbMapSetting then
		Log("CangBaoTu GetTip tbMapSetting is null!!",tbMapSetting)
		return "";
	end

	local szTip = string.format("线索点：%s(%s, %s)\n", tbMapSetting.MapName, math.floor(nPosX * Map.nShowPosScale), math.floor(nPosY * Map.nShowPosScale));
	return szTip
end


function tbItem:OnNotifyItem(pPlayer,it,tbMsg)
	tbCangBaoTu:OnNotifyItem(pPlayer,it,tbMsg)
end


function tbItem:CheckCanWaBao(pPlayer, nItemId)
	local pItem = KItem.GetItemObj(nItemId);
	if not pItem or pItem.szClass ~= "CollectAndRobClue" then
		return false, "咦，线索呢！";
	end

	local nMapTemplateId, nPosX, nPosY = tbCangBaoTu:GetCangBaoTuPos(pItem);
	local nMpaId, nX, nY = pPlayer.GetWorldPos();
	if pPlayer.nMapTemplateId ~= nMapTemplateId or math.abs(nPosX - nX) > 100 or math.abs(nPosY - nY) > 100 then
		return false, "此处没有宝藏，换个地方试试吧！";
	end

	return true, szMsg, pItem;
end


function tbItem:OnUse(it)
	if not it.dwTemplateId then
		return 
	end

	if not Activity:__IsActInProcessByType("CollectAndRobClue") then
		me.CenterMsg("当前没有相关活动")
		return
	end
	local tbItems = me.FindItemInBag(self.nActStartSendItem) 
	if #tbItems ~= 1 then
		me.CenterMsg("当前无法使用，请少侠优先领取神州分卷收纳盒")
		return
	end
	
	local bRet, szMsg = me.CheckNeedArrangeBag();
	if bRet then
		me.CenterMsg(szMsg);
		return
	end

	local nMapTemplateId, nPosX, nPosY = tbCangBaoTu:GetCangBaoTuPos(it);
	if not tbCangBaoTu:Islegal(tbCangBaoTu.TYPE_NORMAL, nMapTemplateId, nPosX, nPosY,me) then
		tbCangBaoTu:RandomPosFromType(it, me, tbCangBaoTu.TYPE_NORMAL);
		nMapTemplateId, nPosX, nPosY = tbCangBaoTu:GetCangBaoTuPos(it);
	end
	
	local bRet, szMsg = self:CheckCanWaBao(me, it.dwId);

	if not bRet then
		it.SetIntValue(tbCangBaoTu.PARAM_MAPID, nMapTemplateId);
		it.SetIntValue(tbCangBaoTu.PARAM_POSX, nPosX);
		it.SetIntValue(tbCangBaoTu.PARAM_POSY, nPosY);
		me.CallClientScript("CangBaoTu:OnUseItem", it.dwId, nMapTemplateId, nPosX, nPosY, "线索点");
		return;
	end

	tbCangBaoTu:UpdateHeadState(me, true, tbCangBaoTu.tbSetting[tbCangBaoTu.TYPE_NORMAL].nWaBaoTime);
	GeneralProcess:StartProcessExt(me, tbCangBaoTu.tbSetting[tbCangBaoTu.TYPE_NORMAL].nWaBaoTime * Env.GAME_FPS, true, 0, 0, "正在探寻线索", {self.OnEndProgress, self, it.dwId}, {self.OnBreakProgress, self, it.dwId});
	return 0;
end

tbItem.tbRandEventRate = nil;
function tbItem:GetRandEventRateTB()
	if self.tbRandEventRate then
		return self.tbRandEventRate
	end

	local nTotalRate = 0;
	local tbRandEventRate = {}
	for i,v in ipairs(self.tbRandEventRateRaw) do
		nTotalRate = nTotalRate + v[1]
		v[1] = nTotalRate;
		table.insert(tbRandEventRate, v)
	end
	self.tbRandEventRate = tbRandEventRate
	return tbRandEventRate
end

function tbItem:OnEndProgress(nItemId)
	tbCangBaoTu:UpdateHeadState(me, false);
	local bRet, szMsg, pItem = self:CheckCanWaBao(me, nItemId);
	if not bRet then
		me.CenterMsg(szMsg);
		return;
	end

	local nConsumeCount = me.ConsumeItem(pItem, 1, Env.LogWay_CangBaoTuWaBao); -- 这里逻辑上比较危险，防止刷，所以不管成功失败，都扣除藏宝图，有问题了再补
	if nConsumeCount ~= 1 then
		Log("tbItem:OnEndProgress ConsumeItem fail",nItemId,ndwTemplateId,nConsumeCount);
		return
	end
	
	local szEventType = self:ExecuteRandEvent(me)
	tbCangBaoTu:RecordPlayerInfo(me,tbCangBaoTu.TYPE_NORMAL);
	tbCangBaoTu:RandomPosFromType(pItem, me, tbCangBaoTu.TYPE_NORMAL);
	me.CallClientScript("Ui:OpenQuickUseItem", nItemId, "使  用");
	if szEventType == "FnGetRandAward" then
		me.CallClientScript("CangBaoTu:UseItem", nItemId);
	end
end

function tbItem:ExecuteRandEvent(pPlayer)
	local tbRandEventRate = self:GetRandEventRateTB()
	local nTotalRate = tbRandEventRate[#tbRandEventRate][1];
	local nRand = MathRandom(nTotalRate)
	for i,v in ipairs(tbRandEventRate) do
		if nRand <= v[1] then
			self[v[2]](self, pPlayer, unpack(v, 3) )
			return v[2]
		end
	end
end

function tbItem:OnBreakProgress(nItemId)
	me.CallClientScript("Ui:OpenQuickUseItem", nItemId, "使  用");
	tbCangBaoTu:UpdateHeadState(me, false);
end


function tbItem:GetRandAward(nRandMin, nRandMax)
	local nRandCount = MathRandom(nRandMin, nRandMax)
	local tbKey = {};
	for i=1,nRandCount do
		local nRadnIndex = MathRandom(#self.tbAllClueDebris)
		tbKey[nRadnIndex] = (tbKey[nRadnIndex] or 0) + 1
	end
	local tbAward = {}
	for k,v in pairs(tbKey) do
		local nItemId = self.tbAllClueDebris[k]
		table.insert(tbAward, {"CollectClue", nItemId, v})
	end
	return tbAward, nRandCount
end

function tbItem:FnGetRandAward(pPlayer, nRandMin, nRandMax)
	local tbAct = self:GetAct()
	local tbAward = self:GetRandAward(nRandMin, nRandMax)
	pPlayer.SendAward( tbAward, true, nil, tbAct.LogWayType_OpenBox)

	Activity:OnPlayerEvent(pPlayer, "Act_OnGetClueRandAward")
end

function tbItem:FnOpenPosion( pPlayer )
	local tbAct = self:GetAct()
	local tbCurInfo = tbAct:GetPlayerCurCounInfo(pPlayer)
	local tbHasItemId = {}
	if tbCurInfo then
		for k,v in pairs(tbCurInfo) do
			table.insert(tbHasItemId, k)
		end
	end

	ActionMode:DoForceNoneActMode(pPlayer)
	pPlayer.GetNpc().DoCommonAct(20, 0)
	if #tbHasItemId == 0 then
		Dialog:SendBlackBoardMsg(pPlayer, self.szBlackMsgOpenPosion2)
		return
	end
	local nRandItemId = tbHasItemId[MathRandom(#tbHasItemId)] 
	Dialog:SendBlackBoardMsg(pPlayer, self.szBlackMsgOpenPosion)

	Activity:OnPlayerEvent(pPlayer,"Act_ModifyClueCount", nRandItemId, -1, tbAct.LogWayType_OpenPosin)
end


function tbItem:FnFindAttackNpc(pPlayer, nNpcTemplateId, nNpcCount, nRandMin, nRandMax, szKinMsg)
	local nMapID,nPox,nPoy = pPlayer.GetWorldPos();
	local tbAct = self:GetAct()
	local dwRoleId = pPlayer.dwID
	local nLeftCount = nNpcCount
	local fnCallBackOnNpcDeath = function ()
		nLeftCount = nLeftCount - 1
		if nLeftCount > 0 then
			return
		end
		local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
		if not pPlayer then
			return
		end

		local tbAward, nRandCount = self:GetRandAward(nRandMin, nRandMax)
		pPlayer.SendAward( tbAward, true, nil, tbAct.LogWayType_AttackNpc, nNpcTemplateId)
		Activity:OnPlayerEvent(pPlayer, "Act_OnGetClueRandAward")
		if szKinMsg and pPlayer.dwKinId ~= 0 then
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format(szKinMsg, pPlayer.szName, nRandCount), pPlayer.dwKinId)
		end
	end

	for i=1,nNpcCount do
		local tbOffsetPos = tbCangBaoTu.tbDBZOffsetPos[i] or {0,0};
		local pNpc = KNpc.Add(nNpcTemplateId, pPlayer.nLevel, 1, nMapID, nPox + tbOffsetPos[1], nPoy + tbOffsetPos[2], 0);
		if pNpc then
			Npc:RegNpcOnDeath(pNpc, fnCallBackOnNpcDeath)
		end
	end
end

function tbItem:FnFindDialogNpc(pPlayer, nNpcTemplateId, nGetItemId, nGetCount, nSellPrice, nReviveTime, szDialogMsg, szKinMsg, bSysNotify)
	local nMapID,nPox,nPoy = pPlayer.GetWorldPos();
	local pNpc = KNpc.Add(nNpcTemplateId, 1, 1, nMapID, nPox, nPoy, 0);
	if not pNpc then
		return
	end

	pNpc.nAcceptRoleId = pPlayer.dwID
	pNpc.nGetCount = nGetCount
	pNpc.nGetItemId = nGetItemId
	pNpc.nSellPrice = nSellPrice
	pNpc.szDialogMsg = szDialogMsg
	pNpc.szKinMsg = szKinMsg
	pNpc.bSysNotify = bSysNotify
	local szBlackMsg = self.tbNpcAppearBlackMsg[nNpcTemplateId]
	if szBlackMsg then
		Dialog:SendBlackBoardMsg(pPlayer, szBlackMsg)
	end
	
	local nNpcId = pNpc.nId
	Timer:Register(Env.GAME_FPS * nReviveTime, function ()
		local pNpc = KNpc.GetById(nNpcId)
		if not pNpc then
			return
		end
		local nAcceptRoleId = pNpc.nAcceptRoleId
		pNpc.Delete()
		Log("DeleteFnFindDialogNpc", nAcceptRoleId, pNpc.nTemplateId)
	end)

end

function tbItem:GetDerbisCombieTarId(nDerbisId)
	if not self.tbAllClueDebrisRevert then
		self.tbAllClueDebrisRevert = {};
		for i,v in ipairs(self.tbAllClueDebris) do
			self.tbAllClueDebrisRevert[v] = i;
		end
	end
	local nIndex = self.tbAllClueDebrisRevert[nDerbisId]
	if not nIndex then
		return 
	end
	return self.tbAllClueCombine[nIndex]
end

function tbItem:CanCombieDebris(tbItems)
	if not tbItems then
		return
	end
	for i,v in ipairs(self.tbAllClueCombine) do
		if not tbItems[v] or tbItems[v] == 0 then
			return
		end
	end	
	return true
end


function tbItem:GetUseSetting(nTemplateId, nItemId)
	if not Activity:__IsActInProcessByType("CollectAndRobClue") then
		if Shop:CanSellWare(me, nItemId, 1) then
			local tbUserSet = {};	
			tbUserSet.szFirstName = "出售"
			tbUserSet.fnFirst = "SellItem"
			return tbUserSet
		end
	end
end