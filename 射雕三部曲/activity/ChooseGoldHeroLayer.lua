--[[
	文件名：ChooseGoldHeroLayer.lua
	描述：限时招募页面之神将选择页面
	创建人：libowen
    修改人：chenqiang
	创建时间：2016.6.20
--]]

local ChooseGoldHeroLayer = class("ChooseGoldHeroLayer", function (params)
	return display.newLayer()
end)

-- 构造函数
--[[
	params:
	Table params:
	{
		activityEnumId 					-- 必传参数，活动枚举id
		callback 						-- 页面关闭时的回调函数
        isBless                         -- 是通过消耗祝福值来招募神将
        recruitType                     -- 招募类型
        needCloseBtn                    -- 是否需要返回按钮，默认不需要
                                        -- 商城招募或限时招募弹出时不需要此按钮，强制玩家必须选择一个神将
                                        -- 当祝福值达到了，开启神将宝箱时，需要此按钮
	}
--]]
function ChooseGoldHeroLayer:ctor(params)
    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

	-- 初始化数据
	self.mActivityEnumId = params.activityEnumId
	self.mCallBack = params.callback
    self.mIsBless = params.isBless
    self.mRecruitType = params.recruitType
    self.mNeedCloseBtn = params.needCloseBtn or false
	self.mSelectIndex = -1
    self.isCanEvaluate = params.isCanEvaluate

    -- 3个神将modelId列表
    local goodsID = TimedRecruitModel.items[self.mActivityEnumId].goldHeroModelID      -- 产出神将的道具模型id
    self.mHeroIdList = {
        GoodsOutputRelation.items[goodsID][1].outputModelID,
        GoodsOutputRelation.items[goodsID][2].outputModelID,
        GoodsOutputRelation.items[goodsID][3].outputModelID
    }

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 添加UI相关
	self:initUI()
end

