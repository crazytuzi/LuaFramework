
local tbItem = Item:GetClass("ShanHeSheJiTu");

tbItem.tbPosInfo = {
{414, 2531, 8227},
{414, 8820, 12626},
{414, 13497 ,12521},
{414, 9774, 10184},
{414, 13561 ,2410},
{414, 11390 ,1659},
{414, 8161, 2289},
{414, 6144, 2963},
{414, 4834, 2415},
{414, 2394, 2130},
{414, 2860, 3999},
{414, 4680, 9199},
{414, 2836, 13032},
};

tbItem.nAwardItemId = 3238;		-- 奖励道具
tbItem.nProcessTime = 5;		-- 读条时间

function tbItem:OnUse(it)
	if not it.tbPos then
		it.tbPos = tbItem.tbPosInfo[MathRandom(#self.tbPosInfo)];
	end

	local nMapTemplateId, nPosX, nPosY = unpack(it.tbPos);
	local nMapId, nX, nY = me.GetWorldPos();
	if nMapTemplateId ~= me.nMapTemplateId or nX ~= nPosX or nY ~= nPosY then
		me.CallClientScript("Item:GoAndUseItem", nMapTemplateId, nPosX, nPosY, it.dwId);
	else
		GeneralProcess:StartProcess(me, self.nProcessTime * Env.GAME_FPS, "正在挖掘..", self.OnEndProgress, self, it.dwId);
	end
end

function tbItem:OnEndProgress(nItemId)
	local pItem = me.GetItemInBag(nItemId);
	if not pItem then
		return;
	end

	if pItem.nCount > 1 then
		pItem.tbPos = nil;
	end

	local nItemTemplateId = pItem.dwTemplateId;
	local nConsumeCount = me.ConsumeItem(pItem, 1, Env.LogWay_ShanHeSheJiTu);
	if nConsumeCount ~= 1 then
		Log("[ShanHeSheJiTu] ConsumeItem ERR ?? ", me.dwID, me.szAccount, me.szName, nItemTemplateId, nConsumeCount);
		return;
	end

	me.SendAward({{"item", self.nAwardItemId, 1}}, nil, nil, Env.LogWay_ShanHeSheJiTu);
	Log("[ShanHeSheJiTu] Use Item", me.dwID, me.szAccount, me.szName, nItemTemplateId, self.nAwardItemId);
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
	if nItemId then
		return {szFirstName = "前往", fnFirst = "UseItem"};
	else
		return {};
	end
end