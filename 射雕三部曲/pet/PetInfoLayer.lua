--[[
	文件名:PetInfoLayer.lua
	描述：外功秘籍详细信息页面
	创建人：peiyaoqiang
	创建时间：2017.03.21
--]]

local PetInfoLayer = class("PetInfoLayer", function(params)
    return display.newLayer()
end)

local OperateBtnTag = {
    eUpBtn = 11,     --升级按钮
    eTalentBtn = 12, --参悟按钮
    eRepBtn = 13,    --更换按钮
}

--[[
-- 参数 params 中各项为：
	{
        petId          宠物的Id
        modelId        宠物的模型Id，当petId有效时，这个参数无效
        petList        参数，外功秘籍列表
        needOpt        是否需要显示按钮，只有当petId有效的时候，这个参数才有效
        formationObj   玩家阵容数据，查看其他玩家信息的时候需要传该参数
	}
]]
function PetInfoLayer:ctor(params)
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})
    params = params or {}

    --保存列表的数据
    self.mFormationObj = params.formationObj or FormationObj    -- 后面读取玩家信息的时候，一定要通过访问 self.mFormationObj
    self.mPetId = params.petId or nil
    self.mPetList = params.petList or nil
    self.mPetData = nil
    for _,v in pairs(self.mPetList or {}) do
        if (v.Id == self.mPetId) then
            self.mPetData = clone(v)
            break
        end
    end

    self.mModelId = (self.mPetId ~= nil) and self.mPetData.ModelId or params.modelId
    self.mOnlyModelInfo = (params.petId == nil) and true or false
    self.mNeedBtn = (params.needOpt or false) and (not self.mOnlyModelInfo)
    self.mCurrIndex = 1
    
    --获得宠物在列表中的下标
    if self.mPetList ~= nil then
        for sub, v in pairs(self.mPetList) do
            if v.Id == self.mPetId then
                self.mCurrIndex = sub
            end
        end
    end

    -- 外功秘籍数量
    if self.mPetList ~= nil then
        self.mPetNum = table.nums(self.mPetList)
    else
        self.mPetNum = 1
    end
    
	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化页面控件
    self:initUI()
end

-- 获取恢复数据
function PetInfoLayer:getRestoreData()
    local retData = {
        petId = self.mPetId,
        petList = self.mPetList,
        needOpt = self.mNeedBtn,
    }
    return retData
end

-- 初始化页面控件
function PetInfoLayer:initUI()
    -- 背景图片
    local bgSprite = ui.newSprite("wgmj_16.jpg")
    bgSprite:setAnchorPoint(0, 0)
    bgSprite:setPosition(0, 0)
    self.mParentLayer:addChild(bgSprite)
    self.mBgSprite = bgSprite

    -- 判断是否有多个宠物
    if self.mOnlyModelInfo or self.mPetNum == 1 then
    	local petLv = (self.mPetData == nil) and 1 or self.mPetData.Lv
    	local petLayer = self.mOnlyModelInfo and 0 or (self.mPetData.TotalNum - self.mPetData.CanUseTalNum)  --宠物已点的参悟数
    	local petLayerStr = (petLayer == 0) and "" or string.format("%+d", petLayer)
    	local isIn, slotId
	    if not self.mOnlyModelInfo then
	        isIn, slotId = self.mFormationObj:petInFormation(self.mPetData.Id)
	    end
        self:addPetFigure(self.mBgSprite, self.mPetId, self.mModelId, petLv, petLayerStr, isIn, slotId)
    else
        --创建形象图的滑动控件
        self:addSliderView()
        --设置箭头
        self:initSliderArrow()
    end

    -- 退出按钮
    local mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    mCloseBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
    self.mParentLayer:addChild(mCloseBtn)

    -- 获取途径
    local btnGetway = ui.newButton({
        normalImage = "tb_34.png",
        clickAction = function()
            -- local currModelId = self.mModelId
            -- if not self.mOnlyModelInfo then
            --     local mPetData = self.mPetList[self.mCurrIndex]
            --     currModelId = mPetData.ModelId
            -- end
            -- if (currModelId ~= nil) and (currModelId > 0) then
            --     LayerManager.addLayer({
            --         name = "hero.DropWayLayer",
            --         data = {
            --             resourceTypeSub = ResourcetypeSub.ePet,
            --             modelId = currModelId
            --         },
            --         cleanUp = false,
            --     })
            -- end
            if not ModuleInfoObj:moduleIsOpen(ModuleSub.eExpedition, true) then
                return
            end
            LayerManager.showSubModule(ModuleSub.eExpedition)
        end
    })
    btnGetway:setPosition(580, 690)
    self.mParentLayer:addChild(btnGetway)

    -- 显示详情
    self:createPetDetail()
