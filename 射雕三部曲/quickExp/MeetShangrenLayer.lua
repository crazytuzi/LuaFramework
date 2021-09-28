--[[
    文件名: MeetShangrenLayer.lua
	描述: 奇遇-云游商人
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

local MeetShangrenLayer = class("MeetShangrenLayer", function()
    return display.newLayer()
end)

function MeetShangrenLayer:ctor(params)
	self.mMeetInfo = params.meetInfo[params.selIndex]
	-- body
	self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    self:requestGetMeetBuy()
	-- 初始化页面控件
	self:initUI()
end

function MeetShangrenLayer:initUI()
	-- 背景图
    local bgSprite = ui.newSprite("cdjh_10.jpg")
    bgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    bgSprite:setPosition(320,568)
    self.mParentLayer:addChild(bgSprite)

    --广告语
    local icon = ui.newSprite("cdjh_12.png")
    icon:setPosition(cc.p(490, 820))
    bgSprite:addChild(icon)
    local advertisementLabel = ui.newLabel({
    	text = TR("走过路过千万不要错过\n      低价甩卖了！"),
    	size = 24,
    	color = Enums.Color.eNormalWhite,
    	outlineColor = Enums.Color.eBlack,
    	})
    advertisementLabel:setPosition(490, 820)
    bgSprite:addChild(advertisementLabel)

    --下方背景
    local size =  cc.size(530, 160)
    local bottomBg = ui.newScale9Sprite("c_65.png", size)
    bottomBg:setPosition(cc.p(320, 220))
    self.mParentLayer:addChild(bottomBg)
    self.mRewardBg = bottomBg

    --购买按钮
    local btn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("购买"),
        clickAction = function(pSender)
           self:touchMeetBuyOp()
        end
    })
    btn:setAnchorPoint(1, 0.5)
    bottomBg:addChild(btn)
    btn:setPosition(cc.p(500, size.height - 40))
    self.mBuyBtn = btn
    self.mBuyBtn:setVisible(false)

    --已领取
    local hadGet = ui.newSprite("jc_21.png")
    hadGet:setAnchorPoint(1, 0.5)
    hadGet:setPosition(cc.p(480 , size.height - 80))
    bottomBg:addChild(hadGet)
    self.mHadGet = hadGet
    self.mHadGet:setVisible(false)

    --原价
    local laibel1 = ui.newLabel({
       text = TR("原价:"),
       color = Enums.Color.eBlack,
       size = 24,
    })
    laibel1:setAnchorPoint(cc.p(0, 0.5))
    laibel1:setPosition(cc.p(185, size.height / 2 + 30))
    self.prePrice = laibel1
    bottomBg:addChild(laibel1)
    --现价
    local laibel2 = ui.newLabel({
        text = TR("现价:"),
        color = Enums.Color.eBlack,
        size = 24,
    })
    laibel2:setAnchorPoint(cc.p(0, 0.5))
    laibel2:setPosition(cc.p(185, size.height / 2 - 30))
    self.curPrice = laibel2
    bottomBg:addChild(laibel2)

    --斜杠标志
    local sp = ui.newSprite("cdjh_14.png")
    sp:setPosition(265, size.height / 2 + 30)
    sp:setScale(1)
    bottomBg:addChild(sp)


    --放弃按钮
    self.mGiveupBtn = ui.newButton({
        normalImage = "c_33.png",
        text = TR("放弃"),
        anchorPoint = cc.p(1, 0.5),
        clickAction = function(pSender)
            self:showSureBox()
        end
    })
    self.mGiveupBtn:setPosition(cc.p(500, size.height - 110))
    bottomBg:addChild(self.mGiveupBtn)
end

--显示2次确认弹窗
function MeetShangrenLayer:showSureBox()
    local function DIYfunc(boxRoot, bgSprite, bgSize)
        self.mSureBox = boxRoot
        --等级要求
        local tipsLabel = ui.newLabel({
            text = TR("是否确定放弃？"),
            size = 24,
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
        tipsLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height / 2))
        bgSprite:addChild(tipsLabel)
        --确定按钮
        local sureBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("确定"),
            clickAction = function()
                LayerManager.removeLayer(self.mSureBox)
                self:requestGiveUpMeet() --放弃奇遇
            end
        })
        sureBtn:setPosition(bgSize.width / 2 + 100, 50)
        bgSprite:addChild(sureBtn)
    end


    local boxSize = cc.size(600, 400)
    LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
            --bgImage = "",
            bgSize = boxSize,   --背景size
            title = TR("提示"),     --标题
            btnInfos = {},      --按钮列表
            DIYUiCallback = DIYfunc,    --DIY回调
            closeBtnInfo = {
                normalImage = "c_33.png",
                 text = TR("取消"),
                position = cc.p(boxSize.width / 2 - 100, 50),
                clickAction = function()
                    LayerManager.removeLayer(self.mSureBox)
                end
            }
        },
    })
