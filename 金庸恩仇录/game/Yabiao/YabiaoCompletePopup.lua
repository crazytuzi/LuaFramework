local YabiaoCompletePopup = class("YabiaoCompletePopup", function()
	return require("utility.ShadeLayer").new()
end)

function YabiaoCompletePopup:ctor(param)
	self:setUpView(param)
end

function YabiaoCompletePopup:onEnter()
end

function YabiaoCompletePopup:onExit()
end

function YabiaoCompletePopup:setUpView(param)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("huodong/yabiao_complete.ccbi", proxy, self._rootnode)
	node:setPosition(cc.p(display.cx, display.cy))
	self:addChild(node)
	if param.type == 2 then
		self._rootnode.title_sign:setDisplayFrame(display.newSprite("ui/ui_guild_battle/xunluowancheng.png"):getDisplayFrame())
	else
		display.addSpriteFramesWithFile("ui/ui_yabiao_common.plist", "ui/ui_yabiao_common.png")
		self._rootnode.title_sign:setDisplayFrame(display.newSprite("#yabiao_ok.png"):getDisplayFrame())
	end
	
	--х╥хо
	self._rootnode.confirmBtn:addHandleOfControlEvent(function(eventName, sender)
		if param.confirmFunc then
			param.confirmFunc()
			self:removeFromParent()
			PostNotice(NoticeKey.CommonUpdate_Label_Gold)
			PostNotice(NoticeKey.CommonUpdate_Label_Silver)
		end
	end,
	CCControlEventTouchUpInside)
	
	local cellDatas = {}
	for k, v in pairs(param.itemData) do
		local temp = {}
		temp.id = v.id
		temp.num = v.num
		temp.type = v.type
		temp.iconType = ResMgr.getResType(v.type)
		temp.name = require("data.data_item_item")[v.id].name
		table.insert(cellDatas, temp)
		if v.id == 1 then
			game.player:setGold(game.player:getGold() + v.num)
		elseif v.id == 2 then
			game.player:setSilver(game.player:getSilver() + v.num)
		end
	end
	local boardWidth = self._rootnode.listView:getContentSize().width
	local boardHeight = self._rootnode.listView:getContentSize().height * 0.97
	local function createFunc(index)
		local item = require("game.nbactivity.TanBao.JifenRewordItem").new()
		return item:create({
		id = index,
		itemData = cellDatas[index + 1],
		viewSize = cc.size(boardWidth, boardHeight)
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh({
		index = index,
		itemData = cellDatas[index + 1]
		})
	end
	local cellContentSize = require("game.nbactivity.TanBao.JifenRewordItem").new():getContentSize()
	self.ListTable = require("utility.TableViewExt").new({
	size =  cc.size(boardWidth, boardHeight),
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #cellDatas,
	cellSize = cellContentSize
	})
	self.ListTable:setPosition(0, self._rootnode.listView:getContentSize().height * 0.015)
	self._rootnode.listView:addChild(self.ListTable)
end

return YabiaoCompletePopup