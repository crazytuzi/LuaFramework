local BaseMapNetNode = class("BaseMapNetNode", function() return cc.Scene:create() end)
local commConst = require("src/config/CommDef")
local MPropOp = require "src/config/propOp"
function BaseMapNetNode:registerMsgHandler()
	local msgids = {SKILL_SC_LOADSKILL,SKILL_SC_SKILLUPDATE,FRAME_SC_MESSAGE,FRAME_GW_HEART_BEAT,
					FRAME_SC_PICKUP,FRAME_SC_PROP_UPDATE,LITTERFUN_SC_NOTIFY_MONEYTREE,PUSH_SC_RED_MARK,COPY_SC_GETCOPYTOWERDATA_RET,
					RELATION_SC_BE_FRIEND,SKILL_SC_DELETESKILL,SKILL_SC_CLEAR_COOL,COMMON_SC_GETMAINOBJECT_RET,ITEM_SC_USEMATERIAL}
	require("src/MsgHandler").new(self,msgids,nil)
	self:getNetData()

    self.m_isPlayingNotice = false;
    -- 公告数据临时队列
    self.m_notice = require("src/List"):new();
end

function BaseMapNetNode:CheckNoticePlay()
    if self.m_notice ~= nil and self.m_notice:IsEmpty() == false then
        local tmpTipsData = self.m_notice:PopRight();
        if tmpTipsData ~= nil then
            TIPS(tmpTipsData);
            self.m_isPlayingNotice = true;
            return;
        end
    end

    self.m_isPlayingNotice = false;
end

function BaseMapNetNode:getNetData()

	if activityDelayFun == nil then
		activityDelayFun = function(obj_id)
		 	if not G_ROLE_MAIN then
		 		return
		 	end	

    		local platform = sdkGetPlatform()
    		local LoginScene = require("src/login/LoginScene")
    		local pandoraType = ""
    		if platform == 1 then
       		 	--pandoraSDK
        		pandoraType = "wx"
    		elseif platform == 2 then
        		--pandoraSDK
        		pandoraType = "qq"
    		end

    		local payZoneid = tostring(userInfo.serverId) .. "_" .. tostring(userInfo.currRoleStaticId)
	 	    require("src/PandoraFunction")
	 	    G_isInMainScene = true
	 	    local c_roleName = require("src/layers/role/RoleStruct"):getAttr(ROLE_NAME)
	 	    if c_roleName == nil then
	 	    	c_roleName = " "
	 	    end
    		PandoraLogin(isAndroid(),LoginScene.VERSION,sdkGetOpenId(),sdkGetArea(),userInfo.serverId,userInfo.currRoleStaticId,payZoneid,string.format(c_roleName),sdkGetPayToken(),"1105148805",LoginScene.user_pwd,pandoraType)
   			print("suzhen pandora login,with values: " .. "accessToken is " .. LoginScene.user_pwd .. " and roleName is " .. c_roleName)
			--LoadRecvRedBagInfo()
			g_msgHandlerInst:sendNetDataByTableExEx( ACTIVITY_NORMAL_CS_FIND_REWARD_LIST , "ActivityNormalFindRewardList", {} ) --请求找回数据
			
			if DATA_Mission then DATA_Mission:checkBranchData() end--初始化密令任务
			g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_GET_FINISH_BRANCH, "GetFinishBranchProtocol", {})

	      	local function getcurrOfflineLayer(buff)
	      		G_OFFLINE_DATA.currLayer = buff:popShort()
	      		if self.refreshOfflineRedDot then self:refreshOfflineRedDot() end
	      	end
		    g_msgHandlerInst:registerMsgHandler( OFFLINE_SC_SENDOFFLAYER , getcurrOfflineLayer )
		    g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETCOPYTOWERDATA, "CopyGetTowerDataProtocol", {})

            --请求语聊数据
            g_msgHandlerInst:sendNetDataByTable(APOLLO_CS_AUTHKEY, "ApolloAuthKeyProtocol", {});
            cclog("yuexiaojun sendNetDataByTable APOLLO_CS_AUTHKEY")

            -- 请求屠龙传说数据
            DragonData:SendSingleInstanceData();

            local function getNormalData()
	            g_msgHandlerInst:sendNetDataByTableExEx( ACTIVITY_NORMAL_CS_REQ , "ActivityNormalReq" , { tab = 1 } )
	            g_msgHandlerInst:sendNetDataByTableExEx( ACTIVITY_NORMAL_CS_REQ , "ActivityNormalReq" , { tab = 2 } )
	            g_msgHandlerInst:sendNetDataByTableExEx( ACTIVITY_NORMAL_CS_REQ , "ActivityNormalReq" , { tab = 3 } )
	            g_msgHandlerInst:sendNetDataByTableExEx( ACTIVITY_NORMAL_CS_REQ , "ActivityNormalReq" , { tab = 4 } )
            end
            getNormalData()
            --请求活跃度宝箱数据
            g_msgHandlerInst:sendNetDataByTableExEx( ACTIVITY_NORMAL_CS_ACTIVENESS_REQ , "ActivityNormalActivenessReq" , {} )
            local function normalChange( buff )
            	local t = g_msgHandlerInst:convertBufferToTable( "ActivityNormalStateChange" , buff ) 
            	-- flag=1等级，flag=2行会，level对应等级值(行会暂不做处理)
            	--日常按钮有红点不请求
            	if t.flag == 1 and G_TOP_STATE and G_TOP_STATE[ "Battle" ] and G_TOP_STATE[ "Battle" ][ "isRed" ] == false then getNormalData() end
            end
            g_msgHandlerInst:registerMsgHandler( ACTIVITY_NORMAL_SC_STATE_CHANGE , normalChange ) 

		    activityDelayFun = false
	    	if DATA_Activity then DATA_Activity:initRollTips() end
	    	
	    	if DATA_Battle then 
	    		DATA_Battle:resetTime( DATA_Battle:setRecord( "r" , "todayNum" ) ) --获取本地记录并设置
	    		DATA_Battle:beginTime( game.getAutoStatus()  ) 
	    	end
	    end
	end

end

function BaseMapNetNode:onPickUp(luaBuffer)
	--cclog("==========================BaseMapScene:onPickUp")
	local proto = g_msgHandlerInst:convertBufferToTable("FramePickUpRetProtocol", luaBuffer) 
	local objType,numOrId,objNum = proto.type,proto.value,proto.num
	--cclog("picked! objType:"..objType.."numOrid:"..numOrId)
	if objType == commConst.ePickUp_XP and self.map_layer then
		self.map_layer:showExpNumer(numOrId,nil,0.1,"res/mainui/number/4.png" , commConst.ePickUp_XP )
	elseif objType == commConst.ePickUp_Prestige and self.map_layer then
		--声望展示
		self.map_layer:showExpNumer(numOrId,nil,0.1,"res/mainui/number/5.png" , commConst.ePickUp_Prestige)

	elseif objType == commConst.ePickUp_Money then
		AudioEnginer.playEffect("sounds/actionMusic/104.mp3",false) --拾取金币音效
		-- self.sysInfoPanel:addSysInfo("您获得"..numOrId.."金币")
		-- local msg_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{ 1 , 1 })
		-- if msg_item  then
		-- 	local msgStr = string.format( msg_item.msg , numOrId )
		-- 	TIPS( { type = msg_item.tswz , str = msgStr } )
		-- end
		
		if objNum and objNum >= 1 then
			local msg_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{ 1 , 2 })
			if msg_item  then
				TIPS( { type = msg_item.tswz , str = msg_item.msg , numOrId = { numOrId } , objNum = objNum} )
			end
		else
			local msg_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{ 1 , 1 })
			if msg_item  then
				local msgStr = string.format( msg_item.msg , numOrId )
				TIPS( { type = msg_item.tswz , str = msgStr } )
			end
		end					
	else
		if numOrId == 2001 or numOrId == 2002 then
			AudioEnginer.playEffect("sounds/actionMusic/104.mp3",false) --拾取金砖金条音效
		elseif numOrId >= 20020 and numOrId <= 20038 then
			AudioEnginer.playEffect("sounds/actionMusic/105.mp3",false)
		-- elseif math.floor(numOrId / 1000000) == 5 then
		-- 	AudioEnginer.playEffect("sounds/actionMusic/35.mp3",false)
		-- else
		-- 	AudioEnginer.playEffect("sounds/actionMusic/35.mp3",false)
		end
		-- local msg_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{ 1 , 2 })
		-- if msg_item  then
		-- 	--local msgStr = string.format( msg_item.msg , numOrId )
		-- 	if objNum and objNum > 1 then
		-- 		TIPS( { type = msg_item.tswz , str = msg_item.msg , numOrId = { numOrId } , objNum = objNum} )
		-- 	else
		-- 		TIPS( { type = msg_item.tswz , str = msg_item.msg , numOrId = { numOrId } } )
		-- 	end			
		-- end
	end
end

function BaseMapNetNode:onDressUpdate(id,isMe, roleId, g_id,event)
	--local MPackManager = require "src/layers/bag/PackManager"
	--print("id"..id.."值："..tostring(g_id))

    if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then--公平竞技场外观都一样
        return
    end
	local MPropOp = require "src/config/propOp"
	if id == PLAYER_EQUIP_WEAPON or id == PLAYER_EQUIP_UPPERBODY or id >= PLAYER_EQUIP_WING then
		if id >= PLAYER_EQUIP_WING and g_id == 0 then
			event = "-"
		end
		local func = function()
			local role = nil
			if isMe then
				role = G_ROLE_MAIN
			elseif self.map_layer and self.map_layer.item_Node then
				role = tolua.cast(self.map_layer.item_Node:getChildByTag(roleId),"SpritePlayer")
			end
			if not role then return end
			local add_id ,special_body = 0,nil
			if role:getOnRide() then
				add_id = 1000
				-- if role:getIsOnHighRide() then
				-- 	special_body = 6001505 
				-- end
			end
			if event ~= "-" then
				local w_resId = nil
				local  ride_id = 1
				if id < PLAYER_EQUIP_WING then
					w_resId = MPropOp.equipResId(g_id)
				end
				--w_resId = w_resId or 2  -- 待光翼资源id修改
				if w_resId and w_resId > 0 or id >= PLAYER_EQUIP_WING then
					if id == PLAYER_EQUIP_UPPERBODY then
                        if G_ROLE_MAIN ~= nil then
						    if not special_body then
							    --w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_UPPERBODY,w_resId+role:getSex()*100000+add_id)
							    local r_path = "role/" .. (w_resId+role:getSex()*100000+add_id)
							    role:setBaseUrl(r_path)
						    else
							    role:setBaseUrl("role/" .. (special_body+role:getSex()*100000))
						    end
                        end
					elseif id == PLAYER_EQUIP_WEAPON then
                        if G_ROLE_MAIN ~= nil then
						    --w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WEAPON ,w_resId)
						    local w_path = "weapon/" .. (w_resId)
			      		    G_ROLE_MAIN:setEquipment_ex(role,PLAYER_EQUIP_WEAPON,w_path)
                        end
			      	elseif id == PLAYER_EQUIP_WING then
                        if G_ROLE_MAIN ~= nil then
			      		    w_resId = getConfigItemByKey("WingCfg","q_ID",g_id,"q_senceSouceID")
			      		    w_resId = w_resId+100000+add_id --G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WING,w_resId+100000+add_id)
			      		    if special_body then w_resId = w_resId + 1000 end
			      		    local w_path = "wing/" .. (w_resId)
			      		    G_ROLE_MAIN:setEquipment_ex(role,PLAYER_EQUIP_WING,w_path)
                        end
			      	elseif id == PLAYER_EQUIP_RIDE then
			      		--print("g_idg_id："..g_id)
                        if G_ROLE_MAIN ~= nil then
			      		    G_ROLE_MAIN:upOrDownRide_ex(role,g_id,true,true)
                        end
			      	end
		      	end
			else
				if id == PLAYER_EQUIP_UPPERBODY then
					role:setBaseUrl( "role/" .. g_normal_close_id+role:getSex()*100000+add_id)
				elseif id == PLAYER_EQUIP_RIDE then
					if G_ROLE_MAIN then
						G_ROLE_MAIN:upOrDownRide_ex(role,nil,nil,true)
					end
				else
					role:removeActionChildByTag(id)
				end
			end
			role:reloadRes()
		end
		func()
		-- if G_ROLE_MAIN and roleId == G_ROLE_MAIN.obj_id then 
		-- 	func()
		-- elseif tolua.cast(self.map_layer.item_Node:getChildByTag(roleId),"SpritePlayer") then
		-- 	func()
		-- else
		-- 	local delay_time = 0
		-- 	local doCheckFunc = function()
		-- 	end
		-- 	doCheckFunc = function()
  --               if self.map_layer == nil then
  --                   return;
  --               end
		-- 		if tolua.cast(self.map_layer.item_Node:getChildByTag(roleId),"SpritePlayer") then
		-- 			func()
		-- 		else
		-- 			if delay_time < 3 then
		-- 				performWithDelay(self,doCheckFunc,0.5)
		-- 			end
		-- 			delay_time = delay_time + 1;
		-- 		end
		-- 	end
		-- 	if self.map_layer and self.map_layer.item_Node then
		-- 		performWithDelay(self.map_layer.item_Node,doCheckFunc,0.5)
		-- 	end
		-- end
		
	end
