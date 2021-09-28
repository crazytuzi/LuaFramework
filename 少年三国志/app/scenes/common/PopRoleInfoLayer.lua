require("app.cfg.basic_figure_info")
require("app.const.FigureType")

require("app.cfg.frame_info")

local FunctionLevelConst = require "app.const.FunctionLevelConst"
local EffectNode = require "app.common.effects.EffectNode"

local PopRoleInfoLayer = class("PopRoleInfoLayer",UFCCSModelLayer)

PopRoleInfoLayer.layer_is_show = false

function PopRoleInfoLayer.canShowRoleInfo( ... )
    return not PopRoleInfoLayer.layer_is_show
end

function PopRoleInfoLayer:ctor(...)
    self.super.ctor(self,...)

    self:adapterWithScreen()
    PopRoleInfoLayer.layer_is_show = true

    self:_initText()
    self:registerBtnClickEvent("Button_Close",handler(self,self.closeWindows))
    self:registerBtnClickEvent("Button_Comfirm",handler(self,self.closeWindows))
    
    self._timer = G_GlobalFunc.addTimer(1, handler(self,self.updateTime))
    local _role_info =  role_info.get(G_Me.userData.level)
    
    local label = self:getLabelByName("Label_Name")
    if label then 
        local mainInfo = G_Me.bagData.knightsData:getMainKightInfo()
        if mainInfo then 
            local knightInfo = knight_info.get(mainInfo["base_id"])
            if knightInfo then 
                label:setColor(Colors.getColor(knightInfo and knightInfo.quality or 1)) 
            end
        end
        label:setText(G_Me.userData.name)
        label:createStroke(Colors.strokeBrown,1)
    end
    --self:getLabelByName("Label_Name"):setText(G_Me.userData.name)
    --self:getLabelByName("Label_Name"):createStroke(Colors.strokeBrown,1)
    
    self:showWidgetByName("ImageView_friend", not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.AWAKEN))
    self:showWidgetByName("ImageView_shenhun", G_moduleUnlock:isModuleUnlock(FunctionLevelConst.AWAKEN))
    
    local labelFriendValue = self:getLabelByName("Label_FriendValue")
    labelFriendValue:setVisible(not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.AWAKEN))
    labelFriendValue:setText(table.nums(G_Me.friendData:getFriendList()))
    
    local labelShenhunValue = self:getLabelByName("Label_shenhunValue")
    labelShenhunValue:setVisible(G_moduleUnlock:isModuleUnlock(FunctionLevelConst.AWAKEN))
    labelShenhunValue:setText(G_Me.userData.god_soul)
    
    self:getLabelByName("Label_GoldValue"):setText(G_Me.userData.gold)
    self:getLabelByName("Label_PrestigeValue"):setText(G_Me.userData.prestige)
    self:getLabelByName("Label_SilverValue"):setText(G_Me.userData.money)
    
    -- local _, team1Count = G_Me.formationData:getFirstTeamKnightIds()
    -- local _, team2Count = G_Me.formationData:getSecondTeamKnightIds()
    -- local _num = team1Count + team2Count
    -- self:getLabelByName("Label_LineUpValue"):setText(_num)
    self:showTextWithLabel("Label_corpContriValue", G_Me.userData.corp_point)

    
    self:getLabelByName("Label_MedalValue"):setText(G_Me.userData.medal)
    self:getLabelByName("Label_JingPoValue"):setText(G_Me.userData.essence)
    self:getLabelByName("Label_TowerValue"):setText(G_Me.userData.tower_score)

    
    self:getLabelAtlasByName("LabelAtlas_VIP"):setStringValue(G_Me.userData.vip)
    
    self:getLabelByName("Label_FightValue"):setText(G_Me.userData.fight_value)
    self:getLabelByName("Label_FightValue"):createStroke(Colors.strokeBrown,2)
    
    self:getLabelByName("Label_Lv"):setText(G_Me.userData.level .. G_lang:get("LANG_FIGHTEND_GONGXI_AFTER"))
    --self:getLabelByName("Label_Lv"):createStroke(Colors.strokeBrown,1)
    
    self:getLabelByName("Label_ExpValue"):setText(G_Me.userData.exp .. "/" .. _role_info.experience)
    self:getLabelByName("Label_ExpValue"):createStroke(Colors.strokeBrown,2)
    self:getLoadingBarByName("LoadingBar_Exp"):setPercent(G_Me.userData.exp/_role_info.experience*100) 
    
    --self:getLabelByName("Label_Exp"):createStroke(Colors.strokeBrown,1)
    --self:getLabelByName("Label_Fight"):createStroke(Colors.strokeBrown,1)
    -- 用户信息界面增加称号
    local titleLabel = self:getLabelByName("Label_Title")
    local titleBgBtn = self:getButtonByName("Button_With_Title_Bg")
    titleLabel:setVisible(false)
    titleBgBtn:setVisible(false)
    if G_Me.userData:getTitleId() > 0 then
        require("app.cfg.title_info")
        local titleInfo = title_info.get(G_Me.userData.title_id)
        -- __Log("G_Me.userData.title_id = %d", G_Me.userData.title_id)
        -- dump(titleInfo)
        if titleInfo and type(titleInfo) == "table" then
            titleLabel:setVisible(true)
            titleLabel:setColor(Colors.getColor(titleInfo.quality))
            titleLabel:setText(titleInfo.name)
            titleLabel:createStroke(Colors.strokeBrown, 3)
            titleBgBtn:setVisible(true)
            titleBgBtn:loadTextureNormal(titleInfo.picture, UI_TEX_TYPE_LOCAL)  
            self:registerBtnClickEvent("Button_With_Title_Bg", function ( ... )
                local dialog = require("app.scenes.title.TitleDetailDialogInfo").create(G_Me.userData.title_id)
                -- TODO:这样加会不会有问题？？？
                self:addChild(dialog)
            end)  
        else
            titleLabel:setVisible(false)
            titleBgBtn:setVisible(false)
        end
    elseif G_Me.bagData:isTitleOutOfDate(G_Me.userData.title_id) then 
        -- 称号过期
        G_HandlersManager.titleHandler:sendUpdateFightValue()
    end
    
    self:updateTime(0)
    
    local knightId = G_Me.formationData:getMainKnightId()
    local baseId = G_Me.bagData.knightsData:getKnightByKnightId(knightId)["base_id"]
    require("app.cfg.knight_info")
    local knightInfo = knight_info.get(baseId)
    local resId = knightInfo.res_id
    resId = G_Me.dressData:getDressedPic()
    self:getImageViewByName("ImageView_Head"):loadTexture(G_Path.getKnightIcon(resId))
    self:setCascadeOpacityEnabled(true)

    self:getButtonByName("Button_knight"):loadTextureNormal(G_Path.getEquipColorImage(knightInfo.quality,G_Goods.TYPE_KNIGHT))

    --add by kaka for avatar frame

    -- self:registerWidgetClickEvent("ImageView_Head",handler(self,self._setFrameEvent))
    self:registerWidgetClickEvent("ImageView_Head",handler(self,self._changeNameOrFrame))
    self:registerBtnClickEvent("Button_SetFrame",handler(self,self._changeNameOrFrame))

    self:getButtonByName("Button_SetFrame"):setVisible(G_moduleUnlock:isModuleUnlock(FunctionLevelConst.SET_AVATAR))

    if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.SET_AVATAR) or G_moduleUnlock:isModuleUnlock(FunctionLevelConst.CHANGE_ROLE_NAME) then
        if G_moduleUnlock:isNewModule(FunctionLevelConst.SET_AVATAR) or G_moduleUnlock:isNewModule(FunctionLevelConst.CHANGE_ROLE_NAME) then
            if not self._headEffect then
                self._headEffect = EffectNode.new("effect_around1", function(event) end)
                self:getImageViewByName("ImageView_Head"):addNode(self._headEffect, 20)
                self._headEffect:setPositionX(3)
                self._headEffect:setScale(1.6)
                self._headEffect:play()
            end   
        end
    end     
