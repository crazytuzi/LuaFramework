
WebView.WebViewMgrC = luanet.import_type("WebViewManager");

WebView.tbClass     = WebView.tbClass or {};
WebView.tbClassBase = WebView.tbClassBase or {};

local tbBase = WebView.tbClassBase;
function tbBase:OnReceivedMessage(szMsg)
end

function tbBase:OnLoadComplete(bSuccess, szError)
end

function tbBase:OnWebViewShouldClose()
end

function tbBase:OnEvalJavaScriptFinished(szResult)
end

function tbBase:OnHttpRequestData(szMsg, szError)
end

function WebView:GetClass(szClass)
    local tbClass  = self.tbClass[szClass];
    if not tbClass then
        tbClass = Lib:NewClass(self.tbClassBase);
        self.tbClass[szClass]   = tbClass;
        tbClass.szClassName = szClass;
    end

    return tbClass;
end

function WebView:OnReceivedMessage(szClass, szMsg)
    local tbClass = self:GetClass(szClass);
    if not tbClass then
        return;
    end

    tbClass:OnReceivedMessage(szMsg);   
end

function WebView:OnLoadComplete(szClass, bSuccess, szError)
    local tbClass = self:GetClass(szClass);
    if not tbClass then
        return;
    end

    tbClass:OnLoadComplete(bSuccess, szError);
    if bSuccess then
        Ui:OpenWindow("BgBlackAll");
        Ui.CameraMgr.SetMainCameraActive(false);
    end
    Log("OnLoadComplete", szClass, (bSuccess and "True" or "False"), szError or "");   
end

function WebView:OnWebViewShouldClose(szClass)        
    local tbClass = self:GetClass(szClass);
    if not tbClass then
        return;
    end

    tbClass:OnWebViewShouldClose();
    Ui:CloseWindow("BgBlackAll");
    Ui.CameraMgr.SetMainCameraActive(true);
    Log("OnWebViewShouldClose", szClass);   
end

function WebView:OnEvalJavaScriptFinished(szClass, szResult)
    local tbClass = self:GetClass(szClass);
    if not tbClass then
        return;
    end

    tbClass:OnEvalJavaScriptFinished(szResult);
end

function WebView:OnHttpRequestData(szClass, szMsg, szError)
    local tbClass = self:GetClass(szClass);
    if not tbClass then
        return;
    end

    tbClass:OnHttpRequestData(szMsg, szError);   
end

function WebView:OpenUrl(szClass, szUrl, tbCurEdgeInsets)
    local tbClass = self:GetClass(szClass);
    if not tbClass then
        return;
    end
    
    tbClass.szOpenUrl = szUrl;
    local tbEdgeInsets = tbCurEdgeInsets;
    if not tbEdgeInsets then
        tbEdgeInsets = {0, 0, 0, 0};
    end    

    self.WebViewMgrC.LoadUrl(szClass, szUrl, tbEdgeInsets[1], tbEdgeInsets[2], tbEdgeInsets[3], tbEdgeInsets[4]);
    Log("WebView OpenUrl", szClass, szUrl, tbEdgeInsets[1], tbEdgeInsets[2], tbEdgeInsets[3], tbEdgeInsets[4]);
end

function WebView:Close(szClass)
    self:OnWebViewShouldClose(szClass)
    self.WebViewMgrC.Close();
    Log("WebView Close");
end

function WebView:EvaluatingJavaScript(szJavaScript)
    self.WebViewMgrC.EvaluatingJavaScript(szJavaScript);    
end  

function WebView:AddUrlScheme(szUrlScheme)
    self.WebViewMgrC.AddUrlScheme(szUrlScheme);
end

function WebView:HttpRequestData(szClass, szUrl)
    self.WebViewMgrC.HttpRequestData(szClass, szUrl);
end 