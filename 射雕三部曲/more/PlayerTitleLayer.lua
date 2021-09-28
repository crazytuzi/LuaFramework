--[[
    文件名: PlayerTitleLayer.lua
    描述：玩家声望页面
    创建人：peiyaoqiang
    创建时间：2018.04.12
--]]

local PlayerTitleLayer = class("PlayerTitleLayer", function(params)
    return display.newLayer()
end)

--[[
--]]
function PlayerTitleLayer:ctor(params)
    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eFormation,
        topInfos = {
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eGold,
            ResourcetypeSub.eVIT,
        }
    })
    self:addChild(topResource, 1)

    -- 页面控件的父对象
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 规则按钮
    local btnRule = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(46, 1040),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                TR("1.名望可提升全体属性，并且会展示专属的标识"),
                TR("2.总战力需要达到指定条件才能提升名望"),
                TR("3.提升名望需要消耗名望道具，可通过魔教入侵拍卖行获得"),
            })
        end
    })
    self.mParentLayer:addChild(btnRule, 1)

    -- 退出按钮
    local btnClose = ui.newButton({
        normalImage = "c_29.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(btnClose, 1)

    -- 初始化页面控件并刷新
    self:initUI()
    self:refreshLayer()
end

-- 初始化页面控件
function PlayerTitleLayer:initUI()
    -- 背景图
    local bgSprite = ui.newSprite("zr_18.jpg")
    bgSprite:setAnchorPoint(cc.p(0.5, 1))
    bgSprite:setPosition(320, 1136)
    self.mParentLayer:addChild(bgSprite)
    
    -- 操作面板
    local ctrlSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 530))
    ctrlSprite:setAnchorPoint(0.5, 0)
    ctrlSprite:setPosition(320, 0)
    self.mParentLayer:addChild(ctrlSprite)
    self.mCtrlSprite = ctrlSprite

    -- 人物名字
    local _, _, nameLabel = Figure.newNameAndStar({
        parent = self.mParentLayer,
        position = cc.p(320, 1120),
    })
    self.mNameLabel = nameLabel
    
    -- 人物大图
    local heroData = HeroObj:getHero(FormationObj:getSlotInfoBySlotId(1).HeroId)
    Figure.newHero({
        parent = self.mParentLayer,
        heroModelID = heroData.ModelId,
        fashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId"),
        IllusionModelId = heroData.IllusionModelId,
        position = cc.p(320, 650),
        scale = 0.25,
        needRace = false,
    })
    
    -- 战力需求
    local fapNeedLabel = ui.newLabel({
        text = "",
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 22
    })
    fapNeedLabel:setPosition(320, 485)
    ctrlSprite:addChild(fapNeedLabel)
    self.fapNeedLabel = fapNeedLabel

    -- 箭头
    local arrowSprite = ui.newSprite("c_67.png")
    arrowSprite:setPosition(315, 368)
    ctrlSprite:addChild(arrowSprite)

    -- 属性框
    local function createAttrNode(pos)
        -- 背景
        local attrNode = ui.newScale9Sprite("c_54.png",cc.size(250, 180))
        attrNode:setAnchorPoint(0.5, 1)
        attrNode:setPosition(pos)
        attrNode.refreshNode = function (target, titleModel, isCurrent)
            target:removeAllChildren()

            -- 是否有配置
            if (titleModel == nil) then
                local errorLabel = ui.newLabel({
                    text = (isCurrent == true) and TR("未激活") or TR("已满级"),
                    size = 30,
                    color = Enums.Color.eRed,
                })
                errorLabel:setPosition(cc.p(125, 75))
                target:addChild(errorLabel)
                return
            end

            -- 标题
            local titleSprite = ui.createTitleNode(titleModel.ID)
            titleSprite:setPosition(125, 160)
            target:addChild(titleSprite)

            -- 属性
            local textColor = (isCurrent == true) and "#258711" or "#C27000"
            local yPosList = {115, 85, 55, 25}
            local attrList = Utility.analysisStrFashionAttrList(titleModel.allAttr)
            for i,v in ipairs(attrList) do
                local strValue = Utility.getRangeStr(v.range) .. string.format("%s%s+", FightattrName[v.fightattr], textColor)
                if (v.fightattr == Fightattr.eDAMADDR) or (v.fightattr == Fightattr.eDAMCUTR) then
                    strValue = strValue .. (v.value/100) .. "%"
                else
                    strValue = strValue .. v.value
                end
                local attrLabel = ui.newLabel({
                    text = strValue,
                    color = cc.c3b(0x46, 0x22, 0x0d),
                    size = 20
                })
                attrLabel:setAnchorPoint(cc.p(0, 0.5))
                attrLabel:setPosition(40, yPosList[i])
                target:addChild(attrLabel)
            end
        end
        ctrlSprite:addChild(attrNode)
        
        return attrNode
    end
    self.currAttrNode = createAttrNode(cc.p(155, 465))
    self.nextAttrNode = createAttrNode(cc.p(485, 465))
    
    -- 材料需求
    local tempBgSprite = ui.newScale9Sprite("c_17.png", cc.size(580, 170))
    tempBgSprite:setAnchorPoint(cc.p(0.5, 1))
    tempBgSprite:setPosition(320, 275)
    ctrlSprite:addChild(tempBgSprite)

    local resBgSize = cc.size(570, 160)
    local resBgSprite = ui.newScale9Sprite("c_37.png", resBgSize)
    resBgSprite:setAnchorPoint(0, 0)
    resBgSprite:setPosition(5, 5)
    tempBgSprite:addChild(resBgSprite)
    self.mResSprite = resBgSprite
    self.mResSprite.refreshNode = function (target, nextModel)
        target:removeAllChildren()

        -- 判断是否满级
        if (nextModel == nil) then
            local topSprite = ui.newSprite("zb_26.png")
            topSprite:setPosition(resBgSize.width * 0.5, 65)
            target:addChild(topSprite)
        else
            -- 创建需求材料
            local resInfo = string.split(nextModel.needResource, ",")
            local resType, resModelId, needNum = tonumber(resInfo[1]), tonumber(resInfo[2]), tonumber(resInfo[3])
            local tmpCard, cardShowAttrs = CardNode.createCardNode({
                resourceTypeSub = resType,
                modelId = resModelId,
                num = needNum,
                cardShape = Enums.CardShape.eSquare,
                cardShowAttrs = {CardShowAttr.eNum, CardShowAttr.eBorder},
                onClickCallback = function()
                    Utility.showResLackLayer(resType, resModelId)
                end
            })
            tmpCard:setPosition(resBgSize.width * 0.5, 62)
            target:addChild(tmpCard)

            -- 显示当前拥有数量
            local numLabel = cardShowAttrs[CardShowAttr.eNum].label
            local holdNum = Utility.getOwnedGoodsCount(resType, resModelId)
            local color = (holdNum >= needNum) and Enums.Color.eGreenH or Enums.Color.eRedH
            numLabel:setString(color .. string.format("%d/%d", holdNum, needNum))

            -- 创建铜钱需求
            local daibiNode = ui.createDaibiView({resourceTypeSub = ResourcetypeSub.eGold, number = nextModel.needGoldCoin})
            daibiNode:setAnchorPoint(0, 0.5)
            daibiNode:setPosition(420, 90)
            target:addChild(daibiNode)
            
            -- 升级按钮
            local button = nil
            button = ui.newButton({
                normalImage = "c_28.png",
                position = cc.p(480, 40),
                text = TR("升级"),
                clickAction = function()
                    -- 判断战力需求
                    if (PlayerAttrObj:getPlayerInfo().FAP < nextModel.needFAP) then
                        ui.showFlashView(TR("您的总战力需要达到%s%s%s才能继续升级名望", Enums.Color.eRedH, Utility.numberFapWithUnit(nextModel.needFAP), Enums.Color.eNormalWhiteH))
                        return
                    end
                    -- 判断铜钱需求
                    if not Utility.isResourceEnough(ResourcetypeSub.eGold, nextModel.needGoldCoin) then
                        return
                    end
                    -- 判断材料需求
                    if (holdNum < needNum) then
                        Utility.showResLackLayer(resType, resModelId)
                        return
                    end
                    -- 调用接口
                    button:setEnabled(false)
                    self:requestTitleUp()
                end
            })
            target:addChild(button)
        end
    end
