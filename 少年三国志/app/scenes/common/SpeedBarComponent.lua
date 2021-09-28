--SpeedBarComponent.lua

local BagConst = require("app.const.BagConst")
local SpeedBarComponent = class("SpeedBarComponent", UFCCSNormalLayer)
local selectBtnName = ""
local CheckFunc = require("app.scenes.common.CheckFunc")
local PlotlineDungeonType = require("app.const.PlotlineDungeonType")
local FunctionLevelConst = require("app.const.FunctionLevelConst")

local ButtonList =
{
    ["BagScene"] = "Button_Packbag",
    ["MainScene"] = "Button_MainPage",
    ["ShopScene"] = "Button_Shop",
    ["DungeonMainScene"] = "Button_Dungeon",
    ["PlayingScene"] = "Button_PlayRule",
    ["HeroScene"] = "Button_LineUp",
}

function SpeedBarComponent:ctor( ... )
	self.super.ctor(self, ...)
        selectBtnName = "Button_MainPage"
        self:showSelectBtn()
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SPEEDBAR, self._changeScene, self)
end

function SpeedBarComponent:onLayerLoad( ... )
    self:registerBtnClickEvent("Button_Dungeon",handler(self,self.onDungeonScene))
    self:registerBtnClickEvent("Button_MainPage",handler(self,self.onBackMain))
    self:registerBtnClickEvent("Button_Shop",handler(self,self.onShop))
    self:registerBtnClickEvent("Button_Packbag",handler(self,self.onPackbag))
    self:registerBtnClickEvent("Button_PlayRule",handler(self,self.onPlayRule))
    self:registerBtnClickEvent("Button_LineUp",handler(self,self.onLineUp))

    function setBMFontText(name,txt)
        local _label = self:getLabelBMFontByName(name)
        if _label then _label:setText(txt) end
    end
    
    self:registerBtnClickEvent("qianghua", self._onQianghua)



end

function SpeedBarComponent:onLayerEnter()
    -- 清理主线副本关卡地图拖动位置
    G_Me.dungeonData:setMapLayerPosYAndScale(100,1)
    G_Me.hardDungeonData:setMapLayerPosYAndScale(100,1)

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_DROP_KNIGHT_INFO, self._getShopDropKnightInfo, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_DROP_GOOD_KNIGHT, self._getDropGoodKnightResult, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_DROP_GODLY_KNIGHT, self._getDropGodlyKnightResult, self)

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_EQUIP_DIRTY_FLAG_CHANGED, self._onReceiveEquipDirtyFlagChange, self)
    
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._onBagDataChanged, self)
    -- 剧情副本
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_STORYDUNGEON_EXECUTEBARRIER, self._updateTips, self)
    

    --有宝物可合成,也显示玩法的提示
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._updateTips, self)
    
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_INFO, self._updateTips, self)

    --跨服战有连胜奖励可以领取，显示红点
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_WINS_AWARD_INFO, self._updateTips, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_FINISH_WINS_AWARD, self._updateTips, self)

    --百战沙场
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CRUSADE_UPDATE_BATTLEFIELD_INFO, self._updateTips, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CRUSADE_UPDATE_AWARD_INFO, self._updateTips, self)

    --充值后,vip发生变化
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECHARGE_SUCCESS, self._showShopTipsImage, self)

    --购买成功的消息比包裹变化的消息晚到，无法根据包裹变化判断vip礼包的购买变化
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_ITEM_BUY_RESULT, self._showShopTipsImage, self)

    -- 隔天了，限时抽将有免费次数了，更新商城红点
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_THEME_DROP_ENTER_MAIN_LAYER, self._showShopTipsImage, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_THEME_DROP_UPDATE_SHOP_TIPS, self._showShopTipsImage, self)

    -- 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HARD_RIOT_UPDATE_MAIN_LAYER, self.showDungeonTips, self)
 
    -- 战宠护佑
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_USER_LEVELUP, self._updateTips, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._updateTips, self)    

    --更新下面所有按钮红点
    self:_updateTips()

    --发送招将消息
    if not G_Me.shopData:checkDropInfo() then
        G_HandlersManager.shopHandler:sendDropKnightInfo()  
    end
    
    --发送商城信息
    if not G_Me.shopData:checkEnterScoreShop() then 
      require("app.const.ShopType")
      G_HandlersManager.shopHandler:sendShopInfo(SHOP_TYPE_SCORE)
    end


    -- 请求剧情副本信息
    if G_Me.storyDungeonData:getDungeonList() == nil then
            G_HandlersManager.storyDungeonHandler:sendGetStoryList()
    end

    -- 检查是否有符合要求的情况，决定是否冒红点
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CITY_INFO, self._updateTips, self)
    
end

function SpeedBarComponent:_onBagDataChanged( changeType, buff )
   if BagConst.CHANGE_TYPE.AWAKEN_ITEM == changeType then 
      self:_updateTips()
   end
