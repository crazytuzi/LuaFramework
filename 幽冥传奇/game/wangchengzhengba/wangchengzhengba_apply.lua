local WangChengZhengBaApplyView = WangChengZhengBaApplyView or BaseClass(SubView)

function WangChengZhengBaApplyView:__init()
	self.texture_path_list[1] = 'res/xui/wangchengzhengba.png'
	self.config_tab = {
		{"wangchengzhengba_ui_cfg", 4, {0}},
	}
end

function WangChengZhengBaApplyView:LoadCallBack(index, loaded_times)
	self.node_t_list.btn_apply_siege.node:addClickEventListener(BindTool.Bind1(self.OnClickAutoApplyHandler, self))
	self:CreateRankingList()
	EventProxy.New(WangChengZhengBaData.Instance, self):AddEventListener(WangChengZhengBaData.ApplyDataChangeEvent, BindTool.Bind(self.OnFlushApplyView, self))
end

function WangChengZhengBaApplyView:ReleaseCallBack()
	if self.ranking_list then
		self.ranking_list:DeleteMe()
		self.ranking_list = nil
	end		
end

function WangChengZhengBaApplyView:ShowIndexCallBack(index)
	self:OnFlushApplyView()
end

function WangChengZhengBaApplyView:OnClickAutoApplyHandler()
	WangChengZhengBaCtrl.SendApplyGongCheng()
end

function WangChengZhengBaApplyView:CreateRankingList()
	if nil == self.ranking_list then
		local ph = self.ph_list.ph_application_list
		self.ranking_list = ListView.New()
		self.ranking_list:Create(ph.x, ph.y, ph.w, ph.h, nil, WangChengZhengBaRankingRender, nil, nil, self.ph_list.ph_society_ranking_item)
		self.ranking_list:GetView():setAnchorPoint(0, 0)
		self.ranking_list:SetMargin(3)
		self.ranking_list:SetItemsInterval(4)
		self.ranking_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_apply_siege.node:addChild(self.ranking_list:GetView(), 100)
	end
end

function WangChengZhengBaApplyView:OnFlushApplyView()
	self:UpdateList()
	self:OnFlushApplyBtnState()
end

function WangChengZhengBaApplyView:UpdateList()
	local data = WangChengZhengBaData.Instance:GetApplyGuildData()
	if data then
		for k,v in pairs(data) do
			v.show_index = k
		end
	end

	if #data < 8 then
		for i=#data, 8 - 1 do
			table.insert(data, {})
		end
	end

	self.ranking_list:SetDataList(data)
end

function WangChengZhengBaApplyView:OnFlushApplyBtnState()
	self.node_t_list.btn_apply_siege.node:setEnabled(GuildData.GetSelfGuildPosition() == SOCIAL_MASK_DEF.GUILD_LEADER or GuildData.GetSelfGuildPosition() == SOCIAL_MASK_DEF.GUILD_ASSIST_LEADER)
end




----------------------------------------
-- WangChengZhengBaRankingRender
----------------------------------------
WangChengZhengBaRankingRender = WangChengZhengBaRankingRender or BaseClass(BaseRender)
function WangChengZhengBaRankingRender:__init()	
end

function WangChengZhengBaRankingRender:__delete()	
end

function WangChengZhengBaRankingRender:CreateChild()
	BaseRender.CreateChild(self)
end

function WangChengZhengBaRankingRender:OnFlush()
	if self.index and self.index % 2 == 1 then
		self.node_tree.img9_list_item.node:loadTexture(ResPath.GetWangChengZhengBa("img9_render_bg_2"))
	end	

	if nil == self.data or not self.data.show_index then 
		self.node_tree.txt_ranking.node:setString("")
		self.node_tree.txt_society_name.node:setString("")
		self.node_tree.txt_society_grade.node:setString("")
		self.node_tree.txt_society_people.node:setString("")
		return 
	end
	self.node_tree.txt_ranking.node:setString(self.data.show_index)
	self.node_tree.txt_society_name.node:setString(self.data.guild_name or "")
	self.node_tree.txt_society_grade.node:setString(self.data.guild_level and (self.data.guild_level .. Language.Common.Ji) or "")
	local guild_total_num = self.data.guild_total_num or 0
	local guild_member_num = self.data.guild_member_num or 0
	self.node_tree.txt_society_people.node:setString(guild_member_num .. "/" .. guild_total_num)
end

function WangChengZhengBaRankingRender:CreateSelectEffect()
	
end

return WangChengZhengBaApplyView