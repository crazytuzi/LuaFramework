--[[
    文件名：ExpediHomeLayer.lua
    描述：组队副本主页
    创建人：chenzhong
    创建时间：2017.07.8
--]]

local ExpediHomeLayer = class("ExpediHomeLayer",function()
    return display.newLayer()
end)

-- 构造函数
--[[
    nodeId: 默认选择的结点ID
    maxNodeId: 玩家挑战的最高结点ID
    isPass: 是否通过该关卡
--]]
function ExpediHomeLayer:ctor(params)
    -- 当前选择的节点ID
    self.mNodeId = params.nodeId or 1111
    self.mMaxNodeId = params.maxNodeId or self.mNodeId
    self.mIsPass = params.isPass or false
    -- 创建房间的时候是否选择私密创建
    self.mIsLocked = false
    -- 创建房间的时间默认挑战次数
    self.mCurrSelCount = 1
    -- 挑战一次消耗的体力
    self.mUseVitNum = ExpeditionMapModel.items[1].challengeUse

    -- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- ui
    self:setUI()

    -- 请求队伍信息(判断是否已经在队伍中，如果在直接进入队伍页面)
    -- self:requestTeamInfo()

    -- 获取当前节点副本队伍信息
    self:getTeamInfo(self.mNodeId)

    --  加入刷新按钮
    self:createBottomBtns()

    self:requestGetTimedActivityInfo()
end

--获取页面恢复信息
function ExpediHomeLayer:getRestoreData()
    local retData = {
        nodeId = self.mNodeId,
        maxNodeId = self.mMaxNodeId,
        isPass = self.mIsPass,
    }
    return retData
end

-- setUI
function ExpediHomeLayer:setUI( )
    -- 创建背景
    local spriteBg = ui.newSprite("zdfb_01.jpg")
    spriteBg:setPosition(320, 568)
    self.mParentLayer:addChild(spriteBg, -2)

    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

    -- 彩带
    local ribbonSprite = ui.newSprite("zdfb_03.png")
    ribbonSprite:setAnchorPoint(cc.p(0, 1))
    ribbonSprite:setPosition(0, 1070)
    spriteBg:addChild(ribbonSprite)

    -- 返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(584, 1040),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    spriteBg:addChild(closeBtn)

    -- 兑换按钮
    -- local exchangeBtn = ui.newButton({
    --     normalImage = "tb_27.png",
    --     anchorPoint = cc.p(0.5, 1),
    --     position = cc.p(320, 1070),
    --     clickAction = function()
    --         LayerManager.addLayer({
    --             name = "challenge.ExpediShopLayer",
    --         })
    --     end
    -- })
    -- spriteBg:addChild(exchangeBtn)

    -- 规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "tb_127.png",
        anchorPoint = cc.p(0.5, 1),
        position = cc.p(450, 1070),
        clickAction = function()
            local rulesData = {
                TR("1、共6个难度逐渐递增的门派，解锁条件为达到一定等级且通关上一难度。通关少林困难以后可以挑战成昆，挑战成昆可获得光明顶密藏。"),
                TR("2、玩家可以选择创建队伍或者加入队伍，组满3人即可开始挑战，也可以用一键匹配快速获得队友"),
                TR("3、参与挑战的玩家，每次挑战消耗一定体力，每日挑战次数上限为2000次"),
                TR("4、每个难度BOSS均拥有一定特性，第1难度1条特性，随着难度逐渐增加特性条目数"),
                TR("5、战斗采取３Ｖ３形式，３局两胜制"),
                TR("6、邀请好友、同帮派成员可以获得奖励加成"),
                TR("7、队长需要预设连战次数，其他玩家需要足够体力才能加入队伍，掉线将会中止连战，玩家也可以手动停止连战"),
                TR("8、通关任意难度以后就能和队友一起组队挂机该难度。"),
            }
            MsgBoxLayer.addRuleHintLayer(TR("规则提示"), rulesData, cc.size(598, 474))
        end
    })
    spriteBg:addChild(ruleBtn)

    -- 显示队伍的listView
    self.mlistView = ccui.ListView:create()
    self.mlistView:setContentSize(cc.size(600, 730))
    self.mlistView:setDirection(ccui.ListViewDirection.vertical)
    self.mlistView:setGravity(ccui.ListViewGravity.centerHorizontal)
    self.mlistView:setBounceEnabled(true)
    self.mlistView:setAnchorPoint(0.5, 1)
    self.mlistView:setPosition(320, 910)
    spriteBg:addChild(self.mlistView)

    -- 显示当前节点名字
    self:ShowNodeName()
