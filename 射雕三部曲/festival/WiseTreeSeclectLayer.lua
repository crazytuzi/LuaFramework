--[[
    文件名：WiseTreeSeclectLayer.lua
    描述：祈愿树选择奖励页面(孔明灯也是这个选择页面)
    创建人：chenzhong
    创建时间：2018.1.25
--]]
local WiseTreeSeclectLayer = class("WiseTreeSeclectLayer", function(params)
    return cc.Layer:create()
end)

-- 初始化函数
--[[
    params: 参数列表
    {
        id  -- 档位id
        callback  -- 回调
        tag  -- 活动类型
    }
--]]
function WiseTreeSeclectLayer:ctor(params)
    self.mCallback = params.callback
    self.mId = params.id or 1
    self.mTag = params.tag or ModuleSub.eCommonHoliday18
    -- 选中的道具ID (0表示没有选择)
    self.mProId = 0 

    -- 创建原始界面
    self:initLayer()
end

-- 初始化界面
--[[
    无参数
--]]
function WiseTreeSeclectLayer:initLayer()
    local popSprite = require("commonLayer.PopBgLayer").new({
        title = self.mTag == ModuleSub.eCommonHoliday18 and TR("祈愿豪礼") or TR("祈福豪礼"),
        bgSize = cc.size(610, 550),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(popSprite)
    local bgSprite = popSprite.mBgSprite
    self.bgSize = bgSprite:getContentSize()
    self.bgSprite = bgSprite

    -- 介绍规则Label
    local introText = TR("选择下列一种祝福，开始您的放飞孔明灯之旅吧！只需每天祈福，最后放飞孔明灯，就能获得10倍大奖！")
    if self.mTag == ModuleSub.eCommonHoliday18 then 
        introText = TR("从下列道具中选择一种作为您想要的奖励，选完全部奖励以后可以开始抽取奖励，选定奖励之后不能重新选择哦！")
    end 
    local introLabel = ui.newLabel({
        text = introText,
        color = cc.c3b(0x46, 0x22, 0x0d),
        -- outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
        dimensions = cc.size(self.bgSize.width-80, 0)
    })
    introLabel:setPosition(self.bgSize.width/2, self.bgSize.height - 95)
    bgSprite:addChild(introLabel)

    -- 奖励列表控件和背景
    local listViewBgSize = cc.size(self.bgSize.width - 60, self.bgSize.height - 250)
    local listViewBgSprite = ui.newScale9Sprite("c_17.png",listViewBgSize)
    listViewBgSprite:setAnchorPoint(cc.p(0.5, 1))
    listViewBgSprite:setPosition(self.bgSize.width/2, self.bgSize.height - 130)
    bgSprite:addChild(listViewBgSprite)
    self.mRewardListView = ccui.ListView:create()
    self.mRewardListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mRewardListView:setBounceEnabled(true)
    self.mRewardListView:setContentSize(cc.size(listViewBgSize.width, listViewBgSize.height-10))
    self.mRewardListView:setItemsMargin(5)
    self.mRewardListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mRewardListView:setPosition(listViewBgSize.width/2, listViewBgSize.height/2)
    listViewBgSprite:addChild(self.mRewardListView)

    -- 确定按钮
    local confimBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确 定"),
        position = cc.p(self.bgSize.width/2, 70),
        clickAction = function(pSender)
            if self.mProId == 0 then 
                ui.showFlashView({text = TR"您还没有选择道具！"})
                return
            end 
            self.resetHintBox = MsgBoxLayer.addOKLayer(
                TR("选择道具之后不能更换，是否确定选择该道具？"),
                TR("提示"),
                {
                    {
                        normalImage = "c_28.png",
                        text = TR("确定"),
                        clickAction = function()
                            self:requestSetReward()
                            LayerManager.removeLayer(self.resetHintBox)
                        end
                    },
                    {
                        normalImage = "c_28.png",
                        text = TR("取消"),
                        clickAction = function()
                            LayerManager.removeLayer(self.resetHintBox)
                        end
                    },
                },
                {}
            )
        end
    })
    bgSprite:addChild(confimBtn)

    -- 获取信息
    self:requestGetInfo()
