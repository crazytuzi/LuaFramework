--[[
	文件名：HeroRecruitShowTenActionLayer.lua
	描述：人物招募之招募十次动画页面
	创建人：libowen
    修改人：chenqiang
	创建时间：2016.5.10
--]]

-- 该页面由LayerManager直接添加，需适配
local HeroRecruitShowTenActionLayer = class("HeroRecruitShowTenActionLayer", function(params)
	return display.newLayer(cc.c4b(0, 0, 0, 255))
end)

-- 构造函数
--[[
	params:
	Table params:
	{
		heroList    		-- 必须的参数，招募十次所得的10个英雄列表
		goodInfo 			-- 可选的参数，额外掉落的道具信息
		recruitBtnType  	-- 必须的参数，招募按钮的类型，哪种方式的哪个招募按钮
		btnCallBack 		-- 必须的参数，再招十次按钮回调
		closeCallBack 		-- 可选的参数，关闭该页面时的回调
		activityID 			-- 可选的参数，限时招募活动ID
		needCrd             --上线
        isCanEvaluate       -- 是否可以调用评价sdk接口
	}
--]]
function HeroRecruitShowTenActionLayer:ctor(params)
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})

    -- 初始化数据
    self.mHeroList = params and params.heroList
    self.mGoodInfo = params and params.goodInfo
    self.mRecruitBtnType = params and params.recruitBtnType
    self.mBtnCallBack = params and params.btnCallBack
    self.mCloseCallBack = params and params.closeCallBack
	self.mActivityID = params.activityID and params.activityID or nil
    self.mNeedCrd = params.needCrd and params.needCrd or nil
    self.isCanEvaluate = params.isCanEvaluate

    self.mBlessNum = params and params.blessNum
    self.mCredit = params and params.credit

	self.mShownHeroIndex = 1                            -- 当前显示的英雄的索引号
    self.mShowAll = false                            	-- 是否直接显示所有英雄
    self.mHeroNode = {}									-- 存放英雄实例
    self.mAllowShowSpecialHeroLayer = true 				-- 当前是否允许显示橙色英雄的专属展示页面
    self.mNotShowAllHeros = true 						-- 当前页面还未展示全部英雄，意味着还未点击屏幕让10个英雄一下子显示出来

    -- 对某些数据做特殊处理
    self:configSomeData()

    -- 添加UI
    self:initUI()

    -- 添加触摸事件
    self:addTouchEventToLayer()

  	-- 逐个招募英雄
    self:showOneHero()
end

