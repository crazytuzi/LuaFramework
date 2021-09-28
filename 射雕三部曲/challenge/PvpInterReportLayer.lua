--[[
	文件名：PvpInterReportLayer.lua
	文件描述：浑源之战战报页面
	创建人：chenqiang
	创建时间：2017.07.31
]]

local PvpInterReportLayer = class("PvpInterReportLayer",function()
	return display.newLayer()
end)

-- 文字数字替换
local labelRef = {
    [1] = TR("壹"),
    [2] = TR("贰"),
    [3] = TR("叁"),
    [4] = TR("肆"),
    [5] = TR("伍"),
    [6] = TR("陆"),
    [7] = TR("柒"),
    [8] = TR("捌"),
    [9] = TR("玖"),
}

function PvpInterReportLayer:ctor()
	-- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = self})

    -- 背景大小
    self.mBgSize = cc.size(607, 669)
    self.mViewSize = cc.size(532, 560)
    self.mCellSize = cc.size(532, 125)

    local popBgLayer = require("commonLayer.PopBgLayer").new({
        bgSize = self.mBgSize,
        title = TR("战报"),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(popBgLayer)

    -- 背景对象
    self.mBgSprite = popBgLayer.mBgSprite

	-- 初始化UI
	self:initUI()

	-- 请求战报列表
	self:requsetReportList()
end

-- 初始化UI
function PvpInterReportLayer:initUI()
    -- 背景
    local tempSprite = ui.newScale9Sprite("c_17.png", cc.size(548, 567))
    tempSprite:setAnchorPoint(cc.p(0.5, 0))
    tempSprite:setPosition(self.mBgSize.width * 0.5, 30)
    self.mBgSprite:addChild(tempSprite)

    -- 创建ListView
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setContentSize(self.mViewSize)
    self.mListView:setAnchorPoint(cc.p(0.5, 0))
    self.mListView:setPosition(self.mBgSize.width * 0.5, 32)
    self.mListView:setItemsMargin(15)
    self.mListView:setBounceEnabled(true)
    self.mBgSprite:addChild(self.mListView)

    local nothingSprite = ui.createEmptyHint(TR("暂无战报数据！"))
    nothingSprite:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height * 0.5)
    self.mBgSprite:addChild(nothingSprite)
    self.mNothingSprite = nothingSprite
end

-- 刷新战报列表
function PvpInterReportLayer:refreshListView()
    self.mListView:removeAllChildren()

	for index, item in ipairs(self.mReportData) do
        local cellItem = ccui.Layout:create()
        cellItem:setContentSize(self.mCellSize)
		self.mListView:pushBackCustomItem(cellItem)

        self:refreshListItem(index)
	end
end

-- 刷新列表单个条目
function PvpInterReportLayer:refreshListItem(index)
    local cellItem = self.mListView:getItem(index - 1)
    if not cellItem then
        cellItem = ccui.Layout:create()
        cellItem:setContentSize(self.mCellSize)
        self.mListView:insertCustomItem(cellItem, index - 1)
    end
    cellItem:removeAllChildren()

    -- 条目背景
    local cellBgSprite = ui.newScale9Sprite("c_18.png", self.mCellSize)
    cellBgSprite:setPosition(self.mCellSize.width * 0.5, self.mCellSize.height * 0.5)
    cellItem:addChild(cellBgSprite)

    -- 胜负图标
    local resultSpr = ""
    if self.mReportData[index].IsWin then
        resultSpr = "qxzb_5.png"
    else
        resultSpr = "qxzb_6.png"
    end
    local resultSprite = ui.newSprite(resultSpr)
    resultSprite:setPosition(28, self.mCellSize.height / 2)
    cellItem:addChild(resultSprite)

    -- 名字
    local nameLabel = ui.newLabel({
        text = self.mReportData[index].TargetName,
        color = Utility.getQualityColor(Utility.getQualityByModelId(self.mReportData[index].TargetHeadImageId), 1),
        outlineColor = Enums.Color.eOutlineColor,
        size = 22,
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(60, 95)
    cellItem:addChild(nameLabel)

    local befText = ""
    local aftText = ""
    if self.mReportData[index].BeforeState == 6 then
        befText = TR("%s%d积分", PvpinterStateRelation.items[self.mReportData[index].BeforeState].name, self.mReportData[index].BeforeRate)
    else
        befText = TR("%s%s阶%d星", PvpinterStateRelation.items[self.mReportData[index].BeforeState].name, labelRef[self.mReportData[index].BeforeStep], self.mReportData[index].BeforeStar)
    end
    if self.mReportData[index].AfterState == 6 then
        aftText = TR("%s%d积分", PvpinterStateRelation.items[self.mReportData[index].AfterState].name, self.mReportData[index].AfterRate)
    else
        aftText = TR("%s%s阶%d星", PvpinterStateRelation.items[self.mReportData[index].AfterState].name, labelRef[self.mReportData[index].AfterStep], self.mReportData[index].AfterStar)
    end
    local resultLabel = ui.newLabel({
        text = TR("由   "..befText..TR("\n变为")..aftText),
        size = 20,
        color = Enums.Color.eBlack,
    })
    resultLabel:setAnchorPoint(cc.p(0, 0.5))
    resultLabel:setPosition(60, 50)
    cellItem:addChild(resultLabel)

    -- 头像
    local headCard = CardNode:create({allowClick = false})
    headCard:setHero({ModelId = self.mReportData[index].TargetHeadImageId}, {CardShowAttr.eBorder}, nil, self.mReportData[index].TargetFashionModelId)
    headCard:setPosition(345, self.mCellSize.height / 2)
    cellItem:addChild(headCard)

    local reportBtn = ui.newButton({
        text = TR("战报"),
        normalImage = "c_28.png",
        clickAction = function()
            self:requsetGetFightInfo(self.mReportData[index].FightId, self.mReportData[index], self.mReportData[index])
        end
    })
    reportBtn:setPosition(self.mCellSize.width * 0.87 - 3, self.mCellSize.height / 2)
    cellItem:addChild(reportBtn)
end

-- ======================== 服务器相关 ===========================
-- 请求战报信息
function PvpInterReportLayer:requsetReportList()
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "PVPinter",
        methodName = "GetPVPinterFightLog",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            self.mReportData = response.Value.PVPinterFightLog

            self.mNothingSprite:setVisible(#self.mReportData <= 0)

            self:refreshListView()
        end,
    })
end

-- 查看战报
function PvpInterReportLayer:requsetGetFightInfo(fightID, pvpInterFightLog, targetPlayerInfo)
	local myInfo = PlayerAttrObj:getPlayerInfo()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "PVPinter",
        methodName = "GetFightInfo",
        svrMethodData = {fightID},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- 战斗页面控制信息
    		local controlParams = Utility.getBattleControl(ModuleSub.ePVPInter)
            local fightResult = response.Value.FightInfo or {}
            fightResult.PVPinterFightLog = pvpInterFightLog

            LayerManager.addLayer({
		        name = "ComBattle.BattleLayer",
		        cleanUp = true,
		        data = {
		            data = response.Value.FightInfo,
		            skip = controlParams.skip,
		            trustee = controlParams.trustee,
		            skill = controlParams.skill,
		            map = Utility.getBattleBgFile(ModuleSub.ePVPInter),
		            callback = function(retData)
		                PvpResult.showPvpResultLayer(
                            -- 模块ID
		                    ModuleSub.ePVPInter, 
                            -- 战斗结果
                            fightResult,
                            -- 我的信息
		                    myInfo,
                            -- 敌人信息
		                    targetPlayerInfo
		                )

		                if controlParams.trustee and controlParams.trustee.changeTrusteeState then
		                    controlParams.trustee.changeTrusteeState(retData.trustee)
		                end
		            end
		        },
		    })
        end,
    })
end

return PvpInterReportLayer