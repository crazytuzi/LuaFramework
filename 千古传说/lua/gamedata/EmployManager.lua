--[[
	**********雇佣管理器****************
]]

local EmployManager = class("EmployManager")

EmployManager.MyEmployInfoMessage = "EmployManager.MyEmployInfoMessage"
EmployManager.AllEmployInfoMessage = "EmployManager.AllEmployInfoMessage"

EmployManager.MyEmployTeamMessage = "EmployManager.MyEmployTeamMessage"
EmployManager.AllEmployTeamMessage = "EmployManager.AllEmployTeamMessage"
EmployManager.ShowEmployReward = "EmployManager.ShowEmployReward"

EmployManager.UPDATEFORMATIONSUCESS = "EmployManager.UPDATEFORMATIONSUCESS"
EmployManager.EmployTeamSuccessNotice = "EmployManager.EmployTeamSuccessNotice"
EmployManager.EmployTeamFormationSuccessNotice = "EmployManager.EmployTeamFormationSuccessNotice"
EmployManager.EmploySingleRoleSuccessNotice = "EmployManager.EmploySingleRoleSuccessNotice"
EmployManager.UpdateEmployFormationMessage = "EmployManager.UpdateEmployFormationMessage"
EmployManager.EmploySingleRoleErrorNotice = "EmployManager.EmploySingleRoleErrorNotice"


EmployManager.AddEmployRole = 1
EmployManager.RemoveEmployRole = 2
EmployManager.GetRewardEmployRole = 3

EmployManager.GetRewardEmployTeam = 1
EmployManager.RemoveEmployTeam = 2
function EmployManager:ctor()
	self.myEmployRoleList = TFArray:new()
	self.employedPlayerList = TFArray:new()
	self.employRoleList = TFArray:new()


	self.myEmployTeamDetalis = {}


	self.myHireRoleDetalis = {}
	self.myHireTeamDetalis = {} -- 已雇佣队伍
	self.allHireTeamDetalis = TFArray:new()-- 所有雇佣队伍
	self.allHireRoleDetalis = TFArray:new()-- 所有雇佣角色

	self.employTeamList = TFArray:new()

	self.hasGetTeamInfo = false
    TFDirector:addProto(s2c.MY_EMPLOY_INFO, self, self.receiveMyEmployInfo)
    TFDirector:addProto(s2c.EMPLOY_ROLE_OPERATION_RESULT, self, self.EmployRoleOperationResult)
    TFDirector:addProto(s2c.EMPLOY_OTHER_INFO_RESULT, self, self.EmployOtherInfoResult)
    TFDirector:addProto(s2c.ALL_EMPLOY_INFO, self, self.receiveAllEmployInfo)

	TFDirector:addProto(s2c.MERCENARY_TEAM_OUTLINE_LIST, self, self.mercenaryTeamOutlineListMsg)
	TFDirector:addProto(s2c.DISPATCH_MERCENARY_TEAM_SUCCESS, self, self.dispatchMercenaryTeamSuccess)
	TFDirector:addProto(s2c.MY_MERCENARY_TEAM_DETAILS, self, self.myMercenaryTeamDetails)
	TFDirector:addProto(s2c.MERCEANRY_TEAM_OPERATION_NOTIFY, self, self.merceanryTeamOperationNotify)


	TFDirector:addProto(s2c.EMPLOY_TEAM_SUCCESS, self, self.employTeamSuccess)
	TFDirector:addProto(s2c.EMPLOY_TEAM_DETAILS, self, self.employTeamDetails)
	TFDirector:addProto(s2c.MODIFY_EMPLOY_TEAM_FORMATION_SUCCESS, self, self.modifyEmployTeamFormationSuccess)
	TFDirector:addProto(s2c.EMPLOY_TEAM_LIST, self, self.employTeamListMessage)

	TFDirector:addProto(s2c.EMPLOY_TEAM_COUNT, self, self.employTeamCount)
	TFDirector:addProto(s2c.EMPLOY_TEAM_COUNT_LIST, self, self.employTeamCountList)

	TFDirector:addProto(s2c.EMPLOY_SINGLE_ROLE_DETAILS, self, self.EmploySingleRoleDetails)
	TFDirector:addProto(s2c.EMPLOY_ROLE_COUNT_LIST, self, self.EmployRoleCountList)
	TFDirector:addProto(s2c.EMPLOY_SINGLE_ROLE_LIST, self, self.EmploySingleRoleList)
	TFDirector:addProto(s2c.EMPLOY_SINGLE_ROLE_LIST_BY_USE_TYPE, self, self.EmploySingleRoleListByUseType)
	TFDirector:addProto(s2c.EMPLOY_ROLE_COUNT, self, self.EmployRoleCount)
	TFDirector:addProto(s2c.EMPLOY_SINGLE_ROLE_SUCCESS, self, self.EmploySingleRoleSuccess)
	ErrorCodeManager:addProtocolListener(s2c.EMPLOY_SINGLE_ROLE_SUCCESS, function() self:EmploySingleRoleErrorHandle() end)

	TFDirector:addProto(s2c.EMPLOY_SINGLE_ROLE_RELEASE, self, self.EmploySingleRoleRelease)
	TFDirector:addProto(s2c.UPDATE_EMPLOY_FORMATION_NOTIFY, self, self.updateEmployFormationNotify)

