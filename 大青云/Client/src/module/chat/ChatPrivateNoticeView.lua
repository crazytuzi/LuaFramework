--[[
私聊通知界面
lizhuangzhuang
2014年9月25日20:31:12
]]
_G.UIChatPrivateNotice = BaseUI:new("UIChatPrivateNotice");

function UIChatPrivateNotice:Create()
	self:AddSWF("chatPrivateNotice.swf",true,"bottom");
end

function UIChatPrivateNotice:OnLoaded(objSwf)
	objSwf.panel._visible = false;
	objSwf.btnNotice.click = function() self:OnBtnNoticeClick(); end
	objSwf.panel.list.itemClick = function(e) self:OnItemClick(e); end
	objSwf.panel.list.itemClose = function(e) self:OnItemClose(e); end
	objSwf.panel.btnIgnore.click = function() self:OnBtnIgnoreClick(); end
end

function UIChatPrivateNotice:GetWidth()
	return 79;
end

function UIChatPrivateNotice:GetHeight()
	return 79;
end

function UIChatPrivateNotice:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.panel._visible = false;
end

--显示列表
function UIChatPrivateNotice:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not objSwf.panel._visible then return; end
	local list = ChatModel.privateNoticeList;
	if #list <= 0 then
		self:Hide();
		return;
	end
	local len = 0;
	objSwf.panel.list.selectedIndex = -1; 
	objSwf.panel.list.dataProvider:cleanUp();
	for i,vo in ipairs(list) do
		if i> 10 then break; end
		objSwf.panel.list.dataProvider:push(UIData.encode(vo));
		len = len + 1;
	end
	objSwf.panel.list:invalidateData();
	objSwf.panel.list.height = 35*len;
	objSwf.panel.bg._height = 35*len + 100; 
	objSwf.panel.btnIgnore._y = objSwf.panel.bg._height - 40;
	objSwf.panel._y = 20 - objSwf.panel.bg._height;
end

function UIChatPrivateNotice:OnBtnNoticeClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.panel._visible = not objSwf.panel._visible;
	self:ShowList();
end

--点击item
function UIChatPrivateNotice:OnItemClick(e)
	ChatController:OpenPrivateChat(e.item.roleId,e.item.roleName,e.item.icon,e.item.lvl,e.item.vipLvl)
end

--关闭item
function UIChatPrivateNotice:OnItemClose(e)
	ChatController:RemovePrivateChatNotice(e.item.roleId);
end

--点击忽略全部
function UIChatPrivateNotice:OnBtnIgnoreClick()
	ChatController:ClearPrivateChatNotice();
end

function UIChatPrivateNotice:HandleNotification(name,body)
	if not self.bShowState then return;end
	local objSwf = self.objSwf;
	if not objSwf then return;end
	if name == NotifyConsts.StageClick then
		local panelTarget = string.gsub(objSwf._target,"/",".");
		if string.find(body.target,panelTarget) then
			return;
		end
		objSwf.panel._visible = false;
	elseif name == NotifyConsts.StageFocusOut then
		objSwf.panel._visible = false;
	elseif name == NotifyConsts.ChatPrivateNotice then
		local list = ChatModel.privateNoticeList;
		if #list <= 0 then
			self:Hide();
			return;
		end
		self:ShowList();
	end
end

function UIChatPrivateNotice:ListNotificationInterests()
	return {NotifyConsts.StageClick,NotifyConsts.StageFocusOut,NotifyConsts.ChatPrivateNotice};
end