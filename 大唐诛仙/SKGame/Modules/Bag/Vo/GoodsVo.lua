-- 一个物品数据
GoodsVo = BaseClass()
local _itm = "item"
local _eqm = "equipment"

local _none= "none"
local _equipment= "equipment"
local _item= "item"
local _gold= "gold"
local _diamond= "diamond"
local _bindDiamond= "bindDiamond"
local _contribution= "contribution"
local _honor= "honor"
local _exp= "exp"
local _stone= "stone"

local _k2none = "通用"
local _k2equipment = "装备"
local _k2item = "材料"
local _k2gold = "金币"
local _k2diamond = "元宝"
local _k2bindDiamond = "代金卷"
local _k2contribution = "贡献"
local _k2honor = "荣誉"
local _k2exp = "经验"
local _k2stone = "宝玉"

local etn0 = "装备"
local etn1 = "头盔"
local etn2 = "铠甲"
local etn3 = "鞋子"
local etn4 = "项链"
local etn5 = "护腕"
local etn6 = "戒指"
local etn7 = "武器"
local etn8 = "法宝"

local ttn10 = "任务物品"
local ttn20 = "红药"
local ttn30 = "蓝药"
local ttn40 = "复活"
local ttn50 = "灵石"
local ttn60 = "随机铭文"
local ttn70 = "PK药"
local ttn80 = "定向铭文"
local ttn11 = "礼包"
local ttn52 = "技能书"

local _rc0 = "#ebebeb"
local _rc1 = "#ebebeb"
local _rc2 = "#3dc476"
local _rc3 = "#5fb6ff"
local _rc4 = "#b854ff"
local _rc5 = "#ffc228"
local _rc6 = "#f73116"

local _2rc0 = "#2e3341"
local _2rc1 = "#2e3341"
local _2rc2 = "#348a37"
local _2rc3 = "#1b72de"
local _2rc4 = "#b52aba"
local _2rc5 = "#d89401"
local _2rc6 = "#e13710"

--=============静态数据============================================================>>
	GoodsVo.GoodIcon = { -- 资源数据类型(server)
		[0] = _none,
		[1] = _equipment,
		[2] = _item,
		[3] = _gold,
		[4] = _diamond,
		[5] = _bindDiamond,
		[6] = _contribution,
		[7] = _honor,
		[8] = _exp,
		[9] = _stone,
	}
	GoodsVo.GoodType = { -- 资源数据类型id(server)
		none = 0,
		equipment = 1,
		item = 2,
		gold = 3,
		diamond = 4,
		bindDiamond = 5,
		contribution = 6,
		honor = 7,
		exp = 8,
		stone = 9,
		box = 12,
		buff = 13
	}
	GoodsVo.GoodTypeKeyToName = { -- 资源数据类型名字(server)
		none = _k2none,
		equipment = _k2equipment,
		item = _k2item,
		gold = _k2gold,
		diamond = _k2diamond,
		bindDiamond = _k2bindDiamond,
		contribution = _k2contribution,
		honor = _k2honor,
		exp = _k2exp,
		stone = _k2stone
	}
	GoodsVo.GoodTypeName = { -- 资源数据类型名字(server)
		[0] = _k2none,
		[1] = _k2equipment,
		[2] = _k2item,
		[3] = _k2gold,
		[4] = _k2diamond,
		[5] = _k2bindDiamond,
		[6] = _k2contribution,
		[7] = _k2honor,
		[8] = _k2exp,
		[9] = _k2stone,
	}

	-- 物品小类 
	GoodsVo.TinyTypeName = {
		[10] = ttn10,
		[20] = ttn20,
		[30] = ttn30,
		[40] = ttn40,
		[50] = ttn50,
		[60] = ttn60,
		[70] = ttn70,
		[80] = ttn80,
		[11] = ttn11,
		[52] = ttn52,
	}
	GoodsVo.TinyTypeMap = {
		[1] = 10,
		[2] = 20,
		[3] = 30,
		[4] = 40,
		[5] = 50,
		[6] = 60,
		[7] = 70,
		[8] = 80,
		[9] = 11,
		[10] = 52
	}
	GoodsVo.TinyType = {
		task = 10,
		hp = 20,
		mp = 30,
		relife = 40,
		lingshi = 50,
		randomInscriptions = 60,
		pk = 70,
		orientationInscriptions = 80,
		gift = 11,
		skillBook = 52,
	}
	--装备部位
	GoodsVo.EquipPos = {
		None 		= 0,--初始化用
		Head		= 1,--头盔(head)
		Upbody		= 2,--铠甲(upbody)
		Downbody	= 3,--裤子(downbody)
		Neck		= 4,--项链(neck)
		Hand		= 5,--护腕(hand)
		Finger		= 6,--戒指(finger)
		Weapon01	= 7,--武器(weapon01)
		Weapon02	= 8,--法宝(weapon02)
	}
	GoodsVo.EquipTypeName = {
		[0] = etn0,
		[1] = etn1,
		[2] = etn2,
		[3] = etn3,
		[4] = etn4,
		[5] = etn5,
		[6] = etn6,
		[7] = etn7,
		[8] = etn8,
	}

	--品质颜色代码(黑底)
	GoodsVo.RareColor = {
		[0] = _rc0,--白
		[1] = _rc1,--白
		[2] = _rc2,--绿
		[3] = _rc3,--蓝
		[4] = _rc4,--紫
		[5] = _rc5,--橙  
		[6] = _rc6,--红
	}

	--品质颜色代码(聊天)白底
	GoodsVo.RareColor2 = {
		[0] = _2rc0,--白
		[1] = _2rc1,--白
		[2] = _2rc2,--绿
		[3] = _2rc3,--蓝
		[4] = _2rc4,--紫
		[5] = _2rc5,--橙  
		[6] = _2rc6,--红
	}

	-- errorcolor 警告超价格颜色
	GoodsVo.errorcolor = "#e32321"

	-- 获取配置 t类型(对应 GoodsVo)， 表id数据
	function GoodsVo.GetCfg( t, id )
		local cfg = nil
		if t == 1 then -- 装备
			cfg = GetCfgData(_eqm):Get(id)
			-- equipType-- 部位
		elseif id and id ~= 0 then -- 药品|材料
			cfg = GetCfgData(_itm):Get(id)
			-- tinyType -- 子类型
		else -- 其他资产类
			cfg = {
				id = 0,
				goodsType = t,
				icon = GoodsVo.GoodIcon[t],
				name = GoodsVo.GoodTypeName[t]
			}
			if GoodsVo.GoodType.gold == t then
				cfg.rare = 1
			elseif GoodsVo.GoodType.diamond == t or
				   GoodsVo.GoodType.stone == t then
				cfg.rare = 5
			elseif GoodsVo.GoodType.exp == t then
				cfg.rare = 2
			else
				cfg.rare = 3
			end

			-- 无此物品配置自构
		end
		return cfg
	end
	
	-- 获取仅item表中的配置
	function GoodsVo.GetItemCfg(id)
		return GetCfgData(_itm):Get(id)
	end
	-- 获取仅装备表中的装备配置
	function GoodsVo.GetEquipCfg(id )
		return GetCfgData(_eqm):Get(id)
	end

	function GoodsVo.GetEquipRare(id)
		local rtnRare = -1
		local equipCfg = GetCfgData(_eqm):Get(id)
		if equipCfg then
			rtnRare = equipCfg.rare
		end
		return rtnRare
	end

	-- 获取图标资源路径
	function GoodsVo.GetIconUrl( t, id )
		local cfg = GoodsVo.GetCfg( t, id )
		if t==1 then
			if cfg then
				return "Icon/Goods/"..cfg.icon
			else
				logWarn("装备不存在！！"..(t or "nil").."|"..(id or "nil"))
			end
		elseif id and  id ~= 0 then -- 药品|材料
			if cfg then
				return "Icon/Goods/"..cfg.icon
			else
				logWarn("物品不存在！！"..(t or "nil").."|"..(id or "nil"))
			end
		else
			return "Icon/Goods/"..GoodsVo.GoodIcon[t].."_big"
		end
	end
	-- 获取默认品质
	function GoodsVo.GetRare( t, id )
		local rare = 1
		local cfg = GoodsVo.GetCfg( t, id )
		if cfg and cfg.rare ~= 0 then
			return cfg.rare
		else
			logWarn("不存在！！"..(t or "nil").."|"..(id or "nil"))
			return rare
		end
	end
	function GoodsVo.IsRoleCareerData( id )
		local career = LoginModel:GetInstance():GetLoginRole().career
		local v = GoodsVo.GetItemCfg(id)
		if not v then
			v = GoodsVo.GetEquipCfg(id)
		end
		if v and (v.needJob == 0 or v.needJob == career) then
			return true
		end
		if v == nil then
			return true
		end
		return false
	end

