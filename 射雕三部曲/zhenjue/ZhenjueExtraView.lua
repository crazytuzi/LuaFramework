--[[
	文件名:ZhenjueExtraView.lua
	描述：内功心法洗炼view，作为控件的形势存在, 该控件自生不会做适配
	创建人: peiyaoqiang
	创建时间: 2017.04.05
--]]

local ZhenjueExtraView = class("ZhenjueExtraView", function(params)
    return display.newLayer()
end)

-- 模块类型的消息通知常量
local ExtraEventName = {
	eUseTypeChange = "eZhenjueExtraUseTypeChange",   -- 内功心法洗炼类型改变
	eExtraCountChange = "eZhenjueExtraCountChange",  -- 内功心法洗炼次数改变
	eUpAttrDataChange = "eZhenjueExtraUpAttrDataChange", -- 内功心法洗炼属性改变
	eTempUpAttrDataChange = "eZhenjueExtraTempUpAttrDataChange", -- 洗炼临时属性改变
	eTempUpTotalAttrDataChange = "eZhenjueExtraTempUpTotalAttrDataChange", -- 洗炼临时总属性改变
	eOptBtnStatusChange = "eZhenjueExtraOptBtnStatusChange", -- 操作按钮状态改变
}

-- 属性对应图片
local picConfig = {
	[Fightattr.eHPADD] = { -- 生命
		dsPic = "ng_07.png",  --静态图片(红色)
		color = cc.c3b(0xff, 0xbd, 0xbd),  --祯颜色
		aniName = "hong"
	},
	[Fightattr.eHP] = { -- 生命
		dsPic = "ng_07.png",  --静态图片(红色)
		color = cc.c3b(0xff, 0xbd, 0xbd),  --祯颜色
		aniName = "hong"
	},
	[Fightattr.eAPADD] = {  -- 攻击
		dsPic = "ng_14.png", -- 绿色
		color = cc.c3b(0x9e, 0xff, 0xcb),
		aniName = "lvse"
	},
	[Fightattr.eAP] = {  -- 攻击
		dsPic = "ng_14.png", -- 绿色
		color = cc.c3b(0x9e, 0xff, 0xcb),
		aniName = "lvse"
	},
	[Fightattr.eDEFADD] = {  --物防
		dsPic = "ng_05.png", -- 蓝色
		color = cc.c3b(0xb1, 0xe8, 0xff),
		aniName = "lan"
	},
	[Fightattr.eDEF] = {  --物防
		dsPic = "ng_05.png", -- 蓝色
		color = cc.c3b(0xb1, 0xe8, 0xff),
		aniName = "lan"
	},
	[Fightattr.eDOD] = {  -- 闪避
		dsPic = "ng_16.png",  --紫色
		color = cc.c3b(0xe5, 0xc7, 0xff),
		aniName = "zise"
	},
	[Fightattr.eBLO] = {  -- 格挡
		dsPic = "ng_03.png", --咖啡色
		color = cc.c3b(0xff, 0xf9, 0xc7),
		aniName = "cheng"
	},
	[Fightattr.eHIT] = {  -- 命中
		dsPic = "ng_07.png", --玫红色
		color = cc.c3b(0xff, 0xbd, 0xbd),  --祯颜色
		aniName = "hong"
	},
	[Fightattr.eBOG] = {  -- 击破
		dsPic = "ng_03.png", --咖啡色
		color = cc.c3b(0xff, 0xf9, 0xc7),
		aniName = "cheng"
	},
	[Fightattr.eCRI] = {  -- 暴击
		dsPic = "ng_03.png", --橙色
		color = cc.c3b(0xff, 0xf9, 0xc7),
		aniName = "cheng"
	},
	[Fightattr.eTEN] = {  -- 抗暴
		dsPic = "ng_16.png", --紫色
		color = cc.c3b(0xe5, 0xc7, 0xff),
		aniName = "zise"
	},
}

--[[
-- 参数 params 中各项为：
	{
		zhenjueItem: 内功心法实体对象
		viewSize:显示大小

		useType: 洗炼消耗类型
		extraCount: 洗炼次数类型
	}
]]
function ZhenjueExtraView:ctor(params)
	-- 整理页面数据
	params = params or {}
	-- view显示大小
	self.mViewSize = params.viewSize or cc.size(640, 610)
	-- 洗炼信息背景的大小
	self.mBgSize = cc.size(640, 395)

	-- 洗炼消耗类型
	self.mUseType = params.useType or 1
	-- 洗炼次数类型
	self.mExtraCount = params.extraCount or 1
	-- 要锁定的属性
	self.mLockedAttr = {}
	self.mLockedNode = {}
	-- 洗炼进度
	self.mProgressList = {}
	-- 查找玩家当前洗炼最大值的配置记录
	local playerLv = PlayerAttrObj:getPlayerAttrByName("Lv")
	self.mUpMaxItem = nil
	for key, item in pairs(ZhenjueUpmaxLvRelation.items) do
		if not self.mUpMaxItem or key <= playerLv and self.mUpMaxItem.playerLv < item.playerLv then
			self.mUpMaxItem = item
		end
	end

	self:setContentSize(self.mViewSize)
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setIgnoreAnchorPointForPosition(false)

	-- 初始化页面控件
	self:initUI()

	-- 初始化内功心法对象
	if Utility.isEntityId(params.zhenjueItem and params.zhenjueItem.Id) then
		self:changeZhenjue(params.zhenjueItem)
	end