-- 添加UI相关
function HeroRecruitShowTenActionLayer:initUI()
	-- 父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	-- 背景
    local backSprite = ui.newSprite("sc_25.jpg")
    backSprite:setPosition(320, 568)
    self.mParentLayer:addChild(backSprite)
    self.mBackSize = backSprite:getContentSize()
    self.mBackGround = backSprite

    -- 显示关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("关 闭"),
        textColor = Enums.Color.eWhite,
        anchorPoint = cc.p(0.5, 0),
        position = self.mRecruitBtnType ~= 40 and cc.p(self.mBackSize.width * 0.7, -120)
                    or cc.p(self.mBackSize.width * 0.5, -120),
        clickAction = function()
            if self.mCloseCallBack ~= nil then
                self.mCloseCallBack()
            end
            LayerManager.removeLayer(self)
        end
    })
    backSprite:addChild(self.mCloseBtn)

    -- 再招十次按钮
    local recruitTenCount = nil
    local recruitTenType = nil
    local recruitTenModelId = nil
    if self.mRecruitBtnType ~= 40 then
        self.mRecuritAgainBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("十连抽"),
            textColor = Enums.Color.eWhite,
            anchorPoint = cc.p(0.5, 0),
            position = cc.p(self.mBackSize.width * 0.28, -120),
            clickAction = function()
                local itemsCount = TimedRecruitCreditrewardRelation.items_count
				print("111111111111", self.mBlessNum, self.mCredit, self.mActivityID, TimedRecruitCreditrewardRelation.items[itemsCount].needCredit)
                if (self.mBlessNum and self.mBlessNum == 0 and self.mCredit >= TimedRecruitCreditrewardRelation.items[itemsCount].needCredit)
                    or (self.mBlessNum and self.mBlessNum > 0 and self.mBlessNum >= TimedRecruitModel.items[self.mActivityID].receiveBlessNum) then
						print("xxxxxxxxx")
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
                            {}
                        )
                else
                    self.mBtnCallBack(self.mRecruitBtnType)
                    LayerManager.removeLayer(self)
                end
            end
        })
        backSprite:addChild(self.mRecuritAgainBtn)
		local recruitUse = {}
		if self.mRecruitBtnType == 30 then
			recruitUse = Utility.analysisStrResList(HeroRecruitModel.items[4].recruitUse)
		else
			recruitUse = Utility.analysisStrResList(HeroRecruitModel.items[self.mRecruitBtnType].recruitUse)
		end
        if not self.mActivityID then
            recruitTenType = recruitUse[1].resourceTypeSub
            recruitTenCount = recruitUse[1].num
            recruitTenModelId = recruitUse[1].modelId
        else
            recruitTenType = ResourcetypeSub.eDiamond
            recruitTenCount = TimedRecruitModel.items[self.mActivityID].recruitPrice * 10
            recruitTenModelId = 0
        end
    else
        self.mRecuritAgainBtn = ccui.Widget:create()
        self:addChild(self.mRecuritAgainBtn)
    end

    -----------------招募消耗-------------------
    -- 消耗10个灵符
    if self.mRecruitBtnType == 10 then
        local picName =  Utility.getDaibiImage(recruitTenType, recruitTenModelId)
        -- 消耗的道具
        local castTenLabel = ui.newLabel({
            text = string.format("{%s} %d", picName, recruitTenCount),
            color = Utility.getOwnedGoodsCount(recruitTenType, recruitTenModelId) >= recruitTenCount and Enums.Color.eNormalGreen or Enums.Color.eRed,
            align = ui.TEXT_ALIGN_CENTER
        })
        castTenLabel:setPosition(self.mRecuritAgainBtn:getContentSize().width * 0.5, 80)
        self.mRecuritAgainBtn:addChild(castTenLabel)
    -- 元宝招募十次
    elseif self.mRecruitBtnType == 30 then
    	local picName = "xshd_48.png"
    	local num = recruitTenCount
        local recruitLabel = ui.newLabel({
            text = TR("{%s}*10 (%d元宝)", picName, num),
            color = Utility.getOwnedGoodsCount(recruitTenType, recruitTenModelId) >= recruitTenCount and Enums.Color.eNormalGreen or Enums.Color.eRed,
            align = ui.TEXT_ALIGN_CENTER
        })
        recruitLabel:setAnchorPoint(cc.p(0.5, 1))
        recruitLabel:setPosition(cc.p(self.mRecuritAgainBtn:getContentSize().width * 0.5, 0))
        self.mRecuritAgainBtn:addChild(recruitLabel)
    end

    -- 额外掉落的道具
    if self.mGoodInfo ~= nil then
        local goodName = ConfigFunc:getGoodsName(self.mGoodInfo[1].ModelId)
        local goodNum = self.mGoodInfo[1].Num

        -- 额外获得XXXX标签
        self.mGoodSprite = ui.newLabel({
            text = TR("额外获得             %sx%d", Enums.Color.eNormalGreenH, goodNum),
            color = Enums.Color.eWhite,
            align = ui.TEXT_ALIGN_CENTER
        })
        self.mGoodSprite:setAnchorPoint(cc.p(0.5, 1))
        self.mGoodSprite:setPosition(self.mBackSize.width * 0.5, self.mBackSize.height * 0.14)
        backSprite:addChild(self.mGoodSprite)
        self.mGoodSprite:setVisible(false)

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
        self.mGoodSprite:addChild(self.mGoodHead)
    end
end

-- 对某些表做特殊预处理
function HeroRecruitShowTenActionLayer:configSomeData()
	-- 处理数据，保证第一个不是15资质的将
    if HeroModel.items[self.mHeroList[1].ModelId].quality == 15 then
        for i, v in ipairs(self.mHeroList) do
            if HeroModel.items[v.ModelId].quality ~= 15 then
                local temp = nil
                temp = self.mHeroList[i]
                self.mHeroList[i] = self.mHeroList[1]
                self.mHeroList[1] = temp
                break
            end
        end
    end

    -- 处理主将列表，判断是否有道具包
    local pos = math.random(3, 8)
    if table.maxn(self.mHeroList) == 9 then
        table.insert(self.mHeroList, pos, {})
    end

   	-- 10个英雄的摆放位置
    self.mHerosPos = {
        [1] = cc.p(100, 800),
        [2] = cc.p(250, 800),
        [3] = cc.p(400, 800),
        [4] = cc.p(550, 800),
        [5] = cc.p(100, 520),
        [6] = cc.p(250, 520),
        [7] = cc.p(400, 520),
        [8] = cc.p(550, 520),
        [9] = cc.p(320 - 75, 240),
        [10] = cc.p(320 + 75, 240)
    }
