PartnerCard.CARD_SAVE_GROUP_LIST = {159,160,161,162,163,164,165,166,167,168,169,170} 				-- 卡片数据保存的组（只能扩组，不能改变组的顺序，改顺序会导致卡片数据错乱，按200个门客每个门客预留15个位置算，得预留（200*15/255）12个组）
PartnerCard.CARD_POS_LOCK_SAVE_GROUP_LIST = {158} 													-- 门客位是否解锁保存的组（只能扩组，不能改变组的顺序，改顺序会导致卡片数据错乱）（一个组256*32个）
local MAX_SAVE_COUNT_PER = 15 																		-- 每个卡片预留几个位置保存数据（出去后不能改，如果出去后不够用，只能将数据存在别的地方）
local MAX_PER_GROUP_COUNT = math.floor(255 / MAX_SAVE_COUNT_PER)									-- 每个组最多存几个卡（出去后不能改）
PartnerCard.MAX_PARTNER_CARD_ID = 200 																-- 因为数据是根据卡的ID存的所有在目前可用组的情况下可用的最大的id，也是可用的门客的数量，如果想扩大得先扩组
local LEVEL_IDX_STEP = 1 																			-- [卡片等级] 基于所在组开始索引的跨度（出去后不能改）															
local EXP_IDX_STEP = 2 																				-- [卡片友好度] 基于所在组开始索引的跨度（出去后不能改）
local ON_POS_IDX_STEP = 3 																			-- [卡片上阵位置] 基于所在组开始索引的跨度（出去后不能改）
local GET_TIME_IDX_STEP = 4 																		-- [获得卡片时间]也是判断拥有该卡片的依据 基于所在组开始索引的跨度（出去后不能改）
local GET_FLAG_IDX_STEP = 5 																		-- [获得卡片标志]也是判断拥有过该卡片的依据 基于所在组开始索引的跨度（出去后不能改）
PartnerCard.nMaxCardPos = 200 																		-- 限制一共最多有200个门客位,也是门客位CardPos的最大值（门客位信息记录在异步信息里面，要调整的话得调整异步数据存储大小）

local PARTNER_CARD_POS_BEGINE_SAVE_ID = 4158 														-- 在异步数据中存储的开始位置，不能改
local PARTNER_CARD_POS_END_SAVE_ID = 7159 															-- 在异步数据中存储的结束位置，不能改
local PARTNER_CARD_POS_CARD_ID_IDX_STEP = 1 														-- [上阵卡片id] 异步数据基于所在组开始索引的跨度（出去后不能改）
local PARTNER_CARD_POS_CARD_LEVEL_IDX_STEP = 2 														-- [上阵卡片等级] 异步数据基于所在组开始索引的跨度（出去后不能改）
local PARTNER_CARD_POS_MAX_IDX_STEP = 5 															-- 每个上阵位预留最大数量（出去后不能改）
-- 外部访问
PartnerCard.nLevelIdxStep = LEVEL_IDX_STEP
PartnerCard.nExpIdxStep = EXP_IDX_STEP
PartnerCard.nOnPosIdxStep = ON_POS_IDX_STEP
PartnerCard.nGetTimeIdxStep =  GET_TIME_IDX_STEP	
PartnerCard.nGetFlagIdxStep =  GET_FLAG_IDX_STEP													
PartnerCard.nAsynCardIdIdxStep = PARTNER_CARD_POS_CARD_ID_IDX_STEP
PartnerCard.nAsynCardLevelIdxStep = PARTNER_CARD_POS_CARD_LEVEL_IDX_STEP
PartnerCard.nMaxSaveCountPer = MAX_SAVE_COUNT_PER

-- 之前Start和End覆盖了，现在是从7180开始的，就是说7160到7180之间还没用到(暂废弃，因为可以用过现有数据算出来，不过里面可能存了一些脏数据，用之前得先清掉)
--PartnerCard.PARTNER_CARD_SKILL_BEGINE_SAVE_ID = 7160 												-- 门客增加的护主技能开始
PartnerCard.PARTNER_CARD_SKILL_BEGINE_SAVE_ID = 7180 												-- 门客增加的护主技能结束
PartnerCard.PARTNER_CARD_SKILL_END_SAVE_ID = 7200 													-- 门客增加的护主技能结束
PartnerCard.nAsynMaxUseSkill = 8 																	-- 4个同伴位，每个同伴一个护主，需要记录技能id和技能等级，最多占用8个位置

-- 下面策划配
PartnerCard.CARD_START_LEVEL = 1 																	-- 卡片获得初始等级
PartnerCard.szFuncOpenTimeFrame = "OpenLevel39" 													-- 功能开放时间轴
PartnerCard.nMaxGiftSendTimes = 50 																	-- 每个门客每天可被赠送礼物的次数

PartnerCard.bGiftTimesReset = true 																	-- 是否每天重置次数
PartnerCard.nShowLockCardPos = 1 																	-- 显示未解锁的后几个
PartnerCard.nDefaultSuitLevel = 1 																	-- 默认套装属性的等级
	
PartnerCard.nPartnerGralleryGuideId = 46 															-- 点击图鉴引导
PartnerCard.nPartnerCardGuideId = 47 																-- 打开门客界面引导

PartnerCard.tbQualityTitle =  																		-- 等级称号
{
	[1] = 6801;
	[2] = 6802;
	[3] = 6803;
	[4] = 6804;
	[5] = 6805;
}

PartnerCard.nDimissReturnRate = 0.8 																-- 遣散返还道具比例

PartnerCard.tbPartnerLevelOutPut =  																-- 可以指定招募的门客同伴质量
{
	[4] = "OpenLevel39";
	[5] = "OpenLevel39";
}

PartnerCard.nRepeatAddQuality = 3 																	-- 甲级以上的只要拥有过遣散后就能重新招揽，以下的需要拥有同伴才能招揽

-- 默认开放的配最小开放时间轴
PartnerCard.tbLevelTimeFrame =  																	-- 星级开放时间轴
{
	[1] = "OpenLevel39";
	[2] = "OpenLevel39";
	[3] = "OpenLevel39";
	[4] = "OpenLevel39";
	[5] = "OpenLevel39";
	[6] = "OpenLevel39";
	[7] = "OpenLevel39";
	[8] = "OpenLevel39";
	[9] = "OpenLevel39";
	[10] = "OpenLevel39";
}

-- 时间轴开放对应的最大星级
PartnerCard.tbTimeFrameMaxOpenLevel = {}
for nLevel, szTimeFrame in pairs(PartnerCard.tbLevelTimeFrame) do
	local nMaxLevel = PartnerCard.tbTimeFrameMaxOpenLevel[szTimeFrame] or 0
	PartnerCard.tbTimeFrameMaxOpenLevel[szTimeFrame] = math.max(nMaxLevel, nLevel)
end

PartnerCard.nLiveTaskId = 3310 																		-- 入住家园任务id
PartnerCard.nUpPosTaskId = 3309 																	-- 上阵任务id

PartnerCard.nLogTypeAddCard = 1 																	-- TLog类型，获得门客
PartnerCard.nLogTypeDismissCard = 2 																-- TLog类型，遣散门客
PartnerCard.nLogTypeExp = 3 																		-- TLog类型，增加/减少门客友好度
PartnerCard.nLogTypeGift = 4 																		-- TLog类型，给门客送礼
PartnerCard.nLogTypeActState = 5 																	-- TLog类型，门客派遣

PartnerCard.nLogSubTypeSendCard = 1 																-- TLog Sub类型，获得门客重复拆解
PartnerCard.nLogSubTypeAddCard = 2 																	-- TLog Sub类型，获得门客不重复
PartnerCard.nLogSubTypeComposeCard = 3 																-- TLog Sub类型，合成门客
PartnerCard.nLogSubTypeDismissCardSingle = 1  														-- TLog Sub类型，遣散门客单个
PartnerCard.nLogSubTypeDismissCardBatch = 2 														-- TLog Sub类型，遣散门客批量
PartnerCard.nLogSubTypeDismissCardIdip = 3 															-- TLog Sub类型，Idip遣散门客,不返还直接遣散
PartnerCard.nLogSubTypeAddExp = 1 																	-- TLog Sub类型，增加友好度
PartnerCard.nLogSubTypeReduceExp = 2 																-- TLog Sub类型，减少友好度
PartnerCard.nLogSubTypeVisit = 1 																	-- TLog Sub类型，派遣拜访
PartnerCard.nLogSubTypeMuse = 2 																	-- TLog Sub类型，派遣冥想
PartnerCard.nLogSubTypeTrip = 3 																	-- TLog Sub类型，派遣游历
PartnerCard.tbPlayerShowAttrib = {"basic_damage_v", "None", "vitality_v","dexterity_v","strength_v","energy_v","metal_resist_v","ignore_metal_resist_v","wood_resist_v","ignore_wood_resist_v","water_resist_v","ignore_water_resist_v",
"fire_resist_v","ignore_fire_resist_v","earth_resist_v","ignore_earth_resist_v",  "all_series_resist_v","ignore_all_resist_v", "defense_v", "ignore_defense_v","deadlystrike_v","weaken_deadlystrike_v","recover_life_v","lifereplenish_p","state_hurt_resisttime",
"state_hurt_resistrate","state_stun_resisttime","state_stun_resistrate","state_slowall_resisttime","state_slowall_resistrate","state_zhican_resisttime","state_zhican_resistrate","state_palsy_resisttime","state_palsy_resistrate",
"add_seriesstate_rate_v","add_seriesstate_time_v"}

PartnerCard.tbQualityToTxtColor = 
{
	[1] = "e6d012";
	[2] = "ff8f06";
	[3] = "aa62fc";
	[4] = "11adf6";
	[5] = "64db00";
	[6] = "848484";
}

PartnerCard.CARD_COMPOSE_TIME = 86400 																	-- 合成需等待时间

PartnerCard.tbComposeNpcOffset =  																	-- 合成时周围npc相对中间npc的偏移和方向
{
	{300, 0, 50};
	{0, 300, 30};
	{-300, 0, 14};
	{0, -300, 58};	
}

PartnerCard.bCloseCompose = false 																	-- 门客合成开关
PartnerCard.nComposeNpcFurnitureId = 4 																-- npc同等模型家具检测是否可以摆放合成门客用
PartnerCard.nComposeEffect = 4710 																	-- 四周npc的特效
PartnerCard.nComposeMainEffect = 4711																-- 中间npc的技能特效
PartnerCard.COMPOSE_FINISH_NOTIFY_TIME = 30 * 60 													-- 门客合成完成感叹号过期时间

