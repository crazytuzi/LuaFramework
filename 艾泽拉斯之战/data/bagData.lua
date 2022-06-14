local bagData = class("bagData")



function bagData:ctor()
	self.items = {}	
			
	for	i = enum.BAG_TYPE.BAG_TYPE_BAG, enum.BAG_TYPE.BAG_TYPE_COUNT - 1 do
		self.items[i] = {}		
	end
	
end 	

function bagData:clear()		
	for	i = enum.BAG_TYPE.BAG_TYPE_BAG, enum.BAG_TYPE.BAG_TYPE_COUNT - 1 do
		
		for k,v in pairs(self.items[i]) do
			if v then
				itemManager.destroyItem(v:getIndex());
			end
		end
		
		self.items[i] = {}		
	end
end

function bagData:getVecItemNums(vec_type)
	if(vec_type >= enum.BAG_TYPE.BAG_TYPE_COUNT or vec_type < enum.BAG_TYPE.BAG_TYPE_BAG )	then
		error("bagData:getVecItemNums vec_type.."..vec_type)
		return 0
	end
	return table.nums(self.items[vec_type])
end

function bagData:getItemNums(vec_type,tableId)
	if(vec_type >= enum.BAG_TYPE.BAG_TYPE_COUNT or vec_type < enum.BAG_TYPE.BAG_TYPE_BAG )	then
		error("bagData:getItemNums vec_type.."..vec_type)
		return 0
	end
	local num = 0
	for i,v in pairs(self.items[vec_type])do
		if(v and v:getId() ==tableId )then
			num = num + v:getCount()
		end
		
	end
	return num
end
 
function bagData:getItem(pos,vec_type)	
	
	if(vec_type >= enum.BAG_TYPE.BAG_TYPE_COUNT or vec_type < enum.BAG_TYPE.BAG_TYPE_BAG )	then
		error("bagData:getItem vec_type.."..vec_type)
		return nil
	end
	
	local vec = self.items[vec_type]	
	return vec[pos]
end 		

function bagData:getVec(vec_type)
		return self.items[vec_type]	
end	


function bagData:OnaddItemEnd()
		 
	local nums = self:getVecItemNums(enum.BAG_TYPE.BAG_TYPE_BAG)
	local vec =  self:getVec(enum.BAG_TYPE.BAG_TYPE_BAG)
	
	local t = table.keys(vec)
	local itemIndex = 0
	self.tmp ={}
	local filter = enum.ITEM_TYPE.ITEM_TYPE_DEBRIS
	
	for i = 1,nums do	
	 	local item = self:getItem(t[i],enum.BAG_TYPE.BAG_TYPE_BAG)					
	 	if item  and  (item:filter(filter) )then	
			local config = dataConfig.configs.debrisConfig[item:getSubId()]
			if(config and item:getCount() >= config.needCount  )then
				table.insert(self.tmp,item:getPos()) 
			end			
		end
	end
	
	for i,v in ipairs (self.tmp) do
		sendUseItem(enum.USE_ITEM_OPCODE.USE_ITEM_OPCODE_CARFTED, v)
		return
	end
 
end	

function bagData:addItem(item,pos,vec_type,delOld)
	
	if(vec_type >= enum.BAG_TYPE.BAG_TYPE_COUNT or vec_type < enum.BAG_TYPE.BAG_TYPE_BAG )	then
		error("bagData:addItem vec_type.."..vec_type)
		return 
	end	
	if(delOld)then
		self:delItem(pos,vec_type)
	end
	local vec = self.items[vec_type]
	vec[pos] = item	
	
	if(item)then
		item:setPos(pos)
		item:setVec(vec_type)	
	end
end 
function bagData:delItemWithPositions(position,vec_type)
		for i,v in ipairs(position)	do
			self:delItem(v,vec_type)
		end
end	
 
function bagData:delItem(pos,vec_type)
	if(vec_type >= enum.BAG_TYPE.BAG_TYPE_COUNT or vec_type < enum.BAG_TYPE.BAG_TYPE_BAG )	then
		error("bagData:delItem vec_type.."..vec_type)
		return 
	end	
	local vec = self.items[vec_type]
	local item = vec[pos]
	if(item)then		
		item:setPos(-1)
		item:setVec(-1)		
		itemManager.destroyItem(item:getIndex())
	end
	vec[pos] = 	nil
end 	

--- 是否存在比当前装备基础属性1 更强的装备在玩家背包里

