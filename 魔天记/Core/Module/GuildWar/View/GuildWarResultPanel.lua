require "Core.Module.Common.Panel";
require "Core.Module.Common.Phalanx";
require "Core.Module.GuildWar.View.Item.GuildWarResultItem";

GuildWarResultPanel = Panel:New();

function GuildWarResultPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function GuildWarResultPanel:_InitReference()
    self._imgBg = UIUtil.GetChildByName(self._trsContent, "UISprite", "bg");

    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
    self._txtCloseLabel = UIUtil.GetChildByName(self._trsContent, "UILabel", "btnClose/txtLabel");
    
    self._trsInfo = UIUtil.GetChildByName(self._trsContent, "Transform", "trsInfo");
    self._txtRank = UIUtil.GetChildByName(self._trsInfo, "UILabel", "txtRank");
    self._txtNum = UIUtil.GetChildByName(self._trsInfo, "UILabel", "txtNum");
    self._txtPoint = UIUtil.GetChildByName(self._trsInfo, "UILabel", "txtPoint");
    self._txtMyPoint = UIUtil.GetChildByName(self._trsInfo, "UILabel", "txtMyPoint");

    self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "ScrollView/phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, GuildWarResultItem);

    self._totalTime = 30;
    self._timer = Timer.New( function(val) self:_OnTickHandler(val) end, 0, -1, false);
    self._timer:Start();
end

function GuildWarResultPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
end

function GuildWarResultPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function GuildWarResultPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
end

function GuildWarResultPanel:_DisposeReference()

    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end
    if (self._effBg) then
        Resourcer.Recycle(self._effBg, false);
        self._effBg = nil;
    end
    if (self._effWin) then
        Resourcer.Recycle(self._effWin, false);
        self._effWin = nil;
    end

    self._imgBg = nil;

    self._phalanx:Dispose();
    self._phalanx = nil;
end

function GuildWarResultPanel:_Opened()
   	--self:UpdateDisplay();
end

function GuildWarResultPanel:Update(data)
    self.data = data;
	self:UpdateDisplay();
end

function GuildWarResultPanel:UpdateDisplay()
    local data = self.data;
    local myInfo = nil; 
    local pid = PlayerManager.hero.id;
    for i, v in ipairs(data.l) do 
        if v.pi == pid then
            myInfo = v;
            break;
        end
    end

    local items = data.l;
    self._phalanx:Build(#items, 1 , items);

    self._txtRank.text = myInfo and myInfo.id or "";
    self._txtNum.text = data.c;
    self._txtPoint.text = data.pt;
    self._txtMyPoint.text = myInfo and myInfo.pt or "";

    self:_ShowEffect(self.data.win)
end

function GuildWarResultPanel:_OnClickBtnClose()
	--ModuleManager.SendNotification(GuildWarNotes.CLOSE_RESULT_PANEL);
	GuildWarProxy.ReqLeave();
end

function GuildWarResultPanel:_OnTickHandler()
    if (self._totalTime) then
        self._totalTime = self._totalTime - Timer.deltaTime;
        local cTime = math.ceil(self._totalTime);
        if (self._currTime ~= cTime) then
            self._currTime = cTime
            self._txtCloseLabel.text = LanguageMgr.Get("Arathi/OverResult/exit", { n = cTime });
        end
        if (cTime < 1) then
            self._totalTime = nil;
            self:_OnClickBtnClose()
        end
    end
end

function GuildWarResultPanel:_ShowEffect(win)
    if (win == 1) then
        self._effBg = UIUtil.GetUIEffect("ui_win_BG", self._trsContent, self._imgBg, 3);
        self._effWin = UIUtil.GetUIEffect("ui_win", self._trsContent, self._imgBg, 4);
        UIUtil.ScaleParticleSystem(self._effWin, 0.6);
        Util.SetLocalPos(self._effWin, 0, 230, 0)
        --        self._effWin.transform.localPosition = Vector3.New(0, 230, 0);
    else
        self._effBg = UIUtil.GetUIEffect("ui_lose", self._trsContent, self._imgBg, 3);
    end
    UIUtil.ScaleParticleSystem(self._effBg, 0.6);
    Util.SetLocalPos(self._effBg, 0, 230, 0)

    --    self._effBg.transform.localPosition = Vector3.New(0, 230, 0);
end