--[[
    文件名：HeroFashionHomeLayer.lua
    描述：侠客时装列表子页面
    创建人: yanghongsheng
    创建时间: 2018.6.17
--]]

local HeroFashionSubView = class("HeroFashionSubView", function(params)
    return cc.Node:create()
end)

--[[
-- 参数 params 中各项为：
    {
        heroId: 侠客实例Id
        viewSize: 显示大小，必选参数
        callback: 回调接口
    }
]]
function HeroFashionSubView:ctor(params)
    -- 读取参数
    self.mHeroId = params.heroId
    local heroInfo = HeroObj:getHero(self.mHeroId)
    self.mHeroModelId = heroInfo.ModelId
    if heroInfo.IllusionModelId and heroInfo.IllusionModelId > 0 then
        self.mHeroModelId = heroInfo.IllusionModelId
    end
    self.viewSize = params.viewSize
    self.callback = params.callback
    self.fashionList = {}           -- 所有时装列表
    self.selectModelId = nil
    
    -- 初始化
    self:setContentSize(self.viewSize)
    
    -- 显示界面
    self:initUI()
    self:refreshData()
    self:refreshUI()
end

-- 初始化UI
function HeroFashionSubView:initUI()
    -- 属性背景
    local attrBgSize = cc.size(self.viewSize.width - 20, 90)
    local attrBgSprite = ui.newScale9Sprite("c_18.png", attrBgSize)
    attrBgSprite:setAnchorPoint(cc.p(0.5, 1))
    attrBgSprite:setPosition(cc.p(self.viewSize.width * 0.5, self.viewSize.height - 5))
    self:addChild(attrBgSprite)
    self.attrBgSprite = attrBgSprite

    -- 中间背景
    local centerBgSprite = ui.newSprite("zr_54.jpg")
    centerBgSprite:setAnchorPoint(cc.p(0.5, 0))
    centerBgSprite:setPosition(self.viewSize.width * 0.5, 235)
    self:addChild(centerBgSprite)
    self.centerBgSprite = centerBgSprite

    -- 属性总览按钮
    local btnAttr = ui.newButton({
        normalImage = "mp_43.png",
        clickAction = function()
            LayerManager.addLayer({name = "fashion.HeroFashionDlgAttrLayer", data = {heroId = self.mHeroId}, cleanUp = false,})
        end
    })
    btnAttr:setPosition(60, self.viewSize.height * 0.7 + 20)
    self:addChild(btnAttr)

    -- 列表背景
    local listBgSize = cc.size(self.viewSize.width - 20, 144)
    local listBgSprite = ui.newScale9Sprite("c_65.png", listBgSize)
    listBgSprite:setAnchorPoint(cc.p(0.5, 0))
    listBgSprite:setPosition(cc.p(self.viewSize.width * 0.5, 80))
    self:addChild(listBgSprite)

    -- 头像列表
    local mCellSize = cc.size(130, listBgSize.height)
    local mSliderView = ui.newSliderTableView({
        width = listBgSize.width - 20,
        height = listBgSize.height,
        isVertical = false,
        selItemOnMiddle = false,
        itemCountOfSlider = function(sliderView)
            return #self.fashionList
        end,
        itemSizeOfSlider = function(sliderView)
            return mCellSize.width, mCellSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
            local itemData = self.fashionList[index + 1]
            local showAttrs = {CardShowAttr.eBorder, CardShowAttr.eName}
 
            if (self.selectModelId == itemData.baseInfo.ID) then
                -- 选中框
                table.insert(showAttrs, CardShowAttr.eSelected)
            end
            if (itemData.isDressIn ~= nil) and (itemData.isDressIn == true) then
                -- 已上阵
                table.insert(showAttrs, CardShowAttr.eBattle)
            end
            local tempCard = require("common.CardNode").new({
                allowClick = true,
                onClickCallback = function()
                    self.selectModelId = itemData.baseInfo.ID
                    self:refreshUI()
                end
            })
            tempCard:setPosition(mCellSize.width / 2, mCellSize.height / 2 + 12)
            tempCard:setHero({ModelId = self.mHeroModelId}, showAttrs)
            if (itemData.isOwned == nil) or (itemData.isOwned == false) then
                local lockSprite = ui.newSprite("bsxy_14.png")
                lockSprite:setPosition(48, 48)
                tempCard:addChild(lockSprite, 2)
                tempCard.mBgSprite:setGray(true)
            end
            itemNode:addChild(tempCard)
        end,
        selectItemChanged = function(sliderView, selectIndex)
        end
    })
    mSliderView:setTouchEnabled(true)
    mSliderView:setAnchorPoint(cc.p(0.5, 0.5))
    mSliderView:setPosition(listBgSize.width / 2, listBgSize.height / 2)
    listBgSprite:addChild(mSliderView)
    self.mSliderView = mSliderView

    -- 保存按钮
    local btnSave = ui.newButton({
        normalImage = "c_28.png",
        text = TR("上阵"),
        clickAction = function()
            local currData = self:getSelectedFashion()
            if (currData.isOwned ~= nil) and (currData.isOwned == true) then
                -- 使用
                self:requestDressUp(currData.baseInfo.ID)
            else
                ui.showFlashView("请关注运营活动")
            end
        end
    })
    btnSave:setPosition(self.viewSize.width * 0.5, 40)
    self:addChild(btnSave)
    self.btnSave = btnSave
