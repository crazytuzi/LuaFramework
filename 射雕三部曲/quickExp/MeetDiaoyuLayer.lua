--[[
    文件名: MeetDiaoyuLayer.lua
	描述: 奇遇-钓鱼
	创建人: yanghongsheng
	创建时间: 2017.4.10
--]]

--[[
    params =  {
        meetInfo   :    奇遇数据
        showMeetId :    选中界面ID
        selIndex   :    选中页索引
    }
]]

local MeetDiaoyuLayer = class("MeetDiaoyuLayer", function()
    return display.newLayer()
end)

--战斗对象类型(简单 普通 困难)
local FishType = {
    [1] = {id = 1, res = "cdjh_51.png", str = TR("泡泡鱼")},    -- 轻而易举
    [2] = {id = 2, res = "cdjh_52.png", str = TR("金色鲤鱼")},    -- 势均力敌
    [3] = {id = 3, res = "cdjh_53.png", str = TR("蓝色小龙虾")}     -- 实力强劲
}

function MeetDiaoyuLayer:ctor(params)
	--当前奇遇数据
    self.mMeetInfo = params.meetInfo[params.selIndex]
    -- 选中界面ID
	self.mSelIndex = params.selIndex
    -- 保存父结点
    self.parent = params.parent

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 初始化页面控件
	self:initUI()
    -- 刷新界面
    self:refreshUI()
end

function MeetDiaoyuLayer:initUI()
    -- 背景（特效）
    local bgEffect = ui.newEffect({
            zorder = -1,
            parent = self.mParentLayer,
            effectName = "ui_effect_diaoyu",
            position = cc.p(320, 568),
            scale = 0.5,
            loop = true,
        })
    self.fishEffect = bgEffect
    -- 黑色背景层
    local blackLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 200))
    self.mParentLayer:addChild(blackLayer, -1)
    blackLayer:setContentSize(cc.size(640, 1136))
    self.blackLayer = blackLayer
    -- 人物图
    local heroSprite = ui.newSprite("cdjh_55.png")
    heroSprite:setAnchorPoint(cc.p(0.5, 0.5))
    heroSprite:setPosition(460,600)
    self.mParentLayer:addChild(heroSprite)
    self.heroSprite = heroSprite
    -- 文字背景框
    local textBg = ui.newSprite("cdjh_54.png")
    textBg:setPosition(cc.p(260, 850))
    self.mParentLayer:addChild(textBg)
    self.textBg = textBg
    -- 文字
    local textBgSize = textBg:getContentSize()
    local textLabel = ui.newLabel({
            text = TR("老头子我好久没吃鱼了，能帮我钓几条吗？"),
            size = 20,
            outlineColor = cc.c3b(0x0, 0x0, 0x0),
            dimensions = cc.size(textBgSize.width*0.8, 0)
        })
    textBg:addChild(textLabel)
    textLabel:setPosition(textBgSize.width*0.5, textBgSize.height*0.5+10)
    self.textLabel = textLabel
    -- 开始钓鱼
    self.diaoyuBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("开始钓鱼"),
            clickAction = function ()
                self:FishingUI()

                --[[--------新手引导--------]]--
                -- local _, _, eventID = Guide.manager:getGuideInfo()
                -- if eventID == 11005 then
                --     -- 屏蔽界面
                --     Guide.manager:showGuideLayer({})
                --     Guide.manager:nextStep(eventID)
                -- end
            end
        })
    self.diaoyuBtn:setPosition(cc.p(320, 200))
    self.mParentLayer:addChild(self.diaoyuBtn)
    -- 起杆按钮
    self.qiganBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("起杆"),
            clickAction = function ()
                self:requestGetMeetCompare()
            end
        })
    self.qiganBtn:setPosition(cc.p(320, 200))
    self.mParentLayer:addChild(self.qiganBtn)
    -- 领奖按钮
    self.bottomBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("领取奖励"),
            clickAction = function ()
                self.mMeetInfo.IsDone = true
                ui.ShowRewardGoods(self.mMeetInfo.data.BaseGetGameResourceList)
                self:refreshUI()

                --[[--------新手引导--------]]--
                -- local _, _, eventID = Guide.manager:getGuideInfo()
                -- if eventID == 11006 then
                --     -- 不删除引导界面，后续还在此界面引导
                --     Guide.manager:nextStep(eventID)
                --     self:executeGuide()
                -- end
            end
        })
    self.bottomBtn:setPosition(cc.p(320, 200))
    self.mParentLayer:addChild(self.bottomBtn)
