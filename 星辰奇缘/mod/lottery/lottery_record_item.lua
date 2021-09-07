-- -------------------------------------
-- 一闷夺宝记录项
-- hosr
-- -------------------------------------
LotteryRecordItem = LotteryRecordItem or BaseClass()

function LotteryRecordItem:__init(go, parent)
    self.gameObject = go
    self.parent = parent
    self.timeId = nil
    self.countTime = 0
    self:InitPanel()
end

function LotteryRecordItem:__delete()
	self.btnImg.sprite = nil
	if self.timeId ~= nil then
		LuaTimer.Delete(self.timeId)
		self.timeId = nil
	end
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end
end

function LotteryRecordItem:InitPanel()
    self.transform = self.gameObject.transform

    self.slot = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:Find("Slot").gameObject, self.slot.gameObject)
    self.name = self.transform:Find("Name"):GetComponent(Text)
    self.slider = self.transform:Find("Slider"):GetComponent(Slider)
    self.desc1 = self.transform:Find("Desc1"):GetComponent(Text)
    self.desc2 = self.transform:Find("Desc2"):GetComponent(Text)
    self.desc3 = self.transform:Find("Desc3"):GetComponent(Text)
    self.desc4 = self.transform:Find("Desc4"):GetComponent(Text)
    self.result = self.transform:Find("Result"):GetComponent(Text)

    self.ImgGetReward = self.transform:Find("ImgGetReward").gameObject

    self.btn1Obj = self.transform:Find("Button1").gameObject
    self.btn1 = self.btn1Obj:GetComponent(Button)
    self.btnImg = self.btn1Obj:GetComponent(Image)
    self.btn1.onClick:AddListener(function() self:Join() end)
    self.btn1Txt = self.btn1Obj.transform:Find("Text"):GetComponent(Text)

    self.btn2Obj = self.transform:Find("Button2").gameObject
    self.btn2 = self.btn2Obj:GetComponent(Button)
    self.btn2.onClick:AddListener(function() self:ShowDetail() end)
    self.btn2Txt = self.btn2Obj.transform:Find("Text"):GetComponent(Text)

    self.timeObj = self.transform:Find("Time").gameObject
    self.timeVal = self.transform:Find("Time/Text"):GetComponent(Text)
    self.timeVal.color = Color(255/255, 255/255, 154/255)
    for i = 1, 6 do
        self.transform:Find("Time"):GetChild(i).gameObject:SetActive(false)
    end
    self.timeTips = self.transform:Find("Time/Tips"):GetComponent(Text)
end

function LotteryRecordItem:update_my_self(data)
	if data == nil or self.gameObject == nil then
		return
	end

    self.data = data
    self.itemData = ItemData.New()
    self.itemData:SetBase(BaseUtils.copytab(DataItem.data_get[self.data.item_id]))
    self.itemData.quantity = self.data.item_count
    self.slot:SetAll(self.itemData)

    self.name.text = ColorHelper.color_item_name(self.itemData.quality, self.itemData.name)
    self.desc1.text = string.format(TI18N("状态:<color='#00ff00'>%s</color>"), LotteryEumn.StateName[self.data.state])
    self.desc2.text = string.format(TI18N("我已参与:<color='#00ff00'>%s</color>"), self.data.times_my)
    self.desc3.text = string.format(TI18N("总参与:<color='#00ff00'>%s</color>"), self.data.times_now)
    self.desc4.text = string.format(TI18N("剩余:<color='#00ff00'>%s</color>"), self.data.times_sum - self.data.times_now)
    self.slider.value = self.data.times_now / self.data.times_sum

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

    -- self.ImgGetReward
    if self.parent.currIndex == 2 or self.parent.currIndex == 3 then
        if RoleManager.Instance.RoleData.id == self.data.rid and RoleManager.Instance.RoleData.zone_id == self.data.zone_id and     RoleManager.Instance.RoleData.platform == self.data.platform then
            self.ImgGetReward:SetActive(true)
        else
            self.ImgGetReward:SetActive(false)
        end
    else
        self.ImgGetReward:SetActive(false)
    end

    local serverName = TI18N("神秘大陆")
    for k, v in pairs(DataServerList.data_server_name) do
        if v.platform == self.data.platform and v.zone_id == self.data.zone_id then
            serverName = v.platform_name
            break
        end
    end

    self.result.text = string.format(TI18N("获奖者:<color='#b031d5'>%s</color>\n参与人次:<color='#ffff00'>%s/%s</color>\n幸运号码:<color='#ffff00'>%s</color>\n%s<color='#c7f9ff'>%s</color>"), self.data.role_name, self.data.times_lottery, self.data.times_sum, tempStr, TI18N("来自："), serverName)
    self:UpdateState()
