--[[
	文件名：ZslyEliteLayer.lua
	描述：丹方界面
	创建人：yanghongsheng
	创建时间： 2017.12.21
--]]

local ZslyEliteLayer = class("ZslyEliteLayer", function(params)
	return display.newLayer()
end)

local FirstRewardReddot = "FirstRewardReddot"

--[[
	params:
		baseInfo  	基础信息
		callback	刷新主界面回调
        eliteId     精英挑战id
]]

function ZslyEliteLayer:ctor(params)
	self.mBaseInfo = params.baseInfo
	self.mCallback = params.callback
	self.mCurEliteId = params.eliteId
	self.mZslyOrderIdList = {}	-- 章节顺序id
	self:dealZslyIdOrder()
	-- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(620, 830),
        title = TR("精英挑战"),
        closeAction = function (layerObj)
            if self.mCallback then
                self.mCallback(self.mBaseInfo, self.mCurEliteId, false)
            end
            LayerManager.removeLayer(layerObj)
        end,
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

	-- 创建页面控件
	self:initUI()

	self:requestInfo()
end

function ZslyEliteLayer:dealZslyIdOrder()
	self.mZslyOrderIdList = {}
	local function dealOrder(floorId)
		if floorId == 0 then return end

		table.insert(self.mZslyOrderIdList, floorId)

		dealOrder(ZslyNodeModel.items[floorId].nextNodeId)
	end

	dealOrder(1001)
end

function ZslyEliteLayer:initUI()
	-- 背景
	local bgSprite = ui.newSprite("zsly_7.png")
	bgSprite:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-60)
	bgSprite:setAnchorPoint(cc.p(0.5, 1))
	self.mBgSprite:addChild(bgSprite)
end

function ZslyEliteLayer:createHeadList()
	if not self.mListBg then
		self.mListBg = ui.newScale9Sprite("c_17.png", cc.size(560, 135))
		self.mListBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-75)
		self.mListBg:setAnchorPoint(cc.p(0.5, 1))
		self.mBgSprite:addChild(self.mListBg)
	end
	self.mListBg:removeAllChildren()

	-- listView
	local listBgSize = self.mListBg:getContentSize()
    local headListView = ccui.ListView:create()
    headListView:setDirection(ccui.ScrollViewDir.horizontal)
    headListView:setBounceEnabled(false)
    headListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    headListView:setAnchorPoint(cc.p(0.5, 0.5))
    headListView:setPosition(listBgSize.width*0.5, listBgSize.height*0.5)
    headListView:setContentSize(listBgSize)
    self.mListBg:addChild(headListView)

    for eliteId, _ in ipairs(ZslyEliteNodeModel.items) do
    	local headItem = self:createHead(eliteId)
    	headListView:pushBackCustomItem(headItem)
    end
    -- 显示当前头像位置
    ui.setListviewItemShow(headListView, self.mCurEliteId-1)
end

function ZslyEliteLayer:isUnLock(eliteId)
	local curIndex = table.indexof(self.mZslyOrderIdList, self.mBaseInfo.CommonCurNodeId)
	local eliteModel = ZslyEliteNodeModel.items[eliteId]
	local eliteIndex = table.indexof(self.mZslyOrderIdList, eliteModel.openCondition)

	return curIndex and curIndex >= eliteIndex or false
end

