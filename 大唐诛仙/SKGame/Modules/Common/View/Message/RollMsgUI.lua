RollMsgUI =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function RollMsgUI:__init( ... )
	self.URL = "ui://0tyncec1rdc8bs";
	self:__property(...)
	self:Config()

	self.msgList = {}
	self.isRolling = false
	self.isFadeIning = false
	self.bannerHasShow = false
	self.duration = 10
end

-- Set self property
function RollMsgUI:SetProperty( ... )
	
end

-- Logic Starting
function RollMsgUI:Config()
	
end

-- Register UI classes to lua
function RollMsgUI:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Common","RollMsgUI");

	self.mark = self.ui:GetChild("mark")
	self.msgInfo = self.ui:GetChild("msgInfo")
end

function RollMsgUI:AddMsg(msg)
	table.insert(self.msgList, msg)
	if not self.isRolling then
		if self.ui == nil then return end 
		self:RollMsg()
	end
end

function RollMsgUI:RollMsg()
	if not self.bannerHasShow and not self.isFadeIning then 
		self:FadeIn()
		return
	end
	if #self.msgList < 1 then 
		self.isRolling = false
		self:FadeOut()
		return 
	end
	local msg = table.remove(self.msgList,1)
	if self.msgInfo then
		self.msgInfo.text = msg
		self.msgInfo.x = self.mark.x + self.mark.width + 30
		local toX = self.mark.x - self.msgInfo.textWidth - 30
		self.isRolling = true
		local tweener = TweenUtils.TweenFloat(self.msgInfo.x, toX, self.duration, 
			function(data)
				if not self.msgInfo then return end
				self.msgInfo.x = data
			end)
		TweenUtils.OnComplete(tweener, function () self:RollMsg() end, tweener)
	else
		self:FadeOut()
	end
end

function RollMsgUI:FadeIn()
	if self.ui == nil then return end
	self:SetVisible(true)
	--淡入
	self.ui.alpha = 0
	self.isFadeIning = true
	local tweener = TweenUtils.TweenFloat(0, 1, 0.3, function(data) 
		if self.ui == nil then return end
		self.ui.alpha = data
	end)
	TweenUtils.OnComplete(tweener, function()
		if self.ui == nil then return end
		self:RollMsg()
		self.bannerHasShow = true
		self.isFadeIning = false
	end, tweener)
end

function RollMsgUI:FadeOut()
	if self.ui == nil then return end
	--淡出
	self.ui.alpha = 1
	local tweener = TweenUtils.TweenFloat(1, 0, 0.3, function(data) 
		if self.ui == nil then return end
		self.ui.alpha = data
	end)
	TweenUtils.OnComplete(tweener, function()
		if self.ui == nil then return end
		self:SetVisible(false)
		self.bannerHasShow = false
	end, tweener)
end

-- Combining existing UI generates a class
function RollMsgUI.Create( ui, ...)
	return RollMsgUI.New(ui, "#", {...})
end

-- Dispose use RollMsgUI obj:Destroy()
function RollMsgUI:__delete()
	self.msgInfo = nil
	self.mark = nil
end