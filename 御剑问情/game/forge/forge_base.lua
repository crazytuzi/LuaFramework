ForgeBaseCell = ForgeBaseCell or BaseClass(BaseCell)

function ForgeBaseCell:__init(instance, cell_type, forge_type)
	self.attr_list = {}
	local obj_group = self:FindObj("ObjGroup")
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		if string.find(obj.name, "Attr") ~= nil then
			local variable_table = obj:GetComponent(typeof(UIVariableTable))
			local data = {}
			data.attr_value = variable_table:FindVariable("AttrValue")
			data.is_show = variable_table:FindVariable("IsShow")
			data.att_image = variable_table:FindVariable("att_image")
			if forge_type == FORGE_TYPE.SHENZHU then
				data.up_value = variable_table:FindVariable("UpValue")
			end
			if cell_type ~= nil then
				data.next_value = variable_table:FindVariable("PromoteValue")
				data.is_show_promote = variable_table:FindVariable("IsShowPromote")
			end
			self.attr_list[count] = data
			count = count + 1
		end
	end

	self.power = self:FindVariable("Power")
	self.is_show = self:FindVariable("IsShow")

	if cell_type ~= nil then
		self.is_next = true
		self.flush_func = BindTool.Bind(self.NextCellFlush, self)
		self.type = cell_type
	else
		self.flush_func = BindTool.Bind(self.CommonFlush, self)
	end
	self.forge_type = forge_type
	if self.forge_type == FORGE_TYPE.SHENZHU then
		self.cur_attr_present = self:FindVariable("cur_attr_present")
		self.next_attr_present = self:FindVariable("next_attr_present")
		-- self.show_cur_attr_present = self:FindVariable("show_cur_attr_present")
		self.show_next_attr_present = self:FindVariable("show_next_attr_present")
		self.next_limit_text = self:FindVariable("next_limit_text")
	end
	self.effect_obj = nil
	self.is_load_effect = false
	-- self.name_effect = self:FindObj("NameEffect")
end

function ForgeBaseCell:__delete()
	if self.effect_obj then
		GameObject.Destroy(self.effect_obj)
		self.effect_obj = nil
	end
	self.is_load_effect = nil
end

--触发刷新的函数
function ForgeBaseCell:OnFlush()
	self.is_show:SetValue(true)
	self.flush_func()
end

--通用刷新
function ForgeBaseCell:CommonFlush()
	self:AttrFlush()
	self:FlushCallBack()
end

