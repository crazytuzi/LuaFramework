local ActivityPageVipDiscount = class("ActivityPageVipDiscount", UFCCSNormalLayer )
local KnightPic = require("app.scenes.common.KnightPic")
local FunctionLevelConst = require "app.const.FunctionLevelConst"
require("app.cfg.vip_level_info")
require("app.cfg.vip_discount_store")
require("app.cfg.vip_daily_boon")

function ActivityPageVipDiscount.create(...)
    return ActivityPageVipDiscount.new("ui_layout/activity_ActivityVipDiscount.json")
end


function ActivityPageVipDiscount:onLayerEnter()
    -- uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_VIPDISCOUNTINFO, self._onVipDiscountInfo, self) 
    -- uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_BUYVIPDISCOUNT, self._onBuyVipDiscount, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_VIPDAILYINFO, self._onVipDailyInfo, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_BUYVIPDAILY, self._onBuyVipDaily, self)
    -- self:updateView()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_VIPWEEKSHOPINFO, self._onVipWeekShopInfo, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_VIPWEEKSHOPBUY, self._onVipWeekShopBuy, self) 

    self._tabs:checked("CheckBox_fuli")
    G_HandlersManager.activityHandler:sendVipDiscountInfo()
    G_HandlersManager.activityHandler:sendVipWeekShopInfo()
    -- if self._schedule == nil then
    --     self._schedule = GlobalFunc.addTimer(1, handler(self, self._refreshTimeLeft))
    -- end
    self:updateTips()
end

function ActivityPageVipDiscount:updateTips()
    self:getImageViewByName("Image_libao_tip"):setVisible(G_Me.activityData.vipDiscount:hasToBuy())
    self:getImageViewByName("Image_fuli_tip"):setVisible(G_Me.activityData.vipDiscount:hasToGet())
end

function ActivityPageVipDiscount:onLayerExit()
    -- if self._schedule then
    --     GlobalFunc.removeTimer(self._schedule)
    --     self._schedule = nil
    -- end
   uf_eventManager:removeListenerWithTarget(self)
end

function ActivityPageVipDiscount:ctor(...)
    self.super.ctor(self, ...)

    self:getLabelByName("Label_desc"):createStroke(Colors.strokeBrown, 1)
    self._bubbleLabel = self:getLabelByName("Label_bubble")
    self._heroPanel = self:getPanelByName("Panel_hero")
    self._awardPanel = self:getPanelByName("Panel_awardIcon")
    self._bubbleImg = self:getImageViewByName("Image_bubble")
    self._heroPanel2 = self:getPanelByName("Panel_hero2")
    self._listPanel = self:getPanelByName("Panel_list")
    self._dailyListItem = {}
    self._dailyTxt = self:getLabelByName("Label_dailyTxt")
    self._dailyTxt:createStroke(Colors.strokeBrown, 1)
    self._dailyTxt:setText(G_lang:get("LANG_ACTIVITY_VIPDAILY_CONTENT"))

    self._liBaoData = {}

    self._tabs = require("app.common.tools.Tabs").new(1, self, self.onCheckCallback)
    self._tabs:add("CheckBox_fuli", self:getPanelByName("Panel_content2"),"Label_fuli")
    self._tabs:add("CheckBox_libao", self:getPanelByName("Panel_content1"),"Label_libao")

    self:getWidgetByName("CheckBox_libao"):setTouchEnabled(G_moduleUnlock:isModuleUnlock(FunctionLevelConst.VIP_LIBAO))
    -- self._tabs:checked("CheckBox_fuli")

    -- self:registerBtnClickEvent("Button_buy", function()
    --     local info = vip_discount_store.get(self._vipIndex)
    --     if G_Me.userData.vip >= info.vip_level then
    --         if G_Me.userData.gold >= info.current_cost then
    --             -- G_HandlersManager.activityHandler:sendBuyVipDiscount(self._vipIndex)
    --             local str = G_lang:get("LANG_VIP_BUY",{level=info.vip_level})
    --             MessageBoxEx.showYesNoMessage(nil,str,false,function()
    --                 G_HandlersManager.activityHandler:sendBuyVipDiscount(self._vipIndex)
    --             end,nil,nil,MessageBoxEx.OKNOButton.OKNOBtn_Default)
    --         else
    --             require("app.scenes.shop.GoldNotEnoughDialog").show()
    --         end
    --     else
    --         local str = G_lang:get("LANG_MSGBOX_VIPLEVELSP1",{vip_level=info.vip_level})
    --         MessageBoxEx.showYesNoMessage(nil,str,false,function()
    --             require("app.scenes.shop.recharge.RechargeLayer").show()  
    --         end,nil,nil,MessageBoxEx.OKNOButton.OKNOBtn_Vip)
    --     end
    -- end)
    -- self._vipIndex = 1
    -- self._btns = {}
    -- self:_initScrollView()
    -- self:_initTalk()
    -- self._talkType = 1
    -- self._changed = false
    -- self:updateDailyHero2()