end

-- 初始化页面控件
function ZhenjueExtraView:initUI()
	-- 面板背景
	self.mBgSprite = ui.newScale9Sprite("c_19.png", self.mBgSize)
	self.mBgSprite:setAnchorPoint(cc.p(0.5, 0))
	self.mBgSprite:setPosition(self.mViewSize.width / 2, 0)
	self:addChild(self.mBgSprite)

	-- 创建内功心法的星级、名字、类型等基本信息
	self:createBaseInfo()
	-- 创建操作按钮
	self:createOptBtn()
	-- 创建洗炼类型次数信息
	self:createExtraInfo()
	-- 创建内功心法的洗炼属性信息
	self:createZhenjueInfo()
end

-- 获取恢复该页面的参数
function ZhenjueExtraView:getRestoreData()
	local retData = {}
	retData.useType = self.mUseType
	retData.extraCount = self.mExtraCount
	retData.viewSize = self.mViewSize
	retData.zhenjueItem = self.mZhenjueItem

	return retData
end

----------------------------------------------------------------------------------------------------

-- 创建内功心法的星级、名字、类型等基本信息
function ZhenjueExtraView:createBaseInfo()
	self.mNameBgSprite = ui.newScale9Sprite("c_25.png", cc.size(550, 55))
	self.mNameBgSprite:setPosition(self.mBgSize.width / 2, self.mBgSize.height - 55)
	self.mBgSprite:addChild(self.mNameBgSprite)
	
	-- 内功心法的星数
	local starNode = ui.newStarLevel(0)
	starNode:setAnchorPoint(cc.p(0, 0.5))
	self.mNameBgSprite:addChild(starNode)

	-- 显示内功心法名称和类型的label
	local nameLabel = self:createLabel("", nil, cc.p(0, 0.5), nil, cc.c3b(0x6b, 0x48, 0x2b))
	self.mNameBgSprite:addChild(nameLabel)

	-- 刷新星级和名字
	local nameBgSize = self.mNameBgSprite:getContentSize()
	self.mNameBgSprite.refresh = function()
		if not self.mZhenjueItem or not Utility.isEntityId(self.mZhenjueItem.Id) then
			starNode.setStarLevel(0)
			nameLabel:setString(TR("没有内功心法信息"))
		else
			local tempViewInfo = Utility.getZhenjueViewInfo(self.mZhenjueModel.typeID)
			local tempColorH = Utility.getColorValue(self.mZhenjueModel.colorLV, 2)
			local strName = string.format("%s[%s]%s", tempColorH, tempViewInfo.typeName, self.mZhenjueModel.name)
			local nStep = self.mZhenjueItem.Step or 0
			if (nStep > 0) then
				strName = strName .. "+" .. nStep
			end
			starNode.setStarLevel(self.mZhenjueModel.colorLV)
			nameLabel:setString(strName)
		end

		local starWidth = starNode:getContentSize().width
		local nameWidth = nameLabel:getContentSize().width
		local startPosx = (nameBgSize.width - starWidth - nameWidth - 10) / 2
		starNode:setPosition(startPosx, nameBgSize.height / 2)
		nameLabel:setPosition(startPosx + starWidth + 10, nameBgSize.height / 2)
	end
end

