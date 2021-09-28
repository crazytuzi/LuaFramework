MultyHit =BaseClass(LuaUI)

MultyHit.hitNum = 0

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function MultyHit:__init( ... )
	self.URL = "ui://0tyncec1rdc8bx";
	self:__property(...)
	self:Config()
	self:InitEvent()

	self:SetVisible(false)
end

-- Set self property
function MultyHit:SetProperty( ... )
	
end

-- Logic Starting
function MultyHit:Config()
	
end

function MultyHit:GetInstance()
	if MultyHit.inst == nil then
		MultyHit.inst = MultyHit.New()
		MultyHit.inst:Init()
	end
	return MultyHit.inst
end

function MultyHit:Init()
	layerMgr:GetMSGLayer():AddChild(self.ui)
end

-- Register UI classes to lua
function MultyHit:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Common","MultyHit");
	self.multyHitItem = self.ui:GetChild("multyHitItem")
	self.multyHitItem = MultyHitItem.Create(self.multyHitItem)

	self.title = self.multyHitItem.title
	self.hitAnimation = self.multyHitItem.hitAnimation
end

function MultyHit:InitEvent()
	--定时器
	self.hitTime = Timer.New(function ()
			self._time1 = self._time1 - 0.1
			if self._time1 <= 0 then
				self:SetVisible(false)
				MultyHit.hitNum= 0
				self.hitTime:Stop()
			end
		end, 0.1, -1)
end

function MultyHit:PlayAni()
	self:SetVisible(true)
	self.hitAnimation:Play()
	self._time1 = 2.5
	if MultyHit.hitNum == 0 then
		self.hitTime:Start()
	end
	MultyHit.hitNum = MultyHit.hitNum + 1
	self.title.text = MultyHit.hitNum
end

-- Combining existing UI generates a class
function MultyHit.Create( ui, ...)
	return MultyHit.New(ui, "#", {...})
end

-- Dispose use MultyHit obj:Destroy()
function MultyHit:__delete()
	if self.multyHitItem then
		self.multyHitItem:Destroy()
	end
	self.multyHitItem = nil
	MultyHit.inst = nil
end