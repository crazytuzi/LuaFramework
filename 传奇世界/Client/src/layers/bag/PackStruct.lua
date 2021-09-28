local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
local Mconvertor = require "src/config/convertor"
local MpropOp = require "src/config/propOp"
local MequipOp = require "src/config/equipOp"
local MObserver = require "src/young/observer"
-----------------------------------------------------------------------
-- 包裹类型
eBag = 1 -- 背包
eBank = 2	-- 仓库
eDress = 3	-- 着装
eRecycle = 4 -- 商店回收包裹
eRide = 5 -- 兽栏
eRideDress1 = 6 --灵兽装备背包
eRideDress2 = 7
eRideDress3 = 8
eRideDress4 = 9
eRideDress5 = 10
eRideDress6 = 11
eRideDress7 = 12
eRideDress8 = 13
eRideDress9 = 14
eRideDress10 = 15
-----------------------------------------------------------------------
-- 道具过滤器
eAll = -1 -- 所有
eOther = 0 -- 其他
eEquipment = 1 -- 装备
eMedicine = 2 -- 药品
eAny = 3 -- 任何类别
eRideEquipment=22 --灵兽装备
-----------------------------------------------------------------------
-- 装备的着装位置名字
eWeapon = 1	    -- 武器
eClothing = 2	-- 衣服
eHelmet = 3	    -- 头盔
eNecklace = 4	-- 项链
eCuffLeft = 5	-- 护腕左
eCuffRight = 6	-- 护腕右
eRingLeft = 7	-- 戒指左
eRingRight = 8	-- 戒指右
eSuit = 9	    -- 时装
eBelt = 10	    -- 腰带
eShoe = 11	    -- 鞋子
eMedal = 12	    -- 勋章

local tEquipId = {
	[eWeapon] = Mconvertor.eWeapon,
	[eClothing] = Mconvertor.eClothing,
	[eHelmet] = Mconvertor.eHelmet,
	[eNecklace] = Mconvertor.eNecklace,
	[eCuffLeft] = Mconvertor.eCuff,
	[eCuffRight] = Mconvertor.eCuff,
	[eRingLeft] = Mconvertor.eRing,
	[eRingRight] = Mconvertor.eRing,
	[eSuit] = Mconvertor.eSuit,
	[eBelt] = Mconvertor.eBelt,
	[eShoe] = Mconvertor.eShoe,
	[eMedal] = Mconvertor.eMedal,
}

equipId = function(location)
	return tEquipId[location]
end

local tDressId = {
	[Mconvertor.eWeapon] = eWeapon,
	[Mconvertor.eClothing] = eClothing,
	[Mconvertor.eHelmet] = eHelmet,
	[Mconvertor.eNecklace] = eNecklace,
	[Mconvertor.eCuff] = 0,
	[Mconvertor.eRing] = 0,
	[Mconvertor.eSuit] = eSuit,
	[Mconvertor.eBelt] = eBelt,
	[Mconvertor.eShoe] = eShoe,
	[Mconvertor.eMedal] = eMedal,
}

dressId = function(equipId)
	return tDressId[equipId]
end
-----------------------------------------------------------------------
-- 物品的实例属性名字
eAttrRandom = 1 -- 随机属性 table
eAttrStrengthLevel = 2 -- 强化等级	BYTE
eAttrBind = 3 -- 是否绑定	bool
eAttrExpiration = 4 -- 限时道具的到期时间
eAttrStallPrice = 6 -- 拍卖价格
eAttrStallTime = 7 -- 拍卖时间
eAttrStallWaitTime = 20 -- 上架尚需等待的时间, 0表示已经上架
eAttrLuck = 8 -- 装备幸运值
eAttrQuality = 30
eAttrSpecial = 31 -- 极品属性
------------------------------
eAttrPAttack = 31 -- 物理攻击
eAttrPDefense = 32 -- 物理防御
eAttrMAttack = 33 -- 魔法攻击
eAttrMDefense = 34 -- 魔法防御
eAttrTAttack = 35 -- 道术攻击
------------------------------
eAttrHP = 36 -- 生命
eAttrMP = 37 -- 法力
eAttrHit = 39 -- 命中
eAttrDodge = 40 -- 闪避
eAttrStrike = 41 -- 暴击
eAttrTenacity = 42 -- 韧性
eAttrHuShenRift = 43 -- 护身穿透
eAttrHuShen = 44 -- 护身
eAttrFreeze = 45 -- 冰冻
eAttrFreezeOppose = 46 -- 冰冻抵抗
------------------------------
eAttrGroup = 70 -- 属组
eAttrEvolve = 71 -- 进化
eAttrName = 72 -- 物品名字
eAttrSchool = 73 -- 使用职业
eAttrLevel = 74 -- 使用最低等级
eAttrCombatPower = 75 -- 战斗力
------------------------------

