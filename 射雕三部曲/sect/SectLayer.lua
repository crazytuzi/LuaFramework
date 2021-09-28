--[[
    文件名: SectLayer.lua
    描述: 八大门派大地图界面
    创建人: lengjiazhi
    创建时间: 2017.08.24
-- ]]
local SectLayer = class("SectLayer", function(params)
	return display.newLayer()
end)

function SectLayer:ctor()
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)
	self:getSectInfo()
	self:initUI()
	self:requestGetTimedActivityInfo()
end

function SectLayer:initUI()
	local bgSprite = ui.newSprite(SectModel.items[self.mSectInfo.SectId].backPic..".jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite, -1)

	--关闭按钮
    local cancelBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(580, 1040),
        clickAction = function ()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(cancelBtn, 1)

   	-- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        -- currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {
            ResourcetypeSub.eSTA,
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eGold
        }
    })
    self:addChild(topResource, 4)
    self:createBuild()
    self:playerEffect()
	self:createTopView()
	self:handleChamber()
end

--创建上部分显示及操作按钮
function SectLayer:createTopView()
	--职位
	local sectLvBgSprite = ui.newSprite("mp_32.png")
	sectLvBgSprite:setPosition(320, 1000)
	self.mParentLayer:addChild(sectLvBgSprite)

	local sectLvSprite = ui.newSprite(SectRankModel.items[self.mSectInfo.SectRank].pic..".png")
	sectLvSprite:setPosition(78, 30)
	sectLvBgSprite:addChild(sectLvSprite)

	local maxValue
	if self.mSectInfo.SectRank <= 1 then
		maxValue = SectRankModel.items[self.mSectInfo.SectRank].needSectCoinMin
	else
		maxValue = SectRankModel.items[self.mSectInfo.SectRank - 1].needSectCoinMin
	end
	--声望进度条
	local sectScoreBar = require("common.ProgressBar"):create({
                bgImage = "mp_30.png",
                barImage = "mp_29.png",
                currValue = self.mSectInfo.TotalSectCoin,
                maxValue = maxValue,
                needLabel = true,
                percentView = false,
                size = 20,
                color = Enums.Color.eNormalWhite,
            })
	sectScoreBar:setPosition(320, 1050)
	self.mParentLayer:addChild(sectScoreBar)
	--声望总览按钮
	local sectScoreViewBtn = ui.newButton({
		normalImage = "mp_27.png",
		clickAction = function()
			LayerManager.addLayer({
					name = "sect.SectPrestigeLayer",
					cleanUp = false
				})
		end
		})
	sectScoreViewBtn:setPosition(60, 1030)
	self.mParentLayer:addChild(sectScoreViewBtn)
	-- 职阶预览按钮
	local rankPreviewBtn = ui.newButton({
			normalImage = "c_79.png",
			clickAction = function ()
				self:createRankLayer()
			end
		})
	rankPreviewBtn:setPosition(450, 1000)
	self.mParentLayer:addChild(rankPreviewBtn)
	--弟子排行按钮
	local rankBtn = ui.newButton({
		normalImage = "mp_26.png",
		clickAction = function()
			LayerManager.addLayer({
					name = "sect.SectRankMainLayer",
				})
		end
		})
	rankBtn:setPosition(60, 830)
	self.mParentLayer:addChild(rankBtn)

	--我的功法按钮
	local myBookBtn = ui.newButton({
		normalImage = "mp_28.png",
		clickAction = function()
			LayerManager.addLayer({
					name = "sect.SectMyBookLayer",
					cleanUp = false
				})
		end
		})
	myBookBtn:setPosition(60, 930)
	self.mParentLayer:addChild(myBookBtn)

	-- 退出门派
	local exitBtn = ui.newButton({
			normalImage = "mp_66.png",
			clickAction = function ()
				self:requestExit()
			end
		})
	exitBtn:setPosition(60, 730)
	self.mParentLayer:addChild(exitBtn)
end

