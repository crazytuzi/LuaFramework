--
-- Author: Daneil
-- Date: 2015-02-02 15:40:52
--
require("game.Yabiao.YabiaoFuc")
local data_config_yabiao_config_yabiao = require("data.data_config_yabiao_config_yabiao")
local YabiaoController = class("YabiaoController", function()
    return display.newNode()
end)

function YabiaoController:ctor(param)
	self:init(param)
end

function YabiaoController:init(param)
	self.mainMap = param.map
	self.instance = param.mainscene
    self.repairReQestGroups = {}
	--运镖完成回调
	RegNotice(self,
        function()
        	if BeingRemoveId == game.player.m_playerID then
        		if self._isSpeedUp == true then
        			self:_hasComplete()
        		else
        			self:_runCarComplete()
        		end
        		
        	else
        		self:_getExtraData()
        	end
        end,
    NoticeKey.Yabiao_repair_enemy)

    --开始运镖回调
    RegNotice(self,
        function()
            self:_startRunCar()
        end,
    NoticeKey.Yabiao_run_car)


	local func = function ()
		self:initEnemyCars()
		self:initMyCards()
		self:initExtraData()
		if game.player._yaBiaoCollTime ~= 0 then
			self:refreshCountDown(game.player._yaBiaoCollTime)
		end
	end
	self:_getBaseData(func)

	local repairFuc = function ()
		self:_repaireLogic()
	end
	self._scheduler = require("framework.scheduler")
	self._schedule = self._scheduler.scheduleGlobal(repairFuc, 1 , false )	
end

function YabiaoController:_repaireLogic()

	local function initData(data)
		
		data = {
			{ 
			quality  = 3,
			name  = "name",
			lv = 10,
			roleId  = 12,
			arriveTime  = 30,
			totalTime = 30,
			dartkey = 1
			}
		}

		for k,v in pairs(data) do
			dump(v)
			local temp = { 
				types  = v.quality,
				name  = v.name,
				level = v.lv,
				roleId  = v.roleId,
				time  = v.arriveTime,
				totalTime = self.totalTime,
				dartkey = v.dartkey
			}
			local instance = require("game.Yabiao.YabiaoItemView").new(temp)
			self.mainMap:addChild(instance)
			table.insert(self._enemyExtra,instance)
		end
		
	end

	for k,v in pairs(self.repairReQestGroups) do
		RequestHelper.yaBiaoSystem.refreshSigleEnemy({
				repairIds = v,
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        initData(data.rtnObj)
                    end
                end 
                })
		table.remove(self.repairReQestGroups,k)
		print("pop")
		break
	end
end

function YabiaoController:_hasComplete(data)
	--增加押镖完成界面
	CCDirector:sharedDirector():getRunningScene():addChild(
			require("game.Yabiao.YabiaoCompletePopup").new(
					{confirmFunc = function ()
						self.instance.yabiaoBtn:setDisplayFrame(display.newSprite("#yabiao_btn.png"):getDisplayFrame())
						self.selfState = 1
						if self._hero  then
							for k,v in pairs(self._hero) do
								if v and v.removeSelf then
									v:removeSelf()
									self._hero = {}
								end
							end
						end
					end
					}
				)
		)
	self._isSpeedUp = false
end

--初始化敌方镖车
function YabiaoController:initEnemyCars()
	
	if self._enemy then
		for k,v in pairs(self._enemy) do
			if v and v.removeSelf then
				v:removeSelf()
			end
		end
	end
	if self._enemyExtra then
		for k,v in pairs(self._enemyExtra) do
			if v and v.removeSelf then
				v:removeSelf()
			end
		end
	end

	self._enemy = {}
	self._enemyExtra = {}
	
	self.enemyData = { 

		{ 
			quality  = 3,
			name  = "name",
			lv = 10,
			roleId  = 12,
			arriveTime  = 30,
			totalTime = 30,
			dartkey = 1
		},
		{ 
			quality  = 3,
			name  = "name",
			lv = 10,
			roleId  = 12,
			arriveTime  = 30,
			totalTime = 30,
			dartkey = 1
		}


	}

	for k,v in pairs(self.enemyData) do
		dump(v)
		local temp = { 
			types  = v.quality,
			name  = v.name,
			level = v.lv,
			roleId  = v.roleId,
			time  = v.arriveTime,
			totalTime = self.totalTime,
			dartkey = v.dartkey
		}
		
		local instance = require("game.Yabiao.YabiaoItemView").new(temp)
		self.mainMap:addChild(instance)
		table.insert(self._enemy,instance)
	end



	
	--[[for index = 1 , 15  do
		local temp = { 
			types  = 3,
			name  = "name",
			level = 10,
			roleId  = 12,
			time  = index * 120,
			totalTime = 30,
			dartkey = 1
		}
		local instance = require("game.Yabiao.YabiaoItemView").new(temp)
		self.mainMap:addChild(instance)
		table.insert(self._enemy,instance)
	end--]]
