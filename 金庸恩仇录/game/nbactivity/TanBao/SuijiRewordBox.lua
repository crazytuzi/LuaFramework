local SuijiRewordBox = class("SuijiRewordBox", function()
	return require("utility.ShadeLayer").new()
end)

function SuijiRewordBox:initButton()
	local function closeFun(sender, eventName)
		if self._confirmFunc ~= nil then
			self._confirmFunc()
		end
		self:removeSelf()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	end
	self._rootnode.closeBtn:addHandleOfControlEvent(closeFun, CCControlEventTouchUpInside)
	self._rootnode.okBtn:addHandleOfControlEvent(closeFun, CCControlEventTouchUpInside)
end

function SuijiRewordBox:initRewardListView(cellDatas)
	local boardWidth = self._rootnode.listView:getContentSize().width
	local boardHeight = self._rootnode.listView:getContentSize().height * 0.97
	local function createFunc(index)
		local item = require("game.nbactivity.TanBao.SuijiRewordItem").new()
		return item:create({
		id = index,
		itemData = cellDatas[index + 1],
		viewSize = cc.size(boardWidth, boardHeight * 0.48)
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh({
		index = index,
		itemData = cellDatas[index + 1]
		})
	end
	local cellContentSize = require("game.nbactivity.TanBao.SuijiRewordItem").new():getContentSize()
	self.ListTable = require("utility.TableViewExt").new({
	size = CCSizeMake(boardWidth, boardHeight),
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #cellDatas,
	cellSize = cellContentSize,
	direction = kCCScrollViewDirectionVertical
	})
	self.ListTable:setPosition(0, self._rootnode.listView:getContentSize().height * 0.015)
	self._rootnode.listView:addChild(self.ListTable)
end

function SuijiRewordBox:onExit()
	TutoMgr.removeBtn("lingqu_confirm")
end

function SuijiRewordBox:ctor(param)
	self:setNodeEventEnabled(true)
	self._confirmFunc = param.confirmFunc
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("huodong/huodong_suijijiangli.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	local cellDatas = param.cellDatas
	local data = {}
	local index = 0
	local dataTemp = {}
	for k, v in pairs(cellDatas) do
		table.insert(dataTemp, v)
		if k % 4 == 0 or k == #cellDatas then
			table.insert(data, dataTemp)
			dataTemp = {}
		end
	end
	self:initButton()
	self:initRewardListView(data)
	dump(data)
end

return SuijiRewordBox