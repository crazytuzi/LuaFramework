--[[
******游戏数据装备管理类*******

	-- by Stephen.tao
	-- 2013/11/27
]]

local EquipmentManager = class("EquipmentManager",TFArray)


EquipmentManager.EQUIP_OPERATION 						= "EquipmentManager.EQUIP_OPERATION"
EquipmentManager.UNEQUIP_OPERATION 						= "EquipmentManager.UNEQUIP_OPERATION"
EquipmentManager.EQUIPMENT_INTENSIFY_RESULT 			= "EquipmentManager.EQUIPMENT_INTENSIFY_RESULT"
EquipmentManager.EQUIPMENT_SELL_RESULT 					= "EquipmentManager.EQUIPMENT_SELL_RESULT"
EquipmentManager.EQUIPMENT_EXPLODE_RESULT	 			= "EquipmentManager.EQUIPMENT_EXPLODE_RESULT"
EquipmentManager.GEM_MOSAIC_RESULT 						= "EquipmentManager.GEM_MOSAIC_RESULT"
EquipmentManager.GEM_UN_MOSAIC_RESULT 					= "EquipmentManager.GEM_UN_MOSAIC_RESULT"
EquipmentManager.UNLOCK_EQUIPMENT_HOLE_RESULT 			= "EquipmentManager.UNLOCK_EQUIPMENT_HOLE_RESULT"
EquipmentManager.ALL_EQUIPMENT_GEM_SOLT_NUMBER_CHANGED 	= "EquipmentManager.ALL_EQUIPMENT_GEM_SOLT_NUMBER_CHANGED"
EquipmentManager.EQUIPMENT_REFINING_RESULT 				= "EquipmentManager.EQUIPMENT_REFINING_RESULT"
EquipmentManager.EQUIPMENT_STAR_UP_RESULT 				= "EquipmentManager.ALL_EQUIPMENT_GEM_SOLT_NUMBER_CHANGED"
EquipmentManager.EQUIPMENT_PRACTICE_RESULT 				= "EquipmentManager.EQUIPMENT_PRACTICE_RESULT"

EquipmentManager.DEL_EQUIP = "EquipmentManager.DEL_EQUIP"


EquipmentManager.EQUIPMENT_TUPO_RESULT 				= "EquipmentManager.EQUIPMENT_TUPO_RESULT"
EquipmentManager.SELECT_GEM_POS 				= "EquipmentManager.SELECT_GEM_POS"
--传承
EquipmentManager.EQUIP_SMIRITI 				= "EquipmentManager.EQUIP_SMIRITI"

EquipmentManager.SortEquipmentType 		= 1
EquipmentManager.SortEquipmentQuality 	= 2

--装备附加属性的条目上限
EquipmentManager.kMaxExtraAttributeSize		= 4
--装备最高星级
EquipmentManager.kMaxStarLevel   			= 5

--宝石合成常量定义
--宝石合成低级宝石个数
EquipmentManager.kGemMergeSrcNum 	= 4
--宝石合成目标宝石个数
EquipmentManager.kGemMergeTargetNum = 2
--宝石合成目标宝石索引
EquipmentManager.kGemMergeTargetIndex = 5
--宝石合成宝石位个数
EquipmentManager.kGemMergeTotalNum  = EquipmentManager.kGemMergeSrcNum + EquipmentManager.kGemMergeTargetNum

