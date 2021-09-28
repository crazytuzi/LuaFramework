--[[
 --
 -- add by vicky
 -- 2014.10.06 
 --
 --]]

local RewardInfoMsgBox = class("RewardInfoMsgBox", function ()
	return require("utility.ShadeLayer").new()
end)

local ARENA_SHOP_TYPE = 1
local HUASHAN_SHOP_TYPE = 2

function RewardInfoMsgBox:initRewardListView(cellDatas)
	dump(cellDatas) 

	local boardWidth = self._rootnode["listView"]:getContentSize().width 
	local boardHeight = self._rootnode["listView"]:getContentSize().height * 0.97

    -- 创建
    local function createFunc(index)
    	local item = require("game.Huodong.rewardInfo.RewardInfoCell").new()
    	return item:create({
            viewSize = CCSizeMake(boardWidth, boardHeight), 
            itemData = cellDatas[index + 1], 
            num = self._num 
            })
    end

    -- 刷新
    local function refreshFunc(cell, index)
    	cell:refresh(cellDatas[index + 1])
    end

    local cellContentSize = require("game.Huodong.rewardInfo.RewardInfoCell").new():getContentSize()

    self.ListTable = require("utility.TableViewExt").new({
    	size        = CCSizeMake(boardWidth, boardHeight), 
    	direction   = kCCScrollViewDirectionVertical, 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum   	= #cellDatas, 
        cellSize    = cellContentSize
    	})

    self.ListTable:setPosition(0, self._rootnode["listView"]:getContentSize().height * 0.015)
    self._rootnode["listView"]:addChild(self.ListTable)

end


function RewardInfoMsgBox:ctor(param) 
	-- self:setNodeEventEnabled(true)
    self.shopType = param.shopType or ARENA_SHOP_TYPE
	local proxy = CCBProxy:create()
	self._rootnode = {}

	local node = CCBuilderReaderLoad("huodong/reward_information_msg_box.ccbi", proxy, self._rootnode)
	local layer = tolua.cast(node, "CCLayer")
	layer:setPosition(display.width/2, display.height/2)
	self:addChild(layer) 

    if self.shopType == HUASHAN_SHOP_TYPE then

    end

	local cellDatas = param.cellDatas
	self._num = param.num

	self._rootnode["closeBtn"]:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
			self:removeFromParentAndCleanup(true)
		end, CCControlEventTouchUpInside)

 	self._rootnode["confirmBtn"]:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
			self:removeFromParentAndCleanup(true)
		end, CCControlEventTouchUpInside)

	self:initRewardListView(cellDatas) 

end

return RewardInfoMsgBox

