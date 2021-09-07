GoddessGongMingUpView = GoddessGongMingUpView or BaseClass(BaseView)

local GODDRESS_GM_UP_ID_1 = 0   --显示属性
local GODDRESS_GM_UP_ID_2 = 1   --显示提升概率
local GODDRESS_GM_UP_ID_3 = 2   --显示持续时间
local GODDRESS_GM_UP_ID_4 = 3   --显示总属性
local GODDRESS_GM_UP_ID_5 = 4   --显示技能伤害
local GODDRESS_GM_UP_ID_6 = 5   --显示冷却时间

function GoddessGongMingUpView:__init()
	self:SetMaskBg(true)
	self.ui_config = {"uis/views/goddess","GoddessGongMingUp"}
	self.view_layer = UiLayer.Pop

	self.title_str = ""
	self.now_level = ""
	self.total_level_name = ""
	self.attr_list = {}
	self.next_attr_list = {}
	self.play_audio = true
	self.grid_id = 0
end

function GoddessGongMingUpView:__delete()

end

function GoddessGongMingUpView:LoadCallBack()
	--获取变量
	self.now_total_des = self:FindVariable("text_now_title")		--当前等级
	self.text_now_name = self:FindVariable("text_now_name")			-- 当前兵道的名字
	self.next_total_des = self:FindVariable("text_next_title")		--下一级等级
	self.NowPower = self:FindVariable("NowPower")				--当前战力
	self.NextPower = self:FindVariable("NextPower")				--下装战力
	self.is_show_next_cap = self:FindVariable("is_show_next_cap")				--下装战力
	self.text_show_lingye = self:FindVariable("text_show_lingye")
	self.skill_text = self:FindVariable("skill_text")
	self.skill_icon_show = self:FindVariable("skill_icon_show")
	self.skill_icon = self:FindVariable("skill_icon")

	self.cur_gongji = self:FindVariable("cur_gongji")
	self.next_gongji = self:FindVariable("next_gongji")

	self.text_now_att2_show = self:FindVariable("text_now_att2_show")
	self.text_next_att2_show = self:FindVariable("text_next_att2_show")
	self.is_show_now = self:FindVariable("is_show_now")
	self.is_show_next = self:FindVariable("is_show_next")

	self.btn_show = self:FindVariable("btn_show")
	self.btn_text_show = self:FindVariable("btn_text_show")

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("BtnUpOnClick", BindTool.Bind(self.BtnUpOnClick, self))

	for i = 0, 2 do
		self["is_show_icon" .. i] = self:FindVariable("is_show_icon" .. i)
		self["icon_bg" .. i] = self:FindVariable("icon_bg" .. i)
		self["icon_level" .. i] = self:FindVariable("icon_level" .. i)
	end

	self:InitEffect()
end

function GoddessGongMingUpView:ReleaseCallBack()
	-- 清理变量和对象
	self.now_total_des = nil
	self.text_now_name = nil
	self.next_total_des = nil
	self.text_show_lingye = nil
	self.NowPower = nil
	self.NextPower = nil
	self.btn_show = nil
	self.btn_text_show = nil

	self.text_now_att2_show = nil
	self.text_next_att2_show = nil
	self.is_show_now = nil
	self.is_show_next = nil

	self.cur_gongji = nil
	self.next_gongji = nil
	self.grid_id = 0

	self.eff_obj = nil
	self.effect = nil

	self.skill_text = nil
	self.skill_icon_show = nil
	self.skill_icon = nil
	self.is_show_next_cap = nil

	for i = 0, 2 do
		self["is_show_icon" .. i] = nil
		self["icon_bg" .. i] = nil
		self["icon_level" .. i] = nil
	end
end


function GoddessGongMingUpView:SetGridId(id)
	self.grid_id = id
end

function GoddessGongMingUpView:CloseWindow()
	self:Close()
end

function GoddessGongMingUpView:BtnUpOnClick()
	local level = GoddessData.Instance:GetXiannvShengwuGridLevel(self.grid_id)
	local info_data = GoddessData.Instance:GetXianNvGridIconCfg(self.grid_id)
	local can_click = true
	if info_data then
		can_click = GoddessData.Instance:GetXianNvGridIconIsCan(info_data)
	end

	local next_data = GoddessData.Instance:GetXianNvGongMingCfg(self.grid_id, level)
	if next_data == nil then
		info_data = nil
		return
	end
	
	if next(next_data) then
		local cur_lingye = GoddessData.Instance:GetShengWuLingYeValue()
		if cur_lingye >= next_data.upgrade_need_ling and can_click then
			GoddessCtrl.Instance:SentCSXiannvShengwuReqReq(GODDESS_REQ_TYPE.UPGRADE_GRID, self.grid_id)
		elseif can_click == false then
			TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.GoddessUpTextNoClick)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.GoddessUpTextNo)
		end
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.GoddessUpTextManJi)
	end
	info_data = nil
