ExpGetRewardView = ExpGetRewardView or BaseClass(BaseView)
function ExpGetRewardView:__init( ... )
	 self.is_modal = true
	 self.is_any_click_close = true	
	  self.texture_path_list = {
		'res/xui/fuben_cl.png',
		'res/xui/fuben.png',
	}
	 self.config_tab = {
        --{"common_ui_cfg", 1, {0}},
        {"fuben_cl_and_jy_ui_cfg", 6, {0}},
		--{"common_ui_cfg", 2, {0}, nil , 999},
    }
end

function ExpGetRewardView:__delete( ... )
	-- body
end

function ExpGetRewardView:ReleaseCallBack( ... )
	if self.reward_list then
		self.reward_list:DeleteMe()
		self.reward_list = nil
	end
	if self.data_change then
		GlobalEventSystem:UnBind(self.data_change)
		self.data_change = nil
	end
end

function ExpGetRewardView:LoadCallBack( ... )
	self:CreateListShow()
	self.data_change = GlobalEventSystem:Bind(JI_YAN_FUBEN_EVENT.DATA_CHANGE, BindTool.Bind1(self.ChangeDataClose,self))
end

function ExpGetRewardView:ChangeDataClose( ... )
	if FubenData.Instance:GetCurFightLevel() <= 0 then
		ViewManager.Instance:CloseViewByDef(ViewDef.ShowRewardExp)
	end
end

function ExpGetRewardView:OpenCallBack( ... )
	-- body
end

function ExpGetRewardView:CloseCallBack( ... )
	-- body
end

function ExpGetRewardView:CreateListShow( ... )
	if nil == self.reward_list then
		local ph = self.ph_list.ph_list--获取区间列表
		self.reward_list = ListView.New()
		self.reward_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, RewardListItem, nil, nil, self.ph_list.ph_list_item_reward)
		self.reward_list:SetItemsInterval(2)--格子间距
		self.reward_list:SetMargin(5)
		self.reward_list:SetJumpDirection(ListView.Top)--置顶
		self.node_t_list.latout_get_reward.node:addChild(self.reward_list:GetView(), 20)
		--self.reward_list:SetSelectCallBack(BindTool.Bind(self.SelectEquipListCallback, self))
		self.reward_list:GetView():setAnchorPoint(0, 0)
	end
end

function ExpGetRewardView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ExpGetRewardView:SetRewardShowList()
	-- body
end

function ExpGetRewardView:OnFlush()
	local data = expFubenConfig.getAwardsType
	self.reward_list:SetDataList(data)

	local last_level = FubenData.Instance:GetCurFightLevel()
	local last_bo = FubenData.Instance:GetHadTongGuangBo()
	if last_bo == 0 then
		last_bo = 1
	end
	local score =  DungeonData.Instance:GetScore(last_level, last_bo)
	self.node_t_list.img_level.node:loadTexture(ResPath.GetFubenCL("level_".. score))

	local total_bo = DungeonData.Instance:GetHadMonsterLevel(last_level)

	local text = string.format(Language.JiYanFubenShow.showDesc1, FubenData.Instance:GetHadTongGuangBo(), total_bo)
	
	RichTextUtil.ParseRichText(self.node_t_list.text_skill_num.node, text)
	XUI.RichTextSetCenter(self.node_t_list.text_skill_num.node)
end


RewardListItem = RewardListItem or BaseClass(BaseRender)
function RewardListItem:__init( ... )
	-- body
end

function RewardListItem:__delete( ... )
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function RewardListItem:CreateChild( ... )
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.btn_get.node, BindTool.Bind1(self.GetReward,self), true)

	local ph = self.ph_list.ph_cell
	if self.cell == nil then
		self.cell = BaseCell.New()
		self.cell:GetView():setPosition(ph.x, ph.y - 5)
		self.view:addChild(self.cell:GetView(), 99)
		self.cell:GetView():setScale(0.88)
	end
end

function RewardListItem:OnFlush( ... )
	if self.data == nil  then
		return
	end
	local text = ""
	if self.data.consume then
		local path = ResPath.GetCommon("gold")
	
		 text = string.format(Language.Bag.ComposeTip, path,"20,20", 1, 0, 0, "00ff00", self.data.consume[1].count)
	end
	RichTextUtil.ParseRichText(self.node_tree.text_consume.node, text)
	XUI.RichTextSetCenter(self.node_tree.text_consume.node)

	local last_level = FubenData.Instance:GetCurFightLevel()
	local last_bo = FubenData.Instance:GetHadTongGuangBo()
	if last_bo == 0 then
		last_bo = 1
	end
	local score =  DungeonData.Instance:GetScore(last_level, last_bo)
	local reward = DungeonData.Instance:GetRewardDataByScoreAndlevel(last_level, score)
	self.cell:SetData({item_id = reward[1].id, num = 1, is_bind = 0})
	self.node_tree.img_level.node:loadTexture(ResPath.GetFubenCL("times".. self.data.times))
	local num = reward[1].count * self.data.times
	self.node_tree.text_num.node:setString("X"..num)
end

function RewardListItem:GetReward()
	FubenCtrl.Instance:SendGetJinYanFuben(self.data.times)
end
