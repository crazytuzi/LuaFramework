Require("CommonScript/Partner/PartnerDef.lua");
Require("CommonScript/Partner/PartnerCommon.lua");

local MAX_SKILL_LEVEL = 10;
function Partner:LoadSkillInfo()
	self.tbLevelupTemplate = {};
	local tbLevelupInfo = LoadTabFile("Setting/Partner/SkillLevelup.tab", "ddd", nil, {"nLevelupId", "nLevel", "nExp"});
	for _, tbRow in ipairs(tbLevelupInfo) do
		self.tbLevelupTemplate[tbRow.nLevelupId] = self.tbLevelupTemplate[tbRow.nLevelupId] or {};
		assert(tbRow.nLevel == #self.tbLevelupTemplate[tbRow.nLevelupId] + 1, string.format("[Partner] LoadSkillInfo ERR !! Setting/Partner/SkillLevelup.tab nLevelupId = %d, nLevel = %d ", tbRow.nLevelupId, tbRow.nLevel));
		table.insert(self.tbLevelupTemplate[tbRow.nLevelupId], tbRow.nExp);
	end

	self.tbSkillBookSetting = {};
	local szType = "dddddddd";
	local tbTitle = {"nSkillBookId", "nType", "nLevel", "nQuality", "nSeries", "nSkillId", "nValue", "nLevelupId"};
	for i = 1, MAX_SKILL_LEVEL do
		szType = szType .. "d";
		table.insert(tbTitle, "nLevelValue" .. i);
	end

	local tbSkillBook = LoadTabFile("Setting/Partner/SkillBook.tab", szType, "nSkillBookId", tbTitle);
	for nSkillBookId, tbInfo in pairs(tbSkillBook) do
		self.tbSkillBookSetting.tbSkillId2BookId = self.tbSkillBookSetting.tbSkillId2BookId or {};
		assert(not self.tbSkillBookSetting.tbSkillId2BookId[tbInfo.nSkillId], "[Partner] Load Setting/Partner/SkillBook.tab fail !! nSkillBookId = " .. nSkillBookId);
		self.tbSkillBookSetting.tbSkillId2BookId[tbInfo.nSkillId] = nSkillBookId;

		self.tbSkillBookSetting.tbBookInfo = self.tbSkillBookSetting.tbBookInfo or {};
		assert(not self.tbSkillBookSetting.tbBookInfo[nSkillBookId], "[Partner] Load Setting/Partner/SkillBook.tab fail !! nSkillBookId = " .. nSkillBookId);


		local tbLevelupInfo = self.tbLevelupTemplate[tbInfo.nLevelupId];
		assert(tbLevelupInfo, "[Partner] Load Setting/Partner/SkillBook.tab fail !! nLevelupId error !! nSkillBookId = " .. nSkillBookId);

		tbInfo.tbSkillValue = {};
		for i = 1, MAX_SKILL_LEVEL do
			tbInfo.tbSkillValue[i] = tbInfo["nLevelValue" .. i];
			tbInfo["nLevelValue" .. i] = nil;
			if tbInfo.tbSkillValue[i] == 0 then
				tbInfo.tbSkillValue[i] = nil;
				break;
			end

			tbInfo.nMaxLevel = i;
			assert(#tbLevelupInfo >= i - 1);
			assert(tbInfo.tbSkillValue[i] >= (tbInfo.tbSkillValue[i - 1] or 0));
		end
		self.tbSkillBookSetting.tbBookInfo[nSkillBookId] = tbInfo;
	end
end

Partner:LoadSkillInfo();

function Partner:GetSkillInfo(nSkillBookId)
	return self.tbSkillBookSetting.tbBookInfo[nSkillBookId];
end

function Partner:GetSkillInfoBySkillId(nSkillId)
	local nSkillBookId = self.tbSkillBookSetting.tbSkillId2BookId[nSkillId];
	if not nSkillBookId then
		return;
	end

	return self:GetSkillInfo(nSkillBookId);
end

function Partner:GetMaxSkillLevel(nSkillId, nPartnerLevel)
	return 1;
end

