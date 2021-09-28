--[[
	文件名:ZhenyuanInfoLayer.lua
	描述：真元详细信息页面
	创建人: peiyaoqiang
	创建时间: 2017.04.05
--]]

local ZhenyuanInfoLayer = class("ZhenyuanInfoLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params 中各项为：
	{
		zhenyuanInfo: 真元的详情，如果不传入该参数，那么只展示modelId对应的真元基础信息
		modelId: 真元模型Id, 如果 zhenyuanInfo 为有效值，该参数失效
		onlyViewInfo: 是否只查看信息，不显示操作按钮，默认为true
	}
]]
function ZhenyuanInfoLayer:ctor(params)
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})
	
	-- 处理参数
	params = params or {}
	self.mOnlyViewInfo = params.onlyViewInfo
	self.mZhenyuanItem = params.zhenyuanInfo
	self.findSlotIdx = 0
	self.findZhenyuanIdx = 0
	if self.mZhenyuanItem and self.mZhenyuanItem.Id then
		self.mModelId = self.mZhenyuanItem.ModelId

		-- 计算该真元所在的卡槽
    	local function findOneZhenyuanItem(tmpSlot)
    		if (tmpSlot == nil) or (tmpSlot.ZhenYuan == nil) then
    			return 0
    		end
    		for i,v in ipairs(tmpSlot.ZhenYuan) do
    			if (v.Id == self.mZhenyuanItem.Id) then
    				return i
    			end
    		end
    		return 0
    	end
    	for i=1,6 do
    		local tmpIdx = findOneZhenyuanItem(FormationObj:getSlotInfoBySlotId(i))
    		if (tmpIdx > 0) then
    			self.findSlotIdx = i
    			self.findZhenyuanIdx = tmpIdx
    			break
    		end
    	end
	else
		self.mModelId = params.modelId or params.ModelId
		self.mOnlyViewInfo = true
	end
	self.mModel = ZhenyuanModel.items[self.mModelId]
	if (self.mOnlyViewInfo == nil) then
		self.mOnlyViewInfo = true
	end

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 
	-- 初始化页面控件
	self:initUI()
end

-- 初始化页面控件
function ZhenyuanInfoLayer:initUI()
	-- 背景图片
	local bgSprite = ui.newSprite("ng_17.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	local pic = Figure.newZhenyuan({
		viewSize = cc.size(640, 420),
		modelId = self.mModelId,
		needAction = true,
	})
	pic:setAnchorPoint(cc.p(0.5, 0))
	pic:setPosition(320, 620)
	self.mParentLayer:addChild(pic)

	-- 面板背景
	local bgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 570))
	bgSprite:setAnchorPoint(cc.p(0.5, 0))
	bgSprite:setPosition(320, 0)
	self.mParentLayer:addChild(bgSprite)

	-- 灰色背景
    local tmpGraySprite = ui.newScale9Sprite("c_17.png", cc.size(620, self.mOnlyViewInfo and 510 or 450))
    tmpGraySprite:setAnchorPoint(0.5, 1)
    tmpGraySprite:setPosition(320, 527)
    bgSprite:addChild(tmpGraySprite)

	-- 显示名字和星级
	local strName = Utility.getQualityColor(self.mModel.quality, 2) .. self.mModel.name
	if (self.mZhenyuanItem ~= nil) then
		strName = TR("等级%d ", (self.mZhenyuanItem.Lv or 0)) .. strName
	end
	Figure.newNameAndStar({
		parent = bgSprite,
		position = cc.p(320, 1120),
		nameText = strName,
		starCount = Utility.getQualityColorLv(self.mModel.quality),
	})

	-- 创建滑动列表
	self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(640, self.mOnlyViewInfo and 495 or 435))
    self.mListView:setItemsMargin(6)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(320, 520)
    bgSprite:addChild(self.mListView)

    -- 显示真元详情
	self:createBaseInfo()
	self:createIntro()
	-- 判断是否显示天命属性（只有天命真元才有）
	local zhenyuanType = ZhenyuanModel.items[self.mModelId] and ZhenyuanModel.items[self.mModelId].type or 0
	if zhenyuanType >= 7 and zhenyuanType <= 9 and self.mZhenyuanItem and self.mZhenyuanItem.TalId and self.mZhenyuanItem.TalId > 0 then 
		self:createTianMingAtrrInfo()
	end 

	-- 创建操作按钮
	self:createOptBtn()
	
	-- 获取途径
	local btnGetWay = ui.newButton({
		normalImage = "tb_34.png",
		clickAction = function()
			LayerManager.addLayer({name = "zhenyuan.ZhenYuanTabLayer", data = {}})
		end
	})
	btnGetWay:setPosition(580, 610)
	self.mParentLayer:addChild(btnGetWay)
	
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

