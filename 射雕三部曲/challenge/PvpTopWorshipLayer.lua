--[[
    文件名：PvpTopWorshipLayer
    描述：武林盟主休战界面
    创建人：lengjiazhi
    创建时间：2017.11.02
--]]
local PvpTopWorshipLayer = class("PvpTopWorshipLayer", function()
	return display.newLayer()
end)

function PvpTopWorshipLayer:ctor()

	self.mCurSelectId = 1

	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self:initUI()
	self:requestGetInfo()
end

function PvpTopWorshipLayer:initUI()
	--背景
	local bgSprite = ui.newSprite("wlmz_15.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	--中间标题
	local titleSprite = ui.newSprite("wlmz_01.png")
	titleSprite:setPosition(320, 1020)
	self.mParentLayer:addChild(titleSprite)

    -- 退出按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(self.mCloseBtn, 100)

    -- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 1),
        position = cc.p(45, 1085),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.一个赛季分为初赛、争霸赛2个阶段，一周为一个赛季"),
                [2] = TR("2.每周周一0点至周日凌晨5点为初赛阶段，周日18:30点开始决赛，同时各位大侠可以给中意的强者下注"),
                [3] = TR("3.初赛分为初入江湖，小有名气，名动一方，天下闻名，一代宗师，登峰造极，6个段位，登峰造极前128名进入武林神话段位，参加争霸赛"),
                [4] = TR("4.初赛规则与武林争霸规则一致"),
                [5] = TR("5.在争霸赛开始时，进入争霸赛的玩家会随机分成4个组进入战斗"),
                [6] = TR("6.争霸赛分为16强赛、8强赛、4强赛、半决赛、决赛5个比赛阶段"),
                [7] = TR("7.每场比赛的规则会根据比赛阶段进行变化（16强赛一局定胜负，8强赛三局两胜，4强赛三局两胜，半决赛三局两胜，决赛五局三胜)"),
                [8] = TR("8.每个比赛阶段前都会开启【竞猜】\n每场比赛的阶段竞猜时间：\n    16强赛：每周日18:30-19：00\n    8强赛：每周日19:00-19:30\n    4强赛：每周日19:30-20:00\n    半决赛：每周日20:00-20:30\n    决赛：每周日20:30-21:00"),
                [9] = TR("9.每个比赛阶段只能为1名玩家进行【下注】"),
                [10] = TR("10.竞猜成功将获得酬金与本金返还，竞猜失败则无法获得酬金并且不返还本金"),
                [11] = TR("11.本轮争霸赛结束后按照排行榜发放奖励，并可在次日对武林盟主进行膜拜，并开启下一轮比赛"),
                [12] = TR("12.每位玩家可对【武林盟主】进行膜拜，每日只能进行1次膜拜"),
                [13] = TR("13.每周将清空争霸赛的积分和信息，每两周将清空初赛的积分和信息"),
                [14] = TR("14.每周参与竞猜，竞猜正确可以领取竞猜宝箱。"),
        	})
        end})
    self.mParentLayer:addChild(ruleBtn, 1)


    --战报按钮
    local FightReportBtn = ui.newButton({
    	normalImage = "tb_198.png",
    	clickAction = function()
            self:requestIsHaveBattleReport()
    	end
    	})
    FightReportBtn:setPosition(45, 930)
    self.mParentLayer:addChild(FightReportBtn)

    --奖励按钮
    local rewardBtn = ui.newButton({
    	normalImage = "tb_199.png",
    	clickAction = function()
    		LayerManager.addLayer({
                name = "challenge.PvpTopRankLayer",
                cleanUp = false,
                })
    	end
    	})
    rewardBtn:setPosition(580, 930)
    self.mParentLayer:addChild(rewardBtn)


    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            ResourcetypeSub.eVIT,
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eGold
        }
    })
    self:addChild(topResource)
end

