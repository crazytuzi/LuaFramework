--[[
帮派:帮派列表面板
liyuan
2014年11月20日16:22:09
]]


_G.UIUnionList = UIUnionListBase:new("UIUnionList")

function UIUnionList:Create()
	self:AddSWF("unionListPanel.swf", true, nil);
end

function UIUnionList:OnShow(name)
	self:GetCurrentPage()
	
	self:OnLevelUp()
	local objSwf = self.objSwf
	if not objSwf then return end
	-- self.objSwf.btnCreate.disabled = true
end

-- 获得当前页数据 更新帮派列表
function UIUnionList:ShowUnionList(guildList, pages)
	local objSwf = self.objSwf
	if not objSwf then return end

	if not guildList then return end

	objSwf.listUnion.dataProvider:cleanUp() 
	for i, guildVO in pairs(guildList) do
		local extendNum = guildVO.extendNum or 0
		guildVO.maxMemCnt = UnionUtils:GetUnionMemMaxNum(guildVO.level) + extendNum
		guildVO.viewOnly = 1
		-- guildVO.isGM = GMModule:IsGM();
		guildVO.isGM = true;
		objSwf.listUnion.dataProvider:push( UIData.encode(guildVO) )
	end
	objSwf.listUnion:invalidateData()
	
	self:UpdatePageBtnState(pages)
end