end

function EmployManager:restart()
	self.myEmployRoleList:clear()
	self.employedPlayerList:clear()
	self.employRoleList:clear()
	self.employTeamList:clear()
	self:clearMyEmployTeamDetalis()
	self.myHireTeamDetalis = {} -- 已雇佣队伍
	self.myHireRoleDetalis = {} -- 已雇佣队伍
	self.allHireTeamDetalis:clear()
	self.allHireRoleDetalis:clear()
	self.hasGetTeamInfo = false
	self.isClear = false
end

function EmployManager:resetByDay()
	self.allHireTeamDetalis:clear()
	self.allHireRoleDetalis:clear()
end

function EmployManager:getMyEmployInfo()
	showLoading()
	TFDirector:send(c2s.REQUEST_MY_EMPLOY_INFO,{})
	if self.hasGetTeamInfo then
		self:queryMyMercenaryTeam()
	end
	-- local event = {}
	-- event.data ={}
	-- event.data.roleList = {}

	-- for i=1,2 do
	-- 	local role = {}
	-- 	local roleInfo = CardRoleManager.cardRoleList:objectAt(i)
	-- 	role.roleId = roleInfo.gmId
	-- 	role.startTime = MainPlayer:getNowtime() - 7405
	-- 	role.coin = 5000
	-- 	role.indexId = i
	-- 	role.count = 10
	-- 	event.data.roleList[#event.data.roleList+1] = role
	-- end
	-- self:receiveMyEmployInfo(event)
end


function EmployManager:receiveMyEmployInfo(event)
	hideLoading();
	local data = event.data
	self.myEmployRoleList:clear()
	if data.roleList ~= nil then
		for i=1, #data.roleList do
			self.myEmployRoleList:pushBack(data.roleList[i])
		end
	end
	TFDirector:dispatchGlobalEventWith(EmployManager.MyEmployInfoMessage ,{})
end

function EmployManager:EmployRoleOperation(instance_id , operation)
	local indexId = 1
	if operation == 1 then
		indexId = self:getIndexMin()
		if indexId == -1 then
			-- toastMessage("放置角色已满")
			toastMessage(localizable.EmployManager_role_is_full)
			return
		end


		-- local role = {}
		-- role.roleId = instance_id
		-- role.startTime = MainPlayer:getNowtime()
		-- role.coin = 5000
		-- role.indexId = indexId
		-- role.count = 0

		-- local event = {data = {role = role ,operation = 1}}
		-- self:EmployRoleOperationResult(event)
		-- return
	else
		local employRole = self:getEmployRoleByGmid(instance_id)
		if employRole == nil then
			print("无法找到该角色 gmid == ",instance_id)
			return
		end
		indexId = employRole.indexId

		-- local event = {data = {role = employRole ,operation = 2}}
		-- self:EmployRoleOperationResult(event)
		-- return
	end
	local msg = {
		instance_id,
		operation,
		indexId,
	}
	showLoading()
	TFDirector:send(c2s.EMPLOY_ROLE_OPERATION,msg)

end

function EmployManager:getRoleHoleNum()
	local holeNum = 0
	local vip_level = MainPlayer:getVipLevel()
	for v in MercenaryConfig:iterator() do
        if v.type == 1 and  v.vip_level <= vip_level then
            holeNum = holeNum + 1
        end
    end
	return holeNum
end
function EmployManager:getIndexMin(index)
	if index == nil then
		index = 1
	end
	local temp = 1
	local holeNum = self:getRoleHoleNum()
	for i=1,holeNum do
		local holeHas = false
		for v in self.myEmployRoleList:iterator() do
			if v.indexId == i then
				holeHas = true
			end
		end
		if holeHas == false then
			if temp == index then
				return i
			else
				temp = temp + 1
			end
		end
	end
	return -1
end



function EmployManager:getEmployRoleByIndex( index )
	for v in self.myEmployRoleList:iterator() do
		if v.indexId == index then
			return v
		end
	end
	return nil
end
function EmployManager:getEmployRoleByGmid( gmid )
	for v in self.myEmployRoleList:iterator() do
		if v.roleId == gmid then
			return v
		end
	end
	return nil
end

function EmployManager:EmployRoleOperationResult(event)
	hideLoading();
	local data = event.data
	if data.operation == 1 then
		self.myEmployRoleList:pushBack(data.role)
	elseif data.operation == 2 then
		local role = self:getEmployRoleByGmid(data.role.roleId)
		if role == nil then
			print("找不到该角色 id == ",data.role.roleId)
			return
		end
		self.myEmployRoleList:removeObject(role)
		self:openEmployReward(data.coin)
	elseif data.operation == 3 then

	end
	TFDirector:dispatchGlobalEventWith(EmployManager.MyEmployInfoMessage ,{})
end
function EmployManager:getEmployOtherInfo()
	TFDirector:send(c2s.EMPLOY_OTHER_INFO,{})
end

function EmployManager:EmployOtherInfoResult(event)
	local data = event.data
	self.employedPlayerList:clear()
	if data.info ~= nil then
		for i=1, #data.info do
			self.employedPlayerList:pushBack(data.info[i])
		end
	end
end

function EmployManager:requestAllEmployInfo()
	showLoading()
	TFDirector:send(c2s.REQUEST_ALL_EMPLOY_INFO,{})

	-- local tempName = {"好鸡巴戴","坏鸡巴戴","好鸡巴维","坏鸡巴维","好鸡巴康","坏鸡巴康"}

	-- local event = {}
	-- event.data ={}
	-- event.data.info = {}
	-- for i=1,80 do
	-- 	local role = {}
	-- 	role.instanceId = 10000+i;
	-- 	role.playerId = math.random(1,4)+70;
	-- 	role.name = tempName[math.mod(i,6)+1];
	-- 	role.relation  = math.mod(i,3)+1;
	-- 	role.roleId = math.random(1,100);
	-- 	role.level = math.random(1,100);
	-- 	role.start = math.random(1,5);
	-- 	role.martial = math.random(1,11);
	-- 	role.power = math.random(1,100) * 10000 + math.random(1,1000);

	-- 	event.data.info[#event.data.info+1] = role
	-- end
	-- self:receiveAllEmployInfo(event)

end

function EmployManager:receiveAllEmployInfo(event)
	hideLoading();
	self.employRoleList:clear()
	local data = event.data
	if data.info ~= nil then
		for i=1, #data.info do
			data.info[i].gmId = data.info[i].instanceId
			self.employRoleList:pushBack(data.info[i])
		end
	end
	TFDirector:dispatchGlobalEventWith(EmployManager.AllEmployInfoMessage ,{})
end

function EmployManager:openEmployLayer()
	local layer = require("lua.logic.employ.EmployBaseLayer"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY)
    AlertManager:show()
end

 
--获得佣兵队伍概要信息列表
function EmployManager:requestMercenaryTeamListOutline(start,length)
	if start == nil then
		start = 0
	end
	if length == nil then
		length = 0
	end
	showLoading()
	TFDirector:send(c2s.REQUEST_MERCENARY_TEAM_LIST_OUTLINE,{start,length})
end

--派遣佣兵队伍
function EmployManager:dispatchMercenaryTeam(battleRole,assistant)
	-- if 1 then
	-- 	self:testDispatchMercenaryTeam(battleRole,assistant)
	-- 	return
	-- end
	print("battleRole",battleRole)
	print("assistant",assistant)
	local msg = {
	battleRole,
	assistant,
	}
	showLoading()
	self.isClear = false
	TFDirector:send(c2s.DISPATCH_MERCENARY_TEAM,msg)
end

-- function EmployManager:testDispatchMercenaryTeam( battleRole,assistant )
-- 	local event = {}
-- 	event.data = {}
-- 	event.data.battleRole ={}
-- 	for i=1,#battleRole do
-- 		local info = battleRole[i]
-- 		local role = { instanceId = info[1],position = info[2] }
-- 		event.data.battleRole[#event.data.battleRole+1] = role
-- 	end
-- 	event.data.assistant ={}
-- 	for i=1,#assistant do
-- 		local info = assistant[i]
-- 		local role = { instanceId = info[1],position = info[2] }
-- 		event.data.assistant[#event.data.assistant+1] = role
-- 	end

-- 	event.data.startTime 	= MainPlayer:getNowtime()
-- 	event.data.coin 	= 10000
-- 	event.data.employCount 	= 0
-- 	self:myMercenaryTeamDetails(event)
-- end

--查询我的佣兵队伍信息
function EmployManager:queryMyMercenaryTeam()
	showLoading()
	TFDirector:send(c2s.QUERY_MY_MERCENARY_TEAM,{})
end

--领取奖励或者归队
function EmployManager:merceanryTeamOperation(operation)
	showLoading()
	TFDirector:send(c2s.MERCEANRY_TEAM_OPERATION,{operation})
end


--[[

//佣兵队伍概要信息
message MercenaryTeamOutlineMsg
{
	required int32 playerId = 1;					//发布佣兵信息的玩家ID
	required int32 power = 2;						//战力
	required string playerName = 3;					//佣兵主人名字
	repeated MercenaryRoleOutline battleRole = 4;	//角色列表
	required int32 relation  = 5;					//关系 二进制 00 表示没关系 01表示好友 10表示帮派 11表示好友和帮派
}

//简单佣兵单位信息
message MercenaryRoleOutline{
	required int64 instanceId = 1;				//角色实例id
	required int32 roleId = 2;					//角色id
	required int32 level = 3;					//等级
	required int32 starLevel = 4;				//星级
	required int32 martialLevel = 5;			//秘籍重数
	required int32 position = 6;				//上阵位置
}
]]

--佣兵队伍概要信息
function EmployManager:mercenaryTeamOutlineListMsg(event)
	hideLoading()
	local data = event.data
	self.employTeamList:clear()
	if data.outline ~= nil then
		for i=1, #data.outline do
			self.employTeamList:pushBack(data.outline[i])
		end
	end
	TFDirector:dispatchGlobalEventWith(EmployManager.AllEmployTeamMessage ,{})
end


--派遣队伍成功通知，用于客户端取消菊花
function EmployManager:dispatchMercenaryTeamSuccess(event)
	hideLoading()
end

--[[

//上阵角色
message MercenaryTeamRole
{
	required int64 instanceId = 1;				//角色实例ID
	required int32 position = 2;				//位置，0~8
}
]]
--我的佣兵队伍
function EmployManager:myMercenaryTeamDetails(event)
	hideLoading()
	if self.isClear then
		return
	end
	local data = event.data
	self.myEmployTeamDetalis = data
	self.hasGetTeamInfo = true
	print("myMercenaryTeamDetails------------->",data)
	if data.startTime == 0 then
		self:clearMyEmployTeamDetalis()
		TFDirector:dispatchGlobalEventWith(EmployManager.MyEmployTeamMessage ,{})
		return
	end


	local battleList = {}
	for i=1,9 do
		battleList[i] = 0
	end
	if self.myEmployTeamDetalis.battleRole ~= nil then
		for i=1,#self.myEmployTeamDetalis.battleRole do
			local info = self.myEmployTeamDetalis.battleRole[i]
			battleList[info.position+1] = info.instanceId
		end
	end
	ZhengbaManager:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_MERCENARY_TEAM, battleList )

	local assistantList = {}
	for i=1,7 do
		assistantList[i] = 0
	end
	if self.myEmployTeamDetalis.assistant ~= nil then
		for i=1,#self.myEmployTeamDetalis.assistant do
			local info = self.myEmployTeamDetalis.assistant[i]
			assistantList[info.position+1] = info.instanceId
		end
	end
	AssistFightManager:setAssistRoleList( LineUpType.LineUp__MERCENARY_TEAM ,assistantList )

	TFDirector:dispatchGlobalEventWith(EmployManager.MyEmployTeamMessage ,{})
end
--领取奖励或者归队
function EmployManager:merceanryTeamOperationNotify(event)
	hideLoading()
	local data = event.data

	-- if data.operation == 2 then
	-- 	self:clearMyEmployTeamDetalis()
	-- 	TFDirector:dispatchGlobalEventWith(EmployManager.MyEmployTeamMessage ,{})
	-- end
	self.isClear = true
	self:openEmployTeamReward(data.coin)
	-- TFDirector:dispatchGlobalEventWith(EmployManager.ShowEmployReward ,{data.coin})
end

function EmployManager:clearMyEmployTeamDetalis()
	self.myEmployTeamDetalis = {}
	self.myEmployTeamDetalis.battleRole 	= nil
	self.myEmployTeamDetalis.assistant 		= nil
	self.myEmployTeamDetalis.startTime 		= 0
	self.myEmployTeamDetalis.coin 			= 0
	self.myEmployTeamDetalis.employCount 	= 0

	self.isClear = false

	local battleList = {}
	for i=1,9 do
		battleList[i] = 0
	end
	ZhengbaManager:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_MERCENARY_TEAM, battleList )

	local assistantList = {}
	for i=1,7 do
		assistantList[i] = 0
	end
	AssistFightManager:setAssistRoleList( LineUpType.LineUp__MERCENARY_TEAM ,assistantList )
end


function EmployManager:openArmyLayer()
    local layer = require("lua.logic.employ.EmployTeamArmyLayer"):new()
    layer:freshRoleList()
    AlertManager:addLayer(layer)
    AlertManager:show()
end
-- 上阵
function EmployManager:OnBattle(gmid, posIndex)
    local role = CardRoleManager:getRoleByGmid(gmid)
    if role == nil then
        --toastMessage("没有该英雄")
        toastMessage(localizable.EmRoleArmyLayer_nothis_hero)
        return
    end

    local list = ZhengbaManager:getFightList(EnumFightStrategyType.StrategyType_MERCENARY_TEAM)
    print("list = ",list)
    for i=1,9 do
        if list[i] and list[i] == gmid then
            list[i] = 0
        end
    end

    list[posIndex] = gmid
    ZhengbaManager:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_MERCENARY_TEAM, list )
	TFDirector:dispatchGlobalEventWith(EmployManager.UPDATEFORMATIONSUCESS ,{})
end

-- 下阵
function EmployManager:OutBattle(gmid)
    local list = ZhengbaManager:getFightList(EnumFightStrategyType.StrategyType_MERCENARY_TEAM)
    for i=1,10 do
        if list[i] and list[i] == gmid then
            list[i] = 0
        end
    end
    ZhengbaManager:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_MERCENARY_TEAM, list )
	TFDirector:dispatchGlobalEventWith(EmployManager.UPDATEFORMATIONSUCESS ,{})
