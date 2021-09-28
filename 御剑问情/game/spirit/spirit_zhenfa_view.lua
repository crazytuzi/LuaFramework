SpiritZhenfaView = SpiritZhenfaView or BaseClass(BaseRender)



function SpiritZhenfaView:__init(instance)
	self.model_root = {}
	self.model_shadow = {}
	self.model_obj = {}
	self.model_label = {}
	self.model_list = {}
	self.is_show_model = {}
	self.sprite_table = {}
	self.model_capacity = {}
	self.show_red_point_hunyu = {}
	self.Shangzhen_red_point = {}

	self:ListenEvent("OnClickShangzhen1",BindTool.Bind(self.OnClickShowShangzhenList, self, 1))
	self:ListenEvent("OnClickShangzhen2",BindTool.Bind(self.OnClickShowShangzhenList, self, 2))
	self:ListenEvent("OnClickShangzhen3",BindTool.Bind(self.OnClickShowShangzhenList, self, 3))
	self:ListenEvent("ShowAllProperty",BindTool.Bind(self.OnShowProperty, self))
	self:ListenEvent("OnClickUpGrade",BindTool.Bind(self.OnLeveUpZhenfa, self))
	self:ListenEvent("OnClickLeveluphunshoyu",BindTool.Bind(self.OnShowHunShouyuView, self))
	self:ListenEvent("OnClickHelper",BindTool.Bind(self.OnClickHelper, self))

	self.is_position1_full = self:FindVariable("is_position1_full")
	self.is_position2_full = self:FindVariable("is_position2_full")
	self.is_position3_full = self:FindVariable("is_position3_full")

	self.text_zhenfa_rate = self:FindVariable("text_zhenfa_rate")
	self.show_red_point_xianzhen = self:FindVariable("show_red_point_xianzhen")
	self.zhenfa_level = self:FindVariable("zhenfa_level")

	self.text_gongji_rate = self:FindVariable("text_gongji_rate")
	self.text_hp_rate = self:FindVariable("text_hp_rate")
	self.text_fangyu_rate = self:FindVariable("text_fangyu_rate")
	for i=0,2 do
		self.show_red_point_hunyu[i] = self:FindVariable("show_red_point_hunyu" .. i)
	end

	for i = 1,3 do
		self.model_root[i] = self:FindObj("model" .. i .. "_root")
		self.model_shadow[i] = self.model_root[i]:FindObj("model_empty")
		self.model_obj[i] = self.model_root[i]:FindObj("model_obj")
		self.is_show_model[i] = self:FindVariable("is_show_model" .. i)
		self.model_label[i] = self.model_root[i]:FindObj("name_bg")
		self.model_capacity[i] = self:FindVariable("text_zhenfa_capacity" .. i)
		self.model_list[i] = RoleModel.New("spirit_zhenfa_frame")
		self.model_list[i]:SetDisplay(self.model_obj[i].ui3d_display)
		self.Shangzhen_red_point[i] = self:FindVariable("show_red_point_shangzhen_" .. i)
	end

	self.zhenfa_rate = self:FindObj("zhenfa_rate"):GetComponent(typeof(UnityEngine.UI.Text))
	self.attackhunyu_rate = self:FindObj("attackshouhunyu_rate"):GetComponent(typeof(UnityEngine.UI.Text))
	self.defensehunyu_rate = self:FindObj("defenseshouhunyu_rate"):GetComponent(typeof(UnityEngine.UI.Text))
	self.lifehunyu_rate = self:FindObj("lifeshouhunyu_rate"):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.attackhunyu_lv = self:FindObj("attackhunshouyu_lv"):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.defensehunyu_lv = self:FindObj("defenseshouhunyu_lv"):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.lifehunyu_lv = self:FindObj("lifeshouhunyu_lv"):GetComponent(typeof(UnityEngine.UI.Text))
	self.zhenfa_lv = self:FindObj("zhenfa_lv"):GetComponent(typeof(UnityEngine.UI.Text))
	self.addpower = self:FindObj("addspiritpower"):GetComponent(typeof(UnityEngine.UI.Text))

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.SpiritShangZhen)
	RemindManager.Instance:Bind(self.remind_change, RemindName.SpiritZhenFaPromote)
	RemindManager.Instance:Bind(self.remind_change, RemindName.SpiritZhenFaUplevel)
	RemindManager.Instance:Bind(self.remind_change, RemindName.SpiritZhenFaHunyu)
