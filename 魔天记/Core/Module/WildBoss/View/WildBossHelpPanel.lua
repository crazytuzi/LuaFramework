require "Core.Module.Common.Panel"

WildBossHelpPanel = class("WildBossHelpPanel", Panel);
function WildBossHelpPanel:New()
	self = { };
	setmetatable(self, { __index = WildBossHelpPanel });
	return self
end 

function WildBossHelpPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function WildBossHelpPanel:_InitReference()
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

	local txtTitle = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTitle");
	txtTitle.text = LanguageMgr.Get("WildBoss/help/title")

	local txt_title1 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_title1");
	txt_title1.text = LanguageMgr.Get("WildBoss/help/title1")

	local txt_title2 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_title2");
	txt_title2.text = LanguageMgr.Get("WildBoss/help/title2")

	local txt_title3 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_title3");
	txt_title3.text = LanguageMgr.Get("WildBoss/help/title3")

	local txt_text1 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_text1");
	txt_text1.text = LanguageMgr.Get("WildBoss/help/text1")

	local txt_text2 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_text2");
	txt_text2.text = LanguageMgr.Get("WildBoss/help/text2")

	local txt_text3 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_text3");
	txt_text3.text = LanguageMgr.Get("WildBoss/help/text3")
end

function WildBossHelpPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function WildBossHelpPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(WildBossNotes.CLOSE_WILDBOSSHELPPANEL)
end

function WildBossHelpPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function WildBossHelpPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
end

function WildBossHelpPanel:_DisposeReference()
	self._btn_close = nil;
end