local tSchoolAttack = 
{
	[1] = eAttrPAttack,
	[2] = eAttrMAttack,
	[3] = eAttrTAttack,
}

schoolAttack = function(school)
	return tSchoolAttack[school]
end
-----------------------------------------------------------------------
--[[
local PackStruct =
{
	mPackType = nil,
	mNumOfGirdOpened = nil, mMaxNumOfGirdCanOpen = nil,
	mEachOfGird =
	{
		mGirdSlot =
		{
			mGuid = nil,
			mGirdSlot = nil,
			mPropProtoId = nil,
			mPropCategory = nil,
			mNumOfOverlay = nil, mMaxNumOfOverlay = nil,
			mEachOfSpecialAttr =
			{
				key = value,
			},
			
			mRandomAttrsOrder = 
			{
				i = value,
			},
		}
	},
	
	mSpecialAttr = nil,
	
	mEquipment = nil,
	mMedicine = nil,
	mOther = nil,
	mAny = nil,
	
	mPrototype = nil,
}
--]]

local mObservables = 
{
	[eBag] = MObserver.new(),
	[eBank] = MObserver.new(),
	[eDress] = MObserver.new(),
	[eRecycle] = MObserver.new(),
	[eRide] = MObserver.new(),
	[eRideDress1]=MObserver.new(),
	[eRideDress2]=MObserver.new(),
	[eRideDress3]=MObserver.new(),
	[eRideDress4]=MObserver.new(),
	[eRideDress5]=MObserver.new(),
	[eRideDress6]=MObserver.new(),
	[eRideDress7]=MObserver.new(),
	[eRideDress8]=MObserver.new(),
	[eRideDress9]=MObserver.new(),
	[eRideDress10]=MObserver.new(),
}

packId = function(this)
	return this.mPackType
end

local observable = function(this)
	return mObservables[this:packId()]
end

register = function(this, observer)
	observable(this):register(observer)
end

unregister = function(this, observer)
	observable(this):unregister(observer)
end

broadcast = function(this, ...)
	observable(this):broadcast(this, ...)
end

packName = function(this)
	local switch = {
		[eBag] = "背包",
		[eBank] = "仓库",
		[eDress] = "着装",
		[eRecycle] = "回收",
		[eRide] = "兽栏",
		[eRideDress1]="灵兽着装1",
		[eRideDress2]="灵兽着装2",
		[eRideDress3]="灵兽着装3",
		[eRideDress4]="灵兽着装4",
		[eRideDress5]="灵兽着装5",
		[eRideDress6]="灵兽着装6",
		[eRideDress7]="灵兽着装7",
		[eRideDress8]="灵兽着装8",
		[eRideDress9]="灵兽着装9",
		[eRideDress10]="灵兽着装10",
	}
	return switch[this.mPackType]
end

userData = function(this, userData)
	if not userData then
		return this.mUserData
	else
		this.mUserData = userData
	end
end

local tGirdCanOpen = {
	[eBag] = 100,
	[eBank] = 100,
	[eDress] = 12,
	[eRecycle] = 30,
	[eRide] = 10,
	[eRideDress1]=6,
	[eRideDress2]=6,
	[eRideDress3]=6,
	[eRideDress4]=6,
	[eRideDress5]=6,
	[eRideDress6]=6,
	[eRideDress7]=6,
	[eRideDress8]=6,
	[eRideDress9]=6,
	[eRideDress10]=6,
}

maxNumOfGirdCanOpen = function(this)
	return tGirdCanOpen[this.mPackType]
end

numOfGirdOpened = function(this)
	return this.mNumOfGirdOpened
end

numOfGirdRemain = function(this)
	return this:numOfGirdOpened() - this:numOfCategory(eAll)
end

numOfCategory = function(this, filter)
	local switch = 
	{
		[eAll] = #this.mAny,
		[eEquipment] = #this.mEquipment,
		[eMedicine] = #this.mMedicine,
		[eOther] = #this.mOther,
		[eAny] = #this.mAny,
	}
	
	return switch[filter]
end

categoryList = function(this, filter)
	local switch = 
	{
		[eAll] = this.mAny,
		[eEquipment] = this.mEquipment,
		[eMedicine] = this.mMedicine,
		[eOther] = this.mOther,
		[eAny] = this.mAny,
	}
	
	return switch[filter]
end

filterGirdId = function(this, globalGirdId, filter)
	for i, v in ipairs( this:categoryList(filter) ) do
		if v.mGirdSlot == globalGirdId then
			return i
		end
	end
end

numOfGirdUsed = function(this)
	return this:numOfCategory(eAll)
end

