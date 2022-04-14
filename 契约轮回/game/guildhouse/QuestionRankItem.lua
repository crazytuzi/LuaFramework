QuestionRankItem = QuestionRankItem or class("QuestionRankItem",BaseCloneItem)
local QuestionRankItem = QuestionRankItem

function QuestionRankItem:ctor(obj,parent_node,layer)
	QuestionRankItem.super.Load(self)
end

function QuestionRankItem:dctor()
end

function QuestionRankItem:LoadCallBack()
	self.nodes = {
		"rank","name","score","rank_img"
	}
	self:GetChildren(self.nodes)
	self.rank = GetText(self.rank)
	self.name = GetText(self.name)
	self.score = GetText(self.score)
	self.rank_img = GetImage(self.rank_img)
	self:AddEvent()

	self:UpdateView()
end

function QuestionRankItem:AddEvent()
end

--data:p_ranking
function QuestionRankItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function QuestionRankItem:UpdateView()
	if self.data then
		if self.data.rank < 4 then
			SetVisible(self.rank, false)
			SetVisible(self.rank_img, true)
			lua_resMgr:SetImageTexture(self,self.rank_img, 'common_image', 'com_rank_' .. self.data.rank, true)
		else
			SetVisible(self.rank, true)
			SetVisible(self.rank_img, false)
			self.rank.text = self.data.rank
		end
		self.name.text = self.data.base.name
		self.score.text = self.data.sort
	end
end