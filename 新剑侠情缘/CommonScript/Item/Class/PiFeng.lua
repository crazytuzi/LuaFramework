Require("CommonScript/Item/Class/Equip.lua")
Require("CommonScript/Player/PlayerDef.lua")

local tbPiFeng = Item:GetClass("PiFeng");
local tbEquip = Item:GetClass("equip");

--不同阶不同性别
tbPiFeng.tbEquipDesc = {
	[1]	= {
		[Player.SEX_MALE] = "轻纱质地的披风，饰以碎星，上缀烫金制成的凤凰花饰，如同凤唳云中，下临霄汉。寓意不鸣则已，一鸣惊人。\n\n[1EFEFB]一朝孤凤鸣云中，震断九州无凡乡。[-]";
		[Player.SEX_FEMALE] = "湘水之西有峰名曰回雁峰，为北雁过冬之所。相传有猎人于山北射落雄雁，雌雁见爱侣身亡，盘桓三周亦触山殉死。后人感于大雁为爱忠贞不渝，至死方休，随制此披风，以示两情相悦，至死不渝。\n\n[1EFEFB]雁阵惊寒，声断衡阳之浦。[-]";
	};
};

function tbPiFeng:OnInit(pEquip)
	local nValue = pEquip.nOrgValue;
	local nFightPower = pEquip.nBaseFightPower;
	local nRefinePower, nRefineValue, nMaxQuality = Item.tbPiFeng:InitEquip(pEquip);
	pEquip.nFightPower = nFightPower + nRefinePower;
	pEquip.SetSingleValue(nValue + nRefineValue)
	pEquip.nQuality = math.max(1, nMaxQuality);
end

function tbPiFeng:GetTip(pEquip, pPlayer, bIsCompare)            -- 获取普通道具Tip
	local nMaxQuality = pEquip.nQuality
	local tbRandomAttrib, nMaxQuality = self:GetRandomAttrib(pEquip)
	--local tbReturn = self:FormatTips(tbRandomAttrib,pEquip.nLevel, pPlayer.GetSex())
	local tbReturn = self:FormatTips(tbRandomAttrib,pEquip.nLevel, pPlayer.nSex)
	return tbReturn, nMaxQuality;
end

function tbPiFeng:GetTipByTemplate(nTemplateId, tbSaveRandomAttrib)
	local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId);
	local nBaseQuality = tbBaseInfo.nQuality
	local nMaxQuality = nBaseQuality
	local tbRandomAttrib = {}
	if tbSaveRandomAttrib then
		tbSaveRandomAttrib["nLevel"] = tbBaseInfo.nLevel
		tbRandomAttrib, nMaxQuality = self:GetRandomAttrib(tbSaveRandomAttrib)
	end
	
	nMaxQuality = math.max(nMaxQuality, nBaseQuality)

	local tbReturn = self:FormatTips(tbRandomAttrib, tbBaseInfo.nLevel, me.nSex)

	return tbReturn, nMaxQuality;
end

function tbPiFeng:FormatTips(tbRandomAttrib, nEquipLevel,nSex)
	local tbAttribs = {};
	table.insert(tbAttribs, {"", 1});
	
	if next(tbRandomAttrib) then
		local nMaxCount = Item.tbPiFeng:GetMaxAtrriCountByLevel( nEquipLevel )
		table.insert(tbAttribs, {  string.format("附加属性%d/%d", #tbRandomAttrib, nMaxCount) });
		for i, v in ipairs(tbRandomAttrib) do
			table.insert(tbAttribs, v);
		end
	end
	for i=1,10 -#tbRandomAttrib  do
		table.insert(tbAttribs, {"", 1});
	end
	local szDesc = self.tbEquipDesc[nEquipLevel][nSex]
	table.insert(tbAttribs, {szDesc})
	return tbAttribs
end

function tbPiFeng:GetRandomAttrib(pEquipOrTab)
	local tbAttribs = Item.tbPiFeng:GetRandomAttrib(pEquipOrTab)
	
	local tbTip = {};
	local nMaxQulity = 0;
	local nEquipLevel = pEquipOrTab.nLevel
	
	for _, tbAttrib in ipairs(tbAttribs) do
		local vOne, nQuality = self:GetTipOneAttrib(nEquipLevel, tbAttrib)
		if vOne then
			table.insert(tbTip, vOne);
		end
		if nQuality > nMaxQulity then
			nMaxQulity = nQuality;
		end
	end

	return tbTip, nMaxQulity;
end

--装备格子特效显示用到
function tbPiFeng:GetBaseAttrib(nTemplate)
	local tbTip = {};
	local tbInfo = KItem.GetItemBaseProp(nTemplate)
	local nColorQuality = tbInfo.nQuality
	return tbTip, nColorQuality;
end


function tbPiFeng:GetTipOneAttrib(nEquipLevel, tbAttrib)
	local nQuality = Item.tbRefinement:GetAttribColor(nEquipLevel, tbAttrib.nAttribLevel);
	local szDesc = tbEquip:GetMagicAttribDesc(tbAttrib.szAttrib, tbAttrib.tbValues);
	if Lib:IsEmptyStr(szDesc) then
		return nil, nQuality
	end
	return {szDesc, nQuality}, nQuality
end