-- require "luascript/script/config/gameconfig/energyNightCfg"
receivereward2VoApi={
	flag = false,
}

function receivereward2VoApi:getFlag()
	return self.flag
end

function receivereward2VoApi:getTimeStr()
	local time1 = string.format("%02d:%02d",getEnergyNightCfg.opentime[1][1],getEnergyNightCfg.opentime[1][2])
	local time2 = string.format("%02d:%02d",getEnergyNightCfg.opentime[2][1],getEnergyNightCfg.opentime[2][2])
	local timeStr = string.format("%s~%s",time1,time2)
	return timeStr
end

function receivereward2VoApi:clear()
	self.flag = false
end

function receivereward2VoApi:checkShopOpen()

	local openTime = getEnergyNightCfg.opentime[1][1]*60*60+getEnergyNightCfg.opentime[1][2]*60
	local endTime = getEnergyNightCfg.opentime[2][1]*60*60+getEnergyNightCfg.opentime[2][2]*60
	if base.meirilingjiangTime-(G_getWeeTs(base.meirilingjiangTime)+openTime)<0 then
		return 1
	elseif base.meirilingjiangTime-(G_getWeeTs(base.meirilingjiangTime)+endTime)>0 then
		return false
	else
		return 2
	end
end


function receivereward2VoApi:showShop(layerNum)
	if self:checkShopOpen()==2 then
		local function callBack(fn,data)
			local ret,sData = base:checkServerData(data)
			if ret==true then 
                if sData.data==nil then 
                  return
                end

				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),28)
				local jiangli = FormatItem(getEnergyNightCfg.reward)
				--军令特权
				local moPrivilegeFlag, moPrivilegeValue
				if militaryOrdersVoApi then
					moPrivilegeFlag, moPrivilegeValue = militaryOrdersVoApi:isUnlockByPrivilegeId(4)
				end
				if moPrivilegeFlag == true and moPrivilegeValue then
					jiangli[1].num = jiangli[1].num * moPrivilegeValue
				end
				G_addPlayerAward(jiangli[1].type,jiangli[1].key,jiangli[1].id,jiangli[1].num,false,true)
				self.flag=true
				-- receivereward2Vo:dispose()
			end
		end
		if self.flag==false then
			socketHelper:activityGetenergy(2,callBack)
		end
	else
		-- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_nostart"),28)
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("not_to_time"),28)
		
		-- local jiangli = FormatItem(getEnergyNightCfg.reward)
		-- local str = jiangli[1].name
		-- str = string.format("%sx%d",str,jiangli[1].num)
		-- local dialog = smallDialog:showInfo("PanelPopup.png",CCSizeMake(500,200),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,layerNum+1,25,{{"energyIcon.png",str}},CCSizeMake(450,160))
		-- sceneGame:addChild(dialog,layerNum)

	end
end