end


--[[
	描述：刷新界面
]]
function MeetDiaoyuLayer:refreshUI()
	-- 奇遇完成
    if self.mMeetInfo.IsDone then
        self:meetIsDone()
    -- 钓了鱼但没领取奖励
    elseif self.mMeetInfo.IsFishing then
        self:awardUI()
    -- 钓了鱼没起杆
    elseif self.mMeetInfo.IsFished then
        self:FishedUI()
    -- 还没接受任务
    else
        self:startUI()
    end
end
-- 还没接受任务界面
function MeetDiaoyuLayer:startUI()
    -- 文本框
    if self.textBg ~= nil then
        self.textBg:setPosition(cc.p(260, 850))
    end
    -- 文本
    if self.textLabel ~= nil then
        self.textLabel:setString(TR("老头子我好久没吃鱼了，能帮我钓几条吗？"))
    end
    -- 黑色背景
    self.blackLayer:setVisible(true)
    self.heroSprite:setVisible(true)
    self.textBg:setVisible(true)
    -- 显示钓鱼按钮，隐藏领奖按钮
    self.diaoyuBtn:setVisible(true)
    self.bottomBtn:setVisible(false)
    self.qiganBtn:setVisible(false)
end
-- 正在钓鱼
function MeetDiaoyuLayer:FishingUI()
    -- 黑色背景
    self.blackLayer:setVisible(false)
    self.heroSprite:setVisible(false)
    self.textBg:setVisible(false)
    -- 显示钓鱼按钮，隐藏领奖按钮
    self.diaoyuBtn:setVisible(false)
    self.bottomBtn:setVisible(false)
    self.qiganBtn:setVisible(false)
    -- 屏蔽层
    self.mLockLayer = cc.Layer:create()
    ui.registerSwallowTouch({node = self.mLockLayer})
    display.getRunningScene():addChild(self.mLockLayer, 255)
    -- 随机等待3～5s
    local waitTime = math.random(1, 3)
    -- 显示进度条
    local progressBar = require("common.ProgressBar").new({
        bgImage = "cdjh_34.png",
        barImage = "cdjh_35.png",
        currValue = 0,
        maxValue = waitTime,
        barType = ProgressBarType.eHorizontal,
    })
    progressBar:setAnchorPoint(cc.p(0.5, 0.5))
    progressBar:setPosition(320, 200)
    self.mParentLayer:addChild(progressBar)
    local countTime = 0
    progressBar:scheduleUpdate(function (dt)
        countTime = countTime + 1/60
        if countTime < waitTime then
            progressBar:setCurrValue(countTime)
        else
            self.mMeetInfo.IsFished = true
            self:FishedUI()
            progressBar:unscheduleUpdate()
            progressBar:removeFromParent()
        end
    end)

end
-- 钓到了鱼但没起杆
function MeetDiaoyuLayer:FishedUI()
    -- 播放钓鱼特效
    self.fishEffect:setAnimation(0, "daiji", true)
    -- 去除屏蔽层
    if self.mLockLayer then
        self.mLockLayer:removeFromParent()
        self.mLockLayer = nil
    end
    -- 黑色背景
    self.blackLayer:setVisible(false)
    self.heroSprite:setVisible(false)
    self.textBg:setVisible(false)
    -- 显示钓鱼按钮，隐藏领奖按钮
    self.diaoyuBtn:setVisible(false)
    self.bottomBtn:setVisible(false)
    self.qiganBtn:setVisible(true)

    --[[--------新手引导--------]]--
    -- local _, _, eventID = Guide.manager:getGuideInfo()
    -- if eventID == 110051 then
    --     -- 继续引导点击起杆
    --     self:executeGuide()
    -- end
