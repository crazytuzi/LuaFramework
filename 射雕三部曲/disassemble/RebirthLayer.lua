--[[

	文件名：RebirthLayer.lua
	描述：炼化功能重生页面
	创建人：yanxingrui
    修改人：lengjiazhi
	创建时间： 2016.4.19

--]]

local RebirthLayer = class("RebirthLayer", function(params)
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
function RebirthLayer:ctor(params)

	self.viewLayer = nil

    -- 当前选中物品的类型
    self.mResourcetype = params and params.resourcetype
    -- 当前选中的物品数据列表
    self.mSelectList = params and params.selectList or {}

    self:initUI()

end

function RebirthLayer:getRestoreData()
    local retData = {}
    retData.selectList = self.mSelectList
    retData.resourcetype = self.mResourcetype

    return retData
end

-- 初始化界面
function RebirthLayer:initUI()
	self.mSelectKeys = table.keys(self.mSelectList)
	if #self.mSelectKeys > 0 then
		if #self.mSelectKeys == 1 then
			self:afterLayer(self.mSelectList)
		else
			self:moreRebirthLayer(self.mSelectList)
		end
		return
	end

    self.viewLayer = ui.newSprite("zl_01.jpg")
    self.viewLayer:setPosition(320, 568)
    self:addChild(self.viewLayer)

    -- 聚宝阁
	local mysteryShopButton = ui.newButton({
		normalImage = "tb_25.png",
		clickAction = function()
			LayerManager.addLayer({name = "mysteryshop.MysteryShopLayer"})
		end,
		position = cc.p(565, 880)
	})
	self.viewLayer:addChild(mysteryShopButton)

    -- 黑色剪影
    local shadowSprite = ui.newSprite("c_36.png")
    shadowSprite:setPosition(320, 590)
    self.viewLayer:addChild(shadowSprite)

	-- 选择人物
	local chooseButton = ui.newButton({
		normalImage = "c_22.png",
        scale = 1.5,
		clickAction = function()
            local tempLayer
			tempLayer = LayerManager.addLayer({
				name = "commonLayer.SelectLayer",
				data = {
                    selectType = Enums.SelectType.eRebirth,
                    --resourcetypeSub = self.mResourcetype,
                    oldSelList = self.mSelectList,
                    callback = function(selectLayer, selectItemList, resourcetype)
                        local tempStr = "disassemble.DisassembleLayer"
                        local tempData = LayerManager.getRestoreData(tempStr)
                        tempData.rebirth = tempData.rebirth or {}
                        tempData.rebirth.resourcetype = resourcetype
                        tempData.rebirth.selectList = selectItemList
                        tempData.currTag = Enums.DisassemblePageType.eRebirth
                        LayerManager.setRestoreData(tempStr, tempData)

                        -- 删除选择页面
                        LayerManager.removeLayer(selectLayer)
                    end
                },
			})
		end,
	})
    local tempSize = chooseButton:getContentSize()
    local tempSprite = ui.createGlitterSprite({
        filename = "c_22.png",
        parent = chooseButton,
        position = cc.p(tempSize.width / 2, tempSize.height / 2),
        actionScale = 1.2,
    })
    chooseButton:setPosition(320, 620)
	self.viewLayer:addChild(chooseButton)

    local bgSprite2 = ui.newScale9Sprite("c_25.png", cc.size(550, 50))
    local str = TR("点击放入需要重生的#95ea50侠客/装备/神兵/内功/外功")
    -- if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eZhenjue) then
    --     str = str.."/阵决"
    -- end
    local lab2 = ui.newLabel({
        text = str,
        color = cc.c3b(0xff, 0xfb, 0xde),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        size = 24,
    })
    bgSprite2:setPosition(320, 280)
    self:addChild(bgSprite2)
    lab2:setPosition(320, 280)
    self:addChild(lab2)

    -- 重生
    local rebirthButton = ui.newButton({
        normalImage = "c_28.png",
        text = TR("重生"),
        clickAction = function()
            ui.showFlashView(str, 1.0)
        end,
    })
    rebirthButton:setPosition(320, 180)
    self.rebirthButton = rebirthButton
    self.viewLayer:addChild(rebirthButton)


    -- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 1),
        position = cc.p(60, 957),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.点击加号可以选择自动放入物品"),
                [2] = TR("2.一次最多可以选择6种同类物品"),
                [3] = TR("3.重生内功，返还80%的资源"),
                [4] = TR("4.重生侠客/装备/外功，返还全部资源"),
            })
        end})
    self.viewLayer:addChild(ruleBtn, 1)
