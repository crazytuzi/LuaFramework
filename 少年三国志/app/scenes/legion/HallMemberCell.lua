--HallMemberCell.lua

require("app.cfg.knight_info")

local EffectNode = require "app.common.effects.EffectNode"

local HallMemberCell = class("HallMemberCell", function ( ... )
	return CCSItemCellBase:create("ui_layout/legion_HallMemberItem.json")
end)

function HallMemberCell:ctor( ... )
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
end

function HallMemberCell:_getTime( time )
    local t = G_ServerTime:getTime() - time
    local str
    if time == 0 then 
        str = G_lang:get("LANG_FRIEND_ONLINE1")
        return str
    end

    local min=math.floor(t/60)
    local hour=math.floor(min/60)
    local day=math.floor(hour/24)
    if day >= 1 then 
        str = G_lang:get("LANG_FRIEND_ONLINE2", {time=day})
    elseif hour >= 1 then 
        str = G_lang:get("LANG_FRIEND_ONLINE3", {time=hour})
    else
        if min == 0 then
            min = 1
        end
        str = G_lang:get("LANG_FRIEND_ONLINE4", {time=min})
    end
    return str
end

function HallMemberCell:updateItem( memberInfo )
	
	self:showTextWithLabel("Label_level_value", memberInfo and memberInfo.level or 0)
	self:showTextWithLabel("Label_fight_num_value", GlobalFunc.ConvertNumToCharacter4(memberInfo and memberInfo.fight_value or 0))
	self:showTextWithLabel("Label_total_contribution_value", memberInfo and memberInfo.total_contribute or 0)
	self:showTextWithLabel("Label_today_contribution_value", memberInfo and memberInfo.worship_exp or 0)
    self:showWidgetByName("Image_vip", memberInfo and memberInfo.vip > 0)

    local panel1Back = self:getPanelByName("Panel_Root")
    local panel2Back = self:getPanelByName("Panel_info")
    if memberInfo and memberInfo.id == G_Me.userData.id then 
        panel1Back:setBackGroundImage("board_red.png",UI_TEX_TYPE_PLIST)
        panel2Back:setBackGroundImage("list_board_red.png",UI_TEX_TYPE_PLIST)
    else
        panel1Back:setBackGroundImage("board_normal.png",UI_TEX_TYPE_PLIST)
        panel2Back:setBackGroundImage("list_board.png",UI_TEX_TYPE_PLIST)
    end

	local img = self:getImageViewByName("Image_member_type")
    if img then 
        img:loadTexture(G_Path.getLegionMemberPosition(memberInfo and memberInfo.position or 0))
    end

    local knightBaseInfo = nil
	knightBaseInfo = knight_info.get(memberInfo and memberInfo.main_role or 0)

	local icon = self:getImageViewByName("Image_icon")
	if icon ~= nil then
        local resId = knightBaseInfo and knightBaseInfo.res_id or 0
        if memberInfo and memberInfo.id == G_Me.userData.id then 
            resId = G_Me.dressData:getDressedPic()
        else
            resId = G_Me.dressData:getDressedResidWithClidAndCltm(memberInfo.main_role, memberInfo.dress_id,
                memberInfo.clid,memberInfo.cltm,memberInfo.clop)
        end
		local heroPath = G_Path.getKnightIcon(resId)
    	icon:loadTexture(heroPath, UI_TEX_TYPE_LOCAL) 
	end

	local pingji = self:getImageViewByName("Image_pingji")
	if pingji then
    	pingji:loadTexture(G_Path.getAddtionKnightColorImage(knightBaseInfo and knightBaseInfo.quality or 1))  
    end

    local name = self:getLabelByName("Label_name")
	if name ~= nil then
		name:setColor(Colors.qualityColors[knightBaseInfo and knightBaseInfo.quality or 1])
		name:setText(memberInfo and memberInfo.name or "")
	end

	local online = memberInfo and memberInfo.online or 0
	self:showTextWithLabel("Label_online_status", G_GlobalFunc.getOnlineTime(online))
	local label = self:getLabelByName("Label_online_status")
    if online == 0 then
        label:setColor(Colors.lightColors.TIPS_01)
    else
    	label:setColor(Colors.lightColors.TIPS_02)
    end

    local detailCorp = G_Me.legionData:getCorpDetail() 

    local _onHeaderClick = function ( ... )
    	if memberInfo then 
    		self:_onMemberHeadClick(memberInfo.id, memberInfo.name)
    	end
    end
    local _onTanheClick = function ( ... )
    	if memberInfo then 
    		self:_onTanheClick(memberInfo.id, online, detailCorp and detailCorp.position)
    	end
    end
    local _onDismissClick = function ( ... )
    	if memberInfo then 
    		self:_onDismissClick(memberInfo.id, memberInfo.name, memberInfo.join_corp_time)
    	end
    end
    local _onChangPositionClick = function ( ... )
    	if memberInfo then 
    		self:_onChangPositionClick(memberInfo.id, memberInfo.position, memberInfo.name)
    	end
    end
    local _onQuitClick = function ( ... )
    	if memberInfo then 
    		self:_onQuitClick(memberInfo.position, memberInfo.join_corp_time)
    	end
    end
    self:registerWidgetClickEvent("Image_member", _onHeaderClick)

    local _loadAndShowBtn = function ( btnName, textName, resName )
    	local img = self:getImageViewByName(textName)
    	if img then 
    		img:loadTexture(resName, UI_TEX_TYPE_LOCAL)
    	end
    	self:showWidgetByName(btnName, true)
    end

    
    if not detailCorp then 
    	self:showWidgetByName("Button_fun_middle", false)
    	self:showWidgetByName("Button_fun_up", false)
    	self:showWidgetByName("Button_fun_down", false)
    	return 
    end

    local LOOKAT_RES = "ui/text/txt-small-btn/chakan.png"
    local EXIT_RES = "ui/text/txt-small-btn/jt_tuichu.png"
    local RENGMING_RES = "ui/text/txt-small-btn/renming_1.png"
    local DISMISS_RES = "ui/text/txt-small-btn/tichu.png"
    local TANHE_RES = "ui/text/txt-small-btn/jt_tanhe.png"

    local memberPosition = memberInfo and memberInfo.position or 0

    if detailCorp.position == memberPosition then 
    	if memberInfo and memberInfo.id == G_Me.userData.id then
    		_loadAndShowBtn("Button_fun_middle", "Image_middle", EXIT_RES)
    		self:registerWidgetClickEvent("Button_fun_middle", _onQuitClick)
    	else
    		_loadAndShowBtn("Button_fun_middle", "Image_middle", LOOKAT_RES)
    		self:registerWidgetClickEvent("Button_fun_middle", _onHeaderClick)
    	end
    	self:showWidgetByName("Button_fun_up", false)
    	self:showWidgetByName("Button_fun_down", false)
    elseif detailCorp.position == 1 then 
    	_loadAndShowBtn("Button_fun_up", "Image_up", RENGMING_RES)
    	self:registerWidgetClickEvent("Button_fun_up", _onChangPositionClick)
    	_loadAndShowBtn("Button_fun_down", "Image_down", DISMISS_RES)
    	self:registerWidgetClickEvent("Button_fun_down", _onDismissClick)
    	self:showWidgetByName("Button_fun_middle", false)
    elseif detailCorp.position == 2 then
    	_loadAndShowBtn("Button_fun_up", "Image_up", LOOKAT_RES)
    	self:registerWidgetClickEvent("Button_fun_up", _onHeaderClick)
    	if memberPosition == 1 then
    		_loadAndShowBtn("Button_fun_down", "Image_down", TANHE_RES)
    		self:registerWidgetClickEvent("Button_fun_down", _onTanheClick)
    	else
    		_loadAndShowBtn("Button_fun_down", "Image_down", DISMISS_RES)
    		self:registerWidgetClickEvent("Button_fun_down", _onDismissClick)
    	end
    	self:showWidgetByName("Button_fun_middle", false)
    else
    	if memberPosition == 1 then 
    		_loadAndShowBtn("Button_fun_up", "Image_up", LOOKAT_RES)
    		self:registerWidgetClickEvent("Button_fun_up", _onHeaderClick)
    		_loadAndShowBtn("Button_fun_down", "Image_down", TANHE_RES)
    		self:registerWidgetClickEvent("Button_fun_down", _onTanheClick)
    		self:showWidgetByName("Button_fun_middle", false)
    	else
    		_loadAndShowBtn("Button_fun_middle", "Image_middle", LOOKAT_RES)
    		self:registerWidgetClickEvent("Button_fun_middle", _onHeaderClick)
    		self:showWidgetByName("Button_fun_up", false)
    		self:showWidgetByName("Button_fun_down", false)
    	end
    end
