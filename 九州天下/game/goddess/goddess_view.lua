require("game/goddess/goddess_shengwu_view")
require("game/goddess/goddess_gongming_view")

--------------------------------------------------------------------------
-- GoddessView 	女神总面板
--------------------------------------------------------------------------
GoddessView = GoddessView or BaseClass(BaseView)

function GoddessView:__init()
	self:SetMaskBg()
	self.ui_config = {"uis/views/goddess","GoddessNewView"}
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.def_index = TabIndex.goddess_shengwu
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

-- 关闭女神面板
function GoddessView:BackOnClick()
	ViewManager.Instance:Close(ViewName.Goddess)
end

function GoddessView:__delete()
	self.tab_index = nil
end

function GoddessView:LoadCallBack()
	-- 监听UI事件
	self:ListenEvent("Close", BindTool.Bind(self.BackOnClick, self))

	self.money = MoneyBar.New()
	self.money:SetInstanceParent(self:FindObj("MoneyBar"))

	self.shengwu_view = GoddessShengWuView.New()
	local shengwu_content = self:FindObj("ShengWuView")
	shengwu_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.shengwu_view:SetInstance(obj)
	end)

	self.gongming_view = GoddessGongMingView.New()
	local gongming_content = self:FindObj("GongMingView")
	gongming_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.gongming_view:SetInstance(obj)
	end)

	self.toggle_Shengwu = self:FindObj("TabShengWu")
	self.toggle_Gongming = self:FindObj("TabGongMing")

	self.toggle_Shengwu.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.goddess_shengwu))
	self.toggle_Gongming.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.goddess_gongming))

	self.red_point_list = {
		[RemindName.Goddess_FaZhe] = self:FindVariable("FaZeRed"),
		[RemindName.Goddess_GongMing] = self:FindVariable("GongMingRed"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
	self:CheckTabIsHide()

	self:Flush()
end

function GoddessView:RemindChangeCallBack(remind_name, num)
	if self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function GoddessView:OnToggleChange(index, ison)
	if ison then
		self:ChangeToIndex(index)
	end
end

function GoddessView:ShowIndexCallBack(index)
	if index == TabIndex.goddess_shengwu then
		self.toggle_Shengwu.toggle.isOn = true

	elseif index == TabIndex.goddess_gongming then
		self.toggle_Gongming.toggle.isOn = true
	end

	self:Flush()
end

function GoddessView:CheckTabIsHide()
	if not self:IsOpen() then return end

	self.toggle_Shengwu:SetActive(OpenFunData.Instance:CheckIsHide("goddess"))
	self.toggle_Gongming:SetActive(OpenFunData.Instance:CheckIsHide("goddess"))
end

function GoddessView:GetGoddessShengWuAllView()
	return self.shengwu_content_all_view
end

function GoddessView:Open(index)
	BaseView.Open(self, index)
end

function GoddessView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Goddess)
	end

	if self.shengwu_view then
		self.shengwu_view:DeleteMe()
		self.shengwu_view = nil
	end
	if self.gongming_view then
		self.gongming_view:DeleteMe()
		self.gongming_view = nil
	end

	if self.money then
		self.money:DeleteMe()
		self.money = nil
	end

	-- 清理变量和对象
	self.btn_close = nil
	self.toggle_list = nil
	self.diamond = nil
	self.bind_gold = nil
	self.red_point_list = nil
	self.toggle_Shengwu = nil
	self.toggle_Gongming = nil

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
end

function GoddessView:CloseCallBack()
	
end

function GoddessView:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if k == "all" then
			if self.show_index == TabIndex.goddess_shengwu then
				if self.shengwu_view then
					self.shengwu_view:Flush()
				end
			elseif self.show_index == TabIndex.goddess_gongming then
				if self.gongming_view then
					self.gongming_view:Flush()
				end
			end
		elseif k == "shengwu_fly" then
			if self.shengwu_view then
				self.shengwu_view:ShowShengWuViewFly()
			end
		end
	end

end
