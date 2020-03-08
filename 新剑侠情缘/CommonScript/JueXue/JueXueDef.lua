JueXue.Def = {
	szMoneyType            = "SkillExp",
	nXiuLian4SkilllLv      = 10,   --每修炼等级对应的技能ID比例
	nActivateTemplateId    = 2424, --激活消耗道具ID
	nActivateConsume       = 100,  --激活消耗道具数量
	nAttribScale           = 1000, --属性比例
	nDpSkillRate           = 10000,--断篇技能总概率
	nMibenAddScale         = 10,   --秘本加成比例
	tbDpAttribPercent      = {
								[1] = {nPercent = 0,   nRate = 3656},
								[2] = {nPercent = 10,  nRate = 2436},
								[3] = {nPercent = 20,  nRate = 1624},
								[4] = {nPercent = 30,  nRate = 1082},
								[5] = {nPercent = 40,  nRate = 721},
								[6] = {nPercent = 50, nRate = 481},
							},
	tbAreaInfo             = {
								[1] = {szTimeFrame = "OpenLevel49", nBookType = 9 , bSuit = true},
								[2] = {szTimeFrame = "OpenDay369", nBookType = 10, bSuit = true},
								[3] = {szTimeFrame = "OpenLevel129Add45", nBookType = 11, bSuit = true},
								[4] = {szTimeFrame = "OpenSecretFuben", nBookType = 12, bSuit = true},
								--如果有tbChildArea，那么不检查其他条件，规则有修改需重新设计
								--bNotMiben代表这个区域没有秘本，那么断篇的位置也提前一位
								[5] = {tbChildArea = {1, 2, 3, 4},  bNotMiben = true},
							},
	tbAttribColor          = {	--ItemColor的白色文本颜色为灰色，所以此处属性全部自定义色值
								"ffffff",--白
								"64db00",--绿
								"11adf6",--蓝
								"aa62fc",--紫
								"ff578c",--粉
								"ff8f06",--橙
								"e6d012",--金
							},
	tbRelationSkill        = {
								[5349] = {5383, 5384},  --增加5349技能的同时，增加5383、5384两个技能
							},



	nDataGroup             = 155,
	nActivateFlag          = 1,
	nXiuLianLv             = 2,
	nAreaInterval          = 5,
							--保存在装备上的数据，1-20为其他占用，详见CommonScript/Item/Define.lua
	tbJuexueItemData       = {nSkillLv = 21, nAttribLv = 22},
	tbMibenItemData        = {nDuanpianAddBegin = 21, nDuanpianAddEnd = 24, nAttribIdxBegin = 25, nAttribValvePBegin = 26},
	tbDuanpianItemData     = {nSuitSkillId = 21, nMibenAdd = 22, nAttribIdxBegin = 23, nAttribValvePBegin = 24},
	nMibenAttNum           = 2,
	nDuanpianAttNum        = 3,
	nItemExtAttribGroup    = 1,
	nItemExtAddXiuwei      = 2,
	nItemExtFixSuitId      = 3,
	nSuitSkillQuality      = 1,--大于该质量才有可能有套装
							--装备位置，勿改
	nAreaEquipPos          = 9,
	nMibenEquipPos         = 2,
	nDuanPianEquipStartPos = 3,
	tbJuexuePos            = {[1] = 1, [10] = 2, [19] = 3, [28] = 4, [37] = 5},
	tbDpAroundMiben        = {
								[2]  = {9,  38, 41,  3},
								[11] = {12, 18, 39, 38},
								[20] = {39, 21, 27, 40},
								[29] = {41, 40, 30, 36},
							},
}
--[[

每个区域装备位置从绝学开始，其次秘本，然后才是断篇
周边区域的断篇的位置从秘本开始顺时针
中间区域的断篇从0点开始顺时针

 6---7---8      13--14--15
 |   |   |       |   |   |
 5--[1]--9      12-[10]-16
 |   |   |       |   |   |
 4---3--(2)-38-(11)-18--17
         |   |   |
        41-[37]-39
         |   |   |
35--36-(29)-40-(20)-21--22
 |   |   |       |   |   |
34-[28]-30      27-[19]-23
 |   |   |       |   |   |
33--32--31      26--25--24

]]

