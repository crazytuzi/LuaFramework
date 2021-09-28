local WingAndRidingAdvanceLeftNode = class("WingAndRidingAdvanceLeftNode", function() return cc.Node:create() end )

function WingAndRidingAdvanceLeftNode:ctor(parent, type)
	local pathCommon = "res/wingAndRiding/common/"
	local pathWing = "res/wingAndRiding/wing/"
	local pathRiding = "res/wingAndRiding/riding/"
	local path

	self.load_data = {}
	self.type = type


	local tab,skillTab = nil,{}
 	local id, nextId
	if self.type == wingAndRidingType.WR_TYPE_WING then
		tab = "WingCfg"
		id = G_WING_INFO.id

		if G_WING_INFO.skillTab == nil then
			G_WING_INFO.skillTab = {}
		end
		skillTab = G_WING_INFO.skillTab
	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
		tab = "RidingCfg"
		id = G_RIDING_INFO.id

		if G_RIDING_INFO.skillTab == nil then
			G_RIDING_INFO.skillTab = {}
		end
		skillTab = G_RIDING_INFO.skillTab
	end 
	self.skillTab = skillTab
	nextId = self:getNextId(id)

	local record = getConfigItemByKey(tab, "q_ID", id)
	self.record = record

	local nextRecord = getConfigItemByKey(tab, "q_ID", nextId)
	self.nextRecord = nextRecord

	local bg = createSprite(self, "res/common/bg/infoBg11.png", cc.p(0, 0), cc.p(1, 0.5))
	
	local scrollView = cc.ScrollView:create()
    if nil ~= scrollView then
        scrollView:setViewSize(cc.size(270, 475))
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
end

function WingAndRidingAdvanceLeftNode:getNextId(id)
	log("WingAndRidingAdvanceLeftNode:getNextId id = "..id)
	if self.type == wingAndRidingType.WR_TYPE_WING then
		return getConfigItemByKey("WingCfg", "q_ID", id, "q_nextID")
	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
		return getConfigItemByKey("RidingCfg", "q_ID", id, "q_nextID")
	end 
end

function WingAndRidingAdvanceLeftNode:getFight(record)
	if record then
		--dump(record)
		local paramTab = {}

		local MRoleStruct = require("src/layers/role/RoleStruct")
		paramTab.school = MRoleStruct:getAttr(ROLE_SCHOOL)
		if paramTab.school == 1 then
			paramTab.attack = {["["] = record.q_attack_min, ["]"] = record.q_attack_max}
		elseif paramTab.school == 2 then
			paramTab.attack = {["["] = record.q_magic_attack_min, ["]"] = record.q_magic_attack_max}
		elseif paramTab.school == 3 then
			paramTab.attack = {["["] = record.q_sc_attack_min, ["]"] = record.q_sc_attack_max}
		end
		 
		paramTab.lucks = record.q_luck
		paramTab.pDefense = {["["] = record.q_defence_min, ["]"] = record.q_defence_max}
		paramTab.mDefense = {["["] = record.q_magic_defence_min, ["]"] = record.q_magic_defence_max}
		paramTab.hp = record.q_max_hp
		paramTab.hit = record.q_hit
		paramTab.dodge = record.q_dodge
		paramTab.skill = {}

		-- for i,v in pairs(self.skillTab) do
		-- 	if v ~= nil and v ~= 0 then
		-- 		paramTab.skill[i] = {lv = 1, id = v}
		-- 	end
		-- end 
		--dump(paramTab)
		local Mnumerical = require "src/functional/numerical"
		return Mnumerical:calcCombatPowerRange(paramTab)
	else
		return 0
	end
end

function WingAndRidingAdvanceLeftNode:createAttNode(record)
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
		local str = formatStr2(game.getStrByKey("prop_speed"), record.q_addSpeed)
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

	-- local pos = {cc.p(10, 100), 
	-- 			 cc.p(10, 70),
	-- 			 cc.p(10, 40),
	-- 			 cc.p(10, 10),
	-- 			}
	-- local node = cc.Node:create()
	-- node:setContentSize(cc.size(260, 130))
	-- node:setAnchorPoint(cc.p(0, 0))
	-- for i,v in ipairs(attStrs) do
	-- 	local richText = require("src/RichText").new(node, pos[i], cc.size(150, 30), cc.p(0, 0), 30, 20, MColor.white)
	--     richText:addText(v, MColor.white, false)
	--     richText:format()
	-- end

	local richText = require("src/RichText").new(node, cc.p(0, 0), cc.size(240, 30), cc.p(0, 0), 30, 20, MColor.white)
	for i,v in ipairs(attStrs) do
	    richText:addText(v.."\n", MColor.white, false)
	end
	richText:format()
	dump(richText:getContentSize())

	return richText
