--[[
	文件名：LightenStarLayer.lua
	描述：拼酒
	创建人：lengjiazhi
	创建时间： 2016.10.19
--]]

local LightenStarLayer = class("practice.LightenStarLayer", function (params)
	return display.newLayer()
end)

--构造函数
--[[
	参数：

--]]
function LightenStarLayer:ctor(params)
	self.mLightStarInfo = {} -- 服务器返回信息
	-- 原人物信息
	self.mOldHeroInfo = clone(HeroObj:getMainHero())
	--页面元素父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self:requestLightenStarInfo()
	self:initUI()

	--顶部公共模块
	local commonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.ePractice,
        topInfos = {ResourcetypeSub.eSTA, ResourcetypeSub.eDiamond, ResourcetypeSub.eGold}
    })
    self:addChild(commonLayer)
end

--初始化UI
function LightenStarLayer:initUI()
	-- --背景图
	local bgSprite = ui.newSprite("pj_03.png")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite, -1)

	-- 人物特效
	local heroEffect = ui.newEffect({
			parent = self.mParentLayer,
			zorder = -1,
			effectName = "ui_effect_dakouhejiu",
			position = cc.p(332, 568),
			loop = true,
			endRelease = true,
		})
	self.heroEffect = heroEffect
	self.heroEffect:addAnimation(0, "daiji", true)

	--返回按钮
	local backBtn = ui.newButton({
		normalImage = "c_29.png",
		position = cc.p(590, 1035),
		clickAction = function ()
			LayerManager.removeLayer(self)
		end
		})
	self.mParentLayer:addChild(backBtn, 1)

	-- 酿酒
	local wineBtn = ui.newButton({
			normalImage = "hj_5.png",
			clickAction = function ()
				if not ModuleInfoObj:moduleIsOpen(ModuleSub.eBrewing, true) then
					return
				end
				LayerManager.addLayer({name = "brew.BrewHomeLayer"})
			end,
		})
	wineBtn:setPosition(574, 930)
	self.mParentLayer:addChild(wineBtn, 1)
end
--下部分提示信息
function LightenStarLayer:bottomView()
	local onekeyIsOpen, onekeyInfo = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eOneKeyPracticeLightenStar, false)
	--信息背景
	local tipBgSprite = ui.newScale9Sprite("c_145.png", cc.size(400, 110))
	local tipBgSize = tipBgSprite:getContentSize()
	tipBgSprite:setAnchorPoint(1, 0)
	tipBgSprite:setPosition(620, 300)
	self.mParentLayer:addChild(tipBgSprite)

	self.mMaxLevelLabel = ui.newLabel({
		text = TR("已满级"),
		size = 30,
		outlineColor = cc.c3b(0x23, 0x23, 0x23)
	})
	self.mMaxLevelLabel:setPosition(tipBgSize.width * 0.5, tipBgSize.height * 0.5)
	self.mMaxLevelLabel:setVisible(false)
	tipBgSprite:addChild(self.mMaxLevelLabel)

	-- 下一次开启信息
	local string1, string2 = self:bottomString(self.mLightStarInfo.StarId)

	--资质提示信息
	local label = ui.newLabel({
		text = string1,
		color = Enums.Color.eNormalWhite,
		outlineColor = cc.c3b(0x23, 0x23, 0x23),
		outlineSize = 2,
		size = 20,
		anchorPoint = cc.p(0.5, 0.5),
	})
	label:setPosition(tipBgSize.width*0.5, 24)
	tipBgSprite:addChild(label)
	self.mBottomLebl1 = label

	--卡槽提示信息
	local label = ui.newLabel({
		text = string2,
		color = Enums.Color.eNormalWhite,
		outlineColor = cc.c3b(0x23, 0x23, 0x23),
		outlineSize = 2,
		size = 20,
		anchorPoint = cc.p(0.5, 0.5),
	})
	label:setPosition(tipBgSize.width*0.5, 52)
	tipBgSprite:addChild(label)
	self.mBottomLebl2 = label

	-- 提升属性
	local promoteAttLabel = ui.newLabel({
			text = "",
			outlineColor = cc.c3b(0x23, 0x23, 0x23),
			size = 22,
			anchorPoint = cc.p(0.5, 0.5),
		})
	promoteAttLabel:setPosition(tipBgSize.width*0.5, 85)
	tipBgSprite:addChild(promoteAttLabel)
	self.mBottomLebl3 = promoteAttLabel
