--[[
    文件名：GDDHLayer.lua
    描述：武林大会主页面 (GDDH---->格斗大会)
    创建人：liucunxin
    创建时间：2017.2.3
--]]

local GDDHLayer = class("GDDHLayer", function(params)
    return display.newLayer()
end)

-- 三个挑战玩家的位置大小信息
local targetPlayerInfo = {
    [1] = {
        position = cc.p(240, 720),                  -- 位置
        scale = 0.17,                               -- 缩放比例
    },
    [2] = {
        position = cc.p(420, 720),
        scale = 0.17,
    },
    [3] = {
        position = cc.p(540, 620),
        scale = 0.17,
    },
    [4] = {
        position = cc.p(100, 620),
        scale = 0.17,
    },
}

-- listview每组成员个数
local EachGroupNum = 8

-- 构造函数
--[[
    params:
    -- 恢复页面需要请求数据，正常情况下进入页面不需要调用
    Table params: 进入战斗页面之后恢复数据
    {
        needAction                  -- 是否需要进场动画
        oldFourList                 -- 之前排在玩家前面的两个玩家
        mOldRank                    -- 进入战斗页面之前的排名
        alreadyPlayRank             -- 是否已经播放过排名动画
    }
--]]
function GDDHLayer:ctor(params)
    -- 格斗大会赛季信息
    self.mSignupInfo = {}
    -- 玩家格斗大会信息
    self.mWrestleRaceInfo = {}
    -- 挑战玩家实例列表
    self.challengPlayerNodeList = {}
    -- TabView选择Id
    self.mSelectId = params.selectId
    -- 玩家组号
    self.mGroupId = params.groupId or nil
    -- 战斗前，玩家的排名
    self.mOldRank = params.oldRank or 0
    -- 战斗前，玩家名次前四个玩家的的信息
    self.mOldFourList = params.oldFourList or {}
    -- 是否需要入场动画,默认为需要
    self.mNeedAction = params.needAction ~= false
    -- 是否已经播放过排名动画
    self.mAlreadyPlayRank = params.alreadyPlayRank
    -- 配置宝箱奖励信息
    self:addChestAward()
    -- 获取格斗大会信息
    self:requestSignupInfo()

    -- 创建页面父对象
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建页面背景
    self.mBgSprite = ui.newSprite("wldh_15.jpg")
    self.mBgSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(self.mBgSprite)
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 创建页面二层背景
    local twoBgSprite = ui.newSprite("wldh_16.png")
    twoBgSprite:setPosition(cc.p(320, 638))
    self.mBgSprite:addChild(twoBgSprite)

    -- 旗帜（特效）
    ui.newEffect({
        parent = self.mBgSprite,
        effectName = "effect_ui_wulingdahui",
        position = cc.p(550, 1035),
        scale = 0.5,
        loop = true,
        })

    -- 包含顶部底部的公共layer
    local mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {ResourcetypeSub.eSTA, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond},
        })
    self:addChild(mCommonLayer)
end

-- 初始化本地数据UI
function GDDHLayer:initUIWithoutData()
    -- 创建页面功能性按钮
    self.mFunctionBtns = self:createFunctionBtn()

    -- 创建页面宝箱按钮
    self.mChestBtnNode = self:createChestBtn()

    -- 创建页面非功能性导航按钮
    self.mNonFunctionBtns = self:createOptBtn()
end

-- 初始化服务器数据UI
function GDDHLayer:initUI()
    -- 显示功能按钮(动画逻辑处理需要)
    for _, item in pairs(self.mFunctionBtns) do
        item:setVisible(true)
    end

    -- 创建空排行榜
    self.mTabView = self:createTabLayer()

    -- 创建玩家形象
    self:createPlayer()

    -- 创建奖励倒计时label, 休战状态不显示
    if not self.mIsInTruce then
        self:createInfoLabel()
    end

    -- 所有控件移到场外以便播放入场动画
    self:setAllItemPosition()

    -- 刷新排行榜数据
    local selectid = self.mSelectId or self.mGroupId or 1       -- 恢复页面数据适配
    self.mTabView.refreshRankList(selectid)

    -- 休战状态隐藏切换按钮
    if self.mIsInTruce then
        self.mFunctionBtns[1]:setVisible(false)
    end

    -- 加成
    local attrLabel = ConfigFunc:getMonthAddAttrStr(true, true)
    if attrLabel then
        attrLabel:setPosition(320, 960)
        self.mParentLayer:addChild(attrLabel)
    end
end

-- 创建TabLayer
function GDDHLayer:createTabLayer()
    -- 排行榜父节点
    local rankListParent = cc.Node:create()
    rankListParent:setPosition(cc.p(320, 465))
    self.mParentLayer:addChild(rankListParent)

    local groupId = {
        eOne = 1,       -- 第一组
        eTwo = 2,       -- 第二组
        eThree = 3,     -- 第三组
        eFour = 4,      -- 第四组
        eFive = 5,      -- 第五组(帮派)
    }

    -- tablayer按钮信息
    local tabBtnInfos = {
        {
            text = TR("帮派"),
            tag = groupId.eFive,
            -- customNormalImage = "wldh_27.png",
            -- customLightedImage = "wldh_26.png",
            -- customNormalTextcolor = cc.c3b(0x78, 0xb0, 0xba),
            -- customLightedTextcolor = cc.c3b(0xe1, 0xff, 0xcd),
            -- curstomNormalOutlineColor = cc.c3b(0x0f, 0x2d, 0x45),
            -- curstomLightedOutlineColor = cc.c3b(0x14, 0x42, 0x46),
        },
        {
            text = TR("个人"),
            tag = groupId.eOne,
        },
        -- {
        --     text = TR("武当"),
        --     tag = groupId.eTwo,
        -- },
        -- {
        --     text = TR("朝廷"),
        --     tag = groupId.eThree,
        -- },
        -- {
        --     text = TR("明教"),
        --     tag = groupId.eFour,
        -- },

    }

    -- 创建排行榜tablayer
    -- 若排行没有发生变化恢复页面则恢复所选择的页签
    local defaultTag = (self.mOldRank == self.mRank) and self.mSelectId or self.mGroupId or 1
    local tabLayer = ui.newTabLayer({
        btnInfos = tabBtnInfos,
        normalImage = "wldh_25.png",
        lightedImage = "wldh_24.png",
        normalTextColor = cc.c3b(0xc6, 0xa9, 0x83),
        lightedTextColor = cc.c3b(255, 239, 205),
        isVert = false,
        space = 5,
        needLine = false,
        defaultSelectTag = defaultTag,
        allowChangeCallback = function (btnTag)
            return true
        end,
        onSelectChange = function (selectBtnTag)
            self.mSelectId = selectBtnTag
            if rankListParent.refreshRankList then
                rankListParent.refreshRankList(selectBtnTag)
            end
        end
    })
    tabLayer:setAnchorPoint(cc.p(0.5, 0))
    tabLayer:setPosition(cc.p(10, -15))
    rankListParent:addChild(tabLayer, 1)

    -- 所在组标签
    -- local inTeamPosX = {
    --     165,
    --     286,
    --     407,
    --     528
    -- }
    -- local inTeamSprite = ui.newSprite("wldh_18.png")
    -- inTeamSprite:setAnchorPoint(cc.p(0.5, 0))
    -- inTeamSprite:setPosition(cc.p(inTeamPosX[self.mGroupId], 33))
    -- tabLayer:addChild(inTeamSprite)

    -- 排行榜背景
    local rankListBgSize = cc.size(640, 380)
    local rankListBgSprite = ui.newScale9Sprite("wldh_01.png", rankListBgSize)
    rankListBgSprite:setAnchorPoint(cc.p(0.5, 1))
    rankListBgSprite:setPosition(0, 10)
    rankListParent:addChild(rankListBgSprite)

    -- 创建listView父对象
    local itemList = ccui.ListView:create()
    itemList:setDirection(ccui.ScrollViewDir.vertical)
    itemList:setBounceEnabled(true)
    itemList:setContentSize(cc.size(630, 310))
    itemList:setTouchEnabled(false)
    itemList:setGravity(ccui.ListViewGravity.centerVertical)
    itemList:setItemsMargin(0)
    itemList:setAnchorPoint(cc.p(0.5, 1))
    itemList:setPosition(cc.p(rankListBgSize.width * 0.5, rankListBgSize.height * 0.88))
    itemList:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    rankListBgSprite:addChild(itemList)


    -- 刷新排行榜和所在组标签位置
    function rankListParent.refreshRankList(selectBtnTag)
        -- 清空listview
        itemList:removeAllItems()

        if selectBtnTag == groupId.eFive then
            if self.mGuildInfo and next(self.mGuildInfo) then

                for index, item in pairs(self.mGuildInfo) do
                    itemList:pushBackCustomItem(self:addGuildRankLabel(item))
                end
            else
                -- 没有帮派信息的时候,因label不是继承的node 此处做特殊处理
                local tempSize = itemList:getContentSize()
                local tempNode = cc.Node:create()
                tempNode:setPosition(cc.p(tempSize.width * 0.5, tempSize.height * 0.5))
                itemList:addChild(tempNode)

                local tempLabel = ui.newLabel({
                    text = TR("暂无帮派排行"),
                    size = 32,
                    color = cc.c3b(0x59, 0x28, 0x17),
                })
                tempNode:addChild(tempLabel)
            end
            return
        end

        -- 模板
        local stencilNode = cc.LayerColor:create(cc.c4b(0, 0, 0, 1))
        stencilNode:setContentSize(cc.size(630, 80))
        stencilNode:setIgnoreAnchorPointForPosition(false)
        stencilNode:setAnchorPoint(cc.p(0.5, 0))
        stencilNode:setPosition(itemList:getContentSize().width * 0.5, 0)

        -- 创建剪裁
        self.mClipNode = cc.ClippingNode:create()
        self.mClipNode:setContentSize(itemList:getContentSize())
        self.mClipNode:setAlphaThreshold(1.0)
        self.mClipNode:setStencil(stencilNode)
        self.mClipNode:setAnchorPoint(cc.p(0.5, 0))
        self.mClipNode:setIgnoreAnchorPointForPosition(false)
        self.mClipNode:setPosition(itemList:getContentSize().width * 0.5, 0)

        -- 特殊信息条目节点
        self.mSpecilItemNode = cc.LayerColor:create(cc.c4b(0, 0, 0, 0))
        self.mSpecilItemNode:setContentSize(cc.size(630, 80))
        self.mClipNode:addChild(self.mSpecilItemNode)

        -- 播放入场动画
        self:aniEnterSecene()

        -- 重新创建排行榜
        if selectBtnTag == self.mGroupId then
            self.mSpecilItemNode:setVisible(true)
            self.mSpecilItemNode:removeAllChildren()
            self:createOwnGroup(itemList, self.mSpecilItemNode, self.mRankListInfo[selectBtnTag])
            self:aniRankListRoll()
        else
            self.mSpecilItemNode:setVisible(false)
            local tempData = self:createListView(self.mRankListInfo[selectBtnTag])
            for index, item in ipairs(tempData) do
                itemList:pushBackCustomItem(item)
            end
        end

        -- 刷新所在组标签位置
        -- if self.mGroupId then
        --     inTeamSprite:setPosition(cc.p(inTeamPosX[self.mGroupId], 25))
        -- else
        --     inTeamSprite:setVisible(false)
        -- end

    end

    -- 排行榜滚动动画
    function rankListParent.aniRoll()
        local items = table.nums(self.mOldFourList)
        local moveDisRatio = items > 2 and items - 2 or 0
        self.mSpecilItemNode:runAction(cc.MoveBy:create(0.3, cc.p(0, moveDisRatio * -40)))
    end

    return rankListParent