-- 创建操作按钮
function ZhenjueExtraView:createOptBtn()
	-- 创建洗炼次数选择
	self.mSelectCountBtn = ui.newButton({
		normalImage = "ng_08.png",
		text = TR("洗炼%d次", self.mExtraCount),
		clickAction = function()
			self:createSelectCountNode()
		end
	})
	self.mSelectCountBtn:setPosition(110, 55)
	self.mBgSprite:addChild(self.mSelectCountBtn)

	-- 添加箭头
	local btnSize = self.mSelectCountBtn:getContentSize()
	local function addBtnArrow(img, xPos)
		local sprite = self:createSprite(img, cc.p(xPos, 0))
		self.mSelectCountBtn:getExtendNode2():addChild(sprite)
	end
	addBtnArrow("ng_09.png", 20 - btnSize.width * 0.5)
	addBtnArrow("ng_10.png", btnSize.width * 0.5 - 20)

	-- 创建洗炼按钮
	local extraBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("洗炼"),
		clickAction = function()
			-- 判断资源是否足够
			local keyName = "upAttrUse" .. tostring(self.mUseType)
			local tempList = Utility.analysisStrResList(ZhenjueConfig.items[1][keyName])
			for _, useItem in pairs(tempList) do
				local needCount = useItem.num * self.mExtraCount
				if Utility.isPlayerAttr(useItem.resourceTypeSub) then  -- 玩家属性（元宝、铜币）
					if not Utility.isResourceEnough(useItem.resourceTypeSub, needCount, true) then
						return
					end
				else
					local tempCount = Utility.getOwnedGoodsCount(useItem.resourceTypeSub, useItem.modelId)
					if tempCount < needCount then
						local hintStr
						local tempName = Utility.getGoodsName(useItem.resourceTypeSub, useItem.modelId)
						if (useItem.modelId == 16050046) then -- 重洗令
							hintStr = TR("%s不足,重生内功心法可获得%s，是否前往？", tempName, tempName)
						else
							hintStr = TR("%s不足,可以在镇守襄阳中获得，是否前往？", tempName, tempName)
						end
						local okBtnInfo = {
							text = TR("前往"),
							clickAction = function(layerObj, btnObj)
								if (useItem.modelId == 16050046) then -- 重洗令
									LayerManager.showSubModule(ModuleSub.eDisassemble, {currTag = Enums.DisassemblePageType.eRebirth})
								else
									LayerManager.showSubModule(ModuleSub.eTeambattle)
								end
							end
						}
						MsgBoxLayer.addOKCancelLayer(hintStr, TR("提示"), okBtnInfo)
						return
					end
				end
			end

			-- 判断属性是否已满
			if self:isAllAttFull() then
				ui.showFlashView(TR("已达到洗炼上限，进阶内功心法可提升洗炼上限"))
				return
			end

			-- 获取阵决洗炼信息的数据请求
			self:requestExtra()
		end
	})
	extraBtn:setPosition(self.mBgSize.width / 2, 55)
	self.mBgSprite:addChild(extraBtn)

	-- 保存
	local saveBtn = ui.newButton({
		normalImage = "c_33.png",
		text = TR("替换"),
		clickAction = function()
			if not next(self.mZhenjueItem.TempUpAttrData) then
				ui.showFlashView(TR("请先进行洗炼!"))
				return
			end
			self:requestSave()
		end
	})
	saveBtn:setPosition(self.mBgSize.width * 0.8, 55)
	self.mBgSprite:addChild(saveBtn)

	-- 不能洗炼的时的提示信息
	local hintLabel = ui.newLabel({text = TR("蓝色及其以上的内功心法才能进行洗炼"), color = Enums.Color.eRed})
	hintLabel:setPosition(self.mBgSize.width / 2, 55)
	self.mBgSprite:addChild(hintLabel)

	-- 注册操作按钮状态改变的事件
	local function onOptBtnStatusChange()
		local allowExtra = self.mZhenjueModel and self.mZhenjueModel.upOddsClass > 0
		local haveTempUpAttr = self.mZhenjueItem and next(self.mZhenjueItem.TempUpAttrData or {}) ~= nil
		local allPlus, allNegative  = haveTempUpAttr, haveTempUpAttr
		for _, value in pairs(self.mZhenjueItem and self.mZhenjueItem.TempUpAttrData or {}) do  -- 检查是否全大于0或全小于0
			if value > 0 then
				allNegative = false
			elseif value < 0 then
				allPlus = false
			end
		end

		self.mSelectCountBtn:setVisible(allowExtra)
		extraBtn:setVisible(allowExtra and not (allPlus and not allNegative))
		saveBtn:setVisible(allowExtra and haveTempUpAttr and not allNegative)
		hintLabel:setVisible(not allowExtra)
	end
	Notification:registerAutoObserver(hintLabel, onOptBtnStatusChange, {ExtraEventName.eUpAttrDataChange, ExtraEventName.eTempUpAttrDataChange, ExtraEventName.eOptBtnStatusChange})
	onOptBtnStatusChange()
end

