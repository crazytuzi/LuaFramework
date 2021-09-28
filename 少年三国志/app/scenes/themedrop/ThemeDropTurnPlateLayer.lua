local TurnPlateLayerBase = require("app.scenes.themedrop.TurnPlateLayerBase")
local ThemeDropTurnPlateNode = require("app.scenes.themedrop.ThemeDropTurnPlateNode")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

local ThemeDropTurnPlateLayer = class("ThemeDropTurnPlateLayer", TurnPlateLayerBase)

-- 10个角度
--local angles = {55, 90, 125, 200, 270, 340}

--				 4   5   6    7		8	9	 1    2    3
local angles1 = {40, 75, 105, 140, 175, 225, 270, 315, 355}
local hidePos1 = {5, 6}
local halfHidePos1 = {4, 7}
local showPos1 = {1, 2, 3, 8, 9}

--				 4   5   6    7	   8	9   10    1    2    3
local angles2= {40, 75, 90, 105, 140, 175, 225, 270, 315, 355}
local hidePos2 = {5, 6, 7}
local halfHidePos2 = {4, 8}
local showPos2 = {1, 2, 3, 9, 10}

--				 4   5  6    7	 8	  9   10    11   1    2    3
--local angles3= {40, 75, 85, 95, 105, 140, 175, 225, 270, 315, 360}
local angles3= {40, 60, 80, 95, 115, 140, 175, 225, 270, 310, 355}


local hidePos3 = {5, 6, 7, 8}
local halfHidePos3 = {4, 9}
local showPos3 = {1, 2, 3, 10, 11}


function ThemeDropTurnPlateLayer:init(size, tDropKnightList)
	self._tDropKnightList = tDropKnightList or {}
	self._nNodeCount = table.nums(self._tDropKnightList)

	self._isAutoRotate = false

	assert(self._nNodeCount ~= 0)

	self._tAngles = {}
	self._tHidePos = {}
	self._tHalfHidePos = {}
	self._tShowPos = {}
	local nStartIndex = 6

	if self._nNodeCount == 9 then
		self._tAngles = angles1
		self._tHidePos = hidePos1
		self._tHalfHidePos = halfHidePos1
		self._tShowPos = showPos1
		nStartIndex = 6
	elseif self._nNodeCount == 10 then
		self._tAngles = angles2
		self._tHidePos = hidePos2
		self._tHalfHidePos = halfHidePos2
		self._tShowPos = showPos2
		nStartIndex = 7
	elseif self._nNodeCount == 11 then
		self._tAngles = angles3
		self._tHidePos = hidePos3
		self._tHalfHidePos = halfHidePos3
		self._tShowPos = showPos3
		nStartIndex = 8
	end

	self.super.init(self, size, self._tAngles, nStartIndex)


	for i=1, self._nNodeCount do
		local tThemeTmpl = self._tDropKnightList[i]
		assert(tThemeTmpl)
		if tThemeTmpl then
			local node = ThemeDropTurnPlateNode.create()
			local nKnightBaseId = tThemeTmpl.id
			node:setData(i, nKnightBaseId)
			self:addNode(node, i)

			local nScale = tThemeTmpl.ball_size / 1000
			node:scaleStarImage(nScale)
			node:addEffect()
			node:adapterKinghtNamePos()
		end
	end

	self:onMove()
end

function ThemeDropTurnPlateLayer:onMove()
--	__Log("--onMove")

    for i=1, #self._showList do
	    local node = self._showList[i]
	    local x, y = node:getPosition()
	    y = y - self.m_nCenter.y
	    x = x-self.m_nCenter.x


	    local b = self.m_shortAxis / 2
	    local c = y / b 

	    local nAngle = math.asin(c) * 180 / math.pi

	    if x>0 then
	   		if y < 0 then
	   	  		nAngle = nAngle + 360
		    end
	    else
	   	  	nAngle = 180 - nAngle
	    end
		if c >= 1 then
			nAngle = 90
		elseif c <= -1 then
			nAngle = -90
		end

	    if nAngle > 45 and nAngle < 120 then
	   		node:changeOpacity(0)
	    else
	   		node:changeOpacity(255)		
	    end

	    if nAngle > 30 and nAngle < 150 then
	   		node:setZOrder(node:getZOrder() * (-1))
	    else
	   		node:setZOrder(node:getZOrder() * (1))
	    end
    end

