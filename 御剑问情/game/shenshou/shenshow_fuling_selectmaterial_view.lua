FulingSelectMaterialView = FulingSelectMaterialView or BaseClass(BaseView)

function FulingSelectMaterialView:__init()
	self.ui_config = {"uis/views/shenshouview_prefab","FulingSelectMaterialView"}
	self.play_audio = true
end

function FulingSelectMaterialView:__delete()

end

function FulingSelectMaterialView:ReleaseCallBack()

end

function FulingSelectMaterialView:OpenCallBack()

end

function FulingSelectMaterialView:CloseCallBack()
	if self.close_call_back then
		self.close_call_back()
	end
	
	self.call_back = nil
	self.close_call_back = nil
end

function FulingSelectMaterialView:SetCloseCallBack(close_call_back)
	self.close_call_back = close_call_back
end

function FulingSelectMaterialView:SetCallBack(call_back)
	self.call_back = call_back
end

function FulingSelectMaterialView:LoadCallBack()
	self:ListenEvent("CloseWindow",BindTool.Bind(self.Close, self))

	for i = 1, 4 do
		self:ListenEvent("OnClickBtn" .. i,BindTool.Bind(self.OnClickBtn, self, i + 1))
	end
end

function FulingSelectMaterialView:OnClickBtn(i)
	if self.call_back then
		self.call_back(i)
	end
	self:Close()
end