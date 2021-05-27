ActExploreView = ActExploreView or BaseClass(ActBaseView)

function ActExploreView:__init(view, parent, act_id)
	self:LoadView(parent)
	
end

function ActExploreView:__delete()
	-- if self.alert_window then
	-- 	self.alert_window:DeleteMe()
 --  		self.alert_window = nil
	-- end	
	-- if self.own_record_list then
	-- 	self.own_record_list:DeleteMe()
	-- 	self.own_record_list = nil
	-- end
	-- if self.service_record_list then
	-- 	self.service_record_list:DeleteMe()
	-- 	self.service_record_list = nil
	-- end
	if self.spare_51_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.spare_51_time)
		self.spare_51_time = nil
	end
	-- if self.explore_cell_list then
	-- 	for k,v in pairs(self.explore_cell_list) do
	-- 		v:DeleteMe()
	-- 	end
	-- 	self.explore_cell_list = {}
	-- end
	-- if ExploreData.Instance then
	-- 	ExploreData.Instance:RemoveEventListener(self.explore_listener)
	-- end
end

function ActExploreView:InitView()
	-- self:CreateExploreCell()
	-- self:UpdateOwnRecord()
	-- self:UpdateServiceRecord()
	self:CreateActSpareTimer()
	-- self.alert_window = nil
	-- EventProxy.New(ExploreData.Instance, self):AddEventListener(ExploreData.EXPLORE_BLESSING_CHANGE, BindTool.Bind(self.RefreshView, self))
	XUI.AddClickEventListener(self.node_t_list.btn_rechrge.node, BindTool.Bind(self.OnClickOpenRecharge, self), true)
	-- XUI.AddClickEventListener(self.node_t_list.btn_draw_times_1.node, BindTool.Bind(self.OnClickExploreHandler, self, 1))
	-- XUI.AddClickEventListener(self.node_t_list.btn_draw_times_10.node, BindTool.Bind(self.OnClickExploreHandler, self, 2))
	-- local yuanbao = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)				--元宝
	-- self.node_t_list.txt_gold.node:setString(yuanbao) 
	-- self.explore_listener = ExploreData.Instance:AddEventListener(ExploreData.EXPLORE_RECORD_CHANGE, BindTool.Bind(self.RefreshView, self))
end
	
function ActExploreView:RefreshView(param_list)
	-- if self.view ~= nil then
	-- 	local yuanbao = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)				--元宝
	-- 	self.node_t_list.txt_gold.node:setString(yuanbao) 
	-- 	local table = ExploreData.Instance:GetXunBaoData()
	-- 	local jifen = table.blessing_value
	-- 	self.node_t_list.txt_integrate.node:setString(jifen)
	-- 	self:FlushOwnRecord()
	-- 	self:FlushServiceRecord()
	-- end
end

-- function ActExploreView:CreateExploreCell()
-- 	self.explore_cell_list = {}
-- 	local show_data = ActivityBrilliantData.Instance:GetShowItemList(ACT_ID.CJHD)
-- 	local index = ActivityBrilliantData.Instance:GetShowItemListType(ACT_ID.CJHD)
-- 	if nil == index or nil == show_data then return end
-- 	for i = 1, 10 + index do
-- 		local cell_ph = nil
-- 		if i > 10 then
-- 			cell_ph = self.ph_list["ph_51_cell_".. index .."_" .. (i - 10)]
-- 		else
-- 			cell_ph = self.ph_list["ph_51_cell_" .. i]
-- 		end
-- 		if nil == cell_ph then
-- 			break
-- 		end
-- 		local cell = BaseCell.New()
-- 		cell:SetPosition(cell_ph.x, cell_ph.y)
-- 		cell:SetIndex(i)
-- 		cell:SetAnchorPoint(0.5, 0.5)
-- 		if i > 10 then 
-- 			cell:SetCellBg(ResPath.GetCommon("cell_101"))
-- 		else 
-- 			cell:SetCellBg(ResPath.GetCommon("cell_102"))
-- 		end
-- 		self.node_t_list.layout_act_51_draw.node:addChild(cell:GetView(), 103)
-- 		cell:SetData(show_data[i])
-- 		table.insert(self.explore_cell_list, cell)
-- 		local act_eff = RenderUnit.CreateEffect(920, self.node_t_list.layout_act_51_draw.node, 200, nil, nil,  cell_ph.x + 2, cell_ph.y + 2)
-- 	end
-- end

function ActExploreView:UpdateActSpareTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.CJHD)
	if nil == cfg then return end
	local now_time =TimeCtrl.Instance:GetServerTime()
	local end_time = cfg.end_time 
	local spare_time = end_time - now_time 
	self.node_t_list.lbl_51_spare_time.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end

function ActExploreView:CreateActSpareTimer()
	self.spare_51_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateActSpareTime, self), 1)
end

-- function ActExploreView:UpdateOwnRecord()
-- 	local ph = self.ph_list.ph_own_records_list
-- 	if self.own_record_list == nil then
-- 		self.own_record_list = ListView.New()
-- 		self.own_record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, OwnRecordRender, nil, nil, self.ph_list.ph_own_record)
-- 		self.own_record_list:GetView():setAnchorPoint(0, 0)
-- 		self.own_record_list:SetJumpDirection(ListView.Top)
-- 		self.own_record_list:SetItemsInterval(5)
-- 		self.node_t_list.layout_act_51_draw.node:addChild(self.own_record_list:GetView(), 100)
-- 	end
-- end

