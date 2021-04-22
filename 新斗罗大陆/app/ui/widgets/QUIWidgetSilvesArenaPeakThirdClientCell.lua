--
-- Kumo.Wang
-- 西尔维斯大斗魂场巅峰赛小组赛界面Cell
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaPeakThirdClientCell = class("QUIWidgetSilvesArenaPeakThirdClientCell", QUIWidget)

local QUIWidgetSilvesArenaPeakHead = import("..widgets.QUIWidgetSilvesArenaPeakHead")

QUIWidgetSilvesArenaPeakThirdClientCell.EVENT_REPLAY = "QUIWIDGETSILVESARENAPEAKTHIRDCLIENTCELL.EVENT_REPLAY"

function QUIWidgetSilvesArenaPeakThirdClientCell:ctor(options)
	local ccbFile = "ccb/Widget_Group_Two_Player.ccbi"
  	local callBacks = {
  		{ccbCallbackName = "onTriggerReplay", callback = handler(self, self._onTriggerReplay)},
  	}
	QUIWidgetSilvesArenaPeakThirdClientCell.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

  	q.setButtonEnableShadow(self._ccbOwner.camera_3)

  	self._roundLayer = {{1, 2},{3}}

  	self._lightIndex = {} -- 点亮的节点，2个点亮的节点中间的线也点亮
  	self._headCellList = {} -- 界面中英雄头像

	self:_init()
end

function QUIWidgetSilvesArenaPeakThirdClientCell:onEnter()
	QUIWidgetSilvesArenaPeakThirdClientCell.super.onEnter(self)
end

function QUIWidgetSilvesArenaPeakThirdClientCell:onExit()
	QUIWidgetSilvesArenaPeakThirdClientCell.super.onExit(self)
end

function QUIWidgetSilvesArenaPeakThirdClientCell:update(info)
	QKumo(info)
	if not info then return end

	self:_initHeads()
	self:_initAllLineColor()

	table.sort(info, function(a, b)
		return a.position < b.position
	end)
	self._info = info

	self._isEnd = false
	for index, value in pairs(info) do
		if value.isThirdRound then
			self._isEnd = true
			self._ccbOwner.node_result:setVisible(true)
			break
		end
	end
	
	self:_updateHeads()
	self:_updateAllLineColor()
end

function QUIWidgetSilvesArenaPeakThirdClientCell:_reset()
	self._ccbOwner.node_result:setVisible(false)
end

function QUIWidgetSilvesArenaPeakThirdClientCell:_init()
	self:_reset()
	self:_initHeads()
	self:_initAllLineColor()
end

function QUIWidgetSilvesArenaPeakThirdClientCell:_initHeads()
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
function QUIWidgetSilvesArenaPeakThirdClientCell:_updateHeads()
	for round, tbl in ipairs(self._roundLayer) do
		local showIndexTbl = {} -- 已经显示的index
		for j, index in ipairs(tbl) do
			local head = self._headCellList[index]
			local title = self._ccbOwner["tf_head_"..index]

			if self._isEnd then
				-- 已经出结果的轮次
				for i, value in pairs(self._info) do
					if not showIndexTbl[i] then
						showIndexTbl[i] = true
						if value.isThirdRound then
							self._lightIndex[index] = true
							if head then
								head:setInfo(value, false, true)
								head:setVisible(true)
							end
							if title then
								title:setString("第三名")
							end
						else
							if head then
								head:setInfo(value, true, true)
								head:setVisible(true)
							end
							if title then
								title:setString("第四名")
							end
						end
						if j * 2 > #tbl then
							-- 头像默认是面向右
							if head then
								head:setHeadFlipX()
							end
						end
						break
					end
				end
			else
				-- 当前正在比赛的轮次
				for i, value in pairs(self._info) do
					if not showIndexTbl[i] then
						showIndexTbl[i] = true
						if head then
							head:setInfo(value, nil, true)
							head:setVisible(true)
						end
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
	end
end

function QUIWidgetSilvesArenaPeakThirdClientCell:_initAllLineColor()
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

function QUIWidgetSilvesArenaPeakThirdClientCell:_updateAllLineColor()
	local roundIndex = 1
	while true do
		local curLayerTbl = self._roundLayer[roundIndex]
		local nextLayerTbl = self._roundLayer[roundIndex + 1]
		if curLayerTbl and nextLayerTbl then
			for _, nextNum in ipairs(nextLayerTbl) do
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

				if self._isEnd then
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

function QUIWidgetSilvesArenaPeakThirdClientCell:_onTriggerReplay(event, target)
	app.sound:playSound("common_small")
	local tbl = {}
	if target == self._ccbOwner.camera_3 then
		if self._info[1] and self._info[1].teamId and self._info[2] and self._info[2].teamId then
			tbl = {self._info[1].teamId, self._info[2].teamId}
		end
	end
	if not q.isEmpty(tbl) then
		self:dispatchEvent({name = QUIWidgetSilvesArenaPeakThirdClientCell.EVENT_REPLAY, teamIdList = tbl})
	end
end

return QUIWidgetSilvesArenaPeakThirdClientCell