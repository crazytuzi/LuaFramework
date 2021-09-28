--[[
文件名：MysteryshopCopyLayer.lua
描述： 黑市复制法阵页面
创建人：lengjiazhi
创建时间：2016.9.26
--]]

local MysteryshopCopyLayer = class("MysteryshopCopyLayer", function(params)
	return display.newLayer()
end)
--构造函数
--[[
	参数：
	params: 选中的复制品的参数
--]]
function MysteryshopCopyLayer:ctor(params)
	self.mParam_ = params

	if self.mIsSelect == nil then	
		self.mIsSelect = false
	end

	self:init()
	self:refreshCard(self.mParam_)

	self:requestCopyTimes()
end
-- 初始化ui
function MysteryshopCopyLayer:init()
	--背景图
	local bgSprite = ui.newSprite("jbg_01.jpg")
	bgSprite:setPosition(320, 568)
	self:addChild(bgSprite)
	
	-- 炉子主体
	-- local sprite = ui.newSprite("fzfz_04.png")
	-- sprite:setPosition(320, 610)
	-- self:addChild(sprite, 1)

	-- --炉子配件1
	-- local sprite = ui.newSprite("fzfz_03.png")
	-- sprite:setPosition(530, 705)
	-- self:addChild(sprite, 1)
	-- --炉子配件2
	-- local sprite = ui.newSprite("fzfz_05.png")
	-- sprite:setPosition(110, 705)
	-- self:addChild(sprite, 1)

	-- --石头1
	-- local sprite = ui.newSprite("fzfz_07.png")
	-- sprite:setPosition(130, 440)
	-- self:addChild(sprite, 1)

	-- --石头2
	-- local sprite = ui.newSprite("fzfz_06.png")
	-- sprite:setPosition(520, 440)
	-- self:addChild(sprite, 1)

	--规则按钮
	local button = ui.newButton({
		normalImage = "c_72.png",
		clickAction = function ()
			MsgBoxLayer.addRuleHintLayer(
				TR("规则"),
				{
				[1] = TR("1、消耗神魂可以复制神将碎片"),
				[2] = TR("2、提升VIP等级可以增加每日的复制次数"),
				-- [3] = TR("zcacasd")
				})
		end,
		})
	button:setPosition(50, 930)
	self:addChild(button)

	--提示文字
	local Label = ui.createLabelWithBg({
		bgFilename = "jbg_03.png",   -- 背景图片的文件名
        labelStr = TR("复制目标"),
        fontSize = 22,
        color = Enums.Color.eNormalWhite,
        offset = 45,
		})
	Label:setPosition(120, 675)
	self:addChild(Label, 1)

	--提示文字
	local Label = ui.createLabelWithBg({
		bgFilename = "jbg_03.png",   -- 背景图片的文件名
	    labelStr = TR("复制获得"),
	    fontSize = 22,
	    color = Enums.Color.eNormalWhite,
	    offset = 35,
	})
	Label:setPosition(535, 675)
	self:addChild(Label, 1)
	self:bottomView()

	-- self:playEffect()
	-- 待机特效
	self.mStandEffect = self:playAnimation("putong", cc.p(320, 320), 0)
end
--下方控件
function MysteryshopCopyLayer:bottomView()
	--复制按钮
	self.mCopyBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("复制"),
		clickAction = function ()
			self:requestMysteryshopCopy(self.mParam_)
		end
		})
	self.mCopyBtn:setPosition(320, 180)
	self:addChild(self.mCopyBtn, 1)
	self.mCopyBtn:setEnabled(self.mParam_ and true or false)

	--剩余次数
	self.mCountLabel = ui.newLabel({
		text = TR("今日剩余 %s/%s 次", 0, 0),
		size = 22,
		color = Enums.Color.eNormalWhite,
		})
	self.mCountLabel:setPosition(320, 120)
	self:addChild(self.mCountLabel, 1)

	--复制消耗
	self.mCostLabel = ui.createDaibiView({
		resourceTypeSub = ResourcetypeSub.eHeroCoin,
        number = 0,
        fontColor = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack,
		})
	self.mCostLabel:setPosition(320, 240)
	self:addChild(self.mCostLabel, 1)

	--目标卡牌
	self.mTargetCardNode = CardNode.createCardNode({
		allowClick = true,
		cardShowAttrs = {CardShowAttr.eBorder},
        onClickCallback = function ()
	        local tempData = {
	        	callback = function (selectLayer, selectdata)
		        	local tempStr = "mysteryshop.MysteryShopLayer"
		        	local tempData = {
						tabPageTag = ModuleSub.eMysteryshopCopy,
						data = selectdata
					}
					LayerManager.setRestoreData(tempStr, tempData)
	                LayerManager.removeLayer(selectLayer)
	        	end
	    	}
	    	LayerManager.addLayer({
	    		name = "mysteryshop.MysteryShopSelectLayer",
		        data = tempData
    		})
    	end
	})
	self.mTargetCardNode:setPosition(130, 580)
	self.mTargetCardNode:setEmpty({}, "c_68.png", "c_22.png")
	self:addChild(self.mTargetCardNode, 1)
	local tempSize = self.mTargetCardNode:getContentSize()
	local tempSprite = ui.createGlitterSprite({
		filename = "c_37.png",
        parent = self.mTargetCardNode,
        position = cc.p(tempSize.width / 2, tempSize.height / 2),
        actionScale = 1.2,
	})
	
	--结果卡片
	self.mResultCardNode = CardNode.createCardNode({
			cardShowAttrs = {CardShowAttr.eBorder},
		})
	self.mResultCardNode:setPosition(525, 580)
	self.mResultCardNode:setEmpty({}, "c_68.png")
	self:addChild(self.mResultCardNode, 1)
