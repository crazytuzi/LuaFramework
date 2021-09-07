-- -----------------------------------
-- 一闷夺宝展示项
-- hosr
-- -----------------------------------
LotteryShowItem = LotteryShowItem or BaseClass()

function LotteryShowItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.parent = parent
    self.timeId = nil
    self.countTime = 0
    self.tweenId = 0
    self:InitPanel()
end

function LotteryShowItem:__delete()
	self.btnImg.sprite = nil
	if self.timeId ~= nil then
		LuaTimer.Delete(self.timeId)
		self.timeId = nil
	end
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end

    if self.tweenId ~= 0 then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = 0
    end
end

function LotteryShowItem:InitPanel()
    self.transform = self.gameObject.transform

    self.tips = self.transform:Find("TipsIcon").gameObject
    self.name = self.transform:Find("Name"):GetComponent(Text)

    self.slot = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:Find("Slot").gameObject, self.slot.gameObject)

    self.ItemValueTxt = self.transform:Find("ItemValueTxt"):GetComponent(Text)
    self.ItemValueTxtMsg = MsgItemExt.New(self.ItemValueTxt, 150, 15, 23)
    self.TxtFinishI18N = self.transform:Find("TxtFinishI18N").gameObject
    self.MidCon = self.transform:Find("MidCon")
    self.now = self.MidCon:Find("Now"):GetComponent(Text)
    self.need = self.MidCon:Find("Need"):GetComponent(Text)
    self.left = self.MidCon:Find("Left"):GetComponent(Text)
    self.remain = self.MidCon:Find("Remain"):GetComponent(Text)
    self.slider = self.MidCon:Find("Slider"):GetComponent(Slider)
    self.slider.value = 0
    self.timeObj = self.transform:Find("Time").gameObject
    self.timeTips = self.transform:Find("Time/Tips"):GetComponent(Text)
    self.timeVal = self.transform:Find("Time/Text"):GetComponent(Text)
    self.timeVal.color = Color(255/255, 255/255, 154/255)
    for i = 1, 6 do
        self.transform:Find("Time"):GetChild(i).gameObject:SetActive(false)
    end

    self.btnObj = self.transform:Find("Button").gameObject
    self.btn = self.btnObj:GetComponent(Button)
    self.btnImg = self.btnObj:GetComponent(Image)
    self.btnTxt = self.btnObj.transform:Find("BtnTxtI18N"):GetComponent(Text)
    self.heardIcon = self.transform:Find("ImgBtnIcon2"):GetComponent(Image)
    self.heardBtn = self.transform:Find("ImgBtnIcon1"):GetComponent(Button)
    self.heardIcon.gameObject:SetActive(true)
    self.heardBtn.onClick:AddListener(function()
        LotteryManager.Instance:Send16908(self.data.idx)
    end)
    self.btn.onClick:AddListener(function() self:ClickButton() end)

    self.tag = self.transform:Find("Tag").gameObject
    self.tag:SetActive(false)

    self.result = self.transform:Find("Result")
    self.WinnerTxt = self.result:Find("WinnerTxt"):GetComponent(Text)
    self.JoinTxt = self.result:Find("JoinTxt"):GetComponent(Text)
    self.LuckTxt = self.result:Find("LuckTxt"):GetComponent(Text)
    self.PlatFormTxt = self.result:Find("PlatFormTxt"):GetComponent(Text)
    self.result.gameObject:SetActive(false)
end