function ChooseGoldHeroLayer:initUI()
	-- 背景图
	local bgSprite = ui.newSprite("sc_23.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)
    self.mBgSprite = bgSprite
    self.mBgSize = bgSprite:getContentSize()

    -- 返回按钮
    if self.mNeedCloseBtn then
        local closeBtn = ui.newButton({
            normalImage = "c_29.png",
            position = Enums.StardardRootPos.eCloseBtn,
            clickAction = function (sender)
                self:removeFromParent()
            end
        })
        bgSprite:addChild(closeBtn)
    end

    -- "获得神将"标题
    self.mTitleImage = ui.newSprite("sc_22.png")
    self.mTitleImage:setPosition(320, 1000)
    bgSprite:addChild(self.mTitleImage, 1)
    -- self.mTitleImage:setScale(2)
    self.mTitleImage:setOpacity(0)

    -- 文字描述
    self.mDescLabel = ui.newLabel({
    	text = TR("恭喜获得武林神话侠客，可从三名侠客中选择一位点击确定即可获得该名侠客！"),
    	color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack,
        dimensions = cc.size(415, 0),
    	align = cc.TEXT_ALIGNMENT_CENTER,
        size = 20,
    })
    self.mDescLabel:setPosition(320, 900)
    bgSprite:addChild(self.mDescLabel, 1)

    -- 下方3个按钮
    self:addTwoCardNodes()

    local effect1 = ui.newEffect({
        parent = bgSprite,
        effectName = "effcet_ui_renwuzhaomu_b",
        position = cc.p(320, 568),
        loop = false,
        animation = "zhaomu",
        endRelease = true,
        eventListener = function(p)
            if p.event.stringValue == "end" then
                -- 添加人物
    			self:addSlidingHeros()

                -- 背景光
                -- ui.newEffect({
                --     parent = self.mBgSprite,
                --     effectName = "effect_ui_zhandoushengli_tw",
                --     position = cc.p(320, 1000),
                --     loop = true,
                --     animation = "guang",
                --     endRelease = true,
                --     --speed = 0.8
                -- })

                self.mTitleImage:runAction(cc.FadeIn:create(0.2))
            end
        end,
        completeListener = function()
        end,
        startListener = function()
            MqAudio.playEffect("zhaomu.mp3")
        end
    })

    -- 确定按钮
	self.mOkBtn = ui.newButton({
		normalImage = "c_28.png",
        text = TR("确 定"),
        textColor = Enums.Color.eNormalWhite,
        anchorPoint = cc.p(0.5, 1),
        position = cc.p(self.mBgSize.width * 0.5, self.mBgSize.height * 0.10),
        clickAction = function()
        	if self.mSelectIndex == -1 then
        		ui.showFlashView({
        			text = TR("请选择一个主将！！！")
        		})
        	else
                if self.mIsBless then
                    self:requestDrawGoldHeroForBless(self.mHeroIdList[self.mSelectIndex])
                else
                    self:requestDrawGoldHero(self.mHeroIdList[self.mSelectIndex])
                end
        	end
        end
	})
	bgSprite:addChild(self.mOkBtn)
end

-- 添加下方3个cardNode
function ChooseGoldHeroLayer:addTwoCardNodes()
	self.mCardNodeList = {}
	local heroPos = {
		[1] = cc.p(320 - 150, 200),
		[2] = cc.p(320 + 150, 200),
        [3] = cc.p(320, 200)
	}

	for i = 1, #self.mHeroIdList do

		-- 可点击的卡牌
		local cardNode = CardNode.createCardNode({
			resourceTypeSub = ResourcetypeSub.eHero,
			modelId = self.mHeroIdList[i],
			num = 1,
			cardShowAttrs = {CardShowAttr.eBorder},
			onClickCallback = function ()
                -- 跳转详情界面
                if self.mSelectIndex == i then
                    local tempData = {
                        resourceTypeSub = ResourcetypeSub.eHero,
                        modelId = self.mHeroIdList[i],
                    }
                    CardNode.defaultCardClick(tempData)
                -- 添加选中框
                else
    				self.mSelectIndex = i

    				-- 显示选中框
    				for i, v in ipairs(self.mCardNodeList) do
    					v.selectSpr:setVisible(false)
    				end
    				self.mCardNodeList[i].selectSpr:setVisible(true)
                end
			end
		})
		cardNode:setPosition(heroPos[i])
		self.mBgSprite:addChild(cardNode)
		table.insert(self.mCardNodeList, cardNode)

        --羁绊标签
        local relationStatus = FormationObj:getRelationStatus(self.mHeroIdList[i], ResourcetypeSub.eHero)
        if relationStatus ~= Enums.RelationStatus.eNone then
            local relationStr = {
                [Enums.RelationStatus.eIsMember] = TR("缘份"),  -- 推荐
                [Enums.RelationStatus.eTriggerPr] = TR("可激活"),  -- 缘分
                [Enums.RelationStatus.eSame] = TR("已上阵")   -- 已上阵
            }
            local relationPics = {
                [Enums.RelationStatus.eIsMember] = "c_57.png",  -- 推荐
                [Enums.RelationStatus.eTriggerPr] = "c_58.png",  -- 缘分
                [Enums.RelationStatus.eSame] = "c_62.png"  -- 已上阵
            }
            cardNode:createStrImgMark(relationPics[relationStatus], relationStr[relationStatus])
        end

		-- 选中框
		local selectSpr = ui.newSprite("c_31.png")
		selectSpr:setPosition(cardNode:getPosition())
		self.mBgSprite:addChild(selectSpr)
		selectSpr:setVisible(false)
		cardNode.selectSpr = selectSpr
	end
end

-- 添加持续滑动的神将
function ChooseGoldHeroLayer:addSlidingHeros()
    -- 每帧移动的距离
    local deltaX = 2

    -- 人物形象位置，用于滚动
    self.mHeroPos = {
        [1] = cc.p(self.mBgSize.width * -0.5, self.mBgSize.height * 0.28),
        [2] = cc.p(self.mBgSize.width * 0.5, self.mBgSize.height * 0.28),
        [3] = cc.p(self.mBgSize.width * 1.5, self.mBgSize.height * 0.28),
        [4] = cc.p(self.mBgSize.width * -1.5, self.mBgSize.height * 0.28),
    }

    -- 创建第一个node
    self.mHeroNode1 = cc.Node:create()
    self.mHeroNode1:setPosition(self.mHeroPos[1])
    self.mBgSprite:addChild(self.mHeroNode1)
    -- node上的人物
    self:createHeroByIndex(1, self.mHeroNode1)

    -- 创建第二个node
    self.mHeroNode2 = cc.Node:create()
    self.mHeroNode2:setPosition(self.mHeroPos[2])
    self.mBgSprite:addChild(self.mHeroNode2)
    -- node上的人物
    self:createHeroByIndex(2, self.mHeroNode2)

    -- 创建第三个nodde
    self.mHeroNode3 = cc.Node:create()
    self.mHeroNode3:setPosition(self.mHeroPos[3])
    self.mBgSprite:addChild(self.mHeroNode3)
    -- node上的人物
    self:createHeroByIndex(3, self.mHeroNode3)

    -- 神将持续滑动逻辑(改变神将的显示位置)
    local function updateHeroLocation()
        -- 获取node的坐标
        local pos1X, pos1Y = self.mHeroNode1:getPosition()
        local pos2X, pos2Y = self.mHeroNode2:getPosition()
        local pos3X, pos3Y = self.mHeroNode3:getPosition()

        -- 改变node的位置
        pos1X = pos1X - deltaX
        pos2X = pos2X - deltaX
        pos3X = pos3X - deltaX

        -- 重置node的坐标
        self.mHeroNode1:setPosition(cc.p(pos1X, pos1Y))
        self.mHeroNode2:setPosition(cc.p(pos2X, pos2Y))
        self.mHeroNode3:setPosition(cc.p(pos3X, pos3Y))

        -- 判断神将的位置，到一定距离后重置神将的位置
        if pos1X <= self.mHeroPos[4].x then
            self.mHeroNode1:setPosition(self.mHeroPos[3])
        end

        if pos2X <= self.mHeroPos[4].x then
            self.mHeroNode2:setPosition(self.mHeroPos[3])
        end

        if pos3X <= self.mHeroPos[4].x then
            self.mHeroNode3:setPosition(self.mHeroPos[3])
        end
    end

    -- 定时器
    Utility.schedule(self, updateHeroLocation, 0.01)
end

-- 根据在英雄表中的索引号创建一个包含有名字、阵营的英雄，并添加到指定节点上
--[[
    params:
    index                  英雄表中的索引号，由此号来创建英雄
    parent                 英雄添加到该节点上去

    return:
    hero                   返回新创建的这名英雄
--]]
function ChooseGoldHeroLayer:createHeroByIndex(index, parent)
    -- 创建英雄
    local hero = Figure.newHero({
        heroModelID = self.mHeroIdList[index],
        position = cc.p(parent:getContentSize().width / 2, parent:getContentSize().height / 2),
        scale = 0.325,
		buttonAction = function()
			local tempData = {
				heroModelId = self.mHeroIdList[index],
				onlyViewInfo = false,
			}
			LayerManager.addLayer({name = "hero.HeroInfoLayer", data = tempData, cleanUp = false})
		end,
    })
    parent:addChild(hero)

    -- 名字标签背景
    local nameBg = ui.newSprite("c_25.png")
    nameBg:setPosition(0, 0)
    nameBg:setScale(0.7)
    parent:addChild(nameBg)

    -- 名称
    local heroInfo = HeroModel.items[self.mHeroIdList[index]]
    local nameColor = Utility.getQualityColor(heroInfo.quality, 1)
    local nameLabel = ui.newLabel({
        text = heroInfo.name,
        color = nameColor,
        align = ui.TEXT_ALIGN_CENTER
    })
    nameLabel:setPosition(0, 0)
    parent:addChild(nameLabel)

    -- 阵营标签
    local retBgSprite = Figure.newHeroRaceAndQuality(self.mHeroIdList[index])
    if (retBgSprite ~= nil) then
        retBgSprite:setPosition(120, 80)
        parent:addChild(retBgSprite)
    end
end

-------------------网络相关-----------------
-- 请求服务器，领取神将
--[[
	params:
	heroId  			-- 要招募的神将id，祝福值招募所得
--]]
function ChooseGoldHeroLayer:requestDrawGoldHeroForBless(heroId)
    HttpClient:request({
        moduleName = "TimedRecruitInfo",
        methodName = "DrawGoldHeroForBless",
        svrMethodData = {heroId},
        callbackNode = self,
        callback = function (data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 更新上级页面数据与UI
            if self.mCallBack then
                self.mCallBack(data.Value.BlessNum)
            end

            -- 显示人物招募动画
            local layerParams = {
	            heroInfo = data.Value.BaseGetGameResourceList[1].Hero,
	            recruitBtnType = 3,
	            typeFrom = nil,
                isCanEvaluate = self.isCanEvaluate,
	            closeCallBack = function()
	                LayerManager.removeLayer(self)
	            end
	        }

	        LayerManager.addLayer({
	            name = "shop.HeroRecruitShowActionLayer",
	            data = layerParams,
	            cleanUp = false
	        })
        end
    })
end

-- 请求服务器，获取神将，普通招募、限时招募
--[[
    heroId                  -- 英雄id
--]]
function ChooseGoldHeroLayer:requestDrawGoldHero(heroId)
    HttpClient:request({
        moduleName = "TimedRecruitInfo",
        methodName = "DrawGoldHero",
        svrMethodData = {heroId},
        callbackNode = self,
        callback = function (data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            if self.mRecruitType == 3 or self.mRecruitType == 1 then
                local layerParams = {
                    heroInfo = data.Value.BaseGetGameResourceList[1].Hero,
                    recruitBtnType = self.mRecruitType,
                    activityID = self.mActivityEnumId,
                    typeFrom = ModuleSub.eTimedRecruit,
                    btnCallBack = self.mCallBack,
                    closeCallBack = function()
                        LayerManager.removeLayer(self)
                    end
                }
                LayerManager.addLayer({
                    name = "shop.HeroRecruitShowActionLayer",
                    data = layerParams,
                    cleanUp = false
                })
            -- 在招募10次的过程中，出现神将
            else
                -- heroId传入上一级页面
                self.mCallBack(data.Value.BaseGetGameResourceList[1].Hero[1].ModelId)
                LayerManager.removeLayer(self)

                -- local layerParams = {
                --     heroInfo = {
                --         [1] = {
                --             ["ModelId"] = data.Value.BaseGetGameResourceList[1].Hero[1].ModelId,
                --         }
                --     },
                --     closeCallBack = function()
                --         -- heroId传入上一级页面
                --         self.mCallBack(data.Value.BaseGetGameResourceList[1].Hero[1].ModelId)

                --         LayerManager.removeLayer(self)
                --     end
                -- }
                -- LayerManager.addLayer({
                --     name = "shop.HeroRecruitShowActionLayer",
                --     data = layerParams,
                --     cleanUp = false
                -- })
            end
        end
    })
end
return ChooseGoldHeroLayer
