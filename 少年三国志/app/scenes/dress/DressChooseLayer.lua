
local DressChooseLayer = class("DressChooseLayer",UFCCSNormalLayer)
require("app.cfg.dress_info")
require("app.cfg.dress_compose_info")
require("app.cfg.dress_change_text")
require("app.cfg.skill_info")
require("app.cfg.knight_info")
local MergeEquipment = require("app.data.MergeEquipment")
local KnightPic = require("app.scenes.common.KnightPic")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local JumpBackCard = require("app.scenes.common.JumpBackCard")
local EffectNode = require "app.common.effects.EffectNode"

function DressChooseLayer.create( container)   
    local layer = DressChooseLayer.new("ui_layout/dress_ChooseLayer.json",container) 
    -- layer:setContainer(container)
    return layer
end

function DressChooseLayer:ctor(json,container)
    self.super.ctor(self,json)
    self._container = container
    self._playing = false
    self._dressListInit = false
    self._detailPanel = self:getPanelByName("Panel_detail")
    self._detailPanel:setVisible(false)
    self._heroPanel = self:getPanelByName("Panel_hero")
    -- self:_initScrollView()
    
    self._equipment = G_Me.dressData:getDressed() 
    self._showedSkill = 0
    self._talkImg = self:getImageViewByName("Image_talk")
    self._talkLabel = self:getLabelByName("Label_talk")
    self._talkImg:setVisible(false)
    -- self._talkLabel:createStroke(Colors.strokeBrown, 1)
    -- self._noEquipLabel = self:getLabelByName("Label_equipno")
    -- self._noEquipLabel:createStroke(Colors.strokeBrown, 1)
    -- self._noEquipLabel:setText(G_lang:get("LANG_DRESS_NODRESS"))

    local noDressAttr = self:getLabelByName("Label_noDressAttr")
    noDressAttr:setVisible(false)
    self:getLabelByName("Label_skillno"):setVisible(false)

    self:registerWidgetClickEvent("Panel_change", function()
        if self._equipment then
            G_HandlersManager.dressHandler:sendAddFightDress(self._equipment.id)
        else
            G_HandlersManager.dressHandler:sendClearFightDress()
        end
    end)
    self:registerBtnClickEvent("Button_skill1", function()
         self:updateSkillDetail(1)
    end)
    self:registerBtnClickEvent("Button_skill2", function()
         self:updateSkillDetail(2)
    end)
    self:registerBtnClickEvent("Button_skill3", function()
         self:updateSkillDetail(3)
    end)
    self:registerBtnClickEvent("Button_skill4", function()
         self:updateSkillDetail(4)
    end)
    -- self:registerBtnClickEvent("Button_go", function()
    --      require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_SHI_ZHUANG, dress_info.indexOf(1).id,
    --       GlobalFunc.sceneToPack("app.scenes.dress.DressMainScene"))
    -- end)
    self:registerWidgetClickEvent("Panel_Click", function()
         self:updateSkillDetail(0)
    end)
    self:registerWidgetClickEvent("Panel_heroClick", function()
        local dress = self._equipment
        if dress then
            require("app.scenes.dress.DressInfo").showEquipmentInfo(dress,self._container )
        end
    end)
    
    -- self:registerTouchEvent(false,true,0)
    -- self:getPanelByName("Panel_strength"):setVisible(false)
    self._saveEffect = EffectNode.new("effect_jiantou", function(event, frameIndex)
                end)  
    self._saveEffect:setPosition(ccp(40,40))
    self:getPanelByName("Panel_breathe"):addNode(self._saveEffect)
    self._saveEffect:play()

end

function DressChooseLayer:onLayerEnter( )
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ADD_DRESS, self._onChangeRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CLEAR_DRESS, self._onChangeRsp, self)
    self._playing = false
    self._container:_setListClick(true)
    self._dressListInit = false
    -- self._equipment = self._container:getChoosed()
    -- self:updataData()
    -- self:changeAnime()
    -- self:_heroComeAnime()
end

function DressChooseLayer:reset( )
    self._equipment = self._container:getChoosed()
    self:updataData()

    local skillPanel = self:getWidgetByName("Panel_skill")
    local posx,posy = skillPanel:getPosition()
    skillPanel:setPosition(ccp(posx+300,posy))

    local strPanel = self:getWidgetByName("Panel_attr")
    local posx,posy = strPanel:getPosition()
    strPanel:setPosition(ccp(posx,posy-200))
    strPanel:setOpacity(0)
    self:_heroComeAnime()
