require "luascript/script/game/gamemodel/checkPoint/checkPointVo"

checkPointVoApi={
	refreshFlag=-1,
	unlockCheckPointVo={},
	checkPointNum=0,
	--一个关卡星星数量
	chapterStarNum=3,
    --一个关卡章节的关卡数量
	chapterNum=16,
	unlockChapterNum=1,
	--[[
	--返回数据格式
	data={	-- 关卡
		"maxsid":175,
		"star":[46,48,48,48,48,48,48,45,48,46,45]},
        info={
            s1={	-- 关卡标识
                s=3	-- 过关获得的星星
			},
			s2={s=3},
			...
        }
    }
	]]
	flag=-1,

	techFlag=-1,
	techData={},
	--资源增加百分比，单独拿出来，减少计算
	resAddPercent=0,

	chapterDetail={}, --查看关卡详情数据
	cRewardCfg={},

	buyRaidsData={}, --购买扫荡令数据,{ts=1487692800,p19=1},{购买的凌晨的时间戳,道具的购买次数}
}

function checkPointVoApi:getStarById(id)
    local starNum=0
    local cpvo=self:getCheckPointVoBySid(id)
    if cpvo and cpvo.starNum then
        starNum=cpvo.starNum
    end
    return starNum
end

function checkPointVoApi:setFlag(flag)
	self.flag=flag
end
function checkPointVoApi:getRefreshFlag()
	return self.refreshFlag
end
function checkPointVoApi:setRefreshFlag(flag)
	self.refreshFlag=flag
end

-- 开启的最大关卡(后台传)
function checkPointVoApi:getMaxNum()
	local maxNum=playerVoApi:getMaxLvByKey("unlockCheckpoint")
	print("maxNummaxNummaxNum",maxNum)
	local cfgMaxNum=0
	for k,v in pairs(checkPointCfg) do
		if v and v.sid and tonumber(v.sid) and tonumber(v.sid)>0 and tonumber(v.sid)<10000 then
			cfgMaxNum=cfgMaxNum+1
		end
	end
	if maxNum and tonumber(maxNum) then
		maxNum=tonumber(maxNum)
		if maxNum>cfgMaxNum then
			maxNum=cfgMaxNum
		end
		return maxNum
	end
	return nil
end

function checkPointVoApi:getCheckPointNum()
	if self.checkPointNum==nil or self.checkPointNum==0 then
		for k,v in pairs(checkPointCfg) do
			if v and v.sid and tonumber(v.sid) and tonumber(v.sid)>0 and tonumber(v.sid)<10000 then
				self.checkPointNum=self.checkPointNum+1
			end
		end
    end

    -- 开启的最大关卡
    local maxNum=self:getMaxNum()
    if maxNum then
    	self.checkPointNum=maxNum
    end

	return self.checkPointNum
end
function checkPointVoApi:getChapterNum()
	return self.chapterNum
end
function checkPointVoApi:getChapterStarNum()
	return self.chapterStarNum
end
function checkPointVoApi:getMaxEnergy()
	if base.he==1 then
		return playerCfg.maxEnergy_equip
	end
	return playerCfg.maxEnergy_normal
end
function checkPointVoApi:getCheckPointStarNum()
	local starNum = self:getChapterNum()*self:getChapterStarNum()
	return starNum
end
function checkPointVoApi:getChapterTotalNum()
	local chapterTotalNum = self:getChapterNum()*self:getCheckPointNum()
	return chapterTotalNum
end

function checkPointVoApi:clear()
	self:clearData()
	self:clearChapterDetail()
	self.buyRaidsData={}
end
function checkPointVoApi:clearData()
	if self.unlockCheckPointVo~=nil then
		for k,v in pairs(self.unlockCheckPointVo) do
			v=nil
		end
		self.unlockCheckPointVo=nil
	end
	self.unlockCheckPointVo={}
	self.unlockChapterNum=1
    self.refreshFlag=-1
	self.flag=-1
	self.techFlag=-1
	self.techData={}
	self.resAddPercent=0
	self.cRewardCfg={}
