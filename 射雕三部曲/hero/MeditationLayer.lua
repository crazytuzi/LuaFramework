--[[
    文件名: MeditationLayer.lua
    描述: 冥想界面
    创建人: lengjiazhi
    创建时间: 2018.06.23
-- ]]
local MeditationLayer = class("MeditationLayer", function(params)
	return display.newLayer()
end)

function MeditationLayer:ctor(params)
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	--选择道具的列表
	self.mSelectInfo = params.selectInfo or {[1] = 0,[2] = 0,[3] = 0,}

	self:initUI()
   	self:createBottomView() 
   	self:autoRefresh()
	self:requestGetInfo()
end

function MeditationLayer:initUI()
	--背景图
	local bgSprite = ui.newSprite("nl_15.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	--标题
	local titleSprite = ui.newSprite("nl_20.png")
	titleSprite:setPosition(320, 1020)
	self.mParentLayer:addChild(titleSprite)

	-- 低盘
	local downSprite = ui.newSprite("nl_42.png")
	downSprite:setPosition(320, 600)
	self.mParentLayer:addChild(downSprite)

	local mainPic = ui.newSprite("nl_40.png")
	mainPic:setPosition(320, 760)
	self.mParentLayer:addChild(mainPic)

	local eff = ui.newEffect({
			parent = self.mParentLayer,
            effectName = "effect_ui_neili_qi",
            -- animation  = "dianji",
            position = cc.p(320, 780),
            loop = true,
		})

	--底框背景图
	local bottomBG = ui.newSprite("nl_16.png")
	bottomBG:setPosition(320, 420)
	self.mParentLayer:addChild(bottomBG)

	local tipLabel = ui.newLabel({
		text = TR("在冥想前消耗静心丸可提升收益"),
		outlineColor = Enums.Color.eBlack,
		size = 20,
		})
	tipLabel:setPosition(320, 545)
	self.mParentLayer:addChild(tipLabel)

	--返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 1035),
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn, 1000)
	-- 规则按钮
	local btnRule = ui.newButton({
	    normalImage = "c_72.png",
	    anchorPoint = cc.p(0.5, 0.5),
	    position = cc.p(50, 1040),
	    clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                TR("1.70级开启冥想"),
                TR("2.冥想可获得强化内力需要的阴、阳、邪三种气劲"),
                TR("3.气劲会在开始冥想后随着时间自动累积，中途可随时收取"),
                TR("4.可使用静心丸提升冥想的收益"),
        	})
	    end
	})
	self.mParentLayer:addChild(btnRule, 5)

    -- 内力按钮
    local neiliBtn = ui.newButton({
        normalImage = "nl_24.png",
        position = cc.p(590, 600),
        clickAction = function(pSender)
            LayerManager.addLayer({
            		name = "hero.HeroNeiliHomeLayer",
            	})
        end
    })
    self.mParentLayer:addChild(neiliBtn, 1)

    -- 创建底部导航和顶部玩家信息部分
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)
end

