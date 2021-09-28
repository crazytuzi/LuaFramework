--CrusadeRankListItem.lua

local CrusadeRankListItem = class("CrusadeRankListItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/crusade_RankListItem.json")
end)

function CrusadeRankListItem:ctor( ... )
	self._bgImage = self:getImageViewByName("Image_bg")

	self._frameImage = self:getImageViewByName("Image_frame")    --头像框
	self._bmpLabel = self:getLabelBMFontByName("BitmapLabel_rank_value")
	self:enableLabelStroke("Label_member_name", Colors.strokeBrown, 1 )

	self._userInfo = nil
end

function CrusadeRankListItem:updateItem( rankInfo, index )
	
	if not rankInfo then 
		return 
	end

	self._userInfo = rankInfo

	--背景
	if rankInfo.id == G_Me.userData.id and tostring(rankInfo.sid) == tostring(G_PlatformProxy:getLoginServer().id) then
		self._bgImage:loadTexture("board_red.png",UI_TEX_TYPE_PLIST)
	else
		self._bgImage:loadTexture("board_normal.png",UI_TEX_TYPE_PLIST)
	end

	self:showTextWithLabel("Label_server_name", "["..rankInfo.sname.."]")
	self:showTextWithLabel("Label_max_points_value", rankInfo.sp1)

	--头像框
	self._frameImage:setVisible(false)

	if rawget(rankInfo,"fid") and rankInfo.fid > 0 then
		require("app.cfg.frame_info")
        local frame = frame_info.get(rankInfo.fid)
		self._frameImage:setVisible(true)
		self._frameImage:loadTexture(G_Path.getAvatarFrame(rankInfo.fid))
		G_GlobalFunc.addHeadIcon(self._frameImage,frame.vip_level)
	end

	--头像信息
   	self:showWidgetByName("Image_vip", rawget(rankInfo,"vip") and rankInfo.vip > 0 or false)
	local knightBaseInfo = knight_info.get(rankInfo.main_role)
	local icon = self:getImageViewByName("Image_icon")
	if icon ~= nil then
		local resId = knightBaseInfo and knightBaseInfo.res_id or 0
    	resId = G_Me.dressData:getDressedResidWithClidAndCltm(rankInfo.main_role, rankInfo.dress_id,
    		rawget(rankInfo,"clid"),rawget(rankInfo,"cltm"),rawget(rankInfo,"clop"))
		local heroPath = G_Path.getKnightIcon(resId)
    	icon:loadTexture(heroPath, UI_TEX_TYPE_LOCAL) 
	end

	local name = self:getLabelByName("Label_member_name")
	if name ~= nil then
		name:setColor(Colors.qualityColors[knightBaseInfo and knightBaseInfo.quality or 1])
		name:setText(rankInfo.name)
	end

	local pingji = self:getImageViewByName("Image_border")
	if pingji then
    	pingji:loadTexture(G_Path.getAddtionKnightColorImage(knightBaseInfo and knightBaseInfo.quality or 1))  
    end


	--查看阵容
	self:registerWidgetClickEvent("Image_headbg", handler(self, self._onTouchHead))
--[[
    self:registerWidgetClickEvent("Image_headbg", function ( ... )
		if rankInfo.id and rankInfo.id ~= G_Me.userData.id then 
			local FriendInfoConst = require("app.const.FriendInfoConst")
			local infoLayer = require("app.scenes.friend.FriendInfoLayer").createByName(rankInfo.id, rankInfo.name,nil,
                        function ( ... )
                            uf_sceneManager:replaceScene(require("app.scenes.crusade.CrusadeScene").new())
                        end)   
    		uf_sceneManager:getCurScene():addChild(infoLayer)
		end
	end)
]]

    --排名
	self:showWidgetByName("Image_rank_value", index < 4)
	self._bmpLabel:setVisible(index >= 4)

	if index < 4 then 
		local img = self:getImageViewByName("Image_rank_value")
		if img then 
			img:loadTexture(G_Path.getRankTopThreeIcon(index))
		end
	else
		self._bmpLabel:setText(index)
	end
end

function CrusadeRankListItem:_onTouchHead(...)

	if self._userInfo.id ~= G_Me.userData.id then
		if self._userInfo.sid and self._userInfo.id then
			uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_PLAYER_TEAM, self._onRcvPlayerTeam, self)
			G_HandlersManager.crossWarHandler:sendGetPlayerTeam(self._userInfo.sid, self._userInfo.id)
		end
	end
end

function CrusadeRankListItem:_onRcvPlayerTeam(data)
	if data.user_id == self._userInfo.id and data.sid == self._userInfo.sid then
		local user = rawget(data, "user")
		if user ~= nil then
			local layer = require("app.scenes.arena.ArenaZhenrong").create(user)
			uf_sceneManager:getCurScene():addChild(layer)
		end
	end

	uf_eventManager:removeListenerWithTarget(self)
end

return CrusadeRankListItem

