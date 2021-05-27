SupplyContentionScoreView = SupplyContentionScoreView or BaseClass(XuiBaseView)

function SupplyContentionScoreView:__init()
	self.config_tab = {
		-- {"common_ui_cfg", 1, {0}},
		{"supply_contention_score_ui_cfg", 1, {0}},
		-- {"common_ui_cfg", 2, {0}},
	}
	self.cells_score_list = {}
end

function SupplyContentionScoreView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then

		XUI.AddClickEventListener(self.node_t_list.closeBtn.node,BindTool.Bind(self.OnClickBtn,self),true)
	end
end

function SupplyContentionScoreView:OpenCallBack()
	SupplyContentionScoreCtrl.Instance:SendDeleteMailReq()
end


function SupplyContentionScoreView:OnFlush(param_t, index)
	local dataInfo = SupplyContentionData.Instance:GetRankData()
	self:UpdateRankList(dataInfo.ranking_list)

	self.node_t_list.text_myRankNum.node:setString(dataInfo.my_rank)
	self.node_t_list.text_myRoleName.node:setString(Language.SupplyContentionAward.Desc_3)
	self.node_t_list.text_myKillNum.node:setString(dataInfo.my_kill.."/"..dataInfo.my_die)
	self.node_t_list.text_myFoodNum.node:setString(dataInfo.my_transport)
	self.node_t_list.text_myScoreNum.node:setString(dataInfo.my_score)
end


function SupplyContentionScoreView:UpdateRankList(arr)
	if nil == self.rank_item_list then
		local ph = self.ph_list.rank_list
		self.rank_item_list = ListView.New()
		self.rank_item_list:Create(ph.x, ph.y, ph.w, ph.h, nil, SupplyContentionScoreRender, nil, nil, self.ph_list.rank_item)
		self.rank_item_list:GetView():setAnchorPoint(0, 0)
		self.rank_item_list:SetItemsInterval(5)
		self.rank_item_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_info.node:addChild(self.rank_item_list:GetView(), 100)
	end
	self.rank_item_list:SetDataList(arr or {})
end

function SupplyContentionScoreView:OnClickBtn()
	self:Close()
end


function SupplyContentionScoreView:__delete()
end

function SupplyContentionScoreView:ReleaseCallBack()
	if self.rank_item_list then
		self.rank_item_list:DeleteMe()
		self.rank_item_list = nil
	end
end






SupplyContentionScoreRender = SupplyContentionScoreRender or BaseClass(BaseRender)
function SupplyContentionScoreRender:__init()
	
end


function SupplyContentionScoreRender:OnFlush()
	if self.data == nil then return end
	local index = self:GetIndex()
	self.node_tree.text_rankNum.node:setString(index)
	self.node_tree.text_roleName.node:setString(self.data.roleName)
	self.node_tree.text_killNum.node:setString(self.data.kill.."/"..self.data.die)
	self.node_tree.text_foodNum.node:setString(self.data.transport)
	self.node_tree.text_scoreNum.node:setString(self.data.score)

	local c
	if index == 1 then
		c = cc.c3b(255,255,0);
	elseif index == 2 then
		c = cc.c3b(204,0,255);
	elseif index == 3 then
		c = cc.c3b(0,204,255);
	else
		c = cc.c3b(31,115,69);
	end

	self.node_tree.text_rankNum.node:setColor(c)
	self.node_tree.text_roleName.node:setColor(c)
	self.node_tree.text_killNum.node:setColor(c)
	self.node_tree.text_foodNum.node:setColor(c)
	self.node_tree.text_scoreNum.node:setColor(c) 	
end