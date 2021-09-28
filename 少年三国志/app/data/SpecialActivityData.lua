
require("app.cfg.special_holiday_info")
require("app.cfg.special_holiday_sale")
require("app.cfg.special_holiday_change")

local SpecialHolidayActivityInfoMeta= class("SpecialHolidayActivityInfoMeta")
 
function SpecialHolidayActivityInfoMeta:ctor( data )
    self:updateData(data)
end
 
function SpecialHolidayActivityInfoMeta:updateData( data )
    self.id         = data and data.id or 0
    self.progress       = data and data.progress or 0
    self.award_count      = data and data.award_count or 0
    self.can_award      = data and data.can_award or false
end

local SpecialActivityData = class("SpecialActivityData")

SpecialActivityData.TIMECOUNT = 4
SpecialActivityData.TABCOUNT = 4

function SpecialActivityData:ctor()
    self._activityInfoList = {}
    self._activitySaleList = {}
    self._startTime = 0
    self._endTime = 0
    self._inHoliday = false
    self._holidayData = nil
    self._shopData = nil
    self._curLevel = 0
    self._timeList = nil

    self._changeData = {}
    self:initChangeData()
end

function SpecialActivityData:initData( data )
    self._inHoliday = data.in_holiday or false
    self._startTime = data.start_time or 0
    self._endTime = data.end_time or 0
    self:initInfoList(data.infos)
end