--=============动态类结============================================================>>
-- 对象类
function GoodsVo:__init(data)
	self.id = 0 -- 实例id
	self.bid = 0 -- (物品｜装备) 表id
	self.goodsType = 2 -- 物品类别 (1:装备 2：药品 3：材料)	 12对应表goodsType (1.equipment表， 2. item表， 其他:GoodsVo对应)
	self.equipId = 0 -- 装备实例id(goodsType = 1时)(查询装备的实例id)
	self.itemIndex = 0 -- 物品索引下标(格子) 对应PkgCell gid 格子id
	self.num = 0 -- 数量
	self.isBinding = 0 -- 是否绑定(1:是 0：否)
	self.state = 0 -- 物品状态 (1:背包 2:穿戴 其他:空)
	if nil == data then return end
	self.isNew = false -- 是否刚得到
	self:Update(data)
end
function GoodsVo:Update(data)
	if not data then return end
	self.id = toLong(data.playerBagId or data.id)
	self.goodsType = data.goodsType or 2
	self.itemIndex = data.itemIndex or 0
	self.num = data.num or 0
	self.isBinding = data.isBinding or 0
	self.state = data.state or 0
	self.cfg = nil
	if self.goodsType == 1 then
		self.equipId = toLong(data.itemId or data.equipId)
		local info = PkgModel:GetInstance():GetEquipInfoByInfoId(self.equipId)
		if info then
			self.bid = info.bid or data.bid or 0
		else
			self.bid = data.bid or 0
		end
	else
		self.bid = toLong(data.itemId or data.bid)
	end
end
-- t类型(对应GoodsVo)， 表id数据
function GoodsVo:SetCfg(t, id, num, bind)
	self.cfg = GoodsVo.GetCfg(t, id)
	if self.cfg == nil then 
		print(StringFormat("无此物品类型t:{0},表id:{1}", t, id))
		return
	end
	self.isBinding = bind == true and 1 or 0
	self.num = num or 0
	self.bid = self.cfg.id
	self.goodsType = self.cfg.goodsType
end
function GoodsVo:SetCfgData(cfg, num, bind)
	self.cfg = cfg
	if self.cfg == nil then 
		print(StringFormat("无此物品类型t:{0},表id:{1}", t, id))
		return
	end
	self.isBinding = bind == true and 1 or 0
	self.num = num or 0
	self.bid = self.cfg.id
	self.goodsType = self.cfg.goodsType
end
-- 获取cfg
function GoodsVo:GetCfgData()
	self.cfg = self.cfg or GoodsVo.GetCfg(self.goodsType, self.bid)
	return self.cfg
end