noticeMgr={
    isShowing=false,
    isFirstLogin=false,
    url="http://"..base.serverUserIp.."/tankheroclient/".."tankimg/".."notice/".."notice_advertise.jpg",
}

function noticeMgr:isShowNoticeDialog()
    if G_isHexie()==true then
        return false
    end
	local uid=playerVoApi:getUid()
    local noticeKey="lastNoticeLocalTime@"..tostring(uid).."@"..tostring(base.curZoneID)
    local lastTime=CCUserDefault:sharedUserDefault():getIntegerForKey(noticeKey)
    if G_isToday(lastTime)==false then
    	if acThreeYearVoApi then
            if(buildingGuildMgr and buildingGuildMgr.isGuilding==true) or (newGuidMgr and newGuidMgr.isGuiding==true) or (otherGuideMgr and otherGuideMgr.isGuiding==true)then
                return false
            end
			local acVo=acThreeYearVoApi:getAcVo()
			if activityVoApi:isStart(acVo)==true then
	            if self.isShowing==false and self.isFirstLogin==true and base.allShowedCommonDialog==0 and SizeOfTable(G_SmallDialogDialogTb)==0 then
                    return true
                end
			end
    	end
    end
    return false
end

function noticeMgr:setHasShow()
    self.isShowing=true
	local uid=playerVoApi:getUid()
    local noticeKey="lastNoticeLocalTime@"..tostring(uid).."@"..tostring(base.curZoneID)
    CCUserDefault:sharedUserDefault():setIntegerForKey(noticeKey,base.serverTime)
    CCUserDefault:sharedUserDefault():flush()
end

function noticeMgr:downloadNoticeImage()
    local function onLoadIcon(fn,icon)
    end
    local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("notice/notice_advertise.jpg"),onLoadIcon)
end

function noticeMgr:getDownloadUrl()
    return G_downloadUrl("notice/notice_advertise.jpg")
end

function noticeMgr:setFirstLogin()
    self.isFirstLogin=true
end

function noticeMgr:clear()
    self.isShowing=false
    self.isFirstLogin=false
end