function LotteryShowItem:SetData(data, tweenProg)
    self.data = data
    self.itemData = ItemData.New()
    self.itemData:SetBase(BaseUtils.copytab(DataItem.data_get[self.data.item_id]))
    self.itemData.quantity = self.data.item_count
    self.slot:SetAll(self.itemData, {nobutton = true})

    if self.data.item_count > 1 then
        self.name.text = string.format("<color='#0c52b0'>%sx%s</color>", self.itemData.name, self.data.item_count) --ColorHelper.color_item_name(self.itemData.quality, self.itemData.name)
    else
        self.name.text = string.format("<color='#0c52b0'>%s</color>", self.itemData.name)
    end

    local price = self.data.price
    self.ItemValueTxtMsg:SetData(string.format("%s<color='#c7f9ff'>%s</color>{assets_2,%s}", TI18N("价值:"), price, self.data.gold_type))

    self.ItemValueTxt.gameObject.transform:GetComponent(RectTransform).anchoredPosition = Vector2((170 - self.ItemValueTxtMsg.selfWidth)/2, -94.5)

    self.now.text = tostring(self.data.times_now)
    self.need.text = tostring(self.data.times_sum)
    self.left.text = tostring(self.data.times_sum - self.data.times_now)

    if tweenProg then
        if self.curSliderValue ~= (self.data.times_now / self.data.times_sum) or self.curSliderValue == 0 then
            if self.data.times_now / self.data.times_sum > 0 then
                if self.tweenId ~= 0 then
                    Tween.Instance:Cancel(self.tweenId)
                    self.tweenId = 0
                end
                self.slider.value = 0

                local tweenData = Tween.Instance:ValueChange(self.slider.value, self.data.times_now / self.data.times_sum, 1, nil, LeanTweenType.linear, function(v)
                    if BaseUtils.isnull(self.slider) then
                        if self.tweenId ~= 0 then
                            Tween.Instance:Cancel(self.tweenId)
                            self.tweenId = 0
                        end
                    else
                        self.slider.value = v
                    end
                end)
                self.tweenId = tweenData.id
            else
                if self.tweenId ~= 0 then
                    Tween.Instance:Cancel(self.tweenId)
                    self.tweenId = 0
                end
                self.slider.value = 0
            end
        end
    else
        self.slider.value = self.data.times_now / self.data.times_sum
    end
    self.curSliderValue = self.slider.value

    -- if self.data.focus == 1 then
    --     --有关注
    --     self.heardIcon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.lottery_res,"SingHeart1")
    -- else
    --     self.heardIcon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.lottery_res,"SingHeart2")
    -- end
    self:SetFocusState()

    self.tips:SetActive(self.data.hot == 1)

    self:UpdateState()
end

function LotteryShowItem:UpdateState()
    -- 是否参与
    if self.data.times_my == 0 then
        -- self.btnImg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.button1, "Button1Green")
        self.btnTxt.text = TI18N("立即参与")
    else
        -- self.btnImg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.button1, "Button1Orange")
        self.btnTxt.text = string.format("%s", TI18N("继续追加"))
        -- self.btnTxt.color = ColorHelper.DefaultButton3
    end
    self.TxtFinishI18N:SetActive(false)
    -- 单项状态

    if self.data.state == LotteryEumn.State.Joining then
        -- 活动参与中
		self.tag:SetActive(false)
        self.timeObj:SetActive(false)
        self.btnObj:SetActive(true)
        self.result.gameObject:SetActive(false)
        self.MidCon.gameObject:SetActive(true)
    elseif self.data.state == LotteryEumn.State.Opening then
        -- 揭晓中
		self.tag:SetActive(false)
        self.btnObj:SetActive(false)
        self.result.gameObject:SetActive(false)
        self.MidCon.gameObject:SetActive(false)
        self.slider.value = 0
        self.countTime = self.data.time - BaseUtils.BASE_TIME + 3
        if self.countTime <= 0 then
            self.timeObj:SetActive(false)
        	self:RequestNew()
        else
            self.timeObj:SetActive(true)
        	self.timeTips.text = TI18N("揭晓倒计时:")
            self.temp_time2 = Time.time
	        self:Loop()
	        self:TimeCount()
        end
    elseif self.data.state == LotteryEumn.State.Showing or self.data.state == LotteryEumn.State.Over then
		-- 已揭晓
		self.tag:SetActive(false)
        self.btnObj:SetActive(false)
        self.timeObj:SetActive(false)
        self.result.gameObject:SetActive(true)
        self.MidCon.gameObject:SetActive(false)
        self.slider.value = 0
        local serverName = TI18N("神秘大陆")
        for k, v in pairs(DataServerList.data_server_name) do
            if v.platform == self.data.platform and v.zone_id == self.data.zone_id then
                serverName = v.platform_name
                break
            end
        end

        local tempStr = tostring(self.data.lucky_num)
        if self.data.lucky_num < 10 then
            tempStr = string.format("0000%s", tempStr)
        elseif self.data.lucky_num < 100 then
            tempStr = string.format("000%s", tempStr)
        elseif self.data.lucky_num < 1000 then
            tempStr = string.format("00%s", tempStr)
        elseif self.data.lucky_num < 10000 then
            tempStr = string.format("0%s", tempStr)
        end

        self.WinnerTxt.text = string.format("%s<color='#35dfe7'>%s</color>" , TI18N("获得者："), self.data.role_name)
        self.JoinTxt.text = string.format("%s<color='#ffff00'>%s/%s</color>%s" , TI18N("参与："), self.data.times_lottery, self.data.times_sum, TI18N("人次"))
        self.LuckTxt.text = string.format("%s<color='#ffff00'>%s</color>" , TI18N("幸运号码："), tempStr)
        self.PlatFormTxt.text = string.format("%s<color='#c7f9ff'>%s</color>" , TI18N("来自："), serverName)
    elseif self.data.state == LotteryEumn.State.Hold then
        self.btnObj:SetActive(true)
        self.timeObj:SetActive(false)
        self.result.gameObject:SetActive(false)
        self.MidCon.gameObject:SetActive(false)
        self.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.TxtFinishI18N:SetActive(true)
    end
