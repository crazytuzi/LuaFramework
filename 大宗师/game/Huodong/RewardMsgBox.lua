--[[
 --
 -- add by vicky
 -- 2014.08.09
 --
 --]]

local RewardMsgBox = class("RewardMsgBox", function ()
	return require("utility.ShadeLayer").new()
end)


function RewardMsgBox:initButton()

	local function closeFun(eventName, sender)
        self._rootnode["closeBtn"]:setEnabled(false)
        self._rootnode["confirmBtn"]:setEnabled(false)
        if self._confirmFunc ~= nil then
            self._confirmFunc()
        end
        PostNotice(NoticeKey.REMOVE_TUTOLAYER)
        self:removeFromParentAndCleanup(true)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end

	self._rootnode["closeBtn"]:addHandleOfControlEvent(closeFun, 
	 		CCControlEventTouchUpInside)

 	self._rootnode["confirmBtn"]:addHandleOfControlEvent(closeFun, 
	 		CCControlEventTouchUpInside)

 	TutoMgr.addBtn("lingqu_confirm",self._rootnode["confirmBtn"])
 	-- TutoMgr.addBtn("lingqu_close_btn",self._rootnode["closeBtn"])
 	TutoMgr.active()
end

function RewardMsgBox:initRewardListView(cellDatas)
	
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

    self.ListTable = require("utility.TableViewExt").new({
    	size        = CCSizeMake(boardWidth, boardHeight), 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum   	= #cellDatas, 
        cellSize    = cellContentSize
    	})

    self.ListTable:setPosition(0, self._rootnode["listView"]:getContentSize().height * 0.015)
    self._rootnode["listView"]:addChild(self.ListTable)

end

function RewardMsgBox:onExit()
	TutoMgr.removeBtn("lingqu_confirm")
	-- TutoMgr.removeBtn("lingqu_close_btn")
end


function RewardMsgBox:ctor(param)

	self:setNodeEventEnabled(true)
	self._confirmFunc = param.confirmFunc 

	local proxy = CCBProxy:create()
	self._rootnode = {}

	local node = CCBuilderReaderLoad("reward/reward_msg_box.ccbi", proxy, self._rootnode)
	local layer = tolua.cast(node, "CCLayer")
	layer:setPosition(display.width/2, display.height/2)
	self:addChild(layer)

	self._rootnode["title"]:setString(param.title or "恭喜您获得如下奖励") 

	local cellDatas = param.cellDatas

	self:initButton()
	self:initRewardListView(cellDatas)

	-- layer:setScale(0.2)
	-- layer:runAction(transition.sequence({
	-- 	CCScaleTo:create(0.2,1.2),
	-- 	CCScaleTo:create(0.1,1.1),
	-- 	CCScaleTo:create(0.1,0.9),
	-- 	CCScaleTo:create(0.2,1),
	-- 	}))

end

return RewardMsgBox