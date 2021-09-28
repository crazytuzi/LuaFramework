--[[
    文件名: KillerValleyGameEndLayer.lua
	描述: 绝情谷游戏结束页面
	创建人: peiyaoqiang
	创建时间: 2018.01.26
-- ]]

local KillerValleyGameEndLayer = class("KillerValleyGameEndLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 128))
end)

--[[
    isDelay: 是否延迟显示，默认为false
--]]
function KillerValleyGameEndLayer:ctor(params)
    -- 从Helper里读取结果，或者由参数传来
    local resultData = clone(KillerValleyHelper.battleResultData)
	self.myRank = 0          -- 我的排名
	self.myKill = 0          -- 我的击杀
	self.myScore = 0         -- 我的积分
    for _,v in ipairs(resultData) do
        if (v.PlayerId ~= nil) and (v.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId")) then
            self.myRank = v.Rank
            self.myKill = v.KillNum
            self.myScore = v.FightScore
            self.reportInfo = v
            self.reportInfo.isWin = (self.myRank == 1)
            break
        end
    end
	self.rankInfo = resultData         -- 当前排名列表
    self.isWin = (self.myRank == 1)     -- 是否胜利

    --屏蔽下层触控
    ui.registerSwallowTouch({node = self})

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 初始化页面控件
    if params and params.isDelay then
        Utility.performWithDelay(self.mParentLayer, handler(self, self.initUI), 1)
    else
        self:initUI()
    end
end

-- 初始化页面控件
function KillerValleyGameEndLayer:initUI()
    -- 显示背景图
    local bgSprite = ui.newSprite((self.isWin == true) and "jqg_2.png" or "jqg_1.png")
    bgSprite:setPosition(cc.p(320, 600))
    self.mParentLayer:addChild(bgSprite)

    -- 显示排名和积分
    local function addLabel(strText, anchor, pos)
        local label = ui.newLabel({
            text = strText,
            anchorPoint = anchor,
            outlineColor = Enums.Color.eOutlineColor,
        })
        label:setPosition(pos)
        bgSprite:addChild(label)
    end
    local yPos = (self.isWin == true) and 510 or 520
    addLabel(TR("本场排名: %s%s", "#ffdd80", self.myRank), cc.p(0, 0.5), cc.p(60, yPos))
    addLabel(TR("击杀: %s%s", "#ffb380", self.myKill), cc.p(0.5, 0.5), cc.p(320, yPos))
    addLabel(TR("积分: %s%s", "#96e5ff", self.myScore), cc.p(1, 0.5), cc.p(580, yPos))

    -- 当前排行
    local btnRank = ui.newButton({
        normalImage = "c_28.png",
        text = TR("当前排行"),
        clickAction = function ()
            LayerManager.addLayer({name = "killervalley.DlgGameRankLayer", data = self.rankInfo, cleanUp = false})
        end,
    })
    btnRank:setPosition(140, 280)
    self.mParentLayer:addChild(btnRank)

    -- 战报
    local btnReport = ui.newButton({
        normalImage = "c_28.png",
        text = TR("战报"),
        clickAction = function ()
            LayerManager.addLayer({name = "killervalley.DlgGameReportLayer", data = self.reportInfo, cleanUp = false})
        end,
    })
    btnReport:setPosition(320, 280)
    self.mParentLayer:addChild(btnReport)

    -- 关闭按钮
    local btnClose = ui.newButton({
    	normalImage = "c_33.png",
    	text = TR("退出"),
    	clickAction = function ()
            -- 清除缓存数据
            KillerValleyHelper:clearUpBattleResult()
            -- 回到挑战界面
            KillerValleyUiHelper:exitGame(true)
    	end,
    })
    btnClose:setPosition(500, 280)
    self.mParentLayer:addChild(btnClose)
end

----------------------------------------------------------------------------------------------------

return KillerValleyGameEndLayer