--中间信息展示
function PvpTopWorshipLayer:PlayerView()
	if next(self.mPlayerInfo) == nil or self.mPlayerInfo[4] == nil then
        MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.一个赛季分为初赛、争霸赛2个阶段，一周为一个赛季"),
                [2] = TR("2.每周周一0点至周日凌晨5点为初赛阶段，周日18:30点开始决赛，同时各位大侠可以给中意的强者下注"),
                [3] = TR("3.初赛分为初入江湖，小有名气，名动一方，天下闻名，一代宗师，登峰造极，6个段位，登峰造极前128名进入武林神话段位，参加争霸赛"),
                [4] = TR("4.初赛规则与武林争霸规则一致"),
                [5] = TR("5.在争霸赛开始时，进入争霸赛的玩家会随机分成4个组进入战斗"),
                [6] = TR("6.争霸赛分为16强赛、8强赛、4强赛、半决赛、决赛5个比赛阶段"),
                [7] = TR("7.每场比赛的规则会根据比赛阶段进行变化（16强赛一局定胜负，8强赛三局两胜，4强赛三局两胜，半决赛三局两胜，决赛五局三胜)"),
                [8] = TR("8.每个比赛阶段前都会开启【竞猜】\n每场比赛的阶段竞猜时间：\n    16强赛：每周日18:30-19：00\n    8强赛：每周日19:00-19:30\n    4强赛：每周日19:30-20:00\n    半决赛：每周日20:00-20:30\n    决赛：每周日20:30-21:00"),
                [9] = TR("9.每个比赛阶段只能为1名玩家进行【下注】"),
                [10] = TR("10.竞猜成功将获得酬金与本金返还，竞猜失败则无法获得酬金并且不返还本金"),
                [11] = TR("11.本轮争霸赛结束后按照排行榜发放奖励，并可在次日对武林盟主进行膜拜，并开启下一轮比赛"),
                [12] = TR("12.每位玩家可对【武林盟主】进行膜拜，每日只能进行1次膜拜"),
                [13] = TR("13.每周将清空争霸赛的积分和信息，每两周将清空初赛的积分和信息"),
                [14] = TR("14.每周参与竞猜，竞猜正确可以领取竞猜宝箱。"),
        	},
        	nil,
        	{clickAction = function(layerObj)
        		LayerManager.removeLayer(layerObj)
        		LayerManager.removeLayer(self)
        	end},
        	{{text = TR("确定"),
        	normalImage = "c_28.png",
        	clickAction = function(layerObj)
        		LayerManager.removeLayer(layerObj)
        		LayerManager.removeLayer(self)
        	end}})
		return
	end

    local defaultInfo = self.mPlayerInfo[1]
	self:createEllipseView()

    --名望称号
    local titleNode = cc.Node:create()
    titleNode:setContentSize(cc.size(120, 30))
    titleNode:setPosition(cc.p(320, 505))
    self.mParentLayer:addChild(titleNode)
    self.mTitleNode = titleNode
    self.mTitleNode.refreshTitle = function (target, titleId)
        target:removeAllChildren()

        -- 创建新的称号
        local newNode = ui.createTitleNode(titleId)
        if (newNode == nil) then
            return
        end
        newNode:setPosition(0, -10)
        target:addChild(newNode)
    end
    self.mTitleNode:refreshTitle(defaultInfo.TitleId)

	--战力背景
	local fapBgSprite = ui.newSprite("c_53.png")
	fapBgSprite:setPosition(320, 455)
	self.mParentLayer:addChild(fapBgSprite)

	--战力
	local fapLabel = ui.newLabel({
		text = Utility.numberFapWithUnit(defaultInfo.FAP),
		outlineColor = Enums.Color.eOutlineColor,
		size = 22,
		})
	fapLabel:setPosition(320, 455)
	self.mParentLayer:addChild(fapLabel)
	self.mFapLabel = fapLabel

	--名字背景
	local nameBgSprite = ui.newScale9Sprite("c_25.png", cc.size(360, 45))
	nameBgSprite:setPosition(320, 405)
	self.mParentLayer:addChild(nameBgSprite)

	--名字
	local nameLabel = ui.newLabel({
		text = string.format("%s  %s", defaultInfo.Name, defaultInfo.Zone),
		outlineColor = Enums.Color.eOutlineColor,
		size = 22,
		})
	nameLabel:setPosition(320, 405)
	self.mParentLayer:addChild(nameLabel)
	self.mNameLabel = nameLabel

	local guildLabel = ui.newLabel({
		text = string.format("<%s>", defaultInfo.GuildName),
		outlineColor = Enums.Color.eBlack,
		size = 22,
		})
	guildLabel:setPosition(320, 370)
	self.mParentLayer:addChild(guildLabel)
	self.mGuildLabel = guildLabel
	self.mGuildLabel:setVisible(defaultInfo.GuildName ~= "")

	--膜拜按钮
	local worshipBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("膜拜"),
		clickAction = function()
			self:requestWorship()
		end
		})
	worshipBtn:setPosition(320, 310)
	self.mParentLayer:addChild(worshipBtn)
    self.mWorshipBtn = worshipBtn

    --周日提示
    if os.date("*t", Player:getCurrentTime()).wday == 1 then
        local tipLabel = ui.newLabel({
            text = TR("周日不能膜拜武林盟主"),
            size = 22,
            outlineColor = Enums.Color.eOutlineColor,
            })
        tipLabel:setPosition(320, 270)
        self.mParentLayer:addChild(tipLabel)
        self.mTipLabel = tipLabel
    end


    local function dealRedDotVisible(redDotSprite)
        redDotSprite:setVisible(RedDotInfoObj:isValid(ModuleSub.eGodWorship))
        worshipBtn:setEnabled(RedDotInfoObj:isValid(ModuleSub.eGodWorship))
    end
    ui.createAutoBubble({parent = worshipBtn, eventName = RedDotInfoObj:getEvents(ModuleSub.eGodWorship), refreshFunc = dealRedDotVisible})

