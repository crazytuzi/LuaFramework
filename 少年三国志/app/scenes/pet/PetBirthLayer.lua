local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local EffectNode = require "app.common.effects.EffectNode"

local PetBirthLayer = class("PetBirthLayer", UFCCSModelLayer)

local OFF_SET = 150

function PetBirthLayer.create(nFragmentId, nComposeNum, ...)
	local tLayer = PetBirthLayer.new("ui_layout/PetBag_BirthLayer.json", Colors.modelColor, nFragmentId, nComposeNum, ...)
	uf_sceneManager:getCurScene():addChild(tLayer)
	return tLayer
end

function PetBirthLayer:ctor(json, param, nFragmentId, nComposeNum, ...)
	self.super.ctor(self, json, param, ...)
    self:adapterWithScreen()

    local tFragmentTmpl = fragment_info.get(nFragmentId)
    assert(tFragmentTmpl)
    self._nBaseId = tFragmentTmpl.fragment_value
    self._tPetTmpl = pet_info.get(self._nBaseId)

    self._nComposeNum = nComposeNum or 1

    self._nPosX = 0
    self._nPosY = 0

    self:_initWidgets()
end

function PetBirthLayer:onLayerEnter( ... )
	self:closeAtReturn(true)
	self:setClickClose(true)
end

function PetBirthLayer:onLayerExit( ... )
	-- body
end

function PetBirthLayer:_initWidgets( ... )
	local nQuality = self._tPetTmpl.quality
    CommonFunc._updateLabel(self, "Label_PetName", {text=self._tPetTmpl.name, color=Colors.qualityColors[nQuality], stroke=Colors.strokeBrown, visible=false})
    CommonFunc._updateLabel(self, "Label_GongXi", {text=G_lang:get("LANG_PET_GET_PET_CONGRATULATION"), stroke=Colors.strokeBrown, visible=false})
    CommonFunc._updateLabel(self, "Label_ComposeNum", {text="  x"..self._nComposeNum, stroke=Colors.strokeBrown, visible=false})

    if self._nComposeNum > 1 then
        local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
                self:getLabelByName('Label_GongXi'),
                self:getLabelByName('Label_PetName'),
                self:getLabelByName('Label_ComposeNum'),
            }, "C")
        self:getLabelByName('Label_GongXi'):setPositionXY(alignFunc(1))
        self:getLabelByName('Label_PetName'):setPositionXY(alignFunc(2))
        self:getLabelByName('Label_ComposeNum'):setPositionXY(alignFunc(3))
    else
        local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
                self:getLabelByName('Label_GongXi'),
                self:getLabelByName('Label_PetName'),
            }, "C")
        self:getLabelByName('Label_GongXi'):setPositionXY(alignFunc(1))
        self:getLabelByName('Label_PetName'):setPositionXY(alignFunc(2))
    end

    self:showWidgetByName("Image_ClickContinue", false)
    self._nPosX = self:getPanelByName("Panel_GongXi"):getPositionX()
    self._nPosY = self:getPanelByName("Panel_GongXi"):getPositionY()
    self._nPosY = self._nPosY - OFF_SET
    self:getPanelByName("Panel_GongXi"):setPositionY(self._nPosY)

    -- 分享
    self:showWidgetByName("Button_Share",G_ShareService:canShareImage())
    self:registerBtnClickEvent("Button_Share",function()
        --点这里分享
        local SharingLayer = require("app.scenes.mainscene.SharingLayer")
        local detailLayer = SharingLayer.create(SharingLayer.LAYOUT_SETTING_STYLE, Colors.modelColor, {
            {"Label_share_content", {text=G_lang:get("LANG_PET_SHARE_CONTENT_DESC")}}
        })
        uf_sceneManager:getCurScene():addChild(detailLayer)

        detailLayer:registerBtnClickEvent("Button_to_weibo", function()
            detailLayer:close()
            uf_funcCallHelper:callAfterFrameCount(2, function()
                G_ShareService:weiboShareScreen()
            end)
        end)

        detailLayer:registerBtnClickEvent("Button_to_wechat", function()
            detailLayer:close()
            uf_funcCallHelper:callAfterFrameCount(2, function()
                G_ShareService:weixinShareScreen()
            end)
        end)

    end)

    self:_addSceneEffect()

    self:_showPet()
