require("game/marriage/equip/marry_equip_info_view")
require("game/marriage/equip/marry_equip_suit_view")
require("game/marriage/equip/marry_equip_recyle_info_view")

MarryEquipContentView = MarryEquipContentView or BaseClass(BaseRender)

function MarryEquipContentView:__init(instance, mother_view)
	self.tab_index = TabIndex.marriage_equip_equip
end

function MarryEquipContentView:LoadCallBack()
	self.equip_toggle = self:FindObj("Tab1").toggle
	self.suit_toggle = self:FindObj("Tab2").toggle
	self.recyle_toggle = self:FindObj("Tab3").toggle

	local marry_equip = self:FindObj("EquipView")
	self.equip_view = MarryEquipInfoView.New()
	marry_equip.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.equip_view:SetInstance(obj)
	end)

	local equip_suit = self:FindObj("SuitView")
	self.suit_view = MarryEquipSuitView.New()
	equip_suit.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.suit_view:SetInstance(obj)
	end)

	local recyle_view = self:FindObj("RecyleView")
	self.recyle_view = MarryEquipReclyeInfoView.New()
	recyle_view.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.recyle_view:SetInstance(obj)
	end)

	self.equip_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_equip_equip))
	self.suit_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_equip_suit))
	self.recyle_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.marriage_equip_recyle))

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)

	self.red_point_list = {
		[RemindName.MarryEquip] = self:FindVariable("ShowRed1"),
		[RemindName.MarrySuit] = self:FindVariable("ShowRed2"),
		[RemindName.MarryEquipRecyle] = self:FindVariable("ShowRed3"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end


function MarryEquipContentView:FlushView()
	if self.tab_index == TabIndex.marriage_equip_equip and self.equip_view then
		self.equip_view:Flush()
	elseif self.tab_index == TabIndex.marriage_equip_suit and self.suit_view then
		self.suit_view:Flush()
	elseif self.tab_index == TabIndex.marriage_equip_recyle and self.recyle_view then
		self.recyle_view:Flush()
	end
end

function MarryEquipContentView:RemindChangeCallBack(remind_name, num)
	if self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function MarryEquipContentView:__delete()
	if self.suit_view then
		self.suit_view:DeleteMe()
		self.suit_view = nil
	end

	if self.equip_view then
		self.equip_view:DeleteMe()
		self.equip_view = nil
	end

	if self.recyle_view then
		self.recyle_view:DeleteMe()
		self.recyle_view = nil
	end

	self.red_point_list = nil

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
end


function MarryEquipContentView:ShowOrHideTab()

end

function MarryEquipContentView:OnToggleChange(index, is_on)
	if is_on then
		self.tab_index = index
		if self.tab_index == TabIndex.marriage_equip_equip and self.equip_view then
			self.equip_view:OpenCallBack()
		elseif self.tab_index == TabIndex.marriage_equip_suit and self.suit_view then
			MarryEquipCtrl.SendActiveLoverEquipInfo()
			self.suit_view:OpenCallBack()
		elseif self.tab_index == TabIndex.marriage_equip_recyle and self.recyle_view then
			MarryEquipCtrl.SendActiveLoverEquipInfo()
			self.recyle_view:OpenCallBack()
		end
	end
end

function MarryEquipContentView:OpenCallBack()
	MarryEquipCtrl.SendActiveLoverEquipInfo()
	if self.tab_index == TabIndex.marriage_equip_equip and self.equip_view then
		self.equip_toggle.isOn = true
		self.equip_view:OpenCallBack()
	elseif self.tab_index == TabIndex.marriage_equip_suit and self.suit_view then
		self.suit_toggle.isOn = true
		self.suit_view:OpenCallBack()
	elseif self.tab_index == TabIndex.marriage_equip_recyle and self.recyle_view then
		self.recyle_toggle.isOn = true
		self.recyle_view:OpenCallBack()
	end
end

function MarryEquipContentView:OnFlush(param_t)
	if self.tab_index == TabIndex.marriage_equip_equip and self.equip_view then
		self.equip_view:Flush()
	elseif self.tab_index == TabIndex.marriage_equip_suit and self.suit_view then
		self.suit_view:Flush()
	elseif self.tab_index == TabIndex.marriage_equip_recyle and self.recyle_view then
		self.recyle_view:Flush()
	end
end

function MarryEquipContentView:SetShowIndex(table_index)
	self.tab_index = table_index or TabIndex.marriage_equip_equip
end

-- function MarryEquipContentView:UpdateRemind()
-- 	local remind_m = RemindManager.Instance
-- 	self.red_point_1:SetValue(remind_m:GetRemind(RemindName.MarryEquip) > 0)
-- 	self.red_point_2:SetValue(remind_m:GetRemind(RemindName.MarrySuit) > 0)
-- 	self.red_point_3:SetValue(remind_m:GetRemind(RemindName.MarryEquipRecyle) > 0)
-- end