end

-- 选择重生物品后新绘制的界面
--[[
    params:
    item:选择的人物
]]--

function RebirthLayer:afterLayer(dataList)
	local theChooseOne = {}
	for _, item in pairs(dataList) do
		theChooseOne = item
	end

    -- 金钱
    self:calcCostRes({theChooseOne})

    self.viewLayer2 = ui.newSprite("zl_01.jpg")
    self.viewLayer2:setPosition(320, 568)
	self:addChild(self.viewLayer2)

    -- 聚宝阁
    local mysteryShopButton = ui.newButton({
        normalImage = "tb_25.png",
        clickAction = function()
            LayerManager.addLayer({name = "mysteryshop.MysteryShopLayer"})
        end,
        position = cc.p(565, 880)
    })
    self.viewLayer2:addChild(mysteryShopButton)

    -- 名字
    local nameStr, qualityName = self:refreshNameData(theChooseOne)
	-- 创建星星
    local starLev = nil
    if Utility.isZhenjue(resType) then
        starLev = qualityName.colorLV
    elseif not Utility.isHero(resType) then
        starLev = Utility.getQualityColorLv(qualityName.quality)
    end
    _, _, self.nameLabel = Figure.newNameAndStar({
        parent = self.viewLayer2,
        position = cc.p(320, 980),
        nameText = nameStr,
        starCount = starLev,
        })

	-- 图
	if self.mResourcetype == Resourcetype.eHero then
		local hero = Figure.newHero({
			heroModelID = theChooseOne.modelId,
            IllusionModelId = theChooseOne.IllusionModelId,
			position = cc.p(320, 360),
			scale = 0.31,
            needRace = true,
			buttonAction = function()
                self.mSelectList = {}
                self.mResourcetype = nil
                if self.viewLayer2 then
                    self.viewLayer2:removeFromParent()
                    self.viewLayer2 = nil
                end
                self:initUI()
			end,
		})
        self.viewLayer2:addChild(hero)
    elseif self.mResourcetype == Resourcetype.eEquipment then
        local pic = Figure.newEquip({
            modelId = theChooseOne.modelId,
            clickCallback = function()
                self.mSelectList = {}
                self.mResourcetype = nil
                if self.viewLayer2 then
                    self.viewLayer2:removeFromParent()
                    self.viewLayer2 = nil
                end
                self:initUI()
            end,
        })
        pic:setAnchorPoint(cc.p(0.5, 0))
        pic:setPosition(320, 360)
        self.viewLayer2:addChild(pic)
    elseif self.mResourcetype == Resourcetype.eTreasure then
        local pic = Figure.newTreasure({
            modelId = theChooseOne.modelId,
            clickCallback = function()
                self.mSelectList = {}
                self.mResourcetype = nil
                if self.viewLayer2 then
                    self.viewLayer2:removeFromParent()
                    self.viewLayer2 = nil
                end
                self:initUI()
            end,
        })
        pic:setAnchorPoint(cc.p(0.5, 0))
        pic:setPosition(320, 360)
        self.viewLayer2:addChild(pic)
    elseif self.mResourcetype == Resourcetype.eNewZhenJue then
        local pic = Figure.newZhenjue({
            modelId = theChooseOne.modelId,
            clickCallback = function()
                self.mSelectList = {}
                self.mResourcetype = nil
                self.viewLayer2:removeFromParent()
                self:initUI()
            end,
        })
        pic:setAnchorPoint(cc.p(0.5, 0))
        pic:setPosition(320, 360)
        self.viewLayer2:addChild(pic)
    elseif self.mResourcetype == Resourcetype.ePet then
        local pic = Figure.newPet({
            modelId = theChooseOne.modelId,
            clickCallback = function()
                self.mSelectList = {}
                self.mResourcetype = nil
                self.viewLayer2:removeFromParent()
                self:initUI()
            end,
        })
        pic:setAnchorPoint(cc.p(0.5, 0))
        pic:setPosition(320, 360)
        self.viewLayer2:addChild(pic)
    elseif self.mResourcetype == Resourcetype.eZhenshou then
        local pic = Figure.newZhenshou({
            modelId = theChooseOne.modelId,
            clickCallback = function()
                self.mSelectList = {}
                self.mResourcetype = nil
                self.viewLayer2:removeFromParent()
                self:initUI()
            end,
        })
        pic:setAnchorPoint(cc.p(0.5, 0))
        pic:setPosition(320, 260)
        self.viewLayer2:addChild(pic)
	end

    -- 代币
    self.coinNode, self.coinLabel = ui.createDaibiView({
    	resourceTypeSub = ResourcetypeSub.eDiamond,
        number = self.mDiamond,
        fontColor = Enums.Color.eWhite,
    })
    self.coinNode:setPosition(320, 280)
    self.coinNode:setAnchorPoint(cc.p(0.5, 0.5))
    self.viewLayer2:addChild(self.coinNode)

    local bgSprite3 = ui.newScale9Sprite("c_25.png", cc.size(640, 50))
    local lab3 = ui.newLabel({
        text = TR("重生可使目标退回初始状态，并返还培养消耗"),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        color = Enums.Color.eWhite,
    })
    bgSprite3:setPosition(320, 160)
    self.viewLayer2:addChild(bgSprite3)
    lab3:setPosition(320, 160)
    self.viewLayer2:addChild(lab3)

    -- 重生
    local rebirthButton = ui.newButton({
        normalImage = "c_28.png",
        text = TR("重生"),
        position = cc.p(320, 220),
        clickAction = function (btnObj)
            self:onRebirthClick(btnObj, theChooseOne)
        end,
    })
    self.rebirthButton = rebirthButton
    self.viewLayer2:addChild(rebirthButton)

    -- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 1),
        position = cc.p(60, 957),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.点击加号可以选择自动放入物品"),
                [2] = TR("2.一次最多可以选择6种同类物品"),
                [3] = TR("3.重生内功，返还80%的资源"),
                [4] = TR("4.重生侠客/装备/外功，返还全部资源"),
            })
        end})
    self.viewLayer2:addChild(ruleBtn, 1)