end
function checkPointVoApi:formatStoryData(data)
	if self.flag==-1 then
		--"challenge":{"maxsid":175,"info":{ },"star":[46,48,48,48,48,48,48,45,48,46,45]},	
		checkPointVoApi:clearData()
		local totalNum=self:getChapterTotalNum()
		local chapterNum=self:getChapterNum()
		local starTab=data.star or {}
		local unlockChapter=tonumber(data.maxsid) or 1
		self.unlockChapterNum=unlockChapter+1
		local unlockIndex=math.ceil((unlockChapter+1)/chapterNum)
		if unlockChapter>=totalNum then
			unlockIndex=math.ceil(unlockChapter/chapterNum)
		end

		-- 开启的最大关卡
	    local maxNum=self:getMaxNum()
	    if maxNum then
	    	if unlockIndex>maxNum then
	    		unlockIndex=maxNum
	    	end
	    end

		for k=1,unlockIndex do
		--for k,v in pairs(starTab) do
			local starNum=tonumber(starTab[k]) or 0
	        local vo = checkPointVo:new()
			local chapter={}
			if k==1 then
				for i=1,chapterNum do
					if i==1 then
						table.insert(chapter,i,{index=i,isUnlock=true,starNum=0})
					else
						table.insert(chapter,i,{index=i,isUnlock=false,starNum=0})
					end
				end
			end
	        vo:initWithData(k,starNum,true,chapter)
			self.unlockCheckPointVo[k]=vo
	        --table.insert(self.unlockCheckPointVo,k,vo)
		end
        local function sortSidAsc(a, b)
            return a.sid < b.sid
        end
        table.sort(self.unlockCheckPointVo,sortSidAsc)
		self:setFlag(1)
		
		
	end
end
function checkPointVoApi:formatData(data)
	local totalNum=self:getChapterTotalNum()
	local chapterNum=self:getChapterNum()

	local unlockNum=self:getUnlockNum()
	if unlockNum==nil or unlockNum==0 then
		unlockNum=1
	end
	local checkPointIndex=unlockNum
	local lastIndex=0
	for k,v in pairs(data) do
		local cIndex=tonumber(k) or tonumber(RemoveFirstChar(k))
		local chapterIndex=cIndex%chapterNum
		if chapterIndex==0 then
			chapterIndex=chapterNum
		end
		if lastIndex<chapterIndex then
			lastIndex=chapterIndex
		end
		checkPointIndex=math.ceil(cIndex/chapterNum)
		local isUnlock=true
		local starNum=tonumber(v.s)
		if self.unlockCheckPointVo[checkPointIndex] then
			local chapter={index=chapterIndex,isUnlock=isUnlock,starNum=starNum}
			if self.unlockCheckPointVo[checkPointIndex].chapterTab==nil then
				self.unlockCheckPointVo[checkPointIndex].chapterTab={}
			end
			self.unlockCheckPointVo[checkPointIndex].chapterTab[chapterIndex]=chapter
			--table.insert(self.unlockCheckPointVo[checkPointIndex].chapterTab,chapterIndex,chapter)
		end
	end
	if self.unlockCheckPointVo[checkPointIndex] then
		if self.unlockCheckPointVo[checkPointIndex].chapterTab==nil then
			self.unlockCheckPointVo[checkPointIndex].chapterTab={}
		end
		for i=1,chapterNum do
			if self.unlockCheckPointVo[checkPointIndex].chapterTab[i]==nil then
				local chapter1={index=i,isUnlock=false,starNum=0}
				self.unlockCheckPointVo[checkPointIndex].chapterTab[i]=chapter1
				--table.insert(self.unlockCheckPointVo[checkPointIndex].chapterTab,i,chapter1)
			end
			if (i-1)==lastIndex then
				self.unlockCheckPointVo[checkPointIndex].chapterTab[i].isUnlock=true
			end
		end
		
        local function sortSidAsc(a, b)
            return a.index < b.index
        end
        table.sort(self.unlockCheckPointVo[checkPointIndex].chapterTab,sortSidAsc)
	end
	--[[
	
	local unlockIndex=math.ceil((num+1)/chapterNum)
	if num>=totalNum then
		unlockIndex=math.ceil(num/chapterNum)
	end
	local showNum=unlockIndex*chapterNum
	local chapterTab={}
	local starTab={}
	for k=1,showNum do
    --for k,v in pairs(data) do
		local checkPointIndex=math.ceil(k/chapterNum)
		if chapterTab[checkPointIndex]==nil then
			chapterTab[checkPointIndex]={}
		end
		if starTab[checkPointIndex]==nil then
			starTab[checkPointIndex]=0
		end
		local chapterIndex=k%chapterNum
		if chapterIndex==0 then
			chapterIndex=chapterNum
		end
		local isUnlock=false
		local starNum=0
		local chapterData=data["s"..tostring(k)]
		if chapterData then
			isUnlock=true
			starNum=chapterData.s
			starTab[checkPointIndex]=starTab[checkPointIndex]+chapterData.s
		end
		if k==(num+1) then
			isUnlock=true
			starNum=0
		end
		local chapter={index=chapterIndex,isUnlock=isUnlock,starNum=starNum}
		table.insert(chapterTab[checkPointIndex],chapterIndex,chapter)
    end

	for i=1,unlockIndex do
        local function sortSidAsc(a, b)
            return a.index < b.index
        end
        table.sort(chapterTab[i],sortSidAsc)
        local vo = checkPointVo:new()
        vo:initWithData(i,starTab[i],true,chapterTab[i])
        table.insert(self.unlockCheckPointVo,i,vo)
	end
	if self:getRefreshFlag()==-1 then
		self:setRefreshFlag(1)
	elseif self:getRefreshFlag()==1 then
		self:setRefreshFlag(0)
	end
	]]
