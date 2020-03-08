local tbUi = Ui:CreateClass("WantedTips");
-- 窗口打不开

function tbUi:OnOpen(dwWantedId, szWantedName)
	self.pPanel:Label_SetText("txtContent", string.format(
		"[FFFE0D]%s[-] 在野外地图击杀了你，你可以发布通缉，让你的好友和家族成员对他进行抓捕。", szWantedName))
	self.dwWantedId = dwWantedId
	self.szWantedName = szWantedName
	if self.nTimer then
		Timer:Close(self.nTimer)
	end
	self.nTimer = Timer:Register(Env.GAME_FPS * 600, Ui.CloseWindow, Ui, "WantedTips")
end


function tbUi:OnClose()
	self.dwWantedId = nil
	self.szWantedName = nil
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil;
	end
end




tbUi.tbOnClick = {};

tbUi.tbOnClick.BtnWantedShort = function (self)
	--发布通缉时服务器上检查了是不是好友或者同家族的
	local fnAgree = function ()
		RemoteServer.RequestWanted(self.dwWantedId, FriendShip.nWantedTimeShort)
		Ui:CloseWindow("WantedTips")
	end
	Ui:OpenWindow("MessageBox",
	 string.format("你是否要对 [FFFE0D]%s[-] 发起持续 [FFFE0D]%s[-] 的通缉？", self.szWantedName , Lib:TimeDesc(FriendShip.nWantedTimeShort)),
	 { {fnAgree}, {}  }, 
	 {"同意", "取消"});

end

tbUi.tbOnClick.BtnWantedLong = function (self)
	if me.GetMoney("Gold") < FriendShip.nWantedLongCost then
		me.CenterMsg("您的元宝不足了")
		Ui:CloseWindow(self.UI_NAME)
		Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
		return
	end

	local fnAgree = function ()
		RemoteServer.RequestWanted(self.dwWantedId, FriendShip.nWantedTimeLong)
		Ui:CloseWindow("WantedTips")
	end
	Ui:OpenWindow("MessageBox",
	 string.format("你是否要对 [FFFE0D]%s[-] 发起持续 [FFFE0D]%s[-] 的通缉？需要消耗 [FFFE0D]%d元宝[-]", self.szWantedName , 
	 	Lib:TimeDesc(FriendShip.nWantedTimeLong), FriendShip.nWantedLongCost),
	 { {fnAgree}, {}  }, 
	 {"同意", "取消"});
end

tbUi.tbOnClick.BtnCancel = function (self)
	Ui:CloseWindow("WantedTips")
end


