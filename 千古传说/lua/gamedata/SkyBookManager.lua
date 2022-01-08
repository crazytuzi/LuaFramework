--[[
******游戏数据装备管理类*******

	-- by Stephen.tao
	-- 2013/11/27
]]

local SkyBookManager = class("SkyBookManager",TFArray)

local CardSkyBook = require('lua.gamedata.base.CardSkyBook')

local SweepData  = require('lua.table.t_s_sweep')
local ResetData  = require('lua.table.t_s_reset_consume')

SkyBookManager.EQUIP_OPERATION = "SkyBookManager.EQUIP_OPERATION"
SkyBookManager.UNEQUIP_OPERATION = "SkyBookManager.UNEQUIP_OPERATION"
SkyBookManager.DEL_EQUIP = "SkyBookManager.DEL_EQUIP"
SkyBookManager.ESSENTIAL_EXPLODE_RESULT = "SkyBookManager.ESSENTIAL_EXPLODE_RESULT"
SkyBookManager.ESSENTIAL_UN_MOSAIC_RESULT = "SkyBookManager.ESSENTIAL_UN_MOSAIC_RESULT"
SkyBookManager.ESSENTIAL_MOSAIC_RESULT = "SkyBookManager.ESSENTIAL_MOSAIC_RESULT"
SkyBookManager.BIBLE_RESET_RESULT = "SkyBookManager.BIBLE_RESET_RESULT"
SkyBookManager.BIBLE_BREACH_RESULT = "SkyBookManager.BIBLE_BREACH_RESULT"
SkyBookManager.BIBLE_LEVEL_UP_RESULT = "SkyBookManager.BIBLE_LEVEL_UP_RESULT"
SkyBookManager.BIBLE_ADD_RESULT = "SkyBookManager.BIBLE_ADD_RESULT"

SkyBookManager.SortSkyBookType = 1
SkyBookManager.SortSkyBookQuality = 2

--天书最高星级
SkyBookManager.kMaxStarLevel = 5

--天书附加属性的条目上限
SkyBookManager.kMaxAttributeSize = 9
--精要type
SkyBookManager.TYPE_ESSENTIAL = EnumGameItemType.SBStone

--天书最大重数
--SkyBookManager.kMaxLevel = 10


function SkyBookManager:ctor()
	self.super.ctor(self)
	self.map = {}
	self.sortType = SkyBookManager.SortEquipmentType

	TFDirector:addProto(s2c.EQUIP_BIBLE_RESULT, self, self.onReceiveBibleEquip)
	TFDirector:addProto(s2c.UNEQUIP_BIBLE_RESULT, self, self.onReceiveBibleUnEquip)
	TFDirector:addProto(s2c.ESSENTIAL_MOSAIC_RESULT, self, self.onEssentialMosaic)
	TFDirector:addProto(s2c.ESSENTIAL_UN_MOSAIC_RESULT, self, self.onEssentialUnMosaic)
	TFDirector:addProto(s2c.BIBLE_BREACH_RESULT, self, self.onBibleBreach)
	
	TFDirector:addProto(s2c.ESSENTIAL_EXPLODE_RESULT, self, self.onEssentialExplode)
	TFDirector:addProto(s2c.BIBLE_RESET_RESULT, self, self.onBibleReset)
	TFDirector:addProto(s2c.BIBLE_LEVEL_UP_RESULT, self, self.onBibleLevelUp)
	TFDirector:addProto(s2c.BIBLE_ADD_RESULT, self, self.onBibleAdd)
end

--天书装备s2c
--[[
	[1] = {--EquipBibleResult
		[1] = 'int32':result	[是否成功]
		[2] = 'int64':roleId	[角色实例id]
		[3] = 'int64':bible	[装备到身上的天书userid]
		[4] = 'int64':drop	[如果有替换下来的天书则发送卸下的天书userid]
	}
--]]
function SkyBookManager:onReceiveBibleEquip(event)
	local data = event.data
	print("*********SkyBookManager:onReceiveBibleEquip********** result = ", data.result)
	print("*********SkyBookManager:onReceiveBibleEquip********** roleId = ", data.roleId)
	print("*********SkyBookManager:onReceiveBibleEquip********** bible = ", data.bible)
	print("*********SkyBookManager:onReceiveBibleEquip********** drop = ", data.drop)

	hideLoading()

	if data.result ~= 0 then
		--toastMessage("天书装配失败")
		toastMessage(localizable.SkyBookManager_text1)
		return
	end

	local role = CardRoleManager:getRoleByGmid(data.roleId)
	local oldequip = nil
	if data.drop then
		oldequip = self:getItemByInstanceId(data.drop)
	end
	if role == nil then 
		print("role == nil")
		return
	end

	local equip = self:getItemByInstanceId(data.bible)
	if oldequip then
		role:delSkyBook(oldequip)
	end
	role:setSkyBook(equip)
	role:updateSkyBookAttr()
	TFDirector:dispatchGlobalEventWith(SkyBookManager.EQUIP_OPERATION, {gmId = role.gmId, equip = equip}) 
	TFDirector:dispatchGlobalEventWith("SkyBookChangeEnd", {})
end

--天书卸下s2c
--[[
	[1] = {--UnequipBibleResult
		[1] = 'int32':result	[是否成功]
		[2] = 'int64':drop	[卸除的天书]
	}
--]]
function SkyBookManager:onReceiveBibleUnEquip(event)
	local data = event.data
	print("*********SkyBookManager:onReceiveBibleUnEquip********** result = ", data.result)
	print("*********SkyBookManager:onReceiveBibleUnEquip********** drop = ", data.drop)
	hideLoading()

	if data.result ~= 0 then
		--toastMessage("天书卸下失败")
		toastMessage(localizable.SkyBookManager_text2)
		return
	end

	local role = CardRoleManager:getRoleByBibleInstanceId(data.drop)
	local equip = self:getItemByInstanceId(data.drop)
	if role == nil or equip == nil then 
		print("role == nil or equip == nil")
		return
	end
	role:delSkyBook(equip)
	role:updateSkyBookAttr()
	TFDirector:dispatchGlobalEventWith(SkyBookManager.UNEQUIP_OPERATION, {gmId = role.gmId, equip = equip})
	TFDirector:dispatchGlobalEventWith("SkyBookChangeEnd", {}) 
end

--镶嵌精要s2c
--[[
	[1] = {--EssentialMosaicResult
		[1] = 'int32':result	[是否成功]
		[2] = 'int64':roleId	[角色实例id]
		[3] = 'int64':essential	[镶嵌的天书id]
		[4] = 'int32':itemId	[宝石id]
		[5] = 'int32':pos	[镶嵌的位置]
	}
--]]
function SkyBookManager:onEssentialMosaic(event)
	hideLoading()
	local data = event.data

	print("*********SkyBookManager:onEssentialMosaic********** result = ", data.result)
	print("*********SkyBookManager:onEssentialMosaic********** roleId = ", data.roleId)
	print("*********SkyBookManager:onEssentialMosaic********** essential = ", data.essential)
	print("*********SkyBookManager:onEssentialMosaic********** itemId = ", data.itemId)
	print("*********SkyBookManager:onEssentialMosaic********** pos = ", data.pos)

	if data.result == 0 and data.essential and data.itemId and data.pos then
		local bible = self:getItemByInstanceId(data.essential)
		if not bible then
			print("没有找到该天书 == " .. data.essential)
			return
		end

		bible:setStonePos(data.pos, data.itemId)
		bible:updatePower()
		TFDirector:dispatchGlobalEventWith(SkyBookManager.ESSENTIAL_MOSAIC_RESULT, {pos = data.pos})
	else
		--toastMessage("精要镶嵌失败")
		toastMessage(localizable.SkyBookManager_text3)
	end
end


--卸下精要s2c
--[[
//code = 0x6005
//卸下精要
message EssentialUnMosaicResult{
	required int32 result = 1; //是否成功
	optional int64 bible = 2; 	//成功则字段有效 卸下的天书实例id
	optional int32 pos = 3;  //卸下的天书所在位置
}
--]]
function SkyBookManager:onEssentialUnMosaic(event)
	hideLoading()
	local data = event.data
	print("*********SkyBookManager:onEssentialUnMosaic********** result = ", data.result)
	print("*********SkyBookManager:onEssentialUnMosaic********** bible = ", data.bible)
	print("*********SkyBookManager:onEssentialUnMosaic********** pos = ", data.pos)

	if data.result == 0 and data.bible and data.pos then
		local equip = self:getItemByInstanceId(data.bible)
		if not equip then
			print("没有找到该天书 == " .. data.bible)
			return
		end
		--local stoneId = equip:getStonePos(data.pos)
		equip:setStonePos(data.pos, nil)
		equip:updatePower()
		TFDirector:dispatchGlobalEventWith(SkyBookManager.ESSENTIAL_UN_MOSAIC_RESULT, {})
	else
		--toastMessage("精要卸下失败")
		toastMessage(localizable.SkyBookManager_text2)
	end
end

--天书突破s2c
--[[
	//code = 0x6006
	//天书突破
	message BibleBreachResult{
		required int32 result = 1; //是否成功
		optional int64 instanceId = 2;			//成功则字段有效 天书实例ID
	}
--]]
function SkyBookManager:onBibleBreach(event)
	hideLoading()
	local data = event.data

	print("*********SkyBookManager:onBibleBreach********** result = ", data.result)
	print("*********SkyBookManager:onBibleBreach********** instanceId = ", data.instanceId)

	if data.result == 0 then
		local bible = self:getItemByInstanceId(data.instanceId)
		local curTupoLevel = bible:getTupoLevel()
		if curTupoLevel < self.kMaxStarLevel then
			local level = bible.level
			local tupoLevel = curTupoLevel + 1
			bible:setTupoLevel(tupoLevel)
			bible:updatePower()				
		end
		--[[
		self.timerID = TFDirector:addTimer(500, 1, nil,
		function() 
			print("+++++dispatching bible breach result event+++++")
			TFDirector:removeTimer(self.timerID)
			self.timerID = nil
			TFDirector:dispatchGlobalEventWith(SkyBookManager.BIBLE_BREACH_RESULT, {})
		end)
		]]
		TFDirector:dispatchGlobalEventWith(SkyBookManager.BIBLE_BREACH_RESULT, {})	
	else
		--toastMessage("天书突破失败")
		toastMessage(localizable.SkyBookManager_text4)
	end
	--TFDirector:dispatchGlobalEventWith(SkyBookManager.BIBLE_BREACH_RESULT, {})
