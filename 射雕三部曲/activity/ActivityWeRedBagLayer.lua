--[[
    文件名: ActivityWeRedBagLayer.lua
	描述: 微信红包界面
	创建人: yanghongsheng
	创建时间: 2018.12.24
--]]

local ActivityWeRedBagLayer = class("ActivityWeRedBagLayer", function()
    return display.newLayer()
end)

local GiftType = {
	eLoginGift = 1,		-- 累计登录
	eChargeGift = 2,	-- 首冲礼包
	eFapGift = 3,		-- 战力礼包
	ePTTGift = 4,		-- 普天同庆
}

--[[
-- 参数 params 中的各项为：
]]
function ActivityWeRedBagLayer:ctor(params)
	params = params or {}
	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 

    -- 创建底部导航和顶部玩家信息部分
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

	-- 初始化页面控件
	self:initUI()
	-- 请求数据
	self:requestInfo()
end

-- 初始化页面控件
function ActivityWeRedBagLayer:initUI()
	--背景图
	local bgSprite = ui.newSprite("wslb_01.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	-- 活动倒计时
	self.mTimeLabel = ui.newLabel({
			text = "",
			color = Enums.Color.eWhite,
			outlineColor = cc.c3b(0x46, 0x22, 0x0d),
		})
	self.mTimeLabel:setAnchorPoint(cc.p(0, 0))
	self.mTimeLabel:setPosition(35, 905)
	self.mParentLayer:addChild(self.mTimeLabel)

    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(590, 930),
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn)
end

-- 创建切换列表
function ActivityWeRedBagLayer:createBtnList()
	-- 列表按钮
	local btnInfoList = {
		-- 累计登录
		[GiftType.eLoginGift] = {
			normalImage = "tb_322.png",
			btnTag = GiftType.eLoginGift,
		},
		-- 首冲礼包
		[GiftType.eChargeGift] = {
			normalImage = "tb_324.png",
			btnTag = GiftType.eChargeGift,
		},
		-- 战斗礼包
		[GiftType.eFapGift] = {
			normalImage = "tb_325.png",
			btnTag = GiftType.eFapGift,
		},
		-- 普天同庆
		[GiftType.ePTTGift] = {
			normalImage = "tb_323.png",
			btnTag = GiftType.ePTTGift,
		},
	}
	-- 列表背景
	local listBgSize = cc.size(640, 150)
	if not self.mListBgSprite then
		local listBg = ui.newScale9Sprite("c_69.png", listBgSize)
		listBg:setPosition(320, 1016)
		self.mParentLayer:addChild(listBg)
		self.mListBgSprite = listBg
	end
	self.mListBgSprite:removeAllChildren()

	-- 列表
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.horizontal)
    listView:setBounceEnabled(true)
    listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    listView:setItemsMargin(8)
    listView:setAnchorPoint(cc.p(0.5, 0.5))
    listView:setPosition(listBgSize.width*0.5, listBgSize.height*0.5)
    listView:setContentSize(cc.size(listBgSize.width-40, listBgSize.height))
    self.mListBgSprite:addChild(listView)

    local ConfigGiftTypeList = {}
    local tempList = {}
    for _, configInfo in pairs(self.mWechatredConfig) do
    	tempList[configInfo.RedType] = true
    end
    ConfigGiftTypeList = table.keys(tempList)
    -- 填充列表
    for i, giftType in ipairs(ConfigGiftTypeList) do
    	local btnInfo = btnInfoList[giftType]
    	local selectSprite = ui.newSprite("c_116.png")

    	-- 回调
    	btnInfo.clickAction = function ()
			self:refreshUI(btnInfo.btnTag)
			if self.mSelectSprite then
				self.mSelectSprite:setVisible(false)
			end
			self.mSelectSprite = selectSprite
			selectSprite:setVisible(true)
    	end
    	-- 列表项
    	local cellSize = cc.size(140, listView:getContentSize().height)
    	local cellItem = ccui.Layout:create()
    	cellItem:setContentSize(cellSize)
    	listView:pushBackCustomItem(cellItem)
    	-- 添加选择框
    	selectSprite:setPosition(cellSize.width*0.5, cellSize.height*0.55)
    	selectSprite:setVisible(i == 1)
    	if i == 1 then self.mSelectSprite = selectSprite end
    	cellItem:addChild(selectSprite)
    	-- 添加按钮
    	local tempBtn = ui.newButton(btnInfo)
    	tempBtn:setPosition(cellSize.width*0.5, cellSize.height*0.5)
    	cellItem:addChild(tempBtn)
    end

    -- 刷新第一个页面
    self:refreshUI(ConfigGiftTypeList[1])
end

