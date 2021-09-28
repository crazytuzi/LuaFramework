--[[
    文件名：IllusionHomeLayer.lua
    描述：幻化主页面
    创建人: 陈中
    创建时间: 2018.03.12
--]]

local IllusionHomeLayer = class("IllusionHomeLayer", function()
    return display.newLayer()
end)

--[[
    params:
        HeroId:学员实体ID
        callback
]]
-- 构造函数
function IllusionHomeLayer:ctor(params)
    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("幻 化"),
        bgSize = cc.size(630, 880),
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)

    -- 保存弹窗控件信息
    self.bgSprite = bgLayer.mBgSprite
    self.viewSize = bgLayer.mBgSprite:getContentSize()
    -- 幻化将列表
    self.illusionList = {}
    -- 当前学员Id
    self.mCurrentHeroId = params.HeroId or EMPTY_ENTITY_ID
    self.mCallback = params.callback

    -- 初始化UI
    self:initUI()
    -- 获取幻化初始数据
    self:getIllusionData()
    -- 刷新页面
    self:refreshUI()
end

-- 初始化UI
function IllusionHomeLayer:initUI()
    -- 文字提示
    local infoLabel = ui.newLabel({
        text = TR("*幻化不分男女性别，均可使用"),
        color = cc.c3b(0xff, 0x00, 0x36),
    })
    infoLabel:setAnchorPoint(cc.p(1, 0.5))
    infoLabel:setPosition(self.viewSize.width - 65, self.viewSize.height - 85)
    self.bgSprite:addChild(infoLabel)

    -- 中间背景
    local centerBgSprite = ui.newSprite("zr_54.jpg")
    centerBgSprite:setAnchorPoint(cc.p(0.5, 0))
    centerBgSprite:setPosition(self.viewSize.width * 0.5, 285)
    self.bgSprite:addChild(centerBgSprite)
    self.centerBgSprite = centerBgSprite

    -- 效果预览按钮
    local btnAttr = ui.newButton({
        normalImage = "tb_261.png",
        clickAction = function()
            self:illusionAttrPopLayer()
        end
    })
    btnAttr:setPosition(90, self.viewSize.height * 0.75)
    self.bgSprite:addChild(btnAttr)

    -- 列表背景
    local listBgSize = cc.size(self.viewSize.width - 70, 144)
    local listBgSprite = ui.newScale9Sprite("c_65.png", listBgSize)
    listBgSprite:setAnchorPoint(cc.p(0.5, 0))
    listBgSprite:setPosition(cc.p(self.viewSize.width * 0.5, 120))
    self.bgSprite:addChild(listBgSprite)

    -- 头像列表
    local mCellSize = cc.size(130, listBgSize.height)
    local mSliderView = ui.newSliderTableView({
        width = listBgSize.width - 20,
        height = listBgSize.height,
        isVertical = false,
        selItemOnMiddle = false,
        itemCountOfSlider = function(sliderView)
            return #self.illusionList
        end,
        itemSizeOfSlider = function(sliderView)
            return mCellSize.width, mCellSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
            local itemData = self.illusionList[index + 1]
            local tempCardNum = Utility.getOwnedGoodsCount(ResourcetypeSub.eIllusion, itemData.modelId)
            local showAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
            if (self.selectModelId == itemData.modelId) then
                -- 选中框
                table.insert(showAttrs, CardShowAttr.eSelected)
            end
            if (itemData.IsInFormation ~= nil) and (itemData.IsInFormation == true) then
                -- 已上阵
                table.insert(showAttrs, CardShowAttr.eBattle)
                -- 如果已经幻化了 那么这儿数量需要减1
                tempCardNum = tempCardNum - 1
            end
            local tempCard = require("common.CardNode").new({
                allowClick = true,
                onClickCallback = function()
                    self.selectModelId = itemData.modelId
                    self:refreshUI()
                end
            })
            tempCard:setPosition(mCellSize.width / 2, mCellSize.height / 2 + 12)
            tempCard:setIllusion({ModelId = itemData.modelId, Num = tempCardNum}, showAttrs)
            if (itemData.isOwned == nil) or (itemData.isOwned == false) then
                local lockSprite = ui.newSprite("bsxy_14.png")
                lockSprite:setPosition(48, 48)
                tempCard:addChild(lockSprite, 2)
                tempCard.mBgSprite:setGray(true)
            end
            itemNode:addChild(tempCard)
        end,
        selectItemChanged = function(sliderView, selectIndex)
        end
    })
    mSliderView:setTouchEnabled(true)
    mSliderView:setAnchorPoint(cc.p(0.5, 0.5))
    mSliderView:setPosition(listBgSize.width / 2, listBgSize.height / 2)
    listBgSprite:addChild(mSliderView)
    self.mSliderView = mSliderView

    -- 幻化按钮
    local btnSave = ui.newButton({
        normalImage = "c_28.png",
        text = TR("幻 化"),
        clickAction = function()

        end
    })
    btnSave:setPosition(self.viewSize.width * 0.5, 70)
    self.bgSprite:addChild(btnSave)
    self.btnSave = btnSave

    -- 幻化重生按钮
    local rebirthBtn = ui.newButton({
        normalImage = "tb_262.png",
        clickAction = function ()
            
        end,
    })
    rebirthBtn:setPosition(self.viewSize.width * 0.75, 70)
    self.bgSprite:addChild(rebirthBtn)
    self.rebirthBtn = rebirthBtn

    -- 幻化于XX
    self.mHintLabel = ui.newLabel({
        text = "",
        color = cc.c3b(0xff, 0xfb, 0xde),
        outlineColor = cc.c3b(0x37, 0x30, 0x2c),
        size = 24,
    })
    self.mHintLabel:setAnchorPoint(cc.p(1, 0.5))
    self.mHintLabel:setPosition(580, 300)
    self.bgSprite:addChild(self.mHintLabel, 1)