end

--精要分解s2c
--[[
	[1] = {--EssentialExplodeResult
		[1] = 'int32':result	[是否成功]
		[2] = 'int32':itemId	[分解userid]
		[3] = 'int32':number	[数量]
	}
--]]
function SkyBookManager:onEssentialExplode(event)
	hideLoading()
	local data = event.data

	print("*********SkyBookManager:onEssentialExplode********** result = ", data.result)
	--opti逗号隔开
	print("*********SkyBookManager:onEssentialExplode********** itemId = ", data.itemId)

	if data.result == 0 then
		TFDirector:dispatchGlobalEventWith(SkyBookManager.ESSENTIAL_EXPLODE_RESULT, data.itemId)
	else
		--toastMessage("精要分解失败")
		toastMessage(localizable.SkyBookManager_text5)
	end
end

--重置天书s2c
--[[
	[1] = {--BibleResetResult
		[1] = 'int32':result	[是否成功]
		[2] = 'int64':bible	[成功时有效 天书id]
	}
--]]
function SkyBookManager:onBibleReset(event)
	hideLoading()
	local data = event.data

	print("*********SkyBookManager:onBibleReset********** result = ", data.result)
	print("*********SkyBookManager:onBibleReset********** bible = ", data.bible)

	--local num = BagManager:getItemNumById(30094)
    --print("=========== after chongzhi, num = ", num)

	if data.result == 0 then
		local bible = self:getItemByInstanceId(data.bible)

		local oldBible = clone(bible)

		bible:setLevel(1)
		bible:resetStone()
		bible:updatePower()

		--test
		self:showChongzhiRewardLayer(oldBible, data.bible)

		TFDirector:dispatchGlobalEventWith(SkyBookManager.BIBLE_RESET_RESULT, {})
	else
		--toastMessage("天书重置失败")
		toastMessage(localizable.SkyBookManager_text6)
	end
end

--[[
	[1] = {--BibleLevelUpResult
		[1] = 'int32':result	[是否成功]
		[2] = 'int64':instanceId	[唯一id]
		[3] = 'int32':level	[当前重数]
	}
]]
function SkyBookManager:onBibleLevelUp(event)
	hideLoading()
	local data = event.data

	print("*********SkyBookManager:onBibleLevelUp********** result = ", data.result)
	print("*********SkyBookManager:onBibleLevelUp********** instanceId = ", data.instanceId)
	print("*********SkyBookManager:onBibleLevelUp********** level = ", data.level)

	if data.result == 0 then
		local bible = self:getItemByInstanceId(data.instanceId)
		bible:setLevel(data.level)
		bible:resetStone()
		bible:updatePower()

		TFDirector:dispatchGlobalEventWith(SkyBookManager.BIBLE_LEVEL_UP_RESULT, {})
	else
		--toastMessage("天书升重失败")
		toastMessage(localizable.SkyBookManager_text7)
	end
end

--[[
	[1] = {--BibleAddResult
		[1] = 'int32':result	[是否成功]
		[2] = 'int64':instanceId	[唯一id]
		[3] = 'int32':id	[模板id]
	}
--]]
function SkyBookManager:onBibleAdd(event)
	local data = event.data

	print("*********SkyBookManager:onBibleAdd********** result = ", data.result)
	print("*********SkyBookManager:onBibleAdd********** instanceId = ", data.instanceId)
	print("*********SkyBookManager:onBibleAdd********** id = ", data.id)

	data.level = 1
	data.breachLevel = 0

	BagManager:AddSkyBookByNet(data)
	TFDirector:dispatchGlobalEventWith(SkyBookManager.BIBLE_ADD_RESULT, data)
end

--天书装备c2s
function SkyBookManager:requestBibleEquip(data)
	showLoading()
	
	local Msg = 
	{
		data.roleId,
		data.bibleId,
		data.itemId
	}
	print(Msg[1], Msg[2], Msg[3])
	TFDirector:send(c2s.EQUIP_BILBLE_REQUEST, Msg)
end

--天书卸下c2s
function SkyBookManager:requestBibleUnEquip(data)
	showLoading()
	local Msg = 
	{
		data.roleId,
		data.bibleId
	}
	print(Msg[1], Msg[2])
	TFDirector:send(c2s.UNEQUIP_BIBLE_REQUEST, Msg)
end

--精要分解c2s
function SkyBookManager:requestEssentialExplode(data)
	showLoading()
	local Msg = {}
	Msg[1] = {}
	for i = 1, #data do
		table.insert(Msg[1], {data[i].id, data[i].num})
	end
	TFDirector:send(c2s.ESSENTIAL_EXPLODE_REQUEST, Msg)
end

--精要镶嵌c2s
--[[
//code = 0x6004
//镶嵌精要
message EssentialMosaicRequest{
	required int64 bible = 1; 	//镶嵌的天书id
	required int32 essential = 2; //精要id
	required int32 pos    = 3; //镶嵌的位置
}
]]
function SkyBookManager:requestEssentialMosaic(data)
	showLoading()
	if not data then
		return
	end
	print("SkyBookManager:requestEssentialMosaic : ", data[1], data[2], data[3])
	TFDirector:send(c2s.ESSENTIAL_MOSAIC_REQUEST, data)
end

--精要卸下c2s
--[[
//code = 0x6005
//卸下精要
message EssentialUnMosaicRequest{
	required int64 bible = 1; 	//精要的天书id
	required int32 pos = 2; 	//卸下的精要的位置
}
]]
function SkyBookManager:requestEssentialUnMosaic(data)
	showLoading()
	if not data then
		return
	end
	print("SkyBookManager:requestEssentialUnMosaic : ", data[1], data[2])
	TFDirector:send(c2s.ESSENTIAL_UN_MOSAIC_REQUEST, data)
end

--精要合成c2s
function SkyBookManager:requestEssentialMerge(data)
	if not data then
		return
	end	
	print("SkyBookManager:requestEssentialMerge, essentialId = ", data)
	BagManager:requestEquipMerge(data)
end

--升重c2s
--[[
	//code = 0x6006
	//天书突破请求
	message RequestBibleBreachRequest{
		required int64 instanceId = 1;			//天书实例ID
	}
]]
function SkyBookManager:requestBibleBreach(data)
	print("========", data)
	if not data then
		return
	end
	showLoading()

	TFDirector:send(c2s.REQUEST_BIBLE_BREACH_REQUEST, {data})
end

--重置c2s
--[[
	//code = 0x6008
	//重置天书
	message BibleResetRequest{
		required int64 instanceId = 1; //id
	}
]]
function SkyBookManager:requestBibleReset(data)
	if not data then
		return
	end
	showLoading()

	TFDirector:send(c2s.BIBLE_RESET_REQUEST, {data})
end

function SkyBookManager:requestBibleLevelUp(data)
	if not data then
		return
	end
	showLoading()

	TFDirector:send(c2s.BIBLE_LEVEL_UP_REQUEST, {data})
end

function SkyBookManager:testUnEquip()
	local roleId = 787094
	local instanceId = 1
	local data = 
	{
		roleId = roleId,
		bibleId = instanceId
	}
	self:requestBibleUnEquip(data)
end

function SkyBookManager:testEquip()
	showLoading()
	local Msg = 
	{
		787094,
		1,
		50001
	}
	print("+++send equip")
	TFDirector:send(c2s.EQUIP_BILBLE_REQUEST, Msg)
end

function SkyBookManager:testTupo()
	showLoading()
	local Msg = 
	{
		1
	}
	TFDirector:send(c2s.REQUEST_BIBLE_BREACH_REQUEST, Msg)
end

function SkyBookManager:testMosaic()
	showLoading()
	local Msg = 
	{
		1,
		51001,
		1
	}
	TFDirector:send(c2s.ESSENTIAL_MOSAIC_REQUEST, Msg)
end

function SkyBookManager:testUnMosaic()
	showLoading()
	local Msg = 
	{
		1,
		1
	}
	TFDirector:send(c2s.ESSENTIAL_UN_MOSAIC_REQUEST, Msg)
end

function SkyBookManager:testExplode()
	showLoading()

	local Msg =
	{
		{
			{51001, 1},
			{51006, 1}
		}
	}

	TFDirector:send(c2s.ESSENTIAL_EXPLODE_REQUEST, Msg)
end

function SkyBookManager:testReset()
	showLoading()
	local Msg = 
	{
		1
	}
	TFDirector:send(c2s.BIBLE_RESET_REQUEST, Msg)
end

function SkyBookManager:restart()
	self.map = {}
	self.sortType = SkyBookManager.SortEquipmentType
	for v in self:iterator() do
		v:dispose()
	end
	self:clear()
end
--[[--
	新增天书
	@param skyBook: 天书
	@return 是否成功
]]	
function SkyBookManager:AddSkyBook(skyBook)
	local itemType = skyBook:getConfigType()

	-- changed by wuqi
	if itemType == nil  or itemType ~= EnumGameItemType.SkyBook then
	--if itemType == nil  or itemType ~= EnumGameObjectType.SkyBook then
		print(skyBook.name .. "skyBook add fail ")
		return  false
	end

	--added by wuqi
	--[[
	if skyBook.equip and skyBook.equip ~= 0 then
		local role = CardRoleManager:getRoleByGmid(skyBook.equip)
		role:setSkyBook(skyBook)
	end
	]]

	self.super.push(self, skyBook)
end

local function sortlistByQuality(v1,v2)
	if v1.quality > v2.quality then
		return true
	elseif v1.quality == v2.quality then
		if v1:getpower() > v2:getpower() then
			return true
		elseif v1:getpower() == v2:getpower() then
			return true			
		else
			return false
		end
	else
		return false
	end
end 

--added by wuqi
function SkyBookManager:getItemByInstanceId( instanceId )
	for v in self:iterator() do
		if v.instanceId == instanceId then
			return v
		end
	end
end


--[[
	added by wuqi
	获得全部未装配天书
]]
function SkyBookManager:getAllUnEquippedBook()
	local skyBookArray = TFArray:new()
	for v in self:iterator() do
		if v.equip == nil or v.equip == 0 then
			skyBookArray:push(v)
		end
	end
	skyBookArray:sort(sortlistByQuality)

	return skyBookArray
