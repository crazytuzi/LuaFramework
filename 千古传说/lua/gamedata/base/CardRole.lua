--[[
******游戏数据角色牌类*******

	-- by Stephen.tao
	-- 2013/11/27

    -- by haidong.gan
	-- 2014/4/10
]]

local GameObject    = require('lua.gamedata.base.GameObject')
local RoleEquipment = require('lua.gamedata.base.RoleEquipment')

local GameAttributeData = require('lua.gamedata.base.GameAttributeData')
local RoleEffectExtraData = require('lua.gamedata.base.RoleEffectExtraData')

local CardRole = class("CardRole",GameObject)




function CardRole:ctor( Data )
	self.super.ctor(self)
	self:init(Data)

	self.fightTypePos = {}
end

function CardRole:init( Data )
	self.Type 			= EnumGameObjectType.Role	--类型		//1为武将卡
	self.gmId			= 0 						--服务器唯一id
	self.level 			= 0							--等级
	self.pos			= 0							--位置
	self.curExp 		= 0 						--当前经验
	self.maxExp 		= 0 						--总经验
	self.upHp 			= 0 						--每升一级加血量
	self.head       	= 0 						--头像
	self.skillId		= 0 						--装备的技能id
	self.getTime 		= 0 						-- 获得时间
	self.power 			= 0
	self.skillLevel 	= 1
	self.starlevel		= 0 						--星级
	self.starexp 		= 0							--星级经验
	-- self.starexpMax		= 0							--星级经验
	self.otherPlayerCard= false
	self.baseAttribute 	= GameAttributeData:new() 				
	self.attributeUp 	= GameAttributeData:new() 				
	self.attribute 		= GameAttributeData:new() 				
	self.equipAttribute	= GameAttributeData:new()				
	self.fateAttribute	= GameAttributeData:new()				
	self.fateAttributeForQihe = GameAttributeData:new()
	self.totalAttribute	= GameAttributeData:new()				
	self.totalAttributeForQihe	= GameAttributeData:new()
	self.attrCoefficient= GameAttributeData:new()
	self.skillAttribute	= GameAttributeData:new()
	self.martialAttribute = GameAttributeData:new()
	self.starupAttribute = GameAttributeData:new()
	self.factionPracticeAttribute = GameAttributeData:new()
	self.qiheAttribute = GameAttributeData:new()	--契合属性
	self.monthAttribute = GameAttributeData:new()	--契合属性
	self.skyBookAttribute = GameAttributeData:new()	--契合属性

	self.qimenAttribute = GameAttributeData:new()	--奇门属性
	self.qimenAttrTable = {}
	self.qimenTeamAttrTable = {}
	self.qimenPower = 0

	self.lianTiAttribute = GameAttributeData:new()	--炼体属性
	self.lianTiAttrTable = {}

	self.totalAttributeByType = {}
	self.fateStatesByType = {}

	self.factionPractice = {}

	self.effectExtraAttribute = RoleEffectExtraData:new(self)
	self.effectExtraAttribute:restart()
	self.beEffectExtraAttribute = RoleEffectExtraData:new(self)
	self.beEffectExtraAttribute:restart()
	self.immuneAttribute = RoleEffectExtraData:new(self) 	
	self.immuneAttribute:restart()
	-- self.starLevelAttributeTable	= {}
	-- self.starLevelPercentTable = {}
	
	self.acupointList 	= {}

	self.bookAttrAdd 	= {}
	self.acupointAttrAdd= {}
	self.equipment 		= RoleEquipment:new()		--装备
	self.fateMap 		= {}
	
	self:initConfig( Data ,true)
	-- <--------------add by king-
	self.blood_pos			= 0
	self.blood_maxHp		= 0
	self.blood_curHp		= 0
	self.blood_tag			= 0
	---->------------------end----
	--self:setLevel(1)

	--武学列表，装备武学的栏目
	self.martialList 		= {}
	self.martialLevel 		= 1							--武学等级，角色默认1级

	--added by wuqi
	self.bible = nil
	self.LianTiData = {
		{acupoint = 1,level = 0,quality = 0,isOpen = true},
		{acupoint = 2,level = 0,quality = 0,isOpen = false},
		{acupoint = 3,level = 0,quality = 0,isOpen = false},
		{acupoint = 4,level = 0,quality = 0,isOpen = false},
		{acupoint = 5,level = 0,quality = 0,isOpen = false}
	}
end


function CardRole:initConfig( role_id ,isInit)
	local roleConfig = RoleData:objectByID(role_id)
	if(roleConfig == nil) then
		toastMessage("角色获取为空(CardroleConfig:49)-"..role_id)
		return
	end
	self.id 				= roleConfig.id 
	self.name  				= roleConfig.name
	if isInit then
		self.quality			= roleConfig.quality					--品质
	end
	-- self.textrueName		= roleConfig:getImagePath()				--全身像
	self.image 				= roleConfig.image
	self.bigTextrueName		= roleConfig:getBigImagePath()				--全身像
	self.head 				= roleConfig:getHeadPath()				--头像
	self.icon 				= roleConfig:getIconPath()				--头像
	self.describe1			= roleConfig.description				--描述
	self.provide_exp			= roleConfig.provide_exp	
	self.soul_card_id			= roleConfig.soul_card_id	
	self.merge_card_num			= roleConfig.merge_card_num	
	self.upstar_need_soul_num_arr	= string.split(roleConfig.upstar_need_soul_num,',')			--分解"，"
	self.maxStar = roleConfig.max_star_level

	--quanhuan 2015-10-10 10:25:09
	self.upstar_need_soul_num_list = RoleTalentData:GetRoleStarInfoByRoleId( self.id )
	
	self.spellLevelIdList	= {}
	self.leadingRoleSpellList	= {}

	self.spellInfoList				= roleConfig:getSpellInfoList();
	self.leadingSpellInfoConfigList	= roleConfig:getLeadingSpellInfoConfigList();
	self.leadingSpellInfoList	    = roleConfig:getLeadingSpellInfoList();

	self.price				= 100 									--身价
	self.skillId			= roleConfig.skill
	self.outlineArr			= roleConfig:getOutline()
	self.outline			= roleConfig.outline

	self.baseAttribute:init(roleConfig.attribute)
	self.attributeUp:init(roleConfig.level_up)

	self.effectExtraAttribute:initBaseAttribute(roleConfig.effect_extra)
	self.beEffectExtraAttribute:initBaseAttribute(roleConfig.be_effect_extra)
	self.immuneAttribute:initBaseAttribute(roleConfig.immune)

	self.upHp 				= roleConfig.lv_maxhp
	self.isMainPlayer 		= ProtagonistData:IsMainPlayer( self.id )
end

function CardRole:dispose()
	self.gmId		= nil 								--服务器唯一id
	self.level 		= nil								--等级

	self.pos		= nil								--位置
	self.curExp 	= nil 								--当前经验
	self.maxExp 	= nil 								--总经验
	self.getTime 	= nil 		  						-- 获得时间
	self.upHp  		= nil
	self.head  		= nil
	self.baseAttribute 		= nil
	self.attributeUp 		= nil
	self.attribute 			= nil 						--基本属性
	self.fateAttribute		= nil						--缘分属性
	self.fateAttributeForQihe		= nil						--缘分属性
	self.totalAttribute		= nil						--总属性
	self.totalAttributeForQihe		= nil						--总属性
	self.skyBookAttribute		= nil						--总属性
	-- self.starLevelAttributeTable = nil						--升星属性加成
	-- self.starLevelPercentTable = nil
	self.starupAttribute	= nil
	self.attrCoefficient 	= nil
	self.equipment 			= nil 						--装备
	self.skillId			= nil 						--装备的技能id
	self.equipAttribute		= nil
	self.power 				= nil
	self.skillLevel 		= nil
	self.acupointList		= nil
	self.otherPlayerCard	= nil
	self.bookAttrAdd 		= nil
	self.acupointAttrAdd	= nil
	self.starlevel			= nil
	self.starexp 			= nil
	self.fateMap 			= nil
	self.martialList		= nil
	self.martialAttribute 	= nil
	self.factionPracticeAttribute 	= nil
	self.immuneAttribute 	= nil
	self.effectExtraAttribute 	= nil
	self.beEffectExtraAttribute 	= nil
	self.lianTiAttribute = nil
	self.lianTiAttrTable = {}
	self.totalAttributeByType = nil
	self.fateStatesByType = nil
	self.fateMap = {}
	self.super.dispose(self)
	TFDirector:unRequire('lua.gamedata.base.GameObject')
	TFDirector:unRequire('lua.table.RoleData')
end

function CardRole:setPos(pos)
	if pos == nil then
		pos = 0
	end
	
	self.pos = pos
end

function CardRole:setSpellLevelIdList(spellLevelIdList)
	self.spellLevelIdList	= spellLevelIdList;
	self:updateSkillAttr();
end
function CardRole:setLeadingRoleSpellList(leadingRoleSpellList)
	self.leadingRoleSpellList = leadingRoleSpellList
end

function CardRole:getEquipment()
	return self.equipment
end

function CardRole:getNameColor()
	return GetColorByQuality(self.quality)
end

