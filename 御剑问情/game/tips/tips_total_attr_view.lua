TipsTotalAttrView = TipsTotalAttrView or BaseClass(BaseView)

function TipsTotalAttrView:__init()
	self.ui_config = {"uis/views/tips/attrtips_prefab", "TotalAttrTips"}
	self.view_layer = UiLayer.Pop

	self.title_str = ""
	self.now_level = ""
	self.total_level_name = ""
	self.attr_list = {}
	self.next_attr_list = {}
	self.play_audio = true
end

function TipsTotalAttrView:__delete()

end

function TipsTotalAttrView:LoadCallBack()
	--获取变量
	self.title_name = self:FindVariable("TitleName")			--标题
	self.have_next = self:FindVariable("HaveNext")				--是否显示下一级属性
	self.have_now = self:FindVariable("HaveNow")				--是否显示当前属性
	self.now_content = self:FindVariable("NowDes")				--现在的属性列表
	self.next_content = self:FindVariable("NextDes")			--下一级属性列表
	self.now_total_des = self:FindVariable("NowTotalDes")		--当前套装等级
	self.next_total_des = self:FindVariable("NextTotalDes")		--下一级套装等级
	self.next_level_des = self:FindVariable("NextLevelDes")		--下一级套装等级
	self.NowPower = self:FindVariable("NowPower")				--当前套装战力
	self.NextPower = self:FindVariable("NextPower")				--下级套装战力

	self.cur_maxhp = self:FindVariable("cur_maxhp")
	self.cur_gongji = self:FindVariable("cur_gongji")
	self.cur_fangyu = self:FindVariable("cur_fangyu")
	self.next_maxhp = self:FindVariable("next_maxhp")
	self.next_gongji = self:FindVariable("next_gongji")
	self.next_fangyu = self:FindVariable("next_fangyu")

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
end

function TipsTotalAttrView:ReleaseCallBack()
	-- 清理变量和对象
	self.title_name = nil
	self.have_next = nil
	self.have_now = nil
	self.now_content = nil
	self.next_content = nil
	self.now_total_des = nil
	self.next_total_des = nil
	self.next_level_des = nil
	self.NowPower = nil
	self.NextPower = nil

	self.cur_maxhp = nil
	self.cur_gongji = nil
	self.cur_fangyu = nil
	self.next_maxhp = nil
	self.next_gongji = nil
	self.next_fangyu = nil
end

function TipsTotalAttrView:CloseWindow()
	self:Close()
end

function TipsTotalAttrView:CloseCallBack()
	self.title_str = ""
	self.now_level = ""
	self.total_level_name = ""
	self.attr_list = {}
	self.next_attr_list = {}
end

function TipsTotalAttrView:OpenCallBack()
	self:Flush()
end

function TipsTotalAttrView:SetTotalLevelName(total_level_name)
	self.total_level_name = total_level_name or ""
end

function TipsTotalAttrView:SetTitleName(title_name)
	self.title_str = title_name or ""
end

function TipsTotalAttrView:SetNowLevel(level)
	self.now_level = level or ""
end

function TipsTotalAttrView:SetAttrList(list)
	self.attr_list = list or {}
end

function TipsTotalAttrView:SetNextAttrList(list)
	self.next_attr_list = list or {}
end

function TipsTotalAttrView:GetAttrDes(attr_list)
	local attr_des = ""

	local is_attr_ibutte = false		--是否进阶属性
	for k, v in pairs(attr_list) do
		if CommonDataManager.GetAdvanceAttrName(k) ~= "nil" then
			is_attr_ibutte = true
			break
		end
	end

	--生成对应属性表
	local attribute = {}
	if is_attr_ibutte then
		attribute = CommonDataManager.GetAdvanceAttributteByClass(attr_list)
	else
		attribute = CommonDataManager.GetAttributteNoUnderline(attr_list)
	end

	--开始生成文本
	for k, v in pairs(attribute) do
		local attr_name = ""
		local temp_attr_des = ""

		if v > 0 then
			if is_attr_ibutte then
				attr_name = CommonDataManager.GetAdvanceAttrName(k)
				temp_attr_des = attr_name .. ": " .. ToColorStr(v/100, TEXT_COLOR.BLUE_SPECIAL) .. "%"
			else
				attr_name = CommonDataManager.GetAttrName(k)			--先获取属性名
				temp_attr_des = attr_name .. ": " .. ToColorStr(v, TEXT_COLOR.BLUE_SPECIAL)
			end
			if attr_des == "" then
				attr_des = temp_attr_des
			else
				attr_des = attr_des .. "\n" .. temp_attr_des
			end
		end
	end

	attr_des = attr_des == "" and "无" or attr_des
	return attr_des
