--[[
	文件名：PetTalentLayer.lua
	描述：外功秘籍参悟分页面
	创建人：peiyaoqiang
    创建时间：2017.03.21
--]]

local PetTalentLayer = class("PetTalentLayer", function(params)
	return display.newLayer()
end)

-- 构造函数
--[[
	params:
	Table params:
	{
		petList 			-- 必须参数，外功秘籍列表
		currIndex 			-- 必须参数，需要展示的外功秘籍在阵容卡槽里的序号
		callback 			-- 可选参数，数据改变之后父页面的回调
	}
--]]
function PetTalentLayer:ctor(params)
    require("pet.PetTalentHelper")

	-- 父节点已做适配，此页面按照(640, 1136)使用即可
	self:setContentSize(640, 1136)

	-- 保存数据
    self.mPetList = params.petList
    self.mCurrIndex = params.currIndex
    self.mCallback = params.callback

    -- 当前外功秘籍信息
    self.mPetInfo = self.mPetList[self.mCurrIndex]
    -- 当前参悟的层数
    self.mCurrLayer = self.mPetInfo.Layer
    -- 需要显示的层数
    self.mShowLayer = params.showLayer

    -- 招式ID为索引的招式表，便于查找
    self.mCTalList = {}
    for k, v in pairs(self.mPetInfo.TalentInfoList or {}) do
        self.mCTalList[v.TalentID] = v
    end

    -- 整理节点配置信息表
    local petModel = PetModel.items[self.mPetInfo.ModelId]
    self.nodeList = ConfigFunc:getPetTalTreeNode(petModel.valueLv)
    self.layerIdList = table.keys(self.nodeList)
    self.maxLayer = #self.layerIdList
    table.sort(self.layerIdList, function(id1, id2)
        -- 层数由低到高排序
        return id1 < id2
    end)

    -- 如果调用者没有传入需要显示的层数，则自动找到第一个还没学满的招式
    if (self.mShowLayer == nil) then
        local function findActiveItem(nodeItem)
            local activeTalItem = nil
            local activeTalInfo = nil
            for _, v in pairs(nodeItem) do
                local tmpTalInfo = self.mCTalList[v.ID]
                if tmpTalInfo then
                    activeTalItem = clone(v)
                    activeTalInfo = clone(tmpTalInfo)
                    break
                end
            end
            return activeTalItem, activeTalInfo
        end
        for i, nodeItem in ipairs(self.nodeList) do
            self.mShowLayer = i
            
            -- 处理数据
            local activeTalItem, activeTalInfo = findActiveItem(nodeItem)
            if (activeTalInfo == nil) or (activeTalItem == nil) then
                -- 该层招式还没参悟
                break
            end
            local curNum = activeTalInfo.TalentNum or 0
            local maxNum = activeTalItem.totalNum
            if (curNum < maxNum) then
                -- 该层招式还没学满
                break
            end
        end
    end
    
    -- 天赋技能的显示配置
    -- pos是技能图片的位置，lvPos是等级Label的位置，flagPos是选中图片的位置
    self.preImgConfig = {pos = cc.p(150, 550), lvPos = cc.p(160, 570), flagPos = cc.p(160, 530), studyPos = cc.p(50, 650)}
    self.talImgConfigList = {
        -- 尽量使得flagPos与起点形成的偏角是45的倍数，不然会出现很明显的锯齿
        [1] = {
            {pos = cc.p(500, 200), lvPos = cc.p(500, 180), flagPos = cc.p(380, 310), studyPos = cc.p(600, 300)}
        },
        [2] = {
            {pos = cc.p(150, 200), lvPos = cc.p(150, 180), flagPos = cc.p(160, 380), studyPos = cc.p(50, 300)}, 
            {pos = cc.p(500, 450), lvPos = cc.p(500, 420), flagPos = cc.p(450, 530), studyPos = cc.p(600, 550)}
        },
        [3] = {
            {pos = cc.p(150, 200), lvPos = cc.p(150, 180), flagPos = cc.p(160, 380), studyPos = cc.p(50, 300)}, 
            {pos = cc.p(500, 200), lvPos = cc.p(500, 180), flagPos = cc.p(400, 290), studyPos = cc.p(600, 300)}, 
            {pos = cc.p(500, 550), lvPos = cc.p(550, 530), flagPos = cc.p(480, 530), studyPos = cc.p(600, 650)}
        },
    }

	-- 添加UI元素
	self:initUI()
