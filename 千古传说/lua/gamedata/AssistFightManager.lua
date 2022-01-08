--[[
******助战管理类*******
	-- quanhuan
	-- 2015-11-24
]]


local AssistFightManager = class("AssistFightManager")

AssistFightManager.refreshWindow = "AssistFightManager.refreshWindow"
AssistFightManager.levelUpAgreeSuccess = "AssistFightManager.levelUpAgreeSuccess"
AssistFightManager.GETASSISTROLESUCCESS = "AssistFightManager.GETASSISTROLESUCCESS"
AssistFightManager.GETASSISTROLESUCCESSFORFRIEND = "AssistFightManager.GETASSISTROLESUCCESSFORFRIEND"
AssistFightManager.FRIENDASSISTLIST = "AssistFightManager.FRIENDASSISTLIST"
AssistFightManager.UPDATEPROVIDE = "AssistFightManager.UPDATEPROVIDE"
AssistFightManager.UPDATEDEMANDROLE = "AssistFightManager.UPDATEDEMANDROLE"


local AgreeConditionData = require('lua.table.t_s_agree_condition')
local AgreeConditionAttributeData = require('lua.table.t_s_agree_condition_attribute')

AssistFightManager.friendAssistIndex = 19
AssistFightManager.CloseFriendType = {LineUpType.LineUp__MERCENARY_TEAM }

--t_s_assistant_rule
function AssistFightManager:ctor()
	--助战信息
	TFDirector:addProto(s2c.ASSISTANT_INFO, self, self.assistInfoReceive)
	--开启助战格子
	TFDirector:addProto(s2c.OPEN_ASSISTANT_GRID_SUCESS, self, self.openGridReceive)
	--助战阵容改变
	TFDirector:addProto(s2c.UPDATE_ASSISTANT_ROLE_SUCESS, self, self.updateRoleReceive)
	--契合
	TFDirector:addProto(s2c.LEVEL_UP_AGREE_SUCESS, self, self.qiheSuccessReceive)

	--好友侠客库
	TFDirector:addProto(s2c.FRIEND_ASSISTANT_INFO_LIST, self, self.onFriendAssistList)
	--修改需求侠客
	TFDirector:addProto(s2c.UPDATE_DEMAND_SUCESS, self, self.updateDemandSuccess)
	--修改提供侠客
	TFDirector:addProto(s2c.UPDATE_PROVIDE_SUCESS, self, self.updateProvideSuccess)
	--获得助战侠客
	TFDirector:addProto(s2c.GAIN_ASSISTANT_ROLE_SUCESS, self, self.getAssistRoleSuccess)
	--给予助战侠客
	TFDirector:addProto(s2c.PROVIDE_FRIEND_ASSISTANT_SUCESS, self, self.giveAssisRoleSuccess)
	
	

	self:restart()
end

function AssistFightManager:restart()
	self.gridState = {}
	self.roleInfo = {}
	self.qiheInfo = {}
	self.friendRoleInfo = {}
	self.provideSelectRole = {}
	self.requestSelectRole = {}
	for i=1,6 do
		self.roleInfo[i] = {}
	end
	for i=1,6 do
		self.gridState[i] = false
	end
end

--助战信息
function AssistFightManager:requestAssistInfo()
	TFDirector:send(c2s.GAIN_ASSISTANT_INFO,{})
	showLoading()
end
function AssistFightManager:assistInfoReceive( event )
	hideLoading()
	self:restart()

	local data = event.data
	-- print("data = ",data)

	local flag = {1,2,4,8,16,32}
	for i=1,6 do
		if bit_and(data.openPos,flag[i]) ~= 0 then
			self.gridState[i] = true
		else
			self.gridState[i] = false
		end
		self.qiheInfo[i] = data.agreeLevels[i] or 0
		-- self.qiheInfo[i] = 5
	end
	data.roleInfos = data.roleInfos or {}
	
	for _,v in pairs(data.roleInfos) do
		self.roleInfo[v.type] = {}
		self.roleInfo[v.type] = v.roles
		for i=1,6 do
			self.roleInfo[v.type][i] = self.roleInfo[v.type][i] or 0
		end		
	end
	for i=1,LineUpType.LineUp_MAX do
		self.roleInfo[i] = self.roleInfo[i] or {}
		for j=1,6 do
			self.roleInfo[i][j] = self.roleInfo[i][j] or 0
		end
	end
	self.friendRoleInfo = {}
	self.friendRoleInfo.friendRoleId = data.friendRoleId or 0
	self.friendRoleInfo.friendProvideTime = data.friendProvideTime or 0	
	
	-- print("----AssistFightManager time1 = ", os.time())

	TFDirector:dispatchGlobalEventWith(AssistFightManager.refreshWindow ,{})
end

--助战格子
function AssistFightManager:requestOpenGrid(idx)
	self.OpenGridIdx = idx + 1
	TFDirector:send(c2s.OPEN_ASSISTANT_GRID,{idx})
	showLoading()
end
function AssistFightManager:openGridReceive( event )
	hideLoading()

	play_linglianshangsuo()

	self.gridState[self.OpenGridIdx] = true
	TFDirector:dispatchGlobalEventWith(AssistFightManager.refreshWindow ,{})
	-- toastMessage("成功解锁")
	toastMessage(localizable.common_unlock_suc)
end

--助战改变角色
function AssistFightManager:requestUpdateRole(Type, iconIdx, gmId)
	self.UpdateRoleType = Type
	-- print("self.roleInfo = ",self.roleInfo)
	self.UpdateRoleList = {}
	self.UpdateRoleList = self.roleInfo[self.UpdateRoleType]
	self.UpdateRoleList[iconIdx] = gmId
	if Type == LineUpType.LineUp__MERCENARY_TEAM or Type == LineUpType.LineUp_HIRE_TEAM then
		self:updateRoleReceive( event )
		return
	end

	local msg = {Type, self.UpdateRoleList}
	print("msg = ",msg)
	TFDirector:send(c2s.UPDATE_ASSISTANT_ROLE,msg)
	showLoading()
