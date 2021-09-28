--[[
    文件名：HeroRecruitLayer.lua
    描述：商城招募之队员招募页面
    创建人：chenzhong
    创建时间：2017.3.15
--]]

-- 当前页面是添加到TabView的pageLayer上，此layer中的元素不必适配，按 640，1136来计算
local HeroRecruitLayer = class("HeroRecruitLayer", function(params)
    return display.newLayer()
end)

local RecruitType = {
    eLowOnceRecruit = 1,        -- 一次豪侠招募
    eLowTenRecruit = 2,         -- 十次豪侠招募
    eSeniorOnceRecruit = 3,     -- 一次宗师招募
    eSeniorTenRecruit = 4,     -- 十次宗师招募
}

-- 构造函数
--[[
    params:
    Table params:
    {

    }
--]]
function HeroRecruitLayer:ctor(params)
    if params then
        self.mShopLayer = params.shopLayer
    end

    -- 初始化数据
    self.mRecruitInfo = nil                                     -- 招募信息，从服务器获取
    self.mRecruitUse = {}                                       -- 三种不同的招募方式的消耗配置表
    self.mIsSecondFree = false;                                 -- 第二个页面当前是否免费

    -- 设置当前Layer大小
    self.mBgSize = cc.size(640, 1136)
    self:setContentSize(self.mBgSize)

    -- 配置招募消耗表
    self:configRecruitUseTable()

    -- UI相关
    self:initUI()

    -- 请求服务器，获取招募相关信息，并刷新页面
    self:requestRecruitInfo()

    -- 退出时销毁计时器
    self:registerScriptHandler(function(eventType)
        if "enterTransitionFinish" == eventType and self.onEnterTransitionFinish then
            self:onEnterTransitionFinish()
        end
    end)
end

-- 两种不同的招募方式消耗信息存入表中
function HeroRecruitLayer:configRecruitUseTable()
    -- 招募花费配置
    -- for i = 1, HeroRecruitModel.items_count do
    --     local useItem = Utility.analysisStrResList(HeroRecruitModel.items[i].recruitUse)
    --     table.insert(self.mRecruitUse, useItem)
    -- end
    for _, recruitInfo in pairs(HeroRecruitModel.items) do
        if (recruitInfo.ID == RecruitType.eLowOnceRecruit) or (recruitInfo.ID == RecruitType.eLowTenRecruit) or
         (recruitInfo.ID == RecruitType.eSeniorOnceRecruit) or (recruitInfo.ID == RecruitType.eSeniorTenRecruit) then
            local useItem = Utility.analysisStrResList(recruitInfo.recruitUse)
            self.mRecruitUse[recruitInfo.ID] = useItem
        end
    end
    -- dump(self.mRecruitUse,"self.mRecruitUse")
end

