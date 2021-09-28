--[[
    文件名: ResultUtility.lua
	描述: 战斗结算通用元素创建
	创建人: liaoyuangang
	创建时间: 2016.06.09
-- ]]

ResultUtility = {}

DEBUG_S = false

-- 战斗胜利动画
--[[
-- 参数
	starCount: 需要显示星星的数量，默认为 0
	isFinishText: 显示的文字是否是“战斗结束”，为 false 时显示 “战斗胜利”， 默认为：false
	textIsOnTop: 显示的文字是否放在动画的上面，如果为nil时自动判断，即：
		starCount > 0 或 isFinishText == true 时 放在下面，否则放在上面
]]
function ResultUtility.createWinAnimation(starCount, isFinishText, textIsOnTop)
	starCount = starCount or 0
	-- 胜利动画的显示大小
	local tempSize = cc.size(640, 580)

	local retNode = ccui.Layout:create()
	retNode:setContentSize(tempSize)
	retNode:setIgnoreAnchorPointForPosition(false)

	local centerPosX, centerPosY = tempSize.width / 2, tempSize.height / 2

    -- 战斗胜利或战斗结束的文字
    -- local tempPosY = ((starCount > 0) --[[or isFinishText]]) and (centerPosY + 28) or (centerPosY + 55)
    local tempPosY = starCount > 0 and centerPosY + 28 or centerPosY + 55
    if textIsOnTop ~= nil then
    	tempPosY = textIsOnTop and (centerPosY + 28) or (centerPosY + 28)
    end

    -- 显示星星
    local startPosX = centerPosX - starCount * 120 / 2 + 60
    local startPosY = centerPosY + 250
    local index = 1
    local starPosYList = {
        [3] = {[1] = -20, [3] = -20}
    }
    -- 创建星星动画
    local function createStarEffect()
    	local tempPosX = startPosX + (index - 1) * 120
    	local tempPosY = startPosY + (starPosYList[starCount] and starPosYList[starCount][index] or 0)
    	local xingxingEffect = ui.newEffect({
            parent = retNode,
            effectName = "effect_ui_zhandoushenli",
            animation = "XingXing",
            position = cc.p(tempPosX, tempPosY),
            scale = 0.6,
            loop = false,
            endRelease = false,
            -- startListener = function()
            --     MqAudio.playEffect("sound_win_star.mp3")
            -- end,
            eventListener = function(p)
                if p.event.stringValue == "end" then
                    if index < starCount then
                        index = index + 1
                        createStarEffect()
                    end
                end
            end,
        })
        MqAudio.playEffect("sound_win_star.mp3")
    end

    -- 胜利动画显示
    local beiguangEffect = ui.newEffect({
        parent = retNode,
        effectName = "effect_ui_zhandoushenli",
        animation = "ChuXian",
        position = cc.p(centerPosX - 5, centerPosY + 120),
        loop = false,
        endRelease = true,
        -- startListener = function()
        --     MqAudio.playEffect("sound_tongguan.mp3")
        -- end,
        completeListener = function()
            local tempEffect = ui.newEffect({
                parent = retNode,
                effectName = "effect_ui_zhandoushenli",
                animation = "Daiji",
                position = cc.p(centerPosX - 5, centerPosY + 120),
                loop = true,
                endRelease = false,
            })

            -- 星星特效
            if index <= starCount then
                createStarEffect()
            end
        end
    })
    MqAudio.playEffect("sound_tongguan.mp3")

	return retNode
end

-- 战斗失败的动画
function ResultUtility.createLoseAnimation()
	-- 失败动画的显示大小
	local tempSize = cc.size(640, 600)

	local retNode = ccui.Layout:create()
	retNode:setContentSize(tempSize)
	retNode:setIgnoreAnchorPointForPosition(false)

	local centerPosX, centerPosY = tempSize.width / 2, tempSize.height / 2

	ui.newEffect({
        parent = retNode,
        effectName = "effect_ui_zhandoushibai",
        animation = "ChuChang",
        position = cc.p(centerPosX, centerPosY + 60),
        loop = false,
        endRelease = true,
        completeListener = function()
            ui.newEffect({
                parent = retNode,
                effectName = "effect_ui_zhandoushibai",
                animation = "DaiJi",
                position = cc.p(centerPosX, centerPosY + 60),
                loop = false,
                endRelease = false,
            })
        end
    })

    return retNode
end

