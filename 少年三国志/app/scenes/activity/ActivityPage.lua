local ActivityPage = class("ActivityPage",function ()
    return CCSPageCellBase:create("ui_layout/activity_ActivityPage.json")
end)

local ActivityPageWine= require("app.scenes.activity.ActivityPageWine")
local ActivityPageCaishen= require("app.scenes.activity.ActivityPageCaishen")
local ActivityPageDaily= require("app.scenes.activity.ActivityPageDaily")
local ActivityPageGiftCode = require("app.scenes.activity.ActivityPageGiftCode")
local FundMainLayer = require("app.scenes.fund.FundMainLayer")
local MonthFundMainLayer = require("app.scenes.monthfund.MonthFundMainLayer")
local ActivityMonthCard = require("app.scenes.activity.ActivityMonthCard")
local ActivityShouChong = require("app.scenes.activity.ActivityShouChong")

local ActivityHoliday = require("app.scenes.activity.ActivityHoliday")

local ActivityLingqu = require("app.scenes.activity.gm.ActivityLingqu")
local ActivityGongGao = require("app.scenes.activity.gm.ActivityGongGao")


local ActivityShareLayer = require("app.scenes.activity.ActivityShareLayer")

local ActivityPhone = require("app.scenes.activity.ActivityPagePhone")
local ActivityFanhuan = require("app.scenes.activity.ActivityPageFanhuan")
local ActivityVipDiscount = require("app.scenes.activity.ActivityPageVipDiscount")
local ActivityInvitor = require("app.scenes.activity.ActivityInvitorLayer")
local ActivityInvited = require("app.scenes.activity.ActivityInvitedLayer")
local ActivityPageRecharge = require("app.scenes.activity.ActivityPageRecharge")
local ActivityUserReturn = require("app.scenes.activity.ActivityUserReturn")
local ActivityPageTaoBaoGift = require("app.scenes.activity.ActivityPageTaoBaoGift")
local ActivitySevenDayFightValueRank = require("app.scenes.activity.ActivitySevenDayFightValueRank")
local ActivityDailyFortune = require("app.scenes.activity.ActivityDailyFortune")

function ActivityPage:ctor()
    -- self:getRootWidget():setContentSize(CCSizeMake(640,1136))
    --self:adapterWidgetHeight("Panel_content", "Panel_top", "Panel_bottom", 0, 0)
    self._activityId = ""
    self._layer = nil
end


function ActivityPage:showPage(activity)
    self:updatePage(activity)
    if self._layer and self._layer.showPage then
        self._layer:showPage()  
    end

    if G_Me.activityData:isGmActivity(activity) then
        local result = G_Me.activityData.custom:setActivityEntered(activity.data.act_id)
        if result then
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)
        end
        --print("--show gm ActivityPage=" .. activity.data.act_id)
    end

end
        
function ActivityPage:updatePage(activity)
    __Log("update page " ..activity.id )
    G_Report:addHistory("activity", "updatePage " .. tostring(activity.id))
    if self._activityId ~= activity.id then
        if self._layer ~= nil then
            G_Report:addHistory("activity", "remove " .. tostring(self._layer))
            self._layer:removeFromParentAndCleanup(true)
            self._layer = nil
        end

        local page 

        if activity.id == "caishen" then
            page = ActivityPageCaishen.create()

        elseif activity.id == "wine" then
            page = ActivityPageWine.create()
        elseif activity.id == "daily" then
            page = ActivityPageDaily.create()
        elseif activity.id == "giftcode" then
            page = ActivityPageGiftCode.create()
        elseif activity.id == "fund" then
            page = FundMainLayer.create()
        elseif activity.id == "monthfund" then
            page = MonthFundMainLayer.create()
        elseif activity.id == "invitor" then
            page = ActivityInvitor.create()
        elseif activity.id == "invited" then
            page = ActivityInvited.create()
        elseif activity.id == "month_card" then
            --月卡
            page = ActivityMonthCard.create()
        elseif activity.id == "shou_chong" then
            page = ActivityShouChong.create()
        -- elseif activity.id == "lingqu" then
        elseif string.match(activity.id,"lingqu") then
            page = ActivityLingqu.create(activity.data.act_id)
        -- elseif activity.id == "xianshi" then
        elseif string.match(activity.id,"xianshi") then
            page = ActivityGongGao.create(activity.data.act_id)
        -- elseif activity.id == "wupinduihuan" then
        elseif string.match(activity.id,"wupinduihuan") then 
            page = ActivityLingqu.create(activity.data.act_id)
        -- elseif activity.id == "chongzhi" then
        elseif string.match(activity.id,"chongzhi") then
            page = ActivityLingqu.create(activity.data.act_id)
        elseif activity.id == "holiday" then
            --圣诞活动
            page = ActivityHoliday.create(activity.data)
        elseif activity.id == "share" then
            page = ActivityShareLayer.create()
        elseif activity.id == "phone" then
            page = ActivityPhone.create()
        elseif activity.id == "fanhuan" then
            page = ActivityFanhuan.create()
        elseif activity.id == "vipDiscount" then
            page = ActivityVipDiscount.create()
        elseif activity.id == "activity_recharge" then
            page = ActivityPageRecharge.create()
        elseif activity.id == "userReturn" then
            page = ActivityUserReturn.create()
        elseif activity.id == "taobao_gift" then
            page = ActivityPageTaoBaoGift.create()
        elseif activity.id == "fightvaluerank" then
            page = ActivitySevenDayFightValueRank.create()
        elseif activity.id == "daily_fortune" then
            page = ActivityDailyFortune.create()
        else 
            page = ActivityPageWine.create()
        end

        self._layer = page 
        if self._layer then
            if self._layer.updatePage then
                self._layer:updatePage(activity)
            end

            local cellSize = self:getSize()
            -- print("cellsize:" .. cellSize.width .. "," .. cellSize.height)
            local layerSize = CCSizeMake(640, cellSize.height)
            self._layer:getRootWidget():setSize(layerSize)

            --    -- local layerSize = self._layer:getSize()
            --   --  print("cellsize:" .. layerSize.width .. "," .. layerSize.height)
            
            -- self._layer:setPosition(ccp(0, 0))
            self:getRootWidget():addNode(page)
            if self._layer.adapterLayer then
                self._layer:adapterLayer()
            end
        end
    else
        if self._layer and self._layer.updatePage then
            self._layer:updatePage(activity)
        end
    end

   
    self._activityId = activity.id


end





return ActivityPage

