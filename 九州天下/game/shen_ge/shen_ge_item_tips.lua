ShenGeItemTips = ShenGeItemTips or BaseClass(BaseView)
function ShenGeItemTips:__init()
    self.ui_config = {"uis/views/shengeview", "ShenGeItemTips"}
    self.play_audio = true
    self.view_layer = UiLayer.Pop

    self.index = -1
end

function ShenGeItemTips:__delete()
end

function ShenGeItemTips:ReleaseCallBack()
	self.name = nil
	self.level = nil
	self.type = nil
	self.cur_attr_var_list = nil
	self.show_two_attr = nil
	self.show_three_attr = nil
	self.image_res = nil
	self.power = nil
	self.quality = nil
end

function ShenGeItemTips:LoadCallBack()
	self.name = self:FindVariable("Name")
	self.level = self:FindVariable("Level")
	self.type = self:FindVariable("Types")

	self.cur_attr_var_list = {}
	for i=1,3 do
		self.cur_attr_var_list[i] = {
			attr = self:FindVariable("AttrText"..i)
		}
	end

	self.show_three_attr = self:FindVariable("ShowThreeAttr")
	self.image_res = self:FindVariable("ImageRes")
	self.power = self:FindVariable("Power")
	self.quality = self:FindVariable("Quality")

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
end

function ShenGeItemTips:SetData(data)
	self.data = data
end

function ShenGeItemTips:SetCloseCallBack(callback)
	self.callback = callback
end

function ShenGeItemTips:OpenCallBack()
	self:FlushView()
end

function ShenGeItemTips:CloseCallBack()
	self.index = -1
	if self.callback then
		self.callback()
		self.callback = nil
	end
end

function ShenGeItemTips:CloseWindow()
	self:Close()
end

function ShenGeItemTips:FlushView()
	if not self.data or not next(self.data) then
		return
	end
	local data = self.data

	local item_id = ShenGeData.Instance:GetShenGeItemId(data.types, data.quality)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg.icon_id > 0 then
		self.image_res:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
	end

	local name_color = SHEN_GE_QUALITY[data.quality + 1] or TEXT_COLOR.BLUE
	local name = Language.ShenGe.AttrTypeMastre[data.types] or ""
	--local name_des = ToColorStr(name, name_color)
	self.name:SetValue(name)

	self.level:SetValue(data.level)
	self.quality:SetAsset(ResPath.GetRomeNumImage(data.quality))

	local types_des = Language.ShenGe.ShenGeType1
	if data.kind == 1 then
		types_des = Language.ShenGe.ShenGeType2
	end
	self.type:SetValue(types_des)

	self.show_three_attr:SetValue(true)
	for k,v in ipairs(self.cur_attr_var_list) do
		local attr_value = data["add_attributes_"..k-1]
		local attr_type = data["attr_type_"..k-1]
		if(attr_value > 0)then
			v.attr:SetValue(Language.ShenGe.AttrTypeName[attr_type].." +"..attr_value)
		else
			v.attr:SetValue("")
	 		self.show_three_attr:SetValue(false)
		end
	end

	-- 设置战斗力
	local attr_info = CommonStruct.AttributeNoUnderline()
	local attr_type_1 = Language.ShenGe.AttrType[data.attr_type_0]
	local attr_type_2 = Language.ShenGe.AttrType[data.attr_type_1]
	if attr_type_1 then
		RuneData.Instance:CalcAttr(attr_info, attr_type_1, data.add_attributes_0)
	end
	if attr_type_2 then
		RuneData.Instance:CalcAttr(attr_info, attr_type_2, data.add_attributes_1)
	end
	local capability = CommonDataManager.GetCapabilityCalculation(attr_info)
	self.power:SetValue(capability)
end