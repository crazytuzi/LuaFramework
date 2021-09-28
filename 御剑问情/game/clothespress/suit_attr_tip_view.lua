SuitAttrTipView = SuitAttrTipView or BaseClass(BaseView)

function SuitAttrTipView:__init()
	self.ui_config = {"uis/views/clothespress_prefab", "SuitAttrTipView"}
end

function SuitAttrTipView:LoadCallBack()
	self.data_index = 1

	self.sheng_ming = self:FindVariable("Hp")
	self.gong_ji = self:FindVariable("Gongji")
	self.fang_yu = self:FindVariable("Fangyu")
	self.desc = self:FindVariable("desc")
	self.fight_power = self:FindVariable("Capability")

	self:ListenEvent("Close", BindTool.Bind(self.CloseButton, self))
end

function SuitAttrTipView:ReleaseCallBack()
	self.sheng_ming = nil
	self.gong_ji = nil
	self.fang_yu = nil
	self.desc = nil
	self.fight_power = nil
end

function SuitAttrTipView:OpenCallBack()
	if self.data_list and self.data_list.attr and self.data_list.desc then
		local attr_list = self.data_list.attr
		local part_num = self.data_list.part_num
		local active_part_num = self.data_list.active_part_num
		local color = active_part_num < part_num and TEXT_COLOR.RED or TEXT_COLOR.BLACK_1
		local str = ToColorStr(active_part_num, color)
		local desc_num = "(" .. str .. " / " .. part_num .. ")"
		
		self.sheng_ming:SetValue(attr_list.sheng_ming)
		self.gong_ji:SetValue(attr_list.gong_ji)
		self.fang_yu:SetValue(attr_list.fang_yu)
		self.fight_power:SetValue(attr_list.power)
		local desc = self.data_list.desc .. "  " .. desc_num
		self.desc:SetValue(desc)
	end
end

function SuitAttrTipView:GetDataListBySuitIndex()
	self.data_list = ClothespressData.Instance:GetSuitAttrDataListBySuitIndex(self.data_index)
end

function SuitAttrTipView:CloseButton()
	self:Close()
end

function SuitAttrTipView:SetData(data_index)
	self.data_index = data_index
	self:GetDataListBySuitIndex()
	self:Open()
end