end

--上部信息
function LightenStarLayer:topView()
	-- 信息背景
	local upBg = ui.newScale9Sprite("c_25.png", cc.size(580, 55))
	upBg:setPosition(320, 1050)
	self.mParentLayer:addChild(upBg)

	--已经获得的加成
	local additionLabel = ui.newLabel({
		text = "",
		color = Enums.Color.eYellow,
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
		})
	additionLabel:setAnchorPoint(cc.p(0.5, 0.5))
	additionLabel:setPosition(260, 26)
	upBg:addChild(additionLabel)
	self.mTotalAddLabel = additionLabel

	-- 当前拥有的拼酒
	-- 背景
	local ganwuBg = ui.newScale9Sprite("pj_02.png")
	ganwuBg:setPosition(130, 950)
	self.mParentLayer:addChild(ganwuBg)
	--星数信息
	local label = ui.newLabel({
		text = TR("当前拥有{%s}%s%s", "db_1125.png", Enums.Color.eYellowH, self.mLightStarInfo.StarCount),
		color = Enums.Color.eNormalWhite,
		size = 22,
		anchorPoint = cc.p(0, 0.5),
		outlineColor = Enums.Color.eOutlineColor,
		outlineSize = 2,
		})
	label:setPosition(30, 50)
	self.mStarNumLabel = label
	ganwuBg:addChild(label)

	--已经拼酒的次数
	local label = ui.newLabel({
		text = TR("总拼酒次数: %s%s", Enums.Color.eYellowH, self.mLightStarInfo.StarId),
		color = Enums.Color.eNormalWhite,
		size = 22,
		anchorPoint = cc.p(0, 0.5),
		outlineColor = Enums.Color.eOutlineColor,
		outlineSize = 2,
		})
	label:setPosition(30, 20)
	self.mLightNumLabel = label
	ganwuBg:addChild(label)

    -- 升红按钮
    local upRedBtn = ui.newButton({
        normalImage = "hj_2.png",
        clickAction = function ()
            local castInfo = ""
            for k,v in pairs(HerostepHeroredRelation.items) do
                if v.attrTreeID > 0 then 
                    castInfo = v.needResource
                    break
                end 
            end
            local goodInfo = Utility.analysisStrResList(castInfo)
            for i,v in ipairs(goodInfo) do
                local ownNum = Utility.getOwnedGoodsCount(v.resourceTypeSub, v.modelId)
                if ownNum < v.num then 
                    ui.showFlashView(TR("%s不足", Utility.getGoodsName(v.resourceTypeSub, v.modelId)))
                    return
                end 
            end
            self:requestPlayerUpgradeQuality()
        end
    })
    upRedBtn:setPosition(130, 850)
    self.mParentLayer:addChild(upRedBtn)
    self.upRedBtn = upRedBtn

    self.upRedBtn.moduleId = ModuleSub.ePracticeLightenStar -- 拼酒模块
    self.upRedBtn.moduleSubId = "CanUpgradeQuality" -- 升红小红点
    -- 已经赠送图
    local upRedSprite = ui.newSprite("hj_4.png")
    upRedSprite:setPosition(130, 850)
    self.mParentLayer:addChild(upRedSprite)
    self.upRedSprite = upRedSprite
end

