require "Core.Module.Common.UIItem"

GuildHBItem = UIItem:New();

local cfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_RED_PACKET);

function GuildHBItem:_Init()
    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "imgIcon");
    self._txtTitle = UIUtil.GetChildByName(self.transform, "UILabel", "txtTitle");
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._txtMoney = UIUtil.GetChildByName(self.transform, "UILabel", "txtMoney");
    self._txtState = UIUtil.GetChildByName(self.transform, "UILabel", "txtState");
    self._btnFunc = UIUtil.GetChildByName(self.transform, "UIButton", "btnFunc");
    self._txtFuncLabel = UIUtil.GetChildByName(self.transform, "UILabel", "btnFunc/Label");
    
    self._onClickBtnFunc = function(go)self:_OnClickBtnFunc(self) end
    UIUtil.GetComponent(self._btnFunc, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnFunc);
    
    self:UpdateItem(self.data);
end

function GuildHBItem:_Dispose()
    UIUtil.GetComponent(self._btnFunc, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnFunc = nil;
    self._imgIcon = nil;
    self._txtTitle = nil;
    self._txtName = nil;
    self._txtMoney = nil;
    self._txtState = nil;
    self._btnFunc = nil;
    self._txtFuncLabel = nil;
end

function GuildHBItem:UpdateItem(data)
    self.data = data;
    if (data) then
        local cfgItem = cfg[data.rptid];
        if (cfgItem) then
            self._txtTitle.text = cfgItem.name;
        end
        if (data.st == 0) then
            self._imgIcon.spriteName = "no_hb_bg";
            self._txtState.gameObject:SetActive(true)
            self._btnFunc.gameObject:SetActive(false)
        else
            self._imgIcon.spriteName = "guild_hb";
            self._txtState.gameObject:SetActive(false)
            self._btnFunc.gameObject:SetActive(true)
        end
        
        self._txtName.text = data.pn;
        self._txtMoney.text = data.bgold;
        if (data.f == 0) then
            self._txtFuncLabel.text =LanguageMgr.Get("guild/GuildHBItem/open")
            ;
        else
            self._txtFuncLabel.text = LanguageMgr.Get("guild/GuildHBItem/check")
        end
    end
end

function GuildHBItem:_OnClickBtnFunc()
    local data = self.data
    if (data) then
        GuildProxy.ReqShowHongBao(data.rpid)
    end
end
