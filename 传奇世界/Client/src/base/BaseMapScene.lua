local BaseMapScene = class("BaseMapScene", require("src/base/BaseMapNetNode"))

local commConst = require("src/config/CommDef");
--local activityDelayFun = nil    --活动数据延迟执行
local delayTime,delayTime1 = 0,0
local posY_bottomButton = 35
local duration_buttonSlide = 0.2
local duration_small_gap_between_bottom_btns = 0.05
G_UPDATE_TIME_SPAN = 5
local tag_mb_bg = 55
--require "src/layers/role/red_dot"
require "src/layers/pay/PayView"
require "src/layers/shop/shopLayer"
require "src/layers/random_versus/versus_view"
require("src/layers/expBall/expBallHandler")
-- 主界面zorder规划
-- 主界面信息提示层(tips messageBox) - 400
-- 主界面特效层(新手引导 濒死 等) - 300
-- 主界面子功能(主角 好友等) - 200
-- 主界面按钮菜单 聊天信息 - 100
-- 主界面 - 0
function BaseMapScene:reInit()
	BaseMapScene.full_mode = false
	BaseMapScene.hide_task = false
	BaseMapScene.hide_topIcons = false
	BaseMapScene.Shrank_mode = nil
	BaseMapScene.skill_cds = {}
	BaseMapScene.prop_cds = {}
	BaseMapScene.red_points = require("src/base/RedPoints")
	require("src/base/MapBaseLayer").max_tips_time = 0
end

function BaseMapScene:processEquipButtonRedDot()
--[[
    local forge = require("src/config/Forge")
    local bool_has_one_item_enough_rongLian_daZao = false
	local player_money = MRoleStruct:getAttr(PLAYER_MONEY) or 0
	local player_vital = MRoleStruct:getAttr(PLAYER_VITAL) or 0
    --装备打造合成红点
    for k, v in pairs(forge) do
        while true do
            local q_forgeCost = assert(loadstring("return " .. v.q_forgeCost))()
            local bool_enough = true
            for item_id, item_count in pairs(q_forgeCost) do
                if item_id == 777777 and item_count > player_vital then--声望
                    bool_enough = false
                    break
                end
                if item_id == 999998 and item_count > player_money then--金币
                    bool_enough = false
                    break
                end
                if item_id ~= 999998 and item_id ~= 777777 and item_count > MPackManager:getPack(MPackStruct.eBag):countByProtoId(item_id) then--道具:除了以上两种材料，其他都认为是道具，如果有不同的情况，程序崩溃，到时扩展程序
                    bool_enough = false
                    break
                end
            end
            if bool_enough then
                bool_has_one_item_enough_rongLian_daZao = true
            end
            break
        end
        if bool_has_one_item_enough_rongLian_daZao then
            break
        end
    end
    --熔炼红点
    if G_RED_DOT_DATA.bool_shallShowSmelterRedDot then
        bool_has_one_item_enough_rongLian_daZao = true
    end
    if bool_has_one_item_enough_rongLian_daZao then
        self.red_points:insertRedPoint(6, 2)
    else
        self.red_points:removeRedPoint(6, 2)
    end
    ]]
    if G_RED_DOT_DATA.bool_shallShowSmelterRedDot then
        self.red_points:insertRedPoint(6, 2)
    else
        self.red_points:removeRedPoint(6, 2)
    end
end
--刷新背包上的红点
function BaseMapScene:updateBagRedPoint()
	if self.bag_redPoint then
		local redPointVisible=false
		local bag=MPackManager:getPack(MPackStruct.eBag)
		if (bag:countByProtoId(1017)+bag:countByProtoId(1018))>0 then
			redPointVisible=true
		end
		self.bag_redPoint:setVisible(redPointVisible)
	end
end
function BaseMapScene:ctor(buff,param)
	if not (param and param[1] and buff) then 
		return
	end
	G_MAINSCENE = self

    -------------------------------------主界面的空白屏蔽事件块[仅拦截事件，完全透明]---------------------------------------------
    -- PKmode 按钮扩大范围
    self.m_attackmodeSpan = nil;
    -- 挂机按钮扩大选区
    self.m_hangupSpan = nil;
    -------------------------------------------------------------------------------------------------------------------------------

	--local bg = createSprite(self,"res/mainui/bg.png",g_scrCenter,nil,0)
	--bg:setScale(g_scrSize.width/960,g_scrSize.height/640)
	--self:createMapLayer()
	cc.SpriteFrameCache:getInstance():addSpriteFramesWithFileEx("res/mainui/mainui@0.plist", false, false)
	self.mainui_node = createMainUiNode(self,20)
	self.tick_time = 0
	self.t_time = 0
	userInfo.noNetTransforTime = 0
	self.eatDrugCheck = 0
	self.bag_full_time = 0
	self.shouldShowDrug = {}
	self.inviteTeamId = 0
	self.base_node = cc.Layer:create()
	self.base_node:setPosition(cc.p(0,0))
	self:addChild(self.base_node, commConst.ZVALUE_UI)
	self:registerMsgHandler()
	self.entryBtn = nil	
	self.isHide_icon = false
	self.isOnlyShowTeamNode = false
	self:initializePre(param[3],param[2])
	schedule(self,function() self:update() end,0.25)
    local func_changed_item_baseMapScene = function(observable, event, pos, pos1, new_grid)
        if not (event == "-" or event == "+" or event == "=") then return end
        --self:processEquipButtonRedDot()
        self:updateBagRedPoint()
    end
    --[[
    local func_changed_gold_baseMapScene = function(observable, attrId, objId, isMe, attrValue)
        if not isMe then return end
        if attrId ~= PLAYER_MONEY and attrId ~= PLAYER_VITAL then return end
        self:processEquipButtonRedDot()
    end
    ]]
	self:registerScriptHandler(function(event)
		if event == "enter" then

			G_MAINSCENE = self  
			local handler = require("src/layers/newEquipment/NewEquipmentHandler")
			MPackManager:getPack(MPackStruct.eBag):register(handler)
			self.newEquipmentHandler = handler
			MPackManager:getPack(MPackStruct.eBag):register(expBallMessage)
			if self.buffLayer then self.buffLayer:clearFun() end
			self.buffLayer = nil
			TOPBTNMG = nil
			if DATA_Activity.___arrowBtn and tablenums(DATA_Activity.___arrowBtn.btns)~=0 then 
				for key ,v in pairs(DATA_Activity.___arrowBtn.btns) do
					removeFromParent(v) 
					DATA_Activity.___arrowBtn[key] = nil 
				end
			end
			TIPS( { type = 5 } ) --检测跑马灯
			if DATA_Battle then DATA_Battle.D.time = nil end
            MPackManager:getPack(MPackStruct.eBag):register(func_changed_item_baseMapScene)
            --MRoleStruct:register(func_changed_gold_baseMapScene)
            --self:processEquipButtonRedDot()
		elseif event == "exit" then
			if DATA_Battle then DATA_Battle.D.time = nil end
			MPackManager:getPack(MPackStruct.eBag):unregister(expBallMessage)
			if self.buffLayer and self.buffLayer.clearFun then self.buffLayer:clearFun() end
			self.buffLayer = nil
			TOPBTNMG = nil
			G_MAINSCENE = nil
			if DATA_Activity.___arrowBtn and tablenums(DATA_Activity.___arrowBtn.btns)~=0 then 
				for key ,v in pairs(DATA_Activity.___arrowBtn.btns) do
					removeFromParent(v) 
					DATA_Activity.___arrowBtn[key] = nil 
				end
			end
			MPackManager:getPack(MPackStruct.eBag):unregister(self.newEquipmentHandler)
			self.newEquipmentHandler = nil
            MPackManager:getPack(MPackStruct.eBag):unregister(func_changed_item_baseMapScene)
            --MRoleStruct:unregister(func_changed_gold_baseMapScene)
		end
	end)
	self:showTipLayer()
	self:theFinalLayer()
end

function BaseMapScene:initializePre(mapid,objId)
	self.topLeftNode = cc.Node:create()
	self.mainui_node:addChild(self.topLeftNode, 2)	
	self.topRightNode = cc.Node:create()
	self.mainui_node:addChild(self.topRightNode, 100)
	self.taskBaseNode = cc.Node:create()
    self.taskBaseNode:setPosition(0, (g_scrSize.height-640)/2);
	self.mainui_node:addChild(self.taskBaseNode, 100)
	self.tasknewFunctionNode = cc.Node:create()
	self:addChild(self.tasknewFunctionNode, 100)	
	self.tutoNode = require("src/layers/tuto/TutoTrigger").new()
	self.nfTriggerNode = require("src/layers/newFunction/NewFunctionTriggerNode").new()
	self:addChild(self.tutoNode)
	self:addChild(self.nfTriggerNode)
	G_TUTO_NODE = self.tutoNode
	G_NFTRIGGER_NODE = self.nfTriggerNode
	self:createHeadInfo()
	--self:createChargeInfo()
	self:createExtNode()
	self:addTsxlEffect(G_ROLE_MAIN and g_buffs_ex and g_buffs_ex[G_ROLE_MAIN.obj_id] and g_buffs_ex[G_ROLE_MAIN.obj_id][30])
	local operate_node = OperateLayer:create()
	self:addChild(operate_node,6)
	self.operate_node = operate_node
	self:changeLeftRightMode()
	--self:createNearBtn()
	self:initHangUpCheck()

	self:isShowTeamNodeMap(mapid)
	if __TASK then 
		if tolua.cast(__TASK,"cc.Node") then removeFromParent(__TASK) end
		__TASK = nil 
	end
	__TASK = require( "src/layers/mission/MissionLayer" ).new( { parent = self.taskBaseNode } )
	__TASK:hideIcon(self.isHide_icon or BaseMapScene.hide_task )
	local cb = function()
		self:createBottomBtn()
		self:createHangNode()
		self:createChatPanel()

		local topLayer = require("src/base/TopBtns").new( self.topRightNode)
		self.topBtnNode = topLayer
		if self.isHide_icon then
			topLayer:hideTop(true)
		end
		
		-- self:createTopBtn2()
		-- self:addOutspreadShrankNode()
		G_TUTO_NODE:setTouchNode(operate_node:getChildByTag(1), TOUCH_MAIN_ROCKING)

		self:addBuffNode()
		--self:recoverBtns()
		--self:addBuffNode2()  
		self:addTopNode()
		self:addLineNode()
		self:setFullShortNode(false, true)
		self:showMail()

		if not SOCIAL_DATA then 
			require("src/layers/role/enemyShow"):init() 
		elseif SOCIAL_DATA.isHave then
			self:showEnemyHead()
		end   --仇人展示数据

		--延时初始化活动
		if activityDelayFun then  activityDelayFun(objId)  end


	 	--3秒后还没有主线任务推送就主动请求
		__TaskAskFun = function()
			local taskID = getLocalRecordByKey( 2 , "plot_taskID" .. tostring( userInfo.currRoleStaticId  )  )
			if G_ROLE_MAIN then
				g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_DEALLOADING, "DealLoadingProtocol", { taskID = tonumber(taskID) } )
			end
		end
		performWithDelay(self, function() if __TaskAskFun then __TaskAskFun() end end , 5 )
		performWithDelay(self, function() if DATA_Mission then DATA_Mission:setFindPath( true ) end end , 5 ) --可以支持支线自动寻路了 

		g_msgHandlerInst:sendNetDataByTableExEx(RANK_CS_GLAMOUR_REQ, "RankGlamour", {})
		g_msgHandlerInst:sendNetDataByTableExEx(RANK_CS_GET_NO1_DATA, "RankGetNo1Protocol", {})
		g_msgHandlerInst:sendNetDataByTableExEx(MANORWAR_CS_GET_LEADERINFO, "ManorGetLeaderInfoProtocol", {manorID = 1})
		g_msgHandlerInst:sendNetDataByTableExEx(DIGMINE_CS_OPEN, "DigMineOpen", {})
		g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_GET_SHARED_TASK_TIMES, "GetSharedTaskTimesProtocol", {})
		g_msgHandlerInst:sendNetDataByTableExEx(SHAWAR_CS_GETLEADER, "ShaGetLeaderProtocol", {})
		g_msgHandlerInst:sendNetDataByTableExEx(GIVEWINE_CS_GETWINE_NUM, "GetWineNumReqProtocol", {})
		g_msgHandlerInst:sendNetDataByTableExEx(MANORWAR_CS_GETOWNFACTION, "GetOwnFactionProtocol", {})
	
		self:reloadSkillConfig()
		self:createDyingLayer()
		if not self.targetAwards and not G_MAINSCENE.map_layer.isfb  then
			self:createTargetAwards()
		end
	end
	performWithDelay(self, cb, 0.0)

	local cb = function()
		require("src/functional/CombatPowerUp"):listen()		
	end
	performWithDelay(self,cb,3.0)

	local cb = function()
		if not G_ROLE_MAIN then
			return
		end
		self:hideTopIcon(BaseMapScene.hide_topIcons, 0.2)

		--活动弹出
		local activityPopup = function()
			local function noticeDelayFun()
				if DATA_Activity.activityData and DATA_Activity.activityData["cellData"] and #DATA_Activity.activityData["cellData"]<=0 then
					return
				end
				DATA_Activity:regClockFun( "activity_first_show" , nil )
				if DATA_Activity and ( #DATA_Activity.activityData["cellData"] >0 ) and (not DATA_Activity.isLoginShow ) and MRoleStruct:getAttr(ROLE_LEVEL) >= 2 and ( self.map_layer and not self.map_layer.isfb ) and self.mapId ~= 1000 then
					__GotoTarget( {ru = "a89"} )
				end   	--如果有系统公告数据，则展示一次
			end
			DATA_Activity:regClockFun( "activity_first_show" , noticeDelayFun )
		end
		local dateStr = os.date( "%x" , os.time() )
		local recordDateStr = getLocalRecordByKey( 2 , "activityPopKey" .. tostring( userInfo.currRoleStaticId or 0 )  )
		recordDateStr = recordDateStr or ""
		if  recordDateStr ~= dateStr and ( MRoleStruct:getAttr( ROLE_LEVEL ) and MRoleStruct:getAttr( ROLE_LEVEL ) >= 10 )  then
			activityPopup()
		end
		setLocalRecordByKey( 2 , "activityPopKey" .. ( userInfo.currRoleStaticId or 0 )  , dateStr )		
	end
	performWithDelay(self, cb, 0.5)
end


function BaseMapScene:initialize(objId)	
	if self.map_layer then
		self.map_layer.caiji_num = nil
		local detailMapNode = require("src/layers/map/DetailMapNode"):getDetailMapInfo()
		local autofunc = function()
			if g_reconnect_auto_status then 
				game.setAutoStatus(g_reconnect_auto_status) 
				g_reconnect_auto_status = nil
			else
				if self._removeFunc then
	               	__removeAllLayers() 
	               if type(self._removeFunc) == "function" then
	                    self._removeFunc()
	               end
	               self._removeFunc = nil
	            end
			end
		end
		if g_reconnect_auto_status then 
			game.setAutoStatus(g_reconnect_auto_status)
		end
		if G_MAINSCENE.relive_layer then
        	removeFromParent(G_MAINSCENE.relive_layer)
        	G_MAINSCENE.relive_layer = nil
    	end	
		performWithDelay(self, autofunc, 0.0)
		--if DATA_Mission:getAutoPath() and not DATA_Mission.isStopFind then game.setAutoStatus( AUTO_PATH ) end
		self.map_layer:taskInit(self.mapId)
		if game.getAutoStatus() == AUTO_PATH or DATA_Mission:getAutoPath() then
			detailMapNode.curmap_tarpos = nil
			detailMapNode.map_id = nil
			detailMapNode.target_pos = nil
			local func = function() 
				if  self.map_layer and self.map_layer:isHasAllLoaded() then
					local task_data = DATA_Mission:getTempFindPath()
					if task_data and tonumber(task_data.q_done_event or 0)==0  then
						__TASK:findPath( task_data )
					end
					DATA_Mission.isStopFind = nil
				end
			end
			performWithDelay(self,func,0.1)
		elseif game.getAutoStatus() == AUTO_PATH_MAP then
			local func = function()
				if self.map_layer and self.map_layer:isHasAllLoaded() then
					if detailMapNode.map_id then
						if self.mapId == detailMapNode.map_id then
							local callback = function()
								self.map_layer:removeWalkCb()
								local need_move_pos = nil
								if self.dart_pos then
									local pathCfg = require("src/layers/map/DetailMapNode"):getDartPath()
									need_move_pos = getNextGoPos( self.dart_pos , pathCfg )
								end

								local mappathCfg = nil
								if self.task_escort_pos then
									local escortCfg = getConfigItemByKey( "ConvoyDB" , "q_id" )
									for k , v in pairs( escortCfg ) do
										if v.q_mapID == self.mapId then
											mappathCfg = v
											break
										end
									end
									if mappathCfg then
										local pathCfg = unserialize( mappathCfg.q_path or "" )
										need_move_pos = getNextGoPos( self.dart_pos , pathCfg )
									end
								end
								if self.mapId == 2100 and need_move_pos and detailMapNode.target_pos and 
									need_move_pos.x == detailMapNode.target_pos.x and need_move_pos.y == detailMapNode.target_pos.y then
									game.setAutoStatus(AUTO_MATIC)
								elseif mappathCfg and need_move_pos and detailMapNode.target_pos and 
									need_move_pos.x == detailMapNode.target_pos.x and need_move_pos.y == detailMapNode.target_pos.y then
									game.setAutoStatus( AUTO_ESCORT )
								else
									game.setAutoStatus(0)
								end
								require("src/layers/map/DetailMapNode"):setDetailMapInfo()
							end
							self.map_layer:registerWalkCb(callback)
							local target_p = detailMapNode.target_pos
							local sub_num = (target_p.x > 40 and target_p.y > 40 ) and 1  or -1
							while self.map_layer:isBlock(detailMapNode.target_pos) do
								if detailMapNode.target_pos.y > 2 and target_p.x == detailMapNode.target_pos.x then
									detailMapNode.target_pos.y = detailMapNode.target_pos.y - sub_num
								else
									detailMapNode.target_pos.y = target_p.y
									detailMapNode.target_pos.x = detailMapNode.target_pos.x - sub_num
								end
							end
							detailMapNode.curmap_tarpos = detailMapNode.target_pos
			 				self.map_layer:moveMapByPos(detailMapNode.curmap_tarpos,true)
			 				-- if self.map_layer:hasPath() then
			 				-- 	self:playHangupEffect(1)
			 				-- else
			 				-- 	self:playHangupEffect(2)
			 				-- 	self.map_layer:removeWalkCb()
			 				-- end
			 				game.setAutoStatus(game.getAutoStatus())
						else
							--print("detailMapNode.curmap_tarpos")
							detailMapNode.curmap_tarpos = findTarMap(detailMapNode.map_id,self.mapId)
							-- detailMapNode.curmap_tarpos = self.tasktracer:findTarMap(detailMapNode.map_id,self.mapId)
						end
					else
						local task_data = DATA_Mission:getTempFindPath()
						if task_data and tonumber(task_data.q_done_event or 0)==0  then
							__TASK:findPath( task_data )
						end
						DATA_Mission.isStopFind = nil
					end
				end
			end
			performWithDelay(self,func,0.1)
		else
			require("src/layers/map/DetailMapNode"):setDetailMapInfo()
		end
	end
	self.tick_time = 0
	self.t_time = G_UPDATE_TIME_SPAN - 1
	userInfo.noNetTransforTime = 0

	performWithDelay(self,function() 
						self:checkBagNotice()--检查背包是否已满
						self:checkFriendNoticeNode()--检查背包是否已满
                        self:checkFactionInviteNoticeNode()
						RED_BAG_CREATE()

						--穿云箭
						if DATA_Activity.___arrowBtn and tablenums(DATA_Activity.___arrowBtn.data)~=0 then 
							for key ,v in pairs(DATA_Activity.___arrowBtn.data) do
								self:showArrowBtn( v , true )
							end
						end
		end ,1.0)

	-- --检查背包是否已满
	-- performWithDelay(self, function()  self:checkBagNotice() end, 1.0)
	-- --检查背包是否已满
	-- performWithDelay(self, function()  self:checkFriendNoticeNode() end, 1.0)
end

function BaseMapScene:hideIcons(isHide)
	--cclog("*******************************"..tostring(isHide))
	--print(string.format(debug.traceback()),isHide)
	if isHide then
		if TOPBTNMG  then TOPBTNMG:hideTop( true) end --true and (not BaseMapScene.Shrank_mode)
	else
		if TOPBTNMG  then TOPBTNMG:hideTop( false) end
		userInfo.bringData = nil
	end
	self.isHide_icon = isHide
	--BaseMapScene.Shrank_mode = not isHide	
	if __TASK then __TASK:hideIcon( (isHide and not self:checkShaWarState()) or BaseMapScene.hide_task ) end
	--if self.buff_btn2 then self.buff_btn2:setVisible(not isHide) end
	--if self.entryBtn then self.entryBtn:setVisible(not isHide) end
	if self.task_btn_node and not self:checkShaWarState() then 
		self:hideTaskBtn(isHide, true)
		self.task_btn_node:setVisible(not isHide) 
	end
	-- if self.newFuntionNodeEx then
	-- 	self.newFuntionNodeEx:setVisible( not isHide )
	-- end
end

function BaseMapScene:hideTopIcon(visable, timeNum)
	if self.current_dir == visable then return end
	self.topLeftNode:stopAllActions()
	self.topRightNode:stopAllActions()
	self.taskBaseNode:stopAllActions()
	self.tasknewFunctionNode:stopAllActions()
	local time =  timeNum or 0.4
	if visable then
		self.topLeftNode:runAction(cc.MoveTo:create(time * (280 - self.topLeftNode:getPositionY()) / 280, cc.p(0, 280)))
		self.topRightNode:runAction(cc.MoveTo:create(time* (280 - self.topRightNode:getPositionY()) / 280, cc.p(0, 280)))
		self.taskBaseNode:runAction(cc.MoveTo:create(time * -(- 280 - self.topRightNode:getPositionX()) / 280, cc.p(-280, (g_scrSize.height-640)/2)))
		self.tasknewFunctionNode:runAction(cc.MoveTo:create(time * self.tasknewFunctionNode:getPositionX() / 250, cc.p(250, 0)))
		if G_CHAT_INFO.chatPanel then
			G_CHAT_INFO.chatPanel:runAction(cc.MoveTo:create(time, cc.p(-300, 280 + (g_scrSize.height-640))))
		end
		tutoRemoveMenuTutoAction()
	else
		self.topLeftNode:runAction(cc.MoveTo:create(time * self.topLeftNode:getPositionY() / 280, cc.p(0, 0)))
		self.topRightNode:runAction(cc.MoveTo:create(time * self.topRightNode:getPositionY() / 280, cc.p(0, 0)))
		self.taskBaseNode:runAction(cc.MoveTo:create(time * (-self.taskBaseNode:getPositionX()) / 280, cc.p(0, (g_scrSize.height-640)/2)))
		self.tasknewFunctionNode:runAction(cc.MoveTo:create(time * self.tasknewFunctionNode:getPositionX() / 250, cc.p(0,0)))
		if G_CHAT_INFO.chatPanel then
			G_CHAT_INFO.chatPanel:runAction(cc.MoveTo:create(time, cc.p(0, 280 + (g_scrSize.height-640))))
		end
	end
	BaseMapScene.hide_topIcons = visable
	self.current_dir = visable
end

function BaseMapScene:playHangupEffect(flag)
	if not self.hangup_effect then
		self.hangup_effect = Effects:create(false)
		self.hangup_effect:setPosition(cc.p(g_scrSize.width/2,150))
		self.hangup_effect:setScale(1)
		self:addChild(self.hangup_effect, 9)
	end
	if not self.hangup_menu then
		local func = function()
			local status = game.getAutoStatus()
			if status >= 1 and status <= 3  then
				if DATA_Mission then
					local target_info = DATA_Mission:getLastFind()
					if target_info and target_info.mapid and target_info.x then 
						__shoesGoto( { mapid = target_info.mapid , x = target_info.x , y = target_info.y } )
						return
					end
				end
				local detailMapNode = require("src/layers/map/DetailMapNode"):getDetailMapInfo()
				if detailMapNode.target_pos and detailMapNode.map_id then
					__shoesGoto( { mapid = detailMapNode.map_id , x = detailMapNode.target_pos.x , y = detailMapNode.target_pos.y } )
				end
			end
		end
		self.hangup_menu =  createTouchItem(self, "res/mainui/goto.png",cc.p(g_scrSize.width/2+140,150) , func,true) 
		self.hangup_menu:setLocalZOrder(10)
		local flyeffect = Effects:create(false)
		flyeffect:setPosition(cc.p(55,45))
		flyeffect:playActionData("flyeffect", 9, 0.5,-1)
		addEffectWithMode(flyeffect,3)
		self.flyeffect = flyeffect
		self.hangup_menu:addChild(flyeffect)
		if G_TUTO_NODE then
			G_TUTO_NODE:setTouchNode(self.hangup_menu, TOUCH_MAIN_FLY_SHOE)
		end
		self.shop_count = createLabel(self,"X0",cc.p(g_scrSize.width/2+160,145),cc.p(0.0,0.5),18, true, nil , nil,MColor.white )
		self.shop_count:enableOutline(cc.c4b(0, 0, 0, 255), 1)
	end
	-- if G_ROLE_MAIN and flag == 0 then
	-- 	if G_ROLE_MAIN:getCurrActionState() == ACTION_STATE_EXCAVATE then
	-- 		g_msgHandlerInst:sendNetDataByFmt(FRAME_CS_MOVE_TO,"issssccc",G_ROLE_MAIN.obj_id,265,self.mapId,G_ROLE_MAIN.tile_pos.x,G_ROLE_MAIN.tile_pos.y,1,0,0)
	-- 	end
	-- end
	self.hangup_menu:setVisible(true)
	self.shop_count:setVisible(false)
	self.flyeffect:setVisible(false)

	if self.dartFlag then removeFromParent( self.dartFlag )  end
	self.dartFlag = nil 
	
	if flag == 0 then
		self.hangup_effect:playActionData("autoattack", 14, 1,-1,0)
		self.hangup_effect:setVisible(true)
		G_ROLE_MAIN:upOrDownRide(false)
		--self.hang_node:setImages("res/mainui/anotherbtns/stop.png")
		--self.hang_node:setSpriteFrame(getSpriteFrame("mainui/anotherbtns/stop.png"))
		if self.hang_node then
			self.hang_node:setOpacity(0)
            self.m_stopHangSpr:setVisible(true);
		end
		self.hangup_menu:setVisible(false)
	elseif flag == 1 then
		self.hangup_effect:playActionData("autopath", 14, 1,-1,0)
		self.hangup_effect:setVisible(true)
		local is_change_status = G_ROLE_MAIN:isChangeModeDisplay()
		local mapInfo = getConfigItemByKey("MapInfo","q_map_id",G_MAINSCENE.map_layer.mapID)
		if  mapInfo.q_map_ride and tonumber(mapInfo.q_map_ride) == 1 and  (not is_change_status) then
			G_ROLE_MAIN:upOrDownRide(true)
		end		
		if self.hang_node then
			--self.hang_node:setImages("res/mainui/anotherbtns/hangup.png")
			--self.hang_node:setSpriteFrame(getSpriteFrame("mainui/anotherbtns/hangup.png"))
			self.hang_node:setOpacity(255)
            self.m_stopHangSpr:setVisible(false);
		end
		if self.map_layer and (not self.map_layer:isHideMode()) and (not is_change_status) then
			local MPackStruct = require "src/layers/bag/PackStruct"
			local MPackManager = require "src/layers/bag/PackManager"
			local pack = MPackManager:getPack(MPackStruct.eBag)
			local count = pack:countByProtoId(1001)
			self.shop_count:setString("X"..count)
			self.hangup_menu:setTexture("res/mainui/goto.png")
			self.shop_count:setVisible(true)
			self.flyeffect:setVisible(true)
		else
			self.hangup_menu:setVisible(false)
		end
	elseif flag == 3 then
		self.hangup_effect:playActionData("autoescort", 14, 1, -1, 0)
		self.hangup_effect:setVisible(true)		
		self.hangup_menu:setVisible(false)
		self.dartFlag = createSprite( self.hangup_effect , "res/mainui/card_flag.png" , cc.p( -35 , 21 ) , cc.p( 0 , 0 ) )
	elseif flag == 4 then
		self.hangup_effect:playActionData("automine", 14, 1, -1, 0)
		self.hangup_effect:setVisible(true)		
		self.hangup_menu:setVisible(false)
	elseif flag == 5 then
		--任务护送
		self.hangup_effect:playActionData("autopro", 14, 1, -1, 0)
		self.hangup_effect:setVisible(true)		
		self.hangup_menu:setVisible(false)
	else
		self.hangup_effect:setVisible(false)
		if self.hang_node then
			--self.hang_node:setImages("res/mainui/anotherbtns/hangup.png")
			--self.hang_node:setSpriteFrame(getSpriteFrame("mainui/anotherbtns/hangup.png"))
			self.hang_node:setOpacity(255)
            self.m_stopHangSpr:setVisible(false);
		end
		self.hangup_menu:setVisible(false)
	end

	if flag ~= 0 then
		self.hangup_tile = nil
	elseif G_ROLE_MAIN then
		self.hangup_tile = G_ROLE_MAIN.tile_pos
	end
end


function BaseMapScene:update()
	self.t_time  = self.t_time  + 1
	self.tick_time  = self.tick_time  + 1

	if self.tick_time > 40 then
		g_msgHandlerInst:sendNetDataByTableEx(FRAME_CG_HEART_BEAT,"FrameHeartBeatReq",{})
		self.tick_time = 0
		if self.pingNode then
			self.pingNode:check(FRAME_CG_HEART_BEAT) 
		end
	end

	if userInfo.connStatus == CONNECTED then
		userInfo.noNetTransforTime = userInfo.noNetTransforTime + 1
		if userInfo.noNetTransforTime >= 50 then
			userInfo.noNetTransforTime = 0
			NetError(5)
		end
	else
		userInfo.noNetTransforTime = 0
	end

	if not G_ROLE_MAIN then return end
	for k,v in pairs(BaseMapScene.skill_cds)do
		BaseMapScene.skill_cds[k] = BaseMapScene.skill_cds[k] - 0.25
		if BaseMapScene.skill_cds[k] <= 0 then 
			BaseMapScene.skill_cds[k] = nil
		end
	end
	for k,v in pairs(BaseMapScene.prop_cds)do
		BaseMapScene.prop_cds[k] = BaseMapScene.prop_cds[k] - 0.25
		if BaseMapScene.prop_cds[k] <= 0 then
			BaseMapScene.prop_cds[k] = nil							
		end
	end

    -- 1s一次[per 4]
    if self.t_time%4 == 0 then
        DATA_Mission:MyAcceptedRewardTaskCountdown();
    end

	if self.t_time%G_UPDATE_TIME_SPAN == 0 then
			
		if self.map_layer then
			self.map_layer:update()
		end

		self:eatDrug()

        -- 2s一次
        if self.t_time%(2*G_UPDATE_TIME_SPAN) == 0 then
            self:CheckNoticePlay()
            self:CheckTeamInvite()
        end
    elseif self.map_layer then
    	self.map_layer:doCheckAttack()
	end
end

function BaseMapScene:reloadSkillConfig(isStoryNeed)
	if G_ROLE_MAIN == nil then
		return
	end

	if self.skill_node then
		removeFromParent(self.skill_node)
		self.skill_node = nil
	end
	local skills = G_ROLE_MAIN.skills
	local no_skill_tips = true
	local addActiveNode = function(skill_id,handler,is_remove,center,is_remove_all)
		local skillname = getConfigItemByKey("SkillCfg","skillID",skill_id,"name")
		local parent_node = self.skill_node
		local pos = cc.p(handler:getPosition())
		local center_node = self.skill_node:getCenterNode()
		local active_node = parent_node:getChildByTag(525)
		if is_remove_all then
			active_node = self.skill_node:getChildByTag(525)
			if not active_node then
				parent_node = center_node
				active_node = center_node:getChildByTag(525)
			end
		else
			if center then 
				pos = cc.p(-71,85) 
			else
				parent_node = center_node
			end
			active_node = parent_node:getChildByTag(525)
		end
		if active_node then
			if is_remove then
				parent_node:removeChildByTag(525) 
				TIPS( { type = 1 , str = "^c(red)"..game.getStrByKey("cancel_active")..skillname.."^" } ) 
			else
				--active_node:setSpriteFrame(frame_name)
				active_node:setPosition(pos)
				if center then
					active_node:setScale(1.3)
				else
					active_node:setScale(1.0)
				end
				if not no_skill_tips then
					TIPS( { type = 1 , str = "^c(green)"..skillname..game.getStrByKey("wr_skill_available").."^" } ) 
				end
			end
		elseif not is_remove then
			local andSelectEffect = function()
				local select_effect = createSprite(parent_node,"res/mainui/skill_foucs.png",pos,cc.p(0.5,0.5),1)
				if select_effect then
					select_effect:setTag(525)
					if center then
						select_effect:setScale(1.3)
					end
				end
                --剧情提示
                if G_MAINSCENE.map_layer.isStory then
                    G_MAINSCENE.storyNode:showSkillActiveTips(skill_id)
                end
			end
			performWithDelay(parent_node,andSelectEffect,0.0)
			--select_effect:playActionData("toucheffect", 4, 1,-1)
			if  not no_skill_tips then
				TIPS( { type = 1 , str = "^c(green)"..skillname..game.getStrByKey("wr_skill_available").."^" } )
			end
		end
	end 
	local doSkillCheck = function(skill_id,handler,justset,center)
        -- 校验
        if handler == nil then
            return false;
        end
        if getGameSetById(GAME_SET_ACTIVE_SKILL) == 1 then	
        	local spe_skill_maps ={[2007]=true,[2011]=true,[2008]=true,[3001]=true,[3003]=true,[3006]=true,[2036]=true,[2039]=true,[2037]=true,[3032]=true,[3034]=true,[3036]=true}
			if spe_skill_maps[skill_id] then 
				if not justset then
					local active_info = nil
					if not G_ROLE_MAIN.base_data.spe_skill[skill_id] then
						active_info = true
					end
					local open_skill = nil
					for k,v in pairs(G_ROLE_MAIN.base_data.spe_skill)do 
						open_skill = k
					end
					if open_skill then
						addActiveNode(open_skill,handler,true,center,true)
					end
					G_ROLE_MAIN.base_data.spe_skill = {}
					G_ROLE_MAIN.base_data.spe_skill[skill_id] = active_info
				--else
					--G_ROLE_MAIN.base_data.spe_skill = {}
				end
				addActiveNode(skill_id,handler,not G_ROLE_MAIN.base_data.spe_skill[skill_id],center)
				return true
			elseif G_ROLE_MAIN and (not justset) then
				local open_skill = nil
				for k,v in pairs(G_ROLE_MAIN.base_data.spe_skill)do 
					open_skill = k
				end
				if open_skill then
					G_ROLE_MAIN.base_data.spe_skill = {}
					addActiveNode(open_skill,handler,true,center,true)
				end
			end
		end
		return false
	end


	local func = function(tag,handler,skill_id,kind)
		if kind == 1 then
			local jnfenlie = getConfigItemByKey("SkillCfg","skillID",skill_id,"jnfenlie")
			if jnfenlie == 1 or jnfenlie == 9 or jnfenlie == 10 then
				if BaseMapScene.skill_cds[skill_id]  then
					return
				end
				game.setMainRoleAttack(true)
				local effect_type = getConfigItemByKey("SkillCfg","skillID",skill_id,"effectRangeType")
				if doSkillCheck(skill_id,handler,nil,tag==0) then
					return
				else
					for k,v in pairs(self.map_layer.skill_todo)do
						if v == skill_id then
							table.remove(self.map_layer.skill_todo,k)
						end
					end
					--if skill_id~= 1005 and skill_id ~= 1010 then
						if skill_id ~= 1006 then
							if skill_id == 1005 or skill_id == 1035 or skill_id == 1010 or skill_id == 1038 then
								self.map_layer:removeWalkCb()
								self.map_layer:cleanAstarPath(true,true)
								self.map_layer.skill_todo = {}
								local status = G_ROLE_MAIN:getCurrActionState()
								if status == ACTION_STATE_ATTACK then
									table.insert(self.map_layer.skill_todo,skill_id)
									self.map_layer.common_cd = nil
									resetGmainSceneTime(2)
									return
								end
							else
								table.insert(self.map_layer.skill_todo,skill_id)
							end
						elseif (not BaseMapScene.skill_cds[1006]) and (not (g_buffs_ex and g_buffs_ex[G_ROLE_MAIN.obj_id] and g_buffs_ex[G_ROLE_MAIN.obj_id][126])) and (not self.map_layer.isStory) then
							g_msgHandlerInst:sendNetDataByTable(SKILL_CS_OPENFIRE,"SkillOpenFireProtocol",{skillId = 1006})
						end
						if not (game.getAutoStatus() == AUTO_ATTACK or self.map_layer.common_cd) then
							resetGmainSceneTime()
						else
							if  (game.getAutoStatus() ~= AUTO_ATTACK) and (skill_id < 7000) and (self.map_layer.select_monster  or self.map_layer.select_role or self.map_layer.pet_attacker) and effect_type < 8 then
								if not self.map_layer.stopNextSkill and getConfigItemByKey("SkillCfg","skillID",skill_id,"Is_Lx") then
									self.map_layer.on_attack = skill_id
								end
								if (not self.map_layer.stopNextSkill) and skill_id == 1006 and  (not self.map_layer.isStory) then
									self.map_layer.on_attack = 1003
								end
							end
                            if self.map_layer.isStory and game.getAutoStatus() == AUTO_ATTACK and not self.map_layer.stopNextSkill and (skill_id == 1006 or skill_id == 1004 ) then
                                self.map_layer.on_attack = skill_id
							elseif skill_id ~= 1005 and skill_id ~= 1035 and skill_id ~= 1010 and skill_id ~= 1038 then
								return
							end
						end
					--end
				end
				if game.getAutoStatus() < AUTO_ATTACK then 
					self.map_layer:cleanAstarPath(true,true)
					if self.map_layer.play_step then
						AudioEnginer.stopEffect(self.map_layer.play_step) 
						self.map_layer.play_step = nil
					end
					self.map_layer:resetHangup()

                    if not G_ROLE_MAIN:CanWarAttack() then
					    G_ROLE_MAIN:upOrDownRide(false)
                    end
				end
				if self.map_layer:roleStartToAttack(skill_id) then
					self:doSkillAction(skill_id, self.map_layer and self.map_layer.skill_map and self.map_layer.skill_map[skill_id]  or 1,cd)--skills[i][2])
				-- else
				-- 	return
				end
				
				if  (game.getAutoStatus() ~= AUTO_ATTACK) and (skill_id < 7000) and (self.map_layer.select_monster  or self.map_layer.select_role or self.map_layer.pet_attacker) and effect_type < 8 then
					if not self.map_layer.stopNextSkill and getConfigItemByKey("SkillCfg","skillID",skill_id,"Is_Lx") then
						self.map_layer.on_attack = skill_id
					end
					if (not self.map_layer.stopNextSkill) and skill_id == 1006 and  (not self.map_layer.isStory) then
						self.map_layer.on_attack = 1003
					end
				end
			elseif jnfenlie == 8 then
				-- self:doSkillCdAction(skill_id,1)
				if skill_id == 10049 and not BaseMapScene.skill_cds[skill_id] then
					__GotoTarget({ru = "a187",skillId = skill_id})
				elseif skill_id == 10050 and not BaseMapScene.skill_cds[skill_id] then
					__GotoTarget({ru = "a188",skillId = skill_id})
				end
			end
		elseif kind == 2 then
			self:doPropAction(skill_id)
		end
	end
	local skill_node =  require("src/base/SkillTouchNode").new(self.mainui_node, skills,func,G_SKILLPROP_POS,isStoryNeed)--SkillCtrl:create()
	--self:addChild(skill_node,1)
	skill_node:setVisible(not BaseMapScene.full_mode)
	if self.map_layer then self.map_layer:setSkillMap(true) end
	self.skill_node = skill_node
	local center_btn = skill_node:getCenterItem()
	G_TUTO_NODE:setTouchNode(center_btn, TOUCH_MAIN_MAINSKILL)

	-- local SkillUpdateLayer = require("src/layers/skill/SkillUpdateLayer")
	for i=1,#skills do
		-- local jnfenlie = getConfigItemByKey("SkillCfg","skillID",skills[i][1],"jnfenlie")
		-- local useType = getConfigItemByKey("SkillCfg","skillID",skills[i][1],"useType")
		-- if jnfenlie and jnfenlie == 1 or (useType and useType == 1) then
		-- 	local s_type = getConfigItemByKey("SkillCfg","skillID",skills[i][1],"skillspecialtype")
			-- if SkillUpdateLayer:canUpdate(skills[i]) then
			-- 	if self.red_points then
	 	-- 			self.red_points:insertRedPoint(4, 2)
	  --   		end	    		
			-- end
			for k,v in pairs(G_SKILLPROP_POS) do
				if v[2] == 1 and skills[i][1] == v[3] then
					if v[1] == 1 then
						local center_btn = self.skill_node:getCenterItem()
						doSkillCheck(skills[i][1],center_btn,true,true) 
					elseif v[1] < 20 and v[1] > 1 then
						local center_node = self.skill_node:getCenterNode()
						local menuItem = tolua.cast(center_node:getChildByTag(v[1]), "TouchSprite")
						doSkillCheck(skills[i][1],menuItem,true) 
					end
					break
				end
			end
		-- end
	end
	no_skill_tips = nil	
	for k,v in pairs(BaseMapScene.skill_cds)do		
		local lv = self.map_layer.skill_map[k] or 1
		self:doSkillCdAction(k,lv,v,nil,true)
	end
