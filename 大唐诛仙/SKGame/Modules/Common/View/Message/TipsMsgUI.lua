TipsMsgUI =BaseClass(LuaUI)

TipsMsgUI.tipsItemPool = {}

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function TipsMsgUI:__init( ... )
	self.URL = "ui://0tyncec1rdc8bt";
	self:__property(...)
	self:Config()

	self.msgList = {}
	

	self.isPlayingTips = false
	self.inited = true
end

-- Set self property
function TipsMsgUI:SetProperty( ... )
	
end

-- Logic Starting
function TipsMsgUI:Config()
	
end

-- Register UI classes to lua
function TipsMsgUI:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Common", "TipsMsgUI");

	self.test = self.ui:GetChild("test")
end

function TipsMsgUI.GetTipsItemFromPool()
	local tipsItem
	if #TipsMsgUI.tipsItemPool < 1 then 
		tipsItem = TipsMsgItem.New()
	else
		tipsItem = table.remove(TipsMsgUI.tipsItemPool, 1)
	end
	
	return tipsItem
end

function TipsMsgUI.BacktoTipsItemPool(item)
	table.insert(TipsMsgUI.tipsItemPool, item)
end

function TipsMsgUI:AddMsg(msg)
	if not self.inited then return end
	if #self.msgList > 20 then
		table.remove(self.msgList, 1)
	end
	table.insert(self.msgList, msg)

	if not self.isPlayingTips then 
		self:PlayTips() 
	end
end

function TipsMsgUI:PlayTips()
	if not self.inited then return end
	if #self.msgList < 1 then 
		self.isPlayingTips = false
		return 
	end
	local msg = table.remove(self.msgList, 1)
	local tipsItem = TipsMsgUI.GetTipsItemFromPool()
	tipsItem:Reset(msg, self)
	tipsItem:Play(
		function()
			if not self.inited then return end
			if #self.msgList < 1 then 
				self.isPlayingTips = false
				return 
			end
	end)
	self.isPlayingTips = true
	DelayCall(function()
		if not self.inited then return end
		self:PlayTips() 
	end, TipsMsgItem.duration*0.5)
end

-- Combining existing UI generates a class
function TipsMsgUI.Create( ui, ...)
	return TipsMsgUI.New(ui, "#", {...})
end

-- Dispose use TipsMsgUI obj:Destroy()
function TipsMsgUI:__delete()
	self.inited = false
	self.msgList = nil
	for i,v in pairs(TipsMsgUI.tipsItemPool) do
		v:Destroy()
	end
	TipsMsgUI.tipsItemPool = {}
end