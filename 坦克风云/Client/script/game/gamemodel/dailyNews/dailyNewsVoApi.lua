require "luascript/script/game/gamemodel/dailyNews/dailyNewsVo"

dailyNewsVoApi={
    newsList={},
    journalsNum=0,      --第几期
    headlinesNews={},   --头条
    isPraise=0,         --是否点过赞
    lastShareTime={0,0},--上次分享时间
    lastCollectTime=0,  --上次收藏时间
    flag=0, -- 是否弹过板子（0：没弹）
    lastGetDataTime=0,  --上一次初始化数据时间
}

function dailyNewsVoApi:clear()
    self.newsList={}
    self.journalsNum=0
    self.headlinesNews={}
    self.isPraise=0
    self.lastShareTime={0,0}
    self.lastCollectTime=0
    self.flag=0
    self.lastGetDataTime=0
end

function dailyNewsVoApi:getDailyNewsRequest(getCallback)
    local cmd="dailynews.news.list"
    local params={}
    local function onRequestEnd(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            self:formatData(sData)
            if getCallback then
                getCallback()
            end
        end
    end
    local callback=onRequestEnd
    return cmd,params,callback
end

function dailyNewsVoApi:showDailyNewsDialog(layerNum,headlinesData)
    local function showDialog( ... )
        require "luascript/script/game/scene/gamedialog/dailyNews/dailyNewsSmallDialog"
        self.flag=1
        local sd=dailyNewsSmallDialog:new()
        sd:init(layerNum,headlinesData)
    end
    local function showCallback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            self:formatData(sData)
        	showDialog()
        end
    end
    if G_isToday(self.lastGetDataTime)==true or (headlinesData and SizeOfTable(headlinesData)>0) then
        showDialog()
    else
        socketHelper:dailynewsNewsList(showCallback)
    end
end

function dailyNewsVoApi:showDailyNewsInfoDialog(flag,layerNum,infoTb)
	require "luascript/script/game/scene/gamedialog/dailyNews/dailyNewsInfoSmallDialog"
    local titleStr
	if flag==1 then -- 军团
        local allianceinfo=infoTb.allianceinfo
        if allianceinfo then
            titleStr=getlocal("alliance_info_title")
    		dailyNewsInfoSmallDialog:showAllianceInfo(layerNum,titleStr,allianceinfo,flag)
        end
	else -- 个人和天梯榜（个人和军团）
        local info   
        if flag==2 then
             titleStr=getlocal("playerRole")
            info=infoTb.userinfo
        elseif flag==3 then
             titleStr=getlocal("alliance_info_title")
            info=infoTb.skyladderAlliance
        elseif flag==4 then
             titleStr=getlocal("playerRole")
            info=infoTb.skyladderUser
        end
        if info then
    		dailyNewsInfoSmallDialog:showPersonalInfo(layerNum,titleStr,info,flag)
        end
	end
end

function dailyNewsVoApi:goAllianceDialog(layerNum,searchName)
	local buildVo=buildingVoApi:getBuildingVoByBtype(15)[1]--军团建筑
    if base.isAllianceSwitch==1 and buildVo and buildVo.status>=0 then
        allianceVoApi:showAllianceDialog(layerNum)
	else
		if base.isAllianceSwitch==0 then
	        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("alliance_willOpen"),nil,layerNum)
            do
                return
            end
        else
        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("port_scene_building_tip_6"),30)
        	return
        end 
	end
end

function dailyNewsVoApi:dailynewsNewsVote(newsId,callback)
    local function voteCallback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            local praiseNum=self:getPraiseNum()
            self:setPraiseNum(praiseNum+1)
            self:setIsPraise(1)
            if callback then
                callback()
            end
        end
    end
    socketHelper:dailynewsNewsVote(newsId,voteCallback)
end

function dailyNewsVoApi:dailynewsNewsComment(comment,callback)
    local function commentCallback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            self:setComment(comment)
            if callback then
                callback()
            end
        end
    end
    if self:isCanEdit()==true then
        local headlinesNews=self:getHeadlinesNews()
        if headlinesNews and headlinesNews.comment and headlinesNews.comment>0 then
        elseif headlinesNews.id and comment and comment~=0 then
            local commenter=playerVoApi:getPlayerName()
            socketHelper:dailynewsNewsComment(headlinesNews.id,comment,commenter,commentCallback)
        end
    end
