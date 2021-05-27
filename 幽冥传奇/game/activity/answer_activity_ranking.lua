AnswerActivityRankingView = AnswerActivityRankingView or BaseClass(XuiBaseView)

function AnswerActivityRankingView:__init()
	self.config_tab = {
		{"welkin_ui_cfg", 4, {0}},
	}
	
end

function AnswerActivityRankingView:__delete()

end

function AnswerActivityRankingView:ReleaseCallBack()
	if self.answer_ranking_list then
		self.answer_ranking_list:DeleteMe()
		self.answer_ranking_list = nil 
	end
	-- if self.rankling_envent then
	-- 	GlobalEventSystem:UnBind(self.rankling_envent)
	-- 	self.rankling_envent = nil
	-- end
end

function AnswerActivityRankingView:LoadCallBack(index, loaded_times)	
	if loaded_times <= 1 then
		self:CreateRankingView()
		--self.rankling_envent = GlobalEventSystem:Bind(AllDayActivityEvent.ANSWER_RANKING_DATA, BindTool.Bind(self.SetRankingData,self))
	end
end

function AnswerActivityRankingView:CreateRankingView()
	if self.answer_ranking_list == nil then
		local ph = self.ph_list.ph_answer_list
		self.answer_ranking_list = ListView.New()
		self.answer_ranking_list:Create(ph.x, ph.y, ph.w, ph.h, nil, AnswerActivityRankingRender, nil, nil, self.ph_list.ph_answer_item)
		self.answer_ranking_list:GetView():setAnchorPoint(0, 0)
		self.answer_ranking_list:SetItemsInterval(5)
		self.answer_ranking_list:SetJumpDirection(ListView.Top)
		self.answer_ranking_list:SetMargin(3)
		self.node_t_list.layout_answer_ranking.node:addChild(self.answer_ranking_list:GetView(), 100)
	end
end

function AnswerActivityRankingView:SetRankingData(data)
	if self.answer_ranking_list then
		self.answer_ranking_list:SetDataList(data)
	end
end

function AnswerActivityRankingView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function AnswerActivityRankingView:ShowIndexCallBack(index)
	self:Flush(index)
end

function AnswerActivityRankingView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--刷新界面
function AnswerActivityRankingView:OnFlush(param_t, index)
	
end

AnswerActivityRankingRender = AnswerActivityRankingRender or BaseClass(BaseRender)

function AnswerActivityRankingRender:__init()
end

function AnswerActivityRankingRender:__delete()
	
end

function AnswerActivityRankingRender:CreateChild()
	BaseRender.CreateChild(self)
	
end

function AnswerActivityRankingRender:OnFlush()
	if self.data == nil then return end
	self.node_tree.txt_jifen.node:setString(self.data.score)
	self.node_tree.txt_name.node:setString(self.data.player_name)
end