--[[
	文件名: DlgMyFightLogLayer.lua
	描述: 我的战斗日志对话框
	创建人: peiyaoqiang
	创建时间: 2017.11.2
-- ]]

local DlgMyFightLogLayer = class("DlgMyFightLogLayer",function()
	return cc.LayerColor:create(cc.c4b(0, 0, 0, 100))
end)

function DlgMyFightLogLayer:ctor(params)
	-- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("我的战报"),
        bgSize = cc.size(600, 566),
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)

    -- 保存弹窗控件信息
    self.mBgSprite = bgLayer.mBgSprite
    self.mBgSize = bgLayer.mBgSprite:getContentSize()

	self.mTurnCountFlag = 0 -- 计算场次用
	self.mTurns = 0         -- 场次
	self.mLogList = {}		-- 日志列表
	self.mIsBattle = 0

	-- 
	self:getData()
end

-- 初始化界面
function DlgMyFightLogLayer:setUI()
	-- 无信息
	if next(self.mLogList) == nil then
		local hintStr = ""
		if self.mIsBattle == 0 then
			hintStr = TR("很抱歉，您在初赛中并未达到前128名，未能参与武林盟主争霸赛，请再接再厉")
		elseif self.mIsBattle == 1 then
			hintStr = TR("正在进行16强比赛竞猜 请于19:00查看您的比赛结果，谢谢！")
		end
		local emptyHintSprite,label = ui.createEmptyHint(hintStr)
		emptyHintSprite:setContentSize(cc.size(540, 320))
        emptyHintSprite:setPosition(300, 320)
        local x, y =label:getPosition()
        label:setPosition(x, y + 20)
        self.mBgSprite:addChild(emptyHintSprite)
		return
	end
	-- 列表背景
	local listBgSize = cc.size(540, 380)
	local listBg = ui.newScale9Sprite("c_17.png", listBgSize)
	listBg:setAnchorPoint(cc.p(0.5, 1))
	listBg:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height-70)
	self.mBgSprite:addChild(listBg)
	-- 创建ListView列表
    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setItemsMargin(5)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(listBgSize.width, listBgSize.height-20))
    self.listView:setGravity(ccui.ListViewGravity.centerVertical)
    self.listView:setAnchorPoint(cc.p(0.5, 0.5))
    self.listView:setPosition(listBgSize.width * 0.5, listBgSize.height * 0.5)
    listBg:addChild(self.listView)

    for i = 1, #self.mLogList do
        self.listView:pushBackCustomItem(self:createCellView(i))
    end

    -- 是否结束个人的比赛
    local isEnd, endTurnCount = self:figureEnding()
    print("isEnd, endTurnCount", isEnd, endTurnCount)

    if isEnd then
		ui.newLabel({
			text = TR("很遗憾您在%s时战败，期望下次再接再厉获取更好的成绩", self:getBetId(endTurnCount)),
			size = 24,
			color = Enums.Color.eRed,
			dimensions = cc.size(540,0),
			x = self.mBgSize.width*0.5,
			y = 70,
		}):addTo(self.mBgSprite)
    end
end