end

function HallMemberCell:_onMemberHeadClick( memberId, memberName )
	if memberId ~= G_Me.userData.id then 
		local FriendInfoConst = require("app.const.FriendInfoConst")
		local input = require("app.scenes.friend.FriendInfoLayer").createByName(memberId, memberName,nil,
                        function ( ... )
                            uf_sceneManager:replaceScene(require("app.scenes.legion.LegionHallScene").new(2))
                        end
            )   
    	uf_sceneManager:getCurScene():addChild(input)
        -- input:setKillCallBack(function ( ... )
        --     print("_onMemberHeadClick")
        --     uf_sceneManager:replaceScene(require("app.scenes.legion.LegionHallScene").new(2))
        -- end)
    else
        return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CLICK_SELF"))
	end	
end

function HallMemberCell:_onQuitClick( position, joinTime )
	joinTime = joinTime or 0
	if type(joinTime) ~= "number" then
		joinTime = 0
	end

    position = position or 0
    if position == 1 then
        local detailCorp = G_Me.legionData:getCorpDetail() or {}
        if detailCorp.size > 1 then 
            return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_LEADER_QUIT_CORP_TIP"))
        end

        MessageBoxEx.showYesNoMessage(nil, G_lang:get("LANG_LEGION_DISMISS_CORP_CONFIRM"), false, function ( ... )
            G_HandlersManager.legionHandler:sendDismissCorp()
        end)
        return 
	end

    -- if joinTime <= 0 then 
    --     return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_QUIT_NOT_REACH_TIME"))
    -- elseif joinTime > 0 then 
    --     local t = G_ServerTime:getTime() - joinTime
    --     require("app.cfg.corps_value_info")
    --     local minSed = corps_value_info.get(7).value
    --     if t < minSed then 
    --         return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_QUIT_NOT_REACH_TIME"))
    --     end
    -- end

	MessageBoxEx.showYesNoMessage(nil, G_lang:get("LANG_LEGION_CORP_QUIT"), false, function ( ... )
		G_HandlersManager.legionHandler:sendQuitCorp()
	end)
