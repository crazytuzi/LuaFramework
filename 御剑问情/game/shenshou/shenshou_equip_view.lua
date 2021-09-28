ShenShouEquipView = ShenShouEquipView or BaseClass(BaseRender)

function ShenShouEquipView:__init(instance, mother_view)
	self.select_shou_id = 1
	self:InitScroller()
	self.skill_t = {}

	for i = 1, 4 do
		local skill_item = ShenShouSkillItem.New()
		skill_item:SetInstanceParent(self:FindObj("Skillpanel"))
		skill_item:SetClickCallBack(BindTool.Bind(self.SkillItemClick, self, i, skill_item))
		self.skill_t[i] = skill_item
	end
	self.equip_t = {}
	self.equip_up_t = {}
	self.equip_txt_t = {}
	for i = 1, 5 do
		local item_cell = ShenShouEquip.New()
		item_cell:SetInstanceParent(self:FindObj("Equip" .. i))
		self.equip_txt_t[i] = self:FindVariable("EquipText" .. i)
		item_cell:ShowHighLight(false)
		self.equip_t[i] = item_cell
		self.equip_up_t[i] = self:FindObj("Up" .. i)
		self.equip_up_t[i].transform:SetAsLastSibling()
	end

	self.head_img = self:FindVariable("HeadImg")
	self.add_count = self:FindVariable("addCount")
	self.zhuzhan_txt = self:FindVariable("ZhuzhanTxt")
	self.is_active = self:FindVariable("IsActive")
	self.fight_power = self:FindVariable("fight_power")

	self.attr_t = {}
	for i = 1, 4 do
		self.attr_t[i] = {}
		self.attr_t[i].attr = self:FindVariable("Attr" .. i)
		self.attr_t[i].attr_add = self:FindVariable("Attr" .. i .. "Add")
		self.attr_t[i].attr_img = self:FindVariable("AttrImg" .. i)
	end

	self:ListenEvent("OnClickAdd",BindTool.Bind(self.OnClickAdd, self))
	self:ListenEvent("OnClickAutoTakeOff",BindTool.Bind(self.OnClickAutoTakeOff, self))
	self:ListenEvent("OnClickPackage",BindTool.Bind(self.OnClickPackage, self))
	self:ListenEvent("OnClickFight",BindTool.Bind(self.OnClickFight, self))
	self:ListenEvent("OnClickHelp",BindTool.Bind(self.OnClickHelp, self))
end

function ShenShouEquipView:__delete()
	self.scroller = nil
	self.equip_txt_t = {}
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end

	if self.equip_t then
		for k,v in pairs(self.equip_t) do
			v:DeleteMe()
		end
		self.equip_t = {}
	end

	if self.skill_t then
		for k,v in pairs(self.skill_t) do
			v:DeleteMe()
		end
		self.skill_t = {}
	end
end

function ShenShouEquipView:InitScroller()
	self.cell_list = {}
	self.data = ShenShouData.Instance:GetShenshouListData()
	self.scroller = self:FindObj("Listview")
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  ShenShouItem.New(cell.gameObject)
			target_cell = self.cell_list[cell]
			target_cell:SetToggleGroup(self.scroller.toggle_group)
		end
		local cell_data = self.data[data_index]
		target_cell:SetData(cell_data)
		target_cell:SetClickCallBack(BindTool.Bind(self.SelectShenShouCallBack, self, data_index))
		target_cell:SetToggle(cell_data.shou_id == self.select_shou_id)
	end
end

function ShenShouEquipView:SelectShenShouCallBack(data_index)
	self.select_shou_id = data_index
	self:Flush()
end

function ShenShouEquipView:SkillItemClick(index, cell)
	ShenShouCtrl.Instance:OpenSkillTip(index, cell)
end

function ShenShouEquipView:EquipClick(index, cell)
	ShenShouCtrl.Instance:SetDataAndOepnEquipTip(cell:GetData(), ShenShouEquipTip.FromView.ShenShouView, self.select_shou_id)
	-- ShenShouCtrl.Instance:OpenShenShouBag(self.select_shou_id)
end

function ShenShouEquipView:OpenCallBack()
	self:Flush()
end

function ShenShouEquipView:OnClickAdd()
	ShenShouCtrl.Instance:OpenExtraZhuZhanTip()
end