function PartnerCard:LoadSetting()
	self.tbCardSetting = {}
	self.tbAllAttrib = {}
	self.tbAllSkill = {}
	self.tbSuitCardCombine = {}
	self.tbPartnerTId2CardId = {}
	local tbFile = LoadTabFile("Setting/PartnerCard/PartnerCardSetting.tab", "ddddddssdssds", nil, {"nCardId", "nPartnerTempleteId", "nNpcNoTurnTempleteId", "nNpcTempleteId", "nExtAttribId", "nExtPartnerSkillId", "szUniquePartnerSkillId", "szCost", "nSuitIdx", "szName", "szTask", "nDialogId", "szRepeat"});
	local nMaxCardId = 0
	for _, v in ipairs(tbFile) do
		if not Lib:IsEmptyStr(v.szCost) then
			v.tbCost = Lib:GetAwardFromString(v.szCost)
		end
		v.szCost = nil
		if not Lib:IsEmptyStr(v.szRepeat) then
			v.tbRepeat = Lib:GetAwardFromString(v.szRepeat)
			assert(#v.tbRepeat == 1 and (v.tbRepeat[1][1] == "item" or v.tbRepeat[1][1] == "Item"), "PartnerCard Repeat Award Err " ..v.nCardId)
		end
		v.szRepeat = nil
		local szTask = v.szTask
		if not Lib:IsEmptyStr(szTask) then
			local tbTask = Lib:SplitStr(szTask, ";")
			for k, nTaskId in pairs(tbTask) do
				tbTask[k] = tonumber(nTaskId)
			end
			v.tbTask = tbTask
			v.szTask = nil
		end
		if Lib:IsEmptyStr(v.szTripBubble) then
			v.szTripBubble = nil
		end
		if v.nDialogId <= 0 then
			v.nDialogId = nil
		end
		nMaxCardId = math.max(nMaxCardId, v.nCardId)
		assert(not self.tbAllAttrib[v.nExtAttribId], "PartnerCard Attrib Same" ..v.nExtAttribId ..debug.traceback())
		self.tbAllAttrib[v.nExtAttribId] = true
		if v.nSuitIdx > 0 then
			self.tbSuitCardCombine[v.nSuitIdx] = self.tbSuitCardCombine[v.nSuitIdx] or {}
			table.insert(self.tbSuitCardCombine[v.nSuitIdx], v.nCardId)
		end
		if v.nExtPartnerSkillId > 0 then
			self.tbAllSkill[v.nExtPartnerSkillId] = true
		end
		if not Lib:IsEmptyStr(v.szUniquePartnerSkillId) then
			local tbUniquePartnerSkillId = Lib:SplitStr(v.szUniquePartnerSkillId, ";")
			for k, nSkillId in pairs(tbUniquePartnerSkillId) do
				nSkillId = tonumber(nSkillId)
				tbUniquePartnerSkillId[k] = nSkillId
				self.tbAllSkill[nSkillId] = true
			end
			v.tbUniquePartnerSkillId = tbUniquePartnerSkillId
			v.szUniquePartnerSkillId = nil
		end
		
		self.tbPartnerTId2CardId[v.nPartnerTempleteId] = v.nCardId
		self.tbCardSetting[v.nCardId] = v
	end
	if nMaxCardId > self.MAX_PARTNER_CARD_ID then
		Log(string.format("PartnerCard Valid MaxCardId : %d", nMaxCardId), debug.traceback())
	end
	self.tbCardPosSetting = {} 																		-- 门客位id为key
	self.tbPartnerCardPos = {} 																		-- 同伴位为key
	local nMaxCardPosId = 0
	tbFile = LoadTabFile("Setting/PartnerCard/PartnerCardPosSetting.tab", "ddsssss", nil, {"nPartnerPos", "nCardPos", "szOpenTimeFrame", "szLaterOpenTimeFrame", "szCost", "szLockTip", "szConsumeTip"});
	for _, v in ipairs(tbFile) do
		nMaxCardPosId = math.max(nMaxCardPosId, v.nCardPos)
		if v.nPartnerPos < 1 or v.nPartnerPos > Partner.MAX_PARTNER_POS_COUNT then
			Log(string.format("PartnerCard Valid PartnerPos : %d", v.nPartnerPos), debug.traceback())
		else
			if not self.tbCardPosSetting[v.nCardPos] then
				if v.szOpenTimeFrame == "" then
					v.szOpenTimeFrame = nil
				end
				if v.szLaterOpenTimeFrame == "" then
					v.szLaterOpenTimeFrame = nil
				end
				if not Lib:IsEmptyStr(v.szCost) then
					v.tbCost = Lib:GetAwardFromString(v.szCost)
				end
				v.szCost = nil
				self.tbCardPosSetting[v.nCardPos] = v
				self.tbPartnerCardPos[v.nPartnerPos] = self.tbPartnerCardPos[v.nPartnerPos] or {}
				table.insert(self.tbPartnerCardPos[v.nPartnerPos], v)
			else
				Log(string.format("PartnerCard Repeat CardPos : %d", v.nCardPos), debug.traceback())
			end
		end
	end
	assert(nMaxCardPosId <= self.nMaxCardPos, string.format("PartnerCard Valid MaxCardPosId %d", nMaxCardPosId) ..debug.traceback())
	local nCardPosCount = Lib:CountTB(self.tbCardPosSetting)
	assert(nCardPosCount <= self.nMaxCardPos, string.format("PartnerCard Valid MaxCardPos %d", nCardPosCount) ..debug.traceback())
	for _, v in pairs(self.tbPartnerCardPos) do
		if #v > 1 then
			table.sort(v, function (a,b) 
				return a.nCardPos < b.nCardPos
			end )
		end
	end
	self.tbCardSuit = {}
	self.tbCardSuitName = {}
	local szTabPath = "Setting/PartnerCard/PartnerCardSuit.tab";
	local szParamType = "ds";
	local szKey = "nSuitIdx";
	local tbParams = {"nSuitIdx", "szSuitName"};
	local nMaxClu = 10
	for i=1, nMaxClu do
		szParamType = szParamType .."dd";
		table.insert(tbParams,"nAttrib" ..i);
		table.insert(tbParams,"nActiveNum" ..i);
	end
	tbFile = LoadTabFile(szTabPath, szParamType, szKey, tbParams);
	for nSuitIdx, v in pairs(tbFile) do
		self.tbCardSuit[nSuitIdx] = self.tbCardSuit[nSuitIdx] or {}
		self.tbCardSuitName[nSuitIdx] = v.szSuitName
		for i = 1, nMaxClu do
			local szAttribKey = "nAttrib" ..i;
			local szActiveNumKey = "nActiveNum" ..i;
			if v[szAttribKey] and v[szAttribKey] > 0 and v[szActiveNumKey] and v[szActiveNumKey] > 0 then
					table.insert(self.tbCardSuit[nSuitIdx], {
							nAttrib = v[szAttribKey];
							nActiveNum = v[szActiveNumKey];
						})
				assert(not self.tbAllAttrib[v[szAttribKey]], "PartnerCard Attrib Same" ..v[szAttribKey] ..debug.traceback())
				self.tbAllAttrib[v[szAttribKey]] = true
			end
		end
		if #self.tbCardSuit[nSuitIdx] > 1 then
			table.sort(self.tbCardSuit[nSuitIdx], function (a,b) return a.nActiveNum < b.nActiveNum end)
		end
	end
	self.tbCardGift = {}
	tbFile = LoadTabFile("Setting/PartnerCard/PartnerCardGift.tab", "dds", nil, {"nItemId", "nAddExp", "szCardId"});
	for _, v in ipairs(tbFile) do
		assert(not self.tbCardGift[v.nItemId] and v.nAddExp > 0 , "PartnerCard Gift Item Repeat or Not Exp" ..v.nAddExp ..debug.traceback())

		self.tbCardGift[v.nItemId] = {}
		self.tbCardGift[v.nItemId].nAddExp = v.nAddExp
		local tbBelongCard = {}
		if not Lib:IsEmptyStr(v.szCardId) then
			tbBelongCard = Lib:SplitStr(v.szCardId, ";")
		end
		if next(tbBelongCard) then
			for _, szCardId in pairs(tbBelongCard) do
				self.tbCardGift[v.nItemId].tbBelongCard = self.tbCardGift[v.nItemId].tbBelongCard or {}
				self.tbCardGift[v.nItemId].tbSeqBelongCard = self.tbCardGift[v.nItemId].tbSeqBelongCard or {}
				local nCardId = tonumber(szCardId)
				self.tbCardGift[v.nItemId].tbBelongCard[nCardId] = true
				table.insert(self.tbCardGift[v.nItemId].tbSeqBelongCard, nCardId)
			end
			
		end
	end
	self.nCardFightPower = {}
	tbFile = LoadTabFile("Setting/PartnerCard/PartnerCardFightPower.tab", "ddd", nil, {"nQuality", "nLevel", "nFightPower"});
	for _, v in ipairs(tbFile) do
		assert(Partner.tbQualityLevelDes[v.nQuality], "PartnerCard FightPower Valid Quality" .. v.nQuality ..debug.traceback())
		self.nCardFightPower[v.nQuality] = self.nCardFightPower[v.nQuality] or {}
		self.nCardFightPower[v.nQuality][v.nLevel] = v.nFightPower
	end
	self.tbCardUpGrade = {}
	self.nMaxCardLevel = 0
	tbFile = LoadTabFile("Setting/PartnerCard/PartnerCardUpGrade.tab", "ddds", nil, {"nQualityLevel", "nLevel", "nUpGradeExp", "szReturn"});
	for _, v in ipairs(tbFile) do
		for _, tbLevelPower in pairs(self.nCardFightPower) do
			assert(tbLevelPower[v.nLevel], "PartnerCard FightPower No Exist Level" ..v.nLevel ..debug.traceback())
		end
		local tbReturn
		if not Lib:IsEmptyStr(v.szReturn) then
			tbReturn = Lib:GetAwardFromString(v.szReturn)
		end
		-- 返还道具不允许摆摊
		for _, v in ipairs(tbReturn or {}) do
			v[4] = 0
			v[5] = true
		end
		v.tbReturn = tbReturn
		v.szReturn = nil
		self.nMaxCardLevel = math.max(self.nMaxCardLevel, v.nLevel)
		self.tbCardUpGrade[v.nQualityLevel] = self.tbCardUpGrade[v.nQualityLevel] or {}
		self.tbCardUpGrade[v.nQualityLevel][v.nLevel] = v
	end
	self.tbCardSkillDes = {}
	tbFile = LoadTabFile("Setting/PartnerCard/PartnerCardSkillDes.tab", "ds", nil, {"nSkillId", "szSkillDes"});
	for _, v in ipairs(tbFile) do
		self.tbCardSkillDes[v.nSkillId] =  string.gsub(v.szSkillDes, "\\n", "\n")
	end

	self.tbCardCompose = {}
	local szTabPath = "Setting/PartnerCard/PartnerCardCompose.tab";
	local szParamType = "dddsssd";
	local szKey = "nTargetCard";
	local tbParams = {"nTargetCard", "nNeedLevel", "nMainNpc", "szAward", "szIntro", "szName", "nShowItem"};
	local nMaxClu = 5
	local nMaxChild = 0
	for i=1, nMaxClu do
		szParamType = szParamType .."d";
		table.insert(tbParams, "nChildCard" ..i);
	end
	for i=1, nMaxClu do
		szParamType = szParamType .."ss";
		table.insert(tbParams, "szDetail" ..i);
		table.insert(tbParams, "szCheckDetail" ..i);
	end
	tbFile = LoadTabFile(szTabPath, szParamType, szKey, tbParams);
	for nTargetCard, v in pairs(tbFile) do
		self.tbCardCompose[nTargetCard] = {}
		assert(v.nNeedLevel > 1, string.format("PartnerCard Compose Invalid Need Level %d : %d", nTargetCard, v.nNeedLevel))
		self.tbCardCompose[nTargetCard].nNeedLevel = v.nNeedLevel
		assert(v.nMainNpc > 0, string.format("PartnerCard Compose Error MainNpc , TargetCard : %d", nTargetCard))
		self.tbCardCompose[nTargetCard].nMainNpc = v.nMainNpc
		self.tbCardCompose[nTargetCard].tbChild = {}
		self.tbCardCompose[nTargetCard].tbDetail = {}
		self.tbCardCompose[nTargetCard].nShowItem = v.nShowItem
		for i=1, nMaxClu do
			local nChildCard = v["nChildCard" ..i]
			if nChildCard > 0 then
				assert(self.tbCardSetting[nChildCard].nNpcNoTurnTempleteId > 0, string.format("PartnerCard Compose Err Npc %s_%s", nTargetCard, nChildCard))
				table.insert(self.tbCardCompose[nTargetCard].tbChild, nChildCard)
			end
		end
		nMaxChild = math.max(nMaxChild, #self.tbCardCompose[nTargetCard].tbChild)
		assert(next(self.tbCardCompose[nTargetCard].tbChild), string.format("PartnerCard Compose Invalid Child %d ", nTargetCard))
		local tbAward 
		if not Lib:IsEmptyStr(v.szAward) then
			tbAward = Lib:GetAwardFromString(v.szAward)
		end
		self.tbCardCompose[nTargetCard].tbAward = tbAward
		self.tbCardCompose[nTargetCard].szIntro = string.gsub(v.szIntro, "\\n", "\n")
		self.tbCardCompose[nTargetCard].szName = v.szName
		for i=1, nMaxClu do
			local szDetail = v["szDetail" ..i]
			local szDetailCheck = v["szCheckDetail" ..i]
			if not Lib:IsEmptyStr(szDetail) and not Lib:IsEmptyStr(szDetailCheck) then
				local nChildCard
				if szDetailCheck == "CheckLevel" then
					nChildCard = self.tbCardCompose[nTargetCard].tbChild[i]
					assert(nChildCard, "PartnerCard Compose Detail Err " .. nTargetCard .. i)
					szDetail = string.gsub(szDetail, "\\n", "\n")
				end
				table.insert(self.tbCardCompose[nTargetCard].tbDetail, {szDetail, szDetailCheck, {nChildCard}})
			end
		end
		assert(next(tbAward), string.format("PartnerCard Compose Not Award. nCardId : %s", nTargetCard))
	end
	assert(nMaxChild <= #self.tbComposeNpcOffset, string.format("PartnerCard Error Offset MaxChild: %s OffsetCount: %s", nMaxChild, #self.tbComposeNpcOffset))
end

PartnerCard:LoadSetting()

function PartnerCard:GetComposeInfo(nCardId)
	return self.tbCardCompose[nCardId]
end

function PartnerCard:CheckComposeOpen()
	return not PartnerCard.bCloseCompose
end

function PartnerCard:IsCardBelongItem(pPlayer, nBelongCardId, nItemId)
	local tbCard = PartnerCard:GetBelongCardIdOwn(pPlayer, nItemId)
	for _, nCardId in pairs(tbCard) do
		if nCardId == nBelongCardId then
			return true
		end
	end
	return false
end

function PartnerCard:GetBelongCardIdOwn(pPlayer, nItemTemplateId)
	local tbCard = {}
	local tbSeqBelongCard = PartnerCard.tbCardGift[nItemTemplateId] and PartnerCard.tbCardGift[nItemTemplateId].tbSeqBelongCard
	for _, nCardId in ipairs(tbSeqBelongCard or {}) do
		if PartnerCard:IsHaveCard(pPlayer, nCardId) then
			table.insert(tbCard, nCardId)
		end
	end
	return tbCard
end

function PartnerCard:CanComposeCard(pPlayer, nCardId, bCheckCard)
	if not PartnerCard:IsOpen() then
		return false, "暂未开放"
	end
	if not PartnerCard:CheckComposeOpen() then
		return false, "暂未开放合成系统"
	end
	local tbCardInfo = self:GetCardInfo(nCardId)
	if not tbCardInfo then
		return false, "未知门客"
	end
	local tbComposeInfo = self:GetComposeInfo(nCardId)
	if not tbComposeInfo then
		return false, "无法合成"
	end
	if not bCheckCard and not House:IsInOwnHouse(pPlayer) then
		return false, "在自己家园才可操作"
	end
	local tbChild = tbComposeInfo.tbChild
	local nNeedLevel = tbComposeInfo.nNeedLevel
	local nMapId, nX, nY = pPlayer.GetWorldPos()
	local bCanUse = CheckBarrier(nMapId, nX, nY);
	if not bCheckCard and not bCanUse then
		return false, "请找个无障碍的地方合成"
	end
	local bCanPut, szMsg = Decoration:CheckCanUseDecoration(nMapId, nX, nY, nil, PartnerCard.nComposeNpcFurnitureId, true)
	if not bCheckCard and not bCanPut then
		return false, "请找个无障碍的地方合成"
	end
	for nIdx, nChildCard in ipairs(tbChild) do
		local tbCardInfo = self:GetCardInfo(nChildCard)
		if not tbCardInfo then
			return false, "未知门客"
		end
		if not PartnerCard:IsHaveCard(pPlayer, nChildCard) then
			return false, "请先集齐"
		end
		local nCurLevel = self:GetCardSaveInfo(pPlayer, nChildCard, LEVEL_IDX_STEP)
		if nCurLevel < nNeedLevel then
			return false, string.format("要求门客%s达到%d级", tbCardInfo.szName, nNeedLevel)
		end
		if PartnerCard:IsCardLiveHouse(pPlayer, nChildCard) then
			return false, string.format("门客%s不能入住家园", tbCardInfo.szName)
		end
		local tbOffset = self.tbComposeNpcOffset[nIdx] or {}
		if not next(tbOffset) then
			return false, "没有门客偏移？？"
		end
		local nNpcX = nX + tbOffset[1]
		local nNpcY = nY + tbOffset[2]
		bCanUse = CheckBarrier(nMapId, nNpcX, nNpcY);
		if not bCheckCard and not bCanUse then
			return false, "请找个无障碍的地方合成"
		end

	end
	local tbComposeData = PartnerCard:GetComposeData(pPlayer.dwID)
	if not tbComposeData then
		return false, "请先拥有家园"
	end
	if not bCheckCard and PartnerCard:IsCardComposeState(pPlayer.dwID, nCardId) then
		return false, "已有相同的门客正在合成"
	end
	if not bCheckCard and PartnerCard:CheckComposeConflict(pPlayer.dwID, nCardId) then
		return false, "门客忙碌中"
	end
	return true, "", nX, nY
end

function PartnerCard:ComposeCheckLevel(pPlayer, nCardId, nCheckCardId)
	local tbComposeInfo = self:GetComposeInfo(nCardId)
	if not tbComposeInfo then
		return false
	end
	local tbChild = tbComposeInfo.tbChild
	local nNeedLevel = tbComposeInfo.nNeedLevel
	local bRet = false
	for nIdx, nChildCard in ipairs(tbChild) do
		if nChildCard == nCheckCardId then
			local tbCardInfo = self:GetCardInfo(nChildCard)
			if not tbCardInfo then
				return false
			end
			if not PartnerCard:IsHaveCard(pPlayer, nChildCard) then
				return false
			end
			local nCurLevel = self:GetCardSaveInfo(pPlayer, nChildCard, LEVEL_IDX_STEP)
			if nCurLevel < nNeedLevel then
				return false
			end
			bRet = true
		end
	end
	return bRet
end

function PartnerCard:ComposeCheckLive(pPlayer, nCardId)
	local tbComposeInfo = self:GetComposeInfo(nCardId)
	if not tbComposeInfo then
		return false
	end
	local tbChild = tbComposeInfo.tbChild
	local nNeedLevel = tbComposeInfo.nNeedLevel
	for nIdx, nChildCard in ipairs(tbChild) do
		local tbCardInfo = self:GetCardInfo(nChildCard)
		if not tbCardInfo then
			return false
		end
		if not PartnerCard:IsHaveCard(pPlayer, nChildCard) then
			return false
		end
		if PartnerCard:IsCardLiveHouse(pPlayer, nChildCard) then
			return false
		end
	end
	return true
end

function PartnerCard:CheckComposeConflict(dwID, nCardId)
	local tbComposeData = PartnerCard:GetComposeData(dwID)
	if not tbComposeData then
		return false
	end
	local tbRelateCard = {}
	for nId, v in pairs(tbComposeData) do
		if PartnerCard:IsCardComposeState(dwID, nId) then
			local tbComposeInfo = PartnerCard:GetComposeInfo(nId)
			if tbComposeInfo then
				local tbChild = tbComposeInfo.tbChild or {}
				for _, nChildCard in ipairs(tbChild) do
					tbRelateCard[nChildCard] = true
				end
			end
		end
	end
	local tbComposeInfo = PartnerCard:GetComposeInfo(nCardId)
	if not tbComposeInfo then
		return false
	end
	local tbChild = tbComposeInfo.tbChild or {}
	for _, nChildCard in ipairs(tbChild) do
		if tbRelateCard[nChildCard] then
			return true
		end
	end
	return false
end

function PartnerCard:GetComposeNpcByCardId(nCardId)
	local tbCardInfo = self:GetCardInfo(nCardId)
	return tbCardInfo and tbCardInfo.nNpcNoTurnTempleteId
end

function PartnerCard:CheckFinishComposeCard(pPlayer, nCardId, bNotCheckTime)
	if not PartnerCard:IsOpen() then
		return false, "暂未开放"
	end
	if not PartnerCard:CheckComposeOpen() then
		return false, "暂未开放合成系统"
	end
	local tbCardInfo = self:GetCardInfo(nCardId)
	if not tbCardInfo then
		return false, "未知门客"
	end
	local tbComposeData = PartnerCard:GetComposeData(pPlayer.dwID)
	if not tbComposeData then
		return false, "请先建造家园"
	end
	local tbCardCompose = tbComposeData[nCardId]
	if not tbCardCompose then
		return false, "请先请求合成"
	end
	local nApplyComposeTime = tbCardCompose.nComposeTime or 0
	if nApplyComposeTime <= 0 then
		return false, "请先请求合成"
	end
	local nNowTime = GetTime()
	if not bNotCheckTime and nApplyComposeTime + PartnerCard.CARD_COMPOSE_TIME > nNowTime then
		return false, "时间未到，请耐心等待"
	end
	local tbComposeInfo = PartnerCard:GetComposeInfo(nCardId)
	if not tbComposeInfo then
		return false, "无法合成"
	end
	local tbChild = tbComposeInfo.tbChild
	local nNeedLevel = tbComposeInfo.nNeedLevel
	for _, nChildCard in ipairs(tbChild) do
		local tbCardInfo = self:GetCardInfo(nChildCard)
		if not tbCardInfo then
			return false, "未知门客"
		end
		if not PartnerCard:IsHaveCard(pPlayer, nChildCard) then 
			return false, "请先集齐"
		end
		local nCurLevel = self:GetCardSaveInfo(pPlayer, nChildCard, LEVEL_IDX_STEP)
		if nCurLevel < nNeedLevel then
			return false, string.format("要求门客%s达到%d级", tbCardInfo.szName, nNeedLevel)
		end
	end

	return true, nil, tbComposeInfo
end

function PartnerCard:GetLevelNeedExp(nCardId, nNeedLevel)
	local nNeedExp = 0
	local nQualityLevel = PartnerCard:GetQualityByCardId(nCardId)
	for nLevel = 1, nNeedLevel - 1 do
		local nExp = self.tbCardUpGrade[nQualityLevel] and self.tbCardUpGrade[nQualityLevel][nLevel] and self.tbCardUpGrade[nQualityLevel][nLevel].nUpGradeExp
		nNeedExp = nNeedExp + (nExp or 0)
	end
	return nNeedExp
end

function PartnerCard:GetCardAllExp(pPlayer, nCardId)
	local nCurLevel = self:GetCardSaveInfo(pPlayer, nCardId, LEVEL_IDX_STEP)
	local nCurExp = self:GetCardSaveInfo(pPlayer, nCardId, EXP_IDX_STEP)
	local nAllExp = nCurExp
	local nQualityLevel = PartnerCard:GetQualityByCardId(nCardId)
	for nLevel = nCurLevel - 1, 1, -1 do 
		local nExp = self.tbCardUpGrade[nQualityLevel] and self.tbCardUpGrade[nQualityLevel][nLevel] and self.tbCardUpGrade[nQualityLevel][nLevel].nUpGradeExp
		nAllExp = nAllExp + (nExp or 0)
		
	end
	return nAllExp
end

function PartnerCard:GetCardCurMaxOpenLevel()
	local szTimeFrame = Lib:GetMaxTimeFrame(PartnerCard.tbTimeFrameMaxOpenLevel)
	local nMaxLevel = PartnerCard.tbTimeFrameMaxOpenLevel[szTimeFrame] or 1
	return nMaxLevel
end

function PartnerCard:RemainCanSendExp(pPlayer, nCardId, nExp)
	nExp = nExp or 0
	local nAllExp = PartnerCard:GetCardAllExp(pPlayer, nCardId)
	local nCurMaxLevel = PartnerCard:GetCardCurMaxOpenLevel()
	local nAllCanSendExp = PartnerCard:GetLevelNeedExp(nCardId, nCurMaxLevel)
	local nCanSendExp = nAllCanSendExp - nAllExp - nExp
	return nCanSendExp
end

function PartnerCard:CheckCanSendExp(pPlayer, nCardId, nItemId, nCount, nPerExp)
	local nRemainCanSendExp = PartnerCard:RemainCanSendExp(pPlayer, nCardId, nCount * nPerExp)
	-- 在未满的情况下至少允许再送一个
	nRemainCanSendExp = nRemainCanSendExp + nPerExp
	local bBelongCardItem = PartnerCard:IsCardBelongItem(pPlayer, nCardId, nItemId)
	if nRemainCanSendExp <= 0 and not bBelongCardItem then
		return false, "已达当前开放的最高星级，不能赠送通用礼物，只能赠送该门客特有礼物"
	end
	return true
end

function PartnerCard:GetExpUpgradeInfo(nCardId, nAllExp, nCurLevel)
	local nLevel = 1
	local nExp = 0
	local nQualityLevel = PartnerCard:GetQualityByCardId(nCardId)
	local tbExp = self.tbCardUpGrade[nQualityLevel]
	if not tbExp then
		return 
	end
	for nUpgradeLevel, v in ipairs(tbExp) do
		if nAllExp < v.nUpGradeExp or nAllExp <= 0 or nLevel >= nCurLevel then
			break
		end
		nLevel = nUpgradeLevel + 1
		nAllExp = nAllExp - v.nUpGradeExp
	end
	nExp = math.max(nAllExp, 0)
	return nLevel, nExp
end

-- 门客是否正在参与合成
function PartnerCard:ComposeWorking(dwID, nCardId)
	local tbComposeData = PartnerCard:GetComposeData(dwID)
	if not tbComposeData then
		return false
	end
	for nId, v in pairs(tbComposeData) do
		local nComposeTime = v.nComposeTime or 0
		if nComposeTime > 0 then
			if nId == nCardId then
				return true
			end
			local tbComposeInfo = PartnerCard:GetComposeInfo(nId)
			if tbComposeInfo then
				local tbChild = tbComposeInfo.tbChild
				for _, nChildCard in ipairs(tbChild) do
					if nChildCard == nCardId then
						return true
					end
				end
			end
		end
	end
	return false
end

-- 请求合成后还没手动结束合成（就是家园中还会有npc表现,合成中或者已完成还没确认）
function PartnerCard:IsCardComposeState(dwID, nCardId)
	local tbComposeData = PartnerCard:GetComposeData(dwID)
	if not tbComposeData then
		return 
	end
	local tbCardCompose = tbComposeData[nCardId]
	if not tbCardCompose then
		return
	end
	local nComposeTime = tbCardCompose.nComposeTime or 0
	return nComposeTime ~= 0
end

-- 正在等待合成时间区间内
function PartnerCard:IsCardComposing(dwID, nCardId)
	local tbComposeData = PartnerCard:GetComposeData(pPlayer.dwID)
	if not tbComposeData then
		return 
	end
	local tbCardCompose = tbComposeData[nCardId]
	if not tbCardCompose then
		return
	end
	local nComposeTime = tbCardCompose.nComposeTime or 0
	local nNowTime = GetTime()
	return nNowTime < nComposeTime + PartnerCard.CARD_COMPOSE_TIME 
end

function PartnerCard:IsLevelOpen(nLevel)
	local szOpenTimeFrame = self.tbLevelTimeFrame[nLevel]
	if szOpenTimeFrame then
		return GetTimeFrameState(szOpenTimeFrame) == 1
	end
end

function PartnerCard:CheckCardOpen(nCardId)
	local nQuality = PartnerCard:GetQualityByCardId(nCardId)
	local szOpenTimeFrame = self.tbPartnerLevelOutPut[nQuality]
	if szOpenTimeFrame then

		return GetTimeFrameState(szOpenTimeFrame) == 1
	else
		return true
	end
end

function PartnerCard:CheckCanRepeatAdd(pPlayer, nCardId)
	local tbCardInfo = self:GetCardInfo(nCardId)
	if not tbCardInfo then
		return false
	end
	local nQuality = PartnerCard:GetQualityByCardId(nCardId)
	if nQuality > PartnerCard.nRepeatAddQuality then
		local nHas = pPlayer.GetUserValue(Partner.PARTNER_HAS_GROUP, tbCardInfo.nPartnerTempleteId);
		return nHas == 1
	else
		local nGetFlag = PartnerCard:GetCardSaveInfo(pPlayer, nCardId, PartnerCard.nGetFlagIdxStep)
		return nGetFlag > 0
	end 
	return false
end

-- 返回所有已上阵门客的信息
function PartnerCard:GetOnPosCardInfo(pPlayer, pPlayerAsync)
	local tbOnPosCardInfo = {}
	if pPlayer then
		tbOnPosCardInfo = self:GetOnPosCardInfoByPlayer(pPlayer)
	elseif pPlayerAsync then
		tbOnPosCardInfo = self:GetOnPosCardInfoByAsynData(pPlayerAsync)
	end
	return tbOnPosCardInfo
end

-- 存玩家身上的上阵信息
function PartnerCard:GetOnPosCardInfoByPlayer(pPlayer)
	local tbOnPosCardInfo = {}
	for nCardId in pairs(self.tbCardSetting) do
		local nLevel = 0
		local bHasCard = self:IsHaveCard(pPlayer, nCardId)
		local nCardPos = self:GetCardSaveInfo(pPlayer, nCardId, ON_POS_IDX_STEP)
		if bHasCard and nCardPos > 0 then
			nLevel = self:GetCardSaveInfo(pPlayer, nCardId, LEVEL_IDX_STEP)
		end
		if nLevel > 0 then
			tbOnPosCardInfo[nCardPos] = {}
			tbOnPosCardInfo[nCardPos].nLevel = nLevel
			tbOnPosCardInfo[nCardPos].nCardId = nCardId
		end
	end
	return tbOnPosCardInfo
end

-- 存异步数据的上阵信息
function PartnerCard:GetOnPosCardInfoByAsynData(pPlayerAsync)
	local tbOnPosCardInfo = {}
	for nCardPos in pairs(self.tbCardPosSetting) do
		local nCardId = self:GetAsynPosSaveInfo(pPlayerAsync, nCardPos, PARTNER_CARD_POS_CARD_ID_IDX_STEP) or 0
		local nLevel = self:GetAsynPosSaveInfo(pPlayerAsync, nCardPos, PARTNER_CARD_POS_CARD_LEVEL_IDX_STEP) or 0
		if nCardId > 0 and nLevel > 0 then
			tbOnPosCardInfo[nCardPos] = {}
			tbOnPosCardInfo[nCardPos].nLevel = nLevel
			tbOnPosCardInfo[nCardPos].nCardId = nCardId
		end
	end
	return tbOnPosCardInfo
end

-- 所有上阵的同伴给玩家加属性
function PartnerCard:UpdatePlayerAttribute(pPlayer)
	-- 先移除所有属性
	for nAttribGroup in pairs(self.tbAllAttrib) do
		pPlayer.RemoveExternAttrib(nAttribGroup);
	end
	local tbOnPosCardInfo = self:GetOnPosCardInfo(pPlayer)
	self:ApplyAttrib(pPlayer, tbOnPosCardInfo)
	self:UpdatePlayerSuitAttribute(pPlayer, tbOnPosCardInfo)
	local tbApplySkill, tbRepeatSkillCard = {}, {} 
	if MODULE_GAMESERVER then
		local pNpc = pPlayer.GetNpc()
		if pNpc then
			for nSkillId in pairs(self.tbAllSkill) do
				pNpc.RemoveFightSkill(nSkillId);
			end
			tbApplySkill, tbRepeatSkillCard = PartnerCard:GetApplySkill(pPlayer, tbOnPosCardInfo)
		
			self:ApplySkill(pNpc, tbApplySkill)
		end
		-- 每次把应用的技能存到异步数据
		--PartnerCard:SaveAsynSkillData(pPlayer, tbApplySkill)
		pPlayer.CallClientScript("PartnerCard:UpdatePlayerAttributeC");
	end
	return tbRepeatSkillCard
end

-- function PartnerCard:GetApplySkillByAsyncData(pPlayerAsync)
-- 	local tbApplySkill = {}
-- 	local nCount = 0
-- 	for nPos = 1, 4 do
-- 		local nSkillId = pPlayerAsync.GetAsyncBattleValue(PartnerCard.PARTNER_CARD_SKILL_BEGINE_SAVE_ID + nCount * 2) or 0
-- 		local nSkillLevel = pPlayerAsync.GetAsyncBattleValue(PartnerCard.PARTNER_CARD_SKILL_BEGINE_SAVE_ID + nCount * 2 + 1) or 0
-- 		if nSkillId > 0 and nSkillLevel > 0 then
-- 			tbApplySkill[nSkillId] = nSkillLevel
-- 		end
-- 		nCount = nCount + 1
-- 	end
-- 	return tbApplySkill
-- end

function PartnerCard:GetPartnerInfo(pPlayer, pPlayerAsync)
	local tbInfo = {}
	if pPlayer then
		local tbPosInfo = pPlayer.GetPartnerPosInfo();
        for nPos = 1, Partner.MAX_PARTNER_POS_COUNT do
			tbInfo[nPos] = tbInfo[nPos] or {}
			local nPartnerId = tbPosInfo[nPos]
			if nPartnerId > 0 then
				local pPartner = pPlayer.GetPartnerObj(nPartnerId);
				if pPartner then
					tbInfo[nPos].nTemplateId = pPartner.nTemplateId
					tbInfo[nPos].nFightPower = pPartner.nFightPower
				end
			end
		end
    elseif pPlayerAsync then
    	for nPos = 1, Partner.MAX_PARTNER_POS_COUNT do
    		tbInfo[nPos] = tbInfo[nPos] or {}
    		local nTemplateId, nLevel, nFightPower = pPlayerAsync.GetPartnerInfo(nPos)
    		if nTemplateId then
    			tbInfo[nPos].nTemplateId = nTemplateId
				tbInfo[nPos].nFightPower = nFightPower
    		end
    	end
	end
	
	return tbInfo
end

-- 返回生效的护主技能，相同技能的等级取较高的
function PartnerCard:GetApplySkill(pPlayer, tbOnPosCardInfo, pPlayerAsync)
	local tbApplySkill = {}
	local tbApplyUniqSkill = {} 					-- 唯一属性技能，控制该项属性取较高技能等级
	local tbPosApplySkill = {}
	local tbOnPosCardInfo = tbOnPosCardInfo or self:GetOnPosCardInfo(pPlayer, pPlayerAsync)
	local tbPosInfo = PartnerCard:GetPartnerInfo(pPlayer, pPlayerAsync)
	local tbRepeatSkillCard = {}
	for nPos = 1, Partner.MAX_PARTNER_POS_COUNT do
		local tbPartnerInfo = tbPosInfo[nPos] or {}
		if next(tbPartnerInfo) then
			local nPartnerTId = tbPartnerInfo.nTemplateId or 0
			local nFightPower = tbPartnerInfo.nFightPower or 0
			local nProtectSkillLevel = Partner:GetPartnerSkillLevelByFightPower(nFightPower) or 0
			local nUniqProtectSkillLevel = nProtectSkillLevel
			for nCardPos, v in pairs(tbOnPosCardInfo) do
				local tbCardInfo = self.tbCardSetting[v.nCardId] or {}
				local nLevel = v.nLevel or 0
				local tbCardPosInfo = self.tbCardPosSetting[nCardPos] or {}
				local nPartnerPos = tbCardPosInfo.nPartnerPos or 0
				local nSkillPartnerTId = tbCardInfo.nPartnerTempleteId or 0
				local nSkillId = tbCardInfo.nExtPartnerSkillId or 0
				local tbUniqueSkillId = tbCardInfo.tbUniquePartnerSkillId or {}
				if nPartnerTId > 0 and nSkillId > 0 and nSkillPartnerTId == nPartnerTId 
					and (nPartnerPos > 0 and nPartnerPos <= Partner.MAX_PARTNER_POS_COUNT) 
					and (nPos == nPartnerPos) and nLevel > 0 and nProtectSkillLevel > 0 then
					local nOldProtectSkillLevel = tbApplySkill[nSkillId]
					-- 技能相同时，取较大的护主技能等级
					if nOldProtectSkillLevel then
						if nProtectSkillLevel < nOldProtectSkillLevel then
						   nProtectSkillLevel = nOldProtectSkillLevel
						end
					end
					tbApplySkill[nSkillId] = nProtectSkillLevel

					for _, nUniqSkillId in ipairs(tbUniqueSkillId) do
						local nOldUniqSkillLevel = tbApplyUniqSkill[nUniqSkillId]
						if nOldUniqSkillLevel then
							if nUniqProtectSkillLevel < nOldUniqSkillLevel then
								nUniqProtectSkillLevel = nOldUniqSkillLevel
							end
							tbRepeatSkillCard[v.nCardId] = {nPartnerTempleteId = nSkillPartnerTId, nSkillId = nUniqSkillId, nProtectSkillLevel = nProtectSkillLevel}
						end
						tbApplyUniqSkill[nUniqSkillId] = nUniqProtectSkillLevel
					end
				end
			end
		end
	end

	local tbSkill = {}
	local tbData = {tbApplySkill, tbApplyUniqSkill}
	for _, v in pairs(tbData) do
		for nId, nLevel in pairs(v) do
			table.insert(tbSkill, {nSkillId = nId, nSkillLevel = nLevel})
		end
	end
	return tbSkill, tbRepeatSkillCard, tbApplySkill
end

function PartnerCard:ApplySkill(pNpc, tbSkill)
	tbSkill = tbSkill or {}
	for _, v in ipairs(tbSkill) do
		pNpc.AddFightSkill(v.nSkillId, v.nSkillLevel)
	end
end

function PartnerCard:UpdatePlayerSuitAttribute(pTarget, tbOnPosCardInfo)
	local tbAllApplyAttrib = {}
	local tbAttrib = self:GetOnPosActiveSuitAttrib(tbOnPosCardInfo)
	for nPartnerPos, tbAttrib in pairs(tbAttrib) do
		for _, v in ipairs(tbAttrib) do
			local nAttribGroup, nSuitLevel = unpack(v)
			if tbAllApplyAttrib[nAttribGroup] then
				Log("PartnerCard fnUpdatePlayerSuitAttribute Same Attrib!!", pTarget.szName, nAttribGroup, nPartnerPos)
			else
				pTarget.ApplyExternAttrib(nAttribGroup, nSuitLevel)
				tbAllApplyAttrib[nAttribGroup] = true
			end
		end
	end
end

-- 所有上阵的同伴给异步数据玩家加属性
function PartnerCard:UpdateAsyncPlayerAttribute(pPlayerAsync, pNpc)
	local tbOnPosCardInfo = self:GetOnPosCardInfo(nil, pPlayerAsync)
	self:ApplyAttrib(pNpc, tbOnPosCardInfo)
	self:UpdatePlayerSuitAttribute(pNpc, tbOnPosCardInfo)
	local tbApplySkill = PartnerCard:GetApplySkill(nil, nil, pPlayerAsync)
	self:ApplySkill(pNpc, tbApplySkill)
	pNpc.RestoreHP();
end

function PartnerCard:ApplyAttrib(pTarget, tbInfo)
	for _, v in pairs(tbInfo or {}) do
		local nCardId = v.nCardId
		local nAttribLevel = v.nLevel or 0
		local tbCardInfo = self.tbCardSetting[v.nCardId]
		local nExtAttribId = tbCardInfo and tbCardInfo.nExtAttribId
		if nExtAttribId and nAttribLevel > 0 then
			pTarget.ApplyExternAttrib(nExtAttribId, nAttribLevel);
		end
	end
end

-- 返回激活的护主技能id
function PartnerCard:GetActiveSkillId(pPlayer, nPartnerTempleteId, nPos, pPlayerAsync)
	if not nPartnerTempleteId or not nPos then
		return
	end
	local tbSkillId = {}
	local tbOnPosCardInfo = self:GetOnPosCardInfo(pPlayer, pPlayerAsync);
	for nCardPos, v in pairs(tbOnPosCardInfo) do
		local tbCardInfo = self.tbCardSetting[v.nCardId] or {}
		local nLevel = v.nLevel or 0
		local tbCardPosInfo = self.tbCardPosSetting[nCardPos] or {}
		local nPartnerPos = tbCardPosInfo.nPartnerPos or 0
		local nSkillPartnerTId = tbCardInfo.nPartnerTempleteId or 0
		local nSkillId = tbCardInfo.nExtPartnerSkillId or 0
		local tbUniqueSkillId = tbCardInfo.tbUniquePartnerSkillId or {}
		if nPartnerTempleteId > 0 and nSkillId > 0 and nSkillPartnerTId == nPartnerTempleteId 
			and (nPartnerPos > 0 and nPartnerPos <= Partner.MAX_PARTNER_POS_COUNT) 
			and (nPos and nPos == nPartnerPos) and nLevel > 0 then
			tbSkillId = {nSkillId}
			return Lib:MergeTable(tbSkillId, tbUniqueSkillId)
		end
	end
end

function PartnerCard:GetPartnerPosByPTId(pPlayer, pPlayerAsync, nPartnerTempleteId)
	local tbPosInfo = PartnerCard:GetPartnerInfo(pPlayer, pPlayerAsync)
	for nPos, v in pairs(tbPosInfo) do
		if v.nTemplateId and v.nTemplateId == nPartnerTempleteId then
			return nPos
		end
	end

end

-- 返回激活的护主技能id
function PartnerCard:GetActiveSkillIdByPTId(pPlayer, pPlayerAsync, nPartnerTempleteId)
	local nPos =  PartnerCard:GetPartnerPosByPTId(pPlayer, pPlayerAsync, nPartnerTempleteId)
	if not nPos then
		return
	end
	return PartnerCard:GetActiveSkillId(pPlayer, nPartnerTempleteId, nPos, pPlayerAsync)
end

-- 创建同伴的时候给同伴加护主技能(护主技能加玩家身上)
-- function PartnerCard:OnCreatePartnerNpc(nNpcId, nPartnerTempleteId, nProtectSkillLevel, bNotWait)
-- 	if not bNotWait then
-- 		-- 此时 MasterNpcId还没有设置，所以要延迟下才进行更新数据
-- 		Timer:Register(2, function ()
-- 			self:OnCreatePartnerNpc(nNpcId, nPartnerTempleteId, nProtectSkillLevel, true);
-- 		end);
-- 		return;
-- 	end
-- 	local pNpc = KNpc.GetById(nNpcId);
-- 	if not pNpc or pNpc.nMasterNpcId <= 0 then
-- 		return;
-- 	end
-- 	local pMasterNpc = KNpc.GetById(pNpc.nMasterNpcId);
-- 	if not pMasterNpc then
-- 		return;
-- 	end
-- 	local nPlayerId = pMasterNpc.dwPlayerID;
-- 	if nPlayerId <= 0 and pMasterNpc.GetPlayerIdSaveInNpc then
-- 		nPlayerId = pMasterNpc.GetPlayerIdSaveInNpc();
-- 	end
-- 	if nPlayerId <= 0 then
-- 		return;
-- 	end 
-- 	local pAsyncData = KPlayer.GetAsyncData(nPlayerId);
-- 	if not pAsyncData then
-- 		return;
-- 	end
-- 	local tbPartnerPosMap = self:GetPartnerPosMap(pAsyncData)
-- 	-- 当前同伴的上阵位
-- 	local nPos = tbPartnerPosMap[nPartnerTempleteId]
-- 	local tbOnPosCardInfo = {}
-- 	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
-- 	if not MODULE_ZONESERVER and pPlayer then
-- 		tbOnPosCardInfo = self:GetOnPosCardInfo(pPlayer);
-- 	else
-- 		tbOnPosCardInfo = self:GetOnPosCardInfo(nil, pAsyncData);
-- 	end
-- 	for nCardPos, v in pairs(tbOnPosCardInfo) do
-- 		local tbCardInfo = self.tbCardSetting[v.nCardId] or {}
-- 		local nLevel = v.nLevel or 0
-- 		local tbCardPosInfo = self.tbCardPosSetting[nCardPos] or {}
-- 		local nPartnerPos = tbCardPosInfo.nPartnerPos or 0
-- 		local nSkillPartnerTId = tbCardInfo.nPartnerTempleteId or 0
-- 		local nSkillId = tbCardInfo.nExtPartnerSkillId or 0
-- 		if nPartnerTempleteId > 0 and nSkillId > 0 and nSkillPartnerTId == nPartnerTempleteId 
-- 			and (nPartnerPos > 0 and nPartnerPos <= Partner.MAX_PARTNER_POS_COUNT) 
-- 			and (nPos and nPos == nPartnerPos) and nLevel > 0 then
-- 			pNpc.AddSkillState(nSkillId, nProtectSkillLevel, 3, 10000000);
-- 		end
-- 	end
-- end

function PartnerCard:GetPartnerPosMap(pAsyncData)
	local tbPartner = {}
	for nPos = 1, Partner.MAX_PARTNER_POS_COUNT do
		local nPartnerTemplateId = pAsyncData.GetPartnerInfo(nPos);
		if nPartnerTemplateId and nPartnerTemplateId > 0 then
			tbPartner[nPartnerTemplateId] = nPos
		end
	end
	return tbPartner
end

-- int32位，每1位存一个值，最大256，一共可存32*256个标志位
function PartnerCard:GetCardPosLockUserValueSaveIdx(nCardPos, tbSaveGroup)
	if nCardPos <= 0 or nCardPos > PartnerCard.nMaxCardPos then
		return;
	end

	tbSaveGroup = tbSaveGroup or self.CARD_POS_LOCK_SAVE_GROUP_LIST;

	local nTotalIdx = math.ceil(nCardPos / 32);
	local nBitIdx = nCardPos % 32;
	nBitIdx = nBitIdx == 0 and 32 or nBitIdx;

	local nSaveGroup = math.ceil(nTotalIdx / 255);
	if nSaveGroup > #tbSaveGroup then
		return;
	end
	nSaveGroup = tbSaveGroup[nSaveGroup];

	local nSaveIdx = nTotalIdx % 255;
	nSaveIdx = nSaveIdx == 0 and 255 or nSaveIdx;

	return nSaveGroup, nSaveIdx, nBitIdx - 1, nBitIdx - 1;
end

function PartnerCard:GetCardPosUnlockFlag(pPlayer, nCardPos)
	local nSaveGroup, nSaveIdx, nBitBegin, nBitEnd = self:GetCardPosLockUserValueSaveIdx(nCardPos);
	if not nSaveGroup then
		Log("PartnerCard fnGetCardPosUnlockFlag ERR ?? ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nCardPos, debug.traceback());
		return 0
	end
	local nValue = pPlayer.GetUserValue(nSaveGroup, nSaveIdx);
	return Lib:LoadBits(nValue, nBitBegin, nBitEnd);
end

-- 门客位是否解锁
function PartnerCard:IsCardPosUnlock(pPlayer, nCardPos)
	if not self:IsCardPosOpen(pPlayer, nCardPos) then
		return false
	end
	local tbCost = self:GetCardPosUnlockConsume(nCardPos)
	if tbCost and PartnerCard:GetCardPosUnlockFlag(pPlayer, nCardPos) == 0 then
		return false
	end
	return true
end

-- 是否可以解锁门客位
function PartnerCard:CanUnlockCardPos(pPlayer, nCardPos)
	if not PartnerCard:IsOpen() then
		return false, "还没开放门客功能"
	end
	if not self:IsCardPosOpen(pPlayer, nCardPos) then
		return false, "该门客位暂未开放"
	end
	if PartnerCard:IsCardPosUnlock(pPlayer, nCardPos) then
		return false, "已经解锁了该门客位"
	end
	local tbCost = self:GetCardPosUnlockConsume(nCardPos)
	if tbCost then
		for _, tbInfo in pairs(tbCost) do
			local nType = Player.AwardType[tbInfo[1]];
			if not nType or (nType ~= Player.award_type_item and nType ~= Player.award_type_money) then
				return false, "异常配置";
			end

			if nType == Player.award_type_money then
				if pPlayer.GetMoney(tbInfo[1]) < tbInfo[2] then
					return false, string.format("%s不足", Shop:GetMoneyName(tbInfo[1]), tbInfo[2]);
				end
			elseif nType == Player.award_type_item then
				local nCount = pPlayer.GetItemCountInBags(tbInfo[2]);
				if nCount < tbInfo[3] then
					local szItemName = Item:GetItemTemplateShowInfo(tbInfo[2], pPlayer.nFaction, pPlayer.nSex)
					return false, string.format("%s不足", szItemName, tbInfo[3]), nil, szItemName, tbInfo[3], nCount
				end
			end
		end
	end
	return true, nil, tbCost
end

-- 解锁门客位消耗，没有则不需要消耗解锁
function PartnerCard:GetCardPosUnlockConsume(nCardPos)
	return self.tbCardPosSetting[nCardPos] and self.tbCardPosSetting[nCardPos].tbCost
end

-- 门客位时间轴是否开放
function PartnerCard:IsCardPosOpen(pPlayer, nCardPos)
	if not self:IsOpen() then
		return false
	end
	local tbCardPosInfo = self.tbCardPosSetting[nCardPos]
	if not tbCardPosInfo then
		return false
	end
	local szOpenTimeFrame = self:GetCardPosOpenTimeFrame(tbCardPosInfo)
	if szOpenTimeFrame then
		if GetTimeFrameState(szOpenTimeFrame) ~= 1 then
			return false
		end
	end
	return true
end

function PartnerCard:GetCardPosOpenTimeFrame(tbCardPosInfo)
	local tbLaterCardPosInfo = self:GetLaterCardPosInfo()
	return tbLaterCardPosInfo[tbCardPosInfo.nCardPos] and tbCardPosInfo.szLaterOpenTimeFrame or tbCardPosInfo.szOpenTimeFrame
end

function PartnerCard:GetLaterCardPosInfo()
	return self.tbLaterCardPosInfo or {}
end

function PartnerCard:IsOpen()
	if self.bClose then
		return false
	end
	if GetTimeFrameState(self.szFuncOpenTimeFrame) ~= 1 then
		return false
	end
	return true
end

-- 返回卡id数据保存所在的分组和起始位置
function PartnerCard:GetCardUserValueSaveIdx(nCardId, tbSaveGroup)
	tbSaveGroup = tbSaveGroup or self.CARD_SAVE_GROUP_LIST
	local nMaxCardId = #tbSaveGroup * MAX_PER_GROUP_COUNT
	if nCardId <= 0 or nCardId > nMaxCardId then
		Log("[PartnerCard] fnGetCardUserValueSaveIdx vaild ", nCardId, nMaxCardId)
		return
	end
	local nSaveGroupIdx = math.ceil(nCardId / MAX_PER_GROUP_COUNT)
	local nSaveGroup = tbSaveGroup[nSaveGroupIdx] 													-- 卡数据保存的所在组
	local nSaveIdx = nCardId % MAX_PER_GROUP_COUNT
	nSaveIdx = nSaveIdx == 0 and MAX_PER_GROUP_COUNT or nSaveIdx 									-- 卡ID在所在组的索引（需要注意的是当卡ID为所在组的最大值时nSaveIdx要转换）
	local nBaseIdx = (nSaveIdx - 1) * MAX_SAVE_COUNT_PER 											-- 卡所在组的起始保存位置
	return nSaveGroup, nBaseIdx
end

function PartnerCard:GetAsynPosSaveIdx(nCardPos, nIdxStep)
	if nCardPos > PartnerCard.nMaxCardPos or nIdxStep > PARTNER_CARD_POS_MAX_IDX_STEP or nCardPos < 1 or nIdxStep < 1 then
		Log("PartnerCard fnGetAsynPosSaveIdx Valid ", nCardPos, nIdxStep)
		return
	end
	local nBaseIdx = (nCardPos - 1) * PARTNER_CARD_POS_MAX_IDX_STEP + PARTNER_CARD_POS_BEGINE_SAVE_ID
	return nBaseIdx + nIdxStep
end

function PartnerCard:GetAsynPosSaveInfo(pAsyncData, nCardPos, nIdxStep)
	local nSaveIdx = self:GetAsynPosSaveIdx(nCardPos, nIdxStep)
	if not nSaveIdx then
		return 
	end
	return pAsyncData.GetAsyncBattleValue(nSaveIdx)
end

function PartnerCard:GetCardReturn(nCardId, nLevel)
	local tbCardInfo = self:GetCardInfo(nCardId)
	if not tbCardInfo then
		return
	end
	local _, nQualityLevel = GetOnePartnerBaseInfo(tbCardInfo.nPartnerTempleteId);
	local tbInfo = self.tbCardUpGrade[nQualityLevel] and self.tbCardUpGrade[nQualityLevel][nLevel]
	return tbInfo and tbInfo.tbReturn
end

function PartnerCard:GetDimissReturn(tbAward)
	local tbReturn = {}
	tbAward = tbAward or {}
	for _,v in pairs(tbAward) do
		if v[1] == "item" or v[1] == "Item" then
			local nReturnCount = math.floor(v[3] * PartnerCard.nDimissReturnRate)
			if nReturnCount > 0 then
				local tbItem = Lib:CopyTB(v)
				tbItem[3] = nReturnCount
				tbItem[4] = 0 
				tbItem[5] = true 			-- 返还的道具不允许摆摊
				table.insert(tbReturn, tbItem)
			end
		end
	end
	return tbReturn
end

function PartnerCard:CanDismissCard(pPlayer, nCardId)
	local tbCardInfo = self:GetCardInfo(nCardId)
	if not tbCardInfo then
		return false, "未知门客"
	end
	if not PartnerCard:IsOpen() then
		return false, "还没开放门客功能"
	end
	if not PartnerCard:IsHaveCard(pPlayer, nCardId) then
		return false, string.format("请先招募该同伴%s", tbCardInfo.szName)
	end
	if PartnerCard:IsCardUpPos(pPlayer, nCardId) then
		return false, string.format("门客%s已上阵，不能遣散", tbCardInfo.szName)
	end
	if PartnerCard:IsCardLiveHouse(pPlayer, nCardId) then
		return false, string.format("门客%s已经入住家园，不能遣散", tbCardInfo.szName)
	end
	if PartnerCard:ComposeWorking(pPlayer.dwID, nCardId) then
		return false, string.format("门客%s正在参与合成，不能遣散", tbCardInfo.szName)
	end
	return true, "", tbCardInfo
end

function PartnerCard:GetCardSaveInfo(pPlayer, nCardId, nIdxStep, tbSaveGroup)
	if nIdxStep > MAX_SAVE_COUNT_PER or nIdxStep < 1 then
		return
	end
	local nSaveGroup, nBaseIdx = self:GetCardUserValueSaveIdx(nCardId, tbSaveGroup)
	return pPlayer.GetUserValue(nSaveGroup, nBaseIdx + nIdxStep)
end

function PartnerCard:IsHaveCard(pPlayer, nCardId)
	local nGetTime = nCardId > 0 and PartnerCard:GetCardSaveInfo(pPlayer, nCardId, GET_TIME_IDX_STEP) or 0
	return nGetTime > 0
end

function PartnerCard:GetCardInfo(nCardId)
	return self.tbCardSetting[nCardId]
end

function PartnerCard:GetCardPosInfo(nCardPos)
	return self.tbCardPosSetting[nCardPos]
end

function PartnerCard:CanAddCard(pPlayer, nCardId)
	if not self:IsOpen() then
		return false, "还没开放门客功能"
	end
	local tbCardInfo = self:GetCardInfo(nCardId)
	if not tbCardInfo then
		return false, "没有该门客"
	end
	local bCan = PartnerCard:CheckCanRepeatAdd(pPlayer, nCardId)
	if not bCan then
		return false, "该门客不能通过该种方式招揽"
	end
	local tbCost = self:GetAddCardCost(nCardId)
	if tbCost then
		for _, tbInfo in pairs(tbCost) do
			local nType = Player.AwardType[tbInfo[1]];
			if not nType or (nType ~= Player.award_type_item and nType ~= Player.award_type_money) then
				return false, "异常配置";
			end

			if nType == Player.award_type_money then
				if pPlayer.GetMoney(tbInfo[1]) < tbInfo[2] then
					return false, string.format("%s不足", Shop:GetMoneyName(tbInfo[1]), tbInfo[2]);
				end
			elseif nType == Player.award_type_item then
				local nCount = pPlayer.GetItemCountInBags(tbInfo[2]);
				if nCount < tbInfo[3] then
					local szItemName = Item:GetItemTemplateShowInfo(tbInfo[2], pPlayer.nFaction, pPlayer.nSex)
					return false, string.format("%s不足", szItemName, tbInfo[3]), tbInfo[2];
				end
			end
		end
	end
	return true, nil, tbCost, tbCardInfo.szName
end

function PartnerCard:GetAddCardCost(nCardId)
	return self.tbCardSetting[nCardId] and self.tbCardSetting[nCardId].tbCost
end 

function PartnerCard:CanSendGift(pPlayer, nCardId, nItemId, nCount)
	if not self:IsOpen() then
		return false, "暂未开放"
	end
	if nCount < 1 then
		return false, "数量异常"
	end
	local tbGiftInfo = self.tbCardGift[nItemId]
	if not tbGiftInfo then
		return false, "该道具不支持赠送"
	end
	if not self:IsHaveCard(pPlayer, nCardId) then
		return false, "请先获得该门客"
	end
	local nLevel = PartnerCard:GetCardSaveInfo(pPlayer, nCardId, PartnerCard.nLevelIdxStep)
	if nLevel >= self.nMaxCardLevel then
		return false, "已经达到最大等级,不能赠送"
	end
	local nCanLevel = PartnerCard:CardUpGradeMaxLevel(pPlayer, nCardId)
	if not PartnerCard:IsLevelOpen(nCanLevel) then
		return false, "门客星级已达上限，无法继续赠送礼物"
	end
	if tbGiftInfo.tbBelongCard then
		if not tbGiftInfo.tbBelongCard[nCardId] then
			return false, "该道具不能赠送给该门客"
		end
	end
	local nSendTimes = self:GetCardSendTimes(pPlayer, nCardId)
	if (nSendTimes + nCount) > PartnerCard.nMaxGiftSendTimes then
		return false, "剩余可赠送次数不足"
	end
	local nOrgCount = pPlayer.GetItemCountInAllPos(nItemId);
	local szItemName = Item:GetItemTemplateShowInfo(nItemId, pPlayer.nFaction, pPlayer.nSex)
	if nOrgCount < nCount then
		return false, string.format("您的%s不足", szItemName);
	end
	if PartnerCard:ComposeWorking(pPlayer.dwID, nCardId) then
		return false, string.format("门客正在参与合成，不能送礼")
	end
	return true, nil, tbGiftInfo.nAddExp * nCount, tbGiftInfo.nAddExp
end

-- 当前经验和等级最多能升到几级
function PartnerCard:CardUpGradeMaxLevel(pPlayer, nCardId)
	local nCurLevel = self:GetCardSaveInfo(pPlayer, nCardId, LEVEL_IDX_STEP)
	local nCurExp = self:GetCardSaveInfo(pPlayer, nCardId, EXP_IDX_STEP)
	local nQualityLevel = PartnerCard:GetQualityByCardId(nCardId)
	local tbLevelExp = self.tbCardUpGrade[nQualityLevel]
	if not tbLevelExp then
		return nCurLevel
	end
	if nCurLevel >= self.nMaxCardLevel then
		return nCurLevel
	end
	for i = nCurLevel, self.nMaxCardLevel do
		local nLevelExp = tbLevelExp[i] and tbLevelExp[i].nUpGradeExp or 0
		if nCurExp >= nLevelExp then
			nCurLevel = nCurLevel + 1
			nCurExp = nCurExp - nLevelExp
		else
			break
		end
	end
	return nCurLevel
end

function PartnerCard:CanCardUpGrade(pPlayer, nCardId)
	if not self:IsOpen() then
		return false, "暂未开放"
	end
	local tbCardInfo = self:GetCardInfo(nCardId)
	if not tbCardInfo then
		return false, "未知门客？？"
	end
	if not self:IsHaveCard(pPlayer, nCardId) then
		return false, "请先获得该门客"
	end
	local _, nQualityLevel = GetOnePartnerBaseInfo(tbCardInfo.nPartnerTempleteId);
	local tbLevelExp = self.tbCardUpGrade[nQualityLevel]
	if not tbLevelExp then
		return false, "该门客不能进阶"
	end
	local nCurLevel = self:GetCardSaveInfo(pPlayer, nCardId, LEVEL_IDX_STEP)
	if nCurLevel >= self.nMaxCardLevel then
		return false, "已经达到最大星级"
	end
	local nUpgradeLevel = nCurLevel + 1
	local tbNextLevel = tbLevelExp[nUpgradeLevel]
	if not tbNextLevel then
		return false, "已经无法继续进阶"
	end
	if not PartnerCard:IsLevelOpen(nUpgradeLevel) then
		return false, "已达当前星级上限，无法进阶"
	end
	local tbCurLevel = tbLevelExp[nCurLevel]
	if not tbCurLevel then
		return false, "未知等级？？"
	end
	local nCurExp = self:GetCardSaveInfo(pPlayer, nCardId, EXP_IDX_STEP)
	local nNextLevelNeedExp = tbCurLevel.nUpGradeExp
	if nCurExp < nNextLevelNeedExp then
		return false, "友好度不足,无法进阶"
	end
	if PartnerCard:ComposeWorking(pPlayer.dwID, nCardId) then
		return false, string.format("门客%s正在参与合成，不能升阶", tbCardInfo.szName)
	end
	return true, nil, nUpgradeLevel, nCurExp, nNextLevelNeedExp
end

-- 是否有未上阵的门客
function PartnerCard:IsAllCardOnPos(pPlayer)
	local tbOwnCard = self:GetAllOwnCard(pPlayer)
	for _, v in ipairs(tbOwnCard) do
		local bPos = PartnerCard:IsCardUpPos(pPlayer, v.nCardId)
		if not bPos then
			return false
		end
	end
	return true
end
-- 是否有门客上阵
function PartnerCard:IsHaveCardOnPos(pPlayer)
	local tbOwnCard = self:GetAllOwnCard(pPlayer)
	for _, v in ipairs(tbOwnCard) do
		local bPos = PartnerCard:IsCardUpPos(pPlayer, v.nCardId)
		if bPos then
			return true
		end
	end
end

function PartnerCard:GetAllOwnCard(pPlayer)
	local tbCard = {}
	for nCardId, v in pairs(self.tbCardSetting) do
		if self:IsHaveCard(pPlayer, nCardId) then
			table.insert(tbCard, {
					dwID = nCardId;
					nFaction = 0;
					nLevel = self:GetCardSaveInfo(pPlayer, nCardId, LEVEL_IDX_STEP);
					szName = v.szName;
					nState = 2;
					nPortrait = 0;
					dwKinId = 0;
					szKinName = "";
					nHonorLevel = 0;
					nImity = 0;
					nVipLevel = 0;
					nSex = 0;
					nPartnerTempleteId = v.nPartnerTempleteId;
					nPos = self:GetCardSaveInfo(pPlayer, nCardId, ON_POS_IDX_STEP);
					nGetTime = self:GetCardSaveInfo(pPlayer, nCardId, GET_TIME_IDX_STEP);
					nFightPower = self:GetCardFightPower(pPlayer, nCardId);
					nCardId = nCardId;
					nNpcTemplateId = v.nNpcTempleteId;
				})
		end
	end
	return tbCard
end

function PartnerCard:GetCardFightPower(pPlayer, nCardId, nLevel)
	local nFightPower = 0
	local tbCardInfo = self.tbCardSetting[nCardId]
	if not tbCardInfo then
		return nFightPower
	end
	local nPartnerTempleteId = tbCardInfo.nPartnerTempleteId
	local _, nQualityLevel = GetOnePartnerBaseInfo(nPartnerTempleteId);
	local nLevel = nLevel or self:GetCardSaveInfo(pPlayer, nCardId, LEVEL_IDX_STEP)
	nFightPower = self.nCardFightPower[nQualityLevel] and self.nCardFightPower[nQualityLevel][nLevel]
	return nFightPower or 0
end

function PartnerCard:GetCardFightPowerById(nCardId, nLevel)
	local nFightPower = 0
	local tbCardInfo = self.tbCardSetting[nCardId]
	if not tbCardInfo then
		return nFightPower
	end
	local nPartnerTempleteId = tbCardInfo.nPartnerTempleteId
	local _, nQualityLevel = GetOnePartnerBaseInfo(nPartnerTempleteId);
	return (self.nCardFightPower[nQualityLevel] and self.nCardFightPower[nQualityLevel][nLevel]) or 0
end

-- 返回所有背包里所有可以赠送给门客的道具
function PartnerCard:GetAllCanSendGift(pPlayer, nCardId)
	local tbCanSend = {}
	for nItemId, v in pairs(self.tbCardGift) do
		if not v.tbBelongCard or v.tbBelongCard[nCardId] then
			local nCount = pPlayer.GetItemCountInAllPos(nItemId);
			if nCount > 0 then
				table.insert(tbCanSend, {nGiftType = 0, nItemId = nItemId})
			end
		end
	end
	return tbCanSend
end

function PartnerCard:GetMaxSendTimes()
	return PartnerCard.nMaxGiftSendTimes
end

function PartnerCard:GetItemAddExp(nItemId)
	local tbInfo = self.tbCardGift[nItemId] or {}
	return tbInfo.nAddExp or 0
end

-- function PartnerCard:Test(pPlayer,nTest)
-- 	for i=1, nTest do
-- 		local nSaveGroup, nBaseIdx = self:GetCardUserValueSaveIdx(i, tbSaveGroup)
-- 		if nSaveGroup and nBaseIdx then
-- 			Log(string.format("CardId %d, SaveGroup %d, BaseIdx %d, Level %d, Exp %d",i,nSaveGroup, nBaseIdx, pPlayer.GetUserValue(nSaveGroup, nBaseIdx + LEVEL_IDX_STEP), pPlayer.GetUserValue(nSaveGroup, nBaseIdx + EXP_IDX_STEP)))
-- 		end
-- 	end
-- end

-- 返回各同伴位激活的套装属性
function PartnerCard:GetOnPosActiveSuitAttrib(tbOnPosCardInfo)
	local tbAttrib = {}
	local tbSuitIndexs = {}
	local tbSuitCard = {}
	local tbActiveSuitCard = {}
	for nCardPos, v in pairs(tbOnPosCardInfo or {}) do
		local tbPosInfo = self.tbCardPosSetting[nCardPos] or {}
		local nPartnerPos = tbPosInfo.nPartnerPos or 0
		if nPartnerPos > 0 and nPartnerPos <= Partner.MAX_PARTNER_POS_COUNT then
			tbSuitIndexs[nPartnerPos] = tbSuitIndexs[nPartnerPos] or {}
			tbSuitCard[nPartnerPos] = tbSuitCard[nPartnerPos] or {}
			local tbCardInfo = self.tbCardSetting[v.nCardId] or {}
			local nSuitIdx = tbCardInfo.nSuitIdx or 0
			if nSuitIdx > 0 then
				tbSuitIndexs[nPartnerPos][nSuitIdx] = (tbSuitIndexs[nPartnerPos][nSuitIdx] or 0) + 1
				tbSuitCard[nPartnerPos][nSuitIdx] = tbSuitCard[nPartnerPos][nSuitIdx] or {}
				table.insert(tbSuitCard[nPartnerPos][nSuitIdx], v.nCardId)
			end
		end
	end
	local tbAllAttribGroup = {}
	for nPartnerPos, v in pairs(tbSuitIndexs) do
		tbAttrib[nPartnerPos] = tbAttrib[nPartnerPos] or {}
		tbActiveSuitCard[nPartnerPos] = tbActiveSuitCard[nPartnerPos] or {}
		for nSuitIdx, nCount in pairs(v) do
			local tbSuitInfo = self.tbCardSuit[nSuitIdx]
			if tbSuitInfo then
				for i = #tbSuitInfo, 1, -1 do
					local nActiveNeedNum = tbSuitInfo[i].nActiveNum
					local nAttribGroup = tbSuitInfo[i].nAttrib
					if nActiveNeedNum > 0 and nActiveNeedNum <= nCount and not tbAllAttribGroup[nAttribGroup] then
						table.insert(tbAttrib[nPartnerPos],{nAttribGroup, PartnerCard.nDefaultSuitLevel, nSuitIdx})
						tbAllAttribGroup[nAttribGroup] = true
						tbActiveSuitCard[nPartnerPos][nSuitIdx] = tbSuitCard[nPartnerPos][nSuitIdx]
						break
					end
				end
			end
		end
	end
	return tbAttrib, tbActiveSuitCard
end

-- 根据门客位返回所在的同伴位
function PartnerCard:GetPartnerPosByCardPos(nCardPos)
	local nPartnerPos = self.tbCardPosSetting[nCardPos] and self.tbCardPosSetting[nCardPos].nPartnerPos
	return nPartnerPos or 0
end

-- 门客是否已经上阵
function PartnerCard:IsCardUpPos(pPlayer, nCardId)
	local nCardPos = PartnerCard:GetCardSaveInfo(pPlayer, nCardId, ON_POS_IDX_STEP)
	local nPos = nCardPos > 0 and nCardPos
	return nPos
end

function PartnerCard:IsCardUpPosByAsynData(pPlayerAsync, nCardId)
	local tbOnPosCardInfo = self:GetOnPosCardInfo(nil, pPlayerAsync)
	for nCardPos, v in pairs(tbOnPosCardInfo) do
		if v.nCardId == nCardId then
			return nCardPos
		end
	end
end

-- 门客位上是否有门客
function PartnerCard:IsPosHaveCard(pPlayer, nCardPos)
	local tbOnPosCardInfo = PartnerCard:GetOnPosCardInfo(pPlayer)
	return tbOnPosCardInfo[nCardPos]
end

-- 显示出来的门客位(本身已经按nCardPos从小到大排好序)
function PartnerCard:GetShowCardPos(pPlayer)
	local tbCardPos = {} 						-- 所有时间轴已开放的门客位
	local tbLockOpenCardPos = {} 				-- 所有时间轴已解锁的门客位（如果需要道具已消耗道具解锁）
	local tbUnlockPos = {} 						-- 所有时间轴未开放的门客位（不判断道具消耗）
	local tbCanUsePos = {} 						-- 所有时间轴已解锁的门客位并且没有门客上阵
	local tbOnPosCard = {} 						-- 已经被上阵的门客位
	for nPartnerPos, v in pairs(self.tbPartnerCardPos) do
		tbCardPos[nPartnerPos] = tbCardPos[nPartnerPos] or {}
		tbLockOpenCardPos[nPartnerPos] = tbLockOpenCardPos[nPartnerPos] or {}
		tbUnlockPos[nPartnerPos] = tbUnlockPos[nPartnerPos] or {}
		tbCanUsePos[nPartnerPos] = tbCanUsePos[nPartnerPos] or {}
		tbOnPosCard[nPartnerPos] = tbOnPosCard[nPartnerPos] or {}
		local tbUnLockOpen = {}
		for _, j in ipairs(v) do
			if PartnerCard:IsCardPosUnlock(pPlayer, j.nCardPos) and not self:IsPosHaveCard(pPlayer, j.nCardPos) then
				table.insert(tbCanUsePos[nPartnerPos], j.nCardPos)
			end
			if PartnerCard:IsCardPosUnlock(pPlayer, j.nCardPos) then
				table.insert(tbUnlockPos[nPartnerPos], j.nCardPos)
			end
			if PartnerCard:IsCardPosOpen(pPlayer, j.nCardPos) then
				table.insert(tbCardPos[nPartnerPos], j.nCardPos)
			else
				table.insert(tbLockOpenCardPos[nPartnerPos], j.nCardPos)
			end
			local tbOnPosCardInfo = self:IsPosHaveCard(pPlayer, j.nCardPos)
			if tbOnPosCardInfo then
				table.insert(tbOnPosCard[nPartnerPos], {nCardPos = j.nCardPos, nCardId = tbOnPosCardInfo.nCardId})
			end
		end
	end
	return tbCardPos, tbLockOpenCardPos, tbUnlockPos, tbCanUsePos, tbOnPosCard
end

-- 返回已上阵的门客信息(同伴位为key)
function PartnerCard:GetPartnerOnPosCard(pPlayer, pPlayerAsync)
	local tbCard = {}
	local tbOnPosCardInfo = PartnerCard:GetOnPosCardInfo(pPlayer, pPlayerAsync)
	for nCardPos, v in pairs(tbOnPosCardInfo) do
		local nPartnerPos = self:GetPartnerPosByCardPos(nCardPos)
		tbCard[nPartnerPos] = tbCard[nPartnerPos] or {}
		table.insert(tbCard[nPartnerPos], v)
	end
	return tbCard
end

-- 门客加成的基础属性和护主技能和套装属性<最大数量的>（配置上的属性，无论有没有激活）
function PartnerCard:GetShowCardAttrib(pPlayer, nCardId)
	local tbAttrib = {tbPlayerAttrib = {}; tbPartnerSkill = {}; tbSuitAttrib = {}}
	local tbBaseAttrib = {}
	local tbSkillAttrib = {}
	local tbCardInfo = self:GetCardInfo(nCardId)
	if not tbCardInfo then
		return tbAttrib
	end
	local tbSuitInfo = self.tbCardSuit[tbCardInfo.nSuitIdx] or {}
	local tbMaxSuitInfo = tbSuitInfo[#tbSuitInfo] or {}
	local nSuitAttrib = tbMaxSuitInfo.nAttrib
	local nLevel = PartnerCard:GetCardSaveInfo(pPlayer, nCardId, LEVEL_IDX_STEP)
	nLevel = math.max(nLevel, 1)
	table.insert(tbAttrib.tbPlayerAttrib,  {tbCardInfo.nExtAttribId, nLevel})
	table.insert(tbAttrib.tbPartnerSkill,  {tbCardInfo.nExtPartnerSkillId, 1, nCardId})
	if nSuitAttrib then
		table.insert(tbAttrib.tbSuitAttrib,  {nSuitAttrib, PartnerCard.nDefaultSuitLevel, tbCardInfo.nSuitIdx})
	end
	return tbAttrib
end

function PartnerCard:GetPartnerPosAttrib(pPlayer, nPartnerPos)
	local tbAttrib = {tbPlayerAttrib = {}; tbPartnerSkill = {}; tbSuitAttrib = {}}
	local tbCard = self:GetPartnerOnPosCard(pPlayer)
	local tbPartnerCard = tbCard[nPartnerPos] or {}
	local tbAllAttrib = {}
	for _, v in pairs(tbPartnerCard) do
		local nCardId = v.nCardId or 0
		local tbTempAttrib = self:GetShowCardAttrib(pPlayer, nCardId)
		table.insert(tbAllAttrib, tbTempAttrib)
	end
	return PartnerCard:CombineAttrrib(unpack(tbAllAttrib))
end

-- 同伴位已上阵门客加成的基础属性和护主技能和套装属性(已激活的)
function PartnerCard:GetPartnerPosActiveAttrib(pPlayer, nPartnerPos, pPlayerAsync, tbPartnerInfo)
	local tbAttrib = {tbPlayerAttrib = {}; tbPartnerSkill = {}; tbSuitAttrib = {}}
	local tbCard = self:GetPartnerOnPosCard(pPlayer, pPlayerAsync)
	local tbOnPosCardInfo = PartnerCard:GetOnPosCardInfo(pPlayer, pPlayerAsync)
	local tbPartnerCard = tbCard[nPartnerPos] or {}

	local nPartnerTId 
	local nFightPower 
	if tbPartnerInfo then
		nPartnerTId = tbPartnerInfo[nPartnerPos] and tbPartnerInfo[nPartnerPos].tbPartnerInfo and tbPartnerInfo[nPartnerPos].tbPartnerInfo.nTemplateId
		nFightPower = tbPartnerInfo[nPartnerPos] and tbPartnerInfo[nPartnerPos].tbPartnerInfo and tbPartnerInfo[nPartnerPos].tbPartnerInfo.nFightPower
	else
		local tbPosInfo = pPlayer.GetPartnerPosInfo()
		local nPartnerId = tbPosInfo[nPartnerPos] or 0;
		local tbPartner = pPlayer.GetPartnerInfo(nPartnerId) or {};
		nPartnerTId = tbPartner.nTemplateId or 0
		nFightPower = tbPartner.nFightPower
	end
	nPartnerTId = nPartnerTId or 0
	nFightPower = nFightPower or 0

	local tbSuitAttrib = self:GetOnPosActiveSuitAttrib(tbOnPosCardInfo)
	local tbPartnerPosSuitAttrib = tbSuitAttrib[nPartnerPos] or {}
	Lib:MergeTable(tbAttrib.tbSuitAttrib, tbPartnerPosSuitAttrib)
	for _, v in pairs(tbPartnerCard) do
		local nCardId = v.nCardId
		local nLevel = v.nLevel
		local tbCardInfo = self:GetCardInfo(nCardId)
		if tbCardInfo then
			table.insert(tbAttrib.tbPlayerAttrib,  {tbCardInfo.nExtAttribId, nLevel})
			-- 只有上阵了对应门客位的同伴才会激活同伴的护主技能
			if nPartnerTId ~= 0 and nPartnerTId == tbCardInfo.nPartnerTempleteId then
				local nSkillLevel = Partner:GetPartnerSkillLevelByFightPower(nFightPower)
				table.insert(tbAttrib.tbPartnerSkill,  {tbCardInfo.nExtPartnerSkillId, nSkillLevel, nCardId})
			end
		end
	end
	return tbAttrib
end

-- 返回所有已经激活的基础属性和护主技能和套装属性
function PartnerCard:GetAllActiveAttrib(pPlayer, pPlayerAsync, tbPartnerInfo)
	local tbAllPartnerPosAttrib = {}
	for nPartnerPos = 1, Partner.MAX_PARTNER_POS_COUNT do
		local tbPPAttrib = self:GetPartnerPosActiveAttrib(pPlayer, nPartnerPos, pPlayerAsync, tbPartnerInfo)
		table.insert(tbAllPartnerPosAttrib, tbPPAttrib)
	end
	local tbAttrib = self:CombineAttrrib(unpack(tbAllPartnerPosAttrib))
	return tbAttrib
end

function PartnerCard:CombineAttrrib(...)
	local tbAttrib = {tbPlayerAttrib = {}; tbPartnerSkill = {}; tbSuitAttrib = {}}
	local tbCombine = {...}
	for _, v in pairs(tbCombine) do
		Lib:MergeTable(tbAttrib.tbPlayerAttrib, (v.tbPlayerAttrib or {}))
		Lib:MergeTable(tbAttrib.tbPartnerSkill, (v.tbPartnerSkill or {}))
		Lib:MergeTable(tbAttrib.tbSuitAttrib, (v.tbSuitAttrib or {}))
	end
	return tbAttrib
end

function PartnerCard:GetAttribInfo(tbAttribInfo)
	local tbAllAttrib = {};
	for _, tbInfo in ipairs(tbAttribInfo) do
		local nAttributeID, nLevel = unpack(tbInfo);
		local tbAttrib = KItem.GetExternAttrib(nAttributeID, nLevel);
		for nSeq, tbMagic in pairs(tbAttrib or {}) do
			tbAllAttrib[tbMagic.szAttribName] = tbAllAttrib[tbMagic.szAttribName] or {tbValue = {0, 0, 0}};
			tbAllAttrib[tbMagic.szAttribName].nSeq = nSeq
			local tbOldInfo = tbAllAttrib[tbMagic.szAttribName];
			for i = 1, 3 do
				tbOldInfo.tbValue[i] = tbOldInfo.tbValue[i] + tbMagic.tbValue[i];
			end
		end
	end
	return tbAllAttrib;
end

function PartnerCard:FormatAttribSeq(tbAttrib)
	local tbSeqAttrib = {}
	for szType, tbInfo in pairs(tbAttrib or {}) do
		local tbData = {}
		tbData.szType = szType
		tbData.tbValue = tbInfo.tbValue
		tbData.nSeq = tbInfo.nSeq
		table.insert(tbSeqAttrib, tbData)
	end
	-- 按ExternAttrib表里配的顺序排序
	if #tbSeqAttrib > 1 then
		table.sort(tbSeqAttrib, function(a, b) return a.nSeq < b.nSeq end)
	end
	return tbSeqAttrib
end

-- 根据同伴id获取门客id
function PartnerCard:GetCardIdByPartnerTempleteId(nPartnerTempleteId)
	return self.tbPartnerTId2CardId[nPartnerTempleteId]
end

function PartnerCard:GetQualityByCardId(nCardId)
	local tbCardInfo = self:GetCardInfo(nCardId)
	if not tbCardInfo then
		return 0
	end
	local _, nQuality = GetOnePartnerBaseInfo(tbCardInfo.nPartnerTempleteId);
	return nQuality or 0
end

-- 计算战力
function PartnerCard:CalcFightPower(pPlayer)
	local nFightPower = 0
	local tbCard = PartnerCard:GetAllOwnCard(pPlayer)
	for _, v in ipairs(tbCard) do
		if PartnerCard:IsCardUpPos(pPlayer, v.nCardId) then
			nFightPower = nFightPower + PartnerCard:GetCardFightPower(pPlayer, v.nCardId)
		end
	end
	return nFightPower
end

function PartnerCard:GetUniqSkillIdByCardId(nCardId)
	local tbCardInfo = self:GetCardInfo(nCardId)
	return tbCardInfo and tbCardInfo.tbUniquePartnerSkillId
end
