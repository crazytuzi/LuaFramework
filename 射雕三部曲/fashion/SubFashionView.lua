--[[
	文件名:SubFashionView.lua
	描述：绝学列表的子页面
	创建人：peiyaoqiang
	创建时间：2017.09.15
--]]

local SubFashionView = class("SubFashionView", function(params)
    return cc.Node:create()
end)

--[[
-- 参数 params 中各项为：
	{
		viewSize: 显示大小，必选参数
		callback: 回调接口
	}
]]
function SubFashionView:ctor(params)
	-- 读取参数
	self.viewSize = params.viewSize
	self.callback = params.callback
	self.fashionList = {}  			-- 所有时装列表
	self.selectModelId = nil
	
	-- 初始化
	self:setContentSize(self.viewSize)
	
	-- 显示界面
	self:initUI()
	self:refreshData()
	self:refreshUI()
end

-- 初始化UI
function SubFashionView:initUI()
	-- 属性背景
	local attrBgSize = cc.size(self.viewSize.width - 20, 90)
	local attrBgSprite = ui.newScale9Sprite("c_18.png", attrBgSize)
	attrBgSprite:setAnchorPoint(cc.p(0.5, 1))
	attrBgSprite:setPosition(cc.p(self.viewSize.width * 0.5, self.viewSize.height - 5))
	self:addChild(attrBgSprite)
	self.attrBgSprite = attrBgSprite
	
	-- 文字提示
	local infoLabel = ui.newLabel({
		text = TR("*绝学不分男女性别，均可使用"),
		color = cc.c3b(0xff, 0x00, 0x36),
	})
	infoLabel:setAnchorPoint(cc.p(1, 0.5))
	infoLabel:setPosition(self.viewSize.width - 15, self.viewSize.height - 115)
	self:addChild(infoLabel)

	-- 中间背景
	local centerBgSprite = ui.newSprite("zr_54.jpg")
	centerBgSprite:setAnchorPoint(cc.p(0.5, 0))
	centerBgSprite:setPosition(self.viewSize.width * 0.5, 235)
	self:addChild(centerBgSprite)
	self.centerBgSprite = centerBgSprite

	-- 属性总览按钮
	local btnAttr = ui.newButton({
		normalImage = "mp_43.png",
		clickAction = function()
			LayerManager.addLayer({name = "fashion.DlgFashionAttrLayer", cleanUp = false,})
		end
	})
	btnAttr:setPosition(60, self.viewSize.height * 0.7 + 20)
	self:addChild(btnAttr)

	-- 绝学录按钮
	local btnIllustrate = ui.newButton({
		normalImage = "tb_265.png",
		clickAction = function()
			if not ModuleInfoObj:moduleIsOpen(ModuleSub.eIllustrated, true) then
                return
            end
            LayerManager.addLayer({name = "hero.IllustrateHomeLayer", data = {defaultTab = 4}})
		end
	})
	btnIllustrate:setPosition(60, self.viewSize.height * 0.7 - 90)
	self:addChild(btnIllustrate)

	-- 重生按钮
	local btnRebirth = ui.newButton({
		normalImage = "tb_212.png",
		clickAction = function()
			local curFashionInfo = self:getSelectedFashion()

			if curFashionInfo.isDressIn then
				ui.showFlashView(TR("请先下阵该绝学"))
			elseif curFashionInfo.Step <= 0 then
				ui.showFlashView(TR("该绝学还没进阶"))
			else
				self:rebirthBox(curFashionInfo)
			end
		end
	})
	btnRebirth:setPosition(60, self.viewSize.height * 0.7 - 190)
	self:addChild(btnRebirth)
	self.mBtnRebirth = btnRebirth

	-- 列表背景
	local listBgSize = cc.size(self.viewSize.width - 20, 144)
	local listBgSprite = ui.newScale9Sprite("c_65.png", listBgSize)
	listBgSprite:setAnchorPoint(cc.p(0.5, 0))
	listBgSprite:setPosition(cc.p(self.viewSize.width * 0.5, 80))
	self:addChild(listBgSprite)

	-- 头像列表
	local mCellSize = cc.size(130, listBgSize.height)
	local mSliderView = ui.newSliderTableView({
        width = listBgSize.width - 20,
        height = listBgSize.height,
        isVertical = false,
        selItemOnMiddle = false,
        itemCountOfSlider = function(sliderView)
        	return #self.fashionList
        end,
        itemSizeOfSlider = function(sliderView)
            return mCellSize.width, mCellSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
        	local itemData = self.fashionList[index + 1]
        	local showAttrs = {CardShowAttr.eBorder}
        	if (itemData.baseInfo.ID > 0) then
        		-- 主角不显示名字和进阶
        		table.insert(showAttrs, CardShowAttr.eName)
        		table.insert(showAttrs, CardShowAttr.eNum)
        		table.insert(showAttrs, CardShowAttr.eStep)
        	end
        	if (self.selectModelId == itemData.baseInfo.ID) then
        		-- 选中框
        		table.insert(showAttrs, CardShowAttr.eSelected)
        	end
        	if (itemData.isDressIn ~= nil) and (itemData.isDressIn == true) then
        		-- 已上阵
        		table.insert(showAttrs, CardShowAttr.eBattle)
        	end
        	local tempCard = require("common.CardNode").new({
				allowClick = true,
				onClickCallback = function()
					self.selectModelId = itemData.baseInfo.ID
					self:refreshUI()
				end
			})
			tempCard:setPosition(mCellSize.width / 2, mCellSize.height / 2 + 12)
			if (itemData.baseInfo.ID == 0) then
				tempCard:setHero({ModelId = FormationObj:getSlotInfoBySlotId(1).ModelId}, showAttrs)
			else
				tempCard:setFashion({ModelId = itemData.baseInfo.ID, Num = itemData.ownNum, Step = FashionObj:getOneItemStep(itemData.baseInfo.ID)}, showAttrs)
			end
			if (itemData.isOwned == nil) or (itemData.isOwned == false) then
				local lockSprite = ui.newSprite("bsxy_14.png")
				lockSprite:setPosition(48, 48)
				tempCard:addChild(lockSprite, 2)
				tempCard.mBgSprite:setGray(true)
			end
			itemNode:addChild(tempCard)
        end,
        selectItemChanged = function(sliderView, selectIndex)
        end
    })
    mSliderView:setTouchEnabled(true)
    mSliderView:setAnchorPoint(cc.p(0.5, 0.5))
    mSliderView:setPosition(listBgSize.width / 2, listBgSize.height / 2)
    listBgSprite:addChild(mSliderView)
    self.mSliderView = mSliderView

	-- 保存按钮
	local btnSave = ui.newButton({
		normalImage = "c_28.png",
		text = TR("上阵"),
		clickAction = function()
			local currData = self:getSelectedFashion()
			if (currData.isOwned ~= nil) and (currData.isOwned == true) then
				-- 使用
				self:requestDressUp(currData.baseInfo.ID)
			else
				-- 获取
				Utility.getFashionWay(currData.baseInfo.ID)
			end
		end
	})
	btnSave:setPosition(self.viewSize.width * 0.5, 40)
	self:addChild(btnSave)
	self.btnSave = btnSave

	-- 提示文字
	local tmpLabel = ui.newLabel({
        text = TR("绝学录激活或升星时，至少会保留一件绝学用于图鉴属性激活"), 
        size = 16,
        color = cc.c3b(0x46, 0x22, 0x0d),
        dimensions = cc.size(200, 0)
        })
    tmpLabel:setAnchorPoint(cc.p(0, 0))
    tmpLabel:setPosition(cc.p(self.viewSize.width / 2 + 85, 10))
    self:addChild(tmpLabel)

	-- 进阶按钮
	local btnStep = ui.newButton({
		normalImage = "c_28.png",
		text = TR("进阶"),
		clickAction = function()
			local currData = self:getSelectedFashion()
			local function closeFunc()
				self:refreshData()
				self:refreshUI()
				if self.callback then
					self.callback()
				end
			end
			LayerManager.addLayer({name = "fashion.DlgFashionStepUpLayer", data = {item = currData, callback = closeFunc}, cleanUp = false,})
		end
	})
	btnStep:setPosition(self.viewSize.width * 0.2, 40)
	self:addChild(btnStep)
	self.btnStep = btnStep
