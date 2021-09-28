--[[
    文件名：LianQiLayer.lua
    描述：练气主页面
    创建人：chenzhong
    创建时间：2017.12.14
--]]
local LianQiLayer = class("LianQiLayer", function(params)
    return display.newLayer()
end)

-- 五种不同的状态
local StatusList = {
    [1] = {headerImage = "zy_06.png", headerName = "zy_01.png"},
    [2] = {headerImage = "zy_07.png", headerName = "zy_02.png"},
    [3] = {headerImage = "zy_08.png", headerName = "zy_03.png"},
    [4] = {headerImage = "zy_09.png", headerName = "zy_04.png"},
    [5] = {headerImage = "zy_10.png", headerName = "zy_05.png"},
}

-- 一键聚气最大容量30个
local allZhenYuanCount = 30

-- 构造函数
--[[
    statusStype:当前练气的状态
--]]
function LianQiLayer:ctor(params)
    -- package.loaded["zhenyuan.LianQiLayer"] = nil
    self.mParent = params and params.parent
    -- 页面大小
    self:setContentSize(cc.size(640, 1136))
    self.mStatusIndex = params and params.statusStype or 1
    self.mRecruitFreeTimes = 0 -- 默认免费次数
    self.mNewAddNum = 0  -- 新增真元个数

    -- UI相关
    self:initUI()
end

-- 添加相关UI元素
function LianQiLayer:initUI()
    -- 背景页面
    local backSprite = ui.newSprite("zy_18.jpg")
    backSprite:setPosition(320, 568)
    self:addChild(backSprite)

    -- 添加修炼值显示
    local topSize = cc.size(266, 54)
    local topSprite = ui.newScale9Sprite("c_25.png", topSize)
    topSprite:setAnchorPoint(0, 0.5)
    topSprite:setPosition(-30, 480)
    self:addChild(topSprite)
    self.mSocreLabel = ui.newLabel({
        text = TR("修炼值:%s点", 0),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
        anchorPoint = cc.p(0, 0.5),
        x = 50,
        y = topSize.height/2,
    })
    topSprite:addChild(self.mSocreLabel)
    -- 添加ListView
    self:addListView()
    -- 增加按钮(一键聚气、一键收纳、一键练气)
    self:addButton()
    -- 请求服务器，获取道具信息
    self:requestGoodsList()
    -- 添加屏蔽层
    self:isSwallowTouch(false)
end

-- 创建ListView列表视图
function LianQiLayer:addListView()
    self.mListView = ccui.ListView:create()
    self.mListView:setContentSize(cc.size(640, 420))
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setItemsMargin(10)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(320, 950)
    self.mListView:setScrollBarEnabled(false)
    self.mListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self:addChild(self.mListView)
end

--创建椭圆控件
function LianQiLayer:createEllipseView()
    self.mGoodsList = {}
    -- 首先创建一个状态的名字 后面转到之后跟着变化
    self.mHeadName = ui.newSprite(StatusList[1].headerName)
    self.mHeadName:setPosition(300, 320)
    self:addChild(self.mHeadName, 1)
    -- 首先自己创建一次消耗
    self:createUseInfo(1)
    -- 创建旋转3D
    self._ellipseLayer = require("common.EllipseLayer3D").new({
        longAxias = 190,
        shortAxias = 100,
        fixAngle = 90,
        totalItemNum = 5,
        itemContentCallback = function(parent, index)
            -- 每种状态头像
            local headerSprite = ui.newSprite(StatusList[index].headerImage)
            headerSprite:setScale(0.8)
            parent:addChild(headerSprite)
            parent.showNode = headerSprite
            -- 刷新旋转的item
            parent.updateFunc = function(opacity)
                local tmpOpacity = opacity
                if (opacity < 120) then
                    tmpOpacity = 130
                end
                local tmpScale = 0.4 + (0.3*tmpOpacity)/255
                parent.showNode:setOpacity(tmpOpacity)
                parent.showNode:setScale(tmpScale)
            end
        end,
        alignCallback = function (index)
            self.mStatusIndex = index
            -- 刷新每种状态的名字
            if self.mHeadName then 
                self.mHeadName:setVisible(true)
                self.mHeadName:setTexture(cc.Director:getInstance():getTextureCache():addImage(StatusList[index].headerName))
            end 

            -- 显示当前状态练气需要的消耗东西
            self:createUseInfo(index)
        end
    })
    self._ellipseLayer:setPosition(cc.p(300, 410))
    self:addChild(self._ellipseLayer)