--中间按钮信息
function LightenStarLayer:buttonView()
	-- 拼酒按钮
	local ganwuBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("拼酒"),
			clickAction = function ()
				if AttrtreeModel.items[self.mLightStarInfo.StarId + 2] == nil then
					ui.showFlashView({text = TR("已满级")})
					return
				end
				if self.mLightStarInfo.StarCount < AttrtreeModel.items[self.mLightStarInfo.StarId + 2].needStar then
					MsgBoxLayer.addOKLayer(
		                TR("烧刀子酒不足,通关战役可获得烧刀子酒,是否现在前往?"),
		                TR("烧刀子酒不足"),
		                {
		                    {
		                        normalImage = "c_28.png",
		                        text = TR("前往"),
		                        clickAction = function()
		                            LayerManager.showSubModule(ModuleSub.eBattleNormal)
		                        end
		                    },
		                },
		                {}
		            )
		        elseif PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eGold) < AttrtreeModel.items[self.mLightStarInfo.StarId + 2].needGold then
		            MsgBoxLayer.addGetGoldHintLayer()
                else 
                        self:playAnimation()
                        self:requestLightenStar()
                        return
                    end

                -- 烧刀子或金币不足，退出引导
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID == 112103 then
                    Guide.helper:guideError(eventID, -1)
                end
			end})
	ganwuBtn:setPosition(320, 200)
	self.mParentLayer:addChild(ganwuBtn)
	self.pinjiuBtn = ganwuBtn
	-- 背景
	local downBgSize = cc.size(350, 40)
	local downBg = ui.newScale9Sprite("sc_19.png", downBgSize)
	downBg:setPosition(320, 150)
	self.mParentLayer:addChild(downBg)
	self.downBg = downBg
	-- 消耗星
	local starConsume = ui.newLabel({
			text = "",
			color = cc.c3b(0xff, 0xea, 0x2b),
			outlineColor = Enums.Color.eOutlineColor,
			outlineSize = 2,
			size = 24,
		})
	starConsume:setAnchorPoint(cc.p(0.5, 0.5))
	starConsume:setPosition(downBgSize.width*0.5, downBgSize.height*0.5)
	downBg:addChild(starConsume)
	self.mCastLabel = starConsume

	local onekeyIsOpen, onekeyInfo = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eOneKeyPracticeLightenStar, false)
	--一键拼酒
	local tempBtn = ui.newButton({
		normalImage = "tb_39.png",
		position = cc.p(550, 180),
		clickAction = function ()
			-- 判断该模块是否已开启
			if not onekeyIsOpen then
				ui.showFlashView(onekeyInfo.openMessage)
				return
			end
			--
			local tempModel = AttrtreeModel.items[self.mLightStarInfo.StarId + 2]

			-- 判断星数是否足够
			if self.mLightStarInfo.StarCount < tempModel.needStar then
				local btnInfos = {
					{
                        normalImage = "c_28.png",
                        text = TR("前往"),
                        clickAction = function()
                            LayerManager.showSubModule(ModuleSub.eBattleNormal)
                        end
                    },
				}
				local tempHint = TR("烧刀子酒不足,通关战役可获得烧刀子酒,是否现在前往?")
				MsgBoxLayer.addOKLayer(tempHint, TR("烧刀子酒不足"), btnInfos, {})

				return
			end
                -- 判断铜钱是否足够
                if not Utility.isResourceEnough(ResourcetypeSub.eGold, tempModel.needGold, true) then
                return
            end

			-- todo 其他条件判断

			self:playAnimation()
			-- 请求一键拼酒
			self:requestOneKeyLiaghtStar()
		end,
	})
	self.mParentLayer:addChild(tempBtn)
	self.mOneKeyBtn = tempBtn
end