end

-- 刷新界面
function IllusionHomeLayer:refreshUI()
    -- 读取选中的绝学
    local currData = self:getSelectedFashion()
    
    -- 刷新列表
    self.mSliderView:reloadData()

    -- 刷新详情
    if (self.centerBgSprite.refreshNode == nil) then
        self.centerBgSprite.refreshNode = function (target, newData)
            target:removeAllChildren()
            if (newData == nil) then
                return
            end

            -- 显示名字
            local centerBgSize = target:getContentSize()
            local nameLabel = ui.createLabelWithBg({
                bgFilename = "zr_50.png",
                labelStr = newData.name,
                fontSize = 24,
                color = cc.c3b(0x51, 0x18, 0x0d),
                alignType = ui.TEXT_ALIGN_CENTER
            })
            nameLabel:setPosition(centerBgSize.width * 0.5, centerBgSize.height - 30)
            target:addChild(nameLabel)

            -- 显示大图
            Figure.newHero({
                parent = target,
                IllusionModelId = newData.modelId,
                position = cc.p(centerBgSize.width / 2, 30),
                scale = 0.27,
            })

            -- 显示技能图标
            local function createSkillHeader(skillId, isSkill, img, posY)
                local tempCard = require("common.CardNode").new({
                    allowClick = true,
                    onClickCallback = function()
                        self:showSkillDlg(skillId, isSkill, cc.p(centerBgSize.width - 70, posY + 330))
                    end
                })
                tempCard:setPosition(centerBgSize.width - 60, posY)
                tempCard:setSkillAttack({modelId = skillId, icon = img .. ".png", isSkill = isSkill}, {CardShowAttr.eBorder})
                target:addChild(tempCard)
            end
            createSkillHeader(newData.NAID, false, newData.attackIcon, 340)
            createSkillHeader(newData.RAID, true, newData.skillIcon, 240)
        end
    end
    self.centerBgSprite:refreshNode(currData)

    -- 刷新按钮状态
    if (currData.isOwned ~= nil) and (currData.isOwned == true) then
        -- 已拥有
        self.btnSave.mTitleLabel:setString(TR("幻 化"))
        self.btnSave:setClickAction(function()
            self:requestCombat()
        end)
    else
        -- 未拥有
        self.btnSave.mTitleLabel:setString(TR("去获取"))
        self.btnSave:setClickAction(function()
            -- ui.showFlashView("通过活动获取")
            LayerManager.addLayer({
                name = "hero.DropWayLayer",
                data = {
                    resourceTypeSub = ResourcetypeSub.eIllusion,
                    modelId = currData.modelId,
                },
                cleanUp = false,
            })
        end)
    end
    -- 已经穿戴的禁止点击
    self.btnSave:setEnabled(not ((currData.IsInFormation ~= nil) and (currData.IsInFormation == true)))

    -- 重生按钮
    self.rebirthBtn:setEnabled((currData.IsInFormation ~= nil) and (currData.IsInFormation == true))
    self.rebirthBtn:setClickAction(function( )
        self:rebirthBox()
    end)

    -- 显示幻化于
    if (currData.IsInFormation ~= nil) and (currData.IsInFormation == true) then
        self.mHintLabel:setVisible(true)
        local heroId = IllusionObj:getInFormationHeroId(currData.modelId)
        local heroInfo = HeroObj:getHero(heroId)
        local heroBase = HeroModel.items[heroInfo.ModelId]
        self.mHintLabel:setString(TR("幻化于 %s%s", Utility.getQualityColor(heroBase.quality, 2), heroBase.name))
    else
        self.mHintLabel:setVisible(false)
    end
