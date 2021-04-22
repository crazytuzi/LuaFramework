
--[[
	红点处理
]]


local QBaseModel = import("..models.QBaseModel")
local QRedTips = class("QRedTips", QBaseModel)

QRedTips.TIPS_STATE_CHANGE = "TIPS_STATE_CHANGE"
function QRedTips:ctor(  )
	-- body
	QRedTips.super.ctor(self)
    self:_init()
end

--手动添加红点 结构 
-- 
function QRedTips:_init(  )
	-- body
	self._tipsRoot = {}
end

--登录 拉取完 数据 初始化红点
function QRedTips:initRedTips( )
	--占卜活动 红点
	local imp = remote.activityRounds:getDivination()
	if imp and imp.isOpen then
		imp:initDivinationTips()
	end

	imp = remote.activityRounds:getRushBuy()
	if imp and imp.isOpen then
		imp:initRushbuyTips()
	end

end

function QRedTips:removeNodeByName(name, isNotNeedDispatch)
	-- body
	local node = self._tipsRoot[name]
	if node and node.parentName then
		local parentNode = self._tipsRoot[parentName]
		if parentNode and parentNode.children then
			parentNode.children[name] = nil
		end
		self._tipsRoot[name] = nil
		--如果当前节点为true 则需要检查父节点的状态
		if node.state then
			local isSame, parentState = self:_checkNodeState(parentNode)
			if isSame then
				if not isNotNeedDispatch then
					self:_dispatchTipsChange()
				end
			else
				return self:setTipsStateByName(node.parentName, parentState, isNotNeedDispatch)
			end
		end
	else
		self._tipsRoot[name] = nil
	end
end


function QRedTips:createTipsNode( name, parentName )
	-- body
	local temp = {}
	temp.state = false
	if parentName then
		local parentNode = self._tipsRoot[parentName]
		if parentNode then
			if not parentNode.children then
				parentNode.children = {}
			end
			temp.parentName = parentName
			parentNode.children[name] = temp
		end
	end
	self._tipsRoot[name] = temp
end

function QRedTips:didappear()
	self._appear = true
end

function QRedTips:disappear()
	self._appear = nil
end

--获取红点状态
function QRedTips:getTipsStateByName( name )
	-- body
	local node = self._tipsRoot[name]
	if node then
		return node.state or false
	end
	return false
end

--设置红点状态
function QRedTips:setTipsStateByName( name , state , isNotNeedDispatch, parentName)
	-- body
	local node = self._tipsRoot[name]
	if not node and parentName then
		self:createTipsNode(name, parentName)
		node = self._tipsRoot[name]
	end
	
	if node then
		if state == node.state then
			return
		end
		node.state = state
		if node.parentName then
			local parentNode = self._tipsRoot[node.parentName]
			local isSame, parentState = self:_checkNodeState(parentNode)
			if isSame then
				if not isNotNeedDispatch then
					self:_dispatchTipsChange()
				end
			else
				return self:setTipsStateByName(node.parentName, parentState, isNotNeedDispatch)
			end
		else
			if not isNotNeedDispatch then
				self:_dispatchTipsChange()
			end
		end
	end
end

function QRedTips:_dispatchTipsChange()
	-- body
	if not self._schedulerID then
		self._schedulerID = scheduler.performWithDelayGlobal(function ()
			if self._appear then
				self:dispatchEvent({name = QRedTips.TIPS_STATE_CHANGE})
				self._schedulerID = nil
			end
		end, 0)
	end
end




function QRedTips:_checkNodeState( node )
	-- body
	if node and node.children then
		local oldState = node.state
		local newState = false
		for _, v in pairs(node.children) do
			if v.state == true then
				newState = true
			end
		end
		return oldState == newState, newState
	end
	return true
end




return QRedTips