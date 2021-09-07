local OutLineNoticeView = {
	visible = false,
	notice_des = nil,
	ok_func = nil,
	is_ok_click = false,
	notice_data = nil,
	root_obj = nil,
	view_variable = {
		des = nil,
	},
	view_event = {
		close_window = nil,
		click_ok = nil,
	},
}

local LoadingCamera = GameObject.Find("Loading/UICamera")

function OutLineNoticeView:Start()
	LoadingCamera:GetComponent(typeof(UnityEngine.Camera)).enabled = true
	local view_obj = GameObject.Find("Loading/UILayer/OutLineNoticeView")
	if nil ~= view_obj then
		view_obj.gameObject:SetActive(true)
		self:SetupView(view_obj.gameObject)
	else
		UtilU3d.PrefabLoad(
		"uis/views/login_prefab",
		"OutLineNoticeView",
		function(obj)
			obj.name = string.gsub(obj.name, "%(Clone%)", "")
			self:SetupView(obj)
		end)
	end

end

function OutLineNoticeView:SetupView(obj)
	self.root_obj = obj

	local variable_table = obj:GetComponent("UIVariableTable")
	self.view_variable.des = variable_table:FindVariable("des")

	local event_table = obj:GetComponent("UIEventTable")
	-- event_table:ListenEvent("ClickOk", function()
	-- 	self:OnClickOk()
	-- end)
	event_table:ListenEvent("CloseWindow", function()
		self:Hide()
	end)

	local UIRoot = GameObject.Find("Loading/UILayer").transform
	obj.transform:SetParent(UIRoot, false)
	obj.transform:SetLocalScale(1, 1, 1)
	local rect = obj:GetComponent(typeof(UnityEngine.RectTransform))
	rect.anchorMax = Vector2(1, 1)
	rect.anchorMin = Vector2(0, 0)
	rect.anchoredPosition3D = Vector3(0, 0, 0)
	rect.sizeDelta = Vector2(0, 0)

	-- 设置深度
	local canvas = obj.transform:GetComponent(typeof(UnityEngine.Canvas))
	canvas.overrideSorting = true
	canvas.sortingOrder = 30000

	if not self.visible then
		self.root_obj:SetActive(false)
	end

	if self.is_need_show then
		self:OnFlush()
		self:Show()
	end
end

function OutLineNoticeView:OnFlush()
	if nil == self.notice_data then
		return
	end

	local des = self.notice_data.data.content
	self.view_variable.des:SetValue(des)
end

function OutLineNoticeView:SetNoticeData(notice_data)
	self.notice_data = notice_data
	--self:OnFlush()
end

function OutLineNoticeView:OnClickOk()
	if self.ok_func then
		self.ok_func()
		self.is_ok_click = true
	end
end

function OutLineNoticeView:SetOkFunc(func)
	self.is_ok_click = false
	self.ok_func = func
end

function OutLineNoticeView:Show()
	self.visible = true
	LoadingCamera:GetComponent(typeof(UnityEngine.Camera)).enabled = true
	if self.root_obj ~= nil then
		-- 显示Loading视图
		self.root_obj:SetActive(true)

		-- 重置坐标位置
		local transform = self.root_obj.transform
		transform:SetLocalScale(1, 1, 1)
		local rect = transform:GetComponent(typeof(UnityEngine.RectTransform))
		rect.anchorMax = Vector2(1, 1)
		rect.anchorMin = Vector2(0, 0)
		rect.anchoredPosition3D = Vector3(0, 0, 0)
		rect.sizeDelta = Vector2(0, 0)

		-- 设置深度
		local canvas = transform:GetComponent(typeof(UnityEngine.Canvas))
		canvas.overrideSorting = true
		canvas.sortingOrder = 30000
	end
end

function OutLineNoticeView:Hide()
	self.visible = false
	LoadingCamera:GetComponent(typeof(UnityEngine.Camera)).enabled = false
	if self.root_obj ~= nil then
		self.root_obj:SetActive(false)
	end

	self:Destroy()
end

function OutLineNoticeView:Destroy()
	if self.root_obj ~= nil then
		GameObject.Destroy(self.root_obj)
		self.root_obj = nil
	end
end

function OutLineNoticeView:GetIsOkClick()
	if next(self.notice_data.data) then
		return self.is_ok_click
	else
		return true
	end
end

function OutLineNoticeView:GetOutLineNoticeVisible()
	return self.visible
end

function OutLineNoticeView:SetIsNeedShow(value)
	self.is_need_show = value
end

function OutLineNoticeView:GetIsNeedShow(value)
	return self.is_need_show
end

return OutLineNoticeView