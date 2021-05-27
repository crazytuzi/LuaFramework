GongGaoView = GongGaoView or BaseClass(ActBaseView)

local act_cfg = {}

local get_act_days = function()
	return ActivityBrilliantData.Instance:GetActPassDay(ACT_ID.GG) + 1
end

local get_notice_str = function()
	return act_cfg.config and act_cfg.config.params and act_cfg.config.params.connect or ""
end

function GongGaoView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function GongGaoView:__delete()
	self:DeleteNoticeTimer()

	if self.cell_charge_list then 
		self.cell_charge_list:DeleteMe()
		self.cell_charge_list = nil
	end
end

function GongGaoView:InitView()
	act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.GG)
	self:CreateNoticeTimer()
	self:InitNoticeGridScroll()
	self:InitUpdateNoticeView()
	XUI.AddClickEventListener(self.node_t_list.btn_notice_lingqu.node, BindTool.Bind(self.OnClickNoticeRewardBtn, self), true)
end

function GongGaoView:RefreshView(param_list)
	self:SetNoticeAwards()
 	local act_days = get_act_days()
	local is_rec = ActivityBrilliantData.Instance:GetNoticeActRecSign(act_days)
	self.node_t_list.btn_notice_lingqu.node:setTitleText(true == is_rec and Language.Common.YiLingQu or Language.Common.LingQu)
	XUI.SetButtonEnabled(self.node_t_list.btn_notice_lingqu.node, false == is_rec)
end

function GongGaoView:OnClickNoticeRewardBtn()
 	local act_days = get_act_days()
	ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.GG, act_days)
end

function GongGaoView:InitNoticeGridScroll()
	local ph = self.ph_list["ph_cell_charge_list"]
	self.cell_charge_list = ListView.New()
	self.cell_charge_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActBaseCell, ListViewGravity.CenterVertical, false, {w = 80, h = 80})
	self.cell_charge_list:SetItemsInterval(5)
	-- self.cell_charge_list:GetView():setAnchorPoint(0, 0)
	self.cell_charge_list:SetMargin(8)
	self.node_t_list.layout_notice.node:addChild(self.cell_charge_list:GetView(), 100)
end

function GongGaoView:InitUpdateNoticeView()
	local beg_time = os.date("*t", act_cfg.beg_time)
	local end_time = os.date("*t", act_cfg.end_time)
	local str_time = string.format(Language.ActivityBrilliant.AboutTime, beg_time.month, beg_time.day, beg_time.hour, beg_time.min)
	local str_time_2 = string.format(Language.ActivityBrilliant.AboutTime, end_time.month, end_time.day, end_time.hour, end_time.min)
	self.node_t_list.lbl_notice_time.node:setString(str_time .. "-" .. str_time_2)

	local scroll_node = self.node_t_list.scroll_text_content.node
	local rich_content = XUI.CreateRichText(30, 10, 660, 0, false)
	scroll_node:addChild(rich_content, 100, 100)
	local text = get_notice_str()
	HtmlTextUtil.SetString(rich_content, text)
	rich_content:refreshView()

	local scroll_size = scroll_node:getContentSize()
	local inner_h = math.max(rich_content:getInnerContainerSize().height + 20, scroll_size.height)
	scroll_node:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	rich_content:setPosition(scroll_size.width / 2, inner_h - 10)
	scroll_node:jumpToTop()
end

function GongGaoView:SetNoticeAwards()
	local notice_awards_cfg = act_cfg.config.awards
 	local act_days = get_act_days()

	local cell_data_list = {}
	if nil ~= notice_awards_cfg[act_days] then
		local cell_data = notice_awards_cfg[act_days].award
		for k, v in pairs(cell_data) do
			cell_data_list[k] = ItemData.InitItemDataByCfg(v)
		end
	end
	self.cell_charge_list:SetDataList(cell_data_list)
	self.cell_charge_list:SetJumpDirection(ListView.Left)
end

function GongGaoView:CreateNoticeTimer()
	self.notice_spare_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateNoticeOnlineTime, self), 1)
end

function GongGaoView:DeleteNoticeTimer()
	if self.notice_spare_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.notice_spare_time)
		self.notice_spare_time = nil
	end
end

function GongGaoView:UpdateNoticeOnlineTime()
	if nil == act_cfg then return end
	local now_time = TimeCtrl.Instance:GetServerTime()
	local end_time = act_cfg.end_time 
	local spare_time = end_time - now_time 
	self.node_t_list.lbl_notice_spare_time.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end
