function Pray:OnSyncResponse(szWuxing)
    self.szWuxing = szWuxing;
    UiNotify.OnNotify(UiNotify.emNOTIFY_PRAY_SYNC);
end

function Pray:PrayAnimationControl(nState)
    UiNotify.OnNotify(UiNotify.emNOTIFY_PRAY_ANI_CON, nState);
end

function Pray:GetWuxing()
    return self.szWuxing or "";
end

function Pray:GetLastWuxing()
    if not self.szWuxing or self.szWuxing == "" then
        return "";
    end
     
    local nLen = string.len(self.szWuxing);
    local szElem = string.sub(self.szWuxing, nLen, nLen);
    return tonumber(szElem) or 1;
end