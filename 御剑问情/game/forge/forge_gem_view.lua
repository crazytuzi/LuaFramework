--装备-宝石
ForgeGem = ForgeGem or BaseClass(BaseRender)

local SPECIAL_GEM_TYPE = 5

function ForgeGem:__init(instance, mother_view)
	self.mother_view = mother_view
	self.select_cell_index = 0

	self.equip_icon = self:FindVariable("EquipIcon")
	--是否显示宝石列表
	self.is_show_gem_list = self:FindVariable("IsShowGemList")
	--是否显示镶嵌宝石选项
	self.is_show_gem_option = self:FindVariable("IsShowGemOption")
	--是否显示升级按钮
	self.is_show_up_btn = self:FindVariable("IsShowUpBtn")
	--宝石选项提示板
	self.gem_option_plane = self:FindObj("GemOptionPlane")
	--宝石总战力
	self.gem_power = self:FindVariable("Power")
	--正在自动升级
	self.auto_upgradeing = self:FindVariable("AutoUpgradeing")
	self.auto_upgradeing:SetValue(false)
	--五个宝石格子的表
	self.gem_list = {}
	local item_manager = self:FindObj("ItemManager")
	local child_number = item_manager.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = item_manager.transform:GetChild(i).gameObject
		obj = obj.transform:GetChild(0)
		if string.find(obj.name, "GemCell") ~= nil then
			self.gem_list[count] = GemCell.New(obj)
			self.gem_list[count].mother_view = self
			self.gem_list[count].cell_index = count - 1
			count = count + 1
		end
	end
	self:InitScroller()

	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self:FindObj("CurEquipCell"))
	--不显示数据
	self.is_show = self:FindVariable("IsShow")
	--绑定装备滚动条点击事件
	self.mother_view:SetClickCallBack(TabIndex.forge_baoshi, BindTool.Bind(self.OnClick, self))
	--宝石选项按钮
	self.unload_button = self:FindObj("UnloadButton")
	self.unload_button.button:AddClickListener(BindTool.Bind(self.UnloadClick, self))
	self.level_up_button = self:FindObj("LevelUpButton")

	self.inlay_button = self:FindObj("InalayButton")
	self.GemCellsix = self:FindObj("GemCellsix")
	self.GemCellseven = self:FindObj("GemCellseven")
	self.imageleft = self:FindObj("imageleft")
	self.imageright = self:FindObj("imageright")
	self.inlay_button.button:AddClickListener(BindTool.Bind(self.InlayClick, self))
	self.inlay_button_text = self.inlay_button:FindObj("ButtonName")
	--全身宝石等级Tips
	-- self.total_gem_tips = TotalGemTips.New(self:FindObj("TotalGemTips"))
	-- self.total_gem_tips:SetActive(false)
	--监听事件
	self:ListenEvent("CloseGemList", BindTool.Bind(self.ShowOrHideGemList, self, false))
	self:ListenEvent("CloseGemOption", BindTool.Bind(self.ShowOrHideGemOption, self, false))
	self:ListenEvent("OpenTotalGem", BindTool.Bind(self.ShowOrHideTotalGem, self, true))
	self:ListenEvent("CloseTotalGem", BindTool.Bind(self.ShowOrHideTotalGem, self, false))
	self:ListenEvent("AutoUpgrade", BindTool.Bind(self.AutoUpgradeClick, self))
	self:ListenEvent("CancelAutoUpgradeClick", BindTool.Bind(self.CancelAutoUpgradeClick, self))
	self:ListenEvent("BuyClick", BindTool.Bind(self.BuyClick, self))
	self:ListenEvent("LevelUpClick", BindTool.Bind(self.LevelUpClick, self))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))
	--self.root_node:SetActive(false)

	--模型展示
	self.model_display = self:FindObj("ModelDisplay")
	if nil ~= self.model_display then
		self.model = RoleModel.New()
		self.model:SetDisplay(self.model_display.ui3d_display)
	end
	self.color = 0
	self.color_glow = 0
	self.model_bg_effect = self:FindObj("ModelBgEffect")
	self.equip_bg_effect_obj = nil
	self.model_glow_effect = self:FindObj("ModelGlowEffect")
	self.equip_glow_effect_obj = nil
	self.model_index = nil
