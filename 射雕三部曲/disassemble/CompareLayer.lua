--[[
	文件名：CompareLayer.lua
	描述：外功合成
    修改人：heguanghui
	创建时间： 2017.8.2

--]]

local CompareLayer = class("CompareLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数
    params 中各项为：
    {
        resourcetype: 已选择物品的类型，取值在EnumsConfig.lua 的 Resourcetype 中获取
        selectList: 已经选择物品列表
    }
]]

function CompareLayer:ctor(params)
    -- 当前选中物品的类型
    self.mResourcetype = params and params.resourcetype
    -- 当前选中的物品数据列表
    self.mSelectList = params and params.selectList or {}

    -- 合成需要的消息
    self.mNeedGold = 0
    self:initUI()

    self:createSlotCard()
    self:refreshSlotUI()
end

function CompareLayer:getRestoreData()
    local retData = {}
    retData.selectList = self.mSelectList
    retData.resourcetype = self.mResourcetype

    return retData
end

-- 初始化界面
function CompareLayer:initUI()
    -- 背景
    self.bgSprite = ui.newSprite("zl_01.jpg")
    self.bgSprite:setPosition(320, 568)
    self:addChild(self.bgSprite)

    local bgSp = ui.newScale9Sprite("c_25.png", cc.size(570, 50))
    local lab = ui.newLabel({
        text = TR("6个同品质的外功可以随机合成1个#FFE492更高品质#FFFFFF的外功"),
        color = Enums.Color.eNormalWhite,
        outlineColor = cc.c3b(0x5a, 0x2e, 0x2a),
        size = 22,
    })
    bgSp:setPosition(320, 950)
    self:addChild(bgSp)
    lab:setPosition(320, 950)
    self:addChild(lab)

	-- 一键合成
	local mysteryShopButton = ui.newButton({
		normalImage = "tb_109.png",
		clickAction = function()
            self:requestOneKeyCompare()
		end,
		position = cc.p(587, 885)
	})
	self.bgSprite:addChild(mysteryShopButton)

    -- 黑色剪影
    local shadowSprite = ui.newSprite("zl_08.png")
    shadowSprite:setPosition(310, 520)
    self.bgSprite:addChild(shadowSprite)

    -- 自动放入
    local autoPushButton = ui.newButton({
        normalImage = "c_28.png",
        text = TR("自动放入"),
        clickAction = function()
            self:autoPushPet()
        end,
    })
    autoPushButton:setPosition(204, 162)
    self.bgSprite:addChild(autoPushButton)
    -- 添加自动放入小红点
    local function dealRedDotVisible(redDotSprite)
        redDotSprite:setVisible(RedDotInfoObj:isValid(ModuleSub.ePetCompare))
    end
    ui.createAutoBubble({parent = autoPushButton, eventName = RedDotInfoObj:getEvents(ModuleSub.ePetCompare),
        refreshFunc = dealRedDotVisible})

    -- 合成
    local compareButton = ui.newButton({
        normalImage = "c_28.png",
        text = TR("合成"),
        clickAction = function()
            local curQulity = nil
            for i=1,6 do
                local item = self.mSelectList[i]
                if not item or not Utility.isEntityId(item.Id) then
                    ui.showFlashView(TR("需要6个同品质外功才能合成"))
                    return
                end
                -- 同品质判断
                local itemQulity = PetModel.items[item.ModelId].valueLv
                curQulity = curQulity or itemQulity
                if curQulity ~= itemQulity then
                    ui.showFlashView(TR("需要6个同品质外功才能合成"))
                    return
                end
            end

            -- 判断铜币是否足够
            if not Utility.isResourceEnough(ResourcetypeSub.eGold, self.mNeedGold) then
                return
            end

            self:requestCompare()
        end,
    })
    compareButton:setPosition(445, 162)
    self.bgSprite:addChild(compareButton)

    -- 合成物品需要消耗的铜币数
    local goldBgSprite = ui.newSprite("c_23.png")
    goldBgSprite:setPosition(cc.p(459, 221))
    self.bgSprite:addChild(goldBgSprite)
    self.mNeedGoldNode = ui.createDaibiView({
        resourceTypeSub = ResourcetypeSub.eGold,
        number = 0,
        fontColor = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack,
    })
    self.mNeedGoldNode:setAnchorPoint(cc.p(0, 0.5))
    self.mNeedGoldNode:setPosition(-10, 11)
    goldBgSprite:addChild(self.mNeedGoldNode)
end

