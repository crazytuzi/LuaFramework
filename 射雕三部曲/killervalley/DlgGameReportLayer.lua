--[[
	文件名：DlgGameReportLayer.lua
	描述：绝情谷每局战斗的战报界面
	创建人：peiyaoqiang
	创建时间：2018.1.25
--]]

local DlgGameReportLayer = class("DlgGameReportLayer", function(params)
	return display.newLayer()
end)

function DlgGameReportLayer:ctor(params)
    --dump(params, "params")
    -- 战报数据
    self.reportInfo = params or {}
    -- 初始化数据
    self.reportList = self.reportInfo.FightReportBrief or {}
    
    -- 创建背景框
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("战报"),
        bgSize = cc.size(600, 570),
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)

    self.mBgLayer = bgLayer.mBgSprite
    self.mBgSize = self.mBgLayer:getContentSize()

    -- 初始化UI
    self:initUI()
end

-- 刷新显示
function DlgGameReportLayer:initUI()
    -- 列表背景
    local listBgSize = cc.size(self.mBgSize.width - 60, self.mBgSize.height - 200)
    local listBgSprite = ui.newScale9Sprite("c_17.png", listBgSize)
    listBgSprite:setAnchorPoint(cc.p(0.5, 0))
    listBgSprite:setPosition(self.mBgSize.width * 0.5, 130)
    self.mBgLayer:addChild(listBgSprite)

    -- 排名列表
    local mListView = ccui.ListView:create()
    mListView:setDirection(ccui.ScrollViewDir.vertical)
    mListView:setBounceEnabled(true)
    mListView:setContentSize(cc.size(listBgSize.width - 10,listBgSize.height - 10))
    mListView:setPosition(5, 5)
    listBgSprite:addChild(mListView)

    -- 显示所有战报
    local cellSize = cc.size(listBgSize.width - 10, 120)
    if next(self.reportList) then
        for i,v in ipairs(self.reportList) do
            local lvItem = ccui.Layout:create()
            lvItem:setContentSize(cellSize)
            mListView:pushBackCustomItem(lvItem)

            v.FightInfo = self.reportInfo.FightReport[i].FightInfo
            self:createRerportCell(lvItem, cellSize, v)
        end
    else
        local emptyHint = ui.createEmptyHint(TR("暂无战报"))
        emptyHint:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height*0.5+100)
        self.mBgLayer:addChild(emptyHint)
    end

    -- 显示玩家的死亡原因
    local dieBgSize = cc.size(self.mBgSize.width - 60, 90)
    local dieBgSprite = ui.newScale9Sprite("c_17.png", dieBgSize)
    dieBgSprite:setAnchorPoint(cc.p(0.5, 0))
    dieBgSprite:setPosition(self.mBgSize.width * 0.5, 30)
    self.mBgLayer:addChild(dieBgSprite)

    -- 这个原因根据实际情况修改key
    local dieReasonList = {
        -- 毒圈
        TR("因为%s情花瘴%s太过强烈，不得不退出绝情谷。", Enums.Color.eRedH, Enums.Color.eNormalWhiteH),
        -- 被人点死
        TR("您被%s偷袭%s，身受重伤，不得不退出绝情谷。", Enums.Color.eRedH, Enums.Color.eNormalWhiteH),
        -- 陷阱
        TR("您不幸踩到了%s情花刺%s，中了情花之毒，不得不退出绝情谷。", Enums.Color.eRedH, Enums.Color.eNormalWhiteH),
        -- 飞刀
        TR("您被%s飞刀%s命中，身受重伤，不得不退出绝情谷。", Enums.Color.eRedH, Enums.Color.eNormalWhiteH),
        -- 冰魄银针
        TR("您被%s冰魄银针%s命中，身中剧毒，不得不退出绝情谷。", Enums.Color.eRedH, Enums.Color.eNormalWhiteH),
    }
    local dieLabel = ui.newLabel({
        text = self.reportInfo.isWin and TR("恭喜你击败所有玩家获得第一名") or dieReasonList[self.reportInfo.DeadEnum] or "",
        size = 22,
        anchorPoint = cc.p(0.5, 0.5),
        color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eOutlineColor,
        align = cc.TEXT_ALIGNMENT_CENTER,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        dimensions = cc.size(dieBgSize.width - 60, dieBgSize.height),
    })
    dieLabel:setPosition(dieBgSize.width / 2, dieBgSize.height / 2)
    dieBgSprite:addChild(dieLabel)
end

----------------------------------------------------------------------------------------------------

-- 创建一行排名cell
function DlgGameReportLayer:createRerportCell(parent, size, item)
    if (item == nil) then
        return
    end
    
    -- 显示背景
    local cellBgSize = cc.size(size.width - 6, size.height - 5)
    local cellBgSprite = ui.newScale9Sprite("c_18.png", cellBgSize)
    cellBgSprite:setPosition(size.width / 2, size.height / 2)
    parent:addChild(cellBgSprite)

    -- 描述
    local descLabel = ui.newLabel({
            text = TR("%s%s%s对%s%s%s发起了挑战，%s%s%s胜利了",
                "#ff99fe",
                item.AttackName,
                Enums.Color.eWhiteH,
                "#ff99fe",
                item.TargetName,
                Enums.Color.eWhiteH,
                "#ff99fe",
                item.IsWin and item.AttackName or item.TargetName,
                Enums.Color.eWhiteH),
            color = Enums.Color.eWhite,
            outlineColor = Enums.Color.eOutlineColor,
            dimensions = cc.size(size.width*0.68, 0)
        })
    descLabel:setAnchorPoint(0, 0.5)
    descLabel:setPosition(15, size.height*0.5)
    parent:addChild(descLabel)

    -- 查看战报按钮
    local reportBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("查看"),
        clickAction = function()
            item.FightInfo.TreasureInfo = nil
            -- 战斗页面控制信息
            local controlParams = Utility.getBattleControl(ModuleSub.eKillerValley)
            -- 调用战斗页面
            self.battleLayer = LayerManager.addLayer({
                name = "ComBattle.BattleLayer",
                data = {
                    data = item.FightInfo,
                    skip = controlParams.skip,
                    trustee = controlParams.trustee,
                    skill = controlParams.skill,
                    map = Utility.getBattleBgFile(ModuleSub.eKillerValley),
                    callback = function(retData)
                        LayerManager.removeLayer(self.battleLayer)

                        if controlParams.trustee and controlParams.trustee.changeTrusteeState then
                            controlParams.trustee.changeTrusteeState(retData.trustee)
                        end
                    end
                },
            })
        end
    })
    reportBtn:setPosition(cellBgSize.width - 75, cellBgSize.height / 2)
    cellBgSprite:addChild(reportBtn)
end

----------------------------------------------------------------------------------------------------

return DlgGameReportLayer