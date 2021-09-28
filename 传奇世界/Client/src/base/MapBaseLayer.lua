local MapBaseLayer = class("MapBaseLayer", function() return  MapView:create() end)
MapBaseLayer.max_tips_time = 0

local commConst = require("src/config/CommDef");

function MapBaseLayer:ctor(strname,parent,r_pos,mapId)
	self.parent = parent
	self.mapID = mapId
	self:registerMsgHandler()
	self:initialize(r_pos)
end

function MapBaseLayer:initializePre()
	self.updata_time = 0
	--self.hurt_num_count = 0
	self.item_Node = nil

	local lab_ttf = {}
    lab_ttf.fontFilePath = g_font_path
    lab_ttf.fontSize = 14
    lab_ttf.outlineSize = 1
    self.item_batchlabel = MirBatchDrawLabel:createWithTTF(lab_ttf)
	self.item_batchlabel:setPosition(cc.p(0, 0))
	self:addChild(self.item_batchlabel,5)
	self.item_batchlabel_top = MirBatchDrawLabel:createWithTTF(lab_ttf)
	self.item_batchlabel_top:setPosition(cc.p(0, 0))
	self:addChild(self.item_batchlabel_top,11)

	self.skill_item_Node = nil
	
	self.npc_tab = {}
	self.mineTab = {}
	self.monster_tab = {}
	self.spec_tab = {}
	self.goods_tab = {}
	self.goods_tilepos = {}
	self.pet = {}
	self.pet_tab = {}
	self.role_tab = {}
	self.role_actions = {}
	self.hide_flags = {}
	self.move_paths = {}
	self.stop_rock = {}
	self.rock_status = {}
	self.skill_todo = {}
	self.attackinfo = {}
	self.carry_owner_objid = {}
	self.banner_owner_objid = {}
	self.need_halfhide_objs = {}
    -- 朋友助战，数据与实体分开
    self.m_friendsData = {};
    self.hurt_node = cc.Sprite:create("res/mainui/number/hurt.png",cc.rect(0,0,1,1))
    self:addChild(self.hurt_node,5000)

	self:registerScriptHandler(function(event)
		if event == "enter" then
            print("map base layer event enter ...................................................................")
            require("src/layers/weddingSystem/WeddingSysCommFunc").addOrDeleteAutoPlayLayer(false)
            require("src/layers/weddingSystem/WeddingSysCommFunc").showLieYueShiNpc(false)
            local function showMenus(isShow)
                if self.parent.topLeftNode then
                    self.parent.topLeftNode:setVisible(isShow)
                end
                if self.parent.taskBaseNode then
                    self.parent.taskBaseNode:setVisible(isShow)
                end
                if self.parent.topRightNode then
                    self.parent.topRightNode:setVisible(isShow)
                end
                if self.parent.tasknewFunctionNode then
                    self.parent.tasknewFunctionNode:setVisible(isShow)
                end
                require("src/layers/weddingSystem/WeddingSysCommFunc").isWeddingSys = not isShow
                if G_CHAT_INFO.chatPanel then
                    G_CHAT_INFO.chatPanel:setVisible(isShow)
                end
            end
            
            showMenus(true)

			local map_name = getConfigItemByKey("MapInfo","q_map_id",self.mapID,"q_map_name") 
			if map_name then MdsAgent:startTracePage(map_name) end
			if self.isJjc then
				self.pk_mode = require("src/layers/pkmode/PkModeLayer"):getCurMode()
			 	require("src/layers/pkmode/PkModeLayer"):setCurMode(3)
	            if self.parent.attackmode_node then
	                self.parent.attackmode_node:setImages("res/mainui/pkmode/4.png")
                    if self.parent.m_pkModeLal then
                        self.parent.m_pkModeLal:setString(game.getStrByKey("pkmode_quanti_str"));
                    end
	            end
	        elseif isBattleArea(self.mapID) or self.mapID == 6003 then
				self.pk_mode = require("src/layers/pkmode/PkModeLayer"):getCurMode()
			 	if G_ROLE_MAIN then
			 		g_msgHandlerInst:sendNetDataByTable(FRAME_CS_CHANGE_MODE , "FrameChangeModeProtocol", {mode = 2})
			 	end
            elseif self.mapID == 2200 then
                print("self.mapID == 2200 then ...............................................................")
                local pos = self:tile2Space(cc.p( 20,30))
                if MRoleStruct:getAttr(PLAYER_SEX) == 2 then
                    -- female 21 29
                    pos = self:tile2Space(cc.p( 24,31))    
                end
                local effect = Effects:create(false)
                effect:playActionData("storyEndPoint", 11, 2, -1)
                effect:setAnchorPoint(cc.p(0.5, 0.47))
                effect:setPosition( pos )
                addEffectWithMode(effect, 3)
                self.item_Node:addChild(effect,0,111111)
                --self.parent.smallMap:setVisible(false)
                showMenus(false)
            
	        else
	        	self.pk_mode = require("src/layers/pkmode/PkModeLayer"):getCurMode()
	            if self.parent.attackmode_node then
	                self.parent.attackmode_node:setImages("res/mainui/pkmode/"..(self.pk_mode+1)..".png")
                    if self.parent.m_pkModeLal then
                        local pkModeStrs = {
                            game.getStrByKey("pkmode_heping_str"),
                            game.getStrByKey("pkmode_zudui_str"),
                            game.getStrByKey("pkmode_banghui_str"),
                            game.getStrByKey("pkmode_quanti_str"),
                            game.getStrByKey("pkmode_shane_str"),
                            game.getStrByKey("pkmode_gongsha_str")
                        }
                        self.parent.m_pkModeLal:setString(pkModeStrs[self.pk_mode+1]);
                    end
	            end
	        end
		elseif event == "exit" then
			local map_name = getConfigItemByKey("MapInfo","q_map_id",self.mapID,"q_map_name") 
			if map_name then MdsAgent:endTracePage(map_name) end
			if (self.isJjc or isBattleArea(self.mapID) or self.mapID == 6003) and self.pk_mode then
				game.setAutoStatus(0)
				if self.isJjc then
					require("src/layers/pkmode/PkModeLayer"):setCurMode(self.pk_mode)
				else
					if G_ROLE_MAIN then
				 		g_msgHandlerInst:sendNetDataByTable(FRAME_CS_CHANGE_MODE , "FrameChangeModeProtocol", {mode = self.pk_mode})
				 	end
				end
			end
			if self.scheduler and self.schedulerHandle then
                self.scheduler:unscheduleScriptEntry(self.schedulerHandle)
            end
		end
	end)
	
	local checkFrameRate = function() 
		if not self.total_frame then
			self.total_frame = Director:getTotalFrames()
		else
			local total_frame = Director:getTotalFrames()
			local span_frame = total_frame - self.total_frame
			if span_frame < 600 and MapBaseLayer.max_tips_time < 3 then
				if getGameSetById(GAME_SET_ID_CLOSE_VOICE) == 1 then
					TIPS( { type = 1 , str = game.getStrByKey( "sys_tips1" ) }  )
				else
					TIPS( { type = 1 , str = game.getStrByKey( "sys_tips2" ) }  )
				end
				MapBaseLayer.max_tips_time = MapBaseLayer.max_tips_time + 1
			end
			self.total_frame = total_frame
		end
		--print("self.total_frame",self.total_frame)
	end
	if MapBaseLayer.max_tips_time < 3 then
		schedule(self,checkFrameRate,30)
	end
end

function MapBaseLayer:loadMapInfo(strname,mapId,r_pos)
	self.mapID = mapId

	local load_map_info = getConfigItemByKey("MapInfo","q_map_id",self.mapID)

	self.mapResid = load_map_info.q_mapresid

	if load_map_info.q_newmap then
		self:loadMapNew(strname,mapId,r_pos)
	else
		self:loadMap(strname,mapId,r_pos)
	end
------------------------------------------------------
	self.item_Node = self:GetItemRoot()
	self.skill_item_Node = MapView:getSkillNode()

------------------------------------------------------
	self:initNodeItemTouch()

	self:initialize(r_pos)
	if self.addTransfor then
		--传送圈
		self:addTransfor(mapId)
	end
	if self.setShaWarTransfor then
		self:setShaWarTransfor()
	end
	if self.setSharWarMapBlock then
		self:setSharWarMapBlock()
	end
	if getGameSetById(GAME_SET_SHOWSKILLEFFECT) == 1 then
		if self.skill_item_Node then
			self.skill_item_Node:setVisible(false)
		end
		local skill_down_Node = MapView:getSkillDownNode()
		if skill_down_Node then
			skill_down_Node:setVisible(false)
		end
	end
end

function MapBaseLayer:taskInit()
end

function MapBaseLayer:isNeedOpacity(t_pos)
	if G_ROLE_MAIN and cc.pGetDistance(t_pos,G_ROLE_MAIN.tile_pos) <=1 and t_pos.y >= G_ROLE_MAIN.tile_pos.y and t_pos.x == G_ROLE_MAIN.tile_pos.x then
	--if (t_pos.y >= G_ROLE_MAIN.tile_pos.y and t_pos.y -G_ROLE_MAIN.tile_pos.y <=1 and math.abs(t_pos.x-G_ROLE_MAIN.tile_pos.x)<=1) then
		return true
	end
	return false
end

function MapBaseLayer:isHideMode(hide_icon)
	return self.isMine or self.isfb or self.isJjc or self.is3v3 or self.isExerciseRoom or (self.parent.isHide_icon and (not hide_icon)) or self.isFactionFb or self.isMysteriousMap
end

