--Author:		bishaoqing
--DateTime:		2016-05-11 17:33:19
--Region:		装备对比
--Author:		bishaoqing
--DateTime:		2016-05-11 15:19:53
--Region:		EquipCompare拆解（物品对比栏）
local Mmisc = require "src/young/util/misc"
local MpropOp = require "src/config/propOp"
local Mprop = require "src/layers/bag/prop"
local MequipOp = require "src/config/equipOp"
local Mconvertor = require "src/config/convertor"
local MMenuButton = require "src/component/button/MenuButton"

local EquipCompare = class("EquipCompare")

function EquipCompare:ctor(params)
	--------------------------------------------------------
	if type(params) ~= "table" then 
		return 
	end
	self:ParseParams(params)
	self:InitUI(params)
end

--读取一些逻辑参数
function EquipCompare:ParseParams( params )
	-- body
	self.size = 20
	self.color = MColor.lable_yellow
	self.strfile = "res/common/bg/tips1.png"
	self.addY = 234

	self.bgType = params.bgType

	if self.bgType ~= 1 then
	    self.strfile = "res/common/bg/tips2.png"
	    self.addY = 0
	end

	self.params = params

	--对比物品
	self.compareGrid = params.compareGrid
	self.compareGridId = MPackStruct.girdIdFromGird(self.compareGrid)
	self.compareProtoId = MPackStruct.protoIdFromGird(self.compareGrid)
	self.compareStrengthLv = MPackStruct.attrFromGird(self.compareGrid, MPackStruct.eAttrStrengthLevel)
	-- 包裹id
	self.packId = params.packId
	
	--身上装备的
	self.grid = Mmisc:getValue(params, "grid", MPackStruct:buildGirdFromProtoId(params.protoId))
	
	self.gridId = MPackStruct.girdIdFromGird(self.grid)
	
	-- 原型ID
	self.protoId = MPackStruct.protoIdFromGird(self.grid)
	
	-- 是否是勋章
	self.isMedal = self.protoId >= 30004 and self.protoId <= 30006
	-- 类型
	self.cate = MPackStruct.categoryFromGird(self.grid)

	-- 是否是装备类型
	self.isEquip = not self.isMedal and self.cate == MPackStruct.eEquipment
	
	self.isWeapon = self.isEquip and MequipOp.kind(self.protoId) == MPackStruct.eWeapon
	
	-- 是否是套装
	self.isSuit = MequipOp.isSuit(self.protoId)
	
	-- 是否绑定
	self.isBind = nil
	if params.isBind ~= nil then
		self.isBind = params.isBind
	else
		self.isBind = MPackStruct.attrFromGird(self.grid, MPackStruct.eAttrBind)
	end
	
	-- 使用职业
	self.school = MpropOp.schoolLimits(self.protoId)
	
	-- 使用性别
	self.sex = MpropOp.sexLimits(self.protoId)
	
	-- 物品等级
	self.level = MpropOp.levelLimits(self.protoId)
	
	-- 过期时间
	self.expiration = MPackStruct.attrFromGird(self.grid, MPackStruct.eAttrExpiration)
	
	-- 装备强化等级
	self.strengthLv = MPackStruct.attrFromGird(self.grid, MPackStruct.eAttrStrengthLevel)
	
	-- 装备战斗力
	self.power = MPackStruct.attrFromGird(self.grid, MPackStruct.eAttrCombatPower)
	
	-- 物品品质
	self.quality = MpropOp.quality(self.protoId, self.grid)
end

--创建UI
function EquipCompare:InitUI( params )
	-- body
	-- self:InitCommonUI(params)
	-- self:InitScrollUI(params)
end

-- --创建一些基本控件
-- function EquipCompare:InitCommonUI( params )
-- 	-- body
-- 	-- 物品名字
-- 	Mnode.createLabel(
-- 	{
-- 		parent = self,
-- 		src = MpropOp.name(self.protoId),
-- 		color = self.color,
-- 		anchor = cc.p(0, 0.5),
-- 		pos = cc.p(26, 262 + self.addY),
-- 		size = self.size,
-- 	})
	
