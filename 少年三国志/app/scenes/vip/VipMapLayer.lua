-- 日常副本
local VipMapLayer = class ("VipMapLayer", UFCCSNormalLayer)
local EffectNode = require "app.common.effects.EffectNode"
local JumpBackCard = require("app.scenes.common.JumpBackCard")
KnightPic = require("app.scenes.common.KnightPic")
Goods = require("app.setting.Goods")

VipMapLayer.BATTLE_MAP = 31013

function VipMapLayer.create( scenePack, ... )   
    return VipMapLayer.new("ui_layout/vip_fightLayerNewVersion.json", scenePack, ...) 
end

function VipMapLayer:ctor( json, scenePack, ... )  
    self.super.ctor(self, ...)
    GlobalFunc.savePack(self, scenePack)

    -- 当前boss在开放boss列表中的索引
    self._index = 1
    -- -- 如果周二、四。。。则进来直接显示今天开放的副本
    -- if G_Me.vipData:getDailyDungeonList()[1]["isOpenToday"] == false then
    --     self._index = 4
    -- end
    self._validPageCount = 0

    self._scrollView = self:getScrollViewByName("ScrollView_Top")
    self._costLabel = self:getLabelByName("Label_Vit")
    self:attachImageTextForBtn("Button_Fight", "ImageView_Fight")
    self._fightButton = self:getButtonByName("Button_Fight")
    self._cover = self:getPanelByName("Panel_Cover")
    self._cover:setVisible(false)
    -- 可滑动区域上面的boss icon
    self._btns = {}
    
    self:_initScrollView()
    self:getLabelByName("Label_Vit_Tag"):createStroke(Colors.strokeBrown, 1)
    self:showWidgetByName("Label_Beaten_Txt", false)
    self:getLabelByName("Label_Beaten_Txt"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_Unbeaten_Txt"):createStroke(Colors.strokeBrown, 1)
    
    self:registerBtnClickEvent("Button_Fight", function()
        local dungeonInfo = G_Me.vipData:getDailyDungeonList()[self._index] 
        local open_level = dungeonInfo.level_1
        if dungeonInfo["isOpenToday"] == false then
            -- 此时按钮已被置为不可点
            return
        elseif G_Me.userData.level >= open_level then
            self:startFight(self._index)
        else
            G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_HOLIDAY_LEVEL_NOT_ENOUGH"))
        end
    end)

    self:registerBtnClickEvent("Button_Left", function()
        if self._index > 1 then
            self:updateBoss(self._index - 1)
        end
    end)

    self:registerBtnClickEvent("Button_Right", function()
        if self._index < self._validPageCount then
            self:updateBoss(self._index + 1)
        end
    end)

    self:registerBtnClickEvent("Button_Help", function (  )
        self:_onHelpBtnClicked()
    end)

    self:registerBtnClickEvent("Button_StoryDungeon",function()
        local FunctionLevelConst = require("app.const.FunctionLevelConst")
        local level = G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.STORY_DUNGEON)
        if G_Me.userData.level >= level  then
            uf_sceneManager:replaceScene(require("app.scenes.storydungeon.StoryDungeonMainScene").new())
        else
            G_MovingTip:showMovingTip(G_lang:get("LANG_PLAY_STORYDUNGEON_TIPS",{level = level}))
        end
    end)

    self:registerBtnClickEvent("Button_Dungeon",function()
        uf_sceneManager:replaceScene(require("app.scenes.dungeon.DungeonMainScene").new())
    end)

    --添加特效
    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        local bgImage = self:getImageViewByName("ImageView_bg")
        self._bgEffect01 = EffectNode.new("effect_pj", function(event, frameIndex)
                    end)  
        self._bgEffect01:setPosition(ccp(0,0))
        bgImage:addNode(self._bgEffect01)
        self._bgEffect01:play()
        self._bgEffect02 = EffectNode.new("effect_sunshine_pj", function(event, frameIndex)
                    end)  
        self._bgEffect02:setPosition(ccp(0,0))
        bgImage:addNode(self._bgEffect02)
        self._bgEffect02:play()
    end
end

function VipMapLayer:onLayerEnter( ... )
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DUNGEON_DAILY_INFO, self._onDungeonDailyInfo, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DUNGEON_DAILY_CHALLENGE, self._onDungeonDailyChallenge, self)

    G_HandlersManager.vipHandler:sendGetDungeonDailyInfo()

    -- 显示名将副本提示
    local FunctionLevelConst = require("app.const.FunctionLevelConst")
    local level = G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.STORY_DUNGEON)
    if G_Me.userData.level >= level then
        self:getImageViewByName("Image_StoryTips"):setVisible(G_Me.storyDungeonData:isHaveBouns() or G_Me.storyDungeonData:getExecutecount() > 0)
    else
        self:getImageViewByName("Image_StoryTips"):setVisible(false)
    end
    self:getImageViewByName("Image_Tips"):setVisible(G_Me.dungeonData:hasUnclaimedBox())
end