checkNum = function(this)
	-----------------------------------------
	local other = this:numOfCategory(eOther)
	--dump(other, "eOther")
	local equipment = this:numOfCategory(eEquipment)
	--dump(equipment, "eEquipment")
	local medicine = this:numOfCategory(eMedicine)
	--dump(medicine, "eMedicine")
	local all = this:numOfCategory(eAll)
	--dump(all, "eAll")
	if  other + equipment + medicine ~= all then
		--assert(false, "分类数目之和必须等于总数")
		-- dump(debug.traceback(), "分类数目之和不等于总数")
	end
	-----------------------------------------
end

getCategoryByPropId = function(this, id)
	local cate = MpropOp.category(id)
	cate = cate == eRideEquipment and eEquipment or cate
	if cate ~= eEquipment  and cate ~= eMedicine then cate = eOther end
	return cate
end
-----------------------------------------------------------
getGirdByGirdId = function(this, girdId, filter)
	local filter = filter or eAll

	local switch = 
	{
		[eAll] = this.mEachOfGird,
		[eEquipment] = this.mEquipment,
		[eMedicine] = this.mMedicine,
		[eOther] = this.mOther,
		[eAny] = this.mAny,
	}

	return switch[filter][girdId]
end

buildGirdFromProtoId = function(this, protoId)
	return {
		mGirdSlot = nil,
		mPropProtoId = protoId,
		mPropCategory = this:getCategoryByPropId(protoId),
		mNumOfOverlay = 1, 
		mMaxNumOfOverlay = MpropOp.maxOverlay(protoId),
		mNumOfSpecialAttr = 0,
		mEachOfSpecialAttr = { },
	}
end

buildGrid = function(this, params)
	local ret = {}

	local protoId = params.protoId
	ret.mGirdSlot = params.gridId
	ret.mPropProtoId = protoId
	ret.mPropCategory = this:getCategoryByPropId(protoId)
	ret.mNumOfOverlay = params.num or 1
	ret.mMaxNumOfOverlay = MpropOp.maxOverlay(protoId)

	local attr = params.attr or {}
	ret.mEachOfSpecialAttr = attr
	ret.mNumOfSpecialAttr = table.size(attr)
	
	return ret
end

gridSetOverlay = function(grid, num)
	grid.mNumOfOverlay = num
end
-----------------------------------------------------------
-- each of gird
guidFromGird = function(gird)
	return gird and gird.mGuid
end

-- 获取原型id
protoId = function(this, girdId, filter)
	local aGird = getGirdByGirdId(this, girdId, filter)
	return aGird and aGird.mPropProtoId
end

protoIdFromGird = function(gird)
	return gird and gird.mPropProtoId
end

-- 获取叠加数量
numOfOverlay = function(this, girdId, filter)
	local aGird = getGirdByGirdId(this, girdId, filter)
	return aGird and aGird.mNumOfOverlay
end

overlayFromGird = function(gird)
	return gird and gird.mNumOfOverlay
end

-- 获取包裹格子索引
globalGirdId = function(this, girdId, filter)
	local aGird = getGirdByGirdId(this, girdId, filter)
	return aGird and aGird.mGirdSlot
end

girdIdFromGird = function(gird)
	return gird and gird.mGirdSlot
end

-- 获取道具所属分类
category = function(this, girdId, filter)
	local aGird = getGirdByGirdId(this, girdId, filter)
	return aGird and aGird.mPropCategory
end

categoryFromGird = function(gird)
	return gird and gird.mPropCategory
end

-- 是否是实例物品
isSpecialFromGird = function(gird)
	return gird and gird.mEachOfSpecialAttr and table.maxn(gird.mEachOfSpecialAttr) > 0
end

isSpecial = function(this, girdId, filter)
	local aGird = getGirdByGirdId(this, girdId, filter)
	return aGird and aGird.mEachOfSpecialAttr and table.maxn(aGird.mEachOfSpecialAttr) > 0
end

-- 极品属性
specialAttrFromGird = function(gird)
	return gird and gird.mSpecialAttr
end

-- 勋章底纹
emblazonry1 = function(gird)
	local wen = {}
	if gird and gird.emblazonry1 and gird.emblazonry1 > 0 then
		local num = gird.emblazonry1/10
		local num1,num2 = math.modf(num)
		wen = {math.floor(num1),math.ceil(num2)}
		return wen
	end
	return 0
end

-- 勋章边纹
emblazonry2 = function(gird)
	local wen = {}
	if gird and gird.emblazonry2 and gird.emblazonry2 > 0 then
		local num = gird.emblazonry2/10
		local num1,num2 = math.modf(num)
		wen = {math.floor(num1),math.ceil(num2)}
		return wen
	end
	return 0
end


-- 勋章饰纹
emblazonry3 = function(gird)
	local wen = {}
	if gird and gird.emblazonry3 and gird.emblazonry3 > 0 then
		local num = gird.emblazonry3/10
		local num1,num2 = math.modf(num)
		wen = {math.floor(num1),math.ceil(num2)}
		return wen
	end
	return 0
