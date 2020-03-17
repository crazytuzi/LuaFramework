
_G.GMModule = Module:new();

--是否GM
GMModule.isGM = false;
--是否GM称号
GMModule.isUseGmTitle = false;
--是否接收聊天
GMModule.isChat = false;

GMModule.listMap = {};

GMModule.chatList = {};

function GMModule:SetGMInfo(isGM,isUseGmTitle,isChat)
	self.isGM = isGM;
	self.isUseGmTitle = isUseGmTitle;
	self.isChat = isChat;
end

function GMModule:IsGM()
	return self.isGM;
end

function GMModule:IsGMTitle()
	return self.isUseGmTitle;
end

function GMModule:IsChat()
	return self.isChat;
end

function GMModule:SetList(type,datalist)
	local list = {};
	for i,data in ipairs(datalist) do
		local vo = GMListVO:new(data,type);
		table.push(list,vo);
	end
	self.listMap[type] = list;
	self:sendNotification(NotifyConsts.GMListRefresh,{type=type});
end

function GMModule:GetList(type)
	if not self.listMap[type] then
		return {};
	end
	return self.listMap[type];
end

function GMModule:AddChat(chatVO)
	while #self.chatList >= GMConsts.MaxChat do
		table.remove(self.chatList,1);
	end
	table.push(self.chatList,chatVO);
	self:sendNotification(NotifyConsts.GMChatRefresh,{channel=chatVO.channel});
end

function GMModule:ClearChat()
	self.chatList = {};
end
