require"Lang"
UIActivitySuccess = {
	operateType = {
		success = 1,
		mail  = 2,
	}
}
local _operateType = nil 
local scrollView =nil 
local listItem =nil 

function UIActivitySuccess.setOperateType(operateType)
	_operateType = operateType
end

function UIActivitySuccess.init()
	scrollView = ccui.Helper:seekNodeByName(UIActivitySuccess.Widget, "view_success") --  滚动层
    listItem = scrollView:getChildByName("image_base_success"):clone()
end
----比较规则 先领取 后前往 在完成
local function compareAchi(value1,value2)
	if value1.int["4"] ~= 0 and value1.int["5"] ==0 and value2.int["5"] ~=0 then 
		return true
	elseif value1.int["5"] ~=0 and value2.int["5"] ==0 then 
		return false
	else 
		if value1.int["4"] == 0 and value2.int["4"] ~= 0 then 
			return true
		elseif value1.int["4"] ~= 0 and value2.int["4"] == 0 then 
			return false
		else 
			return false
		end
	end
end
local function findCurValue(sname)
	for key,obj in pairs(net.InstPlayerAchievementValue) do 
		if DictAchievementType[tostring(obj.int["3"])].sname == sname then 
			return obj.int["4"]
		end
	end
end

function UIActivitySuccess.checkImageHint()
    local Thing={}
    if net.InstPlayerAchievement then 
       for key, obj in pairs(net.InstPlayerAchievement) do
            table.insert(Thing,obj)
       end
       utils.quickSort(Thing,compareAchi)
    end
    for key, obj in pairs(Thing) do
        local achieveId= obj.int["4"]
	    local canAchieveId = obj.int["5"]
        if achieveId == 0 and  canAchieveId ~= 0 then --完成了但没领取
            return true
        elseif achieveId ~= 0 and  canAchieveId ~= 0 then --没完成领取
            return true
        end
    end
    return false
end

local function getCurValueByName(sname,dictData)
	local curState = 0
	if sname == "pcLevel" then 
		curState   = net.InstPlayer.int["4"]
	elseif sname == "pagoda" then 
		if net.InstPlayerPagoda then 
			curState   = net.InstPlayerPagoda.int["7"]
		end
	elseif sname == "fightValue" then 
		curState = utils.getFightValue()
	elseif sname == "vip" then 
		curState   = net.InstPlayer.int["19"]
	elseif sname == "fire" then 
		curState   = 0
	elseif sname == "barrier" then 
		local chapterId = tonumber(dictData.conditions)
		for key,obj in pairs(net.InstPlayerChapter) do 
			if obj.int["3"] == chapterId and obj.int["6"] == 1 then 
				curState   = 1
			end
		end
	else
		curState   = findCurValue(sname)
	end
	return curState
end

