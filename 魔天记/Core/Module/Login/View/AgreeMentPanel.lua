require "Core.Module.Common.Panel"

local AgreeMentPanel = class("AgreeMentPanel", Panel);
function AgreeMentPanel:New()
	self = {};
	setmetatable(self, {__index = AgreeMentPanel});
	return self
end


function AgreeMentPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function AgreeMentPanel:_InitReference()
	self._btnOk = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnOk");
	self._toggle1 = UIUtil.GetChildByName(self._trsContent, "UIToggle", "checkBox1")
	self._toggle2 = UIUtil.GetChildByName(self._trsContent, "UIToggle", "checkBox2")
	
	self._toggle1.value = false
	self._toggle1.value = false
	self._btnOk.isEnabled = false
end

function AgreeMentPanel:_InitListener()
	self:_AddBtnListen(self._btnOk.gameObject)
	self:_AddBtnListen(self._toggle1.gameObject)
	self:_AddBtnListen(self._toggle2.gameObject)	
	
end

function AgreeMentPanel:_OnBtnsClick(go)
	if go == self._btnOk.gameObject then
		self:_OnClickBtnOk()		
	elseif go == self._toggle1.gameObject then
		self:_OnClickBtnToggle1()		
	elseif go == self._toggle2.gameObject then
		self:_OnClickBtnToggle2()
	end
end

function AgreeMentPanel:_OnClickBtnOk()
	ModuleManager.SendNotification(LoginNotes.CLOSE_AGREENMENTPANEL)
end

function AgreeMentPanel:_OnClickBtnToggle1()
	self._btnOk.isEnabled = self._toggle1.value and self._toggle2.value 
end

function AgreeMentPanel:_OnClickBtnToggle2()
	self._btnOk.isEnabled = self._toggle1.value and self._toggle2.value
end

function AgreeMentPanel:_Dispose()
	self:_DisposeReference();
end

function AgreeMentPanel:_DisposeReference()
	self._btnOk = nil;
end
return AgreeMentPanel 