end

-- 换位置
function EmployManager:ChangePos(oldPos, newPos)
    local list = ZhengbaManager:getFightList(EnumFightStrategyType.StrategyType_MERCENARY_TEAM)
    local temp = list[oldPos] or 0
    list[oldPos] = list[newPos] or 0
    list[newPos] = temp
    ZhengbaManager:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_MERCENARY_TEAM, list )
	TFDirector:dispatchGlobalEventWith(EmployManager.UPDATEFORMATIONSUCESS ,{})
end

function EmployManager:sendTeamInfo()
	local list = ZhengbaManager:getFightList(EnumFightStrategyType.StrategyType_MERCENARY_TEAM)
	local battleList = {}
	for i=1,9 do
		if list[i] and list[i] ~= 0 then
			local battleRole = {
				list[i],
				i
			}
			battleList[#battleList+1] = battleRole
		end
	end

	local assistRoleList = AssistFightManager:getAssistRoleList(EnumFightStrategyType.StrategyType_MERCENARY_TEAM)
	local assistList = {}
	for k,v in pairs(assistRoleList) do
		if v and v ~= 0 then
			local assistRole = {
				v,
				k
			}
			assistList[#assistList+1] = assistRole
		end
	end
	self:dispatchMercenaryTeam(battleList,assistList)
end
function EmployManager:clearTeamInfo()
	local battleList = {}
	for i=1,9 do
		battleList[i] = 0
	end
	ZhengbaManager:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_MERCENARY_TEAM, battleList )

	local assistantList = {}
	for i=1,7 do
		assistantList[i] = 0
	end
	AssistFightManager:setAssistRoleList( LineUpType.LineUp__MERCENARY_TEAM ,assistantList )

end

function EmployManager:getFilterList()
	local filter_list = TFArray:new()
    for v in self.myEmployRoleList:iterator() do
        local role = CardRoleManager:getRoleByGmid(v.roleId)
        if role then
            filter_list:pushBack(role)
        end
    end

	if self.myEmployTeamDetalis.battleRole then
		for i = 1,#self.myEmployTeamDetalis.battleRole do
			local roleId = self.myEmployTeamDetalis.battleRole[i].instanceId
			local role = CardRoleManager:getRoleByGmid(roleId)
			if role then
				filter_list:pushBack(role)
			end
		end
	end
	if self.myEmployTeamDetalis.assistant then
		for i = 1,#self.myEmployTeamDetalis.assistant do
			local roleId = self.myEmployTeamDetalis.assistant[i].instanceId
			local role = CardRoleManager:getRoleByGmid(roleId)
			if role then
				filter_list:pushBack(role)
			end
		end
	end
    return filter_list
end


function EmployManager:getTeamRoleList()
    local roleList = TFArray:new()
    local filter_list = TFArray:new()
    for v in self.myEmployRoleList:iterator() do
        local role = CardRoleManager:getRoleByGmid(v.roleId)
        if role then
            filter_list:pushBack(role)
        end
    end
    for v in CardRoleManager.cardRoleList:iterator() do
        if filter_list:indexOf(v) == -1 then
            roleList:pushBack(v)
        end
    end
    return  roleList
end

function EmployManager:openHireTeamLayer(useType,clickCallBack)

    local layer = require("lua.logic.employ.HireTeamLayer"):new(useType)
    layer:setHireBtnClick( clickCallBack )
    AlertManager:addLayer(layer)
    AlertManager:show()
    self:requestMercenaryTeamListOutline()
end

function EmployManager:openEmployTeamInfo( teamInfo )
    local layer = AlertManager:addLayerByFile("lua.logic.employ.EmployTeamInfo",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_0);
	layer:showInfo( teamInfo )
    AlertManager:show()
end

function EmployManager:EmployTeamSureLayer( teamInfo ,useType,clickCallBack)
   	local layer = require("lua.logic.employ.EmployTeamSureLayer"):new(useType)
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY)
    layer:setHireBtnClick( clickCallBack )
	layer:initTeamInfo( teamInfo )
    AlertManager:show()
