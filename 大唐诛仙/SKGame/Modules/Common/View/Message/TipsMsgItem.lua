TipsMsgItem =BaseClass(LuaUI)
TipsMsgItem.duration = 0.9
function TipsMsgItem:__init( ... )
	self.URL = "ui://0tyncec1rdc8bu";
	self:__property(...)

	self.playCallBack = nil
	self.inited = true
	self:AddEvent()
end

function TipsMsgItem:SetProperty( ... )
	
end
function TipsMsgItem:Config()
end

function TipsMsgItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Common","TipsMsgItem");
	self.bg = self.ui:GetChild("bg")
	self.title = self.ui:GetChild("title")
end

function TipsMsgItem:AddEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function()  --全局事件
		self.inited = false
	end)
end

function TipsMsgItem:Reset(msg,parent)
	if not self.inited then return end
	if (not parent) or (not self) or (ToLuaIsNull(self.ui)) then return end
	self.title.text = getRichTextContent(msg)

	local x = (parent.ui.width - self.ui.width)*0.5
	local y = parent.ui.height
	local w = self.ui.width
	local h = self.ui.height
	self:AddTo(parent.ui, x, y, w, h, true)
	self:SetVisible(true)
end

function TipsMsgItem:Play(playCallBack)
	if not self.inited then return end
	self.playCallBack = playCallBack
	
	local toY = self.ui.y  - 200
	local posTweener = TweenUtils.TweenFloat(self.ui.y, toY, TipsMsgItem.duration, function(data)
		if not self.inited then return end
		self.ui.y = data
	end)
	TweenUtils.SetEase(posTweener, 21)
	TweenUtils.OnComplete(posTweener, function ()
		if not self.inited then return end
		self:Finish()
	end, posTweener)

	self.ui.alpha = 0
	local alphaTweener = TweenUtils.TweenFloat(0, 1, TipsMsgItem.duration*0.7, function(data)
		if not self.inited then return end
		self.ui.alpha = data
	end)
	TweenUtils.SetEase(alphaTweener, 1)
end

function TipsMsgItem:Finish()
	if not self.inited then return end
	if ToLuaIsNull(self.ui) then return end
	TipsMsgUI.BacktoTipsItemPool(self)
	self:SetVisible(false)
	if self.playCallBack ~= nil then 
		pcall(self.playCallBack)
		self.playCallBack = nil
	end
end

function TipsMsgItem.Create( ui, ...)
	return TipsMsgItem.New(ui, "#", {...})
end

function TipsMsgItem:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	self.inited = false
	self.bg = nil
	self.title = nil
	TipsMsgItem.duration = 0.9
end