-- 创建文字列表
function ActivityWeRedBagLayer:createRuleLabelList(ruleStrList, listSize)
	-- 列表
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(false)
    listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    -- listView:setItemsMargin(8)
    listView:setAnchorPoint(cc.p(0.5, 0.5))
    listView:setContentSize(listSize)
    
    for _, textStr in ipairs(ruleStrList) do
    	local labelItem = ccui.Layout:create()
    	listView:pushBackCustomItem(labelItem)

    	local label = ui.newLabel({
    			text = textStr,
    			size = 22,
    			color = Enums.Color.eWhite,
    			outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    			dimensions = cc.size(listSize.width-10, 0),
    		})
    	labelItem:addChild(label)

    	local labelSize = label:getContentSize()
    	local itemSize = cc.size(listSize.width, labelSize.height+10)

    	labelItem:setContentSize(itemSize)
    	label:setPosition(itemSize.width*0.5, itemSize.height*0.5)
	end

    return listView
end

-- 创建累计登录介绍页
function ActivityWeRedBagLayer:createLoginLayer()
	-- 活动简介
	local activityIntroList = {
		TR("活动简介："),
		TR("1.每个满足条件的玩家累计登录满3天和5天的礼包各能领取一次(限量3000个，发完为止)"),
		TR("2.等级达到40级才能领取对应得礼包"),
		TR("3.活动时间有限，需登录达到对应得天数才可领取对应得礼包"),
		TR("4.关注微信公众号“赤影江湖”，在对话框输入兑换码即可领取微信礼包"),
	}
	local introListView = self:createRuleLabelList(activityIntroList, cc.size(600, 260))
	introListView:setPosition(332, 770)
	self.mRuleParent:addChild(introListView)

	-- 黑背景
	local blackSprite = ui.newScale9Sprite("c_38.png", cc.size(630, 420))
	blackSprite:setPosition(320, 420)
	self.mRuleParent:addChild(blackSprite)

	-- 题目图
	local titleSprite = ui.newSprite("wslb_03.png")
	titleSprite:setPosition(340, 580)
	self.mRuleParent:addChild(titleSprite)

	-- 活动规则
	local activityRuleList = {
		TR("活动期间，每个玩家连续登陆达到指定天数即可触发微信礼包奖励，可前往公众号兑换微信礼包"),
		TR("每个玩家共有两次机会获得微信礼包"),
		TR("累计登陆满3天：获得微信礼包兑换码一个"),
		TR("累计登陆满5天：获得微信礼包兑换码一个"),
	}
	local ruleListView = self:createRuleLabelList(activityRuleList, cc.size(600, 245))
	ruleListView:setPosition(330, 343)
	self.mRuleParent:addChild(ruleListView)

	-- 添加提示文字
	local hintStrLabel = ui.newLabel({
			text = TR("点击首页-->更多-->飞鸽传书 即可查看获得的礼包兑换码"),
			size = 20,
			color = Enums.Color.eWhite,
		})
	hintStrLabel:setPosition(320, 240)
	self.mRuleParent:addChild(hintStrLabel)
end

-- 创建首冲介绍页
function ActivityWeRedBagLayer:createChargeLayer()
	-- 活动简介
	local activityIntroList = {
		TR("活动详情："),
		TR("1.每个角色充值都可获得首充礼包兑换码，同类型兑换码微信领取无次数限制"),
		TR("2.活动期间，微信首充礼包和累计登录礼包 每个角色都只能领取一次"),
		TR("3.关注微信公众号“赤影江湖”，在对话框输入兑换码即可领取微信礼包"),
	}
	local introListView = self:createRuleLabelList(activityIntroList, cc.size(600, 260))
	introListView:setPosition(332, 770)
	self.mRuleParent:addChild(introListView)

	-- 黑背景
	local blackSprite = ui.newScale9Sprite("c_38.png", cc.size(630, 420))
	blackSprite:setPosition(320, 420)
	self.mRuleParent:addChild(blackSprite)

	-- 题目图
	local titleSprite = ui.newSprite("wslb_04.png")
	titleSprite:setPosition(340, 580)
	self.mRuleParent:addChild(titleSprite)

	-- 活动规则
	local activityRuleList = {
		TR("活动期间，每个角色完成任意首冲即可触发微信礼包奖励"),
		TR("每个角色共有两次机会获得微信礼包"),
		TR("完成首冲(>=6元)：获得微信礼包兑换码一个"),
		TR("首冲且累计登陆满5天：获得微信礼包兑换码一个"),
	}
	local ruleListView = self:createRuleLabelList(activityRuleList, cc.size(620, 245))
	ruleListView:setPosition(330, 343)
	self.mRuleParent:addChild(ruleListView)

	-- 添加提示文字
	local hintStrLabel = ui.newLabel({
			text = TR("点击首页-->更多-->飞鸽传书 即可查看获得的礼包兑换码"),
			size = 20,
			color = Enums.Color.eWhite,
		})
	hintStrLabel:setPosition(320, 270)
	self.mRuleParent:addChild(hintStrLabel)

	-- 领取按钮
	local goBtn = ui.newButton({
			normalImage = "c_28.png",
			text =  TR("去充值"),
			clickAction = function ()
				LayerManager.addLayer({name = "recharge.RechargeLayer"})
			end
		})
	goBtn:setPosition(320, 150)
	self.mRuleParent:addChild(goBtn)

	-- 添加特效
	local liubianEffect = ui.newEffect({
			parent = goBtn,
			effectName = "effect_ui_jianghushouchong",
			position = cc.p(goBtn:getContentSize().width*0.5, goBtn:getContentSize().height*0.5),
			scale = 0.8,
			loop = true,
		})
