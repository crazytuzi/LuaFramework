-- zengqingfeng
-- 2018/5/29
-- ui组件之下拉伸缩列表节点
-------------------------------------------------------
module(..., package.seeall)

local require = require;

widgetDropDownListNode = i3k_class("widgetDropDownListNode")

function widgetDropDownListNode:ctor(titleName, _data, _groupID, _title_res,_hierarchy)
	-- [外部需要主动赋值的数据]
	self.m_title_name = titleName or "" -- 标题的文本
	self.m_data = _data -- 其他的为数据信息，用来显示的
	self.m_groupID = _groupID or -1 -- 该节点的类型id，回调处理统一处理
	-- [可选值]
	self.m_title_res = _title_res -- 标题的资源脚本，为空或不存在就用全局定义好的默认值
	self.m_hierarchy = _hierarchy or 0 -- [可选值] 层级,根节点为0，其他的从1开始
	-- [创建时需要的信息]
	self.view = nil -- 会被添加到列表的ui
	
	-- [初始化时自动计算的值]
	self.m_parent = nil  -- 父节点
	self.m_children = {} -- 子节点们 
	self.m_index = 0 -- 当前层级的位置，各个层级的sort相加就是全局的sort
	
	-- [运行时的变量]
	self.m_isSelected = false -- 是否被选中
	self.m_redCount = 0 -- 红点提示数目
end

-- 在需要时把这个节点可视化
function widgetDropDownListNode:initView(res, hoster, call)
	if self.m_title_res then 
		res = self.m_title_res -- 有自己特有的资源就优先用自己的
	end 
	local itemView = require(res)()
	self:View(itemView)
	local btn = self:getTitleUIBtn()
	if btn then
	btn:onClick(hoster, call, self)
	end
	local ui_name, title_name = self:getTitleUIName(), self:TitleName()
	if ui_name and title_name then 
		ui_name:setText(title_name)
	end 
	self:Selected(false)
	self:updateRedPoint()
	return itemView 
end 

-- 重设标题状态
function widgetDropDownListNode:changeSelectView(value)
	if value == nil then  
		value = self:Selected()
	end 
	local btn = self:getTitleUIBtn()
	if value then 
		btn:stateToPressed(true)
	else 
		btn:stateToNormal(true)
	end
end 

function widgetDropDownListNode:changeSelectView_safe(value)
	if self:View() and self:getTitleUIBtn() then 
		self:changeSelectView(value)
	end
end 

function widgetDropDownListNode:getIndex(node)
	return self:getLocalIndex(node)
end 

function widgetDropDownListNode:getLocalIndex(node)
	return self:Index()
end 

-- 获取全局的索引
function widgetDropDownListNode:getGlobalIndex()
	local parent = self:getParent()
	if parent then 
		return self:Index() + parent:getGlobalIndex()
	else
		return self:Index()
	end 
end 

-- 标签UI的获取方法
function widgetDropDownListNode:getTitleUIBtn()
	return self.view.vars.btn
end

function widgetDropDownListNode:getTitleUIName()
	return self.view.vars.name or self.view.vars.nameLabel
end  

function widgetDropDownListNode:getTitleUISubName()
	return self.view.vars.sub_name
end  

function widgetDropDownListNode:getTitleUIIcon()
	return self.view.vars.icon
end  

function widgetDropDownListNode:getTitleUIDesc()
	if self.view then
		return self.view.vars.desc
	end
end  

function widgetDropDownListNode:getRedPoint()
	return self.view.vars.redPoint
end  

-- 对于标签ui的操作
function widgetDropDownListNode:setTitleUIName(value, isSafe)
	local ui = self:getTitleUIName()
	if isSafe then 
		self:setUIText_safe(ui, value)
	else 
		ui:setText(value)
	end
end 

function widgetDropDownListNode:setTitleUISubName(value, isSafe)
	local ui = self:getTitleUISubName()
	if isSafe then 
		self:setUIText_safe(ui, value)
	else 
		ui:setText(value)
	end
end 

function widgetDropDownListNode:setTitleIcon(value, isSafe)
	local ui = self:getTitleUIIcon()
	if isSafe then 
		self:setUIImage_safe(ui, value)
	else 
		ui:setImage(value)
	end
end  

function widgetDropDownListNode:setTitleDesc(value, isSafe)
	local ui = self:getTitleUIDesc()
	if isSafe then 
		self:setUIText_safe(ui, value)
	else 
		ui:setText(value)
	end
