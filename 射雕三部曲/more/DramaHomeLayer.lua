--[[
    文件名：DramaHomeLayer
    描述：剧情场景主页面
    创建人：chenzhong
    创建时间：2017.12.4
-- ]]

local DramaHomeLayer = class("DramaHomeLayer",function ()
    return display.newLayer()
end)

--主界面初始化
--[[
    params: 参数列表
    {
        index: 可选参数，第几章
    }
--]]
function DramaHomeLayer:ctor(params)
    --变量
    self.mChapterIndex = params.index or 1
    
    -- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    self.mChaildLayer = ui.newStdLayer()
    self:addChild(self.mChaildLayer)

    -- 初始化UI
    self:initUI()
end

--初始化UI
function DramaHomeLayer:initUI()
    --创建顶部资源栏和底部导航栏
    local bottomSprite = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            ResourcetypeSub.eSTA, 
            ResourcetypeSub.eDiamond, 
            ResourcetypeSub.eGold
        }
    })
    self:addChild(bottomSprite)

    -- 背景
    local bgSprite = ui.newSprite("jq_57.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    --规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        textColor = Enums.Color.eYellow,
        position = cc.p(50, 906),
        clickAction = function ()
            print("规则")
            MsgBoxLayer.addRuleHintLayer(TR("规则"),{
                TR("1.观看剧情可以获得奖励，不能跳过和快进"),
                TR("2.观看完每小节可以领取一次奖励，观看完一章以后可以领取一次奖励"),
                TR("3.观看需要按顺序观看，观看完上一小节才能解锁下一小节"),
                TR("4.每日观看次数2次"),
                TR("5.宝箱奖励和小节奖励均为一次性奖励"),
                TR("6.需要通关相应章节的副本才能观看相应剧情"),
            })
        end
    })
    self.mParentLayer:addChild(ruleBtn)

    -- 退出按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end     
    })
    closeBtn:setPosition(594, 906)
    self.mParentLayer:addChild(closeBtn)

    --创建顶部背景
    local topSize = cc.size(640, 157)
    local topSprite = ui.newScale9Sprite("c_69.png", topSize)
    topSprite:setPosition(320, 1136 - 45)
    topSprite:setAnchorPoint(cc.p(0.5, 1))
    self.mParentLayer:addChild(topSprite)
    self.topSprite = topSprite

    -- 获取数据
    -- self:lookNode()
    self:getData()
end

--创建顶部背景栏
function DramaHomeLayer:initTopUI()
    if self.chapterListView then
        self.chapterListView:removeFromParent()
        self.chapterListView = nil 
    end     

    -- 观看的下一章节ID
    local nextChapterId = self.mDramaInfo.NextId or 11 --and 21 or self.mDramaInfo.NextId
    --列表
    local topSize = cc.size(640, 157)
    self.chapterListView = ui.newSliderTableView({
        width = topSize.width - 60,
        height = topSize.height,
        isVertical = false,
        selItemOnMiddle = false,
        itemCountOfSlider = function(sliderView)
            return DramaChapterModel.items_count
        end,
        itemSizeOfSlider = function(sliderView)
            return 100, topSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
            local currentInfo = DramaChapterModel.items[index+1]
            local width = itemNode:getContentSize().width
            local height = topSize.height

            -- 是否可以观看
            local isToWatch = false
            if nextChapterId >= (currentInfo.chapterID*10 + 1) then 
                isToWatch = true
            end

            local bgName = isToWatch and "jq_10.png" or "jq_11.png"
            local nameBg = ui.newSprite(bgName)
            nameBg:setAnchorPoint(0, 0.5)
            nameBg:setPosition(0, height/2)
            itemNode:addChild(nameBg)
            local bgSize = nameBg:getContentSize()
            local selectSprite = ui.newSprite("c_116.png")
            selectSprite:setPosition(bgSize.width * 0.5, bgSize.height * 0.5+10)
            nameBg:addChild(selectSprite, -1)

            -- 添加锁
            local keySprite = ui.newSprite("jq_12.png")
            keySprite:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
            nameBg:addChild(keySprite, 1)  
            keySprite:setVisible(not isToWatch) 

            -- 选中
            if self.mChapterIndex == index + 1 then 
                selectSprite:setVisible(true)
                -- 刷新选中显示的内容
                self:refreshChapterLayer()
            else 
                selectSprite:setVisible(false)
            end   

            -- 章节名字
            local chapterName = ui.newLabel({
                text = currentInfo.name,
                size = 18,
                outlineColor = Enums.Color.eBlack,
                outlineSize = 2,   
            })
            chapterName:setPosition(bgSize.width/2, bgSize.height*0.55)
            nameBg:addChild(chapterName)

            -- 第几章
            local orderName = ui.newLabel({
                text = currentInfo.order,
                size = 16,
                outlineColor = Enums.Color.eBlack,
                outlineSize = 2,   
            })
            orderName:setPosition(bgSize.width/2, bgSize.height*0.25)
            nameBg:addChild(orderName)
        end,
        onItemClecked = function (sliderView, index)
            local currentInfo = DramaChapterModel.items[index+1]
            -- 是否可以观看
            if nextChapterId >= (currentInfo.chapterID*10 + 1) then 
                self.mChapterIndex = index + 1
            else 
                ui.showFlashView(TR("请观看前一章或通关相应副本！"))    
            end
            self.chapterListView:reloadData()
        end
    })
    self.chapterListView:setAnchorPoint(cc.p(0, 0.5))
    self.chapterListView:setPosition(30, topSize.height/2)
    self.topSprite:addChild(self.chapterListView)
    -- 第一次进入手动刷新
    -- self.chapterListView:refreshItem(self.mChapterIndex-1)
    self.chapterListView.onItemClecked(self.chapterListView, math.floor(nextChapterId/10)-1)
