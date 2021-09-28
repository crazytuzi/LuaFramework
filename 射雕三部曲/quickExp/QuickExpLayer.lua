--[[
    文件名: QuickExpLayer.lua
	描述: 演武
	创建人: Lichunsheng
	创建时间: 2017.07.10
--]]

local QuickExpLayer = class("QuickExpLayer", function()
    return display.newLayer()
end)

function QuickExpLayer:ctor()
    --屏蔽下层点击
    ui.registerSwallowTouch({node = self})
	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    self.mNametable = {"hero_ouyangke", "hero_jinlunfawang", "hero_yangkang", "hero_hebiweng", "hero_luzhangke", "hero_yinzhiping", "hero_huodu", "hero_zhaozhijing"}
    self.mMusicTable = {"chuangdang_hit01.mp3", "chuangdang_hit02.mp3", "chuangdang_hit03.mp3", "bsxy_fail.mp3"}
    self.mEnemyNodeTable = {}
	self:initData() --初始化页面数据
    self:initUI()   --UI初始化
    self:requestGetInfo() --获取演武数据
end

function QuickExpLayer:onEnter()
end

function QuickExpLayer:onExit()
    if self.mRunMusic then
        MqAudio.stopEffect(self.mRunMusic)
    end
end

function QuickExpLayer:initData()
	LayerData = {
        BoxConfig 		= tempConfig,
        searchNum 		= 0,      	--已经使用次数
        nowNum 			= 0,  		--当前可用次数
        rewardString 	= "",   	--可以领取的次数奖励,次数之间以逗号间隔
        nextRestoreTime = 0, 		--下次数恢复时间
        totalNum 		= 0,  		--最多恢复次数
    }
    self.mAllMeetInfo = {} --当前奇遇信息
    self.mIsOneKey = false -- 是否一键演武
end

--初始化UI
function QuickExpLayer:initUI()
    local lowBgNode = ccui.Widget:create()
    self.mParentLayer:addChild(lowBgNode)
    -- 异步创建每一层背景
    local bgList = {"yw_04.jpg", "yw_03.png", "yw_02.png", "yw_01.png"}
    local lowBgSpriteList = {}
    for i,v in ipairs(bgList) do
        display.loadImage(v, function ()
            --创建背景1
            local topBgSprite1 = ui.newSprite(v)
            topBgSprite1:setAnchorPoint(cc.p(0, 0.5))
            topBgSprite1:setPosition(1920, 568)
            lowBgNode:addChild(topBgSprite1, i)

            local topBgSprite = ui.newSprite(v)
            topBgSprite:setAnchorPoint(cc.p(0, 0.5))
            topBgSprite:setPosition(0, 568)
            lowBgNode:addChild(topBgSprite, i)
            -- 加入缓存
            lowBgSpriteList[i] = {topBgSprite, topBgSprite1}
        end)
    end

    -- 每一层的移动步伐和结束点
    local lowBgFactor = {{pace = 1, endX = 1920}, {pace = 1.5, endX = 1920},
        {pace = 2, endX = 1917}, {pace = 16, endX = 1918}}
    local bgSchedule = Utility.schedule(
        lowBgNode,
        function()
            for i=1,4 do
                if lowBgSpriteList[i] then
                    local factor = lowBgFactor[i]
                    for _,v in ipairs(lowBgSpriteList[i]) do
                        v:setPositionX(v:getPositionX() - factor.pace)
                        if v:getPositionX() <= -1920 then
                            v:setPositionX(factor.endX)
                        end
                    end
                end
            end
        end,
        0
    )

    --透明按钮触摸区域
    local touchBtn = ui.newButton({
        normalImage = "c_83.png",
        size = cc.size(640, 620),
        clickAction = function()
            if LayerData.nowNum > 0 and LayerData.searchNum ~= 30 and self.mIsOneKey == false then
                local random = math.random(1, 4)
                MqAudio.playEffect(self.mMusicTable[random])
            end
            if LayerData.searchNum ~= 30 then
                self:requestSearch()--演武单次
            else
                ui.showFlashView({text = TR("请先领取套圈奖励")})
            end
        end
    })
    touchBtn:setAnchorPoint(cc.p(0, 0))
    touchBtn:setPosition(0, 350)
    self.mParentLayer:addChild(touchBtn)
    -- 保存按钮，引导使用
    self.touchBtn = touchBtn

    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.ePractice,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

    self:createPlayer()		--创建角色
    self:createEnemyTable()
    self:createRecover()	--创建次数恢复信息
    self:createOptBtn()		--创建操作按钮

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
    self.mCloseBtn:setLocalZOrder(5)
    self.mParentLayer:addChild(self.mCloseBtn)
