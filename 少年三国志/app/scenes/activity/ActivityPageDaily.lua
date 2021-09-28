require("app.cfg.login_reward_info_1")
require("app.cfg.login_reward_info_vip")
require ("app.cfg.knight_info")
local ActivityPageDaily = class("ActivityPageDaily", UFCCSNormalLayer )
local ActivityDailyCell = require("app.scenes.activity.ActivityDailyCell")

function ActivityPageDaily.create(...)
    return ActivityPageDaily.new("ui_layout/activity_ActivityDaily.json")
end

function ActivityPageDaily:ctor(...)
    self._isFirstTimeEnter = true
    self._loginRewardList = {}
    self._vipRewardList = {}
    self.super.ctor(self, ...)
    self.tabs = require("app.common.tools.Tabs").new(1, self, self._onCheckCallback)

    self._awardPanel = self:getPanelByName("Panel_awardIcon")

    self._views = {}
    self:_createStroke()
    self:_initListData()
end

function ActivityPageDaily:adapterLayer()
    
end

function ActivityPageDaily:_createStroke()
    self:getLabelByName("Label_titleTip"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_22"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_22_0"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_22_1"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_Bottom"):createStroke(Colors.strokeBrown,1)
    
end

function ActivityPageDaily:_initListData( ... )
    self._loginRewardList = {}
    for i=1,login_reward_info_1.getLength() do
        local item = login_reward_info_1.indexOf(i)
        if item and G_Me.activityData.daily:getNormalDailyType() == item.type then
            table.insert(self._loginRewardList,item)
        end
    end

    for i=1,login_reward_info_vip.getLength() do 
        local item = login_reward_info_vip.indexOf(i)
        if item then
            table.insert(self._vipRewardList,item)
        end
    end
end

function ActivityPageDaily:_onCheckCallback(checkName)
    if checkName == "CheckBox_meiri" then
        self:getLabelByName("Label_titleTip"):setText(G_lang:get("LANG_ACTIVITY_DAILY_MEIRI"))
        self:showWidgetByName("Label_titleTip",true)
        self:showWidgetByName("Panel_viptips",false)
        self:showWidgetByName("Panel_zhezhao",true)
        self:showWidgetByName("Panel_Haohua",false)
        self:_initNormalListView()
    else
        self:showWidgetByName("Label_titleTip",false)
        self:showWidgetByName("Panel_viptips",false)
        self:showWidgetByName("Panel_zhezhao",false)
        self:showWidgetByName("Panel_Haohua",true)
        self:_initVIPView()
    end
end


function ActivityPageDaily:onLayerEnter()
    self:adapterWidgetHeight("Panel_listviewContent","","",270,0)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ACTIVITY_DATA_DAILY_UPDATED, self._onDailyUpdated, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ACTIVITY_FINISH_DAILY, self._onDailyFinish, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECHARGE_SUCCESS, self.updatePage, self) 
    
end

function ActivityPageDaily:onLayerExit()
   uf_eventManager:removeListenerWithTarget(self)
end

function ActivityPageDaily:_onDailyFinish(data)  
    if data and data.ret == 1 then
        --领取成功  totals就是id
        local info = nil
        if data.type == 0 then --普通
            info = login_reward_info_1.get(G_Me.activityData.daily:getNormalDailyType(), G_Me.activityData.daily:getNormalDailyDay())
            if info then
                --构建一个type value size
                local size = 0
                if info.vip_level ~= 0 and G_Me.userData.vip >= info.vip_level then
                    size = info.size_1 * 2
                else
                    size = info.size_1
                end
                local awards = {{type=info.type_1,value=info.value_1,size=size}}
                local words = ""
                if info.vip_level >0 and G_Me.userData.vip >= info.vip_level then
                    --满足vip条件
                    words = G_lang:get("LANG_ACTIVITY_DAILY_SIGN_SUCCESS_VIP")
                else
                    words = G_lang:get("LANG_ACTIVITY_DAILY_SIGN_SUCCESS")
                end
                local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awards,nil,words)
                uf_notifyLayer:getModelNode():addChild(_layer)
            end
        else  --豪华
            info = login_reward_info_vip.get(data.vipid)
            if info then
                --构建一个type value size
                local awards = {{type=info.type_1,value=info.value_1,size=info.size_1},
                                {type=info.type_2,value=info.value_2,size=info.size_2},}
                local words = G_lang:get("LANG_ACTIVITY_DAILY_SIGN_SUCCESS")
                local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awards,nil,words)
                uf_notifyLayer:getModelNode():addChild(_layer)
            end
        end
    end
end

function ActivityPageDaily:_onDailyUpdated(data)

    self:_initListData()

    self:updatePage()   
    if self._isFirstTimeEnter then
        self._tabs = require("app.common.tools.Tabs").new(1, self, self._onCheckCallback)
        self._tabs:add("CheckBox_meiri", nil)
        self._tabs:add("CheckBox_haohua", nil)
        self._tabs:checked("CheckBox_meiri")
        self._isFirstTimeEnter = false
    end
    self:_showTips()    