function MapBaseLayer:initialize(r_pos)
	if G_ROLE_MAIN then 
		if not (G_ROLE_MAIN:getParent()) then
			self.item_Node:addChild(G_ROLE_MAIN,r_pos.y,G_ROLE_MAIN.obj_id)
			G_ROLE_MAIN:onRestore()
			G_ROLE_MAIN:release()
			G_ROLE_MAIN:standed()
			G_ROLE_MAIN:reloadRes()
			--self:onBuffUpdate(G_ROLE_MAIN.obj_id, nil,true)
		else 
			G_ROLE_MAIN:setPosition(self:tile2Space(r_pos))
		end
		if self:isOpacity(cc.p(r_pos.x,r_pos.y)) then
			G_ROLE_MAIN:setOpacity(100)
		else
			G_ROLE_MAIN:setOpacity(255)
		end

		local init = function()
			
			G_MAINSCENE:QryMonsterNameColor(G_ROLE_MAIN.obj_id)

			local specialTitle = require("src/layers/role/RoleStruct"):getAttr(PLAYER_SPECIAL_TITLE_ID)
			if specialTitle then
				G_ROLE_MAIN:setSpecialTitle(G_ROLE_MAIN, specialTitle)
			end

			if not (g_buffs_ex and g_buffs_ex[G_ROLE_MAIN.obj_id] and g_buffs_ex[G_ROLE_MAIN.obj_id][6]) then
				G_ROLE_MAIN:setColor(cc.c3b(255,255,255))
			end
			self:initDataAndFunc(r_pos)
		end
		performWithDelay(self.item_Node,init,0)
		self:setSkillMap()
		if g_speed_time then
			self:resetSpeed(g_speed_time)
		end
	end
	local Tab = {		
			["equip"] = {
				GAME_SET_ID_PICKUP_WHITE_EQUIP,
				GAME_SET_ID_PICKUP_GREEN_EQUIP,
				GAME_SET_ID_PICKUP_BLUE_EQUIP,
				GAME_SET_ID_PICKUP_VIOLET_EQUIP,
				GAME_SET_ID_PICKUP_ORANGE_EQUIP,
			},
			["drug"] = {
				GAME_SET_ID_PICKUP_WHITE_MATERIAL,
				GAME_SET_ID_PICKUP_GREEN_MATERIAL,
				GAME_SET_ID_PICKUP_BLUE_MATERIAL,
				GAME_SET_ID_PICKUP_VIOLET_MATERIAL,
				GAME_SET_ID_PICKUP_ORANGE_MATERIAL,
			},
			["other"] = {
				GAME_SET_ID_PICKUP_WHITE_OTHER,
				GAME_SET_ID_PICKUP_GREEN_OTHER,
				GAME_SET_ID_PICKUP_BLUE_OTHER,
				GAME_SET_ID_PICKUP_VIOLET_OTHER,
				GAME_SET_ID_PICKUP_ORANGE_OTHER,
			},
		}
	local qua = function(str,tag) 
		return (getGameSetById(Tab[str][tag]) and getGameSetById(Tab[str][tag]) == 0)
	end
	local propOp = require("src/config/propOp")
	local MPackStruct = require "src/layers/bag/PackStruct"
	local isAsTheSetting = function(k)
		local item = k
		if  k~=100 and k~=200 and k~=300 then
			local quality =  propOp.quality(k)
			if (not quality) or quality == 0 then quality = 1 end
			local Category = MPackStruct:getCategoryByPropId(k)
			if Category == MPackStruct.eEquipment and ((getGameSetById(GAME_SET_AUTO_EQUIP) == 1 and qua("equip",quality)) or getGameSetById(GAME_SET_AUTO_EQUIP) == 0) then
				-- print("aaaaaaaaaaaaaaaaaaa111111111111111111111111")
				item = nil
			elseif Category == MPackStruct.eMedicine and ((getGameSetById(GAME_SET_AUTO_DRUG) == 1 and qua("drug",quality)) or getGameSetById(GAME_SET_AUTO_DRUG) == 0) then
				-- print("bbbbbbbbbbbbbbbbbbbbbbb111111111111111111111111111")
				item = nil
			elseif (not (Category == MPackStruct.eEquipment or Category == MPackStruct.eMedicine)) and ((getGameSetById(GAME_SET_AUTO_OTHER) == 1 and qua("other",quality)) or getGameSetById(GAME_SET_AUTO_OTHER) == 0) then
				-- print("cccccccccccccccccccccccccc1111111111111111111111111111")
				item = nil
			end
		elseif (not auto) and getGameSetById(GAME_SET_ID_PICKUP_MONEY) == 0 then
			-- print("dddddddddddddddddddddddddddd1111111111111111111111111")
			item = nil
		end
		-- dump(item,"1111111111111111111111111222222222222222222")
		return item
	end
	local func = function(flag,flag_ex,flag_reset)
		if flag and flag_ex then
			self:doCheckPosition(cc.p(flag,flag_ex))
			if flag_reset and G_MAINSCENE then
				self.common_cd = nil
				self:onRoleAttack()
				resetGmainSceneTime()
				self.common_cd = true
				local comFunc = function()
					self.common_cd = nil
				end
				performWithDelay(self,comFunc,0.5)
			end
	    elseif flag then
	    	local status = game.getAutoStatus()
	    	if flag < 3 then
				self.caiji_num = nil
				if flag > 0 then
	    			self.on_pickup = nil
					self:removeWalkCb() 
					local detailMapNode = require("src/layers/map/DetailMapNode")
					detailMapNode:setDetailMapInfo()
					DATA_Mission:setAutoPath(false)
					DATA_Mission:setTempFindPath( nil )
					DATA_Mission:setLastTarget()
					--DATA_Mission:setLastFind( nil )
					if status ~= AUTO_ATTACK then
						game.setAutoStatus(0)
					end	
					self.on_attack = nil
					self.skill_todo = {}
					self.resetHangup_tile = true
					if self.rock_action then
						self.item_Node:stopAction(self.rock_action)
						self.rock_action = nil
					end
					game.setMainRoleAttack(true)
				end
				if G_ROLE_MAIN and G_ROLE_MAIN.isHoe then
					G_ROLE_MAIN:isChangeToHoe(G_ROLE_MAIN, false)
				end
				if not G_MY_STEP_SOUND and G_ROLE_MAIN then
					G_MY_STEP_SOUND =  AudioEnginer.randStepMus(G_ROLE_MAIN.up_ride)
				end
			elseif flag < 5 and G_ROLE_MAIN then
				if status ~= AUTO_ATTACK and status ~= AUTO_MATIC and status ~= AUTO_ESCORT  then
					--game.setAutoStatus(0)
					self.parent:playHangupEffect(2)
				end
				if not self.common_cd then
					resetGmainSceneTime()
				end
				local get_good = false
				local get_good_owner = nil
				local role_tile_pos = self:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
				for v,k in pairs(self.goods_tab) do
					local drop_tile = self.goods_tilepos[v]
					if drop_tile and role_tile_pos.x == drop_tile.x and role_tile_pos.y== drop_tile.y then
						if self.isStory then
                            self.item_Node:removeChildByTag(v)
                            self.goods_tab[v] = nil
                            if G_MAINSCENE.storyNode.onPickGoods then
                                 G_MAINSCENE.storyNode:onPickGoods()
                            end
                            break
                        end
                        
                        local owner = MRoleStruct:getAttr(ROLE_HP,v) or 0
						if status == AUTO_ATTACK and (not self.pick_by_handle) then--or status == AUTO_PICKUP then
							if (owner == 0 or owner == G_ROLE_MAIN.obj_id and k) then
								if isAsTheSetting(k) then
									if get_good then
										local quality =  propOp.quality(v)
										local old_quality =  propOp.quality(get_good)
										if quality > old_quality then
											get_good = v
										end
									else
										get_good = v
									end	
								end
							end
						else
							if get_good then
							local quality =  propOp.quality(v)
								local old_quality =  propOp.quality(get_good)
								if quality > old_quality then
									get_good = v
								end
							else
								get_good = v
							end								
						end
					end
				end
				self.pick_by_handle = nil
				self.on_pickup = nil
				if get_good then
					if not (self.has_send_pickup and self.has_send_pickup == get_good) then
						g_msgHandlerInst:sendNetDataByTable(FRAME_CS_PICKUP,"FramePickUpProtocol",{mpwID = get_good})

						if status == AUTO_ATTACK or status == AUTO_PICKUP then
							self.on_pickup = true
							self:resetSelectMonster()
						end
						--performWithDelay(self.item_Node,autoPick,0.25)
						self.has_send_pickup = get_good
					end

					local autoReset = function()
						self.on_pickup = nil
						if self.has_send_pickup then
							self:autoPickUp()
						end
						self.has_send_pickup = nil
					end
					local good_item = self.item_Node:getChildByTag(get_good)
					if good_item then
						performWithDelay(good_item,autoReset,1.0)
					end
				end
				if G_MY_STEP_SOUND then
					AudioEnginer.pauseEffect(G_MY_STEP_SOUND) 
					local play_step = G_MY_STEP_SOUND
					performWithDelay(self.item_Node,function() AudioEnginer.stopEffect(play_step)   end,0.0)
					G_MY_STEP_SOUND = nil
				end
				--[[
				if game.getAutoStatus() ~= AUTO_PATH_MAP and game.getAutoStatus() ~= AUTO_PATH then
					local detailMapNode = require("src/layers/map/DetailMapNode")
					detailMapNode:setDetailMapInfo()
				end
				]]
				local select_node = self.select_monster --or self.select_role
				if select_node and (not self.isStory) then
					select_node = tolua.cast(select_node,"SpriteMonster")
					if select_node and select_node:isAlive() then
						local tile_pos = select_node:getServerTile()
						if math.abs(tile_pos.x-G_ROLE_MAIN.tile_pos.x) > 15 or math.abs(tile_pos.y-G_ROLE_MAIN.tile_pos.y) > 15 then
							self:resetSelectMonster()
							self.select_role = nil
							if self.monster_head and tolua.cast(self.monster_head,"cc.Node") then
								removeFromParent(self.monster_head)
								self.monster_head = nil
							end
						end
					end
				end
				if self.resetHangup_tile and G_MAINSCENE.hangup_tile then
					G_MAINSCENE.hangup_tile = G_ROLE_MAIN.tile_pos
					self.resetHangup_tile = nil
				end
			elseif flag == 5 then
				if G_MY_STEP_SOUND then
					AudioEnginer.pauseEffect(G_MY_STEP_SOUND) 
					local play_step = G_MY_STEP_SOUND
					performWithDelay(self.item_Node,function() AudioEnginer.stopEffect(play_step)   end,0.0)
					G_MY_STEP_SOUND = nil
				end
				if G_MAINSCENE.hangup_tile then
					G_MAINSCENE.hangup_tile = G_ROLE_MAIN.tile_pos
				end
				self.resetHangup_tile = nil
			end

		end
	end
	self:registerRockerCb(func)

	local touchMove = function(is_up_ride,obj_id)
		if G_ROLE_MAIN then
			if obj_id and obj_id ~= G_ROLE_MAIN.obj_id  then
				local role = self:isValidStatus(obj_id)
				if role then
					G_ROLE_MAIN:upOrDownRide_ex(role,nil,nil,true)
				end
			else
				if is_up_ride then
					G_ROLE_MAIN:upOrDownRide(is_up_ride)
				else
					G_ROLE_MAIN:upOrDownRide_ex(G_ROLE_MAIN,is_up_ride)
				end
			end
		end
	end
	self:registerTouchMoveCb(touchMove)

	local onHurtFunc = function(objId,attackId,hurt,cur_blood,resistType,...)
		if G_ROLE_MAIN then
			if objId == G_ROLE_MAIN.obj_id then
				local attacker = nil
				local args = {...}
				if attackId and attackId > 1 then
					attacker = tolua.cast(self.item_Node:getChildByTag(attackId),"SpriteMonster")
				end
				if attacker then
					local attack_type = attacker:getType()
					local my_sex = MRoleStruct:getAttr(PLAYER_SEX)
					if hurt > 0 then
						if hurt > G_ROLE_MAIN:getMaxHP()*0.1 then
							if my_sex == 2 then
								AudioEnginer.playEffect("sounds/actionMusic/102.mp3",false)
							elseif my_sex == 1 then
								AudioEnginer.playEffect("sounds/actionMusic/2.mp3",false)
							end
						end
						G_ROLE_MAIN:updateData()
						--挂机自动反击
						if game.getAutoStatus() == AUTO_ATTACK and attack_type >= 20 and  getGameSetById(GAME_SET_ID_ELUDE_MONSTER) == 1 then
							--g_msgHandlerInst:sendNetDataByFmt(FRAME_CS_CHANGE_MODE , "ic", G_ROLE_MAIN.obj_id,4)
							local select_role = tolua.cast(self.select_role,"SpritePlayer")
							if (not select_role) then
								self:removeWalkCb()
								local doAttack = function() self:touchRoleFunc(attacker) end
								performWithDelay(self,doAttack,0.5)
								--和平模式下修改为善恶攻击模式并在屏幕上提示
								local MPkModeLayer = require("src/layers/pkmode/PkModeLayer")
								if MPkModeLayer:getCurMode() == 0 and require("src/layers/role/RoleStruct"):getAttr(PLAYER_PK) < 6 and (not self.isJjc) then
									g_msgHandlerInst:sendNetDataByTable(FRAME_CS_CHANGE_MODE , "FrameChangeModeProtocol", {mode = 4})
									TIPS( { type = 1 , str = string.format(game.getStrByKey("tip_change_mode_auto"), attacker:getTheName()) }  )
								end
							end
						end
					end
				end
				self:bloodupdate(objId,cur_blood,true,attacker)
			else
				local args = {...}
				if resistType > 0 then
					local hurt_item = self:isValidStatus(objId)
					if hurt_item then
						self:onEntityHurt(hurt_item, objId, 0, 0, 0, attackId)
					end
				elseif cur_blood == 0 then
					self:bloodupdate(objId,0,true)
				end
			end

			local args_buff = {...}
			local buff_count = #args_buff
			for i = 1, buff_count do
				local buff_id = args_buff[i]
				local skill_id = getConfigItemByKey("buff", "id", buff_id, "is_shield")
				if skill_id ~= nil and skill_id > 0 then
					CMagicCtrlMgr:getInstance():CreateMagic(skill_id, 0, attackId, objId, 0);
				end
			end
		end 

	end
	self:registerHurtCb(onHurtFunc)

	self:addSaftArea()
    if self.mapID ~= 1000 then
	    startTimerAction(self, 0.5, false, showMapTip)
    end
    if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
    	local firePos={cc.p(9,35),cc.p(29,24),cc.p(52,26)}
		for k,v in pairs(firePos) do
			local effect = Effects:create(false)
		    effect:setPlistNum(-1)
		    effect:setAnchorPoint(cc.p(0.5,0.5))
		   	effect:playActionData2("petefire", 100, -1, 0)
			effect:setPosition(G_MAINSCENE.map_layer:tile2Space(v))
			G_MAINSCENE.map_layer.item_Node:addChild(effect, 0)
		end
		local clodPos={cc.p(19,52),cc.p(20,24),cc.p(44,11),cc.p(58,25)}
		for k,v in pairs(clodPos) do
			local effect = Effects:create(false)
		    effect:setPlistNum(-1)
		    effect:setAnchorPoint(cc.p(0.5,0.5))
		   	effect:playActionData2("petewind", 250, -1, 0)
			effect:setPosition(G_MAINSCENE.map_layer:tile2Space(v))
			effect:setFlippedY(true)
			effect:setScale(2)
			effect:setFlippedX(true)
			G_MAINSCENE.map_layer.item_Node:addChild(effect, 910)
		end	
	end

    DATA_Mission:setCallback("map_checkDig", function()
        --如果收到挖宝任务消息会触发
        local tile_pos = self:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
        local show_icon = require("src/layers/teamTreasureTask/teamTreasureTaskLayer"):checkShowDigIcon(self.mapID, tile_pos)
	    if self.parent then
		    if show_icon then
			    self.parent:createTaskDigIcon()
		    else
			    self.parent:removeTaskDigIcon()
		    end
	    end
    end)
end

