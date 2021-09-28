require "Core.Module.Common.Panel"

require "Core.Manager.Item.XMBossDataManager";

XMBossShouLingJieShaoPanel = class("XMBossShouLingJieShaoPanel", Panel);
function XMBossShouLingJieShaoPanel:New()
    self = { };
    setmetatable(self, { __index = XMBossShouLingJieShaoPanel });
    return self
end


function XMBossShouLingJieShaoPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function XMBossShouLingJieShaoPanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txttitle = UIUtil.GetChildInComponents(txts, "txttitle");
    self._txttitle = UIUtil.GetChildInComponents(txts, "txttitle");

    self.txtToggleLabel1 = UIUtil.GetChildInComponents(txts, "txtToggleLabel1");
    self.txtToggleLabel2 = UIUtil.GetChildInComponents(txts, "txtToggleLabel2");
    self.txtToggleLabel3 = UIUtil.GetChildInComponents(txts, "txtToggleLabel3");

    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
    self._btnTog1 = UIUtil.GetChildInComponents(btns, "btnTog1");
    self._btnTog2 = UIUtil.GetChildInComponents(btns, "btnTog2");
    self._btnTog3 = UIUtil.GetChildInComponents(btns, "btnTog3");
    local trss = UIUtil.GetComponentsInChildren(self._trsContent, "Transform");
    self._trsToggle = UIUtil.GetChildInComponents(trss, "trsToggle");



    self.mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");
    self.table = UIUtil.GetChildByName(self.mainView, "Transform", "listPanel/subPanel/table");


    for i = 1, 6 do
        self["item" .. i] = UIUtil.GetChildByName(self.table, "Transform", "item" .. i);
    end

    self.cfList = XMBossDataManager.tong_monsterCf;

    for i = 1, 3 do
        self["txtToggleLabel" .. i].text = self.cfList[i].name;
    end


    self:SetSelected(1);
end

function XMBossShouLingJieShaoPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickBtnTog1 = function(go) self:_OnClickBtnTog1(self) end
    UIUtil.GetComponent(self._btnTog1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog1);
    self._onClickBtnTog2 = function(go) self:_OnClickBtnTog2(self) end
    UIUtil.GetComponent(self._btnTog2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog2);
    self._onClickBtnTog3 = function(go) self:_OnClickBtnTog3(self) end
    UIUtil.GetComponent(self._btnTog3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog3);
end

function XMBossShouLingJieShaoPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(XMBossNotes.CLOSE_XMBOSSSHOULINGJIESHAOPANEL);
end

function XMBossShouLingJieShaoPanel:_OnClickBtnTog1()

    self:SetSelected(1);
end

function XMBossShouLingJieShaoPanel:_OnClickBtnTog2()
    self:SetSelected(2);
end 

function XMBossShouLingJieShaoPanel:_OnClickBtnTog3()
    self:SetSelected(3);
end

function XMBossShouLingJieShaoPanel:SetSelected(index)

    local obj = self.cfList[index];
    local monster_id = obj.monster_id;
    local monster_obj = ConfigManager.GetMonById(monster_id);
    local lv = monster_obj.level;


    self.bossLvTxt = UIUtil.GetChildByName(self.item1, "UILabel", "head/bossLvTxt");
    self.decTxt = UIUtil.GetChildByName(self.item1, "UILabel", "decTxt");
    self.bossIcon = UIUtil.GetChildByName(self.item1, "UISprite", "head/bossIcon");

    self.bossLvTxt.text = "" .. lv;
    self.decTxt.text = obj.desc;
    self.bossIcon.spriteName = "" .. monster_obj.icon_id;


    for i = 1, 5 do
        local skill_name = obj["skill_name_" .. i];
        local skill_desc = obj["skill_desc_" .. i];

        local index = i + 1;

        local txttitle = UIUtil.GetChildByName(self["item" .. index], "UILabel", "txttitle");
        local decTxt = UIUtil.GetChildByName(self["item" .. index], "UILabel", "decTxt");

        if skill_name == "" then
            txttitle.gameObject:SetActive(false);
            decTxt.gameObject:SetActive(false);
        else

            txttitle.text = skill_name;
            decTxt.text = skill_desc;

            txttitle.gameObject:SetActive(true);
            decTxt.gameObject:SetActive(true);
        end

    end


end

function XMBossShouLingJieShaoPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function XMBossShouLingJieShaoPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btnTog1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTog1 = nil;
    UIUtil.GetComponent(self._btnTog2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTog2 = nil;
    UIUtil.GetComponent(self._btnTog3, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTog3 = nil;
end

function XMBossShouLingJieShaoPanel:_DisposeReference()

    self.mainView = nil;
    self.table = nil;


    for i = 1, 6 do
        self["item" .. i] = nil;
    end

    self.bossLvTxt = nil;
    self.decTxt = nil;
    self.bossIcon = nil;


    self._btn_close = nil;
    self._btnTog1 = nil;
    self._btnTog2 = nil;
    self._btnTog3 = nil;
    self._txttitle = nil;
    self._txttitle = nil;
    self._txttitle = nil;
    self._txttitle = nil;
    self._txttitle = nil;
    self._trsToggle = nil;
end
