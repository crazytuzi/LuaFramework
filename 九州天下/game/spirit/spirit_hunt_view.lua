SpiritHuntView = SpiritHuntView or BaseClass(BaseRender)

local MAX_GRID_NUM = 16
local ROW = 4
local COLUMN = 4

function SpiritHuntView:__init(instance)
	self.onece_price = self:FindVariable("OncePrice")
	self.ten_price = self:FindVariable("TenPrice")
	self.hour = self:FindVariable("hour")
	self.min = self:FindVariable("min")
	self.sec = self:FindVariable("sec")
	self.show_help_tip = self:FindVariable("ShowHelpTip")
	self.show_time = self:FindVariable("ShowTime")
	self.show_free = self:FindVariable("ShowFree")
	self.show_free_red_point = self:FindVariable("ShowFreeRedPoint")

	self.show_once_card = self:FindVariable("ShowOnceCard")
	self.once_card_name = self:FindVariable("OnceCardName")
	self.once_card_num = self:FindVariable("OnceCardNum")

	self.show_ten_card = self:FindVariable("ShowTenCard")
	self.ten_card_name = self:FindVariable("TenCardName")
	self.ten_card_num = self:FindVariable("TenCardNum")

	self.page_count = 1
    --illustrated
    self.illustrated_display=self:FindObj("illustruate_display")
    self.illustrated_model=RoleModel.New()
    self.illustrated_model:SetDisplay(self.illustrated_display.ui3d_display)
    self.illustrated_fighted_power=self:FindVariable("fight_power")

    self.illustrated_name=self:FindVariable("illustrate_name")
    self.illustrated_description=self:FindVariable("illustrate_description")
    self.quality=self:FindVariable("quality")
    self.quality_discription=self:FindVariable("shizhanhui")
    self.temp_illustrated_data=nil


	self.show_toggles = {
		self:FindVariable("ShowToggle1"),
		self:FindVariable("ShowToggle2"),
		self:FindVariable("ShowToggle3"),
		self:FindVariable("ShowToggle4")
	}

	self.play_ani_toggle = self:FindObj("PlayAniToggle").toggle

	self:ListenEvent("OnClickOnece", BindTool.Bind(self.OnClickOnece, self))
	self:ListenEvent("OnClickTen", BindTool.Bind(self.OnClickTen, self))
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickPlayAniToggle", BindTool.Bind(self.OnClickPlayAniToggle, self))
    self:ListenEvent("CloseIllustratedDispaly",BindTool.Bind(self.CloseIllustratedDispaly,self))
	-- self.dis_modle_list = {}
	-- for i = 1, 4 do
	-- 	local display = self:FindObj("Display"..i)
	-- 	local dis_modle = RoleModel.New()
	-- 	dis_modle:SetDisplay(display.ui3d_display)
	-- 	self.dis_modle_list[i] = dis_modle
	-- end

	self.list_view = self:FindObj("ListView")
	local list_simple_delegate = self.list_view.list_simple_delegate
	list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumOfCell, self)
	list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.fix_show_time = 8
	self.time_quest = {}
	self.display_items = {}
	self.is_first_open = true
	self.power_data=nil
end

function SpiritHuntView:__delete()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self.illustrated_model:DeleteMe()

	-- for k, v in pairs(self.dis_modle_list) do
	-- 	v:DeleteMe()
	-- end
	-- self.dis_modle_list = {}
	self.fix_show_time = nil

	self.page_count = nil
	self.is_first_open = nil

	for k, v in pairs(self.display_items) do
		v:DeleteMe()
	end
	self.display_items = {}

	for k, v in pairs(self.time_quest) do
		GlobalTimerQuest:CancelQuest(v)
	end
	self.time_quest = {}
end

function SpiritHuntView:OnClickPlayAniToggle()
	SpiritData.Instance:SetPlayAniState(self.play_ani_toggle.isOn)
end

function SpiritHuntView:OnClickOnece()
	SpiritData.Instance:SetChestshopMode(CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_1)
	SpiritCtrl.Instance:SendHuntSpiritReq(CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_1, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)
end

function SpiritHuntView:OnClickTen()
	SpiritData.Instance:SetChestshopMode(CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_10)
	SpiritCtrl.Instance:SendHuntSpiritReq(CHEST_SHOP_MODE.CHEST_SHOP_JL_MODE_10, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_JINGLING)
end

function SpiritHuntView:OnClickClose()
	self.show_help_tip:SetValue(false)
end

function SpiritHuntView:OnClickHelp()
	self.show_help_tip:SetValue(true)
	self:IllustrateDefulatShow(15016)
