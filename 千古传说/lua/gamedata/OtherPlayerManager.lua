--[[
******其他玩家数据管理类*******

	-- by Stephen.tao
	-- 2014/1/17
]]

local CardRole = require('lua.gamedata.base.CardRole')
local CardSkyBook = require('lua.gamedata.base.CardSkyBook')

local OtherPlayerManager = class("OtherPlayerManager")

OtherPlayerManager.OPENRANKINFO = "OtherPlayerManager.openRankInfo"
OtherPlayerManager.OVERVIEW = "OtherPlayerManager.overview"
OtherPlayerManager.FriendFight = "OtherPlayerManager.friendsFight"
OtherPlayerManager.REFRESHDATAOFRANK = "OtherPlayerManager.refreshDataOfRank"
OtherPlayerManager.Zhengbasai = "OtherPlayerManager.Zhengbasai"
OtherPlayerManager.WeekRace = "OtherPlayerManager.WeekRace"
function OtherPlayerManager:ctor(data)
	self.cardRoleDic = {}
	-- self.layer_type = 0
	-- self.data = {}

	-- self.cardRoleList = TFArray:new()


	TFDirector:addProto(s2c.OTHER_PLAYER_DETAILS, self,self.getAttackRoleInfoRequest)
	TFDirector:addProto(s2c.PLAYER_SIMPLE_INFO, self,self.showOtherPlayerInfo)
	
end


function OtherPlayerManager:restart()
	self.cardRoleDic = {}

	-- self.layer_type = 0
	-- self.data = {}
	-- for v in self.cardRoleList:iterator() do
	-- 	v:dispose()
	-- end
	-- self.cardRoleList:clear()
end

function OtherPlayerManager:getAttackRoleInfoRequest(event)
	hideLoading();
	-- print("OtherPlayerManager:getAttackRoleInfoRequest:",event.data)
	-- if self.layer_type == 0 then
	-- 	self:OpenEnemyInfolayer(event)
	-- elseif self.layer_type == 1 then
	-- 	local data = event.data
	-- 	self:OpenRoleMainLayer(data)
	-- end

     self:openArmyInfo( event.data );
end

function OtherPlayerManager:showOtherPlayerdetails(playerId,type, flag)
	showLoading();
	self.type = type;
	local msgType = 0
	if type == "vs" then
		msgType = 1
	end
	if flag then
		msgType = 1
	end
	local InfoMsg = 			
	{
		playerId,
		msgType
	}
	
	TFDirector:send(c2s.GET_PLAYER_DETAILS	, InfoMsg)
end

function OtherPlayerManager:showOtherPlayerdetailsForWeekRace(playerId,type)
	showLoading();
	self.type = type;
	local msgType = 2	
	local InfoMsg = 			
	{
		playerId,
		msgType
	}
	
	TFDirector:send(c2s.GET_PLAYER_DETAILS	, InfoMsg)
end

function OtherPlayerManager:showOtherPlayerdetailsForShaluRank(playerId,type,msgType)
	--[[
		msgType
		3 阵型一
		4 阵型二
	]]
	showLoading();
	self.type = type;
	local msgType = msgType or 3	
	local InfoMsg = 			
	{
		playerId,
		msgType
	}
	print('showOtherPlayerdetailsForShaluRank = ',InfoMsg)
	TFDirector:send(c2s.GET_PLAYER_DETAILS	, InfoMsg)