end

--刷新页面
function MysteryshopCopyLayer:refreshCard(data)
	if data then
		local attr = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum}
		self.mTargetCardNode:setCardData({
			resourceTypeSub = Utility.getTypeByModelId(data.ModelId),
        	modelId = data.ModelId,
    		allowClick = true,
	        onClickCallback = function ()
	        	self.mParam_ = nil
	        	self:refreshCard()
	        	self.mCopyBtn:setEnabled(false)
	        end
    	})
		--dump(data.ModelId)
		self.mResultCardNode:setCardData({
			num = data.Num * 2,
			resourceTypeSub = Utility.getTypeByModelId(data.ModelId),
        	modelId = data.ModelId,
        	cardShowAttrs = attr,
        	allowClick = false
    	})

		local tempStr
		if Utility.getTypeByModelId(data.ModelId) == ResourcetypeSub.eFunctionProps then
			self.mTargetCardNode:setCardData({
				num = data.Num,
				resourceTypeSub = Utility.getTypeByModelId(data.ModelId),
	        	modelId = data.ModelId,
	        })
			self.mResultCardNode:setCardData({
				num = data.Num * 2,
				resourceTypeSub = Utility.getTypeByModelId(data.ModelId),
	        	modelId = data.ModelId,
	        })
			local tempTable = Utility.analysisStrResList(MysteryshopCopyConfig.items[1].copyOneBreakDanNeed)
			tempStr = data.Num * tempTable[1].num
		elseif Utility.getTypeByModelId(data.ModelId) == ResourcetypeSub.eHero then
			local tempQuality = HeroModel.items[data.ModelId].quality
			if tempQuality == 13 then
				local tempTable = Utility.analysisStrResList(MysteryshopCopyConfig.items[1].copy13manNeed)
				tempStr = tempTable[1].num
			elseif tempQuality == 15 then
				local tempTable = Utility.analysisStrResList(MysteryshopCopyConfig.items[1].copy15manNeed)
				tempStr = tempTable[1].num
			end
		end
		self.mCostLabel.setNumber(tempStr)
	else
		self.mTargetCardNode:setCardData({
			allowClick = true,
			cardShowAttrs = {CardShowAttr.eBorder},
	        onClickCallback = function ()
		        local tempData = {
	        		callback = function (selectLayer, selectdata)
			        	local tempStr = "mysteryshop.MysteryShopLayer"
			        	local tempData = {
							tabPageTag = ModuleSub.eMysteryshopCopy,
							data = selectdata
						}
						LayerManager.setRestoreData(tempStr, tempData)
		                LayerManager.removeLayer(selectLayer)
	        		end
		    	}
		    	LayerManager.addLayer({
		    		name = "mysteryshop.MysteryShopSelectLayer",
			        data = tempData
	    		})
    		end
    	})
    	self.mTargetCardNode:setEmpty({}, "c_68.png", "c_22.png")
    	local tempSize = self.mTargetCardNode:getContentSize()
		local tempSprite = ui.createGlitterSprite({
			filename = "c_22.png",
	        parent = self.mTargetCardNode,
	        position = cc.p(tempSize.width / 2, tempSize.height / 2),
	        actionScale = 1.2,
		})

		self.mResultCardNode:setCardData({
				cardShowAttrs = {CardShowAttr.eBorder},
        	})
		self.mResultCardNode:setEmpty({}, "c_68.png")

		self.mCostLabel.setNumber(0)
	end
end

-- 播放特效
--[[
	animation: 动画名
	pos: 位置
	zorder: 层级
]]
function MysteryshopCopyLayer:playAnimation(animation, pos, zorder)
	local animation = animation or "putong"

	local effect = ui.newEffect({
		parent = self,
		effectName = "effect_ui_fuzhifazhen",
		animation = animation,
		position = pos,
		zorder = zorder,
		loop = true,
		endRelease = true,
	})

	return effect
end

