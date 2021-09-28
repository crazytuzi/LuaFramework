--[[
    文件名：GDDHReportLayer.lua
    描述：序列争霸战报页面
    创建人：libowen
    修改人:liucunxin
    创建时间：2016.12.6
--]]

local GDDHReportLayer = class("GDDHReportLayer", function(params)
    return display.newLayer()
end)

-- 数据暂存
local DataCache = {
     hideBox = false   
}

-- 构造函数
--[[
params:
    Table params:
    {
        dataList                            -- 必须的参数，战报列表，由上一级页面传入
        rankCount                           -- 必须的参数，玩家挑战次数
        buyRankCount                        -- 必须的参数，玩家已购买的挑战次数
        perNum                              -- 必须的参数，日挑战次数限制
    }
--]]
function GDDHReportLayer:ctor(params)
    -- 屏蔽下层点击事件
    -- ui.registerSwallowTouch({node = self})
    
    -- 保存数据
    self.mReviveList = params.dataList
    self.mRankCount = params.rankCount
    self.mBuyRankCount = params.buyRankCount
    self.mPerNum = params.perNum
    
    -----测试数据-----
    -- self.mReviveList = {}
    -- for i = 1, 10 do
    --     table.insert(self.mReviveList, {
    --         RankHeadImageId = 12011401, 
    --         RankName = "独步天下",
    --         GuildName = "天下无敌",
    --         RankFAP = 1234567890
    --     })
    -- end
    ---------------
    
    -- 初始化UI
    self:initUI()
end

-- 添加UI
function GDDHReportLayer:initUI()
    -- 添加弹出框层
    local bgSpriteWidth = 590
    local bgSpriteHeight = 598
    local popLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(bgSpriteWidth, bgSpriteHeight),
        title = TR("战报"),
    })
    self:addChild(popLayer)

    self.mBgSprite = popLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 添加黑色背景框
    local blackSize = cc.size(self.mBgSize.width*0.9, (self.mBgSize.height-153))
    local blackBg = ui.newScale9Sprite("c_17.png", blackSize)
    blackBg:setAnchorPoint(0.5, 0)
    blackBg:setPosition(self.mBgSize.width/2, 85)
    self.mBgSprite:addChild(blackBg)

    -- 显示暂无战报按钮
    local noReportLabel = ui.newLabel({
        text = TR("暂无战报"),
        size = 32,
        color = cc.c3b(0x59, 0x28, 0x17),
        align = ui.TEXT_ALIGN_CENTER
    })
    noReportLabel:setPosition(self.mBgSize.width * 0.5,  self.mBgSize.height * 0.56)
    self.mBgSprite:addChild(noReportLabel)
    if table.maxn(self.mReviveList) > 0 then
        noReportLabel:setVisible(false)
        
        -- 创建复仇列表
        self:createListView()
    end 

    -- 底部按钮
    local confirmBtn = ui.newButton({
            text = TR("确定"),
            normalImage = "c_28.png",
            position = cc.p(self.mBgSize.width * 0.5, 50),
            clickAction = function()
                LayerManager.removeLayer(self)
            end
        }):addTo(self.mBgSprite)
end

-- 创建复仇挑战列表
function GDDHReportLayer:createListView()
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(590, 435))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    -- self.mListView:setItemsMargin(3)
    self.mListView:setAnchorPoint(cc.p(0, 1))
    self.mListView:setPosition(0, self.mBgSize.height * 0.88)
    self.mBgSprite:addChild(self.mListView)

    -- 添加数据
    for i = 1, #self.mReviveList do
        self.mListView:pushBackCustomItem(self:createCellByIndex(i))
    end
end

