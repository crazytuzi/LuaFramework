--[[
禁言名单
lizhuangzhuang
2015年10月9日15:55:01
]]

_G.UIGMUnChat = BaseUI:new("UIGMUnChat");

function UIGMUnChat:Create()
	self:AddSWF("gmUnChatPanel.swf",true,nil);
end

function UIGMUnChat:OnLoaded(objSwf)
	objSwf.btnAdd.click = function() self:OnBtnAddClick(); end
	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end
	objSwf.list.btnClick = function(e) self:OnListBtnClick(e); end
end


function UIGMUnChat:OnShow()
	self:ShowList();
	GMController:GetGMList(GMConsts.T_UnChat);
end

function UIGMUnChat:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = GMModule:GetList(GMConsts.T_UnChat);
	objSwf.list.dataProvider:cleanUp();
	for i,gmListVO in ipairs(list) do
		objSwf.list.dataProvider:push(gmListVO:GetUIData());
	end
	objSwf.list:invalidateData();
end

function UIGMUnChat:HandleNotification(name,body)
	if name == NotifyConsts.GMListRefresh then
		if body.type == GMConsts.T_UnChat then
			self:ShowList();
		end
	end
end

function UIGMUnChat:ListNotificationInterests()
	return {NotifyConsts.GMListRefresh};
end

function UIGMUnChat:OnListItemClick(e)
	if not e.item then return; end
	local id = e.item.id;
	if not id then return; end
	if id == "0_0" then return; end
	UIGMRoleOper:Open(id);
end

function UIGMUnChat:OnListBtnClick(e)
	if not e.item then return; end
	local guildUid = e.item.guildUid;
	if not guildUid then return; end
	if guildUid == "0_0" then return; end
	GMController:GetGMGuildInfo(guildUid)
end

function UIGMUnChat:OnBtnAddClick()
	if UIGMSearch:IsShow() then
		UIGMSearch:Hide();
	else
		UIGMSearch:Show();
	end
end