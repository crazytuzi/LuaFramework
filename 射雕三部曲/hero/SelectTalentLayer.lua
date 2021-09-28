--[[
    文件名: SelectTalentLayer.lua
	描述: 人物选择天赋页面
	创建人: peiyaoqiang
    创建时间: 2017.04.28
--]]

local SelectTalentLayer = class("SelectTalentLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params中的每项为：
    {
    }
--]]
function SelectTalentLayer:ctor(params)
    -- 需要上阵的人物Id
    self.mHeroId = params.heroId
    -- 当前选择的突破次数
    self.mHeroStep = params.heroStep

    -- 当前位置穿戴的天赋ID
    self.currTalentId = HeroObj:getTalentIdByStep(self.mHeroId, self.mHeroStep)
    -- 保存所有已上阵的天赋ID
    self.allInteamList = {self.currTalentId}

    -- 是否隐藏已上阵人物
    self.mHideInFormation = true
    -- 天赋列表
    self.mTalentInfos = {}

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 初始化页面控件
	self:initUI()

	-- 创建底部导航和顶部玩家信息部分
	local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eFormation,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer, 1)

    -- 获取列表
    self:requestGetInfo()
end

-- 初始化页面控件
function SelectTalentLayer:initUI()
    -- 背景图片
	local bgSprite = ui.newSprite("c_34.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    local tempSprite = ui.newScale9Sprite("c_17.png", cc.size(630, 900))
    tempSprite:setAnchorPoint(cc.p(0.5, 1))
    tempSprite:setPosition(320, 1010)
    self.mParentLayer:addChild(tempSprite)

    -- 创建选择列表
    self:createListView()

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
    self.mParentLayer:addChild(self.mCloseBtn)
end

-- 创建选择列表
function SelectTalentLayer:createListView()
    -- 空列表提示
    self.mEmptyHintSprite = ui.createEmptyHint(TR("没有可以选择的招式"))
    self.mEmptyHintSprite:setPosition(320, 568)
    self.mParentLayer:addChild(self.mEmptyHintSprite)
    self.mToGetBtn = ui.newButton({
        text = TR("去获取"),
        normalImage = "c_28.png",
        fontSize = 21,
        clickAction = function ()
            if not ModuleInfoObj:moduleIsOpen(ModuleSub.eSect, true) then
                    return
                end

            SectObj:getSectInfo(function(response)
                if response.IsJoinIn then
                    LayerManager.addLayer({
                        name = "sect.SectBookLayer",
                        data = {}
                    })
                else
                    LayerManager.addLayer({
                        name = "sect.SectSelectLayer",
                        data = {}
                    })
                end
            end)
        end
        })
    self.mToGetBtn:setPosition(320, 400)
    self.mParentLayer:addChild(self.mToGetBtn, 10)

    --
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(640, 890))
    self.mListView:setPosition(cc.p(0, 115))
    self.mParentLayer:addChild(self.mListView)
    --
    self:refreshList()

    -- 显示隐藏开关的背景
    local bgCheckBox = ui.newSprite("c_41.png")
    bgCheckBox:setAnchorPoint(cc.p(0, 0.5))
    bgCheckBox:setPosition(cc.p(0, 1045))
    self.mParentLayer:addChild(bgCheckBox)

    -- 是否显示上阵人物开关按钮
    local checkBox = ui.newCheckbox({
        normalImage = "c_60.png",
        selectImage = "c_61.png",
        isRevert = false,
        text = TR("隐藏已上阵招式"),
        textColor = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
        callback = function(isSelected)
            self.mHideInFormation = isSelected
            self:refreshList()
        end
    })
    checkBox:setCheckState(true)
    checkBox:setAnchorPoint(cc.p(0, 0.5))
    checkBox:setPosition(cc.p(20, 1045))
    self.mParentLayer:addChild(checkBox)
end