end

function YabiaoController:initExtraData()
	if self.selfState == 1 then
		self.instance.yabiaoBtn:setDisplayFrame(display.newSprite("#yabiao_btn.png"):getDisplayFrame())
	else
		self.instance.yabiaoBtn:setDisplayFrame(display.newSprite("#yabiao_jiasu_btn.png"):getDisplayFrame())
		if self.selfState == 3 then
			self:_hasComplete()
		end
	end


	addTouchListener(self.instance.yabiaoBtn, function(sender,eventType)
    	print(eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
    		sender:setScale(1)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
            if self.selfState == 1 then
            	--押镖
            	self.instance:addChild(require("game.Yabiao.YabiaoSelectView").new())
            elseif self.selfState == 2 then
            	local func = function()
            		--加速押镖
	            	self._isSpeedUp = true
	            	self:_speedUpComplete()
	            	game.player:setGold(game.player:getGold() - data_config_yabiao_config_yabiao[17].value)
    				PostNotice(NoticeKey.CommonUpdate_Label_Gold)
            	end
            	self.instance:addChild(require("game.Yabiao.YabiaoSpeedUpCommitPopup").new(
            		{ 
            			cost = data_config_yabiao_config_yabiao[17].value,
            			disStr = "立即完成押镖",
            			confirmFunc = func
            		}
				))
            end
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)

    addTouchListener(self.instance.shuaxinBtn, function(sender,eventType)
    	print(eventType)
    	if eventType == EventType.began then
    		sender:setScale(0.9)
    	elseif eventType == EventType.ended then
    		sender:setScale(1)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
            if game.player._yaBiaoCollTime ~= 0 then
            	show_tip_label("刷新时间未到")
            	return
            end
            local refresh = function ()
            	--这一步特别重要 清理缓存 要不会随机不出来
            	initTimeGroup()
            	self:initEnemyCars()
            	self:refreshCountDown(coutDownTime)
            end
            self:_refreshData(refresh)
        elseif eventType == EventType.cancel then
        	sender:setScale(1)
        end
    end)
end


--刷新倒计时
function YabiaoController:refreshCountDown(time)
	game.player._yaBiaoCollTime = time
	--倒计时
	self.instance.shuaxinBtn:setDisplayFrame(display.newSprite("#count_down_btn.png"):getDisplayFrame())
	local countDownLabel  = ui.newTTFLabel({  text = format_time(time), 
								size = 25, 
						        align = ui.TEXT_ALIGN_CENTE,
						        color = FONT_COLOR.WHITE,
						        font = FONTS_NAME.font_fzcy })
    countDownLabel:setPosition(cc.p(self.instance.shuaxinBtn:getContentSize().width / 2,self.instance.shuaxinBtn:getContentSize().height / 2))
    countDownLabel:setAnchorPoint(cc.p(0.5,0.5))
    self.instance.shuaxinBtn:addChild(countDownLabel)
    local countDown = function()
		countDownLabel:setString(format_time(game.player._yaBiaoCollTime))
		if game.player._yaBiaoCollTime == 0 then
			self._schedulerCountDown.unscheduleGlobal(self._schedules)
			self.instance.shuaxinBtn:setDisplayFrame(display.newSprite("#shuaxin_btn.png"):getDisplayFrame())
			self.instance.shuaxinBtn:removeAllChildren()
		end
	end
	self._schedulerCountDown = require("framework.scheduler")
	self._schedules = self._schedulerCountDown.scheduleGlobal(countDown, 1, false )	
end

--初始化我方的镖车
function YabiaoController:initMyCards()
	self._hero = {}
	local v = self.heroData
	if not v.name then
		return 
	end
	local temp = { 
			types  = v.quality,
			name  = v.name,
			level = v.lv,
			time  = v.arriveTime,
			roleId  = v.roleId,
			totalTime = self.totalTime,
			dartkey = v.dartkey,
			mid = true
		}
	self.selfState = 2	
	local instance = require("game.Yabiao.YabiaoItemView").new(temp)
	self.mainMap:addChild(instance)
	table.insert(self._hero,instance)
	self.instance.yabiaoBtn:setDisplayFrame(display.newSprite("#yabiao_jiasu_btn.png"):getDisplayFrame())

	
	--矫正位置
	--self.mainMap:setPositionY(0 - instance:getY())
	
end

--清除定时器
function YabiaoController:clearTimer()

	if self._enemy then
		for k,v in pairs(self._enemy) do
			if v and v.removeSelf then
				v:removeSelf()
			end
		end
	end
	if self._enemyExtra then
		for k,v in pairs(self._enemyExtra) do
			if v and v.removeSelf then
				v:removeSelf()
			end
		end
	end
	if self._hero  then
		for k,v in pairs(self._hero) do
			if v and v.removeSelf then
				v:removeSelf()
			end
		end
	end
	self._enemy = {}
	self._enemyExtra = {}
	self._hero = {}

	UnRegNotice(self, NoticeKey.Yabiao_repair_enemy)
	UnRegNotice(self, NoticeKey.Yabiao_run_car)

	if self._schedules then
		self._schedulerCountDown.unscheduleGlobal(self._schedules)
	end
	if self._schedule then
		self._scheduler.unscheduleGlobal(self._schedule)
	end
end

--创建自己的镖车
function YabiaoController:_startRunCar()
	self._hero = {}
	local temp = { 
			types     = selfCarInfo.types,
			name      = selfCarInfo.name,
			level     = selfCarInfo.level,
			roleId    = selfCarInfo.roleId,
			dartkey   = selfCarInfo.dartkey,
			time      = self.totalTime * 60,
			totalTime = self.totalTime,
			mid       = true
		}
	self.selfState = 2
	local instance = require("game.Yabiao.YabiaoItemView").new(temp)
	self.mainMap:addChild(instance)
	table.insert(self._hero,instance)
	self.instance.yabiaoBtn:setDisplayFrame(display.newSprite("#yabiao_jiasu_btn.png"):getDisplayFrame())
end

---
-- 进入押镖系统基本数据请求
function YabiaoController:_getBaseData(func)

	local function initData(data)
		self.enemyData = {}
		for k,v in pairs(data.otherDartCar) do
			table.insert(self.enemyData, v) 
		end
		self.totalTime = data.lastTime
		self.selfState = data.selfState
		self.heroData = data.selfDartCar
		func()
	end
	RequestHelper.yaBiaoSystem.getBaseInfo({
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        initData(data.rtnObj)
                    end
                end 
                })
end

---
-- 当有玩家押镖完成时候进行补位请求
function YabiaoController:_getExtraData()

	--[[local function initData(data)
		for k,v in pairs(data) do
			dump(v)
			local temp = { 
				types  = v.quality,
				name  = v.name,
				level = v.lv,
				time  = v.arriveTime,
				totalTime = self.totalTime
			}
			local instance = require("game.Yabiao.YabiaoItemView").new(temp)
			self.mainMap:addChild(instance)
			table.insert(self._enemyExtra,instance)
		end
	end
	RequestHelper.yaBiaoSystem.refreshSigleEnemy({
				repairIds = BeingRemoveId,
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        initData(data.rtnObj)
                    end
                end 
                })--]]
	print("push---------")
	self.repairReQestGroups[#self.repairReQestGroups + 1] = BeingRemoveId
	print(BeingRemoveId)
end

---
-- 加速押镖
function YabiaoController:_speedUpComplete()

	local function initData(data)
		self.rewords = data
		for k,v in pairs(self._hero) do
			v._time = 0
			v:removeSelf()
			self._hero = {}
		end
		game.player._yaBiaoCollTime = 1
		self:_hasComplete()
	end
	RequestHelper.yaBiaoSystem.beginRunWithSpeedUp({
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        initData(data.rtnObj)
                    end
                end 
                })
end

---
-- 押镖完成
function YabiaoController:_runCarComplete()
	
	local function initData(data)
		self.rewords = data
		self:_hasComplete()
	end
	RequestHelper.yaBiaoSystem.getRewords({
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        initData(data.rtnObj)
                    end
                end 
                })
end

--刷新(全刷)
function YabiaoController:_refreshData(func)
	local function initData(data)
		self.enemyData = {}
		for k,v in pairs(data) do
			table.insert(self.enemyData, v) 
		end
		func()
	end
	RequestHelper.yaBiaoSystem.refreshAllEnemy({
                callback = function(data)
                    dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        initData(data.rtnObj)
                    end
                end 
                })
end

return YabiaoController


