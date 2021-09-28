local WingAndRidingLeftNode = class("WingAndRidingLeftNode", function() return cc.Node:create() end )

local pathCommon = "res/wingAndRiding/common/"

function WingAndRidingLeftNode:ctor(parent, type, isAdvance, otherRoleData, param)
	local pathWing = "res/wingAndRiding/wing/"
	local pathRiding = "res/wingAndRiding/riding/"
	local path

	self.type = type
	self.param = param
	dump(self.param)

	local isOtherRole = false
	if otherRoleData then
		self.otherRoleData = otherRoleData
		isOtherRole = true
		self.isOtherRole = true
		dump(otherRoleData)
	end

	local tab,skillTab = nil,{}
 	local id
	if self.type == wingAndRidingType.WR_TYPE_WING then
		tab = "WingCfg"
		id = G_WING_INFO.id

		if G_WING_INFO.skillTab == nil then
			G_WING_INFO.skillTab = {}
		end
		skillTab = G_WING_INFO.skillTab
		if isOtherRole then
			id = otherRoleData.wing.id
			if otherRoleData.wing.skillTab == nil then
				otherRoleData.wing.skillTab = {}
			end 
			skillTab = otherRoleData.wing.skillTab
		end
	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
		tab = "RidingCfg"
		id = G_RIDING_INFO.id

		if G_RIDING_INFO.skillTab == nil then
			G_RIDING_INFO.skillTab = {}
		end
		skillTab = G_RIDING_INFO.skillTab
		if isOtherRole then
			id = otherRoleData.ridingInfo.id
			if otherRoleData.ridingInfo.skillTab == nil then
				otherRoleData.ridingInfo.skillTab = {}
			end 
			skillTab = otherRoleData.ridingInfo.skillTab
		end
	end 
	self.skillTab = skillTab

	local record = getConfigItemByKey(tab, "q_ID", id)
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
			G_WING_LEFT_NODE = self
		elseif event == "exit" then
			G_WING_LEFT_NODE = nil
		end
	end)
end

function WingAndRidingLeftNode:refresh()
	self:updateScrollView()
end

function WingAndRidingLeftNode:getFight()
	local record = self.record
	if record then
		--dump(record)
		local paramTab = {}

		local MRoleStruct = require("src/layers/role/RoleStruct")
		paramTab.school = MRoleStruct:getAttr(ROLE_SCHOOL)
		if self.otherRoleData and self.otherRoleData.school then
			--dump(self.otherRoleData.school)
			paramTab.school = self.otherRoleData.school
		end
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

function WingAndRidingLeftNode:createAttNode()
	local record = self.record
	if record == nil then
		return nil
	end

	--羽化效果
	-- local addAttExt
	-- if self.skillTab and self.skillTab[2] then
	-- 	if self.skillTab[2] and self.skillTab[2].skillLevel and self.skillTab[2].skillLevel > 0 then
	-- 		addAttExt = getConfigItemByKeys("WingSkillDB", {"q_pos", "q_level"}, {2, self.skillTab[2].skillLevel}, "q_addAttr")
	-- 		if addAttExt then
	-- 			addAttExt = addAttExt/100
	-- 		end
	-- 	end
	-- end

	local attStrs = {}

	local formatStr2 = function(str1, str2, ignoreAddAttExt)
		local str = "^c(lable_yellow)"..str1.."^".." ".."^c(white)"..str2.."^"
		if addAttExt and ignoreAddAttExt ~= true then
			str = str.." ^c(green)("..math.ceil(str2*addAttExt)..")^"
		end
		return str
	end

	local formatStr3 = function(str1, str2, str3, ignoreAddAttExt)
		local str = "^c(lable_yellow)"..str1.."^".." ".."^c(white)"..str2.."-"..str3.."^"
		if addAttExt and ignoreAddAttExt ~= true then
			str = str.." ^c(green)("..math.ceil(str2*addAttExt).."-"..math.ceil(str3*addAttExt)..")^"
		end
		return str
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

	local cfgTab = getConfigItemByKey("WingCfg")
	local skillCfg = {}
	local index = 1
	for i,v in ipairs(cfgTab) do
		if v.q_activeSkill > 0 then
			local record = v.q_activeSkill
			table.insert(skillCfg, record)
			index = index + 1
			if #skillCfg == 4 then
				break
			end
		end
	end
	dump(skillCfg)

	dump(self.skillTab)
	if self.skillTab then
		for i,v in ipairs(self.skillTab) do
			if v.skillId == 3 and v.skillLevel > 0 then
				local num = getConfigItemByKey("SkillLevelCfg", "skillID", skillCfg[v.skillId]*1000+v.skillLevel, "hs2")
				if num then
					local str = formatStr2(game.getStrByKey("hu_shen"), num, true)
					table.insert(attStrs, str)
				end
			end

			if v.skillId == 4 and v.skillLevel > 0 then
				local num = getConfigItemByKey("SkillLevelCfg", "skillID", skillCfg[v.skillId]*1000+v.skillLevel, "hs21")
				if num then
					local str = formatStr2(game.getStrByKey("hu_shen_rift"), num, true)
					table.insert(attStrs, str)
				end
			end
		end
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
	-- 	local richText = require("src/RichText").new(node, pos[i], cc.size(200, 30), cc.p(0, 0), 30, 20, MColor.white)
	--     richText:addText(v, MColor.white, false)
	--     richText:format()
	-- end

	local richText = require("src/RichText").new(node, cc.p(0, 0), cc.size(240, 30), cc.p(0, 0), 30, 20, MColor.white)
	for i,v in ipairs(attStrs) do
	    richText:addText(v.."\n", MColor.white, false)
	end
	richText:format()
	--dump(richText:getContentSize())

	return richText
