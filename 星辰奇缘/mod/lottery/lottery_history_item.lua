-- ------------------------------------------
-- 一闷夺宝获奖历史项
-- hosr
-- ------------------------------------------
LotteryHistoryItem = LotteryHistoryItem or BaseClass()

function LotteryHistoryItem:__init(gameObject, parent)
    self.parent = parent
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self:InitPanel()
end

function LotteryHistoryItem:__delete()
end

function LotteryHistoryItem:InitPanel()
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.transform = self.gameObject.transform

    self.desc1 = self.transform:Find("Desc1"):GetComponent(Text)
    self.JoinTimeTxt = self.transform:Find("JoinTimeTxt"):GetComponent(Text)
    self.NeedNumTxt = self.transform:Find("NeedNumTxt"):GetComponent(Text)

    self.desc1.text = ""
    self.JoinTimeTxt.text = ""
    self.NeedNumTxt.text = ""
end

function LotteryHistoryItem:update_my_self(_data, _index)
    self.data = _data
    local baseData = DataItem.data_get[_data.item_id]
    local itemName = ColorHelper.color_item_name(baseData.quality, string.format("[%s]",baseData.name))

    if _data.item_count > 1 then
        self.desc1.text = string.format("%s<color='#38F0F6'>%s</color>%s%sx%s", TI18N("恭喜"), _data.role_name, TI18N("夺得"),itemName, _data.item_count)
    else
        self.desc1.text = string.format("%s<color='#38F0F6'>%s</color>%s%s", TI18N("恭喜"), _data.role_name, TI18N("夺得"),itemName)
    end
    self.JoinTimeTxt.text = string.format("%s<color='#2fc823'>%s</color>%s", TI18N("参与"), _data.times_buy, TI18N("人次"))
    self.NeedNumTxt.text = string.format("%s<color='#2fc823'>%s</color>%s", TI18N("总共"), _data.times_sum, TI18N("人次"))

    -- local year = os.date("%y", _data.time)
    -- local month = os.date("%m", _data.time)
    -- local day = os.date("%d", _data.time)
    -- local hour = os.date("%H", _data.time)
    -- local min = os.date("%M", _data.time)
    -- local sec = os.date("%S", _data.time)
    -- local str1 = string.format("20%s.%s.%s", year, month, day)
    -- local str2 = string.format("%s:%s:%s", hour, min, sec)
    -- self.TimeTxt.text = string.format("%s %s", str1, str2)
end
