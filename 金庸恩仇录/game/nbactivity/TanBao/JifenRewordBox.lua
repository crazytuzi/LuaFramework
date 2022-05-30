local JifenRewordBox = class("JifenRewordBox", function()
	return require("utility.ShadeLayer").new()
end)

function JifenRewordBox:initButton()
	
	local function closeFun(sender, eventName)
		self:removeSelf()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	end
	
	local function confirmFun(sender, eventName)
		if self._confirmFunc ~= nil then
			self._confirmFunc()
		end
		self:removeSelf()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end
	
	self._rootnode.closeBtn:addHandleOfControlEvent(closeFun, CCControlEventTouchUpInside)
	self._rootnode.okBtn:addHandleOfControlEvent(confirmFun, CCControlEventTouchUpInside)
	
	if self._jifen < self._num then
		self._rootnode.okBtn:setTouchEnabled(false)
		self._rootnode.okBtn:setEnabled(false)
	end
	if self._state == 0 then
		self._rootnode.okBtn:setVisible(false)
		local iconComplete = display.newSprite("#getok.png")
		iconComplete:setPosition(cc.p(display.width / 2, display.height / 2 - 120))
		self:addChild(iconComplete, 10)
	end
	if self.titleDis then
		self._rootnode.titleLabel:setString(self.titleDis)
	end
end

function JifenRewordBox:initRewardListView(cellDatas)
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
	size = cc.size(boardWidth, boardHeight),
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #cellDatas,
	cellSize = cellContentSize
	})
	self.ListTable:setPosition(0, self._rootnode.listView:getContentSize().height * 0.015)
	self._rootnode.listView:addChild(self.ListTable)
end

function JifenRewordBox:onEnter()
	
end

function JifenRewordBox:onExit()
	TutoMgr.removeBtn("lingqu_confirm")
end

function JifenRewordBox:ctor(param)
	self:setNodeEventEnabled(true)
	self._confirmFunc = param.confirmFunc
	self._jifen = param.jifen
	self.titleDis = param.titleDis
	self._num = param.num
	self._state = param.state
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("huodong/huodong_jifenjiangli.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.scoreLabel:setString(param.num or 0)
	local tabel = {}
	table.insert(tabel, self._rootnode.rewardsLabel1)
	table.insert(tabel, self._rootnode.scoreLabel)
	table.insert(tabel, self._rootnode.rewardsLabel2)
	alignNodesOneByAllCenterX(self._rootnode.rewardsLabel1:getParent(), tabel)
	local cellDatas = param.cellDatas
	self:initButton()
	self:initRewardListView(cellDatas)
end

return JifenRewordBox