end

function TipsTotalAttrView:GetNextAttrDes(attr_list, is_next)
	local total_level = attr_list.total_level or attr_list.total_strength_level or attr_list.total_star or attr_list.shen_level or attr_list.level or 0

	local total_level_name = self.total_level_name ~= "" and self.total_level_name or Language.Forge.AllTotalLevel
	local suit_name = total_level_name
	local total_level = total_level.. "级"
	local now_level = ToColorStr(self.now_level .. "级", TEXT_COLOR.RED)
	local total_str = ""
	if is_next then
		total_str = "(".. now_level .. " / " .. total_level .. ")"
	else
		now_level = self.now_level .. "级"
		total_str = "(" .. now_level .. ")"
	end
	return total_level_name, total_str
end

function TipsTotalAttrView:OnFlush()
	self.title_name:SetValue(self.title_str)

	if next(self.next_attr_list) then
		self.have_next:SetValue(true)
	else
		self.have_next:SetValue(false)
	end

	if next(self.attr_list) then
		self.have_now:SetValue(true)
	else
		self.have_now:SetValue(false)
	end

	self:SetTotalLevelName(self.attr_list.name)
	--设置当前套装等级

	local now_total_des = ForgeData.Instance:GetTotalLevelDes(self.attr_list, nil, self.total_level_name, self.now_level)
	self.now_total_des:SetValue(now_total_des)
	--设置当前套装属性
	-- local now_des = self:GetAttrDes(self.attr_list)
	-- self.now_content:SetValue(now_des)
	self:SetCurAttValue()
	local now_power = CommonDataManager.GetCapabilityCalculation( self.attr_list )
	self.NowPower:SetValue(now_power)

	if next(self.next_attr_list) then
		--设置下级套装等级
		self:SetTotalLevelName(self.next_attr_list.name)
		local next_total_des, level_des = self:GetNextAttrDes(self.next_attr_list, true)
		self.next_total_des:SetValue(next_total_des)
		self.next_level_des:SetValue(level_des)
		local next_power = CommonDataManager.GetCapabilityCalculation( self.next_attr_list )
		self.NextPower:SetValue(next_power)

		--设置下级套装属性
		-- local next_des = self:GetAttrDes(self.next_attr_list)
		-- self.next_content:SetValue(next_des)
		self:SetNextAttValue()
	end
end

function TipsTotalAttrView:SetCurAttValue()
	self.cur_maxhp:SetValue(ToColorStr(self.attr_list.maxhp, TEXT_COLOR.BLUE_SPECIAL))
	self.cur_gongji:SetValue(ToColorStr(self.attr_list.gongji, TEXT_COLOR.BLUE_SPECIAL))
	self.cur_fangyu:SetValue(ToColorStr(self.attr_list.fangyu, TEXT_COLOR.BLUE_SPECIAL))
end

function TipsTotalAttrView:SetNextAttValue()
	self.next_maxhp:SetValue(ToColorStr(self.next_attr_list.maxhp, TEXT_COLOR.BLUE_SPECIAL))
	self.next_gongji:SetValue(ToColorStr(self.next_attr_list.gongji, TEXT_COLOR.BLUE_SPECIAL))
	self.next_fangyu:SetValue(ToColorStr(self.next_attr_list.fangyu, TEXT_COLOR.BLUE_SPECIAL))
end