end

function SpiritZhenfaView:LoadCallBack()

end

function SpiritZhenfaView:__delete()
	self.model_root = {}
	self.model_shadow = {}
	self.model_obj = {}
	self.model_label = {}
	self.model_list = {}
	self.is_show_model = {}
	self.sprite_table = {}
	self.model_capacity = {}
	self.show_red_point_hunyu = {}
	self.Shangzhen_red_point = {}
	self.is_position1_full = nil
	self.is_position2_full = nil
	self.is_position3_full = nil
	self.zhenfa_rate = nil
	self.attackhunyu_rate = nil
	self.defensehunyu_rate = nil
	self.lifehunyu_rate = nil
	self.text_gongji_rate = nil
	self.text_hp_rate = nil
	self.text_fangyu_rate = nil
	-- self.attackhunyu_lv = nil
	-- self.defensehunyu_lv = nil
	-- self.lifehunyu_lv = nil
	self.zhenfa_lv = nil
	self.addpower = nil
	self.text_zhenfa_rate = nil
	self.show_red_point_xianzhen = nil
	self.helpId = 42

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

function SpiritZhenfaView:RemindChangeCallBack(remind_name, num)
	if RemindName.SpiritShangZhen == remind_name or
		RemindName.SpiritZhenFaPromote == remind_name then
		self:Flush()
	end
end

function SpiritZhenfaView:CloseCallBack()

end

function SpiritZhenfaView:OnShowProperty()

	SpiritCtrl.Instance:ShowSpiritZhenFaValueView()
end

function SpiritZhenfaView:OnLeveUpZhenfa()
	SpiritCtrl.Instance:ShowSpiritZhenFaPromoteView(SPIRITPROMOTETAB_TYPE.TABXIANZHEN)
end

function SpiritZhenfaView:OnClickShowShangzhenList(index)
	local item = self.sprite_table[index] and self.sprite_table[index].item or nil
	TipsCtrl.Instance:ShowSpiritShangZhenView(index, item)
end

function SpiritZhenfaView:OnShowHunShouyuView()
	SpiritCtrl.Instance:ShowSpiritZhenFaPromoteView(SPIRITPROMOTETAB_TYPE.TABHUNYU)
end

function SpiritZhenfaView:OnClickHelper()
	local helpId = 42
	TipsCtrl.Instance:ShowHelpTipView(helpId)
end

