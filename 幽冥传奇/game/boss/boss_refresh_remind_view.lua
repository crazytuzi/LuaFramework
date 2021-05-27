--BOSS提醒视图
BossRefreshRemindView = BossRefreshRemindView or BaseClass(BaseView)

function BossRefreshRemindView:__init()
	self:SetIsAnyClickClose(true)
	self.texture_path_list = {
		'res/xui/rankinglist.png',
		-- 'res/xui/meridians.png',
		-- 'res/xui/equipbg.png',
		-- 'res/xui/prestige.png',
	}
	self.config_tab = {
		{"boss_refresh_remind_ui_cfg", 1, {0}},
	}
	self.ranking_list = nil
	self.boss_type = -1
end

function BossRefreshRemindView:__delete()
end

function BossRefreshRemindView:ReleaseCallBack()
	if self.ranking_list then	
		self.ranking_list:DeleteMe()
		self.ranking_list = nil
	end	
end

function BossRefreshRemindView:LoadCallBack(index, loaded_times)
	self:CreateRankingList()
	-- EventProxy.New(RankingListData.Instance, self):AddEventListener(RankingListData.SHILIAN_LIST_CHANGE, BindTool.Bind(self.OnShiLianListChange, self))
end

function BossRefreshRemindView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BossRefreshRemindView:CloseCallBack(is_all)
	if self.boss_type >= 0 and BossData.Instance:GetOneTypeRemindInt64Value(self.boss_type) then
		BossCtrl.SetOneTypeBossRemindFlag(self.boss_type, BossData.Instance:GetOneTypeRemindInt64Value(self.boss_type))
		self:DispatchEvent(BossData.BOSS_DATA_REFRESH)
	end
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BossRefreshRemindView:ShowIndexCallBack(index)
	self:Flush(index)
end

function BossRefreshRemindView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "all" then
			self:FlushRanking(v.data)
		end
	end
end
------------------------------------------------------------------------------
function BossRefreshRemindView:ReleaseHelper()
	self.view_manager:AddReleaseObj(self)
end

function BossRefreshRemindView:Close(...)
	if not ViewManager.Instance:IsOpen(ViewDef.BossRefreshRemind) then
		BossRefreshRemindView.super.Close(self, ...)
	end
end
------------------------------------------------------------------------------

----------end----------
function BossRefreshRemindView:CreateRankingList()
	if nil == self.ranking_list then
		local ph = self.ph_list.ph_ranking_list
		self.ranking_list = ListView.New()
		self.ranking_list:Create(ph.x, ph.y, ph.w, ph.h, nil, self.RankingRender, nil, nil, self.ph_list.ph_rankinglist_item)
		self.ranking_list:GetView():setAnchorPoint(0, 0)
		self.ranking_list:SetMargin(2)
		self.ranking_list:SetItemsInterval(5)
		self.ranking_list:SetJumpDirection(ListView.Top)
		self.ranking_list:SetSelectCallBack(BindTool.Bind(self.OnRankCallBack, self))
		self.node_t_list.layout_board_bottom.node:addChild(self.ranking_list:GetView(), 100)
	end	
end

function BossRefreshRemindView:OnRankCallBack(select_item, index)
	if select_item then
		local data = select_item:GetData()
	end
end

function BossRefreshRemindView:FlushRanking(data)
	if not self.ranking_list or not data then return end
	self.boss_type = data[1] and data[1].boss_type or data[1].type or -1
	self.ranking_list:SetDataList(data)
end

----------BOSS提醒列表----------
BossRefreshRemindView.RankingRender = BaseClass(BaseRender)
local RankingRender = BossRefreshRemindView.RankingRender
function RankingRender:__init()
	self.save_data = {}
	self.img_list = {}
end

function RankingRender:__delete()
end

function RankingRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph_checkbox = self.ph_list.ph_checkbox
	self.yb_check_box = XUI.CreateCheckBox(ph_checkbox.x, ph_checkbox.y, ResPath.GetCommon("img9_110"), ResPath.GetCommon("bg_checkbox_hook2"), bg_disable, cross, cross_disable, true)
	self.view:addChild(self.yb_check_box, 10)
	-- self.yb_check_box:setSelected(false)
	XUI.AddClickEventListener(self.yb_check_box, BindTool.Bind(self.OnCheckBoxClick, self, self.yb_check_box))
	-- self.yb_check_box_check_flag = self.yb_check_box:isSelected()
end

function RankingRender:OnFlush()
	if self.data == nil then return end
	self.node_tree.img9_stripes.node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)

	-- 默认取ModBossTips
	self.data.boss_name = self.data.boss_name or self.data.BossName
	self.data.boss_type = self.data.boss_type or self.data.type or 0
	self.data.boss_id = self.data.boss_id or self.data.BossId
	self.data.rindex = self.data.rindex or BossData.Instance:GetRemindex(self.data.boss_type, self.data.boss_id) or 0
	self.yb_check_box:setSelected(BossData.Instance:GetRemindFlag(self.data.boss_type, self.data.rindex) == 0)

	-- self.yb_check_box:setSelected(NewlyBossData.Instance:GetBossIsShow(self.data.boss_type, self.data.boss_id) == 0)
	
	self.node_tree.txt_name.node:setString(self.data.boss_name)
	local is_enough, text_str = BossData.BossIsEnoughAndTip(self.data)
	local lv_str = ""
	if is_enough then
		lv_str = self.data.bosslv..Language.Common.Ji
	-- if self.data.monster_lunhui > 0 then
	-- 	lv_str = self.data.monster_lunhui..Language.Common.Dao
	-- elseif self.data.monster_circle > 0 then
	-- 	lv_str = self.data.monster_circle..Language.Common.Zhuan
	else
		lv_str = text_str
	end
	self.node_tree.txt_lev.node:setString(lv_str)
	self.node_tree.txt_lev.node:setColor(is_enough and COLOR3B.GREEN or COLOR3B.RED)
	self.node_tree.txt_state.node:setString(is_enough and "" or Language.Boss.NotMatchLvCond)
	self.yb_check_box:setVisible(is_enough)
	self.node_tree.txt_relive_remind.node:setVisible(is_enough)	
end

function RankingRender:OnCheckBoxClick(sender)
	if not self.data then return end
	BossData.Instance:SetOneTypeRemindFlag(self.data.boss_type, 64-self.data.rindex, sender:isSelected() and 0 or 1)

	NewlyBossData.Instance:ChangeState()
end