function ForgeBaseCell:AttrFlush(previous_attr)
	--previous_attr不是空的话就是下一效果格子
	local attr_data = {}
	local temp = {}
	local power_value = 0
	local next_attr_data = nil
	temp, power_value = ForgeData.Instance:GetEquipAttrAndPower(self.data)
	attr_data = CommonDataManager.SortAttribute(temp)
	if not previous_attr then
		self.data.param.strengthen_level = self.data.param.strengthen_level + 1
		self.data.param.shen_level = self.data.param.shen_level + 1
		next_attr_data = ForgeData.Instance:GetEquipAttrAndPower(self.data)
		self.data.param.strengthen_level = self.data.param.strengthen_level - 1
		self.data.param.shen_level = self.data.param.shen_level - 1
	end
	self.power:SetValue(power_value)
	if self.forge_type == FORGE_TYPE.SHENZHU then
		local equip_index = EquipData.Instance:GetEquipIndexByType(self.data.item_cfg.sub_type)
		local shen_level = self.data.param.shen_level
		local cfg = ForgeData.Instance:GetShenOpSingleCfg(equip_index, shen_level)

		local cur_attr_present = 0
		if cfg and next(cfg) then
			cur_attr_present = cfg.attr_percent
		end
		local next_cfg = ForgeData.Instance:GetNextShenZhuAttrPresent(equip_index, cur_attr_present)

		if cfg then
			-- self.show_cur_attr_present:SetValue(true)
			self.cur_attr_present:SetValue(string.format(Language.Forge.ShenZhuCurAttrDesc, Language.Forge.EquipName[equip_index], cfg.attr_percent))
		else
			-- self.show_cur_attr_present:SetValue(false)
			self.cur_attr_present:SetValue(string.format(Language.Forge.ShenZhuCurAttrDesc, Language.Forge.EquipName[equip_index], 0))
		end
		if next_cfg then
			self.show_next_attr_present:SetValue(true)
			self.next_attr_present:SetValue(string.format(Language.Forge.ShenZhuNextAttrDesc, Language.Forge.EquipName[equip_index], next_cfg.attr_percent))
			self.next_limit_text:SetValue("(" .. string.format(Language.Mount.ShowRedStr, shen_level) .." / ".. string.format(Language.Mount.ShowBlue2Str, next_cfg.shen_level) ..")")
		else
			self.show_next_attr_present:SetValue(false)
			self.next_attr_present:SetValue("")
		end
	end

	local count = 1

	for k,v in pairs(attr_data) do
		if v.value > 0 then
			if count > #self.attr_list then
				print("属性超出最大可显示范围",k,v)
				break
			end
			local data = self.attr_list[count]
			if previous_attr ~= nil then
				--下一效果格子
				local previous_attr_value = previous_attr[v.key] or 0
				local promote_value = v.value - previous_attr_value
				if promote_value > 0 then
					--有提升
					data.is_show:SetValue(true)
					data.attr_value:SetValue(v.key..': '..v.value)
					data.att_image:SetAsset("uis/images_atlas", Language.Forge.AttImageTab[v.key])

					-- data.is_show_promote:SetValue(true)
					data.next_value:SetValue(promote_value)
					count = count + 1
				else
					--无提升
					data.is_show:SetValue(false)
					-- data.is_show_promote:SetValue(false)
				end
			else
				--当前效果格子
				data.is_show:SetValue(true)
				data.attr_value:SetValue(v.key..': '..v.value)
				data.att_image:SetAsset("uis/images_atlas", Language.Forge.AttImageTab[v.key])
				if data.up_value then
					local shen_level = self.data.param.shen_level
					local equip_index = EquipData.Instance:GetEquipIndexByType(self.data.item_cfg.sub_type)
					local cfg = ForgeData.Instance:GetShenOpSingleCfg(equip_index, shen_level)
					local next_cfg = ForgeData.Instance:GetShenOpSingleCfg(equip_index, shen_level + 1)
					if next_cfg then
						local diff_value = 0
						local cur_value = 0
						if v.key == Language.Forge.AttrName.shengming then
							if cfg and next(cfg) then cur_value = cfg.maxhp end
							diff_value = next_cfg.maxhp -cur_value
						elseif v.key == Language.Forge.AttrName.gongji then
							if cfg and next(cfg) then cur_value = cfg.gongji end
							diff_value = next_cfg.gongji - cur_value
						elseif v.key == Language.Forge.AttrName.fangyu then
							if cfg and next(cfg) then cur_value = cfg.fangyu end
							diff_value = next_cfg.fangyu - cur_value
						elseif v.key == Language.Forge.AttrName.mingzhong then
							if cfg and next(cfg) then cur_value = cfg.mingzhong end
							diff_value = next_cfg.mingzhong - cur_value
						elseif v.key == Language.Forge.AttrName.shanbi then
							if cfg and next(cfg) then cur_value = cfg.shanbi end
							diff_value = next_cfg.shanbi - cur_value
						elseif v.key == Language.Forge.AttrName.baoji then
							if cfg and next(cfg) then cur_value = cfg.baoji end
							diff_value = next_cfg.baoji - cur_value
						elseif v.key == Language.Forge.AttrName.kaobao then
							if cfg and next(cfg) then cur_value = cfg.jianren end
							diff_value = next_cfg.jianren - cur_value
						end
						data.up_value:SetValue(diff_value)
					end
				end
				count = count + 1
			end
		end
	end
	if next_attr_data then
		for k, v in pairs(next_attr_data) do
			if v > 0 and CommonDataManager.SearchAttributeValue(attr_data,k) <= 0 then
				local data = self.attr_list[count]
				data.is_show:SetValue(true)
				if self.forge_type == FORGE_TYPE.SHENZHU then
					local diff_value = 0
					diff_value = next_attr_data[k]
					data.up_value:SetValue(diff_value)
				end
				data.attr_value:SetValue(k..': '..CommonDataManager.SearchAttributeValue(attr_data,k))
				data.att_image:SetAsset("uis/images_atlas", Language.Forge.AttImageTab[k])
				count = count + 1
			end
		end
	end
	if count <= #self.attr_list then
		for i=count,#self.attr_list do
			self.attr_list[i].is_show:SetValue(false)
		end
	end

	self.is_show:SetValue(false)
	self.is_show:SetValue(true)
	local item_name_index = ForgeData.Instance:GetQualityNameIndex(self.data)

	--设置神铸段位对应的特效
	if item_name_index > 0 then
		-- local bundle, asset = ResPath.GetUITipsEffect(item_name_index)
		-- PrefabPool.Instance:Load(AssetID(bundle, asset), function(prefab)
		-- 	if prefab then
		-- 		if self.effect_obj then
		-- 			GameObject.Destroy(self.effect_obj)
		-- 			self.effect_obj = nil
		-- 		end
		-- 		local obj = GameObject.Instantiate(prefab)
		-- 		local transform = obj.transform
		-- 		-- transform:SetParent(self.name_effect.transform, false)
		-- 		self.effect_obj = obj.gameObject
		-- 		PrefabPool.Instance:Free(prefab)
		-- 	end
		-- end)
	end

end

--下一级格子专用刷新
function ForgeBaseCell:NextCellFlush()
	--提升值和上箭头
	self.previous_data = TableCopy(self.data)
	local next_data = TableCopy(self.data)
	next_data.param[self.type] = next_data.param[self.type] + 1
	self.data = next_data
	local previous_attr = ForgeData.Instance:GetEquipAttrAndPower(self.previous_data)
	self:AttrFlush(previous_attr)

	self:FlushCallBack()