end

function PopRoleInfoLayer:_setFrameEvent()

    if not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.SET_AVATAR) then
        return
    end

    local layer = require("app.scenes.common.RoleAvatarFrameListLayer").create()
    --PopRoleInfoLayer.layer_is_show = false
    --self:close()  --直接关掉PopRoleInfoLayer
    --uf_sceneManager:getCurScene():addChild(layer)
    uf_notifyLayer:getModelNode():addChild(layer)  
    --layer:setConfirmCallback(function()
        --TODO
    --    end) 
end

function PopRoleInfoLayer:_changeNameOrFrame(  )
    local posX, posY = self:getImageViewByName("ImageView_Head"):convertToWorldSpaceXY(0, 0)

    local changeFrameOrNameLayer = require("app.scenes.changename.ChangeFrameOrNameBtnPopupLayer").create(posX, posY)
    uf_sceneManager:getCurScene():addChild(changeFrameOrNameLayer)
end

function PopRoleInfoLayer:_updateAvatar()

    local frameId = G_Me.userData:getFrameId()
    if frameId > 0 then

        local frame = frame_info.get(frameId)
        if frame then
            self:getImageViewByName("ImageView_Frame"):setVisible(true)
            self:getImageViewByName("ImageView_Frame"):loadTexture(G_Path.getAvatarFrame(frame.res_id))
            G_GlobalFunc.addHeadIcon(self:getImageViewByName("ImageView_Frame"),frame.vip_level)
        else
            self:getImageViewByName("ImageView_Frame"):setVisible(false)
        end
    else
        self:getImageViewByName("ImageView_Frame"):setVisible(false)
    end
    