end

function DressChooseLayer:enterAnime( )
    -- GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_dressList")}, false, 0.2, 2, 100)
    GlobalFunc.flyIntoScreenTB({self:getWidgetByName("Panel_attr")}, false, 0.2, 2, 100)
    -- self:_heroComeAnime()


end

function DressChooseLayer:updataData( )
    if self._equipment then
        self._equipmentInfo = G_Me.dressData:getDressInfo(self._equipment.base_id) 
    else
        self._equipmentInfo = nil
    end
    self:baseInit()
    self:initAttrPanel()
    self:initSkillPanel()
    -- self:updateScrollView()
    self:updateHero()
    self:updateSkillDetail(0)
    -- self:updateScrollView()
end

function DressChooseLayer:_onChangeRsp(data)
    if data.ret == 1 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_DRESS_CHANGESUCCESS"))
        -- self:updateScrollView()
        -- self._container:_updateList()
        self:baseInit()
    end
end

function DressChooseLayer:onLayerExit()
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end


function DressChooseLayer:adapterLayer()
    self:adapterWidgetHeight("Panel_Click", "", "", 0, 0)
    self:adapterWidgetHeight("Panel_middle", "", "", 0, 160)

    self:enterAnime()
end

function DressChooseLayer:updateHero()
    local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
    local info = knight_info.get(baseId)
    local resid = info.res_id
    if self._equipment then
        resid = G_Me.dressData:getDressedResidWithDress(baseId,self._equipment.base_id)
    end
    if self._knight then
        self._knight:removeFromParentAndCleanup(true)
    end
    self._knight =KnightPic.createKnightPic( resid, self._heroPanel, "knightImg",true )
    -- self._knight:setScale(0.8)
    self._heroPanel:setScale(0.8)
    self:breathe(true)
end

function DressChooseLayer:baseInit()
    if self._equipmentInfo == nil then
        self:getImageViewByName("Image_dressName"):setVisible(false)
    else
        self:getImageViewByName("Image_dressName"):setVisible(true)
        local name = self:getLabelByName("Label_dressName")
        name:setText(self._equipmentInfo.name)
        name:setColor(Colors.qualityColors[self._equipmentInfo.quality])
        name:createStroke(Colors.strokeBrown, 1)
    end
    local changePanel = self:getPanelByName("Panel_change")
    if (self._equipment == nil and G_Me.dressData:getDressed() == nil) or 
        (self._equipment and G_Me.dressData:getDressed() and self._equipment.id == G_Me.dressData:getDressed().id) then
        changePanel:setVisible(false)
    else
        changePanel:setVisible(true)
    end
end

function DressChooseLayer:changeAnime()
    -- local panel = self:getPanelByName("Panel_breathe")
    -- self._breathEffect = EffectSingleMoving.run(self:getPanelByName("Panel_breathe"), "smoving_idle", nil, {})
    -- local guangImg = self:getImageViewByName("Image_guang")
    -- guangImg:stopAllActions()
    -- local fadeInAction = CCFadeIn:create(0.5)
    -- local fadeOutAction = CCFadeOut:create(0.5)
    -- local seqAction = CCSequence:createWithTwoActions(fadeInAction, fadeOutAction)
    -- seqAction = CCRepeatForever:create(seqAction)
    -- guangImg:runAction(seqAction)
end

