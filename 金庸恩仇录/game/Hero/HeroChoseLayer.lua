local data_carden_carden = require("data.data_carden_carden")

local HeroChoseLayer = class("HeroChoseLayer", function(param)
	return require("utility.ShadeLayer").new()
end)

function HeroChoseLayer:init()
	
end

function HeroChoseLayer:ctor(param)
	self.kongfuData = param.listData
	self.index = param.index
	self.choseTable = param.choseTable
	self.updateFunc = param.updateFunc
	self.setUpBottomVisible = param.setUpBottomVisible
	self.removeListener = param.removeListener
	self.curExpValue = 0
	self.choseAbleData = param.sellAbleData
	local topProxy = CCBProxy:create()
	self.topNode = {}
	local topNode = CCBuilderReaderLoad("skill/skill_select_top.ccbi", topProxy, self.topNode)
	topNode:setPosition(self.topNode.itemBg:getContentSize().width * 0.5, display.height)
	self.topNode.title:setEnabled(false)
	self.topNode.title:setTitleForState(common:getLanguageString("@SelectHero1"), CCControlStateDisabled)
	local topBtn = self.topNode.backBtn
	topBtn:addHandleOfControlEvent(function(sender, eventName)
		PostNotice(NoticeKey.MAINSCENE_SHOW_BOTTOM_LAYER)
		self.updateFunc()
		self.setUpBottomVisible()
		if self.removeListener ~= nil then
			self.removeListener()
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	
	local bottomProxy = CCBProxy:create()
	self.bottomNode = {}
	local bottomNode = CCBuilderReaderLoad("skill/skill_select_bottom.ccbi", bottomProxy, self.bottomNode)
	bottomNode:setPosition(self.bottomNode.itemBg:getContentSize().width * 0.5, 0)
	self.bottomNode.choseName:setString(common:getLanguageString("@SelectHero"))
	self.heroNum = self.bottomNode.selectedLabel
	self.heroNum:setString(0)
	self.expNum = self.bottomNode.expNumLabel
	self.expNum:setString(0)
	local confirmBtn = self.bottomNode.confirmBtn
	
	
	confirmBtn:addHandleOfControlEvent(function(eventName, sender)
		PostNotice(NoticeKey.MAINSCENE_SHOW_BOTTOM_LAYER)
		self.setUpBottomVisible()
		self.updateFunc()
		if self.removeListener ~= nil then
			self.removeListener()
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	self.behBg = display.newScale9Sprite("jpg_bg/list_bg.png", x, y, CCSizeMake(display.width, display.height - self.topNode.itemBg:getContentSize().height - self.bottomNode.itemBg:getContentSize().height))
	self.behBg:setPosition(display.width / 2, self.bottomNode.itemBg:getContentSize().height)
	self:addChild(self.behBg)
	self.bg = display.newScale9Sprite("jpg_bg/list_bg.png", x, y, CCSizeMake(display.width, display.height - self.topNode.itemBg:getContentSize().height - self.bottomNode.itemBg:getContentSize().height))
	self.bg:setPosition(display.width / 2, self.bottomNode.itemBg:getContentSize().height + self.bg:getContentSize().height / 2)
	self:addChild(self.bg)
	self:addChild(topNode)
	self:addChild(bottomNode)
	for i = 1, #self.choseTable do
		local resId = self.choseAbleData[self.choseTable[i]].resId
		self.curExpValue = self.curExpValue + ResMgr.getCardData(resId).exp
	end
	self.heroNum:setString(#self.choseTable)
	self.expNum:setString(self.curExpValue)
	local function choseFunc(param)
		local cellIndex = param.cellIndex
		if param.op == 1 then
			if #self.choseTable < 5 then
				self.choseTable[#self.choseTable + 1] = param.cellIndex
				local resId = self.choseAbleData[param.cellIndex].resId
				local data = self.choseAbleData[param.cellIndex]
				local cardExp = ResMgr.getCardData(resId).exp + data_carden_carden[data.level].sumexp[data.star] + data.curExp
				self.curExpValue = self.curExpValue + cardExp
				self.heroNum:setString(#self.choseTable)
				self.expNum:setString(self.curExpValue)
				return true
			else
				show_tip_label(common:getLanguageString("@EnhanceLevelMax"))
				return false
			end
		else
			if #self.choseTable > 0 then
				for i = 1, #self.choseTable do
					if self.choseTable[i] == param.cellIndex then
						table.remove(self.choseTable, i)
					end
				end
				local resId = self.choseAbleData[param.cellIndex].resId
				local data = self.choseAbleData[param.cellIndex]
				local cardExp = ResMgr.getCardData(resId).exp + data_carden_carden[data.level].sumexp[data.star] + data.curExp
				self.curExpValue = self.curExpValue - cardExp
			else
				dump(common:getLanguageString("@Condition1"))
			end
			self.heroNum:setString(#self.choseTable)
			self.expNum:setString(self.curExpValue)
		end
		dump("heheeh " .. #self.choseTable)
	end
	local function createFunc(idx)
		local item = require("game.Hero.HeroChoseCell").new()
		return item:create({
		id = idx + 1,
		viewSize = cc.size(self.bg:getContentSize().width, self.bg:getContentSize().height),
		list = self.choseAbleData,
		choseTable = self.choseTable,
		choseFunc = choseFunc
		})
	end
	local refreshFunc = function(cell, idx)
		cell:refresh(idx + 1)
	end
	self.kongFuList = require("utility.TableViewExt").new({
	size = cc.size(self.bg:getContentSize().width, self.bg:getContentSize().height),
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self.choseAbleData,
	cellSize = require("game.Hero.HeroChoseCell").new():getContentSize()
	})
	self.bg:addChild(self.kongFuList)
end

return HeroChoseLayer