--刷新部分页面
function LightenStarLayer:refresh(oneKey)
    -- 刷新升红按钮
    self:refreshUpBtn()

	local tempStrS
	local tempStrG
	local colorS = Enums.Color.eYellowH
	local colorG = Enums.Color.eYellowH
	local currConfig = AttrtreeModel.items[self.mLightStarInfo.StarId + 1]
	local nextConfig = AttrtreeModel.items[self.mLightStarInfo.StarId + 2]
       
	-- 当表中数据读取到超过界限的时候跳过
	if self.mLightStarInfo.StarId + 2 <=  #AttrtreeModel.items then
		if (nextConfig.needStar > self.mLightStarInfo.StarCount) then
			colorS = Enums.Color.eRedH
		end
		if (nextConfig.needGold > PlayerAttrObj:getPlayerAttrByName("Gold")) then
			colorG = Enums.Color.eRedH
		end
	end

	-- 显示消耗
    	if (nextConfig == nil) then
    		if self.downBg then
    			self.downBg:setVisible(false)
    		end

    		if self.pinjiuBtn then
    			self.pinjiuBtn:setVisible(false)
    		end

    		if self.mOneKeyBtn then
    			self.mOneKeyBtn:setVisible(false)
    		end
    	else
    		self.mCastLabel:setString(string.format("{%s}%s%s     {%s}%s%s",
    			"db_1125.png",
    			colorS, nextConfig.needStar,
    			Utility.getDaibiImage(ResourcetypeSub.eGold),
    			colorG, nextConfig.needGold))
    	end

	-- 显示属性
	local function formatAttrStr(hpValue, defValue, apValue, color1, color2)
		return TR("%s生命:%s+%d    %s防御:%s+%d    %s攻击:%s+%d",
			color1 or Enums.Color.eNormalWhiteH, color2 or "#a8ff5b", hpValue,
			color1 or Enums.Color.eNormalWhiteH, color2 or "#a8ff5b", defValue,
			color1 or Enums.Color.eNormalWhiteH, color2 or "#a8ff5b", apValue)
	end
	local tempStrS = TR("当前拥有{%s}%s%s", "db_1125.png", Enums.Color.eYellowH, self.mLightStarInfo.StarCount)
	local tempStrL = TR("总拼酒次数: %s%s", Enums.Color.eYellowH, self.mLightStarInfo.StarId)
	self.mStarNumLabel:setString(tempStrS)
	self.mLightNumLabel:setString(tempStrL)
	self.mTotalAddLabel:setString(TR("总加成") .. "    " .. formatAttrStr(currConfig.curHPADDTotal, currConfig.curDEFADDTotal, currConfig.curAPADDTotal))

	-- 判断是否满级
	if (nextConfig == nil) then
		self.mMaxLevelLabel:setVisible(true)
		self.mBottomLebl1:setVisible(false)
		self.mBottomLebl2:setVisible(false)
		self.mBottomLebl3:setVisible(false)
		return
	end

	-- 显示下一级可增加的属性
	local string1, string2 = self:bottomString(self.mLightStarInfo.StarId)
	if (string1 == "") and (string2 == "") then
		self.mBottomLebl1:setString(TR("没有额外收益了"))
		self.mBottomLebl1:setPositionY(40)
		self.mBottomLebl2:setVisible(false)
	else
		self.mBottomLebl1:setString(string1)
		self.mBottomLebl2:setString(string2)
	end
	self.mBottomLebl3:setString(formatAttrStr(nextConfig.curHPADDTotal - currConfig.curHPADDTotal, nextConfig.curDEFADDTotal - currConfig.curDEFADDTotal, nextConfig.curAPADDTotal - currConfig.curAPADDTotal, "#5EF6FF", "#FFDF2F"))
end

-- 刷新按钮
function LightenStarLayer:refreshUpBtn()
    local heroQuality = HeroModel.items[HeroObj:getMainHero().ModelId].quality
    local function dealRedDotVisible(redDotSprite)
        local redDotData = RedDotInfoObj:isValid(self.upRedBtn.moduleId, self.upRedBtn.moduleSubId)
        redDotSprite:setVisible(redDotData)
    end
    ui.createAutoBubble({refreshFunc = dealRedDotVisible, parent = self.upRedBtn, eventName = RedDotInfoObj:getEvents(self.upRedBtn.moduleId, self.upRedBtn.moduleSubId)})
        
    -- 按钮可视化
    self.upRedBtn:setVisible(heroQuality < 18)
    self.upRedSprite:setVisible(heroQuality >= 18)
end