end

-- 更新下面所有按钮红点
function SpeedBarComponent:_updateTips()

    if  G_commonLayerModel:getDelayUpdate() == true then
        return
    end  

    --阵容
    self:showWidgetByName("Image_LineUpTips",
     G_HandlersManager.fightResourcesHandler:getEffectEquipFlag() 
     or G_Me.formationData:hasAwakenEquipForTeamKnight())

    --商城
    self:_showShopTipsImage()

   --征战
    self:showPlayTips()
    self:showDungeonTips()
end


-- 场景切换
function SpeedBarComponent:_changeScene(sceneName)
    if ButtonList[sceneName] then
        self:setSelectBtn(ButtonList[sceneName])
    else

        self:setSelectBtn("")
    end
end

function SpeedBarComponent:_onReceiveEquipDirtyFlagChange( flag )
    if  G_commonLayerModel:getDelayUpdate() == true then
        return
    end  
    self:showWidgetByName("Image_LineUpTips", flag and true or false)
end



function SpeedBarComponent:_onLayerUnload(...)
 -- uf_eventManager:removeListenerWithTarget(self)
end

--提醒玩家有免费抽卡或召将令
function SpeedBarComponent:_showShopTipsImage()
  if  G_commonLayerModel:getDelayUpdate() == true then
      return
  end  
  --检查是否进入过shop
  if not G_Me.shopData:checkDropInfo() then
    return
  end

  --极品
  local JPLeftTime = G_ServerTime:getLeftSeconds(G_Me.shopData.dropKnightInfo.jp_free_time)
  local JPTokenCount = G_Me.bagData:getGodlyKnightTokenCount()
  local LPTokenCount = G_Me.bagData:getGoodKnightTokenCount()
  local LPLeftTime = G_ServerTime:getLeftSeconds(G_Me.shopData.dropKnightInfo.lp_free_time)
  --vip礼包可购买
  local vipGifgbagEnabled = CheckFunc.checkVipGiftbagEnabled()
  -- 限时抽将，有免费次数，或可以抽红将了
  local themeDropTips = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.THEME_DROP) and (G_Me.themeDropData:hasFreeTimes() or G_Me.themeDropData:couldExtractKnight())
  self:showWidgetByName("Image_shopTips",(LPLeftTime<=0 and G_Me.shopData.dropKnightInfo.lp_free_count < 3) or JPLeftTime<=0 or LPTokenCount > 0 or JPTokenCount > 0 or vipGifgbagEnabled or themeDropTips)
end

function SpeedBarComponent:_getShopDropKnightInfo(data)
  self:_showShopTipsImage()
end
function SpeedBarComponent:_getDropGoodKnightResult(data)
  self:_showShopTipsImage()
end
function SpeedBarComponent:_getDropGodlyKnightResult(data)
  self:_showShopTipsImage()
end



-- @desc 设置选中状态
function SpeedBarComponent:showSelectBtn()
    self:showPlayTips()
    self:showDungeonTips()
    local btn = self:getButtonByName(selectBtnName)
    local _selectImg = self:getImageViewByName("ImageView_Select")
    if btn then 
        if _selectImg then _selectImg:setPositionX(btn:getPositionX()) end
        _selectImg:setVisible(true)
    else
        _selectImg:setVisible(false)
    end
    if selectBtnName ~= "Button_Dungeon" then
        --G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.MAIN)
    end
end

-- @desc 得到按钮选中状态
function SpeedBarComponent.getSelectBtnName()
    return selectBtnName
end

function SpeedBarComponent.create()
    return SpeedBarComponent.new("ui_layout/common_SpeedBarComponent.json")
end

function SpeedBarComponent:onDungeonScene(widget)
     if selectBtnName ~= "Button_Dungeon" then
        self:_checkSwitchEnable(nil, function ( ... )
            selectBtnName = "Button_Dungeon"
            uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.dungeon.DungeonMainScene").new())
        end)
     end
end

function SpeedBarComponent:_checkSwitchEnable( param, fun )
  local curScene = uf_sceneManager:getCurScene()
  if not curScene or not curScene.onSceneSwitch then 
    if fun then 
      fun()
    end
    return false
  end

  if curScene:onSceneSwitch(param, fun) then 
    return true
  end

  if fun then 
    fun()
  end
  return false
end

-- @清理选中状态
function SpeedBarComponent:setSelectBtn(btnName)
    selectBtnName = btnName == nil and  "" or btnName
    self:showSelectBtn()
end

-- 包裹
function SpeedBarComponent:onPackbag(widget)
     if selectBtnName ~= "Button_Packbag" then
        self:_checkSwitchEnable(nil, function ( ... )
            selectBtnName = "Button_Packbag"
            local scanePack = nil
            if G_SceneObserver:getSceneName() == "AwakenShopScene" then
              scanePack = GlobalFunc.sceneToPack("app.scenes.awakenshop.AwakenShopScene", {})
            end
            uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.bag.BagScene").new(nil, scanePack))
        end)
     end