end

function LianQiLayer:createUseInfo(index)
    if not tolua.isnull(self.freeLabel) then 
        self.freeLabel:removeFromParent()
        self.freeLabel = nil 
    end
    if self.mRecruitFreeTimes > 0 then 
        self.freeLabel = ui.newLabel({
            text = TR("今日免费练气次数:%s", self.mRecruitFreeTimes),
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            outlineSize = 2,
            anchorPoint = cc.p(0.5, 1),
            x = 320,
            y = 150,
        })
        self:addChild(self.freeLabel)
        return
    end     
    for i,v in ipairs(self.mGoodsList) do
        if not tolua.isnull(v) then
            v:removeFromParent()
        end     
    end
    local useInfo = Utility.analysisStrResList(ZhenyuanRecruitModel.items[index].recruitUse)
    for i,item in ipairs(useInfo) do
        local goodsLabel = ui.newLabel({
            text = string.format("{%s}%s", Utility.getDaibiImage(item.resourceTypeSub), Utility.numberWithUnit(item.num, 0)),
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            outlineSize = 2,
            anchorPoint = cc.p(0, 1),
            x = 400,
            y = 270 - (i-1)*50,
        })
        goodsLabel:setScale(0.9)
        self:addChild(goodsLabel)
        table.insert(self.mGoodsList, goodsLabel)
    end
end

-- 增加按钮(一键聚气、一键收纳、一键练气、练气、心无旁骛按钮)
function LianQiLayer:addButton()
    local btnInfos = {
        {
            -- 一键聚气
            normalImage = "tb_219.png",
            position = cc.p(590, 375),
            clickAction = function ()
                -- 紫色品质及以上需要提示
                self:checkQualityHint(4, 7)
            end

        },
        {
            -- 一键收纳
            normalImage = "tb_218.png",
            position = cc.p(590, 275),
            clickAction = function ()
                self:requestOneKeyCollect()
            end
        },
        {
            -- 一键练气
            normalImage = "tb_220.png",
            position = cc.p(590, 175),
            clickAction = function ()
                self:requestOneKeyRecruit()
            end
        },
        {
            -- 练气
            normalImage = "zy_11.png",
            position = cc.p(320, 225),
            isGuide = true,
            clickAction = function ()
                self:requestRecruit()
                --[[--------新手引导(不理会练气是否成功)--------]]--
                local _, _, eventID = Guide.manager:getGuideInfo()
                if eventID == 10013 then
                    -- 不删除引导界面
                    Guide.manager:nextStep(eventID)
                    self.mParent:executeGuide()
                end
            end
        },
        {
            -- 心无旁骛按钮
            normalImage = "zy_15.png",
            position = cc.p(130, 195),
            tag = 1, -- 添加一个tag（创建的时候需要单独添加一个特效）
            clickAction = function ()
                self:requestGoLimitUp()
            end
        }
    }
    for _, btnInfo in pairs(btnInfos) do
        local tempBtn = ui.newButton(btnInfo)
        self:addChild(tempBtn)
        -- 保存引导使用
        if btnInfo.isGuide then
            self.mLianQiBtn = tempBtn
        end

        -- 心无旁骛按钮需要添加特效
        if btnInfo.tag and btnInfo.tag == 1 then 
            local btnSize = tempBtn:getContentSize()
            ui.newEffect({
                parent = tempBtn,
                effectName = "effect_ui_zhenyuan_anniu",
                position = cc.p(btnSize.width/2, btnSize.height/2),
                loop = true,
                endRelease = true,
            })
        end    
    end

    --心无旁骛消耗
    local useInfo = Utility.analysisStrResList(ZhenyuanRecruitModel.items[4].oneKeyLitUp)
    for i,item in ipairs(useInfo) do
        local goodsLabel = ui.newLabel({
            text = string.format("{%s}%s", Utility.getDaibiImage(item.resourceTypeSub), Utility.numberWithUnit(item.num, 0)),
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            outlineSize = 2,
            anchorPoint = cc.p(0.5, 1),
            x = 130,
            y = 150,
        })
        self:addChild(goodsLabel)
    end
