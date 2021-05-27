local CSHonorActView = CSHonorActView or BaseClass(CSActBaseView)
local RankHonorItem = RankHonorItem or BaseClass(BaseRender)
local AllRankHonorItem = AllRankHonorItem or BaseClass(BaseRender)

function CSHonorActView:__init(view, parent)
	self:LoadView(parent)
end

function CSHonorActView:__delete()
	if nil ~= self.rank_list then
		self.rank_list:DeleteMe()
		self.rank_list = nil
	end

	if nil ~= self.rank1_reward_list then
		self.rank1_reward_list:DeleteMe()
		self.rank1_reward_list = nil
	end

	if nil ~= self.person_reward_list then
		self.person_reward_list:DeleteMe()
		self.person_reward_list = nil
	end

	if nil ~= self.all_rank_list then
		self.all_rank_list:DeleteMe()
		self.all_rank_list = nil
	end

	self.effect = nil
end

function CSHonorActView:InitView()
	local ph_list = self.ph_list.ph_list_reward
	self.rank1_reward_list = ListView.New()
	self.rank1_reward_list:Create(ph_list.x, ph_list.y, ph_list.w, ph_list.h, ScrollDir.Horizontal, BaseCell)
	self.rank1_reward_list:SetItemsInterval(20)
	self.tree.node:addChild(self.rank1_reward_list:GetView(), 100)
	
	local ph_list = self.ph_list.ph_person_reward
	self.person_reward_list = ListView.New()
	self.person_reward_list:Create(ph_list.x, ph_list.y, ph_list.w, ph_list.h, ScrollDir.Horizontal, BaseCell)
	self.person_reward_list:SetItemsInterval(20)
	self.tree.node:addChild(self.person_reward_list:GetView(), 100)

	local ph_list = self.ph_list.ph_rank_list
	self.rank_list = ListView.New()
	self.rank_list:Create(ph_list.x, ph_list.y, ph_list.w, ph_list.h, ScrollDir.Vertical, RankHonorItem, nil, true, self.ph_list.ph_honor_rank_item)
	self.rank_list:SetItemsInterval(5)
	self.rank_list:SetMargin(5)
	self.tree.node:addChild(self.rank_list:GetView(), 100)

	XUI.AddClickEventListener(self.tree.layout_btn_see_rank.node, function()
		self:ChangeAllRankBoard(true)
	end, true)

	XUI.AddClickEventListener(self.tree.btn_rec_person_reward.node, function()
		self:SendRecPersonRewardReq(self.act_model:GetCurPersonLevel())
	end, true)

	local event_proxy = EventProxy.New(self.act_model, self)
	event_proxy:AddEventListener("XFRY_DATA_CHANGE", BindTool.Bind(self.OnDataChange, self))
	event_proxy:AddEventListener("CZRY_DATA_CHANGE", BindTool.Bind(self.OnDataChange, self))
	event_proxy:AddEventListener("XBRY_DATA_CHANGE", BindTool.Bind(self.OnDataChange, self))
	event_proxy:AddEventListener("CQRY_DATA_CHANGE", BindTool.Bind(self.OnDataChange, self))
end

function CSHonorActView:OnDataChange()
	self:RefreshView()
end

function CSHonorActView:ShowIndexView(param_list)
	ActivityBrilliantCtrl.Instance.ActivityReq(3, self.act_id)
	self:RefreshView()
end