-- 初始化顶部boss icon所在的scrollview
function VipMapLayer:_initScrollView( )
    local dungeonList = G_Me.vipData:getDailyDungeonList()

    self._scrollView:removeAllChildren()
    local space = 12 --间隙
    local size = self._scrollView:getContentSize()
    local knightItemWidth = 170
    local maxLength = #dungeonList

    self._validPageCount = 0
    for i = 1, maxLength do
        local widget = require("app.scenes.vip.VipMapCell").new()

        widget:updateView(i, function (index)
            self:_clicked(index)
            __Log("index: %d", index)
        end)
        self._btns[i] = widget

        widget:setPosition(ccp(knightItemWidth*(i-1)+i*space,0))

        self._scrollView:addChild(widget)
        self._validPageCount = self._validPageCount + 1
    end

    local scrollViewWidth = knightItemWidth * self._validPageCount + space * (self._validPageCount + 1)
    self._scrollView:setInnerContainerSize(CCSizeMake(scrollViewWidth, size.height))
end

function VipMapLayer:updateView(index, hasEnter)
    self._index = index

    self:_initHeroPageView()
    if self and self._loadHeroPage then 
        self:_loadHeroPage()
    end

    if hasEnter == -1 then
        self:_enterAnime()
    end

    self:updateBoss(index)
    self._costLabel:createStroke(Colors.strokeBrown, 1)
end

function VipMapLayer:_initHeroPageView(  )
    local pagePanel = self:getPanelByName("Panel_Scroll")
    if pagePanel == nil then
        return 
    end 

    self._heroPageView = CCSNewPageViewEx:createWithLayout(pagePanel)
end

function VipMapLayer:_loadHeroPage(  )
    local HeroPageItem = require("app.scenes.vip.VipPageItem")
    self._heroPageView:setPageCreateHandler(function ( page, index )
        local cell = HeroPageItem.new()
        cell:setTouchEnabled(true)
        return cell
    end)

    self._heroPageView:setPageUpdateHandler(function ( page, index, cell )
        if cell and cell.initPageItem then 
            cell:initPageItem(index + 1, self)
        end
    end)

    self._heroPageView:setPageTurnHandler(function ( page, index, cell )
        local oldCell = self._heroPageView:getPageCell(self._index - 1)
        if oldCell then
            oldCell:hideQipao()
        end
        self:updateBoss(index+1)
        if cell  then 
            cell:showQipao()
        end
    end)

    self._heroPageView:setClickCellHandler(function ( pageView, index, cell)
        --self:_onHeroPageViewClicked(index + 1, knightId)
    end)
    self._heroPageView:setClippingEnabled(false)

    self._heroPageView:showPageWithCount(self._validPageCount, 0)
end

function VipMapLayer:_enterAnime( )
    GlobalFunc.flyIntoScreenLR({self:getWidgetByName("ScrollView_Top")}, false, 0.2, 2, 100)

    local dungeonList = G_Me.vipData:getDailyDungeonList()

    local info = dungeonList[self._index]
    local knight = self:getPanelByName("Panel_Hero")
    local resId = info.monster_image
    local worldPos = knight:convertToWorldSpace(ccp(0,0))
    local jumpKnight = JumpBackCard.create()
    local start = ccp(-500,0)
    knight:getParent():addNode(jumpKnight)
    -- knight:setVisible(false)
    self._heroPageView:setVisible(false)
    self._cover:setVisible(true)

    jumpKnight:play(resId, start, 0.375, worldPos, 0.75, function() 
        jumpKnight:removeFromParentAndCleanup(true)
        self._heroPageView:setVisible(true)
        self._cover:setVisible(false)
        local cell = self._heroPageView:getPageCell(self._index-1)
        if cell then
          cell:showQipao()
        end
    end )
end

function VipMapLayer:updateBoss( index )
    self._btns[self._index]:unchecked()
    self._btns[index]:checked()

    local dungeonList = G_Me.vipData:getDailyDungeonList()

    local maxLength = #dungeonList
    self._scrollView:scrollToPercentHorizontal((index - 1) * 100 / (maxLength - 1), 0.3, false)
    if self._heroPageView:getCurPageIndex() ~= index - 1 then
        self._heroPageView:jumpToPage(index - 1)
    end

    self._index = index
    local info = dungeonList[index]
    self:_initHero(info)
    self:setCost(info.expend)
end

