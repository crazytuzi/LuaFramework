local ZORDER = 100

local BiwuEnemyLayer = class("BiwuEnemyLayer", function()
	return display.newLayer("BiwuEnemyLayer")
end)

function BiwuEnemyLayer:setUpView(param)
	local function createFunc(index)
		local item = require("game.Biwu.BiwuEnemyItem").new()
		return item:create({
		viewSize = cc.size(param.size.width, param.size.width / 3.4),
		cellData = self.dataCenter[index + 1],
		times = self.times,
		rewardListener = handler(self, BiwuEnemyLayer.onRefresh)
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh({
		viewSize = cc.size(param.size.width, param.size.width / 3.4),
		cellData = self.dataCenter[index + 1],
		times = self.times,
		rewardListener = handler(self, BiwuEnemyLayer.onRefresh)
		})
	end
	local boardWidth = param.size.width
	local boardHeight = param.size.height
	self._tableView = require("utility.TableViewExt").new({
	size = cc.size(boardWidth, boardHeight),
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self.dataCenter,
	cellSize = cc.size(boardWidth, param.size.width / 3.4)
	})
	self._tableView:setPosition(0, 0)
	self._tableView:setAnchorPoint(cc.p(0, 0))
	self:addChild(self._tableView)
end

function BiwuEnemyLayer:ctor(param)
	self:setContentSize(param.size)
	local function fuc()
		self:setUpView(param)
	end
	self:_getData(fuc)
end

function BiwuEnemyLayer:onRefresh()
end

function BiwuEnemyLayer:remove()
	self:removeSelf()
end

function BiwuEnemyLayer:_getData(func)
	local function initData(data)
		self.dataCenter = {}
		for k, v in pairs(data.list) do
			table.insert(self.dataCenter, v)
		end
		self.times = data.challengeTimes
		func()
	end
	RequestHelper.biwuSystem.getEnemyList({
	callback = function(data)
		dump(data)
		initData(data)
	end
	})
end

return BiwuEnemyLayer