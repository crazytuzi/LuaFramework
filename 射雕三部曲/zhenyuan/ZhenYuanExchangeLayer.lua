--[[
    文件名：ZhenYuanExchangeLayer.lua
    描述：真元兑换界面
    创建人：chenzhong
    创建时间： 2017.12.14
--]]

local ZhenYuanExchangeLayer = class("ZhenYuanExchangeLayer", function(params)
    return display.newLayer()
end)

function ZhenYuanExchangeLayer:ctor(params)
    -- package.loaded["zhenyuan.ZhenYuanExchangeLayer"] = nil
    -- 初始化经验值
    self.mPracticeNum = 0
    -- listView索引
    self.itemID = 1
    -- 背景图片
    local bgSprite = ui.newSprite("c_128.jpg")
    bgSprite:setPosition(320, 568)
    self:addChild(bgSprite)
    self.mBgSprite = bgSprite

    --下方白板背景
    local bottomSprtie = ui.newScale9Sprite("c_19.png", cc.size(640, 1015))
    bottomSprtie:setAnchorPoint(0.5, 0)
    bottomSprtie:setPosition(320, 0)
    bgSprite:addChild(bottomSprtie)

    --灰色底板
    local underBgSprite = ui.newScale9Sprite("c_17.png", cc.size(622, 825))
    underBgSprite:setPosition(320, 925)
    underBgSprite:setAnchorPoint(0.5, 1)
    bgSprite:addChild(underBgSprite)

    -- 添加修炼值显示
    local infoBgSprite = ui.newScale9Sprite("c_25.png", cc.size(300, 54))
    infoBgSprite:setAnchorPoint(0, 0.5)
    infoBgSprite:setPosition(10, 955)
    bgSprite:addChild(infoBgSprite)
    self.mSocreLabel = ui.newLabel({
        text = TR("当前修炼值: %s点", 0),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
        anchorPoint = cc.p(0.5, 0.5),
        x = 150,
        y = 27,
    })
    infoBgSprite:addChild(self.mSocreLabel)

    -- 获取修炼值信息
    self:requestGoodsList()
end

-- 刷新装备列表
function ZhenYuanExchangeLayer:refreshList()
    if self.mZhenYuanList then
        self.mZhenYuanList:removeFromParent()
        self.mZhenYuanList = nil
    end

    self.mZhenYuanList = ccui.ListView:create()
    self.mZhenYuanList:setPosition(320, 916)
    self.mZhenYuanList:setAnchorPoint(0.5, 1)
    self.mZhenYuanList:setContentSize(630, 810)
    self.mZhenYuanList:setDirection(ccui.ScrollViewDir.vertical)
    self.mZhenYuanList:setBounceEnabled(true)
    self.mBgSprite:addChild(self.mZhenYuanList)
 
    for i=1, ZhenyuanShopModel.items_count do
        self.mZhenYuanList:pushBackCustomItem(self:createItem(i))
    end

    ui.setListviewItemShow(self.mZhenYuanList, self.itemID)
end