function SectLayer:createBuild()
	local buildListInfo = {}
	self.mBulidList = {}
	local buildModel = SectBuildModel.items
	for k,v in pairs(buildModel) do
		if v.sectModelID == self.mSectInfo.SectId then
			table.insert(buildListInfo, v)
		end
	end

	table.sort(buildListInfo,function(a, b)
		if a.num ~= b.num then
			return a.num < b.num
		end
	end)
	local redDotModules = {
		[1] = ModuleSub.eSectShop,
		[2] = ModuleSub.eSectTask,
		[4] = ModuleSub.eSectPalace,
	}
	for i,item in ipairs(buildListInfo) do
		local buildBtn = ui.newButton({
			normalImage = item.pic..".png",
			clickAction = function ()
				self:buildCallFunc(item.num)
			end
			})
		buildBtn:setPosition(Utility.analysisPoints(item.mapPoint))
		self.mParentLayer:addChild(buildBtn)
		self.mBulidList[item.num] = buildBtn

		-- 添加小红点
		local currentModuleId = redDotModules[i]
		if currentModuleId then
			local function dealRedDotVisible(redDotSprite)
        	    redDotSprite:setVisible(RedDotInfoObj:isValid(currentModuleId))
        	end
        	ui.createAutoBubble({parent = buildBtn, eventName = RedDotInfoObj:getEvents(currentModuleId), refreshFunc = dealRedDotVisible})
        end
	end

    -- 创建BOSS入侵气泡
    ui.createFlashAutoIcon({parent = self.mBulidList[3], moduleId = ModuleSub.eWorldBoss, clickAction = function (pSender)
            self:buildCallFunc(3)
        end, position = cc.p(0.55, 0.7), anchor = cc.p(0.21, 0.08), imgName = "mjrq_11.png"})

    -- 注册boss血量改变事件
    Notification:registerAutoObserver(self.mBulidList[3], function(node, data)
        if data <= 0 then
            RedDotInfoObj:setSocketRedDotInfo({[tostring(ModuleSub.eWorldBoss)] = {Default=false}})
        end
    end, EventsName.eBossHpChanged)
end

--点击建筑回调函数
function SectLayer:buildCallFunc(num)
	if num == 1 then --商店
		LayerManager.addLayer({
				name = "sect.SectBookLayer",
			})
	elseif num == 2 then -- 任务
		LayerManager.addLayer({
			name = "sect.SectTaskLayer",
			data = {}
		})
	elseif num == 3 then --探索
		LayerManager.addLayer({
			name = "sect.SectBigMapLayer",
			data = {}
		})
	elseif num == 4 then --地宫
		if ModuleInfoObj:moduleIsOpen(ModuleSub.eSectPalace, true) then
			LayerManager.addLayer({
				name = "sect.SectPalaceHomeLayer",
			})
		end
	end
end

-- 创建门派称号预览弹窗
function SectLayer:createRankLayer()
	-- 列表大小
	local listSize = cc.size(540, 580)
	-- 项大小
	local itemSize = cc.size(520, 120)
	-- 创建一项
	local function createItem(itemData)
		local itemLayout = ccui.Layout:create()
		itemLayout:setContentSize(itemSize)

		-- 背景
		local bgSprite = ui.newScale9Sprite("c_18.png", itemSize)
		bgSprite:setPosition(itemSize.width*0.5, itemSize.height*0.5-5)
		itemLayout:addChild(bgSprite)
		-- 职阶图
		local rankSprite = ui.newSprite(itemData.pic..".png")
		rankSprite:setPosition(itemSize.width*0.2, itemSize.height*0.5)
		bgSprite:addChild(rankSprite)
		-- 需要声望
		local needCoinLabel = ui.newLabel({
				text = TR("声望要求: %s%d", "#d17b00", itemData.needSectCoinMin),
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 24,
			})
		needCoinLabel:setAnchorPoint(cc.p(0, 0.5))
		needCoinLabel:setPosition(itemSize.width*0.5, itemSize.height*0.5)
		bgSprite:addChild(needCoinLabel)

		return itemLayout
	end
	-- 弹窗回掉函数
	local function DIYfunc(boxRoot, bgSprite, bgSize)
		-- 列表背景
		local listBg = ui.newScale9Sprite("c_17.png", listSize)
		listBg:setPosition(bgSize.width*0.5, bgSize.height*0.48)
		bgSprite:addChild(listBg)
		-- 称号列表
		local listView = ccui.ListView:create()
    	listView:setDirection(ccui.ScrollViewDir.vertical)
    	listView:setBounceEnabled(true)
    	listView:setContentSize(cc.size(listSize.width, listSize.height-20))
    	listView:setItemsMargin(5)
    	listView:setGravity(ccui.ListViewGravity.centerHorizontal)
    	listView:setAnchorPoint(cc.p(0.5, 0.5))
    	listView:setPosition(listSize.width*0.5, listSize.height*0.5)
    	listBg:addChild(listView)
    	-- 填充列表
    	for _, value in ipairs(SectRankModel.items) do
    		local item = createItem(value)
    		listView:pushBackCustomItem(item)
    	end
	end
	-- 创建对话框
    LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
        	bgSize = cc.size(600, 700),
            notNeedBlack = true,
            DIYUiCallback = DIYfunc,
        	title = TR("门派称号"),
        	closeBtnInfo = {},
        	btnInfos = {},
        }
    })