end

function SubFashionView:rebirthBox(fashionInfo)
	local step = fashionInfo.Step
	local modelId = fashionInfo.baseInfo.ID
	local backUpUseSteps = string.splitBySep(fashionInfo.BackUpUseSteps, ",") or {}

	local tempList = {}
	for _, step in pairs(backUpUseSteps) do
		tempList[tonumber(step)] = true
	end
	backUpUseSteps = tempList

	-- 计算重生花费
	local useDiamond = FashionRebirthRelation.items[step].useDiamond
	local useResText = string.format("{%s}%d", Utility.getDaibiImage(ResourcetypeSub.eDiamond), useDiamond)
	
	-- 计算资源返还
	local stepCount = step - 1
	local getResList = {}
	while (stepCount >= 0) do
		local needResStr = ""
		if backUpUseSteps[stepCount] then
			needResStr = FashionStepRelation.items[modelId][stepCount].backUpUse
		else
		    needResStr = FashionStepRelation.items[modelId][stepCount].upUse
		end

		local needResList = Utility.analysisStrResList(needResStr)
		for _, resInfo in pairs(needResList) do
		    if getResList[resInfo.modelId] then
		        getResList[resInfo.modelId].num = getResList[resInfo.modelId].num + resInfo.num
		    else
		        getResList[resInfo.modelId] = resInfo
		    end
		end

	    stepCount = stepCount - 1
	end
	
	local function createHintBox(parent, bgSprite, bgSize)
	    -- 花费提示
	    local useLabel = ui.newLabel({
	            text = TR("是否花费%s返还以下物品?", useResText),
	            color = Enums.Color.eWhite,
	            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
	        })
	    useLabel:setAnchorPoint(0.5, 0.5)
	    useLabel:setPosition(bgSize.width*0.5, bgSize.height-90)
	    bgSprite:addChild(useLabel)
	    -- 黑背景
	    local blackBg = ui.newScale9Sprite("c_17.png", cc.size(bgSize.width-50, 150))
	    blackBg:setPosition(bgSize.width*0.5, bgSize.height*0.5)
	    bgSprite:addChild(blackBg)
	    -- 列表
	    local listView = ccui.ListView:create()
	    listView:setDirection(ccui.ScrollViewDir.horizontal)
	    -- listView:setBounceEnabled(true)
	    listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
	    listView:setAnchorPoint(cc.p(0.5, 0.5))
	    listView:setPosition(blackBg:getContentSize().width*0.5, blackBg:getContentSize().height*0.5)
	    blackBg:addChild(listView)

	    local cellSize = cc.size(100, blackBg:getContentSize().height)

	    -- 列表宽度
	    local listWidth = 0

	    -- 添加其他返还
	    for _, resInfo in pairs(getResList) do
	        local itemCell = ccui.Layout:create()
	        itemCell:setContentSize(cellSize)
	        listView:pushBackCustomItem(itemCell)

	        resInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum}
	        local resCard = CardNode.createCardNode(resInfo)
	        resCard:setPosition(cellSize.width*0.5, cellSize.height*0.55)
	        itemCell:addChild(resCard)

	        listWidth = listWidth + cellSize.width
	    end

	    -- 设置列表大小
	    local maxWidth = blackBg:getContentSize().width-10
	    listView:setContentSize(cc.size(listWidth < maxWidth and listWidth or maxWidth, cellSize.height))
	end
	
	self.rebirthBoxLayer = LayerManager.addLayer({
	    name = "commonLayer.MsgBoxLayer",
	    cleanUp = false,
	    data = {
	        notNeedBlack = true,
	        bgSize = cc.size(600, 400),
	        title = TR("重生"),
	        btnInfos = {
	            {
	                text = TR("确定"),
	                normalImage = "c_28.png",
	                clickAction = function ()
	                    self:requestRebirth(fashionInfo.Id)
	                    LayerManager.removeLayer(self.rebirthBoxLayer)
	                end,
	            },
	            {
	                text = TR("取消"),
	                normalImage = "c_28.png",
	                clickAction = function ()
	                    LayerManager.removeLayer(self.rebirthBoxLayer)
	                end,
	            },
	        },
	        DIYUiCallback = createHintBox,
	        closeBtnInfo = {}
	    }
	})