end

function BaseMapNetNode:onBuffUpdate(id,isMe, roleId, buffs)
	local buffs = buffs or g_buffs[roleId]
	if self.map_layer and self.map_layer.onBuffUpdate then
		self.map_layer:onBuffUpdate(roleId,buffs)
		if G_ROLE_MAIN and roleId == G_ROLE_MAIN.obj_id then
			G_BUFF_TIME = os.time()
			require("src/layers/buff/BuffLayer").need_refresh = true
		end
	end
end

function BaseMapNetNode:onEnterMapScene(proto,params,first_enter)
	--cclog("BaseMapScene:onEnterMapScene-------------------------------")
	--local isMe,objId,mapId,posX,posY,objType,attrNum = luaBuffer:readByFmt("bissscs")
	--TimeProfile:funcBegin()
	local isMe,objId,mapId,posX,posY,objType = params[1],params[2],params[3],params[4],params[5],params[6]
	--print("[BaseMapNetNode:onEnterMapScene] "..tostring(isMe).." "..objId.." "..mapId.." "..posX.." "..posY.." "..objType)
	local entity = {}
	local item_node = nil
	local buffFunc = nil
	for k,v in pairs(proto.props) do
		local id = v.propId --luaBuffer:popChar()
		local callback = nil
		if  id == ROLE_BUFF then
			callback = function(attrId, objId,isMe, buffs)
				buffFunc = function() self:onBuffUpdate(attrId,isMe,objId, buffs) end
			end
		elseif id == PLAYER_HOLD_MAT then
			local tab = {}
			local matTable = protobuf.decode("HoldMatProtocol", v.propString)
			if matTable and matTable.mats then
				for key,value in pairs(matTable.mats)do 
					tab[key] = {matId = value.itemID,cout = value.itemNum,time = os.time()+ value.remainTime}
				end
				entity[id] = tab
			end
		end
		if id ~= PLAYER_HOLD_MAT then

			entity[id] = MRoleStruct:setAttr(id, objId, v, isMe, callback)
		end
		--if isMe then print("attr id:"..id,v.propInt,v.propString,entity[id]) end
	end
	--TimeProfile:step("step1")
	if objType == commConst.eClsTypePlayer then
		local player_factionid = entity[PLAYER_FACTIONID]
		local player_factionname = entity[PLAYER_FACTIONNAME]

		if isMe then
			local player_pattern = entity[PLAYER_PATTERN]
			local palyer_battle = entity[PLAYER_BATTLE]

			if player_pattern and self.attackmode_node then
				require("src/layers/pkmode/PkModeLayer"):setCurMode(player_pattern)
				self.attackmode_node:setImages("res/mainui/pkmode/"..(player_pattern+1)..".png")

                if self.m_pkModeLal then
                    local pkModeStrs = {
                        game.getStrByKey("pkmode_heping_str"),
                        game.getStrByKey("pkmode_zudui_str"),
                        game.getStrByKey("pkmode_banghui_str"),
                        game.getStrByKey("pkmode_quanti_str"),
                        game.getStrByKey("pkmode_shane_str"),
                        game.getStrByKey("pkmode_gongsha_str")
                    }
                    self.m_pkModeLal:setString(pkModeStrs[player_pattern+1]);
                end
			end
			if player_factionid and player_factionname then
		      G_FACTION_INFO.id = player_factionid
		      if G_FACTION_INFO.id > 0 then
		        G_FACTION_INFO.facname = player_factionname
		      else
		        G_FACTION_INFO.facname = nil
		      end
			end
	 		if palyer_battle then
	 			self:addBattleNum(palyer_battle)
			end
			local mapInfo = getConfigItemByKey("MapInfo","q_map_id",mapId)

			if mapInfo==nil then
				cclog("no map data found,mapip:"..mapId)
				return
			end

            if g_msgHandlerInst ~= nil then
            	g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_GET_TEAMINFO, "TeamGetTeamInfoProtocol", {})
            end

			if first_enter then -- 新地图
				--print("first enter"..mapId)
				local map_name = mapInfo.q_map_name
				if userInfo and userInfo.lastFbType == 3 and mapId == 5100 then
					local fbId = userInfo.lastFb
					local itemDate = getConfigItemByKey("FBTower", "q_id", fbId)
					if itemDate and itemDate.q_copyLayer then
						map_name = map_name .. string.format(game.getStrByKey("fb_layer"), tonumber(itemDate.q_copyLayer or 1))
					end
				end

				if self.mapName then
					self.mapName:setString(map_name)
				end
				self:initialize(objId)
				local level = entity[ROLE_LEVEL]
                ---------------------------屏蔽欢迎页--------------------------------------
				--if level==1 and mapId == 1100 then
					--require("src/layers/welcome/WelcomeLayer").new(self)
				--end
                ---------------------------------------------------------------------------
				if mapId == 2113 and self.map_layer then
					self.map_layer:setNpcState(10398, 1)
				end

				self.curr_exp = entity[PLAYER_XP]
				if G_ROLE_MAIN then
					local role = G_ROLE_MAIN
					item_node = G_ROLE_MAIN
					level = MRoleStruct:getAttr(ROLE_LEVEL)
					self.curr_exp = self.curr_exp or role.base_data.curr_exp or 0
					local p_x,p_y = posX,posY
					self.map_layer:makeMainRole(p_x,p_y,true,3,isMe,objId,entity)
					local cb = function()
						local battle_num = MRoleStruct:getAttr(PLAYER_BATTLE)
						self:resetHeadInfo(role.base_data.name)
						handlerMultiFunc(MONEY_GOLD_UPDATE)
						self:addBattleNum(battle_num)
						self:refreshOfflineRedDot(level,battle_num)
						if userInfo.lastFBScene and tonumber(mapInfo.q_map_zones) ~= 1 then--副本
		                    local sub_node
		                    local tag = nil
		                    if userInfo.lastFBScene == 3 and userInfo.connStatus == CONNECTED then
		                    	if g_EventHandler["FbTowerFailCallBack"] then
		                    		g_EventHandler["FbTowerFailCallBack"]()
		                    		g_EventHandler["FbTowerFailCallBack"] = nil
		                    	else
		                    		__GotoTarget({ru = "a128"})
		                    	end
		                    elseif userInfo.lastFBScene == commConst.CARBON_MULTI_GUARD then
		                    	if g_EventHandler ~= nil and g_EventHandler["FbMultiFailCallBack"] then
		                    		g_EventHandler["FbMultiFailCallBack"]()
		                    		g_EventHandler["FbMultiFailCallBack"] = nil
                                end
                            elseif userInfo.lastFBScene == commConst.CARBON_DRAGON_SLIAYER then
                                if g_EventHandler ~= nil and g_EventHandler["FbDragonFailCallBack"] then
		                    		g_EventHandler["FbDragonFailCallBack"]()
		                    		g_EventHandler["FbDragonFailCallBack"] = nil
                                end

                                -- 主动打开屠龙传说界面
                                DragonData.DRAGON_SLIAYER_WINDOW = false;
                                __GotoTarget{ ru="a127" }
                      		elseif userInfo.lastFBScene == commConst.CARBON_MINE then
                            	if g_EventHandler ~= nil and  g_EventHandler["FbRobMineFailCallBack"] then
                            		g_EventHandler["FbRobMineFailCallBack"]()
                            		g_EventHandler["FbRobMineFailCallBack"] = nil
                            	end

                                -- 主动打开屠龙传说界面
                                DragonData.DRAGON_SLIAYER_WINDOW = false;
                                __GotoTarget{ ru="a127" }
                            elseif userInfo.lastFBScene == commConst.CARBON_PRINCESS then
                                -- 主动打开屠龙传说界面
                                DragonData.DRAGON_SLIAYER_WINDOW = false;
                                __GotoTarget{ ru="a127" }
                            -- 针对小红点, 再调整屠龙传说数据
		                    elseif userInfo.lastFBScene == 9 then
		                    	__GotoTarget({ ru = "a4", mode = userInfo.lastJJCMode or 1 })
		                    elseif userInfo.lastFBScene == commConst.CARBON_DART then
		                    	DragonData.DRAGON_SLIAYER_WINDOW = false;
                                __GotoTarget{ ru="a127" }
		                    end
		                    if sub_node then
		                       getRunScene():addChild(sub_node,200)
		                       if tag then
		                       		sub_node:setTag(tag)
		                       end
		                    end
		                end

		                if tonumber(mapInfo.q_map_zones) ~= 1 and g_EventHandler ~= nil and g_EventHandler["normalFbFailCallBack"] then
		                	g_EventHandler["normalFbFailCallBack"]()
                            g_EventHandler["normalFbFailCallBack"] = nil
		               	end

		                if self.map_layer.isfb then
		                    userInfo.lastFBScene = userInfo.lastFbType or tonumber(getLocalRecordByKey(2,"lastFbType")) or 1;
                            if userInfo.lastFBScene == commConst.CARBON_DRAGON_SLIAYER then
                                -- 第一波主动提示, 自动寻路
                                self.map_layer:showNextCircleMonsterWay();
                            end
		                elseif self.map_layer.isJjc then
		                	userInfo.lastFBScene = 9
		                else
		                    userInfo.lastFBScene = nil
		                end


                        -- 切换 Scene 可能导致 newskillconfiglayer 关闭
                        if g_EventHandler and g_EventHandler["newSkillConfig"] then
                            local tmpLua = require("src/layers/skillToConfig/newSkillConfigLayer");
                            if tmpLua then
                                local tmpLayer = tmpLua.new(g_EventHandler["newSkillConfig"]);
                                if tmpLayer ~= nil and self.base_node ~= nil then
                                    self.base_node:addChild(tmpLayer, 100);
                                end
                            end

                            g_EventHandler["newSkillConfig"] = nil;
                        end
					end
					performWithDelay(self, cb, 0.0)

					if self.nfTriggerNode then
						self.nfTriggerNode:check()
					end
				end

				
		
				self.total_exp = getConfigItemByKeys("roleData", {
			        "q_zy",
			        "q_level",
			      },{MRoleStruct:getAttr(ROLE_SCHOOL) or 1,level},"q_exp")
				self.curr_exp = self.curr_exp or 0
				self.total_exp = self.total_exp or self.curr_exp
                if self.total_exp == 0 then
                    self.total_exp = 1
                end
				--if entity[ROLE_MODEL] then userInfo.currRoleStaticId = entity[ROLE_MODEL] end
				--print("sssssssssssssssssssssssssssssssss" .. userInfo.currRoleStaticId)
				local percentage = self.curr_exp*100/self.total_exp
				--cclog("percentage"..percentage.."self.total_exp"..self.total_exp)
				self.exp_process:setPercentage(percentage)
				self.exp_label:setString(""..self.curr_exp.."/"..self.total_exp.." ("..math.floor(percentage).."%)")
				local name = entity[ROLE_NAME]
				if G_ROLE_MAIN then name = nil end	
				if G_ROLE_MAIN then
					G_ROLE_MAIN:setCarry_ex(G_ROLE_MAIN, {})
					G_ROLE_MAIN:setBanner(G_ROLE_MAIN, 0)
				end				
				self:resetHeadInfo(name,tostring(level))

				if self.tutoNode then
					self.tutoNode:checkCfgData()
				end
			elseif G_ROLE_MAIN then -- 复活
				self.map_layer.role_tab[G_ROLE_MAIN:getTag()] = nil
				G_ROLE_MAIN:setTag(objId)
				G_ROLE_MAIN:setRoleId(objId)
				self.map_layer.role_id = objId
				item_node = G_ROLE_MAIN
				--G_ROLE_MAIN.up_ride=nil
				--if G_ROLE_MAIN.setOnRide then G_ROLE_MAIN:setOnRide(false) end 
				self.map_layer:makeMainRole(posX,posY,nil,3,isMe,objId,entity)
				self:initialize(objId)
				if mapId == 3130 then
					local pk = MRoleStruct:getAttr(PLAYER_PK)
					if pk >= 6 then
						messageBox(game.getStrByKey("tip_pk_revive"))
					end
				end	
			else
				return 
			end
			if entity[ROLE_HP] and entity[ROLE_HP] == 0 then
				if self.map_layer then
					self.map_layer:showReliveLayer(objId)
				end
			end
			if self.nfTriggerNode and entity[ROLE_LEVEL] then
				self.nfTriggerNode:check(entity[ROLE_LEVEL])
			end

			

		end
		--TimeProfile:step("step2")
		if entity[ROLE_SCHOOL] and entity[PLAYER_SEX] then
			local dressFunc = function(role_item_node,ride_id,wing_id,weapon_id)
				if G_ROLE_MAIN and role_item_node then
					if ride_id and ride_id > 0 then
						local  w_resId = getConfigItemByKey("RidingCfg","q_ID",ride_id,"q_senceSouceID")
	                    if w_resId and G_ROLE_MAIN then -- 空值校验
						    G_ROLE_MAIN:upOrDownRide_ex(role_item_node,ride_id,true,true)
	                    end
					else
    					local need_reload = false
						if wing_id and wing_id>0 then
					      	local w_resId = getConfigItemByKey("WingCfg","q_ID",wing_id,"q_senceSouceID")
					      	if w_resId and G_ROLE_MAIN then -- 空值校验
						      	--w_resId = G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WING,w_resId+100000)
						      	local w_path = "wing/" .. (w_resId+100000)
						      	G_ROLE_MAIN:setEquipment_ex(role_item_node,PLAYER_EQUIP_WING,w_path)
						      	need_reload = true
						    end
						end
						if weapon_id and weapon_id > 0 then
						    local w_resId = MPropOp.equipResId(weapon_id)--G_ROLE_MAIN:getRightResID(PLAYER_EQUIP_WEAPON ,MPropOp.equipResId(weapon_id))
						    local w_path = "weapon/" .. (w_resId)
			      		    G_ROLE_MAIN:setEquipment_ex(role_item_node,PLAYER_EQUIP_WEAPON,w_path)
			      		    need_reload = true
					    end
					    if need_reload then
					    	role_item_node:reloadRes()
					    end
					end
				end
			end
			if isMe then
				if not G_ROLE_MAIN then
					local w_resId = g_normal_close_id
					if entity[PLAYER_EQUIP_UPPERBODY] then w_resId = MPropOp.equipResId(entity[PLAYER_EQUIP_UPPERBODY]) end
					--local roleSprite = require("src/base/RoleSprite")
					w_resId = w_resId+entity[PLAYER_SEX]*100000-- roleSprite:getRightResID(PLAYER_EQUIP_UPPERBODY,w_resId+entity[PLAYER_SEX]*100000)
					item_node = self.map_layer:makeMainRole(posX,posY,"role/" .. w_resId,3,isMe,objId,entity)
					dressFunc(item_node,entity[PLAYER_EQUIP_RIDE],entity[PLAYER_EQUIP_WING],entity[PLAYER_EQUIP_WEAPON])
					local head_node = tolua.cast(self.head_node:getChildByTag(55),"TouchSprite")
					head_node:setSpriteFrame(getSpriteFrame("mainui/head/"..(entity[ROLE_SCHOOL]+(entity[PLAYER_SEX]-1)*3)..".png"))
					--head_node:setTexture("res/mainui/head/"..(entity[ROLE_SCHOOL]+(entity[PLAYER_SEX]-1)*3)..".png")
				end
				G_ROLE_MAIN.currGold = entity[PLAYER_MONEY] or 0
				G_ROLE_MAIN.currBindGold = entity[PLAYER_BINDMONEY] or 0
				G_ROLE_MAIN.currIngot = entity[PLAYER_INGOT] or 0
				G_ROLE_MAIN.currBindIngot = entity[PLAYER_BINDINGOT] or 0
				--handlerMultiFunc(MONEY_GOLD_UPDATE)
				local cb = function()
					handlerMultiFunc(MONEY_GOLD_UPDATE)
				end
				performWithDelay(self, cb, 0.0)
				-- 新功能开启初始化
				if entity[ROLE_LEVEL] then
					self.nfTriggerNode:init()
				end	
				-- SDK信息统计
				if BaseMapNetNode.first_login then
					-- SDK信息统计
					local function onEnterGame()
						BaseMapNetNode.first_login = nil
						--local target = cc.Application:getInstance():getTargetPlatform()
						local info = {}
						info.userId = tostring(userInfo.currRoleStaticId)
						info.serverId = getLocalRecordByKey(1,"lastServer")
						info.lv = MRoleStruct:getAttr(ROLE_LEVEL)
						info.serverName = getLocalRecordByKey(2,"lastServerName")
						info.roleName = MRoleStruct:getAttr(ROLE_NAME)
						info.vipLevel = (G_VIP_INFO and G_VIP_INFO.vipLevel) or 0
						info.factionName = (G_FACTION_INFO and G_FACTION_INFO.facname) or ""
						info.isNewRole = (not not G_ONCREATE_GAME)
						
						local extraInfo = {}
						extraInfo.gift_card_ID = tostring(G_Gift_Card_ID or 0)
						--dump(extraInfo, "extraInfo")
						info.extraInfo = require("json").encode(extraInfo)
						--print("onEnterGame")
						if Device_target == cc.PLATFORM_OS_ANDROID then
							local json_text = require("json").encode(info)
							local args = { json_text }
							local className = "org/cocos2dx/lua/AppActivity"
							local methodName = "onEnterGame"
							local sig = "(Ljava/lang/String;)V"
							local ok, ret = callStaticMethod(className, methodName, args, sig)
						elseif Device_target ~= cc.PLATFORM_OS_WINDOWS then
							local className = "channel_ios"
							info.type = "onEnterGame"
							local ok,ret  = callStaticMethod(className,"call",info)
						end
					end
					--performWithDelay(self,onEnterGame,3)	
				end	
				if entity[PLAYER_LINE] then
					self:addLineNode(entity[PLAYER_LINE])
				end
				setRoleInfo(3, userInfo.currRoleStaticId, entity[ROLE_LEVEL], entity[ROLE_SCHOOL], entity[ROLE_NAME])
			else
				--if G_TEST == 1 then return end
				--TimeProfile:step("step55")
				local w_resId = g_normal_close_id
				if entity[PLAYER_EQUIP_UPPERBODY] then w_resId = MPropOp.equipResId(entity[PLAYER_EQUIP_UPPERBODY]) end
				--local roleSprite = require("src/base/RoleSprite")
				w_resId = w_resId+entity[PLAYER_SEX]*100000 --roleSprite:getRightResID(PLAYER_EQUIP_UPPERBODY,w_resId+entity[PLAYER_SEX]*100000)
				item_node = self.map_layer:makeMainRole(posX,posY,"role/" .. w_resId,3,isMe,objId,entity)
				dressFunc(item_node,entity[PLAYER_EQUIP_RIDE],entity[PLAYER_EQUIP_WING],entity[PLAYER_EQUIP_WEAPON])
				if item_node then
				    self:changeHoldDirByRoleID(objId)
				end
				--TimeProfile:step("step56")
			end
		else
			cclog("unknown schoool or sex")
		end
		if buffFunc then
			buffFunc()
		end
		buffFunc = nil
		--TimeProfile:step("step3")
		--if true then return end
		if isMe and self.map_layer then self.map_layer:ShaWarTransforCheck() end
		if not item_node then 
            print("create Role item faild ")
			local callback = function()
				globalInit()
				game.ToLoginScene()
			end
			if isMe then
				MessageBox(game.getStrByKey("login_dataError"), game.getStrByKey("sure"), callback)
				return
			end
        end
        if not G_ROLE_MAIN then return end
		if entity[PLAYER_PK] then
			if objId == userInfo.currRoleId then
				self:changePlayColor()		
			else
				self:QryMonsterNameColor(objId)
			end
			--self:QryMonsterNameColor(objId)
			--G_ROLE_MAIN:setNameColor_ex(item_node, entity[PLAYER_PK])
		end
		if entity[PLAYER_TITLE] then    -- 空值校验
			G_ROLE_MAIN:setTitle_ex(item_node, entity[PLAYER_TITLE])
		end
		-- if entity[PLAYER_VIP] and G_ROLE_MAIN then
		-- 	G_ROLE_MAIN:setVip_ex(item_node, entity[PLAYER_VIP])
		-- end
		if player_factionid then
			if G_ROLE_MAIN then
                G_ROLE_MAIN:setCornerSign_ex(item_node,2,player_factionid)
            end
			--
			if objId == userInfo.currRoleId then
				self:changePlayColor()
			else
				self:QryMonsterNameColor(objId)
			end
		else
			--self:QryMonsterNameColor(objId)
			if objId == userInfo.currRoleId then
				self:changePlayColor()		
			else
				self:QryMonsterNameColor(objId)
			end
		end
		if player_factionname then
			G_ROLE_MAIN:setFactionName_ex(item_node, player_factionname)
		end
		if entity[PLAYER_TEAMID] then
			if G_MAINSCENE.map_layer then
				if G_MAINSCENE.map_layer.mapID == 2100 or G_MAINSCENE.map_layer.mapID == 5003 then
					G_ROLE_MAIN:setCar_ex(item_node,entity[PLAYER_TEAMID])
					self:QryMonsterNameColor(objId)
				end
			elseif G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
				self:set3V3NameColor(item_node, entity[PLAYER_TEAMID])
			end
		end
       
        if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
        	--如果有坐骑，先下来
        	G_ROLE_MAIN:upOrDownRide_ex(item_node,nil,nil,true)
            local clothesId,weaponId,wingId=G_MAINSCENE.map_layer:getclothes(entity[ROLE_SCHOOL],entity[PLAYER_SEX])
           	if isMe then
           		clothesId,weaponId,wingId=G_MAINSCENE.map_layer:getclothes(MRoleStruct:getAttr(ROLE_SCHOOL),MRoleStruct:getAttr(PLAYER_SEX))
           	end
           	item_node:setEquipments(clothesId,weaponId,wingId)
        end
		-- if entity[PLAYER_SERVER_ID] then
		-- 	G_ROLE_MAIN:setServer_ex(item_node, entity[PLAYER_SERVER_ID])
		-- end
		if entity[PLAYER_HOLD_MAT] then -- 空值校验
			G_ROLE_MAIN:setCarry_ex(item_node, entity[PLAYER_HOLD_MAT])
		end
		if entity[PLAYER_BANNER] then
			G_ROLE_MAIN:setBanner(item_node, entity[PLAYER_BANNER])		
		end
		if entity[PLAYER_HOLD_MINE] then
			G_ROLE_MAIN:setMine(item_node, entity[PLAYER_HOLD_MINE])
		end
		if entity[PLAYER_SPECIAL_TITLE_ID] then
			G_ROLE_MAIN:setSpecialTitle(item_node, entity[PLAYER_SPECIAL_TITLE_ID])
		end
		if entity[ROLE_MOVE_SPEED] then
		    local base_speed = getConfigItemByKeys("roleData", {
		        "q_zy",
		        "q_level",
		      },{1,1},"q_move_speed")/1000
		    if isMe then
				g_speed_time = base_speed/(entity[ROLE_MOVE_SPEED]/100)
				if g_speed_time < 0.08 then g_speed_time = 0.08 end
				--print("move time"..g_speed_time)
				item_node:setBaseSpeed(g_speed_time)
				if self.map_layer then
					self.map_layer:resetSpeed(g_speed_time)
	     		end
	     	else
	     		item_node:setBaseSpeed(base_speed)
		 		item_node:setSpeed(base_speed/(entity[ROLE_MOVE_SPEED]/100))
	     	end
	 	end
	 	if self.map_layer and self.map_layer.monster_head and self.map_layer.monster_head.monster_id == objId and tolua.cast(self.map_layer.monster_head,"cc.Node") then
			self.map_layer:touchRoleFunc(item_node)
		end	

		--滴血的矿石副本玩家名字颜色设置
		if isMe and mapId == 5008 and self.map_layer.setFbRoleNameColor then 
			--print("-----------------FbMapLayer:setFbRoleNameColor 2" ,G_ROLE_MAIN)
			self.map_layer:setFbRoleNameColor(item_node , MColor.name_orange)
		end
	 	--TimeProfile:step("step4")	
	elseif  objType == commConst.eClsTypeMonster then
		local addMonsterRole = function(datas)
			local tmpRole = createSceneRoleNode(datas)
            -- 朋友宠物可能会死亡跟随自己
            if entity[ROLE_HP] and entity[ROLE_HP] <= 0 then
                tmpRole:showNameAndBlood(false)
		        if entity[ROLE_SCHOOL] and entity[ROLE_SCHOOL] == 2 then
			        tmpRole:gotoDeath(6)
		        else
			        tmpRole:gotoDeath(7)
		        end
            else
                tmpRole:initStandStatus(4,6,1.0,4)
                tmpRole:standed()
                tmpRole:showNameAndBlood(true,80)
            end
            if datas[ROLE_DIR] then 
            	tmpRole:setSpriteDir(datas[ROLE_DIR])
            end
            tmpRole:setBaseSpeed(0.45)
            if entity[ROLE_MOVE_SPEED] then
		        tmpRole:setSpeed(0.45/(entity[ROLE_MOVE_SPEED]/100))
            else
                tmpRole:setSpeed(0.45)
		    end
			tmpRole:setIsMonsterRole(true)
            if self.map_layer.item_Node:getChildByTag(objId) then
			    self.map_layer.item_Node:removeChildByTag(objId)
            end

            -- 挖矿中用来表示敌人头顶上顶了多少矿
            if self.map_layer.mapID == 5008 and self.map_layer.setFbRoleNameColor then
            	self.map_layer:setFbRoleNameColor(tmpRole , MColor.name_orange)
            end
            if   self.map_layer.mapID == 5008 then
				-- entity[PLAYER_TEAMID] and
				local mineNum  = 1
            	if entity[PLAYER_TEAMID] then
            		 mineNum = tonumber(entity[PLAYER_TEAMID])
            	end
            	if G_ROLE_MAIN and mineNum and self.map_layer  then 
            		local allGetGoods = {}
            		for i=1,mineNum do
	        			local item = {}
					    item.matId = 6200032
					    item.time = os.time() + 50000
					    table.insert(allGetGoods , item)
            		end
				    G_ROLE_MAIN:setCarry_ex(tmpRole , allGetGoods)
            	end
            end

            self.map_layer.item_Node:addChild(tmpRole,posY,objId)
            tmpRole:setServerTilePosByTile(posX,posY)
			self.map_layer.role_tab[objId] = objId
			-- print("role_tab_obj_id" ,entity[ROLE_SCHOOL]  ,objId ,datas[ROLE_NAME])
			--self.map_layer.m_friendsData[objId] = self.map_layer.m_friendsData[objId] or objId
			return tmpRole
		end
		local monsterItem= getConfigItemByKey("monster","q_id",entity[ROLE_MODEL])
		if entity[ROLE_MODEL] == 7001 or entity[ROLE_MODEL] == 7002 or entity[ROLE_MODEL] == 7003 then
		 	if self.map_layer.m_friendsData and self.map_layer.m_friendsData[objId] then
                addMonsterRole(self.map_layer.m_friendsData[objId])
            elseif entity[ROLE_SCHOOL] then
            	local item = getConfigItemByKey("SimulationRoleCopyDB", "q_id", entity[ROLE_SCHOOL])
            	if item then
            		local params = {}
				    -- params[ROLE_SCHOOL] = item.q_school
				    local role_school = entity[ROLE_MODEL]%7000 
				    params[ROLE_SCHOOL] = role_school
				    params[PLAYER_SEX]  = item.q_sex
				    params[ROLE_HP]     = entity[ROLE_HP]
				    params[ROLE_MAX_HP] = entity[ROLE_MAX_HP]
				    params[ROLE_NAME]   = item.q_name
				    if entity[ROLE_NAME] then 
				   		params[ROLE_NAME]   = entity[ROLE_NAME]
				    end
				    params[ROLE_DIR]    = item.q_dir
				    params[ROLE_LEVEL]  = entity[ROLE_LEVEL]
					params[PLAYER_EQUIP_WEAPON]    = item.q_weapon
				    params[PLAYER_EQUIP_UPPERBODY] = item.q_cloth
				    params[PLAYER_EQUIP_WING]      = item.q_wing		
				    if entity[ROLE_DIR] then
				    	params[ROLE_DIR]  = entity[ROLE_DIR]
				    end
            		local monster = addMonsterRole(params)
            		-- 加封号 by xhh
            		local function getSpecialTitle( school,lv )
				        for k,v in pairs(getConfigItemByKey("SpecialTitleDB", "q_id")) do
				            if v.q_school==school and v.q_lv==lv then
				                return v
				            end
				        end
				    end
            		if monster and self.map_layer.mapID == 5008 then
            			local titleNameNode = monster:getTitleNameBatchLabel()
			            if titleNameNode  then
			            	local specialTitle = getSpecialTitle( params[ROLE_SCHOOL] ,item.q_level)
			            	if specialTitle then
			            		titleNameNode:setString(specialTitle.q_name)
				                if item.q_titlecolor then
				                    titleNameNode:setColor(specialTitle.q_color)
				                end
			            	end
			            end
            		end
		           
            	end
			end
		elseif monsterItem and monsterItem.q_weapon and monsterItem.q_body and monsterItem.q_class then
			local params = {}
		    params[ROLE_SCHOOL] = monsterItem.q_class
		    params[PLAYER_SEX]  = monsterItem.q_sex or 2
		    params[ROLE_HP]     = entity[ROLE_HP]
		    params[ROLE_MAX_HP] = entity[ROLE_MAX_HP]
		    params[ROLE_NAME]   = monsterItem.q_name
		    params[ROLE_DIR]    = entity[ROLE_DIR] 
		    params[ROLE_LEVEL]  = entity[ROLE_LEVEL]
			params[PLAYER_EQUIP_WEAPON]    = monsterItem.q_weapon
		    params[PLAYER_EQUIP_UPPERBODY] = monsterItem.q_body
		    params[PLAYER_EQUIP_WING]      = monsterItem.q_wing		    

    		local monster_node = addMonsterRole(params)
			if entity[PLAYER_TEAMID] and monster_node then
				if G_MAINSCENE.map_layer and (mapId == 5003 or mapId == 5010 )then
					self:QryMonsterNameColor(objId)
				end
			end       		
		else
			local res_id = getConfigItemByKey("monster","q_id",entity[ROLE_MODEL],"q_featureid")
			--local roleSprite = require("src/base/RoleSprite")
			--res_id = roleSprite:getRightResID(1,res_id) 
			if not self.numup or self.numup == 1 then
				self.numup = 2
			else
				self.numup = 1
			end
			if self.map_layer then
				local isMonsterEx = false
				if entity[ROLE_SCHOOL] and entity[ROLE_SCHOOL] > 0 then
					isMonsterEx = true
                    if mapId == 2117 and entity[ROLE_MODEL] == 661 then
                        entity[PLAYER_EQUIP_UPPERBODY] = 5110507
                        entity[PLAYER_EQUIP_WEAPON] = 5110107
                        entity[PLAYER_EQUIP_WING] = 4031
                        entity[PLAYER_SEX] = 1
                    end
				end
				local monster_node = nil
				if isMonsterEx then
					if self.map_layer.isJjc then
						monster_node = self.map_layer:addMonster_ex(posX,posY,tostring(res_id),3,objId,entity)
					else
						monster_node = addMonsterRole(entity)
					end
				else
					monster_node = self.map_layer:addMonster(posX,posY,tostring(res_id),3,objId,entity)
				end
				if entity[PLAYER_TEAMID] and monster_node then
					if G_MAINSCENE.map_layer and (G_MAINSCENE.map_layer.mapID == 2100 or G_MAINSCENE.map_layer.mapID == 5003) then
						G_ROLE_MAIN:setCar_ex(monster_node, entity[PLAYER_TEAMID])
						self:QryMonsterNameColor(objId)
					elseif G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
						self:set3V3NameColor(monster_node, entity[PLAYER_TEAMID])
						--公平竞技场箭塔破损效果
						if entity[ROLE_HP] and entity[ROLE_MAX_HP]  then
							self.map_layer:showDamagedEffect(monster_node,entity[ROLE_HP],entity[ROLE_MAX_HP])
						end
					end
				end
				if self.map_layer.monster_head and self.map_layer.monster_head.monster_id == objId and tolua.cast(self.map_layer.monster_head,"cc.Node") then
					self.map_layer:touchMonsterFunc(monster_node)
				end
			end
		end
		if buffFunc then
			buffFunc()
		end
		buffFunc = nil
		--TimeProfile:step("step5")
	elseif objType == commConst.eClsTypeMpw then--掉落
		if self.map_layer then
			self.map_layer:addDropOut(posX,posY,objId,entity)
		end
	elseif objType == commConst.eClsTypeMagic then	-- 地面特效
		if self.map_layer then
			if (entity[ROLE_MODEL] == 2011 or entity[ROLE_MODEL] == 2039) then
                CMagicCtrlMgr:getInstance():CreateFloorMagic(3, posX, posY, objId);
            elseif (entity[ROLE_MODEL] == 10042) then   -- 阿修罗神　奔雷　地面效果
                CMagicCtrlMgr:getInstance():CreateFloorMagic(5, posX, posY, objId, entity[ROLE_DIR] or 1);
			else
				CMagicCtrlMgr:getInstance():CreateFloorMagic(entity[ROLE_MODEL], posX, posY, objId);
            end
            --self.map_layer:addMagicEffect(posX,posY,objId,entity)
		end
	end
	--TimeProfile:funcEnd()
