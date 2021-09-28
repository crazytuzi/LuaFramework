 --[[
 --
 -- @authors shan 
 -- @date    2014-08-05 14:17:11
 -- @version 
 --
 --]]

 local data_jingyingfuben_jingyingfuben =  require("data.data_jingyingfuben_jingyingfuben")
 local data_huodongfuben_huodongfuben = require("data.data_huodongfuben_huodongfuben")

local MAX_ZODER = 1001 
local OPENLAYER_ZORDER = MAX_ZODER + 1 

local JINGYING_VIEW = 1
local HUODONG_VIEW = 2
local JIEFUJIPIN_ID = 1 -- 劫富济贫 


local ChallengeScene = class("ChallengeScene", function ( ... )
	return require("game.BaseScene").new({
        contentFile = "challenge/challenge_bg.ccbi",
        subTopFile = "challenge/challenge_up_tab.ccbi", 
        topFile = "public/top_frame_other.ccbi", 
        isOther = true, 
    })
end)

function ChallengeScene:sendJingYingReq()
	
	 -- 获取精英副本list信息
    RequestHelper.JingyingFuBenList({
        callback = function(data)
        	-- print("jinyingdatatat")
        	-- dump(data)
        	JingYingModel.initData(data)
			self:updateJingYingList()
			
        end,       
        })  
end

function ChallengeScene:updateJingYingList()
		self._rootnode["active_num_bg"]:setVisible(false)

		self._rootnode["today_rest_node"]:setVisible(true)
		self._rootnode["today_rest_num"]:setString(JingYingModel.getRestNum())

		self.jingyingRestNum = JingYingModel.getRestNum()

		self:checkDayLeftCnt({jingyingNum = JingYingModel.getRestNum()})

		if JingYingModel.getRestNum() > 0 then
			self._rootnode["jingying_num_bg"]:setVisible(true)
		else
			self._rootnode["jingying_num_bg"]:setVisible(false)
		end

		local maxLv = JingYingModel.getMaxLv()
		local totalNum = maxLv + 2
		local isAllLvlDone = false
	    if totalNum > #data_jingyingfuben_jingyingfuben then
	    	totalNum = #data_jingyingfuben_jingyingfuben
	    	isAllLvlDone = true
	    end

		local function createFunc(idx)
			local item = require("game.Challenge.JingYingCell").new()	        
	        return item:create({
	            viewSize = CCSizeMake(self._rootnode["list_bg"]:getContentSize().width, self._rootnode["list_bg"]:getContentSize().height*0.95),
	            idx      = idx,
	            totalNum = totalNum,
	            isAllLvlDone = isAllLvlDone
	        })     
	    end

	    local function refreshFunc(cell, idx)	    
	        cell:refresh(idx+1,isAllLvlDone)
	    end

	    local itemList = require("utility.TableViewExt").new({
	        size        = CCSizeMake(self._rootnode["list_bg"]:getContentSize().width, self.getCenterHeightWithSubTop()),-- numBg:getContentSize().height - 20),
	        direction   = kCCScrollViewDirectionVertical,
	        createFunc  = createFunc,
	        refreshFunc = refreshFunc,
	        cellNum   = totalNum,
	        cellSize    = CCSize(display.width*0.9,200),--require("game.Arena.ArenaCell").new():getContentSize(),
	        touchFunc = function ( cell )
	        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
				print(totalNum  - cell:getIdx() )-- 因为是反着的  所以需要进行一些处理
				PostNotice(NoticeKey.REMOVE_TUTOLAYER)
				local function removeFunc() 
				self.isTouchJingYingCell = false 
				print("fffffffff")
				end
				if self.isTouchJingYingCell ~= true then
					self.isTouchJingYingCell = true

					if cell:getIsAllowPlay() then
						if JingYingModel.getRestNum() > 0 then							
								local layer = require("game.Challenge.JingYingFuBenInfoBox").new(totalNum  - cell:getIdx(),removeFunc)               
			        			display.getRunningScene():addChild(layer,10000)		
			        		
						else
							removeFunc()
							show_tip_label("当日挑战次数已用完，请明日再战！")
						end
					else
						removeFunc()
	        			show_tip_label("尚未解锁！")
	        		end
				end


        
			end,
	                       
	    })

	    self.listView:removeAllChildren()
	    self.listView:addChild(itemList)

	    local cell = itemList:cellAtIndex(1)
	    if cell ~= nil then
	    	local tutoBtn = cell:getTutoBtn()
	    	TutoMgr.addBtn("jingying_fuben_chuchumaolu",tutoBtn)
		end
		local tuto = self._rootnode["tab2"]
		TutoMgr.addBtn("huodongfuben_tab",tuto)
		TutoMgr.active()	   

end



function ChallengeScene:sendHuoDongReq()
	 -- 获取精英副本list信息
    RequestHelper.HuoDongFuBenList({
        callback = function(data)
        print("huodong data")
        dump(data)
        HuoDongFuBenModel.initData(data)        	
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)		
		self:updateHuoDongList()
        end,       
        })  

