--[[
******游戏数据角色管理类*******

	-- by Stephen.tao
	-- 2013/12/05

	-- by haidong.gan
	-- 2014/4/10
]]

local CardRoleManager = class("CardRoleManager");

local CardRole      = require('lua.gamedata.base.CardRole');
local CardEquipment = require('lua.gamedata.base.CardEquipment');
local CardSkyBook = require('lua.gamedata.base.CardSkyBook');

CardRoleManager.GET_ROLE 	 		= "CardRoleManager.GET_ROLE"

CardRoleManager.LEVEL_INFO 		= "CardRoleManager.LEVEL_INFO"
CardRoleManager.EXP_CHANGED 	= "CardRoleManager.EXP_CHANGED"

CardRoleManager.OBTAIN_PARTNER 		= "CardRoleManager.OBTAIN_PARTNER"
CardRoleManager.REMOVE_PARTNER 	 	= "CardRoleManager.REMOVE_PARTNER"

CardRoleManager.LEADING_ROLE_SPELL_LIST 	= "CardRoleManager.LEADING_ROLE_SPELL_LIST"
CardRoleManager.SPELL_LEVEL_UP_NOTIFY 	 	= "CardRoleManager.SPELL_LEVEL_UP_NOTIFY"
CardRoleManager.ROLE_SPELL_ENABLE_NOTIFY 	= "CardRoleManager.ROLE_SPELL_ENABLE_NOTIFY"
CardRoleManager.SELECT_SPELL_RESULT 	 	= "CardRoleManager.SELECT_SPELL_RESULT"

CardRoleManager.UPDATE_ALL_ROLE_TRAIN_INFO 		= "CardRoleManager.UPDATE_ALL_ROLE_TRAIN_INFO"
CardRoleManager.UPDATE_ROLE_TRAIN_INFO 	   		= "CardRoleManager.UPDATE_ROLE_TRAIN_INFO"
CardRoleManager.REFRESH_ACUPOINT_MSG_RESULT  	= "CardRoleManager.REFRESH_ACUPOINT_MSG_RESULT"
CardRoleManager.ACUPOINT_LEVEL_UP_RESULT  	= "CardRoleManager.ACUPOINT_LEVEL_UP_RESULT"
CardRoleManager.ROLE_BREAKTHROUGH_RESULT 	 	= "CardRoleManager.ROLE_BREAKTHROUGH_RESULT"

CardRoleManager.ROLE_TRANSFER_RESULT  		= "CardRoleManager.ROLE_TRANSFER_RESULT"
CardRoleManager.ROLE_PRACTICE_RESULT 		= "CardRoleManager.ROLE_PRACTICE_RESULT"
CardRoleManager.ROLE_HERMIT_RESULT 		= "CardRoleManager.ROLE_HERMIT_RESULT"
CardRoleManager.ROLE_REBIRTH_RESULT 		= "CardRoleManager.ROLE_REBIRTH_RESULT"
CardRoleManager.ACUPOINT_BREACH_RESULT 		= "CardRoleManager.ACUPOINT_BREACH_RESULT"

CardRoleManager.QIMEN_INJECT_SUCCESS = "CardRoleManager.QIMEN_INJECT_SUCCESS"
CardRoleManager.QIMEN_BREACH_SUCCESS = "CardRoleManager.QIMEN_BREACH_SUCCESS"

CardRoleManager.updateFateMessage = "CardRoleManager.updateFateMessage"

CardRoleManager.openArmyIndex = EnumFightStrategyType.StrategyType_PVE
CardRoleManager.freshLock = true
function CardRoleManager:ctor()
	self:init();
end

function CardRoleManager:init()
	TFDirector:addProto(s2c.GET_ROLE, self, self.onReceiveRoleInfo)

	TFDirector:addProto(s2c.LEVEL_INFO, self, self.onReceiveLevelInfo)
	TFDirector:addProto(s2c.EXP_CHANGED, self, self.onReceiveExpChange)

	TFDirector:addProto(s2c.OBTAIN_PARTNER, self, self.onReceiveObtainPartner)
	TFDirector:addProto(s2c.REMOVE_PARTNER, self, self.onReceiveRemovePartner)

	--技能
	TFDirector:addProto(s2c.LEADING_ROLE_SPELL_LIST, self, self.onReceiveLeadingRoleSpellList)
	TFDirector:addProto(s2c.SPELL_LEVEL_UP_NOTIFY, self, self.onReceiveSpellLevelUpNotify)
	TFDirector:addProto(s2c.ROLE_SPELL_ENABLE_NOTIFY, self, self.onReceiveRoleSpellEnableNotify)
	TFDirector:addProto(s2c.SELECT_SPELL_RESULT, self, self.onReceiveSelectSpellResult)


	--经脉
	TFDirector:addProto(s2c.UPDATE_ALL_ROLE_TRAIN_INFO, self, self.onReceiveUpdateAllRoleTrainInfo)
	TFDirector:addProto(s2c.UPDATE_ROLE_TRAIN_INFO, self, self.onReceiveUpdateRoleTrainInfo)
	TFDirector:addProto(s2c.ACUPOINT_LEVEL_UP_RESULT, self, self.onReceiveUplevelAcupointMsgResult)
	TFDirector:addProto(s2c.ACUPOINT_BREACH_RESULT, self, self.onReceiveAcupointBreachResult)
	
	TFDirector:addProto(s2c.ROLE_BREAKTHROUGH_RESULT, self, self.onReceiveRoleBreakthroughResult)

	--修炼
	TFDirector:addProto(s2c.ROLE_TRANSFER_RESULT, self, self.onReceiveRoleTransferResult)
	TFDirector:addProto(s2c.ROLE_PRACTICE_RESULT, self, self.onReceiveStarUpResult)
	TFDirector:addProto(s2c.ROLE_HERMIT_RESULT, self, self.RoleHermitResult)
	TFDirector:addProto(s2c.ROLE_REBIRTH_RESULT, self, self.RoleRebirthResult)
	ErrorCodeManager:addProtocolListener(s2c.ROLE_HERMIT_RESULT,  function() return self:roleHermitErrorHandle() end)
	--主角奇门
	TFDirector:addProto(s2c.QUERY_QIMEN_MSG_RESULT, self, self.onQimenDetailInfo)
	TFDirector:addProto(s2c.QIMEN_INJECT_MSG_RESULT, self, self.onQimenInjectSuccess)
	TFDirector:addProto(s2c.QIMEN_BREACH_MSG_RESULT, self, self.onQimenBreachSuccess)


	self.cardRoleList = TFArray:new()
	self.sort_type 	= CardRoleManager.SORT_TYPE_POS
	-- add by king
	self.cardRoleListBlood = TFArray:new()
	self.sortblood_type = CardRoleManager.SORT_TYPE_POS
	self.bloodLvLimit	= 0
	--end


	--经脉突破概率
	self.breachInfo = {}
end

function CardRoleManager:restart()
	for cardRole in self.cardRoleList:iterator() do
		cardRole:dispose();
	end
	self.cardRoleList:clear();
	CardRoleManager.freshLock = true
	self.openArmyIndex = EnumFightStrategyType.StrategyType_PVE
end