end

function DramaHomeLayer:refreshChapterLayer()
    self.mChaildLayer:removeAllChildren()
    -- 观看的下一章节ID
    local nextChapterId = self.mDramaInfo.NextId == 11 and 21 or self.mDramaInfo.NextId
    -- 根据章节显示名字
    local nameBg = ui.newSprite("zdfb_10.png")
    nameBg:setPosition(320, 906)
    self.mChaildLayer:addChild(nameBg)
    local nameBgSize = nameBg:getContentSize()
    local nameLabel = ui.newLabel({
        text = self.mChapterIndex <= 10 and TR("神雕侠侣") or TR("射雕英雄传"),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 24,
    })
    nameLabel:setPosition(nameBgSize.width/2, nameBgSize.height/2)
    nameBg:addChild(nameLabel)

    -- 获取当前章对应的小节
    local currentList = {}
    for k,v in pairs(DramaModel.items) do
        if math.floor(v.ID/10) == self.mChapterIndex then 
            table.insert(currentList, v)
        end     
    end

    -- 排序
    table.sort(currentList, function(item1, item2)
        return item1.ID < item2.ID
    end)

    -- 整合数据（是否观看当前节点和领取节点奖励）
    for k,v in pairs(currentList) do
        v.isWatch = false  -- 默认没有观看
        v.rewardStatus = 0 -- 默认没有领取节点奖励
        for index, item in pairs(self.mDramaInfo.LookedIdStr or {}) do
            if tonumber(index) == v.ID then
                v.rewardStatus = item
                v.isWatch = true
                break
            end     
        end
    end

    local chapterReward = currentList[1].chapterReward
    local chapterRewardId = currentList[1].ID
    -- 剧情任务只有一节
    if #currentList == 1 then 
        local chapterBtn = ui.newButton({
            normalImage = currentList[1].pic1..".png",
            clickAction = function()
                 LayerManager.addLayer({
                    name = "more.DramaWatchLayer",
                    data = {
                        nodeInfo = currentList[1],
                        watchNum = self.mDramaInfo.TotalNum,
                        callback = function (data)
                            -- dump(data,"dddddddd")
                            self.mDramaInfo = data or self.mDramaInfo
                            -- 添加顶部按钮
                            self:initTopUI()
                        end
                    },
                    cleanUp=false
                })
            end     
        })
        chapterBtn:setPosition(320, 670)
        self.mChaildLayer:addChild(chapterBtn)
    else 
        -- 章节宝箱奖励配置在第三个配置里面
        chapterReward = currentList[3].chapterReward
        chapterRewardId = currentList[3].ID
        -- 添加节点按钮
        for i,v in ipairs(currentList) do
            local chapterBtn = ui.newButton({
                normalImage = currentList[i].pic1..".png",
                clickAction = function()
                    LayerManager.addLayer({
                        name = "more.DramaWatchLayer",
                        data = {
                            nodeInfo = v,
                            watchNum = self.mDramaInfo.TotalNum,
                            callback = function (data)
                                -- dump(data,"dddddddd")
                                self.mDramaInfo = data or self.mDramaInfo
                                -- 添加顶部按钮
                                self:initTopUI()
                            end
                        },
                        cleanUp=false
                    })
                end     
            })
            chapterBtn:setPosition(110 + (i-1)*210, 670)
            self.mChaildLayer:addChild(chapterBtn)

            -- 添加锁
            if nextChapterId < v.ID then 
                local key = ui.newSprite("c_35.png")
                key:setPosition(90, 100)
                chapterBtn:addChild(key)
                chapterBtn:setClickAction(function()
                    ui.showFlashView(TR("请观看前一章或通关相应副本！"))    
                end) 
                chapterBtn:setEnabled(false)   
            end 

            -- 添加新
            if nextChapterId == v.ID then
                local newBg = ui.newSprite("c_115.png")
                newBg:setScale(1.6)
                newBg:setPosition(170, 260)
                chapterBtn:addChild(newBg)
            end    
        end    
    end  

    -- 显示当前章的奖励
    local goodsList = Utility.analysisStrResList(chapterReward)
    local boxBtn = ui.newButton({
        normalImage = "jq_7.png",
        disabledImage = "jq_58.png",
        clickAction = function()
            MsgBoxLayer.addPreviewDropLayer(goodsList, TR("观看完本章剧情可获得以下奖励"), TR("宝箱奖励"))
        end
        })
    boxBtn:setPosition(320, 410)
    self.mChaildLayer:addChild(boxBtn)

    -- 领取宝箱按钮
    -- local getRewardBtn = ui.newButton({
    --     normalImage = "c_28.png",
    --     text = TR("领 取"),
    --     clickAction = function(psender)
    --         self:DrawChapterReward(chapterRewardId)
    --     end
    -- })
    -- getRewardBtn:setPosition(320, 210)
    -- self.mChaildLayer:addChild(getRewardBtn)

    -- 判断本章奖励是否领取
    local isGetChapterReward = false
    for k,item in pairs(self.mDramaInfo.RewardStr or {}) do
        if math.floor(item/10) == self.mChapterIndex then 
            isGetChapterReward = true
            break
        end     
    end

    local num = 0
    for i,v in ipairs(currentList) do
        if v.isWatch then 
            num = num + 1
        end     
    end 

    -- 宝箱按钮
    boxBtn:setEnabled(not isGetChapterReward)   
    -- 领取按钮
    if (isGetChapterReward) or (num < #currentList) then
        -- getRewardBtn:setEnabled(false)
    else 
        boxBtn:setClickAction(function ( ... )
            self:DrawChapterReward(chapterRewardId)
        end)
        ui.setWaveAnimation(boxBtn, 9.5, false, cc.p(40, 80))    
    end     

    -- 今日观看次数Label
    local watchLabel = ui.newLabel({
        text = TR("今日观看次数: #ffde00%d/%d", self.mDramaInfo.TotalNum, self.mDramaInfo.DailyTotalNum),
        -- color = cc.c3b(0x46, 0x22, 0x0d),
        size = 24,
        outlineColor = cc.c3b(0x00, 0x00, 0x00),
        outlineSize = 2,
    })
    watchLabel:setPosition(320, 170)
    self.mChaildLayer:addChild(watchLabel)

    -- 章节美术字
    local nameSprite = ui.newSprite(currentList[1].pic3..".png")
    nameSprite:setPosition(320, 280)
    self.mChaildLayer:addChild(nameSprite)
end

-- 获取数据
function DramaHomeLayer:getData()
    HttpClient:request({
        moduleName = "DramaInfo",
        methodName = "GetInfo",
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            
            dump(response,"datadatad")
            self.mDramaInfo = response.Value.DramaInfo or {}
            -- 添加顶部按钮
            self:initTopUI()
        end,
    })
end

-- 领取章奖励
function DramaHomeLayer:DrawChapterReward(chapterRewardId)
    HttpClient:request({
        moduleName = "DramaInfo",
        methodName = "DrawChapterReward",
        svrMethodData = {chapterRewardId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- 飘窗奖励
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

            -- 刷新数据
            self.mDramaInfo = response.Value.DramaInfo or {}
            -- 添加顶部按钮
            self:initTopUI()
        end,
    })
end

return DramaHomeLayer