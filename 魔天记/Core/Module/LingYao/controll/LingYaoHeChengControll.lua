require "Core.Module.LingYao.controll.LingYaoHeChengPanelCtr"


LingYaoHeChengControll = class("LingYaoHeChengControll");

function LingYaoHeChengControll:New()
    self = { };
    setmetatable(self, { __index = LingYaoHeChengControll });
    return self
end

function LingYaoHeChengControll:Init(gameObject)
    self.gameObject = gameObject;

    local btns = UIUtil.GetComponentsInChildren(self.gameObject, "UIButton");

    self._btnTog1 = UIUtil.GetChildInComponents(btns, "btnTog1");
    self._btnTog2 = UIUtil.GetChildInComponents(btns, "btnTog2");
    self._btnTog3 = UIUtil.GetChildInComponents(btns, "btnTog3");

    self._btnTog_npoint1 = UIUtil.GetChildByName(self._btnTog1, "Transform", "npoint");

    self._onClickBtnTog1 = function(go) self:_OnClickBtnTog1(self) end
    UIUtil.GetComponent(self._btnTog1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog1);
    self._onClickBtnTog2 = function(go) self:_OnClickBtnTog2(self) end
    UIUtil.GetComponent(self._btnTog2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog2);
    self._onClickBtnTog3 = function(go) self:_OnClickBtnTog3(self) end
    UIUtil.GetComponent(self._btnTog3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog3);

    self.dy_panels = UIUtil.GetChildByName(self.gameObject, "Transform", "dy_panels");

    for i = 1, 3 do

        self["panel" .. i] = UIUtil.GetChildByName(self.dy_panels, "Transform", "panel" .. i);

        self["panelCtr" .. i] = LingYaoHeChengPanelCtr:New();
        self["panelCtr" .. i]:Init(self["panel" .. i], i);
    end

    self.panel_right = UIUtil.GetChildByName(self.dy_panels, "Transform", "panel_right");

    self.btn_gotoYaoYuan = UIUtil.GetChildByName(self.gameObject, "UIButton", "btn_gotoYaoYuan");

    self.checkBox = UIUtil.GetChildByName(self.dy_panels, "UIToggle", "checkBox");

    self.rightCtr = LingYaoHeChengRightPanelCtr:New();
    self.rightCtr:Init(self.panel_right);

    self.currShowPantl = self["panelCtr1"];

    self._onClickCheckBox = function(go) self:_OnClickCheckBox(self) end
    UIUtil.GetComponent(self.checkBox, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickCheckBox);

    self._onClickGotoYaoYuan = function(go) self:_OnClickGotoYaoYuan(self) end
    UIUtil.GetComponent(self.btn_gotoYaoYuan, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickGotoYaoYuan);

    self:Hide();
end

function LingYaoHeChengControll:_OnClickGotoYaoYuan()

    local b = GuildDataManager.InGuild();

    if b then
        if PlayerManager.hero.info.level >= 29 then
            ModuleManager.SendNotification(YaoyuanNotes.OPEN_YAOYUANROOTPANEL);
        else
            MsgUtils.ShowTips("Guild/GuildActListItem/NoLevel");
        end
    else
        -- ????????????????????????????
        MsgUtils.ShowTips("Guild/GuildActSubPanel/label2");
    end



end

function LingYaoHeChengControll:_OnClickCheckBox()

    local v = self.checkBox.value;
    for i = 1, 3 do
        self["panelCtr" .. i]:UpShowListItem(v)
    end

end

function LingYaoHeChengControll:_OnClickBtnTog1()

    if self.currShowPantl ~= nil then
        self.currShowPantl:Hide();
    end

    self.currShowPantl = self["panelCtr1"];
    self.currShowPantl:Show()

end

function LingYaoHeChengControll:_OnClickBtnTog2()
    if self.currShowPantl ~= nil then
        self.currShowPantl:Hide();
    end

    self.currShowPantl = self["panelCtr2"];
    self.currShowPantl:Show()
end 

function LingYaoHeChengControll:_OnClickBtnTog3()
    if self.currShowPantl ~= nil then
        self.currShowPantl:Hide();
    end

    self.currShowPantl = self["panelCtr3"];
    self.currShowPantl:Show()
end

function LingYaoHeChengControll:UpInfos(setTip)

    for i = 1, 3 do
        self["panelCtr" .. i]:UpInfos(setTip)
    end

    self.rightCtr:UpInfos();

    self:_OnClickCheckBox()

end




function LingYaoHeChengControll:Show()

    -- self.gameObject.gameObject:SetActive(true);
    SetUIEnable(self.gameObject, true);
end

function LingYaoHeChengControll:Hide()

    -- self.gameObject.gameObject:SetActive(false);
    SetUIEnable(self.gameObject, false);
end

function LingYaoHeChengControll:Dispose()

    UIUtil.GetComponent(self._btnTog1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTog1 = nil;
    UIUtil.GetComponent(self._btnTog2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTog2 = nil;
    UIUtil.GetComponent(self._btnTog3, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTog3 = nil;


    UIUtil.GetComponent(self.checkBox, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickCheckBox = nil;


    UIUtil.GetComponent(self.btn_gotoYaoYuan, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickGotoYaoYuan = nil;

    for i = 1, 3 do
        self["panelCtr" .. i]:Dispose();
        self["panelCtr" .. i] = nil;
        self["panel" .. i] = nil;
    end


    if self.rightCtr ~= nil then
        self.rightCtr:Dispose();
        self.rightCtr = nil;
    end

    self.gameObject = nil;


    self._btnTog1 = nil;
    self._btnTog2 = nil;
    self._btnTog3 = nil;

    self.dy_panels = nil;

    self.panel_right = nil;

    self.checkBox = nil;


    self.currShowPantl = nil;

    self._onClickCheckBox = nil;

end