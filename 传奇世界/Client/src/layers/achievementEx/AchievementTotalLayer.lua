local AchievementTotalLayer = class("AchievementTotalLayer", require("src/TabViewLayer"))

local path = "res/achievement/"
local pathCommon = "res/common/"


function AchievementTotalLayer:ctor()
	self.data = {}
	self.school = require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)

	local topBg = createSprite(self, path.."2.png", cc.p(-2, 290), cc.p(0, 0))
	--createSprite(topBg, path.."3.png", cc.p(topBg:getContentSize().width/2, 50), cc.p(0.5, 0))

	local logoBg = createSprite(topBg, path.."get/9.png", cc.p(105, topBg:getContentSize().height/2+10), cc.p(0.5, 0.5))
	createSprite(logoBg, path.."get/8.png", getCenterPos(logoBg), cc.p(0.5, 0.5))
	local levelBg = createSprite(logoBg, "res/common/bg/score_needed_bg2.png", cc.p(logoBg:getContentSize().width/2, 5), cc.p(0.5, 0.5))
	self.levelLabel = createLabel(levelBg, "", getCenterPos(levelBg), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.lable_yellow)
	
	local progressBg = createSprite(topBg, "res/component/progress/6.png", cc.p(195, 35), cc.p(0, 0))
	self.progress = cc.ProgressTimer:create(cc.Sprite:create("res/component/progress/6-1.png"))  
	progressBg:addChild(self.progress)
    self.progress:setPosition(getCenterPos(progressBg))
    self.progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.progress:setAnchorPoint(cc.p(0.5, 0.5))
    self.progress:setBarChangeRate(cc.p(1, 0))
    self.progress:setMidpoint(cc.p(0, 1))
    self.progress:setPercentage(0)
    --进度
	self.progressLabel = createLabel(progressBg, "0/0", getCenterPos(progressBg), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.white)

	self:createTableView(self, cc.size(710, 290), cc.p(0, 0), true, false)

	self.attNode = cc.Node:create()
	topBg:addChild(self.attNode)
	self.attNode:setPosition(cc.p(0, 0))

	createLabel(topBg, game.getStrByKey("achievement_achieve_att"), cc.p(200, 145), cc.p(0, 0), 20, true, nil, nil, MColor.black)
end

function AchievementTotalLayer:setData(data)
	--dump(data)
	self.data = copyTable(data)
	table.remove(self.data, 1)
	self:updateData()
end

function AchievementTotalLayer:updateData()
	self:updateUI()
end

function AchievementTotalLayer:updateUI()
	-- local function getProgress(record)
	-- 	local count = 0
	-- 	local finishCount = 0
	-- 	for i,v in ipairs(self.data) do
	-- 		for i,v in ipairs(v.subData) do
	-- 			for i,v in ipairs(v.groupData) do
	-- 				for i,v in ipairs(v.recordData) do
	-- 					count = count + v.q_activity
	-- 					if v.finishTime then
	-- 						log("finish 1111111111111111111111111111")
	-- 						finishCount = finishCount + v.q_activity
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end

	-- 	return count, finishCount
	-- end

	-- local count, finishCount = getProgress()
	-- if count and finishCount then
	-- 	self.progressLabel:setString(finishCount.."/"..count)
	-- 	self.progress:setPercentage(finishCount * 100 / count)
	-- end

	if self.data.achieveLevel and self.data.achieveActivety then
		local record = getConfigItemByKeys("AchieveAttrDB", {"q_achieveLevel", "q_school"}, {self.data.achieveLevel, self.school})
		if record and record.q_achievePoint then
			self.progressLabel:setString(self.data.achieveActivety.."/"..record.q_achievePoint)
			self.progress:setPercentage(self.data.achieveActivety * 100 / record.q_achievePoint)
		end
	end

	if self.data.attTab then
		self.attNode:removeAllChildren()
		self:createAttNode(self.data.attTab, self.attNode, 20, MColor.black)
	end

	if self.data.achieveLevel and self.levelLabel then
		self.levelLabel:setString("Lv."..self.data.achieveLevel)
	end

	self:getTableView():reloadData()
end

