--------------------------------------------------------------------------------------
-- 文件名:	ChuanChengData.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	传承数据 主角不能传承
-- 应  用:  
---------------------------------------------------------------------------------------

ChuanChengData = class("ChuanChengData")
ChuanChengData.__index = ChuanChengData


--交换等级和经验
-- function ChuanChengData:exchangeLevelByExp(cardId,nLevel,nExp)
	-- local cardInfo = g_Hero:getCardObjByServID(cardId)
	
	-- cardInfo:setLevel(nLevel)
	-- cardInfo:setExp(nExp)
-- end

--交换等级和经验
function ChuanChengData:exchangeLevelByExp(cardId1,cardId2)
	local cardInfo1 = g_Hero:getCardObjByServID(cardId1)
	local cardInfo2 = g_Hero:getCardObjByServID(cardId2)
	
	local level1 = cardInfo1:getLevel()
	local level2 = cardInfo2:getLevel()	
	
	local exp1 = cardInfo1:getExp()
	local exp2 = cardInfo2:getExp()
	
	cardInfo1:setLevel(level2)
	cardInfo2:setLevel(level1)
	cardInfo1:setExp(exp2)
	cardInfo2:setExp(exp1)

end

--交换武器属性 类型也交换 --交换防具属性 
function ChuanChengData:exchangeEquip(cardId,equipIdList,csvId)
	--卸下
	local cardInfo = g_Hero:getCardObjByServID(cardId)
	for i = 1,6 do 
		local nEquipID = cardInfo:getEquipIDByPos(i)
		if nEquipID > 0 then 
			local equipData = g_Hero:getEquipObjByServID(nEquipID)
			cardInfo:changeEquipIDByPos(i, 0, "Undress",  equipData, nil)
		end
	end

	--穿上
	local cardInfo = g_Hero:getCardObjByServID(cardId)

	for index = 1,#equipIdList do 
		local equipServerID = equipIdList[index] 
		if equipServerID > 0 then 
			if index == 1  then 
				local equipData = g_Hero:getEquipObjByServID(equipServerID)
				if csvId > 0 then --在同类型武器传承的时候 配置ID 为零 不修改
					equipData:setEquipCsvID(csvId)
				end
				--传承后需要更新
				equipData.tbEquipCsv = g_DataMgr:getCsvConfigByOneKey("Equip",csvId)
				local id = csvId
				if id <= 0 then  id =  equipData:getCsvBase().ID end
				
				equipData:setOwnerID(id)
				cardInfo:changeEquipIDByPos(1, equipServerID, "Dress", nil, equipData)
				
				local starLv = equipData:getCsvBase().StarLevel
				local starLevel = equipData:getStarLevel()
				local csvEquip = g_DataMgr:getEquipCsv(id,starLv)
				equipData:setCsvBase(csvEquip)
				
			else
				--交换防具属性 
				local equipData = g_Hero:getEquipObjByServID(equipServerID)
				--设置装备所装备的伙伴ID
				equipData:setOwnerID(cardId)

				equipData:setEquipServerId(equipServerID) 
				cardInfo:setCardEquipID(index,equipServerID)
			
			end
		end
	end

end



--交换境界
function ChuanChengData:exchangRealm(cardId,relamLv,relamExp)
	local cardInfo = g_Hero:getCardObjByServID(cardId) 
	cardInfo:setReleamProp(relamLv,relamExp)
end

--交换上香
function ChuanChengData:exchangShangXiang(cardID,accuPropValue)
	local tbCard = g_Hero:getCardObjByServID(cardID)
	local csXiangData = tbCard:getCSXiangData()
	for i = 1,#accuPropValue do
		csXiangData:setAccuPropValue(i,accuPropValue[i])
	end
	-- tbCard:initCardPropAll()
end

--异兽操作
function ChuanChengData:operateFate(operation, cardInfo)
	for k, v in pairs(cardInfo.tbFateIdList) do
		local tbFateInfo = g_Hero:getFateInfoByID(v)
		if tbFateInfo then
			if "Dress" == operation then
				cardInfo:reCalculateFateProps(operation, nil, tbFateInfo)
				tbFateInfo:setOwnerID(cardInfo.nServerID)
			elseif "Undress" == operation then
				cardInfo:reCalculateFateProps(operation, tbFateInfo)
			end
		end
	end
end

