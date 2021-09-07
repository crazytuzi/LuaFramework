TreasureContentView = TreasureContentView or BaseClass(BaseRender)

TREASURE_FUNCTION_OPEN = 40

function TreasureContentView:__init(instance)
	self.is_buy_quick = false
	self.show_frame = TreasureFrameItem.New(self:FindObj("show_frame"))
	self.show_frame:Flush()
	self:ListenEvent("open_one_click", BindTool.Bind(self.OpenOneClick, self))
	self:ListenEvent("open_ten_click", BindTool.Bind(self.OpenTenClick, self))
	self:ListenEvent("open_fifty_click", BindTool.Bind(self.OpenFiftyClick, self))
	self:ListenEvent("mask_click", BindTool.Bind(self.CheckBoxClick, self))

	self.show_mask = self:FindVariable("is_mask")
	self.open_ten_money = self:FindVariable("open_ten_money")
	self.open_fifty_money = self:FindVariable("open_fifty_money")
	self.open_one_money = self:FindVariable("open_one_money")
	self.open_one_free_text = self:FindVariable("open_one_free_text")

	self.key_one_text = self:FindVariable("key_one_text")
	self.key_ten_text = self:FindVariable("key_ten_text")
	self.key_fifty_text = self:FindVariable("key_fifty_text")
	self.show_coin_text = self:FindVariable("show_coin_text")
	self.show_ten_coin_text = self:FindVariable("show_ten_coin_text")
	self.show_fifty_coin_text = self:FindVariable("show_fifty_coin_text")
	self.show_one_red = self:FindVariable("show_one_red")
	self.show_ten_red = self:FindVariable("show_ten_red")

	self.show_mask:SetValue(TreasureData.Instance:GetIsShield())
	self.open_one_money:SetValue(TreasureData.Instance:GetTreasurePrice(CHEST_SHOP_MODE.CHEST_SHOP_MODE_1))
	self.open_ten_money:SetValue(TreasureData.Instance:GetTreasurePrice(CHEST_SHOP_MODE.CHEST_SHOP_MODE_10))
	self.open_fifty_money:SetValue(TreasureData.Instance:GetTreasurePrice(CHEST_SHOP_MODE.CHEST_SHOP_MODE_50))
	--监听寻宝道具改变
	self:SetNotifyDataChangeCallBack()

	--引导用按钮
	self.one_times_btn = self:FindObj("OneTimesBtn")

	self.contain_cell_list = {}
	self.item_cfg_list = TreasureData.Instance:GetShowCfg()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.is_click = false
end

function TreasureContentView:__delete()
	if self.show_frame then
		self.show_frame:DeleteMe()
	end
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self.is_buy_quick = nil
	self.show_mask = nil
	self.open_ten_money = nil
	self.open_fifty_money = nil
	self.open_one_money = nil
	self.open_one_free_text = nil
	self.key_one_text = nil
	self.key_ten_text = nil
	self.key_fifty_text = nil
	self.show_coin_text = nil
	self.show_ten_coin_text = nil
	self.show_fifty_coin_text = nil
	self.is_click = false
end

function TreasureContentView:OpenOneClick()
	if self.is_click then
		return
	end 

	local treasure_list = TreasureData.Instance:GetOtherCfg()
	local open_one_num = TreasureData.Instance:GetTreasurePrice(CHEST_SHOP_MODE.CHEST_SHOP_MODE_1)
	local bag_num = ItemData.Instance:GetItemNumInBagById(treasure_list.equip_use_itemid)
	if bag_num < open_one_num and not self.is_buy_quick then
		-- 物品不足，弹出TIP框
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[treasure_list.equip_use_itemid]
		if item_cfg == nil then
			-- TipsCtrl.Instance:ShowItemGetWayView(treasure_list.equip_use_itemid)
			TipsCtrl.Instance:ShowSystemMsg(Language.Xunbao.NoEnoughTips)
			return
		end
		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			self.is_buy_quick = is_buy_quick
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, treasure_list.equip_use_itemid, nil, (open_one_num - bag_num))
		return
	end
	local auto_buy = self.is_buy_quick and 1 or 0
	TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE_1)
	TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE_1, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP, auto_buy)
	self.is_click = true