end

local function sortlistByType(v1,v2)
	if v:getConfigKind() < v:getConfigKind() then
		return true
	elseif v:getConfigKind() <= v:getConfigKind() then
		if v1.quality > v2.quality then
			return true
		elseif v1.quality == v2.quality then
			if v1:getpower() < v2:getpower() then
				return true
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end

local function sortlist(v1,v2)
	if SkyBookManager.sortType == SkyBookManager.SortEquipmentType then
		return sortlistByType(v1,v2)
	else
		return sortlistByQuality(v1,v2)
	end
end

local function sortlistByQualityAndEquipedFirst(v1,v2)
	if v1.equip == 0 and v2.equip~=0 then
		return false
	elseif v1.equip ~=0 and v2.equip==0 then
		return true
	end
	if v1.quality > v2.quality then
		return true
	elseif v1.quality == v2.quality then
		if v1:getpower() > v2:getpower() then
			return true
		elseif v1:getpower() == v2:getpower() then
			if v1.star >= v2.star then
				return true
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end 

local function sortlistByTypeAndEquipedFirst(v1,v2)
	if v1.equip == 0 and v2.equip~=0 then
		return false
	elseif v1.equip ~=0 and v2.equip==0 then
		return true
	end
	if v1.equipType < v2.equipType then
		return true
	elseif v1.equipType <= v2.equipType then
		if v1.quality > v2.quality then
			return true
		elseif v1.quality == v2.quality then
			if v1:getpower() < v2:getpower() then
				return true
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end

local function sortlistAndEquipedFirst(v1,v2)
	if SkyBookManager.sortType == SkyBookManager.SortEquipmentType then
		return sortlistByTypeAndEquipedFirst(v1,v2)
	else
		return sortlistByQualityAndEquipedFirst(v1,v2)
	end
end

--[[--
	返回指定天书类型的装备
	@param kind: 天书类型
	@return 指定Key值的元素
]]	
function SkyBookManager:getSkyBookByType(kind)
	local skyBookArray = TFArray:new()
	for v in self:iterator() do
		if kind == nil or v:getConfigKind() == kind or kind == 0 then
			skyBookArray:push(v)
		end
	end
	skyBookArray:sort(sortlist)

	return skyBookArray
end

--[[
	--added by wuqi
	获得所有天书
]]
function SkyBookManager:getAllSkyBook()
	local skyBookArray = TFArray:new()
	for v in self:iterator() do
		skyBookArray:push(v)
	end
	skyBookArray:sort(sortlistByQuality)

	return skyBookArray
end

--added by wuqi
function SkyBookManager:getNumByInstanceId(instanceId)
	local count = 0
	for v in self:iterator() do
		if v.instanceId == instanceId then
			count = count + 1
		end
	end
	return count
end

--[[--
	返回指定天书类型的天书,是否已使用
	@param kind: 天书类型
	@param isused 是否正在使用
	@param sortDisable 是否不排序
	@return 指定Key值的元素
]]	
function SkyBookManager:getSkyBookByTypeAndUsed(kind,isused,sortDisable)
	local skyBookArray = TFArray:new()
	for v in self:iterator() do
		if kind == nil or v:getConfigKind() == kind or kind == 0 then
		    if isused and v.equip and v.equip ~= 0 then
				skyBookArray:push(v)
			elseif isused == false and (v.equip == nil or v.equip == 0) then
				skyBookArray:push(v)
			end
		end
	end
	if not sortDisable then
		skyBookArray:sort(sortlist)
	end
	return skyBookArray
end

--[[--
	返回指定天书类型的天书,且排除了装备在特定角色身上的天书
	@param equipType: 天书类型
	@param roleGmIdTable: 排除的角色模板ID
	@param equipArray 存储装备数组
	@return 指定Key值的元素
]]	
function SkyBookManager:GetEquipExclude(equipType,roleTemplateIdTable,equipArray)
	local function constains(instanceId)
		if not roleTemplateIdTable then
			return false
		end

		for i = 1,9 do
		  	local gmId = roleTemplateIdTable[i]
		  	if gmId and gmId ~= 0 and gmId == instanceId then
				return true
			end
		end
		return false
	end

	if not equipArray then
		equipArray = TFArray:new()
	end

	for v in self:iterator() do
		if equipType == nil or v.equipType == equipType or equipType == 0 then
		    if v.equip and v.equip ~= 0 then
		    	local exclude = constains(v.equip)
				if not exclude then
					equipArray:push(v)
				end
			elseif v.equip == nil or v.equip == 0 then
				equipArray:push(v)
			end
		end
	end
	equipArray:sort(sortlistAndEquipedFirst)
	return equipArray
end

--[[--
	返回指定装备类型的装备,是否已使用
	@param equipType: 装备类型
	@return 指定Key值的元素
]]	
function SkyBookManager:GetEquipExcludeInWarSide(equipType)
	local roleTemplateIdTable = StrategyManager:getRoleTemplateIdTable()
	return self:GetEquipExclude(equipType,roleTemplateIdTable)
end

--[[--
	返回所有装备，并且上阵的角色身上穿着装备优先
	@param equipType: 装备类型
	@return 指定Key值的元素
]]	
function SkyBookManager:GetAllEquipInWarSideFirst(equipType)
	local equipArray = TFArray:new()
	local roleTemplateIdTable = StrategyManager:getRoleTemplateIdTable()
	for i = 1,9 do
	  	local gmId = roleTemplateIdTable[i]
	  	if gmId then
	  		local role = CardRoleManager:getRoleById(gmId)
	  		for i = EnumGameEquipmentType.Weapon,EnumGameEquipmentType.Shoe do
				if role.equipment.map[i] then
					if equipType and equipType ~=0 then
						if role.equipment.map[i].equipType == equipType then
							equipArray:pushBack(role.equipment.map[i])
						end
					else
						equipArray:pushBack(role.equipment.map[i])
					end
				end
			end
		end
	end
	return self:GetEquipExclude(equipType,roleTemplateIdTable,equipArray)
end

--[[--
	返回是否使用的装备
	@param isused: 是否使用
	@return 指定Key值的元素
]]	
function SkyBookManager:GetEquipByUsed(isused)
	local EquipArray = TFArray:new()
	for v in self:iterator() do
		if isused and v.equip and v.equip ~= 0 then
			EquipArray:push(v)
		elseif isused == false and (v.equip == nil or v.equip == 0) then
			EquipArray:push(v)
		end
	end
	EquipArray:sort(sortlist)
	return EquipArray
end

--[[--
	返回是否使用的装备
	@param gmid 排除此装备
	@param isused: 是否使用
	@param sortDisable 是否不进行内部排序
	@return 指定Key值的元素
]]	
function SkyBookManager:GetOtherEquipByUsed(gmid,isused,sortDisable)
	local EquipArray = TFArray:new()
	for v in self:iterator() do
		--有重铸过的装备排除
		if v.recastPercent <= 0 then
			if isused and v.equip and v.equip ~= 0 then
				if v.gmId ~= gmid then
					EquipArray:push(v)
				end
			elseif isused == false and (v.equip == nil or v.equip == 0) then
				if v.gmId ~= gmid then
					EquipArray:push(v)
				end
			end
		end
	end
	if not sortDisable then
		EquipArray:sort(sortlist)
	end
	return EquipArray
end

--[[--
	返回指定的装备
	@param gmid: 装备唯一id
	@return 指定Key值的元素
]]	
function SkyBookManager:getEquipByGmid(gmid)
	for v in self:iterator() do
		if v.gmId == gmid then
			return v
		end
	end
end


--[[--
	写下指定类型的装备
	@param type: 装备类型
	@return 成功失败
]]	
function SkyBookManager:DelEquipmentByGmid(gmId)
	for v in self:iterator() do
		if v.gmId == gmId then
			print("删除道具 --- "..v.name)
			if v.equip and v.equip ~= 0 then
				local role = CardRoleManager:getRoleById(v.equip)
				if role then 
					role:DelEquipment(v)	
				end		
			end
			local equipType = v.equipType
			self:removeObject(v)
			v:dispose()
			v = nil
			TFDirector:dispatchGlobalEventWith(SkyBookManager.DEL_EQUIP,equipType)	
			return true
		end
	end
	return false
end


--[[--
	更换装备
]]	
function SkyBookManager:onReceiveEquipOperation(event)
	hideLoading();
	--print("-------------------------EquipOperation-----------------")
	local data = event.data
	--print("EquipOperation info")
	--print(data)
	local role = CardRoleManager:getRoleByGmid(data.roleId)
	local equip = self:getEquipByGmid(data.equipment)
	if role == nil or equip == nil then 
		print("role == nil or equip == nil ------- SkyBookManager:101-----")
		return
	end
	local oldequip = role:getEquipmentByIndex(equip.equipType)
	if oldequip ~= nil then
		role:DelEquipment(oldequip)
	end
	role:AddEquipment(equip) --本身updateFate就有计算属性@mark
	---equip.equip = role.id
	--print("--------------------EquipOperation  ok-----------------")
	--CardRoleManager:UpdateRoleFate()
	role:updateFate()
	TFDirector:dispatchGlobalEventWith(SkyBookManager.EQUIP_OPERATION,{gmId = role.gmId,equip = equip}); 
	TFDirector:dispatchGlobalEventWith("EquipmentChangeEnd",{}); 
end

function SkyBookManager:onReceiveUnequipOperation(event)
	hideLoading();
	--print("-------------------------UnequipOperation-----------------")
	local data = event.data
	--print(data)
	local role = CardRoleManager:getRoleByGmid(data.roleId)
	local equip = self:getEquipByGmid(data.equipment)
	if role == nil or equip == nil then 
		print("role == nil or equip == nil ------- SkyBookManager:101-----")
		return
	end
	role:DelEquipment(equip) --本身updateFate就有计算属性@mark
	--print("-------------------- UnequipOperation   ok-----------------")
	--CardRoleManager:UpdateRoleFate()
	role:updateFate()
	TFDirector:dispatchGlobalEventWith(SkyBookManager.UNEQUIP_OPERATION,{gmId = role.gmId,equip = equip});
	TFDirector:dispatchGlobalEventWith("EquipmentChangeEnd",{});  
end