end

-- 某纹饰是否激活
active = function(gird)
	return gird and gird.active
end

-----------------------------------------------------------
-- 实例属性操作
attrValue = function(gird, attrName)
	local attrs = gird and gird.mEachOfSpecialAttr
	return attrs and attrs[attrName]
end

local calc1 = function(gird, name)
	if gird ~= nil and (gird.mPropCategory == eEquipment or MpropOp.category(gird.mPropProtoId)==21)then
		local protoId = gird.mPropProtoId
		local strengthLv = MPackStruct.attrFromGird(gird, MPackStruct.eAttrStrengthLevel)
		local base = MequipOp.combatAttr(protoId, name)
		--dump(base, "base")
		local grow = MequipOp.upStrengthCombatAttr(name, protoId, strengthLv)
		--dump(grow, "grow")
		local randomAttrSet = MPackStruct.attrFromGird(gird, MPackStruct.eAttrRandom)
		local random = MPackStruct.randomCombatAttr(name, randomAttrSet)
		--dump(random, "random")
		base["["] = base["["] + grow["["] + random["["]
		base["]"] = base["]"] + grow["]"] + random["]"]
		return base
	else
		return { ["["] = 0, ["]"] = 0 }
	end
end

local calc2 = function(gird, name, base_func, grow_func)
	if gird ~= nil and (gird.mPropCategory == eEquipment or MpropOp.category(gird.mPropProtoId)==21) then
		local protoId = gird.mPropProtoId
		local strengthLv = MPackStruct.attrFromGird(gird, MPackStruct.eAttrStrengthLevel)
		local base = base_func(protoId)
		--dump(base, "base")
		local grow = grow_func(protoId, strengthLv)
		--dump(grow, "grow")
		local randomAttrSet = MPackStruct.attrFromGird(gird, MPackStruct.eAttrRandom)
		local random = MPackStruct.randomAttr(randomAttrSet, name)
		--dump(random, "random")
		base = base + grow + random
		return base
	else
		return 0
	end
end

local tgetAttrActions = 
{
	-- 物品名字
	[eAttrName] = function(gird)
		return MpropOp.name(gird.mPropProtoId)
	end,
	
	-- 使用职业
	[eAttrSchool] = function(gird)
		return MpropOp.schoolLimits(gird.mPropProtoId)
	end,
	
	-- 使用最低等级
	[eAttrLevel] = function(gird)
		return MpropOp.levelLimits(gird.mPropProtoId)
	end,
	
	-- 绑定属性值
	[eAttrBind] = function(gird)
		local value = attrValue(gird, eAttrBind)
		
		if value ~= nil then
			return value and (value ~= 0)
		else
			return MpropOp.bind(gird.mPropProtoId)
		end
	end,
	
	-- 幸运
	[eAttrLuck] = function(gird)
		local value = attrValue(gird, MPackStruct.eAttrLuck)
		return (value or 0) + calc2(gird, MPackStruct.eAttrLuck, MequipOp.luck, MequipOp.upStrengthLuck)
	end,
}

