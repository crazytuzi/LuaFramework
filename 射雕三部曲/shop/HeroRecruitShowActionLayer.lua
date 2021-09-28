--[[
	文件名：HeroRecruitShowActionLayer.lua
	文件描述：点击招募一次弹出的英雄动画页面
	创建人：libowen
    修改人：chenqiang
	创建时间：2016.5.5
--]]

-- 此页面由LayerManager添加，需适配
local HeroRecruitShowActionLayer = class("HeroRecruitShowActionLayer", function(params)
	return display.newLayer()
end)

-- 构造函数
--[[
	params:
	Table params:
	{
		heroInfo		-- 招募英雄的信息
		goodInfo 		-- 掉落物品信息
		recruitBtnType 	-- 招募按钮类型
		typeFrom		-- 招募类型，普通招募还是限时招募
		btnCallBack  	-- 再招一次回调
		outZiCount 		-- 还差多少次出橙将
		closeCallBack 	-- 关闭本页面之后的回调
		activityID  	-- 可选的参数，限时招募ID
        isCanEvaluate   -- 是否可以调用评价sdk接口

        isNotRecruit    -- 非招募（合成，开包）
	}
--]]
function HeroRecruitShowActionLayer:ctor(params)
    -- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = self})

    -- 初始化数据
    self.mHeroInfo = params and params.heroInfo
    self.mGoodInfo = params and params.goodInfo
    self.mRecruitBtnType = params and params.recruitBtnType
    self.mTypeFrom = params and params.typeFrom
    self.mBtnCallBack = params and params.btnCallBack
    self.mOutZiCount = params and params.outZiCount
    self.mCloseCallBack = params and params.closeCallBack
    self.mActivityId = params and params.activityID 		-- 限时招募id
    self.isNotRecruit = params and params.isNotRecruit

    self.mBlessNum = params and params.blessNum
    self.mCredit = params and params.credit

    self.isCanEvaluate = params.isCanEvaluate

    -- 英雄id
    if self.mHeroInfo[1].FashionModelId and self.mHeroInfo[1].FashionModelId ~= 0 then
        self.mHeroModelId = self.mHeroInfo[1].FashionModelId
    else
        self.mHeroModelId = self.mHeroInfo[1].ModelId
    end

	-- 配置招募花费表
	self:configRecruitUseTable()

    -- 创建界面设置UI
    self:initUI()
end