end


function ChallengeScene:updateHuoDongList()
	self.huodong_fuben_list = HuoDongFuBenModel.getFubenList()
	self._rootnode["today_rest_node"]:setVisible(false)
	self._rootnode["jingying_num_bg"]:setVisible(false)

	-- 排序 按照order排序 开启（openCnt>0）的放在上面，未开启放在下面 
	local openList = {}
	local closeList = {} 
	for i = 1, #data_huodongfuben_huodongfuben do 
		for k, v in pairs(self.huodong_fuben_list) do 
			local aid = checkint(k) 
			local item = data_huodongfuben_huodongfuben[aid] 
			if item.order == i then 
				if v.openCnt > 0 then 
					table.insert(openList, aid) 
				else
					table.insert(closeList, aid)
				end  
				break 
			end 
		end 
	end 

	local huodongIdList = openList 	
	for i, v in ipairs(closeList) do 
		table.insert(huodongIdList, v)  
	end 

	local dayLeftCnt = 0 
	for k,v in pairs(self.huodong_fuben_list) do 
		dayLeftCnt = dayLeftCnt + v.surplusCnt
	end

	self:checkDayLeftCnt({huodongNum = dayLeftCnt})

	local filename = "game.Challenge.HuoDongCell" 
	local function createFunc(idx)
		local item = require(filename).new()	        
        return item:create({
            viewSize = CCSizeMake(self._rootnode["list_bg"]:getContentSize().width, self._rootnode["list_bg"]:getContentSize().height*0.95),
            aid = huodongIdList[idx + 1], 
            fubenTimes = self.huodong_fuben_list,
            refreshFunc = function() 
            	self:sendHuoDongReq()
        	end
        })     
    end

    local function refreshFunc(cell, idx)  
        cell:refresh(huodongIdList[idx + 1]) 
    end

    local itemList = require("utility.TableViewExt").new({
        size        = CCSizeMake(self._rootnode["list_bg"]:getContentSize().width, self.getCenterHeightWithSubTop()),-- numBg:getContentSize().height - 20),
        direction   = kCCScrollViewDirectionVertical,
        createFunc  = createFunc,
        refreshFunc = refreshFunc,
        cellNum   	= #huodongIdList, 
        cellSize    = require(filename).new():getContentSize(),
        touchFunc = function ( cell ) 
			local actId = huodongIdList[cell:getIdx() + 1] 

			local itemId = HuoDongFuBenModel.getItemID(actId)
			local itemNum =  HuoDongFuBenModel.getItemNum(actId)
			local isEnough = true

			if itemId ~= 0 and itemNum == 0 then
				isEnough = false
			end

			local function toBat()				
				if actId == JIEFUJIPIN_ID then
					local ruleLayer = require("game.Huodong.jiefuRuleLayer").new({
							jumpFunc = function() GameStateManager:ChangeState(GAME_STATE.STATE_HUODONG_BATTLE, actId) end
						})
					display:getRunningScene():addChild(ruleLayer,1000)
				else
					GameStateManager:ChangeState(GAME_STATE.STATE_HUODONG_BATTLE, actId)
				end		
			end 

			if cell:getIsAllowPlay() then
				-- 劫富济贫和其他副本不一样
				if actId == JIEFUJIPIN_ID then 
					if HuoDongFuBenModel.getRestNum(tostring(actId)) > 0  then
						toBat()				
					else
						if cell:getOpenCnt() > 0 then
							if itemId ~= 0 and itemNum > 0 then
								toBat()
							else
								show_tip_label("当日挑战次数已用完，请明日再战！")
							end
						else
							show_tip_label("今日活动未开启")
						end
					end
				else
					local fbInfo = data_huodongfuben_huodongfuben[actId] 
					RequestHelper.challengeFuben.actDetail({
						aid = actId, 
						sysId = fbInfo.sys_id, 
						callback = function(data)
							dump(data)
							if data.err == "" then 
								game.runningScene:addChild(require("game.ChallengeFuben.ChallengeFubenLayer").new({
									fbId = actId, 
									rtnObj = data.rtnObj, 
									refreshCellFunc = function()
										self:sendHuoDongReq() 
									end	
								}), MAX_ZODER)
							end 
						end, 
						}) 
				end 
			else 
				local trueId = actId
				local fubenData = data_huodongfuben_huodongfuben[trueId]

				show_tip_label(fubenData.tips)
			end	
		end,
                       
    })

    self.listView:removeAllChildren()
    self.listView:addChild(itemList)
end