--[[
function bagData:hasEquippedStronger(itemEquip,point)
	
	local equipAttValue = 0
	local hasFind = false
	
	if(itemEquip)then
		local att = itemEquip:getFirstAttr()
		if(not att)then
			att = itemEquip:getSecondAttr()
		end
		if(att)then
			equipAttValue = att.attvalue
		end
	end
	local kingLevel = dataManager.playerData:getLevel()
	for i,v in pairs(self.items[enum.BAG_TYPE.BAG_TYPE_BAG])do
		if(v and v:isEquip() and v:getEquipPoint() == point and  v:getUseLevel() <= kingLevel )then
			 if( v:getFirstAttr()) then
				hasFind = v:getFirstAttr().attvalue > equipAttValue
             elseif( v:getSecondAttr()) then
			 	hasFind =  v:getSecondAttr().attvalue > equipAttValue		
			end
			if(hasFind)then
				return true
			end
		end			
	end
	return false
end
]]--

function bagData:hasEquippedStronger(itemEquip,point)
	local equipAttValue1,equipAttValue2 = 0,0
	local hasFind = false
	
	if(itemEquip)then
		equipAttValue1,equipAttValue2 = itemEquip:getFeatureMaxEquipAtt()
	end
	local kingLevel = dataManager.playerData:getLevel()
	for i,v in pairs(self.items[enum.BAG_TYPE.BAG_TYPE_BAG])do
		if(v and v:isEquip() and v:getEquipPoint() == point and  v:getUseLevel() <= kingLevel )then
		
			local 	_equipAttValue1,_equipAttValue2 = v:getFeatureMaxEquipAtt()
			 if( v:getFirstAttr()) then
				hasFind = _equipAttValue1 > equipAttValue1
             elseif( v:getSecondAttr()) then
			 	hasFind =  _equipAttValue2 > equipAttValue2		
			end
			if(hasFind)then
				return true
			end
		end			
	end
	return false
end

-- 排序装备list
function bagData:getEquipSortListByEquipPoint(equipPoint)
		
	-- 把对应的位置上装备筛选出来		
	
	local nums = dataManager.bagData:getVecItemNums(enum.BAG_TYPE.BAG_TYPE_BAG)	
	local vec = dataManager.bagData:getVec(enum.BAG_TYPE.BAG_TYPE_BAG)
	local t = table.keys(vec)
			
	local __items = {}
	for i = 1 , nums  do	
	 	local item = dataManager.bagData:getItem(t[i],enum.BAG_TYPE.BAG_TYPE_BAG)			
	 	if item and item:isEquip() and equipPoint == item:getEquipPoint() then	
			table.insert(__items,item)
		end
	end		
	
  function sortAttEquipAsc(a,b)	
	
		local 	equipAttValue1,equipAttValue2 = a:getFeatureMaxEquipAtt()
		local 	_equipAttValue1,_equipAttValue2 = b:getFeatureMaxEquipAtt()
		
		
		if(equipAttValue1 == _equipAttValue1)	then
			return a:getEnhanceLevel() > b:getEnhanceLevel()
		end
 
		return equipAttValue1 > _equipAttValue1
		
	end
	
	-- 按照第一条属性和第二条属性和排序 
	table.sort(__items, sortAttEquipAsc);
	
	return __items;
end

-- 是否有紫装满强化
-- star 表示品质
function bagData:hasMaxEnhancedEquipByStar(star, level)
	
	for bagType=enum.BAG_TYPE.BAG_TYPE_BAG, enum.BAG_TYPE.BAG_TYPE_SHIP_6 do
	
		local nums = dataManager.bagData:getVecItemNums(bagType);	
		local vec = dataManager.bagData:getVec(bagType);
		
		local t = table.keys(vec);
				
		local __items = {}
		for i = 1 , nums  do	
		 	
		 	local item = dataManager.bagData:getItem(t[i],bagType);
		 	
		 	if item and item:isEquip() and item:getStar() == star and item:getEnhanceLevel() >= level then	
				return true;
			end
			
		end
			
	end
	
	return false;
end

function bagData:getItemWithTableId(vec_type,tableId)
	if(vec_type >= enum.BAG_TYPE.BAG_TYPE_COUNT or vec_type < enum.BAG_TYPE.BAG_TYPE_BAG )	then
		error("bagData:getItemNums vec_type.."..vec_type)
		return 0
	end
	 
	for i,v in pairs(self.items[vec_type])do
		if(v and v:getId() ==tableId )then
			return v
		end
		
	end
	return nil
end

return bagData