end

-- 刷新页面
function PlayerTitleLayer:refreshLayer()
    -- 读取玩家信息
    local playerInfo = PlayerAttrObj:getPlayerInfo()
    local slotInfo = FormationObj:getSlotInfoBySlotId(1)
    local heroModel = HeroModel.items[slotInfo.ModelId]
    local nTitleId = playerInfo.TitleId or 0
    local currConfig = TitleModel.items[nTitleId]
    local nextConfig = TitleModel.items[nTitleId + 1]

    -- 刷新玩家名字
    local strPlayerName = ""
    if (currConfig ~= nil) then
        strPlayerName = string.format("%s【%s】", Utility.getColorValue(currConfig.valueLv, 2), currConfig.name)
    end
    strPlayerName = strPlayerName .. string.format("%s%s", Utility.getQualityColor(heroModel.quality, 2), playerInfo.PlayerName)
    self.mNameLabel:setString(strPlayerName)
    
    -- 刷新战力需求
    if (nextConfig ~= nil) then
        local strNeedFap = TR("战力需求: %s%s", ((playerInfo.FAP >= nextConfig.needFAP) and "#087E05" or "#EF0008"), Utility.numberFapWithUnit(nextConfig.needFAP))
        self.fapNeedLabel:setString(strNeedFap)
        self.fapNeedLabel:setVisible(true)
    else
        self.fapNeedLabel:setVisible(false)
    end
    
    -- 刷新属性和材料
    self.currAttrNode:refreshNode(currConfig, true)
    self.nextAttrNode:refreshNode(nextConfig, false)
    self.mResSprite:refreshNode(nextConfig)
end    

-- 升级接口
function PlayerTitleLayer:requestTitleUp()
    HttpClient:request({
        moduleName = "Title",
        methodName = "LvUp",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return 
            end

            -- 保存新的名望
            PlayerAttrObj:changeAttr({TitleId = response.Value.TitleId})

            -- 播放特效
            ui.newEffect({
                parent = self.mParentLayer,
                effectName = "effect_ui_mingwangshengji",
                position = cc.p(325, 672),
                loop = false,
                endListener = function ()
                    self:refreshLayer()
                end
            })
            MqAudio.playEffect("renwu_shengji.mp3")
        end
    })
end

return PlayerTitleLayer