Compose.ValueCompose = Compose.ValueCompose or {}
local ValueCompose = Compose.ValueCompose;
local nMaxParam = 9;
ValueCompose.tbAllInfo = {};
ValueCompose.tbGuideItem =  					-- 给处于nStartTaskId 至 nEndTaskId 任务线之间并且没有nGuideItemId的玩家补发nGuideItemId
{
	[1] = {
		nStartTaskId = 26; 
		nEndTaskId = 188;
		nGuideItemId = 9567;
	};
	[2] = {
		nStartTaskId = 216;
		nEndTaskId = 412;
		nGuideItemId = 9568;
	};
}
ValueCompose.tbTipPos = 
{
	[1] =  						-- 拥有总数对应的提示位置
	{
		[0] = 1;
		[1] = 2;
		[2] = 3;
		[3] = 4;
		[4] = 5;
		[5] = 6;
		[6] = 7;
		[7] = 8;
		[8] = 9;
	};
	[2] = 
	{
		[0] = 1;
		[1] = 2;
		[2] = 3;
		[3] = 4;
		[4] = 5;
		[5] = 6;
		[6] = 7;
		[7] = 8;
		[8] = 9;
	};
}

-- 补发错过的线索
ValueCompose.tbFinishTaskValue = 
{
	[1] = {
		[26] = 1;
		[46] = 2;
		[57] = 3;
		[84] = 4;
		[95] = 5;
		[109] = 6;
		[138] = 7;
		[162] = 8;
		[188] = 9;
	};
	[2] = {
		[216] = 1;
		[235] = 2;
		[259] = 3;
		[265] = 4;
		[288] = 5;
		[306] = 6;
		[320] = 7;
		[352] = 8;
		[412] = 9;
	};
}

function ValueCompose:InitData()
	local szTabPath = "Setting/Item/ItemCompose/ValueCompose.tab";
	local szParamType = "ddsdsd";
	local szKey = "SeqId";
	local tbParams = {"SeqId","TargetTemplateId","DirTitle", "Icon", "Tips", "Quality"};

	for i=1,nMaxParam do
		szParamType = szParamType .."s";
		table.insert(tbParams,"ItemDes" ..i);
		szParamType = szParamType .."s";
		table.insert(tbParams,"ItemTexture" ..i);
		szParamType = szParamType .."s";
		table.insert(tbParams,"ItemTip" ..i);
	end

	local tbSettings = LoadTabFile(szTabPath, szParamType, szKey, tbParams);
	for nSeqId,v in ipairs(tbSettings) do
		local tbSeqInfo = {}
		tbSeqInfo.nSeqId = v.SeqId;
		tbSeqInfo.nTargetTemplateId = v.TargetTemplateId;
		tbSeqInfo.szDirTitle = v.DirTitle;
		
		tbSeqInfo.szBGMapPath = v.BGMapPath;
		tbSeqInfo.nIcon = v.Icon;
		tbSeqInfo.szTips = v.Tips;
		tbSeqInfo.nQuality = v.Quality;
		local nTempCount = 0;
		for i=1, nMaxParam do
			tbSeqInfo["szItemDes" ..i] = v["ItemDes" ..i];
			tbSeqInfo["szItemTip" ..i] = v["ItemTip" ..i];
			if v["ItemTexture" ..i] ~= "" then
				tbSeqInfo["ItemTexture" ..i] = v["ItemTexture" ..i];
				nTempCount = nTempCount + 1;
			end
			
		end
		tbSeqInfo.nAllCount = nTempCount;
		self.tbAllInfo[nSeqId] = tbSeqInfo;
	end
end

ValueCompose:InitData();

--返回某个nSeqId的信息
function ValueCompose:GetSeqInfo(nSeqId)
	return self.tbAllInfo[nSeqId];
end

function ValueCompose:GetShowInfo(nSeqId)
	local tbSeqInfo = self:GetSeqInfo(nSeqId)
	if not tbSeqInfo then
		return;
	end

	return tbSeqInfo.nIcon, tbSeqInfo.szDirTitle, tbSeqInfo.szTips, tbSeqInfo.nQuality;
end

function ValueCompose:GetSeqAllCount(nSeqId)
	local tbSeqInfo = self:GetSeqInfo(nSeqId)
	if not tbSeqInfo then
		return;
	end
	return tbSeqInfo.nAllCount