-- 显示获得的玩家属性
--[[
-- 参数
	attrInfoList 中的每个元素为
	{
		{
			resourcetypeSub = ResourcetypeSub.eGold,  -- 资源类型
			num = 100, -- 数量
		},
		...
	}
]]
function ResultUtility.createPlayerAttr(attrInfoList, extraList)
	attrInfoList = attrInfoList or {}
    for k,v in pairs(attrInfoList) do
        if v.modelId and tonumber(v.modelId) > 0 then
            table.remove(attrInfoList, k)
        end
    end
	local tempSize = cc.size(640, 50)
	local retNode = ccui.Layout:create()
	retNode:setContentSize(tempSize)
	retNode:setIgnoreAnchorPointForPosition(false)
    extraList = extraList or {}
    local baseCount = #attrInfoList
    local extraCount = #extraList
	local startPosX = 320 - (baseCount + extraCount) * 150 / 2 + 75
    local xIndex = 0
	for _, item in pairs(attrInfoList) do
        item.fontColor = Enums.Color.eLightYellow
        if item.num then
            local tempNode = ui.createDaibiView(item)
            tempNode:setAnchorPoint(cc.p(0.5, 0.5))
            tempNode:setPosition(startPosX + xIndex * 150, tempSize.height / 2)
            retNode:addChild(tempNode)
            xIndex = xIndex + 1
        end
	end

    -- 额外列表
    for index, item in pairs(extraList) do
        local tempNode = ui.newLabel({
            text = string.format("%s%s%+d", item.Name, Enums.Color.eLightYellowH, item.Num),
        })
        tempNode:setAnchorPoint(cc.p(0.5, 0.5))
        tempNode:setPosition(startPosX + (index + baseCount - 1) * 150, tempSize.height / 2)
        retNode:addChild(tempNode)
    end

	return retNode
end