-- 添加UI元素
function HeroRecruitShowActionLayer:initUI()
    self.mHeroBaseInfo = HeroModel.items[self.mHeroModelId]

	-- 父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	-- 背景
	local backSprite = ui.newSprite("sc_23.jpg")
	backSprite:setPosition(320, 568)
	self.mParentLayer:addChild(backSprite)
    self.mBgSprite = backSprite
	self.mBackSize = backSprite:getContentSize()

    -- 人物出场
    self:addHeroAndEffect()

    -- 人物下方的资质 阵营 星级 名字等标签信息
    self:addHeroShownInfo()

    -- 显示获得的道具
    if self.mGoodInfo then
        local goodName = ConfigFunc:getGoodsName(self.mGoodInfo[1].GoodsModelId)
        local goodNum = self.mGoodInfo[1].Num

        -- 额外获得XXXX标签
        -- self.mGoodSprite = ui.newLabel({
        --     text = TR("额外获得             %sx%d", Enums.Color.eNormalGreenH, goodNum),
        --     color = Enums.Color.eWhite,
        --     align = ui.TEXT_ALIGN_CENTER
        -- })
        -- self.mGoodSprite:setAnchorPoint(cc.p(0.5, 1))
        -- self.mGoodSprite:setPosition(cc.p(self.mBackSize.width / 2, self.mBackSize.height * 0.29))
        -- backSprite:addChild(self.mGoodSprite)
        -- self.mGoodSprite:setVisible(false)

        -- 卡牌
        self.mGoodHead = CardNode.createCardNode({
            resourceTypeSub = self.mGoodInfo[1].ResourceTypeSub,
            modelId = self.mGoodInfo[1].ModelId,
            num = self.mGoodInfo[1].Num,
            cardShowAttrs = {CardShowAttr.eBorder}
        })
        self.mGoodHead:setAnchorPoint(0, 0)
        self.mGoodHead:setScale(0.6)
        self.mGoodHead:setPosition(96, -15)
        -- self.mGoodSprite:addChild(self.mGoodHead)
        self.mGoodHead:setOpacity(0)
    end

    -- "再招XX次必出橙卡"之类的招募提示标签，普通招募中的天阶招募才显示，限时招募和其他招募不显示
    if self.mTypeFrom == ModuleSub.eRecruit and self.mRecruitBtnType == 3 then
        if self.mOutZiCount == 0 then
            self.mNeedSprite = ui.newLabel({
                text = TR("下次必出%s宗师%s!",
                    Enums.Color.eOrangeH,
                    Enums.Color.eWhiteH
                ),
                align = ui.TEXT_ALIGN_CENTER
            })
        else
            self.mNeedSprite = ui.newLabel({
                text = TR("再招%s%d%s次必出%s宗师%s!",
                    Enums.Color.eOrangeH,
                    self.mOutZiCount + 1,
                    Enums.Color.eWhiteH,
                    Enums.Color.eOrangeH,
                    Enums.Color.eWhiteH
                ),
                align = ui.TEXT_ALIGN_CENTER
            })
        end

        self.mNeedSprite:setAnchorPoint(cc.p(0.5, 1))
        self.mNeedSprite:setPosition(self.mBackSize.width / 2, self.mBackSize.height * 0.29)
        backSprite:addChild(self.mNeedSprite)
        self.mNeedSprite:setVisible(false)
    end

	-- 关闭按钮
    local _, _, eventID = Guide.manager:getGuideInfo()
	self.mCloseBtn = ui.newButton({
		normalImage = "c_28.png",
        text = eventID == 10206 and TR("上阵") or TR("关 闭"),
        -- size = cc.size(140, 60),
        textColor = Enums.Color.eWhite,
        anchorPoint = cc.p(0.5, 1),
        position = cc.p(self.mBackSize.width * 0.7, -self.mBackSize.height * 0.22),
        clickAction = function()
            if eventID == 10206 then
                Guide.manager:nextStep(10206)
                LayerManager.showSubModule(ModuleSub.eFormation)
            else
                if self.mCloseCallBack then
                    self.mCloseCallBack()
                end
                LayerManager.removeLayer(self)
            end
        end
	})
	backSprite:addChild(self.mCloseBtn)

    -- 添加分享按钮
    self.mShareBtn = ui.newButton({
        normalImage = "qq_11.png",
        position = cc.p(self.mBackSize.width * 0.5, - self.mBackSize.height * 0.22),
        clickAction = function()
            local shareFBData = {
                url = "http://xln.gamedreamer.com/",
            }
            
            local jstr = json.encode(shareFBData)

            IPlatform:getInstance():invoke("ShareToFB",jstr, function(jsonStr) 
                local data = cjson.decode(jsonStr)
                if data["ret"] == "0" then
                    ui.showFlashView(TR("分享成功！"))
                else
                    --分享失败
                    ui.showFlashView(TR("分享失败！！"))
                end
            end)
        end,
    })
    backSprite:addChild(self.mShareBtn)

    if self.mTypeFrom then
    	-- 再招一次 按钮
    	self.mRecuritAgainBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("抽一次"),
            -- size = cc.size(140, 60),
            textColor = Enums.Color.eWhite,
            anchorPoint = cc.p(0.5, 1),
            position = cc.p(self.mBackSize.width * 0.3, -self.mBackSize.height * 0.22),
            clickAction = function()
                local itemsCount = TimedRecruitCreditrewardRelation.items_count
                if (self.mBlessNum and self.mBlessNum == 0 and self.mCredit >= TimedRecruitCreditrewardRelation.items[itemsCount].needCredit)
                    or (self.mBlessNum and self.mBlessNum > 0 and self.mBlessNum >= TimedRecruitModel.items[self.mActivityId].receiveBlessNum) then
                    MsgBoxLayer.addOKLayer(
                        TR("请领取宝箱后再进行抽取哟"),
                        TR("提示"),
                        {
                            {
                                text = TR("确定"),
                                clickAction = function(layerObj, btnObj)
                                    LayerManager.removeLayer(layerObj)
                                    LayerManager.removeLayer(self)
                                end
                            }
                        },
                        nil,
                        false
                    )
                else
                    self.mBtnCallBack(self.mRecruitBtnType)
                    LayerManager.removeLayer(self)
                end
            end
        })
        backSprite:addChild(self.mRecuritAgainBtn)

        --------------------显示消耗-------------------

        local recruitUse = Utility.analysisStrResList(HeroRecruitModel.items[self.mRecruitBtnType].recruitUse)
        recruitTenType = recruitUse[1].resourceTypeSub
        recruitTenCount = recruitUse[1].num
        recruitTenModelId = recruitUse[1].modelId

        if self.mRecruitBtnType > 1 then
            local num = 0
            local numStr = ""
            local picName =  Utility.getDaibiImage(recruitTenType, recruitTenModelId)
            if self.mTypeFrom == ModuleSub.eRecruit then
                num = self.mRecruitUse[self.mRecruitBtnType][1].num
                numStr = string.format("%s/%s", GoodsObj:getCountByModelId(self.mRecruitUse[self.mRecruitBtnType][1].modelId), num)
            else
                picName = "xshd_48.png"
                num = self.mTimedRecruit[self.mActivityId].recruitPrice
                recruitTenType = ResourcetypeSub.eDiamond
                recruitTenModelId = 0
                numStr = TR("*1 (%s元宝)", num)  -- 限时招募的时候只显示资源数量
            end
            local costLabel = ui.newLabel({
                text = string.format("{%s} %s", picName, numStr),
                color = Utility.getOwnedGoodsCount(recruitTenType, recruitTenModelId) >= num and Enums.Color.eNormalGreen or Enums.Color.eRed,
                align = ui.TEXT_ALIGN_CENTER
            })
            costLabel:setPosition(self.mRecuritAgainBtn:getContentSize().width * 0.5-3, 80) -- 减3个像素是因为有图片的原因 感觉没有居中
            self.mRecuritAgainBtn:addChild(costLabel)
        else
            if self.mTypeFrom == ModuleSub.eRecruit then
                local picName =  Utility.getDaibiImage(recruitTenType, recruitTenModelId)
                local numStr = string.format("%s/%s", GoodsObj:getCountByModelId(recruitTenModelId), recruitTenCount)

                local costLabel = ui.newLabel({
                    text = string.format("{%s}   %s", picName, numStr),
                    color = Utility.getOwnedGoodsCount(recruitTenType, recruitTenModelId) >= recruitTenCount and Enums.Color.eNormalGreen or Enums.Color.eRed,
                    align = ui.TEXT_ALIGN_CENTER
                })
                costLabel:setPosition(self.mRecuritAgainBtn:getContentSize().width * 0.5-3, 80)
                self.mRecuritAgainBtn:addChild(costLabel)
            else
                self.mRecuritAgainBtn:setVisible(false)
                self.mCloseBtn:setPosition(self.mBackSize.width * 0.5, - self.mBackSize.height * 0.22)
            end
        end
    else       
        self.mCloseBtn:setPosition(self.mBackSize.width * 0.5, - self.mBackSize.height * 0.22)
    end

    -- 详情按钮
    self.mShowDetailBtn = ui.newButton({
        normalImage = "c_79.png",
        anchorPoint = cc.p(1, 0.5),
        position = cc.p(self.mBackSize.width * 0.95, self.mBackSize.height * 0.8),
        scale = 1.2,
        clickAction = function()
            if self.mHeroBaseInfo.ID then
                local layerParams = {
                    heroId = nil,
                    heroModelId = self.mHeroBaseInfo.ID,
                    onlyViewInfo = true
                }
                LayerManager.addLayer({
                    name="hero.HeroInfoLayer",
                    data = layerParams,
                    cleanUp=false
                })
            else
                -- 暂不支持时装信息
                -- local layerParams = {
                --     modelId = self.mHeroBaseInfo.modelId
                -- }
                -- LayerManager.addLayer({
                --     name="fashion.FashionDetailLayer",
                --     data = layerParams,
                --     cleanUp=false
                -- })
            end
        end
    })
    self.mShowDetailBtn:setOpacity(0)
    backSprite:addChild(self.mShowDetailBtn, 1)