function MapBaseLayer:addSaftArea()
	if self.safe_node and #self.safe_node > 0 then
		return
	end
	local addEffect = function(pos)
		local safe_effect = Effects:create(false)
		safe_effect:setPosition(self:tile2Space(pos))
		self.item_Node:addChild(safe_effect, 0)	
		safe_effect:playActionData("selfarea", 15, 1,-1,0)	
		if self:isBlock(pos) or self:isOpacity(pos) then
			safe_effect:setOpacity(108)
		end
		return safe_effect
	end
	local map_info = getConfigItemByKey("MapInfo","q_map_id",self.mapID)
	self.q_map_pk = map_info.q_map_pk
	if map_info then
		if map_info.q_map_safe_x then
			self.safe_centerpos = cc.p(map_info.q_map_safe_x,map_info.q_map_safe_y)
			self.q_radius = tonumber(map_info.q_radius)
			self.safe_node = {} 
			--[[
			--map_info.q_radius = map_info.q_radius
			local posy ,j= map_info.q_map_safe_y,0
			for i= (-1)*map_info.q_radius,map_info.q_radius do 
				local pos = cc.p(map_info.q_map_safe_x+i,posy+j)
				self.safe_node[#self.safe_node+1] = addEffect(pos)
				local pos = cc.p(map_info.q_map_safe_x+i,posy-j)
				self.safe_node[#self.safe_node+1] = addEffect(pos)
				if i >= 0 then 
					j= j - 1
				else
					j= j + 1
				end
			end
			]]
		elseif tonumber(map_info.q_all_safe) == 1 then
			self.is_all_safe = true
		end
	end
	if map_info.q_red then
		local safe_info = stringsplit(map_info.q_red,",")
		local safe_x,safe_y,safe_radius = tonumber(safe_info[1]),tonumber(safe_info[2]),tonumber(safe_info[3])
		self.red_safe_center = cc.p(safe_x,safe_y)
		self.red_radius = safe_radius
		--[[
		local posy ,j= safe_y,0
		for i= (-1)*safe_radius,safe_radius do 
			local pos = cc.p(safe_x+i,posy+j)
			self.safe_node[#self.safe_node+1] = addEffect(pos)
			local pos = cc.p(safe_x+i,posy-j)
			self.safe_node[#self.safe_node+1] = addEffect(pos)
			if i >= 0 then 
				j= j - 1
			else
				j= j + 1
			end
		end
		]]
	end
end

function MapBaseLayer:removeSaftArea()
	if self.safe_node then
		for i,v in ipairs(self.safe_node) do
			removeFromParent(v)
		end
	end
	self.safe_node = {}
	self.safe_centerpos = nil
end

function MapBaseLayer:resetHangup(flag)
	local currStatus = game.getAutoStatus()
	if currStatus >=AUTO_TASK then
		-- if currStatus == AUTO_MINE then
		-- 	g_msgHandlerInst:sendNetDataByFmtExEx(DIGMINE_CS_STOPDIGMINE,"i",userInfo.currRoleId)
		-- end
		game.setAutoStatus(0)
		self:removeWalkCb()
		--self.parent.hang_node:setImages("res/mainui/anotherbtns/hangup.png")
		-- local detailMapNode = require("src/layers/map/DetailMapNode")
		-- detailMapNode:setDetailMapInfo()
	end
end

function MapBaseLayer:resetItemData()
	--self.item_Node:stopAllActions()
	if self.isStory == true then
		return
	end
	if not self.skill_item_Node then
		self.skill_item_Node = MapView:getSkillNode()
	end
	for k,v in pairs(self.role_actions)do
		self.item_Node:stopAction(v)
		self.role_actions[k] = nil
		self.rock_status[k] = nil
	end
	if self.monster_tab then
		for k,v in pairs(self.monster_tab)do
			self.item_Node:removeChildByTag(v)
		end
	end
	if self.mineTab then
		for k,v in pairs(self.mineTab)do
			self.item_Node:removeChildByTag(v)
		end
	end
	if self.role_tab then
		for k,v in pairs(self.role_tab)do
			if k ~= self.role_id then
				--print("remove Child :",k)
				self.item_Node:removeChildByTag(v)
			end
		end
	end
	if self.pet then 
		for k,v in pairs(self.pet)do
			removeFromParent(v)
		end
	end
    -- 清空
    self.m_friendsData = {};
	if self.goods_tab then
		for v,k in pairs(self.goods_tab)do
			self.item_Node:removeChildByTag(v)
		end
	end

	if self.spec_tab then
		for v,k in pairs(self.spec_tab)do
			self.item_Node:removeChildByTag(v)
		end
	end
    -- 类似于 self.spec_tab 中，清除 C++中创建的魔法
    CMagicCtrlMgr:getInstance():ClearAllFloors();

	if G_ROLE_MAIN then
		G_ROLE_MAIN:setCarry_ex(G_ROLE_MAIN, {})
		G_ROLE_MAIN:setBanner(G_ROLE_MAIN, 0)
	end
	-- if self.item_batchlabel then
	-- 	self.item_batchlabel:removeAllChildren()
	-- end	
	self.monster_tab = {}
	self.mineTab = {}
	self.goods_tab = {}
	self.goods_tilepos = {}
	self.role_tab = {}
	self.pet = {}
	self.hide_flags = {}
	self.spec_tab = {}
	self.skill_todo = {}
	self.common_cd = nil
	self.on_pickup = nil
	self.has_send_pickup = nil
	self.carry_owner_objid = {}
	self.banner_owner_objid = {}
end

function MapBaseLayer:update()
	self.updata_time = self.updata_time + 1
	if self.updata_time >= 10000 then
		self.updata_time = 0
	end
	if G_MAINSCENE then
		if not G_MAINSCENE.temp_lock then
			self:onRoleAttack()
		end
		G_MAINSCENE.temp_lock = nil
	end
end

function MapBaseLayer:setDirectorScale(scale,tile_pos)
	local m_scale = scale or getGameSetById(GAME_SET_ID_SCALE_RATE)/100
	if m_scale then
		-- if g_scrSize.height > 640 then
		-- 	m_scale = m_scale*610/g_scrSize.height
		-- end 
		Director:setMapScale(m_scale)
		self:setScale(m_scale)
		--self:stopAllActions()
		--self:scroll2Tile(tile_pos or G_ROLE_MAIN.tile_pos)
		self:setShowNormalMonster()
	end
end

function MapBaseLayer:setShowNormalMonster(noset)
	local carCfg = { ["80000"] = true , ["80001"] = true , ["80002"] = true , ["80003"] = true , ["31"] = true, ["21"] = true, ["23"] = true} 
	for k,v in pairs(self.monster_tab)do
		local monster_node = tolua.cast(self.item_Node:getChildByTag(v),"SpriteMonster")
		local show = MRoleStruct:getAttr(ROLE_SHOW,k) or 1
		if monster_node then
			local monsterid = monster_node:getMonsterId()
			if not carCfg[ monsterid .. "" ]  then
				if monster_node:getType() < 12 then
					local host_name = MRoleStruct:getAttr(ROLE_HOST_NAME,k)
					if not host_name then
						monster_node:setVisible((getGameSetById(GAME_SET_ID_SHIELD_MONSTER) == 0) and (show == 1))
					end
				else 
					monster_node:setVisible( show == 1 )
				end
			end
		end
	end
end

function MapBaseLayer:setShowNormalPlayer(noset)
	for k,v in pairs(self.role_tab)do
		local role_node = tolua.cast(self.item_Node:getChildByTag(v),"SpritePlayer")
		if role_node and v~= self.role_id then
			role_node:setVisible(getGameSetById(GAME_SET_ID_SHIELD_PLAYER)==0)
		end
	end
end
function MapBaseLayer:makeMainRole(px,py,filepath,maxcut,isMe,objid,entity)
	local temp_id = objid
	--print("makeMainRole",objid)
	if not isMe then temp_id = 0 end
	local role_main
	if isMe and G_ROLE_MAIN then
		role_main = G_ROLE_MAIN
		role_main:refreshData(entity)
		self:resetTouchTag()
		role_main:setLocalZOrder(py)
		if role_main.obj_id ~= objid then
			role_main:setTag(objid)
			role_main:setRoleId(objid)
			self.role_tab[role_main.obj_id] = nil
		end
        if G_ROLE_MAIN:getChildByTag(1024) then
            G_ROLE_MAIN:removeChildByTag(1024)
        end
        if G_ROLE_MAIN.mineTab and tablenums(G_ROLE_MAIN.mineTab) > 0 then
            G_ROLE_MAIN.mineTab = {}
            G_ROLE_MAIN:setMine(G_ROLE_MAIN,{})
        end
        if G_ROLE_MAIN.sign_effect then
        	G_ROLE_MAIN.sign_effect:playActionData2("myselfsign",200,-1,0)
        	local func = function()
	        	if getGameSetById(GAME_SET_TOPARROW) == 0 then
	        		G_ROLE_MAIN.sign_effect:setVisible(false)
	        	end
	        end
        	performWithDelay(self,func,0.0)
        end
	else
		if self.role_tab[objid] then  
			self.item_Node:removeChildByTag(objid)
		end
		role_main = require("src/base/RoleSprite").new(filepath,temp_id,entity)
		self.item_Node:addChild(role_main,py,objid)
	end

	role_main:setServerTilePosByTile(px,py)

	if self:isOpacity(cc.p(px,py)) then
		role_main:setOpacity(128)
	else
		role_main:setOpacity(255)
	end
	if isMe then
		self:setMainRole(role_main)
		self.role_id = objid
		role_main.obj_id = objid
		userInfo.currRoleId = objid
		G_ROLE_MAIN = G_ROLE_MAIN or role_main
        self.parent:updateHeadInfo()
        self:initDataAndFunc(cc.p(px,py))
		if filepath then
			self:setDirectorScale(nil,cc.p(px,py))
			--self:scroll2Tile(cc.p(px,py))
			G_NFTRIGGER_NODE:initFunc()
		else
			self:resetItemData()
			if true or (cc.pGetDistance(G_ROLE_MAIN.tile_pos,cc.p(px,py))>3) then
				--传送
				G_ROLE_MAIN:stopAllActions()
				G_ROLE_MAIN:standed()
				self:doCheckPosition(cc.p(px,py))
			end
		end
		self:scroll2Tile(cc.p(px,py))
		G_ROLE_MAIN.tile_pos = cc.p(px,py)
		--G_ROLE_MAIN:showNameAndBlood(true)
		--self:cleanAstarPath(true)
		if G_MY_STEP_SOUND then
			AudioEnginer.stopEffect(G_MY_STEP_SOUND) 
			G_MY_STEP_SOUND = nil
		end
		self:doCheckPosition(cc.p(px,py))
		--print("*************RoleId:"..tostring(userInfo.currRoleStaticId))
		--print("serverId: "..tostring(userInfo.serverId).."   mapid:"..tostring(self.mapID))
	else
        -- 空值校验
        if G_ROLE_MAIN then
		    G_ROLE_MAIN:setCornerSign_ex(role_main,1)
        end

		if entity[ROLE_HP] and entity[ROLE_HP] <= 0 then
			if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
	            local clothesId,weaponId,wingId=G_MAINSCENE.map_layer:getclothes(entity[ROLE_SCHOOL],entity[PLAYER_SEX])
				role_main:setEquipments(clothesId,weaponId,wingId)
	        end
			role_main:showNameAndBlood(false)
			if entity[ROLE_SCHOOL] and entity[ROLE_SCHOOL] == 2 then
				role_main:gotoDeath(6,0.01)
			else
				role_main:gotoDeath(7,0.01)
			end
			role_main:setOpacity(128)
			--死亡不展示死亡动作
			role_main:setVisible(false)
			if getGameSetById(GAME_SET_ID_SHIELD_PLAYER)==0 then
				role_main:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.Show:create()))
			end
		else
			role_main:setVisible(getGameSetById(GAME_SET_ID_SHIELD_PLAYER)==0)
		end
		--开启附近目标的引导
		if require("src/layers/role/RoleStruct"):getAttr(ROLE_LEVEL) == 37 then
			if G_TUTO_DATA then
				for k,v in pairs(G_TUTO_DATA) do
					if v.q_id == 48 then
						if v.q_state == TUTO_STATE_HIDE then
							v.q_state = TUTO_STATE_OFF
						end
					end
				end
			end
		end
	end
	if objid then
		self.role_tab[objid] = objid
	end

	local base_speed = getConfigItemByKeys("roleData", {
	        "q_zy",
	        "q_level",
	      },{1,1},"q_move_speed")/1000
    if isMe then
		g_speed_time =  g_speed_time or base_speed
        role_main:setBaseSpeed(g_speed_time)
		self:resetSpeed(g_speed_time)
 	else
		role_main:setBaseSpeed(base_speed)
		role_main:setSpeed(base_speed)
 	end
	return role_main
end

function MapBaseLayer:registerMsgHandler()
end


function MapBaseLayer:doCheckAttack()
	if G_ROLE_MAIN and self.select_role and (game.getAutoStatus() == AUTO_ATTACK or self.on_attack) and MRoleStruct:getAttr(ROLE_SCHOOL) == 1 and (not self:hasPath()) then
		local state = G_ROLE_MAIN:getCurrActionState()
		if state == ACTION_STATE_IDLE then
			local role = tolua.cast(self.select_role,"SpritePlayer")
			if role then
				local m_tile_pos = self.select_role:getServerTile()
				local r_pos = cc.p(G_ROLE_MAIN:getPosition())
				local r_tile_pos = self:space2Tile(r_pos)
				if math.max(math.abs(r_tile_pos.x-m_tile_pos.x),math.abs(r_tile_pos.y-m_tile_pos.y)) > 1 then
					local do_skill = self.skill_todo[1]
					if self.on_attack and type(self.on_attack) == "number" then 
						do_skill = do_skill or self.on_attack
						if game.getAutoStatus() == AUTO_ATTACK then
							self.on_attack = nil
						end
					end
					self:roleStartToAttack(do_skill)				
				end
			end
		end
	end
	if self.on_attack then
		game.setMainRoleAttack(true)
	end
	
	if G_MAINSCENE and (not self:hasPath()) then
		if game.getAutoStatus() == AUTO_MATIC then 
			local m_teamId = MRoleStruct:getAttr(PLAYER_TEAMID)
			if G_MAINSCENE.dart_objid then
				local dart_obj = tolua.cast(self.item_Node:getChildByTag(G_MAINSCENE.dart_objid),"SpriteMonster")
				if dart_obj then
					G_MAINSCENE.dart_pos = dart_obj:getTilePoint()
				elseif not G_MAINSCENE.dart_pos then
					G_MAINSCENE.dart_objid = nil
					g_msgHandlerInst:sendNetDataByTableExEx(DART_CS_POSITION, "DartPositionProtocol", {} )
				end
			end
			if m_teamId and m_teamId > 0 or G_MAINSCENE.dart_pos  then
				if G_MAINSCENE.dart_pos then
					local pathCfg = require("src/layers/map/DetailMapNode"):getDartPath()
					local need_move_pos = getNextGoPos(G_MAINSCENE.dart_pos , pathCfg )
					if need_move_pos then
						if self.mapID == 2100 then
							self:moveMapByPos(need_move_pos,false)
						else
							if DATA_Mission then 
								DATA_Mission:setTempFindPath() 
								DATA_Mission:setLastFind()
					 			DATA_Mission:setAutoPath(false)
					   			DATA_Mission.isStopFind = true  
							end
							local detailMapNode = require("src/layers/map/DetailMapNode"):getDetailMapInfo()
							detailMapNode.curmap_tarpos = findTarMap( 2100 , self.mapID)
							detailMapNode.map_id = 2100
							detailMapNode.target_pos = need_move_pos
						end
					end
				else
					g_msgHandlerInst:sendNetDataByTableExEx(DART_CS_POSITION, "DartPositionProtocol", {} )
				end
			end
		end
	end

	if G_MAINSCENE and  game.getAutoStatus() == AUTO_ESCORT then
		--检测护送
		if self:checkEscort() == false then
			G_MAINSCENE.task_escort_id = nil
			G_MAINSCENE.task_escort_pos = nil
			self:cleanAstarPath(true,true)
			game.setAutoStatus(0)
		end
	end

end

--数据请求
function MapBaseLayer:escortAsk()
	if G_MAINSCENE.task_escort_id then
		local escort_obj = tolua.cast(self.item_Node:getChildByTag( G_MAINSCENE.task_escort_id ),"SpriteMonster")
		if escort_obj then
			G_MAINSCENE.task_escort_pos = escort_obj:getTilePoint()
		elseif not G_MAINSCENE.task_escort_pos then
			g_msgHandlerInst:sendNetDataByTableExEx( CONVOY_CS_POSITION , "ConvoyPositionProtocol", {} )
		end
	elseif not G_MAINSCENE.task_escort_pos then
		g_msgHandlerInst:sendNetDataByTableExEx( CONVOY_CS_POSITION , "ConvoyPositionProtocol", {} )
	end
end
--检测护送
function MapBaseLayer:checkEscort()
	local isEscort = false --是否有护送任务
	if DATA_Mission then
		local nowTask = DATA_Mission:getLastTaskData()
		local doneCfg = stringsplit( nowTask.q_done_event , "_" )
		if tonumber( doneCfg[1] ) == 56 then
				isEscort = true
				self:escortAsk()
				if G_MAINSCENE.task_escort_pos then
					local escortCfg = getConfigItemByKey( "ConvoyDB" , "q_id" , tonumber( doneCfg[2] ) )
					local pathCfg = unserialize( escortCfg.q_path )
					local need_move_pos = getNextGoPos( G_MAINSCENE.task_escort_pos , pathCfg )
					if need_move_pos then
						if self.mapID == escortCfg.q_mapID then
							self:moveMapByPos(need_move_pos,false)
						else
							if DATA_Mission then 
								DATA_Mission:setTempFindPath() 
								DATA_Mission:setLastFind()
					 			DATA_Mission:setAutoPath(false)
					   			DATA_Mission.isStopFind = true  
							end
							local detailMapNode = require("src/layers/map/DetailMapNode"):getDetailMapInfo()
							detailMapNode.curmap_tarpos = findTarMap( escortCfg.q_mapID , self.mapID)
							detailMapNode.map_id = escortCfg.q_mapID
							detailMapNode.target_pos = need_move_pos
						end
					end
				end


		end
	end
	return isEscort
end

function MapBaseLayer:onRoleAttack()
	local getSkillId = function(s_id)
		local skillLv = nil
		if self.skill_map then
			skillLv = self.skill_map[s_id]
		end
		if skillLv then
			local mp = MRoleStruct:getAttr(ROLE_MP)
			local useMP = getConfigItemByKey("SkillLevelCfg","skillID",s_id*1000+skillLv,"useMP")
			return (not useMP) or (mp >= useMP)
		end
		return false
	end
	local hasTheBuffById = function(obj_id,buff_id)
		local buffs = g_buffs_ex[obj_id]
	    if buffs == nil or buffs[buff_id] == nil then
	      return false
	    else
	      return true
	    end
	end
	local a_state = 0
	if G_ROLE_MAIN then
		a_state = G_ROLE_MAIN:getCurrActionState() 
		if game.getAutoStatus() == AUTO_MINE then
			if a_state == ACTION_STATE_EXCAVATE then
				AudioEnginer.playEffect("sounds/actionMusic/wakuang.mp3",false)
			elseif a_state == ACTION_STATE_IDLE then
				G_ROLE_MAIN:isChangeToHoe(G_ROLE_MAIN, true)
				local dir = G_ROLE_MAIN:getCurrectDir()
				G_ROLE_MAIN:excavateToTheDir(0.5,dir)
			end
			return
		elseif a_state == ACTION_STATE_DIG then
			return
		end
		if getSkillId(1006) and getGameSetById(GAME_SET_ID_AUTO_DOUBLE_FIRE)+getGameSetById(GAME_SET_ID_AUTO_FIRE) >= 1 then
			if not G_MAINSCENE.skill_cds[1006] then
				if hasTheBuffById(G_ROLE_MAIN.obj_id,126) then
					if getGameSetById(GAME_SET_ID_AUTO_DOUBLE_FIRE) == 1 then
						if not G_ROLE_MAIN.double_fire then
							TIPS( { type = 2 , str = game.getStrByKey("double_leihuo") } )
							G_ROLE_MAIN.double_fire = 1
						end	
					end
				else
					g_msgHandlerInst:sendNetDataByTable(SKILL_CS_OPENFIRE,"SkillOpenFireProtocol",{skillId = 1006})
				end
			end
		end
	else
		return
	end
	--print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@",os.time())
	--print("cd:",self.common_cd,"DirSet:",self:getRockDirSet(),"Path:",self:hasPath(),"Status:",game.getAutoStatus() ,"on_attack:",self.on_attack,"self.skill_todo[1]:",self.skill_todo[1])
	if self.updata_time%2 == 0 and getGameSetById(GAME_SET_MAGICSHIELD) == 1 and  (not self.isMine) and (not self.isStory) and (not self.caiji_num) and getSkillId(2004) and (not hasTheBuffById(self.role_id,11)) and (G_MAINSCENE and (not G_MAINSCENE.skill_cds[2004])) then
		if G_ROLE_MAIN and (not G_ROLE_MAIN:getOnRide()) and (not G_ROLE_MAIN:isChangeModeDisplay()) then
			self:roleStartToAttack(2004,G_ROLE_MAIN)
		end
	elseif (not self.common_cd) and (game.getAutoStatus() == AUTO_ATTACK or self.on_attack or self.skill_todo[1]) and (not self:getRockDirSet()) and (not self:hasPath()) then
		--if (not self.skill_todo[1]) or (not self.touch_skill_id) or (self.touch_skill_id ~= self.skill_todo[1]) then
--		if not self.stopNextSkill then
		local do_skill = self.skill_todo[1]
		if self.on_attack then
			if type(self.on_attack) == "number" then 
				do_skill = do_skill or self.on_attack
			end
			if game.getAutoStatus() == AUTO_ATTACK then
				self.on_attack = nil
			end
		end
		self:roleStartToAttack(do_skill)
--		end
		--end
	end

	if (not self.common_cd) then
		a_state = G_ROLE_MAIN:getCurrActionState()
		if a_state == ACTION_STATE_IDLE then
			G_ROLE_MAIN:standed()
			self.common_cd = nil
		end
	end
end

function MapBaseLayer:addNpc(px,py,resid,npcid, cj)
	local npc_node = require("src/base/NpcSprite").new(tostring(resid), npcid,cj)
	--local npc_node = require("src/base/NpcSprite").new("npc/"..resid, npcid,cj)
	local pos = self:tile2Space(cc.p(px,py))
	if cj and cj == 1 then
		pos.y = pos.y-15
	end
	npc_node:setPosition(pos)
	if self:isOpacity(cc.p(px,py)) then
		npc_node:setOpacity(100)
	end
	self.npc_tab[npcid] = npc_node
	self.item_Node:addChild(npc_node,py,npcid)

end

function MapBaseLayer:addRoleNpc(px,py,entity,npcid)
	local npc_config = getConfigItemByKey("NPC","q_id",npcid)
    local params={}
    params[ROLE_SCHOOL] = 1
    params[PLAYER_SEX] = 1
    params[ROLE_NAME] = npc_config.q_name or ""
    params[PLAYER_EQUIP_WEAPON] = tonumber(npc_config.q_wuqi)
    params[PLAYER_EQUIP_UPPERBODY] = tonumber(npc_config.q_yifu)
    params[PLAYER_EQUIP_WING] = tonumber(npc_config.q_wing)
    local npc_node = createSceneRoleNode(params)
    npc_node:initStandStatus(4,6,1.0,6)
    npc_node:setNeedShowName(true)
    npc_node:showNameAndBlood(false,85)
    
    npc_node.id = npcid
    local name_label = npc_node:getNameBatchLabel()
    if name_label then
      	name_label:setColor(MColor.yellow)
  	end

	if self:isOpacity(cc.p(px,py)) then
		npc_node:setOpacity(100)
	end
	self.npc_tab[npcid] = npc_node
	self.item_Node:addChild(npc_node,py,npcid)
	local npc_effect = Effects:create(false)
	npc_effect:setVisible(false)
	npc_effect:setPosition(cc.p(0 ,135))
	local top_node = npc_node:getTopNode()
	if top_node then
		top_node:addChild(npc_effect,25)
	end
	npc_node.npc_effect = npc_effect

	npc_node.showTask = function(node,idx)
		if npc_node.npc_effect then
			npc_node.npc_effect:setVisible(true)
			if idx == 1 then
				npc_node.npc_effect:playActionData("finishtask", 9, 2, -1)
			elseif idx == 2 then
				npc_node.npc_effect:playActionData("newtask", 7, 1.6, -1)
			elseif idx == 3 then
				npc_node.npc_effect:playActionData("unfinishtask", 9, 2, -1)
			end
		end
	end
	npc_node.normalState = function(npc_node)
		npc_node.npc_effect:runAction(cc.Sequence:create(cc.DelayTime:create(0.0), cc.Hide:create()))
	end
	local pos = self:tile2Space(cc.p(px,py))
	npc_node:setPosition(pos)
	npc_node:standed()
end

function MapBaseLayer:addBeautyWomen(px,py,filepath,maxcut,objid,entity)
	--print("addBeauty")
	--dump(entity)
	-- local roleSprite = require("src/base/RoleSprite")
	-- self.pet = self.pet or {}
	-- local beauty = SpritePlayer:create("role/70000001" ,0)
	-- beauty:initStandStatus(4,6,1.0,5)
 --  	beauty:initHurtStatus("",2)
 --  	beauty:setType(21)
 --  	beauty:setMonsterId(entity[ROLE_MODEL])
 --  	local monster_data = getConfigItemByKey("monster","q_id",entity[ROLE_MODEL])
 --  	entity[ROLE_HOST_NAME] = entity[ROLE_HOST_NAME] or ""
 --  	local name = entity[ROLE_HOST_NAME] .."的"..monster_data.q_name
 --  	beauty:setName(name)
 --  	local level = entity[ROLE_LEVEL] or  MRoleStruct:getAttr(ROLE_LEVEL)
 --    beauty:setLevel(level)
 --    local nameLabel = createLabel(beauty:getNameLabel(),name,nil,nil,14,true,nil,nil,MColor.white)
 --  	nameLabel:setTag(10)
	-- local pos = self:tile2Space(cc.p(px,py))
	-- beauty:setPosition(pos)
	-- if self.item_Node:getChildByTag(objid) then
	-- 	self.item_Node:removeChildByTag(objid)
	-- end
 --  	self.item_Node:addChild(beauty,py,objid)
 --  	if entity[ROLE_BEAUTY_WEAPON] then
 --  		local w_resId = 70000000 + entity[ROLE_BEAUTY_WEAPON]%10
 --  		w_resId = roleSprite:getRightResID(PLAYER_EQUIP_WEAPON,w_resId)
 --  		roleSprite:setEquipment_ex(beauty,PLAYER_EQUIP_WEAPON,"weapon/" .. (w_resId))
 --  	end
 --  	if entity[ROLE_BEAUTY_CLOTH] then
 --  		local w_resId = 70000000 + entity[ROLE_BEAUTY_CLOTH]%10
 --  		w_resId = roleSprite:getRightResID(PLAYER_EQUIP_UPPERBODY,w_resId)
 --  		beauty:setBaseUrl("role/"..(w_resId))
 --  	end
 --  	beauty:standed()
	-- if self:isOpacity(cc.p(px,py)) then
	-- 	beauty:setOpacity(100)
	-- else
	-- 	beauty:setOpacity(255)
	-- end
 --  	beauty:setVisible(getGameSetById(GAME_SET_ID_SHIELD_BEAUTY)==0 or entity[ROLE_HOST_NAME] == MRoleStruct:getAttr(ROLE_NAME))
	-- self.pet_tab[objid] = objid	
end

function MapBaseLayer:isTree(monsterid)
	return monsterid == 5270 or monsterid == 5274 or monsterid == 1009 or monsterid == 5272 or monsterid == 10010
end

function MapBaseLayer:addMonster(px,py,filepath,maxcut,objid,entity)
	local role_model = entity[ROLE_MODEL]
	local role_hp = entity[ROLE_HP]
	local role_host_name = entity[ROLE_HOST_NAME]
	local role_move_speed = entity[ROLE_MOVE_SPEED]
	local map_resid = self.mapResid or ""
	local retok = (not role_hp or role_hp > 0 or self.isSkyArena or role_model == 21 or role_model == 23 or role_model == 31)

	if retok then
		--print("add a monster to : ",self.mapID,entity[ROLE_MODEL],px,py,os.time())
		if self:isBlock(cc.p(px,py)) then--and (entity[ROLE_MODEL] ~= 9001 and entity[ROLE_MODEL] ~= commConst.MULTI_GUARD_PRINCESS_ID) then
			print("add a monster to a block : ",self.mapID,role_model,px,py)
			--return
		end
		local monster = require("src/base/MonsterSprite").new(filepath,entity,objid)

		if  not monster then return print("add a monster error！！！！！！！！！！！！！！！") end

		local monster_resid = monster:getResId()

		local setPos = function() 
			local m_type =  monster:getType()
			local show = MRoleStruct:getAttr(ROLE_SHOW,objid) or 1
			--local carCfg = { ["80000"] = true , ["80001"] = true , ["80002"] = true , ["80003"] = true , ["31"] = true, ["21"] = true, ["23"] = true}
			if role_model ~= 80000 and role_model ~= 80001 and role_model ~= 80002 and role_model ~= 80003 and role_model ~= 31 and role_model ~= 21 and role_model ~= 23 then
				if m_type>=12 then
					monster:setVisible(show == 1)
				elseif not ((getGameSetById(GAME_SET_ID_SHIELD_MONSTER) == 0) and (show == 1)) then
					local host_name = MRoleStruct:getAttr(ROLE_HOST_NAME,objid)
					if not host_name then
						monster:setVisible(false)
					end
				end
			end
			monster:setServerTilePosByTile(px,py)
			if self:isOpacity(cc.p(px,py)) then
				monster:setOpacity(128)
			else
				monster:setOpacity(255)
			end
		end
		--monster:setVisible(false)
		setPos()

		if self:isTree(role_model) then
			monster:setTreeFlag(true)
			monster:initStandStatus(5,5,1.0,6)
        end	

		if role_host_name and role_host_name == MRoleStruct:getAttr(ROLE_NAME) and role_model >=90000 and role_model <=93000 then  --自己的骷髅
			if self.pet[objid] then
				self.item_Node:removeChildByTag(objid)
			end
			self.pet = self.pet or {}
			self.pet[objid] = monster

			if role_model >= 91000 then
				local delayShow = function()
					if self.pet[objid] == nil then return end
					local skill_effect = Effects:create(true)
					--skill_effect:setPosition(pos)
					if role_model < 92000 then
						skill_effect:playActionData2("skill3007/begin",80,1,0)
						skill_effect:setPosition(cc.p(0,-30))
						skill_effect:setRenderMode(2)
					elseif role_model < 93000 then
						skill_effect:playActionData2("skill3012/begin",60,1,0)
						skill_effect:setRenderMode(2)
					end
					-- performWithDelay(skill_effect,function()
					-- 	removeFromParent(skill_effect)
					-- 	skill_effect = nil
					-- end, 0.5)
					monster:addChild(skill_effect,7)
				end
				performWithDelay(monster,delayShow,0.1)
			end
			monster:showNameAndBlood(true)
		elseif role_model ~= 9001 and role_model ~= commConst.MULTI_GUARD_PRINCESS_ID and role_model ~= 9003 then
			--local modelEffects = {[31] = "copperOre",[23] = "silverOre",[21] = "goldOre"}
			--local addPos = {[31] = -5,[23] = -15,[21] = 26}
			if role_model == 31 or role_model == 23 or role_model == 21 then
				if self.mineTab[objid] then
					self.item_Node:removeChildByTag(objid)
				end
				self.mineTab[objid] = objid
				self.item_Node:addChild(monster,py,objid)
				monster:initStandStatus(4,4,1.0,6)
	        	monster:standed()    	
	        	--开启挖矿的引导
				if G_TUTO_DATA then
					--dump(G_TUTO_DATA)
					for k,v in pairs(G_TUTO_DATA) do
						if v.q_id == 403 then
							if v.q_state == TUTO_STATE_HIDE then
								v.q_state = TUTO_STATE_OFF
							end
						end
					end
				end

				return monster
			end
			if self.monster_tab[objid] then
				self.item_Node:removeChildByTag(objid)
			end
			self.monster_tab[objid] = objid

			if role_model >= 90000 then
				self.pet_tab[objid] = objid
			end
			if role_model == 9005 then
				local dir = 6
				if py > 100 then
					if px < 100 then
						dir = 5
					else
						dir = 7
					end
				else
					if px < 100 then
						dir = 7
					elseif py < 55 then
						dir = 1
					else
						dir = 5
					end
				end
				monster:initStandStatus(5,3,1.0,dir)
			end
		elseif role_model == 9003 then
			local function detail()
	  			local bg = popupBox({ 
                         bg = "res/common/scalable/bg.png" , 
                         createScale9Sprite = { size = cc.size( 500 , 300 ) } ,
                         close = { callback = function()  end , scale = 0.5 } , 
                         zorder = 299 ,
                         isNoSwallow = true , 
                         isHalf = true , 
                         actionType = 7 ,
                       })				
	  			local data = require("src/config/PromptOp")
	  			local str = data:content(60)
			    local richText = require("src/RichText").new(bg, cc.p(15, 275), cc.size(450, 30), cc.p(0, 1), 22, 20, MColor.lable_black)
			    richText:addText(str)
			    richText:format()
			    local function closeFunc()
			    	removeFromParent(bg)
			    end
			    registerOutsideCloseFunc(bg, closeFunc, true, true)
			    local close_btn = createMenuItem(bg, "res/common/13.png", cc.p(bg:getContentSize().width-5, bg:getContentSize().height-5), closeFunc)
				close_btn:setScale(0.8)
			end
			local function getFlag()
				log("getFlag")
				g_msgHandlerInst:sendNetDataByTableExEx(MANORWAR_CS_PICKUPBANNER, "PickUpBannerProtocol", {manorID = 1})
			end

			local BtnNode = cc.Node:create()
			self:addChild(BtnNode, 9000)
			local t_pos = self:tile2Space(cc.p(px, py))
			local detailBtn = createMenuItem(BtnNode, "res/empire/baqi.png", cc.p(t_pos.x + 120, t_pos.y + 100), getFlag)
			local getFlagBtn = createMenuItem(BtnNode, "res/empire/hsuoming.png", cc.p(t_pos.x - 120, t_pos.y + 100 ), detail)

			if self.BannerBtn then
				removeFromParent(self.BannerBtn)
				self.BannerBtn = nil
			end
			self.BannerFlagId = objid
			self.BannerBtn = BtnNode
			self.BannerBtn:setVisible(false)

			monster:initStandStatus(5,5,1.0,6)
			--dump(entity)
			--py = 55555
			performWithDelay(self.item_Node , function() self:NearBannerCheck() end , 0.5)
			if self.spec_tab[objid] then
				self.item_Node:removeChildByTag(objid)
			end
			self.spec_tab[objid] = objid
		else
			local m,n=4,3
			if role_model == 9001 then
				log("entity[ROLE_MODEL]" .. role_model)
				self.defenseObjId = objid
				m=4
				n=3
				if self.pet[objid] then
					self.item_Node:removeChildByTag(objid)
				end
				self.pet[objid] = monster
			elseif role_model == commConst.MULTI_GUARD_PRINCESS_ID then
				if self.MulityObjId and self.MulityObjId == objid and self.item_Node:getChildByTag(objid) then
					self.item_Node:removeChildByTag(objid)
				end
				self.MulityObjId = objid
			end

			monster:initStandStatus(m,n,1.0,6)
		end

        local monster_info = getConfigItemByKey("MonsterAction", "q_featureid", monster_resid)
		monster:setMonsterActionByInfo(monster_info)

		self.item_Node:addChild(monster,py,objid)

		monster:doMonsterAppearActionByInfo(monster_info)

        local show = monster:getHP()<monster:getMaxHP()
        if role_model >= 90000 or isSpecalModel(role_model) or role_model== 9005 or role_model== 9008 then
          	show = false
        end
        local feature_id = tonumber(filepath)
        if feature_id ~= 4000001 and feature_id ~= 4000002 then
        	if feature_id == 20085 then
        		--monster:showNameAndBlood(false,110)
        		--monster:setLockHeight(true)
        		monster:initAttackStatus(6)
        	end
			if role_model == 9001 or role_model == commConst.MULTI_GUARD_PRINCESS_ID then
				show = true
			end
--     		local showBlood = function()
			-- 	local monster = tolua.cast(monster,"SpriteMonster")
			-- 	if monster then
			-- 		if getGameSetById(GAME_SET_MONSTER_NAMESHOW) == 1 then
			-- 			monster:setNeedShowName(true)
			-- 		end
			-- 		monster:showNameAndBlood(show)
			-- 	end
			-- end
    		--performWithDelay(monster:getMainNode(),showBlood,0.5)
    		if getGameSetById(GAME_SET_MONSTER_NAMESHOW) == 1 then
				monster:setNeedShowName(true)
			end
			monster:showNameAndBlood(show)
      	else
      		--monster:getMainSprite():setScale(1.33)
      		--monster:walkInTheDir(0.5,pos,5)
      		monster:initWalkStatus(8)
	     	monster:showNameAndBlood(true,100)
	     	monster:setLockHeight(true)
	     	--monster:setSpeed(0.8)
	     	role_move_speed = role_move_speed or 70
	     	--print(role_move_speed)
	    end

		monster:setBaseSpeed(0.45)
		
	    if role_move_speed then
	    	monster:setSpeed(45.0/role_move_speed)
        else
			monster:setSpeed(0.45)
	    end
		
		if role_model == 6005 then
			local effNode = createMonsterEffect(monster, "mae_20032_6", 20, 2.0, 1)
			if effNode then
				effNode:setScale(1.11)
			end 
		elseif (role_model >= 90000 and role_model >= 92003) or role_model == 70051 then
			createMonsterEffect(monster, "mae_90000_6", 14, 1.0, 1)
		end
		
		-- if entity[ROLE_SHOW] then
		-- 	log("[MapBaseLayer:addMonster] called. entity id = %s, model id = %s, ROLE_SHOW = %s.", objid, role_model, entity[ROLE_SHOW])
		-- 	if entity[ROLE_SHOW] == 0 then
		-- 		monster:setVisible(false)
		-- 	end
		-- end
		--monster:setSpeed(0.5)
		if monster then
			if role_hp and role_hp == 0 then
				monster:showNameAndBlood(false)
				monster:gotoDeath(7,0.1)
				--已经死亡，不显示死亡动作
				monster:setVisible(false)
				if getGameSetById(GAME_SET_ID_SHIELD_MONSTER)==0 then 
					monster:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Show:create()))
				end
				if not ( self.isSkyArena )then
					monster:setOpacity(128)
				end
			else
				monster:standed()
			end
		end
		return monster
	end
