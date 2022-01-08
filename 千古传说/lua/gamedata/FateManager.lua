local FateManager = class("FateManager")

function FateManager:ctor()

	TFDirector:addProto(s2c.ROLE_FATE_LIST_RESULT,self,self.onReceiveRoleFateListResult)
	TFDirector:addProto(s2c.MATCH_FATE_RESULT,self,self.onReceiveMatchFateResult)
	TFDirector:addProto(s2c.ROLE_FATE_INFO,self,self.onReceiveRoleFateInfo)

	self.roleFateMap = {}
end

function FateManager:restart()
	self.roleFateMap = {}
end

function FateManager:Reset()
	self.roleFateMap = {}
end
--[[
	required int64 instanceId = 1;		//角色实例ID
	required int32 roleFateId = 2;		//角色缘分id
	required int64 endTime = 3;			//使用结束时间
	required bool forever = 4;			//是否永久有效
]]
function FateManager:onReceiveRoleFateListResult( event )
	local data = event.data
	if data.list == nil then
		return
	end
	-- print("FateManager:onReceiveRoleFateListResult",data.list)
	for _,fate in pairs(data.list) do
		-- print("fate == ",fate,MainPlayer:getNowtime())
		self.roleFateMap[fate.instanceId] = self.roleFateMap[fate.instanceId] or {}
		self.roleFateMap[fate.instanceId][fate.roleFateId] = fate
	end
	CardRoleManager:UpdateRoleFate()
end
function FateManager:onReceiveRoleFateInfo( event )
	-- print("FateManager:onReceiveRoleFateInfo")
	local data = event.data
	self.roleFateMap[data.instanceId] = self.roleFateMap[data.instanceId] or {}
	if self.roleFateMap[data.instanceId][data.roleFateId] and self.roleFateMap[data.instanceId][data.roleFateId].endTime and data.endTime > self.roleFateMap[data.instanceId][data.roleFateId].endTime then
		toastMessage(TFLanguageManager:getString(ErrorCodeData.Fate_Prop))
	end
	self.roleFateMap[data.instanceId][data.roleFateId] = data
	local role = CardRoleManager:getRoleById(data.instanceId)
	if role then
		role:updateFate(true)
	end
end
function FateManager:onReceiveMatchFateResult( event )
	hideLoading();
end

--道具使用信息
function FateManager:getFateItemInfo( roleId,roleFateId )
	if self.roleFateMap[roleId] == nil then
		return nil
	end
	return self.roleFateMap[roleId][roleFateId]
end

function FateManager:removeFateItemInfo( roleId,roleFateId )
	if self.roleFateMap[roleId] == nil then
		return
	end
	self.roleFateMap[roleId][roleFateId] = nil
end

function FateManager:activateFateByItem( instanceId,roleFateId,itemId ,num)
	local item_num = BagManager:getItemNumById( itemId )
	if item_num == 0 then
		--toastMessage("道具不足")
		toastMessage(localizable.common_prop_not_enough)
		return
	end
	showLoading()
	TFDirector:send(c2s.REQUEST_MATCH_FATE,{instanceId,roleFateId,itemId,num})
end




-- 获取单个角色缘分
function FateManager:getRoleFate(roleid, clearAllFate)
	local fateList = {}
	local fateMap = MEMapArray:new()
	-- local fateMap = TFArray:new()

	local fateTemplete = RoleFateData:getRoleFateById(roleid)
	local fateArray = clone(fateTemplete)
	if fateArray == nil then
		print("此人没有缘分  id == "..roleid)
		return
	end

	for fate in fateArray:iterator() do
		-- print("fate = ", fate)
		local targetList = fate:gettarget()

		if #targetList == 0 then
			-- status = false
		else
			for _,target in pairs(targetList) do
				--1、角色；2、装备；3、秘籍；4、道具
				if target.fateType == 1 then
					fateList[fate.id] = fate

					if clearAllFate then
					-- 表示缘分是否匹配
						fate.match  = false
					end

					fate.fateid = fate.id
					-- print('--fate.id = ', fate.id)
					if fateMap:objectByID(fate.id) == nil then
						fateMap:pushbyid(fate.id, fate)
					end
					-- fateMap:pushBack(fate)
				end
			end
		end
	end

	-- print("fateMap = ", fateMap)
	return fateMap