-- 创建卡槽对应的卡牌
function CompareLayer:createSlotCard()
    -- （创建顺序）顶上，左，下，右
    local posYList = {798, 663, 427, 305}
    local leftXOffset = 105
    local possList = {cc.p(320, posYList[1]), cc.p(leftXOffset, posYList[2]), 
        cc.p(leftXOffset, posYList[3]), cc.p(320, posYList[4]), 
        cc.p(640 - leftXOffset, posYList[3]), cc.p(640 - leftXOffset, posYList[2])}

    self.mCardPos = possList
    self.mCardNodeList = {}
    for index = 1, 6 do
        local tempCard
        tempCard = CardNode:create({
            allowClick = true,
            onClickCallback = function()
                local tempData = self.mSelectList[index]
                -- 如存在外功，再次点击时去除选择
                if tempData and Utility.isEntityId(tempData.Id) then
                    self.mSelectList[index] = nil
                    -- 全部取消时，需要刷新消息
                    self:refreshSlotUI()
                    return
                end

                local tempData = {
                    selectType = Enums.SelectType.ePetCompare,
                    oldResourcetype = self.mResourcetype,
                    oldSelList = self.mSelectList or {},
                    callback = function(selectLayer, selectItemList, resourcetype)
                        local tempStr = "disassemble.DisassembleLayer"
                        local tempData = LayerManager.getRestoreData(tempStr)
                        tempData.compare = tempData.compare or {}
                        tempData.compare.resourcetype = resourcetype
                        tempData.compare.selectList = selectItemList
                        tempData.currTag = Enums.DisassemblePageType.eCompare
                        LayerManager.setRestoreData(tempStr, tempData)

                        -- 删除装备选择页面
                        LayerManager.removeLayer(selectLayer)
                    end
                }
                LayerManager.addLayer({
                    name = "commonLayer.SelectLayer",
                    data = tempData,
                })
            end
        })
        tempCard:setPosition(possList[index])
        self:addChild(tempCard)
        --
        table.insert(self.mCardNodeList, tempCard)
    end
end

-- 刷新界面显示
function CompareLayer:refreshSlotUI()
    local compareColorLv = 0
    for i,cardNode in ipairs(self.mCardNodeList) do
        local tempData = self.mSelectList[i]
        if tempData and Utility.isEntityId(tempData.Id) then
            -- 显示外功
            cardNode:setPet(tempData)
            compareColorLv = PetModel.items[tempData.ModelId].valueLv
        else
            -- 设置+号
            cardNode:setEmpty({}, "c_10.png", "c_22.png")
            local tempSize = cardNode:getContentSize()
            local tempSprite = ui.createGlitterSprite({
                filename = "c_22.png",
                parent = cardNode,
                position = cc.p(tempSize.width / 2, tempSize.height / 2),
                actionScale = 1.2,
            })
        end
    end

    -- 刷新合成需要消耗掉铜币数
    self.mNeedGold = 0
    if compareColorLv > 0 then
        self.mNeedGold = PetColorRelation.items[compareColorLv].colorUpUseNum
    end
    self.mNeedGoldNode.setNumber(self.mNeedGold)
end

function CompareLayer:autoPushPet()
    local petData = PetObj:getPetList({isCompare = true})
    local selectLayer = require("commonLayer.SelectLayer").new({})
    selectLayer:sortPetData(petData)
    -- 顺序自动选中同品质的外功
    local curQulity = 1
    local selectList = {}
    for _,v in ipairs(petData) do
        local qulity = PetModel.items[v.ModelId].valueLv
        if curQulity ~= qulity then
            selectList = {}
            curQulity = qulity
        end
        table.insert(selectList, clone(v))
        if #selectList == 6 then
            break
        end
    end
    -- 选中6个，刷新界面
    if #selectList < 6 then
        ui.showFlashView(TR("需要6个同品质外功才能合成"))
    else
        self.mSelectList = selectList
        self:refreshSlotUI()
    end
end

-- 播放合成的特效
function CompareLayer:playComposeEffect(endCallback)
    for index = 1, #self.mCardNodeList do
        local beginPos = cc.p(self.mCardNodeList[index]:getPosition())
        local effect = ui.newEffect({
            parent = self,
            zorder = 1,
            effectName = "effect_ui_waigonghecheng",
            position = beginPos,
            loop = false,
            endRelease = true,
            endListener = function()
                if endCallback and index == #self.mCardNodeList then
                    endCallback()
                end
            end,
        })
    end
end


-------------------------------网络请求---------------------
-- 外功秘籍散功请求
function CompareLayer:requestCompare()
    local compareData = {}
    for i,v in ipairs(self.mSelectList) do
        table.insert(compareData, v.Id)
    end
    HttpClient:request({
        moduleName = "Pet",
        methodName = "PetCompose",
        svrMethodData = {compareData},
        callback = function(data)
            if data and data.Status == 0 then
                for i,v in ipairs(compareData) do
                    PetObj:deletePetById(v)
                end
                -- 刷新界面
                self.mSelectList = {}
                self:refreshSlotUI()
                -- 播放特效
                self:playComposeEffect(function ()
                    MsgBoxLayer.addGameDropLayer(data.Value.BaseGetGameResourceList, {}, " ", "", {{text = TR("确定")}}, {})
                end)
                
            end
        end})
end

function CompareLayer:requestOneKeyCompare()
    HttpClient:request({
        moduleName = "Pet",
        methodName = "PetComposeByOneKey",
        svrMethodData = compareData,
        callback = function(data)
            if data and data.Status == 0 then
                for i,v in ipairs(data.Value.BaseConsumeGameResourceList) do
                    PetObj:deletePetById(v.EntityId)
                end
                -- 刷新界面
                self.mSelectList = {}
                self:refreshSlotUI()
                -- 播放特效
                self:playComposeEffect(function ()
                    MsgBoxLayer.addGameDropLayer(data.Value.BaseGetGameResourceList, {}, " ", "", {{text = TR("确定")}}, {})
                end)
            end
        end})
end

return CompareLayer