-- 	-- 是否绑定
-- 	Mnode.createLabel(
-- 	{
-- 		parent = self,
-- 		src = self.isBind and (game.getStrByKey("already")..game.getStrByKey("theBind")) or (game.getStrByKey("not")..game.getStrByKey("theBind")),
-- 		color = self.isBind and MColor.red or MColor.green,
-- 		anchor = cc.p(0, 0.5),
-- 		pos = cc.p(215, 262 + self.addY),
-- 		size = self.size,
-- 	})
	
-- 	-- 物品等级
-- 	local n_level = Mnode.createKVP(
-- 	{
-- 		k = Mnode.createLabel(
-- 		{
-- 			src = "LV.",
-- 			size = self.size,
-- 			color = self.color,
-- 		}),
		
-- 		v = {
-- 			src = tostring(self.level),
-- 			size = self.size,
-- 			color = MRoleStruct:getAttr(ROLE_LEVEL) >= self.level and MColor.green or MColor.red,
-- 		},
-- 	})
	
-- 	Mnode.addChild(
-- 	{
-- 		parent = self,
-- 		child = n_level,
-- 		anchor = cc.p(0, 0.5),
-- 		pos = cc.p(290, 262 + self.addY),
-- 	})
	
-- 	-- 物品图标
-- 	local icon = Mprop.new(
-- 	{
-- 		grid = self.grid,
-- 		strengthLv = self.strengthLv,
-- 	})

-- 	Mnode.addChild(
-- 	{
-- 		parent = self,
-- 		child = icon,
-- 		pos = cc.p(68, 194 + self.addY),
-- 	})

--     local icon_size = icon:getContentSize()
--     Mnode.createSprite(
--     {
--         src = "res/layers/bag/using.png",
--         parent = icon,
--         anchor = cc.p(0,1),
--         pos = cc.p(0,icon_size.height),
--         zOrder = 100,
--     } )
	
-- 	-- 使用职业
-- 	local n_school = Mnode.createKVP(
-- 	{
-- 		k = Mnode.createLabel(
-- 		{
-- 			src = game.getStrByKey("school").."：",
-- 			size = self.size,
-- 			color = self.color,
-- 		}),
		
-- 		v = {
-- 			src = Mconvertor:school(self.school),
-- 			size = self.size,
-- 			color = (self.school~= Mconvertor.eWhole and self.school ~= MRoleStruct:getAttr(ROLE_SCHOOL)) and  MColor.red or MColor.green,
-- 		},
-- 	})

-- 	-- 使用性别
-- 	local n_sex = Mnode.createKVP(
-- 	{
-- 		k = Mnode.createLabel(
-- 		{
-- 			src = game.getStrByKey("sex").."：",
-- 			size = self.size,
-- 			color = self.color,
-- 		}),
		
-- 		v = {
-- 			src = Mconvertor:sexName(self.sex),
-- 			size = self.size,
-- 			color = (self.sex ~= Mconvertor.eSexWhole and self.sex ~= MRoleStruct:getAttr(PLAYER_SEX)) and  MColor.red or MColor.green,
-- 		},
-- 	})

-- 	local n_school_pos = cc.p(136, 211 + self.addY)
-- 	local n_sex_pos = cc.p(136, 176 + self.addY)
	
-- 	local n_power = nil
-- 	if self.isEquip or self.isMedal then
-- 		n_school_pos = cc.p(116, 221 + self.addY)
-- 		n_sex_pos = cc.p(116, 196 + self.addY)
-- 		-- 装备类型
-- 		Mnode.createLabel(
-- 		{
-- 			parent = self,
-- 			src = game.getStrByKey("cate").."："..Mconvertor:equipName(MequipOp.kind(self.protoId)),
-- 			color = self.color,
-- 			size = self.size,
-- 			anchor = cc.p(0, 0.5),
-- 			pos = cc.p(116, 171 + self.addY),
-- 		})
		
-- 		-- 装备战斗力
-- 		local n_power_bg = Mnode.createSprite(
-- 		{
-- 			parent = self,
-- 			src = "res/common/bg/powerBg.png",
-- 			child = n_power_bg,
-- 			pos = cc.p(290, 190 + self.addY),
-- 		})
		
