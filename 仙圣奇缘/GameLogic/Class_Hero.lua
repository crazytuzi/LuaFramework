--------------------------------------------------------------------------------------
-- 文件名:	Hero.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2013-12-16 15:24
-- 版  本:	1.0
-- 描  述:	玩家数据
-- 应  用:
---------------------------------------------------------------------------------------

--创建CHero类继承CCObject
Class_Hero = class("Class_Hero")
Class_Hero.__index = Class_Hero

function Class_Hero:Init()
    
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_CARD_ATTRIBUTE_UPDATE,handler(self,self.OnRespondAttributeUpdate))

	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_INIT_CARD_LIST_NOTIFY,handler(self,self.OnRespondCardList))

	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_INIT_EQUIP_LIST_NOTIFY,handler(self,self.OnRespondEquipList))

	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_INIT_MATERIAL_LIST_NOTIFY,handler(self,self.OnRespondMaterialList))

	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_INIT_FATE_LIST_NOTIFY,handler(self,self.OnRespondFateList))

	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_FINISH_FIRST_NOTIFY,handler(self,self.OnsprondFirstOpTyep))

	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_UPDATE_MATERIAL_NOTIFY,handler(self,self.OnRespondUpdataCardList))

end

--服务端返回登陆消息从而填充玩家的基础信息
function Class_Hero:setHeroBaseInfo(tbMasterMsg)
	if(not tbMasterMsg )then
		cclog("Class_Hero:setHeroBaseInfo nil")
		return
	end
	--设置玩家基础数据
	self.tbMasterBase = {}
	self.tbMasterBase.szName = tbMasterMsg.masterinfo.name
	self.tbMasterBase.nEnergy = tbMasterMsg.masterinfo.energy or 0
	self.tbMasterBase.nYuanBao = tbMasterMsg.masterinfo.coupons or 0						--元宝
	self.tbMasterBase.nCoins = tbMasterMsg.masterinfo.golds or 0							--铜钱
	self.tbMasterBase.nPrestige = tbMasterMsg.masterinfo.prestige or 0					--声望
	self.tbMasterBase.nKnowlede = tbMasterMsg.masterinfo.knowlede or 0					--阅历
	self.tbMasterBase.nRealmpoints = tbMasterMsg.masterinfo.realmpoints or 0				--境界经验
	self.tbMasterBase.nVipLevel = tbMasterMsg.masterinfo.viplv or 0							--VIP等级
	self.tbMasterBase.nTotalChargeYuanBao = tbMasterMsg.masterinfo.totalrecharge or 0			--累积充值
    self.tbMasterBase.nTotalChargeYuanBaoJR = tbMasterMsg.masterinfo.totalrechargeJR or 0      --节日累计充值
    self.tbMasterBase.nTotalSummon = tbMasterMsg.masterinfo.totalsummon or 0                   --累计召唤
    self.tbMasterBase.nTotalSummonJR = tbMasterMsg.masterinfo.totalsummonJR or 0               --节日累计召唤
    self.tbMasterBase.nTotalCostYuanBao = tbMasterMsg.masterinfo.totalcost or 0                --累计消耗元宝
    self.tbMasterBase.nTotalCostYuanBaoJR = 0                                    --节日累计消耗元宝
	self.tbMasterBase.nIncense = tbMasterMsg.masterinfo.incense or 0						--香贡、香贡
	self.tbMasterBase.nGodPower = tbMasterMsg.masterinfo.power or 0						--神力
	self.tbMasterBase.nArenaTimes = tbMasterMsg.masterinfo.arena_times or 0				--竞技场挑战次数
	self.tbMasterBase.nEssence = tbMasterMsg.masterinfo.essence or 0						--灵力、元素精华
	self.tbMasterBase.nFriendPoints = tbMasterMsg.masterinfo.friend_heart or 0			--爱心友情之心
	self.tbMasterBase.nXianLing = tbMasterMsg.masterinfo.xian_ling or 0				--仙令
	self.tbMasterBase.nDragonBall = tbMasterMsg.masterinfo.dragon_ball or 0                --龙珠
	self.tbMasterBase.nJiangHunShi = tbMasterMsg.masterinfo.jiang_hun_shi or 0                --将魂石
	self.tbMasterBase.nRefreshToken = tbMasterMsg.masterinfo.refresh_token or 0                --刷新令
	self.tbMasterBase.nSex = tbMasterMsg.masterinfo.sex or 0			--性别
    self.tbMasterBase.nTotalSysDays = 1                      --累计开服天数

	g_Guild:setGuildID(tbMasterMsg.guild_id or 0) --帮派Id
	
		
	--帮派建筑
	g_Guild:guildBuildingData(tbMasterMsg.guild_building)
	
	local guildInfo = tbMasterMsg.guild_info
	if guildInfo then 
		local guildName = guildInfo.guild_name --帮派名字
		local guildlevel = guildInfo.guild_lv --帮派等级
		g_Guild:setUserGuildName(guildName)
		g_Guild:setUserGuildLevel(guildlevel)
	end
	self.tbMasterBase.dujie_array = tbMasterMsg.dujie_array --渡劫卡牌阵型
	self.tbMasterBase.cur_dujie_method_id = tbMasterMsg.cur_dujie_method_id --渡劫当前选择的阵型
	
	self.tbEctypeStars = {} --副本过关星级情况
    self.tbBigMapRequest = {} --副本过关星级情况
	self.nFinalClearEctypeID = tbMasterMsg.big_pass_id
    self.nDialogID = tbMasterMsg.dialog_opened_id
	self.nBuyEenergyTimes = tbMasterMsg.buy_energy_times
	self.nContinuousLoginDate = tbMasterMsg.continuous_login --连续登陆信息
	self.tbMaterAddProps = {} --主角附加属性
	self.tbMaterAddProps.tbZhenXinProps = {} --主角阵心附加属性

	tbData = tbMasterMsg
	
	--仙脉数据
	g_XianMaiInfoData:setXianMaiInfo(tbMasterMsg.xian_mai)
	
	--初始化奇术
    self:initQiShu(tbMasterMsg)
	
	--刷新出战成员的属性
	self:initTeamMemberAddProps(true)
	
    --刷新伙伴缘分
    self:cardGroupAddProps()

	--魂魄
	self:initHunPoList(tbMasterMsg)
	
	--元神列表
	-- echoj("元神====",tbMasterMsg.soul_info)
	self:initSoulItem(tbMasterMsg.soul_info)
	
	
	--初始化材料卡牌列表
	self:initCardMaterialList() 
	--设置提醒信息
	self:setNotifyInfo(tbMasterMsg.notify_info)
	
	self.nRank = tbMasterMsg.arena_rank
	self.nOfficialRank = tbMasterMsg.offcial_rank

	--背包容量
	self.tbExtraSpace = {
		[macro_pb.ITEM_TYPE_ARRAYMETHOD] = tbMasterMsg.arraymethod_extra_space,
		[macro_pb.ITEM_TYPE_CARD] = tbMasterMsg.card_extra_space,
		[macro_pb.ITEM_TYPE_EQUIP] = tbMasterMsg.equip_extra_space,
		[macro_pb.ITEM_TYPE_FATE] = tbMasterMsg.fate_extra_space,
	}

	--新手引导的二进制数据
	self:initPlayerGuideStep(tbMasterMsg.guide_key1, tbMasterMsg.guide_key2)

    self:calcCurBattlePower()
	--爱心
	self:initSendFriendPointsStatus(tbMasterMsg.friend_recv_list)
	self:initReceiveFriendPointsStatus(tbMasterMsg.friend_send_heart)
	
	g_VIPBase:setVipLevel(self.tbMasterBase.nVipLevel)

	--玩家第一次的操作信息
	self:initFirstOpType(tbMasterMsg)

