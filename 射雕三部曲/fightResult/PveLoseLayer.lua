--[[
    文件名: PveLoseLayer.lua
	描述: Pve 战斗失败结算页面
	创建人: liaoyuangang
	创建时间: 2016.06.10
-- ]]

local PveLoseLayer = class("PveLoseLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params 中的各项为
	{
		battleType = ModuleSub.eBattleNormal, -- 战役类型, 在 EnumsConfig.lua 文件的 ModuleSub中定义
		starCount = 0, -- 星数
		result = nil,  -- 服务端返回的结果
		myInfo = {}, -- 我方信息， 默认为nil
		enemyInfo = {}, -- 对方信息， 默认为nil
		extraData = {}, -- 模块数据
	}
]]
function PveLoseLayer:ctor(params)
	params = params or {}
	self.mBattleType = params.battleType
	self.mStarCount = params.starCount
	self.mBattleResult = params.result
	self.mMyInfo = params.myInfo
	self.mEnemyInfo = params.enemyInfo
	self.mExtraData = params.extraData or {}

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 初始化页面控件
	self:initUI()
end

-- 初始化页面控件
function PveLoseLayer:initUI()
	local needVsInfo = (self.mMyInfo ~= nil) and (self.mEnemyInfo ~= nil)

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

    -- local bg2Sprite = ui.newScale9Sprite("zdjs_05.png", cc.size(640, 350))
    -- bg2Sprite:setAnchorPoint(0.5, 1)
    -- bg2Sprite:setPosition(320, 696.29)
    -- self.mParentLayer:addChild(bg2Sprite)

    -- -- 战斗统计按钮
    -- local statistsBtn = ui.newButton({
    --     normalImage = "zdjs_45.png",
    --     clickAction = function ()
    --         LayerManager.addLayer({name = "fightResult.DlgStatistDamageLayer", cleanUp = false})
    --     end,
    -- })
    -- statistsBtn:setPosition(575, 800)
    -- self.mParentLayer:addChild(statistsBtn)

    -- 显示双方战力信息
    if needVsInfo then
    	-- 显示对阵双方的战力信息
		local vsNode = ResultUtility.createVsInfo({
			myInfo = self.mMyInfo,
			otherInfo = self.mEnemyInfo,
			viewSize = cc.size(640, 100),
			bgImg = "",
			bgIsScale9 = true,
		})
		vsNode:setAnchorPoint(cc.p(0.5, 1))
		vsNode:setPosition(320, 760)
		self.mParentLayer:addChild(vsNode)
    end

    -- 显示战斗失败后提升战力的挑战按钮
	local mEnhanceNode = ResultUtility.createEnhanceBtns()
	mEnhanceNode:setAnchorPoint(cc.p(0.5, 0.5))
	mEnhanceNode:setPosition(320, 540)
	self.mParentLayer:addChild(mEnhanceNode)

    -- 关闭按钮
    local button = ui.newButton({
        normalImage = "c_33.png",
        text = TR("关闭"),
        textColor = Enums.Color.eWhite,
        anchorPoint = cc.p(0.5, 0.5),
        clickAction = function()
            -- 删除战斗页面
            LayerManager.removeTopLayer(true)
        end,
    })
    button:setPosition(320, 200)
    self.mParentLayer:addChild(button)
    self.mCloseBtn = button


    if self.mBattleType == ModuleSub.eBattleNormal then
        self:createBattleNormalUI()
    elseif self.mBattleType == ModuleSub.ePracticeBloodyDemonDomain then -- 九山兵阁
    	self:createPracticeBloodyDemonDomainUI()
    elseif self.mBattleType == ModuleSub.eSectTask then
        mEnhanceNode:setPosition(320, 360)
        self:createSectFightUI()
    end
end

-- 创建普通副本特殊的控件
function PveLoseLayer:createBattleNormalUI()
	-- 如果自动推图已经开启
    if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eBattleAutomatic, false) then
	   ResultUtility.createAutoFightViews(self)
    end
end

-- 创建九山兵阁特殊控件
function PveLoseLayer:createPracticeBloodyDemonDomainUI()
	-- 标题
	local label = ui.newLabel({
        text = TR("通关评价"),
        color = Enums.Color.eYellow,
        size = 26,
        x = 320,
        y = 690,
    })
    self.mParentLayer:addChild(label)

    -- 条件
    local label = ui.newLabel({
        text = TR("未能达成通关条件 : %s", self.mExtraData.condition or ""),
        color = Enums.Color.eWhite,
        x = 320,
        y = 655,
    })
    self.mParentLayer:addChild(label)
end

-- 创建门派战斗特殊控件
function PveLoseLayer:createSectFightUI()

    local taskModel = SectTaskWeightRelation.items[self.mExtraData[1]]

    local tipSprite = ui.newSprite("mp_48.png")
    tipSprite:setPosition(320, 580)
    self.mParentLayer:addChild(tipSprite)

    local taskLable = ui.newLabel({
        text = TR("  手动释放技能\n获胜几率更高哦"),
        size = 24,
        outlineColor = Enums.Color.eBlack,
        })
    taskLable:setPosition(413, 183)
    tipSprite:addChild(taskLable)

end

----------------- 新手引导 -------------------
function PveLoseLayer:onEnterTransitionFinish()
    self:executeGuide()
end

-- 执行新手引导
function PveLoseLayer:executeGuide()
    Guide.helper:executeGuide({
        [4001] = {clickNode = self.mCloseBtn},
    })
end

return PveLoseLayer