end

-- 添加人物及其背景效果
function HeroRecruitShowActionLayer:addHeroAndEffect()
    -- 人物出场的动画效果
    local effectName, zhaomuEffect, animation, music = nil, nil, nil, nil
    local isShowBgG = true
    if self.mHeroBaseInfo.quality >= 13 then
        effectName = "effect_ui_shengjiangchuchang_jin"
    elseif self.mHeroBaseInfo.quality >= 10 then
        effectName = "effect_ui_shengjiangchuchang_zi"
    elseif self.mHeroBaseInfo.quality >= 6 then
        effectName = "effect_ui_shengjiangchuchang_lan"
    else
        effectName = "effect_ui_shengjiangchuchang_lan"
        
        isShowBgG = false
    end
    -- 若不是招募（如：合成，开包）
    if self.isNotRecruit then
        zhaomuEffect = effectName
        animation = "luo"
        music = "renwuhecheng_01.mp3"
        position = cc.p(self.mBackSize.width / 2, self.mBackSize.height * 0.4)
    else
        zhaomuEffect = "effect_ui_zhaomu"
        animation = "animation"
        music = "zhaomu.mp3"
        position = cc.p(self.mBackSize.width / 2, self.mBackSize.height * 0.6)
    end
    local effect1 = ui.newEffect({
        parent = self.mBgSprite,
        effectName = zhaomuEffect,
        position = position,
        animation = animation,
        loop = false,
        scale = 1.5,
        endRelease = true,
        startListener = function()
            MqAudio.playEffect(music)
        end,
        completeListener = function()
            -- 英雄淡入->相关文字描述淡入->星星动画淡入->两个按钮由下到上进入
            self:showAnimationEffect()
        end
    })
    -- 播放音效
    MqAudio.playEffect(music)

    -- local effect2 = ui.newEffect({
    --     parent = self.mBgSprite,
    --     effectName = effectName,
    --     position = cc.p(self.mBackSize.width / 2, self.mBackSize.height * 0.6),
    --     loop = false,
    --     animation = "luo",
    --     endRelease = true,
    --     scale = 1.5,
    -- })

    -- 人物背面的发光效果
    self.mLightEffect = ui.newEffect({
        parent = self.mBgSprite,
        effectName = effectName,
        position = cc.p(self.mBackSize.width * 0.5 + 30, self.mBackSize.height * 0.6 - 30),
        loop = true,
        animation = "guangyun",
        endRelease = false,
    })
    self.mLightEffect:setOpacity(0)
    self.mLightEffect:setVisible(isShowBgG)

    -- 人物
    self.mHeadSprite = Figure.newHero({
        heroModelID = self.mHeroInfo[1].ModelId or Player.slotInfo[1].ModelId,
        fashionModelID = self.mHeroInfo[1].ModelId or 0,
        position = cc.p(self.mBackSize.width * 0.5, self.mBackSize.height * 0.4),
        scale = 0.3,
        buttonAction = function()
            if self.mHeroBaseInfo.ID then
                local layerParams = {
                    heroId = nil,
                    heroModelId = self.mHeroBaseInfo.ID,
                    onlyViewInfo = true
                }
                LayerManager.addLayer({
                    name="hero.HeroInfoLayer",
                    data = layerParams,
                    cleanUp = false
                })
            else
                -- 暂不支持时装信息
                -- local layerParams = {
                --     modelId = self.mHeroBaseInfo.modelId
                -- }
                -- LayerManager.addLayer({
                --     name = "fashion.FashionDetailLayer",
                --     data = layerParams,
                --     cleanUp = false
                -- })
            end
        end
    })
    self.mHeadSprite:setOpacity(0)
    self.mBgSprite:addChild(self.mHeadSprite)
    -- 刚创建时不可点击，等到动画执行完后才可点击
    self.mHeadSprite.button:setEnabled(false)