function EquipmentManager:ctor()
	self.super.ctor(self)
	self.map = {}
	self.sortType = EquipmentManager.SortEquipmentType

	TFDirector:addProto(s2c.EQUIP_OPERATION, self, self.onReceiveEquipOperation)
	TFDirector:addProto(s2c.UNEQUIP_OPERATION, self, self.onReceiveUnequipOperation)
	TFDirector:addProto(s2c.EQUIPMENT_INTENSIFY_RESULT, self, self.onReceiveEquipmentIntensifyResult)
	TFDirector:addProto(s2c.EQUIPMENT_SELL_RESULT, self, self.onReceiveEquipmentSellResult)
	TFDirector:addProto(s2c.EQUIPMENT_EXPLODE_RESULT, self, self.onReceiveEquipmentExplodeResult)
	TFDirector:addProto(s2c.GEM_MOSAIC_RESULT, self, self.onReceiveGemMosaicResult)
	TFDirector:addProto(s2c.GEM_UN_MOSAIC_RESULT, self, self.onReceiveGemUnMosaicResult)
	TFDirector:addProto(s2c.UNLOCK_EQUIPMENT_HOLE_RESULT, self, self.onReceiveUnlockEquipmentHoleResult)
	TFDirector:addProto(s2c.ALL_EQUIPMENT_GEM_SOLT_NUMBER_CHANGED, self, self.onReceiveAllEquipmentGemSoltNumberChanged)
	TFDirector:addProto(s2c.EQUIPMENT_REFINING_RESULT, self, self.onReceiveEquipmentRefiningResult)
	TFDirector:addProto(s2c.EQUIPMENT_STAR_UP_RESULT, self, self.onReceiveEquipmentStarUpResult)
	-- 突破 
	TFDirector:addProto(s2c.REFINE_BREACH_RESULT, self, self.onReceiveEquipmentTupo)
	TFDirector:addProto(s2c.EQUIP_PRACTICE_RESULT, self, self.onReceiveEquipmentPracticeResult)
	--传承
	TFDirector:addProto(s2c.EQUIPMENT_TRANSLATE_SUCCESS, self, self.onReceiveSmritiResult)
	--传承之后信息
	TFDirector:addProto(s2c.EQUIPMENT_INFO, self, self.onReceiveEquipInfo)

	--TFDirector:addMEListener(self, "Equipment_Change", self.EquipmentChange)
--[[
	测试代码

	local CardEquipment = require('lua.gamedata.base.CardEquipment')
	local EquipmentData = ItemData:GetEquipmentByEquipType(EnumGameItemType.Equipment)
	for v in EquipmentData:iterator() do
		local equip = CardEquipment:new(v.id)
		equip.gmId = 1000000 + equip.id
		print(equip.gmId)
		equip:setLevel(10)
		self:AddEquipment(equip)
	end

	测试代码结束]]

	--add by david.dai
	--红点提示增加
	--新增物品监听
	self.newRefinStoneMark = false
	self.newGemMark = false
    self.itemAddCallBack = function (event)
    	local holdGoods = event.data[1]
        if holdGoods.itemdata.id == self:getRefinStone().id then
            self.newRefinStoneMark = true
        elseif holdGoods.itemdata.type == EnumGameItemType.Gem then
        	self.newGemMark = true
        end
    end
    TFDirector:addMEGlobalListener(BagManager.ItemAdd,self.itemAddCallBack)

    self.itemNumberChangedCallBack = function (event)
        local holdGoods = event.data[1].item
        local oldNum = event.data[1].oldNum
        if holdGoods.num <= oldNum then
        	return 
        end
        if holdGoods.itemdata.id == self:getRefinStone().id then
            self.newRefinStoneMark = true
        elseif holdGoods.itemdata.type == EnumGameItemType.Gem then
        	self.newGemMark = true
        end
    end
    TFDirector:addMEGlobalListener(BagManager.ItemChange,self.itemNumberChangedCallBack)

    self.itemDeleteCallBack = function (event)
        local holdGoods = event.data[1]
        if holdGoods.itemdata.id == self:getRefinStone().id then
            self.newRefinStoneMark = false
            self.newGemMark = false
        end
    end
    TFDirector:addMEGlobalListener(BagManager.ItemDel,self.itemDeleteCallBack)

end

function EquipmentManager:getRefinStone()
	if not self.refinStone then
		local refinStoneConstant = ConstantData:objectByID("Equip.Refining.Consume.Goods")
		if refinStoneConstant then
			self.refinStone = ItemData:objectByID(refinStoneConstant.res_id)
		end
	end
	
	return self.refinStone
end
function EquipmentManager:getPracticeStone()
	if not self.practiceStone then
		local practiceStoneConstant = ConstantData:objectByID("Equip.Remake.Extra.Consume.Goods")
		if practiceStoneConstant then
			self.practiceStone = ItemData:objectByID(practiceStoneConstant.res_id)
		end
	end
	
	return self.practiceStone
end

function EquipmentManager:getHoldRefinStone()
	if self.refinStone then
		return BagManager:getItemById(self.refinStone.id)
	end
	
	return nil
end

function EquipmentManager:getHoldPracticeStone()
	if self.practiceStone then
		return BagManager:getItemById(self.practiceStone.id)
	end
	
	return nil
end