-- 创建洗炼类型次数信息
function ZhenjueExtraView:createExtraInfo()
	local extraBgSize = cc.size(610, 220)
	local BgSprite = ui.newScale9Sprite("c_17.png", cc.size(620, 230))
	BgSprite:setPosition(self.mBgSize.width / 2, self.mBgSize.height - 195)
	self.mBgSprite:addChild(BgSprite)

	local extraBgSprite = ui.newScale9Sprite("c_18.png", extraBgSize)
	extraBgSprite:setPosition(self.mBgSize.width / 2, self.mBgSize.height - 195)
	self.mBgSprite:addChild(extraBgSprite)

	-- 显示玩家拥有的材料数量
	local xPosList = {5, 235, 435}
	for key, modelId in ipairs({16050034, 16050046, 16050345}) do  -- 洗炼石, 重洗令
		local tempPosX, tempPosY = xPosList[key], 186
		local tempModel = GoodsModel.items[modelId]

		-- 拥有道具数量
		local tempSprite = self:createSprite("ng_12.png", cc.p(tempPosX, tempPosY), cc.p(0, 0.5), 0.9)
		extraBgSprite:addChild(tempSprite)

		local tempLabel = self:createLabel(tempModel.name, cc.p(tempPosX + 10, tempPosY), cc.p(0, 0.5), 20, Enums.Color.eBlack)
		extraBgSprite:addChild(tempLabel)

		-- 代币数量和标识
		local daibiNode = self:createDaibiView(cc.p(tempPosX + 90, tempPosY), tempModel.typeID, modelId, GoodsObj:getCountByModelId(modelId))
		extraBgSprite:addChild(daibiNode)

		-- 注册数量改变的事件通知
		Notification:registerAutoObserver(daibiNode, function(tempNode)
	        tempNode.setNumber(GoodsObj:getCountByModelId(modelId))
	    end, EventsName.ePropRedDotPrefix .. tostring(modelId))
	end

	-- 显示洗炼消耗类型
	local yPosList = {134, 82, 30}
	for index,name in ipairs({TR("铜币洗炼"), TR("元宝洗炼"), TR("免费洗炼")}) do
		local checkBox = self:createCheckBox(cc.p(30, yPosList[index]), name, (self.mUseType == index), function ()
				self.mUseType = index
	            Notification:postNotification(ExtraEventName.eUseTypeChange)
			end)
	    extraBgSprite:addChild(checkBox)
	    -- 注册数量改变的事件通知
		Notification:registerAutoObserver(checkBox, function()
	        checkBox:setCheckState(self.mUseType == index)
	    end, ExtraEventName.eUseTypeChange)

		-- 显示消耗的父控件
		local useNode = cc.Node:create()
		useNode:setContentSize(cc.size(520, 50))
		useNode:setIgnoreAnchorPointForPosition(false)
		useNode:setAnchorPoint(cc.p(0, 0.5))
		useNode:setPosition(200, yPosList[index])
		extraBgSprite:addChild(useNode)
		
		-- 洗炼消耗改变处理函数
		local function dealUseNodeChange()
			local keyName = "upAttrUse" .. tostring(index)
			local tempList = (index == 1) and Utility.getZhenjueGoldUpAttrUse(self.mExtraCount) or Utility.analysisStrResList(ZhenjueConfig.items[1][keyName])
			table.sort(tempList, function(item1, item2)
				if item1.resourceTypeSub ~= item2.resourceTypeSub then
					return item1.resourceTypeSub > item2.resourceTypeSub
				end
				return item1.modelId > item2.modelId
			end)

		    -- 创建该类型洗炼的消耗
		    useNode:removeAllChildren()
		    for useIndex, useItem in ipairs(tempList) do
		    	local showNum = useItem.num * ((index == 1) and 1 or self.mExtraCount)
		    	local daibiNode = self:createDaibiView(cc.p((useIndex - 1) * 120, 25), useItem.resourceTypeSub, useItem.modelId, showNum, Utility.isPlayerAttr(useItem.resourceTypeSub))
		    	useNode:addChild(daibiNode)
		    end
		end
		-- 注册数量改变的事件通知
		Notification:registerAutoObserver(useNode, dealUseNodeChange, {ExtraEventName.eExtraCountChange, ExtraEventName.eUpAttrDataChange, ExtraEventName.eTempUpAttrDataChange, EventsName.eExtraNum})
		dealUseNodeChange()
	end
	
	-- 显示洗炼锁定符
	self.lockCheckbox = self:createCheckBox(cc.p(300, 30), TR("使用洗炼锁定符"), false, handler(self, self.refreshAttrLockState))
    extraBgSprite:addChild(self.lockCheckbox)
    
 	-- 需要消耗的锁定符
    self.lockDaibiNode = self:createDaibiView(cc.p(500, 30), 1605, 16050345, 0)
    self.lockDaibiNode:setVisible(false)
	extraBgSprite:addChild(self.lockDaibiNode)
end