end

-- 幻化重生
function IllusionHomeLayer:rebirthBox()
    -- 读取选中的绝学
    local currData = self:getSelectedFashion()
    -- 计算当前幻化将对应的上阵学员的heroId
    local currIllusionHeroId = IllusionObj:getInFormationHeroId(currData.modelId)
    if currIllusionHeroId == EMPTY_ENTITY_ID then 
        ui.showFlashView(TR("当前幻化将不能重生"))
        return
    end 
    -- 计算重生花费
    local heroInfo = clone(HeroObj:getHero(currIllusionHeroId))
    local stepPoor = heroInfo.Step - IllusionConfig.items[1].illusionStepNeedHeroStep
    local useResList = Utility.analysisStrResList(IllusionConfig.items[1].rebirthBaseResources)
    local useResText = ""
    for _, resInfo in ipairs(useResList) do
        useResText = useResText .. string.format("{%s}%d", Utility.getDaibiImage(resInfo.resourceTypeSub, resInfo.modelId), resInfo.num * (stepPoor > 0 and stepPoor or 0))
    end
    -- 计算资源返还
    local illusionModelId = heroInfo.IllusionModelId
    local stepCount = clone(heroInfo.Step)
    local getResList = {}
    while (stepCount > IllusionConfig.items[1].illusionStepNeedHeroStep) do
        local needResStr = IllusionTalRelation.items[illusionModelId][stepCount-1].upUse
        local needResList = Utility.analysisStrResList(needResStr)
        for _, resInfo in pairs(needResList) do
            if getResList[resInfo.modelId] then
                getResList[resInfo.modelId].num = getResList[resInfo.modelId].num + resInfo.num
            else
                getResList[resInfo.modelId] = resInfo
            end
        end

        stepCount = stepCount - 1
    end
    -- 加一个上阵的幻化将
    if getResList[illusionModelId] then
        getResList[illusionModelId].num = getResList[illusionModelId].num + 1
    else
        getResList[illusionModelId] = {resourceTypeSub = ResourcetypeSub.eIllusion, modelId = illusionModelId, num = 1}
    end
    
    local function createHintBox(parent, bgSprite, bgSize)
        -- 花费提示
        local useLabel = ui.newLabel({
                text = TR("是否花费%s返还以下物品?", useResText),
                color = Enums.Color.eWhite,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            })
        useLabel:setAnchorPoint(0.5, 0.5)
        useLabel:setPosition(bgSize.width*0.5, bgSize.height-90)
        bgSprite:addChild(useLabel)
        -- 黑背景
        local blackBg = ui.newScale9Sprite("c_17.png", cc.size(bgSize.width-50, 150))
        blackBg:setPosition(bgSize.width*0.5, bgSize.height*0.5)
        bgSprite:addChild(blackBg)
        -- 列表
        local listView = ccui.ListView:create()
        listView:setDirection(ccui.ScrollViewDir.horizontal)
        -- listView:setBounceEnabled(true)
        listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
        listView:setAnchorPoint(cc.p(0.5, 0.5))
        listView:setPosition(blackBg:getContentSize().width*0.5, blackBg:getContentSize().height*0.5)
        blackBg:addChild(listView)

        local cellSize = cc.size(100, blackBg:getContentSize().height)
        -- 添加返还角色
        local itemCell = ccui.Layout:create()
        itemCell:setContentSize(cellSize)
        listView:pushBackCustomItem(itemCell)
        -- 创建角色卡牌
        local heroInfo = clone(HeroObj:getHero(currIllusionHeroId))
        heroInfo.Step = heroInfo.Step > 20 and 20 or heroInfo.Step
        heroInfo.IllusionModelId = 0
        local heroCard = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eHero,
            instanceData = heroInfo,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eLevel, CardShowAttr.eStep},
            allowClick = false,
        })
        heroCard:setPosition(cellSize.width*0.5, cellSize.height*0.55)
        itemCell:addChild(heroCard)

        -- 列表宽度
        local listWidth = cellSize.width

        -- 添加其他返还
        for _, resInfo in pairs(getResList) do
            local itemCell = ccui.Layout:create()
            itemCell:setContentSize(cellSize)
            listView:pushBackCustomItem(itemCell)
            
            resInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum}
            local resCard = CardNode.createCardNode(resInfo)
            resCard:setPosition(cellSize.width*0.5, cellSize.height*0.55)
            itemCell:addChild(resCard)

            listWidth = listWidth + cellSize.width
        end

        -- 设置列表大小
        local maxWidth = blackBg:getContentSize().width-10
        listView:setContentSize(cc.size(listWidth < maxWidth and listWidth or maxWidth, cellSize.height))
    end
    
    self.rebirthBoxLayer = LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
            notNeedBlack = true,
            bgSize = cc.size(600, 400),
            title = TR("重生"),
            btnInfos = {
                {
                    text = TR("确定"),
                    normalImage = "c_28.png",
                    clickAction = function ()
                        self:requestRebirth(currIllusionHeroId)
                    end,
                },
                {
                    text = TR("取消"),
                    normalImage = "c_28.png",
                    clickAction = function ()
                        LayerManager.removeLayer(self.rebirthBoxLayer)
                    end,
                },
            },
            DIYUiCallback = createHintBox,
            closeBtnInfo = {}
        }
    })
