--[[
    文件名：LieanerLayout.lua
	描述：线性布局
	创建人：suntao
	创建时间：2016.06.22
--]]

local LieanerLayout = class("LieanerLayout", function()
    return ccui.Layout:create()
end)

local AlignCenter = 0
local AlignStart = -1
local AlignEnd = 1

-- 构造函数
--[[
-- params参数：
	{
		isHorizontal  		是否是水平方向，默认为false
		align				0表示中，-1表示左（下），1表示右（上），默认为0
	}
--]]
function LieanerLayout:ctor(params)
	params = params or {}
	-- 方向
	self.mIsHorizontal = params.isHorizontal or false
	self.mAlign = params.align or AlignCenter

	-- 位置变量
	self.mFixedLength = 0
	self.mVariableLength = 0

	-- 数据存储
	self.mConfigArray = {}
	self.mConfigList = {}
	self.mBackgroundConfig = nil

	-- 根节点
	self.mParentNode = cc.Node:create()
    self:addChild(self.mParentNode)
end

-- 清空
function LieanerLayout:clear()
	self.mParentNode:removeAllChildren()
	self.mFixedLength = 0
	self.mVariableLength = 0
	self.mConfigArray = {}
	self.mConfigList = {}
	self.mBackgroundConfig = nil
end

-- 重新加载
function LieanerLayout:reload()
	local configArray = self.mConfigArray
	for i, config in ipairs(configArray) do
		if config.node then
			config.node:retain()
		end
	end

	self:clear()

	for i, config in ipairs(configArray) do
		self:addItem(config)
		if config.node then
			config.node:release()
		end
	end
end

-- ====================== 控件 ==========================
-- 添加控件
function LieanerLayout:addItem(config)
	-- 保存配置
	config = config or {}
	table.insert(self.mConfigArray, config)
	config.index = #self.mConfigArray
	local tag = config.tag or config.index
	self.mConfigList[tag] = config

	-- 计算偏移
	local variableLength = config.length or 0

	-- 添加节点
	local node = config.node
	if node ~= nil then
		-- 设置锚点
		node:setAnchorPoint(self:adaptAnchor())

		-- 修正偏移
		local size = node:getContentSize()
		if not config.length then
			local a, b = self:adaptSize(size.width, size.height)
			variableLength = variableLength + b
		end

		-- 设置位置
		local posNum = self.mVariableLength + variableLength/2
		node:setPosition(self:adaptPos(0, posNum))
		self.mParentNode:addChild(node)

		-- 修正定长
		local fixedLength = self:adaptSize(size.width, size.height)
		if fixedLength > self.mFixedLength then
			self.mFixedLength = fixedLength
		end
	end

	-- 修正变量
	self.mVariableLength = self.mVariableLength + variableLength

	-- 修正容器位置大小参数
	self:setContentSize(self:adaptSize(self.mFixedLength, self.mVariableLength))
	self:fixParentNode()
	self:fixBackground()

	return node
end

-- 获取控件
function LieanerLayout:getItem(tag)
	return self.mConfigList[tag]
end

-- 移除控件
function LieanerLayout:removeItem(tag)
	local config = self.mConfigArray[tag]
	if config ~= nil then
		-- 数据移除
		table.remove(self.mConfigArray, config.index)

		-- 重载
		self:reload()
	end
end

-- 添加控件
function LieanerLayout:moveItem(tag, index)
	local config = self.mConfigArray[tag]
	if config ~= nil then
		-- 数据移除
		table.remove(self.mConfigArray, config.index)
		table.insert(self.mConfigArray, index, config)

		-- 重载
		self:reload()
	end
end

-- 获取控件
function LieanerLayout:getItems()
	return self.mConfigArray
end

-- ====================== 背景 ==========================
-- 添加背景
function LieanerLayout:addBackground(config)
	-- 删除
	if self.mBackgroundConfig then
		self.mBackgroundConfig.node:removeFromParent()
	end

	-- 添加控件
	local sprite = ui.newScale9Sprite(config.imgName)
	self:addChild(sprite, -1)

	-- 保存
	config.node = sprite
	self.mBackgroundConfig = config

	self:fixBackground()

	return sprite
end

-- 刷新背景大小
function LieanerLayout:fixBackground()
	if self.mBackgroundConfig then
		local config = self.mBackgroundConfig
		local layoutSize = self:getContentSize()
		local size = cc.size(layoutSize.width + (config.marginHorizontal or 0), layoutSize.height + (config.marginVertical or 0))
		config.node:setContentSize(size)
		config.node:setPosition(layoutSize.width/2, layoutSize.height/2)
	end 
end

-- ====================== 工具 ==========================
-- 根据方向修正位置
function LieanerLayout:adaptPos(a, b)
	if not self.mIsHorizontal then
		return a, -b
	else
		return b, a
	end
end

-- 根据方向修正大小
function LieanerLayout:adaptSize(a, b)
	if not self.mIsHorizontal then
		return a, b
	else
		return b, a
	end
end

-- 根据方向修正锚点
function LieanerLayout:adaptAnchor()
	local x = 0.5
	local y = 0.5
	if not self.mIsHorizontal then
		-- 垂直
		if self.mAlign == AlignStart then 
			x = 0
		elseif self.mAlign == AlignEnd then 
			x = 1
		end
	else
		-- 水平
		if self.mAlign == AlignStart then 
			y = 0
		elseif self.mAlign == AlignEnd then 
			y = 1
		end
	end

	--dump(cc.p(x, y))
	return cc.p(x, y)
end

-- 修正父节点位置
function LieanerLayout:fixParentNode()
	local x
	local y
	if not self.mIsHorizontal then
		-- 垂直
		x = self.mFixedLength/2
		y = self.mVariableLength
		if self.mAlign == AlignStart then 
			x = 0
		elseif self.mAlign == AlignEnd then 
			x = self.mFixedLength
		end
	else
		-- 水平
		x = 0
		y = self.mFixedLength/2
		if self.mAlign == AlignStart then 
			y = 0
		elseif self.mAlign == AlignEnd then  
			y = self.mFixedLength
		end
	end

	self.mParentNode:setPosition(x, y)
end

return LieanerLayout
