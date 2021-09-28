--[[
	文件名：PetLvUpLayer.lua
	描述：外功秘籍升级分页面
	创建人：peiyaoqiang
	创建时间：2017.03.21
--]]

local PetLvUpLayer = class("PetLvUpLayer", function()
	return display.newLayer()
end)

-- 构造函数
--[[
	params:
	Table params:
	{
		petList 			-- 必须参数，外功秘籍列表
		currIndex 			-- 必须参数，需要展示的外功秘籍在列表中的序号
		callback 			-- 可选参数，数据改变之后父页面的回调
	}
--]]
function PetLvUpLayer:ctor(params)
	-- 父节点已做适配，此页面按照640 1136即可
	self:setContentSize(640, 1136)

	-- 保存数据
    self.mPetList = params.petList
    self.mCurrIndex = params.currIndex
    self.mCallback = params.callback

    -- 外功秘籍数量
    self.mPetNum = table.nums(self.mPetList)

	-- 添加UI元素
	self:initUI()
end

-- 初始化UI
function PetLvUpLayer:initUI()
	-- 背景图
    local bgSprite = cc.Node:create()
    bgSprite:setContentSize(cc.size(640, 1136))
    bgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    bgSprite:setPosition(320, 568)
    self:addChild(bgSprite)
    self.mBgSprite = bgSprite

    -- 创建SliderView
    self:addSliderView()

    -- 左右箭头
    if self.mPetNum > 1 then
    	self.mLeftArrow = ui.newButton({
    		normalImage = "c_26.png",
    		position = cc.p(20, 840),
    		clickAction = function(btnObj)
    			self.mSliderView:setSelectItemIndex(self.mCurrIndex - 2, true)
    		end
    	})
    	self.mLeftArrow:setScaleX(-1)
    	bgSprite:addChild(self.mLeftArrow)

    	self.mRightArrow = ui.newButton({
    		normalImage = "c_26.png",
    		position = cc.p(620, 840),
    		clickAction = function(btnObj)
    			self.mSliderView:setSelectItemIndex(self.mCurrIndex, true)
    		end
    	})
    	bgSprite:addChild(self.mRightArrow)

    	if self.mCurrIndex == 1 then
    		self.mLeftArrow:setVisible(false)
    	elseif self.mCurrIndex == self.mPetNum then
    		self.mRightArrow:setVisible(false)
    	end
    end

    -- 规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        clickAction = function (pSender)
            MsgBoxLayer.addRuleHintLayer(
		        TR("规则"),
		        {
		            TR("1.外功秘籍可以通过消耗铜币和璞玉进行升级，提升相关属性"),
		            TR("2.外功秘籍的等级受限于主角等级，主角等级越高则外功秘籍可升到的等级越高"),
		            TR("3.不同品质的外功秘籍可以参悟的武学招式数量不同，品质越高可参悟的招式就越多"),
		        }
    		)
        end
    })
    ruleBtn:setPosition(45, 952)
    bgSprite:addChild(ruleBtn)

	-- 底部背景框
	local bottomBg = ui.newScale9Sprite("c_19.png", cc.size(640, 545))
	bottomBg:setAnchorPoint(cc.p(0.5, 0))
	bottomBg:setPosition(320, 0)
	bgSprite:addChild(bottomBg)
	self.mBottomBg = bottomBg
	
	-- 灰色背景框
    local tempBgSprite = ui.newScale9Sprite("c_17.png", cc.size(610, 200))
    tempBgSprite:setAnchorPoint(cc.p(0.5, 1))
    tempBgSprite:setPosition(320, 480)
    bottomBg:addChild(tempBgSprite)

    -- 等级信息背景框
    _, self.currLvLabel = ui.newNodeBgWithTitle(bottomBg, cc.size(250, 180), TR("当前等级"), cc.p(150, 470), cc.p(0.5, 1))
    _, self.nextLvLabel = ui.newNodeBgWithTitle(bottomBg, cc.size(250, 180), TR("下一级"), cc.p(490, 470), cc.p(0.5, 1))

    -- 箭头
    local sprite = ui.newSprite("c_67.png")
    sprite:setPosition(315, 385)
    bottomBg:addChild(sprite)

	-- 升十次按钮
	self.mUpTenBtn = ui.newButton({
		normalImage = "c_33.png",
        text = TR("升十次"),
        textColor = Enums.Color.eWhite,
        position = cc.p(160, 170),
        clickAction = function()
        	self:lvUpBtnClicked(10)
        end
    })
    bottomBg:addChild(self.mUpTenBtn)

    -- 升级按钮
	self.mUpBtn = ui.newButton({
		normalImage = "c_28.png",
        text = TR("升级"),
        textColor = Enums.Color.eWhite,
        position = cc.p(480, 170),
        clickAction = function()
        	self:lvUpBtnClicked(1)
        end
    })
    bottomBg:addChild(self.mUpBtn)

    -- 初始选中外功秘籍的属性
	self:addPetAttrLabels()
