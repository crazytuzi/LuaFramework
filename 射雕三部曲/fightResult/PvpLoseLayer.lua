--[[
    文件名: PvpLoseLayer.lua
	描述: Pvp 战斗失败结算页面
	创建人: suntao
	创建时间: 2016.06.20
-- ]]

local PvpLoseLayer = class("PvpLoseLayer", function(params)
	local parent = display.newLayer(cc.c4b(0, 0, 0, 200))
	-- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = parent})
	return parent
end)

-- 构造函数
--[[
-- 参数 params 中的各项为
	{
		battleType = ModuleSub.eBattleNormal, -- 战役类型, 在 EnumsConfig.lua 文件的 ModuleSub中定义
		result = nil,  -- 服务端返回的结果
		myInfo = {}, -- 我方信息， 默认为nil
		enemyInfo = {}, -- 对方信息， 默认为nil
	}
]]
function PvpLoseLayer:ctor(params)
	params = params or {}
	self.mBattleType = params.battleType
	self.mBattleResult = params.result
	self.mMyInfo = params.myInfo
	self.mEnemyInfo = params.enemyInfo
	self.mParams = params

    -- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    local bgSprite = ui.newSprite("zdjs_02.png")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite, -10)

    -- 显示背景图
    local bgEffect = ui.newEffect({
        parent = self.mParentLayer,
        effectName = "effect_ui_zhandoushibai",
        position = cc.p(320, 514),
        animation = "zhandoushenglipvp",
        loop = false,
        endRelease = true,
        completeListener = function()
            ui.newEffect({
                parent = self.mParentLayer,
                zorder = -1,
                effectName = "effect_ui_zhandoushibai",
                animation = "zhandoushenglixunhuanpvp",
                position = cc.p(320, 514),
                loop = true,
                endRelease = false,
            })
        end,
    })

    -- local tmpSprite = ui.newScale9Sprite("zdjs_05.png", cc.size(640, 450))
    -- tmpSprite:setAnchorPoint(0.5, 1)
    -- tmpSprite:setPosition(320, 696.29)
    -- self.mParentLayer:addChild(tmpSprite)

	-- 初始化页面控件
	self:initUI()
end

