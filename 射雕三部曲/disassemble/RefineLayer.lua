--[[
	文件名：RefineLayer.lua
	描述：炼化功能分解页面
	创建人：yanxingrui
    修改人：lengjiazhi
	创建时间： 2016.4.19
--]]

local RefineLayer = class("RefineLayer", function(params)
	return display.newLayer()
end)

--[[
-- 参数
    params 中各项为：
    {
        resourcetype: 已选择物品的类型，取值在EnumsConfig.lua 的 Resourcetype 中获取
        selectList: 已经选择物品列表
    }
]]
function RefineLayer:ctor(params)
    -- 当前选中物品的类型
    self.mResourcetype = params and params.resourcetype
    -- 当前选中的物品数据列表
    self.mSelectList = params and params.selectList or {}

    -- 卡槽的最大数
    self.mSlotMaxCount = 6
    -- 卡槽对应的cardNode的列表
    self.mCardNodeList = {}


    -- 每个卡槽的位置
    self.mCardPos = {}

	-- 初始化分解页面
	self:initUI()

    self:refreshSlot()
end

function RefineLayer:getRestoreData()
    local retData = {}
    retData.resourcetype = self.mResourcetype
    retData.selectList = self.mSelectList

    return retData
end


function RefineLayer:initUI()
    -- 炉子
    self.BgSprite = ui.newSprite("zl_02.jpg")
    self.BgSprite:setPosition(320, 568)
    self:addChild(self.BgSprite)

    -- 分解待机（特效）
    local refineEffect = ui.newEffect({
            parent = self,
            effectName = "effect_ui_renwufenjie",
            animation = "daiji",
            position = cc.p(315, 525),
            loop = true,
        })

    -- 炉子声音
    self.mAudio = MqAudio.playEffect("luhuo.mp3", true)
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then
            MqAudio.stopEffect(self.mAudio)
        end
    end)

    local bgSp = ui.newScale9Sprite("c_25.png", cc.size(550, 43))
    local lab = ui.newLabel({
        text = TR("分解后返还所有强化消耗，原物品不保留"),
        color = cc.c3b(0xff, 0xfb, 0xde),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        size = 20,
    })
    bgSp:setPosition(320, 245)
    self:addChild(bgSp)
    lab:setPosition(320, 245)
    self:addChild(lab)

    -- 分解
    local tempBtn = ui.newButton({
    	text = TR("分解"),
    	normalImage = "c_28.png",
        position = cc.p(320, 180),
        clickAction = function()
            if not next(self.mSelectList) then
                ui.showFlashView(TR("请选择分解的物品"))
                return
            end
            if self.mResourcetype == Resourcetype.eHero then  -- 分解人物
                local orangeList, redList = {}, {}
                for _, item in pairs(self.mSelectList) do
                    local tempModel = HeroModel.items[item.ModelId]
                    if Utility.getQualityColorLv(tempModel.quality) > 4 then
                        if Utility.getQualityColorLv(tempModel.quality) > 5 then
                            table.insert(redList, tempModel.name)
                        else
                            table.insert(orangeList, tempModel.name)
                        end
                    end
                end

                if #redList == 0 and #orangeList == 0 then
                    self:requestHeroRefine()
                else
                    local tempStr = ""
                    if #redList ~= 0 then
                        local redStr = table.concat(redList, ",")
                        tempStr = string.format(tempStr..TR("红色侠客%s%s ", Enums.Color.eRedH, redStr))
                    end
                    if #orangeList ~= 0 then
                        local orangeStr = table.concat(orangeList, ",")
                        tempStr = string.format(tempStr..TR("%s橙色侠客%s%s ", Enums.Color.eNormalWhiteH, Enums.Color.eOrangeH, orangeStr))
                    end
                    self.layerObj = MsgBoxLayer.addOKLayer(TR("有%s%s被丢进了炼化炉，是否确定归隐？",
                            tempStr, Enums.Color.eNormalWhiteH), TR("归隐"), {{
                            text = TR("归隐"),
                            clickAction = function ()
                                self:requestHeroRefine()
                                LayerManager.removeLayer(self.layerObj)
                            end
                        }},{})
                end
            elseif self.mResourcetype == Resourcetype.eTreasure then -- 分解神兵
                self:requestTreasureRefine()
            elseif self.mResourcetype == Resourcetype.eNewZhenJue then -- 分解阵诀
                self:requestZhenJueRefine()
            elseif self.mResourcetype == Resourcetype.eEquipment then -- 分解装备
                self:requestEquipRefine()
			elseif self.mResourcetype == Resourcetype.ePet then -- 分解外功
				self.mConfirmLayer = MsgBoxLayer.addOKLayer(TR("有%s橙色%s外功被丢进炼化炉了，是否确定分解？", Enums.Color.eOrangeH, Enums.Color.eNormalWhiteH),
						TR("分解"), {{
							text = TR("分解"),
							clickAction = function ()
								self:requestPetRefine()
								LayerManager.removeLayer(self.mConfirmLayer)
							end
					}},{})
            elseif self.mResourcetype == Resourcetype.eZhenshou then -- 分解珍兽
                self:requestZhenshouRefine()
            end
        end,
    })
    self:addChild(tempBtn)
    self.decompose = tempBtn
    local redDotBtnList = {}
    if ModuleInfoObj:moduleIsOpen(ModuleSub.eZhenjue, false) then
        -- 内功一键分解
        local zhenJueOnekeyBtn = ui.newButton({
            normalImage = "tb_182.png",
            position = cc.p(90, 940),
            clickAction = function(pSender)
                pSender:setEnabled(false)
                self:oneKeyZhenJue(pSender)
            end,
        })
        self:addChild(zhenJueOnekeyBtn)
        zhenJueOnekeyBtn.moduleId = ModuleSub.eZhenjueRefine
        table.insert(redDotBtnList, zhenJueOnekeyBtn)
    end

    -- 装备一键分解
    local equipBtn = ui.newButton({
        normalImage = "tb_156.png",
        position = cc.p(210, 940),
        clickAction = function(obj)
            obj:setEnabled(false)
            self:oneKeyEquip(obj)
        end,
    })
    self:addChild(equipBtn)
    equipBtn.moduleId = ModuleSub.eDisassembleEquip
    -- 装备一键分解8级开启
    equipBtn:setVisible(PlayerAttrObj:getPlayerInfo().Lv>=8)
    table.insert(redDotBtnList, equipBtn)
    for i,btn in ipairs(redDotBtnList) do
        local function dealRedDotVisible(redDotSprite)
            redDotSprite:setVisible(RedDotInfoObj:isValid(btn.moduleId))
        end
        ui.createAutoBubble({parent = btn, eventName = RedDotInfoObj:getEvents(btn.moduleId),
            refreshFunc = dealRedDotVisible})
    end

    -- 人物一键分解
    local heroBtn = ui.newButton({
        normalImage = "tb_24.png",
        position = cc.p(330, 940),
        clickAction = function()
            self:oneKeyRefine(Resourcetype.eHero)
        end,
    })
    self:addChild(heroBtn)

    -- 装备商店
    local equipShopBtn = ui.newButton({
        normalImage = "tb_180.png",
        position = cc.p(450, 940),
        clickAction = function()
            if not ModuleInfoObj:moduleIsOpen(ModuleSub.eBDDShop, true) then
                return
            end
            LayerManager.addLayer({
                name = "challenge.BddExchangeLayer",
                data = {
                    mTag = 2
                }
            })
        end,
    })
    self:addChild(equipShopBtn)

    -- 聚宝阁
    local shopBtn = ui.newButton({
        normalImage = "tb_25.png",
        position = cc.p(570, 940),
        clickAction = function()
            if not ModuleInfoObj:moduleIsOpen(ModuleSub.eMysteryShop, true) then
                return
            end
            LayerManager.addLayer({
                name = "mysteryshop.MysteryShopLayer",
            })
        end,
    })
    self:addChild(shopBtn)

    --
    self:createSlotCard()