--缓存用户所有卡牌信息
function CardRoleManager:onReceiveRoleInfo(event)
	-- print("CardRoleManager:onReceiveRoleInfo" )
	-- print(event.data)

	hideLoading();
	local data = event.data;
	for _,role in pairs(data.rolelist) do
		self:addCardRole(role);
	end

	local role = self:getRoleById(MainPlayer:getProfession())
	if role then
		role.name = MainPlayer:getPlayerName()
	end

	TFDirector:dispatchGlobalEventWith(CardRoleManager.GET_ROLE , data)
end

--卡牌升级
function CardRoleManager:onReceiveLevelInfo(event)
	-- print("CardRoleManager:onReceiveLevelInfo" )
	-- print(event.data)
	
	hideLoading();

	local data = event.data;
	local cardRole = self:getRoleByGmid(data.userId);
	cardRole:setLevel(data.currentLevel);
	cardRole.curExp = data.currentExp;

	TFDirector:dispatchGlobalEventWith(CardRoleManager.LEVEL_INFO , self.id, level)
end

--卡牌经验改变
function CardRoleManager:onReceiveExpChange(event)
	-- print("CardRoleManager:onReceiveExpChange" )
	-- print(event.data)
	
	hideLoading();
	local data = event.data;
	local cardRole = self:getRoleByGmid(data.userId);
	cardRole.curExp = data.currentExp;
	if data.userId == MainPlayer:getPlayerId() then
		MainPlayer:setExpCur(cardRole.curExp);
		TFDirector:dispatchGlobalEventWith(MainPlayer.ExpChange , 0)
	end

	TFDirector:dispatchGlobalEventWith(CardRoleManager.EXP_CHANGED , cardRole)
end

--获得新卡牌
function CardRoleManager:onReceiveObtainPartner(event)
	-- print("CardRoleManager:onReceiveObtainPartner" )
	-- print(event.data)
	
	hideLoading();
	local role = event.data.info;
	self:addCardRole(role);

	TFDirector:dispatchGlobalEventWith(CardRoleManager.OBTAIN_PARTNER , cardRole)
end

--删除卡牌
function CardRoleManager:onReceiveRemovePartner(event)
	-- print("CardRoleManager:onReceiveRemovePartner" )
	-- print(event.data)
	
	hideLoading();
	local userId = event.data.userId;
	ZhengbaManager:delRoleByGmid( userId )
	self:removeRoleByGmid(userId);

	TFDirector:dispatchGlobalEventWith(CardRoleManager.REMOVE_PARTNER , userId)
end

function CardRoleManager:onReceiveLeadingRoleSpellList(event)
	-- print("CardRoleManager:onReceiveLeadingRoleSpellList" )
	-- print(event.data)
	
	hideLoading();
	local data = event.data;
	for cardRole in self.cardRoleList:iterator() do
		if cardRole:getIsMainPlayer() then
			cardRole:setLeadingRoleSpellList(data.spell or {})
			cardRole:updateSkillAttr();
		end
	end

	TFDirector:dispatchGlobalEventWith(CardRoleManager.LEADING_ROLE_SPELL_LIST , data)
end

function CardRoleManager:onReceiveSpellLevelUpNotify(event)
	-- print("CardRoleManager:onReceiveSpellLevelUpNotify" )
	-- print(event.data)
	
	hideLoading();
	local data = event.data;

	local cardRole = self:getRoleByGmid(data.userid);

	if cardRole == nil then
		print("Card Role not Found in Spell Level Up Notify : ",data.userid)
	end

	if cardRole.spellLevelIdList == nil then
		print("Card Role have not spell list in Spell Level Up Notify : ",data.userid)
	end

	-- --quanhuan 2015-10-8 12:23:41
	-- local roleInfoList = RoleTalentData:GetRoleStarInfoByRoleId( cardRole.id )
	-- for i=1,cardRole.starlevel do
	-- 	local item = roleInfoList:getObjectAt(i)
	-- 	if item ~= nil then
	-- 		if item.type == 2 then --技能替换
	-- 			local activity = string.split(item.expression,'_')
	-- 			local old_skill = tonumber(activity[1])
	-- 			local new_skill = tonumber(activity[2])

	-- 			if data.skillId == old_skill then
	-- 				data.skillId = new_skill
	-- 			end
	-- 		end
	-- 	end
	-- end

	data.oldId = {skillId = data.skillId ,level = data.oldLevel }
	data.newId = {skillId = data.skillId ,level = data.newLevel }

	for i,v in ipairs(cardRole.spellLevelIdList) do
		if v.skillId == data.skillId then
			cardRole.spellLevelIdList[i] = data.newId;
		end
	end

	if cardRole:getIsMainPlayer() then
		for k,v in pairs(cardRole.leadingRoleSpellList ) do
			if v.spellId.skillId == data.skillId then
				v.spellId = data.newId
				break;
			end
		end
	end
	cardRole:updateSkillAttr();
	TFDirector:dispatchGlobalEventWith(CardRoleManager.SPELL_LEVEL_UP_NOTIFY,data)
end

function CardRoleManager:onReceiveRoleSpellEnableNotify(event)
	-- print("CardRoleManager:onReceiveRoleSpellEnableNotify" )
	-- print(event.data)
	
	hideLoading();
	local data = event.data;

	local cardRole = self:getRoleByGmid(data.userId);
	cardRole.spellLevelIdList = data.allSpellId;

	cardRole:updateSkillAttr();
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_SPELL_ENABLE_NOTIFY,data)
end

function CardRoleManager:onReceiveSelectSpellResult(event)
	print("CardRoleManager:onReceiveSelectSpellResult" )
	-- print(event.data)
	
	hideLoading();
	local data = event.data;

	for cardRole in self.cardRoleList:iterator() do
		if cardRole:getIsMainPlayer() then

			-- --quanhuan 2015-10-8 12:23:41
			-- local roleInfoList = RoleTalentData:GetRoleStarInfoByRoleId( cardRole.id )
			-- for i=1,cardRole.starlevel do
			-- 	local item = roleInfoList:getObjectAt(i)
			-- 	if item ~= nil then
			-- 		if item.type == 2 then --技能替换
			-- 			local activity = string.split(item.expression,'_')
			-- 			local old_skill = tonumber(activity[1])
			-- 			local new_skill = tonumber(activity[2])

			-- 			if old_skill == data.oldSpellId.skillId then
			-- 				data.oldSpellId.skillId = new_skill;
			-- 			end
			-- 			if old_skill == data.spellId.skillId then
			-- 				data.spellId.skillId = new_skill
			-- 			end
			-- 		end
			-- 	end
			-- end

			for k,v in pairs(cardRole.leadingRoleSpellList ) do
				if v.spellId.skillId == data.oldSpellId.skillId then
					v.choice = false;
				end
				if v.spellId.skillId == data.spellId.skillId then
					v.choice = true;
				end
			end
			cardRole:updateSkillAttr();
		end
	end

	TFDirector:dispatchGlobalEventWith(CardRoleManager.SELECT_SPELL_RESULT,data)
end

