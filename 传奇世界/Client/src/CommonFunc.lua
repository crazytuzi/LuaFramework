require("src/GotoTarget")
g_normal_close_id = 5010501
function __getMapIDByRoleId(roleid)
    if G_MAINSCENE and G_MAINSCENE.mapId then
        return G_MAINSCENE.mapId
    end
    if g_roleTable and #g_roleTable > 0 then
        for k,v in pairs(g_roleTable)do
            if v["RoleID"] == roleid then
                return tonumber(v["MapID"])
            end
        end
    end
end

--加好友检查网络黑名单
function AddFriends(name_str, name_tab)
	--log("AddFriends = "..name_str)
	if G_ROLE_MAIN and G_ROLE_MAIN:getTheName() == name_str then
		TIPS({str = game.getStrByKey("charm_addFriendToSelf"), type = 1})
		return
	end
		
	g_msgHandlerInst:registerMsgHandler(RELATION_SC_GETRELATIONDATA_RET , function(buff)
		log("get RELATION_SC_GETRELATIONDATA_RET")
		local t = g_msgHandlerInst:convertBufferToTable("GetRelationDataRetProtocol", buff) 
		local relationType = t.relationKind
		log("relationType = "..relationType)
		dump(relationType)
		if relationType == 3 then
			local blackData = {}
			-- local onlineNum = buff:popChar()
			-- for i=1,onlineNum do
			-- 	local record = {}
			-- 	record.roleId = buff:popInt()
			-- 	record.name = buff:popString()
			-- 	record.lv = buff:popChar()
			-- 	record.sex = buff:popChar()
			-- 	record.school = buff:popChar()
			-- 	record.fight = buff:popInt()
			-- 	record.online = true

			-- 	table.insert(blackData, #blackData+1, record)
			-- end
			-- local offLineNum = buff:popChar()
			-- for i=1,offLineNum do
			-- 	local record = {}
			-- 	record.roleId = buff:popInt()
			-- 	--log("test 1")
			-- 	record.name = buff:popString()
			-- 	--log("test 2")
			-- 	record.lv = buff:popChar()
			-- 	--log("test 3")
			-- 	record.sex = buff:popChar()
			-- 	--log("test 4")
			-- 	record.school = buff:popChar()
			-- 	--log("test 5")
			-- 	record.fight = buff:popInt()
			-- 	--log("test 8")
			-- 	record.online = false

			-- 	table.insert(blackData, #blackData+1, record)
			-- end
			for i,v in ipairs(t.roleData) do
				local record = {}
				record.roleId = v.roleSid
				record.name = v.name
				record.lv = v.level
				record.sex = v.sex
				record.school = v.school
				record.fight = v.fightAbility
				record.online = v.isOnLine
				table.insert(blackData, #blackData+1, record)
			end
			dump(blackData)

			local function addFunc(blackData, name)
				local isInList = false
				for i,v in ipairs(blackData) do
					if name == v.name then
						isInList = true
						break
					end
				end

				if isInList then
					local function yesFunc()
						--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_ADDRELATION,"iccS",G_ROLE_MAIN.obj_id,1,1,name)
						local t = {}
						t.relationKind = 1
						t.targetName = {name}
						g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_ADDRELATION, "AddRelationProtocol", t)
						startTimerAction(G_MAINSCENE, 1, false, function() UpdateBlack() end)
					end
					MessageBoxYesNoEx(nil,game.getStrByKey("social_tip_for_add_friend"),yesFunc,nil,nil,nil,true)
				else
					log("1 name = "..name)
					--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_ADDRELATION,"iccS",G_ROLE_MAIN.obj_id,1,1,name)
					local t = {}
					t.relationKind = 1
					t.targetName = {name}
					g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_ADDRELATION, "AddRelationProtocol", t)
					startTimerAction(G_MAINSCENE, 1, false, function() UpdateBlack() end)
				end
			end

			if name_str then
				addFunc(blackData, name_str)
			end

			if name_tab then
				for k,v in pairs(name_tab) do
					dump(v)
					addFunc(blackData, v.name)
				end
			end
		end
	end)
	--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_GETRELATIONDATA, "ic", G_ROLE_MAIN.obj_id, 3)
	g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 3})
end

--加好友检查本地黑名单
function AddFriendsEx(name_str)
	--log("AddFriends = "..name_str)
	if G_ROLE_MAIN and G_ROLE_MAIN:getTheName() == name_str then
		TIPS({str = game.getStrByKey("charm_addFriendToSelf"), type = 1})
		return
	end

	local function addFunc(blackData, name)
		local isInList = false
		for i,v in ipairs(G_BLACK_INFO) do
			if name == v.name then
				isInList = true
				break
			end
		end

		if isInList then
			local function yesFunc()
				--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_ADDRELATION,"iccS",G_ROLE_MAIN.obj_id,1,1,name)
				local t = {}
				t.relationKind = 1
				t.targetName = {name}
				g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_ADDRELATION, "AddRelationProtocol", t)
				--startTimerAction(G_MAINSCENE, 1, false, function() UpdateBlack() end)
				startTimerAction(G_MAINSCENE, 0.3, false, function() 
					g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 1})
					g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 3})
				end)
			end
			MessageBoxYesNoEx(nil,game.getStrByKey("social_tip_for_add_friend"),yesFunc,nil,nil,nil,true)
		else
			log("1 name = "..name)
			--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_ADDRELATION,"iccS",G_ROLE_MAIN.obj_id,1,1,name)
			local t = {}
			t.relationKind = 1
			t.targetName = {name}
			g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_ADDRELATION, "AddRelationProtocol", t)
			--startTimerAction(G_MAINSCENE, 1, false, function() UpdateBlack() end)
		end
	end

	if name_str then
		addFunc(blackData, name_str)
	end
end

--加黑名单
function AddBlackList(name_str)
	if G_ROLE_MAIN and G_ROLE_MAIN:getTheName() == name_str then
		TIPS({str = game.getStrByKey("charm_addBlackToSelf"), type = 1})
		return
	end	
	g_msgHandlerInst:registerMsgHandler(RELATION_SC_GETRELATIONDATA_RET , function(buff)
		log("get RELATION_SC_GETRELATIONDATA_RET")
		local t = g_msgHandlerInst:convertBufferToTable("GetRelationDataRetProtocol", buff)
		local relationType = t.relationKind
		log("relationType = "..relationType)
		dump(relationType)
		if relationType == 1 then
			local friendData = {}
			-- local leftYuanBaoFlowerTime = buff:popChar()
			-- local leftJinBiFlowerTime = buff:popInt()
			-- local onlineNum = buff:popChar()
			-- for i=1,onlineNum do
			-- 	local record = {}
			-- 	record.roleId = buff:popInt()
			-- 	record.name = buff:popString()
			-- 	record.lv = buff:popChar()
			-- 	record.sex = buff:popChar()
			-- 	record.school = buff:popChar()
			-- 	record.fight = buff:popInt()
			-- 	record.flowerGetFromMe = buff:popInt()
			-- 	record.flowerSendToMe = buff:popInt()
			-- 	record.online = true

			-- 	table.insert(friendData, #friendData+1, record)
			-- end
			-- local offLineNum = buff:popChar()
			-- for i=1,offLineNum do
			-- 	local record = {}
			-- 	record.roleId = buff:popInt()
			-- 	record.name = buff:popString()
			-- 	record.lv = buff:popChar()
			-- 	record.sex = buff:popChar()
			-- 	record.school = buff:popChar()
			-- 	record.fight = buff:popInt()
			-- 	record.flowerGetFromMe = buff:popInt()
			-- 	record.flowerSendToMe = buff:popInt()
			-- 	record.online = false

			-- 	table.insert(friendData, #friendData+1, record)
			-- end
			for i,v in ipairs(t.roleData) do
				local record = {}
				record.roleId = v.roleSid
				record.name = v.name
				record.lv = v.level
				record.sex = v.sex
				record.school = v.school
				record.fight = v.fightAbility
				record.online = v.isOnLine
				table.insert(friendData, #friendData+1, record)
			end
			dump(friendData)

			local isInList = false
			for i,v in ipairs(friendData) do
				if name_str == v.name then
					isInList = true
					break
				end
			end

			if isInList then
				local function yesFunc()
					--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_ADDRELATION,"iccS",G_ROLE_MAIN.obj_id,3,1,name_str)
					local t = {}
					t.relationKind = 3
					t.targetName = {name_str}
					g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_ADDRELATION, "AddRelationProtocol", t)
					startTimerAction(G_MAINSCENE, 1, false, function() UpdateBlack() end)
				end
				MessageBoxYesNoEx(nil,game.getStrByKey("social_tip_for_add_black"),yesFunc,nil,nil,nil,true)
			else
				--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_ADDRELATION,"iccS",G_ROLE_MAIN.obj_id,3,1,name_str)
				local t = {}
				t.relationKind = 3
				t.targetName = {name_str}
				g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_ADDRELATION, "AddRelationProtocol", t)
				startTimerAction(G_MAINSCENE, 1, false, function() UpdateBlack() end)
			end
		end
	end)
	--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_GETRELATIONDATA, "ic", G_ROLE_MAIN.obj_id, 1)
	g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 1})
end

--邀请组队
function InviteTeamUp(name_str)
   	-- g_msgHandlerInst:sendNetDataByFmtExEx(TEAM_CS_INVITE_TEAM,"iSbi",userInfo.currRoleId,name_str,false,0)
   	g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_INVITE_TEAM, "InviteTeamProtocol", {["tName"] = name_str,["isApply"] = false,["iTeamID"] = 0})
end

--查看资料
function LookupInfo(name_str,sub_index, notTips)		
	local root = require("src/layers/beautyWoman/RoleAndBeautyLayer").new({ role = name_str, noTips = notTips or 1},sub_index)
	getRunScene():addChild(root, 200, 2000)
	-- root:setAnchorPoint(cc.p(0.5, 0.5))
	-- root:setPosition(g_scrCenter)
	-- Manimation:transit(
	-- {
	-- 	node = root,
	-- 	sp = g_scrCenter,
	-- 	--trend = "-",
	-- 	curve = "-",
	-- 	zOrder = 200,
	-- 	swallow = true,
	-- })
end

--查看摊位
function LookupBooth(name_str)
   	TIPS( { type = 1 , str = "^c(yellow)功能未开启^" }  )
end

-- 仓库开启状态信息
function bankOpenStatus()
	return true
end

--私聊
function PrivateChat(name_str)
	--g_msgHandlerInst:sendNetDataByFmtExEx(CHAT_CS_GETSTRANGERMSG,"iS",userInfo.currRoleStaticId,name_str)
	local t = {}
	t.targetName = name_str
	g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_GETSTRANGERMSG, "GetStrangerMsgProtocol", t)

	g_msgHandlerInst:registerMsgHandler(CHAT_SC_SENDSTRANGERMSG , function(buff)
		
		local t = g_msgHandlerInst:convertBufferToTable("SendStrangerMsgProtocol", buff)
		local roleData = {}
		roleData.online = t.online
		roleData.roleId = t.targetRoleSID
        roleData.name = t.targetName
        roleData.sex = t.targetSex
        roleData.school = t.targetSchool
        roleData.lv = t.targetLevel
        roleData.vip = t.targetVip
        roleData.fight = t.targetBattle

		if roleData then
			--TIPS( { type = 1 , str = "^c(yellow)功能未开启^" }  )
		   	local chatLayer = getRunScene():getChildByTag(305)
            if not chatLayer then
			   	chatLayer = require("src/layers/chat/Chat").new(0, roleData)
			   	G_MAINSCENE.chatLayer = chatLayer
		   		G_MAINSCENE.base_node:addChild(chatLayer)
		   		chatLayer:setLocalZOrder(200)
		   		chatLayer:setTag(305)
		   		chatLayer:setAnchorPoint(cc.p(0, 0))
		   		chatLayer:setPosition(cc.p(0, 0))
                chatLayer:selectTab(0, roleData)
			  --  		Manimation:transit(
					-- {
					-- 	ref = getRunScene(),
					-- 	node = chatLayer,
					-- 	curve = "-",
					-- 	sp = cc.p(g_scrSize.width/2-160,150),
					-- 	zOrder = 200,
					-- 	tag = 305,
					-- 	swallow = false,
					-- })
			else
				chatLayer:show()
				chatLayer:selectTab(0, roleData)
			end
		end
	end)
end

--传送
function GotoNearPos(name_str,isfriend)
	--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_GOTO_POS,"iSc",G_ROLE_MAIN.obj_id,name_str,isfriend or 1)
	local t = {}
	t.targetName = name_str
	t.relationType = isfriend or 1
	g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GOTO_POS, "GotoPosProtocol", t)
end

-- 交易
function TradeWithRole(role_node)
	local secondaryPass = require("src/layers/setting/SecondaryPassword")
	if not secondaryPass.isSecPassChecked() then
		secondaryPass.inputPassword()
		return
	end

	local MtradeOp = require "src/layers/trade/tradeOp"
	MtradeOp:reqTrade(role_node:getTag())
end

--送花
function SendFlower(roleName, callback)
	if G_CONTROL:isFuncOn( GAME_SWITCH_ID_FLOWER ) == false then
		return
	end

	--g_msgHandlerInst:sendNetDataByFmtExEx(CHAT_CS_GETSTRANGERMSG,"iS",userInfo.currRoleStaticId,roleName)
	local t = {}
	t.targetName = roleName
	dump(t)
	g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_GETSTRANGERMSG, "GetStrangerMsgProtocol", t)

	g_msgHandlerInst:registerMsgHandler(CHAT_SC_SENDSTRANGERMSG , function(buff)
	        local t = g_msgHandlerInst:convertBufferToTable("SendStrangerMsgProtocol", buff)
			local roleData = {}
			roleData.online = t.online
			roleData.roleId = t.targetRoleSID
	        roleData.name = t.targetName
	        roleData.sex = t.targetSex
	        roleData.school = t.targetSchool
	        roleData.lv = t.targetLevel
	        roleData.vip = t.targetVip
	        roleData.fight = t.targetBattle

        	if roleName and roleData.roleId then
        		local layer = require("src/layers/friend/SendFlowerLayer").new({[1]=roleData.roleId, [2]=roleName}, callback)
				Manimation:transit(
				{
					ref = getRunScene(),
					node = layer,
					sp = g_scrCenter,
					ep = g_scrCenter,
					zOrder = 200,
					curve = "-",
					swallow = true,
				})
        	end
    	end
	)
end

--拜师
function AskForMaster(name_str)
	--g_msgHandlerInst:sendNetDataByFmtExEx(APPRENTICE_CS_REQ, "iS", G_ROLE_MAIN.obj_id, name_str)
	local t = {}
	t.name = name_str
	g_msgHandlerInst:sendNetDataByTableExEx(APPRENTICE_CS_REQ, "ApprenticeReq", t)

	TIPS({type =1 ,str = game.getStrByKey("master_wait_student")})
end

--收徒
function AskForStudent(name_str)
	--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_REQ, "iS", G_ROLE_MAIN.obj_id, name_str)
	local t = {}
	t.name = name_str
	g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_REQ, "MasterReq", t)

	TIPS({type =1 ,str = game.getStrByKey("master_wait_master")})
end

function autoFindWayToSpecialNpc(mapId,npcX,npcY,npcID)
    local handlerFun = function()                                          
        require("src/layers/mission/MissionNetMsg"):sendClickNPC(npcID)
    end

    local tempData = { targetType = 4 , mapID =  mapId ,  x = npcX  , y = npcY, callFun = handlerFun }
    if __TASK then __TASK:findPath( tempData ) end
end

