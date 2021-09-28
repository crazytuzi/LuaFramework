--[[
    文件名: ShengyuanWarsChooseTeamMateLayer.lua
    描述: 决战桃花岛邀请队友页面
    创建人: chenzhogn
    创建时间: 2017.9.2
--]]

-- 待邀请的玩家类型：好友/公会成员
local PersonType = {
    eTypeFriend = 1,
    eTypeGuildMember = 2
}

local ShengyuanWarsChooseTeamMateLayer = class("ShengyuanWarsChooseTeamMateLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 100))
end)

-- 构造函数
--[[
    params:
--]]
function ShengyuanWarsChooseTeamMateLayer:ctor(params)
    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 包含顶部底部的公共layer
    -- self.mCommonLayer = require("commonLayer.CommonLayer"):create({
    --     needMainNav = true,
    --     topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond},
    -- })
    -- self:addChild(self.mCommonLayer)

    -- 初始化页面
    self:initUI()

    -- 请求服务器，获取可邀请的人员信息
    self:requestGetFriendsOrGuildMembers()
end

-- 初始化UI
function ShengyuanWarsChooseTeamMateLayer:initUI()
    -- 背景
    self.mBgSprite = ui.newScale9Sprite("c_30.png", cc.size(572, 908))
    self.mBgSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(self.mBgSprite)
    local bgSize = self.mBgSprite:getContentSize()

    local title = ui.newLabel({
        size = 30,
        text = TR("好友邀请"),
        color = cc.c3b(0xff, 0xee, 0xdD),
        outlineColor = cc.c3b(0x3f, 0x27,0x1f),
        outlineSize = 1,
        })
    title:setAnchorPoint(cc.p(0.5, 1.0))
    title:setPosition(cc.p(bgSize.width / 2 , bgSize.height - 20))
    self.mBgSprite:addChild(title)

    -- 返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        anchorPoint = cc.p(1, 1),
        position = cc.p(bgSize.width, bgSize.height + 10),
        clickAction = function()
            LayerManager.removeLayer(self)
        end,
    })
    self.mBgSprite:addChild(closeBtn)

    self.mViewBg = ui.newScale9Sprite("c_17.png", cc.size(520, 810))
    self.mViewBg:setAnchorPoint(cc.p(0.5, 1))
    self.mViewBg:setPosition(cc.p(bgSize.width / 2, bgSize.height - 70))
    self.mBgSprite:addChild(self.mViewBg)
end

-- 获取数据后，刷新页面
function ShengyuanWarsChooseTeamMateLayer:refreshLayer()
    -- 没有可邀请的人员
    if (table.nums(self.mInfo.FriendPlayer) <= 0) and (table.nums(self.mInfo.GuildPlayer) <= 0) then
        local tipNode = ui.createEmptyHint(TR("暂无在线的帮派成员"))
        tipNode:setPosition(286, 580)
        self.mBgSprite:addChild(tipNode)
    else
        -- 处理数据
        self:handleData()

        -- 创建listview
        self:createListView()
    end
end

-- 数据处理
function ShengyuanWarsChooseTeamMateLayer:handleData()
    -- 去重
    local tempList = {}
    for k, v in pairs(self.mInfo.GuildPlayer) do
        v.personType = PersonType.eTypeGuildMember
        tempList[v.PlayerId] = v
    end
    for k, v in pairs(self.mInfo.FriendPlayer) do
        v.personType = PersonType.eTypeFriend
        tempList[v.PlayerId] = v
    end

    -- 可邀请成员列表（无重复）
    self.mPersonList = {}
    for k, v in pairs(tempList) do
        table.insert(self.mPersonList, v)
    end

    -- 排序
    table.sort(self.mPersonList, function(a, b)
        if a.FAP ~= b.FAP then
            return a.FAP > b.FAP
        else
            return a.State < b.State
        end
    end)
end

-- 创建listview
function ShengyuanWarsChooseTeamMateLayer:createListView()
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(572, 805))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setItemsMargin(5)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(286, 830)
    self.mBgSprite:addChild(self.mListView)

    for i, v in ipairs(self.mPersonList) do
        self.mListView:pushBackCustomItem(self:createCellByInfo(v))
    end
end

