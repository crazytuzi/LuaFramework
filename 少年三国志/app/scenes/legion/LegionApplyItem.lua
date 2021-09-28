--LegionApplyItem.lua

local LegionApplyItem = class("LegionApplyItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/legion_LegionApplyItem.json")
end)

function LegionApplyItem:ctor( ... )
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
end

function LegionApplyItem:updateItem( memberIndex )
	if type(memberIndex) ~= "number" then 
		memberIndex = 1 
	end
	local memberInfo = G_Me.legionData:getCorpApplyByIndex(memberIndex)

	self:showTextWithLabel("Label_level_value", memberInfo and memberInfo.level or 0)
	self:showTextWithLabel("Label_zhanli", memberInfo and memberInfo.fight_value or 0)
    self:showWidgetByName("Image_vip", memberInfo and memberInfo.vip > 0)

	local knightBaseInfo = nil
	knightBaseInfo = knight_info.get(memberInfo and memberInfo.main_role or 0)
	local icon = self:getImageViewByName("Image_icon")
	if icon ~= nil then
		local heroPath = G_Path.getKnightIcon(knightBaseInfo and knightBaseInfo.res_id or 0)
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

	self:registerWidgetClickEvent("Button_ok", function ( ... )
		if memberInfo then
			self:_onConfirmApply(memberInfo.id, true)
		end
	end)
	self:registerWidgetClickEvent("Button_no", function ( ... )
		if memberInfo then 
			self:_onConfirmApply(memberInfo.id, false)
		end
	end)

	self:registerWidgetClickEvent("Image_legion", function ( ... )
		if memberInfo then
			local FriendInfoConst = require("app.const.FriendInfoConst")
			local input = require("app.scenes.friend.FriendInfoLayer").createByName(memberInfo.id, memberInfo.name, nil
				-- ,
                        -- function ( ... )
                        --     uf_sceneManager:replaceScene(require("app.scenes.legion.LegionHallScene").new(2))
                        -- end
            )   
    		uf_sceneManager:getCurScene():addChild(input)
		end
		end)
end

function LegionApplyItem:_onConfirmApply( userId, confirm )
	G_HandlersManager.legionHandler:sendConfirmJoinCorp(userId, confirm)
end

return LegionApplyItem