function CardRole:getEquipmentByIndex(index)
	return self.equipment:GetEquipByType(index)
end

--added by wuqi
--test
--[[
function CardRole:getSkyBook()
	local book  = SkyBookManager:getItemByInstanceId(1)
	book.equip = self.id
	return book
end
]]

function CardRole:setLevel(level)
	if self.level == level then
		return
	end

	self.level = level
	self.maxExp = LevelData:getMaxRoleExp(level)
	--self:refreshRoleBaseAttr()
	self:updateTotalAttr()

	if self.effectExtraAttribute:isNeedUpdateByLevelUp() then
		self.effectExtraAttribute:updateAttribute()
	end
	if self.immuneAttribute:isNeedUpdateByLevelUp() then
		self.immuneAttribute:updateAttribute()
	end
	if self.beEffectExtraAttribute:isNeedUpdateByLevelUp() then
		self.beEffectExtraAttribute:updateAttribute()
	end
end

function CardRole:getTotalExp()
	local exp = self.curExp
	for i=1,self.level - 1 do
		exp = exp + LevelData:getMaxRoleExp(i)
	end
	return exp
end

function CardRole:refreshRoleBaseAttr()
	local function cmp( attr , index ,tbl)
		local attributeUp = tbl.attributeUp:getAttribute()
		local temp = attributeUp[index] or 0
		local martialAdd = 0
		if tbl.martial and tbl.martial[index] then
			martialAdd = tbl.martial[index]
		end
		local num = math.floor((attr + temp * tbl.trainItem.lv_up_mutil * (tbl.level + tbl.trainItem.extra_lv))  * tbl.trainItem.streng_then + martialAdd)
		return math.floor(num)
	end
	self.attribute:clear()

	-- local roleConfig = RoleData:objectByID(self.id)
	-- if roleConfig == nil then
	-- 	toastMessage("角色获取为空(CardroleConfig:49) - ".. self.id)
	-- 	return
	-- end

	--print("CARD ROLE : ",roleConfig.quality,self.quality)
	local trainItem = RoleTrainData:getRoleTrainByQuality(self.quality,self.starlevel)
	local martialRole = MartialRoleConfigure:findByRoleIdAndMartialLevel(self.id,self.martialLevel -1)
	local martialAdd = nil
	if martialRole then
		martialAdd = martialRole:getAttributeTable()
	end
	--if self.id == 77 then
	--	print("CardRole:refreshRoleBaseAttr() : ",self.quality,self.startlevel,trainItem)
	--end
	self.attribute:setAttByMath(self.baseAttribute,cmp,{level = (self.level -1),attributeUp = self.attributeUp,trainItem = trainItem,martial = martialAdd})

	-- --添加天赋属性Attribute 固定值
	-- for k,v in pairs(self.starLevelAttributeTable) do
	-- 	self.attribute:addAttr(k,v)
	-- end

	-- --添加天赋属性Attribute 百分比
	-- for k,v in pairs(self.starLevelPercentTable) do
	-- 	local attr_index = k-17
	-- 	local base_value = self.attribute:getAttributeByIndex(attr_index)
	-- 	local curr_value = math.floor((v)/10000*base_value)
	-- 	self.attribute:addAttr(attr_index,curr_value)
	-- end
end

function CardRole:updateTotalAttr()
	if self.otherPlayerCard then
		return
	end
	if CommonManager:checkLoginCompleteState() == false then
		return
	end
	self.totalAttribute:clear()
	self.totalAttributeForQihe:clear()

	self:refreshRoleBaseAttr()
	self.totalAttribute:clone(self.attribute)


	-- print(self.name.."------------------self.totalAttribute 11111 ->",self.totalAttribute:displayString())
	self.totalAttribute:setAddAttData(self.martialAttribute)
	--if self.id == 77 then
	--	print("裸体【等级+放大倍数】 ->",self.attribute:displayString())
	--end
	
	--if self.id == 77 then
	--	print("+缘分 ->",self.totalAttribute:displayString())
	--end
	for k,v in pairs(self.bookAttrAdd) do
		self.totalAttribute:addAttr(k,v)
	end
	
	for k,v in pairs(self.acupointAttrAdd) do
		self.totalAttribute:addAttr(k,v)
		--print("经脉 ",k,v)
	end
	-- print(self.name.."------------------self.totalAttribute 222 ->",self.totalAttribute:displayString())
	--奇门属性加成
	self.totalAttribute:setAddAttData(self.qimenAttribute)

	--if self.id == 77 then
	--	print("+经脉 ->",self.totalAttribute:displayString())
	--end
	--print("装备属性尼玛逼 ： ",self.equipAttribute:displayString())
	self.totalAttribute:setAddAttData(self.equipAttribute)
	--if self.id == 77 then
	--	print("+装备 ->",self.totalAttribute:displayString())
	--end
	self.totalAttribute:setAddAttData(self.skillAttribute)
	self.totalAttribute:setAddAttData(self.skyBookAttribute)
	--if self.id == 77 then
	--	print("+被动技能 ->",self.totalAttribute:displayString())
	--end
	--天赋属性
	self.totalAttribute:setAddAttData(self.starupAttribute)
	self.totalAttribute:setAddAttData(self.factionPracticeAttribute)
	self.totalAttribute:setAddAttData(self.lianTiAttribute)
	
	--契合所加属性
	self.totalAttribute:refreshBypercent()

	self.totalAttributeForQihe:clone(self.totalAttribute)

	self.totalAttribute:setAddAttData(self.qiheAttribute)
	
	self.totalAttribute:setAddAttData(self.fateAttribute)
	self.totalAttribute:refreshBypercent()

	-- self.totalAttributeForQihe:setAddAttData(self.qiheAttribute)
	-- self.totalAttributeForQihe:setAddAttData(self.factionPracticeAttribute)
	self.totalAttributeForQihe:setAddAttData(self.fateAttributeForQihe)	
	self.totalAttributeForQihe:refreshBypercent()
	-- print(self.name.."------------------self.totalAttribute 333 ->",self.totalAttribute:displayString())
	if self.isMainPlayer then
		local vip_add = VipRuleManager:addMainPlayerAttr()
		if vip_add ~= 0 then
			self.totalAttribute:addAttr(EnumAttributeType.Force,vip_add)
			self.totalAttribute:addAttr(EnumAttributeType.Magic,vip_add)

			self.totalAttributeForQihe:addAttr(EnumAttributeType.Force,vip_add)
			self.totalAttributeForQihe:addAttr(EnumAttributeType.Magic,vip_add)
		end
	end

	-- 大月卡增加额外属性-- 主角：武力、内力 各500 +level*5
	local bOwnMonth = MonthCardManager:isExistMonthCard(MonthCardManager.CARD_TYPE_2)
	if bOwnMonth == true then
		if self.isMainPlayer then
			self.monthAttribute:clear()
			self:updateMonthCard()
			self.totalAttribute:setAddAttData(self.monthAttribute)	
			self.totalAttributeForQihe:setAddAttData(self.monthAttribute)	
			-- local level = MainPlayer:getLevel()
			-- local wuliPower = 500 + 5 * level
			-- self.totalAttribute:addAttr(EnumAttributeType.Force, wuliPower)
			-- local neiliPower = 500 + 5 * level
			-- self.totalAttribute:addAttr(EnumAttributeType.Magic, neiliPower)

			-- self.totalAttributeForQihe:addAttr(EnumAttributeType.Force, wuliPower)
			-- self.totalAttributeForQihe:addAttr(EnumAttributeType.Magic, neiliPower)
		end
	end

	-- print(self.name.."------------------self.totalAttribute 444 ->",self.totalAttribute:displayString())
	self.totalAttribute:updatePower()
	self:updatePower()
	--if self.id == 77 then
	--	print("总属性 ->",self.totalAttribute:displayString())
	--end

	--print("############# " .. self.name .. "  战力：" .. self.power .." ##################")
end

function CardRole:updateMonthCard()
	-- 大月卡增加额外属性-- 主角：t_s_month_card_buff_conf
	print("updateMonthCard")
	local bOwnMonth = MonthCardManager:isExistMonthCard(MonthCardManager.CARD_TYPE_2)
	if bOwnMonth == true then
		if self.isMainPlayer then
			local level = MainPlayer:getLevel()
			local dataConfig = MonthCardBuffData:objectByID(1)
			local absoluteConfig,_ = stringToTable(dataConfig.absolute,"|")
			local lvlupAddConfig,_ = stringToTable(dataConfig.level_up,"|")
			local propAddConfig = {}
			for k,v in pairs(absoluteConfig) do
				local config,_ = stringToNumberTable(v,"_")
				if config[1] ~= nil then
					local index = config[1]
					local baseAdd = config[2]
					propAddConfig[index] = propAddConfig[index] or {}
					propAddConfig[index].baseAdd = baseAdd
				end
			end
			for k,v in pairs(lvlupAddConfig) do
				local config,_ = stringToNumberTable(v,"_")
				if config[1] ~= nil then
					local index = config[1]
					local lvlAdd = config[2]
					propAddConfig[index] = propAddConfig[index] or {}
					propAddConfig[index].lvlAdd = lvlAdd
				end
			end
			for k,v in pairs(propAddConfig) do
				local baseAdd = v.baseAdd or 0
				local lvlAdd = v.lvlAdd or 0
				self.monthAttribute:addAttr(k, baseAdd + lvlAdd*level)
			end
		end
	end
