NatiBossTreasurePage = NatiBossTreasurePage or BaseClass()


function NatiBossTreasurePage:__init()
end	

function NatiBossTreasurePage:__delete()
	self:RemoveEvent()
	if self.mysterious_shop_grid ~= nil then
		self.mysterious_shop_grid:DeleteMe()
		self.mysterious_shop_grid = nil
	end
	if self.alert_view ~= nil then
		self.alert_view:DeleteMe()
		self.alert_view = nil 
	end
end	

--初始化页面接口
function NatiBossTreasurePage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.time = 1
	self:CreateItemCell()
	self:InitEvent()
	self:FlushShopItems()
end	


--初始化事件
function NatiBossTreasurePage:InitEvent()
	self.view.node_tree.layout_boss_treasure["btn_refresh"].node:addClickEventListener(BindTool.Bind(self.OnRefrShopItem, self))
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushTime, self, -1),  1)
	self.data_event  = GlobalEventSystem:Bind(OperateActivityEventType.BOSS_TREASURE_DATA, BindTool.Bind(self.FlushShopItems, self))
	self.role_data_change = BindTool.Bind(self.OnRoleAttrChange, self)
	RoleData.Instance:NotifyAttrChange(self.role_data_change)
	self.item_data_change = BindTool.Bind(self.OnItemChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_change)
end

--移除事件
function NatiBossTreasurePage:RemoveEvent()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

	if self.data_event then
		GlobalEventSystem:UnBind(self.data_event)
		self.data_event = nil
	end
	if self.role_data_change and RoleData.Instance then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_change)
		self.role_data_change = nil
	end

	if self.item_data_change and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_change)
		self.item_data_change = nil
	end
end

--更新视图界面
function NatiBossTreasurePage:UpdateData(data)
	local cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.BOSS_TREASURE)
	local content = cfg and cfg.act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_tree.layout_boss_treasure.rich_desc.node, content, 24, COLOR3B.YELLOW)
	local act_id = OPERATE_ACTIVITY_ID.BOSS_TREASURE
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, act_id)
	end
	self:FlushMoney()
	self:FlushBossSuiPian()
end	

function NatiBossTreasurePage:OnRoleAttrChange(key, value, old_value)
	if key == OBJ_ATTR.ACTOR_COIN or key == OBJ_ATTR.ACTOR_BIND_GOLD 
	 or key == OBJ_ATTR.ACTOR_GOLD or key == OBJ_ATTR.ACTOR_BIND_COIN then
		self:FlushMoney()
	end	
end

function NatiBossTreasurePage:OnItemChange(change_type, item_id, item_index, series, reason)
	if item_id == OperateActivityData.Instance:GetBossTreasureBosssuipianId() then
		self:FlushBossSuiPian()
	end
end

function NatiBossTreasurePage:FlushMoney()
	self.view.node_tree.layout_boss_treasure.label_yb_num.node:setString(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD))
	self.view.node_tree.layout_boss_treasure.label_bind_yb_num.node:setString(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_GOLD))
	self.view.node_tree.layout_boss_treasure.label_coin_num.node:setString(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_COIN))
end

function NatiBossTreasurePage:FlushBossSuiPian()
	self.view.node_tree.layout_boss_treasure.label_boss_sp_num.node:setString(ItemData.Instance:GetItemNumInBagById(OperateActivityData.Instance:GetBossTreasureBosssuipianId()))
end

function NatiBossTreasurePage:FlushShopItems()
	local cur_data = OperateActivityData.Instance:GetBossTreasureItemsData()
	self.mysterious_shop_grid:SetDataList(cur_data)
	self:FlushTime()
end

function NatiBossTreasurePage:FlushTime()
	local time_str = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.BOSS_TREASURE)
	if self.view.node_tree.layout_boss_treasure.txt_rest_time then
		self.view.node_tree.layout_boss_treasure.txt_rest_time.node:setString(Language.Common.RemainTime .."："..time_str)
	end
	local time = OperateActivityData.Instance:GetBossTreasureRefrCD() - Status.NowTime
	if time < 0 then
		local act_id = OPERATE_ACTIVITY_ID.BOSS_TREASURE
		local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
		if cmd_id then
			OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, award_index, 2, oper_time, dindan_id, role_id, join_type)
		end
	else
		local c_time = TimeUtil.FormatSecond2Str(time)
		local txt = string.format(Language.CombineServerActivity.Refreshtime, c_time)
		self.view.node_tree.layout_boss_treasure.txt_refresh_time.node:setString(txt)
	end
end

function NatiBossTreasurePage:CreateItemCell()
	if self.mysterious_shop_grid == nil then
		self.mysterious_shop_grid = BaseGrid.New()
		local ph_baggrid = self.view.ph_list.ph_boss_treasure_grid
		local count = OperateActivityData.Instance:GetBossTreasureShowItemNum()
		local grid_node = self.mysterious_shop_grid:CreateCells({w = ph_baggrid.w, h = ph_baggrid.h, cell_count = count, col = 3, row =2, itemRender = OperBossTreasureRender, direction = ScrollDir.Vertical ,ui_config = self.view.ph_list.ph_item_info_panel_boss})
		grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
		self.view.node_tree.layout_boss_treasure.node:addChild(grid_node, 100)
	end
end

function NatiBossTreasurePage:OnRefrShopItem()
	if self.alert_view == nil then
		self.alert_view = Alert.New()
		local cost = OperateActivityData.Instance:GetBossTreasureRefrCost()
		-- self.alert_view:SetShowCheckBox(true)
		local txt = string.format(Language.CombineServerActivity.Refresh_Tips, cost)
		self.alert_view:SetLableString(txt)
		self.alert_view:SetOkFunc(function ()
			local act_id = OPERATE_ACTIVITY_ID.BOSS_TREASURE
			local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
			if cmd_id then
				OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, award_index, 2, oper_time, dindan_id, role_id, join_type)
			end
	  	end)
	end
  	self.alert_view:Open()
end