function SkyBookManager:EquipmentChange(data)
	showLoading();
	--print("-------------------- EquipmentChange   ok-----------------")
	--print(data)
	local role = CardRoleManager:getRoleById(data.roleid)
	local equip = self:getEquipByGmid(data.gmid)
	if role == nil or equip == nil  then
		print("role == nil or equip == nil -----SkyBookManager:134-------- ")
		return
	end
-- 	message EquipRequest{
-- 	required int64 roleId = 1; //角色实例id
-- 	required int64 equipment = 2; //装备到身上的装备userid
-- }
	local Msg = 
	{
		role.gmId,
		equip.gmId,
	}
	TFDirector:send(c2s.EQUIP_REQUEST,Msg)
	--role:AddEquipment(equip)
	--equip.equip = role.id
end

function SkyBookManager:unEquipmentChange(data)
	showLoading();
	--print("-------------------- EquipmentChange   ok-----------------")
	--print(data)
	local role = CardRoleManager:getRoleById(data.roleid)
	local equip = self:getEquipByGmid(data.gmid)
	if role == nil or equip == nil  then
		print("role == nil or equip == nil -----SkyBookManager:134-------- ")
		return
	end
-- 	message EquipRequest{
-- 	required int64 roleId = 1; //角色实例id
-- 	required int64 equipment = 2; //装备到身上的装备userid
-- }
	local Msg = 
	{
		role.gmId,
		equip.gmId,
	}
	TFDirector:send(c2s.UNEQUIP_REQUEST,Msg)
	--role:AddEquipment(equip)
	--equip.equip = role.id
end

function SkyBookManager:EquipmentIntensify(userid )
	showLoading()
	local Msg = 
	{
		userid,
	}
	TFDirector:send(c2s.EQUIPMENT_INTENSIFY,Msg)
end

function SkyBookManager:EquipmentIntensifyToTop(userid )
	showLoading()
	local Msg = 
	{
		userid,
	}
	TFDirector:send(c2s.EQUIPMENT_INTENSIFY_TO_TOP,Msg)
end

function SkyBookManager:onReceiveEquipmentIntensifyResult(event )
-- 	// code = 0x1014
-- //强化装备
-- message EquipmentIntensifyResult{
-- 	required int32 result = 1; //是否成功
-- 	optional EquipmentLevelChanged levelChanged = 2;	//强化提升的等级
--}
	hideLoading()
	local data = event.data
	if data.result == 0 then
		local levelChanged = data.levelChanged
		if levelChanged then
			-- message EquipmentLevelChanged
			-- {
			-- 	required int64 userid = 1;
			-- 	required int32 levelUp = 2;
			-- 	required EquipmentAttribute attr = 3;
			-- }
			local equip = self:getEquipByGmid(levelChanged.userid)
			if equip == nil then
				print("没有找到该装备 userid == " .. levelChanged.userid)
				return
			end
			local notice_data = {}
			notice_data.gmid =levelChanged.userid
			notice_data.level = levelChanged.levelUp
			notice_data.change_attr = {}
			local base_attr_old = {}
			local baseAttr = equip:getBaseAttribute():getAttribute()
			for i=1,(EnumAttributeType.Max-1) do
				if baseAttr[i] then
					base_attr_old[i] = baseAttr[i]
				end
			end

			local level = equip.level + levelChanged.levelUp
			equip:setLevel(level)

			--equip:UpdateAttr()
			baseAttr = equip:getBaseAttribute():getAttribute()
			for i=1,(EnumAttributeType.Max-1) do
				if baseAttr[i] then
					notice_data.change_attr[i] = baseAttr[i] - base_attr_old[i]
				end
			end
			TFDirector:dispatchGlobalEventWith(SkyBookManager.EQUIPMENT_INTENSIFY_RESULT, notice_data)
			TFDirector:dispatchGlobalEventWith(SkyBookManager.EQUIP_OPERATION ,{id = equip.equip,equip = equip})
		end
	end
	
end

function SkyBookManager:EquipmentSell(userid )
	showLoading()
	local Msg = 
	{
		userid,
	}
	TFDirector:send(c2s.EQUIPMENT_SELL,Msg)
end

function SkyBookManager:onReceiveEquipmentSellResult(event )
-- //code = 0x1015
-- //装备出售
-- message EquipmentSellResult{
-- 	required int32 result = 1; //是否成功
-- 	optional int64 userid = 2; //
-- }
	hideLoading()
	local data = event.data
	if data.result == 0 then
		self:DelEquipmentByGmid(data.userid)
		TFDirector:dispatchGlobalEventWith(SkyBookManager.EQUIPMENT_SELL_RESULT,data.userid)
	end
end

function SkyBookManager:EquipmentExplode(userid )
	showLoading()
	local Msg = 
	{
		userid,
	}
	TFDirector:send(c2s.EQUIPMENT_EXPLODE,Msg)
end
function SkyBookManager:onReceiveEquipmentExplodeResult(event )
-- //code = 0x1016
-- //装备分解
-- message EquipmentExplodeResult{
-- 	required int32 result = 1; //是否成功
-- 	optional int64 userid = 2; //
-- }
	hideLoading()
	local data = event.data
	if data.result == 0 then
		self:DelEquipmentByGmid(data.userid)
		TFDirector:dispatchGlobalEventWith(SkyBookManager.EQUIPMENT_EXPLODE_RESULT,data.userid)
	end
end

function SkyBookManager:GemMosaic(userid , id , pos )
	showLoading()
	local Msg = 
	{
		userid,
		id,
		pos,
	}
	TFDirector:send(c2s.GEM_MOSAIC,Msg)
end
function SkyBookManager:onReceiveGemMosaicResult(event )
-- //code = 0x1051
-- //宝石镶嵌
-- message GemMosaicResult{
-- 	required int32 result = 1; //是否成功
-- 	optional EquipmentGemChanged gemchanged = 2;
-- }
	hideLoading()
	local data = event.data
-- message EquipmentGemChanged
-- {
-- 	required int64 userid = 1;
-- 	required GemPos gem   = 2;		//宝石信息
-- }
	if data.result == 0 and data.gemchanged then
		local equip = self:getEquipByGmid(data.gemchanged.userid)
		if equip == nil then
			print("没有找到该装备 userid == " .. data.gemchanged.userid)
			return
		end
		local gem = data.gemchanged.gem
		equip:setGemPos( gem.pos , gem.id )
		equip:UpdateAttr()
		TFDirector:dispatchGlobalEventWith(SkyBookManager.GEM_MOSAIC_RESULT,data.gemchanged)
	end
end
--拆卸宝石
function SkyBookManager:GemUnMosaic(userid , pos )
	showLoading()
	local Msg = 
	{
		userid,
		pos,
	}
	TFDirector:send(c2s.GEM_UN_MOSAIC,Msg)
end
function SkyBookManager:onReceiveGemUnMosaicResult(event )
-- //code = 0x1052
-- //宝石拆卸
-- message GemUnMosaicResult{
-- 	required int32 result = 1; //是否成功
-- 	optional int64 userid = 2; //
-- 	optional int32 pos 	  = 3; //
-- }
	hideLoading()
	local data = event.data
	if data.result == 0 and data.userid and data.pos then
		local equip = self:getEquipByGmid(data.userid)
		if equip == nil then
			print("没有找到该装备 userid == " .. data.userid)
			return
		end
		local gemid = equip:getGemPos(data.pos)
		equip:setGemPos( data.pos , nil)
		equip:UpdateAttr()
		TFDirector:dispatchGlobalEventWith(SkyBookManager.GEM_UN_MOSAIC_RESULT,{gemid = gemid , userid = data.userid})
	end
end
--宝石孔花钱解锁
function SkyBookManager:UnlockEquipmentHole(userid)
	showLoading()
	local Msg = 
	{
		userid,
	}
	TFDirector:send(c2s.UNLOCK_EQUIPMENT_HOLE,Msg)
end
function SkyBookManager:onReceiveUnlockEquipmentHoleResult(event )
-- //code = 0x1053
-- //宝石孔花钱解锁
-- message UnlockEquipmentHoleResult{
-- 	required int32 result = 1; //是否成功
-- 	optional EquipmentGemStatusChanged gemStatus = 2;
-- }
	hideLoading()
	local data = event.data
-- 	message EquipmentGemStatusChanged
-- {
-- 	required int64 userid = 1;
-- 	required int32 holeNum = 2;  // 宝石孔数
-- }
	if data.result == 0 and data.gemStatus then
		local equip = self:getEquipByGmid(data.gemStatus.userid)
		if equip == nil then
			print("没有找到该装备 userid == " .. data.gemStatus.userid)
			return
		end
		equip.maxGem = data.gemStatus.holeNum
		TFDirector:dispatchGlobalEventWith(SkyBookManager.UNLOCK_EQUIPMENT_HOLE_RESULT,equip.maxGem)
	end
end
function SkyBookManager:onReceiveAllEquipmentGemSoltNumberChanged(event )
	hideLoading();
-- //code = 0x1055
-- //所有角色持有装备宝石孔更变
-- message AllEquipmentGemSoltNumberChanged{
-- 	required int32 max = 1; //默认开放的宝石孔个数
-- }
	local data = event.data

	for v in self:iterator() do
		v.maxGem = data.max
		--TFDirector:dispatchGlobalEventWith(SkyBookManager.UNLOCK_EQUIPMENT_HOLE_RESULT,equip.maxGem)
	end
end


--装备精炼
function SkyBookManager:EquipmentRefining(userid , lockArray,isten)
	if isten == nil then
		isten = false
	end
	showLoading()
	local Msg = 
	{
		userid,
		lockArray,
	}
	if isten then
		TFDirector:send(c2s.ONE_KEY_EQUIP_REFINE,Msg)
	else
		TFDirector:send(c2s.EQUIPMENT_REFINING,Msg)
	end
end

--装备洗炼
function SkyBookManager:EquipPractice(userid , lockArray)
	showLoading()
	local Msg = 
	{
		userid,
		lockArray,
	}
	TFDirector:send(c2s.EQUIP_PRACTICE,Msg)
end