-- 添加UI元素
function HeroRecruitLayer:initUI()
    local bgSprite = ui.newSprite("xzm_07.jpg")
    bgSprite:setPosition(320, 568)
    self:addChild(bgSprite)

    -- 豪侠招募图
    local haoxiaSprite = ui.newSprite("xzm_05.png")
    haoxiaSprite:setPosition(80, 850)
    self:addChild(haoxiaSprite)
    --宗师招募图
    local haoxiaSprite = ui.newSprite("xzm_06.png")
    haoxiaSprite:setPosition(550, 450)
    self:addChild(haoxiaSprite)

    -- 特效
    ui.newEffect({
        parent = self,
        effectName = "effect_ui_zhaomutexiao",
        position = cc.p(255, 370),
        loop = true,
    })

    if ModuleInfoObj:moduleIsOpen(ModuleSub.eShowTheProbability, false) then
        -- 设置规则按钮
        local ruleBtn = ui.newButton({
            normalImage = "c_72.png",
            anchorPoint = cc.p(0.5, 1),
            position = cc.p(594, 1005),
            clickAction = function()
                MsgBoxLayer.addRuleHintLayer(TR("规则"),
                {
                    [1] = TR("1.宗师招募概率为：神话3%、宗师10%、豪侠87%"),
                    [2] = TR("2.豪侠招募概率为：宗师1%、豪侠5%、大侠48%、侠客46%"),
                })
            end})
        bgSprite:addChild(ruleBtn, 1)
    end

    -- 添加提示文字
    --[[
    local hintLabel = ui.newLabel({
            text = TR("每次招募必得%s传说%s碎片", Enums.Color.eRedH, Enums.Color.eWhiteH),
            color = Enums.Color.eWhite,
            size = 24,
            outlineColor = cc.c3b(0x04, 0x14, 0x26),
        })
    hintLabel:setAnchorPoint(cc.p(0, 0))
    hintLabel:setPosition(cc.p(380, 130))
    self:addChild(hintLabel) --]]
    -- 添加两个按钮
    self.mRecruitBtns = {
        self:createTwoBtn(RecruitType.eLowOnceRecruit, RecruitType.eLowTenRecruit), -- 豪侠
        self:createTwoBtn(RecruitType.eSeniorOnceRecruit, RecruitType.eSeniorTenRecruit) -- 宗师
    }
    -- 按钮动画前后的位置
    local btnsPos = {
        cc.p(self.mBgSize.width * 0.5, self.mBgSize.height * 0.68),
        cc.p(self.mBgSize.width * 0.5, self.mBgSize.height * 0.29)
    }
    for i = 1, #self.mRecruitBtns do
        self.mRecruitBtns[i]:setPosition(btnsPos[i])
        self:addChild(self.mRecruitBtns[i])
    end

    -- 首次使用宗师招募令的标签
    local introLabel = ui.createLabelWithBg({
        bgFilename = "sc_24.png",  
        bgSize = cc.size(335, 57),
        fontSize = 22,  
        labelStr = TR("首次使用宗师招募令必得#ff974a宗师"),
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
        alignType = ui.TEXT_ALIGN_CENTER,
    })
    introLabel:setAnchorPoint(cc.p(0, 0))
    introLabel:setPosition(cc.p(180, 120))
    self:addChild(introLabel)
    self.mInroLabel = introLabel    

    -- 限时神将跳转按钮
    local tranBtn = ui.newButton({
            normalImage = "xzm_02.png",
            clickAction = function ()
                -- 判断活动是否开启
                local activityData = ActivityObj:getActivityItem(ModuleSub.eTimedRecruit)
                if activityData then
                    LayerManager.showSubModule(ModuleSub.eTimedRecruit)
                else
                    ui.showFlashView(TR("活动未开启"))
                end
            end
        })
    tranBtn:setPosition(160, 520)
    self:addChild(tranBtn)
    -- 限时神将图标
    local recruitTubiao = ui.newSprite("tb_100.png")
    recruitTubiao:setPosition(-90, 0)
    tranBtn:getExtendNode2():addChild(recruitTubiao)
    -- 立即前往
    if ActivityObj:getActivityItem(ModuleSub.eTimedRecruit) then
        local goSprite = ui.newSprite("jrhd_22.png")
        goSprite:setPosition(20, -15)
        tranBtn:getExtendNode2():addChild(goSprite)
    else
        local goSprite = ui.newSprite("jrhd_21.png")
        goSprite:setScale(0.5)
        goSprite:setPosition(20, -15)
        tranBtn:getExtendNode2():addChild(goSprite)
    end
    -- "最高可得传说"
    local descLabel = ui.newLabel({
            text = TR("最高可得传说"),
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        })
    descLabel:setPosition(20, 10)
    tranBtn:getExtendNode2():addChild(descLabel)

    -- 按钮动画
    -- local moveAction, easeBaseAction, delayAction = nil, nil, nil
    -- for i = 1, #self.mRecruitBtns do
    --     delayAction = cc.DelayTime:create(0.06 * i)
    --     local acts = {delayAction}
    --     if i == #self.mRecruitBtns then
    --         --[[----------执行新手引导----------]]--
    --         local executeGuide = cc.CallFunc:create(function()
    --             self:executeGuide()
    --         end)
    --         --------------------------------------
    --         table.insert(acts, executeGuide)
    --     end
    --     local seq = cc.Sequence:create(acts)
    --     self.mRecruitBtns[i]:runAction(seq)
    -- end