end

function WiseTreeSeclectLayer:refreshLayer()
    self.mRewardListView:removeAllItems()
    local headerList = {}
    -- 一排几个
    local colNum = 3
    local width = self.mRewardListView:getContentSize().width
    local height = 140
    -- colNum个奖励头像的位置
    local positionList = {}
    for i = 1, colNum do
        -- 计算间隔
        local moreInterval = -width*(1/(100*(colNum+1)))+i*width*(1/(100*(colNum+1)))   
        positionList[i] = cc.p(width * i/(colNum+1)+moreInterval, 80)
    end
    -- 计算出总共有多少排（每4个为一排）
    for index = 1, math.ceil(#self.mRewardInfo / colNum) do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cc.size(width, height))
        self.mRewardListView:pushBackCustomItem(lvItem)
        -- 判断当前排是否为3个
        local itemNum
        if index <= math.floor(#self.mRewardInfo / colNum) then
            itemNum = colNum
        else
            itemNum = #self.mRewardInfo % colNum
        end
        -- 显示每一排的奖励的图标
        for k = 1, itemNum do
            -- 获取每一个的奖励图标信息
            local info = self.mRewardInfo[colNum * (index - 1) + k]
            local headerInfo = Utility.analysisStrResList(info.Reward)[1]
            -- 创建奖励图标
            local header 
            header = CardNode.createCardNode({
                resourceTypeSub = headerInfo.resourceTypeSub,
                modelId = headerInfo.modelId,
                num = headerInfo.num,
                cardShape = Enums.CardShape.eCircle,
                onClickCallback = function()
                    local IsActive = info.IsActive
                    -- 是否已经选择了
                    if IsActive then 
                        ui.showFlashView({text = TR"该道具已经被选了！"})
                    else 
                        if header.tempSprite:isVisible() then -- 如果已经选中
                            CardNode.defaultCardClick({
                                resourceTypeSub = headerInfo.resourceTypeSub,
                                modelId = headerInfo.modelId,
                            })
                        else
                            for i,v in ipairs(headerList) do
                                if not tolua.isnull(v) then 
                                   v.tempSprite:setVisible(false)
                                end 
                            end

                            -- 把当前的头像选择点亮
                            header.tempSprite:setVisible(true)
                            self.mProId = info.Id
                        end 
                    end 
                end
            })
            header:setAnchorPoint(cc.p(0.5, 0.5))
            header:setPosition(positionList[k])
            header:setSwallowTouches(false)
            lvItem:addChild(header)
            local headerSize = header:getContentSize()
            -- 选中图片
            local tempSprite = ui.newSprite("c_31.png")
            tempSprite:setPosition(cc.p(headerSize.width/2, headerSize.height/2))
            header:addChild(tempSprite)
            header.tempSprite = tempSprite
            tempSprite:setVisible(false)
            table.insert(headerList, header)
            -- 是否已经选择
            if info.IsActive then 
                local doneSprite = ui.newSprite("c_170.png")
                doneSprite:setPosition(headerSize.width/2, headerSize.height/2)
                header:addChild(doneSprite)
            end     
        end    
    end
end

--请求信息
function WiseTreeSeclectLayer:requestGetInfo()
    HttpClient:request({
        moduleName = self.mTag == ModuleSub.eCommonHoliday18 and "TimedWishtree" or "TimedKongminglights", 
        methodName = "GetRewardInfo",
        svrMethodData = {self.mId},
        callbackNode = self,
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            -- dump(data, "ReceiveReward")
            -- 奖励列表
            self.mRewardInfo = data.Value or {}
            -- 刷新页面
            self:refreshLayer()
        end
    })
end

--请求信息
function WiseTreeSeclectLayer:requestSetReward()
    HttpClient:request({
        moduleName = self.mTag == ModuleSub.eCommonHoliday18 and "TimedWishtree" or "TimedKongminglights", 
        methodName = "SetReward",
        svrMethodData = {self.mId, self.mProId},
        callbackNode = self,
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            
            if self.mCallback then 
                self.mCallback()
            end 

            LayerManager.removeLayer(self)
        end
    })
end

return WiseTreeSeclectLayer