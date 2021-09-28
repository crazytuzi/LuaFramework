require "Core.Module.Common.Panel"

GotoGamePanel = Panel:New();

function GotoGamePanel:_Init()
	self:_InitReference();
	self:_InitListener();
	self._txtServer.text = ""
	self._lastClickTime = 0
	self:UpdateGoToGamePanel()
    
    if GameConfig.instance.autoLogin then LoginProxy.TryConnect()  end
end

function GotoGamePanel:GetUIOpenSoundName()
	return ""
end

function GotoGamePanel:_InitReference()
	self._btnGotoGame = UIUtil.GetChildByName(self._trsContent, "UIButton", "trsOpt/btnGotoGame");
	self._txtServer = UIUtil.GetChildByName(self._trsContent, "UILabel", "trsOpt/trsServer/txtServer");
	self._icoNew = UIUtil.GetChildByName(self._trsContent, "UISprite", "trsOpt/trsServer/icoStatus");
	self._btnSelectServer = UIUtil.GetChildByName(self._trsContent, "UILabel", "trsOpt/trsServer/txtSelectServer");
	
	-- self._btnBack = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnBack");
end

function GotoGamePanel:_InitListener()
	self._onClickBtnGotoGame = function(go) self:_OnClickBtnGotoGame(self) end
	UIUtil.GetComponent(self._btnGotoGame, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGotoGame);
	self._onClickBtnSelectServer = function(go) self:_OnClickBtnSelectServer(self) end
	UIUtil.GetComponent(self._btnSelectServer, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSelectServer);
	-- self._onClickBtnBack = function(go) self:_OnClickBtnBack(self) end
	-- UIUtil.GetComponent(self._btnBack, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnBack);
	MessageManager.AddListener(LoginNotes, LoginNotes.UPDATE_GOTOGAME_PANEL, GotoGamePanel.UpdateGoToGamePanel, self);
end

function GotoGamePanel:_OnClickBtnGotoGame()
	if(os.time() - self._lastClickTime > 1) then
		self._lastClickTime = os.time()
		LoginProxy.TryConnect();
	else
		log("间隔时间不足1秒")
		return
	end	
end

function GotoGamePanel.ConnectSuccess(statu, err)
	if statu == SocketClientLua.EVENT_CONNECTION_SUCCEED then
		ModuleManager.SendNotification(LoginNotes.CLOSE_GOTOGAME_PANEL)
		ModuleManager.SendNotification(SelectRoleNotes.OPEN_SELECTROLE_PANEL)
	end
end

function GotoGamePanel:_OnClickBtnSelectServer()
	ModuleManager.SendNotification(LoginNotes.OPEN_SELECTSERVER_PANEL)
end

function GotoGamePanel:_OnClickBtnBack()
	
end

function GotoGamePanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function GotoGamePanel:_DisposeListener()
	UIUtil.GetComponent(self._btnGotoGame, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnGotoGame = nil;
	UIUtil.GetComponent(self._btnSelectServer, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnSelectServer = nil;
	-- UIUtil.GetComponent(self._btnBack, "LuaUIEventListener"):RemoveDelegate("OnClick");
	-- self._onClickBtnBack = nil;
	MessageManager.RemoveListener(LoginNotes, LoginNotes.UPDATE_GOTOGAME_PANEL, GotoGamePanel.UpdateGoToGamePanel);
end

function GotoGamePanel:_DisposeReference()
	self._btnGotoGame = nil;
	self._btnSelectServer = nil;
	-- self._icoStatus = nil
	-- self._btnBack = nil;
end

function GotoGamePanel:IsPopup()
	return false;
end

function GotoGamePanel:UpdateGoToGamePanel()
	local svr = LoginProxy:GetCurrentServerInfo()	
	
	if(svr) then
		self._icoNew.gameObject:SetActive(svr.icon ~= 0);
		if(svr.icon == 1) then
			self._icoNew.spriteName = "serverHot"
		elseif svr.icon == 2 then
			self._icoNew.spriteName = "serverTuijian"
		elseif svr.icon == 3 then
			self._icoNew.spriteName = "serverNew"
		end
		self._txtServer.text = svr.name;
		-- self._icoStatus.spriteName = "serverSt" .. svr.status;
	else
		self._icoNew.gameObject:SetActive(false);
		self._txtServer.text = ""
		-- self._icoStatus.spriteName = ""
	end
end 