end

-- 创建滑动控件
function PetInfoLayer:addSliderView()
    -- 显示窗口大小
    local sliderViewSize = cc.size(640, 1136)

    self.mSliderView = ui.newSliderTableView({
        width = sliderViewSize.width,
        height = sliderViewSize.height,
        isVertical = false,
        selectIndex = self.mCurrIndex - 1,
        selItemOnMiddle = true,
        itemCountOfSlider = function(sliderView)
            return #self.mPetList
        end,
        itemSizeOfSlider = function(sliderView)
            return sliderViewSize.width, sliderViewSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
        	local itemInfo = self.mPetList[index + 1]
        	local petLayer = itemInfo.TotalNum - itemInfo.CanUseTalNum  --宠物已点的参悟数
            local petLayerStr = petLayer == 0 and "" or string.format("%+d", petLayer)
            local isIn, slotId = self.mFormationObj:petInFormation(itemInfo.Id)
        	self:addPetFigure(itemNode, itemInfo.Id, itemInfo.ModelId, itemInfo.Lv, petLayerStr, isIn, slotId)
        end,
        selectItemChanged = function(sliderView, selectIndex)
            print("---当前是第"..tostring(selectIndex + 1).."只外功秘籍---")
            self.mCurrIndex = selectIndex + 1
            self:refreshDetail()

            -- 左右箭头
            if self.mLeftArrow and self.mRightArrow then
                if selectIndex == 0 then
                    self.mLeftArrow:setVisible(false)
                    self.mRightArrow:setVisible(true)
                elseif selectIndex == self.mPetNum - 1 then
                    self.mLeftArrow:setVisible(true)
                    self.mRightArrow:setVisible(false)
                else
                    self.mLeftArrow:setVisible(true)
                    self.mRightArrow:setVisible(true)
                end
            end

            -- 更新父页面数据
            if self.mCallback then
                self.mCallback(self.mPetList, self.mCurrIndex)
            end
        end,
        onItemClecked = function(sliderView, onClickItemIndex)
            print("---点击第"..tostring(onClickItemIndex + 1).."只外功秘籍---")
        end
    })
    self.mSliderView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mSliderView:setPosition(sliderViewSize.width * 0.5, sliderViewSize.height * 0.5)
    self.mBgSprite:addChild(self.mSliderView)
end

--显示宠物的大图、名字和星级
function PetInfoLayer:addPetFigure(parent, petGuid, petModelId, petLv, petLayerStr, isIn, slotId)
    local pet = Figure.newPet({
        petId = petGuid,
        modelId = petModelId,
        needAction = true,
        clickCallback = nil
    })
    pet:setAnchorPoint(cc.p(0.5, 0))
    pet:setPosition(320, 600)
    parent:addChild(pet)

    -- 外功秘籍名字
    local petName = PetModel.items[petModelId].name
    local valueLv = Utility.getQualityColorLv(PetModel.items[petModelId].quality)
    local petNameColorH = Utility.getColorValue(valueLv, 2)
    local tempStr = nil
    local strHeroName, heroNameColorH = nil
    if isIn then
        -- 获取主人名字
        local slotInfo = self.mFormationObj:getSlotInfoBySlotId(slotId)
        local heroInfo = self.mFormationObj:getSlotHeroInfo(slotInfo.HeroId)
        local heroBase = HeroModel.items[heroInfo.ModelId]
        strHeroName = ConfigFunc:getHeroName(heroInfo.ModelId, {IllusionModelId = heroInfo.IllusionModelId, heroFashionId = heroInfo.CombatFashionOrder})
        heroNameColorH = Utility.getQualityColor(heroBase.quality, 2)
        
        -- 如果是主角
        if (heroBase.specialType == Enums.HeroType.eMainHero) and (self.mFormationObj.mOtherPlayerInfo ~= nil) and (self.mFormationObj.mOtherPlayerInfo.Name ~= nil) then
            strHeroName = self.mFormationObj.mOtherPlayerInfo.Name
        end

        -- 构建标题字符串
        tempStr = TR("等级%s%s%s%s%s",
            petLv,
            petNameColorH,
            petName,
            Enums.Color.eYellowH,
            petLayerStr
        )        
    else
        if petGuid == nil then  --只是模型Id
            tempStr = string.format("%s%s",
                petNameColorH,
                petName
            )
        else    --得到的外功秘籍
            tempStr = TR("等级%s %s%s%s%s",
                petLv,
                petNameColorH,
                petName,
                Enums.Color.eYellowH,
                petLayerStr
            )
        end
    end
    Figure.newNameAndStar({
        parent = parent,
        position = cc.p(320, 1120),
        nameText = tempStr,
        starCount = valueLv,
        })
    if (strHeroName ~= nil) then
        local nameLabel = ui.newLabel({
            text = TR("装备于%s%s", heroNameColorH, strHeroName),
            color = cc.c3b(0xff, 0xfb, 0xde),
            outlineColor = cc.c3b(0x37, 0x30, 0x2c),
            size = 24,
        })
        nameLabel:setAnchorPoint(cc.p(0, 0.5))
        nameLabel:setPosition(20, 660)
        parent:addChild(nameLabel, 1)
    end