end

-- 刷新数据
function SubFashionView:refreshData()
	self.fashionList = {}

	-- 添加主角（主角有3个，需要分别单独配置）
	local playerModelId = FormationObj:getSlotInfoBySlotId(1).ModelId
	local playerInfo = HeroModel.items[playerModelId]
	local playerItem = {
		baseInfo = {
			ID = 0, 
			name = ConfigFunc:getHeroName(playerModelId), 
			NAID = playerInfo.NAID, 
			RAID = playerInfo.RAID, 
			attackIcon = "zr_64", 
			skillIcon = "zr_65", 
			actionPic = playerInfo.largePic
		},
		Step = 0,
		isOwned = FashionObj:getOneItemOwned(0),
		isDressIn = FashionObj:getOneItemDressIn(0),
		ownNum = FashionObj:getFashionCount(0)
	}
	table.insert(self.fashionList, playerItem)

	-- 添加所有时装
	for _,v in pairs(FashionModel.items) do
		local tmpV = {baseInfo = clone(v)}
		tmpV.isOwned = FashionObj:getOneItemOwned(v.ID)
		tmpV.isDressIn = FashionObj:getOneItemDressIn(v.ID)
		tmpV.ownNum = FashionObj:getFashionCount(v.ID)

		-- 添加时装的实体id和当前阶数
		local fashionInfo = FashionObj:getStepFashionInfo(v.ID)
		tmpV.Id = fashionInfo and fashionInfo.Id or nil
		tmpV.Step = fashionInfo and fashionInfo.Step or 0
		tmpV.BackUpUseSteps = fashionInfo and fashionInfo.BackUpUseSteps or ""

		table.insert(self.fashionList, tmpV)
	end
	table.sort(self.fashionList, function (a, b)
			if (a.baseInfo.ID == 0) then
				return true
			end
			if (b.baseInfo.ID == 0) then
				return false
			end
			if (a.isOwned ~= b.isOwned) then
				return (a.isOwned == true)
			end
			return a.baseInfo.ID < b.baseInfo.ID
		end)

	-- 默认选择顺序：优先选择已上阵，如果没有的话就选主角
	if (self.selectModelId == nil) then
		self.selectModelId = 0
		for _,v in ipairs(self.fashionList) do
			if (v.isDressIn) then
				self.selectModelId = v.baseInfo.ID
				break
			end
		end
	end