end

function HallMemberCell:_onTanheClick( userId, online, myPosition )
	if type(online) ~= "number" then 
		return 
	end

	myPosition = myPosition or 0
	if online > 0 then
		local t = G_ServerTime:getTime() - online
    	-- local min=math.floor(t/60)
    	-- local hour=math.floor(min/60)
    	-- local day=math.floor(hour/24)
        require("app.cfg.corps_value_info")
        local minSed1 = corps_value_info.get(12).value
        local minSed2 = corps_value_info.get(11).value
		if myPosition == 0 and t < minSed1 then
			return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_TANHE_NO_RIGHT_7"))
		elseif myPosition == 2 and t < minSed2 then 
			return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_TANHE_NO_RIGHT_5"))
		end

        local costGold = corps_value_info.get(13).value
		MessageBoxEx.showYesNoMessage(nil, G_lang:get("LANG_LEGION_TANHE_TIP"), false, function ( ... )
			if G_Me.userData.gold < costGold then 
				return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_TANHE_NO_MONEY"))
			end

			G_HandlersManager.legionHandler:sendExchangeLeader()
		end)		
	else
		if myPosition == 0 then
			return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_TANHE_NO_RIGHT_7"))
		elseif myPosition == 2 then 
			return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_TANHE_NO_RIGHT_5"))
		end
	end
end

function HallMemberCell:_onDismissClick( userId, memberName, joinTime )
	joinTime = joinTime or 0
	if type(joinTime) ~= "number" then
		joinTime = 0
	end

	if joinTime <= 0 then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_DISMISS_NOT_REACH_TIME"))
	elseif joinTime > 0 then 
		local t = G_ServerTime:getTime() - joinTime
		local hour = t/(3600)
		if hour < 24 then 
            local leftTime = 3600*24 - t
            local hourV = math.floor(leftTime/3600)
            local minV = math.floor(leftTime%3600/60)
			return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_DISMISS_NOT_REACH_TIME_FORMAT", {hourValue=hourV, minValue=minV}))
		end
	end
	
	MessageBoxEx.showYesNoMessage(nil, G_lang:get("LANG_LEGION_CORP_STAFF_DISMISS_MEMBER", {name=memberName}), false, function ( ... )
		G_HandlersManager.legionHandler:sendDissmissCorpMember(userId)
	end)
end

function HallMemberCell:_onChangPositionClick( userId, position, memberName )
	local btn = self:getWidgetByName("Button_fun_up")
	if not btn then 
		return 
	end

	local btnSize = btn:getSize()
	local posx, posy = btn:convertToWorldSpaceXY(-btnSize.width/2, 0)
	require("app.scenes.legion.LegionRenming").show(posx, posy, position, function ( btnIndex )
		if btnIndex == 1 then 
			MessageBoxEx.showYesNoMessage(nil, G_lang:get("LANG_LEGION_CORP_STAFF_TUANZHANG", {name=memberName}), false, function ( ... )
				G_HandlersManager.legionHandler:sendCorpStaff(userId, 1)
			end)
		elseif btnIndex == 2 then 
			MessageBoxEx.showYesNoMessage(nil, G_lang:get("LANG_LEGION_CORP_STAFF_FUTUANZHANG", {name=memberName}), false, function ( ... )
				G_HandlersManager.legionHandler:sendCorpStaff(userId, 2)
			end)
		elseif btnIndex == 3 then 
			MessageBoxEx.showYesNoMessage(nil, G_lang:get("LANG_LEGION_CORP_STAFF_DISMISS_FUTUANZHANG", {name=memberName}), false, function ( ... )
				G_HandlersManager.legionHandler:sendCorpStaff(userId, 0)
			end)
		end
	end)
end

function HallMemberCell:showCorpStaffFlag( ... )
    local node = self:getWidgetByName("Image_member")
    if not node then 
        return 
    end
    local around = nil
    around = EffectNode.new("effect_around1", 
        function(event)
            if event == "finish" and around then 
                around:removeFromParentAndCleanup(true)
                around = nil
             end
    end)
    node:addNode(around)
    around:setScale(2)
    around:play()
    around:setPositionXY(3, -3)

    around:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(2.2), CCRemove:create()))
end

return HallMemberCell
