-- --------------------------
-- 擂台获得星星
-- hosr
-- --------------------------
PlayerkillGetStarShow = PlayerkillGetStarShow or BaseClass()

function PlayerkillGetStarShow:__init(parent, callback)
	self.parent = parent
	self.callback = callback
end

function PlayerkillGetStarShow:__delete()
	self:EndTime()
	self:EndTween()
	self.parent.effectStarFly:SetActive(false)
end

function PlayerkillGetStarShow:Show(is3win)
	-- 取到现在的星星排布
	if self.parent.currData.index == 6 then
		if self.callback ~= nil then
			self.callback()
		end
	else
		local posList = PlayerkillEumn.StarPos[self.parent.currData.star - 1]
		self.parent.curr_star = self.parent.curr_star + 1
		self.targetPos = posList[self.parent.curr_star]
		if is3win then
			self.parent.effectStarFly.transform.localPosition = Vector3(268, -64, -400)
		else
			self.parent.effectStarFly.transform.localPosition = Vector3(115, 54, -400)
		end

		self.parent.effectStarFly:SetActive(false)
		self.parent.effectStarFly:SetActive(true)
		if self.targetPos ~= nil then
			self.targetPos = self.targetPos + Vector3(1.5, -1, 0)
			self:EndTime()
			self.timeId = LuaTimer.Add(100, function() self:Fly() end)
		else
			if self.callback ~= nil then
				self.callback()
			end
		end
	end
end

function PlayerkillGetStarShow:EndTime()
	if self.timeId ~= nil then
		LuaTimer.Delete(self.timeId)
		self.timeId = nil
	end
end

function PlayerkillGetStarShow:Fly()
	self:EndTime()
	self.tweenId = Tween.Instance:MoveLocal(self.parent.effectStarFly, self.targetPos, 0.5, function() self:FlyCallBack() end, LeanTweenType.easeOutQuad).id
	self.timeId = LuaTimer.Add(1500, function() self:LightUp() end)
end

function PlayerkillGetStarShow:LightUp()
	self:EndTime()
	self.parent.effectStarFly:SetActive(false)
	self.parent.starsList[self.parent.curr_star]:LightUp(true)
	if self.callback ~= nil then
		self.callback()
	end
end

function PlayerkillGetStarShow:EndTween()
	if self.tweenId ~= nil then
		Tween.Instance:Cancel(self.tweenId)
		self.tweenId = nil
	end
end

function PlayerkillGetStarShow:FlyCallBack()
	self:EndTween()
end