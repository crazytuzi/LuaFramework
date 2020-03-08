Require("Script/WebView/WebView.lua");

local tbWebView = WebView:GetClass("Normal");

function tbWebView:OpenUrl(szUrl)
	WebView:OpenUrl("Normal", szUrl);
end

