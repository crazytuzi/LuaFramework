require "Core.Module.Common.UIComponent"

local EndlessTryPanel = class("EndlessTryPanel",UIComponent);
function EndlessTryPanel:New()
	self = { };
	setmetatable(self, { __index =EndlessTryPanel });
	return self
end

local teaminfo = nil
local teaminfo2 = nil
local notInsprie = nil
local notUse = nil
local instime
function EndlessTryPanel:_Init()
	self:_InitReference();
	self:_InitListener();
    teaminfo = LanguageMgr.Get("EndlessTry/teaminfo")
    teaminfo2 = LanguageMgr.Get("EndlessTry/teaminfo2")
    notInsprie = LanguageMgr.Get("EndlessTry/notInsprie")
    notUse = LanguageMgr.Get("EndlessTry/notUse")
    self._timer = Timer.New(EndlessTryProxy.GetEndlessInfo, 3, -1, false)
end

function EndlessTryPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._gameObject, "UILabel");
	self._txtInstanceContext = UIUtil.GetChildInComponents(txts, "txtInstanceContext");
	self._txtInstanceDes = UIUtil.GetChildInComponents(txts, "InstanceContext");
	self._txtInspireTeam = UIUtil.GetChildInComponents(txts, "txtInspireTeam");
	self._txtInspireTeam2 = UIUtil.GetChildInComponents(txts, "txtInspireTeam2");
	self._btnQuestion = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnQuestion");
	self._btnInspire = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnInspire");
	self._btnExpBuy = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnExpBuy");
	self._trsInspireTeam = UIUtil.GetChildByName(self._gameObject, "Transform", "trsInspireTeam");
	self._bgInspireTeam = UIUtil.GetChildByName(self._trsInspireTeam, "Transform", "bgInspireTeam");
    self._trsInspireTeam.gameObject:SetActive(false)
end

function EndlessTryPanel:_InitListener()
	self._onClickBtnQuestion = function(go) self:_OnClickBtnQuestion(self) end
	UIUtil.GetComponent(self._btnQuestion, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnQuestion);
	self._onClickBtnInspire = function(go) self:_OnClickBtnInspire(self) end
	UIUtil.GetComponent(self._btnInspire, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnInspire);
	self._onClickBtnExpBuy = function(go) self:_OnClickBtnExpBuy(self) end
	UIUtil.GetComponent(self._btnExpBuy, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnExpBuy);
	self._onClickBgInspireTeam = function(go) self:_OnClickBgInspireTeam(self) end
	UIUtil.GetComponent(self._bgInspireTeam, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBgInspireTeam);
end

function EndlessTryPanel:_OnClickBtnQuestion()
	self._trsInspireTeam.gameObject:SetActive(true)
    EndlessTryProxy.GetTeamInsprieInfo()
end

function EndlessTryPanel:_OnClickBtnInspire()
	ModuleManager.SendNotification(EndlessTryNotes.OPEN_ENDLESS_INSPRIE_PANEL)
end

function EndlessTryPanel:_OnClickBtnExpBuy()
	ModuleManager.SendNotification(EndlessTryNotes.OPEN_ENDLESS_EXP_BUY_PANEL)
end

function EndlessTryPanel:_OnClickBgInspireTeam()
	self._trsInspireTeam.gameObject:SetActive(false)
end
function EndlessTryPanel:_OnChangeTeamInfo(data)
    local str = teaminfo
    local str2 = teaminfo2
    local ls = data.l
    for i=1,#ls,1 do
       local d = ls[i]
       str = str .. "\n" .. d.n
       str2 = str2 .. "\n" .. (d.value == 0 and notInsprie or (d.value .. "%")) 
    end
	self._txtInspireTeam.text = str
	self._txtInspireTeam2.text = str2