local tgetAttrConfig = {
	-- 品质属性值
	[eAttrQuality] = function(gird)
		return 0
	end,
	
	-- 强化等级属性值
	[eAttrStrengthLevel] = function(gird)
		return 0
	end,
	
	-- 物理攻击
	[eAttrPAttack] = function(gird)
		--dump(calc1(gird, Mconvertor.ePAttack), "calc1(ePAttack)")
		return calc1(gird, Mconvertor.ePAttack)
	end,
	
	-- 物理防御
	[eAttrPDefense] = function(gird)
		return calc1(gird, Mconvertor.ePDefense)
	end,
	
	-- 魔法攻击
	[eAttrMAttack] = function(gird)
		return calc1(gird, Mconvertor.eMAttack)
	end,
	
	-- 魔法防御
	[eAttrMDefense] = function(gird)
		return calc1(gird, Mconvertor.eMDefense)
	end,
	
	-- 道术攻击
	[eAttrTAttack] = function(gird)
		return calc1(gird, Mconvertor.eTAttack)
	end,
	
	-- 生命
	[eAttrHP] = function(gird)
		return calc2(gird, MPackStruct.eAttrHP, MequipOp.maxHP, MequipOp.upStrengthMaxHP)
	end,
	
	-- 法力
	[eAttrMP] = function(gird)
		return calc2(gird, MPackStruct.eAttrMP, MequipOp.maxMP, MequipOp.upStrengthMaxMP)
	end,
	
	-- 幸运
	[eAttrLuck] = function(gird)
		return calc2(gird, MPackStruct.eAttrLuck, MequipOp.luck, MequipOp.upStrengthLuck)
	end,
	
	-- 命中
	[eAttrHit] = function(gird)
		return calc2(gird, MPackStruct.eAttrHit, MequipOp.hit, MequipOp.upStrengthHit)
	end,
	
	-- 闪避
	[eAttrDodge] = function(gird)
		return calc2(gird, MPackStruct.eAttrDodge, MequipOp.dodge, MequipOp.upStrengthDodge)
	end,
	
	-- 暴击
	[eAttrStrike] = function(gird)
		return calc2(gird, MPackStruct.eAttrStrike, MequipOp.strike, MequipOp.upStrengthStrike)
	end,
	
	-- 韧性
	[eAttrTenacity] = function(gird)
		return calc2(gird, MPackStruct.eAttrTenacity, MequipOp.tenacity, MequipOp.upStrengthTenacity)
	end,
	
	-- 护身穿透
	[eAttrHuShenRift] = function(gird)
		return calc2(gird, MPackStruct.eAttrHuShenRift, MequipOp.huShenRift, MequipOp.upStrengthHuShenRift)
	end,
	
	-- 护身
	[eAttrHuShen] = function(gird)
		return calc2(gird, MPackStruct.eAttrHuShen, MequipOp.huShen, MequipOp.upStrengthHuShen)
	end,
	
	-- 冰冻
	[eAttrFreeze] = function(gird)
		return calc2(gird, MPackStruct.eAttrFreeze, MequipOp.freeze, MequipOp.upStrengthFreeze)
	end,
	
	-- 冰冻抵抗
	[eAttrFreezeOppose] = function(gird)
		return calc2(gird, MPackStruct.eAttrFreezeOppose, MequipOp.freezeOppose, MequipOp.upStrengthFreezeOppose)
	end,
	
	-- 属组
	[eAttrGroup] = function(gird)
		if gird ~= nil and gird.mPropCategory == eEquipment then
			return MequipOp.group(gird.mPropProtoId)
		else
			return nil
		end
	end,
	
	-- 进化
	[eAttrEvolve] = function(gird)
		if gird ~= nil and gird.mPropCategory == eEquipment then
			return MequipOp.evolve(gird.mPropProtoId)
		else
			return 0
		end
	end,
	
	-- 战斗力
	[eAttrCombatPower] = function(gird)
		if gird == nil then return 0 end
		
		if gird ~= nil and gird.mPropCategory == eEquipment then
			local MRoleStruct = require("src/layers/role/RoleStruct")
			local MPackStruct = require "src/layers/bag/PackStruct"
			local Mnumerical = require "src/functional/numerical"
			-------------------------------------------------
			local protoId = gird.mPropProtoId
			local school = MpropOp.schoolLimits(protoId)
			local strengthLv = MPackStruct.attrFromGird(gird, MPackStruct.eAttrStrengthLevel)
			
			--勋章做特殊处理
			if protoId >= 30004 and protoId <= 30006 then

				local theLevId = 1000*school+strengthLv
				local battle = getConfigItemByKey("honourCfg","q_ID",theLevId,"battle")

				return tonumber(battle) or 0
			end
			------------------------------------------------------------------------
            --极品属性
            local   specialAttr=MPackStruct.specialAttrFromGird(gird)
            local   MequipOp = require "src/config/equipOp"
            local   Mconvertor = require "src/config/convertor"
            local   protoId = MPackStruct.protoIdFromGird(gird)
            local   attrCate = MequipOp.specialAttrCate(protoId)
            local   isRange = Mconvertor.isRangeAttr(attrCate)
            local   eachLayerValue = MequipOp.specialAttrEachLayerValue(protoId)
            local   specialValue=specialAttr and specialAttr*eachLayerValue
            local   attrTable={ [MPackStruct.eAttrPDefense]         ="pDefense",
                                [MPackStruct.eAttrMDefense]         ="mDefense", 
                                [MPackStruct.eAttrLuck]             ="luck",
                                [MPackStruct.eAttrHP]               ="hp",
                                [MPackStruct.eAttrHit]              ="hit",
                                [MPackStruct.eAttrDodge]            ="dodge",
                                [MPackStruct.eAttrStrike]           ="strike",
                                [MPackStruct.eAttrTenacity]         ="tenacity",
                                [MPackStruct.eAttrHuShenRift]       ="hu_shen_rift",
                                [MPackStruct.eAttrHuShen]           ="hu_shen",
                                [MPackStruct.eAttrFreeze]           ="freeze",
                                [MPackStruct.eAttrFreezeOppose]     ="freeze_oppose",
                            }

            local params={}
            params.school=school
            --攻击力单独算
            params.attack = MPackStruct.attrFromGird(gird, MPackStruct.schoolAttack(school))
            --把极品属性的的类型，转换成MPackStruct里能识别的类型
            local specialAttrKey=tSpecialToPackStructMap[attrCate]
            if specialAttr and specialAttrKey and MPackStruct.schoolAttack(school)==specialAttrKey then
                params.attack["]"]= params.attack["]"]+specialValue
            end
            for k,v in pairs(attrTable) do
                params[v]=MPackStruct.attrFromGird(gird, k)
                --加上极品属性
                if specialAttr and  specialAttrKey and specialAttrKey==k then
                    if isRange then
                        params[v]["]"]=params[v]["]"]+specialValue
                    else
                        params[v]=params[v]+specialValue
                    end
                   
                end
            end
			return Mnumerical:calcCombatPowerRange(params)
		else
			local protoId = gird.mPropProtoId
			
			-- 各种潜能丹
			if protoId >= 1003 and protoId <= 1014 then
				local Mnumerical = require "src/functional/numerical"
				local MPotencyOp = require "src/config/PotencyOp"
				-------------------------------------------------
				local school = MPotencyOp:school(protoId)
				local base = MPotencyOp:combatAttr(protoId, "all")
				return Mnumerical:calcCombatPowerRange(
				{
					school = school,
					attack = base[Mconvertor:schoolAttack(school)],
					pDefense = base[Mconvertor.ePDefense],
					mDefense = base[Mconvertor.eMDefense],
					luck = MPotencyOp:luck(protoId),
					hp = MPotencyOp:maxHP(protoId),
					hit = MPotencyOp:hit(protoId),
					dodge = MPotencyOp:dodge(protoId),
				})
			else
				return 0
			end
		end
	end,
}

