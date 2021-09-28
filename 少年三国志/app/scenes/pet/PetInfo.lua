
local PetInfo = class("PetInfo", UFCCSModelLayer)

local MergeEquipment = require("app.data.MergeEquipment")
local Colors = require("app.setting.Colors")
local EffectNode = require "app.common.effects.EffectNode"
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local PetBagConst = require("app.const.PetBagConst")
local FunctionLevelConst = require "app.const.FunctionLevelConst"
local KnightPic = require("app.scenes.common.KnightPic")

local STAR_MAX = 5

local HERO_DESC_LAYER_TAG = 10200

--style 取值
-- 1 显示强化 ,精炼
-- 2 显示强化,精炼, 卸下, 更换 , 此时slotInfo必须有值为: {teamId=, slot=, pos=}
-- 3 去掉bottom面板
function PetInfo.showEquipmentInfo( equipment, style, slotInfo, flag)
    local equipDesc = require("app.scenes.pet.PetInfo").new("ui_layout/PetBag_PetInfo.json", Colors.modelColor)
    uf_sceneManager:getCurScene():addChild(equipDesc)
    equipDesc:initEquipmentWithEquip(equipment, style, slotInfo)

    return equipDesc
end


function PetInfo:ctor( ... )
	self._tPet = nil
    self._slotInfo = nil 
    self._canClick = true
	self.super.ctor(self, ...)

	self:adapterWithScreen()

	self:registerBtnClickEvent("Button_back", function ( widget )
		self:_closeWindow()
	end)
    -- 卸下宠物
	self:registerBtnClickEvent("Button_xiexia", function ( widget )
    --    G_HandlersManager.fightResourcesHandler:sendClearFightEquipment( self._slotInfo.teamId , self._slotInfo.pos, self._slotInfo.slot)
                        G_HandlersManager.petHandler:sendChangeFightPet(0)
		self:_closeWindow()
	end)
    -- 强化
	self:registerBtnClickEvent("Button_strength", function ( widget )
                        if self:checkClick() then
                            self:_onStrengthClick()
                        end
	end)
    -- 升星
	self:registerBtnClickEvent("Button_jinglian", function ( widget )
                        if self:checkClick() then
                            self:_onUpStarClick()
                        end
	end)
    -- 神炼
    self:registerBtnClickEvent("Button_Spirit", function ( widget )
        if self:checkClick() then
                self:_onRefineClick()
            end
    end)

    -- 去获取碎片
    self:registerBtnClickEvent("Button_GetFrament", function ( widget )
        if not self._tPet then
            return
        end
        local tPetTmpl = pet_info.get(self._tPet["base_id"])
        assert(tPetTmpl)
        local nFragmentId = tPetTmpl.relife_id

        require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_FRAGMENT, nFragmentId, GlobalFunc.sceneToPack("app.scenes.pet.bag.PetBagMainScene", {2, nFragmentId}))
    end)
    -- 查看所有技能
    self:registerWidgetTouchEvent("Label_CheckSkill", function ( widget, eventType)
        if eventType == TOUCH_EVENT_ENDED then
            if not self._tPetTmpl then
                return
            end
            local tTmplList = {}
            for i=1, pet_info.getLength() do
                local tPetTmpl = pet_info.indexOf(i)
                if tPetTmpl and tPetTmpl.advanced_id == self._tPetTmpl.advanced_id then
                    table.insert(tTmplList, #tTmplList + 1, tPetTmpl)
                end
            end

            local tContentList = {}
            for i=1, #tTmplList do
                local tPetTmpl = tTmplList[i]
                local tSkillTmpl = skill_info.get(tPetTmpl.active_skill_id)

                local tContent = {}
                tContent["color"] = Colors.lightColors.DESCRIPTION
                tContent["content"] = tSkillTmpl.directions
                table.insert(tContentList, #tContentList + 1, tContent)
            end
            
            require("app.scenes.common.CommonAttrLayer").show(tContentList, nil, "ui/text/txt/zhanchongjineng.png")
        end
    end)

    -- 宠物神炼预览
    self:registerBtnClickEvent("Label_Spirir_Check", function( ... )
    --    __Log(" -- 宠物神炼预览")
        require("app.scenes.pet.develop.PetRefineTarget").show(self._tPet)
    end)

    -- 向左的箭头
    self:registerBtnClickEvent("Button_Left", function()
        local nCurIndex = self._petPageView:getCurPageIndex()
        local nPreIndex = nCurIndex - 1
        if nPreIndex < 0 then
           nPreIndex = 0
        end
        self._petPageView:scrollToPage(nPreIndex)
    end)
    -- 向右的箭头
    self:registerBtnClickEvent("Button_Right", function()
        local nCurIndex = self._petPageView:getCurPageIndex()
        local nNextIndex = nCurIndex + 1
        local nPageCount = self._petPageView:getPageCount()
        if nNextIndex >= nPageCount then
           nNextIndex = nPageCount - 1
        end
        self._petPageView:scrollToPage(nNextIndex)
    end)

    -- self._type == 1的情况下，宠物也要能上阵
    self:registerBtnClickEvent("Button_ShangZhen", function()
        G_HandlersManager.petHandler:sendChangeFightPet(self._tPet["id"])
        self:_closeWindow()
    end)

    self:registerBtnClickEvent("Button_XieXia", function()
        G_HandlersManager.petHandler:sendChangeFightPet(0)
        self:_closeWindow()
    end)

    self:attachImageTextForBtn("Button_strength", "Image_strtxt")
    self:attachImageTextForBtn("Button_jinglian", "Image_reftxt")
    self:attachImageTextForBtn("Button_Spirit", "Image_12")
    self:attachImageTextForBtn("Button_ShangZhen", "ImageView_ShangZhen")
end

function PetInfo:checkClick()
    if not self._canClick then
        if self._clickFunc then
            self._clickFunc()
        end
    end
    return self._canClick
end

function PetInfo:disableClick()
    self._canClick = false
    self._clickFunc = function (  )
        G_MovingTip:showMovingTip(G_lang:get("LANG_PET_LEAVE_FIRST"))
    end
end

function PetInfo:onLayerEnter( )
    self:registerKeypadEvent(true, false)
    if G_SceneObserver:getSceneName() == "DailyPvpTeamScene" then
        self:disableClick()
    end
end

function PetInfo:onBackKeyEvent( ... )
    self:_closeWindow()
    return true
end

function PetInfo:initEquipmentWithEquip( equipment, style, slotInfo )
	self._tPet = equipment
    self._tPetTmpl = pet_info.get(self._tPet["base_id"])
    self._style = style

    if not self._tPet then
        return
    end

    if style == 1 then
        self:adapterWidgetHeight("Panel_desc1", "Panel_topbar1", "Panel_btns2", 0, -25)
        self:adapterWidgetHeight("ScrollView_scroll", "Panel_topbar2", "", 85, 30)
        self:getPanelByName("Panel_btns1"):setVisible(false)
        self:showWidgetByName("Panel_btns2", true)

        self:showWidgetByName("Button_Left", false)
        self:showWidgetByName("Button_Right", false)

        -- 判断是不是上阵的战宠
        local nFightPetId = G_Me.bagData.petData:getFightPetId()
        if nFightPetId == self._tPet["id"] then
            self:showWidgetByName("Button_ShangZhen", false)
            self:showWidgetByName("Button_XieXia", true)
        else
            self:showWidgetByName("Button_ShangZhen", true)
            self:showWidgetByName("Button_XieXia", false)
        end

        if G_Me.formationData:isProtectPetByPetId(self._tPet["id"]) then
            self:getButtonByName("Button_ShangZhen"):setTouchEnabled(false)
        end
    elseif style== 2 then
        self:adapterWidgetHeight("Panel_desc1", "Panel_topbar1", "Panel_btns1", 0, -25)
        self:adapterWidgetHeight("ScrollView_scroll", "Panel_topbar2", "", 85, 30)
        self:getPanelByName("Panel_btns1"):setVisible(true)
        self:showWidgetByName("Panel_btns2", false)

        self:showWidgetByName("Button_Left", true)
        self:showWidgetByName("Button_Right", true)

        self._slotInfo = slotInfo

        if slotInfo.flag then 
            local around = nil
            around = EffectNode.new("effect_around1", 
                function(event)
                    if event == "finish" and around then 
                        around:removeFromParentAndCleanup(true)
                        around = nil
                    end
            end)
            around:setScaleX(3.4)

            local changeBtn = self:getWidgetByName("Button_genghuan")
            if changeBtn then 
                changeBtn:addNode(around)
                around:setPositionXY(5, 0)
                around:play()
            end
        end

        -- 要一个pageView
        local pagePanel = self:getPanelByName("Panel_knight_pic_back")
        assert(pagePanel)

        self._petPageView = CCSNewPageViewEx:createWithLayout(pagePanel)
        self._petPageView:setPageCreateHandler(function ( page, index )
            local cell = CCSPageCellBase:create("ui_layout/knight_info_page.json")
            return cell
        end)

        self._petPageView:setPageUpdateHandler(function ( page, index, cell )
            if index == 0 then
               -- 放第6个武将
               if not self._heroImage then
                    local nHeroCount = G_Me.formationData:getFormationHeroCount() or 1
                    local knightId = G_Me.formationData:getKnightIdByIndex(1, nHeroCount)
                    local tKnight = G_Me.bagData.knightsData:getKnightByKnightId(knightId)
                    local tKnightTmpl = knight_info.get(tKnight["base_id"])
                    self._heroImage = KnightPic.createKnightPic(tKnightTmpl.res_id, cell:getPanelByName("Panel_knight"))
               end
            elseif index == 1 then
                -- 放宠物
                local eff = G_Path.getPetReadyEffect(self._tPetTmpl.ready_id)
                if not self._tEffectPic then
                    self._tEffectPic = EffectNode.new(eff)
                    assert(self._tEffectPic)
                    local tParent = cell:getPanelByName("Panel_knight")
                    if tParent then
                        tParent:setScale(0.8)
                        tParent:addNode(self._tEffectPic)
                        self._tEffectPic:play()
                    end
                end
                
            end
        end)

        self._petPageView:setPageTurnHandler(function ( page, index, cell )
            if index == 0 then
                local tLayer = uf_sceneManager:getCurScene():getChildByTag(HERO_DESC_LAYER_TAG)
                local nHeroCount = G_Me.formationData:getFormationHeroCount() or 1
                if not tLayer then
                    local knightId = G_Me.formationData:getKnightIdByIndex(1, nHeroCount)
                    tLayer = require("app.scenes.hero.HeroDescLayer").showHeroDesc(uf_sceneManager:getCurScene(), knightId, true, false, 1, nHeroCount)
                    tLayer:setTag(HERO_DESC_LAYER_TAG)
                else
                    tLayer:scrollToPageWithIndex(nHeroCount - 1)
                end
            elseif index == 1 then
                
            end
        end)

        self._petPageView:setClippingEnabled(false)
        self._petPageView:showPageWithCount(2, 1)
    elseif style == 3 then
        self:adapterWidgetHeight("Panel_desc1", "Panel_topbar1", "", 0, 0)
        self:adapterWidgetHeight("ScrollView_scroll", "Panel_topbar2", "", 10, 10)
        self:getPanelByName("Panel_btns1"):setVisible(false)
        self:showWidgetByName("Panel_btns2", false)

        self:showWidgetByName("Button_Left", false)
        self:showWidgetByName("Button_Right", false)

    end

    -- 更换战宠
    self:registerBtnClickEvent("Button_genghuan", function ( widget )
        if slotInfo and slotInfo.teamId and slotInfo.pos and slotInfo.slot then
         
        end
        require("app.scenes.pet.PetSelectPetLayer").show()
        self:_closeWindow()
    end) 

    self:_updateCommonAttrs()
    self:_enableFosterButton()
end

function PetInfo:scrollToPageWithIndex(nIndex)
    if self._petPageView then
        local nPageCount = self._petPageView:getPageCount()
        if nIndex >= 0 and nIndex <= (nPageCount - 1) then
            self._petPageView:jumpToPage(nIndex)
        end
    end
end

-- 更新通用的属性, 名字啊, star啥的
function PetInfo:_updateCommonAttrs()
    -- 4个title
    self:getLabelByName("Label_attr1_title"):createStroke(Colors.strokeBrown, 2)
    self:getLabelByName("Label_attr2_title"):createStroke(Colors.strokeBrown, 2)
    self:getLabelByName("Label_skill_txt"):createStroke(Colors.strokeBrown, 2)
    self:getLabelByName("Label_spirit_txt"):createStroke(Colors.strokeBrown, 2)
    self:getLabelByName("Label_desc_txt"):createStroke(Colors.strokeBrown, 2)

    if self._style == 1 or self._style == 3 then
        --战宠形象
        local eff = G_Path.getPetReadyEffect(self._tPetTmpl.ready_id)
        if not self._tEffectPic then
            self._tEffectPic = EffectNode.new(eff)
            assert(self._tEffectPic)
            local tParent = self:getPanelByName("Panel_PetEffect")
            if tParent then
                tParent:setScale(0.8)
                tParent:addNode(self._tEffectPic)
                self._tEffectPic:play()
            end
        end
    end

    -- 战斗力
    CommonFunc._updateLabel(self, "Label_FightValue", {text=G_GlobalFunc.ConvertNumToCharacter(self._tPet.fight_value), stroke=Colors.strokeBrown, color=Colors.qualityColors[1]})

    -- 战宠名字
    CommonFunc._updateLabel(self, "Label_name", {text=self._tPetTmpl.name, color=Colors.qualityColors[self._tPetTmpl.quality], stroke=Colors.strokeBrown, size=2})

    -- 什么品质的宠
    CommonFunc._updateImageView(self, "Image_color", {texture=G_Path.getPetQualityImage(self._tPetTmpl.quality)})

    -- 基础属性
    local nAttack, nHp, nPhyDef, nMagDef = G_Me.bagData.petData:getBaseAttr(self._tPet.level, self._tPetTmpl.id,self._tPet.addition_lvl)

    CommonFunc._updateLabel(self, "Label_attack_value", {text=" +"..nAttack})
    CommonFunc._updateLabel(self, "Label_hp_value", {text=" +"..nHp})
    CommonFunc._updateLabel(self, "Label_phydef_value", {text=" +"..nPhyDef})
    CommonFunc._updateLabel(self, "Label_magdef_value", {text=" +"..nMagDef})
    CommonFunc._updateLabel(self, "Label_Tips", {text=G_lang:get("LANG_PET_STRENGTH_TIPS")})

    -- 有没有技能加伤
    if self._tPetTmpl.harm_add == 0 then
        self:showWidgetByName("Label_StarAddHarm", false)
        self:showWidgetByName("Label_StarAddHarm_Value", false)
    else
        self:showWidgetByName("Label_StarAddHarm", true)
        self:showWidgetByName("Label_StarAddHarm_Value", true)
        local label = self:getLabelByName("Label_StarAddHarm_Value")
        if label then
            label:setText(string.format(" +%.f%%", self._tPetTmpl.harm_add/10))
        end
    end

    -- 护佑
    local szProtectRate = string.format("%d", self._tPetTmpl.protect_account / 10)
    CommonFunc._updateLabel(self, "Label_Protect_Tips", {text=G_lang:get("LANG_PET_PROTECT_TIPS", {num=szProtectRate})})

    -- 战宠星级
    local nStar = self._tPetTmpl.star
    for i=1, STAR_MAX do
        self:showWidgetByName("Image_star_"..i.."_full", nStar >= i)
        self:showWidgetByName("Image_start_"..i.."_full", nStar >= i)
    end

    -- 满星时则隐藏星级进度显示同时显示满星的文字说明
    self:showWidgetByName("Panel_Progress_Info", nStar < STAR_MAX)
    self:showWidgetByName("Label_Progress_Full", nStar >= STAR_MAX)

    -- 当前碎片的数量和需要碎片的数量
    local nQuality = self._tPetTmpl.quality
    local tPetStarTmpl = pet_star_info.get(nStar, nQuality)
    local nCurFragmentNum = G_Me.bagData:getFragmentNumById(self._tPetTmpl.relife_id)
    local nNeedFragmentNum = 0
    if tPetStarTmpl then
        nNeedFragmentNum = tPetStarTmpl.cost_fragment
    end
    CommonFunc._updateLabel(self, "Label_Progress", {text=nCurFragmentNum.."/"..nNeedFragmentNum, stroke=Colors.strokeBrown})
    local processBar = self:getLoadingBarByName("ProgressBar_Fragment")
    assert(processBar)
    if processBar then
        if nCurFragmentNum >= nNeedFragmentNum then
            processBar:setPercent(100)
        else
            processBar:setPercent(nCurFragmentNum / nNeedFragmentNum * 100)
        end
    end
    CommonFunc._updateLabel(self, "Label_UpStarTips", {text=G_lang:get("LANG_PET_UPSTAR_TIPS")})

    -- 神炼
    local tAdditionTmpl = pet_addition_info.get(self._tPetTmpl.addition_id, self._tPet.addition_lvl)
    CommonFunc._updateLabel(self, "Label_Spirit_Level", {text=self._tPet.addition_lvl})
    local szSpiritDescList = {}
    if tAdditionTmpl then
        for i=1, 6 do
            local pos = i
            local type = tAdditionTmpl["type_"..i]
            local value = tAdditionTmpl["value_"..i]
            self:getLabelByName("Label_Pos_"..i):createStroke(Colors.strokeBrown, 1)
            if type == 0 then
                self:showWidgetByName("Image_Pos_Light_"..i, false)
            else
                local _, _, attrType, attrValue = MergeEquipment.convertPassiveSkillTypeAndValue(type, value)
                self:showWidgetByName("Image_Pos_Light_"..i, true)
                local szDesc = G_lang:get("LANG_PET_SHOOT_POSITION", {num=i}).." "..attrType.."：+"..attrValue
                table.insert(szSpiritDescList, #szSpiritDescList + 1, szDesc)
            end
        end
        local nCount = 0
        for i=1, 7 do
            local szDesc = szSpiritDescList[i]
            local labelSpiritAttr = self:getLabelByName("Label_Spirit_Attr_"..i)
            if szDesc then
                labelSpiritAttr:setText(szDesc)
                nCount = nCount + 1
            else
                labelSpiritAttr:setText("")
            end
        end

        local szAddShow, szAttr = G_Me.bagData.petData:getAttrAddShow(self._tPet["base_id"], self._tPet.addition_lvl)
        if szAddShow and szAttr then
            local label = self:getLabelByName("Label_Spirit_Attr_"..(nCount + 1))
            if label then
                label:setText(szAddShow..szAttr)
            end
        end
    end
    CommonFunc._updateLabel(self, "Label_Spirit_Desc", {text=G_lang:get("LANG_PET_ADDITION_DESC")})


    -- 描述
    CommonFunc._updateLabel(self, "Label_desc_content", {text=self._tPetTmpl.directions})
    
    self:setSkillInfo()

    self:adapterInfo()


end

function PetInfo:setSkillInfo()
    -- 普通技能
    local tCommomSkillTmpl = skill_info.get(self._tPetTmpl.common_id)
    local tActiveSkillTmpl = skill_info.get(self._tPetTmpl.active_skill_id)
    local szCommonSkillDesc = ""
    local szActiveSkillDesc = ""
    if tCommomSkillTmpl then
       szCommonSkillDesc = "["..tCommomSkillTmpl.name.."] " .. tCommomSkillTmpl.directions
    end
    if tActiveSkillTmpl then
       szActiveSkillDesc = "["..tActiveSkillTmpl.name.."] " .. tActiveSkillTmpl.directions
    end

    local tPanel = self:getPanelByName("Panel_skill")
    local tSize = tPanel:getSize()

    local nBottomY = 5
    local labelCheck = self:getLabelByName("Label_CheckSkill")
    local labelLine = self:getLabelByName("Label_Line")
    if labelCheck then
        labelCheck:setPositionXY(tSize.width - 100, nBottomY + labelCheck:getSize().height/2)
        labelLine:setPositionXY(tSize.width - 100, nBottomY + labelCheck:getSize().height/2)

        nBottomY = labelCheck:getSize().height + 10
    end


    local labelSkillTips = self:getLabelByName("Label_SkillTips")
    if labelSkillTips then
        labelSkillTips:setText(G_lang:get("LANG_PET_SKILL_TIPS"))
        labelSkillTips:setPositionXY(labelSkillTips:getPositionX(), nBottomY + labelSkillTips:getSize().height/2)

        nBottomY = nBottomY + labelSkillTips:getSize().height + 5
    end

    -- 技能
    if tActiveSkillTmpl then
        local label = GlobalFunc.createGameLabel(szActiveSkillDesc, 22, Colors.inActiveSkill, nil, CCSizeMake(tSize.width - 50, 0), true)
        local labelSize = label:getSize()
        local labelPosX = tSize.width - labelSize.width/2 - 5
        label:setPosition(ccp(labelPosX, nBottomY + labelSize.height/2))
        tPanel:addChild(label, 1, 100)

        labelPosX = labelPosX - labelSize.width/2
        local img = ImageView:create()
        img:loadTexture("ui/text/txt/icon_skill_ji.png", UI_TEX_TYPE_LOCAL)
        local imgSize = img:getSize()
        img:setPosition(ccp(labelPosX - imgSize.width/2 - 5, nBottomY + labelSize.height - imgSize.height/2))
        tPanel:addChild(img)

        nBottomY = nBottomY + labelSize.height + 5
    end

    -- 普通攻击
    if tCommomSkillTmpl then
        local label = GlobalFunc.createGameLabel(szCommonSkillDesc, 22, Colors.inActiveSkill, nil, CCSizeMake(tSize.width - 50, 0), true)
        local labelSize = label:getSize()
        local labelPosX = tSize.width - labelSize.width/2 - 5
        label:setPosition(ccp(labelPosX, nBottomY + labelSize.height/2))
        tPanel:addChild(label, 1, 100)

        labelPosX = labelPosX - labelSize.width/2
        local img = ImageView:create()
        img:loadTexture("ui/text/txt/icon_skill_pu.png", UI_TEX_TYPE_LOCAL)
        local imgSize = img:getSize()
        img:setPosition(ccp(labelPosX - imgSize.width/2 - 5, nBottomY + labelSize.height - imgSize.height/2))
        tPanel:addChild(img)

        nBottomY = nBottomY + labelSize.height + 8
    end

    -- title 
    local imgTitle = self:getImageViewByName("ImageView_skillTitle")
    if imgTitle then
        local x, y = imgTitle:getPosition()
        local size = imgTitle:getSize()
        imgTitle:setPosition(ccp(x, nBottomY + size.height/2))
        nBottomY = nBottomY + size.height + 5
    end

    tPanel:setSize(CCSizeMake(tSize.width, nBottomY))
end

function PetInfo:adapterInfo()
    local height = 5
    local scrollView = self:getScrollViewByName("ScrollView_scroll")
    local scrollSize = scrollView:getInnerContainerSize()
    local panel = self:getPanelByName("Panel_desc")
    panel:setPosition(ccp(0,height))
    height = height + panel:getSize().height + 5

    panel = self:getPanelByName("Panel_spirit")
    panel:setPosition(ccp(0,height))
    height = height + panel:getSize().height + 5

    panel = self:getPanelByName("Panel_skill")
    panel:setVisible(true)
    panel:setPosition(ccp(0,height))
    height = height + panel:getSize().height + 5

    panel = self:getPanelByName("Panel_attr")
    panel:setPosition(ccp(0,height))
    height = height + panel:getSize().height + 5

    height = height - 5
    scrollView:setInnerContainerSize(CCSizeMake(scrollSize.width, height))
    self:getPanelByName("Panel_scrollContent"):setContentSize(CCSizeMake(scrollSize.width,height))
end

function PetInfo:_closeWindow()
    local tLayer = uf_sceneManager:getCurScene():getChildByTag(HERO_DESC_LAYER_TAG)
    if tLayer and tLayer.close then
        tLayer:close()
    end

    self:close()
end

function PetInfo:_enableFosterButton( ... )
    self:getButtonByName("Button_strength"):showAsGray(not G_Me.bagData.petData:couldStrength(self._tPet))
    self:getButtonByName("Button_jinglian"):showAsGray(not G_Me.bagData.petData:couldUpStar(self._tPet))
    self:getButtonByName("Button_Spirit"):showAsGray(self._tPet.addition_lvl >= G_Me.bagData.petData:getMaxRefineLevel())

    self:getImageViewByName("Image_strtxt"):showAsGray(not G_Me.bagData.petData:couldStrength(self._tPet))
    self:getImageViewByName("Image_reftxt"):showAsGray(not G_Me.bagData.petData:couldUpStar(self._tPet))
    self:getImageViewByName("Image_12"):showAsGray(self._tPet.addition_lvl >= G_Me.bagData.petData:getMaxRefineLevel())
end

-- 强化
function PetInfo:_onStrengthClick()
    if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.PET) then 
        return 
    end

    if not G_Me.bagData.petData:couldStrength(self._tPet) then
        G_MovingTip:showMovingTip(G_lang:get("LANG_PET_STRENGTH_MAX_LEVEL_TIPS"))
        return
    end

    if require("app.scenes.pet.develop.PetDevelopeScene").show(self._tPet,PetBagConst.DevelopType.STRENGTH) then
        self:_closeWindow()
    end
end

-- 升星
function PetInfo:_onUpStarClick()
    if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.PET) then 
        return 
    end

    if not G_Me.bagData.petData:couldUpStar(self._tPet) then
        G_MovingTip:showMovingTip(G_lang:get("LANG_PET_UPSTAR_MAXLEVEL_TIPS"))
        return
    end

    if require("app.scenes.pet.develop.PetDevelopeScene").show(self._tPet,PetBagConst.DevelopType.STAR) then
        self:_closeWindow()
    end
end

-- 神炼
function PetInfo:_onRefineClick()
    if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.PET) then 
        return 
    end

    if self._tPet.addition_lvl >= G_Me.bagData.petData:getMaxRefineLevel() then
        G_MovingTip:showMovingTip(G_lang:get("LANG_PET_REFINE_MAXLEVEL_TIPS"))
        return false
    end

    if require("app.scenes.pet.develop.PetDevelopeScene").show(self._tPet,PetBagConst.DevelopType.REFINE) then
        self:_closeWindow()
    end
end


return PetInfo