function ShenShouEquipView:OnClickAutoTakeOff()
	for i=0, 5 do
		ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_TAKE_OFF, self.select_shou_id, i)
	end
end

function ShenShouEquipView:OnClickPackage()
	ShenShouCtrl.Instance:OpenShenShouBag(self.select_shou_id)
end

function ShenShouEquipView:OnClickFight()
	ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_ZHUZHAN, self.select_shou_id)
end

function ShenShouEquipView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(225)
end

function ShenShouEquipView:OnFlush(param_t)
	self.data = ShenShouData.Instance:GetShenshouListData()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
	self.fight_power:SetValue(self.data[self.select_shou_id].zonghe_pingfen)
	
	local quality_requirement = ShenShouData.Instance:GetQualityRequirement(self.select_shou_id)
	if quality_requirement ~= nil then
	    for k, v in pairs(quality_requirement) do
	    	local str1 = Language.ShenShou.ItemDesc[v.slot_need_quality] or ""
	    	local str2 = Language.ShenShou.ZhuangBeiLeiXing[v.slot] or ""
		    local str = str1 .. str2
		    if nil ~= self.equip_txt_t[v.slot + 1] then
		    	self.equip_txt_t[v.slot + 1]:SetValue(ToColorStr(str, ITEM_TIP_COLOR[v.slot_need_quality] or "#ffffff"))
		    end
	    end
    end
	
	local shenshou_list = ShenShouData.Instance:GetShenshouList(self.select_shou_id)
	local is_visible = ShenShouData.Instance:GetShenShouHasRemindImg(self.select_shou_id)
	local is_active  = ShenShouData.Instance:IsShenShouActive(self.select_shou_id)
	self.is_active:SetValue(is_active)
	local flag = false
	if shenshou_list then
		for k, v in pairs(shenshou_list.equip_list) do
			self.equip_t[k]:SetData(v)
			-- self.equip_t[k]:SetInteractable(true)
			self.equip_t[k].root_node:SetActive(v.item_id > 0)
			flag = ShenShouData.Instance:GetHasBetterShenShouEquip(v, self.select_shou_id, k)
			self.equip_up_t[k]:SetActive(is_visible and flag)
			if v.item_id > 0 then
				self.equip_t[k]:ListenClick(BindTool.Bind(self.EquipClick, self, k, self.equip_t[k]))
				self.equip_t[k]:SetInteractable(true)
			end
		end
	else
		for k,v in pairs(self.equip_t) do
			flag = ShenShouData.Instance:GetHasBetterShenShouEquip(nil, self.select_shou_id, k)
			self.equip_up_t[k]:SetActive(is_visible and flag)
			v.root_node:SetActive(false)
		end
	end

	local other_cfg = ConfigManager.Instance:GetAutoConfig("shenshou_cfg_auto").other[1]
	local extra_zhuzhan_count = ShenShouData.Instance:GetExtraZhuZhanCount()
	local zhuzhan_num = ShenShouData.Instance:GetZhuZhanNum()
	self.add_count:SetValue(zhuzhan_num .. " / " .. extra_zhuzhan_count + other_cfg.default_zhuzhan_count)
	self.head_img:SetAsset("uis/views/shenshouview/images_atlas", "shenshou_" .. self.select_shou_id)

	local is_zhuzhan = ShenShouData.Instance:IsShenShouZhuZhan(self.select_shou_id)
	local btn_text = is_zhuzhan and Language.ShenShou.ZhaoHui or Language.ShenShou.ZhuZhan
	self.zhuzhan_txt:SetValue(btn_text)

	local shou_cfg = ShenShouData.Instance:GetShenShouCfg(self.select_shou_id)
	local shenshou_base_struct = CommonDataManager.GetAttributteByClass(shou_cfg)
	local eq_struct = ShenShouData.Instance:GetOneShenShouAttr(self.select_shou_id)
	local attr_keys = CommonDataManager.GetAttrKeyList()
	local base_content = ""

	local index = 0
	for k,v in pairs(attr_keys) do
		local shou_base_value = math.floor(shenshou_base_struct[v])
		local eq_add_value = math.floor(eq_struct[v])
		local attr_name = Language.Common.AttrName[v]
		if attr_name and shou_base_value > 0 then
			index = index + 1
			if self.attr_t[index] then
				self.attr_t[index].attr:SetValue(attr_name .. ": " .. shou_base_value)
				self.attr_t[index].attr_add:SetValue(eq_add_value)
				self.attr_t[index].attr_img:SetAsset(ResPath.GetBaseAttrIcon(attr_name))
			end
		end
	end
	for i= index + 1, 4 do
		self.attr_t[i].attr:SetValue("")
		self.attr_t[i].attr_add:SetValue(0)
		self.attr_t[i].attr_img:ResetAsset()
	end

	local skill_list = ShenShouData.Instance:GetOneShouSkill(self.select_shou_id)
	for k,v in pairs(self.skill_t) do
		if skill_list[k - 1] then
			v:SetData(skill_list[k - 1])
		end
		if v.root_node then
			v.root_node:SetActive(skill_list[k - 1] ~= nil)
		end
	end
