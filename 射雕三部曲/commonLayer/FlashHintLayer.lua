--[[
    文件名: FlashHintLayer.lua
	描述: 飘窗提示信息页面，
	创建人: liaoyuangang
	创建时间: 2016.6.1
--]]

local FlashHintLayer = class("FlashHintLayer", function(params)
    return display.newLayer()
end)

--[[
]]
function FlashHintLayer:ctor()
	-- 需要提示的信息列表
	self.mHintInfoList = {}
	-- 当前是否正在显示提示信息
	self.mIsShowing = false
	-- 是否立即执行
	self.isShowNow = true

	-- 拥有执行Actions的对象
	self.mActionNode = cc.Node:create()
	self:addChild(self.mActionNode)

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 
end

-- 设置延迟执行
function FlashHintLayer:delayShowAction()
	self.isShowNow = false
end

-- 开始执行动画
function FlashHintLayer:startShowAction()
	self.isShowNow = true
	self:beginShowInfo()
end

-- 开始显示提示信息
function FlashHintLayer:beginShowInfo()
	if self.mIsShowing or not self.isShowNow then
		return
	end

	self.mIsShowing = true
	self.mActionNode:stopAllActions()
	Utility.schedule(self.mActionNode, function()
		local count = #self.mHintInfoList
		if count == 0 then
			self.mActionNode:stopAllActions()
			self.mIsShowing = false
			return 
		end

		local tempInfos = self.mHintInfoList
		self.mHintInfoList = {}
		self:showOneInfo(tempInfos)
	end, 0.6)
end

-- 显示一条信息(私有函数)
function FlashHintLayer:showOneInfo(hintInfos)
	local hightSum = 0
	local tempNodeList = {}
	for index, hintInfo in ipairs(hintInfos) do
		if hintInfo.HintBgImg == "c_41.png" then
			-- 创建卡槽的战力
			local FAPBgSprite = ui.newFAPView(hintInfo.HintStr)
			self.mParentLayer:addChild(FAPBgSprite)
			local tempSize = FAPBgSprite:getContentSize()
			hightSum = hightSum + tempSize.height + 5
			table.insert(tempNodeList, FAPBgSprite)
		else
			local tempNode = ui.createSpriteAndLabel({
		    	imgName = hintInfo.HintBgImg or "c_103.png",
		    	scale9Size = cc.size(300, 39),
		        labelStr = hintInfo.HintStr,
		        fontColor = hintInfo.Color or Enums.Color.eBrown,
		    })
		    table.insert(tempNodeList, tempNode)
		    self.mParentLayer:addChild(tempNode)

		    hightSum = hightSum + tempNode:getContentSize().height + 5
		end
	end

	-- 
	local tempPosY = 630 + hightSum / 2
	for index, node in ipairs(tempNodeList) do
		node:setPosition(320, tempPosY)
		tempPosY = tempPosY - node:getContentSize().height - 5

		-- 执行动画
	    node:setScale(0.8)
	    local array = {}
	    table.insert(array, cc.ScaleTo:create(0.1, 1.1))
	    table.insert(array, cc.ScaleTo:create(0.1, 1))
	    table.insert(array, cc.DelayTime:create(1))
	    table.insert(array, cc.FadeOut:create(0.3))
	    table.insert(array, cc.CallFunc:create(function()
	        node:removeFromParent()
	    end))
	    node:runAction(cc.Sequence:create(array))
	end
end

-- 添加提示信息
--[[
-- 参数params的格式为
	{
		Color = Enums.Color.eBrown, -- 提示信息的显示颜色
        HintStr = "", -- 提示信息
        HintBgImg = "", -- 提示信息的背景
	}
]]
function FlashHintLayer:addHintInfo(params)
	if not params or not params.HintStr or params.HintStr == "" then
		return
	end

	local count = #self.mHintInfoList
	table.insert(self.mHintInfoList, count + 1, params)
	self:beginShowInfo()
end

-- 添加一组提示信息
--[[
-- 参数params的格式为
	{
		{
			Color = Enums.Color.eBrown, -- 提示信息的显示颜色
	        tempItem.HintStr = "", -- 提示信息
		}
		...
	}
]]
function FlashHintLayer:addHintList(params)
	for _, item in ipairs(params or {}) do
		self:addHintInfo(item)
	end
end

return FlashHintLayer