--[[
    文件名: MeetQiecuoLayer.lua
	描述: 奇遇-切磋武功
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

local MeetQiechuoLayer = class("MeetQiechuoLayer", function()
    return display.newLayer()
end)

function MeetQiechuoLayer:ctor(params)
	self.mMeetInfo = params.meetInfo[params.selIndex]
    
	-- body
	self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 
    self:requestGetMeetChallege() --请求数据


	-- 初始化页面控件
	self:initUI()
end

function MeetQiechuoLayer:initUI()
	-- 背景图
    local bgSprite = ui.newSprite("cdjh_39.jpg")
    bgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    bgSprite:setPosition(320,568)
    self.mParentLayer:addChild(bgSprite)

    --下方背景
    local size =  cc.size(640, 402)
    local bottomBg = ui.newScale9Sprite("c_19.png", size)
    bottomBg:setAnchorPoint(0.5, 0)
    bottomBg:setPosition(cc.p(320, 0))
    bgSprite:addChild(bottomBg)
    -- local bgLine = ui.newSprite("c_131.png")
    -- bgLine:setPosition(bottomBg:getContentSize().width / 2, 210)
    -- bottomBg:addChild(bgLine)

    -- 下方灰色背景
    local rewardBg = ui.newScale9Sprite("c_17.png", cc.size(614, 182))
    rewardBg:setPosition(cc.p(320, 217))
    bottomBg:addChild(rewardBg)
    self.mRewardBg = rewardBg
    --白色背景
   	local rewardBgSprite = ui.newScale9Sprite("c_54.png", cc.size(596, 170)) 
   	rewardBgSprite:setPosition(cc.p(320, 217))
   	bottomBg:addChild(rewardBgSprite)	

    --战斗奖励
    local rewardIcon = ui.newLabel({
        text = TR("#faf6f1战斗奖励:"),
        color = Enums.Color.eWhite,
        outlineColor = Enums.Color.eBrown,
        size = 24,
    })
    -- rewardIcon:setAnchorPoint(cc.p(0, 0.5))
    rewardIcon:setPosition(cc.p(320, 280))
    bottomBg:addChild(rewardIcon)

    --挑战按钮
    local btn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("挑战"),
        clickAudio = "sound_dianjikaizhan.mp3",
        clickAction = function(pSender)
            --体力判断
            if Utility.isResourceEnough(ResourcetypeSub.eVIT, QuickexpConfig.items[1].meetChallengeUse, true) then
                self:requestGetMeetChallegeFight()
            end
        end
    })
    bottomBg:addChild(btn)
    btn:setPosition(cc.p(size.width - btn:getContentSize().width / 2 - 50, 210))
    self.mChallengeBtn = btn
    self.mChallengeBtn:setVisible(false)

    --消耗体力
    local use = ui.newLabel({
        text = TR("消耗体力:{%s}5",Utility.getDaibiImage(ResourcetypeSub.eVIT)),
        color = Enums.Color.eBlack,
        size = 19,
    })
    use:setPosition(cc.p(size.width - btn:getContentSize().width / 2 - 50, 125 + btn:getBoundingBox().height / 2 + 12))
    bottomBg:addChild(use)

    --已领取
    local hadGet = ui.newSprite("jc_21.png")
    hadGet:setPosition(cc.p(size.width - btn:getContentSize().width / 2 - 50, 210))
    bottomBg:addChild(hadGet)
    self.mHadGet = hadGet
    self.mHadGet:setVisible(false)

    --描述文字
    local describe = ui.newLabel({
        text = TR("测试文字"),
        size = 22,
        -- color = cc.c3b(255, 255, 255),
        -- outlineColor = Enums.Color.eBlue,
        dimensions = cc.size(600, 50)
    })
    describe:setAnchorPoint(cc.p(0, 1))
    bottomBg:addChild(describe)
    describe:setPosition(cc.p(25, bottomBg:getContentSize().height - 40))
    self.mDescribe = describe

    --奖励列表
    local listViewSize = cc.size(430, 120)
    local listView = ccui.ListView:create()
    listView:setItemsMargin(2)
    listView:setDirection(ccui.ScrollViewDir.horizontal)
    listView:setBounceEnabled(true)
    listView:setGravity(ccui.ListViewGravity.centerVertical)
    listView:setContentSize(listViewSize)
    listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    listView:setAnchorPoint(cc.p(0.5, 0.5))
    listView:setPosition(cc.p(bottomBg:getContentSize().width / 2 - 80, 210))
    self.mListView = listView
    bottomBg:addChild(listView)

    --血量进度条
    local hpBar = require("common.ProgressBar").new({
        bgImage = "zr_14.png",
        barImage = "zr_15.png",
        currValue = 0,
        needLabel = true,
        maxValue = 100,
        size = 18,
        color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack,
        barType = ProgressBarType.eHorizontal,
    })
    hpBar:setPosition(320, 435)
    self.mParentLayer:addChild(hpBar)
 	self.mHpBar = hpBar
