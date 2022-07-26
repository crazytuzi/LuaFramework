UITeamInfo = {}
function UITeamInfo.init()
end
function UITeamInfo.setup()
	local ui_teamIcon = ccui.Helper:seekNodeByName(UITeamInfo.Widget, "image_icon") --战队头像
	local ui_teamLv = ccui.Helper:seekNodeByName(ui_teamIcon, "label_lv") --战队等级
	local ui_teamName = ccui.Helper:seekNodeByName(UITeamInfo.Widget, "text_team_name")--战队名字
	local ui_teamVipLv = ccui.Helper:seekNodeByName(UITeamInfo.Widget, "label_vip_number")--战队VIP等级
	local ui_teamEnargyBar = ccui.Helper:seekNodeByName(UITeamInfo.Widget, "bar_enargy")--战队体力条
	local ui_teamStaminaBar = ccui.Helper:seekNodeByName(UITeamInfo.Widget, "bar_stamina")--战队耐力条
	local ui_teamExpBar = ccui.Helper:seekNodeByName(UITeamInfo.Widget, "bar_exp")--战队经验条
	local ui_teamGold = ccui.Helper:seekNodeByName(UITeamInfo.Widget, "text_gold_number")--战队元宝
	local ui_teamMoney = ccui.Helper:seekNodeByName(UITeamInfo.Widget, "text_silver")--战队铜钱
	local ui_teamFight = ccui.Helper:seekNodeByName(UITeamInfo.Widget, "label_fighting_number")--战队战斗力
	local ui_enary = ccui.Helper:seekNodeByName(UITeamInfo.Widget, "image_enargy")
	local ui_stamina = ccui.Helper:seekNodeByName(UITeamInfo.Widget, "image_stamina")
	local ui_text_exp = ui_teamExpBar:getChildByName("text_exp")
	local ui_text_exp_up = ui_teamExpBar:getChildByName("text_exp_up")
	if net.InstPlayer then
		ui_teamName:setString(net.InstPlayer.string["3"])
		ui_teamLv:setString(tostring(net.InstPlayer.int["4"]))
		ui_teamVipLv:setString(tostring(net.InstPlayer.int["19"]))
		ui_teamEnargyBar:setPercent(utils.getPercent(net.InstPlayer.int["8"], net.InstPlayer.int["9"]))
		ui_teamStaminaBar:setPercent(utils.getPercent(net.InstPlayer.int["10"], net.InstPlayer.int["11"]))
		local InstPlayerNowLevel = net.InstPlayer.int["4"]
	    local nowExp = net.InstPlayer.int["7"]
	    local ExpNowLevelValue =0
	    if DictLevelProp[tostring(InstPlayerNowLevel)]~= nil then 
	        ExpNowLevelValue = DictLevelProp[tostring(InstPlayerNowLevel)].fleetExp 
	    end
	    local number = nowExp/ ExpNowLevelValue * 100
	    if number > 100 then 
	        ui_teamExpBar:setPercent(100)
	    else
	        ui_teamExpBar:setPercent(number)
	    end
		ui_text_exp:setString(string.format("EXP：%d/%d",nowExp,ExpNowLevelValue))
		ui_text_exp_up:setString(string.format("EXP：%d/%d",nowExp,ExpNowLevelValue))
		ui_teamGold:setString(tostring(net.InstPlayer.int["5"]))
		ui_teamMoney:setString(net.InstPlayer.string["6"])
		ui_teamFight:setString(tostring(utils.getFightValue()))
		
		local enaryBar = ui_enary:getChildByName("bar_enargy")
		enaryBar:setPercent(utils.getPercent(net.InstPlayer.int["8"], net.InstPlayer.int["9"]))
		enaryBar:getChildByName("text_enargy"):setString(net.InstPlayer.int["8"] .. "/" .. net.InstPlayer.int["9"])
		enaryBar:getChildByName("text_enargy_up"):setString(net.InstPlayer.int["8"] .. "/" .. net.InstPlayer.int["9"])
		
		local staminaBar = ui_stamina:getChildByName("bar_stamina")
		staminaBar:setPercent(utils.getPercent(net.InstPlayer.int["10"], net.InstPlayer.int["11"]))
		staminaBar:getChildByName("text_atamina"):setString(net.InstPlayer.int["10"] .. "/" .. net.InstPlayer.int["11"])
		staminaBar:getChildByName("text_atamina_up"):setString(net.InstPlayer.int["10"] .. "/" .. net.InstPlayer.int["11"])
		
		local dictCard = DictCard[tostring(net.InstPlayer.int["32"])]
        local teamHead = false
		if dictCard then
            for key, obj in pairs(net.InstPlayerFormation) do
                local dictCardId = obj.int["6"] --卡牌字典ID
                if dictCardId == dictCard.id then
                    local dictCardData = DictCard[tostring(dictCardId)] --卡牌字典数据
                    local instCardData = net.InstPlayerCard[tostring(obj.int["3"])]
                    local isAwake = instCardData.int["18"]
                    teamHead = true
                    ui_teamIcon:loadTexture("image/" .. DictUI[tostring(isAwake == 1 and dictCardData.awakeSmallUiId or dictCardData.smallUiId)].fileName)
                    break
                end
	        end
		end
        if not teamHead then
            ui_teamIcon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
        end
		ui_teamIcon:setTouchEnabled(true)
		ui_teamIcon:addTouchEventListener(function(sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				UIManager.pushScene("ui_team")
			end
			UIHomePage.hideMore()
		end)
	end
end