end

-- 效果预览弹窗
function IllusionHomeLayer:illusionAttrPopLayer()
    local function DIYFunction(layerObj, bgSprite, bgSize)
        local viewSize = cc.size(480, 500)
        -- 背景
        local tempSprite = ui.newScale9Sprite("c_17.png", viewSize)
        tempSprite:setAnchorPoint(cc.p(0.5, 1))
        tempSprite:setPosition(bgSize.width / 2, bgSize.height - 120)
        bgSprite:addChild(tempSprite)

        -- 添加介绍
        local introLabelWithBg = ui.createLabelWithBg({
            bgFilename = "wgmj_18.png",
            labelStr = TR("幻化后，会激活以下属性代替原属性"),
            fontSize = 22,
            color = cc.c3b(0x79, 0x40, 0x40),
            alignType = ui.TEXT_ALIGN_CENTER,
        })
        introLabelWithBg:setAnchorPoint(0.5, 1)
        introLabelWithBg:setPosition(bgSize.width/2, bgSize.height - 75)
        bgSprite:addChild(introLabelWithBg)

        -- 预览信息集合
        local previewInfo = {}
        -- 当前幻化将信息
        local currData = self:getSelectedFashion()
        local listView = ccui.ListView:create()
        listView:setDirection(ccui.ScrollViewDir.vertical)
        listView:setBounceEnabled(true)
        listView:setContentSize(viewSize.width - 10, 480)
        listView:setGravity(ccui.ListViewGravity.centerVertical)
        listView:setAnchorPoint(cc.p(0.5, 0))
        listView:setPosition(viewSize.width * 0.5, 10)
        tempSprite:addChild(listView) 

        for k,v in pairs(IllusionTalRelation.items[currData.modelId]) do
            if v.step == 3 or v.step == 5 or v.step == 8 or v.step == 10 or v.step == 15 or v.step == 20 or v.step == 21 or v.step == 22 or v.step == 23 or v.step == 24 or v.step == 25  then 
                table.insert(previewInfo,{step = v.step, talName = v.TALName, talModelId = v.TALModelID})
            end     
        end     
        table.sort(previewInfo, function (a, b)
            return a.step < b.step
        end)    

        local cellSize = cc.size(viewSize.width - 10, 110)
        for k,v in ipairs(previewInfo) do
            local lvItem = ccui.Layout:create()
            lvItem:setContentSize(cellSize)
            listView:pushBackCustomItem(lvItem)

            local introInfo = {} 
            if v.talModelId > 0 then 
                table.insert(introInfo, TalModel.items[v.talModelId].intro)
            end     

            local cellBgSize = cc.size(cellSize.width, 106)
            local cellBg = ui.newScale9Sprite("c_18.png", cellBgSize)
            cellBg:setPosition(cc.p(cellSize.width * 0.5, cellSize.height * 0.5))
            lvItem:addChild(cellBg)

            -- 突破名字
            local introNameLabel =  ui.newLabel({
                    text = string.format("#46220d%s：",v.talName),
                    font = _FONT_PANGWA,
                    anchorPoint = cc.p(0, 0.5),
                    size = 28,
                    x = 40,
                    y = cellBgSize.height/2
            })
            cellBg:addChild(introNameLabel)

            -- 突破属性介绍
            for i,v in ipairs(introInfo) do
                local rateLabel = ui.newLabel({
                    text = string.format("#249029%s",v),
                    font = _FONT_PANGWA,
                    anchorPoint = cc.p(0, 0.5),
                    size = 22,
                    dimensions = cc.size(300, 120),
                    x = 155,
                    y = cellBgSize.height/2
                })
                cellBg:addChild(rateLabel)        
            end
        end
    end

    MsgBoxLayer.addDIYLayer({
        bgSize = cc.size(542, 650),
        title = TR("效果预览"),
        notNeedBlack = true,
        btnInfos = {},
        closeBtnInfo = {},
        DIYUiCallback = DIYFunction,
    })