end

function PetBirthLayer:_addSceneEffect()
    if not self._sceneEffect then
        self._sceneEffect = EffectNode.new("effect_shoulan_bg")  -- 
        local tParent = self:getImageViewByName("Image_Bg")
        if tParent then
            tParent:addNode(self._sceneEffect)
            self._sceneEffect:setScale(0.5)
            self._sceneEffect:play()
        end
    end
end

function PetBirthLayer:_showPet()
    if not self._tPetTmpl then
        return
    end

    -- 先播放一个特效，然后再生成战宠
    if not self._birthEffect then
        self._birthEffect = EffectNode.new("effect_card_show", function(event, frameIndex)
            if event == "finish" then
                -- 现发一团白光
                if not self._lightEffect then
                    self._lightEffect = EffectNode.new("effect_circle_light", function(event, frameIndex)
                        if event == "finish" then
                            -- 背景光
                            if not self._bgEffect then
                                self._bgEffect = EffectNode.new("effect_zjbj")  -- effect_zjbj
                                local tParent = self:getPanelByName("Panel_Pet")
                                if tParent then
                                    tParent:addNode(self._bgEffect)
                                    self._bgEffect:play()
                                    self._bgEffect:setPositionY(self._bgEffect:getPositionY() + 180)
                                    self._bgEffect:setScale(0.5)
                                end
                            end

                            --战宠形象
                            local eff = G_Path.getPetReadyEffect(self._tPetTmpl.ready_id)
                            if not self._tEffectPic then
                                self._tEffectPic = EffectNode.new(eff)
                                assert(self._tEffectPic)
                                local tParent = self:getPanelByName("Panel_Pet")
                                if tParent then
                                    tParent:addNode(self._tEffectPic)
                                    self._tEffectPic:play()

                                    self._tEffectPic:setOpacity(0)
                                    self._tEffectPic:setCascadeOpacityEnabled(true)
                                    self._tEffectPic:runAction(CCFadeIn:create(2))
                                end
                            end 

                            self:_fly()

                            self._lightEffect:removeFromParentAndCleanup(true)
                            self._lightEffect = nil
                        end
                    end)
                    local tParent = self:getPanelByName("Panel_Pet")
                    if tParent then
                        tParent:addNode(self._lightEffect)
                        self._lightEffect:play()
                        self._lightEffect:setPositionY(self._lightEffect:getPositionY() + 180)
                    end

                end

                self._birthEffect:removeFromParentAndCleanup(true)
                self._birthEffect = nil
            end
        end) 
        local tParent = self:getPanelByName("Panel_Pet")
        if tParent then
            tParent:addNode(self._birthEffect)
            self._birthEffect:setScale(2)
            self._birthEffect:play()
            self._birthEffect:setPositionY(self._birthEffect:getPositionY() + 250)
        end
    end  
end

function PetBirthLayer:_fly()
    CommonFunc._updateLabel(self, "Label_PetName", {visible=true})
    CommonFunc._updateLabel(self, "Label_GongXi", {visible=true})
    if self._nComposeNum > 1 then
        CommonFunc._updateLabel(self, "Label_ComposeNum", {visible=true})
    end

    self:showWidgetByName("Image_ClickContinue", true)
    local actMoveTo = CCMoveTo:create(0.13, ccp(self._nPosX, self._nPosY + OFF_SET))
    local function blink()
        local actSeq = CCSequence:createWithTwoActions(CCFadeIn:create(0.5), CCFadeOut:create(0.5))
        local actFor = CCRepeatForever:create(actSeq)
        self:getImageViewByName("Image_ClickContinue"):runAction(actFor)
    end

    self:getPanelByName("Panel_GongXi"):runAction(CCSequence:createWithTwoActions(actMoveTo, CCCallFunc:create(blink)))
end

return PetBirthLayer