end

-- 刷新数据
function HeroFashionSubView:refreshData()
    self.fashionList = {}
    local heroInfo = HeroObj:getHero(self.mHeroId)
    -- 上阵时装id
    local combatId = heroInfo.CombatFashionOrder
    -- 激活时装id列表
    local activelist = {}
    if heroInfo.ActivatedFashionStr ~= "" then
        for _, activeId in pairs(string.splitBySep(heroInfo.ActivatedFashionStr, ",")) do
            activelist[tonumber(activeId)] = true
        end
    end
    -- 添加侠客
    local playerInfo = IllusionModel.items[self.mHeroModelId] or HeroModel.items[self.mHeroModelId]
    local playerItem = {
        baseInfo = {
            ID = 0, 
            name = playerInfo.name,
            actionPic = playerInfo.largePic,
        },
        isDressIn = combatId == 0,
        isOwned = true,
    }
    table.insert(self.fashionList, playerItem)

    -- 添加所有时装
    for _,v in pairs(clone(HeroFashionRelation.items)) do
        if v.modelId == self.mHeroModelId then
            local tmpV = {baseInfo = {
                ID = v.Id, 
                name = v.fashionName, 
                actionPic = v.largePic,
            }}
            tmpV.isOwned = activelist[v.Id] and true or false
            tmpV.isDressIn = combatId == v.Id

            table.insert(self.fashionList, tmpV)
        end
    end
    table.sort(self.fashionList, function (a, b)
            if (a.baseInfo.ID == 0) then
                return true
            end
            if (b.baseInfo.ID == 0) then
                return false
            end
            if (a.isOwned ~= b.isOwned) then
                return (a.isOwned == true)
            end
            return a.baseInfo.ID < b.baseInfo.ID
        end)

    -- 默认选择顺序：优先选择已上阵，如果没有的话就选主角
    if (self.selectModelId == nil) then
        self.selectModelId = 0
        for _,v in ipairs(self.fashionList) do
            if (v.isDressIn) then
                self.selectModelId = v.baseInfo.ID
                break
            end
        end
    end
end