end

-- 刷新界面
function SubFashionView:refreshUI()
	-- 读取选中的绝学
	local currData = self:getSelectedFashion()
	
	-- 刷新列表
	self.mSliderView:reloadData()

	-- 刷新详情
	if (self.centerBgSprite.refreshNode == nil) then
		self.centerBgSprite.refreshNode = function (target, newData)
			target:removeAllChildren()
			if (newData == nil) then
				return
			end

			-- 显示名字
			local strName = newData.baseInfo.name
			local nStep = FashionObj:getOneItemStep(newData.baseInfo.ID)
			if (nStep > 0) then
				strName = strName .. "+" .. nStep
			end
			local centerBgSize = target:getContentSize()
			local nameLabel = ui.createLabelWithBg({
				bgFilename = "zr_50.png",
				labelStr = strName,
				fontSize = 24,
				color = cc.c3b(0x51, 0x18, 0x0d),
				alignType = ui.TEXT_ALIGN_CENTER
			})
			nameLabel:setPosition(centerBgSize.width * 0.5, centerBgSize.height - 30)
			target:addChild(nameLabel)

			-- 显示大图
			Figure.newHero({
	        	parent = target,
	        	figureName = newData.baseInfo.actionPic,
	    		position = cc.p(centerBgSize.width / 2, 30),
	    		scale = 0.27,
	    		async = function (figureNode)
	    		end,
	    	})

	    	-- 显示限定标志
	    	if (newData.baseInfo.pricePic ~= nil) and (newData.baseInfo.pricePic ~= "") then
	    		local flagSprite = ui.newSprite(newData.baseInfo.pricePic .. ".png")
	    		flagSprite:setPosition(centerBgSize.width / 2 - 100, 320)
	    		target:addChild(flagSprite, 1)
	    	end
	    	
	    	-- 显示技能图标
	    	local function createSkillHeader(skillId, isSkill, img, posY)
	        	local tempCard = require("common.CardNode").new({
					allowClick = true,
					onClickCallback = function()
						self:showSkillDlg(skillId, isSkill, cc.p(centerBgSize.width - 100, posY + 280))
					end
				})
				tempCard:setPosition(centerBgSize.width - 60, posY)
				tempCard:setSkillAttack({modelId = skillId, icon = img .. ".png", isSkill = isSkill}, {CardShowAttr.eBorder})
				target:addChild(tempCard)
	    	end
	    	local stepInfo = newData.baseInfo
	    	if (FashionStepRelation.items[newData.baseInfo.ID] ~= nil) then
	    		stepInfo = FashionStepRelation.items[newData.baseInfo.ID][(newData.Step or 0)]
	    	end
	    	createSkillHeader(stepInfo.NAID, false, newData.baseInfo.attackIcon, 380)
	    	createSkillHeader(stepInfo.RAID, true, newData.baseInfo.skillIcon, 280)
		end
	end
	self.centerBgSprite:refreshNode(currData)

	-- 刷新属性
	if (self.attrBgSprite.refreshNode == nil) then
		self.attrBgSprite.refreshNode = function (target, newData)
			target:removeAllChildren()
			if (newData == nil) then
				return
			end

			-- 显示属性
			local function addAttrLabel(strName, strValue, pos)
				local strText = strName
				if (strValue ~= nil) then
					strText = strName .. "#D38212+" .. strValue
				end
				local label = ui.newLabel({
			        text = strText,
			        color = cc.c3b(0x46, 0x22, 0x0d),
			        size = 22,
			    })
			    label:setAnchorPoint(cc.p(0, 0.5))
			    label:setPosition(pos)
			    target:addChild(label)
			end
			-- 读取属性
			local attrList = self:getFashionAttr(newData)
			if (attrList == nil) then
				-- 主角无属性加成
				local label = ui.newLabel({
			        text = TR("无属性加成"),
			        color = cc.c3b(0x46, 0x22, 0x0d),
			        size = 24,
			    })
			    label:setAnchorPoint(cc.p(0.5, 0.5))
			    label:setPosition(cc.p(self.viewSize.width * 0.5 - 10, 45))
			    target:addChild(label)
				return 
			end

			-- 显示时装属性
			addAttrLabel(TR("基本属性:"), nil, cc.p(0, 64))
			local posXList = {102, 224, 334, 444}
			for i,v in ipairs(attrList[1] or {}) do
				addAttrLabel(FightattrName[tonumber(v[1])], v[2], cc.p(posXList[i], 64))
			end
			addAttrLabel(TR("穿戴属性:"), nil, cc.p(0, 26))
			for i,v in ipairs(attrList[2] or {}) do
				addAttrLabel(FightattrName[tonumber(v[1])], v[2], cc.p(posXList[i], 26))
			end
		end
	end
	self.attrBgSprite:refreshNode(currData)

	-- 刷新按钮状态
	if (currData.isOwned ~= nil) and (currData.isOwned == true) then
		-- 已拥有
		self.btnSave.mTitleLabel:setString(TR("上阵"))
		self.btnStep:setEnabled(currData.baseInfo.ID > 0)
	else
		-- 未拥有
		self.btnSave.mTitleLabel:setString(TR("去获取"))
		self.btnStep:setEnabled(false)
	end
	-- 已经穿戴的禁止点击
	self.btnSave:setEnabled(not ((currData.isDressIn ~= nil) and (currData.isDressIn == true)))

	-- 显示／隐藏重生按钮(是时装且时装有实体id同时有进阶等级)
	self.mBtnRebirth:setVisible(currData.Id and currData.Step > 0)