function DressChooseLayer:initAttrPanel()
    
    if self._equipmentInfo == nil then
        self:getPanelByName("Panel_basic"):setVisible(false)
        self:getPanelByName("Panel_strength"):setVisible(false)
        self:getPanelByName("Panel_attr"):setVisible(false) 
        -- noDressAttr:setVisible(true)
        -- noDressAttr:createStroke(Colors.strokeBrown, 1)
        return
    end
    -- noDressAttr:setVisible(false)
    self:getPanelByName("Panel_attr"):setVisible(true) 
    self:getPanelByName("Panel_basic"):setVisible(true)
    self:getPanelByName("Panel_strength"):setVisible(true)
    -- self:getPanelByName("Panel_strength"):setVisible(false)
    
    if not G_Me.dressData:getDressCanStrength() then
        self:getPanelByName("Panel_strength"):setVisible(false)
    end

    self:getLabelByName("Label_basicTitle"):createStroke(Colors.strokeBrown, 1)
    local attr1 = self:getLabelByName("Label_basicattr1")
    local value1 = self:getLabelByName("Label_basicvalue1")
    local attr2 = self:getLabelByName("Label_basicattr2")
    local value2 = self:getLabelByName("Label_basicvalue2")
    attr1:createStroke(Colors.strokeBrown, 1)
    value1:createStroke(Colors.strokeBrown, 1)
    attr2:createStroke(Colors.strokeBrown, 1)
    value2:createStroke(Colors.strokeBrown, 1)

    local attrtype1,attrvalue1,strtype1,strvalue1 = MergeEquipment.convertAttrTypeAndValue(self._equipmentInfo.basic_type_1, self._equipmentInfo.basic_value_1)
    local attrtype2,attrvalue2,strtype2,strvalue2 = MergeEquipment.convertAttrTypeAndValue(self._equipmentInfo.basic_type_2, self._equipmentInfo.basic_value_2)
    attr1:setText(strtype1)
    value1:setText(strvalue1)
    attr2:setText(strtype2)
    value2:setText(strvalue2)

    self:getLabelByName("Label_strengthTitle"):createStroke(Colors.strokeBrown, 1)
    local attr1 = self:getLabelByName("Label_strengthattr1")
    local value1 = self:getLabelByName("Label_strengthvalue1")
    local attr2 = self:getLabelByName("Label_strengthattr2")
    local value2 = self:getLabelByName("Label_strengthvalue2")
    local attr3 = self:getLabelByName("Label_strengthattr3")
    local value3 = self:getLabelByName("Label_strengthvalue3")
    local attr4 = self:getLabelByName("Label_strengthattr4")
    local value4 = self:getLabelByName("Label_strengthvalue4")
    attr1:createStroke(Colors.strokeBrown, 1)
    value1:createStroke(Colors.strokeBrown, 1)
    attr2:createStroke(Colors.strokeBrown, 1)
    value2:createStroke(Colors.strokeBrown, 1)
    attr3:createStroke(Colors.strokeBrown, 1)
    value3:createStroke(Colors.strokeBrown, 1)
    attr4:createStroke(Colors.strokeBrown, 1)
    value4:createStroke(Colors.strokeBrown, 1)

    local attrtype1,attrvalue1,strtype1,strvalue1 = MergeEquipment.convertAttrTypeAndValue(self._equipmentInfo.strength_type_1, self._equipmentInfo.strength_value_1*(self._equipment.level-1))
    local attrtype2,attrvalue2,strtype2,strvalue2 = MergeEquipment.convertAttrTypeAndValue(self._equipmentInfo.strength_type_2, self._equipmentInfo.strength_value_2*(self._equipment.level-1))
    local attrtype3,attrvalue3,strtype3,strvalue3 = MergeEquipment.convertAttrTypeAndValue(self._equipmentInfo.strength_type_3, self._equipmentInfo.strength_value_3*(self._equipment.level-1))
    local attrtype4,attrvalue4,strtype4,strvalue4 = MergeEquipment.convertAttrTypeAndValue(self._equipmentInfo.strength_type_4, self._equipmentInfo.strength_value_4*(self._equipment.level-1))
    attr1:setText(strtype1)
    value1:setText(strvalue1)
    attr2:setText(strtype2)
    value2:setText(strvalue2)
    attr3:setText(strtype3)
    value3:setText(strvalue3)
    attr4:setText(strtype4)
    value4:setText(strvalue4)

end

