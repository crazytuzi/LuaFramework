Compose.EntityCompose = Compose.EntityCompose or {};
local EntityCompose = Compose.EntityCompose;
local nMaxChildCount = 8;

EntityCompose.tbChildInfo = {};
EntityCompose.tbTargeInfo = {};
EntityCompose.tbShowFragTemplates = {};

-- 合成材料在背包的优先显示切页
-- 1 常用
EntityCompose.tbToggleSetting =
{
	[11767] = {1};
	[11768] = {1};
	[11769] = {1};
	[11770] = {1};
	[11771] = {1};
	[11772] = {1};
}

function EntityCompose:GetToggleSetting(nItemTID)
	return self.tbToggleSetting[nItemTID]
end

function EntityCompose:LoadSetting()

	local szTabPath = "Setting/Item/ItemCompose/EntityCompose.tab";
	local szParamType = "dddddsddds";
	local szKey = "TargetTemplateID";
	local tbParams = {"TargetTemplateID", "IsShowFrag", "NoSellAttachTarget", "IsHideItemTip", "IsHideTip", "ConsumeType","ConsumeCount", "BagSort", "KinMsg", "ValidTime",};
	for i=1,nMaxChildCount do
		szParamType = szParamType .."dd";
		table.insert(tbParams,"ChildTemplateID" ..i);
		table.insert(tbParams,"NeedCount" ..i);
	end
	local tbSettings = LoadTabFile(szTabPath, szParamType, szKey, tbParams);

	local tbPieceToId = {}
	for nTargetTemplateID,tbRowInfo in pairs(tbSettings) do
		assert(not self.tbTargeInfo[nTargetTemplateID], "EntityCompose assert fail repeat nTargetTemplateID")
		self.tbTargeInfo[nTargetTemplateID] = self.tbTargeInfo[nTargetTemplateID] or {}
		self.tbTargeInfo[nTargetTemplateID]["nBagSort"] = tbRowInfo.BagSort;
		if tbRowInfo.ConsumeType and tbRowInfo.ConsumeCount and tbRowInfo.ConsumeType ~= "" and tbRowInfo.ConsumeCount ~= 0 then
			self.tbTargeInfo[nTargetTemplateID]["szConsumeType"] = tbRowInfo.ConsumeType;
			self.tbTargeInfo[nTargetTemplateID]["nConsumeCount"] = tbRowInfo.ConsumeCount;
			self.tbTargeInfo[nTargetTemplateID]["nKinMsg"] = tbRowInfo.KinMsg;
		end
		if tbRowInfo.IsHideTip and tbRowInfo.IsHideTip == 1 then
			self.tbTargeInfo[nTargetTemplateID]["bIsHideTip"] = true
		end
		if tbRowInfo.IsHideItemTip and tbRowInfo.IsHideItemTip == 1 then
			self.tbTargeInfo[nTargetTemplateID]["bIsHideItemTip"] = true
		end
		if tbRowInfo.NoSellAttachTarget and tbRowInfo.NoSellAttachTarget == 1 then
			self.tbTargeInfo[nTargetTemplateID]["bNoSellAttachTarget"] = true
		end
		for i=1,nMaxChildCount do
			local szChildKey = "ChildTemplateID" ..i;
			if tbRowInfo[szChildKey] and tbRowInfo[szChildKey] ~=0 then
				local nChildItemId = tbRowInfo[szChildKey];
				local nCount = tbRowInfo["NeedCount" ..i];
				self.tbChildInfo[nChildItemId] = self.tbChildInfo[nChildItemId] or {}
				table.insert(self.tbChildInfo[nChildItemId], nTargetTemplateID)
				self.tbTargeInfo[nTargetTemplateID][nChildItemId] = nCount;
				if tbRowInfo.IsShowFrag == 1 then
					self.tbShowFragTemplates[nChildItemId] = 1;
				end
			end
		end
		--合成道具的有效期
		if tbRowInfo.ValidTime and tbRowInfo.ValidTime ~= "" then
			self.tbTargeInfo[nTargetTemplateID]["nValidTime"] = Lib:ParseDateTime(tbRowInfo.ValidTime)
		end
		tbPieceToId[tbRowInfo.ChildTemplateID1] = nTargetTemplateID
	end
	self.tbPieceToId = tbPieceToId
end

EntityCompose:LoadSetting();

function EntityCompose:GetAllTargetByChild(nChildItemId)
	return self.tbChildInfo[nChildItemId]
end

function EntityCompose:GetTargetIdByChild(nTemplateId)
	local tbTargetId = EntityCompose:GetAllTargetByChild(nTemplateId) or {}
	if not next(tbTargetId) then
		return
	end
	-- 如果同一个道具有多个合成目标，优先第一个
	-- 例如目前门派信物可参与合成多个道具，但是一般像门派信物这种的道具类都不用ComposeMeterial,
	-- 所以一般道具都只有一个合成目标,有多个合成目标的一般由另一个唯一的参与合成的道具决定合成哪一个
	-- 换句话说就是一般像门派信物这个不会有合成按钮
	return tbTargetId[1]
end