end

--创建玩家角色信息
function QuickExpLayer:createPlayer()
    --玩家英雄模型
    if not self.mRunMusic then
        self.mRunMusic = MqAudio.playEffect("run.mp3", true)
    end
    local playerModelId = FormationObj:getSlotInfoBySlotId(1).ModelId
    local effectName = HeroQimageRelation.items[playerModelId].kongshouPic

    local effectParams = {
        parent = self.mParentLayer,
        zorder = 5,
        effectName = effectName,
        position = cc.p(220, 430),
        scale = 0.18,
        rotationY = 180,
    }
    -- 左手
    self.handEffect2 = ui.newEffect(effectParams)
    self.handEffect2:addAnimation(0, "pao_shou2", true)
    -- 头发
    if effectName ~= "hero_nanzhukongshou" then
        self.mHeorhair = ui.newEffect(effectParams)
        self.mHeorhair:setAnimation(0, "pao_tou2", true)
    end
    -- 身体
    self.heroBody = ui.newEffect(effectParams)
    self.heroBody:setAnimation(0, "pao_xia", true)
    -- 头
    self.mHeorhand = ui.newEffect(effectParams)
    self.mHeorhand:setAnimation(0, "pao_tou", true)
    -- 阴影
    local shadeSprite = ui.newSprite("cdjh_13.png")
    shadeSprite:setPosition(cc.p(200, 420))
    self.mParentLayer:addChild(shadeSprite)
    -- 右手
    self.handEffect = ui.newEffect(effectParams)
    self.handEffect:addAnimation(0, "pao_shou", true)
    -- 右手的攻击动画(初始隐藏)
    self.handAttackEffect = ui.newEffect(effectParams)
    self.handAttackEffect:setVisible(false)
end

--创建5个敌人的table
function QuickExpLayer:createEnemyTable()
    for index, item in ipairs(self.mNametable) do
        ui.newEffect({
            parent = self.mParentLayer,
            zorder = 4,
            effectName = item,
            position = cc.p(800, 450),
            scale = 0.15,
            rotationY = 180,
            endRelease = true,
            async = function(effect)
                table.insert(self.mEnemyNodeTable, effect)
            end
        })
    end

end

