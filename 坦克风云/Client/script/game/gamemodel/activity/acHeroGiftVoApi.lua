acHeroGiftVoApi={}

function acHeroGiftVoApi:getAcVo( )
	return activityVoApi:getActivityVo("twohero")
end

function acHeroGiftVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end
function acHeroGiftVoApi:afterExchange()
    local vo = self:getAcVo()

    CCUserDefault:sharedUserDefault():setIntegerForKey(vo.tipKey,2)-- 2 ： 玩家已领奖 或是非排行榜玩家已开过板子
    CCUserDefault:sharedUserDefault():flush()
    vo.tipKeyInteger = 2

    activityVoApi:updateShowState(vo)
    vo.stateChanged = true -- 强制更新数据
end
function acHeroGiftVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end
function acHeroGiftVoApi:setLastTime( newTime)
	local vo  = self:getAcVo()
	if vo  then
		vo.lastTime =newTime
	end
end
function acHeroGiftVoApi:canReward()
	-- print("~~~~~~~~~~")
	local isCan=false							--是否是第一次免费

	local vo = self:getAcVo()
	if not vo.tipKey then--设置key
		self:setTipKey()
		vo.tipKeyInteger = CCUserDefault:sharedUserDefault():getIntegerForKey(vo.tipKey)
	end

	if self:isToday() == false and self:acIsStop() == false then
		if vo.tipKeyInteger ~= 1 then
			CCUserDefault:sharedUserDefault():setIntegerForKey(vo.tipKey,1)--默认非领奖时间内 设置为 1
		    CCUserDefault:sharedUserDefault():flush()
		end
		isCan = true
	elseif self:acIsStop() and vo.tipKeyInteger < 2 then
	    isCan = true
	end
	return isCan
end

function acHeroGiftVoApi:setTipKey( )
	local vo = self:getAcVo()
	vo.tipKey = playerVoApi:getPlayerName()..playerVoApi:getUid().."twohero"
end
function acHeroGiftVoApi:getTipKey(  )
	local vo = self:getAcVo()
	return vo.tipKey,vo.tipKeyInteger
end



function acHeroGiftVoApi:isFree( )
	local isFree = true
	if self:isToday() == true then
		isFree = false
	end
	return isFree
end
function acHeroGiftVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end
function acHeroGiftVoApi:refreshPlayerList( )
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-300) then
		return false
	end
	return true	
end
function acHeroGiftVoApi:setPlayerList( list )
	local vo = self:getAcVo()
	if vo and vo.playerList then
		vo.playerList =list
	end
end
function acHeroGiftVoApi:getPlayerList( )
	local vo = self:getAcVo()
	if vo and vo.playerList then
		return vo.playerList
	end
	return nil
end
function acHeroGiftVoApi:isReaward( )
	local score = self:getScore()
	local playerList = self:getPlayerList()
	local playeName = playerVoApi:getPlayerName()
	for k,v in pairs(playerList) do
		-- print("v[2].......",v[2],playeName,v[3],score)
		if v[2] ==playeName and tonumber(v[3]) ==score then
			self:setRank(k)
			return true
		end
	end
	return false
end
function acHeroGiftVoApi:setRank(idx)
	local vo = self:getAcVo()
	if vo  then 
		vo.rankPos=tonumber(idx)
	end
end
function acHeroGiftVoApi:getRank()
	local vo  = self:getAcVo()
	if vo and vo.rankPos then
		return vo.rankPos
	end
	return nil
end
function acHeroGiftVoApi:getSingleGoldShow( )
	local vo = self:getAcVo()
	if vo and vo.cost then
		return vo.cost
	end
	return nil
end
function acHeroGiftVoApi:getMulGoldShow( )
	local vo = self:getAcVo()
	if vo and vo.mulCost then
		return vo.mulCost 
	end
	return nil
end

function acHeroGiftVoApi:getScore( )
	local vo = self:getAcVo()
	if vo and vo.score then
		return vo.score
	end
	return 0
end
function acHeroGiftVoApi:getScoreFloor( )
	local vo = self:getAcVo()
	if vo and vo.scoreFloor then
		return vo.scoreFloor
	end
	return nil
end
function acHeroGiftVoApi:getAwardList( )
	local vo = self:getAcVo()
	if vo and vo.awardList then
		return vo.awardList
	end
	return nil
end
function acHeroGiftVoApi:getedBigAward( )
	local vo = self:getAcVo()
	if vo and vo.getedBigAward then
		return vo.getedBigAward
	end
	return nil
end
function acHeroGiftVoApi:setGetedBigAward( )
	local vo  = self:getAcVo()
	if vo and vo.getedBigAward==nil then
		vo.getedBigAward =1
	end
end
function acHeroGiftVoApi:getAwardListNums( )
	local vo = self:getAcVo()
	if vo and vo.awardList then
		return SizeOfTable(vo.awardList)
	end
	return nil
