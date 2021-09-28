--[[
    文件名：ShengyuanPlaneLevelUpLayer.lua
    描述：飞船升级页面
    创建人：chenzhong
    创建时间：2017.9.2
--]]

local ShengyuanPlaneLevelUpLayer = class("ShengyuanPlaneLevelUpLayer", function(params)
    return display.newLayer()
end)


-- 构造函数
--[[
    params:
    {   
        ownPlaneList    -- 玩家当前拥有的飞机列表
        callback        -- 关闭页面回调
    }
--]]
function ShengyuanPlaneLevelUpLayer:ctor(params)
    self.mOwnPlaneList = params.ownPlaneList

    self:sortData()

    local bgSprite = require("commonLayer.PopBgLayer").new({
        title = TR("船只培养"),
        bgSize = cc.size(592, 694),
        closeAction = function()
            if params.callback then
                params.callback()
            end
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgSprite)

    self.mBgSprite = bgSprite.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 信息背景条
    local lineBg = ui.newSprite("jzthd_65.png")
    lineBg:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height * 0.625)
    self.mBgSprite:addChild(lineBg)
    self.mLineBg =lineBg
    local infoBg = ui.newSprite("jzthd_66.png")
    infoBg:setPosition(lineBg:getContentSize().width * 0.5, 46)
    lineBg:addChild(infoBg)

    self.mParentNode = cc.Node:create()
    self.mBgSprite:addChild(self.mParentNode)

    local btnInfos = {
        {
            text = TR("升级"),
            tag = 1
        },
        {
            text = TR("更换"),
            tag = 2
        },
    }
    local tabView = ui.newTabLayer({
        btnInfos = btnInfos,
        viewSize = cc.size(self.mBgSprite:getContentSize().width -40, 85),
        isVert = false,
        space = 14,
        needLine = false,
        allowChangeCallback = function(btnTag)
            return true
        end,
        onSelectChange = function(selectBtnTag)
            if selectBtnTag == self.curPage then 
                return
            end   
            self.curPage = selectBtnTag  

            self.mParentNode:removeAllChildren()
            if selectBtnTag == 1 then 
                -- 刷新UI
                self:setLevelUI()
            else 
                self:getPlaneOrChange()
            end     
            
        end
    })
    tabView:setAnchorPoint(0.5, 1)
    tabView:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height - 40)
    self.mBgSprite:addChild(tabView)
end

-- 整理数据
function ShengyuanPlaneLevelUpLayer:sortData()
    self.mMountModelList = {}
    -- 飞机模型表由低到高排序
    local totalMountModel = {}
    for k, v in pairs(GoddomainMountModel.items) do
        table.insert(totalMountModel, v)
    end
    table.sort(totalMountModel, function(a, b)
        return a.colorLv < b.colorLv
    end)

    -- 找出玩家当前使用的飞机
    if not self.mCurrIndex then
        for i, v in ipairs(totalMountModel) do
            if v.Id == ShengyuanWarsHelper:getMountModelId() then
                self.mCurrIndex = i
            else 
                table.insert(self.mMountModelList, v)    
            end
        end
    end

    -- 找出玩家拥有的最牛飞机的等级上限
    self.mMaxLevel = 0
    for i, v in ipairs(self.mOwnPlaneList) do
        local model = GoddomainMountModel.items[v.MountModelId]
        if model.maxLevel > self.mMaxLevel then
            self.mMaxLevel = model.maxLevel
        end
    end
end