end

function ForgeGem:__delete()
	self.mother_view = nil
	if nil ~= self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	-- self.total_gem_tips:DeleteMe()
	for k,v in pairs(self.gem_list) do
		v:DeleteMe()
	end

	if nil ~= self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end

	if self.equip_bg_effect_obj then
		GameObject.Destroy(self.equip_bg_effect_obj)
		self.equip_bg_effect_obj = nil
	end

	if self.equip_glow_effect_obj then
		GameObject.Destroy(self.equip_glow_effect_obj)
		self.equip_glow_effect_obj = nil
	end

	self.GemCellsix = nil
	self.GemCellseven = nil
	self.imageleft = nil
	self.imageright = nil

	self:CancelQuest()
end

--初始化滚动条
function ForgeGem:InitScroller()
	self.cell_list = {}
	self.scroller = self:FindObj("Scroller")
	self.gem_scroller_select_index = 1

	self.list_view_delegate = ListViewDelegate()
	PrefabPool.Instance:Load(AssetID("uis/views/forgeview_prefab", "GemItem"), function (prefab)
		if nil == prefab then
			print(ToColorStr("prefab为空", TEXT_COLOR.RED))
			return
		end
		self.enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		self.scroller.scroller.Delegate = self.list_view_delegate
		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)

		PrefabPool.Instance:Free(prefab)
	end)
end

--滚动条格子数量
function ForgeGem:GetNumberOfCells()
	return #self.scroller_data
end

--滚动条格子大小
function ForgeGem:GetCellSize()
	return 110
end

--帮助
function ForgeGem:ClickHelp()
	local tips_id = 147    -- 宝石tips
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

--滚动条刷新
function ForgeGem:GetCellView(scroller, data_index, cell_index)

	local cell = scroller:GetCellView(self.enhanced_cell_type)

	data_index = data_index + 1
	local scroller_cell = self.cell_list[cell]
	if nil == scroller_cell then
		self.cell_list[cell] = GemScrollerCell.New(cell.gameObject)
		scroller_cell = self.cell_list[cell]
		scroller_cell.mother_view = self
		scroller_cell.root_node.toggle.group = self.scroller.toggle_group
	end
	self.scroller_data[data_index].data_index = data_index
	scroller_cell:SetData(self.scroller_data[data_index])
	return cell
end

--按下了自动升级
function ForgeGem:AutoUpgradeClick()
	local data = self.mother_view:GetSelectData()
	if data.item_id == nil then
		--选了空装备格
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return
	end
	self:AutoUpgrade()
end

--自动升级
function ForgeGem:AutoUpgrade()
	local reason_list = {}
	for i=1,#self.gem_list do
		local have_upgrade, reason = self.gem_list[i]:AutoUpgrade(true)
		reason_list[i] = reason
		if have_upgrade then
			self.auto_upgradeing:SetValue(true)
			self:CancelQuest()
			self.time_quest = GlobalTimerQuest:AddDelayTimer(function()
				local bag_empty_num = ItemData.Instance:GetEmptyNum()
				if bag_empty_num ~= 0 then
					self:AutoUpgrade()
				else
					self:CancelAutoUpgradeClick()
				end
			end, 0.5)
			return
		end
	end
	self.auto_upgradeing:SetValue(false)
	local data = self.mother_view:GetSelectData()
	if data.param.strengthen_level == 0 then
		--开启孔位数量为0时
		-- TipsCtrl.Instance:ShowSystemMsg(Language.Forge.OpenMorePos)
		return
	end
	for k,v in pairs(reason_list) do
		if v ~= 1 then
			-- TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoEnoughGem)
			return
		end
	end
	TipsCtrl.Instance:ShowSystemMsg(Language.Forge.AllGemMaxLevel)
end

function ForgeGem:CancelAutoUpgrade()
	self.auto_upgradeing:SetValue(false)
	self:CancelQuest()
end

function ForgeGem:CancelQuest()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function ForgeGem:CancelAutoUpgradeClick()
	self:CancelAutoUpgrade()
end

function ForgeGem:BuyClick()
	--跳转商城
	ViewManager.Instance:Open(ViewName.Shop, nil,"from_duanzao", {index = 2})
