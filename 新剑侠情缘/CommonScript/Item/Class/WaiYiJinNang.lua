local tbItem = Item:GetClass("WaiYiJinNang");

function tbItem:GetUseSetting(nTemplateId, nItemId)
	local tbUserSet = {};
	local fnOpenWeb = function ()
		local szUrl = "http://www.jxqy.org";
		local tbMyInfo = FriendShip:GetMyPlatInfo();
		local szFinalUrl = string.format(szUrl,tostring(me.dwID),tostring(Sdk:GetLoginPlatId()),tostring(Sdk:GetUid()),tostring(Sdk:GetAreaId()),tostring(Sdk:GetServerId()),Lib:UrlEncode(tbMyInfo.szNickName or me.szName));
		Sdk:OpenUrl(szFinalUrl);
	end

	tbUserSet.szFirstName = "使用"
	tbUserSet.fnFirst = fnOpenWeb;
	return tbUserSet;
end