--参数 ：StarId = 当前节点数
--返回值：1.资质提升的提示文字   2.卡槽开启的提示文字
--底部距离下次大提升的提示
function LightenStarLayer:bottomString(StarId)
	local string1 = ""
	local string2 = ""

	local HeroNewTable = {}
    for index, value in pairs(AttrtreeHeromodelRelation.items) do
        table.insert(HeroNewTable, value)
    end
    for index, value in pairs(HerostepHeroredRelation.items) do
        table.insert(HeroNewTable, value)
    end
    table.sort(HeroNewTable, function (a, b)
        return a.attrTreeID < b.attrTreeID
    end)

    local SlotNewTable = {}
    for index, value in pairs(AttrtreeSlotRelation.items) do
        table.insert(SlotNewTable, value)
    end
    table.sort(SlotNewTable, function (a, b)
        return a.needAttrTreeID < b.needAttrTreeID
    end)

    local needNumHero = 0
    local needNumSlot = 0
    for i,v in ipairs(HeroNewTable) do
    	if StarId < v.attrTreeID then
			needNumHero = v.attrTreeID - StarId
			local quality = HeroModel.items[v.boyHeroModelID].quality
			local colorStr = ""
            local colorStr1 = ""
			if quality == 6 then
                colorStr = TR("游侠")
            elseif quality == 10 then
                colorStr = TR("%s豪侠", Enums.Color.ePurpleH)
            elseif quality == 13 then
                colorStr = TR("%s宗师", Enums.Color.eOrangeH)
            elseif quality == 15 then
                colorStr = TR("%s神话", Enums.Color.eOrangeH)
            elseif quality == 18 then
                colorStr = TR("%s传说", Enums.Color.eRedH)   
                colorStr1 = TR("赠神僧龙骨酒") 
            end
			string1 = TR("再拼酒%s%d%s次,%s提升主角品质为%s", "#FFDF2F", needNumHero, Enums.Color.eNormalWhiteH, colorStr1, colorStr)
    		break
    	end
    end
    for i,v in ipairs(SlotNewTable) do
    	if StarId < v.needAttrTreeID then
    		needNumSlot = v.needAttrTreeID - StarId
    		if v.ID < 17 then
	    		string2 = TR("再拼酒%s%d%s次,开启上阵位%s%s", 
	    			"#FFDF2F", needNumSlot, Enums.Color.eNormalWhiteH, 
	    			"#FFDF2F", v.ID - 10)
	    	else
	    		string2 = TR("再拼酒%s%d%s次,开启江湖后援团插槽%s%s", 
	    			"#FFDF2F", needNumSlot, Enums.Color.eNormalWhiteH, 
	    			"#FFDF2F", v.ID - 20)
	    	end

    		break
    	end
    end
	return string1, string2
end

--判断是否开启新的上阵位
function LightenStarLayer:isNewSlot(StarId)
	if StarId < 29 then --28为最后一个上阵位
		for k,v in pairs(AttrtreeSlotRelation.items) do
			if v.needAttrTreeID == StarId then
				MsgBoxLayer.addOKLayer(
                    TR("开启新上阵位%d,是否前往?", v.ID - 10),
                    TR("开启新上阵位"),
                    {
                        {
                            normalImage = "c_28.png",
                            text = TR("前往"),
                            clickAction = function()
                                LayerManager.addLayer({
                                    name = "team.TeamLayer",
                                    data = {showIndex = v.ID - 10},
                                })
                            end
                        },
                    },
                    {}
                )
			end
		end
	end

	if StarId > 47 then --48为第一个江湖后援团卡槽
		for k,v in pairs(AttrtreeSlotRelation.items) do
			if v.needAttrTreeID == StarId then
				MsgBoxLayer.addOKLayer(
                    TR("开启江湖后援团插槽位%d,是否前往?", v.ID - 20),
                    TR("开启新插槽"),
                    {
                        {
                            normalImage = "c_28.png",
                            text = TR("前往"),
                            clickAction = function()
                                LayerManager.addLayer({
                                    name = "team.TeamLayer",
                                    data = {showIndex = 7},
                                })
                            end
                        },
                    },
                    {}
                )
			end
		end
	end
end

