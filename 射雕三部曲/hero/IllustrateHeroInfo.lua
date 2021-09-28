--[[
	文件名:IllustrateHeroInfo.lua
	描述：群侠谱人物升星界面
	创建人: yanghongsheng
	创建时间: 2017.11.13
--]]

local IllustrateHeroInfo = class("IllustrateHeroInfo", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params中的每项为：
    {
    	curCampId:当前资质等级（1:宗师，2:神话，3:传说）
    	CurrHeroModelId: 选中角色模型id
        HeroList: 所有角色数据列表
        callback:回掉
    }
--]]
function IllustrateHeroInfo:ctor(params)
	params = params or {}
	-- 参数
	self.selectModelId = params.CurrHeroModelId
	self.heroDataList = params.HeroList or {}
	self.selectIndex = 1
	self.campId = params.curCampId or 1
	self.callback = params.callback
	self.mHeroMaxStar = 0
	-- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
    	bgImage = "c_83.png",
    	color4B = cc.c4b(0, 0, 0, 200),
        bgSize = cc.size(640, 1136),
        title = "",
        closeImg = "",
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 初始化当前索引
    self:findSelectIndex()

	-- 创建页面控件
	self:initUI()
end

-- 查找当前选中项
function IllustrateHeroInfo:findSelectIndex()
	for key, value in ipairs(self.heroDataList) do
		if self.selectModelId == value.HeroModelId then
			self.selectIndex = key
			break
		end
	end
end

function IllustrateHeroInfo:initUI()
	-- 创建滑动窗
	local heroView = self:createHeroView()
	heroView:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.62)
	self.mBgSprite:addChild(heroView)
	self.heroView = heroView

	-- 左箭头
	local arrowLeft = ui.newSprite("c_26.png")
	arrowLeft:setPosition(self.mBgSize.width*0.04, self.mBgSize.height*0.65)
	arrowLeft:setRotation(180)
	self.mBgSprite:addChild(arrowLeft)
	self.arrowLeft = arrowLeft
	-- 右箭头
	local arrowRight = ui.newSprite("c_26.png")
	arrowRight:setPosition(self.mBgSize.width*0.96, self.mBgSize.height*0.65)
	self.mBgSprite:addChild(arrowRight)
	self.arrowRight = arrowRight

	-- 更新箭头
	if self.selectIndex == 1 then
		self.arrowLeft:setVisible(false)
	end
	if self.selectIndex == #self.heroDataList then
		self.arrowRight:setVisible(false)
	end

	-- 重生按钮
	local rebirthBtn = ui.newButton({
		normalImage = "tb_212.png",
		clickAction = function ()
			local heroInfo = self.heroDataList[self.selectIndex]
			if not heroInfo then 
				return 
			end
			
			if heroInfo.StarNum == 0 then		-- 没激活
				ui.showFlashView({text = TR("还没有激活该侠客侠谱升星")})
			elseif heroInfo.StarNum > 0 then	-- 已激活升星
				-- 元宝是否充足
				local useDiamond = IllustratedRebirthRelation.items[self.campId][heroInfo.StarNum].useDiamond
				if not Utility.isResourceEnough(ResourcetypeSub.eDiamond, useDiamond) then 
					return 
				end
				-- 返还弹窗
				local rebirthResList = self:getRebirthRes(heroInfo) -- 获取返还资源
				self.rebirthMsgBox = MsgBoxLayer.addPreviewDropLayer(
					rebirthResList, TR("是否花费{db_1111.png}%d返还以下物品？",useDiamond), TR("重生"),
					{
						{
							text = TR("确定"),
							clickAction = function ()
								self:requestRebirth(heroInfo)
								LayerManager.removeLayer(self.rebirthMsgBox)
							end,
						},
						{
							text = TR("取消"),
						},
					},
					{}
				)
			end
		end
	})
	rebirthBtn:setPosition(50, 450)
	rebirthBtn:setVisible(self.campId == 3 or self.campId == 4)  -- 传说,绝学才显示重生按钮
	self.mBgSprite:addChild(rebirthBtn)
	
	-- info背景
	local infoBg = ui.newScale9Sprite("qxp_12.png", cc.size(640, 350))
	infoBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.22)
	self.mBgSprite:addChild(infoBg)
	self.infoBg = infoBg

	-- 进度条
	self.mStepProgBar = require("common.ProgressBar"):create({
        bgImage = "qxp_15.png",
        barImage = "qxp_16.png",
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        needLabel = true,
    })
    self.mStepProgBar:setPosition(320, 210)
    self.mBgSprite:addChild(self.mStepProgBar)

	-- 初始化详细信息
	self:refreshHeroInfo(self.selectIndex)

	-- 退出按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mBgSprite:addChild(closeBtn)