end  

function widgetDropDownListNode:setUIText_safe(ui, value)
	if ui and value then 
		ui:setText(value)
	end
end 

function widgetDropDownListNode:setUIImage_safe(ui, value)
	if ui and value then 
		ui:setImage(value)
	end
end 

function widgetDropDownListNode:setRedCount(count)
	self.m_redCount = count
	self:updateRedPoint()
end 

function widgetDropDownListNode:updateRedPoint()
	local redPoint = self:getRedPoint()
	if redPoint then 
		if self.m_redCount > 0 then 
			redPoint:show()
		else 
			redPoint:hide()
		end
	end
end 

-- 数据重置方法，暂时没用就不写了
function widgetDropDownListNode:clear()
	
end 

function widgetDropDownListNode:removeView()
	self.view = nil 
end 

-- get set 
function widgetDropDownListNode:Index(value) -- 类似c#的属性
	if value == nil then 
		return self.m_index -- get 
	else 
		self.m_index = value -- set 
	end
end 

function widgetDropDownListNode:Hierarchy(value) 
	if value == nil then 
		return self.m_hierarchy -- get 
	else 
		self.m_hierarchy = value -- set 
	end
end 

function widgetDropDownListNode:Data(value) 
	if value == nil then 
		return self.m_data -- get 
	else 
		self.m_data = value -- set 
	end
end

function widgetDropDownListNode:View(value) 
	if value == nil then 
		return self.view -- get 
	else 
		self.view = value -- set 
	end
end 
 
function widgetDropDownListNode:TitleName(value) 
	if value == nil then 
		return self.m_title_name -- get 
	else
		error(string.format(debug_error_tips_readonly, "_title_name"))
		--self.m_title_name = value -- set 
	end
end 

function widgetDropDownListNode:GroupID(value) 
	if value == nil then 
		return self.m_groupID -- get 
	else
		error(string.format(debug_error_tips_readonly, "_groupID"))
		--self.m_groupID = value -- set 
	end
end 

function widgetDropDownListNode:Type(value) 
	if value == nil then 
		return self.m_groupID -- get 
	else
		error(string.format(debug_error_tips_readonly, "_groupID"))
		--self.m_groupID = value -- set 
	end
end 

function widgetDropDownListNode:Selected(value) 
	if value == nil then 
		return self.m_isSelected -- get 
	else 
		if self.m_isSelected ~= value and self.view then 
			self:changeSelectView_safe(value)
		end
		self.m_isSelected = value -- set 
	end
end 

function widgetDropDownListNode:isSelected()
	return self.m_isSelected
end 


-- 树结构一些基本的api -- 
function widgetDropDownListNode:getChild(node)
	for index, child in ipairs(self.m_children) do 
		if child == node then
			return child, index
		end
	end
end 

function widgetDropDownListNode:getChildByIndex(_index)
	for index, child in ipairs(self.m_children) do 
		if index == _index then
			return child, index
		end
	end
	return nil, 0 
end 

function widgetDropDownListNode:addChild(node)
	node:setParent(self)
	table.insert(self.m_children, node) 
end 

function widgetDropDownListNode:removeChild(node)
	local _, index = self:getChild(node)
	if index ~= 0 then 
		table.remove(self.m_children, index)
	end 
	return index 
end 

function widgetDropDownListNode:removeChildByIndex(index)
	local _, index = self:getChildByIndex(node)
	if index ~= 0 then 
		table.remove(self.m_children, index)
	end 
	return index 
end  

function widgetDropDownListNode:removeAllChildren()
	for index, child in ipairs(self.m_children) do 
		child:removeFromParent()
	end
	self.m_children = {}
end 

function widgetDropDownListNode:getChildrenCount()
	return #self.m_children
end 

function widgetDropDownListNode:hasChild()
	return self:getChildrenCount() > 0
end 

function widgetDropDownListNode:getChildren()
	return self.m_children
end 

function widgetDropDownListNode:getParent()
	return self.m_parent 
end

function widgetDropDownListNode:setParent(parent)
	self:removeFromParent()
	self.m_parent = parent
end

function widgetDropDownListNode:removeFromParent()
	if self.m_parent then  
		self.m_parent:removeChild(self)
	end
	self.m_parent = nil 
end
