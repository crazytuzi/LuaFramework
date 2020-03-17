--[[
主界面任务追踪树节点：任务内容
2015年5月11日17:35:25
haohu
]]

_G.QuestNodeContent = QuestNode:new(QuestNodeConst.Node_Content)

-- content = questVO
function QuestNodeContent:SetContent( content )
	self.content = content;
end

function QuestNodeContent:GetLabel()
	local quest = self:GetContent()
	if not quest then return end
	local label = quest:GetContentLabel();
	return string.format("   %s", label); -- 内容节点缩进一个字
end

-- 获取任务类型
function QuestNodeContent:GetQuestType()
	local quest = self:GetContent();
	return quest and quest:GetType()
end

function QuestNodeContent:HasRewardEffect()
	local quest = self:GetContent();
	return quest ~= nil and quest:GetPlayRewardEffect()
end

function QuestNodeContent:OnClick()
	local quest = self:GetContent()
	if not quest then return end
	quest:OnContentClick()
end

function QuestNodeContent:HasTeleportBtn()
	local quest = self:GetContent()
	return quest and quest:CanTeleport()
end

function QuestNodeContent:OnTeleportClick()
	local quest = self:GetContent()
	if not quest then return end
	quest:Teleport()
end

function QuestNodeContent:OnTeleportRollOver()
	MapUtils:ShowTeleportTips()
end

function QuestNodeContent:OnTeleportRollOut()
	TipsManager:Hide();
end