end

function TreasureContentView:OpenTenClick()
	if self.is_click then
		return
	end 

	local treasure_list = TreasureData.Instance:GetOtherCfg()
	local open_ten_num = TreasureData.Instance:GetTreasurePrice(CHEST_SHOP_MODE.CHEST_SHOP_MODE_10)
	local bag_num = ItemData.Instance:GetItemNumInBagById(treasure_list.equip_use_itemid)
	if bag_num < open_ten_num and not self.is_buy_quick then
		-- 物品不足，弹出TIP框
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[treasure_list.equip_use_itemid]
		if item_cfg == nil then
			-- TipsCtrl.Instance:ShowItemGetWayView(treasure_list.equip_use_itemid)
			TipsCtrl.Instance:ShowSystemMsg(Language.Xunbao.NoEnoughTips)
			return
		end
		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			self.is_buy_quick = is_buy_quick
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, treasure_list.equip_use_itemid, nil, (open_ten_num - bag_num))
		return
	end
	local auto_buy = self.is_buy_quick and 1 or 0
	TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE_10)
	TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE_10, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP, auto_buy)
	self.is_click = true
end

--屏蔽掉的30抽
function TreasureContentView:OpenFiftyClick()
	TreasureData.Instance:SetChestShopMode(CHEST_SHOP_MODE.CHEST_SHOP_MODE_50)
	TreasureCtrl.Instance:SendXunbaoReq(CHEST_SHOP_MODE.CHEST_SHOP_MODE_50, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP)
end

function TreasureContentView:GetNumberOfCells()
	local temp = (#self.item_cfg_list/2)%4
	if temp == 0 then
		return #self.item_cfg_list/2
	else
		return #self.item_cfg_list/2 + (4 - temp)
	end
end

function TreasureContentView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = TreasureShowCell.New(cell.gameObject,self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)
	contain_cell:Flush()
end

function TreasureContentView:CheckBoxClick()
	local treasure_data = TreasureData.Instance
	local is_shield = treasure_data:GetIsShield()
	treasure_data:SetIsShield(not is_shield)
	self.show_mask:SetValue(not is_shield)
end

function TreasureContentView:OnFlush()
	self.is_click = false
	self:FlushText()
end

function TreasureContentView:FlushTime()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
	local can_chest_time = TreasureData.Instance:GetChestFreeTime()
	local remain_time = can_chest_time - TimeCtrl.Instance:GetServerTime()
		if remain_time < 0 then
			self.show_coin_text:SetValue(false)
			GlobalTimerQuest:CancelQuest(self.timer_quest)
		else
			local time_str = string.format(Language.Treasure.ShowFreeTime, TimeUtil.FormatSecond(remain_time))
			-- 屏蔽免费抽
			--self.open_one_free_text:SetValue(time_str)
		end
	end, 0)
end

function TreasureContentView:FlushText()
	local cfg = TreasureData.Instance:GetOtherCfg()
	local item_1 = cfg.equip_use_itemid
	local item_count = ItemData.Instance:GetItemNumInBagById(item_1)
	self.key_one_text:SetValue( item_count >= TreasureData.Instance:GetTreasurePrice(CHEST_SHOP_MODE.CHEST_SHOP_MODE_1) and item_count or ToColorStr(item_count, TEXT_COLOR.RED))
	self.key_ten_text:SetValue( item_count >= TreasureData.Instance:GetTreasurePrice(CHEST_SHOP_MODE.CHEST_SHOP_MODE_10) and item_count or ToColorStr(item_count, TEXT_COLOR.RED))
	self.show_one_red:SetValue(item_count >= TreasureData.Instance:GetTreasurePrice(CHEST_SHOP_MODE.CHEST_SHOP_MODE_1))
	self.show_ten_red:SetValue(item_count >= TreasureData.Instance:GetTreasurePrice(CHEST_SHOP_MODE.CHEST_SHOP_MODE_10))
end

function TreasureContentView:SetNotifyDataChangeCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(function(cfg, item_id, reason, put_reason, old_num, new_num)
			if item_id == TreasureData.Instance:GetOtherCfg().equip_use_itemid then
				self:OnFlush()
			end
		end, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

----------------------------------------------------------------------
TreasureFrameItem = TreasureFrameItem or BaseClass(BaseCell)
function TreasureFrameItem:__init()
	self.mount_display = self:FindObj("model")
	-- self.effect_obj_pos = self:FindObj("effect")
	self.model_view = RoleModel.New("treasure_content_view")
	self.model_view:SetDisplay(self.mount_display.ui3d_display)
	self.is_load_effect = false
end

function TreasureFrameItem:__delete()
	if nil ~= self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end
end

function TreasureFrameItem:OnFlush()
	local main_role = Scene.Instance:GetMainRole()
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local display_cfg = TreasureData.Instance:GetSingleCfgByProf(game_vo.prof)
	local cfg = TreasureData.Instance:GetXunBaoZhenXiCfg()
	if not display_cfg then return end
	if display_cfg.role and display_cfg.role == 0 then
		local res_id = main_role:GetRoleResId()
		self.model_view:SetRoleResid(res_id)
	elseif display_cfg.role and display_cfg.role ~= 0 then
		self.model_view:SetRoleResid(display_cfg.role)
	end
	if display_cfg.weapon and display_cfg.weapon ~= 0 then
		self.model_view:SetWeaponResid(display_cfg.weapon)
	end
	if display_cfg.wing and display_cfg.wing ~= 0 then
		self.model_view:SetWingResid(display_cfg.wing)
	end
	if display_cfg.guanghuan and display_cfg.guanghuan ~= 0 then
		self.halo_model:SetHaloResid(display_cfg.guanghuan)
	end
	if display_cfg.zuji and display_cfg.zuji ~= 0 then
		--足迹
	end
	if display_cfg.pifeng and display_cfg.pifeng ~= 0 then
		--披风
	end
	-- self:SetModelEffect()
end

-- function TreasureFrameItem:SetModelEffect()
-- 	if not self.is_load_effect then
-- 		self.is_load_effect = true
-- 		local bundle = "effects/prefabs"
-- 		local asset = "UI_tongyongbaoju_1"

-- 		PrefabPool.Instance:Load(AssetID(bundle, asset), function(prefab)
-- 			if prefab then
-- 					if self.effect_obj  ~= nil then
-- 						GameObject.Destroy(self.effect_obj)
-- 						self.effect_obj = nil
-- 					end
-- 					local obj = GameObject.Instantiate(prefab)
-- 					PrefabPool.Instance:Free(prefab)

-- 					local transform = obj.transform
-- 					transform:SetParent(self.effect_obj_pos.transform, false)
-- 					self.effect_obj = obj.gameObject
-- 					self.effect_obj.transform.localScale = Vector3(1, 1, 1)
-- 					self.is_load_effect = false
-- 					end
-- 			end)
-- 	end
-- end
----------------------------------------------------------------
--------------cell----------------------------------------------
----------------------------------------------------------------
TreasureShowCell = TreasureShowCell  or BaseClass(BaseCell)
function TreasureShowCell:__init()
	self.item_cells = {}
	for i=1,2 do
		self.item_cells[i] = {}
		self.item_cells[i] = ItemCell.New()
		self.item_cells[i]:SetInstanceParent(self:FindObj("item_"..i))
	end
	self.show_cfg = TreasureData.Instance:GetShowCfg()
end

function TreasureShowCell:__delete()
	for i=1,2 do
		if self.item_cells[i] then
			self.item_cells[i]:DeleteMe()
		end
	end
end

function TreasureShowCell:OnFlush()
	for i=1,2 do
		local index = CommonDataManager.GetCellIndexList(self.index, 4, 2)[i]
		self.item_cells[i]:SetData(self.show_cfg[index])
		self.item_cells[i]:IsDestoryActivityEffect(index > 6)
		self.item_cells[i]:SetActivityEffect()
	end
end

