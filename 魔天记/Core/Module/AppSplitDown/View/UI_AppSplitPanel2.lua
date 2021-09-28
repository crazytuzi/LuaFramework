require "Core.Module.Common.Panel"
require "Core.Module.Common.ProductItems"

local UI_AppSplitPanel2 = class("UI_AppSplitPanel2", Panel);
function UI_AppSplitPanel2:New()
	self = {};
	setmetatable(self, {__index = UI_AppSplitPanel2});
	return self
end


function UI_AppSplitPanel2:_Init()
	self:_InitReference();
	self:_InitListener();
end

function UI_AppSplitPanel2:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	self._txtPress = UIUtil.GetChildInComponents(txts, "txtPress");
	self._Title = UIUtil.GetChildInComponents(txts, "Title");
	self._Title.text = LanguageMgr.Get("UI_AppSplitPanel/title")
	self._Msg = UIUtil.GetChildInComponents(txts, "Msg");
	self._Msg.text = LanguageMgr.Get("UI_AppSplitPanel/des")
	self._txtBtn = UIUtil.GetChildInComponents(txts, "txtLabel");
	self:_SetBtnLabel()
	self._btnPause = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnPause")
	local imgs = UIUtil.GetComponentsInChildren(self._trsContent, "UISprite");
	self._imgPress = UIUtil.GetChildInComponents(imgs, "imgPress");
	self._timer = Timer.New(function() self:Update() end, - 1, 0.1, true)
	self._timer:Start()
	
	self:_AddBtnListen(self._btnPause.gameObject)
end

function UI_AppSplitPanel2:_OnBtnsClick(go)	
	if go == self._btnPause.gameObject then
		self:_OnClickBtnPause()
	end
end


function UI_AppSplitPanel2:_OnClickBtnPause()
	if AppSplitDownProxy.puased then AppSplitDownProxy.Start()
	else AppSplitDownProxy.Pause() end
	self:_SetBtnLabel()	
end

function UI_AppSplitPanel2:_SetBtnLabel()
	self._txtBtn.text = AppSplitDownProxy.puased and
	LanguageMgr.Get("UI_AppSplitPanel/start") or LanguageMgr.Get("UI_AppSplitPanel/puase")
end

function UI_AppSplitPanel2:_InitListener()

end

function UI_AppSplitPanel2:Update()
	self._imgPress.width = 520 *(AppSplitDownProxy.process / 100)
	self._txtPress.text = AppSplitDownProxy.GetProcessDec()
end

function UI_AppSplitPanel2:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function UI_AppSplitPanel2:_DisposeListener()
	if self._timer then
		self._timer:Stop()
		self._timer = nil
	end
end

function UI_AppSplitPanel2:_DisposeReference()
	self._txtPress = nil;
	self._imgPress = nil;
end
return UI_AppSplitPanel2 