-- 重新刷新列表数据显示
function SelectTalentLayer:refreshList()
    self.mListView:removeAllItems()

    -- 刷新数据
    local tmpTalentList = {}
    local function isInTeam(talentId)
        for _,v in pairs(self.allInteamList) do
            if (v == talentId) then
                return true
            end
        end
        return false
    end
    for _,modelId in pairs(self.mTalentInfos) do
        local item = {}
        item.modelId = modelId
        item.inTeam = isInTeam(modelId)
        if (not self.mHideInFormation) or (not item.inTeam) then
            table.insert(tmpTalentList, item)
        end
    end
    table.sort(tmpTalentList, function (a, b)
            if (a.modelId == self.currTalentId) then
                return true
            elseif (b.modelId == self.currTalentId) then
                return false
            else
                return a.modelId < b.modelId
            end
        end)

    -- 刷新列表
    local cellSize = cc.size(640, 128)
    for _,v in ipairs(tmpTalentList) do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mListView:pushBackCustomItem(lvItem)
        -- 子条目背景
        local tempSprite = ui.newScale9Sprite("c_18.png", cc.size(600, 120))
        tempSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
        lvItem:addChild(tempSprite)
        -- 天赋模型
        local talentBase = TalModel.items[v.modelId]
        -- 天赋对应的功法
        local bookData = self:findBookData(v.modelId)

        -- 显示头像
        local tempCard = CardNode.createCardNode({
            resourceTypeSub = bookData.typeID,
            modelId = bookData.ID,
            cardShowAttrs = {CardShowAttr.eBorder},
            allowClick = true, --是否可点击
        })
        -- tempCard:setTalent(v.modelId, {CardShowAttr.eBorder})
        tempCard:setPosition(100, cellSize.height / 2)
        lvItem:addChild(tempCard)

        -- 人物的名字
        local tempLabel = ui.newLabel({
            text = bookData.name,
            color = Utility.getQualityColor(Utility.getPlayerAttrQuality(ResourcetypeSub.eEXP), 1),
            size = 24,
            align = cc.TEXT_ALIGNMENT_LEFT,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        })
        tempLabel:setAnchorPoint(cc.p(0, 0.5))
        tempLabel:setPosition(165, cellSize.height / 2 + 25)
        lvItem:addChild(tempLabel)

        -- 人物的资质
        local tempLabel = ui.newLabel({
            text = talentBase.intro,
            color = cc.c3b(0x41, 0x1c, 0x00),
            size = 20,
            dimensions = cc.size(300, 100),
            align = cc.TEXT_ALIGNMENT_LEFT,
            valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        })
        tempLabel:setAnchorPoint(cc.p(0, 1))
        tempLabel:setPosition(165, cellSize.height / 2)
        lvItem:addChild(tempLabel)

        -- 判断是否上阵
        if v.inTeam then
            local tempSprite = ui.createStrImgMark("c_62.png", TR("已上阵"), Enums.Color.eNormalWhite)
            local tempSize = tempSprite:getContentSize()
            tempSprite:setPosition(620 - tempSize.width / 2 - 1, 124 - tempSize.height / 2 - 1)
            tempSprite:setRotation(90)
            lvItem:addChild(tempSprite, 1)
        end

        -- 选择按钮
        local tempBtn = ui.newButton({
            text = (self.currTalentId == v.modelId) and TR("卸下") or TR("选择"),
            normalImage = "c_28.png",
            clickAction = function()
                -- 卸下
                if self.currTalentId == v.modelId then
                    self:requestTalent(0)
                    return
                end

                -- 上阵
                if v.inTeam then
                    ui.showFlashView(TR("该招式已上阵"))
                else
                    local talImpact = self:getTalImpact(bookData.ID)
                    local hintStr = ""
                    -- 不需要提示的效果
                    if talImpact == 0 then
                        self:requestTalent(v.modelId)
                        return
                    -- 正面效果
                    elseif talImpact == 1 then
                        hintStr = TR("如果大侠没有装备治疗类绝学，该招式正面效果（如：回怒效果）会对敌方生效，建议大侠先学习治疗类绝学再选择该招式，是否确认选择？")
                    -- 负面效果
                    elseif talImpact == 2 then
                        hintStr = TR("如果大侠装备治疗类绝学，该招式负面效果会对己方生效，是否确认选择？")
                    end

                    self.hintBox = MsgBoxLayer.addOKLayer(hintStr, TR("招式"), {
                            {
                                text = TR("选择"),
                                clickAction = function ()
                                    self:requestTalent(v.modelId)
                                    LayerManager.removeLayer(self.hintBox)
                                end
                            }
                        }, {})
                end
            end
        })
        tempBtn:setPosition(530, cellSize.height / 2)
        lvItem:addChild(tempBtn)
    end

    self.mEmptyHintSprite:setVisible(next(tmpTalentList) == nil)
    self.mToGetBtn:setVisible(next(tmpTalentList) == nil)
end

-- 查找天赋的效果是正面还是负面
--[[
params:
    talId       -- 天赋id
返回值:
    result      -- 0:无影响效果 1:正面效果 2:负面效果
]]
function SelectTalentLayer:getTalImpact(bookModelId)
    local positiveBookList = {
        [26010408] = true,      -- 西子捧心
    }
    local negativeBookList = {
        [26010208] = true,      -- 玉蜂素心针
        [26010108] = true,      -- 苍云白鹤
        [26010308] = true,      -- 寒灯望月
    }

    if positiveBookList[bookModelId] then
        return 1
    elseif negativeBookList[bookModelId] then
        return 2
    end

    return 0
end

-- 找对应功法数据
function SelectTalentLayer:findBookData(talId)
    for _, v in pairs(SectBookModel.items) do
        if v.TALModelID == talId then
            return v
        end
    end
end

-- 获取可选择的天赋技能列表
function SelectTalentLayer:requestGetInfo()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Hero",
        methodName = "HeroChoiceTalentInfo",
        svrMethodData = {self.mHeroId, self.mHeroStep},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mTalentInfos = response.Value.ChoiceTalent or {}
            self:refreshList()
        end,
    })
end

-- 上阵选中的天赋技能
function SelectTalentLayer:requestTalent(modelId)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Hero",
        methodName = "HeroChoiceTalent",
        svrMethodData = {self.mHeroId, self.mHeroStep, modelId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            HeroObj:modifyTalentIdByStep(self.mHeroId, self.mHeroStep, modelId)
            LayerManager.removeLayer(self)
        end,
    })
end


return SelectTalentLayer
