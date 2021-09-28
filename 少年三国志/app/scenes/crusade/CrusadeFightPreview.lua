
require("app.cfg.knight_info")
require("app.cfg.passive_skill_info")
require("app.cfg.battlefield_info")


local Colors = require("app.setting.Colors")

local CrusadeFightPreview = class("CrusadeFightPreview", UFCCSModelLayer)

local function _setStroke(parent,labelName,num)
    local _name = parent:getLabelByName(labelName)
    if _name then 
        _name:createStroke(Colors.strokeBrown,num)
    end
end

function CrusadeFightPreview:onBackKeyEvent( ... )
    self:_closeWindow()
    return true
end

function CrusadeFightPreview.create(gateId, callback, ...)
    return CrusadeFightPreview.new("ui_layout/crusade_FightPreview.json",Colors.modelColor,gateId,callback, ...)
end

function CrusadeFightPreview:ctor(json, color, gateId, callback, ...)
    self.super.ctor(self, json, color, ...)
    self:adapterWithScreen()

    self._callback = callback
    self._gateId = gateId

    self:registerBtnClickEvent("closebtn",handler(self,self._closeWindow))
    self:registerBtnClickEvent("Button_Challenge",handler(self,self._onChallenge))
    self:registerBtnClickEvent("Button_BuZhen",handler(self,self._onBuZhen))

    _setStroke(self, "Label_Name",2)

    self:_initBattleFieldDetail()

end


function CrusadeFightPreview:_initBattleFieldDetail()
  
    self:registerKeypadEvent(true)

    self._awardValue = self:getLabelByName("Label_AwardValue")
    self._awardImage = self:getImageViewByName("Image_Award")
    self._awardValue:setVisible(false)
    self._awardImage:setVisible(false)

    self:showTextWithLabel("Label_Name", "")

    self:showTextWithLabel("Label_ServerName", "")
    self:showTextWithLabel("Label_Award", G_lang:get("LANG_CRUSADE_GET_AWARD"))
    self:showWidgetByName("Label_Award",false)
    self:showTextWithLabel("Label_AwardValue", "")
    self:showTextWithLabel("Label_LevelValue", "")
    self:showTextWithLabel("Label_Power", G_lang:get("LANG_CRUSADE_OPP_POWER"))
    self:showTextWithLabel("Label_PowerValue", "")

    self:showTextWithLabel("Label_AwardBuff", "")
    self:showTextWithLabel("Label_Score", G_lang:get("LANG_CRUSADE_GET_SCORE"))
    self:showTextWithLabel("Label_ScoreValue", "")
    
    self:getPanelByName("Panel_119"):setVisible(false)
    self:getImageViewByName("ImageView_FromationBg"):setVisible(false)
    self:getButtonByName("Button_Challenge"):setVisible(false)
   
end


function CrusadeFightPreview:_closeWindow()
    self:animationToClose() 
end

function CrusadeFightPreview:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

function CrusadeFightPreview:onLayerEnter()
    self:closeAtReturn(true)

    require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("ImageView_762"), "smoving_bounce")
 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CRUSADE_UPDATE_BATTLEFIELD_DETAIL, self._updateBattleFieldDetail, self)

    local needRequest = false 

    --优化：避免每次都请求服务器
    if G_Me.crusadeData:getLastRequestID() ~= self._gateId then
        G_HandlersManager.crusadeHandler:sendGetBattleFieldDetail(self._gateId)
    else
        self:_updateBattleFieldDetail()   --使用本地缓存数据
    end

end