-- 创建单个装备条目
function ZhenYuanExchangeLayer:createItem(index)
    local cellSize = cc.size(626, 150)
    local item = ZhenyuanShopModel.items[index]
    local lvItem = ccui.Layout:create()
    lvItem:setContentSize(cellSize)
    --背景
    local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(610, 142))
    bgSprite:setPosition(315, 75)
    lvItem:addChild(bgSprite)
    -- 商品信息
    local shopInfo = Utility.analysisStrResList(item.sellGoods)

    --前往按钮
    local lvUpBtn = ui.newButton({
        text = TR("兑 换"),
        normalImage = "c_28.png",
        clickAction = function ()
            if self.mPracticeNum < item.price then
                ui.showFlashView({text = TR("修炼值不足！")})
            else     
                -- 参数列表
                local params = {
                    title = TR("兑换"),                          
                    exchangePrice = item.price,     
                    modelID = shopInfo[1].modelId,               
                    typeID  = shopInfo[1].resourceTypeSub,                
                    resourcetypeCoin = Enums.ExchangeGoodsID.eZhenyuan,   --真元只能修炼值换(用自己定义的ID)          
                    maxNum = math.floor(self.mPracticeNum/item.price),                          
                    oKCallBack = function(exchangeCount, layerObj, btnObj)
                        LayerManager.removeLayer(layerObj)
                        self:requesExchange(item.ID, exchangeCount)
                    end,                      
                }
                MsgBoxLayer.addExchangeGoodsCountLayer(params)
            end
        end
    })
    lvUpBtn:setPosition(539, 65)
    lvItem:addChild(lvUpBtn)

    -- 真元头像
    local tempCard = CardNode.createCardNode({
        cardShowAttrs = {CardShowAttr.eBorder},
        resourceTypeSub = shopInfo[1].resourceTypeSub,
        modelId = shopInfo[1].modelId,
        allowClick = true, 
    })
    tempCard:setPosition(80, cellSize.height / 2)
    lvItem:addChild(tempCard)

    -- 真元个数
    local numLabel = ui.newLabel({
        text = string.format("%d", shopInfo[1].num),
        align = cc.TEXT_ALIGNMENT_LEFT,
        size = 20,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
    })
    numLabel:setAnchorPoint(cc.p(0.5, 0.5))
    numLabel:setPosition(tempCard:getContentSize().width/2, 16)
    tempCard:addChild(numLabel)

    -- 真元名字
    local goodsInfo = ZhenyuanModel.items[shopInfo[1].modelId]
    local nameColor =  Utility.getQualityColor(goodsInfo.quality, 1)
    local nameLabel = ui.newLabel({
        text = goodsInfo.name,
        color = nameColor,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        size = 24,
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(165, cellSize.height / 2 + 30)
    lvItem:addChild(nameLabel)

    -- 消耗
    local numColor =  self.mPracticeNum < item.price and Enums.Color.eRedH or Enums.Color.eDarkGreenH
    local conNumLabel = ui.newLabel({
        text = TR("修炼值: %s%d", numColor, item.price),
        color = Enums.Color.eBrown,
        align = cc.TEXT_ALIGNMENT_LEFT,
    })
    conNumLabel:setAnchorPoint(cc.p(0, 0.5))
    conNumLabel:setPosition(350, cellSize.height / 2 + 30)
    lvItem:addChild(conNumLabel)

    -- 真元的资质
    local qualityLabel = ui.newLabel({
        text = TR("资质: %s%d", Enums.Color.eDarkGreenH, goodsInfo.quality),
        color = Enums.Color.eBrown,
        align = cc.TEXT_ALIGNMENT_LEFT,
    })
    qualityLabel:setAnchorPoint(cc.p(0, 0.5))
    qualityLabel:setPosition(165, cellSize.height / 2 - 5)
    lvItem:addChild(qualityLabel)

    -- 属性显示
    local attrStr = self:getZhenyuanAttrStr(0, shopInfo[1].modelId) -- 默认1级
    local attrLabel = ui.newLabel({
        text = attrStr,
        color = Enums.Color.eBrown,
        align = cc.TEXT_ALIGNMENT_CENTER,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
    })
    attrLabel:setAnchorPoint(cc.p(0, 0.5))
    attrLabel:setPosition(165, cellSize.height / 2 -40)
    lvItem:addChild(attrLabel)

    return lvItem
end

-- 获取真元的属性列表
function ZhenYuanExchangeLayer:getZhenyuanAttrStr(curLv, modelId)
    -- 是否满级
    if not ZhenyuanLvUpRelation.items[curLv] then return end

    -- 属性列表
    local attrList = {}

    -- 真元属性信息
    local zhenyuanModel = ZhenyuanModel.items[modelId]
    local baseAtrrList = Utility.analysisStrAttrList(zhenyuanModel.basicAttr)
    local upAtrrList = Utility.analysisStrAttrList(zhenyuanModel.attrUP)

    -- 获取属性加入列表
    for _, upAttr in pairs(upAtrrList) do
        upAttr.value = upAttr.value*curLv
        attrList[upAttr.fightattr] = upAttr.value
    end
    for _, baseAtrrList in pairs(baseAtrrList) do
        attrList[baseAtrrList.fightattr] = (attrList[baseAtrrList.fightattr] or 0) + baseAtrrList.value
    end

    -- 将属性信息转化为字符串
    local attrStrList = {}
    for fightattr, value in pairs(attrList) do
        local text = FightattrName[fightattr]..Utility.getAttrViewStr(fightattr, value)
        table.insert(attrStrList, text)
    end

    return table.concat(attrStrList, ",")
end

-- 购买
function ZhenYuanExchangeLayer:requesExchange(shopId, count)
    HttpClient:request({
        moduleName = "ZhenyuanRecruitInfo",
        methodName = "Exchange",
        svrMethodData = {shopId, count},
        callbackNode = self,
        callback = function(data)
            -- dump(data, "信息：")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            self.itemID = shopId

            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
            -- 刷新修炼值
            self.mPracticeNum = data.Value.RecruitInfo.PracticeNum or 0
            if not tolua.isnull(self.mSocreLabel) then 
                self.mSocreLabel:setString(TR("当前修炼值: %s%s点", Enums.Color.eYellowH, data.Value.RecruitInfo.PracticeNum or 0))
            end 
            -- 创建列表
            self:refreshList()    
        end
    })
end

-- 请求服务器，获取所有要显示的道具的信息
function ZhenYuanExchangeLayer:requestGoodsList()
    HttpClient:request({
        moduleName = "ZhenyuanRecruitInfo",
        methodName = "GetInfo",
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
 
            -- 刷新修炼值
            self.mPracticeNum = data.Value.RecruitInfo.PracticeNum or 0
            if not tolua.isnull(self.mSocreLabel) then 
                self.mSocreLabel:setString(TR("当前修炼值: %s%s点", Enums.Color.eYellowH, data.Value.RecruitInfo.PracticeNum or 0))
            end 
            -- 创建列表
            self:refreshList()    
        end
    })
end

return ZhenYuanExchangeLayer
