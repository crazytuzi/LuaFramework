--
-- Author: Daneil
-- Date: 2015-03-06 14:24:24
--

local SuijiRewordBox = class("SuijiRewordBox", function ()
	return require("utility.ShadeLayer").new()
end)


function SuijiRewordBox:initButton()

	local function closeFun(eventName, sender)
        if self._confirmFunc ~= nil then
            self._confirmFunc()
        end
        self:removeFromParentAndCleanup(true)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
	end

	self._rootnode["closeBtn"]:addHandleOfControlEvent(closeFun,CCControlEventTouchUpInside)
	self._rootnode["okBtn"]:addHandleOfControlEvent(closeFun, CCControlEventTouchUpInside)
end

function SuijiRewordBox:initRewardListView(cellDatas)
	
	local boardWidth = self._rootnode["listView"]:getContentSize().width 
	local boardHeight = self._rootnode["listView"]:getContentSize().height * 0.97

    -- 创建
    local function createFunc(index)
    	local item = require("game.nbactivity.TanBao.SuijiRewordItem").new()
    	return item:create({
    		id = index, 
    		itemData = cellDatas[index + 1],
            viewSize = CCSizeMake(boardWidth, boardHeight * 0.48)
    		})
    end

    -- 刷新
    local function refreshFunc(cell, index)
    	cell:refresh({
            index = index, 
            itemData = cellDatas[index + 1]
            })
    end

    local cellContentSize = require("game.nbactivity.TanBao.SuijiRewordItem").new():getContentSize()

    self.ListTable = require("utility.TableViewExt").new({
    	size        = CCSizeMake(boardWidth, boardHeight), 
        createFunc  = createFunc, 
        refreshFunc = refreshFunc, 
        cellNum   	= #cellDatas, 
        cellSize    = cellContentSize,
        direction	= kCCScrollViewDirectionVertical
    	})

    self.ListTable:setPosition(0, self._rootnode["listView"]:getContentSize().height * 0.015)
    self._rootnode["listView"]:addChild(self.ListTable)

end

function SuijiRewordBox:onExit()
	TutoMgr.removeBtn("lingqu_confirm")
	-- TutoMgr.removeBtn("lingqu_close_btn")
end


function SuijiRewordBox:ctor(param)

	self:setNodeEventEnabled(true)
	self._confirmFunc = param.confirmFunc 

	local proxy = CCBProxy:create()
	self._rootnode = {}

	local node = CCBuilderReaderLoad("huodong/huodong_suijijiangli.ccbi", proxy, self._rootnode)
	local layer = tolua.cast(node, "CCLayer")
	layer:setPosition(display.width/2, display.height/2)
	self:addChild(layer)

	--self._rootnode["title"]:setString(param.title or "恭喜您获得如下奖励") 

	local cellDatas = param.cellDatas

	local data = {}
	local index = 0
	local dataTemp = {}
	for k,v in pairs(cellDatas) do
		table.insert(dataTemp,v)
		if k % 4 == 0 or k == #cellDatas then
			table.insert(data,dataTemp)
			dataTemp = {}
		end
		
	end


	self:initButton()
	self:initRewardListView(data)
	dump(data)

	-- layer:setScale(0.2)
	-- layer:runAction(transition.sequence({
	-- 	CCScaleTo:create(0.2,1.2),
	-- 	CCScaleTo:create(0.1,1.1),
	-- 	CCScaleTo:create(0.1,0.9),
	-- 	CCScaleTo:create(0.2,1),
	-- 	}))

end

return SuijiRewordBox