end

function checkPointVoApi:getUnlockCheckPointVo()
    return self.unlockCheckPointVo
end


function checkPointVoApi:getCfgBySid(sid)
	for k,v in pairs(checkPointCfg) do
		if tostring(v.sid)==tostring(sid) then
			return v
		end
	end
	return {}
end

function checkPointVoApi:getCheckPointVoBySid(sid)
	local unlockVo=self:getUnlockCheckPointVo()
	for k,v in pairs(unlockVo) do
		if tostring(v.sid)==tostring(sid) then
			return v
		end
	end
	return {}
end

function checkPointVoApi:getUnlockNum()
	local unlockVo=self:getUnlockCheckPointVo()
	return SizeOfTable(unlockVo)
end

function checkPointVoApi:getUnlockChapterNum()
	return self.unlockChapterNum
	--[[
	local num=1
	local unlockVo=self:getUnlockCheckPointVo()
	for k,v in pairs(unlockVo) do

		for m,n in pairs(v.chapterTab) do
			if n.isUnlock==true then
				num=num+1
			end
		end
	end
	return num
	]]
end
function checkPointVoApi:getUnlockChapterSid()
	return 10000+self.unlockChapterNum
end

function checkPointVoApi:getUnlockSid()
	local unlockIndex=1
	local unlockVo=self:getUnlockCheckPointVo()
	for k,v in pairs(unlockVo) do
		if v and v.isUnlock and v.sid and v.sid>unlockIndex then
			unlockIndex=v.sid
		end
	end
	return unlockIndex
end

function checkPointVoApi:getUnlockChapter(sid,index)
	local cpVo = self:getCheckPointVoBySid(sid)
	if cpVo and cpVo.chapterTab then
		for k,v in pairs(cpVo.chapterTab) do
			if tostring(v.index)==tostring(index) then
				return v
			end
		end
	end
	return {}
end

