--[[
    文件名：JianghuKillTeamLayer.lua
    描述：江湖杀组队页面
    创建人：chenzhong
    创建时间：2018.9.20
--]]
local JianghuKillTeamLayer = class("JianghuKillTeamLayer", function(params)
    return display.newLayer()
end)


local gLayerTab = {
    myTeam = 1,  -- 我的队友
    otherTeam = 2,   -- 其他队伍
}

-- 构造函数
--[[
    params:
        currentNodeId :当前节点ID
--]]
function JianghuKillTeamLayer:ctor(params)
    self.mNodeId = params.currentNodeId
    self.mCurrTab = gLayerTab.myTeam
    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = "jhs_70.png",
        titlePos = cc.p(307, 895),
        bgImage = "jhs_40.png",
        bgSize = cc.size(615, 916),
        closeImg = "c_29.png",
        closeBtnPos = cc.p(570, 955),
        popAction = false,
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)
    -- 保存弹窗控件信息
    self.mBgSprite = bgLayer.mBgSprite

    -- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(35, 955),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                TR("1.玩家可以创建队伍或者加入他人的队伍，点击其他队伍即可查看并加入他人队伍。"),
                TR("2.刚创建的队伍，或者刚发布组队邀请的队伍，其他玩家才能看到。"),
                TR("3.只能加入在同一门派的队伍，即组队玩家必须在同一门派。"),
                TR("4.当队员全部准备后，队长可以带领全体队员一起前往其他邻近门派。"),
                TR("5.当队长为镖师时，全体队员共享镖师的移动速度，并且队员不消耗粮草。"),
            })
        end})
    self.mBgSprite:addChild(ruleBtn)

    -- 由于每个tab的子页面都加了ui.newStdLayer 避免重复设置缩放 适配出问题，在这儿不加缩放
    self.mSubLayer = cc.Layer:create()
    self.mSubLayer:setContentSize(cc.size(640, 1136))
    bgLayer:addChild(self.mSubLayer)

    -- 初始化UI
    self:initUI()

    -- 
    self:changePage()
end

function JianghuKillTeamLayer:initUI()
    local tabConfig = {
        {tag = gLayerTab.myTeam, text = TR("我的队伍")},
        {tag = gLayerTab.otherTeam, text = TR("其他队伍")},
    }
    local tabLayer = ui.newTabLayer({
        viewSize = cc.size(590, 90),
        btnInfos = tabConfig,
        defaultSelectTag = self.mCurrTab,
        -- needLine = true,
        onSelectChange = function(tag)
            if (self.mCurrTab ~= tag) then
                self.mCurrTab = tag
                -- 切换子页面
                self:changePage()
            end
        end,
    })
    tabLayer:setAnchorPoint(cc.p(0.5, 1))
    tabLayer:setPosition(cc.p(310, 885))
    self.mBgSprite:addChild(tabLayer)
end

-- 切换子页面
function JianghuKillTeamLayer:changePage()
    -- 删除原来的子页面
    self.mSubLayer:removeAllChildren()
    if self.mCurrTab == gLayerTab.myTeam then             -- 我的队伍
        local tempLayer = require("jianghuKill.JianghuKillMyTeamLayer").new({currentNodeId = self.mNodeId or 1})
        self.mSubLayer:addChild(tempLayer)
    elseif self.mCurrTab == gLayerTab.otherTeam then    -- 其他队伍
        local tempLayer = require("jianghuKill.JianghuKillOtherTeamLayer").new()
        self.mSubLayer:addChild(tempLayer)
    end
end

return JianghuKillTeamLayer