end

function GoddessGongMingUpView:InitEffect()
	self.eff_obj = self:FindObj("Effect")

	if self.effect == nil then
  		PrefabPool.Instance:Load(AssetID("effects2/prefab/ui/ui_shuidi01_prefab", "UI_shuidi01"), function (prefab)
			if not prefab or self.effect then return end
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)
			local transform = obj.transform
			transform:SetParent(self.eff_obj.transform, false)
			self.effect = obj.gameObject
			self.effect.transform.localScale = Vector3(0.4, 0.4, 0.4)
			--self.is_loading = false
			--self.effect:SetActive(flag)
		end)		
	end
end

function GoddessGongMingUpView:CloseCallBack()
	self.title_str = ""
	self.now_level = ""
	self.total_level_name = ""
	self.attr_list = {}
	self.next_attr_list = {}
end

function GoddessGongMingUpView:OpenCallBack()
	self:Flush()
end

-- 显示属性 GODDRESS_GM_UP_ID_1 属性名字 值 
-- 显示提升概率 GODDRESS_GM_UP_ID_2 技能id 值
-- 显示时间 GODDRESS_GM_UP_ID_3 技能id 值
-- 显示总属性 GODDRESS_GM_UP_ID_4 nil 值
function GoddessGongMingUpView:GetAttrDes(data_cfg)
	local show_list = {}
	local tip_list = {
		has_skill = false,
		cap = 0,
		skill_num = 0,
		tip_text = "",
	}
	local has_index = 0
	local cap = 0

	if data_cfg == nil then
		return show_list, tip_list
	end

	local attr_list = CommonDataManager.GetAttributteNoUnderline(data_cfg)
	tip_list.cap = CommonDataManager.GetCapability(attr_list) + data_cfg.capbility

	for k, v in pairs(attr_list) do
		if v > 0 then
			has_index = has_index + 1
			show_list[1] = {index = GODDRESS_GM_UP_ID_1, value1 = k, value2 = v}
		end
	end

	if data_cfg.skill_id > 0 then
		has_index = has_index + 1
		if data_cfg.trigger_rate > 0 then
			show_list[2] = {index = GODDRESS_GM_UP_ID_2, value1 = data_cfg.skill_id, value2 = data_cfg.trigger_rate}
		elseif data_cfg.param_2 > 0 then
			show_list[2] = {index = GODDRESS_GM_UP_ID_3, value1 = data_cfg.skill_id, value2 = data_cfg.param_2}
		elseif data_cfg.param_1 > 0 then
			show_list[2] = {index = GODDRESS_GM_UP_ID_5, value1 = data_cfg.skill_id, value2 = data_cfg.param_1}
		elseif data_cfg.cool_down_s > 0 then
			show_list[2] = {index = GODDRESS_GM_UP_ID_6, value1 = data_cfg.skill_id, value2 = data_cfg.cool_down_ms}
		end

		local info_data = GoddessData.Instance:GetXianNvShengWuCfg(data_cfg.shengwu_id, 0)
		if info_data ~= nil then
			tip_list.skill_num = info_data.icon_num or 0
		end
		tip_list.tip_text = data_cfg.skill_desc
		tip_list.has_skill = true
	end
	if data_cfg.attr_percent > 0 then
		has_index = has_index + 1
		show_list[2] = {index = GODDRESS_GM_UP_ID_4, value1 = 0, value2 = data_cfg.attr_percent}
	end

	return show_list, tip_list
end