-- 创建每一个cell
--[[
    info        -- 人员信息
--]]
function ShengyuanWarsChooseTeamMateLayer:createCellByInfo(info)
    -- 创建cell
    local cellWidth, cellHeight = 572, 130
    local customCell = ccui.Layout:create()
    customCell:setContentSize(cc.size(cellWidth, cellHeight))

    -- cell背景
    local cellBg = ui.newScale9Sprite("c_18.png",cc.size(cellWidth-64, cellHeight-2))
    cellBg:setPosition(cc.p(cellWidth * 0.5, cellHeight * 0.5))
    customCell:addChild(cellBg)
    local cellBgSize = cellBg:getContentSize()

    -- 玩家头像
    local header = CardNode.createCardNode({
        resourceTypeSub = ResourcetypeSub.eHero,
        modelId = info.HeadImageId,
        fashionModelID = info.FashionModelId,
        IllusionModelId = info.IllusionModelId,
        cardShowAttrs = {CardShowAttr.eBorder},
        PVPInterLv = info.DesignationId,
        onClickCallback = function()
            Utility.showPlayerTeam(info.PlayerId)
        end
    })
    header:setPosition(cellBgSize.width * 0.2, cellBgSize.height * 0.48)
    cellBg:addChild(header)
    header:setScale(0.9)

    -- 玩家名字
    local nameLabel = ui.newLabel({
        text = TR("%s", info.Name),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 24
    })
    nameLabel:setAnchorPoint(cc.p(0, 0))
    nameLabel:setPosition(cellBgSize.width * 0.33, cellBgSize.height * 0.53)
    cellBg:addChild(nameLabel)

    -- 战斗力
    local fapLabel = ui.newLabel({
        text = TR("战斗力: %s%s", "#56c636", Utility.numberFapWithUnit(info.FAP)),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 24
    })
    fapLabel:setAnchorPoint(cc.p(0, 1))
    fapLabel:setPosition(cellBgSize.width * 0.33, cellBgSize.height * 0.42)
    cellBg:addChild(fapLabel)

    -- 邀请按钮
    local inviteBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("邀请"),
        position = cc.p(cellBgSize.width * 0.82, cellBgSize.height * 0.5),
        clickAction = function(btnObj)
            self:requestInviteFriends(info.PlayerId)

            -- 按钮cd
            btnObj:setEnabled(false)
            local cdTime = 30
            btnObj.ac = Utility.schedule(btnObj, function()
                if cdTime < 0 then
                    btnObj:stopAction(btnObj.ac)
                    btnObj.ac = nil
                    btnObj:setEnabled(true)
                    btnObj:setTitleText(TR("邀请"))
                else
                    btnObj:setTitleText(string.format("%sS", cdTime))
                    cdTime = cdTime - 1
                end
            end, 1.0)
        end
    })
    cellBg:addChild(inviteBtn)

    -- 不同状态
    if info.State == 1 then
        inviteBtn:setTitleText(TR("队伍中"))
        inviteBtn:setEnabled(false)
    elseif info.State == 2 then
        inviteBtn:setTitleText(TR("游戏中"))
        inviteBtn:setEnabled(false)
    elseif info.HangUpResetTime - Player:getCurrentTime() >= 0 then
        inviteBtn:setTitleText(TR("惩罚中"))
        inviteBtn:setEnabled(false)
    end

    return customCell
end

--------------------------------网络相关------------------------------------
-- 请求服务器，获取可邀请的成员信息
function ShengyuanWarsChooseTeamMateLayer:requestGetFriendsOrGuildMembers()
    HttpClient:request({
        moduleName = "ShengyuanTeam",
        methodName = "GetFriendsOrGuildMembers",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            --dump(data, "requestGetFriendsOrGuildMembers")

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            data.Value.FriendPlayer = data.Value.FriendPlayer or {}
            data.Value.GuildPlayer = data.Value.GuildPlayer or {}

            -- 保存数据
            self.mInfo = data.Value

            -- 刷新页面
            self:refreshLayer()
        end
    })
end

-- 请求服务器，邀请人员
--[[
    playerId            -- 玩家id
--]]
function ShengyuanWarsChooseTeamMateLayer:requestInviteFriends(playerId)
    HttpClient:request({
        moduleName = "ShengyuanTeam",
        methodName = "InviteFriends",
        svrMethodData = {playerId},
        callbackNode = self,
        callback = function (data)

            -- 容错处理
            if data.Status ~= 0 then
                return
            end

            -- 飘窗提示
            ui.showFlashView({
                text = TR("发送组队邀请成功")
            })
        end
    })
end

return ShengyuanWarsChooseTeamMateLayer