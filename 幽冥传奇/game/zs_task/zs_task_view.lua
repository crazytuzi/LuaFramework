-- 钻石任务
ZsTaskView = ZsTaskView or BaseClass(BaseView)
function ZsTaskView:__init()
	self.title_img_path = ResPath.GetWord("word_zs_task")

	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.def_index = 1

	self.texture_path_list[1] = "res/xui/zs_task.png"

	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"zs_task_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}

	self.zj_cell = nil
end

function ZsTaskView:__delete()
end

function ZsTaskView:ReleaseCallBack()
	if self.equip_eff then
		self.equip_eff:setStop()
		self.equip_eff = nil
	end

	self.zj_cell = nil
end

function ZsTaskView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateZsTaskList()

		XUI.AddClickEventListener(self.node_t_list["btn_tips"].node, BindTool.Bind(self.OnTip, self), true)
		XUI.AddClickEventListener(self.node_t_list["btn_all_rew"].node, BindTool.Bind(self.OnCleckAllReward, self), true)

		EventProxy.New(ZsTaskData.Instance, self):AddEventListener(ZsTaskData.REWARD_STATE, BindTool.Bind(self.Flush, self))
	end
end

--创建右边列表
function ZsTaskView:CreateZsTaskList()
	-- 左边列表创建
	local ph = self.ph_list.ph_task_left_list
	self.left_task_list = ListView.New()
	self.left_task_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ZsTaskListItem, nil, nil, self.ph_list.ph_task_left_item)
	self.node_t_list.layout_zs_task.node:addChild(self.left_task_list:GetView(), 99)
	self.left_task_list:SetItemsInterval(8)
	self.left_task_list:SetMargin(2)
	self.left_task_list:SetJumpDirection(ListView.Top)
	self:AddObj("left_task_list")

	-- 右边列表创建
	ph = self.ph_list.ph_task_right_list
	self.right_task_list = ListView.New()
	self.right_task_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ZsTaskListItem, nil, nil, self.ph_list.ph_task_right_item)
	self.node_t_list.layout_zs_task.node:addChild(self.right_task_list:GetView(), 99)
	self.right_task_list:SetItemsInterval(8)
	self.right_task_list:SetMargin(2)
	self.right_task_list:SetJumpDirection(ListView.Top)
	self:AddObj("right_task_list")

	-- 奖励物品特效
	if nil == self.equip_eff then
		ph = self.ph_list.ph_effect_equip
	 	self.equip_eff = AnimateSprite:create()
	 	self.equip_eff:setPosition(ph.x, ph.y + 5)
	 	self.node_t_list.layout_zs_task.node:addChild(self.equip_eff, 100)
	end

	if nil == self.zj_cell then
		self.zj_cell = BaseCell.New()
		self.zj_cell:SetPosition(self.ph_list.ph_zj_cell.x, self.ph_list.ph_zj_cell.y)
		self.zj_cell:SetIndex(i)
		self.zj_cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_zs_task.node:addChild(self.zj_cell:GetView(), 101)
	end	
end

-- 任务说明
function ZsTaskView:OnTip()
	DescTip.Instance:SetContent(Language.DescTip.ZsTaskContent, Language.DescTip.ZsTaskTitle)
end

-- 领取大任务奖励
function ZsTaskView:OnCleckAllReward()
	ZsTaskCtrl.Instance:SendBigAwardReq()
end

function ZsTaskView:ShowIndexCallBack(index)
	self:Flush(index)
end
	
function ZsTaskView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ZsTaskView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ZsTaskView:OnFlush(param_t, index)
	local item_1, item_2 = ZsTaskData.Instance:GetNewTaskList()
	self.left_task_list:SetDataList(item_1)
	self.right_task_list:SetDataList(item_2)

	local big_index = ZsTaskData.Instance:GetBigTaskIndex()
	self.node_t_list.img_gift.node:loadTexture(ResPath.GetZsTask("txt_lb_" .. big_index-1))
	self.node_t_list.img_task.node:loadTexture(ResPath.GetZsTask("txt_task_" .. big_index))

	-- local itemid = ZsTaskData.Instance:GetShowEffId()
	-- local config = SpecialTipsCfg[itemid]
	local modleId = TaskGoodGiftConfig.task[big_index].ItemEffect

	if modleId then
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(modleId)
		-- self.equip_eff:setScale(0.8)
		self.equip_eff:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		if modleId == 1071 then
			local ph = self.ph_list.ph_effect_equip
			self.equip_eff:setPositionX(ph.x-60)
		end
	end

	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local zj_item = TaskGoodGiftConfig.task[big_index].awards[sex+1]
	self.zj_cell:SetData({type = zj_item.type, item_id = zj_item.id, is_bind = zj_item.bind, num = zj_item.count})

	local btn_vis = ZsTaskData.Instance:GetSmallTaskRew()
	self.node_t_list["btn_all_rew"].node:setVisible(btn_vis)
