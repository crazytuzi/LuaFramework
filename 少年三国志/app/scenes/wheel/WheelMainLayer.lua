local WheelMainLayer = class("WheelMainLayer",UFCCSNormalLayer)
require("app.cfg.wheel_info")
require("app.cfg.wheel_prize_info")
KnightPic = require("app.scenes.common.KnightPic")

local FuCommon = require("app.scenes.dafuweng.FuCommon")

local btnImg = {"ui/dungeon/btn_mingjiangfuben.png","ui/dungeon/btn_zhuxianfuben.png"}

function WheelMainLayer:ctor( json, fun, scenePack, ...)
    self.super.ctor(self, json, fun, scenePack, ...)
    self:initPageView()
    
    self._curPage = 1
    self:getImageViewByName("Image_left"):setVisible(false)
    self:getImageViewByName("Image_right"):setVisible(true)
    self._timeLabel = self:getLabelByName("Label_time")
    self._rankLabel = self:getLabelByName("Label_paihang")
    self._scoreLabel1 = self:getLabelByName("Label_curScore1")
    self._scoreLabel2 = self:getLabelByName("Label_curScore2")
    self._timeLabel:createStroke(Colors.strokeBrown, 1)
    self._rankLabel:createStroke(Colors.strokeBrown, 1)
    self._scoreLabel1:createStroke(Colors.strokeBrown, 1)
    self._scoreLabel2:createStroke(Colors.strokeBrown, 1)
    self._normalPanel = self:getPanelByName("Panel_normal")
    self._finishPanel = self:getPanelByName("Panel_finish")
    -- self._topTitle = self:getImageViewByName("Image_topTitle")
    self._helpButton = self:getButtonByName("Button_help")
    self._ptWheelButton = self:getButtonByName("Button_ptWheel")
    self._jyWheelButton = self:getButtonByName("Button_jyWheel")
    self._titleImg = self:getImageViewByName("Image_title")
    self._shizhuang = self:getLabelByName("Label_shizhuang")
    self._shizhuang:createStroke(Colors.strokeBrown, 1)
    self._shizhuang:setText(G_lang:get("LANG_WHEEL_SHIZHUANG"))
    self._normalPanel:setVisible(false)
    self._finishPanel:setVisible(false)
    self._rolling = false
    self._timeStart = false

    self:_loadWheelPage()

    self._rankLabel:setText(0)
    self._timeLabel:setText("")
    self._scoreLabel2:setText(0)

    self:registerBtnClickEvent("Button_ptWheel", function ( ... )
        self:moveTo(1)
    end)
    self:registerBtnClickEvent("Button_jyWheel", function ( ... )
        self:moveTo(2)
    end)
    self:registerBtnClickEvent("Button_back", function()
        uf_sceneManager:replaceScene(scenePack and G_GlobalFunc.packToScene(scenePack) or require("app.scenes.dafuweng.FuMainScene").new(FuCommon.WHEEL_TYPE_ID))
    end)
    self:registerWidgetClickEvent("Image_left", function ( ... )
        self:moveTo(1)
    end)
    self:registerWidgetClickEvent("Image_leftArrow", function ( ... )
        self:moveTo(1)
    end)
    self:registerWidgetClickEvent("Image_right", function ( ... )
        self:moveTo(2)
    end)
    self:registerWidgetClickEvent("Image_rightArrow", function ( ... )
        self:moveTo(2)
    end)
    self:registerBtnClickEvent("Button_paihang", function ( ... )
        local top = require("app.scenes.wheel.WheelTopLayer").create(1)
        uf_sceneManager:getCurScene():addChild(top)
    end)
    self:registerBtnClickEvent("Button_shop", function ( ... )
        --积分商店
        if G_Me.wheelData:getState() == 3 then
            return
        end
        require("app.const.ShopType")
        uf_sceneManager:pushScene(require("app.scenes.shop.score.ShopScoreScene").new(SCORE_TYPE.ZHUAN_PAN))
        -- local top = require("app.scenes.wheel.WheelRoll").create(1,{1,2,3,4,5,6,7,1,1,1},{0,0,0,0,0,0,0,0,0,0})
        -- uf_sceneManager:getCurScene():addChild(top)
    end)
    self:registerBtnClickEvent("Button_help", function ( ... )
        -- local help = require("app.scenes.wheel.WheelHelp").create()
        -- uf_sceneManager:getCurScene():addChild(help)
        require("app.scenes.common.CommonHelpLayer").show({
            {title=G_lang:get("LANG_WHEEL_HELPTITLE1"), content=G_lang:get("LANG_WHEEL_HELP1",{num=G_Me.wheelData.jyRankScore})},
            {title=G_lang:get("LANG_WHEEL_HELPTITLE2"), content=G_lang:get("LANG_WHEEL_HELP2",{num=G_Me.wheelData.jyRankScore})},
            -- {title=G_lang:get("LANG_WHEEL_HELPTITLE3"), content=G_lang:get("LANG_WHEEL_HELP3",{num=G_Me.wheelData.jyRankScore})},
            } )
    end)
    self:registerBtnClickEvent("Button_getAward", function ( ... )
        if G_Me.wheelData:getState() == 3 then
            return
        end
        local top = require("app.scenes.wheel.WheelTopAward").create(1)
        uf_sceneManager:getCurScene():addChild(top)
    end)
