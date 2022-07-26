require"Lang"
UITaskDay ={}
local scrollView = nil
local taskItem = nil
local _awardData = nil

local function netCallbackFunc(pack)
	if tonumber(pack.header) == StaticMsgRule.dailyTashReward then
		UIManager.flushWidget(UITeamInfo)
		UIManager.flushWidget(UIHomePage)
		UIManager.flushWidget(UITaskDay)
		UIAwardGet.setOperateType(UIAwardGet.operateType.award,_awardData,UITaskDay)
   		UIManager.pushScene("ui_award_get")
	end
end
local function sendRewardData(param)
    local  sendData = {
      header = StaticMsgRule.dailyTashReward,
      msgdata = {
        int = {
          instPlayerDailyTaskId = param,
        }
      }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end
local function setScrollViewItem(_Item, _obj)
	local ui_name = ccui.Helper:seekNodeByName(_Item, "text_task_name")
	local ui_info = ccui.Helper:seekNodeByName(_Item, "text_task_info")
	local ui_image_exp = ccui.Helper:seekNodeByName(_Item, "image_exp")
	local ui_exp = ccui.Helper:seekNodeByName(_Item, "text_exp")
	local ui_image_money = ccui.Helper:seekNodeByName(_Item, "image_money")
	local ui_money = ccui.Helper:seekNodeByName(_Item, "text_money")
	local ui_number = ccui.Helper:seekNodeByName(_Item, "text_task_number")
	local ui_image = ccui.Helper:seekNodeByName(_Item, "image_task")
	local btn_prize = ccui.Helper:seekNodeByName(_Item, "btn_prize")
	local dictObj = DictDailyTask[tostring(_obj.int["3"])]
	local uiId = dictObj.uiId
	local smallImage = "image/head_char_jiutianzun.png"
	if smallUiId ~= 0 then 
		smallImage = DictUI[tostring(uiId)].fileName
	end
--	local name = dictObj.name
	local info = dictObj.description
	local totalTimes = dictObj.times
	local rewardTimes = _obj.int["4"]
	local rewardState = _obj.int["5"] -- 领取状态 0 未领 1 领完了
	ui_name:setString(Lang.ui_task_day1 .. dictObj.plan)
	ui_info:setString(info)
	ui_number:setString(string.format("%d/%d",rewardTimes,totalTimes))
	ui_image:loadTexture("image/" .. smallImage)
	if _Item:getChildByName("ylq") then 
		_Item:getChildByName("ylq"):removeFromParent()
	end
	local rewardsData = utils.stringSplit(dictObj.rewards, ";")
	if rewardsData[1] then 
		local tableData = utils.stringSplit(rewardsData[1], "_")
		local icon =nil  
		if tonumber(tableData[2]) == 3 then 
			icon = "ui/yh_exp.png"
			ui_image_exp:loadTexture(icon)
			ui_exp:setString("×" .. tableData[3])
		elseif tonumber(tableData[2]) == 1 then 
			icon = "ui/jin.png"
			ui_image_money:loadTexture(icon)
			ui_money:setString("×" .. tableData[3])
		elseif tonumber(tableData[2]) == 2 then 
			icon = "ui/yin.png"
			ui_image_money:loadTexture(icon)
			ui_money:setString("×" .. tableData[3])
		elseif tonumber(tableData[2]) == 5 then 
			icon = "ui/weiwang.png"
			ui_image_money:loadTexture(icon)
			ui_money:setString("×" .. tableData[3])
		end
	end
	if rewardsData[2] then 
		ui_image_money:setVisible(true)
		local tableData = utils.stringSplit(rewardsData[2], "_")
		local icon =nil  
		if tonumber(tableData[2]) == 3 then 
			icon = "ui/yh_exp.png"
			ui_image_exp:loadTexture(icon)
			ui_exp:setString("×" .. tableData[3])
		elseif tonumber(tableData[2]) == 1 then 
			icon = "ui/jin.png"
			ui_image_money:loadTexture(icon)
			ui_money:setString("×" .. tableData[3])
		elseif tonumber(tableData[2]) == 2 then 
			icon = "ui/yin.png"
			ui_image_money:loadTexture(icon)
			ui_money:setString("×" .. tableData[3])
		elseif tonumber(tableData[2]) == 5 then 
			icon = "ui/weiwang.png"
			ui_image_money:loadTexture(icon)
			ui_money:setString("×" .. tableData[3])
		end
	else 
		ui_image_money:setVisible(false)
	end

	if rewardState == 1 then 
		btn_prize:setVisible(false)
		if not _Item:getChildByName("ylq") then 
			local ylqImage = ccui.ImageView:create("ui/rw_ylq.png")
			ylqImage:setName("ylq")
			_Item:addChild(ylqImage)
			ylqImage:setPosition(cc.p(btn_prize:getPosition()))
		else 
			_Item:getChildByName("ylq"):setVisible(true)
		end
	elseif  rewardState == 0 and rewardTimes < totalTimes then 
		btn_prize:setVisible(true)
		btn_prize:loadTextureNormal("ui/tk_jm_btn.png")
		btn_prize:loadTexturePressed("ui/tk_jm_btn.png")
		btn_prize:setTitleText(Lang.ui_task_day2)
		if _Item:getChildByName("ylq") then 
			_Item:getChildByName("ylq"):setVisible(false)
		end
	elseif  rewardState == 0 and rewardTimes >= totalTimes then 
		btn_prize:setVisible(true)
		btn_prize:loadTextureNormal("ui/tk_btn01.png")
		btn_prize:loadTexturePressed("ui/tk_btn01.png")
		btn_prize:setTitleText(Lang.ui_task_day3)
		if _Item:getChildByName("ylq") then 
			_Item:getChildByName("ylq"):setVisible(false)
		end
	end
	local function btnTouchEvent(sender, eventType)
       if eventType == ccui.TouchEventType.ended then
       		if  rewardState == 0 and rewardTimes < totalTimes then 
                local taskLevel = 0
                if dictObj.functionOpenId == 40 then
                    taskLevel = 40
                else
                    taskLevel = DictFunctionOpen[tostring(dictObj.functionOpenId)].level
                end
       		    if net.InstPlayer.int["4"] < taskLevel then
                    return UIManager.showToast(Lang.ui_task_day4 .. taskLevel .. Lang.ui_task_day5)
                end 
       			sender:retain()
                if UIAllianceSkill.Widget and UIAllianceSkill.Widget:getParent() then
                    UIManager.showWidget("ui_menu")
                end
       			if dictObj.sname ~= "skillChipLoot" and dictObj.sname ~= "generBarrier" and dictObj.sname ~= "almaBarrier" then 
	       			UIManager.popScene()
	       			UIManager.hideWidget("ui_team_info")
	       		end
       			if dictObj.sname == "cardStrength" then -- 卡牌强化
                    UILineup.friendState = 0
       				UIManager.showWidget("ui_lineup")
	       		elseif dictObj.sname == "equipStrength" then --装备强化
	       			UIManager.showWidget("ui_team_info", "ui_bag_equipment")
	       		elseif dictObj.sname == "extractCard" then --抽卡
	       			UIMenu.onShop()
	       		elseif dictObj.sname == "skillChipLoot" then --抢碎片
	       			local lootOpen = false
					if net.InstPlayerBarrier then
				      for key,obj in pairs(net.InstPlayerBarrier) do
				          if obj.int["3"] == 17 then  --17关开启
				          	lootOpen = true
				          	break;
				          end
				      end
				    end
				    if lootOpen then 
				    	UIManager.popScene()
       					UIManager.hideWidget("ui_team_info")
						UILoot.show(1,1)
					else
						UIManager.showToast(Lang.ui_task_day6)
						return  
					end
	       		elseif dictObj.sname == "almaBarrier" then --精英关卡
	       			UIMenu.onFight(1)
	       		elseif dictObj.sname == "area" then --竞技场
	       			UIManager.showWidget("ui_arena")
	       		elseif dictObj.sname == "pill" then --炼丹
	       			UIManager.showWidget("ui_liandan")
	       		elseif dictObj.sname == "state" then --境界
                    UILineup.friendState = 0
	       			UIManager.showWidget("ui_lineup")
	       		elseif dictObj.sname == "tower" then --练气塔
	       			 UIManager.showWidget("ui_tower_test")
--	       		elseif dictObj.sname == "fire" then --异火
	       			-- UIManager.showWidget("ui_fire")
	       		elseif dictObj.sname == "generBarrier" then --普通副本
	       			UIMenu.onFight(2)
	       		elseif dictObj.sname == "worldBoss" then --世界boss
	       			UIManager.showWidget("ui_boss")
                elseif dictObj.sname == "challenge" then
                    UIManager.hideWidget("ui_team_info")
                    UIManager.hideWidget("ui_menu")
                    UIManager.showWidget("ui_game")
                elseif dictObj.sname == "yFire" then
                    UIManager.hideWidget("ui_team_info")
                    UIManager.hideWidget("ui_menu")
                    UIManager.showWidget("ui_fire_base")
                elseif dictObj.sname == "danta" then
                    UIManager.hideWidget("ui_team_info")
                    UIManager.showWidget("ui_pilltower")
                elseif dictObj.sname == "wingBarrier" then
                    UIManager.showWidget("ui_team_info", "ui_bag_wing")
                elseif dictObj.sname == "holdStar" then
                    UIManager.showWidget("ui_star")
	       		end
	       		cc.release(sender)
       		elseif  rewardState == 0 and rewardTimes >= totalTimes then 
       			_awardData = rewardsData
       			sendRewardData(_obj.int["1"])
       		end	
       		
	   end
	end
	btn_prize:addTouchEventListener(btnTouchEvent)
	btn_prize:setPressedActionEnabled(true)
end
function UITaskDay.init( ... )
	local btn_close = ccui.Helper:seekNodeByName(UITaskDay.Widget, "btn_close")
	local function btnTouchEvent(sender, eventType)
       if eventType == ccui.TouchEventType.ended then
       		AudioEngine.playEffect("sound/button.mp3")
       		UIManager.popScene()
	   end
	end
	btn_close:addTouchEventListener(btnTouchEvent)
	btn_close:setPressedActionEnabled(true)
	scrollView = ccui.Helper:seekNodeByName(UITaskDay.Widget, "view_award_lv")
    taskItem = scrollView:getChildByName("image_base_gift"):clone()
   if taskItem:getReferenceCount() == 1 then
      taskItem:retain()
    end
end

local function compareTask(value1,value2)
	if value1.int["5"] == 1 and value2.int["5"] == 0 then 
		return true 
	elseif value1.int["5"] == 0 and value2.int["5"] == 1 then 
		return false
	elseif value1.int["5"] == 1 and value2.int["5"] == 1 then 
		return false
	else 
		if DictDailyTask[tostring(value1.int["3"])].times <= value1.int["4"] and DictDailyTask[tostring(value2.int["3"])].times > value2.int["4"] then 
			return false
		elseif DictDailyTask[tostring(value1.int["3"])].times > value1.int["4"] and DictDailyTask[tostring(value2.int["3"])].times > value2.int["4"] then 
			if value1.int["3"] ~= 11 and value2.int["3"] == 11 then 
				return true
			else 
				return false
			end
		else 
			return true
		end
	end
end
function UITaskDay.setup()
    scrollView:removeAllChildren()
    local taskThing, boxData = {}, {}
    local currentValue, maxValue = 0, 0
    if net.InstPlayerDailyTask then
       local level = net.InstPlayer.int["4"]
       for key, obj in pairs(net.InstPlayerDailyTask) do
            if obj.int["3"] < 1000 then
       		    local dictObj = DictDailyTask[tostring(obj.int["3"])]
                if obj.int["4"] >= dictObj.times then
                    currentValue = currentValue + dictObj.plan
                end
                maxValue = maxValue + dictObj.plan
--       		    local taskLevel = DictFunctionOpen[tostring(dictObj.functionOpenId)].level
--       		    if level >= taskLevel then 
				    table.insert(taskThing,obj)
--			    end
            else
                boxData[#boxData+1] = obj
            end
       end
       utils.quickSort(taskThing,compareTask)
       utils.quickSort(boxData, function(obj1, obj2) if obj1.int["3"] > obj2.int["3"] then return true end end)
    end
    if next(taskThing) then
        utils.updateView(UITaskDay,scrollView,taskItem,taskThing,setScrollViewItem)
    end

    local buildBoxImgs = {
        {"ui/fb_bx.png", "ui/fb_bx_empty.png", "ui/fb_bx_full.png"},
        {"ui/fb_bx01.png", "ui/fb_bx01_empty.png", "ui/fb_bx01_full.png"},
        {"ui/fb_bx02.png", "ui/fb_bx02_empty.png", "ui/fb_bx02_full.png"}
    }
    local loadingPanel = UITaskDay.Widget:getChildByName("image_basemap"):getChildByName("image_base_loading")
    local ui_buildBoxs = {}
    ui_buildBoxs[1] = {
        box = loadingPanel:getChildByName("image_box_first"),
        node = loadingPanel:getChildByName("image_first"),
        value = loadingPanel:getChildByName("image_first"):getChildByName("text_first_29")
    }
    ui_buildBoxs[2] = {
        box = loadingPanel:getChildByName("image_box_second"),
        node = loadingPanel:getChildByName("image_second"),
        value = loadingPanel:getChildByName("image_second"):getChildByName("text_second_31")
    }
    ui_buildBoxs[3] = {
        box = loadingPanel:getChildByName("image_box_third"),
        node = loadingPanel:getChildByName("image_third"),
        value = loadingPanel:getChildByName("image_third"):getChildByName("text_third_33")
    }
    local ui_loadingBar = loadingPanel:getChildByName("bar_loading")
    local ui_curValueLabel = loadingPanel:getChildByName("text_loading_now")
    local loadingBarLeftPosX = ui_loadingBar:getPositionX() - ui_loadingBar:getContentSize().width / 2
    for key, obj in pairs(ui_buildBoxs) do
        if boxData[key] then
            local dictObj = DictDailyTask[tostring(boxData[key].int["3"])]
            obj.box:setPositionX(loadingBarLeftPosX + (dictObj.plan / maxValue) * ui_loadingBar:getContentSize().width)
            obj.node:setPositionX(loadingBarLeftPosX + (dictObj.plan / maxValue) * ui_loadingBar:getContentSize().width)
            obj.value:setString(tostring(dictObj.plan))
            local _isStandard = false
            if currentValue >= dictObj.plan then
                _isStandard = true
            end
            local _isGetBox = false
            if boxData[key].int["5"] == 1 then
                _isGetBox = true
            end
            local _index = 1
            if _isStandard then
                _index = 3
                if _isGetBox then
                    _index = 2
                end
            end
            obj.box:loadTexture(buildBoxImgs[key][_index])
            obj.box:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    local _enabled = false
                    local _btnTitleText = Lang.ui_task_day7
                    if _isStandard and not _isGetBox then
                        _enabled = true
                    elseif _isGetBox then
                        _btnTitleText = Lang.ui_task_day8
                    end
                    local _rewardThings = dictObj.rewards
                    local _isJoinAlliance = (net.InstUnionMember and net.InstUnionMember.int["2"] ~= 0) and true or false
                    if not _isJoinAlliance then
                        local _tempRewardThings = ""
                        local _tempData = utils.stringSplit(_rewardThings, ";")
                        for _tempKey, _tempObj in pairs(_tempData) do
                            local _tempThings = utils.stringSplit(_tempObj, "_")
                            local _tableTypeId = tonumber(_tempThings[1])
                            local _tableFieldId = tonumber(_tempThings[2])
                            if not ((_tableTypeId == StaticTableType.DictUnionSkillNoFightProp and _tableFieldId == StaticUnionSkillNoFightProp.unionFund)
                            or (_tableTypeId == StaticTableType.DictThing and _tableFieldId == StaticThing.unionWand)) then
                                _tempRewardThings = _tempRewardThings .. _tempObj .. ";"
                            end
                        end
                        local strLastChar = string.sub(_tempRewardThings, string.len(_tempRewardThings), string.len(_tempRewardThings))
                        if strLastChar == ";" then
                            _tempRewardThings = string.sub(_tempRewardThings, 1, string.len(_tempRewardThings) - 1)
                        end
                        _rewardThings = _tempRewardThings
                    end
                    UIAwardGet.setOperateType(UIAwardGet.operateType.dailyTaskBox, {
                        btnTitleText = _btnTitleText,
                        enabled = _enabled,
                        things = _rewardThings,
                        isJoinAlliance = _isJoinAlliance,
                        callbackFunc = function() _awardData = utils.stringSplit(_rewardThings, ";"), sendRewardData(boxData[key].int["1"]) end
                    } )
                    UIManager.pushScene("ui_award_get")
                end
            end)
        end
    end
    ui_loadingBar:setPercent(utils.getPercent(currentValue, maxValue))
    ui_curValueLabel:setString(Lang.ui_task_day9 .. currentValue)

    UIGuidePeople.isGuide(nil,UITaskDay)
end

function UITaskDay.free()
	if taskItem and taskItem:getReferenceCount() >= 1 then
    taskItem:release()
    taskItem = nil
  end
	scrollView:removeAllChildren()
	_awardData = nil
end