--创建次数恢复信息
function QuickExpLayer:createRecover()
    --获取玩家数据
    local playerInfo = PlayerAttrObj:getPlayerInfo()
    --次数和恢复时间背景
    local bgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 360))
    bgSprite:setAnchorPoint(cc.p(0.5, 0))
    bgSprite:setPosition(cc.p(320, 0))
    self.mParentLayer:addChild(bgSprite)

    local LineBgSprite = ui.newScale9Sprite("c_25.png", cc.size(590, 54))
    LineBgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    LineBgSprite:setPosition(cc.p(320, 230))
    self.mParentLayer:addChild(LineBgSprite)

    -- 玩家当前等级
    local lvLabel = ui.newLabel({
        text = TR("等级: "),
        size = 22,
        color = Enums.Color.eBlack,
    })
    lvLabel:setPosition(cc.p(70,  300))
    self.mParentLayer:addChild(lvLabel)

    local lvNumLabel = ui.newLabel({
        text = string.format("%d", playerInfo.Lv),
        size = 22,
        color = cc.c3b(0x24, 0x90, 0x29),
    })
    lvNumLabel:setAnchorPoint(cc.p(0, 0.5))
    lvNumLabel:setPosition(cc.p(100, 300))
    self.mParentLayer:addChild(lvNumLabel)
    self.mLV = lvNumLabel

    --人物经验条
    local expProgressBar = require("common.ProgressBar").new({
        bgImage = "cdjh_34.png",
        barImage = "cdjh_35.png",
        currValue = 0,
        contentSize = cc.size(450, 23),
        maxValue= 100,
        needLabel = true,
        color = Enums.Color.eWhite,
    })
    expProgressBar:setPosition(380, 300)
    self.mHeroEXP = expProgressBar
    self.mParentLayer:addChild(expProgressBar)


    --恢复时间
    local restoreLabel = ui.newLabel({
        text = TR("恢复时间:"),
        size = 24,
        color = cc.c3b(0xff, 0xff, 0xff),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 1,
    })
    restoreLabel:setAnchorPoint(cc.p(0, 0.5))
    restoreLabel:setPosition(50, 27)
    LineBgSprite:addChild(restoreLabel)

    local restoreTimeLabel = ui.newLabel({
        text = string.format("00:00:00"),
        size = 24,
        color = cc.c3b(0xff, 0xe2, 0x89),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 1,
    })
    restoreTimeLabel:setAnchorPoint(cc.p(0, 0.5))
    restoreTimeLabel:setPosition(160, 27)
    LineBgSprite:addChild(restoreTimeLabel)
    self.mRecoverTime = restoreTimeLabel

    --定时更新
    Utility.schedule(restoreTimeLabel, function()
        local lastTime = LayerData.nextRestoreTime - Player:getCurrentTime()
        if lastTime > 0 then
            restoreTimeLabel:setString(MqTime.formatAsHour(lastTime))
        elseif LayerData.nowNum < LayerData.totalNum then
            --重新获取双修信息
            self:requestGetInfo()
        end
    end, 1.0)

    --演武次数
    local tempLabel = ui.newLabel({
        text = TR("闯荡次数:"),
        size = 24,
        color = cc.c3b(0xff, 0xff, 0xff),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 1,
    })
    tempLabel:setAnchorPoint(cc.p(0, 0.5))
    tempLabel:setPosition(350, 27)
    LineBgSprite:addChild(tempLabel)

    local tempTimesLabel = ui.newLabel({
        text = "0",
        size = 24,
        color = cc.c3b(0xff, 0xe2, 0x89),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 1,
    })
    tempTimesLabel:setAnchorPoint(cc.p(0, 0.5))
    tempTimesLabel:setPosition(460, 27)
    self.mYanwuNum = tempTimesLabel
    LineBgSprite:addChild(tempTimesLabel)
end

--开启套圈的弹窗
function QuickExpLayer:openTaoquan()
    MsgBoxLayer.addOKLayer(
        TR("幸运套圈开启,可获得丰厚奖励是否立即前往?"),
        TR("{cdjh_15.png}"),
        {{
            text = TR("立即前往"),
            position = cc.p(420, 60),
            clickAction = function()
                LayerManager.addLayer({
                    name = "quickExp.QuickExpLuckyRingLayer",
                    data = {
                        callBack = self.dealDemonsInfo
                    },
                    cleanUp = true
                })
            end
        }},
        {
            normalImage = "c_33.png",
            text = TR("稍后再说"),
            position = cc.p(160, 60),
        }
    )
end