-- 获取单一属性值
attrFromGird = function(gird, attrName)
	local action = nil
	---------------------------------------
	action = tgetAttrActions[attrName]
	if action then return action(gird) end
	---------------------------------------
	local value = attrValue(gird, attrName)
	if value ~= nil then return value end
	---------------------------------------
	action = tgetAttrConfig[attrName]
	if action then return action(gird) end
	---------------------------------------
end

-- 获取一组属性值
attrsFromGird = function(gird, attrNameSet, ret)
	local ret = ret or {}
	
	local name = nil
	for i = 1, #attrNameSet do
		name = attrNameSet[i]
		ret[name] = attrFromGird(gird, name)
	end
	
	return ret
end

orderedRandomAttrFromGird = function(grid)
	return grid and grid.mRandomAttrsOrder or {}
end
------------------------------------------------------
-- 随机属性
local tRandomAttrs = 
{
	[ROLE_MIN_AT] = { name = "物理攻击", max = "q_attack" },
	[ROLE_MAX_AT] = { name = "物理攻击", max = "q_attack" },
	[ROLE_MIN_DF] = { name = "物理防御", max = "q_defence" },
	[ROLE_MAX_DF] = { name = "物理防御", max = "q_defence" },
	[ROLE_MIN_MT] = { name = "魔法攻击", max = "q_magic_attack" },
	[ROLE_MAX_MT] = { name = "魔法攻击", max = "q_magic_attack" },
	[ROLE_MIN_MF] = { name = "魔法防御", max = "q_magic_defence" },
	[ROLE_MAX_MF] = { name = "魔法防御", max = "q_magic_defence" },
	[ROLE_MIN_DT] = { name = "道术攻击", max = "q_sc_attack" },
	[ROLE_MAX_DT] = { name = "道术攻击", max = "q_sc_attack" },
	--------------------
	[ROLE_MAX_HP] = { name = "生命", max = "q_max_hp" },
	[ROLE_MAX_MP] = { name = "法力", },
	[PLAYER_LUCK] = { name = "幸运", max = "q_luck" },
	[ROLE_HIT] = { name = "命中", max = "q_hit" },
	[ROLE_DODGE] = { name = "闪避", max = "q_dodge" },
	[ROLE_CRIT] = { name = "暴击", max = "q_crit" },
	[ROLE_TENACITY] = { name = "韧性", max = "q_tenacity" },
	[PLAYER_PROJECT_DEF] = { name = "护身穿透", max = "q_projectDef" },
	[PLAYER_PROJECT] = { name = "护身", max = "q_project" },
	[PLAYER_BENUMB] = { name = "冰冻", max = "q_benumb" },
	[PLAYER_BENUMB_DEF] = { name = "冰冻抵抗", max = "q_benumbDef" },
}

getRandomAttrLevel = function( protoId, nId, nValue1, nValue2 )
	-- body
	local max_cfg = DB.get("EquipRandPropDB", "q_id", protoId)
	if not max_cfg then
		return 1
	end
	-- dump(max_cfg)
	local nValue = nValue1
	if nValue2 then
		nValue = nValue2
	end
	local max_value = tonumber(max_cfg[tRandomAttrs[nId].max]) or 0
	local level = math.max(math.floor(nValue/(max_value/(tonumber(max_cfg.q_maxFloor or 1)))), 1)
	return level
end

