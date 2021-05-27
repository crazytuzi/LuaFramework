-- 开服限时每日充值View

LimitDailyChargeView = LimitDailyChargeView or BaseClass(XuiBaseView)

function LimitDailyChargeView:__init()
	self.texture_path_list[1] = 'res/xui/charge.png'
	self.texture_path_list[2] = 'res/xui/vip.png'
	self.texture_path_list[3] = 'res/xui/invest_plan.png'
	self.texture_path_list[4] = 'res/xui/equipment.png'
	self.config_tab = {
		--{"charge_ui_cfg", 1, {0}},
		{"charge_ui_cfg", 3, {0}}
	}	
	self.reward_cell = {}
end

function LimitDailyChargeView:__delete()
end

function LimitDailyChargeView:ReleaseCallBack()
	if self.cell_list then 
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
	if self.soul_stone  then
		for k,v in ipairs(self.soul_stone) do
			v:DeleteMe()
		end
		self.soul_stone = nil
	end
	-- if self.cells_container then
	-- 	self.cells_container:removeFromParent()
	-- 	self.cells_container = nil
	-- end
	-- if self.role_attr_change_callback then
	-- 	RoleData.Instance:UnNotifyAttrChange(self.role_attr_change_callback)
	-- 	self.role_attr_change_callback = nil
	-- end
end

function LimitDailyChargeView:RoleDataChangeCallback(key, value, old_value)
	if key == OBJ_ATTR.ACTOR_GOLD then
		LimitDailyChargeCtrl.Instance:SendInfoReq()
	end
end

function LimitDailyChargeView:CreateBagCell()
	if not self.soul_ston then
		self.soul_stone = {}
		for i=1,6 do
			local ph = self.ph_list["ph_img_"..i]
			local  img_red 
			if i <= 3 then
				img_red= XUI.CreateImageView(ph.x+50, ph.y+50, ResPath.GetCharge("charge_day_item_1"), true)
			else
				img_red= XUI.CreateImageView(ph.x+50, ph.y+50, ResPath.GetCharge("charge_day_item_2"), true)
			end
			local cur_data = {state = 0}
			self.node_t_list.layout_charge_everyday.node:addChild(img_red, 100)
			local cell = self:CreateStoneRender(ph, cur_data,i)
			cell:AddClickEventListener(BindTool.Bind1(self.OnClickCell, self), true)
			table.insert(self.soul_stone, cell)			
		end
		self.select_index = 1
		local cur_level = LimitDailyChargeData.Instance:GetTempData()
		for i,v in ipairs(cur_level) do
			if v.index == self.select_index then
				self:SetAwardCells(v.state)
			end
		end
	end
end

function LimitDailyChargeView:CreateStoneRender(ph, cur_data,index)
	local cell = ChargeEveryDayRender.New()
	local render_ph = self.ph_list.lay_tocell
	cell:SetUiConfig(render_ph, true)
	cell:SetIndex(index)
	cell:GetView():setPosition(ph.x+20, ph.y+20)
	self.node_t_list.layout_charge_everyday.node:addChild(cell:GetView(), 999)
	cell:SetData(cur_data)
	return cell
end

function LimitDailyChargeView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then 
		-- self.role_attr_change_callback = BindTool.Bind(self.RoleDataChangeCallback, self)
		-- RoleData.Instance:NotifyAttrChange(self.role_attr_change_callback)
		XUI.AddClickEventListener(self.node_t_list.btn_charge_every_day.node, BindTool.Bind(self.ChargeEveryDayMoney, self), true)
		--self:CreateCellsContainer()
		self:CreateChargeNumberBar()
		self:CreateCellsContainer()
		self:CreateBagCell()
	end
end

function LimitDailyChargeView:OpenCallBack()
	LimitDailyChargeCtrl.Instance:SendInfoReq()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function LimitDailyChargeView:ShowIndexCallBack(index)
	self:Flush(index)
end

