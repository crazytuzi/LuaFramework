--LegionListItem.lua

require("app.cfg.corps_info")

local LegionListItem = class("LegionListItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/legion_LegionListItem.json")
end)

function LegionListItem:ctor( ... )
	self:enableLabelStroke("Label_legion_name", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_level", Colors.strokeBrown, 1 )
end

function LegionListItem:updateItem( corpInfo )
	self:showTextWithLabel("Label_legion_name", corpInfo and corpInfo.name or "")
	self:showTextWithLabel("Label_level", corpInfo and corpInfo.level or 0)
	self:showTextWithLabel("Label_tuanzhang", corpInfo and corpInfo.leader_name or "")
	self:showTextWithLabel("Label_count", corpInfo and corpInfo.size or 0)
	self:showTextWithLabel("Label_notice_content", corpInfo and corpInfo.announcement or "")

	local img = self:getImageViewByName("Image_icon")
    if img then 
        img:loadTexture(G_Path.getLegionIconByIndex(corpInfo and corpInfo.icon_pic or 1))
    end
    img = self:getImageViewByName("Image_legion")
    if img then 
        img:loadTexture(G_Path.getLegionIconBackByIndex(corpInfo and corpInfo.icon_frame or 1))
    end

    local memberCount = corpInfo and corpInfo.size or 0
    local currentCorpInfo = corps_info.get(corpInfo and corpInfo.level or 1)
    local isFull = currentCorpInfo and currentCorpInfo.number <= memberCount

    self:showWidgetByName("Button_cancelApply", (corpInfo and corpInfo.has_join) )
    self:showWidgetByName("Image_full", isFull and (not corpInfo or not corpInfo.has_join))
    self:showWidgetByName("Button_apply", (not corpInfo or not corpInfo.has_join) and not isFull)
    self:registerBtnClickEvent("Button_apply", function ( ... )
    	if corpInfo then
    		self:_onApplyClick(corpInfo.id)
    	end
    end)
    self:registerBtnClickEvent("Button_cancelApply", function ( ... )
    	if corpInfo then
    		self:_onCancelApplyClick(corpInfo.id, corpInfo.name)
    	end
    end)
end

function LegionListItem:_onApplyClick( corpId )
	if type(corpId) ~= "number" then 
		return 
	end

    local corpDetail = G_Me.legionData:getCorpDetail()
    if not corpDetail then 
        return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_APPLY_NOT_REACH_TIME"))
    end
    if corpDetail.quit_corp_cd then 
        corpDetail.quit_corp_cd = corpDetail.quit_corp_cd or (G_ServerTime:getTime() - 1)
        local leftTime = corpDetail.quit_corp_cd - G_ServerTime:getTime()
        if leftTime > 0 and leftTime < 24*3600 then 
            local leftHour = math.floor(leftTime/3600)
            local leftMin = math.floor(leftTime%3600/60)
            --__Log("leftTime:%d, leftHour:%d, leftMin:%d", leftTime, leftHour, leftMin)
            return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_APPLY_NOT_REACH_TIME_FORMAT", {hourValue=leftHour, minValue=leftMin}))
        end
    end

	G_HandlersManager.legionHandler:sendRequestJoinCorp(corpId)
end

function LegionListItem:_onCancelApplyClick( corpId, corpName )
	if type(corpId) ~= "number" then 
		return 
	end

	MessageBoxEx.showYesNoMessage(nil, G_lang:get("LANG_LEGION_APPLY_CANCEL_CORP", {name=corpName}), false, function ( ... )
		G_HandlersManager.legionHandler:sendDeleteJoinCorp(corpId)
	end)
end

return LegionListItem