end

function ThemeDropTurnPlateLayer:onMoveStop(reason)
	if reason == "back" then
		for k,v in pairs(self._showList) do
	    	--处于自动旋转状态，并且旋转结束，pos == 1的结点，要处理一个回调
	    	if self._isAutoRotate then
	    		if v.pos == 1 then
	    			if self._playEffectCallback then
	    			--	__Log(" 执行了回调，开始播放特效")
	    				self._playEffectCallback()
	    				self._playEffectCallback = nil
	    			end
	    		end
	    	end
	    end

	   	self:_refresh()
	end
end

--[[
function ThemeDropTurnPlateLayer:_arrangeZOrder()

end
]]


-- 点击
function ThemeDropTurnPlateLayer:onClick(pt)
  
end

function ThemeDropTurnPlateLayer:autoRotateToCenter(nKnightBaseId, playEffectCallback)
	self._isAutoRotate = true
	self._playEffectCallback = playEffectCallback
	self:disabledTouch()
	self._nRate = 15

	local findKnight = false
	local nDir = 1
	local nStep = 0
	for key, val in pairs(self._showList) do
		local node = val
		if node:getKnightBaseId() == nKnightBaseId then
			findKnight = true
			local nCenter = math.ceil(self._nNodeCount/2)
			if node.pos <= nCenter then
				nDir = -1
				nStep = node.pos - 1
			else
				nDir = 1
				nStep = (self._nNodeCount + 1) - node.pos
			end
		end
	end

	
	if nStep <= 2 and nStep > 0 then
		self._nRate = 6
	elseif nStep == 0 then
		nDir = -1
		self._nRate = 15
	end

	if not findKnight then
		assert(false, "not find knight ~")
	end

	-- 测试
	-- nStep = 0
	-- nDir = -1
	-- self._nRate = 50

	self:judgeNeedMoveBack(nDir, nStep)
end

function ThemeDropTurnPlateLayer:autoRotateToCenter1(nDir, nStep, playEffectCallback)
	self._isAutoRotate = true
	self._playEffectCallback = playEffectCallback
	self:disabledTouch()
	self._nRate = 18

	self:judgeNeedMoveBack(nDir, nStep)
end

function ThemeDropTurnPlateLayer:disabledTouch()
	self:setTouchEnabled(false)
end

function ThemeDropTurnPlateLayer:recoverTouch()
    self:setTouchEnabled(true)
end

function ThemeDropTurnPlateLayer:getFrontNode()
	local frontNode = nil
	for key, val in pairs(self._showList) do
		if val.pos == 1 then
			frontNode = val
			break
		end 
	end
	return frontNode
end

-- 排除最前面的其它所有结点
function ThemeDropTurnPlateLayer:getNodeExceptFront()
	local tNodeList = {}
	for key, val in pairs(self._showList) do
		if val.pos ~= 1 then
			table.insert(tNodeList, #tNodeList+1, val)
		end
	end
	return tNodeList
end

function ThemeDropTurnPlateLayer:setAutoRotate(isAuto)
	self._isAutoRotate = isAuto or false
end

function ThemeDropTurnPlateLayer:isAutoRotate()
	return self._isAutoRotate or false
end

function ThemeDropTurnPlateLayer:calcStep(nKnightBaseId)
	local nStep = 0
	for key, val in pairs(self._showList) do
		local node = val
		if node:getKnightBaseId() == nKnightBaseId then
			nStep = node.pos - 1
		end
	end
	return nStep
end

function ThemeDropTurnPlateLayer:getNodeCount()
	return self._nNodeCount
end


return ThemeDropTurnPlateLayer