function LimitDailyChargeView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function LimitDailyChargeView:CreateCellsContainer()
	-- if not self.cells_container then
	-- 	local pos_x, pos_y = self.node_t_list.btn_charge_every_day.node:getPositionX(), self.node_t_list.btn_charge_every_day.node:getPositionY()
	-- 	self.cells_container = XLayout:create(0, 80)
	-- 	self.cells_container:setAnchorPoint(0.5, 0)
	-- 	self.cells_container:setPosition(pos_x, pos_y + 70)
	-- 	self.node_t_list.layout_charge_everyday.node:addChild(self.cells_container, 100)
	-- end
	self.cell_list = {}
	for i = 1, 6 do
		local ph = self.ph_list["ph_cell_" .. i]
		if ph then
			local cell = BaseCell.New()
			cell:SetPosition(ph.x, ph.y)
			cell:SetIndex(i)
			cell:SetAnchorPoint(0, 0)
			cell:SetCellBg(ResPath.GetCommon("cell_100"))
			if i == 6 then
				cell:SetCellBg(ResPath.GetEquipment("cell_1_bg"))
			end
			RenderUnit.CreateEffect(7, cell:GetView(), 201, nil, nil)
			self.node_t_list.layout_charge_everyday.node:addChild(cell:GetView(), 200)
			table.insert(self.cell_list, cell)
		end
	end
end

function LimitDailyChargeView:CreateChargeNumberBar()
	local ph = self.ph_list.ph_zhanwei
	-- 需要充值金额
	self.charge_num = NumberBar.New()
	self.charge_num:SetRootPath(ResPath.GetMainui("num_"))
	self.charge_num:SetPosition(ph.x + 40, ph.y - 5)
	self.charge_num:SetGravity(NumberBarGravity.Center)
	self.node_t_list.layout_charge_everyday.node:addChild(self.charge_num:GetView(), 300, 300)
	self.charge_num:GetView():setScale(0.7)
end

-- 刷新
function LimitDailyChargeView:OnFlush(param_t, index)
	local cur_level = LimitDailyChargeData.Instance:GetTempData()
	for i,v in ipairs(cur_level) do
		if self.soul_stone and self.soul_stone[i] then
			self.soul_stone[i]:SetData(v)
		end
		if v.index == self.select_index then
			self:SetAwardCells(v.state)
		end
	end
end

function LimitDailyChargeView:SetAwardCells(state)
	if not state then return end
	self.select_state = state
	local awards_data = LimitDailyChargeData.Instance:GetEveryDayCellRewardCfg(self.select_index)
	self.charge_num:SetNumber(OpenServerDailyRechargeCfg.Gold[self.select_index])
	if awards_data then
		local item_cfg=ItemData.Instance:GetItemConfig(awards_data[#awards_data].item_id)		
		self.node_t_list.txt_cofig_name.node:setString(item_cfg.name)
	end	
	for i,v in ipairs(awards_data) do
		if self.cell_list[i] ~= nil then
			self.cell_list[i]:SetData(v)
		end		
	end
	local path = nil
	if state == 0 then
		path = ResPath.GetVipResPath("text_bg")
	elseif state == 1 then
		path = ResPath.GetCommon("stamp_14")
	elseif state == 2 then
		path = ResPath.GetCommon("stamp_15")	
	end
	self.node_t_list.img_recharge.node:loadTexture(path)
	XUI.SetLayoutImgsGrey(self.node_t_list.btn_charge_every_day.node, state ==2, true)
end

function LimitDailyChargeView:ChargeEveryDayMoney()
	if self.select_state and self.select_index then
		if self.select_state == 0 then 
			ViewManager.Instance:Open(ViewName.ChargePlatForm)
		elseif self.select_state == 1 then 
			LimitDailyChargeCtrl.Instance:SendGetEveryDayGiftBagReq(self.select_index) --领取奖励
		end
	end
end


function LimitDailyChargeView:OnClickCell(cell)
	if nil == cell and  cell:GetData() ~= nil then return end
	local select_data = cell:GetData()
	self.select_index = cell:GetIndex()
	if select_data then
		self:SetAwardCells(select_data.state)
	end
end


ChargeEveryDayRender = ChargeEveryDayRender or BaseClass(BaseRender)
function ChargeEveryDayRender:__init()

end

function ChargeEveryDayRender:__delete()

end

function ChargeEveryDayRender:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.img_bg.node:setOpacity(0)
end

function ChargeEveryDayRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.txt_num.node:setString(OpenServerDailyRechargeCfg.Gold[self.index])
	if self.data.state == 2 then
		self.node_tree.txt_num.node:setColor(Str2C3b("aaaa7f"))
		self.node_tree.txt_dec.node:setColor(Str2C3b("aaaa7f"))
	else
		self.node_tree.txt_num.node:setColor(Str2C3b("ffff00"))
		self.node_tree.txt_dec.node:setColor(Str2C3b("ffff00"))
	end
	self.node_tree.img_red.node:setVisible(self.data.state == 1)
end


