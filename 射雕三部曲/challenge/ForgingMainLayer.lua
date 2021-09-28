    --[[
	文件名：ForgingMainLayer.lua
	描述：锻造主页面
	创建人：yanghongsheng
	创建时间：2017.4.5
--]]

--[[
    params:
        modelId     锻造图id
]]

local ForgingMainLayer = class("ForgingMainLayer", function()
    return display.newLayer()
end)

function ForgingMainLayer:ctor(params)
	-- 屏蔽下层触摸
	ui.registerSwallowTouch({node = self})
	-- 玩家拥有的锻造书
	self.forgingBookList = {}
	-- 锻造书选中状态图
	self.selectedSprites = {}
    -- 初始化锻造书表
    self:refreshData()
    -- 上次选中的锻造书index
    local modelIndex = self:findIndex(params.modelId)
    self.beforeIndex = (modelIndex > 0) and modelIndex or (params.selIndex or 1)

	-- 初始化界面
	self:initUI()
end

function ForgingMainLayer:getRestoreData()
    local retData = {}
    retData.selIndex = self.beforeIndex

    return retData
end

-- 查找modelId的索引
function ForgingMainLayer:findIndex(modelId)
    if modelId == nil then return 0 end

    local retIdx = 0
    for i, v in ipairs(self.forgingBookList) do
        if v.TreasureModelId == modelId then
            retIdx = i
            break
        end
    end
    return retIdx
end

--[[
    描述：刷新锻造列表数据
]]
function ForgingMainLayer:refreshData()
    -- 清空表
    self.forgingBookList = {}
    -- 初始化表
    for _, v in pairs(TreasureDebrisObj.mTreasureDebrisList) do
        if (v.TreasureDebrisModelId == 15032101) or (v.TreasureDebrisModelId == 15032201) then
            local item = clone(v)
            item.Num = 0
            item.TreasureModelId = TreasureDebrisModel.items[v.TreasureDebrisModelId].treasureModelID
            item.quality = TreasureDebrisModel.items[v.TreasureDebrisModelId].quality
            table.insert(self.forgingBookList, item)
        elseif v.Num >= 1 then
            local item = clone(v)
            item.TreasureModelId = TreasureDebrisModel.items[v.TreasureDebrisModelId].treasureModelID
            item.quality = TreasureDebrisModel.items[v.TreasureDebrisModelId].quality
            table.insert(self.forgingBookList, item)
        end
    end

    -- 对表排序
    table.sort(self.forgingBookList, function(a, b)
        if a.quality ~= b.quality then
            return a.quality > b.quality
        end

        return a.TreasureModelId > b.TreasureModelId
    end)
end

