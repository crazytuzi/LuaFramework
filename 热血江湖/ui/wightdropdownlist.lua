-- zengqingfeng
-- 2018/5/29
-- ui组件之下拉伸缩列表（类似于排行榜)
-- 使用例子请参考homeland_structure
--注意:外部注册的回调方法如果处理成功的话一定要return true --
--注意:外部注册的回调方法如果处理成功的话一定要return true --
--注意:外部注册的回调方法如果处理成功的话一定要return true --
-- 回调返回值通知界面是否刷新成功 -- 方便内部处理
-------------------------------------------------------
module(..., package.seeall)

local require = require;

wightDropDownList = i3k_class("wightDropDownList")

function wightDropDownList:ctor(scrollView, titleRes)
	self.m_scrollView = scrollView
	self.m_root_node = nil -- 根节点
	self.m_autoOpenFirstChild = true
	self.m_titleRes = titleRes or {"ui/widgets/rxphblbt", "ui/widgets/rxphblbt2"}-- 每个层级的按钮资源（一个层级暂时是统一的)
	self.m_curNode = nil -- 当前成功加载的界面所属节点
	self.m_hoster = nil -- 使用者
	self.m_common_handler = nil -- 公共回调函数 
	self.m_handlers = nil -- UID回调行数对应表
end

-- 将列表菜单数据设置
function wightDropDownList:configure(infos)
	self:removeAllView()
	-- 初始化层级的信息

	self.m_root_node = self:_createNode() -- 建立数据为空的根节点(没有数据不会可视化)
	self:_setConfig(self.m_root_node, infos, 1)
end 

-- 注意要放在注册函数之后
function wightDropDownList:show()
	self:_onClickItem(nil, self.m_root_node) -- 默认点击了一下根节点（也就是把根节点下的一层子节点显示出来)
end 

--------------------------- 外部接口 公共方法 --------------------------
-- 注意:外部注册的回调方法如果处理成功的话一定要return true --
-- 公共的注册点击触发事件，只要点击了就发出 -- 比较简单
function wightDropDownList:rgSelectedCommmonHandler(hoster, callbackFunc)
	self.m_hoster = hoster 
	self.m_common_handler = callbackFunc
end 

--- 处理函数多推荐第二种方式 -- 注册uid和处理函数的对应表，读表查询uid发出注册过的方法
function wightDropDownList:rgSelectedHandlers(hoster, callbackFunc)
	self.m_hoster = hoster 
	self.m_handlers = callbackFunc
end 

-- 按照uid单独注册对应的处理函数
function wightDropDownList:rgSelectedHandlerByUID(hoster, callbackFunc)

end 

-- 清理所有回调函数
function wightDropDownList:clearHandlers()
	
end 

-- 快速打开指定标签（可以传入筛选函数，且会自动重置界面） 
function wightDropDownList:clickItemByGroup(typeID, conditionFunc)
	local node = self:findItemByGroup(typeID, conditionFunc)
	if node then 
		local oldFlag = self:AutoOpenFirstChild()
		self:AutoOpenFirstChild(false) -- 暂时关闭自动开启功能
		self:resetView() -- 重置主界面
		self:_parentOpen(node) -- 打开父节点
		self:AutoOpenFirstChild(oldFlag)
		self:_onClickItem(nil, node) -- 选择自身
		return true 
	end
	return false 
end 

-- 关闭当前同一层级的所有节点的子节点
function wightDropDownList:closeAllChildItems(node)
	local parent = node:getParent()
	if parent then 
		for index, child in ipairs(parent:getChildren()) do 
			self:_closeChildItems_safe(child)
		end
	end
end 

-- 重新重置界面（只把层级1下的子节点删除）
function wightDropDownList:resetView()
	for index, child in ipairs(self.m_root_node:getChildren()) do 
		self:_closeChildItems_safe(child)
	end
end 

-- 根据标签类型搜索节点（同一类型可以使用筛选函数过滤）
function wightDropDownList:findItemByGroup(groupID, conditionFunc, parent)
	parent = parent or self.m_root_node -- 默认从根节点找
	local target = nil
	for index, child in ipairs(parent:getChildren()) do 
		if child:GroupID() == groupID then
			if conditionFunc then 
				if child:Data() and conditionFunc(child:Data()) then 
					return child
				end 
			else 
				return child 
			end 
		end
		target = self:findItemByGroup(groupID, conditionFunc, child) -- 递归访问子节点(深度遍历)
		if target then 
			return target
		end
	end
end 

-- 如果该节点没有数据是否默认开启有数据的第一个子页签
function wightDropDownList:AutoOpenFirstChild(value)
	if value == nil then 
		return self.m_autoOpenFirstChild -- get 
	else 
		self.m_autoOpenFirstChild = value -- set 
	end
end 

-- 当前加载的界面节点
function wightDropDownList:CurNode(value)
	if value == nil then 
		return self.m_curNode -- get 
	else 
		self.m_curNode = value -- set 
	end
end 

-- 清理视图
function wightDropDownList:removeAllView()
	self.m_scrollView:removeAllChildren()
	-- 节点里面的item引用暂时还没去除
end 

-- 后期添加信息节点
function wightDropDownList:addNewInfo(newInfo)
	-- 根据新的信息修改树结构信息
	