end

function RebirthLayer:refreshNameData(theChooseOne, nameLabel)
    if not theChooseOne or not Utility.isEntityId(theChooseOne.Id) then
        return
    end
    
    local nameStr
    local qualityName
    local colorlv
    local illusionModel
    local resType = Utility.getTypeByModelId(theChooseOne.ModelId)
    if Utility.isHero(resType) then
        qualityName = HeroModel.items[theChooseOne.ModelId]
        illusionModel = IllusionModel.items[theChooseOne.IllusionModelId]
        colorlv = Utility.getQualityColorLv(qualityName.quality)
    elseif Utility.isEquip(resType) then
        qualityName = EquipModel.items[theChooseOne.ModelId]
        colorlv = Utility.getQualityColorLv(qualityName.quality)
    elseif Utility.isTreasure(resType) then
        qualityName = TreasureModel.items[theChooseOne.ModelId]
        colorlv = Utility.getQualityColorLv(qualityName.quality)
    elseif Utility.isZhenjue(resType) then
        qualityName = ZhenjueModel.items[theChooseOne.ModelId]
        colorlv = qualityName.colorLV
    elseif Utility.isPet(resType) then
        qualityName = PetModel.items[theChooseOne.ModelId]
        nameColor = qualityName.valueLv
    elseif Utility.isZhenshou(resType) then
        qualityName = ZhenshouModel.items[theChooseOne.ModelId]
        nameColor = qualityName.colorLv
    end
	-- 重置对象的信息
    local nameColor = Utility.getColorValue(colorlv, 2)
    local oneStep = theChooseOne.Step or ((theChooseOne.TotalNum or 0) - (theChooseOne.CanUseTalNum or 0))
    if theChooseOne.Lv == nil then
        nameStr = string.format("%s%s", nameColor, illusionModel and illusionModel.name or qualityName.name)
        if (oneStep > 0) then
            nameStr = nameStr .. "+" .. oneStep
        end
    elseif oneStep == 0 then
        nameStr = Enums.Color.eYellowH .. TR("等级%d %s%s", theChooseOne.Lv, nameColor, illusionModel and illusionModel.name or qualityName.name)
    elseif oneStep > 0 then
        nameStr = Enums.Color.eYellowH .. TR("等级%d %s%s%s +%d", theChooseOne.Lv, nameColor, illusionModel and illusionModel.name or qualityName.name, Enums.Color.eWhiteH, oneStep)
    end
	if not tolua.isnull(nameLabel) then
		nameLabel:setString(nameStr)
	end
    return nameStr, qualityName