end

function HeroRecruitLayer:createTwoBtn(onceType, tenType)
    -- 所有招募列表
    local heroAllList = {}
    local heroList2 = string.splitBySep(HeroRecruitModel.items[onceType].outShowAll, ",")
    for i, v in ipairs(heroList2) do
        table.insert(heroAllList, tonumber(v))
    end

    -- 创建背景
    local twoBtn = cc.LayerColor:create(cc.c4b(0, 0, 0, 0))
    twoBtn:setContentSize(cc.size(640, 350))
    twoBtn:setIgnoreAnchorPointForPosition(false)
    twoBtn:setAnchorPoint(cc.p(0.5, 0.5))

    local twoSize = twoBtn:getContentSize()
    -- 预览按钮
    local previewPos = {
        [RecruitType.eLowOnceRecruit] = cc.p(130, 340),
        [RecruitType.eSeniorOnceRecruit] = cc.p(500, 380),
    }
    local previewBtn = ui.newButton({
        normalImage = "c_79.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = previewPos[onceType],
        clickAction = function()
            LayerManager.addLayer({
                name = "shop.HeroRecruitShowAllLayer",
                data = {heroList = heroAllList},
                cleanUp = false
            })
        end
    })
    previewBtn:setScale(0.9)
    twoBtn:addChild(previewBtn)

    -- 剩余招募次数
    local labelPos = {
        [RecruitType.eLowOnceRecruit] = cc.p(550, 180),
        [RecruitType.eSeniorOnceRecruit] = cc.p(80, 160),
    }
    local countLabel = ui.newLabel({
            text = "",
            color = Enums.Color.eRed,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            size = 24,
            dimensions = cc.size(30, 0),
        })
    countLabel:setPosition(labelPos[onceType])
    twoBtn:addChild(countLabel)
    twoBtn.countLabel = countLabel


     -- 招募按钮信息
    local btnInfos = {
        {
            normalImage = "xzm_08.png",
            text = TR("招募1次"),
            textColor = Enums.Color.eNormalWhite,
            anchorPoint = cc.p(0, 0.5),
            position = cc.p(20, 40),
            recruitType = onceType,
            clickAction = function()
                self:recruitBtnClicked(onceType)
            end
        },
        {
            normalImage = "xzm_09.png",
            text = TR("招募10次"),
            textColor = Enums.Color.eNormalWhite,
            anchorPoint = cc.p(0, 0.5),
            position = cc.p(220, 40),
            recruitType = tenType,
            clickAction = function()
                self:recruitBtnClicked(tenType)
            end
        }
    }

    twoBtn.buttons = {}
    twoBtn.prop = {}
    for item, btnInfo in ipairs(btnInfos) do
        -- 宗师招募重设坐标
        if btnInfo.recruitType == RecruitType.eSeniorOnceRecruit or btnInfo.recruitType == RecruitType.eSeniorTenRecruit then
            btnInfo.position.x = btnInfo.position.x + 200
            btnInfo.position.y = btnInfo.position.y + 50
        end
        -- 招募按钮
        local button = ui.newButton(btnInfo)
        twoBtn:addChild(button)
        twoBtn.buttons[item] = button
        local btnSize = button:getContentSize()

        -- 创建消耗
        local useInfo = self.mRecruitUse[btnInfo.recruitType][1]
        local tempColor = GoodsObj:getCountByModelId(useInfo.modelId) > useInfo.num and Enums.Color.eWhiteH or Enums.Color.eRedH
        local pic = Utility.getDaibiImage(useInfo.resourceTypeSub, useInfo.modelId)

        button.costLabel = ui.newLabel({
            text = self:getResConsumeInfoStr(pic, tempColor, useInfo.num, GoodsObj:getCountByModelId(useInfo.modelId)),
            outlineColor = Enums.Color.eBlack,
        })
        button.costLabel:setAnchorPoint(cc.p(0.5, 0.5))
        button.costLabel:setPosition(btnInfo.position.x + button:getContentSize().width/2-5, btnInfo.position.y + 55)
        twoBtn:addChild(button.costLabel)

        -- 按钮上的小红点，当免费时才显示
        local redDot = ui.createBubble({
            position = cc.p(btnSize.width * 0.9, btnSize.height * 0.8)
        })
        button:addChild(redDot)
        button.redDot = redDot
    end

    -- 单次宗师招募免费计时
    if onceType == RecruitType.eSeniorOnceRecruit then
        -- 本次免费/XXXX后免费
        twoBtn.remainTime = ui.newLabel({
            text = "",
            outlineColor = Enums.Color.eBlack,
            font = _FONT_PANGWA,
            size = 22,
        })
        twoBtn.remainTime:setAnchorPoint(0, 0.5)
        twoBtn.remainTime:setPosition(250, 40)
        twoBtn.remainTime:setVisible(false)
        twoBtn:addChild(twoBtn.remainTime)
    end

    return twoBtn