-- 		local n_power_bg_size = n_power_bg:getContentSize()
		
-- 		n_power = Mnode.createKVP(
-- 		{
-- 			k = Mnode.createLabel(
-- 			{
-- 				src = game.getStrByKey("combat_power"),
-- 				size = 25,
-- 				color = self.color,
-- 			}),
			
-- 			v = {
-- 				src = tostring(self.power), -- 10000000
-- 				color = MColor.white,
-- 				size = 22,
-- 			},
			
-- 			ori = "|",
-- 			margin = 5,
-- 		})
		
-- 		Mnode.addChild(
-- 		{
-- 			parent = n_power_bg,
-- 			child = n_power,
-- 			pos = cc.p(n_power_bg_size.width/2, n_power_bg_size.height/2+10),
-- 		})
-- 	end
	
-- 	Mnode.addChild(
-- 	{
-- 		parent = self,
-- 		child = n_school,
-- 		anchor = cc.p(0, 0.5),
-- 		pos = n_school_pos,
-- 	})
	
-- 	Mnode.addChild(
-- 	{
-- 		parent = self,
-- 		child = n_sex,
-- 		anchor = cc.p(0, 0.5),
-- 		pos = n_sex_pos,
-- 	})
-- end

-- --滚动区域ui
-- function EquipCompare:InitScrollUI( params )
-- 	-- body
-- 	-- 滚动区域
-- 	self.vSize = cc.size(338, 270)
--     if self.bgType ~= 1 then
--         self.vSize = cc.size(338, 128)
--     end
-- 	self.cSize = cc.size(self.vSize.width, self.vSize.height) -- 不能写成 cSize = vSize
	
-- 	self.n_placeholder = Mnode.createColorLayer(
-- 	{
-- 		--src = cc.c4b(244 ,164 ,96, 255*0.5),
-- 		src = cc.c4b(244 ,164 ,96, 255*0),
-- 		cSize = self.cSize,
-- 	})
	
-- 	-- ScrollView
-- 	self.n_scroll = cc.ScrollView:create()
-- 	self.n_scroll:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
-- 	self.n_scroll:setClippingToBounds(true)
-- 	--self.n_scroll:setBounceable(true)
-- 	self.n_scroll:setViewSize(self.vSize)
-- 	self.n_scroll:setContainer(self.n_placeholder)
-- 	self.n_scroll:updateInset()
-- 	--self.n_scroll:setContentOffset(cc.p(0, vSize.height - cSize.height))
--     if self.bgType ~= 1 then
--         Mnode.addChild(
-- 	    {
-- 		    parent = self,
-- 		    child = self.n_scroll,
-- 		    anchor = cc.p(0, 1),       
-- 		    pos = cc.p(20, 140),
-- 	    })
--     else
-- 	    Mnode.addChild(
-- 	    {
-- 		    parent = self,
-- 		    child = self.n_scroll,
-- 		    anchor = cc.p(0, 1),       
-- 		    pos = cc.p(20, 367),
-- 	    })
--     end
	
	
-- 	--------------------------------------------------------
	
	
--     self:buildScrollContent(params)
-- end