end

--查询已雇佣队伍列表
function EmployManager:queryEmployTeamList()
	showLoading()
	TFDirector:send(c2s.QUERY_EMPLOY_TEAM_LIST,{})
end

--修改已雇佣队伍的阵形
function EmployManager:modifyEmployTeamFormation(playerId,useType,formation)
	showLoading()
	local msg = {
	playerId,
	useType,
	formation
	}
	print("msg = ",msg)
	TFDirector:send(c2s.MODIFY_EMPLOY_TEAM_FORMATION,msg)
end

--查询雇佣队伍信息
function EmployManager:employTeamDetailsQuery(useType)
	showLoading()
	TFDirector:send(c2s.EMPLOY_TEAM_DETAILS_QUERY,{0,useType})
end

--雇佣佣兵队伍
function EmployManager:employTeamRequest(playerId,useType)
	showLoading()
	TFDirector:send(c2s.EMPLOY_TEAM_REQUEST,{playerId,useType})
end
--查询已经雇佣的队伍次数信息
function EmployManager:queryEmployTeamCount()
	-- showLoading()
	TFDirector:send(c2s.QUERY_EMPLOY_TEAM_COUNT,{})
end


--雇佣佣兵队伍详细信息
function EmployManager:employTeamSuccess(event)
	hideLoading()
	local data = event.data

	local employTeamCount = { playerId = data.fromId ,todayCount = 1 }
	self.allHireTeamDetalis:pushBack(employTeamCount)

	TFDirector:dispatchGlobalEventWith(self.EmployTeamSuccessNotice ,{data.fromId})
	-- local data = event.data
	-- self.myHireTeamDetalis[data.useType] = {} -- 已雇佣队伍
	-- local x = 1