end

----------------------------------玩家所有掉落消息----------------------------------
--[[
ITEM_TYPE_CARD = 1;    //伙伴
ITEM_TYPE_EQUIP = 2;   //装备
ITEM_TYPE_ARRAYMETHOD = 3;  //阵法(暂时作废)
ITEM_TYPE_FATE = 4;    //异兽
ITEM_TYPE_CARD_GOD = 5;   //魂魄
ITEM_TYPE_MATERIAL = 6;   //ItemBase(道具)
ITEM_TYPE_SOUL = 7;    //元神
ITEM_TYPE_MASTER_EXP = 8;  //主角经验
ITEM_TYPE_MASTER_ENERGY = 9; //体力
ITEM_TYPE_COUPONS = 10;   //点券、元宝
ITEM_TYPE_GOLDS = 11;   //金币、铜钱
ITEM_TYPE_PRESTIGE = 12;  //声望
ITEM_TYPE_KNOWLEDGE = 13;  //阅历
ITEM_TYPE_INCENSE = 14;   //香贡
ITEM_TYPE_POWER = 15;   //神力
ITEM_TYPE_ARENA_TIME = 16;  //竞技场挑战次数
ITEM_TYPE_ESSENCE = 17;  //灵力、元素精华
ITEM_TYPE_FRIENDHEART = 18; //友情之心
]]

local element ={
   	 macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_METAL,		    --金元素
	 macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_NATURE,	        --木元素
	 macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_WATER,		    --水元素
	 macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_FIRE,           --火元素
	 macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_EARTH,           --土元素
	 macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_AIR,            --风元素
	 macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_LIGHTNING,         --雷元素 
}

function Class_Hero:addDropItem(tbDropItem)
	local nType = tbDropItem.drop_item_type
	
	if(nType == macro_pb.ITEM_TYPE_CARD)then --卡牌
		g_Hero:addCard(tbDropItem)
	elseif(nType == macro_pb.ITEM_TYPE_EQUIP)then --装备
		g_Hero:addEquip(tbDropItem)
	elseif(nType == macro_pb.ITEM_TYPE_ARRAYMETHOD)then --阵法（已废除）
		--
	elseif(nType == macro_pb.ITEM_TYPE_FATE)then --异兽
		g_Hero:addFate(tbDropItem)
	elseif(nType == macro_pb.ITEM_TYPE_CARD_GOD)then --魂魄
		g_Hero:addHunPo(tbDropItem)
	elseif(nType == macro_pb.ITEM_TYPE_MATERIAL)then --道具（ItemBase）
		g_Hero:addItem(tbDropItem)
	elseif(nType == macro_pb.ITEM_TYPE_SOUL)then --元神
		g_Hero:addSoul(tbDropItem)
	elseif(nType == macro_pb.ITEM_TYPE_MASTER_EXP)then --主角经验
		cclog("==========设置主角等级======="..tbDropItem.lv)
		cclog("==========设置主角经验======="..tbDropItem.exp)
		g_Hero:addMasterCardExp(0, tbDropItem.lv, tbDropItem.exp)
	elseif(nType == macro_pb.ITEM_TYPE_MASTER_ENERGY)then --体力
		g_Hero:addEnergy(tbDropItem.drop_item_num)
	elseif(nType == macro_pb.ITEM_TYPE_COUPONS)then --点券
		g_Hero:addYuanBao(tbDropItem.drop_item_num)
	elseif(nType == macro_pb.ITEM_TYPE_GOLDS)then --铜钱
		g_Hero:addCoins(tbDropItem.drop_item_num)
	elseif(nType == macro_pb.ITEM_TYPE_PRESTIGE)then --声望
		g_Hero:addPrestige(tbDropItem.drop_item_num)
	elseif(nType == macro_pb.ITEM_TYPE_KNOWLEDGE)then --阅历
		g_Hero:addKnowledge(tbDropItem.drop_item_num)
	elseif(nType == macro_pb.ITEM_TYPE_INCENSE)then --香贡
		g_Hero:addIncense(tbDropItem.drop_item_num)
	elseif(nType == macro_pb.ITEM_TYPE_POWER)then --神力
		g_Hero:addGodPower(tbDropItem.drop_item_num)
	elseif(nType == macro_pb.ITEM_TYPE_ARENA_TIME)then --竞技场挑战次数
		g_Hero:addArenaTimes(tbDropItem.drop_item_num)
	elseif(nType == macro_pb.ITEM_TYPE_ESSENCE)then --灵力
		g_Hero:addEssence(tbDropItem.drop_item_num)
	elseif(nType == macro_pb.ITEM_TYPE_FRIENDHEART)then --友情之心
		g_Hero:addFriendPoints(tbDropItem.drop_item_num)
	elseif(nType == macro_pb.ITEM_TYPE_CARDEXPINBATTLE)then --卡牌经验
		g_Hero:addTeamMemberExpWithHeroEvent(tbDropItem.drop_item_num, tbDropItem.lv, tbDropItem.exp)
	elseif(nType == macro_pb.ITEM_TYPE_XIAN_LING)then --仙令
		g_Hero:addXianLing(tbDropItem.drop_item_num)
	elseif(nType == macro_pb.ITEM_TYPE_DRAGON_BALL)then --神龙令
		g_Hero:addDragonBall(tbDropItem.drop_item_num)
	elseif(nType == macro_pb.ITEM_TYPE_XIANMAI_ONE_KEY)then --一键消除
		g_Hero:addXiaoChuSkill(tbDropItem.drop_item_num, nType)
	elseif(nType == macro_pb.ITEM_TYPE_XIANMAI_BA_ZHE)then --霸者横栏
		g_Hero:addXiaoChuSkill(tbDropItem.drop_item_num, nType)
	elseif(nType == macro_pb.ITEM_TYPE_XIANMAI_LIAN_SUO)then --清除连锁
		g_Hero:addXiaoChuSkill(tbDropItem.drop_item_num, nType)
	elseif(nType == macro_pb.ITEM_TYPE_XIANMAI_DOU_ZHUAN)then --斗转星移
		g_Hero:addXiaoChuSkill(tbDropItem.drop_item_num, nType)
	elseif(nType == macro_pb.ITEM_TYPE_XIANMAI_DIAN_DAO)then --颠倒乾坤
		g_Hero:addXiaoChuSkill(tbDropItem.drop_item_num, nType)
	elseif nType >= macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_METAL 
		and nType <= macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_LIGHTNING then --觉醒元素属性数量
        for i = 1, #element do 
            if nType == element[i] then
                g_XianMaiInfoData:addTbElementDrop(i, tbDropItem.drop_item_num)
                return
            end
        end
	elseif(nType == macro_pb.ITEM_TYPE_SECRET_JIANGHUN)then --将魂石
		g_Hero:addJiangHunShi(tbDropItem.drop_item_num)
	elseif(nType == macro_pb.ITEM_TYPE_SECRET_REFRESH_TOKEN)then --将魂令
		g_Hero:addRefreshToken(tbDropItem.drop_item_num)
	else
		cclog("*****Class_Hero:addDropItem *****"..nType)
	end
