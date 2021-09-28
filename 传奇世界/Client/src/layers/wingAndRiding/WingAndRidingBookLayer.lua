local WingAndRidingBookLayer = class("WingAndRidingBookLayer", require("src/TabViewLayer"))

local MPropOp = require "src/config/propOp"

function WingAndRidingBookLayer:ctor(job, isWithSkill)
	self:init(job, isWithSkill)

	local function onBagChange()
		-- self:init(self.job)
		-- self:updateData()
		if not self.goto_next then
			local layer = require("src/layers/wingAndRiding/WingAndRidingBookLayer").new(job)
			Manimation:transit(
			{
				ref = G_MAINSCENE.base_node,
				node = layer,
				curve = "-",
				sp = cc.p(display.cx, 0),
				zOrder = 200,
				--swallow = true,
			})
			self:removeFromParent()
		end
	end
	self:registerScriptHandler(function(event)
		local pack = MPackManager:getPack(MPackStruct.eBag)
		if event == "enter" then
			pack:register(onBagChange)
		elseif event == "exit" then
			pack:unregister(onBagChange)
		end
	end)
end

function WingAndRidingBookLayer:init(job, isWithSkill)
	self:removeAllChildren()

	local num = self:initData(job)
	self.isWithSkill = isWithSkill

	if num > 0 then
		local bg = createSprite(self, "res/common/bg/bg36.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
		--createScale9Sprite(bg, "res/common/68.png", cc.p(bg:getContentSize().width/2, 20), cc.size(420, 250), cc.p(0.5, 0))
		self:createTableView(bg, cc.size(360, 208), cc.p(29, 35), true)
		registerOutsideCloseFunc(bg, function() removeFromParent(self) end, true)
	else
		self.goto_next = true
		local text_str = game.getStrByKey("wr_skill_no_book_tip")
		if self.isWithSkill then
			text_str = game.getStrByKey("wr_skill_no_book_tip_1")
		end
		local function lotteryFunc()
			__GotoTarget({ ru = "a11"})
		end
		local function fbFunc()
			__GotoTarget({ ru = "a40"})
		end
		MessageBoxYesNoEx(nil,text_str,fbFunc ,lotteryFunc,game.getStrByKey("wr_skill_book_way_fb"), game.getStrByKey("wr_skill_book_way_lottery"),true)
	end
end

function WingAndRidingBookLayer:initData(job)
	self.job = job
	self.data = {}
	self.rowSprite = {}
	self.school = require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)
	self.lv = require("src/layers/role/RoleStruct"):getAttr(ROLE_LEVEL)
	self.girdTab = self:getGirdData(job)
	log("job = "..job)
	dump(self.girdTab)

	
	local low = 1
	local index = 1
	local indexMax = 4
	self.indexMax = indexMax
	for i,v in ipairs(self.girdTab) do
		if self.data[low] == nil then
			self.data[low] = {}
		end

		self.data[low][index] = v

		index = index + 1
		if index > indexMax then
			index = 1
			low = low + 1
		end
	end

	dump(self.data)
	return #self.girdTab
end

-- function WingAndRidingBookLayer:onBagChange()

-- end

function WingAndRidingBookLayer:getGirdData(job)
	local bag = MPackManager:getPack(MPackStruct.eBag)
	return bag:filtrate(function(grid)
		local protoId = MPackStruct.protoIdFromGird(grid)
		local category = MPropOp.category(protoId)
		local levelLimits = MPropOp.levelLimits(protoId)
		local schoolLimits = MPropOp.schoolLimits(protoId)
		
		if self.lv < levelLimits then
			return false
		end

		if self.school ~= schoolLimits and schoolLimits ~= 0 then
			return false
		end

		local skillTab = getConfigItemByKey("SkillCfg")
		if category == 6 then
			--dump(grid)
			for k,v in pairs(skillTab) do
				if v.learnBook and v.learnBook == protoId and v.job and v.job == job then
					return true
				end
			end
		end
		
		return false
	end, MPackStruct.eOther)
end

function WingAndRidingBookLayer:updateData()
	self:updateUI()
end

function WingAndRidingBookLayer:updateUI()
	self:getTableView():reloadData()
end

function WingAndRidingBookLayer:tableCellTouched(table, cell)
	local idx = cell:getIdx()
	--print("x = "..cell:getX()..", y = "..cell:getY())
	local touchX, touchY = cell:getX(), cell:getY()
	if self.rowSprite[idx] then
		for i,v in ipairs(self.rowSprite[idx]) do
			if cc.rectContainsPoint(v:getBoundingBox(), cc.p(touchX, touchY)) then
				AudioEnginer.playTouchPointEffect()
				local Mtips = require "src/layers/bag/tips"
				Mtips.new(
				{
					--protoId = MPackStruct.protoIdFromGird(self.data[idx+1][i]),
					grid = self.data[idx+1][i],
					pos = v:getParent():convertToWorldSpace(cc.p(v:getPosition())),
					contrast = true,
					actions = {"use"},
				})
				break
			end
		end
	end
end

function WingAndRidingBookLayer:cellSizeForTable(table, idx) 
    return 90, 360
end

function WingAndRidingBookLayer:tableCellAtIndex(table, idx)
	local record = self.data[idx+1]
	local startX = 360 / (self.indexMax) / 2
	local addX = 360 / (self.indexMax)
	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new() 
		self.rowSprite[idx] = {}
		for i,v in ipairs(record) do
			local iconNode = createPropIcon(cell, MPackStruct.protoIdFromGird(v), false, false, nil)
			iconNode:setPosition(cc.p(startX+(i-1)*addX ,50))
			iconNode:setScale(0.8)

			self.rowSprite[idx][i] = iconNode
		end
    else
    	cell:removeAllChildren()
    	self.rowSprite[idx] = {}
    	for i,v in ipairs(record) do
			local iconNode = createPropIcon(cell, MPackStruct.protoIdFromGird(v), false, false, nil)
			iconNode:setPosition(cc.p(startX+(i-1)*addX ,50))
			iconNode:setScale(0.8)

			self.rowSprite[idx][i] = iconNode
		end
    end

    return cell
end

function WingAndRidingBookLayer:numberOfCellsInTableView(table)
   	return #self.data
end

function WingAndRidingBookLayer:networkHander(buff,msgid)
	

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return WingAndRidingBookLayer