--[[
竞技场跳过按钮
2015年12月14日19:14
]]

_G.UIArenaSkip = BaseUI:new("UIArenaSkip")

function UIArenaSkip:Create()
	self:AddSWF("arenaSkip.swf", true, "story")
end

function UIArenaSkip:OnLoaded( objSwf )
	objSwf.btnSkip.click = function() self:OnSkipClick() end
end

function UIArenaSkip:OnSkipClick()
	ArenaBattle:SetResult()
end