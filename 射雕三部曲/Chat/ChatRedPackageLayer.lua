--[[
    ChatRedPackageLayer.lua
    描述: 聊天红包界面
    创建人: yanghongsheng
    创建时间: 2017.8.30
-- ]]

local ChatRedPackageLayer = class("ChatRedPackageLayer", function()
    return display.newLayer()
end)

function ChatRedPackageLayer:ctor()
    ui.registerSwallowTouch({node = self})
	
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self.mChannle = false --false为世界频道，true为帮派频道
	self.mSelectNum = nil --选择的红包
	self.mSelectModelId = nil

	self:getRedpurse()
	self:initUI()
end

function ChatRedPackageLayer:initUI()
	--黑色底层
	local bgLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
	bgLayer:setContentSize(640, 1136)
	self.mParentLayer:addChild(bgLayer)

	--返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(508, 835),
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn = closeBtn
    self.mParentLayer:addChild(closeBtn, 10)

     -- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        position = cc.p(145, 835),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.充值30元及以上档位会获得红包。"),
                [2] = TR("2.红包分为3个档次，单笔充值30-98档位，获得价值188元宝的侠义红包，单笔充值198-648档位，获得价值388元宝的豪侠福袋，单笔充值648及以上档位可以获得价值888元宝的至尊礼盒。"),
                [3] = TR("3.红包可以通过聊天界面发放，必须当时在线才能参与抢红包。"),
                [4] = TR("4.充值后红包通过领奖中心发放。"),
        	})
        end})
    self.mParentLayer:addChild(ruleBtn, 10)

end

