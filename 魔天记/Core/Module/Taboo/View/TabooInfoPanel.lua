require "Core.Module.Common.UIComponent"

local TabooInfoPanel = class("TabooInfoPanel",UIComponent)
function TabooInfoPanel:New()
	self = { }
	setmetatable(self, { __index =TabooInfoPanel })
	return self
end


function TabooInfoPanel:_Init()
	self:_InitReference()
	self:_InitListener()
end

function TabooInfoPanel:_InitReference()
	self._txtNum = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtNum")
	self._txtTime = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtTime")
	self._txtMozhu = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtMozhu")
	--self._trsCollect = UIUtil.GetChildByName(self._gameObject, "Transform", "trsCollect").gameObject
	--self._btnAction = UIUtil.GetChildByName(self._trsCollect, "Transform", "btnAction")
	--self._imgIcon = UIUtil.GetChildByName(self._trsCollect, "UITexture", "imgIcon")
	--self._txtName = UIUtil.GetChildByName(self._trsCollect, "UILabel", "txtName")
end
function TabooInfoPanel:_InitListener()
end

function TabooInfoPanel:SetCuurentNum()
    self._txtNum.text = TabooProxy.GetNumShow()
end

function TabooInfoPanel:Enter()
    --Warning("TabooInfoPanel,Enter")
    TabooProxy.SetInTaboo(true)
    ChoosePKTypeProxy.ForceTaboo()
    ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY)
    self._txtTime.text = TabooProxy.GetCollectInfoShow()
    self:Show()
    MessageManager.AddListener(TabooNotes, TabooNotes.TABOO_COLLECT_NUM, TabooInfoPanel.SetCuurentNum, self)
    MessageManager.AddListener(TabooNotes, TabooNotes.TABOO_HOLD_MINE_NEAR, TabooInfoPanel._HoldMineNear, self)
    MessageManager.AddListener(TabooNotes, TabooNotes.TABOO_HOLD_MINE_AWAY, TabooInfoPanel._HoldMineAway, self)
    MessageManager.AddListener(TabooNotes, TabooNotes.TABOO_HOLD_MINE, TabooInfoPanel._HoldMine, self)
    MessageManager.AddListener(TabooNotes, TabooNotes.TABOO_MINE_COLLECTED, TabooInfoPanel._MineChange, self)
    MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_BEFORE_EXIT, TabooInfoPanel.Exit, self);
    TabooProxy.GetTabooInfo()
    self._trsCollect = UIUtil.GetUIGameObject(ResID.UI_TABOO_COLLECT_PANEL, self._transform.parent)
	self._btnAction = UIUtil.GetChildByName(self._trsCollect, "Transform", "btnAction")
	self._imgIcon = UIUtil.GetChildByName(self._trsCollect, "UITexture", "imgIcon")
	self._txtName = UIUtil.GetChildByName(self._trsCollect, "UILabel", "txtName")
	self._onClickFunctionHandler = function() self:_OnClickFunctionHandler() end
	UIUtil.GetComponent(self._btnAction, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickFunctionHandler)
    self._trsCollect:SetActive(false)
    self.entering = true
    self.timer = Timer.New(function() self:_UpdateTime() end, 1, -1):Start()
    self:_UpdateTime()
end
function TabooInfoPanel:_UpdateTime()
    self._txtMozhu.text = TabooProxy.GetMozhuDes()