function EntityCompose:CheckIsComposeMaterial(nTemplateId)

	local szMsg = "找不到该合成材料";
	if not nTemplateId then
		return false,szMsg;
	end
	local tbTargetId = EntityCompose:GetAllTargetByChild(nTemplateId) or {}
	if not next(tbTargetId) then
		return false,szMsg;
	end

	for _, nTargetID in ipairs(tbTargetId) do
		if not self.tbTargeInfo[nTargetID] then
			return false,szMsg;
		end

		if not self.tbTargeInfo[nTargetID][nTemplateId] then
			return false,szMsg;
		end
	end

	return true;
end

function EntityCompose:GetIdFromPiece(nPieceId)
	return self.tbPieceToId[nPieceId]
end

--只能是一种碎片数量合成的，不然现在无法定出售(或者列NoSellAttachTarget配1也无法出售)
function EntityCompose:GetEquipComposeInfo(nTemplateId)
	local nTargetID = EntityCompose:GetTargetIdByChild(nTemplateId)
	if not nTargetID then
		return
	end
	local nNeedTotal = 0;
	local tbTargeInfo = self.tbTargeInfo[nTargetID];
	if tbTargeInfo.bNoSellAttachTarget then
		return
	end
	for nChildId,nNeed in pairs(tbTargeInfo) do
		if tonumber(nChildId) then
			if  nChildId ~= nTemplateId then
				return
			end
			nNeedTotal = nNeedTotal + nNeed
		end

	end
	return nTargetID, nNeedTotal
end

function EntityCompose:CheckIsCanCompose(pPlayer, nTemplateId)
	-- 只要有一个目标可合成则返回true
	local tbTargetId = EntityCompose:GetAllTargetByChild(nTemplateId) or {}
	local nComposeTargetId
	local bIsCan = false
	for _, nTargetID in ipairs(tbTargetId) do
		bIsCan = true
		nComposeTargetId = nTargetID
		local tbTargeInfo = self.tbTargeInfo[nTargetID];
		for nChildId,nNeed in pairs(tbTargeInfo) do
			if tonumber(nChildId) then
				local nHave = pPlayer.GetItemCountInAllPos(nChildId);
				if nHave < nNeed then
					bIsCan = false
					break;
				end
			end
		end
		if bIsCan then
			break
		end
	end
	local szTip = nComposeTargetId and string.format("您的材料不足，无法合成【%s】",Item:GetItemTemplateShowInfo(nComposeTargetId, pPlayer.nFaction, pPlayer.nSex)) or "您的材料不足，无法合成"
	return bIsCan, szTip, nComposeTargetId;
end

function EntityCompose:GetTip(it)
	local nTemplateId = it.dwTemplateId
	return self:GetMaterialList(nTemplateId)
end

function EntityCompose:GetMaterialList(nTemplateId, bColorTxt)
	if not self:CheckIsComposeMaterial(nTemplateId) then
		return ""
	end
	local nTargetID = EntityCompose:GetTargetIdByChild(nTemplateId)
	local tbTargeInfo = self.tbTargeInfo[nTargetID]
	local szTip = "";
	local szName = "";
	local nHave = 0;
    local szTxtColor = "[-]"
    if bColorTxt then
	    local _, _, _, nQuality = Item:GetItemTemplateShowInfo(nTemplateId)
	    local _, _, _, _, szColor = Item:GetQualityColor(nQuality)
	    szTxtColor = "[" .. szColor .. "]"
    end
	for nChildId,nNeed in pairs(tbTargeInfo) do
		if tonumber(nChildId) and nChildId ~= nTemplateId then
			szName = Item:GetItemTemplateShowInfo(nChildId, me.nFaction, me.nSex)
			nHave = me.GetItemCountInAllPos(nChildId);
			szTip = (szTip == "") and szTip or (szTip .. "\n")
			szTip = string.format("%s%s%s：[FFFE0D]%d/%d[-]", szTip, szTxtColor, szName,nHave,nNeed);
		end
	end
	return szTip;
end

function EntityCompose:IsNeedConsume(nTemplateId)
	local nTargetID = EntityCompose:GetTargetIdByChild(nTemplateId)
	local tbTargeInfo = self.tbTargeInfo[nTargetID];
	return tbTargeInfo.szConsumeType
end

function EntityCompose:GetConsumeInfo(nTemplateId)
	local nTargetID = EntityCompose:GetTargetIdByChild(nTemplateId)
	local tbTargeInfo = self.tbTargeInfo[nTargetID];
	return tbTargeInfo.szConsumeType,tbTargeInfo.nConsumeCount;
end

function EntityCompose:GetBagSort(nTemplateId)
	local nTargetID = EntityCompose:GetTargetIdByChild(nTemplateId)
	local tbTargeInfo = self.tbTargeInfo[nTargetID];
	return tbTargeInfo.nBagSort;
end

function EntityCompose:GetHideItemTip(nTemplateId)
	local nTargetID = EntityCompose:GetTargetIdByChild(nTemplateId)
	local tbTargeInfo = self.tbTargeInfo[nTargetID];
	return tbTargeInfo.bIsHideItemTip;
end


function EntityCompose:GetMaterialCount(nTemplateId)
	local nTargetID = EntityCompose:GetTargetIdByChild(nTemplateId) or 0
	local tbTargeInfo = self.tbTargeInfo[nTargetID];
	local nCount = 0
	for nChildId in pairs(tbTargeInfo) do
		if tonumber(nChildId) and nChildId ~= nTemplateId then
			nCount = nCount + 1
		end
	end
	return nCount
end