-- 创建列表单元
function DlgMyFightLogLayer:createCellView(index)
	local info = self.mLogList[index]
    local custom_item = ccui.Layout:create()
    local width = self.listView:getContentSize().width
    local height = 177

    custom_item:setContentSize(cc.size(width, height))

    if self.mTurnCountFlag == info.TurnCount then
    	self.mTurns = self.mTurns + 1
    else
    	self.mTurns = 1
    end

    -- 计算场次
    self.mTurnCountFlag = info.TurnCount

    -- 单元背景图
    local bgSprite = ui.newScale9Sprite("c_54.png", cc.size(width-20, height))
    bgSprite:setPosition(width * 0.5, height * 0.5)
    custom_item:addChild(bgSprite)

    -- 多少强比赛
    ui.newLabel({
    	text        = self:getBetId(info.TurnCount)..TR("  第%d场", self.mTurns),
    	size        = 26,
    	color       = Enums.Color.eWhite,
    	outlineColor= cc.c3b(0x72, 0x25, 0x13),
    	x           = width * 0.5,
    	y           = 155,
    	}):addTo(custom_item)

    -- 攻击方头像
    local Attacker = CardNode.createCardNode({
			resourceTypeSub = ResourcetypeSub.eHero,
	        modelId = info.AttackerHeadImageId,
	        fashionModelID = info.AttackerFashionModelId,
	        onClickCallback = function ()
	        	Utility.showPlayerTeam(info.AttackerId)
	        end,
	        cardShowAttrs = {
	            CardShowAttr.eBorder,
	        },
	    })
	Attacker:setAnchorPoint(0.5, 0.5)
	Attacker:setPosition(cc.p(80, 80))
	custom_item:addChild(Attacker)

    -- 攻击方等级名字
    ui.newLabel({
    	text        = info.AttackerName,
    	size        = 20,
    	color 		= cc.c3b(0x46, 0x22, 0x0d),
    	x           = Attacker:getContentSize().width * 0.5,
    	y           = -15
    	}):addTo(Attacker)

    -- VS 图片
    local VsSprite = ui.newSprite("zdjs_07.png")
    VsSprite:setPosition(200, 80)
    custom_item:addChild(VsSprite)

    -- 防守方头像
    local Defender = CardNode.createCardNode({
			resourceTypeSub = ResourcetypeSub.eHero,
	        modelId = info.DefenderHeadImageId,
	        fashionModelID = info.DefenderFashionModelId,
	        onClickCallback = function ()
	        	Utility.showPlayerTeam(info.DefenderId)
	        end,
	        cardShowAttrs = {
	            CardShowAttr.eBorder,
	        },
	    })
	Defender:setAnchorPoint(0.5, 0.5)
	Defender:setPosition(cc.p(320, 80))
	custom_item:addChild(Defender)

    -- 防守方等级名字
    ui.newLabel({
    	text = info.DefenderName,
    	size = 20,
    	color= cc.c3b(0x46, 0x22, 0x0d),
    	x = Defender:getContentSize().width * 0.5,
    	y = -15
    	}):addTo(Defender)

    -- 查看按钮
    ui.newButton({
		normalImage = "c_28.png",
		text = TR("查看"),
		position = cc.p(460, 80),
		clickAction = function ()
			local isWin = false
			local playerId = PlayerAttrObj:getPlayerAttrByName("PlayerId")
			if (info.AttackerId == playerId and info.IsWin) or (info.DefenderId == playerId and not info.IsWin) then
				isWin = true
			end
			local params = {
                AttackerName = info.AttackerName,
                AttackerFAP  = info.AttackerFAP,
                DefenderName = info.DefenderName,
                DefenderFAP  = info.DefenderFAP,
                IsWin        = isWin
            }

			-- 播放战报
			self:fight(info.BattleReportId, params)
		end,
    }):addTo(custom_item)

    -- 胜利标签
    local successSprite = ui.newSprite("qxzb_5.png")
    successSprite:setPosition(90, 85)
    successSprite:setScale(0.8)
    -- 失败标签
    local failSprite = ui.newSprite("qxzb_6.png")
    failSprite:setPosition(90, 90)
    failSprite:setScale(0.8)

    -- 胜利/失败标签
    if info.IsWin then
    	Attacker:addChild(successSprite)
    	Defender:addChild(failSprite)
    else
    	Attacker:addChild(failSprite)
    	Defender:addChild(successSprite)
    end

    return custom_item
end

-- 辅助函数 转换下注ID
function DlgMyFightLogLayer:getBetId(paramId)
    local tTable = {[1] = TR("16强赛"), [2] = TR("8强赛"), [3] = TR("4强赛"), [4] = TR("半决赛"), [5] = TR("决赛")}
    return tTable[paramId]
end

