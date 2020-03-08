local tbUi = Ui:CreateClass("FriendApplyPanel");

function tbUi:OnOpen()
	local tbAllRequet = FriendShip:GetAllFriendRequestData() --不会空
	self.tbAllRequet = tbAllRequet;
	
	local fnSetFriend = function (itemClass, index)
		
		itemClass:SetData(tbAllRequet[index])
		
	end
	self.ScrollView:Update(tbAllRequet, fnSetFriend);
end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnDelete()
	if not self.tbAllRequet or #self.tbAllRequet == 0 then
		me.CenterMsg("暂无可清空的信息")
		return
	end
	local fnYes = function ()
    	FriendShip:RefuseAllRequet()
	    self:OnOpen();
	end

	Ui:OpenWindow("MessageBox",
	  "您确定要清空申请列表吗？",
	 { {fnYes},{} }, 
	 {"确定", "取消"});
	
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNoTIFY_SYNC_FRIEND_DATA, self.OnOpen },		
	};

	return tbRegEvent;
end

