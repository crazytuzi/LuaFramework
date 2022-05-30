local BaseTab = class("BaseTab", function ()
	return display.newNode()
end)
local BASE_HORIZON = 0
local BASE_VERTICAL = 1
function BaseTab:ctor(param)
	local tabImages = param.tabs
	local tabUnSelImage = param.unSelImage
	local touchTab = param.tabListener
	local direction = param.direction or BASE_HORIZON
	local spaceInCells = param.spaceInCells or 0
	local red_num_bg_path = "ui/new_btn/red_num_bg.png"
	local checkFunc = param.checkFunc
	local curX = 0
	local curY = 0
	local tabs = {}
	self.numTable = {}
	self.numBgTable = {}
	self.currentIndex = 0
	local function touchTabByIndex(index, tabCells)
		if checkFunc ~= nil and checkFunc() ~= true then
			return
		end
		for tabsId = 1, #tabCells do
			if index ~= tabsId then
				if tabUnSelImage == nil or tabUnSelImage[tabsId] == nil then
					tabCells[tabsId]:setScale(0.9)
					tabCells[tabsId]:setColor(ccc3(100, 100, 100))
				else
					display.addSpriteFramesWithFile("ui/ui_friend.plist", "ui/ui_friend.png")
					local ne = display.newSpriteFrame(tabUnSelImage[tabsId])
					tabCells[tabsId]:setDisplayFrame(ne)
				end
			else
				if tabUnSelImage == nil or tabUnSelImage[tabsId] == nil then
					tabCells[tabsId]:setScale(1)
					tabCells[tabsId]:setColor(ccc3(255, 255, 255))
				else
					display.addSpriteFramesWithFile("ui/ui_friend.plist", "ui/ui_friend.png")
					local ne = display.newSpriteFrame(tabImages[tabsId])
					tabCells[tabsId]:setDisplayFrame(ne)
				end
				touchTab(tabsId)
				self.currentIndex = tabsId
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
			end
		end
	end
	for index = 1, #tabImages do
		do
			local selImage
			if tabUnSelImage ~= nil then
				selImage = tabUnSelImage[index]
			end
			local tabBtn = display.newSprite("#" .. tabImages[index])
			local redbg = display.newSprite(red_num_bg_path)
			redbg:setPosition(tabBtn:getContentSize().width * 0.8, tabBtn:getContentSize().height)
			redbg:setVisible(false)
			local numLabel = ui.newTTFLabel({
			text = "1",
			font = FONTS_NAME.font_fzcy,
			size = 18
			})
			numLabel:setPosition(redbg:getContentSize().width / 2, redbg:getContentSize().height / 2)
			self.numTable[index] = numLabel
			self.numBgTable[index] = redbg
			redbg:addChild(numLabel)
			tabBtn:addChild(redbg)
			local function touSprite(event)
				if event.name == "began" and self.currentIndex ~= index then
					touchTabByIndex(index, tabs)
				end
			end
			tabBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, touSprite)
			tabBtn:setTouchEnabled(true)
			if direction == BASE_HORIZON then
				tabBtn:setAnchorPoint(ccp(0, 0))
				tabBtn:setPosition(curX, curY)
				curX = curX + tabBtn:getContentSize().width + spaceInCells
				self:addChild(tabBtn)
				tabs[#tabs + 1] = tabBtn
			else
				tabBtn:setAnchorPoint(ccp(0, 1))
				tabBtn:setPosition(curX, curY)
				curY = curY - tabBtn:getContentSize().height - spaceInCells
				self:addChild(tabBtn)
				tabs[#tabs + 1] = tabBtn
			end
		end
	end
	self.tabs = tabs
	touchTabByIndex(1, tabs)
end
function BaseTab:setNum(index, num)
	if num > 0 then
		self.numBgTable[index]:setVisible(true)
	else
		self.numBgTable[index]:setVisible(false)
	end
	self.numTable[index]:setString(num)
end
function BaseTab:setTouchState(value)
	for i = 1, #self.tabs do
		if i ~= self.currentIndex then
			self.tabs[i]:setTouchEnabled(value)
		end
	end
end

-- function BaseTab:getContentSize()
--     return CCSize(self.contentWidth, self.contentHeight)
-- end
return BaseTab