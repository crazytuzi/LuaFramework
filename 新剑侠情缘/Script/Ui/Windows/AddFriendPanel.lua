local tbUi = Ui:CreateClass("AddFriendPanel");

function tbUi:OnOpen()
end

function tbUi:ClearAndClose()
	self.pPanel:Input_SetText("InputField", "")
	Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnCancel()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnApply()
	local nNow = GetTime()
	if self.nRequestTime  and self.nRequestTime == nNow then
		return
	end
	local szTextName = self.pPanel:Input_GetText("InputField")
	local nTextName = tonumber(szTextName)

	if szTextName == me.szName or szTextName == me.dwID then
		me.CenterMsg("不允许搜索自己")
		return
	end

	--Todo 下面的可以不要
	local tbAllFriend = FriendShip:GetAllFriendData() ;
	local bIsFriend = false;
	if nTextName then
		if tbAllFriend[nTextName] then
			bIsFriend = true;
		end
	else
		for i, v in ipairs(tbAllFriend) do
			if v.szName == szTextName then
				bIsFriend = true;
				break;
			end
		end
	end
	if bIsFriend then
		me.CenterMsg("他已经是你的好友了")
		return
	end

	if nTextName then
		FriendShip:RequetAddFriend(nTextName);	
	else
		RemoteServer.SearchRole(szTextName, true)
	end
	self.nRequestTime = nNow
end