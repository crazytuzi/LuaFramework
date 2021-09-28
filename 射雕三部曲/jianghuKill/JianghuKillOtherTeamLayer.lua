--[[
    文件名：JianghuKillOtherTeamLayer.lua
    描述：江湖杀其他队伍页面
    创建人：chenzhong
    创建时间：2018.9.20
--]]
local JianghuKillOtherTeamLayer = class("JianghuKillOtherTeamLayer", function(params)
    return display.newLayer()
end)

-- 一个队伍的最大人数
local teamNum = 6
-- 每一页10条数据
local eachPageNum = 10

-- 构造函数
--[[
    params:
--]]
function JianghuKillOtherTeamLayer:ctor(params)
    -- package.loaded["jianghuKill.JianghuKillOtherTeamLayer"] = nil
    -- 所有的队伍信息
    self.mTeamInfo = {}
    -- 当前页数
    self.mCurrentPageNum = 1
    self.mTotalPageNum = 1

    -- 子页面控件的父对象
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化UI
    self:initUI()
end

function JianghuKillOtherTeamLayer:initUI()
    -- -- 添加一键申请按钮
    -- local oneKeyBtn = ui.newButton({
    --     normalImage = "c_28.png",
    --     text = TR("一键申请"),
    --     clickAction = function()
           
    --     end,
    -- })
    -- oneKeyBtn:setPosition(cc.p(545, 940))
    -- oneKeyBtn:setScale(0.9)
    -- self.mParentLayer:addChild(oneKeyBtn)

    -- 灰色背景
    local graySprite = ui.newScale9Sprite("jhs_41.png", cc.size(560, 680))
    graySprite:setAnchorPoint(cc.p(0.5, 1))
    graySprite:setPosition(320, 910)
    self.mParentLayer:addChild(graySprite)

    -- 添加人员信息
    self.mTeamListView = ccui.ListView:create()
    self.mTeamListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mTeamListView:setBounceEnabled(true)
    self.mTeamListView:setContentSize(cc.size(560, 660))
    self.mTeamListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mTeamListView:setAnchorPoint(cc.p(0.5, 1))
    self.mTeamListView:setPosition(320, 900)
    self.mParentLayer:addChild(self.mTeamListView)

    -- 翻页按钮
    self.mPageLabel = ui.newLabel({text = TR("第 %s 页", self.mCurrentPageNum), size = 22, color = cc.c3b(0x46, 0x22, 0x0d)})
    self.mPageLabel:setPosition(320, 180)
    self.mParentLayer:addChild(self.mPageLabel)

    -- 左箭头
    local leftSprite, leftLabel = ui.createLabelWithBg({
        bgFilename = "c_43.png",
        labelStr = TR("上一页"),
        color = cc.c3b(0x46, 0x22, 0x0d),
        fontSize = 20,
        offset = 60,
    })
    leftSprite:setRotation(90)
    leftLabel:setRotation(-90)
    leftLabel:setPosition(25, 30)
    leftSprite:setPosition(80, 180)
    self.mParentLayer:addChild(leftSprite)
    -- 右箭头
    local rightSprite, rightLabel = ui.createLabelWithBg({
        bgFilename = "c_43.png",
        labelStr = TR("下一页"),
        color = cc.c3b(0x46, 0x22, 0x0d),
        fontSize = 20,
        offset = 60,
    })
    rightSprite:setRotation(-90)
    rightLabel:setRotation(90)
    rightLabel:setPosition(25, 90)
    rightSprite:setPosition(560, 180)
    self.mParentLayer:addChild(rightSprite)

    -- 左透明按钮
    local leftBtn = ui.newButton({
        normalImage = "c_83.png",
        size = cc.size(130, 60),
        clickAction = function()
            if self.mCurrentPageNum <= 1 then 
                ui.showFlashView(TR(TR("当前已经是第一页！")))
            else 
                self.mCurrentPageNum = self.mCurrentPageNum - 1
                self:refreshTeamList()
                self.mPageLabel:setString(TR("第 %s 页", self.mCurrentPageNum))
            end 
        end
    })
    leftBtn:setPosition(120, 180)
    self.mParentLayer:addChild(leftBtn)
    -- 右透明按钮
    local rightBtn = ui.newButton({
        normalImage = "c_83.png",
        size = cc.size(130, 60),
        clickAction = function()
            if self.mCurrentPageNum >= self.mTotalPageNum then 
                ui.showFlashView(TR(TR("当前已经是最后一页！")))
            else 
                self.mCurrentPageNum = self.mCurrentPageNum + 1
                self:refreshTeamList()
                self.mPageLabel:setString(TR("第 %s 页", self.mCurrentPageNum))
            end 
        end
    })
    rightBtn:setPosition(530, 180)
    self.mParentLayer:addChild(rightBtn)

    self.mHintSprite = ui.createEmptyHint(TR("当前没有队伍信息!"))
    self.mHintSprite:setPosition(320, 598)
    self.mParentLayer:addChild(self.mHintSprite)
    self.mHintSprite:setVisible(false)

    --获取所有的队伍信息
    self:requestGetTeamInfo()