end

--雇佣佣兵队伍详细信息
function EmployManager:employTeamDetails(event)
	hideLoading()
	local data = event.data
	self.myHireTeamDetalis[data.useType] = data -- 已雇佣队伍
end


--修改已雇佣队伍的阵形成功通知
function EmployManager:modifyEmployTeamFormationSuccess(event)
	hideLoading()
	TFDirector:dispatchGlobalEventWith(self.EmployTeamFormationSuccessNotice ,{})
end

--已雇佣队伍列表
function EmployManager:employTeamListMessage(event)
	hideLoading()
	local data = event.data
	if data.team then
		for i=1,#data.team do
			local teamInfo = data.team[i]
			self.myHireTeamDetalis[teamInfo.useType] = teamInfo 
		end
	end
end

--雇佣队伍信息
function EmployManager:employTeamCount(event)
	hideLoading()
	local data = event.data
	for v in self.allHireTeamDetalis:iterator() do
		if v.playerId == data.playerId then
			v = data
			return
		end
	end
	self.allHireTeamDetalis:pushBack(data)
end

--雇佣队伍信息列表
function EmployManager:employTeamCountList(event)
	hideLoading()
	self.allHireTeamDetalis:clear()
	local data = event.data
	if data.count then
		for i=1,#data.count do
			local countInfo = data.count[i]
			self.allHireTeamDetalis:pushBack(countInfo)
		end
	end