function EquipmentManager:restart()
	self.map = {}
	self.sortType = EquipmentManager.SortEquipmentType
	for v in self:iterator() do
		v:dispose()
	end
	self:clear()
	self.newRefinStoneMark = false
	self.newGemMark = false
end
--[[--
	新增装备
	@param equipment: 装备
	@return 是否成功
]]	
function EquipmentManager:AddEquipment(equipment)
	if equipment.type == nil  or equipment.type ~= EnumGameObjectType.Equipment then
		print(equipment.name .. "AddEquipment add fail ")
		return  false
	end
	self.super.push(self, equipment)
end

local function sortlistByQuality(v1,v2)
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

local function sortlistByType(v1,v2)
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

local function sortlist(v1,v2)
	if EquipmentManager.sortType == EquipmentManager.SortEquipmentType then
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
	if EquipmentManager.sortType == EquipmentManager.SortEquipmentType then
		return sortlistByTypeAndEquipedFirst(v1,v2)
	else
		return sortlistByQualityAndEquipedFirst(v1,v2)
	end
end

--[[--
	返回指定装备类型的装备
	@param equipType: 装备类型
	@return 指定Key值的元素
]]	
function EquipmentManager:GetEquipByType(equipType)
	local EquipArray = TFArray:new()
	for v in self:iterator() do
		if equipType == nil or v.equipType == equipType or equipType == 0 then
			EquipArray:push(v)
		end
	end
	EquipArray:sort(sortlist)
	return EquipArray
end

--[[--
	返回指定装备类型的装备,是否已使用
	@param equipType: 装备类型
	@param isused 是否正在使用
	@param sortDisable 是否不排序
	@return 指定Key值的元素
]]	
function EquipmentManager:GetEquipByTypeAndUsed(equipType,isused,sortDisable)
	local EquipArray = TFArray:new()
	for v in self:iterator() do
		if equipType == nil or v.equipType == equipType or equipType == 0 then
		    if isused and v.equip and v.equip ~= 0 then
				EquipArray:push(v)
			elseif isused == false and (v.equip == nil or v.equip == 0) then
				EquipArray:push(v)
			end
		end
	end
	if not sortDisable then
		EquipArray:sort(sortlist)
	end
	return EquipArray
end

--[[--
	返回指定装备类型的装备,且排除了装备在特定角色身上的装备
	@param equipType: 装备类型
	@param roleGmIdTable: 排除的角色模板ID
	@param equipArray 存储装备数组
	@return 指定Key值的元素
]]	
function EquipmentManager:GetEquipExclude(equipType,roleTemplateIdTable,equipArray)
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
function EquipmentManager:GetEquipExcludeInWarSide(equipType)
	local roleTemplateIdTable = StrategyManager:getRoleTemplateIdTable()
	return self:GetEquipExclude(equipType,roleTemplateIdTable)
end

--[[--
	返回所有装备，并且上阵的角色身上穿着装备优先
	@param equipType: 装备类型
	@return 指定Key值的元素
]]	
function EquipmentManager:GetAllEquipInWarSideFirst(equipType)
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
function EquipmentManager:GetEquipByUsed(isused)
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
function EquipmentManager:GetOtherEquipByUsed(gmid,isused,sortDisable)
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
function EquipmentManager:getEquipByGmid(gmid)
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
function EquipmentManager:DelEquipmentByGmid(gmId)
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
			TFDirector:dispatchGlobalEventWith(EquipmentManager.DEL_EQUIP,equipType)	
			return true
		end
	end
	return false
end


--[[--
	更换装备
]]	
function EquipmentManager:onReceiveEquipOperation(event)
	hideLoading();
	--print("-------------------------EquipOperation-----------------")
	local data = event.data
	--print("EquipOperation info")
	--print(data)
	local role = CardRoleManager:getRoleByGmid(data.roleId)
	local equip = self:getEquipByGmid(data.equipment)
	if role == nil or equip == nil then 
		print("role == nil or equip == nil ------- EquipmentManager:101-----")
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
	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIP_OPERATION,{gmId = role.gmId,equip = equip}); 
	TFDirector:dispatchGlobalEventWith("EquipmentChangeEnd",{}); 
end