function ShengyuanPlaneLevelUpLayer:setLevelUI()
    self.mParentNode:removeAllChildren()
    -- 飞机模型
    local item = {
        MountModelId = ShengyuanWarsHelper:getMountModelId(),
        showWave = true,
    }
    local planeSpr = ShengyuanWarsUiHelper:createBoat(item)
    planeSpr:setPosition(320, 480)
    planeSpr:setScale(0.8)
    self.mParentNode:addChild(planeSpr)

    local function createPlaneInfo(lv)
        local tempParent = cc.Node:create()
        self.mParentNode:addChild(tempParent)

        -- 飞机名字
        local tempData = GoddomainMountModel.items[ShengyuanWarsHelper:getMountModelId()]
        local tempName = tempData.name
        local tempColor = Utility.getColorValue(tempData.colorLv, 1)
        local nameLabel = ui.newLabel({
            text = tempName,
            color = tempColor,
            size = 20,
        })
        nameLabel:setPosition(55, -140)
        tempParent:addChild(nameLabel)

        -- 等级
        local levelLabel = ui.newLabel({
            text = TR("等级:%s%s", "#56c636", lv),
        })
        levelLabel:setAnchorPoint(0, 1)
        levelLabel:setPosition(-30, -155)
        tempParent:addChild(levelLabel)

        -- 速度
        local levelConfig = GoddomainMountLvRelation.items[lv]
        local modelConfig = GoddomainMountModel.items[ShengyuanWarsHelper:getMountModelId()]
        local speedStr = TR("速度:%s%s", "#56c636", math.floor(levelConfig.speed * modelConfig.speedPro * 10))
        -- 时装加成
        local addSpeed = self.getFashionSpeedAdd()
        if addSpeed > 0 then
        	speedStr = speedStr .. string.format("+%s", addSpeed)
        end

        local speedLabel = ui.newLabel({
            text = speedStr,
        })
        speedLabel:setAnchorPoint(0, 1)
        speedLabel:setPosition(50, -155)
        tempParent:addChild(speedLabel)

        return tempParent
    end

    -- 当前等级信息
    local currentLevelData = GoddomainMountLvRelation.items[ShengyuanWarsHelper:getMountLv()]
    -- 下一级信息
    local nextLevelData = nil
    if ShengyuanWarsHelper:getMountLv() < self.mMaxLevel then
        nextLevelData = GoddomainMountLvRelation.items[ShengyuanWarsHelper:getMountLv() + 1]
    end

    -- 升级前飞机信息
    local beforePlane = createPlaneInfo(currentLevelData.level)
    if nextLevelData and next(nextLevelData) then
        -- 升级后飞机信息
        local afterPlane = createPlaneInfo(nextLevelData.level)

        -- 箭头
        local jianTou = ui.newSprite("c_67.png")
        jianTou:setPosition(280, 330)
        jianTou:setScale(0.8)
        self.mParentNode:addChild(jianTou)

        beforePlane:setPosition(self.mBgSize.width * 0.15, self.mBgSize.height * 0.7)
        afterPlane:setPosition(self.mBgSize.width * 0.65, self.mBgSize.height * 0.7)
    else
        beforePlane:setPosition(self.mBgSize.width * 0.4, self.mBgSize.height * 0.7)
    end
    
    -- 升级消耗
    local tempMentionLabel = ui.createLabelWithBg({
        bgFilename = "c_25.png",
        labelStr = TR("升级消耗"),
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        outlineSize = 1,
        alignType = ui.TEXT_ALIGN_CENTER,
    })  
    tempMentionLabel:setPosition(self.mBgSize.width * 0.5, 240)
    self.mParentNode:addChild(tempMentionLabel)

    -- 升级按钮
    local levelUpBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("升级"),
        clickAction = function()
            self:requestPlaneLavelUp()
        end
    })
    levelUpBtn:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height * 0.08)
    self.mParentNode:addChild(levelUpBtn)

    -- 升级消耗显示
    local tempDataList = Utility.analysisStrResList(currentLevelData.lvUpUseResource)
    if nextLevelData and next(nextLevelData) and tempDataList and next(tempDataList) then
        local tempCardList = ui.createCardList({
            maxViewWidth = 475,
            cardDataList = tempDataList,
        })
        tempCardList:setAnchorPoint(0.5, 0.5)
        tempCardList:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height * 0.22)
        self.mParentNode:addChild(tempCardList)

        -- 资源颜色显示装填修改
        for i, node in ipairs(tempCardList.getCardNodeList()) do
            local resInfo = tempDataList[i]
            local holdNum
            if Utility.isGoods(resInfo.resourceTypeSub) then
                holdNum = GoodsObj:getCountByModelId(resInfo.modelId)
                self:setCardCount(node, holdNum, resInfo.num)
            else
                holdNum = PlayerAttrObj:getPlayerAttr(resInfo.resourceTypeSub)
                self:setCardCount(node, holdNum, resInfo.num)
            end

            if holdNum < resInfo.num then
                levelUpBtn:setEnabled(false)
            end
        end
    else
        tempMentionLabel:setVisible(false)
        levelUpBtn:setVisible(false)
        local tempLabel = ui.newLabel({
            text = TR("已到等级上限"),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 32
        })
        tempLabel:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height * 0.22)
        self.mParentNode:addChild(tempLabel)
    end