function ZslyEliteLayer:createHead(eliteId)
	local cellSize = cc.size(110, 135)
	local cellItem = ccui.Layout:create()
	cellItem:setContentSize(cellSize)

	local eliteModel = ZslyEliteNodeModel.items[eliteId]
	local eliteInfo = self.mEliteList[eliteId]

    -- 选择框
	local selectSprite = ui.newSprite("c_31.png")
	selectSprite:setPosition(cellSize.width*0.5, 75)
	selectSprite:setVisible(false)
	cellItem:addChild(selectSprite)
	-- 初始化
	if eliteId == self.mCurEliteId then
		self.mBeforeSelect = selectSprite
		self.mBeforeSelect:setVisible(self:isUnLock(eliteId))
	end
	-- 创建头像
	local headCard = CardNode.createCardNode({
        resourceTypeSub = ResourcetypeSub.eHero,
        modelId = eliteModel.npcModel, 
        cardShowAttrs = {CardShowAttr.eBorder},
        allowClick = true,
        onClickCallback = function ()
        	if self:isUnLock(eliteId) then
        		-- 刷新id
        		self.mCurEliteId = eliteId
        		-- 刷新选择框
        		if self.mBeforeSelect then
        			self.mBeforeSelect:setVisible(false)
        		end
        		self.mBeforeSelect = selectSprite
        		self.mBeforeSelect:setVisible(true)
        		-- 刷新其他ui
        		self:refreshUI()
        	end
        end
    })
    headCard:setPosition(cellSize.width*0.5, 75)
    cellItem:addChild(headCard)

    -- 已解锁
    if self:isUnLock(eliteId) then
    	-- 星星
    	if eliteInfo then
	    	starStr = ""
	    	for i = 1, eliteInfo.StarsNum do
	    		starStr = starStr.."{c_75.png}"
	    	end
	    	local starLabel = ui.newLabel({text = starStr})
	    	starLabel:setAnchorPoint(cc.p(0.5, 0))
            starLabel:setScale(0.8)
	    	starLabel:setPosition(cellSize.width*0.5, 30)
	    	cellItem:addChild(starLabel)
	    end
    -- 未解锁
    else
    	-- 锁
    	local lockSprite = ui.newSprite("zsly_10.png")
    	lockSprite:setPosition(cellSize.width*0.5, 75)
    	cellItem:addChild(lockSprite)
    	-- 开启条件
    	local openLabel = ui.newLabel({
    		text = TR("通关%s开启", ZslyNodeModel.items[eliteModel.openCondition].name),
    		color = Enums.Color.eWhite,
    		outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    		align = ui.TEXT_ALIGN_CENTER,
    		dimensions = cc.size(cellSize.width-10, 0),
    		size = 20,
    	})
    	openLabel:setAnchorPoint(cc.p(0.5, 0.5))
    	openLabel:setPosition(cellSize.width*0.5, 30)
    	cellItem:addChild(openLabel)
    	-- 置灰
    	headCard:setGray(true)
    end

    -- 添加小红点
    local function dealRedDotVisible(redDotSprite)
        redDotSprite:setVisible(self.mEliteList[eliteId] and self.mEliteList[eliteId].IsReceivedFirstReward == false)
    end
    ui.createAutoBubble({parent = cellItem, eventName = FirstRewardReddot..eliteId, refreshFunc = dealRedDotVisible})


	return cellItem
end