function checkPointVoApi:updateChapter(data)
	if data then
		local index
		for k,v in pairs(data) do
			index=tonumber(RemoveFirstChar(k))
			self:updateOneChapter(index,v.s)
		end
		if self.unlockChapterNum==index then
			self.unlockChapterNum=self.unlockChapterNum+1
			local nextIndex=index+1
			self:updateOneChapter(nextIndex,0)
		end
		self:setRefreshFlag(0)
	end
end

function checkPointVoApi:updateOneChapter(index,star)
	local chapterNum=self:getChapterNum()
	local totalNum=self:getChapterTotalNum()
	local checkPointIndex=math.ceil(index/chapterNum)
	local chapterIndex=index%chapterNum
	if chapterIndex==0 then
		chapterIndex=chapterNum
	end
	if index<=totalNum then
		if self.unlockCheckPointVo[checkPointIndex]==nil then
			local chapterTab={}
			for i=1,chapterNum do
				local isUnlock=false
				local starNum=0
				--if i==chapterIndex then
				if i==1 then
					isUnlock=true
					--starNum=star
				end
				local chapter={index=i,isUnlock=isUnlock,starNum=starNum}
				table.insert(chapterTab,i,chapter)
			end
	        local function sortSidAsc(a, b)
	            return a.index < b.index
	        end
	        table.sort(chapterTab,sortSidAsc)
	        local vo = checkPointVo:new()
	        vo:initWithData(checkPointIndex,0,true,chapterTab)
			self.unlockCheckPointVo[checkPointIndex]=vo
			
			if checkPointIndex>=6 then
				-- chatVoApi:sendSystemMessage(getlocal("chatSystemMessage2",{playerVoApi:getPlayerName(),checkPointIndex}))
				-- local paramTab={}
				-- paramTab.functionStr="guanqia"
				-- paramTab.addStr="go_attack"
				-- local message={key="chatSystemMessage2",param={playerVoApi:getPlayerName(),checkPointIndex}}
    --             chatVoApi:sendSystemMessage(message,paramTab)

				-- local params = {key="chatSystemMessage2",param={{playerVoApi:getPlayerName(),1},{checkPointIndex,3}}}
				-- chatVoApi:sendUpdateMessage(41,params)
			end
		else
			local cTab=self.unlockCheckPointVo[checkPointIndex].chapterTab
			if cTab and cTab[chapterIndex] and SizeOfTable(cTab[chapterIndex])>0 then
				local oldStar=cTab[chapterIndex].starNum
				local newStar=star
				self.unlockCheckPointVo[checkPointIndex].chapterTab[chapterIndex].isUnlock=true
				if newStar>oldStar then
					local diffStar=newStar-oldStar
					self.unlockCheckPointVo[checkPointIndex].chapterTab[chapterIndex].starNum=newStar
					self.unlockCheckPointVo[checkPointIndex].starNum=self.unlockCheckPointVo[checkPointIndex].starNum+diffStar
				end
			else
				if cTab==nil then
					self.unlockCheckPointVo[checkPointIndex].chapterTab={}
				end
				local chapter={index=chapterIndex,isUnlock=true,starNum=0}
				self.unlockCheckPointVo[checkPointIndex].chapterTab[chapterIndex]=chapter
				--table.insert(self.unlockCheckPointVo[nextCheckPointIndex].chapterTab,nextChapterIndex,chapter)
			end
		end
	end
end

function checkPointVoApi:getStarNum()
	local starNum=0
	local unlockVo=self:getUnlockCheckPointVo()
	if unlockVo and SizeOfTable(unlockVo)>0 then
		for k,v in pairs(unlockVo) do
			if v and tonumber(v.starNum) then
				starNum=starNum+tonumber(v.starNum)
			end
		end
	end
	return starNum
end