end

-- 添加英雄的相关显示信息
function HeroRecruitShowActionLayer:addHeroShownInfo()
    -- 名字标签
    local nameColor = Utility.getQualityColor(self.mHeroBaseInfo.quality, 1)
    self.mNameLabel = ui.createLabelWithBg({
        bgFilename = "c_25.png",
        labelStr = self.mHeroBaseInfo.name,
        color = nameColor,
        alignType = ui.TEXT_ALIGN_CENTER
    })
    self.mNameLabel:setPosition(self.mBackSize.width * 0.5, self.mBackSize.height * 0.33)
    self.mBgSprite:addChild(self.mNameLabel)
    self.mNameLabel:setVisible(false)

    -- 主将阵营
    self.mHeroSign = Figure.newHeroRaceAndQuality(self.mHeroModelId)
    if (self.mHeroSign ~= nil) then
        self.mHeroSign:setPosition(self.mBackSize.width * 0.3, self.mBackSize.height * 0.73)
        self.mBgSprite:addChild(self.mHeroSign, 1)
        self.mHeroSign:setScale(10)
        self.mHeroSign:setVisible(false)
    end
end

-- 各个UI元素透明度变化动画
function HeroRecruitShowActionLayer:showAnimationEffect()
    -- 人物执行的动画序列
    local seq = cc.Sequence:create(cc.FadeIn:create(0.5),
        cc.CallFunc:create(function()
            -- 播放人物配音
            local heroData = HeroModel.items[self.mHeroModelId]
            if ((heroData) and ((heroData.modelId and heroData.modelId > 0) or (heroData.ID and heroData.ID > 0))) then
                if self.mCurentSoundID then
                    MqAudio.stopEffect(self.mCurentSoundID)
                end
                local _, staySound = Utility.getHeroSound(heroData)
                self.mCurentSoundID = MqAudio.playEffect(Utility.randomStayAudio(staySound))
            end

            -- 人名标签
            self.mNameLabel:setVisible(true)

            -- 额外获得的物品
            -- if self.mGoodSprite then
            --     self.mGoodSprite:setVisible(true)
            --     self.mGoodHead:runAction(cc.FadeIn:create(0.2))
            -- end

            -- "再招募多少次必出xx" "本次必出...."标签
            if self.mNeedSprite then
                self.mNeedSprite:setVisible(true)
            end

            -- 查看按钮淡入
            self.mShowDetailBtn:runAction(cc.Sequence:create(
                cc.FadeIn:create(0.2),
                cc.CallFunc:create(function()
                    local actions = {}
                    --[[--------新手引导--------]]--
                    local _, _, eventID = Guide.manager:getGuideInfo()
                    if eventID == 10206 then
                        local executeGuide = cc.CallFunc:create(function()
                            self:executeGuide()
                        end)
                        table.insert(actions, executeGuide)
                    end

                    -- 再招一次按钮
                    if self.mRecuritAgainBtn then
                        if self.mGoodInfo then
                            self.mRecuritAgainBtn:runAction(cc.MoveTo:create(0.3, cc.p(self.mBackSize.width * 0.3, self.mBackSize.height * 0.15)))
                        else
                            self.mRecuritAgainBtn:runAction(cc.MoveTo:create(0.3, cc.p(self.mBackSize.width * 0.3, self.mBackSize.height * 0.22)))
                        end
                    end

                    local shareAction = nil
                    -- 关闭按钮,分享按钮
                    -- 普通招募或限时招募
                    if self.mTypeFrom then
                        if self.mTypeFrom == ModuleSub.eRecruit or self.mRecruitBtnType > 1 then
                            if self.mGoodInfo then
                                table.insert(actions, 1, cc.MoveTo:create(0.3, cc.p(self.mBackSize.width * 0.7, self.mBackSize.height * 0.15)))
                                shareAction = cc.MoveTo:create(0.3, cc.p(self.mBackSize.width * 0.5, self.mBackSize.height * 0.07))
                            else
                                table.insert(actions, 1, cc.MoveTo:create(0.3, cc.p(self.mBackSize.width * 0.7, self.mBackSize.height * 0.22)))
                                shareAction = cc.MoveTo:create(0.3, cc.p(self.mBackSize.width * 0.5, self.mBackSize.height * 0.12))
                            end
                        else
                            table.insert(actions, 1, cc.MoveTo:create(0.3, cc.p(self.mBackSize.width * 0.5, self.mBackSize.height * 0.22)))
                            shareAction = cc.MoveTo:create(0.3, cc.p(self.mBackSize.width * 0.5, self.mBackSize.height * 0.27))
                        end
                    -- 神将招募
                    else
                        table.insert(actions, 1, cc.MoveTo:create(0.3, cc.p(self.mBackSize.width * 0.5, self.mBackSize.height * 0.22)))
                        shareAction = cc.MoveTo:create(0.3, cc.p(self.mBackSize.width * 0.5, self.mBackSize.height * 0.27))
                    end
                    self.mCloseBtn:runAction(cc.Sequence:create(actions))
                    self.mShareBtn:runAction(shareAction)

                    -- 阵营标签
                    if self.mHeroSign then
                        self.mHeroSign:setVisible(true)
                        self.mHeroSign:runAction(cc.ScaleTo:create(0.15, 1))
                    end
                end)
            ))
        end),
        cc.DelayTime:create(1.8),
        cc.CallFunc:create(function()
            self.mHeadSprite.button:setEnabled(true)
        end)
    )

    self.mHeadSprite:runAction(seq)
    self.mLightEffect:runAction(cc.FadeIn:create(0.5))
    if self.mLightEffect:isVisible() then
        MqAudio.playEffect("renwuhecheng_02.mp3")
    end

    -- 调用评价
    local heroModel = HeroModel.items[self.mHeroInfo[1].ModelId]
    if heroModel.quality >= 15 and device.platform == "ios" and not self.isNotRecruit then
        print("调用评价SDK接口")
        IPlatform:getInstance():invoke("AppStoreScore", "", function() end) 
    end