--创建发送界面
function ChatRedPackageLayer:createSendView()
	if self.mSendNode then
		self.mSendNode:removeFromParent()
		self.mSendNode = nil
	end

	--翻转节点
	local sendNode = cc.Node:create()
	sendNode:setPosition(320, 568)
	self.mParentLayer:addChild(sendNode)
	self.mSendNode = sendNode

	--背景图
	local bgSprite = ui.newSprite("xn_22.png")
	bgSprite:setPosition(0, 0)
	sendNode:addChild(bgSprite)
	local bgSize = bgSprite:getContentSize()

	--标题
	local titleSprite = ui.newSprite("xn_23.png")
	titleSprite:setPosition(bgSize.width * 0.5, bgSize.height)
	bgSprite:addChild(titleSprite)

	--帮派频道选择框
	local channleGuild = ui.newCheckbox({
        isRevert = true,
        text = TR("帮派频道"),
        textColor = cc.c3b(0xf6, 0xe8, 0x7e),
        callback = function (isSelected)
        	self.mChannleWorld:setCheckState(not isSelected)
        	self.mChannle = isSelected
        	LocalData:saveGameDataValue("RedPackChannle", self.mChannle)
        end
		})
	channleGuild:setPosition(bgSize.width * 0.5, bgSize.height * 0.90)
	bgSprite:addChild(channleGuild)
	self.mChannleGuild = channleGuild

	--世界频道选择框
	local channleWorld = ui.newCheckbox({
        isRevert = true,
        text = TR("世界频道"),
        textColor = cc.c3b(0xf6, 0xe8, 0x7e),
        callback = function (isSelected)
        	self.mChannleGuild:setCheckState(not isSelected)
        	self.mChannle = not isSelected
        	LocalData:saveGameDataValue("RedPackChannle", self.mChannle)
        end
		})
	channleWorld:setPosition(bgSize.width * 0.5, bgSize.height * 0.83)
	bgSprite:addChild(channleWorld)
	self.mChannleWorld = channleWorld

	-- 读取本地配置获取上次选择
	self.mChannle = LocalData:getGameDataValue("RedPackChannle") or false
	self.mChannleWorld:setCheckState(not self.mChannle)
	self.mChannleGuild:setCheckState(self.mChannle)

	if next(self.mGoodsIdList) == nil then
		local noGoodsLabel = ui.newLabel({
			text = TR("暂无红包"),
			size = 28,
			color = cc.c3b(0xf6, 0xe8, 0x7e),
			})
		noGoodsLabel:setPosition(bgSize.width * 0.5, bgSize.height * 0.55)
		bgSprite:addChild(noGoodsLabel, 1)
	else
		--创建红包列表
		self.mGoodsCardList = {}
		for i,v in ipairs(self.mGoodsIdList) do
			local cardInfo = {
				resourceTypeSub = Utility.getTypeByModelId(v.ModelId, true),
		        modelId = v.ModelId, 
		        num = v.Num,  
		        cardShowAttrs = {CardShowAttr.eNum, CardShowAttr.eName, CardShowAttr.eBorder}, 
		    	onClickCallback = function (pSender)
		    		if self.mSelectNum == i then
		    			return
		    		else
		    			self.mSelectNum = i
		    			for m, n in ipairs(self.mGoodsList.getCardNodeList()) do
		    				n.mShowAttrControl[CardShowAttr.eSelected].sprite:setVisible(m == self.mSelectNum)
						end
		    		end
		    	end
			}
			table.insert(self.mGoodsCardList, cardInfo)
		end
		local goodList = ui.createCardList({
				maxViewWidth = 350,
		        viewHeight = 140,
		        space = 5, 
		        cardDataList = self.mGoodsCardList,
		        allowClick = true,  
			})
		goodList:setAnchorPoint(0.5, 0.5)
		goodList:setPosition(bgSize.width * 0.5, bgSize.height * 0.53)
		bgSprite:addChild(goodList)
		for i,v in ipairs(goodList.getCardNodeList()) do
			v:setSelectedImg()
		end
		self.mGoodsList = goodList

		for i, v in ipairs(self.mGoodsList.getCardNodeList()) do
			v.mShowAttrControl[CardShowAttr.eSelected].sprite:setVisible(i == self.mSelectNum)
		end
	end

	--输入框
    local editBox = ui.newEditBox({
        image = "c_38.png",
        size = cc.size(380, 70),
    })
    editBox:setPlaceHolder(TR("点击输入祝福语"))
    editBox:setPosition(bgSize.width*0.5, bgSize.height*0.3)
    bgSprite:addChild(editBox)

    --透明底板
    local underBgSprite = ui.newScale9Sprite("bsxy_10.png", cc.size(375, 150))
    underBgSprite:setPosition(bgSize.width * 0.5, bgSize.height * 0.55)
    bgSprite:addChild(underBgSprite)

	--发送按钮
	local sendBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("发送"),
		clickAction = function ()
			if self.mSelectNum == nil then
				ui.showFlashView(TR("请先选择红包"))
				return
			end
			local tempStr = editBox:getText()
			local length = self:asciilen(tempStr)
			if length > 16 then
				ui.showFlashView(TR("输入字符不能超过8个字！"))
				return
			end
			if length == 0 then
				tempStr = TR("大吉大利")
			end

        	local channle = self.mChannle and 6 or 5
        	local modelId = self.mGoodsCardList[self.mSelectNum].modelId
        	self:requestSend(tempStr, channle, modelId)
		end
		})
	sendBtn:setPosition(bgSize.width * 0.5, bgSize.height * 0.08)
	bgSprite:addChild(sendBtn)
	if next(self.mGoodsIdList) == nil then
		sendBtn:setEnabled(false)
	end

	--查看记录按钮
	local checkHistoryBtn = ui.newButton({
		normalImage = "xn_81.png",
		clickAction = function ()
			self.mSendNode:runAction(self:turnAction(false))
		end
		})
	checkHistoryBtn:setPosition(bgSize.width * 0.9, bgSize.height * 0.1)
	bgSprite:addChild(checkHistoryBtn)

	self.mSendNode:setScaleX(0)
	self.mSendNode:runAction(cc.ScaleTo:create(0.3, 1, 1))

end

