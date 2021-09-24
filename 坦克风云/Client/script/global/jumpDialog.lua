jumpScrollMgr={
	messageTb={},
	isGuilding=false, --当前是否在引导
}

-- {key="honorUpgradeMessage",param={{"dksdkks",1},{6,3}}},{key="honorUpgradeMessage",param={{"dksdkks",1},{6,3}}},{key="honorUpgradeMessage",param={{"dksdkks",1},{{e={{a1=50},},},4}}}

function jumpScrollMgr:isGuiding()
	if self.isGuilding==false and SizeOfTable(self.messageTb)~= 0 then
		return true
	end
	return false
end

function jumpScrollMgr:showScrollMessage()
	if self.isGuilding==true or SizeOfTable(self.messageTb)==0 then
		do return end
	end
	self.isGuilding=true
	local msg=self.messageTb[1]
	self.loopc=msg.loopc or 1 --滚动次数，默认为1次
	self.curloop=1
	scrollSmallDialog:showScrollDialog(self.messageTb[1])
end

function jumpScrollMgr:addScrollMessage(msg)
	if msg.sys then --如果是系统滚屏消息的话就直接插入到队列的最前面
		table.insert(jumpScrollMgr.messageTb,1,msg)
		do return end
	end
	table.insert(jumpScrollMgr.messageTb,msg)
	if SizeOfTable(jumpScrollMgr.messageTb)>20 then
		table.remove(jumpScrollMgr.messageTb,1)
	end
end

function jumpScrollMgr:scrollEndHandler()
	if self.loopc<=self.curloop then --滚动次数已达上限则移除该滚动消息
		self.isGuilding=false
		table.remove(self.messageTb,1)
	else --如果没有达到滚动要求的次数则次数加1，再滚动一次
		self.curloop=self.curloop+1
		scrollSmallDialog:showScrollDialog(self.messageTb[1])
	end
end

function jumpScrollMgr:clear()
	self.messageTb={}
	self.isGuilding=false
	self.loopc=0
	self.curloop=0
end