-- 初始化界面
function ForgingMainLayer:initUI()
	-- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建背景
    local spriteBg = ui.newSprite("dz_02.jpg")
    spriteBg:setPosition(320, 568)
    self.mParentLayer:addChild(spriteBg, -2)

	-- 创建底部导航和顶部玩家信息部分
	local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {ResourcetypeSub.eSTA, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)
    self.mCommonLayer_ = tempLayer

    -- 创建一键挖矿按钮
    local oneKeyMiningBtn = ui.newButton({
            normalImage = "tb_123.png",
            clickAction = function()
                if not ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eOneKeyChallengeGrab) then
                    return
                end

                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eOneKeyChallengeGrab, true) then
                    return
                end

                local playerHave = PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eSTA)
                if playerHave < 2 then
                    Utility.isResourceEnough(ResourcetypeSub.eSTA, 2, true)
                    return
                end
                self:requestOneKeyMining()
            end,
        })
    oneKeyMiningBtn:setPosition(cc.p(490, 200))
    self.mParentLayer:addChild(oneKeyMiningBtn)
    self.oneKeyMiningBtn = oneKeyMiningBtn

    -- 多次锻造按钮
    local timesForgingBtn = ui.newButton({
            normalImage = "tb_226.png",
            clickAction = function ()
                local limitLv = 60
                if PlayerAttrObj:getPlayerAttrByName("Lv") < limitLv then
                    ui.showFlashView(TR("%s级开启低级神兵多次锻造", limitLv))
                    return
                end

                local debrisInfo = self.forgingBookList[self.beforeIndex]
                local debrisModel = TreasureDebrisModel.items[debrisInfo.TreasureDebrisModelId]

                local limitNum =  debrisInfo.Num > 0 and debrisInfo.Num < 20 and debrisInfo.Num or 20

                self.timesForgBox = self:selectCountBox({
                        title = TR("选择次数"),
                        modelID = debrisModel.treasureModelID,
                        typeID = ResourcetypeSub.eBook,
                        resourcetypeCoin = ResourcetypeSub.eSTA,
                        exchangePrice = debrisModel.needExp,
                        maxNum = limitNum,
                        oKCallBack = function (exchangeCount)
                            -- 耐力是否足够
                            if not Utility.isResourceEnough(ResourcetypeSub.eSTA, debrisModel.needExp*exchangeCount) then
                                return
                            end
                            self:requestTimesMining(debrisInfo.TreasureDebrisModelId, exchangeCount)
                            LayerManager.removeLayer(self.timesForgBox)
                        end,
                    })
            end,
        })
    timesForgingBtn:setPosition(140, 200)
    self.mParentLayer:addChild(timesForgingBtn)
    self.timesForgingBtn = timesForgingBtn

    -- 创建退出按钮
    local button = ui.newButton({
        normalImage = "c_29.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(600,920),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(button, 5)

    -- 若没有锻造图的提示
    if next(self.forgingBookList) == nil then
        self:debrisGetHint()
        return
    end

    -- 其他需要刷新控件容器
    self.treasureRefresh = cc.Node:create()
    self.mParentLayer:addChild(self.treasureRefresh)

    -- 创建锻造列表
    local forgingList = self:createForgingList()
    forgingList:setPosition(320, 1030)
    self.mParentLayer:addChild(forgingList)

    -- 加成
    local attrLabel = ConfigFunc:getMonthAddAttrStr(true)
    if attrLabel then
        attrLabel:setPosition(584, 200)
        self.mParentLayer:addChild(attrLabel)
    end
end

-- 创建选择次数弹窗（用PopBgLayer防止与MsgBoxLayer冲突)
--[[
    params:
        title               题目
        modelID             神兵modelId
        typeID              神兵类型
        resourcetypeCoin    消耗资源类型
        modelIdCoin         消耗资源模型id
        exchangePrice       价格
        maxNum              最大数量
        oKCallBack          确定按钮回调
]]
function ForgingMainLayer:selectCountBox(params)
    local bgSize = cc.size(598, 435)
    -- 资源简介
    local info = Utility.getGoodsIntro(params.typeID, params.modelID)
    local infoLabel = ui.newLabel({
            text = info,
            color = Enums.Color.eNormalWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            dimensions = cc.size(bgSize.width-100, 0),
            align = cc.TEXT_ALIGNMENT_CENTER,
        })
    infoLabel:setAnchorPoint(cc.p(0.5, 1))
    -- 重设背景大小
    local bgSize = cc.size(bgSize.width, bgSize.height+infoLabel:getContentSize().height)

    local popLayer = require("commonLayer.PopBgLayer").new({
            bgImage = "c_30.png",
            bgSize = bgSize,
            closeImg = "c_29.png",
            title = params.title or TR("选择"),
        })
    self:addChild(popLayer)
    local bgSprite = popLayer.mBgSprite
    local bgSize = popLayer.mBgSize

    -- 黑背景
    local blackBg = ui.newScale9Sprite("c_17.png", cc.size(bgSize.width-60, bgSize.height-170))
    blackBg:setAnchorPoint(cc.p(0.5, 1))
    blackBg:setPosition(bgSize.width*0.5, bgSize.height-70)
    bgSprite:addChild(blackBg)

    -- 资源卡
    local card = CardNode.createCardNode({
            resourceTypeSub = params.typeID,
            modelId = params.modelID,
        })
    card:setPosition(bgSize.width*0.5, bgSize.height-130)
    bgSprite:addChild(card)

    -- 代币
    local daibiImg = Utility.getDaibiImage(params.resourcetypeCoin, params.modelIdCoin)
    local daibiLabel = ui.newLabel({
            text = string.format("{%s}%d", daibiImg, params.exchangePrice),
            color = Enums.Color.eNormalWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        })
    daibiLabel:setAnchorPoint(cc.p(0.5, 0.5))
    daibiLabel:setPosition(bgSize.width*0.5, bgSize.height-230)
    bgSprite:addChild(daibiLabel)

    -- 添加资源简介
    infoLabel:setPosition(bgSize.width*0.5, bgSize.height-260)
    bgSprite:addChild(infoLabel)

    -- 数量选择控件
    local curCount = 1
    local tempView = require("common.SelectCountView"):create({
        maxCount = params.maxNum,
        viewSize = cc.size(500, 200),
        changeCallback = function(count)
            curCount = count
            daibiLabel:setString(string.format("{%s}%d", daibiImg, params.exchangePrice*count))
            return true
        end
    })
    local viewY = bgSize.height-260-infoLabel:getContentSize().height-30
    tempView:setPosition(bgSize.width*0.5, viewY)
    bgSprite:addChild(tempView)

    -- 确定按钮
    local confirmBtn = ui.newButton({
            text = TR("确定"),
            normalImage = "c_28.png",
            clickAction = function ()
                if params.oKCallBack then
                    params.oKCallBack(curCount)
                end
            end
        })
    confirmBtn:setPosition(bgSize.width*0.5, 70)
    bgSprite:addChild(confirmBtn)

    return popLayer
end

--[[
    描述：没有锻造图提示（弹窗）
]]
function ForgingMainLayer:debrisGetHint()
    -- 创建弹窗
    local bgSize = cc.size(572, 337)
    -- 创建背景图片
    local bgSprite = ui.newScale9Sprite("mrjl_02.png", bgSize)
    bgSprite:setPosition(display.cx, display.cy)
    self.mParentLayer:addChild(bgSprite)
    -- 黑色背景框
    local blackSize = cc.size(bgSize.width*0.9, (bgSize.height-190))
    local blackBg = ui.newScale9Sprite("c_17.png", blackSize)
    blackBg:setAnchorPoint(0.5, 0)
    blackBg:setPosition(bgSize.width/2, 110)
    bgSprite:addChild(blackBg)

    -- 创建弹窗的标题
    local titlePos = cc.p(bgSize.width / 2, bgSize.height - 36)
    -- 标题的锚点
    local titleAnchorPoint = cc.p(0.5, 0.5)
    local titleNode = ui.newLabel({
        text = TR("提示"),
        size = 30,
        color = cc.c3b(0xff, 0xee, 0xd0),
        outlineColor = cc.c3b(0x3a, 0x24, 0x18),
        outlineSize = 2,
    })
    titleNode:setAnchorPoint(titleAnchorPoint)
    titleNode:setPosition(titlePos)
    bgSprite:addChild(titleNode)

    -- 创建提示内容
    local msgLabel = ui.newLabel({
        text = TR("你还没有锻造图纸，快去行侠仗义吧"),
        color = Enums.Color.eBlack,
        align = ui.TEXT_ALIGN_CENTER,
        dimensions = cc.size(bgSize.width*0.85 - 10, 0)
    })
    msgLabel:setAnchorPoint(cc.p(0.5, 0.5))
    msgLabel:setPosition(bgSize.width / 2, bgSize.height*0.5+15)
    bgSprite:addChild(msgLabel)
    -- 确认按钮
    local confirmBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("前往"),
            clickAction = function ()
                LayerManager.addLayer({
                    name = "challenge.BattleBossLayer"
                    })
            end
        })
    confirmBtn:setPosition(bgSize.width*0.3, 65)
    bgSprite:addChild(confirmBtn)
    -- 取消
    local cancelBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("取消"),
            clickAction = function ()
                LayerManager.removeLayer(self)
            end
        })
    cancelBtn:setPosition(bgSize.width*0.7, 65)
    bgSprite:addChild(cancelBtn)
    ui.showPopAction(bgSprite)