end

--创建地宫双倍气泡
function SectLayer:createPalaceTip()
	local size = self.mBulidList[4]:getContentSize()

	local tipSprite = ui.newSprite("mp_169.png")
	tipSprite:setPosition(size.width * 0.5, size.height * 0.8)
	self.mBulidList[4]:addChild(tipSprite)
	self.mChamberSprite = tipSprite

	local action = cc.Sequence:create({
		cc.ScaleTo:create(1, 0.9),
		cc.ScaleTo:create(1, 1)
		})
	tipSprite:runAction(cc.RepeatForever:create(action))
end

--创建迷宫气泡
function SectLayer:createChamberTip()
	local size = self.mBulidList[3]:getContentSize()

	local tipSprite = ui.newSprite("mp_33.png")
	tipSprite:setPosition(size.width * 0.8, size.height * 0.9)
	self.mBulidList[3]:addChild(tipSprite)
	self.mChamberSprite = tipSprite

	local action = cc.Sequence:create({
		cc.ScaleTo:create(1, 0.9),
		cc.ScaleTo:create(1, 1)
		})
	tipSprite:runAction(cc.RepeatForever:create(action))

	self:updateChamber()
    self.mSchelTime = Utility.schedule(self, self.updateChamber, 1.0)
end

-- 迷宫计时器
function SectLayer:updateChamber()
    local timeLeft = self.mChamberInfo.ChamberEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        -- self.mTimeLabel:setString(TR(MqTime.formatAsDay(timeLeft)))
    else
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
            ui.showFlashView(TR("地宫已消失"))
            self.mChamberSprite:removeFromParent()
            self.mChamberSprite = nil
        end
    end
end