end

ShenShouSkillItem = ShenShouSkillItem or BaseClass(BaseCell)

function ShenShouSkillItem:__init()
	GameObjectPool.Instance:SpawnAsset("uis/views/shenshouview_prefab", "ShenshouSkillItem", function(obj)
		local u3dobj = U3DObject(obj)
		self:SetInstance(u3dobj)
		if self.instance_parent then
			self.root_node.transform:SetParent(self.instance_parent.transform, false)
			self.instance_parent = nil
		end
		self:Init()
	end)
end

function ShenShouSkillItem:SetInstance(instance)
	-- UI根节点, 支持instance是GameObject或者U3DObject
	if type(instance) == "userdata" then
		self.root_node = U3DObject(instance)
	else
		self.root_node = instance
	end

	self.name_table = instance:GetComponent(typeof(UINameTable))			-- 名字绑定
	self.event_table = instance:GetComponent(typeof(UIEventTable))			-- 事件绑定
	self.variable_table = instance:GetComponent(typeof(UIVariableTable))	-- 变量绑定
end

function ShenShouSkillItem:Init()
	self.head_img = self:FindVariable("HeadImg")
	self.level = self:FindVariable("Level")
	self:ListenEvent("OnClick",BindTool.Bind(self.OnClick, self))
	self.root_node:SetActive(self.data ~= nil)
	self.init = true
	self:Flush()
end

function ShenShouSkillItem:__delete()
	self.instance_parent = nil
	self.init = false
end

function ShenShouSkillItem:SetInstanceParent(instance_parent)
	if self.root_node then
		self.root_node.transform:SetParent(instance_parent.transform, false)
	else
		self.instance_parent = instance_parent
	end
end

function ShenShouSkillItem:OnFlush(param_t)
	if not self.data or not self.init then return end
	self.level:SetValue(self.data.level)
	local skill_cfg = ShenShouData.Instance:GetShenShouSkillCfg(self.data.skill_type, self.data.level)
	if nil == skill_cfg then return end
	self.head_img:SetAsset(ResPath.GetShenShouSkillIcon(skill_cfg.icon_id))
end

ShenShouItem = ShenShouItem or BaseClass(BaseCell)

function ShenShouItem:__init()
	self.show_flag = self:FindVariable("ShowFlag")
	self.head_img = self:FindVariable("HeadImg")
	self.name = self:FindVariable("Name")
	self.cap = self:FindVariable("Cap")
	self.is_active = self:FindVariable("IsActive")
	self.remind = self:FindVariable("Remind")
	self:ListenEvent("OnClick",BindTool.Bind(self.OnClick, self))
end

function ShenShouItem:Init()

end

function ShenShouItem:__delete()

end

function ShenShouItem:SetToggleGroup(group)
  	self.root_node.toggle.group = group
end

function ShenShouItem:SetToggle(value)
  	self.root_node.toggle.isOn = value
end

function ShenShouItem:OnFlush(param_t)
	if not self.data then return end
	self.head_img:SetAsset("uis/views/shenshouview/images_atlas", "shenshou_" .. self.data.shou_id)
	self.name:SetValue(string.format("<color=%s>%s</color>", ITEM_TIP_COLOR[self.data.quality], self.data.name))
	self.show_flag:SetValue(self.data.has_zhuzhan)
	local is_active = ShenShouData.Instance:IsShenShouActive(self.data.shou_id)
	self.is_active:SetValue(is_active)
	self.cap:SetValue(self.data.zonghe_pingfen)
	self.remind:SetValue(self.data.show_remind_bg)
end