end

-- 为当前Layer添加触摸事件
function HeroRecruitShowTenActionLayer:addTouchEventToLayer()
	-- 添加触摸事件
    ui.registerSwallowTouch({
    	node = self.mBackGround,
        beganEvent = function (touch, event)
        	-- 第一次触摸进行判断，如果没有执行以下内容 显示全部的英雄，则执行以下内容，否则跳过
            if ((self.mNotShowAllHeros ~= nil) and (self.mNotShowAllHeros == true)) then
                -- 关闭和再招十次按钮
                -- 道具10连和商城10连关闭按钮位置不同
                if self.mRecruitBtnType ~= 40 then
                    self.mCloseBtn:runAction(cc.MoveBy:create(0.2, cc.p(0, 180)))
                else
                    self.mCloseBtn:runAction(cc.MoveBy:create(0.2, cc.p(0, 180)))
                end
                self.mRecuritAgainBtn:runAction(cc.MoveTo:create(0.2, cc.p(self.mBackSize.width * 0.28, 60)))

                -- 额外道具
                if self.mGoodSprite ~= nil then
                    self.mGoodSprite:setVisible(true)
                end

                -- 移除正在显示的英雄入场动画效果
                self.mEnteringEffect:removeFromParent(true)
                -- 移除已经存在的所有英雄及其上面的猛将、神将标志
                for i = 1, 10 do
                    if self.mHeroNode[i] then
                        -- 移除英雄背景光
                        if self.mHeroNode[i].beiguangEffect then
                            self.mHeroNode[i].beiguangEffect:removeFromParent(true)
                            self.mHeroNode[i].beiguangEffect = nil
                        end

                        -- 移除猛将神将标志
                        if self.mHeroNode[i].heroSign then
                            self.mHeroNode[i].heroSign:removeFromParent()
                            self.mHeroNode[i].heroSign = nil
                        end

                        -- 移除英雄
                        self.mHeroNode[i]:removeFromParent()
                        self.mHeroNode[i] = nil
                    end
                end

                -- 重新添加英雄相关
                for i = 1, 10 do
                	-- 判断是否是限时英雄
                    local count = 0
                    for k, v in pairs(self.mHeroList[i]) do
                        if v ~= nil then
                            count = count + 1
                        end
                    end

                    -- 普通英雄招募
                    if count ~= 0 then
                        -- 产生一个带名字 资质 标志信息的英雄
                        local hero = self:produceOneHero(i, true, 255)

                        -- 英雄背景光
                        if HeroModel.items[self.mHeroList[i].ModelId].quality == 15 or HeroModel.items[self.mHeroList[i].ModelId].quality == 13 then
                            hero.beijingEffect = ui.newEffect({
                                parent = self.mBackGround,
                                effectName = "effect_ui_shengjiangchuchang_jin",
                                position = cc.p(self.mHerosPos[i].x, self.mHerosPos[i].y + 80),
                                loop = true,
                                scale = 0.6,
                                animation = "guangyun",
                                endRelease = false,
                            })
                        end
                    -- 神将招募
                    else
                        local layerParams = {
                            activityEnumId = self.mActivityID,
                            isBless = false,
                            recruitType = self.mRecruitBtnType,
                            callback = function(heroId)
                                self.mHeroList[i].ModelId = heroId
                                self:showSpecialHero(i)
                            end
                        }

                        LayerManager.addLayer({
                            name = "activity.ChooseGoldHeroLayer",
                            data = layerParams,
                            cleanUp = false
                        })
                    end

                    -- 调用评价
                    if self.mHeroList[i].ModelId then
                        local heroModel = HeroModel.items[self.mHeroList[i].ModelId]
                        if heroModel.quality >= 15 and device.platform == "ios" then
                            IPlatform:getInstance():invoke("AppStoreScore", "", function() end) 
                        end
                    end
                end

                self.mNotShowAllHeros = false
                return true
            end
        end})
end