end

-- 重生时播放音效
function RebirthLayer:rebirthEffect(value)
    -- 禁用重生按钮
    self.rebirthButton:setEnabled(false)
    local array = {}
    table.insert(array, cc.CallFunc:create(function()
        local di = ui.newEffect({
            parent = self,
            effectName = "effect_ui_renwuchongsheng",
            animation = "shang",
            position = cc.p(320, 370),
            loop = false,
            endRelease = true,
        })
    end))
    table.insert(array, cc.DelayTime:create(0.2))
    table.insert(array, cc.CallFunc:create(function()
		MqAudio.playEffect("hero_chongsheng.mp3", false)
        local hou = ui.newEffect({
            parent = self,
            effectName = "effect_ui_renwuchongsheng",
            animation = "xia",
            position = cc.p(320, 330),
            loop = false,
            endRelease = true,
            completeListener = function()
            	MsgBoxLayer.addGameDropLayer(value.Value.BaseGetGameResourceList, {}, TR("获得以下物品"), TR("重生"), {{text = TR("确定")}}, {})
                if not tolua.isnull(self) then
                    if self.viewLayer2 and not tolua.isnull(self.viewLayer2) then
                        self.viewLayer2:removeFromParent()
                        self.viewLayer2 = nil
                    end
                    self:initUI()
                    self.rebirthButton:setEnabled(true)
                end
            end,
        })
    end))
    MqAudio.playEffect("hero_chongsheng.mp3")
    self:runAction(cc.Sequence:create(array))
end

function RebirthLayer:moreRebirthLayer(dataList)
    -- 背景
    self.viewLayer3 = ui.newSprite("zl_01.jpg")
    self.viewLayer3:setPosition(320, 568)
    self:addChild(self.viewLayer3)

    -- 珍宝阁
    local mysteryShopButton = ui.newButton({
        normalImage = "tb_25.png",
        clickAction = function()
            LayerManager.addLayer({name = "mysteryshop.MysteryShopLayer"})
        end,
        position = cc.p(565, 880)
    })
    self.viewLayer3:addChild(mysteryShopButton)

    -- 代币
    local coinNode, coinLabel = ui.createDaibiView({
        resourceTypeSub = ResourcetypeSub.eDiamond,
        number = 0,
        fontColor = Enums.Color.eWhite,
    })
    coinNode:setPosition(320, 270)
    coinNode:setAnchorPoint(cc.p(0.5, 0.5))
    self.viewLayer3:addChild(coinNode)
    self.mCoinNode = coinNode

    -- 描述
    local tipsLabel = ui.createSpriteAndLabel({
        imgName = "c_25.png",
        scale9Size = cc.size(640, 53),
		labelStr = TR("重生可使目标退回初始状态，并返还所有培养消耗"),
		fontColor = Enums.Color.eWhite,
    })
    tipsLabel:setPosition(320, 160)
    self.viewLayer3:addChild(tipsLabel)
	self:createGoodsBorder(dataList)

    -- 消耗的资源
    self:calcCostRes(dataList)
    self.mCoinNode.setNumber(self.mDiamond)

    -- 重生
    local rebirthButton = ui.newButton({
        normalImage = "c_28.png",
        text = TR("重生"),
        position = cc.p(320, 220),
        clickAction = function (btnObj)
            self:onRebirthClick(btnObj, self.mSelectList, true)
        end,
    })
    self.viewLayer3:addChild(rebirthButton)
    self.mMoreRebirthBtn = rebirthButton

    -- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 1),
        position = cc.p(60, 957),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.点击加号可以选择自动放入物品"),
                [2] = TR("2.一次最多可以选择6种同类物品"),
                [3] = TR("3.重生内功，返还80%的资源"),
                [4] = TR("4.重生侠客/装备/外功，返还全部资源"),
            })
        end})
    self.viewLayer3:addChild(ruleBtn, 1)
