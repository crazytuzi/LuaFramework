TipsSuitAttrView = TipsSuitAttrView or BaseClass(BaseView)

function TipsSuitAttrView:__init()
	self.ui_config = {"uis/views/tips/attrtips", "SuitAttrTips"}
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)
	self.play_audio = true
end

function TipsSuitAttrView:LoadCallBack()
	--获取变量
	self.cur_attr_list = {}
	self.next_attr_list = {}
	for i = 1, 8 do
		self.cur_attr_list[i] = {
			attr = self:FindVariable("CurAttr"..i),
			show = self:FindVariable("ShowCurAttr"..i),
		}
		self.next_attr_list[i] = {
			attr = self:FindVariable("NextAttr"..i),
			show = self:FindVariable("ShowNextAttr"..i),
		}
		self.cur_attr_list[i].attr:SetValue("")
		self.cur_attr_list[i].show:SetValue(false)
		self.next_attr_list[i].attr:SetValue("")
		self.next_attr_list[i].show:SetValue(false)
	end

	self.cur_suit_detail = self:FindVariable("NowTotalDes")
	self.next_suit_detail = self:FindVariable("NextTotalDes")
	self.cur_fight_power = self:FindVariable("NowPower")
	self.next_fight_power = self:FindVariable("NextPower")
	self.show_next_power = self:FindVariable("ShowNextPower")

	self:ListenEvent("CloseWindow", BindTool.Bind(self.Close, self))
end

function TipsSuitAttrView:ReleaseCallBack()
	-- 清理变量和对象
	self.cur_attr_list = nil
	self.next_attr_list = nil
	self.cur_suit_detail = nil
	self.next_suit_detail = nil
	self.cur_fight_power = nil
	self.next_fight_power = nil
	self.show_next_power = nil
end

function TipsSuitAttrView:SetData(cur_data, next_attr_data, cur_level)
	self.cur_attr_data = cur_data or {}
	self.next_attr_data = next_attr_data or {}
	self.cur_level = cur_level or 0
	self:Flush()
end

function TipsSuitAttrView:OnFlush()
	if (self.cur_attr_data and next(self.cur_attr_data)) or (self.next_attr_data and next(self.next_attr_data)) then

		local change_next_attr_list = CommonDataManager.GetAttributteNoUnderline(self.next_attr_data)
		if self.next_attr_data and next(self.next_attr_data) then
			local next_count = 0
			for k, v in pairs(change_next_attr_list) do
				if v > 0 then
					next_count = next_count + 1
					self.next_attr_list[next_count].show:SetValue(true)
					local next_attr_str = (Language.Common.AttrNameNoUnderline[k] or Language.Common.AttrName[k]) .. "：" .. ToColorStr(v, COLOR.WHITE)
					self.next_attr_list[next_count].attr:SetValue(next_attr_str)
				end
			end
		elseif self.cur_attr_data and next(self.cur_attr_data) then
			for i = 1, 8 do
				self.next_attr_list[i].attr:SetValue("")
				self.next_attr_list[i].show:SetValue(false)
			end
		end

		local cur_count = 0
		local change_cur_attr_list = CommonDataManager.GetAttributteNoUnderline(self.cur_attr_data)
		for k, v in pairs(change_cur_attr_list) do
			local value = change_next_attr_list[k] > 0 and change_next_attr_list[k] or v
			if value > 0 then
				cur_count = cur_count + 1
				self.cur_attr_list[cur_count].show:SetValue(true)
				local cur_attr_str = (Language.Common.AttrNameNoUnderline[k] or Language.Common.AttrName[k]) .. "：" .. ToColorStr(v, COLOR.WHITE)
				self.cur_attr_list[cur_count].attr:SetValue(cur_attr_str)
			end
		end

		local next_suit_level = ""
		if self.next_attr_data and next(self.next_attr_data) then
			next_suit_level = string.format(Language.FamousGeneral.BoneSuitNextLevel, self.cur_level, self.next_attr_data.level)
			self.show_next_power:SetValue(true)
		else
			self.show_next_power:SetValue(false)
		end

		self.cur_fight_power:SetValue(CommonDataManager.GetCapability(change_cur_attr_list))
		self.next_fight_power:SetValue(CommonDataManager.GetCapability(change_next_attr_list))

		local cur_suit_name = self.cur_attr_data.name or Language.FamousGeneral.BoneNoSuitAttr
		local cur_suit_level = string.format(Language.FamousGeneral.BoneSuitCurLevel, self.cur_level)
		local next_suit_name = self.next_attr_data.name or Language.FamousGeneral.BoneMaxSuitAttr
		
		self.cur_suit_detail:SetValue(cur_suit_name .. cur_suit_level)
		self.next_suit_detail:SetValue(next_suit_name .. next_suit_level)
	end
end