end

-- 创建排行榜
-- infoData          -- 玩家数据
-- nullItems         -- 需要特殊处理的位置信息表
function GDDHLayer:createListView(infoData, nullItems)
    -- 分组数据
    local data = infoData
    -- 分组创建数据
    local tempData = {}
    -- 分组创建listview
    for index, item in ipairs(data) do
        if nullItems then
            table.insert(tempData, self:createListItem(item, nullItems))
        else
            table.insert(tempData, self:createListItem(item))
        end
    end
    return tempData
end

-- 创建普通组玩家信息
function GDDHLayer:createListItem(data, nullItems)
    -- 标签分页父节点
    local customCell = ccui.Layout:create()
        customCell:setContentSize(cc.size(630, 40))

    local tempSize = customCell:getContentSize()

    -- label为奇数的有背景条
    local tempRank = data.Rank > EachGroupNum and EachGroupNum or data.Rank
    if tempRank % 2 == 1 then
        local tempBg = ui.newScale9Sprite("wldh_02.png", cc.size(550, 40))
        tempBg:setAnchorPoint(cc.p(0.5, 0.5))
        tempBg:setPosition(cc.p(tempSize.width * 0.5, tempSize.height * 0.5))
        customCell:addChild(tempBg)
    end

    -- 特殊情况返回空的layout
    if nullItems then
        for i, v in pairs(nullItems) do
            if data.Rank == v then
                return customCell
            end
        end
    end

    -- 设置标签颜色
    if data.Name == PlayerAttrObj:getPlayerAttrByName("PlayerName") and data.Rank > 3 then
        textColor = self:getLabelColor(0)
    else
        textColor = self:getLabelColor(data.Rank)
    end

    -- 排名
    local label1 = ui.newLabel({
        text = data.Rank,
        color = textColor,
        align = ui.TEXT_ALILGN_CENTER,
    })
    label1:setAnchorPoint(cc.p(0.5, 0.5))
    label1:setPosition(cc.p(80, tempSize.height * 0.5))
    customCell:addChild(label1)

    -- 前三名显示圆圈
    if data.Rank <= 3 then
        local picName = nil
        if data.Rank == 1 then
            picName = "c_44.png"
        elseif data.Rank == 2 then
            picName = "c_45.png"
        elseif  data.Rank == 3 then
            picName = "c_46.png"
        end

        local spr = ui.newSprite(picName)
        spr:setAnchorPoint(cc.p(0.5, 0.5))
        spr:setPosition(label1:getPosition())
        customCell:addChild(spr)
        spr:setScale(0.6)
    end

    -- 名字
    local label2 = ui.newLabel({
        text = data.Name,
        color = textColor,
    })
    label2:setAnchorPoint(cc.p(0, 0.5))
    label2:setPosition(cc.p(120, tempSize.height * 0.5))
    customCell:addChild(label2)

    -- 积分
    local label3 = ui.newLabel({
        text = TR("积分:%s", data.Integral),
        color = textColor,
    })
    label3:setAnchorPoint(cc.p(0, 0.5))
    label3:setPosition(cc.p(280, tempSize.height * 0.5))
    customCell:addChild(label3)

    -- 帮派
    local tempName = (data.GuildName == "" or data.GuildName == nil) and TR("暂无帮派") or data.GuildName
    local label4 = ui.newLabel({
        text = tempName,
        color = textColor,
    })
    label4:setAnchorPoint(cc.p(0.5, 0.5))
    label4:setPosition(cc.p(500, tempSize.height * 0.5))
    customCell:addChild(label4)

    function customCell.aniRoll()
        self:changeValue(self.mOldRank, self.mRank, label1, customCell)
    end

    return customCell
end

-- 创建特殊处理的玩家信息
function GDDHLayer:createSpecilItem(data)
    -- 标签分页父节点
    local customCell = cc.Node:create()
        customCell:setContentSize(cc.size(630, 40))

    local tempSize = customCell:getContentSize()

    -- label为奇数的有背景条
    local tempRank = self.mRank > EachGroupNum and EachGroupNum or self.mRank
    local tempRankCorrect = math.abs(tempRank - math.abs(data.Rank - self.mRank))
    if tempRankCorrect % 2 == 1 then
        local tempBg = ui.newScale9Sprite("wldh_02.png", cc.size(550, 40))
        tempBg:setAnchorPoint(cc.p(0.5, 0.5))
        tempBg:setPosition(cc.p(tempSize.width * 0.5, tempSize.height * 0.5))
        customCell:addChild(tempBg)
    end

    -- 特殊情况返回空的layout
    if nullItems then
        for i, v in pairs(nullItems) do
            if data.Rank == v then
                return customCell
            end
        end
    end

    -- 设置标签颜色
    if data.Name == PlayerAttrObj:getPlayerAttrByName("PlayerName") and data.Rank > 3 then
        textColor = self:getLabelColor(0)
    else
        textColor = self:getLabelColor(data.Rank)
    end

    -- 排名
    local label1 = ui.newLabel({
        text = data.Rank,
        color = textColor,
        align = ui.TEXT_ALILGN_CENTER,
    })
    label1:setAnchorPoint(cc.p(0.5, 0.5))
    label1:setPosition(cc.p(80, tempSize.height * 0.5))
    customCell:addChild(label1)

    -- 前三名显示圆圈
    if data.Rank <= 3 then
        local picName = nil
        if data.Rank == 1 then
            picName = "c_44.png"
        elseif data.Rank == 2 then
            picName = "c_45.png"
        elseif  data.Rank == 3 then
            picName = "c_46.png"
        end

        local spr = ui.newSprite(picName)
        spr:setAnchorPoint(cc.p(0.5, 0.5))
        spr:setPosition(label1:getPosition())
        customCell:addChild(spr)
        spr:setScale(0.6)
    end

    -- 名字、积分
    local label2 = ui.newLabel({
        text = data.Name,
        color = textColor,
    })
    label2:setAnchorPoint(cc.p(0, 0.5))
    label2:setPosition(cc.p(120, tempSize.height * 0.5))
    customCell:addChild(label2)

    local label3 = ui.newLabel({
        text = TR("积分:%s", data.Integral),
        color = textColor,
    })
    label3:setAnchorPoint(cc.p(0, 0.5))
    label3:setPosition(cc.p(280, tempSize.height * 0.5))
    customCell:addChild(label3)

    -- 帮派
    local tempName = (data.GuildName == "" or data.GuildName == nil) and TR("暂无帮派") or data.GuildName
    local label4 = ui.newLabel({
        text = tempName,
        color = textColor,
    })
    label4:setAnchorPoint(cc.p(0.5, 0.5))
    label4:setPosition(cc.p(500, tempSize.height * 0.5))
    customCell:addChild(label4)

    return customCell
end

-- 创建排行榜视图条目，这个条目包含4个label，用于帮派分组
--[[
    params:
    parent                  -- 4个label的父节点
    Table data =
    {
        Rank                -- 名次
        Lv                  -- 等级
        Name                -- 玩家名
        Guild               -- 帮派
        Integral            -- 玩家积分
    }
--]]
function GDDHLayer:addGuildRankLabel(data)
   -- 标签分页父节点
    local customCell = ccui.Layout:create()
        customCell:setContentSize(cc.size(630, 40))

    local tempSize = customCell:getContentSize()

    -- label为奇数的有背景条
    local tempRank = data.Rank > EachGroupNum and EachGroupNum or data.Rank
    if tempRank % 2 == 1 then
        local tempBg = ui.newScale9Sprite("wldh_02.png", cc.size(550, 40))
        tempBg:setAnchorPoint(cc.p(0.5, 0.5))
        tempBg:setPosition(cc.p(tempSize.width * 0.5, tempSize.height * 0.5))
        customCell:addChild(tempBg)
    end

    -- 设置标签颜色
    if data.Name == PlayerAttrObj:getPlayerAttrByName("PlayerName") and data.Rank > 3 then
        textColor = self:getLabelColor(0)
    else
        textColor = self:getLabelColor(data.Rank)
    end

    -- 排名
    local label1 = ui.newLabel({
        text = data.Rank,
        color = textColor,
        align = ui.TEXT_ALILGN_CENTER,
    })
    label1:setAnchorPoint(cc.p(0.5, 0.5))
    label1:setPosition(cc.p(80, tempSize.height * 0.5))
    customCell:addChild(label1)

    -- 前三名显示圆圈
    if data.Rank <= 3 then
        local picName = nil
        if data.Rank == 1 then
            picName = "c_44.png"
        elseif data.Rank == 2 then
            picName = "c_45.png"
        elseif  data.Rank == 3 then
            picName = "c_46.png"
        end

        local spr = ui.newSprite(picName)
        spr:setAnchorPoint(cc.p(0.5, 0.5))
        spr:setPosition(label1:getPosition())
        customCell:addChild(spr)
        spr:setScale(0.6)
    end
    -- 等级
    local label2 = ui.newLabel({
        text = TR("等级:%s", data.LV),
        color = textColor,
    })
    label2:setPosition(cc.p(145, tempSize.height * 0.5))
    customCell:addChild(label2)

    -- 帮派名字
    local tempName = data.GuildName == "" and TR("暂无帮派") or data.GuildName
    local label3 = ui.newLabel({
        text = tempName,
        color = textColor,
    })
    label3:setAnchorPoint(cc.p(0.5, 0.5))
    label3:setPosition(cc.p(325, tempSize.height * 0.5))
    customCell:addChild(label3)

    -- 积分
    local label4 = ui.newLabel({
        text = TR("积分:%s", data.Integral),
        color = textColor,
    })
    label4:setAnchorPoint(cc.p(0, 0.5))
    label4:setPosition(cc.p(450, tempSize.height * 0.5))
    customCell:addChild(label4)
    return customCell