end
function acHeroGiftVoApi:formatAwardList( idx )
	local awardAllList = self:getAwardList()
	local awardList = nil
	local type1 = {}
	if awardAllList then
		for k,v in pairs(awardAllList) do
			if idx >= v[1][1] and idx <=v[1][2] then
				-- print("here????",v[1][1],v[1][2])
				awardList =FormatItem(v[2],false,true)
				for m,n in pairs(v[2]) do
					if m then
						table.insert(type1,m)
					end
				end
			end
		end
	end
	return awardList,type1
end

function acHeroGiftVoApi:setScore( idx,num )
	local vo = self:getAcVo()
	if idx and num ==nil then 
		vo.score =idx 
	end
	if idx and num ==2 then
		vo.score =vo.score+idx
	end
end

function acHeroGiftVoApi:takeHeroOrder( id )
	if id  then
		local heroId = heroCfg.soul2hero[id]
		if heroId then
			local orderId = heroListCfg[heroId]["fusion"]["p"]
			return heroId,orderId
		end
		
	end
	return nil
end

function acHeroGiftVoApi:getShowHero( )
	local vo = self:getAcVo()
	if vo and vo.showList then
		return self:FormatItem(vo.showList,true,true)
	end
	return nil
end
function acHeroGiftVoApi:getFirstIcon( )
	local showList = self:getShowHero()
	if  SizeOfTable(showList) then
		return showList[1].key
	end
	return nil
end

-- function acHeroGiftVoApi:refresh()
-- 	local vo = self:getAcVo()
-- 	if vo then
-- 		vo.refresh = true
-- 	end
-- end

function acHeroGiftVoApi:showHero(reward,oldHeroList,score,isShow,layerNum)
    if reward then
        local rewardTb=FormatItem(reward)
        local award=rewardTb[1]
        if award then
            if award.type=="h" then
                local type,heroIsExist,addNum,newProductOrder=heroVoApi:getNewHeroData(award,oldHeroList)
                if isShow then
                	G_recruitShowHero(type,award,layerNum+1,heroIsExist,addNum,nil,newProductOrder,score)
                end

                if award.eType=="h" and heroIsExist==false then
                    heroVoApi:getNewHeroChat(award.key)
                end

                if heroVoApi:heroHonorIsOpen()==true then
                    local hid
                    if award.eType=="h" then 
                        hid=award.key
                    elseif award.eType=="s" then
                        hid=heroCfg.soul2hero[award.key]
                    end 
                    if hid and heroVoApi:getIsHonored(hid)==true then
                        local pid=heroCfg.getSkillItem
                        local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
                        bagVoApi:addBag(id,addNum)
                    end
                end
            else
                G_addPlayerAward(award.type,award.key,award.id,award.num,false,true)
                if isShow then	
                	G_recruitShowHero(3,award,layerNum+1,nil,nil,nil)
                end
            end
        end
    end
end

function acHeroGiftVoApi:FormatItem(data,includeZore,sortByIndex)
	if includeZore==nil then
		includeZore=true
	end
	local formatData={}	
	local num=0
	local name=""
	local pic=""
	local desc=""
    local id=0
	local index=0
    local eType=""
    local noUseIdx=0 --无用的index 只是占位
    local equipId
	if data then
		for r,t in pairs(data) do		--[{"h":[{"h24":3,"index":1}]},{"h":[{"index":1,"h23":3}]}]
			if t then

				for k,v in pairs(t) do		--{"h":[{"h24":3,"index":1}]},{"h":[{"index":1,"h23":3}]}
					if v then
						for m,n in pairs(v) do
							if m~=nil and n~=nil then
								local key,type1,num=m,k,n
								-- print("key--1111--num",key,num)
								if type(n)=="table" then
									for i,j in pairs(n) do
										if i=="index" then
											index=j
										else
											-- print("key--2222--num",key,num)
											key=i
											num=j
										end
									end
								end
								if sortByIndex then
									name,pic,desc,id,noUseIdx,eType,equipId=getItem(key,type1)
								else
									name,pic,desc,id,index,eType,equipId=getItem(key,type1)
								end
								if name and name~="" then
									if includeZore==false then
										if num>0 then
											--index=index+1
											-- print("key--33333--num",key,num)
											table.insert(formatData,{name=name,num=num,pic=pic,desc=desc,id=id,type=k,index=index,key=key,eType=eType,equipId=equipId})
										end
									else
										--index=index+1
										-- print("key--44444--num",key,num)
										table.insert(formatData,{name=name,num=num,pic=pic,desc=desc,id=id,type=k,index=index,key=key,eType=eType,equipId=equipId})
									end
								end
							end
						end
					end
				end

			end
		end
	end
	if formatData and SizeOfTable(formatData)>0 then
		local function sortAsc(a, b)
			if sortByIndex then
				if a.index and b.index and tonumber(a.index) and tonumber(b.index) then
					return a.index < b.index
				end
			else
				if a.type==b.type then
					if a.index and b.index and tonumber(a.index) and tonumber(b.index) then
						return a.index < b.index
					end
					--else
					--return a.type<b.type
		        end
			end
	    end
		table.sort(formatData,sortAsc)
	end
	return formatData
end