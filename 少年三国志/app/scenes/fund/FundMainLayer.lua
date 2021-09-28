
local FundMainLayer = class("FundMainLayer",UFCCSNormalLayer)

require("app.cfg.fund_coin_info")
require("app.cfg.fund_number_info")

function FundMainLayer.create(...)
    local layer = require("app.scenes.fund.FundMainLayer").new("ui_layout/fund_MainLayer.json", ...)
    -- layer:adapterLayer()
    return layer
end

function FundMainLayer:ctor(json,...)
    self.super.ctor(self, ...)
    self._tabs = require("app.common.tools.Tabs").new(2, self,self._checkedCallBack, self._uncheckedCallBack) 
    self:registerBtnClickEvent("Button_recharge", function()
         require("app.scenes.shop.recharge.RechargeLayer").show()  
    end)
    self:registerWidgetClickEvent("Button_wantBuy", function()
        self._tabs:checked("CheckBox_list")
        -- G_Me.fundData._buy_count = G_Me.fundData._buy_count + 1
        -- self:_updateNumList()
    end)

    self:registerWidgetClickEvent("Button_buy", function()
        if G_Me.userData.vip < 7 then
            G_MovingTip:showMovingTip(G_lang:get("LANG_FUND_VIP"))
            return
        end
        if G_Me.userData.gold < 1000 then
            -- G_MovingTip:showMovingTip(G_lang:get("LANG_PURCHASE_GOLD_NOT_ENOUGH"))
            require("app.scenes.shop.GoldNotEnoughDialog").show()
            return
        end
        MessageBoxEx.showYesNoMessage(nil, G_lang:get("LANG_FUND_BUY_OK"), nil , 
            function() 
               G_HandlersManager.fundHandler:sendBuyFund()
            end,
            nil
        )
    end)
    
    -- if G_Me.achievementData:hasNew() then
    --     self:getImageViewByName("Image_composeTips2"):setVisible(true)
    -- end

    self._anime = false
    self._awardId = 0
    self._peopleCount = 0
    self._buyNumLabel = self:getLabelByName("Label_buynum")
    self._timeLabelDes1 = self:getLabelByName("Label_timedes")
    self._timeLabel1 = self:getLabelByName("Label_time")
    self._timeLabelDes2 = self:getLabelByName("Label_timedes2")
    self._timeLabel2 = self:getLabelByName("Label_time2")
    self._buyNumLabel:createStroke(Colors.strokeBrown, 1)
    -- self._timeLabelDes1:createStroke(Colors.strokeBrown, 1)
    -- self._timeLabel1:createStroke(Colors.strokeBrown, 1)
    -- self._timeLabelDes2:createStroke(Colors.strokeBrown, 1)
    -- self._timeLabel2:createStroke(Colors.strokeBrown, 1)
    -- self._timeLabelDes1:setText(G_lang:get("LANG_FUND_TIMEDES"))
    -- self._timeLabelDes2:setText(G_lang:get("LANG_FUND_TIMEDES"))
    self._timeLabelDes1:setVisible(false)
    self._timeLabel1:setVisible(false)
    self._timeLabelDes2:setVisible(false)
    self._timeLabel2:setVisible(false)

    self._buyButton = self:getButtonByName("Button_buy")
    self._imgVip2 = self:getImageViewByName("Image_vip2")
    self._buyPanel = self:getPanelByName("Panel_buy")
    self._buyLabel1 = self:getLabelByName("Label_buy1")
    self._buyLabel2 = self:getLabelByName("Label_buy2")
    self._buyLabel3 = self:getLabelByName("Label_buy3")
    self._buyLabel4 = self:getLabelByName("Label_buy4")
    self._buyLabel1:createStroke(Colors.strokeBrown, 1)
    self._buyLabel2:createStroke(Colors.strokeBrown, 1)
    self._buyLabel3:createStroke(Colors.strokeBrown, 1)
    self._buyLabel4:createStroke(Colors.strokeBrown, 1)
    self._buyLabel1:setText(G_lang:get("LANG_FUND_BUY_LABEL1")) 
    self._buyLabel3:setText(G_lang:get("LANG_FUND_BUY_LABEL3")) 
    self._vipLabel = self:getLabelByName("Label_vip")
    self._vipLabel:createStroke(Colors.strokeBrown, 1)
    self._vipLabel:setText(G_lang:get("LANG_FUND_VIP_LEVEL")) 
    self._vipAtlasLabel = self:getLabelAtlasByName("AtlasLabel_vip")

    self._buyButton:setVisible(false)
    self._imgVip2:setVisible(false)
    self._buyPanel:setVisible(false)
    -- vip动画
    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        local EffectNode = require "app.common.effects.EffectNode"

        if self._vipAtlasLabel then
            if not self._vipShine then
                self._vipShine = EffectNode.new("effect_vipshine", function(event, frameIndex) end)
                self._vipAtlasLabel:addNode(self._vipShine,1)
                self._vipShine:play()
            end
        end
    end

    self:registerWidgetClickEvent("Image_vip", function ( ... )
        self:showVip()
    end)
    self:registerWidgetClickEvent("LabelAtlas_VIP", function ( ... )
        self:showVip()
    end)

    self._numList = {self:getLabelByName("Label_num1"),self:getLabelByName("Label_num2"),
                        self:getLabelByName("Label_num3"),self:getLabelByName("Label_num4")}
    self._numList2 = {self:getLabelByName("Label_num1_0"),self:getLabelByName("Label_num2_0"),
                        self:getLabelByName("Label_num3_0"),self:getLabelByName("Label_num4_0")}
    for i = 1,4 do 
        self._numList[i]:createStroke(Colors.strokeBrown, 1)
    end
    for i = 1,4 do 
        self._numList2[i]:createStroke(Colors.strokeBrown, 1)
    end

    local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    if appstoreVersion or IS_HEXIE_VERSION  then 
        self:showWidgetByName("Image_17", false)
        -- if image then 
        --     image:loadTexture("ui/arena/xiaozhushou_hexie.png")
        -- end
    end
