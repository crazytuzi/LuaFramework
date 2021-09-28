require("game/marriage/equip/marry_equip_info_view")

MarryEquipContentView = MarryEquipContentView or BaseClass(BaseRender)

function MarryEquipContentView:__init(instance, mother_view)
	self.tab_index = TabIndex.marriage_equip

	self.red_point_1 = self:FindVariable("ShowRed1")
	self.red_point_2 = self:FindVariable("ShowRed2")
	self.red_point_3 = self:FindVariable("ShowRed3")
	self.equip_toggle = self:FindObj("Tab1").toggle

	local marry_equip = self:FindObj("EquipView")
	UtilU3d.PrefabLoad("uis/views/marriageview_prefab", "MarryEquipView",
	function(obj)
		obj.transform:SetParent(marry_equip.transform, false)
		obj = U3DObject(obj)
		self.equip_view = MarryEquipInfoView.New(obj, self)
		self.equip_view:OpenCallBack()
	end)

	self.equip_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_equip))
end

function MarryEquipContentView:__delete()
	if self.equip_view then
		self.equip_view:DeleteMe()
		self.equip_view = nil
	end
end

function MarryEquipContentView:ShowOrHideTab()

end

function MarryEquipContentView:OnToggleChange(index, is_on)
	if is_on then
		self.tab_index = index
		if self.tab_index == TabIndex.marriage_equip and self.equip_view then
			self.equip_view:OpenCallBack()
		end
	end
end

function MarryEquipContentView:OpenCallBack()
	MarryEquipCtrl.SendActiveLoverEquipInfo()
	if self.tab_index == TabIndex.marriage_equip and self.equip_view then
		self.equip_view:OpenCallBack()
	end
	-- self:UpdateRemind()
end

function MarryEquipContentView:OnFlush(param_t)
	-- self:UpdateRemind()
	local is_open = MarryEquipCtrl.Instance:IsOpenView()
	if self.equip_view then
		if is_open then
			self.equip_view:Flush()
		else
			self.equip_view:UpdateRemind()
			MarryEquipCtrl.Instance:FlushMarryEquipSuitView()
			MarryEquipCtrl.Instance:FlushMarryEquipReclyeInfoView()
		end
	end
end

function MarryEquipContentView:UpdateRemind()
	local remind_m = RemindManager.Instance
	self.red_point_1:SetValue(remind_m:GetRemind(RemindName.MarryEquip) > 0)
	self.red_point_2:SetValue(remind_m:GetRemind(RemindName.MarrySuit) > 0)
	self.red_point_3:SetValue(remind_m:GetRemind(RemindName.MarryEquipRecyle) > 0)
end

function MarryEquipContentView:ShowOrHideView(index)
	local toggle_index = index 
	if toggle_index == TabIndex.marriage_equip then
		self.equip_toggle.isOn = true
	end
end