end

-- 获取重生返还资源
function IllustrateHeroInfo:getRebirthRes(heroInfo)
	local modelId, starNum, progNum = heroInfo.HeroModelId, heroInfo.StarNum, heroInfo.usedNum
	-- 消耗侠客数，及其他资源
	local useHeroNum, useResList = 0, {}
	for i = 1, starNum do
		local useResData = IllustratedAttrRelation.items[self.campId][modelId][i]
		useHeroNum = useHeroNum + useResData.consumHeroNum

		local resList = Utility.analysisStrResList(useResData.needGold)
		for _, res in pairs(resList) do
			local uniqueTag = tostring(res.resourceTypeSub)..tostring(res.modelId)
			if useResList[uniqueTag] then
				useResList[uniqueTag].num = useResList[uniqueTag].num + res.num
			else
				useResList[uniqueTag] = res
			end

		end
	end
	-- 加上当前进度消耗的
	useHeroNum = useHeroNum + progNum
	-- 消耗的总资源
	local useAllRes = {}
	-- 消耗的侠客
	local resourceTypeSub = self.campId == 4 and ResourcetypeSub.eFashion or ResourcetypeSub.eHero
	local useHeroRes = {resourceTypeSub = resourceTypeSub, modelId = modelId, num = useHeroNum, cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum}}
	
	table.insert(useAllRes, useHeroRes)
	-- 消耗的其他资源
	for _, res in pairs(useResList) do
		table.insert(useAllRes, res)
	end

	return useAllRes
end

function IllustrateHeroInfo:createHeroView()
	-- 大小
	local width, height = 640, 800
	-- 滑动窗体
	local heroSlider = ui.newSliderTableView({
        width = width,
        height = height,
        isVertical = false,
        selItemOnMiddle = true,
        selectIndex = self.selectIndex-1,
        itemCountOfSlider = function(sliderView)
        	return #self.heroDataList
        end,
        itemSizeOfSlider = function(sliderView)
            return width, height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
        	-- 数据
        	local itemData = self.heroDataList[index+1]
        	local heroInfo = IllustratedHeroLihuiRelation.items[itemData.HeroModelId]
        	-- hero背景
        	local heroBg = ui.newSprite("qxp_11.png")
        	heroBg:setPosition(width*0.5, height*0.5)
        	itemNode:addChild(heroBg)
        	-- 模板
        	local lookViewSize = cc.size(560,740)
    		local stencilNode = cc.LayerColor:create(cc.c4b(255, 0, 0, 255))
    		stencilNode:setIgnoreAnchorPointForPosition(false)
    		stencilNode:setAnchorPoint(cc.p(0.5, 0.5))
    		stencilNode:setContentSize(lookViewSize)
    		stencilNode:setPosition(width*0.5-3, height*0.5)
    		-- 裁剪节点
    		local clipNode = cc.ClippingNode:create()
    		clipNode:setContentSize(cc.size(width,height))
    		clipNode:setAlphaThreshold(1.0)
    		clipNode:setStencil(stencilNode)
    		itemNode:addChild(clipNode)
    		-- 立绘
			local heroLihui = ui.newSprite(heroInfo.pic..".png")
			heroLihui:setPosition(width*0.5, height*0.5)
			clipNode:addChild(heroLihui)

    		-- 星数
    		local starsNode = self:createStars(itemData.StarNum, true)
    		if starsNode then
	    		starsNode:setPosition(cc.p(width*0.1, height*0.7))
	    		itemNode:addChild(starsNode)
	    	end
	    	-- 名字
	    	local nameSprite = ui.newSprite(heroInfo.smallPic..".png")
	    	nameSprite:setAnchorPoint(cc.p(0.5, 1))
	    	nameSprite:setPosition(cc.p(width*0.2, height*0.92))
	    	itemNode:addChild(nameSprite)
        end,
        selectItemChanged = function(sliderView, selectIndex)
        	-- 更新索引
        	self.selectIndex = selectIndex+1
        	-- 更新图框
        	sliderView:refreshItem(selectIndex)
        	-- 更新下面详细信息
        	self:refreshHeroInfo(selectIndex+1)
        	-- 更新箭头
        	if self.selectIndex == 1 then
        		self.arrowLeft:setVisible(false)
        		self.arrowRight:setVisible(true)
    		elseif self.selectIndex == #self.heroDataList then
    			self.arrowLeft:setVisible(true)
        		self.arrowRight:setVisible(false)
        	else
        		self.arrowLeft:setVisible(true)
        		self.arrowRight:setVisible(true)
    		end
        end
    })

    return heroSlider