end

--[[
战斗力 = 生命*0.1 + 武力 * 0.5+ 内力*0.5+ 身法*0.5 +防御*0.5 + 冰伤*0.5 + 毒伤*0.5+ 火伤*0.5+冰抗 *0.5+ 火抗*0.5+ 毒抗*0.5 + 技能加成
]]
function CardRole:updatePower()
	self.power = self.totalAttribute:getPower()
	if self.spellPower then
		self.power = self.power + self.spellPower
	end

	--增加修炼场战斗力
	local factionSkill = self.factionPractice or {}
	for k,v in pairs(factionSkill) do
		self.power = self.power + v.power
	end

	self.power = self.power + self.qimenPower

	for i=1,EnumFightStrategyType.StrategyType_Max do
		if i == CardRoleManager.openArmyIndex then
			if self.totalAttributeByType[i] then
				if AssistFightManager:freshRoleInStrategyPower( i ,self.gmId ) == false then
					self.totalAttributeByType[i] = nil
				end
			end
		end
	end
end

function CardRole:getTotalAttribute(index  )
	if index == nil then
		return self.totalAttribute:getAttribute()
	end
	local attribute = self.totalAttribute:getAttribute()
	local num = attribute[index] or 0
	local attrCoefficient = 1
	return num,attrCoefficient
end
function CardRole:getTotalAttributeByFightType(fight_type,index  )
	-- print("self.totalAttributeByType[fight_type]  ==",self.totalAttributeByType[fight_type]:displayString())
	-- print("self.totalAttribute  ==",self.totalAttribute:displayString())
	if self.totalAttributeByType[fight_type] == nil then
		return self:getTotalAttribute(index)
	end
	if AssistFightManager:isinStrategyList( fight_type,self.gmId ) == false then
		self.totalAttributeByType[fightType] = nil
		return self:getTotalAttribute(index)
	end

	if index == nil then
		return self.totalAttributeByType[fight_type]:getAttribute()
	end
	local attribute = self.totalAttributeByType[fight_type]:getAttribute()
	local num = attribute[index] or 0
	local attrCoefficient = 1
	return num,attrCoefficient
end

function CardRole:getTotalAttributeWithOutQihe(index)
	if index == nil then
		return self.totalAttributeForQihe:getAttribute()
	end
	local attribute = self.totalAttributeForQihe:getAttribute()
	local num = attribute[index] or 0
	local attrCoefficient = 1
	return num,attrCoefficient
end

function CardRole:RefreshBookAttrAdd()
	self.bookAttrAdd = {}
	for k,v in pairs(BookManager.bookBag) do
		if v.roleID == self.gmId then
			local bookResData = BookConfig:objectByID(v.resID)
		    if bookResData ~= nil then
		        local attribute = bookResData.attribute
		        local currAdd = self.bookAttrAdd[attribute] or 0
		    	self.bookAttrAdd[attribute] = currAdd + v.attrAdd
		    else
		    	assert(false)
		    end
		end
	end

	self:updateTotalAttr()
end

function CardRole:RefreshEquipment( ... )
	self.equipAttribute:clear()
	local function cmp( x , y , tbl )
		return x+ y
	end
	-- for v in self:getEquipment():iterator() do
	-- 	self.equipAttribute:doMathAttData(v:GetTotalAttrArray(),cmp)
	-- end
	--self.equipAttribute:refreshRoleAttrBypercent(self)
	for v in self:getEquipment():iterator() do
		self.equipAttribute:doMathAttData(v:getAttrWithOutGem(),cmp)
	end
	self.equipAttribute:refreshBypercent()
	for v in self:getEquipment():iterator() do
		self.equipAttribute:setAddAttData(v:getAttrWithGem())
	end

	self:updateTotalAttr()
end

function CardRole:refreshMartial(...)
	self.martialAttribute:clear()
	for i = 1,6 do
		local martial = self.martialList[i]
		if martial then
			local attributeTable 	= martial.template:getAttributeTable()
			local newAttributeTable = {}
			for i,v in pairs(attributeTable) do
				v = v + math.floor(v*martial.enchantLevel*0.1)
				newAttributeTable[i] = v
			end

			self.martialAttribute:add(newAttributeTable)
		end
	end
	self:updateTotalAttr()
end

function CardRole:AddEquipment( equip )
	self:getEquipment():AddEquipment(equip)
	equip.equip = self.id
	self:RefreshEquipment()
end

function CardRole:DelEquipment( equip )
	self:getEquipment():DelEquipment(equip)
	self:RefreshEquipment()
end

function CardRole:DelEquipmentBygmid(gmid)
	local equip = EquipmentManager:getEquipByGmid(gmid)
	if equip then
		self:DelEquipment( equip )
	end
end

function CardRole:UpdatePower()
	if CardRoleManager.freshLock == true then
		return
	end
	self:updateTotalAttr()
end

function CardRole:getpower( )
	return self.power
end
function CardRole:getTotalRoleExp()
	return LevelData:getTotalRoleExp( self.level ) + self.curExp
end
function CardRole:getBigImagePath()
	return self.bigTextrueName
end

function CardRole:getHeadPath()
	return self.head
end

function CardRole:getIconPath()
	return self.icon
end
function CardRole:getOutline()
	return self.outlineArr
end

function CardRole:getUpstarNeedSoulNum()
	-- if self.upstar_need_soul_num_arr[self.starlevel + 1] then
	-- 	return tonumber(self.upstar_need_soul_num_arr[self.starlevel + 1]) 
	-- end
	local item = self.upstar_need_soul_num_list:getObjectAt(self.starlevel+1)
	if item then
		return item.soul_num
	end
	return 0;
end

function CardRole:getHaveSoulNum()
	local soul = BagManager:getItemById(self.soul_card_id );
    if soul then
        return soul.num;
    end
    return 0;
end

function CardRole:getIsMainPlayer()
	return self.isMainPlayer;
end

function CardRole:getChangSoulNum()
	local num = self.merge_card_num
	-- for i=1,self.starlevel do
	-- 	num = num + tonumber(self.upstar_need_soul_num_arr[i])
	-- end
	for i=1,self.starlevel do
		local item = self.upstar_need_soul_num_list:getObjectAt(i)
		if item then
			num = num + item.soul_num
		end
	end
	return num
end
function CardRole:getStarSoulNum()
	local num = 0
	-- for i=1,self.starlevel do
	-- 	num = num + tonumber(self.upstar_need_soul_num_arr[i])
	-- end
	for i=1,self.starlevel do
		local item = self.upstar_need_soul_num_list:getObjectAt(i)
		if item then
			num = num + item.soul_num
		end
	end	
	return num
end
--[[
获取当前可以升级的穴位索引
]]
function CardRole:getCurrentAcupointIndex()
	local configure = MeridianConfigure:objectByID(self.id)
	local alen = configure:acupointLength()
	local acupintInfo = nil
	local minLevelIndex = nil
	for i = 1,alen do
		acupointInfo = self.acupointList[i]
		if not acupointInfo then
			-- print("CardRole:getCurrentAcupointIndex : ",i)
			return i
		end
		if minLevelIndex then
			if self.acupointList[i-1].level > acupointInfo.level then
				minLevelIndex = i
			end
		else
			minLevelIndex = 1
		end
	end
	return minLevelIndex
end

function CardRole:SetAcupointInfo(acupointInfo)

	local pos = acupointInfo.position
	if self.acupointList[pos] == nil then
		self.acupointList[pos] = {}
	end

	self.acupointList[pos].level =  acupointInfo.level
	self.acupointList[pos].position = pos
	self.acupointList[pos].breachLevel = acupointInfo.breachLevel


	self:RefresAcuPointAttrAdd()
end

function CardRole:RefresAcuPointAttrAdd()
	self.acupointAttrAdd = {}
	local configure = MeridianConfigure:objectByID(self.id)
	-- print("acupoint configure : ",configure)
	for k,acupointInfo in pairs(self.acupointList) do
		if acupointInfo then
			if acupointInfo.breachLevel == nil then
				acupointInfo.breachLevel = 0
			end
			local key = configure:getAttributeKey(k)
			local info = AcupointBreachData:getData( key, acupointInfo.breachLevel )
			local value = info.value * acupointInfo.level
			
			self.acupointAttrAdd[key] = value
		end
	end

	self:updateTotalAttr()
end

function CardRole:GetAcupointInfo(pos)
	-- print('self.acupointList = ',self.acupointList)
	if pos == nil then
		return nil
	else
		return self.acupointList[pos]
	end
end

--设置角色品质
function CardRole:setQuality( quality )
	self.quality = quality				--品质
end

--设置角色星级属性等级，
function CardRole:setStarlevel( starlevel )
	if self.starlevel == starlevel then
		return
	end

	self.starlevel = starlevel

	self:updateStarLevelAttr()
	self:updateSkillAttr()
	self:updateTotalAttr()
end
--设置角色星级属性经验
function CardRole:setStarexp( starexp )
	self.starexp = starexp				--星级经验
