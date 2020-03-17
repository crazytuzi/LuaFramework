--[[
私聊VO
lizhuangzhuang
2014年9月29日11:27:56
]]
_G.classlist['ChatPrivateVO'] = 'ChatPrivateVO'
_G.ChatPrivateVO = setmetatable({},{__index=ChatVO});
ChatPrivateVO.objName = 'ChatPrivateVO'
function ChatPrivateVO:SetText(text)
	local str = "";
	local nameColor = "";
	if self.senderVO:GetID() == MainPlayerModel.mainRoleID then
		nameColor = "#b3ce1d";
	else
		nameColor = "#428fe0";
	end
	str = "<font color='"..nameColor.."'>" .. self.senderVO:GetName()
	str = str .."\t" .. CTimeFormat:todate(self.sendTime);
	str = str .."</font>";
	str = str .. "<br/>";
	str = str .. "<font color='"..ChatConsts.Color_Private.."'>" ..text.."</font>";
	self.text = str;
end
