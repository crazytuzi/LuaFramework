--[[
	文件名：DlgGameRankLayer.lua
	描述：绝情谷每局战斗的排行界面
	创建人：peiyaoqiang
	创建时间：2018.1.25
--]]

local DlgGameRankLayer = class("DlgGameRankLayer", function(params)
	return display.newLayer()
end)

function DlgGameRankLayer:ctor(params)
    -- 读取参数
    local resultData = params
    self.myRank = 1
    self.myScore = 0
    for _,v in ipairs(resultData) do
        if (v.PlayerId ~= nil) and (v.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId")) then
            self.myRank = v.Rank
            self.myScore = v.FightScore
            break
        end
    end
    self.rankList = resultData
    
    -- 创建背景框
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("当前排行"),
        bgSize = cc.size(600, 780),
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
function DlgGameRankLayer:initUI()
    -- 积分背景
    local scoreBgSize = cc.size(self.mBgSize.width - 60, 60)
    local scoreBgSprite = ui.newScale9Sprite("c_25.png", scoreBgSize)
    scoreBgSprite:setPosition(self.mBgSize.width / 2, self.mBgSize.height - 100)
    self.mBgLayer:addChild(scoreBgSprite)

    -- 我的排名
    local rankLabel = ui.newLabel({
        text = TR("我的排名: %s", self.myRank),
        anchorPoint = cc.p(0, 0.5),
        outlineColor = Enums.Color.eOutlineColor,
    })
    rankLabel:setPosition(100, 30)
    scoreBgSprite:addChild(rankLabel)

    -- 我的积分
    local scoreLabel = ui.newLabel({
        text = TR("我的积分: %s", self.myScore),
        anchorPoint = cc.p(1, 0.5),
        outlineColor = Enums.Color.eOutlineColor,
    })
    scoreLabel:setPosition(scoreBgSize.width - 100, 30)
    scoreBgSprite:addChild(scoreLabel)

    -- 列表栏目
    local function addHeaderTitle(titleName, posX)
        local label = ui.newLabel({
            text = titleName,
            size = 25,
            color = cc.c3b(0x46, 0x22, 0x0d)
        })
        label:setPosition(posX, self.mBgSize.height - 160)
        self.mBgLayer:addChild(label)
    end
    addHeaderTitle(TR("排名"), 85)
    addHeaderTitle(TR("玩家"), 200)
    addHeaderTitle(TR("区服"), 340)
    addHeaderTitle(TR("战绩"), 470)

    -- 列表背景
    local listBgSize = cc.size(self.mBgSize.width - 60, self.mBgSize.height - 260)
    local listBgSprite = ui.newScale9Sprite("c_17.png", listBgSize)
    listBgSprite:setAnchorPoint(cc.p(0.5, 0))
    listBgSprite:setPosition(self.mBgSize.width * 0.5, 80)
    self.mBgLayer:addChild(listBgSprite)

    -- 排名列表
    local mListView = ccui.ListView:create()
    mListView:setDirection(ccui.ScrollViewDir.vertical)
    mListView:setBounceEnabled(true)
    mListView:setContentSize(cc.size(listBgSize.width - 10,listBgSize.height - 10))
    mListView:setPosition(5, 5)
    listBgSprite:addChild(mListView)

    -- 显示所有排名
    local cellSize = cc.size(listBgSize.width - 10, 102)
    for i=1,KillervalleyConfig.items[1].matchNum do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        mListView:pushBackCustomItem(lvItem)
        self:createRankCell(lvItem, cellSize, i)
    end
    
    -- 提示文字
    local strInfo = TR("很遗憾，您在本局比赛中只获得了第%s%s%s名。", "#D17E00", self.myRank, "#46220D")
    if (self.myRank == 1) then
        strInfo = TR("恭喜，您在本局比赛中获得了第%s%s%s名！", "#D17E00", self.myRank, "#46220D")
    end
    local infoLabel = ui.newLabel({
        text = strInfo,
        color = cc.c3b(0x46, 0x22, 0x0d)
    })
    infoLabel:setPosition(self.mBgSize.width / 2, 50)
    self.mBgLayer:addChild(infoLabel)
end

----------------------------------------------------------------------------------------------------

-- 创建一行排名cell
function DlgGameRankLayer:createRankCell(parent, size, rank)
    -- 查找排名对应的信息
    local item = {}
    for _,v in pairs(self.rankList) do
        if (v.Rank == rank) then
            item = clone(v)
            break
        end
    end

    -- 显示背景
    local cellBgSize = cc.size(size.width - 6, size.height - 5)
    local cellBgSprite = ui.newScale9Sprite("c_18.png", cellBgSize)
    cellBgSprite:setPosition(size.width / 2, size.height / 2)
    parent:addChild(cellBgSprite)

    -- 显示排名
    local rankImgList = {
        [1] = "c_44.png",
        [2] = "c_45.png",
        [3] = "c_46.png",
    }
    local rankImg = rankImgList[rank]
    if rankImg then
        local rankSprite = ui.newSprite(rankImg)
        rankSprite:setPosition(50, cellBgSize.height / 2)
        cellBgSprite:addChild(rankSprite)
    else
        local rankNumLabel = ui.createSpriteAndLabel({
            imgName = "c_47.png",
            labelStr = rank,
            fontSize = 30,
            fontColor = Enums.Color.eNormalWhite,
        })
        rankNumLabel:setPosition(50, cellBgSize.height / 2)
        cellBgSprite:addChild(rankNumLabel)
    end

    -- 显示玩家名、区服、战绩
    local function addAttrLabel(strAttr, posX)
        local label = ui.newLabel({
            text = strAttr,
            size = 22,
            anchorPoint = cc.p(0.5, 0.5),
            color = cc.c3b(0x46, 0x22, 0x0d)
        })
        label:setPosition(posX, cellBgSize.height / 2)
        cellBgSprite:addChild(label)
    end
    local strZone = item.Zone or TR("暂无")
    local strScore = item.FightScore and TR("积分: %d\n击杀: %d", item.FightScore, item.KillNum) or TR("暂无")
    addAttrLabel(item.Name or TR("未决出"), 170)
    addAttrLabel("#D17E00" .. strZone, 305)
    addAttrLabel(strScore, 440)
end

----------------------------------------------------------------------------------------------------

return DlgGameRankLayer