end

-- 创建星
function IllustrateHeroInfo:createStars(num, isVertical)
	local parentNode = cc.Node:create()
	local space = 40
	local num = num - 1
	local monStars = 5
	local monNum = num - monStars
	if (num <= 0) then 
		return 
	end

	-- 月亮
	if monNum > 0 then
		for i = 1, monNum do
			local starSprite = ui.newSprite("zs_04.png")
			parentNode:addChild(starSprite)
			if isVertical then
				starSprite:setPosition(0, -((i-1)*space)+160)
			else
				starSprite:setPosition((i-1)*space, 0)
			end
		end
	-- 星星
	else
		for i = 1, num do
			local starSprite = ui.newSprite("c_75.png")
			parentNode:addChild(starSprite)
			if isVertical then
				starSprite:setPosition(0, -((i-1)*space)+160)
			else
				starSprite:setPosition((i-1)*space, 0)
			end
		end
	end

	return parentNode
end

-- 获得属性字符串
function IllustrateHeroInfo:getAttrString(str)
	local attrList = Utility.analysisStrFashionAttrList(str)
	local function getSortIndex(fightAttr)
		if (fightAttr == Fightattr.eHP) or (fightAttr == Fightattr.eHPR) then
			return 3
		end
		if (fightAttr == Fightattr.eAP) or (fightAttr == Fightattr.eAPR) then
			return 2
		end
		if (fightAttr == Fightattr.eDEFR) or (fightAttr == Fightattr.eDEFR) then
			return 1
		end
		return 0
	end
	table.sort(attrList, function (a, b)
			-- 血量 > 攻击 > 防御
			return getSortIndex(a.fightattr) > getSortIndex(b.fightattr)
		end)
	local attrStrList = {}
	for _, value in pairs(attrList) do
		-- 获取属性范围字符串
		local text = Utility.getRangeStr(value.range)
		-- 属性名
		text = text .. FightattrName[value.fightattr]
		-- 属性值
		text = text .. "+" .. tostring(value.value)

		table.insert(attrStrList, text)
	end

	return table.concat(attrStrList, "\n")
end