end

-- 初始化UI
function PetTalentLayer:initUI()
    -- 规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        --position = cc.p(585, 860),
        position = cc.p(595, 960),
        clickAction = function (pSender)
            MsgBoxLayer.addRuleHintLayer(
                TR("规则"),
                {
                    TR("1.外功秘籍参悟招式分为多层，每层可选择一种招式进行学习或升级"),
                    TR("2.外功秘籍升到一定的等级后，才能开启相应层级的外功招式"),
                    TR("3.外功招式必须按照层级顺序进行参悟，相同层级的招式只能选择一种"),
                    TR("4.消耗指定材料可学习招式或提升招式级别"),
                    TR("5.每种参悟都会使外功秘籍属性获得提升"),
                    TR("6.品质越高的外功秘籍可参悟的武学招式越多"),
                    TR("7.外功招式可以重置，重置后返还所有花费的材料")
                }
            )
        end
    })
    self:addChild(ruleBtn)

    -- 遗忘招式按钮
    local resetBtn = ui.newButton({
        normalImage = "tb_36.png",
        position = cc.p(55, 940),
        clickAction = function(btnObj)
            local needItem = PetTalentHelper.getResetCost(self.mPetInfo)
            if (needItem == nil) then
                ui.showFlashView({text = TR("您尚未参悟任何招式呢")})
                return
            end

            MsgBoxLayer.addOKCancelLayer(
                TR("遗忘招式将消耗{%s}%s%s%s并返还所有已消耗的资源，是否确认？",
                    Utility.getDaibiImage(needItem.resourceTypeSub),
                    "#249029",
                    needItem.num,
                    Enums.Color.eNormalWhiteH
                ),
                TR("遗忘招式"),
                {
                    normalImage = "c_28.png",
                    text = TR("确认遗忘"),
                    clickAction = function(layerObj, btnObj)
                        LayerManager.removeLayer(layerObj)
                        if Utility.isResourceEnough(needItem.resourceTypeSub, needItem.num, true) then
                            self:requestResetTal()
                        end
                    end
                },
                {
                    normalImage = "c_28.png",
                    text = TR("取消"),
                }
            )
        end
    })
    self:addChild(resetBtn)

    -- 目录按钮
    local btnBook = ui.newButton({
        normalImage = "wgcw_27.png",
        position = cc.p(590, 870),
        clickAction = function (pSender)
            LayerManager.addLayer({
                name = "pet.DlgPetBookLayer",
                data = {nodeList = self.nodeList, mCTalList = self.mCTalList, callback = function (retNewLayer)
                    self.mShowLayer = retNewLayer
                    self:refreshUI()
                end},
                cleanUp = false,
            })
        end
    })
    self:addChild(btnBook)

    -- 招式的背景Node
    local bgSprite = cc.Node:create()
    bgSprite:setContentSize(cc.size(640, 760))
    bgSprite:setAnchorPoint(cc.p(0.5, 0))
    bgSprite:setPosition(320, 100)
    self:addChild(bgSprite)
    self.mBgSprite = bgSprite

    -- 左右箭头
    local rightButton = ui.newButton({
        normalImage = "c_43.png",
        position = cc.p(610, 570),
        clickAction = function(btnObj)
            if (self.mShowLayer >= self.maxLayer) then
                ui.showFlashView({text = TR("已经到最高层了")})
                return
            end
            self.mShowLayer = self.mShowLayer + 1
            self:refreshUI()
        end
    })
    local leftButton = ui.newButton({
        normalImage = "c_43.png",
        position = cc.p(30, 570),
        clickAction = function(btnObj)
            if (self.mShowLayer <= 1) then
                ui.showFlashView({text = TR("已经到第一层了")})
                return
            end
            self.mShowLayer = self.mShowLayer - 1
            self:refreshUI()
        end
    })
    rightButton:setRotation(270)
    leftButton:setRotation(90)
    self:addChild(rightButton)
    self:addChild(leftButton)
    
    -- 刷新界面
    self:refreshUI()
