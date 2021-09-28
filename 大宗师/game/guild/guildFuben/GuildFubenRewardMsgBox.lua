--[[
 --
 -- add by vicky
 -- 2015.03.09 
 --
 --]]

local GuildFubenRewardMsgBox = class("GuildFubenRewardMsgBox", function ()
	return require("utility.ShadeLayer").new()
end)


function GuildFubenRewardMsgBox:initRewardListView(cellDatas)
	dump(cellDatas) 
	local boardWidth = self._rootnode["listView"]:getContentSize().width 
	local boardHeight = self._rootnode["listView"]:getContentSize().height * 0.97

    -- 创建
    local function createFunc(index)
    	local item = require("game.Huodong.RewardItem").new()
    	return item:create({
    		id = index, 
    		itemData = cellDatas[index + 1],
            viewSize = CCSizeMake(boardWidth, boardHeight)
    		})
    end

    -- 刷新
    local function refreshFunc(cell, index)
    	cell:refresh({
            index = index, 
            itemData = cellDatas[index + 1]
            })
    end

    local cellContentSize = require("game.Huodong.RewardItem").new():getContentSize()

    self._rootnode["touchNode"]:setTouchEnabled(true)
    local posX = 0
    local posY = 0
    self._rootnode["touchNode"]:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
        posX = event.x
        posY = event.y
    end)

    local listTable = require("utility.TableViewExt").new({
    	size        = CCSizeMake(boardWidth, boardHeight), 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum   	= #cellDatas, 
        cellSize    = cellContentSize, 
        touchFunc = function(cell) 
            if self._hasShowInfo == false then 
                local icon = cell:getRewardIcon() 
                local pos = icon:convertToNodeSpace(ccp(posX, posY)) 
                if CCRectMake(0, 0, icon:getContentSize().width, icon:getContentSize().height):containsPoint(pos) then
                    self._hasShowInfo = true 
                    local idx = cell:getIdx() + 1 
                    local itemData = cellDatas[idx] 
                    local itemInfo = require("game.Huodong.ItemInformation").new({
                            id = itemData.id,
                            type = itemData.type,
                            name = itemData.name,
                            describe = itemData.describe, 
                            endFunc = function()
                                self._hasShowInfo = false 
                            end
                            })

                    game.runningScene:addChild(itemInfo, self:getZOrder() + 1)
                end 
            end 
        end 
    	})

    listTable:setPosition(0, self._rootnode["listView"]:getContentSize().height * 0.015)
    self._rootnode["listView"]:addChild(listTable) 
end


function GuildFubenRewardMsgBox:onExit()

end


function GuildFubenRewardMsgBox:setBtnEnabled(bEnabled)
    self._rootnode["rewardBtn"]:setEnabled(bEnabled)  
end 


function GuildFubenRewardMsgBox:ctor(param) 
	self:setNodeEventEnabled(true)
    self._hasShowInfo = false 

    dump(param) 

    local boxState = param.boxState 
    local cellDatas = param.cellDatas
	local rewardFunc = param.rewardFunc  
    local closeFunc = param.closeFunc 

	local proxy = CCBProxy:create()
	self._rootnode = {}

	local node = CCBuilderReaderLoad("guild/guild_fuben_reward_msgBox.ccbi", proxy, self._rootnode) 
    -- local node = CCBuilderReaderLoad("reward/reward_msg_box.ccbi", proxy, self._rootnode)
	node:setPosition(display.width/2, display.height/2)
	self:addChild(node)

	self._rootnode["title"]:setString(param.title or "通关奖励") 

    if boxState == FUBEN_REWARD_STATE.hasGet then 
        self:setHasRewarded() 
    else
        self._rootnode["tag_hasGet"]:setVisible(false) 
        if boxState == FUBEN_REWARD_STATE.notOpen then 
            self._rootnode["rewardBtn"]:setVisible(true)
            self._rootnode["rewardBtn"]:setEnabled(false)

        elseif boxState == FUBEN_REWARD_STATE.canGet then 
            self._rootnode["rewardBtn"]:setVisible(true)
        end
    end 

    self._rootnode["closeBtn"]:addHandleOfControlEvent(function(eventName,sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
            if closeFunc ~= nil then 
                closeFunc(self) 
            end 
            self:removeFromParentAndCleanup(true) 
        end, CCControlEventTouchUpInside)

    self._rootnode["rewardBtn"]:addHandleOfControlEvent(function(eventName,sender) 
            self:setBtnEnabled(false) 
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            if rewardFunc ~= nil then 
                rewardFunc(self) 
            end 
        end, CCControlEventTouchUpInside)

	self:initRewardListView(cellDatas)
end


function GuildFubenRewardMsgBox:setHasRewarded()
    self._rootnode["tag_hasGet"]:setVisible(true) 
    self._rootnode["rewardBtn"]:setVisible(false) 
end 


return GuildFubenRewardMsgBox 