end
----------------------------------------------------------------------------------------------------
-- 辅助接口

-- 获取当前选中的幻化数据
function IllusionHomeLayer:getSelectedFashion()
    -- 读取选中的绝学
    local currData = nil
    for _,v in ipairs(self.illusionList) do
        if (self.selectModelId == v.modelId) then
            currData = clone(v)
            break
        end
    end
    return currData
end

-- 获取幻化数据
function IllusionHomeLayer:getIllusionData()
    -- 幻化开放列表
    local openIllusionList = {
        28010001,
        28010002,
        28010004,
        28010003,
        28010005,
        28010006,
        28010007,
        28010008,
        28010009,
        28010010,
        28010011,
        28010012,
        28010013,
        28010014,
        28010015,
        28010016,
    }

    self.illusionList = {}
    for _,v in pairs(IllusionModel.items) do
        if table.indexof(openIllusionList, v.modelId) then
            local item = clone(v)
            item.isOwned = IllusionObj:getOneItemOwned(item.modelId)
            item.IsInFormation = IllusionObj:getOneTypeInFormation(item.modelId)
            table.insert(self.illusionList, item)
        end
    end

    table.sort(self.illusionList, function (a, b)
        if (a.isOwned ~= b.isOwned) then
            return (a.isOwned == true)
        end
        return a.modelId < b.modelId
    end)

    -- 默认选择顺序：优先选择已上阵，如果没有的话就选第一个
    if (self.selectModelId == nil) then
        self.selectModelId = self.illusionList[1].modelId
        for _,v in ipairs(self.illusionList) do
            if (v.IsInFormation) then
                self.selectModelId = v.modelId
                break
            end
        end
    end
end