local tRandomAttrLevelColor = {
	[1] = MColor.white,
	[2] = MColor.white,
	[3] = MColor.green,
	[4] = MColor.green,
	[5] = MColor.blue,
	[6] = MColor.blue,
	[7] = MColor.purple,
	[8] = MColor.purple,
}
getRandomAttrColor = function( nLevel )
	-- body
	return tRandomAttrLevelColor[nLevel]
end

local calc_random_attr = function(attr_set, min_name, max_name)
	local isRange = max_name ~= nil
	if isRange then
		local sum_l, sum_r = 0, 0
		local list = {}
		local ids = {}
		if attr_set then
			local set_l = attr_set[min_name]
			local set_r = attr_set[max_name]
			if type(set_l) == "table" and type(set_r) == "table" then
				for i = 1, #set_l do
					local v_l = type(set_l[i]) == "table" and set_l[i].value or 0
					local v_r = type(set_r[i]) == "table" and set_r[i].value or 0
					sum_l = sum_l + v_l
					sum_r = sum_r + v_r
					list[#list+1] = { ["["] = v_l, ["]"] = v_r }
					ids[#ids + 1] = {["["] = min_name, [']'] = max_name}
				end
			end
		end
		
		return sum_l, sum_r, list, ids
	else
		local sum = 0
		local list = {}
		local ids = {}
		if attr_set then
			local set = attr_set[min_name]
			if type(set) == "table" then
				for i = 1, #set do
					local v = set[i].value
					sum = sum + v
					list[#list+1] = v
					ids[#ids + 1] = {["["] = min_name}
				end
			end
		end
		return sum, list, ids
	end
end

local tRandomAttrConfig = {
	-- 物理攻击
	[eAttrPAttack] = function(attr_set)
		return calc_random_attr(attr_set, ROLE_MIN_AT, ROLE_MAX_AT)
	end,
	
	-- 物理防御
	[eAttrPDefense] = function(attr_set)
		return calc_random_attr(attr_set, ROLE_MIN_DF, ROLE_MAX_DF)
	end,
	
	-- 魔法攻击
	[eAttrMAttack] = function(attr_set)
		return calc_random_attr(attr_set, ROLE_MIN_MT, ROLE_MAX_MT)
	end,
	
	-- 魔法防御
	[eAttrMDefense] = function(attr_set)
		return calc_random_attr(attr_set, ROLE_MIN_MF, ROLE_MAX_MF)
	end,
	
	-- 道术攻击
	[eAttrTAttack] = function(attr_set)
		return calc_random_attr(attr_set, ROLE_MIN_DT, ROLE_MAX_DT)
	end,
	
	-- 生命
	[eAttrHP] = function(attr_set)
		return calc_random_attr(attr_set, ROLE_MAX_HP)
	end,
	
	-- 法力
	[eAttrMP] = function(attr_set)
		return calc_random_attr(attr_set, ROLE_MAX_MP)
	end,
	
	-- 幸运
	[eAttrLuck] = function(attr_set)
		return calc_random_attr(attr_set, PLAYER_LUCK)
	end,
	
	-- 命中
	[eAttrHit] = function(attr_set)
		return calc_random_attr(attr_set, ROLE_HIT)
	end,
	
	-- 闪避
	[eAttrDodge] = function(attr_set)
		return calc_random_attr(attr_set, ROLE_DODGE)
	end,
	
	-- 暴击
	[eAttrStrike] = function(attr_set)
		return calc_random_attr(attr_set, ROLE_CRIT)
	end,
	
	-- 韧性
	[eAttrTenacity] = function(attr_set)
		return calc_random_attr(attr_set, ROLE_TENACITY)
	end,
	
	-- 护身穿透
	[eAttrHuShenRift] = function(attr_set)
		return calc_random_attr(attr_set, PLAYER_PROJECT_DEF)
	end,
	
	-- 护身
	[eAttrHuShen] = function(attr_set)
		return calc_random_attr(attr_set, PLAYER_PROJECT)
	end,
	
	-- 冰冻
	[eAttrFreeze] = function(attr_set)
		return calc_random_attr(attr_set, PLAYER_BENUMB)
	end,
	
	-- 冰冻抵抗
	[eAttrFreezeOppose] = function(attr_set)
		return calc_random_attr(attr_set, PLAYER_BENUMB_DEF)
	end,
}

randomAttr = function(attr_set, attrName)
	return tRandomAttrConfig[attrName](attr_set)
end


local tRandomAttrPair = {
	[ROLE_MAX_AT] = true,
	[ROLE_MAX_DF] = true,
	[ROLE_MAX_MT] = true,
	[ROLE_MAX_MF] = true,
	[ROLE_MAX_DT] = true,
}

numOfRandomAttr = function(attr_set)
	local ret = 0
	if type(attr_set) == "table" then
		for k, v in pairs(attr_set) do
			if not tRandomAttrPair[k] then
				ret = ret + #v
			end
		end
	end
	return ret
end

-- 随机属性-战斗属性
local tRandomCombatAttr = 
{
	[Mconvertor.ePAttack] = function(attr_set)
		return randomAttr(attr_set, eAttrPAttack)
	end,
	
	[Mconvertor.eMAttack] = function(attr_set)
		return randomAttr(attr_set, eAttrMAttack)
	end,
	
	[Mconvertor.eTAttack] = function(attr_set)
		return randomAttr(attr_set, eAttrTAttack)
	end,
	
	[Mconvertor.ePDefense] = function(attr_set)
		return randomAttr(attr_set, eAttrPDefense)
	end,
	
	[Mconvertor.eMDefense] = function(attr_set)
		return randomAttr(attr_set, eAttrMDefense)
	end,
}

-- 基础战斗属性值
randomCombatAttr = function(name, attr_set)
	local lower, upper
	if type(name) == "number" then
		lower, upper = tRandomCombatAttr[name](attr_set)
		return { ["["] = lower, ["]"] = upper }
	end
	
	if name == "all" then name = Mconvertor.eCombatAttrList end
	
	if type(name) == "table" then
		local ret = {}
		for i, v in ipairs(name) do
			lower, upper = tRandomCombatAttr[v](attr_set)
			ret[v] = { ["["] = lower, ["]"] = upper }
		end
		return ret
	end
end
------------------------------------------------------

girdInfoFromGird = function(gird, attrNameSet)
	local ret = {}
	ret.girdId = gird.mGirdSlot
	ret.protoId = gird.mPropProtoId
	ret.num = gird.mNumOfOverlay
	ret.maxNum = gird.mMaxNumOfOverlay
	ret.type = gird.mPropCategory
	ret.attrs = attrsFromGird(gird, attrNameSet)
	return ret
end

girdInfo = function(this, girdId, attrNameSet, filter)
	local aGird = getGirdByGirdId(this, girdId, filter)
	return aGird and girdInfoFromGird(aGird, attrNameSet)
end
-----------------------------------------------------------
-- 获取包裹中某原型id的物品数量
countByProtoId = function(this, protoId)
	local repertory = this.mPrototype[tonumber(protoId) or 0]
	if not repertory then return 0 end
	--dump(repertory, "repertory")
	local count = 0
	local girdId = nil
	local minNum = 0
	local overlay = nil
	for k, v in pairs(repertory) do
		--dump(k, "k")
		--dump(this:numOfOverlay(k), "this:numOfOverlay(k)")
		
		local attrs = v.mEachOfSpecialAttr
		local expiration = attrs and attrs[eAttrExpiration]
		if expiration == nil or os.time() <= expiration then
			overlay = this:numOfOverlay(k) or 0
			count = count + overlay
			
			if girdId == nil then
				girdId = v.mGirdSlot
				minNum = overlay
			end
			
			if overlay < minNum then
				girdId = v.mGirdSlot
				minNum = overlay
			end
		end
	end
	return count, girdId
end

getGirdsByProtoId = function(this, protoId)
	return this.mPrototype[protoId]
end

filtrate = function(this, handler, filter)
	local ret = {}
	
	for i, v in ipairs( this:categoryList(filter) ) do
		if not handler or handler(v) then
			ret[#ret + 1] = v
		end
	end
	
	return ret
end
-----------------------------------------------------------
local init = function(this, packType)
	this.mPackType = packType
	this.mNumOfGirdOpened = this:maxNumOfGirdCanOpen()
	this.mMaxNumOfGirdCanOpen = this:maxNumOfGirdCanOpen()
	this.mNumOfGirdUsed = 0
	this.mEachOfGird = {}
	this.mEquipment = {}
	this.mMedicine = {}
	this.mOther = {}
	this.mAny = {}
	this.mPrototype = {}
end

reset = function(this)
	local packId = this:packId()
	init(this, packId)
end


new = function(packType)
	local this = Myoung.newSubModule(M)
	init(this, packType)
	return this
end
---- 极品属性key对应MPackStruct中属性key表
tSpecialToPackStructMap = 
{
	[Mconvertor.eHP]        = eAttrHP,
	[Mconvertor.ePAttack]   = eAttrPAttack,
	[Mconvertor.eMAttack]   = eAttrMAttack,
	[Mconvertor.eTAttack]   = eAttrTAttack,
	[Mconvertor.ePDefense]  = eAttrPDefense,
	[Mconvertor.eMDefense]  = eAttrMDefense,
	[Mconvertor.eMingZhong] = eAttrHit,
	[Mconvertor.eShanBi]    = eAttrDodge,
	[Mconvertor.eBaoji]     = eAttrStrike,
	[Mconvertor.eRenXing]   = eAttrTenacity,
}
-----------------------------------------------------------
_G.MPackStruct = M
-----------------------------------------------------------