function useShoseToSpecialNpc(mapId,npcX,npcY,npcId)
    local shoewNeedData = { 
            targetData = { 
                    mapID = mapId , 
                    pos = { 
                    { 
                        x = npcX , 
                        y = npcY 
                    } 
                    } 
            } ,  
        noTipShop = ( false ) ,
        q_done_event = ( "0" ) ,
        oldData = ( nil )
        }
    __removeAllLayers(true,function () require("src/layers/mission/MissionNetMsg"):sendClickNPC(npcId) end )
    require("src/base/BaseMapScene").auto_mine = nil
    if not __TASK:portalGo( shoewNeedData , ( false ) , ( false ),true ) then
        DATA_Mission.isStopFind = true
    end
end

--前往某人坐标
function GotoRolePos(staticId)
	g_msgHandlerInst:registerMsgHandler(MASTER_SC_GET_POSITION_RET , function(buff)
		log("get MASTER_SC_GET_POSITION_RET")
		local t = g_msgHandlerInst:convertBufferToTable("MasterGetPositionRet", buff) 
		local mapId = t.mapID
		local x = t.x
		local y = t.y
		if mapId > 0 and x >= 0 and y >= 0 then
			local detailMapNode = require("src/layers/map/DetailMapNode")
      		detailMapNode:goToMapPos(mapId, cc.p(x, y), false)
		else
			TIPS({type =1 ,str = game.getStrByKey("master_pos_error")})
		end
	end)
	--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_GET_POSITION, "ii", G_ROLE_MAIN.obj_id, staticId)
	local t = {}
	t.roleSID = staticId
	g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_GET_POSITION, "MasterGetPosition", t)
end

--叛逃师门
function BetrayMaster(staticId)
	g_msgHandlerInst:registerMsgHandler(MASTER_SC_OFFLINE_PUNISH_RET , function(buff)
		local t = g_msgHandlerInst:convertBufferToTable("MasterOfflinePunishRet", buff)
		local isPunish = t.punish
		if isPunish then
			local function yesFunc()
				--g_msgHandlerInst:sendNetDataByFmtExEx(APPRENTICE_CS_BETRAY, "ii", G_ROLE_MAIN.obj_id, staticId)
				local t = {}
				t.roleSID = staticId
				g_msgHandlerInst:sendNetDataByTableExEx(APPRENTICE_CS_BETRAY, "ApprenticeBetray", t)
				removeFromParent(self.operateLayer)
				removeFromParent(self.mainLayer)
			end
			MessageBoxYesNo(nil,game.getStrByKey("master_delete_master_tip_1"),yesFunc)
		else
			local function yesFunc()
				--g_msgHandlerInst:sendNetDataByFmtExEx(APPRENTICE_CS_BETRAY, "ii", G_ROLE_MAIN.obj_id, staticId)
				local t = {}
				t.roleSID = staticId
				g_msgHandlerInst:sendNetDataByTableExEx(APPRENTICE_CS_BETRAY, "ApprenticeBetray", t)
				removeFromParent(self.operateLayer)
				removeFromParent(self.mainLayer)
			end
			MessageBoxYesNo(nil,game.getStrByKey("master_delete_master_tip_2"),yesFunc)
		end
	end)

	--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_OFFLINE_PUNISH, "i", G_ROLE_MAIN.obj_id)
	local t = {}
	g_msgHandlerInst:sendNetDataByTableExEx(MASTER_CS_OFFLINE_PUNISH, "MasterOfflinePunish", t)
end

--出师
function BeMaster()
	--g_msgHandlerInst:sendNetDataByFmtExEx(APPRENTICE_CS_FINISH, "i", G_ROLE_MAIN.obj_id)
	local t = {}
	g_msgHandlerInst:sendNetDataByTableExEx(APPRENTICE_CS_FINISH, "ApprenticeFinish", t)
end

-- state: 0 下坐骑 1 上坐骑
function RidingSwitch(state)
	if G_CONTROL:isFuncOn( GAME_SWITCH_ID_RIDE ) == false then return end
	if G_RIDING_INFO.id[1] and G_ROLE_MAIN:getCurrActionState() ~= ACTION_STATE_EXCAVATE then
		--g_msgHandlerInst:sendNetDataByFmtExEx(RIDE_CS_CHANG_STATE, "ici", G_ROLE_MAIN.obj_id, state, G_RIDING_INFO.id[1])
		local t = {}
		t.opType = state
		t.rideID = G_RIDING_INFO.id[1]
		g_msgHandlerInst:sendNetDataByTableExEx(RIDE_CS_CHANG_STATE, "RideChangeStateProtocol", t)
	end
end

function createRoleNode(school,cl_id,weapon_id,wing_id,scale,sex,touchCallBack)
	local MpropOp = require "src/config/propOp"
	local roleSprite = require("src/base/RoleSprite")
	local path = ""
	local school = school or 1
	local sex = sex < 3 and sex or 1 
	local scale = scale or 1
	local w_resId = MpropOp.equipResId(cl_id)
	if w_resId == 0 then w_resId = g_normal_close_id end
	local wing,weapon = nil, nil
	local role_node = cc.Node:create()
	local clo = createSprite(role_node,"res/showplist/role/"..w_resId.."/"..sex..".png",cc.p(30,30))
	local createEffect = function(effect_str,pos,tag,times,mode)
	-----------------------------------------------------------------------
		local futil = cc.FileUtils:getInstance()
		local bCurFilePopupNotify = false
		if isWindows() then
			bCurFilePopupNotify = futil:isPopupNotify()
			futil:setPopupNotify(false)
		end
		local c_effect = nil
		if futil:isFileExist("res/effectsplist/"..effect_str .. "@0.plist") then
			c_effect =  Effects:create(false)
			c_effect:setPosition(pos)
		    role_node:addChild(c_effect,1,tag)
		    c_effect:playActionData2(effect_str,times,-1,0)
		    addEffectWithMode(c_effect,mode or 2)
		end

		if isWindows() then
			futil:setPopupNotify(bCurFilePopupNotify)
		end
		return c_effect
-----------------------------------------------------------------------
	end
	if clo then
		clo:setTag(PLAYER_EQUIP_UPPERBODY)
		-- if sex == 2 then
		-- 	clo:setPosition(cc.p(0,5))
		-- end
		-- local close_effect_tab = {[5010508]=true}
		-- if close_effect_tab[w_resId] then
		-- 	local effect_str = "myifu_"..w_resId
		-- 	if sex == 2 then
		-- 		effect_str = "fyifu_"..w_resId
		-- 	end
		-- 	local close_effect =  Effects:create(false)
	 --        role_node:addChild(close_effect,1,1234)
	 --        close_effect:playActionData2(effect_str,180,1,0)
	 --        addEffectWithMode(close_effect,2)
	 --    end
	 	local effect_str = "myifu_"..w_resId
		if sex == 2 then
			effect_str = "fyifu_"..w_resId
		end
		createEffect(effect_str,cc.p(1,-7),1234,180)
	end
	if role_node then
		local r_size = role_node:getContentSize()
		--[[
		local pifeng = createSprite(role_node,"res/showplist/role/"..w_resId.."/"..(sex+2)..".png",cc.p(r_size.width/2,r_size.height/2))
		if pifeng then 
			pifeng:setColor(MColor.red)
			pifeng:setTag(1)
		end
		]]
		if wing_id and wing_id > 0 then
			local w_resId = getConfigItemByKey("WingCfg","q_ID",wing_id,"q_senceSouceID") or 1
			local wing_posx = 20
			--if sex == 2 then wing_posx = 0 end
			wing = createSprite(role_node,"res/showplist/wing/"..(w_resId%10)..".png",cc.p(wing_posx,50))
			if wing then 
				wing:setTag(PLAYER_EQUIP_WING)
				wing:setLocalZOrder(-1) 
			end	
		end
		if weapon_id and weapon_id > 0 then
			local w_resId = MpropOp.equipResId(weapon_id)	
			weapon = createSprite(role_node,"res/showplist/weapon/"..w_resId..".png",cc.p(-70,50))
			if weapon then weapon:setTag(PLAYER_EQUIP_WEAPON) end
			createEffect("wuqi_"..w_resId,cc.p(-70,50),1235,180,1)
		end
		-- local headimg = 3
		-- local head_pos = cc.p(r_size.width/2+21.5,r_size.height/2-1)
		-- if sex == 2 then 
		-- 	headimg = 6
		-- 	if school == 1 then 
		-- 		headimg = 4
		-- 		head_pos = cc.p(r_size.width/2+18,r_size.height/2)
		-- 	end
		-- end
		--local head = createSprite(role_node,"res/showplist/head/"..headimg..".png",head_pos)
		--local color_map = {cc.c3b(150, 117, 59),cc.c3b(20, 55, 107),cc.c3b(104, 67, 86)}
		--if head then head:setColor(color_map[school]) end
		role_node:setScale(scale)
		
		if touchCallBack then
			local listenner = cc.EventListenerTouchOneByOne:create()
			listenner:setSwallowTouches(true)
		    listenner:registerScriptHandler(function(touch,event)
		    	local pt = role_node:convertTouchToNodeSpace(touch)
		    	local box = cc.rect(-60 * scale, -40 * scale, 120 * scale, 160 * scale)
		    	if cc.rectContainsPoint(box, pt) then
		    		return true
		    	end
		        return false
		    end,cc.Handler.EVENT_TOUCH_BEGAN)
		    listenner:registerScriptHandler(function(touch,event)
		    	touchCallBack()
		    end,cc.Handler.EVENT_TOUCH_ENDED)
		    local eventDispatcher = role_node:getEventDispatcher()
		    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, role_node	)	    
		end
	end
	return role_node,wing,weapon
end

function createSceneRoleNode(params)
	local MpropOp = require "src/config/propOp"
	local w_resId = MpropOp.equipResId(params[PLAYER_EQUIP_UPPERBODY])
    if w_resId <= 0 then w_resId = g_normal_close_id end
	local role_node = require("src/base/RoleSprite").new("role/" .. w_resId+params[PLAYER_SEX]*100000,0,params)
	role_node:setEquipments(params[PLAYER_EQUIP_UPPERBODY],params[PLAYER_EQUIP_WEAPON],params[PLAYER_EQUIP_WING]) 
	role_node:setSpeed(0.3)
	return role_node
end



-- --加载抢到的元宝红包记录
-- local maxRedInfoNum = 40
-- function LoadRecvRedBagInfo()
-- 	--try()
-- 	--print("LoadRecvRedBagInfo...................................................................................")
-- 	local userID = tostring(userInfo.currRoleStaticId)
-- 	--print("userID", userID)
-- 	if not G_DIR_REDBAG_RECV then G_DIR_REDBAG_RECV = {} end
-- 	local key = "G_RB_" .. userID .. "_"
-- 	for i = 1, maxRedInfoNum do
-- 		local str= getLocalRecordByKey(2,key .. i)
-- 		if str ~= "" then 
-- 			print(str)
-- 			local tgStr = stringsplit(str, "_")
-- 			G_DIR_REDBAG_RECV[i] = {}
-- 			G_DIR_REDBAG_RECV[i].time = tonumber(tgStr[1] or "0")
-- 			G_DIR_REDBAG_RECV[i].num = tonumber(tgStr[2] or "0")
-- 			G_DIR_REDBAG_RECV[i].name = tgStr[3] or ""
-- 		else
-- 			break
-- 		end
-- 	end
-- 	--dump(G_DIR_REDBAG_RECV)
-- end

-- --更新抢到的元宝红包记录
-- function RefRecvRedBagInfo(params)
-- 	local num = #G_DIR_REDBAG_RECV
-- 	if num ~= 0 then
-- 		for i = 1 , num do -- 1 ... 40
-- 			local curIndex = num - i + 2 --2 .. 41
-- 			if  curIndex > maxRedInfoNum then 
-- 				G_DIR_REDBAG_RECV[curIndex] = nil 
-- 			else
-- 				if not G_DIR_REDBAG_RECV[curIndex] then G_DIR_REDBAG_RECV[curIndex] = {} end
-- 				G_DIR_REDBAG_RECV[curIndex ].time = G_DIR_REDBAG_RECV[curIndex - 1].time
-- 				G_DIR_REDBAG_RECV[curIndex ].num = G_DIR_REDBAG_RECV[curIndex - 1].num
-- 				G_DIR_REDBAG_RECV[curIndex ].name = G_DIR_REDBAG_RECV[curIndex - 1].name
-- 			end
-- 		end
-- 	end

-- 	if not G_DIR_REDBAG_RECV[1] then G_DIR_REDBAG_RECV[1] = {}  end
-- 	G_DIR_REDBAG_RECV[1].time = params.time
-- 	G_DIR_REDBAG_RECV[1].num = params.num
-- 	G_DIR_REDBAG_RECV[1].name = params.name
	
-- 	local userID = tostring(userInfo.currRoleStaticId)
-- 	if not G_DIR_REDBAG_RECV then G_DIR_REDBAG_RECV = {} end
-- 	local key = "G_RB_" .. userID .. "_"
-- 	for k,v in pairs(G_DIR_REDBAG_RECV) do
-- 		if k > maxRedInfoNum then break end
-- 		setLocalRecordByKey(2,key .. k, "" .. v.time .. "_" .. v.num .. "_" .. v.name)
-- 	end
-- 	if g_EventHandler["DirRedBagFlash"] then g_EventHandler["DirRedBagFlash"]() end
-- end

local __textAry__ = {}
function clearTextAry()
	for k,v in pairs(__textAry__)do
		for h,t in pairs(v)do
			local target = tolua.cast(t,"cc.Node")
			if target then		
				removeFromParent(target)
				target = nil
			end		
		end
	end
	__textAry__ = {}
end

function ShowEffectFont(parent, pos, effectFileName, zOrder)
    local sprite_text_success = cc.Sprite:create("res/common/effectFont/" .. effectFileName)
    sprite_text_success:setAnchorPoint(.5, .5)
    sprite_text_success:setPosition(pos)
    sprite_text_success:runAction(cc.Sequence:create(
        cc.DelayTime:create(1.25)
        , cc.FadeOut:create(1)
        , cc.RemoveSelf:create()
    ))
    parent:addChild(sprite_text_success, zOrder and zOrder or 0)
    local animateSpr = Effects:create(false)
    animateSpr:setAnchorPoint(.5, .5)
    animateSpr:setPosition(pos)
    animateSpr:playActionData("operationsuccess", 11, 1.9, 1)--todo: 增加失败背景特效
    animateSpr:runAction(cc.Sequence:create(
        cc.DelayTime:create(1.9)
        , cc.RemoveSelf:create()
    ))
    addEffectWithMode(animateSpr, 1)
    parent:addChild(animateSpr, zOrder and zOrder or 0)
    return sprite_text_success, animateSpr
end