-- 初始化页面控件
function PvpLoseLayer:initUI()
	local hasEnemyButton = self.mEnemyInfo.PlayerId ~= nil
    -- 关闭按钮
    local x = 320
    local offsetX = 210
    if not hasEnemyButton then 
        x = x + 105
    end

    local buttonInfo = {
		normalImage = "c_28.png",
		text = TR("关闭"),
    	anchorPoint = cc.p(0.5, 0.5),
    	clickAction = function()
            if self.mBattleType == ModuleSub.eExpedition then -- 如果是六大派 需要传参数 让不能自动开战
                local tempStr = "challenge.ExpediTeamLayer"
                local tempData = LayerManager.getRestoreData(tempStr)
                tempData.autoWar = 1
                LayerManager.setRestoreData(tempStr, tempData)
            end 
    		-- 删除战斗页面
    		LayerManager.removeTopLayer(true)
    	end,
	}
    local button = ui.newButton(buttonInfo)
    button:setPosition(self.mBattleType ~= ModuleSub.eExpedition and x or 320, self.mBattleType ~= ModuleSub.eExpedition and 160 or 130)
    self.mParentLayer:addChild(button)
    self.mCloseBtn = button

    -- 重播按钮
    buttonInfo.text = TR("重播")
    buttonInfo.clickAction = function()
        -- 如果是挑战六大派 重播战报入口不一样
        -- if self.mBattleType == ModuleSub.eExpedition then 
        --     self:replayExpedition()
        --     return 
        -- end 
            
    	self:replay()
    end
    local button = ui.newButton(buttonInfo)
    button:setPosition((x - offsetX), 160) -- 
    self.mParentLayer:addChild(button)
    button:setVisible(self.mBattleType ~= ModuleSub.eExpedition)
    self.mReplayBtn = button

    -- 战斗统计按钮
    local statistsBtn = ui.newButton({
        normalImage = "zdjs_45.png",
        clickAction = function ()
            local fightInfo = self.mBattleResult.FightInfo or self.mBattleResult.Result or self.mBattleResult
            if type(fightInfo) == type("") then
                fightInfo = cjson.decode(fightInfo)
            end
            LayerManager.addLayer({name = "fightResult.DlgStatistDamageLayer", data = {statData = fightInfo.StatistsData}, cleanUp = false})
        end,
    })
    statistsBtn:setPosition(575, 800)
    self.mParentLayer:addChild(statistsBtn)

    -- 敌方阵容按钮
    buttonInfo.text = TR("敌方阵容")
    buttonInfo.clickAction = function()
    	if hasEnemyButton then
    		Utility.showPlayerTeam(self.mEnemyInfo.PlayerId, self.mBattleType == ModuleSub.ePVPInter)
    	end
    end
    local button = ui.newButton(buttonInfo)
    button:setPosition(x + offsetX, 160)
    self.mParentLayer:addChild(button)
    if not hasEnemyButton then
        button:setVisible(false)
    end

    local mEnhanceNode = ResultUtility.createEnhanceBtns()
    mEnhanceNode:setAnchorPoint(cc.p(0.5, 0.5))
    mEnhanceNode:setPosition(320, self.mBattleType ~= ModuleSub.eExpedition and 360 or 240)
    self.mParentLayer:addChild(mEnhanceNode)

    -- 显示战斗失败后提升战力的挑战按钮
    if self.mBattleType == ModuleSub.eShengyuanWars then 
        mEnhanceNode:setVisible(false)
    end     

    -- 显示特殊的控件
    if (self.mBattleType ~= ModuleSub.eTeambattle) then
        -- 战力对比
        if (self.mMyInfo ~= nil) and (self.mEnemyInfo ~= nil) and (self.mBattleType ~= ModuleSub.eExpedition and self.mBattleType ~= ModuleSub.ePVPInter) then
            local vsNode = ResultUtility.createVsInfo({
                myInfo = self.mMyInfo,
                otherInfo = self.mEnemyInfo,
                viewSize = cc.size(640, 100),
                bgImg = "",
                bgIsScale9 = true,
            })
            vsNode:setAnchorPoint(cc.p(0.5, 1))
            vsNode:setPosition(320, (self.mBattleType ~= ModuleSub.eShengyuanWars) and 760 or 650)
            self.mParentLayer:addChild(vsNode)
        end
        if self.mBattleType ~= ModuleSub.eExpedition and self.mBattleType ~= ModuleSub.ePVPInter and self.mBattleType ~= ModuleSub.eShengyuanWars and self.mBattleType ~= ModuleSub.eGuildBattle then 
            -- 玩家属性
            local dropList = Utility.analysisGameDrop(self.mBattleResult.BaseGetGameResourceList)
            local resTypeList = {ResourcetypeSub.eGold, ResourcetypeSub.eEXP, ResourcetypeSub.eHeroExp}
            local attrList, addExp = Utility.splitDropPlayerAttr(dropList, resTypeList)
            
            -- 玩家属性背景
            local attrBgSprite = ui.newSprite("zdjs_06.png")
            attrBgSprite:setPosition(cc.p(320, 590))
            self.mParentLayer:addChild(attrBgSprite)

            -- 创建掉落的玩家属性显示
            local attrNode = ResultUtility.createPlayerAttr(attrList)
            attrNode:setAnchorPoint(cc.p(0.5, 0.5))
            attrNode:setPosition(320, 590)
            self.mParentLayer:addChild(attrNode)

            -- 创建经验条
            if (self.mBattleType ~= ModuleSub.ePVPInter) then
                local expNode = ResultUtility.createExpProg(addExp)
                expNode:setAnchorPoint(cc.p(0.5, 0.5))
                expNode:setPosition(320, 510)
                self.mParentLayer:addChild(expNode)
            end
        elseif self.mBattleType == ModuleSub.ePVPInter then
            local layout = require("fightResult.PvpWinLayer").createPvpInterUI(self)
            layout:setAnchorPoint(cc.p(0.5, 1))
            layout:setPosition(320, 840)
            self.mParentLayer:addChild(layout, 1)
            -- 创建境界变化前后信息
            ResultUtility.createStateChange(self, self.mBattleResult.PVPinterFightLog)
            -- 掉落
            local height
            if self.mBattleResult.BaseGetGameResourceList then
                height = 470
            else
                height = 430
            end
            ResultUtility.createUi(self, {height, "Drop"})

            mEnhanceNode:setPositionY(160)
            self.mCloseBtn:setPositionY(50)
            self.mReplayBtn:setPositionY(50)
        elseif self.mBattleType == ModuleSub.eShengyuanWars then   
            self.mCloseBtn:setPosition(320, 340)
            self.mReplayBtn:setVisible(false)
        elseif self.mBattleType == ModuleSub.eGuildBattle then
            -- 创建灰色星星
            local showTextList = {
                TR("消灭敌方主角"),
                TR("消灭敌方任意三人"),
                TR("全灭敌方"),
            }
            local starBgSize = cc.size(500, 45)
            for i, starText in pairs(showTextList) do
                local starBg = ui.newScale9Sprite("zdjs_06.png", starBgSize)
                starBg:setPosition(320, 620-(i-1)*60)
                self.mParentLayer:addChild(starBg)

                local starLabel = ui.newLabel({
                        text = "{c_102.png}   "..starText,
                        color = Enums.Color.eWhite,
                        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
                        size = 20,
                    })
                starLabel:setAnchorPoint(cc.p(0, 0.5))
                starLabel:setPosition(starBgSize.width*0.3, starBgSize.height*0.5)
                starBg:addChild(starLabel)
            end

            self.mCloseBtn:setPosition(425, 200)
            self.mReplayBtn:setPosition(215, 200)
        elseif self.mBattleType == ModuleSub.eExpedition then
         -- 挑战六大派显示不同的重播
            -- dump(self.mParams,"self.mParams")
            -- 显示敌我双方标签
            local leftPosX, rightPosx = 160, 480
            for i=1,2 do
                -- 1代表左边是我方队友
                local image = i==1 and "zdjs_17.png" or "zdjs_16.png"  
                local posX = i==1 and leftPosX or rightPosx
                local IconSprite = ui.newSprite(image)
                IconSprite:setPosition(posX, 730)
                self.mParentLayer:addChild(IconSprite) 
            end

            -- 添加三对hero头像
            local nodeModelInfo = ExpeditionNodeModel.items[self.mParams.result.NodeInfo.NodeModelId]
            local enemyModelIdList = string.split(nodeModelInfo.heroModelID, "|")
            for i = 1, #self.mParams.myInfo do
                local posY = 660 - (i-1)*120
                -- 我方头像
                local myHeroCard = CardNode.createCardNode({
                    modelId = self.mParams.myInfo[i].HeadImageId,
                    fashionModelID = self.mParams.myInfo[i].FashionModelId,
                    IllusionModelId = self.mParams.myInfo[i].IllusionModelId,
                    resourceTypeSub = ResourcetypeSub.eHero,
                    allowClick = false,
                    cardShowAttrs = {
                        CardShowAttr.eBorder,
                    }
                })
                myHeroCard:setScale(0.95)
                myHeroCard:setPosition(leftPosX, posY)
                myHeroCard:setCardName(string.format(self.mParams.myInfo[i].Name))
                self.mParentLayer:addChild(myHeroCard)

                -- 敌方头像
                local enemyModelId = tonumber(string.split(enemyModelIdList[i], ",")[2])
                local enemyHeroCard = CardNode.createCardNode({
                    modelId = enemyModelId,
                    resourceTypeSub = ResourcetypeSub.eHero,
                    allowClick = false,
                    cardShowAttrs = {
                        CardShowAttr.eBorder,
                        CardShowAttr.eName
                    }
                })
                enemyHeroCard:setScale(0.95)
                enemyHeroCard:setPosition(rightPosx, posY)
                self.mParentLayer:addChild(enemyHeroCard)

                -- 查看战报按钮
                local battleBtn = ui.newButton({
                    normalImage = "zdjs_15.png",
                    position = cc.p(320, posY),
                    clickAction = function()
                        self:replayExpedition(i)
                    end
                })
                self.mParentLayer:addChild(battleBtn) 

                -- 添加胜负标签  
                local myIsWinImage = self.mParams.result.FightResults[i].IsWin and "zdjs_14.png" or "zdjs_13.png" 
                local enemyIsWinImage = self.mParams.result.FightResults[i].IsWin and "zdjs_13.png" or "zdjs_14.png" 
                local myIswinSprite = ui.newSprite(myIsWinImage)
                myIswinSprite:setPosition(23, 77)
                myHeroCard:addChild(myIswinSprite)

                local enemyIsWinSprite = ui.newSprite(enemyIsWinImage)
                enemyIsWinSprite:setPosition(23, 77)
                enemyHeroCard:addChild(enemyIsWinSprite)

                self.mCloseBtn:setClickAction(function() --回放特殊处理
                    if self.mBattleType == ModuleSub.eExpedition then -- 如果是六大派 需要传参数 让不能自动开战
                        local tempStr = "challenge.ExpediTeamLayer"
                        local tempData = LayerManager.getRestoreData(tempStr)
                        tempData.autoWar = 1
                        LayerManager.setRestoreData(tempStr, tempData)
                    end 
                    -- 删除战斗页面
                    local layerName = LayerManager.getTopCleanLayerName()
                    if layerName == "ComBattle.BattleLayer" then -- 回放特殊处理
                        LayerManager.deleteStackItem("challenge.ExpediMapLayer")
                    end
                    LayerManager.removeTopLayer(true)
                end)
            end
        end     
    end  