function SkyBookManager:onReceiveEquipmentRefiningResult(event )
-- //code = 0x1019
-- //装备精炼
-- message EquipmentRefiningResult{
-- 	required int64 equipment = 1; //装备userid
-- 	required string extra_attr = 2;	//附加属性
-- }
	hideLoading()
	local data = event.data
	local equip = self:getEquipByGmid(data.equipment)
	if equip == nil then
		print("该装备不存在")
		return
	end
	local notice_data = {}
	notice_data.gmId = equip.gmId
	local base_attr_old = {}
	local baseAttr = equip:getExtraAttribute():getAttribute()
	for i=1,(EnumAttributeType.Max-1) do
		if baseAttr[i] then
			base_attr_old[i] = baseAttr[i]
		end
	end

	equip:getExtraAttribute():clear()
	equip:setExtraAttribute(data.extra_attr)
	equip:UpdateAttr()
	baseAttr = equip:getExtraAttribute():getAttribute()
	notice_data.change_attr = {}
	for i=1,(EnumAttributeType.Max-1) do
		if baseAttr[i] then
			notice_data.change_attr[i] = baseAttr[i] - base_attr_old[i]
		end
	end

	TFDirector:dispatchGlobalEventWith(SkyBookManager.EQUIPMENT_REFINING_RESULT,notice_data)
end


function SkyBookManager:onReceiveEquipmentPracticeResult(event )
-- //code = 0x1019
-- //装备精炼
-- message EquipmentRefiningResult{
-- 	required int64 equipment = 1; //装备userid
-- 	required string extra_attr = 2;	//附加属性
-- }
	hideLoading()
	local data = event.data
	local equip = self:getEquipByGmid(data.equipment)
	if equip == nil then
		print("该装备不存在")
		return
	end
	local notice_data = {}
	notice_data.gmId = equip.gmId
	local base_attr_old = {}
	local baseAttr = equip:getExtraAttribute():getAttribute()
	for i=1,(EnumAttributeType.Max-1) do
		if baseAttr[i] then
			base_attr_old[i] = baseAttr[i]
		end
	end

	equip:getExtraAttribute():clear()
	equip:setExtraAttribute(data.extra_attr)
	equip:UpdateAttr()
	baseAttr = equip:getExtraAttribute():getAttribute()
	notice_data.change_attr = {}
	for i=1,(EnumAttributeType.Max-1) do
		if baseAttr[i] then
			base_attr_old[i] = base_attr_old[i] or 0
			notice_data.change_attr[i] = baseAttr[i] - base_attr_old[i]
		end
	end

	TFDirector:dispatchGlobalEventWith(SkyBookManager.EQUIPMENT_PRACTICE_RESULT,notice_data)
end

--装备突破
function SkyBookManager:EquipmentTupo(userid)
	showLoading()
	local Msg = 
	{
		userid,
	}
	TFDirector:send(c2s.REQUEST_REFINE_BREACH, Msg)
end

function SkyBookManager:onReceiveEquipmentTupo(event)
	-- //装备精炼等级突破结果，最有在突破成功后发送给客户端
	-- message RefineBreachResult{
	-- 	required int64 instanceId = 1;			//装备实例ID
	-- 	required int32 refineLevel = 2;			//装备精炼等级
	-- }

	local data = event.data

	hideLoading()

	local equip = self:getEquipByGmid(data.instanceId)
	if equip == nil then
		print("该装备不存在")
		return
	end
	equip.refineLevel = data.refineLevel

	TFDirector:dispatchGlobalEventWith(SkyBookManager.EQUIPMENT_TUPO_RESULT,event.data)

end

--装备升星
function SkyBookManager:EquipmentStarUp(userid , eat_equipmentList,stuffList)
	showLoading()
	--添加的材料列表，需要从外部传入，暂时列为空
	--add by wkdai
	if not stuffList then
		stuffList = {}
	end
	local Msg = 
	{
		userid,
		eat_equipmentList,
		stuffList

	}
	TFDirector:send(c2s.EQUIPMENT_STAR_UP,Msg)
end

function SkyBookManager:onReceiveEquipmentStarUpResult(event )
-- //code = 0x1020
-- //装备升星
-- message EquipmentStarUpResult{
-- 	required int32 					result = 1;//结果
-- 	optional EquipmentStarSuccess 	success = 2;//成功结果
-- 	optional EquipmentStarFail 		fail = 3;//失败结果
-- }
	hideLoading()
	local data = event.data
	if  data.success then
		local equip = self:getEquipByGmid(data.success.equipment)
		if equip == nil then
			print("该装备不存在")
			return
		end
		equip:setStar( data.success.star )
		equip:setGrow( data.success.grow )
		equip:UpdatePower()
		equip.failPercent = 0
		--toastMessage("升星成功")
		TFDirector:dispatchGlobalEventWith(SkyBookManager.EQUIPMENT_STAR_UP_RESULT,{gmid = equip.gmid , success = true})
	elseif data.fail then
		local equip = self:getEquipByGmid(data.fail.equipment)
		if equip == nil then
			print("该装备不存在")
			return
		end
		equip.failPercent   = math.floor(data.fail.fail/100)
		if equip.failPercent > 0 then
			--toastMessage("升星失败,累计补偿成功概率["..equip.failPercent .."%]")
		end
		TFDirector:dispatchGlobalEventWith(SkyBookManager.EQUIPMENT_STAR_UP_RESULT,{gmid = equip.gmid , success = false})
	end
end

function SkyBookManager:OpenSmithyMainLaye()
	local teamLev = MainPlayer:getLevel()
    local openLev = PlayerGuideManager:getEquipOpenLevel()
    if teamLev < openLev then
        --toastMessage("团队等级达到"..openLev.."级开启")
        toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
        return
    end
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.smithy.SmithyMainLayer");
    layer.selectedTab = nil;
    AlertManager:show();      
end

function SkyBookManager:OpenEquipmentIntensify(gmId)
	local equip = self:getEquipByGmid(gmId)
	local layer = require("lua.logic.smithy.SmithyIntensify"):new(equip)
    AlertManager:addLayer(layer)
    AlertManager:show()
end

function SkyBookManager:OpenOperationLayer(gmId)
	local equip = self:getEquipByGmid(gmId)
	local layer = require("lua.logic.smithy.SmithyBaseLayer"):new(equip)
    AlertManager:addLayer(layer)
    AlertManager:show()
    return layer
end

function SkyBookManager:OpenEquipmentStarUp(gmId)
	local equip = self:getEquipByGmid(gmId)
    local layer = require("lua.logic.smithy.EquipmentStarUp"):new(equip.gmId)
    AlertManager:addLayer(layer)
    AlertManager:show()
end

function SkyBookManager:OpenEquipmentRefining(gmId)
	local equip = self:getEquipByGmid(gmId)
	if equip.quality <= 1 then
		--toastMessage("丁级装备无法洗炼")
		toastMessage(localizable.EquipmentManager_equip_wufaxilian)
	end
    local layer = require("lua.logic.smithy.EquipmentRefining"):new(equip.gmId)
    AlertManager:addLayer(layer)
    AlertManager:show()
end

function SkyBookManager:OpenGemMosaicLayer(gmId)
	local equip = self:getEquipByGmid(gmId)
    local layer = require("lua.logic.smithy.SmithyGem"):new(equip)
    AlertManager:addLayer(layer)
    AlertManager:show()
end

function SkyBookManager:OpenGemBuildLayer()
    local layer = require("lua.logic.smithy.SmithyGemBuild"):new()
    AlertManager:addLayer(layer)
    AlertManager:show()
end

--功能开放逻辑
SkyBookManager.Function_Intensify = 101
SkyBookManager.Function_StarUp = 102
SkyBookManager.Function_Parctice = 107
SkyBookManager.Function_Refining = 103
SkyBookManager.Function_Gem_Mount = 104
SkyBookManager.Function_Gem_Merge = 105
SkyBookManager.Function_Recast = 108
--[[
验证装备强化是否开放
@return 如果装备强化开放返回true，否则返回false
]]
function SkyBookManager:isIntensifyEnable()
	local configure = FunctionOpenConfigure:objectByID(SkyBookManager.Function_Intensify)
	if configure then
		return configure.level <= MainPlayer:getLevel()
	end
	return true
end

--[[
验证装备升星是否开放
@return 如果装备升星开放返回true，否则返回false
]]
function SkyBookManager:isStarUpEnable()
	local configure = FunctionOpenConfigure:objectByID(SkyBookManager.Function_StarUp)
	if configure then
		return configure.level <= MainPlayer:getLevel()
	end
	return true
end


--[[
验证装备精炼是否开放
@return 如果装备精炼开放返回true，否则返回false
]]
function SkyBookManager:isRefiningEnable()
	local configure = FunctionOpenConfigure:objectByID(SkyBookManager.Function_Refining)
	if configure then
		return configure.level <= MainPlayer:getLevel()
	end
	return true
end

--[[
验证宝石镶嵌是否开放
@return 如果宝石镶嵌开放返回true，否则返回false
]]
function SkyBookManager:isGemMountEnable()
	local configure = FunctionOpenConfigure:objectByID(SkyBookManager.Function_Gem_Mount)
	if configure then
		return configure.level <= MainPlayer:getLevel()
	end
	return true
end

--[[
验证宝石合成是否开放
@return 如果宝石合成开放返回true，否则返回false
]]
function SkyBookManager:isGemMergeEnable()
	local configure = FunctionOpenConfigure:objectByID(SkyBookManager.Function_Gem_Merge)
	if configure then
		return configure.level <= MainPlayer:getLevel()
	end
	return true
end

--红点判断逻辑
SkyBookManager.gemEnoughRPM = EnumServiceType.GOODS * 256 + 128
SkyBookManager.newRefinStoneRPM = EnumServiceType.GOODS * 256 + 129
SkyBookManager.newGemRPM = EnumServiceType.GOODS * 256 + 130

--需求：当有足够数量的低级宝石时，可合成高级宝石，在该宝石图标、宝石合成标签、主界面铁匠铺图标右上角标注红点；
--      当玩家点击合成该宝石，该宝石合成完毕，其数量不足以继续合成下一级宝石时，该宝石图标右上角红点消失；
--该宝石是否可以合成
function SkyBookManager:isGemEnough(id)
	if not self:isGemMergeEnable() then
		return false
	end
	local holdGem = BagManager:getItemById(id)
	if holdGem and holdGem.num > 3 and holdGem.level < 15  then
		return true
	end
	return false
end

--是否有宝石可以合成
function SkyBookManager:isHaveGemEnough()
	if not self:isGemMergeEnable() then
		return false
	end

	local allItems = BagManager.itemArray
	for v in allItems:iterator() do
		if v.type == EnumGameItemType.Gem then
			if v.num > 3 and v.level <15 then
				return true
			end
		end
	end
	return false