end

--[[
	描述：创建锻造列表
	参数：
]]
function ForgingMainLayer:createForgingList()
	-- 列表背景
    local listBg = ui.newScale9Sprite("dz_01.png", cc.size(640, 140))

    -- 创建列表
    local forgingList = ccui.ListView:create()
    forgingList:setDirection(ccui.ScrollViewDir.horizontal)
    forgingList:setItemsMargin(0)
    forgingList:setBounceEnabled(true)
    forgingList:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    forgingList:setAnchorPoint(cc.p(0, 0.5))
    forgingList:setContentSize(cc.size(640, 120))
    forgingList:setPosition(0, listBg:getContentSize().height*0.5 - 10)
    listBg:addChild(forgingList)

    self.forgeList = forgingList

    -- 初始化列表项
    for i, v in ipairs(self.forgingBookList or {}) do
    	local forgingCell = self:addOneItem(i)
    	forgingList:pushBackCustomItem(forgingCell)
    end
    -- 列表滚动到选中位置
    if self.beforeIndex > 5 then
        forgingList:jumpToPercentHorizontal(((self.beforeIndex)/#self.forgingBookList)*100)
    end
    
    if self.forgingBookList[self.beforeIndex] then
        self:changeItem(self.beforeIndex)
    else
        self:changeItem(1)
    end

    return listBg
end

--[[
	描述：添加列表项
	参数：index 			项索引
]]
function ForgingMainLayer:addOneItem(index)
	-- 锻造书modele数据
    local indexItemData = self.forgingBookList[index]
	local forgingModelID = indexItemData.TreasureDebrisModelId
	local modelData = TreasureDebrisModel.items[forgingModelID]
    local treasureData = TreasureModel.items[modelData.treasureModelID]
	-- cell大小
	local cellSize = cc.size(114, 110)
	-- 创建cell
	local forgingCell = ccui.Layout:create()
	forgingCell:setContentSize(cellSize)
	-- 创建卡片
    local cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eSelected}
    if indexItemData.Num > 0 then
        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eSelected, CardShowAttr.eNum}
    end
	local card, attrs = CardNode.createCardNode({
	    	resourceTypeSub = modelData.typeID,
	        modelId = modelData.ID,
            num = indexItemData.Num,
	        cardShowAttrs = cardShowAttrs,
	        allowClick = true,
	        onClickCallback = function ()
	        	self:changeItem(index)
	        end,
	    })
    card:setPosition(cellSize.width / 2, cellSize.height / 2)
    forgingCell:addChild(card)
	-- 选中状态图
	self.selectedSprites[index] = attrs[CardShowAttr.eSelected].sprite
	-- 默认隐藏
	self.selectedSprites[index]:setVisible(false)

	-- 羁绊状态
    local relationStatus = FormationObj:getRelationStatus(treasureData.ID, treasureData.typeID)
    if relationStatus == Enums.RelationStatus.eIsMember or relationStatus == Enums.RelationStatus.eTriggerPr then
        card:createStrImgMark("c_62.png", TR("缘分"), 22)
    end

    -- 检测是否能够合成-添加小红点
    local tempSprite = ui.createBubble({position = cc.p(78, 78),})
    card:addChild(tempSprite)
    -- 获取锻造石数量
    local materialNum = indexItemData.TotalExp
    local needNum = TreasureDebrisModel.items[indexItemData.TreasureDebrisModelId].needExp
    tempSprite:setVisible((materialNum >= needNum))

    return forgingCell