end
	
-- 创建滑动控件
function PetLvUpLayer:addSliderView()
	-- 显示窗口大小
	local sliderViewSize = cc.size(640, 1136)

	self.mSliderView = ui.newSliderTableView({
		width = sliderViewSize.width,
        height = sliderViewSize.height,
        isVertical = false,
        selectIndex = self.mCurrIndex - 1,
        selItemOnMiddle = true,
        itemCountOfSlider = function(sliderView)
        	return #self.mPetList
        end,
        itemSizeOfSlider = function(sliderView)
            return sliderViewSize.width, sliderViewSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
        	-- 外功秘籍
        	local petItem = self.mPetList[index + 1]
        	local pet = Figure.newPet({
        		petId = petItem.Id,
		        needAction = true,
		        clickCallback = nil
	        })
	        pet:setPosition(320, 760)
	        itemNode:addChild(pet)

	        -- 显示外功秘籍名字
	        local petBase = PetModel.items[petItem.ModelId]
	        local petName = petBase.name
	        local valueLv = Utility.getQualityColorLv(petBase.quality)
        	local petNameColorH = Utility.getColorValue(valueLv, 2)
        	local tempStr = nil
        	local isIn, slotId = FormationObj:petInFormation(petItem.Id)
        	local strHeroName, heroNameColorH = nil
        	if isIn then
        		-- 获取主人名字
        		local slotInfo = FormationObj:getSlotInfoBySlotId(slotId)
        		local heroInfo = FormationObj:getSlotHeroInfo(slotInfo.HeroId)
        		strHeroName = ConfigFunc:getHeroName(heroInfo.ModelId, {IllusionModelId = heroInfo.IllusionModelId, heroFashionId = heroInfo.CombatFashionOrder})
        		heroNameColorH = Utility.getQualityColor(HeroModel.items[heroInfo.ModelId].quality, 2)

        		-- 构建标题字符串
        		tempStr = TR("等级%s%s%s", 
        			petItem.Lv,
        			petNameColorH,
        			petName
        		)
        	else
        		tempStr = TR("等级%s %s%s",
        			petItem.Lv,
        			petNameColorH,
        			petName
        		)
        	end
        	if petItem.Layer > 0 then
        		tempStr = tempStr .. string.format("%s+%s", Enums.Color.eYellowH, petItem.TotalNum - petItem.CanUseTalNum)
        	end
        	Figure.newNameAndStar({
				parent = itemNode,
				position = cc.p(320, 995),
				nameText = tempStr,
				starCount = valueLv,
				})
        	if (strHeroName ~= nil) then
		        local nameLabel = ui.newLabel({
		        	text = TR("装备于%s%s", heroNameColorH, strHeroName),
            		color = cc.c3b(0xff, 0xfb, 0xde),
		            outlineColor = cc.c3b(0x37, 0x30, 0x2c),
		            size = 24,
		        })
		        nameLabel:setAnchorPoint(cc.p(0, 0.5))
		        nameLabel:setPosition(20, 555)
		        itemNode:addChild(nameLabel, 1)
		    end
        end,
        selectItemChanged = function(sliderView, selectIndex)
        	print("---当前是第"..tostring(selectIndex + 1).."只外功秘籍---")
        	self.mCurrIndex = selectIndex + 1
        	self:addPetAttrLabels()

        	-- 左右箭头
        	if self.mLeftArrow and self.mRightArrow then
        		if selectIndex == 0 then
        			self.mLeftArrow:setVisible(false)
        			self.mRightArrow:setVisible(true)
        		elseif selectIndex == self.mPetNum - 1 then
        			self.mLeftArrow:setVisible(true)
        			self.mRightArrow:setVisible(false)
        		else
        			self.mLeftArrow:setVisible(true)
        			self.mRightArrow:setVisible(true)
        		end
        	end

        	-- 更新父页面数据
        	if self.mCallback then
        		self.mCallback(self.mPetList, self.mCurrIndex)
        	end
        end,
        onItemClecked = function(sliderView, onClickItemIndex)
        	print("---点击第"..tostring(onClickItemIndex + 1).."只外功秘籍---")
        end
	})
	self.mSliderView:setAnchorPoint(cc.p(0.5, 0.5))
	self.mSliderView:setPosition(sliderViewSize.width * 0.5, sliderViewSize.height * 0.5)
	self.mBgSprite:addChild(self.mSliderView)