--当主角资质提升的动画
function LightenStarLayer:qualityChange(modelId)
    -- 背景
    self.mBgSprite = ui.newSprite("sc_23.jpg")
    self.mBgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(self.mBgSprite, 500)
    self.mBackSize = self.mBgSprite:getContentSize()
    --  屏蔽下层触摸
	ui.registerSwallowTouch({node = self.mBgSprite})

    local effectName, animation, music = nil, nil, nil
    if Utility.getColorLvByModelId(modelId) >= 5 then
        effectName = "effect_ui_shengjiangchuchang_jin"
        animation = "guangyun"
        music = "renwuhecheng_01.mp3"
    elseif Utility.getColorLvByModelId(modelId) >= 4 then
        effectName = "effect_ui_shengjiangchuchang_zi"
        animation = "guangyun"
        music = "renwuhecheng_01.mp3"
    elseif Utility.getColorLvByModelId(modelId) >= 3 then
        effectName = "effect_ui_shengjiangchuchang_lan"
        animation = "guangyun"
        music = "renwuhecheng_01.mp3"
    end
    local effect1 = ui.newEffect({
        parent = self.mBgSprite,
        effectName = effectName,
        position = cc.p(self.mBackSize.width / 2, self.mBackSize.height * 0.5),
        animation = "luo",
        loop = false,
        endRelease = true,
        completeListener = function(p)
        	ui.newEffect({
        		parent = self.mBgSprite,
		        effectName = effectName,
		        position = cc.p(self.mBackSize.width / 2, self.mBackSize.height * 0.6),
		        loop = true,
		        animation = animation,
		        endRelease = true,
		        completeListener = function ()
			        local closeBtn = ui.newButton({
				        normalImage = "c_28.png",
				        text = TR("关 闭"),
				        textColor = Enums.Color.eWhite,
				        anchorPoint = cc.p(0.5, 1),
				        position = cc.p(self.mBackSize.width * 0.5, self.mBackSize.height * 0.21),
				        clickAction = function()
				            self.mBgSprite:removeFromParent()
				            self.mBgSprite = nil
				        end
				    })
				    self.mBgSprite:addChild(closeBtn, 1)
		    	end
        	})
        	MqAudio.playEffect("renwuhecheng_02.mp3")
            -- self.mLightEffect:setOpacity(255)
            self.mHeadSprite:runAction(cc.FadeIn:create(0.5))
        end,
    })
    -- ui.newEffect({
    -- 	parent = self.mBgSprite,
    --     effectName = effectName,
    --     position = cc.p(self.mBackSize.width / 2, self.mBackSize.height * 0.6),
    --     loop = false,
    --     animation = "qian",
    --     endRelease = true,
    -- })

    MqAudio.playEffect(music)

    -- 人物
    self.mHeadSprite = Figure.newHero({
        heroModelID = modelId,
        position = cc.p(self.mBackSize.width * 0.5, self.mBackSize.height * 0.4),
        scale = 0.3,
    })
    self.mHeadSprite:setOpacity(0)
    self.mBgSprite:addChild(self.mHeadSprite, 10)

    local tocolor = ""
    if HeroModel.items[modelId].quality == 10 then
        tocolor = TR("主角品质升级为%s豪侠！", Enums.Color.ePurpleH)
    elseif HeroModel.items[modelId].quality == 13 then
        tocolor = TR("主角品质升级为%s宗师！", Enums.Color.eOrangeH)
    elseif HeroModel.items[modelId].quality == 15 then
        tocolor = TR("主角品质升级为%s神话！", Enums.Color.eOrangeH)    
    else
        tocolor = TR("主角品质升级为%s传说！", Enums.Color.eRedH)
    end
    local label = ui.newLabel({
        text = tocolor,
        size = 26,
        color = Enums.Color.eWhite,
    })
    label:setPosition(self.mBackSize.width * 0.5, self.mBackSize.height * 0.27)
    self.mBgSprite:addChild(label)
end

-- 播放喝酒特效
function LightenStarLayer:playAnimation()
	SkeletonAnimation.action({
    		    skeleton         = self.heroEffect,
    		    action           = "hejiu",
    		    endListener = function()
    		    	self.heroEffect:setToSetupPose()
    		    end,
    		})

	self.heroEffect:addAnimation(0, "daiji", true)
end