end

--[[
	描述：改变选中项
	参数：选中项index
]]
function ForgingMainLayer:changeItem(index)
	-- 显示选中框
	if self.selectedSprites[self.beforeIndex] then
		self.selectedSprites[self.beforeIndex]:setVisible(false)
	else
		return
	end
	self.selectedSprites[index]:setVisible(true)
	self.beforeIndex = index
	-- 获取锻造书模型id
	local modelIdTem = self.forgingBookList[index].TreasureDebrisModelId
    local modelData = clone(TreasureDebrisModel.items[modelIdTem])
    -- 该锻造书的锻造石
    modelData.materialNum = self.forgingBookList[index].TotalExp
	-- 改变ui
	self:changeItemUI(modelData)

end

--[[
	描述：改变ui
	参数：modelData	该锻造书数据
         materialNum 已有锻造石的数量
]]
function ForgingMainLayer:changeItemUI(modelData)
	self.treasureRefresh:removeAllChildren()

	-- 显示星级
    local colorLv = Utility.getQualityColorLv(modelData.quality)
    local view = ui.newStarLevel(colorLv)
    view:setPosition(320, 940)
    self.treasureRefresh:addChild(view)

    -- 显示名字
    local label = ui.createSpriteAndLabel({
		imgName = "c_25.png",
		scale9Size = cc.size(400, 50),
        labelStr = modelData.name,
        fontColor = Utility.getColorValue(colorLv, 1),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
        fontSize = 26,
    })
    label:setPosition(320, 900)
    self.treasureRefresh:addChild(label)

    -- 获取宝物信息
    local treasureID = modelData.treasureModelID
    local treasureData = TreasureModel.items[treasureID]
    -- 创建神兵图片
    local tempNode = Figure.newTreasure({
        modelId = treasureData.ID,
        needAction = true,
        viewSize = cc.size(640, 400)
    })
    tempNode:setAnchorPoint(cc.p(0.5, 0))
    tempNode:setPosition(320, 400)
    self.treasureRefresh:addChild(tempNode)
    -- 创建点击响应按钮
    local clickBtn = ui.newButton({
            normalImage = "c_83.png",
            size = cc.size(400, 400),
            position = cc.p(300, 200),
            clickAction = function ()
                LayerManager.addLayer({
                        name = "equip.TreasureInfoLayer",
                        data = {
                            treasureModelID = treasureData.ID,
                        },
                    })
            end,
        })
    tempNode:addChild(clickBtn)

    -- 创建文字背景
    local textBgSize = cc.size(276, 54)
    local textBg = ui.newScale9Sprite("c_25.png", textBgSize)
    textBg:setPosition(320, 300)
    self.treasureRefresh:addChild(textBg)
    -- 创建文字
    local textMaterialNum = ui.newLabel({
    		text = TR("所需材料 %s/%s", modelData.materialNum, modelData.needExp),
    		color = Enums.Color.eWhite,
    		outlineColor = Enums.Color.eOutlineColor,
    	})
    textMaterialNum:setAnchorPoint(cc.p(0.5, 0.5))
    textMaterialNum:setPosition(textBgSize.width * 0.5, textBgSize.height * 0.5)
    textBg:addChild(textMaterialNum)
    self.materialLabel = textMaterialNum

    -- 创建按钮
    local forgingButton
    if modelData.materialNum < modelData.needExp then
        forgingButton = ui.newButton({
            text = TR("进入矿场"),
            normalImage = "c_28.png",
            anchorPoint = cc.p(0.5, 0.5),
            position = cc.p(320, 200),
            clickAction = function()
                    LayerManager.addLayer({
                            name = "challenge.ForgingDigOreLayer",
                            data = {
                                    debrisModelId = modelData.ID,
                                },
                        })
            end
        })
        self.oneKeyMiningBtn:setEnabled(true)
    else
        forgingButton = ui.newButton({
                text = TR("锻 造"),
                normalImage = "c_33.png",
    			anchorPoint = cc.p(0.5, 0.5),
    			position = cc.p(320, 200),
    			clickAction = function()
                    --判断耐力是否足够
                    self:requestDebrisCompose(modelData.ID)
    			end
    		})
        self.oneKeyMiningBtn:setEnabled(false)
    end
    self.treasureRefresh:addChild(forgingButton)
    -- 保存按钮，引导使用
    self.forgingButton = forgingButton