end

-- 创建按钮（创建队伍、快速加入、刷新）
function ExpediHomeLayer:createBottomBtns()
    local btnInfos = {
        {   -- 创建队伍
            normalImage = "c_28.png",
            text = TR("创建队伍"),
            clickAction = function()
                self:showBattleList(true)
            end
        },
        {   -- 快速加入
            normalImage = "c_28.png",
            text = TR("快速加入"),
            clickAction = function()
                if next(self.mTeamList) ~= nil then
                    self:quickGotoTeam(self.mNodeId)
                else
                    ui.showFlashView(TR("没有可加入的队伍！"))
                end
            end
        },
        {   -- 刷新
            normalImage = "c_28.png",
            text = TR("刷 新"),
            clickAction = function()
                self:getTeamInfo(self.mNodeId)
            end
        },
    }

    for index, btnInfo in ipairs(btnInfos) do
        local startPosX, space = 100, 220
        local tempBtn = ui.newButton(btnInfo)
        tempBtn:setPosition(startPosX + (index - 1) * space, 140)
        self.mParentLayer:addChild(tempBtn)
    end
end

-- 显示当前的队伍信息
function ExpediHomeLayer:refreshListView(teamInfo)
    self.mlistView:removeAllItems()
    if not tolua.isnull(self.mNothingSprite) then
        self.mNothingSprite:removeFromParent()
        self.mNothingSprite = nil
    end

    local cellSize = cc.size(600, 230)
    for i, item in ipairs(teamInfo) do
        -- 找到队长数据
        local captainInfo = {}
        for _, memberInfo in pairs(item.Member) do
            if item.LeaderId == memberInfo.PlayerId then
                captainInfo = memberInfo
            end
        end
        -- 筛选出不挂机或本服挂机队伍
        local serverInfo = Player:getSelectServer()
        if (not item.IsGuaji) or (captainInfo.ServerGroupId == serverInfo.ServerGroupID) then
            local cell = ccui.Layout:create()
            cell:setContentSize(cellSize)
            self.mlistView:pushBackCustomItem(cell)

            -- 背景
            local  cellBg = ui.newScale9Sprite("c_18.png", cc.size(cellSize.width , cellSize.height-10))
            cellBg:setPosition(cellSize.width/2, cellSize.height/2)
            cell:addChild(cellBg)

            -- 显示是否自动开战
            --dump(item.IfAutoReady,"IfAutoReady")
            local autoFigt = ui.newSprite("zf_09.png")
            autoFigt:setPosition(cellSize.width-60, cellSize.height-55)
            cellBg:addChild(autoFigt)
            autoFigt:setVisible(item.IfAutoReady)

            -- 目标 推荐战力
            local fapNum = self:getMinFap(item.NodeFap)
            local targetLabel = ui.newLabel({
                text = TR("目标:%s  推荐战力:%s  连战:%s次", 
                    ExpeditionNodeModel.items[item.BattleNodeId].name, 
                    Utility.numberFapWithUnit(fapNum), 
                    item.NeedBattleCount
                ),
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 20,
            })
            targetLabel:setAnchorPoint(0, 1)
            targetLabel:setPosition(30, cellSize.height - 20)
            cellBg:addChild(targetLabel)

            -- 宣言
            local decLabel = ui.newLabel({
                text = TR("宣言:%s", item.Slogan),
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 20,
            })
            decLabel:setAnchorPoint(0, 0)
            decLabel:setPosition(30, 15)
            cellBg:addChild(decLabel)

            -- 玩家头像
            for k, playerInfo in ipairs(item.Member) do
                local headSprite = require("common.CardNode").new({
                    allowClick = false,
                })
                local showAttrs = {CardShowAttr.eBorder, CardShowAttr.eName}
                headSprite:setHero({HeroModelId = playerInfo.HeadImageId, pvpInterLv = playerInfo.DesignationId, FashionModelID = playerInfo.FashionModelId, IllusionModelId = playerInfo.IllusionModelId}, showAttrs, playerInfo.Name)
                headSprite:setAnchorPoint(0, 0.5)
                headSprite:setPosition(20 + 106*(k-1), cellSize.height/2+10)
                cellBg:addChild(headSprite)
            end

            -- 加入按钮
            if item.IfCanShow then 
                local joinBtn = ui.newButton({
                    normalImage = "c_28.png",
                    text = TR("加 入"),
                    anchorPoint = cc.p(0.5, 0.5),
                    position = cc.p(500, cellSize.height/2+10),
                    clickAction = function()
                        -- 加入时先判断体力是否足够
                        local vitNum = item.NeedBattleCount*self.mUseVitNum 
                        if  vitNum > PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eVIT) then 
                            MsgBoxLayer.addGetStaOrVitHintLayer(ResourcetypeSub.eVIT, vitNum)
                            return
                        end  
                        -- 加入
                        self:gotoTeam(item.TeamId, item.BattleNodeId)
                    end
                }) 
                cellBg:addChild(joinBtn)

                local vitLabel = ui.newLabel({
                    text = TR("消耗体力:%s", item.NeedBattleCount*self.mUseVitNum),
                    color = cc.c3b(0x46, 0x22, 0x0d),
                    size = 20,
                })
                vitLabel:setPosition(500, cellSize.height/2-40)
                cellBg:addChild(vitLabel)
            else 
                local secretSprite = ui.newSprite("zdfb_02.png")
                secretSprite:setPosition(500, cellSize.height/2)
                cellBg:addChild(secretSprite)  
            end     
        end
    end

    local itemList = self.mlistView:getItems()
    if not next(itemList) then
        self.mNothingSprite = ui.createEmptyHint(TR("暂时没有队伍！"))
        self.mNothingSprite:setPosition(320, 568)
        self.mParentLayer:addChild(self.mNothingSprite)
    end