function CrusadeFightPreview:_updateBattleFieldDetail(data)

    local _heroInfo = G_Me.crusadeData:getHeroInfo(self._gateId)

    if _heroInfo and _heroInfo.user then
             
        --dump(_heroInfo)

        --显示人物形象
        local resID = G_Me.dressData:getDressedResidWithClidAndCltm(_heroInfo.user.main_role, _heroInfo.user.dress_id,
            rawget(_heroInfo.user,"clid"),rawget(_heroInfo.user,"cltm"),rawget(_heroInfo.user,"clop"))
        local head = require("app.scenes.common.KnightPic").createKnightPic(resID,self:getPanelByName("Panel_4"),"head",false)
        self:getPanelByName("Panel_4"):setScale(0.7)
    --    head:setPositionX(self:getPanelByName("Panel_4"):getContentSize().width*0.4)
    --    head:setPositionY(self:getPanelByName("Panel_4"):getContentSize().height*0.56)
        self:getPanelByName("Panel_4"):setPositionX(self:getPanelByName("Panel_4"):getPositionX()+75)
        self:getPanelByName("Panel_4"):setPositionY(self:getPanelByName("Panel_4"):getPositionY()-40)


        self:getPanelByName("Panel_119"):setVisible(true)
        self:getImageViewByName("ImageView_FromationBg"):setVisible(true)
        self:getButtonByName("Button_Challenge"):setVisible(true)


        --角色名
        self:showTextWithLabel("Label_Name", _heroInfo.user.name)
        local knightInfo = knight_info.get(_heroInfo.user.main_role)       
        local color = Colors.qualityColors[knightInfo.quality]
        self:getLabelByName("Label_Name"):setColor(color)

        --服务器名
        if _heroInfo.user.sname then
            self:showTextWithLabel("Label_ServerName", "[".._heroInfo.user.sname.."]")
        end

        --等级
        self:showTextWithLabel("Label_LevelValue", G_lang:get("LANG_CRUSADE_LEVEL1",{num=_heroInfo.level}))

        --战力
        local fight_value = rawget(_heroInfo.user, "fight_value") and _heroInfo.user.fight_value or 0
        self:showTextWithLabel("Label_PowerValue", G_GlobalFunc.ConvertNumToCharacter(fight_value))
        self:showTextWithLabel("Label_ScoreValue", tostring(_heroInfo.pet_point))

        local battlefield = battlefield_info.get(G_Me.crusadeData:getCurStage())
        
        --奖励
        local good = G_Goods.convert(battlefield.award_type, battlefield.award_value)
        if good then
            self._awardValue:setVisible(true)
            self._awardImage:setVisible(true)
            self:showWidgetByName("Label_Award",true)
            self._awardImage:loadTexture(good.icon_mini,good.texture_type)
            self._awardValue:setText(tostring(battlefield.award_size))
        end

        --额外奖励
        
        if battlefield and battlefield.ratio > 0 then
            self:showTextWithLabel("Label_AwardBuff",  G_lang:get("LANG_CRUSADE_AWARD_BUFF",{buff=tostring(battlefield.ratio/10)}))
        else
            self:showTextWithLabel("Label_AwardBuff",  G_lang:get("LANG_CRUSADE_AWARD_ADDI")) 
        end

        --战宠
        self:getImageViewByName("Image_pb_bg7"):setVisible(false)   --进度条不显示
        self:getLabelByName("info7"):setVisible(false)
        self:getImageViewByName("knight7"):setVisible(false)    --头像
        self:getImageViewByName("ico7"):setVisible(false)   --品质框
        self:getImageViewByName("kuang7"):setVisible(false)   --品质底图

        
        self:getLabelByName("name7"):setText("")

        local baseId = rawget(_heroInfo.user,"fight_pet") and _heroInfo.user.fight_pet or 0   
        local petInfo = pet_info.get(baseId)

        --dump(petInfo)

        if petInfo then
            local _pet = self:getImageViewByName("knight7")
            _pet:setVisible(true)
            _pet:loadTexture(G_Path.getPetIcon(petInfo.res_id))
            self:getImageViewByName("ico7"):setVisible(true)
            self:getImageViewByName("ico7"):loadTexture(G_Path.getEquipColorImage(petInfo.quality,G_Goods.TYPE_PET))         
            self:getImageViewByName("kuang7"):setVisible(true)
            self:getImageViewByName("kuang7"):loadTexture(G_Path.getEquipIconBack(petInfo.quality))         
            self:getLabelByName("name7"):createStroke(Colors.strokeBrown,1)
            self:getLabelByName("name7"):setText(petInfo.name)
            self:getLabelByName("name7"):setColor(Colors.qualityColors[petInfo.quality])
        else
            self:getLabelByName("name7"):setColor(Colors.lightColors.TIPS_02)
            self:getLabelByName("name7"):setText(G_lang:get("LANG_CRUSADE_KNIGHT_NONE"))
        end


        local function initKnight(index,data)
            
            local _index = index + 3

            if index > 3 then
                _index = index - 3
            end

            local _pb_image_bg = self:getImageViewByName("Image_pb_bg" .. _index)
            local _info = self:getLabelByName("info" .. _index)
            local _knight = self:getImageViewByName("knight" .. _index)
            local _ico = self:getImageViewByName("ico" .. _index)

            _pb_image_bg:setVisible(false)
            _info:setText("")
            _ico:setVisible(false)
            _knight:setVisible(false)
            _knight:showAsGray(false)


            if data then
                local baseId = data.base_id    
                local knightInfo = knight_info.get(baseId)
                local resId = knightInfo and knightInfo.res_id or 0

                _ico:setVisible(true)
                _knight:setVisible(true)
                _knight:loadTexture(G_Path.getKnightIcon(resId))
                _knight:setTag(_index)

                _ico:loadTexture(G_Path.getAddtionKnightColorImage(knightInfo and knightInfo.quality or 1))

                local progress = math.ceil(data.hp*100/data.max_hp)

                progress = math.min(progress, 100)
                _pb_image_bg:setVisible(progress > 0)

                if progress > 0 then
                    self:getLabelByName("percent".._index):createStroke(Colors.strokeBrown,1)
                    self:showTextWithLabel("percent".._index, progress.."%")
                    local progressBar = self:getLoadingBarByName("progressBar".._index)
                    if progressBar then
                        progressBar:runToPercent(progress, 0.001)
                    end
                else
                    _info:setText(G_lang:get("LANG_CRUSADE_KNIGHT_DEATH"))
                    _knight:showAsGray(true)
                end
            else
                _info:setText(G_lang:get("LANG_CRUSADE_KNIGHT_NONE"))       
            end
        end
     
        --初始化阵容
        for index = 1, 6 do
            initKnight(index,_heroInfo.knights[index])
        end

    end

end

function CrusadeFightPreview:_doChallenge()
    G_HandlersManager.crusadeHandler:sendChallenge(self._gateId)
    self:close()
end

function CrusadeFightPreview:_onChallenge(widget)

    local currentId = G_Me.crusadeData:getCurrentId()

    if currentId > 0 and currentId ~= self._gateId then
        local box = require("app.scenes.tower.TowerSystemMessageBox")
        box.showSpecialMessage( G_lang:get("LANG_CRUSADE_FIGHT_CHANGE"), handler(self,self._doChallenge))
    else
        self:_doChallenge()
    end
    
end


-- 布阵
function CrusadeFightPreview:_onBuZhen(widget)
    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
    require("app.scenes.hero.HerobuZhengLayer").showBuZhengLayer()
end


return CrusadeFightPreview