end
function AssistFightManager:updateRoleReceive( event )
	hideLoading()
	if self.UpdateRoleType == nil or self.UpdateRoleList == nil then
		return
	end
	self.roleInfo[self.UpdateRoleType] = self.UpdateRoleList
	self:refreshRoleQiheAttr()
	self.UpdateRoleList = nil
	self.UpdateRoleType = nil
	TFDirector:dispatchGlobalEventWith(AssistFightManager.refreshWindow ,{})

	-- 增加音效
	play_chuangongrenwushengji()
end

function AssistFightManager:updateRoleOff(Type, gmId)
	--下阵
	if self.roleInfo[Type] then
		for i=1,#self.roleInfo[Type] do
			if self.roleInfo[Type][i] == gmId then
				self:requestUpdateRole(Type, i, 0)
				return
			end
		end
	end
end


function AssistFightManager:getGridList()
	return self.gridState
end

function AssistFightManager:getAssistRoleList( Type )
	-- print("Type = ",Type)
	return self.roleInfo[Type]
end

function AssistFightManager:setAssistRoleList( Type ,list )
	self.roleInfo[Type] = list
end

function AssistFightManager:refreshAssistRoleList( Type ) 
	if self.roleInfo[Type] then
		for i=1,#self.roleInfo[Type] do
			if self.roleInfo[Type][i] and self.roleInfo[Type][i] > 0 then
				local cardRole = CardRoleManager:getRoleByGmid( self.roleInfo[Type][i] )
				if cardRole == nil then
					self.roleInfo[Type][i] = 0
				end
			end
		end
	end
end


function AssistFightManager:openAssistWithType(Type)

	local strategyList = self:getStrategyList(Type)
	if strategyList == nil then
		print("can't fint strategy list , type = ", Type)
		return
	end
	-- 传入阵位信息
	local roleFateMap = FateManager:getRoleFateWihtRoleList(strategyList,true,Type)

	-- 传入阵上所有角色的缘分 和 助战列表（需要将当期阵位和助战列表融到一起）
	-- [1] = xxx ...... [11]...
	local roleList = self:getAssistRoleList(Type) or {}
	for k,v in pairs(roleList) do
		local role = CardRoleManager:getRoleByGmid(v)
		if role == nil then
			local mercenary = EmployManager:getMercenaryInAllEmployRole( v )
			if mercenary ==nil then
				mercenary = EmployManager:getEmploySingleRoleByGmId( v ,Type)
				if mercenary ==nil then
					roleList[k] = 0
				end
			end
		end
	end
	local assistlist = {}

	assistlist = FateManager:LinkStrategyAndAssit(strategyList, roleList,Type)

	print("assistlist = ", assistlist)

	-- FateManager:updateFate(roleFateMap, {1,2,3,4,5,6})
	FateManager:updateFate(roleFateMap, assistlist)

	-- 获取缘分列表
	local fateList = FateManager:getFateList(roleFateMap)

	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.assistFight.AssistFightLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
	
	layer:setFateList(roleFateMap, fateList)
	layer:setLineUpType(Type)
	AlertManager:show()
end

function AssistFightManager:getCardRoleList( Type )
	
	local cardRoleList = TFArray:new()
	local function needAdd( gmId, assistlist, onlinelist)
		if assistlist then
			for _,k in pairs(assistlist) do
				if gmId == k then
					return false
				end			
			end
		end
		if onlinelist then
			for _,k in pairs(onlinelist) do
				if gmId == k then
					return false
				end			
			end
		end		
		return true
	end

	if Type == LineUpType.LineUp_Main then
		for cardRole in CardRoleManager.cardRoleList:iterator() do
			if cardRole.pos and cardRole.pos ~= 0 then
			-- elseif needAdd( cardRole.gmId, self.roleInfo[Type], nil) then
			else
				local card_copy = clone(cardRole)
				card_copy.fateid = 0
				cardRoleList:push(card_copy)
			end			
		end
	elseif Type == LineUpType.LineUp_BloodyBattle then
		for cardRole in CardRoleManager.cardRoleListBlood:iterator() do
			if cardRole.blood_pos and cardRole.blood_pos ~= 0 then
			-- elseif needAdd( cardRole.gmId, self.roleInfo[Type], nil) then
			else

				local card_copy = clone(cardRole)
				card_copy.fateid = 0
				cardRoleList:push(card_copy)
			end			
		end
	elseif Type == LineUpType.LineUp_Attack then
		local attackList = ZhengbaManager:getFightList(EnumFightStrategyType.StrategyType_CHAMPIONS_ATK)
		for cardRole in CardRoleManager.cardRoleList:iterator() do
			-- if needAdd(cardRole.gmId, self.roleInfo[Type], attackList) then
			if 1 then
				local card_copy = clone(cardRole)
				card_copy.fateid = 0
				cardRoleList:push(card_copy)
			end
		end
	elseif Type == LineUpType.LineUp_Defense then
		-- local defenseList = ZhengbaManager:getFightList(EnumFightStrategyType.StrategyType_CHAMPIONS_DEF)		
		for cardRole in CardRoleManager.cardRoleList:iterator() do
			-- if needAdd(cardRole.gmId, self.roleInfo[Type], defenseList) then
			if 1 then
				local card_copy = clone(cardRole)
				card_copy.fateid = 0
				cardRoleList:push(card_copy)
			end
		end
	elseif Type == LineUpType.LineUp_QunhaoDef then
		-- local defenseList = ZhengbaManager:getFightList( EnumFightStrategyType.StrategyType_AREAN )		
		for cardRole in CardRoleManager.cardRoleList:iterator() do
			-- if needAdd(cardRole.gmId, self.roleInfo[Type], defenseList) then
			if 1 then
				local card_copy = clone(cardRole)
				card_copy.fateid = 0
				cardRoleList:push(card_copy)
			end
		end

	elseif Type == LineUpType.LineUp_Mine1_Defense then
		-- local defenseList = ZhengbaManager:getFightList(EnumFightStrategyType.StrategyType_MINE1_DEF)
		local normalRoleList =  ZhengbaManager:getRoleList(EnumFightStrategyType.StrategyType_MINE1_DEF)
		for cardRole in normalRoleList:iterator() do
			-- if needAdd(cardRole.gmId, self.roleInfo[Type], defenseList) then
			if 1 then
				local card_copy = clone(cardRole)
				card_copy.fateid = 0
				cardRoleList:push(card_copy)
			end
		end

	elseif Type == LineUpType.LineUp_Mine2_Defense then
		-- local defenseList = ZhengbaManager:getFightList(EnumFightStrategyType.StrategyType_MINE2_DEF)	
		local normalRoleList =  ZhengbaManager:getRoleList(EnumFightStrategyType.StrategyType_MINE2_DEF)	
		for cardRole in normalRoleList:iterator() do
			-- if needAdd(cardRole.gmId, self.roleInfo[Type], defenseList) then
			if 1 then
				local card_copy = clone(cardRole)
				card_copy.fateid = 0
				cardRoleList:push(card_copy)
			end
		end
	elseif Type == LineUpType.LineUp_DOUBLE_1 or Type == LineUpType.LineUp_DOUBLE_2 then
		-- local defenseList = ZhengbaManager:getFightList(EnumFightStrategyType.StrategyType_MINE2_DEF)	
		local normalRoleList =  ZhengbaManager:getRoleList(Type)	
		for cardRole in normalRoleList:iterator() do
			-- if needAdd(cardRole.gmId, self.roleInfo[Type], defenseList) then
			if 1 then
				local card_copy = clone(cardRole)
				card_copy.fateid = 0
				cardRoleList:push(card_copy)
			end
		end
	elseif Type == LineUpType.LineUp__MERCENARY_TEAM then
		-- local defenseList = ZhengbaManager:getFightList(EnumFightStrategyType.StrategyType_MINE2_DEF)	
		local normalRoleList =  ZhengbaManager:getRoleList(EnumFightStrategyType.StrategyType_MERCENARY_TEAM)	
		for cardRole in normalRoleList:iterator() do
			-- if needAdd(cardRole.gmId, self.roleInfo[Type], defenseList) then
			if 1 then
				local card_copy = clone(cardRole)
				card_copy.fateid = 0
				cardRoleList:push(card_copy)
			end
		end
	elseif Type == LineUpType.LineUp_HIRE_TEAM then
		-- local defenseList = ZhengbaManager:getFightList(EnumFightStrategyType.StrategyType_MINE2_DEF)	
		local normalRoleList =  ZhengbaManager:getRoleList(EnumFightStrategyType.StrategyType_HIRE_TEAM)	
		for cardRole in normalRoleList:iterator() do
			-- if needAdd(cardRole.gmId, self.roleInfo[Type], defenseList) then
			if 1 then
				local card_copy = clone(cardRole)
				card_copy.fateid = 0
				cardRoleList:push(card_copy)
			end
		end
	end

