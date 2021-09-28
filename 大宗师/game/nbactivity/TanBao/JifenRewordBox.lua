--
-- Author: Daneil
-- Date: 2015-03-06 14:24:24
--

local JifenRewordBox = class("JifenRewordBox", function ()
	return require("utility.ShadeLayer").new()
end)


function JifenRewordBox:initButton()

	local function closeFun(eventName, sender)
        self:removeFromParentAndCleanup(true)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
	end

	local function confirmFun(eventName, sender)
        if self._confirmFunc ~= nil then
            self._confirmFunc()
        end
        self:removeFromParentAndCleanup(true)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end

	self._rootnode["closeBtn"]:addHandleOfControlEvent(closeFun,CCControlEventTouchUpInside)
	self._rootnode["okBtn"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, confirmFun)

	if self._jifen < self._num then
		self._rootnode["okBtn"]:setTouchEnabled(false)
		self._rootnode["okBtn"]:setEnabled(false)
	end

	if self._state == 0 then
		self._rootnode["okBtn"]:setVisible(false)
		local iconComplete = display.newSprite("#getok.png")
		iconComplete:setPosition(cc.p(display.width/2,display.height/2 - 120))
		self:addChild(iconComplete,10)
	end
end

function JifenRewordBox:initRewardListView(cellDatas)
	
	local boardWidth = self._rootnode["listView"]:getContentSize().width 
	local boardHeight = self._rootnode["listView"]:getContentSize().height * 0.97

    -- 创建
    local function createFunc(index)
    	local item = require("game.nbactivity.TanBao.JifenRewordItem").new()
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

    local cellContentSize = require("game.nbactivity.TanBao.JifenRewordItem").new():getContentSize()

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

function JifenRewordBox:onExit()
	TutoMgr.removeBtn("lingqu_confirm")
	-- TutoMgr.removeBtn("lingqu_close_btn")
end


function JifenRewordBox:ctor(param)

	self:setNodeEventEnabled(true)
	self._confirmFunc = param.confirmFunc 
	self._jifen = param.jifen
	self._num = param.num
	self._state = param.state
	local proxy = CCBProxy:create()
	self._rootnode = {}

	local node = CCBuilderReaderLoad("huodong/huodong_jifenjiangli.ccbi", proxy, self._rootnode)
	local layer = tolua.cast(node, "CCLayer")
	layer:setPosition(display.width/2, display.height/2)
	self:addChild(layer)

	self._rootnode["scoreLabel"]:setString(param.num or 0) 



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

return JifenRewordBox