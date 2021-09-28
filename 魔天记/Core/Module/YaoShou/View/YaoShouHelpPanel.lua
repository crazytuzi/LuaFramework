local YaoShouHelpPanel = class("YaoShouHelpPanel", Panel);


function YaoShouHelpPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function YaoShouHelpPanel:_InitReference()
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

	local txtTitle = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTitle");
	txtTitle.text = LanguageMgr.Get("YaoShouBoss/help/title")
	--[[
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
	]]
	local txt_text3 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_text3");
	txt_text3.text = LanguageMgr.Get("YaoShouBoss/help")
end

function YaoShouHelpPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function YaoShouHelpPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(YaoShouNotes.CLOSE_YAOSHOU_HELP_PANEL)
end

function YaoShouHelpPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function YaoShouHelpPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
end

function YaoShouHelpPanel:_DisposeReference()
	self._btn_close = nil;
end

return YaoShouHelpPanel;