end 

-- 后期删除信息节点
function wightDropDownList:removeInfo(info)
	-- 根据信息修改树结构信息
	
end 

----------------------  私有方法 内部实现 -------------------------
function wightDropDownList:_setConfig(parent, info, hierarchy)
	for index, value in ipairs(info) do 
		local node = self:_createNode(value._title_name, value._data, value._groupID, value._title_res) -- 根据资源和数据创建节点
		node:Hierarchy(hierarchy)
		node:Index(index)
		parent:addChild(node)
		if value._children then 
			self:_setConfig(node, value._children, hierarchy + 1) -- 递归访问子节点处理
		end
	end
end 

-- 点击触发事件
function wightDropDownList:_onClickItem(sender, node)
	local selectFlag = node:isSelected()
	if not selectFlag then 
		selectFlag = true 
		self:closeAllChildItems(node)
		self:_sendHandler(node)
	end 
	
	if node:hasChild() then 
		self:_scrollChange(node)
	else 
		-- 没有伸缩功能是否选中的逻辑用之前的
		node:Selected(selectFlag)
	end 
end 

-- 响应注册过的点击事件
function wightDropDownList:_sendHandler(node)
	if self.m_hoster then 
		local successFlag = false 
		local oldNode = self:CurNode()
		self:CurNode(node)
		
		-- 分发公共处理函数
		if self.m_common_handler then 
			if self.m_common_handler(self.m_hoster, node, node:Data()) then 
				successFlag = true 
			end
		end
		
		-- 按照注册的事件表分发
		if self.m_handlers then 
			if self:_sendHandlers(node) then 
				successFlag = true 
			end
		end
		
		if not successFlag then 
			self.m_curNode = oldNode -- 没有一个处理成功的话回档
		end 
	end 
end 

function wightDropDownList:_sendHandlers(node)
	local groupID = node:GroupID()
	local callBackFunc = self.m_handlers[groupID]
	if callBackFunc then 
		-- 分发事件
		local successFlag = false 
		local oldNode = self:CurNode()
		self:CurNode(node)
		for index, _funcStr in ipairs(callBackFunc) do 
			local func = self.m_hoster[_funcStr]
			if func then 
				if func(self.m_hoster, node, node:Data()) then 
					successFlag = true -- 只要有一个处理函数成功就算成功
				end
			end
		end
		return successFlag 
	end
end 

-- 有子节点就有伸缩功能
function wightDropDownList:_scrollChange(node)
	if node:isSelected() then 
		self:_closeChildItems(node)
	else 
		self:_openChildItems(node)
	end
end 

function wightDropDownList:_openChildItems_safe(node)
	if node:hasChild() and (not node:isSelected()) then 
		self:_openChildItems(node)
	else 
		node:Selected(true)
	end
end 

function wightDropDownList:_closeChildItems_safe(node, deleteNum)
	if node:hasChild() and node:isSelected() then 
		self:_closeChildItems(node, deleteNum)
	else 
		node:Selected(false)
	end
end 

-- 打开扩张该item的子列表(关闭状态下才可操作)
function wightDropDownList:_openChildItems(node)
	local parentIndex = node:getGlobalIndex()
	local titleRes = self:_getGlobalTitleRes(node:Hierarchy() + 1) -- 获取全局默认标题资源
	for index, child in ipairs(node:getChildren()) do 
		-- 添加之前暂时没有做防止重复添加的判断，之后有必要再加
		local itemView = child:initView(titleRes, self, self._onClickItem)
		self.m_scrollView:insertChildToIndex(itemView, parentIndex + index)
	end
	node:Selected(true)
	self.m_scrollView:jumpToChildWithIndex(parentIndex + 1)
	
	-- 自身没有数据的话自动点击第一个子节点
	if self:AutoOpenFirstChild() and not node:Data() then 
		local firstChild = node:getChildByIndex(1)
		if firstChild then 
			self:_onClickItem(nil, firstChild)
		end
	end
end 

-- 关闭该item的子列表(打开状态下才可操作)
function wightDropDownList:_closeChildItems(node, deleteNum)
	deleteNum = deleteNum or 0 -- 节点删除是动态的，老旧的index需要适当修复
	local parentIndex = node:getGlobalIndex()
	for index, child in ipairs(node:getChildren()) do 
		-- 去除之前暂时不会判断被去除节点的正确性，之后有必要再加
		self:_closeChildItems_safe(child, index - 1) -- 递归调用除去子节点
		child:removeView()
		self.m_scrollView:removeChildAtIndex(parentIndex + 1 - deleteNum)
	end  
	node:Selected(false)
end 

-- 被选中了把没有被打开的父节点先全打开
function wightDropDownList:_parentOpen(node)
	local parent = node:getParent()
	if parent and parent ~= self.m_root_node then 
		self:_parentOpen(parent) -- 递归访问父节点
		self:_openChildItems_safe(parent) -- 倒序处理
	end
end 

function wightDropDownList:_createNode(...)
	local script = require("ui/wightDropDownListNode"); 
	return script.wightDropDownListNode.new(...);
end 

function wightDropDownList:_getGlobalTitleRes(hierarchy)
	hierarchy = hierarchy or 1
	return self.m_titleRes[hierarchy] or self.m_titleRes[1]
end 