end

function PopRoleInfoLayer:_removeAvatarEffect()

    if self._headEffect then
        self._headEffect:removeFromParentAndCleanup(true)
        self._headEffect = nil
    end  
    
end

function PopRoleInfoLayer:_initText()
    self:getLabelByName("Label_Exp"):setText(G_lang:get("LANG_EXP"))
    --self:getLabelByName("Label_Fight"):setText(G_lang:get("LANG_INFO_FIGHT"))
    self:getLabelByName("Label_Gold"):setText(G_lang:get("LANG_GOLDEN") .. ":")
    self:getLabelByName("Label_Silver"):setText(G_lang:get("LANG_SILVER").. ":")
    
    local labelFriend = self:getLabelByName("Label_Friend")
    labelFriend:setVisible(not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.AWAKEN))
    labelFriend:setText(G_lang:get("LANG_INFO_FRIENDNUM").. ":")
    
    local labelShenhun = self:getLabelByName("Label_shenhun")
    labelShenhun:setVisible(G_moduleUnlock:isModuleUnlock(FunctionLevelConst.AWAKEN))
    labelShenhun:setText(G_lang:get("LANG_INFO_SHENHUN_NUM")..":")
    
    --self:getLabelByName("Label_LineUp"):setText(G_lang:get("LANG_INFO_SHANGZHENNUM"))
    self:getLabelByName("Label_Prestige"):setText(G_lang:get("LANG_SHENG_WANG"))
    self:getLabelByName("Label_Medal"):setText(G_lang:get("LANG_INFO_JIANGZHANG"))
    self:getLabelByName("Label_JingPo"):setText(G_lang:get("LANG_INFO_JIANGHUN"))
    self:getLabelByName("Label_Tower"):setText(G_lang:get("LANG_ZHAN_GONG"))
    self:getLabelByName("Label_JingLi"):setText(G_lang:get("LANG_INFO_JINGLI"))
    self:getLabelByName("Label_TiLi"):setText(G_lang:get("LANG_INFO_TILI"))
    self:getLabelByName("Label_ChuZheng"):setText(G_lang:get("LANG_INFO_CHUZHENGLING").. ":")
    self:getLabelByName("Label_JingLiRestore"):setText(G_lang:get("LANG_INFO_JINGLI_RESTORE"))
    self:getLabelByName("Label_JingLiRestoreAll"):setText(G_lang:get("LANG_INFO_JINGLI_RESTORE_ALL"))
    self:getLabelByName("Label_TiLiRestore"):setText(G_lang:get("LANG_INFO_TILI_RESTORE"))
    self:getLabelByName("Label_TiLiRestoreAll"):setText(G_lang:get("LANG_INFO_TILI_RESTORE_ALL"))
    self:getLabelByName("Label_ChuZhengRestore"):setText(G_lang:get("LANG_INFO_CHUZHENGLING_RESTORE"))
    self:getLabelByName("Label_ChuZhengRestoreAll"):setText(G_lang:get("LANG_INFO_CHUZHENGLING_RESTORE_ALL"))
    