--基本属性
function ZhenyuanInfoLayer:createBaseInfo()
	-- 基本属性
	local baseSize = cc.size(600, 140)
	local baseAttrSprite = self:createAtrrBg(TR("基础属性"), baseSize)
	self.mListView:pushBackCustomItem(baseAttrSprite)
	
	-- 构造显示属性
	local nLv = 0
	if (self.mZhenyuanItem ~= nil) then
		nLv = self.mZhenyuanItem.Lv or 0
	end
	local showAttrList = {
		{name = TR("等级"), value = nLv},
		{name = TR("资质"), value = self.mModel.quality},
	}
	local attrList = ConfigFunc:getZhenyuanLvAttr(self.mModelId, nLv)
	for _,v in ipairs(attrList) do
		table.insert(showAttrList, {name = FightattrName[v.fightattr], value = v.value})
	end
	
	-- 显示属性
	for i,v in ipairs(showAttrList) do
		-- 判断锚点 高度
		local posY = math.ceil(i/2)
		local mark = i%2 
		mark = mark ~= 0 and 0 or 1
		
		-- 文字
		local label = ui.newLabel({
			text = string.format("%s: %s%s", v.name, Enums.Color.eNormalGreenH, v.value),
			color = cc.c3b(0x46, 0x22, 0x0d),
		}) 
		label:setAnchorPoint(cc.p(0,1))
		label:setPosition(cc.p(300 * mark + 50, 80 - (posY - 1) * 35 ))
		baseAttrSprite:addChild(label)
	end
end

-- 创建内功简介
function ZhenyuanInfoLayer:createIntro()
	local introSize = cc.size(600, 120)
	local introSprite = self:createAtrrBg(TR("真元简介"), introSize)
	self.mListView:pushBackCustomItem(introSprite)

	local introLabel = ui.newLabel({
			text = self.mModel.intro,
			color = cc.c3b(0x46, 0x22, 0x0d),
			dimensions = cc.size(540, 0)
		})
	introLabel:setPosition(introSize.width / 2 + 25, 40)
	introSprite:addChild(introLabel)
end

-- 天命属性
function ZhenyuanInfoLayer:createTianMingAtrrInfo()
	local introSize = cc.size(600, 120)
	local introSprite = self:createAtrrBg(TR("天命属性"), introSize)
	self.mListView:pushBackCustomItem(introSprite)
	dump(self.mZhenyuanItem, "self.mZhenyuanItem")
	local talId = self.mZhenyuanItem.TalId
	dump(talId, "talId")
	local introLabel = ui.newLabel({
			text = TalModel.items[talId].intro,
			color = cc.c3b(0x46, 0x22, 0x0d),
			dimensions = cc.size(540, 0)
		})
	introLabel:setPosition(introSize.width / 2 + 25, 40)
	introSprite:addChild(introLabel)
end

-- 创建每一个属性背景
function ZhenyuanInfoLayer:createAtrrBg(titleText, bgSize)
	local custom_item = ccui.Layout:create()
    custom_item:setIgnoreAnchorPointForPosition(false)
    
	local tmpBgSprite = ui.newNodeBgWithTitle(custom_item, bgSize, titleText)
	local tmpBgSize = tmpBgSprite:getContentSize()

	custom_item:setContentSize(tmpBgSize)
	custom_item:setAnchorPoint(cc.p(0.5, 0.5))
    custom_item:setPosition(cc.p(320, tmpBgSize.height/2))
    tmpBgSprite:setPosition(cc.p(320, tmpBgSize.height/2))

	return custom_item
end

-- 创建操作按钮
function ZhenyuanInfoLayer:createOptBtn()
	-- 如果知识查看信息，则不需要操作按钮
	if self.mOnlyViewInfo then
		return
	end

	local btnInfos = {
		{
	        text = TR("聚气"),
	        operateBtnTag = 1,
	        clickAction = function()
	        	LayerManager.addLayer({name = "zhenyuan.ZhenYuanLvUpLayer", data = {zhenyuanList = {self.mZhenyuanItem.Id}}})
	        end
	    },
	    {
	        text = TR("兑换"),
	        operateBtnTag = 2,
	        clickAction = function()
	        	LayerManager.addLayer({name = "zhenyuan.ZhenYuanTabLayer", data = {moduleSub = 2}})
	        end
	    },
	    {
	        text = TR("更换"),
	        operateBtnTag = 3,
	        clickAction = function()
	        	LayerManager.addLayer({name = "team.TeamSelectZhenyuanLayer", data = {slotId = self.findSlotIdx, currZhenyuanIndex = self.findZhenyuanIdx,}})
	        end
	    }
	}
	
	--
	local btnStartPosX = 320 - (#btnInfos - 1) / 2 * 160
    for index, item in ipairs(btnInfos) do
        item.normalImage = "c_28.png"
        item.position = cc.p(btnStartPosX + (index - 1) * 160, 40)
        
        local tempBtn = ui.newButton(item)
        local btnSize = tempBtn:getContentSize()
        self.mParentLayer:addChild(tempBtn)

        -- 更换按钮需要显示小红点
        if (item.operateBtnTag == 3) then 
        	local isShowReddot = false
        	local onekeyData = SlotPrefObj:getOneKeyReplaceZhenyuan(self.findSlotIdx)
			if (onekeyData ~= nil) then
        		local tmpData = onekeyData[self.findZhenyuanIdx] or {}
        		isShowReddot = Utility.isEntityId(tmpData.Id)
        	end
        	if (isShowReddot == true) then
        		local redSprite = ui.createBubble({position = cc.p(btnSize.width * 0.8, btnSize.height * 0.8)})
        		tempBtn:addChild(redSprite)
        	end
        end
    end
end

return ZhenyuanInfoLayer