end

----------------------------------------------------------------------------------------------------
-- 辅助接口

-- 获取当前选中的时装数据
function SubFashionView:getSelectedFashion()
	-- 读取选中的绝学
	local currData = nil
	for _,v in ipairs(self.fashionList) do
		if (self.selectModelId == v.baseInfo.ID) then
			currData = clone(v)
			break
		end
	end
	return currData
end

-- 读取某个时装的属性
function SubFashionView:getFashionAttr(itemData)
	if (itemData == nil) or (itemData.baseInfo == nil) or (itemData.baseInfo.ID == 0) then
		return nil
	end
    -- 读取配置
    local modelId = itemData.baseInfo.ID
    local modelInfo = FashionModel.items[modelId]
    
    -- 读取基础属性和穿戴属性
    local retAttrList = {}
    for _,list in ipairs({string.split(modelInfo.baseAttrStr, ","), string.split(modelInfo.dressAttrStr, ",")}) do
        local curList = {}
        for _,v in ipairs(list) do
            table.insert(curList, string.split(v, "|"))
        end
        table.insert(retAttrList, curList)
    end

    -- 把基础属性加上进阶属性
    local nStep = itemData.Step or 0
    if (nStep > 0) then
    	local stepInfo = FashionStepRelation.items[modelId][nStep]
	    local attrStepList = {}
		for _,v in ipairs(string.split(stepInfo.attrStr, ",")) do
			table.insert(attrStepList, string.split(v, "|"))
		end
	    local function addToBaseAttr(item)
	    	local baseAttrList = retAttrList[1] or {}
	    	local isFind = false
	    	for _,v in ipairs(baseAttrList) do
	    		if (v[1] == item[1]) then
	    			v[2] = v[2] + item[2]
	    			isFind = true
	    			break
	    		end
	    	end
	    	if (isFind == false) then
	    		table.insert(baseAttrList, item)
	    	end
	    end
	    for _,attr in ipairs(attrStepList) do
	    	addToBaseAttr(attr)
	    end
	end

    return retAttrList