--创建操作按钮
function QuickExpLayer:createOptBtn()
    --获取玩家vip等级
    local playerVipLv = PlayerAttrObj:getPlayerAttrByName("Vip")
    local playerLv = PlayerAttrObj:getPlayerAttrByName("Lv")
    --一键演武vip等级要求
    local vipLvLimit = ModuleSubModel.items[ModuleSub.eQuickExpOneKey].advancedOpenVIPLv
    local playerLvLimit = ModuleSubModel.items[ModuleSub.eQuickExpOneKey].openLv

    local confirmBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("一键闯荡"),
        position = cc.p(320, 160),
        clickAction = function(pSender)
    		if  ModuleInfoObj:moduleIsOpen(ModuleSub.eQuickExpOneKey, true) then
                    if  LayerData.searchNum >= 30 then
                        self:openTaoquan()
                    elseif LayerData.nowNum <= 0 then
                        self:showGotoBattleBox()
                    else
                        self:requestSearchOneKey()
                    end
            else
                --ui.showFlashView(TR("VIP4级或者等级达到45开始一键闯荡功能"))
            end
        end
    })
    self.mParentLayer:addChild(confirmBtn)
    self.mConfirmBtn = confirmBtn


    local isVip3Label = ui.newLabel({
        text = TR("VIP%d或者等级%d\n  开启一键闯荡", vipLvLimit, playerLvLimit),
        size = 20,
        color = Enums.Color.eBlack,
    })
    isVip3Label:setPosition(470, 155)
    isVip3Label:setLocalZOrder(3)
    isVip3Label:setVisible(playerVipLv < vipLvLimit and playerLv < playerLvLimit)
    self.mParentLayer:addChild(isVip3Label)

    -- 加成
    local attrLabel = ConfigFunc:getMonthAddAttrStr(true)
    if attrLabel then
        attrLabel:setPosition(200, 155)
        self.mParentLayer:addChild(attrLabel)
    end

    --奇遇
    local happyEncounter = ui.newButton({
        normalImage = "tb_38.png",
        position = cc.p(65, 1020),
        clickAction = function(pSender)
              for k, v in ipairs(self.mAllMeetInfo) do
  		        local lastTime = v.EndTime - Player:getCurrentTime()
  		        if (lastTime > 0) and (not v.IsDone) then --判断是否有奇遇没结束
  		            LayerManager.addLayer({name = "quickExp.QuickExpMeetLayer", data = {meetInfo = self.mAllMeetInfo, showMeetId = nil}})
  		            return
  		        end
  		    end
  		    ui.showFlashView(TR("尚未触发奇遇"))
          end
    })
    happyEncounter:setScale(1)
    self.mMeetBtn = happyEncounter
    self.mParentLayer:addChild(happyEncounter)
    -- 保存按钮，引导使用
    self.happyEncounter = happyEncounter

    --奇遇小红点
    local function dealRedDotVisible(redDotSprite)
        local redDotData = RedDotInfoObj:isValid(ModuleSub.eQuickExpMeetMain)
        redDotSprite:setVisible(redDotData)
    end
    ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = RedDotInfoObj:getEvents(ModuleSub.eQuickExpMeetMain), parent = self.mMeetBtn})


    --套圈
    self.mTurnTableBtn = ui.newButton({
    	normalImage = "cdjh_24.png",
    	clickAction = function(pSender)
            if LayerData.searchNum >= 30 then
                LayerManager.addLayer({
                    name = "quickExp.QuickExpLuckyRingLayer",
                    cleanUp = false,
                    data = {
                        callBack = self.dealDemonsInfo
                    },
                    cleanUp = true
                })
            else
                ui.showFlashView(TR("还不能领取套圈奖励"))
            end
    	end
    })
    self.mTurnTableBtn:setPosition(cc.p(160, 1020))
    self.mParentLayer:addChild(self.mTurnTableBtn)
    --背景
    local bg = ui.newScale9Sprite("c_103.png",cc.size(155, 39))
    bg:setPosition(160, 960)
    self.mParentLayer:addChild(bg)

    --数字
	self.mSearchNum = ui.newLabel({
		text = string.format("%d/%d", LayerData.searchNum, 30),
		color = cc.c3b(255, 255, 255),
		size = 20,
	})
	bg:addChild(self.mSearchNum)

	local desSize = self.mSearchNum:getContentSize()
	bg:setContentSize(cc.size(desSize.width + 30, desSize.height + 4))
	local bgSize = bg:getContentSize()
	self.mSearchNum:setPosition(cc.p(bgSize.width / 2, bgSize.height / 2))