end

--初始化箭头的显示
function PetInfoLayer:initSliderArrow()
    if self.mPetNum > 1 then
        self.mLeftArrow = ui.newButton({
            normalImage = "c_26.png",
            position = cc.p(20, 840),
            clickAction = function(btnObj)
                self.mSliderView:setSelectItemIndex(self.mCurrIndex - 2, true)
            end
        })
        self.mLeftArrow:setScaleX(-1)
        self.mBgSprite:addChild(self.mLeftArrow)

        self.mRightArrow = ui.newButton({
            normalImage = "c_26.png",
            position = cc.p(620, 840),
            clickAction = function(btnObj)
                self.mSliderView:setSelectItemIndex(self.mCurrIndex, true)
            end
        })
        self.mBgSprite:addChild(self.mRightArrow)

        if self.mCurrIndex == 1 then
            self.mLeftArrow:setVisible(false)
        elseif self.mCurrIndex == self.mPetNum then
            self.mRightArrow:setVisible(false)
        end
    end
end

-- 创建宠物详细信息部分
function PetInfoLayer:createPetDetail()
    --详细信息背景
    local infoBgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 650))
    infoBgSprite:setPosition(320, 0)
    infoBgSprite:setAnchorPoint(cc.p(0.5, 0))
    self.mParentLayer:addChild(infoBgSprite)

    -- 灰色背景
    local tmpGraySprite = ui.newScale9Sprite("c_17.png", cc.size(620, self.mNeedBtn and 530 or 590))
    tmpGraySprite:setAnchorPoint(0.5, 1)
    tmpGraySprite:setPosition(320, 607)
    self.mParentLayer:addChild(tmpGraySprite)

    -- 详细信息滑动部分
    self.mDetailView = ccui.ScrollView:create()
    self.mDetailView:setContentSize(cc.size(640, self.mNeedBtn and 516 or 575))
    self.mDetailView:setDirection(ccui.ScrollViewDir.vertical)
    self.mDetailView:setPosition(0, self.mNeedBtn and 85 or 25)
    self.mParentLayer:addChild(self.mDetailView)
    -- 详细信息真正的parent
    self.mDetailParent = ccui.Layout:create()
    self.mDetailView:addChild(self.mDetailParent)

    self:refreshDetail()
end

