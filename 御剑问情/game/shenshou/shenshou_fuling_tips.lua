FulingTips = FulingTips or BaseClass(BaseView)
function FulingTips:__init()
	self.ui_config = {"uis/views/shenshouview_prefab","FulingTips"}
	self.play_audio = true
end

function FulingTips:__delete()

end

function FulingTips:ReleaseCallBack()	
	self.open_call_back = nil
	self.close_call_back = nil
	self.content = nil
end

function FulingTips:SetCloseCallBack(close_call_back)
	self.close_call_back = close_call_back
end

function FulingTips:SetOpenCallBack(call_back)
	self.open_call_back = call_back
end

function FulingTips:LoadCallBack()
	self.content = self:FindVariable("Content")
	self:ListenEvent("ClickBtn", BindTool.Bind(self.ClickBtn, self))
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))	
end

function FulingTips:OpenCallBack()
	self.content = self:FindVariable("Content")
	if self.open_call_back then
		local cost, shuliandu = self.open_call_back()
		self.cost = shuliandu / cost
		self.cost = math.floor(self.cost)
	end
	local str = string.format(Language.ShenShou.FulingTips, self.cost)
	self.content:SetValue(str)
end

function FulingTips:CloseCallBack()
	self.content = nil
end

function FulingTips:ClickBtn()
	if self.close_call_back then
		self.close_call_back()
	end
	self:Close()
end

function FulingTips:CloseWindow()
	self:Close()
end