end

function CardRole:getPowerByFightType(fightType)
	if self.totalAttributeByType[fightType] == nil then
		return self.power
	end
	if AssistFightManager:isinStrategyList( fightType,self.gmId ) == false then
		self.totalAttributeByType[fightType] = nil
		return self.power
	end
	local power = self.totalAttributeByType[fightType]:getPower()
	if self.spellPower then
		power = power +self.spellPower
	end

	--增加修炼场战斗力
	local factionSkill = self.factionPractice or {}
	for k,v in pairs(factionSkill) do
		power = power + v.power
	end
	power = power + self.qimenPower
	return power
end

--清除缘分
function CardRole:clearFate()
	self.fateMap ={}
	self.fateAttribute:clear()
	self.fateAttributeForQihe:clear()
	--清除缘分时也要刷新属性
	self:updateTotalAttr()
end

--获取缘分的状态
function CardRole:getFateStatusByFightType(fightType,fateId)
	print("self.fateStatesByType = ",self.fateStatesByType)
	if self.fateStatesByType == nil then
		return false
	end
	if self.fateStatesByType[fightType] == nil then
		if self.fateStatesByType[100] == nil then
			return false
		end
		return self.fateStatesByType[100][fateId]
	end
	if AssistFightManager:isinStrategyList( fightType,self.gmId ) == false then
		self.fateStatesByType[fightType] = nil
		return self.fateStatesByType[100][fateId]
		-- self:updateFateByList({},fightType)
		-- if self.fateStatesByType == nil or self.fateStatesByType[fightType] == nil then
		-- 	return false
		-- end
	end
	if self.fateStatesByType[fightType][fateId] == true then
		return true
	else
		return false
	end
end
--获取缘分的状态
function CardRole:getFateStatus(fateId)
	if self.fateMap[fateId] == true then
		return true
	else
		return false
	end
end
--更新缘分
function CardRole:updateFate(showMessage)
	--先清除现有缘分
	-- self.fateMap ={}
	if showMessage == nil then
		showMessage = false
	end

	self.fateStatesByType = self.fateStatesByType or {}
	self.fateStatesByType[100] = self.fateStatesByType[100] or {}

	-- print("CardRole:updateFate()  self.fateMap = ",self.fateMap)
	self.fateAttribute:clear()
	self.fateAttributeForQihe:clear()

	local battleType = 1 -- 普通1  血战2
	local inWar		 = false
	--如果自身不在战阵上则肯定没有任何缘分
	if BloodFightManager:bPlayerIsInBloodFighting() == true then
		inWar 		= BloodFightManager:getRoleByTemplateId(self.id)
		battleType 	= 2
	else
		inWar = StrategyManager:getRoleByTemplateId(self.id)
	end

	local fateArray = RoleFateData:getRoleFateById( self.id)
	if fateArray == nil then
		print("此人没有缘分  id == "..self.id)
		self:updateQihe()
		return
	end

	for v in fateArray:iterator() do
		local targetList = v:gettarget()
		local status = true
		if #targetList == 0 then
			status = false
		end
		local isRoleFate = true
		for _,target in pairs(targetList) do
			if target.fateType == 1 then
				isRoleFate = false
			end
			if self:getTargetStatus(target,battleType) == true then
			else
				status = false
				isRoleFate = false
			end
		end

		local fateItemInfo = FateManager:getFateItemInfo( self.id,v.id )
		if fateItemInfo then
			if fateItemInfo.forever or fateItemInfo.endTime >= MainPlayer:getNowtime() then
				status = true
				isRoleFate = true
			elseif fateItemInfo.endTime < MainPlayer:getNowtime() then
				FateManager:removeFateItemInfo( self.id,v.id )
			end
		end
		if status == true then
			if self.fateMap[v.id] ~= nil and self.fateMap[v.id] == false and showMessage then
				-- print(self.name.. "self.fateMap[v.id]  v.title = "..v.title.." vaule = ",self.fateMap[v.id])
				-- toastMessage("激活缘分 "..v.title)
				fateMessage(v.title,nil,nil,nil,true,"lua.uiconfig_mango_new.common.FateMessage")
			end
			self.fateMap[v.id] = true
			local attr_index , attr_num = v:getAttr()
			self.fateAttribute:addAttr(attr_index,attr_num)
			self.fateStatesByType[100][v.id] = true
			if isRoleFate then
				self.fateAttributeForQihe:addAttr(attr_index,attr_num)
			else
				self.fateStatesByType[100][v.id] = false
			end
		else
			self.fateMap[v.id] = false
			self.fateStatesByType[100][v.id] = false
		end
	end

	-- self:updateTotalAttr()

	self:updateQihe()

	TFDirector:dispatchGlobalEventWith(CardRoleManager.updateFateMessage,{self.gmId})
end
--判断是否与物品有缘分
function CardRole:hasFate( fateType , fateId )
	local fateArray = RoleFateData:getRoleFateById( self.id)
	if fateArray == nil then
		print("此人没有缘分  id == "..self.id)
		return false
	end
	for v in fateArray:iterator() do
		local targetList = v:gettarget()
		for _,target in pairs(targetList) do
			if target.fateType == fateType and target.fateId == fateId then
				return true
			end
		end
	end
	return false
end

--更新技能属性加成
function CardRole:updateSkillAttr()
	self.skillAttribute:clear()
	self.effectExtraAttribute:getSkillAttribute():clear()
	self.immuneAttribute:getSkillAttribute():clear()
	self.beEffectExtraAttribute:getSkillAttribute():clear()

	self.spellPower = 0
	if self:getIsMainPlayer() then
		for i,spell in pairs(self.leadingRoleSpellList) do
			if spell.choice then

				local skillLevelInfo = SkillLevelData:getInfoBySkillAndLevel( spell.spellId.skillId , spell.spellId.level);
	            --<<<<<<<<<<<<<<<<<<<技能替换判断
	            local replaceSkillId = CardRoleManager:isSkillReplace(self.id, self.starlevel,spell.spellId.skillId)
	            if replaceSkillId ~= spell.spellId.skillId then
	                skillLevelInfo = SkillLevelData:getInfoBySkillAndLevel( replaceSkillId , spell.spellId.level);
	            end       
	            -->>>>>>>>>>>>>>>>>>>>						
				self.spellPower =  self.spellPower + skillLevelInfo.power
				if skillLevelInfo.type ~= EnumSkillType.BeiDongZengYiGuangHuan and skillLevelInfo.type ~= EnumSkillType.BeiDongChiJianGuangHuan  then

					-- local attr_add_arr = string.split(skillLevelInfo.attr_add, '|');
					for k,v in pairs(skillLevelInfo.attr_add) do
						self.skillAttribute:addAttr(k,v)
					end

					for k,v in pairs(skillLevelInfo.immune) do
						self.immuneAttribute:getSkillAttribute():addAttr(k,v)
					end
					for k,v in pairs(skillLevelInfo.effect_extra) do
						self.effectExtraAttribute:getSkillAttribute():addAttr(k,v)
					end
					for k,v in pairs(skillLevelInfo.be_effect_extra) do
						self.beEffectExtraAttribute:getSkillAttribute():addAttr(k,v)
					end
				end
			end
		end
	else
		for i,levelInfo in pairs(self.spellLevelIdList) do
			local skillLevelInfo = SkillLevelData:getInfoBySkillAndLevel( levelInfo.skillId , levelInfo.level);
            --<<<<<<<<<<<<<<<<<<<技能替换判断
           

            local replaceSkillId = CardRoleManager:isSkillReplace(self.id, self.starlevel, levelInfo.skillId)
            if replaceSkillId ~= levelInfo.skillId then
                skillLevelInfo = SkillLevelData:getInfoBySkillAndLevel( replaceSkillId , levelInfo.level);
            end      
            -->>>>>>>>>>>>>>>>>>>>
			if skillLevelInfo then
				self.spellPower =  self.spellPower + skillLevelInfo.power
			end
			if skillLevelInfo.type ~= EnumSkillType.BeiDongZengYiGuangHuan and skillLevelInfo.type ~= EnumSkillType.BeiDongChiJianGuangHuan then
				-- local attr_add_arr = string.split(skillLevelInfo.attr_add, '|');

				for k,v in pairs(skillLevelInfo.attr_add) do
					self.skillAttribute:addAttr(k,v)
				end
				for k,v in pairs(skillLevelInfo.immune) do
					self.immuneAttribute:getSkillAttribute():addAttr(k,v)
				end
				for k,v in pairs(skillLevelInfo.effect_extra) do
					self.effectExtraAttribute:getSkillAttribute():addAttr(k,v)
				end
				for k,v in pairs(skillLevelInfo.be_effect_extra) do
					self.beEffectExtraAttribute:getSkillAttribute():addAttr(k,v)
				end
			end
		end
	end
	
	self:updateTotalAttr()
	self.effectExtraAttribute:updateAttribute()
	self.immuneAttribute:updateAttribute()
	self.beEffectExtraAttribute:updateAttribute()
end

