--[[
灵诀 model
haohu
2016年1月22日11:33:33
]]

_G.LingJueModel = Module:new()

LingJueModel.lingJueGroups = {}

function LingJueModel:Init()
	for tid, cfg in pairs(t_lingjueachieve) do
		self:CreateLingJue(tid)
	end
end

function LingJueModel:CreateLingJue(tid)
	local lingJue = LingJue:new(tid)
	local groupId = lingJue:GetGroup()
	local group = self:GetGroup(groupId, true)
	group:AddLingJue(lingJue)
end

function LingJueModel:GetGroup(groupId, create)
	if not self.lingJueGroups[groupId] and create then
		self.lingJueGroups[groupId] = LingJueGroup:new(groupId)
	end
	return self.lingJueGroups[groupId]
end

function LingJueModel:GetLingJue(tid)
	local cfg = t_lingjueachieve[tid]
	if not cfg then return end
	local groupId = cfg.group
	local group = self:GetGroup(groupId)
	return group and group:GetLingJue(tid)
end

function LingJueModel:SetLingJuePro( tid, level, pro )
	local lingJue = self:GetLingJue(tid)
	if lingJue and lingJue:SetPro(pro, level) then
		self:sendNotification( NotifyConsts.LingJuePro )
	end
end

function LingJueModel:GetGroupNum()
	return getTableLen( self.lingJueGroups )
end

function LingJueModel:GetAttrTotal()
	local attrList = {}
	for _, lingJueGroup in pairs(self.lingJueGroups) do
		attrList = LingJueUtils:AttrAdd( attrList, lingJueGroup:GetAttrTotal() )
	end
	return attrList
end

function LingJueModel:GetSortedLingJueGroups()
	local list = {}
	for _, group in pairs(self.lingJueGroups) do
		table.push(list, group)
	end
	table.sort( list, function( A, B )
		return A:GetGroupId() < B:GetGroupId()
	end )
	return list
end