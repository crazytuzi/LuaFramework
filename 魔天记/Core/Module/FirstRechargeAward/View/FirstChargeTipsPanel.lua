require "Core.Module.Common.Panel"

local FirstChargeTipsPanel = class("FirstChargeTipsPanel",Panel);
function FirstChargeTipsPanel:New()
	self = { };
	setmetatable(self, { __index =FirstChargeTipsPanel });
	return self
end

function FirstChargeTipsPanel:_Init()
	self:_InitReference();
	self:_InitListener();
    self:UpdatePanel()
end

function FirstChargeTipsPanel:IsPopup()
	return false
end

function FirstChargeTipsPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	self._txtPower = UIUtil.GetChildInComponents(txts, "txtPower");
	local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
	self._btnClose = UIUtil.GetChildInComponents(btns, "btnClose");
	self._btnok = UIUtil.GetChildInComponents(btns, "btnok");
    self._aim = UIUtil.GetChildByName(self._trsContent, "Animator", "tip");
    self._aim:Play('selected')
end

function FirstChargeTipsPanel:UpdatePanel()
    self._txtPower.text = LanguageMgr.Get("FirstChargeTipsPanel/addPower")
    if self._tPath then UIUtil.RecycleTexture(self._tPath) self._tPath = nil end
    local k = PlayerManager.GetPlayerKind()
    --k = ({101000,102000,103000,104000 })[math.random (1,4)]
    self._tPath = 'arm/' .. k
    local imgArm = UIUtil.GetChildByName(self._trsContent, "UITexture", "tip/" .. k);
    imgArm.mainTexture = UIUtil.GetTexture(self._tPath)
    local armTrs = imgArm.transform
    self._effect = UIUtil.GetUIEffect("ui_" .. k, armTrs, nil)
    UIUtil.ScaleParticleSystem(armTrs.gameObject, true)
    local actTrs = GuideContent.GetActItem(SystemConst.Id.FIRSTRECHARGEAWARD)
    if not actTrs then return end
    self._trsContent.position = actTrs.position
end

function FirstChargeTipsPanel:_InitListener()
	self:_AddBtnListen(self._btnClose.gameObject)
	self:_AddBtnListen(self._btnok.gameObject)
end

function FirstChargeTipsPanel:_OnBtnsClick(go)
	if go == self._btnClose.gameObject then
		self:_OnClickBtnClose()
	elseif go == self._btnok.gameObject then
		self:_OnClickBtnok()
	end
end

function FirstChargeTipsPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(FirstRechargeAwardNotes.CLOSE_FIRSTRECHARGE_ALERT_PANEL)
end

function FirstChargeTipsPanel:_OnClickBtnok()
    --ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 3 })
    ModuleManager.SendNotification(ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL,{code_id=3});
    self:_OnClickBtnClose()
end


function FirstChargeTipsPanel:_Dispose()
	self:_DisposeReference();
    if self._tPath then UIUtil.RecycleTexture(self._tPath) self._tPath = nil end
    Resourcer.Recycle(self._effect, false)
end

function FirstChargeTipsPanel:_DisposeReference()
	self._btnClose = nil;
	self._btnok = nil;
	self._txtPower = nil;
end
return FirstChargeTipsPanel