end

function FundMainLayer:showVip()
    local p = require("app.scenes.vip.VipMainLayer").create()
    G_Me.shopData:setVipEnter(true)   
    uf_sceneManager:getCurScene():addChild(p)
end

function FundMainLayer:onLayerEnter()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FUND_INFO, self._onGetInfo, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FUND_USER_FUND, self._onGetUser, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FUND_BUY_FUND, self._onGetBuy, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FUND_AWARD, self._onGetAward, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FUND_WEAL, self._onGetWeal, self)

    G_HandlersManager.fundHandler:sendGetFundInfo()
    -- self:_onGetInfo()
end
function FundMainLayer:onLayerLoad(...)
    self:registerKeypadEvent(true)
end
function FundMainLayer:onBackKeyEvent()
    uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
    return true
end

function FundMainLayer:showPage()   
    
end


function FundMainLayer:updatePage()
    
end

function FundMainLayer:_initTabs()
    self._tabs:add("CheckBox_list", self:getPanelByName("Panel_content1"), "Label_renwu") --delay load
    self._tabs:add("CheckBox_list2", self:getPanelByName("Panel_content2"), "Label_chengjiu")  -- delay load

    self._tabs:checked("CheckBox_list")
end




function FundMainLayer:_checkedCallBack(btnName)
    if btnName == "CheckBox_list" then
        self:_resetListView1()
    elseif btnName == "CheckBox_list2" then
        self:_resetListView2()
        -- self:getImageViewByName("Image_composeTips2"):setVisible(false)
    end
end