function EquipmentManager:onReceiveUnequipOperation(event)
	hideLoading();
	--print("-------------------------UnequipOperation-----------------")
	local data = event.data
	--print(data)
	local role = CardRoleManager:getRoleByGmid(data.roleId)
	local equip = self:getEquipByGmid(data.equipment)
	if role == nil or equip == nil then 
		print("role == nil or equip == nil ------- EquipmentManager:101-----")
		return
	end
	role:DelEquipment(equip) --本身updateFate就有计算属性@mark
	--print("-------------------- UnequipOperation   ok-----------------")
	--CardRoleManager:UpdateRoleFate()
	role:updateFate()
	TFDirector:dispatchGlobalEventWith(EquipmentManager.UNEQUIP_OPERATION,{gmId = role.gmId,equip = equip});
	TFDirector:dispatchGlobalEventWith("EquipmentChangeEnd",{});  
end

function EquipmentManager:EquipmentChange(data)
	showLoading();
	--print("-------------------- EquipmentChange   ok-----------------")
	--print(data)
	local role = CardRoleManager:getRoleById(data.roleid)
	local equip = self:getEquipByGmid(data.gmid)
	if role == nil or equip == nil  then
		print("role == nil or equip == nil -----EquipmentManager:134-------- ")
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

function EquipmentManager:unEquipmentChange(data)
	showLoading();
	--print("-------------------- EquipmentChange   ok-----------------")
	--print(data)
	local role = CardRoleManager:getRoleById(data.roleid)
	local equip = self:getEquipByGmid(data.gmid)
	if role == nil or equip == nil  then
		print("role == nil or equip == nil -----EquipmentManager:134-------- ")
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

function EquipmentManager:EquipmentIntensify(userid )
	showLoading()
	local Msg = 
	{
		userid,
	}
	TFDirector:send(c2s.EQUIPMENT_INTENSIFY,Msg)
end

function EquipmentManager:EquipmentIntensifyToTop(userid )
	showLoading()
	local Msg = 
	{
		userid,
	}
	TFDirector:send(c2s.EQUIPMENT_INTENSIFY_TO_TOP,Msg)
end

function EquipmentManager:onReceiveEquipmentIntensifyResult(event )
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
			TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_INTENSIFY_RESULT, notice_data)
			TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIP_OPERATION ,{id = equip.equip,equip = equip})
		end
	end
	
end

function EquipmentManager:EquipmentSell(userid )
	showLoading()
	local Msg = 
	{
		userid,
	}
	TFDirector:send(c2s.EQUIPMENT_SELL,Msg)
end

function EquipmentManager:onReceiveEquipmentSellResult(event )
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
		TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_SELL_RESULT,data.userid)
	end
end

function EquipmentManager:EquipmentExplode(userid )
	showLoading()
	local Msg = 
	{
		userid,
	}
	TFDirector:send(c2s.EQUIPMENT_EXPLODE,Msg)
end
function EquipmentManager:onReceiveEquipmentExplodeResult(event )
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
		TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_EXPLODE_RESULT,data.userid)
	end
end

function EquipmentManager:GemMosaic(userid , id , pos )
	showLoading()
	local Msg = 
	{
		userid,
		id,
		pos,
	}
	TFDirector:send(c2s.GEM_MOSAIC,Msg)
end
function EquipmentManager:onReceiveGemMosaicResult(event )
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
		TFDirector:dispatchGlobalEventWith(EquipmentManager.GEM_MOSAIC_RESULT,data.gemchanged)
	end
end
--拆卸宝石
function EquipmentManager:GemUnMosaic(userid , pos )
	showLoading()
	local Msg = 
	{
		userid,
		pos,
	}
	TFDirector:send(c2s.GEM_UN_MOSAIC,Msg)
end
function EquipmentManager:onReceiveGemUnMosaicResult(event )
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
		TFDirector:dispatchGlobalEventWith(EquipmentManager.GEM_UN_MOSAIC_RESULT,{gemid = gemid , userid = data.userid})
	end
end
--宝石孔花钱解锁
function EquipmentManager:UnlockEquipmentHole(userid)
	showLoading()
	local Msg = 
	{
		userid,
	}
	TFDirector:send(c2s.UNLOCK_EQUIPMENT_HOLE,Msg)
end
function EquipmentManager:onReceiveUnlockEquipmentHoleResult(event )
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
		TFDirector:dispatchGlobalEventWith(EquipmentManager.UNLOCK_EQUIPMENT_HOLE_RESULT,equip.maxGem)
	end
