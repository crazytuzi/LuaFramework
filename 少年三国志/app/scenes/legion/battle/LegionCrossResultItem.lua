--LegionCrossResultItem.lua

local LegionCrossResultItem = class("LegionCrossResultItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/legion_CrossMemberRankItem.json")
end)


function LegionCrossResultItem:ctor( ... )
	self:enableLabelStroke("Label_member_name", Colors.strokeBrown, 1 )
end

function LegionCrossResultItem:updateItem( index )
	if type(index) ~= "number" then 
		return 
	end

	local rankInfo = G_Me.legionData:getBattleRankInfoByIndex(index)
	if not rankInfo then 
		return 
	end

	local panelBack = self:getPanelByName("Panel_Root")
	local imgBack = self:getImageViewByName("Image_111")
	if rankInfo and rankInfo.user_id == G_Me.userData.id then 
        panelBack:setBackGroundImage("board_red.png",UI_TEX_TYPE_PLIST)
        imgBack:loadTexture("list_board_red.png",UI_TEX_TYPE_PLIST)
    else
        panelBack:setBackGroundImage("board_normal.png",UI_TEX_TYPE_PLIST)
        imgBack:loadTexture("list_board.png",UI_TEX_TYPE_PLIST)
    end

	self:showTextWithLabel("Label_exp_acquire", rankInfo.rob_exp)
	self:showTextWithLabel("Label_kill_count", rankInfo.kill_count)
    self:showWidgetByName("Image_vip", rankInfo and rankInfo.vip > 0)

	local knightBaseInfo = knight_info.get(rankInfo.main_role)
	local icon = self:getImageViewByName("Image_icon")
	if icon ~= nil then
		local resId = knightBaseInfo and knightBaseInfo.res_id or 0
       	resId = G_Me.dressData:getDressedResidWithClidAndCltm(rankInfo.main_role, rankInfo.dress_id
       		,rankInfo.clid,rankInfo.cltm,rankInfo.clop)
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

    self:registerWidgetClickEvent("Image_legion", function ( ... )
		if rankInfo.user_id and rankInfo.user_id ~= G_Me.userData.id then 
			local FriendInfoConst = require("app.const.FriendInfoConst")
			local input = require("app.scenes.friend.FriendInfoLayer").createByName(rankInfo.user_id, rankInfo.name,nil,
                        function ( ... )
                        	local chapterInfo = G_Me.legionData:getCorpChapters()
                            uf_sceneManager:replaceScene(require("app.scenes.legion.LegionMapScene").new( 
                            	chapterInfo and chapterInfo.today_chid or 1 ))
                        end)   
    		uf_sceneManager:getCurScene():addChild(input)
		end
	end)

    self:showWidgetByName("Image_rank_value", index < 4)
    self:showWidgetByName("Label_rank_value", index >= 4)
    if index < 4 then 
		local img = self:getImageViewByName("Image_rank_value")
		if img then 
			img:loadTexture(G_Path.getRankTopThreeIcon(index))
		end
	else
		self:showTextWithLabel("Label_rank_value", index)
	end
end


return LegionCrossResultItem