-- for test cardRoleList--
	local cardRoleFateList = TFArray:new()

	local strategyList = self:getStrategyList(Type)
	if strategyList == nil then
		print("can't fint strategy list , type = ", Type)
		return
	end

	-- 传入阵位信息
	local roleFateMap = FateManager:getRoleFateWihtRoleList(strategyList,false,Type)
	FateManager:updateRoleListFate(roleFateMap,cardRoleList,strategyList)


	if Type == LineUpType.LineUp_Main then
		for cardRole in cardRoleList:iterator() do
			if needAdd( cardRole.gmId, self.roleInfo[Type], nil) then
				cardRoleFateList:push(cardRole)
			end			
		end
	elseif Type == LineUpType.LineUp_BloodyBattle then
		for cardRole in cardRoleList:iterator() do
			if needAdd( cardRole.gmId, self.roleInfo[Type], nil) then				
				cardRoleFateList:push(cardRole)
			end			
		end
	elseif Type == LineUpType.LineUp_Attack then
		local attackList = ZhengbaManager:getFightList( EnumFightStrategyType.StrategyType_CHAMPIONS_ATK )
		for cardRole in cardRoleList:iterator() do
			if needAdd(cardRole.gmId, self.roleInfo[Type], attackList) then
				cardRoleFateList:push(cardRole)
			end
		end
	elseif Type == LineUpType.LineUp_Defense then
		local defenseList = ZhengbaManager:getFightList( EnumFightStrategyType.StrategyType_CHAMPIONS_DEF )		
		for cardRole in cardRoleList:iterator() do
			if needAdd(cardRole.gmId, self.roleInfo[Type], defenseList) then
				cardRoleFateList:push(cardRole)
			end
		end
	elseif Type == LineUpType.LineUp_QunhaoDef then
		local defenseList = ZhengbaManager:getFightList( EnumFightStrategyType.StrategyType_AREAN )		
		for cardRole in cardRoleList:iterator() do
			if needAdd(cardRole.gmId, self.roleInfo[Type], defenseList) then
				cardRoleFateList:push(cardRole)
			end
		end	

	elseif Type == LineUpType.LineUp_Mine1_Defense then
		local defenseList = ZhengbaManager:getFightList( EnumFightStrategyType.StrategyType_MINE1_DEF )		
		for cardRole in cardRoleList:iterator() do
			if needAdd(cardRole.gmId, self.roleInfo[Type], defenseList) then
				cardRoleFateList:push(cardRole)
			end
		end	
	elseif Type == LineUpType.LineUp_Mine2_Defense then
		local defenseList = ZhengbaManager:getFightList( EnumFightStrategyType.StrategyType_MINE2_DEF )		
		for cardRole in cardRoleList:iterator() do
			if needAdd(cardRole.gmId, self.roleInfo[Type], defenseList) then
				cardRoleFateList:push(cardRole)
			end
		end	
	elseif Type == LineUpType.LineUp__MERCENARY_TEAM then
		local defenseList = ZhengbaManager:getFightList( EnumFightStrategyType.StrategyType_MERCENARY_TEAM )		
		for cardRole in cardRoleList:iterator() do
			if needAdd(cardRole.gmId, self.roleInfo[Type], defenseList) then
				cardRoleFateList:push(cardRole)
			end
		end	
	elseif Type == LineUpType.LineUp_HIRE_TEAM then
		local defenseList = ZhengbaManager:getFightList( EnumFightStrategyType.StrategyType_HIRE_TEAM )		
		for cardRole in cardRoleList:iterator() do
			if needAdd(cardRole.gmId, self.roleInfo[Type], defenseList) then
				cardRoleFateList:push(cardRole)
			end
		end
	elseif Type == LineUpType.LineUp_DOUBLE_1 or Type == LineUpType.LineUp_DOUBLE_2 then
		local defenseList = ZhengbaManager:getFightList( Type )		
		for cardRole in cardRoleList:iterator() do
			if needAdd(cardRole.gmId, self.roleInfo[Type], defenseList) then
				cardRoleFateList:push(cardRole)
			end
		end		
	end

	-- for test
	print("遍历缘分的结果-------- ", cardRoleFateList:length())
	for role in cardRoleFateList:iterator() do
		if role.fateid and role.fateid > 0 then
			print("-----------fate role name = ", role.name)
		end
	end

	return cardRoleFateList
