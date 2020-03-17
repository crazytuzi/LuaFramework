--[[
	2016年1月8日15:15:51
	wangyanwei
	挑战副本队伍确认框
]]

_G.UIDekaronDungeonTeamConfirm = BaseUI:new('UIDekaronDungeonTeamConfirm');

function UIDekaronDungeonTeamConfirm:Create()
	self:AddSWF('dekaronDungeonConfirm.swf',true,'top');
end

function UIDekaronDungeonTeamConfirm:OnLoaded(objSwf)
	--选择结果 0同意 1拒绝 2关闭(所有人权限)
	objSwf.btn_close.click = function () DekaronDungeonController:SendDekaronDungeonTeamState(2);self:Hide(); end
	objSwf.btn_cancel.click = function () DekaronDungeonController:SendDekaronDungeonTeamState(1); end
	objSwf.btn_enter.click = function () DekaronDungeonController:SendDekaronDungeonTeamState(0); end
end

function UIDekaronDungeonTeamConfirm:OnShow()
	
end

function UIDekaronDungeonTeamConfirm:OnHide()
	
end

function UIDekaronDungeonTeamConfirm:Open()
	if self:IsShow() then
		self:Show();
	else
		self:OnShow();
	end
end

function UIDekaronDungeonTeamConfirm:ShowTeamListState()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.list.dataProvider:cleanUp();
	local teamList = DekaronDungeonUtil:GetSelfTeamPlayerData();
end