end

-- 招募1次、招募十次按钮点击事件
--[[
    params:
    recruitType                 -- 招募按钮的类型
--]]
function HeroRecruitLayer:recruitBtnClicked(recruitType)
    print("click"..recruitType)
    -- 注意：
    -- 召唤符属于道具，应该用 GoodsObj:getCountByModelId 这个函数，Utility.isResourceEnough 只用来判断人物属性是否足够
    -- 元宝属于物品也属于人物属性，二者均可
    -- 豪侠

    -- 招募数量
    local recruitNumList = {
        [RecruitType.eLowOnceRecruit] = 1,
        [RecruitType.eLowTenRecruit] = 10,
        [RecruitType.eSeniorOnceRecruit] = 1,
        [RecruitType.eSeniorTenRecruit] = 10,
    }

    -- 招募次数不足
    if self.mRecruitInfo.LimitNum < recruitNumList[recruitType] then
        ui.showFlashView({text = TR("今日招募次数不足")})
        return
    end

    -- 招募令不足
    if recruitType == RecruitType.eLowOnceRecruit or recruitType == RecruitType.eLowTenRecruit then
        if GoodsObj:getCountByModelId(self.mRecruitUse[recruitType][1].modelId) < self.mRecruitUse[recruitType][1].num then
            ui.showFlashView({text = TR("豪侠招募令不足")})
            return
        end
    elseif recruitType == RecruitType.eSeniorOnceRecruit or recruitType == RecruitType.eSeniorTenRecruit then
        if recruitType == RecruitType.eSeniorOnceRecruit and self.mIsSecondFree == true then
            -- 调用免费招募
            self:requestRecruit(recruitType, true)
            return
        elseif GoodsObj:getCountByModelId(self.mRecruitUse[recruitType][1].modelId) < self.mRecruitUse[recruitType][1].num then
            self:requestGetShopGoodsInfo(self.mRecruitUse[recruitType][1].modelId)
            return
        end
    end

    -- 调用招募接口
    self:requestRecruit(recruitType, false)
end

