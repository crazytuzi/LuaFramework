local WingAndRidingSkillNode = class("WingAndRidingSkillNode", function() return cc.Node:create() end )

local pathCommon = "res/wingAndRiding/common/"

local function checkRed(index)
	local record = getConfigItemByKeys("WingSkillDB", {"q_pos", "q_level"}, {index, 1})

	if record and record.q_itemID then
		local MPackStruct = require "src/layers/bag/PackStruct"
		local MPackManager = require "src/layers/bag/PackManager"
		local pack = MPackManager:getPack(MPackStruct.eBag)
		local num = pack:countByProtoId(record.q_itemID)

		if num > 0 then
			return num
		else
			return false
		end
	end
end

function WingAndRidingSkillNode:ctor(parent)
	local msgids = {WING_SC_LEARN_SKILL_RET}
	require("src/MsgHandler").new(self,msgids)

	self.parent = parent

	local bg = createSprite(self, "res/common/bg/bg18.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	self.bg = bg
	createLabel(bg, game.getStrByKey("wr_skill_title"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-30), cc.p(0.5, 0.5), 24, true)
	
	local contentBg = createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 15),
        cc.size(792,455),
        5
    )
	self.contentBg = contentBg

	local closeFunc = function() 
	   	self.bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0), cc.CallFunc:create(function() self:removeFromParent() end)))	
	end
	local closeBtn = createTouchItem(bg, "res/component/button/x2.png", cc.p(bg:getContentSize().width-48, bg:getContentSize().height-28), closeFunc)

	self:updateData()
	self:clearLongTouch()

	SwallowTouches(self)

	self:registerScriptHandler(function(event)
		if event == "enter" then
		elseif event == "exit" then
			if self.parent and self.parent.refresh then
				if self.reloadDataAction then
					self.parent:refresh()
				end
			end
		end
	end)
end

function WingAndRidingSkillNode:updateData()
	self:updateUI()
end