--冥想基本信息
local baseInfo = {
	[1] = {
		pic = "nl_27.png",
		eff = "effect_ui_neili_yinhuo",
		eff2 = "effect_ui_minxiang_lan",
		name = "YinQi",
		resGetType = ResourcetypeSub.eYinQi,
	},
	[2] = {
		pic = "nl_29.png",
		eff = "effect_ui_neili_yanghuo",
		eff2 = "effect_ui_minxiang_huang",
		name = "YangQi",
		resGetType = ResourcetypeSub.eYangQi,
	},
	[3] = {
		pic = "nl_28.png",
		eff = "effect_ui_neili_xiehuo",
		eff2 = "effect_ui_minxiang_zi",
		name = "XieQi",
		resGetType = ResourcetypeSub.eXieQi,
	},
}
--创建下方显示
function MeditationLayer:createBottomView()
	self.mBottomInfo = {}
	for i,v in ipairs(baseInfo) do
		--冥想静态图
		local staticPic = ui.newSprite(v.pic)
		staticPic:setPosition(115 + (i-1)*200, 430)
		self.mParentLayer:addChild(staticPic)

		local resNumLabel = ui.newLabel()
		resNumLabel:setPosition(115 + (i-1)*200, 140)
		self.mParentLayer:addChild(resNumLabel)

		--选择道具状态的父节点
		local chooseNode = cc.Node:create()
		chooseNode:setPosition(115 + (i-1)*200, 220)
		self.mParentLayer:addChild(chooseNode)

		--卡牌头像
		local emptyCard = CardNode.createCardNode({cardShowAttrs = {CardShowAttr.eBorder}})
		emptyCard:setClickCallback(function()
			self:selectLayer(i)
		end)
		emptyCard:setEmpty({CardShowAttr.eBorder}, "c_04.png")
		emptyCard:showGlitterAddMark()
		emptyCard:setPosition(0, 70)
		chooseNode:addChild(emptyCard)
		chooseNode.emptyCard = emptyCard
		
		local tipLabel = ui.newLabel({
			text = TR("点击选择增益道具"),
			color = cc.c3b(0xf8, 0x76, 0x2a),
			size = 18,
			})
		tipLabel:setPosition(0, 0)
		chooseNode:addChild(tipLabel)
		chooseNode.tipLabel = tipLabel

		local startBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("开始冥想"),
			clickAction = function()
				-- 调用接口
				self:requestStartMingxiang(i)
			end
			})
		startBtn:setPosition(0, -35)
		startBtn:setScale(0.8)
		chooseNode:addChild(startBtn)
		chooseNode:setVisible(false)

		--冥想状态的父节点
		local meditatingNode = cc.Node:create()
		meditatingNode:setPosition(115 + (i-1)*200, 220)
		self.mParentLayer:addChild(meditatingNode)

		--火的特效
		local effect = ui.newEffect({
                parent = meditatingNode,
                effectName = v.eff,
                -- animation  = "dianji",
                position = cc.p(0, 200),
                loop = true,
            })

		--如果有使用道具显示加成
		local buffTipLabel = ui.newLabel({
			text = TR("九阴"),
			color = cc.c3b(0xf8, 0x76, 0x2a),
			size = 20,
			})
		buffTipLabel:setPosition(0, 100)
		meditatingNode:addChild(buffTipLabel)
		meditatingNode.buffTipLabel = buffTipLabel

		--累计文本
		local cumulativeLabel = ui.newLabel({
			text = TR("累计阴气：#e8c23c%s", 99999),
			size = 18,
			})
		cumulativeLabel:setPosition(0, 65)
		meditatingNode:addChild(cumulativeLabel)
		meditatingNode.cumulativeLabel = cumulativeLabel

		--倒计时文本
		local saveTimeLabel = ui.newLabel({
			text = TR("#5fcc50%s%s后获得全部收益", "00:00:00", Enums.Color.eWhiteH),
			size = 17,
			})
		saveTimeLabel:setPosition(0, 35)
		meditatingNode:addChild(saveTimeLabel)
		meditatingNode.saveTimeLabel = saveTimeLabel

		local endBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("收起气劲"),
			clickAction = function()
	           	-- 播放特效
	           	ui.newEffect({
					parent = meditatingNode,
					effectName = baseInfo[i].eff2,
					position = cc.p(0, -35),
					zorder = 1,
					loop = false,
				})
				-- 调用接口
				self:requestEndMingxiang(i)
			end
			})
		endBtn:setPosition(0, -35)
		endBtn:setScale(0.8)
		meditatingNode:addChild(endBtn)

		meditatingNode:setVisible(false)

		self.mBottomInfo[i] = {}
		self.mBottomInfo[i].chooseNode = chooseNode
		self.mBottomInfo[i].meditatingNode = meditatingNode
		self.mBottomInfo[i].resNumLabel = resNumLabel
	end
end

