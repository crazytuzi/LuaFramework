require "Core.Module.Common.UIItem"

GuildSelfHBItem = UIItem:New();

local cfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_RED_PACKET);

function GuildSelfHBItem:_Init()
    self._txtTitle = UIUtil.GetChildByName(self.transform, "UILabel", "txtTitle");
    self._txtOther = UIUtil.GetChildByName(self.transform, "UILabel", "txtOther");
    self._txtMoney = UIUtil.GetChildByName(self.transform, "UILabel", "txtMoney");
    self._btnFunc = UIUtil.GetChildByName(self.transform, "UIButton", "btnFunc");
    self._txtFuncLabel = UIUtil.GetChildByName(self.transform, "UILabel", "btnFunc/Label");

    self._onClickBtnFunc = function(go) self:_OnClickBtnFunc(self) end
    UIUtil.GetComponent(self._btnFunc, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnFunc);

    self:UpdateItem(self.data);
end

function GuildSelfHBItem:_Dispose()
    UIUtil.GetComponent(self._btnFunc, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnFunc = nil;

    self._txtTitle = nil;
    self._txtOther = nil;
    self._txtMoney = nil;
    self._btnFunc = nil;
    self._txtFuncLabel = nil;
end

function GuildSelfHBItem:UpdateItem(data)
    self.data = data;
    if (data) then
        local cfgItem = cfg[data.rptid];        
        if (cfgItem) then
            self._txtTitle.text = cfgItem.name;
            self._txtOther.text = "";            
        end
        self._txtMoney.text = data.bgold;
        if (data.st == 0) then
            self._txtFuncLabel.text = LanguageMgr.Get("GuildSelfHBItem/label1") ;
        else
            if (data.f == 0 and data.st ~= 2) then
                self._txtFuncLabel.text = LanguageMgr.Get("GuildSelfHBItem/label2") ;
            else
                self._txtFuncLabel.text = LanguageMgr.Get("GuildSelfHBItem/label3") ;
            end
        end
    end
end

function GuildSelfHBItem:_OnClickBtnFunc()
    local data = self.data
    if (data) then
        if (data.st == 0) then
            ModuleManager.SendNotification(GuildNotes.OPEN_GUILDSENDHONGBAOPANEL, data);
        else
            GuildProxy.ReqShowHongBao(data.rpid)
        end
    end
end