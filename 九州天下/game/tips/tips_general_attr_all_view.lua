TipsGeneralAttrAllView = TipsGeneralAttrAllView or BaseClass(BaseView)

function TipsGeneralAttrAllView:__init()
	self.ui_config = {"uis/views/tips/attrtips", "GeneralAttrAllTip"}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)

	self.attr_data = {}
end

function TipsGeneralAttrAllView:LoadCallBack()
	self.fight_power = self:FindVariable("FightPower")
	self:ListenEvent("OnClickClose",BindTool.Bind(self.OnCloseClick, self))
	self.view_name = self:FindVariable("ViewName")

	self.attr_cell_list = {}
	self.attr_list = self:FindObj("ListView")
	local name_view_delegate = self.attr_list.list_simple_delegate
	--生成数量
	name_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetAttrListNumber, self)
	--刷新函数
	name_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshAttrListView, self)
end

function TipsGeneralAttrAllView:ReleaseCallBack()
	if self.attr_cell_list ~= nil then
		for k,v in pairs(self.attr_cell_list) do
			if v ~= nil then
				v:DeleteMe()
			end
		end

		self.attr_cell_list = {}
	end

	self.fight_power = nil
	self.attr_list = nil
	self.view_name = nil
	self.name_str = nil
	self.attr_data = {}
end

function TipsGeneralAttrAllView:ShowIndexCallBack()
	self:Flush()
end

function TipsGeneralAttrAllView:SetData(attr_data, view_name)
	self.attr_data = attr_data
	self.name_str = view_name
	-- self.attr_data = {}
	-- local attr = CommonDataManager.GetAttributteNoUnderline(attr_data)
	-- local sort_list = CommonDataManager.no_line_sort_list
	-- for k,v in pairs(attr) do
	-- 	--if v > 0 then
	-- 		table.insert(self.attr_data, {key = k, value = v, sort = sort_list[k] or 0})
	-- 	--end
	-- end

	-- function sort_attr(a, b)
	-- 	return a.sort < b.sort
	-- end

	-- table.sort(self.attr_data, sort_attr)
	self:Open()
end

function TipsGeneralAttrAllView:GetAttrListNumber()
	return #self.attr_data
end

function TipsGeneralAttrAllView:RefreshAttrListView(cell, data_index, cell_index)
	local icon_cell = self.attr_cell_list[cell]
	if icon_cell == nil then
		icon_cell = GeneralAttrRender.New(cell.gameObject)
		self.attr_cell_list[cell] = icon_cell
	end

	if self.attr_data ~= nil then
		icon_cell:SetData(self.attr_data[data_index + 1])
	end
end

function TipsGeneralAttrAllView:OnFlush()
	if self.fight_power ~= nil then
		local attribute = CommonStruct.AttributeNoUnderline()
		if self.attr_data ~= nil then
			for k,v in pairs(self.attr_data) do
				if v ~= nil and attribute[v.key] ~= nil then
					attribute[v.key] = attribute[v.key] + v.value
				end
			end
		end

		self.fight_power:SetValue(CommonDataManager.GetCapability(attribute))
	end

	self.attr_list.scroller:ReloadData(0)
	--local obj = self.attr_list:GetComponent(typeof(UnityEngine.UI.LayoutElement))
	if self.view_name ~= nil then
		self.view_name:SetValue(self.name_str or Language.JingLing.AttrTipTitle)
	end
end

function TipsGeneralAttrAllView:OnCloseClick()
	self:Close()
end


---------------------------------------------------------------
GeneralAttrRender = GeneralAttrRender or BaseClass(BaseRender)
function GeneralAttrRender:__init(instance)
	self.name = self:FindVariable("Name")
	self.value = self:FindVariable("Value")
end

function GeneralAttrRender:__delete()
end

function GeneralAttrRender:SetData(data)
	self.data = data
	self:Flush()
end

function GeneralAttrRender:OnFlush()
	if self.data == nil or next(self.data) == nil then
		return
	end

	if self.name ~= nil then
		if Language.Common.AttrNameNoUnderline[self.data.key] ~= nil then
			self.name:SetValue(Language.Common.AttrNameNoUnderline[self.data.key] .. ":" or "")
		end
	end

	if self.value ~= nil then
		local check_value = math.floor(self.data.value)
		local begin = string.find(self.data.key, "^per")
		if begin then
			check_value = self.data.value * 0.01
			check_value = tostring(check_value) .. "%"
		end
		self.value:SetValue(tostring(check_value))
	end
end	