-----关卡科技,奖励
function checkPointVoApi:initTechData()
	self.techData={}
	local rewardCfg=self:getChallengeRewardCfg()
	local techCfg=self:getChallengeTechCfg()
	if rewardCfg then
		for k,v in pairs(rewardCfg) do
			local sid="s"..v.sid
			self.techData[sid]={}
			if v and v.content and v.content[3] and v.content[3].reward then
				local rCfg=v.content[3].reward
				local award=FormatItem(rCfg)
				if award and award[1] and award[1].key then
					local cid=award[1].key
					if cid and techCfg[cid] and techCfg[cid].value then
						local valueTb=techCfg[cid].value
						for m,n in pairs(valueTb) do
							table.insert(self.techData[sid],0)
						end
					end
				end
			end
		end
	end
end

function checkPointVoApi:formatTechData(data)
	local techFlag=self:getTechFlag()
	if techFlag==-1 then
		if data then
			self:initTechData()
			for k,v in pairs(data) do
				if self.techData[k]==nil then
					self.techData[k]={}
				end
				if v and SizeOfTable(v)>0 then
					for m,n in pairs(v) do
						self.techData[k][m]=n
					end
				end
			end
			self:updateResAddPercent()
			self:setTechFlag(1)
		end
	end
end

function checkPointVoApi:getTechData()
	return self.techData
end

function checkPointVoApi:getTechFlag()
	return self.techFlag
end
function checkPointVoApi:setTechFlag(techFlag)
	self.techFlag=techFlag
end

function checkPointVoApi:getChallengeRewardCfg()
	-- local cRewardCfg={}
	if self.cRewardCfg and SizeOfTable(self.cRewardCfg)==0 then
		local maxNum=playerVoApi:getMaxLvByKey("unlockCheckpoint")
		if maxNum and tonumber(maxNum) then
			self.cRewardCfg={}
			for k,v in pairs(challengeRewardCfg) do
				if tonumber(v.sid)<=tonumber(maxNum) then
					table.insert(self.cRewardCfg,v)
				end
			end
			-- local function sortAsc(a, b)
			-- 	return tonumber(a.sid) < tonumber(b.sid)
			-- end
			-- table.sort(cRewardCfg,sortAsc)
		else
			self.cRewardCfg=challengeRewardCfg
		end
	end
	return self.cRewardCfg
end
function checkPointVoApi:getCRewardCfgBySid(sid)
	local cRewardCfg={}
	if sid then
		local crCfg=self:getChallengeRewardCfg()
		for k,v in pairs(crCfg) do
			if tostring(v.sid)==tostring(sid) then
				cRewardCfg=v
			end
		end
	end
	return cRewardCfg
end
function checkPointVoApi:getChallengeTechCfg()
	-- local function sortAsc(a, b)
	-- 	return tonumber(a.cid) < tonumber(b.cid)
	-- end
	-- table.sort(challengeTechCfg,sortAsc)
	return challengeTechCfg
end
function checkPointVoApi:getCRewardCfgByTech(cid,level)
	local rewardCfg=self:getChallengeRewardCfg()
	if rewardCfg then
		for k,v in pairs(rewardCfg) do
			if v and v.content and v.content[3] and v.content[3].reward and v.content[3].star then
				local star=v.content[3].star
				-- local aa = G_getCurDeviceMillTime()

				-- local award=FormatItem(v.content[3].reward,true)
				-- local bb = G_getCurDeviceMillTime()
				-- print("FormatItem(v.content[3].reward,true)========",bb-aa)
				-- local item=award[1]
				-- if item and item.key and item.num then
				-- 	if item.key=="c"..cid and item.num==level then
				-- 		return v,star
				-- 	end
				-- end


				if v.content[3].reward.c and cid and level and v.content[3].reward.c["c"..cid] and v.content[3].reward.c["c"..cid]==level then
					return v,star
				end

			end
			
		end
	end
	return nil
end

function checkPointVoApi:isShowTech(sid)
	local isShow=false
	local techData=self:getTechData()
	local ssid="s"..sid
	if sid and techData and techData[ssid] then
		for k,v in pairs(techData[ssid]) do
			if tonumber(v)==0 then
				isShow=true
			end
		end
	end
	return isShow
end

