local tbAct = Activity.NewYearChris or {}
Activity.NewYearChris = tbAct

tbAct.nWishTextMaxLen = 30	--愿望最长字数
if version_vn then
	tbAct.nWishTextMaxLen = 80
end

function tbAct:OnUpdateWishList(tbList)
	self.tbWishList = tbList
	UiNotify.OnNotify(UiNotify.emNOTIFY_NYC_WISHLIST_CHANGE)
end

function tbAct:UpdateWishList()
	self.tbWishList = self.tbWishList or {}
	RemoteServer.NewYearChrisReq("UpdateWishList", self.tbWishList.nVersion or 0)
end

function tbAct:AddWish(szText)
	if not szText or szText=="" then
		me.CenterMsg("愿望不能为空")
		return false
	end

	if Lib:Utf8Len(szText)>self.nWishTextMaxLen then
		me.CenterMsg(string.format("愿望最长%d字", self.nWishTextMaxLen))
		return false
	end

	if ReplaceLimitWords(szText) then
	  	me.CenterMsg("内容中含有敏感字符，请修改后重试")
  		return false
	end

	RemoteServer.NewYearChrisReq("AddWishText", szText)
	return true
end

function tbAct:MakeWish()
	RemoteServer.NewYearChrisReq("MakeWish")
end