end

-- 创建存放物品的背景框
function RebirthLayer:onRebirthClick(btnObj, dataList, isSelecks)
    btnObj:setEnabled(false)
    if not Utility.isResourceEnough(ResourcetypeSub.eDiamond, self.mDiamond) then
        btnObj:setEnabled(true)
        return
    end
    if self.mResourcetype == Resourcetype.eHero then
        self:rebirthRequest("Hero", "HeroRebirth", dataList, isSelecks)
    elseif self.mResourcetype == Resourcetype.eEquipment then
        self:rebirthRequest("Equip", "EquipRebirth", dataList, isSelecks)
    elseif self.mResourcetype == Resourcetype.eTreasure then
        self:rebirthRequest("Treasure", "TreasureRebirth", dataList, isSelecks)
    elseif self.mResourcetype == Resourcetype.eNewZhenJue then
        self:rebirthRequest("Zhenjue", "ZhenjueRebirth", dataList, isSelecks)
    elseif self.mResourcetype == Resourcetype.ePet then
        self:rebirthRequest("Pet", "PetRebirthByOneKey", dataList, isSelecks)
    elseif self.mResourcetype == Resourcetype.eZhenshou then
        self:rebirthRequest("Zhenshou", "Rebirth", dataList, isSelecks)
    end
end

-- 创建存放物品的背景框
function RebirthLayer:createGoodsBorder(dataList)
	-- 控件位置
	local CenterPosX = 320
	local CenterPosY = 550
	local Radius = 230
    self.mSelectCards = {}
    -- local len = table.maxn(dataList)
    local len = #self.mSelectKeys
    local angle = 2 * math.pi / len
    local theta = math.pi / 2 + (len + 1) % 2 * angle / 2

    for index, item in pairs(dataList) do
        -- 坐标系转换
        x = Radius * math.cos(theta) + CenterPosX
        y = Radius * math.sin(theta) + CenterPosY

        local tempCard
        tempCard = CardNode.createCardNode({
            allowClick = true,
            onClickCallback = function ()
                local tempData = dataList[index]
                if tempData and Utility.isEntityId(tempData.Id) then
                    self.mSelectList[index] = nil
                    tempCard:setEmpty({}, "c_04.png", nil)

                    local tempSize = tempCard:getContentSize()
                    local tempSprite = ui.createGlitterSprite({
                        filename = "c_22.png",
                        parent = tempCard,
                        position = cc.p(tempSize.width / 2, tempSize.height / 2),
                        actionScale = 1.2,
                    })

                    self:calcCostRes(self.mSelectList)
                    self.mCoinNode.setNumber(self.mDiamond)

                    if table.maxn(self.mSelectList) == 0 then
                        self.mMoreRebirthBtn:setEnabled(false)
                    else
                        self.mMoreRebirthBtn:setEnabled(true)
                    end
                    return
                end

                local tempData = {
                    selectType = Enums.SelectType.eRebirth,
                    oldResourcetype = self.mResourcetype,
                    oldSelList = self.mSelectList or {},
                    callback = function(selectLayer, selectItemList, resourcetype)
                        local tempStr = "disassemble.DisassembleLayer"
                        local tempData = LayerManager.getRestoreData(tempStr)
                        tempData.rebirth = tempData.rebirth or {}
                        tempData.rebirth.resourcetype = resourcetype
                        tempData.rebirth.selectList = selectItemList
                        tempData.currTag = Enums.DisassemblePageType.eRebirth
                        LayerManager.setRestoreData(tempStr, tempData)

                        -- 删除装备选择页面
                        LayerManager.removeLayer(selectLayer)
                    end
                }
                LayerManager.addLayer({
                    name = "commonLayer.SelectLayer",
                    data = tempData,
                })
            end,
        })
        local showAttrs = {CardShowAttr.eBorder, CardShowAttr.eLevel, CardShowAttr.eStep}
        if self.mResourcetype == Resourcetype.eHero then
            tempCard:setHero(item, showAttrs)
        elseif self.mResourcetype == Resourcetype.eEquipment then
            tempCard:setEquipment(item, showAttrs)
        elseif self.mResourcetype == Resourcetype.eTreasure then
            tempCard:setTreasure(item, showAttrs)
        elseif self.mResourcetype == Resourcetype.eNewZhenJue then
            tempCard:setZhenjue(item, showAttrs)
        elseif self.mResourcetype == Resourcetype.ePet then
            tempCard:setPet(item, showAttrs)
        elseif self.mResourcetype == Resourcetype.eZhenshou then
            tempCard:setZhenshou(item, showAttrs)
        end
        tempCard:setPosition(x, y)
        self.viewLayer3:addChild(tempCard)
        -- 坐标递进
        theta = theta - angle

        table.insert(self.mSelectCards, tempCard)
    end
