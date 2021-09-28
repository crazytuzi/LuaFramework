--[[
    文件名: DesignationBagLayer.lua
    描述：称号包裹页面
    创建人：peiyaoqiang
    创建时间：2018.04.20
--]]

local DesignationBagLayer = class("DesignationBagLayer", function(params)
    return display.newLayer()
end)

--[[
--]]
function DesignationBagLayer:ctor(params)
    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

    -- 数据处理
    self.ownedList = {}
    self.countList = {}

    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eFormation,
        topInfos = {
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eGold,
            ResourcetypeSub.eVIT,
        }
    })
    self:addChild(topResource, 1)

    -- 页面控件的父对象
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
  
    -- 退出按钮
    local btnClose = ui.newButton({
        normalImage = "c_29.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(btnClose, 1)

    -- 初始化页面控件并刷新
    self:initUI()
    self:requestGetInfo()
end

-- 初始化页面控件
function DesignationBagLayer:initUI()
    -- 背景图
    local bgSprite = ui.newSprite("c_128.jpg")
    bgSprite:setAnchorPoint(cc.p(0.5, 1))
    bgSprite:setPosition(320, 1136)
    self.mParentLayer:addChild(bgSprite)
    
    -- 操作面板
    local ctrlSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 1000))
    ctrlSprite:setAnchorPoint(0.5, 0)
    ctrlSprite:setPosition(320, 0)
    self.mParentLayer:addChild(ctrlSprite)
    
    -- 属性加成框
    local attrBgNode = ui.newSprite("ch_01.png")
    attrBgNode:setAnchorPoint(cc.p(0.5, 1))
    attrBgNode:setPosition(320, 980)
    ctrlSprite:addChild(attrBgNode)

    self.attrBgNode = attrBgNode
    self.attrBgNode.refreshNode = function (target)
        target:removeAllChildren()
        
        -- 保存头像框
        local currModelId = self:getBorderOfCombat()
        PlayerAttrObj:changeAttr({DesignationId = (currModelId or 0)})

        -- 读取当前的头像
        local tempCard = require("common.CardNode").new({allowClick = false})
        tempCard:setHero({HeroModelId = PlayerAttrObj:getPlayerInfo().HeadImageId, FashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId"), pvpInterLv = currModelId}, {CardShowAttr.eBorder})
        tempCard:setPosition(110, 85)
        target:addChild(tempCard)

        -- 显示属性标题
        local tempLabel = ui.newLabel({
            text = TR("称号属性加成总览"),
            size = 25,
            color = Enums.Color.eNormalWhite,
            outlineColor = cc.c3b(0xa2, 0x4b, 0x41),
        })
        tempLabel:setPosition(cc.p(385, 122))
        target:addChild(tempLabel)

        -- 显示加成属性
        local strAttr = self:formatAttrStr(self:getAllBorderAttr())
        if (table.nums(self.ownedList) == 0) then
            strAttr = TR("暂未激活任何称号")
        end
        local attrLabel = ui.newLabel({
            text = strAttr,
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 18,
            align = cc.TEXT_ALIGNMENT_CENTER,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
            dimensions = cc.size(410, 0)
        })
        attrLabel:setAnchorPoint(cc.p(0.5, 1))
        attrLabel:setPosition(385, 95)
        target:addChild(attrLabel)
    end

    -- 提示文字
    local infoLabel = ui.newLabel({
        text = TR("称号解锁即可获得属性，可叠加"),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 20
    })
    infoLabel:setAnchorPoint(cc.p(0, 0.5))
    infoLabel:setPosition(20, 790)
    ctrlSprite:addChild(infoLabel)

    -- 持续时间
    local timeLabel = ui.newLabel({
        text = "",
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 20
    })
    timeLabel:setAnchorPoint(cc.p(1, 0.5))
    timeLabel:setPosition(620, 790)
    ctrlSprite:addChild(timeLabel)
    self.timeLabel = timeLabel

    -- 称号预览框
    local previewNode = ui.newScale9Sprite("c_65.png",cc.size(620, 170))
    previewNode:setAnchorPoint(0.5, 0)
    previewNode:setPosition(cc.p(320, 110))
    ctrlSprite:addChild(previewNode)

    self.previewNode = previewNode
    self.previewNode.refreshNode = function (target, item)
        target:removeAllChildren()
        if (item == nil) or (item.pic == nil) then
            return
        end

        -- 显示头像
        local headerSprite = ui.newSprite(item.pic .. ".png")
        headerSprite:setPosition(90, 85)
        target:addChild(headerSprite)

        if (item.effectCode ~= "") then
            -- 显示头像框特效
            ui.newEffect({
                parent = target,
                effectName = item.effectCode,
                position = cc.p(90, 85),
                loop = true,
            })
        end

        -- 显示完成条件和属性加成
        local function createLabel(strText, dimensions, anchor, posY)
            local label = ui.newLabel({
                text = strText,
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 20,
                align = cc.TEXT_ALIGNMENT_LEFT,
                valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
                dimensions = dimensions
            })
            label:setAnchorPoint(anchor)
            label:setPosition(170, posY)
            target:addChild(label)
        end
        local config = DesignationTypeModel.items[item.typeID]
        -- 特殊处理几个渠道称号的达成条件
        if item.ID == 71 or item.ID == 72 then
            createLabel(TR("达成条件: 游戏fan渠道专属称号"), cc.size(300, 50), cc.p(0, 0), 85)
        elseif item.ID == 73 or item.ID == 74 then
            createLabel(TR("达成条件: tt渠道专属称号"), cc.size(300, 50), cc.p(0, 0), 85)
        elseif item.ID == 75 or item.ID == 76 or item.ID == 77 then
            createLabel(TR("达成条件: 果盘渠道专属称号"), cc.size(300, 50), cc.p(0, 0), 85)
        else
            createLabel(TR("达成条件") .. ": " .. self:formatDestStr(item, config), cc.size(300, 50), cc.p(0, 0), 85)
        end
        createLabel(TR("属性加成") .. ": " .. self:formatAttrStr(Utility.analysisStrFashionAttrList(item.allAttr)), cc.size(300, 0), cc.p(0, 1), 80)
        self:getContinueTime(item, config)
        
        -- 显示佩戴按钮
        local isOwned = self:isBorderOwned(item.ID)
        local isCombat = self:isBorderCombat(item.ID)
        local strText = (isOwned == true) and TR("佩戴") or TR("获取")
        if (isCombat == true) then
            strText = TR("卸下")
        end
        local button = ui.newButton({
            normalImage = (isOwned == true) and "c_33.png" or "c_28.png",
            text = strText,
            clickAction = function()
                if (isOwned == true) then
                    self:requestCombat((isCombat == true) and 0 or item.ID)
                else
                    LayerManager.showSubModule(config.modelID)
                end
            end
        })
        button:setAnchorPoint(cc.p(0, 0.5))
        button:setPosition(480, 85)
        target:addChild(button)
    end

    -- 列表背景框
    local lisgBgNode = ui.newScale9Sprite("c_24.png", cc.size(620, 470))
    lisgBgNode:setAnchorPoint(0.5, 0)
    lisgBgNode:setPosition(cc.p(320, 290))
    ctrlSprite:addChild(lisgBgNode)
    self.lisgBgNode = lisgBgNode
    self.listBgSize = self.lisgBgNode:getContentSize()
end

-- 刷新页面
function DesignationBagLayer:refreshUI()
    -- 删除头像框列表
    if (self.mGridView ~= nil) then
        self.mGridView:removeFromParent()
        self.mGridView = nil
    end

    -- 重建头像框列表
    local dataList = {}
    for _,v in pairs(DesignationPicRelation.items) do
        if (v.hide == 0) or (self:isBorderOwned(v.ID) == true) then
            -- 暂时屏蔽地宫称号
            local notOpenList = {80, 81, 82, 83}
            if not table.indexof(notOpenList, v.ID) then
                table.insert(dataList, clone(v))
            end
        end
    end
    table.sort(dataList, function (a, b)
            -- 已激活的靠前
            local aOwned = self:isBorderOwned(a.ID)
            local bOwned = self:isBorderOwned(b.ID)
            if (aOwned ~= bOwned) then
                return (aOwned == true)
            end

            -- 类型相同的在一起
            if (a.typeID ~= b.typeID) then
                return a.typeID < b.typeID
            end

            return a.ID < b.ID
        end)
    local gridWidth = self.listBgSize.width / 4
    self.mGridView = require("common.GridView"):create({
        viewSize = self.listBgSize,
        selectIndex = 1,
        colCount = 4,
        getCountCb = function()
            return #dataList
        end,
        createColCb = function(itemParent, colIndex, isSelected)
            -- 是否选中
            local curItem = dataList[colIndex]
            local isOwned = self:isBorderOwned(curItem.ID)
            if isSelected then
                local selectSprite = ui.newSprite("c_31.png")
                selectSprite:setPosition(gridWidth / 2, gridWidth / 2)
                selectSprite:setScale(1.25)
                itemParent:addChild(selectSprite)

                -- 选中
                self.previewNode:refreshNode(curItem)
            end
            
            -- 显示头像框
            local button = ui.newButton({
                normalImage = curItem.pic .. ".png",
                clickAction = function()
                    self.mGridView:setSelect(colIndex)
                end
            })
            button:setPressedActionEnabled(false)
            button:setPosition(gridWidth / 2, gridWidth / 2)
            button:setBright(isOwned)
            itemParent:addChild(button)

            -- 显示头像框特效（仅限于已激活）
            if (isOwned == true) and (curItem.effectCode ~= "") then
                ui.newEffect({
                    parent = itemParent,
                    effectName = curItem.effectCode,
                    position = cc.p(gridWidth / 2, gridWidth / 2),
                    loop = true,
                })
            end

            -- 是否已穿戴
            if (self:isBorderCombat(curItem.ID) == true) then
                local useSprite = ui.newSprite("c_173.png")
                useSprite:setAnchorPoint(cc.p(0, 1))
                useSprite:setPosition(10, gridWidth - 10)
                itemParent:addChild(useSprite)
            end

            -- 是否已拥有
            if (isOwned == false) then
                local lockSprite = ui.newSprite("c_35.png")
                lockSprite:setPosition(gridWidth / 2, gridWidth / 2)
                itemParent:addChild(lockSprite)
            end
        end,
    })
    self.mGridView:setPosition(self.listBgSize.width / 2, self.listBgSize.height / 2)
    self.lisgBgNode:addChild(self.mGridView)

    -- 刷新加成属性
    self.attrBgNode:refreshNode()
end    

----------------------------------------------------------------------------------------------------

-- 读取包裹信息的接口
function DesignationBagLayer:requestGetInfo()
    HttpClient:request({
        moduleName = "Designation",
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return 
            end
            -- 保存拥有的称号列表
            self.ownedList = clone(response.Value.DesignationList)
            self.countList = clone(response.Value.DesignationNumInfo)

            -- 刷新界面
            self:refreshUI()
        end
    })
end

-- 读取包裹信息的接口
function DesignationBagLayer:requestCombat(modelId)
    HttpClient:request({
        moduleName = "Designation",
        methodName = "Replace",
        svrMethodData = {modelId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return 
            end
            -- 保存拥有的称号列表
            self.ownedList = clone(response.Value.DesignationList)
            self.countList = clone(response.Value.DesignationNumInfo)

            -- 刷新列表
            local mViewPos = cc.p(self.mGridView.mScrollView:getInnerContainer():getPosition())
            self.mGridView:reloadData()
            self.mGridView.mScrollView:getInnerContainer():setPosition(mViewPos)

            -- 刷新加成属性
            self.attrBgNode:refreshNode()
        end
    })
end

----------------------------------------------------------------------------------------------------

-- 辅助：判断某个头像框是否已获取
function DesignationBagLayer:isBorderOwned(modelId)
    for _,v in ipairs(self.ownedList or {}) do
        if (modelId == v.Id) then
            return true
        end
    end
    return false
end

-- 辅助：判断某个头像框是否已佩戴
function DesignationBagLayer:isBorderCombat(modelId)
    for _,v in ipairs(self.ownedList or {}) do
        if (modelId == v.Id) and (v.IsCombat ~= nil) and (v.IsCombat == true) then
            return true
        end
    end
    return false
end

-- 辅助：返回当前佩戴的头像框
function DesignationBagLayer:getBorderOfCombat()
    for _,v in ipairs(self.ownedList or {}) do
        if (v.IsCombat ~= nil) and (v.IsCombat == true) then
            return v.Id
        end
    end
    return nil
end

-- 辅助：读取称号的有效时间
function DesignationBagLayer:getContinueTime(item, config)
    -- 读取剩余有效时间
    local nEndTime = 0
    for _,v in ipairs(self.ownedList or {}) do
        if (item.ID == v.Id) then
            nEndTime = tonumber(v.EndDate)
        end
    end

    -- 停止其他称号的倒计时
    self.timeLabel:stopAllActions()

    -- 大于14表示永久
    if (config.duration > 14) then
        self.timeLabel:setString(TR("称号有效时间:") .. Enums.Color.eNormalGreenH .. TR("永久"))
    else
        -- 如果剩余有效时间不合法，就读取配置显示
        local function valueActionUpdate(dt)
            local lastTime = nEndTime - Player:getCurrentTime()
            if (lastTime > 0) then
                self.timeLabel:setString(TR("剩余有效时间:") .. Enums.Color.eNormalGreenH .. MqTime.formatAsDay(lastTime))
            else
                self.timeLabel:setString(TR("称号有效时间:") .. Enums.Color.eNormalGreenH .. TR("%s天", config.duration))
            end
        end
        Utility.schedule(self.timeLabel, valueActionUpdate, 0.5)
    end
end

-- 构造要显示的达成条件字符串
function DesignationBagLayer:formatDestStr(item, config)
    local tmpCount = nil
    for _,v in ipairs(self.countList or {}) do
        if (v.TypeId == config.typeID) then
            tmpCount = tonumber(v.Num)
        end
    end
    if (tmpCount == nil) then
        return string.format(config.reachedIntroFormat, item.showIntro)
    end

    -- 如果存在次数，则需要拆分字符串重新组合
    local tmpList = string.split(config.reachedIntroFormat, "%s")
    local strColor = Enums.Color.eNormalGreenH
    if (tmpCount < tonumber(item.condition)) then
        strColor = Enums.Color.eRedH
    end
    return string.format("%s%s%s%s/%s%s%s", tmpList[1], strColor, tmpCount, Enums.Color.eNormalGreenH, item.condition, "#46220D", tmpList[2])
end

-- 构造要显示的加成属性字符串
function DesignationBagLayer:formatAttrStr(attrList)
    local strAttr = ""
    for i,v in ipairs(attrList) do
        strAttr = strAttr .. "#46220D"
        if (i ~= 1) then
            strAttr = strAttr .. ", "
        end
        strAttr = strAttr .. Utility.getRangeStr(v.range) .. string.format("%s%s+", FightattrName[v.fightattr], "#258711")
        if (v.fightattr == Fightattr.eAPR) or (v.fightattr == Fightattr.eHPR) or (v.fightattr == Fightattr.eDEFR) or 
           (v.fightattr == Fightattr.eCPR) or (v.fightattr == Fightattr.eBCPR) or 
           (v.fightattr == Fightattr.eDAMADDR) or (v.fightattr == Fightattr.eDAMCUTR) or 
           (v.fightattr == Fightattr.eRADAMADDR) or (v.fightattr == Fightattr.eRADAMCUTR) or 
           (v.fightattr == Fightattr.eRBDAMADDR) or (v.fightattr == Fightattr.eRBDAMCUTR) or 
           (v.fightattr == Fightattr.eRCDAMADDR) or (v.fightattr == Fightattr.eRCDAMCUTR) or 
           (v.fightattr == Fightattr.eRDDAMADDR) or (v.fightattr == Fightattr.eRDDAMCUTR) or 
           (v.fightattr == Fightattr.eADAMADDR) or (v.fightattr == Fightattr.eADAMCUTR) then
            strAttr = strAttr .. (v.value/100) .. "%"
        else
            strAttr = strAttr .. v.value
        end
    end
    return strAttr
end

-- 计算当前激活的总属性
function DesignationBagLayer:getAllBorderAttr()
    local tmpAllList = {}
    local function addToAllList(item)
        local isFind = false
        for _,v in ipairs(tmpAllList) do
            if (v.range == item.range) and (v.fightattr == item.fightattr) then
                isFind = true
                v.value = v.value + item.value
                break
            end
        end
        if (isFind == false) then
            table.insert(tmpAllList, item)
        end
    end
    for _,v in ipairs(self.ownedList or {}) do
        local model = DesignationPicRelation.items[v.Id] or {}
        local list = Utility.analysisStrFashionAttrList(model.allAttr)
        for _,item in ipairs(list) do
            addToAllList(item)
        end
    end
    return tmpAllList
end

return DesignationBagLayer