end


-- 获取缘分map 是否清楚缘分状态
function FateManager:getRoleFateWihtRoleList(rolelist, clearAllFate,fight_type)
	if clearAllFate == nil then
		clearAllFate = true
	end

	-- local roleFateMap = MEMapArray:new()
	local roleFateMap = TFArray:new()
	for i=1,9 do
		if rolelist[i] and rolelist[i] ~= 0 then
			-- print("rolelist["..i.."]=",rolelist[i])
			local gmId = rolelist[i]
			local role = CardRoleManager:getRoleByGmid(gmId)
			local role_id = 0
			if role  then
				role_id = role.id
			else
				local mercenary = EmployManager:getMercenaryInAllEmployRole( rolelist[i] )
				if mercenary then
					role_id = mercenary.roleId
				else
					mercenary = EmployManager:getEmploySingleRoleByGmId( rolelist[i] ,fight_type)
					if mercenary then
						role_id = mercenary.roleId
					end
				end
            end

			-- if role == nil then
			-- 	print("gmid = ", gmId)
			-- 	print("i = ", i)
			-- end

			local list = self:getRoleFate(role_id, clearAllFate)

			-- print("role_id = ", role_id)

			list.roleid = role_id
			-- if list:length() > 0 then
				-- roleFateMap:pushbyid(role.id, list)
				roleFateMap:pushBack(list)
			-- end
			-- print("list = ",list)
		end
	end
	-- print('roleFateMap = ', roleFateMap)

	-- print("roleFateMap length = ", roleFateMap:length())
	-- for map in roleFateMap:iterator() do
	-- 	-- print("map = ", map)
	-- 	print("fate length = ", map:length())
	-- end

	return roleFateMap
end


-- 
function FateManager:getTargetStatus(target, roleList)
	local fateid = target.fateId

	-- local role = CardRoleManager:getRoleByGmid(self.strategylist[i])
	for k,v in pairs(roleList) do
		if fateid == v then
			return true
		end
	end

	return false
end

-- 通过小伙伴列表 和 缘分map 里面的缘分（全部归零后重新计算）
function FateManager:updateFate(roleFateMap, roleList)
	if showMessage == nil then
		showMessage = false
	end

	-- print("roleFateMap length = ", roleFateMap:length())
	for map in roleFateMap:iterator() do
		local fateArray = map

		-- print("roleid = ", map.roleid)
		for fate in fateArray:iterator() do
			fate.match = false
			local status = true
			local targetList = fate:gettarget()
			if #targetList == 0 then
				status = false
			end
			print("----------------->fate = ",fate)
			local role = CardRoleManager:getRoleById(fateArray.roleid)
			local hasItemFate = false  --是否使用道具产生的缘分
			if role then
				local fateItemInfo = self:getFateItemInfo(role.id,fate.fateid)
				if fateItemInfo and (fateItemInfo.forever or fateItemInfo.endTime > MainPlayer:getNowtime()) then
					hasItemFate = true
					fate.match = true
				end
			end
			if hasItemFate == false then
				for _,target in pairs(targetList) do
					if self:getTargetStatus(target,roleList) == true then
					else
						status = false
					end
				end
				if status == true then
					fate.match = true
					print("updateFate 开启的缘分 fate.title = ", fate.title)
					if showMessage then
						fateMessage(fate.title,nil,nil,nil,true,"lua.uiconfig_mango_new.common.FateMessage")
					end

					local role  = CardRoleManager:getRoleById(fateArray.roleid)
					if role then
						role:updateFate(false)
					end
				end
			end
		end
	end
end