end

function SpiritHuntView:GetNumOfCell()
	local page_count = #SpiritData.Instance:GetSpiritResourceCfg() - MAX_GRID_NUM
	page_count = (page_count > 0) and page_count or 0
	local list_page_scroll = self.list_view.list_page_scroll
	local page = 0
	if page_count > 0 then
		page = math.floor(page_count / ROW / COLUMN) + 1
	end
	list_page_scroll:SetPageCount(page + 1)
	return (MAX_GRID_NUM + page * ROW * COLUMN) / ROW
end

function SpiritHuntView:RefreshCell(cell, data_index)
	local group = self.display_items[cell]---nil
	if nil == group then
		group = DisplaySpiritItemGroup.New(cell)
		group:SetToggleGroup(self.list_view.toggle_group)
		self.display_items[cell] = group
	end
	-- 计算索引
	local page = math.floor(data_index / COLUMN)
	local column = data_index - page * COLUMN
	local grid_count = COLUMN * ROW
	for i = 1, ROW do
		local index = (i - 1) * COLUMN  + column + (page * grid_count)
	    --竖行遍历

		-- 获取数据信息
		local data = SpiritData.Instance:GetDisPlaySpiritListFromHigh()[index + 1]
		data = data or {}
		if data.id then
			data.item_id = data.id
			data.param = {strengthen_level = 1}
			local cfg = SpiritData.Instance:GetSpiritTalentAttrCfgById(data.item_id)-- 获取精灵天赋属性
			if index <= 5 then
				for i = 1, 7 do
					if cfg["type"..i] > 0  then
						data.param.xianpin_type_list = data.param.xianpin_type_list or {}
						data.param.xianpin_type_list[i] = i
					end
				end
			end
		end
		data.locked = false
		if data.index == nil then
			data.index = index
		end
		if data.index==1 then 
			self.temp_cell=group
		end
		group:SetData(i, data)
		-- group:ShowHighLight(i, not data.locked)
		group:SetHighLight(i, (self.cur_index == index and nil ~= data.item_id))
		group:ListenClick(i, BindTool.Bind(self.HandleItemOnClick, self, data, group, i, index))
		group:SetInteractable(i, (nil ~= data.item_id or data.locked))
	end
end

function SpiritHuntView:HandleItemOnClick(data, group, i, index)
	if data == nil or data.item_id == nil then
		return
	end
    if data==self.temp_illustrated_data then --重复选中同一精灵 禁止刷新显示
    	return 
    end
	-- if cur_index ~=nil then 
	    self.cur_index = index
	--     group:SetHighLight(i, self.cur_index == index)
 --    end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
	self:SetRoleModel(item_cfg.is_display_role,data)
	local str="<color=%s>"..item_cfg.name.."</color>"
	self.illustrated_name:SetValue(string.format(str, SOUL_NAME_COLOR[item_cfg.color]))
	local spirit_data=SpiritData.Instance:GetSpiritResourceCfg()
	spirit_data=ListToMap(spirit_data,"id")
    self.illustrated_description:SetValue(spirit_data[data.item_id].description)
    self.illustrated_fighted_power:SetValue(CommonDataManager.GetCapability(self:CalculatePower(data.item_id,1)))
    self.quality:SetAsset(ResPath.GetQualityTagBg(Common_Five_Rank_Color[item_cfg.color]))
    self.quality_discription:SetValue(Language.QualityAttr[Common_Five_Rank_Color[item_cfg.color]])
    self.temp_illustrated_data=data	
    self.illustrated_display.ui3d_display:ResetRotation()

	-- TipsCtrl.Instance:OpenItem(data)
end

function SpiritHuntView:CalculatePower(item_id,level)
    local spirit_data=SpiritData.Instance:GetSpiritLevelConfig()
    spirit_data=ListToMap(spirit_data,"item_id","level")
    return spirit_data[item_id][level]
end