--
function MysteryshopCopyLayer:playEffect(response, callback)
	local function completeEffect()
		for i = 1, 2 do
			ui.newEffect({
				parent = self,
				effectName = "effect_ui_fuzhifazhen",
				animation = "di",
				position = cc.p(i == 1 and 135 or 518, 485),
				zorder = 1,
				rotationY = i == 1 and true or false,
				loop = false,
				endRelease = true,
			})
			ui.newEffect({
				parent = self,
				effectName = "effect_ui_fuzhifazhen",
				animation = "guangzhu",
				position = cc.p(i == 1 and 135 or 518, 485),
				zorder = 1,
				rotationY = i == 1 and true or false,
				loop = false,
				endRelease = true,
				completeListener = function()
					if callback then
						callback(response)
					end
				end
			})
		end
	end

	ui.newEffect({
		parent = self,
		effectName = "effect_ui_fuzhifazhen",
		animation = "chenggong",
		position = cc.p(320, 320),
		loop = false,
		endRelease = true,
		completeListener = function()
			-- 播放复制音效
			MqAudio.playEffect("sound_fuzhifazhen_fuzhi.mp3")
			-- 播放复制特效
			completeEffect()
			-- 播放待机动画
			self.mStandEffect = self:playAnimation("putong", cc.p(320, 320), 0)
		end
	})
end

-- ==========================网络请求===============================
--复制请求函数
function MysteryshopCopyLayer:requestMysteryshopCopy(data)
	local tempList = {}
	table.insert(tempList, data.Id)
	if Utility.getTypeByModelId(data.ModelId) == ResourcetypeSub.eFunctionProps then
		table.insert(tempList, data.Num)
	elseif Utility.getTypeByModelId(data.ModelId) == ResourcetypeSub.eHero then
		table.insert(tempList, 1)
	end
	HttpClient:request({
		moduleName = "MysteryshopCopy",
		methodName = "Copy",
		svrMethodData = tempList,
		callbackNode = self,
		callback = function (response)
			if not response or response.Status ~= 0 then 
				return 
			end

			-- 禁用复制按钮
			self.mCopyBtn:setEnabled(false)
			-- 判断待机特效是否存在
			if not tolua.isnull(self.mStandEffect) then
				self.mStandEffect:removeFromParent()
				self.mStandEffect = nil
			end

			-- 播放复制动画
			self:playEffect(response, function(response)
				-- 特殊处理,显示操作和掉落综合结果:显示的所有有数量显示的奖励的数量x2
				local dropResourceList = clone(response.Value.BaseGetGameResourceList)
				for _, item in pairs(dropResourceList) do
					for i, v in pairs(item) do
						for j, k in pairs(v) do 
							if k.Num then
								k.Num = k.Num * 2
							else
								k.Num = 2
							end
						end
					end
				end

				self:addGameDropLayer(
					dropResourceList,
					{}, 
					TR("获得以下物品"), 
					TR("复制"),
					{{text = TR("确定")}},
					{}
				)
				local lastStr = response.Value.CopyInfo.TotalCount - response.Value.CopyInfo.UseCount
				self.mCountLabel:setString(TR("今日剩余 %s/%s 次", lastStr, response.Value.CopyInfo.TotalCount))
				-- 恢复复制按钮
				self.mCopyBtn:setEnabled(true)
				-- 清空界面
				self:refreshCard()
			end)
		end
	})
end

function MysteryshopCopyLayer:addGameDropLayer(baseDrop, extraDrop, msgText, title, btnInfos, closeBtnInfo)
    -- 物品掉落提示窗体的DIY函数
    local function DIYFuncion(layerObj, bgSprite, bgSize)
        -- 重新设置提示信息的位置
        local tempLabel = layerObj:getMsgLabel()
        tempLabel:setAnchorPoint(cc.p(0.5, 1))
        tempLabel:setPosition(bgSize.width / 2, bgSize.height - 90)

        -- 需要展示的物品列表
        local resourceList = Utility.analysisGameDrop(baseDrop, extraDrop)
        -- 特殊处理：所有没有num属性的card均添加num字段设置为2
        for _, item in pairs(resourceList) do 
        	if not item.num then
        		item.num = 2
        	end
        	item.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum}
        end
        -- 创建奖励物品列表
        local cardListNode = ui.createCardList({
            maxViewWidth = bgSize.width - 60, 
            space = 15, 
            cardDataList = resourceList,
            allowClick = true, 
            needArrows = true,
        })
        cardListNode:setAnchorPoint(cc.p(0.5, 0))
        cardListNode:setPosition(bgSize.width / 2 , 120)
        bgSprite:addChild(cardListNode)
    end

    local tempData = {
        bgSize = cc.size(572, 400),
        title = title ~= "" and title or TR("奖励"),
        msgText = msgText ~= "" and msgText or TR("获得以下物品"),
        btnInfos = next(btnInfos or {}) and btnInfos or {{text = TR("确定"),}, },
        closeBtnInfo = closeBtnInfo,
        DIYUiCallback = DIYFuncion,
    }
    return LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer", 
        data = tempData, 
        cleanUp = false, 
        needRestore = true
    })
end

--获取复制次数信息
function MysteryshopCopyLayer:requestCopyTimes()
	HttpClient:request({
		moduleName = "MysteryshopCopy",
		methodName = "GetInfo",
		svrMethodData = {},
		callbackNode = self,
		callback = function (response)
			if response.Status == 0 then
				local lastStr = response.Value.TotalCount - response.Value.UseCount
				self.mCountLabel:setString(TR("今日剩余 %s/%s 次", lastStr, response.Value.TotalCount))
			else
				return
			end
		end
	})
end

return MysteryshopCopyLayer