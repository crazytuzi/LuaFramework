--[[
playerData = {
		szWuxing = "1112",--五行结果
	};
]]
Pray.PRAY_OPEN_LEVEL = 1;

function Pray:LoadSetting()
	local tbRewardSetting = LoadTabFile(
        "Setting/Pray/PrayReward.tab", 
        "dsdd", nil,
        {"Group", "Type", "TemplateId", "Count"});

	self.tbRewardSetting = {};
	for k,v in pairs(tbRewardSetting) do
		self.tbRewardSetting[v.Group] = self.tbRewardSetting[v.Group] or {};
		table.insert(self.tbRewardSetting[v.Group], {
			szType = v.Type,
			nTemplateId = v.TemplateId,
			nCount = v.Count,
		});
	end


	local tbPraySetting = LoadTabFile(
        "Setting/Pray/Pray.tab", 
        "sssssdddd", "Type",
        {"Type", "Wuxing", "Buff", "Explain", "Arrangement", "RewardGroup", "SkillId", "SkillLevel", "SkillTime"});
	
	self.tbPraySetting = {};
	for k,v in pairs(tbPraySetting) do
		local szArrangement = string.gsub(v.Arrangement, "\\n", "\n") 
		local szExplain = string.gsub(v.Explain, "\\n", "\n") 
		
		self.tbPraySetting[v.Type] = {
			szType = v.Type,
			szWuxing = v.Wuxing,
			szBuff = v.Buff,
			szExplain = szExplain,
			szArrangement = szArrangement,
			nRewardGroup = v.RewardGroup,
			nSkillId = v.SkillId,
			nSkillLevel = v.SkillLevel,
			nSkillTime = v.SkillTime,
		};
	end
end
Pray:LoadSetting();

function Pray:IsEndWuxing(pPlayer)
	local szWuxing = self:GetPrayElements(pPlayer);
	local nLen = string.len(szWuxing);

	if nLen == 5 then
		return true;
	end

	if nLen > 1 then
		local szElem1 = string.sub(szWuxing, nLen, nLen);
		local szElem2 = string.sub(szWuxing, nLen - 1, nLen - 1);

		if szElem1 == szElem2 then
			return false;
		else
			return true;
		end
	end

	return false;
end

function Pray:IsNullWuxing(pPlayer)
	local szWuxing = self:GetPrayElements(pPlayer);
	local nLen = string.len(szWuxing);

	if nLen < 1 then
		return true;
	end

	return false;
end

function Pray:GetItemRewards(pPlayer)
	local szWuxing = self:GetPrayElements(pPlayer);
	local tbSetting = self.tbPraySetting[szWuxing];
	
	if not tbSetting then
		return {};
	end

	local nRewardGroup = tbSetting.nRewardGroup;
	return self.tbRewardSetting[nRewardGroup] or {};
end

function Pray:GetBuffRewards(pPlayer)
	local szWuxing = self:GetPrayElements(pPlayer);
	local tbSetting = self.tbPraySetting[szWuxing];

	if not tbSetting or not tbSetting.nSkillId then
		return;
	end

	return tbSetting.nSkillId, tbSetting.nSkillLevel, tbSetting.nSkillTime;
end

function Pray:GetPrayElements(pPlayer)
	if MODULE_GAMESERVER then
		local tbPrayData = pPlayer.GetScriptTable("Pray");
		return tbPrayData.szWuxing or "";
	else
		return self.szWuxing or "";
	end
end

function Pray:GetSetting(szWuxing)
	return self.tbPraySetting[szWuxing or ""] or {};
end

function Pray:IsLevelEnough(pPlayer)
	return pPlayer.nLevel >= self.PRAY_OPEN_LEVEL;
end