end


function WheelMainLayer:onLayerEnter( ... )
    
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WHEEL_INFO, self._onWheelInfoRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_PLAY_WHEEL, self._onPlayWheelRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WHEEL_REWARD, self._onGetRewardRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WHEEL_RANK, self._onWheelRankRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._bagChanged, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_ITEM_BUY_RESULT, self._buyRes, self)

    G_HandlersManager.wheelHandler:sendWheelInfo()
    G_HandlersManager.wheelHandler:sendWheelRankingList()

    self:initMeiNv()
    self:_enableRoll(true)
    -- self:initEndPanel()
    if self._schedule == nil then
        self._schedule = GlobalFunc.addTimer(1, handler(self, self._refreshTimeLeft))
    end
end

function WheelMainLayer:updateView(  )
    local state = G_Me.wheelData:getState()
    if state == 1 then
        self._normalPanel:setVisible(true)
        self._finishPanel:setVisible(false)
        self._titleImg:setVisible(false)
        self._ptWheelButton:setVisible(true)
        self._jyWheelButton:setVisible(true)
        self._helpButton:setVisible(true)
    elseif state == 2 then
        self._normalPanel:setVisible(false)
        self._finishPanel:setVisible(true)
        self._titleImg:setVisible(true)
        self._ptWheelButton:setVisible(false)
        self._jyWheelButton:setVisible(false)
        self._helpButton:setVisible(false)
        self:initEndPanel()
    elseif state == 3 then 
        --应该关闭
        -- uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
        uf_sceneManager:replaceScene(require("app.scenes.dafuweng.FuMainScene").new(FuCommon.WHEEL_TYPE_ID))
        -- self._normalPanel:setVisible(false)
        -- self._finishPanel:setVisible(true)
        -- self:updateOthers()
        -- self:initEndPanel()
        return
    end
    self._pageView:refreshPageWithCount(2,self._curPage-1)
    -- self:updateOthers()
    self:showTime()
end

function WheelMainLayer:adaptView(  )
    self:adapterWidgetHeight("Panel_middle","Panel_top","",0,60)
end

function WheelMainLayer:_bagChanged(  )
    self:updateView()
end