end

--打开或关闭全身宝石奖励
function ForgeGem:ShowOrHideTotalGem(is_show)
	-- if is_show then
	-- 	self.total_gem_tips:SetData()
	-- end
	-- self.total_gem_tips:SetActive(is_show)
	local level, current_cfg, next_cfg = ForgeData.Instance:GetTotalGemCfg()
	TipsCtrl.Instance:ShowTotalAttrView(Language.Forge.ForgeGemSuitAtt, level, current_cfg, next_cfg)
end

--点击绑定事件
function ForgeGem:OnClick()
	self:CancelAutoUpgrade()
	self:Flush()
end

function ForgeGem:OpenCallback()
	self:CancelAutoUpgrade()
	-- self.total_gem_tips:SetActive(false)
end

--不显示数据
function ForgeGem:ShowEmpty()
	for k,v in pairs(self.gem_list) do
		v:ShowEmpty()
	end
	self.equip_icon:SetAsset("","")
	self.is_show:SetValue(false)
end

function ForgeGem:Flush()
	--隐藏宝石选项和宝石列表
	self:HideTips()
	--获取被选中装备的信息
	local data = self.mother_view:GetSelectData()
	if data.item_id == nil then
		self:ShowEmpty()
		return
	end
	--被选中装备赋值
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	self.equip_icon:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
	--刷新五个宝石格子
	local gem_data = ForgeData.Instance:GetEquipGemInfo(data)
	ForgeData.Instance:SetCurEquipGemInfo(gem_data)
	for i=1,7 do
		local limit_cfg = ForgeData.Instance:GetGemOpenLimitCfg(self.cell_index)
		if i == 6 and gem_data[i-1].gem_state == 0 then
			self.GemCellsix:SetActive(false)
			self.imageleft:SetActive(false)
		elseif i == 6 and gem_data[i-1].gem_state ~= 0 then
			self.GemCellsix:SetActive(true)
			self.imageleft:SetActive(true)
		elseif i == 7 and gem_data[i-1].gem_state == 0 then
			self.GemCellseven:SetActive(false)
			self.imageright:SetActive(false)
		elseif i == 7 and gem_data[i-1].gem_state ~= 0 then
			self.GemCellseven:SetActive(true)
			self.imageright:SetActive(true)
		end
		self.gem_list[i]:SetData(gem_data[i - 1])
	end
	local power = ForgeData.Instance:GetTotalGemPower()
	self.is_show:SetValue(true)
	self.gem_power:SetValue(power)
	self:SetEquipModel(data)

end

function ForgeGem:SetEquipModel(data)
	if ForgeData.Instance:GetCurOpenViewIndex() ~= 2 then
		return
	end
	--设置模型
	local model_index = "000" .. data.data_index + 1

	if nil ~= self.model_index and self.model_index == model_index then
		return
	end

	self.model_index = model_index
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if nil ~= self.model then
		-- local bundle, asset = ResPath.GetForgeEquipModel(model_index)
		-- self.model:SetMainAsset(bundle,asset)
		-- self:SetEquipModelBgEffect(item_cfg.color)
		-- self:SetEquipModelGlowEffect(item_cfg.color)
		-- self:FlushFlyAni()
	end
	self.equip_cell:SetData(data)
end

--模型出场动作
function ForgeGem:FlushFlyAni()
	if self.tweener then
		self.tweener:Pause()
	end
	self.model_display.rect:SetLocalScale(0, 0, 0)
	local target_scale = Vector3(1, 1, 1)
	self.tweener = self.model_display.rect:DOScale(target_scale, 0.5)
end

function ForgeGem:CloseUpStarView()
	if self.tweener then
		self.tweener:Pause()
		self.tweener = nil
	end
end

function ForgeGem:SetEquipModelBgEffect(color)

	-- if self.color ~= color then
	-- 	local bundle, asset = ResPath.GetForgeEquipBgEffect(color)
	-- 	self.color = color
	-- 	PrefabPool.Instance:Load(AssetID(bundle, asset), function(prefab)
	-- 		if prefab then
	-- 			if self.equip_bg_effect_obj then
	-- 				GameObject.Destroy(self.equip_bg_effect_obj)
	-- 				self.equip_bg_effect_obj = nil
	-- 			end
	-- 			local obj = GameObject.Instantiate(prefab)
	-- 			local transform = obj.transform
	-- 			transform:SetParent(self.model_bg_effect.transform, false)
	-- 			self.equip_bg_effect_obj = obj.gameObject
	-- 			self.color = 0
	-- 			PrefabPool.Instance:Free(prefab)
	-- 		end
	-- 	end)
	-- end