end

function AssistFightManager:deleteRoleByGmId( gmId )
	for i=1,#self.roleInfo do
		for j=1,#self.roleInfo[i] do
			if self.roleInfo[i][j] == gmId then
				self.roleInfo[i][j] = 0
			end
		end
	end
end

function AssistFightManager:isInAssist( Type, gmId )
	if self.roleInfo[Type] then
		for i=1,#self.roleInfo[Type] do
			if self.roleInfo[Type][i] == gmId then
				return true
			end
		end
	end
	return false
end

function AssistFightManager:isInAssistAll( gmId )
	for i=1,LineUpType.LineUp_MAX do
		if self.roleInfo[i] then
			for j=1,#self.roleInfo[i] do
				if self.roleInfo[i][j] == gmId then
					return true
				end
			end
		end
	end
	return false
end

function AssistFightManager:isinStrategyList( Type,gmId )
	local list  = self:getStrategyList( Type )
	for i=1,9 do
		if list[i] == gmId then
			return true
		end
	end
	return false
end
function AssistFightManager:getStrategyList( Type )
	
	-- if Type == LineUpType.LineUp_Main then
	-- 	return StrategyManager:getList()

	-- elseif Type == LineUpType.LineUp_BloodyBattle then
	-- 	return BloodFightManager:getList()

	-- elseif Type == LineUpType.LineUp_Attack then
	-- 	return ZhengbaManager:getFightList( Type )
		
	-- elseif Type == LineUpType.LineUp_Defense then
	-- 	return ZhengbaManager:getFightList( Type )

	-- elseif Type == LineUpType.LineUp_QunhaoDef then
	-- 	return ZhengbaManager:getFightList( Type )
	-- end

	local roleList = {}
	if Type == EnumFightStrategyType.StrategyType_PVE then
		roleList = StrategyManager:getList()

	elseif Type == EnumFightStrategyType.StrategyType_BLOOY then
		roleList = BloodFightManager:getList()

	elseif Type == EnumFightStrategyType.StrategyType_CHAMPIONS_ATK then
		roleList = ZhengbaManager:getFightList( Type )

	elseif Type == EnumFightStrategyType.StrategyType_CHAMPIONS_DEF then
		roleList = ZhengbaManager:getFightList( Type )

	elseif Type == EnumFightStrategyType.StrategyType_AREAN then
		roleList = ZhengbaManager:getFightList( Type )

	elseif Type == EnumFightStrategyType.StrategyType_MINE1_DEF then
		roleList = ZhengbaManager:getFightList( Type )

	elseif Type == EnumFightStrategyType.StrategyType_MINE2_DEF then
		roleList = ZhengbaManager:getFightList( Type )
	elseif Type == EnumFightStrategyType.StrategyType_MERCENARY_TEAM then
		roleList = ZhengbaManager:getFightList( Type )
	elseif Type == EnumFightStrategyType.StrategyType_HIRE_TEAM then
		roleList = ZhengbaManager:getFightList( Type )
	else
		roleList = ZhengbaManager:getFightList( Type )
	end

	if roleList then
		for k,v in pairs(roleList) do
			local role = CardRoleManager:getRoleByGmid(v)
			if role == nil then
				local mercenary = EmployManager:getMercenaryInAllEmployRole( v )
				if mercenary == nil then
					mercenary = EmployManager:getEmploySingleRoleByGmId( v ,Type)
					if mercenary ==nil then
						roleList[k] = 0
					end
				end
			end
		end
	end
	return roleList
end

function AssistFightManager:getStrategyPower( Type )
	local strategyList = self:getStrategyList( Type )

	if strategyList == nil then
		print("1AssistFightManager:getStrategyPower can't find strategyList, type = ", Type)
		return 0
	end

	local assistList = self:getAssistRoleList(Type)
	if assistList == nil then
		print("2AssistFightManager:getStrategyPower can't find assistList, type = ", Type)
		return 0
	end

	local roleIdList = FateManager:LinkStrategyAndAssit(strategyList, assistList,Type)

	-- local roleIdList = self:gmIdChangeToID(assistList ,Type)

	local allPower = 0
	for i=1,10 do
		if strategyList[i] and strategyList[i] ~= 0 then
			local role = CardRoleManager:getRoleByGmid(strategyList[i])

			if role then
				allPower = allPower + role:getPowerByIdList(roleIdList,Type)
            else
				local mercenary = EmployManager:getMercenaryInAllEmployRole( strategyList[i] )
				if mercenary then
					allPower = allPower + mercenary.power
				else
					mercenary = EmployManager:getEmploySingleRoleByGmId( strategyList[i] ,Type)
					if mercenary then
						allPower = allPower + mercenary.power
					end
				end
            end
		end
	end

	return allPower
end

function AssistFightManager:freshRoleInStrategyPower( Type ,gmId )
	local strategyList = self:getStrategyList( Type )

	if strategyList == nil then
		print("1AssistFightManager:getStrategyPower can't find strategyList, type = ", Type)
		return false
	end

	local assistList = self:getAssistRoleList(Type)
	if assistList == nil then
		print("2AssistFightManager:getStrategyPower can't find assistList, type = ", Type)
		return false
	end

	local roleIdList = FateManager:LinkStrategyAndAssit(strategyList, assistList,Type)

	for i=1,10 do
		if strategyList[i] and strategyList[i] ~= 0 then
			if strategyList[i] == gmId then
				local role = CardRoleManager:getRoleByGmid(strategyList[i])
				if role then
					role:getPowerByIdList(roleIdList,Type)
					return true
				end
			end
		end
		if assistList[i] and assistList[i] ~= 0 then
			if assistList[i] == gmId then
				local role = CardRoleManager:getRoleByGmid(assistList[i])
				if role then
					-- role:getPowerByIdList(roleIdList,Type)
					self:getStrategyPower( Type )
					return true
				end
			end
		end
	end

	return false
