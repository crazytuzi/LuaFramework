GoddessGongMingUpView = GoddessGongMingUpView or BaseClass(BaseView)

local GODDRESS_GM_UP_ID_1 = 0   --显示属性
local GODDRESS_GM_UP_ID_2 = 1   --显示提升概率
local GODDRESS_GM_UP_ID_3 = 2   --显示持续时间
local GODDRESS_GM_UP_ID_4 = 3   --显示总属性
local GODDRESS_GM_UP_ID_5 = 4   --显示技能伤害
local GODDRESS_GM_UP_ID_6 = 5   --显示冷却时间

function GoddessGongMingUpView:__init()
	self.ui_config = {"uis/views/goddess_prefab","GoddessGongMingUp"}
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
	self.img_now_bg = self:FindVariable("img_now_bg")
	self.img_next_bg = self:FindVariable("img_next_bg")
	self.img_now_show = self:FindVariable("img_now_show")
	self.img_next_show = self:FindVariable("img_next_show")

	self.text_now_att2_show = self:FindVariable("text_now_att2_show")
	self.text_next_att2_show = self:FindVariable("text_next_att2_show")
	self.is_show_now = self:FindVariable("is_show_now")
	self.is_show_next = self:FindVariable("is_show_next")

	self.btn_show = self:FindVariable("btn_show")
	self.btn_text_show = self:FindVariable("btn_text_show")

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("BtnUpOnClick", BindTool.Bind(self.BtnUpOnClick, self))

	--self:InitEffect()
end

