local WingAndRidingAdvanceNode = class("WingAndRidingAdvanceNode", function() return cc.Node:create() end )

local pathCommon = "res/wingAndRiding/common/"

function WingAndRidingAdvanceNode:ctor(parent)
	local msgids = {WING_SC_PROMOTE_RET,
					WING_SC_PROMOTE_CONDITION_FAIL,
					WING_SC_GET_WING_PRICE_RET,
					}
	require("src/MsgHandler").new(self,msgids)

	dump(G_WING_INFO)

	self.parent = parent
	self.nowLevel = self:getCfgData("q_level", true)
	self.selectLevel = self.nowLevel
	self.maxLevel = 7
	self.blessValue = self:getData("bless")
	self.maxBless = self:getCfgData("q_needNum", true)
	self.school = require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)

	local bg = createSprite(self, "res/common/bg/bg18.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	self.bg = bg
	createLabel(bg, game.getStrByKey("wr_update"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-30), cc.p(0.5, 0.5), 24, true)

	local contentBg = createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 15),
        cc.size(792,455),
        5
    )

	local closeFunc = function() 
	   	self.bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0), cc.CallFunc:create(function() self:removeFromParent() end)))	
	end
	local closeBtn = createTouchItem(bg, "res/component/button/x2.png", cc.p(bg:getContentSize().width-48, bg:getContentSize().height-28), closeFunc)

	local rightBg = createScale9Sprite(contentBg, "res/common/scalable/setbg.png", cc.p(435, 5), cc.size(345, 440), cc.p(0, 0))
	self.rightBg = rightBg
	local leftBg = createSprite(contentBg, "res/wingAndRiding/1.png", cc.p(5, 5), cc.p(0, 0))
	self.leftBg = leftBg
	
	self:updateData()

	registerOutsideCloseFunc(bg , closeFunc, true)

	self:registerScriptHandler(function(event)
		if event == "enter" then
			G_TUTO_NODE:setShowNode(self, SHOW_WING_ADVANCE)
		elseif event == "exit" then
			
		end
	end)
end

function WingAndRidingAdvanceNode:updateData()
	self:updateUI()
end

function WingAndRidingAdvanceNode:updateUI()
	self:updateLeft()
	self:updateRight()
	--startTimerAction(self, 1, true, function() self:updateRight() end)
end