function ZslyEliteLayer:refreshUI()
	if not self.mHeroParent then
		self.mHeroParent = cc.Node:create()
		self.mBgSprite:addChild(self.mHeroParent)
	end
	self.mHeroParent:removeAllChildren()

	local eliteModel = ZslyEliteNodeModel.items[self.mCurEliteId]
	local eliteInfo = self.mEliteList[self.mCurEliteId]

	-- 创建人物
    local hero = Figure.newHero({
        heroModelID = eliteModel.npcModel,
        position = cc.p(self.mBgSize.width*0.5-50, 210),
        scale = 0.3,
    })
    self.mHeroParent:addChild(hero)
    -- 名字
    local nameBg = ui.newSprite("zsly_9.png")
    nameBg:setPosition(450, 450)
    self.mHeroParent:addChild(nameBg)

    local nameLabel = ui.newLabel({
            text = HeroModel.items[eliteModel.npcModel].name,
            color = Enums.Color.eWhite,
            size = 20,
            dimensions = cc.size(20, 0),
        })
    nameLabel:setAnchorPoint(cc.p(0.5, 1))
    nameLabel:setPosition(20, nameBg:getContentSize().height-20)
    nameBg:addChild(nameLabel)
    -- 推荐战力
    local fapBg = ui.newSprite("zsly_3.png")
    fapBg:setPosition(450, 580)
    self.mHeroParent:addChild(fapBg)

    local fapSprite = ui.newSprite("zsly_5.png")
    fapSprite:setPosition(30, fapBg:getContentSize().height*0.5)
    fapBg:addChild(fapSprite)

    local fapLabel = ui.newNumberLabel({
            text = Utility.numberFapWithUnit(tonumber(eliteModel.fapNeedShow)),
            imgFile = "jhs_85.png", -- 数字图片名
            charCount = 12, 
        })
    fapLabel:setAnchorPoint(cc.p(0, 0.5))
    fapLabel:setPosition(80, fapBg:getContentSize().height*0.5)
    fapBg:addChild(fapLabel)
    -- 奖励背景
    local rewardBg = ui.newSprite("zsly_8.png")
    rewardBg:setPosition(self.mBgSize.width*0.5, 255)
    self.mHeroParent:addChild(rewardBg)
    -- 首通奖励
    local tempLabel = ui.newLabel({
            text = TR("首通奖励"),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
    tempLabel:setPosition(80, 140)
    rewardBg:addChild(tempLabel)

    local firstRewardList = Utility.analysisStrResList(eliteModel.firstReward)
    for _, rewardInfo in pairs(firstRewardList) do
        rewardInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
    end
    local firstCardList = ui.createCardList({
            maxViewWidth = 300,
            cardDataList = firstRewardList,
            allowClick = true,
        })
    firstCardList:setScale(0.8)
    firstCardList:setPosition(150, 140)
    firstCardList:setAnchorPoint(cc.p(0, 0.5))
    rewardBg:addChild(firstCardList)

    -- 通关奖励
    local tempLabel = ui.newLabel({
            text = TR("通关奖励"),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
    tempLabel:setPosition(80, 60)
    rewardBg:addChild(tempLabel)

    local customRewardList = Utility.analysisStrResList(eliteModel.customReward)
    for _, rewardInfo in pairs(customRewardList) do
        rewardInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
    end
    local customCardList = ui.createCardList({
            maxViewWidth = 300,
            cardDataList = customRewardList,
            allowClick = true,
        })
    customCardList:setScale(0.8)
    customCardList:setPosition(150, 60)
    customCardList:setAnchorPoint(cc.p(0, 0.5))
    rewardBg:addChild(customCardList)

    -- 领取首通按钮
    local getFirstBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("领取"),
            clickAction = function ()
                self:requestFirstReward()
            end,
        })
    getFirstBtn:setPosition(470, 140)
    getFirstBtn:setScale(0.8)
    rewardBg:addChild(getFirstBtn)
    -- 不能领取
    if not eliteInfo then
        getFirstBtn:setEnabled(false)
    elseif eliteInfo.IsReceivedFirstReward then
        getFirstBtn:setEnabled(false)
        getFirstBtn:setTitleText(TR("已领取"))
    end

    -- 扫荡按钮
    local sweepBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("扫荡"),
        clickAction = function ()
            if self.mBaseInfo.EliteFightNum < 1 then
                ui.showFlashView(TR("挑战次数不足"))
                return
            end
            self:requestSweep()
        end,
    })
    sweepBtn:setPosition(195, 95)
    self.mHeroParent:addChild(sweepBtn)
    -- 不能扫荡
    if not eliteInfo or eliteInfo.StarsNum < 3 then
        sweepBtn:setEnabled(false)
        -- 三星通关开启
        local tempLabel = ui.newLabel({
            text = TR("三星通关开启"),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
        })
        tempLabel:setPosition(195, 45)
        self.mHeroParent:addChild(tempLabel)
    end

    -- 挑战按钮
    local challengeBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("挑战"),
        clickAction = function ()
            if self.mBaseInfo.EliteFightNum < 1 then
                ui.showFlashView(TR("挑战次数不足"))
                return
            end
            self:requestFight()
        end,
    })
    challengeBtn:setPosition(430, 95)
    self.mHeroParent:addChild(challengeBtn)
    -- 是否不能挑战
    challengeBtn:setEnabled(self:isUnLock(self.mCurEliteId))

    -- 挑战次数
    local fightNumLabel = ui.newLabel({
            text = TR("剩余次数 %s 次", self.mBaseInfo.EliteFightNum),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
        })
    fightNumLabel:setPosition(430, 45)
    self.mHeroParent:addChild(fightNumLabel)

    -- 购买按钮
    local buyBtn = ui.newButton({
            normalImage = "c_21.png",
            clickAction = function ()
                if self.mBaseInfo.TodayBuyEliteFightNum >= ZslyEliteFightnumBuyModel.items_count then
                    ui.showFlashView(TR("今日次数购买已达上限"))
                    return
                end
                MsgBoxLayer.buyZslyCountHintLayer(self.mBaseInfo.TodayBuyEliteFightNum, ZslyEliteFightnumBuyModel.items_count, function (buyCount)
                    self:requestBuyNum(buyCount)
                end)
            end
        })
    buyBtn:setPosition(530, 45)
    self.mHeroParent:addChild(buyBtn)

    -- 更新
    if self.mCallback then
        self.mCallback(self.mBaseInfo, self.mCurEliteId, true)
    end
