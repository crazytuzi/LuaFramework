UILineupDialog = {}

local _baseLuckPos = nil
local userData = nil
local _isActionDone = nil
local _actionTime = 0.3

function UILineupDialog.init()
	local ui_baseLuck = ccui.Helper:seekWidgetByName(UILineupDialog.Widget, "image_base_luck")
	_baseLuckPos = cc.p(ui_baseLuck:getPositionX(), ui_baseLuck:getPositionY())
	
	UILineupDialog.Widget:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if _isActionDone then
				local callfunc = cc.CallFunc:create(function() UIManager.popScene() _isActionDone = true end)
				if ui_baseLuck:isVisible() then
					_isActionDone = false
					ui_baseLuck:runAction(cc.Sequence:create(cc.MoveTo:create(_actionTime, cc.p(_baseLuckPos.x + ui_baseLuck:getContentSize().width, _baseLuckPos.y)), callfunc))
				end
			end
		end
	end)
	ui_baseLuck:setPositionX(_baseLuckPos.x + ui_baseLuck:getContentSize().width)
end

function UILineupDialog.setup()
	if userData and type(userData) == "table" then
        local ui_baseLuck = ccui.Helper:seekWidgetByName(UILineupDialog.Widget, "image_base_luck")
		if #userData >= 3 then
			ui_baseLuck:setVisible(true)
			---[[缘分
			for key = 1, 6 do
                local dictLuck = userData[key]
				local ui_luckName = ui_baseLuck:getChildByName("text_luck" .. key)
				local ui_luckDesc = ui_baseLuck:getChildByName("text_luck"..key.."_info")
                if dictLuck then
				    ui_luckName:setString("·" .. dictLuck.name .. "·")
				    ui_luckDesc:setString(dictLuck.description)
				    if dictLuck.color then
					    ui_luckName:setColor(cc.c3b(0, 255, 255))
					    ui_luckDesc:setColor(cc.c3b(0, 255, 255))
				    else
					    ui_luckName:setColor(cc.c3b(255, 255, 255))
					    ui_luckDesc:setColor(cc.c3b(255, 255, 255))
				    end
                else
                    ui_luckName:setString("")
				    ui_luckDesc:setString("")
                end
			end
			--]]
		else
			ui_baseLuck:setVisible(false)
		end
		if ui_baseLuck:isVisible() then
			_isActionDone = false
			ui_baseLuck:runAction(cc.Sequence:create(cc.MoveTo:create(_actionTime, _baseLuckPos), cc.CallFunc:create(function() _isActionDone = true end)))
		end
	end
end

function UILineupDialog.show(_tableParams)
	userData = _tableParams
	UIManager.pushScene("ui_lineup_dialog", true)
end

function UILineupDialog.free()
	userData = nil
    _baseLuckPos = nil
    _isActionDone = nil
end