--更新侠客升星属性加成
function CardRole:updateStarLevelAttr()
	-- self.starLevelAttributeTable = {}
	-- self.starLevelPercentTable = {}

	-- local roleInfoList = RoleTalentData:GetRoleStarInfoByRoleId( self.id )

	-- for i=1,self.starlevel do
	-- 	local item = roleInfoList:getObjectAt(i)
	-- 	if item ~= nil then
	-- 		if item.type == 1 then --属性加成
	-- 			local attr_buffer = string.split(item.expression,'|')
	-- 			for j=1,#attr_buffer do

	-- 				local activity = string.split(attr_buffer[j],'_')
	-- 				local attr_index = tonumber(activity[1])
	-- 				local attr_value = tonumber(activity[2])

	-- 				if attr_index < 18 then--18之前加固定值
	-- 					if self.starLevelAttributeTable[attr_index] then
	-- 						self.starLevelAttributeTable[attr_index] = self.starLevelAttributeTable[attr_index] + attr_value
	-- 					else 
	-- 						self.starLevelAttributeTable[attr_index] = attr_value
	-- 					end
	-- 				else
	-- 					if self.starLevelPercentTable[attr_index] then
	-- 						self.starLevelPercentTable[attr_index] = self.starLevelPercentTable[attr_index] + attr_value
	-- 					else 
	-- 						self.starLevelPercentTable[attr_index] = attr_value
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
	--close 2015-10-12 14:19:46 ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

	self.starupAttribute:clear()
	local roleInfoList = RoleTalentData:GetRoleStarInfoByRoleId( self.id )
	for i=1,self.starlevel do
		local item = roleInfoList:getObjectAt(i)
		if item ~= nil then
			if item.type == 1 then --属性加成
				local attr_buffer = string.split(item.expression,'|')
				for j=1,#attr_buffer do

					local activity = string.split(attr_buffer[j],'_')
					local attr_index = tonumber(activity[1])
					local attr_value = tonumber(activity[2])

					self.starupAttribute:addAttr(attr_index,attr_value)

				end
			end
		end
	end

end

--获取缘分目标状态（是否存在） battleType == 1 普通战阵 2 血战
function CardRole:getTargetStatus( target, battleType)
	--1、角色；2、装备；3、秘籍；4、道具
	if target.fateType == 1 then
		local StrategyFate = StrategyManager
		if battleType == 1 then
			StrategyFate = StrategyManager
		elseif battleType == 2 then
			StrategyFate = BloodFightManager
		end

		local selfInWar = StrategyFate:getRoleByTemplateId(self.id)
		if not selfInWar then
			return false
		end

		local fateRole =  StrategyFate:getRoleByTemplateId(target.fateId)
		if fateRole then
			return true
		else
			-- 在缘分列表里面找找
			if battleType == 1 then
				local role =  self:getRoleByTemplateId(target.fateId)
				if role ~= nil then
					return true
				end
			end
			return false
		end
	elseif  target.fateType == 2 then
		for i=1,5 do
			local equip = self.equipment:GetEquipByType(i)
			if equip and equip.id == target.fateId then
				return true
			end
		end
		return false
	elseif target.fateType == 3 then
		for k,v in pairs(BookManager.bookBag) do
			if v.roleID == self.gmId and v.resID == target.fateId then
				return true
			end
		end
		return false
	elseif target.fateType == 4 then
		return false
	end
	return false 
end

--[[
检测是否可以装备武学
@martialTemplate 武学模版
@position 位置，从1开始
]]
function CardRole:isCanEquipMartial(martialTemplate,position)
	if self.martialList[position] ~= nil then
		--toastMessage("该位置已经装备了武学，不可重复装备")
		toastMessage(localizable.CardRole_tip1)
		return false
	end

	local martialRoleConfigure = MartialRoleConfigure:findByRoleIdAndMartialLevel(self.id,self.martialLevel)
	if martialRoleConfigure == nil then
		--toastMessage("找不到对应的角色武学配置 : [" .. self.id .. "] , [" ..self.martialLevel .. "]")
		toastMessage(stringUtils.format(localizable.CardRole_tip2, self.id, self.martialLevel))
		return false
	end

	local martialTable = martialRoleConfigure:getMartialTable()
	if not martialTable then
		--toastMessage("不可装备，Martial table is nil or not found")
		toastMessage(localizable.CardRole_tip3)
		return false
	end

	if martialTable[position] ~= martialTemplate.id then
		--toastMessage("武学id与配置不匹配.")
		toastMessage(localizable.CardRole_tip4)
		return false
	end
	return true
end

--[[
尝试装备武学，经过本地校验，如果有效则会请求服务器进行武学装备
@martialTemplate 武学模版
@position 位置，从1开始
]]
function CardRole:tryEquipMartial(martialTemplate,position)
	MartialManager:requestEquip(self,martialTemplate,position,false)
end

--[[
在角色实力身上直接添加武学
@martialTemplate 武学模版
@position 位置，从1开始
]]
function CardRole:addMartial(martialTemplate,position)
	local martialInstance = require('lua.gamedata.hold.MartialInstance'):new(martialTemplate)
	martialInstance:setTemplate(martialTemplate)
	martialInstance.position = position
	self.martialList[position] = martialInstance
	martialInstance.roleId = self.gmId
	return martialInstance
end

--[[
通过武学id查找装备到角色身上的武学实力
@martialId 武学id
@return 因为同一种武学可能同时装备多个，所以返回的事table表格
]]
function CardRole:findMartialById(martialId)
	local result = {}
	for i,value in pairs(self.martialList) do
		if value then
			if value.template.id == martialId then
				result[i] = value
			end
		end
	end
	return result
end

--[[
通过武学装备位置查找武学实例
@position 武学装备位置
@return 武学实例，找不到返回nil
]]
function CardRole:findMartialByPosition(position)
	-- return self[position]
	return self.martialList[position]
end

--是否有技能可以升级
function CardRole:isSkillCanUp()
    local skillMaxLevel = ConstantData:objectByID("RoleSkill.Max.Level").value or 150
	if self:getIsMainPlayer() then
		for i,spell in pairs(self.leadingRoleSpellList) do
			if spell.choice then
				if spell.spellId.level < self.level and spell.spellId.level < skillMaxLevel then
					return true
				end
			end
		end
	else
		for i,levelInfo in pairs(self.spellLevelIdList) do
			if levelInfo.level < self.level  and levelInfo.level < skillMaxLevel then
				return true
			end
		end
	end
	return false
end

function CardRole:getSpellAllCost()
	local cost = 0
	if self:getIsMainPlayer()  then
		for i,levelInfo in pairs(self.leadingRoleSpellList) do
			for i=1,levelInfo.spellId.level - 1 do
				local info = SkillAttributeData:objectByID(i)
				if info then
					cost = cost + info.uplevel_cost
				end
			end
		end
	else
		for i,levelInfo in pairs(self.spellLevelIdList) do
			for i=1,levelInfo.level - 1 do
				local info = SkillAttributeData:objectByID(i)
				if info then
					cost = cost + info.uplevel_cost
				end
			end
		end
	end
	return cost
end
function CardRole:getMeridianAllCostByLevel( level )
	local cost = 0
	for i=1,level do
		local info = MeridianConsume:objectByID(i)
		if info then
			cost = cost + info.cost
		end
	end
	return cost
end

function CardRole:getMeridianAllCost()
	local cost = 0
	for k,acupointInfo in pairs(self.acupointList) do
		if acupointInfo then
			cost = cost + self:getMeridianAllCostByLevel(acupointInfo.level)
		end
	end
	return cost
end
function CardRole:getMeridianBreachAllCost()
	local cost = 0
	local configure = MeridianConfigure:objectByID(self.id)
	for k,acupointInfo in pairs(self.acupointList) do
		if acupointInfo then
			local key = configure:getAttributeKey(k)
			cost = cost + AcupointBreachData:getConsumeMinByLevel(key ,acupointInfo.breachLevel)
		end
	end
	return cost
end

function CardRole:reBirth()
	self.curExp = 0
	self:setLevel(1)
	-- self.level = 1;
	self.starlevel = 0;

	self.martialList		= {}
	self.martialLevel		= 1							--武学等级，角色默认1级

	self.acupointList 	= {}
	self.acupointAttrAdd = {}
	self.bookAttrAdd = {}
	if self:getIsMainPlayer() then
		self.leadingRoleSpellList[1].spellId.level = 1
		self.leadingRoleSpellList[1].choice = true
		for i=2,9 do
			self.leadingRoleSpellList[i] = nil
		end
	else
		self.spellLevelIdList[1].level = 1
		for i=2,3 do
			self.spellLevelIdList[i] = nil
		end
	end
	self:setFactionPractice({})
	self:updateSkillAttr()
	self:refreshMartial()

	-- self:updateTotalAttr()
end

function CardRole:replaceSkillList()

end



--获取缘分目标状态（是否存在）
function CardRole:getRoleFateStatusByList( list,target)
	--1、角色；2、装备；3、秘籍；4、道具
	if target.fateType ~= 1 then
		return false
	end
	local inWar = false
	-- for i=1,9 do
	-- 	if list[i] and list[i] == self.gmId then
	-- 		inWar = true
	-- 	end
	-- end
	-- if inWar == false then
	-- 	return false
	-- end

	local fateRole = CardRoleManager:getRoleById( target.fateId )
	if fateRole then
		for i=1,19 do
			if list[i] and list[i] == fateRole.gmId then
				return true
			end
		end
	end
	return false