end

--不显示数据
function ForgeBaseCell:ShowEmpty()
	self.is_show:SetValue(false)
	self:ShowEmptyCallBack()
end

--专用初始化函数2
function ForgeBaseCell:InitType2()
	self.equip_name = self:FindVariable("EquipName")
	self.show_name = self:FindVariable("show_name")
	self.level = self:FindVariable("Level")
	self.show_text = self:FindVariable("UpTenLevel")
	
	if nil == self.data then
		return
	end
	local item_name_index = ForgeData.Instance:GetQualityNameIndex(self.data)
	if item_name_index > 0 and item_name_index <= 10 then
		self.show_name:SetValue(true)
		local bundle, asset = ResPath.GetForgeItemName(item_name_index)
		self.equip_name:SetAsset(bundle, asset)
		self.show_text:SetValue(false)
	elseif item_name_index > 10 then
		self.level:SetValue(item_name_index)
		self.show_name:SetValue(false)
		self.show_text:SetValue(true)
	else
		self.show_name:SetValue(false)
		self.show_text:SetValue(false)
	end

end

--专用刷新函数2
function ForgeBaseCell:FlushType2()
	--名字
	local item_name_index = ForgeData.Instance:GetQualityNameIndex(self.data)
	if item_name_index > 0 and item_name_index <= 10 then
		self.show_name:SetValue(true)
		local bundle, asset = ResPath.GetForgeItemName(item_name_index)
		self.equip_name:SetAsset(bundle, asset)
		self.show_text:SetValue(false)
	elseif item_name_index > 10 then
		self.level:SetValue(item_name_index)
		self.show_name:SetValue(false)
		self.show_text:SetValue(true)
	else
		self.show_name:SetValue(false)
		self.show_text:SetValue(false)
	end
end

--专用刷新函数2
function ForgeBaseCell:ShowEmptyType2()
	self.equip_name:SetValue('')
end

--回调函数
function ForgeBaseCell:FlushCallBack()
end
function ForgeBaseCell:ShowEmptyCallBack()
end

------------------------锻造View的通用函数------------------------
ForgeBaseView = ForgeBaseView or BaseClass(BaseRender)

function ForgeBaseView:__init(instance, mother_view, index)
	self.index = index
	self.mother_view = mother_view
	self.equip_icon = self:FindVariable("EquipIcon")
	--是否满级
	self.is_max_level = self:FindVariable("IsMaxLevel")
	self.is_max_level:SetValue(false)
	--升级材料
	self.material = ItemCellReward.New()
	self.material:SetInstanceParent(self:FindObj("Material"))
	self.material_number = self:FindVariable("MaterialNum")
end

function ForgeBaseView:__delete()
	if nil ~= self.material then
		self.material:DeleteMe()
		self.material = nil
	end
	self.mother_view = nil
end

function ForgeBaseView:CommonFlush()
	self.data = self.mother_view:GetSelectData()
	if self.data == nil or self.data.item_id == nil or self.data.item_id == 0 then
		self:ShowEmpty()
		self.current_effect:ShowEmpty()
		if nil ~= self.max_effect then
			self.max_effect:ShowEmpty()
		end
		if self.next_effect then
			self.next_effect:ShowEmpty()
		end
		self.material:SetData()
		self.material_number:SetValue('')
		self.equip_icon:SetAsset("","")
		return
	end
	self:SetNextCfg()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.equip_icon:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))

	self.current_effect:SetData(self.data)
	if nil ~= self.max_effect then
		self.max_effect:SetData(self.data)
	end
	if self.next_effect then
		self.next_effect:SetData(self.data)
	end
	--升级材料
	self:StuffCommonFlush()
end

function ForgeBaseView:StuffCommonFlush()
	--升级材料
	if self.next_cfg ~= nil then
		self.is_max_level:SetValue(false)
		local item_id = self.next_cfg["stuff_id"]
		local data = {}
		data.item_id = item_id
		self.material:SetData(data)
		local need_item_num = self.next_cfg["stuff_count"]
		local need_item_text = ' / '..need_item_num
		local had_item_num = ItemData.Instance:GetItemNumInBagById(item_id)
		local had_item_text = ""
		if had_item_num < need_item_num then
			had_item_text = ToColorStr(had_item_num,TEXT_COLOR.RED)
		else
			had_item_text = ToColorStr(had_item_num,TEXT_COLOR.BLUE_SPECIAL)
		end
		self.material_number:SetValue(had_item_text..need_item_text)
	else
		self.is_max_level:SetValue(true)
		self.material_number:SetValue("")
		self.material:SetData()
	end
end

function ForgeBaseView:MaterialClick()
	if self.data == nil or self.data.item_id == nil then
		return
	end
	local data = {}
	data.item_id = self.next_cfg["stuff_id"]
	TipsCtrl.Instance:OpenItem(data)
end

function ForgeBaseView:SetNextCfg()
end