end
-- 钓了鱼但没领取奖励界面
function MeetDiaoyuLayer:awardUI()
    -- 停止播放钓鱼特效
    self.fishEffect:setAnimation(0, "daiji", false)
    self.fishEffect:setTimePercent(100)
    -- 鱼
    if self.fishBgSprite == nil then
        -- 鱼背景
        self.fishBgSprite = ui.newSprite("cdjh_56.png")
        self.fishBgSprite:setPosition(260, 700)
        self.mParentLayer:addChild(self.fishBgSprite)
        -- 鱼
        local imageName = FishType[self.mMeetInfo.data.ID].res
        if imageName == nil then return end
        local fishBgSize = self.fishBgSprite:getContentSize()
        local fishSprite = ui.newSprite(imageName)
        fishSprite:setPosition(cc.p(fishBgSize.width*0.5, fishBgSize.height*0.5))
        self.fishBgSprite:addChild(fishSprite)
    end
    -- 文本框
    self.textBg:setPosition(260, 850)
    -- 文本
    self.textLabel:setString(TR("呦呦呦，运气不错，钓到珍贵的%s，这些奖励是给你的。", FishType[self.mMeetInfo.data.ID].str))
    -- 奖励
    if self.rewardBg == nil then
        -- 奖励背景
        local rewardBgSize = cc.size(560, 150)
        self.rewardBg = ui.newScale9Sprite("jsxy_04.png", rewardBgSize)
        self.rewardBg:setPosition(320, 320)
        self.mParentLayer:addChild(self.rewardBg)
        -- 奖励
        local rewardList = ui.createCardList({
                maxViewWidth = rewardBgSize.width-50,
                viewHeight = rewardBgSize.height-20,
                allowClick = true,

                cardDataList = self.mMeetInfo.data.BaseGetGameResourceList[1].Goods
            })
        rewardList:setAnchorPoint(cc.p(0.5, 0.5))
        rewardList:setPosition(cc.p(rewardBgSize.width*0.5, rewardBgSize.height*0.5-10))
        self.rewardBg:addChild(rewardList)
    end
    -- 黑色背景
    self.blackLayer:setVisible(true)
    self.heroSprite:setVisible(true)
    self.textBg:setVisible(true)
    -- 显示钓鱼按钮，隐藏领奖按钮
    self.diaoyuBtn:setVisible(false)
    self.bottomBtn:setVisible(true)
    self.qiganBtn:setVisible(false)
end

-- 奇遇结束
function MeetDiaoyuLayer:meetIsDone()
    self.mMeetInfo.IsDone = true
    self.mMeetInfo.redDotSprite:setVisible(false)
    self:awardUI()
    -- 隐藏钓鱼按钮,领奖按钮
    self.diaoyuBtn:setVisible(false)
    self.bottomBtn:setVisible(false)
end

--------------------服务器请求相关-----------------------
function MeetDiaoyuLayer:requestGetMeetCompare()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "QuickExp",
        methodName = "DrawFishingReward",
        svrMethodData = {self.mMeetInfo.Id},
        -- guideInfo = Guide.helper:tryGetGuideSaveInfo(110051),
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            --[[--------新手引导--------]]--
            -- local _, _, eventID = Guide.manager:getGuideInfo()
            -- if eventID == 110051 then
            --     -- 不删除引导界面，后续还在此界面引导
            --     Guide.manager:nextStep(eventID)
            --     self:executeGuide()
            -- end

            -- dump(response.Value)
            -- 设置标记已钓鱼
            self.mMeetInfo.IsFishing = true
            -- 获取服务器数据
            self.mMeetInfo.data = response.Value
            -- 刷新界面
            self:refreshUI()
        end
    })
end

-- ========================== 新手引导 ===========================
function MeetDiaoyuLayer:onEnterTransitionFinish()
    self:executeGuide()
end

-- 执行新手引导
function MeetDiaoyuLayer:executeGuide()
    Guide.helper:executeGuide({
        -- -- 点击钓鱼
        -- [11005] = {clickNode = self.diaoyuBtn, hintPos = cc.p(display.cx, display.cy)},
        -- -- 点击起杆
        -- [110051] = {clickNode = self.qiganBtn, hintPos = cc.p(display.cx, display.cy)},
        -- -- 点击领取奖励
        -- [11006] = {clickNode = self.bottomBtn, hintPos = cc.p(display.cx, display.cy)},
        -- -- 点击返回
        -- [11008] = {clickNode = self.parent.closeBtn},
    })
end

return MeetDiaoyuLayer
