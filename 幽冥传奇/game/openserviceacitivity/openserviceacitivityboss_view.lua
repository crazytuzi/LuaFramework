local OpenServiceAcitivityBossView = OpenServiceAcitivityBossView or BaseClass(SubView)

function OpenServiceAcitivityBossView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/openserviceacitivity.png'
	self.config_tab = {
		{"openserviceacitivity_ui_cfg", 3, {0}},
		{"openserviceacitivity_ui_cfg", 8, {0}},
	}
end

function OpenServiceAcitivityBossView:LoadCallBack()
	self.panel_info = OpenServiceAcitivityData.Instance:GetBossInfo()
	self:CreateList()
	EventProxy.New(OpenServiceAcitivityData.Instance, self):AddEventListener(OpenServiceAcitivityData.BossChange, BindTool.Bind(self.OnFlushBossView, self))
	RichTextUtil.ParseRichText(self.node_t_list.rich_tips.node, self.panel_info.tips, 19, COLOR3B.OLIVE)
	self.node_t_list.rich_tips.node:setPosition(self.node_t_list.rich_tips.node:getPositionX(),self.node_t_list.rich_tips.node:getPositionY()+12)
end

function OpenServiceAcitivityBossView:ReleaseCallBack()
	if self.boss_gift_list then
		self.boss_gift_list:DeleteMe()
		self.boss_gift_list = nil
	end
	self.panel_info = {}
end

function OpenServiceAcitivityBossView:OnFlushBossView()
	self.panel_info = OpenServiceAcitivityData.Instance:GetBossInfo()
	self.node_t_list.lbl_activity_time.node:setString(self.panel_info.activity_time_interval)
	self.boss_gift_list:SetDataList(self.panel_info.item_list)
end

function OpenServiceAcitivityBossView:ShowIndexCallBack()
	self.node_t_list.img_top_bg.node:loadTexture(ResPath.GetBigPainting("open_service_acitivity_bg1"))
	self:OnFlushBossView()
end

function OpenServiceAcitivityBossView:CreateList()
	if self.boss_gift_list then return end
	local ph = self.ph_list.ph_boss_list
	self.boss_gift_list = ListView.New()
	self.boss_gift_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BossAwardListRender, nil, nil, self.ph_list.ph_boss_item)
	self.boss_gift_list:GetView():setAnchorPoint(0, 0)
	self.node_t_list.layout_boss.node:addChild(self.boss_gift_list:GetView(), 100)
	self.boss_gift_list:SetItemsInterval(1)
	self.boss_gift_list:SetJumpDirection(ListView.Top)
	-- self.boss_gift_list:SetSelectCallBack(BindTool.Bind1(self.SelectSkillCallBack, self))
end

----------------------------------------------
-- 奖励列表item
----------------------------------------------

BossAwardListRender = BossAwardListRender or BaseClass(BaseRender)

function BossAwardListRender:__init()
end

function BossAwardListRender:__delete()
end

function BossAwardListRender:CreateChild()
	BaseRender.CreateChild(self)
	self:CreateAwardScroll()
	self:CreateNeedKillNum()
	XUI.AddClickEventListener(self.node_tree.btn_receive.node, BindTool.Bind(self.OnClickReceive, self))
	self.node_tree.btn_receive.node:setVisible(true)
	self.node_tree.img_stamp.node:setVisible(false)
	self.node_tree.btn_receive.remind_eff = RenderUnit.CreateEffect(23, self.node_tree.btn_receive.node, 1)
end

function BossAwardListRender:OnFlush()
	if nil == self.data then return end

	self.need_kill_num:SetNumber(self.data.need_kill)
	self.node_tree.lbl_kill_num.node:setString("(" .. self.data.kill_count .. "/" .. self.data.need_kill .. ")")
	self:CreateAwardList()
	if self.data.btn_state == 0 then
		self.node_tree.btn_receive.node:setEnabled(false)
		self.node_tree.btn_receive.node:setTitleText("未完成")
		self.node_tree.btn_receive.remind_eff:setVisible(false)
	elseif self.data.btn_state == 1 then
		self.node_tree.btn_receive.node:setEnabled(true)
		self.node_tree.btn_receive.node:setTitleText("领    取")
		self.node_tree.btn_receive.remind_eff:setVisible(true)
	else
		self.node_tree.btn_receive.node:setVisible(false)
		self.node_tree.img_stamp.node:setVisible(true)
	end
end

function BossAwardListRender:CreateAwardList()
	if self.award_cell_list then 
		for k, v in pairs(self.award_cell_list) do
			v:GetView():removeFromParent()
			v:DeleteMe()
			v = nil
		end
		self.award_cell_list = {}
	end
	self.award_cell_list = {}
	local x, y = 0, 0
	local x_interval = 85
	for k, v in pairs(self.data.award_list) do
		local award_cell = BaseCell.New()
		award_cell:SetAnchorPoint(0, 0)
		self.reward_list_view:addChild(award_cell:GetView(), 99)
		award_cell:SetPosition(x, y)
		award_cell:SetData(v)
		x = x + x_interval
		table.insert(self.award_cell_list, award_cell)
	end
	local w = #self.data.award_list * x_interval
	self.reward_list_view:setInnerContainerSize(cc.size(w, 80))
end

function BossAwardListRender:CreateAwardScroll()
	self.reward_items = {}
	self.reward_list_view = self.node_tree.scroll_award_view.node
	self.reward_list_view:setScorllDirection(ScrollDir.Horizontal)
end

-- 创建需要充值数字显示
function BossAwardListRender:CreateNeedKillNum()
	if self.need_kill_num ~= nil then return end
	local x, y = self.node_tree.img_kill_num_bg.node:getPosition()
	local kill_num = NumberBar.New()
	kill_num:SetRootPath(ResPath.GetCommon("num_150_"))
	kill_num:SetPosition(x - 25, y - 10)
	kill_num:SetSpace(-5)
	self.need_kill_num = kill_num
	self.need_kill_num:SetGravity(NumberBarGravity.Center)
	self:GetView():addChild(kill_num:GetView(), 100, 100)
end

-- 创建选中特效
function BossAwardListRender:CreateSelectEffect()
end

-- 领取奖励按钮回调
function BossAwardListRender:OnClickReceive()
	OpenServiceAcitivityCtrl.SendGetBossGift(self.data.index)
end

return OpenServiceAcitivityBossView