-- 根据获取的招募数据，刷新页面各种标签
function HeroRecruitLayer:refreshLayer()
    -----------豪侠招募按钮-----------
    -- 四种招募令个数
    local normalOneItem = self.mRecruitUse[RecruitType.eLowOnceRecruit][1]
    local normalTenItem = self.mRecruitUse[RecruitType.eLowTenRecruit][1]
    local specialOneItem = self.mRecruitUse[RecruitType.eSeniorOnceRecruit][1]
    local specialTenItem = self.mRecruitUse[RecruitType.eSeniorTenRecruit][1]

    local normalOneCount = GoodsObj:getCountByModelId(normalOneItem.modelId)
    local normalTen = GoodsObj:getCountByModelId(normalTenItem.modelId)
    local specialOne = GoodsObj:getCountByModelId(specialOneItem.modelId)
    local specialTen = GoodsObj:getCountByModelId(specialTenItem.modelId)
    -- 四种招募令图片
    local normalOnePic = Utility.getDaibiImage(normalOneItem.resourceTypeSub, normalOneItem.modelId)
    local normalTenPic = Utility.getDaibiImage(normalTenItem.resourceTypeSub, normalTenItem.modelId)
    local specialOnePic = Utility.getDaibiImage(specialOneItem.resourceTypeSub, specialOneItem.modelId)
    local specialTenPic = Utility.getDaibiImage(specialTenItem.resourceTypeSub, specialTenItem.modelId)

    ------------豪侠招募按钮------------
    -- 10个以上的牌子，才显示小红点
    local recruitBtn1 = self.mRecruitBtns[1]
    local normalBtn1, normalBtn2 = recruitBtn1.buttons[1], recruitBtn1.buttons[2]
    normalBtn1.costLabel:setString(self:getResConsumeInfoStr(normalOnePic,
        (normalOneCount < 1) and Enums.Color.eRedH or Enums.Color.eWhiteH,
        normalOneItem.num, normalOneCount))
    normalBtn2.costLabel:setString(self:getResConsumeInfoStr(normalTenPic,
        (normalOneCount < 10) and Enums.Color.eRedH or Enums.Color.eWhiteH,
        normalTenItem.num, normalTen))
    normalBtn1.redDot:setVisible(false) -- 豪侠招一次永远不显示
    normalBtn2.redDot:setVisible(normalOneCount >= 10 and self.mRecruitInfo.LimitNum >= 10)

    ------------宗师招募按钮------------
    -- 拥有招募令数量标签
    local recruitBtn2 = self.mRecruitBtns[2]
    local specialBtn1, specialBtn2 = recruitBtn2.buttons[1], recruitBtn2.buttons[2]
    specialBtn1.costLabel:setString(self:getResConsumeInfoStr(specialOnePic,
        (specialOne < 1) and Enums.Color.eRedH or Enums.Color.eWhiteH,
        specialOneItem.num, Utility.numberWithUnit(specialOne)))
    specialBtn2.costLabel:setString(self:getResConsumeInfoStr(specialTenPic,
        (specialTen < 1) and Enums.Color.eRedH or Enums.Color.eWhiteH,
        specialTenItem.num, Utility.numberWithUnit(specialTen)))
    -- 设置小红点的显示
    specialBtn1.redDot:setVisible((specialOne >= 1 or self.mIsSecondFree) and self.mRecruitInfo.LimitNum >= 1)
    specialBtn2.redDot:setVisible(specialTen >= 1 and self.mRecruitInfo.LimitNum >= 10)

    -- 首次使用宗师招募令的标签 HigAlreadyUseResource:(true：已经付费招募,false：未付费招募)
    if self.mInroLabel then
        local introStr = ""
        if not self.mRecruitInfo.HigAlreadyUseResource then 
            introStr = TR("首次使用宗师招募令必得#ff974a宗师")
        else  
            if self.mRecruitInfo.OutZiCount == 0 then 
                introStr = TR("下次必出%s宗师%s!",
                    Enums.Color.eOrangeH,
                    Enums.Color.eWhiteH
                )
            else     
                introStr = TR("再招%s%d%s次必出%s宗师%s!",
                    Enums.Color.eOrangeH,
                    self.mRecruitInfo.OutZiCount + 1,
                    Enums.Color.eWhiteH,
                    Enums.Color.eOrangeH,
                    Enums.Color.eWhiteH
                )
            end     
        end     
        self.mInroLabel:setString(introStr)
    end     
    
    -- 两个按钮的免费倒计时
    -- 计时器延迟1s才执行,这里手动调用一次
    self:updateTimeLabels()
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    self.mSchelTime = Utility.schedule(self, self.updateTimeLabels, 1.0)

    -- 两个剩余招募次数刷新
    recruitBtn1.countLabel:setString(TR("今日招募剩余次数%d", self.mRecruitInfo.LimitNum))
    recruitBtn2.countLabel:setString(TR("今日招募剩余次数%d", self.mRecruitInfo.LimitNum))