function ChallengeScene:checkDayLeftCnt(param)
	local jingyingNum = param.jingyingNum or game.player:getJingyingNum()
	local huodongNum = param.huodongNum or game.player:getHuodongNum()

	game.player:setJingyingNum(jingyingNum)
	game.player:setHuodongNum(huodongNum) 

	if game.player:getHuodongNum() <= 0 then 
		self._rootnode["active_num_bg"]:setVisible(false)
	else 
		local bHasOpen, _ = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.HuoDong_FuBen, game.player:getLevel(), game.player:getVip()) 
		if not bHasOpen then
			self._rootnode["active_num_bg"]:setVisible(false)
		else
			self._rootnode["active_num_bg"]:setVisible(true)
		end
		self._rootnode["huodong_num"]:setString(tostring(game.player:getHuodongNum()))
	end

	if game.player:getJingyingNum() <= 0 then 
		self._rootnode["jingying_num_bg"]:setVisible(false)
	else 
		local bHasOpen, _ = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.JiYing_FuBen, game.player:getLevel(), game.player:getVip()) 
		if not bHasOpen then
			self._rootnode["jingying_num_bg"]:setVisible(false)
		else
			self._rootnode["jingying_num_bg"]:setVisible(true)
		end 
		self._rootnode["jingying_num"]:setString(tostring(game.player:getJingyingNum()))
	end
end

function ChallengeScene:addJingYingNum()
	if self.jingyingRestNum > 0 then
		ResMgr.showMsg(6)
	else
		local buyMsgBox = require("game.Challenge.JingYingBuyMsgBox").new({aid = actId,
			removeListener = function()
				self:updateJingYingList() 
			end})
        display.getRunningScene():addChild(buyMsgBox,1000)
	end
end


function ChallengeScene:ctor( viewType )
	local viewType = viewType or JINGYING_VIEW
	display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
	game.runningScene = self

	-- TODO
	-- ResMgr.createBefTutoMask(self)

    self.listView = self._rootnode["listView"]
    self.jingyingPlusBtn = self._rootnode["jingying_plus_btn"]

    self.jingyingPlusBtn:addHandleOfControlEvent(function(eventName,sender)
    	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        self:addJingYingNum()
    end,
    CCControlEventTouchUpInside)


    self._rootnode["backBtn"]:addHandleOfControlEvent(function(eventName,sender)
    	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        GameStateManager:ChangeState(GAME_STATE.STATE_MAIN_MENU)
    end,
    CCControlEventTouchUpInside)

    self.viewType = 0

    local function onTabBtn(tag)
    	if self.firstOnTab == nil then
    		self.firstOnTab = false
    	else
	    	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian)) 
	    end
    	local canClick = true 
    	local bHasOpen = false  
    	local prompt 
    	if JINGYING_VIEW == tag then 
            bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.JiYing_FuBen, game.player:getLevel(), game.player:getVip()) 
        elseif HUODONG_VIEW == tag then
        	bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.HuoDong_FuBen, game.player:getLevel(), game.player:getVip()) 
        end 
        
        if not bHasOpen then
            show_tip_label(prompt) 
            canClick = false
        end

        if canClick then 
	        for i = 1, 2 do
	            if tag == i then
	                self._rootnode["tab" ..tostring(i)]:selected()
	            else
	                self._rootnode["tab" ..tostring(i)]:unselected()
	            end
	        end

	        self.viewType = tag

	        if JINGYING_VIEW == tag then
	            self:sendJingYingReq()
	        elseif HUODONG_VIEW == tag then
	            self:sendHuoDongReq()
	        end
	    end 
    end
  --初始化选项卡
    local function initTab()
        for i = 1, 2 do
            self._rootnode["tab" ..tostring(i)]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTabBtn)
        end
        self._rootnode["tab1"]:selected()
    end
    initTab()

    onTabBtn(viewType)


	self.jingying_fuben_list = {}
	self.huodong_fuben_list = {}

	self:checkDayLeftCnt({}) 

	self._bExit = false 

end


function ChallengeScene:onEnter() 
	game.runningScene = self 
	display.addSpriteFramesWithFile("ui/ui_challenge.plist", "ui/ui_challenge.png")
	display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
	    self:regNotice()

	-- 是否开启新系统
    local levelData = game.player:getLevelUpData() 
    if levelData.isLevelUp then 
        local _, systemIds = OpenCheck.checkIsOpenNewFuncByLevel(levelData.beforeLevel, levelData.curLevel) 
        -- dump(systemIds)
        game.player:updateLevelUpData({isLevelUp = false})
        local function createOpenLayer()
            if #systemIds > 0 then 
                local systemId = systemIds[1] 
                self:addChild(require("game.OpenSystem.OpenLayer").new({
                    systemId = systemId, 
                    confirmFunc = createOpenLayer
                }), OPENLAYER_ZORDER) 
                table.remove(systemIds, 1)
            end 
        end 
        createOpenLayer()
    end 
     TutoMgr.active()

    -- 广播
    if self._bExit == true then
        self._bExit = false
        local broadcastBg = self._rootnode["broadcast_tag"]
        if game.broadcast:getParent() ~= nil then
            game.broadcast:removeFromParentAndCleanup(true)
        end
        broadcastBg:addChild(game.broadcast)
    end
end


function ChallengeScene:onExit()
	-- body
	    self:unregNotice()
	TutoMgr.removeBtn("huodongfuben_tab")
	TutoMgr.removeBtn("jingying_fuben_chuchumaolu")
	self._bExit = true 
end


return ChallengeScene