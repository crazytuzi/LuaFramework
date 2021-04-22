--
-- Kumo.Wang
-- 西尔维斯大斗魂场巅峰赛小组赛界面Cell
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaPeakGroupClientCell = class("QUIWidgetSilvesArenaPeakGroupClientCell", QUIWidget)

local QUIWidgetSilvesArenaPeakHead = import("..widgets.QUIWidgetSilvesArenaPeakHead")

QUIWidgetSilvesArenaPeakGroupClientCell.EVENT_RIGHT = "QUIWIDGETSILVESARENAPEAKGROUPCLIENTCELL.EVENT_RIGHT"
QUIWidgetSilvesArenaPeakGroupClientCell.EVENT_LEFT = "QUIWIDGETSILVESARENAPEAKGROUPCLIENTCELL.EVENT_LEFT"
QUIWidgetSilvesArenaPeakGroupClientCell.EVENT_REPLAY = "QUIWIDGETSILVESARENAPEAKGROUPCLIENTCELL.EVENT_REPLAY"

function QUIWidgetSilvesArenaPeakGroupClientCell:ctor(options)
	local ccbFile = "ccb/Widget_Group_Four_Player.ccbi"
  	local callBacks = {
  		{ccbCallbackName = "onTriggerReplay", callback = handler(self, self._onTriggerReplay)},
  		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
  		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
  	}
	QUIWidgetSilvesArenaPeakGroupClientCell.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

  	
  	q.setButtonEnableShadow(self._ccbOwner.camera_5)
  	q.setButtonEnableShadow(self._ccbOwner.camera_6)
  	q.setButtonEnableShadow(self._ccbOwner.camera_7)

  	-- 这个界面是一个小组4名选手，所以首轮为4，之后进行淘汰
  	self._roundLayer = {{1, 2, 3, 4},{5, 6},{7}}

  	self._lightIndex = {} -- 点亮的节点，2个点亮的节点中间的线也点亮
  	self._headCellList = {} -- 界面中英雄头像

	self:_init()
end

function QUIWidgetSilvesArenaPeakGroupClientCell:onEnter()
	QUIWidgetSilvesArenaPeakGroupClientCell.super.onEnter(self)
end

function QUIWidgetSilvesArenaPeakGroupClientCell:onExit()
	QUIWidgetSilvesArenaPeakGroupClientCell.super.onExit(self)
end

