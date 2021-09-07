-- -------------------------------
-- 中秋活动主界面倒计时显示
-- hosr
-- -------------------------------
MidAutumnEnjoyMainui = MidAutumnEnjoyMainui or BaseClass(BasePanel)

function MidAutumnEnjoyMainui:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.midAutumn_enjoymoon_mainui, type = AssetType.Main}
	}

	self.tickListener = function() self:Loop() end
	self.infoListener = function() self:SetData() end

    self.mgr = MidAutumnFestivalManager.Instance

    self.timeFormat2 = TI18N("%s小时")
    self.timeFormat3 = TI18N("%s分钟")
    self.timeFormat4 = TI18N("%s秒")
    self.timeString2 = TI18N("00分00秒")

	self.val = 0
end

function MidAutumnEnjoyMainui:__delete()
	self.mgr.infoEvent:RemoveListener(self.infoListener)
	self:End()
end

function MidAutumnEnjoyMainui:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.midAutumn_enjoymoon_mainui))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.title = self.transform:Find("Title/Text"):GetComponent(Text)
    self.timeVal = self.transform:Find("Title/Text/TimeVal"):GetComponent(Text)

    self:SetData()
    self.mgr.infoEvent:AddListener(self.infoListener)
end

function MidAutumnEnjoyMainui:SetData()
	self.val = self.model["enjoymoon_left_time"] or 0
	if self.val == 0 then
		self:End()
	else
		self:Begin()
	end
end

function MidAutumnEnjoyMainui:Begin()
	self:End()
	self.mgr.tickEvent:AddListener(self.tickListener)
end

function MidAutumnEnjoyMainui:Loop()
	self.val = self.val - 1
	local t = self.val
	if self.val > 17 * 60 then
		t = t - 17 * 60
	elseif self.val > 11 * 60 then
		t = t - 11 * 60
	elseif self.val > 5 * 60 then
		t = t - 5 * 60
	else
		t = 0
	end

	if t == 0 then
		self:End()
		self.model:CloseEnjoyMoonMainUI()
	else
		local h = 0
	    local m = 0
	    local s = 0
	    _,h,m,s = BaseUtils.time_gap_to_timer(t)
	    if h > 0 then
	        self.timeVal.text = string.format("%s时%s分%s秒", tostring(h), tostring(m), tostring(s))
	    elseif m > 0 then
	        self.timeVal.text = string.format("%s分%s秒", tostring(m), tostring(s))
	    elseif s > 0 then
	        self.timeVal.text = string.format("%s分%s秒", tostring(m), tostring(s))
	    else
	        self.timeVal.text = self.timeString2
	    end
	end
end

function MidAutumnEnjoyMainui:End()
	self.mgr.tickEvent:RemoveListener(self.tickListener)
	self.timeVal.text = ""
end
