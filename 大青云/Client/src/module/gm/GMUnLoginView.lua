--[[
封停名单
lizhuangzhuang
2015年10月9日15:55:19
]]

_G.UIGMUnLogin = BaseUI:new("UIGMUnLogin");

function UIGMUnLogin:Create()
	self:AddSWF("gmUnLoginPanel.swf",true,nil);
end

function UIGMUnLogin:OnLoaded(objSwf)
	objSwf.btnAdd.click = function() self:OnBtnAddClick(); end
	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end
	objSwf.list.btnClick = function(e) self:OnListBtnClick(e); end
end


function UIGMUnLogin:OnShow()
	self:ShowList();
	GMController:GetGMList(GMConsts.T_UnLogin);
end

function UIGMUnLogin:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = GMModule:GetList(GMConsts.T_UnLogin);
	objSwf.list.dataProvider:cleanUp();
	for i,gmListVO in ipairs(list) do
		objSwf.list.dataProvider:push(gmListVO:GetUIData());
	end
	objSwf.list:invalidateData();
end

function UIGMUnLogin:HandleNotification(name,body)
	if name == NotifyConsts.GMListRefresh then
		if body.type == GMConsts.T_UnLogin then
			self:ShowList();
		end
	end
end

function UIGMUnLogin:ListNotificationInterests()
	return {NotifyConsts.GMListRefresh};
end

function UIGMUnLogin:OnListItemClick(e)
	if not e.item then return; end
	local id = e.item.id;
	if not id then return; end
	if id == "0_0" then return; end
	UIGMRoleOper:Open(id);
end

function UIGMUnLogin:OnListBtnClick(e)
	if not e.item then return; end
	local guildUid = e.item.guildUid;
	if not guildUid then return; end
	if guildUid == "0_0" then return; end
	GMController:GetGMGuildInfo(guildUid)
end

function UIGMUnLogin:OnBtnAddClick()
	if UIGMSearch:IsShow() then
		UIGMSearch:Hide();
	else
		UIGMSearch:Show();
	end
end