function WingAndRidingAdvanceNode:updateLeft()
	self.leftBg:removeAllChildren()

	createLabel(self.leftBg, game.getStrByKey("wr_update_pre_tip"), cc.p(self.leftBg:getContentSize().width/2, 5), cc.p(0.5, 0), 20, true, nil, nil, MColor.lable_yellow)

	local wingSpr = createSprite(self.leftBg, "res/showplist/wing/"..self.selectLevel..".png", cc.p(self.leftBg:getContentSize().width/2+20, 230), cc.p(0.5, 0.5))
	--wingSpr:setScale(1.2)

	local nameBg = createSprite(self.leftBg, "res/layers/role/24.png", cc.p(self.leftBg:getContentSize().width/2, 370), cc.p(0.5, 0)) 
	createLabel(nameBg, self:getCfgDataByLevel("q_name", self.selectLevel), getCenterPos(nameBg, 0, -9), cc.p(0.5, 0.5), 20, true)

	local levelBg = createSprite(self.leftBg, pathCommon.."1.png", cc.p(370, 380), cc.p(0.5, 0.5))
	local levelNum = self.selectLevel
	createMultiLineLabel(levelBg, game.getStrByKey("num_"..levelNum)..game.getStrByKey("grade"), cc.p(levelBg:getContentSize().width/2, levelBg:getContentSize().height-25), cc.p(0.5, 1), 22, true, nil, nil, MColor.lable_yellow, 30, 25, true)

	if self.selectLevel == self.nowLevel then
		local function createStar()
			local star = {}
			local padding = 30
			local y = 355
			star[1] = createSprite(self.leftBg, "res/group/star/s3.png", cc.p(self.leftBg:getContentSize().width/2-padding*2, y), cc.p(0.5, 0.5), nil, 0.8)
			star[2] = createSprite(self.leftBg, "res/group/star/s3.png", cc.p(self.leftBg:getContentSize().width/2-padding, y), cc.p(0.5, 0.5), nil, 0.8)
			star[3] = createSprite(self.leftBg, "res/group/star/s3.png", cc.p(self.leftBg:getContentSize().width/2, y), cc.p(0.5, 0.5), nil, 0.8)
			star[4] = createSprite(self.leftBg, "res/group/star/s3.png", cc.p(self.leftBg:getContentSize().width/2+padding, y), cc.p(0.5, 0.5), nil, 0.8)
			star[5] = createSprite(self.leftBg, "res/group/star/s3.png", cc.p(self.leftBg:getContentSize().width/2+padding*2, y), cc.p(0.5, 0.5), nil, 0.8)

			local starNum = self:getCfgData("q_star", true)
			for i=1,starNum do
				createSprite(star[i], "res/group/star/s4.png", getCenterPos(star[i]), cc.p(0.5, 0.5), nil, 0.8)
			end
		end

		createStar()
		--createLabel(self.leftBg, game.getStrByKey("wr_progress").."：", cc.p(130, 315), cc.p(0, 0), 20, true, nil, nil, MColor.lable_yellow)
		self.progressLabel = createLabel(self.leftBg, "0/0", cc.p(230, 315), cc.p(0, 0), 20, true, nil, nil, MColor.white)
		self.progressLabel:setVisible(false)
		if self.blessValue and self.maxBless then
			self.progressLabel:setString(self.blessValue.."/"..self.maxBless)
		end
	end

	local preBtnFunc = function()
		self.selectLevel = self.selectLevel - 1
		if self.selectLevel < 1 then
			self.selectLevel = 1
		end
		self:updateLeft()
	end
	local preBtn = createMenuItem(self.leftBg, "res/group/arrows/18.png", cc.p(self.leftBg:getContentSize().width/2-185, self.leftBg:getContentSize().height/2), preBtnFunc)
	self.preBtn = preBtn
	--preBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(display.cx-400-5, 300)), cc.MoveTo:create(0.3, cc.p(display.cx-400, 300)))))
	--preBtn:setOpacity(255*0.5)

	local nextBtnFunc = function()
		self.selectLevel = self.selectLevel + 1
		if self.selectLevel > self.maxLevel then
			self.selectLevel = self.maxLevel
		end
		self:updateLeft()
	end
	local nextBtn = createMenuItem(self.leftBg, "res/group/arrows/19.png", cc.p(self.leftBg:getContentSize().width/2+185, self.leftBg:getContentSize().height/2), nextBtnFunc)
	self.nextBtn = nextBtn
	--nextBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(display.cx+400+5, 300)), cc.MoveTo:create(0.3, cc.p(display.cx+400, 300)))))
	--nextBtn:setOpacity(255*0.5)

	if self.selectLevel <= 1 then
		self.preBtn:setVisible(false)
	elseif self.selectLevel >= self.maxLevel then
		self.nextBtn:setVisible(false)
	end
end