end

-- 创建战力介绍页
function ActivityWeRedBagLayer:createFapLayer()
	-- 活动简介
	local activityIntroList = {
		TR("活动详情："),
		TR("1.每个角色需要单笔充值对应得金额才能触发战力礼包"),
		TR("2.玩家获取的奖励为当前充值档位，达到战力所有的奖励档位，例：玩家55W战力，充值了98元，则能领取98元档5W到50W战力礼包所有的礼包"),
		TR("3.活动期间，每个角色每个充值档位仅能获取一次。"),
		TR("4.若活动期间，玩家充值了648元，当时战力为20W，能领取648元20W战力得礼包，接着在活动期间战力提升至50W战力，则能继续领取648元档 50W战力得礼包，达到下一战力档位可以继续领取"),
		TR("5.关注微信公众号“赤影江湖”，在对话框输入兑换码即可领取礼包码"),
	}
	local introListView = self:createRuleLabelList(activityIntroList, cc.size(600, 260))
	introListView:setPosition(332, 770)
	self.mRuleParent:addChild(introListView)

	-- 黑背景
	local blackSprite = ui.newScale9Sprite("c_38.png", cc.size(630, 447))
	blackSprite:setPosition(320, 394)
	self.mRuleParent:addChild(blackSprite)

	-- 题目图
	local titleSprite = ui.newSprite("wslb_05.png")
	titleSprite:setPosition(340, 560)
	self.mRuleParent:addChild(titleSprite)

	-- 表格图
	local gridSprite = ui.newSprite("wslb_07.png")
	gridSprite:setPosition(320, 350)
	self.mRuleParent:addChild(gridSprite)

	-- 提示
	local hintLabel = ui.newLabel({
			text = TR("战力达到指定数值将获得礼包"),
			size = 20,
			color = Enums.Color.eWhite,
		})
	hintLabel:setPosition(320, 210)
	self.mRuleParent:addChild(hintLabel)

	-- 领取按钮
	local goBtn = ui.newButton({
			normalImage = "c_28.png",
			text =  TR("去充值"),
			clickAction = function ()
				LayerManager.addLayer({name = "recharge.RechargeLayer"})
			end
		})
	goBtn:setPosition(320, 130)
	self.mRuleParent:addChild(goBtn)

	-- 添加特效
	local liubianEffect = ui.newEffect({
			parent = goBtn,
			effectName = "effect_ui_jianghushouchong",
			position = cc.p(goBtn:getContentSize().width*0.5, goBtn:getContentSize().height*0.5),
			scale = 0.8,
			loop = true,
		})
end

