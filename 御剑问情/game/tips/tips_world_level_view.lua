TipsWorldLevel = TipsWorldLevel or BaseClass(BaseView)

function TipsWorldLevel:__init()
	self.ui_config = {"uis/views/player_prefab", "TipsWorldLevel"}

	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function TipsWorldLevel:__delete()

end

function TipsWorldLevel:LoadCallBack()

	self:ListenEvent("Close", BindTool.Bind(self.CloseWindow, self))
end

function TipsWorldLevel:ReleaseCallBack()
	-- 清理变量和对象
end

function TipsWorldLevel:CloseWindow()
	self:Close()
end

function TipsWorldLevel:OpenCallBack()
	self:FindVariable("WorldOpenLevel"):SetValue(self.worldOpenLevel) 
	self:FindVariable("WorldLevel"):SetValue(self.worldLevel) 
	self:FindVariable("ExpPercent"):SetValue(self.expPercent) 
end

function TipsWorldLevel:SetData(worldOpenLevel, worldLevel, expPercent)
	self.worldOpenLevel = worldOpenLevel or 0 
	self.worldLevel = worldLevel or 0 
	self.expPercent = expPercent or 0 
	if self:FindVariable("WorldOpenLevel") ~= nil then
		self:FindVariable("WorldOpenLevel"):SetValue(self.worldOpenLevel) 
	end
	if self:FindVariable("WorldLevel") ~= nil then
	self:FindVariable("WorldLevel"):SetValue(self.worldLevel) 
	end
	if self:FindVariable("ExpPercent") ~= nil then
	self:FindVariable("ExpPercent"):SetValue(self.expPercent) 
	end
end

function TipsWorldLevel:OnFlush()
end