end

function BaseMapNetNode:onPropUpdate(luaBuffer)
	--if true then return end
	local proto = g_msgHandlerInst:convertBufferToTable("FramePropUpdateProtocol", luaBuffer)
	--local objId,attrNum = luaBuffer:readByFmt("is")
	local objId = proto.roleID
	local MRoleStruct = require("src/layers/role/RoleStruct")
	local has_get = false
	local old_attrs = {}
	local getOldAttrs = function() 
		has_get = true
		for i= ROLE_MIN_AT,ROLE_DODGE,1 do 
			old_attrs[i] = MRoleStruct:getAttr(i)
		end
		old_attrs[ROLE_MAX_HP] = MRoleStruct:getAttr(ROLE_MAX_HP)
		old_attrs[ROLE_MAX_MP] = MRoleStruct:getAttr(ROLE_MAX_MP)
		old_attrs[ROLE_SHOW] = MRoleStruct:getAttr(ROLE_SHOW, objId)
		if old_attrs[ROLE_SHOW] == nil then
			old_attrs[ROLE_SHOW] = 1
		end
	end

	local entity = {}
	for k,v in pairs(proto.props) do
		local id = v.propId --luaBuffer:popChar()
		--print("attr id:"..id)
		if (id > ROLE_MAX_COMPROP and id <= ROLE_DODGE or id == ROLE_MAX_HP or id == ROLE_MAX_MP) and objId == userInfo.currRoleId then
			if (not has_get) then
				getOldAttrs()
			end
		end
		if id == ROLE_SHOW then
			if (not has_get) then
				getOldAttrs()
			end
		end

		local callback = nil
		if id>=PLAYER_EQUIP_WEAPON and id<PLAYER_OTHER then
			callback = function(attrId, objId,isMe, g_id,event)
				self:onDressUpdate(attrId,isMe,objId, g_id,event)		
			end
		elseif  id == ROLE_BUFF then
			callback = function(attrId, objId,isMe, buffs)
				self:onBuffUpdate(attrId,isMe,objId, buffs)
			end
		elseif id == PLAYER_HOLD_MAT then
			local tab = {}
			local matTable = protobuf.decode("HoldMatProtocol", v.propString)
			if matTable and matTable.mats then
				for key,value in pairs(matTable.mats)do 
					tab[key] = {matId = value.itemID,cout = value.itemNum,time = os.time()+ value.remainTime}
				end
				entity[id] = tab
			end
		end
		if id ~= PLAYER_HOLD_MAT then
			entity[id] = MRoleStruct:setAttr(id, objId, v, objId == userInfo.currRoleId, callback)
		end
		--if objId == userInfo.currRoleId then print("onPropUpdate attr id:"..id,v.propInt,v.propString,entity[id]) end
	end
	if (not self.map_layer) or  (not self.map_layer.item_Node) or (not G_ROLE_MAIN) then
		return
	end
	if objId == userInfo.currRoleId and has_get and old_attrs[ROLE_MAX_HP] then
		for i= ROLE_MIN_AT,ROLE_DODGE,1 do 
			if entity[i] and old_attrs[i] and entity[i] > old_attrs[i] then
				self.map_layer:showAttrChangeNumer(i,entity[i]-old_attrs[i])
			end
		end
		if entity[ROLE_MAX_HP] and old_attrs[ROLE_MAX_HP] and entity[ROLE_MAX_HP] > old_attrs[ROLE_MAX_HP] then
			self.map_layer:showAttrChangeNumer(ROLE_MAX_HP,entity[ROLE_MAX_HP]-old_attrs[ROLE_MAX_HP])
		end
		if entity[ROLE_MAX_MP] and old_attrs[ROLE_MAX_MP] and entity[ROLE_MAX_MP] > old_attrs[ROLE_MAX_MP] then
			self.map_layer:showAttrChangeNumer(ROLE_MAX_MP,entity[ROLE_MAX_MP]-old_attrs[ROLE_MAX_MP])
		end
	end
	local node = tolua.cast(self.map_layer.item_Node:getChildByTag(objId), "SpriteMonster")
	if not node then return end
	-- if entity[ROLE_DIR] then 
	-- 	local a_state = node:getCurrActionState()
	--   	if (not a_state) or a_state <= ACTION_STATE_IDLE then
	--   		node:setSpriteDir(entity[ROLE_DIR])
	--   		node:standed()
	--   	end
	-- end

	if entity[ROLE_MAX_HP] then 
		node:setMaxHP(entity[ROLE_MAX_HP])
		node:setHP(node:getHP())
	end
	if entity[ROLE_HP] then
        if entity[ROLE_HP] <= 0 then
            if node.boss_effect then
                node.boss_effect:setVisible(false)
            end
            if node.worldBossPic then
                node.worldBossPic:setVisible(false)
            end
        end
		if entity[ROLE_HP] > 0 then
            if node.boss_effect then
                node.boss_effect:setVisible(true)
            end
            if node.worldBossPic then
                node.worldBossPic:setVisible(true)
            end
			node:setHP(entity[ROLE_HP])
			--if node:getType() >= 20 then node:showNameAndBlood(true) end
		elseif self.map_layer then
			node:setHP(entity[ROLE_HP])
			self.map_layer:showReliveLayer(objId)
		end
		if objId == userInfo.currRoleId and self.dyingLayer then
			self.dyingLayer:check()
		end
		--公平竞技场箭塔破损效果
		if self.map_layer and self.map_layer.isSkyArena  then
			self.map_layer:showDamagedEffect(node,entity[ROLE_HP])
		end
		-- --怪物头像更新
		-- if self.map_layer and self.map_layer.monster_head and tolua.cast(self.map_layer.monster_head,"cc.Node") and self.map_layer.monster_head.monster_id == objId then
		-- 	self.map_layer.monster_head:updateInfo(node)
		-- end
	end
	if entity[PLAYER_PK] or (entity[PLAYER_TEAMID] and ((not self.map_layer ) or self.map_layer.mapID ~= 5008)) then
		if objId == userInfo.currRoleId then
			self:changePlayColor()
			if self.map_layer.mapID == 5003 then
				self:changePetNameColor()
			end		
		else
			self:QryMonsterNameColor(objId)
		end		
		--self:QryMonsterNameColor(objId)
		--G_ROLE_MAIN:setNameColor_ex(node, entity[PLAYER_PK])
	end

	if entity[PLAYER_TITLE] then
		G_ROLE_MAIN:setTitle_ex(node, entity[PLAYER_TITLE])
	end
	if entity[PLAYER_VIP] then
		G_ROLE_MAIN:setVip_ex(node, entity[PLAYER_VIP])
	end
	if entity[PLAYER_FACTIONID] then
		--print("entity[PLAYER_FACTIONID] ", objId, entity[PLAYER_FACTIONID])
		if objId == userInfo.currRoleId then
			G_FACTION_INFO.id = entity[PLAYER_FACTIONID]
			if G_FACTION_INFO.id <= 0 then
				G_FACTION_INFO.facname = nil
			end
			--dump(G_FACTION_INFO.id)
			self:changePlayColor()
			self:changeMonsterColor()
		end

		G_ROLE_MAIN:setCornerSign_ex(node,2,entity[PLAYER_FACTIONID])
		self:QryMonsterNameColor(objId)
	end
	if entity[PLAYER_FACTIONNAME] then
		if objId == userInfo.currRoleId then
			G_FACTION_INFO.facname = entity[PLAYER_FACTIONNAME]
			--dump(G_FACTION_INFO.facname)
		end

		G_ROLE_MAIN:setFactionName_ex(node, entity[PLAYER_FACTIONNAME])
	end
    if entity[PLAYER_TEAMID] then
    	if G_MAINSCENE.map_layer and (G_MAINSCENE.map_layer.mapID == 2100 or G_MAINSCENE.map_layer.mapID == 5003 )then
			G_ROLE_MAIN:setCar_ex(node, entity[PLAYER_TEAMID])
			self:QryMonsterNameColor(objId)
		elseif G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
        	G_MAINSCENE:set3V3NameColor(node, entity[PLAYER_TEAMID])
		end
	end
    
	-- if entity[PLAYER_SERVER_ID] then
	-- 	G_ROLE_MAIN:setServer_ex(node, entity[PLAYER_SERVER_ID])
	-- end
	if entity[PLAYER_HOLD_MAT] then
		--if self:isCarryMode() then
			G_ROLE_MAIN:setCarry_ex(node, entity[PLAYER_HOLD_MAT])
		--end
	end
	if entity[PLAYER_SPECIAL_TITLE_ID] then
		G_ROLE_MAIN:setSpecialTitle(node, entity[PLAYER_SPECIAL_TITLE_ID])
	end
	if entity[PLAYER_BANNER] then
		G_ROLE_MAIN:setBanner(node, entity[PLAYER_BANNER])
	end
	
	if entity[PLAYER_HOLD_MINE] then
		if G_ROLE_MAIN and G_ROLE_MAIN.mineTab and string.len(entity[PLAYER_HOLD_MINE]) < 3 then
			local itemNum = tablenums(G_ROLE_MAIN.mineTab)
			--print("itemNum",itemNum)
			if itemNum > 0 then
				local items = {}
				for k,v in pairs(G_ROLE_MAIN.mineTab)do
					items[#items+1] = {id=v.matId,cnt=1}
				end
				self:playGetPrizeEffect(itemNum,items,0.1)
			end
		end
		G_ROLE_MAIN:setMine(node, entity[PLAYER_HOLD_MINE])
	end

	if entity[ROLE_STATUS_NAME] then
		require("src/base/MonsterSprite"):setBannerOwer(node, entity[ROLE_STATUS_NAME])
	end

	if entity[ROLE_MOVE_SPEED] then
	    
	    if objId == userInfo.currRoleId then
	    	local base_speed = getConfigItemByKeys("roleData", {
									"q_zy",
									"q_level",
									},{1,1},"q_move_speed")/1000

			g_speed_time = base_speed/(entity[ROLE_MOVE_SPEED]/100)
			if g_speed_time < 0.08 then g_speed_time = 0.08 end
			--print("move time"..g_speed_time)
			if self.map_layer then
				self.map_layer:resetSpeed(g_speed_time)
	 		end
	 	else
	 		node:setSpeed(node:getBaseSpeed()/(entity[ROLE_MOVE_SPEED]/100))

	 		-- if self.map_layer and (self.map_layer.monster_tab[objId] or self.map_layer.m_friendsData[objId])then
	 		-- 	node:setSpeed(0.45/(entity[ROLE_MOVE_SPEED]/100))
	 		-- else
	 		-- 	node:setSpeed(base_speed/(entity[ROLE_MOVE_SPEED]/100))
	 		-- end
	 	end
 	end

	if entity[ROLE_SHOW] then
		local iHasGet = 0
		if has_get then
			iHasGet = 1
		end
		log("[BaseMapNetNode:onPropUpdate] called. Begin ROLE_SHOW action. old_attrs[ROLE_SHOW] = %s, has_get = %s.", old_attrs[ROLE_SHOW], iHasGet)
		if has_get and old_attrs[ROLE_SHOW] then
			local oldShow = old_attrs[ROLE_SHOW]
			local newShow = entity[ROLE_SHOW]
			log("[Update ROLE_SHOW] called. new = %s, old = %s.", entity[ROLE_SHOW], old_attrs[ROLE_SHOW])
			if oldShow == 0 and newShow == 1 then		-- appear action
				local modelId = node:getResId()
				local appearFrameCount = 4
				local appearDir = 7
				local monster_info = getConfigItemByKey("MonsterAction", "q_featureid", modelId)
				local has_appear_action = false
				if monster_info then
					if monster_info.q_appear then
						appearFrameCount = tonumber(monster_info.q_appear)
						if appearFrameCount > 0 then
							has_appear_action = true
							appearDir = tonumber(monster_info.appear_dir)
						end
					end
				end
				local monster_type = node:getType()
				local visible_state = true
				if monster_type < 12 then
					if self.map_layer and getGameSetById(GAME_SET_ID_SHIELD_MONSTER) == 1 then
						visible_state = false
					end
				end
				local FuncShow = function()
				--	node:initStandStatus(4,4,1.0,0)
					if self.map_layer then
						local node_item = self.map_layer:isValidStatus(objId)
						if node_item then
							node_item:setVisible(visible_state)
						end
					end
				end
				log("[Update ROLE_SHOW] called. appear. framecount = %s, rolemodel = %s.", appearFrameCount, modelId)

				if modelId == 6060 then
					local effNode = createMonsterEffect(node, "mae_6060_6", 16, 2.0, 1)
					if effNode then
						effNode:setLocalZOrder(-10)
					end
				end

				if has_appear_action then
					node:appeared(0.8, appearFrameCount, appearDir)
					performWithDelay(self, FuncShow, 0.2)
				else
					node:standed()
					node:setVisible(visible_state)
				end
			elseif oldShow == 1 and newShow == 0 then	-- disappear action
				local modelId = node:getResId()
				local disappearFrameCount = 4
				local has_disappear_action = false
				local monster_info = getConfigItemByKey("MonsterAction", "q_featureid", modelId)
				if monster_info then
					if monster_info.q_disappear then
						disappearFrameCount = tonumber(monster_info.q_disappear)
						if disappearFrameCount > 0 then
							has_disappear_action = true
						end
					end
				end
				local FuncHide = function()
					if self.map_layer then
						local node = tolua.cast(self.map_layer.item_Node:getChildByTag(objId), "SpriteMonster")
						if node then 
							node:setVisible(false)
						end
					end
				end
				log("[Update ROLE_SHOW] called. disappear. framecount = %s, rolemodel = %s.", disappearFrameCount, modelId)

				if has_disappear_action then
					node:disappeared(0.6, disappearFrameCount, 7)
					performWithDelay(self, FuncHide, 0.6)
				else
					node:setVisible(false)
				end
			end
		end
	end


	if objId == userInfo.currRoleId then
		--if entity[ROLE_MODEL] then userInfo.currRoleStaticId = entity[ROLE_MODEL] end
		if entity[PLAYER_PATTERN] and self.attackmode_node then
			require("src/layers/pkmode/PkModeLayer"):setCurMode(entity[PLAYER_PATTERN])
			self.attackmode_node:setImages("res/mainui/pkmode/"..(entity[PLAYER_PATTERN]+1)..".png")

            if self.m_pkModeLal then
                local pkModeStrs = {
                    game.getStrByKey("pkmode_heping_str"),
                    game.getStrByKey("pkmode_zudui_str"),
                    game.getStrByKey("pkmode_banghui_str"),
                    game.getStrByKey("pkmode_quanti_str"),
                    game.getStrByKey("pkmode_shane_str"),
                    game.getStrByKey("pkmode_gongsha_str")
                }
                self.m_pkModeLal:setString(pkModeStrs[entity[PLAYER_PATTERN]+1]);
            end
		end
		if entity[ROLE_LEVEL] and G_ROLE_MAIN then 
			--cclog("=============================")
			self.total_exp =  getConfigItemByKeys("roleData", {
			        "q_zy",
			        "q_level",
			      },{MRoleStruct:getAttr(ROLE_SCHOOL),entity[ROLE_LEVEL]},"q_exp")
			self:resetHeadInfo(nil,tostring(entity[ROLE_LEVEL]))
			
			if G_ROLE_MAIN:getLevel() < entity[ROLE_LEVEL] then
				G_ROLE_MAIN:setLevel(entity[ROLE_LEVEL])
				--更新周围怪的名字颜色
				UpdateMonsterNameColor()

				--等级改变检测最新可接密令任务 
				if DATA_Mission then DATA_Mission:checkBranchData() end
				
				self:createTargetAwards(true)

				--查询背包中可替换的装备
				self:checkChangeEquipment()
				local updateTip = getConfigItemByKey("updateTip","q_lv",entity[ROLE_LEVEL])			   

			    if updateTip then
			    	local zi = ""
		        	require("src/utf8")
		        	self.theLight = cc.Sprite:create("res/layers/role/light.png")
					local rotate = cc.RotateBy:create(0.1, 6)
					local forever = cc.RepeatForever:create(rotate)
					self.theLight:runAction(forever)
					self.theLight:setPosition(cc.p(display.cx, display.cy-70))
					G_MAINSCENE:addChild(self.theLight,899)
					self.congratulation = createSprite(G_MAINSCENE,"res/mainui/congratulation.png",cc.p(display.cx, display.cy-70),cc.p(0.5,0.5),900)
		        	local sentence = string.format(updateTip.q_tips,tostring(math.floor(math.random(1,15))+84).."%")
		        	local sentence1 = cutRichText(sentence)
		        	local num = string.utf8len(sentence1)
		            self.thefloor = createScale9Sprite(G_MAINSCENE, "res/common/notice_msg_bg.png", cc.p(display.cx, display.cy-140), cc.size(num*28, 50 ), cc.p(0.5, 0.5),nil,nil,899)
		            --self.caption = createLabel(self.thefloor,sentence,cc.p(65,self.thefloor:getContentSize().height/2),cc.p(0,0.5),25,nil,900,nil,MColor.yellow)
		   			self.caption = require("src/RichText").new(self.thefloor, cc.p(65,self.thefloor:getContentSize().height/2), cc.size(self.thefloor:getContentSize().width-2,self.thefloor:getContentSize().height-2), cc.p(0, 0.5), 25, 24, MColor.yellow)
					self.caption:addText(sentence1, MColor.yellow)
					self.caption:format()
					self.caption:setVisible(false)
		            local s = self.caption:getContentSize()
		            local particle = cc.ParticleSystemQuad:create("res/particle/newFunctionOn.plist")
		            particle:setLifeVar(0)
		            particle:setLife(0.5)
		            particle:setPosition(cc.p(g_scrSize.width,g_scrSize.height/2))
		            self.thefloor:addChild(particle)
		            --self.caption:addChild(particle)
		            num = string.utf8len(sentence)
		            for i=0 , num, 1 do
		                self.caption:runAction(cc.Sequence:create(cc.DelayTime:create(i/20), cc.CallFunc:create(function() 
	                    zi = string.utf8sub(sentence,1,i+1)
	                    --self.caption:setString(zi)
	     				self.caption1 = require("src/RichText").new(self.thefloor, cc.p(65,self.thefloor:getContentSize().height/2), cc.size(self.thefloor:getContentSize().width-2,self.thefloor:getContentSize().height-2), cc.p(0, 0.5), 25, 24, MColor.yellow)
						self.caption1:addText(zi, MColor.yellow)
						self.caption1:format()
	                    s = self.caption1:getContentSize()
	                   	particle:setPosition(cc.p((g_scrSize.width/num)*i,(g_scrSize.height)*(i%2)*(-1)+40))
	                        if i >= num-1 then
	                        	for i=0,num do
	                        		particle:runAction(cc.Sequence:create(cc.DelayTime:create(i/20),cc.CallFunc:create(function()
	                        				particle:setPosition(cc.p((g_scrSize.width/num)*i,(g_scrSize.height)*(i%2)*(-1)+40))
	                        			end)))
	                        	end
	                        end
	                    end)))
		            end
					            -- particle:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
	                --                 particle:stopSystem()
	                --             end)))
					    --self.thefloor:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,1.2),cc.ScaleTo:create(0.5,1)))
				    G_MAINSCENE:runAction(cc.Sequence:create(cc.DelayTime:create(6), cc.CallFunc:create(function() 
				        if self.caption then
				            removeFromParent(self.caption)
				            self.caption = nil
				        end
				      	if self.thefloor then
				      		removeFromParent(self.thefloor)
				            self.thefloor = nil
				      	end
				      	if self.theLight then
				      		removeFromParent(self.theLight)
				      		self.theLight = nil
				      	end
				      	if self.congratulation then
				      		removeFromParent(self.congratulation)
				      		self.congratulation = nil
				      	end
				    end)))
				end

				AudioEnginer.playEffect("sounds/uiMusic/ui_levelup.mp3",false)
				MdsAgent:postEvent("player_upgrade", entity[ROLE_LEVEL])
				--cclog("find! exp:"..v.q_exp)
				--update animation
				if G_SKYARENA_DATA.tipsLimit and G_SKYARENA_DATA.tipsLimit.levelUpStopTimes and G_SKYARENA_DATA.tipsLimit.levelUpStopTimes==0 then
					G_SKYARENA_DATA.tipsLimit.levelUpStopTimes=1
				else
					local anim = Effects:create(false)
					anim:playActionData("levelUpdate",22,2,1)
					anim:setScale(1.11)
					anim:setPosition(cc.p(0,150))
					G_ROLE_MAIN:addChild(anim,9,1024)
					local removeEffect = function()
				        if G_ROLE_MAIN:getChildByTag(1024) then
				            G_ROLE_MAIN:removeChildByTag(1024)
				        end
					end
					performWithDelay(self,removeEffect,2)
				end
				if self.total_exp == 0 then
					cclog("cant find the updating expierence of level "..entity[ROLE_LEVEL])
				end
				self.nfTriggerNode:check()
				__TASK:getMainIcon():refreshData()

				local fbData = require("src/config/dragonSliayerCfg")
				local idxx = nil
				for i=1,#fbData do
					local item = fbData[i]
					if entity[ROLE_LEVEL] == tonumber(item.q_lv) then
						idxx = i
						userInfo.newFbId = tonumber(item.q_id)
						break
					end
				end
				if idxx then
					if G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_FB_SINGLE) then
	    				DATA_Battle:setRedData("TLCS", true)
	    			end
	    			
					if userInfo.newFbId then
						setLocalRecordByKey(2,"redDotFbId",""..userInfo.currRoleStaticId.."."..userInfo.newFbId)
					end
				end

				local ques = require("src/layers/activity/Questionnaire")
				ques:checkLocalRecord(entity[ROLE_LEVEL])
				if Device_target == cc.PLATFORM_OS_ANDROID then
					local tabs = {level=entity[ROLE_LEVEL]}
					callStaticMethod("org/cocos2dx/lua/AppActivity", "onLevelChange", {require("json").encode(tabs)})
				end
				setRoleInfo(3, userInfo.currRoleStaticId, entity[ROLE_LEVEL], MRoleStruct:getAttr(ROLE_SCHOOL), MRoleStruct:getAttr(ROLE_NAME) )

				if not entity[PLAYER_XP] then
					--cclog("player_xp~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"..entity[PLAYER_XP])
					self.curr_exp = MRoleStruct:getAttr(PLAYER_XP) or 0
					if self.total_exp > 0 then
						local percentage = self.curr_exp*100/self.total_exp
						self.exp_process:setPercentage(percentage)
						self.exp_label:setString(""..self.curr_exp.."/"..self.total_exp.." ("..math.floor(percentage).."%)")
					end
				end
			end
			G_ROLE_MAIN:setLevel(entity[ROLE_LEVEL])
		end
		if entity[PLAYER_XP] then
			--cclog("player_xp~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"..entity[PLAYER_XP])
			self.curr_exp = entity[PLAYER_XP]
			self.total_exp = self.total_exp or getConfigItemByKeys("roleData", {
			        "q_zy",
			        "q_level",
			      },{MRoleStruct:getAttr(ROLE_SCHOOL),MRoleStruct:getAttr(ROLE_LEVEL)},"q_exp")
			if self.total_exp then
				local percentage = self.curr_exp*100/self.total_exp
				local old_percent = self.exp_process:getPercentage()
				if percentage > old_percent and percentage > 1 and percentage < 99 then
					local upexp = Effects:create(false)
					upexp:setAsyncLoad(false)
					local times = 0.5+(percentage - old_percent)*0.01
					upexp:playActionData("upexp",12,times+0.1,1)
					upexp:setPosition(cc.p(self.exp_process:getContentSize().width*old_percent/100+47,13))
					self.exp_bg:addChild(upexp,20)
					performWithDelay(self.exp_bg,function() removeFromParent(upexp) end,times+0.1)
					upexp:runAction(cc.MoveTo:create(times,cc.p(self.exp_process:getContentSize().width*percentage/100+47,13)))
					self.exp_process:runAction(cc.ProgressFromTo:create(times,old_percent,percentage))
				else
					self.exp_process:setPercentage(percentage)
				end
				self.exp_label:setString(""..self.curr_exp.."/"..self.total_exp.." ("..math.floor(percentage).."%)")
			end
		end
		if entity[PLAYER_FACTIONID] then
      		G_FACTION_INFO.id = entity[PLAYER_FACTIONID]
	 	end
	 	if entity[PLAYER_FACTIONNAME] then
	      --log("faction id : "..tostring(G_FACTION_INFO.id))
	      --log("faction name : "..tostring(G_FACTION_INFO.facname))
	      if string.len(entity[PLAYER_FACTIONNAME])>0 then
	        G_FACTION_INFO.facname = entity[PLAYER_FACTIONNAME]
	      else
	        G_FACTION_INFO.facname = nil
	      end
		end
 		if entity[PLAYER_BATTLE] then
 			self:addBattleNum(entity[PLAYER_BATTLE])
 			self.nfTriggerNode:check()
 			self:refreshOfflineRedDot(nil,entity[PLAYER_BATTLE])
		end
		G_ROLE_MAIN.currGold = entity[PLAYER_MONEY] or G_ROLE_MAIN.currGold
		G_ROLE_MAIN.currBindGold = entity[PLAYER_BINDMONEY] or G_ROLE_MAIN.currBindGold
		G_ROLE_MAIN.currIngot = entity[PLAYER_INGOT] or G_ROLE_MAIN.currIngot
		G_ROLE_MAIN.currBindIngot = entity[PLAYER_BINDINGOT] or G_ROLE_MAIN.currBindIngot

		if entity[PLAYER_MONEY] or entity[PLAYER_BINDMONEY] or entity[PLAYER_INGOT] or entity[PLAYER_BINDINGOT] then
			handlerMultiFunc(MONEY_GOLD_UPDATE)
		end
		if G_ROLE_MAIN then
			G_ROLE_MAIN:refreshData(entity)
			if entity[ROLE_HP] or entity[ROLE_MP] or entity[ROLE_MAX_HP] or entity[ROLE_MAX_MP] then
				self:updateHeadInfo()
			end
			if entity[PLAYER_PET_ID] then
				self.map_layer:setPet()
			end
		end
		if entity[PLAYER_LINE] then
			self:addLineNode(entity[PLAYER_LINE])
		end
	else
		if entity[ROLE_MODEL] then
			self:changeMonsterDisplay(objId,entity)
		end
		if entity[ROLE_HOST_NAME] then 
			local monster_id = node:getMonsterId()
			local q_name_label = node:getNameBatchLabel()
			local q_name = getConfigItemByKey("monster","q_id",monster_id,"q_name")
			if q_name_label and q_name then
		        local carCfg = { ["80000"] = true , ["80001"] = true , ["80002"] = true , ["80003"] = true }
        		if  carCfg[ monster_id .. "" ] then
		            q_name_label:setString(q_name .. "\n".. entity[ROLE_HOST_NAME])
		            node:setTheName(q_name .. "\n".. entity[ROLE_HOST_NAME])
		            if MRoleStruct:getAttr(ROLE_NAME) == entity[ROLE_HOST_NAME] then
		            	q_name_label:setColor(MColor.green)
		            elseif entity[PLAYER_FACTIONID]  and entity[PLAYER_FACTIONID] == MRoleStruct:getAttr(PLAYER_FACTIONID) then
		            	q_name_label:setColor(MColor.blue)
		            end
		        else
		        	q_name_label:setString(entity[ROLE_HOST_NAME] .."的"..q_name)
		        	node:setTheName(entity[ROLE_HOST_NAME] .."的"..q_name)
		        end
		    end
	    end
	    local role_name = entity[ROLE_NAME]
	    if role_name then
			local name_label = node:getNameBatchLabel()
			if name_label then
                if entity[ROLE_MODEL] and (entity[ROLE_MODEL] == commConst.MULTI_GUARD_PRINCESS_ID) then
                    print("no need to change princess name!");
                else
		            name_label:setString(role_name)
		            if game.getAutoStatus() == AUTO_ATTACK then
		            	local m_role_name = MRoleStruct:getAttr(ROLE_NAME)
		            	local find_index = string.find(role_name,m_role_name)
		            	if find_index and find_index > 1 and self.map_layer then
		            		self.map_layer:touchMonsterFunc(node,true)
		            	end
		            end
                end
		    end
		end	     
	end