end

--处理演武信息
--params:
--[[
    value： 服务器返回的value
--]]
function QuickExpLayer:dealDemonsInfo(value)
    if value.QuickExpMeetInfo then
        LayerData.quickExpMeetInfo = value.QuickExpMeetInfo --获取奇遇数据
    end
    local info = value.QuickExpInfo
    --处理其他数据
    LayerData.searchNum 		= info.SearchNum or LayerData.searchNum--已用次数
    LayerData.nowNum 			= info.NowNum or LayerData.nowNum--可用次数
    LayerData.rewardString 		= info.RewardString or LayerData.rewardString --宝箱奖励
    LayerData.nextRestoreTime 	= info.NextRestoreTime or LayerData.nextRestoreTime --下次恢复时间
    LayerData.totalNum 			= info.TotalNum or LayerData.totalNum --总次数
    --刷新UI
    self:refreshUI()
end

--刷新UI
function QuickExpLayer:refreshUI()
	--次数
    self.mYanwuNum:setString(string.format("%d/%d", LayerData.nowNum, LayerData.totalNum))
    --时间
    local time = LayerData.nextRestoreTime - Player:getCurrentTime()
    if time > 0 then    --有冷却时间
        time = MqTime.formatAsHour(time)
    else
        time = "00:00:00"
    end
    self.mRecoverTime:setString(time)
    --设置等级
    local playerInfo = PlayerAttrObj:getPlayerInfo()
    local currLv = playerInfo.Lv
    self.mLV:setString(string.format("%d", currLv))
    --人物经验条
    local currLvExpTotal, nextLvExpTotal = 0, 100
    if PlayerLvRelation.items[currLv] then
        currLvExpTotal = PlayerLvRelation.items[currLv].EXPTotal
    end
    if PlayerLvRelation.items[currLv + 1] then
        nextLvExpTotal = PlayerLvRelation.items[currLv + 1].EXPTotal
    else
        nextLvExpTotal = currLvExpTotal
    end
    self.mHeroEXP:setMaxValue(nextLvExpTotal - currLvExpTotal)
    self.mHeroEXP:setCurrValue(playerInfo.EXP - currLvExpTotal)
    --演武次数
    self.mSearchNum:setString(string.format("%d/%d", LayerData.searchNum, 30))
    -- 抖动套圈按钮
    if LayerData.searchNum >= 30 then
        ui.setWaveAnimation(self.mTurnTableBtn, 7.5, true, cc.p(40, 45))
    end

    -- 非新手引导添加手指
    local _, _, eventID = Guide.manager:getGuideInfo()
    if not eventID and not self.arrowSprite then
        self.arrowSprite = ui.addGuideArrowEffect(self.mParentLayer, cc.p(380, 568))
    end
end


--检查当前是否能演武
--返回值：true = 能演武  false = 不能
function QuickExpLayer:checkCanQuickExp()
    --正在一键演武
    if self.mIsOneKey then
        return false
    end

    --可领取
    if LayerData.searchNum >= 30  then
        ui.showFlashView({text = TR("请领取奖励")})
        return false
    end

    --没有次数
    if LayerData.nowNum <= 0 then
        self:showGotoBattleBox()
        return false
    end

    -- 背包空间是否充足
    if not Utility.checkBagSpace() then
        return false
    end

    return true
end

