--[[
	文件名:SubEquipStarUpView.lua
	描述：装备升星的子页面
	创建人：peiyaoqiang
	创建时间：2017.05.12
--]]

local SubEquipStarUpView = class("SubEquipStarUpView", function(params)
    return cc.Node:create()
end)

--[[
-- 参数 params 中各项为：
	{
		viewSize: 显示大小，必选参数
		equipId: 装备实例Id，必选参数
		callback: 回调接口，可选参数

		parentName: 父页面路径，可选参数
		resStarItem: 已选择的装备材料，可选参数
	}
]]
function SubEquipStarUpView:ctor(params)
	params = params or {}
	
	-- 读取参数
	self.viewSize = params.viewSize
	self.equipId = params.equipId
	self.callback = params.callback

	self.parentName = params.parentName
	self.resStarItem = params.resStarItem
	
	-- 初始化
	self:setContentSize(self.viewSize)
	
	-- 显示界面
	local equipInfo = EquipObj:getEquip(self.equipId)
	local equipBase = EquipModel.items[equipInfo.ModelId]
	if (equipBase.valueLv < 4) then
		local infoLabel = ui.newLabel({
			text = TR("橙色或更高品质的装备才能进行升星"),
			color = cc.c3b(0x46, 0x22, 0x0d),
			size = 30,
		})
		infoLabel:setAnchorPoint(cc.p(0.5, 0.5))
		infoLabel:setPosition(cc.p(self.viewSize.width * 0.5, self.viewSize.height * 0.5))
		self:addChild(infoLabel)
	else
		self:initUI()
		self:refreshUI()
	end

	-- 注册关闭监控事件
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then
            FormationObj:enableShowAttrChangeAction(true)
        end
    end)
end