function CSHonorActView:RefreshView(param_list)
	local data_list = {}
	for k, v in pairs(self.act_model.act_cfg.config.rankings[1].award) do
		data_list[#data_list + 1] = ItemData.FormatItemData(v)
	end
	local num = #data_list
	local interval = (self.ph_list.ph_list_reward.w - 10 - num * 80) / (num - 1)
	self.rank1_reward_list:SetItemsInterval(interval)
	self.rank1_reward_list:SetDataList(data_list)
	local role_name = ""
	local gold_xiaofei = self.act_model.act_cfg.config.rankings[1].count
	if nil ~= self.act_model.data.rank_list then
		local rank1_vo = self.act_model.data.rank_list[1]
		if rank1_vo and rank1_vo[3] >= self.act_model.act_cfg.config.rankings[1].count then
			role_name = rank1_vo[2]
			-- gold_xiaofei = rank1_vo[3]
		end
	end
	self.tree.lbl_rank_1_role_name.node:setString(role_name)
	self.tree.lbl_gold_xiaofei.node:setString(Language.CSOperateAct.GoldConsume .. gold_xiaofei)

	local data_list = {}
	local cur_level = self.act_model:GetCurPersonLevel()
	local join_award = self.act_model.act_cfg.config.join_award
	local is_rec_all = cur_level > #join_award
	local show_index = is_rec_all and #join_award or cur_level
	for k, v in pairs(join_award[show_index].award) do
		data_list[#data_list + 1] = ItemData.FormatItemData(v)
	end
	local num = #data_list
	local interval = (self.ph_list.ph_person_reward.w - 10 - num * 80) / (num - 1)
	self.person_reward_list:SetItemsInterval(interval)
	self.person_reward_list:SetDataList(data_list)
	self.tree.lbl_gold_reward.node:setString(join_award[show_index].count .. Language.Common.Gold)
	self.tree.img_rec.node:setVisible(is_rec_all)
	self.tree.btn_rec_person_reward.node:setVisible(not is_rec_all)

	local data_list = {}
	for k, v in ipairs(self.act_model:GetRankDataList()) do
		if k ~= 1 then
			data_list[#data_list + 1] = v
		else
		end
	end
	self.rank_list:SetDataList(data_list)

	local effect_id = self.act_model:GetEffectId()
	if nil == self.effect then
		self.effect = RenderUnit.CreateEffect(effect_id, self.tree.node, 999, nil, nil, 190, 329)
	else
	end
end

function CSHonorActView:ChangeAllRankBoard(show_all_rank)
	local all_rank_board_tags = {
		[998] = 1,
		[997] = 1,
	}
	for k, v in pairs(self.tree.node:getChildren()) do
		if all_rank_board_tags[v:getTag()] then
			v:setVisible(show_all_rank)
		else
			v:setVisible(not show_all_rank)
		end
	end

	if show_all_rank then
		self:FlushAllRankList()
	else
		self:RefreshView()
	end
end

function CSHonorActView:FlushAllRankList()
	if nil == self.all_rank_list then
		local ph_list = self.ph_list.ph_all_rank_list
		self.all_rank_list = ListView.New()
		self.all_rank_list:Create(ph_list.x, ph_list.y, ph_list.w, ph_list.h, ScrollDir.Vertical, AllRankHonorItem, nil, true, self.ph_list.ph_all_rank_item)
		self.all_rank_list:SetItemsInterval(20)
		self.all_rank_list:SetMargin(8)
		self.tree.node:addChild(self.all_rank_list:GetView(), 100, 998)

		local return_node = XUI.CreateImageView(980, 24, ResPath.GetCommon("btn_return"), true)
		self.tree.node:addChild(return_node, 997, 997)
		XUI.AddClickEventListener(return_node, BindTool.Bind(self.ChangeAllRankBoard, self, false), true)
	end

	self.all_rank_list:SetDataList(self.act_model.data.rank_list)
	self.all_rank_list:SetDataList(list)
end

function CSHonorActView:SendRecPersonRewardReq(level)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSendActivityBrillantReq)
	protocol.type = 4
	protocol.cmd_id = ActivityBrilliantData.Instance:GetCmdIdByActId(self.act_model.act_id) or 0
	protocol.act_id = self.act_model.act_id
	protocol.activity_index = level
	protocol:EncodeAndSend()
end

------------------------------------------------------------------
function RankHonorItem:__init()
end

function RankHonorItem:__delete()
	if nil ~= self.reward_list then
		self.reward_list:DeleteMe()
		self.reward_list = nil
	end
end

function RankHonorItem:CreateChild()
	RankHonorItem.super.CreateChild(self)

	local ph_list = self.ph_list.ph_list_reward
	self.reward_list = ListView.New()
	self.reward_list:Create(ph_list.x, ph_list.y, ph_list.w, ph_list.h, ScrollDir.Horizontal, BaseCell)
	self.reward_list:SetItemsInterval(10)
	self.view:addChild(self.reward_list:GetView(), 100)
end

function RankHonorItem:OnFlush()
	self.node_tree.lbl_rank_num.node:setString(string.format(Language.CSOperateAct.LevelNumFormat, self:RankNum()))
	self.node_tree.lbl_rank_role_name.node:setString(#self.data.role_list == 1 and self.data.role_list[1][2] or "")
	self.node_tree.lbl_gold_xiaofei.node:setString(Language.CSOperateAct.GoldConsume .. self.data.rank_cfg.count)
	local data_list = {}
	for k, v in pairs(self.data.rank_cfg.award) do
		data_list[#data_list + 1] = ItemData.FormatItemData(v)
	end
	self.reward_list:SetDataList(data_list)
end

function RankHonorItem:RankNum()
	return self:GetIndex() + 1
end

------------------------------------------------------------------
function AllRankHonorItem:__init()
end

function AllRankHonorItem:__delete()
	if nil ~= self.reward_list then
		self.reward_list:DeleteMe()
		self.reward_list = nil
	end
end

function AllRankHonorItem:CreateChild()
	AllRankHonorItem.super.CreateChild(self)

	local ph_list = self.ph_list.ph_list_reward
	self.reward_list = ListView.New()
	self.reward_list:Create(ph_list.x, ph_list.y, ph_list.w, ph_list.h, ScrollDir.Horizontal, BaseCell)
	self.reward_list:SetItemsInterval(16)
	self.view:addChild(self.reward_list:GetView(), 100)
end

function AllRankHonorItem:OnFlush()
	local rank_img_node = self.view:getChildByTag(98)
	local rank_num_node = self.view:getChildByTag(99)
	if self:RankNum() <= 3 then
		if rank_img_node == nil then
			self.view:addChild(XUI.CreateImageView(35, 45, "", true), 99, 98)
			self.view:addChild(XUI.CreateImageView(60, 45, "", true), 99, 99)
		else
			rank_img_node:setVisible(true)
			rank_num_node:setVisible(true)
		end
		self.view:getChildByTag(98):loadTexture(ResPath.GetRankingList("bg_crowns_" .. self:RankNum()))
		self.view:getChildByTag(99):loadTexture(ResPath.GetRankingList("ranking_" .. self:RankNum()))
	else
		self.node_tree.lbl_rank_num.node:setString(string.format(Language.CSOperateAct.RankNumFormat, self:RankNum()))
		if rank_img_node ~= nil then
			rank_img_node:setVisible(false)
			rank_num_node:setVisible(false)
		end
	end

	local act_model = ActivityBrilliantData.Instance:GetCSActModel(ACT_ID.XFRY)
	local data_list = {}
	local rank_cfg = act_model.act_cfg.config.rankings
	local award = rank_cfg[self.data.rank_level] and rank_cfg[self.data.rank_level].award or {}
	for _, item in pairs(award) do
		data_list[#data_list + 1] = ItemData.FormatItemData(item)
	end

	self.node_tree.lbl_rank_role_name.node:setString(self.data[2])
	self.node_tree.lbl_gold_xiaofei.node:setString(Language.CSOperateAct.GoldConsume .. self.data[3])
	self.reward_list:SetDataList(data_list)
end

function AllRankHonorItem:RankNum()
	return self:GetIndex()
end

------------------------------------------------------------------
return CSHonorActView
