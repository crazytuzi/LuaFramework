--[[
    文件名: jianghuKillReportLayer.lua
    描述: 江湖杀密信页面
    创建人: yanghongsheng
    创建时间: 2018.09.20
-- ]]
local jianghuKillReportLayer = class("jianghuKillReportLayer", function(params)
	return display.newLayer()
end)

local ReportType = {
    eAttack = 1,
    eDefense = 2,
}

--[[
	params:
]]
function jianghuKillReportLayer:ctor(params)
    -- 战报数据列表
    self.mReportInfoList = {}
	-- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
    	bgSize = cc.size(620, 600),
    	title = TR("战报"),
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

	self:initUI()

    self:requestInfo()
end

function jianghuKillReportLayer:initUI()
	-- 黑背景
    local blackSize = cc.size(self.mBgSize.width-50, self.mBgSize.height-240)
    local blackBg = ui.newScale9Sprite("c_17.png", blackSize)
    blackBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-130)
    blackBg:setAnchorPoint(cc.p(0.5, 1))
    self.mBgSprite:addChild(blackBg)

    -- 确定按钮
    local closeBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("确定"),
            clickAction = function ()
                LayerManager.removeLayer(self)
            end
        })
    closeBtn:setPosition(self.mBgSize.width*0.5, 60)
    self.mBgSprite:addChild(closeBtn)

    -- 列表
    self.mReportListView = ccui.ListView:create()
    self.mReportListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mReportListView:setBounceEnabled(true)
    self.mReportListView:setContentSize(cc.size(blackSize.width-40, blackSize.height-20))
    self.mReportListView:setItemsMargin(5)
    self.mReportListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mReportListView:setPosition(blackSize.width*0.5, blackSize.height*0.5)
    blackBg:addChild(self.mReportListView)

    -- 创建空提示
    self.emptyHint = ui.createEmptyHint(TR("暂无战报"))
    self.emptyHint:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.5)
    self.mBgSprite:addChild(self.emptyHint)
    self.emptyHint:setVisible(false)
end

-- 请求服务器
function jianghuKillReportLayer:createTabView()
    local tabInfoList = {
        {
            text = TR("进攻"),
            tag = ReportType.eAttack,
        },
        {
            text = TR("防守"),
            tag = ReportType.eDefense,
        }
    }
    local tabView = ui.newTabLayer({
            btnInfos = tabInfoList,
            isVert = false,
            needLine = false,
            allowChangeCallback = function(btnTag)
                return true
            end,
            onSelectChange = function(selectBtnTag)
                self:refreshList(selectBtnTag)
            end
        })
    tabView:setAnchorPoint(cc.p(0, 0))
    tabView:setPosition(12, self.mBgSize.height-140)
    self.mBgSprite:addChild(tabView)
end

function jianghuKillReportLayer:refreshList(tag)
    self.mReportListView:removeAllChildren()
    self.emptyHint:setVisible(false)

    if self.mReportInfoList[tag] and next(self.mReportInfoList[tag]) then
        for _, reportInfo in ipairs(self.mReportInfoList[tag] or {}) do
            local labelWidth = self.mReportListView:getContentSize().width
            local cellItem = ccui.Layout:create()

            -- 战报文字
            local descText = ""
            local winAddNum = JianghukillModel.items[1].winAdd / 100
            if reportInfo.IsAttackPlayer then   -- 进攻
                local baseHonorCoin = reportInfo.IsAttackSuccess and JianghukillModel.items[1].challengeSuccessReward or JianghukillModel.items[1].challengeFailReward
                descText = TR("{c_80.png}  您对#60d8ff%s#F7F5F0发起了挑战，挑战%s，荣誉点#ffe748+%d", reportInfo.TargetPlayerName,
                    reportInfo.IsAttackSuccess and TR("成功") or TR("失败"), reportInfo.AttackHonorCoin)
            else                                -- 防守
                local isSpritEmpty = reportInfo.DefendPlayerSpritNum <= 0
                local baseHonorCoin = (not reportInfo.IsAttackSuccess) and JianghukillModel.items[1].challengeSuccessReward or JianghukillModel.items[1].challengeFailReward
                local useSpritNum = math.floor(reportInfo.DefendHonorCoin / baseHonorCoin)
                dump(reportInfo)
                local defStr = (not reportInfo.IsAttackSuccess) and TR("防守成功，精神-%d", useSpritNum) or TR("防守失败，精神-%d", useSpritNum)
                if isSpritEmpty then
                    defStr = TR("精神耗尽，返回总部")
                end
                descText = TR("{c_80.png}  #ff7200%s#F7F5F0对您发起了挑战，%s，荣誉点#ffe748+%d", reportInfo.TargetPlayerName,
                    defStr, reportInfo.DefendHonorCoin)
            end
            local descLabel = ui.newLabel({
                    text = descText,
                    color = Enums.Color.eWhite,
                    outlineColor = cc.c3b(0x46, 0x22, 0x0d),
                    dimensions = cc.size(labelWidth-20, 0),
                })
            descLabel:setPosition(0, descLabel:getContentSize().height)
            descLabel:setAnchorPoint(cc.p(0, 1))
            cellItem:addChild(descLabel)

            cellItem:setContentSize(labelWidth, descLabel:getContentSize().height)

            self.mReportListView:pushBackCustomItem(cellItem)
        end
    else
        self.emptyHint:setVisible(true)
    end
end

--==============================网络相关======================
-- 请求服务器
function jianghuKillReportLayer:requestInfo()
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Jianghukill",
        methodName = "GetFightInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- dump(response.Value)

            for _, reportInfo in pairs(response.Value.FightInfo) do
                if reportInfo.IsAttackPlayer then
                    self.mReportInfoList[ReportType.eAttack] = self.mReportInfoList[ReportType.eAttack] or {}
                    table.insert(self.mReportInfoList[ReportType.eAttack], reportInfo)
                else
                    self.mReportInfoList[ReportType.eDefense] = self.mReportInfoList[ReportType.eDefense] or {}
                    table.insert(self.mReportInfoList[ReportType.eDefense], reportInfo)
                end
            end
            -- 排序
            for _, reportInfoList in pairs(self.mReportInfoList) do
                table.sort(reportInfoList, function(reportInfo1, reportInfo2)
                    return reportInfo1.UpdateTime > reportInfo2.UpdateTime
                end)
            end
            -- 创建tabview
            self:createTabView()
        end,
    })
end

return jianghuKillReportLayer