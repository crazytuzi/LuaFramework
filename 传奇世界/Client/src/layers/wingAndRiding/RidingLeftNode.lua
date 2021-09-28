local RidingLeftNode = class("RidingLeftNode", function() return cc.Node:create() end )

function RidingLeftNode:ctor(parent, otherRoleData)
	dump(G_RIDING_INFO)
	dump(otherRoleData)
	self.data = G_RIDING_INFO.id

	local isOtherRole = false
	if otherRoleData then
		self.data = otherRoleData.ridingInfo
		self.isOtherRole = true
	end

	local record = getConfigItemByKey("RidingCfg", "q_ID", self.data[1])
	self.record = record

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

function RidingLeftNode:refresh(index, data)
	if data then
		self.data = data
	end

	log("index = "..tostring(index))
	local defaultIndex = index or 1
	-- self.data = G_RIDING_INFO.id
	-- if self.isOtherRole then
	-- 	self.data = 
	-- end
	self.record = getConfigItemByKey("RidingCfg", "q_ID", self.data[defaultIndex])
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

	return self.record.battle or 0
end

function RidingLeftNode:createAttNode()
	local record = self.record
	if record == nil then
		return nil
	end

	local attStrs = {}

	local formatStr2 = function(str1, str2)
		return "^c(lable_yellow)"..str1.."^".." ".."^c(white)"..str2.."^"
	end

	local formatStr2Ex = function(str1, str2)
		return "^c(purple)"..str1.."^".." ".."^c(green)"..str2.."^"
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

	if record.q_propper then
		local percent = record.q_propper * 100 / 10000
		local str = formatStr2Ex(game.getStrByKey("prop_hp_add"), percent.."%")
		table.insert(attStrs, str)
		local str = formatStr2Ex(game.getStrByKey("prop_mp_add"), percent.."%")
		table.insert(attStrs, str)
		local str = formatStr2Ex(game.getStrByKey("prop_attack_add"), percent.."%")
		table.insert(attStrs, str)
		local str = formatStr2Ex(game.getStrByKey("prop_magicAttack_add"), percent.."%")
		table.insert(attStrs, str)
		local str = formatStr2Ex(game.getStrByKey("prop_scAttack_add"), percent.."%")
		table.insert(attStrs, str)
		local str = formatStr2Ex(game.getStrByKey("prop_defence_add"), percent.."%")
		table.insert(attStrs, str)
		local str = formatStr2Ex(game.getStrByKey("prop_magicDefence_add"), percent.."%")
		table.insert(attStrs, str)
		local str = "^c(red)"..game.getStrByKey("prop_add_tip").."^"
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

function RidingLeftNode:updateScrollView()
	dump(self.record)

	self.node:removeAllChildren()

	-- local fightBg = createSprite(nil, "res/common/misc/powerbg_1.png", cc.p(0, 0), cc.p(0, 0))
	-- local fightRichText = require("src/RichText").new(fightBg, getCenterPos(fightBg, 0, 5), cc.size(250, 30), cc.p(0.5, 0.5), 30, 24, MColor.white)
 --    fightRichText:addText("^c(lable_yellow)"..game.getStrByKey("combat_power").."：".."^"..self:getFight(), nil, false)
 --    fightRichText:setAutoWidth()
 --    fightRichText:format()
 	local Mnode = require "src/young/node"
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

    --local lineTop = createSprite(nil, "res/common/bg/infoBg11-1.png", cc.p(0, 0), cc.p(0, 0))

    local titileRoleBg = createSprite(nil, "res/common/bg/infoBg11-2.png", cc.p(0, 0), cc.p(0, 0))
    createLabel(titileRoleBg, game.getStrByKey("wr_title_role"), getCenterPos(titileRoleBg), cc.p(0.5, 0.5), 22, false, nil, nil, MColor.lable_yellow)

    local attNode = self:createAttNode()

 --    local skillTitleBg = createSprite(nil, "res/common/bg/titleBg2.png", cc.p(0, 0), cc.p(0, 0))
	-- createLabel(skillTitleBg, game.getStrByKey("wr_riding_skill"), getCenterPos(skillTitleBg), cc.p(0.5, 0.5), 22, false, nil, nil, MColor.lable_yellow)
    
 --    local skillNode = self:createSkillNode(self.otherRoleData)

    local topPadding = cc.Node:create()
    topPadding:setContentSize(cc.size(10, 0))

    --local Mnode = require("src/young/node")
    local node = Mnode.combineNode(
	{
		nodes = 
		{
			--skillNode,
			--skillTitleBg,
			attNode,
			titileRoleBg,
			--lineTop,
			power_bg,
			--topPadding,
		},
		ori = "|",
		margins = 5,
	})
	self.node:addChild(node)
	--dump(node:getContentSize())
	self.scrollView:setContentSize(cc.size(280, node:getContentSize().height))
	self.scrollView:setContentOffset(cc.p(0, -(node:getContentSize().height-478)), false)
end

return RidingLeftNode