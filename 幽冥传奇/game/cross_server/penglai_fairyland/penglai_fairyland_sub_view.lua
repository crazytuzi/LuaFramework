local PengLaiFairylandSubView = BaseClass(SubView)

function PengLaiFairylandSubView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/penglai_fairyland.png'
	self.config_tab = {
		{"penglai_fairyland_ui_cfg", 2, {0}},
	}
	self.panel_info = {}
	self.scene_index = 0
end

function PengLaiFairylandSubView:LoadCallBack()
	self:CreateBuyText()
	EventProxy.New(PengLaiFairylandData.Instance, self):AddEventListener(PengLaiFairylandData.PengLaiInfoChange, BindTool.Bind(self.OnFlushPengLaiFairylandView, self))
	XUI.AddClickEventListener(self.node_t_list.btn_tip.node, BindTool.Bind(self.OnClickTip, self))
	XUI.AddClickEventListener(self.node_t_list.btn_participate_challenge.node, BindTool.Bind(self.OnClickParticipateChallenge, self))
end

function PengLaiFairylandSubView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
		v = nil
	end
	self.cell_list = nil
	self.cell_view = nil
	self.buy_text = nil
	self.panel_info = nil
end

function PengLaiFairylandSubView:ShowIndexCallBack()
	self:OnFlushPengLaiFairylandView()
end

function PengLaiFairylandSubView:OnFlushPengLaiFairylandView()
	self.panel_info = PengLaiFairylandData.Instance:GetPengLaiFairyLandInfo()
	-- 剩余击杀BOSS次数
	local remaining_kill_text = string.format(Language.CrossBoss.RemainingCanKillBossTime, self.panel_info.remaining_can_kill_boss_times)
	self.node_t_list.lbl_remaining_kill.node:setString(remaining_kill_text)
	-- 购买次数消耗元宝显示
	local consumption_ingot_text = Language.CrossBoss.ConsumptionIngot .. self.panel_info.buy_kill_boss_time_consume
	self.node_t_list.lbl_consumption_ingot.node:setString(consumption_ingot_text)
	-- 左上角轮回显示及创建奖励显示
	self.scene_index = PengLaiFairylandData.Instance:GetScenesIndex()
	self.node_t_list.img_circle.node:loadTexture(ResPath.GetPengLaiFairyland("circle_" .. self.scene_index))
	self:CreateCell(self.scene_index)
end

-- 创建奖励显示
function PengLaiFairylandSubView:CreateCell(index)
	-- 获取滚动条
	self.cell_view = self.node_t_list.scroll_award_list.node
	self.cell_view:setScorllDirection(ScrollDir.Horizontal)

	self.cell_list = {}
	local cell_data_list = PengLaiFairylandData.Instance:GetDropAwardDataList(index)
	local total_width
	local data_list_num = #cell_data_list
	local ph = self.ph_list.ph_award_cell
	if data_list_num <= 6 then
		total_width = 537
	else
		total_width = data_list_num * ph.w + (data_list_num - 1) * 15
	end
	local x, y = 0, 15
	for k, v in pairs(cell_data_list) do
		local cell = BaseCell.New()
		self.cell_view:addChild(cell:GetView(), 10)
		x = total_width / 2 - ((data_list_num / 2) * ph.w + ((data_list_num - 1) / 2) * 15) + ((ph.w + 15) * (k - 1)) + ph.w / 2
		cell:SetPosition(x, y)
		cell:SetAnchorPoint(0.5, 0)
		cell:SetData(v)
		self.cell_list[#self.cell_list + 1] = cell
	end
	self.cell_view:setInnerContainerSize(cc.size(total_width, 110))
end

-- 创建购买次数按钮
function PengLaiFairylandSubView:CreateBuyText()
	local x, y = self.ph_list.ph_buy_text.x, self.ph_list.ph_buy_text.y
	self.buy_text = RichTextUtil.CreateLinkText(Language.CrossBoss.BuyQuantityText, 17, COLOR3B.GREEN, nil, true)
	self.buy_text:setPosition(x, y)
	self.node_t_list.layout_penglai_fairyland.node:addChild(self.buy_text, 10)
	XUI.AddClickEventListener(self.buy_text, BindTool.Bind(self.OnClickBuyText, self), true)
end

function PengLaiFairylandSubView:OnClickBuyText()
	PengLaiFairylandCtrl.SendPengLaiInfo(2)
end

-- 点击参与挑战
function PengLaiFairylandSubView:OnClickParticipateChallenge()
	CrossServerCtrl.Instance.SentJoinCrossServerReq(1, self.scene_index)
end

function PengLaiFairylandSubView:OnClickTip()
	DescTip.Instance:SetContent(PengLaiFairylandData.Instance:GetTipContent() or "", Language.Fuben.CallBossTitle)
end

return PengLaiFairylandSubView