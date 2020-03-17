--[[
聊天发送者名字
参数格式:type,roleID,roleName,teamId,guildId,guildPos,vip,lvl,icon,cityPos,vflag,isGM,跨服
lizhuangzhuang
2014年9月23日16:36:57
]]

_G.SenderNameChatParam = setmetatable({},{__index=ChatParam});

function SenderNameChatParam:GetType()
	return ChatConsts.ChatParam_SenderName;
end

function SenderNameChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	if not params[2] then return ""; end
	local str = params[2];
	if params[1] == tostring(MainPlayerModel.mainRoleID) then
		str = "<font color='#7df3fe'>" .. str .. "</font>";
	else
		str = "<font color='#52d584'>" .. str .. "</font>";
	end
	--
	if not MainPlayerController.isInterServer then
		local vip = toint(params[6]);
		-- local vipStr = ResUtil:GetVIPIcon(vip);
		local vipStr = VipController:GetSelfVipIcon(vip)
		if vipStr and vipStr~="" then
			str = "<img src='".. vipStr .."'/>" .. str;
		end
	end
	--
	-- local vflag = toint(params[10]);
	-- local vflagStr = ResUtil:GetVIcon(vflag);
	-- if vflagStr and vflagStr~="" then
		-- str = "<img src='".. vflagStr .."'/>" .. str;
	-- end
	--
	local cityPosName = ChatConsts:GetCityPosName(toint(params[9]));
	if cityPosName ~= "" then
		str = "<font color='#ff4633'>[" .. cityPosName .. "]</font>" .. str;
	end
	--
	local isGM = toint(params[11]);
	if isGM == 1 then
		str = "<font color='#ffffff'>[GM]</font>" .. str;
	end
	--
	if params[1] == tostring(MainPlayerModel.mainRoleID) then
		return str;
	else
		if params[12] == "1" then--跨服
			return str;
		else
			return self:GetLinkStr(str,paramStr);
		end
	end
end

function SenderNameChatParam:DoLink(paramStr)
	local params = self:Decode(paramStr);
	if params[12] ~= "1" then
		local chatRoleVO = ChatRoleVO:new();
		chatRoleVO:ParseStr(paramStr);
		UIChatRoleOper:Open(chatRoleVO);
	end
end