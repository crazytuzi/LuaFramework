--[[
    文件名: GuildRankLayer
    描述: 帮派排行
    创建人: chenzhong
    创建时间: 2017.03.06
-- ]]

local GuildRankLayer = class("GuildRankLayer",function()
	return cc.LayerColor:create(cc.c4b(0, 0, 0, 200))
end)

function GuildRankLayer:ctor()
	-- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    --初始化页面控件
    self:initUI()

    --获取成员信息
    self:requestGetGuildRankList()
end

--初始化UI
function GuildRankLayer:initUI()
	--背景
    local backImageSprite = ui.newScale9Sprite("c_34.jpg", cc.size(640, 1136))
    backImageSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(backImageSprite)

    --标题
    -- local titleLabel = ui.newLabel({
    --     text = TR("帮派排名"),
    --     size = 32,
    --     x = 320,
    --     y = 1045,
    -- })
    -- self.mParentLayer:addChild(titleLabel)

	--关闭按钮
    local cancelBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(600, 1040),
        clickAction = function ()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(cancelBtn)

    local listBg = ui.newScale9Sprite("c_17.png", cc.size(610, 900))
    listBg:setAnchorPoint(cc.p(0.5, 1))
    listBg:setPosition(320, 1005)
    self.mParentLayer:addChild(listBg)
    --成员列表
    self.guildListView = ccui.ListView:create()
    self.guildListView:setContentSize(cc.size(630, 880))
    self.guildListView:setAnchorPoint(cc.p(0.5,1))
    self.guildListView:setPosition(cc.p(320, 995))
    self.guildListView:setItemsMargin(10)
    self.guildListView:setDirection(ccui.ListViewDirection.vertical)
    self.guildListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    self.guildListView:setBounceEnabled(true)
    self.mParentLayer:addChild(self.guildListView)

    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        needFAP = false,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eSTA, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(topResource)
end

--刷新listView
function GuildRankLayer:refreshListView()
	for i = 1, #self.mRankList do
        self.guildListView:pushBackCustomItem(self:createRankCell(i))
    end
end

function GuildRankLayer:createRankCell(index)
	local cellSize = cc.size(620, 144)

    --容器
    local layout = ccui.Layout:create()
    layout:setContentSize(cellSize)

    -- 条目的背景图
    local cellBgSprite = ui.newScale9Sprite("c_54.png", cc.size(600, 149))
    cellBgSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
    layout:addChild(cellBgSprite)

    local desireBg = ui.newSprite("bp_14.png")
    desireBg:setPosition(cc.p(155, 12))
    desireBg:setAnchorPoint(0, 0)
    layout:addChild(desireBg)

    local info = self.mRankList[index]

    -- 名字
    local guildName = ui.newLabel({
        text = info.Name,
        color = cc.c3b(0xfa, 0xf6, 0xf1),
        outlineColor = cc.c3b(0x8d, 0x4b, 0x3a),
        outlineSize = 1,
        size = 26,
        x = 310,
        y = 125
    })
    layout:addChild(guildName)

    local imageData = {
    	[1] = {image = "c_44.png"},
    	[2] = {image = "c_45.png"},
    	[3] = {image = "c_46.png"},
	}

	if imageData[index] then
		local rankSprite = ui.newSprite(imageData[index].image)
		rankSprite:setPosition(cc.p(55, 60))
        layout:addChild(rankSprite)
    else
    	local rankNumLabel = ui.createSpriteAndLabel({
            imgName = "c_47.png",
            -- scale9Size = cc.size(69, 69),
            labelStr = index,
            fontColor = Enums.Color.eNormalWhite,
            -- outlineColor = Enums.Color.eOutlineColor,
            fontSize = 40
        })
        rankNumLabel:setPosition(cc.p(55, 60))
        layout:addChild(rankNumLabel)
    end

    -- 帮主:
    local leaderName = ui.newLabel({
        text = TR("#46220d帮主:   #d38212%s", info.LeaderName),
        size = 20,
        -- font = _FONT_PANGWA,
        -- outlineColor = cc.c3b(0, 0, 0),
        color = Enums.Color.eNormalWhite,
        anchorPoint = cc.p(0, 0.5),
        x = 95,
        y = 78
    })
    layout:addChild(leaderName)

    -- 等级
    local levelLabel = ui.newLabel({
        text = TR("#46220d等级:   #d38212%s", info.Lv),
        size = 20,
        anchorPoint = cc.p(0, 0.5),
        color = Enums.Color.eNormalWhite,
        x = 295,
        y = 78
    })
    layout:addChild(levelLabel)

    -- 成员
    local memberNumMax = GuildLvRelation.items[info.Lv].memberNumMax + (info.ExtendCount or 0)
    local pipo = ui.newLabel({
        text = TR("#46220d成员:   #d38212%d/%d", info.MemberCount, memberNumMax),
        size = 20,
        color = Enums.Color.eNormalWhite,
        anchorPoint = cc.p(0, 0.5),
        x = 95,
        y = 50
    })
    layout:addChild(pipo)

    -- 帮派资金
    local function formatValue(value)
        local nCount = value or 0
        local strCount = tostring(nCount)
        if (nCount >= 100000) then
            strCount = math.floor(nCount / 10000) .. TR("万")
        end

        return strCount
    end

    local guildFundTotal = ui.newLabel({
            text = TR("#46220d帮派资金:   #d38212%s", formatValue(info.GuildFundTotal)),
            size = 20,
            color = Enums.Color.eNormalWhite,
            anchorPoint = cc.p(0, 0.5),
            x = 295,
            y = 50
        })
    layout:addChild(guildFundTotal)

    -- 宣言
    local subject = info.Declaration
    local needBtn = false
    if string.utf8len(subject) > 14  then
        needBtn = true
        subject = string.utf8sub(subject, 1, 14).."..."
        print(subject)
    elseif string.find(subject, "\n") then
        local sStart, sEnd =  string.find(subject, "\n")
        needBtn = true
        subject = string.sub(subject, 1, sStart -1 ).."..."
    end

    if needBtn then
        local xqbt = ui.newButton({
            normalImage = "c_28.png",
            text = TR("详情"),
            scale = 0.9,
            position = cc.p(540, 56),
            clickAction = function()
                MsgBoxLayer.addOKLayer(info.Declaration, TR("帮派宣言"))
            end
        })
        layout:addChild(xqbt)
    end

    local declaration = ui.newLabel({
        text = TR("宣言:"),
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d),
        anchorPoint = cc.p(0, 0.5),
        dimensions = cc.size(cellSize.width * 0.6, 0),
        x = 95,
        y = 22
    })
    layout:addChild(declaration)

    local declaration = ui.newLabel({
        text = subject,
        size = 20,
        color = cc.c3b(0xd3, 0x82, 0x12),
        anchorPoint = cc.p(0, 0.5),
        dimensions = cc.size(cellSize.width * 0.6, 0),
        x = 155,
        y = 22
    })
    layout:addChild(declaration)

    return layout
end

-- ================== 请求服务器数据相关函数 ===================

--请求排行榜数据
function GuildRankLayer:requestGetGuildRankList()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "GetGuildRankList",
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- dump(response.Value.GuildRankInfo)
            self.mRankList = response.Value.GuildRankInfo
            self:refreshListView()
        end,
    })
end

return GuildRankLayer
