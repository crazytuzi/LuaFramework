--[[
    文件名：HeroBookLayer.lua
    描述：招式详情界面
    创建人：yanghongsheng
    创建时间：2017.9.2
-- ]]

local HeroBookLayer = class("HeroBookLayer", function()
    return  display.newLayer()
end)

--[[
    params:
    {
        parent              父节点
        heroData            hero信息
    }
--]]
function HeroBookLayer:ctor(params)
    -- 传入参数
    self.mParent = params.parent
    self.mHeroId = params.heroId
    self.mTalFloorNum = params.selectTalentIdx or 1
    
    -- 天赋列表
    self.mTalentInfos = {}

    -- 初始化界面
    self:initLayer()

    self:showInfo()
end


-- 初始化界面
function HeroBookLayer:initLayer()
    -- 父容器（Tab显示的可见区域）
    local layout = ccui.Layout:create()
    layout:setContentSize(640, 435)
    layout:setAnchorPoint(0.5, 0)
    layout:setPosition(320, 80)
    self:addChild(layout)
    self.mPanelLayout = layout
    
    -- 属性信息背景框
    local blackBgSize = cc.size(508, 398)
    local blackBgSprite = ui.newScale9Sprite("c_17.png", blackBgSize)
    blackBgSprite:setAnchorPoint(cc.p(1, 1))
    blackBgSprite:setPosition(630, 420)
    self.mPanelLayout:addChild(blackBgSprite)

    local twoBgSprite = ui.newScale9Sprite("c_18.png", cc.size(500, 390))
    twoBgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    twoBgSprite:setPosition(blackBgSize.width*0.5, blackBgSize.height*0.5)
    blackBgSprite:addChild(twoBgSprite)
    -- 更换按钮
    local button = ui.newButton({
        normalImage = "c_28.png",
        position = cc.p(360, 60),
        text = TR("更换"),
        clickAction = function()
            -- 修改当前选中招式等级
            self.mParent.selectTalentIdx = self.mTalFloorNum
            -- 跳转招式选择界面
            LayerManager.addLayer({
            		name = "hero.SelectTalentLayer",
            		data = {
            			heroId = self.currHeroId,
                        heroStep = self.mTalFloorNum,
            		}
            	})
        end
    })
    self.mPanelLayout:addChild(button)
    self.changeBtn = button
    -- 创建招式类型列表
    self:createBtnList()
end

-- 创建按钮列表
function HeroBookLayer:createBtnList()
    local btnInfos = {
        [1] = {     -- 入流
            normalImage = "mp_36.png",  -- 按钮图
            tag = 1,                    -- 天赋层数
        },
        [2] = {     -- 妙招
            normalImage = "mp_38.png",  -- 按钮图
            tag = 2,                    -- 天赋层数
        },
        [3] = {     -- 秘式
            normalImage = "mp_37.png",  -- 按钮图
            tag = 3,                    -- 天赋层数
        },
    }
    -- 招式等级列表
    local btnListView = ccui.ListView:create()
    btnListView:setDirection(ccui.ScrollViewDir.vertical)
    btnListView:setContentSize(cc.size(150, 400))
    btnListView:setItemsMargin(5)
    btnListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    btnListView:setAnchorPoint(cc.p(0, 0.5))
    btnListView:setPosition(0, 180)
    self.mPanelLayout:addChild(btnListView, 1)
    -- 初始化列表
    for i, btnInfo in pairs(btnInfos) do
        local cellSize = cc.size(150, 80)
        local item = ccui.Layout:create()
        item:setContentSize(cellSize)
        -- 选中图
        local selectSprite = ui.newSprite("mp_34.png")
        selectSprite:setAnchorPoint(cc.p(0, 0.5))
        selectSprite:setPosition(0, cellSize.height*0.5)
        item:addChild(selectSprite)
        selectSprite:setVisible(false)
        local selectSprite2 = ui.newSprite("c_26.png")
        selectSprite2:setPosition(125, selectSprite:getContentSize().height*0.5)
        selectSprite:addChild(selectSprite2)
        -- 显示默认选中
        if self.mTalFloorNum == btnInfo.tag then
            selectSprite:setVisible(true)
            self.selectSprite = selectSprite
        end
        -- 招式等级按钮
        local talBtn = ui.newButton({
                normalImage = btnInfo.normalImage,
                clickAction = function ()
                    if self.mTalFloorNum == btnInfo.tag then return end
                    -- 隐藏当前选中图
                    if self.selectSprite then self.selectSprite:setVisible(false) end
                    -- 显示新选中图
                    selectSprite:setVisible(true)
                    -- 更新当前选中项
                    self.selectSprite = selectSprite
                    -- 更新右边招式详情ui
                    self:refreshRightUI(btnInfo.tag)
                end
            })
        talBtn:setAnchorPoint(cc.p(0, 0.5))
        talBtn:setPosition(0, cellSize.height*0.5)
        item:addChild(talBtn)

        btnListView:pushBackCustomItem(item)

        -- 招式按钮小红点
        local currentIndex = i
        local function dealRedDotVisible(redDotSprite)
            local talInfo = SlotPrefObj:haveMainHeroTal()
            redDotSprite:setVisible(table.keyof(talInfo or {}, currentIndex) ~= nil)
        end
        local eventNames = {SelectSlotChange, EventsName.eRedDotPrefix .. tostring(ModuleSub.eFormation)}
        ui.createAutoBubble({parent = talBtn, eventName = eventNames, refreshFunc = dealRedDotVisible})
    end