-- 当小伙伴列表有更新的时候 更新缘分map
function FateManager:updateFateWithChange(roleFateMap, roleList)
	-- print("updateFateWithChange roleList = ", roleList)
	print("---------------FateManager:updateFateWithChange -------------------- ")
	local fateList = {}
	local fateNum  = 0

	for map in roleFateMap:iterator() do
		local fateArray = map

		-- print("roleid = ", map.roleid)
		for fate in fateArray:iterator() do
			local status = true
			local targetList = fate:gettarget()
			if #targetList == 0 then
				status 		= false
				fate.match  = false
			end
			local role = CardRoleManager:getRoleById(fateArray.roleid)
			local hasItemFate = false
			if role then
				local fateItemInfo = self:getFateItemInfo(role.id,fate.fateid)
				if fateItemInfo and (fateItemInfo.forever or fateItemInfo.endTime > MainPlayer:getNowtime()) then
					hasItemFate = true
					fate.match = true
				end
			end
			if hasItemFate == false then
				for _,target in pairs(targetList) do
					if self:getTargetStatus(target,roleList) == true then
					else
						status = false
					end
				end

				if status == true then
					if fate.match == false then
						print("开启的缘分 fate.title = ", fate.title)
						-- fateMessage(fate.title,nil,nil,nil,true,"lua.uiconfig_mango_new.common.FateMessage")
						fateNum 				= fateNum + 1
						fateList[fateNum]		= fate.title
					end
				end
				-- print("fateid = ", fate.fateid)
				-- print("status = ", status)
				-- print("fate.match = ", fate.match)
				if status ~= fate.match then
					local role  = CardRoleManager:getRoleById(fateArray.roleid)
					if role then
						role:updateFate(false)
					end

					if status == false then
						print("缘分关闭 :", fate.title)
					end
				end
				fate.match = status
			end
		end
	end

	if fateNum > 0 then
		fateMessageDelay(fateList)
	end
	print("fateList = ", fateList)
	print("---------------FateManager:updateFateWithChange end -------------------- ")
end

-- 将缘分map里面的内容 组合成一个数组，用于显示界面角色和缘分的列表
function FateManager:getFateList(roleFateMap)
	local fateList = TFArray:new()

	for map in roleFateMap:iterator() do
		local fateArray = map
		-- print("map.roleid = ", map.roleid)
		local fateRoleNode = {}
		fateRoleNode.type = 1 --1为角色 2为缘分
		fateRoleNode.id   = map.roleid --角色id

		fateList:push(fateRoleNode)
		for fate in fateArray:iterator() do
			-- print("fate.fateid = ", fate.fateid)
			local fateNode = {}
			fateNode.type = 2 			 --1为角色 2为缘分
			fateNode.id   = fate.fateid  --缘分id
			fateNode.match= fate.match

			fateList:push(fateNode)
		end
	end

	return fateList
end

-- 将阵型 和 小伙伴 融合到一起 返回一个角色id的列表
function FateManager:LinkStrategyAndAssit(strategylist, assistlist,fight_type)
	local rolelist = {}

	for i=1,9 do
		if strategylist[i] and strategylist[i] ~= 0 then
			rolelist[i] = strategylist[i]
		end
	end

	for i=1,10 do
		if assistlist[i] and assistlist[i] ~= 0 then
			local index = i + 10
			rolelist[index] = assistlist[i]
		end
	end




	for i=1,20 do
		if rolelist[i] then
			local role = CardRoleManager:getRoleByGmid(rolelist[i])
			if role then
				rolelist[i] = role.id
			else
				local mercenary = EmployManager:getMercenaryInAllEmployRole( rolelist[i] )
				if mercenary then
					rolelist[i] = mercenary.roleId
				else
					mercenary = EmployManager:getEmploySingleRoleByGmId( rolelist[i] ,fight_type)
					if mercenary then
						rolelist[i] = mercenary.roleId
					end
				end
			end
		end
	end

	for i=1,#AssistFightManager.CloseFriendType do
		if fight_type == AssistFightManager.CloseFriendType[i] then
			return rolelist
		end
	end
	
	--添加好友助战
	local info = AssistFightManager:getFriendIconInfo()
    local cardRole = RoleData:objectByID(info.friendRoleId)
    if cardRole then
		rolelist[AssistFightManager.friendAssistIndex] = cardRole.id
	else
		rolelist[AssistFightManager.friendAssistIndex] = 0
	end
	
	return rolelist
