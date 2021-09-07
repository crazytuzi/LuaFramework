TipsGeneralAttrSmallView = TipsGeneralAttrSmallView or BaseClass(BaseView)

function TipsGeneralAttrSmallView:__init()
	self.ui_config = {"uis/views/tips/attrtips", "GeneralAttrSmallTip"}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)

	self.attr_data = {}
end

function TipsGeneralAttrSmallView:LoadCallBack()
	self.fight_power = self:FindVariable("FightPower")
	self:ListenEvent("OnClickClose",BindTool.Bind(self.OnCloseClick, self))
	self.view_name = self:FindVariable("ViewName")

	self.attr_list = {}
	for i = 1, 7 do
		self.attr_list[i] = {}
		self.attr_list[i].render = GeneralAttrRender.New(self:FindObj("Attr" .. i))
		self.attr_list[i].show = self:FindVariable("ShowAttr" .. i)
	end
end

function TipsGeneralAttrSmallView:ReleaseCallBack()
	if self.attr_list ~= nil then
		for k,v in pairs(self.attr_list) do
			if v ~= nil and v.render ~= nil then
				v.render:DeleteMe()
			end
		end

		self.attr_list = {}
	end

	self.fight_power = nil
	self.view_name = nil
	self.name_str = nil
	self.attr_data = {}
end

function TipsGeneralAttrSmallView:ShowIndexCallBack()
	self:Flush()
end

function TipsGeneralAttrSmallView:SetData(attr_data, view_name)
	self.attr_data = attr_data
	self.name_str = view_name
	--self.attr_data = {}
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

function TipsGeneralAttrSmallView:OnFlush()
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

	if self.attr_list ~= nil and self.attr_data ~= nil then
		for k,v in pairs(self.attr_list) do
			if self.attr_data[k] ~= nil then
				if v.render ~= nil then
					v.render:SetData(self.attr_data[k])
				end

				if v.show ~= nil then
					v.show:SetValue(true)
				end
			else
				if v.show ~= nil then
					v.show:SetValue(false)
				end				
			end
		end
	end

	if self.view_name ~= nil then
		self.view_name:SetValue(self.name_str or Language.JingLing.AttrTipTitle)
	end
end

function TipsGeneralAttrSmallView:OnCloseClick()
	self:Close()
end

