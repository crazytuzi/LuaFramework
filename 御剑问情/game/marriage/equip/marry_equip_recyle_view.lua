MarryEquipRecyleView = MarryEquipRecyleView or BaseClass(BaseView)

function MarryEquipRecyleView:__init()
	self.ui_config = {"uis/views/marriageview_prefab","MarryEquipAutoRecycle"}
	self.play_audio = true
end

function MarryEquipRecyleView:__delete()

end

function MarryEquipRecyleView:ReleaseCallBack()

end

function MarryEquipRecyleView:OpenCallBack()

end

function MarryEquipRecyleView:CloseCallBack()
	self.call_back = nil
end

function MarryEquipRecyleView:SetCallBack(call_back)
	self.call_back = call_back
end

function MarryEquipRecyleView:LoadCallBack()
	self:ListenEvent("CloseWindow",BindTool.Bind(self.Close, self))

	for i = 1, 4 do
		self:ListenEvent("OnClickBtn" .. i,BindTool.Bind(self.OnClickBtn, self, i))
	end
end

function MarryEquipRecyleView:OnClickBtn(i)
	if self.call_back then
		self.call_back(i)
	end
	self:Close()
end