end

--是否有新的精炼石
function SkyBookManager:isHaveNewRefinStone()
	local enabled = RedPointManager:isRedPointEnabled(SkyBookManager.newRefinStoneRPM)
	if enabled then
		return true
	end
	if self.newRefinStoneMark then
		RedPointManager:setRedPointEnabled(SkyBookManager.newRefinStoneRPM,true)
	end
	return self.newRefinStoneMark
end

--进入精炼界面，红点消失
function SkyBookManager:onIntoRefinLayer()
	--服务端记录，并推送前端
	self.newRefinStoneMark = false
	RedPointManager:setRedPointEnabled(SkyBookManager.newRefinStoneRPM,false)
end

--是否有新的宝石
function SkyBookManager:isHaveNewGem()
	local enabled = RedPointManager:isRedPointEnabled(SkyBookManager.newGemRPM)
	if enabled then
		return true
	end
	if self.newGemMark then
		RedPointManager:setRedPointEnabled(SkyBookManager.newGemRPM,true)
	end
	return self.newGemMark
end

--进入镶嵌界面，红点消失
function SkyBookManager:onIntoGemLayer()
	--服务端记录，并推送前端
	self.newGemMark = false
	RedPointManager:setRedPointEnabled(SkyBookManager.newGemRPM,false)
end

--直接进入装备强化界面
function SkyBookManager:openSmithyLayer(equipGMId,equipList,equipType,allList,completeOpenCallback)
	local teamLev = MainPlayer:getLevel()
    local openLev = PlayerGuideManager:getEquipOpenLevel()
    if teamLev < openLev then
        --toastMessage("团队等级达到"..openLev.."级开启")
        toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
        return
    end
	--如果传入的equipList为nil，则自动根据equipGMId来生成equipList
	if not equipList then
		local equip = self:getEquipByGmid(equipGMId)
    	if equip == nil  then
    	    print("equipment not found .",equipGMId)
    	    return false
    	end

    	if allList then
    		equipList = self:GetAllEquipInWarSideFirst(equipType)
    	else
    		if equip.equip ~= 0 then
	    		local role = CardRoleManager:getRoleById(equip.equip)
	    		equipList = role.equipment:allAsArray()
	    	else
	    		equipList = self:GetAllEquipInWarSideFirst(equipType)
	    	end
    	end
	end
	if completeOpenCallback then
		completeOpenCallback()
	end

    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.smithy.SmithyBaseLayer");
    layer:loadData(equipGMId,equipList,equipType,allList)
    AlertManager:show();   
    return true
end

function SkyBookManager:showEquipDetailsDialog(equipGMId,equipList,equipType,allList)
    -- local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.smithy.EquipDetailsDialog",AlertManager.BLOCK_AND_GRAY_CLOSE);
    -- layer:loadData(equipGMId,equipList,equipType,allList)
    -- AlertManager:show();   
    self:openSmithyLayer(equipGMId,equipList,equipType,allList)
end

function SkyBookManager:getTupoStone()
	if not self.tupoStone then
		local tupoStoneConstant = ConstantData:objectByID("Equip.Tupo.Consume.Goods")
		if tupoStoneConstant then
			self.tupoStone = ItemData:objectByID(tupoStoneConstant.res_id)
		end
	end
	
	return self.tupoStone
end

function SkyBookManager:getHoldTupoStone()
	if self.tupoStone then
		return BagManager:getItemById(self.tupoStone.id)
	end
	
	return nil
end

function SkyBookManager:getEquipListByID(id, except_gmid)
	local EquipArray = TFArray:new()
	for v in self:iterator() do
		if (v.id == id and v.gmId ~= except_gmid) and (v.equip == nil or v.equip == 0) then
			EquipArray:push(v)
		end
	end

	local function sortByPower(v1,v2)
		return v1.power < v2.power		
	end

	EquipArray:sort(sortByPower)
	return EquipArray
end
--重铸请求
function SkyBookManager:requestRecastEquip(Msg)
	showLoading()	
	print('requestRecastEquip = ',Msg)
	TFDirector:send(c2s.EQUIPMENT_RECAST,Msg)
end

--是否存在精炼
function SkyBookManager:checkIsJinglian(equip)
    if equip == nil  then
        print("equipment not found .")
        return 0
    end    
    local refineLevel   = equip.refineLevel
    local equipmentTemplate = EquipmentTemplateData:objectByID(equip.id)
    if equipmentTemplate == nil then
        print("没有此类装备模板信息")
        return 0
    end
    local jinlianshi = 0
    if equip.quality >= 2 then
		local attribute,indexTable = equip:getExtraAttribute():getAttribute()
		local min_attribute , max_attribute = equipmentTemplate:getExtraAttribute(refineLevel)

		local index = 1
		local maxPercent = 0

    	for k,i in pairs(indexTable) do
    		if min_attribute[i] and max_attribute[i] then
    			local percent = attribute[i]/max_attribute[i]		
    			if percent > maxPercent then
    				maxPercent = percent
    				local initValue = min_attribute[i]+equipmentTemplate.init_min
	            	local Dvalue = attribute[i] - initValue
	            	local refiningGood = string.split(equipmentTemplate.refining_good,'|')
	            	local refiningNew = {}
	            	for k,v in pairs(refiningGood) do
						local activity= string.split(v,'_')
						local arrIdx = tonumber(activity[1])
						local arrValue = tonumber(activity[2])	            		
	            		refiningNew[arrIdx] = arrValue
	            	end
    				jinlianshi = math.ceil(Dvalue/refiningNew[i])
    			end
    		end
	        index = index + 1
	    end
    end
	return jinlianshi
end

function SkyBookManager:BindEffectOnEquip(panel, equip)
	if equip == nil or panel == nil then
    	return
    end
    
    local recastInfo = equip.recastInfo or {}
    local quality = 0
    for k,v in pairs(recastInfo) do
    	if v.quality > quality then
    		quality = v.quality 
    	end
    end

	if panel.equipEffect then
		panel.equipEffect:removeFromParent()
		panel.equipEffect = nil
	end


    local infoTemplete = EquipmentRecastData:getInfoByquality(quality)
    if infoTemplete then
    	local filePath = "effect/"..infoTemplete.effects..".xml"
    	TFResourceHelper:instance():addArmatureFromJsonFile(filePath)
	    local effect = TFArmature:create(infoTemplete.effects.."_anim")
	    effect:setAnimationFps(GameConfig.ANIM_FPS)
	    effect:playByIndex(0, -1, -1, 1)
	    effect:setVisible(true)
	    effect:setScale(1.15)
	    local offsetX = 0
	    local offsetY = 0
	    local widgetClassName = panel:getDescription()
	    if widgetClassName == 'TFImage' then
	    	local contentSize = panel:getContentSize()
	    	offsetX = contentSize.width/2
	    	offsetY = contentSize.height/2
	    end
	    effect:setPosition(ccp(offsetX,offsetY))
	    panel:addChild(effect,100)
	    panel.equipEffect = effect	
    end
end

function SkyBookManager:getExtraPercentByRecast( recastInfo )
	local percent = 0
	recastInfo = recastInfo or {}
	local qualityInfo = {}

	for k,v in pairs(recastInfo) do
		for i=1,v.quality do
			qualityInfo[i] = qualityInfo[i] or 0
			qualityInfo[i] = qualityInfo[i] + 1
		end
	end

	for v in EquipmentRecastSubAddData:iterator() do
		local currCount = qualityInfo[v.quality] or 0
		if v.sub_type == 3 and v.sub_count <= currCount then
			if percent < v.tppe_value then
				percent = v.tppe_value
			end
		end
	end

    return percent
end

--[[
	added by wuqi
	打开天书主界面
]]
function SkyBookManager:openTianshuMainLayer(instanceId, tag)
	local item = self:getItemByInstanceId(instanceId)
	local layer = require("lua.logic.tianshu.TianshuMainLayer"):new()
	layer:loadData(instanceId)
	layer:setTag(tag)
    AlertManager:addLayer(layer)
    AlertManager:show()
end

--获得对应品质天书残页数量
function SkyBookManager:getBiblePieceNumByQuality(quality)
	local base_id = 30095
	local num = BagManager:getItemNumById(base_id + quality - 1)
	return num
end

function SkyBookManager:getBiblePieceByQuality(quality)
	local base_id = 30095
	return BagManager:getItemById(base_id + quality - 1)
end

function SkyBookManager:getBiblePieceTemplateByQuality(quality)
	local base_id = 30095
	return ItemData:objectByID(base_id + quality - 1)
end

--通过精要碎片id获得所能合成的精要id
function SkyBookManager:getJingyaoIdByPieceId(pieceId)
	for v in EssentialData:iterator() do
		local str = v.comsume
		local tab = string.split(str, "_")
		if tonumber(tab[1]) == pieceId then
			return v.id
		end
	end
end

--是否有精要碎片可合成精要
function SkyBookManager:isHaveJingyaoCanHecheng()
	local jingyaoList = BagManager:getItemByType(EnumGameItemType.SBStonePiece)

	local bHave = false
	for v in jingyaoList:iterator() do
		local id = v.id
		local jingyaoId = self:getJingyaoIdByPieceId(id)
    	local bCan = self:isJingyaoCanHecheng(jingyaoId)
    	if bCan then
    		bHave = true
    	end
	end

	return bHave
end

--通过天书实例获得突破所需碎片数量
function SkyBookManager:getTupoNeedPieceNumByInstance(item)
	local breachConfig = item.breachConfig
	local consume = breachConfig.comsume
	
	local count = 0
	local tab_tupofu = {}
	local data = string.split(consume, "|")
	local strPiece = data[1]
	local strTupofu = data[2]
	
	if strPiece then
		local temp = string.split(strPiece, "_")
		count = tonumber(temp[3])		
	end

	if strTupofu then
		local temp = string.split(strTupofu, "_")
		tab_tupofu.id = tonumber(temp[2])
		tab_tupofu.num = tonumber(temp[3])
	end

	return count, tab_tupofu
end

--是否已经达到最高级
function SkyBookManager:isInTupoMaxLevel(item)
	if item.tupoLevel < self.kMaxStarLevel then
		return false
	else
		return true
	end
end