--===========================网络请求==============================
--获取总信息
function LightenStarLayer:requestLightenStarInfo()
	HttpClient:request({
		moduleName = "LightenStar",
        methodName = "GetLightenStarInfo",
        svrMethodData = {},
        callback = function (data)
        	if not data or data.Status ~= 0 then
        		return
        	end
        	self.mLightStarInfo = data.Value
        	self:topView()
        	self:buttonView()
        	self:bottomView()
        	self:refresh()

        	-- 执行新手引导
        	self:executeGuide()
        end
	})
end

--升红
function LightenStarLayer:requestPlayerUpgradeQuality()
    HttpClient:request({
        moduleName = "LightenStar",
        methodName = "UpgradeQuality",
        svrMethodData = {},
        callback = function (data)
            if not data or data.Status ~= 0 then
                return
            end
            -- dump(data.Value,"data.Value")
            if not tolua.isnull(self.mStandEffect) then
                self.mStandEffect:removeFromParent()
                self.mStandEffect = nil
            end

            if HeroModel.items[data.Value.HeroInfo.ModelId].quality > HeroModel.items[self.mOldHeroInfo.ModelId].quality then
                self:qualityChange(HeroObj:getMainHero().ModelId)
            end

            -- 更新主角数据
            if data.Value.HeroInfo then
                HeroObj:modifyHeroItem(data.Value.HeroInfo)
            end

            self.mOldHeroInfo = clone(HeroObj:getMainHero())

            -- 刷新升红按钮
            self:refreshUpBtn()
        end
    })
end

--拼酒一次
function LightenStarLayer:requestLightenStar()   
	HttpClient:request({
		moduleName = "LightenStar",
        methodName = "LightenStar",
        svrMethodData = {},
        needWait = false,
        guideInfo = Guide.helper:tryGetGuideSaveInfo(112103),
        callback = function (data)
        	if not data or data.Status ~= 0 then
        		return
        	end
            --[[--------新手引导--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 112103 then
                Guide.manager:removeGuideLayer()
                Guide.manager:nextStep(eventID)
            end

        	local size = self.pinjiuBtn:getContentSize()
        	if not tolua.isnull(self.mStandEffect) then
        		self.mStandEffect:removeFromParent()
        		self.mStandEffect = nil
        	end

        	-- 刷新数据
    		self.mLightStarInfo = data.Value

        	self:refresh()
        	self:isNewSlot(self.mLightStarInfo.StarId)

        	if HeroModel.items[HeroObj:getMainHero().ModelId].quality > HeroModel.items[self.mOldHeroInfo.ModelId].quality then
                self:qualityChange(HeroObj:getMainHero().ModelId)
            end
            self.mOldHeroInfo = clone(HeroObj:getMainHero())

            -- 喝酒音效
            MqAudio.playEffect("hejiu_dakou.mp3")

            -- 更新主角数据
            if data.Value.HeroInfo then
            	HeroObj:modifyHeroItem(data.Value.HeroInfo)
            end
        end
	})
end

--一键拼酒
function LightenStarLayer:requestOneKeyLiaghtStar()
	HttpClient:request({
        moduleName = "LightenStar",
        methodName = "LightenStarForOneKey",
        svrMethodData = {},
        callback = function (data)
        	--dump(data, "onekey")
        	if not data or data.Status ~= 0 then
        		return
        	end
	        self.mLightStarInfo = data.Value
	        local oneKey = true
	    	self:refresh(oneKey)
	    	self:isNewSlot(self.mLightStarInfo.StarId)

	    	if HeroModel.items[HeroObj:getMainHero().ModelId].quality > HeroModel.items[self.mOldHeroInfo.ModelId].quality then
	            self:qualityChange(HeroObj:getMainHero().ModelId)
	        end
	        self.mOldHeroInfo = clone(HeroObj:getMainHero())

            -- 喝酒音效
            MqAudio.playEffect("hejiu_dakou.mp3")

            -- 更新主角数据
            if data.Value.HeroInfo then
            	HeroObj:modifyHeroItem(data.Value.HeroInfo)
            end
        end
    })
end

-- ========================== 新手引导 ===========================

-- 执行新手引导
function LightenStarLayer:executeGuide()
    Guide.helper:executeGuide({
    	[112103] = {clickNode = self.pinjiuBtn},
    })
end

return LightenStarLayer