function SpiritHuntView:IllustrateDefulatShow(item_id)
	local defulat_item_id=item_id or math.random(15001,15016)
	local defulat_data=SpiritData.Instance:GetSpiritResourceCfg()
	defulat_data=ListToMap(defulat_data,"id")
	local data=defulat_data[defulat_item_id]
	local defulat_item_cfg=ItemData.Instance:GetItemConfig(defulat_item_id)
	self.illustrated_description:SetValue(defulat_data[defulat_item_id].description)
	self:SetRoleModel(defulat_item_cfg.is_display_role,data)
	local str="<color=%s>"..defulat_item_cfg.name.."</color>"
	self.illustrated_name:SetValue(string.format(str, SOUL_NAME_COLOR[defulat_item_cfg.color]))
    self.illustrated_fighted_power:SetValue(CommonDataManager.GetCapability(self:CalculatePower(defulat_item_id,1)))
    self.quality:SetAsset(ResPath.GetQualityTagBg(Common_Five_Rank_Color[defulat_item_cfg.color]))
    self.quality_discription:SetValue(Language.QualityAttr[Common_Five_Rank_Color[defulat_item_cfg.color]])	
    self.cur_index=0
    self.illustrated_display.ui3d_display:ResetRotation()

    if self.list_view.scroller.isActiveAndEnabled then
      self.list_view.scroller:RefreshActiveCellViews()
    end
end


function SpiritHuntView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	for k, v in pairs(self.time_quest) do
		GlobalTimerQuest:CancelQuest(v)
	end
	self.time_quest = {}
	self.is_first_open = true
	self.show_help_tip:SetValue(false)
end

function SpiritHuntView:RefreshDisplayItem()
	if self.list_view.scroller.isActiveAndEnabled then
		local page_count = #SpiritData.Instance:GetSpiritResourceCfg() - MAX_GRID_NUM
		local page = 0
		if self.page_count ~= (page_count + 1) then
			self.list_view.scroller:ReloadData(0)
		else
			self.list_view.scroller:RefreshActiveCellViews()
		end
		if page_count > 0 then
			page = math.floor(page_count / ROW / COLUMN) + 1
			for i = 1, page do
				self.show_toggles[i]:SetValue(true)
			end
			if page ~= 4 then
				for i = page + 1, 4 do
					self.show_toggles[i]:SetValue(false)
				end
			end
		else
			for i = 1, 4 do
				self.show_toggles[i]:SetValue(false)
			end
		end
		self.page_count = page_count + 1
	end
end

function SpiritHuntView:SetModleRestAni(model, index)
	local timer = 8
	if not self.time_quest[index] then
		self.time_quest[index] = GlobalTimerQuest:AddRunQuest(function()
			timer = timer - UnityEngine.Time.deltaTime
			if timer <= 0 then
				if model then
					model:SetTrigger("rest")
				end
				timer = 8
			end
		end, 0)
	end
end

function SpiritHuntView:SetCardState()
	local cfg = ConfigManager.Instance:GetAutoConfig("chestshop_auto").other[1] or {}
	local once_card_num = ItemData.Instance:GetItemNumInBagById(cfg.jingling_use_itemid)
	local once_card_cfg = ItemData.Instance:GetItemConfig(cfg.jingling_use_itemid)

	self.show_once_card:SetValue(once_card_num > 0)
	if once_card_num > 0 and once_card_cfg then
		self.once_card_num:SetValue(once_card_num)
		local name_str = "<color="..SOUL_NAME_COLOR[once_card_cfg.color]..">"..once_card_cfg.name.."</color>"
		self.once_card_name:SetValue(name_str)
	end

	local ten_card_num = ItemData.Instance:GetItemNumInBagById(cfg.jingling_10_use_itemid)
	local ten_card_cfg = ItemData.Instance:GetItemConfig(cfg.jingling_10_use_itemid)

	self.show_ten_card:SetValue(ten_card_num > 0)
	if ten_card_num > 0 and ten_card_cfg then
		self.ten_card_num:SetValue(ten_card_num)
		local name_str = "<color="..SOUL_NAME_COLOR[ten_card_cfg.color]..">"..ten_card_cfg.name.."</color>"
		self.ten_card_name:SetValue(name_str)
	end
end

