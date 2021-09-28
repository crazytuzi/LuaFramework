--LegionNewDamageRankLegionItem.lua


local LegionNewDamageRankLegionItem = class("LegionNewDamageRankLegionItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/legion_DungeonNewMemberRankItem.json")
end)

function LegionNewDamageRankLegionItem:ctor( ... )
	self:enableLabelStroke("Label_member_name", Colors.strokeBrown, 1 )
end

function LegionNewDamageRankLegionItem:updateItem( memberIndex )
	if type(memberIndex) ~= "number" then 
		memberIndex = 1 
	end
	
	local rankInfo = G_Me.legionData:getNewLegionRankByIndex(memberIndex)
	if not rankInfo then 
		return 
	end

	self:showTextWithLabel("Label_total_damage", rankInfo.sp1)
	self:showTextWithLabel("Label_max_damage", GlobalFunc.ConvertNumToCharacter4(rankInfo.harm))
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

    	self:registerWidgetClickEvent("Image_legion", function ( ... )
		if rankInfo.id and rankInfo.id ~= G_Me.userData.id then 
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

return LegionNewDamageRankLegionItem