end

function ForgeGem:SetEquipModelGlowEffect(color)
	-- if self.color_glow ~= color then
		-- local bundle, asset = ResPath.GetForgeEquipGlowEffect(color)
		-- self.color_glow = color
		-- PrefabPool.Instance:Load(AssetID(bundle, asset), function(prefab)
		-- 	if prefab then
		-- 		if self.equip_glow_effect_obj then
		-- 			GameObject.Destroy(self.equip_glow_effect_obj)
		-- 			self.equip_glow_effect_obj = nil
		-- 		end
		-- 		local obj = GameObject.Instantiate(prefab)
		-- 		local transform = obj.transform
		-- 		transform:SetParent(self.model_glow_effect.transform, false)
		-- 		self.equip_glow_effect_obj = obj.gameObject
		-- 		self.color_glow = 0
		-- 		PrefabPool.Instance:Free(prefab)
		-- 	end
		-- end)
	-- end
end

--设置可用宝石列表的数据
function ForgeGem:SetScrollerData(data)
	self.scroller_data = data
end

--镶嵌按下后
function ForgeGem:InlayClick()
	if next(self.scroller_data) == nil then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NotSelectGem)
		return
	end
	if self.replace_flag then
		self.replace_flag = false
		self:UnloadClick()
	end
	ForgeCtrl.Instance:SendStoneInlay(self.select_cell_index, self.select_gem_bag_index, 1)
	self:ShowOrHideGemList(false)
end

--显示或隐藏可镶嵌列表
function ForgeGem:ShowOrHideGemList(is_show, cell_index)
	self.is_show_gem_list:SetValue(is_show)
	if is_show then
		self.inlay_button_text.text.text = Language.Forge.Inlay
		self.select_cell_index = cell_index
		self.gem_scroller_select_index = 1
		self.scroller.scroller:ReloadData(0)
	else
		self.replace_flag = false
	end
end

--显示或隐藏宝石选项
function ForgeGem:ShowOrHideGemOption(is_show, pos, cell_index)
	self.is_show_gem_option:SetValue(is_show)
	--出现位置
	if is_show then
		self.gem_option_plane.transform.position = pos
		self.select_cell_index = cell_index

		local data = self.mother_view:GetSelectData()
		local gem_data = ForgeData.Instance:GetEquipGemInfo(data)
		local gem_id = gem_data[self.select_cell_index].gem_id
		local gem_cfg = ForgeData.Instance:GetGemCfg(gem_id)
		local gem_type = ForgeData.Instance:GetGemTypeByid(gem_id)
		if nil == gem_cfg then return end
		local flag = gem_type ~= 4	--该宝石在商城没卖，所以不显示升级按钮
		local type_flag = gem_cfg.stone_type ~= 5	-- 特殊宝石不显示升级按钮
		self.level_up_button:SetActive(gem_cfg.level < 10 and flag and type_flag)
	end
end

--隐藏所有弹出窗
function ForgeGem:HideTips()
	self:ShowOrHideGemList(false)
	self:ShowOrHideGemOption(false)
end

function ForgeGem:UnloadClick()
	ForgeCtrl.Instance:SendStoneInlay(self.select_cell_index, 0, 0)
	self:ShowOrHideGemOption(false)
end

