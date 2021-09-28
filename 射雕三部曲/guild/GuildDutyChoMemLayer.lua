--[[
    文件名：GuildDutyChoMemLayer
    描述：帮派任命页面
    创建人：chenzhong
    创建时间：2016.6.12
-- ]]

local GuildDutyChoMemLayer = class("GuildDutyChoMemLayer",function()
	return display.newLayer()
end)

--[[
    params:
    callBack      从父页面传过来的回调  点击任命时执行
    setPostId     目标权限id          用于判断不必要的设立  如已是欲设立的职位
    isZhuanR      是否是转让           转让只需要列出副帮主即可
]]
function GuildDutyChoMemLayer:ctor(params)
    -- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = self})

    self.callBack = params.callBack

    self.setPostId = params.setPostId

    self.isZhuanR = params.isZhuanR

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    self:initUI()

    self:requestGetGuildMembers()
end

function GuildDutyChoMemLayer:initUI()
    --背景
    self.backImageSprite = ui.newScale9Sprite("c_34.jpg", cc.size(640, 1136))
    self.backImageSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(self.backImageSprite)

    local backSize = self.backImageSprite:getContentSize()

    --关闭按钮
    local cancelBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(590, 1050),
        clickAction = function (sender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(cancelBtn)

     --在线成员
    local activePlayerBg = ui.newSprite("c_41.png")
    activePlayerBg:setPosition(120, 1040)
    self.mParentLayer:addChild(activePlayerBg)
    self.mActivePlayerLabel = ui.newLabel({
        text = TR("在线成员: %s%d/%d",Enums.Color.eNormalGreenH, 0, 0),
        size = 22,
        outlineColor = Enums.Color.eBlack,
        color = Enums.Color.eNormalWhite,
        x = 100,
        y = 1040,
    })
    self.mParentLayer:addChild(self.mActivePlayerLabel)

    -- 底部背景
    local listBg = ui.newScale9Sprite("c_17.png", cc.size(630, 900))
    listBg:setAnchorPoint(cc.p(0.5, 1))
    listBg:setPosition(320, 1005)
    self.mParentLayer:addChild(listBg)

    --顶部区域
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        needFAP = false,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eSTA, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(topResource)
end

function GuildDutyChoMemLayer:addListView(memberData)
    --筛选人物  只能操作职位小于自己的人  转让帮主只出现副帮主
    if self.isZhuanR then
        for i = #memberData, 1, -1 do
            if memberData[i].PostId ~= 34001002 then
                table.remove(memberData,i)
            end
        end
    else
        for i = #memberData, 1, -1 do
            if memberData[i].PostId <= GuildObj:getPlayerGuildInfo().PostId then
                table.remove(memberData,i)
            end
        end
    end

    table.sort( memberData, function (a, b)
        if a.PostId ~= b.PostId then
            return a.PostId < b.PostId
        elseif a.Vip ~= b.Vip then
            return a.Vip > b.Vip
        elseif a.FundTotal ~= b.FundTotal then
            return a.FundTotal > b.FundTotal
        else
            return a.FAP > b.FAP
        end
    end )

    if self.playerListView then
        self.playerListView:removeFromParent()
    end

    self.playerListView = ccui.ListView:create()
    self.playerListView:setContentSize(cc.size(630, 880))

    for i,player in ipairs(memberData) do
        self.playerListView:pushBackCustomItem(self:createPlayerCell(player))
    end

    self.playerListView:setAnchorPoint(cc.p(0.5,1))
    self.playerListView:setPosition(cc.p(320, 995))
    self.playerListView:setItemsMargin(15)
    self.playerListView:setDirection(ccui.ListViewDirection.vertical)
    self.playerListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    self.playerListView:setBounceEnabled(true)
    self.mParentLayer:addChild(self.playerListView)

    if next(memberData) == nil then
       local tempSprite = ui.createEmptyHint(TR("暂无帮派成员"))
        tempSprite:setPosition(320,568)
        self.mParentLayer:addChild(tempSprite)
    end
end

--创建单个成员控件
--[[
    params:
    table playerdata:
    {
        Id:玩家Id
        Name:玩家名称
        Lv:玩家等级
        Vip:玩家Vip等级
        HeadImageId:玩家头像
        IsActive:玩家是否在线
        OutTime:玩家离线时间
        FundTotal:玩家累积帮派资源
        BuildTime:建设间隔
        BuildType:上次建设建设类型
        PostId:权限Id
    }
]]
function GuildDutyChoMemLayer:createPlayerCell(playerdata)
    local cellSize = cc.size(630, 130)

    --添加背景
    local backImageSprite = ui.newScale9Sprite("c_18.png", cc.size(610, 130))
    backImageSprite:setPosition(cellSize.width / 2, cellSize.height / 2)

    --容器
    local layout = ccui.Layout:create()
    layout:setContentSize(cellSize)
    layout:addChild(backImageSprite)

    --头像
    local headerSpr = CardNode.createCardNode({
        resourceTypeSub = ResourcetypeSub.eHero,
        modelId = playerdata.HeadImageId,
        fashionModelID = playerdata.FashionModelId,
        IllusionModelId = playerdata.IllusionModelId,
        pvpInterLv = playerdata.DesignationId,
        cardShowAttrs = {CardShowAttr.eBorder},
        onClickCallback = function () end
        })
    headerSpr:setPosition(35 ,65)
    headerSpr:setAnchorPoint(cc.p(0,0.5))
    backImageSprite:addChild(headerSpr)

    --职务标识
    local dutySprData = {
        [34001001] = "bp_20.png",
        [34001002] = "bp_18.png",
        [34001003] = "bp_21.png",
        [34001004] = "bp_19.png",
    }

    if not dutySprData[playerdata.PostId] then
        local dutySprite = ui.newLabel({
            text = GuildPostModel.items[playerdata.PostId].name,
            size = 25,
            x = 140,
            y = 40,
            color = cc.c3b(0x46, 0x22, 0x0d),
            anchorPoint = cc.p(0, 0.5),
        })
        backImageSprite:addChild(dutySprite)
    else
        local dutySprite = ui.newSprite(dutySprData[playerdata.PostId])
        dutySprite:setAnchorPoint(cc.p(0, 0.5))
        dutySprite:setPosition(cc.p(140, 40))
        backImageSprite:addChild(dutySprite)
    end

    --名称
    local nameLabel = ui.newLabel({
        text = playerdata.Name,
        size = 22,
        color = cc.c3b(0x46, 0x22, 0x0d),
        x = 140,
        y = 90,
        anchorPoint = cc.p(0, 0.5)
    })
    backImageSprite:addChild(nameLabel)

    --贡献
    local donateLabel = ui.newLabel({
        text = TR("贡献:"),
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d),
        x = 230,
        y = 40,
        anchorPoint = cc.p(0, 0.5)
    })
    backImageSprite:addChild(donateLabel)

    local donateValueLabel = ui.createDaibiView({
        resourceTypeSub = ResourcetypeSub.eContribution,
        number = playerdata.FundTotal,
        fontColor = cc.c3b(0xd1, 0x7b, 0x00),
        fontSize = 20,
    })
    donateValueLabel:setAnchorPoint(cc.p(0, 0.5))
    donateValueLabel:setPosition(cc.p(280, 38))
    backImageSprite:addChild(donateValueLabel)

    --状态
    local str = ""
    local color = nil
    if playerdata.IsActive == true then
        str = TR("【当前在线】")
        color = Enums.Color.eNormalGreen
    else
        local tempStr = string.utf8sub(MqTime.toDownFormat(playerdata.OutTime), 1, -2)
        str = TR("【离线%s】",tempStr)
        color = Enums.Color.eRed
    end
    local stateLabel = ui.newLabel({
        text = str,
        size = 20,
        x = 420,
        y = 90,
        color = color,
        anchorPoint = cc.p(1, 0.5)
    })
    backImageSprite:addChild(stateLabel)

    --任命按钮
    local operBtn = ui.newButton({
        normalImage = "c_28.png",
        position = cc.p(495, 65),
        text = TR("任命"),
        clickAction = function (sender)
            if not self.isZhuanR then
                if (playerdata.PostId == self.setPostId) then
                    MsgBoxLayer.addOKLayer(TR("该成员已经是%s了", GuildPostModel.items[self.setPostId].name))
                    return
                end
            end

            self.callBack(playerdata.Id, playerdata.Name, playerdata.HeadImageId, playerdata.DesignationId, playerdata.FashionModelId)
            LayerManager.removeLayer(self)
        end
    })
    backImageSprite:addChild(operBtn)

    return layout
end

-- =============================== 请求服务器数据相关函数 ===================

--请求成员列表
function GuildDutyChoMemLayer:requestGetGuildMembers()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "GetGuildMembers",
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            local value = response.Value

            self.GuildMembersInfo = value.GuildMembersInfo
            --更新在线成员
            local activePlayer = 0
            for k,v in pairs(self.GuildMembersInfo) do
                if v.IsActive == true then
                    activePlayer = activePlayer + 1
                end
            end
            self.mActivePlayerLabel:setString(TR("在线成员: %s%d/%d",Enums.Color.eNormalGreenH, activePlayer, #self.GuildMembersInfo))
            self:addListView(self.GuildMembersInfo)
        end,
    })
end

return GuildDutyChoMemLayer