function WingAndRidingAdvanceNode:updateRight()
	self.rightBg:removeAllChildren()
	
	createLabel(self.rightBg, game.getStrByKey("wr_now_info"), cc.p(100, 410), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.lable_yellow)
	createLabel(self.rightBg, game.getStrByKey("wr_next_info"), cc.p(280, 410), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.lable_yellow)

	local id = self:getData("id")
	local nextId = self:getNextId(id)
	local record = getConfigItemByKey("WingCfg", "q_ID", id)
	local nextRecord = getConfigItemByKey("WingCfg", "q_ID", nextId)
	self:createAttNode(record)
	self:createAttNodeEx(nextRecord)

	createSprite(self.rightBg, "res/group/arrows/17.png", cc.p(210, 310), cc.p(0.5, 0.5), nil, 0.75)

	local lineBg = createSprite(self.rightBg, "res/common/bg/bg27-4-2.png", cc.p(self.rightBg:getContentSize().width/2, 205), cc.p(0.5, 0.5))
	createLabel(lineBg, game.getStrByKey("wr_use"), getCenterPos(lineBg), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.lable_yellow)
	
	local oneKeyBtnFunc = function()
		local isAuto = 1
		local t = {}
		t.onceUp = isAuto
		g_msgHandlerInst:sendNetDataByTableExEx(WING_CS_PROMOTE, "WingPromoteProtocol", t)
		--self:addBlessEffect(1)
	end
	local oneKeyBtn = createMenuItem(self.rightBg, "res/component/button/50.png", cc.p(self.rightBg:getContentSize().width/2, 40), oneKeyBtnFunc)
	self.oneKeyBtn = oneKeyBtn
	G_TUTO_NODE:setTouchNode(oneKeyBtn, TOUCH_WING_ADVANCE_ADVANCE)

	local upLable = createLabel(oneKeyBtn, game.getStrByKey("wr_up_star"), getCenterPos(oneKeyBtn), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.lable_yellow)
	if self:getCfgData("q_star", true) == 5 then
		upLable:setString(game.getStrByKey("wr_up"))
	end

	-- local useBtnFunc = function()
	-- 	local t = {}
	-- 	t.onceUp = isAuto
	-- 	g_msgHandlerInst:sendNetDataByTableExEx(WING_CS_PROMOTE, "WingPromoteProtocol", t)
	-- end
	-- local useBtn = createMenuItem(self.rightBg, "res/component/button/50.png", cc.p(self.rightBg:getContentSize().width/2+80, 40), useBtnFunc)
	-- createLabel(useBtn, game.getStrByKey("wr_btn_use"), getCenterPos(useBtn), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.lable_yellow)

	local isSpecial = function()
		-- if self.blessValue and self.maxBless and self.blessValue == self.maxBless then
		-- 	return true
		-- end

		return false
	end

	if isSpecial() then
		removeFromParent(oneKeyBtn)
		--removeFromParent(useBtn)

		local upBtnFunc = function()
		local t = {}
		t.onceUp = isAuto
			g_msgHandlerInst:sendNetDataByTableExEx(WING_CS_PROMOTE, "WingPromoteProtocol", t)
		end
		local upBtn = createMenuItem(self.rightBg, "res/component/button/50.png", cc.p(self.rightBg:getContentSize().width/2, 40), upBtnFunc)
		createLabel(upBtn, game.getStrByKey("wr_up"), getCenterPos(upBtn), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.lable_yellow)
	end

	self:updateNeedsLabel()
end 