function checkPointVoApi:getTechEffectTab(cid)
	local tmpTab={}
	if cid then
		local techCfg=self:getChallengeTechCfg()
		local valueTb=techCfg["c"..cid].value
		local techData=self:getTechData()
		for k,v in pairs(valueTb) do
			-- local bb = G_getCurDeviceMillTime()
			local rewardCfg=self:getCRewardCfgByTech(cid,k)
			-- local cc = G_getCurDeviceMillTime()
			-- print("self:getCRewardCfgByTech=========",cc-bb)
			if rewardCfg then
				local ssid="s"..rewardCfg.sid
				if techData and techData[ssid] and techData[ssid][3] then
					local isReward=techData[ssid][3]
					table.insert(tmpTab,isReward)
				end
			end
		end


	end
	return tmpTab
end

function checkPointVoApi:getTechIsEffect(cid)
	local isEffect=false
	local level=0
	-- local aa = G_getCurDeviceMillTime()
	local tmpTab=self:getTechEffectTab(cid)
	-- local bb = G_getCurDeviceMillTime()

	-- print("getTechEffectTab ========== ",bb-aa)

	if tmpTab and SizeOfTable(tmpTab)>0 then
		for k,v in pairs(tmpTab) do
			if tonumber(v)==1 then
				local isShow=true
				for i=1,k do
					if tmpTab[i]==0 then
						isShow=false
					end
				end
				if isShow==true then
					isEffect=true
					if level<k then
						level=k
					end
				end
			end
		end
	end
	-- local cc = G_getCurDeviceMillTime()
	-- print("getTechEffectTab total ========== ",cc-bb)

	return isEffect,level
end

function checkPointVoApi:setReward(sid,idx)
	local techData=self:getTechData()
	local ssid="s"..sid
	if sid and idx and techData and techData[ssid] then
		self.techData[ssid][idx]=1
		self:updateResAddPercent()
	end
end

--关卡科技加成{资源，攻击，血量，精准，闪避，暴击，装甲}
function checkPointVoApi:getTechAddNum()
	local techAddTab={}
	-- local aa = G_getCurDeviceMillTime()
	local techCfg=self:getChallengeTechCfg()
	-- local bb = G_getCurDeviceMillTime()
	-- print("获取关卡科技配置耗时==========",bb-aa)
	for k,v in pairs(techCfg) do
		local cc = G_getCurDeviceMillTime()
		local isEffect,level=self:getTechIsEffect(tonumber(v.cid))
		local dd = G_getCurDeviceMillTime()
		-- print("获取科技效果耗时============",dd-cc)

		if isEffect==true and v.value and v.value[level] then
			techAddTab[tonumber(v.cid)]=tonumber(v.value[level])
		else
			techAddTab[tonumber(v.cid)]=0
		end
	end
	-- local ee = G_getCurDeviceMillTime()
	-- print("遍历耗时===========================",ee-bb)
	return techAddTab
end

function checkPointVoApi:getResAddPercent()
	return self.resAddPercent
end
function checkPointVoApi:updateResAddPercent()
	local techAddTab=self:getTechAddNum()
    if techAddTab and techAddTab[1] then
        local addPercent=techAddTab[1] or 0
        self.resAddPercent=addPercent
    end
end




function checkPointVoApi:formatChapterDetail(sid,data)
	if data and SizeOfTable(data)>0 then
		local detailData={}
		if data.reward then
			detailData.reward=FormatItem(data.reward,false,true)
		end
		if data.pool then
			detailData.pool=FormatItem(data.pool,false,true)
			for k,v in pairs(detailData.pool) do
				if v and v.key and propCfg[v.key] and propCfg[v.key].sortId then
					detailData.pool[k].sortId=tonumber(propCfg[v.key].sortId)
				end
			end
			local function sortAsc(a, b)
				if a and b and a.sortId and b.sortId then
					return a.sortId < b.sortId
				end
	        end
	        table.sort(detailData.pool,sortAsc)
		end
		detailData.tank={{},{},{},{},{},{}}
		if data.tank then
			for k,v in pairs(data.tank) do
				if v and SizeOfTable(v)>0 then
					local type="o"
					local name,pic,desc,id,noUseIdx,eType,equipId=getItem(v[1],type)
					local num=tonumber(v[2])
					detailData.tank[k]={name=name,num=num,pic=pic,desc=desc,id=id,type=type,key=v[1],eType=eType,equipId=equipId}
				end
			end
		end
		if self.chapterDetail==nil then
			self.chapterDetail={}
		end
		self.chapterDetail[sid]=detailData
	end