end

-- 计算重生需要消耗的资源
function RebirthLayer:calcCostRes(dataList)
    -- 金钱
    local diamond = 0
    for _, item in pairs(dataList) do
        if self.mResourcetype == Resourcetype.eHero then
            item.modelId = item.ModelId
            local rebirthInfo = HeroRebirthRelation.items[HeroModel.items[item.ModelId].quality]
            local stepPoor = item.Step - IllusionConfig.items[1].illusionStepNeedHeroStep
            diamond = diamond + rebirthInfo[stepPoor > 0 and IllusionConfig.items[1].illusionStepNeedHeroStep or item.Step].useDiamond

            -- 突破超过20
            -- 在这儿强行认为该资源为元宝
            local resInfo = Utility.analysisStrResList(IllusionConfig.items[1].rebirthBaseResources)[1]
            diamond = diamond + (stepPoor > 0 and stepPoor*resInfo.num or 0)

            if item.RebornStep then
                diamond = diamond + rebirthInfo[item.RebornStep].useDiamond
            end
        elseif self.mResourcetype == Resourcetype.eEquipment then
            item.modelId = item.ModelId
            diamond = diamond + EquipRebirthRelation.items[EquipModel.items[item.ModelId].quality][item.Star].useDiamond
        elseif self.mResourcetype == Resourcetype.eTreasure then
            item.modelId = item.ModelId
            diamond = diamond + TreasureRebirthRelation.items[TreasureModel.items[item.ModelId].quality][item.Step].useDiamond
        elseif self.mResourcetype == Resourcetype.eNewZhenJue then
            item.modelId = item.ModelId
            diamond = diamond + ZhenjueRebirthRelation.items[ZhenjueModel.items[item.ModelId].colorLV].useDiamond
        elseif self.mResourcetype == Resourcetype.ePet then
            item.modelId = item.ModelId
            local curDiamond = 0
            local rebirthInfo = PetRebirthRelation.items[PetModel.items[item.ModelId].quality]
            if rebirthInfo then
                -- 重生表里没有对应的资质，则重生不消耗
                local resetTable = {}
                for index, value in pairs(PetRebirthRelation.items[PetModel.items[item.ModelId].quality]) do
                    table.insert(resetTable, value)
                end
                table.sort(resetTable, function(a, b) return a.talTreeNum > b.talTreeNum end)
                for i = 1, #resetTable do
                    if (item.TotalNum - item.CanUseTalNum) >= resetTable[i].talTreeNum then
                        curDiamond = resetTable[i].useDiamond
                        break
                    end
                end
            end
            diamond = diamond + curDiamond
        elseif self.mResourcetype == Resourcetype.eZhenshou then
            item.modelId = item.ModelId
            diamond = diamond + ZhenshouRebirthRelation.items[ZhenshouModel.items[item.ModelId].quality].useDiamond
        end
    end
    self.mDiamond = diamond