end

-- function ActivityPageVipDiscount:setMeinv(resid)
--     self._heroPanel:removeAllChildrenWithCleanup(true)
--     local hero = KnightPic.createKnightButton( resid, self._heroPanel, "meinv",self,function ( )
--         self._changed = true
--         self:_bubbleShow()
--     end )
--     hero:setScale(0.8)
--     local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
--     self._bossEffect = EffectSingleMoving.run(hero, "smoving_idle", nil, {})
-- end


--选中了某个tab
function ActivityPageVipDiscount:onCheckCallback(btnName)
    if btnName == "CheckBox_fuli" then
        G_HandlersManager.activityHandler:sendVipDailyInfo()
    elseif btnName == "CheckBox_libao" then  
        -- G_HandlersManager.activityHandler:sendVipDiscountInfo()
        G_HandlersManager.activityHandler:sendVipWeekShopInfo()
    end
end

function ActivityPageVipDiscount:adapterLayer()
    self:adapterWidgetHeight("Panel_content1","","",0,0)
    self:adapterWidgetHeight("Panel_LiBao","Panel_tab","",0,0)
    self:adapterWidgetHeight("Panel_libaoList","Panel_tab","",210,0)
    self:initLiBaoList()
end

function ActivityPageVipDiscount:initLiBaoList()
    self:updateLiBaoList()
    if not self._liBaoList then
        self._liBaoList = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_libaoList"), LISTVIEW_DIR_VERTICAL)
        self._liBaoList:setSpaceBorder(0, 40)
        self._liBaoList:setCreateCellHandler(function ( list, index)
            return require("app.scenes.activity.ActivityPageVipLiBaoListItem").new(list, index)
        end)
        self._liBaoList:setUpdateCellHandler(function ( list, index, cell)
           cell:updateData(self._liBaoData[index+1]) 
        end)
        self._liBaoList:initChildWithDataLength( #self._liBaoData)
        
    end
end

function ActivityPageVipDiscount:updateLiBaoList()
    self._liBaoData = G_Me.activityData.vipDiscount:getShopList()
    if self._liBaoList then
        self._liBaoList:refreshAllCell()
    end
end

function ActivityPageVipDiscount:_onVipWeekShopInfo()
    self:updateLiBaoList()
    self:updateTips()
end

function ActivityPageVipDiscount:_onVipWeekShopBuy(data)
    if data.ret == NetMsg_ERROR.RET_OK then
        self:updateLiBaoList()
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)
        self:updateTips()
        local award = {}
        local id = math.floor(data.id/10)
        local info = vip_weekshop_info.get(id)
        for i = 1 , 4 do 
            if info["bag_1_item_"..i.."_type"] > 0 then
                table.insert(award,#award+1,{type=info["bag_1_item_"..i.."_type"],value=info["bag_1_item_"..i.."_value"],size=info["bag_1_item_"..i.."_size"]})
            end
        end
        local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(award)
        uf_notifyLayer:getModelNode():addChild(_layer,1000)
    end
end

-- function ActivityPageVipDiscount:_getLeftDay()
--     local timeObj = G_ServerTime:getDateObject()
--     local wday = timeObj.wday 
--     --sunday is 1, saturday is 7
--     -- 1,2,3,4,5,6,7
--     -- 0,6,5,4,3,2,1
--     return (8-wday) % 7
-- end

-- function ActivityPageVipDiscount:_getLeftTime()
--     local timeLeft = G_ServerTime:getCurrentDayLeftSceonds()
--     local day = self:_getLeftDay()
--     if timeLeft > 0 or day > 0 then
--         local hour = (timeLeft-timeLeft%3600)/3600
--         local minute = (timeLeft-hour*3600 -timeLeft%60)/60
--         hour = hour%24
--         local second = timeLeft%60
--         return G_lang:get("LANG_DAYS7_OVERTIME_FORMAT",{dayValue=day, hourValue=hour, minValue=minute, secondValue=second})
--     else
--         return nil
--     end
-- end

-- function ActivityPageVipDiscount:updateAward()
--     self._awardPanel:removeAllChildrenWithCleanup(true)
--     local info = vip_discount_store.get(self._vipIndex)
--     local offset = 5
--     local width = 100
--     -- for index = 1 , 4 do 
--     --     if info["item_"..index.."_type"] > 0 then
--     --         local item = GlobalFunc.createIcon({type=info["item_"..index.."_type"],value=info["item_"..index.."_value"],size=info["item_"..index.."_size"],click=true,name=false})
--     --         item:setPosition(ccp(width*(index-1)+offset*index,-55))
--     --         self._awardPanel:addChild(item)
--     --     end
--     -- end
--     local award = {}
--     for index = 1 , 4 do 
--         if info["item_"..index.."_type"] > 0 then
--             local item = {type=info["item_"..index.."_type"],value=info["item_"..index.."_value"],size=info["item_"..index.."_size"]}
--             table.insert(award,#award+1,item)
--         end
--     end
--     GlobalFunc.createIconInPanel({panel=self._awardPanel,award=award,click=true})
-- end

function ActivityPageVipDiscount:showPage()   
    --进界面的时候强刷一次数据
    G_HandlersManager.activityHandler:sendVipDiscountInfo()
end

-- function ActivityPageVipDiscount:_refreshTimeLeft(  )
--     local time = self:_getLeftTime()
--     if time then
--         self._timeLabel:setText(time)
--     else
--         self:showPage()
--     end

--     self._talkCount = self._talkCount - 1 
--     if self._talkCount == 0 then
--         if self._talkType > 0 and not self._changed then
--             self._changed = true
--             self:_bubbleShow()
--         end
--     end

--     -- if self._dailyCount == 0 then
--     --     self._heroPanel1:setVisible(true)
--     --     self._heroPanel2:setVisible(false)
--     --     self._sayImage1:setVisible(true)
--     --     self._sayImage2:setVisible(false)
--     -- end
--     -- self._dailyCount = self._dailyCount + 1
--     -- if self._dailyCount >= 100 then
--     --     self._dailyCount = 0
--     -- end
-- end
-- 
-- function ActivityPageVipDiscount:_onVipDiscountInfo(data)
--     if data.ret == 1 then
--         self:updateView()
--     end
-- end
-- 
-- function ActivityPageVipDiscount:_onBuyVipDiscount(data)
--     if data.ret == 1 then
--         self:updateView()
--         uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)
--         local id = G_Me.activityData.vipDiscount.buyId
--         G_Me.activityData.vipDiscount.buyId = 0
--         local info = vip_discount_store.get(id)
--         local awards = {}
--         for index = 1 , 4 do 
--             if info["item_"..index.."_type"] > 0 then
--                 local award = {type=info["item_"..index.."_type"],value=info["item_"..index.."_value"],size=info["item_"..index.."_size"]}
--                 table.insert(awards,#awards+1,award)
--             else
--             end
--         end
--         local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awards)
--         uf_notifyLayer:getModelNode():addChild(_layer,1000)
--     end
-- end
-- 
-- function ActivityPageVipDiscount:_bubbleShow()
--     if self._talkType > 0 then
--         local info = vip_discount_store.get(self._vipIndex)
--         self._bubbleLabel:setText(info["talk_"..self._talkType])
--         self._talkType = 3 - self._talkType
--         self._talkCount = 4
--         GlobalFunc.sayAction(self._bubbleImg)
--     end
-- end

-- function ActivityPageVipDiscount:updateView()
--     local info = vip_discount_store.get(self._vipIndex)
--     self._vipLabel:setText("VIP"..info.vip_level)
--     self._vipLabel2:setText(G_lang:get("LANG_ACTIVITY_VIPSHOW",{level=info.vip_level}))
--     self._curPriceLabel:setText(info.current_cost)
--     self._beforePriceLabel:setText(info.original_cost)
--     local time = self:_getLeftTime()
--     if time then
--         self._timeLabel:setText(time)
--     else
--         self:showPage()
--     end
    
--     local state = G_Me.activityData.vipDiscount:getBuyState(self._vipIndex)
--     self._buyImg:setVisible(state)
--     self._buyButton:setVisible(not state)
--     self:setMeinv(info.res_id)
--     self:updateAward()
--     self:_initTalk()
--     -- self._bubbleLabel:setText(info.talk_1)
--     self._talkType = state and 3 or 1
--     self:_bubbleShow()
--     self:_updateButton()

--     self:getImageViewByName("Image_libao_tip"):setVisible(G_Me.activityData.vipDiscount:hasToBuy())
-- end

-- function ActivityPageVipDiscount:_updateButton()
--     local maxLength = vip_discount_store.getLength()
--     for index = 1 , maxLength do 
--         local img = self:getImageViewByName("vip_img" .. "_" .. index)
--         if index == self._vipIndex then
--             img:loadTexture("ui/vip/vip_lv_xuanzhong.png")
--         else
--             img:loadTexture("ui/vip/vip_lv_di.png")
--         end
--     end
    
-- end

-- function ActivityPageVipDiscount:_initTalk()
--     self._talkCount = 4
--     self._talkType = 1
--     self._changed = false
-- end
-- 
-- function ActivityPageVipDiscount:_initScrollView( )
--     self._scrollView:removeAllChildren();
--     local space = 5 --间隙
--     local size = self._scrollView:getContentSize()
--     local _knightItemWidth = 0
--     local maxLength = vip_discount_store.getLength()

--     local flag = true
--     for i = 1, maxLength do
--         if flag then
--           local btnName = "vip_img" .. "_" .. i
--           local widget = CCSItemCellBase:create("ui_layout/activity_ActivityVipDiscountCell.json")

--           self:updateLevel(widget,vip_discount_store.get(i).vip_level)
--           widget:getImageViewByName("Image_di"):setName(btnName)
--           -- widget:getImageViewByName("Image_vip"):loadTexture(G_Path.getVipLevelImage(vip_discount_store.get(i).vip_level))

--           self._btns[i] = widget

--           -- _knightItemWidth = widget:getWidth()
--           _knightItemWidth = 120

--           widget:setPosition(ccp(_knightItemWidth*(i-1)+i*space,0))
--           --self:addChild(widget)
--           self._scrollView:addChild(widget)
--           -- self._validPageCount = self._validPageCount + 1
--           self:registerWidgetClickEvent(btnName, function()
--               self._vipIndex = i
--               self:updateView()
--           end)
--         end
--     end

--     local _scrollViewWidth = _knightItemWidth*maxLength+space*(maxLength+1)
--     self._scrollView:setInnerContainerSize(CCSizeMake(_scrollViewWidth,size.height))
-- end
-- 
-- function ActivityPageVipDiscount:updateLevel(widget,vip)
--     local vipLevelImg = widget:getImageViewByName("Image_di")
--     local vipImg = widget:getImageViewByName("Image_vip")
--     local levelImg = widget:getImageViewByName("Image_level")
--     levelImg:loadTexture(G_Path.getVipLevelImage(vip))
--     local totalWidth = vipLevelImg:getContentSize().width
--     local levelWidth = levelImg:getContentSize().width
--     local vipWidth = vipImg:getContentSize().width
--     local center = (vipWidth-levelWidth)/2
--     levelImg:setPositionXY(center+levelWidth/2,0)
--     vipImg:setPositionXY(center-vipWidth/2,0)
-- end

function ActivityPageVipDiscount:_onVipDailyInfo(data)
    if data.ret == 1 then
        self:updateDaily()
        self:updateTips()
    end
end

function ActivityPageVipDiscount:_onBuyVipDaily(data)
    if data.ret == 1 then
        local info = G_Me.activityData.vipDiscount:getDailyData(G_Me.activityData.vipDiscount.lastLevel)
        local award = {}
        for i = 1 , 5 do 
            if info["item_"..i.."_type"] > 0 then
                table.insert(award,#award+1,{type=info["item_"..i.."_type"],value=info["item_"..i.."_value"],size=info["item_"..i.."_size"]})
            end
        end
        local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(award)
        uf_notifyLayer:getModelNode():addChild(_layer,1000)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)
        self:updateDaily()
        self:updateTips()
    end
end

function ActivityPageVipDiscount:updateDaily()
    self:updateDailyHero(G_Me.userData.vip)
    self:updateDailyList(1,G_Me.activityData.vipDiscount.curLevel==-1 and G_Me.userData.vip or G_Me.activityData.vipDiscount.curLevel)
    self:updateDailyList(2,G_Me.userData.vip+1)
end

function ActivityPageVipDiscount:updateDailyHero(level)
    local panel = self:getPanelByName("Panel_hero2")

    local data = G_Me.activityData.vipDiscount:getDailyData(level)

    panel:setVisible(true)
    panel:removeAllChildrenWithCleanup(true)

    local hero = KnightPic.createKnightPic( data["res_id_1"], panel, "meinv" )
    hero:setScale(0.8)
    -- local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
    -- self._bossEffect = EffectSingleMoving.run(hero, "smoving_idle", nil, {})
end


-- function ActivityPageVipDiscount:updateDailyHero2()
--     local panel = self:getPanelByName("Panel_hero")

--     panel:setVisible(true)
--     panel:removeAllChildrenWithCleanup(true)

--     local hero = KnightPic.createKnightPic( 13013, panel, "meinv" )
--     hero:setScale(0.8)
-- end

function ActivityPageVipDiscount:updateDailyList(index,level)
    local data = G_Me.activityData.vipDiscount:getDailyData(level)
    if #self._dailyListItem < index and data then
        local item = require("app.scenes.activity.ActivityPageVipDiscountListItem").new()
        self._listPanel:addChild(item)
        item:setPositionXY(0,(2-index)*171)
        item:updateData(index,data)
    end
end

-- function ActivityPageVipDiscount:dailyHide(index)
--     local heroPanel = self:getPanelByName("Panel_hero"..index)
--     local sayImage = self:getImageViewByName("Image_say"..index)
--     local detlaX = index == 1 and -300 or 300
--     sayImage:setVisible(false)
--     local posx,posy = heroPanel:getPosition()
--     heroPanel:runAction(CCMoveBy:create(0.5,ccp(detlaX,0)))
--     heroPanel:runAction(CCSequence:createWithTwoActions(CCEaseBounceOut:create(CCScaleTo:create(0.5,1)),
--         CCCallFunc:create(function()
--             heroPanel:setVisible(false)
--             heroPanel:setPositionXY(posx,posy)
--         end)))
-- end

-- function ActivityPageVipDiscount:dailyShow(index)
--     local heroPanel = self:getPanelByName("Panel_hero"..index)
--     local sayImage = self:getImageViewByName("Image_say"..index)
--     local posx,posy = heroPanel:getPosition()
--     local detlaX = index == 1 and 300 or -300
--     heroPanel:setPositionXY(posx-detlaX,posy)
--     heroPanel:setVisible(true)
--     heroPanel:runAction(CCSequence:createWithTwoActions(CCMoveBy:create(0.5,ccp(detlaX,0)),
--         CCCallFunc:create(function()
--             sayImage:setVisible(true)
--             sayImage:setScale(0.1)
--             sayImage:runAction(CCEaseBounceOut:create(CCScaleTo:create(0.5,1)))
--     end)))
-- end

-- function ActivityPageVipDiscount:dailyReset()
--     self:dailyActionEnd()
--     transition.stopTarget(self._heroPanel1)
--     transition.stopTarget(self._heroPanel2)
--     transition.stopTarget(self._sayImage1)
--     transition.stopTarget(self._sayImage2)
--     self._heroPanel1:setVisible(false) 
--     self._heroPanel1:setPosition(self._heroPanelBasePos1)
--     self._sayImage1:setVisible(false)
--     self._sayImage1:setScale(1)
--     self._heroPanel2:setVisible(false) 
--     self._heroPanel2:setPosition(self._heroPanelBasePos2)
--     self._sayImage2:setVisible(false)
-- end

-- function ActivityPageVipDiscount:dailyActionStart()
--     self:dailyReset()

--     local data = G_Me.activityData.vipDiscount:getDailyData(G_Me.userData.vip)
--     if data["res_id_2"] == 0 then
--         self:dailyShow(1)
--         return
--     end

--     self._dailyRepeat = true
--     self:dailyActionRepeat(1)
-- end

-- function ActivityPageVipDiscount:dailyActionEnd()
--     self._dailyRepeat = false
-- end

-- function ActivityPageVipDiscount:dailyActionRepeat(index)
--     local arr = CCArray:create()
--     arr:addObject(CCCallFunc:create(function()
--         if not self._dailyRepeat then
--             return
--         end
--         self:dailyShow(index)
--         self:dailyHide(3-index)
--     end))
--     arr:addObject(CCDelayTime:create(5.0))
--     arr:addObject(CCCallFunc:create(function()
--         if not self._dailyRepeat then
--             return
--         end
--         self:dailyActionRepeat(3-index)
--     end))
--     self._heroPanel1:runAction(CCSequence:create(arr))
-- end

return ActivityPageVipDiscount