function CardRoleManager:onReceiveUpdateAllRoleTrainInfo(event)
	-- print("CardRoleManager:onReceiveUpdateAllRoleTrainInfo" )
	-- print(event.data)
	
	hideLoading();
	local trainInfoList = event.data.trainlist
	if trainInfoList == nil then
		return
	end
	self.breachInfo.lastTime = event.data.lastTime
	self.breachInfo.totalRate = event.data.totalRate
	self.breachInfo.waitRemain = event.data.waitRemain
	-- print(event.data)
	-- pp.pp = 1


	for i=1, #trainInfoList do
	    self:updateRoleTrainInfo(trainInfoList[i]);
	end

	TFDirector:dispatchGlobalEventWith(CardRoleManager.UPDATE_ALL_ROLE_TRAIN_INFO,trainInfoList)
end

function CardRoleManager:onReceiveUpdateRoleTrainInfo(event)
	-- print("CardRoleManager:onReceiveUpdateRoleTrainInfo")
	-- print(event.data)
	
	hideLoading();
	local trainInfo = event.data
	self:updateRoleTrainInfo(trainInfo);

	TFDirector:dispatchGlobalEventWith(CardRoleManager.UPDATE_ROLE_TRAIN_INFO,trainInfo)
end

function CardRoleManager:updateRoleTrainInfo(trainInfo)
	local cardRole = self:getRoleByGmid(trainInfo.instanceId)

	if trainInfo and trainInfo.acupointList then
		for i=1,#trainInfo.acupointList do
			local acupointInfo = trainInfo.acupointList[i]
			cardRole:SetAcupointInfo(acupointInfo)
		end
	end

	
end	

function CardRoleManager:onReceiveUplevelAcupointMsgResult( event )
	hideLoading();
	play_chongxue();

	local cardRole = self:getRoleByGmid(event.data.instanceId)
	if cardRole then
		cardRole:SetAcupointInfo(event.data.acupointInfo)
	end
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ACUPOINT_LEVEL_UP_RESULT,event.data)
end

function CardRoleManager:onReceiveRoleBreakthroughResult(event)
	hideLoading();
	local data = event.data
	local role = self:getRoleByGmid(data.userid)
	role:setQuality(data.quality)
	role:updateTotalAttr()
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_BREAKTHROUGH_RESULT)
end

function CardRoleManager:onReceiveRoleTransferResult(event)
	-- print("CardRoleManager:onReceiveRoleTransferResult" )
	-- print(event.data)
	
	hideLoading();
	local data = event.data
	local role = self:getRoleByGmid(data.userid)
	if role == nil then
		print("无法找到该角色 gmid == "..data.userid)
		return
	end

	-- local msg = {}
	-- msg.oldPower = role:getpower()
	-- print("msg.oldPower",msg.oldPower)
	-- role:setStarexp( data.starExp)
	-- local b = false
	-- if role.starlevel ~= data.starlevel then
	-- 	role:setStarlevel(data.starlevel)
	-- 	role:UpdatePower()
	-- 	msg.nowPower = role:getpower()
	-- print("msg.nowPower",msg.nowPower)
	-- 	b = true
	-- end
	-- msg.oldSkill = role.skillId
	-- role.skillId = data.spellId
	-- msg.nowSkill = role.skillId
	-- msg.gmid  = data.userid
	-- msg.levelup = b
	-- print("RoleStarUpResult .role skillId - > :"..role.skillId)

	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_TRANSFER_RESULT,data)
end

function CardRoleManager:onReceiveStarUpResult(event)
	-- print("CardRoleManager:onReceiveStarUpResult" )
	-- print(event.data)
	
	hideLoading();

	local data = event.data
	local role = self:getRoleByGmid(data.userid)
	if role == nil then
		print("无法找到该角色 gmid == "..data.userid)
		return
	end
	role:setStarlevel(data.starLevel)
	role:UpdatePower()

	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_PRACTICE_RESULT,data)
end
function CardRoleManager:RoleHermitResult(event)
	hideLoading();
	--quanhuan add 2015/11/30
	for i=1,LineUpType.LineUp_MAX do
		AssistFightManager:refreshAssistRoleList(i)
	end
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_HERMIT_RESULT,data)
end
function CardRoleManager:RoleRebirthResult(event)
	hideLoading();
	local userid = event.data.userid
	local role = self:getRoleByGmid(userid)
	if role == nil then
		print("无法找到该角色 gmId==",userid)
		return
	end
	role:reBirth()
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ROLE_REBIRTH_RESULT,data)
end

function CardRoleManager:replaceSkillList()

end

function CardRoleManager:addCardRole(role)


	local cardRole = CardRole:new(role.id);

	-- --quanhuan 2015-10-8 12:59:31
	-- local roleInfoList = RoleTalentData:GetRoleStarInfoByRoleId( role.id )
	-- for i=1,role.starlevel do
	-- 	local item = roleInfoList:getObjectAt(i)
	-- 	if item ~= nil then
	-- 		if item.type == 2 then --技能替换
	-- 			local activity = string.split(item.expression,'_')
	-- 			local old_skill = tonumber(activity[1])
	-- 			local new_skill = tonumber(activity[2])

	-- 			for j=1,#role.spellId do
	-- 				if role.spellId[j].skillId == old_skill then
	-- 					role.spellId[j].skillId = new_skill
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
	cardRole.gmId  = role.userid;
	cardRole:setLevel(role.level);
	cardRole.curExp = role.curexp;
	cardRole:setSpellLevelIdList(role.spellId);
	cardRole:setQuality(role.quality)				--品质
	cardRole:setStarlevel(role.starlevel)			--星级
	cardRole:setStarexp(role.starExp)				--星级经验
	cardRole.skillId = role.spellId  				--技能ID
	if self.qimenInfo then
		if self.qimenInfo.idx and self.qimenInfo.level then
			cardRole:setQimenInfo(self.qimenInfo.idx,self.qimenInfo.level)
		end
	end

	if role.equiplist and role.equipiplist ~= NULL then
		for _,equip in pairs(role.equiplist) do
			local cardEquip = CardEquipment:new(equip.id);
			cardEquip.gmId    = equip.userid;
			cardEquip:setLevel(equip.level);
			cardEquip:setQuality(equip.quality);
			cardEquip:setBaseAttribute( equip.base_attr );
			cardEquip:setExtraAttribute( equip.extra_attr );
			cardEquip:setGrow(equip.grow);
			cardEquip.maxGem  = equip.holeNum;
			cardEquip:setStar(equip.star);
            cardEquip.failPercent = math.floor(equip.starFailFix/100)
            cardEquip.refineLevel = equip.refineLevel


            --寶石
			if equip.gem then 
				for _,gempos in pairs(equip.gem) do
					cardEquip:setGemPos(gempos.pos , gempos.id );
				end
			end
			cardEquip:UpdateAttr();

			cardEquip:setRecastInfo(equip.recast)
			cardRole:AddEquipment(cardEquip);				--加到角色装备
			EquipmentManager:AddEquipment(cardEquip);		--加入背包
		end
	end
	
	--added by wuqi
	if role.bibleInfo and role.bibleInfo ~= NULL then
		print("+++++ role.bibleInfo received ++++++, id = ", role.userid)
		for _, book in pairs(role.bibleInfo) do
			local skyBook = CardSkyBook:new(book.id)
			skyBook.instanceId = book.instanceId
			skyBook:setLevel(book.level)
			skyBook:setTupoLevel(book.breachLevel)
			print("+++++ role.bibleInfo received= ", book.roleId)
			if book.essential then
				for _, essential in pairs(book.essential) do
					skyBook:setStonePos(essential.pos, essential.id)
				end
			end
			skyBook:updatePower()
			cardRole:setSkyBook(skyBook) --天书加入角色
			SkyBookManager:AddSkyBook(skyBook) --加入背包
		end
	end
	self.cardRoleList:push(cardRole);
	cardRole:updateFate()
	return cardRole