end

-- 合成特效
function RebirthLayer:playCompoundEffect(value)
    self.mSwallowLayer = ui.createSwallowLayer()
    self.viewLayer3:addChild(self.mSwallowLayer, 3)

    Utility.performWithDelay(self.viewLayer3, function ()
		local array = {}
	    table.insert(array, cc.CallFunc:create(function()
	        local di = ui.newEffect({
	            parent = self,
	            effectName = "effect_ui_renwuchongsheng",
	            animation = "shang",
	            position = cc.p(320, 370),
	            loop = false,
	            endRelease = true,
	        })
	    end))
	    table.insert(array, cc.DelayTime:create(0.2))
	    table.insert(array, cc.CallFunc:create(function()
			MqAudio.playEffect("hero_chongsheng.mp3", false)
	        local hou = ui.newEffect({
	            parent = self,
	            effectName = "effect_ui_renwuchongsheng",
	            animation = "xia",
	            position = cc.p(320, 330),
	            loop = false,
	            endRelease = true,
	            completeListener = function()
	            	MsgBoxLayer.addGameDropLayer(value.Value.BaseGetGameResourceList, {}, TR("获得以下物品"), TR("重生"), {{text = TR("确定")}}, {})
	                if not tolua.isnull(self) then
	                    if self.viewLayer2 then
	                        self.viewLayer2:removeFromParent()
	                        self.viewLayer2 = nil
	                    end
	                    self:initUI()
	                    self.rebirthButton:setEnabled(true)
	                end
	            end,
	        })
	    end))
	    MqAudio.playEffect("hero_chongsheng.mp3")
	    self:runAction(cc.Sequence:create(array))
    end, 0.9)
end


-------------------------------网络请求---------------------
-- 重生请求
function RebirthLayer:rebirthRequest(module, method, Data, isSelecks)
	local idList
    if self.mResourcetype == Resourcetype.eNewZhenJue then
        idList = Data.Id
    else
        idList = {}
    	if not isSelecks then
    		table.insert(idList, Data.Id)
    	else
    		for _, item in pairs(Data) do
    			table.insert(idList, item.Id)
    		end
    	end
    end
    HttpClient:request({
        moduleName = module,
        methodName = method,
        svrMethodData = {idList},
        callback = function(data)
            if data and data.Status == 0 then
                self.mSelectList = {}

                self:refreshNameData(Data, self.nameLabel)

                if self.mResourcetype == Resourcetype.eHero then
					for _, item in pairs(data.Value.HeroInfo) do
						HeroObj:modifyHeroItem(item)
					end
                elseif self.mResourcetype == Resourcetype.eEquipment then
					for _, item in pairs(data.Value.EquipInfo) do
						EquipObj:modifyEquipItem(item)
					end
                elseif self.mResourcetype == Resourcetype.eTreasure then
					for _, item in pairs(data.Value.TreasureInfo) do
						TreasureObj:modifyTreasureItem(item)
					end
                elseif self.mResourcetype == Resourcetype.eNewZhenJue then
					-- for _, item in pairs(data.Value.ZhenjueInfo) do
						ZhenjueObj:modifyZhenjueItem(data.Value.ZhenjueInfo)
					-- end
                elseif self.mResourcetype == Resourcetype.ePet then
                    for _, item in pairs(data.Value.PetInfo) do
                        PetObj:modifyPetItem(item)
                    end
                elseif self.mResourcetype == Resourcetype.eZhenshou then
                    for _, item in pairs(data.Value.ZhenShouInfo) do
                        ZhenshouObj:modifyZhenshouItem(item)
                    end
                end

				if not isSelecks then
					-- 播放重生特效
					self:rebirthEffect(data)
				else
					-- 播放多个物品重生特效
					self:playCompoundEffect(data)
				end
            end
        end
    })
end

return RebirthLayer