function AchievementTotalLayer:createAttNode(record, parent, fontSize, fontColor)
	if record == nil then
		return nil
	end

	local attNodes = {}

	local formatStr2 = function(str1, str2)
		return str1.." ".."^c(white)"..str2.."^"
	end

	local formatStr3 = function(str1, str2, str3)
		return str1.." ".."^c(white)"..str2.."-"..str3.."^"
	end

	if record.q_max_hp then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_hp"), record.q_max_hp)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_max_mp then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_mp"), record.q_max_mp)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_attack_min and record.q_attack_max then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr3(game.getStrByKey("prop_attack"), record.q_attack_min, record.q_attack_max)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_magic_attack_min and record.q_magic_attack_max then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr3(game.getStrByKey("prop_magicAttack"), record.q_magic_attack_min, record.q_magic_attack_max)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_sc_attack_min and record.q_sc_attack_max then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr3(game.getStrByKey("prop_scAttack"), record.q_sc_attack_min, record.q_sc_attack_max)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_defence_min and record.q_defence_max then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr3(game.getStrByKey("prop_defence"), record.q_defence_min, record.q_defence_max)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_magic_defence_min and record.q_magic_defence_max then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr3(game.getStrByKey("prop_magicDefence"), record.q_magic_defence_min, record.q_magic_defence_max)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_att_dodge then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_attackDodge"), record.q_att_dodge)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_mac_dodge then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_magicDodge"), record.q_mac_dodge)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_crit then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_cirt"), record.q_crit)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_hit then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_hit"), record.q_hit)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_dodge then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_dodge"), record.q_dodge)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_attack_speed then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_attackSpeed"), record.q_attack_speed)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_luck then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_luck"), record.q_luck)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_addSpeed then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_speed"), record.q_addSpeed)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_subAt then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_subAt"), record.q_subAt)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_subMt then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_subMt"), record.q_subMt)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_subDt then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_subDt"), record.q_subDt)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_addAt then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_addAt"), record.q_addAt)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_addMt then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_addMt"), record.q_addMt)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_addDt then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_addDt"), record.q_addDt)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	-- local reverseTab = function(tab)
	-- 	local retTab = {}

	-- 	for i=#tab,1,-1 do
	-- 		retTab[#tab-i+1] = tab[i]
	-- 	end

	-- 	return retTab
	-- end

	-- attNodes = reverseTab(attNodes)

	-- local attBg = createSprite(nil, pathCommon.."bg/infoBg17.png", cc.p(0, 0), cc.p(0.5, 0), nil, 1)
	-- local posTab = {cc.p(attBg:getContentSize().width/2-140, 160), 
	-- cc.p(attBg:getContentSize().width/2+20, 160), 
	-- cc.p(attBg:getContentSize().width/2-140, 130), 
	-- cc.p(attBg:getContentSize().width/2+20, 130)}
	-- local x = 390
	-- local y = 230
	-- local addY = -30

	-- -- if #attNodes == 1 then
	-- -- 	posTab = {cc.p(attBg:getContentSize().width/2-50, 145)}
	-- -- end
	-- createLabel(parent, game.getStrByKey("achievement_tip_reward_att"), cc.p(420, 260), cc.p(0, 0), 20, false, nil, nil, MColor.lable_yellow)
	-- createSprite(parent, "res/common/bg/line11.png", cc.p(parent:getContentSize().width/2, 260-3))

	-- for i,v in ipairs(attNodes) do
	-- 	parent:addChild(v)
	-- 	v:setPosition(cc.p(x, y))
		
	-- 	y = y + addY
	-- end

	-- local x = 390
	-- local y = 230
	-- local addY = -30
	-- for i=1,4 do
	-- 	createSprite(parent, "res/common/bg/line11.png", cc.p(parent:getContentSize().width/2, y-3))
	-- 	y = y + addY
	-- end

	local posTab = {cc.p(200, 110), 
	cc.p(410, 110), 
	cc.p(200, 75), 
	cc.p(410, 75)}

	for i,v in ipairs(attNodes) do
		parent:addChild(v)
		if posTab[i] then
			v:setPosition(posTab[i])
		end
	end

	return attBg
end

function AchievementTotalLayer:tableCellTouched(table, cell)
	
end

function AchievementTotalLayer:cellSizeForTable(table, idx) 
    return 73, 710
end

function AchievementTotalLayer:tableCellAtIndex(table, idx)
	local recordLeft = self.data[idx*2+1]
	local recordRight = self.data[idx*2+2]
	-- dump(recordLeft)
	-- dump(recordRight)

	local cell = table:dequeueCell()

	local function getProgress(record)
		local count = 0
		local finishCount = 0
		for i,v in ipairs(self.data) do
			if v.mainType == record.mainType then
				for i,v in ipairs(v.subData) do
					for i,v in ipairs(v.groupData) do
						for i,v in ipairs(v.recordData) do
							count = count + v.q_activity
							if v.finishTime then
								log("finish 1111111111111111111111111111")
								finishCount = finishCount + v.q_activity
							end
						end
					end
				end
			end
		end

		return count, finishCount
	end

	local function createCellContent(cell)
		local function createCellPart(record, pos)
			local bg = createSprite(cell, pathCommon.."bg/bg71.png", pos, cc.p(0, 0))
			if record then
				if record.mainTypeDesc then
					createLabel(bg, record.mainTypeDesc, cc.p(80, bg:getContentSize().height/2), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.lable_yellow)
				end

				local progressBg = createSprite(bg, "res/component/progress/6.png", cc.p(130, bg:getContentSize().height/2), cc.p(0, 0.5))
				local progress = cc.ProgressTimer:create(cc.Sprite:create("res/component/progress/6-1.png"))  
				progressBg:addChild(progress)
			    progress:setPosition(getCenterPos(progressBg))
			    progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
			    progress:setAnchorPoint(cc.p(0.5, 0.5))
			    progress:setBarChangeRate(cc.p(1, 0))
			    progress:setMidpoint(cc.p(0, 1))
			    progress:setPercentage(0)
			    progressBg:setScale(0.45, 1)
			    --进度
				local progressLabel = createLabel(bg, "0/0", cc.p(235, bg:getContentSize().height/2), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.white)

				local count, finishCount = getProgress(record)
				if count and finishCount then
					progressLabel:setString(finishCount.."/"..count)
					progress:setPercentage(finishCount * 100 / count)
				end
			end
		end
		createCellPart(recordLeft, cc.p(0, 0))
		createCellPart(recordRight, cc.p(350, 0))
    end

    if nil == cell then
        cell = cc.TableViewCell:new()  
    else
    	cell:removeAllChildren()
    end
    createCellContent(cell)
    return cell
end

function AchievementTotalLayer:numberOfCellsInTableView(table)
	--dump(#self.data/2)
   	return math.ceil(#self.data/2)
end

return AchievementTotalLayer