end

-- 更新宗师招募的时间标签
function HeroRecruitLayer:updateTimeLabels()
    -- 宗师招募按钮
    local leftTime = self.mRecruitInfo.CooledInfo[3].CooledTime - Player.mTimeTick
    local timeLeft2 = leftTime > 0 and leftTime or 0
    local specialOne = GoodsObj:getCountByModelId(self.mRecruitUse[RecruitType.eSeniorOnceRecruit][1].modelId)
    local recruitBtn2 = self.mRecruitBtns[2]
    local specialButton1 = recruitBtn2.buttons[1]

    if timeLeft2 > 0 then
        self.mIsSecondFree = false

        recruitBtn2.remainTime:setString(TR("%s后免费", MqTime.formatAsHour(timeLeft2, {hour = true, min = true, sec = true})))
        recruitBtn2.remainTime:setVisible(true)
    else
        self.mIsSecondFree = true
        specialButton1.costLabel:setString(TR("%s本次免费", Enums.Color.eGreenH))
        recruitBtn2.remainTime:setVisible(false)
    end

    -- 刷新按钮小红点
    specialButton1.redDot:setVisible((specialOne >= 1 or self.mIsSecondFree) and self.mRecruitInfo.LimitNum >= 1)
end

-- 招募消耗信息
function HeroRecruitLayer:getResConsumeInfoStr(pic, color, have, use)
    local str = string.format("{%s} %s%s %s/ %s", pic, color, use, Enums.Color.eWhiteH, have)
    return str
end

-------------------------网络相关-------------------------
-- 获取人物招募信息
function HeroRecruitLayer:requestRecruitInfo()
    HttpClient:request({
        moduleName = "HeroRecruit",
        methodName = "RecruitInfo",
        callbackNode = self,
        callback = function(data)
            if data.Status == 0 then
                self.mRecruitInfo = data.Value
                -- dump(self.mRecruitInfo,"self.mRecruitInfo")
                -- print("time = "..Player.mTimeTick)

                -- 根据获取的数据刷新页面
                self:refreshLayer()
            else
                Guide.manager:removeGuideLayer()
            end
        end
    })
end