end

-- 配置招募花费表
function HeroRecruitShowActionLayer:configRecruitUseTable()
	-- 普通招募
    if self.mTypeFrom == ModuleSub.eRecruit then
		self.mRecruitUse = {}
	    for i = 1, HeroRecruitModel.items_count do
	        local useItem = Utility.analysisStrResList(HeroRecruitModel.items[i].recruitUse)
	        table.insert(self.mRecruitUse, useItem)
	    end
	-- 限时招募
    elseif self.mTypeFrom == ModuleSub.eTimedRecruit then
        self.mTimedRecruit = {}
        for i, v in pairs(TimedRecruitModel.items) do
            self.mTimedRecruit[i] = v
        end
    end
end

--[[ 网络相关 ]]--

-- ========================== 新手引导 ===========================
-- 进入该页面时的执行函数
function HeroRecruitShowActionLayer:onEnterTransitionFinish()
    local _, _, eventID = Guide.manager:getGuideInfo()
    if eventID == 10206 then
        -- 引导时屏蔽其它操作
        Guide.manager:showGuideLayer({})
    end
end

-- 执行新手引导
function HeroRecruitShowActionLayer:executeGuide()
    Guide.helper:executeGuide({
        [10206] = {clickNode = self.mCloseBtn},
    })
end

return HeroRecruitShowActionLayer