end

-- 升级按钮点击处理
--[[
	num 			-- 形式上的升级次数
--]]
function PetLvUpLayer:lvUpBtnClicked(num)
    -- 外功秘籍等级高于玩家等级
	if self.mPetList[self.mCurrIndex].Lv >= PlayerAttrObj:getPlayerAttrByName("Lv") then
		ui.showFlashView({
			text = TR("外功秘籍等级不能超过主角等级")
		})
		return
	end

	-- 够不够升级1次
	if self:isMaterialEnough(1) then
		if num == 1 then
			self:requestPetLvUp(1)
		elseif num == 10 then
			local currLv = self.mPetList[self.mCurrIndex].Lv
			-- 最大升级次数
			local maxUpLv = 1

			local loopNum = math.min(PetModel.items[self.mPetList[self.mCurrIndex].ModelId].lvMax - currLv, 10)
			for i = 2, loopNum do
				-- 能升到的最大等级
				local maxLv = currLv + i
				-- 升到maxLv的花费
				local costNum = PetLvRelation.items[maxLv].baseExpTotal - PetLvRelation.items[currLv].baseExpTotal
				if Utility.isResourceEnough(ResourcetypeSub.eGold, costNum, false) 
					and Utility.isResourceEnough(ResourcetypeSub.ePetEXP, costNum, false) then
					maxUpLv = i
				else
					break
				end
			end

			-- 升级相应次数
			self:requestPetLvUp(maxUpLv)			
		end
	end
end

-- 升级所需的材料是否足够
--[[
	params:
	num 					-- 升级次数
--]]
function PetLvUpLayer:isMaterialEnough(num)
	local retEnough = true
	for _, v in ipairs(self.mCostList) do
		if not Utility.isResourceEnough(v.resourceTypeSub, v.num, false) then
			if v.resourceTypeSub == ResourcetypeSub.eGold then
                MsgBoxLayer.addGetGoldHintLayer()
            else
				MsgBoxLayer.addOKCancelLayer(
		            TR("您的%s%s%s不足，是否前往获取?", Enums.Color.eNormalGreenH, Utility.getGoodsName(v.resourceTypeSub, v.modelId), Enums.Color.eNormalWhiteH),
		            TR("提示"),
		            {
		                text = TR("是"),
		                clickAction = function(layerObj, btnObj)
		                    LayerManager.removeLayer(layerObj)

		                    -- 跳转到挑战六大派
	                        if ModuleInfoObj:moduleIsOpen(ModuleSub.eExpedition, true) then
	                            LayerManager.showSubModule(ModuleSub.eExpedition)
	                        end
		                end
		            },
		            {
		                text = TR("否")
		            }
		        )
			end

			retEnough = false
			break
		end
	end

	return retEnough
end

