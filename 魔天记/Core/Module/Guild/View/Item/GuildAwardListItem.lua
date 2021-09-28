require "Core.Module.Common.UIItem"

GuildAwardListItem = UIItem:New();

function GuildAwardListItem:_Init()

    self._icoMain = UIUtil.GetChildByName(self.transform, "UISprite", "icoMain");
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._txtDesc = UIUtil.GetChildByName(self.transform, "UILabel", "txtDesc");
    self._btnOpen = UIUtil.GetChildByName(self.transform, "UIButton", "btnOpen");
    self._btnOther = UIUtil.GetChildByName(self.transform, "UIButton", "btnOther");

    self._icoOpenRedPoint = UIUtil.GetChildByName(self._btnOpen, "UISprite", "redPoint");
    self._icoOtherRedPoint = UIUtil.GetChildByName(self._btnOther, "UISprite", "redPoint");

    self._btnOpenLabel = UIUtil.GetChildByName(self._btnOpen, "UILabel", "Label");
    self._btnOtherLabel = UIUtil.GetChildByName(self._btnOther, "UILabel", "Label");

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self._btnOpen, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

    self._onClickBtnOther = function(go) self:_OnClickBtnOther(self) end
    UIUtil.GetComponent(self._btnOther, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnOther);

    self._btnOther.gameObject:SetActive(false);
    if self._icoOpenRedPoint then
        self._icoOpenRedPoint.alpha = 0;
    end

    if self._icoOtherRedPoint then
        self._icoOtherRedPoint.alpha = 0;
    end

    self:UpdateItem(self.data);
end

function GuildAwardListItem:_Dispose()
    UIUtil.GetComponent(self._btnOpen, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;

    UIUtil.GetComponent(self._btnOther, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnOther = nil;
end

local btnLabel1 = LanguageMgr.Get("GuildAwardListItem/btnLabel1")
local btnLabel2 = LanguageMgr.Get("GuildAwardListItem/btnLabel2")
local btnLabel3 = LanguageMgr.Get("GuildAwardListItem/btnLabel3")

function GuildAwardListItem:UpdateItem(data)
    self.data = data;
    if data then
        self._icoMain.spriteName = data.icon;
        -- data.icon;
        self._txtName.text = data.name;
        self._txtDesc.text = data.openDesc;

        if self.data.id == GuildDataManager.Open.XMBoss_FuLi then
            self._btnOpenLabel.text = btnLabel1;
            self._btnOtherLabel.text = btnLabel2;
            self._btnOther.gameObject:SetActive(true);
        elseif self.data.id == GuildDataManager.Open.SALARY then
            self._btnOpenLabel.text = btnLabel3
            self._btnOtherLabel.text = btnLabel2
            self._btnOther.gameObject:SetActive(true);
        end
        self:UpdateRedPoint();
    else
        self._icoMain.spriteName = "";
        self._txtName.text = "";
        self._txtDesc.text = "";
    end
end

function GuildAwardListItem:_OnClickBtn()
    -- MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_GUILD_AWARD_SELECT, self.data);

    local lv = GuildDataManager.data.level;
    if lv < self.data.level then
        MsgUtils.ShowTips("guild/act/openType/-1", { lv = self.data.level });
        return;
    end

    local rolelv = PlayerManager.GetPlayerLevel();
    if rolelv < self.data.req_lev then
        MsgUtils.ShowTips("guild/act/openType/-2", { lv = self.data.req_lev });
        return;
    end

    if self.data.id == GuildDataManager.Open.SHOP then
        -- ModuleManager.SendNotification(TShopNotes.OPEN_TSHOP,{type = TShopNotes.Shop_type_team})
        --  ModuleManager.SendNotification(TShopNotes.OPEN_TSHOP, {type = TShopNotes.Shop_type_fightScene});
        ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 5 });

    elseif self.data.id == GuildDataManager.Open.XMBoss_FuLi then
        -- 仙盟 福利
        ModuleManager.SendNotification(XMBossNotes.OPEN_XMBOSSFULIPANEL);
    elseif self.data.id == GuildDataManager.Open.SKILL then
        -- 仙盟技能
        ModuleManager.SendNotification(GuildNotes.OPEN_GUILD_OTHER_PANEL, GuildNotes.OTHER.SKILL);
    elseif self.data.id == GuildDataManager.Open.SALARY then
        -- show desc
        ModuleManager.SendNotification(GuildNotes.OPEN_GUILD_OTHER_PANEL, GuildNotes.OTHER.SALARYDESC);
    end

end

function GuildAwardListItem:_OnClickBtnOther()

    local lv = GuildDataManager.data.level;
    if lv < self.data.level then
        MsgUtils.ShowTips("guild/act/openType/-1", { lv = self.data.level });
        return;
    end

    local rolelv = PlayerManager.GetPlayerLevel();
    if rolelv < self.data.req_lev then
        MsgUtils.ShowTips("guild/act/openType/-2", { lv = self.data.req_lev });
        return;
    end

    if self.data.id == GuildDataManager.Open.XMBoss_FuLi then
        -- 领取奖励
        XMBossProxy.GetXMBossFBFenPeiBox();
    elseif self.data.id == GuildDataManager.Open.SHOP then
        ModuleManager.SendNotification(TShopNotes.OPEN_TSHOP, { type = TShopNotes.Shop_type_team })
    elseif self.data.id == GuildDataManager.Open.SALARY then
        -- 领取工资
        GuildProxy.ReqGetSalary();
    end

end

function GuildAwardListItem:UpdateRedPoint()
    if self.data.id == GuildDataManager.Open.XMBoss_FuLi then
        self._icoOpenRedPoint.alpha =(GuildDataManager.GetGrant(GuildDataManager.opt.assign) and GuildDataManager.awardFpNum > 0) and 1 or 0;
        self._icoOtherRedPoint.alpha = GuildDataManager.awardMyNum > 0 and 1 or 0;
    elseif self.data.id == GuildDataManager.Open.SALARY then
        self._icoOtherRedPoint.alpha = GuildDataManager.canGetSalary and 1 or 0;
    elseif self.data.id == GuildDataManager.Open.SKILL then
        self._icoOpenRedPoint.alpha = GuildDataManager.GetSkillRedPoint() and 1 or 0;
    end
end