end

function BaseMapNetNode:changeMonsterDisplay(objId,entity)
	if self.map_layer then
		local res_id = getConfigItemByKey("monster","q_id",entity[ROLE_MODEL],"q_featureid")
		local roleSprite = require("src/base/RoleSprite")
		--res_id = roleSprite:getRightResID(1,res_id) 
		local monster_item =  tolua.cast(self.map_layer.item_Node:getChildByTag(objId), "SpriteMonster")
		if res_id and monster_item and monster_item:getType() < 20 then
			local monsterIdOld = monster_item:getMonsterId()
			local monsterIdNew = entity[ROLE_MODEL]
			if monsterIdOld ~= monsterIdNew then
				monster_item:setMonsterId(monsterIdNew)
				
				local changeFrameCount = 4
				local monster_info = getConfigItemByKey("MonsterAction", "q_featureid", res_id)
				if monster_info then
					changeFrameCount = tonumber(monster_info.q_change)
					if changeFrameCount ~= nil and changeFrameCount > 0 then
						monster_item:setBaseUrl(tostring(res_id))
                        monster_item:setMonsterActionByInfo(monster_info)
						monster_item:changeDisplay(0.6, changeFrameCount, 7)
					else
						monster_item:standed()
					end
				end
				log("[Update ROLE_MODEL] called. change model. modelold = %s, modelnew = %s.", monsterIdOld, monsterIdNew)

                -- 重设显示 变身怪物死亡后-- 重设显示[if getGameSetById(GAME_SET_MONSTER_DIEDSHOW) == 1 then]
                monster_item:setVisible(true);

                -- 重设高度
                local hpHigh = getConfigItemByKey("monster","q_id",entity[ROLE_MODEL],"hp_high");
                if hpHigh then
                    hpHigh = tonumber(hpHigh);
                    if hpHigh and hpHigh > 0 then
                        monster_item:showNameAndBlood(true, hpHigh);
                    end
                end
				-------------------------------------------

                -- 针对死亡怪物，需要重设透明度
                local rolePos = cc.p(monster_item:getPosition());
                local roleTile = self.map_layer:space2Tile(rolePos);
                if self.map_layer:isOpacity(roleTile) then
                    monster_item:setOpacity(100);
                else
                    monster_item:setOpacity(255);
                end

				local monsterInfo = getConfigItemByKey("monster", "q_id")[monsterIdNew]
				if monsterInfo then
					local monsterHPMax = monsterInfo["q_maxhp"]
					if monsterHPMax then
						monster_item:setMaxHP(monsterHPMax)
					end
				end
			end
		end
	end