-- 滚动区域内容
function EquipCompare:buildScrollContent(params)
	self.allNodes = {}
	
	if self.isEquip then		
		-- 基础属性
		-- 标题
		local n_attr_title = Mnode.createLabel(
		{
			src = game.getStrByKey("attr_change").."：",
			size = self.size,
			color = self.color,
			outline = false,
		})
		
		table.insert(self.allNodes, 1, n_attr_title)
		
		self:addAttrNode(game.getStrByKey("physical_attack_s")..": ", MPackStruct.eAttrPAttack, Mconvertor.ePAttack)
		self:addAttrNode(game.getStrByKey("magic_attack_s")..": ", MPackStruct.eAttrMAttack, Mconvertor.eMAttack)
		self:addAttrNode(game.getStrByKey("taoism_attack_s")..": ", MPackStruct.eAttrTAttack, Mconvertor.eTAttack)
		self:addAttrNode(game.getStrByKey("physical_defense_s")..": ", MPackStruct.eAttrPDefense, Mconvertor.ePDefense)
		self:addAttrNode(game.getStrByKey("magic_defense_s")..": ", MPackStruct.eAttrMDefense, Mconvertor.eMDefense)
		self:addAttrNode(game.getStrByKey("hp")..": ", MPackStruct.eAttrHP, nil, MequipOp.maxHP, MequipOp.upStrengthMaxHP)
		self:addAttrNode(game.getStrByKey("mp")..": ", MPackStruct.eAttrMP, nil, MequipOp.maxMP, MequipOp.upStrengthMaxMP)
		self:addAttrNode(game.getStrByKey("luck")..": ", MPackStruct.eAttrLuck, nil, MequipOp.luck, MequipOp.upStrengthLuck)
		self:addAttrNode(game.getStrByKey("my_hit")..": ", MPackStruct.eAttrHit, nil, MequipOp.hit, MequipOp.upStrengthHit)
		self:addAttrNode(game.getStrByKey("dodge")..": ", MPackStruct.eAttrDodge, nil, MequipOp.dodge, MequipOp.upStrengthDodge)
		self:addAttrNode(game.getStrByKey("strike")..": ", MPackStruct.eAttrStrike, nil, MequipOp.strike, MequipOp.upStrengthStrike)
		self:addAttrNode(game.getStrByKey("my_tenacity")..": ", MPackStruct.eAttrTenacity, nil, MequipOp.tenacity, MequipOp.upStrengthTenacity)
		self:addAttrNode(game.getStrByKey("hu_shen_rift")..": ", MPackStruct.eAttrHuShenRift, nil, MequipOp.huShenRift, MequipOp.upStrengthHuShenRift)
		self:addAttrNode(game.getStrByKey("hu_shen")..": ", MPackStruct.eAttrHuShen, nil, MequipOp.huShen, MequipOp.upStrengthHuShen)
		self:addAttrNode(game.getStrByKey("freeze")..": ", MPackStruct.eAttrFreeze, nil, MequipOp.freeze, MequipOp.upStrengthFreeze)
		self:addAttrNode(game.getStrByKey("freeze_oppose")..": ", MPackStruct.eAttrFreezeOppose, nil, MequipOp.freezeOppose, MequipOp.upStrengthFreezeOppose)
	

		local uiNode = self:createJipinCompare()
		if uiNode then
			uiNode:setContentSize(cc.size(100, 18))
			table.insert(self.allNodes, 1, uiNode)
		end
		-- print("uiNodegetContentSize",uiNode:getContentSize().width,uiNode:getContentSize().height)
	end
	

	local n_content = Mnode.combineNode(
	{
		nodes = self.allNodes,
		ori = "|",
		align = "l",
		margins = 10,
	})

	return n_content
	-- self:refresh_content(self.n_placeholder, n_content)
	-- self.n_scroll:updateInset() -- 调用它，否则滑动无动画
	-- self.n_scroll:setContentOffset(cc.p(0, self.vSize.height - self.cSize.height))
end

function EquipCompare:createJipinCompare( ... )
	-- body
	local nEquipJipin, nEquipCate = self:getJipinAttr(self.grid)
	local nComJipin, nComCate = self:getJipinAttr(self.compareGrid)
	print("nEquipCate,nComCate",nEquipCate,nComCate,nComJipin, nEquipJipin)
	local uiNode = nil
	if nEquipCate == nComCate then

		uiNode = self:createSingleLine(nEquipCate, nComJipin, nEquipJipin)

	else

		local uiCom = self:createSingleLine(nComCate, nComJipin, 0)
		local uiEquip = self:createSingleLine(nEquipCate, 0, nEquipJipin)

		uiNode = cc.Node:create()
		if uiCom then
			uiNode:addChild(uiCom)
		end
		if uiEquip then
			uiNode:addChild(uiEquip)
			print("uiEquip;getContentSize",uiEquip:getContentSize().width,uiEquip:getContentSize().height)
		end
		
	end
	-- if uiNode then
	-- 	GetUIHelper():FixNode(uiNode, 10)
	-- end
	return uiNode
end

