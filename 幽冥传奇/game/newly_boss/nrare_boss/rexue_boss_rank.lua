local ReXueBossRankView = BaseClass(BaseView)
local ReXueBossAwardRender = BaseClass(BaseRender)

function ReXueBossRankView:__init()
	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/boss.png',
	}
	self.config_tab = {
		{"new_boss_ui_cfg", 14, {0}},
	}

	-- 管理自定义对象
	self._objs = {}
end

function ReXueBossRankView:ReleaseCallBack()
	-- 清理自定对象
	for k, v in pairs(self._objs) do
		if nil == v.DeleteMe then ErrorLog("不可清理的对象 ReleaseCallBack ReXueBossRankView") end
		v:DeleteMe()
	end
	self._objs = {}
end

function ReXueBossRankView:LoadCallBack(index, loaded_times)
	EventProxy.New(NewlyBossData.Instance, self):AddEventListener(NewlyBossData.RX_BOSS_RANK_LIST_CHANGE, function ()	
		self._objs.award_list:SetData(ReXueBaZheBossCfg.rankAwards.ranks)
	end)

	EventProxy.New(NewlyBossData.Instance, self):AddEventListener(NewlyBossData.RX_BOSS_SELF_RANK_CHANGE, function ()
		self.node_t_list.lbl_myrank.node:setString(NewlyBossData.Instance:GetReXueBossInfo().rank)
		self.node_t_list.lbl_myscore.node:setString(NewlyBossData.Instance:GetReXueBossInfo().score)
	end)
	self:CreateAwardList()
end

function ReXueBossRankView:ShowIndexCallBack()
	self:FlushView()
end

function ReXueBossRankView:CreateAwardList()
    if nil == self._objs.award_list then
        local ph = self.ph_list.ph_list_view
        self._objs.award_list = ListView.New()
        self._objs.award_list:Create( ph.x, ph.y, ph.w, ph.h, nil, ReXueBossAwardRender, nil, nil, self.ph_list.ph_list_cell)
        self.node_t_list.layout_rexue_rank.node:addChild(self._objs.award_list:GetView(), 100)
        self._objs.award_list:SetJumpDirection(ListView.Top)
        self._objs.award_list:SetMargin(2) --首尾留空
    end
end

function ReXueBossRankView:FlushView()
	self._objs.award_list:SetData(ReXueBaZheBossCfg.rankAwards.ranks)
	self.node_t_list.lbl_myrank.node:setString(NewlyBossData.Instance:GetReXueBossInfo().rank)
	self.node_t_list.lbl_myscore.node:setString(NewlyBossData.Instance:GetReXueBossInfo().score)
end

function ReXueBossRankView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ReXueBossRankView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.data = nil
end

function ReXueBossRankView:OnDataChange(vo)
end



function ReXueBossAwardRender:__init()
end

function ReXueBossAwardRender:__delete()
	if nil ~= self.cell_charge_list then
		self.cell_charge_list:DeleteMe()
		self.cell_charge_list = nil
	end

	if nil ~= self.num_bar then
		self.num_bar:DeleteMe()
		self.num_bar = nil
	end
end

function ReXueBossAwardRender:CreateChild()
	BaseRender.CreateChild(self)

	local ph = self.ph_list["ph_cell_grid"]
	self.cell_charge_list = ListView.New()
	self.cell_charge_list:Create(ph.x, ph.y + 12, ph.w, ph.h, ScrollDir.Horizontal, BaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	self.cell_charge_list:GetView():setAnchorPoint(0, 0)
	self.cell_charge_list:GetView():setScale(0.7)
	self.cell_charge_list:SetItemsInterval(10)
	self.view:addChild(self.cell_charge_list:GetView(), 10)

	-- 奖励
	local data_list = {}
	for k, v in pairs(self.data.awards) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.FormatItemData(v))
		end
	end
	self.cell_charge_list:SetDataList(data_list)

	self.num_bar = NumberBar.New()
	self.num_bar:SetRootPath(ResPath.GetBoss("rexue_rank_num_"))
	self.num_bar:SetPosition(46, 30)
	self.num_bar:SetSpace(-10)
	self.num_bar:SetNumber(self:GetIndex())
	if self:GetIndex() >= 10 then
		self.num_bar:SetPosition(40, 30)
	end
	self.view:addChild(self.num_bar:GetView(), 300, 300)
end

function ReXueBossAwardRender:CreateSelectEffect()
end

local idx2color = {COLOR3B.YELLOW, COLOR3B.PURPLE, COLOR3B.BLUE}
function ReXueBossAwardRender:OnFlush()
	if nil == self.data then
		return
	end

	local rank_info = NewlyBossData.Instance:GetReXueBossRankList()[self:GetIndex()]
	if rank_info then
		self.node_tree.lbl_name.node:setString(rank_info.name)
		self.node_tree.lbl_score.node:setString(rank_info.score)
	else
		self.node_tree.lbl_name.node:setString("暂无")
		self.node_tree.lbl_score.node:setString("")
	end
	self.node_tree.lbl_name.node:setColor(idx2color[self:GetIndex()] or COLOR3B.WHITE)
	self.node_tree.lbl_score.node:setColor(idx2color[self:GetIndex()] or COLOR3B.WHITE)

	-- self.awards_list:SetData(self.data)
	-- local cfg = ItemData.Instance:GetItemConfig(self.data.id)
	-- RichTextUtil.ParseRichText(self.node_tree.rich_record.node, cfg.name .. "{wordcolor;1eff00;x" .. self.data.count .. "}", 20, COLOR3B.PURPLE)
end

return ReXueBossRankView