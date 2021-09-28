local StarItem2 = require "Core.Module.Star.View.StarItem2"

local StarGetItem = class("StarGetItem", StarItem2);
local showDelay = 0.5
local popTime = 0.25

function StarGetItem:New()
	self = {};
	setmetatable(self, {__index = StarGetItem});
	return self
end

function StarGetItem:CheckRedEffect()
	if self.data.quality >= EquipQuality.Orange then
		if not self._redEffect then
			self._redEffect = UIUtil.GetUIEffect("ui_treasury2", self.transform, self._imgIcon)
			local t = self._redEffect.transform
			t.localScale = Vector3(1.22, 1.22, 1.22)
			Util.SetLocalPos(t, 5, 0, 0)
		else
			self._redEffect:SetActive(true)
		end
	else
		if self._redEffect then self._redEffect:SetActive(false) end
	end
end

function StarGetItem:ShowEffect(i)
	self.gameObject:SetActive(false)
	if i == 0 then self:Show() return end
	
	local func = function() self:Show(i) end
	if self.timer then self.timer:Stop() self.timer = nil end
	self.timer = Timer.New(func, i * showDelay, 1)
	
	self.timer:Start()
end

function StarGetItem:Show(i)
	self.timer = nil
	self.gameObject:SetActive(true)
	self.transform.localScale = Vector3.one * 0.1
	self.time = 0
	self.scale = 1
	if(self._corutine) then
		coroutine.stop(self._corutine)
		self._corutine = nil
	end
	
	self._corutine = coroutine.start(self._Showing, self)
	if self._effect then self._effect:SetActive(false) end
	local p = 'Other/' ..(self.data.quality < EquipQuality.Orange and 'awardBg' or 'awardBg2')
	if p ~= self._tPath then
		UIUtil.RecycleTexture(self._tPath)
		self._tPath = p
		if not self.bg then
			self.bg = UIUtil.GetChildByName(self.transform, "UITexture", "bg")
		end
		self.bg.mainTexture = UIUtil.GetTexture(self._tPath)
	end
end

function StarGetItem:_Showing()
	while self.time < popTime do
		coroutine.step();
		self.time = self.time + Timer.deltaTime;
		self.scale = EaseUtil.easeInQuad(0.1, 1, self.time / popTime)
		self.transform.localScale = Vector3.New(self.scale, self.scale, 1);
	end
	self.transform.localScale = Vector3.one;
	
	if not self._effect then
		self._effect = UIUtil.GetUIEffect("ui_treasury1", self.transform, self._imgIcon)
		local t = self._effect.transform
		Util.SetLocalPos(t, 0, 20, 0)
	else
		self._effect:SetActive(true)
	end
	UISoundManager.PlayUISound(UISoundManager.ui_compose)
end


function StarGetItem:_Dispose()
	self:_DisposeReference()
	Resourcer.Recycle(self._redEffect, false)
	Resourcer.Recycle(self._effect, false)
	if(self._corutine) then
		coroutine.stop(self._corutine)
		self._corutine = nil
	end
	if self.timer then self.timer:Stop() self.timer = nil end
	if self._tPath then UIUtil.RecycleTexture(self._tPath) self._tPath = nil end
end

return StarGetItem 