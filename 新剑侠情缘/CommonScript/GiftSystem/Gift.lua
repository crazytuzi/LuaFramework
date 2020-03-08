Gift.Sex = {
	Boy  = 1,
	Girl = 2,
}

Gift.GiftType = 										-- 赠送类型
{
	RoseAndGrass = 1,
	FlowerBox    = 2,
	MailGift 	 = 3,
	Lover  		 = 4,
	MoonCake	 = 5,
	QRFlowerBox  = 6,
	TwinLotus    = 7,
}

Gift.AllGift =
{
	[Gift.GiftType.RoseAndGrass] = true,
	[Gift.GiftType.FlowerBox] 	 = true,
	[Gift.GiftType.MailGift] 	 = true,
	[Gift.GiftType.Lover] 		 = true,
	[Gift.GiftType.MoonCake] 	 = true,
	[Gift.GiftType.QRFlowerBox] 	 = true,
	[Gift.GiftType.TwinLotus]    = true,
}

Gift.AllGiftNeedOnline = {
	[Gift.GiftType.RoseAndGrass] = true,
	[Gift.GiftType.FlowerBox] 	 = true,
	[Gift.GiftType.MailGift] 	 = false,
	[Gift.GiftType.Lover] 		 = true,
	[Gift.GiftType.MoonCake] 	 = true,
	[Gift.GiftType.QRFlowerBox] 	 = true,
	[Gift.GiftType.TwinLotus]    = true,
}

Gift.MailType =
{
	Times2Player = 1, 									-- 次数针对玩家
	Times2Item  = 2, 									-- 次数针对道具
	NoLimit = 3,										-- 没有次数限制
}

Gift.MailTimesType =
{
	[Gift.MailType.Times2Player] = true,
	[Gift.MailType.Times2Item]	 = true,
	[Gift.MailType.NoLimit]		 = true,
}

Gift.MailTimesTypeNeedOnline =
{
	[Gift.MailType.Times2Player] = true,
	[Gift.MailType.Times2Item]	 = true,
	[Gift.MailType.NoLimit]		 = false,
}

Gift.Times =
{
	Forever = -1 ,										-- 性别礼物类型不计赠送次数
}

Gift.nRoseId 		= 1234								-- 玫瑰花道具ID
Gift.nGrassId		= 1235								-- 幸运草道具ID

Gift.nRoseBoxId 	= 2180								-- 99朵玫瑰
Gift.nGrassBoxId	= 2181								-- 99棵幸运草

Gift.nQingRenBoxId	= 10315								-- 情人节玫瑰

Gift.nQiaoKeLiId 	= 3789								-- 巧克力 春蚕悬丝
Gift.nFlowerId		= 3788								-- 花束   蓝色妖姬

Gift.nMoonCakeId    = 6440 								-- 月饼（晴雲秋月）
Gift.nTwinLotusId   = 10660                             -- 金杏叶（520活动）

-- 特殊处理的礼物类型
Gift.SpecialGift =
{
	[Gift.GiftType.MailGift] = true, 					-- 邮件发送道具类型（具体在Setting/Gift/MailGift.tab中配，可多个道具共用次数）
}

-- 性别礼物类型配置
Gift.IsReset = 											-- 性别礼物类型是否每天重置
{
	[Gift.GiftType.RoseAndGrass] = true,
	[Gift.GiftType.FlowerBox] 	 = true,
	[Gift.GiftType.Lover] 		 = true,
	[Gift.GiftType.MoonCake] 	 = true,
	[Gift.GiftType.QRFlowerBox]  = true,
	[Gift.GiftType.TwinLotus]  = true,
}

Gift.SendTimes = 										-- 性别礼物类型赠送次数
{
	[Gift.GiftType.RoseAndGrass] = 999,
	[Gift.GiftType.FlowerBox] 	 = 999,
	[Gift.GiftType.Lover] 	 	 = 999,
	[Gift.GiftType.MoonCake] 	 = 99,
	[Gift.GiftType.QRFlowerBox]  = 5,
	[Gift.GiftType.TwinLotus] 	 = 10,
}