--创建历史记录界面
function ChatRedPackageLayer:createHistoryView()
	if self.mHistoryNode then
		self.mHistoryNode:removeFromParent()
		self.mHistoryNode = nil
	end

	--翻转节点
	local historyNode = cc.Node:create()
	historyNode:setPosition(320, 568)
	self.mParentLayer:addChild(historyNode)
	self.mHistoryNode = historyNode

	--背景图
	local bgSprite = ui.newSprite("xn_22.png")
	bgSprite:setPosition(0, 0)
	historyNode:addChild(bgSprite)
	local bgSize = bgSprite:getContentSize()

	--标题
	local titleSprite = ui.newSprite("xn_82.png")
	titleSprite:setPosition(bgSize.width * 0.5, bgSize.height)
	bgSprite:addChild(titleSprite)

	--抢到的红包
	local tipGetLabel = ui.createLabelWithBg({
	  	bgFilename = "bpz_31.png",
        labelStr = TR("我抢到的红包"),
        fontSize = 20,
        color = cc.c3b(0xf6, 0xe8, 0x7e),
        outlineColor = cc.c3b(0x5f, 0x29, 0x06),
        alignType = ui.TEXT_ALIGN_CENTER,    
		})
	tipGetLabel:setPosition(bgSize.width*0.5, bgSize.height * 0.9)
	bgSprite:addChild(tipGetLabel)

	--发放的红包
	local tipSendLabel = ui.createLabelWithBg({
	  	bgFilename = "bpz_31.png",
        labelStr = TR("我发放的红包"),
        fontSize = 20,
        color = cc.c3b(0xf6, 0xe8, 0x7e),
        outlineColor = cc.c3b(0x5f, 0x29, 0x06),
        alignType = ui.TEXT_ALIGN_CENTER,    
		})
	tipSendLabel:setPosition(bgSize.width*0.5, bgSize.height * 0.45)
	bgSprite:addChild(tipSendLabel)


	 --透明底板
    local underBgSprite = ui.newScale9Sprite("bsxy_10.png", cc.size(380, 220))
    underBgSprite:setPosition(bgSize.width * 0.5, bgSize.height * 0.675)
    bgSprite:addChild(underBgSprite)

    if next(self.mRewardInfo) == nil then
    	local noGoodsLabel = ui.newLabel({
			text = TR("尚未抢到红包"),
			size = 30,
			color = cc.c3b(0xf6, 0xe8, 0x7e),
			})
		noGoodsLabel:setPosition(bgSize.width * 0.5, bgSize.height * 0.65)
		bgSprite:addChild(noGoodsLabel, 1)
    else
	     --我抢到的红包列表
	    local listView = ccui.ListView:create()
	    listView:setDirection(ccui.ScrollViewDir.vertical)
	    listView:setBounceEnabled(true)
	    listView:setContentSize(cc.size(375, 210))
	    listView:setItemsMargin(5)
	    listView:setGravity(ccui.ListViewGravity.centerHorizontal)
	    listView:setAnchorPoint(cc.p(0.5, 0.5))
	    listView:setPosition(bgSize.width * 0.5, bgSize.height * 0.675)
	    bgSprite:addChild(listView)

	    for i,v in ipairs(self.mRewardInfo) do
	        listView:pushBackCustomItem(self:createOneCell(i))
	    end
	end

    --我发放的红包
	if next(self.mDetailInfo) == nil then
		local noGoodsLabel = ui.newLabel({
			text = TR("尚未发放红包"),
			size = 30,
			color = cc.c3b(0xf6, 0xe8, 0x7e),
			})
		noGoodsLabel:setPosition(bgSize.width * 0.5, bgSize.height * 0.28)
		bgSprite:addChild(noGoodsLabel, 1)
	else
		--创建红包列表
		local cardInfoList = {}
		for i,v in ipairs(self.mDetailInfo) do
			local cardInfo = {
				resourceTypeSub = Utility.getTypeByModelId(v.ModelId, true),
		        modelId = v.ModelId, 
		        num = 1,  
		        cardShowAttrs = {CardShowAttr.eName, CardShowAttr.eBorder}, 
			}
			table.insert(cardInfoList, cardInfo)
		end
		local goodList = ui.createCardList({
				maxViewWidth = 400,
		        viewHeight = 140,
		        space = 5, 
		        cardDataList = cardInfoList,
		        allowClick = false,  
			})
		goodList:setAnchorPoint(0.5, 0.5)
		goodList:setPosition(bgSize.width * 0.5, bgSize.height * 0.25)
		goodList:setScale(0.9)
		bgSprite:addChild(goodList)
		for i,v in ipairs(goodList.getCardNodeList()) do
			v:setSelectedImg()
		end
		self.mGoodsList = goodList

		for i, v in ipairs(self.mGoodsList.getCardNodeList()) do
			v.mShowAttrControl[CardShowAttr.eSelected].sprite:setVisible(i == self.mSelectNum)
		end
	end


	--发红包按钮
	local checkHistoryBtn = ui.newButton({
		normalImage = "xn_80.png",
		clickAction = function ()
			self.mHistoryNode:runAction(self:turnAction(true))
		end
		})
	checkHistoryBtn:setPosition(bgSize.width * 0.9, bgSize.height * 0.1)
	bgSprite:addChild(checkHistoryBtn)

	self.mHistoryNode:setScaleX(0)
	self.mHistoryNode:runAction(cc.ScaleTo:create(0.3, 1, 1))
end