-- 创建复仇列表的每一个条目
--[[
    params:
    index                           -- cell的序号
--]]
function GDDHReportLayer:createCellByIndex(index)
    local cellInfo = self.mReviveList[index]

    -- 创建cell
    local width = self.mListView:getContentSize().width
    local height = 120
    local customCell = ccui.Layout:create()
    customCell:setContentSize(cc.size(width, height))

    -- cell背景
    local cellBgSprite = ui.newScale9Sprite("c_18.png", cc.size(520, 118))
    cellBgSprite:setPosition(width * 0.5, height * 0.5)
    customCell:addChild(cellBgSprite)
    local cellbgSize = cellBgSprite:getContentSize()

    -- 头像
    local head = CardNode.createCardNode({
        resourceTypeSub = ResourcetypeSub.eHero,
        modelId = cellInfo.RankHeadImageId,
        IllusionModelId = cellInfo.IllusionModelId,
        cardShowAttrs = {CardShowAttr.eBorder},
        onClickCallback = function()
            -- self.mScrollViewPos = self.mListView:getInnerContainerPosition()
            --dump(self.mScrollViewPos, "滑动位置:")

            Utility.showPlayerTeam(cellInfo.RankPlayerId)
        end
    })
    head:setAnchorPoint(cc.p(0, 0.5))
    head:setPosition(cellbgSize.width * 0.06, cellbgSize.height * 0.5)
    cellBgSprite:addChild(head)

    -- 名字
    local nameLabel = ui.newLabel({
        text = TR(cellInfo.RankName),
        color = cc.c3b(0x59, 0x28, 0x17),
        -- size = 23,
    })
    nameLabel:setAnchorPoint(cc.p(0, 1))
    nameLabel:setPosition(cellbgSize.width * 0.25, cellbgSize.height * 0.75)
    cellBgSprite:addChild(nameLabel)

    -- -- 帮派
    -- local guildText = (cellInfo.GuildName and cellInfo.GuildName ~= "") and cellInfo.GuildName or "暂未加入帮派"
    -- local guildName = ui.newLabel({
    --     text = TR("帮派: %s%s", 
    --         Enums.Color.eNormalGreenH, 
    --         guildText
    --     ),
    --     color = Enums.Color.eNormalWhite,
    --     size = 21,
    -- })
    -- guildName:setAnchorPoint(cc.p(0, 0.5))
    -- guildName:setPosition(cellbgSize.width * 0.25, cellbgSize.height * 0.5)
    -- cellBgSprite:addChild(guildName)

    -- 显示战斗力
    local fapText = Utility.numberFapWithUnit(cellInfo.RankFAP)
    local fapLabel = ui.newLabel({
        text = TR("战斗力: %s%s", 
            "#249029", 
            fapText
        ),
        color = cc.c3b(0x59, 0x28, 0x17),
        size = 20,
    })
    fapLabel:setAnchorPoint(cc.p(0, 0))
    fapLabel:setPosition(cellbgSize.width * 0.25, cellbgSize.height * 0.25)
    cellBgSprite:addChild(fapLabel)
   
    -- 显示复仇按钮
    local revengeBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("复仇"),
        anchorPoint = cc.p(0, 0.5),
        position = cc.p(cellbgSize.width * 0.7, cellbgSize.height * 0.5),
        clickAction = function()
            print("---复仇---")
             -- 没有挑战次数了
            if self.mRankCount == 0 then
                ui.showFlashView({
                    text = TR("当前挑战次数已使用完毕,请耐心等待挑战恢复!!!\n                        君子报仇十年不晚!!!")
                })
            else
                -- 耐力是否足够
                if Utility.isResourceEnough(ResourcetypeSub.eSTA, 2, true) then
                    self:requestRankWrestleRace(cellInfo, 1)
                end
            end
        end
        })
    cellBgSprite:addChild(revengeBtn)

    return customCell
end

-----------------------------网络相关-----------------------------------
-- 请求服务器，挑战对应玩家
--[[
    params:
    playerData              -- 挑战目标玩家数据
    type                    -- 是否通过复仇挑战   0:正常列表挑战  1:复仇挑战
--]]
function GDDHReportLayer:requestRankWrestleRace(playerData, type)
    local requestData = {playerData.RankPlayerId, type}
    HttpClient:request({
        moduleName = "Gddh",
        methodName = "RankWrestleRace",
        svrMethodData = requestData,
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 获取战斗信息
            local control = Utility.getBattleControl(ModuleSub.eChallengeWrestle)

            LayerManager.addLayer({
                name = "ComBattle.BattleLayer",
                data = {
                    data = data.Value.FightInfo,
                    skip = control.skip,
                    trustee = control.trustee,
                    skill = control.skill,
                    map = Utility.getBattleBgFile(ModuleSub.eChallengeWrestle),
                    callback = function(result)
                        PvpResult.showPvpResultLayer(
                            ModuleSub.eChallengeWrestle, 
                            data.Value, 
                            {
                                PlayerName = PlayerAttrObj:getPlayerAttrByName("PlayerName"), 
                                FAP = PlayerAttrObj:getPlayerAttrByName("FAP"),
                            }, 
                            {
                                PlayerName = playerData.RankName, 
                                FAP = playerData.RankFAP,
                                PlayerId = playerData.RankPlayerId,
                            }
                        )

                        if control.trustee and control.trustee.changeTrusteeState then
                            control.trustee.changeTrusteeState(result.trustee)
                        end
                    end
                }
            })
        end
    })
end

-- 请求服务器，购买挑战次数
--[[
    params:
    playerData                  -- 挑战目标玩家数据
    buyCount                    -- 购买次数
--]]
function GDDHReportLayer:requestBuyRankCount(playerData, buyCount)
    local requestData = {buyCount}
    HttpClient:request({
        moduleName = "Gddh", 
        methodName = "BuyRankCount", 
        svrMethodData = requestData,
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if data.Status ~= 0 then
                return
            end

            self:requestRankWrestleRace(playerData, 1)
        end
    })
end

return GDDHReportLayer