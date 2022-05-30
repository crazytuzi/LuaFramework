local LeijiLoginItem = class("LeijiLoginItem", function()
	return CCTableViewCell:new()
end)

function LeijiLoginItem:getContentSize()
	local proxy = CCBProxy:create()
	local rootNode = {}
	local node = CCBuilderReaderLoad("nbhuodong/leijiLogin_item.ccbi", proxy, rootNode)
	local size = rootNode.itemBg:getContentSize()
	self:addChild(node)
	node:removeSelf()
	return size
end

function LeijiLoginItem:getDay()
	return self._day
end

function LeijiLoginItem:refreshItem(cellDatas)
	self._day = cellDatas.day
	local itemData = cellDatas.itemData
	local hasGet = false
	for i, v in ipairs(self._hasGetAry) do
		if cellDatas.day == v then
			hasGet = true
			break
		end
	end
	if hasGet then
		self._rootnode.rewardBtn:setVisible(false)
		self._rootnode.tag_has_get:setVisible(true)
	else
		self._rootnode.tag_has_get:setVisible(false)
		self._rootnode.rewardBtn:setVisible(true)
		if self._day <= self._hasLoginDays then
			self._rootnode.rewardBtn:setEnabled(true)
		else
			self._rootnode.rewardBtn:setEnabled(false)
		end
	end
	self._rootnode.title_lbl:setString(common:getLanguageString("@LoginDayNo") .. tostring(self._day) .. common:getLanguageString("@LoginReward"))
	if self._ListTable ~= nil then
		self._ListTable:removeFromParentAndCleanup(true)
	end
	local listView = self._rootnode.reward_list
	local listViewSize = listView:getContentSize()
	local function createFunc(index)
		local itemCell = require("game.nbactivity.MonthCard.MonthCardRewardItem").new()
		return itemCell:create({
		viewSize = listViewSize,
		itemData = itemData[index + 1]
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh({
		itemData = itemData[index + 1]
		})
	end
	local cellContentSize = require("game.nbactivity.MonthCard.MonthCardRewardItem").new():getContentSize()
	self._ListTable = require("utility.TableViewExt").new({
	size = listViewSize,
	direction = kCCScrollViewDirectionHorizontal,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #itemData,
	cellSize = cellContentSize,
	touchFunc = function(cell)
		if self._curInfoIndex ~= -1 then
			return
		end
		local idx = cell:getIdx() + 1
		self._curInfoIndex = idx
		local itemData = itemData[idx]
		local itemInfo = require("game.Huodong.ItemInformation").new({
		id = itemData.id,
		type = itemData.type,
		name = itemData.name,
		describe = itemData.describe,
		endFunc = function()
			self._curInfoIndex = -1
		end
		})
		game.runningScene:addChild(itemInfo, 100)
	end
	})
	self._ListTable:setPosition(0, 0)
	listView:addChild(self._ListTable)
end

function LeijiLoginItem:create(param)
	self._curInfoIndex = -1
	local viewSize = param.viewSize
	local rewardListener = param.rewardListener
	self._hasGetAry = param.hasGetAry or {}
	self._hasLoginDays = param.hasLoginDays or 0
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/leijiLogin_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width * 0.5, self._rootnode.itemBg:getContentSize().height * 0.5)
	self:addChild(node)
	
	--Áì½±
	self._rootnode.rewardBtn:addHandleOfControlEvent(function()
		if rewardListener ~= nil then
			self._rootnode.rewardBtn:setEnabled(false)
			rewardListener(self)
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	local cellDatas = param.cellDatas
	self:refreshItem(cellDatas)
	return self
end

function LeijiLoginItem:refresh(cellDatas)
	self:refreshItem(cellDatas)
end

function LeijiLoginItem:getReward(hasGetAry)
	self._hasGetAry = hasGetAry
	local rewardBtn = self._rootnode.rewardBtn
	rewardBtn:setVisible(false)
	self._rootnode.tag_has_get:setVisible(true)
end

return LeijiLoginItem