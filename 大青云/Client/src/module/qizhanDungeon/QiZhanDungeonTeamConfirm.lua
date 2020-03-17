--[[
	2015年11月15日16:19:00
	wangyanwei
	骑战队伍确认框
]]

_G.UIQiZhanDungeonTeamConfirm = BaseUI:new('UIQiZhanDungeonTeamConfirm');

function UIQiZhanDungeonTeamConfirm:Create()
	self:AddSWF('qizhanDungeonConfirm.swf',true,'top');
end

function UIQiZhanDungeonTeamConfirm:OnLoaded(objSwf)
	--选择结果 0同意 1拒绝 2关闭(所有人权限)
	objSwf.btn_close.click = function () QiZhanDungeonController:SendQiZhanDungeonTeamState(2);self:Hide(); end
	objSwf.btn_cancel.click = function () QiZhanDungeonController:SendQiZhanDungeonTeamState(1); end
	objSwf.btn_enter.click = function () QiZhanDungeonController:SendQiZhanDungeonTeamState(0); end
end

function UIQiZhanDungeonTeamConfirm:OnShow()
	
end

function UIQiZhanDungeonTeamConfirm:OnHide()
	
end

function UIQiZhanDungeonTeamConfirm:Open()
	if self:IsShow() then
		self:Show();
	else
		self:OnShow();
	end
end

function UIQiZhanDungeonTeamConfirm:ShowTeamListState()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.list.dataProvider:cleanUp();
	local teamList = QiZhanDungeonUtil:GetSelfTeamPlayerData();
end