-- 添加外功秘籍属性标签
function PetLvUpLayer:addPetAttrLabels()
	-- 需要更新的标签对象，删除后再重新添加
	if self.mRemoveList and #self.mRemoveList ~= 0 then
		for k, v in pairs(self.mRemoveList) do
			v:removeFromParent()
		end
	end

	-- 获取当前等级和下一等级各个属性
	local petAttrList = self:getPetAttrList(self.mPetList[self.mCurrIndex])
	local nextLvAttrList = self:getPetAttrList(self.mPetList[self.mCurrIndex], true)
	-- 外功秘籍属性配置表
	local arrList = {
		[1] = {
			eValue = Fightattr.ePetAP,
			currValue = petAttrList.PetAP,
			nextValue = nextLvAttrList.PetAP or 0
		},
		[2] = {
			eValue = Fightattr.ePetDEF, 		
			currValue = petAttrList.PetDEF,
			nextValue = nextLvAttrList.PetDEF or 0
		},
		[3] = {
			eValue = Fightattr.ePetHP,
			currValue = petAttrList.PetHP,
			nextValue = nextLvAttrList.PetHP or 0
		}
	}

	self.mRemoveList = {}
	----------------当前属性-----------------
	-- 背景框
	local bottomBgSize = self.mBottomBg:getContentSize()
	self.currLvLabel:setString(self.currLvLabel.rawText .. " " .. "#FF974A" .. self.mPetList[self.mCurrIndex].Lv)
    
	-- 当前等级属性明细
	for i = 1, #arrList do
		local currLabel = ui.newLabel({
			text = string.format("%s: %s%d", 
				ConfigFunc:getViewNameByFightName(ConfigFunc:getFightNameByEnum(arrList[i].eValue)),
				"#C27000", 
				Utility.getAttrViewStr(arrList[i].eValue, arrList[i].currValue)
			),
			color = cc.c3b(0x46, 0x22, 0x0d),
			anchorPoint = cc.p(0, 0.5),
			x = bottomBgSize.width * 0.14,
			y = bottomBgSize.height * (0.64 -  (i - 1) * 0.07) + 50,
		})
		self.mBottomBg:addChild(currLabel)
		table.insert(self.mRemoveList, currLabel)
	end
	
	----------------下一级属性-----------------
	if table.nums(nextLvAttrList) ~= 0 then
		self.nextLvLabel:setString(self.nextLvLabel.rawText .. " " .. "#9BFF6A" .. nextLvAttrList.Lv)

		-- 下一等级属性明细
		for i = 1, #arrList do
			local nextLabel = ui.newLabel({
				text = string.format("%s: %s%d", 
					ConfigFunc:getViewNameByFightName(ConfigFunc:getFightNameByEnum(arrList[i].eValue)),
					"#258711", 
					Utility.getAttrViewStr(arrList[i].eValue, arrList[i].nextValue)
				),
				color = cc.c3b(0x46, 0x22, 0x0d),
				anchorPoint = cc.p(0, 0.5),
				x = bottomBgSize.width * 0.63,
				y = bottomBgSize.height * (0.64 -  (i - 1) * 0.07) + 50
			})
			self.mBottomBg:addChild(nextLabel)
			table.insert(self.mRemoveList, nextLabel)
		end

		-- 升级一次的消耗 = (下一级的基础经验 - 当前等级的基础经验) * 外功秘籍的经验系数，注：升级只消耗铜钱和妖灵，且 铜钱:妖灵 = 1:1
		local petItem = PetModel.items[self.mPetList[self.mCurrIndex].ModelId]
		local currLv = self.mPetList[self.mCurrIndex].Lv
		local nextLv = nextLvAttrList.Lv
		local costNum = (PetLvRelation.items[nextLv].baseExpTotal - PetLvRelation.items[currLv].baseExpTotal) * petItem.expR
		local costList = {
			[1] = {
				resourceTypeSub = ResourcetypeSub.eGold,
				num = costNum
			},
			[2] = {
				resourceTypeSub = ResourcetypeSub.ePetEXP,
				num = costNum
			}
		}
		local costLabel = ui.newLabel{
			text = string.format("{%s}%s%s   {%s}%s%s",
				Utility.getResTypeSubImage(costList[2].resourceTypeSub),
				Utility.getOwnedGoodsCount(costList[2].resourceTypeSub) < costList[2].num and Enums.Color.eRedH or Enums.Color.eDarkGreenH,
				Utility.numberWithUnit(costList[2].num),
				Utility.getResTypeSubImage(costList[1].resourceTypeSub),
				Utility.getOwnedGoodsCount(costList[1].resourceTypeSub) < costList[1].num and Enums.Color.eRedH or Enums.Color.eDarkGreenH,
				Utility.numberWithUnit(costList[1].num)
			),
			align = ui.TEXT_ALIGN_CENTER,
			x = 470, 
			y = bottomBgSize.height * 0.37 + 30
		}
		self.mBottomBg:addChild(costLabel)
		table.insert(self.mRemoveList, costLabel)

		self.mCostList = costList

		-- 可以继续升级
		self.mUpBtn:setEnabled(true)
		self.mUpTenBtn:setEnabled(true)
	else
		-- 提示标签
		local tipLabel = ui.newLabel({
			text = TR("已经达到\n等级上限"),
			color = Enums.Color.eRed,
			x = bottomBgSize.width * 0.77,
			y = bottomBgSize.height * 0.67
		})
		self.mBottomBg:addChild(tipLabel)
		table.insert(self.mRemoveList, tipLabel)

		-- 不能再继续升级
		self.mUpBtn:setEnabled(false)
		self.mUpTenBtn:setEnabled(false)
	end