function TIPS( params )
	if not params then return false end		--没有参数直接返回

	if not params.isMustShow then --登陆前是否强制显示TIPS信息
		if __TASK == nil then return end 		--任务为空则不在游戏场景中
	end
	
	if ( G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.isStory == true ) then   --剧情不展示提示信息
		if G_MAINSCENE.storyNode and not G_MAINSCENE.storyNode:isCanShowTips() then
            return false
        end
	end

	-- params = { type = [ "1.常规提示：提示操作成功或操作失败" , "2.收获提示：用于提示各种收益" , "3.任务提示：用于提示任务进度" , "4.跑马灯提示：用于广播大事件" , 5.滚动字幕 ] , str = "" } 
	local tipStr = params.str or params.msg or "" 
	local flag = params.flag or nil				--是否有标记
	local index = params.type or ( params.tswz and params.tswz or 1 ) 
	if (not G_MAINSCENE) and (index == 2 or index == 3) then return false end		--直接返回
	local effTime = 0.5 						--动画执行时间
	__textAry__[index] = __textAry__[index]  or {}

	-- if index == 1 then
	-- 	if __G_cacheTip__ then
	-- 		if params.passCache == nil then
	-- 			params.passCache = true
	-- 			table.insert( __G_cacheTip__ , params )
	-- 			return
	-- 		end
	-- 	else
	-- 		__G_cacheTip__ = {}
	-- 	end
	-- end

	local clearItem  = function( target )
		if target and tolua.cast(target,"cc.Node") then		
			removeFromParent(target)
			target = nil
		end
	end
	local removeSelf = cc.RemoveSelf:create()
	local overCallbackFun  = function( clear) 
		if __textAry__[index] and #__textAry__[index] > 0 then
			local target = table.remove( __textAry__[index] , 1 ) 
			if target then
				if index == 1 then
					-- if __G_cacheTip__ then
					-- 	if #__G_cacheTip__ == 0 then
					-- 		__G_cacheTip__ = nil							
					-- 	else
					-- 		TIPS( table.remove( __G_cacheTip__ , 1 ) )
					-- 	end
					-- end
					if clear then clearItem( target ) end
				elseif index == 4 then
					target:runAction( cc.Sequence:create( cc.ScaleTo:create( 0.2 , 1 , 0 ) , removeSelf ) )
				else
					if clear then clearItem( target ) end
				end
			end
		end
	end	--动画执行完回调
	
	local numOrId = params.numOrId or nil			--以原型ID来查找配置信息并展示
	if numOrId then    
		
		local objs = require("src/config/propOp")

		local getColorName = function( _id )
    		local color = objs.nameColor( _id )
	    	local qualityValue = color.r + color.g + color.b
	    	local qualityColor = "white"
	    	for key , v in pairs( MColor ) do
				if type(v) == "table" and ( v.r + v.g + v.b ) ==  qualityValue then qualityColor = key break end
	    	end
	    	return qualityColor
		end

		local propInfo = ""
	    for i=1,#numOrId do
	        propInfo = propInfo .. "^c(" .. getColorName( numOrId[i] )  .. ")" .. objs.name(numOrId[i]) .. "^"
	    end
	    if params.objNum then
	    	tipStr = tipStr .. propInfo .. " X" ..tostring(params.objNum)
	    else
	    	tipStr = tipStr .. propInfo
	    end
	end
	
	local showNum = __textAry__[index] and #__textAry__[index] or 1
	showNum = showNum == 0 and 1 or showNum
	local overConfig = { 
							{ x = display.cx , y = display.height*0.75 , interval = 0 } , 
							{ x = 330 , y = display.height*0.234 - 30 , interval = 25 } ,  
							{ x = display.cx , y = display.height - 32 , interval = 40 } ,  
							{ x = 0 , y = 0 , interval = 0  } ,  
							{ x = 0 , y = 0 , interval = 0  } ,  
						}
	local function getTargetValue( idx )
		return cc.p( overConfig[ index ].x , overConfig[ index ].y - ( idx or ( __textAry__[index]  and #__textAry__[ index ] or 1 ) ) * overConfig[ index ].interval ) 
	end

	local config = { 
						{ 
							bg  = "res/chat/infoBg1.png" , initPoint = cc.p( display.cx , 450 )  ,
							-- beginAction = cc.Sequence:create( { cc.MoveTo:create( effTime , getTargetValue() ) , cc.DelayTime:create( effTime * showNum + 1.5 ) , cc.CallFunc:create( overCallbackFun ) } )  ,
							beginAction = cc.Sequence:create( { cc.Spawn:create( cc.EaseBackOut:create( cc.ScaleTo:create( 0.3  , 1 ) ) , cc.MoveTo:create( 0.1 , cc.p( display.cx , 480 ) )  ) , cc.DelayTime:create( 2 - ( params.passCache and 1 or 0 ) ) ,removeSelf, cc.CallFunc:create( overCallbackFun ) }),
						} ,
						{ 
							initPoint = cc.p( 330 , 50 )  , 
							-- beginAction = cc.Sequence:create( { cc.MoveTo:create( 0.5 , getTargetValue() ) , cc.DelayTime:create( 1.5 ) , cc.CallFunc:create( function() overCallbackFun() end ) } )  ,
							beginAction = cc.Sequence:create( {cc.Spawn:create( { cc.EaseBackOut:create( cc.ScaleTo:create( effTime  , 1 ) )  , cc.MoveTo:create( effTime , getTargetValue() )  } ) , cc.DelayTime:create( effTime * (showNum + 1) ) ,removeSelf, cc.CallFunc:create( overCallbackFun ) } )  ,
						} ,	
						{ 
							bg  = "res/common/task_msg_bg.png" , initPoint = cc.p( display.cx , display.height - 130 )  , flag = "res/layers/task/task_msg_flag.png" ,
							beginAction = cc.Sequence:create( { cc.MoveTo:create( effTime , getTargetValue() ) , cc.DelayTime:create( effTime * showNum + 1.5 ) ,removeSelf, cc.CallFunc:create( overCallbackFun ) } )  ,
						} ,	
						{ 
							bg  = ( params.isRedBag and "res/common/55.png" or "res/common/notice_msg_bg.png" ), initPoint = cc.p( display.cx , display.height - 111 )  , initScale = { y = 0 } ,
							beginAction = cc.Sequence:create( { cc.EaseBackOut:create( cc.ScaleTo:create( effTime  , 1 ) ) , cc.DelayTime:create( effTime * 10  + 3 ) ,removeSelf, cc.CallFunc:create( overCallbackFun ) } )  ,
						} ,
						{ 
							bg  = "res/common/notice_msg_bg1.png" , initPoint = cc.p( display.cx , display.height - 160 )  , initScale = { y = 0 } ,
							-- beginAction = cc.Sequence:create( { cc.EaseBackOut:create( cc.ScaleTo:create( effTime  , 1 ) ) , cc.DelayTime:create( effTime * 10 ) , cc.CallFunc:create( function() overCallbackFun() end ) } )  ,
							beginAction = nil  ,
						} ,
					}

	local numCfg = { 1 , 5 , 2 , 1 , 1 }
	local totalNum = numCfg[index] 			--可同时存在的个数
	if params.totalNumSet then
		totalNum = params.totalNumSet
	end
	
	local data = config[ index ]
	local function createLayout()
		local fontSize = { 20 , 20 , 20 , 25 , 23 }    --显示文字大小

		local function showStyle1()
			--飘出消息
			local node = cc.Node:create()
			setNodeAttr( node , data.initPoint , cc.p( 0 , 0 ) )	
			local richText = require("src/RichText").new( node , cc.p( 0 , 0 ) , cc.size(800 , 25 ) , cc.p( 0.5 , 0.5 ) , 22 , fontSize[index] , MColor.white )
			richText:setAutoWidth()
			richText:addText( tipStr , MColor.lable_yellow , false )
			richText:format()
			local text_size = richText:getContentSize()

			--node:setContentSize( text_size )
			local bg = createSprite( node , data.bg , cc.p( 0 , 0 ) , cc.p( 0.5 , 0.5 ) ) 
			bg:setLocalZOrder(-1)
			local bgSize = bg:getContentSize()  
			if bgSize.width -80 < text_size.width then 
				bg:setScale((text_size.width+80)/bgSize.width,1)
			end
			if flag then 
				richText:setPosition(cc.p(15,0))
				createSprite( node , "res/chat/" ..  ( flag == 0 and "flag2.png" or "flag1.png" ) , cc.p( -text_size.width/2 - 10 , 0 ) , cc.p( 0.5 , 0.5 ) ) 
				if flag ~= 0 then
					--bg:setTexture("res/chat/infoBg2.png")
				end
			end
			if tipStr == "" then
				error("tips str is empty !!!")
			end			
			node:setScale( 0.75 )
			return node
		end

		local function showStyle2()
			--获得经验
			local node = cc.Node:create()

			local width , height = 600,25--MColor( tipStr ) , 25 
			setNodeAttr( node , data.initPoint , cc.p( 0.5 , 0.5 ) )
			--local bg = createSprite( node ,"res/common/56.png" , cc.p( -55 , 13 ) , cc.p( 0.0 , 0.5 ) )
			--bg:setScaleY(0.5)
			--node:setContentSize( cc.size( width , height ) )
			local addRichText = function()
				local richText = require("src/RichText").new( node , cc.p( -50 , height/2  ), cc.size( width , height ), cc.p( 0.0 , 0.5 ), 21 , fontSize[index] , MColor.white )
				richText:addText( tipStr , MColor.white , false )
				richText:setFont(nil,nil,1,cc.c3b(128,128,128))
				richText:format()
			end
			addRichText()
			--performWithDelay(node,addRichText,0.1)
			--node:setScale( 0 )
			return node
		end
		local function showStyle3()
			--击杀怪物
			local node = cc.Node:create()		 
			setNodeAttr( node , data.initPoint , cc.p( 0 , 0 ) )
			local bg = createSprite( node , data.bg , cc.p( 0 , 0 ) , cc.p( 0.5 , 0.5 ) )
			local addRichText = function()
				local richText = require("src/RichText").new( node , cc.p(  0  , 0 ) , cc.size( 430 , 0 ) , cc.p( 0.5 , 0.5 ) , 22 , fontSize[index] , MColor.white )
				richText:setAutoWidth()
				richText:addText( tipStr , MColor.lable_yellow ,false)
				richText:format()
			end
			addRichText()
			--performWithDelay(bg,addRichText,0.1)
			return node
		end
		local function showStyle4()
			AudioEnginer.playEffect("sounds/uiMusic/ui_message.mp3",false)


			--系统公告
			local node = cc.Node:create()
			local bg ,bgSize , richText = nil  , nil , nil
			local width , height = 680 , 25 

			bg = createSprite( node , data.bg , cc.p( 0 , 0 ) , cc.p( 0.5 , 0.5 ) ) 
			bgSize = bg:getContentSize()  
			setNodeAttr( node , data.initPoint , cc.p( 0 , 0 ) )
			--node:setContentSize( bgSize )

			if params.isFlower then
			    local effect = Effects:create(false)
			    effect:playActionData( "giveFlower" ,  11 , 1.5 , -1 )
			    bg:addChild( effect  )
				effect:setScale( 1.1 )
			    effect:setAnchorPoint(cc.p(0.5, 0.5))
			    effect:setPosition( cc.p( bgSize.width/2 , bgSize.height/2+7 ) )
			    addEffectWithMode(effect,1)
			end
			

			richText = require("src/RichText").new( node , cc.p( 0 , 0 ) , cc.size( width , height ) , cc.p( 0.5 , 0.5 ) , 27 , fontSize[index] , ( params.isRedBag and  MColor.green or MColor.red ) )
			richText:setAutoWidth()
			richText:addText( tipStr , MColor.yellow_gray , false )
			richText:format()

			bg:setScaleY( (richText:getContentSize().height+50)/ bgSize.height  )

			if  data.initScale  then
				if type( data.initScale ) == "table" then
					if data.initScale.x then
						node:setScaleX( data.initScale.x  )
					end
					if data.initScale.y then
						node:setScaleY( data.initScale.y  )
					end
				else
					node:setScale( data.initScale  )
				end
				node.text = richText
				richText:setVisible( false )
				setNodeAttr( richText , cc.p( 0 , 30 ) , cc.p( 0.5 , 0.5 ) )
				richText:runAction( cc.Sequence:create( { 
														cc.DelayTime:create( 0.3 ) , 
														cc.Show:create(),
														cc.EaseBackOut:create( cc.MoveTo:create( 0.2 , cc.p( 0 , 0 ) ) ) , 
													} ) )
			end

			if params.isRedBag then
				local function getFunc()
					g_msgHandlerInst:sendNetDataByTableExEx( PUSH_CS_RED_BAG , "PushGetRedBag" , {redBagID = params.isRedBag.bagID})
				end
				local getBtn = createTouchItem( bg , "res/component/button/9.png" , cc.p( richText:getContentSize().width + width/2 - 50 , bgSize.height/2 ) , function()  getFunc( ) end , true  )
				createLabel( getBtn , game.getStrByKey("for_red_bag")  , cc.p( getBtn:getContentSize().width/2 , getBtn:getContentSize().height/2 ) , cc.p( 0.5 , 0.5 ) , 23 , true , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
			end

			return node
		end
		local function showStyle5()
		    --数据整理
		    local function collectionStr()
			    if not DATA_Activity then return ""end
			    local data = DATA_Activity:getRollTipsData()
			    local keys = {}
			    local length = 0
			    for key , v  in pairs( data ) do
			        length = length + 1
			        if v.id then
			        	keys[ #keys + 1 ] = v.id
			        end
			    end

			    local overStr = ""
			    if length>1 then
			        table.sort( keys, function(a , b ) return a<b end )

			        local str = {}
			        for i = 1 , #keys do
			            local itemData = data[ keys[i] .. "" ]
			            if itemData and itemData[ "msg" ] and itemData["isShow"] == true then
			                data[ keys[i] .. "" ]["isShow"] = false
			                str[ #str + 1 ] = itemData[ "msg" ]
			            end
			        end
			        overStr = table.concat( str , "                  " )
			    elseif length == 1 then
			    	local itemData = data[ keys[1] .. "" ]
			    	if itemData and itemData[ "msg" ] and itemData["isShow"] == true then
				        data[ keys[1] .. "" ]["isShow"] = false
				        overStr = data[ keys[1] .. "" ][ "msg" ]
			    	end
			    end

			    return overStr , length
			end

  			local tipStr , length = collectionStr()

		    if tipStr == "" then return nil end


			--滚动系统公告
			local speed , space = 70 , 100

			local bg = createSprite( node , data.bg , cc.p( 0 , 0 ) , cc.p( 0.5 , 0.5 ) ) 
			
			local bgSize = bg:getContentSize()  
			setNodeAttr( bg , data.initPoint , cc.p( 0.5 , 0.5 ) )


			local scrollView = cc.ScrollView:create()
		    scrollView:setViewSize( cc.size( bgSize.width - 100 , fontSize[index] + 10 ) )
		    scrollView:setPosition( cc.p( 25 , 9 ) )
		    scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL )
		    scrollView:setTouchEnabled(false)
		    scrollView:setDelegate()
		    bg:addChild(scrollView)

		    -- local textSize = cc.size( 3000 , fontSize[index] + 10 )
		    local layer = cc.Node:create()
		    scrollView:setContainer( layer )
		    scrollView:updateInset()
		    setNodeAttr( layer , cc.p( bgSize.width , 0 ) , cc.p( 0 , 0 ) )
		    -- layer:setContentSize( textSize )

		    local oneLayer = cc.Node:create()
		    oneLayer.idx = 1
		    local twoLayer = cc.Node:create()
		    twoLayer.idx = 2
		    layer:addChild( oneLayer )
		    layer:addChild( twoLayer )

		    local textSize= nil
		    local createText = function()
		    	if oneLayer then oneLayer:removeAllChildren() end
		    	if twoLayer then twoLayer:removeAllChildren() end

			    local v = createLabel( nil , tipStr ,cc.p( 0 , 0 ) , cc.p(0 , 0 ) , fontSize[index] , nil , nil , nil , MColor.yellow_gray )
			    textSize = v:getContentSize()
			    local text1 = require("src/RichText").new( oneLayer , cc.p( 0 , 0 ) , cc.size( textSize.width + 20 , textSize.height )  , cc.p( 0 , 0 ) , fontSize[index] + 10 , fontSize[index] , MColor.yellow_gray )
			    setNodeAttr( oneLayer , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) ) 
			    text1:addText( tipStr , MColor.yellow_gray , false )
			    text1:format()	
			    	    
			    local text2 = require("src/RichText").new( twoLayer , cc.p( 0 , 0 ) , cc.size( textSize.width + 20 , textSize.height ) , cc.p( 0 , 0 ) , fontSize[index] + 10 , fontSize[index] , MColor.yellow_gray )
			    setNodeAttr( twoLayer , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) ) 
			    text2:addText(  tipStr , MColor.yellow_gray , false )
			    text2:format()
			end

			createText()
		    local actionFun = function() end
		    actionFun = function( targetLayer )

		      if targetLayer then targetLayer:stopAllActions() end
		      local function loopFun()
		      	tipStr , length = collectionStr()
		      	local isShow = false

			    if length ~= 0  and tipStr ~= "" then
		    		isShow = true
			    end

			    layer:setVisible( isShow )
			    bg:setVisible( isShow )

  				if tipStr == "" and length == 0 then
  					overCallbackFun(true)
				else
					-- text1:setString( tipStr )
					-- text2:setString( tipStr )
					-- textSize = text1:getContentSize()
				    local v = createLabel( nil , tipStr ,cc.p( 0 , 0 ) , cc.p(0 , 0 ) , fontSize[index] , nil , nil , nil , MColor.yellow_gray )
			    	textSize = v:getContentSize()
					createText()
					actionFun( targetLayer.idx == 1 and twoLayer or oneLayer )
				end
		      end

		      local time = math.abs( ( bgSize.width + textSize.width )/speed )

		      local actions = {}
  			  actions[#actions+1] = cc.Spawn:create(
				cc.MoveTo:create( time , cc.p( 0 - textSize.width - bgSize.width  , 0 ) ), 
				cc.Sequence:create( {cc.DelayTime:create( time ) , cc.CallFunc:create( loopFun ) } )  )
		      actions[#actions+1] = cc.CallFunc:create( function() setNodeAttr( targetLayer , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) ) end )

		      targetLayer:runAction(cc.Sequence:create(actions))
		    end
		    
		    actionFun( oneLayer )

			return bg
		end
		local switchFun = { showStyle1 ,  showStyle2 , showStyle3 , showStyle4 , showStyle5} 

		return switchFun[index]()
	end

	if #__textAry__[index] >= totalNum then 
		overCallbackFun(true)
		local newActionConfig = { 
						function( idx ) return cc.Sequence:create( { cc.EaseBackOut:create( cc.ScaleTo:create( 0.3  , 1 ) ), cc.DelayTime:create(1 ) ,removeSelf, cc.CallFunc:create( overCallbackFun ) })  end ,
						function( idx ) return cc.Sequence:create( { cc.MoveTo:create( effTime , getTargetValue( idx ) ) , cc.DelayTime:create( effTime * idx ), removeSelf, cc.CallFunc:create( overCallbackFun) } )  end ,
						function( idx ) return cc.Sequence:create( { cc.MoveTo:create( effTime , getTargetValue( idx ) ) , cc.DelayTime:create( effTime * idx ) ,removeSelf, cc.CallFunc:create( overCallbackFun ) } )  end ,
						function( idx ) return cc.Sequence:create( { cc.EaseBackOut:create( cc.ScaleTo:create( effTime  , 1 ) ) , cc.DelayTime:create( effTime * idx ) ,removeSelf, cc.CallFunc:create( overCallbackFun ) } )  end ,
						function( idx ) return cc.Sequence:create( { cc.EaseBackOut:create( cc.ScaleTo:create( effTime  , 1 ) ) , cc.DelayTime:create( effTime * idx ) ,removeSelf, cc.CallFunc:create( overCallbackFun ) } )  end ,
						}

		for i = 1 , #__textAry__[index] do
			if tolua.cast(__textAry__[index][i],"cc.Node") then
				__textAry__[index][i]:stopAllActions( )
				__textAry__[index][i]:runAction( newActionConfig[index]( i ) )
			end
		end

	end

	local curItem = createLayout()
	if curItem then
		(G_MAINSCENE or getRunScene()):addChild( curItem , 499 )
		__textAry__[ index ][ #__textAry__[ index ] + 1 ] = curItem
		if data.beginAction then curItem:runAction( data.beginAction ) end	
	end

	return true
end

--单选按钮组
function CreateBtnGroup( params )
  params = params or {}
  local parent = params.parent              --按钮添加到
  local btnCfg = params.btns                --按钮配置
  local tableIndex = params.defIndex or 1   --默认激活按钮
  local backcalls = params.callbacks        --回调集合
  local btnBg = params.bg or { "res/component/TabControl/5.png" ,  "res/component/TabControl/6.png" } --按钮背景
  local customBgFun = params.customBgFun or nil 	--选背景方法 返回指定组
  local path  = params.path
  local x = params.x or 0 
  local y = params.y or 0 
  local space = params.space or 0
  local btnsOffY = params.btnsOffY or 0   --按钮字体Y偏移
  local isGray = params.isGray or false   --是否灰显示
  local isText = params.isText or false		--是否显示文字按钮组

  local node = cc.Node:create()
  parent:addChild( node)

  local btns , curBtn = {} , nil
  local function changeState( index )
      if curBtn then
          if curBtn.pre then
              curBtn.def:setVisible( true )
              curBtn.pre:setVisible( false  )
          end
          curBtn:unselected()

          curBtn = btns[index]
          if curBtn.pre then
              curBtn.def:setVisible( false )
              curBtn.pre:setVisible( true  )
          end
          curBtn:selected()
      else
        for i = 1 , #btns do
          if btns[i].pre then
               btns[i].def:setVisible( true )
               btns[i].pre:setVisible( false  )
          end
        end

        curBtn = btns[index]
        if not curBtn then curBtn = btns[1] end
        
        if curBtn.pre then
          curBtn.def:setVisible( false )
          curBtn.pre:setVisible( true  )
        end
        curBtn:selected()

        --第一次生成时默认执行一次回调
        if type( backcalls ) == "table" then
        	if backcalls[index] then
        		backcalls[index]()
        	else
        		backcalls[1]()
        	end
        else
        	backcalls( index )
       	end

      end 
  end


  local function clickFun( tag , sender )
      changeState( sender.id )
      AudioEnginer.playTouchPointEffect()
      if type( backcalls ) == "table" then
    	backcalls[ sender.id ]() 
	  else
    	backcalls( sender.id )
	  end
  end
 
  local tabMenu = cc.Menu:create()
  setNodeAttr( tabMenu , cc.p(  0 , 0  ) , cc.p( 0 , 0 ) )
  node:addChild( tabMenu )

  local width , height = 0 , 0 
  for i = 1 , #btnCfg do
  	local curBg = { btnBg[1] , btnBg[2] }
  	local bgIndex = 1
  	if customBgFun then
  		bgIndex = customBgFun( i )
  		curBg = { btnBg[bgIndex][1] , btnBg[bgIndex][2] }
  	end
  	

    btns[i] = cc.MenuItemImage:create( curBg[1] , curBg[2] ) 
    -- btns[i]:setEnable( true )
    local btnSize = btns[i]:getContentSize()
    btns[i].id = i
    if isText then
		if btnCfg[i] ~= "" then
        	btns[i].def = createLabel( btns[i] ,  btnCfg[i] , getCenterPos(btns[i]), cc.p(0.5, 0.5), 24, true)
    	end	
    else
	    if type( btnCfg[i] ) == "string" then
	    	if btnCfg[i] ~= "" then
	        	-- btns[i].def = createSprite( btns[i] , path .. btnCfg[i] , cc.p( btnSize.width/2 , btnSize.height/2 + btnsOffY ) , cc.p( 0.5 , 0.5 ) , 5 )
	        	btns[i].def = GraySprite:create(path .. btnCfg[i])
		    	btns[i]:addChild(btns[i].def , 5 )
		    	btns[i].def:setAnchorPoint(cc.p( 0.5 , 0.5 ))
		    	btns[i].def:setPosition(cc.p( btnSize.width/2 , btnSize.height/2 + btnsOffY ) )
	    	end	
	    elseif type( btnCfg[i] ) == "table" then
	        -- btns[i].def = createSprite( btns[i] , path .. btnCfg[i][1] , cc.p( btnSize.width/2 , btnSize.height/2 + btnsOffY ) , cc.p( 0.5 , 0.5 ) , 5 )
	    	btns[i].def = GraySprite:create( path .. btnCfg[i][1])
	    	btns[i]:addChild(btns[i].def , 5)
	    	btns[i].def:setAnchorPoint(cc.p( 0.5 , 0.5 ))
	    	btns[i].def:setPosition(cc.p( btnSize.width/2 , btnSize.height/2 + btnsOffY ) )

	        -- btns[i].pre = createSprite( btns[i] , path .. btnCfg[i][2] , cc.p( btnSize.width/2 , btnSize.height/2 + btnsOffY ) , cc.p( 0.5 , 0.5 ) , 6 )
	    	btns[i].pre = GraySprite:create( path .. btnCfg[i][2] )
	    	btns[i]:addChild(btns[i].pre , 5)
	    	btns[i].pre:setAnchorPoint(cc.p( 0.5 , 0.5 ))
	    	btns[i].pre:setPosition( cc.p( btnSize.width/2 , btnSize.height/2 + btnsOffY ))

	    end
    end

    if isGray then
		if bgIndex == 2 then
			btns[i].def:addColorGray()
		else
			btns[i].def:removeColorGray()
		end
		if  btns[i].pre then
			if bgIndex == 2 then
				btns[i].pre:addColorGray()
			else
				btns[i].pre:removeColorGray()
			end
		end
    end

    setNodeAttr( btns[i] , cc.p( x + width  , y ) , cc.p( 0.5 , 0.5 ) )
    btns[i]:registerScriptTapHandler( clickFun )
    tabMenu:addChild( btns[i] )

    width = width + btnSize.width + space

  end

  changeState( tableIndex )



  function node:getBtns()
  	return btns
  end

  function node:forceActivation( _idx )
  	changeState( _idx )
  	backcalls[ _idx ]() 
  end
  
  return node
end

function useAndGoTo(protoId)
	log("useAndGoTo protoId = "..protoId)
	switch = {
		--寻宝符
		[5019] = function()
			local layer = require("src/layers/lotteryEx/LotteryLayer").new()
			if layer then
		        Manimation:transit(
		        {
		          ref = getRunScene() ,
		          node = layer ,
		          curve = "-",
		          sp = cc.p( display.width/2, 0 ),
		          zOrder = 200 ,
		          swallow = true,
		        })
		  end
		end
		,
	}

	if switch[protoId] then
		switch[protoId]()
	end
end	
--跨地图寻路
function findTarMap( map_id , start_mapid )
	-- body
	local v_max = getConfigItemByKey("MapInfo", "q_map_id",map_id, "q_map_min_level")
	local m_lv = MRoleStruct:getAttr(ROLE_LEVEL) or 0
	if m_lv < v_max then
		local msg_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{17000,-8})
		if msg_item and msg_item.fat then
			local msgStr = string.format(msg_item.msg,tostring(v_max))
			TIPS( { type = msg_item.tswz , str = msgStr } )	 
			return 
		end 
	end
	if start_mapid then
		game.setAutoStatus(AUTO_PATH_MAP)
	else
		game.setAutoStatus(AUTO_PATH)
	end
	local getCurMapHot = function(mapid)
		local transfor = getConfigItemByKey("HotAreaDB","q_id")
		local tran = {}
		for k,v in pairs(transfor) do
			if v.q_mapid == mapid then
				tran[#tran+1] = v
			end
		end
		return tran
	end
	local getDestMapPos = function(trans_for,tar_map_id)
		for k,v in pairs(trans_for) do
			if v.q_tar_mapid == tar_map_id then
				return cc.p(v.q_x, v.q_y)
			end
		end
		return nil
	end
	local start_mapid = start_mapid or G_MAINSCENE.mapId
	local getDeapthPathMapId = function() end
	getDeapthPathMapId = function(start_mapid,map_id,deapth,before_mapid)
		deapth = deapth + 1
		if deapth > 10 then 
			return deapth,map_id
		end
		local trans = getCurMapHot(start_mapid)
		local temp_deapth = 100
		local temp_mapid = map_id
		for k,v in pairs(trans) do
			if map_id == v.q_tar_mapid and start_mapid == v.q_mapid  then
				return deapth,map_id
			elseif v.q_tar_mapid ~= before_mapid then
				local temp_death_temp = 110
				temp_death_temp = getDeapthPathMapId(v.q_tar_mapid,map_id,deapth,start_mapid)
				if temp_deapth > temp_death_temp then
					temp_deapth = temp_death_temp
					temp_mapid = v.q_tar_mapid
				end
			end
		end
		return temp_deapth,temp_mapid
	end
	local deapth,next_map_id = getDeapthPathMapId(start_mapid,map_id,0,0)
	local pos = getDestMapPos(getCurMapHot(start_mapid),next_map_id)
	if pos then
 		G_MAINSCENE.map_layer:moveMapByPos(pos,false)
    else
        TIPS({str = game.getStrByKey("find_way_noPath")})
	end
	return pos
end

--制造执行错误，以便查找调用流程
function try()
	print(string.format(debug.traceback()))
end


--创建倒计时
function createDownTime( params )
	local params = params or {}
	local clockFlag = params.key    			--倒计时key
	local _time = params.time  					--倒计时间
	local callback = params.callback or nil		--倒计回调
	local style = params.style or 0				--表示样式 0天时分秒 1秒钟
	local fontSize = params.fontSize or 22
	local overFun = params.overFun or nil 		--计时完成后回调
	local text = params.text or nil    --描述内容
	local text_dis_time = params.distance or 0     --描述与倒计时的距离扩展

    local node = cc.Node:create()
    if text then
    	createLabel(node , text  , cc.p( 0 , 0  ) , cc.p( 0 , 0 ) , fontSize , nil , nil , nil , MColor.lable_yellow )
    elseif style == 0 then
    	createLabel( node , game.getStrByKey("activity_time")  , cc.p( 0 , 0  ) , cc.p( 0 , 0 ) , fontSize , nil , nil , nil , MColor.lable_yellow )
    end
    -- local bg = createSprite( node , "res/layers/activity/down_time.png" , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) )
    local timeTextAry = {}
    local strCfg = { game.getStrByKey("day") , game.getStrByKey("hour") , game.getStrByKey("min") , game.getStrByKey("sec") }
    local timeColor = params.timeColor or MColor.orange
    for i = 1 , 4 do
      timeTextAry[i] = createLabel( node , "00"  , cc.p( 120 + ( i - 1 ) * 60 + text_dis_time , 0 ) , cc.p( 0.5 , 0 ) , fontSize , nil , nil , nil , timeColor )
      if style == 0 then
	      createLabel( node , strCfg[i]  , cc.p( 150 + ( i - 1 ) * 60 + text_dis_time , 0 ) , cc.p( 0.5 , 0 ) , fontSize , nil , nil , nil , timeColor )
	  end
    end

    local function downFun()
        _time = _time - 1 
        return _time
    end


    local function downTime( key , timeTextAry ,downFun , _type )
		if callback then callback() end
      local typeIndex = _type and _type or 0
      local timeText = {}
      local function refreshTime()
        local curTime = downFun()
        if curTime < 0 then curTime = 0 end
        local dayNum = math.floor( tonumber(timeConvert( curTime , "hour"))/24 )
        curTime = curTime - dayNum * 86400
        timeTextAry[1]:setString( dayNum )                        						--天
        timeTextAry[2]:setString( math.mod( timeConvert( curTime , "hour") , 24 )  )  	--时
        timeTextAry[3]:setString( timeConvert( curTime , "min")  )            			--分
        timeTextAry[4]:setString( timeConvert( curTime , "sec")  )            			--秒
        if curTime <= 0 then
          DATA_Activity:regClockFun( key , nil )     
        end
      end
      --24小时，不展示天数
      local function refreshTime1()
        local curTime = downFun()
        if curTime < 0 then curTime = 0 end
        local dayNum = math.floor( tonumber(timeConvert( curTime , "hour"))/24 )
        curTime = curTime - dayNum * 86400
        local hour = math.mod( timeConvert( curTime , "hour") , 24 )
        if hour < 10 then  hour = "0" .. hour end

        timeTextAry[1]:setString( hour .. ":" .. timeConvert( curTime , "min") .. ":" .. timeConvert( curTime , "sec") )

        if curTime <= 0 then
          DATA_Activity:regClockFun( key , nil )     
        end
      end

      if typeIndex == 0 then
      	refreshTime()
        DATA_Activity:regClockFun( key , refreshTime )
      elseif typeIndex == 1 then
		timeTextAry[2]:setString( ""  )  	
        timeTextAry[3]:setString( ""  )            			
        timeTextAry[4]:setString( ""  )      
      	refreshTime1()
        DATA_Activity:regClockFun( key , refreshTime1 )
      end
    end

    downTime( clockFlag ,  timeTextAry , downFun , style )

	node:registerScriptHandler(function(event)
		if event == "enter" then  
		elseif event == "exit" then
			DATA_Activity:regClockFun( clockFlag , nil )
		end
	end)


    return node
end

function createNum( params )
  params = params or {}
  local path = params.path
  local num  = params.num or 0
  local offValue = params.offValue or 0   --图片没有0的偏移值为1否则为0
  local tempText = MakeNumbers:create( path , num - offValue  , -2 ) 
  return tempText 
end

function addTouchEventListen( root,callback )

        Mnode.listenTouchEvent(
        {
        node = root,
        swallow = false ,
        begin = function(touch, event)
          local node = event:getCurrentTarget()
          node.isMove = false
          local inside = Mnode.isTouchInNodeAABB(node, touch)
          return inside
        end,

        moved = function(touch, event)
            local node = event:getCurrentTarget()
            if node.recovered then return end
            local startPos = touch:getStartLocation()
            local currPos  = touch:getLocation()
            if cc.pGetDistance(startPos,currPos) > 5 then
                node.isMove = true
            end
        end,

        ended = function(touch, event)
          local node = event:getCurrentTarget()
          if Mnode.isTouchInNodeAABB(node, touch) and not node.isMove then
            AudioEnginer.playTouchPointEffect()
            if callback then callback() end
          end
        end,
        })
end

--生成帮助
function __createHelp( params )
	params = params or {}

	local str = params.str or {}

	local parent = params.parent or nil						--添加到
	local pos = params.pos or cc.p( 0 , 0 )				--坐标
	local anch = params.anch or cc.p( 0.5  , 0.5 )		
	local zorder = params.zorder or nil  				--层级
	local title	= params.title or game.getStrByKey("game_raiders")
	local width , height  = 480 , ( 300 - 40 )

	--显示帮助文字
	local function showHelp()
	  local base_node = popupBox({ 
                         bg = "res/common/helpBg.png" , 
                         zorder = 299 ,
                         isNoSwallow = true , 
                         isHalf = true , 
                         actionType = 7 ,
                       })


	  local function createLayout()
		local tempNode = cc.Node:create()

		local fontSize = 20
		local text = require("src/RichText").new( tempNode , cc.p( 0 , 0 ) , cc.size( width - 30 , 0 ) , cc.p( 0 , 1 ) , fontSize + 10 , fontSize , MColor.yellow_gray )
		text:addText( params.str , MColor.brown_gray , false )
		text:format()

		tempNode:setContentSize( cc.size( width , math.abs( text:getContentSize().height )  ) )
		setNodeAttr( text , cc.p( 40 , 0 ) , cc.p( 0 , 0  ) )

		return tempNode
	  end

	  

	  local scrollView1 = cc.ScrollView:create()	  
	  scrollView1:setViewSize(cc.size( width + 40  , height ) )--设置可视区域比文字区域大，防止字库导致字体大小不一致的显示问题
	  scrollView1:setPosition( cc.p( 0 , 20  ) )
	  scrollView1:setScale(1.0)
	  scrollView1:ignoreAnchorPointForPosition(true)
	  local layer = createLayout()
	  scrollView1:setContainer( layer )
	  scrollView1:updateInset()
	  scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
	  scrollView1:setClippingToBounds(true)
	  scrollView1:setBounceable(true)
	  scrollView1:setDelegate()
	  base_node:addChild(scrollView1)
	  if not params.title then
	  	createSprite(base_node, "res/common/helpBg_title.png", cc.p(261, 290))
	  end
	  createLabel(base_node,title , cc.p(261, 290), nil, 20):setColor(MColor.brown)

	  local layerSize = layer:getContentSize()
	scrollView1:setContentOffset( cc.p( 0 ,  height - layerSize.height  ) )


	  registerOutsideCloseFunc( base_node , function() removeFromParent(base_node) end,true ,true)
	end

	local helpBtn = nil 
	if parent then 
		helpBtn = createMenuItem( parent , "res/component/button/small_help2.png" , pos , showHelp , zorder )
	end

	return helpBtn , showHelp
end

--生成礼包组
function __createAwardGroup( awards , isShowName , Interval , offX , isSwallow , addWidth )
    local node = cc.Node:create()
    awards = awards or {}

    local cellHeight = 130
    local awardBtns = {}
    local iconNum = #awards
    for i = 1 , iconNum do
			local iconCellBtn = iconCell( { 
			            isTip = true , 
			            swallow = isSwallow ,
			            num = awards[i].num and { value = awards[i].num }  or nil  , 
			            allData = awards[i] , 
			            name = isShowName , 
			            customIcon = awards[i].customIcon , 
			            parent = node , 
			            iconID = awards[i].id or awards[i].q_item ,
		              	showBind = awards[i].showBind ,
  						isBind = awards[i].isBind,
  						noFrame = awards[i].noFrame,
			          } )
			local iconSize = iconCellBtn:getContentSize()
			setNodeAttr( iconCellBtn , cc.p( ( offX or 20 ) + iconSize.width/2 + ( i - 1 ) * ( Interval or 100 ) , cellHeight/2 ) , cc.p( 0.5 , 0.5 ) )
			awardBtns[i] =iconCellBtn
    end
    node:setContentSize( cc.size( iconNum * ( Interval or 100 ) + ( addWidth or 40 ) , cellHeight ) )
    
    function node:getIcons()
    	return awardBtns
    end

    function node:setVisibleAndTouchEnabled( bEnabled )
    	-- body
        for k,v in pairs(awardBtns) do
            v:setVisible(bEnabled)
        end
        node:setVisible(bEnabled)
    end

    return node
end

--检查元宝是否足够
function __checkGold( _needNum )
	local isFull = true
	if _needNum > MRoleStruct:getAttr( PLAYER_INGOT ) then
		isFull = false
	end
	return isFull
end

--飞行靴传送
function __shoesGoto( targetData,auto_mine )
	-- targetData = { need_lv = 35 , noMapLv = true , mapid = 2100 , x = 55.0 , y = 71.0 }
	local tempLayer = nil
	local function chechNeedlv( _lv )
      local isRefuse = false
      --特别等级限制判断
      if not isRefuse and ( MRoleStruct:getAttr(ROLE_LEVEL) < tonumber( _lv ) )  then
          local msg_item = getConfigItemByKeys( "clientmsg" , { "sth" , "mid" } , { 21000 , -1 } )
          local msgStr = string.format( msg_item.msg , tostring( _lv ) )
          TIPS( { type = msg_item.tswz , flag = msg_item.flag , str = msgStr } )
          isRefuse = true
          return isRefuse
      end
      
      return isRefuse
	end

	if targetData.need_lv then 
		--特别等级限制
		if chechNeedlv( targetData.need_lv ) then return end 
	end

	if targetData.mapid and not targetData.noMapLv then 
		--地图默认等级限制
		local map_item = getConfigItemByKey( "MapInfo" , "q_map_id" , targetData.mapid )
		if chechNeedlv( map_item.q_map_min_level ) then return end 
	end


    local useShoseFun = function()
        local shoewNeedData = { targetData = { mapID = targetData.mapid , 
                                              pos = { 
                                                      { 
                                                        x = targetData.x , 
                                                        y = targetData.y 
                                                      } 
                                                    } 
                                              } ,  
                                noTipShop = ( targetData.isNoTipShop or false ) ,
                                q_done_event = ( targetData.q_done_event or "0" ) ,
                                oldData = ( targetData.oldData or nil ) , 
                              }
        require("src/base/BaseMapScene").auto_mine = auto_mine 
        if not __TASK:portalGo( shoewNeedData , ( targetData.isNoPlot or false ) , ( targetData.isTask or false ),true ) then
        	DATA_Mission.isStopFind = true
        	return 
        end
    end

    local function popupTip()
    	local str = game.getStrByKey("worldshoestips")
    	if targetData.noText then
    		str = ""
    	end
    	tempLayer = MessageBoxYesNo(nil, str ,useShoseFun, nil )

    	local no_selectBtn , selectBtn

    	local function selectFun( value )
    		DATA_Mission.no_tip_need_shoes = value
    		selectBtn:setVisible( DATA_Mission.no_tip_need_shoes ~= 0 )
		end

    	no_selectBtn = createMenuItem( tempLayer , "res/component/checkbox/1.png" , cc.p( 170 , 110 ) , function() selectFun( 1 ) end )
    	selectBtn = createMenuItem( tempLayer , "res/component/checkbox/1-1.png" , cc.p( 170 , 110 ) , function() selectFun( 0 ) end )
    	createLabel( tempLayer , game.getStrByKey("ping_btn_no_more")  , cc.p(195 , 110 ) , cc.p( 0 , 0.5 ) , 20 , true , nil , nil , MColor.lable_black , nil , nil , MColor.black , 3 )
    	selectBtn:setVisible( DATA_Mission.no_tip_need_shoes ~= 0 )
    end

  	if not DATA_Mission.no_tip_need_shoes then DATA_Mission.no_tip_need_shoes = 0 end

    if DATA_Mission.no_tip_need_shoes == 0 then
    	popupTip()
    else
    	useShoseFun()
    end

    return tempLayer , useShoseFun
end

function getTimeByInt(value)
	if type(value) ~= "number" then return end
	if value <= 0 then return "" end
	local hour = math.modf(value/3600)
	local late = value%3600
	local min = math.modf(value/60) 
	local late = value%60
	--print(hour, min, late)
	local strTime = string.format("%02d:%02d:%02d", hour, min, late)
	return strTime
end

function copyTable(ori_tab)
    if (type(ori_tab) ~= "table") then
        return nil;
    end
    local new_tab = {};
    for i,v in pairs(ori_tab) do
        local vtyp = type(v);
        if (vtyp == "table") then
            new_tab[i] = copyTable(v);
        elseif (vtyp == "thread") then
            new_tab[i] = v;
        elseif (vtyp == "userdata") then
            new_tab[i] = v;
        else
            new_tab[i] = v;
        end
    end
    return new_tab;
end

function haveDrug()
    local tabTemp = {}  --持续红
    local tabTemp1 = {} --持续蓝
    local tabTemp2 = {} --瞬回红
    local drugTab = {[1]={},[2]={},[3]={}}
    for i=1,20 do
    	if (i+20019) ~= 20023 then          --天山雪莲特殊
	    	local a = getConfigItemByKey("propCfg","q_id",(i+20019),"q_rare")
	        if a then
	            local temp = a
	            local tab = stringsplit(temp, ",")
	            table.insert(tab,(i+20019))
	            if tonumber(tab[1]) == 1 then
	            	table.insert(tabTemp,tab)
	            	table.insert(drugTab[1],{i+20019,tab[2]})
	            elseif tonumber(tab[1]) == 2 or tonumber(tab[1]) == 6 then
	            	table.insert(tabTemp1,tab)
	            	table.insert(drugTab[3],{i+20019,tab[2]})
	            elseif tonumber(tab[1]) == 5 then
	            	table.insert(tabTemp2,tab)
	            	table.insert(drugTab[2],{i+20019,tab[2]})
	            else            	
	            	if tonumber(tab[1]) == 3 then
	            		table.insert(tabTemp,tab)
	            		table.insert(tabTemp1,tab)
	            		table.insert(drugTab[1],{i+20019,tab[2]})
	            		table.insert(drugTab[3],{i+20019,tab[2]})
	            	elseif tonumber(tab[1]) == 4 then
	            		table.insert(tabTemp2,tab)
	            		table.insert(drugTab[2],{i+20019,tab[2]})
	            	end
	            end
	        end
	    end
    end
    local seq = function(a,b)
    	return a[2] < b[2]
	end
    table.sort(tabTemp,seq)
    table.sort(tabTemp1,seq)
    table.sort(tabTemp2,seq)
	G_DRUG_TAB = drugTab
	G_DRUG_MP = tabTemp1
	G_DRUG_HP = tabTemp    	
	G_DRUG_HP_SHORT = tabTemp2
end


--喊人跳转
function __CallGoto( params )
	local callType = params.calltype or 1
	local callData = params.callData or { "1" ,"0"}
	--if not G_CallGotoTimeFlg then TIPS({str = game.getStrByKey("chat_CallMsgTimeLittle") , type = 1})  return end
	if GetTime() - G_CallGotoTimeFlg > 2 then
		G_CallGotoTimeFlg = GetTime()
	else
		TIPS({str = game.getStrByKey("chat_CallMsgTimeLittle") , type = 1})
		return
	end

	print("__CallGoto....................callType:" .. callType)
	if callType == 1 then
		local parm1 = tonumber(callData[1])
		local parm2 = tonumber(callData[2])
		local parm3 = math.floor( tonumber(callData[3]) / 10000 )

		if parm2 == 1100 and G_MAINSCENE.map_layer.mapID == 1100 then
			local lineNum = MRoleStruct:getAttr(PLAYER_LINE) or 10000
			if parm3 ~= math.floor(lineNum/10000)  then
				local map_strs = require("src/layers/buff/ChangeLineLayer"):getMapName(parm3)
				TIPS({ str = "请切换至" .. map_strs .. ",您的队友在等您哦！", type = 1})
				return
			end
		end
		g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_JOINCOPYTEAM, "CopyJoinTeamProtocol", {teamId = parm1});
	elseif callType == 2 then
		local parm1 = callData[1]
		local parm2 = tonumber(callData[2])
		-- g_msgHandlerInst:sendNetDataByFmtExEx(TEAM_CS_INVITE_TEAM,"iSbi",userInfo.currRoleId,parm1,true,parm2)
		g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_INVITE_TEAM, "InviteTeamProtocol", {["tName"] = parm1,["isApply"] = true,["iTeamID"] = parm2})
	elseif callType == 3 then
		__GotoTarget( { ru =  callData[1] } )
	end
	-- G_CallGotoTimeFlg = GetTime()
	-- if G_MAINSCENE then
	-- 	performWithDelay(G_MAINSCENE,function() G_CallGotoTimeFlg = true end, 2)
	-- end
end


function showOperateLayer(node, name,parent)
    if name == G_ROLE_MAIN:getTheName()  or name == "" then
        return
    end    
    local func = function(tag)
      local switch = {
        [1] = function() 
          PrivateChat(name)
        end,
        [2] = function() 
          LookupInfo(name)
        end,
        [3] = function() 
          InviteTeamUp(name)
        end,
        -- [4] = function() 
        --   LookupBooth(name)
        -- end,
        [4] = function() 
          AddFriends(name)
        end,
        [5] = function() 
          AddBlackList(name)
        end,
        }
	    if switch[tag] then switch[tag]() end
		removeFromParent( node.operate)
		node.operate = nil
    end
    local menus = {
		{game.getStrByKey("private_chat"),1,func},
		{game.getStrByKey("look_info"),2,func},
		{game.getStrByKey("re_team"),3,func},
		--{game.getStrByKey("look_shop"),4,func},
		{game.getStrByKey("addas_friend"),4,func},
		{game.getStrByKey("add_blackList"),5,func},
		--{game.getStrByKey("trade"),6,func},
    }
    node.operate =  require("src/OperationLayer").new(parent or G_MAINSCENE.base_node  ,1,menus)
end

function isSelfTeamLeader()
    local res = (G_TEAM_INFO.team_data and G_TEAM_INFO.team_data[1] and  G_TEAM_INFO.team_data[1].roleId == userInfo.currRoleStaticId)
    return res
end

--登陆前提示
function __ShowLoginTip( sevData )

end

function StrSplit(str, split)
    local strTab={}
    local sp=split or "&"
    local tb = {}
    while type(str)=="string" and string.len(str)>0 do
        local f=string.find(str,sp)
        local ele
        if f then
            ele=string.sub(str,1,f-1)
            str=string.sub(str,f+1)
        else
            ele=str
        end
        table.insert(tb, ele)
        if not f then break end
    end
    return tb
end
--根据策划配置的时间.获得对应的中文时间    
function getStrTimeByValue(str,needDay)
	if nil == needDay then 
		needDay = true
	end
	
    if not str or (type(str) == "string" and str == "" )then
        return ""
    end

    local strTime = StrSplit(str, ",")
    local retDay
    if strTime[4] == "*" then
        retDay = "每天"
    else
        local strDay  = StrSplit(strTime[4], " ")
        retDay = game.getStrByKey("faction_bossTime1")
        for i=1, #strDay do
            retDay = retDay .. game.getStrByKey("week_" .. strDay[i])
            if i ~= #strDay then
                retDay = retDay .. "、"
            end
        end
    end
    
    local retHour = ""
    if strTime[5] == "*" then
        retHour = "全天"
    else
	    local strHour = StrSplit(strTime[5] or "", "-")
	    local strHour1 = StrSplit(strHour[1] or "", ":")
	    local strHour2 = StrSplit(strHour[2] or "", ":")
	    for i=1,#strHour1 do
	        if i == 1 then
	            retHour = retHour .. strHour1[i]
	        elseif i == 2 then
	            retHour = retHour .. ":" .. strHour1[i]
	        else
	            break
	        end
	    end

	    retHour = retHour .. "-"
	    for i=1,#strHour2 do
	        if i == 1 then
	            retHour = retHour .. strHour2[i]
	        elseif i == 2 then
	            retHour = retHour .. ":" .. strHour2[i]
	        else
	            break
	        end
	    end
	end    
    if needDay then    	
    	return retDay .. " ".. retHour , retDay
    else
    	return retHour, retDay
    end
end

function isKingModel( modelID )
	-- if  modelID == 51100 or modelID == 52100 or modelID == 51200 or
	-- 	modelID == 52200 or modelID == 51300 or modelID == 52300 or
	-- 	modelID == 51101 or modelID == 52101 or modelID == 51201 or
	-- 	modelID == 52201 or modelID == 51301 or modelID == 52301 then
	-- 	return true
	-- end
	return false
end

function isSpecalModel( modelID )
	return isKingModel(modelID)	or modelID == 9003 or modelID == 53001
end

function saveLoginServerId()
	if userInfo.userName and userInfo.serverId then
		setLocalRecordByKey(1, "serverListLastLogin" .. sdkGetOpenId(), userInfo.serverId)

		local function serverListConnected()
			weakCallbackTab.onServerListConnected = nil
			ServerList.sendLoginServer(sdkGetArea(), userInfo.serverId, false)
		end

		if ServerList.isConnected() then
			serverListConnected()
		else
			weakCallbackTab.onServerListConnected = serverListConnected
			ServerList.connect()
		end
		
		setLocalRecordByKey(1,"lastServer",userInfo.serverId)
		setLocalRecordByKey(2,"lastServerName",userInfo.serverName)
	end
end

--NPC对话类型5 执行客户端方法
function __ClientNPCFun( _tempDate )
	local value , params = _tempDate["optionvalue"] , _tempDate["optionparam"]
	local switchFun = {
						["1"] = function()
                            -- 行会功能未开启
                            if not NewFunctionIsOpen(NF_FACTION) then
                                TIPS{str=game.getStrByKey("func_unavailable"), type=1, flag=1};
                                return;
                            end

                            if G_FACTION_INFO and G_FACTION_INFO.facname and G_FACTION_INFO.id > 0 then
							    local data = require("src/config/FactionCopyDB")
					            for i=1,#data do
								    local tempData = data[i]
								    if tempData.ID == G_FACTION_INFO.StartFbId then
									    local time = os.time()
									    if G_MAINSCENE.pingNode and G_MAINSCENE.pingNode.getServerTime then
										    local serverTime = G_MAINSCENE.pingNode:getServerTime()
										    if serverTime ~= nil then
											    time = serverTime + math.floor(G_MAINSCENE.tick_time / 4)
										    end
									    end
									    if time == nil then
										    time = os.time()
									    end
    --									local passTime = time - G_FACTION_INFO.StartFbTime
    --									if passTime <= tempData.bossFreshTime and passTime > 0 then 
    --										TIPS( {str = string.format(game.getStrByKey("faction_bossNotOpened"), secondParse(tempData.bossFreshTime - passTime)), type = 1  })
    --									else
										    if MRoleStruct:getAttr( ROLE_LEVEL ) < tonumber(data[i].joinLevel) then
											    TIPS({ type = 1, str = string.format( game.getStrByKey("faction_joinFbLevLimite"), tonumber(data[i].joinLevel) ) })
										    else 
										        g_msgHandlerInst:sendNetDataByTableExEx(FACTIONCOPY_CS_JOIN, "FactionCopyJoin", {})
                                            end
    --									end
									    return
								    end
					            end
					            TIPS( getConfigItemByKeys("clientmsg", {"sth", "mid"}, {15900, -11}) )
                            else
                                TIPS{str = game.getStrByKey("join_faction_tips"), type=1, flag=1}
                            end
						end , 
						["2"] = function()  -- 完成悬赏任务
                            local obj = require("src/layers/mission/MissionNetMsg");
                            if obj ~= nil then
                                obj:SendRewardTaskReq(3);
                            end
						end , 
						["3"] = function()	-- 完成共享任务
							local param = tonumber(params)
							if param == 0 then --领取奖励
								local MainRoleId = 0
								if userInfo then
									MainRoleId = userInfo.currRoleId
								end
								g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_GET_SHARED_TASK_PRIZE, "GetSharedTaskPrizeProtocol", {})
								cclog("[TASK_CS_GET_SHARED_TASK_PRIZE] sent. role_id = %s.", MainRoleId)
							elseif params == 2 then --寻找队伍
								require("src/layers/teamTreasureTask/AncientTreasureTeamPanel").new()
							else --远古宝藏
								__GotoTarget({ru = "a202"})
							end
						end,
						-- ["a183"] = function( ... )
						-- 	-- body
						-- 	-- require("src/layers/blackMarket/BlackMarketPanel").new()
						-- 	GetBlackMarketCtr():openBlackMarket()
						-- end
						}
	switchFun[ value .. "" ]()
end

--判断功能开启.如果不开启则提示完成什么任务
function NewFunctionIsOpen(id)
	if id == nil then return true end
	if G_NFTRIGGER_NODE and not G_NFTRIGGER_NODE:isFuncOn(id)then
		local Cfg = getConfigItemByKey("NewFunctionCfg", "q_ID", id)
		if Cfg and Cfg.q_level then
			-- local taskDb = getConfigItemByKey("TaskDB")
			-- for i=1,#taskDb do
			-- 	if taskDb[i].q_taskid == Cfg.q_task then
			-- 		TIPS({str = string.format(game.getStrByKey("func_unavailable_noTask"), taskDb[i].q_name)})
			-- 	end
			-- end
			TIPS({str = string.format(game.getStrByKey("func_unavailable_lv"), Cfg.q_level)})
		end
		return false
	end
	return true
end

--npc地址信息
function __NpcAddr( npcid )

    local npcCfg = getConfigItemByKey("NPC", "q_id"  )[ npcid ]
    if npcCfg then 
		local targetData = 	{ mapID = npcCfg.q_map , pos = { { x = npcCfg.q_x , y =  npcCfg.q_y } } } --为了兼容
        return { targetType = 4 , mapID = npcCfg.q_map ,  x = npcCfg.q_x , y = npcCfg.q_y , targetData = targetData }
    end

    -- local msg_item = getConfigItemByKeys( "clientmsg" , { "sth" , "mid" } , { 21000 , -1 } )
    -- local msgStr = string.format( msg_item.msg , tostring( mapInfo.q_map_min_level ) )
    -- TIPS( { type = msg_item.tswz , flag = msg_item.flag , str = msgStr })
    return nil
end

function charStateEffectTip(effect_type)
	if effect_type < 1 or effect_type > HEADTEXT_SILENCE then
		return
	end

	local key_type = {"dread", "freeze", "", "gravity", "", "palsy", "poison", "poison", "", "silence"}
	if key_type == "" then
		return
	end
	local yourbuffer = key_type[effect_type]
	if yourbuffer == "palsy" then
		if G_MY_STEP_SOUND then
			AudioEnginer.stopEffect(G_MY_STEP_SOUND) 
			G_MY_STEP_SOUND = nil
		end
	end
	local text_type = game.getStrByKey(yourbuffer)
	local text_temp = game.getStrByKey("tip_state_effect_template")
	local text_entire = string.format(text_temp, text_type)

	TIPS({type=2, str=text_entire})
end

function playCommonEffect(_parentNode, _effectFile, _frame, _time, _loop, _tag)

	if _parentNode == nil then
		return
	end

	if _effectFile == nil then
		return
	end

	local frameCount = 3
	if _frame ~= nil then
		frameCount = _frame
	end

	local timeLen = 1.0
	if _time ~= nil then
		timeLen = _time
	end

	local loopCount = 1
	if _loop ~= nil then
		loopCount = _loop
	end

	local effectTag = 5478
	if _tag ~= nil then
		effectTag = _tag
	end

	-------------------------------------------------------

	local effect = Effects:create(false)
	effect:playActionData(_effectFile, frameCount, timeLen, loopCount)

	local parNode = _parentNode

	if parNode:getChildByTag(effectTag) then
		parNode:removeChildByTag(effectTag)
	end
	parNode:addChild(effect, 100, effectTag)

	local removeFunc = function()
		if parNode and parNode:getChildByTag(effectTag) then
			parNode:removeChildByTag(effectTag)
		end
	end

	local dur = timeLen * loopCount
	if loopCount > 0 then
		performWithDelay(parNode, removeFunc, dur)
	end

	return effect
end

function _checkDragonSliayerRed()
	if G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_FB_SINGLE) then 
		if not userInfo.newFbId then
			userInfo.newFbId = -1
			local fullStr = getLocalRecordByKey(2,"redDotFbId","")

			if fullStr ~= "" then
				local split = string.find(fullStr,"%.")
				if split then
					local m = tonumber(string.sub(fullStr,1,split-1))
					local n = tonumber(string.sub(fullStr,split+1,#fullStr))
					if m == userInfo.currRoleStaticId then
						userInfo.newFbId = n
					end
				end
			end
		end
		if userInfo.newFbId ~= -1 then
			local fbData = require("src/config/dragonSliayerCfg")
			local isOpen = false
			for x=1,#fbData do
				if userInfo.newFbId == tonumber(fbData[x].q_id) then
					isOpen = true
					break
				end
			end
			DATA_Battle:setRedData("TLCS", isOpen)
		end
	end  	
end

--显示安全区或pk区信息
function showMapTip()
	log("showMapTip")
	--dump(G_MAINSCENE.map_layer:isInSafeArea(G_ROLE_MAIN.tile_pos))
	local mapId = G_MAINSCENE.mapId
	local mapName = require("src/layers/buff/ChangeLineLayer"):getMapName(nil, mapId)

	local areaStr 
	if G_MAINSCENE.map_layer and G_ROLE_MAIN and G_ROLE_MAIN.tile_pos then 
		local state = G_MAINSCENE.map_layer:isInSafeArea(G_ROLE_MAIN.tile_pos, true)
		--dump(state)
		if state == true then
			areaStr = "^c(green)"..game.getStrByKey("safe_area").."^"
		elseif state == false then
			if G_MAINSCENE.map_layer.q_map_pk and G_MAINSCENE.map_layer.q_map_pk == 0 then
				areaStr = "^c(red)"..game.getStrByKey("fire_area").."^"
			else
				areaStr = "^c(red)"..game.getStrByKey("pk_area").."^"
			end
		end
	end

	if mapName and areaStr then                               
		local bg = createSprite(getRunScene(), "res/common/bg/titleLine2.png", cc.p(display.cx, 260), cc.p(0.5, 0.5), 150)
		local richText = require("src/RichText").new(bg, getCenterPos(bg, 0, -2), cc.size(300, 20) , cc.p(0.5, 0.5), 20, 20, MColor.white)
		richText:setAutoWidth()
		richText:addText(mapName.."-"..areaStr)
		richText:format()
		--createLabel(bg, mapName..areaStr, getCenterPos(bg), cc.p(0.5, 0.5), 20, true)

		bg:setOpacity(0)
		bg:runAction(cc.Sequence:create(cc.FadeIn:create(0.1), 
			cc.DelayTime:create(1), 
			cc.FadeOut:create(0.1), 
			cc.RemoveSelf:create()
		))
	end
end

--初始化快捷短语
function initShortForChat()
	local shortTab = getConfigItemByKey("ChatShortDB")
	--dump(shortTab)
	if shortTab then
		for i,v in ipairs(shortTab) do
			log("id ="..v.q_id.."  q_str = "..v.q_str)
			--g_msgHandlerInst:sendNetDataByFmtExEx(CHAT_CS_SET_PHRASE, "isS", userInfo.currRoleStaticId, v.q_id, v.q_str)
			local t = {}
			t.index = v.q_id
			t.phrase = v.q_str
			g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_SET_PHRASE, "SetPhraseProtocol", t)
		end
	end
end

-- 获取怪物的最大血量
function GetMonsterMaxHP(id)
    if id ~= nil then
        local monsterInfo = getConfigItemByKey("monster", "q_id")[id];
        if monsterInfo~= nil then
            local monsterHPMax = monsterInfo["q_maxhp"]
            if monsterHPMax ~= nil then
                return monsterHPMax;
            end
        end
    end

    return 0;
end

--更新全局黑名单
function UpdateBlack()
	--log("UpdateBlack")
	g_msgHandlerInst:registerMsgHandler(RELATION_SC_GETRELATIONDATA_RET , function(buff)
		log("get RELATION_SC_GETRELATIONDATA_RET")
		local t = g_msgHandlerInst:convertBufferToTable("GetRelationDataRetProtocol", buff) 
		local relationType = t.relationKind
		log("relationType = "..relationType)
		dump(relationType)
		if relationType == 3 then
			local blackData = {}
			-- local onlineNum = buff:popChar()
			-- for i=1,onlineNum do
			-- 	local record = {}
			-- 	record.roleId = buff:popInt()
			-- 	record.name = buff:popString()
			-- 	record.lv = buff:popChar()
			-- 	record.sex = buff:popChar()
			-- 	record.school = buff:popChar()
			-- 	record.fight = buff:popInt()
			-- 	record.online = true

			-- 	table.insert(blackData, #blackData+1, record)
			-- end
			-- local offLineNum = buff:popChar()
			-- for i=1,offLineNum do
			-- 	local record = {}
			-- 	record.roleId = buff:popInt()
			-- 	--log("test 1")
			-- 	record.name = buff:popString()
			-- 	--log("test 2")
			-- 	record.lv = buff:popChar()
			-- 	--log("test 3")
			-- 	record.sex = buff:popChar()
			-- 	--log("test 4")
			-- 	record.school = buff:popChar()
			-- 	--log("test 5")
			-- 	record.fight = buff:popInt()
			-- 	--log("test 8")
			-- 	record.online = false

			-- 	table.insert(blackData, #blackData+1, record)
			-- end
			for i,v in ipairs(t.roleData) do
				local record = {}
				record.roleId = v.roleSid
				record.name = v.name
				record.lv = v.level
				record.sex = v.sex
				record.school = v.school
				record.fight = v.fightAbility
				record.online = v.isOnLine
				table.insert(blackData, #blackData+1, record)
			end
			--dump(blackData)
			if blackData then
				G_BLACK_INFO = {}
				for i,v in ipairs(blackData) do
					table.insert(G_BLACK_INFO, #G_BLACK_INFO+1, {name=v.name, roleId=v.roleId})
				end
			end
			--dump(G_BLACK_INFO)
		end
	end)
	if G_ROLE_MAIN then
		--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_GETRELATIONDATA, "ic", G_ROLE_MAIN.obj_id, 3)
		g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 3})
	end
end

--创建制定角色纸娃娃
function LookupRoleNode(name_str, callback)
	log("LookupRoleNode")
	g_msgHandlerInst:registerMsgHandler(FRAME_SC_LOOKUP_DATARET , function(buff)
		dump("--------------", "查看资料返回")
		local result, info = require("src/layers/beautyWoman/RoleAndBeautyLayer"):ParseRoleData(buff)
		if not result then
			TIPS({ type = 1  , str = "该角色已被删除" })
			return
		end	
		
		--dump(info.wing)
		local clothes = 0
		local weaponId = 0
		if info.equipList[1] then
			weaponId = info.equipList[1].mPropProtoId
		end
		if info.equipList[2] then
			clothes = info.equipList[2].mPropProtoId
		end

		-- self.selRoleInfo = {school = info[ROLE_SCHOOL], clothes = clothes, weaponId = weaponId, wing = info[PLAYER_EQUIP_WING], sex = info[PLAYER_SEX], recnum = info[PLAYER_GLAMOUR]}
		-- dump(self.selRoleInfo)
		local roleNode = createRoleNode(info[ROLE_SCHOOL], clothes, weaponId, info[PLAYER_EQUIP_WING], nil, info[PLAYER_SEX])
		if callback then
			callback(roleNode)
		end
	end)

	--g_msgHandlerInst:sendNetDataByFmt(FRAME_CS_LOOKUP_DATA, "iSi", G_ROLE_MAIN.obj_id, name_str, 0)
	g_msgHandlerInst:sendNetDataByTable(FRAME_CS_LOOKUP_DATA, "FrameLookUpProtocol", {name=name_str, notice=0})
end



--刷新周边怪的颜色
function UpdateMonsterNameColor()
	if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.monster_tab then
		for k,v in pairs(G_MAINSCENE.map_layer.monster_tab) do
		   	local monster = tolua.cast(G_MAINSCENE.map_layer.item_Node:getChildByTag(k), "SpriteMonster")
		   	if monster then
		   		require("src/base/MonsterSprite"):updateNameColor(monster)
		   	else
		   		log("cast monster error!!!!")
		   	end
		end
	end
end

--刷新时间函数
function UpdateGTimeInfo(netTime)
	if G_TIME_INFO then
		G_TIME_INFO.netTime = netTime
		G_TIME_INFO.localTime = os.time()
		G_TIME_INFO.correctTime = G_TIME_INFO.netTime - G_TIME_INFO.localTime
		G_TIME_INFO.time = G_TIME_INFO.localTime + G_TIME_INFO.correctTime
	end
	--dump(G_TIME_INFO)
end

function GetTime()
	if G_TIME_INFO then
		if G_TIME_INFO.correctTime then
			return os.time() + G_TIME_INFO.correctTime
		end
	end
	return os.time()
end

--查看送镖成员名称
function LOOK_TEAM( _str )
	local strTab = stringsplit( _str , "###" )
	local num = #strTab + 1
	local grouNode = cc.Node:create()
	local totalHeight = num * 30
	createLabel( grouNode , game.getStrByKey( "bodyguard_team17" ) , cc.p( 10 , totalHeight ) , cc.p( 0 , 1 ) , 20 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 ) 
	num = num - 1
	for i = 1 , num do
		createLabel( grouNode , i .. "." .. strTab[i] , cc.p( 10 , ( num - i + 1 ) * 30 - 10 ) , cc.p( 0 , 0.5 ) , 18 , nil , nil , nil , MColor.yellow , nil , nil , MColor.black , 3 ) 
	end
	grouNode:setContentSize( cc.size( 150 , totalHeight ) )
	local base_node = popupBox({ 
						 createScale9Sprite = { size = cc.size( 150 , totalHeight + 10 ) } ,  
						 pos = cc.p( 566 , display.height - 50 ) , 
						 anch = cc.p( 0 , 1 ) , 
 						 bg = "res/common/scalable/1.png" ,  
                         close = { callback = function() end , scale = 0.0  } , 
                         zorder = 200 ,
                         actionType = 7 ,
                         isNoSwallow = false , 
                         isHalf = true,
                       })
	base_node:addChild( grouNode )
end

--检测屏蔽关键字
function checkShield(text)
--[[	local shieldTab = getConfigItemByKey("shieldword","name")
	for k,v in pairs(shieldTab) do
		--cclog("~~~~~~~"..text.."~"..k.."1")
	 	local pos = string.find(text,k) 
	 	--dump(pos)
		if pos then
			local utf8len = string.utf8len(k)
			local newStr = ""
			for x=1,utf8len do
				newStr = newStr.."*"
			end
			--dump(k)
			--dump(newStr)
			text = string.gsub(text,k,newStr)
		end
	end
]]	
    text = DirtyWords:checkAndReplaceDirtyWords(text, "****")
    return text
end


--判断node是否有效
function IsNodeValid( uiNode )
	-- body
	if not uiNode then
		return false
	end
	return tolua.cast(uiNode, "cc.Node")
end

--隐藏显示称号
function updateTitleShow(isShow)
	if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.role_tab then
		for k,v in pairs(G_MAINSCENE.map_layer.role_tab) do
			local role_item = tolua.cast(G_MAINSCENE.map_layer.item_Node:getChildByTag(k), "SpritePlayer")

			if role_item and role_item ~= G_ROLE_MAIN then
				local titleNode = role_item:getTitleNode()
				if titleNode then
					local titleSpr = titleNode:getChildByTag(100)
					if titleSpr then
						if isShow then
							titleSpr:setVisible(true)
						else
							titleSpr:setVisible(false)
						end
					end
				end
			end
		end
	end
end

--隐藏翅膀
function updateWingShow(isShow)
	if G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.role_tab then
		for k,v in pairs(G_MAINSCENE.map_layer.role_tab) do
			local role_item = tolua.cast(G_MAINSCENE.map_layer.item_Node:getChildByTag(k), "SpritePlayer")

			role_item:setWingNodeVisble(isShow)
		end
	end
end

--判断是否是windows平台
local bIsWin32 = nil
function IsWin32( ... )
	-- body
	if bIsWin32 == nil then 
		bIsWin32 = cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS
	end
	return bIsWin32
end

--打印table
function TablePrint( t, indent, func, ... )
	if nil == indent then
		indent = 0;
	end
	if nil == func then
		func = handler( GetLog(), GetLog().d );
	end
	if 0 == indent then
		m_mapPrinted = {};
		func( "", ... );
	end
	local strPrefix = "";
	for i=1,indent do
		strPrefix = strPrefix .. " ";
	end
	if type(t) == "table" then
		for k,v in pairs(t) do
			if "table" ~= type(k) and "class" ~= tostring(k) then
				local strSuffix1 = "";
				local strSuffix2 = "";
				if "table" == type(v) then
					if nil == m_mapPrinted[v] and nil == string.find( tostring(k), "m_p", 1 ) then
						m_mapPrinted[v] = true;
						func( strPrefix .. tostring(k) .. " = ", ... );
						func( strPrefix .. "{", ... );
						TablePrint( v, indent+4, func, ... );
						func( strPrefix .. "}" .. ",", ... );
					end
				else
					func( strPrefix .. tostring(k) .. " = " .. tostring(v) .. ",", ... );
				end
			end
		end
	else
		func( strPrefix .. tostring(t) .. ",", ... );
	end
	if 0 == indent then
		func( "", ... );
	end
end

function getSchoolByName(school)
	if not school or tonumber(school) < 1 or tonumber(school) >3 then
		return ""
	end

	local numSchool = tonumber(school)
	if numSchool == 1 then
		return game.getStrByKey("zhanshi")
	elseif numSchool == 2 then
		return game.getStrByKey("fashi")
	elseif numSchool == 3 then
		return game.getStrByKey("daoshi")
	end
	return ""
end

function addStrToTabIfNotExist(tab,str)
    local exist = false
    for k,v in pairs(tab) do
        if v == str then
            exist = true
            break
        end
    end
    if not exist then
        table.insert(tab,str)
    end
    return tab
end

function delStrFromTabIfExist(tab,str)
    local index = 1
    for k,v in pairs(tab) do
        if v == str then
            table.remove(tab,index)
            break
        end
        index = index + 1
    end
    return tab
end

--奖励统用面板
function Awards_Panel( params )
	local params = params or {}
	local award_tip = params.award_tip or ""	--奖励下方简短文字
	local isGet = true  						--是否可以领取
	if params.isGet ~= nil then isGet = params.isGet end

	local getCallBack = params.getCallBack 		--领取按钮回调
	local awards = params.awards  				--奖励物品

	if awards == nil then return end


	local tempLayer = popupBox({ 
					               isMask = true ,
					               zorder = 200 , 
					               actionType = 1 ,
					             })
    tempLayer:registerScriptHandler(function(event)
		if event == "enter" then
		elseif event == "exit" then
			if getCallBack and isGet then
                getCallBack()
            end
		end
	end)

	local bg = createSprite( tempLayer , "res/common/shadow/award_bg.png" , cc.p( display.cx , 180 ) , cc.p( 0.5 , 0 ) )
	createSprite( bg , "res/common/shadow/award_title.png" , cc.p( bg:getContentSize().width/2 , 250 ) , cc.p( 0.5 , 0 ) )

	local bgSize = bg:getContentSize()
	createLabel( bg , award_tip , cc.p( bgSize.width/2  , 210 ) , cc.p( 0.5 , 0.5 ) , 24 , true)
	-- createLabel( bg , game.getStrByKey("get_awards_tip") , cc.p( bgSize.width/2  , 60 ) , cc.p( 0.5 , 0.5 ) , 20 , nil , nil , nil , MColor.lable_black , nil , nil)

	local function clickFun()
	    tempLayer:close()
	    --if getCallBack and isGet then getCallBack() end
	end

	
	
    -- local menuitem = createMenuItem( bg , "res/component/button/50.png" , cc.p( bgSize.width/2 , -50  ) , clickFun )
    createLabel( bg , game.getStrByKey( "click_tips" )  , cc.p( bgSize.width/2 , -50  ) , cc.p( 0.5 , 0.5 ) , 25 , true , nil , nil , MColor.white , nil , nil , MColor.black , 3)

    if tablenums( awards ) > 0 then
        local width = 450
        local scrollView1 = cc.ScrollView:create()
        scrollView1:setViewSize(cc.size( width , 180 ) )
        scrollView1:setPosition( cc.p(  bgSize.width/2 , bgSize.height/2 - 80  ) )
        scrollView1:ignoreAnchorPointForPosition(false)

        local groupAwards =  __createAwardGroup( awards , nil , 85 , 0 , false , 0 )
        setNodeAttr( groupAwards , cc.p( 0 , 37 ) , cc.p( 0 , 0 ) )

        scrollView1:setContainer( groupAwards )
        scrollView1:updateInset()

        scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL )
        scrollView1:setClippingToBounds(true)
        scrollView1:setBounceable(true)
        scrollView1:setDelegate()
        bg:addChild(scrollView1)
        local isAlone = groupAwards:getContentSize().width < width - 20
        if isAlone then
            scrollView1:setTouchEnabled( false )
            scrollView1:setContentOffset( cc.p( ( width - groupAwards:getContentSize().width )/2 , 40 ) )
        else
            scrollView1:setTouchEnabled( true )
        end    
        registerOutsideCloseFunc( groupAwards , clickFun , isAlone )
    end

    -- registerOutsideCloseFunc( tempLayer , function() if getCallBack then getCallBack() end removeFromParent(tempLayer) tempLayer = nil end , true , true )
    return tempLayer , tempLayer:getCloseBtn() , menuitem
end

function sendTssdkAntiData(strData)
    g_msgHandlerInst:sendNetDataByTableEx(TSSDK_CS_RECVANTIDATA, "TssdkRecvAntiDataProtocol", {dataSize=#strData,data=strData});
end

function checkLocalKeyTime(strKey, type)
	local ret = true
	local time = getLocalRecordByKey(1, strKey)
	if time and time ~= 0 then
		local time1 = os.date("*t", time)
		local time2 = os.date("*t")

		if (type == 1 or nil == type) and time1.year == time2.year and time1.month == time2.month and time1.day == time2.day then
			ret = false
		end
	end

	if ret then
		setLocalRecordByKey(1, strKey, os.time())
	end

	return ret
end


function resetGmainSceneTime(back_time)
	if G_MAINSCENE and G_UPDATE_TIME_SPAN then
		local back_time = back_time or 1
		local now_time = G_MAINSCENE.t_time%G_UPDATE_TIME_SPAN
		G_MAINSCENE.t_time = G_MAINSCENE.t_time - now_time	- back_time
	end
end

function theSameColor( col1, col2)
	if nil == col1 or nil == col2 then
		return false
	end

	if nil == col1.r or nil == col1.g or nil == col1.b then
		return false
	end

	if nil == col2.r or nil == col2.g or nil == col2.b then
		return false
	end

	if col1.r == col2.r and
	   col1.g == col2.g and
	   col1.b == col2.b then
	   return true
	end
	return false
end

function checkIfSecondaryPassNeed(callback)
    local secondaryPass = require("src/layers/setting/SecondaryPassword")
    local result = secondaryPass.isSecPassChecked()
    if result then
        if callback then
            callback()
        end
    else
        secondaryPass.inputPassword()
    end

    return result
end
--格式化奖励数据
function FORMAT_AWARDS( _awards  )
	local awardNum = #_awards       --奖励个数
	local awards = {}

	for j = 1 , awardNum do
	    awards[j] = {}
	    awards[j]["id"] = _awards[j].itemID            --奖励ID
	    awards[j]["num"] = _awards[j].count           --奖励个数
        awards[j]["showBind"] = true;
	    awards[j]["isBind"] = _awards[j].bind       --绑定(1绑定0不绑定)
	    awards[j]["streng"] = _awards[j].strength        --强化等级
	    awards[j]["time"] = _awards[j].timeLimit          --限时时间
	end

	return awards
end

function getMemNameFromTeam(roleId)
    local memName = nil
    for k,v in pairs(G_TEAM_INFO.team_data) do
        if v.roleId == roleId then
            memName = v.name
            break
        end
    end
    return memName
end

function payNetLoading(isAdd)
	local nodeName = "payNetLoadingNode"
	local currScene = Director:getRunningScene()
	if isAdd then
		if not currScene:getChildByName(nodeName) then
			local tempNode = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
			tempNode:setName(nodeName)
			currScene:addChild(tempNode, 600)
			
			local spr = createSprite(tempNode, "res/layers/pay/loading.png", g_scrCenter)

			local runeffect = Effects:create(false)
			runeffect:playActionData("loading", 6, 0.6, -1)
			runeffect:setAnchorPoint(cc.p(0.5,0.0))
			spr:addChild(runeffect, 2)
			runeffect:setPosition(cc.p(150,10))

			SwallowTouches(tempNode)
		end
	else
		if currScene:getChildByName(nodeName) then
			currScene:removeChildByName(nodeName)
		end
	end
end

function getNextGoPos( pos ,  pathCfg )
	if pathCfg == nil or pos == nil then
		return nil
	end
	local next_pos = pos
	local pos_index = 0
	local span_pos = 0
	local first_pos = nil
	
	for k,v in ipairs(pathCfg)do
		if pathCfg[k-1] then
			local max_x,max_y,min_x,min_y = 0,0,0,0
			if pathCfg[k].x > pathCfg[k-1].x then
				max_x = pathCfg[k].x
				min_x = pathCfg[k-1].x
			else
				max_x = pathCfg[k-1].x
				min_x = pathCfg[k].x
			end
			if pathCfg[k].y > pathCfg[k-1].y then
				max_y = pathCfg[k].y
				min_y = pathCfg[k-1].y
			else
				max_y = pathCfg[k-1].y
				min_y = pathCfg[k].y
			end
			if pos.x >= min_x and pos.y >= min_y and pos.x <= max_x and pos.y <= max_y then
				pos_index = k
				span_pos = math.max(math.abs(v.x-pos.x),math.abs(v.y-pos.y))
				break
			end
		end
	end

	if pos_index > 0 then next_pos = pathCfg[pos_index+1] end
	return next_pos
end	
--邀请好友
function INVITE_FIRENDS()
     local platform = sdkGetPlatform()
     if platform == 1 then
         if not isWXInstalled() then
             TIPS({type =1 ,str = game.getStrByKey("friend_share_fail_wx2")})
             return
         end
     else
         if not isQQInstalled() then
             TIPS({type =1 ,str = game.getStrByKey("friend_share_fail_qq2")})
             return
         end
     end
     
     local title = game.getStrByKey("friend_share_title")
     local desc = game.getStrByKey("friend_share_desc")
     local file = "res/layers/friend/icon.png"
     
     local imageUrl = "http://game.gtimg.cn/images/cqsj/m/m201604/web_logo.png"
     
     
     if platform == 1 then
         sdkShareWeixin(title, desc, "MSG_INVITE", file, 0, "extend")
     elseif platform == 2 then
         if Device_target == cc.PLATFORM_OS_ANDROID then
            local url = string.format("http://gamecenter.qq.com/gcjump?appid={1105148805}&pf=invite&from=androidqq&plat=qq&originuin=" .. sdkGetOpenId() .. "&ADTAG=gameobj.msg_invite")
             sdkShareQQ(2, title, desc, url, imageUrl, string.len(imageUrl))
         else
            local url = string.format("http://gamecenter.qq.com/gcjump?appid={1105148805}&pf=invite&from=iphoneqq&plat=qq&originuin=" .. sdkGetOpenId() .. "&ADTAG=gameobj.msg_invite")
             sdkShareQQ(2, title, desc, url, file, 0)
         end
     end
end

--组合字体特效
--1结义  2战队  3师徒
function playCommonFontEffect(type)
	local x = display.cx
	local y = display.cy 
	local padding = 90
	local timePadding = 0.05
	local scaleStart = 2
	local scaleHalf = 1
	local scaleStop = 1.2
	local timeToHalf = 0.1
	local timeToStop = 0.35
	local effectTime = 0.5

	local baseNode = cc.Node:create()
	getRunScene():addChild(baseNode, 200)
	baseNode:setPosition(cc.p(x, y))

	local path = 
	{
		"res/text/fontEffect/1/",
		"res/text/fontEffect/2/",
		"res/text/fontEffect/3/",
	}

	local pos = 
	{
		cc.p(-1.5*padding, 0),
		cc.p(-0.5*padding, 0),
		cc.p(0.5*padding, 0),
		cc.p(1.5*padding, 0),
	}

	local fontSprTab = {}

	for i=1,4 do
		local fontSpr = createSprite(baseNode, path[type]..i..".png", pos[i], cc.p(0.5, 0.5))
		table.insert(fontSprTab, fontSpr) 
		fontSpr:runAction(
			cc.Sequence:create(
					cc.CallFunc:create(function() fontSpr:setScale(scaleStart) fontSpr:setOpacity(0) end),
					cc.DelayTime:create(timePadding*(i-1)),
					cc.CallFunc:create(function() fontSpr:setOpacity(255) end),
					cc.ScaleTo:create(timeToHalf, scaleHalf),
					--cc.DelayTime:create(0.3),
					cc.CallFunc:create(function()
							if i == 4 then
								for i,v in ipairs(fontSprTab) do
									v:runAction(
										cc.Sequence:create(
											cc.DelayTime:create(0.65),
											cc.Spawn:create(cc.ScaleTo:create(timeToStop, scaleStop), cc.FadeOut:create(timeToStop))
											)
										)--, cc.FadeOut:create(timeToStop+0.3)
								end
							end

							--startTimerAction(baseNode, 0.3, false, function() 
									-- local effect = Effects:create(false)
									-- effect:playActionData("ceremony", 13, 1.3, 1)
									-- addEffectWithMode(effect, 1)
									-- baseNode:addChild(effect)
									-- effect:setAnchorPoint(cc.p(0.5, 0.5))
									-- effect:setPosition(cc.p(0, 0))
								--end)							
						end),
					cc.CallFunc:create(function()
							if i == 2 then
								local effect = Effects:create(false)
								effect:playActionData("ceremony", 13, 0.8, 1)
								addEffectWithMode(effect, 1)
								baseNode:addChild(effect)
								effect:setAnchorPoint(cc.p(0.5, 0.5))
								effect:setPosition(cc.p(0, 0))
							end						
						end)
				)
		)
	end

	startTimerAction(baseNode, 3, false, function() removeFromParent(baseNode) end)
end

function CommonSocketClose()
	--try()
	LuaSocket:getInstance():closeSocket()
end

function setRoleInfo(delType,staticRoleId, lv, school, Name,serverId)
	local tempServerId = serverId or userInfo.serverId
	local key = "userRoleData" .. sdkGetOpenId() .. "serverId"..tempServerId 
	if delType == 1 then
		local str = getLocalRecordByKey(2, key, "")
		local tempRole = unserialize(str)
		if #tempRole > 2 then
			local lastRole = 1
			local lv = 100
			for k,v in pairs(tempRole) do
				if v.lv < lv then
					lv = v.lv
					lastRole = k
				end
			end
			table.remove(tempRole, k)
		end
		return tempRole
	elseif delType == 2 then
		local str = getLocalRecordByKey(2, key, "")
		local tempTab = unserialize(str)
		for k,v in pairs(tempTab) do
			if v.name == Name then
				table.remove(tempTab, k)
				break
			end
		end
		setLocalRecordByKey(2, key, serialize(tempTab))
	elseif delType == 3 then
		local str = getLocalRecordByKey(2, key, "")
		local tempTab = unserialize(str)
		local findFlg = false
		for k,v in pairs(tempTab) do
			if v.roleid == staticRoleId then
				v.lv = lv
				findFlg = true
				break
			end
		end		


		if not findFlg and tablenums(tempTab) < 3 then
			table.insert(tempTab, {roleid = staticRoleId, lv = lv, school = school, name = Name})
		end
		setLocalRecordByKey(2, key, serialize(tempTab))
	elseif delType == 4 then
		setLocalRecordByKey(2, key, "")
	end
end

function addSpecialPrivate(text1, text2, usrName, callback)
	local commConst = require("src/config/CommDef")
	
	local currRecord = { channelId = 1 }
	--currRecord.time = time
	
	currRecord.text = text1
	currRecord.textEx = text2
    currRecord.usrName = usrName
	currRecord.isSpecialPrivate = true
	currRecord.callback = callback

    if not(currRecord.text and currRecord.text~="") then
        return
    end
	if not G_CHAT_INFO[1] then G_CHAT_INFO[1]={} end
	if #G_CHAT_INFO[1] >= 30 then table.remove(G_CHAT_INFO[1],1) end
	G_CHAT_INFO[1][#G_CHAT_INFO[1]+1] = currRecord
        
    if not G_CHAT_INFO[11] then G_CHAT_INFO[11]={} end
    if #G_CHAT_INFO[11] >= 30 then table.remove(G_CHAT_INFO[11],1) end
    G_CHAT_INFO[11][#G_CHAT_INFO[11]+1] = currRecord

    if not G_MAINSCENE then
        return
    end
	
	if G_CHAT_INFO.unReadPrivateRecord == nil then G_CHAT_INFO.unReadPrivateRecord = 0 end
	G_CHAT_INFO.unReadPrivateRecord = G_CHAT_INFO.unReadPrivateRecord + 1
	G_MAINSCENE:updateChatStartBtn()
	local chatLayer =getRunScene():getChildByTag(305)
	if chatLayer then 
		chatLayer:updateDisplayData(currRecord.channelId)
		chatLayer:updatePrivateBtn()
	end
    if G_CHAT_INFO.chatPanel and G_CHAT_INFO.chatPanel.addChatMsg then
	    G_CHAT_INFO.chatPanel:addChatMsg(currRecord.usrName, currRecord.text, currRecord.usrId, true, currRecord.vipLvl,currRecord.type==3, currRecord.channelId)
	end
end

function getFactionCapturedMap(factionId)
	local ret = { 0, 0, 0}

	if factionId == nil or factionId == 0 then 
		return ret
	end
	
	if G_EMPIRE_INFO and G_EMPIRE_INFO.CAPTURED_INFO then
		for k,v in pairs(G_EMPIRE_INFO.CAPTURED_INFO) do
			if v.facId ~= 0 and v.facId == factionId then
				if k == 1 then  --中州
					ret[2] = 1
				else            --领地
					ret[1] = 1
				end
			end
		end
	end

	if G_SHAWAR_DATA and G_SHAWAR_DATA.startInfo and G_SHAWAR_DATA.startInfo.DefenseID then
		if factionId == G_SHAWAR_DATA.startInfo.DefenseID then
			ret[3] = 1           --沙城
		end
	end

	return ret
end

function gotoActivityDescUI( intro )
	local cfgs = getConfigItemByKey( "ActivityNormalDB" , "q_id"  )
    for k,v in pairs(cfgs) do
        if v.q_intro == intro then
            require( "src/layers/battle/DescLayer" ).new( v )
            return
        end
    end
end

function checkSkillRed()	
	local pack = MPackManager:getPack(MPackStruct.eBag)
	local roleLv = MRoleStruct:getAttr(ROLE_LEVEL) or 0	
	local isRed = false
	if G_ROLE_MAIN and G_ROLE_MAIN.skills then
		for k,v in pairs(G_ROLE_MAIN.skills) do
			local skillCfg = getConfigItemByKey("SkillCfg","skillID",v[1])
			local SkillLevelCfg = getConfigItemByKey("SkillLevelCfg","skillID",v[1]*1000+v[2])
			local skillSld = SkillLevelCfg.sld
			local skillDJXZ = SkillLevelCfg.djxz or 0
			local jjjn = SkillLevelCfg.jjjn  --技能灵丹
			if jjjn and skillCfg.maxlv and jjjn == 2015 and v[2] < skillCfg.maxlv and roleLv >= skillDJXZ then
				local num = pack:countByProtoId(jjjn)   				
				local curSld = v[4] or 0
				local propNum = (math.ceil(skillSld/100)-math.floor(curSld/100))	
				if propNum <= num then					
					G_SKILL_REDCHECK[1][v[1]] = true
					if G_MAINSCENE and G_MAINSCENE.red_points then
						isRed = true
						if G_SKILL_REDCHECK[3] and G_SKILL_REDCHECK[3] < 1 then
							G_MAINSCENE.red_points:insertRedPoint(4, 2)
							G_SKILL_REDCHECK[3] = 1
						end
					end
				else
					G_SKILL_REDCHECK[1][v[1]] = false
				end
			else
				G_SKILL_REDCHECK[1][v[1]] = false
			end
		end
	end
	if not isRed then
		for k,v in pairs(G_SKILL_REDCHECK[2]) do
			if v then
				isRed = true
				break
			end
		end		
	end
	if not isRed then
		G_MAINSCENE.red_points:removeRedPoint(4, 2)
	end
end

function checkWingSkillRed()
	local pack = MPackManager:getPack(MPackStruct.eBag)
	local roleLv = MRoleStruct:getAttr(ROLE_LEVEL) or 0
	local isRed = false
	if G_ROLE_MAIN.wingskills then
		for k,v in pairs(G_ROLE_MAIN.wingskills) do
			local skillCfg = getConfigItemByKey("SkillCfg","skillID",v[1])
			local SkillLevelCfg = getConfigItemByKey("SkillLevelCfg","skillID",v[1]*1000+v[2])
			local skillSld = SkillLevelCfg.sld
			local jjjn = SkillLevelCfg.jjjn or 6200091 --技能灵丹
			if jjjn == 6200091 and v[2] < skillCfg.maxlv then
				local num = pack:countByProtoId(jjjn)   
				local curSld = v[4] or 0
				local propNum = (math.ceil(skillSld/100)-math.floor(curSld/100))	
				if propNum <= num then					
					G_SKILL_REDCHECK[2][v[1]] = true
					if G_MAINSCENE and G_MAINSCENE.red_points then
						isRed = true
						if G_SKILL_REDCHECK[3] and G_SKILL_REDCHECK[3] < 1 then
							G_MAINSCENE.red_points:insertRedPoint(4, 2)
							G_SKILL_REDCHECK[3] = 1
						end
					end
				else
					G_SKILL_REDCHECK[2][v[1]] = false
				end
			else
				G_SKILL_REDCHECK[2][v[1]] = false
			end
		end
	end
	if not isRed then
		for k,v in pairs(G_SKILL_REDCHECK[1]) do
			if v then
				isRed = true
				break
			end
		end		
	end
	if not isRed then
		G_MAINSCENE.red_points:removeRedPoint(4, 2)
	end
end

function addFBTipsEffect(parent, pos, filename)
    if parent == nil then
        return
    end

    local pic = createSprite(parent, filename , pos, cc.p( 0.5, 0.5 ) )  
    pic:setScale(2)
    pic:setOpacity(0)

    local actions = { }
    actions[#actions + 1] = cc.ScaleTo:create(0.15, 0.9)
    actions[#actions + 1] = cc.ScaleTo:create(0.05, 1.0)
    actions[#actions + 1] = cc.DelayTime:create(1.5)
    actions[#actions + 1] = cc.ScaleTo:create(0.1, 1.5)
    actions[#actions + 1] = cc.CallFunc:create( function() removeFromParent(pic) end )
    pic:runAction(cc.Sequence:create(actions))

    local actions2 = { }
    actions2[#actions2 + 1] = cc.FadeTo:create(0.15, 255)
    actions2[#actions2 + 1] = cc.DelayTime:create(1.55)
    actions2[#actions2 + 1] = cc.FadeTo:create(0.15, 0)
    pic:runAction(cc.Sequence:create(actions2))
end

function isForgeMaterialEnough(forge_protoId, school)
    --认为打造和合成的生成的道具列表不会重叠
    local forge = require("src/config/Forge")
    local q_forgeCost
    for k_forge, v_forge in pairs(forge) do
        while true do
            local table_item = assert(loadstring("return " .. v_forge.q_itemID))()
            local bool_item_more_than_one = false
            for k_forgable_item, v_forgable_item in pairs(table_item) do
                if table.size(v_forgable_item) > 1 then
                    bool_item_more_than_one = true
                    break
                end
            end
            for k_forgable_item, v_forgable_item in pairs(bool_item_more_than_one and table_item[school] or table_item[1]) do
                if k_forgable_item == forge_protoId then
                    q_forgeCost =  assert(loadstring("return " .. v_forge.q_forgeCost))()
                    break
                end
            end
            break
        end
    end
    local bool_enough = true
    for item_id, item_count in pairs(q_forgeCost) do
        if item_id == 777777 and item_count > MRoleStruct:getAttr(PLAYER_VITAL) then--声望
            bool_enough = false
            break
        end
        if item_id == 999998 and item_count > MRoleStruct:getAttr(PLAYER_MONEY) then--金币
            bool_enough = false
            break
        end
        if item_id ~= 999998 and item_id ~= 777777 and item_count > MPackManager:getPack(MPackStruct.eBag):countByProtoId(item_id) then--道具:除了以上两种材料，其他都认为是道具，如果有不同的情况，程序崩溃，到时扩展程序
            bool_enough = false
            break
        end
    end
    return bool_enough
end