--请求天书突破
function SkyBookManager:requestTupo(instanceId)
	print("test request tianshu tupo, instanceId = ", instanceId)
end

--获得所有已经装配到天书上的精要
function SkyBookManager:getEquippedJingyaoList()
	local arr = TFArray:new()
	local bookArray = self:getAllSkyBook()
	for v in bookArray:iterator() do
		for i = 1, v.maxStoneNum do
			if v.sbStoneId[i] and v.sbStoneId[i] > 0 then
				local tab = {id = v.sbStoneId[i], bookId = v.id,equipId = v.equip}
				arr:push(tab)
			end
		end
	end

	local function sortByQuality(tab1, tab2)
		if ItemData:objectByID(tab1.id).quality > ItemData:objectByID(tab2.id).quality then
			return true
		elseif ItemData:objectByID(tab1.id).quality == ItemData:objectByID(tab2.id).quality then
			if tab1.id < tab2.id then
				return true
			end
		end
		return false
	end
	arr:sort(sortByQuality)

	return arr
end

--请求升重
function SkyBookManager:requestShengchong(item)
	print("SkyBookManager:requestShengchong, item instanceId = ", item.instanceId)
end

--判断所需精要是否有足够碎片合成
function SkyBookManager:isJingyaoCanHecheng(id)
	local item = EssentialData:objectByID(tonumber(id))
	--[[
	local item = nil
	for v in EssentialData:iterator() do
		if v.id == tonumber(id) then
			item = v
			break
		end
	end
	]]
	if not item then
		print("SkyBookManager:isJingyaoCanHecheng id not exist, id = ", id)
		return false
	end

	local consume = item.comsume
	local tab = string.split(consume, "_")
	local pieceId = tonumber(tab[1])
	local pieceNum = tonumber(tab[2])
	local bagItem = BagManager:getItemById(pieceId)

	if bagItem and bagItem.num >= pieceNum then
		return true
	end
	return false
end

function SkyBookManager:getJingyaoNeedPieceNum(jingyaoId)
	local item = EssentialData:objectByID(tonumber(jingyaoId))

	if not item then
		return
	end

	local consume = item.comsume
	local tab = string.split(consume, "_")
	local pieceId = tonumber(tab[1])
	local pieceNum = tonumber(tab[2])
	
	return pieceNum
end

function SkyBookManager:getJingyaoExplodeReward()
	local breachConfig = item.breachConfig
	local consume = breachConfig.comsume

	local tab = {}
	local data = string.split(consume, "|")
	for i = 1, #data do
		tab[i] = {}
		local temp = string.split(data[i], "_")
		tab[i].type = temp[1]
		tab[i].itemId = temp[2]
		tab[i].number = temp[3]		
	end
end

--test get 天书重置符
function SkyBookManager:getCongzhifuNumByQality(quality)
	local tab = {1, 2, 3, 5, 10}
	return tab[quality]
end

--获得当前天书重置符数量
function SkyBookManager:getCurChongzhifuNum()
	return BagManager:getItemNumById(30094)
end

--获得当前阅历数量
function SkyBookManager:getCurYueli()
	return MainPlayer:getYueliValue()
end

--重置返还物品列表
function SkyBookManager:showChongzhiRewardLayer(oldBible, bibleInstanceId)
	local yueliCost = self:calculateChongzhiGetYueli(oldBible)
	local curBible = self:getItemByInstanceId(bibleInstanceId)

	local rewardList = TFArray:new()
	local tabYueli = {}
	tabYueli.itemId = 0
	tabYueli.number = yueliCost
	tabYueli.type = EnumDropType.YUELI
	rewardList:push(BaseDataManager:getReward(tabYueli))

	local itemList = self:calculateChongzhiGetItem(oldBible)
	table.sort(itemList, function(tab1, tab2)
		return ItemData:objectByID(tab1.id).quality > ItemData:objectByID(tab2.id).quality
	end)
	for i = 1, #itemList do
		local tab = {}
		tab.itemId = itemList[i].id
		tab.number = itemList[i].num
		tab.type = EnumDropType.GOODS
		rewardList:push(BaseDataManager:getReward(tab))
	end

	local jingyaoList = self:calculateChongzhiGetJingyaoList(oldBible)
	table.sort(jingyaoList, function(tab1, tab2)
		return ItemData:objectByID(tab1.id).quality > ItemData:objectByID(tab2.id).quality
	end)

	for i = 1, #jingyaoList do
		local tab = {}
		tab.itemId = jingyaoList[i].id
		tab.number = jingyaoList[i].num
		tab.type = EnumDropType.GOODS
		rewardList:push(BaseDataManager:getReward(tab))
	end

	RewardManager:showRewardListLayer(rewardList)
end

--计算重置返还精要
function SkyBookManager:calculateChongzhiGetJingyaoList(bible)
	local bibleConfig = BibleData:getBibleInfoByIdAndLevel(bible.id, bible.level)
    local jingyaoStr = bibleConfig.essential_id
    local tab = string.split(jingyaoStr, ",")

    local jingyaoList = {}
    local function pushToTable(id)
    	local bFind = false
    	for i = 1, #jingyaoList do
    		if id == jingyaoList[i].id then
    			jingyaoList[i].num = jingyaoList[i].num + 1
    		end
    	end
    	if not bFind then
    		local temp = {}
    		temp.id = id
    		temp.num = 1
    		table.insert(jingyaoList, temp)
    	end
    end
    
    --当前重数返还精要
	for i = 1, bible.maxStoneNum do
        if bible:getStonePos(i) and bible:getStonePos(i) > 0 then
            local id = tonumber(tab[i])
            pushToTable(id)            
        end
    end

    if bible.level <= 1 then
        return jingyaoList
    end

    --返还非当前重数精要
    for i = bible.level - 1, 1, -1 do
        local config = BibleData:getBibleInfoByIdAndLevel(bible.id, i)
        jingyaoStr = config.essential_id
        tab = string.split(jingyaoStr, ",")
        for j = 1, #tab do
            pushToTable(tonumber(tab[j]))
        end
    end

    return jingyaoList
end

--计算重置返还阅历
function SkyBookManager:calculateChongzhiGetYueli(item)
    local need = 0
    local bibleConfig = BibleData:getBibleInfoByIdAndLevel(item.id, item.level)
    local moasicStr = bibleConfig.mosaic
    local tab = string.split(moasicStr, "|")
    for i = 1, item.maxStoneNum do
        if item:getStonePos(i) and item:getStonePos(i) > 0 then
            local tab1 = string.split(tab[i], ",")
            local str = tab1[1]
            local tab2 = string.split(str, "_")
            if tonumber(tab2[1]) == EnumDropType.YUELI then
                need = need + tonumber(tab2[3])
            end
        end
    end
    if item.level <= 1 then
        return need
    end
    for i = item.level - 1, 1, -1 do
        local config = BibleData:getBibleInfoByIdAndLevel(item.id, i)
        moasicStr = config.mosaic
        tab = string.split(moasicStr, "|")
        for j = 1, #tab do
            local tab1 = string.split(tab[j], ",")
            local str = tab1[1]
            local tab2 = string.split(str, "_")
            if tonumber(tab2[1]) == EnumDropType.YUELI then
                need = need + tonumber(tab2[3])
            end
        end
    end

    return need
end

--计算重置返还的升重符
function SkyBookManager:calculateChongzhiGetItem(item)
	local itemList = {}
	if item.level <= 1 then
        return itemList
    end

    local function pushToTable(id, num)
    	local bFind = false
    	for i = 1, #itemList do
    		if itemList[i].id == id then
    			itemList[i].num = itemList[i].num + num
    			bFind = true
    		end
    	end

    	if not bFind then
    		local tab = {}
    		tab.id = id
    		tab.num = num
    		table.insert(itemList, tab)
    	end
    end

    local tempTab = {}
    for i = item.level - 1, 1, -1 do
        local config = BibleData:getBibleInfoByIdAndLevel(item.id, i)
        local consumeStr = config.comsume
        local tab = string.split(consumeStr, ",")
        for j = 1, #tab do
            local tab1 = string.split(tab[j], "_")
            local str = tab1[1]            
            if tonumber(str) == EnumDropType.GOODS then
                pushToTable(tonumber(tab1[2]), tonumber(tab1[3]))
            end
        end
    end

    return itemList
end

local function sortByQualityAndPower(book1, book2)
	if book1.quality > book2.quality then
		return true
	elseif book1.quality == book2.quality then
		if book1:getpower() > book2:getpower() then
			return true
		end
	end

	return false
end

--获得已装备天书,并按照战力排序
function SkyBookManager:getEquippedBookList()
	local bookList = TFArray:new()

	for v in self:iterator() do
		if v.equip and v.equip ~= 0 then
			bookList:push(v)
		end
	end
	bookList:sort(sortByQualityAndPower)

	return bookList
end

--打开升重结果展示界面
--[[
function SkyBookManager:openTianshuBreakResultLayer(bibleInstanceId)
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.tianshu.TianshuBreakResultLayer", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
    layer:loadData(bibleInstanceId)
    AlertManager:show()
end
]]

--通过精要id获得所需精要碎片id
function SkyBookManager:getPieceIdByJingyaoId(jingyaoId)
	local consume = nil
	for v in EssentialData:iterator() do
		if v.id == tonumber(jingyaoId) then
			consume = v.comsume
		end
	end

	if not consume then
		return nil
	end

	local tab = string.split(consume, "_")

	return tonumber(tab[1]), tonumber(tab[2])
end