end

--右边信息列表Item
ZsTaskListItem = ZsTaskListItem or BaseClass(BaseRender)
function ZsTaskListItem:__init()

end

function ZsTaskListItem:__delete()

end

function ZsTaskListItem:CreateChild()
	BaseRender.CreateChild(self)

	-- 奖励物品创建
	if nil == self.cell then
		self.cell = BaseCell.New()
		self.cell:SetPosition(self.ph_list.ph_item_cell.x, self.ph_list.ph_item_cell.y)
		self.cell:SetIndex(i)
		self.cell:SetAnchorPoint(0.5, 0.5)
		self.view:addChild(self.cell:GetView(), 1)
	end	

	-- 任务描述
	local ph_txt = self.ph_list.ph_task_txt
	self.txt_task_desc = RichTextUtil.CreateLinkText("", 18, COLOR3B.GREEN)
	self.txt_task_desc:setPosition(ph_txt.x, ph_txt.y)
	XUI.AddClickEventListener(self.txt_task_desc, BindTool.Bind(self.OnTaskDesc, self), true)
	self.node_tree.layout_task_desc.node:addChild(self.txt_task_desc, 100)
	
	XUI.AddClickEventListener(self.node_tree["btn_rew"].node, BindTool.Bind(self.OnClickReward, self), true)
end

function ZsTaskListItem:OnFlush()
	if nil == self.data then return end	
	
	self.node_tree.lbl_task_name.node:setString(self.data.task_title)
	local award = ItemData.InitItemDataByCfg(self.data.award)
	self.cell:SetData(award)
	self.node_tree.layout_task_desc.node:setVisible(not (self.data.com_time >= self.data.all_time and self.data.state == 0))
	self.node_tree.btn_rew.node:setVisible(self.data.com_time >= self.data.all_time and self.data.state == 0)
	self.node_tree.layout_task_desc.lbl_task_time.node:setString("(" .. self.data.com_time .. "/" .. self.data.all_time .. ")")
	self.node_tree.layout_task_desc.lbl_task_time.node:setColor(self.data.com_time >= self.data.all_time and COLOR3B.GREEN or COLOR3B.RED)
	self.txt_task_desc:setString(self.data.task_desc)
	self.txt_task_desc:setColor(self.data.state == 1 and COLOR3B.GRAY or COLOR3B.GREEN)
	self.node_tree.img9_bg.node:loadTexture(self.data.state == 1 and ResPath.GetZsTask("img_bg_2") or ResPath.GetZsTask("img_bg_1"))
	self.node_tree.img_is_rew.node:setVisible(self.data.state == 1)
end

-- 点击任务描述前往
function ZsTaskListItem:OnTaskDesc()
	if self.data.state == 1 then return end

	if self.data.view_def == nil then
		Scene.SendQuicklyTransportReqByNpcId(self.data.npcid)
		-- Scene.SendQuicklyTransportReq(self.data.npcid)
	else
		ViewManager.Instance:OpenViewByStr(self.data.view_def)
		ViewManager.Instance:CloseViewByDef(ViewDef.ZsTaskView)
	end
end

-- 单个任务领取
function ZsTaskListItem:OnClickReward()
	ZsTaskCtrl.Instance:SendSmallAwardReq(self.data.index-1)
end

function ZsTaskListItem:CreateSelectEffect()
	-- local size = self.view:getContentSize()
	-- self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_285"), true)
	-- if nil == self.select_effect then
	-- 	ErrorLog("BaseRender:CreateSelectEffect fail")
	-- 	return
	-- end

	-- self.view:addChild(self.select_effect, 999)
	return
end