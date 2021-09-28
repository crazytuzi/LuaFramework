PoPFinishFB =BaseClass(LuaUI)
function PoPFinishFB:__init( ... )
	self.URL = "ui://wetrdvlhotx720";
	self:__property(...)
	self:Config()
end
function PoPFinishFB:SetProperty( ... )
	
end
function PoPFinishFB:Config()
	
end
function PoPFinishFB:RegistUI( ui )
	resMgr:AddUIAB("FB")
	self.ui = ui or self.ui or UIPackage.CreateObject("FB","PoPFinishFB");

	self.victoryBg = self.ui:GetChild("victoryBg")
	self.vRole3D = self.ui:GetChild("vRole3D")
	self.n2 = self.ui:GetChild("n2")
	self.victoryText = self.ui:GetChild("victoryText")
	self.victory = self.ui:GetChild("victory")
	self.defeatedBg = self.ui:GetChild("defeatedBg")
	self.dRole3D = self.ui:GetChild("dRole3D")
	self.n11 = self.ui:GetChild("n11")
	self.n12 = self.ui:GetChild("n12")
	self.victoryText_2 = self.ui:GetChild("victoryText_2")
	self.defeated = self.ui:GetChild("defeated")
	self.imgTimeOut = self.ui:GetChild("imgTimeOut")
	self.imgTimeOut.visible = false
end
function PoPFinishFB.Create( ui, ...)
	return PoPFinishFB.New(ui, "#", {...})
end

function PoPFinishFB:OnEnable(result, destroyTime)
	--激活的时候开始倒计时
	self.victory.visible = result == 1
	self.defeated.visible = result == 2

	destroyTime = destroyTime or 30000
	local time = destroyTime / 1000
	self.timerId= nil
	if result == 1 then
		self.victoryBg.visible = false
			EffectMgr.AddToUI("30005", self.vRole3D, 1.5, nil, nil, nil, nil, function ( effect )
				local tf = effect.transform
				tf.rotation = Vector3.New(0, 0, 0)
				tf.localScale = Vector3.New(20, 20, 1)
			end)
			self.victoryText.text  = StringFormat("距离副本关闭还剩余[color=#fc5757]{0}[/color]秒",math.floor(time))
			self.timerId = RenderMgr.Add(function ()
			time = time - Time.deltaTime
			if self.victoryText then
				self.victoryText.text  = StringFormat("距离副本关闭还剩余[color=#fc5757]{0}[/color]秒",math.floor(time))
			end
			
			if time < 1 then
				--FBController:GetInstance():RequireQuitInstance()
				RenderMgr.Remove(self.timerId)
			end
			
		end)
	else
		self.defeatedBg.visible = false
		EffectMgr.AddToUI("30006", self.vRole3D, 2, nil, nil, nil, nil, function ( effect )
			local tf = effect.transform
			tf.rotation = Vector3.New(0, 0, 0)
			tf.localScale = Vector3.New(20, 20, 1)
		end)
		self.victoryText_2.text  = StringFormat("距离副本关闭还剩余[color=#fc5757]{0}[/color]秒",math.floor(time))
		self.timerId = RenderMgr.Add(function ()
			time = time - Time.deltaTime
			if self.victoryText then
				self.victoryText_2.text  = StringFormat("距离副本关闭还剩余[color=#fc5757]{0}[/color]秒",math.floor(time))
			end
			
			if time < 1 then
				--FBController:GetInstance():RequireQuitInstance()
				RenderMgr.Remove(self.timerId)
			end
		end)
		if result == 2 then
			self:ShowTimeEndFlag()
		end
	end
end

function PoPFinishFB:__delete()
	self.victoryBg = nil
	self.vRole3D = nil
	self.n2 = nil
	self.victoryText = nil
	self.victory = nil
	self.defeatedBg = nil
	self.dRole3D = nil
	self.n11 = nil
	self.n12 = nil
	self.victoryText_2 = nil
	self.defeated = nil
	RenderMgr.Remove(self.timerId)
end

function PoPFinishFB:ShowTimeEndFlag()
	local timeIn, timeStay, timeOut = 1, 2.5, 1
	if not self.imgTimeOut then return end
	self.imgTimeOut.visible = true
	self.imgTimeOut.alpha = 0
	local t1 = self.imgTimeOut:TweenFade(1, timeIn)
	local function fadeOut()
		local t2 = self.imgTimeOut:TweenFade(0, timeOut)
		TweenUtils.OnComplete(t2, function ( obj )
			self.imgTimeOut.visible = false
		end, self)
	end
	TweenUtils.OnComplete(t1, function ( obj )
		DelayCall(fadeOut, timeStay)
	end, self)
end