end

-- 展示当前的节点名字
function ExpediHomeLayer:ShowNodeName()
    --说明背景
    local decBgSize = cc.size(520, 50)
    local decBg = ui.newButton({
        normalImage = "xshd_27.png",
        size = decBgSize,
        position = cc.p(cc.p(320, 940)),
        clickAction = function()
            -- self:showBattleList()
        end
    })
    self.mParentLayer:addChild(decBg)

    -- 文字
    local textLabel = ui.newLabel({
        text = TR("当前副本:%s", ExpeditionNodeModel.items[self.mNodeId].name),
        color = Enums.Color.eWhite,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
        size = 22,
    })
    textLabel:setAnchorPoint(0.5, 0.5)
    textLabel:setPosition(260, 25)
    decBg:addChild(textLabel)
    self.textLabel = textLabel

    -- -- 更换按钮
    -- local changeBtn = ui.newButton({
    --     normalImage = "c_28.png",
    --     text = TR("更 换"),
    --     anchorPoint = cc.p(0.5, 1),
    --     position = cc.p(decBgSize.width+20, 25),
    --     clickAction = function()
    --         self:showBattleList()
    --     end
    -- })
    -- changeBtn:setAnchorPoint(1, 0.5)
    -- decBg:addChild(changeBtn)
end

