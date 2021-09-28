--[[
    文件名：ImprintSelectLayer.lua
    描述：选择宝石页面
    创建人：yanghongsheng
    创建时间： 2019.5.27
--]]

local ImprintSelectLayer = class("ActivityPigRankLayer", function(params)
    return display.newLayer()
end)

--[[
params:
    slotId      卡槽id
    part        选择部位
    callback    选择回调
]]

function ImprintSelectLayer:ctor(params)
    self.mSlotId = params.slotId
    self.mPartId = params.part
    self.mCallback = params.callback
    -- 宝石列表
    self.mImprintList = ImprintObj:getImprintList({notInFormation = true, partId = params.part})
    -- 排序
    table.sort(self.mImprintList, function (imprintInfo1, imprintInfo2)
        local imprintModel1 = ImprintModel.items[imprintInfo1.ModelId]
        local imprintModel2 = ImprintModel.items[imprintInfo2.ModelId]
        if imprintModel1.quality ~= imprintModel2.quality then
            return imprintModel1.quality > imprintModel2.quality
        end
        if imprintInfo1.Lv ~= imprintInfo2.Lv then
            return imprintInfo1.Lv > imprintInfo2.Lv
        end
        if imprintInfo1.TotalExp ~= imprintInfo2.TotalExp then
            return imprintInfo1.TotalExp > imprintInfo2.TotalExp
        end
    end)
    -- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(630, 900),
        title = TR("选择宝石"),
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 创建页面控件
    self:initUI()
end

function ImprintSelectLayer:initUI()
    -- 黑背景
    local listBgSize = cc.size(self.mBgSize.width-60, self.mBgSize.height-110)
    local listBg = ui.newScale9Sprite("c_17.png", listBgSize)
    listBg:setAnchorPoint(cc.p(0.5, 0))
    listBg:setPosition(self.mBgSize.width*0.5, 30)
    self.mBgSprite:addChild(listBg)
    -- 宝石列表
    local rewardListView = ccui.ListView:create()
    rewardListView:setDirection(ccui.ScrollViewDir.vertical)
    rewardListView:setBounceEnabled(true)
    rewardListView:setContentSize(cc.size(listBgSize.width-10, listBgSize.height-10))
    rewardListView:setItemsMargin(6)
    rewardListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    rewardListView:setAnchorPoint(cc.p(0.5, 0.5))
    rewardListView:setPosition(listBgSize.width*0.5, listBgSize.height*0.5)
    listBg:addChild(rewardListView)

    if self.mImprintList and next(self.mImprintList) then
        for _, imprintInfo in ipairs(self.mImprintList) do
            -- 创建cell
            local cellWidth, cellHeight = rewardListView:getContentSize().width, 130
            local customCell = ccui.Layout:create()
            customCell:setContentSize(cc.size(cellWidth, cellHeight))
            rewardListView:pushBackCustomItem(customCell)

            -- cell背景框
            local cellBg = ui.newScale9Sprite("c_18.png", cc.size(cellWidth, cellHeight))
            cellBg:setPosition(cellWidth * 0.5, cellHeight * 0.5)
            customCell:addChild(cellBg)

            local imprintModelId = imprintInfo.ModelId
            local imprintModel = ImprintModel.items[imprintModelId]

            -- 宝石卡牌
            local card = CardNode.createCardNode({
                resourceTypeSub = ResourcetypeSub.eImprint,
                modelId = imprintModelId,
                instanceData = imprintInfo,
                allowClick = false,
                cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eLevel},
            })
            card:setPosition(100, cellHeight*0.5)
            cellBg:addChild(card)
            -- 宝石名字
            local color = Utility.getQualityColor(imprintModel.quality, 1)
            local nameLabel = ui.newLabel({
                text = imprintModel.name,
                color = color,
                outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            })
            nameLabel:setAnchorPoint(cc.p(0, 0))
            nameLabel:setPosition(170, cellHeight*0.6)
            cellBg:addChild(nameLabel)
            -- 星数
            local starStr = ""
            for i = 1, imprintModel.stars do
                starStr = starStr .. "{c_75.png}"
            end
            local starLabel = ui.newLabel({
                text = starStr,
            })
            starLabel:setAnchorPoint(cc.p(0, 0))
            starLabel:setPosition(170, cellHeight*0.25)
            cellBg:addChild(starLabel)
            -- 选择按钮
            local selectBtn = ui.newButton({
                normalImage = "c_28.png",
                text = TR("选择"),
                clickAction = function(pSender)
                    self:requestImprintCombat(imprintInfo.Id)
                end,
            })
            selectBtn:setPosition(cellWidth*0.8, cellHeight*0.5)
            cellBg:addChild(selectBtn)
        end
    else
        local emptyHint = ui.createEmptyHint(TR("没有可以选择的宝石"))
        emptyHint:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.5)
        self.mBgSprite:addChild(emptyHint)
    end
end


--=========================服务器相关============================
-- 镶嵌宝石
function ImprintSelectLayer:requestImprintCombat(id)
    local resTypeList = {
        ResourcetypeSub.eWeapon,  -- "武器"
        ResourcetypeSub.eHelmet,  -- "头部"
        ResourcetypeSub.eClothes, -- "衣服"
        ResourcetypeSub.eNecklace,-- "项链"
        ResourcetypeSub.ePants,   -- "裤子"
        ResourcetypeSub.eShoe,    -- "鞋子"
    }
    local ret = {self.mSlotId}
    for _, resType in ipairs(resTypeList) do
        if resType == self.mPartId then
            table.insert(ret, id)
        else
            table.insert(ret, "")
        end
    end

    HttpClient:request({
        moduleName = "Slot",
        methodName = "OneKeyImprintCombat",
        svrMethodData = ret,
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- dump(response.Value)
            if self.mCallback then
                self.mCallback()
            end
            LayerManager.removeLayer(self)
        end
    })
end

return ImprintSelectLayer