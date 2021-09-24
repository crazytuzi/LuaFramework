require "luascript/script/game/gamemodel/ltzdz/ltzdzAttackReportVo"
require "luascript/script/game/gamemodel/ltzdz/ltzdzTransReportVo"

ltzdzReportVoApi={
	reportList={{},{}},
	reportExpireTime={0,0},
	nr={0,0}, --是否有新战报的标识
}

function ltzdzReportVoApi:setNewReport(nr)
	self.nr=nr
	eventDispatcher:dispatchEvent("ltzdz.refreshTip",{tipType="report"})
end

function ltzdzReportVoApi:setNewReportByType(rtype,num)
	if self.nr==nil then
		self.nr={0,0}
	end
	self.nr[rtype]=num
	eventDispatcher:dispatchEvent("ltzdz.refreshTip",{tipType="report"})
end

function ltzdzReportVoApi:hasNewReport(rtype)
	return self.nr[rtype] or 0
end

function ltzdzReportVoApi:getReportListByType(rtype)
	return self.reportList[rtype]
end

function ltzdzReportVoApi:getReportById(rtype,rid)
	local reportList=self:getReportListByType(rtype)
	if reportList then
		for k,v in pairs(reportList) do
			if tonumber(v.rid)==tonumber(rid) then
				return v
			end
		end
	end
	return nil
end

--战报详情
function ltzdzReportVoApi:addContent(rid,rtype,data)
	local reportVo=self:getReportById(rtype,rid)
	if reportVo~=nil then
		if reportVo.isRead==nil then
			reportVo.isRead={}
		end
		local myUid=playerVoApi:getUid()
		table.insert(reportVo.isRead,myUid)
		reportVo:addContent(data)
	end
end

function ltzdzReportVoApi:formatReportList(rtype,callback,isPage)
	local function reportCallback(sData)
		if sData and sData.data then
			if sData.data.list then
				for k,v in pairs(sData.data.list) do
					local rid=tonumber(v.id)
					local rtype=tonumber(v.type)
					local report=self:getReportById(rtype,rid)
					if report==nil then
						local reportVo
						if rtype==1 then
							reportVo=ltzdzAttackReportVo:new()
						elseif rtype==2 then
							reportVo=ltzdzTransReportVo:new()
						end
						if reportVo then
							reportVo:initWithData(v)
						end
				        table.insert(self.reportList[rtype],reportVo)
					end
				end
				local function sortAsc(a, b)
					if a and b and a.time and b.time then
						return a.time>b.time
					end
				end
				table.sort(self.reportList[rtype],sortAsc)
	            ltzdzReportVoApi:setNewReportByType(rtype,0)
				eventDispatcher:dispatchEvent("ltzdz.refreshTip",{tipType="report"})
			end
			self:setReportExpireTime(rtype,base.serverTime+300)
		end
	end
	local httphost=ltzdzVoApi:getHttphostUrl()
	if httphost then
		if isPage==true then
			-- local mineid,maxeid=self:getMinAndMaxId(rtype)
			-- local warId=platWarVoApi:getWarID()
			-- local httpUrl=self.httphost.."report"
			-- local reqStr="uid="..playerVoApi:getUid().."&bid="..warId.."&mineid="..mineid.."&maxeid="..maxeid.."&action="..rtype
			-- -- deviceHelper:luaPrint(httpUrl)
			-- -- deviceHelper:luaPrint(reqStr)
			-- local retStr=G_sendHttpRequestPost(httpUrl,reqStr)
			-- -- deviceHelper:luaPrint(retStr)
			-- if(retStr~="")then
			-- 	local retData=G_Json.decode(retStr)
			-- 	if (retData["ret"]==0 or retData["ret"]=="0") and retData.data then
			-- 		reportCallback(retData)
			-- 	end
			-- end
		elseif base.serverTime>self:getReportExpireTime(rtype) then
			--http://192.168.8.213/tank-servertest/public/index.php/api/mapwar/getreportlist?roomid=1&uid=3000281&type=1
			self.reportList[rtype]={}
			local httpUrl=httphost.."getreportlist"
			local roomid=ltzdzVoApi.clancrossinfo.roomid
			local reqStr="roomid="..roomid.."&uid="..playerVoApi:getUid().."&type="..rtype
			-- deviceHelper:luaPrint(httpUrl)
			-- deviceHelper:luaPrint(reqStr)
			local retStr=G_sendHttpRequestPost(httpUrl,reqStr)
			-- deviceHelper:luaPrint(retStr)
			if(retStr~="")then
				local retData=G_Json.decode(retStr)
				if (retData["ret"]==0 or retData["ret"]=="0") and retData.data then
					reportCallback(retData)
				end
			end
		end
	end
	if callback then
		callback()
	end 
