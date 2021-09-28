TrumpetMsgUI = BaseClass(LuaUI)

function TrumpetMsgUI:__init(...)
	self.URL = "ui://0tyncec1rfrrnms";
	self:__property(...)
	self:Config()

	self.msgList = {}
	self.isRolling = false
	self.isFadeIning = false
	self.bannerHasShow = false
	self.duration = 10
end

function TrumpetMsgUI:SetProperty(...)
end

function TrumpetMsgUI:Config()
end

function TrumpetMsgUI:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Common","TrumpetMsgUI");
	self.mask = self.ui:GetChild("mask")
	self.bg = self.ui:GetChild("bg")
	self.content = self.ui:GetChild("content")
end

function TrumpetMsgUI:AddMsg(msg)
	table.insert(self.msgList, msg)
	if not self.isRolling then self:RollMsg() end
end

function TrumpetMsgUI:RollMsg()
	if not self.content then return end
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
	local size = self.content.textFormat.size + 2
	self.content.text = string.gsub(getRichTextContent(msg), "<img ", "<img width="..size.." height="..size.." ")
	self.content.x = self.mask.x + self.mask.width + 30
	local toX = self.mask.x - self.content.textWidth - 30
	self.isRolling = true
	local tweener = TweenUtils.TweenFloat(self.content.x, toX, self.duration, function(data)
		if not self.ui then return end
		self.content.x = data
	end)
	TweenUtils.OnComplete(tweener, function () self:RollMsg() end, tweener)
end

function TrumpetMsgUI:RollMsg2()
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
	self.content.text = msg

	self.content.y = self.mask.y + self.mask.height + 30
	local toY = 2
	self.isRolling = true
	local tweener = TweenUtils.TweenFloat(self.content.y, toY, 1.5, function(data)
			if not self.ui then return end
			self.content.y = data
		end)
	TweenUtils.OnComplete(tweener, function ()
		DelayCall(function()
			local tweener2 = TweenUtils.TweenFloat(self.content.y, -30, 1, function(data)
					if not self.ui then return end
					self.content.y = data
				end)
			TweenUtils.OnComplete(tweener2, function()
		 			self:RollMsg2() 
				end, tweener2)
		end, 2)
	end, tweener)
end

function TrumpetMsgUI:FadeIn()
	self:SetVisible(true)
	--淡入
	self.ui.alpha = 0
	self.isFadeIning = true
	local tweener = TweenUtils.TweenFloat(0, 1, 0.3, function(data)
		if not self.ui then return end
		self.ui.alpha = data
	end)
	TweenUtils.OnComplete(tweener, function()
		if not self.ui then return end
		self:RollMsg()
		self.bannerHasShow = true
		self.isFadeIning = false
	end, tweener)
end

function TrumpetMsgUI:FadeOut()
	--淡出
	self.ui.alpha = 1
	local tweener = TweenUtils.TweenFloat(1, 0, 0.3, function(data) 
		if not self.ui then return end
		self.ui.alpha = data
	end)
	TweenUtils.OnComplete(tweener, function()
		if not self.ui then return end
		self:SetVisible(false)
		self.bannerHasShow = false
	end, tweener)
end

-- Combining existing UI generates a class
function TrumpetMsgUI.Create( ui, ...)
	return TrumpetMsgUI.New(ui, "#", {...})
end

-- Dispose use TrumpetMsgUI obj:Destroy()
function TrumpetMsgUI:__delete()
	self.content = nil
	self.mask = nil
end