end

function Class_Hero:addDropList(tbDropList)
	if(tbDropList)then
		for i=1, #tbDropList do
			local tbDropItem = tbDropList[i]
			self:addDropItem(tbDropItem)
		end
	else
		cclog("Class_Hero:addDropList drop_result nil")
	end
end

function Class_Hero:addDropInfo(tbDropInfo)

	if(tbDropInfo)then
		local tbDropList = tbDropInfo.drop_result.drop_lst
		self:addDropList(tbDropList)
	else
		cclog("Class_Hero:addDropInfo drop_result nil")
	end
end

local function sortFate(idA, idB)
	local infoA = g_Hero:getFateInfoByID(idA)
	local infoB = g_Hero:getFateInfoByID(idB)
	local lvA = infoA.tbCsvBase.Level
	local lvB = infoB.tbCsvBase.Level
	local slvA = infoA.tbCsvBase.ColorType
	local slvB = infoB.tbCsvBase.ColorType
	return slvA>slvB or (slvA==slvB and lvA>lvB)
end

local function initEctypePassInfo(tbData)
    local tbEcypePass= {}
    for i =1, #tbData do
        tbEcypePass[tbData[i].big_passed_id] =  tbData[i].passed_id
    end
	return tbEcypePass
end

function Class_Hero:setNotifyInfo(info)
	self.bubbleNotify = self.bubbleNotify or {}
	for _,v in pairs(info) do
		if v.type==macro_pb.NT_ACTIVITY then
			self.bubbleNotify.activity = v.num
		elseif v.type==macro_pb.NT_MARKET then
			self.bubbleNotify.market = v.num
		elseif v.type==macro_pb.NT_ASSISTANT then
			--self.bubbleNotify.assistant = v.num
		elseif v.type==macro_pb.NT_SIGN_IN then
			self.SignDateStatus = v.num
		elseif v.type==macro_pb.NT_ZHAOCAI then
			self.bubbleNotify.zhaocai = v.num
		elseif v.type==macro_pb.NT_FARM then
			self.bubbleNotify.farm = v.num
		elseif v.type then
            self:setBubbleNotify(v.type, v.num)
        end
	end
end

function Class_Hero:getBubbleNotify(strName)
	if not strName or not self.bubbleNotify then return 0 end
	return self.bubbleNotify[strName] or 0
end

function Class_Hero:setBubbleNotify(strName, nNum)
	if not self.bubbleNotify then 
		self.bubbleNotify = {}
	end 
	self.bubbleNotify[strName] = nNum
end

function Class_Hero:addBubbleNotify(strName, nNum)
	self.bubbleNotify = self.bubbleNotify or {}
	self.bubbleNotify[strName] = self.bubbleNotify[strName] or 0
	self.bubbleNotify[strName] = self.bubbleNotify[strName] + nNum
end

function Class_Hero:IsDressedFate(nFateID)
	for i=1, #self.tbFate do
		if nFateID > 0 and self.tbFate[i] == nFateID then
			return true
		end
	end
	return false
end

--true 表示这件事情没做过 
function Class_Hero:initFirstOpType(tbData)
	--初始化
	self.tbFirstOpSate = {}
	if not tbData or not tbData.first_record then return end
	for k, v in ipairs(tbData.first_record) do
		self.tbFirstOpSate[k - 1] = v
	end
	echoj("=========Class_Hero:initFirstOpType======111====", self.tbFirstOpSate)
end

--true 表示这件事情没做过 
function Class_Hero:GetFirstOpState(OpType)
	if not self.tbFirstOpSate or self.tbFirstOpSate[OpType] == nil then return true end
	return self.tbFirstOpSate[OpType]
end

-- 异兽
function Class_Hero:initFateItem(tbData)
	cclog(" ==========Class_Hero:initFateItem========"..tostring(tbData))
	self.tbFateItem = {}
	self.tbFateUnDressed = {}
	self.tbCountUnDressedInType = {}
	for nType = 1, 16 do
		self.tbCountUnDressedInType[nType] = 0
	end
	local tbFate = tbData.fate_info
	if(tbFate )then
		for i=1, #tbFate do
			local tbItem = tbFate[i]

			local tbFateItem = Class_Fate.new()
			local nServerID, nOwnerID = tbFateItem:initFateData(tbItem)
			self.tbFateItem[nServerID] = tbFateItem

			if(nOwnerID == 0)then
				local nFateType = tbFateItem:getCsvBase().Type
				self.tbCountUnDressedInType[nFateType] = self.tbCountUnDressedInType[nFateType] + 1
				table.insert(self.tbFateUnDressed, nServerID)
			end
		end
	end

	-- echoj("------Class_Hero:initFateItem-----fate--", self.tbFateItem)
end

function Class_Hero:getFateCount(id, starlv, serverId)
	local count = 0
	for _,v in pairs(self.tbFateItem) do
		if v.nCsvID==id and v.nStarLevel==starlv and (not serverId or serverId==v.nServerID) then
			count = count+v.getNum()
		end
	end
	return count
end

function Class_Hero:FreshUnDressFate()
	self.tbFateUnDressed = {}
	self.tbCountUnDressedInType = {}
	for nType = 1, 16 do
		self.tbCountUnDressedInType[nType] = 0
	end
	for key, value in pairs(self.tbFateItem) do
		if(value:getOwnerID() == 0)then
			local tbFateInfo = self:getFateInfoByID(value.nServerID)
			local nFateType = tbFateInfo:getCardFateCsv().Type
			self.tbCountUnDressedInType[nFateType] = self.tbCountUnDressedInType[nFateType] + 1
			table.insert(self.tbFateUnDressed, value.nServerID)
		end
	end
	table.sort(self.tbFateUnDressed, sortFate)
end

function Class_Hero:DressFate(nIndex, nFateID)
	if self.tbFate[nIndex] == 0 then
		self.tbFate[nIndex] = nFateID
		if self.tbFateUnDressed then
			for i=1, #self.tbFateUnDressed do
				if self.tbFateUnDressed[i] == nFateID then
					local tbFateInfo = self:getFateInfoByID(nFateID)
					local nFateType = tbFateInfo:getCardFateCsv().Type
					self.tbCountUnDressedInType[nFateType] = math.max(self.tbCountUnDressedInType[nFateType]-1, 0)
					table.remove(self.tbFateUnDressed, i)
				end
			end
			table.sort(self.tbFateUnDressed, sortFate)
		end
	end
end

function Class_Hero:UnDressFate(nIndex, nFateID)
	if self.tbFate[nIndex] > 0 then
		local tbFateInfo = self:getFateInfoByID(nFateID)
		local nFateType = tbFateInfo:getCardFateCsv().Type
		self.tbCountUnDressedInType[nFateType] = self.tbCountUnDressedInType[nFateType] + 1
		table.insert(self.tbFateUnDressed, self.tbFate[nIndex])
		table.sort(self.tbFateUnDressed, sortFate)
		self.tbFate[nIndex] = 0
	end