function VipMapLayer:_initHero( info )
    self:getPanelByName("Panel_Hero"):setVisible(false)

    local hasBeaten = true

    local unbeatenDungeons = G_Me.vipData:getUnbeatenDungeons()
    for i=1, #unbeatenDungeons do
        if info.id == unbeatenDungeons[i] then
            hasBeaten = false
            break
        end
    end

    if hasBeaten then
        self:getLabelByName("Label_Beaten_Txt"):setText(G_lang:get("LANG_DAILY_DUNGEON_BEATEN_TXT", {name = info.name}))
    end

    if info.level_1 <= G_Me.userData.level and not hasBeaten then
        self._btns[self._index]:showTips(true)
    else
        self._btns[self._index]:showTips(false)
    end 

    if info["isOpenToday"] then
        if info.level_1 > G_Me.userData.level then
            -- 等级未到
            self:showWidgetByName("Label_Beaten_Txt", false)
            self:showWidgetByName("Label_Unbeaten_Txt", false)
            self._fightButton:setTouchEnabled(false)
        else
            self:showWidgetByName("Label_Beaten_Txt", hasBeaten)
            self:showWidgetByName("Label_Unbeaten_Txt", not hasBeaten)
            self._fightButton:setTouchEnabled(not hasBeaten)
        end
    else
        self:showWidgetByName("Label_Beaten_Txt", false)
        self:showWidgetByName("Label_Unbeaten_Txt", false)
        self._fightButton:setTouchEnabled(false)
    end
end

function VipMapLayer:_clicked( index )
    self:updateBoss(index)
end

function VipMapLayer:setCost( cost )
    self._costLabel:setText(cost)
end

function VipMapLayer:startFight(  )
    local info = G_Me.vipData:getDailyDungeonList()[self._index]
    --检查包裹是否满了
    local CheckFunc = require("app.scenes.common.CheckFunc")
    if CheckFunc.checkBagFullByType(info.type) then
        return
    end

    if G_Me.userData.vit < info.expend then
        G_GlobalFunc.showPurchasePowerDialog(1)
        return 
    end

    require("app.scenes.vip.VipFightPreviewLayer").show(info)
end

function VipMapLayer:_onDungeonDailyInfo( data )
    self:updateView(self._index)
end

function VipMapLayer:_onDungeonDailyChallenge(data)
    if data.ret == 1 then        
        local dungeonIndex = self._index
        local callback = function()
            local FightEnd = require("app.scenes.common.fightend.FightEnd")
            local awardTable = {}
            for i, v in ipairs(data.drop_awards) do
                if v.type == G_Goods.TYPE_MONEY then
                    -- 银两
                    awardTable = {dungeon_daily_yinliang = v.size}
                elseif v.type == G_Goods.TYPE_TREASURE then
                    -- 黄金经验宝物
                    if v.value == 2 then
                        awardTable = {dungeon_daily_huangjinjingyanbaowu = v.size}
                    end
                elseif v.type == G_Goods.TYPE_KNIGHT then
                    -- 金龙宝宝
                    if v.value == 2003 then
                        awardTable = {dungeon_daily_jinlongbaobao = v.size}
                    end
                elseif v.type == G_Goods.TYPE_ITEM then
                    if v.value == 13 then
                        -- 极品精炼石                        
                        awardTable = {dungeon_daily_jipinjinglianshi = v.size}
                    elseif v.value == 18 then
                        -- 宝物精炼石
                        awardTable = {dungeon_daily_baowujinglianshi = v.size}
                    elseif v.value == 6 then
                        -- 突破石
                        awardTable = {dungeon_daily_tuposhi = v.size}
                    end
                end
            end

            FightEnd.show(FightEnd.TYPE_DUNGEON_DAILY, data.info.is_win,
                awardTable,               
                function() 
                    uf_sceneManager:replaceScene(require("app.scenes.vip.VipMapScene").new(dungeonIndex))
                end 
            )
        end
        local battle = nil
        G_Loading:showLoading(function ( ... )
            --创建战斗场景
            if not data or (not self) then
                return
            end
            battle = require("app.scenes.vip.VipBattleScene").new(
            {   data = data,
                func = callback,
                bg = G_Path.getDungeonBattleMap(VipMapLayer.BATTLE_MAP),
                fightId = self._index
            })
            uf_sceneManager:replaceScene(battle)
        end, 
        function ( ... )
            --开始播放战斗
            if battle then
                battle:play()
            end
        end)
       
    else
        -- G_MovingTip:showMovingTip(G_NetMsgError.getMsg(data.ret))
        -- MessageBoxEx.showOkMessage("error", G_NetMsgError.getMsg(data.ret))
    end  
end

function VipMapLayer:_onHelpBtnClicked(  )
    require("app.scenes.common.CommonHelpLayer").show(
        {
            {title = G_lang:get("LANG_DAILY_DUNGEON_HELP_TITLE"), content = G_lang:get("LANG_DAILY_DUNGEON_HELP")}
        })
    -- test protocal
    -- G_HandlersManager.vipHandler:sendDungeonDailyChallenge(201, 2)
    -- G_HandlersManager.vipHandler:sendDungeonDailyChallenge(201, 2)
    -- G_HandlersManager.vipHandler:sendDungeonDailyChallenge(201, 2)
end

function VipMapLayer:onBackKeyEvent( ... )
    local packScene = GlobalFunc.createPackScene(self)
    if not packScene then 
        packScene = require("app.scenes.dungeon.DungeonMainScene").new()
    end
    uf_sceneManager:replaceScene(packScene)

    return true
end

function VipMapLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

return VipMapLayer