function SpiritHuntView:Flush()
	self:RefreshDisplayItem()

	local display_list = ConfigManager.Instance:GetAutoConfig("chestshop_auto").fumo_item_list
	if display_list and self.is_first_open then
		for k, v in pairs(display_list) do
			local bundle_main, asset_main = ResPath.GetSpiritModel(v.rare_item_id)
			local bundle_list_1 = {[SceneObjPart.Main] = bundle_main}
			local asset_list_1 = {[SceneObjPart.Main] = asset_main}
			UIScene:ModelBundle(bundle_list_1, asset_list_1, k)
			local call_back = function(model, root)
				local cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SPIRIT], v.rare_item_id, DISPLAY_PANEL.ADVANCE_SUCCE)
				if root then
					if cfg then
						root.transform.localPosition = cfg.position
						root.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
						root.transform.localScale = cfg.scale
					else
						root.transform.localPosition = Vector3(0, 0, 0)
						root.transform.localRotation = Quaternion.Euler(0, 0, 0)
						root.transform.localScale = Vector3(1, 1, 1)
					end
				end
				self:SetModleRestAni(model, k)
			end
			UIScene:SetModelLoadCallBack(call_back, k)
		end

		self.play_ani_toggle.isOn = false
		SpiritData.Instance:SetPlayAniState(false)
		self.is_first_open = false
	end

	if SpiritData.Instance:GethuntSpiritPriceCfg() then
		self.onece_price:SetValue(SpiritData.Instance:GethuntSpiritPriceCfg()[1].jingling_gold_1)
		self.ten_price:SetValue(SpiritData.Instance:GethuntSpiritPriceCfg()[1].jingling_gold_10)
	end

	local diff_time = SpiritData.Instance:GetHuntSpiritFreeTime() - TimeCtrl.Instance:GetServerTime()
	self.show_free_red_point:SetValue(diff_time <= 0)
	self.show_time:SetValue(diff_time > 0)
	self.show_free:SetValue(diff_time <= 0)

	self:SetCardState()

	if self.count_down == nil and diff_time > 0 then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				self.show_time:SetValue(false)
				return
			end
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			self.hour:SetValue(left_hour)
			self.min:SetValue(left_min)
			self.sec:SetValue(left_sec)
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end


function SpiritHuntView:CloseIllustratedDispaly()
   self.show_help_tip:SetValue(false)
   self.temp_illustrated_data=nil
   self.cur_index=0

end

function SpiritHuntView:SetRoleModel(display_role,data)--1
	local bundle, asset = nil, nil
	local res_id = 0
	if display_role == DISPLAY_TYPE.MOUNT then
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == data.item_id 	 then
				bundle, asset = ResPath.GetMountModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	--elseif display_role == DISPLAY_TYPE.XIAN_NV then
	elseif display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id ==data.item_id then
				bundle, asset = ResPath.GetWingModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	--elseif display_role == DISPLAY_TYPE.FASHION then
	--elseif display_role == DISPLAY_TYPE.HALO then
	elseif display_role == DISPLAY_TYPE.SPIRIT then
		for k, v in pairs(SpiritData.Instance:GetSpiritResourceCfg()) do
			if v.id == data.item_id or v.id==data.id then
				bundle, asset = ResPath.GetSpiritModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	--elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
	--elseif display_role == DISPLAY_TYPE.SHENGONG then
	--elseif display_role == DISPLAY_TYPE.SHENYI then
	end
	if self.illustrated_model and res_id > 0 then
		local DISPLAY_PANEL_ILLUSTRATED=12
		self.illustrated_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[display_role], res_id, DISPLAY_PANEL_ILLUSTRATED)--替换为DISPLAY_PANEL_ILLUSTRATED
	end

	if bundle and asset and self.illustrated_model then
		self.illustrated_model:SetMainAsset(bundle, asset)
	end
end




---------------------------------------------------------------------------
DisplaySpiritItemGroup = DisplaySpiritItemGroup or BaseClass(BaseRender)

function DisplaySpiritItemGroup:__init(instance)
	local item1 = ItemCell.New()
	item1:SetInstanceParent(self:FindObj("Item1"))
	local item2 = ItemCell.New()
	item2:SetInstanceParent(self:FindObj("Item2"))
	local item3 = ItemCell.New()
	item3:SetInstanceParent(self:FindObj("Item3"))
	local item4 = ItemCell.New()
	item4:SetInstanceParent(self:FindObj("Item4"))

	self.cells = {item1, item2, item3,item4}
end

function DisplaySpiritItemGroup:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function DisplaySpiritItemGroup:SetData(i, data)
	self.cells[i]:SetData(data)
end

function DisplaySpiritItemGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function DisplaySpiritItemGroup:SetToggleGroup(toggle_group)
	self.cells[1]:SetToggleGroup(toggle_group)
	self.cells[2]:SetToggleGroup(toggle_group)
	self.cells[3]:SetToggleGroup(toggle_group)
    self.cells[4]:SetToggleGroup(toggle_group)
end

function DisplaySpiritItemGroup:SetHighLight(i, enable)
	self.cells[i]:SetHighLight(enable)
end

function DisplaySpiritItemGroup:ShowHighLight(i, enable)
	self.cells[i]:ShowHighLight(enable)
end

function DisplaySpiritItemGroup:SetInteractable(i, enable)
	self.cells[i]:SetInteractable(enable)
end

----------------------------------------------------------------
IllustratedItem=IllustratedItem or BaseClass(BaseCell)