--刷新下方显示
function MeditationLayer:refreshBottomView()
	for i,v in ipairs(self.mMeditationInfo) do
		local curNode = self.mBottomInfo[i]
		curNode.chooseNode:setVisible(not v.IfMingxiang)
		curNode.meditatingNode:setVisible(v.IfMingxiang)

		local resNum = PlayerAttrObj:getPlayerAttr(baseInfo[i].resGetType)
		local resPic = Utility.getDaibiImage(baseInfo[i].resGetType)
		curNode.resNumLabel:setString(string.format("{%s}%s", resPic, resNum))

		if v.IfMingxiang then
			curNode.meditatingNode.buffTipLabel:setVisible(v.UseGoodsModelId ~= 0)
			if v.UseGoodsModelId ~= 0 then
				local buffInfo = NeiliMingxiangDoubleRelation.items[v.UseGoodsModelId]
				curNode.meditatingNode.buffTipLabel:setString(TR("%s+%d%%收益", buffInfo.name, buffInfo.outputR / 100))
			else
				curNode.meditatingNode.cumulativeLabel:setPosition(0, 85)
				curNode.meditatingNode.saveTimeLabel:setPosition(0, 55)
			end
			if next(v.GetResourceList) ~= nil then
				
				local resName = ResourcetypeSubName[v.GetResourceList[1].ResourceTypeSub]
				curNode.meditatingNode.cumulativeLabel:setString(TR("累计%s：#e8c23c%s",resName, v.GetResourceList[1].Count))
			else
				local tempModel = Utility.analysisStrResList(NeiliMingxiangModel.items[i].tenMinuteOutput)
				local resName = ResourcetypeSubName[tempModel[1].resourceTypeSub]
				curNode.meditatingNode.cumulativeLabel:setString(TR("累计%s：#e8c23c%s",resName, 0))
			end
			local function upDateTime()
			 	local timeLeft = v.EndTime - Player:getCurrentTime()
			    if timeLeft > 0 then
			        curNode.meditatingNode.saveTimeLabel:setString(TR("#5fcc50%s%s后获得全部收益", MqTime.formatAsDay(timeLeft), Enums.Color.eWhiteH))
			        -- print("更新时间")
			    else
			        curNode.meditatingNode.saveTimeLabel:setString(TR("#5fcc50已完成冥想"))
			        
			        -- 停止倒计时
			        if curNode.schedule then
			            curNode.meditatingNode:stopAction(curNode.schedule)
			            curNode.schedule = nil
			        end
			    end
			end
			if curNode.schedule then
				curNode.meditatingNode:stopAction(curNode.schedule)
	            curNode.schedule = nil
	        end
			curNode.schedule = Utility.schedule(curNode.meditatingNode, upDateTime, 1.0)
		else
			if self.mSelectInfo[i] ~= 0 then
				curNode.chooseNode.emptyCard:setCardData({
					resourceTypeSub = Utility.getTypeByModelId(self.mSelectInfo[i]), 
        			modelId = self.mSelectInfo[i],  
				})
				curNode.chooseNode.emptyCard:setClickCallback(function()
					self.mSelectInfo[i] = 0
					self:refreshBottomView()
				end)
			else
				curNode.chooseNode.emptyCard:setEmpty({CardShowAttr.eBorder}, "c_04.png")
				curNode.chooseNode.emptyCard:showGlitterAddMark()
				curNode.chooseNode.emptyCard:setClickCallback(function()
					self:selectLayer(i)
				end)
			end
			curNode.chooseNode.tipLabel:setVisible(self.mSelectInfo[i] == 0)
		end
	end
end

--选择道具弹窗
function MeditationLayer:selectLayer(index)
 	--弹窗
    local popLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(598, 600),
        title = TR("选择道具"),
        closeAction = function(pSender)
            LayerManager.removeLayer(pSender)
        end,
    })
    self:addChild(popLayer)
    self.mPopLayer = popLayer
    self.mPopBgSprite = popLayer.mBgSprite

    local goodsInfo = {}
    for i,v in pairs(NeiliMingxiangDoubleRelation.items) do
    	table.insert(goodsInfo, v)
    end
    table.sort(goodsInfo, function (a, b)
    	local modelA = GoodsModel.items[a.goodsModelID]
    	local modelB = GoodsModel.items[b.goodsModelID]
    	if modelA.quality ~= modelB.quality then
    		return modelA.quality < modelB.quality
    	end
    end)

    -- 选择列表
    local goodsListView = ccui.ListView:create()
    goodsListView:setDirection(ccui.ScrollViewDir.vertical)
    goodsListView:setBounceEnabled(true)
    goodsListView:setContentSize(cc.size(530, 500))
    goodsListView:setItemsMargin(5)
    goodsListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    goodsListView:setAnchorPoint(cc.p(0.5, 0.5))
    goodsListView:setPosition(299, 280)
    self.mPopBgSprite:addChild(goodsListView)

    for i,v in ipairs(goodsInfo) do
    	local goodsModel = GoodsModel.items[v.goodsModelID]
    	local count = Utility.getOwnedGoodsCount(goodsModel.typeID, goodsModel.ID)

    	-- 去掉已选择的数量
    	local hadSelCount = 0
    	for _, modelId in pairs(self.mSelectInfo) do
    		if modelId == goodsModel.ID then
    			hadSelCount = hadSelCount + 1
    		end
    	end
    	count = count - hadSelCount

    	local layout = ccui.Layout:create()
        layout:setContentSize(530, 140)

        local itemBgSprite = ui.newScale9Sprite("c_18.png", cc.size(526, 136))
        itemBgSprite:setPosition(265, 70)
        layout:addChild(itemBgSprite)

        local cardHead = CardNode.createCardNode({
        	resourceTypeSub = goodsModel.typeID,
        	modelId = v.goodsModelID,
        	allowClick = false,
        	cardShowAttrs = {CardShowAttr.eBorder}
        	})
        cardHead:setPosition(80, 70)
        layout:addChild(cardHead)

        local tempColor = Utility.getQualityColor(goodsModel.quality, 1)
        local nameLabel = ui.newLabel({
        	text = v.name,
        	color = tempColor
        	})
        nameLabel:setAnchorPoint(0, 0.5)
        nameLabel:setPosition(150, 100)
        layout:addChild(nameLabel)

        local haveLabel = ui.newLabel({
        	text = TR("拥有：%s", count),
        	color = Enums.Color.eBlack,
        	})
        haveLabel:setAnchorPoint(0, 0.5)
        haveLabel:setPosition(150, 70)
        layout:addChild(haveLabel)

        local buffLabel = ui.newLabel({
        	text = TR("收益加成：%s%%", v.outputR / 100),
        	color = Enums.Color.eBlack,
        	})
        buffLabel:setAnchorPoint(0, 0.5)
        buffLabel:setPosition(150, 40)
        layout:addChild(buffLabel)

        if count > 0 then
        	local selectBtn = ui.newButton({
        		text = TR("选择"),
        		normalImage = "c_28.png",
        		clickAction = function()
        			self.mSelectInfo[index] = goodsModel.ID
        			self:refreshBottomView()
        			LayerManager.removeLayer(self.mPopLayer)
        		end
        		})
        	selectBtn:setPosition(450, 70)
        	layout:addChild(selectBtn)
        else
        	local gotoGetBtn = ui.newButton({
        		text = TR("获取途径"),
        		normalImage = "c_28.png",
        		clickAction = function()
        			LayerManager.addLayer({
			            name = "hero.DropWayLayer",
			            data = {
			                resourceTypeSub = goodsModel.typeID,
			                modelId = goodsModel.ID
			            },
			            cleanUp = false,
			        })
        		end
        		})
        	gotoGetBtn:setPosition(450, 70)
        	layout:addChild(gotoGetBtn)
        end

        goodsListView:pushBackCustomItem(layout)
    end
