local ActivityGongGao = class("ActivityGongGao",UFCCSNormalLayer)
local FunctionLevelConst = require("app.const.FunctionLevelConst")
function ActivityGongGao.create(act_id)
    local layer = ActivityGongGao.new("ui_layout/activity_ActivityGongGao.json",act_id)
    return layer
end

function ActivityGongGao:ctor(_,act_id)
    self.super.ctor(self)
    self._activity = G_Me.activityData.custom:getActivityByActId(act_id)

    self._goBtn = self:getButtonByName("Button_go")
    self:_setWidgets()
    --[[描边]]
    self:getLabelByName("Label_title"):createStroke(Colors.strokeBrown,2)
    self:getLabelByName("Label_endTag"):createStroke(Colors.strokeBrown,2)
    self:getLabelByName("Label_endtime"):createStroke(Colors.strokeBrown,2)
    self:getLabelByName("Label_endTag"):setText(G_lang:get("LANG_DAYS7_ACTIVITY_END_TIME"))

    self:_updateGoButton()
    self:_initEvent()

    --local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    local GlobalConst = require("app.const.GlobalConst")
    --if appstoreVersion or IS_HEXIE_VERSION  then 
    --    knight = knight_info.get(GlobalConst.CAI_WEN_JI_HE_XIE_ID)
    --else
    --    knight = knight_info.get(GlobalConst.CAI_WEN_JI_ID)
    --end

    --英雄形象动态展示
    local knight = nil

    if self._activity and self._activity.role_icon > 0 then
        knight = knight_info.get(self._activity.role_icon)
    end

    if knight == nil then
        knight = knight_info.get(GlobalConst.CAI_WEN_JI_ID)
    end

    if knight then
        local heroPanel = self:getPanelByName("Panel_caiwenji")
        local KnightPic = require("app.scenes.common.KnightPic")
        KnightPic.createKnightPic( knight.res_id, heroPanel, "caiwenji",true )
        heroPanel:setScale(0.7)
        if self._smovingEffect == nil then
            local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
            self._smovingEffect = EffectSingleMoving.run(heroPanel, "smoving_idle", nil, {})
        end
    end

end

function ActivityGongGao:_initEvent()
    self:registerBtnClickEvent("Button_go",function()
        local questList = G_Me.activityData.custom:getQuestByActId(self._activity.act_id)
        if not questList or (#questList ~= 1) then
            return
        end
        local quest = questList[1]
        if not quest then
            return
        end

        --活动处于预览期
        if G_Me.activityData.custom:checkPreviewByActId(quest.act_id) then
            -- G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_IS_IN_PREVIEW"))
            G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_IS_IN_PREVIEW",{time=G_Me.activityData.custom:getStartDateByActId(quest.act_id)}))
            return
        end

        if quest.quest_type == 202 then  -- 名将副本将魂掉落数量翻倍    
            if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.STORY_DUNGEON) == true then
                uf_sceneManager:replaceScene(require("app.scenes.storydungeon.StoryDungeonMainScene").new())
                return
            end
        elseif quest.quest_type == 203 then  -- 日常副本资源掉落翻倍  
            if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.VIP_SCENE) then
                uf_sceneManager:replaceScene(require("app.scenes.vip.VipMapScene").new())
            end
            
        elseif quest.quest_type == 204 then  -- 竞技场战斗声望翻倍   
            if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.ARENA_SCENE) then
                uf_sceneManager:replaceScene(require("app.scenes.arena.ArenaScene").new()) 
            end
        elseif quest.quest_type == 205 then  --三国无双战斗威名翻倍   
            if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TOWER_SCENE) then
                uf_sceneManager:replaceScene(require("app.scenes.wush.WushScene").new())
            end
        elseif quest.quest_type == 206 then  -- 领地征讨物品掉落数量翻倍    
            if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.CITY_PLUNDER) then 
                G_Loading:showLoading(function()
                    uf_sceneManager:replaceScene(require("app.scenes.city.CityScene").new())
                end)
            end
        elseif quest.quest_type == 207 then -- 叛军战斗后功勋值翻倍   
            if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.MOSHENG_SCENE) then 
                uf_sceneManager:replaceScene(require("app.scenes.moshen.MoShenScene").new())
            end
        elseif quest.quest_type == 208 then -- 叛军战斗消耗征讨令减半  
            if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.MOSHENG_SCENE) then 
                uf_sceneManager:replaceScene(require("app.scenes.moshen.MoShenScene").new())
            end
        elseif quest.quest_type == 209 then  --神将抽将界面
            uf_sceneManager:replaceScene(require("app.scenes.shop.ShopScene").new())
        elseif quest.quest_type == 210 then   --神将商店
            if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.SECRET_SHOP) then
                uf_sceneManager:replaceScene(require("app.scenes.secretshop.SecretShopScene").new())
            end
        elseif quest.quest_type == 211 then   --集市
            local ShopVipConst = require("app.const.ShopVipConst")
            uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.shop.ShopScene").new(nil,nil,quest.param2 or 0))
        elseif quest.quest_type == 213 then   -- 将灵商店打折
            uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.herosoul.HeroSoulShopScene").new(nil))
        end
        end)
