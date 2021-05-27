
-----------------------------------------------------
-- BaseRender。实现根据配置进行构建，额外动态内容可通过继承自行实现
-- 具体的数据显示需要通过重写OnFlush
-----------------------------------------------------

BaseRender = BaseRender or BaseClass()
function BaseRender:__init()
	self.view = XLayout:create()
	self.data = nil
	self.index = 0
	self.name = ""

	self.is_ui_created = false						-- 是否已经创建ui
	self.ui_config = nil
	self.node_tree = {}
	self.ph_list = {}
	self.global_event_map = {}

	self.click_callback = nil						-- 点击回调

	self.is_use_step_calc = false					-- 是否使用分步计算
	self.is_add_step = false						-- 是否添加入分步计算池

	self.is_select = false							-- 是否选中
	self.select_effect = nil						-- 选中特效
	self.ignore_data_to_select = false
end

function BaseRender:__delete()
	if self.is_add_step then
		StepPool.Instance:DelStep(self)
	end

	NeedDelObjs:clear(self)

	self.ignore_data_to_select = false
	self.is_ui_created = false

	for k, _ in pairs(self.global_event_map) do
		GlobalEventSystem:UnBind(k)
	end
	self.global_event_map = {}
end

function BaseRender:GetView()
	return self.view
end

function BaseRender:GetData()
	return self.data
end

function BaseRender:SetData(data)
	self.data = data
	self:Flush()
end

function BaseRender:ClearData()
	self:SetData(nil)
end

function BaseRender:GetIndex()
	return self.index
end

function BaseRender:SetIndex(index)
	self.index = index
end

function BaseRender:GetName()
	return self.name
end

function BaseRender:SetName(name)
	self.name = name
end

function BaseRender:IsUiCreated()
	return self.is_ui_created
end

function BaseRender:GetUiConfig()
	return self.ui_config
end

function BaseRender:SetIgnoreDataToSelect(value)
	if self.ignore_data_to_select and not value then
		self:SetSelect(false)
	end
	self.ignore_data_to_select = value
end

function BaseRender:SetUiConfig(ui_config, need_create)
	self.ui_config = ui_config
	self.view:setContentWH(ui_config.w, ui_config.h)
	if need_create then
		self:CreateChild()
	end
end

function BaseRender:SetPosition(x, y)
	self.view:setPosition(x, y)
end

function BaseRender:SetContentSize(w, h)
	self.view:setContentWH(w, h)
end

function BaseRender:SetAnchorPoint(x, y)
	self.view:setAnchorPoint(x, y)
end

function BaseRender:SetScale(scale)
	self.view:setScale(scale)
end

function BaseRender:SetVisible(is_visible)
	self.view:setVisible(is_visible)
end

function BaseRender:SetEventEnabled(is_enabled)
	self.view:setTouchEnabled(is_enabled)
end

function BaseRender:AddClickEventListener(callback, is_click_scale)
	self.click_callback = callback
	self.view:setTouchEnabled(true)
	if is_click_scale then self.view:setIsHittedScale(true) end
	self.view:addClickEventListener(function()
		self:OnClick()
	end)
end

function BaseRender:SetClickCallBack(callback)
	self.click_callback = callback
end

-- 是否使用分步计算
function BaseRender:SetIsUseStepCalc(is_use_step_calc)
	self.is_use_step_calc = is_use_step_calc
end

-- 外部通知刷新，调用此接口
function BaseRender:Flush()
	if self.is_use_step_calc then
		if not self.is_add_step then
			self.is_add_step = true
			StepPool.Instance:AddStep(self)
		end
	else
		if not self.is_ui_created then
			self:CreateChild()
		end
		self:OnFlush()
	end
end

-- 分步计算回调
function BaseRender:Step()
	self.is_add_step = false

	if not self.is_ui_created then
		self:CreateChild()
	end
	self:OnFlush()
end

-- 是否选中
function BaseRender:IsSelect()
	return self.is_select
end

-- 设置是否选中
function BaseRender:SetSelect(is_select)
	if self.is_select == is_select or not self:CanSelect() then
		return
	end
	self.is_select = is_select
	if self.is_select then
		if nil == self.select_effect then
			self:CreateSelectEffect()
		else
			self.select_effect:setVisible(true)
		end
	else
		if nil ~= self.select_effect then
			self.select_effect:setVisible(false)
		end
	end

	self:OnSelectChange(self.is_select)
end

function BaseRender:BindGlobalEvent(event_id, event_func)
	local handle = GlobalEventSystem:Bind(event_id, event_func)
	self.global_event_map[handle] = event_id
	return handle
end

function BaseRender:UnBindGlobalEvent(handle)
	GlobalEventSystem:UnBind(handle)
	self.global_event_map[handle] = nil
end

-- 创建子节点
function BaseRender:CreateChild()
	self.is_ui_created = true

	-- 根据配置创建UI
	if nil ~= self.ui_config then
		XUI.Parse(self.ui_config, self.view, nil, self.node_tree, self.ph_list)
		self.ui_config = nil
	end

	self:CreateChildCallBack()
end

-- 加入自动清理列表
function BaseRender:AddObj(key)
	NeedDelObjs:add(self, key)
end

----------------------------------------------------
-- 可重写的接口 begin
----------------------------------------------------
function BaseRender:CreateChildCallBack()
end

-- 刷新
function BaseRender:OnFlush()
end

-- 点击回调
function BaseRender:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

-- list事件回调
function BaseRender:OnListEvent(event_type)
	
end

-- 是否可选中
function BaseRender:CanSelect()
	return self.ignore_data_to_select or nil ~= self.data
end

-- 创建选中特效
function BaseRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_285"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end

-- 选择状态改变
function BaseRender:OnSelectChange(is_select)
end
----------------------------------------------------
-- 可重写的接口 end
----------------------------------------------------