end

function CardRoleManager:removeCardRole(role)
	self:removeRoleByGmid(role.userid);
end


CardRoleManager.SORT_TYPE_POS     = 1;
CardRoleManager.SORT_TYPE_POWER   = 2;
CardRoleManager.SORT_TYPE_QUALITY = 3;

--排序策略：卡牌（默认）
function CardRoleManager:setSortStrategyForPos(fight_type,cardRolelist)
	self.sort_type = CardRoleManager.SORT_TYPE_POS;
	self:reSortStrategy(fight_type,cardRolelist);
end

--排序策略：战力
function CardRoleManager:setSortStrategyForPower(fight_type,cardRolelist)
	self.sort_type = CardRoleManager.SORT_TYPE_POWER;
	self:reSortStrategy(fight_type,cardRolelist);
end

--排序策略：品质
function CardRoleManager:setSortStrategyForQuality(fight_type,cardRolelist)
	self.sort_type = CardRoleManager.SORT_TYPE_QUALITY;
	self:reSortStrategy(fight_type,cardRolelist);
end

function CardRoleManager:reSortStrategy(fight_type ,cardRoleList)
	if fight_type == nil then
		fight_type = EnumFightStrategyType.StrategyType_PVE
	end
	if cardRoleList == nil then
		cardRoleList = self.cardRoleList
	end

	if fight_type == EnumFightStrategyType.StrategyType_BLOOY then
		self.cardRoleListBlood:clear()
		for cardRole in cardRoleList:iterator() do
			self.cardRoleListBlood:push(cardRole)
			-- if cardRole.blood_curHp > 0 then
			-- else
			-- 	deadRoleList:push(cardRole)
			-- end
			-- print("cardRole.blood_tag = ", cardRole.blood_tag)
		end
	end
	-- self:reSortRoleByLevel();
 --    self:reSortRoleByStar();
	-- local mainCardRole = self:getRoleById(MainPlayer:getProfession());
	-- self.cardRoleList:removeObject(mainCardRole);

	-- for cardRole in cardRoleList:iterator() do		
	-- 	cardRole.resortPos = ZhengbaManager:getRoleIndexByGmidAndFightType( cardRole.gmId , fight_type )
	-- end
	if (self.sort_type == CardRoleManager.SORT_TYPE_POS) or (self.sort_type == CardRoleManager.SORT_TYPE_QUALITY) then
	    local function cmpFun(cardRole1, cardRole2)
	    	local pos1 = cardRole1:getPosByFightType(fight_type)
	    	local pos2 = cardRole2:getPosByFightType(fight_type)


		if fight_type == EnumFightStrategyType.StrategyType_BLOOY then
			if cardRole1.blood_curHp <= 0 and cardRole2.blood_curHp > 0 then
				return false
			elseif cardRole1.blood_curHp > 0 and cardRole2.blood_curHp <= 0 then
				return true
			end
		end


			if pos1 > pos2  and pos2  == 0  then
			    return true;
			elseif  (pos1 > 0 and  pos2 > 0) or pos1 == pos2 then
				if cardRole1.quality > cardRole2.quality then
				 	return true;
				elseif cardRole1.quality == cardRole2.quality then
					if cardRole1.power > cardRole2.power then
 						return true;
 					elseif cardRole1.power == cardRole2.power then
 					    if cardRole1.starlevel > cardRole2.starlevel then
					        return true;
					    elseif cardRole1.starlevel == cardRole2.starlevel then
							if cardRole1.gmId > cardRole2.gmId then
								return true;
							end
					    end
 					end	
 				end
 			end
 			return false;
		end
	    cardRoleList:sort(cmpFun);

	elseif (self.sort_type == CardRoleManager.SORT_TYPE_POWER) then

	    local function cmpFun(cardRole1, cardRole2)
	    	local pos1 = cardRole1:getPosByFightType(fight_type)
	    	local pos2 = cardRole2:getPosByFightType(fight_type)

			if fight_type == EnumFightStrategyType.StrategyType_BLOOY then
				if cardRole1.blood_curHp <= 0 and cardRole2.blood_curHp > 0 then
					return false
				elseif cardRole1.blood_curHp > 0 and cardRole2.blood_curHp <= 0 then
					return true
				end
			end

			if pos1 > pos2  and pos2  == 0  then
			    return true;
			elseif  (pos1 > 0 and  pos2 > 0) or pos1 == pos2 then
				if cardRole1.power > cardRole2.power then
				 	return true;
				elseif cardRole1.power == cardRole2.power then
					if cardRole1.quality > cardRole2.quality then
 						return true;
 					elseif cardRole1.quality == cardRole2.quality then
 					    if cardRole1.starlevel > cardRole2.starlevel then
					        return true;
					    elseif cardRole1.starlevel == cardRole2.starlevel then
							if cardRole1.gmId > cardRole2.gmId then
								return true;
							end
					    end
 					end	
 				end
 			end
 			return false;
		end
	    cardRoleList:sort(cmpFun);

		
	end
end

function CardRoleManager:reSortRoleByPos()
	local function cmpFun(cardRole1, cardRole2)
		cardRole1.pos = cardRole1.pos or 0;
		cardRole2.pos = cardRole2.pos or 0;
	    if cardRole1.pos == 0 and cardRole2.pos > 0 then
	        return false;
	    else
	        return true;
	    end
	end

    self.cardRoleList:sort(cmpFun);
end

function CardRoleManager:reSortRoleByPower()
	local function cmpFun(cardRole1, cardRole2)
	    if cardRole1.power < cardRole2.power then
	        return false;
	    else
	        return true;
	    end
	end

    self.cardRoleList:sort(cmpFun)
end

function CardRoleManager:reSortRoleByLevel()
	local function cmpFun(cardRole1, cardRole2)
	    if cardRole1.level < cardRole2.level then
	        return false;
	    else
	        return true;
	    end
	end

    self.cardRoleList:sort(cmpFun)
end

function CardRoleManager:reSortRoleByStar()
	local function cmpFun(cardRole1, cardRole2)
		cardRole1.starlevel = cardRole1.starlevel or 0;
		cardRole2.starlevel = cardRole2.starlevel or 0;
	    if cardRole1.starlevel < cardRole2.starlevel then
	        return false;
	    else
	        return true;
	    end
	end

    self.cardRoleList:sort(cmpFun)
end

function CardRoleManager:reSortRoleByQuality()
	local function cmpFun(cardRole1, cardRole2)
		if cardRole1.quality < cardRole2.quality then
			return false;
		else
			return true;
		end
	end

    self.cardRoleList:sort(cmpFun)
