--[[
    文件名: ActivityInviteLayer.lua
	描述: 邀请奖励页面
	创建人: yanghongsheng
	创建时间: 2018.7.20
--]]

local ActivityInviteLayer = class("ActivityInviteLayer", function()
    return display.newLayer()
end)

--[[
-- 参数 params 中的各项为：
	{
	}
]]
function ActivityInviteLayer:ctor(params)
    -- 邀请数量
    self.mInviteNum = 0
    -- 输入代码奖励
    self.mImportReward = ""
    -- 领取过的奖励列表
    self.mReceivedList = {}

	params = params or {}
	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 

	-- 初始化页面控件
	self:initUI()

    -- 请求服务器数据
    self:requestInfo()
end

-- 初始化页面控件
function ActivityInviteLayer:initUI()
    -- 创建底部导航和顶部玩家信息部分
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

	--背景图
	local bgSprite = ui.newSprite("yq_6.jpg")
    bgSprite:setAnchorPoint(cc.p(0.5, 1))
	bgSprite:setPosition(320, 1136)
	self.mParentLayer:addChild(bgSprite)
    -- 底部背景
    local downSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 815))
    downSprite:setAnchorPoint(cc.p(0.5, 0))
    downSprite:setPosition(320, 0)
    self.mParentLayer:addChild(downSprite)
    
    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 1050),
        clickAction = function(pSender)
            LayerManager.addLayer({
                name = "home.HomeLayer"
            })
        end
    })
    self.mParentLayer:addChild(closeBtn)

    -- 邀请有礼
    local titleSprite = ui.newSprite("yq_4.png")
    titleSprite:setAnchorPoint(cc.p(0, 0.5))
    titleSprite:setPosition(0, 1010)
    self.mParentLayer:addChild(titleSprite)

    -- 通过line
    local hintTempLabel = ui.newLabel({
            text = TR("通过"),
            color = cc.c3b(0x37, 0xff, 0x40),
            outlineColor = Enums.Color.eOutlineColor,
        })
    hintTempLabel:setPosition(90, 920)
    self.mParentLayer:addChild(hintTempLabel)
    -- 邀请的越多，奖励越多
    local hintTempLabel = ui.newLabel({
            text = TR("邀请的朋友越多，获取的奖励越多"),
            color = cc.c3b(0x37, 0xff, 0x40),
            outlineColor = Enums.Color.eOutlineColor,
        })
    hintTempLabel:setAnchorPoint(cc.p(0, 0.5))
    hintTempLabel:setPosition(20, 885)
    self.mParentLayer:addChild(hintTempLabel)

    -- 邀请码背景
    local inviteSprite = ui.newScale9Sprite("yq_5.png", cc.size(495, 46))
    inviteSprite:setAnchorPoint(cc.p(0, 0.5))
    inviteSprite:setPosition(0, 845)
    self.mParentLayer:addChild(inviteSprite)

    local tempLabel = ui.newLabel({
            text = TR("邀请码"),
        })
    tempLabel:setPosition(52, 23)
    inviteSprite:addChild(tempLabel)

    local inviteBg = ui.newScale9Sprite("yq_1.png", cc.size(220, 30))
    inviteBg:setAnchorPoint(cc.p(0, 0.5))
    inviteBg:setPosition(98, 23)
    inviteSprite:addChild(inviteBg)
    -- 邀请码字符
    self.inviteLabel = ui.newLabel({
            text = "",
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
        })
    self.inviteLabel:setAnchorPoint(cc.p(0, 0.5))
    self.inviteLabel:setPosition(10, 15)
    inviteBg:addChild(self.inviteLabel)
    -- 复制按钮
    local copyBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("复制"),
            clickAction = function ()
                if IPlatform:getInstance().copyWords then
                    IPlatform:getInstance():copyWords(self.inviteLabel:getString())
                    ui.showFlashView(TR("复制成功"))
                end
            end,
        })
    copyBtn:setScale(0.8)
    copyBtn:setPosition(370, 23)
    inviteSprite:addChild(copyBtn)
    -- 列表背景
    local listBg = ui.newScale9Sprite("c_17.png", cc.size(610, 495))
    listBg:setPosition(320, 520)
    self.mParentLayer:addChild(listBg)
    -- 列表
    self.mRewardListView = ccui.ListView:create()
    self.mRewardListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mRewardListView:setBounceEnabled(true)
    self.mRewardListView:setContentSize(cc.size(597, 480))
    self.mRewardListView:setItemsMargin(5)
    self.mRewardListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    self.mRewardListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mRewardListView:setPosition(320, 520)
    self.mParentLayer:addChild(self.mRewardListView)
    -- 邀请朋友
    local tempLabel = ui.newLabel({
            text = TR("邀请朋友"),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
    tempLabel:setPosition(118, 234)
    self.mParentLayer:addChild(tempLabel)
    -- 进度条
    local progBg = ui.newScale9Sprite("yq_2.png", cc.size(370, 27))
    progBg:setPosition(368, 234)
    self.mParentLayer:addChild(progBg)

    self.inviteProBar = require("common.ProgressBar").new({
            barImage = "yq_3.png",
            currValue = 0,
            maxValue = 0,
            barType = ProgressBarType.eHorizontal,
            color = Enums.Color.eWhite,
            needLabel = true,
            size = 18,
            outlineColor = cc.c3b(0x46, 0x0d, 0x22),
        })
    self.inviteProBar:setPosition(368, 233)
    self.mParentLayer:addChild(self.inviteProBar)

    -- 邀请按钮
    local inviteBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("邀请"),
            clickAction = function ()
                local shareToLineData = {
                    message = TR("我正在玩《射雕三部曲》，金庸正版授权，正统武侠卡牌！快来和我一起闯荡江湖！{%s}", self.inviteLabel:getString()),
                }
                -- 台湾
                local PartnerTwList = {"9400", "9900", "9903"}
                -- 港澳
                local PartnerHKList = {"9401", "9901", "9902"}

                -- 台湾
                if table.indexof(PartnerTwList, IPlatform:getInstance():getConfigItem("PartnerID")) then
                    shareToLineData = {
                        message = TR("偷偷告訴你金庸正版授權「射鵰三部曲」出手機遊戲啦！遊戲真實還原金庸經典武俠小說「射雕英雄傳」「神鵰俠侶」「倚天屠龍記」！沒時間解釋了，趕緊下載遊戲輸入邀請碼領取豐厚獎品吧！｛%s｝\n遊戲下載地址：https://go.onelink.me/mV8M/line", self.inviteLabel:getString()),
                    }
                -- 港澳
                elseif table.indexof(PartnerHKList, IPlatform:getInstance():getConfigItem("PartnerID")) then
                    shareToLineData = {
                        message = TR("偷偷告訴你金庸正版授權「射鵰三部曲」出手機遊戲啦！遊戲真實還原金庸經典武俠小說「射雕英雄傳」「神鵰俠侶」「倚天屠龍記」！沒時間解釋了，趕緊下載遊戲輸入邀請碼領取豐厚獎品吧！｛%s｝\n遊戲下載地址：https://go.onelink.me/OSto/line", self.inviteLabel:getString()),
                    }
                end

                local jstr = json.encode(shareToLineData)

                IPlatform:getInstance():invoke("ShareToLine", jstr, function() end)
            end,
        })
    inviteBtn:setPosition(175, 160)
    self.mParentLayer:addChild(inviteBtn)

    -- 输入代码
    self.inputBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("输入代码"),
            clickAction = function ()
                local limitLv = 20
                if PlayerAttrObj:getPlayerAttrByName("Lv") < limitLv then
                    ui.showFlashView(TR("需玩家等级达到%s级才能接受邀请", limitLv))
                    return
                end
                self:createInputBox()
            end,
        })
    self.inputBtn:setPosition(472, 160)
    self.mParentLayer:addChild(self.inputBtn)

    -- 提示
    local tempLabel = ui.newLabel({
            text = TR("可获得丰厚奖励"),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
    tempLabel:setPosition(472, 115)
    self.mParentLayer:addChild(tempLabel)
end

function ActivityInviteLayer:createInputBox()
    local function DIYfunc(boxRoot, bgSprite, bgSize)
        -- 提示文字
        local hintLabel = ui.newLabel({
                text = TR("输入邀请码与好友绑定成功后可领取以下奖励："),
                color = cc.c3b(0x46, 0x22, 0x0d),
            })
        hintLabel:setPosition(bgSize.width*0.5, bgSize.height-80)
        bgSprite:addChild(hintLabel)
        -- 输入框
        local editBox = ui.newEditBox({
            image = "c_38.png",
            size = cc.size(350, 56),
            fontSize = 26,
        })
        editBox:setPlaceHolder(TR("请输入邀请码"))
        editBox:setPosition(bgSize.width*0.5, bgSize.height-120)
        bgSprite:addChild(editBox)
        -- 奖励背景
        local rewardBg = ui.newScale9Sprite("c_17.png", cc.size(bgSize.width*0.85, 140))
        rewardBg:setPosition(bgSize.width*0.5, bgSize.height*0.45)
        bgSprite:addChild(rewardBg)
        -- 奖励列表
        local rewardList = Utility.analysisStrResList(self.mImportReward)
        local cardList = ui.createCardList({
                maxViewWidth = bgSize.width*0.8,
                cardDataList = rewardList,
            })
        cardList:setAnchorPoint(cc.p(0.5, 0.5))
        cardList:setPosition(rewardBg:getContentSize().width*0.5, rewardBg:getContentSize().height*0.5)
        rewardBg:addChild(cardList)
        -- 领取奖励
        local getBtn = ui.newButton({
                normalImage = "c_28.png",
                text = TR("领取奖励"),
                clickAction = function ()
                    local inviteText = editBox:getText()

                    if inviteText and string.len(inviteText) > 0 then
                        self:requestCodeReward(inviteText)
                    else
                        ui.showFlashView({text = TR("请输入邀请码")})
                    end

                    LayerManager.removeLayer(boxRoot)
                end
            })
        getBtn:setPosition(bgSize.width*0.5, 70)
        bgSprite:addChild(getBtn)
    end
    -- 创建对话框
    local boxSize = cc.size(600, 420)
    self.showOneKeyMaxLayer = LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
            notNeedBlack = true,
            bgSize = boxSize,
            title = TR("输入代码"),
            btnInfos = {},
            DIYUiCallback = DIYfunc,
            closeBtnInfo = {}
        }
    })
