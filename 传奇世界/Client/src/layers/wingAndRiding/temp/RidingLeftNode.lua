local RidingLeftNode = class("RidingLeftNode", function() return cc.Node:create() end)

local UpdateNode = class("UpdateNode", function() return cc.Node:create() end)

local MPackStruct = require "src/layers/bag/PackStruct"
local MpropOp = require "src/config/propOp"
local Mnode = require "src/young/node"

function RidingLeftNode:ctor(parent, otherRoleData)
	dump(G_RIDING_INFO)
	dump(otherRoleData)
	
	self:initdata()

	local isOtherRole = false
	if otherRoleData then
		self.data = otherRoleData.ridingInfo
		self.isOtherRole = true
	end

	local bg = createSprite(self, "res/common/bg/infoBg11.png", cc.p(0, 0), cc.p(1, 0.5))
	
	local scrollView = cc.ScrollView:create()
    if nil ~= scrollView then
        scrollView:setViewSize(cc.size(280, 478))
        scrollView:setPosition(cc.p(0, 10))
        scrollView:ignoreAnchorPointForPosition(true)
        local node = cc.Node:create()
        self.node = node
        scrollView:setContainer(node)
        --scrollView:setContentSize(cc.size(320,500))

        scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        scrollView:setClippingToBounds(true)
        scrollView:setBounceable(true)
        bg:addChild(scrollView)
        self.scrollView = scrollView

        local node = cc.Node:create()
        self.node = node
        scrollView:setContainer(node)
    end

    self:updateScrollView()

    self:registerScriptHandler(function(event)
		if event == "enter" then
			G_RIDE_LEFT_NODE = self
		elseif event == "exit" then
			G_RIDE_LEFT_NODE = nil
		end
	end)
end

function RidingLeftNode:initdata(index)
	local function getFirstIndex()
		for i=1,10 do
			local rideBag = MPackManager:getPack(MPackStruct.eRide)
	    	local grid = rideBag:getGirdByGirdId(i)
	    	if grid and grid.mPropProtoId then
				return i
			end
		end
	end

	index = index or G_RIDING_INFO.index
	--第一次显示第一个
	if index == nil or index <= 0 then
		index = getFirstIndex()
	end
	local rideBag = MPackManager:getPack(MPackStruct.eRide)
    local grid = rideBag:getGirdByGirdId(index)
  
	self.data = grid
	self.index = index
	dump(self.data)
	dump(self.index)
end

function RidingLeftNode:refresh(index)
	self:initdata(index)
	self:updateScrollView()
end

function RidingLeftNode:getFight()
	-- local record = self.record
	-- if record then
	-- 	--dump(record)
	-- 	local paramTab = {}

	-- 	local MRoleStruct = require("src/layers/role/RoleStruct")
	-- 	paramTab.school = MRoleStruct:getAttr(ROLE_SCHOOL)
	-- 	if paramTab.school == 1 then
	-- 		paramTab.attack = {["["] = record.q_attack_min, ["]"] = record.q_attack_max}
	-- 	elseif paramTab.school == 2 then
	-- 		paramTab.attack = {["["] = record.q_magic_attack_min, ["]"] = record.q_magic_attack_max}
	-- 	elseif paramTab.school == 3 then
	-- 		paramTab.attack = {["["] = record.q_sc_attack_min, ["]"] = record.q_sc_attack_max}
	-- 	end
		 
	-- 	paramTab.lucks = record.q_luck
	-- 	paramTab.pDefense = {["["] = record.q_defence_min, ["]"] = record.q_defence_max}
	-- 	paramTab.mDefense = {["["] = record.q_magic_defence_min, ["]"] = record.q_magic_defence_max}
	-- 	paramTab.hp = record.q_max_hp
	-- 	paramTab.hit = record.q_hit
	-- 	paramTab.dodge = record.q_dodge
	-- 	paramTab.skill = {}

	-- 	-- for i,v in pairs(self.skillTab) do
	-- 	-- 	if v ~= nil and v ~= 0 then
	-- 	-- 		paramTab.skill[i] = {lv = 1, id = v}
	-- 	-- 	end
	-- 	-- end 
	-- 	--dump(paramTab)
	-- 	local Mnumerical = require "src/functional/numerical"
	-- 	return Mnumerical:calcCombatPowerRange(paramTab)
	-- else
	-- 	return 0
	-- end

	return 0