end

function ActivityGongGao:_updateGoButton()
  	local questList = G_Me.activityData.custom:getQuestByActId(self._activity.act_id)
    if not questList or (#questList ~= 1) then
		self:_showGoButton(false)
        return
    end
    local quest = questList[1]
    if not quest then
		self:_showGoButton(false)
        return
    end

    -- 更新前往按钮,201为主线副本翻倍活动，现在改为副本翻倍活动，影响主线和精英2个副本，2015.03.18
    if quest.quest_type == 201 then
		self:_showGoButton(true)
    else
    	self:_showGoButton(false)
    end

    -- 前往主线副本
    self:registerBtnClickEvent("Button_go_dungeon", function()
    	--活动处于预览期
        if G_Me.activityData.custom:checkPreviewByActId(quest.act_id) then
            G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_IS_IN_PREVIEW",{time=G_Me.activityData.custom:getStartDateByActId(quest.act_id)}))
            return
        end
    	uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.dungeon.DungeonMainScene").new())
    end)
    -- 前往精英副本
    self:registerBtnClickEvent("Button_go_hard_dungeon", function()
    	--活动处于预览期
        if G_Me.activityData.custom:checkPreviewByActId(quest.act_id) then
            G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_IS_IN_PREVIEW",{time=G_Me.activityData.custom:getStartDateByActId(quest.act_id)}))
            return
        end
	    if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.HARDDUNGEON) then
	        uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.harddungeon.HardDungeonMainScene").new())
	    end
    end)
end

-- isDungeon 表示主线副本和精英副本活动，合并为一个活动了
function ActivityGongGao:_showGoButton(isDungeon)
	isDungeon = isDungeon or false
    self:showWidgetByName("Button_go", not isDungeon)
	self:showWidgetByName("Button_go_dungeon", isDungeon)
	self:showWidgetByName("Button_go_hard_dungeon", isDungeon)
end

function ActivityGongGao:_setWidgets()
    self:getLabelByName("Label_title"):setText("")
    self:getLabelByName("Label_endtime"):setText("")
    self:getLabelByName("Label_desc"):setText("")
    if not self._activity then
      return
    end
    self:getLabelByName("Label_title"):setText(self._activity.title)
    self:getLabelByName("Label_desc"):setText(self._activity.desc)
    -- local timeString = G_ServerTime:getDateFormat(self._activity["end_time"])
    local timeString = G_ServerTime:getActivityTimeFormat(self._activity["start_time"],self._activity["end_time"])
    self:getLabelByName("Label_endtime"):setText(timeString)
end

function ActivityGongGao:updatePage(activity)
    if not activity then
        return
    end
    self._activity = activity.data
    self._act_id = activity.data.act_id
    self._activity = G_Me.activityData.custom:getActivityByActId(self._act_id)
    self:_setWidgets()
end

function ActivityGongGao:showPage()  
end

function ActivityGongGao:onLayerEnter( ... )
    if not self._activity then
        return
    end
   self:_setWidgets()
end

function ActivityGongGao:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
    if self._timer then
        GlobalFunc.removeTimer(self._timer)
        self._timer = nil
    end
end

function ActivityGongGao:adapterLayer()
    self:adapterWidgetHeight("Panel_16","Image_17","",0,100)
end

return ActivityGongGao