-- 显示对阵双方的战力信息
--[[
-- 参数 params 中的各项为
	{
		myInfo = {  -- 我方信息
			PlayerName = "", -- 我的名字
			FAP = 0, -- 我的战力
		},
		otherInfo = {  -- 对方的战力信息
			PlayerName = "", -- 对方的名字
			FAP = 0, -- 对方的战力
		},
		viewSize = cc.size(640, 100), 该信息显示区域的大小，默认为： cc.size(640, 100)
		bgImg = "", -- 显示信息的底图，默认为：c_53.png， 如果为 “” 表示不需要背景
		bgIsScale9 = true, -- 背景底图是否才用 Scale9 创建，默认为 true
	}
]]
function ResultUtility.createVsInfo(params)
	params = params or {}
	local tempSize = params.viewSize or cc.size(640, 84)
	local retNode = ccui.Layout:create()
	retNode:setContentSize(tempSize)
	retNode:setIgnoreAnchorPointForPosition(false)

	-- 创建背景图片
	if params.bgImg ~= "" then
		local tempSprite
		if bgIsScale9 ~= false then
			tempSprite = ui.newScale9Sprite(params.bgImg or "c_53.png", tempSize)
		else
			tempSprite = ui.newSprite(params.bgImg or "c_53.png")
		end
		tempSprite:setPosition(tempSize.width / 2, tempSize.height / 2)
		retNode:addChild(tempSprite)
	end

	-- 创建一方的信息
	local function createOneInfo(playerInfo, posX)
		local viewInfoList = {
			{
				text = playerInfo.PlayerName,
				color = Enums.Color.eYellow,
                outlineColor = cc.c3b(0x73, 0x43, 0x0D),
                size = 27,
			},
			{
				text = TR("战力:%s", Utility.numberFapWithUnit(playerInfo.FAP)),
				color = Enums.Color.eWhite,
                outlineColor = cc.c3b(0x73, 0x43, 0x0D),
                size = 25,
			},
		}
		local startPosY = tempSize.height - (tempSize.height - #viewInfoList * 32) / 2 - 20
		for index, item in pairs(viewInfoList) do
			item.align = cc.TEXT_ALIGNMENT_CENTER
			item.anchorPoint = cc.p(0.5, 0.5)

			local tempLabel = ui.newLabel(item)
			tempLabel:setPosition(posX, startPosY - (index - 1) * 32)
			retNode:addChild(tempLabel)
		end
	end

	-- 创建自己的信息
	createOneInfo(params.myInfo, 140)
	-- 创建对方的信息
	createOneInfo(params.otherInfo, 500)

	-- 创建VS图片
	local tempSprite = ui.newSprite("zdjs_07.png")
	tempSprite:setPosition(tempSize.width / 2, tempSize.height / 2)
	retNode:addChild(tempSprite)

	return retNode
end

-- 创建经验进度条和玩家当前等级信息
--[[
-- 参数
	addExp: 当前增加的经验值
]]
function ResultUtility.createExpProg(addExp)
	addExp = addExp or 0
	local viewSize = cc.size(640, 40)
	local retNode = ccui.Layout:create()
	retNode:setContentSize(viewSize)
	retNode:setIgnoreAnchorPointForPosition(false)

	local currLv = PlayerAttrObj:getPlayerAttrByName("Lv")

	-- 显示当前等级
	local lvLabel = ui.newLabel({
        text = TR("等级.%s", currLv),
        size = 25,
        color = Enums.Color.eLightYellow,
    })
    lvLabel:setPosition(75, viewSize.height / 2)
    retNode:addChild(lvLabel)

    local currLvTotal = PlayerLvRelation.items[currLv] and PlayerLvRelation.items[currLv].EXPTotal or 0
    local nextLvTotal = PlayerLvRelation.items[currLv + 1] and PlayerLvRelation.items[currLv + 1].EXPTotal or 0
    local maxExp = math.max(0, nextLvTotal - currLvTotal)
    local currExp = math.max(0, PlayerAttrObj:getPlayerAttrByName("EXP") - currLvTotal)

   	-- 显示当前经验进度
   	local progressBar = require("common.ProgressBar").new({
        bgImage = "zdjs_08.png",
        barImage = "zdjs_09.png",
        currValue = math.max(0, currExp - addExp),
        maxValue= maxExp,
        barType = ProgressBarType.eHorizontal,
        size = 18,
        needLabel = true,
        color = Enums.Color.eWhite,
    })
    progressBar:setPosition(viewSize.width / 2 + 55, viewSize.height / 2)
    retNode:addChild(progressBar)

    -- 动态显示经验增长
    local totalTime = 0
    local dealTime = addExp > 50 and 2 or 1
    progressBar:scheduleUpdateWithPriorityLua(function(dt)
    	if totalTime == 0 then
    		progressBar:doProgress(currExp, dealTime)
    	end
    	totalTime = totalTime + dt

    	local curValue = math.floor(currExp - (1 - totalTime / dealTime) * addExp)
        if curValue < 0 then curValue = 0 end
        progressBar.mProgressLabel:setString(curValue .. " / " .. maxExp)
        if curValue >= currExp then
            progressBar.mProgressLabel:setString(currExp .. " / " .. maxExp)
            progressBar:unscheduleUpdate()
        end
    end, 0)

	return retNode
end

-- 显示打开铜币宝箱的动画
--[[
-- 参数
	isAutoOpen: 是否自动打开，默认为：true
    callback: 宝箱打开后的回调函数
]]
function ResultUtility.createOpenBox(isAutoOpen, callback)
	local viewSize = cc.size(640, 130)
	local retNode = ccui.Layout:create()
	retNode:setContentSize(viewSize)
	retNode:setIgnoreAnchorPointForPosition(false)

	-- 打开箱子的特效
	local beiguangEffect = ui.newEffect({
        parent = retNode,
        effectName = "effect_ui_kaibaoxiang",
        animation = "animation",
        position = cc.p(viewSize.width / 2, viewSize.height / 2),
        loop = false,
        endRelease = true,
        startListener = function ()
            MqAudio.playEffect("sound_kaibaoxiang.mp3")
        end,
        endListener = function ()
        	if callback then
                callback()
            end
        end
    })

    -- 喷射铜币的特效
    Utility.performWithDelay(retNode, function ()
    	local golds = ui.createSprayParticle("db_1112.png", 0.8)
        golds:setPosition(viewSize.width / 2, viewSize.height / 2)
        retNode:addChild(golds)
    end, 0.7)

	return retNode
end

-- 显示翻牌信息
--[[
-- 参数
	ChoiceGetGameResource: 服务器返回的选择掉落部分数据
    choiceCallback  点击打开并且动画完成后执行
]]
function ResultUtility.createChoiceCardInfo(ChoiceGetGameResource, choiceCallback)
	local viewSize = cc.size(640, 180)
	local retNode = ccui.Layout:create()
	retNode:setContentSize(viewSize)
	retNode:setIgnoreAnchorPointForPosition(false)

	-- 实际得到的物品信息
	local dropInfo = {}
	-- 其它的物品选择项目
	local otherInfos = {}
	-- 分类信息
	for _ , item in pairs(ChoiceGetGameResource or {}) do
        if item.IsDrop == true then
            dropInfo = item
        else
            table.insert(otherInfos, item)
        end
    end

    -- 记录玩家是否已经选择了
    local isChoiced = false

    -- 执行一个卡牌的翻牌效果
    local otherIndex = 1
    local function doOneOpenAction(cardBgBtn, isSelect)
    	cardBgBtn:stopAllActions()
		cardBgBtn:setScale(1)
		cardBgBtn:setTouchEnabled(false)

		local tempSize = cardBgBtn:getContentSize()
		local openAction = {
			cc.OrbitCamera:create(0.4, 1, 30, 0, 90, 0, 0),
			cc.CallFunc:create(function()
				cardBgBtn:loadTextures("zdjs_03.png", "zdjs_03.png")
				-- 卡牌背景的大小
		    	local tempCard = CardNode:create({
		    		allowClick = true
		    	})
		    	tempCard:setPosition(tempSize.width / 2, tempSize.height * 0.6)
		    	tempCard:setScaleX(-1)
		    	cardBgBtn:addChild(tempCard)

				if isSelect then
					tempCard:setCardData(dropInfo, {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName})
				    -- 选中标志
                    local sprite = ui.newScale9Sprite("c_31.png", cc.size(tempSize.width + 20, tempSize.height + 20))
                    sprite:setPosition(tempSize.width/2, tempSize.height/2)
                    cardBgBtn:addChild(sprite)
                else
					tempCard:setCardData(otherInfos[otherIndex])
					otherIndex = otherIndex + 1
				end
            end),
            cc.OrbitCamera:create(0.4, 1, 30, 90, 90, 0, 0)
		}
		if not isSelect then
			table.insert(openAction, 1, cc.DelayTime:create(0.5))
		end

		cardBgBtn:runAction(cc.Sequence:create(openAction))
    end

    -- 卡牌对象
    local cardBgList = {}
    local retNodeActions = {}
    local tempCount = #ChoiceGetGameResource
    local startPosX = (viewSize.width - tempCount * 200) / 2 + 100
    for index = 1, tempCount do
    	local tempPosY = viewSize.height / 2
    	-- 卡牌的背景
    	local bgBtn = ui.newButton({
    		normalImage = "zdjs_04.png",
    		clickAction = function( ... )
    			isChoiced = true
    			otherIndex = 1

    			retNode:stopAllActions()
    			for btnIndex, btn in pairs(cardBgList) do
    				doOneOpenAction(btn, btnIndex == index)
    			end

    			if choiceCallback then
    				choiceCallback()
    			end
    		end
    	})
    	bgBtn:setPosition(startPosX + (index - 1) * 200, tempPosY)
    	retNode:addChild(bgBtn)
    	table.insert(cardBgList, bgBtn)

        if not retNode.mClickNode_ then
            retNode.mClickNode_ = bgBtn
        end

    	--
    	table.insert(retNodeActions, cc.DelayTime:create(0.5))
    	table.insert(retNodeActions, cc.CallFunc:create(function()
    		local actionArray = {
	    		cc.ScaleTo:create(0.2, 1.2),
	    		cc.ScaleTo:create(0.2, 1),
	    		cc.DelayTime:create(0.5 * tempCount),
	    	}
	    	bgBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(actionArray)))
    	end))

        if not retNode.mClikcNode_ then
            retNode.mClikcNode_ = bgBtn
        end
   	end
   	retNode:runAction(cc.Sequence:create(retNodeActions))

   	-- 返回当前是否已选择
   	retNode.choiceStatus = function( ... )
   		return isChoiced
   	end

	return retNode
