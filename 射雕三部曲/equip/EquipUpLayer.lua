--[[
    文件名:EquipUpLayer.lua
    描述：装备强化、进阶导航页
    创建人：peiyaoqiang
    创建时间：2017.03.15
--]]
local EquipUpLayer = class("EquipUpLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params 中各项为：
	{
		equipId: 装备实例Id
		defaultTag: 默认显示子页面类型, 取值为EnumsConfig.lua文件中ModuleSub的 eEquipLvUp\eEquipStarUp\eEquipStepUp, 默认为 eEquipLvUp
	}
]]
function EquipUpLayer:ctor(params)
    -- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})
	
	-- 处理参数
	self.mEquipId = params.equipId
	self.defaultTag = params.defaultTag or ModuleSub.eEquipLvUp
    self.resStarItem = params.resStarItem

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 

    -- 显示背景图
    local bgSprite = ui.newSprite("ng_17.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

	-- 创建人物名称等基本信息
    self:createEquipInfo()

    -- 创建培养信息
    self:createTrainInfo()

	-- 创建底部导航和顶部玩家信息部分
	local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eFormation,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

    -- 关闭按钮
    local mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    mCloseBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
    self.mParentLayer:addChild(mCloseBtn)
end

-- 创建装备信息
function EquipUpLayer:createEquipInfo()
    self.mEquipInfoNode = cc.Node:create()
    self.mParentLayer:addChild(self.mEquipInfoNode)

    -- 创建装备的名字
    local mNameLabel = ui.createSpriteAndLabel({
        imgName = "c_25.png",
        labelStr = "",
        fontSize = 24,
        fontColor = cc.c3b(0xff, 0xfb, 0xde),
        outlineColor = cc.c3b(0x37, 0x30, 0x2c),
        outlineSize = 2,
    })
    mNameLabel:setAnchorPoint(cc.p(0.5, 1))
    mNameLabel:setPosition(320, 1070)
    self.mEquipInfoNode:addChild(mNameLabel)

    -- 创建大图
    local figureNode = Figure.newEquip({
        modelId = 0,
        needAction = true,
        viewSize = cc.size(640, 400)
    })
    figureNode:setAnchorPoint(cc.p(0.5, 0))
    figureNode:setPosition(320, 610)
    self.mEquipInfoNode:addChild(figureNode)

    -- 刷新装备信息（名字、星级、大图等）
    self.mEquipInfoNode.refresh = function()
        if self.mEquipInfoNode.mStarNode then
            self.mEquipInfoNode.mStarNode:removeFromParent()
            self.mEquipInfoNode.mStarNode = nil
        end

        local tempEquip = EquipObj:getEquip(self.mEquipId)
        local tempModel = EquipModel.items[tempEquip.ModelId]
        local hColor = Utility.getQualityColor(tempModel.quality, 2)
        mNameLabel:setString(string.format("[%s]%s%s", ResourcetypeSubName[tempModel.typeID], hColor, tempModel.name))
        figureNode:changeEquip(tempEquip.ModelId, tempModel.typeID)

        -- 播放特效
        if (self.needPlayEffect ~= nil) then
            ui.newEffect({
                parent = self.mParentLayer,
                effectName = self.needPlayEffect.name,
                position = self.needPlayEffect.pos,
                zorder = 1,
                loop = false,
                endRelease = true,
            })
            self.needPlayEffect = nil
        end

        -- 显示星级
        self.mEquipInfoNode.mStarNode = Figure.newEquipStarLevel({
            parent = self.mEquipInfoNode,
            anchorPoint = cc.p(0.5, 1),
            position = cc.p(320, 1015),
            guid = tempEquip.Id,
        })
    end
    self.mEquipInfoNode.refresh()
end

-- 创建培养信息
function EquipUpLayer:createTrainInfo()
    self.mTrainInfoNode = cc.Node:create()
    self.mParentLayer:addChild(self.mTrainInfoNode)

    -- 显示背景图
    local bgSize = cc.size(640, 530)
    local bgSprite = ui.newScale9Sprite("c_19.png", bgSize)
    bgSprite:setAnchorPoint(0.5, 0)
    bgSprite:setPosition(320, 0)
    self.mTrainInfoNode:addChild(bgSprite, 1)
    self.mTrainInfoNode.bgSprite = bgSprite

    -- 刷新培养信息
    self.mTrainInfoNode.refresh = function(target)
        target.bgSprite:removeAllChildren()

        local viewSrcList = {
            [ModuleSub.eEquipLvUp] = "equip.SubEquipLvUpView",
            [ModuleSub.eEquipStarUp] = "equip.SubEquipStarUpView",
            [ModuleSub.eEquipStepUp] = "equip.SubEquipStepUpView",
        }
        local tempEquip = EquipObj:getEquip(self.mEquipId)
        local mSubView = require(viewSrcList[self.defaultTag]):create({
            parentName = "equip.EquipUpLayer",
            resStarItem = self.resStarItem,
            viewSize = cc.size(bgSize.width, bgSize.height - 100),
            equipId = tempEquip.Id,
            parent = self,
            callback = function(responseType)
                -- 显示特效
                if responseType == ModuleSub.eEquipLvUp then
                elseif responseType == ModuleSub.eEquipStarUp then
                    self.needPlayEffect = {name = "effect_ui_zhuangbeishengxing", pos = cc.p(317, 725)}
                elseif responseType == ModuleSub.eEquipStepUp then
                    self.needPlayEffect = {name = "effect_ui_zhuangbeishengjie", pos = cc.p(310, 735)}
                end

                -- 刷新页面
                self.resStarItem = nil
                if self.mEquipInfoNode then
                    self.mEquipInfoNode:refresh()
                end

                if self.mTrainInfoNode then
                    self.mTrainInfoNode:refresh()
                end
            end,
        })
        mSubView:setPosition(0, 100)
        target.bgSprite:addChild(mSubView)
    end

    -- 显示Tab
    local buttonInfos = {
        {
            tag = ModuleSub.eEquipLvUp,
            text = TR("强化"),
        },
        {
            tag = ModuleSub.eEquipStepUp,
            text = TR("锻造"),
        },
        {
            tag = ModuleSub.eEquipStarUp,
            text = TR("升星"),
        },
    }
    local tabLayer = ui.newTabLayer({
        btnInfos = buttonInfos,
        btnSize = cc.size(122, 56), 
        defaultSelectTag = self.defaultTag,
        needLine = false,
        onSelectChange = function (tag)
            self.defaultTag = tag
            self.mTrainInfoNode:refresh()
        end
    })
    tabLayer:setAnchorPoint(cc.p(0.5, 0))
    tabLayer:setPosition(cc.p(320, 510))
    self.mTrainInfoNode:addChild(tabLayer)
end

--- ============================ 页面恢复相关 ==========================
-- 获取恢复该页面的参数
function EquipUpLayer:getRestoreData()
    local retData = {}
    retData.equipId = self.mEquipId
    retData.defaultTag = self.defaultTag
    retData.resStarItem = self.resStarItem

    return retData
end

return EquipUpLayer