end

-- 创建自己分组排行榜
--[[
    params:
        parent              -- 普通创建条目父对象
        specielParent       -- 特殊条目创建父对象
        data                -- 选择的组号
--]]
function GDDHLayer:createOwnGroup(parent, specielParent, data)
    if self.mRank >= EachGroupNum and not self.mIsInTruce then
        print("创建特殊分组")
        -- 只有在未休战并且排名大于等于6才特殊创建，其他情况均直接创建
        -- 创建普通数据条目
        local tempData = self:createListView(data, {6, 7})
        self.mPlayerItem = tempData[#tempData]

        -- 玩家条目前两名玩家信息容错处理
        if self.mOldFourList and next(self.mOldFourList) and self.mAlreadyPlayRank then
            local tempNum = table.nums(self.mOldFourList)
            local tempDelNum = tempNum > 2 and tempNum - 2 or 0
            for i = 1, tempDelNum do
                table.remove(self.mOldFourList, #self.mOldFourList)
            end
        end

        -- 创建特殊数据条目
        local tempSpecilData = {}
        for index, item in ipairs(self.mOldFourList) do
            local tempitem = self:createSpecilItem(item)
            tempitem:setPosition(cc.p(0, 40 * (#self.mOldFourList - index)))
            table.insert(tempSpecilData, tempitem)
        end

        -- 加入普通数据条目
        for index, item in ipairs(tempData) do
            parent:pushBackCustomItem(item)
        end

        -- 加入特殊数据条目
        for index, item in ipairs(tempSpecilData) do
            specielParent:addChild(item)
        end
        tempData[7]:addChild(self.mClipNode)
    else
        print("创建普通分组")
        local tempData = self:createListView(data)
        self.mPlayerDataList = tempData

        for index, item in ipairs(tempData) do
            parent:pushBackCustomItem(item)
        end
    end
end

-- 创建玩家形象(挑战次数信息)
function GDDHLayer:createPlayer()
    -- 玩家人物形象父节点
    local playerFigureNode = cc.Node:create()
    playerFigureNode:setPosition(cc.p(500, 510))
    self.mParentLayer:addChild(playerFigureNode)

    -- 玩家状态信息父节点
    local stateInfoNode = cc.Node:create()
    playerFigureNode:addChild(stateInfoNode)

    -- 刷新玩家状态信息
    function playerFigureNode.refreshNodeInfo()
        -- 刷新前先移除所有子节点
        stateInfoNode:removeAllChildren()
        if self.mIsInTruce then
            -- 创建挑战信息背景
            -- local playerInfoBgSprite = ui.newScale9Sprite("wldh_04.png", cc.size(230,60))
            -- stateInfoNode:addChild(playerInfoBgSprite)
            -- playerInfoBgSprite:setAnchorPoint(cc.p(0.5, 1))
            -- local tempSize = playerInfoBgSprite:getContentSize()

            -- 创建开战倒计时
            local fightLastTime = ui.newLabel({
                text = TR("开战倒计时: 00:00:00"),
                color = Enums.Color.eNormalWhite,
                align = ui.TEXT_ALILGN_CENTER,
                size = 20,
                outlineColor = Enums.Color.eOutlineColor,
                outlineSize = 2,
            })
            fightLastTime:setPosition(cc.p(320, 558))
            self.mParentLayer:addChild(fightLastTime)

            -- 开战倒计时创建计时器
            self.mStartRaceScheId = Utility.schedule(stateInfoNode,
                function()
                    self:updateStartGddhTime(self.mSignupInfo.BeginDate, fightLastTime)
                end,
                1.0
            )
        else
            --背景
            local playerInfoBgSprite = ui.newScale9Sprite("wldh_28.png", cc.size(290,60))
            stateInfoNode:addChild(playerInfoBgSprite)
            playerInfoBgSprite:setPosition(-10, 10)
            playerInfoBgSprite:setAnchorPoint(cc.p(0.5, 1))

            local maxBuyCount = GddhBuynumRelation.items_count
            local buyFightNumBtn = ui.newButton({
                normalImage = "gd_27.png",
                clickAction = function()
                    if self.mBuyRankCount >= maxBuyCount then
                        ui.showFlashView(TR("今天购买挑战次数的机会已经用完啦！"))
                        return
                    end
                    MsgBoxLayer.buyGDDHCountHintLayer(self.mBuyRankCount, maxBuyCount,function(count)
                        self:requestBuyRankCount(count)
                    end)
                end
                })
            buyFightNumBtn:setPosition(95, -20)
            stateInfoNode:addChild(buyFightNumBtn)
            -- 创建玩家挑战次数
            local challengNumLabel = ui.newLabel({
                text = "",
                color = Enums.Color.eNormalWhite,
                align = ui.TEXT_ALIGN_CENTER,
                size = 20,
                outlineColor = Enums.Color.eOutlineColor,
                outlineSize = 2,
            })
            challengNumLabel:setPosition(cc.p(-30, -5))
            challengNumLabel.resetShow = function (target)
                target:setString(TR("剩余挑战次数: %s%d / %d", "#abf37f", self.mRankCount, 10))
            end
            stateInfoNode:addChild(challengNumLabel)
            self.challengNumLabel = challengNumLabel
            self.challengNumLabel:resetShow()

            -- 下次挑战恢复时间
            local challengeResumeLabel = ui.newLabel({
                text = "",
                color = Enums.Color.eNormalWhite,
                align = ui.TEXT_ALIGN_CENTER,
                size = 20,
                outlineColor = Enums.Color.eOutlineColor,
                outlineSize = 2,
            })
            challengeResumeLabel:setAnchorPoint(cc.p(0.5, 0.5))
            challengeResumeLabel:setPosition(cc.p(-30, -32))
            challengeResumeLabel.resetShow = function (target)
                if self.mRankCount >= 10 then
                    target:setString(TR("挑战次数已满"))
                    playerFigureNode:stopAction(self.mChallengeResScheId)
                    self.mChallengeResScheId = nil
                    return
                end

                local timeLeft = self.mLastRecoveTime - Player:getCurrentTime()
                if timeLeft > 0 then
                    target:setString(TR("挑战恢复时间: %s%s", "#abf37f", MqTime.formatAsHour(timeLeft)))
                else
                    target:setString(TR("挑战恢复时间: #abf37f00:00:00"))
                    self:requestGetWrestleRaceInfo()
                end
            end
            stateInfoNode:addChild(challengeResumeLabel)
            self.challengeResumeLabel = challengeResumeLabel

            if not self.mChallengeResScheId then
                self.mChallengeResScheId = Utility.schedule(playerFigureNode, function ()
                    self.challengeResumeLabel:resetShow()
                end, 1.0)
            end
        end
    end

    playerFigureNode.refreshNodeInfo()

    return playerFigureNode
end

-- 创建挑战玩家形象
--[[
    params:
        playerInfo :            挑战玩家信息
        stdInfo :               玩家位置大小信息
        index :                 休战状态玩家的排名顺序,未休战状态可不传
--]]
function GDDHLayer:createChallengePlayer(playerInfo, stdInfo, index)
    -- 创建挑战玩家形象父节点
    local challengeFigureNode = cc.Node:create()
    challengeFigureNode:setPosition(stdInfo.position)
    self.mBgSprite:addChild(challengeFigureNode)

    -- 创建挑战玩家形象子父节点,用于刷新时清空节点
    local challengeFigureSubNode = cc.Node:create()
    challengeFigureNode:addChild(challengeFigureSubNode)

    -- 点击处理事件
    local function doClickCallback(clickPlayerInfo)
        -- 休战时，直接返回
        if self.mIsInTruce then
            return
        end
        -- 没有挑战次数了
        if self.mRankCount == 0 then
            local buyConfig = GddhBuynumRelation.items[self.mBuyRankCount + 1]
            local maxBuyCount = GddhBuynumRelation.items_count
            if buyConfig then
                MsgBoxLayer.buyGDDHCountHintLayer(self.mBuyRankCount, maxBuyCount,function(count)
                    self:requestBuyRankCount(count)
                end)
            else
                ui.showFlashView({text = TR("今天购买挑战次数的机会已经用完啦！")})
            end
        else
            -- 耐力不够
            local isEnough = Utility.isResourceEnough(ResourcetypeSub.eSTA, 2, true)
            if isEnough then
                if self.mRewardTime1 == 23 and self.mRewardTime2 >= 30 and self.mRewardTime3 >= 0 then
                    MsgBoxLayer.addOKLayer(TR("23点-23点半为发奖时间，请稍等"))
                else
                    self:requestRankWrestleRace(clickPlayerInfo, 0)
                end
            end
        end
    end

    btnAction = function(info)
        doClickCallback(playerInfo)
    end

    -- 创建挑战玩家形象
    local challengeFigureHero = nil
    local function createPlayerFigure(tmpPlayerInfo, tmpAction)
        challengeFigureHero = Figure.newHero({
            heroModelID = tmpPlayerInfo.HeadImageId,
            fashionModelID = tmpPlayerInfo.FashionModelId,
            IllusionModelId = tmpPlayerInfo.IllusionModelId,
            scale = stdInfo.scale,
            parent = challengeFigureSubNode,
            position = cc.p(0,0),
            needAction = true,
            swallow = true,
            buttonAction = tmpAction
        })
        -- challengeFigureSubNode:setRotationSkewY(180)

        function challengeFigureNode.addClickAction()
            challengeFigureHero.button:setClickAction(tmpAction)
        end
    end
    createPlayerFigure(playerInfo, btnAction)
    -- 保存引导使用
    challengeFigureNode.heroBtn = challengeFigureHero.button

    local underShadowSprite = ui.newSprite("ef_c_67.png")
    underShadowSprite:setPosition(0,20)
    challengeFigureNode:addChild(underShadowSprite)

    -- 创建挑战玩家信息背景
    local infoBg = ui.newScale9Sprite("wldh_05.png", cc.size(180, 65))
    local tempSize = infoBg:getContentSize()
    infoBg:setAnchorPoint(cc.p(0.5, 0.8))
    challengeFigureNode:addChild(infoBg)

     -- 创建"同组"标签
    -- local sameGroupLabel = ui.newSprite("wldh_19.png")
    -- sameGroupLabel:setAnchorPoint(cc.p(1, 0.5))
    -- sameGroupLabel:setPosition(cc.p(5, tempSize.height * 0.5))
    -- infoBg:addChild(sameGroupLabel)
    -- sameGroupLabel:setVisible(playerInfo.GroupId == self.mGroupId)
    -- 等级
    local heroLv = "Lv"..playerInfo.Lv
    -- 创建挑战玩家名字信息
    local nameLabel = ui.newLabel({
        text = heroLv..playerInfo.Name,
        color = cc.c3b(0x4c, 0x18, 0x25),
        align = ui.TEXT_ALILGN_CENTER,
        size = 20
    })
    nameLabel:setAnchorPoint(cc.p(0.5, 0.5))
    nameLabel:setPosition(cc.p(90, tempSize.height * 0.74))
    infoBg:addChild(nameLabel)

    -- 创建玩家帮派名字
    local tempName = (playerInfo.GuildName == "" or playerInfo.GuildName == nil) and TR("暂无帮派") or playerInfo.GuildName
    local guildNameLabel = ui.newLabel({
        text = tempName,
        color = cc.c3b(0xfe, 0xe8, 0x97),
        size = 20
    })
    guildNameLabel:setPosition(cc.p(tempSize.width * 0.5, tempSize.height * 0.25))
    infoBg:addChild(guildNameLabel)

    -- 未休战才创建挑战玩家信息,以及后续功能
    if self.mIsInTruce then
        -- 创建前三名特效
        local rankImage = {"hslj_23.png", "hslj_22.png", "hslj_24.png", "hslj_25.png"}
        -- local rankEffect = ui.newEffect({
        --     parent = challengeFigureNode,
        --     effectName = "effect_ui_longfengtian",
        --     position = cc.p(0, 160),
        --     loop = true,
        --     animation = rankImage[index],
        --     endRelease = false,
        --     startListener = function()
        --     end,
        --     completeListener = function()
        --     end
        -- })
        local rankSprite = ui.newSprite(rankImage[index])
        rankSprite:setPosition(cc.p(0, 140))
        challengeFigureNode:addChild(rankSprite)

        -- 创建"休战中""
        local truceSprite = ui.newSprite("wldh_23.png")
        truceSprite:setPosition(cc.p(0, 40))
        challengeFigureNode:addChild(truceSprite)

        return challengeFigureNode
    end
    -- 创建快速战斗图
    local hintSprite = ui.newSprite("wldh_29.png")
    hintSprite:setPositionY(130)
    challengeFigureNode:addChild(hintSprite)
    hintSprite:runAction(cc.RepeatForever:create(cc.Sequence:create({
        cc.ScaleTo:create(0.4, 0.7),
        cc.ScaleTo:create(0.4, 1),
    })))

    -- 超高积分,默认只有玩家显示
    local highIntegraSprite = ui.newSprite("wldh_22.png")
    highIntegraSprite:setPosition(cc.p(65, 215))
    challengeFigureNode:addChild(highIntegraSprite)
    highIntegraSprite:setVisible(playerInfo.HighValueMin)

    -- 清空挑战节点
    function challengeFigureNode.clearChallengNode()
        challengeFigureSubNode:removeAllChildren()
        challengeFigureNode:setVisible(false)
    end

    -- 刷新节点信息
    function challengeFigureNode.refreshChallengeNode(newPlayerInfo, stdInfo)
        -- 休战状态直接返回
        if self.mIsInTruce then
            return
        end

        local btnAction = function(info)
            doClickCallback(newPlayerInfo)
        end

        -- 创建挑战玩家形象
        createPlayerFigure(newPlayerInfo, btnAction)

        -- 刷新名字标签
        -- 等级
        local heroLv = "Lv"..newPlayerInfo.Lv
        nameLabel:setString(heroLv..newPlayerInfo.Name)

        -- 刷新帮派名字
        local tempName = (newPlayerInfo.GuildName == "" or newPlayerInfo.GuildName == nil) and TR("暂无帮派") or newPlayerInfo.GuildName
        guildNameLabel:setString(tempName)

        -- 设置同组标签显示状态
        -- sameGroupLabel:setVisible(newPlayerInfo.GroupId == self.mGroupId)

        -- 设置超高积分标签显示与否,默认只有玩家显示
        highIntegraSprite:setVisible(newPlayerInfo.HighValueMin)

        -- 设置第一名特效显示状态
        if firstRankEffect then
            firstRankEffect:setVisible(self.mIsInTruce)
        end

        challengeFigureNode:setVisible(true)
    end

    -- 设置figure空点击事件
    function challengeFigureNode.nullClickAction()
        challengeFigureHero.button:setClickAction(function () end)
    end

    -- figure淡入动画
    function challengeFigureNode.fadeIn(delayTime)
        challengeFigureHero:runAction(cc.FadeIn:create(delayTime))
    end

    -- 设置figure透明度
    function challengeFigureNode.setOpacity(opacity)
        challengeFigureHero:setOpacity(opacity)
    end

    return challengeFigureNode
end

-- 创建页面功能性按钮
function GDDHLayer:createFunctionBtn()
    -- 功能性按钮层
    local funcParentLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 0))
    funcParentLayer:setContentSize(cc.size(640, 1136))
    funcParentLayer:setAnchorPoint(cc.p(0, 0))
    self.mParentLayer:addChild(funcParentLayer, 100)

    -- 更换按钮功能
    local changeFunc = function(btnObj)
        btnObj:setEnabled(false)
        self:requestRefreshWrestleRaceRankList(btnObj)
    end

    -- 更换按钮
    local changeBtn = ui.newButton({
        normalImage = "wldh_06.png",
        position = cc.p(320, 570),
        clickAction = changeFunc
    })
    changeBtn:setVisible(false)
    funcParentLayer:addChild(changeBtn)

    -- 返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(584, 1040),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    closeBtn:setVisible(false)
    funcParentLayer:addChild(closeBtn)

    -- 更换按钮，关闭按钮
    return {changeBtn, closeBtn}
end

-- 创建页面非功能性导航按钮
function GDDHLayer:createOptBtn()
    -- 导航按钮背景条
    local navBgSprite = ui.newScale9Sprite("wldh_03.png", cc.size(640, 110))
    navBgSprite:setAnchorPoint(cc.p(0.5, 0))
    navBgSprite:setPosition(cc.p(self.mBgSize.width * 0.5, 980))
    self.mParentLayer:addChild(navBgSprite, 10)

    local tempParentSize = navBgSprite:getContentSize()

    -- 按钮坐标信息
    local optBtnPositionInfo = {
        pOptSubBg = cc.p(135, 0),
        pBattleReportBtn = cc.p(tempParentSize.width * 0.24, tempParentSize.height * 0.5),
        pRankListBtn = cc.p(tempParentSize.width * 0.39, tempParentSize.height * 0.5),
        pExChangeBtn = cc.p(tempParentSize.width * 0.54, tempParentSize.height * 0.5),
        pRuleBtn = cc.p(tempParentSize.width * 0.69, tempParentSize.height * 0.5)
    }

    -- 战报按钮功能
    local battleReportFunc = function()
        HttpClient:request({
            moduleName = "Gddh",
            methodName = "GetWrestleRaceReviveList",
            callbackNode = self,
            callback = function (response)
                if response.Status == 0 then
                    -- 保存数据，格斗大会复仇信息
                    self.mWrestleRaceReviveInfo = clone(response.Value)
                    -- dump(response.Value, "复仇列表")
                    local layerParams = {
                        dataList = self.mWrestleRaceReviveInfo,
                        buyRankCount = self.mBuyRankCount,
                        rankCount = self.mRankCount,
                        perNum = self.mPerNum
                    }
                    local layer = LayerManager.addLayer({
                        name = "challenge.GDDHReportLayer",
                        data = layerParams,
                        cleanUp = false,
                    })
                end
            end
        })
    end

    -- 战报按钮
    local battleReportBtn = ui.newButton({
        normalImage = "tb_121.png",
        anchorPoint = cc.p(0, 0.5),
        position = optBtnPositionInfo.pBattleReportBtn,
        clickAction = battleReportFunc
    })
    navBgSprite:addChild(battleReportBtn)

    -- 排行榜按钮
    local rankListBtn = ui.newButton({
        normalImage = "tb_16.png",
        anchorPoint = cc.p(0, 0.5),
        position = optBtnPositionInfo.pRankListBtn,
        clickAction = function()
            local layerParams = {
                        groupId = self.mGroupId,               -- 组号
                        rank = self.mRank,
                        integral = self.mIntegral,             -- 名次
                        signupData = self.mSignupInfo,
                        selectedBtn = 1,
                        guildInfo = self.mGuildInfo
                    }
                    local layer = LayerManager.addLayer({
                        name = "challenge.GDDHRankLayer",
                        data = layerParams
                    })
            end
        })
    navBgSprite:addChild(rankListBtn)

    -- 兑换按钮
    local exchangeBtn = ui.newButton({
        normalImage = "tb_27.png",
        anchorPoint = cc.p(0, 0.5),
        position = optBtnPositionInfo.pExChangeBtn,
        clickAction = function()
        local layerParams = {
                    histortRank = self.mHistortRank,
                    signupData = self.mSignupInfo
                }
                local layer = LayerManager.addLayer({
                    name = "challenge.GGDHShopLayer",
                    data = layerParams
                })
        end
        })
    navBgSprite:addChild(exchangeBtn)
    -- 保存按钮，引导使用
    self.exchangeBtn = exchangeBtn

    -- 兑换商店注册小红点
    local function dealRedDotVisible(redDotSprite)
        local redDotData = RedDotInfoObj:isValid(ModuleSub.eGDDHShop)
        redDotSprite:setVisible(redDotData)
    end
    ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = RedDotInfoObj:getEvents(ModuleSub.eGDDHShop), parent = exchangeBtn})

    -- 规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "tb_127.png",
        anchorPoint = cc.p(0, 0.5),
        position = optBtnPositionInfo.pRuleBtn,
        clickAction = function()
            local rulesData = {
                [1] = TR("1.每周二到周三，周四到周五，周六到下周周一为一个赛季"),
                [2] = TR("2.每周二、周四和周六早上9点可开始报名挑战"),
                [3] = TR("3.每日23:00到23:30为结算时间，不能进行挑战"),
                [4] = TR("4.挑战对手胜利后可获得积分，对手扣除积分"),
                [5] = TR("5.根据积分高低进行排名，积分越高结算时获得奖励越高"),
                [6] = TR("6.每个人赛季奖励结算后，积分将重置为初始积分即1000"),
                [7] = TR("7.每次赛季在武林大会中挑战获得一定次数的胜利后即可获得保底奖励"),
                [8] = TR("8.武林大会挑战可获得豪侠令，用于兑换各种奖励")
            }
            MsgBoxLayer.addRuleHintLayer(TR("规则提示"), rulesData, cc.size(545, 474))
        end
    })
    navBgSprite:addChild(ruleBtn)

    -- 帮派按钮，战报按钮，排行榜按钮，兑换按钮， 规则按钮
    return {battleReportBtn, rankListBtn, exchangeBtn, ruleBtn}