end

-- 刷新界面
function PetTalentLayer:refreshUI()
    -- 清除以前的内容
    self.mBgSprite:removeAllChildren()
    self.attrBgSprite = nil
    self.flashBgSprite = nil

    -- 处理边界
    if (self.mShowLayer > self.maxLayer) then
        self.mShowLayer = self.maxLayer
    end
    if (self.mShowLayer < 1) then
        self.mShowLayer = 1
    end

    -- 显示名字
    local petName = PetModel.items[self.mPetInfo.ModelId].name
    local valueLv = Utility.getQualityColorLv(PetModel.items[self.mPetInfo.ModelId].quality)
    local petNameColorH = Utility.getColorValue(valueLv, 2)
    local petLayer = self.mPetInfo.TotalNum - self.mPetInfo.CanUseTalNum
    local petLayerStr = (petLayer == 0) and "" or string.format("%+d", petLayer)
    local tempStr = TR("等级%s%s%s%s%s",
        self.mPetInfo.Lv,
        petNameColorH,
        petName,
        Enums.Color.eYellowH,
        petLayerStr
    )
    Figure.newNameAndStar({
        parent = self.mBgSprite,
        position = cc.p(320, 860),
        nameText = tempStr,
        })

    -- 显示当前层
    local layerLabel = ui.newLabel({
        text = TR("当前层:%s%d/%d", Enums.Color.eNormalGreenH, self.mShowLayer, self.maxLayer),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 24,
        anchorPoint = cc.p(0.5, 0.5),
        x = 320,
        y = 750,
    })
    self.mBgSprite:addChild(layerLabel)

    -- 读取当前层和上一层的招式信息
    local preNodes = self.nodeList[self.layerIdList[self.mShowLayer - 1]]
    local curNodes = self.nodeList[self.layerIdList[self.mShowLayer]]
    
    -- 辅助接口：显示一个天赋技能
    self.showTalNodeList = {}
    local function createOneTal(talItem, config)
        if (talItem == nil) then
            return
        end
        local talInfo = self.mCTalList[talItem.ID]

        -- 显示天赋图标
        local normalFlagImg, selectFlagImg = "wgcw_06.png", "wgcw_05.png"
        local imageName = "wgcw_29.png"
        if (talItem.pic ~= nil) then
            imageName = string.format("%s.png", talItem.pic)
        end
        local btnTal = ui.newButton({
            normalImage = imageName,
            anchorPoint = cc.p(0.5, 0),
            position = config.pos,
            clickAction = function ()
                if (talItem.ID ~= nil) then
                    self:selectOneTalNode(talItem.ID)
                    self:showTalentIntro(talItem, self.mBgSprite, config.pos)
                end
            end
        })
        btnTal.setSelect = function (target, flag)
            if (flag == true) then
                if (target.state == nil) or (target.state == false) then
                    target.state = true
                    target.selectSprite:setTexture(selectFlagImg)
                    target.selectEffect:setVisible(true)
                end
            else
                if (target.state ~= nil) and (target.state == true) then
                    target.state = false
                    target.selectSprite:setTexture(normalFlagImg)
                    target.selectEffect:setVisible(false)
                end
            end
        end
        self.mBgSprite:addChild(btnTal, 2)
        table.insert(self.showTalNodeList, {item = talItem, node = btnTal})

        -- 显示选择光圈
        btnTal.selectEffect = ui.newEffect({
            parent = self.mBgSprite,
            effectName = "effect_ui_waigongguangquan",
            position = cc.p(config.pos.x, config.pos.y + 80),
            loop = true,
        })
        btnTal.selectEffect:setVisible(false)

        -- 显示选中图片
        local selectSprite = ui.newSprite(normalFlagImg)
        selectSprite:setPosition(config.flagPos)
        self.mBgSprite:addChild(selectSprite, 3)
        btnTal.selectSprite = selectSprite

        if (talItem.ID ~= nil) then
            -- 显示招式等级
            local talNumNode = ui.createLabelWithBg({
                bgFilename = "bg_05.png",
                labelStr = string.format("%s/%s", (talInfo and talInfo.TalentNum or 0), talItem.totalNum),
                fontSize = 22,
                alignType = ui.TEXT_ALIGN_CENTER
            })
            talNumNode:setPosition(config.lvPos)
            self.mBgSprite:addChild(talNumNode, 2)

            -- 显示学习标签
            local studyImg = nil
            local isEnough = PetTalentHelper.isResourceEnough(self.mPetInfo, talItem, talInfo)
            if (isEnough == true) then              -- 可学习
                studyImg = "wgcw_03.png"
            elseif (talInfo ~= nil) then            -- 已学习
                studyImg = "wgcw_31.png"
            end
            if studyImg then
                local studySprite = ui.newSprite(studyImg)
                studySprite:setPosition(config.studyPos)
                self.mBgSprite:addChild(studySprite, 2)
            end

            -- 显示需求等级
            local tmpNeedLv = talItem.needPetLv or 0
            if (self.mPetInfo.Lv < tmpNeedLv) then
                local lvLabel = ui.newLabel({
                    text = TR("%d级可学习", tmpNeedLv),
                    color = cc.c3b(0xf8, 0x1d, 0x1d),
                    size = 22,
                })
                lvLabel:setPosition(config.lvPos.x, config.lvPos.y + 30)
                self.mBgSprite:addChild(lvLabel, 3)
            end
        end
    end

    -- 显示上一层的技能
    local preTalItem = {}   -- 默认显示问号
    for _,v in pairs(preNodes or {}) do
        if self.mCTalList[v.ID] then
            -- 不为nil表示该技能已激活
            preTalItem = clone(v)
            break
        end
    end
    createOneTal(preTalItem, self.preImgConfig)
    
    -- 显示当前层的技能
    local tmpConfigList = self.talImgConfigList[#curNodes]
    for i,v in pairs(curNodes) do
        local tmpConfig = tmpConfigList[i]
        local tmpTalInfo = self.mCTalList[v.ID]
        createOneTal(clone(v), tmpConfig)
        if (tmpTalInfo ~= nil) then
            -- 首选默认选中已经学习的天赋
            self:selectOneTalNode(v.ID)
        elseif (i == 1) then
            -- 其次默认选中第一个
            self:selectOneTalNode(v.ID)
        end

        -- 显示画线
        self:myDrawLine(self.preImgConfig.flagPos, tmpConfig.flagPos, (tmpTalInfo ~= nil))
    end
end

-- 显示选中的天赋属性
function PetTalentLayer:createTalAttr(talItem, parent)
    -- 清除以前的内容
    if (self.attrBgSprite == nil) then
        self.attrBgSprite = ui.newScale9Sprite("xsms_03.png", cc.size(300, 144))
        self.attrBgSprite:setAnchorPoint(cc.p(0, 0.5))
        self.attrBgSprite:setPosition(20, 80)
        self.mBgSprite:addChild(self.attrBgSprite)
    end
    self.attrBgSprite:removeAllChildren()

    -- 读取技能信息
    local strError = nil
    local isCanUpdate = false
    local talInfo = self.mCTalList[talItem.ID]
    if (talItem.layer - self.mCurrLayer) > 1 then
        -- 当前层的下一层的以下
        strError = TR("请先参悟一个上层的招式")
    elseif (talItem.layer - self.mCurrLayer) == 1 then
        -- 当前层的下一层
    else
        -- 当前层
        if not talInfo then
            strError = TR("每层只能选择一个招式参悟")
        else
            if talInfo.TalentNum < talItem.totalNum then
                -- 可升级
                isCanUpdate = true
            else
                strError = TR("该招式已经参悟到最高等级")
            end
        end
    end
    
    -- 显示学习材料
    local function showErrorLabel(strText, nColor)
        local errorLabel = ui.newLabel({
            text = strText,
            color = nColor or Enums.Color.eRed,
            size = 22,
            anchorPoint = cc.p(0.5, 0.5),
            dimensions = cc.size(240, 0),
            align = cc.TEXT_ALIGNMENT_CENTER
        })
        errorLabel:setPosition(150, 70)
        self.attrBgSprite:addChild(errorLabel)
    end
    if (strError ~= nil) then
        showErrorLabel(strError)
    else
        local costList = PetTalentHelper.getTalentCostlist(self.mPetInfo, talItem, talInfo)
        
        -- 选中某个材料
        self.showItemList = {}
        self.selectItem = nil
        local function selectOneItem(nModelId)
            for _,v in ipairs(self.showItemList) do
                if (v.data.modelId == nModelId) then
                    v.node:getAttrControl()[CardShowAttr.eSelected].sprite:setVisible(true)
                    self.selectItem = clone(v.data)
                else
                    v.node:getAttrControl()[CardShowAttr.eSelected].sprite:setVisible(false)
                end
            end
        end
        
        -- 显示同名外功和替代道具
        local petCostItem = costList.petCost[1] or {}
        local subCostItem = costList.subCost[1] or {}
        local function showCostItemCard(item, xPos)
            local showItem = clone(item)
            showItem.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum, CardShowAttr.eSelected}

            local tempCard = CardNode:create({
                allowClick = true,
                onClickCallback = function ()
                    selectOneItem(item.modelId)
                end,
            })
            tempCard:setCardData(showItem)
            tempCard:setPosition(cc.p(xPos, 80))
            tempCard:setScale(0.9)
            self.attrBgSprite:addChild(tempCard)
            table.insert(self.showItemList, {data = item, node = tempCard})

            -- 重新设置显示数量
            local haveNum = 0
            local needType = item.resourceTypeSub
            local needModelId = item.modelId
            local needNum = item.num
            if Utility.isPet(needType) then
                local list = PetObj:findByModelId(needModelId, {
                    excludeIdList = {self.mPetInfo.Id},
                    notInFormation = true,
                    Lv = 1,
                })
                haveNum = #list
            else
                haveNum = Utility.getOwnedGoodsCount(needType, needModelId)
            end
            local tmpLabel = tempCard:getAttrControl()[CardShowAttr.eNum].label
            local itemEnough = (haveNum >= needNum)
            tmpLabel:setString(string.format("%s%s%s/%s",
                itemEnough and "#00FFFC" or Enums.Color.eRedH,
                Utility.numberWithUnit(haveNum),
                "#00FFFC",
                Utility.numberWithUnit(needNum)
            ))
            return itemEnough
        end

        local showNum = 0
        if (petCostItem.modelId ~= nil) then
            showNum = showNum + 1
        end
        if (subCostItem.modelId ~= nil) then
            showNum = showNum + 1
        end
        if (showNum == 0) then
            showErrorLabel(TR("当前参悟不需要额外的材料消耗"))
        elseif (showNum == 1) then
            local showCostItem = (petCostItem.modelId ~= nil) and petCostItem or subCostItem
            showCostItemCard(showCostItem, 150)
            selectOneItem(showCostItem.modelId)
        else
            local petEnough = showCostItemCard(petCostItem, 70)
            local subEnough = showCostItemCard(subCostItem, 230)
            if (petEnough == subEnough) then
                -- 默认选择外功
                selectOneItem(petCostItem.modelId)
            else
                -- 默认选择数量足够的
                selectOneItem(petEnough and petCostItem.modelId or subCostItem.modelId)
            end
            showErrorLabel(TR("或者"), cc.c3b(0x46, 0x22, 0x0d))
        end
        
        -- 显示按钮
        local button = ui.newButton({
            normalImage = isCanUpdate and "wgcw_23.png" or "wgcw_02.png",
            position = cc.p(370, 70),
            clickAction = function()
                self:requestActiveTal(talItem, talInfo, parent, isCanUpdate)
            end
        })
        self.attrBgSprite:addChild(button)
        self.btnStudy = button

        -- 显示金币和灵玉
        local function addDaibiSprite(item, yPos)
            local daibiBgSprite = ui.newSprite("c_23.png")
            daibiBgSprite:setAnchorPoint(cc.p(0, 0.5))
            daibiBgSprite:setPosition(440, yPos)
            self.attrBgSprite:addChild(daibiBgSprite)

            -- 显示需求数量
            local haveNum = Utility.getOwnedGoodsCount(item.resourceTypeSub, item.modelId)
            local daibiLabel = ui.newLabel{    
                text = string.format("{%s} %s", Utility.getDaibiImage(item.resourceTypeSub, item.modelId), Utility.numberWithUnit(item.num)),
                size = 22,
                color = (haveNum < item.num) and Enums.Color.eRed or nil,
                outlineColor = cc.c3b(0x23, 0x23, 0x23),
                anchorPoint = cc.p(0, 0.5),
                x = 430,
                y = yPos
            }
            self.attrBgSprite:addChild(daibiLabel)
        end
        local yPosList = {45, 95}
        for i,v in ipairs(costList.mustCost) do
            addDaibiSprite(v, yPosList[i])
        end
    end