-- 显示副本列表
--[[
    参数：
        isCreate: 是否是创建队伍
]]
function ExpediHomeLayer:showBattleList(isCreate)
    local battleList = {}
    local cellBtnList = {}
    for _, item in pairs(ExpeditionNodeModel.items) do
        table.insert(battleList, {
            Id = item.ID,
            name = item.name,
        })
    end
    table.sort(battleList, function(item1, item2)
        return item1.Id < item2.Id
    end)

    -- 由于可能纯在弹窗上加弹窗 这里直接先自己创建弹窗背景
    local bgSize = isCreate and cc.size(542, 450) or cc.size(542, 400)
    local bgSprite = ui.newScale9Sprite("c_30.png", bgSize)
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)
    ui.registerSwallowTouch({node = bgSprite})
    local mTitleNode = ui.newLabel({
        text = TR("挑战次数"),
        size = Enums.Fontsize.eTitleDefault,
        color = cc.c3b(0xff, 0xee, 0xd0),
        outlineColor = cc.c3b(0x3a, 0x24, 0x18),
    })
    mTitleNode:setAnchorPoint(cc.p(0.5, 0.5))
    mTitleNode:setPosition(cc.p(bgSize.width / 2, bgSize.height - 36))
    bgSprite:addChild(mTitleNode)
    -- 返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(bgSize.width - 38, bgSize.height - 35),
        clickAction = function()
            bgSprite:removeFromParent()
        end
    })
    bgSprite:addChild(closeBtn)

    -- 背景
    local viewSize = isCreate and cc.size(480, 280) or cc.size(480, 300)
    local tempSprite = ui.newScale9Sprite("c_17.png", viewSize)
    tempSprite:setAnchorPoint(cc.p(0.5, 1))
    tempSprite:setPosition(bgSize.width / 2, bgSize.height - 70)
    bgSprite:addChild(tempSprite)

    local size = tempSprite:getContentSize()
    local cellSize = cc.size(480, 50)
    local item = {}
    for index, v in pairs(battleList) do
        if v.Id == self.mNodeId then 
            item = v
            break
        end 
    end         
    -- 子项背景
    local cellBtn = ui.newButton({
        normalImage = "zdfb_12.png",
        lightedImage = "zdfb_12.png",
        disabledImage = "gd_10.png",
        size = cc.size(cellSize.width - 40, cellSize.height),
        position = cc.p(cellSize.width / 2, viewSize.height - 50),
        clickAction = function()
        end
    })
    tempSprite:addChild(cellBtn)
    cellBtn:setBright(false)

    -- 在按钮上加字
    local btnLabel = ui.newLabel({
        text = item.name,
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 24,
    })
    btnLabel:setPosition(cellBtn:getContentSize().width/2, cellSize.height / 2)
    cellBtn:addChild(btnLabel)

    -- 如果是创建队伍，则添加创建私密队伍复选框
    if isCreate then
        local checkBox = ui.newCheckbox({
            normalImage = "c_60.png",
            selectImage = "c_61.png",
            imageScale = 1.5,
            text = TR("创建私密队伍，非邀请玩家无法加入"),
            textColor = cc.c3b(0x46, 0x22, 0x0d),
            callback = function(isSelect)
                if isSelect then
                    self.mIsLocked = true
                else
                    self.mIsLocked = false
                end
            end
        })
        checkBox:setAnchorPoint(cc.p(0, 0.5))
        checkBox:setPosition(50, 80)
        checkBox:setCheckState(self.mIsLocked)
        bgSprite:addChild(checkBox)

        local guajiState = self.mIsPass
        local checkGuajiBox = ui.newCheckbox({
            normalImage = "c_60.png",
            selectImage = "c_61.png",
            imageScale = 1.5,
            text = TR("创建挂机队伍，挂机队伍仅本服玩家可见"),
            textColor = cc.c3b(0x46, 0x22, 0x0d),
            callback = function(isSelect)
                if not self.mIsPass then
                    bgSprite.checkGuajiBox:setCheckState(false)
                    ui.showFlashView(TR("请先通关该关卡才能挂机"))
                    return
                end
                guajiState = isSelect
            end
        })
        checkGuajiBox:setAnchorPoint(cc.p(0, 0.5))
        checkGuajiBox:setPosition(50, 40)
        checkGuajiBox:setCheckState(guajiState)
        bgSprite:addChild(checkGuajiBox)
        bgSprite.checkGuajiBox = checkGuajiBox

        -- 选择挑战次数
        local tipLabel = ui.newLabel({
            text = TR("请选择挑战次数"),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 24,
        })
        tipLabel:setAnchorPoint(0, 0.5)
        tipLabel:setPosition(50, 250)
        bgSprite:addChild(tipLabel)

        -- 消耗体力的显示
        local colorStr = "#FF4A46"
        if self.mCurrSelCount*self.mUseVitNum <= PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eVIT) then 
            colorStr = "#249029"
        end     
        local cusVitLabel = ui.newLabel({
            text = TR("消耗体力:%s%s#46220d/%s", colorStr, self.mCurrSelCount*self.mUseVitNum, PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eVIT)),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 24,
        })
        cusVitLabel:setAnchorPoint(0, 0.5)
        cusVitLabel:setPosition(250, 250)
        bgSprite:addChild(cusVitLabel)

        -- 数量选择控件
        local tempView = require("common.SelectCountView"):create({
            currSelCount = 1,
            maxCount = 120,   --前端做一个每次连战的场次限制（每次最多120次）
            viewSize = cc.size(500, 80),
            changeCallback = function(count)
                self.mCurrSelCount = count
                local colorStr = "#FF4A46"
                if self.mCurrSelCount*self.mUseVitNum <= PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eVIT) then 
                    colorStr = "#249029"
                end 
                cusVitLabel:setString(TR("消耗体力:%s%s#46220d/%s", colorStr, self.mCurrSelCount*self.mUseVitNum, PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eVIT)))
            end
        })
        tempView:setPosition(bgSize.width / 2, 190)
        bgSprite:addChild(tempView)
        tempView.mSelCountLabel:setColor(cc.c3b(0x46, 0x22, 0x0d))

        -- 确定按钮
        local toBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("创 建"),
            position = cc.p(bgSize.width/2, 135),
            clickAction = function()
                if self.mCurrSelCount <= 0 then 
                    ui.showFlashView(TR("请先选择挑战次数"))
                    return
                end     
                -- 创建队伍时先判断体力是否足够
                local vitNum = self.mCurrSelCount*self.mUseVitNum
                if  vitNum > PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eVIT) then 
                    MsgBoxLayer.addGetStaOrVitHintLayer(ResourcetypeSub.eVIT, vitNum, function(layerObj, btnObj)
                        local colorStr = "#FF4A46"
                        if self.mCurrSelCount*self.mUseVitNum <= PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eVIT) then 
                            colorStr = "#249029"
                        end 
                        cusVitLabel:setString(TR("消耗体力:%s%s#46220d/%s", colorStr, self.mCurrSelCount*self.mUseVitNum, PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eVIT)))
                        LayerManager.removeLayer(layerObj) 
                    end)
                    return
                end  

                self:createTeam(guajiState) 
            end
        })
        bgSprite:addChild(toBtn)
    end
