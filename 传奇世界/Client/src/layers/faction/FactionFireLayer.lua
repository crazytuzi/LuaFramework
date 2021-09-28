local FactionFireLayer = class("FactionFireLayer", function() return cc.Layer:create() end)

local path = "res/faction/"

function FactionFireLayer:ctor()
	local msgids = {FACTIONAREA_SC_GET_WOOD_NUM_RET}
	require("src/MsgHandler").new(self, msgids)

	--g_msgHandlerInst:sendNetDataByFmtExEx(FACTIONAREA_CS_GET_WOOD_NUM, "ii", G_ROLE_MAIN.obj_id, require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID))
	g_msgHandlerInst:sendNetDataByTableExEx(FACTIONAREA_CS_GET_WOOD_NUM, "FactionAreaGetWoodNumProtocol", {})
	addNetLoading(FACTIONAREA_CS_GET_WOOD_NUM, FACTIONAREA_SC_GET_WOOD_NUM_RET)

	self.data = {}

	local bg = createSprite(self, "res/common/bg/bg18.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
 	local rootSize = bg:getContentSize()
	-- 背景图
	createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(33, 17),
       	cc.size(rootSize.width-60, rootSize.height-74),
        5
    )

	local closeBtnFunc = function() 
	    removeFromParent(self)
	end
	local closeBtn = createMenuItem(bg, "res/component/button/x2.png", cc.p(bg:getContentSize().width-35, bg:getContentSize().height-25), closeBtnFunc)

	createSprite(bg, path.."fire.png", cc.p(bg:getContentSize().width/2, 243), cc.p(0.5, 0))

	createLabel(bg, game.getStrByKey("faction_fire_title"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-25), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.lable_yellow)

	local richText = require("src/RichText").new(bg, cc.p(35, 240), cc.size(750, 30) , cc.p(0, 1), 30, 20, MColor.lable_black)
  	richText:addText(game.getStrByKey("faction_fire_content"), MColor.lable_black, true)
  	richText:format()

  	local richText = require("src/RichText").new(bg, cc.p(35, 70), cc.size(750, 30) , cc.p(0, 0.5), 22, 22, MColor.lable_black)
  	richText:addText(game.getStrByKey("faction_time_tip"), MColor.lable_black, true)
  	richText:format()

  	local function onShareToFactionGroup(factionID)
        local title = "兄弟们该上线了！"
        local desc = "行会篝火即将开启，赶快来驻地参加活动吧！"
        local urlIcon = "http://game.gtimg.cn/images/cqsj/m/m201604/web_logo.png"
        sdkSendToWXGroup(1, 1, factionID, title, desc, "MessageExt", "MSG_INVITE", urlIcon, "")
    end

    local function shareToFactionGroup(factionID)
        if isWXInstalled() then
        	local isInWXGroup = getGameSetById(GAME_SET_ISINWXGROUP)
            if isInWXGroup == 1 then
                onShareToFactionGroup(factionID)
                --TIPS({ type = 1  , str = game.getStrByKey("faction_wxgroup_sendMSGtoGroup") })
            else
                --TIPS({ type = 1  , str = game.getStrByKey("faction_wxgroup_notInWXgroup") })
            end
        else
            --TIPS({ type = 1  , str = game.getStrByKey("faction_wxgroup_noInstalledWX") })
        end
    end

  	local openBtnFunc = function() 
  		if G_FACTION_INFO and G_FACTION_INFO.fireData and G_FACTION_INFO.fireData.state == 3 then
		    self:showMessageBox(self.data.time)
		else
			--g_msgHandlerInst:sendNetDataByFmtExEx(FACTIONAREA_CS_OPEN_FIRE, "ii", G_ROLE_MAIN.obj_id, require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID))
			local t = {}
			t.factionID = require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)
			g_msgHandlerInst:sendNetDataByTableExEx(FACTIONAREA_CS_OPEN_FIRE, "FactionAreaOpenFireProtocol", t)
			shareToFactionGroup(t.factionID)
		    removeFromParent(self)
		end
	end
	local openBtn = createMenuItem(bg, "res/component/button/50.png", cc.p(700, 70), openBtnFunc)
	self.openBtn = openBtn
	self.openBtnLabel = createLabel(openBtn, game.getStrByKey("faction_open_fire"), getCenterPos(openBtn), cc.p(0.5, 0.5), 22, true)
	dump(G_FACTION_INFO)
	if G_FACTION_INFO then
		if G_FACTION_INFO.fireData and G_FACTION_INFO.fireData.state == 3 then
			self.openBtnLabel:setString(game.getStrByKey("faction_add_fire"))
		end
	end

	registerOutsideCloseFunc(bg, function() closeBtnFunc() end, true)