--显示跳转到副本
function QuickExpLayer:showGotoBattleBox()
    local function DIYfunc(boxRoot, bgSprite, bgSize)
        --跳转按钮
        local gotoBatttleBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("确定"),
            clickAction = function(pSender, eventType)
                LayerManager.showSubModule(ModuleSub.eBattleNormal, nil, true)
            end
        })
        gotoBatttleBtn:setPosition(cc.p(bgSize.width / 2, 60))
        bgSprite:addChild(gotoBatttleBtn)

        --提示字
        local tips = ui.newLabel({
            text = TR("闯荡次数不足,升级可获得免费次数\n\n          快去副本推图升级吧！"),
            size = 24,
            color = cc.c3b(0x59, 0x28, 0x17),
        })
        bgSprite:addChild(tips)
        tips:setPosition(cc.p(bgSize.width / 2 + 10, bgSize.height / 2 + 35))
        self.mGotoBattleBox = boxRoot
    end

    local boxSize = cc.size(600, 350)
    LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
            bgSize = boxSize,   --背景size
            title = TR("提示"),     --标题
            btnInfos = {},      --按钮列表
            DIYUiCallback = DIYfunc,    --DIY回调
            btnInfos = {},
            closeBtnInfo = {
                normalImage = "c_29.png",
                clickAction = function()
                    self.mGotoBattleBox:removeFromParent()
                end
            }
        },
    })
end

--显示奇遇动作
--[[
    info: 奇遇容器
    isOnekey:是否是一键演武
--]]
function QuickExpLayer:showMeetAction(info, isOnekey)
    if not info or info[1].IsDone == nil then
        return
    end

    if LayerData.searchNum >= 30 then
        ui.setWaveAnimation(self.mTurnTableBtn, 7.5, true, cc.p(40, 45))
    end
    require("quickExp.QuickExpMeetAction"):create({
        meetInfo = info,
        targetPos = cc.p(self.mMeetBtn:getPositionX(), self.mMeetBtn:getPositionY()),
        parent = self,
        callBack = function()
            if LayerData.searchNum >= 30 then
                if not isOnekey then
                    --self:openTaoquan()
                end
            end
        end
    })
end

--显示获得的资源
--[[
    resource:服务器返回资源
--]]
function QuickExpLayer:showReward(resource)
    if self.mDropLayer then
        self.mDropLayer:removeFromParent()
        self.mDropLayer = nil
    end
    local function endCall()
        self.mDropLayer = nil
    end
     ui.ShowRewardGoods(resource.BaseGetGameResourceList)
end


--一键闯荡回调
function QuickExpLayer:OnekeyCallBack(response)

    self.mPreOneKeyNum = LayerData.nowNum
    --新增当前奇遇
    local newMettInfo = response.Value.QuickExpMeetInfo or {}
    for k, v in ipairs(newMettInfo) do
        if v.IsDone ~= nil then
            table.insert(self.mAllMeetInfo, v)
        end
    end
    -- 处理掉落资源
    self:dealDemonsInfo(response.Value)
    --self:showReward(response.Value)

    -- 检查演武次数
    if LayerData.searchNum >= 30 then
        self:openTaoquan()
    end

    -- 检查是否升级
    PlayerAttrObj:showUpdateLayer()
end

--攻击动画
function QuickExpLayer:attackAnimation(response)
    -- 右手隐藏并开启攻击动画
    self.handEffect:setVisible(false)
    self.handAttackEffect:setVisible(true)
    local trackEntry = self.handAttackEffect:setAnimation(0, "pao_gongji", false)

    -- 攻击完成，显示跑步的动画
    self.handAttackEffect:setTrackCompleteListener(trackEntry , function(trackIndex)
        self.handEffect:setVisible(true)
        self.handAttackEffect:setVisible(false)
    end)


    -- 播放刀光特效
    ui.newEffect({
        parent = self.mParentLayer,
        zorder = 5,
        effectName = "hero_nanzhukongshou",
        position = cc.p(130, 480),
        scale = 0.15,
        animation = "daoguang",
        loop = false,
        rotationY = 180,
        endRelease = true,
        endListener = function(effect)
            self:showReward(response.Value)
            --当前有奇遇
            self:showMeetAction(response.Value.QuickExpMeetInfo, false)
            -- 设置为不在演武状态
        end,
    })


    --刷新木头人
    local effNameRand = math.random(1, #self.mEnemyNodeTable)
    local woodMan = self.mEnemyNodeTable[effNameRand]
    local rand = math.random(-1, 2)
    if woodMan then
        woodMan:runAction(cc.Sequence:create(
            cc.MoveTo:create(0.2, cc.p(400, 450)),
            cc.Spawn:create(
                cc.CallFunc:create(function()
                    woodMan:setAnimation(0, "aida", false)
                end),
                cc.MoveTo:create(0.2, cc.p(800, 450 + (rand * 200)))
            ),
            cc.CallFunc:create(function()
                woodMan:setPosition(cc.p(800, 450))
            end)
            )
        )
    end
    self.mIsOneKey = false
end

--------------------服务器请求相关----------------------
function QuickExpLayer:requestGetInfo()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "QuickExp",
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            self.mAllMeetInfo = response.Value.QuickExpMeetInfo or {}  --保存所有奇遇集合
            self:dealDemonsInfo(response.Value)	-- 处理玩家演武信息

            -- 开启引导
            self:executeGuide()
        end,
    })