-- 请求招募接口
--[[
params:
    recruitBtnType:   招募按钮的类型：1、2、3、4
    isFree: 是否是免费招募, false:不免费  true:免费
]]--
function HeroRecruitLayer:requestRecruit(recruitBtnType, isFree)
    -- 请求服务器
    local requestData = {recruitBtnType, isFree}
    HttpClient:request({
        moduleName = "HeroRecruit",
        methodName = "Recruit",
        svrMethodData = requestData,
        guideInfo = Guide.helper:tryGetGuideSaveInfo(10205),
        callbackNode = self,
        callback = function (data)
            -- 容错处理
            if not data or data.Status ~= 0 then
                return
            end
            -- 掉落物品信息表
            local goodInfo = data.Value.BaseGetGameResourceList[1].Goods

            -- 1次招募1个
            if recruitBtnType == 3 or recruitBtnType == 1 then
                --[[--------新手引导--------]]--
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID == 10205 then
                    Guide.manager:nextStep(eventID) -- 主引导:美女引导指向豪侠招募
                    Guide.manager:removeGuideLayer() -- 需要手动删除
                end
                -------------------------------
                local layerParams = {
                    heroInfo = data.Value.BaseGetGameResourceList[1].Hero,
                    goodInfo = goodInfo,
                    recruitBtnType = recruitBtnType,
                    typeFrom = ModuleSub.eRecruit,
                    outZiCount = data.Value.OutZiCount,
                    isCanEvaluate = data.Value.IsFirstHighQualityHero,
                    btnCallBack = function(recruit)
                        self:recruitBtnClicked(recruit)
                    end,
                    closeCallBack = function()
                        self:refreshLayer()
                    end
                }
                LayerManager.addLayer({
                    name = "shop.HeroRecruitShowActionLayer",
                    data = layerParams,
                    cleanUp = false
                })
            -- 1次招募10个
            else
                local layerParams = {
                    heroList = data.Value.BaseGetGameResourceList[1].Hero,
                    goodInfo = goodInfo,
                    recruitBtnType = recruitBtnType,
                    isCanEvaluate = data.Value.IsFirstHighQualityHero,
                    btnCallBack = function(recruit)
                        self:recruitBtnClicked(recruit)
                    end,
                    closeBack = function()
                        self:refreshLayer()
                    end
                }
                LayerManager.addLayer({
                    name = "shop.HeroRecruitShowTenActionLayer",
                    data = layerParams,
                    cleanUp = false
                })
            end

            -- 数据刷新
            if recruitBtnType == 3 then
                -- 进行高级招募
                self.mRecruitInfo.CooledInfo[3].CooledTime = data.Value.CooledTick
                self.mRecruitInfo.OutZiCount = data.Value.OutZiCount
            end
            self.mRecruitInfo.HigAlreadyUseResource = data.Value.HigAlreadyUseResource
            self.mRecruitInfo.MidAlreadyUseResource = data.Value.MidAlreadyUseResource
            self.mRecruitInfo.LimitNum = data.Value.LimitNum
            -- 刷新本页面
            self:refreshLayer()
        end
    })
end

-- 获取道具的购买信息
function HeroRecruitLayer:requestGetShopGoodsInfo(goodsModelId)
    HttpClient:request({
        moduleName = "ShopGoods",
        methodName = "GetShopGoodsInfo",
        svrMethodData = {goodsModelId},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            MsgBoxLayer.addBuyGoodsCountLayer(
                TR("购买道具"),
                response.Value[1],
                function(selCount, layerObj, btnObj, selPrice)
                    layerObj:removeFromParent()
                    self:requestBuyGoods(goodsModelId, selCount, response.Value[1].SellTypeId, selPrice)
                end
            )
        end
    })
end

-- 道具购买请求
function HeroRecruitLayer:requestBuyGoods(goodsModelId, selCount, priceType, selPrice)
    if selCount == 0 then
        return
    end
    if not Utility.isResourceEnough(priceType, selPrice, true) then
        return
    end
    HttpClient:request({
        moduleName = "ShopGoods",
        methodName = "BuyGoods",
        svrMethodData = {goodsModelId, selCount},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            ui.showFlashView(TR("购买成功"))
            self:refreshLayer()
        end
    })
end

-- ========================== 新手引导 ===========================
function HeroRecruitLayer:onEnterTransitionFinish()
    self:executeGuide()
end

function HeroRecruitLayer:executeGuide()
    Guide.helper:executeGuide({
        [10204] = {nextStep = function(eventID, isGot)
            if isGot then
                Guide.manager:nextStep(10204)
                -- 领取服务器物品成功执行下一步
                Utility.performWithDelay(self, function()
                    self:executeGuide()
                end, 0)
            else
                self:executeGuide()
            end
        end},
        [10205] = {clickNode = self.mRecruitBtns[1].buttons[1]},
    })
end

return HeroRecruitLayer