end

function Class_Hero:DelFate(nFateID)
	if not nFateID then
		cclog("Class_Hero:DelFate tbFate is nil")
	end

	if self.tbFateUnDressed then
		for i=1, #self.tbFateUnDressed do
			if self.tbFateUnDressed[i] == nFateID then
				local tbFateInfo = self:getFateInfoByID(nFateID)
				local nFateType = tbFateInfo:getCardFateCsv().Type
				self.tbCountUnDressedInType[nFateType] = math.max(self.tbCountUnDressedInType[nFateType]-1, 0)
				table.remove(self.tbFateUnDressed, i)
				break
			end
		end
		table.sort(self.tbFateUnDressed, sortFate)
	end
	self.tbFateItem[nFateID] = nil
end

--获取未装备异兽数据
function Class_Hero:getFateByIndex(nIndex)
	if(not nIndex )then
		return nil
	end

	local nFateID =	self.tbFateUnDressed[nIndex]
	return self.tbFateItem[nFateID]
end

--获取未装备异兽数量
function Class_Hero:getFateUnDressedAmmount()
	return #self.tbFateUnDressed
end

--获取对应类型未装备异兽数量
function Class_Hero:getFateUnDressedAmmountByType(nFateType)
	return self.tbCountUnDressedInType[nFateType]
end

function Class_Hero:getFateIdxById(id)
	if not id then return nil end
	for idx,v in pairs(self.tbFateUnDressed) do
		if v==id then return idx end
	end
end

function Class_Hero:getFateInfoByID(nServerID)
	if(not nServerID )then
		cclog("Class_Hero:getFateInfoByID nil")
		return nil
	end

	-- cclog("========Class_Hero:getFateInfoByID======?  "..nServerID)

	-- echoj("===========Class_Hero:getFateInfoByID=============",self.tbFateItem)

	return self.tbFateItem[nServerID]
end

function Class_Hero:addFate(tbData)
	local tbFateItem = Class_Fate.new()
	local nServerID, nDropOwnerId = tbFateItem:initFateDropData(tbData)
	self.tbFateItem[nServerID] = tbFateItem
	if nDropOwnerId ~= 0 then
		local cardInfo = self:getCardObjByServID(nDropOwnerId)
		if cardInfo then
			cardInfo:setFateID(tbData.drop_owner_pos, nServerID)
		end
		return
	end
	
	--需要更新
	if(not self.tbFateUnDressed)then
		self.tbFateUnDressed = {}
	end

	if(not self.tbCountUnDressedInType)then
		self.tbCountUnDressedInType = {}
		for nType = 1, 16 do
			self.tbCountUnDressedInType[nType] = 0
		end
	end

	local nFateType = tbFateItem:getCardFateCsv().Type
	self.tbCountUnDressedInType[nFateType] = self.tbCountUnDressedInType[nFateType] + 1
	table.insert(self.tbFateUnDressed, nServerID)
	table.sort(self.tbFateUnDressed, sortFate)
end

----------------------------------
--[[* 添加物品信息，也包括资源等,此gm命令使用掉落系统实现
* 命令格式：additem itemname configid nNum star lv;
	注:itemname:物品名称， configid:配置表id star:星级 nNum:物品数量 lv 等级
* itemname 目前支持 {
	card,equip,arraymethod,medicine,god,material,
	soul,exp,energy,coupons,golds, prestige, knowledge,
	}
]]
function Class_Hero:RequestGM(szCommond)
	if(not szCommond or szCommond == "")then
		return
	end
	g_MsgMgr:requestGM(szCommond)
end