end

-- 将阵型 和 小伙伴 融合到一起 返回一个角色Gmid的列表
function FateManager:LinkStrategyAndAssitGmid(strategylist, assistlist)
	local rolelist = {}

	for i=1,9 do
		if strategylist[i] and strategylist[i] ~= 0 then
			rolelist[i] = strategylist[i]
		end
	end

	for i=1,10 do
		if assistlist[i] and assistlist[i] ~= 0 then
			local index = i + 10
			rolelist[index] = assistlist[i]
		end
	end

	return rolelist
end


-- 从缘分列表中 标记角色列表 可以配出缘分的 将他们标记出来
function FateManager:updateRoleListFate(roleFateMap, cardRoleList, strategylist)
	local strategyRoleList = {}

	function getTargetCardRole(target, roleList)
		local fateid = target.fateId

		-- for k,v in pairs(roleList) do
		for role in roleList:iterator() do
			local roleInBag = CardRoleManager:getRoleByGmid(role.gmId)
			if roleInBag.id == fateid then
				return role
			end
		end

		return nil
	end

	function findRoleInStrageList(target, strategyRoleList)
		local fateid = target.fateId

		-- for k,v in pairs(roleList) do
		for i=1,9 do
			if strategyRoleList[i] and strategyRoleList[i] > 0 then
				if strategyRoleList[i] == fateid then
					return true
				end
			end
		end

		return false
	end
	

	for i=1,9 do
		if strategylist[i] then
			local role = CardRoleManager:getRoleByGmid(strategylist[i])
			if role then
				strategyRoleList[i] = role.id
			end
		end
	end

	for map in roleFateMap:iterator() do
		local fateArray = map

		-- print("roleid = ", map.roleid)
		for fate in fateArray:iterator() do
			local status = true
			local targetList = fate:gettarget()
			if #targetList == 0 then
				status = false
			end
			-- print("fate  = ",fate)
			print("fate  = ",fate)
			local role = CardRoleManager:getRoleById(fateArray.roleid)
			local hasItemFate = false
			if role then
				local fateItemInfo = self:getFateItemInfo(role.id,fate.fateid)
				if fateItemInfo and (fateItemInfo.forever or fateItemInfo.endTime > MainPlayer:getNowtime()) then
					hasItemFate = true
				end
			end
			if hasItemFate == false then
				local fateRoleList = {}
				local count = 0
				for _,target in pairs(targetList) do
					-- 现在阵型上面找 
					local bCanFindInStrageList = true
					bCanFindInStrageList = findRoleInStrageList(target, strategyRoleList)
					if bCanFindInStrageList == false then
						local fateRole = getTargetCardRole(target,cardRoleList)
						if fateRole then
							count = count + 1
							fateRoleList[count] = fateRole
						else
							status = false
						end
					end
				end

				if status == true then
					for i=1,count do
						fateRoleList[i].fateid = map.roleid
					end
				end
			end
		end
	end


	-- 排序
	local function cmpFun(fate1, fate2)
		local fateid1 = fate1.fateid or 0
		local fateid2 = fate2.fateid or 0
		fateid1 = fateid1 == 0 and 10000 or fateid1
		fateid2 = fateid2 == 0 and 10000 or fateid2
		-- if fate1.fateid == 0 and fate2.fateid == 0 then
		-- 	-- 缘分的人物id一样是 配缘分的人物按照品质再排列
		-- 	if fate1.quality < fate2.quality then
		-- 		return false
		-- 	end
		-- 	return true
		-- end

		-- if fate1.fateid == 0 then
		-- 	return false
		-- end
		

		if fateid1 < fateid2 then
		    return true
		elseif fateid1 == fateid2 then
			-- 缘分的人物id一样是 配缘分的人物按照品质再排列
			if fate1.quality < fate2.quality then
				return false
			end
			return true
		else
			return false
		end
	end
	cardRoleList:sort(cmpFun)