end

-- 选中一个天赋技能
function PetTalentLayer:selectOneTalNode(talId)
    for _,v in pairs(self.showTalNodeList) do
        if (talId == v.item.ID) then
            self:createTalAttr(v.item, v.node)
            v.node:setSelect(true)
        else
            v.node:setSelect(false)
        end
    end
end

-- 在两点之间画一条线
function PetTalentLayer:myDrawLine(beginPos, endPos, isRedColor)
    local disv = cc.p(beginPos.x - endPos.x, beginPos.y - endPos.y)
    local length = math.sqrt(disv.x * disv.x + disv.y * disv.y)
    local angle = math.atan(disv.x / disv.y)
    local calcAngle = (beginPos.y < endPos.y) and ((angle * 180) / math.pi) or ((angle * 180) / math.pi + 180)
    
    local showAngle = calcAngle - 90
    local height = 5
    if (showAngle > 0) then
        height = 4 -- 倾斜之后线条视觉效果变粗了，这里把它减小一点
    end

    local sprite = ui.newScale9Sprite(isRedColor and "wgcw_26.png" or "wgcw_07.png", cc.size(length, height))
    sprite:setRotation(showAngle)
    sprite:setAnchorPoint(cc.p(0, 0.5))
    sprite:setPosition(beginPos)
    self.mBgSprite:addChild(sprite)