function FundMainLayer:_resetListView1()
    self._listView1:reloadWithLength(#self:_getListData(1), 0, 0.2)
    self:getImageViewByName("Image_composeTips1"):setVisible(false)
    if G_Me.fundData:hasNew2() then
        self:getImageViewByName("Image_composeTips2"):setVisible(true)
    else
        self:getImageViewByName("Image_composeTips2"):setVisible(false)
    end
end

function FundMainLayer:_resetListView2()
    self._listView2:reloadWithLength(#self:_getListData(2), 0, 0.2)
    self:getImageViewByName("Image_composeTips2"):setVisible(false)
    if G_Me.fundData:hasNew1() then
        self:getImageViewByName("Image_composeTips1"):setVisible(true)
    else
        self:getImageViewByName("Image_composeTips1"):setVisible(false)
    end
end

function FundMainLayer:adapterLayer()
    self:adapterWidgetHeight("Panel_content1", "Panel_checkbox", "", 5, 0)
    self:adapterWidgetHeight("Panel_content2", "Panel_checkbox", "", 5, 0)

    self:adapterWidgetHeight("Panel_list", "Panel_others1", "", 0, 0)
    self:adapterWidgetHeight("Panel_list2", "Panel_others2", "", 0, 0)

    self:_initScrollView1(self:getPanelByName("Panel_list"),1)
    self:_initScrollView2(self:getPanelByName("Panel_list2"),2)
    
    if self._tabs:getCurrentTabName() == "" then
       self:_initTabs() 
    end
    
    -- self:_onGetInfo()
end


function FundMainLayer:onLayerExit()
    if self._schedule then
        GlobalFunc.removeTimer(self._schedule)
    end
    uf_eventManager:removeListenerWithTarget(self)
    self.super:onLayerExit()
end

function FundMainLayer:_onGetInfo(data)
    -- if G_Me.fundData:dataReady() then
    --     self:_onGetUser()
    -- else
    if data.ret == 1 then
        G_HandlersManager.fundHandler:sendGetUserFund()
    end
    -- end
end

function FundMainLayer:_onGetUser(data)
    -- if G_Me.fundData:dataReady() then
    if data.ret == 1 then
        if self._schedule then
            GlobalFunc.removeTimer(self._schedule)
            self._schedule = nil
        end
        self:_updatePanel1()
        self:_updatePanel2()
        -- if G_Me.fundData:getCountDown() > 0 then
        --     self._schedule = GlobalFunc.addTimer(1, handler(self, self._refreshTimeLeft))
        -- end
        self:_updateNumList()
        if G_Me.fundData:getBuy() then
            self._buyButton:setVisible(false)
            self._imgVip2:setVisible(false)
            self._buyPanel:setVisible(true)
            self._buyLabel2:setText(G_lang:get("LANG_FUND_BUY_LABEL2",{num=G_Me.fundData:getGotGold()})) 
            self._buyLabel4:setText(G_lang:get("LANG_FUND_BUY_LABEL4",{num=G_Me.fundData:getGoldCanGet()})) 
        else
            self._buyButton:setVisible(true)
            self._imgVip2:setVisible(true)
            self._buyPanel:setVisible(false)
        end

        self._vipAtlasLabel:setStringValue(G_Me.userData.vip)
    end
end

function FundMainLayer:_onGetBuy(data)
    if data.ret == 1 then
        self._listView1:refreshAllCell()
        self._listView2:refreshAllCell()
        G_MovingTip:showMovingTip(G_lang:get("LANG_FUND_BUY_SUCCESS"))
    end
end

function FundMainLayer:_onGetAward(data)
    if data.ret == 1 then
        self._listView1:refreshAllCell()
        self._buyLabel2:setText(G_lang:get("LANG_FUND_BUY_LABEL2",{num=G_Me.fundData:getGotGold()})) 
        self._buyLabel4:setText(G_lang:get("LANG_FUND_BUY_LABEL4",{num=G_Me.fundData:getGoldCanGet()})) 
        if self._awardId > 0 then
            local info = fund_coin_info.get(self._awardId)
            local awardData = {type=2 ,value=0,size=info.coin_number}
            local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create({awardData})
            uf_notifyLayer:getModelNode():addChild(_layer,1000)
            self._awardId = 0
        end
    end
end

function FundMainLayer:_onGetWeal(data)
    if data.ret == 1 then
        self._listView2:refreshAllCell()
        if self._awardId > 0 then
            local info = fund_number_info.get(self._awardId)
            local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create({info})
            uf_notifyLayer:getModelNode():addChild(_layer,1000)
            self._awardId = 0
        end
    end
end

function FundMainLayer:_updatePanel1()
    self._buyNumLabel:setText(G_lang:get("LANG_FUND_BUYNUM",{num=G_Me.fundData:getBuyNum()})) 
    self._timeLabel1:setText(self:_getTime())
    self._listView1:refreshAllCell()
end

function FundMainLayer:_updatePanel2()
    self._timeLabel2:setText(self:_getTime())
    self._listView2:refreshAllCell()
end

function FundMainLayer:_initScrollView1(panel,type)
    if self._listView1 == nil then
        self._listView1 = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
        self._listView1:setSpaceBorder(0, 40)
        self._listView1:setCreateCellHandler(function ( list, index)
            return require("app.scenes.fund.FundListCell").new(list, index)
        end)
        self._listView1:setUpdateCellHandler(function ( list, index, cell)
            local data = self:_getListData(type)
            if  index < #data then
               cell:updateData(data[index+1],type,function (_id)
                   self._awardId = _id
               end) 
            end
        end)
        self._listView1:initChildWithDataLength( #self:_getListData(type))
    end
end

function FundMainLayer:_initScrollView2(panel,type)
    if self._listView2 == nil then
        self._listView2 = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
        self._listView2:setSpaceBorder(0, 40)
        self._listView2:setCreateCellHandler(function ( list, index)
            return require("app.scenes.fund.FundListCell").new(list, index)
        end)
        self._listView2:setUpdateCellHandler(function ( list, index, cell)
            local data = self:_getListData(type)
            if  index < #data then
               cell:updateData(data[index+1],type,function (_id)
                   self._awardId = _id
               end) 
            end
        end)
        self._listView2:initChildWithDataLength( #self:_getListData(type))
    end
end


function FundMainLayer:_getListData(type)
    local sortFunc = function(a,b)
        if a.status ~= b.status then
            return a.status < b.status
        end
        return a.id < b.id
    end
    if type == 1 then
        local list = {}
        local baseList = G_Me.fundData:getCoinList()
        for k,v in pairs(baseList) do 
            table.insert(list,#list+1,v)
        end
        table.sort(list,sortFunc)
        return list
    else
        local list = {}
        local baseList = G_Me.fundData:getNumberList()
        for k,v in pairs(baseList) do 
            table.insert(list,#list+1,v)
        end
        table.sort(list,sortFunc)
        return list
    end
end

function FundMainLayer:_refreshTimeLeft()
    self._timeLabel1:setText(self:_getTime())
    self._timeLabel2:setText(self:_getTime())
end

function FundMainLayer:_updateNumList()
    -- local num = G_Me.fundData:getBuyNum()
    -- if num > 9999 then
    --     num = 9999
    -- end
    -- self:_setNum1(num)
    self:_numAnimeStart()
end

function FundMainLayer:_getDust()
    local num = G_Me.fundData:getBuyNum()
    if num > 9999 then
        num = 9999
    end
    return num
end

function FundMainLayer:_numAnimeStart()
    local num = self:_getDust()
    self:_numListAnime(self._peopleCount,num,function ( )
        self._peopleCount = num
        if self._peopleCount < self:_getDust() then
            self:_numAnimeStart()
        end
    end)
end

function FundMainLayer:_numListAnime(num1,num2,callback)
    if self._anime then
        return
    end
    if num1 == num2 then
        return
    end
    self._anime = true
    local count = 0
    local list1 = self:_setNum1(num1)
    local list2 = self:_setNum2(num2)
    for i = 1, 4 do
        if list1[i] ~= list2[i] then
            count = count + 1
            self:_runAni(i,function ( )
                count = count - 1
                if count == 0 then
                    self._anime = false
                    callback()
                end
            end)
        end
    end 
end

function FundMainLayer:_setNum1(num1)
    local num = num1
    local num4 = num%10
    num = math.floor(num/10)
    local num3 = num%10
    num = math.floor(num/10)
    local num2 = num%10
    local num1 = math.floor(num/10)
    self._numList[1]:setText(num1)
    self._numList[2]:setText(num2)
    self._numList[3]:setText(num3)
    self._numList[4]:setText(num4)
    return {num1,num2,num3,num4}
end

function FundMainLayer:_setNum2(num2)
    local num = num2
    local num4 = num%10
    num = math.floor(num/10)
    local num3 = num%10
    num = math.floor(num/10)
    local num2 = num%10
    local num1 = math.floor(num/10)
    self._numList2[1]:setText(num1)
    self._numList2[2]:setText(num2)
    self._numList2[3]:setText(num3)
    self._numList2[4]:setText(num4)
    return {num1,num2,num3,num4}
end

function FundMainLayer:_runAni(index,callback)
    local label1 = self._numList[index]
    local label2 = self._numList2[index]
    local delay = 0.5
    local ease1 = CCEaseIn:create(CCMoveBy:create(delay, ccp(0, -71)), delay)
    local ease2 = CCEaseIn:create(CCMoveBy:create(delay, ccp(0, -71)), delay)
    label1:runAction(CCSequence:createWithTwoActions(ease1, CCCallFunc:create(function()
        local posx,posy = label1:getPosition() 
        label1:setPosition(ccp(posx,posy+142))
        self._numList[index] = label2
        self._numList2[index] = label1
        callback()
        end)))
    label2:runAction(ease2)
end

function FundMainLayer:_getTime()
    local temp = G_Me.fundData:getCountDown()
    if temp <= 0 then
        return G_lang:get("LANG_FUND_TIMEOVER")
    end
    local sec = temp%60
    temp = math.floor(temp/60)
    local min = temp%60
    temp = math.floor(temp/60)
    local hour = temp%24
    temp = math.floor(temp/24)
    local day = temp
    local final = ""
    if day > 0 then 
        final = final..G_lang:get("LANG_FUND_TIMEFORMATDAY",{num=day})
    end
    if hour > 0 then 
        final = final..G_lang:get("LANG_FUND_TIMEFORMATHOUR",{num=hour})
    end
    if min > 0 then 
        final = final..G_lang:get("LANG_FUND_TIMEFORMATMIN",{num=min})
    end
    if day == 0 then 
        final = final..G_lang:get("LANG_FUND_TIMEFORMATSEC",{num=day})
    end
    return final
end

return FundMainLayer