function ForgeGem:LevelUpClick()
	local data = self.mother_view:GetSelectData()
	local gem_data = ForgeData.Instance:GetEquipGemInfo(data)

	local gem_id = gem_data[self.select_cell_index].gem_id
	local gem_type = ForgeData.Instance:GetGemTypeByid(gem_id)
	local bag_gems_data = ForgeData.Instance:GetGemsInBag(gem_type)
	local gem_cfg = ForgeData.Instance:GetGemCfg(gem_id)

	if gem_cfg then
		for k,v in pairs(bag_gems_data) do
			local bag_gem_cfg = ForgeData.Instance:GetGemCfg(v.item_id)
				if bag_gem_cfg and bag_gem_cfg.level > gem_cfg.level then
					self.gem_list[self.select_cell_index+1]:ImproveClick()
				return
			end
		end
	end

	-- local gem_num = 1
	-- local gem_level = 1
	-- local danjia = 10
	-- if gem_cfg.level >= 3 then
	-- 	gem_level = 3
	-- 	danjia = 40
	-- 	for i=1, gem_cfg.level - 2 do
	-- 		gem_num = gem_num * 4
	-- 	end
	-- else
	-- 	for i=1, gem_cfg.level do
	-- 		gem_num = gem_num * 4
	-- 	end
	-- 	gem_level = 1
	-- 	danjia = 10
	-- end
	-- if gem_cfg.level == gem_level then
	-- 	gem_num = gem_num - 1
	-- end
	-- local need_gold = gem_num * danjia
	local is_can_upgrade = self.gem_list[self.select_cell_index+1].is_can_upgrade
	if is_can_upgrade then
		ForgeCtrl.Instance:SendStoneUpgrade(self.select_cell_index, 1)
	else
		local normal_item_cfg = ForgeData.Instance:GetGemCfgByTypeAndLevel(gem_type, 1)
		TipsCtrl.Instance:ShowItemGetWayView(normal_item_cfg.item_id)
	end
	self:ShowOrHideGemOption(false)
	-- TipsCtrl.Instance:ShowCommonAutoView("", Language.Forge.LevelUpTips, func)
end

function ForgeGem:SetSelectGemBagIndex(index)
	self.select_gem_bag_index = index
end

function ForgeGem:ReplaceClick()
	self.replace_flag = true
	self:ShowOrHideGemList(true, self.select_cell_index)
	self.inlay_button_text.text.text = Language.Forge.Replace
	self:ShowOrHideGemOption(false)
end
function ForgeGem:UpgradClick()
	ForgeCtrl.Instance:SendStoneUpgrade(self.select_cell_index, 1)
	self:ShowOrHideGemOption(false)
end

-----------------------------------------
--宝石格子
GemCell = GemCell or BaseClass(BaseCell)

function GemCell:__init()
	--属性显示
	self.is_show_attr = self:FindVariable("IsShowAttr")
	--属性
	self.attr_list = {}
	self.attr_content = {}
	for i = 1, 3 do
		self.attr_list[i] = self:FindObj("Attr"..i)
		self.attr_content[i] = self:FindObj("AttContent" .. i)
	end
	--锁定图标
	self.is_locked = self:FindVariable("IsLocked")
	--可升级图标
	self.improve_button = self:FindObj("ImproveButton")
	self.improve_button.button:AddClickListener(BindTool.Bind(self.ImproveClick, self))

	self.is_show_can_upgrade = self:FindVariable("IsShowCanUpgrade")
	--宝石图标
	self.gem_icon = self:FindObj("GemIcon")
	self.gem_icon.button:AddClickListener(BindTool.Bind(self.GemIconClick, self))
	--宝石品质背景图
	self.gem_icon_bg = self:FindVariable("GemIconBg")
	self.gem_icon_bg_obg = self:FindObj("GemIconBg")
	self.is_show_bg = self:FindVariable("IsShowBg")
	--可镶嵌加号按钮
	self.btn_plus = self:FindObj("PlusButton")
	self.btn_plus.button:AddClickListener(BindTool.Bind(self.PlusClick, self))
	--是否可升级
	self.is_can_upgrade = false
	--是否可镶嵌
	self.is_can_inlay = false
	--背包里的宝石信息
	self.bag_gem_data = {}
	self.list_gem_data = {}
	--自动升级
	self.auto_upgrade = false

	self.effect_obj = nil
	self.is_load_effect = false
end

function GemCell:__delete()
	if self.effect_obj then
		GameObject.Destroy(self.effect_obj)
		self.effect_obj = nil
	end
	self.is_load_effect = nil
	self.mother_view = nil
end