end

-- 创建卡槽对应的卡牌
function RefineLayer:createSlotCard()
    local squareSpace = 150 -- 方形排列时每行之间的距离
    local cardCount = self.mSlotMaxCount
    local startPosY = math.ceil(cardCount / 2) * squareSpace / 2 + 670
    for index = 1, cardCount do
        local tempPosX = (math.mod(index, 2) == 1) and 80 or 560
        local tempIndex = math.ceil(index / 2)
        local tempPosY = startPosY - (tempIndex - 1) * squareSpace - squareSpace / 2

        local tempCard
        tempCard = CardNode:create({
            -- cardShape = Enums.CardShape.eCircle,
            allowClick = true,
            onClickCallback = function()
                local tempData = self.mSelectList[index]
                if tempData and Utility.isEntityId(tempData.Id) then
                    self.mSelectList[index] = nil
                    --table.remove(self.mSelectList, index)
                    tempCard:setEmpty({}, "c_10.png", "c_22.png")
                    self:refreshSlot()
                    return
                end
                local tempData = {
                    selectType = Enums.SelectType.eResolve,
                    oldResourcetype = self.mResourcetype,
                    oldSelList = self.mSelectList or {},
                    callback = function(selectLayer, selectItemList, resourcetype)
                        local tempStr = "disassemble.DisassembleLayer"
                        local tempData = LayerManager.getRestoreData(tempStr)
                        tempData.refine = tempData.refine or {}
                        tempData.refine.resourcetype = resourcetype
                        tempData.refine.selectList = selectItemList
                        tempData.currTag = Enums.DisassemblePageType.eRefine
                        LayerManager.setRestoreData(tempStr, tempData)

                        -- 删除装备选择页面
                        LayerManager.removeLayer(selectLayer)
                    end
                }
                LayerManager.addLayer({
                    name = "commonLayer.SelectLayer",
                    data = tempData,
                })
            end
        })

        tempCard:setPosition(tempPosX, tempPosY)
        table.insert(self.mCardPos, cc.p(tempPosX, tempPosY))
        self:addChild(tempCard)
        --
        table.insert(self.mCardNodeList, tempCard)
    end
end

-- 更新卡槽
function RefineLayer:refreshSlot()
    if self.mPerviewBg then
        self.mPerviewBg:removeFromParent()
        self.mPerviewBg = nil
    end

    for index, cardNode in pairs(self.mCardNodeList) do
        local tempData = self.mSelectList[index]
        if tempData and Utility.isEntityId(tempData.Id) then
            -- dump(tempData,"测试装备数据")
            if self.mResourcetype == Resourcetype.eHero then
                cardNode:setHero(tempData, {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eMedicine})
            elseif self.mResourcetype == Resourcetype.eTreasure then
                cardNode:setTreasure(tempData)
            elseif self.mResourcetype == Resourcetype.eNewZhenJue then
                cardNode:setZhenjue(tempData)
            elseif self.mResourcetype == Resourcetype.eEquipment then
                cardNode:setEquipment(tempData)
			elseif self.mResourcetype == Resourcetype.ePet then
				cardNode:setPet(tempData)
            elseif self.mResourcetype == Resourcetype.eZhenshou then
                cardNode:setZhenshou(tempData)
            end
        else
            cardNode:setEmpty({}, "c_10.png", "c_22.png")
            local tempSize = cardNode:getContentSize()
            local tempSprite = ui.createGlitterSprite({
                filename = "c_22.png",
                parent = cardNode,
                position = cc.p(tempSize.width / 2, tempSize.height / 2),
                actionScale = 1.2,
            })
        end
    end
    self:perview()
end