end

--自动刷新界面
function MeditationLayer:autoRefresh()
	self.mAutoTime = 0
	self.mAutoRefresh = Utility.schedule(self, function()
		self.mAutoTime = self.mAutoTime + 1
		if self.mAutoTime >= 30 then
			self.mAutoTime = 0
			self:requestGetInfo()
		end
	end, 1.0)
end

--====================================网络请求============================================
--获取信息
function MeditationLayer:requestGetInfo()
	HttpClient:request({
        moduleName = "NeiliMingxiang", 
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
	        -- dump(data, "data")
	        self.mMeditationInfo = data.Value.NeiliMingxiangInfo
	        self.mAutoTime = 0
           	self:refreshBottomView()
        end
    })
end

--开始冥想
function MeditationLayer:requestStartMingxiang(index)
	HttpClient:request({
        moduleName = "NeiliMingxiang", 
        methodName = "StartMingxiang",
        svrMethodData = {index, self.mSelectInfo[index]},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
	        -- dump(data, "data")
	        self.mMeditationInfo = data.Value.NeiliMingxiangInfo
	        -- self.mSelectInfo = {[1] = 0,[2] = 0,[3] = 0,}
	        self.mSelectInfo[index] = 0
	        self.mAutoTime = 0
           	self:refreshBottomView()
        end
    })
end

--结束冥想
function MeditationLayer:requestEndMingxiang(index)
	-- 查找对应卡槽
	local mingInfo = nil
	for _, mingxiangInfo in pairs(self.mMeditationInfo) do
		if mingxiangInfo.MingxiangSlotId == index then
			mingInfo = mingxiangInfo
			break
		end
	end
	-- 最后30秒不可收取
	local timeLeft = mingInfo.EndTime - Player:getCurrentTime()
	if timeLeft > 0 and timeLeft <= 30 then 	-- 最后30秒不可收取
		ui.showFlashView(TR("冥想即将结束请耐心等待"))
		return
	end
	HttpClient:request({
        moduleName = "NeiliMingxiang", 
        methodName = "EndMingxiang",
        svrMethodData = {index},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
	        -- dump(data, "data")
	        self.mMeditationInfo = data.Value.NeiliMingxiangInfo
	        self.mAutoTime = 0
           	self:refreshBottomView()
        	if data.Value.BaseGetGameResourceList then
        		ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
        	end

        end
    })
end

return MeditationLayer
