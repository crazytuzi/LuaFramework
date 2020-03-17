--[[
帮派副本：地宫炼狱每周提醒
2015年11月6日18:06:59
haohu
]]

_G.UIUnionHellNotice = BaseUI:new("UIUnionHellNotice")

function UIUnionHellNotice:Create()
	self:AddSWF("unionHellNotice.swf", true, "center")
end

function UIUnionHellNotice:OnLoaded( objSwf)
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick() end
	objSwf.btnClose.click = function() self:Hide() end
end

function UIUnionHellNotice:OnShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.tfContent.htmlText = StrConfig['unionhell201']
	objSwf.btnConfirm.label = StrConfig['unionhell202']
end

function UIUnionHellNotice:OnBtnConfirmClick()
	self:OpenUnionHell()
	self:Hide()
end

function UIUnionHellNotice:OpenUnionHell()
	if not FuncManager:GetFuncIsOpen(FuncConsts.Guild) then
		local tips = FuncManager:GetFuncUnOpenTips(FuncConsts.Guild);
		if tips ~= "" then
			FloatManager:AddNormal(tips);
		end
		return;
	end

	if not UnionUtils:CheckMyUnion() then
		FloatManager:AddNormal(StrConfig['unionhell203']);
		return;
	end

	if not UnionDungeonUtils:GetUnionDungeonIsOpen( UnionDungeonConsts.ID_Hell ) then
		FloatManager:AddNormal(StrConfig['unionhell204']);
		return
	end
	UIUnion:SetFirstTab( UnionConsts.TabUnionDungeon )
	UIUnionDungeonMain:SetFirstPanel( UnionDungeonConsts.TabHell );
	local stratum = UnionDungeonHellModel:GetCurrentStratum();
	UIUnionDungeonHell:SetFirstShowStratum( stratum );
	UIUnionDungeonHell.willTweenNext = false;
	UIUnion:Show();
end