--宝石格子的状态: 0、锁定 1、可镶嵌 2、已镶嵌
function GemCell:OnFlush()
	self.is_can_inlay = false
	self.best_gem = nil
	self.improve_button:SetActive(false)
	self.is_can_upgrade = false
	self.attr_content[1]:SetActive(true)
	self.attr_content[2]:SetActive(true)
	self.attr_content[3]:SetActive(true)
	self.attr_list[1]:SetActive(true)
	self.attr_list[2]:SetActive(true)
	self.attr_list[3]:SetActive(true)

	if nil == self.data then
		return
	end
	--0、锁定
	if self.data.gem_state == 0 then
		self.is_show_attr:SetValue(true)
		self.is_locked:SetValue(true)
		self.btn_plus:SetActive(false)
		self.improve_button:SetActive(false)
		self.gem_icon:SetActive(false)
		self.is_show_bg:SetValue(false)
		for i=1,3 do
			if i == 1 then
				local limit_cfg = ForgeData.Instance:GetGemOpenLimitCfg(self.cell_index)
				local text_value = ""
				if limit_cfg.limit ~= 0 then
					local sub_level, rebirth = PlayerData.GetLevelAndRebirth(limit_cfg.param1)
					local str = string.format(Language.Common.LevelFormat2, rebirth, sub_level)	
					text_value = string.format(Language.Forge.GemOpenLimit[limit_cfg.limit], str)
				end
				self.attr_list[i].text.text = text_value
			else
				self.attr_list[i]:SetActive(false)
				self.attr_content[i]:SetActive(false)
			end
		end

	--1、空的
	elseif self.data.gem_state == 1 then
		self.is_show_attr:SetValue(false)
		self.is_locked:SetValue(false)
		self.gem_icon:SetActive(false)
		self.is_show_bg:SetValue(false)
		if nil ~= self.effect_obj then
			self.effect_obj:SetActive(false)
		end
		self.btn_plus:SetActive(true)
		self.list_gem_data = ForgeData.Instance:GetCurBagGemList()

		self.bag_gem_data = ForgeData.Instance:GetCurBagGemList()
		if self.bag_gem_data ~= nil and next(self.bag_gem_data) ~= nil then
			-- self.is_can_inlay = true
			for k,v in pairs(self.bag_gem_data) do 
				local stone_type = ForgeData.Instance:GetGemTypeByid(v.item_id)
				if 0 <= self.cell_index  and self.cell_index <= 4 and 0 <= stone_type and stone_type <= 4 then
					self.is_can_inlay = true
				end
			end
		end
		-- 特殊宝石
		if self.cell_index >= 5 then
			self.is_can_inlay = ForgeData.Instance:GetSpecialGemNumInBag() > 0
		end
		self.improve_button:SetActive(self.is_can_inlay)

	--2、已镶嵌
	elseif self.data.gem_state == 2 then
		self.is_show_attr:SetValue(true)
		self.is_locked:SetValue(false)
		self.btn_plus:SetActive(false)
		self.gem_icon:SetActive(true)
		self.is_show_bg:SetValue(true)
		self.gem_icon.image:LoadSprite(ResPath.GetItemIcon(self.data.gem_id))

		local icon_cfg, _ = ItemData.Instance:GetItemConfig(self.data.gem_id)
		local asset = QUALITY_ICON[icon_cfg.color]
		self.gem_icon_bg:SetAsset("uis/images_atlas", asset)

--------------------------------------
		if self.effect_obj then
			GameObject.Destroy(self.effect_obj)
			self.effect_obj = nil
		end

		if not self.is_load_effect and not self.effect_obj and icon_cfg.special_show and 1 == icon_cfg.special_show then
			self.is_load_effect =  true
			local bundle, asset = ResPath.GetItemEffect(icon_cfg.color)
			PrefabPool.Instance:Load(AssetID(bundle, asset), function(prefab)
				if prefab then
					local obj = GameObject.Instantiate(prefab)
					local transform = obj.transform
					if self.effect_root then
						transform:SetParent(self.effect_root.transform, false)
					else
						transform:SetParent(self.gem_icon_bg_obg.transform, false)
					end
					self.effect_obj = obj.gameObject
					self.is_load_effect = false
					PrefabPool.Instance:Free(prefab)
				end
			end)
		end
