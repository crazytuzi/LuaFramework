--[[
	文件名：DlgLookReportLayer
	描述：弹出查看战报的对话框
	创建人：peiyaoqiang
	创建时间：2017.11.2
-- ]]

local DlgLookReportLayer = class("DlgLookReportLayer",function()
	return cc.LayerColor:create(cc.c4b(0, 0, 0, 100))
end)

function DlgLookReportLayer:ctor(params)
	-- 读取参数
    self.reportLog = params or {}
    -- dump(params)
    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("战报信息"),
        bgSize = cc.size(600, 450),
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)

    -- 保存弹窗控件信息
    self.mBgSprite = bgLayer.mBgSprite
    self.mBgSize = bgLayer.mBgSprite:getContentSize()
    
	-- 
	-- self:initUIs()
    self:initUI()
end

function DlgLookReportLayer:initUI()
    --灰色底板
    local grayBgSprite = ui.newScale9Sprite("c_17.png", cc.size(540, 350))
    grayBgSprite:setPosition(300, 205)
    self.mBgSprite:addChild(grayBgSprite)

    -- 列表控件
    local reportListView = ccui.ListView:create()
    reportListView:setDirection(ccui.ScrollViewDir.vertical)
    reportListView:setBounceEnabled(true)
    reportListView:setContentSize(cc.size(540, 340))
    reportListView:setItemsMargin(5)
    reportListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    reportListView:setAnchorPoint(cc.p(0.5, 0.5))
    reportListView:setPosition(300, 205)
    self.mBgSprite:addChild(reportListView)

    -- 创建头像
    local function createHeader(parent, pos, item)
        if (item.HeadImageId == nil) or (item.HeadImageId == 0) then
            local emptySprite = ui.newSprite("wlmz_32.png")
            emptySprite:setScale(0.8)
            emptySprite:setPosition(pos)
            parent:addChild(emptySprite)
        else
            local attackHead = CardNode.createCardNode({
                resourceTypeSub = ResourcetypeSub.eHero,
                modelId = item.HeadImageId,
                fashionModelID = item.FashionModelId,
                cardShowAttrs = {CardShowAttr.eBorder},
                allowClick = false,
            })
            attackHead:setCardName(item.PlayerName, 1)
            attackHead:setPosition(pos)
            parent:addChild(attackHead)
        end
    end

    -- 显示战报
    for i,v in ipairs(self.reportLog) do
        local layout = ccui.Layout:create()
        layout:setContentSize(530, 144)

        local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(530, 140))
        bgSprite:setPosition(265, 72)
        layout:addChild(bgSprite)

        --左边玩家
        createHeader(layout, cc.p(80, 82), {HeadImageId = v.AttackerHeadImageId, FashionModelId = v.AttackerFashionModelId, PlayerName = v.AttackerName})
        
        --胜负标签
        local isWinSpriteA = ui.newSprite(v.IsWin and "zdjs_14.png" or "zdjs_13.png")
        isWinSpriteA:setPosition(120, 120)
        layout:addChild(isWinSpriteA)

        --vs标志
        local versusSprite = ui.newSprite("zdjs_07.png")
        versusSprite:setPosition(190, 82)
        versusSprite:setScale(0.8)
        layout:addChild(versusSprite)

        --右边玩家
        createHeader(layout, cc.p(300, 82), {HeadImageId = v.DefenderHeadImageId, FashionModelId = v.DefenderFashionModelId, PlayerName = v.DefenderName})
        
        --胜负标签
        local isWinSpriteD = ui.newSprite(v.IsWin and "zdjs_13.png" or "zdjs_14.png")
        isWinSpriteD:setPosition(340, 120)
        layout:addChild(isWinSpriteD)
        
        --场次
        local fightNumLabel = ui.newLabel({
            text = TR("第%s场", i),
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            size = 22,
            })
        fightNumLabel:setPosition(440, 102)
        layout:addChild(fightNumLabel)

        --查看按钮
        local checkBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("战报"),
            clickAction = function()
                if (v.AttackerHeadImageId == nil) or (v.AttackerHeadImageId == 0) or (v.DefenderHeadImageId == nil) or (v.DefenderHeadImageId == 0) then
                    ui.showFlashView(TR("本场比赛轮空，没有战报"))
                    return
                end
                self:requestGetReport(v.BattleReportId, i)
            end
            })
        checkBtn:setPosition(440, 52)
        layout:addChild(checkBtn)

        reportListView:pushBackCustomItem(layout)
    end
end

--==================================网络请求====================================
--请求战报
function DlgLookReportLayer:requestGetReport(battleId, rand)
    HttpClient:request({
        moduleName = "PVPinterTop", 
        methodName = "GetBattleReportContent",
        svrMethodData = {battleId},
        callback = function (data)            
            if not data.Value or data.Status ~= 0 then
                return
            end

            local battleInfo = data.Value.BattleReport.ClientRes
            local control = Utility.getBattleControl(ModuleSub.eWhosTheGod)

            local info = self.reportLog[rand]
            battleInfo.IsWin = info.IsWin
            battleInfo.TreasureInfo = nil --服务端返回为0避免报错直接赋值为空
            LayerManager.addLayer({
                name = "ComBattle.BattleLayer",
                data = {
                    data = battleInfo,
                    skip = control.skip,
                    trustee = control.trustee,
                    skill = control.skill,
                    map = Utility.getBattleBgFile(ModuleSub.eChallengeWrestle),-- 用挖矿的地图
                    callback = function(battleResult)
                        PvpResult.showPvpResultLayer(
                            ModuleSub.eShengyuanWars,
                            battleInfo,
                            {
                                PlayerName = info.AttackerName,
                                FAP = info.AttackerFAP,
                            },
                            {
                                PlayerName = info.DefenderName,
                                FAP = info.DefenderFAP,
                            }
                        )
                        if control.trustee and control.trustee.changeTrusteeState then
                            control.trustee.changeTrusteeState(battleResult.trustee)
                        end
                    end
                },
            })
        end
    })
end

return DlgLookReportLayer