end

function BaseMapScene:doSkillAction(skillid,level,cd)
	if self.map_layer.common_cd  then
		return
	end
	if skillid == 1000 and G_ROLE_MAIN.school == 1 and level then
		self:doSkillCdAction(skillid,level,cd,firstIn)
		local mp = G_ROLE_MAIN.base_data.mp		
		if G_ROLE_MAIN.open_cs then
			level = self.map_layer.skill_map[1003]  or 1
			local useMP = getConfigItemByKey("SkillLevelCfg","skillID",1003*1000+level,"useMP") 
			if useMP and mp >= useMP then skillid = 1003 end
		end
		if G_ROLE_MAIN.open_by then
			level = self.map_layer.skill_map[1004]  or 1
			local useMP = getConfigItemByKey("SkillLevelCfg","skillID",1004*1000+level,"useMP") 
		 	if useMP and mp >= useMP then skillid = 1004 end
		end
	end
	local delay_time = 0
	if skillid == 1005 or skillid == 1035 or skillid == 1010 or skillid == 1038 then
		if self.map_layer and self.map_layer.skill_map then 
			if self.map_layer.skill_map[1005] then
				self:doSkillCdAction(1005,self.map_layer.skill_map[1005],cd) 
			end
           	if self.map_layer.skill_map[1010] then
				self:doSkillCdAction(1010,self.map_layer.skill_map[1010],cd)
			end
			if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
	            self:doSkillCdAction(1035,self.map_layer.skill_map[1035],cd) 
				self:doSkillCdAction(1038,self.map_layer.skill_map[1038],cd)
			end
		end
		delay_time = 0.5
	else
		delay_time = 0.25*G_UPDATE_TIME_SPAN-0.1
		self:doSkillCdAction(skillid,level,cd)
	end
	if not ((skillid == 1006 or skillid == 1036) and level and level >=100) then
		self.map_layer.common_cd = true
		local comFunc = function()
			self.map_layer.common_cd = nil
			if self.map_layer.skill_todo[1] and (skillid==self.map_layer.skill_todo[1] or skillid == 1006 or skillid == 1036) then
				table.remove(self.map_layer.skill_todo,1)
			end
			if game.getAutoStatus() ~= AUTO_ATTACK and self.map_layer.skill_todo[1] then
				if self.map_layer:roleStartToAttack(self.map_layer.skill_todo[1]) then
					self:doSkillAction(self.map_layer.skill_todo[1], self.map_layer and self.map_layer.skill_map and self.map_layer.skill_map[self.map_layer.skill_todo[1]]  or 1)--skills[i][2])
				end
			end
		end
		performWithDelay(self,comFunc,delay_time)
	end
end

function BaseMapScene:doSkillCdAction(skillid,level,cd,shareCd,firstIn)
	if (not self.skill_node) or (not skillid) then return end
	if (skillid == 1006 and (not (level and level>=100)) and (not (self.map_layer and self.map_layer.isStory))) then
	 	return
	end
	local coolTimeShare = getConfigItemByKey("SkillCfg","skillID",skillid,"coolTimeShare")
	local skillLv = self.map_layer.skill_map[skillid] or 1
	local coolTime =  getConfigItemByKey("SkillLevelCfg","skillID",skillid*1000+skillLv,"coolTime") 
	if coolTime and ((not coolTimeShare) or (coolTimeShare < coolTime ))then
		coolTimeShare = coolTime
	end
	if (not coolTimeShare) or coolTimeShare < 200 then
		coolTimeShare = 200
	end
--[[
    if self.map_layer.isStory == true then
        if skillid == 3009 or skillid == 1010 then
            coolTimeShare = 3000
        end
    end
]]
	
	local cd_share = BaseMapScene.skill_cds[skillid] or cd or coolTimeShare/1000
	local MskillOp = require "src/config/skillOp"
	level = level or 1
	local cool_time = MskillOp:skillCoolTime(skillid,level)
	cd = (cool_time == 0) and cd_share*100 or cool_time/1000
	--print(BaseMapScene.skill_cds[skillid] , cd , coolTimeShare/1000,skillid,level,"9999999999999999999999999")
	-- local start_progress
	if firstIn then
		start_progress = cd_share * 100/cd
	else
		start_progress = cd_share*100/(coolTimeShare/1000)  --??
	end	
	if shareCd and (not BaseMapScene.skill_cds[skillid])  then start_progress = 100 end
	BaseMapScene.skill_cds[skillid] = cd_share 
	if skillid == 1005 or skillid == 1035 or skillid == 1010 or skillid == 1038 then
		BaseMapScene.skill_cds[1005] = cd_share+0.2
        BaseMapScene.skill_cds[1035] = cd_share+0.2
		BaseMapScene.skill_cds[1010] = cd_share+0.2
        BaseMapScene.skill_cds[1038] = cd_share+0.2
	elseif skillid == 2005 or skillid == 2035 or skillid == 3009 or skillid == 3039 then
		BaseMapScene.skill_cds[skillid] = cd_share+0.2
	end
	self:releaseCdShow(skillid,start_progress,1)
end

function BaseMapScene:doPropAction(propId,nocheck)
	if (not self.skill_node) or (not propId) then return end
	-- local coolTimeShare = getConfigItemByKey("SkillCfg","skillID",skillid,"coolTimeShare")
	-- local skillLv = self.map_layer.skill_map[skillid] or 1
	-- local coolTime =  getConfigItemByKey("SkillLevelCfg","skillID",skillid*1000+skillLv,"coolTime") 
	-- if coolTime and ((not coolTimeShare) or (coolTimeShare < coolTime ))then
	-- 	coolTimeShare = coolTime
	-- end
	-- if (not coolTimeShare) or coolTimeShare < 200 then
	-- 	coolTimeShare = 200
	-- end
	local skillCD = getConfigItemByKey("propCfg","q_id",propId,"SkillCD")
	local cd_share = skillCD/1000 or 1
	local MPackManager = require "src/layers/bag/PackManager"
	local pack = MPackManager:getPack(MPackStruct.eBag)
	local propNum,girdId = pack:countByProtoId(propId)
	local start_progress = 100 --cd_share*100/(1000/1000)
	--if shareCd and (not BaseMapScene.skill_cds[skillid])  then start_progress = 100 end
	if BaseMapScene.prop_cds[propId] then		
		return
	elseif propNum == 0 and (not nocheck) then
		self:buyDrug1(propId)
		return 
	else
		BaseMapScene.prop_cds[propId] = cd_share
		if not nocheck then
			if propId == 1080 then
				--穿支箭
				MessageBoxYesNo(nil,game.getStrByKey("arrow_text1"),
					function() 
						if girdId then
							g_msgHandlerInst:sendNetDataByTableExEx( SPILLFLOWER_CS_CALLMEMBER , "CallFactionMemProtocol", { slotIndex = girdId } )
						end
					end,
					function() 
					end ,
					game.getStrByKey("sure"),game.getStrByKey("cancel") )	

			else
				MPackManager:useByProtoId(propId)
			end
			-- MPackManager:useByProtoId(propId)
		end
	end

	self:releaseCdShow(propId,start_progress,2)
end

function BaseMapScene:releaseCdShow(id,start_progress,kind)
	local center_btn = self.skill_node:getCenterItem()
	local center_node = self.skill_node:getCenterNode()
    local center_btn_ch = center_btn:getChildByTag(id)
    local handler = nil
    if center_btn_ch then
        handler = tolua.cast(center_btn_ch,"cc.Sprite")
    end
	
	if handler then
		handler = center_btn
	else
		for i=1,12 do
			local menuItem =  tolua.cast(center_node:getChildByTag(i+1), "TouchSprite")
			if tolua.cast(menuItem:getChildByTag(id),"cc.Sprite") then
				handler = menuItem
				break
			end
		end
	end
	local actions = {}
	actions[#actions+1] = cc.DelayTime:create(0.05)
	if handler then
		local playAction = function(parent,pos,scale)
			local ok_effect = Effects:create(true)
			ok_effect:setPosition(pos)
			ok_effect:setScale(scale)
			ok_effect:playActionData("skill_cd", 6, 0.3,1)
			if parent then
				parent:addChild(ok_effect)
			end
		end
		if handler:getChildByTag(105) then
			handler:removeChildByTag(105)
		end
		local sprite = cc.Sprite:create("res/mainui/shadow.png")
	    local ss = cc.ProgressTimer:create(sprite)
	    ss:setTag(105)
	    ss:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	    ss:setReverseDirection(true)
	    local set_pos,scale = cc.p(38,38)
	    if handler == center_btn then
			set_pos = cc.p(55,55)
			scale = 1.2
			ss:setScale(1.0)
	    else
	    	scale = 0.85
	    	ss:setScale(0.7)
	    end
	    ss:setPosition(set_pos)
	    ss:setPercentage(start_progress)
	    handler:addChild(ss)
	    if kind == 1 then
		    actions[#actions+1] = cc.ProgressFromTo:create(BaseMapScene.skill_cds[id],start_progress,0)
		    actions[#actions+1] = cc.CallFunc:create(function()
		    	BaseMapScene.skill_cds[id] = nil
		    	if self.map_layer then
		    		self.map_layer.touch_skill_id = nil
		    	end
		    	playAction(handler,set_pos,scale)
		    	removeFromParent(ss)
	    	end)
		elseif kind == 2 then
			actions[#actions+1] = cc.ProgressFromTo:create(BaseMapScene.prop_cds[id],start_progress,0)
		    actions[#actions+1] = cc.CallFunc:create(function()
		    	BaseMapScene.prop_cds[id] = nil
		    	playAction(handler,set_pos,scale)
		    	removeFromParent(ss)
	    	end)
		end
    	ss:runAction(cc.Sequence:create(actions))
	else
		local ss = cc.Node:create()
		self:addChild(ss)
		if kind == 1 then
			actions[#actions+1] = cc.DelayTime:create(BaseMapScene.skill_cds[id])
			actions[#actions+1] = cc.CallFunc:create(function()
		    	BaseMapScene.skill_cds[id] = nil
		    	if self.map_layer then
		    		self.map_layer.touch_skill_id = nil
		    	end
		    	removeFromParent(ss)
	    	end)
		elseif kind == 2 then
			actions[#actions+1] = cc.DelayTime:create(BaseMapScene.prop_cds[id])
		    actions[#actions+1] = cc.CallFunc:create(function()
		    	BaseMapScene.prop_cds[id] = nil		    	
		    	removeFromParent(ss)
	    	end)
		end
		ss:runAction(cc.Sequence:create(actions))
    end
end

function BaseMapScene:changeLeftRightMode(reload)
	if (not self.operate_node) then return end
	self.operate_node:setCenterPoint(cc.p(120,150))
	if reload then
		self:reloadSkillConfig()
	end
	G_TUTO_NODE:setShowNode(self, SHOW_MAIN)
end


function BaseMapScene:createMapLayer(map_str,mapId,pos,isfb)
	if self.map_layer then
		removeFromParent(self.map_layer)
		self.map_layer = nil
	end
	self.mapId = mapId
	self.map_name = map_str
	self.role_pos = pos
	--__removeAllLayers()
    if mapId == 2300 or mapId == 2301 or mapId == 2302 or mapId == 2303 or mapId == 2304 or mapId == 2305 or mapId == 2306 or mapId == 2307 or mapId == 2308 then
        self.map_layer = require("src/base/MysteriousMapLayer").new(map_str, self, pos, mapId, isfb)
    elseif mapId == 6019 then
		self.map_layer = require("src/base/VSMapLayer").new(map_str, self, pos, mapId, isfb)
	elseif mapId == 6018 then
		self.map_layer = require("src/base/SkyArenaMapLayer").new(map_str,self,pos,mapId,isfb)
	elseif mapId == 6023 or  mapId == 6024 then	--练功房
		self.map_layer = require("src/layers/exerciseRoom/ExerciseRoomMapLayer").new(map_str,self,pos,mapId,isfb)
	elseif isfb and mapId ~= 6006 and mapId ~= 5003 then
		self.map_layer = require("src/base/FbMapLayer").new(map_str,self,pos,mapId,isfb)
		self.map_layer:registerScriptHandler(function(event)
			if event == "enter" then  
			elseif event == "exit" then
				self.map_layer:dispose()
			end
		end)
	else
		self.map_layer = require("src/base/MainMapLayer").new(map_str,self,pos,mapId,isfb)      
	end
	self:showArrowPointToMonster(false)
	self:createSmallMapNode(mapId,pos)
	self.map_layer:setTag(100)

    --剧情模式处理
    self:enterStoryMode(mapId)

    local level = MRoleStruct:getAttr(ROLE_LEVEL) or 0
	if mapId == 1100 and level == 1 and getLocalRecord("storyEx") ~= true then
		self:enterStoryExMode()
		setLocalRecord("storyEx", true)
		--dump(getLocalRecord("storyEx"))
	end 

    self:createRealVoiceOpenNtfNode(mapId)

	local func = function()
		local mapInfo = getConfigItemByKey("MapInfo","q_map_id",mapId)
		local q_music = mapInfo.q_music
		if q_music then
			AudioEnginer.playMusic("sounds/mapMusic/"..q_music..".mp3",true)
		end

		if not mapInfo.q_map_ride or tonumber(mapInfo.q_map_ride) ~= 1 then
			if G_ROLE_MAIN then
		    	G_ROLE_MAIN:upOrDownRide(false,true)
			end
		end

		if G_ROLE_MAIN then
			G_ROLE_MAIN:setCarry_ex(G_ROLE_MAIN, {})
		end

		if not G_ROLE_MAIN then return end
		local objId = G_ROLE_MAIN.obj_id
		self:checkCarryMode(mapId, objId)
		self:enterInvade( mapId )

		self:setMapEmpireInfo(objId, mapId)
		self:enterEmpireMap(mapId)
		self:checkFireWorkMap(mapId)
		self:enterUndefinedMap(mapId)
		self:enterDertFb(mapId)

		--当前地图是沙城地图. 并且开启了沙城战
		if self:checkShaWarState() then
			self:changePlayColor()
			self.map_layer:SpecTitleMap(true)
			G_MAINSCENE:removeAllACtivityIcon()
		end

		local MyfacID = require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)
		if MyfacID then
			G_ROLE_MAIN:showShaName(G_ROLE_MAIN, MyfacID)
		end

		if mapId == 6003 then  -- 落霞暂时用的地图			
			self:addRobBoxInfoNode()
		end
		if mapId == 6006 then
			self:enterFactionFb(objId)
		end

		if mapId == 6017 then
			self:changePlayColor()
			g_msgHandlerInst:sendNetDataByTableExEx(FACTION_INVADE_CS_GET_CUR_FACTION_INFO, "FactionInvadeGetCurFactionInfoReq", {})
		end

		if  DATA_Battle and DATA_Battle:getRedData( "XZKP" ) or 2100 ~= self.map_layer.mapID then
			self:removeActivityRank()
		end

		if G_TEAM_ATUOTURN and  os.time() - G_TEAM_ATUOTURN[3] > 10 then
			local field = getConfigItemByKey("MapInfo","q_map_id",mapId,"q_sjlevel")
			local isOutField = string.find(tostring(field),"2") 
			if isOutField then
				local function teamFun(isYes)
					if isYes then
						g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_FAST_ENTER, "TeamFastEnter", {["enterType"] = 2 })
					else
						setLocalRecord("autoTeam",false)
					end
				end
				local function teamFun1()
					G_TEAM_ATUOTURN[2] = not G_TEAM_ATUOTURN[2]
					self.gou:setVisible(G_TEAM_ATUOTURN[2])			
				end
				if getLocalRecord("autoTeam") then
					if not G_TEAM_ATUOTURN[2] then
						local messBox = MessageBoxYesNo(nil, game.getStrByKey("team_tip6"), function() teamFun(true) end , function() teamFun(false) end,nil,nil,nil,"res/component/button/50.png",0 )
						createTouchItem(messBox, "res/component/checkbox/1.png", cc.p(170, 110), function() teamFun1() end)
						local gou = createSprite(messBox, "res/component/checkbox/1-1.png", cc.p(170, 110))
						gou:setVisible(G_TEAM_ATUOTURN[2])
						self.gou = gou
						createLabel(messBox, game.getStrByKey("team_tip7"), cc.p(195, 110), cc.p(0, 0.5), 18, true, 1, nil, MColor.lable_yellow)
					else
						teamFun(true)
					end
				end
				G_TEAM_ATUOTURN[3] = os.time()
			end
		end

	end

	self:hideIcons(self.map_layer and self.map_layer:isHideMode())
	self:InitIconsStatusByMapId(mapId)
	self:InitIconsStatusBySpecCondition()	


	startTimerAction(self, 0.3, nil, func)
end

function BaseMapScene:InitIconsStatusByMapId(tempMapId)
	if not tempMapId then return end

	local itemdata = getBattleAreaInfo(tempMapId)
	local mapCfg = {[6006] = true, [6003] = true, [2113] = true, [2116] = true, [2117] = true, [6018] = true, [1000] = true, [6017] = true,
					[6000] = true, [6001] = true, [6002] = true, [6020] = true, [6021] = true, [6022] = true, [6030] = true, [6031] = true, [6032] = true, [6018] = true,
				    [6004] = true, [7000] = true, [7001] = true, [7002] = true, [7003] = true, [5008] = true, [5003] = true, }
	if mapCfg[tempMapId] or itemdata then
		self:hideIcons(true)
	end
end

function BaseMapScene:InitIconsStatusBySpecCondition()
	local level = MRoleStruct:getAttr(ROLE_LEVEL) or 0

	if self:checkShaWarState() then 
		self:hideIcons(true)
	elseif mapId == 1100 and level == 1 and getLocalRecord("storyEx") ~= true then
		self:hideIcons(true)
	end
end

function BaseMapScene:isShowTeamNodeMap(tempMapId)
	local mapCfg = {[6000] = true, [6001] = true, [6002] = true, [6017] = true, [6020] = true, [6021] = true, [6022] = true, [6030] = true, [6031] = true, [6032] = true, 
					[7000] = true, [7001] = true, [7002] = true, [7003] = true, [5004] = true,[5005] = true,[5104] = true,
				   }
	if mapCfg[tempMapId] then
		self.isOnlyShowTeamNode = true
	end
end

function BaseMapScene:refreshRedPoints(subid)
 	if self.map_layer and self.map_layer.isMine then
 		return
 	end

-- 	local ishasredpoint = BaseMapScene.red_points:isHasRedPoint(2)
-- 	self.head_redPoint = tolua.cast(self.head_redPoint,"cc.Sprite")
-- 	if self.head_redPoint then
-- 		self.head_redPoint:setVisible(ishasredpoint and (not BaseMapScene.full_mode))
-- 	end
-- 	self.role_redPoint = tolua.cast(self.role_redPoint,"cc.Sprite")
-- 	if self.role_redPoint then
-- 		self.role_redPoint:setVisible(ishasredpoint)
-- 	end
	local isHasSubRedPoint = BaseMapScene.red_points:isHasSubRedPoint(4,2)
 	self.skill_redPoint = tolua.cast(self.skill_redPoint,"cc.Sprite")
 	if self.skill_redPoint then
 		self.skill_redPoint:setVisible(isHasSubRedPoint)
 	end
    isHasSubRedPoint = BaseMapScene.red_points:isHasSubRedPoint(6, 2)
 	self.equip_redPoint = tolua.cast(self.equip_redPoint, "cc.Sprite")
 	if self.equip_redPoint then
 		self.equip_redPoint:setVisible(isHasSubRedPoint)
 	end
 	isHasSubRedPoint = BaseMapScene.red_points:isHasSubRedPoint(4,9)
 	self.faction_redPoint = tolua.cast(self.faction_redPoint,"cc.Sprite")
 	if self.faction_redPoint then
 		self.faction_redPoint:setVisible(isHasSubRedPoint)
 	end
end

function BaseMapScene:createHangNode()
	local func = function(tag,sender)
		AudioEnginer.playEffect("sounds/uiMusic/ui_click2.mp3",false)
		if G_MAINSCENE then
			if G_MAINSCENE.map_layer then
				if G_MAINSCENE.map_layer.isSkyArena then
					if self.hang_node:getOpacity()==0 then
						G_MAINSCENE.map_layer:stopAutoAttack()
						game.setAutoStatus(0)
						self.hang_node:setOpacity(255)
                        self.m_stopHangSpr:setVisible(false);
					else
						G_MAINSCENE.map_layer:startAutoAttack()
						self.hang_node:setOpacity(0)
                        self.m_stopHangSpr:setVisible(true);
					end
					return
				end
			end
		end
		if game.getAutoStatus() == AUTO_ATTACK then
			game.setAutoStatus(0)
			--self:hideTopIcon(false)
		else
			game.setAutoStatus(AUTO_ATTACK)
			--self:hideTopIcon(true)
		end
	end
    ---------------------------------------------------------------------------------
    self.m_hangupSpan = createScale9SpriteMenu(self.mainui_node, "res/common/scalable/4.png", cc.size(90, 96), cc.p(g_scrSize.width-42 ,312), function()
            print("self.m_hangupSpan");
            func();
        end);
    self.m_hangupSpan:setActionEnable(false);
    self.m_hangupSpan:setOpacity(0);
    ---------------------------------------------------------------------------------
	self.hang_node = createTouchItem(self.mainui_node,{"mainui/anotherbtns/hangup.png"},cc.p(g_scrSize.width-40 ,312),func,true)
	self.m_stopHangSpr = createSprite( self.hang_node , getSpriteFrame("mainui/anotherbtns/stop.png")  , cc.p(0 , 0 ) , cc.p( 0.0 , 0.0 ) , -1 );
    self.m_stopHangSpr:setVisible(false);
end

--刷每日必做红点
function BaseMapScene:refreshActivityReddot()

end

function BaseMapScene:createNewFunctionBtn(record)
	--log("BaseMapScene:createNewFunctionBtn")
	self:removeNewFunctionBtn()
	self.newFuntionNode = require("src/layers/newFunction/NewFunctionNode").new(record)
	self:addChild(self.newFuntionNode, 100)
	self.newFuntionNode:setPosition(cc.p(g_scrSize.width - 155, g_scrSize.height - 160))
end

function BaseMapScene:removeNewFunctionBtn()
	--log("BaseMapScene:removeNewFunctionBtn")
	if self.newFuntionNode ~= nil then
		removeFromParent(self.newFuntionNode)
		self.newFuntionNode = nil
	end
end


function BaseMapScene:createNewFunctionBtnEx(record)
--[[ 旧目标奖励
	--log("BaseMapScene:createNewFunctionBtnEx")
	if self.newFuntionNodeEx and self.newFuntionNodeEx.showRecord and self.newFuntionNodeEx.showRecord == record then
		self.newFuntionNodeEx:updateUI()
		return
	end

	if self:removeNewFunctionBtnEx() == true then
		self.newFuntionNodeEx = require("src/layers/newFunction/NewFunctionNodeEx").new(record)
		self.tasknewFunctionNode:addChild(self.newFuntionNodeEx, 100)
		local pos = cc.p(g_scrSize.width - 60, g_scrSize.height - 175)
        -- 这里在部分手机会遮挡副本退出按钮，不需要移动位置
--		if self.isHide_icon or (self.map_layer and self.map_layer:isHideMode()) or BaseMapScene.Shrank_mode then
--			pos = cc.p(g_scrSize.width - 165, g_scrSize.height - 100)
--		end
		self.newFuntionNodeEx:setPosition(pos)
		self.newFuntionNodeEx:setVisible(not self.isHide_icon)
	end
]]	
end

function BaseMapScene:setOrGetMainLineData(kind,data,change)
	if kind == 1 and data then
		G_TARGETAWARD = data
	else
		if not G_TARGETAWARD then
			G_TARGETAWARD = {{},{}}
		end
		if kind == 2 then
			return G_TARGETAWARD
		elseif kind == 3 and change then
			table.insert(G_TARGETAWARD[2],change)			
		elseif kind == 4 then
			if self.targetAwards then 
				local isRed = false
				local red = tolua.cast(self.targetAwards:getChildByTag(11),"cc.Sprite")
				if red then--and table.nums(G_TARGETAWARD[1]) > table.nums(G_TARGETAWARD[2]) then
					local lv = MRoleStruct:getAttr(ROLE_LEVEL)
					local isNextText = false
					local recordid = 0
					local tab = {}
					for k,v in pairs(G_TARGETAWARD[1]) do															
						tab[#tab+1] = v
					end
				
					for k = #tab,1,-1 do
						local isRemove = false
						local thelv = getConfigItemByKey("GrowUpTarget","q_id",tab[k]).q_level
						if lv < thelv then
							isRemove = true
						end
						for i,j in pairs(G_TARGETAWARD[2]) do							
							if tab[k] == j then								
								if tab[k]+1 <= 6 then
									local thenextlv = getConfigItemByKey("GrowUpTarget","q_id",tab[k]+1).q_level
									if lv < thenextlv then
										isNextText = true
										recordid = tab[k]+1
									end
								end
								isRemove = true
								break						
							end
						end
						if isRemove then
							table.remove(tab,k)
						end
					end 
					if #tab > 0 then
						red:setVisible(true)
					else
						red:setVisible(false)
					end
					if isNextText then

						local lab1 = tolua.cast(self.targetAwards:getChildByTag(20),"cc.Label")
						local lab2 = tolua.cast(self.targetAwards:getChildByTag(21),"cc.Label")
						local spr = tolua.cast(self.targetAwards:getChildByTag(30),"cc.Sprite")						

						if lab1 and lab2 and spr then
							lab1:setString(game.getStrByKey("targetAward_tip1"))
							lab2:setString(getConfigItemByKey("GrowUpTarget","q_id",recordid).q_name)
							local MpropOp = require "src/config/propOp"
							local resPath = MpropOp.icon(getConfigItemByKey("GrowUpTarget","q_id",recordid).q_perf)
							spr:setTexture(resPath)
						end
					end
				end				
				local tarCfg1 = require("src/config/GrowUpTarget")
				if table.nums(G_TARGETAWARD[2]) >= #tarCfg1 then
					-- if self.targetAwards then
						removeFromParent(self.targetAwards)
						self.targetAwards = nil
					-- end
				end
			end
		end
	end
end

function BaseMapScene:createTargetAwards(update)	
	local tarCfg1 = require("src/config/GrowUpTarget")
	local getId = 0
	local showBtn = true

	local createFlyParticle = function(startPos, endPos)
		-- dump(startPos)
  		-- dump(endPos)
		if startPos == nil or endPos == nil then
			return
		end

		local scale = math.random(2, 5)
		local particleSpr = createSprite(self.base_node, "res/particle/star.png", startPos, cc.p(0.5, 0.5), 10, scale/10)
		particleSpr:setColor(cc.c3b(255, 255, 0))
		local bezierContorl1
		local bezierContorl2

		local centerPos = cc.p((startPos.x + endPos.x)/2, (startPos.y + endPos.y)/2)
		-- dump(centerPos)
		--math.randomseed(os.time())
		local function getRandomPoint(a, b)
			if a < b then
				return math.random(a, b)
			else
				return math.random(b, a)
			end
		end

		bezierContorl1 = cc.p(getRandomPoint(startPos.x, centerPos.x), getRandomPoint(startPos.y, centerPos.y))
		bezierContorl2 = cc.p(getRandomPoint(centerPos.x, endPos.x), getRandomPoint(centerPos.y, endPos.y))

		local bezier = {
	        bezierContorl1,
	        bezierContorl2,
	        endPos,
    	}

    	local time = math.random(1, 6)
	    local bezierGo = cc.BezierTo:create(time/10, bezier)
	    local action = cc.Sequence:create(bezierGo, 
	    		cc.CallFunc:create(function() 
	    			if particleSpr then removeFromParent(particleSpr) particleSpr = nil end 
	    		end))
	    particleSpr:runAction(action)

	    -- self.targetAwards:setVisible(true)
	end
	local iconFun = function(sender,masking)
		if sender and masking then	
			AudioEnginer.playEffect("sounds/uiMusic/ui_fx.mp3",false)
			local startPos = cc.p(display.width/2, display.height/2)
			local endPos = cc.p(g_scrSize.width - 110, g_scrSize.height - 185)
			-- removeFromParent(sender)
			-- sender = nil
			-- removeFromParent(masking)
			-- masking = nil
			local repeatCreateParticle = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.02), 
			cc.CallFunc:create(function() createFlyParticle(startPos, endPos) end)))--function() log("123") end cc.CallFunc:create(createFlyParticle(startPos, pos) cc.MoveBy:create(1, cc.p(10, 10)))
			self.cszlBtn:runAction(repeatCreateParticle)
			self.cszlBtn:runAction(
			cc.Sequence:create(
				cc.FadeOut:create(1), 
			cc.CallFunc:create(function() 
					if repeatCreateParticle then
						self.cszlBtn:stopAction(repeatCreateParticle) 
						repeatCreateParticle = nil
					end
				end),
			-- 	self.cszlBtn:setPosition(endPos) 
			-- 	self.cszlBtn:setScale(0.5)
			-- 	self.cszlBtn:setOpacity(255) end),			
			-- cc.ScaleTo:create(0.3, 1),
			-- cc.ScaleTo:create(0.2, 0.5),
			-- cc.DelayTime:create(0.5),
			-- cc.FadeOut:create(0.75),
			cc.CallFunc:create(function() 
					removeFromParent(self.cszlBtn)
					self.cszlBtn = nil 
				end),
			cc.CallFunc:create(
	    			function()
	    				-- self.targetAwards:setVisible(true)
	    				self.targetAwards:runAction(cc.FadeIn:create(0.5))
	    				removeFromParent(sender)
						sender = nil
						removeFromParent(masking)
						masking = nil
	    			end
	    	)))

		end
	end

	

	for i=1,#tarCfg1 do		
		local lv = MRoleStruct:getAttr(ROLE_LEVEL)
		if lv < tarCfg1[i].q_level or lv < tarCfg1[1].q_level then
			if lv == tarCfg1[1].q_level and update then
				showBtn = false
			end
			break
		end		
		if lv == tarCfg1[i].q_level and update then			
			setLocalRecord("mainLineTarget",false)
		end
		getId = tarCfg1[i].q_id
	end	
	if getId ~= 0 then
		local tarCfg = getConfigItemByKey("GrowUpTarget","q_id",getId)
		if self.targetAwards then
			removeFromParent(self.targetAwards)
			self.targetAwards = nil
		end
		local data = G_TARGETAWARD
		local red = nil	
		self.targetAwards = createMenuItem(self.tasknewFunctionNode,"res/mainui/targetAward.png",cc.p(g_scrSize.width - 110, g_scrSize.height - 185),function(id,sender)
				local isRed = red:isVisible()
				local targetPage = require("src/layers/targetAwards/targetAwards").new(sender,isRed)
				-- Manimation:transit(
				-- {
				-- 	ref = self.base_node,
				-- 	node = targetPage,
				-- 	curve = "-",
				-- 	sp = cc.p(display.width/2, display.height/2),
				-- 	zOrder = 100,
				-- 	--swallow = true,
				-- })
				targetPage:setPosition(cc.p(display.width/2, display.height/2))
				self.base_node:addChild(targetPage,200)
				setLocalRecord("mainLineTarget",true)
				local effect = tolua.cast(sender:getChildByTag(10),"Effects")
				if effect then
					removeFromParent(effect)
					effect = nil
				end
			end)
		 
		local MpropOp = require "src/config/propOp"
		local resPath = MpropOp.icon(tarCfg.q_perf)
		local btnSize = self.targetAwards:getContentSize()
		local spr = createSprite(self.targetAwards,resPath,cc.p(btnSize.width-50, btnSize.height/2-5))
		spr:setTag(30)
		red = createSprite(self.targetAwards,"res/component/flag/red.png",cc.p(btnSize.width-15,btnSize.height-18))
		red:setTag(11)
		red:setVisible(false)			
		if getLocalRecord("mainLineTarget") ~= true then
			local effect = Effects:create(false)
			effect:setCleanCache()
		    effect:playActionData("newFunctionExSmall", 19, 2, -1)
		    self.targetAwards:addChild(effect,1,10)
		    effect:setAnchorPoint(cc.p(0.5, 0.5))
		    effect:setPosition(cc.p(btnSize.width-50, btnSize.height/2-5))		    
		end

	    createLabel(self.targetAwards,string.format(game.getStrByKey("targetAward_page"),game.getStrByKey("num_"..tostring(tarCfg.q_type))),cc.p(75,55),nil,18,true,nil,nil,MColor.lable_yellow,20)
	    createLabel(self.targetAwards,tarCfg.q_name,cc.p(75,33),nil,18,true,nil,nil,MColor.lable_yellow,21)
	    if not showBtn then
			-- self.targetAwards:setVisible(false)
			self.targetAwards:setOpacity(0)
		end
		self:setOrGetMainLineData(4)	

		if not showBtn then
			local masking = cc.LayerColor:create(cc.c4b(0, 0, 0, 255*0.7))
			self.base_node:addChild(masking)	

			local bg = createSprite(self.base_node, "res/achievement/get/bg.png", cc.p(display.cx, 125), cc.p(0.5, 0))
			
			createSprite(bg, "res/achievement/get/1.png", cc.p(bg:getContentSize().width/2, 146), cc.p(0.5, 0.5))
			createSprite(bg, "res/achievement/get/2.png", cc.p(bg:getContentSize().width/2, 20), cc.p(0.5, 0.5))

			createSprite(bg, "res/achievement/get/6.png", cc.p(bg:getContentSize().width/2, bg:getContentSize().height-15), cc.p(0.5, 0))
			createSprite(bg, "res/achievement/get/5.png", cc.p(bg:getContentSize().width/2, bg:getContentSize().height-15), cc.p(0.5, 0))

			createSprite(bg, "res/newFunction/7.png", getCenterPos(bg), cc.p(0.5, 0.5))

			local effect = Effects:create(false)
			effect:setCleanCache()
		    effect:playActionData("newfunction", 11, 1.3, 1)
		    addEffectWithMode(effect, 1)
		    bg:addChild(effect, 200)
		    effect:setAnchorPoint(cc.p(0.5, 0.5))
		    effect:setPosition(cc.p(bg:getContentSize().width/2, 120))

			createSprite(bg, "res/achievement`/get/9.png", cc.p(bg:getContentSize().width/2, 120), cc.p(0.5, 0))			
			self.cszlBtn = createSprite(bg,"res/mainui/subbtns/cszl.png",cc.p(bg:getContentSize().width/2,181))
			createSprite(bg, "res/achievement/get/7.png",cc.p(bg:getContentSize().width/2,115) , cc.p(0.5, 0), 100)--cc.p(bg:getContentSize().width/2,115)
			createLabel(bg,game.getStrByKey("title_cqd"),cc.p(bg:getContentSize().width/2,120) ,cc.p(0.5,0),20,true,100,nil,MColor.black)
			createLabel(bg,game.getStrByKey("achievement_touch_close"),cc.p(bg:getContentSize().width/2,40),nil,20,true,nil,nil,MColor.lable_black)
			-- local icon = createTouchItem(bg,"res/mainui/subbtns/cszl.png" , cc.p(display.cx+5, 318), function() iconFun(pos) end)
			performWithDelay(self, function() iconFun(bg,masking) end , 2)
		end
		if self.targetAwards then
			self.targetAwards:setVisible( not self.isHide_icon )
		end
		G_TUTO_NODE:setTouchNode(self.targetAwards, TOUCH_MAIN_TARGETAWORD)
	end