end

--=========================服务器相关============================
-- 初始信息
function ZslyEliteLayer:requestInfo()
    HttpClient:request({
        moduleName = "ZslyInfo",
        methodName = "GetEliteNodeInfo",
        svrMethodData = {prescriptionId, num},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end

            self.mEliteList = {}
            for _, eliteInfo in pairs(response.Value.EliteList) do
            	self.mEliteList[eliteInfo.EliteNodeId] = eliteInfo
            end
            -- 初始化当前关卡
            if not self.mCurEliteId then
                for _, eliteModel in ipairs(ZslyEliteNodeModel.items) do
                    if self.mEliteList[eliteModel.modelId] and self.mEliteList[eliteModel.modelId].StarsNum >= 3 then
                        self.mCurEliteId = eliteModel.modelId
                    end
                end
                self.mCurEliteId = self.mCurEliteId or 1
            end

            self:createHeadList()

            self:refreshUI()
        end
    })
end

-- 首通奖励
function ZslyEliteLayer:requestFirstReward()
    HttpClient:request({
        moduleName = "ZslyInfo",
        methodName = "ReceiveEliteNodeFirstReward",
        svrMethodData = {self.mCurEliteId},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end

            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

            self.mEliteList[response.Value.EliteNode.EliteNodeId] = response.Value.EliteNode

            self:refreshUI()

            Notification:postNotification(FirstRewardReddot..self.mCurEliteId)
        end
    })
end

-- 扫荡
function ZslyEliteLayer:requestSweep()
    HttpClient:request({
        moduleName = "ZslyInfo",
        methodName = "SweepEliteNode",
        svrMethodData = {self.mCurEliteId},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end

            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

            self.mBaseInfo = response.Value.BaseInfo
            
            self:refreshUI()

            if self.mCallback then
                self.mCallback(self.mBaseInfo, self.mCurEliteId, true)
            end
        end
    })
end

-- 挑战
function ZslyEliteLayer:requestFight()
    HttpClient:request({
        moduleName = "ZslyInfo",
        methodName = "GetEliteNodeFightInfo",
        svrMethodData = {self.mCurEliteId},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            local nodeId = self.mCurEliteId
            local eliteInfo = self.mEliteList[nodeId] or {}
            local starNum = eliteInfo.StarsNum or 0
            -- 战斗页面控制信息
            local controlParams = Utility.getBattleControl(ModuleSub.eZhenshouLaoyu, starNum > 0)
            local battleLayer = LayerManager.addLayer({
                name = "ComBattle.BattleLayer",
                data = {
                    data = response.Value.FightInfo,
                    skip = controlParams.skip,
                    trustee = controlParams.trustee,
                    skill = controlParams.skill,
                    callback = function(retData)
                        --本地战斗完成,进行校验
                        CheckPve.ZslyElite(retData, nodeId)
                        if controlParams.trustee and controlParams.trustee.changeTrusteeState then
                            controlParams.trustee.changeTrusteeState(retData.trustee)
                        end
                    end
                },
            })
        end
    })
end

-- 购买次数
function ZslyEliteLayer:requestBuyNum(num)
    HttpClient:request({
        moduleName = "ZslyInfo",
        methodName = "PurchaseEliteNodeFightNum",
        svrMethodData = {num},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end

            self.mBaseInfo = response.Value.BaseInfo
            
            self:refreshUI()

            if self.mCallback then
                self.mCallback(self.mBaseInfo, self.mCurEliteId, true)
            end
        end
    })
end

return ZslyEliteLayer