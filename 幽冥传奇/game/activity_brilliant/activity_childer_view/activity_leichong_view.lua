LeiChongView = LeiChongView or BaseClass(ActBaseView)

function LeiChongView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function LeiChongView:__delete()
	if nil~=self.grid_leichong_scroll_list then
		self.grid_leichong_scroll_list:DeleteMe()
	end
	self.grid_leichong_scroll_list = nil
end

function LeiChongView:InitView()
	self:CreateLeichongGridScroll()
	self.node_t_list["rich_activity_tip"].node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
end

function LeiChongView:RefreshView(param_list)
	local text = string.format(Language.ActivityBrilliant.LeiChongTipTitle[self.act_id], ActivityBrilliantData.Instance:GetTodayRecharge())
	local rich = self.node_t_list["rich_activity_tip"].node
	rich = RichTextUtil.ParseRichText(rich, text, 20, COLOR3B.GREEN)
	rich:refreshView()
	
	self.grid_leichong_scroll_list:SetDataList(ActivityBrilliantData.Instance:GetLeichongRewardList())
	self.grid_leichong_scroll_list:JumpToTop()
end

--累冲奖励
function LeiChongView:CreateLeichongGridScroll()
	if nil == self.node_t_list.layout_leichong then
		return
	end
	if nil == self.grid_leichong_scroll_list then
		local ph = self.ph_list.ph_leichong_view_list
		self.grid_leichong_scroll_list = GridScroll.New()
		self.grid_leichong_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 1, self.ph_list.ph_leichong_list.h + 3, LeichongItemRender, ScrollDir.Vertical, false, self.ph_list.ph_leichong_list)
		self.node_t_list.layout_leichong.node:addChild(self.grid_leichong_scroll_list:GetView(), 100)
	end	
end