--创建一个我领取过的条目
function ChatRedPackageLayer:createOneCell(index)
    local cellInfo = self.mRewardInfo[index]

    local layout = ccui.Layout:create()
    layout:setContentSize(370, 106)
    --背景
    local bgSprite = ui.newScale9Sprite("c_155.png", cc.size(370, 105))
    bgSprite:setPosition(185, 53)
    layout:addChild(bgSprite)


    --头像
    local headCard = CardNode.createCardNode({
        allowClick = false,
    	})
    headCard:setHero(
            {
                ModelId = cellInfo.HeadImageId,
                FashionModelID = cellInfo.FashionModelId,
                PVPInterLv = cellInfo.DesignationId,
            },
            {CardShowAttr.eBorder}
            )
    headCard:setPosition(55, 53)
    layout:addChild(headCard)

    --名字
    local nameLabel = ui.newLabel({
        text = cellInfo.PlayerName,
        color = cc.c3b(0xfc, 0xf1, 0x89),
        outlineColor = Enums.Color.eOutlineColor,
        size = 20,
        })
    nameLabel:setAnchorPoint(0, 0.5)
    nameLabel:setPosition(105, 85)
    layout:addChild(nameLabel)

    --等级
    local lvLabel = ui.newLabel({
        text = TR("等级：%s", cellInfo.Lv),
        color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eOutlineColor,
        size = 20,
        })
    lvLabel:setAnchorPoint(0, 0.5)
    lvLabel:setPosition(105, 55)
    layout:addChild(lvLabel)

    --vip等级
    local vipLv = tonumber(cellInfo.Vip)
    if vipLv > 0 then
        local vipNode = ui.createVipNode(vipLv)
        vipNode:setPosition(110, 25)
        layout:addChild(vipNode)
    end

    --奖励道具
    local rewardInfo = Utility.analysisStrResList(cellInfo.Reward)
    local rewardCard = CardNode.createCardNode({
            resourceTypeSub = rewardInfo[1].resourceTypeSub,
            modelId = rewardInfo[1].modelId,  -- 模型Id
            num = rewardInfo[1].num, -- 资源数量
            cardShowAttrs = {CardShowAttr.eName, CardShowAttr.eNum, CardShowAttr.eBorder},
        })
    rewardCard:setScale(0.8)
    rewardCard:setPosition(325, 65)
    layout:addChild(rewardCard)

    return layout
end

--翻转两个界面的动作
function ChatRedPackageLayer:turnAction(ishistory)
	local scaleXMin = cc.ScaleTo:create(0.3, 0, 1)
	local callFun = cc.CallFunc:create(function(pSender)
			pSender:setVisible(false)
			if ishistory then
				self:createSendView()
			else
				if not self.mRewardInfo then
					self:getHistory()
				else
					self:createHistoryView()
				end
			end
		end)

	local sq = cc.Sequence:create(scaleXMin, callFun)

	return sq
end

--不同编码下获取字符串长度
function ChatRedPackageLayer:asciilen(str)
    local barrier  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    local size = #barrier
    local count, delta = 0, 0
    local c, i, j = 0, #str, 0

    while i > 0 do
        delta, j, c = 1, size, string.byte(str, -i)
        while barrier[j] do
            if c >= barrier[j] then i = i - j; break end
            j = j - 1
        end
        delta = j == 1 and 1 or 2
        count = count + delta
    end
    return count
end



--====================================网络请求================================
--获取信息
function ChatRedPackageLayer:getRedpurse()
	HttpClient:request({
        moduleName = "Redpurse",
        methodName = "GetRedpurse",
        svrMethodData = {},
        callback = function(response)
        	-- dump(response, "response")
            if not response or response.Status ~= 0 then
                return
            end
			self.mGoodsIdList = response.Value.GoodsIdList
			table.sort(self.mGoodsIdList, function (a, b)
				local qualityA = GoodsModel.items[a.ModelId].quality
				local qualityB = GoodsModel.items[b.ModelId].quality
				if qualityA ~= qualityB then
					return qualityA > qualityB
				end
			end)
			self:createSendView()

        end,
    })
end

--获取信息
function ChatRedPackageLayer:getHistory()
	HttpClient:request({
        moduleName = "Redpurse",
        methodName = "GetHistory",
        svrMethodData = {},
        callback = function(response)
        	-- dump(response, "response")
            if not response or response.Status ~= 0 then
                return
            end
            self.mRewardInfo = response.Value.RewardInfo
            self.mDetailInfo = response.Value.DetailInfo
           	self:createHistoryView()
        end,
    })
end

--发红包
function ChatRedPackageLayer:requestSend(str, channle, modelId)
	HttpClient:request({
        moduleName = "Redpurse",
        methodName = "SendRedpurse",
        svrMethodData = {channle, modelId, str},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            LayerManager.removeLayer(self)
           
        end,
    })
end
return ChatRedPackageLayer