end


function CardRoleManager:getRoleNum()
	return self.cardRoleList:length()
end

--通过id获得角色牌
function CardRoleManager:getRoleById( id )
	for cardRole in self.cardRoleList:iterator() do
		-- if cardRole.id == 5 then
		-- 	print('xxxxxxxCardRole = ',CardRole)
		-- end
		if cardRole.id == id then
			return cardRole;
		end
	end
end

--通过gmid获得角色牌
function CardRoleManager:getRoleByGmid( gmid )
	for cardRole in self.cardRoleList:iterator() do
		if cardRole.gmId == gmid then
			return cardRole;
		end
	end
end

--通过位置获得角色牌
function CardRoleManager:getRoleByPos(pos)
	for cardRole in self.cardRoleList:iterator() do
		if cardRole.pos == pos then
			return cardRole;
		end
	end
end

--通过gmid获得卡牌在列表中的顺序
function CardRoleManager:getIndexByGmid( gmid )
    local role = self:getRoleByGmid(gmid);
    return  self.cardRoleList:indexOf(role);
end

--通过gmid从列表中删除卡牌
function CardRoleManager:removeRoleByGmid( gmid )
	local cardRole = self:getRoleByGmid(gmid);
	self.cardRoleList:removeObject(cardRole);
end

function CardRoleManager:getNotUsed()
	local roleList = TFArray:new()
	for cardRole in self.cardRoleList:iterator() do
		if cardRole.pos  == nil or cardRole.pos == 0 then
			roleList:push(cardRole);
		end
	end
	return roleList;
end


function CardRoleManager:getNotUsedAndNotDevelop(includeMainPlayer)
	if includeMainPlayer == nil then
		includeMainPlayer = false
	end
	local roleList = TFArray:new()
	for cardRole in self.cardRoleList:iterator() do
		if cardRole.pos  == nil or cardRole.pos == 0 then
			if (cardRole:getTotalExp() ~= 0 or cardRole.starlevel ~= 0 or cardRole.martialLevel ~= 1 or cardRole:getMeridianAllCost() ~= 0 or next(cardRole.factionPractice) or cardRole:getMeridianBreachAllCost() ~= 0) and cardRole:getIsMainPlayer() == includeMainPlayer then
				roleList:push(cardRole);
			end
		end
	end
	return roleList;
end

--获取除了该gmid的角色的没有上阵的角色
function CardRoleManager:getOtherNotUsed(gmid)
	local roleList = TFArray:new()
	for cardRole in self.cardRoleList:iterator() do
		if cardRole.pos  == nil or cardRole.pos == 0 then
			if cardRole.gmId ~= gmid then
				roleList:push(cardRole);
			end
		end
	end
	return roleList;
end

function CardRoleManager:getUsedCardNum()
	local list = self:getUsedCardList()
	return list:length()
end

function CardRoleManager:getUsedCardList()
	local roleList = TFArray:new()
	for cardRole in self.cardRoleList:iterator() do
		if cardRole.pos ~= nil and cardRole.pos > 0 then
			roleList:push(cardRole)
		end
	end

	function cmpFun(cardRole1, cardRole2)
		if cardRole1.isMainPlayer then return true end
		if cardRole2.isMainPlayer then return false end
        if cardRole1.power < cardRole2.power then
        	return false
        else
        	return true
        end
	end

    roleList:sort(cmpFun)

	return roleList
end

--获得成长值
function CardRoleManager:getTrainGrowupvalue(gmId,index)
	local cardRole = self:getRoleByGmid(gmId);
	for trainItem in TrainData:iterator() do
		if trainItem.role_id == cardRole.id then
			local growupvalue = "";
			if cardRole.quality == QUALITY_JIA then
				growupvalue = trainItem.jia_factors; 
			end

			if cardRole.quality == QUALITY_YI then
				growupvalue = trainItem.yi_factors; 
			end

			if cardRole.quality == QUALITY_BING then
				growupvalue = trainItem.bing_factors; 
			end

			if cardRole.quality == QUALITY_DING then
				growupvalue = trainItem.ding_factors; 
			end
			local growupvalueArr = string.split(growupvalue,',');	
			return growupvalueArr[index];
		end
	end
end

--经脉等级上限
function CardRoleManager:getTrainMaxLevel(gmId,quality)
	-- local cardRole = self:getRoleByGmid(gmId);
	-- quality = quality or cardRole.quality

	-- for trainItem in TrainData:iterator() do
	-- 	if trainItem.role_id == cardRole.id then
	-- 		if quality == QUALITY_JIA then
	-- 			return trainItem.jia_max_level; 
	-- 		end

	-- 		if quality == QUALITY_YI then
	-- 			return trainItem.yi_max_level;
	-- 		end

	-- 		if quality == QUALITY_BING then
	-- 			return trainItem.bing_max_level;
	-- 		end
			
	-- 		if quality == QUALITY_DING then
	-- 			return trainItem.ding_max_level;
	-- 		end
	-- 	end
	-- end

	local cardRole = self:getRoleByGmid(gmId)
	local configure = MeridianConfigure:objectByID(cardRole.id)
	return configure.max_level
end

--传功
function CardRoleManager:roleTransfer( userid , dogfoodlist , catfoodlist )
	showLoading();
	local Msg = {
		userid , 
		dogfoodlist , 
		catfoodlist,
	}
	TFDirector:send(c2s.ROLE_TRANSFER,Msg)
end

--升星
function CardRoleManager:roleStarUp( userid )
	showLoading();
	local Msg = {
		userid , 
	}
	TFDirector:send(c2s.ROLE_PRACTICE,Msg)
end

--突破
function CardRoleManager:roleBreakthrough( userid )
	showLoading();
	local Msg = {
		userid , 
	}
	TFDirector:send(c2s.ROLE_BREAKTHROUGH,Msg)
end

--归隐
function CardRoleManager:roleHermit( dogfoodlist , catfoodlist ,force)
	if force == nil then
		force = false
	end
	showLoading();
	self.hermit_msg = {
		dogfoodlist , 
		catfoodlist,
		force,
	}
	TFDirector:send(c2s.ROLE_HERMIT,self.hermit_msg)
end


function CardRoleManager:roleHermitErrorHandle()
	-- TextIndex.role_is_Practice localizable
	local msg = localizable.CardRoleManager_shifoguiyin--"该侠客正在被使用,是否确认归隐？"
	CommonManager:showOperateSureLayer(function()
		self.hermit_msg[3] = true
		TFDirector:send(c2s.ROLE_HERMIT,self.hermit_msg)
    end,
    nil,
    {
		msg = msg,
    })
    return true
end



--重生
function CardRoleManager:roleRebirth( userid )
	showLoading();
	local Msg = {
		userid , 
	}
	TFDirector:send(c2s.ROLE_REBIRTH,Msg)
end
-- function CardRoleManager:btnOpenRoleStarUpLayer( gmid )
-- 	local role = self:getRoleByGmid(gmid)

-- 	if role.starlevel < 5 then
-- 	    self:openRoleStarUpLayer( gmid )
-- 	   	return
-- 	elseif role.quality < 4 then
-- 		self:openRoleBreakthroughLayer( gmid )
-- 		return
-- 	else
-- 		toastMessage("该角色已到达最高品质最高星级")
-- 	end
-- end