function EquipCompare:createSingleLine( nAttrCategory, nComparentNum, nBaseNum )
	-- body
	local sAttr = Mconvertor.attrName(nAttrCategory)..":"
	print("nComparentNum == nBaseNum", nComparentNum, nBaseNum)
	if nComparentNum == nBaseNum then
		return
	end
	local bBigger = false
	if nComparentNum > nBaseNum then
		bBigger = true
	end

	local stColor = bBigger and MColor.green or MColor.red
	local nDelta = math.abs(nComparentNum - nBaseNum)
	local uiNode = cc.Node:create()
	local tfName = createLabel(uiNode, sAttr, cc.p(0, 0), cc.p(0, 0), 18)
	tfName:setColor(MColor.lable_black)
	stNameSize = tfName:getContentSize()

	local sArrowFile = "res/group/arrows/" .. (bBigger and "1.png" or "2.png")
	local uiArrow = createSprite(uiNode, sArrowFile, cc.p(stNameSize.width, 0), cc.p(0,0))
	local stArrowSize = uiArrow:getContentSize()

	local tfNum = createLabel(uiNode, nDelta, cc.p(stNameSize.width + stArrowSize.width, 0), cc.p(0,0), 18)
	tfNum:setColor(stColor)
	local stNumSize = tfNum:getContentSize()

	uiNode:setContentSize(cc.size(stNameSize.width + stArrowSize.width + stNumSize.width, stNameSize.height))

	-- GetUIHelper():FixNode(uiNode, 10, true)
	return uiNode
end

function EquipCompare:isSame( jipinType, normalType )
	-- body
	--[[
	eHP = 1 -- "生命"
	eMP = 2 -- "魔法"
	ePAttack = 3 -- "物理攻击"
	eMAttack = 4 -- "魔法攻击"
	eTAttack = 5 -- "道术攻击"
	ePDefense = 6 -- "物理防御"
	eMDefense = 7 -- "魔法防御"
	eMingZhong = 8 -- "命中"
	eShanBi = 9 -- "闪避"
	eBaoji = 10 -- "暴击"
	eRenXing = 11 -- "韧性"
	eChuanTou = 12 -- "穿透"
	eMianShang = 13 -- "免伤"
	eLuck = 14 -- "幸运"
	eMoveSpeed = 15 -- "移动速度"
	]]
	if jipinType == 1 and normalType == 36 then
		return true
	elseif jipinType == 2 and normalType == 37 then
		return true
	elseif jipinType == 3 and normalType == 31 then
		return true
	elseif jipinType == 4 and normalType == 33 then
		return true
	elseif jipinType == 5 and normalType == 35 then
		return true
	elseif jipinType == 6 and normalType == 32 then
		return true
	elseif jipinType == 7 and normalType == 34 then
		return true
	elseif jipinType == 8 and normalType == 39 then
		return true
	elseif jipinType == 9 and normalType == 40 then
		return true
	elseif jipinType == 10 and normalType == 41 then
		return true
	elseif jipinType == 11 and normalType == 42 then
		return true
	elseif jipinType == 12 and normalType == 43 then
		return true
	elseif jipinType == 13  then
		return true
	elseif jipinType == 14 and normalType == 8 then
		return true
	elseif jipinType == 15  then
		return true
	end
end

function EquipCompare:getJipinAttr( grid, nType )
	-- body
	-- 极品属性
	local protoId = MPackStruct.protoIdFromGird(grid)
	local attrCate = MequipOp.specialAttrCate(protoId)
	-- print("getJipinAttr", nType, attrCate)
	-- if attrCate ~= nType then
	-- 	return
	-- end
	if not self:isSame(attrCate, nType) then
		return
	end
	local isRange = Mconvertor.isRangeAttr(attrCate)
	local specialAttr = MPackStruct.specialAttrFromGird(grid)
	if attrCate ~= nil and specialAttr ~= nil then
		local maxLayer = MequipOp.specialAttrMaxLayer(protoId)
		local eachLayerValue = MequipOp.specialAttrEachLayerValue(protoId)
		local t = {}
		if isRange then
			t.isRange = true
			t.nMin = 0
		
			t.nMax = specialAttr * eachLayerValue
		else
			t.isRange = false
			t.nMin = specialAttr * eachLayerValue
		
			t.nMax = specialAttr * eachLayerValue
		end
		
		
		t.nAttrId = specialAttr
		return t

	end