end

--辅助函数求三个怪物战力的最小值
function ExpediHomeLayer:getMinFap(fapList)
    local minFap, otherFap = 0, 0
    local otherFap = fapList[1] <= fapList[2] and fapList[1] or fapList[2]
    minFap = otherFap <= fapList[3] and otherFap or fapList[3]

    return minFap
end

-- 获取当前节点副本队伍信息
function ExpediHomeLayer:getTeamInfo(nodeId)
    -- Int32:节点ID
    -- Boolean:是否只需要同服队伍
    --dump(nodeId,"nodeId")
    HttpClient:request({
        moduleName = "TeamHall", 
        methodName = "GetTeamInfo", 
        svrMethodData = {nodeId, false},
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if data.Status ~= 0 then
                return
            end
            -- dump(data.Value,"data")
            self.mTeamList = data.Value
            self:refreshListView(data.Value)
        end
    })
end

-- 自己创建房间
-- 接口参数: -- Int32:节点ID,
            -- Int64:最低战力,
            -- Boolean:是否可以从组队大厅加,
            -- Int32:需要战斗次数,
            -- Boolean:是否自动准备,(默认都是自动准备的)
            -- Boolean:是否自动挂机,(默认都是自动挂机的)
function ExpediHomeLayer:createTeam(isGuaij)
    HttpClient:request({
        moduleName = "TeamHall",
        methodName = "CreateTeam",
        svrMethodData = {self.mNodeId, 0, not self.mIsLocked, self.mCurrSelCount, true, isGuaij}, 
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            local data = response.Value
            LayerManager.addLayer({
                name = "challenge.ExpediTeamLayer",
                data = {nodeInfo = data.NodeInfo, teamInfo = data.TeamInfo, isDoubleActivity = self.mIsSalesActivity},
            }) 
        end
    })
end     

--快速加入队伍
function ExpediHomeLayer:quickGotoTeam(nodeId)
    HttpClient:request({
        moduleName = "TeamHall",
        methodName = "QuickEnterTeam",
        svrMethodData = {nodeId},
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if data.Status ~= 0 then
                return
            end

            -- 进入队伍页面
            local data = data.Value
            LayerManager.addLayer({
                name = "challenge.ExpediTeamLayer",
                data = {nodeInfo = data.NodeInfo, teamInfo = data.TeamInfo, isDoubleActivity = self.mIsSalesActivity},
            })
        end,
    })
end

--加入队伍
function ExpediHomeLayer:gotoTeam(guidId, nodeId)
    HttpClient:request({
        moduleName = "TeamHall",
        methodName = "EnterTeam",
        svrMethodData = {guidId, nodeId, false},
        callbackNode = self,
        callback = function(data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                -- 队伍已满/队伍不存在/私密队伍，刷新队伍列表
                if data.Status == -9857 or data.Status == -9846 or data.Status == -9864 then
                    self:getTeamInfo(self.mNodeId)
                end
                return
            end

            local data = data.Value
            LayerManager.addLayer({
                name = "challenge.ExpediTeamLayer",
                data = {nodeInfo = data.NodeInfo, teamInfo = data.TeamInfo, isDoubleActivity = self.mIsSalesActivity},
            })
        end,
    })
end

-- 请求服务器，获取所有已开启的福利多多活动的信息
function ExpediHomeLayer:requestGetTimedActivityInfo()
    HttpClient:request({
        moduleName = "TimedInfo",
        methodName = "GetTimedActivityInfo",
        callbackNode = self,
        callback = function (data)
            -- dump(data, "requestGetTimedActivityInfo")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            for i,v in ipairs( data.Value.TimedActivityList) do
                if v.ActivityEnumId == TimedActivity.eSalesRebornCoin then -- 有真气翻倍活动
                    self.mIsSalesActivity = true
                    break
                end
            end
        end
    })
end

return ExpediHomeLayer