end

function PopRoleInfoLayer.create()
    return PopRoleInfoLayer.new("ui_layout/common_PopRoleInfoLayer.json",Colors.modelColor)
end

function PopRoleInfoLayer:closeWindows()
--    local winSize = CCDirector:sharedDirector():getWinSize()
--    local array = CCArray:create()
--    array:addObject(CCMoveTo:create(0.3,ccp(winSize.width*0.5,winSize.height*1.5)))
--    array:addObject(CCCallFunc:create(handler(self,self.destoryLayer)))
--    self:getImageViewByName("ImageView_Bg"):runAction(CCSequence:create(array))
    PopRoleInfoLayer.layer_is_show = false
    self:startAction()
end

function PopRoleInfoLayer:destoryLayer()
    self:close()
end

function PopRoleInfoLayer:onLayerEnter()
    local winSize = CCDirector:sharedDirector():getWinSize()
    self:setOpacity(0)
    self:getImageViewByName("ImageView_Bg"):setPosition(ccp(winSize.width*0.5,winSize.height*1.5))

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_AVATAR_FRAME_CHANGE,self._updateAvatar, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_AVATAR_FRAME_FUNCTION,self._removeAvatarEffect, self)

    -- uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROLE_INFO_CLOSE_CHANGE_NAMEFRAME_BTN_LAYER, self._closeBtnPopLayer, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CHANGE_ROLE_NAME_SUCCEED, self._onChangeRoleNameSucceed, self)

    self:_updateAvatar()
    --local moveTo = CCMoveTo:create(0.3,ccp(winSize.width*0.5,winSize.height*0.5))
    --local array = CCArray:create()
    --array:addObject(moveTo)
    --array:addObject()
    --local seq = CCSpawn:create(array)
   --self:getImageViewByName("ImageView_Bg"):runAction(CCFadeTo:create(0.3,255))
   self:startAction()
end

function PopRoleInfoLayer:_onChangeRoleNameSucceed(  )
    local label = self:getLabelByName("Label_Name")
    label:setText(G_Me.userData.name)
end

-- 计算移动速度,透明度速度
function PopRoleInfoLayer:calcSpeed()
    local bg = self:getImageViewByName("ImageView_Bg")
    local y = bg:getPositionY()
    local winSize = CCDirector:sharedDirector():getWinSize()
    local t = 10
    if y > winSize.height then
        self.moveSpeed = -(y - winSize.height*0.5)/t
        self.opacitySpeed = 255/t
    else
        self.moveSpeed = (winSize.height*1.5 - y)/t
        self.opacitySpeed = -255/t/1.5
    end
end

function PopRoleInfoLayer:startAction()
    self:calcSpeed()
    self._movetimer = G_GlobalFunc.addTimer(0.01,handler(self,self.moveAction))
end
function PopRoleInfoLayer:moveAction(dt)
    local bg = self:getImageViewByName("ImageView_Bg")
    local winSize = CCDirector:sharedDirector():getWinSize()
    local y = bg:getPositionY()
    y = y +self.moveSpeed
    if self.moveSpeed > 0 then
        if y >= winSize.height*1.5 then
            bg:setPositionY(winSize.height*1.5)
            if self._movetimer then
                G_GlobalFunc.removeTimer(self._movetimer)
                self._movetimer = nil
            end
             self:close()
        else
            bg:setPositionY(y)
            local opacity = self:getOpacity()
            opacity = opacity+self.opacitySpeed
            if opacity < 0 then
                self:setOpacity(0)
            else
                self:setOpacity(opacity)
            end
        end
    else
        if y <= winSize.height*0.5 then
            bg:setPositionY(winSize.height*0.5)
            if self._movetimer then
                    G_GlobalFunc.removeTimer(self._movetimer)
                    self._movetimer = nil
            end
        else
            bg:setPositionY(y)
            local opacity = self:getOpacity()
            opacity = opacity+self.opacitySpeed
            if opacity >= 255 then
                self:setOpacity(255)
            else
                self:setOpacity(opacity)
            end
        end
    end