end

function WingAndRidingLeftNode:createSkillNode(otherRoleData)
	local isOtherRole = false
	if otherRoleData then
		isOtherRole = true
	end
	--dump(otherRoleData)
	local Mnode = require("src/young/node")

	local skillNodes = {}
	local tab = {}
	local wingId
	--local count
	--local skillTab = require("src/config/SkillCfg")
	if self.type == wingAndRidingType.WR_TYPE_WING then
		wingId = G_WING_INFO.id
		tab = G_WING_INFO.skillTab
		count = G_WING_INFO.skillCount
		if isOtherRole then
			tab = otherRoleData.wing.skillTab
			wingId = otherRoleData.wing.id
			--count = otherRoleData.wingInfo.skillCount
		end
	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
		tab = G_RIDING_INFO.skillTab
		count = G_RIDING_INFO.skillCount
		if isOtherRole then
			tab = otherRoleData.ridingInfo.skillTab
			--count = otherRoleData.ridingInfo.skillCount
		end
	end  

	-- local function checkBookFunc()
	-- 	if self.isOtherRole then
	-- 		return 
	-- 	end

	-- 	local job
	-- 	if self.type == wingAndRidingType.WR_TYPE_WING then
	-- 		job = 5
	-- 	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
	-- 		job = 4
	-- 	end  
	-- 	local layer = require("src/layers/wingAndRiding/WingAndRidingBookLayer").new(job)
	-- 	Manimation:transit(
	-- 	{
	-- 		ref = G_MAINSCENE.base_node,
	-- 		node = layer,
	-- 		curve = "-",
	-- 		sp = cc.p(display.cx, 0),
	-- 		zOrder = 200,
	-- 		--swallow = true,
	-- 	})
	-- end

	-- local function checkBookFuncEx()
	-- 	if self.isOtherRole then
	-- 		return 
	-- 	end

	-- 	local job
	-- 	if self.type == wingAndRidingType.WR_TYPE_WING then
	-- 		job = 5
	-- 	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
	-- 		job = 4
	-- 	end  
	-- 	local layer = require("src/layers/wingAndRiding/WingAndRidingBookLayer").new(job, true)
	-- 	Manimation:transit(
	-- 	{
	-- 		ref = G_MAINSCENE.base_node,
	-- 		node = layer,
	-- 		curve = "-",
	-- 		sp = cc.p(display.cx, 0),
	-- 		zOrder = 200,
	-- 		--swallow = true,
	-- 	})
	-- end

	local function getSkillLevelString(index, level)
		local cfgTab = getConfigItemByKey("WingCfg")
		local skillTab = {}
		for i,v in ipairs(cfgTab) do
			if v.q_activeSkill and v.q_activeSkill > 0 then
				table.insert(skillTab, v.q_activeSkill)
				if #skillTab == 4 then
					break
				end
			end
		end
		dump(skillTab)

		local skillRecord = getConfigItemByKey("SkillLevelCfg", "skillID", skillTab[index]*1000+level)
		dump(skillTab)
		if skillRecord then
			local levelStr = game.getStrByKey("skillLevel"..skillRecord.skill_color)
			local starStr = ""
			-- if skillRecord.skill_starNum and skillRecord.skill_starNum > 0 then
			-- 	starStr = skillRecord.skill_starNum..game.getStrByKey("task_d_x")
			-- end

			return levelStr..starStr
		end
	end

	local function checkSkillFunc(index)
		log("checkSkillFunc")
		if self.isOtherRole then
			return
		end
		
		__GotoTarget({ru = "a184", jnChoose = index})
	end

	-- local function checkRed(index)
	-- 	local record = getConfigItemByKeys("WingSkillDB", {"q_pos", "q_level"}, {index, 1})

	-- 	if record and record.q_itemID then
	-- 		local MPackStruct = require "src/layers/bag/PackStruct"
	-- 		local MPackManager = require "src/layers/bag/PackManager"
	-- 		local pack = MPackManager:getPack(MPackStruct.eBag)
	-- 		local num = pack:countByProtoId(record.q_itemID)

	-- 		if num > 0 then
	-- 			return num
	-- 		else
	-- 			return false
	-- 		end
	-- 	end
	-- end

	--技能孔和阶数对应表
	local cfgTab = {}
	local skillActiveTab = {}
	if self.type == wingAndRidingType.WR_TYPE_WING then
		cfgTab = getConfigItemByKey("WingCfg")
	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
		cfgTab = getConfigItemByKey("RidingCfg")
	end 

	dump(tab)
	local skillCfg = {}
	local index = 1
	for i,v in ipairs(cfgTab) do
		if v.q_activeSkill > 0 then
			-- dump(v.q_activeSkill)
			-- dump(index)
			-- dump(tab[index])
			-- dump(v.q_activeSkill*1000+(tab[index].skillLevel or 1))
			local level = tab[index].skillLevel
			if level == 0 then
				level = 1
			end
			local record = getConfigItemByKey("SkillLevelCfg", "skillID", v.q_activeSkill*1000+level)
			table.insert(skillCfg, record)
			index = index + 1
			if #skillCfg == 4 then
				break
			end
		end
	end
	dump(skillCfg)

	--dump(G_WING_INFO.id)

	for i,v in ipairs(cfgTab) do
		--log("000000000000000000000   "..v.q_ID)
		if math.floor(wingId/1000) == math.floor(v.q_ID/1000) then
			--log("111111111111111111111111   "..v.q_ID)
			
			if v.q_activeSkillPos and v.q_activeSkillPos > 0 then
				log("222222222222222222222222")
				skillActiveTab[v.q_activeSkillPos] = true
			end
		end

		if wingId == v.q_ID then
			break
		end
	end
	--dump(skillActiveTab)

	-- if tab then
	-- 	for i=1,4 do
	-- 		if tab[i] == nil and skillActiveTab[i] == true then
	-- 			tab[i] = {skillId=i, skillLevel=0, skillProgress=0}
	-- 		end
	-- 	end
	-- end

	if tab == nil then
		tab = {}
	end
	dump(tab)
	for i=1,4 do
		log("i="..i)
		--已学习
		if tab[i] and tab[i].skillLevel and tab[i].skillLevel > 0 then
			log("11111111111111")
			local record = tab[i]
			--dump(record)
			local skillCfgRecord = skillCfg[i]--getConfigItemByKeys("WingSkillDB", {"q_pos", "q_level"}, {record.skillId, record.skillLevel})
			dump(skillCfgRecord)
			local skillBgSpr = createSprite(nil, "res/common/bg/bg15-1.png", cc.p(0, 0), cc.p(0, 0))
			local skillIcoBg = createSprite(skillBgSpr, "res/common/bg/itemBg.png", cc.p(55, skillBgSpr:getContentSize().height/2), cc.p(0.5, 0.5))
			local skillIconSpr = createTouchItem(skillIcoBg, pathCommon.."skill"..i..".png", getCenterPos(skillIcoBg), function() checkSkillFunc(i) end)
			skillIconSpr:setScale(0.8)
			local nameLabel = createLabel(skillBgSpr, skillCfgRecord.name1, cc.p(100, 55), cc.p(0, 0), 22, nil, nil, nil, MColor.yellow)
			--createLabel(skillBgSpr, "(Lv."..tab[i].skillLevel..")", cc.p(100 + nameLabel:getContentSize().width+10, 63), cc.p(0, 0), 20, nil, nil, nil, MColor.green)

			-- if skillCfgRecord and skillCfgRecord.desc then
			-- 	local richText = require("src/RichText").new(skillBgSpr, cc.p(100, 60), cc.size(115, 30), cc.p(0, 1), 20, 16, MColor.lable_black)
			-- 	richText:addText(skillCfgRecord.desc)
			-- 	richText:format()
			-- end
			local levelStr = createLabel(skillBgSpr, getSkillLevelString(i, tab[i].skillLevel), cc.p(100, 20), cc.p(0, 0), 18, nil, nil, nil, MColor.lable_yellow)

			function createStar(starNum, x)
				if starNum <= 0 then
					return
				end

				local star = {}
				local y = 32
				local addX = 20
				local scale = 0.5
				star[1] = createSprite(skillBgSpr, "res/group/star/s3.png", cc.p(x, y), cc.p(0, 0.5), nil, scale)
				star[2] = createSprite(skillBgSpr, "res/group/star/s3.png", cc.p(x+addX, y), cc.p(0, 0.5), nil, scale)
				star[3] = createSprite(skillBgSpr, "res/group/star/s3.png", cc.p(x+addX*2, y), cc.p(0, 0.5), nil, scale)

				for i=1,starNum do
					createSprite(star[i], "res/group/star/s4.png", getCenterPos(star[i]), cc.p(0.5, 0.5))
				end
			end
			createStar(skillCfgRecord.skill_starNum, levelStr:getPositionX()+levelStr:getContentSize().width)

			-- local advanceBtn = createTouchItem(skillBgSpr, "res/component/button/plus.png", cc.p(240, skillBgSpr:getContentSize().height/2), function() checkSkillFunc(i) end)
			-- if self.isOtherRole then
			-- 	advanceBtn:setVisible(false)
			-- end
			-- local itemNum = checkRed(i)
			-- if itemNum then
			-- 	local redTag = createSprite(advanceBtn, "res/component/flag/red.png", cc.p(advanceBtn:getContentSize().width, advanceBtn:getContentSize().height), cc.p(0.5, 0.5))
			-- 	createLabel(redTag, itemNum, getCenterPos(redTag, 0, 3), cc.p(0.5, 0.5), 16, nil, nil, nil, MColor.white)
			-- end
			
			table.insert(skillNodes, 1, skillBgSpr)
		else
			--已激活未学习
			if skillActiveTab[i] then
				log("22222222222222")
				local record = tab[i]
				--dump(record)
				local skillCfgRecord = skillCfg[i]--getConfigItemByKeys("WingSkillDB", {"q_pos", "q_level"}, {i, 1})
				--dump(skillCfgRecord)
				local skillBgSpr = createSprite(nil, "res/common/bg/bg15-1.png", cc.p(0, 0), cc.p(0, 0))
				local skillIcoBg = createSprite(skillBgSpr, "res/common/bg/itemBg.png", cc.p(55, skillBgSpr:getContentSize().height/2), cc.p(0.5, 0.5))
				local skillIconSpr = createTouchItem(skillIcoBg, pathCommon.."skill"..i..".png", getCenterPos(skillIcoBg), function() checkSkillFunc(i) end)
				skillIconSpr:setScale(0.8)
				skillIconSpr:addColorGray()
				--skillIconSpr:setTouchEnable(false)
				local nameLabel = createLabel(skillBgSpr, skillCfgRecord.name1, cc.p(100, 55), cc.p(0, 0), 22, nil, nil, nil, MColor.yellow)
				--createLabel(skillBgSpr, "("..game.getStrByKey("wr_skill_can_learn")..")", cc.p(100 + nameLabel:getContentSize().width+10, 63), cc.p(0, 0), 20, nil, nil, nil, MColor.green)

				-- if skillCfgRecord and skillCfgRecord.desc then
				-- 	local richText = require("src/RichText").new(skillBgSpr, cc.p(100, 60), cc.size(115, 30), cc.p(0, 1), 20, 16, MColor.lable_black)
				-- 	richText:addText(skillCfgRecord.desc)
				-- 	richText:format()
				-- end
				createLabel(skillBgSpr, game.getStrByKey("wr_skill_can_learn"), cc.p(100, 23), cc.p(0, 0), 18, nil, nil, nil, MColor.green)

				-- local advanceBtn = createTouchItem(skillBgSpr, "res/component/button/plus.png", cc.p(240, skillBgSpr:getContentSize().height/2-5), function() checkSkillFunc(i) end)
				-- if self.isOtherRole then
				-- 	advanceBtn:setVisible(false)
				-- end
				-- local itemNum = checkRed(i)
				-- if itemNum then
				-- 	local redTag = createSprite(advanceBtn, "res/component/flag/red.png", cc.p(advanceBtn:getContentSize().width, advanceBtn:getContentSize().height), cc.p(0.5, 0.5))
				-- 	createLabel(redTag, itemNum, getCenterPos(redTag, 0, 3), cc.p(0.5, 0.5), 16, nil, nil, nil, MColor.white)
				-- end

				table.insert(skillNodes, 1, skillBgSpr)
			else
				log("33333333333333333")
				--未激活
				local record = tab[i]
				--dump(record)
				local skillCfgRecord = skillCfg[i]--getConfigItemByKeys("WingSkillDB", {"q_pos", "q_level"}, {i, 1})
				--dump(skillCfgRecord)
				local skillBgSpr = createSprite(nil, "res/common/bg/bg15-1.png", cc.p(0, 0), cc.p(0, 0))
				local skillIcoBg = createSprite(skillBgSpr, "res/common/bg/itemBg.png", cc.p(55, skillBgSpr:getContentSize().height/2), cc.p(0.5, 0.5))
				local skillIconSpr = createTouchItem(skillIcoBg, pathCommon.."skill"..i..".png", getCenterPos(skillIcoBg), function() checkSkillFunc(i) end)
				skillIconSpr:setScale(0.8)
				skillIconSpr:addColorGray()
				skillIconSpr:setTouchEnable(false)
				createLabel(skillBgSpr, skillCfgRecord.name1, cc.p(100, 55), cc.p(0, 0), 22, nil, nil, nil, MColor.yellow)

				--log("i = "..i)
				for k,v in pairs(cfgTab) do
					--log("tese i = "..i)
					if v.q_activeSkillPos and v.q_activeSkillPos == i then
						--log("111111111111111111111111111111111")
						--dump(v)
						local richText = require("src/RichText").new(skillBgSpr, cc.p(100, 23), cc.size(160, 30), cc.p(0, 0), 18, 18, MColor.lable_black)
						richText:addText(string.format(game.getStrByKey("wr_advance_to"), game.getStrByKey("num_"..v.q_level), v.q_star))
						richText:format()

						break
					end
				end
				-- if skillCfgRecord and skillCfgRecord.q_desc then
				-- 	local richText = require("src/RichText").new(skillBgSpr, cc.p(100, 60), cc.size(170, 30), cc.p(0, 1), 22, 20, MColor.white)
				-- 	richText:addText(skillCfgRecord.q_desc)
				-- 	richText:format()
				-- end

				table.insert(skillNodes, 1, skillBgSpr)
			end
		end
	end
	-- local tipLable = require("src/RichText").new(nil, cc.p(0, 0), cc.size(250, 30), cc.p(0, 1), 22, 20, MColor.red)
	-- tipLable:addText(game.getStrByKey("wr_skill_tip"), nil, false)
	-- tipLable:format()
	
	log("#skillNodes="..#skillNodes)
	local node = Mnode.combineNode(
	{
		nodes = 
		{
			--tipLable,
			Mnode.combineNode(
			{
				nodes = skillNodes,
				ori = "|",
				margins = 3,
			}),
			--skillTitleBg
		},
		ori = "|",
		margins = 3,
	})

	dump(self.param)
	dump(type(self.param))
	if self.param and type(self.param) == "string" and self.param == "toSkill" then
		startTimerAction(self, 0.2, false, function() checkSkillFunc(1) end)  
		self.param = nil
	end

	return node
end

function WingAndRidingLeftNode:updateScrollView()
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

    local skillTitleBg = createSprite(nil, "res/common/bg/infoBg11-2.png", cc.p(0, 0), cc.p(0, 0))
    local skillPadding = cc.Node:create()
    skillPadding:setContentSize(cc.size(10, 10))
    if self.type == wingAndRidingType.WR_TYPE_WING then
		createLabel(skillTitleBg, game.getStrByKey("wr_wing_skill"), getCenterPos(skillTitleBg), cc.p(0.5, 0.5), 22, false, nil, nil, MColor.lable_yellow)
	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
		createLabel(skillTitleBg, game.getStrByKey("wr_riding_skill"), getCenterPos(skillTitleBg), cc.p(0.5, 0.5), 22, false, nil, nil, MColor.lable_yellow)
	end 
    
    local skillNode = self:createSkillNode(self.otherRoleData)

    local topPadding = cc.Node:create()
    topPadding:setContentSize(cc.size(10, 0))

    --local Mnode = require("src/young/node")
    local node = Mnode.combineNode(
	{
		nodes = 
		{
			skillNode,
			skillPadding,
			skillTitleBg,
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

return WingAndRidingLeftNode