function SpecialActivityData:initInfoList( data )
    self._activityInfoList = {}
    if not data then
        return
    end
    for key, value in pairs(data) do 
        table.insert(self._activityInfoList, #self._activityInfoList + 1, SpecialHolidayActivityInfoMeta.new(value))
    end
end

function SpecialActivityData:updateInfoList( data )
    local idata = SpecialHolidayActivityInfoMeta.new(data)
    local find = false
    for k , v in pairs(self._activityInfoList) do 
        if v.id == idata.id then
            v:updateData(idata)
            find = true
            break
        end
    end
    if not find then
        table.insert(self._activityInfoList, #self._activityInfoList + 1, idata)
    end
end

function SpecialActivityData:initSaleList( data )
    self._activitySaleList = {}
    if rawget(data,"id") then
        for key, value in pairs(data.id) do 
            table.insert(self._activitySaleList, #self._activitySaleList + 1, {id=value,count=data.buyed_cnt[key]})
        end
    end
end

function SpecialActivityData:updateSaleList( data )
    local find = false
    for k , v in pairs(self._activitySaleList) do 
        if v.id == data.id then
            v.count = data.buyed_cnt
            find = true
            break
        end
    end
    if not find then
        table.insert(self._activitySaleList, #self._activitySaleList + 1, {id=data.id,count=data.buyed_cnt})
    end
end

function SpecialActivityData:analysData( )
    self._holidayData = {}
    self._shopData = {}
    self._timeList = {}
    for i = 1 , SpecialActivityData.TIMECOUNT do 
        self._holidayData[i] = {}
        for j = 1 , SpecialActivityData.TABCOUNT do 
            self._holidayData[i][j] = {}
        end
    end
    for i = 1 , special_holiday_info.getLength() do 
        data = special_holiday_info.indexOf(i)
        if data.limit_time > 0 then
            table.insert(self._holidayData[data.limit_time][data.tags],#self._holidayData[data.limit_time][data.tags]+1,data)
            if not rawget(self._timeList,data.limit_time) then
                self._timeList[data.limit_time] = {startTime=data.start_time,endTime=data.end_time}
            else
                if self._timeList[data.limit_time].startTime > data.start_time then
                    self._timeList[data.limit_time].startTime = data.start_time
                end
                if self._timeList[data.limit_time].endTime < data.end_time then
                    self._timeList[data.limit_time].endTime = data.end_time
                end
            end
        end
    end
    for i = 1 , special_holiday_sale.getLength() do 
        data = special_holiday_sale.indexOf(i)
        self._curLevel = G_Me.userData.level
        if self._curLevel >= data.level_min and self._curLevel <= data.level_max then
            if data.tags == 1 then
                table.insert(self._holidayData[tonumber(data.limit_time)][4],#self._holidayData[tonumber(data.limit_time)][4]+1,data)
            elseif data.tags == 2 then
                table.insert(self._shopData,#self._shopData+1,data)
            end
        end
    end
    local sortFunc = function ( a,b )
        if a.arrange ~= b.arrange then
            return a.arrange < b.arrange
        end
        return a.id < b.id
    end
    for i = 1 , SpecialActivityData.TIMECOUNT do 
        for j = 1 , SpecialActivityData.TABCOUNT do 
            table.sort( self._holidayData[i][j], sortFunc )
        end
    end
    table.sort( self._shopData, sortFunc )
end

function SpecialActivityData:getInfoData( time,tag)
    if not self._holidayData then
        self:analysData()
    end
    if self._curLevel ~= G_Me.userData.level then
        self:analysData()
    end
    return self._holidayData[time][tag]
end

function SpecialActivityData:getShopData()
    if not self._shopData then
        self:analysData()
    end
    if self._curLevel ~= G_Me.userData.level then
        self:analysData()
    end
    return self._shopData
end

function SpecialActivityData:getCurInfo( id)
    for k , v in pairs(self._activityInfoList) do 
        if v.id == id then
            return v
        end
    end
    return nil
end

function SpecialActivityData:getCurShop( id)
    for k , v in pairs(self._activitySaleList) do 
        if v.id == id then
            return v
        end
    end
    return nil
end

function SpecialActivityData:getTime( index)
    if not self._timeList then
        self:analysData()
    end
    return self._timeList[index]
end

function SpecialActivityData:getTotalEndTime()
    local time = G_ServerTime:getDateObject(self._endTime)
    if time.hour == 0 then
        time.day = time.day - 1 
        time.hour = 24
    end
    local timeStr = G_lang:get("LANG_SPECIAL_ACTIVITY_TIME_FORMAT2",{year=time.year,month=time.month,day=time.day,hour=time.hour})
    return timeStr
end

function SpecialActivityData:isInActivityTime( )
    local arr1 = G_ServerTime:getLeftSeconds(self._startTime)
    local arr2 = G_ServerTime:getLeftSeconds(self._endTime)
    return arr1 <= 0 and arr2 >= 0 and self._inHoliday
end

function SpecialActivityData:getCurIndex( )
    if not self._timeList then
        self:analysData()
    end
    for i = 1 , SpecialActivityData.TIMECOUNT  do 
        if self._timeList[i] then
            local arr1 = G_ServerTime:getLeftSeconds(self._timeList[i].startTime)
            local arr2 = G_ServerTime:getLeftSeconds(self._timeList[i].endTime)
            if arr1 <= 0 and arr2 >= 0 then
                return i
            end
        end
    end
    return 1
end

function SpecialActivityData:needTip( index,day)
    local timeIndex = day or self:getCurIndex()
    if self._holidayData and self._holidayData[timeIndex][index] then
        for k , v in pairs(self._holidayData[timeIndex][index]) do
            local curInfo = G_Me.specialActivityData:getCurInfo(v.id)
            if curInfo and curInfo.can_award then
                if ( v.task_type ~= 1 and curInfo.award_count == 0 ) or ( v.task_type == 1 and (v.task_value2 == 0 or curInfo.award_count < v.task_value2) ) then
                    return true
                end
            end
        end
    end
    return false
end

function SpecialActivityData:needTips( )
    if not self._holidayData then
        self:analysData()
    end
    for i = 1 , SpecialActivityData.TABCOUNT - 1 do 
        if self:needTip(i) then
            return true
        end
    end
    return false
end

function SpecialActivityData:getInfoArrange( id )
    local data = special_holiday_info.get(id)
    local info = self:getCurInfo(id)
    if not info then
        return data.arrange + 100000
    end
    local hasGot = (data.task_type == 1 and data.task_value2 > 0 and info.award_count >= data.task_value2) or (data.task_type ~= 1 and info.award_count >= 1)
    if hasGot then
        return data.arrange + 200000
    elseif info.can_award then
        return data.arrange
    else
        return data.arrange + 100000
    end
end

function SpecialActivityData:getSaleArrange( id )
    local data = special_holiday_sale.get(id)
    local info = self:getCurShop(id)
    if not info then
        return data.arrange
    end
    local hasGot = data.time_self > 0 and info.count >= data.time_self
    if hasGot then
        return data.arrange + 100000
    else
        return data.arrange
    end
end

function SpecialActivityData:canShop( )
    if not self._shopData then
        self:analysData()
    end
    for k , v in pairs(self._shopData) do
                local awardDataList = {{type=v.price_type,value=0,size=v.price},
                            {type=v.extra_type,value=v.extra_value,size=v.extra_size},
                            {type=v.extra_type2,value=v.extra_value2,size=v.extra_size2},}
                local has = true
                local info = self:getCurShop(v.id)
                if info and v.time_self > 0 and v.time_self <= info.count then
                    has = false
                else
                    for key , value in pairs(awardDataList) do 
                        if value.type > 0 then
                            local good = G_Goods.convert(value.type,value.value,value.size)
                            if not G_Goods.checkOwnGood(good) then
                                has = false
                            end
                        end
                    end
                end
                if has then
                    return true
                end
    end
    return false
end

function SpecialActivityData:initChangeData()
    self._changeData = {}
    for i = 1 , special_holiday_change.getLength() do 
        local info = special_holiday_change.indexOf(i)
        self._changeData[info.type] = info.type_value
    end
end

function SpecialActivityData:getTitleCount()
    return self._changeData[1] or 0
end

function SpecialActivityData:getTabName(tab,index)
    local default = 1
    local name = self._changeData[tab*10+index] or self._changeData[tab*10+default]
    return name
end

function SpecialActivityData:getTitleName(index)
    return self._changeData[50+index] or ""
end

function SpecialActivityData:getMoneyId()
    return tonumber(self._changeData[2]), tonumber(self._changeData[3])
end

return SpecialActivityData