end

-- 设置cardnode分数显示
function ShengyuanPlaneLevelUpLayer:setCardCount(parnet, currentNum, needNum)
    local attr = parnet:getAttrControl()
    local tempLabel = attr[CardShowAttr.eNum].label

    if not needNum then
        tempLabel:setString(string.format("%s", needNum))
    else
        local tempColor = currentNum >= needNum and Enums.Color.eWhiteH or Enums.Color.eRedH
        tempLabel:setString(string.format("%s%s", tempColor, Utility.numberWithUnit(needNum, 0)))
    end
end

function ShengyuanPlaneLevelUpLayer.getFashionSpeedAdd()
	local fashionIdList = QFashionObj:getQFashionModelList()
	local speed = 0
	for _, fashionId in pairs(fashionIdList) do
		speed = speed + ShizhuangModel.items[fashionId].shengyuanSpeedAdd
	end

	return speed
end

-- 刷新飞机信息父节点
function ShengyuanPlaneLevelUpLayer:getPlaneOrChange()
    self.mParentNode:removeAllChildren()
    local popbgSprite = self.mLineBg
    local bgSize = popbgSprite:getContentSize()
    local sliderViewIndex = self.mCurrIndex - 1

    -- 显示窗口大小
    local viewSize = cc.size(bgSize.width-50, 500)
    local sliderView = ui.newSliderTableView({
        width = viewSize.width,
        height = viewSize.height,
        isVertical = false,
        selectIndex = self.mCurrIndex - 1,
        selItemOnMiddle = true,
        itemCountOfSlider = function(sliderView)
            return #self.mMountModelList
        end,
        itemSizeOfSlider = function(sliderView)
            return viewSize.width, viewSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
            local planeModel = self.mMountModelList[index + 1]

            -- 飞船形象
            local item = {
                MountModelId = planeModel.Id,
                showWave = true,
            }
            local planeSpr = ShengyuanWarsUiHelper:createBoat(item)
            planeSpr:setPosition(bgSize.width/2, viewSize.height*0.78 + 20)
            planeSpr:setScale(0.8)
            itemNode:addChild(planeSpr)

            -- 名字
            local nameLabel = ui.newLabel({
                text = TR(planeModel.name),
                color = Utility.getColorValue(planeModel.colorLv, 1),
                size = 22,
                x = bgSize.width * 0.45,
                y = viewSize.height*0.545
            })
            itemNode:addChild(nameLabel)

            -- 等级
            local levelLabel = ui.newLabel({
                text = TR("船只等级: %s%s", "#56c636", ShengyuanWarsHelper:getMountLv()),
                x = bgSize.width * 0.15,
                y = viewSize.height*0.49,
                align = ui.TEXT_ALIGN_CENTER
            })
            itemNode:addChild(levelLabel)

            -- 移动速度
            local speed = ShengyuanWarsHelper:getMountSpeed(planeModel.Id, ShengyuanWarsHelper:getMountLv())
            local speedStr = TR("移动速度: %s%s", "#56c636", speed * 10)
            -- 时装加成
	        local addSpeed = self.getFashionSpeedAdd()
	        if addSpeed > 0 then
	        	speedStr = speedStr .. string.format("+%s", addSpeed)
	        end

            local speedLabel = ui.newLabel({
                text = speedStr,
                x = bgSize.width * 0.43,
                y = viewSize.height*0.49,
                align = ui.TEXT_ALIGN_CENTER
            })
            itemNode:addChild(speedLabel)

            -- 速度加成
            local speedAdd = (tonumber(planeModel.speedPro) - 1) * 100
            local speedAddLabel = ui.newLabel({
                text = TR("速度加成: %s%s%%", "#56c636", speedAdd),
                x = bgSize.width * 0.75,
                y = viewSize.height*0.49,
                align = ui.TEXT_ALIGN_CENTER
            })
            itemNode:addChild(speedAddLabel)

            -- 是否拥有该飞机
            local ownThis = false
            for k, v in pairs(self.mOwnPlaneList) do
                if v.MountModelId == planeModel.Id then
                    ownThis = true
                    break
                end
            end
            -- 升级、上马、去获取按钮
            local tempBtn = ui.newButton({
                text = ownThis and TR("更换") or TR("去获取"),
                normalImage = "c_28.png",
                position = cc.p(bgSize.width * 0.45, 100),
                clickAction = function(btnObj)
                    if ownThis then
                        -- 更换
                        self:requestGodDomainMountCombat(planeModel.Id)
                    else
                        LayerManager.showSubModule(ModuleSub.eTimedMountExchange)
                    end
                end
            })
            itemNode:addChild(tempBtn)     

            -- 已开始匹配或游戏中，不能进行升级、更换操作
            if ShengyuanWarsStatusHelper:getGodDomainTeamState() == 2 or ShengyuanWarsStatusHelper:getGodDomainTeamState() == 3 then
                tempBtn:setEnabled(false)
            end
        end,
        selectItemChanged = function(sliderView, selectIndex)
            print("---当前是第"..tostring(selectIndex + 1).."个飞机---")

            sliderViewIndex = selectIndex + 1
            -- 左右箭头
            if sliderView.leftArrow and sliderView.rightArrow then
                if selectIndex == 0 then
                    sliderView.leftArrow:setVisible(false)
                    sliderView.rightArrow:setVisible(true)
                elseif selectIndex == #self.mMountModelList - 1 then
                    sliderView.leftArrow:setVisible(true)
                    sliderView.rightArrow:setVisible(false)
                else
                    sliderView.leftArrow:setVisible(true)
                    sliderView.rightArrow:setVisible(true)
                end
            end
        end,
    })
    sliderView:setAnchorPoint(cc.p(0.5, 0))
    sliderView:setPosition(bgSize.width * 0.55, 70)
    self.mParentNode:addChild(sliderView)

    -- 左右箭头
    if #self.mMountModelList > 1 then
        sliderView.leftArrow = ui.newButton({
            normalImage = "c_26.png",
            position = cc.p(30, 430),
            clickAction = function(btnObj)
                sliderView:setSelectItemIndex(sliderViewIndex - 2, true)
            end
        })
        sliderView.leftArrow:setScaleX(-1)
        self.mParentNode:addChild(sliderView.leftArrow)

        sliderView.rightArrow = ui.newButton({
            normalImage = "c_26.png",
            position = cc.p(640-80, 430),
            clickAction = function(btnObj)
                sliderView:setSelectItemIndex(sliderViewIndex, true)
            end
        })
        self.mParentNode:addChild(sliderView.rightArrow)
    end
end

--=============================网络请求相关============================--
function ShengyuanPlaneLevelUpLayer:requestPlaneLavelUp()
    HttpClient:request({
        moduleName = "GodDomain",
        methodName = "GodDomainPlaneLvUp",
        callbackNode = self,
        callback = function (data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 保存飞机信息
            ShengyuanWarsHelper:setMountModelId(data.Value.ModelId)
            ShengyuanWarsHelper:setMountLv(data.Value.MountLv)

            self:setLevelUI()

            ui.showFlashView(TR("升级成功！"))
        end
    })
end

-- 请求服务器，更换飞机
--[[
    mountModelId
--]]
function ShengyuanPlaneLevelUpLayer:requestGodDomainMountCombat(mountModelId)
    HttpClient:request({
        moduleName = "GodDomain",
        methodName = "GodDomainMountCombat",
        svrMethodData = {mountModelId},
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 修改缓存
            ShengyuanWarsHelper:setMountModelId(data.Value.PlaneModelId)
            ShengyuanWarsHelper:setMountLv(data.Value.MountLv)

            -- 飘窗提示
            ui.showFlashView({text = TR("更换成功")})
        end
    })
end

return ShengyuanPlaneLevelUpLayer