end
function EquipmentManager:onReceiveAllEquipmentGemSoltNumberChanged(event )
	hideLoading();
-- //code = 0x1055
-- //所有角色持有装备宝石孔更变
-- message AllEquipmentGemSoltNumberChanged{
-- 	required int32 max = 1; //默认开放的宝石孔个数
-- }
	local data = event.data

	for v in self:iterator() do
		v.maxGem = data.max
		--TFDirector:dispatchGlobalEventWith(EquipmentManager.UNLOCK_EQUIPMENT_HOLE_RESULT,equip.maxGem)
	end
end


--装备精炼
function EquipmentManager:EquipmentRefining(userid , lockArray,isten)
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
function EquipmentManager:EquipPractice(userid , lockArray)
	showLoading()
	local Msg = 
	{
		userid,
		lockArray,
	}
	TFDirector:send(c2s.EQUIP_PRACTICE,Msg)
end


function EquipmentManager:onReceiveEquipmentRefiningResult(event )
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

	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_REFINING_RESULT,notice_data)
end


function EquipmentManager:onReceiveEquipmentPracticeResult(event )
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

	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_PRACTICE_RESULT,notice_data)
end

--装备突破
function EquipmentManager:EquipmentTupo(userid)
	showLoading()
	local Msg = 
	{
		userid,
	}
	TFDirector:send(c2s.REQUEST_REFINE_BREACH, Msg)
end

function EquipmentManager:onReceiveEquipmentTupo(event)
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

	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_TUPO_RESULT,event.data)

end

--装备升星
function EquipmentManager:EquipmentStarUp(userid , eat_equipmentList,stuffList)
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

function EquipmentManager:onReceiveEquipmentStarUpResult(event )
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
		TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_STAR_UP_RESULT,{gmid = equip.gmid , success = true})
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
		TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIPMENT_STAR_UP_RESULT,{gmid = equip.gmid , success = false})
	end
end

--装备突破
function EquipmentManager:EquipSmriti(srcId,targetId)
	showLoading()
	local Msg = 
	{
		srcId,
		targetId
	}
	TFDirector:send(c2s.EQUIPMENT_TRANSLATE_REQUEST,Msg)
end

function EquipmentManager:onReceiveSmritiResult(event)
	hideLoading()
	TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIP_SMIRITI,event)
end

function EquipmentManager:onReceiveEquipInfo(event)
	local data = event.data
	print("gem--------------------------------------------star")
	BagManager:ChangeEquip(data)
	print("gem--------------------------------------------end")
	--TFDirector:dispatchGlobalEventWith(EquipmentManager.EQUIP_SMIRITI,event)
end


function EquipmentManager:OpenSmithyMainLaye()
	local teamLev = MainPlayer:getLevel()
    local openLev = PlayerGuideManager:getEquipOpenLevel()
    if teamLev < openLev then
        -- toastMessage("团队等级达到"..openLev.."级开启")
        toastMessage(stringUtils.format(localizable.common_function_openlevel, openLev))
        return
    end
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.smithy.SmithyMainLayer");
    layer.selectedTab = nil;
    AlertManager:show();      
end

function EquipmentManager:OpenEquipmentIntensify(gmId)
	local equip = self:getEquipByGmid(gmId)
	local layer = require("lua.logic.smithy.SmithyIntensify"):new(equip)
    AlertManager:addLayer(layer)
    AlertManager:show()
end

function EquipmentManager:OpenOperationLayer(gmId)
	local equip = self:getEquipByGmid(gmId)
	local layer = require("lua.logic.smithy.SmithyBaseLayer"):new(equip)
    AlertManager:addLayer(layer)
    AlertManager:show()
    return layer
end

function EquipmentManager:OpenEquipmentStarUp(gmId)
	local equip = self:getEquipByGmid(gmId)
    local layer = require("lua.logic.smithy.EquipmentStarUp"):new(equip.gmId)
    AlertManager:addLayer(layer)
    AlertManager:show()
end

function EquipmentManager:OpenEquipmentRefining(gmId)
	local equip = self:getEquipByGmid(gmId)
	if equip.quality <= 1 then
		-- toastMessage("丁级装备无法洗炼")
		toastMessage(localizable.EquipmentManager_equip_wufaxilian)
	end
    local layer = require("lua.logic.smithy.EquipmentRefining"):new(equip.gmId)
    AlertManager:addLayer(layer)
    AlertManager:show()