-- 显示页面
function HeroRecruitShowTenActionLayer:showSpecialHero(index)
    local currHero = self.mHeroList[index]
    local currPos = self.mHerosPos[index]
    if ((currHero == nil) or (currPos == nil)) then
        return
    end
    if index == 10 then
        self.mNotShowAllHeros = false
    end

    -- 产生一个带有名字 资质 标志信息的英雄
    local hero = self:produceOneHero(index, true, 0)

    -- 英雄背景光效果
    if Utility.getColorLvByModelId(currHero.ModelId) >= 5 then
        hero.beiguangEffect = ui.newEffect({
            parent = self.mBackGround,
            effectName = "effect_ui_shengjiangchuchang_jin",
            position = cc.p(currPos.x, currPos.y + 80),
            loop = true,
            scale = 0.6,
            animation = "guangyun",
            endRelease = false,
        })
        ui.newEffect({
            parent = self.mBackGround,
            zorder = 1,
            effectName = "effect_ui_shengjiangchuchang_jin",
            position = cc.p(currPos.x, currPos.y + 80),
            loop = true,
            scale = 0.6,
            animation = "lizi",
            endRelease = false,
        })
        hero.beiguangEffect:setOpacity(0)
    end

    -- 英雄进场动画完毕后的回调
    local function showEffect()
        local fadeAction = cc.FadeIn:create(0.02)
        hero:runAction(fadeAction)

        hero.heroName:runAction(cc.FadeIn:create(0.3))

        hero.heroQuality:runAction(cc.FadeIn:create(0.3))

        if hero.heroSign ~= nil then
            hero.heroSign:runAction(cc.FadeIn:create(0.5))
        end

        if hero.beiguangEffect ~= nil then
            hero.beiguangEffect:runAction(cc.FadeIn:create(0.3))
        end
    end

    -- 英雄进场动画
    local effectName, animation, music = nil, nil, nil
    if Utility.getColorLvByModelId(currHero.ModelId) >= 5 then
        effectName = "effect_ui_shengjiangchuchang_jin"
        -- animation = "zhaomu"
        music = "sound_zhaomu_2.mp3"
    else
        effectName = "effect_ui_shengjiangchuchang_zi"
        -- animation = "animation"
        music = "sound_zhaomu_1.mp3"
    end

    self.mEnteringEffect = ui.newEffect({
        parent = self.mBackGround,
        effectName = "effect_ui_zhaomu",
        position = cc.p(currPos.x, currPos.y + 80),
        loop = false,
        scale = 0.25,
        speed = 3,
        endRelease = true,
        -- eventListener = function(p)
        --     if p.event.stringValue == "end" then
        --         showEffect()
        --     end
        -- end,
        startListener = function()
            MqAudio.playEffect(music)
        end,
        completeListener = function()
            showEffect()
        end
    })
    -- ui.newEffect({
    --     parent = self.mBackGround,
    --     effectName = effectName,
    --     position = cc.p(currPos.x, currPos.y + 80),
    --     loop = false,
    --     scale = 0.25,
    --     speed = 3,
    --     animation = "guangyun",
    --     endRelease = true
    -- })
end

