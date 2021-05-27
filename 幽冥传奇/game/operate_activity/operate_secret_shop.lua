OperSecretShopPage = OperSecretShopPage or BaseClass()


function OperSecretShopPage:__init()
end	

function OperSecretShopPage:__delete()
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
function OperSecretShopPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.time = 1
	self:CreateItemCell()
	self:InitEvent()
	self:FlushShopItems()
end	


--初始化事件
function OperSecretShopPage:InitEvent()
	self.view.node_t_list["btn_refresh"].node:addClickEventListener(BindTool.Bind(self.OnRefrShopItem, self))
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushTime, self, -1),  1)
	self.data_event  = GlobalEventSystem:Bind(OperateActivityEventType.SECRET_SHOP_DATA, BindTool.Bind(self.FlushShopItems, self))
end

--移除事件
function OperSecretShopPage:RemoveEvent()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

	if self.data_event then
		GlobalEventSystem:UnBind(self.data_event)
		self.data_event = nil
	end
end

--更新视图界面
function OperSecretShopPage:UpdateData(data)
	local cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.SECRET_SHOP)
	local content = cfg and cfg.act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_secret_shop_des.node, content, 24, COLOR3B.YELLOW)
	local act_id = OPERATE_ACTIVITY_ID.SECRET_SHOP
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, act_id)
	end
end	

function OperSecretShopPage:FlushShopItems()
	local cur_data = OperateActivityData.Instance:GetSecretShopItemsData()
	self.mysterious_shop_grid:SetDataList(cur_data)
	self:FlushTime()
end

function OperSecretShopPage:FlushTime()
	local time_str = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.SECRET_SHOP)
	if self.view.node_t_list.text_secrect_shop_rest_time then
		self.view.node_t_list.text_secrect_shop_rest_time.node:setString(time_str)
	end
	local time = OperateActivityData.Instance:GetSecretShopRefrCD() - Status.NowTime
	if time < 0 then
		local act_id = OPERATE_ACTIVITY_ID.SECRET_SHOP
		local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
		if cmd_id then
			OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, award_index, 2, oper_time, dindan_id, role_id, join_type)
		end
	else
		local c_time = TimeUtil.FormatSecond2Str(time)
		local txt = string.format(Language.CombineServerActivity.Refreshtime, c_time)
		self.view.node_t_list.txt_refresh_time.node:setString(txt)
	end
end

function OperSecretShopPage:CreateItemCell()
	if self.mysterious_shop_grid == nil then
		self.mysterious_shop_grid = BaseGrid.New()
		local ph_baggrid = self.view.ph_list.ph_shop_grid
		local grid_node = self.mysterious_shop_grid:CreateCells({w = ph_baggrid.w, h = ph_baggrid.h, cell_count = 4, col = 2, row =2, itemRender = OperSecretRender, direction = ScrollDir.Horizontal ,ui_config = self.view.ph_list.ph_item_info_panel})
		grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
		self.view.node_t_list.layout_mysterious_item.node:addChild(grid_node, 100)
	end
end

function OperSecretShopPage:OnRefrShopItem()
	if self.alert_view == nil then
		self.alert_view = Alert.New()
		local cost = OperateActivityData.Instance:GetSecretShopRefrCost()
		self.alert_view:SetShowCheckBox(true)
		local txt = string.format(Language.CombineServerActivity.Refresh_Tips, cost)
		self.alert_view:SetLableString(txt)
		self.alert_view:SetOkFunc(function ()
			local act_id = OPERATE_ACTIVITY_ID.SECRET_SHOP
			local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
			if cmd_id then
				OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, act_id, award_index, 2, oper_time, dindan_id, role_id, join_type)
			end
	  	end)
	end
  	self.alert_view:Open()
end