end

function ActivityInviteLayer:createItem(rewardInfo)
    local cellSize = cc.size(self.mRewardListView:getContentSize().width, 130)
    local itemLayout = ccui.Layout:create()
    itemLayout:setContentSize(cellSize)

    local bgSprite = ui.newScale9Sprite("c_18.png", cellSize)
    bgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    bgSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
    itemLayout:addChild(bgSprite)
    -- 描述
    local desLabel = ui.newLabel({
            text = TR("邀请人数"),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
    desLabel:setPosition(74, 76)
    bgSprite:addChild(desLabel)
    -- 人数
    local countLabel = ui.newLabel({
            text = string.format("%d/%d", self.mInviteNum, rewardInfo.inviteTimes),
            color = self.mInviteNum >= rewardInfo.inviteTimes and Enums.Color.eGreen or Enums.Color.eRed,
        })
    countLabel:setPosition(74, 50)
    bgSprite:addChild(countLabel)
    -- 奖励
    local rewardList = Utility.analysisStrResList(rewardInfo.resourceList)
    local cardList = ui.createCardList({
            maxViewWidth = 305,
            cardDataList = rewardList,
        })
    cardList:setAnchorPoint(cc.p(0, 0.5))
    cardList:setPosition(135, cellSize.height*0.5)
    bgSprite:addChild(cardList)

    if self.mReceivedList[rewardInfo.inviteTimes] then
        local getBtn = ui.newButton({
                normalImage = "c_28.png",
                text = TR("已领取"),
                clickAction = function ()
                    self:requestCountReward(rewardInfo.inviteTimes)
                end
            })
        getBtn:setEnabled(false)
        getBtn:setPosition(510, cellSize.height*0.5)
        bgSprite:addChild(getBtn)
    -- 领取
    elseif self.mInviteNum >= rewardInfo.inviteTimes then
        local getBtn = ui.newButton({
                normalImage = "c_28.png",
                text = TR("领取"),
                clickAction = function ()
                    self:requestCountReward(rewardInfo.inviteTimes)
                end
            })
        getBtn:setPosition(510, cellSize.height*0.5)
        bgSprite:addChild(getBtn)

        -- 已领取
        if self.mReceivedList[rewardInfo.inviteTimes] then
            getBtn:setTitleText(TR("已领取"))
            getBtn:setEnabled(false)
        end
    else
        local tempLabel = ui.newLabel({
                text = TR("尚未达成"),
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 27,
            })
        tempLabel:setPosition(510, cellSize.height*0.5)
        bgSprite:addChild(tempLabel)
    end

    return itemLayout
end

function ActivityInviteLayer:refreshListView()
    -- 清空列表
    self.mRewardListView:removeAllChildren()

    local keysList = table.keys(InviteRewardRelation.items)
    table.sort(keysList, function (key1, key2)
        -- 已领取
        if self.mReceivedList[key1] ~= self.mReceivedList[key2] then
            return not self.mReceivedList[key1]
        end
        -- 完成
        if (self.mInviteNum < key1) ~= (self.mInviteNum < key2) then
            return not (self.mInviteNum < key1)
        end

        return key1 < key2
    end)

    for _, key in ipairs(keysList) do
        local item = self:createItem(InviteRewardRelation.items[key])
        self.mRewardListView:pushBackCustomItem(item)
    end
end

function ActivityInviteLayer:refreshUI()
    -- 邀请码显示
    self.inviteLabel:setString(self.mInviteInfo.InviteCode)
    -- 列表
    self:refreshListView()

    -- 进度
     local keysList = table.keys(InviteRewardRelation.items)
    table.sort(keysList, function (key1, key2)
        return key1 < key2
    end)
    local maxValue = 0
    for _, key in ipairs(keysList) do
        maxValue = key
        if maxValue > self.mInviteNum then break end
    end
    self.inviteProBar:setMaxValue(maxValue)
    self.inviteProBar:setCurrValue(self.mInviteNum)

    -- 输入代码按钮是否变灰
    self.inputBtn:setEnabled(not self.mInviteInfo.IfInviteReward)
end

--------------------------网络相关-----------------------------
-- 请求信息
function ActivityInviteLayer:requestInfo()
    HttpClient:request({
        moduleName = "InviteInfo",
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (response)
            if not response.Value or response.Status ~= 0 then
                return
            end

            self.mImportReward = response.Value.ImportRewardList
            self.mInviteInfo = response.Value.InviteInfo
            -- 邀请次数
            self.mInviteNum = response.Value.InviteInfo.InviteNum
            -- 已领取邀请列表
            local receivedList = string.splitBySep(response.Value.InviteInfo.InviteRewardIdStr, ",")
            for _, receivedId in pairs(receivedList) do
                self.mReceivedList[tonumber(receivedId)] = true
            end

            self:refreshUI()
        end
    })
end

-- 领取邀请次数奖励
function ActivityInviteLayer:requestCountReward(num)
    HttpClient:request({
        moduleName = "InviteInfo",
        methodName = "DrawReward",
        svrMethodData = {num},
        callbackNode = self,
        callback = function (response)
            if not response.Value or response.Status ~= 0 then
                return
            end

            -- 显示奖励
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

            self.mInviteInfo = response.Value.InviteInfo
            -- 邀请次数
            self.mInviteNum = response.Value.InviteInfo.InviteNum
            -- 已领取邀请列表
            local receivedList = string.splitBySep(response.Value.InviteInfo.InviteRewardIdStr, ",")
            for _, receivedId in pairs(receivedList) do
                self.mReceivedList[tonumber(receivedId)] = true
            end

            self:refreshUI()
        end
    })
end

-- 领取邀请码奖励
function ActivityInviteLayer:requestCodeReward(inviteStr)
    HttpClient:request({
        moduleName = "InviteInfo",
        methodName = "ImportInviteCode",
        svrMethodData = {inviteStr},
        callbackNode = self,
        callback = function (response)
            if not response.Value or response.Status ~= 0 then
                return
            end

            -- 显示奖励
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

            self.mInviteInfo = response.Value.InviteInfo
            -- 邀请次数
            self.mInviteNum = response.Value.InviteInfo.InviteNum
            -- 已领取邀请列表
            local receivedList = string.splitBySep(response.Value.InviteInfo.InviteRewardIdStr, ",")
            for _, receivedId in pairs(receivedList) do
                self.mReceivedList[tonumber(receivedId)] = true
            end

            self:refreshUI()
        end
    })
end

return ActivityInviteLayer

