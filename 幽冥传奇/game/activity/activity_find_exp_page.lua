ActivityFindExpPage = ActivityFindExpPage or BaseClass()


function ActivityFindExpPage:__init()
	
end	

function ActivityFindExpPage:__delete()
	if self.find_exp_list then
		self.find_exp_list:DeleteMe()
		self.find_exp_list = nil 
	end

	if self.exp_cell ~= nil then
		for k,v in pairs(self.exp_cell) do
			v:DeleteMe()
		end
		self.exp_cell = {}
	end
	if self.alert_desc_view then
		self.alert_desc_view:DeleteMe()
		self.alert_desc_view = nil 
	end
	self:RemoveEvent()
end	

--初始化页面接口
function ActivityFindExpPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateGridScrollList()
	self:CreateCellsExp()
	self:InitEvent()
end	

function ActivityFindExpPage:CreateGridScrollList()
	if self.find_exp_list == nil then
		local ph = self.view.ph_list.ph_grid_list
		self.find_exp_list = GridScroll.New()
		local grid_node = self.find_exp_list:Create(ph.x, ph.y, ph.w,ph.h, 3, ph.y +50, FindResoureItem, ScrollDir.Vertical, false, self.view.ph_list.ph_list_item)
		self.view.node_t_list.layout_find_resoures.node:addChild(grid_node, 999)
		grid_node:setAnchorPoint(0, 0)
		grid_node:setPosition(ph.x, ph.y)
	end
end

function ActivityFindExpPage:CreateCellsExp()
	self.exp_cell = {}
	for i = 1, 2 do
		local ph = self.view.ph_list["ph_cell_"..i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0, 0)
		self.view.node_t_list.layout_find_resoures.node:addChild(cell:GetView(), 200)
		table.insert(self.exp_cell, cell)
	end

end


--初始化事件
function ActivityFindExpPage:InitEvent()
	XUI.AddClickEventListener(self.view.node_t_list.layout_btn_find_percent.node, BindTool.Bind1(self.OnOneKeyFindPercent, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.layout_btn_find_all.node, BindTool.Bind1(self.OnOneKeyFindAll, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_desc.node, BindTool.Bind1(self.OnOpenDesc, self), true)
	self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback,self)			--监听人物属性数据变化
	RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)
	self.find_resoures_data_change_evt = GlobalEventSystem:Bind(ActivityEventType.ACT_FIND_RESOUSE,BindTool.Bind1(self.OnFindResoureDataChange, self))
	RichTextUtil.ParseRichText(self.view.node_t_list.txt_name.node, Language.Activity.FindResouresText[1])
	RichTextUtil.ParseRichText(self.view.node_t_list.txt_name_1.node, Language.Activity.FindResouresText[2])
end

function ActivityFindExpPage:OnOpenDesc()
	DescTip.Instance:SetContent(Language.Activity.FindResouresExPlainContent, Language.Activity.FindResouresExPlainTitle)
end

function ActivityFindExpPage:OnFindResoureDataChange()
	self:FreshData()
end

function ActivityFindExpPage:RoleDataChangeCallback(key,value)
	if  key == OBJ_ATTR.CREATURE_LEVEL or key == OBJ_ATTR.ACTOR_CIRCLE  then
		self:FreshData()
	elseif key == OBJ_ATTR.ACTOR_BIND_COIN or key == OBJ_ATTR.ACTOR_GOLD or key == OBJ_ATTR.ACTOR_BIND_GOLD then		
		self:FreshData()
	end
end

function ActivityFindExpPage:OnOneKeyFindPercent()
	ActivityCtrl.Instance:SendFindResuoresReq(3, 0)
end

function ActivityFindExpPage:OnOneKeyFindAll()
	local cur_data = ActivityData.Instance:GetFindResouseListData()
	local consume_feeAll = 0
	for k,v in pairs(cur_data) do
		if v.time ~= 0 then
			consume_feeAll = consume_feeAll + v.feeAll* (v.time)
		end
	end
	if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_GOLD) < consume_feeAll and RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD) >= consume_feeAll then
		if nil == self.alert_desc_view then
			self.alert_desc_view = Alert.New()
		end
		local des = string.format(Language.Activity.QueShao, consume_feeAll)
		self.alert_desc_view:SetShowCheckBox(false)
		self.alert_desc_view:Open()
		self.alert_desc_view:SetLableString(des)
		self.alert_desc_view:SetOkFunc(BindTool.Bind2(self.FindOneBtnResouresAll, self))
	else
		ActivityCtrl.Instance:SendFindResuoresReq(4, 0)
	end
end

function ActivityFindExpPage:FindOneBtnResouresAll()
	ActivityCtrl.Instance:SendFindResuoresReq(4, 0)
end

--移除事件
function ActivityFindExpPage:RemoveEvent()
	if self.roledata_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
		self.roledata_change_callback = nil 
	end
	if self.find_resoures_data_change_evt then
		GlobalEventSystem:UnBind(self.find_resoures_data_change_evt)
		self.find_resoures_data_change_evt = nil
	end
end

--更新视图界面
function ActivityFindExpPage:UpdateData(data)
	self:FreshData()
	self.find_exp_list:JumpToTop()
end	