-- 刷新信息栏
function IllustrateHeroInfo:refreshHeroInfo(selectIndex)
	local itemData = self.heroDataList[selectIndex]
	if not itemData then 
		return 
	end
	local bgSize = self.infoBg:getContentSize()
	local itemType = math.floor(itemData.HeroModelId / 10000)
	local heroAttrConfig = IllustratedAttrRelation.items[self.campId][itemData.HeroModelId]
	self.mHeroMaxStar = table.maxn(heroAttrConfig)	-- hero满星数
	local itemOwnNum = Utility.isFashion(itemType) and (FashionObj:getFashionCount(itemData.HeroModelId) - 1) or HeroObj:getCountByModelId(itemData.HeroModelId, {notInFormation = true, maxLv = 1, maxStep = 0})
	if (itemOwnNum < 0) then
		itemOwnNum = 0 	-- 不管是否上阵，该绝学必须保留一件不被消耗
	end
	
	-- 清空信息栏
	self.infoBg:removeAllChildren()

	-- 创建加成属性
	local function createAddAttr(tmpStepUpData, pos)
		local attrLabel = ui.newLabel({text = self:getAttrString(tmpStepUpData.currentAttr), size = 20})
		attrLabel:setAnchorPoint(cc.p(0.5, 0.5))
		attrLabel:setPosition(pos)
		self.infoBg:addChild(attrLabel)
	end
	
	-- 创建消耗资源的头像
	local function createResHeader(tmpStepUpData, pos)
		local heroCard, cardShowAttrs = CardNode.createCardNode({
			resourceTypeSub = itemType,
			modelId = itemData.HeroModelId,
			num = tmpStepUpData.consumHeroNum,
			cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
			allowClick = false,
		})
		heroCard:setPosition(pos)
		self.infoBg:addChild(heroCard)

		-- 消耗卡的数量
		local text = Utility.numberWithUnit(itemOwnNum, 0) .. "/" .. Utility.numberWithUnit(tmpStepUpData.consumHeroNum, 0)
        if itemOwnNum >= tmpStepUpData.consumHeroNum then
            cardShowAttrs[CardShowAttr.eNum].label:setString(Enums.Color.eGreenH .. text)
        else
            cardShowAttrs[CardShowAttr.eNum].label:setString(Enums.Color.eRedH .. text)
        end
	end

	-- 创建金币资源的消耗
	local function createGoldResLabel(useResList, pos)
        local useResString = ""
		for _, resData in pairs(useResList) do
			local resImage = Utility.getDaibiImage(resData.resourceTypeSub, resData.modelId)
			useResString = useResString.."{"..resImage.."}"..resData.num.." "
			if resData.num <= Utility.getOwnedGoodsCount(resData.resourceTypeSub, resData.modelId) then
				resData.isEnough = true
			end
		end
		local useResLabel = ui.newLabel({text = useResString, size = 20})
		useResLabel:setPosition(pos)
		self.infoBg:addChild(useResLabel)
	end

	-- 创建按钮
	local function createUpButton(tmpStepUpData, pos, btnText, useResList)
		local stepUpBtn = ui.newButton({
			normalImage = "c_28.png",
			text = btnText,
			clickAction = function ()
				local needNum = 1
				if itemData.StarNum <= 0 then	-- 还没激活需要
					needNum = tmpStepUpData.consumHeroNum
				end
				-- 卡片资源不足
				if itemOwnNum < 1 then
					if Utility.isFashion(itemType) then
						local tempStr = TR("没有多余的绝学%s%s%s了，是否前往获取？", Enums.Color.eNormalGreenH, Utility.getGoodsName(itemType, itemData.HeroModelId), Enums.Color.eNormalWhiteH)
					    local okBtnInfo = {
					        text = TR("前往"),
					        clickAction = function(layerObj, btnObj)
					            LayerManager.removeLayer(layerObj)
					            Utility.getFashionWay(itemData.HeroModelId)
					        end,
					    }
					    MsgBoxLayer.addOKLayer(tempStr, TR("提示"), {okBtnInfo}, {})
					else
						Utility.showResLackLayer(itemType, itemData.HeroModelId)
					end
					return
				end
				-- 其他资源不足
				for _, resData in pairs(useResList) do
					if not resData.isEnough then
						Utility.showResLackLayer(resData.resourceTypeSub, resData.modelId)
						return
					end
				end
				-- 弹出提示框
				local function showHintMsgBox(strText)
					self.hintBox = MsgBoxLayer.addOKCancelLayer(
						strText,
						TR("提示"),
						{
							text = TR("确定"),
							normalImage = "c_28.png",
							clickAction = function ()
								if itemData.StarNum <= 0 then
									self:requestUpHero(itemData.HeroModelId, tmpStepUpData.consumHeroNum)
								else
									self:requestUpHeroCount(itemData.HeroModelId, tmpStepUpData.consumHeroNum-(itemData.usedNum or 0))
								end
								LayerManager.removeLayer(self.hintBox)
							end
						},
						nil,
						{},
						false
					)
				end
				if Utility.isHero(itemType) then
					-- 红将提示
					if (HeroModel.items[itemData.HeroModelId].quality >= 18) then
						showHintMsgBox(TR("侠谱升星需要#FF4A46消耗同名侠客\n%s少侠请确认是否继续？", Enums.Color.eNormalWhiteH))
						return
					end

					-- 已上阵提示
					for _, slotData in pairs(FormationObj:getSlotInfos()) do
						if slotData.ModelId == itemData.HeroModelId then
							showHintMsgBox(TR("此侠客已上阵，侠谱升星需要#FF4A46消耗同名侠客\n%s少侠请确认是否继续？", Enums.Color.eNormalWhiteH))
							return
						end
					end

					-- 执行接口
					if itemData.StarNum <= 0 then
						self:requestUpHero(itemData.HeroModelId, tmpStepUpData.consumHeroNum)
					else
						self:requestUpHeroCount(itemData.HeroModelId, tmpStepUpData.consumHeroNum-(itemData.usedNum or 0))
					end
				else
					-- 执行接口
					if itemData.StarNum <= 0 then
						self:requestUpFashion(itemData.HeroModelId, tmpStepUpData.consumHeroNum)
					else
						self:requestUpFashionCount(itemData.HeroModelId, tmpStepUpData.consumHeroNum-(itemData.usedNum or 0))
					end
				end
			end
		})
		stepUpBtn:setPosition(pos)
		self.infoBg:addChild(stepUpBtn)
		self.stepUpBtn = stepUpBtn
	end

	-- 分别处理激活、升星、满级的情况
	if itemData.StarNum <= 0 then
		-- 星数为0的时候需要先激活
		local heroStepUpData = heroAttrConfig[1]
		local useResList = Utility.analysisStrResList(heroStepUpData.needGold)
		createAddAttr(heroStepUpData, cc.p(bgSize.width*0.5, 180)) 			-- 加成属性
		createResHeader(heroStepUpData, cc.p(bgSize.width*0.2, 160)) 		-- 消耗资源卡
		createGoldResLabel(useResList, cc.p(bgSize.width*0.8, 180)) 	-- 消耗金币
        createUpButton(heroStepUpData, cc.p(bgSize.width*0.8, 130), TR("激活"), useResList)
        self.mStepProgBar:setVisible(false)
	elseif itemData.StarNum >= self.mHeroMaxStar then
		-- 已满星
		local starsNode = self:createStars(self.mHeroMaxStar)
		starsNode:setPosition(bgSize.width*0.35, 230)
		self.infoBg:addChild(starsNode)
		
		-- 加成属性
		createAddAttr(heroAttrConfig[self.mHeroMaxStar], cc.p(bgSize.width*0.48, 160))
		
		-- 已满星label
		local fullSprite = ui.createSpriteAndLabel({imgName = "c_156.png", labelStr = TR("已满星")})
		fullSprite:setPosition(bgSize.width*0.48, 80)
		self.infoBg:addChild(fullSprite)
		-- 进度隐藏
		self.mStepProgBar:setVisible(false)
	else
		-- 显示星数
		local function addStars(num, pos)
			local starsNode = self:createStars(num, false)
			if starsNode then
				starsNode:setAnchorPoint(cc.p(0, 0))
				starsNode:setPosition(pos)
				self.infoBg:addChild(starsNode)
			end
		end

		-- 升星前
		local heroStepUpData = heroAttrConfig[itemData.StarNum]
		addStars(itemData.StarNum, cc.p(bgSize.width*0.1, 260)) 			-- 星星数量
		createAddAttr(heroStepUpData, cc.p(bgSize.width*0.18, 200)) 		-- 加成属性
		
		-- 中间箭头
		local arrowSprite = ui.newSprite("c_67.png")
		arrowSprite:setPosition(bgSize.width*0.45, 195)
		self.infoBg:addChild(arrowSprite)

        -- 升星后
        local heroStepUpData2 = heroAttrConfig[itemData.StarNum+1]
        local useResList = Utility.analysisStrResList(heroStepUpData2.needGold)
        addStars(itemData.StarNum+1, cc.p(bgSize.width*0.62, 260)) 			-- 星星数量
        createAddAttr(heroStepUpData2, cc.p(bgSize.width*0.72, 200))			-- 加成属性
		createResHeader(heroStepUpData2, cc.p(bgSize.width*0.4, 60)) 		-- 消耗资源卡
        createGoldResLabel(useResList, cc.p(bgSize.width*0.65, 90)) 	-- 消耗金币
		createUpButton(heroStepUpData2, cc.p(bgSize.width*0.65, 40), TR("升星"), useResList)

		--进度显示
		self.mStepProgBar:setVisible(true)
		self.mStepProgBar:setMaxValue(heroStepUpData2.consumHeroNum)
		self.mStepProgBar:setCurrValue(itemData.usedNum, 0)
	end
