OpenServerTabbarManager = OpenServerTabbarManager or BaseClass()

-- 判断条件类型
TabbarHideCondition = {
	Outside = 1000,			--外部判断
}


function OpenServerTabbarManager:__init()
	self.check_tabbar_list = {}
	self.outside_mark_list = {} 	-- 记录外部判断index
	self.tab_index_mark_list = {} 	-- 记录view下所有tab_index
	self.tabbar_visible_list = {}	-- 记录标签visible
end

function OpenServerTabbarManager:__delete()
	self.check_tabbar_list = {}
	self.outside_mark_list = {}
	self.tab_index_mark_list = {}
	self.tabbar_visible_list = {}
end

-- 注册检查tabbar项显隐
-- condition 	参考 TabbarHideCondition
-- t 			参考 OpenServerTabbarManager:CheckTVByCheckTabbarTable()
function OpenServerTabbarManager:RegisterCheckTabbarVisible(view_name, tab_index, condition, t)
	condition = condition or TabbarHideCondition.Outside
	if nil ~= self.check_tabbar_list[view_name] and nil ~= self.check_tabbar_list[view_name][tab_index]
		and nil ~= self.check_tabbar_list[view_name][tab_index][condition] then
		if condition >= TabbarHideCondition.Outside then
			if nil ~= self.outside_mark_list[view_name][tab_index] then
				condition = self.outside_mark_list[view_name][tab_index] + 1
			end
		else
			ErrorLog("[ViewName: " .. view_name .."][TabIndex: " .. tab_index .. "][condition: " .. condition .. "]:Already be registered")
			return
		end
	end

	if nil == self.check_tabbar_list[view_name] then self.check_tabbar_list[view_name] = {} end
	if nil == self.check_tabbar_list[view_name][tab_index] then self.check_tabbar_list[view_name][tab_index] = {} end
	self.check_tabbar_list[view_name][tab_index][condition] = {}
	self.check_tabbar_list[view_name][tab_index][condition].view_name = view_name
	self.check_tabbar_list[view_name][tab_index][condition].tab_index = tab_index
	self.check_tabbar_list[view_name][tab_index][condition].condition = condition
	self.check_tabbar_list[view_name][tab_index][condition].t = t

	-- 外部判断允许多个
	if condition >= TabbarHideCondition.Outside then
		if nil == self.outside_mark_list[view_name] then self.outside_mark_list[view_name] = {} end
		self.outside_mark_list[view_name][tab_index] = condition
	end
end

-- 反注册检查tabbar项显隐
function OpenServerTabbarManager:UnRegisterCheckTabbarVisible(view_name, tab_index)
	if nil == self.check_tabbar_list[view_name] then return end

	if nil ~= tab_index then
		if nil ~= self.check_tabbar_list[view_name][tab_index] then
			self.check_tabbar_list[view_name][tab_index] = nil
			self.outside_mark_list[view_name][tab_index] = nil
			self.tabbar_visible_list[view_name][tab_index] = nil
		end
	else
		self.check_tabbar_list[view_name] = {}
	end

	if self.check_tabbar_list[view_name] == {} then
		self.check_tabbar_list[view_name] = nil
		self.outside_mark_list[view_name] = nil
		self.tab_index_mark_list[view_name] = nil
		self.tabbar_visible_list[view_name] = nil
	end
end

-- 记录该view下所有tab_index (防止默认显示标签页被隐藏时显示错误)
function OpenServerTabbarManager:SetViewAllTabIndex(view_name, tab_index_t)
	if nil == self.tab_index_mark_list[view_name] then self.tab_index_mark_list[view_name] = {} end
	local t = {}
	for k,v in pairs(tab_index_t) do
		t[#t + 1] = v
	end
	table.sort(t, function(a, b)
		return a < b 
	end)

	self.tab_index_mark_list[view_name] = t
end

-- 检查tabbar项显隐(外部接口)
function OpenServerTabbarManager:CheckTabbarVisible(view_name, tab_index)
	if nil == self.check_tabbar_list[view_name] then return end
	if nil ~= tab_index then
		local tabbar_t = self.check_tabbar_list[view_name][tab_index]
		if nil == tabbar_t then return end
		self:CheckTVByCheckTabbarTable(tabbar_t, view_name, tab_index)
	else
		for k,v in pairs(self.check_tabbar_list[view_name]) do
			self:CheckTVByCheckTabbarTable(v, view_name, k)
		end
	end
end

-- 检查tabbar项显隐(内部调用) (在这里调用判断方法)
function OpenServerTabbarManager:CheckTVByCheckTabbarTable(tabbar_t, view_name, tab_index)
	if nil == tabbar_t or type(tabbar_t) ~= "table" then return end
	local tab_is_open = true
	for condition, c_tabbar_t in pairs(tabbar_t) do
		if condition >= TabbarHideCondition.Outside and c_tabbar_t.t then 			-- 外部判断
			local open_tag = self:CheckTVByOutside(c_tabbar_t.view_name, c_tabbar_t.tab_index, c_tabbar_t.t.func)
			if nil ~= open_tag then
				tab_is_open = tab_is_open and open_tag
			end

		end
	end
	self:SetViewTabbarVisible(view_name, tab_index, tab_is_open)
end

-- 设置标签页显示隐藏
function OpenServerTabbarManager:SetViewTabbarVisible(view_name, tab_index, is_visible)
	local view = ViewManager.Instance:GetView(view_name)
	if nil == view or nil == view.tabbar then return end

	local tab_btn = view.tabbar:GetToggle(tab_index)
	if tab_btn and tab_btn:isVisible() ~= is_visible then
		view.tabbar:SetToggleVisible(tab_index, is_visible)

		if nil == self.tabbar_visible_list[view_name] then self.tabbar_visible_list[view_name] = {} end
		self.tabbar_visible_list[view_name][tab_index] = is_visible
	end

	if not is_visible and view.tabbar:GetCurSelectIndex() == tab_index and self.check_tabbar_list[view_name] then
		local tab_index_t = self.tab_index_mark_list[view_name]
		if nil ~= tab_index_t then
			for k,v in pairs(tab_index_t) do
				local btn = view.tabbar:GetToggle(v)
				if btn and btn:isVisible() then
					view.tabbar:SelectIndex(v)
					break
				end
			end
		end
	end

	-- if view:GetShowIndex() and view.tabbar:GetCurSelectIndex() ~= view:GetShowIndex() then
	-- 	view:ChangeToIndex(view.tabbar:GetCurSelectIndex())
	-- end
end

function OpenServerTabbarManager:GetViewTabbarVisible(view_name, tab_index)
	if nil == self.tabbar_visible_list[view_name] then return end
	return self.tabbar_visible_list[view_name][tab_index]
end






--------------------------------
-- 外部判断
--------------------------------
function OpenServerTabbarManager:CheckTVByOutside(view_name, tab_index, func)
	if nil == view_name or nil == tab_index or nil == func then return end
	return func()
end