end

-- 弹出技能描述
function PetTalentLayer:showTalentIntro(talItem, parent, pos)
    local isCanUpdate = false
    local talInfo = self.mCTalList[talItem.ID]
    if (talItem.layer - self.mCurrLayer) > 1 then
        -- 当前层的下一层的以下
    elseif (talItem.layer - self.mCurrLayer) == 1 then
        -- 当前层的下一层
    else
        -- 当前层
        if not talInfo then
        else
            if talInfo.TalentNum < talItem.totalNum then
                -- 可升级
                isCanUpdate = true
            end
        end
    end
    local descStrList = string.splitBySep(PetTalentHelper.getPetTalentIntroduce(self.mPetInfo, talItem.ID, isCanUpdate), "+")
    local strDesc = descStrList[1]
    for i,v in ipairs(descStrList) do
        if (i > 1) then
            strDesc = strDesc .. "#8DF55A\n+" .. v
        end
    end

    -- 关闭以前的
    if (self.flashBgSprite ~= nil) then
        self.flashBgSprite:stopAllActions()
        self.flashBgSprite:removeFromParent()
        self.flashBgSprite = nil
    end

    -- 显示背景
    local tmpBgSprite = ui.newSprite("wgcw_33.png")
    local tmpBgSize = tmpBgSprite:getContentSize()
    tmpBgSprite:setPosition(cc.p(pos.x, pos.y + 100))
    parent:addChild(tmpBgSprite, 999)
    self.flashBgSprite = tmpBgSprite

    -- 显示标题
    local nameSprite = ui.newSprite("wgcw_32.png")
    local nameSize = nameSprite:getContentSize()
    nameSprite:setPosition(tmpBgSize.width * 0.55, 105)
    tmpBgSprite:addChild(nameSprite)

    local nameLabel = ui.newLabel({
        text = TR("领悟:"),
        size = 24,
    })
    nameLabel:setPosition(nameSize.width * 0.4, nameSize.height * 0.5)
    nameSprite:addChild(nameLabel)

    -- 显示描述
    local descLabel = ui.newLabel({
        text = strDesc,
        size = 20,
        anchorPoint = cc.p(0.5, 0.5),
        dimensions = cc.size(tmpBgSize.width - 26, 70),
        align = cc.TEXT_ALIGNMENT_CENTER,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    })
    descLabel:setPosition(tmpBgSize.width * 0.5, 50)
    tmpBgSprite:addChild(descLabel)

    -- 显示动画
    local bgActList = {
        cc.FadeTo:create(0.5, 255),
        cc.DelayTime:create(2),
        cc.CallFunc:create(function()
            self.flashBgSprite:removeFromParent()
            self.flashBgSprite = nil
        end)
    }
    tmpBgSprite:runAction(cc.Sequence:create(bgActList))
