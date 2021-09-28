--[[
 --
 -- add by vicky
 -- 2014.11.13 
 --
 --]]


local WorldBossExtraRewardItem = class("WorldBossExtraRewardItem", function()
		return CCTableViewCell:new()
end) 


function WorldBossExtraRewardItem:getContentSize()
	local proxy = CCBProxy:create()
    local rootNode = {}

	local node = CCBuilderReaderLoad("huodong/worldBoss_extraReward_item.ccbi", proxy, rootNode)
	local size = rootNode["itemBg"]:getContentSize()

	self:addChild(node)
	node:removeSelf()

    return size
end 


function WorldBossExtraRewardItem:refreshItem(cellData)  
	local itemData = cellData.itemData 
	local rewardId = cellData.rewardId 
	local title = cellData.title 

	self._rootnode["title_lbl"]:setString(tostring(title)) 

	-- 背景 
	local titleBgName = "#wj_extra_titleBg_4.png" 
	local markName = "#wj_extra_mark_5.png" 
 	local bgName = "#sh_bg_4.png" 
 	local topBgName = "#sh_name_bg_4.png" 

 	if rewardId == 1 then 
 		-- 击杀者
 		titleBgName = "#wj_extra_titleBg_5.png" 
 		markName = "#wj_extra_mark_1.png" 
 		bgName = "#sh_bg_5.png" 
 		topBgName = "#sh_name_bg_6.png" 

 	elseif rewardId == 2 then 
 		-- 伤害第一名
 		titleBgName = "#wj_extra_titleBg_1.png" 
 		markName = "#wj_extra_mark_2.png" 
 		bgName = "#sh_bg_1.png" 
 		topBgName = "#sh_name_bg_1.png" 

 	elseif rewardId == 3 then 
 		-- 伤害第二名
 		titleBgName = "#wj_extra_titleBg_2.png" 
 		markName = "#wj_extra_mark_3.png" 
 		bgName = "#sh_bg_2.png" 
 		topBgName = "#sh_name_bg_2.png" 

 	elseif rewardId == 4 then 
 		-- 伤害第三名
 		titleBgName = "#wj_extra_titleBg_3.png" 
 		markName = "#wj_extra_mark_4.png" 
 		bgName = "#sh_bg_3.png" 
 		topBgName = "#sh_name_bg_3.png" 
 	end 

 	self._rootnode["title_bg_icon"]:setDisplayFrame(display.newSprite(titleBgName):getDisplayFrame())
 	self._rootnode["mark_icon"]:setDisplayFrame(display.newSprite(markName):getDisplayFrame())

 	self._rootnode["bg_node"]:removeAllChildren() 
 	local bg = display.newScale9Sprite(bgName, 0, 0, self._rootnode["bg_node"]:getContentSize()) 
 	bg:setAnchorPoint(0, 0) 
 	self._rootnode["bg_node"]:addChild(bg) 

 	self._rootnode["top_bg_node"]:removeAllChildren() 
 	local topBg = display.newScale9Sprite(topBgName, 0, 0, self._rootnode["top_bg_node"]:getContentSize()) 
 	topBg:setAnchorPoint(0, 0)
 	self._rootnode["top_bg_node"]:addChild(topBg) 
	
	if self._ListTable ~= nil then 
		self._ListTable:removeFromParentAndCleanup(true)
	end 

	local listView = self._rootnode["listView"] 
	local listViewSize = listView:getContentSize() 

	-- 创建
	local function createFunc(index) 
		local itemCell = require("game.Huodong.rewardCenter.RewardCenterCellItem").new()
		return itemCell:create({
			viewSize = listViewSize, 
			itemData = itemData[index + 1]
			}) 
	end 

	-- 刷新
	local function refreshFunc(cell, index)
		cell:refresh({
			itemData = itemData[index + 1]
			})
	end 

	local cellContentSize = require("game.Huodong.rewardCenter.RewardCenterCellItem").new():getContentSize()

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
	         game.runningScene:addChild(itemInfo, 1113) 
        end 
		})

	self._ListTable:setPosition(0, 0) 
	listView:addChild(self._ListTable) 
end 


function WorldBossExtraRewardItem:create(param) 
	-- dump(param) 
	self._curInfoIndex = -1 
	local cellData = param.cellData  
	local viewSize = param.viewSize 

	local proxy = CCBProxy:create()
	self._rootnode = {}

	local node = CCBuilderReaderLoad("huodong/worldBoss_extraReward_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width * 0.5, self._rootnode["itemBg"]:getContentSize().height * 0.5)
	self:addChild(node) 

	self:refreshItem(cellData)

	return self
end


function WorldBossExtraRewardItem:refresh(cellData)
	self:refreshItem(cellData) 
end 


return WorldBossExtraRewardItem 