function GoddessGongMingUpView:UpdataTitleShow(color, level)
	local show_num = 0
	local img_str = "gongming_"
	if self.grid_id == GODDRESS_XIANNV_GRID_ID_12 then
		show_num = 2
		img_str = "gongming_s_"
	elseif self.grid_id == GODDRESS_XIANNV_GRID_ID_25 or 
		self.grid_id == GODDRESS_XIANNV_GRID_ID_26 or
		self.grid_id == GODDRESS_XIANNV_GRID_ID_27 or
		self.grid_id == GODDRESS_XIANNV_GRID_ID_28 then
		show_num = 1
		img_str = "gongming_t_"
	end

	local color = color
	if level == 0 then
		color = 0
	end

	if show_num == 2 then
		self["is_show_icon2"]:SetValue(true)
		self["is_show_icon1"]:SetValue(false)
		self["is_show_icon0"]:SetValue(false)
		self["icon_bg2"]:SetAsset(ResPath.GetGoddessRes(img_str .. color))
		self["icon_level2"]:SetValue(level)
	elseif show_num == 1 then
		self["is_show_icon2"]:SetValue(false)
		self["is_show_icon1"]:SetValue(true)
		self["is_show_icon0"]:SetValue(false)
		self["icon_bg1"]:SetAsset(ResPath.GetGoddessRes(img_str .. color))
		self["icon_level1"]:SetValue(level)
	else
		self["is_show_icon2"]:SetValue(false)
		self["is_show_icon1"]:SetValue(false)
		self["is_show_icon0"]:SetValue(true)
		self["icon_bg0"]:SetAsset(ResPath.GetGoddessRes(img_str .. color))
		self["icon_level0"]:SetValue(level)
	end
end