end

function EquipmentManager:OpenGemMosaicLayer(gmId)
	local equip = self:getEquipByGmid(gmId)
    local layer = require("lua.logic.smithy.SmithyGem"):new(equip)
    AlertManager:addLayer(layer)
    AlertManager:show()
end

function EquipmentManager:OpenGemBuildLayer()
    local layer = require("lua.logic.smithy.SmithyGemBuild"):new()
    AlertManager:addLayer(layer)
    AlertManager:show()
end

--功能开放逻辑
EquipmentManager.Function_Intensify = 101
EquipmentManager.Function_StarUp = 102
EquipmentManager.Function_Parctice = 107
EquipmentManager.Function_Refining = 103
EquipmentManager.Function_Gem_Mount = 104
EquipmentManager.Function_Gem_Merge = 105
EquipmentManager.Function_Recast = 108
--[[
验证装备强化是否开放
@return 如果装备强化开放返回true，否则返回false
]]
function EquipmentManager:isIntensifyEnable()
	local configure = FunctionOpenConfigure:objectByID(EquipmentManager.Function_Intensify)
	if configure then
		return configure.level <= MainPlayer:getLevel()
	end
	return true
end

--[[
验证装备升星是否开放
@return 如果装备升星开放返回true，否则返回false
]]
function EquipmentManager:isStarUpEnable()
	local configure = FunctionOpenConfigure:objectByID(EquipmentManager.Function_StarUp)
	if configure then
		return configure.level <= MainPlayer:getLevel()
	end
	return true
end


--[[
验证装备精炼是否开放
@return 如果装备精炼开放返回true，否则返回false
]]
function EquipmentManager:isRefiningEnable()
	local configure = FunctionOpenConfigure:objectByID(EquipmentManager.Function_Refining)
	if configure then
		return configure.level <= MainPlayer:getLevel()
	end
	return true
end

--[[
验证宝石镶嵌是否开放
@return 如果宝石镶嵌开放返回true，否则返回false
]]
function EquipmentManager:isGemMountEnable()
	local configure = FunctionOpenConfigure:objectByID(EquipmentManager.Function_Gem_Mount)
	if configure then
		return configure.level <= MainPlayer:getLevel()
	end
	return true
end

--[[
验证宝石合成是否开放
@return 如果宝石合成开放返回true，否则返回false
]]
function EquipmentManager:isGemMergeEnable()
	local configure = FunctionOpenConfigure:objectByID(EquipmentManager.Function_Gem_Merge)
	if configure then
		return configure.level <= MainPlayer:getLevel()
	end
	return true
end

--红点判断逻辑
EquipmentManager.gemEnoughRPM = EnumServiceType.GOODS * 256 + 128
EquipmentManager.newRefinStoneRPM = EnumServiceType.GOODS * 256 + 129
EquipmentManager.newGemRPM = EnumServiceType.GOODS * 256 + 130

--需求：当有足够数量的低级宝石时，可合成高级宝石，在该宝石图标、宝石合成标签、主界面铁匠铺图标右上角标注红点；
--      当玩家点击合成该宝石，该宝石合成完毕，其数量不足以继续合成下一级宝石时，该宝石图标右上角红点消失；
--该宝石是否可以合成
function EquipmentManager:isGemEnough(id)
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
function EquipmentManager:isHaveGemEnough()
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
function EquipmentManager:isHaveNewRefinStone()
	local enabled = RedPointManager:isRedPointEnabled(EquipmentManager.newRefinStoneRPM)
	if enabled then
		return true
	end
	if self.newRefinStoneMark then
		RedPointManager:setRedPointEnabled(EquipmentManager.newRefinStoneRPM,true)
	end
	return self.newRefinStoneMark
end

--进入精炼界面，红点消失
function EquipmentManager:onIntoRefinLayer()
	--服务端记录，并推送前端
	self.newRefinStoneMark = false
	RedPointManager:setRedPointEnabled(EquipmentManager.newRefinStoneRPM,false)
end

--是否有新的宝石
function EquipmentManager:isHaveNewGem()
	local enabled = RedPointManager:isRedPointEnabled(EquipmentManager.newGemRPM)
	if enabled then
		return true
	end
	if self.newGemMark then
		RedPointManager:setRedPointEnabled(EquipmentManager.newGemRPM,true)
	end
	return self.newGemMark
