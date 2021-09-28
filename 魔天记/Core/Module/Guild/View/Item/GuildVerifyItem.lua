require "Core.Module.Common.UIItem"

GuildVerifyItem = UIItem:New();

function GuildVerifyItem:_Init()

    self._icoLeader = UIUtil.GetChildByName(self.transform, "UISprite", "icoLeader");
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._txtLv = UIUtil.GetChildByName(self.transform, "UILabel", "txtLv");
    self._txtFight = UIUtil.GetChildByName(self.transform, "UILabel", "txtFight");
    self._txtStatus = UIUtil.GetChildByName(self.transform, "UILabel", "txtStatus");
    
    self._btnNo = UIUtil.GetChildByName(self.transform, "UIButton", "btnNo");
    self._btnYes = UIUtil.GetChildByName(self.transform, "UIButton", "btnYes");
    
    self._onClickBtnNo = function(go) self:_OnClickBtnNo(self) end
    UIUtil.GetComponent(self._btnNo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnNo);
    self._onClickBtnYes = function(go) self:_OnClickBtnYes(self) end
    UIUtil.GetComponent(self._btnYes, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnYes);

    self:UpdateItem(self.data);
end

function GuildVerifyItem:_Dispose()
    UIUtil.GetComponent(self._btnNo, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnNo = nil;
    UIUtil.GetComponent(self._btnYes, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnYes = nil;
end

function GuildVerifyItem:UpdateItem(data)
    self.data = data;
    
    if data then
        self._icoLeader.spriteName = "c" .. data.kind;
        self._txtName.text = data.name;
        self._txtLv.text = data.level;
        self._txtFight.text = data.fight;
        self._txtStatus.text = LanguageMgr.Get("time/OL/".. data.onlineType);
    else
        self._icoLeader.spriteName = "";
        self._txtName.text = "";
        self._txtLv.text = "";
        self._txtFight.text = "";
        self._txtStatus.text = "";
    end
end

function GuildVerifyItem:_OnClickBtnNo()
    GuildProxy.ReqVertify(self.data.id, false);
end

function GuildVerifyItem:_OnClickBtnYes()
    GuildProxy.ReqVertify(self.data.id, true);
end