end
--获取缘分目标状态（是否存在）
function CardRole:getRoleFateStatusByIdList( list,target)
	--1、角色；2、装备；3、秘籍；4、道具
	if target.fateType ~= 1 then
		return false
	end
	local inWar = false
	-- for i=1,9 do
	-- 	if list[i] and list[i] == self.gmId then
	-- 		inWar = true
	-- 	end
	-- end
	-- if inWar == false then
	-- 	return false
	-- end

	for i=1,19 do
		if list[i] and list[i] == target.fateId then
			return true
		end
	end
	return false
end

--获取缘分目标状态（是否存在
function CardRole:getTargetStatusWithOutRole( target)
	--1、角色；2、装备；3、秘籍；4、道具
	if target.fateType == 1 then
		return false
	end
	if  target.fateType == 2 then
		for i=1,5 do
			local equip = self.equipment:GetEquipByType(i)
			if equip and equip.id == target.fateId then
				return true
			end
		end
		return false
	elseif target.fateType == 3 then
		for k,v in pairs(BookManager.bookBag) do
			if v.roleID == self.gmId and v.resID == target.fateId then
				return true
			end
		end
		return false
	elseif target.fateType == 4 then
		return false
	end
	return false 
end

function CardRole:updateFateByList(list,fight_type)
	self.fateStatesByType = self.fateStatesByType or {}
	self.fateStatesByType[fight_type] = {}
	local attribute	= GameAttributeData:new()

	local fateArray = RoleFateData:getRoleFateById( self.id)
	if fateArray == nil then
		print("此人没有缘分  id == "..self.id)
		return
	end

	for v in fateArray:iterator() do
		local status = true
		local fateItemInfo = FateManager:getFateItemInfo(self.id,v.id)
		if fateItemInfo and (fateItemInfo.forever or fateItemInfo.endTime >= MainPlayer:getNowtime()) then
			status = true
		else
			if fateItemInfo and fateItemInfo.endTime < MainPlayer:getNowtime() then
				FateManager:removeFateItemInfo( self.id,v.id )
			end
			
			local targetList = v:gettarget()
			if #targetList == 0 then
				status = false
			end
			for _,target in pairs(targetList) do
				if target.fateType == 1 then
					if self:getRoleFateStatusByList(list,target) == false then
						status = false
					end
				else
					if self:getTargetStatusWithOutRole(target) == false then
						status = false
					end
				end
			end
		end
		if status == true then
			-- print(self.name.."fate == ",v)
			local attr_index , attr_num = v:getAttr()
			attribute:addAttr(attr_index,attr_num)
		end
		self.fateStatesByType[fight_type][v.id] = status
	end
	return attribute
end

function CardRole:updateFateByIdList(list,fight_type)
	self.fateStatesByType = self.fateStatesByType or {}
	self.fateStatesByType[fight_type] = {}
	local attribute	= GameAttributeData:new()

	local fateArray = RoleFateData:getRoleFateById( self.id)
	if fateArray == nil then
		print("此人没有缘分  id == "..self.id)
		return
	end

	for v in fateArray:iterator() do
		local status = true
		local fateItemInfo = FateManager:getFateItemInfo(self.id,v.id)
		if fateItemInfo and (fateItemInfo.forever or fateItemInfo.endTime >= MainPlayer:getNowtime()) then
			status = true
		else
			if fateItemInfo and fateItemInfo.endTime < MainPlayer:getNowtime() then
				FateManager:removeFateItemInfo( self.id,v.id )
			end
			local targetList = v:gettarget()
			if #targetList == 0 then
				status = false
			end
			for _,target in pairs(targetList) do
				if target.fateType == 1 then
					if self:getRoleFateStatusByIdList(list,target) == false then
						status = false
					end
				else
					if self:getTargetStatusWithOutRole(target) == false then
						status = false
					end
				end
			end
		end
		if status == true then
			-- print(self.name.."fate == ",v)
			local attr_index , attr_num = v:getAttr()
			attribute:addAttr(attr_index,attr_num)
		end
		self.fateStatesByType[fight_type][v.id] = status
	end
	return attribute
end

function CardRole:getPowerByList(list,fight_type)
	self.totalAttributeByType = self.totalAttributeByType or {}
	local attribute	= GameAttributeData:new()
	local fateAttribute	= GameAttributeData:new()
	local qiheAttribute = GameAttributeData:new()

	attribute:clone(self.attribute)
	attribute:setAddAttData(self.martialAttribute)
	for k,v in pairs(self.bookAttrAdd) do
		attribute:addAttr(k,v)
	end
	
	for k,v in pairs(self.acupointAttrAdd) do
		attribute:addAttr(k,v)
	end
	attribute:setAddAttData(self.qimenAttribute)
	attribute:setAddAttData(self.equipAttribute)
	attribute:setAddAttData(self.skillAttribute)
	attribute:setAddAttData(self.skyBookAttribute)
	attribute:setAddAttData(self.starupAttribute)
	attribute:setAddAttData(self.factionPracticeAttribute)
	attribute:setAddAttData(self.lianTiAttribute)
	
	attribute:refreshBypercent()

	if AssistFightManager:checkIsStrategyMemberByFightType( self.gmId,fight_type )  then
		local attrList = AssistFightManager:getQihePreviewInfo(fight_type)
		for k,v in pairs(attrList) do
			qiheAttribute:addAttr(k,v)
		end
	end

	attribute:setAddAttData(qiheAttribute)
	
	fateAttribute = self:updateFateByList(list,fight_type)
	attribute:setAddAttData(fateAttribute)


	attribute:refreshBypercent()

	if self.isMainPlayer then
		local vip_add = VipRuleManager:addMainPlayerAttr()
		if vip_add ~= 0 then
			attribute:addAttr(EnumAttributeType.Force,vip_add)
			attribute:addAttr(EnumAttributeType.Magic,vip_add)
		end
	end

	-- 大月卡增加额外属性-- 主角：武力、内力 各500 +level*5
	local bOwnMonth = MonthCardManager:isExistMonthCard(MonthCardManager.CARD_TYPE_2)
	if bOwnMonth == true then
		if self.isMainPlayer then
			self.monthAttribute:clear()
			self:updateMonthCard()	
			attribute:setAddAttData(self.monthAttribute)
		end
	end



	attribute:updatePower()
	local power = attribute:getPower()
	if self.spellPower then
		power = power +self.spellPower
	end

	--增加修炼场战斗力
	local factionSkill = self.factionPractice or {}
	for k,v in pairs(factionSkill) do
		power = power + v.power
	end


	self.totalAttributeByType[fight_type] = attribute

	return power

end
function CardRole:getPowerByIdList(list,assist_type)

	self.totalAttributeByType = self.totalAttributeByType or {}

	local attribute	= GameAttributeData:new()
	local fateAttribute	= GameAttributeData:new()
	local qiheAttribute	= GameAttributeData:new()

	attribute:clone(self.attribute)
	attribute:setAddAttData(self.martialAttribute)
	for k,v in pairs(self.bookAttrAdd) do
		attribute:addAttr(k,v)
	end
	
	for k,v in pairs(self.acupointAttrAdd) do
		attribute:addAttr(k,v)
	end
	attribute:setAddAttData(self.qimenAttribute)
	attribute:setAddAttData(self.equipAttribute)
	attribute:setAddAttData(self.skillAttribute)
	attribute:setAddAttData(self.starupAttribute)
	attribute:setAddAttData(self.skyBookAttribute)
	attribute:setAddAttData(self.factionPracticeAttribute)
	attribute:setAddAttData(self.lianTiAttribute)
	
	attribute:refreshBypercent()

	if AssistFightManager:checkIsStrategyMemberByFightType( self.gmId,assist_type ) then
		local attrList = AssistFightManager:getQihePreviewInfo(assist_type)
		for k,v in pairs(attrList) do
			qiheAttribute:addAttr(k,v)
		end
	end


	attribute:setAddAttData(qiheAttribute)
	
	-- print(self.name.."属性 ->"..attribute:displayString())
	fateAttribute = self:updateFateByIdList(list,assist_type)
	-- print(self.name.."fateAttribute 属性 ->"..fateAttribute:displayString())
	attribute:setAddAttData(fateAttribute)


	attribute:refreshBypercent()

	if self.isMainPlayer then
		local vip_add = VipRuleManager:addMainPlayerAttr()
		if vip_add ~= 0 then
			attribute:addAttr(EnumAttributeType.Force,vip_add)
			attribute:addAttr(EnumAttributeType.Magic,vip_add)
		end
	end

	-- 大月卡增加额外属性-- 主角：武力、内力 各500 +level*5
	local bOwnMonth = MonthCardManager:isExistMonthCard(MonthCardManager.CARD_TYPE_2)
	if bOwnMonth == true then
		if self.isMainPlayer then
			self.monthAttribute:clear()
			self:updateMonthCard()
			attribute:setAddAttData(self.monthAttribute)
		end
	end



	attribute:updatePower()
	local power = attribute:getPower()
	if self.spellPower then
		power = power +self.spellPower
	end

	--增加修炼场战斗力
	local factionSkill = self.factionPractice or {}
	for k,v in pairs(factionSkill) do
		power = power + v.power
	end

	self.totalAttributeByType[assist_type] = attribute
	return power
