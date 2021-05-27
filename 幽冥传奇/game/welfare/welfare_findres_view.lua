-- 资源找回

local WelfareFindresView = BaseClass(SubView)

function WelfareFindresView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)

	self.config_tab = {
		{"welfare_ui_cfg", 13, {0}},
	}

	self.need_yb = 0
	self.need_zs = 0
end

function WelfareFindresView:__delete()
end

function WelfareFindresView:ReleaseCallBack()
	if self.findres_list then
		self.findres_list:DeleteMe()
		self.findres_list = nil
	end

	if self.all_findres_tip then
		self.all_findres_tip:DeleteMe()
		self.all_findres_tip = nil
	end

	if self.all_zs_tip then
		self.all_zs_tip:DeleteMe()
		self.all_zs_tip = nil
	end
end

function WelfareFindresView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateFindResList()

		XUI.AddClickEventListener(self.node_t_list.btn_yb_all.node, BindTool.Bind(self.OnClickFindAll, self, 3), true)
		XUI.AddClickEventListener(self.node_t_list.btn_zs_all.node, BindTool.Bind(self.OnClickFindAll, self, 4), true)

		EventProxy.New(WelfareData.Instance, self):AddEventListener(WelfareData.FINDRES_COUNT, BindTool.Bind(self.Flush, self))
	end

end

function WelfareFindresView:ShowIndexCallBack(index)
	self:Flush()
end
	
function WelfareFindresView:OpenCallBack()
end

function WelfareFindresView:CloseCallBack()
end

function WelfareFindresView:OnClickFindAll(index)
	
	local yb = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COIN)
	local zs = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)

	local money = index == 3 and yb or zs
	local need_money = index == 3 and self.need_yb or self.need_zs
	local txt = index == 3 and "元宝" or "钻石"

	if money >= need_money then
		self.all_findres_tip = self.all_findres_tip or Alert.New()
		self.all_findres_tip:SetShowCheckBox(false)
		self.all_findres_tip:SetLableString(string.format(Language.Welfare.AllFindresTxt, need_money, txt))
		self.all_findres_tip:SetOkFunc(function()
			WelfareCtrl.Instance:FindResGetReq(index)
		end)
		self.all_findres_tip:Open()
	else
		if index == 3 then
			TipCtrl.Instance:OpenGetStuffTip(493)
		else
			self.all_zs_tip = self.all_zs_tip or Alert.New()
			self.all_zs_tip:SetShowCheckBox(false)
			self.all_zs_tip:SetLableString(Language.Welfare.FindresNotZs)
			self.all_zs_tip:SetOkFunc(function()
				ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
			end)
			self.all_zs_tip:Open()
		end
	end
end

function WelfareFindresView:CreateFindResList()
	if nil == self.findres_list then
		local ph = self.ph_list.ph_findres_list
		self.findres_list = ListView.New()  -- 创建ListView
		self.findres_list:Create(ph.x, ph.y, ph.w, ph.h, nil, FindResRender, nil, nil, self.ph_list.ph_findres_render)
		self.findres_list:GetView():setAnchorPoint(0.5, 0.5)
		self.findres_list:SetMargin(2)
		self.findres_list:SetItemsInterval(5)
		self.findres_list:SetJumpDirection(ListView.TOP)
		self.node_t_list.layout_findres.node:addChild(self.findres_list:GetView(), 1)
	end
end

function WelfareFindresView:OnFlush(param_t, index)
	local data_list = WelfareData.Instance:GetFindResList() or {}
	local old_data_list = self.findres_list:GetData()

	self.findres_list:SetDataList(data_list)
	if old_data_list == nil or #old_data_list <= 0 then
		self.findres_list:JumpToTop(true)
	end
	self:FlushComsumeTxt()
end

function WelfareFindresView:FlushComsumeTxt()
	local data_list = WelfareData.Instance:GetFindResList() or {}
	local num_1 = 0
	local num_2 = 0
	for k, v in pairs(data_list) do
		
		num_1 = num_1 + v.yb_find_num * v.task_num
	
		num_2 = num_2 + v.zs_find_num * v.task_num

	end

	self.node_t_list.comsume_yb_all.node:setString(num_1)
	self.node_t_list.comsume_zs_all.node:setString(num_2)

	self.node_t_list.btn_yb_all.node:setEnabled(num_1 > 0)
	self.node_t_list.btn_zs_all.node:setEnabled(num_2 > 0)

	self.need_yb = num_1
	self.need_zs = num_2
end

-- 列表Item
FindResRender = FindResRender or BaseClass(BaseRender)
function FindResRender:__init()
	self.save_data = {}
end

function FindResRender:__delete()

end

function FindResRender:CreateChild()
	BaseRender.CreateChild(self)

	XUI.AddClickEventListener(self.node_tree.btn_find_now.node, BindTool.Bind(self.OnClickFindNowHandle, self, 1), true)
	XUI.AddClickEventListener(self.node_tree.btn_find_pre.node, BindTool.Bind(self.OnClickFindNowHandle, self, 2), true)

	local ph = self.ph_list["ph_raskrew_list"]
	local ph_item = {w = BaseCell.SIZE, h = BaseCell.SIZE}
	local parent = self.view
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w+5, BaseCell, ScrollDir.Horizontal, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.task_award_list = grid_scroll
	self:AddObj("task_award_list")
end

function FindResRender:OnClickFindNowHandle(index)
	if nil == self.data or self.data.find_count == 0 then 
		return 
	end

	local num = index == 1 and self.data.yb_find_num or self.data.zs_find_num
	local item = WelfareData.Instance:GetTaskConfigAward(self.data.task_id)
	WelfareCtrl.Instance:OpenFindreTipItem({index, item, self.data.task_num, num, self.data.task_id})
end

function FindResRender:OnFlush()
	if nil == self.data then return end

	local txt = self.data.task_name .. string.format("{wordcolor;ffff00;(%d)次}", self.data.task_num)

	RichTextUtil.ParseRichText(self.node_tree.rich_task_num.node, txt, 20, COLOR3B.WHITE)

	local item = WelfareData.Instance:GetTaskConfigAward(self.data.task_id)
	self.task_award_list:SetDataList(item)

	self.node_tree.comsume_yb.node:setString(self.data.yb_find_num)
	self.node_tree.comsume_zs.node:setString(self.data.zs_find_num)

end

function FindResRender:CreateSelectEffect()
end

return WelfareFindresView