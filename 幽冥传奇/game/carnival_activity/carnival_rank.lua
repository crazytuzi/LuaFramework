CarnivalRankView = CarnivalRankView or BaseClass(XuiBaseView)

function CarnivalRankView:__init()
	self.config_tab = {
		-- {"common_ui_cfg", 1, {0}},
		{"carnival_ui_cfg", 7, {0}},
		-- {"common_ui_cfg", 2, {0}},
	}
	self:SetIsAnyClickClose(true)
	-- self.texture_path_list = {"res/xui/hero_gold.png",}
	self:SetModal(true)
	-- self.title_img_path = ResPath.GetHeroGold("change_job_title")
end

function CarnivalRankView:__delete()
end

function CarnivalRankView:ReleaseCallBack()
	if self.job_list then
		self.job_list:DeleteMe()
		self.job_list = nil
	end
end

function CarnivalRankView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:JobReceiveList()
	end
end

function CarnivalRankView:JobReceiveList()
	if nil == self.job_list then
		self.job_list = ListView.New()
		local ph = self.ph_list.ph_gift_list
		self.job_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, CarnivalRankRender, gravity, is_bounce, self.ph_list.ph_lis_rank)
		self.job_list:SetItemsInterval(1)
		self.job_list:SetJumpDirection(ListView.Top)
		self.node_t_list.page11.node:addChild(self.job_list:GetView(), 100)		
	end
end
 
function CarnivalRankView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CarnivalRankView:CloseCallBack(is_all)
	
end

function CarnivalRankView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "type" then
			local temp,my_rank = CarnivalData.Instance:getRankData(v.type)
			if my_rank > 0 then				
				self.node_t_list.txt_myrank.node:setString(string.format(Language.OpenServiceAcitivity.RaceMyRank[2],my_rank))
			else
				self.node_t_list.txt_myrank.node:setString(Language.OpenServiceAcitivity.RaceMyRank[1])
			end
			if temp then
				self.job_list:SetDataList(temp)
			end
		end
	end
end

CarnivalRankRender = CarnivalRankRender or BaseClass(BaseRender)
function CarnivalRankRender:__init()
end

function CarnivalRankRender:__delete()

end

function CarnivalRankRender:CreateChild()
	BaseRender.CreateChild(self)
end

function CarnivalRankRender:OnFlush()
	if self.data == nil then return end
	self.node_tree.txt_rank.node:setString(self.data.rank)
	self.node_tree.txt_name.node:setString(self.data.name) 
end