function WheelMainLayer:initEndPanel(  )
    self:getLabelByName("Label_hasAward1"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_hasAward2"):createStroke(Colors.strokeBrown, 1)
    if G_Me.wheelData:getMyRank() == 0 then
        self:getLabelByName("Label_hasAward1"):setVisible(false)
        self:getLabelByName("Label_hasAward2"):setVisible(true)
        self:getButtonByName("Button_getAward"):setVisible(false)
        self:getImageViewByName("Image_got"):setVisible(false)
    else
        self:getLabelByName("Label_hasAward1"):setVisible(true)
        self:getLabelByName("Label_hasAward2"):setVisible(false)
        -- self:getButtonByName("Button_getAward"):setVisible(true)
        if G_Me.wheelData.got_reward then
            self:getImageViewByName("Image_got"):setVisible(true)
            self:getButtonByName("Button_getAward"):setVisible(false)
        else
            self:getImageViewByName("Image_got"):setVisible(false)
            self:getButtonByName("Button_getAward"):setVisible(true)
        end
    end
    self:getLabelByName("Label_hasAward2"):setText(G_lang:get("LANG_WHEEL_END3"))
    if G_Me.wheelData.score_total >= G_Me.wheelData.jyRankScore then
        self:getLabelByName("Label_hasAward1"):setText(G_lang:get("LANG_WHEEL_END1",{rank=G_Me.wheelData:getMyRank()}))
    else
        self:getLabelByName("Label_hasAward1"):setText(G_lang:get("LANG_WHEEL_END2",{rank=G_Me.wheelData:getMyRank()}))
    end

    for i = 1 , 3 do 
        if i <= #G_Me.wheelData.rankList then
            local info = G_Me.wheelData.rankList[i]
            local knightBaseInfo = knight_info.get(info.mainrole)
            self:getImageViewByName("Image_rank"..i):loadTexture("ui/text/txt/phb_"..i.."st.png")
            self:getLabelByName("Label_name"..i):createStroke(Colors.strokeBrown, 1)
            self:getLabelByName("Label_name"..i):setText(info.name)
            self:getLabelByName("Label_name"..i):setColor(Colors.qualityColors[knightBaseInfo.quality])
            self:getLabelByName("Label_score"..i):setText(info.score)
            self:getPanelByName("Panel_best"..i):setVisible(true) 
        else
            self:getPanelByName("Panel_best"..i):setVisible(false) 
        end
    end
end

function WheelMainLayer:initMeiNv(  )
    local hero = self:getPanelByName("Panel_meizi")
    hero:removeAllChildrenWithCleanup(true)
    local GlobalConst = require("app.const.GlobalConst")
    local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    local knight = nil
    if appstoreVersion or IS_HEXIE_VERSION  then 
        knight = knight_info.get(GlobalConst.CAI_WEN_JI_HE_XIE_ID)
    else
        knight = knight_info.get(GlobalConst.CAI_WEN_JI_ID)
    end
    if knight then
        KnightPic.createKnightPic( knight.res_id, hero, "meinv",true )
        hero:setScale(0.8)
        -- local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
        -- self._bossEffect = EffectSingleMoving.run(hero, "smoving_idle", nil, {})
    end
end

-- function WheelMainLayer:initOthers(  )
--     self._scoreLabel1:setText(G_lang:get("LANG_WHEEL_SCORE"))
--     self._scoreLabel2:setText(G_Me.wheelData.score_total)
--     local rank = G_Me.wheelData:getMyRank()
--     self._rankLabel:setText(G_lang:get("LANG_WHEEL_RANK")..(rank == -1 and G_lang:get("LANG_WHEEL_NORANK") or rank))
-- end

function WheelMainLayer:updateOthers( score )
    self._scoreLabel1:setText(G_lang:get("LANG_WHEEL_SCORE"))
    -- self._scoreLabel2:setText(G_Me.wheelData.score_total)
    if score and score > 0 then
        local _time = 0.5
        local _end = G_Me.wheelData.score_total
        local _start = _end - score
        local action1 = CCSequence:createWithTwoActions(CCScaleTo:create(_time/2, 2), CCScaleTo:create(_time/2, 1))
        local growupNumber = CCNumberGrowupAction:create(_start, _end, _time, function ( number )
            self._scoreLabel2:setText(number)
        end)
        action1 = CCSpawn:createWithTwoActions(growupNumber, action1)

        self._scoreLabel2:runAction(action1)
    else
        self._scoreLabel2:setText(G_Me.wheelData.score_total)
    end

    local rank = G_Me.wheelData:getMyRank()
    self._rankLabel:setText(G_lang:get("LANG_WHEEL_RANK")..(rank <= 0 and G_lang:get("LANG_WHEEL_NORANK") or rank))
end

function WheelMainLayer:_onWheelInfoRsp( data )
    self:updateView()
    self:updateOthers()
end

function WheelMainLayer:_buyRes(data)
    if data.ret == NetMsg_ERROR.RET_GAME_TIME_ERROR0 then
        G_HandlersManager.wheelHandler:sendWheelInfo()
        G_HandlersManager.richHandler:sendRichInfo()
    end
end

function WheelMainLayer:_onPlayWheelRsp( data )
    if data.ret == 1 then
        self:_enableRoll(false)
        self:updateView()
        local cell = self._pageView:getPageCell(data.id - 1)
        local award = data.reward_id
        if #award > 1 then
            self._normalPanel:setVisible(false)
            local top = require("app.scenes.wheel.WheelRoll").create(data.id,award,data.money,function ( ... )
                local info = wheel_info.get(data.id)
                local times = #data.reward_id
                local totalScore = info.score*times
                local score = {type=G_Goods.TYPE_ZHUAN_PAN_SCORE,value=0,size=totalScore}
                local top = require("app.scenes.wheel.WheelAwardTen").create(data.id,award,data.money,score,function ( )
                    self:updateOthers(totalScore)
                end)
                uf_sceneManager:getCurScene():addChild(top)
                self._normalPanel:setVisible(true)
                self:_enableRoll(true)
                self:updateView()
            end)
            uf_sceneManager:getCurScene():addChild(top)
        else
            cell:roll(award[#award],#award,function ( )
                self:_enableRoll(true)
                if #award == 1 then
                    local awardGot = self:_calcAward(data.id,award)
                    local money = 0 
                    for k, v in pairs(data.money) do 
                        money = money + v
                    end
                    if money > 0 then
                        local moneyAward = {type=G_Goods.TYPE_GOLD,value=0,size=money}
                        table.insert(awardGot,#awardGot+1,moneyAward)
                    end
                    local info = wheel_info.get(data.id)
                    local times = #data.reward_id
                    local totalScore = info.score*times
                    local score = {type=G_Goods.TYPE_ZHUAN_PAN_SCORE,value=0,size=totalScore}
                    table.insert(awardGot,#awardGot+1,score)
                    local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awardGot)
                    uf_notifyLayer:getModelNode():addChild(_layer,1000)
                    self:updateOthers(totalScore)
                else
                    -- local top = require("app.scenes.wheel.WheelAwardTen").create(data.id,award,data.money)
                    -- uf_sceneManager:getCurScene():addChild(top)
                end
            end)
        end
    end
end
function WheelMainLayer:_onGetRewardRsp(  data)
    if data.ret == 1 then
        local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(data.award)
        uf_notifyLayer:getModelNode():addChild(_layer,1000)
        self:updateView()
    end
end

function WheelMainLayer:_onWheelRankRsp(data  )
    self:updateView()
    self:updateOthers()
end

function WheelMainLayer:_refreshTimeLeft(  )
    self:updateTime()
end

function WheelMainLayer:_enableRoll(able )
    self:getButtonByName("Button_buyone1"):setTouchEnabled(able)
    self:getButtonByName("Button_buyone2"):setTouchEnabled(able)
    self:getButtonByName("Button_buyten1"):setTouchEnabled(able)
    self:getButtonByName("Button_buyten2"):setTouchEnabled(able)
end

function WheelMainLayer:_calcAward(id,award)
    local data = {}
    local temp = {}
    local info = wheel_info.get(id)
    for k,v in pairs(award) do 
        if temp[v] then
            temp[v] = temp[v] + 1
        else
            temp[v] = 1
        end
    end
    
    for k,v in pairs(temp) do 
        if k < 8 then
            local _type = info["type_"..k]
            local _value = info["value_"..k]
            local _size = info["size_"..k]
            local award1 = {type=_type,value=_value,size=_size*v}
            table.insert(data,#data+1,award1)
        end
    end
    
    return data
end

function WheelMainLayer:updateTime(  )
    local time = G_Me.wheelData:getTimeLeft()
    if self._timeStart then
        self:updateView()
        self._timeStart = false
    end
    if time <= 0 then
        self._timeStart = true
        -- G_Me.wheelData:initState()
        -- self:updateView()
        if G_Me.wheelData:getState() == 1 then
            G_HandlersManager.wheelHandler:sendWheelRankingList()
        end
        if G_Me.wheelData:getState() == 2 then
            G_HandlersManager.wheelHandler:sendWheelInfo()
        end
    end
    self:showTime()
end

function WheelMainLayer:showTime(  )
    local time = G_Me.wheelData:getTimeLeft()
    local timeTitle = G_Me.wheelData:getState() == 1 and G_lang:get("LANG_WHEEL_ACTIVITY_TIME") or G_lang:get("LANG_WHEEL_SHOP_TIME")
    self._timeLabel:setText(timeTitle..G_GlobalFunc.formatTimeToHourMinSec(time))
end


function WheelMainLayer:moveTo( index )
    if self._curPage ~= index then
        self._pageView:jumpToPage(index - 1)
        self._curPage = index
    end
    if index == 1 then
        -- self._topTitle:loadTexture("ui/text/txt/titile_xingyunlunpan.png")
        self._ptWheelButton:loadTextureNormal(btnImg[2])
        self._jyWheelButton:loadTextureNormal(btnImg[1])
        self:getImageViewByName("Image_left"):setVisible(false)
        self:getImageViewByName("Image_right"):setVisible(true)
    else
        -- self._topTitle:loadTexture("ui/text/txt/title_haohualunpan.png")
        self._ptWheelButton:loadTextureNormal(btnImg[1])
        self._jyWheelButton:loadTextureNormal(btnImg[2])
        self:getImageViewByName("Image_left"):setVisible(true)
        self:getImageViewByName("Image_right"):setVisible(false)
    end
end
 
function WheelMainLayer:onLayerExit( ... )
    self.super:onLayerExit()
    if self._schedule then
        GlobalFunc.removeTimer(self._schedule)
        self._schedule = nil
    end
    uf_eventManager:removeListenerWithTarget(self)
end

function WheelMainLayer:initPageView( )
    local pagePanel = self:getPanelByName("Panel_wheel")
    if pagePanel == nil then
      return 
    end 
    self._pageView = CCSNewPageViewEx:createWithLayout(pagePanel)
end


function WheelMainLayer:_loadWheelPage(  )
  local PageItem = require("app.scenes.wheel.WheelPageItem")
  self._pageView:setPageCreateHandler(function ( page, index )
      local cell = PageItem.new()
      cell:setTouchEnabled(true)
      return cell
  end)

    self._pageView:setPageUpdateHandler(function ( page, index, cell )
        if cell and cell.initPageItem then 
            cell:initPageItem(index + 1, self)
            cell:updateView()
        end
    end)

  self._pageView:setPageTurnHandler(function ( page, index, cell )
        self:moveTo(index+1)
  end)

  self._pageView:setClickCellHandler(function ( pageView, index, cell)

  end)
  self._pageView:setClippingEnabled(false)

  self._pageView:showPageWithCount(wheel_info.getLength(), 0)

end

return WheelMainLayer