Gift.Rate = 											-- 性别礼物类型亲密度配置,不配不加（每次增加类型记得扩展每天可增加的亲密度数）
{
	[Gift.GiftType.RoseAndGrass] 	= 50,				-- 玫瑰花&幸运草 ~ 亲密度转换率
	[Gift.GiftType.FlowerBox] 		= 999,				-- 玫瑰花篮&幸运草篮 ~ 亲密度转换率
	[Gift.GiftType.Lover] 		    = 200,				-- 巧克力&花束 ~ 亲密度转换率
	[Gift.GiftType.MoonCake] 		= 50, 				-- 月饼 ~ 亲密度转换率
	[Gift.GiftType.QRFlowerBox] 	= 1314,				-- 玫瑰花篮&幸运草篮 ~ 亲密度转换率
}

Gift.AllItem = 											-- 性别礼物类型礼物类型对应性别的item
{
	[Gift.GiftType.RoseAndGrass] = {
		[Gift.Sex.Boy] = {Gift.nGrassId, "棵幸运草"},
		[Gift.Sex.Girl] = {Gift.nRoseId, "朵玫瑰花"},
	},
	[Gift.GiftType.FlowerBox] = {
		[Gift.Sex.Boy] = {Gift.nGrassBoxId, "99棵幸运草"},
		[Gift.Sex.Girl] = {Gift.nRoseBoxId, "99朵玫瑰花"},
	},
	[Gift.GiftType.Lover] = {
		[Gift.Sex.Boy] = {Gift.nQiaoKeLiId, "个春蚕悬丝"},
		[Gift.Sex.Girl] = {Gift.nFlowerId, "朵蓝色妖姬"},
	},
	[Gift.GiftType.MoonCake] = {
		[Gift.Sex.Boy] = {Gift.nMoonCakeId, "个月饼"},
		[Gift.Sex.Girl] = {Gift.nMoonCakeId, "个月饼"},
	},
	[Gift.GiftType.QRFlowerBox] = {
		[Gift.Sex.Boy] = {Gift.nQingRenBoxId, "霞蔚锦簇"},
		[Gift.Sex.Girl] = {Gift.nQingRenBoxId, "霞蔚锦簇"},
	},
	[Gift.GiftType.TwinLotus] = {
		[Gift.Sex.Boy] = {Gift.nTwinLotusId, "朵金杏叶"},
		[Gift.Sex.Girl] = {Gift.nTwinLotusId, "朵金杏叶"},
	},
}

-- 第一个%s是赠送方的名字，第二个%s是接受方的名字，第三个%s是道具的名字
Gift.tbBoxNotice =
{
	[Gift.GiftType.FlowerBox] = {
		-- 赠送放是男的
		[Gift.Sex.Boy] =
		{
			[Gift.Sex.Boy] = "「%s」从火热的胸膛处掏出【%s】送给「%s」，说道：兄弟！天涯何处无芳草，送你一把幸运草……咱俩大块肉，大杯酒，岂不快活！",
			[Gift.Sex.Girl] = "「%s」拿出藏在背后已久的【%s】送给「%s」，说道：此花只应天上有，不及佳人一回眸。最珍贵的花亦远不如你，故此花非你莫属。",
		},
		-- 赠送放是女的
		[Gift.Sex.Girl] =
		{
			[Gift.Sex.Boy] = "「%s」红着脸颊从香囊取出【%s】送给「%s」，说道：花开草叶侧，只缘君护花。谢谢你一路以来的相伴，希望它能为你带来幸运。",
			[Gift.Sex.Girl] = "「%s」从贴身的锦囊中取出【%s】送给「%s」，说道：唯有闺中蜜，方知两人心，我最最亲爱的姐妹，愿你一世貌美如花，不可方物。",
		},
	},
	[Gift.GiftType.QRFlowerBox] = {
		-- 赠送放是男的
		[Gift.Sex.Boy] =
		{
			[Gift.Sex.Boy] = "「%s」在情缘节这样特殊的日子，一把将【%s】塞给「%s」，说道：兄弟！其实我有句话想对你说好久了，正值情人节，今晚来我家，有要事相商！",
			[Gift.Sex.Girl] = "「%s」在情缘节这样特殊的日子，亲手制作了【%s】送给「%s」，说道：金风玉露一相逢，便胜却人间无数。你我相逢即是有缘，愿这缘分永永远远。",
		},
		-- 赠送放是女的
		[Gift.Sex.Girl] =
		{
			[Gift.Sex.Boy] = "「%s」在情缘节这样特殊的日子，明眸流转双颊绯红地拿出【%s】送给「%s」，说道：今夕何夕兮搴洲中流，今日何日兮与君同舟。心悦君已久，君意可知否？",
			[Gift.Sex.Girl] = "「%s」在情缘节这样特殊的日子，从锦囊中拿出【%s】送给「%s」，说道：愿我最亲密的姐妹尽色绝艳，容貌更胜娇花！",
		},
	},
}