end

function RidingLeftNode:createAttNode(record)
	if record == nil then
		return nil
	end

	local attStrs = {}

	local formatStr2 = function(str1, str2)
		return "^c(lable_yellow)"..str1.."^".." ".."^c(white)"..str2.."^"
	end

	local formatStr3 = function(str1, str2, str3)
		return "^c(lable_yellow)"..str1.."^".." ".."^c(white)"..str2.."-"..str3.."^"
	end

	if record.q_max_hp then
		local str = formatStr2(game.getStrByKey("prop_hp"), record.q_max_hp)
		table.insert(attStrs, str)
	end

	if record.q_max_mp then
		local str = formatStr2(game.getStrByKey("prop_mp"), record.q_max_mp)
		table.insert(attStrs, str)
	end

	if record.q_attack_min and record.q_attack_max then
		local str = formatStr3(game.getStrByKey("prop_attack"), record.q_attack_min, record.q_attack_max)
		table.insert(attStrs, str)
	end

	if record.q_magic_attack_min and record.q_magic_attack_max then
		local str = formatStr3(game.getStrByKey("prop_magicAttack"), record.q_magic_attack_min, record.q_magic_attack_max)
		table.insert(attStrs, str)
	end

	if record.q_sc_attack_min and record.q_sc_attack_max then
		local str = formatStr3(game.getStrByKey("prop_scAttack"), record.q_sc_attack_min, record.q_sc_attack_max)
		table.insert(attStrs, str)
	end

	if record.q_defence_min and record.q_defence_max then
		local str = formatStr3(game.getStrByKey("prop_defence"), record.q_defence_min, record.q_defence_max)
		table.insert(attStrs, str)
	end

	if record.q_magic_defence_min and record.q_magic_defence_max then
		local str = formatStr3(game.getStrByKey("prop_magicDefence"), record.q_magic_defence_min, record.q_magic_defence_max)
		table.insert(attStrs, str)
	end

	if record.q_att_dodge then
		local str = formatStr2(game.getStrByKey("prop_attackDodge"), record.q_att_dodge)
		table.insert(attStrs, str)
	end

	if record.q_mac_dodge then
		local str = formatStr2(game.getStrByKey("prop_magicDodge"), record.q_mac_dodge)
		table.insert(attStrs, str)
	end

	if record.q_crit then
		local str = formatStr2(game.getStrByKey("prop_cirt"), record.q_crit)
		table.insert(attStrs, str)
	end

	if record.q_hit then
		local str = formatStr2(game.getStrByKey("prop_hit"), record.q_hit)
		table.insert(attStrs, str)
	end

	if record.q_dodge then
		local str = formatStr2(game.getStrByKey("prop_dodge"), record.q_dodge)
		table.insert(attStrs, str)
	end

	if record.q_attack_speed then
		local str = formatStr2(game.getStrByKey("prop_attackSpeed"), record.q_attack_speed)
		table.insert(attStrs, str)
	end

	if record.q_luck then
		local str = formatStr2(game.getStrByKey("prop_luck"), record.q_luck)
		table.insert(attStrs, str)
	end

	if record.q_addSpeed then
		local str = formatStr2(game.getStrByKey("prop_speed"), record.q_addSpeed.."%")
		table.insert(attStrs, str)
	end

	if record.q_subAt then
		local str = formatStr2(game.getStrByKey("prop_subAt"), record.q_subAt)
		table.insert(attStrs, str)
	end

	if record.q_subMt then
		local str = formatStr2(game.getStrByKey("prop_subMt"), record.q_subMt)
		table.insert(attStrs, str)
	end

	if record.q_subDt then
		local str = formatStr2(game.getStrByKey("prop_subDt"), record.q_subDt)
		table.insert(attStrs, str)
	end

	if record.q_addAt then
		local str = formatStr2(game.getStrByKey("prop_addAt"), record.q_addAt)
		table.insert(attStrs, str)
	end

	if record.q_addMt then
		local str = formatStr2(game.getStrByKey("prop_addMt"), record.q_addMt)
		table.insert(attStrs, str)
	end

	if record.q_addDt then
		local str = formatStr2(game.getStrByKey("prop_addDt"), record.q_addDt)
		table.insert(attStrs, str)
	end

	local reverseTab = function(tab)
		local retTab = {}

		for i=#tab,1,-1 do
			retTab[#tab-i+1] = tab[i]
		end

		return retTab
	end

	--attStrs = reverseTab(attStrs)

	local pos = {cc.p(10, 130),
				 cc.p(10, 100), 
				 cc.p(10, 70),
				 cc.p(10, 40),
				 cc.p(10, 10),
				}
	local node = cc.Node:create()
	node:setContentSize(cc.size(260, #attStrs*30+10))
	node:setAnchorPoint(cc.p(0, 0))
	for i,v in ipairs(attStrs) do
		local richText = require("src/RichText").new(node, cc.p(10, (#attStrs*30+10)-i*30), cc.size(240, 30), cc.p(0, 0), 30, 20, MColor.white)
	    richText:addText(v, MColor.white, false)
	    richText:format()
	end

	return node
end

function RidingLeftNode:createRandomAttNode(randomAttr)
	-- "randomAttr" = {
	--      6 = {
	--          1 = {
	--              "id"    = 6
	--              "order" = 1
	--              "value" = 0
	--          }
	--      }
	--  }
	local nodes = {}

	--dump(randomAttr)

	if randomAttr then
		for k,v in pairs(randomAttr) do
			for k1,v1 in pairs(v) do
				--dump(v1)
				if v1.value > 0 then
					bHasRandom = true
					break
				end
			end
		end
	end

	if randomAttr and bHasRandom then
		-- 构建随机属性节点
		local buildRandomAttrNode = function(nLevel, key, value1, value2)
			--dump({value1=value1, value2=value2})
			local isRange = value2 ~= nil
			if value1 and ((isRange and value2 > 0) or (not isRange and value1 > 0)) then

				local text = "^c(lable_yellow)"..key.."^"..value1
				if value2 then
					text = text.."-"..value2
				end

				local richText = require("src/RichText").new(node, cc.p(0, 0), cc.size(240, 30), cc.p(0, 0), 30, 20, MColor.white)
			    richText:addText(text)
			    richText:format()

			    return richText
			end
		end
	
		local addRandomAttrNode = function(title, attr_name, isRange)
			if isRange then
				local sum_l, sum_r, list, ids = MPackStruct.randomAttr(randomAttr, attr_name)
				-- print("ids")
				-- dump(ids)
				-- print("list")
				-- dump(list)
				for i = 1, #list do
					local nLevel = MPackStruct.getRandomAttrLevel(protoId, ids[i]["["], list[i]["["], list[i]["]"])
					local n_tmp = buildRandomAttrNode(nLevel,title, list[i]["["], list[i]["]"])
					if n_tmp ~= nil then table.insert(nodes, 1, n_tmp) end
				end
			else
				local sum, list, ids = MPackStruct.randomAttr(randomAttr, attr_name)
				-- print("ids")
				-- dump(ids)
				-- print("list")
				-- dump(list)
				for i = 1, #list do
					local nLevel = MPackStruct.getRandomAttrLevel(protoId, ids[i]["["], list[i])
					local n_tmp = buildRandomAttrNode(nLevel, title, list[i])
					if n_tmp ~= nil then table.insert(nodes, 1, n_tmp) end
				end
			end
		end
		
		addRandomAttrNode(game.getStrByKey("physical_attack_s")..": ", MPackStruct.eAttrPAttack, true)
		addRandomAttrNode(game.getStrByKey("magic_attack_s")..": ", MPackStruct.eAttrMAttack, true)
		addRandomAttrNode(game.getStrByKey("taoism_attack_s")..": ", MPackStruct.eAttrTAttack, true)
		addRandomAttrNode(game.getStrByKey("physical_defense_s")..": ", MPackStruct.eAttrPDefense, true)
		addRandomAttrNode(game.getStrByKey("magic_defense_s")..": ", MPackStruct.eAttrMDefense, true)
		addRandomAttrNode(game.getStrByKey("hp")..": ", MPackStruct.eAttrHP, false)
		addRandomAttrNode(game.getStrByKey("mp")..": ", MPackStruct.eAttrMP, false)
		addRandomAttrNode(game.getStrByKey("luck")..": ", MPackStruct.eAttrLuck, false)
		addRandomAttrNode(game.getStrByKey("my_hit")..": ", MPackStruct.eAttrHit, false)
		addRandomAttrNode(game.getStrByKey("dodge")..": ", MPackStruct.eAttrDodge, false)
		addRandomAttrNode(game.getStrByKey("strike")..": ", MPackStruct.eAttrStrike, false)
		addRandomAttrNode(game.getStrByKey("my_tenacity")..": ", MPackStruct.eAttrTenacity, false)
		addRandomAttrNode(game.getStrByKey("hu_shen_rift")..": ", MPackStruct.eAttrHuShenRift, false)
		addRandomAttrNode(game.getStrByKey("hu_shen")..": ", MPackStruct.eAttrHuShen, false)
		addRandomAttrNode(game.getStrByKey("freeze")..": ", MPackStruct.eAttrFreeze, false)
		addRandomAttrNode(game.getStrByKey("freeze_oppose")..": ", MPackStruct.eAttrFreezeOppose, false)
	end
	dump(#nodes)
	-- return nodes

	local node = cc.Node:create()
	node:setContentSize(cc.size(260, #nodes*30+10))
	node:setAnchorPoint(cc.p(0, 0))
	for i,v in ipairs(nodes) do
		node:addChild(v)
	    v:setPosition(cc.p(10, (#nodes*30+10)-i*30))
	end

	return node
end

function RidingLeftNode:updateScrollView()
	self.node:removeAllChildren()

	local power_bg = cc.Sprite:create("res/common/misc/powerbg_1.png")
	local power_bg_size = power_bg:getContentSize()
	local Mnumber = require "src/component/number/view"
	local NumberBuilder = Mnumber.new("res/component/number/10.png")
	local power = Mnode.createKVP(
	{
		k = cc.Sprite:create("res/common/misc/power_b.png"),
		v = NumberBuilder:create(self:getFight(), -5),
		margin = 15,
	})

	power:setScale(0.6)

	Mnode.addChild(
	{
		parent = power_bg,
		child = power,
		anchor = cc.p(0, 0.5),
		pos = cc.p(25, power_bg_size.height/2),
	})


    local infoBg = createSprite(nil, "res/common/bg/infoBg11-2.png", cc.p(0, 0), cc.p(0, 0))
    createLabel(infoBg, game.getStrByKey("wr_title_base"), getCenterPos(infoBg), cc.p(0.5, 0.5), 22, false, nil, nil, MColor.lable_yellow)

    --基本信息
    local baseInfo = require("src/RichText").new(nil, cc.p(0, 0), cc.size(240, 30), cc.p(0, 0), 30, 20, MColor.lable_yellow)
    baseInfo:addText(game.getStrByKey("wr_name").."：".."^c(white)"..MpropOp.name(self.data.mPropProtoId).."^".."\n")
    baseInfo:addText(game.getStrByKey("wr_level").."：".."^c(white)"..self.data.mLevel.."^".."\n")
    local expMax = getConfigItemByKey("MountExp", "q_level", self.data.mLevel, "exp")
    baseInfo:addText(game.getStrByKey("wr_exp").."：".."^c(white)"..self.data.mExp.."/"..expMax.."^")
    baseInfo:format()

    local progressNode = cc.Node:create()
    local progressBg = createSprite(progressNode, "res/component/progress/2_bg.png", cc.p(0, 22), cc.p(0, 0.5))
	local progress = cc.ProgressTimer:create(cc.Sprite:create("res/component/progress/2_green.png"))  
	progressBg:addChild(progress)
    progress:setPosition(getCenterPos(progressBg))
    progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    progress:setAnchorPoint(cc.p(0.5, 0.5))
    progress:setBarChangeRate(cc.p(1, 0))
    progress:setMidpoint(cc.p(0, 1))
    progress:setPercentage(self.data.mExp * 100 / expMax)
	--createLabel(progressBg, self.data.mExp.."/"..expMax, getCenterPos(progressBg), cc.p(0.5, 0.5), 16, true, nil, nil, MColor.white)

	local function plus()
		log("plus 1111111111111")
		local node = require("src/layers/wingAndRiding/RidingAdvanceNode").new(self, self.index)
		getRunScene():addChild(node, 200)
	end
	createTouchItem(progressNode, "res/component/button/plus.png", cc.p(progressBg:getContentSize().width+30, 22), plus)
	progressNode:setContentSize(cc.size(250, 45))

	--基础属性
    local baseAttBg = createSprite(nil, "res/common/bg/infoBg11-2.png", cc.p(0, 0), cc.p(0, 0))
    createLabel(baseAttBg, game.getStrByKey("wr_title_base_att"), getCenterPos(baseAttBg), cc.p(0.5, 0.5), 22, false, nil, nil, MColor.lable_yellow)

    local baseAttNode = self:createAttNode(getConfigItemByKey("MountDB", "mountId", self.data.mPropProtoId))

    --成长属性
    local growAttBg = createSprite(nil, "res/common/bg/infoBg11-2.png", cc.p(0, 0), cc.p(0, 0))
    createLabel(growAttBg, game.getStrByKey("wr_title_grow_att"), getCenterPos(growAttBg), cc.p(0.5, 0.5), 22, false, nil, nil, MColor.lable_yellow)

    getConfigItemByKey("MountGrowProp", "q_id", self.data.mPropProtoId)
    local growAttNode = self:createAttNode(getConfigItemByKey("MountGrowProp", "q_id", self.data.mPropProtoId))

    --极品属性
    local bestAttBg = createSprite(nil, "res/common/bg/infoBg11-2.png", cc.p(0, 0), cc.p(0, 0))
    createLabel(bestAttBg, game.getStrByKey("wr_title_best_att"), getCenterPos(bestAttBg), cc.p(0.5, 0.5), 22, false, nil, nil, MColor.lable_yellow)

    local bestAttNodes = self:createRandomAttNode(self.data.mEachOfSpecialAttr[1])

    local nodes = 
		{
			bestAttNodes,
			bestAttBg,
			-- growAttNode,
			growAttBg,
			baseAttNode,
			baseAttBg,
			progressNode,
			baseInfo,
			infoBg,
			power_bg,
		}
	-- for i,v in ipairs(bestAttNodes) do
	-- 	table.insert(nodes, 1, v)
	-- end
	dump(#nodes)

    local node = Mnode.combineNode(
	{
		nodes = nodes,
		ori = "|",
		--align = "l",
		margins = 5,
	})
	self.node:addChild(node)
	--dump(node:getContentSize())
	self.scrollView:setContentSize(cc.size(280, node:getContentSize().height))
	self.scrollView:setContentOffset(cc.p(0, -(node:getContentSize().height-478)), false)
end

------------------------------------------------------------------------------------------------------------------

function UpdateNode:ctor(mainLayer)
	self.mainLayer = mainLayer

	local bg = createScale9Sprite(self, "res/common/scalable/12.png", cc.p(0, 0), cc.size(480, 230), cc.p(0.5, 0.5))


	registerOutsideCloseFunc(bg, function() removeFromParent(self) end, true)
end

return RidingLeftNode