--交换异兽 脱了再穿
function ChuanChengData:exchangFate(cardId1, cardId2)
	local cardInfo1 = g_Hero:getCardObjByServID(cardId1)
	self:operateFate("Undress", cardInfo1)
	local cardInfo2 = g_Hero:getCardObjByServID(cardId2)
	self:operateFate("Undress", cardInfo2)

	cardInfo1.tbFateIdList, cardInfo2.tbFateIdList = cardInfo2.tbFateIdList, cardInfo1.tbFateIdList
	cardInfo1.tbFatePosIndexInType, cardInfo2.tbFatePosIndexInType = cardInfo2.tbFatePosIndexInType, cardInfo1.tbFatePosIndexInType

	self:operateFate("Dress", cardInfo1)
	self:operateFate("Dress", cardInfo2)

end

--交换技能
function ChuanChengData:exchangSkill(cardId,breachLv,skillLvList,danyaoLvList)
	local cardInfo = g_Hero:getCardObjByServID(cardId)
	
	--突破等级
	if breachLv == 0  then breachLv = 1 end
	cardInfo:setEvoluteLevel(breachLv)
	for nSkillIndex = 1,3  do 
		--技能等级
		local skillLv = skillLvList[nSkillIndex]
		cardInfo:setSkillLevel(nSkillIndex,skillLv)
	end

	local skillIndexCount = 1
	for i = 1,9 do
		local danyaoIdx = i --卡牌丹药索引
		local danyaoLv = danyaoLvList[i] --卡牌丹药等级
		danyaoIdx = danyaoIdx % 3
		if danyaoIdx == 0 then  danyaoIdx = 3  end
		cardInfo:setDanyaoLvList(skillIndexCount, danyaoIdx, danyaoLv)
		if danyaoIdx == 3 then 
			skillIndexCount = skillIndexCount + 1
		end
	end

end


function ChuanChengData:ctor()
	-- MSGID_INHERIT_CARD_REQUEST = 612;				//传承请求	InheritCardRequest
	-- MSGID_INHERIT_CARD_RESPONSE = 613;				//传承响应	InheritCardResponse
	-- MSGID_INCENSE_OVER_AJUST_NOTIFY = 614;			//上香溢出值调整通知  IncenseOverAdjustNotify   传承或者升级导致调整，就会通知
	
	local order = msgid_pb.MSGID_INCENSE_OVER_AJUST_NOTIFY	
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.incenseOverAdjustNotifyResponse))		
	
	local order = msgid_pb.MSGID_INHERIT_CARD_RESPONSE	
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestRIheritCardResponse))	
	
end

--上香溢出值调整通知 传承或者升级导致调整，就会通知
function ChuanChengData:incenseOverAdjustNotifyResponse(tbMsg)
	cclog("---------incenseOverAdjustNotifyResponse------上香溢出值调整通知-------")
	local msgDetail = zone_pb.IncenseOverAdjustNotify()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	
	local cardID = msgDetail.card_id --服务器id
	local accuPropValue = msgDetail.accu_prop_value --上香累计值数组， 生命 武力 法术 绝技
	
	self:exchangShangXiang(cardID,accuPropValue)
	
end


function ChuanChengData:requestInheritCardRequest(cardIdOne,cardIdTwo)

	local msg = zone_pb.InheritCardRequest()
	msg.card1_id = cardIdOne
	msg.card2_id = cardIdTwo
	g_MsgMgr:sendMsg(msgid_pb.MSGID_INHERIT_CARD_REQUEST, msg)
	
end