end

-- 物品信息分组后，刷新ListView
-- isrecruit:是否是练气时创建
-- isOneKeyRecruit:是否是一键练气
function LianQiLayer:refreshListView(isRecruit, isOneKeyRecruit)
    -- 先移除所有再重新添加
    self.mListView:removeAllItems()
    self.mAllHeadList = {}
    -- 判断是够有练出来的真元
    if not tolua.isnull(self.mSpHint) then 
        self.mSpHint:removeFromParent()
        self.mSpHint = nil
    end     
    if #self.mGoodsInfo <= 0 then 
        self.mSpHint = ui.createEmptyHint(TR("没有真元！"))
        self.mSpHint:setPosition(320, 800)
        self:addChild(self.mSpHint)
        return
    end     
    -- 整理物品信息，5个为1组
    self:handleGoodsInfo()

    for i = 1, table.maxn(self.mPropList) do
        -- 创建cell
        local cellWidth, cellHeight = 640, 120
        local customCell = ccui.Layout:create()
        customCell:setContentSize(cc.size(cellWidth, cellHeight))

        -- 向已创建的cell添加UI元素
        self:addElementsToCell(customCell, i, isOneKeyRecruit)

        -- 添加cell到listview
        self.mListView:pushBackCustomItem(customCell)
    end

    local effectNameList = {
        [1] = "ui_effect_zycx",
        [2] = "effect_ui_zhenyuanchuxian_lv",
        [3] = "effect_ui_zhenyuanchuxian_lan",
        [4] = "effect_ui_zhenyuanchuxian_zi",
        [5] = "effect_ui_zhenyuanchuxian_cheng",
        [6] = "effect_ui_zhenyuanchuxian_hong",
        [7] = "effect_ui_zhenyuanchuxian_jin",
    }

    if isOneKeyRecruit then 
        self:isSwallowTouch(true)
        local index = allZhenYuanCount-self.mNewAddNum + 1
        local  function setHeadVisble(index)
            if not tolua.isnull(self.mAllHeadList[index]) then 
                local nodeSize = self.mAllHeadList[index]:getContentSize()
                Utility.performWithDelay(self.mAllHeadList[index], function ( )
                    self.mAllHeadList[index]:setVisible(true)
                    ui.newEffect({
                        parent = self.mAllHeadList[index],
                        effectName = effectNameList[self.mAllHeadList[index].qualityLv],
                        loop = false,
                        endRelease = true,
                        scale = 0.35,
                        position = cc.p(nodeSize.width/2, nodeSize.height/2)
                    })
                    index = index + 1
                    setHeadVisble(index)
                end, 0.15) 
            else
                self:isSwallowTouch(false)       
            end

            if index >= 15 then 
                local innerNode = self.mListView:getInnerContainer()
                innerNode:setPositionY(-330 + 120*(index/5-3))
            end     
        end
        setHeadVisble(index) 
    elseif isRecruit then 
        local nodeSize = self.mAllHeadList[#self.mAllHeadList]:getContentSize()
        ui.newEffect({
            parent = self.mAllHeadList[#self.mAllHeadList],
            effectName = effectNameList[self.mAllHeadList[#self.mAllHeadList].qualityLv],
            loop = false,
            endRelease = true,
            scale = 0.35,
            position = cc.p(nodeSize.width/2, nodeSize.height/2)
        })
        if #self.mPropList > 3 then 
            self.mListView:jumpToBottom()
        end     
    end     
end

-- 向创建的cell添加UI元素
--[[
    cell                -- 需要添加UI元素的cell
    cellIndex           -- cell索引号
--]]
function LianQiLayer:addElementsToCell(cell, cellIndex, isOneKeyRecruit)
    -- 获取每个小组的数据信息, 可能包含2个道具信息  也可能只有1个
    local groupInfo = self.mPropList[cellIndex]

    -- 获取cell宽高
    local cellWidth = cell:getContentSize().width
    local cellHeight = cell:getContentSize().height
    for i, v in ipairs(groupInfo) do
        -- 设置头像
        local propHead = CardNode.createCardNode({
            modelId = v,
            resourceTypeSub = ResourcetypeSub.eZhenYuan,
            cardShowAttrs = {CardShowAttr.eName},
            cardShape = Enums.CardShape.eCircle,
            allowClick = true,
            onClickCallback = function (psender)
                self:requestCollect(v, (cellIndex-1)*5 + i)
            end,
        })
        propHead:setAnchorPoint(cc.p(0.5, 0.5))
        propHead:setPosition(80+(i-1)*120, 75)
        propHead.qualityLv = Utility.getQualityColorLv(ZhenyuanModel.items[v].quality)
        cell:addChild(propHead)
        if (cellIndex-1)*5 + i > (allZhenYuanCount-self.mNewAddNum) then
            propHead:setVisible(not isOneKeyRecruit)
        end    
        table.insert(self.mAllHeadList, propHead)
    end

    return customCell
end

-- 整理物品信息，5个为一组
function LianQiLayer:handleGoodsInfo()
    -- 重置为空表
    self.mPropList = {}

    local tempList = {}
    for i = 1, #self.mGoodsInfo do
        table.insert(tempList, self.mGoodsInfo[i])
        if i % 5 == 0 then
            table.insert(self.mPropList, tempList)
            tempList = {}
        end
    end

    if #tempList ~= 0 then
        table.insert(self.mPropList, tempList)
    end
end

-- 检查选择的品质是否需要提示
--[[
    minQualityLv:            需要提示的最低品质等级（2-7）
    maxQualityLv:            需要提示的最高品质等级（2-7）
]]
function LianQiLayer:checkQualityHint(minQualityLv, maxQualityLv)
    if #self.mGoodsInfo <= 0 then
        ui.showFlashView({text = TR("没有选中的真元")})
        return
    end
    -- 参数传入错误
    if minQualityLv > maxQualityLv then
        return
    end
    -- 查找大于等于紫色品质的真元
    local hintStr = ""
    local hintStrList = {}
    -- 满足条件List
    local newList = {}
    for i = minQualityLv, maxQualityLv do
        newList[i] = {}
    end
    -- 将所有符合品质的真元筛选入列表
    for _, Id in pairs(self.mGoodsInfo) do
        local zhenyuanInfo = ZhenyuanModel.items[Id]
        local qualityLv = Utility.getQualityColorLv(zhenyuanInfo.quality)
        if newList[qualityLv] then
            table.insert(newList[qualityLv], zhenyuanInfo)
        end
    end
    -- 剔除最高品质的第一个真元
    for i=maxQualityLv, minQualityLv, -1 do
        if next(newList[i]) ~= nil then
            table.remove(newList[i], 1)
            break
        end       
    end
    -- 将列表中真元加入提示列表
    for k,v in pairs(newList) do
        for i,item in pairs(v) do
            local zhenyuanInfo = ZhenyuanModel.items[item.ID]
            local colorValue = Utility.getQualityColor(zhenyuanInfo.quality, 2)
            local nameStr = colorValue..zhenyuanInfo.name
            table.insert(hintStrList, nameStr)
        end
    end
    -- 合并提示列表文字
    if #hintStrList > 1 then 
        hintStr = table.concat(hintStrList, "、")
    end     

    -- 创建提示弹窗（有需要提示品质时创建弹窗）
    if hintStr ~= "" then
        local function DIYfunc(boxRoot, bgSprite, bgSize)
            local listSize = cc.size(bgSize.width*0.9-10, bgSize.height-180)
            local listView = ccui.ListView:create()
            listView:setDirection(ccui.ScrollViewDir.vertical)
            listView:setContentSize(listSize)
            listView:setGravity(ccui.ListViewGravity.centerHorizontal)
            listView:setAnchorPoint(cc.p(0.5, 0))
            listView:setPosition(bgSize.width*0.5, 105)
            bgSprite:addChild(listView)

            local hintLabel = ui.newLabel({
                    text = TR("选中的真元中包含%s%s，是否确定一键聚气？", hintStr, Enums.Color.eNormalWhiteH),
                    color = Enums.Color.eNormalWhite,
                    outlineColor = cc.c3b(0x46, 0x22, 0x0d),
                    dimensions = cc.size(listSize.width-10, 0),
                })

            local labelSize = hintLabel:getContentSize()
            local layout = ccui.Layout:create()
            layout:setContentSize(cc.size(listSize.width, listSize.height > labelSize.height and listSize.height or labelSize.height))

            hintLabel:setAnchorPoint(cc.p(0.5, 0.5))
            hintLabel:setPosition(layout:getContentSize().width*0.5, layout:getContentSize().height*0.5)
            layout:addChild(hintLabel)

            listView:pushBackCustomItem(layout)
        end
        self.hintBox = LayerManager.addLayer({
            name = "commonLayer.MsgBoxLayer", 
            data = {
                title = TR("提示"),
                btnInfos = {
                    {
                        text = TR("确定"),
                        clickAction = function ()
                            self:requestOneKeyCompose()
                            LayerManager.removeLayer(self.hintBox)
                        end
                    },
                    {text = TR("取消"),},
                },
                DIYUiCallback = DIYfunc,
                closeBtnInfo = {},
            }, 
            cleanUp = false,
        })
    else
        -- 一键聚气
        self:requestOneKeyCompose()
    end
end

-- 是否屏蔽层
function LianQiLayer:isSwallowTouch(isTouch)
    -- 添加屏蔽层
    if not tolua.isnull(self.mNewlayer) then 
        self.mNewlayer:removeFromParent()
        self.mNewlayer = nil
    end 

    self.mNewlayer = ui.newStdLayer()
    self:addChild(self.mNewlayer, Enums.ZOrderType.eWeakPop)
    ui.registerSwallowTouch({node = self.mNewlayer, allowTouch = isTouch})
end

---------------------网络相关---------------------
-- 请求服务器，获取所有要显示的道具的信息
function LianQiLayer:requestGoodsList()
    HttpClient:request({
        moduleName = "ZhenyuanRecruitInfo",
        methodName = "GetInfo",
        callbackNode = self,
        callback = function(data)
            dump(data, "requestShopGoodsList")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 免费次数
            self.mRecruitFreeTimes = data.Value.RecruitInfo.RecruitFreeTimes or 0
            -- 创建椭圆控件
            self:createEllipseView()
            -- 更新当前显示状态
            if not tolua.isnull(self._ellipseLayer) then 
                self._ellipseLayer:moveToIndexItem(data.Value.RecruitInfo.RecruitStepStatus or 1)
            end  
            -- 刷新修炼值
            if not tolua.isnull(self.mSocreLabel) then 
                self.mSocreLabel:setString(TR("修炼值:%s点", data.Value.RecruitInfo.PracticeNum or 0))
            end
            -- 刷新免费次数
            self:createUseInfo(self.mStatusIndex)  

            -- 保存数据
            self.mGoodsInfo = data.Value.RecruitInfo.RecruitModelIdStr or {}
            -- 刷新ListView
            self:refreshListView()

            --[[--------新手引导(不理会练气是否成功)--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 10013 then
                if self.mRecruitFreeTimes > 0 then
                    self:executeGuide()
                else
                    GuideHelper:guideError(eventID, -1)
                end
            end
        end
    })
end

-- 请求练气
function LianQiLayer:requestRecruit()
    HttpClient:request({
        moduleName = "ZhenyuanRecruitInfo",
        methodName = "Recruit",
        callbackNode = self,
        guideInfo = Guide.helper:tryGetGuideSaveInfo(10013),
        callback = function(data)
            dump(data, "练气信息：")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            -- 免费次数
            self.mRecruitFreeTimes = data.Value.RecruitInfo.RecruitFreeTimes or 0
            -- 更新当前显示状态
            if not tolua.isnull(self._ellipseLayer) then 
                self._ellipseLayer:moveToIndexItem(data.Value.RecruitInfo.RecruitStepStatus or 1)
            end  
            -- 刷新修炼值
            if not tolua.isnull(self.mSocreLabel) then 
                local labelSize = self.mSocreLabel:getContentSize()
                ui.newEffect({
                    parent = self.mSocreLabel,
                    effectName = "effect_ui_zhenyuan_saoguang",
                    position = cc.p(labelSize.width/2, labelSize.height/2-3),
                    loop = false,
                    endRelease = true,
                })
                self.mSocreLabel:setString(TR("修炼值:%s点", data.Value.RecruitInfo.PracticeNum or 0))
            end
            -- 刷新免费次数
            self:createUseInfo(self.mStatusIndex) 

            -- 保存数据
            self.mGoodsInfo = data.Value.RecruitInfo.RecruitModelIdStr or {}
            -- 刷新ListView
            self:refreshListView(true)
        end
    })
end

-- 请求一键练气
function LianQiLayer:requestOneKeyRecruit()
    HttpClient:request({
        moduleName = "ZhenyuanRecruitInfo",
        methodName = "OneKeyRecruit",
        callbackNode = self,
        callback = function(data)
            dump(data, "一键练气信息：")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            -- 免费次数
            self.mRecruitFreeTimes = data.Value.RecruitInfo.RecruitFreeTimes or 0
            self.mNewAddNum = #data.Value.ModelId
            -- 更新当前显示状态
            if not tolua.isnull(self._ellipseLayer) then 
                self._ellipseLayer:moveToIndexItem(data.Value.RecruitInfo.RecruitStepStatus or 1)
            end  
            -- 刷新修炼值
            if not tolua.isnull(self.mSocreLabel) then 
                local labelSize = self.mSocreLabel:getContentSize()
                ui.newEffect({
                    parent = self.mSocreLabel,
                    effectName = "effect_ui_zhenyuan_saoguang",
                    position = cc.p(labelSize.width/2, labelSize.height/2-3),
                    loop = false,
                    endRelease = true,
                })
                self.mSocreLabel:setString(TR("修炼值:%s点", data.Value.RecruitInfo.PracticeNum or 0))
            end
            -- 刷新免费次数
            self:createUseInfo(self.mStatusIndex) 

            -- 保存数据
            self.mGoodsInfo = data.Value.RecruitInfo.RecruitModelIdStr or {}
            -- 刷新ListView
            self:refreshListView(false, true)
        end
    })
end

-- 直接提到心无旁骛
function LianQiLayer:requestGoLimitUp()
    HttpClient:request({
        moduleName = "ZhenyuanRecruitInfo",
        methodName = "GoLimitUp",
        callbackNode = self,
        callback = function(data)
            -- dump(data, "心无旁骛：")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            -- 更新当前显示状态
            if not tolua.isnull(self._ellipseLayer) then 
                self._ellipseLayer:moveToIndexItem(data.Value.RecruitInfo.RecruitStepStatus or 1)
            end  
            -- 刷新修炼值
            if not tolua.isnull(self.mSocreLabel) then 
                self.mSocreLabel:setString(TR("修炼值:%s点", data.Value.RecruitInfo.PracticeNum or 0))
            end

            -- 保存数据
            self.mGoodsInfo = data.Value.RecruitInfo.RecruitModelIdStr or {}
            -- 刷新ListView
            self:refreshListView()
        end
    })
end

-- 一键聚气
function LianQiLayer:requestOneKeyCompose()
    local function zhenYuanAction(index, node, callback)
        local array = {}
        table.insert(array, cc.ScaleTo:create(0.1, 1.1))
        table.insert(array, cc.ScaleTo:create(0.1, 1))
        table.insert(array, cc.DelayTime:create(0.2))
        table.insert(array, cc.FadeOut:create(1.5))
        table.insert(array, cc.CallFunc:create(function()
            if index == #self.mAllHeadList then
                callback()
            end  
        end))
        node:runAction(cc.Sequence:create(array))
    end      
    HttpClient:request({
        moduleName = "ZhenyuanRecruitInfo",
        methodName = "OneKeyCompose",
        callbackNode = self,
        callback = function(data)
            dump(data, "一键聚气信息：")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 一系列动效
            self:isSwallowTouch(true)
            for i,v in ipairs(self.mAllHeadList) do
                zhenYuanAction(i, v, function ()
                    -- 更新当前显示状态
                    if not tolua.isnull(self._ellipseLayer) then 
                        self._ellipseLayer:moveToIndexItem(data.Value.RecruitInfo.RecruitStepStatus or 1)
                    end  
                    -- 刷新修炼值
                    if not tolua.isnull(self.mSocreLabel) then 
                        self.mSocreLabel:setString(TR("修炼值:%s点", data.Value.RecruitInfo.PracticeNum or 0))
                    end

                    ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
                    -- 先飘窗显示物品 然后刷新页面
                    Utility.performWithDelay(self, function ( )
                        -- 保存数据
                        self.mGoodsInfo = data.Value.RecruitInfo.RecruitModelIdStr or {}
                        -- 刷新ListView
                        self:refreshListView()
                        self:isSwallowTouch(false)
                    end, 0.5)    
                end)
            end      
        end
    })
end

-- 一键收纳
function LianQiLayer:requestOneKeyCollect()
    local function zhenYuanAction(index, node, callback)
        local array = {}
        table.insert(array, cc.ScaleTo:create(0.1, 1.1))
        table.insert(array, cc.ScaleTo:create(0.1, 1))
        table.insert(array, cc.DelayTime:create(0.2))
        table.insert(array, cc.FadeOut:create(1.5))
        table.insert(array, cc.CallFunc:create(function()
            if index == #self.mAllHeadList then
                callback()
                self:isSwallowTouch(false)
            end  
        end))
        node:runAction(cc.Sequence:create(array))
    end    
    HttpClient:request({
        moduleName = "ZhenyuanRecruitInfo",
        methodName = "OneKeyCollect",
        callbackNode = self,
        callback = function(data)
            dump(data, "一键收纳信息：")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            -- 一系列动效
            self:isSwallowTouch(true)
            for i,v in ipairs(self.mAllHeadList) do
                zhenYuanAction(i, v, function ()
                    -- 更新当前显示状态
                    if not tolua.isnull(self._ellipseLayer) then 
                        self._ellipseLayer:moveToIndexItem(data.Value.RecruitInfo.RecruitStepStatus or 1)
                    end  
                    -- 刷新修炼值
                    if not tolua.isnull(self.mSocreLabel) then 
                        self.mSocreLabel:setString(TR("修炼值:%s点", data.Value.RecruitInfo.PracticeNum or 0))
                    end

                    ui.ShowRewardGoods(data.Value.BaseGetGameResourceList,false)
                    -- 先飘窗显示物品 然后刷新页面
                    Utility.performWithDelay(self, function ( )
                        -- 保存数据
                        self.mGoodsInfo = data.Value.RecruitInfo.RecruitModelIdStr or {}
                        -- 刷新ListView
                        self:refreshListView()
                    end, 0.5)    
                end)
            end    
        end
    })
end

-- 收纳
function LianQiLayer:requestCollect(modelId, index)
    HttpClient:request({
        moduleName = "ZhenyuanRecruitInfo",
        methodName = "Collect",
        callbackNode = self,
        svrMethodData = {modelId},
        callback = function(data)
            -- dump(data, "收纳信息：")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            -- 一系列动效
            self:isSwallowTouch(true)
            local array = {}
            table.insert(array, cc.ScaleTo:create(0.1, 1.1))
            table.insert(array, cc.ScaleTo:create(0.1, 1))
            table.insert(array, cc.DelayTime:create(0.2))
            table.insert(array, cc.FadeOut:create(1.5))
            table.insert(array, cc.CallFunc:create(function()
                --飘窗提示
                ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
                self:isSwallowTouch(false)
                -- 更新当前显示状态
                if not tolua.isnull(self._ellipseLayer) then 
                    self._ellipseLayer:moveToIndexItem(data.Value.RecruitInfo.RecruitStepStatus or 1)
                end  
                -- 刷新修炼值
                if not tolua.isnull(self.mSocreLabel) then 
                    self.mSocreLabel:setString(TR("修炼值:%s点", data.Value.RecruitInfo.PracticeNum or 0))
                end

                -- 保存数据
                self.mGoodsInfo = data.Value.RecruitInfo.RecruitModelIdStr or {}
                -- 刷新ListView
                self:refreshListView()
            end))
            self.mAllHeadList[index]:runAction(cc.Sequence:create(array))
        end
    })
end

----------------- 新手引导 -------------------
-- 执行新手引导
function LianQiLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 指向炼气
        [10013] = {clickNode = self.mLianQiBtn},
    })
end

return LianQiLayer
