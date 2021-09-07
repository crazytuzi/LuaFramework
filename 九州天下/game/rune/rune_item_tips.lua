RuneItemTips = RuneItemTips or BaseClass(BaseView)
function RuneItemTips:__init()
    self.ui_config = {"uis/views/rune", "RuneItemTips"}
    self.play_audio = true
    self.view_layer = UiLayer.Pop

    self.index = -1
end

function RuneItemTips:__delete()
end

function RuneItemTips:ReleaseCallBack()
	self.name = nil
	self.level = nil
	self.type = nil
	self.attr_text_1 = nil
	self.attr_text_2 = nil
	self.show_two_attr = nil
	self.pass_des = nil
	self.image_res = nil
	self.power = nil
end

function RuneItemTips:LoadCallBack()
	self.name = self:FindVariable("Name")
	self.level = self:FindVariable("Level")
	self.type = self:FindVariable("Types")
	self.attr_text_1 = self:FindVariable("AttrText1")
	self.attr_text_2 = self:FindVariable("AttrText2")
	self.show_two_attr = self:FindVariable("ShowTwoAttr")
	self.pass_des = self:FindVariable("PassDes")
	self.image_res = self:FindVariable("ImageRes")
	self.power = self:FindVariable("Power")

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
end

function RuneItemTips:SetData(data)
	self.data = data
end

function RuneItemTips:SetCloseCallBack(callback)
	self.callback = callback
end

function RuneItemTips:OpenCallBack()
	self:FlushView()
end

function RuneItemTips:CloseCallBack()
	self.index = -1
	if self.callback then
		self.callback()
		self.callback = nil
	end
end

function RuneItemTips:CloseWindow()
	self:Close()
end

function RuneItemTips:FlushView()
	if not self.data or not next(self.data) then
		return
	end
	local quality = self.data.quality
	local types = self.data.types or self.data.type
	local level = self.data.level
	local data = RuneData.Instance:GetAttrInfo(quality, types, level)
	if not next(data) then
		return
	end

	local item_id = RuneData.Instance:GetRealId(quality, types)
	if item_id > 0 then
		self.image_res:SetAsset(ResPath.GetItemIcon(item_id))
	end

	local name = RuneData.Instance:GetRuneNameByItemId(item_id)
	local quality, types = RuneData.Instance:GetQualityTypeByItemId(item_id)
	local name_color = RUNE_COLOR[quality] or TEXT_COLOR.WHITE
	local name_des = ToColorStr(name, name_color)
	self.name:SetValue(name_des)

	self.level:SetValue(data.level)

	local types_des = Language.Rune.RuneType1
	if data.types == GameEnum.RUNE_JINGHUA_TYPE then
		types_des = Language.Rune.RuneType2
	end
	self.type:SetValue(types_des)

	local pass_layer = RuneData.Instance:GetPassLayerByItemId(item_id)
	if pass_layer > 0 then
		local pass_des = string.format(Language.Rune.PassLayerDes, pass_layer)
		self.pass_des:SetValue(pass_des)
	else
		self.pass_des:SetValue("")
	end

	self.show_two_attr:SetValue(false)
	local attr_type_name = ""
	local attr_value = 0
	if data.types == GameEnum.RUNE_JINGHUA_TYPE then
		--符文精华特殊处理
		attr_type_name = Language.Rune.JingHuaAttrName
		attr_value = data.dispose_fetch_jinghua
		local str = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
		self.attr_text_1:SetValue(str)
		self.attr_text_2:SetValue("")
		-- 设置战斗力
		self.power:SetValue(0)
		return
	end
	attr_type_name = Language.Rune.AttrName[data.attr_type1] or ""
	attr_value = data.attr_value1
	if RuneData.Instance:IsPercentAttr(data.attr_type1) then
		attr_value = (data.attr_value1/100.00) .. "%"
	end
	local attr_des = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
	self.attr_text_1:SetValue(attr_des)
	if "" ~= data.attr_type2 then
		attr_type_name = Language.Rune.AttrName[data.attr_type2] or ""
		attr_value = data.attr_value2
		if RuneData.Instance:IsPercentAttr(data.attr_type2) then
			attr_value = (data.attr_value2/100.00) .. "%"
		end
		attr_des = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
		self.attr_text_2:SetValue(attr_des)
		self.show_two_attr:SetValue(true)
	else
		self.attr_text_2:SetValue("")
	end
	--设置战斗力
	local attr_info = CommonStruct.AttributeNoUnderline()
	local attr_type1 = data.attr_type1
	local attr_type2 = data.attr_type2
	if attr_type1 then
		RuneData.Instance:CalcAttr(attr_info, attr_type1, data.attr_value1)
	end
	if attr_type2 then
		RuneData.Instance:CalcAttr(attr_info, attr_type2, data.attr_value2)
	end
	local capability = CommonDataManager.GetCapabilityCalculation(attr_info)
	self.power:SetValue(capability)
end