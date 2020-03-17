--[[
主界面任务追踪树节点：断档推荐
2015年5月12日20:04:15
haohu
]]

_G.QuestNodeRecommend = QuestNode:new( QuestNodeConst.Node_Recommend )

-- content : QuestBreakRecommend

function QuestNodeRecommend:GetLabel()
	local recommend = self:GetContent()
	local label = recommend:GetLabel()
	return string.format( "   %s", label ) -- 内容节点缩进一个字
end

function QuestNodeRecommend:OnClick()
	local recommend = self:GetContent()
	recommend:DoRecommend()
end

function QuestNodeRecommend:OnRollOver()
	local recommend = self:GetContent()
	local tips = recommend:GetTipsTxt() or ""
	TipsManager:ShowBtnTips( tips, TipsConsts.Dir_RightDown )
end

function QuestNodeRecommend:DisposeContent()
	if self.content then
		self.content:Dispose()
		self.content = nil
	end
end


function QuestNodeRecommend:HasTeleportBtn()
	local quest = self:GetContent()
	return quest and quest:CanTeleport()
end

function QuestNodeRecommend:OnTeleportClick()
	local quest = self:GetContent()
	if not quest then return end
	quest:Teleport()
end

function QuestNodeRecommend:OnTeleportRollOver()
	MapUtils:ShowTeleportTips()
end

function QuestNodeRecommend:OnTeleportRollOut()
	TipsManager:Hide();
end
