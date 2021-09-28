--[[
    文件名：IcefirePlayerInfoLayer.lua
    描述：冰火岛入口
    创建人：yanghongsheng
    创建时间： 2019.07.17
--]]

require("ice.IcefireHelper")

local IcefirePlayerInfoLayer = class("IcefirePlayerInfoLayer", function(params)
    return display.newLayer()
end)

--[[
    params:
        playerId    -- 玩家id
        msgType     -- 弹窗类型（1:加入队伍 2:踢出队伍 3:无操作）
]]

function IcefirePlayerInfoLayer:ctor(params)
    self.mPlayerId = params.playerId
    self.mMsgType = params.msgType or 3
    self.mPlayerInfo = IcefireHelper:getPlayerData(self.mPlayerId)
    -- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(580, 370),
        title = TR("玩家信息"),
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 创建页面控件
    self:initUI()
end


function IcefirePlayerInfoLayer:initUI()
    -- 人物名片背景
    local itemSize = cc.size(526, 150)
    local itemBg = ui.newScale9Sprite("c_65.png", itemSize)
    itemBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.6)
    self.mBgSprite:addChild(itemBg)
    -- 创建玩家头像
    local headCard = CardNode.createCardNode({
        resourceTypeSub = ResourcetypeSub.eHero,
        modelId = self.mPlayerInfo.HeadImageId,
        cardShowAttrs = {CardShowAttr.eBorder},
        allowClick = false,
    })
    headCard:setPosition(itemSize.width*0.11, itemSize.height*0.5)
    itemBg:addChild(headCard)
    -- 玩家姓名
    local playerName = ui.newLabel({
            text = TR("姓名: %s", self.mPlayerInfo.Name),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 22,
        })
    playerName:setAnchorPoint(cc.p(0, 0))
    playerName:setPosition(itemSize.width*0.22, itemSize.height*0.6)
    itemBg:addChild(playerName)
    -- 等级
    local playerLv = ui.newLabel({
        text = TR("等级: %s%d", "#d17b00", self.mPlayerInfo.Lv),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 22,
    })
    playerLv:setAnchorPoint(cc.p(0, 0))
    playerLv:setPosition(itemSize.width*0.22, itemSize.height*0.375)
    itemBg:addChild(playerLv)
    -- 战力
    local FAPStr = Utility.numberFapWithUnit(self.mPlayerInfo.Fap)
    local playerFap = ui.newLabel({
        text = TR("战斗力: %s%s", "#20781b", FAPStr),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 22,
    })
    playerFap:setAnchorPoint(cc.p(0, 0))
    playerFap:setPosition(itemSize.width*0.6, itemSize.height*0.6)
    itemBg:addChild(playerFap)
    -- 区服
    local playerGuild = ui.newLabel({
        text = TR("区服: %s%s", "#d17b00", self.mPlayerInfo.Zone),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 22,
    })
    playerGuild:setAnchorPoint(cc.p(0, 0))
    playerGuild:setPosition(itemSize.width*0.6, itemSize.height*0.375)
    itemBg:addChild(playerGuild)
    -- 神行值
    local playerGuild = ui.newLabel({
        text = TR("神行值: %s%s", "#d17b00", self.mPlayerInfo.ActionNum),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 22,
    })
    playerGuild:setAnchorPoint(cc.p(0, 0))
    playerGuild:setPosition(itemSize.width*0.22, itemSize.height*0.15)
    itemBg:addChild(playerGuild)

    -- 加入队伍
    if self.mMsgType == 1 then
        local tempBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("加入队伍"),
            clickAction = function ()
                -- 是否已在队伍中
                if IcefireHelper.ownPlayerInfo.LeaderId ~= PlayerAttrObj:getPlayerAttrByName("PlayerId") then
                    ui.showFlashView(TR("请先退出队伍"))
                    return
                end
                IcefireHelper:requestJoinTeam(self.mPlayerInfo.TeamId)
                LayerManager.removeLayer(self)
            end
        })
        tempBtn:setPosition(self.mBgSize.width*0.5, 80)
        self.mBgSprite:addChild(tempBtn)
    -- 踢出队伍
    elseif self.mMsgType == 2 then
        local tempBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("踢出队伍"),
            clickAction = function ()
                IcefireHelper:deleteMember(self.mPlayerId)
                LayerManager.removeLayer(self)
            end
        })
        tempBtn:setPosition(self.mBgSize.width*0.5, 80)
        self.mBgSprite:addChild(tempBtn)
    -- 踢出队伍
    elseif self.mMsgType == 3 then
        local tempBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("确认"),
            clickAction = function ()
                LayerManager.removeLayer(self)
            end
        })
        tempBtn:setPosition(self.mBgSize.width*0.5, 80)
        self.mBgSprite:addChild(tempBtn)
    end
end

return IcefirePlayerInfoLayer