end

function PopRoleInfoLayer:onLayerExit()
    if self._timer then
        G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
    end

     if self._movetimer then
            G_GlobalFunc.removeTimer(self._movetimer)
            self._movetimer = nil
    end
end

local function setLeftTime(parent,txtName,refreshTime, isCountDown)
    local leftTime = G_ServerTime:getLeftSeconds(refreshTime)
    local _label = parent:getLabelByName(txtName)
    if leftTime > 0 then 
        --
        if isCountDown then
            _label:setText(G_ServerTime:getLeftSecondsString(refreshTime))
        else
            local desc, offset = G_ServerTime:getFutureTimeDesc(refreshTime, true)
            _label:setText(desc)
        end
    else
        if isCountDown then
            _label:setText("00:00:00")
        else
            _label:setColor(Colors.lightColors.ATTRIBUTE)
            _label:setText(G_lang:get("LANG_RES_FULL_TIP"))
        end
    end

    return leftTime
end

function PopRoleInfoLayer:updateTime(dt)
        local countDownOffset1 = 0

        local _info = basic_figure_info.get(TYPE_VIT)   -- 体力
        local _time = (G_Me.userData.vit+1) * _info.unit_time 
        
        if G_Me.userData.vit+1 > _info.time_limit then
            _time = _info.unit_time
        end
        
        local temp = G_Me.userData.refresh_vit_time -_info.time_limit*_info.unit_time
        temp = temp + _time
        if _info.time_limit-G_Me.userData.vit == 0 then _time = 0 end
        local offset = setLeftTime(self,"Label_TiLiRestoreTime", temp, true)
        if offset > 0 and offset > countDownOffset1 then 
            countDownOffset1 = offset
        end
        setLeftTime(self,"Label_TiLiRestoreAllTime",G_Me.userData.refresh_vit_time)
        
        _info = basic_figure_info.get(TYPE_SPIRIT) -- 精力
        _time = (G_Me.userData.spirit+1) * _info.unit_time 
        if G_Me.userData.spirit+1 > _info.time_limit then
            _time = _info.unit_time
        end
        temp = G_Me.userData.refresh_spirit_time -_info.time_limit*_info.unit_time
        temp = temp + _time
        if _info.time_limit-G_Me.userData.spirit == 0 then _time = 0 end
        offset = setLeftTime(self,"Label_JingLiRestoreTime",temp, true)
        if offset > 0 and offset > countDownOffset1 then 
            countDownOffset1 = offset
        end
        setLeftTime(self,"Label_JingLiRestoreAllTime",G_Me.userData.refresh_spirit_time)
        
        _info = basic_figure_info.get(TYPE_CHUZHENG) -- 出征令
        _time = (G_Me.userData.battle_token+1) * _info.unit_time 
        if G_Me.userData.battle_token+1 > _info.time_limit then
            _time = _info.unit_time
        end
        temp = G_Me.userData.battle_token_time -_info.time_limit*_info.unit_time
        temp = temp + _time
        if _info.time_limit-G_Me.userData.battle_token == 0 then _time = 0 end
        offset = setLeftTime(self,"Label_ChuZhengRestoreTime",temp, true)
        if offset > 0 and offset > countDownOffset1 then 
            countDownOffset1 = offset
        end
        setLeftTime(self,"Label_ChuZhengRestoreAllTime",G_Me.userData.battle_token_time)
        
        local _info = basic_figure_info.get(TYPE_SPIRIT) -- 精力
        self:getLabelByName("Label_JingLiPro"):setText(G_Me.userData.spirit .. "/" .. _info.time_limit)
        _info = basic_figure_info.get(TYPE_VIT) 
        self:getLabelByName("Label_TiLiPro"):setText(G_Me.userData.vit .. "/" .. _info.time_limit)
        _info = basic_figure_info.get(TYPE_CHUZHENG)         -- 出征令
        self:getLabelByName("Label_ChuZhengPro"):setText(G_Me.userData.battle_token .. "/" .. _info.time_limit)

        if countDownOffset1 < 1 then 
            if self._timer then
                G_GlobalFunc.removeTimer(self._timer)
                self._timer = nil
            end
        end
end


return PopRoleInfoLayer