end
--打开角色详细信息
function OtherPlayerManager:openArmyInfo( userData  )
	self.cardRoleDic = {}
	self.cardList = TFArray:new();
	-- print("openArmyInfo:",userData)
	local cardList = userData.warside
	for k,v in pairs(cardList) do
		local cardRole = CardRole:new(v.id)
		-- print("cardRole.pos:",v.quality)
		cardRole.level = v.level
        cardRole.power = v.power
        cardRole.curExp = v.curexp
        cardRole.curExp = v.curexp
      	cardRole.maxExp = LevelData:getMaxRoleExp(v.level)
        cardRole.pos  = v.warIndex + 1
        cardRole.skillLevel  = 1
        cardRole.otherPlayerCard  = true
		cardRole.starlevel  = v.starlevel
		cardRole.quality  = v.quality
		cardRole.martialLevel  = v.martialLevel
		cardRole.forgingQuality = v.forgingQuality
		-- print('v = ',v)
		-- pp.pp = 1
		-- print('v = ',v)
		-- pp.pp = 1
		cardRole:setSpellLevelIdList(v.spellId);

        cardRole.attribute = {}
        local attribute = GetAttrByString(v.attributes)

        for i=1,(EnumAttributeType.Max-1) do
        	cardRole.totalAttribute[i] = attribute[i] or 0
        end

        if v.equipment ~= nil then
	        local cardEquipList = cardRole:getEquipment()
	        for i=1,#v.equipment do
	        	local equipInfo = {}
	        	equipInfo.type = EnumGameObjectType.Equipment
	        	equipInfo.id = v.equipment[i].id
	        	equipInfo.level = v.equipment[i].level
	        	equipInfo.quality = v.equipment[i].quality	
	        	-- equipInfo.gemid = v.equipment[i].gemid
	        	equipInfo.gemid = v.equipment[i].gem or {}
	        	equipInfo.recastInfo = v.equipment[i].recast or {}
	        	
	        	local equipData = ItemData:objectByID(equipInfo.id)
				if equipData ~= nil then
					equipInfo.equipType = equipData.kind				
	 				equipInfo.textrueName = equipData:GetPath()
				end

				cardEquipList:AddEquipment(equipInfo)
	        end
	    end
	    if v.bibleInfo  ~= nil then
	    	for _, book in pairs(v.bibleInfo) do
				local skyBook = CardSkyBook:new(book.id)
				skyBook.instanceId = book.instanceId
				skyBook:setLevel(book.level)
				skyBook:setTupoLevel(book.breachLevel)
				if book.essential then
					for _, essential in pairs(book.essential) do
						skyBook:setStonePos(essential.pos, essential.id)
					end
				end
				skyBook:updatePower()
				cardRole:setSkyBook(skyBook) --天书加入角色
			end
	    end

		if cardRole:getIsMainPlayer() then		
			cardRole:setLeadingRoleSpellList(userData.spell or {})
		end

	   	local fateIds = cardRole.fateIds;

		local fateArray = RoleFateData:getRoleFateById(cardRole.id)

		local index = 1;
		local fateStatusArray = {};
		if fateIds then
			for i,v in ipairs(fateIds) do
				fateStatusArray[v] = true;
			end
		end
		cardRole.fateStatusArray = fateStatusArray;
		if v.martial ~= nil then
			for i=1,#v.martial do
				local martialInfo = v.martial[i]
				local martialTemplate = MartialData:objectByID(martialInfo.id)
				if not martialTemplate then
					--toastMessage("找不到武学数据 ： " .. martialInfo.martialId)
					toastMessage(stringUtils.format(localizable.OtherPlayerManager_not_find, martialInfo.martialId))
					return
				end
				--local martial = cardRole:addMartial(martialTemplate,martialInfo.position)
				--quanhuan change position计数从0开始
				local martial = cardRole:addMartial(martialTemplate,martialInfo.position+1)
				martial.enchantLevel = martialInfo.enchantLevel
			end
		end
		-- -- 
		-- 	required string effectActive = 17;			//效果影响主动
		-- 	required string effectPassive = 18;			//效果影响被动
			local effectActive = GetAttrByString(v.effectActive)
			cardRole.effectActive = {}
	        for i=EnumFightEffectType.FightEffectType_NormalAttack,(EnumFightEffectType.FightEffectType_BadAttr) do
	        	cardRole.effectActive[i] = effectActive[i] or 0
	        end

	        local effectPassive = GetAttrByString(v.effectPassive)
			cardRole.effectPassive = {}
	        for i=EnumFightEffectType.FightEffectType_NormalAttack,(EnumFightEffectType.FightEffectType_BadAttr) do
	        	cardRole.effectPassive[i] = effectPassive[i] or 0
	        end

		-- 
	   	self.cardRoleDic[cardRole.id] = cardRole;
	   	self.cardList:push(cardRole);
	end
	local layer = nil;
	if self.type == "rank" then
		TFDirector:dispatchGlobalEventWith(OtherPlayerManager.OPENRANKINFO ,{userData})
		return
	elseif self.type == "overview" then
		TFDirector:dispatchGlobalEventWith(OtherPlayerManager.OVERVIEW, {userData})
		return
	elseif self.type == "friendsFight" then
		TFDirector:dispatchGlobalEventWith(OtherPlayerManager.FriendFight, {userData})
		return
	elseif self.type == "zhengbasai" then
		TFDirector:dispatchGlobalEventWith(OtherPlayerManager.Zhengbasai, {userData})
		return
	elseif self.type == "weekrace" then
		TFDirector:dispatchGlobalEventWith(OtherPlayerManager.WeekRace, {userData})
		return
	elseif self.type == "serverchat" then
		local cardRole = self.cardList:front()
		if cardRole == nil then
			return
		end
		self:openRoleInfo( userData,cardRole.id)
		return
	elseif self.type == "vs" then
	 	--layer = AlertManager:addLayerByFile("lua.logic.army.OtherArmyVSLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
	 	layer = AlertManager:addLayerByFile("lua.logic.arena.ArenaOtherArmyVSLayer",AlertManager.BLOCK)
	else
		layer = AlertManager:addLayerByFile("lua.logic.army.OtherArmyLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
	end

	TFDirector:dispatchGlobalEventWith("OpenEnemyInfolayerEvent",layer)
	
	layer:loadData(userData);
    AlertManager:show()
end

function OtherPlayerManager:openRoleInfo( userData,cardRoleId )
	local cardRole = self.cardRoleDic[cardRoleId];

	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role_new.RoleInfoLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
	layer:loadOtherData(self.cardList:indexOf(cardRole), self.cardList,userData.name);
	AlertManager:show();
end

--quanhuan add
--获取单个侠客榜角色信息
function OtherPlayerManager:openXiakeRoleInfo( userData, roleId, item )

	self.cardRoleDic = {}
	self.cardList = TFArray:new();
	local v = userData
	local cardRole = CardRole:new(v.id)
	-- print("userDatauserData:",userData)
	cardRole.level = v.level
    cardRole.power = v.power
    cardRole.curExp = v.curexp
    cardRole.curExp = v.curexp
  	cardRole.maxExp = LevelData:getMaxRoleExp(v.level)
    cardRole.pos  = v.warIndex + 1
    cardRole.skillLevel  = 1
    cardRole.otherPlayerCard  = true
	cardRole.starlevel  = v.starlevel
	cardRole.quality  = v.quality
	cardRole.martialLevel  = v.martialLevel

	cardRole:setSpellLevelIdList(v.spellId);

    cardRole.attribute = {}
    local attribute = GetAttrByString(v.attributes)

    for i=1,(EnumAttributeType.Max-1) do
    	cardRole.totalAttribute[i] = attribute[i] or 0
    end

    if v.equipment ~= nil then
        local cardEquipList = cardRole:getEquipment()
        for i=1,#v.equipment do
        	local equipInfo = {}
        	equipInfo.type = EnumGameObjectType.Equipment
        	equipInfo.id = v.equipment[i].id
        	equipInfo.level = v.equipment[i].level
        	equipInfo.quality = v.equipment[i].quality	
        	-- equipInfo.gemid = v.equipment[i].gemid	
        	equipInfo.gemid = v.equipment[i].gem or {}
	        equipInfo.recastInfo = v.equipment[i].recast or {}
        	
        	local equipData = ItemData:objectByID(equipInfo.id)
			if equipData ~= nil then
				equipInfo.equipType = equipData.kind				
 				equipInfo.textrueName = equipData:GetPath()
			end

			cardEquipList:AddEquipment(equipInfo)
        end
    end

	if v.bibleInfo  ~= nil then
    	for _, book in pairs(v.bibleInfo) do
			local skyBook = CardSkyBook:new(book.id)
			skyBook.instanceId = book.instanceId
			skyBook:setLevel(book.level)
			skyBook:setTupoLevel(book.breachLevel)
			if book.essential then
				for _, essential in pairs(book.essential) do
					skyBook:setStonePos(essential.pos, essential.id)
				end
			end
			skyBook:updatePower()
			cardRole:setSkyBook(skyBook) --天书加入角色
		end
    end


	if cardRole:getIsMainPlayer() then		
		local spellData = {}
		for _,spellIdData in pairs(v.spellId) do
			local lengh = #spellData + 1
			spellData[lengh] = {}
			spellData[lengh].spellId = {}
			local oldSkillId = CardRoleManager:getReplaceOldSkill(v.id, v.starlevel, spellIdData.skillId) or 0
			spellData[lengh].spellId.skillId = oldSkillId
			spellData[lengh].spellId.level = spellIdData.level
			spellData[lengh].choice = true
		end
		cardRole:setLeadingRoleSpellList( spellData or {})
	end

   	local fateIds = cardRole.fateIds;

	local fateArray = RoleFateData:getRoleFateById(cardRole.id)

	local index = 1;
	local fateStatusArray = {};
	if fateIds then
		for i,v in ipairs(fateIds) do
			fateStatusArray[v] = true;
		end
	end
	cardRole.fateStatusArray = fateStatusArray;
	if v.martial ~= nil then
		for i=1,#v.martial do
			local martialInfo = v.martial[i]
			local martialTemplate = MartialData:objectByID(martialInfo.id)
			if not martialTemplate then
				--toastMessage("找不到武学数据 ： " .. martialInfo.martialId)
				toastMessage(stringUtils.format(localizable.OtherPlayerManager_not_find, martialInfo.martialId))
				return
			end
			local martial = cardRole:addMartial(martialTemplate,martialInfo.position+1)
			martial.enchantLevel = martialInfo.enchantLevel
		end
	end


		-- -- add by king
	-- 	required string effectActive = 17;			//效果影响主动
	-- 	required string effectPassive = 18;			//效果影响被动
		local effectActive = GetAttrByString(v.effectActive)
		cardRole.effectActive = {}
        for i=EnumFightEffectType.FightEffectType_NormalAttack,(EnumFightEffectType.FightEffectType_BadAttr) do
        	cardRole.effectActive[i] = effectActive[i] or 0
        end

        local effectPassive = GetAttrByString(v.effectPassive)
		cardRole.effectPassive = {}
        for i=EnumFightEffectType.FightEffectType_NormalAttack,(EnumFightEffectType.FightEffectType_BadAttr) do
        	cardRole.effectPassive[i] = effectPassive[i] or 0
        end

	-- 

   	self.cardRoleDic[cardRole.id] = cardRole;
    
   	self.cardList:push(cardRole);

   	-- print('self.type = ',self.type)
   	if item and item.value and item.value ~= userData.power then
   		TFDirector:dispatchGlobalEventWith(OtherPlayerManager.REFRESHDATAOFRANK ,nil)
   		return
   	end
   	if item and item.name then
   		self:openRoleInfoByName(userData, cardRole.id, item.name, {cardRole.id})
   	else
   		self:openRoleInfoByName(userData, cardRole.id, "", {cardRole.id})
   	end
end

--quanhuan add openRoleInfo
function OtherPlayerManager:openRoleInfoByName( userData, cardRoleId, userName, roleTable )

	local cardRole = nil
	for k,v in pairs(roleTable) do
		cardRole = self.cardRoleDic[v];
		if cardRole == nil then
			print('self.type = ',self.type)
			TFDirector:dispatchGlobalEventWith(OtherPlayerManager.REFRESHDATAOFRANK ,nil)
			return
		end 
	end
	cardRole = self.cardRoleDic[cardRoleId];
	if cardRole == nil then
		cardRole = self.cardList:getObjectAt(1)
	end

    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.role_new.RoleInfoLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
    layer:loadOtherData(self.cardList:indexOf(cardRole), self.cardList,userName);
    AlertManager:show();
end


function OtherPlayerManager:ZhengbaMatch()
	showLoading();
	self.type = "zhengbasai";
	TFDirector:send(c2s.MATCH, {})
end



function OtherPlayerManager:requestRoleDataById( playerId, roleId )
	showLoading()
	local Msg = 
	{
		playerId,
		roleId
	}	
	TFDirector:send(c2s.GET_OTHER_ROLE_DETAILS,Msg)
end

-- --获取其他角色数据
-- --@type 是获取角色的面板类型，0，表示有九宫格，角色信息的面板;1，表示角色详细信息的面板 
-- --@data 传入的数据需要有playerId
-- function OtherPlayerManager:getOtherPlayerdetails(type,data )
-- 	self.layer_type = type

-- 	if data.playerId then
-- 		self.data = data.playerId
-- 		local InfoMsg = 			
-- 		{
-- 			data.playerId,
-- 		}
-- 		TFDirector:send(c2s.GET_PLAYER_DETAILS	, InfoMsg)
-- 	end
-- end

-- function OtherPlayerManager:OpenEnemyInfolayer(event)
-- 	local data = event.data
-- 	if data == nil or data.warside == nil  then
-- 		return
-- 	end
-- 	local role = {}

-- 	role.name 		= data.name
-- 	role.playerId 	= data.playerId
-- 	role.profession = data.profession
-- 	role.level 		= data.level
-- 	role.vipLevel 	= data.vipLevel
-- 	role.power 		= data.power
-- 	role.warside 	= data.warside

-- 	local layer = require("lua.logic.thirtysix.EnemyInfo"):new(role)
-- 	TFDirector:dispatchGlobalEventWith("OpenEnemyInfolayerEvent",layer)

-- 	AlertManager:addLayer(layer)
-- 	AlertManager:show()
-- end

-- function OtherPlayerManager:OpenRoleMainLayer(data)
-- 	for v in self.cardRoleList:iterator() do
-- 		v:dispose()
-- 	end
-- 	self.cardRoleList:clear()

-- 	local cardList = data.warside
-- 	for k,v in pairs(cardList) do
-- 		local cardRole = CardRole:new(v.id)
-- 		cardRole.level = v.level
--         cardRole.power = v.power
--         cardRole.curExp = v.curexp
--         cardRole.pos  = v.warIndex + 1
--         cardRole.skillLevel  = 1
--         cardRole.otherPlayerCard  = true
-- 		cardRole.starlevel  = v.starlevel

--         cardRole.attribute = {}
--         local attribute = GetAttrByString(v.attributes)
--         for i=1,(EnumAttributeType.Max-1) do
--         	cardRole.totalAttribute[i] = attribute[i] or 0
--         end

--         if v.equipment ~= nil then
-- 	        local cardEquipList = cardRole:getEquipment()
-- 	        for i=1,#v.equipment do
-- 	        	local equipInfo = {}
-- 	        	equipInfo.type = EnumGameObjectType.Equipment
-- 	        	equipInfo.id = v.equipment[i].id
-- 	        	equipInfo.level = v.equipment[i].level
-- 	        	equipInfo.quality = v.equipment[i].quality	
-- 	        	local equipData = ItemData:objectByID(equipInfo.id)
-- 				if equipData ~= nil then
-- 					equipInfo.equipType = equipData.kind				
-- 	 				equipInfo.textrueName = equipData:GetPath()
-- 				end

-- 				cardEquipList:AddEquipment(equipInfo)
-- 	        end
-- 	    end

-- 	   	self.cardRoleList:push(cardRole)
-- 	end

--     local layer = require("lua.logic.role.OtherRoleInfoLayer"):new()
--     AlertManager:addLayer(layer)
--     AlertManager:show()
-- end
function OtherPlayerManager:requestPlayerInfo(showType, playerId, serverId )
	self.showType = showType
	showLoading()
	if serverId == nil then
		local Msg = 
		{
			playerId
		}
		TFDirector:send(c2s.GAIN_SIMPLE_INFO,Msg)
	else
		local Msg = 
		{
			playerId,
			serverId
		}
		self.type = "serverchat"
		TFDirector:send(c2s.GAIN_CROSS_OTHER_INFO,Msg)
	end
	
end

function OtherPlayerManager:showOtherPlayerInfo(event)
	hideLoading();
	if self.showType == nil then
		return;
	end
	local layer = AlertManager:addLayerToQueueAndCacheByFile(
        "lua.logic.friends.FriendInfoLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1);
    layer:setInfoByType(event.data.info,self.showType);
    AlertManager:show();
end

return OtherPlayerManager:new()