end

-- 创建时装的技能介绍框
function SubFashionView:showSkillDlg(modelId, isSkill, pos)
	local dlgBgNode = cc.Node:create()
	dlgBgNode:setContentSize(self.viewSize)
	self:addChild(dlgBgNode, 1)

	-- 背景图
	local dlgBgSprite = ui.newSprite("zr_53.png")
	local dlgBgSize = dlgBgSprite:getContentSize()
	dlgBgSprite:setAnchorPoint(cc.p(1, 1))
	dlgBgSprite:setPosition(pos)
	dlgBgNode:addChild(dlgBgSprite)

	-- 技能图标
	local skillIcon = "c_71.png"
    if (isSkill ~= nil) and (isSkill == true) then
        skillIcon = "c_70.png"
    end
    local skillSprite = ui.newSprite(skillIcon)
    skillSprite:setAnchorPoint(cc.p(0, 0.5))
    skillSprite:setPosition(20, dlgBgSize.height - 40)
    dlgBgSprite:addChild(skillSprite)

    -- 技能名字
    local itemData = AttackModel.items[modelId] or {}
    local nameLabel = ui.newLabel({
        text = itemData.name or "",
        color = Enums.Color.eNormalYellow,
        size = 24,
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(58, dlgBgSize.height - 40)
    dlgBgSprite:addChild(nameLabel)

    -- 技能描述
    local attackList = string.splitBySep(itemData.intro or "", "#73430D")
    local attackText = ""
	for _,v in ipairs(attackList) do
		attackText = attackText .. Enums.Color.eNormalWhiteH .. v
	end
    local introLabel = ui.newLabel({
        text = attackText,
        color = Enums.Color.eNormalWhite,
        size = 22,
        align = ui.TEXT_ALIGN_LEFT,
        valign = ui.TEXT_VALIGN_TOP,
        dimensions = cc.size(dlgBgSize.width - 40, 0)
    })
    introLabel:setAnchorPoint(cc.p(0, 1))
    introLabel:setPosition(20, dlgBgSize.height - 70)
    dlgBgSprite:addChild(introLabel)

    -- 注册触摸关闭
    ui.registerSwallowTouch({
		node = dlgBgNode,
		allowTouch = true,
        endedEvent = function(touch, event)
        	dlgBgNode:removeFromParent()
        end
		})
end

-- 穿戴时装
function SubFashionView:requestDressUp(modelId)
	local fashionId = nil
	if modelId == 0 then
		fashionId = EMPTY_ENTITY_ID
	else
		local fashionInfo = FashionObj:getStepFashionInfo(modelId)
		if (fashionInfo == nil) then
			return
		end
		fashionId = fashionInfo.Id
	end
	
	HttpClient:request({
        moduleName = "Fashion",
        methodName = "DressUp",
        svrMethodData = {fashionId},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            FashionObj:setOneItemDressIn(fashionId)
            self:refreshData()
			self:refreshUI()
			if self.callback then
				self.callback(modelId)
			end
        end,
    })
end

-- 重生时装
function SubFashionView:requestRebirth(fashionId)
	if (fashionId == nil) then
		return
	end
	
	HttpClient:request({
        moduleName = "Fashion",
        methodName = "Rebirth",
        svrMethodData = {fashionId},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            -- 掉落
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            -- 更新缓存
            FashionObj:updateFashionList(response.Value.FashionInfo)
            -- 刷新
            self:refreshData()
			self:refreshUI()
        end,
    })
end

----------------------------------------------------------------------------------------------------

return SubFashionView