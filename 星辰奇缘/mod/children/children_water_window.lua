--作者:hzf
--01/05/2017 19:40:31
--功能:子女泉水

ChildrenWaterWindow = ChildrenWaterWindow or BaseClass(BaseWindow)
function ChildrenWaterWindow:__init(parent)
	self.parent = parent
	self.okEffect = "prefabs/effect/20262.unity3d"
	self.btnEffect = "prefabs/effect/20053.unity3d"
	self.waveEffect = "prefabs/effect/20264.unity3d"
	self.staticEffect = "prefabs/effect/20265.unity3d"
	-- 20124 扫光
	-- 20264 水波
	-- 20265 星光点点
	self.resList = {
		{file = AssetConfig.childrenwaterwindow, type = AssetType.Main},
		{file = self.okEffect, type = AssetType.Main},
		{file = self.btnEffect, type = AssetType.Main},
		{file = self.waveEffect, type = AssetType.Main},
		{file = self.staticEffect, type = AssetType.Main},
		{file = AssetConfig.childrentextures, type = AssetType.Dep},
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.ontimeschange = function()
		self:OnTimesChange()
	end

	self.hasInit = false
	self.movetimer = nil
	self.speed = 2.5
	-- 剩余时间
	self.remaintime = 30
	-- 出界次数
	self.errorTimes = 0
	-- 当前抖动箭头方向，0代表没有
	self.currShakeVal = 0
	-- 箭头抖动tweenid
	self.shakeID = nil
	self.imgLoader = nil
	self.imgLoader1 = nil
end

function ChildrenWaterWindow:__delete()
	if self.imgLoader ~= nil then
		self.imgLoader:DeleteMe()
		self.imgLoader = nil
	end

	if self.imgLoader1 ~= nil then
		self.imgLoader1:DeleteMe()
		self.imgLoader1 = nil
	end

    QuestManager.Instance.childPlantUpdate:RemoveListener(self.ontimeschange)
	if self.movetimer ~= nil then
		LuaTimer.Delete(self.movetimer)
		self.movetimer = nil
	end
	if self.counttimer ~= nil then
		LuaTimer.Delete(self.counttimer)
		self.counttimer = nil
	end
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function ChildrenWaterWindow:OnHide()

end

function ChildrenWaterWindow:OnOpen()

end

function ChildrenWaterWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.childrenwaterwindow))
	self.gameObject.name = "ChildrenWaterWindow"
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

	self.transform = self.gameObject.transform
	self.Panel = self.transform:Find("Panel")
	self.Main = self.transform:Find("Main")
	self.Title = self.transform:Find("Main/Title")
	self.Text = self.transform:Find("Main/Title/Text"):GetComponent(Text)
	self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function()
		ChildrenManager.Instance.model:CloseWaterWindow()
	end)
	self.Con = self.transform:Find("Main/Con")
	self.bg = self.transform:Find("Main/Con/bg")
	self.Target = self.transform:Find("Main/Con/Mask/bg/Target")

	if next(BackpackManager.Instance:GetItemByBaseid(23804)) ~= nil then
		local go = self.transform:Find("Main/Con/Mask/bg/Target").gameObject
	    if self.imgLoader == nil then
	        self.imgLoader = SingleIconLoader.New(go)
	    end
	    self.imgLoader:SetSprite(SingleIconType.Item, DataItem.data_get[23804].icon)

		go = self.transform:Find("Main/Con/ItemIcon").gameObject
	    if self.imgLoader1 == nil then
	        self.imgLoader1 = SingleIconLoader.New(go)
	    end
	    self.imgLoader1:SetSprite(SingleIconType.Item, DataItem.data_get[23804].icon)
	else
		local go = self.transform:Find("Main/Con/Mask/bg/Target").gameObject
	    if self.imgLoader == nil then
	        self.imgLoader = SingleIconLoader.New(go)
	    end
	    self.imgLoader:SetSprite(SingleIconType.Item, DataItem.data_get[23805].icon)

		go = self.transform:Find("Main/Con/ItemIcon").gameObject
	    if self.imgLoader1 == nil then
	        self.imgLoader1 = SingleIconLoader.New(go)
	    end
	    self.imgLoader1:SetSprite(SingleIconType.Item, DataItem.data_get[23805].icon)
	end

	self.StartButton = self.transform:Find("Main/Con/StartButton"):GetComponent(Button)
	self.StartButton.onClick:AddListener(function()
		self:OnStart()
	end)
	self.Icon = self.transform:Find("Main/Con/StartButton/Icon")
	self.StartButtonText = self.transform:Find("Main/Con/StartButton"):GetChild(2):GetComponent(Text)
	self.Ext = MsgItemExt.New(self.StartButtonText, 160, 16, 19)
	self.Ext:SetData(string.format(TI18N("花费：%s{assets_2,%s}"), "50000", "90000"))

	self.Rulebg = self.transform:Find("Main/Con/Rulebg").gameObject
	self.TIpsText = self.transform:Find("Main/Con/TIpsText").gameObject
	self.CountText = self.transform:Find("Main/Con/CountText"):GetComponent(Text)

	self.Slider = self.transform:Find("Main/Con/Slider"):GetComponent(Slider)
	self.icon = self.transform:Find("Main/Con/Slider/icon")
	self.RemainText = self.transform:Find("Main/Con/RemainText"):GetComponent(Text)
	self.InfoButton = self.transform:Find("Main/Con/InfoButton"):GetComponent(Button)
	self.Desc = self.transform:Find("Main/Con/InfoButton/Desc")
	self.Image = self.transform:Find("Main/Con/InfoButton/Image"):GetComponent(Image)
	self.LButton = self.transform:Find("Main/Con/LButton"):GetComponent(Button)
	self.LPos = self.LButton.gameObject.transform.localPosition
	self.LButton.onClick:AddListener(function()
		self:OnLeft()
	end)
	self.RButton = self.transform:Find("Main/Con/RButton"):GetComponent(Button)
	self.RPos = self.RButton.gameObject.transform.localPosition
	self.RButton.onClick:AddListener(function()
		self:OnRight()
	end)
	self.okEffectgo = GameObject.Instantiate(self:GetPrefab(self.okEffect))
    self.okEffectgo.transform:SetParent(self.Main)
    self.okEffectgo.transform.localScale = Vector3.one
    self.okEffectgo.transform.localPosition = Vector3(0,0, -1000)
    Utils.ChangeLayersRecursively(self.okEffectgo.transform, "UI")
    self.okEffectgo:SetActive(false)

    self.btnEffectgo = GameObject.Instantiate(self:GetPrefab(self.btnEffect))
    self.btnEffectgo.transform:SetParent(self.StartButton.transform)
    self.btnEffectgo.transform.localScale = Vector3(1.66, 0.56, 1)
    self.btnEffectgo.transform.localPosition = Vector3(-53, -11, -1000)
    Utils.ChangeLayersRecursively(self.btnEffectgo.transform, "UI")
    self.btnEffectgo:SetActive(true)

    self.waveEffectgo = GameObject.Instantiate(self:GetPrefab(self.waveEffect))
    self.waveEffectgo.transform:SetParent(self.Target)
    self.waveEffectgo.transform.localScale = Vector3.one
    self.waveEffectgo.transform.localPosition = Vector3(0,0, -1000)
    Utils.ChangeLayersRecursively(self.waveEffectgo.transform, "UI")
    self.waveEffectgo:SetActive(true)

    self.staticEffect = GameObject.Instantiate(self:GetPrefab(self.staticEffect))
    self.staticEffect.transform:SetParent(self.Con)
    self.staticEffect.transform.localScale = Vector3.one
    self.staticEffect.transform.localPosition = Vector3(0,0, -1000)
    Utils.ChangeLayersRecursively(self.staticEffect.transform, "UI")
    self.staticEffect:SetActive(true)

    self:Reset()
    self:OnTimesChange()
    QuestManager.Instance.childPlantUpdate:AddListener(self.ontimeschange)