end

function ltzdzReportVoApi:hasRead(reportVo)
	local data=reportVo.isRead or {}
	local myUid=playerVoApi:getUid()
	for k,v in pairs(data) do
		if tonumber(v)==tonumber(myUid) then
			return true
		end
	end
	return false
end

function ltzdzReportVoApi:getHasUnRead(rtype)
	local unReadNum,readNum=0,0
	local reportList=self:getReportListByType(rtype)
	for k,v in pairs(reportList) do
		local readFlag=self:hasRead(v)
		if readFlag==true then
			readNum=readNum+1
		else
			unReadNum=unReadNum+1
		end
	end
	return unReadNum,readNum
end

function ltzdzReportVoApi:readReport(rid,rtype,callback)
	local function readReportCallBack(sData)
		if sData and sData.data then
			self:addContent(rid,rtype,sData.data.report)
			if callback then
				callback()
			end
	    	eventDispatcher:dispatchEvent("ltzdz.refreshTip",{tipType="report"})
		end
	end
	local httphost=ltzdzVoApi:getHttphostUrl()
	if httphost then
		-- http://192.168.8.213/tank-servertest/public/index.php/api/mapwar/getreport?id=1&uid=3000281
		local httpUrl=httphost.."getreport"
		local roomid=ltzdzVoApi.clancrossinfo.roomid
		local reqStr="id="..rid.."&uid="..playerVoApi:getUid()
		deviceHelper:luaPrint(httpUrl)
		deviceHelper:luaPrint(reqStr)
		local retStr=G_sendHttpRequestPost(httpUrl,reqStr)
		deviceHelper:luaPrint(retStr)
		if(retStr~="")then
			local retData=G_Json.decode(retStr)
			if (retData["ret"]==0 or retData["ret"]=="0") and retData.data then
				readReportCallBack(retData)
			end
		end
	end
end

--读取全部战报
function ltzdzReportVoApi:readAllReport(rtype,callback)
	local myuid=playerVoApi:getUid()
	local function readAllCallBack(sData)
		--更新一下战报已读数据
		local reportList=self:getReportListByType(rtype)
		for k,v in pairs(reportList) do
			local flag=self:hasRead(v)
			if flag==false then
				if v.isRead==nil then
					v.isRead={}
				end
				if v.isRead then
					table.insert(v.isRead,myuid)
				end
			end
		end
		if callback then
			callback()
		end
	end
	local httphost=ltzdzVoApi:getHttphostUrl()
	if httphost then
		local httpUrl=httphost.."readall"
		local roomid=ltzdzVoApi.clancrossinfo.roomid
		local reqStr="uid="..playerVoApi:getUid().."&roomid="..roomid.."&type="..rtype
		-- deviceHelper:luaPrint(httpUrl)
		-- deviceHelper:luaPrint(reqStr)
		local retStr=G_sendHttpRequestPost(httpUrl,reqStr)
		-- deviceHelper:luaPrint(retStr)
		if(retStr~="")then
			local retData=G_Json.decode(retStr)
			if (retData["ret"]==0 or retData["ret"]=="0") and retData.data then
				readAllCallBack(retData)
			end
		end
	end
end