end

--[[
    描述：刷新整个锻造界面
]]
function ForgingMainLayer:refreshListView()
    -- 刷新列表数据
    self:refreshData()
    -- 移除
    self.forgeList:removeAllItems()
    -- 清空选中框列表
    self.selectedSprites = {}
    -- 重制上一次选中
    if not self.forgingBookList[self.beforeIndex] then
        self.beforeIndex = 1
    end
    -- 若没有锻造图的提示
    if next(self.forgingBookList) == nil then
        self:debrisGetHint()
        return
    end

    -- 初始化列表项
    for i, v in ipairs(self.forgingBookList or {}) do
        local forgingCell = self:addOneItem(i)
        self.forgeList:pushBackCustomItem(forgingCell)
    end

    -- 默认
    self:changeItem(self.beforeIndex)
end

-------------------服务器请求相关---------------------
-- 合成
function ForgingMainLayer:requestDebrisCompose(debrisModelId)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "TreasureDebris",
        methodName = "TreasureDebrisOneKeyCompose",
        svrMethodData = {debrisModelId},
        guideInfo = Guide.helper:tryGetGuideSaveInfo(11208),
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            --[[--------新手引导--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 11208 then
                Guide.manager:nextStep(eventID)
                self:executeGuide()
            end
            -- 禁用锻造按钮
            self.forgingButton:setEnabled(false)
            --播放锻造特效
            ui.newEffect({
                    parent = self.mParentLayer,
                    effectName = "effect_ui_duobao",
                    zorder = 1,
                    position = cc.p(320, 680),
                    loop = false,
                    endRelease = true,
                    endListener = function()
                        -- 飘窗时间
                        local time = 1
                        ui.ShowRewardGoods(response.Value.BaseGetGameResourceList, true, true, time)
                        -- 延时刷新界面
                        Utility.performWithDelay(self, function ()
                            -- 解禁锻造按钮
                            self.forgingButton:setEnabled(true)
                            -- 刷新界面
                            self:refreshListView()
                        end, time+1)
                    end
                })
                MqAudio.playEffect("shenbingduanzao.mp3", false)
        end
    })