end

-- 显示战斗失败后提升战力的挑战按钮
function ResultUtility.createEnhanceBtns()
	local viewSize = cc.size(640, 130)
	local retNode = ccui.Layout:create()
	retNode:setContentSize(viewSize)
	retNode:setIgnoreAnchorPointForPosition(false)

	-- 战斗失败后提升战力的提示
	local infoLabel = ui.newLabel({
        text = TR("胜败乃兵家常事，通过以下方法可以提升战斗力"),
        align = cc.TEXT_ALIGNMENT_CENTER,
        color = Enums.Color.eYellow,
    })
    infoLabel:setAnchorPoint(cc.p(0.5, 0.5))
    infoLabel:setPosition(viewSize.width / 2, viewSize.height)
    retNode:addChild(infoLabel)

    -- 挑战按钮
    local btnInfos = {
        { -- 人物升级
            normalImage = "tb_51.png",
            moduleId = ModuleSub.eHeroLvUp,
            clickAction = function()
                local layerName = LayerManager.layerStack[table.getn(LayerManager.layerStack) - 1].name
                if layerName == "challenge.PvpInterFightLayer" then
                    LayerManager.deleteStackItem("challenge.PvpInterFightLayer")
                end

                LayerManager.showSubModule(ModuleSub.eHeroLvUp, {originalId = FormationObj:getSlotInfoBySlotId(2).HeroId})
            end,
        },
        { -- 拼酒
            normalImage = "tb_45.png",
            moduleId = ModuleSub.ePracticeLightenStar,
            clickAction = function()
                local layerName = LayerManager.layerStack[table.getn(LayerManager.layerStack) - 1].name
                if layerName == "challenge.PvpInterFightLayer" then
                    LayerManager.deleteStackItem("challenge.PvpInterFightLayer")
                end
                
                LayerManager.showSubModule(ModuleSub.ePracticeLightenStar)
            end,
        },
        { -- 装备强化
            normalImage = "tb_52.png",
            moduleId = ModuleSub.ePracticeBloodyDemonDomain,
            clickAction = function()
                LayerManager.addLayer({
                    name = "team.TeamEquipLayer",
                    data = {},
                    data = {showIndex = 1},
                    cleanUp = true,
                })
            end,
        },
    }

    local startPosX = (viewSize.width - #btnInfos * 120) / 2 + 60
    local tempPosY = (viewSize.height - 40) / 2
    for index, btnInfo in pairs(btnInfos) do
    	local tempBtn = ui.newButton(btnInfo)
    	tempBtn:setPosition(startPosX + (index - 1) * 120, tempPosY)
    	retNode:addChild(tempBtn)
    end

	return retNode
end

-- 创建自动推图控件
function ResultUtility.createAutoFightViews(self)
    -- 执行自动战斗
    local function doAutoFight()
        AutoFightObj:getNextNode(function(chapterId, nodeId, starLv)
            Guide.manager:showChapterGuide(chapterId, function()
                BattleObj:requestFightInfo(chapterId, nodeId, starLv)
            end)
        end)
    end

    -- 改变自动战斗状态
    local function changeAutoStatus(checkboxClick, endCallback)
        -- 判断当前是否是自动推图
        local isAuto = AutoFightObj:getAutoFight()
        self.mCheckBox:setCheckState(isAuto)
        self.mCheckBox:stopAllActions()

        AutoFightObj:getNextNode(function(chapterId, nodeId, starLv)
            if not isAuto then
                self.mCheckBox:setString(checkboxClick and TR("自动进行下一关战斗") or TR("自动推图"))
                self.mCloseBtn:setPosition(320, 200)
                self.mCloseBtn:setTitleText(TR("关闭"))
                self.mContinueBtn:setVisible(false)
            else
                local canContinue = true
                if not chapterId then
                    self.mCheckBox:setString(TR("没有可自动挑战的关卡"))
                    canContinue = false
                elseif not Utility.checkBagSpace(nil, true) then
                    -- 背包控件不足
                    self.mCheckBox:setCheckState(false)
                    canContinue = false
                elseif not Utility.isResourceEnough(ResourcetypeSub.eVIT, 5, true) then
                    -- 体力不足
                    self.mCheckBox:setCheckState(false)
                    canContinue = false
                else
                    local freeTime = 4
                    Utility.schedule(self.mCheckBox, function()
                        local isAuto = AutoFightObj:getAutoFight()
                        if not isAuto then
                            return
                        end
                        freeTime = freeTime - 1

                        if freeTime == 0 then
                            local _, ordinal, _ = Guide.manager:getGuideInfo()
                            if ordinal and ordinal == 1 then
                                -- ui.showFlashView(TR("正在进行新手引导"))
                                -- 莫名原因未开启升级，直接跳转到首页继续引导
                                LayerManager.addLayer({name = "home.HomeLayer", isRootLayer = true})
                            else
                                -- 进行自动战斗
                                doAutoFight()
                            end
                        elseif freeTime > 0 then
                            self.mCheckBox:setString(TR("%d秒后开始自动战斗", freeTime))
                        end
                    end, 1)
                end

                self.mCloseBtn:setPosition(canContinue and 200 or 320, 200)
                self.mCloseBtn:setTitleText(canContinue and TR("结束挂机") or TR("关闭"))
                self.mContinueBtn:setVisible(canContinue)
            end

            if endCallback then
                endCallback()
            end
        end)
    end

    -- 自动挂机的勾选框
    self.mCheckBox = ui.newCheckbox({
        normalImage = "c_60.png",
        selectImage = "c_61.png",
        text = TR("自动推图"),
        callback = function(isSelected)
            AutoFightObj:setAutoFight(isSelected)
            changeAutoStatus(false)
        end
    })
    self.mCheckBox:setPosition(320, 280)
    self.mParentLayer:addChild(self.mCheckBox)

    -- 继续挂机按钮
    self.mContinueBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("继续挂机"),
        clickAction = function()
            self.mCheckBox:stopAllActions()
            -- 进行自动战斗
            doAutoFight()
        end,
    })
    self.mContinueBtn:setPosition(440, 200)
    self.mContinueBtn:setVisible(false)
    self.mParentLayer:addChild(self.mContinueBtn)

    --
    self.mChangeAutoStatus = changeAutoStatus