function WingAndRidingAdvanceNode:updateNeedsLabel()
	--self.needsLabel = createLinkLabel(bg, "坐骑进阶丹", cc.p(150, 120), cc.p(0, 0.5), 20, true, nil, MColor.white, nil, nil, true)--addLabel(bg, "", cc.p(150, 120), cc.p(0, 0.5), 20)
	--self.neddsNumLabel = addLabel(bg, "", cc.p(105, 120), cc.p(0, 0.5), 20)
	local isSpecial = function()
		-- if self.blessValue and self.maxBless and self.blessValue == self.maxBless then
		-- 	return true
		-- end

		return false
	end

	local getMaterialNumber = function(tabStr)
		local num = 0
		local tab = unserialize(tabStr)
		--dump(tab)
		if tab then
			local MPackStruct = require "src/layers/bag/PackStruct"
			local MPackManager = require "src/layers/bag/PackManager"
			local pack = MPackManager:getPack(MPackStruct.eBag)
			for k,v in pairs(tab) do
				num = num + pack:countByProtoId(v)
			end
		end

		return num
	end

	local getNeedMaterialStr = function()
		local materId =  self:getCfgData("q_materialID", true)
		if isSpecial() and self:getCfgData("q_advID", true) then
			materId =  self:getCfgData("q_advID", true)
		end
		self.material = materId
		local meterName = getConfigItemByKey("propCfg", "q_id", materId, "q_name")
		local materialNumber = self.maxBless - (self.blessValue or 0)
		if isSpecial() and self:getCfgData("q_advNum", true) then
			materialNumber =  self:getCfgData("q_advNum", true)
		end
		local needStr = meterName
		local needNumStr = "x"..materialNumber
		local num = getMaterialNumber("{"..materId.."}")
		dump(num)
		local fontColor
		if num >= materialNumber then
			fontColor = MColor.green
		else
			fontColor = MColor.red
		end
		return needStr, needNumStr, fontColor, num
	end
	local str, numStr, color, materialNum = getNeedMaterialStr()
	local colorMaterial = color
	if str then
		self.needsLabel = createLinkLabel(self.rightBg, str, cc.p(40, 170), cc.p(0, 0.5), 20, true, nil, MColor.yellow, nil, function() 
			log("1111")
			local Mtips = require "src/layers/bag/tips"
			Mtips.new(
			{ 
				protoId = self.material,
				pos = cc.p(0, 0),
			})
		 end, true)
	end

	if numStr then
		self.needsNumLabel = createLabel(self.rightBg, "", cc.p(40 + self.needsLabel:getContentSize().width + 1, 170), cc.p(0, 0.5), 20, true)
		self.needsNumLabel:setString(numStr)
		if color then
			--dump(color)
			dump(color)
			self.needsNumLabel:setColor(color)
		end
	end

	local getNeedMoneyStr = function()
		local needStr = getConfigItemByKey("propCfg", "q_id", 999998, "q_name")
		local needMoney = self:getCfgData("q_needMoney", true) * (self.maxBless - (self.blessValue or 0))
		if self.maxBless == self.blessValue then
			needMoney = 0
		end
		local myMoney = G_ROLE_MAIN.currGold + G_ROLE_MAIN.currBindGold
		--dump(needMoney)
		--dump(myMoney)
		local fontColor
		if myMoney >= needMoney then
			fontColor = MColor.green
		else
			fontColor = MColor.red
		end
		return needStr, "x"..numToFatString(needMoney), fontColor, myMoney
	end
	local str, numStr, color, myMoney = getNeedMoneyStr()
	local colorMoney = color
	if str and numStr ~= "x0" then
		self.needMoneyLabel = createLabel(self.rightBg, str, cc.p(40, 130), cc.p(0, 0.5), 20, true, nil, nil, MColor.yellow)
	end

	if numStr and numStr ~= "x0" then
		self.moneyNumLabel = createLabel(self.rightBg, "", cc.p(81, 130), cc.p(0, 0.5), 20, true)
		self.moneyNumLabel:setString(numStr)
		if color then
			self.moneyNumLabel:setColor(color)
		end
	end

	createLabel(self.rightBg, game.getStrByKey("wr_my").."：", cc.p(180, 170), cc.p(0, 0.5), 20, true, nil, nil, MColor.lable_black)
	if materialNum then
		self.myMaterialNumLabel = createLabel(self.rightBg, materialNum, cc.p(240, 170), cc.p(0, 0.5), 20, true, nil, nil, MColor.white)
		startTimerAction(self.myMaterialNumLabel, 1, true, function() 
			local str, numStr, color, materialNum = getNeedMaterialStr()
			if materialNum then
				self.myMaterialNumLabel:setString(materialNum)
			end
			if color then
				if self.needsNumLabel and checkNode(self.needsNumLabel) then
					self.needsNumLabel:setColor(color)
				end
			end
		 end)
	end

	if numStr and numStr ~= "x0" then
		createLabel(self.rightBg, game.getStrByKey("wr_my").."：", cc.p(180, 130), cc.p(0, 0.5), 20, true, nil, nil, MColor.lable_black)
		if myMoney then
			local str = numToFatString(myMoney)
			self.myMoneyLabel = createLabel(self.rightBg, str, cc.p(240, 130), cc.p(0, 0.5), 20, true, nil, nil, MColor.white)
			startTimerAction(self.myMoneyLabel, 1, true, function() 
				local str, numStr, color, myMoney = getNeedMoneyStr()
				if myMoney then
					local str = numToFatString(myMoney)
					self.myMoneyLabel:setString(str)
				end
			 end)
		end
	end

	local getNeedMaterialExStr = function()
		local materId = self:getCfgData("q_advID", true)
		local materialNumber =  self:getCfgData("q_advNum", true)

		if materId == nil or materialNumber == nil then
			return
		end
		self.materialEx = materId
		local meterName = getConfigItemByKey("propCfg", "q_id", materId, "q_name")
		local needStr = meterName
		local needNumStr = "x"..materialNumber
		local num = getMaterialNumber("{"..materId.."}")
		dump(num)
		local fontColor
		if num >= materialNumber then
			fontColor = MColor.green
		else
			fontColor = MColor.red
		end
		return needStr, needNumStr, fontColor, num
	end
	local str, numStr, color, materialNum = getNeedMaterialExStr()
	local colorMaterial = color
	if str then
		self.needsExLabel = createLinkLabel(self.rightBg, str, cc.p(40, 90), cc.p(0, 0.5), 20, true, nil, MColor.yellow, nil, function() 
			log("1111")
			local Mtips = require "src/layers/bag/tips"
			Mtips.new(
			{ 
				protoId = self.materialEx,
				pos = cc.p(0, 0),
			})
		 end, true)
	end

	if numStr then
		self.needsExNumLabel = createLabel(self.rightBg, "", cc.p(40 + self.needsExLabel:getContentSize().width + 1, 90), cc.p(0, 0.5), 20, true)
		self.needsExNumLabel:setString(numStr)
		if color then
			--dump(color)
			dump(color)
			self.needsExNumLabel:setColor(color)
		end
	end

	if materialNum then
		createLabel(self.rightBg, game.getStrByKey("wr_my").."：", cc.p(180, 90), cc.p(0, 0.5), 20, true, nil, nil, MColor.lable_black)
		self.myMaterialExNumLabel = createLabel(self.rightBg, materialNum, cc.p(240, 90), cc.p(0, 0.5), 20, true, nil, nil, MColor.white)
		startTimerAction(self.myMaterialExNumLabel, 1, true, function() 
			local str, numStr, color, materialNum = getNeedMaterialExStr()
			if materialNum then
				self.myMaterialExNumLabel:setString(materialNum)
			end
			if color then
				if self.needsExNumLabel and checkNode(self.needsExNumLabel) then
					self.needsExNumLabel:setColor(color)
				end
			end
		 end)
	end

	-- if colorMaterial == MColor.green and colorMoney == MColor.green then
	-- 	self.oneKeyBtn:setEnabled(true)
	-- else
	-- 	self.oneKeyBtn:setEnabled(false)
	-- end
