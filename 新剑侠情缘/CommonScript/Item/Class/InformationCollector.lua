local tbItem = Item:GetClass("InformationCollector");

function tbItem:GetUseSetting(nTemplateId, nItemId)
	local tbUserSet = {};
	local fnOpenWeb = function ()
		local szUrl = "http://www.jxqy.org";
		Sdk:OpenUrl(szUrl);
	end

	tbUserSet.szFirstName = "使用"
	tbUserSet.fnFirst = fnOpenWeb;
	return tbUserSet;
end