function jump_judgment(functionStr,params) --根据判断条件判断跳转
	if functionStr=="map" then
		if type(params) == "table" then
			if playerVoApi:getPlayerLevel()<3 then
				do return end
			end
	        activityAndNoteDialog:closeAllDialog()
	        -- G_closeAllSmallDialog()
	        mainUI:changeToWorld()
	    	worldScene:focus(params[1], params[2])
		else
			G_goToDialog("pp")
		end
		return
	elseif functionStr=="guanqia" then
		storyScene:setShow()
		return
	elseif functionStr=="juntuan" then
		if playerVoApi:getPlayerAid() and playerVoApi:getPlayerAid()>0 then
			jump_allianceExist(1)

			local td=allianceFuDialog:new(3+1)
			local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("alliance_duplicate"),true,3+1)
			sceneGame:addChild(dialog,3+1)
		else
	    	jump_showTip(getlocal("joinAllianceMessage"))
		end
		return
	elseif functionStr=="juntuan2" then
		local bid=1
		local bType=7
		local buildVo=buildingVoApi:getBuildiingVoByBId(bid)
		if buildVo and buildVo.level<5 then --指挥中心5级开放军团
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("port_scene_building_tip_6"),30)
			do return end
		end
		if allianceVoApi:isHasAlliance()==false then
			jump_alliance()
        else
            jump_allianceExist()
        end
        return
	elseif functionStr=="boss" then
		local acAndNote = jump_acAndNote()
		acAndNote:tabClick(1)
	local allDailyActive=dailyActivityVoApi:getAllActivity()
		for k,v in pairs(allDailyActive) do
			if v.type=="boss" then
				dailyActivityVoApi:showDialog(k,3)
				return
			end

		end
		return
	elseif functionStr=="vip" then
		vipVoApi:showRechargeDialog(3)
		return
	elseif functionStr=="dailyLottery" then
		if base.dailyAcYouhuaSwitch==1 then
			local acAndNote = jump_acAndNote()
			acAndNote:tabClick(1)
			local allDailyActive=dailyActivityVoApi:getAllActivity()
			for k,v in pairs(allDailyActive) do
				if v.type=="dailyLottery" then
					dailyActivityVoApi:showDialog(k,6)
					return
				end

			end
		else
			dailyVoApi:showDailyDialog(3)
		end
		return
	elseif functionStr=="ttjj" then
			dailyTtjjVoApi:showDialog(3)	
		return
	elseif functionStr=="smbd" then
		local acVo = acSmbdVoApi:getAcVo()
		if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
	return
	elseif functionStr=="thfb" then
		if acThfbVoApi and acThfbVoApi.showDialog then
			acThfbVoApi:showDialog(0)
			return
		end
	elseif functionStr=="mjzy" then
		if acMjzyVoApi and acMjzyVoApi.showDialog then
			acMjzyVoApi:showDialog(0)
			return
		end
	elseif functionStr == "xlys" then
		if acXlysVoApi and acXlysVoApi.showDialog then
			acXlysVoApi:showDialog(0)
			return
		end
	elseif functionStr=="emblem" then
		if(base.emblemSwitch==1 and playerVoApi:getPlayerLevel()>=emblemCfg.equipOpenLevel)then
			emblemVoApi:showMainDialog(3)
		else
			if(base.emblemSwitch~=1)then
				jump_showTip(getlocal("backstage17000"))
			else
				jump_showTip(getlocal("expeditionNotEnough",{emblemCfg.equipOpenLevel}))
			end
		end
		do return end
	elseif functionStr =="double11NewWithRedBag" then
		if acDouble11NewVoApi then
			acDouble11NewVoApi:getRedBag()
		end
		return
	elseif functionStr =="acXssd2019WithRedBag" then
		if acXssd2019VoApi then
			acXssd2019VoApi:getRedBag(params)
		end
		return
	elseif functionStr =="armor" then
		if armorMatrixVoApi:canOpenArmorMatrixDialog(isTips) then
			local function showCallback()
				armorMatrixVoApi:showArmorMatrixDialog(4)
				armorMatrixVoApi:showRecruitDialog(5)
			end
			armorMatrixVoApi:armorGetData(showCallback)
			return
		end
	elseif functionStr =="dnews" then
		if dailyNewsVoApi then
			dailyNewsVoApi:showDailyNewsDialog(5)
		end
		return
	end

	local subArr=Split(functionStr,"_")
	if subArr[1]=="wanshengjiedazuozhan" then
		local acVo = acWanshengjiedazuozhanVoApi:getAcVo()
	    if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
	elseif subArr[1]=="yijizaitan" then
		local acVo = acYijizaitanVoApi:getAcVo()
	    if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
    elseif subArr[1]=="halloween" then
		local acVo = acSweetTroubleVoApi:getAcVo()
	    if activityVoApi:isStart(acVo)==true then
	    	local superWeaponOpenLv=base.superWeaponOpenLv or 25
	    	if playerVoApi:getPlayerLevel()>= superWeaponOpenLv then
	    		jump_assignActivity(acVo)
	    	else
	    		jump_showTip(getlocal("local_war_level_limit",{superWeaponOpenLv}))
	    		return
	    	end
	    	
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
    elseif subArr[1]=="feixutansuo" then
		local acVo = acFeixutansuoVoApi:getAcVo()
	    if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
    elseif subArr[1]=="jidongbudui" then
		local acVo = acJidongbuduiVoApi:getAcVo()
	    if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
    elseif subArr[1]=="benfuqianxian" then
		local acVo = acBenfuqianxianVoApi:getAcVo()
	    if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
    elseif subArr[1]=="olympic" then
		local acVo = acOlympicVoApi:getAcVo(functionStr)
	    if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
	elseif subArr[1]=="new112018" then
		local acVo = acDoubleOneVoApi:getAcVo( )
		if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
	elseif subArr[1]=="double11" then
		local acVo = acDouble11VoApi:getAcVo( )
		if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
	elseif subArr[1]=="double11new" then
		local acVo = acDouble11NewVoApi:getAcVo( )
		if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
    elseif subArr[1]=="autumnCarnival" then
		local acVo = acAutumnCarnivalVoApi:getAcVo(functionStr)
	    if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
    elseif subArr[1]=="zhanshuyantao" then
		local acVo = acTacticalDiscussVoApi:getAcVo(functionStr)
	    if activityVoApi:isStart(acVo)==true then
	    	local heroOpenLv=base.heroOpenLv or 20
	    	if playerVoApi:getPlayerLevel()>= heroOpenLv then
	    		jump_assignActivity(acVo)
	    	else
	    		jump_showTip(getlocal("local_war_level_limit",{heroOpenLv}))
	    		return
	    	end
	    	
	    else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
    elseif subArr[1]=="gqkh" then
    	local acVo = acGqkhVoApi:getAcVo(functionStr)
	    if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
    elseif subArr[1]=="threeyear" then
		local acVo = acThreeYearVoApi:getAcVo()
	    if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
    elseif subArr[1]=="wsjdzz" then
		local acVo = acWsjdzzVoApi:getAcVo()
	    if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
    elseif subArr[1]=="christmas2016" then
		local acVo=acChristmasAttireVoApi:getAcVo()
	    if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
    elseif subArr[1]=="openyear" then
		local acVo = acOpenyearVoApi:getAcVo(functionStr)
	    if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
    elseif subArr[1]=="mineExplore" then
		local acVo = acMineExploreVoApi:getAcVo()
	    if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
	elseif subArr[1]=="mineExploreG" then
		local acVo = acMineExploreGVoApi:getAcVo()
	    if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
	elseif subArr[1]=="loversDay" then
		local acVo = acLoversDayVoApi:getAcVo()
	    if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
    elseif subArr[1]=="djrecall" then
    	local acVo=acGeneralRecallVoApi:getAcVo()
	    if activityVoApi:isStart(acVo)==true then
	    	local ptype=acGeneralRecallVoApi:getPlayerType()
	    	if ptype==1 and params and params.inviteCode then
	    		acGeneralRecallVoApi:setInviteCode(params.inviteCode)
	    	end
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end	
    elseif subArr[1]=="cjyx" then
		local acVo=acCjyxVoApi:getAcVo()
	    if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
    elseif subArr[1]=="qxtw" then
		local acVo = acQxtwVoApi:getAcVo(functionStr)
	    if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
    elseif subArr[1]=="yswj" then
		local acVo = acYswjVoApi:getAcVo()
	    if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end
    elseif subArr[1]=="ydcz" then --月度充值
    	if acYdczVoApi then
			local acVo=acYdczVoApi:getAcVo()
		    if activityVoApi:isStart(acVo)==true then
		    	jump_assignActivity(acVo)
	    	else
		    	jump_showTip(getlocal("activeEndMessage"))
		    end
    	end
	else
		local acVo = activityVoApi:getActivityVo(functionStr)
		if activityVoApi:isStart(acVo)==true then
	    	jump_assignActivity(acVo)
    	else
	    	jump_showTip(getlocal("activeEndMessage"))
	    end	
	end