-- 创建内功心法的洗炼属性信息
function ZhenjueExtraView:createZhenjueInfo()
	self.mZhenjueInfoNode = cc.Node:create()
	self:addChild(self.mZhenjueInfoNode)

	-- 刷新内功心法的洗炼属性
	local tempPosY = self.mBgSize.height + 80
	self.mZhenjueInfoNode.refresh = function()
		self.mZhenjueInfoNode:removeAllChildren()
		self.mLockedNode = {}
		 
		if not self.mZhenjueItem or not Utility.isEntityId(self.mZhenjueItem.Id) or not self.mUpMaxItem then
			self.mLockedAttr = {}
			return
		end
		if self.mZhenjueModel.upOddsClass == 0 then 	-- 该内功心法不支持洗炼
			self.mLockedAttr = {}
			return
		end
		-- 如果和上次的内功是同一件，则不修改锁定状态
		if (self.mOldItemId ~= nil) and (self.mOldItemId ~= self.mZhenjueItem.Id) then
			self.mLockedAttr = {}
		end

		-- 当前洗炼进度
		local retPercent = ZhenjueObj:calcPercent(self.mZhenjueItem.Id)
		local nowExtraPro = self:createLabel(TR("洗炼进度: %.1f%%", retPercent * 100), cc.p(320, 600), cc.p(0.5, 0.5), nil, Enums.Color.eBlack)
		self.mZhenjueInfoNode:addChild(nowExtraPro)

		-- 洗炼总的增减
		local isIncreaseSprite = self:createSprite("c_77.png", cc.p(450, 600), cc.p(0, 0.5))
		self.mZhenjueInfoNode:addChild(isIncreaseSprite)

		-- 注册洗炼临时记录改变的事件通知
		local function onTempUpTotalAttrChange()
			local retPercent = ZhenjueObj:calcPercent(self.mZhenjueItem.Id)
			local increasePercent = self:isTotalAttrIncrease()
			if not increasePercent then
				isIncreaseSprite:setVisible(false)
				nowExtraPro:setString(TR("洗炼进度: %.1f%%", retPercent * 100))
				return
			end
			if increasePercent >= 0 then
				nowExtraPro:setString(TR("洗炼进度: %.1f%%#9BFF6A+%.2f%%", retPercent * 100, increasePercent * 100))
			else
				nowExtraPro:setString(TR("洗炼进度: %.1f%%#FF4A46%.2f%%", retPercent * 100, increasePercent * 100))
			end
			isIncreaseSprite:setVisible(true)
			isIncreaseSprite:setTexture(increasePercent > 0 and "c_78.png" or "c_77.png")
		    isIncreaseSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(
		        cc.MoveBy:create(0.3, cc.p(0, 3)), cc.MoveBy:create(0.6, cc.p(0, -6)), cc.MoveBy:create(0.3, cc.p(0, 3))
		    )))
		end
		Notification:registerAutoObserver(isIncreaseSprite, onTempUpTotalAttrChange, ExtraEventName.eTempUpTotalAttrDataChange)
		onTempUpTotalAttrChange()

		-- 该内功心法拥有的属性
		local attrList = Utility.analysisStrAttrList(self.mZhenjueModel.initAttrStr)
		local attrCount = #attrList
		local upUnitAttrList = Utility.analysisStrAttrList(self.mZhenjueModel.upUnitAttrStr)
		local nStepTimes = ZhenjueObj:getTimesOfStep(self.mZhenjueItem)
		local spaceX = 153
		local startPosX = (self.mViewSize.width - attrCount * spaceX) / 2 + spaceX / 2
		for index, item in pairs(attrList) do
			local tempPosX = startPosX + (index - 1) * spaceX
			local extraMaxValue = math.floor(upUnitAttrList[index].value * self.mUpMaxItem.upAttrR * nStepTimes)
			local extraProg = self:createExtraBall(item, extraMaxValue, attrCount)
			extraProg:setPosition(tempPosX, tempPosY)
			extraProg.mProgressTimer:setMidpoint(cc.p(0, 1))
			self.mZhenjueInfoNode:addChild(extraProg)
		end
		self:refreshAttrLockState()
	end
end

----------------------------------------------------------------------------------------------------