end

-- 点击演武(单次)
function QuickExpLayer:requestSearch()
    --检查能否演武
    if self:checkCanQuickExp() then
        self.mIsOneKey = true
        -- 发送演武请求
        HttpClient:request({
            svrType = HttpSvrType.eGame,
            moduleName = "QuickExp",
            methodName = "Search",
            svrMethodData = {},
            needWait = false,
            callbackNode = self,
            guideInfo = Guide.helper:tryGetGuideSaveInfo(11003),
            callback = function(response)
                if not response or response.Status ~= 0 then
                    return
                end

                --[[--------新手引导--------]]--
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID == 11003 then
                    Guide.manager:removeGuideLayer()
                    Guide.manager:nextStep(eventID)
                    -- Utility.performWithDelay(self.mParentLayer, function()
                    --     self:executeGuide()
                    -- end, 0.25)
                end

                if response.Value.QuickExpMeetInfo then
                    for k, v in ipairs(response.Value.QuickExpMeetInfo) do
                        if v.IsDone ~= nil then
                            table.insert(self.mAllMeetInfo, v)
                        end
                    end
                end

                -- 处理玩家演武信息
                self:dealDemonsInfo(response.Value)

                if  LayerData.searchNum >= 30 then
                    self:openTaoquan()
                else
                    self:attackAnimation(response)
                end
                --检测升级
                PlayerAttrObj:showUpdateLayer()
            end
        })
    end
end


--一键演武
function QuickExpLayer:requestSearchOneKey()
    --检查能否演武
    if self:checkCanQuickExp() then
        self.mIsOneKey = true
        HttpClient:request({
            svrType = HttpSvrType.eGame,
            moduleName = "QuickExp",
            methodName = "SearchOneKey",
            svrMethodData = {},
            callbackNode = self,
            callback = function(response)
                if not response or response.Status ~= 0 then
                    return
                end

                if LayerData.nowNum > 0 and LayerData.searchNum ~= 30 then
                    local random = math.random(1, 4)
                    MqAudio.playEffect(self.mMusicTable[random])
                end

                local qiyuTable = {}
               if response.Value.QuickExpMeetInfo then
                    for key,value in ipairs(response.Value.QuickExpMeetInfo) do
                        if value.IsDone ~= nil then
                            table.insert(qiyuTable, value)
                        end
                    end
                end
                -- if #qiyuTable > 0 then
                --     self:attackAnimation(response)
                -- end
                self:attackAnimation(response)

                Utility.performWithDelay(self.mParentLayer, function ()
                    self:OnekeyCallBack(response)
                    -- 设置为不在演武状态
                    self.mIsOneKey = false
                end, 1)
            end,
        })
    end

end

-- ========================== 新手引导 ===========================
-- 执行新手引导
function QuickExpLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 点击骰子
        [11003] = {clickNode = self.touchBtn},
        -- -- 点击奇遇
        -- [11004] = {clickNode = self.happyEncounter},
    })
end

return QuickExpLayer