end

--红点机制
function ActivityPageDaily:_showTips()
    self:showWidgetByName("Image_meiriTips",G_Me.activityData.daily:isActivate())
    -- self:showWidgetByName("Image_vipTips",G_Me.activityData.daily:isVipActivate() and G_Me.activityData.daily.cost)
    --无论是否充值都显示
    self:showWidgetByName("Image_vipTips",G_Me.activityData.daily:isVipActivate())
end

function ActivityPageDaily:showPage()  
    self:callAfterFrameCount(2, function() 
       G_HandlersManager.activityHandler:sendLoginRewardInfo()   
    end)
end

function ActivityPageDaily:updatePage()
    if self._normalListView then
        self._normalListView:refreshAllCell()
    end
    self:updateAward()
end

--每日签到Listview
function ActivityPageDaily:_initNormalListView()
    if self._normalListView == nil then
        local panel = self:getPanelByName("Panel_meirilist")
        self._normalListView = CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
        self._tabs:add("CheckBox_meiri", self._normalListView)
        self._normalListView:setCreateCellHandler(function(list,index)
            local item = ActivityDailyCell.new()        
            return item
        end)
        self._normalListView:setUpdateCellHandler(function(list,index,cell)
            if not cell then
                return
            end
            cell:updateNormal(self._loginRewardList[index+1])
            cell:setSignFunc(function()
                G_HandlersManager.activityHandler:sendLoginReward(0)
                end)
        end)

        local start = G_Me.activityData.daily:getNormalDailyDay() or 0
        self._normalListView:reloadWithLength(#self._loginRewardList,start)
        self._normalListView:setSpaceBorder(0,50)
        self._normalListView:scrollToShowCell(start,0)
    end
end


--豪华签到list
function ActivityPageDaily:_initVIPView()

    self._heroPanel = self:getPanelByName("Panel_hero")
    self._bubbleImg = self:getImageViewByName("Image_bubble")

    self:setMeinv()
    self:_bubbleShow()
    self:updateAward()

end

function ActivityPageDaily:setMeinv()
    local GlobalConst = require("app.const.GlobalConst")
    local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    local knight = nil
    if appstoreVersion or IS_HEXIE_VERSION  then 
        knight = knight_info.get(GlobalConst.CAI_WEN_JI_HE_XIE_ID)
    else
        knight = knight_info.get(GlobalConst.CAI_WEN_JI_ID)
    end
    self._heroPanel:removeAllChildrenWithCleanup(true)
    if knight then
        local hero = KnightPic.createKnightButton( knight.res_id, self._heroPanel, "meinv",self,function ( )
            self._changed = true
            self:_bubbleShow()
        end )
        hero:setScale(0.8)
        local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
        self._bossEffect = EffectSingleMoving.run(hero, "smoving_idle", nil, {})
    end
end

function ActivityPageDaily:_bubbleShow()
    if self._bubbleRichText == nil then
        self._bubbleLabel = self:getLabelByName("Label_bubble")
        self._bubbleLabel:setVisible(false)
        self._bubbleRichText = GlobalFunc.createRichTextFromTemplate(self._bubbleLabel, 
            self._bubbleImg, 
            G_lang:get("LANG_ACTIVITY_DAILY_HAOHUA_RICH"))
    end
    GlobalFunc.sayAction(self._bubbleImg)
end

function ActivityPageDaily:updateAward()

    self._vipId = G_Me.activityData.daily.vipid == 0 and 1 or G_Me.activityData.daily.vipid

    self._awardPanel:removeAllChildrenWithCleanup(true)

    local info = login_reward_info_vip.get(self._vipId)
    local offset = 5
    local width = 100
    local award = {}
    for index = 1 , 2 do 
        if info["type_"..index] > 0 then
            local item = {type=info["type_"..index],value=info["value_"..index],size=info["size_"..index]}
            table.insert(award,#award+1,item)
        end
    end
    GlobalFunc.createIconInPanel({panel=self._awardPanel,award=award,click=true})

    local priceLabel = self:getLabelByName("Label_beforePriceNum")
    priceLabel:setText(info.price)

    self:registerBtnClickEvent("Button_buy", function()
        if G_Me.activityData.daily.cost then 
            G_HandlersManager.activityHandler:sendLoginReward(1)
        else
            require("app.scenes.shop.recharge.RechargeLayer").show()
        end
    end)

    self:showWidgetByName("Button_buy", G_Me.activityData.daily:isVipActivate())
    self:showWidgetByName("Image_bought",not G_Me.activityData.daily:isVipActivate())
    if not G_Me.activityData.daily.cost then
        self:getImageViewByName("Image_28"):loadTexture(G_Path.getSmallBtnTxt("chongzhi.png"))
    else
        self:getImageViewByName("Image_28"):loadTexture(G_Path.getSmallBtnTxt("lingqu.png"))
    end

    self:getLabelByName("Label_Bottom"):setText(G_lang:get("LANG_ACTIVITY_DAILY_HAOHUA_DESC"))
end

return ActivityPageDaily