end

-- 获取外功秘籍的属性列表
--[[
	params:
	petInfo 					-- 外功秘籍信息
	isNextLvAttr 				-- 是否返回下一等级的属性列表
--]]
function PetLvUpLayer:getPetAttrList(petInfo, isNextLvAttr)
	-- 外功秘籍模型
	local petModel = PetModel.items[petInfo.ModelId]
	-- 属性列表
    local atrrList = {}


    -- 基础加成
	if not isNextLvAttr then
		atrrList.PetAP = petModel.APBase + petModel.APBase * petModel.upR * (petInfo.Lv - 1)  		-- 攻击
		atrrList.PetDEF = petModel.DEFBase + petModel.DEFBase * petModel.upR * (petInfo.Lv - 1)  	-- 防御
		atrrList.PetHP = petModel.HPBase + petModel.HPBase * petModel.upR * (petInfo.Lv - 1)  		-- 血量
	else
		-- 当前已是最大等级
		if petInfo.Lv >= petModel.lvMax then
			return atrrList
		end

		atrrList.Lv = petInfo.Lv + 1
		atrrList.PetAP = petModel.APBase + petModel.APBase * petModel.upR * (petInfo.Lv + 1 - 1)  		-- 攻击
		atrrList.PetDEF = petModel.DEFBase + petModel.DEFBase * petModel.upR * (petInfo.Lv + 1 - 1)  	-- 防御
		atrrList.PetHP = petModel.HPBase + petModel.HPBase * petModel.upR * (petInfo.Lv + 1 - 1)  		-- 血量
	end


	-- 参悟加成
	local tempList = {}
    for i, talInfo in ipairs(petInfo.TalentInfoList) do
        local talModel = PetTalTreeModel.items[talInfo.TalentID]
        local attrs = Utility.analysisStrAttrList(talModel.perAttrStr)
        for j, attr in ipairs(attrs) do
            tempList[attr.fightattr] = tempList[attr.fightattr] or 0
            tempList[attr.fightattr] = tempList[attr.fightattr] + attr.value * talInfo.TalentNum
        end
    end

    -- 总加成
    atrrList.PetAP = atrrList.PetAP + (tempList[Fightattr.eAP] or 0)
    atrrList.PetDEF = atrrList.PetDEF + (tempList[Fightattr.eDEF] or 0)
    atrrList.PetHP = atrrList.PetHP + (tempList[Fightattr.eHP] or 0)

    return atrrList
end

-- 播放升级特效
function PetLvUpLayer:playLevelUpAction()
    local posX, posY = 320, 600
    ui.newEffect({
        parent = self.mBgSprite,
        effectName = "effect_ui_chongwushengji",
        position = cc.p(posX, posY),
        loop = false,
        endRelease = true,
    })
end

-------------------网络相关-----------------------
-- 请求服务器，升级外功秘籍
--[[
	params:
	num 		-- 要升级的次数
--]]
function PetLvUpLayer:requestPetLvUp(num)
    HttpClient:request({
        moduleName = "Pet", 
        methodName = "PetLvUp", 
        svrMethodData = {self.mPetList[self.mCurrIndex].Id, num},
        callbackNode = self, 
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
            	return
            end

            local oldPetInfo = self.mPetList[self.mCurrIndex]
            local newPetInfo = data.Value
            -- 更新数据
            self.mPetList[self.mCurrIndex] = data.Value
            -- 不能叠加的东西必须手动修改缓存
            PetObj:modifyPetItem(data.Value)

            -- 升级动画
            self:playLevelUpAction()
            
            -- 更新页面
            self.mSliderView:refreshItem(self.mCurrIndex - 1)
           	self:addPetAttrLabels()

           	-- 父页面数据更新
           	if self.mCallback then
           		self.mCallback(self.mPetList, self.mCurrIndex)
           	end
        end
    })
end


return PetLvUpLayer