end

function MapBaseLayer:setPet()
	local objid = G_ROLE_MAIN.base_data.pet_id
	if self.monster_tab[objid] then
		local pet = tolua.cast(self.item_Node:getChildByTag(objid),"SpriteMonster")
		if pet then
			self.pet = self.pet or {}
			self.pet[objid] = pet
			pet:showNameAndBlood(true)
			self.monster_tab[objid] = nil
		end
	end
end

function MapBaseLayer:moveByPaths(paths,v,objid,m_time,just_send,callback)
	if paths then 
		if objid and (not just_send) and self.role_actions[objid] then
			self.item_Node:stopAction(self.role_actions[objid])
			self.role_actions[objid] = nil
			self.rock_status[objid] = nil
		end
		local setOpacityFunc = function(x,y)
			local item = self:isValidStatus(objid)
			if item then
				item:stopAllActions()
				item:setPosition(self:tile2Space(cc.p(x,y))) 
				if self:isOpacity(cc.p(x,y)) then
					item:setOpacity(100)
				else
					item:setOpacity(255)
				end
				item:setLocalZOrder(y)
			end
		end
		local v = self:isValidStatus(objid)
		if not v then return end
		--if paths[1] then
			--v:setPosition(self:tile2Space(paths[1]))
		--end
		local c_type = v:getType()
		local actions = {}
		for i=1,#paths-1 do
			local now_pos = self:tile2Space(paths[i])
			local tar_pos = self:tile2Space(paths[i+1])
			local dir = getDirBrPos(cc.p((tar_pos.x-now_pos.x),(tar_pos.y-now_pos.y)),v:getCurrectDir())
			local move_time = m_time or 0.4
			local move = function()
				local item = tolua.cast(v,"SpriteMonster")
				if item and item:isAlive() and (not just_send) then
					if c_type < 20 then
						item:walkInTheDir(move_time,tar_pos,dir)
					else
						item:moveInTheDir(move_time*0.95,tar_pos,dir)
					end
				end
			end
			actions[#actions+1] = cc.CallFunc:create(move)
			actions[#actions+1] = cc.DelayTime:create(move_time)
			local x,y = paths[i+1].x,paths[i+1].y
			actions[#actions+1] = cc.CallFunc:create(function() setOpacityFunc(x,y) end)
		end
		actions[#actions+1] = cc.CallFunc:create(function()
			local item = tolua.cast(v,"SpriteMonster")
			self.enemyBody_move = nil
            self.role_actions[objid] = nil
			if item and item:isAlive() then
				item:standed()
			end
			if callback then callback() end
		end)
		self.role_actions[objid] = cc.Sequence:create(actions)
		self.item_Node:runAction(cc.Sequence:create(self.role_actions[objid]))
	end
end

function MapBaseLayer:addDropOut(px,py,objid,entity)
	local propOp = require("src/config/propOp")
	local iconPath = nil
	local name = nil
	local scale = 1.0
	local nameColor = MColor.white
	self.goods_tab = self.goods_tab or {}
	if self.goods_tab[objid] then
		self.item_Node:removeChildByTag(objid)
	end
	local drop_mode_id = entity[ROLE_MODEL]
	if self:isBlock(cc.p(px,py)) then return end 
	if drop_mode_id~=100 and drop_mode_id~=200 and drop_mode_id~=300 then
		iconPath = propOp.icon(drop_mode_id)
		name = propOp.name(drop_mode_id)
		scale = 0.5
		local max_hp = entity[ROLE_MAX_HP]
		if max_hp then
			nameColor = propOp.nameColorEx(max_hp)
		else
			nameColor = propOp.nameColor(drop_mode_id)
		end
	else
		iconPath = "res/dropout/l.png"
		name = game.getStrByKey("gold_coin")
	end

	local icon = nil;
    local effPath = propOp.ItemEffect(drop_mode_id);
    if effPath == nil then
        icon = cc.Sprite:create();
        icon:setTexture(iconPath)
    else
        -----------------------------------------------------带特效的图标-----------------------------------------------------------------------------------------------------------
        icon = Effects:create(false);
        local effMode = propOp.ItemEffectMode(drop_mode_id);
        local effTime = propOp.ItemEffectTime(drop_mode_id);
        --void Effects::playActionData2(const std::string& pszFileName, float speed, int loop, float delaytime)
        icon:playActionData2(effPath, effTime, -1, 0);
        addEffectWithMode(icon, effMode);
    end    
    if not icon then return end
    
	icon:setScale(scale)
	icon:setAnchorPoint(cc.p(0.5,1.0))
	local d_pos =  self:tile2Space(cc.p(px,py))
	icon:setPosition(d_pos)
    
    self.goods_tilepos[objid] = cc.p(px,py)
	self.goods_tab[objid] = drop_mode_id

	local lab = nil
	if nameColor == MColor.purple or nameColor == MColor.orange then
		lab = createBatchLabel(self.item_batchlabel_top, name,cc.p(d_pos.x,d_pos.y), cc.p(0.5,0.0), 14, true, nil, nil, nameColor)
		-- 掉落物品 消失后 去除名字
	    icon:registerScriptHandler(function(event)
			if event == "exit" then
				if self.item_batchlabel_top then
	                if self.item_batchlabel_top:getChildByTag(objid) then
	                	self.item_batchlabel_top:removeChildByTag(objid)
	                end
	            end

	            if self.goods_tilepos then
	                self.goods_tilepos[objid] = nil;
	            end
			end
		end)
	else
		lab = createBatchLabel(self.item_batchlabel, name,cc.p(d_pos.x,d_pos.y), cc.p(0.5,0.0), 14, true, nil, nil, nameColor)
		-- 掉落物品 消失后 去除名字
	    icon:registerScriptHandler(function(event)
			if event == "exit" then
				if self.item_batchlabel then
	                if self.item_batchlabel:getChildByTag(objid) then
	                	self.item_batchlabel:removeChildByTag(objid)
	                end
	            end

	            if self.goods_tilepos then
	                self.goods_tilepos[objid] = nil;
	            end
			end
		end)
	end

	if lab then lab:setTag(objid) end
	if self:isOpacity(cc.p(px,py)) then
		icon:setOpacity(100)
		if lab then lab:setOpacity(100) end
	end

	self.item_Node:addChild(icon,drop_mode_id%7+1,objid)
	local role_hp = entity[ROLE_HP] 
	if role_hp and G_ROLE_MAIN and G_ROLE_MAIN.obj_id 
		and role_hp == G_ROLE_MAIN.obj_id then
		self:autoPickUp()
	end
end

function MapBaseLayer:addMagicEffect(px,py,objid,entity)
	local skill_id = entity[ROLE_MODEL];
	local skill_lv = entity[ROLE_LEVEL];
	if skill_id == nil or skill_lv == nil then
		return
	end
	if self:isBlock(cc.p(px, py)) then
		return
	end

	local skill_info = getConfigItemByKey("SkillCfg", "skillID", skill_id)
	if skill_info == nil then
		return
	end

	local effRange = 1
	if skill_info.effectRangeType ~= nil then
		local skill_rangetype = tonumber(skill_info.effectRangeType)
		if skill_rangetype == 5 then
			effRange = 2
		elseif skill_rangetype == 6 then
			effRange = 2
		elseif skill_rangetype == 7 then
			effRange = 4
		end
	end

	local skill_times = {
		[2007] = {0,0,9,0.3,0,0.5,3,30},
		[10006] = {0,0,15,0,0,1.0,1,10},
		[10009] = {0,0,9,0,0,1.0,5,10},
	}

	local skill_effect = nil
	local times = skill_times[skill_id]
	local dest_pos = self:tile2Space(cc.p(px,py))

	local nodeSet = cc.Node:create()

	-------------------------------------------------------

	if skill_id	== 2011 then
		skill_effect = Effects:create(false)
		skill_effect:setPosition(dest_pos)
		nodeSet:addChild(skill_effect)
		skill_effect:setRenderMode(2)
		skill_effect:setPlistNum(2)

		local actions = {}
		local c_ani_begin = skill_effect:createEffect2(""..skill_id.."/dandao",60)
		c_ani_begin:setLoops(1)	
		actions[#actions+1] = cc.Animate:create(c_ani_begin)

		local c_ani_loop = skill_effect:createEffect2(""..skill_id.."/hit",90)
		c_ani_loop:setLoops(10000000)
		actions[#actions+1] = cc.Animate:create(c_ani_loop)

		skill_effect:runAction(cc.Sequence:create(actions))
	else
		local repeatCount = effRange + 1
		if skill_id == 10006 then repeatCount = 1 end
		if repeatCount < 1 then repeatCount = 1 end
		if repeatCount > 30 then repeatCount = 30 end

		local offsetX = 48
		local offsetY = 32
		local startX = -offsetX * math.floor(repeatCount / 2)
		local startY = -offsetY * math.floor(repeatCount / 2)
		local effectX = startX
		local effectY = startY
		for x = 1, repeatCount do

			effectY = startY

			for y = 1, repeatCount do

				local chlid_eff = Effects:create(false)
				chlid_eff:setVisible(false)
				local dest_tile = self:space2Tile(cc.p(effectX+dest_pos.x, effectY+dest_pos.y))
				local color = cc.c3b(255, 255, 255)
				if self:isBlock(dest_tile) or self:isOpacity(dest_tile) then
					color = cc.c3b(100, 100, 100)
				end 
				local c_animation = chlid_eff:createEffect(""..skill_id.."/hit",times[3],times[6])
				if skill_id == 10006 then
					addEffectWithMode(chlid_eff,3)
				else
					addEffectWithMode(chlid_eff,1)
				end
				c_animation:setLoops(10000000)
				nodeSet:addChild(chlid_eff,6)
				local actions = {}
				actions[#actions+1] = cc.MoveTo:create(times[5],dest_pos)
				actions[#actions+1] = cc.MoveBy:create(0,cc.p(effectX, effectY))
				actions[#actions+1] = cc.Show:create()
				actions[#actions+1] = cc.CallFunc:create(function()
				chlid_eff:setColor(color) end)
				actions[#actions+1] = cc.Animate:create(c_animation)
				actions[#actions+1] = cc.CallFunc:create(function()
				chlid_eff = tolua.cast(chlid_eff,"Effects")
				if chlid_eff then
					removeFromParent(chlid_eff)
					chlid_eff = nil
					end
				end)
				chlid_eff:runAction(cc.Sequence:create(actions))
				effectY = effectY + offsetY

			end

			effectX = effectX + offsetX
		end
	end

	-------------------------------------------------------
	if self.item_Node:getChildByTag(objid) then
		self.item_Node:removeChildByTag(objid)
	end
	self.item_Node:addChild(nodeSet,0,objid)
	self.spec_tab[objid] = objid
end

function MapBaseLayer:resetTouchTag(no_reset_role)
	if self.select_monster and tolua.cast(self.select_monster,"cc.Node") then
		local monster = self.select_monster
		monster:showNameAndBlood(monster:getHP()<monster:getMaxHP() and monster:getHP() > 0 )
	 	if self.select_monster:getChildByTag(158) then self.select_monster:removeChildByTag(158) end
	end
	if self.select_npc and tolua.cast(self.select_npc,"cc.Node") then
	 	if self.select_npc:getChildByTag(158) then self.select_npc:removeChildByTag(158) end
	elseif self.select_role and tolua.cast(self.select_role,"cc.Node") then
	 	if self.select_role:getChildByTag(158) then self.select_role:removeChildByTag(158) end
	elseif self.select_pet and tolua.cast(self.select_pet,"cc.Node") then
	 	if self.select_pet:getChildByTag(158) then self.select_pet:removeChildByTag(158) end
	elseif self.select_mine and tolua.cast(self.select_mine,"cc.Node") then
	 	if self.select_mine:getChildByTag(158) then self.select_mine:removeChildByTag(158) end
	end
	if self.monster_head and tolua.cast(self.monster_head,"cc.Node") then
		removeFromParent(self.monster_head)
	end
	self.monster_head = nil
	self.select_monster = nil
	self.select_npc     = nil
	self.select_role    = nil
	self.select_mine    = nil
	self.pet_attacker = nil
	self.on_attack = nil
end

function MapBaseLayer:resetSelectMonster()
	if self.select_monster then
		if tolua.cast(self.select_monster, "cc.Node") then
			if self.select_monster:getChildByTag(158) then
				self.select_monster:removeChildByTag(158)
			end
		end

		self.select_monster = nil
	end
end

function MapBaseLayer:playSkillEffect(delay,skill_id,role_item,target,d_pos,mofa)
	require("src/base/PlaySkill")(self,delay,skill_id,role_item,target,d_pos)
end

function MapBaseLayer:setSkillMap(reset)
	if G_ROLE_MAIN and (reset or not self.skill_map) then
		self.skill_map = {}
		for k,v in ipairs(G_ROLE_MAIN.skills)do
			local jnfenlie = getConfigItemByKey("SkillCfg","skillID",v[1],"jnfenlie")
			if jnfenlie and jnfenlie == 1 then
				self.skill_map[v[1]] = v[2]
				--if v[4] and v[4] > 0 then 
					--BaseMapScene.skill_cds[v[1]] = v[4]/1000
				--end
			end
		end
	end
end

function MapBaseLayer:getHurtNumer(attacker, target, skillId)
	local skillLv = self.skill_map and self.skill_map[skillId] or 1
	local MskillOp = require "src/config/skillOp"
	local MRoleStruct = require "src/layers/role/RoleStruct"
	local MmonsterOp = require "src/config/monsterOp"
	local Mnumerical = require "src/functional/numerical"
	local Mconvertor = require "src/config/convertor"
	local school = MRoleStruct:getAttr(ROLE_SCHOOL)
	local targetId = target:getMonsterId()
	local attacker = tolua.cast(attacker,"SpriteMonster")
	local hurt = 0

	if attacker then
		if attacker:getType() < 20 then
			local mId = attacker:getMonsterId()
			--local q_featureid = getConfigItemByKey("monster","q_id",mId,"q_featureid")
			if mId == 0 then
			elseif mId%90000 < 10 then -- 骷髅
				local school = MmonsterOp:attackType(mId)
				hurt = Mnumerical:calcHurtRange(
				{
					base = MmonsterOp:combatAttr( mId, Mconvertor:schoolAttack(school) ),
					defense =MmonsterOp:combatAttr( targetId, Mconvertor:schoolDefense(school) ),
					luck = 0,
					gain = 1,
					addition = 0,
				})
			elseif mId%91000 < 10 then -- 神兽
				local bae = MRoleStruct:combatAttr( Mconvertor:schoolAttack(school))
				bae["["] = bae["["] * 0.2+250
				bae["]"] = bae["]"] * 0.2+250
				hurt = Mnumerical:calcHurtRange(
				{
					base = bae,
					defense = MmonsterOp:combatAttr( targetId, Mconvertor:schoolDefense(school) ),
					luck = 0,
					gain = MskillOp:attackGain(skillId, skillLv),
					addition = MskillOp:additionalAttack(skillId, skillLv),
				})
			elseif mId%92000 < 10 then --强化骷髅
				local bae = MRoleStruct:combatAttr( Mconvertor:schoolAttack(school))
				bae["["] = bae["["] * (0.2+(mId%92000+5)*0.025)
				bae["]"] = bae["]"] * (0.2+(mId%92000+5)*0.025)
				hurt = Mnumerical:calcHurtRange(
				{
					base = bae,
					defense = MmonsterOp:combatAttr( targetId, Mconvertor:schoolDefense(school) ),
					luck = 0,
					gain = MskillOp:attackGain(skillId, skillLv),
					addition = MskillOp:additionalAttack(skillId, skillLv),
				})
			end
		else
			local mId = attacker:getMonsterId() 
			if mId and mId == 9995 then
				local bae = MRoleStruct:combatAttr( Mconvertor:schoolAttack(school))
				bae["["] = bae["["] * 0.3+600
				bae["]"] = bae["]"] * 0.3+600
				hurt = Mnumerical:calcHurtRange(
				{
					base = bae,
					defense = MmonsterOp:combatAttr( targetId, Mconvertor:schoolDefense(school) ),
					luck = 0,
					gain = MskillOp:attackGain(skillId, skillLv),
					addition = MskillOp:additionalAttack(skillId, skillLv),
				})
			end
		end
	end

	if hurt == 0  then
	 	hurt = math.ceil(Mnumerical:calcHurtRange(
		{
			base = MRoleStruct:combatAttr( Mconvertor:schoolAttack(school) ),
			defense = MmonsterOp:combatAttr( targetId, Mconvertor:schoolDefense(school) ),
			luck = MRoleStruct:getAttr(PLAYER_LUCK),
			gain = MskillOp:attackGain(skillId, skillLv),
			addition = MskillOp:additionalAttack(skillId, skillLv),
		}))
	 end
	 return hurt,(math.random(0,10) > 8)
end

function MapBaseLayer:showAttrChangeNumer(attrId,number,num_file,add_file , isforcePass )
    -- 小退界面有属性更新会奔溃
    if G_MAINSCENE == nil then
        return;
    end
	--print("attrid "..attrId.."+"..(number))
	if not isforcePass and ((not self.updata_time) or self.updata_time  < 5) and (not self.isJjc) then
		return
	end
	local numfile = num_file or "res/mainui/number/hurt.png"
	if number <= 0 then
		numfile = "res/mainui/number/3.png"
		number = (-1)*number
		return
	end

	local rect ,spans = {0,0,220,30} , 20
	if not num_file then
		rect = {0,30,176,25}
		spans = 16
	end
	local sub_attr = (attrId-ROLE_MAX_COMPROP)
	local addfile = add_file or "res/mainui/number/attr/"..(sub_attr)..".png"
	local numer_sprite = require("src/base/HurtSprite").new(numfile,number,rect,spans,true) --MakeNumbers:createWithSymbol(numfile,number,0)
	if not numer_sprite then 
		return
	end
	createSprite(numer_sprite,addfile,cc.p(-10,0),cc.p(1,0.0))
	G_MAINSCENE:addChild(numer_sprite,200)
	numer_sprite:setVisible(false)
	numer_sprite:setCascadeOpacityEnabled(true)
	local r_pos = g_scrCenter 
	if attrId == 0 then
		numer_sprite:setPosition(cc.p(r_pos.x+30,r_pos.y+150))
	else
		numer_sprite:setPosition(cc.p(r_pos.x+150,r_pos.y+120))
	end

	local actions = {}
	local time = 0.5
	self.attr_ac_time = self.attr_ac_time or 0
	self.attr_ac_time = self.attr_ac_time + 1
	local delay_span = 0.25
	--if isforcePass or self.attr_ac_time > 3 then delay_span = 0.25 end
	actions[#actions+1] = cc.DelayTime:create(self.attr_ac_time*delay_span)
	actions[#actions+1] = cc.Show:create()
	actions[#actions+1] = cc.ScaleTo:create(0.25,1.1)
	actions[#actions+1] = cc.Spawn:create(cc.MoveBy:create(0.4,cc.p(0,80)),cc.FadeOut:create(0.8))
	actions[#actions+1] = cc.CallFunc:create(function()
							if self.attr_ac_time then
								self.attr_ac_time = self.attr_ac_time - 1
							end
						end)
	actions[#actions+1] = cc.RemoveSelf:create()
	numer_sprite:runAction(cc.Sequence:create(actions))
end

function MapBaseLayer:showExpNumer(number,r_pos,delay,filename,showType )
	if showType == commConst.ePickUp_XP then
		self:showAttrChangeNumer(0,number,"res/mainui/number/4.png","res/mainui/number/exp.png", true )
	elseif showType == commConst.ePickUp_Prestige then
		self:showAttrChangeNumer(0,number,"res/mainui/number/5.png","res/mainui/number/prestige.png" , true )
	end
	
end

function MapBaseLayer:showHurtNumer(number,pos,r_pos,delay,file_type,ishit)
	local numer_sprite = nil
	local file_type = file_type or 1
	local filename = "res/mainui/number/hurt.png"
	local rects = {{0,0,220,30},{0,30,176,25},{0,58,176,25}}
	local spans = {20,16,16}
	if number < 0 then number = number*-1 end
	local order = 0
	if pos then
		if number > 0 then
			--numer_sprite = MakeNumbers:createWithSymbol(filename,number,0)
			numer_sprite = require("src/base/HurtSprite").new(filename,number,rects[file_type],spans[file_type],true)
			if ishit then
				local hit_sp = cc.Sprite:create(filename,cc.rect(0,82,54,28))
				hit_sp:setPosition(cc.p(-15,0))
				hit_sp:setAnchorPoint(cc.p(1,0.0))
				numer_sprite:addChild(hit_sp)
				--createSprite(numer_sprite,"res/mainui/number/hit.png",cc.p(-15,0),cc.p(1,0.5))
			end
		else	-- 修改此处做法，因服务端修改
			numer_sprite = cc.Sprite:create("res/mainui/number/miss.png")
			order = 1
		end
		if not numer_sprite then 
			return
		end
		--self.hurt_num_count = self.hurt_num_count + 1
		self.hurt_node:addChild(numer_sprite,order)
		numer_sprite:setVisible(false)
		--local r_pos = cc.p(self:getMainRole():getPosition())
		local span_pos = cc.p(math.random(-20,20),math.random(80,120))
		if r_pos then
			span_pos =cc.p(pos.x-r_pos.x,pos.y-r_pos.y)
			if span_pos.x ~= 0 then
				span_pos.x = math.random(60,100)*span_pos.x/math.abs(span_pos.x)
			end
			if span_pos.y ~= 0 then
				span_pos.y = math.random(40,80)*span_pos.y/math.abs(span_pos.y)
			end
		end
		numer_sprite:setCascadeOpacityEnabled(true)
		numer_sprite:setPosition(cc.p(pos.x+math.random(-10,10),pos.y+math.random(0,30)))
		local actions = {}
		if delay then
			actions[#actions+1] = cc.DelayTime:create(delay)
		end
		actions[#actions+1] = cc.Show:create()
		actions[#actions+1] = cc.MoveBy:create(0.05*math.random(1,2),span_pos)
		actions[#actions+1] = cc.DelayTime:create(0.1)
		actions[#actions+1] = cc.MoveBy:create(0.05,cc.p(span_pos.x/3,span_pos.y/3))
		actions[#actions+1] = cc.DelayTime:create(0.15*math.random(1,2))

		actions[#actions+1] = cc.Spawn:create( cc.ScaleTo:create(0.3,0.8),cc.FadeOut:create(0.8))
		actions[#actions+1] = cc.RemoveSelf:create()
		numer_sprite:runAction(cc.Sequence:create(actions))
		--numer_sprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,1.3),cc.ScaleTo:create(0.3,0.8)))
	end
end

function MapBaseLayer:roleStartToAttack(skillid,attacker,targte_tile)
	if self.isStory then
		return require("src/base/AttackFunc")(self,skillid,attacker,targte_tile)
	else
		return require("src/base/AttackFuncEx")(self,skillid,attacker,targte_tile)
	end
end


function MapBaseLayer:touchCharmModel()
	if G_CharmRankList and G_CharmRankList.ListData and #G_CharmRankList.ListData > 0 then
		local data = G_CharmRankList.ListData[1]
		if data[2] and data[2] ~= "" then
			if tostring(data[2]) == G_ROLE_MAIN:getTheName() then
				TIPS({str = game.getStrByKey("charm_CheckSelf") })
				return
			end
			LookupInfo(tostring(data[2]))
		else
			TIPS({str = game.getStrByKey("charm_NoTop") })			
		end
	else
		TIPS({str = game.getStrByKey("charm_NoTop") })
	end
end

function MapBaseLayer:touchKingModel(monster_node)
	self:resetTouchTag()
	if monster_node then
		if monster_node.isActioning then return end
		local targetPos = self:space2Tile(cc.p(monster_node:getPosition()))
		local role_pos  = self:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
		local offSetX,offSetY,modeId = 3 , 3 , 1

		if math.abs(role_pos.x - targetPos.x) < offSetX and math.abs(role_pos.y - targetPos.y) < offSetY then
			__GotoTarget({ ru = "a88", where = modeId})
		else
			local posX = role_pos.x
			if math.abs(role_pos.x - targetPos.x) >= offSetX then
				posX = (targetPos.x > role_pos.x) and targetPos.x - offSetX + 1 or targetPos.x + offSetX - 1
			end
			local posY = role_pos.y
			if math.abs(role_pos.y - targetPos.y) >= offSetY then
				posY = (targetPos.y > role_pos.y) and targetPos.y - offSetY + 2 or targetPos.y + offSetY - 1
			end			
			
			G_MAINSCENE.map_layer:moveMapByPos( cc.p(posX, posY) ,true)
			G_MAINSCENE.map_layer:removeWalkCb()
			local function handlerFun()
				G_MAINSCENE.map_layer:removeWalkCb()
				__GotoTarget({ ru = "a88", where = modeId})
			end
			G_MAINSCENE.map_layer:registerWalkCb( handlerFun )
		end
	end
end

function MapBaseLayer:touchMonsterFunc(monster_node, auto_attack)
	if self.isStory then
        if  G_MAINSCENE.storyNode:isCanTouchMonster() ~= true then
            return
        end
    end

	if monster_node then
		--if monster_node:getType() == 10 then
        local mId = monster_node:getMonsterId()
		if mId >= 9 and mId <= 11 then
			--print("send EMOUNT_CS_ARREST_MOUNT",monster_node:getTag())
			g_msgHandlerInst:sendNetDataByTable(EMOUNT_CS_ARREST_MOUNT,"MountArrestProtocol",{ dwEntityId = monster_node:getTag() })
			return
		end

	    if self.select_monster and self.select_monster == monster_node then
			if auto_attack then
				game.setAutoStatus(AUTO_ATTACK)
			else
				self.on_attack = true
			end
			return
		end
		self:resetTouchTag()

        local monster_data = getConfigItemByKey("monster","q_id",mId)
        if monster_data.q_type == 1 then
			local select_effect = Effects:create(false)
			select_effect:setAnchorPoint(cc.p(0.5,0.5))
			monster_node:addChild(select_effect,0,158)
			select_effect:playActionData("selectMonsterNormal", 5, 2, -1)
   			select_effect:setRenderMode(1)
			select_effect:setOpacity(monster_node:getOpacity()) 
		end
        --end

        if not self.isStory then
		    monster_node:showNameAndBlood(true)
        end

		self.select_monster = monster_node
		
		if DATA_Mission then DATA_Mission:checkUseTag( 1 , mId ) end --检测是否是使用任务目标

		if monster_node:getType() >= 10 and monster_node:getType() < 14 then
			if self.monster_head and tolua.cast(self.monster_head,"cc.Node") then
				removeFromParent( self.monster_head )
				self.monster_head = nil 
			end

			local monster_head = require("src/base/MonsterBlood").new(monster_node,self)
			monster_head:setPosition(g_scrSize.width/2 - 200,g_scrSize.height-40)
            if (G_MAINSCENE.map_layer.isStory and G_MAINSCENE.storyNode.playerTab) then
			    self.parent:addChild(monster_head,200)
            else
                self.parent:addChild(monster_head,100)
            end
			self.monster_head = monster_head

		end
	end
end

function MapBaseLayer:touchNpcFunc(npc_node,is_touch)
	if npc_node then	
		local func = function()
			self:resetTouchTag()
            self.select_npc = npc_node
            --迷仙阵的宝箱NPC点击不显示圆圈
            if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.npc == npc_node and G_MAINSCENE.map_layer.npc:getResId() == 10047 then
                return
            end
			local select_effect = Effects:create(false)
			select_effect:setPosition(cc.p(0,-10))
			select_effect:setAnchorPoint(cc.p(0.5,0.5))
			npc_node:addChild(select_effect,0,158)
            select_effect:playActionData("select",7,2,-1)
   			addEffectWithMode(select_effect,3)
		end

		if npc_node.isCollect and ((not (DATA_Mission and DATA_Mission:checkCollection( npc_node:getTag()))) or self.caiji_num) then
			return
		end
		
		--如果在别人行会驻地里面. 点击npc不响应
		if self.mapID == 6017 and self.inviteFactionId then
			TIPS({str = game.getStrByKey("faction_Invite_npcTips")})
			return
		end

		func()
		local walkCb = function()
			if is_touch then
				self:removeWalkCb()
			end

			if npc_node.isCollect == true then
				self:taskCaiJi(npc_node:getTag(), 1)
			else
                -- 点击普通NPC
                if npc_node:getTag() == 10481 then  -- jieyi npc
                    if G_TEAM_INFO.memCnt == 1 then
                        require("src/layers/jieyi/JieYiCommFunc").showJieYiErrorCode(9)
                        return
                    elseif not isSelfTeamLeader() then
                        require("src/layers/jieyi/JieYiCommFunc").showJieYiErrorCode(10)
                        return
                    elseif G_TEAM_INFO.memCnt > 4 then
                        require("src/layers/jieyi/JieYiCommFunc").showJieYiErrorCode(8)
                        return
                    end
                elseif npc_node:getTag() == 10480 and MRoleStruct:getAttr(ROLE_LEVEL) < 40 then  -- jieyi npc & role level not reach 40
                    require("src/layers/jieyi/JieYiCommFunc").showJieYiErrorCode(2)
                    return
                end
				require("src/layers/mission/MissionNetMsg"):sendClickNPC(npc_node:getTag())	
			end
		end
		-- if npc_node.id == 10454 then
		-- 	self:touchCharmModel()
		-- 	return
		-- else
		if npc_node.id >= 10468 and npc_node.id <= 10473 then
			self:touchKingModel(npc_node)
			return
		end
		local npc_tile = npc_node:getTilePoint()
		local span_tile = 10
		if G_ROLE_MAIN and G_ROLE_MAIN.tile_pos then
			span_tile = math.max(math.abs(G_ROLE_MAIN.tile_pos.x-npc_tile.x),math.abs(G_ROLE_MAIN.tile_pos.y-npc_tile.y))
		end		
		if is_touch and span_tile > 1 then
			self:registerWalkCb(walkCb)
			local tile_pos = self:space2Tile(cc.p(npc_node:getPosition()))
			self:moveMapByPos(tile_pos,true)
		else
			walkCb()
		end
	end
end

function MapBaseLayer:touchMineFunc(mine_node)
	if self.isStory then
        if G_MAINSCENE.storyNode and G_MAINSCENE.storyNode.onTouchMine then
            G_MAINSCENE.storyNode:onTouchMine(mine_node)
        end

        return
    end
    
    if mine_node and self.select_mine and self.select_mine == mine_node and game.getAutoStatus() == AUTO_MINE then
		return
	end	
	self:resetTouchTag()
	if mine_node and tolua.cast(mine_node, "cc.Node") then
		--if mine_node. then
		
		--end
        local select_effect = Effects:create(false)
		select_effect:setAnchorPoint(cc.p(0.5,0.5))
		mine_node:addChild(select_effect,0,158)
		select_effect:playActionData("select",7,2,-1)
		addEffectWithMode(select_effect,3)

		self.select_mine = mine_node
		local walkCb = function()
			self:removeWalkCb()
			if self.select_mine and tolua.cast(self.select_mine,"SpriteMonster")then
				-- require("src/layers/timeToTonic/tonicConfigHandler"):tonicInit(2,mine_node)
				if self.mapID == 5008 then
					g_msgHandlerInst:sendNetDataByTableExEx(DIGMINE_CS_START,"DigMineStart",{ flag = 0 , mineID = self.select_mine:getTag() })
				else 
					g_msgHandlerInst:sendNetDataByTableExEx(DIGMINE_CS_START,"DigMineStart",{ flag = 1 , mineID = self.select_mine:getTag() })
				end
			end
			--print("send DIGMINE_CS_START",DIGMINE_CS_START)
		end
		self:registerWalkCb(walkCb)
		local tile_pos = self:space2Tile(cc.p(mine_node:getPosition()))
		self:moveMapByPos(tile_pos,true)

		if tutoRemoveMineAction then
			tutoRemoveMineAction()
		end
	end
end

function MapBaseLayer:touchPetFunc(pet_node)
	self:resetTouchTag()
	if pet_node then
		local select_effect = Effects:create(false)
		select_effect:setAnchorPoint(cc.p(0.5,0.5))
		pet_node:addChild(select_effect,0,158)
		select_effect:playActionData("select",7,2,-1)
		addEffectWithMode(select_effect,3)
		self.select_pet = pet_node
	end
end

function MapBaseLayer:touchRoleFunc(role_item, auto_attack)
	if self.select_role and self.select_role == role_item then
		if auto_attack then
			game.setAutoStatus(AUTO_ATTACK)
		else
			self.on_attack = true
		end
		return
	end
	self:resetTouchTag()
	local role_node = tolua.cast(role_item,"SpritePlayer")
	if role_node then
		local obj_id = role_node:getTag()
		if  obj_id~= self.role_id then
			local effect_img = "select"
			local MRoleStruct = require("src/layers/role/RoleStruct")
			local fac_id = MRoleStruct:getAttr(PLAYER_FACTIONID,obj_id)
			local m_fac_id = MRoleStruct:getAttr(PLAYER_FACTIONID)
			if 	m_fac_id and fac_id and m_fac_id > 0 and fac_id == m_fac_id then
				--同帮
				effect_img = "roleselect"
			end
			local is_team_meb = false
			if G_TEAM_INFO and G_TEAM_INFO.team_data then
				for k,v in pairs(G_TEAM_INFO.team_data)do
					if v.name == role_node:getTheName() then
						is_team_meb = true
						break
					end
				end
			end
			if is_team_meb then
				--同队伍
				effect_img = "roleselect"
			end
			if not role_node:getChildByTag(158) then
				local select_effect = Effects:create(false)
				if role_node:getIsOnHighRide() then
					select_effect:setPosition(cc.p(0,5))
				else
					select_effect:setPosition(cc.p(0,-10))
				end
				select_effect:setAnchorPoint(cc.p(0.5,0.5))
				role_node:addChild(select_effect,0,158)
				select_effect:playActionData(effect_img,7,2,-1)
	   			addEffectWithMode(select_effect,3)
	   		end
			self.select_role = role_node
			if self.monster_head and tolua.cast(self.monster_head,"cc.Node") then
				removeFromParent( self.monster_head )
				self.monster_head = nil 
			end
			local monster_head = require("src/base/MonsterBlood").new(role_node,self)
            if self.isSkyArena then
			    monster_head:setPosition(g_scrSize.width/2 - 250,g_scrSize.height-40);
            else
                monster_head:setPosition(g_scrSize.width/2 - 200,g_scrSize.height-40)
            end
            if (G_MAINSCENE.map_layer.isStory and G_MAINSCENE.storyNode.playerTab) then
			    self.parent:addChild(monster_head,200)
            else
                self.parent:addChild(monster_head,100)
            end
			self.monster_head = monster_head
			--if game.getAutoStatus() == AUTO_ATTACK then
				--G_ROLE_MAIN:setUnToAttack(false)
			--end
		end
	end
end

function MapBaseLayer:doSpecialSkill(touch)
	local pos = self:convertToNodeSpace(touch:getLocation())
	local tile_pos = self:space2Tile(pos)
	local school = MRoleStruct:getAttr(ROLE_SCHOOL)
	if not G_ROLE_MAIN then return false end
	local skill_id = nil
	for k,v in pairs(G_ROLE_MAIN.base_data.spe_skill)do 
		skill_id = k
	end 
	if skill_id then
		if (not self.common_cd) and (not G_MAINSCENE.skill_cds[skill_id]) then
			G_ROLE_MAIN:upOrDownRide_ex(G_ROLE_MAIN,false)
			local attack_R = getConfigItemByKey("SkillCfg","skillID",skill_id,"useDistance")
			local playFunc = function()
				if self:isInSafeArea(tile_pos) and (not self.isStory) then
					TIPS( getConfigItemByKeys("clientmsg",{"sth","mid"},{3000,-16})  ) 
					return
				end
			 	g_msgHandlerInst:sendNetDataByTable(SKILL_CS_USESKILL, "SkillUseProtocol", {skillId=skill_id,targetId=0,targetX=tile_pos.x,targetY=tile_pos.y})
				local pos = self:tile2Space(tile_pos)
				local do_attack = G_ROLE_MAIN:magicUpToPos(0.4,pos)
				if do_attack then
                    -- 剧情地表魔法由客户端负责技能处理 [例如 3001 群体治愈术 激活施法]
                    if (not self.isStory) and (CMagicCtrlMgr:getInstance():IsMagicCanDisplay(skill_id) == 3) then
                        local floorTile = CMagicCtrlMgr:getInstance():MakeLongMacro(tile_pos.x, tile_pos.y);
                        CMagicCtrlMgr:getInstance():CreateMagic(skill_id, 0, G_ROLE_MAIN:getTag(), floorTile, 0);
                    else
					    self:playSkillEffect(0.15,skill_id,G_ROLE_MAIN,nil,pos);
                    end
					self.parent:doSkillAction(skill_id)
				end
			end
            
            if self.isStory then
                playFunc()			
            elseif math.abs(tile_pos.x - G_ROLE_MAIN.tile_pos.x) > attack_R or math.abs(tile_pos.y - G_ROLE_MAIN.tile_pos.y) > attack_R then
				local dir = getDirBrPos(cc.p((tile_pos.x-G_ROLE_MAIN.tile_pos.x),(tile_pos.y-G_ROLE_MAIN.tile_pos.y)))+1
				local dir_map = {{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1},{0,-1},{1,-1}}
				attack_R = attack_R -1
				local can_attack_pos = cc.p(tile_pos.x-dir_map[dir][1]*attack_R,tile_pos.y-dir_map[dir][2]*attack_R)
				while self:isBlock(can_attack_pos) do
					if attack_R > 1 then
						attack_R = attack_R - 1
						can_attack_pos = cc.p(tile_pos.x-dir_map[dir][1]*attack_R,tile_pos.y-dir_map[dir][2]*attack_R)
					else 
						can_attack_pos = tile_pos
						break
					end
				end

				self:registerWalkCb(playFunc)
				self:moveMapByPos(can_attack_pos,false)
			else
				playFunc()
			end

		end
		return true
	end
	return false   
end

function MapBaseLayer:initNodeItemTouch()
	local  listenner = cc.EventListenerTouchOneByOne:create()
    	listenner:setSwallowTouches(true)
    	listenner:registerScriptHandler(function(touch, event)
    		if G_MAINSCENE then
    			G_MAINSCENE:insertMulitTouch(touch)

    			if G_MAINSCENE:checkMulitTouchNum() then 
					return false 
				end
    		end
    		if (not G_MAINSCENE) or (not G_ROLE_MAIN) then
    			return false 
    		end
			
			self.touch_node = nil
  			self.touch_npc 	= nil

  			if self:doSpecialSkill(touch) then
    			return true
    		end
  			self.touch_role = nil
  			self.touch_pet  = nil
	    	
			for k,v in pairs(self.mineTab)do
				local monster_node = tolua.cast(self.item_Node:getChildByTag(v),"SpriteMonster")
				if monster_node and monster_node:isTouchInside(touch) then
					self.touch_mine = monster_node
					return true
				end
			end

			for k,v in pairs(self.npc_tab)do
				--中州王
			    if k >= 10455 and k <= 10460 then
	       		   	local pos1 = cc.p(v:getPosition())
	       		   	local pt = self:convertTouchToNodeSpace(touch)
	       		   	local rect = cc.rect(pos1.x - 50, pos1.y - 30, 140, 80)
	       		   	if cc.rectContainsPoint(rect, pt)then
	       				self.touch_npc = v
       					return true
	       			end
	       		end

	       		--沙城主
	       		if k >= 10468 and k <= 10473 then
	       		   	local pos1 = cc.p(v:getPosition())
	       		   	local pt = self:convertTouchToNodeSpace(touch)
	       		   	local rect = cc.rect(pos1.x - 50, pos1.y - 30, 140, 80)
	       		   	if cc.rectContainsPoint(rect, pt)then
	       				self.touch_npc = v
       					return true
	       			end
	       		end

                -- wedding system wine table
                --[[
                if k ==  then   -- wine table id
                    local pos1 = cc.p(v:getPosition())
	       		   	local pt = self:convertTouchToNodeSpace(touch)
	       		   	local rect = cc.rect(pos1.x - 50, pos1.y - 30, 140, 80)
	       		   	if cc.rectContainsPoint(rect, pt)then
	       				self.touch_npc = v
       					return true
	       			end
                end
                ]]

				if v:isTouchInside(touch) then
					self.touch_npc = v
					return true
				end
			end

			local select_node = require("src/base/SelectRoleLayer")
			local pkmode = require("src/layers/pkmode/PkModeLayer"):getCurMode()
			for k,v in pairs(self.role_tab)do
				local role_node =  self:isValidStatus(v)
				if v~=G_ROLE_MAIN.obj_id and role_node and role_node:isVisible() and role_node:isTouchInside(touch) then
					local can_attack,is_wudi = select_node:isCanAttack(pkmode,v)
					if game.getAutoStatus() == AUTO_ATTACK and (not can_attack) then
						if is_wudi then
							TIPS( getConfigItemByKeys("clientmsg",{"sth","mid"},{ 3000,-13})  ) 
						else
							TIPS( getConfigItemByKeys("clientmsg",{"sth","mid"},{ 3000,-12})  ) 
						end
					else
						self.touch_role = role_node
					end
					return true
				end
			end

			for k,v in pairs(self.monster_tab)do
	    		local monster_node = self:isValidStatus(v)
	    		
				if monster_node and monster_node:isVisible() and monster_node:isTouchInside(touch) then
					self.touch_node = monster_node
					return true
				end
			end

			for k,v in pairs(self.pet_tab)do
				local pet_node =  self:isValidStatus(v)
				if pet_node and pet_node:isVisible() and pet_node:isTouchInside(touch) then
					self.touch_pet = pet_node
					return true
				end
			end
            return false
        	end,cc.Handler.EVENT_TOUCH_BEGAN )
    	listenner:registerScriptHandler(function(touch, event)
    		G_MAINSCENE:moveMulitTouch(touch)
 
    		local touchForce = Director:getTouchForce()
    		if touchForce >= 5 then
				if getRunScene():getChildByTag(2000) == nil then
	    			LookupInfo(self.touch_role:getTheName())
				end
    		end

    	end,cc.Handler.EVENT_TOUCH_MOVED )
    	listenner:registerScriptHandler(function(touch, event)
           	if self.touch_node and tolua.cast(self.touch_node,"SpriteMonster") then
           		local monster_id = self.touch_node:getMonsterId()
           		local owner_name = MRoleStruct:getAttr(ROLE_HOST_NAME,self.touch_node:getTag()) or "0"
           		-- if monster_id == 53001 then
           		-- 	self:touchCharmModel()
           		-- elseif isKingModel(monster_id) then            		   
           		-- 	self:touchKingModel(self.touch_node)
           		--else
           		local carCfg = { ["80000"] = true , ["80001"] = true , ["80002"] = true , ["80003"] = true }
           		if MRoleStruct:getAttr(ROLE_NAME) == owner_name then
           		elseif carCfg["" .. monster_id] and self.mapID == commConst.MAPID_DARTFB then
           		elseif monster_id~=9005 then
           			self:touchMonsterFunc(self.touch_node)
	           		--game.setAutoStatus(AUTO_ATTACK)
				end
          	elseif self.touch_npc then
           		self:touchNpcFunc(self.touch_npc,true)
           	elseif self.touch_role then
           		self:touchRoleFunc(self.touch_role)
           	elseif self.touch_pet then
           		self:touchPetFunc(self.touch_pet)
           	elseif self.touch_mine then
           		self:touchMineFunc(self.touch_mine)
          	end
          	G_MAINSCENE:restMulitTouch(touch)
        	end,cc.Handler.EVENT_TOUCH_ENDED )
		listenner:registerScriptHandler(function(touch, event)
			G_MAINSCENE:restMulitTouch(touch)
		end,cc.Handler.EVENT_TOUCH_CANCELLED )
    	local eventDispatcher =  self:getEventDispatcher()
    	eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self.item_Node)

    --if Director:isSupport3DTouch() ~= 0 then
	    local  listenner2 = cc.EventListenerTouchOneByOne:create()
	    listenner2:setSwallowTouches(false)

	    listenner2:registerScriptHandler(function(touch, event)
	    	return true
			end,cc.Handler.EVENT_TOUCH_BEGAN )

	    listenner2:registerScriptHandler(function(touch, event)
	    		local touchForce = Director:getTouchForce()
	    		if touchForce >= 5 then
	    			if not HasTargetTab("a31") then
		    			__GotoTarget( { ru = "a31" } )
		    		end
	    		end
	    	end,cc.Handler.EVENT_TOUCH_MOVED )
	    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner2,self.item_Node)
	--end

end


function MapBaseLayer:bloodupdate(objId,hp,reset,attacker,attack_pos)
	local target_node = self:isValidStatus(objId) 
	if not target_node then
		return
	end
	local monster_id = target_node:getMonsterId()
	local target_type = target_node:getType()
	local sub_hp = hp - target_node:getHP()

	if target_type > 20 then
		if ((not reset) and hp*20 >= target_node:getMaxHP()) or (hp <= 0 and reset) then
			G_ROLE_MAIN:upOrDownRide_ex(target_node,nil,false)
		end
	end
	if hp then
		local r_pos = cc.p(target_node:getPosition())
		sub_hp = target_node:getHP() - hp
		if reset then
			if hp <= 0 then
				target_node:subBlood(target_node:getHP())
			elseif sub_hp > 0 then
				target_node:subBlood(sub_hp)
			else
				target_node:setHP(hp)
			end
		elseif G_ROLE_MAIN and objId ~= G_ROLE_MAIN.obj_id then
			target_node:subBlood(hp)
		end

		-- --怪物头像更新
		-- if self.monster_head and tolua.cast(self.monster_head,"cc.Node") and self.monster_head.monster_id == objId then
		-- 	self.monster_head:updateInfo(target_node)
		-- end

		local curhp = target_node:getHP()
		MRoleStruct:setAttrHPByValue(objId, curhp)
		if curhp <= 0 then
			--公平竞技场箭塔死了后不消失
			local deadDisappear=true
			if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena and target_node:getMonsterId()>=652 and target_node:getMonsterId()<=655 then
				deadDisappear=false
			end	
			if target_type > 20 then
				local node = tolua.cast(target_node, "SpritePlayer")
				if node then
					G_ROLE_MAIN:isChangeToHoe(node, false)
				end
				if target_type == 22 then
					target_node:gotoDeath(6)
					AudioEnginer.playEffect("sounds/actionMusic/103.mp3",false)
				else
					target_node:gotoDeath(7)
					AudioEnginer.playEffect("sounds/actionMusic/3.mp3",false)
				end
				--if self.select_role and objId == self.select_role:getTag() then
					--G_ROLE_MAIN:setUnToAttack(true)
				--end
			else
				local m_tile_pos = target_node:getServerTile()
				--local dir = target_node:getCurrectDir()
				--local span_tile = self:getTileByDir(dir)
				target_node:setPosition(self:tile2Space(m_tile_pos))
				if self.isfb and userInfo.lastFbType~=commConst.CARBON_MULTI_GUARD and userInfo.lastFbType~=commConst.CARBON_PRINCESS and G_ROLE_MAIN.base_data.pet_id~=objId then
					if self.isNewRound then
						self.isNewRound = nil
					else
						self.deadNum = self.deadNum + 1
						self:updateProgress()
					end
				end
				local r_tile_pos =  attack_pos and self:space2Tile(attack_pos) or G_ROLE_MAIN.tile_pos
				local span_tile = cc.p(r_tile_pos.x-m_tile_pos.x,r_tile_pos.y-m_tile_pos.y)
				if span_tile.x ~= 0 then
					span_tile.x = span_tile.x/math.abs(span_tile.x)
				end
				if span_tile.y ~= 0 then
					span_tile.y = span_tile.y/math.abs(span_tile.y)
				end
	
				local dead_dir = 7
				if span_tile.x < 0 then
					dead_dir = 5
				end
				if not deadDisappear then
					target_node:gotoDeath(dead_dir,1.0)
				else
					target_node:gotoDeath(dead_dir)
				end
				--公平竞技场箭塔死了后不消失
				if getGameSetById(GAME_SET_MONSTER_DIEDSHOW) == 1 and deadDisappear then
					target_node:runAction(cc.Sequence:create(cc.DelayTime:create(0.8),cc.Hide:create()))
				end
				AudioEnginer.randMonsterMus(target_node:getMonsterId(),3)				
			end
			if deadDisappear then
				target_node:setOpacity(150)
			end
			if target_node:getChildByTag(158) then target_node:removeChildByTag(158) end
			if target_node:getChildByTag(155) then target_node:removeChildByTag(155) end
			--target_node:setLocalZOrder(1)
			local select_node = self.select_monster or self.select_role
			select_node = tolua.cast(select_node,"SpriteMonster")
			if select_node and select_node:getTag() == objId then
				self:resetTouchTag()
				self:setRockDir(10)
			end

			if self.monster_head and self.monster_head.monster_id and self.monster_head.monster_id == objId and tolua.cast(self.monster_head,"cc.Node") then
				removeFromParent(self.monster_head)
				self.monster_head = nil
			end

			if G_ROLE_MAIN and objId == G_ROLE_MAIN.obj_id then
					self:resetHangup()
					self:cleanAstarPath(true,true)
					self.caiji_num = nil
					if G_MY_STEP_SOUND then
						AudioEnginer.stopEffect(G_MY_STEP_SOUND) 
						G_MY_STEP_SOUND = nil
					end	
					self.last_attacker = attacker	
				--end
			end
		end
	end
	
end

function MapBaseLayer:showReliveLayer(objId)
	if G_ROLE_MAIN and objId == G_ROLE_MAIN.obj_id then	
		local hp = MRoleStruct:getAttr(ROLE_HP)
		if hp <= 0 then

			--if (G_MAINSCENE:CheckEmpireState() and G_FACTION_INFO.facname ) then
				--帮派战 不弹正常死亡界面
            local bool_isMiXianZhen = false
            for k, v in pairs(require("src/config/fanxianfront")) do
                if v.q_map_id == G_MAINSCENE.map_layer.mapID then
                    bool_isMiXianZhen = true
                    break
                end
            end
			if self:isHideMode(true) and G_MAINSCENE.map_layer.mapID ~= 6003 and G_MAINSCENE.map_layer.mapID ~= 5104 and G_MAINSCENE.map_layer.mapID ~= 5008 and not bool_isMiXianZhen then

				--如果是副本，活动地图.不弹正常死亡界面
			elseif G_MAINSCENE:checkShaWarState() then --or (MRoleStruct:getAttr(PLAYER_PK) >= 4 and MRoleStruct:getAttr(ROLE_LEVEL) >=35) then
				--沙城战 不弹正常死亡界面
            elseif self.mapID == 5104 and self.isOver then
                -- 多人守卫已经结算，不出现复活
            elseif self.mapID == 5003 then
            	
			elseif self.mapID == 5008 and userInfo and userInfo.lastFbType == commConst.CARBON_MINE then
				local robMineEndData = {}
	      		robMineEndData.isWin = false
	    		self:showRobMineResult(robMineEndData, 0) 
	    	elseif G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isSkyArena then
	    		self:showRelivePanel()               	
			else
				G_ROLE_MAIN:isChangeToHoe(G_ROLE_MAIN, false)
				if not G_MAINSCENE.relive_layer then
					local r_live = require("src/layers/task/relive").new(self.last_attacker)
					if G_MAINSCENE then
						G_MAINSCENE:addChild(r_live, 333,9999)
					end
				end
			end
            --迷仙阵中如果死亡，复活收到进入场景消息不需要刷新地图
            if bool_isMiXianZhen then
                G_MYSTERIOUS_REVIVE_STETE.alive = false
            end
		end
	else
		local role_item =  tolua.cast(self.item_Node:getChildByTag(objId),"SpritePlayer")
		if role_item then
			role_item:showNameAndBlood(false)
			local status = role_item:getCurrActionState()
			local s_type = role_item:getType()
			if status < ACTION_STATE_DEAD then
				if s_type > 20 then
					G_ROLE_MAIN:isChangeToHoe(role_item, false)
					if  s_type == 22 then
						role_item:gotoDeath(6,0.01)
					else
						role_item:gotoDeath(7,0.01)
					end
					role_item:setOpacity(128)
					role_item:setVisible(false)
					if getGameSetById(GAME_SET_ID_SHIELD_PLAYER)==0 then
						role_item:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.Show:create()))
					end
				else
					role_item:gotoDeath(7,0.01)
					role_item:setVisible(false)
					if getGameSetById(GAME_SET_ID_SHIELD_MONSTER)==0 then
						role_item:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.Show:create()))
					end
					if not (self.isSkyArena )then
						role_item:setOpacity(128)
					end
				end
			end
			--模拟挖矿，这里要把坏蛋头顶的矿去掉
			if self.mapID == 5008 and userInfo and userInfo.lastFbType == commConst.CARBON_MINE then
				G_ROLE_MAIN:setCarry_ex(role_item , {})
			end
		end
	end
end

function MapBaseLayer:isValidStatus(objid)
	if self.monster_tab[objid] or self.role_tab[objid] or self.pet[objid] or self.MulityObjId == objid  then
		local monster_node =  tolua.cast(self.item_Node:getChildByTag(objid),"SpriteMonster")
		if monster_node and (monster_node:isAlive() or objid == 9001) then
			return monster_node
		end
	end
	return nil
end

--[[ MainMapLayer
function MapBaseLayer:isPlayerInOneScreen(pId)
    for k,v in pairs(self.role_tab) do
        if v == pId then
            return true
        end
    end
    return false
end 
]]

function MapBaseLayer:selectTheRole()
	local max_distance = 16
	local select_role = self.select_role
	local cur_mode = require("src/layers/pkmode/PkModeLayer"):getCurMode()
	local select_node = require("src/base/SelectRoleLayer").new(cur_mode)
	if not select_role then
		for k,v in pairs(self.role_tab)do
			if v~= self.role_id then
				local r_node = self:isValidStatus(v)
				if r_node and r_node:isVisible() then
					local m_pos = cc.p(r_node:getPosition())
					local m_tile_pos = self:space2Tile(m_pos)
					local distance = cc.pGetDistance(G_ROLE_MAIN.tile_pos,m_tile_pos)
					if distance < max_distance and select_node:isCanAttack(cur_mode,v) then
						max_distance = distance
						select_role = r_node
						--if distance <= 1 then
							--break
						--end
					end
				end
			end
		end
		if select_role then
			self:touchRoleFunc(select_role)
		end
	end
	select_node:setPosition(cc.p(g_scrSize.width-180-240,120))
	G_MAINSCENE:addChild(select_node,199)
end

function MapBaseLayer:autoPickUp(auto)
	local auto_pick = false
	if not auto then
		if (not (game.getAutoStatus() == AUTO_ATTACK or game.getAutoStatus() == AUTO_PICKUP)) then
			return false
		else
			auto_pick = true
		end
	end
	if self.on_pickup and self:hasPath() then  return false end
	if self.goods_tab and G_ROLE_MAIN then
		local propOp = require("src/config/propOp")
		local MRoleStruct = require("src/layers/role/RoleStruct")
		local MPackStruct = require "src/layers/bag/PackStruct"
		local minDistance = 16
		--local r_pos = cc.p(G_ROLE_MAIN:getPosition())
		local role_tile_pos = self:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
		local pick_item = nil
		local Tab = {		
				["equip"] = {
					GAME_SET_ID_PICKUP_WHITE_EQUIP,
					GAME_SET_ID_PICKUP_GREEN_EQUIP,
					GAME_SET_ID_PICKUP_BLUE_EQUIP,
					GAME_SET_ID_PICKUP_VIOLET_EQUIP,
					GAME_SET_ID_PICKUP_ORANGE_EQUIP,
				},
				["drug"] = {
					GAME_SET_ID_PICKUP_WHITE_MATERIAL,
					GAME_SET_ID_PICKUP_GREEN_MATERIAL,
					GAME_SET_ID_PICKUP_BLUE_MATERIAL,
					GAME_SET_ID_PICKUP_VIOLET_MATERIAL,
					GAME_SET_ID_PICKUP_ORANGE_MATERIAL,
				},
				["other"] = {
					GAME_SET_ID_PICKUP_WHITE_OTHER,
					GAME_SET_ID_PICKUP_GREEN_OTHER,
					GAME_SET_ID_PICKUP_BLUE_OTHER,
					GAME_SET_ID_PICKUP_VIOLET_OTHER,
					GAME_SET_ID_PICKUP_ORANGE_OTHER,
				},
			}
		local qua = function(str,tag) 
			return (getGameSetById(Tab[str][tag]) and getGameSetById(Tab[str][tag]) == 0)
		end
		for v,k in pairs(self.goods_tab)do
			local owner = MRoleStruct:getAttr(ROLE_HP,v) or 0
			if ((owner == 0 or owner == G_ROLE_MAIN.obj_id) and k) or auto then
				local item = v--tolua.cast(self.item_Node:getChildByTag(v),"cc.Sprite")
				if  k~=100 and k~=200 and k~=300 and auto_pick then
					if G_MAINSCENE.bag_full_time >= 5 then
						-- print("aaaaaaaaaaaaaa222222222222222222222")
						item = nil
					else
						local quality =  propOp.quality(k)
						if (not quality) or quality == 0 then quality = 1 end
						local Category = MPackStruct:getCategoryByPropId(k)
						if Category == MPackStruct.eEquipment and ((getGameSetById(GAME_SET_AUTO_EQUIP) == 1 and qua("equip",quality)) or getGameSetById(GAME_SET_AUTO_EQUIP) == 0) then
							-- print("bbbbbbbbbbbbbbbbbbbbbbbbb222222222222222222222222")
							item = nil
						elseif Category == MPackStruct.eMedicine and ((getGameSetById(GAME_SET_AUTO_DRUG) == 1 and qua("drug",quality)) or getGameSetById(GAME_SET_AUTO_DRUG) == 0) then
							-- print("cccccccccccccccccccccc22222222222222222222222222222")
							item = nil
						elseif (not (Category == MPackStruct.eEquipment or Category == MPackStruct.eMedicine)) and ((getGameSetById(GAME_SET_AUTO_OTHER) == 1 and qua("other",quality)) or getGameSetById(GAME_SET_AUTO_OTHER) == 0) then
							-- print("dddddddddddddddddddddddd22222222222222222222222222222")
							item = nil
						end
					end
				elseif (not auto) and getGameSetById(GAME_SET_ID_PICKUP_MONEY) == 0 then
					item = nil
				end
				-- dump(item,"22222222222222222222222222222")
				--if item and ((not self.pick_item) or self.pick_item ~= v) then
				if item then
					local drop_tile = self.goods_tilepos[v]
					local tile_span = math.max(math.abs(role_tile_pos.x-drop_tile.x),math.abs(role_tile_pos.y-drop_tile.y))
					if tile_span < minDistance then
						minDistance = tile_span
						pick_item = v
					end
					--minDistance = math.min(distance,minDistance)
					--相邻格
					if minDistance <= 1 then
						break
					end
				end
			end
		end
		if minDistance >= 10 then
			return false
		end
		--self.pick_item = pick_item
		if pick_item and self.goods_tilepos[pick_item] then
			self.on_pickup = true
			self:moveMapByPos(self.goods_tilepos[pick_item],false)
		end
		if auto then
			self.pick_by_handle = true
		end
		return true
	end
	return false
end

function MapBaseLayer:addBubble(objId, textkey, showTime)
	local charNode = tolua.cast(self.item_Node:getChildByTag(objId), "SpriteMonster")
	if not charNode then
		return
	end

	local charTopNode = charNode:getTopNode()
	if charTopNode then
		local charBubble = charTopNode:getChildByTag(444)
		if charBubble then
			charBubble:removeFromParent()
		end
	end

	-------------------------------------------------------

	local textval = GetTalkByKey(textkey)
	if textval == "" then
		textval = textkey
	end

	local textPos = cc.p(0, 0)
	if charNode.getMainSprite then
		local mainSprite = charNode:getMainSprite()
		if mainSprite then
			local mainRect = mainSprite:getTextureRect()
			textPos.y = textPos.y + mainRect.height/2
		end
	end


	local charBubbleNew = require("src/base/MonsterBubble").new(textval, textPos)
	local charTopNode = charNode:getTopNode()
	if charTopNode then
		charTopNode:addChild(charBubbleNew,4)
	end
	charBubbleNew:setTag(444)

	-------------------------------------------------------

	local funcRemove = function()
		self:removeBubble(objId)
	end

    if showTime == nil then
        showTime = 3
    end
	performWithDelay(self, funcRemove, showTime)

end

function MapBaseLayer:removeBubble(objId)
	local charNode = tolua.cast(self.item_Node:getChildByTag(objId), "SpriteMonster")
	if not charNode then
		return
	end

	local charTopNode = charNode:getTopNode()
	if charTopNode then
		local charBubble = charTopNode:getChildByTag(444)
		if charBubble then
			charBubble:removeFromParent()
		end
	end
end

function MapBaseLayer:networkHander(buff,msgid)
end


return MapBaseLayer