-- 显示一个英雄
function HeroRecruitShowTenActionLayer:showOneHero()
    -- 所有英雄都出来了之后，处理相关的东西
    if self.mShownHeroIndex == 11 then
        -- 道具10连和商城10连关闭按钮位置不同
        if self.mRecruitBtnType ~= 40 then
            self.mCloseBtn:runAction(cc.MoveBy:create(0.2, cc.p(0, 180)))
        else
            self.mCloseBtn:runAction(cc.MoveBy:create(0.2, cc.p(0, 180)))
        end
        self.mRecuritAgainBtn:runAction(cc.MoveTo:create(0.2, cc.p(self.mBackSize.width * 0.28, 60)))

        -- 每个英雄设置为可点击
        for i,v in pairs(self.mHeroNode) do
            self.mHeroNode[i].button:setEnabled(true)
        end
        -- 显示额外道具
        if self.mGoodSprite ~= nil then
            self.mGoodSprite:setVisible(true)
        end

        return
    end

    -- 通过服务器返回的英雄的属性来判断是否需要跳转到限时招募的神将选择页面
    local count = 0
    for k, v in pairs(self.mHeroList[self.mShownHeroIndex]) do
        if v ~= nil then
            count = count + 1
        end
    end
    -- 显示招募神将选择页面
    if count == 0 and self.mNotShowAllHeros == true then
        local layerParams = {
            activityEnumId = self.mActivityID,
            isBless = false,
            recruitType = self.mRecruitBtnType,
            callback = function(heroId)
                self.mHeroList[self.mShownHeroIndex].ModelId = heroId

                -- 置为false，表示接下来的英雄展示要显示小动画而非大动画
                self.mAllowShowSpecialHeroLayer = false
                self:showOneHero()
            end
        }
        LayerManager.addLayer({
            name = "activity.ChooseGoldHeroLayer",
            data = layerParams,
            cleanUp = false
        })
    -- 品质为15且需要展示大动画，则跳转到大动画页面
    elseif HeroModel.items[self.mHeroList[self.mShownHeroIndex].ModelId].quality == 15
        and self.mAllowShowSpecialHeroLayer == true and self.mNotShowAllHeros == true then

        local layerParams = {
            heroInfo = {
                [1] = {
                	["ModelId"] = self.mHeroList[self.mShownHeroIndex].ModelId,
                }
            },
            closeCallBack = function()
                self.mAllowShowSpecialHeroLayer = false
                self:showOneHero()
            end,
            isCanEvaluate = self.isCanEvaluate,
        }
        LayerManager.addLayer({
            name = "shop.HeroRecruitShowActionLayer",
            data = layerParams,
            cleanUp = false
        })
    -- 从限时招募页面返回、从大动画页面返回、本身是资质小于15的，应该显示小动画
    else
        if self.mNotShowAllHeros == true then
            local currHero = self.mHeroList[self.mShownHeroIndex]
            local currPos = self.mHerosPos[self.mShownHeroIndex]
            if ((currHero == nil) or (currPos == nil)) then
                return
            end
            if self.mShownHeroIndex == 10 then
                self.mNotShowAllHeros = false
            end

            -- 生成一个含有名字 资质 标志的英雄
            local hero = self:produceOneHero(self.mShownHeroIndex, false, 0)

            -- 英雄背景光效果, 资质15和15以下的有2种效果
            if HeroModel.items[currHero.ModelId].quality >= 13 then
                hero.beiguangEffect = ui.newEffect({
                    parent = self.mBackGround,
                    effectName = "effect_ui_shengjiangchuchang_jin",
                    position = cc.p(currPos.x, currPos.y + 80),
                    loop = true,
                    scale = 0.5,
                    animation = "guangyun",
                    endRelease = false,
                })
                hero.beiguangEffect:setOpacity(0)
            end
            if HeroModel.items[currHero.ModelId].quality >= 15 then
                ui.newEffect({
                    parent = self.mBackGround,
                    zorder = 1,
                    effectName = "effect_ui_shengjiangchuchang_jin",
                    position = cc.p(currPos.x, currPos.y + 80),
                    scale = 0.5,
                    loop = true,
                    animation = "lizi",
                    endRelease = false,
                })
            end

            -- 底层背景动画执行完完毕后的回调
            local function showEffect()
                local fadeAction = cc.FadeIn:create(0.02)
                local seq = cc.Spawn:create(fadeAction, cc.CallFunc:create(function()
                	-- 索引递增
            		self.mShownHeroIndex = self.mShownHeroIndex + 1

                    self.mAllowShowSpecialHeroLayer = true
                    self:showOneHero()
                end))
                hero:runAction(seq)

                hero.heroName:runAction(cc.FadeIn:create(0.5))

                hero.heroQuality:runAction(cc.FadeIn:create(0.5))

                if hero.heroSign ~= nil then
                    hero.heroSign:runAction(cc.FadeIn:create(0.5))
                end

                if hero.beiguangEffect ~= nil then
                    hero.beiguangEffect:runAction(cc.FadeIn:create(0.5))
                end
            end

            -- 英雄进场动画效果
            local effectName, animation, music = nil, nil, nil
            if Utility.getColorLvByModelId(currHero.ModelId) >= 5 then
                effectName = "effect_ui_shengjiangchuchang_jin"
                -- animation = "zhaomu"
                music = "renwuhecheng_01.mp3"
            else
                effectName = "effect_ui_shengjiangchuchang_zi"
                -- animation = "animation"
                music = "renwuhecheng_01.mp3"
            end
            self.mEnteringEffect = ui.newEffect({
                parent = self.mBackGround,
                effectName = effectName,
                position = cc.p(currPos.x, currPos.y),
                loop = false,
                scale = 0.5,
                speed = 2,
                animation = "luo",
                endRelease = true,
                -- eventListener = function(p)
                --     if p.event.stringValue == "end" then
                --         showEffect()
                --     end
                -- end,
                -- startListener = function()
                --     MqAudio.playEffect(music)
                -- end,
                completeListener = function()
                    showEffect()
                end
            })
            -- -- 播放音效
            -- if self.mEffect then
            --     MqAudio.stopEffect(self.mEffect)
            --     self.mEffect = nil
            -- end
            self.mEffect = MqAudio.playEffect(music)

            -- ui.newEffect({
            --     parent = self.mBackGround,
            --     effectName = effectName,
            --     position = cc.p(currPos.x, currPos.y + 80),
            --     loop = false,
            --     scale = 0.25,
            --     speed = 5,
            --     animation = "qian",
            --     endRelease = true,
            -- })
        end
    end
