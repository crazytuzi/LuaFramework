require "Core.Module.Common.UIItem"

ServerItem = UIItem:New();

function ServerItem:Init(gameObject, data)
	self.gameObject = gameObject
	self._txtZoneName = UIUtil.GetChildByName(self.gameObject.transform, "UILabel", "Label");
	self._icoSelect = UIUtil.GetChildByName(self.gameObject.transform, "UISprite", "icoSelect");
	self._icoStatus = UIUtil.GetChildByName(self.gameObject.transform, "UISprite", "icoStatus");
	self._icoNew = UIUtil.GetChildByName(self.gameObject.transform, "UISprite", "icoNew");
	self._trsRole = UIUtil.GetChildByName(self.gameObject.transform, "Transform", "trsRole");
	self._icoRole = UIUtil.GetChildByName(self._trsRole, "UISprite", "icoHead");
	self._txtLv = UIUtil.GetChildByName(self._trsRole, "UILabel", "txtLv");
	self._imgLevelBg = UIUtil.GetChildByName(self._txtLv, "UISprite", "bg")
	self.data = data;
	
	self._onClickBtn = function(go) self:_OnClickBtn(self) end
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);
	
	self:UpdateItem(data);
end

function ServerItem:UpdateItem(data)
	self.data = data
	self._txtZoneName.text = self.data.name;
	self._icoStatus.spriteName = "serverSt" .. data.status;
	
	self._icoNew.gameObject:SetActive(self.data.icon ~= 0);
	if(self.data.icon == 1) then
		self._icoNew.spriteName = "serverHot"
	elseif self.data.icon == 2 then
		self._icoNew.spriteName = "serverTuijian"
	elseif self.data.icon == 3 then
		self._icoNew.spriteName = "serverNew"
	end
	
	local role = LoginManager.GetSvrRole(data.id);
	if role then
		self._icoRole.spriteName = role.kind;
		self._txtLv.text = GetLv(role.lv) .. "";
		self._imgLevelBg.spriteName = role.lv <= 400 and "levelBg1" or "levelBg2"
		self._imgLevelBg:MakePixelPerfect()
		self._trsRole.gameObject:SetActive(true);
	else
		self._trsRole.gameObject:SetActive(false);
	end
	
	self:UpdateSelected();
end

function ServerItem:_OnClickBtn()
	LoginProxy.currentServerIndex = self.data.id;
	MessageManager.Dispatch(LoginNotes, LoginNotes.UPDATE_GOTOGAME_PANEL);
	LoginManager.SetCurrentServer(self.data)
	PlayerManager.SubmitExtraData(1)
	ModuleManager.SendNotification(LoginNotes.CLOSE_SELECTSERVER_PANEL);
end

function ServerItem:_Dispose()
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn = nil;
end

function ServerItem:UpdateSelected()
	self._icoSelect.gameObject:SetActive(self.data.id == LoginProxy.currentServerIndex);
end 