end

function BaseMapNetNode:networkHander(buff,msgid,params)
	local switch = {
		[SKILL_SC_LOADSKILL] = function()
			-- print("SKILL_SC_LOADSKILL")
			local proto = g_msgHandlerInst:convertBufferToTable("SkillSyncProtocol", buff) 
			local skills = {}
			local skillTemp = {}
			local mTemp = 0
			for i,v in pairs(proto.skills)do
				skills[i] = {v.id,v.level,v.key,v.exp,v.cdTime}
			end
			-- local MskillOp = require "src/config/skillOp"
			local BaseMapScene = require("src/base/BaseMapScene")
			G_SKILLPROP_POS = {}
			for k,v in pairs(skills) do
				-- local cool_time = MskillOp:skillCoolTime(v[1],v[2])
				-- if cool_time then
					BaseMapScene.skill_cds[v[1]] = v[5] or 0--cool_time/1000
				-- end				
				local skillcfg = getConfigItemByKey("SkillCfg","skillID",v[1])
				local canRegister = skillcfg.canRegister
				local jnfenlie = skillcfg.jnfenlie
				if canRegister and canRegister > 0 and jnfenlie ~= 9 then
					table.insert(G_SKILLPROP_POS,{0,1,v[1]})
				end 
			end
			local reloadSkill = function()
				if G_ROLE_MAIN then
					G_ROLE_MAIN:setSkills(skills)
					self:reloadSkillConfig()
					-- for k,v in pairs(G_SKILLPROP_POS) do
					-- 	if v[2] == 2 then
					-- 		self:doPropAction(v[3],true)
					-- 	end
					-- end
				end
				checkSkillRed()
				checkWingSkillRed()
			end
			performWithDelay(self,reloadSkill,0.0)
			local MpropOp = require "src/config/propOp"
			local propData = MpropOp.isInSkill()
			table.insertto(G_SKILLPROP_POS,propData,#G_SKILLPROP_POS+1)
			for i,j in pairs(proto.shortKeys) do
				local data = {j.ptotokey,j.prototype,j.protoid}
				for k,v in pairs(G_SKILLPROP_POS) do
					if v[3] == data[3] then
						v[1] = data[1]
						break
					end
				end
			end			
		end,		
		[SKILL_SC_SKILLUPDATE] = function()
			-- local skills = {buff:popShort(),buff:popChar(),buff:popChar()}
			local proto = g_msgHandlerInst:convertBufferToTable("SkillUpdateProtocol", buff) 
			local skills = {proto.id  ,proto.level  ,proto.key  }
			if G_ROLE_MAIN then
				G_ROLE_MAIN:updateSkills(skills)
			end
			local skillInfo = getConfigItemByKey("SkillCfg","skillID",skills[1])
			--if skills[1] < 9500 and skills[1] ~= 7100 then
			if skillInfo.jnfenlie and skillInfo.jnfenlie == 1 then
				local name = getConfigItemByKey("SkillCfg","skillID",skills[1],"name")
				local msgstr = game.getStrByKey("getNewSkill")..name
				TIPS( { type = 1 , str = msgstr } )
				self:setSkillSetting(skills[1])
			end
			-- local MskillOp = require "src/config/skillOp"
			-- local cool_time = MskillOp:skillCoolTime(skills[1],skills[2])
			-- if cool_time then
				-- require("src/base/BaseMapScene").skill_cds[skills[1]] = cool_time/1000
			-- end
			-- local canRegister = getConfigItemByKey("SkillCfg","skillID",skills[1],"canRegister")
			if skillInfo.canRegister and skillInfo.canRegister ~= 0 and skillInfo.jnfenlie ~= 9 then
				if G_SKILLPROP_POS then
					table.insert(G_SKILLPROP_POS,{skills[3],1,skills[1]})
				end	
				if (skills[3] == 0 or skills[3] == 20) and MRoleStruct and MRoleStruct:getAttr(ROLE_LEVEL) >= 10 then
					table.insert(G_SETPOSTEMP,skills[1])
					if #G_SETPOSTEMP <= 1 then
						require("src/layers/skillToConfig/newSkillConfigHandler").SkillConfig(G_SETPOSTEMP[1])
					end 
				else
					self:reloadSkillConfig()
				end				
			end
			checkSkillRed()
			checkWingSkillRed()
		end,
		[FRAME_SC_MESSAGE] = function()
			local tipClassType,tipID,paramCnt,lastSendMsg = nil,nil,nil,nil
			if buff then
                local proto = g_msgHandlerInst:convertBufferToTable("FrameScMessageProtocol", buff) 
                if not proto then
                	tipClassType,tipID,lastSendMsg,paramCnt = buff:readByFmt("sssc")
                	local msg_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{tipClassType,tipID})
                	print(msg_item.msg,tipClassType,tipID)
                	TIPS( { type = 1 , str = game.getStrByKey("protoWarning") .. "tipClassType=[" .. tipClassType .."] tipID=[" .. tipID .. "]" } )
                    return;
                end
				tipClassType = proto.eventId;
                tipID = proto.eCode;
                lastSendMsg = proto.mesId;
                paramCnt = #proto.param;
				-- print("receive tipClassType .. tipID"..tipClassType.."tipID"..tipID.."lastSendMsg"..lastSendMsg)
				local msg_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{tipClassType,tipID})
				--if msg_item and string.find(msg_item.msg,game.getStrByKey("noGold1")) and (not string.find(msg_item.msg,game.getStrByKey("theBind"))) then
					--MessageBoxYesNo(nil,game.getStrByKey("noGold"),function() __GotoTarget( { ru = "a33" } ) end)
					--return现在含有“元宝不足”的提示都不能显示所以注释这一行
				--end
				-- if msg_item and tipClassType == 15000 and tipID == -5 then --暂时处理骑马脚步
				-- 	if G_MY_STEP_SOUND then
				-- 	    AudioEnginer.stopEffect(G_MY_STEP_SOUND) 
				-- 	    G_MY_STEP_SOUND = nil
				-- 	end
					-- G_MY_STEP_SOUND =  AudioEnginer.randStepMus(nil)
				-- end
				if tipClassType == 5000 and tipID == -5 then
					self.bag_full_time = self.bag_full_time + 1
				end
				if tipClassType == EVENT_FACTIONCOPY_SET then
					log("receive [FRAME_SC_MESSAGE] under faction copy. %d.", tipID)
					if tipID == -17 then	-- 开始打BOSS
						if G_MAINSCENE then
							G_MAINSCENE:showBaseButtonFactionBoss(false, true)
						end
					elseif tipID == -19 then	-- 玩家复活

						local strX = proto.param[1];
						local strY = proto.param[2];
						local posX = tonumber(strX)
						local posY = tonumber(strY)
						if G_MAINSCENE then
							local funcE = function()
								G_MAINSCENE.map_layer:moveMapByPos(cc.p(posX, posY), true)
							end
							performWithDelay(self,funcE,1.0)
							log("[FactionFB Player relive] posX = %d, posY = %d.", posX, posY)
						--	G_MAINSCENE.map_layer:moveMapByPos(cc.p(posX, posY), true)
						--	local detailMapNode = require("src/layers/map/DetailMapNode")
						--	detailMapNode:goToMapPos(6006, cc.p(posX+2, posY+2), false)
						end
					elseif tipID == -20 then	-- 结束打BOSS
						if G_MAINSCENE then
							G_MAINSCENE:showBaseButtonFactionBoss(false, false)
							G_MAINSCENE:setFactionRedPointVisible(2, false)
						end
					end
                elseif tipClassType == EVENT_COPY_SETS then
                    if tipID == -56 then    -- 屠龙传说倒计时 [这种情况下，已经成功了]
                        if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isfb then
                            if G_MAINSCENE.map_layer.m_timePanel ~= nil then
                                local tmpSpr = tolua.cast(G_MAINSCENE.map_layer.m_timePanel, "cc.Sprite");
                                if tmpSpr ~= nil then
                                    tmpSpr:setVisible(false);
                                end
                            end
                            if G_MAINSCENE.map_layer.timeLeft ~= nil then
                                G_MAINSCENE.map_layer.timeLeft = tonumber(proto.param[1]);
                            end

                            G_MAINSCENE.map_layer:ChangeDragonPlotReq();

                            G_MAINSCENE.map_layer:RemoveMasterThunderEff(true);
                        end
                        -- 不需要继续处理弹出tips
                        return;
                    elseif tipID == -53 then    ---- 多人守卫需要不显示死亡不能复活的主角模型, 继续处理tips
                        if G_MAINSCENE and G_MAINSCENE.base_node and G_ROLE_MAIN and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.mapID == 5104 then
                            if not G_MAINSCENE.map_layer.m_noMoreRelive then
                                G_MAINSCENE.map_layer.m_noMoreRelive = true;

                                G_ROLE_MAIN:setVisible(false);
                            else
                                -- 不需要继续处理弹出tips, 防止弹出两次
                                return;
                            end

                            -- 添加蒙板
                            if G_MAINSCENE.base_node:getChildByTag(commConst.TAG_MULTI_CARBON_MASK) == nil then
                                local colorbg = cc.LayerColor:create(cc.c4b(0, 0, 0, 150));
	                            G_MAINSCENE.base_node:addChild(colorbg, commConst.ZVALUE_UI, commConst.TAG_MULTI_CARBON_MASK);
                            end
                        end
                    end
				elseif tipClassType == 31000 then
					if tipID == 71 then
						if checkLocalKeyTime("AreaFightReady" ..sdkGetOpenId(), 1) then
							--liuAudioPlay("sounds/liuVoice/55.mp3",false)
						end
					elseif tipID == 79 then
						if checkLocalKeyTime("BiqiReady" ..sdkGetOpenId(), 1) then
							--liuAudioPlay("sounds/liuVoice/57.mp3",false)
						end
					elseif tipID == 83 then
						if checkLocalKeyTime("ShaWarReady" ..sdkGetOpenId(), 1) then
							liuAudioPlay("sounds/liuVoice/59.mp3",false)
						end
					end
                elseif tipClassType == ESPASS_CS_SET_PASSWORD then
                    if tipID == -7 then
                        require("src/layers/setting/SecondaryPassword").inputPassword()
                    end
				end

				local msgStr = ""
				if msg_item and msg_item.fat then
					if msg_item.mid == 36 and msg_item.sth == 31000 then
						msgStr = string.format( msg_item.msg , proto.param[1], getConfigItemByKey("monster","q_id", tonumber(proto.param[2]),"q_name"), proto.param[3] )
						TIPS( { type = msg_item.tswz , str = msgStr , flag = msg_item.flag } )
					else
                        if #proto.param == 0 then
                            msgStr = "sth = " .. msg_item.sth .. " mid = " .. msg_item.mid .. "Error !";
                        else
						    msgStr = string.format( msg_item.msg , unpack(proto.param) )
                        end
                        if (msg_item.mid == 50 or msg_item.mid == 94) and msg_item.sth == EVENT_PUSH_MESSAGE then
                            -- 悬赏公告类处理多个到达
                            if self.m_notice ~= nil and self.m_isPlayingNotice then
                                self.m_notice:PushLeft({ type = msg_item.tswz , str = msgStr })
                            else
                                TIPS( { type = msg_item.tswz , str = msgStr , flag = msg_item.flag } )
                                self.m_isPlayingNotice = true;
                            end
                        else
						    TIPS( { type = msg_item.tswz , str = msgStr , flag = msg_item.flag } )
                        end
					end
				elseif msg_item and tipClassType == EVENT_FACTIONCOPY_SET and tipID == -14 then
					local funcTipsDelay = function()
						TIPS(msg_item)
					end
					performWithDelay(self, funcTipsDelay, 1.5)
				else
					if not msg_item then
						local tipClassType = tipClassType or "nill"
						local tipID = tipID or "nill"
                        TIPS( { type = 1 , str = "error tipClassType = ".. tipClassType..",tipID =" .. tipID } );
                        return;
					end

                    if (msg_item.mid == 113 or msg_item.mid == 114) and msg_item.sth == EVENT_PUSH_MESSAGE then
                        -- 悬赏公告类处理多个到达
                        if self.m_notice ~= nil and self.m_isPlayingNotice then
                            self.m_notice:PushLeft(msg_item);
                        else
                            TIPS( msg_item )
                            self.m_isPlayingNotice = true;
                        end
                    else
                        TIPS( msg_item )
                    end
				end
			else
				tipClassType,tipID = params[1],params[2]
				local midCfg = { 2 , 3 , -9 }
				local def_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{ 3000 , midCfg[tipClassType] })

				local msg_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{tipClassType,tipID})
				if msg_item and msg_item.fat then
					local msgStr = string.format(msg_item.msg,params[3],params[4],params[5])
					TIPS( { type = msg_item.tswz , str = msgStr } )
				else
					if not def_item then
						local tipClassType = tipClassType or "nill"
						local tipID = tipID or "nill"
						error("error tipClassType = ".. tipClassType..",tipID =" .. tipID )
					end
					TIPS( def_item )
				end

			end

		end,

		[FRAME_GW_HEART_BEAT] = function()
			--log("receive FRAME_GW_HEART_BEAT")
			if self.pingNode then
				self.pingNode:check(FRAME_GW_HEART_BEAT, buff)
			end
		end,
		[FRAME_SC_PICKUP] = function()
			self:onPickUp(buff)
		end,
		[FRAME_SC_PROP_UPDATE] = function()
			self:onPropUpdate(buff)
		end,
		[LITTERFUN_SC_NOTIFY_MONEYTREE] = function()
			TIPS( { type = 1 , str = "金币不足，无法进行操作" }  )
		end,
		[COPY_SC_ENTERCOPY] = function()
			local retTable = g_msgHandlerInst:convertBufferToTable("EnterCopyRetProtocol", buff)
		    userInfo.currCircle = retTable.curCircle
		    userInfo.timeLeft = retTable.remainTime
		end,

		[RELATION_SC_BE_FRIEND] = function()
			local t = g_msgHandlerInst:convertBufferToTable("BeFriendProtocol", buff) 
			local id = t.roleSID
			local name = t.targetName
			if G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_FRIEND) then
				table.insert(G_FIREND_DATA, 1, {id=id, name=name})
				self:createFriendNoticeNode(G_FIREND_DATA)
			end
		end,
		-- 推送积分数据
		[PUSH_SC_RED_MARK] = function()
			local t = g_msgHandlerInst:convertBufferToTable("PushRedBagMark", buff)
			G_jifen = t.mark
			dump(G_jifen,"G_jifen")
		end,
		-- [SKILL_SC_LOADSHORTCUTKEY] = function()
		-- 	local MpropOp = require "src/config/propOp"
		-- 	local propData = MpropOp.isInSkill()
		-- 	table.insertto(G_SKILLPROP_POS,propData,#G_SKILLPROP_POS+1)
		-- 	local skillPropNum = buff:popChar()
		-- 	for i =1 ,skillPropNum do
		-- 		local data = {buff:popChar(),buff:popChar(),buff:popInt()}
		-- 		for k,v in pairs(G_SKILLPROP_POS) do
		-- 			if v[3] == data[3] then
		-- 				v[1] = data[1]
		-- 			end
		-- 		end
		-- 	end
		-- end,
		[COPY_SC_GETCOPYTOWERDATA_RET] = function()
			local towerInfo ={}
			local retTable = g_msgHandlerInst:convertBufferToTable("CopyGetTowerDataRetProtocol", buff)

			towerInfo.restTime = retTable.resetNum  --当前已经重置次数
			if G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_FB_TOWER)then
				DATA_Battle:setRedData( "TTT" , (towerInfo.restTime == 0 ))
			end
		end,
		[SKILL_SC_DELETESKILL] = function()
			local removeskill = g_msgHandlerInst:convertBufferToTable("SkillDelteProtocol", buff)
			local removeskillid = removeskill.skillId
            local i = 1
            local isAdd = true
            while G_SKILLPROP_POS[i] do
            	isAdd = true
            	for k,v in pairs(removeskillid) do
                	if G_SKILLPROP_POS[i][3] == v then
                		table.remove(G_SKILLPROP_POS,i)
                		isAdd = false
                		break
                	end
                end
                if isAdd then
                	i = i+1
                end
            end
			self:reloadSkillConfig(false)
            TIPS({type=1,str=game.getStrByKey("jy_skill_reset")})
		end,
		[SKILL_SC_CLEAR_COOL] = function()
			local resetCd =  g_msgHandlerInst:convertBufferToTable("SkillClearCoolProtocol", buff)
			local resetCdskillid = resetCd.skillId
			local BaseMapScene = require("src/base/BaseMapScene")
			for k,v in pairs(resetCdskillid) do
				BaseMapScene.skill_cds[v] = 0
				G_MAINSCENE:releaseCdShow(v,0,1)
			end
		end,
		[COMMON_SC_GETMAINOBJECT_RET] = function()
			local mainLineTarget = g_msgHandlerInst:convertBufferToTable("GetMainObjectRetProtocol",buff)
			local haveDone = {{} , {}}
			for k,v in pairs(mainLineTarget.doneObjectID) do
				table.insert(haveDone[1],v)

			end
			for k , v in pairs(mainLineTarget.takeRewardObjectID) do
				table.insert(haveDone[2],v)
			end		
			self:setOrGetMainLineData(1,haveDone)
			local cb = function()
				self:createTargetAwards()
			end
			performWithDelay(self, cb, 0.5)
		end,
		[ITEM_SC_USEMATERIAL] = function( ... )
			-- body
			print("ITEM_SC_USEMATERIAL", ITEM_SC_USEMATERIAL)
			local stTable = g_msgHandlerInst:convertBufferToTable("ItemUseRetProtocol", buff)
			local msg_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{ 1 , 18 })
			if msg_item then
				TIPS( { type = msg_item.tswz , str = msg_item.msg , numOrId = { stTable.itemID } , objNum = stTable.itemNum} )
			end
		end,
	}

 	if switch[msgid] then switch[msgid]() end

end

return BaseMapNetNode
			