end
function EmployManager:isFirstHire()
	-- return false
	for v in self.allHireRoleDetalis:iterator() do
		if v.todayCount >= 1 then
			return false
		end
	end
	return true
	-- return self.allHireRoleDetalis:length() == 0
end

function EmployManager:isTeamHasFired( playerId )
	for v in self.allHireTeamDetalis:iterator() do
		if v.playerId == playerId then
			return true
		end
	end
	return false
end

function EmployManager:isPlayerCanFiredByLevel( level )
	return MainPlayer:getLevel() + 5 >= level
end




--------------------------单个佣兵雇佣协议


--查询已经雇佣的角色次数信息
function EmployManager:QueryEmployRoleCount()
	showLoading()
	TFDirector:send(c2s.QUERY_EMPLOY_ROLE_COUNT,{})
end
--查询已雇佣角色列表
function EmployManager:QueryEmployRoleList()
	showLoading()
	TFDirector:send(c2s.QUERY_EMPLOY_ROLE_LIST,{})
end
--查询已雇佣角色列表
function EmployManager:QueryEmployRoleByUse(useType)
	showLoading()
	TFDirector:send(c2s.QUERY_EMPLOY_ROLE_BY_USE,{useType})
end


--[[
message EmploySingleRoleDetails
{
	required int64 instanceId = 1;				//角色实例ID
	required int32 useType = 2;				//使用系统
	required int32 roleId = 3;    				// 卡牌的id
	required int32 level = 4;	  				// 等级
	required int32 martialLevel = 5;			// 武学等级
	required int32 starlevel  = 6;	  			// 星级
	required int32 power = 7; 					// 战力
	required int32 hp = 8;						// 剩余HP
	required string spell = 9;					// 技能表达式：id_level|……
	required string attributes = 10; 			// 属性字符串
	required string immune = 11;				// 免疫概率
	required string effectActive = 12;			// 效果影响主动
	required string effectPassive = 13;			// 效果影响被动
	required int32 state = 14;					//状态：1、正常状态；2、死亡；3、释放
}

]]
--角色明细信息
function EmployManager:EmploySingleRoleDetails( event)
	hideLoading()
	local data = event.data
	self.myHireRoleDetalis[data.useType] = data
	self.myHireRoleDetalis[data.useType].gmId = data.instanceId