end

function CardRole:getRoleByTemplateId(roleid)
	local assistlist = AssistFightManager:getAssistRoleList( LineUpType.LineUp_Main )

	--添加好友助战
	local info = AssistFightManager:getFriendIconInfo()
    local cardRole = RoleData:objectByID(info.friendRoleId)
    if cardRole and cardRole.id == roleid then
    	return cardRole
	end
	-- print("assistlist = ", assistlist)
 -- M = asdasd + 1
	-- print("----AssistFightManager time2 = ", os.time())

	for i=1,10 do
		if assistlist[i] and assistlist[i] ~= 0 then
			local role = CardRoleManager:getRoleByGmid(assistlist[i])
			if role and role.id == roleid then 
				return role
			end
		end
	end

	return nil
end

function CardRole:updateQihe()

	self.qiheAttribute:clear()
	
	if AssistFightManager:checkIsStrategyMember( self.gmId ) then
		local attrList = AssistFightManager:getQihePreviewInfo(LineUpType.LineUp_Main)
		-- print('CardRoleupdateQihe = ',self.name)
		-- print(attrList)
		for k,v in pairs(attrList) do
			self.qiheAttribute:addAttr(k,v)
		end
	-- else
	-- 	print('刷新契合属性-----',self.name)
	end
	self:updateTotalAttr()
end

function CardRole:getFactionPractice()
	return self.factionPractice
end

function CardRole:setFactionPractice( practice_list )
	-- print("practice_list",practice_list)
	practice_list = practice_list or {}
	self.factionPractice = {}
	for k,v in pairs(practice_list) do
		self:setFactionPracticeByType( v.type, v.level )
	end
	-- self:refreshFactionPractice()

end

function CardRole:setFactionPracticeByType( type, level )
	local power = 0
	if level ~= 0 then
		local itemData = GuildPracticeData:getPracticeInfoByTypeAndLevel( type,level,self.outline )
		if itemData then
			power = itemData.power
		end
	end
	for i=1,#self.factionPractice do
		if self.factionPractice[i].type == type then
			self.factionPractice[i].level = level
			self.factionPractice[i].power = power
			self.factionPractice[i].profession = self.outline
			self:refreshFactionPractice()
			return 
		end
	end
	local idx = #self.factionPractice + 1
	self.factionPractice[idx] = {type = type, level = level, power = power, profession = self.outline}
	self:refreshFactionPractice()
end

function CardRole:getFactionPracticeLevelByType( type )
	for i=1,#self.factionPractice do
		if self.factionPractice[i].type == type then
			return self.factionPractice[i].level
		end
	end
	return 0
end

function CardRole:refreshFactionPractice()
	self.immuneAttribute:getPracticeAttribute():clear();
	self.effectExtraAttribute:getPracticeAttribute():clear();
	self.beEffectExtraAttribute:getPracticeAttribute():clear();

	self.factionPracticeAttribute:clear()

	for index,practicedata in pairs(self.factionPractice) do
		local practiceInfo = GuildPracticeData:getPracticeInfoByTbl(practicedata)
		if practiceInfo == nil then
			print("没有此id的修炼信息 id == ",self.factionPractice)
		else
			if practiceInfo.attribute ~= "" then
				local temp_tbl = GetAttrByString(practiceInfo.attribute)
				
				for k,v in pairs(temp_tbl) do
					self.factionPracticeAttribute:addAttr(k,v)
				end
			end
			if practiceInfo.immune_rate ~= "" then
				local temp_tbl = GetAttrByString(practiceInfo.immune_rate)
				for k,v in pairs(temp_tbl) do
					self.immuneAttribute:getPracticeAttribute():addAttr(k,v)
				end
			end
			if practiceInfo.effect_active ~= "" then
				local temp_tbl = GetAttrByString(practiceInfo.effect_active)
				for k,v in pairs(temp_tbl) do
					self.effectExtraAttribute:getPracticeAttribute():addAttr(k,v)
				end
			end
			if practiceInfo.effect_passive ~= "" then
				local temp_tbl = GetAttrByString(practiceInfo.effect_passive)
				for k,v in pairs(temp_tbl) do
					self.beEffectExtraAttribute:getPracticeAttribute():addAttr(k,v)
				end
			end
		end
	end
	self.immuneAttribute:updateAttribute()
	self.effectExtraAttribute:updateAttribute()
	self.beEffectExtraAttribute:updateAttribute()

	
	self:updateTotalAttr()
end

function CardRole:getFactionPracticeCost()
	local cost = 0
	local tableTool = {}
	for i=1,#self.factionPractice do
		local dataArray = GuildPracticeStudyData:getGuildPracticeStudyByType(self.factionPractice[i].type)
		if dataArray then
			for k,v in pairs(dataArray) do
				if v.attribute_level <= self.factionPractice[i].level then
					local tbl = string.split(v.start_practice, "|")
					local dedication = stringToNumberTable(tbl[1], "_") 
					if tbl[2] then
						local tool = stringToNumberTable(tbl[2],"_")
						tableTool[tool[2]] = tableTool[tool[2]] or 0
						tableTool[tool[2]] = tableTool[tool[2]] + tool[3]
					end
					cost = cost + dedication[3]
				end
			end
		end
	end
	return cost,tableTool
end

function CardRole:getQimenAttrDetail()
	return self.qimenAttrTable
end
function CardRole:getQimengetTotalAttribute(index)
	return self.qimenAttrTable[index]
end

function CardRole:getQimenTeamAttrDetail()
	return self.qimenTeamAttrTable
end
function CardRole:getQimenTeamgetTotalAttribute(index)
	return self.qimenTeamAttrTable[index]
end


function CardRole:getQimenLevelInfo()
	return self.qimenLevelInfo
end

function CardRole:setQimenInfo(id,level)

	if id == 0 and level == 0 then
		self.qimenLevelInfo = nil
	else
		self.qimenLevelInfo = {}
		self.qimenLevelInfo.id = id
		self.qimenLevelInfo.level = level
	end
	self.qimenPower = 0
	self.qimenAttrTable = {}
	self.qimenTeamAttrTable = {}
	self.qimenAttribute:clear()
	self.immuneAttribute:getQimenAttribute():clear();
	self.effectExtraAttribute:getQimenAttribute():clear();
	self.beEffectExtraAttribute:getQimenAttribute():clear();
	local endIdx = id
	local startIdx = endIdx - 24
	if startIdx < 1 then
		startIdx = 0
	end
	if self.isMainPlayer then
		for v in QimenConfigData:iterator() do
	        if v.id > startIdx and v.id <= endIdx then
	        -- print('QimenConfigData = '..v.attribute..' v.id = '..v.id)
		        if v.attribute ~= '' then
		        	self.qimenPower = self.qimenPower + v.power
					local awardData = stringToNumberTable(v.attribute, '_')
					self.qimenAttrTable[awardData[1]] = self.qimenAttrTable[awardData[1]] or 0
					self.qimenAttrTable[awardData[1]] = self.qimenAttrTable[awardData[1]] + awardData[2]
					self.qimenAttribute:addAttr(awardData[1],awardData[2])

				elseif v.immune_rate ~= '' then
					self.qimenPower = self.qimenPower + v.power
					local awardData = stringToNumberTable(v.immune_rate, '_')
					-- self.qimenAttrTable[awardData[1]] = self.qimenAttrTable[awardData[1]] or 0
					-- self.qimenAttrTable[awardData[1]] = self.qimenAttrTable[awardData[1]] + awardData[2]
					self.immuneAttribute:getQimenAttribute():addAttr(awardData[1],awardData[2])	

				elseif v.effect_active ~= '' then
					self.qimenPower = self.qimenPower + v.power
					local awardData = stringToNumberTable(v.effect_active, '_')
					-- self.qimenAttrTable[awardData[1]] = self.qimenAttrTable[awardData[1]] or 0
					-- self.qimenAttrTable[awardData[1]] = self.qimenAttrTable[awardData[1]] + awardData[2]
					self.effectExtraAttribute:getQimenAttribute():addAttr(awardData[1],awardData[2])	

				elseif v.effect_passive ~= '' then
					self.qimenPower = self.qimenPower + v.power
					local awardData = stringToNumberTable(v.effect_passive, '_')
					-- self.qimenAttrTable[awardData[1]] = self.qimenAttrTable[awardData[1]] or 0
					-- self.qimenAttrTable[awardData[1]] = self.qimenAttrTable[awardData[1]] + awardData[2]
					self.beEffectExtraAttribute:getQimenAttribute():addAttr(awardData[1],awardData[2])	
				end  
			end         
	    end

		for v in QimenBreachConfigData:iterator() do
	        if v.id > level then
	        	break
	        end
	        if v.attribute ~= '' then
				local dataBuff = string.split(v.attribute, '|')
				for i=1,#dataBuff do
					local awardData = stringToNumberTable(dataBuff[i], '_')
					self.qimenPower = self.qimenPower + v.power
					self.qimenAttrTable[awardData[1]] = self.qimenAttrTable[awardData[1]] or 0
					self.qimenAttrTable[awardData[1]] = self.qimenAttrTable[awardData[1]] + awardData[2]
					self.qimenAttribute:addAttr(awardData[1],awardData[2])
				end
			elseif v.immune_rate ~= '' then
				self.qimenPower = self.qimenPower + v.power
				local awardData = stringToNumberTable(v.immune_rate, '_')
				-- self.qimenAttrTable[awardData[1]] = self.qimenAttrTable[awardData[1]] or 0
				-- self.qimenAttrTable[awardData[1]] = self.qimenAttrTable[awardData[1]] + awardData[2]
				self.immuneAttribute:getQimenAttribute():addAttr(awardData[1],awardData[2])	

			elseif v.effect_active ~= '' then
				self.qimenPower = self.qimenPower + v.power
				local awardData = stringToNumberTable(v.effect_active, '_')
				self.qimenAttrTable[awardData[1]] = self.qimenAttrTable[awardData[1]] or 0
				self.qimenAttrTable[awardData[1]] = self.qimenAttrTable[awardData[1]] + awardData[2]
				self.effectExtraAttribute:getQimenAttribute():addAttr(awardData[1],awardData[2])	

			elseif v.effect_passive ~= '' then
				self.qimenPower = self.qimenPower + v.power
				local awardData = stringToNumberTable(v.effect_passive, '_')
				-- self.qimenAttrTable[awardData[1]] = self.qimenAttrTable[awardData[1]] or 0
				-- self.qimenAttrTable[awardData[1]] = self.qimenAttrTable[awardData[1]] + awardData[2]
				self.beEffectExtraAttribute:getQimenAttribute():addAttr(awardData[1],awardData[2])	
			end
	    end
	end

	for v in QimenBreachConfigData:iterator() do
        if v.id > level then
			break
        end
        if v.team_attribute ~= '' and v.team_attribute ~= '0' then
			local dataBuff = string.split(v.team_attribute, '|')
			for i=1,#dataBuff do
				local awardData = stringToNumberTable(dataBuff[i], '_')
				self.qimenTeamAttrTable[awardData[1]] = self.qimenTeamAttrTable[awardData[1]] or 0
				self.qimenTeamAttrTable[awardData[1]] = self.qimenTeamAttrTable[awardData[1]] + awardData[2]
				self.qimenAttribute:addAttr(awardData[1],awardData[2])
			end
		end
    end
	self.immuneAttribute:updateAttribute()
	self.effectExtraAttribute:updateAttribute()
	self.beEffectExtraAttribute:updateAttribute()

	self:updateTotalAttr()

	-- print('xxxselfxqimenAttrTable = ',self.qimenAttrTable)
	-- print('self.qimenAttribute = ',self.qimenAttribute)
	-- print('self.qimenPower = ',self.qimenPower)