-- 创建普天同庆介绍页
function ActivityWeRedBagLayer:createPTTLayer()
	-- 活动简介
	local activityIntroList = {
		TR("活动详情："),
		TR("1.每个角色仅首次充值648元可触发普天同庆礼包"),
		TR("2.每次普天同庆微信礼包限前100名玩家领取,可前往公众号兑换微信礼包"),
		TR("3.关注微信公众号“赤影江湖”，在对话框输入兑换码即可领取微信礼包"),
	}
	local introListView = self:createRuleLabelList(activityIntroList, cc.size(600, 260))
	introListView:setPosition(332, 770)
	self.mRuleParent:addChild(introListView)

	-- 黑背景
	local blackSprite = ui.newScale9Sprite("c_38.png", cc.size(630, 525))
	blackSprite:setPosition(320, 360)
	self.mRuleParent:addChild(blackSprite)

	-- 题目图
	local titleSprite = ui.newSprite("wslb_06.png")
	titleSprite:setPosition(340, 566)
	self.mRuleParent:addChild(titleSprite)

	-- 活动规则
	local activityRuleList = {
		TR("活动期间，每个玩家首次充值648元即可领取以下奖励并触发全服微信普天同庆礼包好礼。"),
		TR("触发微信普天同庆礼包好礼：即全服玩家可收到一个微信礼包兑换码，可前往公众号兑换微信礼包"),
	}
	local ruleListView = self:createRuleLabelList(activityRuleList, cc.size(620, 150))
	ruleListView:setPosition(330, 405)
	self.mRuleParent:addChild(ruleListView)

	-- 添加提示文字
	local hintStrLabel = ui.newLabel({
			text = TR("点击首页-->更多-->飞鸽传书 即可查看获得的礼包兑换码"),
			size = 20,
			color = Enums.Color.eWhite,
		})
	hintStrLabel:setPosition(320, 650)
	self.mRuleParent:addChild(hintStrLabel)

	-- 奖励列表
	local rewardCardList = ui.createCardList({
			maxViewWidth = 560,
			cardDataList = self.mPTTRewardList,
		})
	rewardCardList:setAnchorPoint(cc.p(0.5, 0.5))
	rewardCardList:setPosition(320, 260)
	self.mRuleParent:addChild(rewardCardList)

	-- 领取按钮
	local getBtn = ui.newButton({
			normalImage = "c_28.png",
			text = self.mWechatredPttqInfo.IsDraw == nil and TR("去充值") or TR("领 取"),
			clickAction = function ()
				if self.mWechatredPttqInfo.IsDraw == nil then
					LayerManager.addLayer({name = "recharge.RechargeLayer"})
					return
				end
				self:requestReward()
			end
		})
	getBtn:setPosition(320, 150)
	self.mRuleParent:addChild(getBtn)

	if self.mWechatredPttqInfo.IsDraw == false then
		getBtn:setTitleText(TR("已领取"))
		getBtn:setEnabled(false)
	elseif self.mWechatredPttqInfo.IsDraw == nil then
		-- 添加特效
		local liubianEffect = ui.newEffect({
				parent = getBtn,
				effectName = "effect_ui_jianghushouchong",
				position = cc.p(getBtn:getContentSize().width*0.5, getBtn:getContentSize().height*0.5),
				scale = 0.8,
				loop = true,
			})
	end
end

-- 创建倒计时
function ActivityWeRedBagLayer:createTimeUpdate()
	if self.mTimeLabel.timeUpdate then
        self.mTimeLabel:stopAction(self.mTimeLabel.timeUpdate)
        self.mTimeLabel.timeUpdate = nil
    end

    self.mTimeLabel.timeUpdate = Utility.schedule(self.mTimeLabel, function ()
        local timeLeft = self.mEndTime - Player:getCurrentTime()
        if timeLeft > 0 then
            self.mTimeLabel:setString(TR("活动倒计时：#ffe748%s", MqTime.formatAsDay(timeLeft)))
        else
            self.mTimeLabel:setString(TR("活动倒计时：#ffe74800:00:00"))
            self.mTimeLabel:stopAction(self.mTimeLabel.timeUpdate)
            self.mTimeLabel.timeUpdate = nil
            LayerManager.removeLayer(self)
        end
    end, 1)
end

-- 刷新界面
function ActivityWeRedBagLayer:refreshUI(btnType)
	if not self.mRuleParent then
		self.mRuleParent = cc.Node:create()
		self.mParentLayer:addChild(self.mRuleParent)
	end
	self.mRuleParent:removeAllChildren()

	if btnType == GiftType.eLoginGift then
		self:createLoginLayer()
	elseif btnType == GiftType.eChargeGift then
		self:createChargeLayer()
	elseif btnType == GiftType.eFapGift then
		self:createFapLayer()
	elseif btnType == GiftType.ePTTGift then
		self:createPTTLayer()
	end

end


-- =========================== 网络请求相关接口 ======================
-- 请求数据
function ActivityWeRedBagLayer:requestInfo()
    HttpClient:request({
        moduleName = "WeChatRed",
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end

            self.mEndTime = response.Value.EndDate
            self.mWechatredPttqInfo = response.Value.WechatredPttqInfo or {}
            self.mWechatredConfig = response.Value.WechatredRelation
            -- 普天同庆奖励列表
            self.mPTTRewardList = {}
            for _, wechatredInfo in pairs(response.Value.WechatredRelation) do
            	if wechatredInfo.RedType == GiftType.ePTTGift and wechatredInfo.Reward ~= "" then
            		local rewardList = Utility.analysisStrResList(wechatredInfo.Reward)
            		for _, rewardInfo in ipairs(rewardList) do
            			table.insert(self.mPTTRewardList, rewardInfo)
            		end
            	end
            end
            -- 创建切换列表
			self:createBtnList()
			-- 创建倒计时
            self:createTimeUpdate()
        end
    })
end

-- 请求领奖
function ActivityWeRedBagLayer:requestReward()
    HttpClient:request({
        moduleName = "WeChatRed",
        methodName = "DrawPttqReward",
        svrMethodData = {},
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

            self.mWechatredPttqInfo = response.Value.WechatredPttqInfo
            
            self:refreshUI(GiftType.ePTTGift)
        end
    })
end

return ActivityWeRedBagLayer