end

-- 根据索引号生成一个英雄及其相关的内容，比如名字 资质 标志
--[[
    params:
    index                       -- 必传参数，英雄在表中的索引号
    isClickable                 -- 必传参数，英雄是否可以点击
    alpha                       -- 节点透明度

    return:
    self.mHeroNode[index]       -- 返回这个英雄的引用
--]]
function HeroRecruitShowTenActionLayer:produceOneHero(index, isClickable, alpha)
    -- 当前情况下继续缩放情况
    local scalePx = index <= 4 and 0.8 or index <= 8 and 0.9 or 1.1
    -- 英雄
    self.mHeroNode[index] = Figure.newHero({
        heroModelID = self.mHeroList[index].ModelId,
        position = self.mHerosPos[index],
        swallow = true,
        buttonAction = function()
            local layerParams = {
                heroId = nil,
                heroModelId = self.mHeroList[index].ModelId,
                onlyViewInfo = true
             }
            LayerManager.addLayer({
                name="hero.HeroInfoLayer",
                data = layerParams,
                cleanUp = false
            })
        end
    })
    self.mHeroNode[index].button:setEnabled(isClickable)
    self.mHeroNode[index]:setScale(0.15*scalePx)
    self.mHeroNode[index]:setOpacity(alpha)
    self.mBackGround:addChild(self.mHeroNode[index], 1)

    -- 添加墨汁背景放人物的名字和资质
    local nameBG = ui.newSprite("c_92.png")
    nameBG:setPosition(self.mHeroNode[index]:getBoundingBox().width * self.mHeroNode[index]:getScale() / 2+30, -165)
    nameBG:setScale(7/scalePx)
    nameBG:setScaleY(10/scalePx)
    self.mHeroNode[index]:addChild(nameBG)

    -- 英雄名字
    self.mHeroNode[index].heroName = ui.newLabel({
        text = ConfigFunc:getHeroName(self.mHeroList[index].ModelId),
        color = Utility.getQualityColor(HeroModel.items[self.mHeroList[index].ModelId].quality, 1),
        align = ui.TEXT_ALIGN_CENTER
    })
    self.mHeroNode[index].heroName:setPosition(
        self.mHeroNode[index]:getBoundingBox().width * self.mHeroNode[index]:getScale() / 2,
        - 110
    )
    self.mHeroNode[index].heroName:setOpacity(alpha)
    self.mHeroNode[index]:addChild(self.mHeroNode[index].heroName)
    self.mHeroNode[index].heroName:setScale(4/scalePx)

    -- 英雄资质
    self.mHeroNode[index].heroQuality = ui.newLabel({
        text = TR("资质:%s",HeroModel.items[self.mHeroList[index].ModelId].quality),
        color = Utility.getQualityColor(HeroModel.items[self.mHeroList[index].ModelId].quality, 1),
        align = ui.TEXT_ALIGN_CENTER
    })
    self.mHeroNode[index].heroQuality:setPosition(
        self.mHeroNode[index]:getBoundingBox().width * self.mHeroNode[index]:getScale() / 2,
        - 220
    )
    self.mHeroNode[index].heroQuality:setOpacity(alpha)
    self.mHeroNode[index]:addChild(self.mHeroNode[index].heroQuality)
    self.mHeroNode[index].heroQuality:setScale(4/scalePx)

    -- 神将或猛将标志
    local retBgSprite = Figure.newHeroRaceAndQuality(self.mHeroList[index].ModelId)
    if (retBgSprite ~= nil) then
        retBgSprite:setAnchorPoint(cc.p(0, 0))
        retBgSprite:setPosition(cc.p(self.mHerosPos[index].x - 80, self.mHerosPos[index].y + 100))
        retBgSprite:setOpacity(alpha)
        retBgSprite:setScale(0.8)
        self.mBackGround:addChild(retBgSprite, 1)
        self.mHeroNode[index].heroSign = retBgSprite
    end

    return self.mHeroNode[index]
end

return HeroRecruitShowTenActionLayer
