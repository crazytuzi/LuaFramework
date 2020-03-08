Require("Script/WebView/WebView.lua");

local tbWebView = WebView:GetClass("TestWeb");
function tbWebView:OnReceivedMessage(szMsg)
    Log("OnReceivedMessage:"..szMsg);
end

function tbWebView:OnLoadComplete(bSuccess, szError)
    Log("OnLoadComplete:".. (bSuccess and "True" or "False") ..(szError or ""));
end

function tbWebView:OnWebViewShouldClose()
    Log("OnWebViewShouldClose");
end

function tbWebView:OnEvalJavaScriptFinished(szResult)
    Log("OnEvalJavaScriptFinished:"..szResult);
end