--战报过期时间
function ltzdzReportVoApi:getReportExpireTime(rtype)
	if rtype and self.reportExpireTime and self.reportExpireTime[rtype] then
		return self.reportExpireTime[rtype]
	else
		return 0
	end
end
function ltzdzReportVoApi:setReportExpireTime(rtype,time)
	if rtype and time then
		if self.reportExpireTime==nil then
			self.reportExpireTime={}
		end
		self.reportExpireTime[rtype]=time
	end
end

function ltzdzReportVoApi:showReportDialog(layerNum)
   	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzReportDialog"
	local td=ltzdzReportDialog:new(layerNum)
	local tbArr={getlocal("allianceWar_battleReport"),getlocal("ltzdz_transport_report")}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("allianceWar_battleReport"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

function ltzdzReportVoApi:showReportDetailDialog(reportVo,layerNum)
   	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzReportDetailDialog"
	local td=ltzdzReportDetailDialog:new(reportVo)
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("fight_content_fight_title"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

function ltzdzReportVoApi:isAttacker(report)
	if report~=nil then
		local myUid=playerVoApi:getUid()		
		if tonumber(report.auid)==tonumber(myUid) then
			return true
		end
	end
	return false
end

function ltzdzReportVoApi:isShowAccessory(report)
	if base.ifAccessoryOpen==1 then
		return true
	end
	return false
end

--判断是不是攻击的野城还是npc (1：野城，2：npc)
function ltzdzReportVoApi:isAttackCityOrNpc(reportVo)
	local enemy=reportVo.defender
    if reportVo and (reportVo.defender==nil or SizeOfTable(reportVo.defender)==0) then
    	if reportVo.duid==0 then
    		return 1
    	elseif reportVo.duid<100 then
    		return 2
    	end
    end
    return 0
end

function ltzdzReportVoApi:getBothStrengthReportHeight()
	return 200
end

function ltzdzReportVoApi:addBothStrengthReport(cell,reportVo,isAttacker,cellWidth,cellHeight,layerNum)
	if reportVo==nil then
		do return end
	end
    require "luascript/script/game/gamemodel/ltzdz/ltzdzFightApi"
    require "luascript/script/game/gamemodel/ltzdz/ltzdzCityVoApi"
    local function nilFunc()    
    end
    local itemBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),nilFunc)
    -- itemBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(cellWidth,cellHeight)
    itemBg:setContentSize(rect)
    itemBg:setOpacity(0)
    itemBg:setPosition(cellWidth/2,cellHeight/2)
    cell:addChild(itemBg)

    local myIconSp,enemySp
    local myNameStr,myPower,enemyNameStr,enemyPower
    if isAttacker==true then
        local myPic=reportVo.attacker[1]
        local personPhotoName=playerVoApi:getPersonPhotoName(myPic)
        -- print("personPhotoName----->>>",personPhotoName)
        myIconSp=playerVoApi:GetPlayerBgIcon(personPhotoName,nilFunc,nil,nil,100)
        myNameStr=reportVo.attacker[2]

        local enemy=reportVo.defender
        local flag=self:isAttackCityOrNpc(reportVo)
        if flag==1 then --说明攻打的不是玩家，是野城
            enemy=reportVo.city[2]
            local enemyPic=ltzdzFightApi:getCityPicByCid(enemy[1],enemy[2])
            enemyNameStr=ltzdzCityVoApi:getCityName(enemy[1])
            enemySp=CCSprite:createWithSpriteFrameName(enemyPic)
        elseif flag==2 then
        	local npcUser=ltzdzFightApi:getUserInfo(reportVo.duid)
        	enemyNameStr=npcUser.nickname
            local personPhotoName=playerVoApi:getPersonPhotoName(npcUser.pic)
            enemySp=playerVoApi:GetPlayerBgIcon(personPhotoName,nilFunc,nil,nil,100)
        else
            local enemyPic
            -- print("reportVo.duid------>>>>>",reportVo.duid)
            if tonumber(reportVo.duid)<100 then
            	local npc=ltzdzFightApi:getUserInfo(reportVo.duid)
            	enemyPic,enemyNameStr=(npc.pic or 1),(npc.nickname or "")
            else
            	enemyPic,enemyNameStr=enemy[1],enemy[2]
            end
            local personPhotoName=playerVoApi:getPersonPhotoName(enemyPic)
            -- print("personPhotoName------>>>>>>>>>",personPhotoName)
            enemySp=playerVoApi:GetPlayerBgIcon(personPhotoName,nilFunc,nil,nil,100)
        end
    else
        local my=reportVo.defender
        local enemy=reportVo.attacker
        local myPic=my[1]
        local personPhotoName=playerVoApi:getPersonPhotoName(myPic)
        myIconSp=playerVoApi:GetPlayerBgIcon(personPhotoName,nilFunc,nil,nil,100)
        local enemyPic=enemy[1]
        personPhotoName=playerVoApi:getPersonPhotoName(enemyPic)
        enemySp=playerVoApi:GetPlayerBgIcon(personPhotoName,nilFunc,nil,nil,100)
        myNameStr=my[2]
        enemyNameStr=enemy[2]
    end
    -- print("myIconSp,enemySp----->",myIconSp,enemySp)
    local showTb={{myIconSp,myNameStr,0,cellWidth/2-150},{enemySp,enemyNameStr,0,cellWidth/2+150}}
    for i=1,2 do
        local campStr,campBgPic=getlocal("plat_war_our"),"ltzdzCampBg1.png"
        if i==2 then
            campStr=getlocal("plat_war_enemy")
            campBgPic="ltzdzCampBg2.png"
        end

        local campBg=CCSprite:createWithSpriteFrameName(campBgPic)
        cell:addChild(campBg)

        local campLb=GetTTFLabel(campStr,23)
        if i==1 then
        	campBg:setRotation(180)
    		campBg:setPosition(campBg:getContentSize().width/2+20,cellHeight-campBg:getContentSize().height/2-10)
            campLb:setAnchorPoint(ccp(0,0.5))
            campLb:setPosition(30,campBg:getPositionY())
        else
    		campBg:setPosition(cellWidth-campBg:getContentSize().width/2-20,cellHeight-campBg:getContentSize().height/2-10)
            campLb:setAnchorPoint(ccp(1,0.5))
            campLb:setPosition(cellWidth-30,campBg:getPositionY())
        end
        cell:addChild(campLb)

        local nameStr=showTb[i][2]
        local power=showTb[i][3] --战力
        local posX=showTb[i][4]
        local iconSp=tolua.cast(showTb[i][1],"CCSprite")
        iconSp:setPosition(posX,cellHeight-130)
        cell:addChild(iconSp)

        local nameLb=GetTTFLabelWrap(nameStr,20,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        nameLb:setPosition(iconSp:getPositionX(),cellHeight-75+nameLb:getContentSize().height/2)
        nameLb:setColor(G_ColorYellowPro)
        cell:addChild(nameLb)

        -- local powerLb=GetTTFLabelWrap(getlocal("search_fleet_report_desc_4",{power}),20,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        -- powerLb:setPosition(iconSp:getPositionX(),cellHeight-185-powerLb:getContentSize().height/2)
        -- -- powerLb:setColor(G_ColorYellowPro)
        -- cell:addChild(powerLb)
    end
    local vsSp=CCSprite:createWithSpriteFrameName("VS.png")
    vsSp:setScale(0.8)
	vsSp:setPosition(cellWidth/2,cellHeight/2-20)
    cell:addChild(vsSp)

    local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine3.png",CCRect(2,1,1,1),function () end)
    lineSp:setContentSize(CCSizeMake(cellWidth-60,2))
    lineSp:setPosition(cellWidth/2,6)
    cell:addChild(lineSp)
end

function ltzdzReportVoApi:clear()
	self.reportList={{},{}}
	self.reportExpireTime={0,0}
	self.nr={0,0}
end