end
function TabooInfoPanel:Exit()
    --Warning("TabooInfoPanel,Exit")
    if not self.entering then return end
    self.entering = false
    TabooProxy.SetInTaboo(false)
    ChoosePKTypeProxy.RevertLast()
    self:Close()
    MessageManager.RemoveListener(TabooNotes, TabooNotes.TABOO_COLLECT_NUM, TabooInfoPanel.SetCuurentNum)
    MessageManager.RemoveListener(TabooNotes, TabooNotes.TABOO_HOLD_MINE_NEAR, TabooInfoPanel._HoldMineNear)
    MessageManager.RemoveListener(TabooNotes, TabooNotes.TABOO_HOLD_MINE_AWAY, TabooInfoPanel._HoldMineAway)
    MessageManager.RemoveListener(TabooNotes, TabooNotes.TABOO_HOLD_MINE, TabooInfoPanel._HoldMine)
    MessageManager.RemoveListener(TabooNotes, TabooNotes.TABOO_MINE_COLLECTED, TabooInfoPanel._MineChange)
    MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_BEFORE_EXIT, TabooInfoPanel.Exit)
    self:_CancelOccupyMine()
    self:_HoldMineAway()
	UIUtil.GetComponent(self._btnAction, "LuaUIEventListener"):RemoveDelegate("OnClick")
	self._onClickFunctionHandler = nil
    Resourcer.Recycle(self._trsCollect)
    if self.timer then self.timer:Stop() self.timer = nil end 
end
function TabooInfoPanel:Show()
    --Warning("TabooInfoPanel,Show")
    if self.showing then return end
	self.showing = true
    self._gameObject:SetActive(true)
end
function TabooInfoPanel:Close()
    --Warning("TabooInfoPanel,Close")
    if not self.showing then return end
	self.showing = false
    self._gameObject:SetActive(false)
end
function TabooInfoPanel:_OnClickFunctionHandler()
    self.collectTime = TabooProxy.StartCollect(self._mid)
end
function TabooInfoPanel:_HoldMine(d)
    if d.f == 0 then
        self:_StartCollect(self.collectTime)
    elseif d.f == 1 then
        self:_HoldMineAway()
        ModuleManager.SendNotification(CountdownNotes.CLOSE_COUNTDOWNBARNPANEL)
    end
end
function TabooInfoPanel:_MineChange()
    self:_HoldMineAway()
    ModuleManager.SendNotification(CountdownNotes.CLOSE_COUNTDOWNBARNPANEL)
    MsgUtils.ShowTips("TabooPanel/collected")
end
function TabooInfoPanel:_HoldMineNear(data)
    self._mid = data.id
    self._mainTexturePath = "Other/" .. data.icon
    self._txtName.text = data.name
    self._imgIcon.mainTexture = UIUtil.GetTexture(self._mainTexturePath)
    self._trsCollect:SetActive(true)
end
function TabooInfoPanel:_HoldMineAway()
    if self._mainTexturePath then
        UIUtil.RecycleTexture(self._mainTexturePath)
        self._mainTexturePath = nil
    end
    self._trsCollect:SetActive(false)
end

function TabooInfoPanel:_StartCollect(t)
    self._trsCollect:SetActive(false)
    --Warning("_StartCollect")
	ModuleManager.SendNotification(CountdownNotes.OPEN_COUNTDOWNBARNPANEL, {
        time = t,
        title = LanguageMgr.Get("GuildWarInfoPanel/collect"),
        cancelHandler = function() self:_CancelOccupyMine() end,
        suspend = function() return self:_CheckSuspendOccupy() end,
        handler = function() self:_HoldMineAway() end
    } )
end
function TabooInfoPanel:_CancelOccupyMine()
    --Warning("_CancelOccupyMine")
	self._trsCollect:SetActive(true)
	ModuleManager.SendNotification(CountdownNotes.CLOSE_COUNTDOWNBARNPANEL)
    TabooProxy.CancelCollect()
end
function TabooInfoPanel:_CheckSuspendOccupy()
	local hero = PlayerManager.hero;
	if(hero == nil) then
		return true;
	end
	local act = hero:GetAction();
	if(act ~= nil and (act.__cname ~= "StandAction" and act.__cname ~= "SendStandAction" and act.__cname ~= "HurtAction")) then
		return true
	end
	return false;
end


function TabooInfoPanel:_Dispose()
	self:_DisposeReference()
end

function TabooInfoPanel:_DisposeReference()
    self:Exit()
	self._txtNum = nil
	self._txtTime = nil
	self._btnAction = nil
    if self._mainTexturePath then
        UIUtil.RecycleTexture(self._mainTexturePath)
        self._mainTexturePath = nil
    end
    self._imgIcon = nil
    if self.timer then self.timer:Stop() self.timer = nil end 
end
return TabooInfoPanel