end

function LotteryShowItem:ClickButton()
    if self.data.state == LotteryEumn.State.Hold then
        NoticeManager.Instance:FloatTipsByString(TI18N("活动已结束，结算期间不能参与{face_1,2}"))
        return
    end
    LotteryManager.Instance.model:OpenJoinPanel(self.data)
end

function LotteryShowItem:TimeCount()
	self:TimeStop()
    self.countTime = self.countTime * 1000
    self.temp_time2 = Time.time
	self.timeId = LuaTimer.Add(0, 10, function() self:Loop() end)
end

function LotteryShowItem:TimeStop()
	if self.timeId ~= nil then
		LuaTimer.Delete(self.timeId)
		self.timeId = nil
	end
end

function LotteryShowItem:Loop()
	if self.countTime <= 0 then
		self:TimeStop()
		self:RequestNew()
		return
	end
    self.countTime = self.countTime - (Time.time - self.temp_time2)*1000
    self.temp_time2 = Time.time
    local my_minute = math.modf(self.countTime/1000 % 86400 % 3600 / 60)
    local my_second = math.modf(self.countTime/1000 % 86400 % 3600 % 60)
    local my_limi = self.countTime - (my_minute*60+my_second)*1000
    local first = ""
	if my_minute < 10 then
        first = "0".. my_minute
	else
        first = string.format("%s%s", math.floor(my_minute/10),  my_minute%10)
    end
    local second = ""
	if my_second < 10 then
        second = "0".. my_second
	else
        second = string.format("%s%s", math.floor(my_second/10),  my_second%10)
    end
    local third = ""
	if my_limi < 100 then
        third = "00"
	else
        third = string.format("%s%s", math.floor(my_limi/100), math.floor(my_limi%100/10))
    end
	-- local list = StringHelper.ConvertStringTable(string.format("%s%s%s", my_minute, my_second, my_limi))
    self.timeVal.text = string.format(" %s:%s:%s", first, second, third)
	self.countTime = self.countTime - 1
	-- list = nil
end

function LotteryShowItem:RequestNew()
	LotteryManager.Instance:RequestNew(LotteryManager.Instance.lastTimeTab[LotteryEumn.Type.Diamond])
end

--设置关注状态
function LotteryShowItem:SetFocusState()
    if LotteryManager.Instance.focusList[self.data.item_idx] ~= nil then
        --有关注
        self.data.focus = 1
        self.heardIcon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.lottery_res,"SingHeart1")
    else
        self.data.focus = 0
        self.heardIcon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.lottery_res,"SingHeart2")
    end
end