end

--进入镶嵌界面，红点消失
function EquipmentManager:onIntoGemLayer()
	--服务端记录，并推送前端
	self.newGemMark = false
	RedPointManager:setRedPointEnabled(EquipmentManager.newGemRPM,false)
end

--直接进入装备强化界面
function EquipmentManager:openSmithyLayer(equipGMId,equipList,equipType,allList,completeOpenCallback)
	local teamLev = MainPlayer:getLevel()
    local openLev = PlayerGuideManager:getEquipOpenLevel()
    if teamLev < openLev then
        -- toastMessage("团队等级达到"..openLev.."级开启")

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

function EquipmentManager:showEquipDetailsDialog(equipGMId,equipList,equipType,allList)
    -- local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.smithy.EquipDetailsDialog",AlertManager.BLOCK_AND_GRAY_CLOSE);
    -- layer:loadData(equipGMId,equipList,equipType,allList)
    -- AlertManager:show();   
    self:openSmithyLayer(equipGMId,equipList,equipType,allList)
end

function EquipmentManager:getTupoStone()
	if not self.tupoStone then
		local tupoStoneConstant = ConstantData:objectByID("Equip.Tupo.Consume.Goods")
		if tupoStoneConstant then
			self.tupoStone = ItemData:objectByID(tupoStoneConstant.res_id)
		end
	end
	
	return self.tupoStone
end

function EquipmentManager:getHoldTupoStone()
	if self.tupoStone then
		return BagManager:getItemById(self.tupoStone.id)
	end
	
	return nil
end

function EquipmentManager:getEquipListByID(id, except_gmid)
	local EquipArray = TFArray:new()
	for v in self:iterator() do
		if (v.id == id and v.gmId ~= except_gmid) and (v.equip == nil or v.equip == 0) then
			EquipArray:push(v)
		end
	end
	-- local function getKindNum( v )
	-- 	local kindNum = 0
	-- 	if v.level ~= 0 then
	-- 		kindNum = kindNum + 1
	-- 	end
	-- 	if v.star ~= 0 then
	-- 		kindNum = kindNum + 1
	-- 	end
	-- 	if self:checkIsJinglian(v) ~= 0 then
	-- 		kindNum = kindNum + 1
	-- 	end
	-- 	if v.recastPercent ~= 0 then
	-- 		kindNum = kindNum + 1
	-- 	end
	-- 	return kindNum
	-- end
	-- local function sortByRecastPercent(v1,v2)
	-- 	return v1.recastPercent > v1.recastPercent
	-- end

	-- local function sortByRefineLevel(v1,v2)
	-- 	local level1 = self:checkIsJinglian(v1)
	-- 	local level2 = self:checkIsJinglian(v2)
	-- 	if level1 == level2 then
	-- 		return sortByRecastPercent(v1,v2)
	-- 	else
	-- 		return level1 > level2
	-- 	end
	-- end
	-- local function sortByStar(v1,v2)
	-- 	if v1.star == v2.star then
	-- 		return sortByRefineLevel(v1,v2)
	-- 	else
	-- 		return v1.star > v2.star
	-- 	end
	-- end
	-- local function sortByLevel(v1,v2)
	-- 	if v1.level == v2.level then
	-- 		return sortByStar(v1,v2)
	-- 	else
	-- 		return v1.level > v2.level
	-- 	end
	-- end

	-- local function sortByKindNum(v1,v2)
	-- 	local kind1 = getKindNum(v1)
	-- 	local kind2 = getKindNum(v2)
	-- 	if kind1 == kind2 then
	-- 		return sortByLevel(v1,v2)
	-- 	else
	-- 		return kind1 < kind2
	-- 	end
	-- end

	local function sortByPower(v1,v2)
		return v1.power < v2.power		
	end

	EquipArray:sort(sortByPower)
	return EquipArray
end
--重铸请求
function EquipmentManager:requestRecastEquip(Msg)
	showLoading()	
	print('requestRecastEquip = ',Msg)
	TFDirector:send(c2s.EQUIPMENT_RECAST,Msg)
end

--是否存在精炼
function EquipmentManager:checkIsJinglian(equip)
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

function EquipmentManager:BindEffectOnEquip(panel, equip)
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

function EquipmentManager:getExtraPercentByRecast( recastInfo )
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
return EquipmentManager:new()