end

function BaseMapScene:removeNewFunctionBtnEx()
	--log("BaseMapScene:removeNewFunctionBtnEx")
	if self:isCanRemoveNewFunctionBtnEx() then
		if self.newFuntionNodeEx ~= nil then
			self.newFuntionNodeEx:removeShow()
			removeFromParent(self.newFuntionNodeEx)
			self.newFuntionNodeEx = nil
		end

		return true
	else
		return false
	end
end

function BaseMapScene:isCanRemoveNewFunctionBtnEx()
	--log("BaseMapScene:isCanRemoveNewFunctionBtnEx")
	if self.newFuntionNodeEx then
		return self.newFuntionNodeEx:isCanRemove()
	end
	--log("return ture")
	return true
end

function BaseMapScene:createNearBtn()
	local btnFunc = function()
		if self.nearInfoLayer then
			return
		end

		local layer = require("src/layers/nearInfo/NearInfoLayer").new()
		--self:addChild(layer, 100)
		Manimation:transit(
		{
			ref = self.base_node,
			node = layer,
			curve = "-",
			sp = cc.p(display.width/2, 0),
			zOrder = 100,
			--swallow = true,
		})
		self.nearInfoLayer = layer
	end
	local btn = createTouchItem(self, "res/nearInfo/1.png", cc.p(0, 0), btnFunc)
	btn:setAnchorPoint(cc.p(0, 0))
	local textSpr = createSprite(btn, "res/nearInfo/3.png", cc.p(7, 10), cc.p(0, 0))
	textSpr:setTag(10)

	self.nearInfoBtn = btn

	self:changeNearBtn()
end

function BaseMapScene:changeNearBtn(isLeft)
	if self.nearInfoBtn then
		if isLeft then
			self.nearInfoBtn:setTexture("res/nearInfo/1.png")
			self.nearInfoBtn:setAnchorPoint(cc.p(0, 0))
			self.nearInfoBtn:setPosition(cc.p(0, 0))
			local textSpr = self.nearInfoBtn:getChildByTag(10)
			if textSpr then
				textSpr:setTexture("res/nearInfo/3.png")
				textSpr:setPosition(cc.p(7, 10))
			end
		else
			self.nearInfoBtn:setTexture("res/nearInfo/1-1.png")
			self.nearInfoBtn:setAnchorPoint(cc.p(1, 0))
			self.nearInfoBtn:setPosition(cc.p(display.width, 0))
			local textSpr = self.nearInfoBtn:getChildByTag(10)
			if textSpr then
				textSpr:setTexture("res/nearInfo/3-1.png")
				textSpr:setPosition(cc.p(62, 10))
			end
		end
	end
end

function BaseMapScene:removeNearBtn()
	if self.nearInfoLayer then
		removeFromParent(self.nearInfoLayer)
		self.nearInfoLayer = nil
	end
end

function BaseMapScene:refreshEmpireRedHot(manorID, isOpen, isShow)
	G_EMPIRE_INFO.REDHOT_INFO[manorID] = isOpen
	if manorID == 1 then
		DATA_Battle:setRedData("ZZZB", isOpen, isShow)
	else
		DATA_Battle:setRedData("LDZD", isOpen, isShow)
	end
end

function BaseMapScene:createBiQiBegainIcon(manorID, isOpen)
	local itemdate = getConfigItemByKey("AreaFlag", "mapID", self.map_layer.mapID)
	self:refreshEmpireRedHot(manorID, isOpen, isOpen)
	
	if G_ROLE_MAIN and isOpen and (not itemdate or itemdate.manorID ~= manorID) and not self.map_layer:isHideMode(true) and self.map_layer.mapID ~= 6018  then
		
		if MRoleStruct:getAttr(ROLE_LEVEL) < 22 then return end

		local tempManorID = manorID == 1 and 1 or 2
		local time = getLocalRecordByKey(1, tostring( userInfo.currRoleStaticId or 0 ) .."empire" .. tempManorID .. "_icon_click_time"..sdkGetOpenId())
		if time and time ~= 0 then
			local time1 = os.date("*t", time)
			local time2 = os.date("*t")
			if time1.year == time2.year and time1.month == time2.month and time1.day == time2.day then
				return
			end
		end

		local buttonFunc = function()
			local tempManorID = manorID == 1 and 1 or 2
			setLocalRecordByKey(1, tostring( userInfo.currRoleStaticId or 0 ) .."empire" .. tempManorID .. "_icon_click_time"..sdkGetOpenId(), os.time())		
			G_MAINSCENE:refreshEmpireRedHot(manorID, false)
			if manorID == 1 then
				__GotoTarget({ru = "a84", index = 2})
			else
				__GotoTarget({ru = "a84", index = 1})
			end
		end

		local cfg = {
						{resName = "res/mainui/subbtns/zzzb.png", str = game.getStrByKey("title_ZZZB")},
						{resName = "res/mainui/subbtns/ldzd.png", str = game.getStrByKey("title_LDZD")},
					}

		local iconCfg = cfg[1]
		if manorID ~= 1 then
			iconCfg = cfg[2]
		end

	    self:createActivityIconData({priority= 20,
							btnResName  = iconCfg.resName,
							btnResLab   = iconCfg.str,
							btnCallBack = buttonFunc,
							btnRemoveTime = 35,
							btnZorder = 100})	  
	elseif not isOpen then
		local resName = "empireOther"
		if manorID == 1 then
			resName = "biqi"
		end
		self:removeActivityIcon(resName)
	end
end

function BaseMapScene:createShaWarNotify(isOpen)
	DATA_Battle:setRedData("SCZB", isOpen, isOpen)

	if G_ROLE_MAIN and isOpen 
		and not self.map_layer:isHideMode(true) 
		and self.map_layer.mapID ~= G_SHAWAR_DATA.mapId 
		and self.map_layer.mapID ~= G_SHAWAR_DATA.mapId1 
		and self.map_layer.mapID ~= 6018 then

		local time = getLocalRecordByKey(1, tostring( userInfo.currRoleStaticId or 0 ) .."shaWar_icon_click_time"..sdkGetOpenId())
		if time and time ~= 0 then
			local time1 = os.date("*t", time)
			local time2 = os.date("*t")
			if time1.year == time2.year and time1.month == time2.month and time1.day == time2.day then
				return
			end
		end

		local buttonFunc = function()
			setLocalRecordByKey(1, tostring( userInfo.currRoleStaticId or 0 ) .."shaWar_icon_click_time"..sdkGetOpenId(), os.time())		
			DATA_Battle:setRedData("SCZB", false)
			__GotoTarget({ru = "a84", index = 3})
		end
	    --按钮
	    self:createActivityIconData({priority= 20, 
						btnResName = "res/mainui/subbtns/sczb.png",
						btnResLab = game.getStrByKey("title_SCZB"),
						btnCallBack = buttonFunc,
						btnRemoveTime = 30,
						btnZorder = 100})	  
	elseif not isOpen then
		self:removeActivityIcon("shaWar")
	end
end

function BaseMapScene:createNewActivityNode( tag )
	if G_CONTROL:isFuncOn( GAME_SWITCH_ID_COPY ) == false then return end

	local function createInfoBtn()

		if not tag then return nil end--空值无效
		if not tag.q_key then return nil end--没有配置唯一键值 不做展示

	  	local keys = { 
	  					-- 策划缩写 = { ICON名称， 音效编号 }
	  					WorldBoss = { 	"sjbs" , 	49 	,	"a9"	} ,
	  					Luoxia = 	{ 	"lxdb" , 	51 	,	"a103"	} ,
	  					XZKP = 		{ 	"gwgc" , 	53 	,	"a109"	} ,
	  					XWZJ = 		{ 	"xwzj" , 	54 	,	"a153"	} ,
	  					jjc = 		{ 	"jjc" , 	0 	,	"a172"	} ,
	  					SZRQ = 		{ 	"szrq" , 	0 	,	"a173"	} ,
	  					skyArena = 	{ 	"gpjjc" , 	0 	,	"a230"	} ,
	  					-- hhwzys = 	{ 	"zqhd" , 	0  	,	""	} ,
	  					-- hhgh = 		{ 	"zjgz" , 	0 	,	""	} ,
	  					-- Envoy = 	{ 	"ycly" , 	0 	,	"a152"	} ,
	  					-- Bodyguard = { 	"hsbc" , 	0 	,	"a155"	} ,
	  					-- MXWK = 		{ 	"wk" , 		0 	,	"a82"	} ,
	  					}
	  	
	  	if not keys[ tag.q_key ] then return nil  end--不在keys列表的不展示图标

		local buttonFunc = function()
			setLocalRecordByKey(1, tostring( userInfo.currRoleStaticId or 0 ) .. "activity" .. tag.q_id .. "_icon_click_time"..sdkGetOpenId(), os.time())
			if DATA_Battle then DATA_Battle:setRedData( tag.q_key , false ) end
			__GotoTarget( { ru = keys[ tag.q_key ][3] } )
		end
	    
		
	   	self.NewActivityAudio = self.NewActivityAudio or {}
	   	local resName = keys[ tag.q_key ][1] or "sjbs"
	    if not self.NewActivityAudio[resName] then
	    	self.NewActivityAudio[resName] = true
	    	if  keys[ tag.q_key ][2] ~= 0 then liuAudioPlay("sounds/liuVoice/" .. keys[ tag.q_key ][2] .. ".mp3",false) end
	    end
	    
	    --按钮s
	    local node = self:createActivityIconData({priority= 10, 
	    							btnResName = "res/mainui/subbtns/"..resName..".png",
	    							btnResLab =  tag.q_name ,
	    							btnCallBack = buttonFunc,
	    							removeCallBack = removeFunc,
	    							btnRemoveTime = 30,
	    							btnZorder = 100})
	    return node
	end

	if  G_ROLE_MAIN and not G_MAINSCENE.map_layer:isHideMode(true) and not self:isActivityMap(G_MAINSCENE.map_layer.mapID)  then
		 

		local time = getLocalRecordByKey(1, tostring( userInfo.currRoleStaticId or 0 ) .. "activity" .. tag.q_id .. "_icon_click_time"..sdkGetOpenId())
		if time and time ~= 0 then
			local time1 = os.date("*t", time)
			local time2 = os.date("*t")
			if time1.year == time2.year and time1.month == time2.month and time1.day == time2.day then
				return
			end
		end
		
		local func = function()
			local node = createInfoBtn()

			-- if TOPBTNMG then TOPBTNMG:showMG( "Activity" , true ) end
		end
		--func()
		performWithDelay( self , func , 1.0 )
	end
end

function BaseMapScene:removeActivityIcon(activityName)
	local resPathName = ""
	if activityName then

		local resName = { WorldBoss = "sjbs", Envoy = "ycly", Luoxia = "lxdb", Bodyguard = "hsbc", XZKP = "gwgc", XWZJ = "xwzj", MXWK = "wk", jjc = "jjc", hhwzys = "zqhd", hhgh = "zjgz",
					  empireOther = "ldzd", biqi = "zzzb", shaWar = "sczb", SZRQ = "szrq",
					}
		if resName[activityName] then
			resPathName = "res/mainui/subbtns/"..resName[activityName]..".png"
		end
	end
	local func = function()
		self:removeActivityIconData({
			btnResName = resPathName
			})
	end
	performWithDelay( self , func , 1.0 )
end

function BaseMapScene:removeActivityIconData(param)	
	param = param or {}

	if param.btnResName and param.btnResName ~= "" and self.ActivityIconData then
		for k,v in pairs(self.ActivityIconData) do
 			if v.btnResName == param.btnResName then
				if v.timer then
					self:stopAction(v.timer)
					v.timer = nil
				end 				
 				if v.node then
 					removeFromParent(v.node)
 				end
 				self.ActivityIconData[k] = nil
 				self:createActivityIconUI()
 				break
 			end
 		end
 	end
end

function BaseMapScene:removeAllACtivityIcon()
	if self.ActivityIconData then
		for k,v in pairs(self.ActivityIconData) do
			if v.timer then
				self:stopAction(v.timer)
				v.timer = nil
			end 				
			if v.node then
				removeFromParent(v.node)
			end
			self.ActivityIconData[k] = nil
		end
		self:createActivityIconUI()
	end
end

function BaseMapScene:createActivityIconData(param)
	--在主界面上显示通知图标
	--定时活动     优先级--10
	--中州沙城领地 优先级--20
	--扫荡奖励     优先级--30
	--行会副本     优先级--20
	param = param or {}
	param.priority  = param.priority or 10  --显示优先级
	param.btnZorder = 99

	self.ActivityIconData = self.ActivityIconData or {}

	if self:CheckEmpireState() or self:checkShaWarState() then
		return nil
	end

	local addFlg = false
	if param.btnResName and param.btnResName ~= "" then
		for k,v in pairs(self.ActivityIconData) do
			if v.btnResName == param.btnResName then
				return v.node
			end
		end

		local IconNum = tablenums(self.ActivityIconData)
		if IconNum == 3 then
			local smallIcon
			for k,v in pairs(self.ActivityIconData) do
				if nil == smallIcon then
					smallIcon = k
				elseif v.priority < self.ActivityIconData[smallIcon].priority then
					smallIcon = k
				end
			end

			if smallIcon and self.ActivityIconData[smallIcon].priority < param.priority then
				local data = self.ActivityIconData[smallIcon]
				if data.timer then
					self:stopAction(data.timer)
					data.timer = nil
				end 								
 				if self.ActivityIconData[smallIcon].node then
 					removeFromParent(self.ActivityIconData[smallIcon].node)
 					self.ActivityIconData[smallIcon].node = nil
 				end

 				self.ActivityIconData[smallIcon] = param
 				addFlg = true 				
			end
	 	else
	 		addFlg = true
	 		table.insert(self.ActivityIconData, param)
		end
	end
	if not addFlg then return nil end

	return self:createActivityIconUI(param)
end

function BaseMapScene:createActivityIconUI(param)
	local num = 1
	local retBtn
	param = param or {}
	local IconNum = tablenums(self.ActivityIconData)	
	local iconWidth = 75
	for k,v in pairs(self.ActivityIconData) do
		if num > 3 then break end

		local node
		if v.node then
			v.node:setPosition(cc.p(display.cx - IconNum*iconWidth /2 + (num-1)*iconWidth+ iconWidth/2, 240))
		else

			local removeIcon = function()
				if v.timer then
					self:stopAction(v.timer)
					v.timer = nil
				end
				removeFromParent(v.node)
				self.ActivityIconData[k] = nil
				self:createActivityIconUI()			
			end

			local buttonFunc = function()
				if v.removeCallBack then
					v.removeCallBack()
				end

				if v.btnCallBack then
					v.btnCallBack()
				end

				removeIcon()
			end
			node = cc.Node:create()
			self:addChild(node, v.btnZorder)
	 		local button = createMenuItem(node, v.btnResName, cc.p(0, 0), buttonFunc)
		    local lab = createLabel(button, v.btnResLab, cc.p(button:getContentSize().width/2, 15), nil, 32, true):setColor(MColor.lable_yellow)
		    --lab:enableShadow(cc.c4b(30, 30, 30, 255),cc.size(2,2))
		    lab:enableOutline(cc.c4b(0, 0, 0, 255), 2)
		    
		    node.button = button
		    node.button:setScale(0.5)
		    node:setPosition(cc.p(display.cx - IconNum*iconWidth /2 + (num-1)*iconWidth + iconWidth/2, 240))
		    v.node = node


		    if v.btnRemoveTime then
		    	v.timer = startTimerAction(self, v.btnRemoveTime or 30 , false, function()
				    	if v.removeCallBack then
				    		v.removeCallBack()
				    	end
				    	removeIcon()		    		
		    	end)
		   	end	
		end
		if param.btnResName and v.btnResName == param.btnResName then
			retBtn = node
		end 		
		num = num + 1
 	end

 	return retBtn
end
	
--展示敌人图像
function BaseMapScene:showEnemyHead()
	local removeFunc = function()
		if self.enemy_node then
			removeFromParent(self.enemy_node) 
			self.enemy_node = nil
		end
	end
	local function createInfoBtn()
		local node = cc.Node:create()
	    --按钮
	    local button = createMenuItem(node, "res/mainui/enemy.png" , cc.p(0, 0), function() removeFunc() SOCIAL_DATA:popupBox() end )
	    performWithNoticeAction(button)
	    return node
	end
	removeFunc()
	local node = createInfoBtn()
	self:addChild(node)
	node:setLocalZOrder(100)
	node:setPosition( display.cx + 180, 240 )
	self.enemy_node = node
end
--展示邮件
function BaseMapScene:showMail()
	if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isfb then return end
	if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isExerciseRoom then return end
	--公平竞技场不能进邮件
	if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then return end
	if G_MAIL_INFO then
		if self.mailFlag then 
			removeFromParent( self.mailFlag ) 
			self.mailFlag = nil 
		end
		if G_MAIL_INFO.emaliCount and G_MAIL_INFO.emaliCount > 0 then
			local createInfoBtn = function()
				local node = cc.Node:create()
			    --按钮
			    local func = function()
					if self.mailFlag then
						removeFromParent( self.mailFlag ) 
						self.mailFlag = nil 
					end
			    	__GotoTarget( { ru = "a79" } )
			    end
			    local button = createMenuItem(node, "res/mainui/mail.png" , cc.p(0, 0), func )
			    performWithNoticeAction(button)
			    return node
			end
			local node = createInfoBtn()
			self.mailFlag = node
			self:addChild(node)
			node:setLocalZOrder(100)
			node:setPosition( display.cx , 150  )
		end

	end
end
--玩法提醒
function BaseMapScene:showWftx( flag )

	if G_MAINSCENE.mailFlag then return end --有邮件不展示
	if G_MAINSCENE.wftxFlag then return end --已存在不展示
	if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isfb then return end
	--公平竞技场不能进邮件
	if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then return end
	if DATA_Battle and DATA_Battle.D.wftxNum >= 3 then return end--每天最多三次展示
	if DATA_Battle and DATA_Battle.D.isOnline == false then return end--在线不足一个小时(不创建提示按钮)

	local data = DATA_Battle:getData()
	if data == nil then return end 	--日常活动数据异常返回
	local boxCount = #data.boxAward
	if boxCount <= 0 then return end
	local maxIntegral = data.boxAward[ boxCount ]["integral"]
	if data.nowIntegral >= maxIntegral then return end--活跃度已满不再提醒



	local function createNode()

		if self.wftxFlag then 
			removeFromParent( self.wftxFlag ) 
			self.wftxFlag = nil 
		end
		
		local itemData = DATA_Battle:getRandomData() 
		if itemData == nil then return end

		local createInfoBtn = function()
			local node = cc.Node:create()
		    --按钮
		    local func = function()
				if self.wftxFlag then
					removeFromParent( self.wftxFlag ) 
					self.wftxFlag = nil 
				end
				
				local str = string.format( game.getStrByKey( "rcwf1" ) , MRoleStruct:getAttr(ROLE_NAME) , ( itemData.q_name or "" ) )
				local clickFun = function()
			        if itemData.isDesc and itemData.isDesc == 1 then
			            package.loaded[ "src/layers/battle/DescLayer" ] = nil
			            require( "src/layers/battle/DescLayer" ).new( itemData )
			        else
			            __GotoTarget( {ru =  itemData.q_go } )
			        end
				end
				addSpecialPrivate( str , game.getStrByKey( "faction_gotoJoin" ), game.getStrByKey("chat_tip_usrName"), clickFun ) 

				require("src/layers/battle/BattleList"):showBattleChat( itemData )
		    end

		    local button = createMenuItem(node, "res/mainui/wftx.png" , cc.p(0, 0), func )
		    performWithNoticeAction(button)
		    --local txtSp = createSprite( button , "res/common/bg/score_needed_bg2.png" , cc.p( button:getContentSize().width/2 , 0 ) , cc.p( 0.5 , 0 ) )
		    --createLabel( txtSp , game.getStrByKey("rcwf") ,getCenterPos( txtSp ) , cc.p( 0.5 , 0.5 ) , 28 , nil , nil , nil , MColor.lable_yellow )
		    return node
		end

		local node = createInfoBtn()
		self.wftxFlag = node
		self:addChild(node)
		node:setLocalZOrder(100)
		node:setPosition( display.cx , 180 - 30   )
	end

	createNode()

end
--组队镖车展示图标
function BaseMapScene:showDartBtn( _createFun , _tempData )
	local downTime = nil 
	local function clearFun()
		if self.dartBtnFlag then 
			removeFromParent( self.dartBtnFlag ) 
			self.dartBtnFlag = nil 
		end
	end
	clearFun()

	if _createFun == nil and _tempData == nil then
		return
	end
	
	local createInfoBtn = function()
		local node = cc.Node:create()
	    --按钮
	    local func = function()
	    	_tempData.downTime = downTime
	    	if _createFun then _createFun( _tempData ) end
	    end
	    local button = createMenuItem(node, "res/mainui/119.png" , cc.p(0, 0), func )
	    -- button:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.15, 1.1), cc.ScaleTo:create(0.15, 0.9) )))
	    return node
	end
	local node = createInfoBtn()
	self.dartBtnFlag = node
	self:addChild(node)
	node:setLocalZOrder(100)
	node:setPosition( display.cx - 150 , display.cy + 150  )

	local tiemCallFun = function( timeValue )
		downTime = timeValue
		if timeValue <= 0 then clearFun() end
	end

	return tiemCallFun
end


--展示穿云箭
function BaseMapScene:showArrowBtn( buff , isData )
	local RoleID = nil 
	local RoleName = nil 
	local downTime = 180
	local MapID = nil 
	local Pos = nil 
	if isData then
		RoleID = buff.RoleID
		RoleName = buff.RoleName --string类型，发出此号召的玩家名字
		downTime = buff.downTime
		MapID = buff.MapID
		Pos = buff.Pos
	else
		local t = g_msgHandlerInst:convertBufferToTable( "NoticeFactionMemProtocol" , buff )
		RoleID = t.roleSID --int类型，发出此号召的玩家ID
		RoleName = t.roleName --string类型，发出此号召的玩家名字
		MapID = t.roleMapID --string类型，对方地图
		Pos = t.rolePos --string类型，对方坐标
	end

	DATA_Activity.___arrowBtn = DATA_Activity.___arrowBtn or {}
	DATA_Activity.___arrowBtn.data = DATA_Activity.___arrowBtn.data or {}
	DATA_Activity.___arrowBtn.btns = DATA_Activity.___arrowBtn.btns or {}

	if DATA_Activity.___arrowBtn.btns[ RoleID .. "" ] then removeFromParent( DATA_Activity.___arrowBtn.btns[ RoleID .. "" ] )  DATA_Activity.___arrowBtn.btns[ RoleID .. "" ] = nil end
	local function createInfoBtn()
		local node = cc.Node:create()

	    --按钮
	    node.button = createMenuItem(node, "res/mainui/zh.png" , cc.p(0, 0), function() 
	    		if DATA_Activity.___arrowBtn.btns[ RoleID .. ""] then removeFromParent(DATA_Activity.___arrowBtn.btns[ RoleID .. ""])  DATA_Activity.___arrowBtn.btns[ RoleID .. ""] = nil end
	    		local mapInfo = getConfigItemByKey( "MapInfo" , "q_map_id" , MapID ) 
	    		local mapName = ""
	    		if mapInfo and mapInfo.q_map_name then
	    			mapName = mapInfo.q_map_name
	    		end
	    		
				MessageBoxYesNo(nil,string.format(game.getStrByKey("arrow_text") , mapName , RoleName ),
					function() 
						DATA_Activity.___arrowBtn.data[ RoleID .. ""] = nil 
						g_msgHandlerInst:sendNetDataByTableExEx( SPILLFLOWER_CS_SENDMEMBER , "SendFactionMemProtocol", { targetSID = RoleID , targetMapID = MapID , targetPos = Pos } )
					end,
					function() 
					end,
					game.getStrByKey("sure"),game.getStrByKey("cancel") )		
	    		
	    	end )
	    node.button:setScale(0.75)
	    performWithNoticeAction(node.button)
	   
	    return node
	end

	local tempBtn = createInfoBtn()
	DATA_Activity.___arrowBtn.data[ RoleID .. ""] = { RoleID = RoleID , RoleName = RoleName , downTime = downTime , MapID = MapID , Pos = Pos }
	DATA_Activity.___arrowBtn.btns[ RoleID .. ""] = tempBtn
	self:addChild(tempBtn)
	tempBtn:setLocalZOrder(100)
	tempBtn:setPosition(display.cx + 180, 330)

	local function down_delayFun()
		for key , v in pairs( DATA_Activity.___arrowBtn.data ) do
			v.downTime = v.downTime - 1
			if v.downTime<=0 then
				removeFromParent( DATA_Activity.___arrowBtn.btns[ key ] )
				DATA_Activity.___arrowBtn.data[ key ] = nil
				DATA_Activity.___arrowBtn.btns[ key ] = nil
			end
		end

		if tablenums(DATA_Activity.___arrowBtn.data) <=0 then
			DATA_Activity:regClockFun( "__showArrowBtn" , nil )
		end
	end
	DATA_Activity:regClockFun( "__showArrowBtn" , down_delayFun )
