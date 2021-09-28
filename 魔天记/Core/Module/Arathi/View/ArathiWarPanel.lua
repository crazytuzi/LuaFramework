require "Core.Module.Common.Panel";
require "Core.Module.Arathi.View.Item.ArathiWarListItem"

local battleCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_BATTLEGROUND_CONFIG);
ArathiWarPanel = Panel:New();

function ArathiWarPanel:_Init()
    local hero = PlayerManager.hero;
    self._camp = hero.info.camp;
    self._winPointNeed = battleCfg[1].winpoint_need
    self:_InitReference();
    self:_InitListener();

    ArathiProxy.ArathiWarRank();
end

function ArathiWarPanel:_InitReference()
    self._trsList = UIUtil.GetChildByName(self._trsContent, "Transform", "trsList");
    self._scrollView = UIUtil.GetComponent(self._trsList, "UIScrollView");
    self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, ArathiWarListItem);

    self._txtOurEnergy = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtOurEnergy");
    self._sliderOurEnergy = UIUtil.GetChildByName(self._trsContent, "UISlider", "sliderOurEnergy");
    self._sliderOurBar = UIUtil.GetChildByName(self._trsContent, "UISprite", "sliderOurEnergy/Foreground");

    self._txtEnemyEnergy = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtEnemyEnergy");
    self._sliderEnemyEnergy = UIUtil.GetChildByName(self._trsContent, "UISlider", "sliderEnemyEnergy");
    self._sliderEnemyBar = UIUtil.GetChildByName(self._trsContent, "UISprite", "sliderEnemyEnergy/Foreground");

    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
    self._btnExit = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnExit");
    self._btnTips = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnTips");

    if (self._camp == 1) then
        self._sliderOurBar.spriteName = "arathiPowerBar1"
        self._sliderEnemyBar.spriteName = "arathiPowerBar2"
    else
        self._sliderOurBar.spriteName = "arathiPowerBar2"
        self._sliderEnemyBar.spriteName = "arathiPowerBar1"
    end
end

function ArathiWarPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

    self._onClickBtnExit = function(go) self:_OnClickBtnExit(self) end
    UIUtil.GetComponent(self._btnExit, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnExit);

    self._onClickBtnTips = function(go) self:_OnClickBtnTips(self) end
    UIUtil.GetComponent(self._btnTips, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTips);

    MessageManager.AddListener(ArathiNotes, ArathiNotes.EVENT_ARATHIWARRANK, ArathiWarPanel._OnDataHandler, self);
    MessageManager.AddListener(ArathiNotes, ArathiNotes.EVENT_ARATHIRESCHAGE, ArathiWarPanel._OnResChangeHandler, self);
end

function ArathiWarPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function ArathiWarPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;

    UIUtil.GetComponent(self._btnExit, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnExit = nil;

    UIUtil.GetComponent(self._btnTips, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTips = nil;

    MessageManager.RemoveListener(ArathiNotes, ArathiNotes.EVENT_ARATHIWARRANK, ArathiWarPanel._OnDataHandler);
    MessageManager.RemoveListener(ArathiNotes, ArathiNotes.EVENT_ARATHIRESCHAGE, ArathiWarPanel._OnResChangeHandler);
end

function ArathiWarPanel:_DisposeReference()
    self._trsList = nil;
    self._scrollView = nil;
    self._phalanxInfo = nil;
    self._phalanx:Dispose()
    self._phalanx = nil;


    self._txtOurEnergy = nil;
    self._sliderOurEnergy = nil;
    self._sliderOurBar = nil;

    self._txtEnemyEnergy = nil;
    self._sliderEnemyEnergy = nil;
    self._sliderEnemyBar = nil;

    self._btnClose = nil;
    self._btnExit = nil;
    self._btnTips = nil;
end

function ArathiWarPanel:SetData(data)
    if (self._camp == 1) then
        self._txtOurEnergy.text = data.wp1 .. "/" .. self._winPointNeed;
        self._sliderOurEnergy.value = data.wp1 / self._winPointNeed;
        self._txtEnemyEnergy.text = data.wp2 .. "/" .. self._winPointNeed;
        self._sliderEnemyEnergy.value = data.wp2 / self._winPointNeed;
    else
        self._txtOurEnergy.text = data.wp2 .. "/" .. self._winPointNeed;
        self._sliderOurEnergy.value = data.wp2 / self._winPointNeed
        self._txtEnemyEnergy.text = data.wp1 .. "/" .. self._winPointNeed;
        self._sliderEnemyEnergy.value = data.wp1 / self._winPointNeed
    end
end

function ArathiWarPanel:_OnDataHandler(data)
    local ls = data.l
    if (ls == nil) then ls = { } end
    self._phalanx:Build(table.getCount(ls), 1, ls);
end

function ArathiWarPanel:_OnResChangeHandler(data)
    self:SetData(data);
end

function ArathiWarPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHIWARPANEL)
end

function ArathiWarPanel:_OnClickBtnExit()
    ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
        title = LanguageMgr.Get("common/notice"),
        msg = LanguageMgr.Get("Arathi/war/exit"),
        ok_Label = LanguageMgr.Get("common/ok"),
        cance_lLabel = LanguageMgr.Get("common/cancle"),
        hander = ArathiWarPanel.DetermineExit,
        target = self;
        data = nil
    } );
end

function ArathiWarPanel:DetermineExit()
    ArathiProxy.ExitArathiWar();
    ModuleManager.SendNotification(ArathiNotes.CLOSE_ARATHIWARPANEL)
end

function ArathiWarPanel:_OnClickBtnTips()
    ModuleManager.SendNotification(ArathiNotes.OPEN_ARATHIWARTIPSPANEL)
end