end
function EndlessTryPanel:_OnChangeInfo(d)
    --PrintTable(d, "__", Warning)
    local ridePro = RideManager.GetAllRideProperty()
    local rideExp = ridePro and (ridePro.exp_per / 10) or 0
    local str = LanguageMgr.Get("EndlessTry/info",{
        --b = d.roundId, tb = d.troundId, 
        kn = d.kn, e = math.floor( d.exp / 10000)
        , ea = d.epv == 0 and notUse or (d.epv/10) .. "%%"
        , et = d.tv == 0 and "[ff0000]0%%[-]" or d.tv .. "%%"
        , re = rideExp == 0 and "[ff0000]0%%[-]" or rideExp .. "%%"
        , ip = d.env == 0 and notInsprie or d.env .. "%%"
        })
        Warning(rideExp ..'----'..str)
	self._txtInstanceContext.text = str
	self._txtInstanceDes.text = LanguageMgr.Get("EndlessTry/des")
end
function EndlessTryPanel:_OnElsetime(et)
    local t =  instime - (et  - GetTime()) 
    local dt = 15
    --Warning("_OnElsetime__" .. tostring(instime) .. '___' .. et .. "__" .. t)
    if t < dt then 
        local msg = {
            downTime = (dt - t),
            prefix = LanguageMgr.Get("downTime/prefix")
            ,
            endMsg = LanguageMgr.Get("EndlessTry/startGmae")
            ,
            endMsgDuration = 3
        }
        MessageManager.Dispatch(SceneEventManager, DownTimer.DOWN_TIME_START, msg);
    end
end

function EndlessTryPanel:Enter()
    self:Show()
    if not self._timer.running then self._timer:Start() end
    EndlessTryProxy.InitConfig()
    EndlessTryProxy.GetEndlessInfo()
    local ins = InstanceDataManager.GetInsByMapId(GameSceneManager.GetId())
    instime = ins.time * 60
    MessageManager.AddListener(EndlessTryNotes, EndlessTryNotes.ENDLESS_CHANGE_TEAM_INFO, EndlessTryPanel._OnChangeTeamInfo, self);
    MessageManager.AddListener(EndlessTryNotes, EndlessTryNotes.ENDLESS_CHANGE_INFO, EndlessTryPanel._OnChangeInfo, self);
    MessageManager.AddListener(InstancePanelProxy, InstancePanelProxy.MESSAGE_ELSETIME_CHANGE, EndlessTryPanel._OnElsetime, self);
end
function EndlessTryPanel:Exit()
    self:Close()
    if self._timer.running then self._timer:Stop() end
    MessageManager.RemoveListener(EndlessTryNotes, EndlessTryNotes.ENDLESS_CHANGE_TEAM_INFO, EndlessTryPanel._OnChangeTeamInfo);
    MessageManager.RemoveListener(EndlessTryNotes, EndlessTryNotes.ENDLESS_CHANGE_INFO, EndlessTryPanel._OnChangeInfo);
    MessageManager.RemoveListener(InstancePanelProxy, InstancePanelProxy.MESSAGE_ELSETIME_CHANGE, EndlessTryPanel._OnElsetime);
end
function EndlessTryPanel:Close()
    if not self.showing then return end
	self.showing = false
    self._gameObject:SetActive(false)
end
function EndlessTryPanel:Show()
    if self.showing then return end
	self.showing = true
    self._gameObject:SetActive(true)
end

function EndlessTryPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function EndlessTryPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnQuestion, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnQuestion = nil;
	UIUtil.GetComponent(self._btnInspire, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnInspire = nil;
	UIUtil.GetComponent(self._btnExpBuy, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnExpBuy = nil;
	UIUtil.GetComponent(self._bgInspireTeam, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBgInspireTeam = nil;
end

function EndlessTryPanel:_DisposeReference()
    self:Exit()
	self._btnQuestion = nil;
	self._btnInspire = nil;
	self._btnExpBuy = nil;
	self._txtInstanceContext = nil;
	self._txtInspireTeam = nil;
	self._txtInspireTeam2 = nil;
	self._trsInspireTeam = nil;
    self._timer:Stop()
    self._timer = nil
end
return EndlessTryPanel