end

--added by wuqi
function CardRole:setSkyBook(bible)
	if bible and bible.equip and bible.equip ~= 0 then
		bible.equip = nil
	end
	self.bible = bible
	bible.equip = self.id

	self.skyBookAttribute:clear()
	self.skyBookAttribute:clone(bible.totalAttribute)
	self:updateTotalAttr()
end

function CardRole:getSkyBook()
	return self.bible
end

function CardRole:delSkyBook()
	if self.bible then
		self.bible.equip = nil
		self.bible = nil
	end
	self.skyBookAttribute:clear()
	self:updateTotalAttr()
end

function CardRole:updateSkyBookAttr()
	if self.bible == nil then
		return
	end
	local bible = self.bible
	self.skyBookAttribute:clear()
	self.skyBookAttribute:clone(bible.totalAttribute)
	self:updateTotalAttr()
end

function CardRole:judgeLianTiData(dataList)
	if self.LianTiData[1] and self.LianTiData[1].level > 0 then
		return true
	end
	local pointData = {}
	for k,data in pairs(dataList) do
		if data.acupoint == 1 then
			pointData = data
			break
		end
	end
	if pointData.level <= 0 then
		return false
	end
	return true
end

function CardRole:setLianTiData(dataList)
	self.LianTiData = self.LianTiData or {}
	if self:judgeLianTiData(dataList) == false then
 		return
	end

	for i = 1,#dataList do
		local data = dataList[i] or {}
		if data.acupoint ~= nil and data.level ~= nil then
			self.LianTiData[ data.acupoint ] = self.LianTiData[ data.acupoint ] or {}
			if self.LianTiData[ data.acupoint ].level ~= data.level then
				data.quality = LianTiData:getPointQuality(data.acupoint,data.level)
				self.LianTiData[ data.acupoint ] = data
			end
			if data.level <= 0 and self.LianTiData[ data.acupoint ].isOpen ~= true then
				local openItem = LianTiOpenData:objectByID(data.acupoint)
				if openItem then
					if openItem.needacu > 0 then
						needPointData = self.LianTiData[ openItem.needacu ]
						if needPointData and needPointData.quality then
							if needPointData.quality >= openItem.quality then
								self.LianTiData[ data.acupoint ].isOpen = true
							else
								self.LianTiData[ data.acupoint ].isOpen = false
							end
						else
							self.LianTiData[ data.acupoint ].isOpen = false
						end
					else
						self.LianTiData[ data.acupoint ].isOpen = true
					end
				end
			else
				self.LianTiData[ data.acupoint ].isOpen = true
			end
		end
	end
			
	self:setLianTiAttri()
end

function CardRole:setLianTiAttri()
	self.lianTiAttribute:clear()
	self.lianTiAttrTable = {}
	self.LianTiData = self.LianTiData or {}
	for k,v in ipairs(self.LianTiData) do
		local quality = self.quality
		if self.isMainPlayer == true then
			quality = QualityHeroType.ChuanShuo
		end
		local attributeTabel = LianTiData:getTotalAttributeByType(quality,v.acupoint,v.level)
		for kk,vv in pairs(attributeTabel) do
			self.lianTiAttrTable[kk] = self.lianTiAttrTable[kk] or 0
			self.lianTiAttrTable[kk] = self.lianTiAttrTable[kk] + vv
		end
	end
	local extraAttri = self:getExtraLianTiAttri()
	for k,v in pairs(extraAttri.attribute) do
		self.lianTiAttrTable[k] = self.lianTiAttrTable[k] or 0
		self.lianTiAttrTable[k] = self.lianTiAttrTable[k] + v.value
	end
	for k,v in pairs(self.lianTiAttrTable) do
		self.lianTiAttribute:addAttr(k,v)
	end
	self:updateTotalAttr()
end

function CardRole:getExtraLianTiAttri()
	self.LianTiData = self.LianTiData or {}
	local pointQuaNum = {}
	local maxQua = 1
	for k,v in pairs(self.LianTiData) do
		pointQuaNum[v.quality] = pointQuaNum[v.quality] or 0
		pointQuaNum[v.quality] = pointQuaNum[v.quality] + 1
		if v.quality > maxQua then
			maxQua = v.quality
		end
	end
	for i=1,maxQua do
		for j=2,maxQua do
			if i < j then
				pointQuaNum[i] = pointQuaNum[i] or 0
				pointQuaNum[j] = pointQuaNum[j] or 0
				pointQuaNum[i] = pointQuaNum[i] + pointQuaNum[j]
			end
		end
	end
	-- print("CardRole:getExtraLianTiAttri()  pointQuaNum, ",pointQuaNum)
	local curitem = {id = 0,meridians = 0,breakthrough = 0,attribute = {},addNum = 0}
	for item in LianTiExtraData:iterator() do
		local num = pointQuaNum[item.quality] or 0
		if num >= item.number then
			if curitem.id < item.id then
				curitem.id = item.id
				if item.attribute ~= "" and item.attribute ~= "0" then
					curitem.attribute = item:getAttributeValue()
					for k,v in pairs(curitem.attribute) do
						if v.value > 0 and v.value > curitem.addNum then
							curitem.addNum = v.value
						end
					end
				end
				if curitem.meridians < item.meridians then
					curitem.meridians = item.meridians
				end
				if curitem.breakthrough < item.breakthrough then
					curitem.breakthrough = item.breakthrough
				end
			end
		end
	end
	local ret = {meridians = curitem.meridians,breakthrough = curitem.breakthrough,attribute = curitem.attribute,addNum = curitem.addNum}
	return ret
end

function CardRole:getLianTiAttrDetail()
	return self.lianTiAttrTable
end
function CardRole:getLianTiTotalAttribute(index)
	return self.lianTiAttrTable[index] or 0
end

function CardRole:getLianTiDataById(id)
	self.LianTiData = self.LianTiData or {}
	return self.LianTiData[ id ]
end

function CardRole:getMaxLianTiQua()
	local quality = 0
	for k,v in pairs(self.LianTiData) do
		if quality < v.quality then
			quality = v.quality
		end
	end
	return quality
end

function CardRole:setPosByFightType( fight_type,pos )
	self.fightTypePos[fight_type] = pos
end

function CardRole:getPosByFightType( fight_type )
	if self.fightTypePos[fight_type] then
		return self.fightTypePos[fight_type]
	end
	return 0
end
return CardRole