end

function WingAndRidingAdvanceNode:createAttNode(record)
	if record == nil then
		return nil
	end

	local attStrs = {}

	local formatStr2 = function(str1, str2)
		return "        ^c(lable_yellow)"..str1.."^".." ".."^c(white)"..str2.."^"
	end

	local formatStr3 = function(str1, str2, str3)
		return "^c(lable_yellow)"..str1.."^".." ".."^c(white)"..str2.."-"..str3.."^"
	end

	local formatStr2Ex = function(str1)
		return "^c(green)"..str2.."^"
	end

	local formatStr3Ex = function(str1, str2)
		return "^c(white)"..str1.."-"..str2.."^"
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

	local richText = require("src/RichText").new(self.rightBg, cc.p(10, 390), cc.size(240, 30), cc.p(0, 1), 35, 20, MColor.white)
	for i,v in ipairs(attStrs) do
	    richText:addText(v.."\n", MColor.white, false)
	end
	richText:format()
	dump(richText:getContentSize())

	return richText
end

function WingAndRidingAdvanceNode:createAttNodeEx(record)
	if record == nil then
		return nil
	end

	local attStrs = {}

	local formatStr2 = function(str1, str2)
		return "^c(green)"..str2.."^"
	end

	local formatStr3 = function(str1, str2, str3)
		return "^c(green)"..str2.."-"..str3.."^"
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

	local richText = require("src/RichText").new(self.rightBg, cc.p(245, 390), cc.size(240, 30), cc.p(0, 1), 35, 20, MColor.white)
	for i,v in ipairs(attStrs) do
	    richText:addText(v.."\n", MColor.white, false)
	end
	richText:format()
	dump(richText:getContentSize())

	return richText
end

function WingAndRidingAdvanceNode:getData(key)
	log("key:"..key)
	return G_WING_INFO[key]
end

function WingAndRidingAdvanceNode:setData(key, value)
	G_WING_INFO[key] = value
end

function WingAndRidingAdvanceNode:getCfgData(key, isNow)
	local nextId = self:getNextId(G_WING_INFO.id)

	if isNow then
		nextId = self:getData("id")
	end

	return getConfigItemByKey("WingCfg", "q_ID", nextId, key)
end