end

-- 重播
function PvpLoseLayer:replay()
	local params = self.mParams

    local layerName = LayerManager.layerStack[table.getn(LayerManager.layerStack) - 1].name
    if layerName == "challenge.PvpInterFightLayer" then
        LayerManager.deleteStackItem("challenge.PvpInterFightLayer")
    end
    
	-- 战斗页面控制信息
    local controlParams = Utility.getBattleControl(params.battleType)
    local fightInfo = params.result.FightInfo or params.result.Result or params.result
    if type(fightInfo) == type("") then
        fightInfo = cjson.decode(fightInfo)
    end
    -- 调用战斗页面
    LayerManager.addLayer({
        name = "ComBattle.BattleLayer",
        data = {
            data = fightInfo,
            skip = controlParams.skip,
            trustee = controlParams.trustee,
            skill = controlParams.skill,
            map = Utility.getBattleBgFile(params.battleType),
            callback = function(retData)
                PvpResult.showPvpResultLayer(
                    params.battleType,
					params.result,
					params.myInfo,
					params.enemyInfo
                )

                if controlParams.trustee and controlParams.trustee.changeTrusteeState then
                    controlParams.trustee.changeTrusteeState(retData.trustee)
                end
            end
        },
    })
end

-- 挑战六大派 重播战报入口
function PvpLoseLayer:replayExpedition(index)
    local params = self.mParams

    -- 战斗页面控制信息
    local controlParams = Utility.getBattleControl(ModuleSub.eChallengeGrab) -- 用神兵锻造的规则
    -- 调用战斗页面
    LayerManager.addLayer({
        name = "ComBattle.BattleLayer",
        data = {
            data = params.result.FightInfo[index],
            skip = controlParams.skip,
            trustee = controlParams.trustee,
            skill = controlParams.skill,
            map = Utility.getBattleBgFile(ModuleSub.eChallengeGrab),
            callback = function(retData)
                PvpResult.showPvpResultLayer(
                    params.battleType,
                    params.result,
                    params.myInfo,
                    params.enemyInfo or nil
                )

                if controlParams.trustee and controlParams.trustee.changeTrusteeState then
                    controlParams.trustee.changeTrusteeState(retData.trustee)
                end
            end
        },
    })
end

return PvpLoseLayer
