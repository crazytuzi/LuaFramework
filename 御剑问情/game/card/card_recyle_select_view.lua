CardRecyleSelectView = CardRecyleSelectView or BaseClass(BaseView)

function CardRecyleSelectView:__init()
	self.ui_config = {"uis/views/cardview_prefab","CardAutoRecycle"}
	self.play_audio = true
end

function CardRecyleSelectView:__delete()

end

function CardRecyleSelectView:ReleaseCallBack()

end

function CardRecyleSelectView:OpenCallBack()

end

function CardRecyleSelectView:CloseCallBack()
	self.call_back = nil
end

function CardRecyleSelectView:SetCallBack(call_back)
	self.call_back = call_back
end

function CardRecyleSelectView:LoadCallBack()
	self:ListenEvent("CloseWindow",BindTool.Bind(self.Close, self))

	for i = 1, 4 do
		self:ListenEvent("OnClickBtn" .. i,BindTool.Bind(self.OnClickBtn, self, i))
	end
end

function CardRecyleSelectView:OnClickBtn(i)
	if self.call_back then
		self.call_back(i)
	end
	self:Close()
end