end

-- 创建页面信息标签
function GDDHLayer:createInfoLabel()
    -- 下次奖励时间
    local nextRewardLabel = ui.newLabel({
        text = "",
        color = cc.c3b(0xff, 0xf7, 0xd1),
        outlineColor = cc.c3b(0x8a, 0x4a, 0x2b),
        align = ui.TEXT_ALIGN_CENTER,
        size = 22
    })
    nextRewardLabel:setAnchorPoint(cc.p(0, 0.5))
    nextRewardLabel:setPosition(cc.p(15, 960))
    self.mParentLayer:addChild(nextRewardLabel)

    -- 刷新赛季下次奖励时间
    --[[
        params:
            firstTime           -- 第一次发奖时间
            endTime             -- 最后一次发奖时间
    --]]
    function updateNextRewardTime(firstTime, endTime)
        -- 开奖倒计时
        local day, hours, minutes, seconds = MqTime.toHour(endTime - Player:getCurrentTime())
        self.mRewardTime1 = hours
        self.mRewardTime2 = minutes
        self.mRewardTime3 = seconds

        local timeLeft = 0
        if (firstTime - Player:getCurrentTime()) > 0 then
            timeLeft = firstTime - Player:getCurrentTime()
            local str = MqTime.formatAsDay(timeLeft)
            nextRewardLabel:setString(TR("赛季大奖: %s", str))
        elseif (endTime - Player:getCurrentTime()) > 0 then
            timeLeft = endTime - Player:getCurrentTime()
            local str = MqTime.formatAsDay(timeLeft)
            nextRewardLabel:setString(TR("赛季大奖: %s", str))
        else
            if self.mNextRewardScheId then
                self:stopAction(self.mNextRewardScheId)
                self.mNextRewardScheId = nil
            end

            MsgBoxLayer.addOKLayer(
                TR("奖励结算中,请稍后再进行挑战"),
                TR("提示"),
                {{
                    text = TR("确定"),
                    textColor = Enums.Color.eWhite,
                    clickAction = function(layerObj, btnObj)
                        LayerManager.removeLayer(layerObj)
                    end
                }},
                {}
            )
        end
    end

    -- 下次奖励时间计时器
    if not self.mNextRewardScheId then
        self.mNextRewardScheId =  Utility.schedule(
        self,
        function()
            updateNextRewardTime(self.mSignupInfo.FirstRewardDate, self.mSignupInfo.EndRewardDate)
        end,
        1.0)
    end

    -- 单次消耗耐力
    local tempPic = Utility.getResTypeSubImage(ResourcetypeSub.eSTA)
    local tempLabel = ui.newLabel({
        text = TR("挑战消耗:{%s}2", tempPic),
        outlineColor = Enums.Color.eOutlineColor,
        outlineSize = 2,
    })
    tempLabel:setPosition(cc.p(545, 960))
    self.mParentLayer:addChild(tempLabel)