end

-- 阵容
function SpeedBarComponent:onLineUp(widget)
     if selectBtnName ~= "Button_LineUp" then
        self:_checkSwitchEnable(nil, function ( ... )
            selectBtnName = "Button_LineUp"
            uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.hero.HeroScene").new( 1))
      --  uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.mynotabledungeon.MyNotableDungeonMainScene").create())
          end) 
     end
end

-- 玩法
function SpeedBarComponent:onPlayRule(widget)
     if selectBtnName ~= "Button_PlayRule" then
        self:_checkSwitchEnable(nil, function ( ... )
            selectBtnName = "Button_PlayRule"
            uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.mainscene.PlayingScene").new())
        end)  
     end
end

function SpeedBarComponent:onBackMain(widget)
      if selectBtnName ~= "Button_MainPage" then
        self:_checkSwitchEnable(nil, function ( ... )
            selectBtnName = "Button_MainPage"
            uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.mainscene.MainScene").new(nil, nil, true))
        end) 
      end
end

--商城
function SpeedBarComponent:onShop(widget)
      if selectBtnName ~= "Button_Shop" then
        self:_checkSwitchEnable(nil, function ( ... )
            selectBtnName = "Button_Shop"
--    uf_sceneManager:replaceScene(require("app.scenes.shop.ShopScene").new("ui/shop/shop_normal.json"))
            uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.shop.ShopScene").new())
        end) 
    end
end

function SpeedBarComponent._onQianghua(widget)
    uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.herofoster.HeroFosterScene").new(1))
end

-- @desc 返回首页
function SpeedBarComponent:backMain()
    self:setSelectBtn("Button_MainPage")
end

-- @desc 返回玩法页面
function SpeedBarComponent:backPlay()
    self:setSelectBtn("Button_PlayRule")
end

-- @desc 玩法tips
function SpeedBarComponent:showPlayTips()
    if  G_commonLayerModel:getDelayUpdate() == true then
      return
    end 

    --先检查夺宝等级
    -- if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TREASURE_COMPOSE) == true  then
    --     local visible = CheckFunc.checkTreasureComposeEnabled()
    --     self:showWidgetByName("Image_PlayTips",visible)
    -- end

    -- self:showWidgetByName("Image_PlayTips", G_Me.cityData:needPatrol() or G_Me.cityData:needHarvest())

    local treasureCompose = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TREASURE_COMPOSE) and CheckFunc.checkTreasureComposeEnabled()
    local city = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CITY_PLUNDER) and (G_Me.cityData:needPatrol() or G_Me.cityData:needHarvest())
    local wush = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TOWER_SCENE) and G_Me.wushData:showTips()
    local crossWar = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CROSS_WAR) and (G_Me.crossWarData:checkCanGetAward() or G_Me.crossWarData:canChooseGroup() or G_Me.crossWarData:canChallenge())
    local rebelbossTip = false
    if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.REBEL_BOSS) then
        local hasAward = false
        local hasChallengeTime = false
        for i=1, 3 do
            if G_Me.moshenData:hasRebelBossAward(i) then
                hasAward = true
                break
            end
        end
        if G_Me.moshenData:hasRebelBossChallengeTime() then
            hasChallengeTime = true
        end
        if hasAward or hasChallengeTime then
            rebelbossTip = true
        end
    end

    --百战沙场
    local crusadeTip = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CRUSADE) and (G_Me.crusadeData:showMainEntryTip())
    local dailyPvpTip = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.DAILY_PVP) and (G_Me.dailyPvpData:needTips() or G_Me.dailyPvpData:getAwardCountLeft() > 0)

    self:showWidgetByName("Image_PlayTips", treasureCompose or city or wush or crossWar or rebelbossTip or crusadeTip or dailyPvpTip)

end

-- @desc 副本tips
function SpeedBarComponent:showDungeonTips()
    if  G_commonLayerModel:getDelayUpdate() == true then
      return
    end 


    local vip = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.VIP_SCENE) and G_Me.vipData:getLeftCount()>0
    local story = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.STORY_DUNGEON) and (G_Me.storyDungeonData:isHaveBouns() or G_Me.storyDungeonData:getExecutecount() > 0)
    local dungeon = G_Me.dungeonData:hasUnclaimedBox()
    -- 精英副本有暴动章节，并且没有被打过的
    local hasRiot = G_Me.hardDungeonData:curTimeExistRiotsAlive()
    -- 玩家等级达到50，并且没有进入过精英副本
    local isEnteredHardDungeon = G_Me.hardDungeonData:isEnteredHardDungeon()

    self:showWidgetByName("Image_DungeonTips", vip or story or dungeon or hasRiot or not isEnteredHardDungeon)
end

return SpeedBarComponent