end

function dailyNewsVoApi:formatData(sData)
    if sData then
        if sData.ts then
            self.lastGetDataTime=sData.ts
        end
        if sData.isVote~=nil then
            if sData.isVote==true then
                dailyNewsVoApi:setIsPraise(1)
            else
                dailyNewsVoApi:setIsPraise(0)
            end
        end
        local headlineType
        if sData.data and sData.data.headline then
            local headline=sData.data.headline
            self.headlinesNews={}
            local itemData={}
            local id=tonumber(headline.id)
            self:setJournalsNum(id)
            local dType = headline.title
            headlineType=dType
            local contentData = headline.content
            local userinfo,allianceinfo,skyladderUser,skyladderAlliance
            local pic=1
            if contentData and contentData.userinfo then
                for k,v in pairs(contentData.userinfo) do
                    if v and type(v)=="table" then
                        userinfo = v
                        pic=userinfo[1] or 1
                        break
                    end
                end
            end
            if contentData and contentData.allianceinfo then
                for k,v in pairs(contentData.allianceinfo) do
                    if v and type(v)=="table" then
                        allianceinfo = v
                        break
                    end
                end
            end
            if contentData and contentData.skyladderUser then
                for k,v in pairs(contentData.skyladderUser) do
                    if v and type(v)=="table" then
                        skyladderUser = v
                        pic=skyladderUser[5] or 1
                        break
                    end
                end
            end
            if contentData and contentData.skyladderAlliance then
                for k,v in pairs(contentData.skyladderAlliance) do
                    if v and type(v)=="table" then
                        skyladderAlliance = v
                        break
                    end
                end
            end
            -- local username = contentData.username
            -- local alliancename = contentData.alliancename
            -- local num = contentData.num or {}
            -- local other=contentData.other or {}
            local praiseNum = tonumber(headline.goodpost) or 0
            local comment = tonumber(headline.comment) or 0
            local commentPlayer = headline.commenter or ""
            local content = self:getNewsContent(headline)
            local itemData={id=id,type=dType,userinfo=userinfo,allianceinfo=allianceinfo,skyladderUser=skyladderUser,skyladderAlliance=skyladderAlliance,content=content,praiseNum=praiseNum,comment=comment,commentPlayer=commentPlayer,pic=pic}
            local dVo=dailyNewsVo:new()
            dVo:initWithData(itemData)
            self.headlinesNews=dVo
        end
        if sData.data and sData.data.newsList then
            local newsList=sData.data.newsList
            self.newsList={}
            local showNum=10
            local tmpList={}
            for k,v in pairs(newsList) do
                local id=tonumber(v.id)
                local dType = v.title
                if headlineType and headlineType==dType then
                else
                    local contentData = v.content
                    local userinfo,allianceinfo,skyladderUser,skyladderAlliance
                    local pic=1
                    if contentData and contentData.userinfo then
                        for k,v in pairs(contentData.userinfo) do
                            if v and type(v)=="table" then
                                userinfo = v
                                pic=userinfo[1] or 1
                                break
                            end
                        end
                    end
                    if contentData and contentData.allianceinfo then
                        for k,v in pairs(contentData.allianceinfo) do
                            if v and type(v)=="table" then
                                allianceinfo = v
                                break
                            end
                        end
                    end
                    if contentData and contentData.skyladderUser then
                        for k,v in pairs(contentData.skyladderUser) do
                            if v and type(v)=="table" then
                                skyladderUser = v
                                pic=skyladderUser[5] or 1
                                break
                            end
                        end
                    end
                    if contentData and contentData.skyladderAlliance then
                        for k,v in pairs(contentData.skyladderAlliance) do
                            if v and type(v)=="table" then
                                skyladderAlliance = v
                                break
                            end
                        end
                    end
                    -- local username = contentData.username
                    -- local alliancename = contentData.alliancename
                    -- local num = contentData.num or {}
                    -- local other=contentData.other or {}
                    local content = self:getNewsContent(v)
                    local itemData={id=id,type=dType,userinfo=userinfo,allianceinfo=allianceinfo,skyladderUser=skyladderUser,skyladderAlliance=skyladderAlliance,content=content,pic=pic}
                    local dVo=dailyNewsVo:new()
                    dVo:initWithData(itemData)
                    table.insert(tmpList,dVo)
                end
            end
            if tmpList and SizeOfTable(tmpList)>0 then
                local function sortFunc(a,b)
                    if a and b and a.type and b.type then
                        local aCfg=self:getCfgByType(a.type)
                        local bCfg=self:getCfgByType(b.type)
                        if aCfg and bCfg and aCfg.index and bCfg.index then
                            return aCfg.index<bCfg.index
                        -- else
                        --     return a.type<b.type
                        end
                    end
                end
                table.sort(tmpList,sortFunc)
                for k,v in pairs(tmpList) do
                    if k<=showNum then
                        table.insert(self.newsList,v)
                    end
                end 
            end
        end
    end