end

-- 加载队伍信息
function JianghuKillOtherTeamLayer:refreshTeamList()
    self.mTeamListView:removeAllItems()

    for i=1, eachPageNum do
        local dataIndex = i + (self.mCurrentPageNum-1)*eachPageNum
        if self.mTeamInfo[dataIndex] then 
            self.mTeamListView:pushBackCustomItem(self:addOneTeamCell(self.mTeamInfo[dataIndex]))
        end 
    end
end

function JianghuKillOtherTeamLayer:addOneTeamCell(teamData)
    local layout = ccui.Layout:create()
    layout:setContentSize(560, 150)

    local cellSprite = ui.newScale9Sprite("jhs_42.png", cc.size(540, 150))
    cellSprite:setPosition(280, 75)
    layout:addChild(cellSprite)
    local goalText = {[1] = TR("进攻"), [2] = TR("驻守"), [3] = TR("采集")}
    -- 一个描述文字
    local introLabel = ui.newLabel({text = TR("队伍目标: #FF974A%s", goalText[teamData.Goal > 0 and teamData.Goal or 1]), size = 20, color = cc.c3b(0x46, 0x22, 0x0d)})
    introLabel:setAnchorPoint(0, 0.5)
    introLabel:setPosition(10, 130)
    cellSprite:addChild(introLabel)

    -- 申请加入按钮
    local interBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("申请加入"),
        clickAction = function()
           -- 加入队伍
           self:requestAddTeam(teamData.TeamId)
        end,
    })
    interBtn:setScale(0.8)
    interBtn:setAnchorPoint(0.5, 1)
    interBtn:setPosition(480, 145)
    cellSprite:addChild(interBtn)

    local function addOneHeroInfo(index)
        local layout = ccui.Layout:create()
        layout:setContentSize(90, 150)

        local heroData = teamData.PlayersInfo[index] or {}
        -- 显示职业图标
        local jobImage = heroData.Profession and Utility.getJHKJobPic(heroData.Profession) or "c_35.png"
        local jobSprite = ui.newSprite(jobImage)
        jobSprite:setScale(0.8)
        jobSprite:setPosition(45, heroData.Profession and 75 or 60)
        layout:addChild(jobSprite)

        -- 玩家名字
        local nameLabel = ui.newLabel({text = heroData.PlayerName or "", size = 18, color = cc.c3b(0x46, 0x22, 0x0d)})
        nameLabel:setPosition(45, 30)
        layout:addChild(nameLabel)

        return layout
    end

    -- 成员
    local memberListView = ccui.ListView:create()
    memberListView:setDirection(ccui.ScrollViewDir.horizontal)
    memberListView:setBounceEnabled(true)
    memberListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    memberListView:setContentSize(cc.size(520, 150))
    memberListView:setAnchorPoint(0.5, 0.5)
    memberListView:setPosition(cc.p(270, 75))
    memberListView:setSwallowTouches(false)
    cellSprite:addChild(memberListView)

    for i=1, teamNum do
        memberListView:pushBackCustomItem(addOneHeroInfo(i))
    end

    return layout
end
---------------------------------------------------------申请加入组队
-- 获取队伍信息
function JianghuKillOtherTeamLayer:requestGetTeamInfo()
    self.mTeamInfo = {}
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "GetTeams",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            -- 队伍信息
            -- dump(response, "获取队伍信息")
            for k,v in ipairs(response.Value or {}) do
                table.insert(self.mTeamInfo, v)
            end

            -- 根据当前页数计算总共有几页
            self.mTotalPageNum = math.ceil(#self.mTeamInfo/eachPageNum)

            -- 加载队伍信息
            self:refreshTeamList()

            self.mHintSprite:setVisible(#self.mTeamInfo<=0)
        end
    })
end

-- 申请加入队伍
function JianghuKillOtherTeamLayer:requestAddTeam(teamId)
    HttpClient:request({
        moduleName = "JianghuKillTeamHall",
        methodName = "AddTeam",
        svrMethodData = {teamId},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                if response.Status == -14400 or response.Status == -14418 then -- 队伍不存在
                    ui.showFlashView(TR("队伍不存在！"))
                    self.mCurrentPageNum = 1
                    self.mTotalPageNum = 1
                    self.mPageLabel:setString(TR("第 %s 页", self.mCurrentPageNum))
                    -- 重新获取队伍数据
                    self:requestGetTeamInfo()
                end
                return
            end
            
            ui.showFlashView(TR("申请成功！"))
        end
    })
end

return JianghuKillOtherTeamLayer
