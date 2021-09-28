TipsSuitAttrView = TipsSuitAttrView or BaseClass(BaseView)

local ARR_DATA = {"maxhp","max_hp","hp","qixue", "gongji","gong_ji","attack",
				  "fangyu","fang_yu", "mingzhong","ming_zhong", "shanbi","shan_bi",
				  "baoji","bao_ji","jianren","jian_ren", "per_maxhp","maxhp_per",
				  "per_gongji","gongji_per", "per_pofang","pofang_per","per_mianshang","mianshang_per",
				  "per_baoji","baoji_per","per_jingzhun","jingzhun_per",
				  "goddess_gongji","fujia_shanghai","xiannv_gongji","fu_jia","fujia",
				  "constant_mianshang","mian_shang","mianshang",
				}

function TipsSuitAttrView:__init()
	self.ui_config = {"uis/views/tips/attrtips_prefab", "SuitAttrTips"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.cur_level = 0
end

function TipsSuitAttrView:__delete()

end

function TipsSuitAttrView:LoadCallBack()
	--获取变量
	self.cur_attr_list = {}
	self.next_attr_list = {}
	for i = 1, 8 do
		self.cur_attr_list[i] = {
			attr = self:FindVariable("CurAttr"..i),
			icon = self:FindVariable("CurAttrIcon"..i),
			show = self:FindVariable("ShowCurAttr"..i),
		}
		self.next_attr_list[i] = {
			attr = self:FindVariable("NextAttr"..i),
			icon = self:FindVariable("NextAttrIcon"..i),
			show = self:FindVariable("ShowNextAttr"..i),
		}
	end

	self.show_next_attr = self:FindVariable("ShowNext")
	self.show_cur_attr = self:FindVariable("ShowCur")

	self.cur_suit_detail = self:FindVariable("NowTotalDes")
	self.cur_fight_power = self:FindVariable("NowPower")
	self.next_suit_detail = self:FindVariable("NextTotalDes")
	self.next_fight_power = self:FindVariable("NextPower")

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
end

function TipsSuitAttrView:ReleaseCallBack()
	-- 清理变量和对象
	self.cur_attr_list = nil
	self.next_attr_list = nil
	self.show_next_attr = nil
	self.cur_suit_detail = nil
	self.cur_fight_power = nil
	self.next_suit_detail = nil
	self.next_fight_power = nil
	self.show_cur_attr = nil
end

function TipsSuitAttrView:CloseWindow()
	self:Close()
end

function TipsSuitAttrView:OpenCallBack()
	self:Flush()
end

function TipsSuitAttrView:SetCurAttrData(cur_data)
	self.cur_attr_data = cur_data
end

function TipsSuitAttrView:SetNextAttrData(next_attr_data)
	self.next_attr_data = next_attr_data
end

function TipsSuitAttrView:SetCurLevel(cur_level)
	self.cur_level = cur_level or 0
end

function TipsSuitAttrView:OnFlush()
	self.show_next_attr:SetValue(nil ~= self.next_attr_data)
	self.show_cur_attr:SetValue(nil ~= self.cur_attr_data)

	if type(self.cur_attr_data) ~= "table" then
		self.cur_attr_data = {}
	end
	local cur_count = 1
	local cur_attr_str = ""
	local cur_set_attr_key_list = {}
	local change_cur_attr_list = CommonDataManager.GetAttributteNoUnderline(self.cur_attr_data)

	for k, v in ipairs(ARR_DATA) do
		if change_cur_attr_list[v] then
			local attr = change_cur_attr_list[v]
			if attr > 0 then
				self.cur_attr_list[cur_count].show:SetValue(true)
				cur_attr_str = (Language.Common.AttrNameNoUnderline[v] or Language.Common.AttrName[v]).."："..ToColorStr(attr,TEXT_COLOR.BLUE_4)
				self.cur_attr_list[cur_count].attr:SetValue(cur_attr_str)
				self.cur_attr_list[cur_count].icon:SetAsset(ResPath.GetBaseAttrIcon(v))
				cur_set_attr_key_list[cur_count] = k
				cur_count = cur_count + 1
			end
		end
	end
	-- for k, v in pairs(change_cur_attr_list) do
	-- 	if v > 0 then
	-- 		self.cur_attr_list[cur_count].show:SetValue(true)
	-- 		cur_attr_str = (Language.Common.AttrNameNoUnderline[k] or Language.Common.AttrName[k]).."："..ToColorStr(v,TEXT_COLOR.BLUE_4)
	-- 		self.cur_attr_list[cur_count].attr:SetValue(cur_attr_str)
	-- 		self.cur_attr_list[cur_count].icon:SetAsset(ResPath.GetBaseAttrIcon(k))

	-- 		cur_set_attr_key_list[cur_count] = k
	-- 		cur_count = cur_count + 1
	-- 	end
	-- end

	if type(self.next_attr_data) ~= "table" then -- nil ~= self.next_attr_data and
		self.next_attr_data = {}
	end

	local next_count = 1
	local next_attr_str = ""
	local key = ""
	local change_next_attr_list = CommonDataManager.GetAttributteNoUnderline(self.next_attr_data)

	for k, v in ipairs(ARR_DATA) do
		if change_next_attr_list[v] then
			local attr = change_next_attr_list[v]
			if attr > 0 then
				key = nil ~= cur_set_attr_key_list[next_count] and cur_set_attr_key_list[next_count] or k
				self.next_attr_list[next_count].show:SetValue(true)
				next_attr_str = (Language.Common.AttrNameNoUnderline[v] or Language.Common.AttrName[v]).."："..ToColorStr(attr,TEXT_COLOR.BLUE_4)
				self.next_attr_list[next_count].attr:SetValue(next_attr_str)
				self.next_attr_list[next_count].icon:SetAsset(ResPath.GetBaseAttrIcon(v))
				next_count = next_count + 1
			end
		end
	end

	-- for k, v in pairs(change_next_attr_list) do
		-- if v > 0 then
			-- key = nil ~= cur_set_attr_key_list[next_count] and cur_set_attr_key_list[next_count] or k
			-- self.next_attr_list[next_count].show:SetValue(true)
			-- next_attr_str = (Language.Common.AttrNameNoUnderline[key] or Language.Common.AttrName[key]).."："..ToColorStr(v,TEXT_COLOR.BLUE_4)
			-- self.next_attr_list[next_count].attr:SetValue(next_attr_str)
			-- self.next_attr_list[next_count].icon:SetAsset(ResPath.GetBaseAttrIcon(key))
			-- next_count = next_count + 1
		-- end
	-- end

	local cur_cap = CommonDataManager.GetCapability(self.cur_attr_data)
	self.cur_fight_power:SetValue(cur_cap)
	local next_cap = CommonDataManager.GetCapability(self.next_attr_data)
	self.next_fight_power:SetValue(next_cap)

	local cur_suit_name = self.cur_attr_data.name or ""
	local next_suit_name = self.next_attr_data.name or ""
	-- local cur_cfg_level = string.format(Language.Mount.ShowGreenStr, self.cur_attr_data.level or 0)
	local next_cfg_level = string.format(Language.Mount.ShowBlue2Str, self.next_attr_data.level or 0)
	local colorJi = string.format(Language.Mount.ShowBlue2Str, Language.Common.Ji)

	if nil ~= next(self.cur_attr_data) then
		local temp_str = ""
		if nil ~= next(self.next_attr_data) then
			temp_str = string.format(Language.Mount.ShowRedStr, self.cur_level..Language.Common.Ji)
			next_suit_name = next_suit_name.."("..temp_str.."/"..next_cfg_level..colorJi..")"

			temp_str = string.format(Language.Mount.ShowBlue2Str, self.cur_level..Language.Common.Ji)
			cur_suit_name = cur_suit_name.."("..temp_str..")"
		else
			temp_str = string.format(Language.Mount.ShowBlue2Str, self.cur_level..Language.Common.Ji)
			cur_suit_name = cur_suit_name.."("..temp_str..")"
		end
	elseif nil ~= next(self.next_attr_data) then
		temp_str = string.format(Language.Mount.ShowRedStr, self.cur_level..Language.Common.Ji)
		next_suit_name = next_suit_name.."("..temp_str.."/"..next_cfg_level..colorJi..")"
	end

	self.cur_suit_detail:SetValue(cur_suit_name)
	self.next_suit_detail:SetValue(next_suit_name)
end