-- 初始化UI
function SubEquipStarUpView:initUI()
	-- 创建灰色背景图
	local centerBgSize = cc.size(self.viewSize.width - 40, self.viewSize.height - 220)
	local centerBgSprite = ui.newScale9Sprite("c_38.png", centerBgSize)
	centerBgSprite:setAnchorPoint(cc.p(0.5, 0))
	centerBgSprite:setPosition(cc.p(self.viewSize.width / 2, 160))
	self:addChild(centerBgSprite)

	-- 创建箭头
	local arrowSprite = ui.newSprite("c_67.png")
	arrowSprite:setPosition(centerBgSize.width * 0.5 - 5, centerBgSize.height * 0.5)
	centerBgSprite:addChild(arrowSprite)

	-- 创建属性背景图
	local function createAttrBg(posX)
		local attrBgSprite = ui.newScale9Sprite("c_54.png", cc.size(centerBgSize.width * 0.4, 150))
		attrBgSprite:setPosition(posX, centerBgSize.height * 0.5)
		attrBgSprite.addTitle = function(target, titleText)
			local titleLabel = ui.newLabel({
		        text = titleText,
		        size = 24,
		        color = Enums.Color.eWhite,
		        outlineColor = cc.c3b(0x8d, 0x4b, 0x3b),
		        outlineSize = 2,
		    })
		    titleLabel:setPosition(centerBgSize.width * 0.2, 150 - 22)
		    target:addChild(titleLabel)
		end
		centerBgSprite:addChild(attrBgSprite)
		return attrBgSprite
	end
	self.oldAttrBg = createAttrBg(centerBgSize.width * 0.23)
	self.newAttrBg = createAttrBg(centerBgSize.width * 0.77)

	-- 等级需求Label
	local lvNeedLabel = ui.newLabel({
		text = "",
		color = cc.c3b(0x46, 0x22, 0x0d),
	})
	lvNeedLabel:setAnchorPoint(cc.p(0.5, 0.5))
	lvNeedLabel:setPosition(self.viewSize.width * 0.5, self.viewSize.height - 45)
	self:addChild(lvNeedLabel)
	self.lvNeedLabel = lvNeedLabel

	-- 提示文字Label
	local introLabel = ui.newLabel({
		text = TR("需要消耗同品质同部位的装备"),
		color = cc.c3b(0xef, 0x00, 0x08),
		dimensions = cc.size(230, 0),
		align = cc.TEXT_ALIGNMENT_CENTER
	})
	introLabel:setAnchorPoint(cc.p(0.5, 0.5))
	introLabel:setPosition(cc.p(self.viewSize.width * 0.23, 85))
	self:addChild(introLabel)
	self.introLabel = introLabel

	-- 消耗材料
	local tempCard = CardNode:create({
        allowClick = true,
        onClickCallback = function()
        	local equipInfo = EquipObj:getEquip(self.equipId)
			local strParentName = self.parentName
        	LayerManager.addLayer({
        		name = "commonLayer.SelectLayer",
        		data = {
        			selectType = Enums.SelectType.eEquipStarUp,
        			modelId = equipInfo.ModelId,
        			needCount = (self.starConfig ~= nil) and self.starConfig.useBaseCardNum or 1,
        			excludeIdList = {self.equipId},
        			callback = function(selectLayer, selectItemList, resoucetype)
        				local tempData = LayerManager.getRestoreData(strParentName)
        				tempData.resStarItem = clone(selectItemList)
        				LayerManager.setRestoreData(tempData)
        				
        				-- 删除装备选择页面
        				LayerManager.removeLayer(selectLayer)
        			end
        		},
        	})
        end,
	})
	tempCard:setPosition(self.viewSize.width * 0.5, 85)
	self:addChild(tempCard)
	self.resEquipNode = tempCard

	-- 显示消耗材料的数量
	local needNumLabel = ui.newLabel({
        text = "",
        size = 16,
        color = Enums.Color.eRed,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2,
        align = ui.TEXT_ALIGN_RIGHT,
        valign = ui.TEXT_VALIGN_CENTER,
    })
    needNumLabel:setAnchorPoint(cc.p(0.5, 0.5))
    needNumLabel:setPosition(cc.p(self.viewSize.width * 0.5, 55))
    self:addChild(needNumLabel, 1)
    self.needNumLabel = needNumLabel

    -- 自动放入按钮
    local btnAutoFill = ui.newButton({
		normalImage = "c_28.png",
		text = TR("自动放入"),
		clickAction = function()
			local needCount = (self.starConfig ~= nil) and self.starConfig.useBaseCardNum or 1
			local equipInfo = EquipObj:getEquip(self.equipId)
			local autoResList = EquipObj:getListOfStarUp(equipInfo.ModelId, self.equipId)
			if (autoResList == nil) or (#autoResList < needCount) then
				ui.showFlashView(TR("没有足够的同名同品质的装备材料"))
				return
			end

			-- 复制读取到的材料
			self.resStarItem = {}
			for i=1,needCount do
				self.resStarItem[i] = autoResList[i]
			end
			self:refreshUI()
		end
	})
	btnAutoFill:setPosition(self.viewSize.width * 0.75, 70)
	self:addChild(btnAutoFill)
	self.btnAutoFill = btnAutoFill

	-- 升星按钮
	local btnStarUp = ui.newButton({
		normalImage = "c_28.png",
		text = TR("升星"),
		clickAction = function()
			self:requestStarUp()
		end
	})
	btnStarUp:setPosition(self.viewSize.width * 0.75, 70)
	btnStarUp:setVisible(false)
	self:addChild(btnStarUp)
	self.btnStarUp = btnStarUp

	-- 显示满级标签
	local fullSprite = ui.newSprite("zb_25.png")
	fullSprite:setPosition(self.viewSize.width * 0.5, 80)
	self:addChild(fullSprite)
	self.fullSprite = fullSprite
end

-- 刷新界面
function SubEquipStarUpView:refreshUI()
	local equipInfo = EquipObj:getEquip(self.equipId)
	local equipBase = EquipModel.items[equipInfo.ModelId]
	
	self.currLv = equipInfo.Lv or 0
	self.currStar = equipInfo.Star or 0
	self.maxStar = equipBase.starMax
	self.starConfig = EquipStarRelation.items[equipBase.valueLv * 100 + (self.currStar + 1)]
	if (self.starConfig ~= nil) then
		local strLvNeed = TR("强化到%d级时，装备可升到%d星", self.starConfig.needUpLv, (self.currStar + 1))
		local strNumNeed = self:getResStarItemCount() .. "/" .. self.starConfig.useBaseCardNum
		self.lvNeedLabel:setString(((self.currLv >= self.starConfig.needUpLv) and Enums.Color.eNormalGreenH or Enums.Color.eRedH) .. strLvNeed)
		self.needNumLabel:setString(((self:getResStarItemCount() >= self.starConfig.useBaseCardNum) and Enums.Color.eNormalGreenH or Enums.Color.eRedH) .. strNumNeed)
	end

	-- 重建当前属性
	local function resetAttrShow(attrBg, titleText, star)
		attrBg:removeAllChildren()
		attrBg:addTitle(TR(titleText))

		local attrList = {
			{posY = 86, text = FightattrName[Fightattr.eHP], attrBase = "HP", attrUp = "HPUP"},
			{posY = 54, text = FightattrName[Fightattr.eAP], attrBase = "AP", attrUp = "APUP"},
			{posY = 22, text = FightattrName[Fightattr.eDEF], attrBase = "DEF", attrUp = "DEFUP"},
		}
		local starId = equipBase.valueLv * 100 + star
		local starBase = EquipStarRelation.items[starId] or {}
		local addAttrR = starBase.curAddAttrR or 0
		for _,v in ipairs(attrList) do
			local tempPerAttr = equipBase[v.attrUp] * (1 + addAttrR)
			local tempAllAttr = "??"
			if (star <= self.maxStar) then
				tempAllAttr = math.floor(tempPerAttr * self.currLv + equipBase[v.attrBase] * (1 + addAttrR))
			end
			local tempLabel = ui.newLabel({
				text = string.format("%s: %s%s", v.text, "#087E05", tempAllAttr),
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 22,
			})
			tempLabel:setAnchorPoint(cc.p(0, 0.5))
			tempLabel:setPosition(50, v.posY)
			attrBg:addChild(tempLabel)
		end
	end
	resetAttrShow(self.oldAttrBg, TR("当前星级"), self.currStar)
	resetAttrShow(self.newAttrBg, TR("下一星级"), self.currStar + 1)

	-- 判断是否已经满级，决定是否显示某些控件
	local isFullLv = (self.currStar >= self.maxStar)
	self.resEquipNode:setVisible(not isFullLv)
	self.introLabel:setVisible(not isFullLv)
	self.needNumLabel:setVisible(not isFullLv)
	self.btnAutoFill:setVisible(not isFullLv)
	self.btnStarUp:setVisible(false) -- 有了自动放入按钮，则升星按钮一直隐藏
	self.fullSprite:setVisible(isFullLv)

	-- 刷新同名的消耗材料
	if (self:getResStarItemCount() > 0) then
		self.resEquipNode:setEquipment(self.resStarItem[1], {CardShowAttr.eBorder})
		self.btnAutoFill:setVisible(false)
		self.btnStarUp:setVisible(not isFullLv)
	else
		self.resEquipNode:setEmpty({}, "c_04.png")
		self.resEquipNode:showGlitterAddMark("c_144.png", 1.2)
	end
	
	-- 刷新额外消耗
	if (self.starConfig ~= nil) and (self.starConfig.useExtraStr ~= nil) then
		local tempList = string.split(self.starConfig.useExtraStr, ",")
		self.usrExtra = {resourceTypeSub = tonumber(tempList[1]), number = tonumber(tempList[3])}

		local useExtraNode = ui.createDaibiView({
			resourceTypeSub = self.usrExtra.resourceTypeSub,
	        number = self.usrExtra.number,
	        showOwned = true,
	        fontColor = cc.c3b(0x46, 0x22, 0x0d),
		})
		useExtraNode:setAnchorPoint(cc.p(0.5, 0.5))
		useExtraNode:setPosition(self.viewSize.width * 0.75, 120)
		self:addChild(useExtraNode)
	end
end

-- 获取已选择材料的数量
function SubEquipStarUpView:getResStarItemCount()
	if (self.resStarItem == nil) then
		return 0
	end
	return #self.resStarItem
end

-- 升星接口
function SubEquipStarUpView:requestStarUp()
	-- 判断是否已经满级
	if (self.currStar >= self.maxStar) then
		ui.showFlashView(TR("该装备已经升星到最高"))
		return
	end

	-- 判断是否符合等级需求
	if (self.currLv < self.starConfig.needUpLv) then
		ui.showFlashView(TR("该装备需强化到%d级才能继续升星", self.starConfig.needUpLv))
		return
	end

	-- 判断铜钱或元宝是否足够
	if not Utility.isResourceEnough(self.usrExtra.resourceTypeSub, self.usrExtra.number, true) then
		return
	end

	-- 判断是否选择了材料
	if (self:getResStarItemCount() < self.starConfig.useBaseCardNum) then
		ui.showFlashView(TR("您选择的同名同品质的装备材料数量不足"))
		return
	end

	-- 预处理
	local oldSlotInfos = clone(FormationObj:getSlotInfos())
	local oldMasterLvs = ConfigFunc:getMasterLv(oldSlotInfos) or {}
	FormationObj:enableShowAttrChangeAction(false)

	-- 请求接口
	local tmpEquipIdList = {}
	for _,v in ipairs(self.resStarItem) do
		table.insert(tmpEquipIdList, v.Id)
	end
	HttpClient:request({
        moduleName = "Equip",
        methodName = "EquipStarUp",
        svrMethodData = {self.equipId, tmpEquipIdList},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return 
            end

            -- 刷新缓存
            EquipObj:modifyEquipItem(response.Value.EquipInfo)
            EquipObj:deleteEquipItems(tmpEquipIdList)
            self.resStarItem = nil

            -- 播放装备升星
            MqAudio.playEffect("jinjiedashi.mp3")

            -- 执行回调
            if (self.callback ~= nil) then
            	self.callback(ModuleSub.eEquipStarUp)
            end

            -- 判断共鸣是否变化
            local newMasterLvs = ConfigFunc:getMasterLv(FormationObj:getSlotInfos()) or {}
            local function endFunc()
            	local slotDiffInfos = FormationObj:getSlotDiff(oldSlotInfos, FormationObj:getSlotInfos())
		        FormationObj:showSlotAttrChange(slotDiffInfos)
		    end
            local ret = FormationObj:showEquipMasterTips(oldMasterLvs, newMasterLvs, endFunc)
            if (ret == nil) then
            	endFunc()
            end
            FormationObj:enableShowAttrChangeAction(true)
        end
    })
end

return SubEquipStarUpView