-- --刷新经脉
-- function CardRoleManager:refreshAcupoint(gmId,acupointIndex,type)
--     showLoading();
-- 	local refreshMsg = 			
-- 	{
-- 		gmId,
-- 		acupointIndex,
-- 		type,
-- 	}

-- 	TFDirector:send(c2s.REFRESH_ACUPOINT, refreshMsg)
-- end

--经脉升级
function CardRoleManager:upLevelAcupont(gmId,acupointIndex)
    showLoading();
	local uplevMsg = 			
	{
		gmId,
		acupointIndex,
	}
	TFDirector:send(c2s.REQUEST_ACUPOINT_LEVEL_UP, uplevMsg)
end
--一键经脉升级
function CardRoleManager:upLevelAcupontToTop(gmId)
    showLoading();
	local uplevMsg = 			
	{
		gmId,
		0,
	}
	TFDirector:send(c2s.REQUEST_ACUPOINT_LEVEL_UP, uplevMsg)
end

--技能升级
function CardRoleManager:upLevelSkill(roleGmId,levelId,level)
    showLoading();
	TFDirector:send(c2s.SPELL_LEVEL_UP_REQUEST, {roleGmId,levelId})
end
--主角技能上阵
function CardRoleManager:selectSpell(spellId,level)
    showLoading();
	TFDirector:send(c2s.SELECT_SPELL_REQUEST, {spellId})
end

--[[
更新缘分方法优化，从原来的全部角色都更新，变为可以指定更新特定角色
modify by david.dai
]]
function CardRoleManager:UpdateRoleFate( ... )
	if arg and arg.n > 0 then
		for i,v in ipairs(arg) do
			v:updateFate()
		end
	else
		for cardRole in self.cardRoleList:iterator() do
			-- cardRole:clearFate(); --更新方法就应该自动清空现有的缘分
			cardRole:updateFate();
		end
	end
end

function CardRoleManager:openRoleList(canOpenInfo)
    if canOpenInfo == nil then
		canOpenInfo = true
    end
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.army.ArmyLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    layer:setCanOpenInfo(canOpenInfo)
    AlertManager:show()

    --为了区分和血战的缘分系统 add by king
    --更新所有缘分
    self:UpdateRoleFate()
end

--打开角色详细信息
function CardRoleManager:openRoleInfo( cardRoleGmid,completeOpenCallback,tween)
	tween = tween or AlertManager.TWEEN_1;
	
	if completeOpenCallback then
		completeOpenCallback()
	end
   local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role_new.RoleInfoLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
   local cardRole = self:getRoleByGmid(cardRoleGmid);
   local selectIndex = self.cardRoleList:indexOf(cardRole);
   layer:loadSelfData(selectIndex);
   AlertManager:show();
end
--打开角色详细信息
function CardRoleManager:openRoleInfoByFightType( cardRoleGmid,fightType,completeOpenCallback,tween)
	tween = tween or AlertManager.TWEEN_1;
	
	if completeOpenCallback then
		completeOpenCallback()
	end
   local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role_new.RoleInfoLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
   local cardRole = self:getRoleByGmid(cardRoleGmid);
   local selectIndex = self.cardRoleList:indexOf(cardRole);
   layer:loadSelfData(selectIndex,fightType);
   AlertManager:show();
end
--打开角色详细信息
function CardRoleManager:openRoleInfoByIndex( index,completeOpenCallback,tween)
	tween = tween or AlertManager.TWEEN_1;
	
	if completeOpenCallback then
		completeOpenCallback()
	end
   local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role_new.RoleInfoLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
   layer:loadSelfData(index);
   AlertManager:show();
end

--打开角色详细信息
function CardRoleManager:openBloodFightRoleInfo(cardRoleGmid)
   local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role_new.RoleInfoLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
   local cardRole = self:getRoleByGmid(cardRoleGmid);
   local selectIndex = self.cardRoleListBlood:indexOf(cardRole);
   print("index = ", selectIndex)
   layer:loadBloodyData(selectIndex, self.cardRoleListBlood);
   AlertManager:show();
end

function CardRoleManager:openRoleSimpleInfo( cardRole )
   local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleSimpleInfoLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
   layer:loadData(cardRole);
   AlertManager:show();
end

function CardRoleManager:openSkillInfo( spellInfo,spellLevelInfo )
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.SkillDetailLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
    layer:loadData(spellInfo,spellLevelInfo);
    AlertManager:show();
end

function CardRoleManager:openRoleSkillListLayer( cardRoleGmid )
   local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleSkillListLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
    layer:loadData(cardRoleGmid);
    AlertManager:show();
end

function CardRoleManager:openMainSkillListLayer( cardRoleGmid )
   local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.MainSkillListLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
    layer:loadData(cardRoleGmid);
    AlertManager:show();
end

function CardRoleManager:openFateDetail( cardRoleGmid )
   local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.FateDetail",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
    layer:loadData(cardRoleGmid);
    AlertManager:show();
end

function CardRoleManager:openMoreAttr( cardRoleGmid )
   local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleAttributeDetail",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
    layer:loadData(cardRoleGmid);
    AlertManager:show();
end

function CardRoleManager:openTrainLayer( cardRoleGmid )
    -- local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleTrainLayer");
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role_new.MeridianLayer");
    layer:loadData(cardRoleGmid);
    AlertManager:show();
end

-- 牛逼的策划要增加左右滚动
function CardRoleManager:openTrainLayerNew( cardRoleGmid, cardRoleList,fightType)
    -- local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleTrainLayer");
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role_new.MeridianLayer")
    layer:loadData(cardRoleGmid,fightType)
    layer:setRoleList(cardRoleList)
    AlertManager:show()
end

function CardRoleManager:openRoleBreakResultLayer( cardRoleGmid )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleBreakResultLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
    layer:loadData(cardRoleGmid);
    AlertManager:show();
end

function CardRoleManager:openRoleTransferLayer( gmid )
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleTransferLayer",AlertManager.BLOCK_AND_GRAY);
    layer:loadData(gmid);
    layer:setRoleList(self.cardRoleList)
    AlertManager:show();
end

-- 牛逼的策划要增加左右滚动
function CardRoleManager:openRoleTransferLayerNew(gmid, cardRoleList,fightType)
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role.RoleTransferLayer",AlertManager.BLOCK_AND_GRAY);
    layer:loadData(gmid,fightType);
    layer:setRoleList(cardRoleList)
    AlertManager:show();
end

function CardRoleManager:addLayerToCache()

end

function CardRoleManager:openTrainLayerBreakLayer( gmid )
    -- local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role_new.TrainLayerBreakLayer",AlertManager.BLOCK_AND_GRAY);
    -- layer:loadData(gmid);
    -- AlertManager:show();
    local layer = require("lua.logic.role_new.TrainLayerBreakLayer"):new()
    AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
    layer:loadData(gmid)
    AlertManager:show()
end

--角色红点判断逻辑