-- 创建操作按钮
function PetInfoLayer:createOptBtn()
    if not self.mNeedBtn then
        return
    end
    --删除按钮
    self.mParentLayer:removeChildByTag(11, true)
    self.mParentLayer:removeChildByTag(12, true)
    self.mParentLayer:removeChildByTag(13, true)

    local petSlotId, petHeroInfo = PetObj:getPetSlotInfo(self.mPetId)   --获取外功秘籍是否装备和装备的人物信息
    local btnInfos = {
        {
            text = TR("升级"),
            clickAction = function()
                LayerManager.addLayer({
                    name = "pet.PetUpgradeLayer",
                    data = {
                        petList = self.mPetList,
                        currIndex = self.mCurrIndex,
                    },
                    cleanUp = true
                })
            end,
            btnTag = OperateBtnTag.eUpBtn,
        },
        {
            text = TR("参悟"),
            clickAction = function()
                local currPetModel = PetModel.items[self.mPetData.ModelId]
                if currPetModel.valueLv < 3 then
                    ui.showFlashView({
                        text = TR("蓝色及以上品质外功秘籍才有参悟系统")
                    })
                    return
                end
                LayerManager.addLayer({
                        name = "pet.PetUpgradeLayer",
                    data = {
                        petList = self.mPetList,
                        currIndex = self.mCurrIndex,
                        pageType = ModuleSub.ePetActiveTal,
                    },
                    cleanUp = true
                })
            end,
            btnTag = OperateBtnTag.eTalentBtn,
        },
        {
            text = TR("更换"),
            clickAction = function()
                local slotInfo = FormationObj:getSlotInfoBySlotId()
                LayerManager.addLayer({
                    name = "team.TeamSelectPetLayer",
                    data = {
                        slotId = petSlotId,
                    },
                    cleanUp = true
                })
            end,
            btnTag = OperateBtnTag.eRepBtn,
        }
    }

    --根据按钮信息table中的数据创建按钮
    local btnStartPosX = 320 - (#btnInfos - 1) / 2 * 160
    for index, item in ipairs(btnInfos) do
        item.normalImage = "c_28.png"
        item.position = cc.p(btnStartPosX + (index - 1) * 160, 40)
        local tempBtn = ui.newButton(item)
        self.mParentLayer:addChild(tempBtn,0,item.btnTag)

        -- 进阶按钮添加小红点
        if item.btnTag == OperateBtnTag.eTalentBtn then
            local function dealRedDotVisible(redDotSprite)
                redDotSprite:setVisible(RedDotInfoObj:isValid(ModuleSub.ePetActiveTal, nil, petSlotId))
            end
            local eventNames = {EventsName.eSlotRedDotPrefix .. tostring(petSlotId)}
            ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = eventNames, parent = tempBtn})
        end
    end

    -- --小红点的判断

    -- local talCanUpGrade = Utility.ifPetCanStep(self.mPetData)
    -- if talCanUpGrade then
    --     local tempBtn = self.mParentLayer:getChildByTag()
    --     local btnSize = tempBtn:getContentSize()
    --     local reddotSprite = ui.createBubble({position = cc.p(btnSize.width * 0.5 - 10, btnSize.height * 0.5 - 10)})
    --     tempBtn:getExtendNode2():addChild(reddotSprite)
    -- end
end

