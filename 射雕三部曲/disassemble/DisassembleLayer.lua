--[[
	文件名：DisassembleLayer.lua
	描述：炼化功能界面的显示
	创建人：yanxingrui
	创建时间： 2016.4.19
--]]

local DisassembleLayer = class("DisassembleLayer", function (params)
	return display.newLayer()
end)

--[[
	table params:
	{
		currTag: 当前选择页面，默认为分解页面
		--
		refine = {data , type}:	返回页面时的分解数据
		rebirth = {data , type}:返回页面时的重生数据
		compare = {data , type}:返回页面时的涅槃数据
		conversion = {data , type}:返回页面时的转化数据
	}

]]
function DisassembleLayer:ctor(params)
	-- 当前选择页签按钮的Tag
	self.mCurrTabTag = params.currTag or Enums.DisassemblePageType.eRefine

	-- 子页面的parent
	self.mSubParentLayer = ui.newStdLayer()
	self:addChild(self.mSubParentLayer)
	-- 该页面的Parent
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self.mRefineData = params and params.refine
	self.mRebirthData = params and params.rebirth
	self.mCompareData = params and params.compare
	self.mConversionData = params and params.conversion

	self.mTabBtnInfos = {}

	--判断服务器是不是开启分解重生
    if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eDisassemble, false) and
        ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eDisassemble) then
        table.insert(self.mTabBtnInfos,{
            text = TR("分解"),
    		tag = Enums.DisassemblePageType.eRefine,
    		pageNodeObj = nil, -- 页面对象
    		pageName = "refine", -- 页面名称
    		pageData = params.refine,
            moduleId = Enums.ClientRedDot.eDisassemble, -- (装备和内功)
        })

        table.insert(self.mTabBtnInfos,{
            text = TR("重生"),
    		tag = Enums.DisassemblePageType.eRebirth,
    		pageNodeObj = nil, -- 页面对象
    		pageName = "rebirth",
    		pageData = params.rebirth,
        })
    end

	--判断服务器是不是开启涅槃
    if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.ePetCompare, false) and
        ModuleInfoObj:moduleIsOpenInServer(ModuleSub.ePetCompare) then
        table.insert(self.mTabBtnInfos,{
            text = TR("外功合成"),
    		tag = Enums.DisassemblePageType.eCompare,
    		pageNodeObj = nil, -- 页面对象
    		pageName = "compare", -- 页面名称
    		pageData = params.compare,
            moduleId = ModuleSub.ePetCompare, 
        })
    end

    --判断服务器是不是开启大侠转化
    if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eHeroConversion, false) and
        ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eHeroConversion) then
        table.insert(self.mTabBtnInfos,{
            text = TR("转化"),
    		tag = Enums.DisassemblePageType.eConversion,
    		pageNodeObj = nil, -- 页面对象
    		pageName = "conversion", -- 页面名称
    		pageData = params.mConversionData,
            moduleId = ModuleSub.eHeroConversion, 
        })
    end

	-- 初始化界面
    self:initUI()

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
    	normalImage = "c_29.png",
    	clickAction = function (pSender)
    		LayerManager.removeLayer(self)
    	end
    })
    self.mCloseBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
    self.mParentLayer:addChild(self.mCloseBtn)
end

-- 初始化页面控件
function DisassembleLayer:initUI()
	-- 子背景
    -- local subBgSprite = ui.newScale9Sprite("c_124.png", cc.size(640, 142))
    -- subBgSprite:setAnchorPoint(cc.p(0.5, 1))
    -- subBgSprite:setPosition(cc.p(self.mParentLayer:getContentSize().width * 0.5, self.mParentLayer:getContentSize().height))
    -- self.mParentLayer:addChild(subBgSprite)
    -- 添加黑底
    local decBgSize = cc.size(640, 97)
    local decBg = ui.newScale9Sprite("c_73.png", decBgSize)
    decBg:setPosition(cc.p(320, 1040))
    self.mParentLayer:addChild(decBg)

    --创建分页
    local tempTabLayer = ui.newTabLayer({
		btnInfos = self.mTabBtnInfos,
		defaultSelectTag = self.mCurrTabTag,
		onSelectChange = function (selectBtnTag)
			if selectBtnTag == self.mCurrTabTag then
				return
			end
			self.mCurrTabTag = selectBtnTag
            self:changePage()
        end,
	})
	tempTabLayer:setPosition(Enums.StardardRootPos.eTabView)
	self.mParentLayer:addChild(tempTabLayer)
	self:changePage()

    for i,info in ipairs(self.mTabBtnInfos) do
        if info.moduleId then
            -- 添加分解小红点
            local refineBtn = tempTabLayer:getTabBtnByTag(info.tag)
            local function dealRedDotVisible(redDotSprite)
                redDotSprite:setVisible(RedDotInfoObj:isValid(info.moduleId))
            end
            ui.createAutoBubble({parent = refineBtn, eventName = RedDotInfoObj:getEvents(info.moduleId),
                refreshFunc = dealRedDotVisible})
        end
    end