function DressChooseLayer:initSkillPanel()
    if self._equipmentInfo == nil then
        -- self:getButtonByName("Button_skill1"):setVisible(false)
        -- self:getButtonByName("Button_skill2"):setVisible(false)
        -- self:getButtonByName("Button_skill3"):setVisible(false)
        -- self:getLabelByName("Label_skillno"):setVisible(true)
        self:getButtonByName("Button_skill1"):setVisible(true)
        self:getButtonByName("Button_skill2"):setVisible(true)
        self:getButtonByName("Button_skill3"):setVisible(false)
        self:getButtonByName("Button_skill4"):setVisible(false)
        if G_Me.dressData:getCurSex() == 1 then
            self:getImageViewByName("Image_skill1"):loadTexture("icon/dress_skill/1001.png")
            self:getImageViewByName("Image_skill2"):loadTexture("icon/dress_skill/1002.png")
        else
            self:getImageViewByName("Image_skill1"):loadTexture("icon/dress_skill/1003.png")
            self:getImageViewByName("Image_skill2"):loadTexture("icon/dress_skill/1004.png")
        end
        return
    end
    local grayColor = ccc3(0xae, 0xae, 0xae) 
    -- self:getLabelByName("Label_skillno"):setVisible(false)
    if self._equipmentInfo.common_skill_id > 0 then
        self:getButtonByName("Button_skill1"):setVisible(true)
        self:getImageViewByName("Image_skill1"):loadTexture("icon/dress_skill/"..self._equipmentInfo.skill_res_id_1..".png")
        if self._equipmentInfo.common_clear_level > self._equipment.level then
            -- self:getImageViewByName("Image_skill1"):setColor(grayColor)
            self:getImageViewByName("Image_skill1"):showAsGray(true)
        else
            -- self:getImageViewByName("Image_skill1"):setColor(Colors.Noraml)
            self:getImageViewByName("Image_skill1"):showAsGray(false)
        end
    else
        self:getButtonByName("Button_skill1"):setVisible(false)
    end
    if self._equipmentInfo.active_skill_id_1 > 0 then
        self:getButtonByName("Button_skill2"):setVisible(true)
        local path = "icon/dress_skill/"..self._equipmentInfo.skill_res_id_2..".png"
        self:getImageViewByName("Image_skill2"):loadTexture(path)
        if self._equipmentInfo.active_clear_level_1 > self._equipment.level then
            -- self:getImageViewByName("Image_skill2"):setColor(grayColor)
            self:getImageViewByName("Image_skill2"):showAsGray(true)
        else
            -- self:getImageViewByName("Image_skill2"):setColor(Colors.Noraml)
            self:getImageViewByName("Image_skill2"):showAsGray(false)
        end
    else
        self:getButtonByName("Button_skill2"):setVisible(false)
    end
    if self._equipmentInfo.unite_skill_id > 0 then
        self:getButtonByName("Button_skill3"):setVisible(true)
        self:getImageViewByName("Image_skill3"):loadTexture("icon/dress_skill/"..self._equipmentInfo.skill_res_id_4..".png")
        if self._equipmentInfo.unite_clear_level > self._equipment.level then
            -- self:getImageViewByName("Image_skill3"):setColor(grayColor)
            if G_Me.dressData:getDressCanStrength() then
                self:getImageViewByName("Image_skill3"):showAsGray(true)
            else
                self:getButtonByName("Button_skill3"):setVisible(false)
            end
        else
            -- self:getImageViewByName("Image_skill3"):setColor(Colors.Noraml)
            if G_Me.dressData:getDressCanStrength() then
                self:getImageViewByName("Image_skill3"):showAsGray(false)
            else
                self:getButtonByName("Button_skill3"):setVisible(true)
            end
        end
    else
        self:getButtonByName("Button_skill3"):setVisible(false)
    end
    if self._equipmentInfo.super_unite_skill_id > 0 then
        self:getButtonByName("Button_skill4"):setVisible(true)
        self:getImageViewByName("Image_skill4"):loadTexture("icon/dress_skill/"..self._equipmentInfo.skill_res_id_4..".png")
        if self._equipmentInfo.super_unite_clear_level > self._equipment.level then
            if G_Me.dressData:getDressCanStrength() then
                self:getImageViewByName("Image_skill4"):showAsGray(true)
            else
                self:getButtonByName("Button_skill4"):setVisible(false)
            end
        else
            if G_Me.dressData:getDressCanStrength() then
                self:getImageViewByName("Image_skill4"):showAsGray(false)
            else
                self:getButtonByName("Button_skill4"):setVisible(true)
            end
        end
    else
        self:getButtonByName("Button_skill4"):setVisible(false)
    end
end

