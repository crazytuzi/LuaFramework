--[[
私聊最小化面板
lizhuangzhuang
2014年9月26日18:01:51
]]

_G.UIChatPrivateMin = BaseUI:new("UIChatPrivateMin");


UIChatPrivateMin.role = 0;
UIChatPrivateMin.roleName = "";
UIChatPrivateMin.icon = 0;
UIChatPrivateMin.lvl = 0;
UIChatPrivateMin.vipLvl = 0;

function UIChatPrivateMin:Create()
	self:AddSWF("chatPrivateMin.swf",true,"bottom");
end

function UIChatPrivateMin:OnLoaded(objSwf,name)
	objSwf.btnNotice.visible = false;
	objSwf.btnNormal.click = function() self:OnBtnClick(); end
	objSwf.btnNotice.click = function() self:OnBtnClick(); end
end

function UIChatPrivateMin:OnShow()
	self:SetName();
	self:CheckNewMsg();
end

function UIChatPrivateMin:SetName()
	local objSwf = self:GetSWF("UIChatPrivateMin");
	if not objSwf then return; end
	--取玩家名
	local name = self.roleName;
	if string.getLen(name) <= 8 then
		name = string.format(StrConfig['chat306'],name);
		objSwf.btnNormal.label = name;
		objSwf.btnNotice.label = name;
		return;
	end
	local i = 1;
    local len = 0;
    local strLen = name:len()
	while i <= strLen do
        local v = string.byte(name, i, i)
        if type(v) == "number" then
            if v >= 128 then
                i = i + 3
                len = len + 2
            else
                i = i + 1
                len = len + 1
            end
        end
		if len >= 4 then
			name = string.sub(name,1,i-1);
			name = name .. "...";
			break;
		end
	end
	name = string.format(StrConfig['chat306'],name);
	objSwf.btnNormal.label = name;
	objSwf.btnNotice.label = name;
end

--检查是否有新消息
function UIChatPrivateMin:CheckNewMsg()
	local objSwf = self:GetSWF("UIChatPrivateMin");
	if not objSwf then return; end
	local newMsg = false;
	for i,vo in pairs(ChatModel.privateChatList) do
		if ChatModel:GetHasPrivateNotice(vo.roleId) then
			newMsg = true;
			break;
		end
	end
	objSwf.btnNotice.visible = newMsg;
	objSwf.btnNormal.visible = not newMsg;
end

function UIChatPrivateMin:Open(roleId,roleName,icon,lvl,vipLvl)
	self.roleId = roleId;
	self.roleName = roleName;
	self.icon = icon;
	self.lvl = lvl;
	self.vipLvl = vipLvl;
	self:Show();
end

function UIChatPrivateMin:OnBtnClick()
	ChatController:OpenPrivateChat(self.roleId,self.roleName,self.icon,self.lvl,self.vipLvl);
	self:Hide();
end


function UIChatPrivateMin:HandleNotification(name,body)
	if not self.bShowState then return;end
	local objSwf = self:GetSWF("UIChatPrivateMin");
	if not objSwf then return;end
	if name == NotifyConsts.ChatPrivateNotice then
		self:CheckNewMsg();
	end
end

function UIChatPrivateMin:ListNotificationInterests()
	return {NotifyConsts.ChatPrivateNotice};
end