--该角色是否可修炼
function CardRoleManager:isCanStarUp(gmid)
	local cardRole = self:getRoleByGmid(gmid);
	if cardRole == nil then
		return false
	end
	if cardRole.starlevel >= cardRole.maxStar then
		return false;
	end

	if cardRole:getHaveSoulNum() < cardRole:getUpstarNeedSoulNum() then
		return false
	end

	local roleInfoList = RoleTalentData:GetRoleStarInfoByRoleId( cardRole.id )
	local RoleStarLevelInfo = roleInfoList:getObjectAt(cardRole.starlevel+1)
	local limitLevel = RoleStarLevelInfo.role_level or 0
	if cardRole.level < limitLevel then
		return false
	end

	local itemGood = {}
	if #RoleStarLevelInfo.other_goods_id > 0 then
		local activity	= string.split(RoleStarLevelInfo.other_goods_id,'_')
		itemGood.id	 = tonumber(activity[1])
		itemGood.num = tonumber(activity[2])
		if BagManager:getItemNumById( itemGood.id ) < itemGood.num then
			return false
		end
	end


	return true
end
--是否有角色可修炼
function CardRoleManager:isHaveCanStarUp()
	for cardRole in self.cardRoleList:iterator() do
		if self:isCanStarUp(cardRole.gmId) then
			return true;
		end
	end
	return false;
end

--该角色是否可突破
function CardRoleManager:isCanBreakUp(gmid)
	-- local cardRole = self:getRoleByGmid(gmid);
	-- if cardRole.quality >= QUALITY_JIA then
	-- 	return false;
	-- end
	-- local isAllToMaxLevel = true;
	-- for i=1,6 do
	-- 	local acupointInfo = cardRole:GetAcupointInfo(i)
	-- 	if acupointInfo ~= nil then
 --    		local maxLevel = self:getTrainMaxLevel(gmid);
 --    		if acupointInfo.level < maxLevel then
 --    			isAllToMaxLevel = false;
 --    		end
	-- 	end
	-- end
	-- return isAllToMaxLevel;
	return false
end

--该角色是否有角色可突破
function CardRoleManager:isHaveCanBreakUp()
	for cardRole in self.cardRoleList:iterator() do
		if self:isCanBreakUp(cardRole.gmId) then
			return true;
		end
	end
	return false;
end
--是否有角色装备满秘籍
function CardRoleManager:isHaveEquipBookAll()
	for cardRole in self.cardRoleList:iterator() do
		local bool = true
		for i=1,6 do
			if cardRole.martialList[i] == nil then
				bool = false
			end
		end
		if bool == true then
			return true
		end
	end
	return false;
end

---<----------------add by king ----
----------血战的布阵----

function CardRoleManager:setBloodLvLimit(bloodLvLimit)
	self.bloodLvLimit	= bloodLvLimit
end

--排序策略：卡牌（默认）
function CardRoleManager:setSortBloodStrategyForPos()
	self.sortblood_type = CardRoleManager.SORT_TYPE_POS;
	self:reSortBloodStrategy();
end

--排序策略：战力
function CardRoleManager:setSortBloodStrategyForPower()
	self.sortblood_type = CardRoleManager.SORT_TYPE_POWER;
	self:reSortBloodStrategy();
end

--排序策略：品质
function CardRoleManager:setSortBloodStrategyForQuality()
	self.sortblood_type = CardRoleManager.SORT_TYPE_QUALITY;
	self:reSortBloodStrategy();
end

function CardRoleManager:reSortBloodStrategy()
	local mainCardRole = nil

	local deadRoleList = TFArray:new()
	deadRoleList:clear()

	self.cardRoleListBlood:clear()
	for cardRole in self.cardRoleList:iterator() do
		if cardRole.id == id then
			mainCardRole = cardRole
		elseif cardRole.blood_tag == 1 then
			if cardRole.blood_curHp > 0 then
				self.cardRoleListBlood:push(cardRole)
			else
				deadRoleList:push(cardRole)
			end
		end
		-- print("cardRole.blood_tag = ", cardRole.blood_tag)
	end

	print("-----------------self.cardRoleListBlood = ", self.cardRoleListBlood:length())

	self:getRoleById(MainPlayer:getProfession());
	self.cardRoleListBlood:removeObject(mainCardRole);

	if (self.sortblood_type == CardRoleManager.SORT_TYPE_POS) or (self.sortblood_type == CardRoleManager.SORT_TYPE_QUALITY) then

	    local function cmpFun(cardRole1, cardRole2)
			cardRole1.blood_pos = cardRole1.blood_pos or 0;
			cardRole2.blood_pos = cardRole2.blood_pos or 0;

			if cardRole1.blood_pos > cardRole2.blood_pos  and cardRole2.blood_pos  == 0  then
			    return true;
			elseif  (cardRole1.blood_pos > 0 and  cardRole2.blood_pos > 0) or cardRole1.blood_pos == cardRole2.blood_pos then
				if cardRole1.quality > cardRole2.quality then
				 	return true;
				elseif cardRole1.quality == cardRole2.quality then
					if cardRole1.power > cardRole2.power then
 						return true;
 					elseif cardRole1.power == cardRole2.power then
 					    if cardRole1.starlevel > cardRole2.starlevel then
					        return true;
					    elseif cardRole1.starlevel == cardRole2.starlevel then
							if cardRole1.gmId > cardRole2.gmId then
								return true;
							end
					    end
 					end	
 				end
 			end
 			return false;
		end
	    self.cardRoleListBlood:sort(cmpFun);

	    deadRoleList:sort(cmpFun);

	elseif (self.sortblood_type == CardRoleManager.SORT_TYPE_POWER) then
	    local function cmpFun(cardRole1, cardRole2)
			cardRole1.blood_pos = cardRole1.blood_pos or 0;
			cardRole2.blood_pos = cardRole2.blood_pos or 0;

			if cardRole1.blood_pos > cardRole2.blood_pos  and cardRole2.blood_pos  == 0  then
			    return true;
			elseif  (cardRole1.blood_pos > 0 and  cardRole2.blood_pos > 0) or cardRole1.blood_pos == cardRole2.blood_pos then
				if cardRole1.power > cardRole2.power then
				 	return true;
				elseif cardRole1.power == cardRole2.power then
					if cardRole1.quality > cardRole2.quality then
 						return true;
 					elseif cardRole1.quality == cardRole2.quality then
 					    if cardRole1.starlevel > cardRole2.starlevel then
					        return true;
					    elseif cardRole1.starlevel == cardRole2.starlevel then
							if cardRole1.gmId > cardRole2.gmId then
								return true;
							end
					    end
 					end	
 				end
 			end
 			return false;
		end
	    self.cardRoleListBlood:sort(cmpFun);
	    deadRoleList:sort(cmpFun);
   	end

   	self.cardRoleListBlood:insertAt(1, mainCardRole)

   	for v in deadRoleList:iterator() do
   		self.cardRoleListBlood:push(v)
    end
end

--秘籍的红点显示调整为：只有上阵的角色显示红点 2015-8-14
--是否有角色可以装备一本书
function CardRoleManager:isHaveBook()
	local list = self:getUsedCardList()
	for cardRole in list:iterator() do
		if  MartialManager:isHaveBook(cardRole) then
			return true
		end
	end

	return false
end