--快捷扫荡
function SkyBookManager:quickMission( missionId ,isReset,isBuyReset )
    local mission = AdventureMissionManager:getMissionById(missionId);

    local difficulty = mission.difficulty
    local maxChallengeCount  = 9
    if difficulty == 1 then
    	maxChallengeCount = 9
    elseif difficulty == 2 then
    	maxChallengeCount = 5
    end

    print("ssssss:", maxChallengeCount)

    mission.maxChallengeCount = 20
    local leftChallengeTimes = mission.maxChallengeCount - mission.challengeCount;
    if leftChallengeTimes <= 0 and isReset == false then
    	return false
    end
    local openVip = ConstantData:getValue("Mission.ManyQuick.NeedVIP");
	if MainPlayer:getVipLevel() < openVip then
		-- local msg =  "VIP" .. openVip .. "开启多次扫荡多次功能。";
		local msg =  "VIP" .. openVip .. "开启多次扫荡功能。\n\n是否前往充值？";
		CommonManager:showOperateSureLayer(
			function()
				PayManager:showPayLayer();
			end,
			nil,
			{
			title = "提升VIP",
			msg = msg,
			uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
			}
		)
		return true;
	end

	if leftChallengeTimes >= maxChallengeCount then
        leftChallengeTimes = maxChallengeCount
    end

    print("left times : ", leftChallengeTimes)

    if not MainPlayer:isEnoughTimes( EnumRecoverableResType.BAOZI , 1 * leftChallengeTimes, false )  then
        VipRuleManager:showReplyLayer(EnumRecoverableResType.BAOZI)
        return true
    end
    if mission.challengeCount >= mission.maxChallengeCount then          --没次数
    	if isReset == false then
			return false
		end

		local useResetTime = mission.resetCount
        local vipItem = VipData:getVipItemByTypeAndVip(2020,MainPlayer:getVipLevel());
        local maxResetTime = (vipItem and vipItem.benefit_value) or 0;
        local need = (useResetTime + 1) * ConstantData:getValue("Mission.Reset.Times.price");


        if maxResetTime - useResetTime < 1 then
			if isBuyReset == false then
				return false
			end
            local nextUpVip = VipData:getVipNextAddValueVip(2020,MainPlayer:getVipLevel())
            if nextUpVip then
				local str1 = stringUtils.format(localizable.youli_text8, nextUpVip.vip_level, nextUpVip.benefit_value)
				local str2 = stringUtils.format(localizable.youli_text9, nextUpVip.vip_level, nextUpVip.benefit_value)
				--[[
                local msg = (maxResetTime <= 0 
                    and "提升至VIP" .. nextUpVip.vip_level .. "可每日购买挑战次数" .. nextUpVip.benefit_value .. "次。\n\n是否前往充值？"
                    or "今日购买次数已用完！\n\n提升至VIP" .. nextUpVip.vip_level .. "可每日购买挑战次数" .. nextUpVip.benefit_value .. "次。\n\n是否前往充值？"
                    );
				]]
				local msg = (maxResetTime <= 0 and str1 or str2);
                CommonManager:showOperateSureLayer(
                        function()
                            PayManager:showPayLayer();
                        end,
                        nil,
                        {
                        title = (maxResetTime <= 0 and "提升VIP" or "挑战次数已用完") ,
                        msg = msg,
                        uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                        }
                )
            else
                toastMessage("挑战次数已用完，今日重置次数已用完");
            end
        else
            local configure = ResetData:objectByID(1)
            if configure then
                local toolId  = configure.token_id
                local temptbl = string.split(configure.token_num, ',')
                local usedResetIndex = useResetTime + 1
                if usedResetIndex > #temptbl then
                    usedResetIndex = #temptbl
                end

                local cost = tonumber(temptbl[usedResetIndex])

                local resetTool = BagManager:getItemById(toolId)
                if resetTool and resetTool.num >= cost then
                    local msg = "此次重置需要重置令" .. cost .. "个，是否确定重置？" ;
                    msg = msg .. "\n\n(当前拥有重置令：" .. resetTool.num..",今日还可以重置" .. maxResetTime - useResetTime .. "次)";
                    CommonManager:showOperateSureLayer(
                            function()
                                 MissionManager:resetChallengeCount( missionId );
                            end,
                            nil,
                            {
                                msg = msg
                            }
                    )
                    return true
                end
            end

            local msg = "是否花费" .. need .. "元宝重置此关卡挑战次数？" ;
            msg = msg .. "\n\n(今日还可以重置" .. maxResetTime - useResetTime .. "次)";
            CommonManager:showOperateSureLayer(
                    function()
                         if MainPlayer:isEnoughSycee( need , true) then
                                MissionManager:resetChallengeCount( missionId );
                         end
                    end,
                    nil,
                    {
                    msg = msg
                    }
            )
        end
        return true
    end


    local challengeTimes = math.min(mission.maxChallengeCount - mission.challengeCount, maxChallengeCount)

    --- vip对应的扫荡次数
    local vipQuickData  = VipData:getVipItemByTypeAndVip(2060, MainPlayer:getVipLevel()) 
    local vipQuickTimes = (vipQuickData and vipQuickData.benefit_value) or 0


    local saoDangCardNum = 0
    local sweepConfigure = SweepData:objectByID(1)
    if sweepConfigure then
        local cost = sweepConfigure.token_num or 1

        local sweepID = sweepConfigure.token_id
        -- 判断扫荡道具 30035
        local tool = BagManager:getItemById(sweepID)
        if tool and tool.num > 0 then
            saoDangCardNum = tool.num
        end

        saoDangCardNum = math.floor(saoDangCardNum/cost)
    end
    
    local totalFreeTimes = vipQuickTimes + saoDangCardNum - MissionManager.useQuickPassTimes

    print("vip扫荡次数----", vipQuickTimes)
    print("拥有扫荡卡----",  saoDangCardNum)
    print("扫荡用掉的次数----",  MissionManager.useQuickPassTimes)
    print("总的次数 ----",  totalFreeTimes)

    -- 需要花钱的次数
    local needCostTimes = challengeTimes - totalFreeTimes

    if needCostTimes <= 0 then
        needCostTimes = 0
        MissionManager:manyQuickPassMission(missionId,false,false,challengeTimes);
    else
        local freeQuickprice = ConstantData:getValue("Mission.FreeQuick.price");
        if challengeTimes == 1 then
            if MainPlayer:isEnoughSycee( freeQuickprice , true) then
                MissionManager:manyQuickPassMission(missionId,false,false,challengeTimes);
            end
            return true
        end

        local costNum =  freeQuickprice * needCostTimes
        local msg = "剩余免费次数和扫荡令总和不足,是否花费" .. costNum .. "元宝进行扫荡？" ;

        if not self.quick_need_money_tip then
            CommonManager:showOperateSureTipLayer(
                    function(data, widget)
                        if MainPlayer:isEnoughSycee( costNum , true) then
                            MissionManager:manyQuickPassMission(missionId,false,false,challengeTimes);
                            self:getHasTip(widget)
                        end
                    end,
                    function(data, widget)
                        AlertManager:close()
                        self:getHasTip(widget)
                    end,
                    {
                        msg = msg
                    }
            )
        else
            if MainPlayer:isEnoughSycee( costNum , true) then
                MissionManager:manyQuickPassMission(missionId,false,false,challengeTimes);
            end
        end
    end
    return true

end

function SkyBookManager:getHasTip( widget )
    local state = widget:getSelectedState();
    print("state == ",state)
    if state == true then
        self.quick_need_money_tip = true
        CCUserDefault:sharedUserDefault():setBoolForKey("quick_need_money_tip", self.quick_need_money_tip);
        CCUserDefault:sharedUserDefault():flush();
        return
    end
end


--------------------------------------

--ok
function SkyBookManager:oneKeyToHechengAndGet(jingyaoId)
	self.oneKeyTbl = {}
	if self:oneKeyToHechengAndGetById(jingyaoId, 1 ,false,false,true) then
		return
	end
	self.oneKeyTbl = {}
	if self:oneKeyToHechengAndGetById(jingyaoId, 1 ,true,false,true) then
		return
	end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
	self.oneKeyTbl = {}
	if self:oneKeyToHechengAndGetById(jingyaoId, 1 ,true,true,true) then
		return
	end
	self.oneKeyTbl = {}
	
	if self:isJingyaoCanHecheng(jingyaoId) then
		toastMessage(TFLanguageManager:getString(ErrorCodeData.Sweep_Synthesis))
	else
		toastMessage(TFLanguageManager:getString(ErrorCodeData.Sweep_No_Martial))
	end	
end

--一键合成及通过关卡获取
--ok
function SkyBookManager:oneKeyToHechengAndGetById(jingyaoId1, num,isReset,isBuyReset,first)
	local jingyaoId = tonumber(jingyaoId1)
	if num == nil then
		num = 1
	end

	self.oneKeyTbl[jingyaoId] = self.oneKeyTbl[jingyaoId] or 0
	self.oneKeyTbl[jingyaoId] = self.oneKeyTbl[jingyaoId] + num
	-- num = self.oneKeyTbl[martialId]
	local jingyaoNum = BagManager:getItemNumById(tonumber(jingyaoId))   --背包是否拥有
	if jingyaoNum >= self.oneKeyTbl[jingyaoId] and first == false then
		return false
	end
	MissionManager:quickPassToGetFGoods(jingyaoId, self.oneKeyTbl[jingyaoId])
	local jingyaoTemplate = EssentialData:objectByID(tonumber(jingyaoId))
	
	if jingyaoTemplate == nil then   --不是完本武学
		if self:getItemByShowWay(jingyaoId ,isReset,isBuyReset) then
			return true
		end
	else
		
		--local material = martialTemplate:getMaterialTable()   -- 合成所需的材料
		local id1, num1 = self:getPieceIdByJingyaoId(jingyaoId)
		local material = {id1 = num1}

		if not id1 then 			--不可合成
			if self:getItemByShowWay(jingyaoId ,isReset,isBuyReset) then
				return true
			end
		else
			--for k,v in pairs(material) do
				if self:oneKeyToHechengAndGetById(id1,num1*num,isReset,isBuyReset,false) then
					return true
				end
			--end
		end
	end
	return false
end

function SkyBookManager:getItemByShowWay( itemId ,isReset,isBuyReset)
	local itemInfo  = ItemData:objectByID(itemId)
	if itemInfo == nil then
		return false
	end
	if itemInfo.show_way == "" then
		print("获取途径为空 id == ",itemId)
		return false
	end
	local outputList  = string.split(itemInfo.show_way, "|")
	for i=1,#outputList do
		local output = string.split(outputList[i], "_")
		if tonumber(output[1]) == 22 then
			local missionId = tonumber(output[2])
			local mission = AdventureMissionManager:getMissionById(missionId);
			if mission == nil then
				print("mission == nil ,missionId =" , missionId)
				return false
			end
			local open = true
			if mission.starLevel == MissionManager.STARLEVEL0 then
		        open = false
		    end
		    
			if open and self:quickMission(missionId,isReset,isBuyReset) then
				return true
			end
			
			--MissionManager:manyQuickPassMission(missionId,false,false,5);
		end
	end
	return false
end


return SkyBookManager:new()