function ActivityFindExpPage:FreshData()
	local cur_data = ActivityData.Instance:GetFindResouseListData()

	self.find_exp_list:SetDataList(cur_data)
	local comsume_feedisc = 0
	local consume_feeAll = 0
	local had_exp = 0 
	for k,v in pairs(cur_data) do
		if v.time ~= 0 then
			comsume_feedisc = comsume_feedisc + v.feeDisc * (v.time)
			consume_feeAll = consume_feeAll + v.feeAll* (v.time)
			if v.reward[1].type == tagAwardType.qatAddExp then
				had_exp  = had_exp + v.time * ItemData.Instance:CalcuSpecialExpVal(v.reward[1])
			else
				had_exp = had_exp + v.time * v.reward[1].count
			end
		end
	end
	self.view.node_t_list.txt_onekey_money_num.node:setString(comsume_feedisc)
	self.view.node_t_list.txt_onekey_gold_num.node:setString(consume_feeAll)
	XUI.SetLayoutImgsGrey(self.view.node_t_list.layout_btn_find_percent.node, comsume_feedisc == 0, true)
	XUI.SetLayoutImgsGrey(self.view.node_t_list.layout_btn_find_all.node, consume_feeAll == 0, true)
	self.view.node_t_list.txt_had_exp.node:setString(string.format(Language.Activity.Had_Exp,math.floor(had_exp*0.3/10000)))
	self.view.node_t_list.txt_had_exp_1.node:setString(string.format(Language.Activity.Had_Exp,math.floor(had_exp/10000)))
	local virtual_item_id = ItemData.Instance:GetVirtualItemId(tagAwardType.qatAddExp)
	for k,v in pairs(self.exp_cell) do
		v:SetData({item_id = virtual_item_id, num = 1, is_bind = 0})
	end
end

FindResoureItem = FindResoureItem or BaseClass(BaseRender)

function FindResoureItem:__init()
end

function FindResoureItem:__delete()
	if self.cell ~= nil then
		self.cell:DeleteMe()
		self.cell = nil 
	end
	if self.alert_view then
		self.alert_view:DeleteMe()
		self.alert_view = nil
	end
end

function FindResoureItem:CreateChild()
	BaseRender.CreateChild(self)
	if self.cell == nil then
		local ph = self.ph_list.ph_cell_show
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x, ph.y)
		self.cell:SetAnchorPoint(0, 0)
		self.view:addChild(self.cell:GetView(), 200)
	end
	XUI.AddClickEventListener(self.node_tree.btn_find_percent.node, BindTool.Bind1(self.OnFindPercent, self), true)
	XUI.AddClickEventListener(self.node_tree.btn_find_all.node, BindTool.Bind1(self.OnFindAll, self), true)
end

function FindResoureItem:OnFlush()
	if self.data == nil then return end
	local icon = self.data.icon 
	self.node_tree.img_icon.node:loadTexture(ResPath.GetMainui("act_icon_"..icon))
	self.node_tree.txt_activity_name.node:setString(self.data.name)
	self.node_tree.txt_money_num.node:setString(self.data.feeDisc)
	self.node_tree.txt_gold_num.node:setString(self.data.feeAll)
	self.node_tree.txt_remain_time.node:setString(string.format(Language.Activity.Remain_time,self.data.time))
	XUI.SetButtonEnabled(self.node_tree.btn_find_percent.node, self.data.time ~= 0)
	XUI.SetButtonEnabled(self.node_tree.btn_find_all.node, self.data.time ~= 0)
	if self.data.reward[1].type == tagAwardType.qatAddExp then
		local virtual_item_id = ItemData.Instance:GetVirtualItemId(self.data.reward[1].type)
		local cur_num = ItemData.Instance:CalcuSpecialExpVal(self.data.reward[1])
		self.cell:SetData({item_id = virtual_item_id, num = cur_num, is_bind = 0})
	else 
		local virtual_item_id = ItemData.Instance:GetVirtualItemId(self.data.reward[1].type)
		self.cell:SetData({item_id = virtual_item_id, num = self.data.reward[1].count, is_bind = 0})	
	end
end

function FindResoureItem:OnFindPercent()
	ActivityCtrl.Instance:SendFindResuoresReq(1, self.data.cur_index)
end

function FindResoureItem:OnFindAll()
	if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_GOLD) < self.data.feeAll and RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD) >= self.data.feeAll then
		if nil == self.alert_view then
			self.alert_view = Alert.New()
		end
		local des = string.format(Language.Activity.QueShao, self.data.feeAll)
		self.alert_view:SetShowCheckBox(true)
		self.alert_view:SetCheckBoxText(Language.Role.ShowKuangText)
		self.alert_view:SetLableString(des)
		if self.alert_view:GetIsNolongerTips() == false then
			self.alert_view:Open()
		else
			ActivityCtrl.Instance:SendFindResuoresReq(2, self.data.cur_index)
		end

		self.alert_view:SetOkFunc(BindTool.Bind2(self.FindResouresAll, self))
	else
		ActivityCtrl.Instance:SendFindResuoresReq(2, self.data.cur_index)
	end
end

function FindResoureItem:FindResouresAll()
	ActivityCtrl.Instance:SendFindResuoresReq(2, self.data.cur_index)
end