function WingAndRidingSkillNode:updateUI()
	self.contentBg:removeAllChildren()
	self.progressLabel = {}
	self.progressBg = {}
	self.progress = {}
	self.red = {}
	self.redLabel = {}
	self:clearLongTouch()

	--技能孔和阶数对应表
	local cfgTab = {}
	local skillActiveTab = {}
	
	cfgTab = getConfigItemByKey("WingCfg")

	dump(G_WING_INFO.id)
	for i,v in ipairs(cfgTab) do
		--log("000000000000000000000 id = "..v.q_ID)
		if math.floor(G_WING_INFO.id/1000) == math.floor(v.q_ID/1000) then
			--log("111111111111111111111111 id = "..v.q_ID)
			--dump(v)
			if v.q_activeSkillPos and v.q_activeSkillPos > 0 then
				--log("222222222222222222222222")
				skillActiveTab[v.q_activeSkillPos] = true
			end
		end

		if G_WING_INFO.id == v.q_ID then
			break
		end
	end
	dump(skillActiveTab)

	local function checkSkillFunc(index)
		local function check(index)
			local record = getConfigItemByKeys("WingSkillDB", {"q_pos", "q_level"}, {index, 1})

			if record and record.q_itemID then
				local MPackStruct = require "src/layers/bag/PackStruct"
				local MPackManager = require "src/layers/bag/PackManager"
				local pack = MPackManager:getPack(MPackStruct.eBag)
				local num = pack:countByProtoId(record.q_itemID)

				if num > 0 then
					return num, record.q_itemID
				else
					return false, record.q_itemID
				end
			end
		end

		local result, protoId = check(index)
		if protoId then
			local Mtips = require "src/layers/bag/tips"
			Mtips.new(
			{
				protoId = protoId
			})
		end
	end

	

	local x = self.contentBg:getContentSize().width/2
	local y = 8
	local paddingY = 2
	for i=4,1,-1 do
		local record = G_WING_INFO.skillTab[i]
		if record and record.skillLevel == 0 then
			record = nil
		end
		--dump(record)
		local skillCfgRecord 
		local nextSkillCfgRecord
		if record then
			skillCfgRecord = getConfigItemByKeys("WingSkillDB", {"q_pos", "q_level"}, {record.skillId, record.skillLevel})
			nextSkillCfgRecord = getConfigItemByKeys("WingSkillDB", {"q_pos", "q_level"}, {record.skillId, record.skillLevel+1})
			--dump(nextSkillCfgRecord)
		else
			skillCfgRecord = getConfigItemByKeys("WingSkillDB", {"q_pos", "q_level"}, {i, 1})
			nextSkillCfgRecord = getConfigItemByKeys("WingSkillDB", {"q_pos", "q_level"}, {i, 2})
		end

		local skillBg = createSprite(self.contentBg, "res/common/bg/bg18-11.png", cc.p(x, y), cc.p(0.5, 0))
		local skillIcoBg = createSprite(skillBg, "res/common/bg/itemBg.png", cc.p(55, skillBg:getContentSize().height/2), cc.p(0.5, 0.5))
		local skillIconSpr = createTouchItem(skillIcoBg, pathCommon.."skill"..i..".png", getCenterPos(skillIcoBg), function() checkSkillFunc(i) end)
		skillIconSpr:setScale(0.8)
		if record == nil and skillActiveTab[i] ~= true then
			skillIconSpr:addColorGray()
		end

		createLabel(skillBg, skillCfgRecord.q_name, cc.p(110, 60), cc.p(0, 0), 20, true, nil, nil, MColor.yellow)

		if record then
			createLabel(skillBg, record.skillLevel..game.getStrByKey("faction_player_level"), cc.p(200, 60), cc.p(0, 0), 20, true, nil, nil, MColor.lable_black)
		else
			createLabel(skillBg, game.getStrByKey("wr_not_learn_skill"), cc.p(200, 60), cc.p(0, 0), 20, true, nil, nil, MColor.lable_black)
		end

		local nowRichText
		if skillCfgRecord.q_desc then
			nowRichText = require("src/RichText").new(skillBg, cc.p(270, 80), cc.size(370, 30), cc.p(0, 1), 20, 20, MColor.lable_black)
			if record == nil then
				nowRichText:addText(skillCfgRecord.q_desc0)
			else
				nowRichText:addText(skillCfgRecord.q_desc)
			end
			nowRichText:format()
		end

		local nextLevelLabel
		local nextRichText
		if nextSkillCfgRecord then
			nextLevelLabel = createLabel(skillBg, game.getStrByKey("lv_next_lv").."：", cc.p(110, 15), cc.p(0, 0), 20, true, nil, nil, MColor.lable_yellow)
			nextRichText = require("src/RichText").new(skillBg, cc.p(190, 15), cc.size(370, 30), cc.p(0, 0), 20, 20, MColor.lable_black)
			nextRichText:addText(skillCfgRecord.q_nextDesc)
			nextRichText:format()
		else
			createLabel(skillBg, game.getStrByKey("fullLevel"), cc.p(110, 15), cc.p(0, 0), 20, true, nil, nil, MColor.lable_yellow)
		end

		local progressBg = createSprite(skillBg, "res/component/progress/3.png", cc.p(360, 15), cc.p(0, 0))
		self.progressBg[i] = progressBg
		local progress = cc.ProgressTimer:create(cc.Sprite:create("res/component/progress/3-1.png"))  
		progressBg:addChild(progress)
	    progress:setPosition(getCenterPos(progressBg))
	    progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	    progress:setAnchorPoint(cc.p(0.5, 0.5))
	    progress:setBarChangeRate(cc.p(1, 0))
	    progress:setMidpoint(cc.p(0, 1))
	    progress:setPercentage(0)
	    self.progress[i] = progress

	    if not nextSkillCfgRecord then
	    	progressBg:setVisible(false)
	    end

	    local progressLabel
	    --进度
	    if record and record.skillProgress then
			progressLabel = createLabel(progressBg, record.skillProgress.."/"..skillCfgRecord.q_maxStrength, getCenterPos(progressBg), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.white)
			progress:setPercentage(record.skillProgress*100 / skillCfgRecord.q_maxStrength)
		else
			progressLabel = createLabel(progressBg, "0".."/"..skillCfgRecord.q_maxStrength, getCenterPos(progressBg), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.white)
		end
		self.progressLabel[i] = progressLabel

		local function advanceFunc()
			if self.longTouched then
				self:clearLongTouch()
			else
				--g_msgHandlerInst:sendNetDataByFmtExEx(WING_CS_LEARN_SKILL, "ii", G_ROLE_MAIN.obj_id, i)
				local t = {}
				t.pos = i
				g_msgHandlerInst:sendNetDataByTableExEx(WING_CS_LEARN_SKILL, "WingLearnSkillProtocol", t)
	    		addNetLoading(WING_CS_LEARN_SKILL, WING_SC_LEARN_SKILL_RET)
    		end
		end

		local function longTouchFunc(passTime)
			log("longTouchFunc!!!!!!!!! passTime = "..passTime)

			self:updateLongTouch(i, passTime)
		end

		local itemNum = checkRed(i)

		local advanceBtn = createMenuItem(skillBg, "res/component/button/48.png", cc.p(710, skillBg:getContentSize().height/2), advanceFunc)
		advanceBtn:setLongTouchCallBack(longTouchFunc)
		local advanceLabel = createLabel(advanceBtn, game.getStrByKey("wr_advance_start"), getCenterPos(advanceBtn), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.lable_yellow)
		if record == nil and skillActiveTab[i] ~= true then
			--advanceBtn:addColorGray()
			advanceBtn:setEnabled(false)
		end

		if itemNum == false or (not nextSkillCfgRecord) then
			--advanceBtn:addColorGray()
			advanceBtn:setEnabled(false)
		else
			local redTag = createSprite(advanceBtn, "res/component/flag/red.png", cc.p(advanceBtn:getContentSize().width, advanceBtn:getContentSize().height), cc.p(0.5, 0.5))
			self.red[i] = redTag
			self.redLabel[i] = createLabel(redTag, itemNum, getCenterPos(redTag, 0, 3), cc.p(0.5, 0.5), 16, nil, nil, nil, MColor.white)		
		end

		if record == nil then
			advanceLabel:setString(game.getStrByKey("learn"))
		end

		local function setNodeUnvisible(node)
			if node and tolua.cast(node, "cc.Node") then
				node:setVisible(false)
			end
		end
		--技能为学习隐藏部分内容
		if record == nil then
			setNodeUnvisible(nextLevelLabel)
			setNodeUnvisible(nextRichText)
			setNodeUnvisible(progressBg)
			setNodeUnvisible(progressLabel)
		end

		y = y + skillBg:getContentSize().height + paddingY
	end
