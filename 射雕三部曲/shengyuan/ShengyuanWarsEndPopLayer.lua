--[[
	文件名: ShengyuanWarsEndPopLayer.lua
	描述: 决战桃花岛结束的结算页面
	创建人: peiyaoqiang
	创建时间: 2017.9.1
--]]

local ShengyuanWarsEndPopLayer = class("ShengyuanWarsEndPopLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 100))
end)

function ShengyuanWarsEndPopLayer:ctor(params)
    -- 处理参数
    self.mPageInfo = {}
    self.mWinTeam  = params.pageInfo.WinTeam -- 胜利队伍名
    if params.pageInfo then
        local function addPageInfo(list, strTeam)
            for _, v in ipairs(list or {}) do
                v.TeamName = strTeam
                table.insert(self.mPageInfo, clone(v))
            end
        end
        addPageInfo(params.pageInfo.A, ShengyuanWarsHelper.teamA)
        addPageInfo(params.pageInfo.B, ShengyuanWarsHelper.teamB)
    end
    
    -- 刷新界面
	self:setUI()
end

function ShengyuanWarsEndPopLayer:setUI()
    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = (self.mWinTeam == ShengyuanWarsHelper.myTeamName) and TR("战斗胜利") or TR("战斗失败"),
        bgSize = cc.size(640, 850),
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
            ShengyuanWarsHelper:clearUpBattleResult()
            ShengyuanWarsUiHelper:exitGame(true)
        end
    })
    self:addChild(bgLayer)

    -- 保存弹窗控件信息
    self.bgSprite = bgLayer.mBgSprite
    self.bgsize = bgLayer.mBgSprite:getContentSize()

    -- 背景图
    local tmpBgSprite = ui.newScale9Sprite("c_17.png", cc.size(self.bgsize.width - 60, self.bgsize.height - 170))
    tmpBgSprite:setAnchorPoint(cc.p(0.5, 0))
    tmpBgSprite:setPosition(self.bgsize.width * 0.5, 100)
    self.bgSprite:addChild(tmpBgSprite)
	
    -- 确定按钮
    ui.newButton({
        normalImage = "c_28.png",
        text = TR("确 定"),
        position = cc.p(self.bgsize.width * 0.5, 60),
        clickAction = function()
            LayerManager.removeLayer(self)
            ShengyuanWarsHelper:clearUpBattleResult()
            ShengyuanWarsUiHelper:exitGame(true)
        end
        }):addTo(self.bgSprite)
    
    -- 列表
    self:createListView()
end

function ShengyuanWarsEndPopLayer:createListView()
	-- 辅助函数：快捷添加Label
    local function addLabel(parent, anchor, pos, strText, textSize, textColor)
        local label = ui.newLabel({text = strText, color = textColor or Enums.Color.eWhite, size = textSize, x = pos.x, y = pos.y, outlineColor = Enums.Color.eBlack})
        label:setAnchorPoint(anchor)
        parent:addChild(label)
    end

    -- 显示标题栏
    addLabel(self.bgSprite, cc.p(0, 0.5), cc.p(40,  self.bgsize.height - 105), TR("玩家名字"), 25)
    addLabel(self.bgSprite, cc.p(0, 0.5), cc.p(220, self.bgsize.height - 105), TR("区服"), 25)
    addLabel(self.bgSprite, cc.p(0, 0.5), cc.p(350, self.bgsize.height - 105), TR("等级"), 25)
    addLabel(self.bgSprite, cc.p(0, 0.5), cc.p(440, self.bgsize.height - 105), TR("击杀"), 25)
    addLabel(self.bgSprite, cc.p(0, 0.5), cc.p(520, self.bgsize.height - 105), TR("积分"), 25)

    -- 显示战绩列表
    local sortTable = self:getSortTable()
    local cellSize = cc.size(640, 35)
    local reportListView = ui.newSliderTableView({
        width = cellSize.width,
        height = self.bgsize.height - 240,
        isVertical = true,
        selItemOnMiddle = false,
        itemCountOfSlider = function()
            return table.nums(sortTable)
        end,
        itemSizeOfSlider = function(pSender, itemIndex)
            return cellSize.width, cellSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
            local item = sortTable[index + 1]
            if (item == nil) then
                return
            end

            local strColor = Enums.Color.eRed
            if item.TeamName == ShengyuanWarsHelper.myTeamName then
                strColor = Enums.Color.eGreen
            end

            addLabel(itemNode, cc.p(0, 0.5), cc.p(40,  cellSize.height * 0.5), item.Name, 22, strColor)
            addLabel(itemNode, cc.p(0, 0.5), cc.p(220, cellSize.height * 0.5), "["..item.ServerName.."]", 22, strColor)
            addLabel(itemNode, cc.p(0, 0.5), cc.p(350, cellSize.height * 0.5), "Lv." .. item.Lv, 22, strColor)
            addLabel(itemNode, cc.p(0, 0.5), cc.p(440, cellSize.height * 0.5), item.KillNum, 22, strColor)
            addLabel(itemNode, cc.p(0, 0.5), cc.p(520, cellSize.height * 0.5), item.FightScore, 22, strColor)
        end,
    })
    reportListView:setAnchorPoint(cc.p(0.5, 0))
    reportListView:setPosition(cc.p(320, 110))
    self.bgSprite:addChild(reportListView)
end

-- 辅助函数  获取排序后的列表
function ShengyuanWarsEndPopLayer:getSortTable()
	-- 根据荣誉值从高到低排序
    local sortTable = clone(self.mPageInfo)
    table.sort(sortTable, function (a, b)
        return a.FightScore > b.FightScore
    end)

    -- 团队总分
    local aTeamResScore = ShengyuanWarsHelper.AResScore
    local bTeamResScore = ShengyuanWarsHelper.BResScore

    -- 失败队伍
    local loseTeamName = ""
    if self.mWinTeam == ShengyuanWarsHelper.teamB then
    	loseTeamName = ShengyuanWarsHelper.teamA
    else
    	loseTeamName = ShengyuanWarsHelper.teamB
    end

    -- 输的队伍列表
    local loseList = {}
    -- 输的提出来
    for k=#sortTable, 1, -1 do
    	if sortTable[k].TeamName == loseTeamName then
    		table.insert(loseList, sortTable[k])
    		table.remove(sortTable, k)
    	end
    end
    -- 插在后面
    for k=#loseList, 1, -1 do
    	table.insert(sortTable, loseList[k])
    end

    return sortTable
end

return ShengyuanWarsEndPopLayer