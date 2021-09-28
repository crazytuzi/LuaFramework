--[[
	文件名:EquipInfoLayer.lua
	描述：装备详细信息页面
	创建人：peiyaoqiang
	创建时间：2017.03.12
--]]

local EquipInfoLayer = class("EquipInfoLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params 中各项为：
	{
		-- 以下3个参数按照优先级排序，如果有前面的参数，就忽略后面的
		equipItem: 装备信息，直接显示装备信息
		equipId: 装备实例Id，从装备缓存里读取信息显示
		equipModelId: 装备模型Id，只显示装备的基础信息
	}
]]
function EquipInfoLayer:ctor(params)
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})
	params = params or {}

	if (params.equipItem ~= nil) then
		self.mEquipItem = clone(params.equipItem)
		self.mEquipModelId = self.mEquipItem.ModelId
	elseif Utility.isEntityId(params.equipId) then
		self.mEquipItem = EquipObj:getEquip(params.equipId)
		self.mEquipModelId = self.mEquipItem.ModelId or params.equipModelId --or params.equipModelId 较之前版本增加容错处理
	else
		self.mEquipModelId = params.ModelId or params.equipModelId--or params.equipModelId 较之前版本增加容错处理
	end
	self.mEquipModel = EquipModel.items[self.mEquipModelId]

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 

	-- 初始化页面控件
	self:initUI()
end

-- 初始化页面控件
function EquipInfoLayer:initUI()
	-- 背景图片
	local bgSprite = ui.newSprite("ng_17.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)
	
	-- 创建装备形象
	self:createFigureInfo()

	-- 创建装备详细信息
	local mDetailView = require("equip.EquipDetailView"):create({
		viewSize = cc.size(595, 510),
		equipInfo = self.mEquipItem,
		equipModelId = self.mEquipModelId,
	})
	mDetailView:setPosition(320, 110)
	mDetailView:setAnchorPoint(cc.p(0.5, 0))
	mDetailView:setIgnoreAnchorPointForPosition(false)
	self.mInfoBg:addChild(mDetailView)

	-- 关闭按钮
	local mCloseBtn = ui.newButton({
		normalImage = "c_29.png",
		clickAction = function()
			LayerManager.removeLayer(self)
		end
	})
	mCloseBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
	self.mParentLayer:addChild(mCloseBtn)
	
	-- 获取途径按钮
	if Utility.getQualityColorLv(self.mEquipModel.quality) >= 3 then
		local tempBtn = ui.newButton({
			normalImage = "tb_34.png",
			clickAction = function()
				LayerManager.addLayer({
		            name = "hero.DropWayLayer",
		            data = {
		                resourceTypeSub = self.mEquipModel.typeID,
		                modelId = self.mEquipModelId
		            },
		            cleanUp = false,
		        })
			end
		})
		tempBtn:setPosition(580, 610)
		self.mParentLayer:addChild(tempBtn)
	end
end

-- 创建装备形象
function EquipInfoLayer:createFigureInfo()
	-- 创建装备图片
	local tempNode = Figure.newEquip({
		modelId = self.mEquipModelId, 
		needAction = true,
		viewSize = cc.size(640, 400)
	})
	tempNode:setAnchorPoint(cc.p(0.5, 0))
	tempNode:setPosition(320, 630)
	self.mParentLayer:addChild(tempNode)

	-- 面板背景
	self.mInfoBg = ui.newScale9Sprite("c_19.png", cc.size(640, 670))
	self.mInfoBg:setAnchorPoint(cc.p(0.5, 0))
	self.mInfoBg:setPosition(cc.p(320, -100))
	self.mParentLayer:addChild(self.mInfoBg)

	-- 灰色背景
    local tmpGraySprite = ui.newScale9Sprite("c_17.png", cc.size(620, 520))
    tmpGraySprite:setAnchorPoint(0.5, 1)
    tmpGraySprite:setPosition(320, 627)
    self.mInfoBg:addChild(tmpGraySprite)

	-- 装备的星级
	Figure.newEquipStarLevel({
		parent = self.mParentLayer,
		anchorPoint = cc.p(0.5, 1),
		position = cc.p(320, 1120),
		info = self.mEquipItem,
		modelId = self.mEquipModelId,
	})

	-- 装备的名字
	local hColor = Utility.getQualityColor(self.mEquipModel.quality, 2)
	local strName = TR("等级%d[%s]%s%s", self.mEquipItem and self.mEquipItem.Lv or 0, ResourcetypeSubName[self.mEquipModel.typeID], hColor, self.mEquipModel.name)
	local mNameLabel = ui.createSpriteAndLabel({
        imgName = "c_25.png",
        labelStr = strName,
        fontSize = 24,
        fontColor = cc.c3b(0xff, 0xfb, 0xde),
        outlineColor = cc.c3b(0x37, 0x30, 0x2c),
        outlineSize = 2,
    })
    mNameLabel:setAnchorPoint(cc.p(0.5, 1))
    mNameLabel:setPosition(320, 1086)
    self.mParentLayer:addChild(mNameLabel)
end

return EquipInfoLayer
