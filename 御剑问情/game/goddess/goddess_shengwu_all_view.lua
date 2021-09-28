GoddessShengWuALLView = GoddessShengWuALLView or BaseClass(BaseRender)

function GoddessShengWuALLView:__init(instance)
	self:InitView()
	self.all_view_selected_index = 0
end

function GoddessShengWuALLView:InitView()
	self.shengwu_content_go = self:FindObj("shengwu_content_view")
	if not self.shengwu_content_view then
		UtilU3d.PrefabLoad("uis/views/goddess_prefab", "ShengWuContent",
			function(obj)
				obj.transform:SetParent(self.shengwu_content_go.transform, false)
				obj = U3DObject(obj)
				self.shengwu_content_view = GoddessShengWuView.New(obj)
				self.shengwu_content_view:SetNotifyDataChangeCallBack()
				self.shengwu_content_view:Flush()
			end
		)		
	end	

	self.gongming_content_go = self:FindObj("gongming_content_view")

	self.shengwu_all_toggle_list = {}
	for i = 0, 1 do
		self.shengwu_all_toggle_list[i] = self:FindObj("shengwu_all_toggle_" .. i)
		self:ListenEvent("OnClickProfessionButton" .. i,
		BindTool.Bind2(self.OnClickProfessionButton, self, i))
	end
	self:ShowOrHideTab()

	self.faze_red = self:FindVariable("FaZeRed")
	self.gongming_red = self:FindVariable("GongMingRed")
	self:FlushRed()
end

function GoddessShengWuALLView:__delete()
	if self.shengwu_content_view then
		self.shengwu_content_view:DeleteMe()
		self.shengwu_content_view = nil
	end

	if self.gongming_content_view then
		self.gongming_content_view:DeleteMe()
		self.gongming_content_view = nil
	end

	self.shengwu_all_toggle_list = nil
	self.shengwu_content_go = nil
	self.gongming_content_go = nil

	self.faze_red = nil
	self.gongming_red = nil
end

function GoddessShengWuALLView:ShowOrHideTab()
	local show_list = {}
	local open_fun_data = OpenFunData.Instance
	show_list[1] = open_fun_data:CheckIsHide("goddess_shengwu")
	show_list[2] = open_fun_data:CheckIsHide("goddess_gongming")

	if self.shengwu_all_toggle_list[0] ~= nil and self.shengwu_all_toggle_list[1] ~= nil then
		self.shengwu_all_toggle_list[0]:SetActive(show_list[1])
		self.shengwu_all_toggle_list[1]:SetActive(show_list[2])
	end
end

-- 1为圣物，2为共鸣
function GoddessShengWuALLView:OnClickProfessionButton(index)
	self:SetAllViewIndex(index)
	self:UpdataView()
end

-- 1为圣物，2为共鸣
function GoddessShengWuALLView:SetAllViewIndex(index)
	self.all_view_selected_index = index
end

function GoddessShengWuALLView:OnSelectedView(index)
	if index == TabIndex.goddess_shengwu then
		self.all_view_selected_index = 0
		self.shengwu_all_toggle_list[1].toggle.isOn = false
	elseif index == TabIndex.goddess_gongming then
		self.all_view_selected_index = 1
		self.shengwu_all_toggle_list[0].toggle.isOn = false
	end
	if not self.shengwu_all_toggle_list[self.all_view_selected_index].toggle.isOn then
		self.shengwu_all_toggle_list[self.all_view_selected_index].toggle.isOn = true
	end

	self:UpdataView()
end

function GoddessShengWuALLView:UpdataView()
	self:ShowOrHideTab()
	if self.all_view_selected_index == 0 then
		self:UpdataShengWuView()
	end
	self:FlushRed()
end

function GoddessShengWuALLView:UpdataShengWuView()
	if self.shengwu_content_view then
		self.shengwu_content_view:Flush()
	end
end

function GoddessShengWuALLView:UpdataGongMingView()
	if self.gongming_content_view then
		self.gongming_content_view:Flush()
	end
end

function GoddessShengWuALLView:UpdataGongMingLingYe()
	if self.gongming_content_view then
		self.gongming_content_view:UpdataGongMingLingYe()
	end
end

function GoddessShengWuALLView:UpdataGongMingGrid()
	if self.gongming_content_view then
		self.gongming_content_view:UpdataGongMingGrid()
	end
end

function GoddessShengWuALLView:ShowShengWuViewFly()
	if self.shengwu_content_view then
		self.shengwu_content_view:ShowShengWuViewFly()
	end
end

function GoddessShengWuALLView:FlushRed()
	if self.faze_red ~= nil then
		self.faze_red:SetValue(GoddessData.Instance:GetFaZeRed())
	end

	if self.gongming_red ~= nil then
		self.gongming_red:SetValue(GoddessData.Instance:GetGongMingRed()) -- or GoddessData.Instance:GetGongMingGridRed()
	end
end