end

function WingAndRidingAdvanceLeftNode:isActive()
	if self.type == wingAndRidingType.WR_TYPE_WING then
		return (getConfigItemByKey("WingCfg", "q_ID", self.nextId, "q_activeSkillPos") == 1)
	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
		return (getConfigItemByKey("RidingCfg", "q_ID", self.nextId, "q_activeSkillPos") == 1)
	end 
end

function WingAndRidingAdvanceLeftNode:updateScrollView()
	self.node:removeAllChildren()

	local topPadding = cc.Node:create()
    topPadding:setContentSize(cc.size(10, 10))

    local nowFightBg = createSprite(nil, "res/common/misc/powerbg_1.png", cc.p(0, 0), cc.p(0, 0))
	local nowFightRichText = require("src/RichText").new(nowFightBg, getCenterPos(nowFightBg, 0, 5), cc.size(250, 30), cc.p(0.5, 0.5), 30, 24, MColor.white)
    nowFightRichText:addText("^c(lable_yellow)"..game.getStrByKey("combat_power").."：".."^"..self:getFight(self.record), nil, false)
    nowFightRichText:setAutoWidth()
    nowFightRichText:format()

    --local lineTop = createSprite(nil, "res/common/bg/infoBg11-1.png", cc.p(0, 0), cc.p(0, 0))

    local titileRoleBg = createSprite(nil, "res/common/bg/infoBg11-2.png", cc.p(0, 0), cc.p(0, 0))
    createLabel(titileRoleBg, game.getStrByKey("wr_title_role"), getCenterPos(titileRoleBg), cc.p(0.5, 0.5), 22, false, nil, nil, MColor.lable_yellow)

    local nowAttNode = self:createAttNode(self.record)

    --local lineCenter = createSprite(nil, "res/common/bg/infoBg11-1.png", cc.p(0, 0), cc.p(0, 0))

    local nextBg = createSprite(nil, "res/common/bg/infoBg11-2.png", cc.p(0, 0), cc.p(0, 0))
    createLabel(nextBg, game.getStrByKey("wr_title_role_next"), getCenterPos(nextBg), cc.p(0.5, 0.5), 22, false, nil, nil, MColor.lable_yellow)

    local nextFightBg = createSprite(nil, "res/common/misc/powerbg_1.png", cc.p(0, 0), cc.p(0, 0))
    local nextFightRichText = require("src/RichText").new(nextFightBg, getCenterPos(nextFightBg, 0, 5), cc.size(250, 30), cc.p(0.5, 0.5), 30, 24, MColor.white)
    nextFightRichText:addText("^c(lable_yellow)"..game.getStrByKey("combat_power").."：".."^"..self:getFight(self.nextRecord), nil, false)
    nextFightRichText:setAutoWidth()
    nextFightRichText:format()

    local titileRoleNextBg = createSprite(nil, "res/common/bg/infoBg11-2.png", cc.p(0, 0), cc.p(0, 0))
    createLabel(titileRoleNextBg, game.getStrByKey("wr_title_role"), getCenterPos(titileRoleNextBg), cc.p(0.5, 0.5), 22, false, nil, nil, MColor.lable_yellow)

    local nextAttNode = self:createAttNode(self.nextRecord)

    --local lineBottom = createSprite(nil, "res/common/bg/infoBg11-1.png", cc.p(0, 0), cc.p(0, 0))

    local tipLabel = createLabel(nil, "", cc.p(0, 0), cc.p(0, 0), 20, false, nil, nil, MColor.green)
    if self:isActive() then
    	tipLabel:setString(game.getStrByKey("wr_tip_active_skill"))
    end

    local Mnode = require("src/young/node")
    local node = Mnode.combineNode(
	{
		nodes = 
		{
			tipLabel,
			--lineBottom,
			nextAttNode,
			titileRoleNextBg,
			nextFightBg,
			nextBg,
			--lineCenter,
			nowAttNode,
			titileRoleBg,
			--lineTop,
			nowFightBg,
			topPadding,
		},
		ori = "|",
		margins = 5,
	})
	self.node:addChild(node)
	--dump(node:getContentSize())
	self.scrollView:setContentSize(cc.size(270, node:getContentSize().height))
	self.scrollView:setContentOffset(cc.p(0, -(node:getContentSize().height-475)), false)
end

return WingAndRidingAdvanceLeftNode