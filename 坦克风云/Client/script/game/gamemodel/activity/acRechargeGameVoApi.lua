acRechargeGameVoApi ={}

function acRechargeGameVoApi:getAcVo( )
	return activityVoApi:getActivityVo("rechargeCompetition")
end

function acRechargeGameVoApi:canReward( )
	 --如果acEt包括最后的领奖时间 则需要减去一天
	 return false
end
function acRechargeGameVoApi:getShowMod()
	local vo = self:getAcVo()
	if vo and vo.showMod then
		return vo.showMod
	end
	return 1
end
function acRechargeGameVoApi:getRanklimit( )--拿到排名总数量 给自己使用 %s+
	local vo = self:getAcVo()
	if vo and vo.ranklimit then
		return vo.ranklimit
	end
end
function acRechargeGameVoApi:getRankMixValue( )--拿到排名所需金币下限
	local vo = self:getAcVo()
	if vo and vo.rankMixValue then
		return vo.rankMixValue
	end
end

function acRechargeGameVoApi:setSelfRank( rechargeGold)
	local vo = self:getAcVo()
	if vo and vo.rechargeGold then
		vo.rechargeGold =rechargeGold
	end
end
function acRechargeGameVoApi:getSelfRank( )
	local vo = self:getAcVo()
	-- local uid = playerVoApi:getUid()
	-- local serverUid = base.curZoneID
	local selfRank = {0,"",0}
	selfRank[1]=playerVoApi:getUid()
	selfRank[2]=base.curZoneID
	selfRank[3]=vo.rechargeGold

	return selfRank
end

function acRechargeGameVoApi:isRefRank( isRefRank)
	local vo = self:getAcVo()
	if vo and vo.isRefRank then
		if isRefRank then
			vo.isRefRank =isRefRank
		end
	end
	return vo.isRefRank
end


function acRechargeGameVoApi:setRankList(rankList )--得奖表
	local vo = self:getAcVo()
	local num1 = SizeOfTable(vo.rankList)
	local num2 = 0
	if rankList then
		num2 =SizeOfTable(rankList)
	end
	if vo and vo.rankList then
		if num1 ~= num2 then
			self:isRefRank(true)
		elseif num1 ~=0 and num2 ~=0 then
			for k,v in pairs(vo.rankList) do
				if v[1] ~=rankList[k][1] or (v[1] ==rankList[k][1] and v[3] ~=rankList[k][3]) then
					self:isRefRank(true)
				end
			end
		else
			print("isRefRank(false)---<")
			self:isRefRank(false)
		end
		vo.rankList =rankList
	end
end

function acRechargeGameVoApi:getRankList( )--得奖表
	local vo = self:getAcVo()
	local rankList = {}
	if vo and vo.rankList and SizeOfTable(vo.rankList)>0 then
		rankList = vo.rankList
	end
	return rankList
end

           -- "rankList": [
           --      [ —- key是名次
           --          "101", —- uid
           --          "1",  —- 服id
           --          "80" —- 充值金币数
           --      ], 
           --      [
           --          "102", 
           --          "2", 
           --          "20"
           --      ]
           --  ]




function acRechargeGameVoApi:getRewardTimeStr( )
	local vo = self:getAcVo()
	local rewardTimeStr = activityVoApi:getActivityRewardTimeStr(vo.acEt-86400,60,86400)
	-- local str = getlocal("recRewardTime")..":"..rewardTimeStr
	return rewardTimeStr
end

function acRechargeGameVoApi:getRewardList()
	local vo = self:getAcVo()
	local rewardRankTb = {}
	if vo and vo.rewardTb  then
		return vo.rewardTb--,SizeOfTable(vo.rewardTb)
	end
	print("no tb~~~~~~")
	return {}
end

function acRechargeGameVoApi:getFortmatReward(idx)
	local rewardTb = self:getRewardList()
	local everyRewardTb = self:getRewardEveTb(rewardTb[idx][2],false,true)
	if everyRewardTb and SizeOfTable(everyRewardTb) then
		return everyRewardTb
	end
	return {}
end

function acRechargeGameVoApi:getRewardEveTb(data,includeZore,sortByIndex)
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
    local bgname = ""
    local equipId
	if data then
		for k,v in pairs(data) do
			if v then
				for m,n in pairs(v) do
					if m~=nil and n~=nil then
						local key,type1,num=m,k,n
						local border
						if type(n)=="table" then
							for i,j in pairs(n) do
								if i=="index" then
									index=j
								elseif i=="isBorder"then
									border=j
								else
									key=i
									num=j
								end
							end
						end
						if sortByIndex then
							name,pic,desc,id,noUseIdx,eType,equipId,bgname=getItem(key,type1)
						else
							name,pic,desc,id,index,eType,equipId,bgname=getItem(key,type1)
						end
						if name and name~="" then
							if includeZore==false then
								if num>0 then
									--index=index+1
									table.insert(formatData,{name=name,num=num,pic=pic,desc=desc,id=id,type=k,index=index,key=key,eType=eType,equipId=equipId,bgname=bgname,border=border})
								end
							else
								--index=index+1
								table.insert(formatData,{name=name,num=num,pic=pic,desc=desc,id=id,type=k,index=index,key=key,eType=eType,equipId=equipId,bgname=bgname,border=border})
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