--[[
 --
 -- add by vicky
 -- 2014.08.11
 --
 --]]


local RewardCenterCell = class("RewardCenterCell", function()
		return CCTableViewCell:new()
end) 


function RewardCenterCell:getContentSize()
	local proxy = CCBProxy:create()
    local rootNode = {}

    local node = CCBuilderReaderLoad("reward/reward_center_item.ccbi", proxy, rootNode)
	local size = rootNode["itemBg"]:getContentSize()
    self:addChild(node)
    node:removeSelf()
    return size
end


function RewardCenterCell:getObjId()
	return self.objId
end


function RewardCenterCell:getCellData()
	return self.cellData
end


function RewardCenterCell:refreshItem(param)
	-- dump(param)

	self.objId = param.objId
	self.num = param.num
	self._rootnode["reward_title"]:setString(param.title)
	self._rootnode["reward_msg"]:setString(param.describe)
	self._rootnode["reward_time"]:setString(param.time)

	if self.ListTable ~= nil then 
		self.ListTable:removeFromParentAndCleanup(true)
	end 

	self.cellData = param.cellData 
	dump(self.cellData)

	local listView = self._rootnode["reward_list"]
	local listViewSize = listView:getContentSize()

	local boardWidth = listViewSize.width
	local boardHeight = listViewSize.height 

	-- 创建
	local function createFunc(index) 
		local itemCell = require("game.Huodong.rewardCenter.RewardCenterCellItem").new()
		return itemCell:create({
			viewSize = CCSizeMake(boardWidth, boardHeight), 
			itemData = self.cellData[index + 1]
			})
	end

	-- 刷新
	local function refreshFunc(cell, index)
		cell:refresh({
			itemData = self.cellData[index + 1]
			})
	end 

	local cellContentSize = require("game.Huodong.rewardCenter.RewardCenterCellItem").new():getContentSize()

	self.ListTable = require("utility.TableViewExt").new({
		size = CCSizeMake(boardWidth, boardHeight), 
		direction = kCCScrollViewDirectionHorizontal, 
		createFunc = createFunc, 
		refreshFunc = refreshFunc, 
		cellNum = #self.cellData, 
		cellSize = cellContentSize
		})

	self.ListTable:setPosition(0, 0)
	listView:addChild(self.ListTable) 
end


function RewardCenterCell:setRewardEnabled(bEnable)
	self._rootnode["rewardBtn"]:setEnabled(bEnable) 
end


function RewardCenterCell:create(param)

	self.viewSize = param.viewSize
	local rewardListener = param.rewardListener

	local proxy = CCBProxy:create()
	self._rootnode = {}

	local node = CCBuilderReaderLoad("reward/reward_center_item.ccbi", proxy, self._rootnode)
	node:setPosition(self.viewSize.width * 0.5, self._rootnode["itemBg"]:getContentSize().height * 0.5)
	self:addChild(node)

	-- 领取按钮
	local rewardBtn = self._rootnode["rewardBtn"] 
	rewardBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
	        if rewardListener then
	        	self:setRewardEnabled(false) 
	            rewardListener(self)
	        end
		end, CCControlEventTouchUpInside)

	self:refreshItem({
		objId = param.objId, 
		title = param.title, 
		describe = param.describe, 
		time = param.time, 
		cellData = param.cellData
		})

	return self
end


function RewardCenterCell:refresh(param)
	self:refreshItem(param)
end


-- 改变领取按钮的状态
function RewardCenterCell:getReward()
	local rewardBtn = self._rootnode["rewardBtn"]
	-- rewardBtn:setEnabled(false)
	-- rewardBtn:setTitleForState(CCString:create("已领取"), CCControlStateDisabled)
	rewardBtn:setVisible(false)
	self._rootnode["tag_has_get"]:setVisible(true)
end


return RewardCenterCell