--------------------------------------

		--处理属性
		local attrs = ForgeData.Instance:GetGemAttr(self.data.gem_id)
		for i=1,3 do
			if attrs[i] == nil or attrs[i] == 0 then
				self.attr_list[i]:SetActive(false)
				self.attr_content[i]:SetActive(false)
			else
				self.attr_list[i]:SetActive(true)
				self.attr_content[i]:SetActive(true)
				self.attr_list[i].text.text = attrs[i].attr_name..':  '..attrs[i].attr_value
			end
		end
		local gem_type = ForgeData.Instance:GetGemTypeByid(self.data.gem_id)
		self.bag_gem_data = ForgeData.Instance:GetGemsInBag(gem_type)
		--处理可替换
		local max_id = self.data.gem_id
		for k,v in pairs(self.bag_gem_data) do
			if v.item_id > max_id then
				 self.best_gem = v
				 max_id = v.item_id
			end
		end
		if self.best_gem == nil then
			--处理可升级
			local forge_gem_cfg = ForgeData.Instance:GetGemCfg(self.data.gem_id)
			local level = forge_gem_cfg.level
			local next_cfg = ForgeData.Instance:GetGemCfgByTypeAndLevel(forge_gem_cfg.stone_type, level + 1)
			if next_cfg ~= nil then
				local upgrade_need_energy = math.pow(3, level) - math.pow(3, level - 1)
				local had_energy = 0
				for k,v in pairs(self.bag_gem_data) do
					if v.item_id <= forge_gem_cfg.item_id then
						local tmp_forge_gem_cfg = ForgeData.Instance:GetGemCfg(v.item_id)
						if tmp_forge_gem_cfg then
							had_energy = had_energy + (math.pow(3, tmp_forge_gem_cfg.level - 1) * v.num)
						end
					end
				end
				if had_energy >= upgrade_need_energy then
					self.is_can_upgrade = true
					self.improve_button:SetActive(true)
				end
			else
				self.max_level = true
			end
		else
			self.improve_button:SetActive(true)
		end
	end
end

--自动提升
function GemCell:AutoUpgrade(is_from_button)
	if self.is_can_inlay then
		--格子为空,背包有宝石可镶嵌
		if self.cell_index >= 5 then
			local special_gem_count, special_gem_list = ForgeData.Instance:GetSpecialGemNumInBag()
			if special_gem_count > 0 then
				for k,v in pairs(special_gem_list) do
					ForgeCtrl.Instance:SendStoneInlay(self.cell_index, k, 1)
					return true
				end
			else
				return false
			end
		else
			local best_gem = nil
			local max_level = 0
			for k,v in pairs(self.bag_gem_data) do
				local gem_cfg = ForgeData.Instance:GetGemCfg(v.item_id)
				if gem_cfg and gem_cfg.level > max_level then
					best_gem = v 
					max_level = gem_cfg.level
				end
			end
			if best_gem then
				local stone_type = ForgeData.Instance:GetGemTypeByid(best_gem.item_id)
				if 0 <= self.cell_index and self.cell_index <= 4 and 0 <= stone_type and stone_type <= 4 then
					ForgeCtrl.Instance:SendStoneInlay(self.cell_index, best_gem.index, 1)
				else
					return false
				end
			end
			return true
		end
	else
		local have_improve, reason = self:ImproveClick(is_from_button)
		return have_improve, reason
	end
end

function GemCell:PlusClick()
	if self.is_can_inlay then
		if self.cell_index == 5 or self.cell_index == 6 then
			local data = {}
			local special_gem_bag_list = ForgeData.Instance:GetGemsInBag(SPECIAL_GEM_TYPE)
			for k ,v in pairs(special_gem_bag_list) do
				table.insert(data,v)
			end
			self.mother_view:SetScrollerData(data)
		else
			local list = {}
			for k1 ,v1 in ipairs(self.list_gem_data) do 
				local stone_type1 = ForgeData.Instance:GetGemTypeByid(v1.item_id)
				if stone_type1 ~= 5 then
					table.insert(list,v1)
				end
			end
			self.mother_view:SetScrollerData(list)
		end
		self.mother_view:ShowOrHideGemList(true, self.cell_index)
	else
		-- local gem_type = ForgeData.Instance:GetGemTypeByid(self.data.gem_id)
		local gem_type = ForgeData.Instance:GetMinType()
		if self.cell_index == 5 or self.cell_index == 6 then
			gem_type = ForgeData.Instance:GetSpecialMinType() or 5
		end

		local gem_cfg = ForgeData.Instance:GetGemCfgByTypeAndLevel(gem_type, 1)

		local func = function(item_id, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, gem_cfg.item_id, nil, 1)
	end
