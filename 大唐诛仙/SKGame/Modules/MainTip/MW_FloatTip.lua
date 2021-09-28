MW_FloatTip =BaseClass(LuaMsgWin)

function MW_FloatTip:__init( ... )
	self.ui = UIPackage.CreateObject("MainTip","MW_FloatTip");

	self.bg = self.ui:GetChildAt(0)
	self.title = self.ui:GetChildAt(1)
	self.parent = GRoot.inst
	self.msg = ""

	self.ui.scaleX = GameConst.scaleX
	self.ui.scaleY = GameConst.scaleY
	local x = (layerMgr.WIDTH - self.ui.width)*0.5
	local y = (layerMgr.HEIGHT - self.ui.height)*0.5
	self.ui.x = x * self.ui.scaleX
	self.ui.y = y * self.ui.scaleY


	self.tipList = {}
end

function MW_FloatTip:SetMsg(str_msg)
	self.msg = str_msg
	self:ShowTip()
end

function MW_FloatTip:ShowTip()
	self.title.text = self.msg

	self.tweener = self.ui:TweenMoveY(self.ui.y-100, 1)
	TweenUtils.SetEase(self.tweener, 21)
	TweenUtils.SetAutoKill(self.tweener, true)
	TweenUtils.OnComplete(self.tweener, function ()
		TweenUtils.Kill(self.tweener, true)
		self.tweener = self.ui:TweenFade(0, 0.5)
		TweenUtils.OnComplete(self.tweener, function ()
			TweenUtils.Kill(self.tweener, true)
			self.tweener = nil
			self:Close()
			self:Destroy()
		end)
	end)
	
end

function MW_FloatTip:__delete()
	self:Close()
	if self.tweener then
		TweenUtils.Kill(self.tweener, true)
		self.tweener = nil
	end
	self.bg = nil
	self.title = nil
end