end

function FactionFireLayer:showMessageBox(time)
	local function yesCallback()
		--g_msgHandlerInst:sendNetDataByFmtExEx(FACTIONAREA_CS_ADD_WOOD, "ii", G_ROLE_MAIN.obj_id, require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID))
		if self.data.time > 0 then
			local t = {}
			t.factionID = require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)
			g_msgHandlerInst:sendNetDataByTableExEx(FACTIONAREA_CS_ADD_WOOD, "FactionAreaAddWoodProtocol", t)
			removeFromParent(self)
		else
			TIPS({str = game.getStrByKey("faction_add_time_zero_tip"), type = 1})
			removeFromParent(self)
		end
	end

	local function noCallback()

	end
	local str = string.format(game.getStrByKey("faction_add_time_tip"), time)
	local bg = MessageBoxYesNo(nil, game.getStrByKey("faction_add_content"), yesCallback, noCallback)

	local richText = require("src/RichText").new(bg, cc.p(bg:getContentSize().width/2, 100), cc.size(150, 30) , cc.p(0.5, 0.5), 20, 20, MColor.lable_yellow)
  	richText:addText(str, MColor.lable_yellow, true)
  	richText:format()
end

function FactionFireLayer:networkHander(buff, msgid)
	local switch = {
		[FACTIONAREA_SC_GET_WOOD_NUM_RET] = function()    
			log("get FACTIONAREA_SC_GET_WOOD_NUM_RET") 
			local t = g_msgHandlerInst:convertBufferToTable("FactionAreaGetWoodNumRetProtocol", buff)
			local time = t.count
			local isTime = t.isTime
			local isLeader = t.isLeader
			--dump(isTime)
			dump(time)
			self.data.time = time

			-- if G_FACTION_INFO.fireData then
			-- 	if G_FACTION_INFO.fireData.state ~= 3 then
			-- 		if isLeader ~= true then
			-- 			--self.openBtn:setVisible(false)
			-- 			self.openBtn:setEnabled(false)
			-- 		end
			-- 	else
			-- 		self.openBtn:setEnabled(true)
			-- 	end
			-- end

			-- if time > 0 then

			-- else
			-- 	if G_FACTION_INFO.fireData and G_FACTION_INFO.fireData.state == 3 then
			-- 		self.openBtn:setEnabled(false)
			-- 	end
			-- end
			dump(G_FACTION_INFO.fireData.state)
			if G_FACTION_INFO.fireData.state then
				if G_FACTION_INFO.fireData.state and G_FACTION_INFO.fireData.state == 0 then
					self.openBtnLabel:setString(game.getStrByKey("faction_fire_time_error"))
					self.openBtn:setEnabled(false)
				elseif G_FACTION_INFO.fireData.state == 1 then
					if isLeader ~= true then
						self.openBtn:setEnabled(false)
					end
				elseif G_FACTION_INFO.fireData.state == 2 then
					self.openBtnLabel:setString(game.getStrByKey("faction_fire_time_pre"))
					self.openBtn:setEnabled(false)
				elseif G_FACTION_INFO.fireData.state == 3 then
					if time <= 0 then
						self.openBtn:setEnabled(false)
					end
				elseif G_FACTION_INFO.fireData.state == 4 then
					self.openBtn:setEnabled(false)
				end
			end

			-- if isTime ~= true then
			-- 	self.openBtnLabel:setString(game.getStrByKey("faction_fire_time_error"))
			-- 	self.openBtn:setEnabled(false)
			-- end
			dump(self.data)
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return FactionFireLayer