end

function dailyNewsVoApi:getNewsContent(itemData)
    local content=""
    if itemData and itemData.title and itemData.content then
        local contentKey,param="",{}
        local itemType=itemData.title
        local dType = tonumber(RemoveFirstChar(itemType)) or 0
        local contentData = itemData.content
        local userinfo,allianceinfo={},{}
        if contentData and contentData.userinfo then
            for k,v in pairs(contentData.userinfo) do
                if v and type(v)=="table" then
                    userinfo = v
                    break
                end
            end
        end
        if contentData and contentData.allianceinfo then
            for k,v in pairs(contentData.allianceinfo) do
                if v and type(v)=="table" then
                    allianceinfo = v
                    break
                end
            end
        end
        local name=""
        local infoData
        local cfg=self:getCfgByType(itemType)
        if cfg then
            if cfg.des then
                contentKey=cfg.des
            end
            if cfg.type==1 and allianceinfo then
                name=allianceinfo[1] or ""
            elseif cfg.type==2 and userinfo then
                name=userinfo[2] or ""
            elseif cfg.type==3 then
                infoData=contentData.skyladderAlliance
                if infoData and infoData[1] then
                    name=infoData[1][1] or ""
                end
            elseif cfg.type==4 then
                infoData=contentData.skyladderUser
                if infoData and infoData[1] then
                    name=infoData[1][1] or ""
                end
            end
        end
        local username = contentData.username or {}
        local alliancename = contentData.alliancename or {}
        local num = contentData.num or {}
        local other=contentData.other or {}
        if contentKey and contentKey~="" then
            if dType==14 or dType==15 or dType==16 or dType==22 then
                if username then
                    if dType==22 then
                        if cfg and cfg.des then
                            if username[1]~=0 and username[2]==0 then
                                contentKey=cfg.des.."_1"
                            elseif username[1]==0 and username[2]~=0 then
                                contentKey=cfg.des.."_2"
                            end
                        end
                        for k,v in pairs(username) do
                            if v and v~=0 and v~="" then
                                table.insert(param,v)
                            end
                        end
                        content=getlocal(contentKey,param)
                    elseif dType==14 or dType==15 then
                        for k,v in pairs(username) do
                            if v and v~=0 and v~="" then
                                local name=v
                                if k==1 then
                                    content=content..getlocal(contentKey,{name})
                                elseif k==2 then
                                    content=content..getlocal("daily_news_des_second",{name})
                                elseif k==3 then
                                    content=content..getlocal("daily_news_des_third",{name})
                                end
                            end
                        end
                    elseif dType==16 then
                        for k,v in pairs(username) do
                            if v and v~=0 and v~="" and num and num[k] then
                                local name,rank=v,playerVoApi:getRankName(tonumber(num[k]))
                                if k==1 then
                                    content=content..getlocal(contentKey,{name,rank})
                                elseif k==2 then
                                    content=content..getlocal("daily_news_des_extra1",{name,rank})
                                elseif k==3 then
                                    content=content..getlocal("daily_news_des_extra1",{name,rank})
                                end
                            end
                        end
                    end
                end
            elseif dType==23 or dType==26 then
                if infoData then
                    for k,v in pairs(infoData) do
                        if v and v[1] and v[1]~=0 and v[1]~="" then
                            local name=v[1]
                            if k==1 then
                                content=content..getlocal(contentKey,{name})
                            elseif k==2 then
                                content=content..getlocal("daily_news_des_second",{name})
                            elseif k==3 then
                                content=content..getlocal("daily_news_des_third",{name})
                            end
                        end
                    end
                end
            else
                param={name}
                if num then
                    for k,v in pairs(num) do
                        local value=tonumber(v)
                        if dType==4 or (dType==5 and k==2) then
                            value=playerVoApi:getRankName(value)
                        else
                            value=FormatNumber(value)
                        end
                        table.insert(param,value)
                    end
                end
                content=getlocal(contentKey,param)
            end
        end
    end
    return content