end
function checkPointVoApi:getChapterDetail(sid)
	if sid and self.chapterDetail and self.chapterDetail[sid] then
		return self.chapterDetail[sid]
	end
	return nil
end

function checkPointVoApi:clearChapterDetail()
	self.chapterDetail={}
end


---------关卡扫荡-----------
function checkPointVoApi:showTankStoryDialog(storyId)
    require "luascript/script/game/scene/gamedialog/warDialog/tankStoryDialog"
    local td=tankStoryDialog:new(storyId)
    local tbArr={getlocal("fleetCard"),getlocal("dispatchCard"),getlocal("repair")}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("goFighting"),true,7)
    sceneGame:addChild(dialog,7)
end
function checkPointVoApi:showRaidsSmallDialog(layerNum,sid,index)
    require "luascript/script/game/scene/gamedialog/warDialog/raidsStorySmallDialog"
    local dialog=raidsStorySmallDialog:new()
    dialog:init(layerNum,sid,index)
    return dialog
end
function checkPointVoApi:showRewardSmallDialog(bgSrc,size,fullRect,inRect,title,content,istouch,isuseami,layerNum,callBackHandler,isOneByOne,upgradeTanks)
    require "luascript/script/game/scene/gamedialog/warDialog/raidsRewardSmallDialog"
    local dialog=raidsRewardSmallDialog:new()
    dialog:init(bgSrc,size,fullRect,inRect,title,content,istouch,isuseami,layerNum,callBackHandler,isOneByOne,upgradeTanks)
    return dialog
end

function checkPointVoApi:getBuyRaidsData()
	return self.buyRaidsData
end
function checkPointVoApi:setBuyRaidsData(buyData)
	self.buyRaidsData=G_clone(buyData)
end

function checkPointVoApi:getBuyRaidsPropNum(pid)
	local buyData=self:getBuyRaidsData()
	if buyData and buyData.ts and G_isToday(buyData.ts)==true and buyData[pid] then
		return buyData[pid]
	end
	return 0
end
function checkPointVoApi:buyCost(pid)
	local num=self:getBuyRaidsPropNum(pid)
	if num and challengeRaidCfg and challengeRaidCfg.buyMoney and challengeRaidCfg.buyMoney[num+1] then
		local buyNum=challengeRaidCfg.buyMoney[num+1]
		return buyNum
	end
	return -1
end

-- 新的关卡科技获得展示板
function checkPointVoApi:showStroyTechInfo(layerNum,istouch,isuseami,titleStr,cid)
	require "luascript/script/game/scene/gamedialog/storyTechInfoSmallDialog"
	storyTechInfoSmallDialog:showStoryTechInfo(layerNum,istouch,isuseami,titleStr,cid)
end

function checkPointVoApi:getTechMaxLv(valueTab,cid)
	-- cid,level
	local maxTechLv=0
	local rewardCfg=self:getChallengeRewardCfg()
	for level,value in pairs(valueTab) do
		if rewardCfg then
			for k,v in pairs(rewardCfg) do
				if v and v.content and v.content[3] and v.content[3].reward then
					if v.content[3].reward.c and cid and level and v.content[3].reward.c["c"..cid] and v.content[3].reward.c["c"..cid]==level then
						if level>maxTechLv then
							maxTechLv=level
						end

					end

				end
				
			end
		end
	end
	return maxTechLv
end
