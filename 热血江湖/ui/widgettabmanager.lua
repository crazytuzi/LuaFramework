-- zengqingfeng
-- 2018/6/4
-- ui组件之页签切换管理器
--[[
<说明>
	1.初始化时注册各个面板的id
	2.各种操作会回调对应方法到外部面板中
		self.listener{
			preTabChanged -- 页签切换前
			onTabChanged -- 页签切换
		}
	3.可以选择切换时关闭上一个页签或者隐藏两种模式
	4.可以修改页签按钮不同状态的文本颜色

</说明>
]]--
-----------------------------------------------

local TAB_NODE_TYPE_NORMAL = 1 -- 默认 只在事件触发时分发事件，使用者自己管理UI逻辑
--local TAB_NODE_TYPE_MULT_PAGE = 2 -- 多个UI脚本共用一个manager
--local TAB_NODE_TYPE_PAGE = 3 -- 同一个脚本UI用一个manager且在本脚本切换各个UI资源
--local TAB_NODE_TYPE_NODE = 4 -- 切换ui节点而不是UI页面只是一个小ui（node，scrollview之类的）

module(..., package.seeall)

local require = require;
widgetTabManager = i3k_class("widgetTabManager")

function widgetTabManager:ctor(hoster)
	self.m_isNoticeAll = false -- 切换时通知知所有页签(一般是多个页签在不同脚本下这个才有用)
	self.m_isCloseHide = false -- 切换时只是隐藏上一个界面而不是关闭
	self.m_node_type = TAB_NODE_TYPE_NORMAL
	self.m_hoster = hoster -- 使用者的引用
	self.m_listener = {-- 事件回调函数集
		preTabChanged = nil, -- 页签切换前
		onTabChanged = nil, -- 页签切换
	}
	self.m_tabs = {} -- 页签按钮引用合集
	self.m_texts = {} -- 页签按钮文本合集
	self.m_textColor = { -- 页签文本颜色 选择和为被选中状态
		{"fffffca3", "ffd8893a"}, -- 主色和描边
		{"ffffa488", "ff9b3d46"}
	} 
	self.m_tabs_name = nil -- 页签按钮名字合集(有要管理类似的时候多个UI, 统一他们的页签按钮名字)

	self.m_curIndex = 0  -- 当前页签的索引
end

function widgetTabManager:configure(tabs)
	self:Tabs(tabs)
	self:refreshColor()
end

----------------------- <公共方法 外部接口> ---------------------
-- == 数据操作相关
function widgetTabManager:rgListener(listener)
	self.m_listener = listener or {}
end

function widgetTabManager:addTab(newTab)
	local index = #self.m_tabs + 1
	newTab:setTag(index)
	newTab:onClick(self, self._onClick, index)
	newTab:setTitleTextColor(self.m_textColor)
	table.insert(self.m_tabs, newTab)
end

function widgetTabManager:refreshColor()
	for index, tab in ipairs(self:Tabs()) do 
		if tab:isStatePressed() then 
			tab:stateToPressed(true)
		else 
			tab:stateToNormal(true)
		end
	end
end 

function widgetTabManager:getTabByIndex(index)
	return self.m_tabs[index]
end

function widgetTabManager:getTextByIndex(index)
	return self.m_texts[index]
end

function widgetTabManager:getTextColorByState(flag)
	local index = flag and 1 or 2
	return self.m_textColor[index]
end 

-- == 操作行为相关
-- 主动触发点击事件
function widgetTabManager:onClick(index)
	self:_setIndex(index, true)
end

-- 刷新当前页签数据
function widgetTabManager:refreshUI()
	self:_setIndex(self.m_curIndex, true)
end

-- get set
-- 切换时只通知目标页签还是通知全部页签
function widgetTabManager:IsNoticeAll(value)
	if value == nil then
		return self.m_isNoticeAll -- get
	else
		self.m_isNoticeAll = value -- set
	end
end

-- 页签按钮
function widgetTabManager:Tabs(value)
	if value == nil then
		return self.m_tabs -- get
	else
		self.m_tabs = {}-- set
		for index, tab in ipairs(value) do
			self:addTab(tab)
		end
	end
end

-- 页签按钮文本
function widgetTabManager:Texts(value)
	if value == nil then
		return self.m_texts -- get
	else
		self.m_texts = value-- set
	end
end

-- 页签按钮颜色
function widgetTabManager:TextsColor(value)
	if value == nil then
		return self.m_textColor -- get
	else
		self.m_textColor = value-- set
		for index, tab in ipairs(self:Tabs()) do 
			tab:setTitleTextColor(self.m_textColor)
		end
		self:refreshColor()
	end
end 

-- 当前索引
function widgetTabManager:CurIndex(value)
	if value == nil then
		return self.m_curIndex -- get
	else
		self:onClick(value)
	end
end

-- 回调函数集合
function widgetTabManager:Listener(value)
	if value == nil then
		return self.m_listener -- get
	else
		-- self.m_listener = value -- set
		error(string.format(debug_error_tips_readonly, "m_listener"))
	end
end


----------------------- </公共方法 外部接口> ---------------------

----------------------- <私有方法 内部实现> ---------------------
function widgetTabManager:_onClick(sender, index, isFroce)
	self:_setIndex(index, isFroce)
end

-- 页签切换
function widgetTabManager:_setIndex(index, isFroce)
	if not isFroce and index == self.m_curIndex then return end

	local oldIndex = self.m_curIndex
	if self.m_listener.preTabChanged then -- 分发切换前的处理
		self.m_listener.preTabChanged(self.m_hoster, index)
	end
	self.m_curIndex = index

	 -- 新标签的处理
	if index then
        self:_setTabFlag(index, true)
        if self.m_listener.onTabChanged then -- 分发切换后处理
            self.m_listener.onTabChanged(self.m_hoster, self:getTabByIndex(index), index)
        end
    end

	-- 旧标签的处理
	if oldIndex then
        self:_setTabFlag(oldIndex, false)
    end
end

function widgetTabManager:_setTabFlag(index, flag)
    local tab = self:getTabByIndex(index)
	if not tab then return end
	
    if flag then
		tab:stateToPressed(true)
	else
		tab:stateToNormal(true)
	end
end

----------------------- </私有方法 内部实现> ---------------------