end


-- 获取缘分map 是否清楚缘分状态
function FateManager:getRoleFateWihtRoleListWithRoleid(rolelist, clearAllFate,fight_type)
	if clearAllFate == nil then
		clearAllFate = true
	end

	-- local roleFateMap = MEMapArray:new()
	local roleFateMap = TFArray:new()
	for i=1,9 do
		if rolelist[i] and rolelist[i] ~= 0 then
			-- print("rolelist["..i.."]=",rolelist[i])
			local role_id = rolelist[i]

			-- if role == nil then
			-- 	print("gmid = ", gmId)
			-- 	print("i = ", i)
			-- end

			local list = self:getRoleFate(role_id, clearAllFate)

			-- print("role_id = ", role_id)

			list.roleid = role_id
			-- if list:length() > 0 then
				-- roleFateMap:pushbyid(role.id, list)
				roleFateMap:pushBack(list)
			-- end
			-- print("list = ",list)
		end
	end
	-- print('roleFateMap = ', roleFateMap)

	-- print("roleFateMap length = ", roleFateMap:length())
	-- for map in roleFateMap:iterator() do
	-- 	-- print("map = ", map)
	-- 	print("fate length = ", map:length())
	-- end
	-- print('roleFateMaproleFateMap = ',roleFateMap)

	return roleFateMap
end

-- 查找角色表里的role 是否有缘分  true 有缘分
function FateManager:checkRoleFateWithList(roleFateMap, roleList, roleid)

	-- print("roleFateMap length = ", roleFateMap:length())o
	for map in roleFateMap:iterator() do
		local fateArray = map

		-- print("roleid = ", map.roleid)
		for fate in fateArray:iterator() do
			local targetList = fate:gettarget()
			-- print('targetList1111111111 = ',targetList)
			local targetListCount = #targetList
			if targetListCount == 1 then
				if targetList[1].fateId == roleid then
					return true
				end
			elseif targetListCount > 1 then
				local needContinue = false
				local needRole = {}
				for _,target in pairs(targetList) do
					if target.fateId == roleid then
						needContinue = true
					else
						needRole[#needRole + 1] = target.fateId
					end
				end
				if needContinue then
					local findCount = 0
					for _,v1 in pairs(needRole) do
						for _,v2 in pairs(roleList) do
							if v1 == v2 then
								findCount = findCount + 1
								break
							end
						end
					end

					if findCount == #needRole then
						return true
					end
				end
			end
		end
	end

	return false
end

function FateManager:checkRoleFate(strategylist, assistlist, roleid)
	if roleid == nil then
		return false
	end

	-- 传入阵位信息
	local roleFateMap = self:getRoleFateWihtRoleListWithRoleid(strategylist, true, nil)
	-- print('roleFateMap = ',roleFateMap)

	-- 传入阵上所有角色的缘分 和 助战列表（需要将当期阵位和助战列表融到一起）
	-- [1] = xxx ...... [11]...

	local rolelist = {}

	for i=1,9 do
		if strategylist[i] and strategylist[i] ~= 0 then
			rolelist[i] = strategylist[i]
		end
	end

	for i=1,10 do
		if assistlist[i] and assistlist[i] ~= 0 then
			local index = i + 10
			rolelist[index] = assistlist[i]
		end
	end

	-- rolelist[AssistFightManager.friendAssistIndex] = roleid

	return self:checkRoleFateWithList(roleFateMap, rolelist, roleid)
end

return FateManager:new()