require "Core.Module.Common.Panel"

local SceneCollectPanel = class("SceneCollectPanel",Panel);
function SceneCollectPanel:New()
	self = { };
	setmetatable(self, { __index =SceneCollectPanel });
	return self
end


function SceneCollectPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function SceneCollectPanel:IsPopup()
	return false
end

function SceneCollectPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	self._txtName = UIUtil.GetChildInComponents(txts, "txtName");
	self._txtAction = UIUtil.GetChildInComponents(txts, "txtAction");
	self._btnAction = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnAction");
	self._imgIcon = UIUtil.GetChildByName(self._trsContent, "UITexture", "imgIcon");
end

function SceneCollectPanel:_InitListener()
	self:_AddBtnListen(self._btnAction.gameObject)
    MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_BEFORE_EXIT, SceneCollectPanel.ExitScene)
end

function SceneCollectPanel:_OnBtnsClick(go)
	if go == self._btnAction.gameObject then
		self:_OnClickBtnAction()
	end
end

function SceneCollectPanel:_OnClickBtnAction()
	local t = SceneEntityProxy.StartCollect(self.d.id)
    if t > 0 then self:_StartCollect(t)
    else SceneCollectPanel:_HoldComplete() end
end

function SceneCollectPanel:SetData(d)
    self.d = d
	self._txtName.text = d.name
    self._mainTexturePath = "Other/" .. d.icon
    self._imgIcon.mainTexture = UIUtil.GetTexture(self._mainTexturePath)
end

function SceneCollectPanel:_StartCollect(t)
    self:SetActive(false)
	ModuleManager.SendNotification(CountdownNotes.OPEN_COUNTDOWNBARNPANEL, {
        time = t,
        title = LanguageMgr.Get("GuildWarInfoPanel/collect"),
        cancelHandler = function() self:_CancelOccupyMine() end,
        suspend = function() return self:_CheckSuspendOccupy() end,
        handler = function() self:_HoldComplete() end
    } )
end
function SceneCollectPanel:_CancelOccupyMine()
    SceneEntityProxy.CancelCollect()
    self:SetActive(true)
end
function SceneCollectPanel:_CheckSuspendOccupy()
	local hero = PlayerManager.hero
	if(hero == nil) then return true end
	local act = hero:GetAction()
	if(act ~= nil and (act.__cname ~= "StandAction" and act.__cname ~= "SendStandAction" and act.__cname ~= "HurtAction")) then
		return true
	end
	return false
end
function SceneCollectPanel:_HoldComplete()
     ModuleManager.SendNotification(SceneEntityNotes.SCENE_ENTITY_AWAY)
end

function SceneCollectPanel:_Dispose()
    if self._mainTexturePath then
        UIUtil.RecycleTexture(self._mainTexturePath)
        self._mainTexturePath = nil
    end
    MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_BEFORE_EXIT, SceneCollectPanel.ExitScene)
	self:_DisposeReference();
end

function SceneCollectPanel:_DisposeReference()
	self._btnAction = nil;
	self._txtName = nil;
	self._txtAction = nil;
end
function SceneCollectPanel.ExitScene()
    ModuleManager.SendNotification(SceneEntityNotes.SCENE_ENTITY_AWAY)
    ModuleManager.SendNotification(CountdownNotes.CLOSE_COUNTDOWNBARNPANEL)
end

return SceneCollectPanel