-- @author 黄耀聪
-- @date 2016年7月22日

AuctionListItem = AuctionListItem or BaseClass()

function AuctionListItem:__init(model, gameObject, callback)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.callback = callback

    local t = self.transform

    self.nameText = t:Find("Name/Text"):GetComponent(Text)
    self.timeText = t:Find("Time/Text"):GetComponent(Text)
    self.clockObj = t:Find("Time/Clock").gameObject
    self.clockText = t:Find("Time/Clock/Text"):GetComponent(Text)
    self.priceText = t:Find("Price/Text"):GetComponent(Text)
    self.bgObj = t:Find("Bg").gameObject
    self.select = t:Find("Select").gameObject

    self.priceExt = MsgItemExt.New(self.priceText, 120, 16, 19)
    self.btn = gameObject:GetComponent(Button)
    if self.btn == nil then
        self.btn = gameObject:AddComponent(Button)
    end
    self.btn1 = t:Find("Notice/Btn1"):GetComponent(Button)
    self.btn2 = t:Find("Notice/Btn2"):GetComponent(Button)

    self.btn1.onClick:AddListener(function() if self.idx ~= nil then AuctionManager.Instance:send16702(self.idx) end end)
    self.btn2.onClick:AddListener(function() if self.idx ~= nil then AuctionManager.Instance:send16702(self.idx) end end)
    self.btn.onClick:AddListener(function()
        if self.idx ~= nil and self.callback ~= nil then
            self.callback(self.idx)
        end
    end)
end

function AuctionListItem:__delete()
    if self.priceExt ~= nil then
        self.priceExt:DeleteMe()
        self.priceExt = nil
    end
end

function AuctionListItem:update_my_self(data, index)
    local model = self.model
    if self.idx ~= nil and model.datalist[self.idx] ~= nil then
        model.datalist[self.idx].item = nil
    end
    self.idx = data.idx
    data.item = self
    if index ~= nil then
        self.bgObj:SetActive(index % 2 == 0)
    end
    self.select:SetActive(self.idx == model.selectIdx)
    local basedata = DataItem.data_get[data.item_id]
    self.nameText.text = basedata.name
    self.priceExt:SetData(string.format("%s{assets_2, 90002}", tostring(data.gold)))

    local size = self.priceExt.contentRect.sizeDelta
    self.priceExt.contentRect.anchoredPosition = Vector2(40 - size.x, size.y / 2)

    self.btn1.gameObject:SetActive(data.focus ~= 1)
    self.btn1.gameObject:SetActive(data.focus == 1)

    self:OnTime()
end

function AuctionListItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function AuctionListItem:Select(bool)
    self.select:SetActive(bool)
end

function AuctionListItem:OnTime()
    local data = self.model.datalist[self.idx]
    if data == nil then
        return
    end
    if data.state == 1 then
        self.clockText.text = TI18N("未开始")
        self.timeText.gameObject:SetActive(false)
        self.clockObj:SetActive(true)
    elseif data.state == 3 or data.state == 4 then
        self.clockText.text = TI18N("已结束")
        self.timeText.gameObject:SetActive(false)
        self.clockObj:SetActive(true)
    else
        self.timeText.gameObject:SetActive(true)
        self.clockObj:SetActive(false)
        local d = nil
        local h = nil
        local m = nil
        local s = nil
        if data.over_time - BaseUtils.BASE_TIME > 0 then
            d,h,m,s = BaseUtils.time_gap_to_timer(data.over_time - BaseUtils.BASE_TIME)
            if d > 0 then
                self.timeText.text = string.format(TI18N("%s天%s小时"), tostring(d), tostring(h))
            elseif h > 0 then
                self.timeText.text = string.format(TI18N("%s小时%s分"), tostring(h), tostring(m))
            elseif m > 0 then
                self.timeText.text = string.format(TI18N("%s分%s秒"), tostring(m), tostring(s))
            elseif s > 0 then
                self.timeText.text = string.format(TI18N("%s秒"), tostring(s))
            end
        else
            self.timeText.text = string.format(TI18N("%s秒"), tostring(0))
        end
    end
end