end

--雇佣角色信息列表
function EmployManager:EmployRoleCountList( event)
	hideLoading()
	self.allHireRoleDetalis:clear()
	local data = event.data
	if data.count then
		for i=1,#data.count do
			local countInfo = data.count[i]
			self.allHireRoleDetalis:pushBack(countInfo)
		end
	end

end
--已雇佣角色列表
function EmployManager:EmploySingleRoleList( event)
	hideLoading()
	local data = event.data
	if data.role then
		for i=1,#data.role do
			local roleInfo = data.role[i]
			self.myHireRoleDetalis[roleInfo.useType] = roleInfo 
		end
	end
end
--某个系统已经使用和正在使用的角色信息
function EmployManager:EmploySingleRoleListByUseType( event)
	hideLoading()
	local data = event.data
	self.myHireRoleDetalis[data.useType] = data.role
	self.myHireRoleDetalis[data.useType].gmId = data.role.instanceId
end

function EmployManager:getMyHireRoleDetailsByType( useType )
	return self.myHireRoleDetalis[useType]
end

--雇佣角色信息
function EmployManager:EmployRoleCount( event)
	hideLoading()
	local data = event.data
	for v in self.allHireRoleDetalis:iterator() do
		if v.playerId == data.playerId then
			v = data
			return
		end
	end
	self.allHireRoleDetalis:pushBack(data)
end

function EmployManager:isEmployRoleByPlayerId( playerId )
	for v in self.allHireRoleDetalis:iterator() do
		if v.playerId == playerId then
			return true
		end
	end
	return false
end

function EmployManager:getEmployRoleByInstanceId( instanceId )
	for v in self.allHireRoleDetalis:iterator() do
		if v.instanceId == instanceId then
			return v
		end
	end
	return nil
end

function EmployManager:getHireRoleList()
	local list = ZhengbaManager:getFightList(EnumFightStrategyType.StrategyType_HIRE_TEAM)
	if next(list) == nil then
		list = clone(AssistFightManager:getStrategyList(EnumFightStrategyType.StrategyType_PVE))
		for i=1,9 do
			if list[i] == nil then
				list[i] = 0
			end
		end
		print("list ====>",list)

		ZhengbaManager:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_HIRE_TEAM, list)

		local assistantList = clone(AssistFightManager:getAssistRoleList( LineUpType.LineUp_Main ))
		AssistFightManager:setAssistRoleList( LineUpType.LineUp_HIRE_TEAM ,assistantList )
	end
	return list
end
function EmployManager:initHireRoleList()

	local list = clone(AssistFightManager:getStrategyList(EnumFightStrategyType.StrategyType_PVE))
	for i=1,9 do
		if list[i] == nil then
			list[i] = 0
		end
	end

	ZhengbaManager:qunHaoDefFormationSet(EnumFightStrategyType.StrategyType_HIRE_TEAM, list)

	local assistantList = clone(AssistFightManager:getAssistRoleList( LineUpType.LineUp_Main ))
	AssistFightManager:setAssistRoleList( LineUpType.LineUp_HIRE_TEAM ,assistantList )

end
--已雇佣角色列表
function EmployManager:getEmploySingleRoleByGmId( instanceId,type)
	local role = self.myHireRoleDetalis[type]
	if role and role.instanceId == instanceId then
		return role
	end
	return nil
end
--已雇佣角色列表
function EmployManager:_getEmploySingleRoleByGmId( instanceId)
	for type,role in pairs(self.myHireRoleDetalis) do
		if role and role.instanceId == instanceId then
			return role,type
		end
	end
	return nil
end


function EmployManager:isExistInAllEmployRole( gmId )
	for v in self.employRoleList:iterator() do
		if v.instanceId == gmId then
			return true
		end
	end
	return false
end
--在所有可雇佣的角色中获得佣兵信息
function EmployManager:getMercenaryInAllEmployRole( gmId )
	if gmId ==nil or gmId == 0 then
		return nil
	end
	for v in self.employRoleList:iterator() do
		if v.instanceId == gmId then
			return v
		end
	end
	return nil
end

function EmployManager:openRoleList(clickCallBack)
	self:requestAllEmployInfo()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.employ.EmployRoleArmyLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
	layer:setAttackBtnClick( clickCallBack )
    AlertManager:show()

end

function EmployManager:openEmployReward(reward_list)
	-- self:requestAllEmployInfo()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.employ.EmployRewardInfo",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
	layer:showInfo( reward_list )
    AlertManager:show()