-- 刷新宠物的详细信息
function PetInfoLayer:refreshDetail()
    --得到外功秘籍的属性
    if self.mOnlyModelInfo then
        self.mPetAttrs = Utility.getPetAttrs({ModelId = self.mModelId})
    else
        self.mPetData = self.mPetList[self.mCurrIndex]
        self.mPetAttrs = Utility.getPetAttrs(self.mPetData)
        self.mPetId = self.mPetData.Id
        self.mModelId = self.mPetData.ModelId
    end

    -- 重置显示
    local petBase = PetModel.items[self.mModelId]
    self:createOptBtn()
    self.mDetailParent:removeAllChildren()
    
    -- 封装创建背景框的函数
    local parentPosY = -10 --变化的y值，记录滑动页面的高度
    local baseWidth = 606  --各种熟悉底图的宽
    local function addBgSprite(tempBgSize, posY, titleText)
        return ui.newNodeBgWithTitle(self.mDetailParent, tempBgSize, titleText, cc.p(320, posY), cc.p(0.5, 1))
    end

    --------------------------------------------------------------------------------
    -- 基础属性(血量、攻击、防御）
    local baseBgSize = cc.size(baseWidth, 101)
    local baseBgSprite = addBgSprite(baseBgSize, parentPosY, TR("基础属性"))
    local attrFont = {TR("生命"), TR("攻击"), TR("防御")}
    for index, item in ipairs({Fightattr.eHP, Fightattr.eAP, Fightattr.eDEF}) do
        local attrValue = self.mPetAttrs[item] or 0
        local tempLabel = ui.newLabel({
            text = string.format("%s:%s %s", attrFont[index], Enums.Color.eDarkGreenH, attrValue),
            color = cc.c3b(0x46, 0x22, 0x0d),
            anchorPoint = cc.p(0, 0.5)
        })
        tempLabel:setPosition((index - 1) * 200 + 30, baseBgSize.height - 67)
        baseBgSprite:addChild(tempLabel)
    end
    parentPosY = parentPosY - baseBgSize.height - 10

    --------------------------------------------------------------------------------
    -- 技能属性
    local skillBgSize = cc.size(baseWidth, 180)
    local skillBgSprite = addBgSprite(skillBgSize, parentPosY, TR("技能属性"))

    --技能属性
    local buffId
    if self.mOnlyModelInfo then
        local relation = PetExtraBuffRelation.items[self.mModelId]
        if relation and relation[0] then
            buffId = relation[0].buffIDs
        end
    end
    
    --上阵的外功秘籍，显示技能在第几回合释放
    if self.mPetId ~= nil then
        local roundText = TR("[没有上阵]")
        local isInFormation, inSlotId = self.mFormationObj:petInFormation(self.mPetId)
        if isInFormation then
            local originalFormation = self.mFormationObj:getPetFormationInfo()
            if (originalFormation.FormationStr == nil) or (originalFormation.FormationStr == "") then
                -- 查看他人阵容的时候，服务器没有返回外功布阵信息，就不显示了
                roundText = ""
            else
                -- 按照服务端的理解，这里应该是以释放顺序为key的列表，value是对应的卡槽
                local tmpFormationList = string.split(originalFormation.FormationStr, ",")
                for index,slotId in ipairs(tmpFormationList) do
                    if (tonumber(slotId) == inSlotId) then
                        roundText = TR("[第%s回合后释放]", index)
                        break
                    end
                end
            end
        end
        local roundLabel = ui.newLabel({
            text = roundText,
            size = 24,
            color = cc.c3b(0x46, 0x22, 0x0d),
            anchorPoint = cc.p(0, 0.5),
        })
        roundLabel:setPosition(30, skillBgSize.height - 65)
        skillBgSprite:addChild(roundLabel)
    end

    --技能描述
    local skillLabel = ui.newLabel({
        text = Utility.getPetSkillDes(self.mOnlyModelInfo and {ModelId = self.mModelId, BuffId = buffId} or self.mPetData),
        color = Enums.Color.eBrown,
        dimensions = cc.size(skillBgSize.width - 60, 0),
    })
    skillLabel:setAnchorPoint(cc.p(0, 1))
    skillLabel:setPosition(30, skillBgSize.height - 87)
    skillBgSprite:addChild(skillLabel)

    parentPosY = parentPosY - skillBgSize.height - 10

    --------------------------------------------------------------------------------
    -- 参悟属性
    if petBase.valueLv >= 3 then   --外功秘籍品质有参悟
        local talentNum = (self.mPetData == nil) and 0 or self.mPetData.Layer             --参悟数量
        local rowHeight = 50    --一行的高度
        local titleHei = 63     --标题高度
        local exetHei = (talentNum == 0) and 63 or -20     --额外的高度，没有参悟时需要这个
        local innateHeight = titleHei + rowHeight * talentNum + exetHei
        if (innateHeight < 115) then
            innateHeight = 115
        end
        --参悟属性背景
        local innateBgSize = cc.size(baseWidth, innateHeight)  --根据参悟数量设置背景的高度
        local innateBgSprite = addBgSprite(innateBgSize, parentPosY, TR("参悟属性"))
        --参悟信息的描述
        if talentNum > 0 then
            for i = 1, talentNum, 1 do
                --参悟的点数标题的显示，如：参悟+1
                local talentIdLabel = ui.newLabel({
                    text = TR("第%d层", i),
                    color = Enums.Color.eDarkGreen,
                    anchorPoint = cc.p(0, 0.5),
                })
                talentIdLabel:setPosition(30, innateBgSize.height - titleHei - rowHeight * (i-1))
                innateBgSprite:addChild(talentIdLabel)

                --参悟每个点数的描述
                local talentId = self.mPetData.TalentInfoList[i].TalentID
                require("pet.PetTalentHelper")
                local talentLabel = ui.newLabel({
                    text = string.format("%s", PetTalentHelper.getPetTalentIntroduce(self.mPetData, talentId)),
                    color = Enums.Color.eDarkGreen,
                    anchorPoint = cc.p(0, 0.5),
                    dimensions = cc.size(410, 0)
                })
                talentLabel:setPosition(innateBgSize.width / 2 - 130, innateBgSize.height - titleHei - rowHeight * (i-1))
                innateBgSprite:addChild(talentLabel)
            end
            parentPosY = parentPosY - innateHeight   --记录这些数据的高度
        else    --已点参悟数量为0
            local talentLabel = ui.newLabel({
                    text = TR("暂未激活任何参悟"),
                    color = Enums.Color.eBrown,
                    anchorPoint = cc.p(0.5, 0.5),
                })
            talentLabel:setPosition(innateBgSize.width / 2, innateBgSize.height - titleHei - 15)
            innateBgSprite:addChild(talentLabel)
            parentPosY = parentPosY - titleHei - exetHei   --记录这些数据的高度
        end
    else
        parentPosY = parentPosY + 10
    end
    parentPosY = parentPosY - 10

    -------------------------------------------------------------------------------
    -- dump(self.mPetData, "外功数据")
    -- 羁绊
    local prHeroModelIds = PetModel.items[self.mModelId].prHeroModelIds
    if prHeroModelIds and next(prHeroModelIds) then
        local innateHeight = 220
        local bgSprite = addBgSprite(cc.size(baseWidth, innateHeight), parentPosY, TR("羁绊"))
        local totalNum = self.mPetData and self.mPetData.TotalNum or 0
        local canUseTalNum = self.mPetData and self.mPetData.CanUseTalNum or 0
        totalNum = totalNum - canUseTalNum
        local prHeroModel = prHeroModelIds[1]
        if #prHeroModelIds > 1 then
            prHeroModel = HeroObj:getMainHero().ModelId
        end
        
        -- 是否激活
        local isActive = false
        for key, item in pairs(self.mFormationObj.mSlotInfo) do
            for _, heroModelId in pairs(prHeroModelIds) do
                if item.ModelId == heroModelId and item.Pet.ModelId == self.mModelId then
                    isActive = true
                    break
                end
            end
        end
        
        -- 文字显示与某人产生羁绊
        local prHeroBase = HeroModel.items[prHeroModel]
        local strPrHeroName = prHeroBase.name
        if (prHeroBase.specialType == Enums.HeroType.eMainHero) and (self.mFormationObj.mOtherPlayerInfo ~= nil) and (self.mFormationObj.mOtherPlayerInfo.Name ~= nil) then
            strPrHeroName = self.mFormationObj.mOtherPlayerInfo.Name
        end
        local prLabel = ui.createLabelWithBg({
                bgFilename = "wgmj_18.png",
                labelStr = TR("该外功可与%s形成羁绊", strPrHeroName),
                color = cc.c3b(0x79, 0x22, 0x0d),
                alignType = ui.TEXT_ALIGN_CENTER,
                fontSize = 23,
            })
        prLabel:setAnchorPoint(cc.p(0.5, 1))
        prLabel:setPosition(cc.p(baseWidth*0.5, 150 + 25))
        bgSprite:addChild(prLabel)

        -- 是否激活
        local activeSprite = ui.createLabelWithBg({
                bgFilename = isActive and "c_156.png" or "c_157.png",
                alignType = ui.TEXT_ALIGN_CENTER,
                labelStr = isActive and TR("已激活") or TR("未激活"),
            })
        activeSprite:setPosition(baseWidth*0.9, innateHeight*0.5)
        bgSprite:addChild(activeSprite)

        -- 显示当前解锁属性和下个属性
        if PetHeroPrRelation.items[prHeroModel] then
            -- 加成属性列表
            local addAttrList = PetHeroPrRelation.items[prHeroModel][self.mModelId]
            -- dump(addAttrList, "加成属性列表")

            local left, right = self:getLeftRightAttr(addAttrList, totalNum)
            -- 解锁完了
            if left == right and totalNum >= right then
                local attrStr = self:getAttrsStr(addAttrList[right])
                local attrLabel = ui.newLabel({
                        text = attrStr,
                        size = 24,
                        color = cc.c3b(0x46, 0x22, 0x0d),
                    })
                attrLabel:setAnchorPoint(cc.p(0, 0.5))
                attrLabel:setPosition(baseWidth*0.05, innateHeight*0.5)
                bgSprite:addChild(attrLabel)

                local unlockLabel = ui.newLabel({
                        text = TR("%s所有羁绊属性已全部解锁", PetModel.items[self.mModelId].name),
                        color = Enums.Color.eNormalGreen,
                        size = 24,
                    })
                unlockLabel:setAnchorPoint(cc.p(0, 0.5))
                unlockLabel:setPosition(baseWidth*0.1, innateHeight*0.25)
                bgSprite:addChild(unlockLabel)
            -- 没解锁完
            else
                local attrStr = self:getAttrsStr(addAttrList[left])
                local attrLeftLabel = ui.newLabel({
                        text = attrStr,
                        size = 24,
                        color = cc.c3b(0x46, 0x22, 0x0d),
                    })
                attrLeftLabel:setAnchorPoint(cc.p(0, 0.5))
                attrLeftLabel:setPosition(baseWidth*0.05, innateHeight*0.5)
                bgSprite:addChild(attrLeftLabel)

                local attrStr = self:getAttrsStr(addAttrList[right])
                local attrRightLabel = ui.newLabel({
                        text = attrStr,
                        size = 24,
                        color = cc.c3b(0x46, 0x22, 0x0d),
                    })
                attrRightLabel:setAnchorPoint(cc.p(0, 0.5))
                attrRightLabel:setPosition(baseWidth*0.05, innateHeight*0.25)
                bgSprite:addChild(attrRightLabel)

                local lockLabel = ui.newLabel({
                        text = TR("(参悟+%d解锁)", right),
                        color = Enums.Color.eRed,
                        size = 24,
                    })
                lockLabel:setAnchorPoint(cc.p(1, 0.5))
                lockLabel:setPosition(baseWidth*0.98, innateHeight*0.25)
                bgSprite:addChild(lockLabel)
            end


            parentPosY = parentPosY - innateHeight
            parentPosY = parentPosY - 10
        else
            bgSprite:setVisible(false)
        end
    end
    
    --------------------------------------------------------------------------------
    -- 宠物描述
    local introLabel = ui.newLabel({
        text = petBase.intro,
        color = cc.c3b(0x46, 0x22, 0x0d),
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        dimensions = cc.size(570, 0)
    })

    local introBgSize = cc.size(baseWidth, introLabel:getContentSize().height + 87)
    local introBgSprite = addBgSprite(introBgSize, parentPosY, TR("外功秘籍简介"))

    introLabel:setAnchorPoint(cc.p(0.5, 1))
    introLabel:setPosition(introBgSize.width / 2, introBgSize.height - 55)
    introBgSprite:addChild(introLabel)
    parentPosY = parentPosY - introBgSize.height - 20
    
    --------------------------------------------------------------------------------
    local tempSize = self.mDetailView:getContentSize()
    local tempHeight = math.max(tempSize.height, math.abs(parentPosY))
    self.mDetailParent:setPosition(0, tempHeight)
    self.mDetailView:setInnerContainerSize(cc.size(tempSize.width, tempHeight))
    self.mDetailView:jumpToTop()
end

-- 找某个序号在列表中前后的序号
--[[
    attrsList   属性列表
    order       参悟次数
]]
function PetInfoLayer:getLeftRightAttr(attrsList, order)
    local greatValue = 10000    -- 虚构一个极大值
    local tinyValue = -1        -- 虚构一个极小值
    local left = tinyValue      -- 找序号左边最大值
    local right = greatValue    -- 找序号右边最小值
    local min = greatValue      -- 找整个列表最小值
    local max = tinyValue       -- 找整个列表最大值
    for key, value in pairs(attrsList) do
        -- 左边
        if order >= key then
            -- 找最大
            if left < key then left = key end
        -- 右边
        else
            -- 找最小
            if right > key then right = key end
        end

        -- 找最小值
        if min > key then min = key end
        -- 找最大值
        if max < key then max = key end
    end
    -- 左边越界
    if left < min then left = min end
    -- 右边越界
    if right > max then right = max end

    return left, right
end

-- 将属性加成转化为字符串
function PetInfoLayer:getAttrsStr(attrData)
    local ack = attrData.APR / 100
    local hp = attrData.HPR / 100
    local def = attrData.DEFR / 100

    local attrStr = ""
    -- 攻击
    if ack > 0 then
        attrStr = TR("%s#46220d攻击: #258711+%d%%    ", attrStr, ack)
    end
    -- 血量
    if hp > 0 then
        attrStr = TR("%s#46220d血量: #258711+%d%%    ", attrStr, hp)
    end
    -- 防御
    if def > 0 then
        attrStr = TR("%s#46220d防御: #258711+%d%%    ", attrStr, def)
    end

    return attrStr
end

return PetInfoLayer
