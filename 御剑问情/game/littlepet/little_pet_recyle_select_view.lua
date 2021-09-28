LittlePetRecycleSelectView = LittlePetRecycleSelectView or BaseClass(BaseView)

function LittlePetRecycleSelectView:__init()
	self.ui_config = {"uis/views/littlepetview_prefab","LittlePetAutoRecycle"}
	self.play_audio = true
end

function LittlePetRecycleSelectView:__delete()

end

function LittlePetRecycleSelectView:ReleaseCallBack()

end

function LittlePetRecycleSelectView:OpenCallBack()

end

function LittlePetRecycleSelectView:CloseCallBack()
	self.call_back = nil
end

function LittlePetRecycleSelectView:SetCallBack(call_back)
	self.call_back = call_back
end

function LittlePetRecycleSelectView:LoadCallBack()
	self:ListenEvent("CloseWindow",BindTool.Bind(self.Close, self))

	for i = 1, 4 do
		self:ListenEvent("OnClickBtn" .. i,BindTool.Bind(self.OnClickBtn, self, i))
	end
end

function LittlePetRecycleSelectView:OnClickBtn(i)
	if self.call_back then
		self.call_back(i)
	end
	self:Close()
end