function JueXue:LoadSetting()
	self.tbJuexue = {}
	local tbFile = Lib:LoadTabFile("Setting/Item/JueXue/JueXue.tab", {ItemTID = 1, Faction = 1, SoleTag = 1, SkillID = 1})
	for _, tbInfo in pairs(tbFile) do
		local tbTmp = {Faction = tbInfo.Faction, SoleTag = tbInfo.SoleTag, SkillID = tbInfo.SkillID, tbAttrib = {}}
		for i = 1, 10 do
			if not tbInfo["AttribType" .. i] then
				break
			end
			table.insert(tbTmp.tbAttrib,
				{AttribType = tbInfo["AttribType" .. i],
				InitValue = tbInfo["InitValue" .. i],
				GrowValue = tbInfo["GrowValue" .. i]})
		end
		self.tbJuexue[tbInfo.ItemTID] = tbTmp
	end

	self.tbXiuLianExp = {}
	self.nXiuLianMaxLv = 0
	tbFile = Lib:LoadTabFile("Setting/Item/JueXue/XiuLianExp.tab", {Level = 1, CostExp = 1})
	for _, tbInfo in pairs(tbFile) do
		self.tbXiuLianExp[tbInfo.Level] = {tbInfo.CostExp, tbInfo.FightPower}
		self.nXiuLianMaxLv = math.max(tbInfo.Level, self.nXiuLianMaxLv)
	end

	self.tbSuitAttrib = {}
	local nDuanpianPosCount = self.Def.nAreaEquipPos - self.Def.nDuanPianEquipStartPos + 1
	local tbKey = {SuitAttribId = 1, Rate = 1, ExternAttribGroupId = 1}
	for i = 1, nDuanpianPosCount do
		tbKey["ActiveLv" .. i] = 1
	end
	tbFile = Lib:LoadTabFile("Setting/Item/JueXue/SuitAttrib.tab", tbKey)
	for _, tbInfo in pairs(tbFile) do
		local tbTmp = {nRate = tbInfo.Rate, nExternGroup = tbInfo.ExternAttribGroupId, tbCount2SkillLv = {}}
		local nMaxLen = 0
		for i = 1, nDuanpianPosCount do
			if tbInfo["ActiveLv" .. i] <= 0 then
				break
			end
			nMaxLen = tbInfo["ActiveLv" .. i]
			table.insert(tbTmp.tbCount2SkillLv, nMaxLen)
		end
		if MODULE_GAMECLIENT then
			tbTmp.szSuitName = tbInfo.SuitName
			tbTmp.nMaxLen    = nMaxLen
			tbTmp.szIcon     = tbInfo.Icon
			tbTmp.szAtlas    = tbInfo.Atlas
		end
		self.tbSuitAttrib[tbInfo.SuitAttribId] = tbTmp
	end

	tbKey = {"Quality", "SumLvMin", "SumLvMax", "SingleLvMin", "SingleLvMax"}
	self.tbMibenAdd = LoadTabFile("Setting/Item/JueXue/Miben2Duanpian.tab", "ddddd", "Quality", tbKey)

	self.tbAttribRate = {}
	tbFile = Lib:LoadTabFile("Setting/Item/JueXue/RandomAttribRate.tab", {GroupId = 1, AttribIdx = 1, Rate = 1})
	for _, tbInfo in pairs(tbFile) do
		self.tbAttribRate[tbInfo.GroupId] = self.tbAttribRate[tbInfo.GroupId] or {nTotalRate = 0, tbAttrib = {}}
		self.tbAttribRate[tbInfo.GroupId].tbAttrib[tbInfo.AttribIdx] = tbInfo.Rate
		self.tbAttribRate[tbInfo.GroupId].nTotalRate = self.tbAttribRate[tbInfo.GroupId].nTotalRate + tbInfo.Rate
	end

	self.tbAttrib = {}
	tbKey = {Idx = 1, Level = 1}
	for i = 1, 3 do
		tbKey["ValueMin" .. i] = 1
		tbKey["ValueRange" .. i] = 1
	end
	tbFile = Lib:LoadTabFile("Setting/Item/JueXue/Attrib.tab", tbKey)
	for _, tbInfo in pairs(tbFile) do
		local tbTmp = {AttribType = tbInfo.AttribType, tbValue = {}}
		for i = 1, 3 do
			table.insert(tbTmp.tbValue, {tbInfo["ValueMin" .. i], tbInfo["ValueRange" .. i]})
		end
		self.tbAttrib[tbInfo.Idx] = self.tbAttrib[tbInfo.Idx] or {}
		self.tbAttrib[tbInfo.Idx][tbInfo.Level] = tbTmp
	end

	self.tbXiuWei2SkillLv = {}
	tbFile = Lib:LoadTabFile("Setting/Item/JueXue/Xiuwei2Skill.tab", {XiuWei = 1, SkillLevel = 1})
	for _, tbInfo in pairs(tbFile) do
		table.insert(self.tbXiuWei2SkillLv, {tbInfo.XiuWei, tbInfo.SkillLevel})
	end
end
JueXue:LoadSetting()

for nArea, tbInfo in ipairs(JueXue.Def.tbAreaInfo) do
	if tbInfo.tbChildArea then
		for _, nChildArea in ipairs(tbInfo.tbChildArea) do
			JueXue.Def.tbAreaInfo[nChildArea].nParentArea = nArea
		end
	end
end