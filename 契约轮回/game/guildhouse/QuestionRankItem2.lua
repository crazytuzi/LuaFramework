QuestionRankItem2 = QuestionRankItem2 or class("QuestionRankItem2",BaseCloneItem)
local QuestionRankItem2 = QuestionRankItem2

function QuestionRankItem2:ctor(obj,parent_node,layer)
	QuestionRankItem2.super.Load(self)
end

function QuestionRankItem2:dctor()
	for i=1, #self.item_list do
		self.item_list[i]:destroy()
	end
	self.item_list = nil
end

function QuestionRankItem2:LoadCallBack()
	self.nodes = {
		"bg","bg2","rank_img", "rank",
		"Content",
	}
	self:GetChildren(self.nodes)
	self.rank_img = GetImage(self.rank_img)
	self.rank = GetText(self.rank)
	--self.name = GetText(self.name)
	--self.guild = GetText(self.guild)
	self.model = GuildHouseModel:GetInstance()
	self.item_list = {}
	self:AddEvent()
end

function QuestionRankItem2:AddEvent()
end

--data:db_guild_question_reward
function QuestionRankItem2:SetData(data, index)
	self.data = data
	self.index = index
	if self.is_loaded then
		self:UpdateView()
	end
end

function QuestionRankItem2:UpdateView()
	if self.data then
		local min = self.data.rank_min
		local max = self.data.rank_max
		local rank = (min == max and min or string.format("%s-%s", min, max))
		if type(rank) == "number" and rank < 4 then
			SetVisible(self.rank, false)
			SetVisible(self.rank_img, true)
			lua_resMgr:SetImageTexture(self,self.rank_img, 'common_image', 'com_rank_' .. rank, true)
		else
			SetVisible(self.rank, true)
			SetVisible(self.rank_img, false)
			self.rank.text = rank
		end
		if self.index % 2 == 0 then
			SetVisible(self.bg, false)
			SetVisible(self.bg2, true)
		else
			SetVisible(self.bg, true)
			SetVisible(self.bg2, false)
		end
		local rewards = String2Table(self.data.gain)
		for i=1, #rewards do
			local reward = rewards[i]
			local item = GoodsIconSettorTwo(self.Content)
			local param = {
				item_id = reward[1],
				num = reward[2],
				can_click = true,
			}
			item:SetIcon(param)
			self.item_list[#self.item_list+1] = item
		end
	end
end