---------------------副本相关
--挑战副本服务端返回
function Class_Hero:setBattleRespone(tbMsg)
    local nEctypeID = tbMsg.ectype_star_info.passed_id
    local tbEctypeInfo = g_DataMgr:getMapEctypeCsv(nEctypeID)

    self.nDialogID = tbMsg.dialog_opened_id
	cclog("============返回的副本ID=============="..nEctypeID)
	self.bIsMapFirstFinish = false
	if self.nFinalClearEctypeID < nEctypeID then
		local tbEctypeList = g_DataMgr:getEctypeListByMapBaseID(tbEctypeInfo.MapID)
		if nEctypeID == tbEctypeList[#tbEctypeList] then
			self.bIsMapFirstFinish = true
		end
		self.nFinalClearEctypeID = nEctypeID
		self.nFinalFirstClearEctypeID = nEctypeID
		cclog("============self.nFinalFirstClearEctypeID=============="..self.nFinalFirstClearEctypeID)
	end 
    local tbStars = {}
    tbStars.attack_num = tbMsg.ectype_star_info.attack_num
    tbStars.star = tbMsg.ectype_star_info.star
    self.tbEctypeStars[nEctypeID] = tbStars
	
	local remainEnergy = tbMsg.remain_energy
	self:setEnergy(remainEnergy)
end

function Class_Hero:getIsMapFirstFinish()
	if self.bIsMapFirstFinish then
		self.bIsMapFirstFinish = false
		return true
	end
	return false
end

--获取关卡过关星级
function Class_Hero:getEctypePassStar(nEctypeID)
	return self.tbEctypeStars[nEctypeID]
end

function Class_Hero:setEctypePassNum(nEctypeID,attackNum)
	if self.tbEctypeStars and self.tbEctypeStars[nEctypeID] then 
		self.tbEctypeStars[nEctypeID].attack_num = self.tbEctypeStars[nEctypeID].attack_num + attackNum
	end
end

--取普通副本的地图ID
function Class_Hero:getFinalClearMapID()
	if not self.nFinalClearEctypeID then return 1 end
    if self.nFinalClearEctypeID == 0 then return 1 end

	local nFinalClearMapID = math.floor(self.nFinalClearEctypeID/1000)
	nFinalClearMapID = math.max(nFinalClearMapID, 1)
	nFinalClearMapID = math.min(nFinalClearMapID, #g_DataMgr:getCsvConfig("MapBase"))
	
	return nFinalClearMapID
end

--取普通副本的地图ID
function Class_Hero:getFinalClearEctypeID()
	return self.nFinalClearEctypeID or 0
end

function Class_Hero:getCurEctypeID()
    local nEctypeID = self.nFinalClearEctypeID
    local tbEctypeData = g_DataMgr:getMapEctypeCsv(nEctypeID)
    local tbStar = self:getEctypePassStar(self.nFinalClearEctypeID)
    local nStarLevel = 1
    if tbStar then
        nStarLevel = tbStar.star
    end

	return tbEctypeData["SubEctype"..nStarLevel]
end

function Class_Hero:setEctypePassStars(tbMsg)
    local nMapBaseCsvID = tbMsg.big_passid
    self.tbBigMapRequest[nMapBaseCsvID] = true

	if nMapBaseCsvID == 0 then --数据非法
		local wndInstance = g_WndMgr:getWnd("Game_Ectype")
		if wndInstance then
			wndInstance:showGame_EctypeList(wndInstance:getMaxOpenMapCsvID())
		end
	else
		for key, value in ipairs(tbMsg.ectype_star_info) do
			local nEctypeID = value.passed_id
			if not self.tbEctypeStars[nEctypeID] then
				self.tbEctypeStars[nEctypeID] = {}
			end

			self.tbEctypeStars[nEctypeID].attack_num = value.attack_num
			self.tbEctypeStars[nEctypeID].star = value.star
		end
		
		local wndInstance = g_WndMgr:getWnd("Game_Ectype")
		if wndInstance then
			local nMaxOpenMapCsvID = wndInstance:getMaxOpenMapCsvID()
			if nMapBaseCsvID > nMaxOpenMapCsvID then --不能跳关
				wndInstance:showGame_EctypeList(nMaxOpenMapCsvID)
			else
				wndInstance:showGame_EctypeList(nMapBaseCsvID)
			end
		end
	end
end

--判断大地图id下的副本星级是否请求过
function Class_Hero:checkEctypeBigMapPassInfo(nMapID)
	return self.tbBigMapRequest[nMapID]
end

function Class_Hero:onSignIn(tbMsg)
	if not tbMsg then
		cclog("Class_Hero onSignIn nil")
		return
	end
	self.SignDateStatus = 0
	local tbInfo = tbMsg.sign_in_info
	self.tabSignInInfo = tbInfo
end

function Class_Hero:onSignInRefresh(tbMsg)
	if not tbMsg then
		cclog("Class_Hero onSignInRefresh nil")
		return
	end

	local tbInfo = tbMsg.sign_in_info or {sign_in_count=0, last_sign_in=0}
	self.tabSignInInfo = tbInfo
end

function Class_Hero:getAssistantInfoCount()
	return #self.tbAssistantCsvIdList
end

function Class_Hero:getAssistantInfoByIndex(nIndex)
	return self.tbAssistantInfo[self.tbAssistantCsvIdList[nIndex]]
end

function Class_Hero:getAssistantInfo()
	return self.tbAssistantInfo
end

function Class_Hero:getActivenessInfo()
	return self.activenessInfo
end

function Class_Hero:sortAssistantCsvIdList()
	if not g_CheckFuncCanOpenByWidgetName("Button_Assistant") then return end

	local function sortAssistantCsvIdList(nAssistantCsvId1, nAssistantCsvId2)
		-- 等级足够的，排在前面
			-- 已开放的排在前面
				-- 未完成的，排在前面
					-- 完成百分比大的排在前面
				-- 已完成的，排在后面
					-- 根据CsvID从小到大排序
			-- 同样是未开放的
					-- 根据CsvID从小到大排序
		-- 等级不够的，排在后面
			-- 根据CsvID从小到大排序
		local CSV_ActivityAssistant1 = g_DataMgr:getCsvConfigByOneKey("ActivityAssistant", nAssistantCsvId1)
		local CSV_ActivityAssistant2 = g_DataMgr:getCsvConfigByOneKey("ActivityAssistant", nAssistantCsvId2)
		local nMasterCardLevel = g_Hero:getMasterCardLevel()
		if nMasterCardLevel >= CSV_ActivityAssistant1.OpenLevel and nMasterCardLevel >= CSV_ActivityAssistant2.OpenLevel then
			local tbAssistantInfo1 = g_Hero.tbAssistantInfo[nAssistantCsvId1]
			local tbAssistantInfo2 = g_Hero.tbAssistantInfo[nAssistantCsvId2]
			if tbAssistantInfo1.bIsOpenToday and tbAssistantInfo2.bIsOpenToday then
				if tbAssistantInfo1.nProgress >= 100 and tbAssistantInfo2.nProgress >= 100 then
					return CSV_ActivityAssistant1.AffairsID < CSV_ActivityAssistant2.AffairsID
				elseif tbAssistantInfo1.nProgress >= 100 and tbAssistantInfo2.nProgress < 100 then
					return false
				elseif tbAssistantInfo1.nProgress < 100 and tbAssistantInfo2.nProgress >= 100 then
					return true
				else
					if tbAssistantInfo1.nProgress == tbAssistantInfo1.nProgress then
						return CSV_ActivityAssistant1.AffairsID < CSV_ActivityAssistant2.AffairsID
					else
						return tbAssistantInfo1.nProgress < tbAssistantInfo2.nProgress
					end
				end
			elseif tbAssistantInfo1.bIsOpenToday and (not tbAssistantInfo2.bIsOpenToday) then
				return true
			elseif (not tbAssistantInfo1.bIsOpenToday) and tbAssistantInfo2.bIsOpenToday then
				return false
			else
				return CSV_ActivityAssistant1.AffairsID < CSV_ActivityAssistant2.AffairsID
			end
		elseif nMasterCardLevel >= CSV_ActivityAssistant1.OpenLevel and nMasterCardLevel < CSV_ActivityAssistant2.OpenLevel then
			return true
		elseif nMasterCardLevel < CSV_ActivityAssistant1.OpenLevel and nMasterCardLevel >= CSV_ActivityAssistant2.OpenLevel then
			return false
		else
			return CSV_ActivityAssistant1.AffairsID < CSV_ActivityAssistant2.AffairsID
		end
	end
	table.sort(self.tbAssistantCsvIdList, sortAssistantCsvIdList)
end

function Class_Hero:resetAssitantInfo()
	for k, v in pairs (self.tbAssistantInfo) do
		local bIsOpenToday = true
		local CSV_ActivityAssistant = g_DataMgr:getCsvConfigByOneKey("ActivityAssistant", k)
		if CSV_ActivityAssistant.OpenDay ~= "" then
			local nDate = g_GetServerTime()
			nDate = os.date("%w", nDate)
			if nDate == 0 then
				nDate = 7
			end
			local tbOpenDate = string.split(CSV_ActivityAssistant.OpenDay, "|")
			bIsOpenToday = false
			for key, value in ipairs(tbOpenDate)do
				if nDate == value then
					bIsOpenToday = true
				end
			end
		end

		v.nFinishCount = 0
		v.nProgress = 0
		v.bIsOpenToday = bIsOpenToday
	end
	self:sortAssistantCsvIdList()
end

function Class_Hero:refreshAssitantInfo(tbServerMsg, isRefresh)
	if not tbServerMsg then	return end
	
	--初次构造数据表，后面只更新
	if not self.tbAssistantInfo then
		self.tbAssistantInfo = {}
		self.tbAssistantCsvIdList = {}
		local CSV_ActivityAssistant = g_DataMgr:getCsvConfig("ActivityAssistant")
		local nIndex = 0
		for k, v in pairs (CSV_ActivityAssistant) do
			if v.IsOpen == 1 then
				nIndex = nIndex + 1
				self.tbAssistantCsvIdList[nIndex] = k

				local bIsOpenToday = true
				if v.OpenDay ~= "" then
					local nDate = g_GetServerTime()
					nDate = os.date("%w", nDate)
					if nDate == 0 then
						nDate = 7
					end
					local tbOpenDate = string.split(v.OpenDay, "|")
					bIsOpenToday = false
					for k, v in ipairs(tbOpenDate)do
						if nDate == v then
							bIsOpenToday = true
						end
					end
				end

				self.tbAssistantInfo[k] = {}
				self.tbAssistantInfo[k].nAssistantCsvId = k
				self.tbAssistantInfo[k].nFinishCount = 0
				self.tbAssistantInfo[k].nProgress = 0
				self.tbAssistantInfo[k].bIsOpenToday = bIsOpenToday
			end
		end
	end

	local tbAssistantServerInfo = tbServerMsg.record
	for i = 1, #tbAssistantServerInfo do
        local nAssistantCsvId = tbAssistantServerInfo[i].type
		local CSV_ActivityAssistant = g_DataMgr:getCsvConfigByOneKey("ActivityAssistant", nAssistantCsvId)
		if CSV_ActivityAssistant.IsOpen == 1 then
			local nFinishCount = tonumber(tbAssistantServerInfo[i].attend_count)
			local nMaxNum = g_VIPBase:getVipMaxTimes(nAssistantCsvId)
			local nProgress = math.floor(nFinishCount*100/nMaxNum)
			if nProgress >= 100 then
				nProgress = 100
			end
			self.tbAssistantInfo[nAssistantCsvId].nFinishCount = nFinishCount
			self.tbAssistantInfo[nAssistantCsvId].nProgress = nProgress
		end
	end
	
	self:sortAssistantCsvIdList()

	if isRefresh then
		self.activenessInfo = { activeness = tbServerMsg.activeness, nCurRewardLv = tbServerMsg.cur_reward_lv }
	else
		self.activenessInfo.activeness = tbServerMsg.activeness
	end
end

function Class_Hero:onAssistantReward(tbServerMsg)
	self.activenessInfo.nCurRewardLv = tbServerMsg.cur_reward_lv
end

function Class_Hero:sorthAssitantInfo(tbServerMsg)
	self.activenessInfo.nCurRewardLv = tbServerMsg.cur_reward_lv
end


function Class_Hero:ClientUpdateAssistant(nType)
	if not self.activenessInfo then return end
	if not nType then return end
	local CSV_ActivityAssistant = g_DataMgr:getCsvConfigByOneKey("ActivityAssistant", nType)
	
	self.tbAssistantInfo = self.tbAssistantInfo or {}
	local nFinishCount = self.tbAssistantInfo[nType] or 0
	if nFinishCount >= tonumber(CSV_ActivityAssistant.EventMaxNum) then return end
	self.tbAssistantInfo[nType] = self.tbAssistantInfo[nType] or {}
	self.tbAssistantInfo[nType].nFinishCount = self.tbAssistantInfo[nType].nFinishCount or 1
	self.tbAssistantInfo[nType].nFinishCount = nFinishCount + 1
	local activeness = self.activenessInfo.activeness
	self.activenessInfo.activeness = activeness+tonumber(CSV_ActivityAssistant.ActiveNess)
end

function Class_Hero:getRewardInfo()
	return self.tbReward
end

function Class_Hero:delRewardInfo(reward_id)
	if self.tbReward then
        if self.tbReward[reward_id] then
		    self.tbReward[reward_id] = nil
        end
	end
end

function Class_Hero:getRewardActivate(nRewardCsvId)
	if self.tbReward and self.tbReward[nRewardCsvId] then
		if nRewardCsvId == common_pb.RewardType_AM_Energy or nRewardCsvId == common_pb.RewardType_PM_Energy then --体力奖励
			local CSV_ActivityReward = g_DataMgr:getCsvConfigByTwoKey("ActivityReward", nRewardCsvId, 1)
			local nStartMin = CSV_ActivityReward.StartHour*60 + CSV_ActivityReward.StartMin
			local nEndMin = CSV_ActivityReward.EndHour*60 + CSV_ActivityReward.EndMin
			local nMin = g_GetServerHour()*60 + g_GetServerMin()
			if nMin >= nStartMin and nMin <= nEndMin then
				return self.tbReward[nRewardCsvId]
			end
		else
			return self.tbReward[nRewardCsvId]
		end
	end
	return nil
end

function Class_Hero:setRewardInfo(tbServerMsg)
	if not tbServerMsg then return end
	self.tbReward = self.tbReward or {}
	for k, v in ipairs (tbServerMsg) do
		local tbRewardTemp = {}
		tbRewardTemp.reward_lv = v.reward_lv
		tbRewardTemp.reward_data = v.reward_data
		tbRewardTemp.reward_id = v.reward_id
		tbRewardTemp.ordinary_card_timeout = v.ordinary_card_timeout
		if tbRewardTemp.reward_id == common_pb.RewardType_AM_Energy or tbRewardTemp.reward_id == common_pb.RewardType_PM_Energy then --体力奖励
			tbRewardTemp.bEnabled = false
			
			local CSV_ActivityReward = g_DataMgr:getCsvConfigByTwoKey("ActivityReward", v.reward_id, 1)
			local nStartMin = CSV_ActivityReward.StartHour*60 + CSV_ActivityReward.StartMin
			local nEndMin = CSV_ActivityReward.EndHour*60 + CSV_ActivityReward.EndMin
			local nMin = g_GetServerHour()*60 + g_GetServerMin()
			if nMin >= nStartMin and nMin <= nEndMin then
				tbRewardTemp.bEnabled = true
			end
		else
			tbRewardTemp.bEnabled = true
		end
		self.tbReward[tbRewardTemp.reward_id] = tbRewardTemp
	end
end

function Class_Hero:ShopRecharge(msgDetail)
	--
	self:setYuanBao(msgDetail.coupon)
	
	g_VIPBase:setVipLevel(msgDetail.vip_level)
	
	self:addChargeYuanBao(msgDetail.total_recharge_value - self:getTotalChargeYuanBao())
	
	self:setTotalChargeYuanBao(msgDetail.total_recharge_value)
	
	local nLastVipLev = self:getVIPLevel()
	if g_Hero.tabZhaoCaiFuInfo and nLastVipLev < msgDetail.vip_level then
		
		local CSV_VipLevelLastLev = g_DataMgr:getCsvConfigByOneKey("VipLevel", nLastVipLev + 1)
		local nZhaoCaiMaxNumLastLev = CSV_VipLevelLastLev.ZhaoCaiMaxNum
		
		local CSV_VipLevelCurLev = g_DataMgr:getCsvConfigByOneKey("VipLevel", msgDetail.vip_level + 1)
		local nZhaoCaiMaxNumCurLev = CSV_VipLevelCurLev.ZhaoCaiMaxNum
		g_Hero.tabZhaoCaiFuInfo.countLeft = g_Hero.tabZhaoCaiFuInfo.countLeft + nZhaoCaiMaxNumCurLev - nZhaoCaiMaxNumLastLev
	end
end

function Class_Hero:BagSell(tbMsgDetail)
	local nType = tbMsgDetail.type
	local nRemainNum = tbMsgDetail.num_left
	local nCsvID = tbMsgDetail.config_id
	local nStarLevel = tbMsgDetail.lv
	local nServerID = tbMsgDetail.server_id
	if nType == macro_pb.ITEM_TYPE_MATERIAL then
		self:setItemByCsvIdAndStar(nCsvID, nStarLevel, nRemainNum)
	elseif nType == macro_pb.ITEM_TYPE_SOUL then
		self:setSoul(nServerID, nRemainNum)
	elseif nType == macro_pb.ITEM_TYPE_CARD_GOD then
		self:setHunPoNum(nServerID, nRemainNum)
	end
end

function Class_Hero:checkReportNumFull()
	return self:checkReportCardNumFull() or
		self:checkReportEquipNumFull() or
		self:checkReportFateNumFull()
end

function Class_Hero:checkReportFateNumFull()
	if self:getFateUnDressedAmmount()>=self:getMaxFateNum() then
		local szText = g_DataMgr:getMsgContentCsv(2041)
		local curScene = CCDirector:sharedDirector():getRunningScene()
		g_ShowServerSysTips({text= szText.Description_ZH,layout = curScene})
		return true
	end
	return false
end

function Class_Hero:checkReportCardNumFull()
	if self:getCardsAmmount()>=self:getMaxCardNum() then
		local szText = g_DataMgr:getMsgContentCsv(2038)
		local curScene = CCDirector:sharedDirector():getRunningScene()
		g_ShowServerSysTips({text = szText.Description_ZH,layout = curScene})
		return true
	end
	return false
end

-- function Class_Hero:buyExtraSpace(tbMsg)
	-- self:setYuanBao(tbMsg.total_coupons)
	-- local t = tbMsg.type
	-- self.tbExtraSpace = self.tbExtraSpace or {}
	-- self.tbExtraSpace[t] = tbMsg.extra_space
-- end

--清空物品
function Class_Hero:ClearItem(tbMsg)
	local item_type = tbMsg.item_type
	if item_type == macro_pb.ITEM_TYPE_CARD then
		for i=1, #tbMsg.del_idlst do
			self:DelCardByID(tbMsg.del_idlst[i])
		end
	elseif item_type == macro_pb.ITEM_TYPE_EQUIP then
		for i=1, #tbMsg.del_idlst do
			self:delEquopByServID(tbMsg.del_idlst[i])
		end
	elseif item_type == macro_pb.ITEM_TYPE_FATE then
		for i=1, #tbMsg.del_idlst do
			self:DelFate(tbMsg.del_idlst[i])
		end
	elseif item_type == macro_pb.ITEM_TYPE_CARD_GOD then
		for i=1, #tbMsg.del_idlst do
			self:delHunPo(tbMsg.del_idlst[i])
		end
	elseif item_type == macro_pb.ITEM_TYPE_MATERIAL then
		for i=1, #tbMsg.del_idlst do
			for key, value in pairs(self.tbItemList) do
				if value.nServerID==tbMsg.del_idlst[i] then
					table.remove(self.tbItemList, key)
					break
				end
			end
		end
	elseif item_type == macro_pb.ITEM_TYPE_SOUL then
		for k=1, #tbMsg.del_idlst do
			local tbSoulNew = {}
			for i=1, #self.tbSoulList do
				local bInsert = true
				if self.tbSoulList[i].nServerID == tbMsg.del_idlst[k] then
					bInsert = false
				end
				if bInsert == true then
					table.insert(tbSoulNew, self.tbSoulList[i])
				end
			end
			self.tbSoulList = tbSoulNew
		end
	end
end

function Class_Hero:setDialogTalkID(nServerID)
	self.nDialogTalkID = nServerID
end

function Class_Hero:getDialogTalkID()
	return self.nDialogTalkID or 0
end

function Class_Hero:dailyUpdate()
	local wnds = {
		"Game_Activity",	-- 活动
		"Game_Assistant",	-- 助手
		"Game_Registration1",	-- 签到
		"Game_ZhaoCaiFu",	-- 招财
		--30, -- 竞技场
	}
	for _,id in pairs(wnds) do
		local visible = g_WndMgr:isVisible(id)
		if visible then g_WndMgr:closeWnd(id) end
		g_WndMgr:destroyWnd(id)
		if visible then g_WndMgr:openWnd(id) end
	end
end

function Class_Hero:getAchievementInfo()
	return self.tbAchievementInfo
end

function Class_Hero:achievementRefresh(msg)
	-- self.tbAchievementInfo = {complete={}, record={}, extra={}}
	-- for _,v in pairs(msg.info_list) do
	-- 	if v.id then table.insert(self.tbAchievementInfo.complete, v) end
	-- end
	-- self.tbAchievementInfo.record = msg.record
	-- local extra = {}
	-- extra.vip = msg.vip
	-- extra.role_lv = msg.role_lv
	-- extra.farm_extend_exp = msg.farm_extend_exp
	-- extra.farm_extend_money = msg.farm_extend_money
	-- extra.farm_field_lv = msg.farm_field_lv
	-- extra.bag_extend = msg.bag_extend
	-- extra.pass_hard_city = msg.pass_hard_city
	-- extra.pass_hero_city = msg.pass_hero_city
	-- extra.star3_pass_city = msg.star3_pass_city
	-- self.tbAchievementInfo.extra = extra
end

function Class_Hero:achievementComplete(msg)
	if not self.tbAchievementInfo or not self.tbAchievementInfo.complete then return false end
	table.insert(self.tbAchievementInfo.complete, msg.info)
	return true
end

function Class_Hero:achievementGetReward(msg)
	for _,v in pairs(self.tbAchievementInfo.complete) do
		if v.id==msg.type*100+msg.id then
			v.rewarded = true
			break
		end
	end
end

function Class_Hero:achievementOnEvent(msg)
	setAchievementProgress(msg.type, msg.total)
end

function Class_Hero:updateDailyNotice(tbDailyNotice)
	if not self.tbDailyNotice then
		self.tbDailyNotice = {}
	end
	for k, v in ipairs(tbDailyNotice) do
		self.tbDailyNotice[v.type] = v.daily_data
	end
end

function Class_Hero:getDailyNoticeByType(nType)
	return self.tbDailyNotice[nType] or 0
end

function Class_Hero:setDailyNoticeByType(nType, nNoticeNum)
	local nNoticeNum = nNoticeNum or 0
	self.tbDailyNotice[nType] = nNoticeNum
end

function Class_Hero:incDailyNoticeByType(nType)
    self.tbDailyNotice[nType] = self.tbDailyNotice[nType] + 1
end

function Class_Hero:getDailyNoticeLimitByType(nType)
	if nType == macro_pb.Buy_Enerngy_Times then
		return g_DataMgr:getGlobalCfgCsv("max_buy_energytimes")
	elseif nType == macro_pb.Sign_Up_Times then
		return 1
	elseif nType == macro_pb.Gain_Enerngy_Times then
		return 1
	elseif nType >= macro_pb.Buy_Shop_Use_Prestige1 and nType <= macro_pb.Buy_Shop_Use_Prestige12 then
		return 0
	elseif nType == macro_pb.TurntableTimes then --转盘次数
		return g_DataMgr:getGlobalCfgCsv("turn_attend_num")
	elseif nType == macro_pb.HuntFateTimes then --猎命免费次数
		return g_DataMgr:getGlobalCfgCsv("free_hunt_fate_times")
	elseif nType == macro_pb.BaXianIncenstTimes	 then --八仙上香次数
		return 1
	elseif nType == macro_pb.Incense_Times then --土地公上香最大次数
		return 1
	elseif nType == macro_pb.Cross_Arena_Challenge_Times then --跨服天榜
		return 10
	end
	
	return 0
end

function Class_Hero:IsDailyNoticeFull(nType)
	local nLimit = self:getDailyNoticeLimitByType(nType)
	local nTimes = self:getDailyNoticeByType(nType)
	return nTimes >= nLimit
end

--获取好友上限
function Class_Hero:getFriendNumMax()
	return g_VIPBase:getVipValue("FriendMaxNum")
end

function Class_Hero:setSignUpTimes(nTimes)
	--self.tabSignInInfo = self.tabSignInInfo or {sign_in_count=0, last_sign_in=0}
	self.tabSignInInfo.sign_in_count = nTimes
end

function Class_Hero:getSignUpTimes()
	--self.tabSignInInfo = self.tabSignInInfo or {sign_in_count=0, last_sign_in=0}
	return  self.tabSignInInfo.sign_in_count
end

function Class_Hero:getSignDateStatus()
	return  self.SignDateStatus
end

-- function Class_Hero:updateIncense(tbMsg)
    -- if not tbMsg then return  end

    -- self:setYuanBao(tbMsg.updated_coupons)
    -- self:setPrestige(tbMsg.updated_prestige)
    -- self:setKnowledge(tbMsg.updated_knowledge)

	-- local farm = g_FarmData:getFarmRefresh()
	
    -- local incense_aura = tbMsg.updated_aura - farm.field_exp
    -- farm.field_exp = tbMsg.updated_aura
    -- farm.incense_times = tbMsg.incense_times

    -- return incense_aura
-- end

-------------系统通知------------------------
function Class_Hero:getTbNotice(nType)
	if not self.tbNotice then
		self.tbNotice = {}
	end
	return self.tbNotice[nType] or 0
end

function Class_Hero:setTbNotice(nType, tbMsg)
	if not self.tbNotice then
		self.tbNotice = {}
	end
	self.tbNotice[nType] = tbMsg
	return self.tbNotice
end

function Class_Hero:setTbNoticeForDoubleKey(nType, tbMsg)
	self.tbNotice = self.tbNotice or {}
	self.tbNotice[nType] = self.tbNotice[nType] or {}
    local nCardID = tbMsg.cardid
    local nPosIndex = tbMsg.posidx

	self.tbNotice[nType][nCardID] = self.tbNotice[nType][nCardID] or {}
	if tbMsg.num > 0 then
		self.tbNotice[nType][nCardID][nPosIndex] = tbMsg.num
	else
		self.tbNotice[nType][nCardID][nPosIndex] = nil
	end
end

function Class_Hero:getTbNoticeByType(nType)
	if not self.tbNotice then  return false  end

	return self.tbNotice[nType]
end

function Class_Hero:checkTbNoticeByTbKey(key, tbKey)
	if not key then return false end

    local tbData = self:getTbNoticeByType(key)
    if not tbData then return false end

    if  not tbKey then
        tbKey = {nCardID = 0, nPosIndex = 0}
    end

    if not tbData[tbKey.nCardID] or  not tbData[tbKey.nCardID][tbKey.nPosIndex] then  return false end

    return tbData[tbKey.nCardID][tbKey.nPosIndex] > 0
end

--渡劫卡牌阵型
function Class_Hero:getDuJieArray()
	return self.tbMasterBase.dujie_array
end

function Class_Hero:setDuJieArray(nIndex,card_idx)
	self.tbMasterBase.dujie_array[nIndex].card_idx = card_idx
end

--渡劫当前选择的阵型
function Class_Hero:getDuJieMethodIndex()
	return self.tbMasterBase.cur_dujie_method_id 
end

function Class_Hero:setDuJieMethodIndex(nIndex)
	self.tbMasterBase.cur_dujie_method_id = nIndex
end

function Class_Hero:getIgend()
	return self.tbMasterBase.nSex
end

------------------------MSG---------------------
--战斗力更新
function Class_Hero:OnRespondAttributeUpdate(tbMsg)
	local msgMoreCard = zone_pb.MoreCardAttrUpdate()
	msgMoreCard:ParseFromString(tbMsg.buffer)

	for k, v in ipairs(msgMoreCard.card_list)do
		local  msg = v
		if not self.CardList or not self.CardList[msg.card_id] then return end

		if msg.fight_point > 1 then --战力
	
			if self.CardList[msg.card_id].fight_point and self.CardList[msg.card_id].fight_point > 0 then --更新
				local context = {}
				context.nold = self.CardList[msg.card_id].fight_point
				context.nend = msg.fight_point
				if context.nold ~= context.nend then
					g_FormMsgSystem:SendFormMsg(FormMsg_Compose_Strength, context)
				end
			else
				self.LastFight = self:getTeamStrength() or 0
			end
			self.CardList[msg.card_id].fight_point = msg.fight_point
			cclog("=============服务端发送战斗力=================="..msg.fight_point)
		end

		if msg.pre_attack > 1 then --队伍中单个卡牌的先攻值
			self.CardList[msg.card_id].preattack = msg.pre_attack
		end
		--后续的加在后面
	end
end


function Class_Hero:OnRespondCardList(tbMsg)
	local msg = zone_pb.InitCardListNotify()
	msg:ParseFromString(tbMsg.buffer)
	cclog("===========Class_Hero:OnRespondCardList == "..tostring(msg))

	self:initCard(msg)
end


function Class_Hero:OnRespondUpdataCardList(tbMsg)
	local msg = zone_pb.UpdateMaterial()
	msg:ParseFromString(tbMsg.buffer)
	cclog("===========Class_Hero:OnRespondUpdataCardList == "..tostring(msg))
	self:UpdataItemList(msg.material_info)
end


function Class_Hero:OnRespondEquipList(tbMsg)
	local msg = zone_pb.InitEquipListNotify()
	msg:ParseFromString(tbMsg.buffer)
	--cclog("===========Class_Hero:OnRespondEquipList == "..tostring(msg))

	self:initEquipList(msg)
end


function Class_Hero:OnRespondMaterialList(tbMsg)
	local msg = zone_pb.InitMaterialListNotify()
	msg:ParseFromString(tbMsg.buffer)
	cclog("===========Class_Hero:OnRespondMaterialList == "..tostring(msg))

	self:initItemList(msg.material_info)
end


function Class_Hero:OnRespondFateList(tbMsg)
	local msg = zone_pb.InitFateInfoListNotify()
	msg:ParseFromString(tbMsg.buffer)
	--cclog("===========Class_Hero:OnRespondFateList == "..tostring(msg))

	self:initFateItem(msg)
end


function Class_Hero:OnsprondFirstOpTyep(tbMsg)
	local msg = zone_pb.FinishFirstOpType()
	msg:ParseFromString(tbMsg.buffer)
	cclog("===========Class_Hero:OnsprondFirstOpTyep == "..tostring(msg))

   
	if self.tbFirstOpSate and self.tbFirstOpSate[msg.type] then
		self.tbFirstOpSate[msg.type] = false
	end

    --if msg.type == macro_pb.FirstOpType_Recharge then 
        --如果充值界面打开着，需要更新充值界面
        g_FormMsgSystem:SendFormMsg(FormMsg_ReCharge_UpdataWnd, nil)
   -- end
	

end