end


function BaseMapScene:isCarryMode(mapid)
	local map_id = mapid or self.mapId
	local itemdate = getConfigItemByKey("AreaFlag", "mapID", map_id)
	if map_id == 6000 or map_id == 6001 or map_id == 6002 or map_id == 6003 or itemdate then
		return true
	end

	return false
end

function BaseMapScene:isActivityMap(map_id)
	if map_id == 6000 or map_id == 6001 or map_id == 6002 or map_id == 6003 or 
	   map_id == 7000 or map_id == 7001 or map_id == 7002 or map_id == 7003 or
	   map_id == 6020 or map_id == 6021 or map_id == 6022 or
	   map_id == 6030 or map_id == 6031 or map_id == 6032 or	   
	   map_id == 1220 or map_id == 6017 or map_id == 6018 then
		return true
	end

	return false
end

function BaseMapScene:enterUndefinedMap(mapId)
	if self.undefinedbtn then
		removeFromParent(self.undefinedbtn)
		self.undefinedbtn = nil 
	end

	if self.undefinedNode then
		removeFromParent(self.undefinedNode)
		self.undefinedNode = nil
	end

	if mapId == 2124 then
		local openUndefindLayer = function()
			if self.undefinedNode then
				self.undefinedNode:updateInfo()
			end
		end
        
        local node = require("src/layers/activity/cell/undefinedNode").new()
		self.base_node:addChild(node, 101)
		self.undefinedNode = node

		self.undefinedbtn = createMenuItem( self.BuffNode , "res/mainui/anotherbtns/undefined.png" , cc.p( 216 + 110, g_scrSize.height - 82) , openUndefindLayer ,2)
		createLabel(self.undefinedbtn, game.getStrByKey("kill_list"), cc.p(60 + 5, 16), nil, 20, true, nil, nil, cc.c3b(201, 195, 171))
	end
end

function BaseMapScene:enterDertFb(mapId)
	if mapId == 5003 then
		if self.DartFbNode == nil then
			self.DartFbNode = require("src/layers/fb/FBDart").new()
			self:addChild(self.DartFbNode, 100)	
		end
	end
end

function BaseMapScene:checkFireWorkMap(mapId)
	--如果进入的是全民宝地
	if mapId == 7000 or mapId == 7001 or mapId == 7002 or mapId == 7003 then
		self:enterFireWorkMap(objId)
	end
end

function BaseMapScene:enterFireWorkMap(objId)
	if self.FireWorkNode == nil then
		self.FireWorkNode = require("src/layers/activity/cell/FireWorkSideNode").new(objId)
		self:addChild(self.FireWorkNode, 100)
		self.FireWorkNode:setPosition(cc.p(0, 0))
	end
end

function BaseMapScene:checkCarryMode(mapId)
	--如果进入的是重装使者
	if mapId == 6000 or mapId == 6001 or mapId == 6002 or 
	   mapId == 6020 or mapId == 6021 or mapId == 6022 or
	   mapId == 6030 or mapId == 6031 or mapId == 6032 then
		self:enterCarryMode(objId)
	end
end

function BaseMapScene:enterCarryMode(objId)
	if self.carryNode == nil then
		self.carryNode = require("src/layers/carry/CarrySideNode").new(objId)
		self.mainui_node:addChild(self.carryNode, 6)

		if self.carryNode.NeedChangeVisibleNode then
			self.carryNode.NeedChangeVisibleNode:setVisible(not BaseMapScene.full_mode)
		end
	end
end

--山贼入侵
function BaseMapScene:enterInvade(mapId)
	if mapId == 6017 then
		local InvadeLayer = require("src/layers/activity/cell/InvadeLayer").new()
		self:addChild( InvadeLayer , 6 )
	end
end

function BaseMapScene:setMapEmpireInfo(objId, mapid)

	G_EMPIRE_INFO.BATTLE_INFO.manorID = -1
	local itemDate, defPos = getBattleAreaInfo(mapid)
	if itemDate then
		if defPos then
			G_EMPIRE_INFO.BATTLE_INFO.defaultPos = defPos
		end
		if itemDate.manorID then
			G_EMPIRE_INFO.BATTLE_INFO.manorID = itemDate.manorID
		end
	end
end

-----------------------剧情模式整合------------------
function BaseMapScene:enterStoryMode(mapid)
	log("BaseMapScene:enterStoryMode")
    
    self:exitStoryMode()
	if self.storyNode == nil then
        if  mapid == 1000 then
            self.storyNode = require("src/layers/story/StoryNode").new()
		elseif mapid == 2116 then
            self.storyNode = require("src/layers/story/StoryGongSha").new()
        elseif mapid == 2117 then
            self.storyNode = require("src/layers/story/StoryGongShaHuangGong").new()
		elseif mapid == 2118 then
            self.storyNode = require("src/layers/story/shousha/StoryShouShaHG").new()
        elseif mapid == 2119 then
            self.storyNode = require("src/layers/story/shousha/StoryShouShaCheng").new()
        elseif mapid == 2134 then
            self.storyNode = require("src/layers/story/shousha/StoryShouShaHGTwo").new()
        elseif mapid == 2135 then
            self.storyNode = require("src/layers/story/shousha/StoryShouShaChengTwo").new() 
        elseif mapid == 5001 then
            self.storyNode = require("src/layers/story/dartEscort/StoryDartEscort").new() 
        elseif mapid == 5002 then
            self.storyNode = require("src/layers/story/dartCut/StoryDartCut").new() 
        elseif mapid == 5004 then
            self.storyNode = require("src/layers/story/shouhu/StoryShouHu").new() 
        elseif mapid == 5006 then
            self.storyNode = require("src/layers/story/mine/StoryWaKuang").new() 
        elseif mapid == 5007 then
            self.storyNode = require("src/layers/story/mine/StoryQiangKuang").new() 
        elseif mapid == 5009 then
            self.storyNode = require("src/layers/story/story3V3Practice/Story3V3Practice").new()
        elseif mapid == 5018 then
            self.storyNode = require("src/layers/story/StoryGongSha").new()
            self.storyNode.m_isFBMode = true
        elseif mapid == 5019 then
            self.storyNode = require("src/layers/story/StoryGongShaHuangGong").new()
            self.storyNode.m_isFBMode = true        
        end

        if self.storyNode then
		    self:addChild(self.storyNode, 198)
		    self.storyNode:updateState()
        end
	end

	if G_MAINSCENE and G_MAINSCENE.map_layer and self.storyNode then 
		G_MAINSCENE.map_layer:setLocalZOrder(197)
		G_MAINSCENE.map_layer.isStory = true
	end

    -- 如果是通过屠龙传说界面进去的，主动打开该界面[模拟剧情本]
    if G_STORY_FB_MODE and self.storyNode == nil then
        G_STORY_FB_MODE = false

        if DragonData.DRAGON_SLIAYER_WINDOW then
            DragonData.DRAGON_SLIAYER_WINDOW = false;
        
            if G_MAINSCENE then
                performWithDelay(G_MAINSCENE, function()
                    if G_MAINSCENE and G_MAINSCENE.map_layer then
                        __GotoTarget{ ru="a127" };
                    end
                end, 0)
            end
        end
    end
end

function BaseMapScene:exitStoryMode()
	log("BaseMapScene:exitStoryMode")
    if self.storyNode then
	    removeFromParent(self.storyNode)
	    self.storyNode = nil
    end

	if G_MAINSCENE and G_MAINSCENE.map_layer then 
		G_MAINSCENE.map_layer:setLocalZOrder(-1)
		G_MAINSCENE.map_layer.isStory = false
	end

    if G_ROLE_MAIN then
        G_ROLE_MAIN:setVisible(true)
    end
end
---------------------------------------------------------------------------------

function BaseMapScene:enterStoryExMode()
	--log("BaseMapScene:enterStoryExMode 11111111111111111111111111111111111111111")
	log("BaseMapScene:enterStoryExMode")

	if G_STORY_ON == false then 
		return
	end

	if self.storyNodeEx == nil then
		self.storyNodeEx = require("src/layers/story/StoryExNode").new()
		self:addChild(self.storyNodeEx, 400)
		self.storyNodeEx:updateState()
	end

	if G_MAINSCENE and G_MAINSCENE.map_layer then 
		G_MAINSCENE.map_layer:setLocalZOrder(399)
		G_MAINSCENE.map_layer.isStory = true
	end
end

function BaseMapScene:exitStoryExMode()
	--log("BaseMapScene:enterStoryExMode 22222222222222222222222222222222222222222")
	log("BaseMapScene:exitStoryExMode")
    if self.storyNodeEx then
	    removeFromParent(self.storyNodeEx)
	    self.storyNodeEx = nil
    end

	if G_MAINSCENE and G_MAINSCENE.map_layer then 
		G_MAINSCENE.map_layer:setLocalZOrder(-1)
		G_MAINSCENE.map_layer.isStory = false
		TIPS( { type = 5 } )
	end

    ---------------------------屏蔽欢迎页--------------------------------------
	--require("src/layers/welcome/WelcomeLayer").new(self)
end

---------------------------------------------------------------------------------

function BaseMapScene:EnterDragonStoryMode(dragonCfg)
    if self.dragonStoryNode == nil and dragonCfg ~= nil then
		self.dragonStoryNode = require("src/layers/story/DragonStory").new(dragonCfg)
		self:addChild(self.dragonStoryNode, commConst.ZVALUE_UI+1)
		self.dragonStoryNode:UpdateState()
	end

	if G_MAINSCENE and G_MAINSCENE.map_layer then 
		G_MAINSCENE.map_layer:setLocalZOrder(commConst.ZVALUE_UI-1)
	end
end

function BaseMapScene:ExitDragonStoryMode(dragonCfg)
    removeFromParent(self.dragonStoryNode)
	self.dragonStoryNode = nil;

	if G_MAINSCENE and G_MAINSCENE.map_layer then 
		G_MAINSCENE.map_layer:setLocalZOrder(-1)
		
        if dragonCfg ~= nil then
            require("src/layers/DragonSliayer/DragonDetail").new(dragonCfg);
        end
	end
end

---------------------------------------------------------------------------------

function BaseMapScene:enterFactionFb(objId)
	log("BaseMapScene:enterFactionFb.................")
	if self.FactionFbNode == nil then
		G_MAINSCENE.map_layer.isFactionFb = true
		self.FactionFbNode = require("src/layers/faction/FactionFBNode").new(objId)
		self:addChild(self.FactionFbNode, 100)
		self.FactionFbNode:setPosition(cc.p(0, display.cy + 50))
	end
end

function BaseMapScene:checkShaWarState()
	if (G_SHAWAR_DATA.mapId == G_MAINSCENE.map_layer.mapID or G_MAINSCENE.map_layer.mapID == G_SHAWAR_DATA.mapId1) and G_SHAWAR_DATA.startInfo.isActive then
		return true
	end
	return false
end

function BaseMapScene:CheckEmpireState(manorID)
	local mapid = G_MAINSCENE.map_layer.mapID
	local itemdate = getBattleAreaInfo(mapid)
	if itemdate and itemdate.manorID == (manorID or G_EMPIRE_INFO.BATTLE_INFO.manorID) then
		return true
	end
	return false
end

function BaseMapScene:enterEmpireMap(mapid)
	local itemdate = getBattleAreaInfo(mapid)
	if itemdate then
		local delaFunc = function()
			if self.biQiInfoNode == nil then
				self.biQiInfoNode = require("src/layers/empire/BiQiInfoNode").new(itemdate.manorID, mapid)
				self:addChild(self.biQiInfoNode, 100)
			end

		    function exitConfirm()
		    	local func = function()
		    		g_msgHandlerInst:sendNetDataByTableExEx(MANORWAR_CS_SENDOUT,"ManorSendOutProtocol", {})
		    	end
		        MessageBoxYesNo(nil, game.getStrByKey("exit_confirm"), func, nil)
		    end
		    local item = createMenuItem(self, "res/component/button/1.png", cc.p(g_scrSize.width-67, g_scrSize.height-98),exitConfirm)
		    item:setSmallToBigMode(false)
		    createLabel(item, game.getStrByKey("exit"), getCenterPos(item), cc.p(0.5,0.5), 22, true):setColor(MColor.lable_yellow)
		    self.biqiExitBtn = item				
		end
		performWithDelay(self, delaFunc, 0.0)
		
		self:changePlayColor()
		G_EMPIRE_INFO.BATTLE_INFO.bannerX = G_EMPIRE_INFO.BATTLE_INFO.defaultPos.x
		G_EMPIRE_INFO.BATTLE_INFO.bannerY = G_EMPIRE_INFO.BATTLE_INFO.defaultPos.y
		
		if self.map_layer then 
			self.map_layer:removeSaftArea()
			G_MAINSCENE:showArrowPointToMonster(true, cc.p(G_EMPIRE_INFO.BATTLE_INFO.bannerX, G_EMPIRE_INFO.BATTLE_INFO.bannerY), true)
		end
		
		-- AudioEnginer.stopMusic()
		-- AudioEnginer.playMusic("sounds/mapMusic/7.mp3",true)

		if G_ROLE_MAIN then
		    G_ROLE_MAIN:upOrDownRide(false,true)
		end
	end
end

function BaseMapScene:clearBiqiModeUi( )
	--if self.biQiInfoNode ~= nil then
	--	removeFromParent(self.biQiInfoNode)
	--	self.biQiInfoNode = nil
	--end

	if self.map_layer then 
		self.map_layer:addSaftArea()
	end

	if __TASK then 
		__TASK:hideIcon(self.isHide_icon or BaseMapScene.hide_task) 
	end

	if self.task_btn_node then 
		self.task_btn_node:setVisible(not self.isHide_icon) 
	end
	G_MAINSCENE:showArrowPointToMonster(false)
end

function BaseMapScene:addRobBoxInfoNode()
	if self.robBoxInfo == nil then
		self.robBoxInfo = require("src/layers/activity/cell/RobBoxNodeInfo").new()
		self:addChild(self.robBoxInfo, 100)
		self.robBoxInfo:setPosition(cc.p(0, 0))
		self:changePlayColor()
		
		-- AudioEnginer.stopMusic()
		-- AudioEnginer.playMusic("sounds/mapMusic/6.mp3",true)
	end
end
function BaseMapScene:createDyingLayer()
	local layer = require("src/base/DyingEffectLayer").new()
	self:addChild(layer, 300)
	self.dyingLayer = layer
end

function BaseMapScene:createPingNode()
	local node = require("src/layers/ping/PingNode").new()
	return node
end

function BaseMapScene:checkBagNotice()
	local bagPack 

	if MPackManager then
		bagPack = MPackManager:getPack(MPackStruct.eBag)
	end

	if bagPack then
		--背包已满
		if bagPack:numOfGirdRemain() == 0 then
			self:createBagNoticeNode()
		else
			self:removeBagNoticeNode()
		end
	end
end

function BaseMapScene:createBagNoticeNode()
	if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
		return
	end
	if self.bagNoticeNode == nil then
		local bagBtn 
		local function buttonFunc()
			local sub_node = require("src/layers/bag/BagView").new()
			if sub_node then
				self.base_node:addChild(sub_node,200,103)
				removeFromParent(self.bagNoticeNode)
	 			self.bagNoticeNode = nil 
	 		end
		end

	    self.bagNoticeNode = cc.Node:create()
	    self:addChild(self.bagNoticeNode)
	    self.bagNoticeNode:setLocalZOrder(100)

	    bagBtn = createMenuItem(self.bagNoticeNode, "res/mainui/bagNotice.png", cc.p(0, 0), buttonFunc)
		bagBtn:setPosition(cc.p(display.cx + 70, 150))
		bagBtn:blink()
		performWithNoticeAction(bagBtn)
		G_TUTO_NODE:setTouchNode(bagBtn, TOUCH_MAIN_BAG_NOTICE)
		if getLocalRecord("tuto15") ~= true then
			--开启背包整理引导
			if G_TUTO_DATA then
				for k,v in pairs(G_TUTO_DATA) do
					if v.q_id == 15 then
						v.q_state = TUTO_STATE_OFF
					end
				end
			end
		end
	end
end

function BaseMapScene:removeBagNoticeNode()
	if self.bagNoticeNode ~= nil then
		removeFromParent(self.bagNoticeNode)
		self.bagNoticeNode = nil
	end
end

function BaseMapScene:initHangUpCheck()
	self:clearHangUpCheck()
	--self:addHangUpCheck()
end

function BaseMapScene:addHangUpCheck(isForTuto)
	if isForTuto == true then
		if game.getAutoStatus() == 0 and G_TUTO_NODE.touchNodeList and G_TUTO_NODE.touchNodeList[TOUCH_MAIN_TASK_GUIDE] then
			tutoAddTipOnNode(G_TUTO_NODE.touchNodeList[TOUCH_MAIN_TASK_GUIDE], nil, nil, TOUCH_MAIN_TASK_GUIDE, nil, nil, function() 
					return game.getAutoStatus() ~= 0
				end)
			end
		return
	end

	if self.checkHangUpAction then
		self:stopAction(self.checkHangUpAction)
		self.checkHangUpAction = nil
	end
	local lv = MRoleStruct:getAttr(ROLE_LEVEL) or 1
	local checkMaxLevel = 20
	local checkHangUpFunc = function()
		--log("checkHangUpFunc")
		if self.hangUpCheckTuto == true then
			return
		end
		--log("checkHangUpFunc 1")
		if self.map_layer and self.map_layer.isfb then
			return
		end

		if (not G_TUTO_NODE) or G_TUTO_NODE.tutoLayer then 
			return
		end
		local lv = MRoleStruct:getAttr(ROLE_LEVEL) or 1
		if lv > 1 and lv < checkMaxLevel then
			--log("checkHangUpFunc 3 status = "..game.getAutoStatus())
			if game.getAutoStatus() == 0 and G_TUTO_NODE.touchNodeList and G_TUTO_NODE.touchNodeList[TOUCH_MAIN_TASK_GUIDE] then
				--log("checkHangUpFunc 4")
				tutoAddTipOnNode(G_TUTO_NODE.touchNodeList[TOUCH_MAIN_TASK_GUIDE], nil, nil, TOUCH_MAIN_TASK_GUIDE, nil, nil, function() 
						--log("check game.getAutoStatus() = "..game.getAutoStatus())
						return game.getAutoStatus() ~= 0
					end)
				self.hangUpCheckTuto = true
			end
		elseif lv >= checkMaxLevel then
			if self.checkHangUpAction then
				self:stopAction(self.checkHangUpAction)
				self.checkHangUpAction = nil
			end
		end
	end
	if lv < checkMaxLevel then
		self.checkHangUpAction = startTimerAction(self, 8, true, checkHangUpFunc)
	end

end

function BaseMapScene:checkMainFunc()
	if game.getAutoStatus() == 0 then
		self.timer = self.timer or 0
		--self.timer = self.timer + 1
		if BaseMapScene.auto_mine and tablenums(self.map_layer.mineTab) > 0 then
			for k,v in pairs(self.map_layer.mineTab)do
				self.map_layer:touchNpcFunc(self.map_layer.item_Node:getChildByTag(v))
				BaseMapScene.auto_mine = nil
				break
			end
		end
		if self.timer == 400 and MRoleStruct:getAttr(ROLE_LEVEL) >= 35 then
	    	self.timer = 0
	    	local tdata = getConfigItemByKey("HotAreaDB")
		  	local num1 = #tdata
		  	self.tp = {}
		  	for i = 1, num1 do
		  		if tdata[i].q_tar_mapid then
		  			self.tp[tdata[i].q_tar_mapid] = {}
		  			self.tp[tdata[i].q_tar_mapid].x = tdata[i].q_sjcs_x
		  			self.tp[tdata[i].q_tar_mapid].y = tdata[i].q_sjcs_y
		  		else
		  			cclog("数据为nil!!!!")
		  		end
		  	end
			local gotoMine = function(id)
				__shoesGoto( { mapid = id , x = self.tp[id].x , y = self.tp[id].y } ,true)
			end
			local gotoMine1 = function(id)
				local detailMapNode = require("src/layers/map/DetailMapNode")
      			detailMapNode:goToMapPos( id , cc.p(self.tp[id].x ,self.tp[id].y) , false )
      			BaseMapScene.auto_mine = true
			end
			local mapInfo = require("src/config/MapInfo")
		    local mapOfMine = ""
		    local mapOfId = 0
		    for k,v in pairs(mapInfo) do
		        if v.q_map_id ~= 20001 and v.q_mapresid == "kd" then
		            if MRoleStruct:getAttr(ROLE_LEVEL) >= v.q_map_min_level then
		                mapOfMine = v.q_map_name
		                mapOfId = v.q_map_id
		            elseif MRoleStruct:getAttr(ROLE_LEVEL) < v.q_map_min_level then
		                break
		            end
		        end
		    end

			if tablenums(self.map_layer.mineTab) > 0 then
				for k,v in pairs(self.map_layer.mineTab)do
					self.map_layer:touchNpcFunc(self.map_layer.item_Node:getChildByTag(v))
					break
				end
			else
				MessageBoxYesNoEx(nil,string.format(game.getStrByKey("goto_mine"),mapOfMine),
					function() 
						gotoMine(mapOfId) 
					end,
					function() 
						gotoMine1(mapOfId)
					end,
					game.getStrByKey("delivery"),game.getStrByKey("auto_find_way"),true,true,5,3)		
			end

		end
	else
		self.timer = 0
	end	
end

function BaseMapScene:insertMulitTouch(touch)
	for k,v in pairs(G_MULTITOUCH_DATA) do
		if tolua.cast(v.adds,"cc.Touch") then
			if touch == v.adds then
				return
			end
		else
			G_MULTITOUCH_DATA[k] = nil
		end
	end
	--if #G_MULTITOUCH_DATA >= 4 then G_MULTITOUCH_DATA = {} end

	local record = {}
    record.adds = touch
	record.startPos = touch:getStartLocation()
	record.currPos  = touch:getLocation()
    table.insert(G_MULTITOUCH_DATA, record )
    -- performWithDelay(self, function( ... )
    -- 	BaseMapScene:restMulitTouch(touch)
    -- end, 5)
end

function BaseMapScene:checkMulitTouchNum()
    if G_MULTITOUCH_DATA ~= nil and #G_MULTITOUCH_DATA >= 2 and G_MAINSCENE ~= nil and G_MAINSCENE.map_layer ~= nil then
		G_MAINSCENE.map_layer.touch_node = nil
		G_MAINSCENE.map_layer.touch_npc     = nil
		G_MAINSCENE.map_layer.touch_role   = nil
		G_MAINSCENE.map_layer.touch_pet    = nil
		return true
	end
	return false
end

function BaseMapScene:restMulitTouch(touch)
	for k,v in pairs(G_MULTITOUCH_DATA) do
		if touch == v.adds then
			v = nil
			G_MULTITOUCH_DATA[k] = nil
		end
	end
end

function BaseMapScene:moveMulitTouch(touch)
	local newTouch = nil
	for k,v in pairs(G_MULTITOUCH_DATA) do
	    if v.adds == touch then
	        v.startPos = touch:getStartLocation()
	        v.currPos  = touch:getLocation()
	        v.isMove   = true
	        newTouch = v
	    end
	end

	local comperTwoPosition = nil
	comperTwoPosition = function(touch1, touch2)
		if  touch1 and touch2 and 
			touch1.startPos and touch1.currPos and 
			touch2.startPos and touch2.currPos then

			touch1.startPos = cc.p(math.floor(touch1.startPos.x),math.floor(touch1.startPos.y))
			touch1.currPos = cc.p(math.floor(touch1.currPos.x),math.floor(touch1.currPos.y))
			touch2.startPos = cc.p(math.floor(touch2.startPos.x),math.floor(touch2.startPos.y))
			touch2.currPos = cc.p(math.floor(touch2.currPos.x),math.floor(touch2.currPos.y))

			local left = nil
			local right = nil        	
		    if touch1.startPos.x < touch2.startPos.x then
		        left  = touch1
		        right = touch2
		    elseif touch1.startPos.x > touch2.startPos.x then
		        left  = touch2
		        right = touch1
		    else
		    	left  = touch1
		    	right = touch2
		    end
		    local offset = 10
		    if (left.currPos.x - left.startPos.x >= offset and right.currPos.x - right.startPos.x <= -offset) then 
		       --(left.currPos.x - left.startPos.x >= 0      and right.currPos.x - right.startPos.x <= -offset )then
		        self:hideTopIcon(false)
		        left.currPos  = left.startPos
		       	right.currPos = right.startPos
		        return
		    end
		    if (left.currPos.x - left.startPos.x <= -offset and right.currPos.x - right.startPos.x >= offset) then 
		       --(left.currPos.x - left.startPos.x <= 0       and right.currPos.x - right.startPos.x >= offset) then
		       self:hideTopIcon(true)
		       --玩家成功隐藏界面之后，会触发一个引导
		       tutoShow(429,true)
		       left.currPos  = left.startPos
		       right.currPos = right.startPos
		       return
		    end
   		end 	
	end

	for k,v in pairs(G_MULTITOUCH_DATA) do
		if v.isMove and v.currPos and v.adds ~= touch then
			comperTwoPosition(v, newTouch)
			break
		end
	end
end

function BaseMapScene:TouchLayerForTopIcon(  )
	local finalLayer1 = cc.Layer:create()
	G_MAINSCENE:addChild(finalLayer1, 5)
	local listenner1 = cc.EventListenerTouchOneByOne:create()
	listenner1:setSwallowTouches(false)
    listenner1:registerScriptHandler(function(touchs,event)
        --local touchItem = touchs[1]
    	self:insertMulitTouch(touchs)
    	self:checkMulitTouchNum()
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN) --EVENT_TOUCHES_BEGAN
    listenner1:registerScriptHandler(function(touchs,event)
        ---local touchItem = touchs[1]
 	    self:moveMulitTouch(touchs)
    end,cc.Handler.EVENT_TOUCH_MOVED) --EVENT_TOUCHES_MOVED
    listenner1:registerScriptHandler(function(touchs,event)
        --local touchItem = touchs[1]
		self:restMulitTouch(touchs)
    end,cc.Handler.EVENT_TOUCH_ENDED)   --  EVENT_TOUCHES_ENDED
	listenner1:registerScriptHandler(function(touchs,event)
        --local touchItem = touchs[1]
		self:restMulitTouch(touchs)
    end,cc.Handler.EVENT_TOUCH_CANCELLED)   --  EVENT_TOUCHES_ENDED

    local eventDispatcher = finalLayer1:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner1, finalLayer1)
end

function BaseMapScene:theFinalLayer()
	self:TouchLayerForTopIcon()
	local MRoleStruct = require("src/layers/role/RoleStruct")
	local final_node = cc.Node:create()
	self:addChild(final_node,101)
	local listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(false)
    listenner:registerScriptHandler(function(touch,event)
    	self.timer = 0
    	BaseMapScene.auto_mine = nil
    	if DATA_Battle then DATA_Battle.D.clockNum = 0 end
    	return true
	end,cc.Handler.EVENT_TOUCH_BEGAN)
	 local eventDispatcher = final_node:getEventDispatcher()
     eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,final_node)
end

function BaseMapScene:clearHangUpCheck()
	self.hangUpCheckTuto = false
end

function BaseMapScene:checkFriendNoticeNode()
	if G_FIREND_DATA and tablenums(G_FIREND_DATA) > 0 then
		if G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_FRIEND) then
			self:createFriendNoticeNode(G_FIREND_DATA)
		end
	end
end

function BaseMapScene:createFriendNoticeNode(tab)
	if self.friendNoticeNode == nil then
		self.friendNoticeNode = require("src/layers/friend/FriendNoticeNode").new(tab)
		self:addChild(self.friendNoticeNode)
		self.friendNoticeNode:setLocalZOrder(100)
		self.friendNoticeNode:setPosition(cc.p(display.cx + 180, 150))
	else
		self.friendNoticeNode:updateNumLabel()
	end
end

function BaseMapScene:checkFactionInviteNoticeNode()
	if G_FACTION_INVITE_DATA and tablenums(G_FACTION_INVITE_DATA) > 0 then
		if G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_FACTION) then
			self:createFactionInviteNoticeNode(G_FACTION_INVITE_DATA)
		end
	end
end

function BaseMapScene:createFactionInviteNoticeNode(tab)
	if self.factionInviteNoticeNode == nil then
		self.factionInviteNoticeNode = require("src/layers/faction/FactionInviteNoticeNode").new(tab)
		self:addChild(self.factionInviteNoticeNode)
		self.factionInviteNoticeNode:setLocalZOrder(100)
		self.factionInviteNoticeNode:setPosition(cc.p(display.cx + 180, 150))
	else
		self.factionInviteNoticeNode:updateNumLabel()
	end
end

function BaseMapScene:createRealVoiceOpenNtfNode(mapId)
	if not mapId or not G_FACTION_INFO.facname or getGameSetById(GAME_SET_VOICE_REALVOICE_OPEN) > 0 then
        return
    end
    
    --是否需要的地图
    local mapTab = {[6003]=1,[6005]=1,[6010]=1,[6011]=1,[6012]=1,[6013]=1,[6014]=1,[6015]=1,[6016]=1,[4100]=1,} 

    if not mapTab[mapId] then
        return
    end

    if mapId == 4100 and not G_SHAWAR_DATA.startInfo.isActive then
        return
    end

    --是否已提示过
    if require("src/layers/chat/ChatRealOpenNoticeNode"):isHaveTips(mapId) then
        return
    end
    
    if self.realVoiceOpenNtfNode == nil then
		self.realVoiceOpenNtfNode = require("src/layers/chat/ChatRealOpenNoticeNode").new(mapId)
		self:addChild(self.realVoiceOpenNtfNode)
		self.realVoiceOpenNtfNode:setLocalZOrder(100)
		self.realVoiceOpenNtfNode:setPosition(cc.p(display.cx + 179, 240 + 90))
	end
end

function BaseMapScene:createBottomBtn()
	--local node = BtnContainer:create("mainui/50.png",70)
	self.leftBottomBtn = {}
	self.rightBottomBtn = {}
	local width = g_scrSize.width <=1050 and g_scrSize.width or 1050
	local spanx = 82*width/960
	cc.SpriteFrameCache:getInstance():addSpriteFramesWithFileEx("res/mainui/mainui@0.plist", false, false)
	local node = createMainUiNode(self.mainui_node,100)
	--node:setPosition(g_scrSize.width/2,30)
	--self:addChild(node,100)
	local res_tabs = {"js","jn","bb","zb","pm","sj","cj","sz"}
	for i=0,10 do
		local func = function(target_id,hander)
			self:bottomItemTouched(i,hander)
			AudioEnginer.playEffect("sounds/uiMusic/ui_click5.mp3",false)
		end
		if i < 4 or i > 6 then
			local tagi = i
			local posi = i 
			if i < 4 then
				tagi = tagi + 1 
				posi =  i - 4.5
			else
				tagi = tagi - 2 
				posi = i - 5.5
			end
			--menu_node = MenuButton:create("res/mainui/bottombtns/"..(tagi)..".png","res/mainui/bottombtns/"..(tagi).."_sel.png")
			local menu_node = TouchSprite:createWithFrame("mainui/bottombtns/"..res_tabs[tagi]..".png","mainui/bottombtns/"..res_tabs[tagi].."_sel.png")
			if menu_node then
				menu_node:setPosition(cc.p(spanx*(posi), posY_bottomButton))
				--menu_node:setSelectAction(cc.DelayTime:create(0))
				if i == 0 then
					G_NFTRIGGER_NODE:addData(menu_node, NF_RIDE)
					G_NFTRIGGER_NODE:addData(menu_node, NF_WING)
					G_NFTRIGGER_NODE:addData(menu_node, NF_ARM)
					G_NFTRIGGER_NODE:addData(menu_node, NF_WEAPON)
					G_NFTRIGGER_NODE:addData(menu_node, NF_BEAUTY)
					self.role_redPoint = createSprite( menu_node , "res/component/flag/red.png" ,cc.p( menu_node:getContentSize().width - 5 , menu_node:getContentSize().height - 15 ) , cc.p( 0.5 , 0.5 ) )
					self.role_redPoint:setVisible( false )
					G_TUTO_NODE:setTouchNode(menu_node, TOUCH_MAIN_ROLE)
				elseif i == 1 then
					self.skill_redPoint = createSprite( menu_node , "res/component/flag/red.png" ,cc.p( menu_node:getContentSize().width - 5 , menu_node:getContentSize().height - 15 ) , cc.p( 0.5 , 0.5 ) )
					self.skill_redPoint:setVisible( false )
					G_TUTO_NODE:setTouchNode(menu_node, TOUCH_MAIN_SKILL)
				elseif i == 2 then 
					self.bag_redPoint = createSprite( menu_node , "res/component/flag/red.png" ,cc.p( menu_node:getContentSize().width - 5 , menu_node:getContentSize().height - 15 ) , cc.p( 0.5 , 0.5 ) )
					self.bag_redPoint:setVisible(false)
				 	G_NFTRIGGER_NODE:addData(menu_node, NF_FURNACE)
				 	G_TUTO_NODE:setTouchNode(menu_node, TOUCH_MAIN_BAG)
				elseif i == 3 then  --装备
                    self.equip_redPoint = createSprite( menu_node , "res/component/flag/red.png" ,cc.p( menu_node:getContentSize().width - 5 , menu_node:getContentSize().height - 15 ) , cc.p( 0.5 , 0.5 ) )
					self.equip_redPoint:setVisible(false)
					G_NFTRIGGER_NODE:addData(menu_node, NF_WASH)
					G_NFTRIGGER_NODE:addData(menu_node, NF_BLESS)
					G_NFTRIGGER_NODE:addData(menu_node, NF_STRENGTHEN)
					G_NFTRIGGER_NODE:addData(menu_node, NF_GOLD)
					G_TUTO_NODE:setTouchNode(menu_node, TOUCH_MAIN_EQUIP)
				elseif i == 7 then  --拍卖行
					G_TUTO_NODE:setTouchNode(menu_node, TOUCH_MAIN_SELL)
				 	G_NFTRIGGER_NODE:addData(menu_node, NF_AUCTION)
				elseif i == 8 then --社交
					G_TUTO_NODE:setTouchNode(menu_node, TOUCH_MAIN_SOCIAL)
				 	G_NFTRIGGER_NODE:addData(menu_node, NF_FRIEND)
				 	G_NFTRIGGER_NODE:addData(menu_node, NF_FACTION)

	                self.__mailRed = createSprite( menu_node , "res/component/flag/red.png" ,cc.p( menu_node:getContentSize().width - 5 , menu_node:getContentSize().height - 15 ) , cc.p( 0.5 , 0.5 ) )
	                local isRed = false
	                if G_MAIL_INFO and G_MAIL_INFO.emaliCount and G_MAIL_INFO.emaliCount > 0 then
	                	isRed = true
	                end
	                self.__mailRed:setVisible( isRed )

				elseif i == 9 then --成就
	    --             self.faction_redPoint = createSprite( menu_node , "res/component/flag/red.png" ,cc.p( menu_node:getContentSize().width - 5 , menu_node:getContentSize().height - 15 ) , cc.p( 0.5 , 0.5 ) )
	    --             self:setFactionRedPointVisible()
					-- G_TUTO_NODE:setTouchNode(menu_node, TOUCH_MAIN_FACTION)
				 -- 	G_NFTRIGGER_NODE:addData(menu_node, NF_FACTION)

				 	G_TUTO_NODE:setTouchNode(menu_node, TOUCH_MAIN_ACHIEVEMENT)
				elseif i == 10 then
					G_TUTO_NODE:setTouchNode(menu_node, TOUCH_MAIN_SET)
				end
				--menu_node:registerScriptTapHandler(func)
				menu_node:registerTouchUpHandler(func)
				node:addChild(menu_node)
				if i < 4 then 
					self.leftBottomBtn[i+1] = {}
					self.leftBottomBtn[i+1].node = menu_node
					self.leftBottomBtn[i+1].pos = cc.p(menu_node:getPosition())
				elseif i > 6 then 
					self.rightBottomBtn[i-6] = {}
					self.rightBottomBtn[i-6].node = menu_node
					self.rightBottomBtn[i-6].pos = cc.p(menu_node:getPosition())
				end
			end
		end
	end
    self.leftButtonPos = {}
    self.rightButtonPos = {}
    for k, v in ipairs(self.leftBottomBtn) do
        table.insert(self.leftButtonPos, cc.p(v.node:getPosition()))
    end
    for k, v in ipairs(self.rightBottomBtn) do
        table.insert(self.rightButtonPos, cc.p(v.node:getPosition()))
    end
	self.bottom_node = node
    self.bottom_node:setPosition(cc.p(g_scrSize.width / 2, 28))
    self:processEquipButtonRedDot()
    self:updateBagRedPoint()