end

-- 获取恢复该页面数据
function DisassembleLayer:getRestoreData()
	local retData = {}

	retData.currTag = self.mCurrTabTag
	for _, item in ipairs(self.mTabBtnInfos) do
		if item.pageNodeObj then
			if item.pageNodeObj.getRestoreData then
				retData[item.pageName] = item.pageNodeObj:getRestoreData()
				--self.mRefineData = item.pageNodeObj:getRestoreData()
				--retData = item.pageNodeObj:getRestoreData()
			end
		end
	end
	return retData
end

-- 选择不同的分页
function DisassembleLayer:changePage()
	if self.topResource then
		self.topResource:removeFromParent()
	end
	local topinfos = {}
	if self.mCurrTabTag == Enums.DisassemblePageType.eRefine then
		topinfos = {ResourcetypeSub.eHeroExp, ResourcetypeSub.eHeroCoin,
			ResourcetypeSub.eDiamond, ResourcetypeSub.eGold}
	elseif self.mCurrTabTag == Enums.DisassemblePageType.eRebirth then
		topinfos = {ResourcetypeSub.eHeroExp, ResourcetypeSub.eHeroCoin,
			ResourcetypeSub.eDiamond, ResourcetypeSub.eGold}
	elseif self.mCurrTabTag == Enums.DisassemblePageType.eCompare then
		topinfos = {ResourcetypeSub.eHeroExp, ResourcetypeSub.eHeroCoin,
			ResourcetypeSub.eDiamond, ResourcetypeSub.eGold}
	elseif self.mCurrTabTag == Enums.DisassemblePageType.eConversion then
		topinfos = {ResourcetypeSub.eHeroExp, ResourcetypeSub.eHeroCoin,
			ResourcetypeSub.eDiamond, ResourcetypeSub.eGold}
	end
	-- 创建顶部资源
    self.topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        needFAP = false,
        topInfos = topinfos
    })
    self:addChild(self.topResource)
	for index, btnInfo in ipairs(self.mTabBtnInfos) do
		local nodeObj = btnInfo.pageNodeObj
		if btnInfo.tag == self.mCurrTabTag then
			if not nodeObj then
				if self.mCurrTabTag == Enums.DisassemblePageType.eRefine then
					nodeObj = require("disassemble.RefineLayer"):create(self.mRefineData)
					self.mRefineData = nil
					btnInfo.pageNodeObj = nodeObj
				elseif self.mCurrTabTag == Enums.DisassemblePageType.eRebirth then
					nodeObj = require("disassemble.RebirthLayer"):create(self.mRebirthData)
					btnInfo.pageNodeObj = nodeObj
				elseif self.mCurrTabTag == Enums.DisassemblePageType.eCompare then
					nodeObj = require("disassemble.CompareLayer"):create(self.mCompareData)
					btnInfo.pageNodeObj = nodeObj
				elseif self.mCurrTabTag == Enums.DisassemblePageType.eConversion then
					nodeObj = require("disassemble.ConversionLayer"):create(self.mConversionData)
					btnInfo.pageNodeObj = nodeObj
				end
				self.mSubParentLayer:addChild(nodeObj)
			else
				self:refresh() -- Todo
			end

		else
			if nodeObj then
				nodeObj:setVisible(false)  -- todo
				-- 停止熔炉音效
				if btnInfo.tag == Enums.DisassemblePageType.eRefine or btnInfo.tag == Enums.DisassemblePageType.eConversion then
					MqAudio.stopEffect(nodeObj.mAudio)
				end
			end
		end
	end
end

-- 刷新页面
function DisassembleLayer:refresh()
	if self.mCurrTabTag == Enums.DisassemblePageType.eRefine then
		self.mTabBtnInfos[1].pageNodeObj:setVisible(true)
		-- 播放熔炉音效
		self.mTabBtnInfos[1].pageNodeObj.mAudio = MqAudio.playEffect("luhuo.mp3", true)
	elseif self.mCurrTabTag == Enums.DisassemblePageType.eRebirth then
		self.mTabBtnInfos[2].pageNodeObj:setVisible(true)
	elseif self.mCurrTabTag == Enums.DisassemblePageType.eCompare then
		self.mTabBtnInfos[3].pageNodeObj:setVisible(true)
	elseif self.mCurrTabTag == Enums.DisassemblePageType.eConversion then
		-- 播放熔炉音效
		self.mTabBtnInfos[4].pageNodeObj.mAudio = MqAudio.playEffect("luhuo.mp3", true)
		self.mTabBtnInfos[4].pageNodeObj:setVisible(true)
	end
end

return DisassembleLayer