function GoddessGongMingUpView:ReleaseCallBack()
	-- 清理变量和对象
	self.now_total_des = nil
	self.next_total_des = nil
	self.text_show_lingye = nil
	self.NowPower = nil
	self.NextPower = nil
	self.img_now_bg = nil
	self.img_next_bg = nil
	self.img_now_show = nil
	self.img_next_show = nil
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
  		PrefabPool.Instance:Load(AssetID("effects/prefabs", "UI_shuidi01"), function (prefab)
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

	local attr_list = CommonDataManager.GetGoddessAttributteNoUnderline(data_cfg)
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
		elseif data_cfg.cool_down_ms > 0 then
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

function GoddessGongMingUpView:OnFlush()
	local level = GoddessData.Instance:GetXiannvShengwuGridLevel(self.grid_id)
	local now_data = GoddessData.Instance:GetXianNvGongMingCfg(self.grid_id, level)
	local next_data = GoddessData.Instance:GetXianNvGongMingCfg(self.grid_id, level + 1)
	if nil == next(now_data) then
		return
	end

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

	if has_next == false then
		self.img_next_show:SetValue(false)
		self.next_gongji:SetValue("")
		self.next_total_des:SetValue("")
		self.text_next_att2_show:SetValue(Language.Goddess.GoddessUpTextManJi)
		self.is_show_next_cap:SetValue(false)
	else
		local next_list, tip_list = self:GetAttrDes(next_data)
		self.is_show_next_cap:SetValue(true)
		self.NextPower:SetValue(tip_list.cap)
		one_skill_num = tip_list.skill_num
		one_skill_desk = tip_list.tip_text
		one_skill_has = tip_list.has_skill

		self.next_total_des:SetValue(string.format(Language.Goddess.GoddessUpTextTitle, level + 1, next_data.name or ""))
		if next_list[1] ~= nil then
			local next_index = next_list[1].index
			local next_value1 = next_list[1].value1
			local next_value2 = next_list[1].value2
			one_next_index = next_index
			if next_index == GODDRESS_GM_UP_ID_1 then
				next_attr_name = CommonDataManager.GetAttrName(next_value1)
				local asset, bundle = ResPath.GetBaseAttrIcon(CommonDataManager.GetAttrName(next_value1))
				if next_value1 == "goddess_gongji" or next_value1 == "constant_mianshang" then
					next_attr_name = Language.Common.AttrNameNoUnderlineGoddess[next_value1]
					local str = next_value1 == "goddess_gongji" and "shanghai" or "shjm"
					asset, bundle = ResPath.GetImages("icon_info_" .. str, "icon_atlas")
				end

				show_next_text = string.format(Language.Goddess.GoddessUpText1, next_attr_name, next_value2)
				show_one_text = string.format(Language.Goddess.GoddessUpText1, next_attr_name, 0)
				show_one_value1 = next_value1
				self.img_next_show:SetValue(true)
				self.img_next_bg:SetAsset(asset, bundle)
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
	local show_now_text = ""
	local attr_name = ""
	if now_list[1] ~= nil then
		index = now_list[1].index
		value1 = now_list[1].value1
		value2 = now_list[1].value2
	end
	self.now_total_des:SetValue(string.format(Language.Goddess.GoddessUpTextTitle, level, now_data.name or ""))
	if index == -1 then
		if one_next_index == GODDRESS_GM_UP_ID_1 then
			self.cur_gongji:SetValue(show_one_text)
			if show_one_value1 ~= nil then
				local asset, bundle = ResPath.GetBaseAttrIcon(CommonDataManager.GetAttrName(show_one_value1))
				if show_one_value1 == "goddess_gongji" or show_one_value1 == "constant_mianshang" then
					attr_name = Language.Common.AttrNameNoUnderlineGoddess[show_one_value1]
					local str = show_one_value1 == "goddess_gongji" and "shanghai" or "shjm"
					asset, bundle = ResPath.GetImages("icon_info_" .. str, "icon_atlas")
				end

				self.img_now_show:SetValue(true)
				self.img_now_bg:SetAsset(asset, bundle)
			else
				self.img_now_show:SetValue(false)
			end
			if has_next_index_2 then
				self.text_now_att2_show:SetValue(show_one_text_2)
			else
				self.text_now_att2_show:SetValue("")
			end
		else
			self.img_now_show:SetValue(false)
			self.cur_gongji:SetValue("")
			self.text_now_att2_show:SetValue(show_one_text)
		end

		if one_skill_has then
			self.skill_icon_show:SetValue(true)
			self.skill_icon:SetAsset(ResPath.GetGoddessRes("goddess_shengwu_skill_" .. one_skill_num))
			self.skill_text:SetValue(one_skill_desk)	
		else
			self.skill_icon_show:SetValue(false)
			self.skill_text:SetValue("")
		end
		self.NowPower:SetValue("0")
	else
		if now_tip_list.has_skill then
			self.skill_icon_show:SetValue(true)
			self.skill_icon:SetAsset(ResPath.GetGoddessRes("goddess_shengwu_skill_" .. now_tip_list.skill_num))
			self.skill_text:SetValue(now_tip_list.tip_text)	
		else
			self.skill_icon_show:SetValue(false)
			self.skill_text:SetValue("")
		end
		self.NowPower:SetValue(now_tip_list.cap)

		if now_list[1] ~= nil then
			if index == GODDRESS_GM_UP_ID_1 then
				attr_name = CommonDataManager.GetAttrName(value1)
				local asset, bundle = ResPath.GetBaseAttrIcon(CommonDataManager.GetAttrName(value1))
				if value1 == "goddess_gongji" or value1 == "constant_mianshang" then
					attr_name = Language.Common.AttrNameNoUnderlineGoddess[value1]
					local str = value1 == "goddess_gongji" and "shanghai" or "shjm"
					asset, bundle = ResPath.GetImages("icon_info_" .. str, "icon_atlas")
				end
				show_now_text = string.format(Language.Goddess.GoddessUpText1, attr_name, value2)
				self.img_now_show:SetValue(true)
				self.img_now_bg:SetAsset(asset, bundle)
				self.cur_gongji:SetValue(show_now_text)
			end
		end
		if now_list[2] ~= nil then
			local index_2 = now_list[2].index
			local value1_2 = now_list[2].value1
			local value2_2 = now_list[2].value2

			if index_2 == GODDRESS_GM_UP_ID_2 then
				self.img_now_show:SetValue(false)
				local show_value = self:GetFormatStr(1, (tonumber(value2_2) / 100))
				attr_name = GoddessData.Instance:GetXianNvShengWuSkillName(value1_2)
				show_now_text = string.format(Language.Goddess.GoddessUpText2, attr_name, show_value) .. "%"
			elseif index_2 == GODDRESS_GM_UP_ID_3 then
				self.img_now_show:SetValue(false)
				attr_name = GoddessData.Instance:GetXianNvShengWuSkillName(value1_2)
				local show_value = self:GetFormatStr(2, (tonumber(value2_2) / 100))
				show_now_text = string.format(Language.Goddess.GoddessUpText3, attr_name, show_value)
			elseif index_2 == GODDRESS_GM_UP_ID_4 then
				self.img_now_show:SetValue(false)
				local show_value = self:GetFormatStr(1, (tonumber(value2_2) / 100))
				show_now_text = string.format(Language.Goddess.GoddessUpText4, show_value) .. "%"
			elseif index_2 == GODDRESS_GM_UP_ID_5 then
				self.img_now_show:SetValue(false)
				attr_name = GoddessData.Instance:GetXianNvShengWuSkillName(value1_2)
				show_now_text = string.format(Language.Goddess.GoddessUpText5, attr_name, value2_2)
			elseif index_2 == GODDRESS_GM_UP_ID_6 then
				self.img_now_show:SetValue(false)
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
		if cur_lingye < now_data.upgrade_need_ling then
			cur_lingye = ToColorStr(cur_lingye, TEXT_COLOR.RED)
		else
			cur_lingye = ToColorStr(cur_lingye, TEXT_COLOR.BLUE1)
		end
		self.text_show_lingye:SetValue(cur_lingye .. " / " .. now_data.upgrade_need_ling)
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