end

function ValueCompose:GetSeqTempleteId(nSeqId)
	local tbSeqInfo = self:GetSeqInfo(nSeqId)
	if not tbSeqInfo then
		return;
	end
	return tbSeqInfo.nTargetTemplateId
end

--是否是有效范围内的Value
function ValueCompose:CheckIsValidValue(nSeq,nPos)
	
	if not nSeq or not nPos or nSeq <= 0 or nPos <= 0 then
		Log("ValueCompose:CheckIsValidValue is not a valid value ",nSeq,nPos)
		return ;
	end

	local tbSeqInfo = self:GetSeqInfo(nSeq);
	if not tbSeqInfo then
		return;
	end

	if nPos > tbSeqInfo.nAllCount then
		return;
	end

	return true;
end

function ValueCompose:GetHaveValueNum(pPlayer,nSeqId)
	local nCount = 0;
	local tbSeqInfo = self:GetNeedCollectValue(nSeqId);
	for _,tbTemp in ipairs(tbSeqInfo) do
		local nId = tbTemp.nSeqId;
		local nPos = tbTemp.nPos;
		if ValueItem.ValueCompose:GetValue(pPlayer,nId,nPos) > 0 then
			nCount = nCount + 1;
		end
	end
	return nCount
end

--是否拥有某个Value
function ValueCompose:CheckIsHaveValue(pPlayer,nSeqId,nPos)
	if not self:CheckIsValidValue(nSeqId,nPos) then
		return ;
	end
	return ValueItem.ValueCompose:GetValue(pPlayer,nSeqId,nPos) > 0;
end

--是否搜集完了Value
function ValueCompose:CheckIsFinish(pPlayer,nSeqId,bJustResult)

	local tbSeqInfo = self:GetNeedCollectValue(nSeqId);
	if not tbSeqInfo then
		Log("ValueCompose:CheckIsFinish ?? can not find tbSeqInfo",pPlayer.szName,nSeqId)
		return
	end
	local tbUnfinishPos = {};
	local tbFinishPos = {};
	local bIsFinish = true;
	for _,tbTemp in ipairs(tbSeqInfo) do
		local nId = tbTemp.nSeqId;
		local nPos = tbTemp.nPos;
		if not self:CheckIsValidValue(nId,nPos) then
			Log("ValueCompose:CheckIsValidValue ?? is a invalid value",nId,nPos);
			return 
		end
		if ValueItem.ValueCompose:GetValue(pPlayer,nId,nPos) < 1 then
			bIsFinish = false;
			if bJustResult then
				return bIsFinish;
			end
			table.insert(tbUnfinishPos,nPos);
		else
			table.insert(tbFinishPos,nPos);
		end
	end

	return bIsFinish,tbUnfinishPos,tbFinishPos;
end

--返回需要搜集的Value
function ValueCompose:GetNeedCollectValue(nSeqId)
	local tbSeqInfo = {}
	
	local nAllCount = self:GetSeqAllCount(nSeqId);
	if nAllCount then
		for nPos=1,nAllCount do
			local tbTemp = {};
			tbTemp.nSeqId = nSeqId;
			tbTemp.nPos = nPos;
			table.insert(tbSeqInfo,tbTemp);
		end
		return tbSeqInfo;
	end
end

function ValueCompose:CheckValueCompose(pPlayer,nSeqId)
	
	if not nSeqId or not tonumber(nSeqId) then
		return false,"违法合成操作！";
	end

	nSeqId = tonumber(nSeqId)
	if nSeqId < 1 then
		return false,"你要合成什么？";
	end

	local tbSeqInfo  = self:GetSeqInfo(nSeqId);
	if not tbSeqInfo then
		return false,"找不到合成信息！";
	end

	local nTargetTemplateId = tbSeqInfo.nTargetTemplateId
	if not nTargetTemplateId then
		return false,"找不到合成目标！"; 
	end

	local bIsFinish, _, tbFinishPos = self:CheckIsFinish(pPlayer, nSeqId)
	if not bIsFinish then
		return false,"还没有完成拼图！";
	end

	local bRet, szMsg = pPlayer.CheckNeedArrangeBag()
	if bRet then
		return false, szMsg;
	end

	return true, "", nTargetTemplateId, tbFinishPos;
end