end

function IllustrateHeroInfo:requestUpHeroCount(modelId, needNum)
	-- 获取所有符合添加的角色数据
	local tmpArray = HeroObj:findHeroByModelId(modelId, {notInFormation = true, maxStep = 0, maxLv = 1}) or {}
	local maxNum = needNum > #tmpArray and #tmpArray or needNum
	if maxNum <= 0 then
		ui.showFlashView(TR("有培养过的侠客，请先重生"))
		return
	end
	MsgBoxLayer.addUseGoodsCountLayer(TR("升星消耗"), modelId, maxNum, function(selCount, layerObj, btnObj)
		self:requestUpHero(modelId, selCount)
		LayerManager.removeLayer(layerObj)
	end, nil, ResourcetypeSub.eHero, false)
end

function IllustrateHeroInfo:requestUpFashionCount(modelId, needNum)
	-- 获取所有符合添加的角色数据
	local tmpArray = FashionObj:getFashionGuidList(modelId)
	local maxNum = needNum > #tmpArray and #tmpArray or needNum
	if maxNum <= 0 then
		ui.showFlashView(TR("有培养过的绝学，请先重生"))
		return
	end
	MsgBoxLayer.addUseGoodsCountLayer(TR("升星消耗"), modelId, maxNum, function(selCount, layerObj, btnObj)
		self:requestUpFashion(modelId, selCount)
		LayerManager.removeLayer(layerObj)
	end, nil, ResourcetypeSub.eFashionClothes, false)