end

--创建椭圆控件
function PvpTopWorshipLayer:createEllipseView()
    self._ellipseLayer = require("common.EllipseLayer3D").new({
        longAxias = 235,
        shortAxias = 180,
        fixAngle = 90,
        totalItemNum = 4,
        itemContentCallback = function(parent, index)
            self:createOnePlayer(parent, index)
        end,
        alignCallback = function (index)
            self:refreshByEllipse(index)
        end
    })
    self._ellipseLayer:setPosition(cc.p(335, 600))
    self.mParentLayer:addChild(self._ellipseLayer)

end

--创建单个玩家
function PvpTopWorshipLayer:createOnePlayer(parent, index)

	local info = self.mPlayerInfo[index]
	local hero = Figure.newHero({
            heroModelID = info.HeadImageId,
            fashionModelID = info.FashionModelId,
            IllusionModelId = info.IllusionModelId,
            parent = parent,
            position = cc.p(0, -80),
            scale = 0.245,
        })
end

function PvpTopWorshipLayer:refreshByEllipse(index)
	self.mCurSelectId = index
	local curInfo = self.mPlayerInfo[index]
    self.mTitleNode:refreshTitle(curInfo.TitleId)
	self.mFapLabel:setString(Utility.numberFapWithUnit(curInfo.FAP))
	self.mNameLabel:setString(string.format("%s  %s",curInfo.Name, curInfo.Zone))
	self.mGuildLabel:setString(string.format("<%s>", curInfo.GuildName))
	self.mGuildLabel:setVisible(curInfo.GuildName ~= "")
end

--下方宝箱展示
function PvpTopWorshipLayer:bottomView()
	--宝箱背景
	local boxBgSprite = ui.newSprite("r_02.png")
	boxBgSprite:setPosition(320, 185)
	self.mParentLayer:addChild(boxBgSprite)
	--宝箱背景
	local boxBgSprite2 = ui.newSprite("r_01.png")
	boxBgSprite2:setPosition(320, 185)
	self.mParentLayer:addChild(boxBgSprite2)

	self.mBoxList = {}
	for i,v in ipairs(self.mRewardInfo) do
		local goodsList = Utility.analysisStrResList(v.ReturnResource)
		local boxBtn = ui.newButton({
			normalImage = "r_05.png",
			disabledImage = "r_14.png",
			clickAction = function()
				MsgBoxLayer.addPreviewDropLayer(goodsList, nil, TR("宝箱奖励"))
			end
			})
		boxBtn:setPosition(70 + (i-1)*100, 185)
		self.mParentLayer:addChild(boxBtn)

		if i <= self.mCurDay then
			boxBtn:setEnabled(false)
		end
		table.insert(self.mBoxList, boxBtn)
		--天数
		local daysLabel = ui.newLabel({
			text = TR("第%s天", i),
			outlineColor = Enums.Color.eBlack,
			size = 22,
			})
		daysLabel:setPosition(70 + (i-1)*100, 145)
		self.mParentLayer:addChild(daysLabel)

	end