function GoddessGongMingUpView:OnFlush()
	local level = GoddessData.Instance:GetXiannvShengwuGridLevel(self.grid_id)
	local now_data = GoddessData.Instance:GetXianNvGongMingCfg(self.grid_id, level)
	local next_data = GoddessData.Instance:GetXianNvGongMingCfg(self.grid_id, level + 1)
	local line_data = GoddessData.Instance:GetGridLineCfg(self.grid_id)

	if nil == next(now_data) then
		return
	end

	self:UpdataTitleShow(now_data.color, level)

	local text_show = ""
	if line_data ~= nil then
		text_show = line_data.grid_text or ""
	end
	self.skill_text:SetValue(text_show)

	local has_next = next_data and true or false

	-- 设置下级属性的显示
	local show_next_text = ""
	local show_next_text_2 = ""
	local next_attr_name = ""

	-- 显示0级属性的显示
	local has_next_index_2 = false
	local show_one_text = "0"
	local show_one_text_2 = "0"
	local show_one_value1 = ""
	local one_next_index = 0
	
	local one_skill_has = false
	local one_skill_num = 0
	local one_skill_desk = ""
	local next_value = 0
	local next_list, tip_list = self:GetAttrDes(next_data)
	if has_next == false then
		self.next_gongji:SetValue("")
		self.next_total_des:SetValue(string.format(Language.Goddess.GoddessUpTextTitle, level, now_data.name or ""))
		self.text_next_att2_show:SetValue(Language.Goddess.GoddessUpTextManJi)
		self.is_show_next_cap:SetValue(false)
	else
		self.is_show_next_cap:SetValue(true)
		one_skill_num = tip_list.skill_num
		one_skill_desk = tip_list.tip_text
		one_skill_has = tip_list.has_skill

		self.next_total_des:SetValue(string.format(Language.Goddess.GoddessUpTextTitle, level + 1, next_data.name or ""))
		if next_list[1] ~= nil then
			local next_index = next_list[1].index
			local next_value1 = next_list[1].value1
			local is_per_tan_thu = "per_pofang" == next_value1 or "per_mianshang" == next_value1 or "attr_percent" == next_value1
				or "per_pvp_hurt_increase" == next_value1 or "per_pvp_hurt_reduce" == next_value1 	-- 是否万分比属性
			local next_value2 = is_per_tan_thu and next_list[1].value2 / 100 .. "%" or next_list[1].value2
			next_value = is_per_tan_thu and next_list[1].value2  / 10000 or next_list[1].value2
			one_next_index = next_index
			if next_index == GODDRESS_GM_UP_ID_1 then
				next_attr_name = CommonDataManager.GetAttrName(next_value1)
				local asset, bundle = ResPath.GetBaseAttrIcon(CommonDataManager.GetAttrName(next_value1))
				if next_value1 == "goddess_gongji" or next_value1 == "constant_mianshang" then
					next_attr_name = Language.Common.AttrNameNoUnderlineGoddess[next_value1]
				end

				show_next_text = string.format(Language.Goddess.GoddessUpText1, next_attr_name, next_value2)
				show_one_text = string.format(Language.Goddess.GoddessUpText1, next_attr_name, 0)
				show_one_value1 = next_value1
				self.next_gongji:SetValue(show_next_text)
			end
		end

		if next_list[2] ~= nil then
			has_next_index_2 = true
			local next_index_2 = next_list[2].index
			local next_value1_2 = next_list[2].value1
			local next_value2_2 = next_list[2].value2
			if next_index_2 == GODDRESS_GM_UP_ID_2 then
				next_attr_name = GoddessData.Instance:GetXianNvShengWuSkillName(next_value1_2)
				local show_next_value = self:GetFormatStr(1, (tonumber(next_value2_2) / 100))
				show_one_text_2 = string.format(Language.Goddess.GoddessUpText2, next_attr_name, 0) .. "%"
				show_next_text_2 = string.format(Language.Goddess.GoddessUpText2, next_attr_name, show_next_value) .. "%"
			elseif next_index_2 == GODDRESS_GM_UP_ID_3 then
				next_attr_name = GoddessData.Instance:GetXianNvShengWuSkillName(next_value1_2)
				show_one_text_2 = string.format(Language.Goddess.GoddessUpText3, next_attr_name, 0)
				local show_next_value = self:GetFormatStr(2, (tonumber(next_value2_2) / 100))
				show_next_text_2 = string.format(Language.Goddess.GoddessUpText3, next_attr_name, show_next_value)
			elseif next_index_2 == GODDRESS_GM_UP_ID_4 then
				local show_next_value = self:GetFormatStr(1, (tonumber(next_value2_2) / 100))
				show_next_text_2 = string.format(Language.Goddess.GoddessUpText4, show_next_value) .. "%"
				show_one_text_2 = string.format(Language.Goddess.GoddessUpText4, 0) .. "%"
			elseif next_index_2 == GODDRESS_GM_UP_ID_5 then
				next_attr_name = GoddessData.Instance:GetXianNvShengWuSkillName(next_value1_2)
				show_one_text_2 = string.format(Language.Goddess.GoddessUpText5, next_attr_name, 0)
				show_next_text_2 = string.format(Language.Goddess.GoddessUpText5, next_attr_name, next_value2_2)
			elseif next_index_2 == GODDRESS_GM_UP_ID_6 then
				next_attr_name = GoddessData.Instance:GetXianNvShengWuSkillName(next_value1_2)
				local show_next_value = self:GetFormatStr(1, (tonumber(next_value2_2) / 100))
				show_one_text_2 = string.format(Language.Goddess.GoddessUpText6, next_attr_name, 0)
				show_next_text_2 = string.format(Language.Goddess.GoddessUpText6, next_attr_name, show_next_value)
			end
			self.text_next_att2_show:SetValue(show_next_text_2)
		else
			self.text_next_att2_show:SetValue("")
		end
	end

	-- 设置当前属性的显示
	local now_list, now_tip_list = self:GetAttrDes(now_data)
	local index = -1
	local value1 = 0
	local value2 = 0
	local cur_value = 0
	local show_now_text = ""
	local attr_name = ""
	if now_list[1] ~= nil then
		index = now_list[1].index
		value1 = now_list[1].value1
		local is_per_tan_thu = "per_pofang" == value1 or "per_mianshang" == value1 or "attr_percent" == value1 
			or "per_pvp_hurt_increase" == value1 or "per_pvp_hurt_reduce" == value1 	-- 是否万分比属性
		value2 = is_per_tan_thu and now_list[1].value2 / 100 .. "%" or now_list[1].value2
		cur_value = is_per_tan_thu and now_list[1].value2 / 10000 or now_list[1].value2
	end
	self.now_total_des:SetValue(string.format(Language.Goddess.GoddessUpTextTitle, level, now_data.name or ""))
	self.text_now_name:SetValue(now_data.name or "")
	if index == -1 then
		if one_next_index == GODDRESS_GM_UP_ID_1 then
			self.cur_gongji:SetValue(show_one_text)
			if has_next_index_2 then
				self.text_now_att2_show:SetValue(show_one_text_2)
			else
				self.text_now_att2_show:SetValue("")
			end
		else
			self.cur_gongji:SetValue("")
			self.text_now_att2_show:SetValue(show_one_text)
		end

		-- if one_skill_has then
		-- 	self.skill_icon_show:SetValue(true)
		-- 	self.skill_icon:SetAsset(ResPath.GetGoddessRes("goddess_shengwu_skill_" .. one_skill_num))
		-- 	self.skill_text:SetValue(one_skill_desk)	
		-- else
		-- 	self.skill_icon_show:SetValue(false)
		-- 	self.skill_text:SetValue("")
		-- end
		self.NowPower:SetValue("0")
	else
		-- if now_tip_list.has_skill then
		-- 	self.skill_icon_show:SetValue(true)
		-- 	self.skill_icon:SetAsset(ResPath.GetGoddessRes("goddess_shengwu_skill_" .. now_tip_list.skill_num))
		-- 	self.skill_text:SetValue(now_tip_list.tip_text)	
		-- else
		-- 	self.skill_icon_show:SetValue(false)
		-- 	self.skill_text:SetValue("")
		-- end
		local attr = GoddessData.Instance:GetXiannvGridTotalAttr()
		local attribute = CommonDataManager.GetAttributteNoUnderline(attr)
		local fight_power = CommonDataManager.GetCapability(attribute)
		local power = math.ceil(cur_value * fight_power)
		local next_power = math.ceil(next_value * fight_power)
		self.NowPower:SetValue(self.grid_id == 12 and power or now_tip_list.cap)
		self.NextPower:SetValue(self.grid_id == 12 and next_power or tip_list.cap)
		if now_list[1] ~= nil then
			if index == GODDRESS_GM_UP_ID_1 then
				attr_name = CommonDataManager.GetAttrName(value1)
				local asset, bundle = ResPath.GetBaseAttrIcon(CommonDataManager.GetAttrName(value1))
				if value1 == "goddess_gongji" or value1 == "constant_mianshang" then
					attr_name = Language.Common.AttrNameNoUnderlineGoddess[value1]
				end
				show_now_text = string.format(Language.Goddess.GoddessUpText1, attr_name, value2)
				self.cur_gongji:SetValue(show_now_text)
			end
		end
		if now_list[2] ~= nil then
			local index_2 = now_list[2].index
			local value1_2 = now_list[2].value1
			local value2_2 = now_list[2].value2

			if index_2 == GODDRESS_GM_UP_ID_2 then
				local show_value = self:GetFormatStr(1, (tonumber(value2_2) / 100))
				attr_name = GoddessData.Instance:GetXianNvShengWuSkillName(value1_2)
				show_now_text = string.format(Language.Goddess.GoddessUpText2, attr_name, show_value) .. "%"
			elseif index_2 == GODDRESS_GM_UP_ID_3 then
				attr_name = GoddessData.Instance:GetXianNvShengWuSkillName(value1_2)
				local show_value = self:GetFormatStr(2, (tonumber(value2_2) / 100))
				show_now_text = string.format(Language.Goddess.GoddessUpText3, attr_name, show_value)
			elseif index_2 == GODDRESS_GM_UP_ID_4 then
				local show_value = self:GetFormatStr(1, (tonumber(value2_2) / 100))
				show_now_text = string.format(Language.Goddess.GoddessUpText4, show_value) .. "%"
			elseif index_2 == GODDRESS_GM_UP_ID_5 then
				attr_name = GoddessData.Instance:GetXianNvShengWuSkillName(value1_2)
				show_now_text = string.format(Language.Goddess.GoddessUpText5, attr_name, value2_2)
			elseif index_2 == GODDRESS_GM_UP_ID_6 then
				local show_value = self:GetFormatStr(1, (tonumber(value2_2) / 100))
				attr_name = GoddessData.Instance:GetXianNvShengWuSkillName(value1_2)
				show_now_text = string.format(Language.Goddess.GoddessUpText6, attr_name, show_value)
			end
			self.text_now_att2_show:SetValue(show_now_text)
		end
	end

	-- 设置按钮材料显示
	if has_next == false then
		self.text_show_lingye:SetValue("--")
		self.btn_show:SetValue(false)
		self.btn_text_show:SetValue(Language.Goddess.GoddessUpTextManJi)
	else
		self.btn_show:SetValue(true)
		self.btn_text_show:SetValue(Language.Goddess.GoddessUpTextShengJi)
		local cur_lingye = GoddessData.Instance:GetShengWuLingYeValue()
		local show_color = TEXT_COLOR.GREEN_6
		if cur_lingye < now_data.upgrade_need_ling then
			show_color = TEXT_COLOR.RED
		end
		local show_lingye = ToColorStr(cur_lingye, show_color) 
		self.text_show_lingye:SetValue(show_lingye .. "/" .. now_data.upgrade_need_ling)
	end
end

function GoddessGongMingUpView:GetFormatStr(value_num, value)
	local read_str = "0"
	if value == math.floor(value) then
		read_str = tostring(value)
	else
		read_str = string.format("%0." .. value_num .. "f", value)
	end

	return read_str
end