-- function ActExploreView:FlushOwnRecord()
-- 	local xunbao = ExploreData.Instance:GetOwnRewardList()
-- 	self.own_record_list:SetDataList(xunbao)
-- end

-- function ActExploreView:UpdateServiceRecord()
-- 	if nil == self.service_record_list then
-- 		local ph = self.ph_list.ph_service_records_list
-- 		self.service_record_list = ListView.New()
-- 		self.service_record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ServiceRecordRender, nil, nil, self.ph_list.ph_servicerecord_item)
-- 		self.service_record_list:GetView():setAnchorPoint(0, 0)
-- 		self.service_record_list:SetJumpDirection(ListView.Top)
-- 		self.node_t_list.layout_act_51_draw.node:addChild(self.service_record_list:GetView(), 100)
-- 	end		
-- end

-- function ActExploreView:FlushServiceRecord()
-- 	local xunbao = ExploreData.Instance:GetXunBaoRecord()
-- 	self.service_record_list:SetDataList(xunbao.world_record_list)
-- end

-- function ActExploreView:OpenTipView()
-- 	if self.alert_window == nil then
-- 		self.alert_window = Alert.New()
-- 		self.alert_window:SetOkString(Language.Common.BtnRechargeText)
-- 		self.alert_window:SetLableString(Language.Common.RechargeAlertText)
-- 		self.alert_window:SetOkFunc(BindTool.Bind(self.OnChargeRightNow, self))
-- 	end
-- 	self.alert_window:Open()
-- end

--充值
function ActExploreView:OnClickOpenRecharge()
	ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
end

-- function ActExploreView:OnClickExploreHandler(explore_type)
-- 	if nil == DmkjConfig then return end
-- 	if explore_type == 1 then
-- 		if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD) <  DmkjConfig.Treasure[1].needYb and BagData.Instance:GetItemNumInBagById(517,nil) < 1 then
-- 			self:OpenTipView()
-- 		end
-- 	elseif explore_type == 2 then
-- 		if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD) < DmkjConfig.Treasure[2].needYb and BagData.Instance:GetItemNumInBagById(517,nil) < 50 then
-- 			self:OpenTipView()
-- 		end
-- 	end
-- 	ExploreCtrl.Instance:SendXunbaoReq(explore_type)
-- end

-- function ActExploreView:OnClickOpenExploreBag()
-- 	ViewManager.Instance:OpenViewByDef(ViewDef.Explore.Storage)
-- end

-- function ActExploreView:ItemConfigCallback()
-- 	self:RefreshView()
-- end


-- OwnRecordRender = OwnRecordRender or BaseClass(BaseRender)
-- function OwnRecordRender:__init()	
-- end

-- function OwnRecordRender:__delete()	
-- end

-- function OwnRecordRender:CreateChild()
-- 	BaseRender.CreateChild(self)
-- 	XUI.AddClickEventListener(self.node_tree.txt_item_name.node, BindTool.Bind1(self.OnClickItemTipsHandler, self))
-- end

-- function OwnRecordRender:OnClickItemTipsHandler()
-- 	TipCtrl.Instance:OpenItem(self.data.item_data, EquipTip.FROM_NORMAL)
-- end

-- function OwnRecordRender:OnFlush()
-- 	if self.data == nil then return end
-- 	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_data.item_id)
-- 	if nil == item_cfg then 
-- 		return 
-- 	end
-- 	local  color = string.format("%06x", item_cfg.color)
-- 	if #color <= 6 then
-- 		self.node_tree.txt_item_name.node:setColor(Str2C3b(color))
-- 	else
-- 		self.node_tree.txt_item_name.node:setColor(Str2C3bEx(color))
-- 	end
-- 	local txt = string.format(Language.XunBao.MyRecord, item_cfg.name)
-- 	self.node_tree.txt_get_1.node:setPosition(0, 24.1)
-- 	self.node_tree.txt_get_2.node:setPosition(25, 24.1)
-- 	local size = self.node_tree.txt_get_2.node:getContentSize()
-- 	self.node_tree.txt_item_name.node:setString(txt)
-- 	self.node_tree.txt_item_name.node:setPosition((size.width/2)*3.0, size.height)
-- end

-- function OwnRecordRender:CreateSelectEffect()
-- end




-- ServiceRecordRender = ServiceRecordRender or BaseClass(BaseRender)
-- function ServiceRecordRender:__init()	
-- end

-- function ServiceRecordRender:__delete()	
-- end

-- function ServiceRecordRender:CreateChild()
-- 	BaseRender.CreateChild(self)
-- end

-- function ServiceRecordRender:OnFlush()
-- 	if self.data == nil then return end
-- 	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_data.item_id)
-- 	if nil == item_cfg then 
-- 		return 
-- 	end
-- 	local  color = string.format("%06x", item_cfg.color)
-- 	local playername = Scene.Instance:GetMainRole():GetName()
-- 	if playername == self.data.role_name then
-- 		self.rolename_color = "CCCCCC"
-- 	else
-- 		self.rolename_color = "FFFF00"
-- 	end
-- 	local text_1 = string.format(Language.XunBao.RecordTxt, self.rolename_color, self.rolename_color, self.data.role_name, self.rolename_color, Language.XunBao.Suffix)
-- 	local text_2 = string.format(RichTextUtil.CreateItemStr(self.data.item_data))
-- 	RichTextUtil.ParseRichText(self.node_tree.rich_tip_1.node, text_1, 18)
-- 	RichTextUtil.ParseRichText(self.node_tree.rich_tip_2.node, text_2, 18)
-- end

-- function ServiceRecordRender:CreateSelectEffect()
-- end