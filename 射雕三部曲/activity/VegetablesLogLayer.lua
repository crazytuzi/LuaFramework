--[[
    文件名: VegetablesLogLayer
    描述: 种菜公告牌
    创建人: chenzhong
    创建时间: 2017.03.27
-- ]]

local VegetablesLogLayer = class("VegetablesLogLayer",function()
    return display.newLayer()
end)

function VegetablesLogLayer:ctor(params)
    -- 显示谁的公告牌没有默认显示自己的
    self.mGuildId = params.playerId or PlayerAttrObj:getPlayerAttrByName("PlayerId")
    -- 是否是自己
    self.mMySelf = self.mGuildId == PlayerAttrObj:getPlayerAttrByName("PlayerId")
    --初始化页面控件
    self:initUI()

    --请求数据
    self:requestGetGuildBuildLog()
end

function VegetablesLogLayer:initUI()
    local popBgLayer = require("commonLayer.PopBgLayer"):create({
        bgSize = cc.size(496, 486),
        title = TR("公告牌"),
        })
    self:addChild(popBgLayer)
    
    self.mBgSprite = popBgLayer.mBgSprite
    self.mBgWidth = popBgLayer.mBgSize.width
    self.mBgHeight = popBgLayer.mBgSize.height

    -- 添加背景
    local bgSprite = ui.newScale9Sprite("c_17.png", cc.size(430, 300))
    bgSprite:setAnchorPoint(cc.p(0.5, 0))
    bgSprite:setPosition(self.mBgWidth * 0.5, 120)
    self.mBgSprite:addChild(bgSprite)

    --确定按钮
    local ensureBtn = ui.newButton({
        normalImage = "c_28.png",
        position = cc.p(239, 70),
        text = TR("确定"),
        clickAction = function (sender)
            LayerManager.removeLayer(self)
        end
    })
    self.mBgSprite:addChild(ensureBtn)
end

function VegetablesLogLayer:reFreshListView(data)
    if #data == 0 then
        local lblEmptyHint = ui.newLabel({
            text = TR("暂时没有公告日志"),
            size = 28,
            x = 239,
            y = 270,
            color = Enums.Color.eBlack,
            dimensions = cc.size(350, 0),
            align = cc.TEXT_ALIGNMENT_CENTER,
        })
        self.mBgSprite:addChild(lblEmptyHint)
        return
    end

    --listData  一条记录的信息
    local function createItem(listData)
        local lvItem = ccui.Layout:create()

        -- 时间Text
        local leftTime = Player:getCurrentTime() - listData.Crdate 
        local timeText =  string.format("%s", MqTime.toDownFormat(leftTime))
        -- 内容Text
        local contentText = ""
        if listData.OperateType == 1 then --偷取
            contentText = TR("#FF974A%s#ffffff悄悄的%s#FF974A%s#ffffff的",
                listData.OperatorName, 
                TR("偷取了"), 
                self.mMySelf and TR("您") or self.mMasterName)

            local info = Utility.analysisStrResList(listData.Content)
            for i,goodInfo in ipairs(info) do
                local goodName = Utility.getGoodsName(goodInfo.resourceTypeSub, goodInfo.modelId)
                local goodQuality = Utility.getQualityByModelId(goodInfo.modelId, goodInfo.resourceTypeSub)
                local goodColor = Utility.getQualityColor(goodQuality, 2)
                contentText = contentText..string.format("%s%s*%s  ", goodColor, goodName, goodInfo.num)
            end
        elseif listData.OperateType == 2 then --施肥
            contentText = TR("#FF974A%s#ffffff悄悄的给#ffffff%s#ffffff%s", 
                listData.OperatorName, 
                self.mMySelf and TR("您") or self.mMasterName, 
                TR("雇佣了铁匠"))
        end 

        local introLabel = ui.newLabel({
            text = string.format("%s   %s", timeText, contentText),
            size = 20,
            -- color = cc.c3b(0x46, 0x22, 0x0d),
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            anchorPoint = cc.p(0, 0.5),
            dimensions = cc.size(400, 0),
        })
        lvItem:addChild(introLabel)

        local labelHeight = introLabel:getContentSize().height
        lvItem:setContentSize(cc.size(350, labelHeight))
        introLabel:setPosition(40, labelHeight/2)

        return lvItem
    end

    --列表
    self.logListView = ccui.ListView:create()
    self.logListView:setContentSize(cc.size(470, 285))
    self.logListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.logListView:setPosition(cc.p(239, 265))
    self.logListView:setItemsMargin(10)
    self.logListView:setBounceEnabled(true)
    self.mBgSprite:addChild(self.logListView)

    for _,v in ipairs(data) do
        self.logListView:pushBackCustomItem(createItem(v))
    end
end

-- =============================== 请求服务器数据相关函数 ===================

--获取帮派建设日志
function VegetablesLogLayer:requestGetGuildBuildLog()
    HttpClient:request({
        moduleName = "TimedVegetablesInfo",
        methodName = "GetRecentRecord",
        svrMethodData = {self.mGuildId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- dump(response,"response")
            self.mMasterName = response.Value.MasterName or ""
            self:reFreshListView(response.Value.RecordList or {})
        end,
    })
end

return VegetablesLogLayer