end

-- 构建对比节点
function EquipCompare:calc_vs(grid, attr_name)
	if self.packId == MPackStruct.eDress then
		return { now_see = MPackStruct.attrFromGird(grid, attr_name) }
	end
	
	local now_see = MPackStruct.attrFromGird(self.compareGrid, attr_name)
	local now_dress = MPackStruct.attrFromGird(grid, attr_name)
	
	local now_see_jipin = self:getJipinAttr(self.compareGrid, attr_name)
	local now_dress_jipin = self:getJipinAttr(grid, attr_name)

	local now_see_min_jipin = 0
	local now_see_max_jipin = 0
	local now_dress_min_jipin = 0
	local now_dress_max_jipin = 0
	if now_see_jipin then
		now_see_min_jipin = now_see_jipin.nMin
		now_see_max_jipin = now_see_jipin.nMax
	end
	if now_dress_jipin then
		now_dress_min_jipin = now_dress_jipin.nMin
		now_dress_max_jipin = now_dress_jipin.nMax
	end


	local ret = {}
	ret.now_see = now_see
	if type(now_see) == "table" then
		ret.vs = { ["["]= now_see["["]-now_dress["["] + now_see_min_jipin - now_dress_min_jipin, ["]"]= now_see["]"]-now_dress["]"] + now_see_max_jipin - now_dress_max_jipin }
	else
		ret.vs = now_see-now_dress + now_see_min_jipin - now_dress_min_jipin
	end
	ret.now_dress = now_dress
	return ret
end