-- 分解预览
function RefineLayer:perview()
    self.mPerviewBg = ui.newScale9Sprite("c_69.png",cc.size(620, 185))
    self.mPerviewBg:setPosition(320, 370)
    self:addChild(self.mPerviewBg)
    local perviewLabel = ui.newLabel({
        text = TR("分解预览"),
        size = 28,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    perviewLabel:setPosition(310, 140)
    self.mPerviewBg:addChild(perviewLabel)

    local resList = {} --分解产出列表
    local function addCount(id, count)
        resList[id] = resList[id] or 0
        resList[id] = resList[id] + count
    end
    local outputList = {}

    if self.mResourcetype == Resourcetype.eHero then
        for _,item in pairs(self.mSelectList) do
            outputList = Utility.analysisStrResList(HeroModel.items[item.ModelId].outputResource)
            for _,v in ipairs(outputList) do
                if v.modelId == 0 then
                    addCount(v.resourceTypeSub, v.num)
                else
                    addCount(v.modelId, v.num)
                end
            end

            if item.Lv > 1 then
                LvExp = ConfigFunc:getHeroEXPTotal(item.ModelId, item.Lv)
                addCount(ResourcetypeSub.eHeroExp, LvExp)
                addCount(ResourcetypeSub.eGold, LvExp)
            end
        end

    elseif self.mResourcetype == Resourcetype.eTreasure then
        local totalEXP = 0
        for _,item in pairs(self.mSelectList) do
            local outputList = Utility.analysisStrResList(TreasureModel.items[item.ModelId].outputResource)
            for _,v in ipairs(outputList) do
                if v.modelId == 0 then
                    addCount(v.resourceTypeSub, v.num)
                else
                    addCount(v.modelId, v.num)
                end
            end
            if item.Lv > 1 then
                local totalTreExp = item.EXP
                totalEXP = totalEXP + totalTreExp
            end
        end
        local tempNum = math.floor(totalEXP / 40000)
        if tempNum > 0 then
            addCount(14011301, tempNum)
        end
        local leftExp = totalEXP - tempNum * 40000
        if leftExp >= 10000 then
            addCount(14010801, math.floor(leftExp / 10000))
        end
    elseif self.mResourcetype == Resourcetype.eNewZhenJue then
        for _,item in pairs(self.mSelectList) do
            local outputList = Utility.analysisStrResList(ZhenjueModel.items[item.ModelId].outputResource)
            for _,v in ipairs(outputList) do
                if v.modelId == 0 then
                    addCount(v.resourceTypeSub, v.num)
                else
                    addCount(v.modelId, v.num)
                end
            end
        end
    elseif self.mResourcetype == Resourcetype.eEquipment then
        local stoneList = {
                GoodsModel.items[16050240],
                GoodsModel.items[16050239],
                GoodsModel.items[16050238],
                GoodsModel.items[16050237],
            }
        for i,v in ipairs(stoneList) do
            v.count = 0
        end
        for _,item in pairs(self.mSelectList) do
            local outputList = Utility.analysisStrResList(EquipModel.items[item.ModelId].outputResource)
            for _,v in ipairs(outputList) do
                if v.modelId == 0 then
                    addCount(v.resourceTypeSub, v.num)
                else
                    addCount(v.modelId, v.num)
                end
            end

            if item.Lv > 0 then
                addCount(ResourcetypeSub.eGold, item.Gold)
            end
            if item.Step > 0 then
                local totalEXP = item.TotalExp
                for i,v in ipairs(stoneList) do
                    if totalEXP == 0 then
                        break
                    end
                    local tempNum = math.floor(totalEXP / v.outputNum)

                    v.count = v.count + tempNum

                    totalEXP = totalEXP - tempNum*v.outputNum
                end
            end
        end
        for i,v in ipairs(stoneList) do
            if v.count > 0 then
                addCount(v.ID, v.count)
            end
        end
	elseif self.mResourcetype == Resourcetype.ePet then
		for index, item in pairs(self.mSelectList) do
			outputList = Utility.analysisStrResList(PetModel.items[item.ModelId].output)
			for key, v in ipairs(outputList) do
				if v.modelId == 0 then
					addCount(v.resourceTypeSub, v.num)
				else
					addCount(v.modelId, v.num)
				end
			end
			--不知道为什么，分解没有返回璞玉和金币。
			if item.Lv > 1 then
				addCount(ResourcetypeSub.eGold, item.TotalExp)
	 			addCount(ResourcetypeSub.ePetEXP, item.TotalExp)
 		   	end
			dump(resList, "产出：")
		end
    elseif self.mResourcetype == Resourcetype.eZhenshou then
        for index, item in pairs(self.mSelectList) do
            outputList = Utility.analysisStrResList(ZhenshouModel.items[item.ModelId].outputResource)
            for key, v in ipairs(outputList) do
                if v.modelId == 0 then
                    addCount(v.resourceTypeSub, v.num)
                else
                    addCount(v.modelId, v.num)
                end
            end
            if item.Lv > 1 then
                local useResList = ZhenshouObj:getZhenshouUseResList(item.Id)
                for key, v in ipairs(useResList) do
                    if v.modelId == 0 then
                        addCount(v.resourceTypeSub, v.num)
                    else
                        addCount(v.modelId, v.num)
                    end
                end
            end
        end
    end

    --处理数据
    local cardResList = {}
    for k,v in pairs(resList) do
        local tempRes = tonumber(k)
        local resType
        if tempRes > 10000 then
            resType = math.floor(tempRes / 10000)
        else
            resType = tempRes
        end
        local resourceTypeSub, moduleId = 0, 0
        if Utility.isGoods(resType) or Utility.isTreasure(resType) then
            resourceTypeSub, moduleId = resType, tempRes
        else
            resourceTypeSub, moduleId = resType, 0
        end
        local cardData = {
            resourceTypeSub = resType,
            num = v,
            modelId = moduleId,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum},
        }
        table.insert(cardResList, cardData)
    end

    local cardList = ui.createCardList({
            maxViewWidth = 580,
            space = 5,
            cardDataList = cardResList,
            allowClick = true,
        })
    cardList:setAnchorPoint(cc.p(0.5, 0.5))
    cardList:setPosition(310, 75)
    cardList:setScale(0.8)
    self.mPerviewBg:addChild(cardList)

    local label = ui.newLabel({
        text = TR("1.侠客归隐可获得修为或神魂，侠客品质越高获得越多"),
        size = 22,
        color = cc.c3b(0x46, 0x22, 0x0d),
        x = 60,
        y = 100,
        anchorPoint = cc.p(0,0.5)
    })
    self.mPerviewBg:addChild(label)

    label:setVisible(not next(self.mSelectList))
    local label = ui.newLabel({
        text = TR("2.分解紫色及以上神兵可获得神兵精魄用于神兵进阶"),
        size = 22,
        color = cc.c3b(0x46, 0x22, 0x0d),
        x = 60,
        y = 65,
        anchorPoint = cc.p(0,0.5)
    })
    self.mPerviewBg:addChild(label)
    label:setVisible(not next(self.mSelectList))

end
-- 一键分解界面
function RefineLayer:oneKeyRefine(resType)
    -- body
    if resType == Resourcetype.eHero then
        -- 分解人物
        local msgLayer
        local tempInfoList = {
            {
            -- 分解蓝色人物
                hintStr = TR("%s自动分解%s豪侠%s及%s豪侠%s以下侠客", Enums.Color.eWhiteH, Enums.Color.ePurpleH,
                    Enums.Color.eWhiteH, Enums.Color.ePurpleH, Enums.Color.eWhiteH),
                btnInfo = {
                    text = TR("归隐"),
                    clickAction = function (pSender)
                        self:oneKeyRefineInterface(10)
                        LayerManager.removeLayer(msgLayer)
                    end
                }
            },

            {
            -- 分解紫色人物
                hintStr = TR("%s自动分解%s宗师%s及%s宗师%s以下侠客", Enums.Color.eWhiteH, Enums.Color.eOrangeH,
                    Enums.Color.eWhiteH, Enums.Color.eOrangeH, Enums.Color.eWhiteH),
                btnInfo = {
                    text = TR("归隐"),
                    clickAction = function (pSender)
                        msgLayer = MsgBoxLayer.addOKLayer(TR("多余的宗师可用于群侠谱升星，少侠要不要再考虑一下？"),
                            "", {{
                            text = TR("归隐"),
                            clickAction = function ()
                                self:oneKeyRefineInterface(13)
                                LayerManager.removeLayer(msgLayer)
                            end
                            }, {
                            text = TR("取消"),
                            clickAction = function ()
                                LayerManager.removeLayer(msgLayer)
                            end}
                        })
                    end
                },
            },
        }
        msgLayer = MsgBoxLayer.addOneKeyRefineChoiceLayer(tempInfoList, TR("选择"))
    elseif resType == Resourcetype.eNewZhenJue then
        -- 分解绿色阵诀
        local msgLayer
        local tempInfoList = {
            {
                hintStr = TR("%s自动分解%s绿色%s及%s绿色%s以下 内功心法", Enums.Color.eWhiteH, Enums.Color.eNormalGreenH,
                    Enums.Color.eWhiteH, Enums.Color.eNormalGreenH, Enums.Color.eWhiteH),
                btnInfo = {
                    text = TR("分解"),
                    clickAction = function (pSender)
                        self:oneKeyRefineZhenJueInterface()
                        LayerManager.removeLayer(msgLayer)
                    end
                }
            }
        }
        msgLayer = MsgBoxLayer.addOneKeyRefineChoiceLayer(tempInfoList, TR("选择"))
    end
end

-- 一键分解装备
function RefineLayer:oneKeyEquip(pSender)
    local temp = true --控制展示或者关闭菜单
    self.mSelectStatus = { --保存菜单选择状态
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false,
        [5] = false,
        -- [6] = false,
        -- [7] = false,
    }

    local showAction
    local touchLayer = display.newLayer()
    touchLayer:setPosition(0,0)
    self:addChild(touchLayer, 10000)
    ui.registerSwallowTouch({
        node = touchLayer,
        allowTouch = true,
        endedEvent = function(touch, event)
            temp = true
            local callfunDelete = cc.CallFunc:create(function()
                if self.mSelBgSprite then
                    self.mSelBgSprite:removeFromParent()
                    self.mSelBgSprite = nil
                end
            end)
            local callfunCT = cc.CallFunc:create(function()
                pSender:setEnabled(true)
                touchLayer:removeFromParent()
            end)
            local scale = cc.ScaleTo:create(0.3, 1)
            showAction = cc.Sequence:create(scale, callfunDelete, callfunCT)
            self.mSelBgSprite:runAction(showAction)
        end
    })

    if temp then
        temp = false
        local callfunCT = cc.CallFunc:create(function()
            pSender:setEnabled(true)
        end)
        local scale = cc.ScaleTo:create(0.3, 2)
        showAction = cc.Sequence:create(scale, callfunCT)
    end

    if not self.mSelBgSprite then
        --菜单背景
        self.mSelBgSprite = ui.newScale9Sprite("gd_01.png", cc.size(120, 185))
        self.mSelBgSprite:setAnchorPoint(0.5, 1)
        self.mSelBgSprite:setPosition(230, 895)
        touchLayer:addChild(self.mSelBgSprite)
        local bgSize = self.mSelBgSprite:getContentSize()

        -- 当前选择分解数量
        local refineNum = ui.newLabel({
            text = TR("当前选择分解数量:%s", 0),
            size = 21,
            x = bgSize.width * 0.5,
            y = 51,
            outlineColor = Enums.Color.eBlack,
            anchorPoint = cc.p(0.5,1)
        })
        refineNum:setScale(0.45)
        self.mSelBgSprite:addChild(refineNum)

        -- 确定按钮
        local okButton = ui.newButton({
            normalImage = "c_28.png",
            text = TR("确定"),
            outlineColor = cc.c3b(0x8e, 0x4f, 0x09),
            clickAction = function()
                ui.showFlashView(TR("您当前没有装备可熔炼，快去获取吧！"))
            end
        })
        okButton:setScale(0.45)
        okButton:setPosition(bgSize.width * 0.5, 25)
        self.mSelBgSprite:addChild(okButton)

        -- 关闭按钮
        local closeButton = ui.newButton({
            normalImage = "zl_10.png",
            clickAction = function()
                if self.mSelBgSprite then
                    self.mSelBgSprite:removeFromParent()
                    self.mSelBgSprite = nil
                end
                touchLayer:removeFromParent()
            end
        })
        closeButton:setScale(0.45)
        closeButton:setPosition(bgSize.width * 0.87, bgSize.height-12)
        self.mSelBgSprite:addChild(closeButton)

        --菜单列表
        local selectList = ccui.ListView:create()
        selectList:setPosition(bgSize.width * 0.5, bgSize.height-20)
        selectList:setAnchorPoint(0.5, 1)
        selectList:setContentSize(bgSize.width, bgSize.height - 75)
        selectList:setDirection(ccui.ScrollViewDir.vertical)
        selectList:setBounceEnabled(true)
        self.mSelBgSprite:addChild(selectList)

        local function checkCallBack ( i )
            if self.mSelectStatus[i] then
                self.mSelectStatus[i] = false
            else
                self.mSelectStatus[i] = true
            end
            local equipData = self:getItemData()
            -- dump(equipData,"equipData")
            -- 重新设置选择的个数
            refineNum:setString(TR("当前选择分解数量:%s", #equipData))
            -- 确定分解按钮
            okButton:setClickAction(function()
                if #equipData == 0 then
                    ui.showFlashView(TR("您当前没有装备可熔炼，快去获取吧！"))
                    return
                end
                -- 调用分解接口
                self:requestEquipRefine(equipData)

                -- 关闭当前框框
                local callfunDelete = cc.CallFunc:create(function()
                    if self.mSelBgSprite then
                        self.mSelBgSprite:removeFromParent()
                        self.mSelBgSprite = nil
                    end
                end)
                local callfunCT = cc.CallFunc:create(function()
                    pSender:setEnabled(true)
                    touchLayer:removeFromParent()
                end)
                local scale = cc.ScaleTo:create(0.3, 1)
                showAction = cc.Sequence:create(scale, callfunDelete, callfunCT)
                self.mSelBgSprite:runAction(showAction)
            end)
        end

        for i = 1, #self.mSelectStatus do
            local layout = ccui.Layout:create()
            layout:setContentSize(bgSize.width, 22)
            local cellSprite = ui.newScale9Sprite("zl_09.png", cc.size(95, 20))
            cellSprite:setPosition(bgSize.width/2, 11)
            layout:addChild(cellSprite)

            local color = Utility.getColorValue(i, 1)
            local checkBtn = ui.newCheckbox({
                text = TR("%s品质",Utility.getColorName(i)),
                isRevert = true,
                textColor = color,
                outlineColor = Enums.Color.eBlack,
                outlineSize = 2,
                callback = function(pSenderC)
                    checkCallBack(i)
                end
                })
            checkBtn:setPosition(bgSize.width/2, 11)
            layout:addChild(checkBtn)
            checkBtn:setCheckState(self.mSelectStatus[i])
            checkBtn:setScale(0.5)
            -- 透明按钮
            local touchBtn = ui.newButton({
                normalImage = "c_83.png",
                size = cc.size(95, 20),
                clickAction = function()
                    checkCallBack(i)
                    checkBtn:setCheckState(self.mSelectStatus[i])
                end
            })
            touchBtn:setPosition(bgSize.width/2, 11)
            cellSprite:addChild(touchBtn)
            selectList:pushBackCustomItem(layout)
        end
    end

    self.mSelBgSprite:runAction(showAction)
end

-- 一键分解内功
function RefineLayer:oneKeyZhenJue(pSender)
    local temp = true --控制展示或者关闭菜单
    self.mSelectStatus = { --保存菜单选择状态
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false,
        [5] = false,
        -- [6] = false,
        -- [7] = false,
    }

    local showAction
    local touchLayer = display.newLayer()
    touchLayer:setPosition(0,0)
    self:addChild(touchLayer, 10000)
    ui.registerSwallowTouch({
        node = touchLayer,
        allowTouch = true,
        endedEvent = function(touch, event)
            temp = true
            local callfunDelete = cc.CallFunc:create(function()
                if self.mSelBgSprite then
                    self.mSelBgSprite:removeFromParent()
                    self.mSelBgSprite = nil
                end
            end)
            local callfunCT = cc.CallFunc:create(function()
                pSender:setEnabled(true)
                touchLayer:removeFromParent()
            end)
            local scale = cc.ScaleTo:create(0.3, 1)
            showAction = cc.Sequence:create(scale, callfunDelete, callfunCT)
            self.mSelBgSprite:runAction(showAction)
        end
    })

    if temp then
        temp = false
        local callfunCT = cc.CallFunc:create(function()
            pSender:setEnabled(true)
        end)
        local scale = cc.ScaleTo:create(0.3, 2)
        showAction = cc.Sequence:create(scale, callfunCT)
    end

    if not self.mSelBgSprite then
        --菜单背景
        self.mSelBgSprite = ui.newScale9Sprite("gd_01.png", cc.size(120, 185))
        self.mSelBgSprite:setAnchorPoint(0.5, 1)
        self.mSelBgSprite:setPosition(110, 895)
        touchLayer:addChild(self.mSelBgSprite)
        local bgSize = self.mSelBgSprite:getContentSize()

        -- 当前选择分解数量
        local refineNum = ui.newLabel({
            text = TR("当前选择分解数量:%s", 0),
            size = 21,
            x = bgSize.width * 0.5,
            y = 51,
            outlineColor = Enums.Color.eBlack,
            anchorPoint = cc.p(0.5,1)
        })
        refineNum:setScale(0.45)
        self.mSelBgSprite:addChild(refineNum)

        -- 确定按钮
        local okButton = ui.newButton({
            normalImage = "c_28.png",
            text = TR("确定"),
            outlineColor = cc.c3b(0x8e, 0x4f, 0x09),
            clickAction = function()
                ui.showFlashView(TR("您当前没有内功心法可分解，快去获取吧！"))
            end
        })
        okButton:setScale(0.45)
        okButton:setPosition(bgSize.width * 0.5, 25)
        self.mSelBgSprite:addChild(okButton)

        -- 关闭按钮
        local closeButton = ui.newButton({
            normalImage = "zl_10.png",
            clickAction = function()
                if self.mSelBgSprite then
                    self.mSelBgSprite:removeFromParent()
                    self.mSelBgSprite = nil
                end
                touchLayer:removeFromParent()
            end
        })
        closeButton:setScale(0.45)
        closeButton:setPosition(bgSize.width * 0.87, bgSize.height-12)
        self.mSelBgSprite:addChild(closeButton)

        --菜单列表
        local selectList = ccui.ListView:create()
        selectList:setPosition(bgSize.width * 0.5, bgSize.height-20)
        selectList:setAnchorPoint(0.5, 1)
        selectList:setContentSize(bgSize.width, bgSize.height - 75)
        selectList:setDirection(ccui.ScrollViewDir.vertical)
        selectList:setBounceEnabled(true)
        self.mSelBgSprite:addChild(selectList)

        local function checkCallBack ( i )
            if self.mSelectStatus[i] then
                self.mSelectStatus[i] = false
            else
                self.mSelectStatus[i] = true
            end
            local zjData = self:getZhenJueData()
            -- dump(zjData,"zjData")
            -- 重新设置选择的个数
            refineNum:setString(TR("当前选择分解数量:%s", #zjData))
            -- 确定分解按钮
            okButton:setClickAction(function()
                if #zjData == 0 then
                    ui.showFlashView(TR("您当前没有内功心法可分解，快去获取吧！"))
                    return
                end
                -- 调用分解接口
                self:requestZhenJueRefine(zjData)

                -- 关闭当前框框
                local callfunDelete = cc.CallFunc:create(function()
                    if self.mSelBgSprite then
                        self.mSelBgSprite:removeFromParent()
                        self.mSelBgSprite = nil
                    end
                end)
                local callfunCT = cc.CallFunc:create(function()
                    pSender:setEnabled(true)
                    touchLayer:removeFromParent()
                end)
                local scale = cc.ScaleTo:create(0.3, 1)
                showAction = cc.Sequence:create(scale, callfunDelete, callfunCT)
                self.mSelBgSprite:runAction(showAction)
            end)
        end

        for i = 1, #self.mSelectStatus do
            local layout = ccui.Layout:create()
            layout:setContentSize(bgSize.width, 22)
            local cellSprite = ui.newScale9Sprite("zl_09.png", cc.size(95, 20))
            cellSprite:setPosition(bgSize.width/2, 11)
            layout:addChild(cellSprite)
            local color = Utility.getColorValue(i, 1)
            local checkBtn = ui.newCheckbox({
                text = TR("%s品质",Utility.getColorName(i)),
                isRevert = true,
                textColor = color,
                outlineColor = Enums.Color.eBlack,
                outlineSize = 2,
                callback = function(pSenderC)
                    checkCallBack (i)
                end
                })
            checkBtn:setPosition(bgSize.width/2, 11)
            layout:addChild(checkBtn)
            checkBtn:setCheckState(self.mSelectStatus[i])
            checkBtn:setScale(0.5)
            -- 透明按钮
            local touchBtn = ui.newButton({
                normalImage = "c_83.png",
                size = cc.size(95, 20),
                clickAction = function()
                    checkCallBack(i)
                    checkBtn:setCheckState(self.mSelectStatus[i])
                end
            })
            touchBtn:setPosition(bgSize.width/2, 11)
            cellSprite:addChild(touchBtn)
            selectList:pushBackCustomItem(layout)
        end
    end

    self.mSelBgSprite:runAction(showAction)
end

-- 获取选择对应品质的装备数据
function RefineLayer:getItemData()
    local equipData = clone(EquipObj:getEquipList({isRefine = true}))
    -- 排出主角套装
    local tempList = {}
    for i, equipInfo in pairs(equipData) do
        if EquipModel.items[equipInfo.ModelId].ifLead ~= 1 then
            table.insert(tempList, equipInfo)
        end
    end
    equipData = tempList

    local selectColor = {}
    for i,v in ipairs(self.mSelectStatus) do
        if v then
            table.insert(selectColor, i)
        end
    end
    local finalList = {}
    if next(selectColor) == nil then
        -- 说明没有选择
    else
        for _,v in ipairs(equipData) do
            local colorLv = Utility.getQualityColorLv(EquipModel.items[v.ModelId].quality)
            for m,n in ipairs(selectColor) do
                if n == colorLv then
                    table.insert(finalList, v)
                end
            end
        end
    end
    return finalList
end

-- 获取选择对应品质的内功数据
function RefineLayer:getZhenJueData()
    local zjData = clone(ZhenjueObj:getZhenjueList({isResolve = true}))
    local selectColor = {}
    for i,v in ipairs(self.mSelectStatus) do
        if v then
            table.insert(selectColor, i)
        end
    end
    local finalList = {}
    if next(selectColor) == nil then
        -- 说明没有选择
    else
        for _,v in ipairs(zjData) do
            local colorLv = ZhenjueModel.items[v.ModelId].colorLV
            for m,n in ipairs(selectColor) do
                if n == colorLv then
                    table.insert(finalList, v)
                end
            end
        end
    end
    return finalList
end

-- 分解时物品掉落和音效
function RefineLayer:resolveEffect(value)
    MqAudio.playEffect("renwu_shengji.mp3")
    local once = true
    for index, item in pairs(self.mSelectList)  do
        local tempData = self.mSelectList[index]
        if tempData and Utility.isEntityId(tempData.Id) then
            self.mSelectList[index] = nil
            --table.remove(self.mSelectList, i)
            self.decompose:setEnabled(false)
            local effect = ui.newEffect({
                parent = self,
                effectName = "effect_ui_fenjie",
                position = self.mCardPos[index],
                loop = false,
                endRelease = true,
                endListener = function()
                    if once then
                        once = false
                        local callback = function()
                            MsgBoxLayer.addGameDropLayer(value.Value.BaseGetGameResourceList, {}, TR("获得以下物品"), TR("奖励"), {{text = TR("确定")}}, {})
                            self.decompose:setEnabled(true)
                            self:refreshSlot()
                        end
                        self:resolveEff(callback)
                    end
                end,
            })
        end
    end
    self.mSelectList = {}
    self:refreshSlot()
end

-- 分解特效
function RefineLayer:resolveEff(callback)
    MqAudio.playEffect("renwu_fenjie.mp3")

    ui.newEffect({
        parent = self,
        effectName = "effect_ui_renwufenjie",
        animation = "fenji",
        position = cc.p(320, 568),
        loop = false,
        endRelease = true,
        endListener = function()
            callback()
        end
    })
end

------------------------------网络请求--------------------------------------
-- 分解人物
function RefineLayer:requestHeroRefine()
    -- 组织服务区接口请求数据
    local tempList = {}
    local ret = {}
    for _, item in pairs(self.mSelectList) do
        table.insert(tempList, item.Id)
    end

    HttpClient:request({
        moduleName = "Hero",
        methodName = "HeroRefine",
        svrMethodData = {tempList},
        callback = function(response)
            if response.Status ~= 0 then
                return
            end
            -- 从缓存对象中删除被分解的人物
            HeroObj:deleteHeroItems(self.mSelectList)
            self:resolveEffect(response)
            self.mSelectList = {}
            self:refreshSlot()
        end
    })
    return ret
end

-- 分解神兵
function RefineLayer:requestTreasureRefine()
    -- 组织服务区接口请求数据
    local tempList = {}
    for _, item in pairs(self.mSelectList) do
        table.insert(tempList, item.Id)
    end
    HttpClient:request({
        moduleName = "Treasure",
        methodName = "TreasureRefine",
        svrMethodData = {tempList},
        callback = function(response)
            if response.Status ~= 0 then
                return
            end
            -- 从缓存对象中删除被分解的人物
            TreasureObj:deleteTreasureItems(self.mSelectList)
            self:resolveEffect(response)
            self.mSelectList = {}
            self:refreshSlot()

        end
    })
end

-- 分解外功
function RefineLayer:requestPetRefine()
    -- 组织服务区接口请求数据
    local tempList = {}
    for _, item in pairs(self.mSelectList) do
        table.insert(tempList, item.Id)
    end
    HttpClient:request({
        moduleName = "Pet",
        methodName = "PetRefine",
        svrMethodData = {tempList},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
			dump(response, "分解外功获得：")
            -- 从缓存对象中删除被分解的外功
			PetObj:deletePetItems(self.mSelectList)
            self:resolveEffect(response)
            self.mSelectList = {}
            self:refreshSlot()

        end
    })
end

-- 分解装备
    -- equipData:只有一键分解的时候才会传
function RefineLayer:requestEquipRefine(equipData)
    -- 组织服务区接口请求数据
    local tempList = {}
    local refineList = {}
    if equipData then
        refineList = equipData
    else
        refineList = self.mSelectList
    end
    for _, item in pairs(refineList) do
        table.insert(tempList, item.Id)
    end
    HttpClient:request({
        moduleName = "Equip",
        methodName = "EquipDecompose",
        svrMethodData = {tempList},
        callback = function(response)
            if response.Status ~= 0 then
                return
            end
            -- 从缓存对象中删除被分解的装备
            EquipObj:deleteEquipItems(refineList)

            -- 如果是一键分解装备的时候直接显示特效效果
            if equipData then
                self.decompose:setEnabled(false)
                MqAudio.playEffect("renwu_fenjie.mp3")
                local effect = ui.newEffect({
                    parent = self,
                    effectName = "effect_ui_renwufenjie",
                    animation = "fenji",
                    position = cc.p(320, 568),
                    loop = false,
                    endRelease = true,
                    endListener = function()
                        -- 判断是否需要提示兑换
                        self:exchangeNoticeMsg(true)
                        -- 弹出奖励内容
                        self.decompose:setEnabled(true)
                        MsgBoxLayer.addGameDropLayer(response.Value.BaseGetGameResourceList, {}, TR("获得以下物品"), TR("奖励"), {{text = TR("确定")}}, {})
                    end
                })
            else
                self:resolveEffect(response)
            end
            self.mSelectList = {}
            self:refreshSlot()
        end
    })
end

-- 分解内功心法
-- zjData:只有一键分解的时候才会传
function RefineLayer:requestZhenJueRefine(zjData)
    -- 组织服务区接口请求数据
    local tempList = {}
    local refineList = {}
    if zjData then
        refineList = zjData
    else
        refineList = self.mSelectList
    end
    for _, item in pairs(refineList) do
        table.insert(tempList, item.Id)
    end
    HttpClient:request({
        moduleName = "Zhenjue",
        methodName = "ZhenjueRefine",
        svrMethodData = {tempList},
        callback = function(response)
            if response.Status ~= 0 then
                return
            end
            -- 从缓存对象中删除被分解的内功
            ZhenjueObj:deleteZhenjueItems(refineList)
            if zjData then
                self.decompose:setEnabled(false)
                local callback = function()
                    -- 判断是否需要提示兑换
                    self:exchangeNoticeMsg(false)
                    -- 弹出分解内容
                    self.decompose:setEnabled(true)
                    MsgBoxLayer.addGameDropLayer(response.Value.BaseGetGameResourceList, {}, TR("获得以下物品"), TR("奖励"), {{text = TR("确定")}}, {})
                end
                self:resolveEff(callback)
            else
                self:resolveEffect(response)
            end
            self.mSelectList = {}
            self:refreshSlot()
        end
    })
end

-- 分解珍兽
function RefineLayer:requestZhenshouRefine(zsData)
    -- 组织服务区接口请求数据
    local tempList = {}
    local refineList = {}
    if zsData then
        refineList = zsData
    else
        refineList = self.mSelectList
    end
    for _, item in pairs(refineList) do
        table.insert(tempList, item.Id)
    end
    HttpClient:request({
        moduleName = "Zhenshou",
        methodName = "Decompose",
        svrMethodData = {tempList},
        callback = function(response)
            if response.Status ~= 0 then
                return
            end
            -- 从缓存对象中删除被分解的内功
            ZhenshouObj:deleteZhenshouItems(refineList)
            if zsData then
                self.decompose:setEnabled(false)
                local callback = function()
                    -- 判断是否需要提示兑换
                    -- self:exchangeNoticeMsg(false)
                    -- 弹出分解内容
                    self.decompose:setEnabled(true)
                    MsgBoxLayer.addGameDropLayer(response.Value.BaseGetGameResourceList, {}, TR("获得以下物品"), TR("奖励"), {{text = TR("确定")}}, {})
                end
                self:resolveEff(callback)
            else
                self:resolveEffect(response)
            end
            self.mSelectList = {}
            self:refreshSlot()
        end
    })
end

-- 人物一键分解网络请求
function RefineLayer:oneKeyRefineInterface(qualityLv)
    HttpClient:request({
        moduleName = "Hero",
        methodName = "OneKeyHeroRefine",
        svrMethodData = {qualityLv},
        callback = function(data)
        --dump(data, "OneKeyHeroRefineInfo", 10)
            -- 返回数据不为空，即炼化的人物不为空时，得到获得的资源
            if data.Status ~= 0 then
                return
            end
            local callback = function()
                MsgBoxLayer.addGameDropLayer(data.Value.BaseGetGameResourceList, {}, TR("获得以下物品"), TR("奖励"), {{text = TR("确定")}}, {})
            end
            self:resolveEff(callback)

            local list = {}
            for _, v in ipairs(HeroObj:getHeroList()) do
                -- 手动删掉缓存中4星以下英雄
                if HeroModel.items[v.ModelId].quality <= qualityLv and tonumber(v.Step) == 0 then
                    -- 排除掉上阵英雄
                    if not FormationObj:heroInFormation(v.Id) then
                        table.insert(list, v)
                    end
                    -- 删除掉已经选中的人物当中4星以下的
                    for index, item in pairs(self.mSelectList) do
                        if item and item.Id == v.Id then
                            self.mSelectList[index] = nil
                            --table.remove(self.mSelectList, i)
                            break
                        end
                    end
                    --TODO
                    -- for i, h in ipairs(self.mCardNodeList) do
                    --     if h.data and h.data.Id == v.Id then
                    --         h.data = nil
                    --         break
                    --     end
                    -- end
                end
            end
            self:refreshSlot()
            HeroObj:deleteHeroItems(list)
        end
    })
end

-- 阵诀一键分解
function RefineLayer:oneKeyRefineZhenJueInterface()
    HttpClient:request({
        moduleName = "Zhenjue",
        methodName = "OneKeyZhenjueRefine",
        svrMethodData = {},
        callback = function(data)
            -- 返回数据不为空，即炼化的阵诀不为空时，得到获得的资源
            if data.Status ~= 0 then
            --    ui.showFlashView(TR("需要绿色及绿色以下品质阵诀才能一键分解"))
                return
            end
            local callback = function()
                MsgBoxLayer.addGameDropLayer(data.Value.BaseGetGameResourceList, {}, TR("获得以下物品"), TR("奖励"), {{text = TR("确定")}}, {})
            end
            self:resolveEff(callback)
            local list = {}
            for _, v in ipairs(ZhenjueObj:getZhenjueList()) do
                if ZhenjueModel.items[v.ModelId].colorLV <= 2 then
                    local isIn, _ = FormationObj:zhenjueInFormation(v.Id)
                    if not isIn then
                        table.insert(list, v)
                    end
                    -- 删除掉已经选中的阵诀当中2星以下的
                    for index, item in pairs(self.mSelectList) do
                        if item.Id == v.Id then
                            self.mSelectList[index] = nil
                            --table.remove(self.mSelectList, i)
                            break
                        end
                    end
                end
            end
            self:refreshSlot()
            ZhenjueObj:deleteZhenjueItems(list)
        end
    })
end

-- 兑换提示框
-- isEquip: 是否是装备
function RefineLayer:exchangeNoticeMsg(isEquip)
    local usedCountList = {0, 0}
    local localCount = 0
    local dbImageName = ""
    if isEquip then
        localCount = PlayerAttrObj:getPlayerAttrByName("Merit")
        for i,tabOrder in ipairs({2, 3}) do
            -- 获取紫色和橙色合成需要的：碎片数*兑换值
            for _,v in pairs(BddEquipExchangeRelation.items) do
                if v.tabOrder == tabOrder and not string.find(v.price, "||") then
                    local needInfo = Utility.analysisStrResList(v.price)[1]
                    -- dump(needInfo, ‘needInfo)
                    dbImageName = Utility.getDaibiImage(needInfo.resourceTypeSub, 0)
                    print(dbImageName, "dbImageName")
                    local goodsInfo = Utility.analysisStrResList(v.sellResource)[1]
                    if goodsInfo.resourceTypeSub == ResourcetypeSub.eEquipmentDebris then
                        usedCountList[i] = needInfo.num * GoodsModel.items[goodsInfo.modelId].maxNum
                        break
                    end
                end
            end
        end
    else
        localCount = Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, 16050023)
        dbImageName = Utility.getDaibiImage(ResourcetypeSub.eFunctionProps, 16050023)
        for i,tabOrder in ipairs({2, 3}) do
            -- 获取紫色和橙色合成需要的：碎片数*兑换值
            for _,v in pairs(TeambattleShopModel.items) do
                if v.tab == tabOrder then
                    local goodsInfo = Utility.analysisStrResList(v.outResource)[1]
                    if goodsInfo.resourceTypeSub == ResourcetypeSub.eNewZhenJueDebris then
                        usedCountList[i] = v.needTeamBattleCoins * GoodsModel.items[goodsInfo.modelId].maxNum
                        break
                    end
                end
            end
        end
    end
    local isNotPurple = LocalData:getGameDataValue(savedName)
    -- 如数量不足，则不创建提示框
    if (isNotPurple and localCount < usedCountList[2]) or (not isNotPurple and localCount < usedCountList[1]) then
        return
    end

    LayerManager.addLayer({
        name = "disassemble.DlgExchangeNoticeLayer",
        data = {isEquip = isEquip, usedCountList = usedCountList, localCount = localCount, dbImageName = dbImageName},
        cleanUp = false,
    })
end

return RefineLayer