-- 刷新界面
function HeroFashionSubView:refreshUI()
    -- 读取选中的绝学
    local currData = self:getSelectedFashion()
    
    -- 刷新列表
    self.mSliderView:reloadData()

    -- 刷新详情
    if (self.centerBgSprite.refreshNode == nil) then
        self.centerBgSprite.refreshNode = function (target, newData)
            target:removeAllChildren()
            if (newData == nil) then
                return
            end

            -- 显示名字
            local strName = newData.baseInfo.name
            local centerBgSize = target:getContentSize()
            local nameLabel = ui.createLabelWithBg({
                bgFilename = "zr_50.png",
                labelStr = strName,
                fontSize = 24,
                color = cc.c3b(0x51, 0x18, 0x0d),
                alignType = ui.TEXT_ALIGN_CENTER
            })
            nameLabel:setPosition(centerBgSize.width * 0.5, centerBgSize.height - 30)
            target:addChild(nameLabel)

            -- 显示大图
            Figure.newHero({
                parent = target,
                figureName = newData.baseInfo.actionPic,
                position = cc.p(centerBgSize.width / 2, 30),
                scale = 0.27,
                async = function (figureNode)
                end,
            })
        end
    end
    self.centerBgSprite:refreshNode(currData)

    -- 刷新属性
    if (self.attrBgSprite.refreshNode == nil) then
        self.attrBgSprite.refreshNode = function (target, newData)
            target:removeAllChildren()
            if (newData == nil) then
                return
            end

            -- 显示属性
            local function addAttrLabel(strName, strValue, pos)
                local strText = strName
                if (strValue ~= nil) then
                    strText = strName .. "#D38212+" .. strValue
                end
                local label = ui.newLabel({
                    text = strText,
                    color = cc.c3b(0x46, 0x22, 0x0d),
                    size = 22,
                })
                label:setAnchorPoint(cc.p(0, 0.5))
                label:setPosition(pos)
                target:addChild(label)
            end
            -- 读取属性
            local attrList = self:getFashionAttr(newData)
            if (attrList == nil) then
                -- 主角无属性加成
                local label = ui.newLabel({
                    text = TR("无属性加成"),
                    color = cc.c3b(0x46, 0x22, 0x0d),
                    size = 24,
                })
                label:setAnchorPoint(cc.p(0.5, 0.5))
                label:setPosition(cc.p(self.viewSize.width * 0.5 - 10, 45))
                target:addChild(label)
                return 
            end
            -- 显示时装属性
            addAttrLabel(TR("激活属性:"), nil, cc.p(0, 64))
            local posXList = {102, 254, 394}
            local col = 3
            for j=1, math.ceil(#attrList/col) do
                for i=1, col do
                    local v = attrList[(j-1)*col+i]
                    if not v then break end

                    addAttrLabel(FightattrName[tonumber(v[1])], v[2], cc.p(posXList[i], 64-(j-1)*30))
                end
            end
        end
    end
    self.attrBgSprite:refreshNode(currData)

    -- 刷新按钮状态
    if (currData.isOwned ~= nil) and (currData.isOwned == true) then
        -- 已拥有
        self.btnSave.mTitleLabel:setString(TR("上阵"))
    else
        -- 未拥有
        self.btnSave.mTitleLabel:setString(TR("去获取"))
    end
    -- 已经穿戴的禁止点击
    self.btnSave:setEnabled(not ((currData.isDressIn ~= nil) and (currData.isDressIn == true)))
end

----------------------------------------------------------------------------------------------------
-- 辅助接口

-- 获取当前选中的时装数据
function HeroFashionSubView:getSelectedFashion()
    -- 读取选中的绝学
    local currData = nil
    for _,v in ipairs(self.fashionList) do
        if (self.selectModelId == v.baseInfo.ID) then
            currData = clone(v)
            break
        end
    end
    return currData
end

-- 读取某个时装的属性
function HeroFashionSubView:getFashionAttr(itemData)
    if (itemData == nil) or (itemData.baseInfo == nil) or (itemData.baseInfo.ID == 0) then
        return nil
    end
    -- 读取配置
    local modelId = itemData.baseInfo.ID
    local modelInfo = HeroFashionRelation.items[itemData.baseInfo.ID]
    
    -- 读取基础属性和穿戴属性
    local retAttrList = {}
    for _, attrInfo in ipairs(Utility.analysisStrAttrList(modelInfo.openAttrStr)) do
        local curList = {attrInfo.fightattr, attrInfo.value}
        table.insert(retAttrList, curList)
    end

    return retAttrList
end

-- 穿戴时装
function HeroFashionSubView:requestDressUp(ID)
    HttpClient:request({
        moduleName = "Hero",
        methodName = "CombatFashion",
        svrMethodData = {self.mHeroId, ID},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            HeroObj:modifyHeroItem(response.Value)
            self:refreshData()
            self:refreshUI()
            if self.callback then
                self.callback()
            end
        end,
    })
end

----------------------------------------------------------------------------------------------------

return HeroFashionSubView