end

function dailyNewsVoApi:getNewsList()
    return self.newsList
end

function dailyNewsVoApi:getCfgByType(dType)
    if dType and dailyNewsCfg and dailyNewsCfg.dailyList and dailyNewsCfg.dailyList[dType] then
        return dailyNewsCfg.dailyList[dType]
    end
    return nil
end

function dailyNewsVoApi:getNewsTitle(dType)
    local title,key="",""
    if dType then
        local cfg=self:getCfgByType(dType)
        if cfg and cfg.name then
            title=getlocal(cfg.name) or ""
            key=cfg.name
        end
    end
    return title,key
end

function dailyNewsVoApi:getNewsAllianceIcon(callback,bgSize)
    local allianceIcon
    if callback then
        allianceIcon=LuaCCSprite:createWithSpriteFrameName("icon_bg_gray.png",callback)
    else
        allianceIcon=CCSprite:createWithSpriteFrameName("icon_bg_gray.png")
    end
    local icon=CCSprite:createWithSpriteFrameName("helpAlliance.png")
    icon:setPosition(getCenterPoint(allianceIcon))
    allianceIcon:addChild(icon)
    icon:setScale((allianceIcon:getContentSize().width+5)/icon:getContentSize().width)
    icon:setTag(1029)
    if bgSize then
        allianceIcon:setScale(bgSize/allianceIcon:getContentSize().width)
    end
    return allianceIcon
end

function dailyNewsVoApi:getNewsIcon(dVo,callback,bgSize)
    local newsIcon
    if dVo and dVo.type then
        local cfg=self:getCfgByType(dVo.type)
        if cfg and (cfg.type==1 or cfg.type==3) then
            newsIcon=self:getNewsAllianceIcon(callback,bgSize)
        elseif cfg and (cfg.type==2 or cfg.type==4) then
            if dVo.pic then
                local personPhotoName=playerVoApi:getPersonPhotoName(dVo.pic)
                if bgSize then
                    newsIcon = playerVoApi:GetPlayerBgIcon(personPhotoName,callback,nil,nil,bgSize)
                else
                    newsIcon = playerVoApi:GetPlayerBgIcon(personPhotoName,callback)
                end
            end
        end
    end
    return newsIcon
end

function dailyNewsVoApi:getHeadlinesNews()
    return self.headlinesNews
end

function dailyNewsVoApi:getJournalsNum()
    return self.journalsNum
end
function dailyNewsVoApi:setJournalsNum(num)
    self.journalsNum=num
end

function dailyNewsVoApi:getIsPraise()
    return self.isPraise
end
function dailyNewsVoApi:setIsPraise(isPraise)
    self.isPraise=isPraise
end

function dailyNewsVoApi:getPraiseNum()
    local num=0
    if self.headlinesNews and self.headlinesNews.praiseNum then
        num=tonumber(self.headlinesNews.praiseNum) or 0
    end
    return num
end
function dailyNewsVoApi:setPraiseNum(praiseNum)
    if praiseNum and self.headlinesNews then
        self.headlinesNews.praiseNum=tonumber(praiseNum)
    end 
end

function dailyNewsVoApi:setComment(comment,commentPlayer)
    if self.headlinesNews and comment then
        self.headlinesNews.comment=comment
        if commentPlayer then
            self.headlinesNews.commentPlayer=commentPlayer
        else
            self.headlinesNews.commentPlayer=playerVoApi:getPlayerName()
        end
    end 
end

function dailyNewsVoApi:getLastShareTime(cType)
    if cType and self.lastShareTime and self.lastShareTime[cType] then
        return self.lastShareTime[cType]
    else
        return 0
    end
end
function dailyNewsVoApi:setLastShareTime(cType,lastShareTime)
    if self.lastShareTime==nil then
        self.lastShareTime={}
    end
    if cType and lastShareTime then
        self.lastShareTime[cType]=lastShareTime
    end
end

function dailyNewsVoApi:getLastCollectTime()
    return self.lastCollectTime
end
function dailyNewsVoApi:setLastCollectTime(lastCollectTime)
    self.lastCollectTime=lastCollectTime
