--[[
·âÍ£MAC
lizhuangzhuang
2015Äê10ÔÂ9ÈÕ15:55:33
]]

_G.UIGMUnMac = BaseUI:new("UIGMUnMac");

function UIGMUnMac:Create()
	self:AddSWF("gmUnMacPanel.swf",true,nil);
end

function UIGMUnMac:OnLoaded(objSwf)
	objSwf.btnAdd.click = function() self:OnBtnAddClick(); end
	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end
	objSwf.list.btnClick = function(e) self:OnListBtnClick(e); end
end


function UIGMUnMac:OnShow()
	self:ShowList();
	GMController:GetGMList(GMConsts.T_UnMac);
end

function UIGMUnMac:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = GMModule:GetList(GMConsts.T_UnMac);
	objSwf.list.dataProvider:cleanUp();
	for i,gmListVO in ipairs(list) do
		objSwf.list.dataProvider:push(gmListVO:GetUIData());
	end
	objSwf.list:invalidateData();
end

function UIGMUnMac:HandleNotification(name,body)
	if name == NotifyConsts.GMListRefresh then
		if body.type == GMConsts.T_UnMac then
			self:ShowList();
		end
	end
end

function UIGMUnMac:ListNotificationInterests()
	return {NotifyConsts.GMListRefresh};
end

function UIGMUnMac:OnListItemClick(e)
	if not e.item then return; end
	local id = e.item.id;
	if not id then return; end
	if id == "0_0" then return; end
	UIGMRoleOper:Open(id);
end

function UIGMUnMac:OnListBtnClick(e)
	if not e.item then return; end
	local guildUid = e.item.guildUid;
	if not guildUid then return; end
	if guildUid == "0_0" then return; end
	GMController:GetGMGuildInfo(guildUid)
end

function UIGMUnMac:OnBtnAddClick()
	if UIGMSearch:IsShow() then
		UIGMSearch:Hide();
	else
		UIGMSearch:Show();
	end
end