end

function AssistFightManager:updateRoleList(Type)
	local cardRoleList = self:getCardRoleList(Type)
end

function AssistFightManager:getOpenLevel()
	return FunctionOpenConfigure:getOpenLevel(1203)    
end
function AssistFightManager:isCanRedPoint( Type )
	--策划取消红点显示
	if 1 then
		return false
	end
	if MainPlayer:getLevel() < self:getOpenLevel() then
		return false
	end
	local unLockData = require('lua.table.t_s_assistant_rule')
    local gridState = self:getGridList() or {}

    for k,v in pairs(gridState) do
    	if v then
    		if self.roleInfo[Type] and self.roleInfo[Type][k] == 0 then
    			return true
    		end
    	else
    		local unLockState = unLockData:getObjectAt(k)
    		if k == 4 and ClimbManager:getClimbFloorNum() >= unLockState.val then
    			return true
    		elseif k == 6 and MainPlayer:getVipLevel() >= unLockState.val then
				return true
			elseif k ~= 5 and MainPlayer:getLevel() >= unLockState.val then
				return true
    		end
    	end
    end
    return false
end

function AssistFightManager:isInAssistBySoulid( soulid )
	--self.roleInfo
	for i=1,LineUpType.LineUp_MAX do
		if self.roleInfo[i] then
			for j=1,#self.roleInfo[i] do
				local cardRole = CardRoleManager:getRoleByGmid(self.roleInfo[i][j])
				if cardRole and cardRole.soul_card_id == soulid then					
					return true					
				end
			end
		end
	end	
	return false
end


-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--契合
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
function AssistFightManager:requestQihe(pos)
	self.qihePos = pos
	TFDirector:send(c2s.LEVEL_UP_AGREE,{pos-1})
	showLoading()
end

function AssistFightManager:qiheSuccessReceive( event )
	hideLoading()
	if self.qihePos then
		self.qiheInfo[self.qihePos] = self.qiheInfo[self.qihePos] or 0
		self.qiheInfo[self.qihePos] = self.qiheInfo[self.qihePos] + 1
	end
	local data = {}
	data.pos = self.qihePos
	data.level = self.qiheInfo[self.qihePos]
	self:refreshRoleQiheAttr()
	TFDirector:dispatchGlobalEventWith(AssistFightManager.levelUpAgreeSuccess, data)

	play_lingdaolitisheng()
end

function AssistFightManager:getQihePreviewInfo(Type)
	local info = {}
	if self.roleInfo[Type] then
		--阵容所加属性
		for k,v in pairs(self.roleInfo[Type]) do
			if v > 0 then
				local currLevel = self.qiheInfo[k]
				local attrTble = AgreeAttributeData:GetAttrTblIndex(currLevel, k)
				local cardRole = CardRoleManager:getRoleByGmid(v)
				local percent = AgreeRuleData:GetPercentValue(currLevel)
				if cardRole then
					-- print('cardRole.name = ',cardRole.name)	
					-- print('totalAttributeForQihe = ',cardRole.totalAttributeForQihe:getAttribute())	
					-- print('fateAttribute = ',cardRole.fateAttribute:getAttribute())
					for _,v in pairs(attrTble) do
						local attridx = tonumber(v)
						-- local num = cardRole:getTotalAttribute(attridx)						
						local num = cardRole:getTotalAttributeWithOutQihe(attridx)
						-- print('attridx = '..attridx..',num = '..num)	
						num = math.floor((percent/10000)*num)
						info[attridx] = info[attridx] or 0
						info[attridx] = info[attridx] + num
					end
				end
			end
		end
		--成就所加属性
		local achieveLevel = self:getAchieveLevel()
		local achieveAttr = self:getAchieveTotalAttr(achieveLevel)

		for k,v in pairs(achieveAttr) do
			info[k] = info[k] or 0
			info[k] = info[k] + v
		end
	end
	return info
end

function AssistFightManager:getAchieveLevel()

	local function copyTab(st)
	    local tab = {}
	    for k, v in pairs(st or {}) do
	        if type(v) ~= "table" then
	            tab[k] = v
	        else
	            tab[k] = copyTab(v)
	        end
	    end
	    return tab
	end	
	local sorTable = copyTab(self.qiheInfo)


	local function comps(a,b)
		return a > b
	end
	table.sort(sorTable, comps)
	-- print('checkNumLevelsorTable = ',sorTable)

	local function checkNumLevel( num, level )
		if sorTable[num] >= level then
			return true
		else
			return false
		end
	end

	local achieveLevel = 0
	for v in AgreeConditionData:iterator() do
		if checkNumLevel( v.arg1, v.arg2 ) then
			achieveLevel = achieveLevel + 1
		else
			return achieveLevel
		end
	end
	return achieveLevel
end

function AssistFightManager:getQiheLevelInfo()
	return self.qiheInfo
end

function AssistFightManager:getAchieveTemplete(level)

	local attrTbl = {}
	local achieveName = ''
	for v in AgreeConditionAttributeData:iterator() do
		if v.id == level then
			local data = string.split(v.attribute, '|')
			for k,v in pairs(data) do
				local details = string.split(v, '_')
				local attrIdx = tonumber(details[1])
				attrTbl[attrIdx] = tonumber(details[2])
			end
			achieveName = v.name
			return attrTbl,achieveName
		end
	end
	return attrTbl,achieveName
end

function AssistFightManager:getAchieveTotalAttr(level)
	local attrTbl = {}
	for v in AgreeConditionAttributeData:iterator() do
		if v.id <= level then
			local data = string.split(v.attribute, '|')
			for k,v in pairs(data) do
				local details = string.split(v, '_')
				local attrIdx = tonumber(details[1])
				local value = tonumber(details[2])
				attrTbl[attrIdx] = attrTbl[attrIdx] or 0
				attrTbl[attrIdx] = attrTbl[attrIdx] + value
			end
		else
			return attrTbl
		end
	end
	return attrTbl