function ChuanChengData:requestRIheritCardResponse(tbMsg)
	cclog("---------requestRIheritCardResponse------传承-------")
	local msgDetail = zone_pb.InheritCardResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	local info1 = msgDetail.info1 
	local info2 = msgDetail.info2
	
	local nCardIdOne = info1.card_id --服务器id, 
	-- local nEquipServerIdOne = info1.equip_server_id 
	local nEquipNewCfgIdOne =  info1.equip_new_cfg_id 
	-- local cardLv = info1.card_lv  
	-- local cardExp = info1.card_exp
	local relamLv = info1.relam_lv 
	local relamExp = info1.relam_exp 
	local equipIdList = info1.equip_id_lst --全部装备服务器id。 如果没穿的位置，发0
	local breachLv = info1.breachlv --突破等级
	local skillLvList = info1.skill_lv_list--技能等级列表
	local danyaoLvList = info1.danyao_lv_list -- 丹药等级列表 0开始
	local accuPropValue = info1.accu_prop_value
	
	self:exchangRealm(nCardIdOne,relamLv,relamExp)	--境界等级 经验
	--武器 防具
	self:exchangeEquip(nCardIdOne,equipIdList,nEquipNewCfgIdOne)
	--技能 丹药 突破等级
	self:exchangSkill(nCardIdOne,breachLv,skillLvList,danyaoLvList)
	--上香
	self:exchangShangXiang(nCardIdOne,accuPropValue)
	
	
	--被传承者-----------------------------------------
	local nCardIdTwo = info2.card_id 
	-- local nEquipServerIdTwo = info2.equip_server_id
	local nEquipNewCfgIdTwo = info2.equip_new_cfg_id --武器配置Id 武器修改
	-- local cardLv = info2.card_lv  --卡牌等级
	-- local cardExp = info2.card_exp --卡牌经验
	local relamLv = info2.relam_lv --境界等级
	local relamExp = info2.relam_exp --境界经验
	local equipIdList = info2.equip_id_lst --全部装备服务器id。 如果没穿的位置，发0
	local breachLv = info2.breachlv --突破等级
	local skillLvList = info2.skill_lv_list--技能等级列表
	local danyaoLvList = info2.danyao_lv_list -- 丹药等级列表 0开始
	local accuPropValue = info2.accu_prop_value --上香数据
	

	self:exchangRealm(nCardIdTwo,relamLv,relamExp)	--境界等级 经验
	self:exchangeEquip(nCardIdTwo,equipIdList,nEquipNewCfgIdTwo)
	self:exchangSkill(nCardIdTwo,breachLv,skillLvList,danyaoLvList)
	self:exchangShangXiang(nCardIdTwo,accuPropValue)
	
	self:exchangFate(nCardIdOne,nCardIdTwo)

	--等级 经验更新
	self:exchangeLevelByExp(nCardIdOne,nCardIdTwo)
	
	local cardInfo1 = g_Hero:getCardObjByServID(nCardIdOne)
	cardInfo1:initCardPropAll()	
	local cardInfo2 = g_Hero:getCardObjByServID(nCardIdTwo)
	cardInfo2:initCardPropAll()
	
	g_WndMgr:closeWnd("Game_ChuanCheng")
	
	local inheritCardCost = g_DataMgr:getGlobalCfgCsv("inherit_card_cost")
	gTalkingData:onPurchase(TDPurchase_Type.TDP_ACTIVITY_CHUAN_CHENG_NUM, 1, inheritCardCost)
	
end

function ChuanChengData:shangXiangInfo(tbCard)
		--key1:职业，key2:星级
	local CSV_CardBase = tbCard:getCsvBase()
	local starLevel = tbCard:getStarLevel()
	
	local csXiangData = tbCard:getCSXiangData()
	local accuPropValue = csXiangData:getAccuPropValue()
	
	local cardIncense = g_DataMgr:getCsvConfigByOneKey("CardIncense",tbCard:getLevel())

	local ProfessionModuls = g_DataMgr:getCsvConfigByTwoKey("ProfessionModuls",CSV_CardBase.Profession,starLevel)
	
	local tbCardIncense = {
		cardIncense.HPMax,
		cardIncense.ForcePoints,
		cardIncense.MagicPoints,
		cardIncense.SkillPoints,
	}
	local tbModuls = {
		ProfessionModuls.incense_hpmax_moduls,
		ProfessionModuls.incense_forcepoints_moduls,
		ProfessionModuls.incense_magicpoints_moduls,
		ProfessionModuls.incense_skillpoints_moduls,
	}
	return accuPropValue,tbCardIncense,tbModuls
end


function ChuanChengData:shangXiangSpill(nCardId1,nCardId2)

	local tbCard1 = g_Hero:getCardObjByServID(nCardId1)
	local accuPropValue1,tbCardIncense1,tbModuls1 = self:shangXiangInfo(tbCard1)	

	local tbCard2 = g_Hero:getCardObjByServID(nCardId2)
	local accuPropValue2,tbCardIncense2,tbModuls2 = self:shangXiangInfo(tbCard2)
	
	for i = 1,4 do
		local upperLimit1 = math.floor(tbCardIncense1[i] * tbModuls1[i] / g_BasePercent)
		local curPropValue1 = accuPropValue1[i]	
		
		local upperLimit2 = math.floor(tbCardIncense2[i] * tbModuls2[i] / g_BasePercent)
		local curPropValue2 = accuPropValue2[i]
		if curPropValue1 > upperLimit2 or curPropValue2 > upperLimit1 then 
			return true
		end
	end
	return false
end


g_CardChuanChengData = ChuanChengData.new()