end

--刷新UI
function MeetShangrenLayer:refreshUI()
	--刷新奖励卡片
	--创建商品
	local msg = QuickexpMeetBuyModel.items[self.mData.TargetId]
	local tempList = string.splitBySep(msg.outStr, ",")
    local card = CardNode.createCardNode({
        resourceTypeSub = 0 + tempList[1],
        modelId = 0 + tempList[2],
        num = 0 + tempList[3],
        allowClick = true,
    })
    card:setAnchorPoint(0, 0.5)
    card:setPosition(50, self.mRewardBg:getContentSize().height / 2 + 10)
    -- card:setScale(0.9)
    self.mRewardBg:addChild(card)
    --原始价格
    tempList = string.splitBySep(msg.initPriceStr, ",")
    local daibiSp = Utility.getDaibiImage(0 + tempList[1], 0 + tempList[2])
    self.prePrice:setString(TR("原价: {%s}%d", daibiSp, 0 + tempList[3]))
    --当前价格
    tempList = string.splitBySep(msg.useStr, ",")
    daibiSp = Utility.getDaibiImage(0 + tempList[1], 0 + tempList[2])
    self.curPrice:setString(TR("现价: {%s}%d", daibiSp, 0 + tempList[3]))
    self.mBuyBtn:setVisible(true)

    self.mPrice = tonumber(tempList[3])
    --当前奇遇已经为完成
     if self.mMeetInfo.IsGiveUp then
        self:giveUpMeet()
    elseif self.mMeetInfo.IsDone then
    	self:meetIsDone()
    end

   
end

--奇遇完成
function MeetShangrenLayer:meetIsDone()
    self.mMeetInfo.IsDone = true
    self.mMeetInfo.redDotSprite:setVisible(false)
	self.mHadGet:setVisible(true)
	self.mBuyBtn:setEnabled(false)
    self.mBuyBtn:setVisible(false)
    self.mGiveupBtn:setVisible(false)
end

--放弃奇遇
function MeetShangrenLayer:giveUpMeet()
    self.mMeetInfo.IsDone = true
    self.mMeetInfo.IsGiveUp = true
    self.mGiveupBtn:setVisible(false)
    self.mBuyBtn:setVisible(false)
    self.mMeetInfo.redDotSprite:setVisible(false)

    local giveUpSprite = ui.newSprite("cdjh_50.png")
    giveUpSprite:setPosition(cc.p(self.mRewardBg:getContentSize().width - 100, self.mRewardBg:getContentSize().height / 2))
    self.mRewardBg:addChild(giveUpSprite)
end

-------------------服务器请求相关--------------------

--获取奇遇数据
function MeetShangrenLayer:requestGetMeetBuy()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "QuickExp",
        methodName = "GetMeetBuyInfo",
        svrMethodData = {self.mMeetInfo.Id},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mData = response.Value
            --dump(response.Value, "获取商人信息")
            self:refreshUI()
        end
    })
end

--点击购买
function MeetShangrenLayer:touchMeetBuyOp()
    if not Utility.isResourceEnough(ResourcetypeSub.eDiamond, self.mPrice) then
        return
    end
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "QuickExp",
        methodName = "MeetBuyOp",
        svrMethodData = {self.mMeetInfo.Id},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            --dump(response.Value, "获取商人信息")
            -- 奇遇完成
            self:meetIsDone()
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList, true) --显示奖励
        end
    })
end

--放弃奇遇
function MeetShangrenLayer:requestGiveUpMeet()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "QuickExp",
        methodName = "MeetFailure",
        svrMethodData = {self.mMeetInfo.Id},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- 放弃奇遇
            self.mMeetInfo.IsGiveUp = true
            self:giveUpMeet()
        end
    })
end

return MeetShangrenLayer