end

function AssistFightManager:getAchieveState(level)

	local total = 1
	local currNum = 0
	for v in AgreeConditionData:iterator() do
		if v.id == level then
			local total = v.arg1

			currNum = 0
			for _,posLevel in pairs(self.qiheInfo) do
				if posLevel >= v.arg2 then
					currNum = currNum + 1
				end
			end
			return currNum,total
		end
	end
	return currNum,total
end

function AssistFightManager:refreshRoleQiheAttr()
	
	local Type = LineUpType.LineUp_Main
	-- local roleList = self.roleInfo[Type] or {}
	local roleList = StrategyManager:getList() or {}
	for _,gmid in pairs(roleList) do
		if gmid > 0 then
			local cardRole = CardRoleManager:getRoleByGmid( gmid )
			if cardRole then
				cardRole:updateQihe()
			end
		end
	end
end

function AssistFightManager:checkIsStrategyMember( gmid )
	local roleList = StrategyManager:getList()
	roleList = roleList or {}
	for _,v in pairs(roleList) do
		if v == gmid then
			return true
		end
	end
	return false
end
function AssistFightManager:checkIsStrategyMemberByFightType( gmid ,fight_type)
	local roleList = self:getStrategyList(fight_type)
	roleList = roleList or {}
	for _,v in pairs(roleList) do
		if v == gmid then
			return true
		end
	end
	return false
end

function AssistFightManager:getGmidByPos(Type, pos)
	if self.roleInfo[Type] then
		return self.roleInfo[Type][pos] or 0
	end
	return 0
end

function AssistFightManager:getLastSelectPos()
	return self.lastAgreePos
end
function AssistFightManager:setLastSelectPos(pos)
	self.lastAgreePos = pos
end

function AssistFightManager:OnBattle( gmId, curIndex )
   
end

function AssistFightManager:OutBattle(gmId)
    
end

function AssistFightManager:ChangePos(oldpos, newpos)
   
end

function AssistFightManager:getRoleInfoByType(type)
   if type == 1 then
   		return self.myProvideRole
   else
   		return self.myRequestRole
   end
end