-- 播放特效
function SectLayer:playerEffect()
	-- 创建特效层
	local effectLayer = display.newLayer()
	effectLayer:setContentSize(cc.size(640, 1136))
	self.mParentLayer:addChild(effectLayer)
	-- 全真教
	if self.mSectInfo.SectId == 1 then
		local xianheNum = 3			 -- 仙鹤数量
		local xianheSpace = 100 	 -- 仙鹤之间间隔
		local xianheSpeed = 100 	 -- 仙鹤飞行速度
		local xianheStartAngle = 135 -- 仙鹤初始角度
		-- 获取两点间夹角
		local function getAngle(p1, p2)
			local x = p2.x - p1.x
			local y = p2.y - p1.y
			local angle = math.atan2(y, x)*180/math.pi
			return angle 	-- 180 ～ -180
		end
		-- 创建移动路线
		local function createRouteMove(startPos, endPos)
			-- 总路程
			local distance = math.sqrt(math.pow(endPos.x - startPos.x, 2) + math.pow(endPos.y - startPos.y, 2))
			-- 移动时间
			local time = distance/xianheSpeed
			-- 起点与终点夹角
			local angle = xianheStartAngle - getAngle(startPos, endPos)
			-- 循环创建仙鹤
			for i = 1, xianheNum do
				-- 间隔时间
				local spaceTime = (i-1)*xianheSpace/xianheSpeed
				-- 延时创建仙鹤及路线
				Utility.performWithDelay(self.mParentLayer, function ()
					-- 创建一只仙鹤
					function createOneXianhe(beginPosition, endPosition)
						local effect = ui.newEffect({
							parent = effectLayer,
							effectName = "effect_ui_xianhe",
							position = beginPosition,
							loop = true,
						})
					
						effect:setScale(0.2)
						effect:setRotation(angle)

						local move = cc.MoveTo:create(time, endPosition)
						local callAction = cc.CallFunc:create(function (node)
							node:removeFromParent()
						end)
						local seqAction = cc.Sequence:create(move, callAction)
						effect:runAction(seqAction)

						return effect
					end

					createOneXianhe(startPos, endPos)
				end, spaceTime)
			end

			return allTime
		end
		-- 路线列表
		local routeList = {
			[1] = {startPos = cc.p(800, 600), endPos = cc.p(-100, 1000)},
			[2] = {startPos = cc.p(-100, 200), endPos = cc.p(800, 800)},
		}
		-- 动作列表
		local actionList = {}
		-- 遍历路线
		for _, route in pairs(routeList) do
			-- 创建路线动作
			local callAction = cc.CallFunc:create(function ()
				createRouteMove(route.startPos, route.endPos)
			end)
			-- 创建延时动作
			local distance = math.sqrt(math.pow(route.endPos.x - route.startPos.x, 2) + math.pow(route.endPos.y - route.startPos.y, 2))
			local time = distance/xianheSpeed
			local delayAction = cc.DelayTime:create(time)
			-- 加入列表
			table.insert(actionList, callAction)
			table.insert(actionList, delayAction)
		end
		-- 创建序列动作
		local seqAction = cc.Sequence:create(actionList)
		-- 创建重复动作
		local repeatAction = cc.RepeatForever:create(seqAction)
		-- 播放动作
		effectLayer:runAction(repeatAction)
		
	-- 古墓
	elseif self.mSectInfo.SectId == 2 then
		ui.newEffect({
			parent = effectLayer,
			effectName = "effect_ui_gumuliushui",
			position = cc.p(505, 360),
			loop = true,
		})
	-- 武当
	elseif self.mSectInfo.SectId == 3 then
		ui.newEffect({
				parent = effectLayer,
				position = cc.p(320, 560),
				effectName = "effect_ui_wudangpai",
				loop = true,
			})
	-- 峨眉
	elseif self.mSectInfo.SectId == 4 then
		-- 花瓣
		ui.newEffect({
				parent = effectLayer,
				position = cc.p(320, 560),
				effectName = "effect_ui_emeipai",
				animation = "huaban",
				loop = true,
			})
		-- 水波
		ui.newEffect({
				parent = effectLayer,
				position = cc.p(320, 568),
				effectName = "effect_ui_emeipai",
				animation = "shuibowen",
				loop = true,
			})
	end
end

--==========================================网络请求==========================================
function SectLayer:getSectInfo()
	self.mSectInfo = clone(SectObj:getPlayerSectInfo())
end

--获取迷宫信息
function SectLayer:handleChamber()
    self.mChamberInfo = SectObj:getChamberInfo()
    self.mChamberPosId = self.mChamberInfo.ChamberLocationId
    local endTime = self.mChamberInfo.ChamberEndTime or 0
    local curTime = Player:getCurrentTime()
    local leftTime = endTime - curTime
    local passedTime = SectConfig.items[1].chamberTime - leftTime

    if endTime == 0 then
        print("没有迷宫")
    else
        if endTime < curTime then
            print("迷宫过期")
        else
            self:createChamberTip()
        end
    end
end

-- 退出门派
function SectLayer:requestExit()
	MsgBoxLayer.addOKCancelLayer(
		TR("退出门派后，进行中的门派任务会视为自动放弃，是否确认退出？"),
		TR("退出门派"),
		{
			text = TR("确定"),
			clickAction = function ()
				SectObj:requestExitSect(SectObj:getPlayerSectInfo().SectId, function()
			    	-- 跳转游戏主界面
			        LayerManager.addLayer({
			            name = "home.HomeLayer"
			        })
				end)
			end,
		}
	)
    
end

-- 请求服务器，获取所有已开启的福利多多活动的信息
function SectLayer:requestGetTimedActivityInfo()
    HttpClient:request({
        moduleName = "TimedInfo",
        methodName = "GetTimedActivityInfo",
        callbackNode = self,
        callback = function (data)
            -- dump(data, "requestGetTimedActivityInfo")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            for i,v in ipairs( data.Value.TimedActivityList) do
                if v.ActivityEnumId == TimedActivity.eSalesSectPalace then -- 有地宫翻倍活动
                    -- 创建地宫双倍气泡
                    self:createPalaceTip()
                    break
                end
            end
        end
    })
end

return SectLayer