end

function ChildrenWaterWindow:OnLeft()
	self.speed = self.speed - 2.3
end

function ChildrenWaterWindow:OnRight()
	self.speed = self.speed + 2.3
end

function ChildrenWaterWindow:OnStart()
	self:Reset()
	-- self:StartMov()
	QuestManager.Instance:Send10245()
end

function ChildrenWaterWindow:StartMov()
	print("啊啊啊啊")
	self.Target.gameObject:SetActive(true)
	self.LButton.gameObject:SetActive(true)
	self.RButton.gameObject:SetActive(true)
	self.StartButton.gameObject:SetActive(false)
	self.TIpsText:SetActive(true)
	self.errorTimes = 0
	local shake = function()
		if self.Target == nil then
			return
		end
		self:ShakeArrow()
		local dir = math.random(-10, 10)/16
		self.Target.anchoredPosition3D = self.Target.anchoredPosition3D + Vector3(1,0,0)*self.speed
		self.speed = self.speed + dir
		if math.abs(self.Target.anchoredPosition.x) > 130 then
			self.errorTimes = self.errorTimes + 1
			if self.errorTimes > 3 then
				self:OnFailed()
			end
		end
	end
	self.movetimer = LuaTimer.Add(0, 50, shake)
	self.remaintime = 10
	local countdown = function()
		self.remaintime = self.remaintime - 1
		self.Slider.value = 1 - self.remaintime/10
		if self.remaintime <= 0 then
			LuaTimer.Delete(self.counttimer)
			LuaTimer.Delete(self.movetimer)
			self:OnSuccess()
		end
		self.RemainText.text = string.format(TI18N("%s%%"), tostring(math.floor((1 - self.remaintime/10)*100)))
	end
	self.counttimer = LuaTimer.Add(0, 1000, countdown)

