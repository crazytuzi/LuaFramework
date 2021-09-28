--LegionDamageRankGloablItem.lua


require("app.cfg.corps_dungeon_rank_info")
require("app.cfg.knight_info")

local LegionDamageRankGloablItem = class("LegionDamageRankGloablItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/legion_DungeonAllMemberRankItem.json")
end)

function LegionDamageRankGloablItem:ctor( ... )
	self:enableLabelStroke("Label_member_name", Colors.strokeBrown, 1 )
end

function LegionDamageRankGloablItem:updateItem( memberIndex )
	if type(memberIndex) ~= "number" then 
		memberIndex = 1 
	end
	
	local rankInfo = G_Me.legionData:getGlobalRankByIndex(memberIndex)
	if not rankInfo then 
		return 
	end

	--self:showTextWithLabel("Label_member_name", rankInfo.name)
	self:showTextWithLabel("Label_owner_legion", rankInfo.corp_name)
	self:showTextWithLabel("Label_max_damage", rankInfo.harm)
    self:showWidgetByName("Image_vip", rankInfo and rankInfo.vip > 0)

	local knightBaseInfo = knight_info.get(rankInfo.main_role)
	local icon = self:getImageViewByName("Image_icon")
	if icon ~= nil then
		local resId = knightBaseInfo and knightBaseInfo.res_id or 0
        if rankInfo.id == G_Me.userData.id then 
            resId = G_Me.dressData:getDressedPic()
        else
        	resId = G_Me.dressData:getDressedResidWithClidAndCltm(rankInfo.main_role, rankInfo.dress_id,
        		rankInfo.clid,rankInfo.cltm,rankInfo.clop)
        end
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

	local _findRankAwardInfo = function ( rankValue )
		if type(rankValue) ~= "number" then 
			return nil
		end

		local length = corps_dungeon_rank_info.getLength()
		for loopi = 1, length do 
			local rankInfo = corps_dungeon_rank_info.get(loopi)
			if rankInfo and rankValue >= rankInfo.rank_min and rankValue <= rankInfo.rank_max then 
				return rankInfo
			end
		end

		return nil
	end

	local text = ""
	local rankAwardInfo = _findRankAwardInfo(rankInfo.rank)
	if rankAwardInfo then 
		local goodInfo = G_Goods.convert(rankAwardInfo.award_type, rankAwardInfo.award_value, rankAwardInfo.award_size)
		if goodInfo then 
			text = goodInfo.name.."x"..goodInfo.size
		end
	end
	self:showTextWithLabel("Label_rank_award", text)
	
	self:registerWidgetClickEvent("Image_legion", function ( ... )
		if rankInfo.id ~= G_Me.userData.id then 
			local FriendInfoConst = require("app.const.FriendInfoConst")
			local input = require("app.scenes.friend.FriendInfoLayer").createByName(rankInfo.id, rankInfo.name,nil,
                        function ( ... )
                        	local chapterInfo = G_Me.legionData:getCorpChapters()
                            uf_sceneManager:replaceScene(require("app.scenes.legion.LegionMapScene").new( 
                            	chapterInfo and chapterInfo.today_chid or 1 ))
                        end)   
    		uf_sceneManager:getCurScene():addChild(input)
		end
	end)

	self:showWidgetByName("Image_rank_value", rankInfo.rank < 4)
    self:showWidgetByName("Label_rank_value", rankInfo.rank >= 4)
    if rankInfo.rank < 4 then 
		local img = self:getImageViewByName("Image_rank_value")
		if img then 
			img:loadTexture(G_Path.getRankTopThreeIcon(rankInfo.rank))
		end
	else
		self:showTextWithLabel("Label_rank_value", rankInfo.rank)
	end
end


return LegionDamageRankGloablItem