function DressChooseLayer:updateSkillDetail(index)
    if self._playing then
        return
    end
    if index == 0 or self._showedSkill == index then
        -- self:getPanelByName("Panel_detail"):setVisible(false)
        self:skillShowAnime(self._showedSkill,false)
        self._showedSkill = 0
        return
    end

    self._showedSkill = index
    self:getPanelByName("Panel_detail"):setVisible(true)
    self:skillShowAnime(self._showedSkill,true)
    for i = 1,4 do 
        self:getImageViewByName("Image_arrow"..i):setVisible(i == index)
    end
    local iconList = {"icon_skill_pu","icon_skill_ji","icon_skill_he","icon_skill_chao",}
    local idList = {}
    local levelList = {}
    if self._equipmentInfo == nil then
        local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
        local info = knight_info.get(baseId)
        idList = {info.common_id,info.active_skill_id,info.unite_skill_id,info.super_unite_skill_id,}
        levelList = {0,0,0,0}
    else
        idList = {self._equipmentInfo.common_skill_id,self._equipmentInfo.active_skill_id_1,
            self._equipmentInfo.unite_skill_id,self._equipmentInfo.super_unite_skill_id,}
        levelList = {self._equipmentInfo.common_clear_level,self._equipmentInfo.active_clear_level_1,
            self._equipmentInfo.unite_clear_level,self._equipmentInfo.super_unite_clear_level,}
    end
    self:getImageViewByName("Image_skillTypeIcon"):loadTexture("ui/text/txt/"..iconList[index]..".png")
    local skillInfo = skill_info.get(idList[index])

    local mainKnightInfo = G_Me.bagData.knightsData:getMainKightInfo()
    local guanhuanLevel = mainKnightInfo.halo_level
    guanhuanLevel = index == 1 and 1 or guanhuanLevel
    self:getLabelByName("Label_skillTitle"):setText(skillInfo.name.." Lv."..guanhuanLevel)
    local desc = index == 4 and self._equipmentInfo.sp_unite_des or skillInfo.directions
    self:getLabelByName("Label_skillDesc"):setText(G_GlobalFunc.formatText(desc, 
                {num1 = skillInfo.formula_value1_1 + math.floor(skillInfo.formula_value1_add_1 / 10 *(guanhuanLevel - 1)),
                 num2 = skillInfo.formula_value1_2 + skillInfo.formula_value1_add_2*(guanhuanLevel - 1),
                 damage_type = G_Me.dressData:getAttackTypeTxt(),
                 test = (guanhuanLevel == 1) and "" or G_lang:get("LANG_KNIGHT_GUANHUAN_ADDITION", {num3=math.floor(skillInfo.formula_value1_add_1 / 10 *(guanhuanLevel - 1))})}))
    local str = G_lang:get("LANG_DRESS_LEVELLIMIT",{level=levelList[index]})
    local skillLevelLabel = self:getLabelByName("Label_skillLevel")
    if self._equipment and levelList[index] > self._equipment.level then
        skillLevelLabel:setText(str)
        skillLevelLabel:setVisible(true)
    else
        skillLevelLabel:setVisible(false)
    end
end

function DressChooseLayer:skillShowAnime(index,show)
    if index == 0 then
        return
    end
    self._playing = true
    self._container:_setListClick(false)
    local panel = self:getPanelByName("Panel_detailMove")
    local size = panel:getSize()
    local toArrow = self:getImageViewByName("Image_arrow"..index)
    local pos = ccp(toArrow:getPositionX()+toArrow:getSize().width/2,toArrow:getPositionY())
    local animeTime = 0.2
    if show then
        panel:setScale(0.01)
        panel:setPosition(pos)
        local anime1 = CCMoveTo:create(animeTime,ccp(0,0))
        local anime2 = CCScaleTo:create(animeTime,1)
        local anime = CCSpawn:createWithTwoActions(anime1, anime2)
        panel:runAction(CCSequence:createWithTwoActions(anime, CCCallFunc:create(function()
                    self._playing = false
                    self._container:_setListClick(true)
            end)))
    else
        panel:setScale(1)
        panel:setPosition(ccp(0,0))
        local anime1 = CCMoveTo:create(animeTime,pos)
        local anime2 = CCScaleTo:create(animeTime,0.01)
        local anime = CCSpawn:createWithTwoActions(anime1, anime2)
        panel:runAction(CCSequence:createWithTwoActions(anime, CCCallFunc:create(function()
                    self._playing = false
                    self._container:_setListClick(true)
            end)))
    end
end