end

-- 设置触摸事件
function PvpTopWorshipLayer:setTouch()
    -- self.mCanTouch = true
    local startPosX, prevPosX = 0, 0
    local isMove = false
    local moveRight = true
    -- local diffX = 0
    local prev = {x = 0, y = 0}
    local start = {x = 0, y = 0}

    -- 触摸开始函数
    local function touchBegin(touch, event)
        prev.x = touch:getLocation().x
        prev.y = touch:getLocation().y

        start.x = touch:getLocation().x
        start.y = touch:getLocation().y

        return true
    end

    -- 触摸中函数
    local function touchMoved(touch, event)
        local diffX = touch:getLocation().x - prev.x
        prev.x = touch:getLocation().x
        prev.y = touch:getLocation().y
        if diffX > 0 then
            self._ellipseLayer:setRadiansOffset(-1)
        end
        if diffX < 0 then
            self._ellipseLayer:setRadiansOffset(1)
        end
    end

    -- 触摸结束函数
    local function touchEnd(touch, event)
        local diffX = touch:getLocation().x - start.x
        if diffX > 100 then 
            self._ellipseLayer:moveToPreviousItem() 
            return 
        end
        if diffX < -100 then self._ellipseLayer:moveToNextItem() 
            return 
        end
        self._ellipseLayer:alignTheLayer(true)
    end

    local function onTouchCancel(touch, event)
        local diffX = touch:getLocation().x - start.x
        if diffX > 100 then 
            self._ellipseLayer:moveToPreviousItem() 
            return 
        end
        if diffX < -100 then self._ellipseLayer:moveToNextItem() 
            return 
        end
        self._ellipseLayer:alignTheLayer(true)
    end

    -- 创建触摸层
    local touchNode = cc.Layer:create()
    self.mParentLayer:addChild(touchNode)
    ui.registerSwallowTouch({
        node = touchNode,
        allowTouch = false,
        beganEvent = touchBegin,
        movedEvent = touchMoved,
        endedEvent = touchEnd,
        cancellEvent = onTouchCancel,
    })
end

--==================================网络请求=================================
--请求信息
function PvpTopWorshipLayer:requestGetInfo()
	HttpClient:request({
        moduleName = "PvpinterTopWorshipInfo", 
        methodName = "GetWorshipInfo",
        svrMethodData = {},
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
	        self.mPlayerInfo = data.Value.PlayerInfo
	        self.mRewardInfo = data.Value.WorshipRewards
	        self.mCurDay = data.Value.Days
	        self:setTouch()
        	self:PlayerView()
        	self:bottomView()
        end
    })
end

--请求膜拜
function PvpTopWorshipLayer:requestWorship()
	HttpClient:request({
        moduleName = "PvpinterTopWorshipInfo", 
        methodName = "Worship",
        svrMethodData = {},
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
            self.mCurDay = self.mCurDay + 1
            for i,v in ipairs(self.mBoxList) do
            	if i <= self.mCurDay then
            		v:setEnabled(false)
            	end
            end
            self.mWorshipBtn:setEnabled(false)
        end
    })
end

--请求战报信息
function PvpTopWorshipLayer:requestIsHaveBattleReport()
        HttpClient:request({
        moduleName = "PVPinterTop", 
        methodName = "IsHaveBattleReport",
        svrMethodData = {},
        callback = function (data)            
            if not data.Value or data.Status ~= 0 then
                return
            end
            if data.Value.IsHave then
                LayerManager.addLayer({
                    name = "challenge.PvpTopHomeLayer",
                    -- cleanUp = false
                })
            else
                ui.showFlashView(TR("暂无战报信息"))
            end
        end
    })
end
return PvpTopWorshipLayer