--秘籍是否能被上阵的角色穿戴 2015-9-14
function CardRoleManager:bookIsCanBeLearn(goodsId)
	-- 先判读物品是否是书
	local itemInfo = ItemData:objectByID(goodsId)
	if itemInfo == nil then
		print("CardRoleManager:bookIsCanBeLearn can't find item :", goodsId)
		return false
	else
		if itemInfo.type ~= EnumGameItemType.Book then

			print("CardRoleManager:bookIsCanBeLearn item is not book")
			return false
		end
	end

	local list 	 = self:getUsedCardList()
	local bookId = goodsId
	for cardRole in list:iterator() do
		if  MartialManager:bookIsCanBeLearn(cardRole, bookId) then
			return true
		end
	end

	return false
end

------>-----------------


function CardRoleManager:isSkillReplace(roleId, starlevel, skillId)

	local roleInfoList = RoleTalentData:GetRoleStarInfoByRoleId( roleId )

	local new_skill = skillId
	for i=1,starlevel do

		local item = roleInfoList:getObjectAt(i)
		if item ~= nil then
			if item.type == 2 then --技能替换
				local activity = string.split(item.expression,'_')
				-- print(activity)
				local old_s = tonumber(activity[1])
				local new_s = tonumber(activity[2])
				if skillId == old_s then
					new_skill = new_s
				end
			end
		end
	end

	return new_skill
end

function CardRoleManager:getReplaceOldSkill(roleId, starlevel, skillId)

	local roleInfoList = RoleTalentData:GetRoleStarInfoByRoleId( roleId )

	local old_skill = skillId
	for i=1,starlevel do

		local item = roleInfoList:getObjectAt(i)
		if item ~= nil then
			if item.type == 2 then --技能替换
				local activity = string.split(item.expression,'_')
				-- print(activity)
				local old_s = tonumber(activity[1])
				local new_s = tonumber(activity[2])
				if skillId == new_s then
					old_skill = old_s
				end
			end
		end
	end

	return old_skill
end

--大月卡重刷属性
function CardRoleManager:refreshAllRolePower()
	for cardRole in self.cardRoleList:iterator() do
		cardRole:UpdatePower()
	end
end

function CardRoleManager:AcupointInfoLevelUp(gmid, pos)
	showLoading();
	TFDirector:send(c2s.REQUEST_ACUPOINT_BREACH, {gmid,pos})
end

function CardRoleManager:onReceiveAcupointBreachResult( event )
	hideLoading();
	local data = event.data;

	local acupointInfo = {}
	acupointInfo.position = data.acupointInfo.position
	acupointInfo.level = data.acupointInfo.level
	acupointInfo.breachLevel = data.acupointInfo.breachLevel
	self.breachInfo.lastTime = event.data.lastTime
	self.breachInfo.totalRate = event.data.totalRate
	self.breachInfo.waitRemain = event.data.waitRemain

	if data.success then
		play_chongxue();
	else
		play_chongxuefail();
	end	

	local role = self:getRoleByGmid(data.instanceId)
	role:SetAcupointInfo(acupointInfo)
	
	TFDirector:dispatchGlobalEventWith(CardRoleManager.ACUPOINT_BREACH_RESULT,data)
end

function CardRoleManager:getBreachCutDownTime()
	
	local currTime = MainPlayer:getNowtime()
	local lastTime = self.breachInfo.lastTime or (currTime*1000)
	lastTime = math.floor(lastTime/1000)
	local lastRate = self.breachInfo.totalRate or 1000

	local DTime = currTime - lastTime
	if DTime < 0 then
		DTime = 0
	end
	local addCount = math.floor(DTime/1800)
	local addRate = addCount*500

	local totalRate = lastRate + addRate
	local cutDownTime = DTime%1800
	cutDownTime = 1800-cutDownTime

	if totalRate >= 10000 then
		totalRate = 10000
		cutDownTime = 0
	end

	return totalRate,cutDownTime
end

function CardRoleManager:onQimenDetailInfo( event )
	--服务器登陆时推送	
	self.qimenInfo = {}
	self.qimenInfo.idx = event.data.id
	self.qimenInfo.level = event.data.breachLevel

	-- local roleid = MainPlayer:getProfession()
 --    local role = self:getRoleById(roleid)
    for cardRole in self.cardRoleList:iterator() do
		-- cardRole:dispose();
		cardRole:setQimenInfo(self.qimenInfo.idx,self.qimenInfo.level)
	end
end

function CardRoleManager:requestQimenInject()
	--请求奇门注入
	showLoading()
	TFDirector:send(c2s.QIMEN_INJECT, {})
end

function CardRoleManager:onQimenInjectSuccess(event)
	--奇门注入成功	
	hideLoading()
	TFDirector:dispatchGlobalEventWith(CardRoleManager.QIMEN_INJECT_SUCCESS,{})
end

function CardRoleManager:requestQimenBreach()
	-- 请求奇门突破
	showLoading()
	TFDirector:send(c2s.QIMEN_BREACH, {})
end

function CardRoleManager:onQimenBreachSuccess( event )
	-- 奇门突破成功
	hideLoading()
	TFDirector:dispatchGlobalEventWith(CardRoleManager.QIMEN_BREACH_SUCCESS,{})
end

function CardRoleManager:getQimenInfo()
	return self.qimenInfo
end

function CardRoleManager:test()
	self.qimenInfo = self.qimenInfo or {}
	self.qimenInfo.idx = self.qimenInfo.idx or 0
	self.qimenInfo.level = self.qimenInfo.level or 0
	self.qimenInfo.idx = self.qimenInfo.idx + 1
	self.onQimenInjectSuccess()
end

function CardRoleManager:checkCanBreach(idx, level)
    if idx%24 == 0 and idx/24 > level then
        return true
    else
        return false
    end   
end


function CardRoleManager:openMainPlayerShuxingLayer(cardRole)
    local layer = require("lua.logic.role_new.MainPlayerRoleShuxing"):new()
    AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
    -- layer:setCardRole(cardRole)
    -- local cardRole  = self.cardRoleList:objectAt(1)
	layer:setCardRole(cardRole)
    AlertManager:show()
	
end

function CardRoleManager:openMainRoleStarUpLayer()
	local layer  = require("lua.logic.role_new.MainRoleStarUp"):new()
	AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
	AlertManager:show()
end

--转职后更新人物数据
function CardRoleManager:updateCardRoleByChangeProfession(beforeId,role)
	local cardRole = self:getRoleById(beforeId)
	local pos 		= cardRole.pos
	local newRole 	= self:addCardRole(role);
	newRole.name 	= MainPlayer:getPlayerName()
	newRole.pos = pos
	self:removeRoleByGmid(cardRole.gmId)
end

--added by wuqi
function CardRoleManager:getRoleByBibleInstanceId(instanceId)
	for cardRole in self.cardRoleList:iterator() do
		if cardRole.bible and cardRole.bible.instanceId == instanceId then
			print("CardRoleManager:getRoleByBibleInstanceId found, cardRole.gmId  = ", cardRole.gmId)
			return cardRole
		end
	end
	print("CardRoleManager:getRoleByBibleInstanceId not found")
	return nil
end

return CardRoleManager:new()