end

function WingAndRidingSkillNode:clearLongTouch()
	self.timeStart = nil
	self.time = nil
	self.longTouched = false
	self.validTime = 0.7
	self.validTimeMin = 0.2
	self.validTimeAdd = -0.1
end

function WingAndRidingSkillNode:updateLongTouch(skillId, passTime)
	local function advanceFunc()
		--log("1111111111111111111111")
		--g_msgHandlerInst:sendNetDataByFmtExEx(WING_CS_LEARN_SKILL, "ii", G_ROLE_MAIN.obj_id, skillId)
		local t = {}
		t.pos = skillId
		g_msgHandlerInst:sendNetDataByTableExEx(WING_CS_LEARN_SKILL, "WingLearnSkillProtocol", t)
		--addNetLoading(WING_CS_LEARN_SKILL, WING_SC_LEARN_SKILL_RET)
		--self:addBlessEffect(skillId, 1)
	end

	if self.time == nil then
		self.timeStart = 0
		self.time = 0
		--advanceFunc()
	end
	self.longTouched = true

	self.time = self.time + passTime
	if (self.time - self.timeStart) > self.validTime then
		self.timeStart = 0
		self.time = 0
		self.validTime = self.validTime + self.validTimeAdd
		if self.validTime <= self.validTimeMin then
			self.validTime = self.validTimeMin
		end
		log("self.validTime = "..self.validTime)
		advanceFunc()
	end
end