function AssistFightManager:getRequestRoleList( Type )
	-- if 1 then
	-- 	print('test = ',FateManager:checkRoleFate({2}, {}, 14))
	-- 	return
	-- end

	local strategyTbl = {}
	local strategylist = self:getStrategyList(Type)
	-- print('Type = ',Type)
	-- print('strategylist = ',strategylist)
	for _,gmId in pairs(strategylist) do
		local cardRole = CardRoleManager:getRoleByGmid(gmId)
		if cardRole then
			strategyTbl[#strategyTbl + 1] = cardRole.id
		end
	end
	local assistTbl = {}
	local assistlist = self:getAssistRoleList(Type)
	for _,gmId in pairs(assistlist) do
		local cardRole = CardRoleManager:getRoleByGmid(gmId)
		if cardRole then
			assistTbl[#assistTbl + 1] = cardRole.id
		end
	end

	local roleList = TFArray:new()
	for v in RoleData:iterator() do
		-- if v.on_show == 1 and self:checkRoleIsPossess(v.id) == false then
		if v.on_show == 1 then					
			if FateManager:checkRoleFate(strategyTbl, assistTbl, v.id) then
				v.fate = 1
				print('v.name = ',v.name)
			else
				v.fate = 0
			end

			roleList:pushBack(v)
		end
	end

	local function sortList(v1,v2)
		if v1.fate == v2.fate then
			if v1.quality == v2.quality then
				return v1.id < v2.id
			else
				return v1.quality > v2.quality
			end
		else
			return v1.fate > v2.fate
		end
	end
	roleList:sort(sortList)
	return roleList
end

function AssistFightManager:checkRoleIsPossess(roleId)
	for cardRole in CardRoleManager.cardRoleList:iterator() do
		if cardRole.id == roleId then
			return true
		end			
	end
	return false
end

--请求好友侠客库信息
function AssistFightManager:requestFriendAssistList(clickCallBack)
 	self.friendAssistListCB = clickCallBack
	TFDirector:send(c2s.GAIN_FRIEND_ASSISTANT_INFO_LIST,{})
	showLoading()
end

function AssistFightManager:onFriendAssistList(event)
	hideLoading()
	--侠客库列表信息
	self.friendAssistList = {}
	if event.data.infos then
		for k,v in pairs(event.data.infos) do
			local idx = #self.friendAssistList + 1
			self.friendAssistList[idx] = {}
			self.friendAssistList[idx].friendId = v.friendId
			self.friendAssistList[idx].demandRole = v.demandRole
			self.friendAssistList[idx].provideRoles = v.provideRoles
			self.friendAssistList[idx].roleUseCount = {}
			if v.roleUseCount and v.roleUseCount ~= "" then
				local roletbl = string.split(v.roleUseCount,"|")
				for _,roleDetail in pairs(roletbl) do
					local details = string.split(roleDetail, '_')
					local roleId = tonumber(details[1])
					local count = tonumber(details[2])
					local playerName = details[3]
					self.friendAssistList[idx].roleUseCount[roleId] = {}
					self.friendAssistList[idx].roleUseCount[roleId].times = count
					self.friendAssistList[idx].roleUseCount[roleId].playerName = playerName
				end
			end
		end
	end
	-- print('event.data.infos = ',event.data.infos)
	-- pp.pp = 1

	--自己用过的好友列表
	self.usePlayersList = {}
	if event.data.usePlayers then
		self.usePlayersList = stringToNumberTable(event.data.usePlayers, ',')
	end
	-- print('event.data.usePlayers = ',event.data.usePlayers)
	-- print('self.usePlayersList = ',self.usePlayersList)
	-- pp.pp = 1
	--自己助战过的好友列表
	-- print('event.data = ',event.data)
	-- pp.pp = 1
	self.assistPlayerList = {}
	if event.data.assistantPlayers then
		self.assistPlayerList = stringToNumberTable(event.data.assistantPlayers, ',')
	end
	-- print('self.assistPlayerList = ',self.assistPlayerList)
	-- pp.pp = 1

	--自己侠客助战次数
	self.myRoleUseCountList = {}
	if event.data.roleUseCount and event.data.roleUseCount ~= "" then
		local info = string.split(event.data.roleUseCount, '|') or {}
		for k,v in pairs(info) do
			local details = string.split(v, '_')
			local roleId = tonumber(details[1])
			local count = tonumber(details[2])
			local playerName = details[3]

			self.myRoleUseCountList[roleId] = {}
			self.myRoleUseCountList[roleId].times = count
			self.myRoleUseCountList[roleId].playerName = playerName
		end		
	end

	self.myProvideRole = {}
	if event.data.provideRoles then
		self.myProvideRole = stringToNumberTable(event.data.provideRoles, ',')
	end

	self.myRequestRole = event.data.demandRole or 0

	if self.friendAssistListCB then
		TFFunction.call(self.friendAssistListCB)
		self.friendAssistListCB = nil
	end
	TFDirector:dispatchGlobalEventWith(AssistFightManager.FRIENDASSISTLIST, {})
end

--是否在自己用过的好友列表中
function AssistFightManager:checkInUsePlayerList( playerId )
	for _,v in pairs(self.usePlayersList) do
		if v == playerId then
			return true
		end
	end
	return false
end

--是否在自己助战过的好友列表中
function AssistFightManager:checkInassistPlayerList( playerId )
	-- print('self.assistPlayerList = ',self.assistPlayerList)
	for _,v in pairs(self.assistPlayerList) do
		if v == playerId then
			return true
		end
	end
	return false
end

function AssistFightManager:getFriendNameByPlayerId( playerId )
	local friendList = FriendManager:getFriendInfoList()
	for k,v in pairs(friendList) do
		if v.info.playerId == playerId then
			return v.info.name
		end
	end
	print('cannot find the player with Id = ', playerId)
	return ""
end

--获取好友库列表
function AssistFightManager:getFriendAssistListForSelect(Type)
	
	local strategyTbl = {}
	local strategylist = self:getStrategyList(Type)
	
	for _,gmId in pairs(strategylist) do
		local cardRole = CardRoleManager:getRoleByGmid(gmId)
		if cardRole then
			strategyTbl[#strategyTbl + 1] = cardRole.id
		end
	end
	local assistTbl = {}
	local assistlist = self:getAssistRoleList(Type)
	for _,gmId in pairs(assistlist) do
		local cardRole = CardRoleManager:getRoleByGmid(gmId)
		if cardRole then
			assistTbl[#assistTbl + 1] = cardRole.id
		end
	end

	-- local roleList = TFArray:new()
	-- for v in RoleData:iterator() do
	-- 	-- if v.on_show == 1 and self:checkRoleIsPossess(v.id) == false then
	-- 	if v.on_show == 1 then					
	-- 		if FateManager:checkRoleFate(strategyTbl, assistTbl, v.id) then
	-- 			v.fate = 1
	-- 			print('v.name = ',v.name)
	-- 		else
	-- 			v.fate = 0
	-- 		end

	-- 		roleList:pushBack(v)
	-- 	end
	-- end

	-- -- ]]


 --    local assistlist = {}
 --    assistlist = FateManager:LinkStrategyAndAssit(self:getStrategyList(Type), self:getAssistRoleList(Type),Type)

	local roleList = {}
	local roleListNoFate = {}
	for k,v in pairs(self.friendAssistList) do
		if v.provideRoles then
			local roleTbl = stringToNumberTable(v.provideRoles, ',') or {}
			for _,roleId in pairs(roleTbl) do
				local data = {}
				data.playerId = v.friendId
				data.role = RoleData:objectByID(roleId)
				local useTimes = 0
				if v.roleUseCount[roleId] and v.roleUseCount[roleId].times then
					useTimes = v.roleUseCount[roleId].times
				end
				if data.role and ((data.role.quality == 5 and useTimes < 3) or (data.role.quality == 4 and useTimes < 1)) then
					data.playerName = self:getFriendNameByPlayerId(data.playerId)					
					if FateManager:checkRoleFate(strategyTbl, assistTbl, roleId) then
						data.fate = 1
					else
						data.fate = 0
					end
					if self:checkInUsePlayerList(data.playerId) == false then
						if data.fate == 1 then
							table.insert(roleList, data)							
						else
							table.insert(roleListNoFate, data)
						end
					end
				end
			end
		end
	end

	local function sortByQuality( v1, v2 )
		if v1.role.quality == v2.role.quality then
			return v1.role.id < v2.role.id
		else
			return v1.role.quality > v2.role.quality
		end
	end
	table.sort(roleList, sortByQuality)
	table.sort(roleListNoFate, sortByQuality)

	for k,v in pairs(roleListNoFate) do
		table.insert(roleList, v)
	end
	-- print('roleList = ',roleList)
	return roleList
end

--获取好友列表的助战信息
function AssistFightManager:getFriendAssistListForView()
	if self.friendAssistList == nil then
		return nil
	end
	local function getAssistDataByPlayerId( playerId )	
		for _,data in pairs(self.friendAssistList) do
			if data.friendId == playerId then
				return data
			end
		end
		print('cannot find data in friend assist with id = ',playerId)
		return nil
	end

	local friendList = FriendManager:getFriendInfoList() or {}
	local roleList = {}
	for k,v in pairs(friendList) do
		local info = getAssistDataByPlayerId(v.info.playerId) or {}
		-- if info 
		-- print('info = ',info)
		local roleInfo = info.roleUseCount or {}
		-- print('roleInfo = ',roleInfo)
		local data = {}
		data.baseInfo = v.info
		--玩家提供的信息
		data.provideRole = {}
		data.isGet = self:checkInUsePlayerList(v.info.playerId)
		if info and info.provideRoles then
			local provideRoles = stringToNumberTable(info.provideRoles, ',') or {}
			for _,roleId in pairs(provideRoles) do
				local idx = #data.provideRole + 1
				data.provideRole[idx] = {}
				data.provideRole[idx].times = 0
				data.provideRole[idx].playerName = nil
				data.provideRole[idx].role = RoleData:objectByID(roleId)
				if data.provideRole[idx].role.quality == 5 then
					data.provideRole[idx].maxTimes = 3
				else
					data.provideRole[idx].maxTimes = 1
				end
				if roleInfo[roleId] then					
					data.provideRole[idx].times = roleInfo[roleId].times
					data.provideRole[idx].playerName = roleInfo[roleId].playerName
				else
					data.provideRole[idx].times = 0
				end
			end
		end
		--玩家需求的信息
		data.requestRole = {}
		data.isGive = self:checkInassistPlayerList(v.info.playerId)
		if info and info.demandRole and info.demandRole ~= 0 then
			-- print('info = ',info)
			-- print('roleInfo = ',roleInfo)
			local roleId = tonumber(info.demandRole)
			data.requestRole.role = RoleData:objectByID(roleId)
			if roleInfo[roleId] then
				data.requestRole.times = roleInfo[roleId].times
				data.requestRole.playerName = roleInfo[roleId].playerName
			else
				data.requestRole.times = 0
			end
		end
		table.insert(roleList, data)
	end

	local function sortByPower(v1, v2)
		return v1.baseInfo.power > v2.baseInfo.power
	end
	table.sort(roleList, sortByPower)

	return roleList
end

--修改需求侠客
function AssistFightManager:requestUpdateDemand(roleId)
	self.requestUpdateDemandId = roleId
	local roledata = RoleData:objectByID(roleId)
	print('roledata.name = ',roledata)
	-- pp.pp = 1
	TFDirector:send(c2s.UPDATE_DEMAND,{roleId})
	showLoading()
end
function AssistFightManager:updateDemandSuccess( event )
	hideLoading()
	self.myRequestRole = self.requestUpdateDemandId

	TFDirector:dispatchGlobalEventWith(AssistFightManager.UPDATEDEMANDROLE, {})
end

--修改提供侠客
function AssistFightManager:requestUpdateProvide(role1, role2)
	self.updateProvideRoleTbl = {}
	self.updateProvideRoleTbl[1] = role1
	self.updateProvideRoleTbl[2] = role2

	TFDirector:send(c2s.UPDATE_PROVIDE,{{role1, role2}})
	showLoading()
end
function AssistFightManager:updateProvideSuccess( event )
	hideLoading()
	self.myProvideRole = {}
	for i=1,2 do
		local cardRole = CardRoleManager:getRoleByGmid(self.updateProvideRoleTbl[i])
		if cardRole then
			self.myProvideRole[i] = cardRole.id
		else
			self.myProvideRole[i] = 0
		end
	end

	TFDirector:dispatchGlobalEventWith(AssistFightManager.UPDATEPROVIDE, {})
end

--获得助战侠客
function AssistFightManager:requestGetAssitRole( friendId, roleId, dispatchMsg )
	TFDirector:send(c2s.GAIN_ASSISTANT_ROLE,{friendId, roleId})
	showLoading()
	self.getAssitRoleFriendId = friendId
	self.getAssitRoleRoleId = roleId
	self.getAssitRoleNeedMsg = dispatchMsg

	self.getAssitRoleFriendName = self:getFriendNameByPlayerId( friendId )
	local cardRole = RoleData:objectByID(roleId) or {}
	self.getAssitRoleRoleName = cardRole.name
	-- self:getAssistRoleSuccess()
end
function AssistFightManager:getAssistRoleSuccess( event )
	hideLoading()

	self.friendRoleInfo = {}
	self.friendRoleInfo.friendRoleId = self.getAssitRoleRoleId or 0
	self.friendRoleInfo.friendProvideTime = MainPlayer:getNowtime()*1000 or 0

	local idx = #self.usePlayersList + 1
	self.usePlayersList[idx] = self.getAssitRoleFriendId

	for i=1,#self.friendAssistList do
		if self.friendAssistList[i].friendId == self.getAssitRoleFriendId then
			self.friendAssistList[i].roleUseCount[self.getAssitRoleRoleId] = self.friendAssistList[i].roleUseCount[self.getAssitRoleRoleId] or {}
			self.friendAssistList[i].roleUseCount[self.getAssitRoleRoleId].times = self.friendAssistList[i].roleUseCount[self.getAssitRoleRoleId].times or 0
			self.friendAssistList[i].roleUseCount[self.getAssitRoleRoleId].times = self.friendAssistList[i].roleUseCount[self.getAssitRoleRoleId].times + 1
			self.friendAssistList[i].roleUseCount[self.getAssitRoleRoleId].playerName = MainPlayer:getPlayerName()
			break			
		end
	end

	TFDirector:dispatchGlobalEventWith(self.getAssitRoleNeedMsg, {self.getAssitRoleFriendName, self.getAssitRoleRoleName})
end

--给予助战侠客
function AssistFightManager:requestGiveAssisRole( msg )
	-- print('msg = ',msg)
	TFDirector:send(c2s.PROVIDE_FRIEND_ASSISTANT,{msg})
	showLoading()
end

function AssistFightManager:giveAssisRoleSuccess( event )
	hideLoading()
	TFDirector:dispatchGlobalEventWith(AssistFightManager.GETASSISTROLESUCCESSFORFRIEND, {})	
end

function AssistFightManager:getFriendIconInfo()
	return self.friendRoleInfo
end

function AssistFightManager:getMyRoleUseInfo( roleId )
	return self.myRoleUseCountList[roleId]
end

function AssistFightManager:getAssistOtherCount()

	local count = 0

	if self.myRoleUseCountList then
		for k,v in pairs(self.myRoleUseCountList) do
			count = count + v.times
		end
	end

	-- if self.assistPlayerList then
	-- 	count = count + #self.assistPlayerList
	-- end

	return count
end

--领取助战奖励
function AssistFightManager:requestDrawAssitAward(friendIdTble)

	TFDirector:send(c2s.DRAW_ASSISTANT_AWARD,{friendIdTble})
	showLoading()
end

function AssistFightManager:resetDataInfo_24()
	self.friendRoleInfo = {}
end

function AssistFightManager:gotoFriendAssistForTask( LineUpType )
	local function friendAssistCallBack()
     --    local layer = AlertManager:addLayerByFile("lua.logic.assistFight.ZhuzhanFriendLayer", AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
	    -- layer:setLineUpType(LineUpType)
	    -- AlertManager:show()
	    FriendManager:openFriendZhuzhanLayer()
    end
    self:requestFriendAssistList(friendAssistCallBack)
end
return AssistFightManager:new();

