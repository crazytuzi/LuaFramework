--[[
    文件名:TreasureUpLayer.lua
    描述：神兵强化、进阶导航页
    创建人：liaoyuangang
    创建时间：2016.06.19
--]]

local TreasureUpLayer = class("TreasureUpLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params 中各项为：
	{
		treasureId: 神兵实例Id
		subPageType: 默认显示子页面类型, 取值为EnumsConfig.lua文件中ModuleSub的 eTreasureLvUp\eTreasureStepUp, 默认为 eTreasureLvUp
        subPageData: 子页面的恢复数据
	}
]]
function TreasureUpLayer:ctor(params)
    -- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})
	--
	params = params or {}
	-- 神兵实例Id
	self.mTreasureId = params.treasureId
	-- 默认显示子页面类型
	self.mSubPageType = params.subPageType or ModuleSub.eTreasureLvUp
    -- 子页面的恢复数据
    self.mSubPageData = params.subPageData or {}

    local treasureItem = TreasureObj:getTreasure(self.mTreasureId)
    self.mTreasureModel = TreasureModel.items[treasureItem.ModelId]
    if self.mSubPageType == ModuleSub.eTreasureStepUp and self.mTreasureModel.maxStep == 0 then
        self.mSubPageType = ModuleSub.eTreasureLvUp
    end

	-- 子页面的parent
    self.mSubParent = ui.newStdLayer()
    self:addChild(self.mSubParent)

    -- 显示背景图
    local bgSprite = ui.newSprite("c_34.jpg")
    bgSprite:setPosition(320, 568)
    self.mSubParent:addChild(bgSprite)

    local tempSprite = ui.newSprite("zr_16.jpg")
    tempSprite:setAnchorPoint(cc.p(0.5, 1))
    tempSprite:setPosition(320, 1136)
    self.mSubParent:addChild(tempSprite)

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 

	-- 初始化页面控件
	self:initUI()

	-- 创建底部导航和顶部玩家信息部分
	local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

	-- 切换页面
    self:changePage()
end

-- 初始化页面控件
function TreasureUpLayer:initUI()
    -- 添加黑底
    local decBgSize = cc.size(640, 97)
    local decBg = ui.newScale9Sprite("c_73.png", decBgSize)
    decBg:setPosition(cc.p(320, 1041))
    self.mParentLayer:addChild(decBg)

	local tabBtnInfos = {
        {
            text = TR("强化"),
            tag = ModuleSub.eTreasureLvUp,
        },
        {
            text = TR("进阶"),
            tag = ModuleSub.eTreasureStepUp,
        },
    }
    self.mTabView = require("common.TabView"):create({
        btnInfos = tabBtnInfos,
        defaultSelectTag = self.mSubPageType,
        allowChangeCallback = function(btnTag)
            -- 判断是否达到开启等级
            if not ModuleInfoObj:modulePlayerIsOpen(btnTag, true) then
                return false
            end
            if btnTag == ModuleSub.eTreasureStepUp and self.mTreasureModel.maxStep == 0 then  -- 判断该神兵是否可以进阶
                ui.showFlashView(TR("该神兵不能进阶"))
                return false
            end

            return true
        end,
        onSelectChange = function(selBtnTag)
            if self.mSubPageType == selBtnTag then
                return
            end
            if not tolua.isnull(self.mCurrPageNode) and self.mCurrPageNode.getRestoreData then
                self.mSubPageData[self.mSubPageType] = self.mCurrPageNode:getRestoreData()
            end

            self.mSubPageType = selBtnTag
            -- 切换页面
            self:changePage()
        end
    })
    self.mTabView:setPosition(Enums.StardardRootPos.eTabView)
    self.mParentLayer:addChild(self.mTabView)
    
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

-- 获取恢复数据
function TreasureUpLayer:getRestoreData()
    local retData = {}

    retData.treasureId = self.mTreasureId
    retData.subPageType = self.mSubPageType
    retData.subPageData = self.mSubPageData

    return retData
end

-- 切换页面
function TreasureUpLayer:changePage()
	-- 先删除原来的子页面
    if not tolua.isnull(self.mCurrPageNode) then
        self.mCurrPageNode:removeFromParent()
        self.mCurrPageNode = nil
    end

    local subPageData = self.mSubPageData[self.mSubPageType] or {}
    subPageData.treasureId = self.mTreasureId
    if self.mSubPageType == ModuleSub.eTreasureLvUp then -- 强化
        self.mCurrPageNode = require("equip.TreasureLvUpView"):create(subPageData)
        self.mSubParent:addChild(self.mCurrPageNode)
    elseif self.mSubPageType == ModuleSub.eTreasureStepUp then -- 进阶
        self.mCurrPageNode = require("equip.TreasureStepUpView"):create(subPageData)
        self.mSubParent:addChild(self.mCurrPageNode)
    end
end

return TreasureUpLayer