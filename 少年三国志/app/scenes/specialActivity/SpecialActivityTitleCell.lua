local SpecialActivityTitleCell = class ("SpecialActivityTitleCell", function (  )
    return CCSItemCellBase:create("ui_layout/specialActivity_TitleItem.json")
end)

function SpecialActivityTitleCell:ctor(index)
    self._titleLabel = self:getLabelByName("Label_title")
    self._timeTitleLabel = self:getLabelByName("Label_timeTitle")
    self._timeLabel = self:getLabelByName("Label_time")

    self._titleLabel:createStroke(Colors.strokeBrown,2)
    self._timeTitleLabel:createStroke(Colors.strokeBrown,1)
    self._timeLabel:createStroke(Colors.strokeBrown,1)

    local titleTxt = G_Me.specialActivityData:getTitleName(index)
    self._titleLabel:setText(titleTxt)
    -- self._timeLabel:setText(G_lang:get("LANG_SPECIAL_ACTIVITY_TIME"..index))
    local time = G_Me.specialActivityData:getTime(index)
    local startTime = G_ServerTime:getDateObject(time.startTime)
    local endTime = G_ServerTime:getDateObject(time.endTime)
    if endTime.hour == 0 then
        endTime.day = endTime.day - 1 
        endTime.hour = 24
    end
    local timeStr1 = G_lang:get("LANG_SPECIAL_ACTIVITY_TIME_FORMAT1",{month=startTime.month,day=startTime.day,hour=startTime.hour})
    local timeStr2 = G_lang:get("LANG_SPECIAL_ACTIVITY_TIME_FORMAT1",{month=endTime.month,day=endTime.day,hour=endTime.hour})
    self._timeLabel:setText(timeStr1.."-"..timeStr2)
end

function SpecialActivityTitleCell:getWidth()
    return 420
end

return SpecialActivityTitleCell

