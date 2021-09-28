TipsFashionAttr = TipsFashionAttr or BaseClass(BaseView)

function TipsFashionAttr:__init()
	self.ui_config = {"uis/views/player_prefab", "TipsFashionAttr"}

	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function TipsFashionAttr:__delete()

end

function TipsFashionAttr:LoadCallBack()
	self.str = self:FindVariable("Str")

	self:ListenEvent("Close", BindTool.Bind(self.CloseWindow, self))
end

function TipsFashionAttr:ReleaseCallBack()
	-- 清理变量和对象
end

function TipsFashionAttr:CloseWindow()
	self:Close()
end

function TipsFashionAttr:OpenCallBack()
	self:FindVariable("attack"):SetValue(self.attackAttr) 
	self:FindVariable("defense"):SetValue(self.defenseAttr) 
	self:FindVariable("hp"):SetValue(self.hpAttr) 
	self:FindVariable("power"):SetValue(self.powerAttr)
	self:FindVariable("title"):SetValue(self.titleAttr)
	self:Flush()
end

function TipsFashionAttr:SetData(attack, defense, hp, power, title)
	self.attackAttr = attack or 0 
	self.defenseAttr = defense or 0 
	self.hpAttr = hp or 0 
	self.powerAttr = power or 0 
	self.titleAttr = title or 0
	if self:FindVariable("attack") ~= nil then
		self:FindVariable("attack"):SetValue(self.attackAttr) 
	end
	if self:FindVariable("defense") ~= nil then
	self:FindVariable("defense"):SetValue(self.defenseAttr) 
	end
	if self:FindVariable("hp") ~= nil then
	self:FindVariable("hp"):SetValue(self.hpAttr) 
	end
	if self:FindVariable("power") ~= nil then
	self:FindVariable("power"):SetValue(self.powerAttr)
	end
	if self:FindVariable("title") ~= nil then
	self:FindVariable("title"):SetValue(self.titleAttr)
	end
end

function TipsFashionAttr:OnFlush()
end