end

function EmployManager:openEmployTeamReward(reward_list)
	-- self:requestAllEmployInfo()
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.employ.EmployTeamRewardInfo",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
	layer:showInfo( reward_list )
    AlertManager:show()
end

function EmployManager:isRoleCanHire( instanceId , fight_type )
	local role = self:getMercenaryInAllEmployRole( instanceId )
	if self:isPlayerCanFiredByLevel(role.level) == false then
		return false
	end

end

function EmployManager:employSingleRoleRequest( playerId,instanceId,useType )
	showLoading()
	TFDirector:send(c2s.EMPLOY_SINGLE_ROLE_REQUEST,{playerId,instanceId,useType})
end

--雇佣单个角色成功通知
function EmployManager:EmploySingleRoleSuccess( event)
	hideLoading()
	local data = event.data
	local roleEmployInfo = self:findRoleHireInfo(data.playerId,data.instanceId)
	if roleEmployInfo == nil then
		local employInfo = {}
		employInfo.playerId = data.playerId
		employInfo.todayCount = 1
		employInfo.totalCount = 1
		employInfo.createTime = MainPlayer:getNowtime()
		employInfo.lastUpdate = MainPlayer:getNowtime()
		employInfo.instanceId = data.instanceId
		self.allHireRoleDetalis:pushBack(employInfo)
	else
		roleEmployInfo.todayCount = roleEmployInfo.todayCount + 1
		roleEmployInfo.totalCount = roleEmployInfo.totalCount + 1
	end
	TFDirector:dispatchGlobalEventWith(self.EmploySingleRoleSuccessNotice ,{})
end

function EmployManager:findRoleHireInfo( playerId,instanceId )
	for v in self.allHireRoleDetalis:iterator() do
		if v.playerId == playerId and v.instanceId == instanceId then
			return v
		end
	end
	return nil
end




function EmployManager:EmploySingleRoleErrorHandle()
	TFDirector:dispatchGlobalEventWith(self.EmploySingleRoleErrorNotice ,{})
end

--雇佣角色失效通知
function EmployManager:EmploySingleRoleRelease( event)
	hideLoading()
	local data = event.data
	-- print("--------------------------> EmploySingleRoleRelease",data)
  
	local list = ZhengbaManager:getFightList(data.useType)
	for i=1,10 do
		if list[i] and list[i] == data.instanceId then
			list[i] = 0
		end
	end
	self.myHireRoleDetalis[data.useType] = nil
	ZhengbaManager:qunHaoDefFormationSet(data.useType, list )
    -- ZhengbaManager:updateFormation(data.useType,list)
end


function EmployManager:updateEmployFormation(fight_type)
	local list = ZhengbaManager:getFightList(fight_type)
	local battleList = {}
	for i=1,9 do
		if list[i] and list[i] ~= 0 then
			local battleRole = {
				list[i],
				i,
			}	
			battleList[#battleList+1] = battleRole
		end
	end

	local assistRoleList = AssistFightManager:getAssistRoleList(fight_type)
	local assistList = {}
	for k,v in pairs(assistRoleList) do
		if v and v ~= 0 then
			local assistRole = {
				v,
				k
			}
			assistList[#assistList+1] = assistRole
		end
	end
	self:updateEmployFormationSend(fight_type,battleList,assistList)
end
function EmployManager:updateEmployFormationSend( useType , role , assistant )
	TFDirector:send(c2s.UPDATE_EMPLOY_FORMATION,{useType , role , assistant})
end

--[[

//code = 0x5130
//更新单个角色佣兵阵形
message UpdateEmployFormationNotify
{
	required int32 type = 1;					//阵形类型，9、推图阵形
	repeated MercenaryTeamRole role = 2;		//上阵角色信息
	repeated AssistantDetails assistant = 3;	//小伙伴信息
	required int64 employRole = 4;				//佣兵角色实例ID，阵上如果有佣兵角色，则为该佣兵角色的实例ID，否则为0
}
]]

--我的佣兵队伍
function EmployManager:updateEmployFormationNotify(event)
	hideLoading()
	local data = event.data


	local battleList = {}
	for i=1,9 do
		battleList[i] = 0
	end
	if data.role ~= nil then
		for i=1,#data.role do
			local info = data.role[i]
			battleList[info.position+1] = info.instanceId
		end
	end
	ZhengbaManager:qunHaoDefFormationSet(data.type, battleList )

	local assistantList = {}
	for i=1,7 do
		assistantList[i] = 0
	end
	if data.assistant ~= nil then
		for i=1,#data.assistant do
			local info = data.assistant[i]
			assistantList[info.position+1] = info.instanceId
		end
	end
	AssistFightManager:setAssistRoleList( data.type ,assistantList )

	TFDirector:dispatchGlobalEventWith(EmployManager.UpdateEmployFormationMessage ,{})
end

return EmployManager:new()