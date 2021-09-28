Start = BaseClass(LuaUI)

function Start:__init( ... )
	self.URL = "ui://d3en6n1nlqpc1m";
	self:__property(...)
	self:Config()
end

-- Set self property
function Start:SetProperty( ... )
end

-- start
function Start:Config()
	
end

-- wrap UI to lua
function Start:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Wing","Start");

	self.down = self.ui:GetChild("down")
	self.up = self.ui:GetChild("up")
	self.role3D = self.ui:GetChild("role3D")
	self.moveRole3D = self.ui:GetChild("moveRole3D")

	self:UnLight()

	self.isDestroy = false

	self.moveEft = "4102" 
	self.bompEft = "4615"
	
	self.bompEftEntityId = nil

	self.moveStartPos = Vector2.New(23, 23)
end

-- Combining existing UI generates a class
function Start.Create( ui, ...)
	return Start.New(ui, "#", {...})
end

function Start:Light(bomp)
	self.up.visible = true
	self.down.visible = false
	if bomp then
		self:BompEft()
	end
end

function Start:UnLight()
	self.up.visible = false
	self.down.visible = true

	self:RemoveBompEft()
end

function Start:RemoveBompEft()
	if self.bompEftEntityId then
		EffectMgr.RealseEffect(self.bompEftEntityId)
		self.bompEftEntityId = nil
	end
end

function Start:BompEft()
	self.bompEftEntityId = EffectMgr.AddToUI(self.bompEft, self.role3D, nil, pos, scale, eulerAngles, id, function(eft)
				end)
end

function Start:FlyTo(targetPos, duration, flyCallBack)
	self.moveRole3D.x = self.moveStartPos.x
	self.moveRole3D.y = self.moveStartPos.y
	self.moveRole3D.visible = true
	local targetPos = self.ui:GlobalToLocal(targetPos)
	local cost = duration
	local callBack = flyCallBack
	EffectMgr.AddToUI(self.moveEft, self.moveRole3D, nil, pos, scale, eulerAngles, id, function(eft)
			self.eft = eft
			if self.closing and self.eft then destroyImmediate(self.eft) return end
			if self.posTweener then
				TweenUtils.Kill(self.posTweener, true)
				self.posTweener = nil
			end
			self.posTweener = TweenUtils.TweenVector2(self.moveStartPos, targetPos, duration, function(data)
				if self.closing and self.eft then destroyImmediate(self.eft) return end
				self.moveRole3D.x = data.x
				self.moveRole3D.y = data.y
			end)
			TweenUtils.SetEase(self.posTweener, 21)
			TweenUtils.OnComplete(self.posTweener, function ()
				if self.closing and self.eft then destroyImmediate(self.eft) return end
				if self.moveRole3D then
					self.moveRole3D.visible = false
				end 
				if callBack then
					callBack()
				end
			end, self.posTweener)
		end)

end

function Start:__delete()
	self.closing = true
	if self.eft then
		destroyImmediate(self.eft)
	end
	self:RemoveBompEft()
end