end

function dailyNewsVoApi:getLastGetDataTime()
    return self.lastGetDataTime
end

function dailyNewsVoApi:isCanEdit()
    local canEdit=false
    local headlinesNews=self:getHeadlinesNews()
    if headlinesNews and headlinesNews.type then
        local cfg=self:getCfgByType(headlinesNews.type)
        if cfg and cfg.type==1 then
            if headlinesNews.allianceinfo and headlinesNews.allianceinfo[11] then
                local aid=tonumber(headlinesNews.allianceinfo[11])
                local selfAlliance=allianceVoApi:getSelfAlliance()
                if selfAlliance and tonumber(selfAlliance.aid)==aid and tostring(selfAlliance.role)=="2" then
                    canEdit=true
                end
            end
        elseif cfg and cfg.type==2 then
            if headlinesNews.userinfo and headlinesNews.userinfo[6] then
                local pId=tonumber(headlinesNews.userinfo[6])
                if pId==tonumber(playerVoApi:getUid()) then
                    canEdit=true
                end
            end
        elseif cfg and cfg.type==3 then
            if headlinesNews.skyladderAlliance and headlinesNews.skyladderAlliance[1] and headlinesNews.skyladderAlliance[2] then
                local allianceName=headlinesNews.skyladderAlliance[1]
                local zoneID=headlinesNews.skyladderAlliance[2]
                local selfZoneID
                if base.curOldZoneID and base.curOldZoneID~="" and base.curOldZoneID~=0 and base.curOldZoneID~="" then
                    selfZoneID=base.curOldZoneID
                else
                    selfZoneID=base.curZoneID
                end
                local selfAlliance=allianceVoApi:getSelfAlliance()
                if tonumber(zoneID)==tonumber(selfZoneID) and selfAlliance and selfAlliance.name==allianceName and tostring(selfAlliance.role)=="2" then
                    canEdit=true
                end
            end
        elseif cfg and cfg.type==4 then
            if headlinesNews.skyladderUser and headlinesNews.skyladderUser[1] and headlinesNews.skyladderUser[2] then
                local playerName=headlinesNews.skyladderUser[1]
                local zoneID=headlinesNews.skyladderUser[2]
                local selfZoneID
                if base.curOldZoneID and base.curOldZoneID~="" and base.curOldZoneID~=0 and base.curOldZoneID~="" then
                    selfZoneID=base.curOldZoneID
                else
                    selfZoneID=base.curZoneID
                end
                if playerName==playerVoApi:getPlayerName() and tonumber(zoneID)==tonumber(selfZoneID) then
                    canEdit=true
                end
            end
        end
    end
    return canEdit
end

function dailyNewsVoApi:isPop()
    if base.dnews==0 then -- 开关没开
        return false
    end
    if self.flag==1 then -- 已经弹了
        return false
    end

    if(buildingGuildMgr and buildingGuildMgr.isGuilding==true) or (newGuidMgr and newGuidMgr.isGuiding==true) or (otherGuideMgr and otherGuideMgr.isGuiding==true)then -- 有引导
        return false
    end

    if base.allShowedCommonDialog==0 and SizeOfTable(G_SmallDialogDialogTb)==0 then
    else --有弹的板子 
        return false
    end

    if self:hasData()==true then
        local key="dailyNews@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
        local time=CCUserDefault:sharedUserDefault():getIntegerForKey(key)
        if time then
            local flag=G_isToday(time)
            self.flag=1
            if flag==true then -- 已经弹了
                return false
            else
                -- 设置弹出时间
                CCUserDefault:sharedUserDefault():setIntegerForKey(key,base.serverTime)
                CCUserDefault:sharedUserDefault():flush()
                -- 判断开关是否开启
                local switch_dailyNewspaper = CCUserDefault:sharedUserDefault():getIntegerForKey("gameSetting_dailyNewspaper")
                if switch_dailyNewspaper == 1 then
                    -- 开关没开
                    return false
                else
                    return true
                end
            end
        end
    end
    return false
end

function dailyNewsVoApi:isPopDialog()
    local flag=self:isPop()
    if flag==true then
        self:showDailyNewsDialog(3)
    end
end

function dailyNewsVoApi:hasData()
    if self.headlinesNews and SizeOfTable(self.headlinesNews)>0 then
        return true
    else
        return false
    end
end