-- 辅助：创建洗炼球
function ZhenjueExtraView:createExtraBall(item, extraMax, attrCount)
	local picItem = picConfig[item.fightattr] or picConfig[Fightattr.eHPADD]
	local extraProg = require("common.ProgressBar"):create({
		bgImage = "ng_15.png",
		barImage = "ng_15.png",
		currValue = 0,  -- 当前进度
		maxValue = extraMax, -- 最大值
		barType = ProgressBarType.eVertical,
		needHideBg = true,
	})
	
	-- 洗炼球特效
	local attrBgSize = extraProg:getContentSize()
	ui.newEffect({
		parent = extraProg,
		zorder = -1,
		position = cc.p(attrBgSize.width / 2, attrBgSize.height / 2 + 5),
		scale = 1.2,
		effectName = "effect_ui_xilianqiu",
		animation = picItem.aniName,
		loop = true,
	})

	-- 因progress上的进度是(最大-当前)，所以进度数值单独显示
	local curProLabel = self:createLabel(string.format("%d/%d", 0, extraMax), cc.p(attrBgSize.width*0.5, attrBgSize.height*0.5), nil, 20, cc.c3b(0x47, 0x50, 0x54))
	extraProg:addChild(curProLabel)

	-- 添加上层蒙板
	local maskSprite = self:createSprite("ng_02.png", cc.p(attrBgSize.width / 2, attrBgSize.height / 2 - 5))
	extraProg:addChild(maskSprite)

	-- 注册洗炼属性改变改变的消息
	local function onUpAttrDataChange()
		local currValue = 0
		for key, value in pairs(self.mZhenjueItem.UpAttrData) do
			if tonumber(key) == item.fightattr then
				currValue = extraMax - value
				curProLabel:setString(TR("%d/%d", value, extraMax))
				self.mProgressList[item.fightattr] = {curValue = value, maxValue = extraMax}
				break
			end
		end
		extraProg:setCurrValue(currValue, 0)
	end
	Notification:registerAutoObserver(extraProg, onUpAttrDataChange, ExtraEventName.eUpAttrDataChange)
	onUpAttrDataChange()

	-- 技能的名字
	local attrNameLabel = self:createLabel(FightattrName[item.fightattr], cc.p(attrBgSize.width / 2, attrBgSize.height / 2 - 62), nil, nil, cc.c3b(0x4e, 0x1f, 0x17))
	attrNameLabel:setColor(picItem.color)
    extraProg:addChild(attrNameLabel)

	-- 洗炼属性变化的箭头和文字
	local changeBgSprite = self:createSprite("c_77.png", cc.p(attrBgSize.width / 2, attrBgSize.height / 2 + 35), cc.p(1, 0.5))
	local changeBgSize = changeBgSprite:getContentSize()
	extraProg:addChild(changeBgSprite)

	local changeLabel = self:createLabel("", cc.p(changeBgSize.width + 5, changeBgSize.height / 2), cc.p(0, 0.5), nil, Enums.Color.eBlack)
	changeBgSprite:addChild(changeLabel)

	-- 注册洗炼临时记录改变的事件通知
	local function onTempUpAttrChange()
		local haveRecord = next(self.mZhenjueItem.TempUpAttrData) ~= nil
		changeBgSprite:setVisible(haveRecord)
		changeBgSprite:stopAllActions()

		-- 如果没有洗炼的临时记录，则直接返回
		if not haveRecord then
			return
		end

		-- 读取变化值
		local tempValue = 0
		for key, value in pairs(self.mZhenjueItem.TempUpAttrData) do
			if item.fightattr == tonumber(key) then
				tempValue = value
				break
			end
		end
		-- 显示变化值
		changeBgSprite:setVisible(tempValue ~= 0) 	-- 变化为0的时候不显示
		if (tempValue ~= 0) then
			changeBgSprite:setTexture((tempValue > 0) and "c_78.png" or "c_77.png")
			changeLabel:setString(string.format("%s%+d", (tempValue > 0) and Enums.Color.eGreenH or Enums.Color.eRedH, tempValue))

			local moveAction1 = cc.MoveBy:create(0.3, cc.p(0, 3))
		    local moveAction2 = cc.MoveBy:create(0.6, cc.p(0, -6))
		    local moveAction3 = cc.MoveBy:create(0.3, cc.p(0, 3))
		    changeBgSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(
		        moveAction1, moveAction2, moveAction3
		    )))
		end
	end
	Notification:registerAutoObserver(changeBgSprite, onTempUpAttrChange, ExtraEventName.eTempUpAttrDataChange)
	onTempUpAttrChange()

	-- 创建锁定标志
	local lockSprite = self:createSprite("c_35.png", cc.p(attrBgSize.width / 2, attrBgSize.height / 2 + 35), cc.p(0.5, 0.5))
	extraProg:addChild(lockSprite)

	-- 创建锁定选择框
	local checkbox
	checkbox = self:createCheckBox(cc.p(attrBgSize.width / 2 - 15, -20), "", false, function ()
			local newState = checkbox:getCheckState()
			lockSprite:setVisible(false)
			if (newState == true) then
				if ((#self.mLockedAttr + 1) == attrCount) then
					checkbox:setCheckState(false)
					ui.showFlashView(TR("不能同时锁定全部的属性"))
					return
				end
				local needNum = self:getNeedLockGoodNum(#self.mLockedAttr + 1)
				local owndNum = GoodsObj:getCountByModelId(16050345)
				if (owndNum < needNum) then
					checkbox:setCheckState(false)
					ui.showFlashView(TR("您的锁定符数量不够用啦"))
					return
				end

				table.insert(self.mLockedAttr, item.fightattr)
				lockSprite:setVisible(true)
			else
				for i,v in ipairs(self.mLockedAttr) do
					if (v == item.fightattr) then
						table.remove(self.mLockedAttr, i)
					end
				end
			end
			self.lockDaibiNode.setNumber(self:getNeedLockGoodNum(#self.mLockedAttr))
		end)
    extraProg:addChild(checkbox)

    -- 保存起来
	table.insert(self.mLockedNode, {attrKey = item.fightattr, lockSprite = lockSprite, ballCheckbox = checkbox})

	return extraProg
end

-- 辅助：洗炼次数选择弹出按钮
function ZhenjueExtraView:createSelectCountNode()
    local tempLayer = cc.Layer:create()
    display.getRunningScene():addChild(tempLayer, Enums.ZOrderType.ePopLayer)

    -- 组册触摸事件
	ui.registerSwallowTouch({
		node = tempLayer,
		allowTouch = true,
		beganEvent = function(touch, event)
	    	return true
	    end,
	    endedEvent = function(touch, event)
	    	tempLayer:removeFromParent()
	    end,
	})

    -- 创建一键选择筛选条件按钮
    local btnInfos= {{text = TR("洗炼1次"), selCount = 1}}
	-- "阵决洗炼十次"
	if ModuleInfoObj:moduleIsOpen(ModuleSub.eZhenjueTenExtra, false) then
		table.insert(btnInfos, {text = TR("洗炼10次"), selCount = 10})
	end
	-- "阵决洗炼二十次"
	if ModuleInfoObj:moduleIsOpen(ModuleSub.eZhenjueTwentyExtra, false) then
		table.insert(btnInfos, {text = TR("洗炼20次"), selCount = 20})
	end

	local startPos = self.mSelectCountBtn:getParent():convertToWorldSpace(cc.p(self.mSelectCountBtn:getPosition()))
    for index, item in ipairs(btnInfos) do
        item.normalImage = "ng_11.png"
        item.size = cc.size(130, 40)
        item.clickAction = function()
        	self.mExtraCount = item.selCount
        	self.mSelectCountBtn:setTitleText(item.text)
        	self:refreshAttrLockState()
        	Notification:postNotification(ExtraEventName.eExtraCountChange)
        	tempLayer:removeFromParent()
        end
        local tempBtn = ui.newButton(item)
        tempBtn:setScale(Adapter.MinScale)
        tempBtn:setPosition(startPos.x, startPos.y + 40 * index * Adapter.MinScale)
        tempLayer:addChild(tempBtn)
    end
end

-- 辅助：创建复选框
function ZhenjueExtraView:createCheckBox(pos, name, defaultCheck, callFunc)
	local checkBox = ui.newCheckbox({
        normalImage = "c_60.png",
        selectImage = "c_61.png",
        isRevert = false, -- 是否把文字放到复选框前面，默认false
        text = name,
        textColor = Enums.Color.eBrown,
        callback = callFunc,
    })
    checkBox:setCheckState(defaultCheck)
    checkBox:setAnchorPoint(cc.p(0, 0.5))
    checkBox:setPosition(pos)
    return checkBox
end

-- 辅助：创建代币
function ZhenjueExtraView:createDaibiView(pos, resType, resModelId, resNum, showOwned)
	local daibiNode = ui.createDaibiView({
		resourceTypeSub = resType,
        goodsModelId = resModelId,
        number = resNum,
        fontColor = cc.c3b(0x45, 0x27, 0x06),
        showOwned = showOwned,
	})
	daibiNode:setAnchorPoint(cc.p(0, 0.5))
	daibiNode:setPosition(pos)
	return daibiNode
end

-- 辅助：创建图片
function ZhenjueExtraView:createSprite(image, pos, anchor, scale)
	local tempSprite = ui.newSprite(image)
	if anchor then
		tempSprite:setAnchorPoint(anchor)
	end
	tempSprite:setPosition(pos)
	if scale then
		tempSprite:setScale(scale)
	end
	return tempSprite
end

-- 辅助：创建Label
function ZhenjueExtraView:createLabel(text, pos, anchor, size, outlineColor)
	local tempLabel = ui.newLabel({text = text, size = size, outlineColor = outlineColor})
	if anchor then
		tempLabel:setAnchorPoint(anchor)
	end
	if pos then
		tempLabel:setPosition(pos)
	end
	return tempLabel
end

----------------------------------------------------------------------------------------------------

-- 判断是否所有属性已满
function ZhenjueExtraView:isAllAttFull()
	for _,v in pairs(self.mProgressList) do
		if (v.curValue < v.maxValue) then
			return false
		end
	end
	return true
end

-- 改变内功心法对象
function ZhenjueExtraView:changeZhenjue(zhenjueItem)
	-- 内功心法对象
	self.mZhenjueItem = zhenjueItem
	-- 内功心法模型
	self.mZhenjueModel = ZhenjueModel.items[self.mZhenjueItem.ModelId]

	-- 刷新内功心法的名称等信息
	if self.mNameBgSprite then
		self.mNameBgSprite.refresh()
	end

	-- 刷新内功心法的洗炼属性
	if self.mZhenjueInfoNode then
		self.mZhenjueInfoNode.refresh()
	end

	-- 通知操作按钮状态改变
    Notification:postNotification(ExtraEventName.eOptBtnStatusChange)
end

-- 判断总体洗炼进度是否增加
function ZhenjueExtraView:isTotalAttrIncrease()
	-- 是否洗炼
	local haveRecord = next(self.mZhenjueItem.TempUpAttrData) ~= nil
	if not haveRecord then return false end
	-- 阵决model数据
	if not self.mZhenjueModel then return false end
	if not self.mUpMaxItem then return false end
	-- 计算百分比
	local tmpPercent, tmpCount = 0, 0
	local attrList = Utility.analysisStrAttrList(self.mZhenjueModel.initAttrStr)
    local upUnitAttrList = Utility.analysisStrAttrList(self.mZhenjueModel.upUnitAttrStr)
    for index, item in pairs(attrList) do
    	local zhenjueInfo = ZhenjueObj:getZhenjue(self.mZhenjueItem.Id)
    	local tmpMaxValue = math.floor(upUnitAttrList[index].value * self.mUpMaxItem.upAttrR * ZhenjueObj:getTimesOfStep(zhenjueInfo))
        local tmpCurValue = 0
        for key, value in pairs(self.mZhenjueItem.TempUpAttrData) do
            if tonumber(key) == item.fightattr then
                tmpCurValue = value
                break
            end
        end
        tmpCount = tmpCount + 1
        tmpPercent = tmpPercent + (tmpCurValue/tmpMaxValue)
    end

    return tmpPercent/tmpCount
end

-- 计算需要的锁定符数量
function ZhenjueExtraView:getNeedLockGoodNum(attrNum)
	return attrNum * self.mExtraCount
end

-- 刷新属性的锁定状态
function ZhenjueExtraView:refreshAttrLockState()
	local nowState = self.lockCheckbox:getCheckState()
	for _,v in ipairs(self.mLockedNode) do
		v.lockSprite:setVisible(false)
		v.ballCheckbox:setVisible(nowState)
	end
	self.lockDaibiNode:setVisible(nowState)

	-- 初始化选中状态
	if (nowState == false) then
		self.mLockedAttr = {}
		return
	end

	-- 判断锁定符数量是否足够
	local needNum = self:getNeedLockGoodNum(#self.mLockedAttr)
	local owndNum = GoodsObj:getCountByModelId(16050345)
	if (owndNum < needNum) then
		-- 重新初始化
		self.mLockedAttr = {}
		self.lockDaibiNode.setNumber(0)
		for _,v in ipairs(self.mLockedNode) do
			v.ballCheckbox:setCheckState(false)
		end
		ui.showFlashView(TR("您的锁定符数量不够用啦"))
		return
	end
	
	local function isAttrLocked(attrKey)
		for _,v in ipairs(self.mLockedAttr) do
			if (v == attrKey) then
				return true
			end
		end
		return false
	end
	for _,v in ipairs(self.mLockedNode) do
		local islocked = isAttrLocked(v.attrKey)
		v.ballCheckbox:setCheckState(islocked)
		v.lockSprite:setVisible(islocked)
	end
	self.lockDaibiNode.setNumber(needNum)
end

----------------------------------------------------------------------------------------------------

-- ===================== 服务器数据请求相关接口请求相关 ==========================
-- 洗炼内功心法的数据请求
function ZhenjueExtraView:requestExtra()
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "ZhenjueExtra",
        methodName = "Extra",
        svrMethodData = {self.mZhenjueItem.Id, self.mUseType, self.mExtraCount, self.mLockedAttr},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
            	return
            end

            -- 把最新的内功心法信息保存到缓存中去
            self.mOldItemId = self.mZhenjueItem.Id
            self.mZhenjueItem = clone(response.Value.Zhenjue)
            ZhenjueObj:modifyZhenjueItem(self.mZhenjueItem)

            -- 修改缓存中的阵决洗炼铜币次数
            PlayerAttrObj:changeAttr({ExtraNum = response.Value.ExtraNum})

            -- 通知洗炼信息改变
            Notification:postNotification(ExtraEventName.eTempUpAttrDataChange)
            Notification:postNotification(ExtraEventName.eTempUpTotalAttrDataChange)

            -- 刷新洗炼锁定符的数量
            Notification:postNotification(EventsName.ePropRedDotPrefix .. "16050345")
        end,
    })
end

-- 保存洗炼信息的数据请求
function ZhenjueExtraView:requestSave()
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "ZhenjueExtra",
        methodName = "Save",
        svrMethodData = {self.mZhenjueItem.Id},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
            	return
            end

            -- 把最新的内功心法信息保存到缓存中去
            self.mOldItemId = self.mZhenjueItem.Id
            self.mZhenjueItem = clone(response.Value.Zhenjue)
            ZhenjueObj:modifyZhenjueItem(self.mZhenjueItem)

            -- 通知洗炼信息改变
            Notification:postNotification(ExtraEventName.eTempUpAttrDataChange)
            Notification:postNotification(ExtraEventName.eTempUpTotalAttrDataChange)
            Notification:postNotification(ExtraEventName.eUpAttrDataChange)
        end,
    })
end

return ZhenjueExtraView