end

function BaseMapScene:resetBottomBtn()
	local maxIndex = #self.leftBottomBtn
	local nodeIndex = maxIndex
	for i=maxIndex,1,-1 do
		local useNodeIndex
		for i=nodeIndex,1,-1 do
			if self.leftBottomBtn[i].node:isVisible() then 
				useNodeIndex = i
				break
			end
		end

		if useNodeIndex and self.leftBottomBtn[useNodeIndex].node then 
			self.leftBottomBtn[useNodeIndex].node:setPosition(self.leftBottomBtn[i].pos)
			nodeIndex = useNodeIndex-1
		end
	end

	local maxIndex = #self.rightBottomBtn
	local nodeIndex = 1
	for i=1,maxIndex do
		local useNodeIndex
		for i=nodeIndex,maxIndex do
			if self.rightBottomBtn[i].node:isVisible() then 
				useNodeIndex = i
				break
			end
		end

		if useNodeIndex and self.rightBottomBtn[useNodeIndex].node then 
			self.rightBottomBtn[useNodeIndex].node:setPosition(self.rightBottomBtn[i].pos)
			nodeIndex = useNodeIndex+1
		end
	end
end

function BaseMapScene:bottomItemTouched(index,hander)
	if self.base_node:getChildByTag(101 + index) then
		self.base_node:removeChildByTag(101 + index)
	end
	local sub_node = nil 
	local spanx = 94
	if g_scrSize.width == 960 then
		spanx = 85
	end
	local touch_x = 95+index*spanx
	if index > 4 then
		touch_x = 95+(index-1)*spanx
	end

	local subFunc = function(sub_index)
		local tmp_sub_node = nil 
		local switch = {
			[1] = function()
				__GotoTarget( { ru = "a124" } )--装备熔炼
			end,
			
			[2] = function()
				__GotoTarget( { ru = "a163" } )--装备传承
			end,
			
			[3] = function()
				__GotoTarget( { ru = "a164" } )--装备强化
			end,
			
			[4] = function()
				__GotoTarget( { ru = "a165" } )--装备祝福
			end,
			
			[5] = function()
				__GotoTarget( { ru = "a185" } )--装备点金
			end,
			
			[6] = function()
				__GotoTarget( { ru = "a141" } )--装备打造
			end,
			
			[7] = function()
				__GotoTarget( { ru = "a186" } )--物品合成
			end,
			
			[8] = function()
				tmp_sub_node = require("src/layers/friend/SocialNode").new()
			end,
			[9] = function()    -- for case 2
				tmp_sub_node = require("src/layers/friend/MasterAndSocialLayer").new()
			end,
			[10] = function()    -- fo r case 3
				local secondaryPass = require("src/layers/setting/SecondaryPassword")
				if not secondaryPass.isSecPassChecked() then
					secondaryPass.inputPassword()
					return
				end
				if G_NFTRIGGER_NODE:isFuncOn(NF_FACTION) then
					dump(G_FACTION_INFO)
					if G_FACTION_INFO.id and G_FACTION_INFO.id > 0 then
						tmp_sub_node = require("src/layers/faction/FactionLayer").new()
						--self:addChild(layer,200,100+index)
					else
						tmp_sub_node = require("src/layers/faction/FactionCreateAndListLayer").new()
						--self:addChild(layer,200,100+index)
					end
				else
					TIPS({type=1, str=string.format(game.getStrByKey("func_unavailable_lv"), 36)})
				end
			end,

            -- add new layer jieyi
            [11] = function()
                local jyCommFunc = require("src/layers/jieyi/JieYiCommFunc")
                if jyCommFunc.getJYId() > 0 then
                    tmp_sub_node = require("src/layers/jieyi/JieYi").new()
                    --tmp_sub_node = require("src/layers/jieyi/JieYiTransform").new()
                else
                    if MRoleStruct:getAttr(ROLE_LEVEL) >= 40 then
                        --jyCommFunc.showJieYiErrorCode(12)
                        if sub_node then
                            sub_node:removeSelf()
                        end
                        
                        local function findWayFunc()
                            autoFindWayToSpecialNpc(2100,130,121,10480)
                        end
                        local function TransmitFunc()
                            useShoseToSpecialNpc(2100,130,121,10480)
                        end
                        MessageBoxYesNoEx(nil,game.getStrByKey("jieyi_gotoJLSZ") ,findWayFunc ,TransmitFunc,game.getStrByKey("auto_find_way"), game.getStrByKey("delivery"),true)

                    else
                        --MessageBox(game.getStrByKey("jieyi_noLevel"))
                        TIPS({type=1,str=game.getStrByKey("jieyi_noLevel")})
                    end
                    
                end
                
            end,
			
			[12] = function()
				__GotoTarget( { ru = "a166" } ) --装备洗炼
			end,

            [13] = function()
                __GotoTarget( { ru = "a206" } ) --战队界面
            end,
            [14] = function()
                __GotoTarget( { ru = "a79" } ) --邮件界面
            end,

		}
	 	if switch[sub_index] then
	 	 	switch[sub_index]()
			if tmp_sub_node then
	 			self.base_node:addChild(tmp_sub_node,200)
	 		end
	 	end
	end

	local switch = {
		[0] = function()
			local secondaryPass = require("src/layers/setting/SecondaryPassword")
			if not secondaryPass.isSecPassChecked() then
				secondaryPass.inputPassword()
				return
			else
				sub_node = require("src/layers/beautyWoman/RoleAndBeautyLayer").new() 
			end
		end,
		[1] = function()    -- for case 2
			sub_node = require("src/layers/skill/SkillsLayer").new()
		end,
		[2] = function()    -- for case 3
		 	sub_node = require("src/layers/bag/BagView").new()
		end,
		[require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP] = function()    --元婴=
			local secondaryPass = require("src/layers/setting/SecondaryPassword")
			if not secondaryPass.isSecPassChecked() then
				secondaryPass.inputPassword()
				return
			end
		
			local params = {}
			dump(G_NFTRIGGER_NODE:isFuncOn(NF_FURNACE))
			if G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_FURNACE) then
				params[#params+1] = {res = "rl", func = function() subFunc(1) end}--熔炼
			end
			if not G_NO_OPEN_INHERIT then
				params[#params+1] = {res = "cc", func = function() subFunc(2) end}
			end
			if G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_STRENGTHEN) then
				params[#params+1] = {res = "qh", func = function() subFunc(3) end}
			end
			if G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_BLESS) then
				params[#params+1] = {res = "zf", func = function() subFunc(4) end}
			end
			if G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_GOLD) then
				params[#params+1] = {res = "dj", func = function() subFunc(5) end}
			end
			if G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_WASH) then
				params[#params+1] = {res = "xl", func = function() subFunc(12) end}
			end
			params[#params+1] = {res = "dz", func = function() subFunc(6) end}
			params[#params+1] = {res = "hc", func = function() subFunc(7) end}

			local pos = cc.p(self.leftBottomBtn[3+1].node:getPosition())
			pos = self.leftBottomBtn[3+1].node:getParent():convertToWorldSpace(pos)
			sub_node = require("src/base/SubNode").new(params,cc.p(pos.x,110))

		end,
		[7] = function()    --拍卖行
			checkIfSecondaryPassNeed(function()
				sub_node = require("src/layers/consign/ConsignLayer").new()
			end)
			--sub_node = createSprite(nil, "res/mainui/juese.jpg", cc.p(0, 0), cc.p(0.5, 0.5))
		end,
		[8] = function()    --好友
			local params = {}
           	if G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_FRIEND) then
           		params[#params+1] = {res = "hy", func = function() subFunc(8) end} -- 好友
           	end
           	if require("src/layers/role/RoleStruct"):getAttr(ROLE_LEVEL) >= 19 then
				params[#params+1] = {res = "bs", func = function() subFunc(9) end} --拜师
			end
			if G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_FACTION) then
				params[#params+1] = {res = "hh", func = function() subFunc(10) end} -- 行会
			end

            -- add new button jieyi
            params[#params+1] = {res="jy",func= function() subFunc(11) end}  -- jieyi
            --params[#params+1] = {res="zd",func= function() subFunc(13) end}  -- 战队
            params[#params+1] = {res="mail",func= function() subFunc(14) end}  -- 邮件

			local pos = cc.p(self.rightBottomBtn[8-6].node:getPosition())
			pos = self.rightBottomBtn[8-6].node:getParent():convertToWorldSpace(pos)
			sub_node = require("src/base/SubNode").new(params,cc.p(pos.x,110))
		end,
		[9] = function()  --成就
			sub_node = require("src/layers/achievementEx/AchievementAndTitleLayer").new()
		end,
		[10] = function () --设置
			__GotoTarget( { ru = "a142" } )--装备图鉴 
		end
	}
 	if switch[index] then
 	 	switch[index]()
 		if sub_node then
 			self.base_node:addChild(sub_node, 200, require("src/config/CommDef").TAG_SUB_NODE_BUTTON + index)
 			--[[
 			Manimation:transit(
			{
				ref = self.base_node,
				node = sub_node,
				curve = "-",
				--sp = cc.p(hander:getPosition()),
				zOrder = 200,
				tag = 101+index,
				--swallow = swallow1,
			})
			]]
 		end
 	end
end


function BaseMapScene:gotoSocial()
	-- if G_NFTRIGGER_NODE:isFuncOn(NF_FRIEND) then
	--     self:bottomItemTouched(8)
	-- else
	-- 	TIPS({type=1, str=string.format(game.getStrByKey("func_unavailable_lv"), 8)})
	-- end
	if NewFunctionIsOpen(NF_FRIEND) then
		self:bottomItemTouched(8)
	end
end

function BaseMapScene:createHeadInfo()
	self.head_node = cc.Node:create()
	self.topLeftNode:addChild(self.head_node,2)
	local sprite = createSprite(self.head_node,getSpriteFrame("mainui/head/headbg.png"),cc.p(1,g_scrSize.height-2),cc.p(0.0,1.0))
	createSprite(sprite, "res/common/misc/power_b.png", cc.p(80, 25), cc.p(0, 0), nil, 0.5)
    
    -- function createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
 	self.name_label  = createLabel(sprite,"", cc.p(160,60), cc.p(0.5, 0), 20,nil,108)
 	self.name_label:setColor(MColor.lable_yellow)
	local pingNode = self:createPingNode()
	sprite:addChild(pingNode)
	pingNode:setPosition(cc.p(360, 95))
	self.pingNode = pingNode
	g_msgHandlerInst:sendNetDataByTableEx(FRAME_CG_HEART_BEAT,"FrameHeartBeatReq",{})
	if self.pingNode then
		self.pingNode:check(FRAME_CG_HEART_BEAT) 
	end

 	local run_mode = true
 	local head_path = "mainui/head/1.png"
 	if G_ROLE_MAIN then
 		head_path = "mainui/head/"..(G_ROLE_MAIN:getSchool()+(G_ROLE_MAIN:getSex()-1)*3)..".png"
 	end
    
 	local sprite1 = createTouchItem(self.head_node,{head_path},cc.p(0,g_scrSize.height-3),function()
		-- if self.map_layer and (not self.map_layer.isMine) then
		-- 	self:setFullShortNode(not BaseMapScene.full_mode)
		-- end
		if self.map_layer and self.map_layer.isSkyArena then
			return
		end
		__GotoTarget({ru = "a57"})
	end)
	sprite1:setScale(0.9)
	local lv_bg = createSprite(self.head_node,getSpriteFrame("mainui/head/headbg1.png"),cc.p(0,g_scrSize.height-2),cc.p(0.0,1.0),100)
    lv_bg:setTag(991)
	self.level_label = createLabel(lv_bg,"",cc.p(18, 20),nil,18,true,nil,108)
	self.level_label:setColor(MColor.lable_yellow)
--	self.head_redPoint = createSprite( sprite1, getSpriteFrame("mainui/flag/red.png") ,cc.p( sprite1:getContentSize().width + 5 , sprite1:getContentSize().height - 10 ) , cc.p( 0.5 , 0.5 ) )
--	self.head_redPoint:setVisible( false )
	G_TUTO_NODE:setTouchNode(sprite1, TOUCH_MAIN_HEAD)
	setNodeAttr(sprite1,nil,cc.p(0.0,1.0),5,55)

    --QQvip信息
    self:createQQVipSign()

	local pkmode = require("src/layers/pkmode/PkModeLayer"):getCurMode()
	local pkmode_str = "res/mainui/pkmode/"..(pkmode+1);

    local pkModeStrs = {
        game.getStrByKey("pkmode_heping_str"),
        game.getStrByKey("pkmode_zudui_str"),
        game.getStrByKey("pkmode_banghui_str"),
        game.getStrByKey("pkmode_quanti_str"),
        game.getStrByKey("pkmode_shane_str"),
        game.getStrByKey("pkmode_gongsha_str")
    }
	
	local pkmodeFunc = function()
	    local func = function(tag)
	    	g_msgHandlerInst:sendNetDataByTable(FRAME_CS_CHANGE_MODE, "FrameChangeModeProtocol", {mode=tag-1})
	      	if self.operate then
		      	removeFromParent(self.operate)
		      	self.operate = nil
		    end
	    end
	    local menus = {
	      {game.getStrByKey("pkmode_heping"),1,func,game.getStrByKey("pkmode_heping_dis")},
	      {game.getStrByKey("pkmode_zudui"),2,func,game.getStrByKey("pkmode_zudui_dis")},
	      {game.getStrByKey("pkmode_banghui"),3,func,game.getStrByKey("pkmode_banghui_dis")},
	      {game.getStrByKey("pkmode_quanti"),4,func,game.getStrByKey("pkmode_quanti_dis")},
	      {game.getStrByKey("pkmode_shane"),5,func,game.getStrByKey("pkmode_shane_dis")},
	      {game.getStrByKey("pkmode_gongsha"),6,func,game.getStrByKey("pkmode_gongsha_dis")},
	    }
	    self.operate =  require("src/base/PkmodeSetLayer").new(self,1,menus)
	    self.operate:setPosition(cc.p(267-g_scrSize.width/2, g_scrSize.height/2-291))
	end
	local function checkMap()
	    	local mapCfg = getConfigItemByKey( "MapInfo" , "q_map_id" , self.mapId )
	    	if (mapCfg and mapCfg.q_all_safe and tonumber( mapCfg.q_all_safe ) == 1) or (self.map_layer and  self.map_layer.isJjc) or (self.map_layer and self.map_layer.is3v3) or (self.map_layer and self.map_layer.isSkyArena)then
				local msg_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{3000,-11})
				if msg_item and msg_item.fat then
					local msgStr = string.format( msg_item.msg , buff:readByFmt(msg_item.fat) )
					TIPS( { type = msg_item.tswz , str = msgStr } )
				else
					TIPS( msg_item )
				end
	    	else
				pkmodeFunc()
	    	end
	end

    ---------------------------------------------------------------------------------
    self.m_attackmodeSpan = createScale9SpriteMenu(self.head_node, "res/common/scalable/4.png", cc.size(110, 40), cc.p(110, g_scrSize.height-80), function()
            print("self.m_attackmodeSpan");
            checkMap();
        end);
    self.m_attackmodeSpan:setOpacity(0);
    ---------------------------------------------------------------------------------

    --function createSprite(parent, pszFileName, pos, anchor, zOrder, fScale)
    local pkModeSpr = createSprite(self.head_node, "res/mainui/pkmode/pkmodebg.png", cc.p(57,g_scrSize.height-96), cc.p(0, 0));
	local sprite1 = createMenuItem(pkModeSpr,pkmode_str..".png",cc.p(14,16),checkMap )
	self.attackmode_node = sprite1
	--setNodeAttr(sprite1,nil,nil,6)
	G_TUTO_NODE:setTouchNode(sprite1 ,TOUCH_MAIN_MODE)
	--sprite1:setAnchorPoint(cc.p(0.0,1.0))

    --function createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
    self.m_pkModeLal = createLabel(pkModeSpr, pkModeStrs[pkmode+1], cc.p(34,3), cc.p(0, 0),20,true, nil, nil, cc.c3b(201, 195, 171))

	--self:createTouchHandler(sprite1)
end

function BaseMapScene:createQQVipSign()
     --if LoginUtils.isQQLogin() or isWindows() then
     if isWindows() then  --暂时关闭qq登录等
        if self.head_node then
            local lv_bg = self.head_node:getChildByTag(991)
            if lv_bg then
                lv_bg:removeChildByTag(9)
                if game.getVipLevel() == 1 then
                    local spr = createSprite(lv_bg,"res/layers/qqMember/vip.png",cc.p(76,20),cc.p(0.5,0.5))
                    spr:setTag(9)
                elseif game.getVipLevel() == 2 then
                    local spr = createSprite(lv_bg,"res/layers/qqMember/svip.png",cc.p(76,20),cc.p(0.5,0.5))
                    spr:setTag(9)
                end
            end
        end        
    end
end

function BaseMapScene:csbdOpen(status)

	-- if status == 2 then
	-- 	if TOPBTNMG then 
	-- 		TOPBTNMG:showMG( "Dictionary" , true ) 
	-- 		local csbdBtn =  TOPBTNMG:getBtn( "Dictionary" )
	-- 		self.csbdEffect = Effects:create(false)
	-- 	    self.csbdEffect:playActionData("NewTeachSmall", 19, 2, -1)
	-- 	    self.csbdEffect:setScale(0.9)
	-- 	    setNodeAttr( self.csbdEffect , getCenterPos( csbdBtn ) , cc.p( 0.5 , 0.5 ) )
	-- 	    csbdBtn:addChild(self.csbdEffect, 1)
	-- 	end
	-- elseif status == 3 then
	-- 	if self.csbdEffect then
	-- 		removeFromParent(self.csbdEffect)
	-- 		self.csbdEffect = nil
	-- 	end
	-- end
end

function BaseMapScene:expBallButton(bagId)
	local MPackStruct = require "src/layers/bag/PackStruct"
	local MPackManager = require "src/layers/bag/PackManager"
	local pack = MPackManager:getPack(MPackStruct.eBag)
	local expNum = {}
	if bagId then
		local openBag = pack:countByProtoId(bagId)
		if openBag > 0 then
			expBallInit(bagId)
		end
	-- else
	-- 	for i=1,5 do
	-- 		expNum[i] = pack:countByProtoId(2008+i)
	-- 		if expNum[i] > 0 then
	-- 			local expBallId = 2008 + i
	-- 			expBallInit(expBallId)
	-- 		end
	-- 	end
	end
end

function BaseMapScene:spoolerButton(theName,spoolPos,canUseNum)
	local MPackStruct = require "src/layers/bag/PackStruct"
	local MPackManager = require "src/layers/bag/PackManager"
	local pack = MPackManager:getPack(MPackStruct.eBag)
	local expNum = {}
	local function propDeal(spoolerId)
		local grids = pack:getGirdsByProtoId(spoolerId)  --获得物品id格子的索引
		for k,v in pairs(grids) do
			if spoolPos and k == spoolPos then

			else
				local isBind = MPackStruct.attrFromGird(v, MPackStruct.eAttrBind)
				local propNum = MPackStruct.overlayFromGird(v)
				if canUseNum and canUseNum > 0 and propNum > canUseNum and theName == 1 then
					propNum = canUseNum
				end
				spoolerInit(spoolerId,isBind,propNum,k)
			end
		end
	end
	if theName == 2 then          --2是金条金砖
		for i=1,2 do
			expNum[i] = pack:countByProtoId(2000+i)
			if expNum[i] > 0 then
				local spoolerId = 2000 + i
				propDeal(spoolerId)
			end
		end
	elseif theName == 1 then                         --1是悬赏卷轴
		for i=1,3 do
			expNum[i] = pack:countByProtoId(9006+i)
			if expNum[i] > 0 then
				local spoolerId = 9006 + i
				propDeal(spoolerId)
			end
		end
	elseif theName == 3 then            --3是经验珠
		for i=1,6 do
			expNum[i] = pack:countByProtoId(2008+i)
			if expNum[i] > 0 then
				local spoolerId = 2008 + i
				propDeal(spoolerId)
			end
		end
	end
end


function BaseMapScene:theVipUpdateTip()
	if G_MAINSCENE and G_MAINSCENE.base_node:getChildByTag(9935) == nil then
		local tempLayer = popupBox({ 
	                --parent = getRunScene()  , 
	                bg = "res/achievement/19.png" , 
	                zorder = 90 ,
	                isNoSwallow = true , 
	                actionType = 7 ,
	                pos = cc.p(display.cx,220),
	                anch = cc.p(0.5,0.5)
	               })
		local size = tempLayer:getContentSize()
		createSprite(tempLayer,"res/layers/vip/VIP.png",cc.p(size.width/8,size.height/2),cc.p(0.5,0.5))
		tempLayer:setTag(9935)
		
	 	createLabel(tempLayer,game.getStrByKey("vipUpdateTip"),cc.p(130,135),cc.p(0,0.5),20,true,nil,nil,MColor.yellow_gray)
	 	createSprite(tempLayer,"res/layers/vip/words1.png",cc.p(125,105),cc.p(0,0.5))
	 	createSprite(tempLayer,"res/layers/vip/words2.png",cc.p(260,105),cc.p(0,0.5))
	 	--createLabel(tempLayer,game.getStrByKey("vipUpdateTip1"),cc.p(140,80),cc.p(0,0.5),20,true,nil,nil,MColor.yellow_gray)
	    local richText = require("src/RichText").new( tempLayer , cc.p( 290 , 65 ) , cc.size( 320, 130 ) , cc.p( 0.5 , 0.5 ) , 30 , 20 , MColor.yellow_gray )
	    richText:addText( game.getStrByKey("vipUpdateTip1") , MColor.yellow_gray  )
	    richText:format()
	    createSprite(tempLayer,"res/layers/vip/vipExpUp.png",cc.p(size.width/2,size.height/2+65),cc.p(0.5,0.5))
	
		local button = createTouchItem(tempLayer,"res/component/button/5.png",cc.p(515,95),function()
				__GotoTarget({ru = "a92"})
				if tempLayer then
					removeFromParent(tempLayer) 
					tempLayer = nil
				end 
		end,true)
		createLabel(button,game.getStrByKey("readPower"),cc.p(button:getContentSize().width/2,button:getContentSize().height/2),cc.p(0.5,0.5),25,true,nil,nil,MColor.yellow_gray)
		if tempLayer then
			registerOutsideCloseFunc(tempLayer,function() 
					if tempLayer then
						removeFromParent(tempLayer) 
						tempLayer = nil
					end 
				end,true)
		end
	end
end

function BaseMapScene:updateHeadInfo(storyHp,storyMp)
	if G_ROLE_MAIN then
		local MRoleStruct = require("src/layers/role/RoleStruct")

        local rolehp = MRoleStruct:getAttr(ROLE_HP) or 0
        local rolemaxhp = MRoleStruct:getAttr(ROLE_MAX_HP) or rolehp
        if rolemaxhp == 0 then
            rolemaxhp = 1
        end

        rolehp = storyHp or rolehp
      	G_ROLE_MAIN:setHP(rolehp)
		local hp_percent = (rolehp/rolemaxhp)*100
		if hp_percent < 0 then hp_percent = 0 
		elseif hp_percent > 100 then hp_percent = 100 end

        local rolemp = MRoleStruct:getAttr(ROLE_MP) or 0
        local rolemaxmp = MRoleStruct:getAttr(ROLE_MAX_MP) or rolemp
        if rolemaxmp == 0 then
            rolemaxmp = 1
        end

        rolemp = storyMp or rolemp
		local mp_percent =(rolemp/rolemaxmp)*100
		if mp_percent < 0 then mp_percent = 0 
		elseif mp_percent > 100 then mp_percent = 100 end

		self.r_pro_blood:setPercentage(100-hp_percent)
		self.r_pro_magic:setPercentage(100-mp_percent)
		if hp_percent > 0 and hp_percent < 1 then hp_percent = 1 end
		if mp_percent > 0 and mp_percent < 1 then mp_percent = 1 end
		self.blood_label:setString(""..math.floor(hp_percent).."%")
		self.magic_label:setString(""..math.floor(mp_percent).."%")
		
		local posx ,scalex, scaley = 60,0 ,0.5
		if hp_percent < 5 then
		elseif hp_percent < 15 then
			scaley = 0.3
			posx = 52 +  hp_percent/2 
			scalex = 0.05 + (hp_percent)/30	
		elseif hp_percent < 35 then
			posx = 60 +  (hp_percent - 15) / 5
			scalex = 0.15 + (hp_percent)/60	
		elseif hp_percent < 70 then
			posx = 60 -  (hp_percent - 35) / 3.5
			scalex = 0.65 - (hp_percent - 35) / 300
		elseif hp_percent < 90 then
			scaley = 0.5 - (hp_percent - 70) / 100
			posx = 48 +  (hp_percent - 70) / 6
			scalex = 1.2 - hp_percent/100	
		end
		self.blood_s:setScale(scalex,scaley)
		self.blood_s:setPosition(cc.p(posx,hp_percent*0.8))

		local posx ,scalex = 27,0 
		local posx ,scalex ,scaley = 60,0 ,0.6
		if mp_percent < 10 then
		elseif mp_percent < 15 then
			scaley = 0.3
			posx = 61 +  mp_percent/5
			scalex =  0.1 + (mp_percent-10)/10	
		elseif mp_percent < 22 then
			scaley = 0.5
			posx = 66 +  (mp_percent - 15) /20
			scalex = 0.2 + (mp_percent - 15)/60	
		elseif mp_percent < 35 then
			posx = 64 +  (mp_percent - 15) /20
			scalex = 0.3 + (mp_percent - 15)/100	
		elseif mp_percent < 70 then
			scaley = 0.4  + (mp_percent - 35) / 200
			posx = 65 -  (mp_percent - 35) / 3
			scalex = 0.5 + (mp_percent - 35) / 200
		elseif mp_percent < 90 then
			scaley =  0.7 - (hp_percent - 70) / 100
			posx = 51 +  (mp_percent - 70) / 5
			scalex = 0.7 - (mp_percent - 70) / 200
		end
		self.magic_s:setScale(scalex,scaley)
		self.magic_s:setPosition(cc.p(posx,mp_percent*0.8))
	end
end

function BaseMapScene:eatDrug()
    -- 进入副本等切换 Scene 可能导致 map 还未创建出来
    if G_MAINSCENE == nil or G_MAINSCENE.map_layer == nil or G_MAINSCENE.map_layer.mapID == nil then
        return;
    end

	local forbidDrug = getConfigItemByKey("MapInfo","q_map_id",G_MAINSCENE.map_layer.mapID,"q_forbidyaoshui")
	if G_ROLE_MAIN and G_ROLE_MAIN:isAlive() and (not forbidDrug) then
		local curMp = MRoleStruct:getAttr(ROLE_MP)
		local curHp = MRoleStruct:getAttr(ROLE_HP)
		local myMp = MRoleStruct:getAttr(ROLE_MAX_MP)
		local myHp = MRoleStruct:getAttr(ROLE_MAX_HP)
		local setMp = getGameSetById(GAME_SET_ID_USE_RED_MP)
		local setHp = getGameSetById(GAME_SET_ID_USE_RED_HP)
		local setHpShort = getGameSetById(GAME_SET_ID_USE_RED_HP_SHORT)
		local red1switch = getGameSetById(GAME_SET_RED1)
		local red2switch = getGameSetById(GAME_SET_RED2)
		local blueswitch = getGameSetById(GAME_SET_BLUE)
		local snowlotusswitch = getGameSetById(GAME_SET_SNOWLOTUS)

		if blueswitch == 1 and curMp and myMp and setMp and curMp < (myMp*(setMp/100)) then 
			require("src/layers/timeToTonic/tonicConfigHandler"):tonicInit(1)
		end
		if red1switch == 1 and curHp and myHp and setHp and curHp < (myHp*(setHp/100)) then			
			require("src/layers/timeToTonic/tonicConfigHandler"):tonicInit(10)
		end
		if red2switch == 1 and curHp and curHp and setHpShort and curHp < (myHp*(setHpShort/100)) then
			require("src/layers/timeToTonic/tonicConfigHandler"):tonicInit(100)
		end
		if snowlotusswitch == 1 then
			local levelLimit = getConfigItemByKey("propCfg","q_id",20023,"q_level")
			local lv = MRoleStruct:getAttr(ROLE_LEVEL)
			local pack = MPackManager:getPack(MPackStruct.eBag)
			local num = pack:countByProtoId(20023)
			if lv >= levelLimit and num > 0 then
				local eatlotus = true
				if g_buffs_ex[G_ROLE_MAIN.obj_id] then
					for key,v in pairs(g_buffs_ex[G_ROLE_MAIN.obj_id]) do
						if key == 30 then
							eatlotus = false
							break
						end
					end
				end
				if eatlotus then
					if G_ROLE_MAIN and G_ROLE_MAIN:isAlive() then 
						local MPackManager = require "src/layers/bag/PackManager"
						return MPackManager:useByProtoId(20023)
					end					
				end
			end
		end
	end
end

function BaseMapScene:buyDrug(drugId,isShow)
	if G_ROLE_MAIN and MRoleStruct:getAttr(ROLE_LEVEL) >= 30 and not (G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena) then
		local defaultSet = {}
		local function callDefaultDrug(num)
			while num > 9 do
				table.insert(defaultSet,math.floor(num%100))
				num = num/100
			end
		end
		local MpropOp = require "src/config/propOp"
		local proId = MpropOp.getBuyDrugTab()
		-- local proId = {{20028,200},{20025,200},{20035,500},{20037,4},{20023,50}} --写硬某些需要弹出提示的药品及价格
		local drug1 = getGameSetById(GAME_DEFAULT_DRUG_LONG_HP) --需要每次读取防止变化
		local drug2 = getGameSetById(GAME_DEFAULT_DRUG_SHORT_HP)
		local drug3 = getGameSetById(GAME_DEFAULT_DRUG_LONG_MP)
		callDefaultDrug(drug1)
		callDefaultDrug(drug2)
		callDefaultDrug(drug3)
		if self.shouldShowDrug and table.nums(self.shouldShowDrug) > 0 then
			for i = 1, table.nums(self.shouldShowDrug) do
				if drugId and self.shouldShowDrug[i][1] and self.shouldShowDrug[i][1] == drugId then
					if isShow then
						return
					else
						table.remove(self.shouldShowDrug,i)
					end
					break
				end
			end
		end
		if isShow then
			local pack = MPackManager:getPack(MPackStruct.eBag)
			for i = 1 ,#proId do
				if drugId == 20023 then
					if proId[i][1] == drugId then
						if pack:countByProtoId(proId[i][1]) <= 1 then						
							table.insert(self.shouldShowDrug,proId[i])
						end
					end
				else
					for j = 1,#defaultSet do
						if proId[i][1] == drugId and (proId[i][1]-20000) == defaultSet[j] then							
							if pack:countByProtoId(proId[i][1]) <= 1 then						
								table.insert(self.shouldShowDrug,proId[i])
							end
							break
						end
					end
				end
			end
		end		
		----------------------------------------------------
		if table.nums(self.shouldShowDrug) > 0 then
			for k ,v in pairs(G_DRUG_CHECK) do
				for m = 1, table.nums(self.shouldShowDrug) do
					if v == self.shouldShowDrug[m][1] then
						table.remove(self.shouldShowDrug,m)
						break
					end
				end
			end
		end		
		----------------------------------------------------
		if self.shouldShowDrug then
			local removeFunc = function()
				if self.drug_node then
					removeFromParent(self.drug_node) 
					self.drug_node = nil
				end
			end
			local showTip = function()
				local MChoose = require("src/functional/ChooseQuantity")
				local Mprop = require( "src/layers/bag/prop" )
				for i = 1 ,#self.shouldShowDrug do
					local drugIdTemp = self.shouldShowDrug[i] or {0,0,0}
					local isTouch = false	
                    -------------------------------------------------------------------------------
                    local attrKind = nil
                    if drugIdTemp[3] == 0 then
						-- yuanbao
                        attrKind = PLAYER_INGOT
					elseif drugIdTemp[3] == 1 then
						-- bangding yuanbao
                        attrKind = PLAYER_BINDINGOT
					elseif drugIdTemp[3] == 14 then
						-- jinbi
                        attrKind = PLAYER_MONEY
					end
                    local maxNum = 99
                    if attrKind then
                        local price = drugIdTemp[2]
                        local realMaxNum = math.floor(MRoleStruct:getAttr(attrKind) / price)
                        if realMaxNum == 0 then
                            realMaxNum = 1
                        end
                        if realMaxNum < maxNum then
                            maxNum = realMaxNum
                        end
                        --maxNum = 20
                    end
                    -------------------------------------------------------------------------------
					local box = MChoose.new(
					{
						title = game.getStrByKey("buy_prop"),
						parent = getRunScene(),
						config = { sp = 1 , ep = maxNum, cur = 1  },
						builder = function(box, parent)
							local cSize = parent:getContentSize()
							
							box:buildPropName(MPackStruct:buildGirdFromProtoId(drugIdTemp[1]), drugIdTemp[3] ~= 0)
							
							-- 物品图标
							local icon = Mprop.new(
							{
								protoId = drugIdTemp[1],
								cb = "tips",
								isBind = drugIdTemp[3] ~= 0,
							})
							
							Mnode.addChild(
							{
								parent = parent,
								child = icon,
								pos = cc.p(70, 264),
							})
							if drugIdTemp[3] == 0 then
								createSprite(parent,"res/group/currency/3.png",cc.p(315,264))
							elseif drugIdTemp[3] == 1 then
								createSprite(parent,"res/group/currency/4.png",cc.p(315,264))
							elseif drugIdTemp[3] == 14 then
								createSprite(parent,"res/group/currency/1.png",cc.p(315,264))
							end

							box.icon = icon
							
							local nodes = {}
							
							if single then
								nodes[#nodes+1] = Mnode.createLabel(
								{
									src = game.getStrByKey("single_buy_limits") .. ": " .. item.mSingleBuyNums.."/" .. singleBuyLimits,
									color = MColor.lable_yellow,
									size = 20,
									outline = false,
								})
							end
							
							if whole then
								nodes[#nodes+1] = Mnode.createLabel(
								{
									src = game.getStrByKey("whole_buy_limits") .. ": " .. (wholeBuyLimits-item.mWholeRemaining) .. "/" .. wholeBuyLimits,
									color = MColor.lable_yellow,
									size = 20,
									outline = false,
								})
							end
							
							local TotalPrice = Mnode.createKVP(
							{
								k = Mnode.createLabel(
								{
									src = game.getStrByKey("buy_totle_price").." ",
									color = MColor.lable_yellow,
									size = 20,
									outline = false,
								}),
								
								v = {
									src = "",
									color = MColor.lable_yellow,
									size = 20,
								},
							})
							
							nodes[#nodes+1] = TotalPrice
							
							Mnode.addChild(
							{
								parent = parent,
								child = Mnode.combineNode(
								{
									nodes = nodes,
									ori = "|",
									align = "l",
									margins = 5,
								}),
								
								anchor = cc.p(0, 0.5),
								--pos = cc.p(153, 243),
								pos = cc.p(130, 264),
							})
							
							box.TotalPrice = TotalPrice
						end,
						
						handler = function(box, value)
							-- if maxNum < 1 then
							-- 	TIPS({ type = 1  , str = game.getStrByKey("buy_rul_tips") })
							-- 	return
							-- end
							if drugIdTemp[1] ~= 0 then
								local MShopOp = require "src/layers/shop/ShopOp"
			                    MShopOp:buyProtoId( drugIdTemp[3] , drugIdTemp[1] , value )						
								if (drugIdTemp[3] == 0 and MRoleStruct:getAttr(PLAYER_INGOT) >= drugIdTemp[2]) or
									(drugIdTemp[3] == 1 and MRoleStruct:getAttr(PLAYER_BINDINGOT) >= drugIdTemp[2]) or
									(drugIdTemp[3] == 14 and MRoleStruct:getAttr(PLAYER_MONEY) >= drugIdTemp[2]) then
									isTouch = true											
									if box then removeFromParent(box) box = nil end
								end
							end
						end,
						
						onValueChanged = function(box, value)
							box.icon:setOverlay(value)
							box.TotalPrice:setValue( drugIdTemp[2] * value)
						end,
					})
					----------------------------------------
					local secondNode = cc.Node:create()
					secondNode:registerScriptHandler(function(event)
						if event == "enter" then
						elseif event == "exit" then
							if not isTouch then
								-- G_DRUG_CHECK[drugIdTemp[1]] = drugIdTemp[1]
								table.insert(G_DRUG_CHECK,drugIdTemp[1])
							end
						end
					end)
					box:addChild(secondNode)
					----------------------------------------
				end
				removeFunc()
			end
			local function createInfoBtn()
				local node = cc.Node:create()
			    --按钮
			    local button = createMenuItem(node, "res/mainui/recover.png" , cc.p(0, 0), function() showTip() end )
			    performWithNoticeAction(button)
			    return node
			end
			if #self.shouldShowDrug > 0 then
				removeFunc()
				local node = createInfoBtn()
				self:addChild(node)
				node:setLocalZOrder(100)
				node:setPosition( display.cx + 180, 240 )
				self.drug_node = node
			else
				removeFunc()
			end
		end
	end
end

function BaseMapScene:buyDrug1(drugId)
	local defaultSet = {}	
	local drugT = {}
	local MpropOp = require "src/config/propOp"
	local proId = MpropOp.getBuyDrugTab()

	local showTip = function()
		local MChoose = require("src/functional/ChooseQuantity")
		local Mprop = require( "src/layers/bag/prop" )
		for i = 1 ,#drugT do
			local drugIdTemp = drugT[i] or {0,0,0}
			local isTouch = false		
			-------------------------------------------------------------------------------
            local attrKind = nil
            if drugIdTemp[3] == 0 then
				-- yuanbao
                attrKind = PLAYER_INGOT
			elseif drugIdTemp[3] == 1 then
				-- bangding yuanbao
                attrKind = PLAYER_BINDINGOT
			elseif drugIdTemp[3] == 14 then
				-- jinbi
                attrKind = PLAYER_MONEY
			end
            local maxNum = 99
            if attrKind then
                local price = drugIdTemp[2]
                local realMaxNum = math.floor(MRoleStruct:getAttr(attrKind) / price)
                if realMaxNum == 0 then
                    realMaxNum = 1
                end
                if realMaxNum < maxNum then
                    maxNum = realMaxNum
                end
                --maxNum = 20
            end
            -------------------------------------------------------------------------------			
			local box = MChoose.new(
			{
				title = game.getStrByKey("buy_prop"),
				parent = getRunScene(),
				config = { sp = 1 , ep = maxNum, cur = 1  },
				builder = function(box, parent)
					local cSize = parent:getContentSize()
					
					box:buildPropName(MPackStruct:buildGirdFromProtoId(drugIdTemp[1]), drugIdTemp[3] ~= 0)
					
					-- 物品图标
					local icon = Mprop.new(
					{
						protoId = drugIdTemp[1],
						cb = "tips",
						isBind = drugIdTemp[3] ~= 0,
					})
					
					Mnode.addChild(
					{
						parent = parent,
						child = icon,
						pos = cc.p(70, 264),
					})
					if drugIdTemp[3] == 0 then
						createSprite(parent,"res/group/currency/3.png",cc.p(315,264))
					elseif drugIdTemp[3] == 1 then
						createSprite(parent,"res/group/currency/4.png",cc.p(315,264))
					elseif drugIdTemp[3] == 14 then
						createSprite(parent,"res/group/currency/1.png",cc.p(315,264))
					end

					box.icon = icon
					
					local nodes = {}
					
					if single then
						nodes[#nodes+1] = Mnode.createLabel(
						{
							src = game.getStrByKey("single_buy_limits") .. ": " .. item.mSingleBuyNums.."/" .. singleBuyLimits,
							color = MColor.lable_yellow,
							size = 20,
							outline = false,
						})
					end
					
					if whole then
						nodes[#nodes+1] = Mnode.createLabel(
						{
							src = game.getStrByKey("whole_buy_limits") .. ": " .. (wholeBuyLimits-item.mWholeRemaining) .. "/" .. wholeBuyLimits,
							color = MColor.lable_yellow,
							size = 20,
							outline = false,
						})
					end
					
					local TotalPrice = Mnode.createKVP(
					{
						k = Mnode.createLabel(
						{
							src = game.getStrByKey("buy_totle_price").." ",
							color = MColor.lable_yellow,
							size = 20,
							outline = false,
						}),
						
						v = {
							src = "",
							color = MColor.lable_yellow,
							size = 20,
						},
					})
					
					nodes[#nodes+1] = TotalPrice
					
					Mnode.addChild(
					{
						parent = parent,
						child = Mnode.combineNode(
						{
							nodes = nodes,
							ori = "|",
							align = "l",
							margins = 5,
						}),
						
						anchor = cc.p(0, 0.5),
						--pos = cc.p(153, 243),
						pos = cc.p(130, 264),
					})
					
					box.TotalPrice = TotalPrice
				end,
				
				handler = function(box, value)
					-- if maxNum < 1 then
					-- 	TIPS({ type = 1  , str = game.getStrByKey("buy_rul_tips") })
					-- 	return
					-- end
					if drugIdTemp[1] ~= 0 then
						local MShopOp = require "src/layers/shop/ShopOp"
	                    MShopOp:buyProtoId( drugIdTemp[3] , drugIdTemp[1] , value )						
						if (drugIdTemp[3] == 0 and MRoleStruct:getAttr(PLAYER_INGOT) >= drugIdTemp[2]) or
							(drugIdTemp[3] == 1 and MRoleStruct:getAttr(PLAYER_BINDINGOT) >= drugIdTemp[2]) or
							(drugIdTemp[3] == 14 and MRoleStruct:getAttr(PLAYER_MONEY) >= drugIdTemp[2]) then
							isTouch = true											
							if box then removeFromParent(box) box = nil end
						end
					end
				end,
				
				onValueChanged = function(box, value)
					box.icon:setOverlay(value)
					box.TotalPrice:setValue( drugIdTemp[2] * value)
				end,
			})
		end
	end
	local check = true			
	for i = 1 ,#proId do					
		if proId[i][1] == drugId then													
			table.insert(drugT,proId[i])
			check = false
			break
		end					
	end
	if check then
		TIPS({type = 1 ,str = game.getStrByKey("noProp")})
	else
		showTip()
	end
end


function BaseMapScene:resetHeadInfo(name,level)
	if name and self.name_label.setString then
		self.name_label:setString(name)
	end
	if level and self.level_label.setString then 
		self.level_label:setString(level)
	end
end

function BaseMapScene:createTouchHandler(node,downfun,upfunc,movefun)
	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    self.count = 1
    listenner:registerScriptHandler(function(touch, event)
    		self.count = self.count + 1
    		if downfun then
           		return downfun(touch)
           	else
           		return false
           	end
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(function(touch, event)
    	    if movefun then
   				movefun(touch)
           	end
        end,cc.Handler.EVENT_TOUCH_MOVED )
    listenner:registerScriptHandler(function(touch, event)
    	    if upfunc then
   				upfunc(touch)
           	end
        end,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, node)
    return listenner
end

function BaseMapScene:createChargeInfo()
	local sprite3 = TouchSprite:create("res/mainui/10.png")
	local size = sprite3:getContentSize()
	self:addChild(sprite3)
	sprite3:setPosition(display.width/2,g_scrSize.height)
	sprite3:setAnchorPoint(cc.p(0.5,1.0))
	sprite3:setScale(g_scrSize.width/960,1)
	createSprite(sprite3,"res/group/currency/1.png",cc.p(300,size.height/2)):setScale(0.66)
	createSprite(sprite3,"res/group/currency/2.png",cc.p(420,size.height/2)):setScale(0.66)
	createSprite(sprite3,"res/group/currency/3.png",cc.p(540,size.height/2)):setScale(0.66)
	createSprite(sprite3,"res/group/currency/4.png",cc.p(660,size.height/2)):setScale(0.66)
	
	local gold = createLabel(sprite3,"0",cc.p(320,size.height/2),cc.p(0,0.5),18,nil,20)
	local lock_gold = createLabel(sprite3,"0",cc.p(440,size.height/2),cc.p(0,0.5),18,nil,20)
	local ingot = createLabel(sprite3,"0",cc.p(560,size.height/2),cc.p(0,0.5),18,nil,2)
	local lock_ingot = createLabel(sprite3,"0",cc.p(680,size.height/2),cc.p(0,0.5),18,nil,20)

	local color = MColor.yellow
	gold:setColor(color)
	lock_ingot:setColor(color)
	lock_gold:setColor(color)
	ingot:setColor(color)
	local updateFunc = function()
		if G_ROLE_MAIN and G_ROLE_MAIN.currGold then
			ingot:setString(numToFatString(G_ROLE_MAIN.currIngot))
			lock_ingot:setString(numToFatString(G_ROLE_MAIN.currBindIngot))
			gold:setString(numToFatString(G_ROLE_MAIN.currGold))
			lock_gold:setString(numToFatString(G_ROLE_MAIN.currBindGold))
		end
	end
	local hander_node = cc.Node:create()
	local function eventCallback(eventType)
        if eventType == "enter" then
        	registMultiHandler(MONEY_GOLD_UPDATE,updateFunc)
        elseif eventType == "exit" then
      		unRegistMultiHandler(MONEY_GOLD_UPDATE,updateFunc)
        end
    end
    hander_node:registerScriptHandler(eventCallback)
    self:addChild(hander_node)
	--registMultiHandler(MONEY_GOLD_UPDATE,updateFunc)
    self.charge_node = sprite3
end

function BaseMapScene:createExtNode()
	local bloodNode = cc.Node:create()
	self:addChild(bloodNode, 20)
	self.bloodNode = bloodNode
    
    -- 防止 createTouchItem 0.15s setTouchEnable(false) 情况下，响应下面的按钮
    ---------------------------------------------------------------------------------
    local mbBgSpan = createScale9SpriteMenu(bloodNode, "res/common/scalable/4.png", cc.size(160, 190), cc.p(display.width/2,15), function()
            print("mbBgSpan");
        end);
    mbBgSpan:setActionEnable(false);
    mbBgSpan:setOpacity(0);
    ---------------------------------------------------------------------------------
    local mb_bg = createTouchItem(bloodNode, {"mainui/exp/73.png"},cc.p(display.width/2,15),function()
		if self.map_layer and (not self.map_layer.isMine) and not self.map_layer.isStory then
			self:setFullShortNode(not BaseMapScene.full_mode)
		end
	end)
	self.mb_bg = mb_bg
	G_TUTO_NODE:setTouchNode(mb_bg, TOUCH_MAIN_BLOOD)
	setNodeAttr(mb_bg,nil,cc.p(0.5,0.0),101,tag_mb_bg)
    self.arrow_zuo = createSprite(self.mainui_node, getSpriteFrame("mainui/exp/you.png"), cc.p(mb_bg:getPositionX() - mb_bg:getContentSize().width / 2 + 23, mb_bg:getPositionY() + mb_bg:getContentSize().height / 2 - 11))
    self.arrow_zuo:setLocalZOrder(101)
    self.arrow_you = createSprite(self.mainui_node, getSpriteFrame("mainui/exp/zuo.png"), cc.p(mb_bg:getPositionX() + mb_bg:getContentSize().width / 2 - 23, mb_bg:getPositionY() + mb_bg:getContentSize().height / 2 - 11))
	self.arrow_you:setLocalZOrder(101)
    --createSprite(mb_bg,"res/mainui/72.png",cc.p(mb_bg:getContentSize().width/2 , 8),cc.p(0.5,0.0),5)
	--local extBg = createSprite(self,"res/mainui/exp_bg.png",cc.p(g_scrSize.width/2,2),cc.p(0.5,0.0),1)
    ----------------------------------------------------------------------------------------------------------------------------
	local extBg = createSprite(bloodNode, getSpriteFrame("mainui/exp/exp_bg.png"),cc.p(g_scrSize.width/2,0),cc.p(0.5,0.0),1)
	extBg:setLocalZOrder(101)
	self.exp_bg = extBg
	local width = g_scrSize.width <=1050 and g_scrSize.width or 1050
	self.exp_bg:setScaleX(width/960)
	local createMB = function(filename,pos,effpos,effect_file,posx)
		local b_sprite = cc.Sprite:createWithSpriteFrame(getSpriteFrame(filename))
		if effect_file then
			local eff = Effects:create(false)
			eff:playActionData(effect_file, 19 , 4 , -1)
			eff:setPosition(effpos)
			mb_bg:addChild( eff)
			-- createSprite(blood, effect_file, cc.p(posx,0), cc.p(0, 0), -1)
			--eff:setScale(0.76)
		end
	    local blood = cc.ProgressTimer:create(b_sprite)
	   	blood:setPosition(pos)
	    blood:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	   -- blood:setAnchorPoint(cc.p(0,0))
	    blood:setBarChangeRate(cc.p(0, 1))
	   	blood:setMidpoint(cc.p(0.0,1.0))
	   	blood:setPercentage(100)
	   	mb_bg:addChild(blood)

		--blood:setScale(0.76)
	   	return blood
	end
   	self.r_pro_blood = createMB("mainui/exp/74.png",cc.p(92,46),cc.p(92,44),"hpeffect",33)--
   	self.r_pro_magic = createMB("mainui/exp/75.png",cc.p(92,46),cc.p(92,44),"mpeffect",35)--
	--createSprite(extBg,"res/mainui/76.png",cc.p(375,10),cc.p(0.5,0.0))
	--self.r_pro_blood = createMB("mpeffect",cc.p(125,32),cc.p(0.5,0))
	--self.r_pro_magic = createMB("mpeffect",cc.p(125,32),cc.p(0.5,0))

	-- 切面
			local eff = Effects:create(false)
			eff:playActionData("blood_s", 13 , 1.3 , -1)
			eff:setAnchorPoint(cc.p(1.0,0.5))
			eff:setPosition(cc.p(60,80))
			self.r_pro_blood :addChild( eff,1 )
			self.blood_s = eff
			local eff = Effects:create(false)
			eff:playActionData("magic_s", 13 , 1.3 , -1)
			eff:setAnchorPoint(cc.p(0.0,0.5))
			eff:setPosition(cc.p(65,80))
			self.r_pro_magic:addChild( eff,1 )
			self.magic_s = eff

	self.blood_label  = createLabel(mb_bg,"",cc.p(65,45),nil,12,false,nil,nil,MColor.white)
  	self.magic_label  = createLabel(mb_bg,"",cc.p(108,45),nil,12,false,nil,nil,MColor.white)
    local exp_process = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrame(getSpriteFrame("mainui/exp/exp_pr.png")))
   	--exp_process:setPosition(0, -10)
    exp_process:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    exp_process:setAnchorPoint(cc.p(0.0,0.0))
    exp_process:setBarChangeRate(cc.p(1, 0))
   	exp_process:setMidpoint(cc.p(0,1))
   	--exp_process:setPercentage(0)
   	extBg:addChild(exp_process)
   	exp_process:setPosition(cc.p(74 , 5.5))
   	self.exp_process = exp_process
   	
   	createSprite(extBg,getSpriteFrame("mainui/exp/exp_ex.png"),cc.p(extBg:getContentSize().width/2 , 0),cc.p(0.5,0.0),1)
   	local ext_labbg = createSprite(extBg,"res/common/56.png",cc.p(extBg:getContentSize().width/2+10, 9),cc.p(0.5,0.5),1)
   	ext_labbg:setScaleY(0.7)

    -- function createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
   	self.exp_label  = createLabel(self,"",cc.p(g_scrSize.width/2+5, 10),nil,12,false)--,nil,nil,MColor.yellow)
  	self.exp_label:setLocalZOrder(20)
   	local goToChatLayer = function(isHide)  
  --  		delayTime = os.time()
		-- if delayTime - delayTime1 > 1 then
		-- 	delayTime1 = delayTime  
            self.chatLayer = self.base_node:getChildByTag(305)    
	        if self.chatLayer == nil or tolua.cast(self.chatLayer, "cc.Node") == nil then
                local chatLayer = require("src/layers/chat/Chat").new()
		   		self.chatLayer = chatLayer
		   		self.base_node:addChild(self.chatLayer)
		   		self.chatLayer:setLocalZOrder(200)
		   		self.chatLayer:setTag(305)
		   		self.chatLayer:setAnchorPoint(cc.p(0, 0))
		   		self.chatLayer:setPosition(cc.p(0, 0))
			else
	            if G_CHAT_INFO.unReadPrivateRecord ~= nil and G_CHAT_INFO.unReadPrivateRecord > 0 then
	                self.chatLayer:selectTab(0)
	            end
				self.chatLayer:show()
			end
		--end

		if isHide == true then 
			if self.chatLayer then 
				self.chatLayer:hide()
			end
		end
   	end
   	goToChatLayer(true)
    ----------------------------------------------------------------------------------------------------------------------------
   	--self.chatStartBtn = createTouchItem(self.mainui_node,{"mainui/anotherbtns/chat.png"},cc.p(25,88),goToChatLayer,true)
    --self.chatStartBtn:setVisible(false)
    --self.ChatVoiceSimple = require("src/layers/chat/ChatVoiceSimple").new(self.mainui_node, cc.p(0,20))
    self.factionRealVoice = require("src/layers/chat/ChatFactionRealLayer").new(self.mainui_node, cc.p(0,104))
    self.ChatAutoPlayLayer = require("src/layers/chat/ChatAutoPlayLayer").new(self.mainui_node, cc.p(0,0))    
   	
    --聊天框中输入 #msglog 打开协议记录
    --local netSim = require("src/net/NetSimulation")
    --if netSim.OpenBtn then
   	--	createTouchItem(self.mainui_node, {"mainui/anotherbtns/chat.png"}, cc.p(25,88 - 60), function() __GotoTarget({ru = "a171"} ) end)
   	--end

	-- 拼战
	local time_to_string = function(time_value)
		if time_value == nil or time_value <= 0 then
			return "00:00"
		end
		
		local minute = math.floor(time_value/60)
		local sec = time_value%60
		return (minute < 10 and ("0" .. minute) or minute) .. ":" .. (sec < 10 and ("0" .. sec) or sec)
	end
	
   	local vsFunc = function(targetID, node)
		local Mversus_net = require "src/layers/random_versus/versus_net"
   		local result = Mversus_net:on_vs_ing()
		if not result then node:setVisible(false) end
   	end
	
	local vs_btn = createMenuItem(self,"res/mainui/vs.png",cc.p(display.cx + 297, 330),vsFunc,12)
	local vs_btn_size = vs_btn:getContentSize()
	
	local CountDown = Mnode.createLabel(
	{
		src = "00:00",
		size = 19,
		color = MColor.white,
	})
	CountDown:enableOutline(cc.c4b(0,0,0,255),1)
	local onVsEventArrive = function(Mversus_net, event, n1, n2)
		if event == "vs_begin" then
			CountDown:setString(time_to_string(n1.time_remaining))
			vs_btn:setVisible(true)
		elseif event == "vs_countdown" then
			CountDown:setString(time_to_string(n1.time_remaining))
			vs_btn:setVisible(true)
		elseif event == "vs_time_over" then
			vs_btn:setVisible(false)
		elseif event == "vs_end" then
			vs_btn:setVisible(false)
			Mversus_net:on_vs_end(n1)
		end
	end
	vs_btn:setVisible(false)
	-- 注意子节点先于父节点销毁
	CountDown:registerScriptHandler(function(event)
		local Mversus_net = require "src/layers/random_versus/versus_net" -- 拼战
		if event == "enter" then
			if self.map_layer and self.map_layer.isSkyArena then
				vs_btn:setVisible(false)
			else
				local Mversus_net = require "src/layers/random_versus/versus_net"
				local versus_info = Mversus_net:get_versus_info()
				vs_btn:setVisible(versus_info ~= nil and versus_info.status ~= "vs_end" and versus_info.status ~= "vs_time_over")
				if versus_info ~= nil then
					if versus_info.time_remaining ~= nil then
						CountDown:setString(time_to_string(versus_info.time_remaining))
					end
					
					performWithDelay(self, function()
						if versus_info.status == "vs_end" then
							Mversus_net:on_vs_end(versus_info)
						end
					end, 2)
				end
		
				Mversus_net:register(onVsEventArrive)
			end
		elseif event == "exit" then
			Mversus_net:unregister(onVsEventArrive)
		end
	end)
	
	Mnode.addChild(
	{
		parent = vs_btn,
		child = CountDown,
		pos = cc.p(vs_btn_size.width/2, 0 ),
	})
	
	-- 交易
	local MMenuButton = require "src/component/button/MenuButton"
	local MtradeOp = require "src/layers/trade/tradeOp"
	local trade_btn = MMenuButton.new(
	{
		src = "res/mainui/jy.png",
		cb = function()
			local secondaryPass = require("src/layers/setting/SecondaryPassword")
			if not secondaryPass.isSecPassChecked() then
				secondaryPass.inputPassword()
				return
			end
		
			local req = MtradeOp:getTradeReq()
			if req == nil then
				TIPS({ type = 1  , str = "交易请求已失效" })
				return
			end
			
			local MConfirmBox = require "src/functional/ConfirmBox"
			local box = MConfirmBox.new(
			{
				sure = game.getStrByKey("accept"),
				cancel = game.getStrByKey("refuse"),
				handler = function(box)
					local req = MtradeOp:getTradeReq()
					if req == nil then 
						TIPS({ type = 1  , str = "交易请求已失效" })
					else
						MtradeOp:resTrade(nil, true)
					end
					
					if box then removeFromParent(box) box = nil end
				end,
				
				closer = function(box)
					MtradeOp:resTrade(nil, false)
					if box then removeFromParent(box) box = nil end
				end,
				
				builder = function(box)
					local boxSize = box:getContentSize()
					local Mcheckbox = require "src/component/checkbox/view"
					local checkbox = Mcheckbox.new(
					{
						label = {
							src = game.getStrByKey("auto_shield_trade"),
							size = 20,
							color = MColor.gray,
						},
						
						margin = 0,
					})
					
					checkbox:registerScriptHandler(function(event)
						if event == "enter" then
						elseif event == "exit" then
							if checkbox:value() then
								MtradeOp:block(true)
							end
						end
					end)
					
					-- 自动屏蔽交易请求
					Mnode.addChild(
					{
						parent = box,
						child = checkbox,
						pos = cc.p(boxSize.width/2, 116),
					})
					
					-- 角色名
					Mnode.createLabel(
					{
						parent = box,
						src = req.mRoleName,
						size = 20,
						color = MColor.lable_yellow,
						pos = cc.p(112, 210),
					})
					
					-- 角色等级
					Mnode.createLabel(
					{
						parent = box,
						src = game.getStrByKey("level") .. "：" .. req.mLevel,
						size = 20,
						color = MColor.lable_yellow,
						pos = cc.p(304, 210),
					})
					
					-- 请求交易
					Mnode.createLabel(
					{
						parent = box,
						src = game.getStrByKey("trade_tips"),
						size = 20,
						pos = cc.p(boxSize.width/2, 170),
						color = MColor.lable_yellow,
					})
				end,
			})
		end,
		
		zOrder = 12,
		hide = true,
		effect = "none",
	})
	local trade_btn_size = trade_btn:getContentSize()
	
	--特效(看看可不可以优化)
	performWithNoticeAction(trade_btn)
	
	local openTradingView = function(record)
		if record == nil then return end
		
		local MtradeLayer = require "src/layers/trade/tradeLayer"
		Manimation:transit(
		{
			node = MtradeLayer.new(
			{
				roleName = record.mRoleName,
				level = record.mLevel,
			}),
			
			sp = g_scrCenter,
			--trend = "-",
			curve = "-",
			zOrder = 200,
			maskTouch = true,
		})
	end
	
	local onTradeEventArrive = function(observable, event, data)
		if event == "TradeReqArrive" then
			trade_btn:setVisible(true)
		elseif event == "TradeReqVoid" then
			trade_btn:setVisible(false)
		elseif event == "TradeEstablish" then
			openTradingView(data.record)
		end
	end
	
	trade_btn:registerScriptHandler(function(event)
		if event == "enter" then
			trade_btn:setVisible(MtradeOp:isTradeReqArrive())
			MtradeOp:register(onTradeEventArrive)
		elseif event == "exit" then
			MtradeOp:unregister(onTradeEventArrive)
		end
	end)
	
	Mnode.addChild(
	{
		parent = self,
		child = trade_btn,
		pos = cc.p(display.cx + 180, 150),
	})
end

function BaseMapScene:createSmallMapNode(mapid,pos)

	local map_id = mapid or self.mapId
	local mapCfg = getConfigItemByKey("MapInfo","q_map_id",map_id)
	local map_name = mapCfg.q_map_name
	self.map_name_str = map_name

	self.all_safe = mapCfg.q_all_safe
	local area_str = game.getStrByKey("safe_area")
	local area_color = MColor.green
	if self.all_safe then
		if self.map_layer and self.map_layer.isfb then
			area_str = game.getStrByKey("fuben")
		end
	elseif self.map_layer and (not self.map_layer:isInSafeArea(pos)) then
        if self.map_layer and self.map_layer.isfb then
            area_str = game.getStrByKey("fuben")
        else
        	if mapCfg.q_map_pk == 0 then
        		area_str = game.getStrByKey("fire_area")
        	else
		    	area_str = game.getStrByKey("pk_area")
		   	end
		    area_color = cc.c3b(255, 42, 27)
        end
	end

	--通天塔副本第几层
	if userInfo and userInfo.lastFbType == 3 and mapid == 5100 then
		local fbId = userInfo.lastFb
		local itemDate = getConfigItemByKey("FBTower", "q_id", fbId)
		if itemDate and itemDate.q_copyLayer then
			map_name = map_name .. string.format(game.getStrByKey("fb_layer"), tonumber(itemDate.q_copyLayer))
		end
	end

	if self.smallMap then
		if self.mapName then 
			self.mapName:setString(map_name)
		end
		if self.safe_label then
			self.safe_label:setString(area_str)
			self.safe_label:setColor(area_color)
		end
		return
	end
	local goToMap = function()
		local layer = require("src/layers/map/MapAndTransfer").new()
		self.base_node:addChild(layer, 200 ,121)
		--[[
		Manimation:transit(
		{
			ref = self.base_node,
			node = layer,
			curve = "-",
			sp = cc.p(g_scrSize.width-20,g_scrSize.height-10),
			zOrder = 200,
			tag = 121,
			swallow = true,
		})	
		]]
	end
	local bg = createTouchItem(self.topRightNode,{"mainui/anotherbtns/map.png"},cc.p(g_scrSize.width-1,g_scrSize.height-1),goToMap)
	bg:setAnchorPoint(cc.p(1.0,1.0))
	bg:setLocalZOrder(7)
	local map_label = createLabel(bg,map_name,cc.p(95,33),cc.p(0.5,0.5),18,true,100)
	map_label:setColor(MColor.lable_yellow)
	self.SysInfo = require( "src/layers/setting/SysInfo" ).new()
	self.topRightNode:addChild(self.SysInfo,7)
	self.smallMap = bg
	self.mapName = map_label
	self.role_pos_label = createLabel(bg,"("..pos.x..","..pos.y..")",cc.p(87,15),cc.p(0.0, 0.5),15,false,nil,nil,MColor.white)
	local safe_label = createLabel(bg,area_str,cc.p(87,15),cc.p(1.0,0.5),15)
	safe_label:setColor(area_color)
	self.safe_label = safe_label

end

function BaseMapScene:addBuffNode()
	local node = cc.Node:create()
	setNodeAttr(node, cc.p(0, 0), cc.p(0, 0))
	self.topLeftNode:addChild(node,2)
	self.BuffNode = node
	local buffFunc = function()
		if G_ROLE_MAIN and g_buffs and g_buffs[G_ROLE_MAIN.obj_id] then
			self.buffLayer = require("src/layers/buff/BuffLayer").new(g_buffs[G_ROLE_MAIN.obj_id], self)
		end
	end

	local buff_btn = createMenuItem( node , "res/mainui/anotherbtns/buff.png" , cc.p( 298 , g_scrSize.height - 46 ) , buffFunc ,2)
	G_TUTO_NODE:setTouchNode(buff_btn, TOUCH_MAIN_BUFF)
	self.buff_btn = buff_btn
	if (not g_buffs)
        or
        (
            G_ROLE_MAIN 
            and (
                    (not g_buffs[G_ROLE_MAIN.obj_id])
                    or (tablenums(g_buffs[G_ROLE_MAIN.obj_id]) == 0)
                    or (tablenums(g_buffs[G_ROLE_MAIN.obj_id]) == 1 and g_buffs[G_ROLE_MAIN.obj_id][403] ~= nil)
                )
         ) then
		self.buff_btn:setVisible(false)
	end
	self:addTaskBtn()
end

function BaseMapScene:changeTeamNode(toTeam)
	if ((self.taskBaseNode and self.selectTemp and self.selectTemp == 2) or toTeam)  then --and not self.hideState
		self.selectTemp = 2
		if __TASK then 
			-- if tolua.cast(__TASK,"cc.Node") then removeFromParent(__TASK) end
			-- __TASK = nil 
			__TASK:setVisible(false)
		end
		if self.teamNode then 
			if tolua.cast(self.teamNode,"cc.Node") then removeFromParent(self.teamNode) end
			self.teamNode = nil 
		end
		self.teamNode = require( "src/layers/teamup/teamNode" ).new( { parent = self.taskBaseNode ,teamMemberNum = (G_TEAM_INFO and G_TEAM_INFO.has_team and G_TEAM_INFO.memCnt) or 0 } )						
		if self.duiwuBtn and self.taskBtn then
			self.duiwuBtn:setSpriteFrame("mainui/anotherbtns/btn_sel.png")
			self.taskBtn:setSpriteFrame("mainui/anotherbtns/btn.png")
			self.touchTime = 1
			self.touchTime1 = 2
		end
		self.teamNode:setVisible(not BaseMapScene.hide_task)
	end
	if self.teamLab and self.teamLab1 then
		local str = game.getStrByKey("make_team")
		if G_TEAM_INFO.has_team and G_TEAM_INFO.memCnt > 0 then
			local n = G_TEAM_INFO.memCnt > 10 and 10 or G_TEAM_INFO.memCnt
			str = game.getStrByKey("make_team").."("..tostring(n)..")"
		end
		self.teamLab:setString(str)
		self.teamLab1:setString(str)
	end
end

function BaseMapScene:addTaskBtn( )
    local rolelevel = MRoleStruct:getAttr(ROLE_LEVEL) or 0
	if G_ROLE_MAIN and rolelevel >= 0 then
		-- local touchTime,touchTime1 = 2,1
		self.touchTime = 2
		self.touchTime1 = 1
		self.selectTemp = 1
		local taskBtnNode = cc.Node:create()
		setNodeAttr(taskBtnNode, cc.p(0, 45), cc.p(0, 0))
		self.taskBaseNode:addChild(taskBtnNode , 10 )
		self.task_btn_node = taskBtnNode



		local height = display.cy + 145

		self.hide_task_btn = nil
		local task_bg = nil
		local taskBtn = nil
		local duiwuBtn = nil
		local isTeam =  nil
		local isTask =  nil
		local task_bg2 = nil

		local function bgSpHandler( ) 
			isTeam =  G_CONTROL:isFuncOn( GAME_SWITCH_ID_TEAM )
			isTask =  G_CONTROL:isFuncOn( GAME_SWITCH_ID_TASK ) and not self.isOnlyShowTeamNode


			self.hide_task_btn:setVisible( true )
			task_bg:setVisible( true )
			
			duiwuBtn:setVisible( isTeam )
			taskBtn:setVisible( isTask )
			task_bg2:setVisible( not BaseMapScene.hide_task )

			if BaseMapScene.hide_task then
				if isTeam == false and isTask == false then
					task_bg:setVisible( false )
					self.hide_task_btn:setVisible( false )	
				end

				return
			end

			if isTeam and isTask then
				setNodeAttr( duiwuBtn , cc.p(151 , height) , cc.p( 0.5 , 0.5 ) )
				setNodeAttr( taskBtn , cc.p(65 , height) , cc.p( 0.5 , 0.5 ) )

				setNodeAttr( task_bg , cc.p(0 , height) , cc.p( 0.0 , 0.5 ) )
				setNodeAttr( self.hide_task_btn , cc.p(  228 , height ) , cc.p( 0.5 , 0.5 ) )
			else
				if isTeam or isTask then
					if isTeam then setNodeAttr( duiwuBtn , cc.p( 41 , height) , cc.p( 0.5 , 0.5 ) ) end
					if isTask then setNodeAttr( taskBtn , cc.p( 41 , height) , cc.p( 0.5 , 0.5 ) ) end
					
					setNodeAttr( task_bg , cc.p( -110 , height) , cc.p( 0.0 , 0.5 ) )
					setNodeAttr( self.hide_task_btn , cc.p(  228 - 110 , height ) , cc.p( 0.5 , 0.5 ) )
				else
					self.hide_task_btn:setVisible( false )
					task_bg:setVisible( false )
				end
			end
		end
		
		task_bg = createSprite(taskBtnNode,getSpriteFrame("mainui/task/task_team_bg.png"),cc.p( G_CONTROL:isFuncOn( GAME_SWITCH_ID_TASK ) and 0 or -108 , height),cc.p(0.0,0.5))
		self.taskBgChangeFun = function( _type )
            local oritype = _type;
            -- 调整成两个永远显示
            if _type == 1 then
                _type = 2;
            end

			if __TASK and __TASK.scrollView1 then
				removeFromParent( task_bg2 )
                -- removeFromParent(taskSplitSpr);
				if _type == 1 then
					__TASK.scrollView1:setViewSize( cc.size( 250 , 106/2 ) )
					__TASK.scrollView1:setPosition( cc.p( 0 , display.cy  + 59 + 106/2 ) )
					__TASK.scrollView1:setTouchEnabled( false )
					__TASK.scrollView1:setContentOffset( cc.p( 0 ,   0 ) )
					task_bg2 = createScale9Sprite( taskBtnNode ,  "res/layers/mission/task_info_bg2.png" , cc.p( 0 , height - 27 ), cc.size(246,105/2), cc.p( 0 , 1 ) )
				else
					__TASK.scrollView1:setViewSize( cc.size( 250 , 106 ) )
					__TASK.scrollView1:setPosition( cc.p( 0 , display.cy + 59  ) )
					__TASK.scrollView1:setTouchEnabled( true )
					task_bg2 = createScale9Sprite( taskBtnNode ,  "res/layers/mission/task_info_bg2.png" , cc.p( 0 , height - 27 ), cc.size(246,105), cc.p( 0 , 1 ) )
					createSprite( task_bg2 ,  "res/common/slider1_bg.png" , cc.p( task_bg2:getContentSize().width - 2 , task_bg2:getContentSize().height/2 ), cc.p( 1 , 0.5 ) )
				end
				task_bg2:setVisible( not BaseMapScene.hide_task )

                -- local taskSplitSpr = createSprite(task_bg2, "res/common/split-2.png", cc.p(6, 51), cc.p(0, 0));
                -- taskSplitSpr:setVisible(oritype==1);
			end
		end
		
		if __TASK and __TASK.gatherData then self.taskBgChangeFun( tablenums(__TASK.gatherData) ) end

		taskBtn = createTouchItem( taskBtnNode, {"mainui/anotherbtns/btn.png","mainui/anotherbtns/btn_sel.png"}, cc.p(65, height-2),function() 
        		if __TASK and __TASK.gatherData then self.taskBgChangeFun( tablenums(__TASK.gatherData) ) end			
				self.selectTemp = 1
				if self.touchTime == 1 then
					if self.teamNode then 
						if tolua.cast(self.teamNode,"cc.Node") then removeFromParent(self.teamNode) end
						self.teamNode = nil 
					end
					-- if __TASK then 
					-- 	if tolua.cast(__TASK,"cc.Node") then removeFromParent(__TASK) end
					-- 	__TASK = nil 
					-- end
					if not __TASK then
						__TASK = require( "src/layers/mission/MissionLayer" ).new( { parent = self.taskBaseNode } )
					else						
						__TASK:setVisible(true)
						__TASK:hideIcon()
					end
					duiwuBtn:setSpriteFrame("mainui/anotherbtns/btn.png")
					taskBtn:setSpriteFrame("mainui/anotherbtns/btn_sel.png")
					self.touchTime = 2
				elseif self.touchTime == 2 then
					if __TASK then __TASK:popupLayout() end 
				end
				self.touchTime1 = 1
			end  )
		taskBtn:setSpriteFrame("mainui/anotherbtns/btn_sel.png")
		self.taskBtn = taskBtn		
		local str = game.getStrByKey("task")
		if __TASK and __TASK.gatherData  then
			str = game.getStrByKey("task") .. "(" .. tablenums( __TASK.gatherData ) .. ")" 
		end

		self.taskLab = createLabel(taskBtn, str  ,cc.p(47,19),nil,22,true,nil,nil,MColor.black)
		self.taskLab:setOpacity(200)
		self.taskLab1 = createLabel(taskBtn, str ,cc.p(45,21),nil,22,true,nil,nil,MColor.lable_yellow)
		--taskBtn:setSelectAction(cc.DelayTime:create(0))
		local pos = cc.p(getCenterPos(taskBtn).x - 5,getCenterPos(taskBtn).y -2)
		--createSprite(taskBtn, "res/mainui/task.png", pos, cc.p(0.5, 0.5))
		G_NFTRIGGER_NODE:addData(taskBtn, NF_TASK_DAILY)
		G_TUTO_NODE:setTouchNode(taskBtn, TOUCH_MAIN_TASK)
			
		taskBtn:setVisible( G_CONTROL:isFuncOn( GAME_SWITCH_ID_TASK ) )
		

		local duiWuFunc = function()
            self.taskBgChangeFun( 2 )
			self.selectTemp = 2
			local teamLv = getConfigItemByKey("NewFunctionCfg","q_ID",NF_TEAM,"q_level")
            local rolelevel = MRoleStruct:getAttr(ROLE_LEVEL) or 0
			if G_ROLE_MAIN and rolelevel < teamLv then
				TIPS( { type = 1 , str = game.getStrByKey("team_limmite") } )
				return
			end			
			if self.touchTime1 == 1 then
				self:changeTeamNode()
				self.touchTime1 = 2
				self.duiwuBtn:setSpriteFrame("mainui/anotherbtns/btn_sel.png")
				self.taskBtn:setSpriteFrame("mainui/anotherbtns/btn.png")				
			elseif self.touchTime1 == 2 then
				__GotoTarget({ ru = "a29",index = 1})
			end
			self.touchTime = 1
		end
		
		
		duiwuBtn = createTouchItem(taskBtnNode, {"mainui/anotherbtns/btn.png","mainui/anotherbtns/btn_sel.png"}, cc.p( G_CONTROL:isFuncOn( GAME_SWITCH_ID_TASK ) and 151 or ( 151 - 108 ) , height-2), duiWuFunc)
		duiwuBtn:setSpriteFrame("mainui/anotherbtns/btn.png")
		self.duiwuBtn = duiwuBtn
		self.teamLab1 = createLabel(duiwuBtn,game.getStrByKey("make_team"),cc.p(47,19),nil,22,true,nil,nil,MColor.black)
		self.teamLab1:setOpacity(200)
		self.teamLab = createLabel(duiwuBtn,game.getStrByKey("make_team"),cc.p(45,21),nil,22,true,nil,nil,MColor.lable_yellow)
		self.teamRedDot = createSprite(duiwuBtn,"res/component/flag/red.png",cc.p(80,28))
		if not G_TEAM_APPLYRED[1] then 
			self.teamRedDot:setVisible(false)
		end
		self:changeTeamNode()
		G_TUTO_NODE:setTouchNode(duiwuBtn, TOUCH_MAIN_TEAM)
		G_NFTRIGGER_NODE:addData(duiwuBtn, NF_TEAM)

		duiwuBtn:setVisible( G_CONTROL:isFuncOn( GAME_SWITCH_ID_TEAM ) )
		


		local hide_imgs = {"res/mainui/anotherbtns/shrink.png","res/mainui/anotherbtns/spread.png"}
		local hideFunc = function()
			--local img_index = 1
			BaseMapScene.hide_task = not BaseMapScene.hide_task
			bgSpHandler()
			if self.selectTemp == 1 then
				if __TASK then 
					--if BaseMapScene.hide_task then img_index = 2 end
					--self.hide_task_btn:setImages(hide_imgs[img_index])
					if G_CONTROL:isFuncOn( GAME_SWITCH_ID_TASK ) then
						__TASK:hideIcon(BaseMapScene.hide_task )
					end
					self:hideTaskBtn()
				end	 
				-- self:hideTaskBtn()
			elseif self.selectTemp ==2 then
				if self.teamNode then
					self.teamNode:setVisible(not BaseMapScene.hide_task)
					self.teamNode.mainFlag:setVisible(not BaseMapScene.hide_task)
					self:hideTaskBtn()
				end
			end
		end	
		self.hideFunc = hideFunc
		local img_index = 1
		if BaseMapScene.hide_task then img_index = 2 end
		self.hide_task_btn = createTouchItem(taskBtnNode,  {"mainui/anotherbtns/shrink.png"}, cc.p(228, height), hideFunc, 2)
		self.hide_task_btn_ex = createSprite(self.hide_task_btn,getSpriteFrame("mainui/anotherbtns/spread.png"),cc.p(0, 0),cc.p(0.0,0.0))
		self.hide_task_btn_ex:setOpacity(0)
		bgSpHandler()
		local controlDelayRegFun = function()
			G_CONTROL:regCallback( GAME_SWITCH_ID_TASK ,function( _isShow )  bgSpHandler()  if not BaseMapScene.hide_task then if __TASK then __TASK:hideIcon( not _isShow ) end end end )
			G_CONTROL:regCallback( GAME_SWITCH_ID_TEAM ,function( _isShow ) bgSpHandler() end )
		end
		performWithDelay( self , controlDelayRegFun , 1 )

		self:hideTaskBtn(self.isHide_icon and not self:checkShaWarState(), true)
		self.task_btn_node:setVisible(not self.isHide_icon or self:checkShaWarState())
		if self.teamNode then
			self.teamNode:setVisible(not BaseMapScene.hide_task and (not self.isHide_icon or self:checkShaWarState()))
		end

		if self:checkShaWarState() then
			duiWuFunc()
		end

		if self.isOnlyShowTeamNode then
			self.task_btn_node:setVisible(true)
			self:hideTaskBtn(false, true)
			self.selectTemp = 2
			self:changeTeamNode()
			self.teamNode:setVisible(not BaseMapScene.hide_task)
			self.teamNode.mainFlag:setVisible(not BaseMapScene.hide_task)
		end
	end	
end

function BaseMapScene:refreshTeamRedDot(how)
	if self.teamRedDot then
		self.teamRedDot:setVisible(how)
	end
end

function BaseMapScene:hideTaskBtn( flg, noAct, forces)
	local hideState = BaseMapScene.hide_task or flg
	if forces == true or forces == false then
		hideState = forces
	end
	--self.hideState = hideState
	if not self.task_btn_node then return end
	if not self.task_btn_node:isVisible() then return end

	local isTeam =  G_CONTROL:isFuncOn( GAME_SWITCH_ID_TEAM )
	local isTask =  G_CONTROL:isFuncOn( GAME_SWITCH_ID_TASK ) and not self.isOnlyShowTeamNode

	if hideState then
		if self.hide_task_btn then self.hide_task_btn:setOpacity(0) end
		if self.hide_task_btn_ex then self.hide_task_btn_ex:setOpacity(255) end
	else
		if self.hide_task_btn then self.hide_task_btn:setOpacity(255) end
		if self.hide_task_btn_ex then self.hide_task_btn_ex:setOpacity(0) end
	end

	self.task_btn_node:stopAllActions()
    local actions = {}
    if not noAct then
	    if hideState then
			actions[#actions+1] = cc.MoveTo:create(0.08, cc.p( ( isTeam and isTask ) and -200 or -90, 45))
	    else 
			actions[#actions+1] = cc.MoveTo:create(0.08, cc.p( 5, 45) )
	    end
	    self.task_btn_node:runAction(cc.Sequence:create(actions))
	else
		if hideState then
			self.task_btn_node:setPositionX(-200)
		else
			self.task_btn_node:setPositionX(5)
		end
	end
end

function BaseMapScene:CheckTeamInvite()
	if G_TEAM_INVITE and #G_TEAM_INVITE > 0 then
		local nowTime = os.time()
		local i = 1 
	    while G_TEAM_INVITE[i] do-- G_TEAM_INVITE[i].time and (nowTime - G_TEAM_INVITE[i].time)>120 do 
	        if G_TEAM_INVITE[i].time then
	        	if (nowTime - G_TEAM_INVITE[i].time)>=59 then 
		            table.remove(G_TEAM_INVITE,i)
		            self:ShowTeamInvite(1)
		        else
		        	break
		        end	            
	        else 
	            i = i+1 
	        end
	    end 
	end
end

function BaseMapScene:ShowTeamInvite(how)
		local removeFunc = function()
			if self.teamInvite then
				removeFromParent(self.teamBtnNum)
				self.teamBtnNum = nil
				removeFromParent(self.teamInvite) 
				self.teamInvite = nil
			end
		end		
		if how and how == 1 then
			local showTip = function()
				if G_TEAM_INVITE[1] and G_TEAM_INVITE[1].nickName then
					local sourceId = G_TEAM_INVITE[1].sourceId
					local teamId = G_TEAM_INVITE[1].teamId
					local inviteCall = function(num)
						local status = false
						if num == 1 then
							if G_TEAM_INVITE[1] and G_TEAM_INVITE[1].teamId then
								self.inviteTeamId = G_TEAM_INVITE[1].teamId							
								status = true
								-- if #G_TEAM_INVITE <= 1 then
								-- 	G_TEAM_INVITE = {}
								-- 	removeFunc()
								-- else
								-- 	table.remove(G_TEAM_INVITE,1)
								-- 	if self.teamBtnNum then
								-- 		self.teamBtnNum:setString(tostring(#G_TEAM_INVITE))
								-- 	end
								-- end
							end
						else
							self.inviteTeamId = 0
							-- if #G_TEAM_INVITE <= 1 then
							-- 	G_TEAM_INVITE = {}
							-- 	removeFunc()
							-- else
							-- 	table.remove(G_TEAM_INVITE,1)
							-- 	if self.teamBtnNum then
							-- 		self.teamBtnNum:setString(tostring(#G_TEAM_INVITE))
							-- 	end
							-- end
						end
						if #G_TEAM_INVITE <= 1 then
							G_TEAM_INVITE = {}
							removeFunc()
						else
							table.remove(G_TEAM_INVITE,1)
							if self.teamBtnNum then
								self.teamBtnNum:setString(tostring(#G_TEAM_INVITE))
							end
						end
						--print(sourceId, userInfo.currRoleStaticId, teamId, status,"sourceId, userInfo.currRoleStaticId, teamId, status")
						-- g_msgHandlerInst:sendNetDataByFmtExEx(TEAM_CS_ANSWER_INVITE,"iiib",sourceId, userInfo.currRoleStaticId, teamId, status)
						g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_ANSWER_INVITE, "TeamAnswerInviteProtocol", {["tRoleId"] = sourceId, ["teamId"] = teamId, ["bAnswer"] = status})
					end				
					MessageBoxYesNo(nil,string.format(game.getStrByKey("team_tip3"),G_TEAM_INVITE[1].nickName),function() inviteCall(1) end,function() inviteCall(2) end)
				end					
			end		
			local function createInfoBtn(num)
				local node = cc.Node:create()
			    --按钮
			    local button = createMenuItem(node, "res/mainui/team.png" , cc.p(0, 0), function() showTip() end )
			    local spr = createSprite(button,"res/component/flag/red.png",cc.p(65,50))
			    self.teamBtnNum = createLabel(spr,num, getCenterPos(spr, -2, 3),nil,18,true,nil,nil,MColor.white)
			    performWithNoticeAction(button)
			    return node
			end
			if G_TEAM_INVITE and #G_TEAM_INVITE > 0 then
				removeFunc()
				local node = createInfoBtn(#G_TEAM_INVITE)
				self:addChild(node)
				node:setLocalZOrder(100)
				node:setPosition( display.cx + 180, 150 )
				self.teamInvite = node
			else
				removeFunc()
			end
		elseif how and how == 2 then
			if self.inviteTeamId and self.inviteTeamId ~= 0 and G_TEAM_INFO.teamID and G_TEAM_INFO.teamID ~= 0 and self.inviteTeamId == G_TEAM_INFO.teamID then
				G_TEAM_INVITE = {}
				removeFunc()
				self.inviteTeamId = 0
			end
		elseif how and how == 3 then
			-- if #G_TEAM_INVITE <= 1 then
			-- 	G_TEAM_INVITE = {}
			-- 	removeFunc()
			-- else
			-- 	table.remove(G_TEAM_INVITE,1)
			-- 	if self.teamBtnNum then
			-- 		self.teamBtnNum:setString(tostring(#G_TEAM_INVITE))
			-- 	end
			-- end
			self.inviteTeamId = 0
		end
end

function BaseMapScene:addLineNode(line_num)
	local line_num = line_num or MRoleStruct:getAttr(PLAYER_LINE)
	if line_num then
		if self.line_menu then
			removeFromParent(self.line_menu)
			self.line_menu = nil
		end

		local total_qu = math.floor(line_num/10000)
		if total_qu >= 1 and self.mapId and self.mapId == 1100 then
			local map_strs = {"落霞岛","夕霞岛","桃花岛"}
			if self.mapName and map_strs[total_qu] then 
				self.mapName:setString(map_strs[total_qu])
			end
		end
		line_num = line_num - total_qu*10000
		local total_line = math.floor(line_num/100)
		local curr_line = line_num - total_line*100
		if total_line >= 1 and self.map_layer and (not self.map_layer:isHideMode()) then
			local ChangeLine = function()
				require("src/layers/buff/ChangeLineLayer").new()
			end
            
			self.line_menu = createMenuItem( self.BuffNode , "res/mainui/anotherbtns/line.png" , cc.p( 216 , g_scrSize.height - 82) , ChangeLine ,2)
            -- function createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
			createLabel(self.line_menu,""..curr_line.." "..game.getStrByKey("line"),cc.p(60,16),nil,20,true, nil, nil, cc.c3b(201, 195, 171))
		end
	end
end

function BaseMapScene:setFullShortNode(full_mode, force)
	local action1 = cc.Hide:create()
	local action2 = cc.Show:create()
	local skill_posx ,muti = g_scrSize.width,1
	-- if getGameSetById(GAME_SET_ID_RIGHT_HAND) ~= 1 then
	-- 	skill_posx,muti = 0,-1
	-- end
	
	if full_mode and self.map_layer and self.map_layer.isMine then
		return
	end
	--公平竞技场不允许切换
	if full_mode and self.map_layer and self.map_layer.isSkyArena then
		return
	end
    if full_mode then
        self.arrow_zuo:setSpriteFrame("mainui/exp/you.png")
        self.arrow_you:setSpriteFrame("mainui/exp/zuo.png")
    else
        self.arrow_zuo:setSpriteFrame("mainui/exp/zuo.png")
        self.arrow_you:setSpriteFrame("mainui/exp/you.png")
    end
    if force and self.bottom_node then
        self.bottom_node:stopAllActions()
		local spanx = 93
		if g_scrSize.width == 960 then
			spanx = 85
		end
		if full_mode then
			if self.mk_btn then
				self.mk_btn:setPosition(cc.p(g_scrSize.width/2-265,160))
			end
            self.operate_node:setPosition(cc.p(- 230 * muti, 0))
            self.operate_node:setVisible(false)
            for i, v in pairs(self.leftBottomBtn) do
                v.node:setPosition(self.leftButtonPos[i])
            end
            if self.skill_node then
                self.skill_node:setPosition(cc.p(skill_posx + 300 * muti, 0))
                self.skill_node:setVisible(false)
			end
            for i, v in pairs(self.rightBottomBtn) do
                v.node:setPosition(self.rightButtonPos[i])
            end
            self.bottom_node:setVisible(true)
		else
			if self.mk_btn then
				self.mk_btn:setPosition(cc.p(g_scrSize.width/2-220,90))
			end
			self.operate_node:setPosition(cc.p(-200*muti,0))
            local spawnActions = {}
            for i, v in pairs(self.leftBottomBtn) do
                v.node:setPosition(cc.p(0, posY_bottomButton))
            end
            for i, v in pairs(self.rightBottomBtn) do
                v.node:setPosition(cc.p(0, posY_bottomButton))
            end
            self.operate_node:setPosition(cc.p(0, 0))
            if self.skill_node then
                self.skill_node:setVisible(true)
                self.skill_node:setPosition(cc.p(skill_posx, 0))
            end
            self.operate_node:setVisible(true)
            self.bottom_node:setVisible(false)
		end
	elseif not force and BaseMapScene.full_mode ~= full_mode and self.bottom_node then
		self.bottom_node:stopAllActions()
		local spanx = 93 
		if g_scrSize.width == 960 then
			spanx = 85
		end
		if full_mode then
			if self.mk_btn then
				self.mk_btn:setPosition(cc.p(g_scrSize.width/2-265,160))
			end
            local spawnActions = {}
            table.insert(spawnActions, cc.TargetedAction:create(self.operate_node, cc.Sequence:create(
                cc.DelayTime:create(duration_small_gap_between_bottom_btns * 0)
                , cc.MoveTo:create(duration_buttonSlide, cc.p(- 230 * muti, 0))
                , action1
            )))
            for i, v in pairs(self.leftBottomBtn) do
                v.node:setPosition(cc.p(0, posY_bottomButton))
                table.insert(spawnActions, cc.TargetedAction:create(v.node, cc.Sequence:create(
                    cc.DelayTime:create(duration_small_gap_between_bottom_btns * i)
                    , cc.MoveTo:create(duration_buttonSlide, self.leftButtonPos[i])
                )))
            end
            if self.skill_node then
                table.insert(spawnActions, cc.TargetedAction:create(self.skill_node, cc.Sequence:create(
                    cc.DelayTime:create(duration_small_gap_between_bottom_btns * 0)
                    , cc.MoveTo:create(duration_buttonSlide, cc.p(skill_posx + 300 * muti, 0))
                    , action1
                )))
			end
            
            for i, v in pairs(self.rightBottomBtn) do
                v.node:setPosition(cc.p(0, posY_bottomButton))
                table.insert(spawnActions, cc.TargetedAction:create(v.node, cc.Sequence:create(
                    cc.DelayTime:create(duration_small_gap_between_bottom_btns * (table.size(self.rightBottomBtn) - i + 1))
                    , cc.MoveTo:create(duration_buttonSlide, self.rightButtonPos[i])
                )))
            end
            self.bottom_node:runAction(cc.Sequence:create(
                action2
                , cc.Spawn:create(
                    spawnActions
                )
            ))
		else
			if self.mk_btn then
				self.mk_btn:setPosition(cc.p(g_scrSize.width/2-220,90))
			end
			if self.skill_node then
				self.skill_node:setPosition(cc.p(skill_posx + 300 * muti, 0))
			end
			self.operate_node:setPosition(cc.p(-200*muti,0))
            local spawnActions = {}
            for i, v in pairs(self.leftBottomBtn) do
                table.insert(spawnActions, cc.TargetedAction:create(v.node, cc.Sequence:create(
                    cc.DelayTime:create(duration_small_gap_between_bottom_btns * (table.size(self.leftBottomBtn) - i))
                    , cc.MoveTo:create(duration_buttonSlide, cc.p(0, posY_bottomButton))
                )))
            end
            
            for i, v in pairs(self.rightBottomBtn) do
                table.insert(spawnActions, cc.TargetedAction:create(v.node, cc.Sequence:create(
                    cc.DelayTime:create(duration_small_gap_between_bottom_btns * (i - 1))
                    , cc.MoveTo:create(duration_buttonSlide, cc.p(0, posY_bottomButton))
                )))
            end
            table.insert(spawnActions, cc.TargetedAction:create(self.operate_node, cc.Sequence:create(
                cc.DelayTime:create(duration_small_gap_between_bottom_btns * table.size(self.rightBottomBtn))
                , cc.MoveTo:create(duration_buttonSlide, cc.p(0, 0))
            )))
            if self.skill_node then
                self.skill_node:setVisible(true)
                table.insert(spawnActions, cc.TargetedAction:create(self.skill_node, cc.Sequence:create(
                    cc.DelayTime:create(duration_small_gap_between_bottom_btns * table.size(self.rightBottomBtn))
                    , cc.MoveTo:create(duration_buttonSlide, cc.p(skill_posx, 0))
                )))
            end
            self.operate_node:setVisible(true)
            self.bottom_node:runAction(cc.Sequence:create(
                cc.Spawn:create(
                    spawnActions
                )
                , action1
            ))
		end
	end
	if self.activityRankNode then
		self.activityRankNode:setVisible(not full_mode)
	end
	
	if self.carryNode and self.carryNode.NeedChangeVisibleNode then
		self.carryNode.NeedChangeVisibleNode:setVisible(not full_mode)
	end
	BaseMapScene.full_mode = full_mode
	-- self:refreshRedPoints(2)
end


function BaseMapScene:addTopNode()
	local top_node = cc.Node:create()
	self:addChild(top_node,1)
	local downFun = function(touch)
		self:setFullShortNode(false)
		return false
	end
	local listenner = self:createTouchHandler(top_node,downFun)
	--listenner:setSwallowTouches(true)
end

function BaseMapScene:checkMapIdChangeColor(mapId)
	local cfg = getConfigItemByKey("MapInfo", "q_map_id", mapId)
	if ( cfg and cfg.q_map_pk and cfg.q_map_pk == 0 ) or self:CheckEmpireState() or self:checkShaWarState() then
		return true
	end

	return false
end

function BaseMapScene:changePlayColor()
	if self.map_layer and self.map_layer.role_tab then 
		for i,v in pairs(self.map_layer.role_tab) do
			self:QryMonsterNameColor(v)
		end
	end
end

function BaseMapScene:changeMonsterColor()
	if self.map_layer and self.map_layer.monster_tab then 
		for i, v in pairs(self.map_layer.monster_tab) do   --所有怪物
			local role = tolua.cast(self.map_layer.item_Node:getChildByTag(v), "SpriteMonster")
			local monster_id = role:getMonsterId()
			if G_MAINSCENE.map_layer.isSkyArena or (monster_id >= 80000 and monster_id < 80005 ) then  --镖车
				self:QryMonsterNameColor(v)
				--print("[BaseMapScene:changeMonsterColor] called", monster_id)
			end
		end	
	end
end

function BaseMapScene:changePetNameColor()
	if self.map_layer and self.map_layer.pet then 
		for i, v in pairs(self.map_layer.pet) do   --所有怪物
			local role = tolua.cast(v, "SpriteMonster")
			local monster_id = role:getMonsterId()
			if (self.map_layer.mapID == 5003 and (monster_id >= 90000 and monster_id <= 92028) ) then  --5003的骷髅
				self:QryMonsterNameColor(v:getTag())
				--print("[BaseMapScene:changePetNameColor] called", monster_id)
			end
		end	
	end
end

--3V3设置名字颜色
function BaseMapScene:set3V3NameColor(item_Node, teamID)
    if item_Node == G_ROLE_MAIN then
    	self:changePlayColor()
    	self:changeMonsterColor()
    	return
    end
    self:QryMonsterNameColor(item_Node:getTag())
end

function BaseMapScene:QryMonsterNameColor(tag, isGray)
	if tag == nil or tag == 0 or not G_ROLE_MAIN then return end

	if self.map_layer.isStory then return end

	--处于结盟或者宣战状态
	local function isHasALLYOrHostie()
		if (G_FACTION_INFO.ally_fac_list and #G_FACTION_INFO.ally_fac_list > 0) or (G_FACTION_INFO.Hostile_fac_list and #G_FACTION_INFO.Hostile_fac_list > 0) then
			return true
		else
			return false
		end
	end

	local function setNameColByPkValue(tag, role)
		if not tag or not role then return end
		if role:getType() < 20 then
			require("src/base/MonsterSprite"):updateNameColor(role)
			return 
		end
		
		local pkVal = MRoleStruct:getAttr(PLAYER_PK, tag)
		if pkVal then
			G_ROLE_MAIN:setNameColor_ex(role, pkVal, isGray)
		end
	end

	local role = tolua.cast(self.map_layer.item_Node:getChildByTag(tag), "SpriteMonster")
	local monster_id = role:getMonsterId()
	if not role then return end
	local nameNode = role:getNameBatchLabel()
	if not nameNode then return end
------------------------------------------------------------------------
	local normalType, greenType, HositleType, factionType, p3v3_blueType, p3v3_redType = 1, 2, 3, 4, 5, 6
	local ret = normalType
	
	local factionID = MRoleStruct:getAttr(PLAYER_FACTIONID, tag)
	local teamID = MRoleStruct:getAttr(PLAYER_TEAMID, tag)
    local fightTeamID = MRoleStruct:getAttr(PLAYER_FIGHT_TEAM_ID, tag)

	local myFactionId = MRoleStruct:getAttr(PLAYER_FACTIONID)
	local myTeamID = MRoleStruct:getAttr(PLAYER_TEAMID)
    local myFightTeamId = MRoleStruct:getAttr(PLAYER_FIGHT_TEAM_ID)
    local myPkValue = MRoleStruct:getAttr(PLAYER_PK)
    local isMeRed = myPkValue and myPkValue >= 4 or false

	local teamInfoAcitve = (self.map_layer.mapID == 2100 or G_MAINSCENE.map_layer.isSkyArena )
	local flgChangeCol = self:checkMapIdChangeColor(self.map_layer.mapID)
------------------------------------------------------------------------
	
	-- if self.map_layer.mapID == 2100 then
	-- 	dump("" .. (myTeamID or "nil") .. "s" ..(teamID or "nil") .. tostring(tag == G_ROLE_MAIN.obj_id), "QryMonsterNameColor  5003")
	-- end
	if myFightTeamId ~= nil and self.map_layer and self.map_layer.is3v3 then
        ret = (myFightTeamId == fightTeamID and p3v3_blueType or p3v3_redType)
    elseif myTeamID ~= nil and self.map_layer and self.map_layer.isSkyArena then
        ret = (myTeamID == teamID and p3v3_blueType or HositleType)		    
    elseif self.map_layer.mapID == 5003 and myTeamID ~= nil then --运镖 1-n 地图
    	ret = (myTeamID == teamID and greenType or p3v3_redType)	
    elseif self.map_layer.mapID == 5010 and myTeamID ~= nil then --
    	ret = (myTeamID == teamID and p3v3_blueType or HositleType)	    
	elseif isMeRed then
		setNameColByPkValue(tag, role)
		return
	elseif myTeamID ~= nil and myTeamID > 0 and teamID == myTeamID and teamInfoAcitve then
		ret = greenType
	elseif G_ROLE_MAIN:getFactionRelation(factionID, 1) then  --同盟
		ret = factionType
	elseif G_ROLE_MAIN:getFactionRelation(factionID, 2) then  --敌对
		ret = HositleType
	elseif G_ROLE_MAIN:getFactionRelation(factionID, 3) and (isHasALLYOrHostie() or flgChangeCol) then  --同会
		ret = factionType
	elseif flgChangeCol then
		if self:checkShaWarState() then
		    local attackFacs = G_SHAWAR_DATA.startInfo.Attack

		    local isInFactionList = function(id)
				if not id or id == 0 then return false end

				for i = 1, #attackFacs do
					if id == attackFacs[i] then
						return true
					end
				end
				return false
		    end

		    if isInFactionList(myFactionId) and isInFactionList(factionID) then
		    	ret = HositleType
		    else
		    	ret = greenType
		    end
		elseif self:CheckEmpireState()  then
			ret = HositleType
		else
			ret = greenType
		end

		if tag == G_ROLE_MAIN.obj_id and ret == greenType then
			ret = factionType
		end
	else
		setNameColByPkValue(tag, role)
		return
	end

	local colorCfg = {MColor.white, MColor.name_green, MColor.name_orange, MColor.name_blue, MColor.name_blue, MColor.name_red}
	if colorCfg[ret] then		
		nameNode:setColor(colorCfg[ret])
	else
		cclog("QryMonsterNameColor error " .. ret)
	end
	
	G_ROLE_MAIN:changeFactionNameColor(role)
end

function BaseMapScene:changePlayShaName()
	if self.map_layer and self.map_layer.role_tab then 
		local MRoleStruct = require("src/layers/role/RoleStruct")
		for i,v in pairs(self.map_layer.role_tab) do
			local role = tolua.cast(self.map_layer.item_Node:getChildByTag(i), "SpritePlayer")
			if role then
				local factionId = MRoleStruct:getAttr(PLAYER_FACTIONID, v)
				if factionId and G_ROLE_MAIN then
					G_ROLE_MAIN:showShaName(role, factionId)
				end
			end
		end
	end	
end

function BaseMapScene:setShaWarHoldRoleDir( data )
	if self.map_layer and self.map_layer.item_Node then 
		local MRoleStruct = require("src/layers/role/RoleStruct")
		for m,n in pairs(data) do
			if n.holdID2 and n.holdID2 > 0 then
				local func = function()
					local role = tolua.cast(self.map_layer.item_Node:getChildByTag(n.holdID2), "SpritePlayer")
					if role then
						local dir = (n.holdIndex and n.holdIndex == 1) and 5 or 7
						role:setSpriteDir(dir)
						role:standed()
					end
				end
				performWithDelay(self.map_layer.item_Node, func, 0.3)
			end
		end
	end
end

function BaseMapScene:changeHoldDirByRoleID(id)
	if not id or id == 0 then return end

	if not self:checkShaWarState() then return end
	if self.map_layer and self.map_layer.item_Node then 
		local data = G_SHAWAR_DATA.holdData or {}
		for k,v in pairs(data) do
			if v.holdID2 and v.holdID2 == id then
				local role = tolua.cast(self.map_layer.item_Node:getChildByTag(id), "SpritePlayer")
				if role then
					role:showShaWarHoldBtn(role, true)
				end				
				local func = function()
					local role = tolua.cast(self.map_layer.item_Node:getChildByTag(id), "SpritePlayer")
					if role then
						local dir = ( k == 1) and 5 or 7
						role:setSpriteDir(dir)
						role:standed()
						
					end
				end
				performWithDelay(self.map_layer.item_Node, func, 0.3)
			end
		end
	end
end

function BaseMapScene:createChatPanel()
	local topNode = cc.Node:create()
	self:addChild(topNode, 499)
	topNode:setPosition(cc.p(display.cx, display.height))

	G_CHAT_INFO.chatPanel = require("src/layers/chat/ChatPanel").new(topNode)
	--G_CHAT_INFO.chatPanel:setAnchorPoint(cc.p(0.0,0.5))
	G_CHAT_INFO.chatPanel:setPosition(cc.p(0, 280 + (g_scrSize.height-640)))
	self:addChild(G_CHAT_INFO.chatPanel,7)
end


function BaseMapScene:playGetPrizeEffect(itemNum,items,time,bag_pos)
    local cd_time = time or 0.1
    if itemNum > 5 then cd_time = 0.02 + 0.4/itemNum  end
    local MPropOp = require "src/config/propOp"
    local bottom_pos = cc.p(self.bottom_node:getPosition())
    local des_pos = bag_pos or cc.p(bottom_pos.x+self.leftBottomBtn[2].pos.x,self.leftBottomBtn[2].pos.y+30)
    for i=1,itemNum do
    		local group = cc.Node:create()
    		setNodeAttr( group , cc.p( display.width/2 , display.height/2 + 100 ) , cc.p( 0.5 , 0.5 ) )
    		getRunScene():addChild( group,300)

			local eff = Effects:create(false)
			eff:playActionData("skillSparkInside", 12 , 2 , -1 )
			group:addChild( eff , -1 )

    		local dropIcon = createSprite( group , MPropOp.icon( items[i].id  ) , cc.p( 0 , 0 ) , cc.p( 0.5 , 0.5 ) )

    		group:runAction( cc.Spawn:create( {
			 cc.CallFunc:create( 
		 		function() 
				 	local bagIcon = createSprite(self, "res/mainui/bottombtns/2.png" , des_pos , cc.p( 0.5 , 0.5 ) )
				 	bagIcon:setOpacity( 0 )

				 	bagIcon:runAction( cc.Sequence:create( 
				 		{ 
					 		cc.DelayTime:create( cd_time * i + 0.2 + 0.3 ) , 
					 		cc.FadeIn:create( 0.3 ) ,
					 		cc.DelayTime:create( 0.7 ) ,
					 		cc.FadeOut:create( 0.3 ) ,
					 		cc.CallFunc:create( function() 
						 			if bagIcon then
							 			removeFromParent(bagIcon) 
							 			bagIcon = nil 
						 			end 
					 			end )
				 		} ) )

			  	end ) , 
    		 cc.Sequence:create( {
    			cc.DelayTime:create( cd_time * i ) , 
				cc.EaseBackOut:create( cc.Sequence:create( { cc.ScaleTo:create( cd_time , 1.3 ) , cc.ScaleTo:create( cd_time , 1 ) , } ) ) ,
				cc.Spawn:create( { cc.ScaleTo:create( cd_time*5 , 0.3 ) , cc.MoveTo:create( cd_time*5  , des_pos )} ) ,
				cc.CallFunc:create( function() 
						if group then
							removeFromParent(group) 
							group = nil
						end
					end ) 
				} ) , 
    		 } ) )
    end
end

function BaseMapScene:addBattleNum(num)
	if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
		--公平竞技场，战斗力统一配置
		local MRoleStruct = require("src/layers/role/RoleStruct")
		local school=MRoleStruct:getAttr(ROLE_SCHOOL) 
		local battle = getConfigItemByKeys("roleData", {"q_zy","q_level"},{school,-1},"battle")
		if battle and battle>=0 then
			num=battle
		end
	end
	if self.battle_num then
		removeFromParent(self.battle_num)
		self.battle_num = nil
	end
	self.battle_num = require("src/base/HurtSprite").new("res/component/number/10.png",num,{0,0,340,38},34,nil,-5)--MakeNumbers:create("res/component/number/10.png",num,-5)
	local posx,scale = 165,0.6
	if num < 1000 then
	elseif num < 10000 then
		posx = 155
	elseif num < 100000 then 
		posx = 155
	elseif num < 1000000 then 
		posx = 155 scale=0.5 
	else
		posx = 155 scale=0.5 
	end
	self.battle_num:setPosition(cc.p(posx,g_scrSize.height-48))
	self.battle_num:setScale(scale)
	self.topLeftNode:addChild(self.battle_num,108)
end


function BaseMapScene:refreshOfflineRedDot(level,battle)
	if not level then
		level = MRoleStruct:getAttr(ROLE_LEVEL)
	end
	if not battle then
		battle = MRoleStruct:getAttr(PLAYER_BATTLE)
	end
	cclog("hahalevel"..tostring(level).."~"..tostring(battle))
	if level and battle then
		local offData = getConfigItemByKey("OffLineDB")--,"q_layer",G_OFFLINE_DATA.tryLayer)
		G_OFFLINE_DATA.maxLayer = tonumber(offData[#offData].q_layer)
		for i=2,#offData do
			local b = tonumber(offData[i].q_enterBattle)
			local l = tonumber(offData[i].q_level)
			if level < l or battle < b then
				G_OFFLINE_DATA.maxLayer = tonumber(offData[i].q_layer)-1
				break
			end
		end
		cclog("hahalevel"..tostring(G_OFFLINE_DATA.currLayer).."~"..tostring(G_OFFLINE_DATA.maxLayer))
		if G_OFFLINE_DATA.currLayer and G_OFFLINE_DATA.maxLayer then
			if G_OFFLINE_DATA.maxLayer > G_OFFLINE_DATA.currLayer then
				G_OFFLINE_DATA.couldGotoNext = true
			else
				G_OFFLINE_DATA.couldGotoNext = false
			end
			--self:refreshActivityReddot()
		end
	end
end

function BaseMapScene:setSkillSetting(skillId)
	function isSkillLearned(id)
		for k,v in ipairs(G_ROLE_MAIN.skills)do
			if v[1] == id then
				return true
			end
		end

		return false
	end

	--法师逻辑
	--冰咆哮
	if skillId == 2008 then
		setGameSetById(GAME_SET_ID_AUTO_ICE, 1)
		setGameSetById(GAME_SET_ID_AUTO_THUNDER, 0)
	--地狱雷光
	elseif skillId == 2003 then
		--if not (isSkillLearned(2008) and getGameSetById(GAME_SET_ID_AUTO_ICE) == 1) then
			setGameSetById(GAME_SET_ID_AUTO_THUNDER, 1)
			--setGameSetById(GAME_SET_ID_AUTO_THUNDER_ONE, 0)
		--end
	--雷电术
	elseif skillId == 2002 then
		--setGameSetById(GAME_SET_ID_AUTO_THUNDER_ONE, 1)
	elseif skillId == 2004 then
		setGameSetById(GAME_SET_MAGICSHIELD,1)
	elseif skillId == 2009 then
		setGameSetById(GAME_SET_FASHI_DEFENSE,1)
	end

	--战士逻辑
	--烈火剑法
	if skillId == 1006 then
		setGameSetById(GAME_SET_ID_AUTO_FIRE, 1)
		-- setGameSetById(GAME_SET_ID_AUTO_DOUBLE_FIRE, 1)
	--半月斩
	elseif skillId == 1004 then
		setGameSetById(GAME_SET_ID_AUTO_HALFMOON, 1)
		--setGameSetById(GAME_SET_ID_AUTO_ASSASSINATION, 0)
	--刺杀剑术
	elseif skillId == 1003 then
		--setGameSetById(GAME_SET_ID_AUTO_ASSASSINATION, 1)
	elseif (skillId == 1005 or skillId == 1010) and getGameSetById(GAME_SET_AUTOCRASH) == 0 and getGameSetById(GAME_SET_AUTOCRASHKILL) == 0 then
		setGameSetById(GAME_SET_AUTOCRASH,1) 
	elseif skillId == 1008 then
		setGameSetById(GAME_SET_ZHANSHI_DEFENSE,1)	
	end

	--道士逻辑
	--召唤骨卫
	if skillId == 3008 then
		setGameSetById(GAME_SET_ID_AUTO_SUMMON_GW, 1)
		setGameSetById(GAME_SET_ID_AUTO_SUMMON, 0)
	--召唤神兽
	elseif skillId == 3007 then
		setGameSetById(GAME_SET_ID_AUTO_SUMMON, 1)
		setGameSetById(GAME_SET_ID_AUTO_SUMMON_GW, 0)
	--幽灵战甲术
	elseif skillId == 3006 then
		setGameSetById(GAME_SET_ID_AUTO_ARMOUR, 1)
	elseif skillId == 3004 then
		setGameSetById(GAME_SET_ID_AUTO_POISON, 1)
	elseif skillId == 3010 then
		setGameSetById(GAME_SET_DAOSHI_DEFENSE,1)	
	end


	saveGameSettings()
end

function BaseMapScene:setSkill()
	if G_SETPOSTEMP[1] then
		require("src/layers/skillToConfig/newSkillConfigHandler").SkillConfig(G_SETPOSTEMP[1])
	end
end

function BaseMapScene:setEquip()
	if G_SETPOSTEMPE[1] then
		local protoId = MPackStruct.protoIdFromGird(G_SETPOSTEMPE[1])
		local kind = require("src/config/equipOp").kind(protoId)
		local time = 0
		self.kind = self.kind or kind
		if self.kind == kind then
			time = 1.2
		end
		local func = function()
			-- require("src/layers/tuto/AutoConfigNode").new(G_SETPOSTEMPE[1][1],G_SETPOSTEMPE[1][2],G_SETPOSTEMPE[1][3],G_SETPOSTEMPE[1][4],G_SETPOSTEMPE[1][5],G_SETPOSTEMPE[1][6],G_SETPOSTEMPE[1][7])
			if G_SETPOSTEMPE[1] then
				equipTip(G_SETPOSTEMPE[1][1],G_SETPOSTEMPE[1][2])
			end
			self.kind = kind
		end
		performWithDelay( self , func , time )
	end
end

function BaseMapScene:downMoneyEffect()
	if self.downMoneyStatu or getGameSetById(GAME_SET_SHOWREDBAG) == 1 then  return end
	
	local num = math.random(40, 60)
	for i = 1, num do
		local effType = math.random(1, 2)
		local node = createSprite(self, "res/mainui/goldEff.png")
		local height = display.height + i/ num * 100 + 60 --math.random(660, 800)
		local pos = self:convertToNodeSpace(cc.p((i % 11) * 100 + 60, height))
		node:setPosition(cc.p(pos.x-math.random(-75, 75), pos.y)) 
		local scaleRandom= math.random(5, 13) / 10
		node:setScale(scaleRandom)
		local allTime = math.random(1.49 +  (num - i) / num * 0.3, 1.8 - i/ num * 0.3)
		local delayTime = math.random(0, 0.5) + 0.03 * i
		local actions = {}
		actions[#actions+1] = cc.DelayTime:create(delayTime)
		actions[#actions+1] = cc.CallFunc:create(function() node:setLocalZOrder(666) end)
		actions[#actions+1] = cc.DelayTime:create(allTime)
		actions[#actions+1] = cc.CallFunc:create(function() 
				if node then
					removeFromParent(node) 
					node = nil
					if i ==num then 
						self.downMoneyStatu = false
					end
				end 
			end)
		node:runAction(cc.Sequence:create(actions))
		
		local actions = {}
		actions[#actions+1] = cc.DelayTime:create(delayTime)
		actions[#actions+1] = cc.MoveBy:create(0.5, cc.p(math.random(-10, 10), 100))
		actions[#actions+1] = cc.MoveBy:create(allTime - 0.5, cc.p(math.random(-10, 10), - height - 60 - 100))
		node:runAction(cc.Sequence:create(actions))
		self.downMoneyStatu = true
	end		
end

function BaseMapScene:checkChangeEquipment()
	local dressPack = MPackManager:getPack(MPackStruct.eDress)
	local bagPack = MPackManager:getPack(MPackStruct.eBag)

	for i=MPackStruct.eWeapon, MPackStruct.eMedal do
		if i ~= MPackStruct.eCuffRight and i ~= MPackStruct.eRingRight then 
			local equipTab = MPackManager:getEquipList(i)

			if equipTab and #equipTab > 0 then
				local bestGird
				for k,v in pairs(equipTab) do
					if bestGird == nil then 
						bestGird = v
					else
						local battleNew = MPackStruct.attrFromGird(v, MPackStruct.eAttrCombatPower)
						local battleOld = MPackStruct.attrFromGird(bestGird, MPackStruct.eAttrCombatPower)
						if battleNew > battleOld then 
							bestGird = v
						end
					end
				end

				if bestGird then
					self:compareEquipment(bestGird)
				end
			end
		end
	end
end

function BaseMapScene:compareEquipment(gird)
	log("compareEquipment")
	if MPackStruct.categoryFromGird(gird) == MPackStruct.eEquipment then
		--是否职业可用
		local protoId = MPackStruct.protoIdFromGird(gird)
		local school = require("src/config/propOp").schoolLimits(protoId)
		local level = require("src/config/propOp").levelLimits(protoId)
		local MRoleStruct = require("src/layers/role/RoleStruct")
		local selfSchool = MRoleStruct:getAttr(ROLE_SCHOOL)
		local selfLevel = MRoleStruct:getAttr(ROLE_LEVEL) or 0

		if school ~= selfSchool then
			return
		end

		if selfLevel < level then
			return
		end

		table.insert(G_SETPOSTEMPE,{gird,true})
		if #G_SETPOSTEMPE <= 1 then
			equipTip(G_SETPOSTEMPE[1][1],G_SETPOSTEMPE[1][2])
		end 
	end
end

function BaseMapScene:recoverBtns()
	-- if userInfo.fbPrizeBtn and (not self:getChildByTag(617)) then
	-- 	local openList = function() 
	-- 		g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETPROREWARDLIST,"GetProRewardListProtocol",{})
	-- 	end
		
	-- 	local btn = G_MAINSCENE:createActivityIconData({priority= 30, 
 --    							btnResName = "res/mainui/subbtns/fbsy.png",
 --    							btnResLab = game.getStrByKey("title_fb_rewards"),
 --    							btnCallBack = openList,
 --    							btnZorder = 200})
	-- 	userInfo.fbPrizeBtn = btn
	-- 	userInfo.fbPrizeBtn:setTag(617)
	-- end
	self:updateTeamQuickEntry()
end

function BaseMapScene:updateTeamQuickEntry()
	--多人守卫下不刷新小旗子
	local func = function()
		if self.map_layer.mapID == 5104 then
			return
		end

		if self.entryBtn then
			removeFromParent(self.entryBtn)
			self.entryBtn = nil
		end

		if self.map_layer and self.map_layer.role_tab then
			for k,v in pairs(self.map_layer.role_tab) do
				if G_ROLE_MAIN and k ~= G_ROLE_MAIN.obj_id then
					local role = tolua.cast(self.map_layer.item_Node:getChildByTag(k),"SpritePlayer")
					if role then
						G_ROLE_MAIN:setCornerSign_ex(role,1)
					end
				end
			end
		end

		if G_TEAM_INFO.has_team then
			local func = function()
				__GotoTarget({ ru = "a29",index = 1})
			end
			self.entryBtn = createTouchItem( self.BuffNode , "res/teamup/62.png" , cc.p(130, g_scrSize.height-135), func,true)
	        if self.entryBtn ~= nil then
	        	local mem = G_TEAM_INFO.memCnt
	        	if mem > 10 then
	        		mem = 10
	        	end
			    local num = MakeNumbers:create("res/component/number/3.png",mem,-2)
			    num:setScale(0.5)
			    local sz = self.entryBtn:getContentSize()
			    num:setPosition(cc.p(sz.width+2,13))
			    self.entryBtn:addChild(num)
			    --self.entryBtn:setVisible(not self.isHide_icon)

                -- 去掉组队小旗子
                self.entryBtn:setVisible(false);
	        end
		end
	end

	--self.BuffNode 按钮出现得比较晚
	performWithDelay(self, func, 0.7)
end 

function BaseMapScene:showTipLayer()
	local tiplayer = cc.Node:create()
	tiplayer:setPosition(cc.p(0,0))
	self:addChild(tiplayer,200)
	self.tipLayer = tiplayer
end
function BaseMapScene:updateChatStartBtn()
    if self.chatStartBtn == nil or G_CHAT_INFO.unReadPrivateRecord == nil then
        return
    end

    local numNode = self.chatStartBtn:getChildByTag(99)
    if numNode == nil then 
        numNode = cc.Node:create()
        numNode:setPosition(46,50)
        numNode:setTag(99)
	    self.chatStartBtn:addChild(numNode)
        
        local la = createLabel(numNode, " " ,cc.p(-1,-2), nil, 16, true,nil,nil,MColor.yellow)
        la:setTag(1)
        la:setAnchorPoint(cc.p(0.5,0.5))

        createSprite(numNode, "res/component/flag/red.png", cc.p(0, -5), cc.p(0.5, 0.5), -1)
    end

    if G_CHAT_INFO.unReadPrivateRecord == 0 then
        numNode:setVisible(false)
        return;
    else
        numNode:setVisible(true)
    end

    local str = tonumber(G_CHAT_INFO.unReadPrivateRecord)
    if G_CHAT_INFO.unReadPrivateRecord > 9 then
        str = "9+";
    end
    numNode:getChildByTag(1):setString(str)
end
function BaseMapScene:createBaseButton()
	log("[BaseMapScene:createBaseButton] called.")

	local clickFuncFactionBoss = function()
	
		local mapId, posX, posY = 2111, 22, 35
		local data = require("src/config/NPC")
		for i=1, #data do
			if tonumber(data[i].q_id) == 10393 then
				mapId = tonumber(data[i].q_map)
				posX = tonumber(data[i].q_x)
				posY = tonumber(data[i].q_y)
				break
			end
		end
		
		local WorkCallBack = function()
			require("src/layers/mission/MissionNetMsg"):sendClickNPC(10393)
		end

     	local tempData = { targetType = 4, mapID = mapId,  x = posX, y = posY, callFun = WorkCallBack }
        __TASK:findPath( tempData )
		__removeAllLayers()
		
		---------------------------------------------------
		
	--	if G_MAINSCENE then
	--		G_MAINSCENE:showBaseButtonFactionBoss(false, false)
	--	end
		self:showBaseButtonFactionBoss(false, false)

	--	local detailMapNode = require("src/layers/map/DetailMapNode")
	--	detailMapNode:goToMapPos(mapId, cc.p(posX+1, posY+1), false)
	end

	local baseBtnFactionBoss = self:createActivityIconData({priority = 20, 
	    							btnResName = "res/mainui/subbtns/faction_search.png",
	    							btnResLab = game.getStrByKey("faction_fb"),
	    							btnCallBack = clickFuncFactionBoss,
	    							btnZorder = 100})
	if baseBtnFactionBoss ~= nil then
		self.baseBtnFactionBoss = baseBtnFactionBoss
		baseBtnFactionBoss:setVisible(true)

		local eff = Effects:create(false)
		self.baseBtnFactionBossEff = eff
		eff:playActionData2("firstBtnEffect", 230 , -1 , 0)
		addEffectWithMode(eff,3)
		eff:setPosition(getCenterPos(baseBtnFactionBoss.button))
		baseBtnFactionBoss.button:addChild(eff)
		eff:setScale(1.11)
		eff:setVisible(false)
	end
end

function BaseMapScene:showBaseButtonFactionBoss(showBtn, showEff)
	if self.baseBtnFactionBoss and self.baseBtnFactionBossEff then
		if showBtn == true and showEff == false then
			self.baseBtnFactionBoss:setVisible(true)
			self.baseBtnFactionBossEff:setVisible(false)
		elseif showBtn == false and showEff == true then
			self.baseBtnFactionBossEff:setVisible(true)
		else	-- false, false
			self:removeActivityIconData({
				btnResName = "res/mainui/subbtns/faction_search.png",
				})
			self.baseBtnFactionBoss = nil
			self.baseBtnFactionBossEff = nil
			-- self.baseBtnFactionBossEff:setVisible(false)
		end
	end
end

function BaseMapScene:createTaskDigIcon()
	local funcDig = function()
		local ret = require("src/layers/teamTreasureTask/teamTreasureTaskLayer"):checkShowPromptDialog()
		if ret then
			if self.map_layer then
				self.map_layer:addDigAction()
			end
		end
	end

	if self.mTaskDigIcon == nil then
		local sprtIcon = createMenuItem(self, "res/layers/teamTreasureTask/task_dig.png", cc.p(display.cx + 125, display.cy - 100), funcDig)
		self.mTaskDigIcon = sprtIcon
	end
end

function BaseMapScene:removeTaskDigIcon(map_id)
	if map_id and self.map_layer then
		if map_id ~= self.map_layer.mapID then
			return
		end
	end

	if self.mTaskDigIcon then
		removeFromParent(self.mTaskDigIcon)
		self.mTaskDigIcon = nil
	end
end

function BaseMapScene:showArrowPointToMonster(isShow, dirpos, isNewPos)
	if isShow then
		if G_ROLE_MAIN and self.map_layer then
			local tile_pos1 = G_ROLE_MAIN.tile_pos
			local tile_pos2 = dirpos
			local rote = math.atan2(tile_pos2.y - tile_pos1.y, tile_pos2.x - tile_pos1.x) * 180 /math.pi + 90 + 360
			G_ROLE_MAIN:changeArrowRot(rote)
			
			if math.abs(tile_pos2.y - tile_pos1.y) < 10 and math.abs(tile_pos2.x - tile_pos1.x) < 10 then
				G_ROLE_MAIN:setArrowEffVisible(false)
			else
				G_ROLE_MAIN:setArrowEffVisible(true)
			end		
		end

		--如果是新的点. 需要去掉指向原来点的定时器
		if isNewPos and self.ArrowPointMonsterTimer then
			self:stopAction(self.ArrowPointMonsterTimer)
			self.ArrowPointMonsterTimer = nil
		end
		if not self.ArrowPointMonsterTimer then
			self.ArrowPointMonsterTimer = startTimerAction(self, 0.2, true, function ()
				self:showArrowPointToMonster(true, dirpos)
			end)	
		end
	else
		if self.ArrowPointMonsterTimer then
			self:stopAction(self.ArrowPointMonsterTimer)
			self.ArrowPointMonsterTimer = nil
		end

		if G_ROLE_MAIN then
			G_ROLE_MAIN:removeArrowDir()
		end
	end
end

function BaseMapScene:setArrowBtnVisable(isVisible)
	if G_ROLE_MAIN then
		G_ROLE_MAIN:setArrowNodeVisible(isVisible)
	end
end


function BaseMapScene:showActivityRank(rankInfo)
	-- local rankInfo = {}
	-- rankInfo.myNum = 1000
	-- rankInfo.myRank = 5
 	-- rankInfo.rankData = {}
	-- rankInfo.rankData[1] = {}
	-- rankInfo.rankData[1].Num = 5
	-- rankInfo.rankData[1].Name = 13212
	-- self:showActivityRank(rankInfo)

	--怪物攻城活动开启的时候
	if 2100 == self.map_layer.mapID then
		if nil == self.activityRankNode then
			self.activityRankNode = require("src/layers/activity/cell/monsterAttack").new()
			self.mainui_node:addChild(self.activityRankNode, 11)

			self.activityRankNode:setVisible(not BaseMapScene.full_mode)
		end
		if self.activityRankNode then
			self.activityRankNode:changeRank(rankInfo)
		end
	else
		self:removeActivityRank()
	end
end

function BaseMapScene:removeActivityRank()
	if self.activityRankNode then
		removeFromParent(self.activityRankNode)
		self.activityRankNode = nil
	end
end

function BaseMapScene:setFactionRedPointVisible(eventType, visible)
	--  eventType定义
    --1  成员申请加入事件
    --2  行会副本开启事件
    
    if self.factionEventMap == nil then      
        self.factionEventMap = {}
    end

    if eventType ~= nil then
        self.factionEventMap[eventType] = visible
    end

    local bV = false
    for k, v in pairs(self.factionEventMap) do
        if v == true then
            bV = true
            break
        end
    end

    if self.faction_redPoint ~= nil then
       self.faction_redPoint:setVisible( bV )
    end
end

function BaseMapScene:shaWarTimeStart(time)
	if time <= 0 then return end
	local node = self:getChildByTag(595)
	if node then
		removeFromParent(node)
	end

	node = cc.Node:create()
	self:addChild(node, 500, 595)
	local timer 
	local timeShow = function(detime)
		node:removeAllChildren()
		if time < 0 then
			if timer then
				timer:stopAllActions()
			end
			removeFromParent(node)
			return
		end

		local lab = createLabel(node, "沙城争霸战即将开启", cc.p(display.cx, display.cy), nil, 28)
		lab:setColor(MColor.lable_yellow)
		lab:enableOutline(cc.c4b(0,0,0,255),1)
		local timeToStartPic = MakeNumbers:create("res/component/number/3.png", time, -2)
		timeToStartPic:setPosition(cc.p(display.cx, display.cy+ 50))
		if time >= 10 then
			timeToStartPic:setPosition(cc.p(display.cx - 15, display.cy + 50))
		end
		timeToStartPic:setAnchorPoint(cc.p(0.5, 0.5))
		node:addChild(timeToStartPic)
		time = time - detime
	end

	timer = startTimerActionEx(self, 1, true, timeShow)
	timeShow(1)
end

function BaseMapScene:checkFactionFire(facId, facName)
	if facId ~= MRoleStruct:getAttr(PLAYER_FACTIONID) then
		self.map_layer.inviteFactionId = facId
	end

	startTimerAction(self, 2, false, function() 
		--g_msgHandlerInst:sendNetDataByFmtExEx(FACTIONAREA_CS_FIRE_STATUS, "ii", G_ROLE_MAIN.obj_id, require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID))
		local t = {}
		t.factionID = facId
		g_msgHandlerInst:sendNetDataByTableExEx(FACTIONAREA_CS_FIRE_STATUS, "FactionAreaFireStatusPtotocol", t)
	end)
end

function BaseMapScene:shaWarMykillNum(num)
	local KillSpr= self:getChildByName("KillSpr")
	if KillSpr then
		removeFromParent(KillSpr)
	end

	if num > 0 then
		local setMidPosition = function(params)
            local nodes = params.nodes
            local centerWidth = params.width

            local totalWidth = 0
            for i=1,#nodes do
                totalWidth = totalWidth + nodes[i]:getContentSize().width
            end

            local currPosition = 0
            local starPosition = centerWidth/2 - totalWidth/2
            for i=1,#nodes do
                nodes[i]:setPositionX(starPosition + currPosition)
                nodes[i]:setAnchorPoint( cc.p(0, nodes[i]:getAnchorPoint().y) )
                currPosition = currPosition + nodes[i]:getContentSize().width
            end
        end

		KillSpr = createSprite(self, "res/mainui/killNum/bg.png")
		KillSpr:setName("KillSpr")
		KillSpr:setLocalZOrder(600)
		KillSpr:setPosition(cc.p(g_scrSize.width* 700/960, g_scrSize.height*490/640))
		local posY = KillSpr:getContentSize().height/2

		local params = {width = KillSpr:getContentSize().width , nodes = {}}
		local numSprCreate = function(num)
			if num < 0 or num > 9 then 
				return 
			end
			local tempSpr = createSprite(KillSpr, "res/mainui/killNum/" .. num .. ".png", cc.p(0, posY))
			params.nodes[#params.nodes + 1] = tempSpr
		end

		local numTab = {}
		for i=1, 4 do
			numTab[i] = {}
			numTab[i].index = i
			if num >= 10 then
				numTab[i].value = num%10
				num = math.floor(num/10)
			else
				numTab[i].value = num
				break
			end
		end

		table.sort( numTab, function(a, b) return a.index > b.index end)

		for i=1, #numTab do
			numSprCreate(numTab[i].value)
		end
		local spr3 = createSprite(KillSpr, "res/mainui/killNum/title.png", cc.p(0, posY))
		params.nodes[#params.nodes + 1] = spr3
		setMidPosition(params)

		KillSpr:setScale(0.1)
		KillSpr:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1)))
		performWithDelay(KillSpr, function() removeFromParent(KillSpr) end, 5)
	end
end

function BaseMapScene:updateSkyArena(param)
	if self.map_layer then
		if self.map_layer.isSkyArena then
			self.map_layer:updateSA(param)
		end
	end
end

function BaseMapScene:addTsxlEffect(value)
	if value then
		if (not self.tslx_effect) then
			self.tslx_effect = Effects:create(false)
			self.tslx_effect:setPosition(cc.p(g_scrSize.width/2,60))
			self.tslx_effect:playActionData2("autoblood",200,-1,0)
			addEffectWithMode(self.tslx_effect,2)
			self:addChild(self.tslx_effect,100)
		end
	elseif self.tslx_effect then
		removeFromParent(self.tslx_effect)
		self.tslx_effect = nil
	end
end

function BaseMapScene:showBagAddItemTips(new_grid, old)
	if not new_grid or not new_grid.mPropProtoId then return end
	local pack = MPackManager:getPack(MPackStruct.eBag)
	--local num = pack:countByProtoId(new_grid.mPropProtoId)

	-- dump(new_grid, "new_grid")
	-- dump(old, "old")
	if new_grid and (not old or old.mNumOfOverlay < new_grid.mNumOfOverlay)then
		local msg_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{ 1 , 2 })
		if msg_item  then
			local oldNum = old and old.mNumOfOverlay or 0
			local objNum = new_grid.mNumOfOverlay - oldNum
			--print(" +++++++++++++++++++++++++++ ", new_grid.mPropProtoId, objNum)
			if objNum and objNum > 0 then
				TIPS( { type = msg_item.tswz , str = msg_item.msg , numOrId = { new_grid.mPropProtoId } , objNum = objNum} )
			--else
			--	TIPS( { type = msg_item.tswz , str = msg_item.msg , numOrId = { new_grid.mPropProtoId } } )
			end
		end
	end
end

function BaseMapScene:isStoryMap(mapId)
    if mapId == nil or G_MAINSCENE == nil or G_MAINSCENE.map_layer == nil then
        return false
    end

    return G_MAINSCENE.map_layer:isStoryMap(mapId)

    --if mapId == 1000 or mapId == 2116 or mapId == 2117 or mapId == 2118 or mapId == 2119 or mapId == 2134 or mapId == 2135 or 
    --   mapId == 5001 or mapId == 5002 or mapId == 5004 or mapId == 5006 or mapId == 5007 or mapId == 5009 or mapId == 5018 or mapId == 5019 then
    --    return true
    --end

    --return false
end

return BaseMapScene