end

-- 一键挖矿
function ForgingMainLayer:requestOneKeyMining()
    local debrisModelId = self.forgingBookList[self.beforeIndex].TreasureDebrisModelId
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "TreasureDebris",
        methodName = "MiningForOneKey",
        svrMethodData = {debrisModelId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            --local costSta = response.Value.TotalMiningCount
            -- 刷新界面
            self:refreshListView()
            -- 显示奖励
            local modelIdTem = self.forgingBookList[self.beforeIndex].TreasureDebrisModelId
            local id = TreasureDebrisModel.items[modelIdTem].quality
            local oreName = TreasureModel.items[TreasureDebrisModel.items[modelIdTem].treasureModelID].name
            LayerManager.addLayer({
                name = "challenge.ForgingDigOreShowUi",
                data = {dropBaseInfo = response.Value, pageType = 1, name = oreName, quality = id, ctCount = response.Value.TotalMiningCount},
                cleanUp = false,
            })
        end
    })
end

-- 多次锻造
function ForgingMainLayer:requestTimesMining(debrisModelId, num)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "TreasureDebris",
        methodName = "MiningModelIdByCount",
        svrMethodData = {debrisModelId, num},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            --播放锻造特效
            ui.newEffect({
                    parent = self.mParentLayer,
                    effectName = "effect_ui_duobao",
                    zorder = 1,
                    position = cc.p(320, 680),
                    loop = false,
                    endRelease = true,
                    endListener = function()
                        -- 飘窗时间
                        MsgBoxLayer.addGameDropLayer(response.Value.BaseGetGameResourceList, nil, nil, TR("锻造"))
                        -- 刷新界面
                        self:refreshListView()
                    end
                })
                MqAudio.playEffect("shenbingduanzao.mp3", false)
        end
    })
end

-- ========================== 新手引导 ===========================
function ForgingMainLayer:onEnterTransitionFinish()
    self:executeGuide()
end

function ForgingMainLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 指向进入矿场
        [11204] = {clickNode = self.forgingButton},
        -- 指向锻造
        [11208] = {clickNode = self.forgingButton},
        [11209]  = {clickNode = self.mCommonLayer_:getNavBtnObj(Enums.MainNav.eFormation)},
    })
end

return ForgingMainLayer