-- 创建时装的技能介绍框
function IllusionHomeLayer:showSkillDlg(modelId, isSkill, pos)
    local dlgBgNode = cc.Node:create()
    dlgBgNode:setContentSize(self.viewSize)
    self.bgSprite:addChild(dlgBgNode, 1)

    -- 背景图
    local dlgBgSprite = ui.newSprite("zr_53.png")
    local dlgBgSize = dlgBgSprite:getContentSize()
    dlgBgSprite:setAnchorPoint(cc.p(1, 1))
    dlgBgSprite:setPosition(pos)
    dlgBgNode:addChild(dlgBgSprite)

    -- 技能图标
    local skillIcon = "c_71.png"
    if (isSkill ~= nil) and (isSkill == true) then
        skillIcon = "c_70.png"
    end
    local skillSprite = ui.newSprite(skillIcon)
    skillSprite:setAnchorPoint(cc.p(0, 0.5))
    skillSprite:setPosition(20, dlgBgSize.height - 40)
    dlgBgSprite:addChild(skillSprite)

    -- 技能名字
    local itemData = AttackModel.items[modelId] or {}
    local nameLabel = ui.newLabel({
        text = itemData.name or "",
        color = Enums.Color.eNormalYellow,
        size = 24,
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(58, dlgBgSize.height - 40)
    dlgBgSprite:addChild(nameLabel)

    -- 技能描述
    local attackList = string.splitBySep(itemData.intro or "", "#73430D")
    local attackText = ""
    for _,v in ipairs(attackList) do
        attackText = attackText .. Enums.Color.eNormalWhiteH .. v
    end
    local introLabel = ui.newLabel({
        text = attackText,
        color = Enums.Color.eNormalWhite,
        size = 22,
        align = ui.TEXT_ALIGN_LEFT,
        valign = ui.TEXT_VALIGN_TOP,
        dimensions = cc.size(dlgBgSize.width - 40, 0)
    })
    introLabel:setAnchorPoint(cc.p(0, 1))
    introLabel:setPosition(20, dlgBgSize.height - 70)
    dlgBgSprite:addChild(introLabel)

    -- 注册触摸关闭
    ui.registerSwallowTouch({
        node = dlgBgNode,
        allowTouch = true,
        endedEvent = function(touch, event)
            dlgBgNode:removeFromParent()
        end
    })
end

-----------------------------------------------------------------------------------------------------
-- 请求幻化接口
function IllusionHomeLayer:requestCombat()
    -- 读取选中的绝学
    local currData = self:getSelectedFashion()
    local ItemList = IllusionObj:getOneTypeIdList(currData.modelId) or {}
    if not next(ItemList) then 
        ui.showFlashView(TR("玩家没有此幻化将"))
        return
    end
    if self.mCurrentHeroId == EMPTY_ENTITY_ID then 
        ui.showFlashView(TR("请选择需要幻化的学员"))
        return
    end

    -- 接口参数
        --[[
            Guid:学员Id 
            Guid:幻化Id(默认取第一个实体ID 这儿没有要求)
        ]]
    HttpClient:request({
        moduleName = "Illusion",
        methodName = "Combat",
        svrMethodData = {self.mCurrentHeroId, ItemList[1].Id}, 
        callbackNode = self,
        callback = function (data)
            -- dump(data,"dadadad")
            -- 容错处理
            if data.Status ~= 0 then
                return
            end

            ui.showFlashView(TR("幻化成功！"))
            -- 刷新本地hero信息缓存
            HeroObj:modifyHeroItem(data.Value)

            -- 重新整理数据刷新页面
            self:getIllusionData()
            self:refreshUI()

            -- 回调刷新阵容信息
            if self.mCallback then 
                self.mCallback()
            end 
        end,
    })
end

-- 重生
function IllusionHomeLayer:requestRebirth(currIllusionHeroId)
    HttpClient:request({
        moduleName = "Hero",
        methodName = "HeroIllusionRebirth",
        svrMethodData = {{currIllusionHeroId}},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- 获取重生前幻化信息
            local illusionId = HeroObj:getHero(currIllusionHeroId).IllusionId
            local illusionInfo = IllusionObj:getIllusion(illusionId)

            -- 修改学员信息
            HeroObj:modifyHeroItem(response.Value.HeroInfo[1])
            -- 添加角色
            response.Value.BaseGetGameResourceList[1] = response.Value.BaseGetGameResourceList[1] or {}
            response.Value.BaseGetGameResourceList[1].Hero = response.Value.BaseGetGameResourceList[1].Hero or {}

            -- 添加角色信息
            local heroInfo = clone(response.Value.HeroInfo[1])
            heroInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eLevel, CardShowAttr.eStep}
            table.insert(response.Value.BaseGetGameResourceList[1].Hero, 1, heroInfo)

            -- 添加一个下阵幻化将
            response.Value.BaseGetGameResourceList[1].Illusion = response.Value.BaseGetGameResourceList[1].Illusion or {}
            if illusionInfo then
                table.insert(response.Value.BaseGetGameResourceList[1].Illusion, 1, illusionInfo)
            end

            -- 返还资源
            MsgBoxLayer.addGameDropLayer(response.Value.BaseGetGameResourceList, nil, nil, TR("返还"))

            -- 重新整理数据刷新页面
            self:getIllusionData()
            self:refreshUI()

            -- 回调刷新阵容信息
            if self.mCallback then 
                self.mCallback()
            end 
        end
    })
end

return IllusionHomeLayer