local function setAchiScrollViewItem(_Item, _obj)
	local ui_name  = ccui.Helper:seekNodeByName(_Item,"text_task_name")
	local ui_image = ccui.Helper:seekNodeByName(_Item,"image_task")
	local ui_plan  = ccui.Helper:seekNodeByName(_Item,"text_plan")
	local ui_award = ccui.Helper:seekNodeByName(_Item,"text_award_info")
	local ui_text_award = ccui.Helper:seekNodeByName(_Item,"text_award")
	local btn_prize= ccui.Helper:seekNodeByName(_Item,"btn_prize")
	local achieveId= _obj.int["4"]
	local canAchieveId = _obj.int["5"]
	local achTypeId= _obj.int["3"]
	local showAchieveId = _obj.int["4"]
	local dictTypeData = DictAchievementType[tostring(achTypeId)]
	local sname    = dictTypeData.sname 
	local smallUiId= dictTypeData.smallUiId
	local status = 0
	if achieveId == 0 and  canAchieveId == 0 then --已完成
		btn_prize:setTitleText(Lang.ui_activity_success1)
		btn_prize:loadTextureNormal("ui/tk_btn02.png")
		btn_prize:setEnabled(false)
		btn_prize:setPressedActionEnabled(false)
		ui_plan:setVisible(false)
	elseif achieveId == 0 and  canAchieveId ~= 0 then --完成了但没领取
		showAchieveId = canAchieveId-- 领取的时候，以第5字段为id
		status = 1
		ui_plan:setVisible(false)
		btn_prize:setTitleText(Lang.ui_activity_success2)
        btn_prize:loadTextures("ui/tk_btn01.png", "ui/tk_btn01.png")
        btn_prize:setEnabled(true)
        btn_prize:setPressedActionEnabled(true)
	elseif achieveId ~= 0 and  canAchieveId == 0 then --前往
		status = 0
		ui_plan:setVisible(true)
		btn_prize:setTitleText(Lang.ui_activity_success3)
		btn_prize:loadTextures("ui/tk_jm_btn.png", "ui/tk_jm_btn.png")
		btn_prize:setEnabled(true)
		btn_prize:setPressedActionEnabled(true)
	elseif achieveId ~= 0 and  canAchieveId ~= 0 then --没完成领取
		showAchieveId = canAchieveId-- 领取的时候，以第5字段为id
		status = 1
		ui_plan:setVisible(false)
		btn_prize:setTitleText(Lang.ui_activity_success4)
        btn_prize:loadTextures("ui/tk_btn01.png", "ui/tk_btn01.png")
		btn_prize:setEnabled(true)
		btn_prize:setPressedActionEnabled(true)
	end
	local _getThing = nil
	if achieveId == 0 and  canAchieveId == 0 then
		ui_name:setString(dictTypeData.name)
		ui_award:setString("")
		ui_text_award:setVisible(false)
	else 
		ui_text_award:setVisible(true)
		local dictData = DictAchievement[tostring(showAchieveId)]
		local curState = getCurValueByName(sname,dictData)
		local rewards  = dictData.rewards
		local rewardName = ""
		_getThing = utils.stringSplit(rewards,";")
	    for key,value in pairs(_getThing) do
	    	if value ~= "" then 
	          local num= utils.stringSplit(value,"_")
	          local name = utils.getDropThing(num[1],num[2])
	          if name then 
	          	if key == #_getThing then 
	          		rewardName = rewardName .. name .. "×" .. num[3]
	          	elseif key == 1 then 
	          		rewardName = rewardName .. name .. "×" .. num[3] .. ","
	          	else 
	          		rewardName = rewardName .. name .. "×" .. num[3] .. ","
	          	end
	          end
	        end
	    end
		ui_name:setString(dictData.name)
		ui_award:setString(rewardName)
		ui_plan:setString(string.format("%d/%d",curState,tonumber(dictData.progress)))
	end
	ui_image:loadTexture("image/" .. DictUI[tostring(smallUiId)].fileName)
	local openLevel = 0 
	if dictTypeData.functionOpenId ~= 0 then 
		openLevel = DictFunctionOpen[tostring(dictTypeData.functionOpenId)].level
	end
	local function btnEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            sender:retain()
            if status == 0 then 
            	if net.InstPlayer.int["4"] >= openLevel then 
	            	if sname == "pcLevel" or sname == "chapter" or sname == "purpleEquip" or sname == "barrier" then 
	            		UIManager.showScreen("ui_notice","ui_team_info","ui_fight","ui_menu")
	            	elseif sname == "hJYStore" then 
					    UIActivityPanel.scrollByName(sname)
	            	elseif sname == "wash" then 
	            		UIManager.showScreen("ui_notice","ui_team_info","ui_bag_equipment","ui_menu")
	            	elseif sname == "arena" then 
	            		UIManager.showScreen("ui_notice","ui_arena","ui_menu")
	            	elseif sname == "pagoda" then 
	            		 UIManager.showScreen("ui_notice","ui_tower_test","ui_menu")
	            	elseif sname == "worldBoss" then 
	            		UIManager.showScreen("ui_notice","ui_boss","ui_menu")
	            	elseif sname == "fightValue" then 
	            		UIManager.showScreen("ui_notice","ui_team_info","ui_bag_card","ui_menu")
	            	elseif sname == "strengthen" or sname == "inlay" then 
	            		UIManager.showScreen("ui_notice","ui_team_info","ui_bag_equipment","ui_menu")
	            	elseif sname == "addPill" or sname == "addEquip" or sname == "title1" or 
	            		sname == "advance" or sname == "title5" then 
                        UILineup.friendState = 0
	            		UIManager.showScreen("ui_notice","ui_lineup","ui_menu")
	            	elseif sname == "magic1" or sname == "magic2" then 
	            		UIManager.hideWidget("ui_activity_panel")
	            		UILoot.show(1,1)
	            	elseif sname == "vip" then 
	            		utils.checkGOLD(1)
	            	end
	            else 
	            	UIManager.showToast(string.format(Lang.ui_activity_success5,openLevel))
	            end
            elseif status == 1 then 
            	UIManager.showLoading()
            	netSendPackage({header = StaticMsgRule.achievementReward,
            	 msgdata = {int={instPlayerAchievementId =_obj.int["1"]}}},function ()
            	 	UIManager.flushWidget(UIActivitySuccess)
            	 	UIAwardGet.setOperateType(UIAwardGet.operateType.award,_getThing)
   					UIManager.pushScene("ui_award_get")
                    UIActivityPanel.addImageHint(UIActivitySuccess.checkImageHint(),"achievement")
            	 end)
            end
            cc.release(sender)
        end
    end
    
    btn_prize:addTouchEventListener(btnEvent)