-- 通用版本
function QUIWidgetSilvesArenaPeakGroupClientCell:setNormal()
	self._ccbOwner.node_view:setPositionY(0)
	local finalIndex = self._roundLayer[#self._roundLayer][1]
	local finalLine = self._ccbOwner["ly_line_"..finalIndex]
	if finalLine then
		finalLine:setContentSize(3, 50)
	end
	local finalHead = self._ccbOwner["head_"..finalIndex]
	if finalHead then
		finalHead:setPositionY(150)
	end
end

-- 用于战报显示3、4名之后压扁
function QUIWidgetSilvesArenaPeakGroupClientCell:setSmall()
	self._ccbOwner.node_view:setPositionY(20)
	local finalIndex = self._roundLayer[#self._roundLayer][1]
	local finalLine = self._ccbOwner["ly_line_"..finalIndex]
	if finalLine then
		finalLine:setContentSize(3, 30)
	end
	local finalHead = self._ccbOwner["head_"..finalIndex]
	if finalHead then
		finalHead:setPositionY(130)
	end
end

function QUIWidgetSilvesArenaPeakGroupClientCell:update(info, baseRound)
	if not info then return end
	self._baseRound = baseRound or 1

	self:_initHeads()
	self:_initAllLineColor()

	table.sort(info, function(a, b)
		return a.position < b.position
	end)
	self._info = info

	self._topRound = 0
	for index, value in pairs(info) do
		local curRound = value.currRound - self._baseRound + 1
		if self._topRound < curRound then
			self._topRound = curRound
		end
	end
	
	self:_updateHeads()
	self:_updateAllLineColor()
end

function QUIWidgetSilvesArenaPeakGroupClientCell:_reset()
end

function QUIWidgetSilvesArenaPeakGroupClientCell:_init()
	self:_reset()
	self:_initHeads()
	self:_initAllLineColor()
end

function QUIWidgetSilvesArenaPeakGroupClientCell:_initHeads()
	if q.isEmpty(self._headCellList) then
		self._headCellList = {}
		local index = 1
		while true do
			local node = self._ccbOwner["head_"..index]
			if node then
				node:removeAllChildren()
				local head = QUIWidgetSilvesArenaPeakHead.new()
				node:addChild(head)
				self._headCellList[index] = head
				index = index + 1
			else
				break
			end
		end
	else
		for _, head in pairs(self._headCellList) do
			head:resetAll()
		end
	end
end

-- 注：currRound 代表这个队伍目前的最高轮次，可能是止步当前轮次，可能是正在进行的轮次，由于4强之后不用树状图，所以不用考虑其他特殊情况
function QUIWidgetSilvesArenaPeakGroupClientCell:_updateHeads()
	for round, tbl in ipairs(self._roundLayer) do
		local showIndexTbl = {} -- 已经显示的index
		for j, index in ipairs(tbl) do
			local head = self._headCellList[index]
			if round == self._topRound then
				-- 当前正在比赛的轮次
				for i, value in pairs(self._info) do
					local curRound = value.currRound - self._baseRound + 1
					if not showIndexTbl[i] then
						showIndexTbl[i] = true
						if curRound >= round  then
							if head then
								print("[无结果] ", round, index, curRound, value.teamName, "NONE")
								head:setInfo(value, nil, true)
								head:setVisible(true)
								if j * 2 > #tbl then
									-- 头像默认是面向右
									if head then
										head:setHeadFlipX()
									end
								end
								break
							end
						end
					end
				end
			elseif round < self._topRound then
				-- 已经出结果的轮次
				for i, value in pairs(self._info) do
					local curRound = value.currRound - self._baseRound + 1
					print("[有结果] ", round, i, curRound, showIndexTbl[i])
					if not showIndexTbl[i] then
						showIndexTbl[i] = true
						if curRound > round then
							self._lightIndex[index] = true
							if head then
								print("[有结果] ", round, index, curRound, value.teamName, "WIN")
								head:setInfo(value, false, true)
								head:setVisible(true)
								if j * 2 > #tbl then
									-- 头像默认是面向右
									if head then
										head:setHeadFlipX()
									end
								end
								break
							end
						elseif curRound == round then
							if head then
								print("[有结果] ", round, index, curRound, value.teamName, "LOST")
								head:setInfo(value, true, true)
								head:setVisible(true)
								if j * 2 > #tbl then
									-- 头像默认是面向右
									if head then
										head:setHeadFlipX()
									end
								end
								break
							end
						end
					end
				end
			else
				-- 还没有到的轮次，这里什么都不用做即可
				-- head:setVisible(false)
			end
		end
	end
end

function QUIWidgetSilvesArenaPeakGroupClientCell:_initAllLineColor()
	self._lightIndex = {}
	local roundIndex = 1
	while true do
		local curLayerTbl = self._roundLayer[roundIndex]
		local nextLayerTbl = self._roundLayer[roundIndex + 1]
		if curLayerTbl and nextLayerTbl then
			for index, curNum in ipairs(curLayerTbl) do
				for _, nextNum in ipairs(nextLayerTbl) do
					-- 晋级线有一个拐角分2段，让2个节点合并成一个节点。
					local line1 = self._ccbOwner["ly_line_"..curNum..nextNum.."1"]
					local line2 = self._ccbOwner["ly_line_"..curNum..nextNum.."2"]
					-- 合并后的节点到晋级的节点连线
					local line3 = self._ccbOwner["ly_line_"..nextNum]
					local camera = self._ccbOwner["camera_"..nextNum]
					if line1 then
						line1:setColor(COLORS.x)
					end
					if line2 then
						line2:setColor(COLORS.x)
					end
					if line3 then
						line3:setColor(COLORS.x)
					end
					if camera then
						camera:setVisible(false)
					end
				end
			end
			roundIndex = roundIndex + 1
		else
			break
		end
	end
end

function QUIWidgetSilvesArenaPeakGroupClientCell:_updateAllLineColor()
	QKumo(self._lightIndex)
	local roundIndex = 1
	while true do
		local curLayerTbl = self._roundLayer[roundIndex]
		local nextLayerTbl = self._roundLayer[roundIndex + 1]
		if curLayerTbl and nextLayerTbl then
			for _, nextNum in ipairs(nextLayerTbl) do
				local isEnd = false
				-- 合并后的节点到晋级的节点连线
				local line3 = self._ccbOwner["ly_line_"..nextNum]
				local camera = self._ccbOwner["camera_"..nextNum]
				for index, curNum in ipairs(curLayerTbl) do
					-- 晋级线有一个拐角分2段，让2个节点合并成一个节点。
					local line1 = self._ccbOwner["ly_line_"..curNum..nextNum.."1"]
					local line2 = self._ccbOwner["ly_line_"..curNum..nextNum.."2"]
					if self._lightIndex[curNum] then
						if line1 then
							line1:setColor(COLORS.w)
							isEnd = true 
						end
						if line2 then
							line2:setColor(COLORS.w)
						end
					else
						if line1 then
							line1:setColor(COLORS.x)
						end
						if line2 then
							line2:setColor(COLORS.x)
						end
					end
				end
				if isEnd then
					if line3 then
						line3:setColor(COLORS.w)
					end
					if camera then
						camera:setVisible(true)
					end
				else
					if line3 then
						line3:setColor(COLORS.x)
					end
					if camera then
						camera:setVisible(false)
					end
				end
			end
			roundIndex = roundIndex + 1
		else
			break
		end
	end
end

function QUIWidgetSilvesArenaPeakGroupClientCell:_onTriggerReplay(event, target)
	app.sound:playSound("common_small")
	local tbl = {}
	if target == self._ccbOwner.camera_5 then
		if self._info[1] and self._info[1].teamId and self._info[2] and self._info[2].teamId then
			tbl = {self._info[1].teamId, self._info[2].teamId}
		end
	elseif target == self._ccbOwner.camera_6 then
		if self._info[3] and self._info[3].teamId and self._info[4] and self._info[4].teamId then
			tbl = {self._info[3].teamId, self._info[4].teamId}
		end
	elseif target == self._ccbOwner.camera_7 then
		local round = #self._roundLayer - 1
		for _, value in ipairs(self._info) do
			local curRound = value.currRound - self._baseRound + 1
			if curRound >= round then
				table.insert(tbl, value.teamId)
			end
		end
	end
	if not q.isEmpty(tbl) then
		self:dispatchEvent({name = QUIWidgetSilvesArenaPeakGroupClientCell.EVENT_REPLAY, teamIdList = tbl})
	end
end

function QUIWidgetSilvesArenaPeakGroupClientCell:_onTriggerRight(event)
	app.sound:playSound("common_small")

	self:dispatchEvent({name = QUIWidgetSilvesArenaPeakGroupClientCell.EVENT_RIGHT})
end

function QUIWidgetSilvesArenaPeakGroupClientCell:_onTriggerLeft(event)
	app.sound:playSound("common_small")

	self:dispatchEvent({name = QUIWidgetSilvesArenaPeakGroupClientCell.EVENT_LEFT})
end

return QUIWidgetSilvesArenaPeakGroupClientCell