-- 赠送之后需要发世界公告
Gift.tbWorldNotice =
{
	[Gift.GiftType.MoonCake] =
	{
		[Gift.Sex.Boy] = "「%s」小心翼翼的拿出精心准备的「%s」送给「%s」，并真挚的说：“沧海生明月，皓空起相思。我赠君祝福，唯恐会意迟。”",
		[Gift.Sex.Girl] = "「%s」小心翼翼的拿出精心准备的「%s」送给「%s」，并真挚的说：“沧海生明月，皓空起相思。我赠君祝福，唯恐会意迟。”",
	};
}

Gift.tbAllShowEffect = {
	[10315] = true,
}

-- 邮件发送道具类型配置
Gift.tbMailGift = {}
Gift.tbAllMailItem = {}
Gift.tbAllMailGirlItem = {}

function Gift:LoadSetting()
	local szTabPath = "Setting/Gift/MailGift.tab";
	local szParamType = "sssdddddddssdddds";
	local szKey = "szKey";
	local tbParams = {"szKey","szId","szGirlId","nTimesType","nReset","nTimes","nItemSend","nItemAccept","nSure","nImityLevel","szSureTip","szUseTip","nVip","nAddImitity","nNotSendMail","nNotConsume","szAliasName"};
	local tbFile = LoadTabFile(szTabPath, szParamType, szKey, tbParams);

	for szKey,tbInfo in pairs(tbFile) do
		self.tbMailGift[szKey] = self.tbMailGift[szKey] or {}
		assert(tbInfo.szId ~= "",  "[Gift] LoadSetting no szId")
		local tbId = Lib:SplitStr(tbInfo.szId, ";")
		assert(next(tbId), "[Gift] LoadSetting fail ! tbItemId is {}")
		local tbGirlId = {}
		if tbInfo.szGirlId ~= "" then
			tbGirlId = Lib:SplitStr(tbInfo.szGirlId, ";")
			-- 男女道具个数要相等
			assert(#tbId == #tbGirlId, "[Gift] LoadSetting mail item count not equal " ..#tbId .."====" ..#tbGirlId)
		end

		local tbItemId = {}
		for i,v in pairs(tbId) do
			local nV = tonumber(v)
			if not nV then
				Log(debug.traceback())
				return
			end
			tbItemId[i] = nV
		end

		local tbGirlItemId = {}
		if next(tbGirlId) then
			for k,v in pairs(tbItemId) do
				local nV = tonumber(tbGirlId[k])
				if not nV then
					Log("[Gift] tbGirlItemId not invail id" ..debug.traceback())
					return
				end
				-- 男女对应道具id不能相同
				assert(nV ~= v, "[Gift] tbGirlItemId same id " ..nV .."====" ..v)
				tbGirlItemId[k] = nV
			end
		end

		self.tbMailGift[szKey].tbItemId = tbItemId
		self.tbMailGift[szKey].tbGirlItemId = tbGirlItemId

		if tbInfo.nReset and tbInfo.nReset == 1 then
			self.tbMailGift[szKey].bReset = true
		end

		if tbInfo.nSure and tbInfo.nSure == 1 then
			self.tbMailGift[szKey].bSure = true
		end

		assert(Gift.MailTimesType[tbInfo.nTimesType],"error times type" ..tbInfo.nTimesType)

		self.tbMailGift[szKey].nTimesType = tbInfo.nTimesType
		self.tbMailGift[szKey].nTimes = tbInfo.nTimes or 0 					-- 针对玩家可赠送的次数
		self.tbMailGift[szKey].nItemSend = tbInfo.nItemSend 				-- 针对道具可赠送的次数
		self.tbMailGift[szKey].nItemAccept = tbInfo.nItemAccept 			-- 针对道具可接受的次数
		self.tbMailGift[szKey].nImityLevel = tbInfo.nImityLevel
		self.tbMailGift[szKey].nVip = tbInfo.nVip
		if tbInfo.nAddImitity > 0 then
			self.tbMailGift[szKey].nAddImitity = tbInfo.nAddImitity
		end
		if tbInfo.nNotSendMail > 0 then
			self.tbMailGift[szKey].bNotSendMail = true
		end
		if tbInfo.nNotConsume > 0 then
			self.tbMailGift[szKey].bNotConsume = true
		end
		if tbInfo.szSureTip ~= "" then
			self.tbMailGift[szKey].szSureTip = tbInfo.szSureTip
		end
		if tbInfo.szUseTip ~= "" then
			self.tbMailGift[szKey].szUseTip = tbInfo.szUseTip
		end

		if tbInfo.szAliasName and tbInfo.szAliasName ~= "" then
			self.tbMailGift[szKey].szAliasName = tbInfo.szAliasName
		end

		for nIdx,nItemId in pairs(tbItemId) do
			assert(not Gift.tbAllMailItem[nItemId],"gift same item id=" ..nItemId)
			Gift.tbAllMailItem[nItemId] = {}
			Gift.tbAllMailItem[nItemId].tbData = self.tbMailGift[szKey]
			Gift.tbAllMailItem[nItemId].szKey = szKey
			Gift.tbAllMailItem[nItemId].nIdx = nIdx
			Gift.tbAllMailItem[nItemId].szAliasName = self.tbMailGift[szKey].szAliasName
		end

		for nIdx,nItemId in pairs(tbGirlItemId) do
			assert(not Gift.tbAllMailGirlItem[nItemId],"gift tbAllMailGirlItem same item id" ..nItemId)
			Gift.tbAllMailGirlItem[nItemId] = {}
			Gift.tbAllMailGirlItem[nItemId].tbData = self.tbMailGift[szKey]
			Gift.tbAllMailGirlItem[nItemId].szKey = szKey
			Gift.tbAllMailGirlItem[nItemId].nIdx = nIdx
		end

	end
end

Gift:LoadSetting()

function Gift:CheckMailItemSex(nItemId)
	local nSex
	if Gift.tbAllMailItem[nItemId] then
		nSex = Gift.Sex.Boy
	elseif Gift.tbAllMailGirlItem[nItemId] then
		nSex = Gift.Sex.Girl
	end
	return nSex
end

function Gift:CheckMailSexLimit(szKey)
	local bSexLimit
	local tbInfo = Gift:GetMailGiftInfo(szKey)
	if tbInfo and tbInfo.tbGirlItemId and next(tbInfo.tbGirlItemId) then
		bSexLimit = true
	end
	return bSexLimit
end

function Gift:GetMailGiftItemInfo(nItemId)
	return Gift.tbAllMailItem[nItemId] or Gift.tbAllMailGirlItem[nItemId]
end

function Gift:GetMailGiftInfo(szKey)
	return Gift.tbMailGift[szKey]
end

function Gift:GetSpecialTimes(nGiftType,nItemId)
	local nTimes,tbInfo
	if nGiftType == Gift.GiftType.MailGift then
		tbInfo = self:GetMailGiftItemInfo(nItemId)
		nTimes = tbInfo and tbInfo.tbData.nTimes
	end
	return nTimes
end

function Gift:GetMailAddImitity(nGiftType,nItemId)
	local nAddImitity,tbInfo
	if nGiftType == Gift.GiftType.MailGift then
		tbInfo = self:GetMailGiftItemInfo(nItemId)
		nAddImitity = tbInfo and tbInfo.tbData.nAddImitity
	end
	return nAddImitity
end

function Gift:GetMailTimesType(nGiftType,nItemId)
	local nType,tbInfo
	if nGiftType == Gift.GiftType.MailGift then
		tbInfo = self:GetMailGiftItemInfo(nItemId)
		nType = tbInfo and tbInfo.tbData.nTimesType
	end
	return nType
end

function Gift:GetItemAcceptTimes(nGiftType,nItemId)
	local nTimes,tbInfo
	if nGiftType == Gift.GiftType.MailGift then
		tbInfo = self:GetMailGiftItemInfo(nItemId)
		nTimes = tbInfo and tbInfo.tbData.nItemAccept
	end
	return nTimes
end

function Gift:GetItemSendTimes(nGiftType,nItemId)
	local nTimes,tbInfo
	if nGiftType == Gift.GiftType.MailGift then
		tbInfo = self:GetMailGiftItemInfo(nItemId)
		nTimes = tbInfo and tbInfo.tbData.nItemSend
	end
	return nTimes
end

function Gift:GetIsReset(nGiftType,nItemId)
	if nGiftType == Gift.GiftType.MailGift then
		local tbInfo = self:GetMailGiftItemInfo(nItemId)
		return tbInfo and tbInfo.tbData.bReset
	else
		return Gift.IsReset[nGiftType]
	end
end

function Gift:CheckNeedSure(nGiftType, nItemId)
	local tbInfo = nGiftType == Gift.GiftType.MailGift and self:GetMailGiftItemInfo(nItemId)
	return tbInfo and tbInfo.tbData.bSure
end

function Gift:CheckUseSure(nGiftType, nItemId)
	local tbInfo = nGiftType == Gift.GiftType.MailGift and self:GetMailGiftItemInfo(nItemId)
	return tbInfo and tbInfo.tbData and tbInfo.tbData.szUseTip
end

function Gift:CheckCommond(pPlayer,nAcceptId,nCount,nGiftType)
	if not nCount or nCount < 1 then
		return false,"请选择要赠送的物品";
	end
	local pAcceptPlayer = KPlayer.GetPlayerObjById(nAcceptId);
	if not pAcceptPlayer then
		return false,"对方不在线";
	end

	local nSex = pAcceptPlayer.nSex;
	if not nSex then
		return false,"对方是男?是女?";
	end

	local bIsFriend = FriendShip:IsFriend(pPlayer.dwID, nAcceptId);
	if not bIsFriend then
		return false,"对方不是你的好友";
	end

	local nItemId = Gift:GetItemId(nGiftType,nSex)

	if not nItemId then
		return false,"找不到要赠送的物品";
	end

	local nOrgCount = pPlayer.GetItemCountInAllPos(nItemId);
	local szItemName = Item:GetItemTemplateShowInfo(nItemId, pPlayer.nFaction, pPlayer.nSex)
	if nOrgCount < nCount then
		return false,string.format("您的%s不够",szItemName);
	end

	return true,"",pAcceptPlayer,nSex,nItemId,szItemName;
end

function Gift:BoxNotice(nGiftType, nSendSex, nAcceptSex)
	local szNotice = "「%s」对「%s」赠送了%s"
	if Gift.tbBoxNotice[nGiftType][nSendSex] and Gift.tbBoxNotice[nGiftType][nSendSex][nAcceptSex] then
		szNotice = Gift.tbBoxNotice[nGiftType][nSendSex][nAcceptSex]
	end
	return szNotice
end

function Gift:GetItemDesc(nGiftType,nSex)
	return Gift.AllItem[nGiftType] and Gift.AllItem[nGiftType][nSex] and Gift.AllItem[nGiftType][nSex][2]
end

-- 获取性别礼物类型ItemId
function Gift:GetItemId(nGiftType,nSex)
	return Gift.AllItem[nGiftType] and Gift.AllItem[nGiftType][nSex] and Gift.AllItem[nGiftType][nSex][1]
end

function Gift:GetItemShowName(nItemId, nMyFaction, nMySex, nFaction, nSex)
	local szMyItemName = Item:GetItemTemplateShowInfo(nItemId, nMyFaction, nMySex) or ""
	local szItemName = Item:GetItemTemplateShowInfo(nItemId, nFaction, nSex) or ""
	if not Lib:IsEmptyStr(szItemName) and szMyItemName ~= szItemName then
		szMyItemName = string.format("%s(%s)", szMyItemName, szItemName)
	end
	return szMyItemName
end

function Gift:GetItemAliasName(nItemId)
	return self.tbAllMailItem[nItemId] and self.tbAllMailItem[nItemId].szAliasName
end