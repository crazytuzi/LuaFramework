Require("Script/WebView/WebView.lua");

local tbWebView = WebView:GetClass("LunTan");
tbWebView.szLuanTanUrl = "http://iu.qq.com/jxqy/mobile/index.html";
function tbWebView:OpenUrlLunTan(szParam)
    if not (Sdk:IsLoginByQQ() or Sdk:IsLoginByWeixin()) then
        return
    end

    local pNpc = me.GetNpc();
    if not pNpc then
        return;
    end

    szParam = szParam or ""

    local szAccountType = "qq"
    if Sdk:IsLoginByWeixin() then
        szAccountType = "wx"
    end

    local msdkInfo = Sdk:GetMsdkInfo()
    local szAppid = Sdk:GetCurAppId();
    local szOpenID = msdkInfo.szOpenId;
    local szAccessToken = msdkInfo.szOpenKey;
    local szPlatid = tostring(Sdk:GetPlatId());
    local szAreaid = tostring(Sdk:GetAreaId());
    local szRoleID = tostring(me.dwID);
    local szWidth  = tostring(Ui.ToolFunction.GetSreenWidth());
    local szHeight = tostring(Ui.ToolFunction.GetSreenHeight());
    local szPartition = tostring(Sdk:GetServerId());
    if Player.nServerIdentity ~= nil then
        szPartition = tostring(Player.nServerIdentity);
    end    
    local szUrl = "";
    if IOS then
        szUrl = string.format("%s?appid=%s&openid=%s&access_token=%s&acctype=%s&platid=%s&areaid=%s&roleid=%s&partition=%s", 
        self.szLuanTanUrl, szAppid, szOpenID, szAccessToken, szAccountType, szPlatid, szAreaid, szRoleID, szPartition);
    else
        szUrl = string.format("%s?appid=%s&openid=%s&access_token=%s&acctype=%s&platid=%s&areaid=%s&roleid=%s&width=%s&height=%s&partition=%s", 
        self.szLuanTanUrl, szAppid, szOpenID, szAccessToken, szAccountType, szPlatid, szAreaid, szRoleID, szWidth, szHeight, szPartition);
    end    

    WebView:OpenUrl("LunTan", szUrl ..szParam);
    WebView:AddUrlScheme("Native");
    WebView:AddUrlScheme("native");
end

function tbWebView:StartOpenUrl()
    if not (Sdk:IsLoginByQQ() or Sdk:IsLoginByWeixin()) then
        return
    end

    local pNpc = me.GetNpc();
    if not pNpc then
        return;
    end

    self:OpenUrlLunTan();    

    -- local msdkInfo = Sdk:GetMsdkInfo()
    -- local szOpenID = msdkInfo.szOpenId;
    -- local szAreaid = tostring(Sdk:GetAreaId());
    -- local szPlatid = tostring(Sdk:GetPlatId());
    -- local szPartition = tostring(Sdk:GetServerId());
    -- local szHttpRequest = string.format("http://apps.game.qq.com/gts/gtp3.0/customize/jxqy/gray.php?openid=%s&sArea=%s&platId=%s&sPartition=%s", 
    --     szOpenID, szAreaid, szPlatid, szPartition);
    -- WebView:HttpRequestData("LunTan", szHttpRequest);
end

function tbWebView:CheckOpenNewUrl(szMsg)
    if Lib:IsEmptyStr(szMsg) then
        return false;
    end

    local nStart, nEnd = string.find(szMsg, "false");
    if nStart and nEnd then
        return false;
    end

    return true;   
end

function tbWebView:OnHttpRequestData(szMsg, szError)
    local bRet = self:CheckOpenNewUrl(szMsg)
    if bRet then
        self:OpenUrlLunTan();
    else
        local szUrl = "http://jxqy.gamebbs.qq.com";
        Sdk:OpenUrl(szUrl);
    end

    Log("WebView OnHttpRequestData", szMsg or "", szError or "");
end

tbWebView.tbAnalyzeMsgStr =
{
    "Native://Order=(.+)&VarName=(.+)",
    "native://Order=(.+)&VarName=(.+)",
}

tbWebView.tbAnalyzeMsgStr1 =
{
    "Native://Order=(.+)",
    "native://Order=(.+)",
}

function tbWebView:AnalyzeMsg(szMsg)
    for nIndex, szStr in ipairs(self.tbAnalyzeMsgStr) do
        local _, _, szOrder, szVarName = string.find(szMsg, szStr);
        if szOrder and szVarName then
            return szOrder, szVarName;
        end
    end

    for nIndex, szStr in ipairs(self.tbAnalyzeMsgStr1) do
        local _, _, szOrder = string.find(szMsg, szStr);
        if szOrder then
            return szOrder;
        end
    end         
end

function tbWebView:OnOrder_isWifi(szVarName)
    if not szVarName then
        return;
    end

    local nWifi = 0;
    local nType = Ui.ToolFunction.GetNetWorkType();
    if nType == Ui.NETWORKTYPE_WIFI then
        nWifi = 1;
    end

    local szJavaScript = string.format("var %s=%s;", szVarName, nWifi);
    WebView:EvaluatingJavaScript(szJavaScript);  
end

function tbWebView:OnOrder_isMusicOn(szVarName)
    if not szVarName then
        return;
    end

    local tbUserSet = Ui:GetPlayerSetting();
    local nOpenSound = 0;
    if tbUserSet.fSoundEffectVolume >= 0.1 or tbUserSet.fMusicVolume >= 0.1 then
        nOpenSound = 1;
    end
    
    local szJavaScript = string.format("var %s=%s;", szVarName, nOpenSound);
    WebView:EvaluatingJavaScript(szJavaScript)    
end

function tbWebView:OnOrder_musicOn(szVarName)
    Ui:UpdateSoundSetting();
end

function tbWebView:OnOrder_musicOff(szVarName)
    Ui:SetMusicVolume(0.0);
    Ui:SetSoundEffect(0.0);
end

function tbWebView:OnOrder_Close(szVarName)
    WebView:Close(self.szClassName);
end

function tbWebView:OnReceivedMessage(szMsg)
    if not szMsg then
        return;
    end

    local szOrder, szVarName = self:AnalyzeMsg(szMsg);
    if not szOrder then
        Log("Error WebView LuanTan", szMsg);
        return;
    end

    local FunOn = self["OnOrder_"..szOrder];
    if not FunOn then
        return;
    end

    FunOn(self, szVarName);    
end

function tbWebView:OnEvalJavaScriptFinished(szResult)
    Log("WebView LuanTan OnEvalJavaScriptFinished", szResult or "");
end

function tbWebView:OnWebViewShouldClose()
    Ui:UpdateSoundSetting();
end