end

function GemCell:GemIconClick()
	local dis = 20
	local pos = self.root_node.transform.position
	if self.cell_index < 2 then
		pos.x = pos.x - dis
	else
		pos.x = pos.x + dis
	end
	self.mother_view:ShowOrHideGemOption(true, pos, self.cell_index)
end

function GemCell:ShowEmpty()
	self.is_show_attr:SetValue(false)
	self.is_locked:SetValue(false)
	self.btn_plus:SetActive(false)
	self.gem_icon:SetActive(false)
	self.improve_button:SetActive(false)
end

--按下了自动镶嵌/替换/升级
function GemCell:ImproveClick(is_from_button)
	if self.is_can_inlay then
		self:PlusClick()
		return
	end

	if self.best_gem ~= nil then
		--可换更好的宝石
		ForgeCtrl.Instance:SendStoneInlay(self.cell_index, 0, 0)
		ForgeCtrl.Instance:SendStoneInlay(self.cell_index, self.best_gem.index, 1)
		return true
	elseif self.is_can_upgrade then
		if is_from_button then
			return false , 0
		end
		--可升级
		ForgeCtrl.Instance:SendStoneUpgrade(self.cell_index, 1)
		return true
	else
		if self.max_level then
			return false, 1
		else
			return false, 0
		end
	end
end

-----------------------------------------
--可用宝石滚动条格子
GemScrollerCell = GemScrollerCell or BaseClass(BaseCell)

function GemScrollerCell:__init()
	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_cell:ListenClick(function()end)
	self.gem_name = self:FindVariable("Name")
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleValueChange, self))
end

function GemScrollerCell:__delete()
	self.item_cell:DeleteMe()
end

function GemScrollerCell:OnFlush()
	self.item_cell:SetData(self.data)
	self.gem_name:SetValue(self.data.cfg.name)
	if self.mother_view.gem_scroller_select_index == self.data.data_index then
		self.root_node.toggle.isOn = false
		self.root_node.toggle.isOn = true
	else
		self.root_node.toggle.isOn = false
	end
end

function GemScrollerCell:OnToggleValueChange(is_on)
	if is_on then
		self.mother_view.gem_scroller_select_index = self.data.data_index
		self.mother_view:SetSelectGemBagIndex(self.data.index)
	end
end

-- ----------------------------
-- -- 宝石套装Tips
-- ----------------------------
-- TotalGemTips = TotalGemTips or BaseClass(FullStrengthTips)
-- function TotalGemTips:SetAttr(message, attr_cfg)
-- 	local attrs = CommonDataManager.GetAdvanceAttributteByClass(attr_cfg)
-- 	for k,v in pairs(attrs) do
-- 		if v > 0 then
-- 			message = message..ToColorStr(CommonDataManager.GetAdvanceAttrName(k)..":  ", TEXT_COLOR.YELLOW)..
-- 			ToColorStr((v/100), TEXT_COLOR.GREEN).."%\n"
-- 		end
-- 	end
-- 	return message
-- end

-- function TotalGemTips:SetStart1(cfg)
-- 	self.start1:SetValue(Language.Forge.GemTotalLevel..ToColorStr(cfg.total_level,TEXT_COLOR.GREEN))
-- end

-- function TotalGemTips:SetStart2(cfg, level)
-- 	self.start2:SetValue(Language.Forge.GemTotalLevel..ToColorStr(cfg.total_level,TEXT_COLOR.GREEN)..'  ('..
-- 		ToColorStr(level, TEXT_COLOR.RED)..ToColorStr(' / '..cfg.total_level,TEXT_COLOR.GREEN)..')')
-- end

-- function TotalGemTips:GetBaseInfo()
-- 	return ForgeData.Instance:GetTotalGemCfg()
-- end