end

--=======================服务器相关================================
-- 激活／升星
function IllustrateHeroInfo:requestUpHero(modelId, num)
	local tmpArray = HeroObj:findHeroByModelId(modelId, {notInFormation = true, maxStep = 0, maxLv = 1}) or {}
	-- 消耗的人id列表
	local useHeroIdList = {}
	for _, item in pairs(tmpArray) do
		table.insert(useHeroIdList, item.Id)
		if num <= #useHeroIdList then break end
	end
	-- 请求升星
	HttpClient:request({
	    moduleName = "Illustrated",
	    methodName = "StarUp",
	    svrMethodData = {modelId, useHeroIdList},
	    callback = function(response)
	        -- 判断返回数据
	        if not response or response.Status ~= 0 then
	            return
	        end
	        -- 更新数据
	        for _, heroServerData in pairs(response.Value.IllustratedInfo) do
	        	for _, heroOriginData in pairs(self.heroDataList) do
	        		if heroServerData.HeroModelId == heroOriginData.HeroModelId then
	        			heroOriginData.StarNum = heroServerData.StarNum
	        			heroOriginData.usedNum = heroServerData.Num
	        		end
	        	end
	        end
	        -- 删除已被消耗的人物
	        for _, heroId in pairs(useHeroIdList) do
	        	HeroObj:deleteHeroById(heroId)
	        end
	        -- 调用回调(更新侠谱主页)
	        if self.callback then
	        	self.callback(self.heroDataList)
	        end
	        -- 播放音效
	        MqAudio.playEffect("qunxiapu.mp3")
	        self.stepUpBtn:setEnabled(false)
	        -- 播放升星特效
	        ui.newEffect({
	    		parent = self.heroView:getItemNode(self.selectIndex-1),
	    		effectName = "effect_ui_shengxingsaoguang",
	    		position = cc.p(self.heroView:getContentSize().width*0.5, self.heroView:getContentSize().height*0.55),
	    		loop = false,
	    		endRelease = true,
	    		endListener = function ()
				    -- 刷新界面
				    self.heroView:refreshItem(self.selectIndex-1)
					self:refreshHeroInfo(self.selectIndex)
	    		end,
	    	})

	    end,
	})