end

-- 创建宝箱按钮,此按钮较为特殊,故与界面ui分开创建
function GDDHLayer:createChestBtn()
    -- 宝箱按钮功能
    -- 奖励预览
    local chestPreview = function()
        -- 预览序列号
        local tempList = {}
        for i, _ in pairs(self.mChestRewardConfig) do
            tempList[i] = self.mChestRewardConfig[i].needAttNums
        end
        tempList[#self.mChestRewardConfig + 1] = self.mPerRankCount
        table.sort(tempList, function(a, b)
            return a < b
        end)
        local tempIndex = #self.mChestRewardConfig
        for i, _ in pairs(tempList) do
            if _ == self.mPerRankCount then
                tempIndex = i
            end
        end

        -- 展示宝箱内容
        local rewardList =  Utility.analysisStrResList(self.mChestRewardConfig[tempIndex].reward)
        MsgBoxLayer.addPreviewDropLayer(
            rewardList,
            TR("挑战次数达到%d次可以领取", self.mChestRewardConfig[tempIndex].needAttNums),
            TR("%s宝箱预览", Enums.Color.eWhiteH),
            {btnInfo},
            {}
        )
    end

    -- 领取奖励
    local chestReward = function()
        print("reward")
        self:requestRaceiveReward(self.mReceiveIdList)
    end

    -- 宝箱按钮父节点
    local chestParentNode = cc.Node:create()
    chestParentNode:setPosition(cc.p(65, 1050))
    self.mParentLayer:addChild(chestParentNode, 11)

    -- 宝箱按钮
    local chestBtn = ui.newButton({
        normalImage = "r_07.png",
        disabledImage = "r_12.png",
        clickAction = function()
        end
    })
    chestBtn:setPosition(cc.p(5, -10))
    chestParentNode:addChild(chestBtn)

    -- 宝箱按钮小红点
    local function dealRedDotVisible(redDotSprite)
        local redDotData = RedDotInfoObj:isValid(ModuleSub.eChallengeWrestle, "RewardBox")
        redDotSprite:setVisible(redDotData)
    end
    ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = RedDotInfoObj:getEvents(ModuleSub.eChallengeWrestle, "RewardBox"), parent = chestBtn})

    -- 宝箱领取信息节点
    local chestInfoBgSprite = ui.newScale9Sprite("c_24.png", cc.size(80, 30))
    chestInfoBgSprite:setPosition(cc.p(5, -50))
    chestParentNode:addChild(chestInfoBgSprite)

    local chestInfoLabel = ui.newLabel({
        text = string.format("%d/%d", 0, 0),
        size = 20,
        outlineColor = Enums.Color.eBlack,
    })
    chestInfoLabel:setPosition(cc.p(5, -50))
    chestParentNode:addChild(chestInfoLabel)

    -- 刷新宝箱领取状态状态
    function chestParentNode.refreshChestState()
        if self.mChestState == Enums.RewardStatus.eNotAllow then
            chestBtn:stopAllActions()
            chestBtn:removeAllChildren()
            chestBtn:setRotation(0)
            chestBtn:setEnabled(true)
            chestBtn:setClickAction(chestPreview)
            chestBtn:setPosition(cc.p(5, -10))
        elseif self.mChestState == Enums.RewardStatus.eAllowDraw then
            chestBtn:setEnabled(true)
            chestBtn:setClickAction(chestReward)
            chestBtn:setPosition(cc.p(5, -10))
            ui.setWaveAnimation(chestBtn)
        elseif self.mChestState == Enums.RewardStatus.eHadDraw then
            chestBtn:stopAllActions()
            chestBtn:removeAllChildren()
            chestBtn:setRotation(0)
            chestBtn:setEnabled(false)
            chestBtn:setPosition(cc.p(5, -20))
        else
            print("chestStateError")
            return
        end
    end

    -- 刷新宝箱领取标签
    function chestParentNode.refreshChestInfoLabel()
        -- 宝箱进度值
        if self.mIsInTruce then
            chestInfoBgSprite:setVisible(false)
            chestInfoLabel:setVisible(false)
            chestParentNode.refreshChestState()
            return chestParentNode
        end

        -- 配置表中能领取宝箱的最大挑战次数
        local maxRewardNum = self.mChestRewardConfig[#self.mChestRewardConfig].needAttNums

        -- 目前最大的能领取次数
        local rewardIndex = 0
        for index, item in ipairs(self.mChestRewardConfig) do
            if self.mPerRankCount == 0 then
                rewardIndex = self.mChestRewardConfig[1].needAttNums
                break
            end

            if self.mPerRankCount < item.needAttNums then
                rewardIndex = item.needAttNums
                break
            end

            rewardIndex = maxRewardNum
        end

        -- 刷新宝箱进度显示
        local tempNum = self.mPerRankCount >= maxRewardNum and maxRewardNum or self.mPerRankCount
        chestInfoLabel:setString(string.format("%d / %d", tempNum, rewardIndex))
    end

    chestParentNode.refreshChestState()
    return chestParentNode
end

-- 设置所有元素场外坐标
function GDDHLayer:setAllItemPosition()
    if not self.mNeedAction then
        return
    end

    -- 战斗按钮，更换按钮，关闭按钮
    self.mFunctionBtns[1]:setPositionX(self.mFunctionBtns[1]:getPositionX() + 100)
    self.mFunctionBtns[2]:setPositionY(self.mFunctionBtns[2]:getPositionY() + 100)
    -- 帮派按钮，战报按钮，排行榜按钮，兑换按钮， 规则按钮
    for _, item in ipairs(self.mNonFunctionBtns) do
        item:setPositionY(item:getPositionY() - 300)
    end

    self.mChestBtnNode:setPositionY(self.mChestBtnNode:getPositionY() - 300)
    self.mTabView:setPositionY(self.mTabView:getPositionY() + 500)
    for index, item in pairs(self.challengPlayerNodeList) do
        item:setPositionY(item:getPositionY() + 200)
        item.setOpacity(0)
    end
end

--========================功能性函数=============================
-- 排行榜中的标签颜色，序号不同，颜色不同
-- -1:默认颜色 0:玩家自己的颜色 1~3:前三名的标签颜色
function GDDHLayer:getLabelColor(index)
    local color = nil
    if index == -1 then
        color = cc.c3b(0xFF, 0xFF, 0xFF)
    elseif index == 0 then
        color = cc.c3b(0x42, 0x88, 0x1F)
    elseif index == 1 then
        color = cc.c3b(0xff, 0xa2, 0x00)
    elseif index == 2 then
        color = cc.c3b(0x4a, 0x82, 0xa6)
    elseif index == 3 then
        color = cc.c3b(0xcd, 0x69, 0x42)
    else
        color = cc.c3b(0x72, 0x47, 0x2d)
    end
    return color
end

-- 配置宝箱奖励
function GDDHLayer:addChestAward()
    -- 配置奖励信息表
    self.mChestRewardConfig = {}
    for k, v in pairs(GddhAttackRewardRelation.items) do
        table.insert(self.mChestRewardConfig, v)
    end

    table.sort(self.mChestRewardConfig, function(a, b)
        return a.needAttNums < b.needAttNums
    end)
end

-- 更换按钮cd计时
function GDDHLayer:updateChangeBtnTime(btnObj, lastTime)
    local tempLabel = ui.newLabel({
        text = "",
        color = Enums.Color.eRed,
        outlineColor = Enums.Color.eOutlineColor,
        outlineSize = 2,
    })
    tempLabel:setAnchorPoint(cc.p(0.5, 1))
    tempLabel:setPosition(btnObj:getContentSize().width * 0.5, 30)
    btnObj:addChild(tempLabel)
    btnObj:setEnabled(false)
    local timer = lastTime - Player:getCurrentTime() + 1

    self.mChangeCdScheId = Utility.schedule(tempLabel,
        function()
            timer = timer - 1
            tempLabel:setString(string.format("%s(s)", timer))
            if timer <= 0 then
                btnObj:stopAction(self.mChangeCdScheId)
                self.mChangeCdScheId = nil
                btnObj:removeChild(tempLabel)
                btnObj:setEnabled(true)
            end
        end,
        1
    )
end

-- 刷新开战倒计时
--[[
    params:
    time                -- 服务器返回的时间戳
--]]
function GDDHLayer:updateStartGddhTime(time, parent)
    local timeLeft = time - Player:getCurrentTime()

    if timeLeft > 0 then
        local str = MqTime.formatAsDay(timeLeft)
        parent:setString(TR("开战倒计时: %s%s", "#abf37f", str))
    elseif timeLeft == 0 then
        if self.mStartRaceScheId then
            self:stopAction(self.mStartRaceScheId)
            self.mStartRaceScheId = nil
        end
        parent:setString(TR("开战倒计时: 00:00:00"))
        -- 重新进入此页面
        MsgBoxLayer.addOKLayer(
            TR("请重新进入武林大会"),
            TR("提示"),
            {{
                normalImage = "c_28.png",
                text = TR("确定"),
                textColor = Enums.Color.eWhite,
                clickAction = function(layerObj, btnObj)
                    LayerManager.removeLayer(layerObj)
                    LayerManager.removeLayer(self)
                end
            }},
            {}
        )
    else
        if self.mStartRaceScheId then
            self:stopAction(self.mStartRaceScheId)
            self.mStartRaceScheId = nil
        end
        parent:setString(TR("奖励发放中，请稍后~~"))
    end
end
--=========================数据处理==============================
-- 数据处理
-- wrestleRace          -- 服务器请求返回的挑战信息
function GDDHLayer:manageData(wrestleRace)
    -- 玩家数据
    local tempPlayerData = {}
    tempPlayerData = clone(wrestleRace)
    self:managePlayerData(tempPlayerData)

    -- 排名数据

    local tempRankData = {}
    tempRankData = clone(wrestleRace.GddhRankList)
    self:manageRankData(tempRankData)

    -- 旧排名数据
    local tempOldRankData = {}
    tempOldRankData = clone(wrestleRace.GddhFrontFiveList)
    if tempOldRankData then
        self:manageOldFourListData(tempOldRankData)
    end
    -- 宝箱数据
    local tempReceiveList = {}
    tempReceiveList = clone(wrestleRace.ReceiveIdList)
    -- -- 临时测试数据
    -- self.mPerRankCount = 5
    -- tempReceiveList = {"1111"}
    self:manageChestData(tempReceiveList)
end

-- 玩家数据处理
function GDDHLayer:managePlayerData(data)
    self.mIsInTruce = data.IsInTruce == nil and true or data.IsInTruce       -- 休战状态
    self.mLastRefreshTime = data.LastRefreshTime                             -- 最后刷新时间
    self.mLastRecoveTime = data.LastRecoveTime                               -- 下次挑战次数恢复时间
    self.mIntegral = data.Integral                                           -- 积分
    self.mHistortRank = data.HistortRank                                     -- 历史排名
    self.mRank = data.Rank                                                   -- 排名
    self.mHistortIntegral = data.HistortIntegral                             -- 历史积分
    self.mBuyRankCount = data.BuyRankCount                                   -- 购买挑战次数
    self.mPerNum = data.PerNum                                               -- 每日玩家挑战次数限制
    self.mRankCount = data.RankCount                                         -- 玩家挑战次数
    self.mPerRankCount = data.PerRankCount                                   -- 玩家当日已挑战次数
    self.mGroupId = data.GroupId                                             -- 玩家所在组号
    self.mGddhRankTargetList = clone(data.GddhRankTargetList)                -- 挑战玩家列表
    self.mReceiveIdList = clone(data.ReceiveIdList)                          -- 奖励列表
    self.mFrontFiveList = data.GddhFrontFiveList and clone(data.GddhFrontFiveList) or {}                      -- 玩家前两名排名列表
    -- WinCount:赛季胜场次数
end

-- 排行榜分组数据处理
function GDDHLayer:manageRankData(data)
    -- 帮派信息
    self.mGuildInfo = clone(data.GuildInfo)

    -- 初始化分组信息表
    self.mRankListInfo = {{}, {}, {}, {}}

    local tempListInfo = {}
    tempListInfo[1] = clone(data.One)
    -- tempListInfo[2] = clone(data.Two)
    -- tempListInfo[3] = clone(data.Three)
    -- tempListInfo[4] = clone(data.Four)

    -- 若玩家排名6-10,并且前两名玩家信息为空则直接从挑战列表中抓取数据
    if self.mRank and self.mRank >= EachGroupNum and self.mRank <= 10 and not next(self.mFrontFiveList) then
        for i = 1, 2 do
            local tempData = tempListInfo[self.mGroupId][self.mRank - i]
            table.insert(self.mFrontFiveList, tempData)
        end
    end

    for index, item in ipairs(tempListInfo) do
        for i = 1, EachGroupNum do
            table.insert(self.mRankListInfo[index], item[i])
        end
    end

    -- 玩家数据特殊处理,若休战状态没有返回排名则不创建
    if not self.mIsInTruce and self.mRank then
        if self.mRank > EachGroupNum then
            local playerInfo = {
                Rank = self.mRank,
                -- Lv = PlayerAttrObj:getPlayerAttrByName("Lv"),
                Name = PlayerAttrObj:getPlayerAttrByName("PlayerName"),
                -- Guild = GuildObj:getGuildInfo().Name,
                Integral = self.mIntegral,
                GuildName = GuildObj:getGuildInfo().Name
            }
            table.remove(self.mRankListInfo[self.mGroupId], #self.mRankListInfo[self.mGroupId])
            table.insert(self.mRankListInfo[self.mGroupId], playerInfo)
        end
    end

    -- 分组数据以排名从低到高进行排序
    for _, items in pairs(self.mRankListInfo) do
        table.sort(items, function(a, b) return a.Rank < b.Rank end)
    end

    -- 休战状态的所有组中积分排名第一的玩家
    if self.mIsInTruce then
        -- local tempTable = {}
        -- for _, item in pairs(self.mRankListInfo[1]) do
        --     table.insert(tempTable, item)
        -- end
        -- table.sort(tempTable, function(a, b) return a.Rank > b.Rank end)
        -- dump(self.mRankListInfo)
        -- 从所有排名玩家中取出积分排名前4的玩家
        self.mFrontThreeRankPlayer = {}
        for index = 1, 4 do
            table.insert(self.mFrontThreeRankPlayer, self.mRankListInfo[1][index])
        end
    end
end

-- 排行榜前两名玩家信息处理（用于数据恢复和排行榜动画）
function GDDHLayer:manageOldFourListData(data)
    -- 若前两名玩家信息为空
    if not next(self.mFrontFiveList) then
        self.mFrontFiveList = clone(data)
    end

    local oldIndexList = {}
    for _, item in pairs(self.mOldFourList) do
        oldIndexList[item.Rank] = true
    end
    -- 插入新数据
    for index, item in ipairs(self.mFrontFiveList) do
        if not oldIndexList[item.Rank] then
            table.insert(self.mOldFourList, item)
        end
    end
    table.sort(self.mOldFourList, function(a, b)
        return a.Rank < b.Rank
    end)
end

-- 宝箱信息处理
function GDDHLayer:manageChestData(data)
    if self.mIsInTruce then
        -- 宝箱已经领完
        self.mChestState = Enums.RewardStatus.eHadDraw
        self.mChestBtnNode.refreshChestState()
        self.mChestBtnNode.refreshChestInfoLabel()
        return
    end

    -- 计算宝箱可领取次数
    chestRewardNum = 0
    for index, item in ipairs(self.mChestRewardConfig) do
        if self.mPerRankCount >= item.needAttNums then
            chestRewardNum = chestRewardNum + 1
        end
    end

    -- 计算宝箱奖励状态
    if chestRewardNum == #self.mChestRewardConfig and not next(data) then
        -- 宝箱已经领完
        self.mChestState = Enums.RewardStatus.eHadDraw
        self.mChestBtnNode.refreshChestState()
        self.mChestBtnNode.refreshChestInfoLabel()
        return
    elseif chestRewardNum == #self.mChestRewardConfig and next(data) then
        -- 宝箱可领取
        self.mChestState = Enums.RewardStatus.eAllowDraw
        self.mChestBtnNode.refreshChestState()
        self.mChestBtnNode.refreshChestInfoLabel()
        return
    end

    if chestRewardNum > 0 and next(data) then
        -- 宝箱可领取
        self.mChestState = Enums.RewardStatus.eAllowDraw
        self.mChestBtnNode.refreshChestState()
        self.mChestBtnNode.refreshChestInfoLabel()
        return
    elseif chestRewardNum >= 0 and chestRewardNum < #self.mChestRewardConfig and not next(data) then
        -- 宝箱不能领取可预览
        self.mChestState = Enums.RewardStatus.eNotAllow
        self.mChestBtnNode.refreshChestState()
        self.mChestBtnNode.refreshChestInfoLabel()
        return
    end
end

-- 数据恢复
function GDDHLayer:getRestoreData()
    local retData = {}
    -- 进入战斗页面再恢复时，只需保存上次排名和排前几名玩家的信息
    retData = {
        oldRank = self.mRank,
        oldFourList = self.mFrontFiveList,
        alreadyPlayRank = false,                                    -- 是否已经播放标签移动动画
        needAction = false,
        selectId = self.mSelectId,
        groupId = self.mGroupId,
    }
    return retData
end

--=======================特效动画相关=============================

-- 入场动画
function GDDHLayer:aniEnterSecene()
    -- 真·入场动画
    if self.mNeedAction then
        local actionTime = 0.6
        -- 播放入场动画
        -- 更换按钮，关闭按钮
        self.mFunctionBtns[1]:runAction(cc.EaseBackOut:create(cc.MoveBy:create(actionTime, cc.p(-100, 0))))
        self.mFunctionBtns[2]:runAction(cc.EaseBackOut:create(cc.MoveBy:create(actionTime, cc.p(0, -100))))
        -- 帮派按钮，战报按钮，排行榜按钮，兑换按钮， 规则按钮
        for _, item in ipairs(self.mNonFunctionBtns) do
            item:runAction(cc.EaseBackOut:create(cc.MoveBy:create(actionTime, cc.p(0, 300))))
        end

        self.mChestBtnNode:runAction(cc.EaseBackOut:create(cc.MoveBy:create(actionTime, cc.p(0, 300))))
        self.mTabView:runAction(cc.EaseBackOut:create(cc.MoveBy:create(actionTime, cc.p(0, -500))))

        -- 动画播放完之后才能点击进行挑战
        local tempActTime = 0.4
        for index, item in pairs(self.challengPlayerNodeList) do
            item.nullClickAction()
            item:runAction(
                cc.Sequence:create(
                    cc.MoveBy:create(tempActTime, cc.p(0, -200)),
                    cc.CallFunc:create(function ()
                        item.addClickAction()
                    end
                    )
                )
            )
            item.fadeIn(tempActTime)
        end
        self.mNeedAction = false
    end
end

-- 排行榜滚动动画
function GDDHLayer:aniRankListRoll()
    -- 排行发生变化才播放动画,播放入场动画的时候也不播放此动画,并且只播放一次
    if self.mNeedAction then
        return
    end
    if self.mAlreadyPlayRank then
        return
    end
    if self.mOldRank and self.mOldRank ~= 0 and self.mOldRank ~= self.mRank then
        if self.mRank >= EachGroupNum then
            self.mPlayerItem.aniRoll()
            self.mTabView.aniRoll()
        else
            self:aniPlayerInfoMoving(self.mOldRank, self.mRank)
        end
        self.mAlreadyPlayRank = true
    end
end

-- 排行榜玩家条目移动动画
function GDDHLayer:aniPlayerInfoMoving(origin, target)
    print("moveAction")
    origin = origin > EachGroupNum and EachGroupNum or origin
    -- 预设坐标位置
    local moveDisRatio = origin - target + 1
    for index = target , origin do
        local tempItem = self.mPlayerDataList[index]
        tempItem:runAction(cc.MoveBy:create(0, cc.p(0, 40)))
    end

    self.mPlayerDataList[target]:runAction(cc.MoveBy:create(0, cc.p(0, - moveDisRatio * 40)))

    -- 移动动画
    local act1 = cc.ScaleTo:create(0.3, 1.1)
    local act2 = cc.DelayTime:create(0.1)
    local act3 = cc.MoveBy:create(0.3, cc.p(0, moveDisRatio * 40))
    local act4 = cc.ScaleTo:create(0.3, 1)
    local act5 = cc.CallFunc:create(function ()
        for index = target , origin do
            local tempItem = self.mPlayerDataList[index]
            tempItem:runAction(cc.MoveBy:create(0.3, cc.p(0, -40)))
        end
    end)
    local act6 = cc.Spawn:create(act4, act5)
    self.mPlayerDataList[target]:runAction(cc.Sequence:create(act1, act2, act3, act6, nil))
end

-- 数字滚动变化
function GDDHLayer:changeValue(oldRank, newRank, label, parent)
    -- 计时器调用间隔
    local time = nil
    if math.abs(oldRank - newRank) >=30 then
        time = 0.01
    else
        time = 0.05
    end

    -- 在上一次排名的基础上，加还是减
    local var = -1
    if oldRank - newRank < 0 then
        var = 1
    else
        var = -1
    end

    label:setString(oldRank)
    self.mRankScheId = Utility.schedule(parent,
        function()
            oldRank = oldRank + var
            label:setString(oldRank)
            if (oldRank <= newRank) then
                parent:stopAction(self.mRankScheId)
                self.mRankScheId = nil
            end
        end,
        time
    )
end
-- 刷新页面
function GDDHLayer:refreshUI()
    -- 刷新对战玩家
    for k, item in pairs(self.challengPlayerNodeList) do
        item.clearChallengNode()
        item.refreshChallengeNode(self.mGddhRankTargetList[k], targetPlayerInfo[k])
        item.addClickAction(self.mBtnAction)
        item.setOpacity(0)
        item.fadeIn(1)
    end
    -- 刷新次数和倒计时显示
    self.challengNumLabel:resetShow()
    self.challengeResumeLabel:resetShow()
    -- 刷新排行列表
    local selectid = self.mSelectId or self.mGroupId or 1
    self.mTabView.refreshRankList(selectid)
end

--========================网络相关==============================
-- 请求服务器，获取格斗大会赛季信息
function GDDHLayer:requestSignupInfo()
    HttpClient:request({
        moduleName = "Gddh",
        methodName = "SignupInfo",
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                MsgBoxLayer.addOKLayer(
                    TR("数据请求错误，请重新进入武林大会"),
                    TR("提示"),
                    {{
                        normalImage = "c_28.png",
                        text = TR("确定"),
                        textColor = Enums.Color.eWhite,
                        clickAction = function(layerObj, btnObj)
                            LayerManager.removeLayer(layerObj)
                            LayerManager.removeLayer(self)
                        end
                    }},
                    {}
                    )
                return
            end

            -- 保存数据，格斗大会赛季信息表
            self.mSignupInfo = clone(response.Value)
            -- 当前时间在格斗大赛有效时间内
            if (Player:getCurrentTime() < self.mSignupInfo.EndRewardDate) and (Player:getCurrentTime() > self.mSignupInfo.BeginDate) then
                -- 是否报名
                if self.mSignupInfo.IsJoin then
                    -- 初始化本地数据UI
                    self:initUIWithoutData()
                    -- 请求服务器，获取玩家格斗大会的详细信息
                    self:requestGetWrestleRaceInfo()
                else
                    -- 请求服务器，申请分组，参加比赛
                    self:requestApplyGroup()
                end
            else
                -- 初始化本地数据UI
                self:initUIWithoutData()
                self:requestGetWrestleRaceInfo()
            end
        end
    })
end

-- 玩家未报名的情况下，申请分组，参加格斗大会
function GDDHLayer:requestApplyGroup()
    HttpClient:request({
        moduleName = "Gddh",
        methodName = "ApplyGroup",
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if not response.Value or response.Status ~= 0 then
                MsgBoxLayer.addOKLayer(
                    TR("报名失败，请重新进入武林大会"),
                    TR("提示"),
                    {{
                        normalImage = "c_28.png",
                        text = TR("确定"),
                        textColor = Enums.Color.eWhite,
                        clickAction = function(layerObj, btnObj)
                            LayerManager.removeLayer(layerObj)
                            LayerManager.removeLayer(self)
                        end
                    }},
                    {}
                    )
                return
            end

            -- 保存数据，报名分组信息表
            self.mApplyGroupInfo = response.Value
            self:initUIWithoutData()
            self:requestGetWrestleRaceInfo()
            ui.showFlashView(TR("武林大会报名成功"))
            --------抽签动画--------
            -- 屏蔽层
            -- local maskLayer = cc.LayerColor:create(cc.c4b(0,0,0,150))
            -- self:addChild(maskLayer, Enums.ZOrderType.eMessageBox)
            -- ui.registerSwallowTouch({node = maskLayer})

            -- -- 不同的分组对应不同的骨骼动画
            -- local aniList = {"daluo","xuantian","shenge","youming"}
            -- local tipTextList = {TR("少林"), TR("武当"), TR("朝廷"), TR("明教")}

            -- local scaleX = cc.Director:getInstance():getWinSizeInPixels().width /  640
            -- local scaleY = cc.Director:getInstance():getWinSizeInPixels().height /  1136
            -- local rightScale = math.min(scaleX, scaleY)

            -- local effect = ui.newEffect({
            --     parent = maskLayer,
            --     effectName = "effect_ui_chouqian",
            --     position = cc.p(display.width * 0.5, display.height * 0.18),
            --     scale = rightScale,
            --     loop = false,
            --     animation = aniList[self.mApplyGroupInfo.GroupId],
            --     endRelease = false,
            --     speed = 0.9,
            --     startListener = function()
            --         MqAudio.playEffect("sound_stwhy_chouqian.mp3")
            --     end,
            --     completeListener = function()
            --         local action1 = cc.DelayTime:create(0.12)
            --         -- 提示文字："你被分到XX组"
            --         local action2 = cc.CallFunc:create(function()
            --             ui.showFlashView({
            --                 text = TR("你被分到了‘%s’组", tipTextList[self.mApplyGroupInfo.GroupId])
            --             })
            --         end)
            --         local action3 = cc.DelayTime:create(1.0)
            --         local action4 = cc.CallFunc:create(function()
            --             -- 初始化本地数据UI
            --             self:initUIWithoutData()
            --             self:requestGetWrestleRaceInfo()
            --             maskLayer:removeFromParent(true)
            --         end)
            --         maskLayer:runAction(cc.Sequence:create(action1, action2, action3, action4, nil))
            --     end
            -- })
        end
    })
end

-- 请求服务器，获取格斗大会详细信息
function GDDHLayer:requestGetWrestleRaceInfo()
    HttpClient:request({
        moduleName = "Gddh",
        methodName = "GetWrestleRaceInfo",
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if not response or response.Status ~= 0 then
                MsgBoxLayer.addOKLayer(
                    TR("数据请求错误，请重新进入武林大会"),
                    TR("提示"),
                    {{
                        normalImage = "c_28.png",
                        text = TR("确定"),
                        textColor = Enums.Color.eWhite,
                        clickAction = function(layerObj, btnObj)
                            LayerManager.removeLayer(layerObj)
                            LayerManager.removeLayer(self)
                        end
                    }},
                    {}
                )
                return
            end
            ------------- 休战状态测试 -----------
            -- response.Value.GddhRankTargetList = {}
            -- response.Value.IsInTruce = true
            -- self.mSignupInfo.BeginDate = Player:getCurrentTime() + 1000
            -------------

            -- 处理数据
            local wrestleRaceData = clone(response.Value)
            self:manageData(wrestleRaceData)

            -- 创建服务器数据相关UI,只在初始化的时候调用一次
            if self.mIsInited then
                self:refreshUI()
                return
            end

            local _, _, eventID = Guide.manager:getGuideInfo()
            -- 休战状态 todo
            if not self.mIsInTruce then
                self.challengPlayerNodeList = {}
                for index, item in ipairs(self.mGddhRankTargetList) do
                    local tempPlayer = self:createChallengePlayer(item, targetPlayerInfo[index])
                    table.insert(self.challengPlayerNodeList, tempPlayer)
                end
                -- 刷新按钮cd计时
                self:updateChangeBtnTime(self.mFunctionBtns[1], wrestleRaceData.LastRefreshTime)

                -- 判断是否发奖中
                local day, hours, minutes, seconds = MqTime.toHour(self.mSignupInfo.EndRewardDate - Player:getCurrentTime())
                if eventID == 11705 and self.mRewardTime1 == 23 and self.mRewardTime2 >= 30 and self.mRewardTime3 >= 0 then
                    Guide.helper:guideError(eventID, -1)
                else
                    -- 开始新手引导,仅非休战时打开
                    self:executeGuide()
                end
            else
                for index, item in pairs(self.mFrontThreeRankPlayer) do
                    self:createChallengePlayer(item, targetPlayerInfo[index], index)
                end

                -- 休战时，取消新手引导
                if eventID == 11705 then
                    Guide.helper:guideError(eventID, -1)
                end
            end

            self.mIsInited = true
            self:initUI()
        end
    })
end

-- 请求服务器，刷新挑战玩家列表
function GDDHLayer:requestRefreshWrestleRaceRankList(btnObj)
    HttpClient:request({
        moduleName = "Gddh",
        methodName = "RefreshWrestleRaceRankList",
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if not response.Value or response.Status ~= 0 then
                if btnObj then
                    btnObj:setEnabled(true)
                end
                return
            end
            if btnObj then
                self:updateChangeBtnTime(btnObj, response.Value.LastRefreshTime)
            end
            self.mGddhRankTargetList = clone(response.Value.GddhRankTargetList)
            -- 刷新挑战人物列表
            for k, item in pairs(self.challengPlayerNodeList) do
                item.clearChallengNode()
                item.refreshChallengeNode(self.mGddhRankTargetList[k], targetPlayerInfo[k])
                item.addClickAction(self.mBtnAction)
                item.setOpacity(0)
                item.fadeIn(1)
            end
        end
    })
end

-- 请求服务器，挑战对应玩家
--[[
    params:
    playerData              -- 挑战目标玩家数据
    type                    -- 是否通过复仇挑战:0:正常列表挑战   1:复仇挑战
--]]
function GDDHLayer:requestRankWrestleRace(playerData, type)
    local requestData = {playerData.PlayerId, type}
    HttpClient:request({
        moduleName = "Gddh",
        methodName = "RankWrestleRace",
        svrMethodData = requestData,
        guideInfo = Guide.helper:tryGetGuideSaveInfo(11705),
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            local _, _, eventID = Guide.manager:getGuideInfo()
            if not response.Value or response.Status ~= 0 then
                -- 如挑战失败，则跳过引导
                if eventID == 11705 then
                    Guide.helper:guideError(eventID, -1)
                end
                -- 若请求服务器之后未响应,但是服务器进行了计算,进行退出页面重进操作
                LayerManager.addLayer({name = "challenge.GDDHLayer",
                    data = {
                        needAction = false
                    }
                })
                LayerManager.removeLayer(self)
                return
            end
            --[[--------新手引导--------]]--
            if eventID == 11705 then
                Guide.manager:removeGuideLayer()
                Guide.manager:nextStep(eventID)
            end
            -- 获取战斗奖励
            if response.Value.IsWin then
                -- 选择奖励
                local chooseRes = nil
                if response.Value.ChoiceGetGameResource then
                    for _, resInfo in pairs(response.Value.ChoiceGetGameResource) do
                        if resInfo.IsDrop then
                            chooseRes = {
                                resourceTypeSub = resInfo.ResourceTypeSub,
                                modelId = resInfo.ModelId,
                                num = resInfo.Num,
                            }
                            break
                        end
                    end
                end
                -- 基础奖励
                local baseResList = Utility.analysisBaseDrop(response.Value.BaseGetGameResourceList)[1]
                -- 所有奖励
                table.insert(baseResList, chooseRes)

                ui.ShowRewardFlash(baseResList)

                self:requestGetWrestleRaceInfo()
            else
                ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
                ui.showFlashView(TR("挑战失败"))
                self:requestGetWrestleRaceInfo()
            end

            -- -- 获取战斗信息
            -- local control = Utility.getBattleControl(ModuleSub.eChallengeWrestle)
            -- LayerManager.addLayer({
            --     name = "ComBattle.BattleLayer",
            --     data = {
            --         data = response.Value.FightInfo,
            --         skip = control.skip,
            --         trustee = control.trustee,
            --         skill = control.skill,
            --         map = Utility.getBattleBgFile(ModuleSub.eChallengeWrestle),
            --         callback = function(battleResult)
            --             PvpResult.showPvpResultLayer(
            --                 ModuleSub.eChallengeWrestle,
            --                 response.Value,
            --                 {
            --                     PlayerName = PlayerAttrObj:getPlayerAttrByName("PlayerName"),
            --                     FAP = PlayerAttrObj:getPlayerAttrByName("FAP"),
            --                 },
            --                 {
            --                     PlayerName = playerData.Name,
            --                     FAP = playerData.FAP,
            --                     PlayerId = playerData.PlayerId,
            --                 }
            --             )

            --             if control.trustee and control.trustee.changeTrusteeState then
            --                 control.trustee.changeTrusteeState(battleResult.trustee)
            --             end
            --         end
            --     }
            -- })
        end
    })

    -- 挑战之后刷新一次挑战玩家列表
end

-- 领取宝箱奖励
--[[
    params:
        challengeData           -- 宝箱奖励信息
--]]
function GDDHLayer:requestRaceiveReward(challengeData)
     HttpClient:request({
        moduleName = "Gddh",
        methodName = "ReceiveReward",
        svrMethodData = challengeData,
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if not response.Value or response.Status ~= 0 then
                return
            end

            -- 刷新宝箱数据和可领取状态
            self:requestGetWrestleRaceInfo()
            -- 掉落物品展示
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
        end
    })
end

-- 请求服务器，购买挑战次数
--[[
    params:
    buyCount            -- 购买次数
--]]
function GDDHLayer:requestBuyRankCount(buyCount)
    local requestData = {buyCount}
    HttpClient:request({
        moduleName = "Gddh",
        methodName = "BuyRankCount",
        svrMethodData = requestData,
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            self.mRankCount = self.mRankCount + buyCount
            self.mBuyRankCount = response.Value.BuyRankCount
            self.mLastRecoveTime = response.Value.LastRecoveTime

            -- 刷新次数和倒计时显示
            self.challengNumLabel:resetShow()
            self.challengeResumeLabel:resetShow()
        end
    })
end

--========================新手引导==============================
-- 执行新手引导
function GDDHLayer:executeGuide()
    local _, _, eventID = Guide.manager:getGuideInfo()
    -- 耐力不足时，跳过引导
    if eventID == 11705 and not Utility.isResourceEnough(ResourcetypeSub.eSTA, 2, false) then
        Guide.helper:guideError(eventID, -1)
        return
    end
    if eventID == 11705 or eventID == 11709 then
        -- 人物跳出来动画
        Utility.performWithDelay(self.mParentLayer, function()
            Guide.helper:executeGuide({
                -- 点击中间的人物
                [11705] = {clickNode = self.challengPlayerNodeList[1].heroBtn},
                -- 兑换按钮
                [11709] = {clickNode = self.exchangeBtn},
            })
        end, 0.4)
    end
end

return GDDHLayer