end

--刷新UI
function MeetQiechuoLayer:refreshUI()
    local info = QuickexpMeetChallengeModel.items[self.mData.TargetId]
    local reward = Utility.analysisStrResList(info.outStr)

    for k, v in ipairs(reward) do
        self:createListItem(v)
    end

    --创建主宰
    local heroView = Figure.newHero({
        heroModelID = info.heroModelId,
        parent = self.mParentLayer,
        scale = 0.32,
    })
    heroView:setAnchorPoint(cc.p(0.5, 0))
    heroView:setPosition(cc.p(320, 500))
    --刷新提示文字
    local heroName = HeroModel.items[info.heroModelId].name
    self.mDescribe:setString(TR("#46220d居然遇到#d17b00%s#46220d，机会难得，快来和他切磋一下，在实战中提升自己的实力！",heroName))
    --刷新进度条
    self.mHpBar:setMaxValue(self.mData.TotalHP)
    self.mHpBar:setCurrValue(self.mData.CurHP)

    self.mChallengeBtn:setVisible(true)
    --奇遇完成
    if self.mMeetInfo.IsDone then
        self:meetIsDone()
    end
end

--创建列表单个奖励
function MeetQiechuoLayer:createListItem(item)
    local size = cc.size(110, 115)
    local lvItem = ccui.Layout:create()
    lvItem:setContentSize(size)
    self.mListView:pushBackCustomItem(lvItem)

    --创建卡片
    local card = CardNode.createCardNode({
        resourceTypeSub = item.resourceTypeSub,
        modelId = item.modelId,
        num = item.num,
        allowClick = true,
    })
    card:setPosition(size.width / 2, size.height / 2 + 3)
    card:setScale(0.85)
    lvItem:addChild(card)
end

--奇遇结束
function MeetQiechuoLayer:meetIsDone()
    --显示奖励
    -- if self.mMeetInfo.BaseGetGameResourceList then
    --     ui.ShowRewardGoods(self.mMeetInfo.BaseGetGameResourceList, true) --显示奖励
    --     self.mMeetInfo.BaseGetGameResourceList = nil
    -- end
    --隐藏挑战按钮
    self.mChallengeBtn:setVisible(false)
    --显示已经完成标志
    self.mHadGet:setVisible(true)
    --标记猎魔完成
    self.mMeetInfo.IsDone = true
    self.mMeetInfo.redDotSprite:setVisible(false)
    --隐藏时间
    -- self.mMeetInfo.meetMsg.timeLabel:setVisible(false)
end

-------------------服务器请求相关--------------------

--获取当前挑战信息
function MeetQiechuoLayer:requestGetMeetChallege()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "QuickExp",
        methodName = "GetMeetChallegeInfo",
        svrMethodData = {self.mMeetInfo.Id},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mData = response.Value
            dump(self.mData)
            self:refreshUI()
        end
    })
end

--点击挑战
function MeetQiechuoLayer:requestGetMeetChallegeFight()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "QuickExp",
        methodName = "GetMeetChallegeFightInfo",
        svrMethodData = {self.mMeetInfo.Id},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- 战斗页面控制信息
            local controlParams = Utility.getBattleControl(ModuleSub.eQuickExpMeetChallenge)
            local id = self.mMeetInfo.Id
            local meetInfo = self.mMeetInfo
            local battleLayer = LayerManager.addLayer({
                name = "ComBattle.BattleLayer",
                data = {
                    data = response.Value.FightInfo,
                    skip = controlParams.skip,
                    trustee = controlParams.trustee,
                    skill = controlParams.skill,
                    map = Utility.getBattleBgFile(ModuleSub.eQuickExpMeetChallenge),
                    callback = function(retData)
                        CheckPve.QuickexpMeetChallenge(id, retData)
                        
                        if controlParams.trustee and controlParams.trustee.changeTrusteeState then
                            controlParams.trustee.changeTrusteeState(retData.trustee)
                        end
                    end
                },
            })
        end
    })
end

return MeetQiechuoLayer