end

----------------------------------------------------------------------------------------------------

-- 判断当前层的招式是否升级满了
function PetTalentLayer:isCurrLayerUpTop()
    local isTop = false
    local activeTalItem = nil
    local activeTalInfo = nil
    for _,v in pairs(self.nodeList[self.layerIdList[self.mShowLayer]]) do
        local tmpTalInfo = self.mCTalList[v.ID]
        if tmpTalInfo then
            activeTalItem = clone(v)
            activeTalInfo = clone(tmpTalInfo)
            break
        end
    end
    if (activeTalItem == nil) or (activeTalInfo == nil) then
        return false
    end

    local curNum = activeTalInfo.TalentNum or 0
    local maxNum = activeTalItem.totalNum or 0

    return (curNum == maxNum)
end

----------------------网络相关-------------------------
-- 请求服务器，参悟/升级招式
--[[
    params:
    talItem             -- 招式配置
    talInfo             -- 招式信息
    isUpdate            -- 如果为true就是升级，否则就是参悟
--]]
function PetTalentLayer:requestActiveTal(talItem, talInfo, parent, isUpdate)
    -- 判断等级是否足够
    local tmpNeedLv = talItem.needPetLv or 0
    if (self.mPetInfo.Lv < tmpNeedLv) then
        ui.showFlashView({text = TR("升到%d级才能解锁该层的招式", tmpNeedLv)})
        return
    end

    -- 资源不足提示
    local isEnough, resList = PetTalentHelper.isResourceEnough(self.mPetInfo, talItem, talInfo, self.selectItem)
    if not isEnough then
        for _, v in ipairs(resList) do
            if (v.resourceTypeSub == ResourcetypeSub.eGold) then
                -- 金币不足
                MsgBoxLayer.addGetGoldHintLayer()
            else
                -- 其他的：同名外功、替代道具、外功灵玉
                MsgBoxLayer.addOKCancelLayer(
                    TR("您的%s%s%s不足，是否前往获取?", Enums.Color.eNormalGreenH, Utility.getGoodsName(v.resourceTypeSub, v.modelId), Enums.Color.eNormalWhiteH),
                    TR("提示"),
                    {
                        text = TR("是"),
                        clickAction = function(layerObj, btnObj)
                            LayerManager.removeLayer(layerObj)

                            -- 直接跳转到挑战六大派
                            if ModuleInfoObj:moduleIsOpen(ModuleSub.eExpedition, true) then
                                LayerManager.showSubModule(ModuleSub.eExpedition)
                            end
                        end
                    },
                    {
                        text = TR("否")
                    }
                )
            end
            break
        end
        return
    end
    
    -- 读取材料参数
    local guidList, isSub = {}, 0
    if (self.selectItem ~= nil) then
        if Utility.isPet(self.selectItem.resourceTypeSub) then
            local list = PetObj:findByModelId(self.selectItem.modelId, {
                excludeIdList = {self.mPetInfo.Id},   -- 过滤掉自己，在参悟未上阵的外功时要用到
                notInFormation = true, 
                Lv = 1,
            })
            for i=1,self.selectItem.num do
                table.insert(guidList, list[i].Id)
            end
        else
            isSub = 1
        end
    end

    -- 请求服务器
    local parentNode = parent
    local parentSize = parent:getContentSize()
    HttpClient:request({
        moduleName = "Pet",
        methodName = "ActiveTal",
        svrMethodData = {self.mPetInfo.Id, talItem.ID, guidList, isSub},
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 禁止点击参悟按钮
            self.btnStudy:setEnabled(false)

            -- 更新本页数据及缓存数据，注：不能叠加的东西必须手动修改缓存
            self.mPetInfo = data.Value.PetInfo
            self.mPetList[self.mCurrIndex] = data.Value.PetInfo
            self.mCurrLayer = data.Value.PetInfo.Layer
            for k, v in pairs(data.Value.PetInfo.TalentInfoList or {}) do
                self.mCTalList[v.TalentID] = v
            end
            PetObj:modifyPetItem(data.Value.PetInfo)

            -- 删除消耗的同名外功
            if (#guidList > 0) then
                -- 删除缓存数据
                for _,v in ipairs(guidList) do
                    PetObj:deletePetById(v)
                end
                
                -- 更新本地数据
                local function removeOneId(theId)
                    for i, v in ipairs(self.mPetList) do
                        if v.Id == theId then
                            table.remove(self.mPetList, i)
                            break
                        end
                    end
                end
                for _,v in ipairs(guidList) do
                    removeOneId(v)
                end
                for i, v in ipairs(self.mPetList) do
                    if v.Id == self.mPetInfo.Id then
                        self.mCurrIndex = i
                        break
                    end
                end
            end
            
            -- 父页面数据更新
            if self.mCallback then
                self.mCallback(self.mPetList, self.mCurrIndex)
            end

            -- 播放特效
            if not isUpdate then
                MqAudio.playEffect("zhaomu.mp3")
            end
            ui.newEffect({
                parent = parentNode,
                effectName = "effect_ui_lingwuchenggong",
                position = cc.p(parentSize.width * 0.5, parentSize.height * 0.5),
                loop = false,
                endRelease = true,
                endListener = function ()
                    -- 升级满了就切换到下一页
                    if self:isCurrLayerUpTop() then
                        if (self.mShowLayer < self.maxLayer) then
                            self.mShowLayer = self.mShowLayer + 1
                        end
                        ui.newEffect({
                            parent = self,
                            effectName = "effect_ui_waigongfanye",
                            position = cc.p(320, 585),
                            loop = false,
                            endRelease = true,
                            endListener = function ()
                                self:refreshUI()
                            end
                        })
                    else
                        self:refreshUI()
                    end
                end
            })
        end
    })
end

-- 请求服务器，遗忘招式
function PetTalentLayer:requestResetTal()
    HttpClient:request({
        moduleName = "Pet",
        methodName = "ResetTal",
        svrMethodData = {self.mPetInfo.Id},
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 更新本页数据及缓存数据
            self.mPetInfo = data.Value.PetInfo
            self.mPetList[self.mCurrIndex] = data.Value.PetInfo
            self.mCurrLayer = data.Value.PetInfo.Layer
            self.mCTalList = {}
            -- 不能叠加的东西必须手动修改缓存
            PetObj:modifyPetItem(data.Value.PetInfo)
            
            -- 飘窗显示返还的消耗
            local resList = data.Value.BaseGetGameResourceList
            ui.ShowRewardGoods(resList)

            -- 返回的有外功秘籍
            local newPetList = resList and resList[1] and resList[1].Pet or {}
            for i, v in ipairs(newPetList) do
                -- 基本掉落的数据刷新，在 Player:addDropToResData 中已处理
                table.insert(self.mPetList, v)
            end

            -- 父页面数据更新
            if self.mCallback then
                self.mCallback(self.mPetList, self.mCurrIndex)
            end
            self.mShowLayer = 1     -- 返回到第一页
            self:refreshUI()
        end
    })
end

return PetTalentLayer