function WingAndRidingSkillNode:updateProgress(skillId, skillLevel, skillProgress)
	local skillCfgRecord = getConfigItemByKeys("WingSkillDB", {"q_pos", "q_level"}, {skillId, skillLevel})
	if skillCfgRecord then
		if self.progress[skillId] then
			self.progress[skillId]:setPercentage(skillProgress*100 / skillCfgRecord.q_maxStrength)
		end

		if self.progressLabel[skillId] then
			self.progressLabel[skillId]:setString(skillProgress.."/"..skillCfgRecord.q_maxStrength)
		end
	end

	if self.redLabel[skillId] then
		local itemNum = checkRed(skillId)
		if itemNum then
			self.redLabel[skillId]:setString(itemNum)
		else
			if self.red[skillId] then
				removeFromParent(self.red[skillId])
				self.red[skillId] = nil
			end
		end
	end
end

function WingAndRidingSkillNode:addBlessEffect(pos, num)
	local progressBg = self.progressBg[pos]

	if progressBg then
		local effectLabel = createLabel(progressBg, "+"..num, cc.p(progressBg:getContentSize().width/2 + math.random(-70, 70), progressBg:getContentSize().height), cc.p(0.5, 0.5), 30, nil, nil, nil, MColor.green)
		effectLabel:setScale(0.01)
		effectLabel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.5), cc.ScaleTo:create(0.2, 1), cc.MoveBy:create(0.5, cc.p(0, 60)), cc.CallFunc:create(function() removeFromParent(effectLabel) end)))
		effectLabel:runAction(cc.Sequence:create(cc.FadeOut:create(1)))

		-- local effectNeedLabel = createLabel(self.bg, "-"..self.needsLabel:getString().."x1   -"..self.needMoneyLabel:getString()..self.moneyNumLabel:getString(), cc.p(self.bg:getContentSize().width/2, 180), cc.p(0.5, 0.5), 20, false, nil, nil, MColor.red)
		-- effectNeedLabel:setScale(0.01)
		-- effectNeedLabel:runAction(cc.Sequence:create(cc.CallFunc:create(function() self.effectNeedStringLabel:stopAllActions() self.effectNeedStringLabel:setVisible(false) end), cc.ScaleTo:create(0.2, 1.5), cc.ScaleTo:create(0.2, 1), cc.MoveBy:create(1, cc.p(0, 60)),
		-- cc.CallFunc:create(function() self.effectNeedStringLabel:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function() self.effectNeedStringLabel:setVisible(false) end))) removeFromParent(effectNeedLabel) end)))
		-- effectNeedLabel:runAction(cc.Sequence:create(cc.FadeOut:create(2)))
	end
end

function WingAndRidingSkillNode:networkHander(buffer,msgid)
	local switch = {
		[WING_SC_LEARN_SKILL_RET] = function()    
			log("WING_SC_LEARN_SKILL_RET")
			local t = g_msgHandlerInst:convertBufferToTable("WingLearnSkillRetProtocol", buffer)
			local skillId = t.pos
			local skillLevel = t.level
			local skillProgress = t.strength
			log("skillId = "..skillId)
			log("skillLevel = "..skillLevel)
			log("skillProgress = "..skillProgress)
			--dump(G_WING_INFO)
			local isLevelUp = (G_WING_INFO.skillTab[skillId] == nil) or (G_WING_INFO.skillTab[skillId].skillLevel < skillLevel)
			G_WING_INFO.skillTab[skillId] = {skillId=skillId, skillLevel=skillLevel, skillProgress=skillProgress}

			if isLevelUp then
				self:updateData()
			else
				self:updateProgress(skillId, skillLevel, skillProgress)
			end

			if not (skillLevel == 1 and skillProgress == 0) then
				self:addBlessEffect(skillId, 1)
			end

			-- if self.parent and self.parent.refresh then
			-- 	self.parent:refresh()
			-- end

			if self.parent and self.parent.refresh then
				if self.reloadDataAction then
					self:stopAction(self.reloadDataAction)
					self.reloadDataAction = nil
				end

				self.reloadDataAction = startTimerAction(self, 60, false, function() 
						self.parent:refresh() 
						self.reloadDataAction = nil
					end)
			end
		end
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return WingAndRidingSkillNode