end

function IllustrateHeroInfo:requestUpFashion(modelId, num)
	local tmpArray = FashionObj:getFashionGuidList(modelId)
	-- 消耗的人id列表
	local useHeroIdList = {}
	for _, item in pairs(tmpArray) do
		table.insert(useHeroIdList, item)
		if num <= #useHeroIdList then break end
	end
	-- 请求接口
    HttpClient:request({
        moduleName = "Illustrated",
        methodName = "StarUp",
        svrMethodData = {modelId, useHeroIdList},
        callback = function(response)
            -- 判断返回数据
            if not response or response.Status ~= 0 then
                return
            end
            -- 更新数据
            for _, heroServerData in pairs(response.Value.IllustratedInfo) do
            	for _, heroOriginData in pairs(self.heroDataList) do
            		if heroServerData.HeroModelId == heroOriginData.HeroModelId then
            			heroOriginData.StarNum = heroServerData.StarNum
            			heroOriginData.usedNum = heroServerData.Num
            		end
            	end
            end
            -- 删除已被消耗的绝学
            for _, guid in pairs(useHeroIdList) do
            	FashionObj:delOneItem(guid)
            end
            -- 调用回调(更新侠谱主页)
            if self.callback then
            	self.callback(self.heroDataList)
            end
            -- 播放音效
            MqAudio.playEffect("qunxiapu.mp3")
            self.stepUpBtn:setEnabled(false)
            -- 播放升星特效
            ui.newEffect({
        		parent = self.heroView:getItemNode(self.selectIndex-1),
        		effectName = "effect_ui_shengxingsaoguang",
        		position = cc.p(self.heroView:getContentSize().width*0.5, self.heroView:getContentSize().height*0.55),
        		loop = false,
        		endRelease = true,
        		endListener = function ()
    			    -- 刷新界面
    			    self.heroView:refreshItem(self.selectIndex-1)
    				self:refreshHeroInfo(self.selectIndex)
        		end,
        	})

        end,
    })
end

-- 侠客重生
function IllustrateHeroInfo:requestRebirth(heroInfo)
	HttpClient:request({
        moduleName = "Illustrated",
        methodName = "Rebirth",
        svrMethodData = {{heroInfo.HeroModelId}},
        callback = function(response)
            -- 判断返回数据
            if not response or response.Status ~= 0 then
                return
            end
            -- 更新数据
            for _, heroServerData in pairs(response.Value.IllustratedInfo) do
            	for _, heroOriginData in pairs(self.heroDataList) do
            		if heroServerData.HeroModelId == heroOriginData.HeroModelId then
            			heroOriginData.StarNum = heroServerData.StarNum
            		end
            	end
            end
            -- 该侠客升星归0
            heroInfo.StarNum = 0
            -- 调用回调(更新侠谱主页)
            if self.callback then
            	self.callback(self.heroDataList)
            end
            -- 掉落
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            
        	-- 如果重生绝学先刷新缓存再刷新界面
        	if self.campId == 4 then
        		FashionObj:refreshFashionList(function (fashionList)
    			    -- 刷新界面
    			    self.heroView:refreshItem(self.selectIndex-1)
    				self:refreshHeroInfo(self.selectIndex)
    			end)
        	else
    		    -- 刷新界面
    		    self.heroView:refreshItem(self.selectIndex-1)
    			self:refreshHeroInfo(self.selectIndex)
        	end
        end,
    })
end

return IllustrateHeroInfo