end

-- 最后处理
function ResultUtility.beforeTheEnd(self, endCallback)
    if self.mChangeAutoStatus then
        self.mChangeAutoStatus(nil, endCallback)
    elseif endCallback then
        endCallback()
    end
end

-- 加入控件
--[[
    uiNames可以包含：
        "VsInfo", "PlayerAttrDrop", "PlayerExpProgress", "Choice",
        "TreasureLootTips", "CommonTips",
        "FapUp", "Drop", "Statists"
    choiceCallback : 翻牌后的回调函数
--]]
function ResultUtility.createUi(targetlayer, uiNames, data, choiceCallback)
    -- 父节点
    local parent = cc.Node:create()
    local mChoiceNode_ = nil
    local tempCallBack = choiceCallback or function() end

    -- 掉落属性
    local dropList = Utility.analysisGameDrop(targetlayer.mBattleResult.BaseGetGameResourceList)

    local resTypeList = {ResourcetypeSub.eHorseDebris, ResourcetypeSub.eBookDebris}
    local treasureDebrisList, addExp = Utility.splitDropPlayerAttr(dropList, resTypeList)

    -- 循环添加控件
    data = data or {}
    local y = 0
    for i, name in ipairs(uiNames) do
        local height
        local node

        if type(name) == "number" then
            height = name
        elseif name == "VsInfo" then
            -- 显示对阵双方的战力信息
            height = 135
            node = ResultUtility.createVsInfo({
                myInfo = targetlayer.mMyInfo,
                otherInfo = targetlayer.mEnemyInfo,
                viewSize = cc.size(640, 100),
                bgImg = "",
                bgIsScale9 = true,
            })
        elseif name == "PlayerAttrDrop" then
            -- 创建掉落的玩家属性显示
            height = 60
            node = ResultUtility.createPlayerAttr(dropList, data[name])
        elseif name == "PlayerExpProgress" then
            -- 创建经验进度条
            height = 44
            node = ResultUtility.createExpProg(addExp)
        elseif name == "TreasureLootTips" then
            -- 挖矿抢夺提示信息
            height = 100

            local text = ""
            if targetlayer.mBattleResult.IsWin == true then
                text = TR("战斗胜利，")
            else
                text = TR("战斗失败，")
            end
            if (targetlayer.mBattleResult.GetExp > 0) and (targetlayer.mBattleResult.TreasureDebrisModelId > 0) then
                local debrisItem = TreasureDebrisModel.items[targetlayer.mBattleResult.TreasureDebrisModelId] or {}
                local treasureItem = TreasureModel.items[debrisItem.treasureModelID or 0] or {}
                text = text .. TR("抢夺到%d个%s%s锻造石", targetlayer.mBattleResult.GetExp, Enums.Color.eYellowH, (treasureItem.name or ""))
            else
                text = text .. TR("未抢夺到任何锻造石")
            end
            node = ui.newLabel({
                text = text,
                color = Enums.Color.eWhite,
                size = 26,
            })
        elseif name == "Choice" then
            -- 翻牌控件
            height = 223
            node = ResultUtility.createChoiceCardInfo(targetlayer.mBattleResult.ChoiceGetGameResource, tempCallBack)
            mChoiceNode_ = node
        elseif name == "CommonTips" then
            -- 序列争霸提示信息
            height = 52
            node = ui.newLabel({
                text = TR("请选择战利品"),
                color = Enums.Color.eWhite,
                size = 26,
            })
        elseif name == "FapUp" then
            height = 166
            node = ResultUtility.createEnhanceBtns()
        elseif name == "Drop" then
            -- 掉落
            local dropList = Utility.analysisGameDrop(targetlayer.mBattleResult.BaseGetGameResourceList)
            height = 150
            if #dropList > 0 then
                node = ui.createCardList({
                    maxViewWidth = 620,
                    space = 20,
                    cardDataList = dropList,
                    allowClick = false, --是否可点击, 默认为false
                    needAction = true, -- 是否需要动画显示列表, 默认为false
                    needArrows = true, -- 当需要滑动显示时是否需要左右箭头, 默认为false
                })
            else
                node = ui.newLabel({
                    text = TR("本次无物品掉落"),
                    color = Enums.Color.eYellow,
                })
            end
        elseif name == "Tips" then
            height = 30
            node = ui.newLabel({
                text = TR(data[name]),
                color = Enums.Color.eWhite,
                size = 26,
            })
        else
            node = nil
        end

        -- 加入
        if height ~= nil then
            y = y - height
            if node ~= nil then
                node:setAnchorPoint(cc.p(0.5, 0))
                node:setPosition(0, y)
                parent:addChild(node)
            end
        end
    end

    parent:setPosition(320, 865)
    targetlayer.mParentLayer:addChild(parent)

    return parent, mChoiceNode_