end

function LotteryRecordItem:Join()
    LotteryManager.Instance.model:OpenJoinPanel(self.data)
end

function LotteryRecordItem:ShowDetail()
    LotteryManager.Instance:Send16903(self.data.idx)
    -- LotteryManager.Instance.model:OpenDetail(self.data)
end

function LotteryRecordItem:UpdateState()
    -- 是否参与
    if self.data.times_my == 0 then
        self.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.result.gameObject:SetActive(false)
        self.btn1Obj:SetActive(true)
        self.btn1Txt.text = TI18N("立即参与")
    else
        self.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.result.gameObject:SetActive(false)
        self.btn1Obj:SetActive(true)
        self.btn1Txt.text = TI18N("继续追加")
    end

    -- 单项状态
    if self.data.state == LotteryEumn.State.Joining then
        -- 活动参与中
        self.result.gameObject:SetActive(false)
        self.timeObj:SetActive(false)
        self.btn1Obj:SetActive(true)
    elseif self.data.state == LotteryEumn.State.Opening then
        -- 揭晓中
        self.result.gameObject:SetActive(false)
        self.btn1Obj:SetActive(false)
        self.timeObj:SetActive(true)
        self.countTime = self.data.time - BaseUtils.BASE_TIME
        self.timeTips.text = TI18N("揭晓倒计时:")
        if self.countTime > 0 then
	        self:Loop()
	        self:TimeCount()
        end
    -- elseif self.data.state == LotteryEumn.State.Showing then
    --     self.result.gameObject:SetActive(false)
    --     self.btn1Obj:SetActive(false)
    --     self.timeObj:SetActive(true)
    --     self.timeTips.text = "刷新倒计时:"
    --     self.countTime = self.data.time - BaseUtils.BASE_TIME
    --     if self.countTime > 0 then
	   --      self:Loop()
	   --      self:TimeCount()
    --     end
    -- elseif self.data.state == LotteryEumn.State.Over then
   	else
        -- 结束
        self.result.gameObject:SetActive(true)
        self.btn1Obj:SetActive(false)
        self.timeObj:SetActive(false)
        self.desc4.text = string.format("<color='#00ff00'>%s</color>", os.date("%Y-%m-%d %H:%M", self.data.time))
    end
end

function LotteryRecordItem:TimeCount()
	self:TimeStop()
	self.timeId = LuaTimer.Add(0, 1000, function() self:Loop() end)
end

function LotteryRecordItem:TimeStop()
	if self.timeId ~= nil then
		LuaTimer.Delete(self.timeId)
		self.timeId = nil
	end
end

function LotteryRecordItem:Loop()
	if self.countTime <= 0 then
		self:TimeStop()
        LotteryManager.Instance:RefreshData(1)
		return
	end
	local _,hour,min,sec = BaseUtils.time_gap_to_timer(self.countTime)
	if hour < 10 then
		hour = "0"..hour
	end
	if min < 10 then
		min = "0"..min
	end
	if sec < 10 then
		sec = "0"..sec
	end
	local list = StringHelper.ConvertStringTable(string.format("%s%s%s", hour, min, sec))
    self.timeVal.text = string.format("%s%s:%s%s:%s%s", list[1], list[2], list[3], list[4], list[5], list[6])
	self.countTime = self.countTime - 1
	list = nil
end