function WingAndRidingAdvanceNode:getCfgDataByLevel(key, level)
	local cfgData = getConfigItemByKey("WingCfg")
	for i,v in ipairs(cfgData) do
		if v.q_level == level and v.q_school == self.school then
			return v[key]
		end
	end
end

function WingAndRidingAdvanceNode:getNextId(id)
	return getConfigItemByKey("WingCfg", "q_ID", id, "q_nextID")
end

function WingAndRidingAdvanceNode:addBlessEffect(num)
	local effectLabel = createLabel(self.leftBg, "+"..num, cc.p(self.progressLabel:getPosition()), cc.p(0.5, 0), 30, true, nil, nil, MColor.green)
	effectLabel:setScale(0.01)
	effectLabel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.5), cc.ScaleTo:create(0.2, 1), cc.MoveBy:create(0.5, cc.p(0, 60)), cc.CallFunc:create(function() removeFromParent(effectLabel) end)))
	effectLabel:runAction(cc.Sequence:create(cc.FadeOut:create(1)))

	-- local effectNeedLabel = createLabel(self.leftBg, "-"..self.needsLabel:getString().."x1   -"..self.needMoneyLabel:getString()..self.moneyNumLabel:getString(), cc.p(self.leftBg:getContentSize().width/2, 180), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.red)
	-- effectNeedLabel:setScale(0.01)
	-- effectNeedLabel:runAction(cc.Sequence:create( cc.ScaleTo:create(0.2, 1.5), cc.ScaleTo:create(0.2, 1), cc.MoveBy:create(1, cc.p(0, 60))))
	-- effectNeedLabel:runAction(cc.Sequence:create(cc.FadeOut:create(2)))
end

function WingAndRidingAdvanceNode:onAdvanceSuccess()
	G_WR_ADVANCE_INFO = {}

	local parent = self.parent

	local detailNode = require("src/layers/wingAndRiding/WingAndRidingLeftNode").new(parent, wingAndRidingType.WR_TYPE_WING)
	parent.switchRightView(parent, detailNode, 30)

	local rightNode = require("src/layers/wingAndRiding/WingAndRidingRightNode").new(parent, wingAndRidingType.WR_TYPE_WING, true)
	parent.switchLeftView(parent, rightNode)

	--self:removeFromParent()
end

function WingAndRidingAdvanceNode:networkHander(buff,msgid)
	local switch = {

		[WING_SC_PROMOTE_RET] = function()
			log("WING_SC_PROMOTE_RET")
			local t = g_msgHandlerInst:convertBufferToTable("WingPromoteRetProtocol", buff) 
			local ret = t.ret
			local newBlessValue = t.promoteTime
			local oldBlessValue = self.blessValue

			self.blessValue = newBlessValue
			self:setData("bless", self.blessValue)
			log("WING_SC_PROMOTE_RET ret = "..tostring(ret))
			log("WING_SC_PROMOTE_RET bless = "..self.blessValue)
			if ret == true then
				if self:getCfgData("q_activeSkillPos") == 1 then
					local skillCount = self:getData("skillCount")
					self:setData("skillCount", skillCount + 1)
				end
				self:setData("id", self:getCfgData("q_ID"))
				
				self:onAdvanceSuccess()
			else
				self.selectLevel = self.nowLevel
				self:updateData()
				self:addBlessEffect(newBlessValue - oldBlessValue)
				if self.blessValue and self.maxBless then
					G_WR_ADVANCE_INFO.bless = self.blessValue
					G_WR_ADVANCE_INFO.rate = self.blessValue * 100 / self.maxBless
				end
			end
		end
		,

		[WING_SC_PROMOTE_CONDITION_FAIL] = function()
			log("WING_SC_PROMOTE_CONDITION_FAIL")
			--self:stopAutoAdvance()
		end
		,

		[WING_SC_GET_WING_PRICE_RET] = function()
			log("WING_SC_GET_WING_PRICE_RET")
			local t = g_msgHandlerInst:convertBufferToTable("WingGetWingPriceRetProtocol", buff) 
			local materialPrice = t.price
			local materialNumber = self:getCfgData("q_needMaterialNum", true)
			if materialPrice and materialNumber then
				self.autoCost = materialNumber * materialPrice
			end
		end
		,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return WingAndRidingAdvanceNode