end



function jump_acAndNote()
	local acAndNote = activityAndNoteDialog:new()
    local tbArr={getlocal("activity"),getlocal("dailyActivity_title"),getlocal("note")}
    local vd = acAndNote:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("activityAndNote_title"),true,3);
    -- if  noteVoApi:hadNewNote() == true then
    --     acAndNote:tabClick(2)
    -- end
    sceneGame:addChild(vd,3);
    return acAndNote
end

function jump_allianceExist(idx)
	-- allianceEventVoApi:clear()
 --    require "luascript/script/game/scene/gamedialog/allianceDialog/allianceExistDialog"
 --    local td=allianceExistDialog:new(1,3)
 --    G_AllianceDialogTb[1]=td
 --    local tbArr={getlocal("alliance_info_title"),getlocal("alliance_function"),getlocal("alliance_list_scene_list")}
 --    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_list_scene_name"),true,3)
 --    sceneGame:addChild(dialog,3)
 --    if idx then
 --    	td:tabClick(1)
 --    end 
 	allianceVoApi:showAllianceDialog(3)
end

function jump_alliance()
	require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialog"
    local td=allianceDialog:new(1,3)
    G_AllianceDialogTb[1]=td
    local tbArr={getlocal("recommendList"),getlocal("alliance_list_scene_create")}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_list_scene_name"),true,3)
    sceneGame:addChild(dialog,3)
end

function jump_showTip(message)
	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),message,30)
end

function jump_assignActivity(acVo)
	local acAndNote = jump_acAndNote()
	local allVo = activityVoApi:getAllActivity()
	for k,v in pairs(allVo) do
		if v.type==acVo.type then
			acAndNote:openInfo(k-1)
			return
		end
	end
end