-- 辅助函数 判断是否被输掉比赛
function DlgMyFightLogLayer:figureEnding()
	-- 以最新一场为基准  判断是否被淘汰  服务端排序第一为最新一场
	-- 如最新一场为4强赛 则找出所有4强赛的比赛 判断胜负总数
	local lastist = self.mLogList[1]
	local isEnd = false
	local playerId = PlayerAttrObj:getPlayerAttrByName("PlayerId")

	if lastist.TurnCount == 1 then
		-- 16强赛 淘汰与否就看这场
		if lastist.AttackerId == playerId and lastist.IsWin == false then
			isEnd = true
		end

		if lastist.DefenderId == playerId and lastist.IsWin == true then
			isEnd = true
		end
	end

	-- 8,4,2强赛 BO3 
	if lastist.TurnCount == 2 or lastist.TurnCount == 3 or lastist.TurnCount == 4 then
		local figureList = {}
		local failCont = 0
		-- 遍历所有8强赛
		for k, v in pairs(self.mLogList) do
			if v.TurnCount == 2 then
				table.insert(figureList, v)
			end
		end

		for k, v in ipairs(figureList) do
			if lastist.AttackerId == playerId and lastist.IsWin == false then
				failCont = failCont + 1
			end

			if lastist.DefenderId == playerId and lastist.IsWin == true then
				failCont = failCont + 1
			end
		end

		-- 输掉两场以上
		if failCont >= 2 then
			isEnd = true
		end
	end

	-- 1强赛 BO5
	if lastist.TurnCount == 5 then
		local figureList = {}
		local failCont = 0
		-- 遍历所有1强赛
		for k, v in pairs(self.mLogList) do
			if v.TurnCount == 5 then
				table.insert(figureList, v)
			end
		end

		for k, v in ipairs(figureList) do
			if lastist.AttackerId == playerId and lastist.IsWin == false then
				failCont = failCont + 1
			end

			if lastist.DefenderId == playerId and lastist.IsWin == true then
				failCont = failCont + 1
			end
		end

		-- 输掉三场以上
		if failCont >= 3 then
			isEnd = true
		end
	end

	return isEnd, lastist.TurnCount
end

---------------------网络相关-------------------------------------------
function DlgMyFightLogLayer:fight(BattleReportId, params)
	HttpClient:request({
	    moduleName = "PVPinterTop",
	    methodName = "GetBattleReportContent",
	    svrMethodData = {BattleReportId},
	    callback = function(response)
	    	if response and response.Status ~= 0 then
                return
            end
	        -- 战斗信息
	        -- dump(response.Value.BattleReport, "战斗信息")
            
            local battleInfo = response.Value.BattleReport.ClientRes
            local control = Utility.getBattleControl(ModuleSub.eWhosTheGod)

            local info = params
            battleInfo.IsWin = params.IsWin
            battleInfo.TreasureInfo = nil --服务端返回为0避免报错直接赋值为空
            LayerManager.addLayer({
                name = "ComBattle.BattleLayer",
                data = {
                    data = battleInfo,
                    skip = control.skip,
                    trustee = control.trustee,
                    skill = control.skill,
                    map = Utility.getBattleBgFile(ModuleSub.eChallengeWrestle),-- 用挖矿的地图
                    callback = function(battleResult)
                        PvpResult.showPvpResultLayer(
                            ModuleSub.eShengyuanWars,
                            battleInfo,
                            {
                                PlayerName = info.AttackerName,
                                FAP = info.AttackerFAP,
                            },
                            {
                                PlayerName = info.DefenderName,
                                FAP = info.DefenderFAP,
                            }
                        )
                        if control.trustee and control.trustee.changeTrusteeState then
                            control.trustee.changeTrusteeState(battleResult.trustee)
                        end
                    end
                },
            })
	    end
	})
end

function DlgMyFightLogLayer:getData()
	HttpClient:request({
	    moduleName = "PVPinterTop",
	    methodName = "GetOwnBattleReport",
	    callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- dump(response.Value, "战报")
            self.mLogList = response.Value and response.Value.BattleReport or {}
			self.mIsBattle = response.Value.IsBattle or 0
			-- 创建我的战报
			self:setUI()
        end
	})

	-- data = {
	-- 	BattleReport = {
	-- 		[1] = {
	-- 			AttackerFAP            = 112900551,
	-- 			AttackerFashionModelId = 0,
	-- 			AttackerHeadImageId    = 12010003,
	-- 			AttackerId             = "ef6c2a7f-ccea-46bd-89b1-2a4114f58cb1",
	-- 			AttackerName           = "端木宿命",
	-- 			AttackerZone           = "苗锐",
	-- 			BattleReportId         = "097885d8-7951-4232-a93d-0b4791e7f730",
	-- 			DefenderFAP            = 13140934,
	-- 			DefenderFashionModelId = 19010005,
	-- 			DefenderHeadImageId    = 12011032,
	-- 			DefenderId             = "ee57411d-a196-4320-9a0f-b122f49be212",
	-- 			DefenderName           = "安然",
	-- 			DefenderZone           = "20区 炼体灵决",
	-- 			IsWin                  = 1,
	-- 		}
	-- 	}
	-- }

	-- self.mLogList = data and data.BattleReport or {}
	-- -- 创建我的战报
	-- self:createMyLog()
end

return DlgMyFightLogLayer