function SpiritZhenfaView:OnFlush(param_list)
	--判断红点
	self.show_red_point_xianzhen:SetValue(SpiritData.Instance:CanPromote())
	for i=0,2 do
		self.show_red_point_hunyu[i]:SetValue(SpiritData.Instance:CanHunYuUp(i))
	end

	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local zhenfa_attr_list = SpiritData.Instance:GetZhenfaAttrList()
	local zhenfa_level = spirit_info.xianzhen_level
	local zhenfa_info = SpiritData.Instance:GetZhenfaCfgByLevel(zhenfa_level)
	if nil == zhenfa_info then -- 阵法满級
		zhenfa_info = SpiritData.Instance:GetZhenfaMaxLevelCfg()
	end
	local zhenfa_rate = zhenfa_info.convert_rate / 100
	local hunyu_level_list = spirit_info.hunyu_level_list
	local attackhunyu_cfg = SpiritData.Instance:GetHunyuCfg(HUNYU_TYPE.ATTACK_HUNYU, hunyu_level_list[HUNYU_TYPE.ATTACK_HUNYU])
	local attackhunyu_rate = attackhunyu_cfg and attackhunyu_cfg.convert_rate or 0
	local defensehunyu_cfg = SpiritData.Instance:GetHunyuCfg(HUNYU_TYPE.DEFENSE_HUNYU, hunyu_level_list[HUNYU_TYPE.DEFENSE_HUNYU])
	local defensehunyu_rate = defensehunyu_cfg and defensehunyu_cfg.convert_rate or 0
	local lifehunyu_cfg = SpiritData.Instance:GetHunyuCfg(HUNYU_TYPE.LIFE_HUNYU,hunyu_level_list[HUNYU_TYPE.LIFE_HUNYU])
	local lifehunyu_rate = lifehunyu_cfg and lifehunyu_cfg.convert_rate or 0
	self.zhenfa_level:SetValue("LV." .. zhenfa_level)
	-- self.zhenfa_lv.text = "LV." .. zhenfa_level

	-- self.zhenfa_rate.text = zhenfa_rate .. "%"
	-- self.attackhunyu_rate.text = attackhunyu_rate / 100 .. "%"
	-- self.defensehunyu_rate.text = defensehunyu_rate / 100 .. "%"
	-- self.lifehunyu_rate.text = lifehunyu_rate / 100 .. "%"
	
	self.text_gongji_rate:SetValue(ToColorStr(attackhunyu_rate / 100 .. "%", TEXT_COLOR.BLUE_SPECIAL))
	self.text_hp_rate:SetValue(ToColorStr(lifehunyu_rate / 100 .. "%", TEXT_COLOR.BLUE_SPECIAL))
	self.text_fangyu_rate:SetValue(ToColorStr(defensehunyu_rate / 100 .. "%", TEXT_COLOR.BLUE_SPECIAL))

	-- self.attackhunyu_lv.text = "LV." .. hunyu_level_list[HUNYU_TYPE.ATTACK_HUNYU]
	-- self.defensehunyu_lv.text = "LV." .. hunyu_level_list[HUNYU_TYPE.DEFENSE_HUNYU]
	-- self.lifehunyu_lv.text = "LV." .. hunyu_level_list[HUNYU_TYPE.LIFE_HUNYU]
	self.addpower.text =  CommonDataManager.GetCapabilityCalculation(SpiritData.Instance:GetZhenfaAttrList())

	self.text_zhenfa_rate:SetValue(ToColorStr(zhenfa_rate .. "%", TEXT_COLOR.BLUE_SPECIAL))
	local display_list = SpiritData.Instance:GetSpiritInfo().jingling_list
	local use_jingling_id = SpiritData.Instance:GetSpiritInfo().use_jingling_id
	-- for k,v in pairs(self.is_show_model) do
	-- 	v:SetValue(false)
	-- end
	for k,v in pairs(self.Shangzhen_red_point) do
		v:SetValue(SpiritData.Instance:CanShangZhen())
	end
	for k,v in pairs(self.sprite_table) do
		v.has = false
	end
	local add_list = {}
	local need = true
	if display_list then
		for k, v in pairs(display_list) do
			if v.item_id > 0 and use_jingling_id ~= v.item_id then
				need = true
				for k1,v1 in pairs(self.sprite_table) do
					if v1.item.item_id == v.item_id then
						v1.has = true
						need = false
					end
				end
				if need then
					table.insert(add_list, v)
				end
			end
		end
	end
	for k,v in pairs(self.sprite_table) do
		if not v.has then
			self.sprite_table[k] = nil
			self.is_show_model[k]:SetValue(false)
		else
			self.is_show_model[k]:SetValue(true)
			self.Shangzhen_red_point[k]:SetValue(false)
		end

		-- 各个精灵战斗力显示
		local attr_list = SpiritData.Instance:GetSpiritZhenfaCapacityByIndex(v.item.index)
		local capacity = CommonDataManager.GetCapabilityCalculation(attr_list)
		self.model_capacity[k]:SetValue(capacity)
	end
	local spirit_cfg = nil
	local bundle_main, asset_main = nil, nil

	for k,v in pairs(add_list) do
		for i = 1, 3 do
			if nil == self.sprite_table[i] then
				self.sprite_table[i] = {}
				self.sprite_table[i].item = v
				self.sprite_table[i].has = true
				spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(v.item_id)
				bundle_main, asset_main = ResPath.GetSpiritModel(spirit_cfg.res_id)
				self.model_list[i]:SetMainAsset(bundle_main, asset_main)
				self.is_show_model[i]:SetValue(true)
				self.Shangzhen_red_point[i]:SetValue(false)
				-- 各个精灵战斗力显示
				local attr_list = SpiritData.Instance:GetSpiritZhenfaCapacityByIndex(v.index)
				local capacity = CommonDataManager.GetCapabilityCalculation(attr_list)
				self.model_capacity[i]:SetValue(capacity)
				break
			end
		end
	end
end