-- zengqingfeng
-- 2018/5/29
-- ui组件之下拉伸缩列表节点
-------------------------------------------------------
module(..., package.seeall)

local require = require;

wightDropDownListNode = i3k_class("wightDropDownListNode")

function wightDropDownListNode:ctor(titleName, _data, _groupID, _title_res)
	-- [外部需要主动赋值的数据]
	self.m_title_name = titleName or "" -- 标题的文本
	self.m_data = _data -- 其他的为数据信息，用来显示的
	self.m_groupID = _groupID or -1 -- 该节点的类型id，回调处理统一处理
	-- [可选值]
	self.m_title_res = _title_res -- 标题的资源脚本，为空或不存在就用全局定义好的默认值
	
	-- [创建时需要的信息]
	self.view = nil -- 会被添加到列表的ui
	
	-- [初始化时自动计算的值]
	self.m_parent = nil  -- 父节点
	self.m_children = {} -- 子节点们 
	self.m_hierarchy = 0 -- 层级,根节点为0，其他的从1开始
	self.m_index = 0 -- 当前层级的位置，各个层级的sort相加就是全局的sort
	
	-- [运行时的变量]
	self.m_isSelected = false -- 是否被选中
end

-- 在需要时把这个节点可视化
function wightDropDownListNode:initView(res, hoster, call)
	if self.m_title_res then 
		res = self.m_title_res -- 有自己特有的资源就优先用自己的
	end 
	local itemView = require(res)()
	self:View(itemView)
	local btn = self:getTitleUIBtn()
	btn:onClick(hoster, call, self)
	local ui_name, title_name = self:getTitleUIName(), self:TitleName()
	if ui_name and title_name then 
		ui_name:setText(title_name)
	end 
	self:Selected(false)
	return itemView 
end 

-- 重设标题状态
function wightDropDownListNode:changeSelectView(value)
	if value == nil then  
		value = self:Selected()
	end 
	local btn = self:getTitleUIBtn()
	if value then 
		btn:stateToPressed()
	else 
		btn:stateToNormal()
	end
end 

function wightDropDownListNode:changeSelectView_safe(value)
	if self:View() and self:getTitleUIBtn() then 
		self:changeSelectView(value)
	end
end 

function wightDropDownListNode:getIndex(node)
	return self:getLocalIndex(node)
end 

function wightDropDownListNode:getLocalIndex(node)
	return self:Index()
end 

-- 获取全局的索引
function wightDropDownListNode:getGlobalIndex()
	local parent = self:getParent()
	if parent then 
		return self:Index() + parent:getGlobalIndex()
	else
		return self:Index()
	end 
end 

function wightDropDownListNode:getTitleUIBtn()
	return self.view.vars.btn
end

function wightDropDownListNode:getTitleUIName()
	return self.view.vars.name or self.view.vars.nameLabel
end  

-- 数据重置方法，暂时没用就不写了
function wightDropDownListNode:clear()
	
end 

function wightDropDownListNode:removeView()
	self.view = nil 
end 

-- get set 
function wightDropDownListNode:Index(value) -- 类似c#的属性
	if value == nil then 
		return self.m_index -- get 
	else 
		self.m_index = value -- set 
	end
end 

function wightDropDownListNode:Hierarchy(value) 
	if value == nil then 
		return self.m_hierarchy -- get 
	else 
		self.m_hierarchy = value -- set 
	end
end 

function wightDropDownListNode:Data(value) 
	if value == nil then 
		return self.m_data -- get 
	else 
		self.m_data = value -- set 
	end
end

function wightDropDownListNode:View(value) 
	if value == nil then 
		return self.view -- get 
	else 
		self.view = value -- set 
	end
end 
 
function wightDropDownListNode:TitleName(value) 
	if value == nil then 
		return self.m_title_name -- get 
	else
		error(string.format(debug_error_tips_readonly, "_title_name"))
		--self.m_title_name = value -- set 
	end
end 

function wightDropDownListNode:GroupID(value) 
	if value == nil then 
		return self.m_groupID -- get 
	else
		error(string.format(debug_error_tips_readonly, "_groupID"))
		--self.m_groupID = value -- set 
	end
end 

function wightDropDownListNode:Selected(value) 
	if value == nil then 
		return self.m_isSelected -- get 
	else 
		if self.m_isSelected ~= value and self.view then 
			self:changeSelectView_safe(value)
		end
		self.m_isSelected = value -- set 
	end
end 

function wightDropDownListNode:isSelected()
	return self.m_isSelected
end 


-- 树结构一些基本的api -- 
function wightDropDownListNode:getChild(node)
	for index, child in ipairs(self.m_children) do 
		if child == node then
			return child, index
		end
	end
end 

function wightDropDownListNode:getChildByIndex(_index)
	for index, child in ipairs(self.m_children) do 
		if index == _index then
			return child, index
		end
	end
	return nil, 0 
end 

function wightDropDownListNode:addChild(node)
	node:setParent(self)
	table.insert(self.m_children, node) 
end 

function wightDropDownListNode:removeChild(node)
	local _, index = self:getChild(node)
	if index ~= 0 then 
		table.remove(self.m_children, index)
	end 
	return index 
end 

function wightDropDownListNode:removeChildByIndex(index)
	local _, index = self:getChildByIndex(node)
	if index ~= 0 then 
		table.remove(self.m_children, index)
	end 
	return index 
end  

function wightDropDownListNode:removeAllChildren()
	for index, child in ipairs(self.m_children) do 
		child:removeFromParent()
	end
	self.m_children = {}
end 

function wightDropDownListNode:getChildrenCount()
	return #self.m_children
end 

function wightDropDownListNode:hasChild()
	return self:getChildrenCount() > 0
end 

function wightDropDownListNode:getChildren()
	return self.m_children
end 

function wightDropDownListNode:getParent()
	return self.m_parent 
end

function wightDropDownListNode:setParent(parent)
	self.m_parent = parent
end

function wightDropDownListNode:removeFromParent()
	if self.m_parent then  
		self.m_parent:removeChild(self)
	end
	self.m_parent = nil 
end
