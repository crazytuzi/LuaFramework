-- 划龙舟开始窗口
-- @ljh 2017.05.18
DragonBoatStartWindow = DragonBoatStartWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function DragonBoatStartWindow:__init(model)
    self.model = model
    self.name = "DragonBoatStartWindow"
    self.windowId = WindowConfig.WinID.dragonboatstartwin

    self.resList = {
        {file = AssetConfig.dragonboatstartwin, type = AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil


	------------------------------------------------
	self.canStart = false
	------------------------------------------------

    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function DragonBoatStartWindow:__delete()
    self:Release()
end

function DragonBoatStartWindow:Release()
    self:OnHide()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function DragonBoatStartWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dragonboatstartwin))
    self.gameObject.name = "DragonBoatStartWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:FindChild("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.text1 = self.transform:FindChild("Main/Text1"):GetComponent(Text)
    self.text2 = self.transform:FindChild("Main/Text2"):GetComponent(Text)
    self.text3 = self.transform:FindChild("Main/Text3"):GetComponent(Text)

    self.buttonTransform = self.transform:FindChild("Main/Button")
    self.button = self.buttonTransform:GetComponent(Button)
	self.button.onClick:AddListener(function() self:OnButtonClick() end)

    self.title = self.transform:FindChild("Main/title/TxtTitle"):GetComponent(Text)
    self.title.text = DragonBoatManager.Instance.title_name

    ----------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function DragonBoatStartWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function DragonBoatStartWindow:OnShow()
	self:Update()

	if self.timerId ~= nil then
		LuaTimer.Delete(self.timerId)
		self.timerId = nil
	end

	if self.moveTweenId ~= nil then
        Tween.Instance:Cancel(self.moveTweenId)
        self.moveTweenId = nil
    end

	self.timerId = LuaTimer.Add(0, 200, function() self:OnTimer() end)
end

function DragonBoatStartWindow:OnHide()
	if self.timerId ~= nil then
		LuaTimer.Delete(self.timerId)
		self.timerId = nil
	end
end

function DragonBoatStartWindow:Update()
	self.text1.text = TI18N("活动即将开始，请做好准备")
	self.text2.text = TI18N("距离活动正式开始还有：")
	self.text3.text = ""
end

function DragonBoatStartWindow:OnButtonClick()
	if self.canStart then
		if TeamManager.Instance:IsSelfCaptin() then
			DragonBoatManager.Instance:GoNext()
		else
			NoticeManager.Instance:FloatTipsByString(TI18N(""))
		end
	else
		local time = DragonBoatManager.Instance.time_out - BaseUtils.BASE_TIME
		local m = nil
        local s = nil
        local _ = nil
        _, _, m,s = BaseUtils.time_gap_to_timer(time)

        if m > 0 then
	        if s < 10 then s = "0" .. s end
	        if m < 10 then m = "0" .. m end
	        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("活动尚未开始，距离活动开始还剩：<color='#00ff00'>%s分%s秒</color>"), m, s))
	    else
	    	NoticeManager.Instance:FloatTipsByString(string.format(TI18N("活动尚未开始，距离活动开始还剩：<color='#00ff00'>%s秒</color>"), time))
	    end
	end

	self:OnClickClose()
end

function DragonBoatStartWindow:OnTimer()
	local time = DragonBoatManager.Instance.time_out - BaseUtils.BASE_TIME
	if time > 3 then
		-- self.text3.text = string.format(TI18N("%s秒"), time)
		local m = nil
        local s = nil
        local _ = nil
        _, _, m,s = BaseUtils.time_gap_to_timer(time)

        if m > 0 then
	        if s < 10 then s = "0" .. s end
	        if m < 10 then m = "0" .. m end
	        self.text3.text = string.format(TI18N("<color='#ffffff'>%s分%s秒</color>"), m, s)
	    else
	    	self.text3.text = string.format(TI18N("<color='#ffffff'>%s秒</color>"), time)
	    end
	else
		-- self.text3.text = string.format(TI18N("%s秒"), 0)
		-- self.buttonTransform:Find("Text"):GetComponent(Text).text = TI18N("出 发")

		-- self.buttonTransform.localScale = Vector3.one * 3
	 --    self.tweenId = Tween.Instance:Scale(self.buttonTransform, Vector3.one, 1, function() self:TweenEnd() end, LeanTweenType.easeOutElastic).id
	 	self:OnClickClose()
	end
end

function DragonBoatStartWindow:TweenEnd()
	if self.moveTweenId ~= nil then
        Tween.Instance:Cancel(self.moveTweenId)
        self.moveTweenId = nil
    end

	self.canStart = true
end