-- 构建基础属性节点
function EquipCompare:buildInfoNode(key, base, added, vs)
	local isRange = type(base) == "table"
	local now_see = vs.now_see
	local vs = vs.vs

	-- 这些情况对比持平
	if vs ~= nil and ((isRange and vs["["] == 0 and vs["]"] == 0) or (not isRange and vs == 0)) then vs = nil end			
	
    local hasBase = (isRange and base["]"] > 0) or (not isRange and base > 0)
    
    if vs ~= nil or hasBase then
		local nodes = {}
		nodes[#nodes+1] = Mnode.createLabel(
		{
			src = key,
			size = 18,
			color = MColor.lable_black,
			outline = false,
		})
		
		if vs ~= nil then
			local isGreen = (isRange and vs["]"] > 0) or (not isRange and vs > 0)
			local uiLine = Mnode.combineNode(
			{
				nodes = {
					Mnode.createSprite(
					{
						src = "res/group/arrows/" .. (isGreen and "1.png" or "2.png"),
					}),
					
					Mnode.createLabel(
					{
						src = isRange and (math.abs(vs["["]) .. "-" .. math.abs(vs["]"])) or math.abs(vs),
						size = 18,
						color = isGreen and MColor.green or MColor.red,
						outline = false,
					}),
				},
				
				margins = 0,
			})
			uiLine.isGreen = isGreen
			nodes[#nodes+1] = uiLine
        else
            nodes[#nodes+1] = Mnode.createLabel(
		    {
			    src = "--",
			    size = 18,
			    color = MColor.white,
			    outline = false,
		    })
		end
		return Mnode.combineNode(
		{
			nodes = nodes,
			margins = {0, 5, 2},
		})
	end

    return nil
end

--不显示对比情况，只显示自己的属性
function EquipCompare:buildMyInfoNode( key, base, added, vs )
	-- body
	local isRange = type(base) == "table"
	local now_see = vs.now_see
	local vs2 = vs.vs2
	local vs = vs.vs
	
	-- 这些情况对比持平
	if vs ~= nil and ((isRange and vs["["] == 0 and vs["]"] == 0) or (not isRange and vs == 0)) then vs = nil end
	if vs2 ~= nil and ((isRange and vs2["["] == 0 and vs2["]"] == 0) or (not isRange and vs2 == 0)) then vs2 = nil end
	local hasBase = (isRange and base["]"] > 0) or (not isRange and base > 0)
	
	if vs ~= nil or vs2 ~= nil or hasBase then
		local nodes = {}
		nodes[#nodes+1] = Mnode.createLabel(
		{
			src = key,
			size = 18,
			color = MColor.lable_black,
			outline = false,
		})
		
		local where = hasBase and now_see or base
		nodes[#nodes+1] = Mnode.createLabel(
		{ 
			src = isRange and (where["["] .. "-" .. where["]"]) or where,
			size = 18,
			color = MColor.white,
			outline = false,
		})
		
		nodes[#nodes+1] = ((isRange and added["]"] > 0) or (not isRange and added > 0)) and Mnode.createLabel(
		{
			--src = game.getStrByKey("strengthen").."+" .. (isRange and (added["["] .. "-" .. added["]"]) or added),
			src = "强".."+" .. (isRange and (added["["] .. "-" .. added["]"]) or added),
			size = 18,
			color = MColor.white,
			outline = false,
		}) or nil
		
		return Mnode.combineNode(
		{
			nodes = nodes,
			margins = {0, 5, 2},
		})
	end
end

-- --显示对比属性还是显示自己的物品属性
-- local bShowDetail = false
--单条属性
function EquipCompare:addAttrNode(title, attr_name1, attr_name2, base_func, grow_func)
	-- if bShowDetail then
		-- if attr_name2 then
		-- 	local n_tmp = self:buildMyInfoNode(title, MequipOp.combatAttr(self.protoId, attr_name2), MequipOp.upStrengthCombatAttr(attr_name2, self.protoId, self.strengthLv), { now_see = MPackStruct.attrFromGird(self.grid, attr_name1) })
		-- 	if n_tmp ~= nil then 
		-- 		table.insert(self.allNodes, 1, n_tmp) 
		-- 	end
		-- else
		-- 	local n_tmp = self:buildMyInfoNode(title, base_func(self.protoId), grow_func(self.protoId, self.strengthLv), { now_see = MPackStruct.attrFromGird(self.grid, attr_name1) })
		-- 	if n_tmp ~= nil then 
		-- 		table.insert(self.allNodes, 1, n_tmp) 
		-- 	end
		-- end
	-- else
		if attr_name2 then
			local n_tmp = self:buildInfoNode(title, MequipOp.combatAttr(self.protoId, attr_name2), MequipOp.upStrengthCombatAttr(attr_name2, self.protoId, self.strengthLv), self:calc_vs(self.grid, attr_name1))
			if n_tmp ~= nil then 
				table.insert(self.allNodes, 1, n_tmp) 
			end
		else
			local n_tmp = self:buildInfoNode(title, base_func(self.protoId), grow_func(self.protoId, self.strengthLv), self:calc_vs(self.grid, attr_name1))
			if n_tmp ~= nil then 
				table.insert(self.allNodes, 1, n_tmp) 
			end
		end
	-- end
end

--刷新滚动区域
function EquipCompare:refresh_content(parent, child) -- n_placeholder-n_content
	local content_tag = 1
	local n_content = parent:getChildByTag(content_tag)
	if n_content then removeFromParent(n_content) end
	
	local child_size = child:getContentSize()
	self.cSize.height = child_size.height
	parent:setContentSize(self.cSize)
	
	local parent_size = parent:getContentSize()
	n_content = Mnode.addChild(
	{
		parent = parent,
		child = child,
		anchor = cc.p(0, 1),
		pos = cc.p(0, parent_size.height), -- 对齐左上角
		tag = content_tag,
	})
end

function EquipCompare:AddDetailToNodes( nodes, where, added, isRange  )
	-- body

	nodes[#nodes+1] = Mnode.createLabel(
	{ 
		src = isRange and (where["["] .. "-" .. where["]"]) or where,
		size = 18,
		color = MColor.white,
		outline = false,
	})
	
	nodes[#nodes+1] = ((isRange and added["]"] > 0) or (not isRange and added > 0)) and Mnode.createLabel(
	{
		--src = game.getStrByKey("strengthen").."+" .. (isRange and (added["["] .. "-" .. added["]"]) or added),
		src = "强".."+" .. (isRange and (added["["] .. "-" .. added["]"]) or added),
		size = 18,
		color = MColor.white,
		outline = false,
	}) or nil
end

return EquipCompare