function DressChooseLayer:_heroChangeAnime()
    self:updateSkillDetail(0)
    self._playing = true
    self._container:_setListClick(false)
    local baseScale = self._knight:getParent():getScale()
    local oldPosx, oldPosy = self._knight:getParent():getPosition()
    self:breathe(false)
    require("app.common.effects.EffectSingleMoving").run(self._knight:getParent(), "smoving_out", function(event)
        if event == "finish" then
            self._knight:setVisible(false)
            self._knight:getParent():setScale(baseScale)
            self._knight:getParent():setPosition(ccp(oldPosx,oldPosy))
            local EffectNode = require "app.common.effects.EffectNode"
            local node = EffectNode.new("effect_yan", function()
                -- if self._callback then
                --     self._callback()
                -- end
                self._knight:setVisible(true)
                self:updataData()
                self:_heroComeAnime(function()
                        self:_heroTalk(self._equipment and self._equipment.base_id or 1,false)
                    end)
            end)
            self._knight:getParent():addNode(node)
            node:setPositionXY(50, 200)
            node:setScale(1.5)
            node:play()
            self:getWidgetByName("Panel_skill"):runAction(CCMoveBy:create(0.2,ccp(300,0)))
            self:getWidgetByName("Panel_attr"):runAction(CCSpawn:createWithTwoActions(CCMoveBy:create(0.2,ccp(0,-200)),CCFadeOut:create(0.2)))
        end
    end)

end

function DressChooseLayer:_heroTalk(id,go,callback)
    self:updateSkillDetail(0)
    self._playing = true
    self._container:_setListClick(false)
    local talkTime = 1.5
    local animeDelay = CCDelayTime:create(1.0)
    local str1 = G_Me.dressData:getCurSex()==1 and "male" or "female"
    local str2 = go and "before" or "after"
    local str = dress_change_text.get(id)[str1.."_"..str2]
    self._talkLabel:setText(str)
    self._talkImg:setVisible(true)
    self._talkImg:setScale(0.1)
    local animeScale = CCEaseBounceOut:create(CCScaleTo:create(0.5,1))
    local arr = CCArray:create()
    arr:addObject(animeScale)
    arr:addObject(animeDelay)
    arr:addObject(CCCallFunc:create(function()
                self._talkImg:setVisible(false)
                if callback then
                    callback()
                else
                    self._playing = false
                    self._container:_setListClick(true)
                end
        end))
    local anime = CCSequence:create(arr)
    self._talkImg:runAction(anime)
end

function DressChooseLayer:_heroComeAnime(callback)
    self._playing = true
    self._container:_setListClick(false)
    local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
    local info = knight_info.get(baseId)
    local resid = info.res_id
    if self._equipment then
        resid = G_Me.dressData:getDressedResidWithDress(baseId,self._equipment.base_id)
    end
    local knight = self._heroPanel
    local worldPos = knight:convertToWorldSpace(ccp(0,0))
    local jumpKnight = JumpBackCard.create()
    local start = knight:convertToWorldSpace(ccp(-400,0))
    knight:getParent():addNode(jumpKnight)
    self._knight:setVisible(false)
     jumpKnight:play(resid, start, 0.5, worldPos, 0.8, function() 
        jumpKnight:removeFromParentAndCleanup(true)
        self._playing = false
        self._container:_setListClick(true)
        self._knight:setVisible(true)
        if callback then
            callback()
        end
    end )
    self:getWidgetByName("Panel_skill"):runAction(CCMoveBy:create(0.2,ccp(-300,0)))
    self:getWidgetByName("Panel_attr"):runAction(CCSpawn:createWithTwoActions(CCMoveBy:create(0.2,ccp(0,200)),CCFadeIn:create(0.2)))
end

function DressChooseLayer:breathe(status)
    if status then
        if self._bossEffect == nil then
                    local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
                    self._bossEffect = EffectSingleMoving.run(self._heroPanel, "smoving_idle", nil, {})
        end
    else
        if self._bossEffect ~= nil then
                    self._bossEffect:stop()
                    self._bossEffect = nil
        end
    end
end

function DressChooseLayer:choosedDress(id)
    -- print("DressChooseLayer:choosedDress "..id)
    self._equipment = G_Me.dressData:getDressByBaseId(id)
    self:_heroChangeAnime()
    -- self:updataData()
end

return DressChooseLayer