end

function ChildrenWaterWindow:Reset()
	self.Slider.value = 0
	self.speed = 2.5
	self.RemainText.text = "%0"
	self.Target.anchoredPosition3D = Vector3(0,0,0)
	self.Target.gameObject:SetActive(false)
	self.StartButton.gameObject:SetActive(true)
	self.LButton.gameObject:SetActive(false)
	self.RButton.gameObject:SetActive(false)
	self.TIpsText:SetActive(false)
	if self.shakeID ~= nil then
		Tween.Instance:Cancel(self.shakeID)
		self.shakeID = nil
	end
	self.currShakeVal = 0
end

function ChildrenWaterWindow:OnSuccess()
	SceneManager.Instance:Send10100(0, 83110)
	LuaTimer.Add(2000, function()
		ChildrenManager.Instance.model:CloseWaterWindow()
	end)
	NoticeManager.Instance:FloatTipsByString(TI18N("采集完毕，快去浇灌灵花吧{face_1,18}"))
	self.okEffectgo:SetActive(true)
end

function ChildrenWaterWindow:OnFailed()
	LuaTimer.Delete(self.counttimer)
	LuaTimer.Delete(self.movetimer)
	self:Reset()
	NoticeManager.Instance:FloatTipsByString(TI18N("瓶子被冲飞了，请再次尝试{face_1,42}"))
	-- self.noEffectgo:SetActive(true)
	-- LuaTimer.Add(2000, function()
	-- 	if not BaseUtils.isnull(self.noEffectgo) then
	-- 		self.noEffectgo:SetActive(false)
	-- 	end
	-- end)
end

function ChildrenWaterWindow:ShakeArrow()
	if self.Target.anchoredPosition.x > 0 then
		if self.currShakeVal <= 0 then
			if self.currShakeVal ~= 0 then
				-- 停止对面箭头抖动
				if self.shakeID ~= nil then
					Tween.Instance:Cancel(self.shakeID)
					self.shakeID = nil
				end
				self.RButton.gameObject.transform.localPosition = self.RPos
			end
			self.currShakeVal = 1
			self.LButton.transform.localPosition = self.LPos
			self.shakeID = Tween.Instance:MoveLocalX(self.LButton.gameObject, self.LPos.x-12, 0.5, nil, LeanTweenType.easeOutSine):setLoopPingPong().id
		end
	else
		if self.currShakeVal >= 0 then
			if self.currShakeVal ~= 0 then
				-- 停止对面箭头抖动
				if self.shakeID ~= nil then
					Tween.Instance:Cancel(self.shakeID)
					self.shakeID = nil
				end
				self.RButton.gameObject.transform.localPosition = self.RPos

			end
			self.currShakeVal = -1
			self.RButton.transform.localPosition = self.RPos
			self.shakeID = Tween.Instance:MoveLocalX(self.RButton.gameObject, self.RPos.x+12, 0.5, nil, LeanTweenType.easeOutSine):setLoopPingPong().id
		end
	end
end

function ChildrenWaterWindow:OnTimesChange()
	if QuestManager.Instance.childPlantData ~= nil and QuestManager.Instance.childPlantData.try_fill ~= 0 then
		self.StartButtonText.gameObject:SetActive(true)
	else
		self.StartButtonText.gameObject:SetActive(false)
	end
end

function ChildrenWaterWindow:CountDown()
	-- 143
	local tick = 3
	self.Rulebg:SetActive(false)
	self.waveEffectgo:SetActive(false)
	self.CountText.gameObject:SetActive(true)
	self.StartButton.gameObject:SetActive(false)
	self.Target.localPosition = Vector3(0, 140, 0)
	self.CountText.text = "3"
	LuaTimer.Add(0 , 1000, function ()
		if tick <= 0 then
			self.CountText.gameObject:SetActive(false)
			self.Target.gameObject:SetActive(true)

			print("啊啊啊啊啊")
			Tween.Instance:MoveY(self.Target.gameObject, 0, 1.5, function() self.waveEffectgo:SetActive(true) self:StartMov() end, LeanTweenType.easeOutQuart)
			return false
		end
		self.CountText.text = tostring(tick)
		tick = tick - 1
	end)
end