end

local function compareMail(value1,value2)
	if value1.int["4"] == 1 and value2.int["4"] == 2 then 
		return true
	elseif (value1.int["4"] == 1 and value2.int["4"] == 1) or (value1.int["4"] == 2 and value2.int["4"] == 2) then 
		local iTime1 = utils.GetTimeByDate(value1.string["7"]) 
		local iTime2 = utils.GetTimeByDate(value2.string["7"]) 
		return iTime1 < iTime2
	else
		return false
	end
end

local function setMailScrollViewItem(_Item, _obj)
	local btn_go = _Item:getChildByName("btn_go")
	local ui_name = _Item:getChildByName("text_title")
	local ui_time = _Item:getChildByName("text_time")
	local ui_description = ccui.Helper:seekNodeByName(_Item,"text_info")
	local _type =_obj.int["4"]
	btn_go:setPressedActionEnabled(true)
	local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
        	sender:retain()
        	if _type == 1 then
        		UIManager.hideWidget("ui_activity_panel")
        		UILoot.show(1,1)
        	elseif _type == 2 then 
        		UIManager.hideWidget("ui_activity_panel")
        		UIManager.showWidget("ui_arena")
        	end
        	cc.release(sender)
       	end
    end
    btn_go:addTouchEventListener(btnTouchEvent)  
    local serverTime = utils.GetTimeByDate(_obj.string["9"]) 
    local currentTime = utils.getCurrentTime()
    local subTime = currentTime - serverTime
    local timeText = nil
    
    if math.floor(subTime/(3600*24)) > 0 then 
    	timeText = math.floor(subTime/(3600*24)) .. Lang.ui_activity_success6
    elseif math.floor(subTime/3600) > 0 then 
    	timeText = math.floor(subTime/3600) .. Lang.ui_activity_success7
    elseif math.floor(subTime/60) > 0 then 
    	timeText = math.floor(subTime/60) .. Lang.ui_activity_success8
    elseif math.floor(subTime%60) > 0 then
    	timeText = math.floor(subTime%60) .. Lang.ui_activity_success9
    end
    ui_time:setString(timeText)
	if _type == 1 then 
		btn_go:setTitleText(Lang.ui_activity_success10)
		ui_name:setString(Lang.ui_activity_success11)
		local chipId = _obj.int["5"] 
		local chipName = DictChip[tostring(chipId)].name 
		ui_description:setString(string.format(Lang.ui_activity_success12,_obj.string["3"],chipName))
	elseif _type == 2 then 
		ui_name:setString(Lang.ui_activity_success13)
		btn_go:setTitleText(Lang.ui_activity_success14)
		ui_description:setString(string.format(Lang.ui_activity_success15,_obj.string["3"],_obj.int["5"]))
	end
end

function UIActivitySuccess.setup()
	if listItem:getReferenceCount() == 1 then 
        listItem:retain()
    end
    scrollView:removeAllChildren()
    local Thing={}
    if _operateType == UIActivitySuccess.operateType.success and net.InstPlayerAchievement then 
       for key, obj in pairs(net.InstPlayerAchievement) do
            table.insert(Thing,obj)
       end
       utils.quickSort(Thing,compareAchi)
    end
    if next(Thing) then
    	if _operateType == UIActivitySuccess.operateType.success then 
    		utils.updateView(UIActivitySuccess,scrollView,listItem,Thing,setAchiScrollViewItem)
    	end
    end
end

function UIActivitySuccess.free( ... )
	_operateType = nil
	scrollView:removeAllChildren()
end
