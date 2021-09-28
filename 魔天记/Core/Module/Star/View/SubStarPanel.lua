require "Core.Module.Common.UIComponent"

local SubStarPanel = class("SubStarPanel",UIComponent);
function SubStarPanel:New()
	self = { };
	setmetatable(self, { __index =SubStarPanel });
	return self
end


function SubStarPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function SubStarPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._gameObject, "UILabel");
	self._txtNextStar = UIUtil.GetChildInComponents(txts, "txtNextStar");
	self._txtLevel = UIUtil.GetChildInComponents(txts, "txtLevel");
	self._txtAtts = UIUtil.GetChildInComponents(txts, "txtAtts");
	self._txtUpgradeAtts = UIUtil.GetChildInComponents(txts, "txtUpgradeAtts");
	self._txtUpgradeNeed = UIUtil.GetChildInComponents(txts, "txtUpgradeNeed");
	local imgs = UIUtil.GetComponentsInChildren(self._gameObject, "UISprite");
	self._imgQuality = UIUtil.GetChildInComponents(imgs, "imgQuality");
	self._imgIcon = UIUtil.GetChildInComponents(imgs, "imgIcon");
	local btns = UIUtil.GetComponentsInChildren(self._gameObject, "UIButton");
	self._btnChange = UIUtil.GetChildInComponents(btns, "btnChange");
	self._btnUpgrade = UIUtil.GetChildInComponents(btns, "btnUpgrade");
	self._trsLelf = UIUtil.GetChildByName(self._gameObject, "Transform", "trsLelf");
	self._trsNoSelect = UIUtil.GetChildByName(self._gameObject, "Transform", "trsNoSelect");
end

function SubStarPanel:_InitListener()
	self:_AddBtnListen(self._btnChange.gameObject)
	self:_AddBtnListen(self._btnUpgrade.gameObject)
end

function SubStarPanel:_OnBtnsClick(go)
	if go == self._btnChange.gameObject then
		self:_OnClickBtnChange()
	elseif go == self._btnUpgrade.gameObject then
		self:_OnClickBtnUpgrade()
	end
end

function SubStarPanel:_OnClickBtnChange()
	
end

function SubStarPanel:_OnClickBtnUpgrade()
	
end

function SubStarPanel:_Dispose()
	self:_DisposeReference();
end

function SubStarPanel:_DisposeReference()
	self._btnChange = nil;
	self._btnUpgrade = nil;
	self._txtNextStar = nil;
	self._txtLevel = nil;
	self._txtAtts = nil;
	self._txtUpgradeAtts = nil;
	self._txtUpgradeNeed = nil;
	self._imgQuality = nil;
	self._imgIcon = nil;
	self._trsLelf = nil;
	self._trsNoSelect = nil;
end
return SubStarPanel