end

-- 群雄争霸（个人PVP）战斗前后境界变化控件
--[[
    pvpResult: 战斗数据
]]
function ResultUtility.createStateChange(self, pvpResult)
    local stars, rateLabel = {}, nil

    local temptext, stateStr, stepStr = "", "", ""
    if pvpResult.BeforeState < 6 then
        if pvpResult.IsWin then
            if pvpResult.IsStreak then
                temptext = TR("连胜额外获得1星")
            else
                temptext = TR("战斗胜利获得1星")
            end
        else
            temptext = TR("战斗失败扣除1星")
        end
    else
        if pvpResult.IsWin then
            temptext = TR("战斗胜利获得积分: +%d", pvpResult.ChangeRate)
        else
            temptext = TR("战斗失败扣除积分: -%d", pvpResult.ChangeRate)
        end
    end
    local wintext = ui.newLabel({
        text = temptext,
        color = Enums.Color.eYellow,
        size = 26,
        outlineColor = Enums.Color.eOutlineColor,
    })
    wintext:setPosition(320, 445)
    self.mParentLayer:addChild(wintext)

    -- 变化前的信息
    local beforeData = {
        state = pvpResult.BeforeState,
        step = pvpResult.BeforeStep,
        star = pvpResult.BeforeStar,
        rate = pvpResult.BeforeRate,
    }
    -- 变化后的信息
    local afterData = {
        state = pvpResult.AfterState,
        step = pvpResult.AfterStep,
        star = pvpResult.AfterStar,
        rate = pvpResult.AfterRate,
    }

    local parent = cc.Node:create()
    parent:setPosition(0, 0)
    self.mParentLayer:addChild(parent)

    local function createStateInfo(info, stepIsChange, stateIsChange)
        parent:removeAllChildren()
        stars = {}

        local stateRelation = PvpinterStateRelation.items[info.state]

        -- 境界图片
        local stateSprite = ui.newSprite(stateRelation.stateHeadFrame2 .. ".png")
        stateSprite:setPosition(320, stateIsChange and 550 or 530)
        stateSprite:setScale(stateIsChange and 3 or 0.8)
        parent:addChild(stateSprite)

        if stateIsChange then
            local action = {
                cc.EaseSineOut:create(cc.MoveTo:create(0.1, cc.p(320, 530))),
                cc.EaseSineOut:create(cc.ScaleTo:create(0.1, 0.8))
            }
            stateSprite:runAction(cc.Spawn:create(action))
        end

        if info.state < 6 then
            -- “阶”图片
            local tempSprite = ui.newSprite("qxzb_20.png")
            tempSprite:setPosition(230, 400)
            parent:addChild(tempSprite)

            -- 阶位
            local stepSprite = ui.newNumberLabel({
                text = info.step,
                imgFile = "qxzb_19.png",
                startChar = 49,
            })
            stepSprite:setPosition(200, 400)
            stepSprite:setScale(stepIsChange and 2 or 1)
            parent:addChild(stepSprite)

            if stepIsChange then
                local action = {
                    cc.EaseSineOut:create(cc.ScaleTo:create(0.1, 1))
                }
                stepSprite:runAction(cc.Spawn:create(action))
            end

            -- 星数
            local pvpInterStateInfo = PvpinterStateRelation.items[info.state]
            for index = 1, pvpInterStateInfo.perStepStars do
                local tempSprite = ui.newSprite("c_75.png")
                tempSprite:setAnchorPoint(cc.p(0.5, 0.5))
                tempSprite:setPosition(310 + 50 * (index - 1), 400)
                parent:addChild(tempSprite)
                tempSprite:setGray(index > info.star)

                table.insert(stars, tempSprite)
            end
        else
            -- 积分
            rateLabel = ui.newLabel({
                text = TR("当前积分: %d", info.rate),
                size = 26,
                color = Enums.Color.eYellow,
                outlineColor = Enums.Color.eOutlineColor,
            })
            rateLabel:setAnchorPoint(cc.p(0.5, 0.5))
            rateLabel:setPosition(320, 400)
            parent:addChild(rateLabel)
        end
    end

    -- 创建变化前的境界信息
    createStateInfo(beforeData)

    -- 星星变动动画
    if pvpResult.BeforeStep == pvpResult.AfterStep then  -- 阶位未变化
        if pvpResult.IsWin then  -- 胜利
            local changeStars = pvpResult.AfterStar - pvpResult.BeforeStar
            for i = 1, changeStars do
                local starSprite = stars[pvpResult.BeforeStar + i]
                local action = {
                    cc.DelayTime:create(0.5 * (i - 1)),
                    cc.ScaleTo:create(0.5, 1.2),
                    cc.RotateTo:create(0.5, 720),
                    cc.CallFunc:create(function()
                        starSprite:setGray(false)
                    end),
                    cc.ScaleTo:create(0.1, 1),
                }
                starSprite:runAction(cc.Sequence:create(action))
            end
        else  -- 失败
            local changeStars = pvpResult.BeforeStar - pvpResult.AfterStar
            for i = 1, changeStars do
                local starSprite = stars[pvpResult.BeforeStar - (i - 1)]
                local action = {
                    cc.DelayTime:create(0.5 * (i - 1)),
                    cc.ScaleTo:create(0.5, 1.2),
                    cc.RotateTo:create(0.5, 720),
                    cc.CallFunc:create(function()
                        starSprite:setGray(true)
                    end),
                    cc.ScaleTo:create(0.1, 1),
                }
                starSprite:runAction(cc.Sequence:create(action))
            end
        end
    else -- 阶位改变
        if pvpResult.IsWin then
            local changeStars = PvpinterStateRelation.items[pvpResult.BeforeState].perStepStars - pvpResult.BeforeStar
            for i = 1, changeStars do
                local starSprite = stars[pvpResult.BeforeStar + i]
                local action = {
                    cc.DelayTime:create(0.5 * (i - 1)),
                    cc.ScaleTo:create(0.5, 1.2),
                    cc.RotateTo:create(0.5, 720),
                    cc.CallFunc:create(function()
                        starSprite:setGray(false)
                    end),
                    cc.ScaleTo:create(0.1, 1),
                    cc.CallFunc:create(function()
                        if i < changeStars then
                            return
                        end

                        -- 延迟0.5执行
                        Utility.performWithDelay(self.mParentLayer, function()
                            -- 创建变化后的境界信息
                            afterData.star = pvpResult.AfterStar > 0 and pvpResult.AfterStar - 1 or pvpResult.AfterStar
                            if pvpResult.BeforeState ~= pvpResult.AfterState then
                                createStateInfo(afterData, true, true)
                            else
                                createStateInfo(afterData, true)
                            end

                            local changeStars = pvpResult.AfterStar
                            for i = 1, changeStars do
                                local tempSprite = stars[i]
                                local action = {
                                    cc.DelayTime:create(0.5 * (i - 1)),
                                    cc.ScaleTo:create(0.5, 1.2),
                                    cc.RotateTo:create(0.5, 720),
                                    cc.CallFunc:create(function()
                                        tempSprite:setGray(false)
                                    end),
                                    cc.ScaleTo:create(0.1, 1),
                                }
                                if tempSprite then
                                    tempSprite:runAction(cc.Sequence:create(action))
                                end
                            end
                        end, 0.5)
                    end)
                }
                starSprite:runAction(cc.Sequence:create(action))
            end
        else
            -- 创建变化后的境界信息
            afterData.star = pvpResult.AfterStar + 1
            if pvpResult.BeforeState ~= pvpResult.AfterState then
                createStateInfo(afterData, true, true)
            else
                createStateInfo(afterData, true)
            end

            local changeStars = PvpinterStateRelation.items[pvpResult.AfterState].perStepStars - pvpResult.AfterStar
            for i = 1, changeStars do
                local tempSprite = stars[pvpResult.AfterStar + i]
                local action = {
                    cc.DelayTime:create(0.5 * (i - 1)),
                    cc.ScaleTo:create(0.5, 1.2),
                    cc.RotateTo:create(0.5, 720),
                    cc.CallFunc:create(function()
                        tempSprite:setGray(true)
                    end),
                    cc.ScaleTo:create(0.1, 1),
                }
                tempSprite:runAction(cc.Sequence:create(action))
            end
        end
    end

    -- 积分变动动画
    if pvpResult.BeforeRate ~= pvpResult.AfterRate then
        local rateNum = pvpResult.BeforeRate
        Utility.schedule(rateLabel, function()
            rateNum = pvpResult.IsWin and rateNum + 1 or rateNum - 1
            rateLabel:setString(TR("当前积分: %d", rateNum))

            if rateNum == pvpResult.AfterRate or rateNum == 0 then
                rateLabel:stopAllActions()
            end
        end, 0.01)
    end
end