end

-- 找对应功法数据
function HeroBookLayer:findBookData(talId)
    for _, v in pairs(SectBookModel.items) do
        if v.TALModelID == talId then
            return v
        end
    end
end
 -- 更新右边招式详情ui
function HeroBookLayer:refreshRightUI(tag)
    -- 更新当前选中招式等级id
    self.mTalFloorNum = tag
    -- 获取该层装备的招式模型id
    local talModelId = HeroObj:getTalentIdByStep(self.currHeroId, tag)
    -- 移除右边ui节点
    if self.rightUINode then
        self.rightUINode:removeFromParent()
        self.rightUINode = nil
    end
    -- 新建ui父节点
    self.rightUINode = cc.Node:create()
    self.mPanelLayout:addChild(self.rightUINode)
    -- 刷新更新显示
    self.changeBtn:setVisible(true)
    -- 若该层没有装备招式
    if talModelId == nil or talModelId == 0 then
        self.changeBtn:setVisible(false)
        if self.mTalentInfos[tag] then
            self:createEmptyHint(tag, self.rightUINode)
        else
            self:requestGetInfo(tag, self.rightUINode)
        end
        return
    end
    -- 获取改天赋对应的功法
    local bookData = self:findBookData(talModelId)
    -- 获取天赋数据
    local talData = TalModel.items[talModelId]
    -- 招式底图
    local  zhaoshiBg = ui.newSprite("mp_49.png")
    zhaoshiBg:setPosition(210, 320)
    self.rightUINode:addChild(zhaoshiBg)
    -- 招式图
    local zhaoshiSprite = ui.newSprite(bookData.pic..".png")
    if zhaoshiSprite then
        zhaoshiSprite:setPosition(210, 320)
        self.rightUINode:addChild(zhaoshiSprite)
    end
    -- 获取品质颜色
    local color = Utility.getColorValue(bookData.valueLv, 1)
    -- 招式名
    local nameLabel = ui.newLabel({
            text = bookData.name,
            color = color,
            outlineColor = Enums.Color.eBlack,
            size = 24,
        })
    nameLabel:setAnchorPoint(cc.p(0, 0))
    nameLabel:setPosition(300, 360)
    self.rightUINode:addChild(nameLabel)
    -- 简介
    local introLabel = ui.newLabel({
            text = bookData.intro,
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
            dimensions = cc.size(300, 0)
        })
    introLabel:setAnchorPoint(cc.p(0, 1))
    introLabel:setPosition(300, 350)
    self.rightUINode:addChild(introLabel)
    -- 招式效果背景框
    local bgSize = cc.size(470, 120)
    local bgSprite = ui.newScale9Sprite("c_54.png", bgSize)
    bgSprite:setPosition(380, 160)
    self.rightUINode:addChild(bgSprite)
    -- 招式效果title
    local titleLabel = ui.newLabel({
            text = TR("招式效果"),
            size = 24,
            color = cc.c3b(0xfa, 0xf6, 0xf1),
            outlineColor = cc.c3b(0x8d, 0x4b, 0x3a),
        })
    titleLabel:setPosition(bgSize.width*0.5, bgSize.height - 20)
    bgSprite:addChild(titleLabel)
    -- 招式效果content
    local contentLabel = ui.newLabel({
            text = talData.intro,
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
        })
    contentLabel:setAnchorPoint(cc.p(0, 1))
    contentLabel:setPosition(20, bgSize.height - 50)
    bgSprite:addChild(contentLabel)
end

function HeroBookLayer:createEmptyHint(tag, parent)
    if not next(self.mTalentInfos[tag] or {}) then
        -- 空列表提示
        local emptyHintSprite = ui.createEmptyHint(TR("没有可以选择的招式"))
        emptyHintSprite:setPosition(380, 300)
        parent:addChild(emptyHintSprite)
        local getBtn = ui.newButton({
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
        getBtn:setPosition(320, 120)
        parent:addChild(getBtn, 10)
    else
        -- 空列表提示
        local emptyHintSprite = ui.createEmptyHint(TR("有可以装备的招式"))
        emptyHintSprite:setPosition(380, 300)
        parent:addChild(emptyHintSprite)
        local getBtn = ui.newButton({
            text = TR("去装备"),
            normalImage = "c_28.png",
            fontSize = 21,
            clickAction = function ()
                -- 修改当前选中招式等级
                self.mParent.selectTalentIdx = tag
                -- 跳转招式选择界面
                LayerManager.addLayer({
                        name = "hero.SelectTalentLayer",
                        data = {
                            heroId = self.currHeroId,
                            heroStep = tag,
                        }
                    })
            end
            })
        getBtn:setPosition(320, 120)
        parent:addChild(getBtn, 10)
    end

end

--- ==================== 数据显示相关 =======================
-- 显示所有信息
function HeroBookLayer:showInfo()
    local data = HeroObj:getHero(self.mHeroId)
    self.mParent.mNameNode:refreshName(data)

    self.currHeroId = data.Id
    self:refreshRightUI(self.mTalFloorNum)
end


--====================服务器相关================
-- 获取可选择的天赋技能列表
function HeroBookLayer:requestGetInfo(tag, parent)
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Hero",
        methodName = "HeroChoiceTalentInfo",
        svrMethodData = {self.currHeroId, tag},
        needWait = false,
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mTalentInfos[tag] = response.Value.ChoiceTalent or {}
            self:createEmptyHint(tag, parent)
        end,
    })
end


return HeroBookLayer