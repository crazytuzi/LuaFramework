localWarVoApi=
{
	initFlag=nil,				--是否初始化数据
	initBuildingFlag=false,		--建筑头顶是否已经显示了图标
	localWarId=nil,				--比赛id
	startTime=nil,				--开始时间
	endTime=nil,				--结束时间
	lastSetFleetTime=0,			--上一次设置部队时间
	tankInfoFlag=-1, 			--是否获取部队信息

	--占领王城信息 {own_at=0,aid=1,name="",kingname=""},buff截止时间(下一场开战时间)，军团id，军团名称，团长名字
	ownCityInfo={},
	isOwnCity=false,			--当前是否有军团占领王城
	applyRank={}, 				--投拍排行榜
	applyAllianceNum=0, 		--报名军团数
	selfApplyData={}, 			--本军团报名信息 {apply_at=1442779813,point=2000}
	isCanBattle=nil, 			--本军团报名结束后能否参赛

	officeTab={},				--官职数据，{j1=国王，j2=外交官，...，{奴隶1，奴隶2，...}}
	officeFlag=-1, 				--官职是否有变化标示
	officeLastStatus=-1,			--官职数据上次请求所在的阶段
	slaveList={
		-- {uid=1000308,name="ddd",level=71,fight=1000,role=1,feat=100},
	}, 				--可以设置成奴隶的列表
	jobs={}, 					--自己的职位提供的buff类型列表
	cityLogList={}, 			--王城记录信息 {"commander":"Dssdf","date":"1443974400","aname":"Dddas","pic":1},{军团长,时间,时间军团名字,头像}
	reportList={},				--军团战报
	myReportList={},			--自己战报
	isNewReport={-1,-1}, 		--是否有新战报
	allFeatRank={}, 			--所有人功绩排行榜
	featRank={}, 				--功绩排行榜
	maxRankNum={0,0},			--排行榜总人数
	initFeatRank={-1,-1},		--战斗结束后是否初始化过功绩排行榜
	featRankPageNum=20,			--功绩排行榜一页的数量
	myFeatRankData={}, 			--我自己的功绩排行榜数据
	allianceMemFeatList={},		--自己军团成员的功绩数据,{{memId,featNum},{军团成员id，功绩数值}}
	task={},					--活跃任务
}

--是否初始化区域战数据
function localWarVoApi:getInitFlag()
	return self.initFlag
end
function localWarVoApi:setInitFlag(initFlag)
	self.initFlag=initFlag
end

--世界争霸id
function localWarVoApi:getlocalWarId()
	return self.localWarId
end
function localWarVoApi:setlocalWarId(localWarId)
	self.localWarId=localWarId
end

--活跃任务
function localWarVoApi:getTask()
	return self.task
end
function localWarVoApi:setTask(task)
	self.task=task
end

-------------以下面板---------------
--弹出主面板
function localWarVoApi:showMainDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/localWar/localWarDialog"
	local td=localWarDialog:new()
	-- local tbArr={getlocal("local_war_sub_title_1"),getlocal("local_war_sub_title_2")}
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("local_war_title"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end
--弹出历届冠军面板
function localWarVoApi:showHistoryDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/localWar/localWarHistoryDialog"
	local td=localWarHistoryDialog:new()
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("local_war_history_title"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end
--弹出报名面板
function localWarVoApi:showBidDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/localWar/localWarBidSmallDialog"
	local signupDialog=localWarBidSmallDialog:new()
	signupDialog:init(layerNum)
end
--弹出详情和奖励面板
function localWarVoApi:showDetailDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/localWar/localWarDetailDialog"
	local td=localWarDetailDialog:new()
	local tbArr={getlocal("local_war_alliance_feat"),getlocal("award"),getlocal("help")}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("playerInfo"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end
--弹出我的部队面板
function localWarVoApi:showTroopsDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/localWar/localWarTroopsDialog"
	local td=localWarTroopsDialog:new()
	local tbArr={getlocal("local_war_troops_status"),getlocal("local_war_troops_preset"),getlocal("gainInformation")}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("local_war_my_troops"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end
--弹出军团面板
function localWarVoApi:showAllianceDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/localWar/localWarAllianceDialog"
	local td=localWarAllianceDialog:new()
	local tbArr={getlocal("local_war_battleStatus"),getlocal("local_war_alliance_feat")}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_list_scene_name"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end
--弹出战报面板
function localWarVoApi:showReportDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/localWar/localWarReportDialog"
	local td=localWarReportDialog:new()
	local tbArr={getlocal("local_war_report_alliance"),getlocal("local_war_report_person")}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("allianceWar_battleReport"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end
--弹出报名排行面板
function localWarVoApi:showApplyRankDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/localWar/localWarApplyRankSmallDialog"
	local applyRankDialog=localWarApplyRankSmallDialog:new()
	applyRankDialog:init(layerNum)
end
--弹出设置官职面板
function localWarVoApi:showSetOfficeDialog(layerNum,officeId,index)
	require "luascript/script/game/scene/gamedialog/localWar/localWarSetOfficeSmallDialog"
	local setOfficeDialog=localWarSetOfficeSmallDialog:new()
	setOfficeDialog:init(layerNum,officeId,index)
end
--弹出官职信息面板
function localWarVoApi:showOfficeInfoDialog(layerNum,officeId,index)
	require "luascript/script/game/scene/gamedialog/localWar/localWarOfficeInfoSmallDialog"
	local officeInfoDialog=localWarOfficeInfoSmallDialog:new()
	officeInfoDialog:init(layerNum,officeId,index)
end
--弹出加速整修面板
function localWarVoApi:showRepairDialog(time,layerNum,callback)
	require "luascript/script/game/gamemodel/localWar/localWarFightVoApi"
	require "luascript/script/game/scene/gamedialog/localWar/localWarRepairSmallDialog"
	local repairDialog=localWarRepairSmallDialog:new()
	repairDialog:init(time,layerNum,callback)
end
--弹出帮助面板
function localWarVoApi:showHelpDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/localWar/localWarHelpDialog"
	local td=localWarHelpDialog:new()
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("help"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end
--弹出官职面板
function localWarVoApi:showOfficeDialog(layerNum)
	local function callback( ... )
		require "luascript/script/game/scene/gamedialog/localWar/localWarOfficeDialog"
	local td=localWarOfficeDialog:new()
		local tbArr={}
		local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("local_war_sub_title_2"),true,layerNum)
		sceneGame:addChild(dialog,layerNum)
	end
	self:getOffice(callback)
end
--弹出奖励面板
function localWarVoApi:showRewardDialog(layerNum)
	local function callback( ... )
		require "luascript/script/game/scene/gamedialog/localWar/localWarRewardDialog"
		local td=localWarRewardDialog:new()
		local tbArr={}
		local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("award"),true,layerNum)
		sceneGame:addChild(dialog,layerNum)
	end
	self:getTankInfo(callback,true)
end
-------------以上面板---------------

-------------以下接口---------------
--初始化，获取报名信息
function localWarVoApi:getApplyData(callback,isShowTip)
	local function getApplyCallback(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data then
				if sData.data.city then
					self:setOwnCityInfo(sData.data.city)
					self:setIsOwnCity(true)
				end
				if sData.data.info then
					self:setSelfApplyData(sData.data.info)
				end
				if sData.data.applycount then
					self:setApplyAllianceNum(tonumber(sData.data.applycount))
				end
				if sData.data.targetState and sData.data.targetState>0 then
					self:setIsCanBattle(true)
				else
					local selfAlliance=allianceVoApi:getSelfAlliance()
					local ownCityInfo=self:getOwnCityInfo()
					if ownCityInfo and ownCityInfo.aid and selfAlliance and tonumber(selfAlliance.aid)==tonumber(ownCityInfo.aid) then
						self:setIsCanBattle(true)
					end
				end
			end

			local status=self:checkStatus()
	        if(status>0 and status<30)then
	            if(buildings.allBuildings)then
	                for k,v in pairs(buildings.allBuildings) do
	                    if(v:getType()==16)then
	                        v:setSpecialIconVisible(4,true)
	                        break
	                    end
	                end
	            end
	        end

			if callback then
				callback()
			end
		end
	end
	local aid
	local selfAlliance=allianceVoApi:getSelfAlliance()
	if(selfAlliance~=nil)then
		aid=selfAlliance.aid
		socketHelper:areawarGetapply(aid,getApplyCallback)
	elseif isShowTip==nil or isShowTip==true then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("local_war_no_alliance_tip"),30)
	end
end
--报名，投拍
function localWarVoApi:bid(point,callback)
	if point then
		local function applyCallback(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				if sData.data and sData.data.point then
					local selfAlliance=allianceVoApi:getSelfAlliance()
			        if selfAlliance then
			            selfAlliance.point=tonumber(sData.data.point)
            		end
            		local selfApplyData={apply_at=sData.ts,point=tonumber(sData.data.point)}
            		self:setSelfApplyData(selfApplyData)
				end
				self:setApplyAllianceNum(self:getApplyAllianceNum()+1)
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("local_war_bid_success"),30)
				if callback then
					callback()
				end
			end
		end
		local aid
		local selfAlliance=allianceVoApi:getSelfAlliance()
		if(selfAlliance~=nil)then
			aid=selfAlliance.aid
			socketHelper:areawarApply(aid,point,applyCallback)
		else
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("local_war_no_alliance_tip"),30)
		end
	end
end
--报名，投拍排行榜
function localWarVoApi:applyrank(callback)
	require "luascript/script/game/gamemodel/localWar/localWarRankVo"
	local applyRank=self:getApplyRank()
	if applyRank and SizeOfTable(applyRank)>0 then
		if callback then
			callback()
		end
	else
		local function applyrankCallback(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				if sData.data and sData.data.rank then
					local rankList=sData.data.rank
					for k,v in pairs(rankList) do
						if v then
							local rankVo=localWarRankVo:new()
							rankVo:initWithData(v)
							table.insert(self.applyRank,rankVo)
						end
					end
					local function sortFunc(a,b)
						return a.rank<b.rank
					end
					table.sort(self.applyRank,sortFunc)
				end
				if callback then
					callback()
				end
			end
		end
		socketHelper:areawarApplyrank(applyrankCallback)
	end
end
--设置职位
function localWarVoApi:setOffice(jobid,memuid,callback)
	local function setjobCallback(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data and sData.data.info then
				self:setOfficeByType(jobid,sData.data.info)

				-- local selfAlliance=allianceVoApi:getSelfAlliance()
	   --          if selfAlliance then
	   --              local aid=selfAlliance.aid
	                local params={jobid,sData.data.info,playerVoApi:getUid()}
	                chatVoApi:sendUpdateMessage(22,params,1)
	            -- end
			end
			self:setOfficeFlag(0)
			if callback then
				callback()
			end
		end
	end
	local aid
	local selfAlliance=allianceVoApi:getSelfAlliance()
	if(selfAlliance~=nil)then
		aid=selfAlliance.aid
		if jobid and memuid then
			socketHelper:areawarSetjob(aid,jobid,memuid,setjobCallback)
		end
	end
end

--获取职位
function localWarVoApi:getOffice(callback)
	local ownCityInfo=self:getOwnCityInfo()
	local status=self:checkStatus()
	if ownCityInfo and ownCityInfo.aid and (self.officeLastStatus==-1 or self.officeLastStatus~=status) then
		local function getjobsCallback(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				if sData.data and sData.data.jobs then
					self:setOfficeTab(sData.data.jobs)
				end
				if sData.data and sData.data.membersslave then
					self:setSlaveList({})
					local membersslave=sData.data.membersslave
					for k,v in pairs(membersslave) do
						if v and SizeOfTable(v)>0 then
							local uid=v[1]
							local name=v[2]
							local level=tonumber(v[3]) or 0
							local fight=tonumber(v[4]) or 0
							local role=tonumber(v[5]) or 0
							local feat=tonumber(v[6]) or 0
							local aName=v[7]
							local slave={uid=uid,name=name,level=level,fight=fight,role=role,feat=feat,aName=aName}
							table.insert(self.slaveList,slave)
						end
					end
				end
				if sData.data and sData.data.membersfeat then
					self:setAllianceMemFeatList(sData.data.membersfeat)
				end
				-- local startTime=self:getStartTime()
				-- local battleStartTime=startTime+86400+localWarCfg.startWarTime[1]*3600+localWarCfg.startWarTime[2]*60
				-- local battleEndTime=startTime+86400+localWarCfg.startWarTime[1]*3600+localWarCfg.startWarTime[2]*60+localWarCfg.maxBattleTime
				-- local status=self:checkStatus()
				-- if status<battleStartTime then
				-- 	self.officeExpiredTime=battleStartTime
				-- elseif status<30 then
				-- 	self.officeExpiredTime=battleEndTime
				-- else
				-- 	self.officeExpiredTime=battleStartTime+(1+localWarCfg.battleTime+localWarCfg.buffTime)*86400
				-- end
				self.officeLastStatus=status
				if callback then
					callback()
				end
			end
		end
		socketHelper:areawarGetjobs(tonumber(ownCityInfo.aid),getjobsCallback)
	else
		if callback then
			callback()
		end 
	end
end

--获取王城记录信息
function localWarVoApi:getKingCitylog(callback)
	local list=self:getCityLogList()
	if list and SizeOfTable(list)>0 then
		if callback then
			callback()
		end
	else
		local function getcitylogCallback(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				if sData.data and sData.data.list then
					self:setCityLogList(sData.data.list)
				end
				if callback then
					callback()
				end
			end
		end
		socketHelper:areawarGetcitylog(getcitylogCallback)
	end
end

--获取部队信息
function localWarVoApi:getTankInfo(callback,isCallback)
	if self:getTankInfoFlag()==-1 or isCallback==true then
		local function getinfoCallback(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				if sData.data and sData.data.troops then
					for k,v in pairs(sData.data.troops) do
						if v and v[1] and v[2] then
							local tid=(tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
							local num=tonumber(v[2])
							tankVoApi:setTanksByType(17,k,tid,num)
						else
							tankVoApi:deleteTanksTbByType(17,k)
						end
					end
					self:setTankInfoFlag(1)
				end
				if sData.data and sData.data.hero then
					heroVoApi:setLocalWarHeroList(sData.data.hero)
				end
				if sData.data and sData.data.aitroops then
					AITroopsFleetVoApi:setLocalWarAITroopsList(sData.data.aitroops)
				end
				if sData.data and sData.data.swtask then
					self:setTask(sData.data.swtask)
				end
				if sData.data and sData.data.equip then
					emblemVoApi:setBattleEquip(17,sData.data.equip)
					--print("local war equip",emblemVoApi:getBattleEquip(17))
				end
				if sData.data and sData.data.plane then
					planeVoApi:setBattleEquip(17,sData.data.plane)
				end
				if sData.data and sData.data.skin then --坦克皮肤
					tankSkinVoApi:setTankSkinListByBattleType(17,sData.data.skin)
				end
				if sData.data and sData.data.ap then --飞艇
					airShipVoApi:setBattleEquip(17,sData.data.ap)
				end
				if callback then
					callback()
				end
			end
		end
		socketHelper:areawarGetinfo(getinfoCallback)
	else
		if callback then
			callback()
		end
	end
end

--获取当前部队信息
function localWarVoApi:getCurTroopsInfo(callback)
	local function gettroopsCallback(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data and sData.data.areaWarserver then
				if sData.data.areaWarserver.troops then
					for k,v in pairs(sData.data.areaWarserver.troops) do
						if v and v[1] and v[2] then
							local tid=(tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
							local num=tonumber(v[2])
							tankVoApi:setTanksByType(18,k,tid,num)
						else
							tankVoApi:deleteTanksTbByType(18,k)
						end
					end
				end
				if sData.data.areaWarserver.heros then
					if SizeOfTable(sData.data.areaWarserver.heros)>=6 then
						heroVoApi:setLocalWarCurHeroList(sData.data.areaWarserver.heros)
					elseif sData.data.areaWarserver.heros[1] then
						heroVoApi:setLocalWarCurHeroList(sData.data.areaWarserver.heros[1])
					end
				end
				if sData.data.areaWarserver.aitroops then
					AITroopsFleetVoApi:setLocalWarCurAITroopsList(sData.data.areaWarserver.aitroops)
				end
				emblemVoApi:setBattleEquip(18,sData.data.areaWarserver.equip)
				planeVoApi:setBattleEquip(18,sData.data.areaWarserver.plane)
				airShipVoApi:setBattleEquip(18,sData.data.areaWarserver.ap)
				if sData.data.areaWarserver.skin then
					tankSkinVoApi:setTankSkinListByBattleType(18, sData.data.areaWarserver.skin)
				end
			end
			if callback then
				callback()
			end
		end
	end
	local checkStatus=self:checkStatus()
	local selfAlliance=allianceVoApi:getSelfAlliance()
	if checkStatus==21 and selfAlliance then
		socketHelper:areawarGettroops(selfAlliance.aid,playerVoApi:getUid(),gettroopsCallback)
	else
		if callback then
			callback()
		end
	end
end

--获取战报信息 type:1军团，2个人
function localWarVoApi:updateReportList(type,callback)
	require "luascript/script/game/gamemodel/localWar/localWarReportVo"
	if self:getIsNewReport(type)==-1 or self:getIsNewReport(type)==0 then
		local aid
		local id
		if type==1 then
			local selfAlliance=allianceVoApi:getSelfAlliance()
			if selfAlliance and selfAlliance.aid then
				aid=selfAlliance.aid
			end
			if self.reportList and SizeOfTable(self.reportList)>0 then
				local function sortFunc(a,b)
					return a.id>b.id
				end
				table.sort(self.reportList,sortFunc)
				local report=self.reportList[1]
				id=report.id
			end
		elseif type==2 then
			if self.myReportList and SizeOfTable(self.myReportList)>0 then
				local function sortFunc(a,b)
					return a.id>b.id
				end
				table.sort(self.myReportList,sortFunc)
				local report=self.myReportList[1]
				id=report.id
			end
		end

		local function areawarListCallback(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				if sData.data and sData.data.areawarlog then
					local areawarlog=sData.data.areawarlog
					if type==1 and aid then
						for k,v in pairs(areawarlog) do
							if v and v[1] then
								local isHas=false
								local id=tonumber(v[1])
								for m,n in pairs(self.reportList) do
									if tonumber(n.id)==tonumber(id) then
										isHas=true
									end
								end
								if isHas==false then
									local reportVo=localWarReportVo:new()
									reportVo:initWithData(v)
									local diffTime=base.serverTime-(reportVo.time or 0)
									if (diffTime/86400)>=(localWarCfg.battleTime+localWarCfg.buffTime) then
									else
										table.insert(self.reportList,reportVo)
									end
								end
							end
						end
						local function sortFunc(a,b)
							if a and b and a.id and b.id then
								return a.id>b.id
							end
						end
						table.sort(self.reportList,sortFunc)
						while SizeOfTable(self.reportList)>localWarCfg.reportMaxNum do
							table.remove(self.reportList,localWarCfg.reportMaxNum+1)
						end
					else
						for k,v in pairs(areawarlog) do
							if v and v[1] then
								local isHas=false
								local id=tonumber(v[1])
								for m,n in pairs(self.myReportList) do
									if tonumber(n.id)==tonumber(id) then
										isHas=true
									end
								end
								if isHas==false then
									local reportVo=localWarReportVo:new()
									reportVo:initWithData(v)
									local diffTime=base.serverTime-(reportVo.time or 0)
									if (diffTime/86400)>=(localWarCfg.battleTime+localWarCfg.buffTime) then
									else
										table.insert(self.myReportList,reportVo)
									end
								end
							end
						end
						local function sortFunc(a,b)
							if a and b and a.id and b.id then
								return a.id>b.id
							end
						end
						table.sort(self.myReportList,sortFunc)
						while SizeOfTable(self.myReportList)>localWarCfg.reportMaxNum do
							table.remove(self.myReportList,localWarCfg.reportMaxNum+1)
						end
					end
					self:setIsNewReport(type,1)
				end
				-- local rData={
				-- 	-- 2：建筑类型
				-- 	-- 3：攻击方名字
				-- 	-- 4：防守方名字
				-- 	-- 5：攻击方军团名字
				-- 	-- 6：防守方军团名字
				-- 	-- 9：时间
				-- 	-- 7：是否胜利：0否，1是
				-- 	-- 8：是否占领：0否，1是
				-- 	{1,"a1","attackName","defenceName","attackAName","defenceAName",base.serverTime,1,0},
				-- 	{2,"a2","attackName","defenceName","attackAName","defenceAName",base.serverTime,1,1},
				-- 	{3,"a3","attackName","defenceName","attackAName","defenceAName",base.serverTime,0,0},
				-- 	{4,"a4","attackName","defenceName","attackAName","defenceAName",base.serverTime,0,1},
			 --    }
				-- for k,v in pairs(rData) do
				-- 	if v then
				-- 		local reportVo=localWarReportVo:new()
				-- 		reportVo:initWithData(v)
				-- 		table.insert(self.reportList,reportVo)
				-- 	end
				-- end
				if callback then
					callback()
				end
			end
		end
		socketHelper:areawarList(type,id,aid,areawarListCallback)
	else
		if callback then
			callback()
		end
	end
end

--获取战斗战报信息
function localWarVoApi:getBattleReport(type,id,callback)
	if type and id then
		local report
		local reportList=self:getReportList(type)
		for k,v in pairs(reportList) do
			if v and v.id==id and v.report and SizeOfTable(v.report)>0 then
				report=v.report
			end
		end
		if report and SizeOfTable(report)>0 then
			if callback then
				callback(report)
			end
		else
			local function reportCallback(fn,data)
				local ret,sData=base:checkServerData(data)
				if ret==true then
					if sData.data and sData.data.report then
						local report=sData.data.report
						if report and SizeOfTable(report)>0 then
							self:setBattleReport(type,id,report)
							if callback then
								callback(report)
							end
						end
					end
				end
			end
			socketHelper:areawarReport(type,id,reportCallback)
		end
	end
end

--获取功绩排行榜
function localWarVoApi:updateRankList(type,page,callback)
	require "luascript/script/game/gamemodel/localWar/localWarFeatRankVo"
	if type==nil then
		type=1
	end
	if page==nil then
		page=1
	end
	local aid
	local selfAlliance=allianceVoApi:getSelfAlliance()
	if selfAlliance and type==2 then
		aid=selfAlliance.aid
	end
	if type==2 and aid==nil then
		do return end
	end
	local checkStatus=self:checkStatus()
	if page==1 and (checkStatus==21 or (checkStatus~=21 and self:getInitFeatRank(type)==-1)) then
		local function donatelistCallback(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				if sData.data and sData.data.areaWarserver then
					if sData.data.areaWarserver.donateRows then
						local maxNum=tonumber(sData.data.areaWarserver.donateRows)
						self:setMaxRankNum(type,maxNum)
					end
					local myRank=0
					if sData.data.areaWarserver.myrank then
						myRank=tonumber(sData.data.areaWarserver.myrank)
					end
					if sData.data.areaWarserver.myrows then
						local myrows=sData.data.areaWarserver.myrows
						if myrows and SizeOfTable(myrows)>0 then
							local featRankVo=localWarFeatRankVo:new()
							local rank=myRank
							local name=myrows[1] or ""
							local point=tonumber(myrows[2]) or 0
							local power=tonumber(myrows[3]) or 0
							local frData={rank=rank,name=name,power=power,point=point}
							featRankVo:initWithData(frData)
							self:setMyFeatRankData(type,featRankVo)
						end
					end
					if sData.data.areaWarserver.donateList then
						local donateList=sData.data.areaWarserver.donateList
						if donateList and SizeOfTable(donateList)>0 then
							self:clearFeatRank(type)
							for k,v in pairs(donateList) do
								if v then
									local featRankVo=localWarFeatRankVo:new()
									local rank=k
									local name=v[1] or ""
									local point=tonumber(v[2]) or 0
									local power=tonumber(v[3]) or 0
									local frData={rank=rank,name=name,power=power,point=point}
									featRankVo:initWithData(frData)
									if type==2 then
										table.insert(self.featRank,featRankVo)
									else
										table.insert(self.allFeatRank,featRankVo)
									end
								end
							end
							local function sortFunc(a,b)
								if a and b and a.rank and b.rank then
									return a.rank<b.rank
								end
							end
							if type==2 then
								table.sort(self.featRank,sortFunc)
							else
								table.sort(self.allFeatRank,sortFunc)
							end
						end
					end
				end
				if checkStatus==21 then
					localWarVoApi:setInitFeatRank(type,-1)
				else
					localWarVoApi:setInitFeatRank(type,1)
				end
				if callback then
					callback()
				end
			end
		end
		socketHelper:areawarDonatelist(aid,playerVoApi:getUid(),1,donatelistCallback)
	elseif page>1 then
		if self:getHasMoreRankNum(type)==true then
			local function donatelistCallback(fn,data)
				local ret,sData=base:checkServerData(data)
				if ret==true then
					if sData.data and sData.data.areaWarserver then
						if sData.data.areaWarserver.donateRows then
							local maxNum=tonumber(sData.data.areaWarserver.donateRows)
							self:setMaxRankNum(type,maxNum)
						end
						local myRank=0
						if sData.data.areaWarserver.myrank then
							myRank=tonumber(sData.data.areaWarserver.myrank)
						end
						if sData.data.areaWarserver.myrows then
							local myrows=sData.data.areaWarserver.myrows
							if myrows and SizeOfTable(myrows)>0 then
								local featRankVo=localWarFeatRankVo:new()
								local rank=myRank
								local name=myrows[1] or ""
								local point=tonumber(myrows[2]) or 0
								local power=tonumber(myrows[3]) or 0
								local frData={rank=rank,name=name,power=power,point=point}
								featRankVo:initWithData(frData)
								self:setMyFeatRankData(type,featRankVo)
							end
						end
						if sData.data.areaWarserver.donateList then
							local donateList=sData.data.areaWarserver.donateList
							if donateList and SizeOfTable(donateList)>0 then
								for k,v in pairs(donateList) do
									if v then
										local featRankVo=localWarFeatRankVo:new()
										local rank=k+(page-1)*self.featRankPageNum
										local name=v[1] or ""
										local point=tonumber(v[2]) or 0
										local power=tonumber(v[3]) or 0
										local frData={rank=rank,name=name,power=power,point=point}
										featRankVo:initWithData(frData)
										if type==2 then
											table.insert(self.featRank,featRankVo)
										else
											table.insert(self.allFeatRank,featRankVo)
										end
									end
								end
							end
						end
					end
					if callback then
						callback()
					end
				end
			end
			socketHelper:areawarDonatelist(aid,playerVoApi:getUid(),page,donatelistCallback)
		else
			if callback then
				callback()
			end
		end
	else
		if callback then
			callback()
		end
	end
end

-- --获取当前部队 战斗战报信息
-- function localWarVoApi:getBattleReport(type,id,callback)
-- 	if type and id then
-- 		local report
-- 		local reportList=self:getReportList(type)
-- 		for k,v in pairs(reportList) do
-- 			if v and v.id==id and v.report and SizeOfTable(v.report)>0 then
-- 				report=v.report
-- 			end
-- 		end
-- 		if report and SizeOfTable(report)>0 then
-- 			if callback then
-- 				callback(report)
-- 			end
-- 		else
-- 			local function reportCallback(fn,data)
-- 				local ret,sData=base:checkServerData(data)
-- 				if ret==true then
-- 					if sData.data and sData.data.report then
-- 						local report=sData.data.report
-- 						if report and SizeOfTable(report)>0 then
-- 							self:setBattleReport(type,id,report)
-- 							if callback then
-- 								callback(report)
-- 							end
-- 						end
-- 					end
-- 				end
-- 			end
-- 			socketHelper:areawarReport(type,id,reportCallback)
-- 		end
-- 	end
-- end

-------------以上接口---------------

function localWarVoApi:updateOffice()
	if self:checkStatus()==21 then
		local officeTab=self:getOfficeTab()
		if officeTab and SizeOfTable(officeTab)>0 then
			self:setOfficeTab({})
			self:setOfficeFlag(0)
		end
	end
end
function localWarVoApi:canSetOffice(type,index)
	local selfAlliance=allianceVoApi:getSelfAlliance()
	if type and selfAlliance then
        local ownCityInfo=self:getOwnCityInfo()
        if ownCityInfo and ownCityInfo.own_at and base.serverTime<tonumber(ownCityInfo.own_at) and tonumber(ownCityInfo.aid)==tonumber(selfAlliance.aid) and playerVoApi:getPlayerName()==ownCityInfo.kingname then
        	local playerInfo=localWarVoApi:getOfficeByType(type,index)
	        if playerInfo and SizeOfTable(playerInfo)>0 then
	        else
            	return true	--为空，即有空位置，可以设置(包括俘虏)
	        end
        end
    end
    return false
end


function localWarVoApi:getIsNewReport(type)
	if type then
		return self.isNewReport[type]
	end
	return -1
end
function localWarVoApi:setIsNewReport(type,isNewReport)
	if type then
		self.isNewReport[type]=isNewReport
	end
end
function localWarVoApi:getReportList(type)
	if type==2 then
		return self.myReportList
	else
		return self.reportList
	end
end
function localWarVoApi:setBattleReport(type,id,report)
	if id then
		if type==2 then
			for k,v in pairs(self.myReportList) do
				if v and v.id==id then
					v.report=report
				end
			end
		else
			for k,v in pairs(self.reportList) do
				if v and v.id==id then
					v.report=report
				end
			end
		end
	end
end

function localWarVoApi:getInitFeatRank(type)
	if type then
		return self.initFeatRank[type]
	end
	return -1
end
function localWarVoApi:setInitFeatRank(type,initFeatRank)
	if type then
		self.initFeatRank[type]=initFeatRank
	end
end
function localWarVoApi:getMaxRankNum(type)
	if type then
		return self.maxRankNum[type]
	end
	return 0
end
function localWarVoApi:setMaxRankNum(type,num)
	if type then
		self.maxRankNum[type]=num
	end
end
function localWarVoApi:getHasMoreRankNum(type)
	if type then
		local featRank=self:getFeatRank(type)
		local num=SizeOfTable(featRank)
		local maxRankNum=self:getMaxRankNum(type)
		if num<maxRankNum then
			return true
		end
	end
	return false
end
function localWarVoApi:getMyFeatRankData(type)
	if type then
		return self.myFeatRankData[type]
	end
	return nil
end
function localWarVoApi:setMyFeatRankData(type,frData)
	if type then
		self.myFeatRankData[type]=frData
	end
end
function localWarVoApi:clearFeatRank(type)
	if type==2 then
		self.featRank={}
	else
		self.allFeatRank={}
	end
end
function localWarVoApi:getFeatRank(type)
	if type==2 then
		return self.featRank
	else
		return self.allFeatRank
	end
end

function localWarVoApi:getCityLogList()
	return self.cityLogList
end
function localWarVoApi:setCityLogList(cityLogList)
	self.cityLogList=cityLogList
	if self.cityLogList and SizeOfTable(self.cityLogList)>0 then
		for k,v in pairs(self.cityLogList) do
			if v then
				v.index=k
			end
		end
		local function sortFunc(a,b)
			if a and b and a.index and b.index then
				return a.index>b.index
			end
		end
		table.sort(self.cityLogList,sortFunc)
	end
end

function localWarVoApi:getAllianceMemFeatList()
	return self.allianceMemFeatList
end
function localWarVoApi:setAllianceMemFeatList(allianceMemFeatList)
	self.allianceMemFeatList=allianceMemFeatList
end

function localWarVoApi:getSlaveList()
	return self.slaveList
end
function localWarVoApi:setSlaveList(slaveList)
	self.slaveList=slaveList
end

function localWarVoApi:getOfficeFlag()
	return self.officeFlag
end
function localWarVoApi:setOfficeFlag(officeFlag)
	self.officeFlag=officeFlag
end

function localWarVoApi:getOfficeTab()
	return self.officeTab
end
function localWarVoApi:setOfficeTab(officeTab)
	self.officeTab=officeTab
end
function localWarVoApi:getOfficeByType(type,index)
	if self.officeTab and self.officeTab["j"..type] then
		local selfUid = playerVoApi:getUid()
		if type==10 and index then
			--修正自己的昵称
			if self.officeTab["j"..type][index] then
				local uid = self.officeTab["j"..type][index][1]
				if tonumber(uid)==tonumber(selfUid) then
					self.officeTab["j"..type][index][2]=playerVoApi:getPlayerName()
				end
			end
			return self.officeTab["j"..type][index]
		else
			--修正自己的昵称
			if self.officeTab["j"..type][1] then
				local uid = self.officeTab["j"..type][1][1]
				if tonumber(uid)==tonumber(selfUid) then
					self.officeTab["j"..type][1][2]=playerVoApi:getPlayerName()
				end
			end
			return self.officeTab["j"..type][1]
		end
	end
	return nil
end
function localWarVoApi:setOfficeByType(type,infoData)
	if self.officeTab and type and infoData then
		if self.officeTab["j"..type]==nil then
			self.officeTab["j"..type]={}
		end
		if type==10 then --为俘虏时，1~5的位置按顺序设置
			if infoData and localWarCfg.jobs and localWarCfg.jobs[type] and localWarCfg.jobs[type].count then
				if SizeOfTable(self.officeTab["j"..type])<=localWarCfg.jobs[type].count then
					local isHas=false
					for k,v in pairs(self.officeTab["j"..type]) do
						if v and v[1] and infoData[1] and tonumber(v[1])==tonumber(infoData[1]) then
							isHas=true
						end
					end
					if isHas==false then
						table.insert(self.officeTab["j"..type],infoData)
					end
				end
			end
		else
			self.officeTab["j"..type][1]=infoData
		end
	end
end

function localWarVoApi:canJoinBattle()
	local selfAlliance=allianceVoApi:getSelfAlliance()
	if(selfAlliance~=nil)then
		local joinTime=allianceVoApi:getJoinTime()
		local startTime=self:getStartTime()
		if joinTime and joinTime>0 and joinTime<(startTime+86400) then
			if self:getIsCanBattle()==true then
		        return true
		    else
		    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("local_war_can_not_join_battle1"),30)
		    	return false
		    end
		else
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("local_war_can_not_join_battle2"),30)
	    	return false
		end
	else
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("local_war_no_alliance_tip"),30)
		return false
	end
end

function localWarVoApi:getIsCanBattle()
	return self.isCanBattle
end
function localWarVoApi:setIsCanBattle(isCanBattle)
	self.isCanBattle=isCanBattle
end

function localWarVoApi:getSelfApplyData()
	return self.selfApplyData
end
function localWarVoApi:setSelfApplyData(selfApplyData)
	self.selfApplyData=selfApplyData
end

function localWarVoApi:getApplyAllianceNum()
	return self.applyAllianceNum
end
function localWarVoApi:setApplyAllianceNum(applyAllianceNum)
	self.applyAllianceNum=applyAllianceNum
end

function localWarVoApi:getApplyRank()
	return self.applyRank
end

function localWarVoApi:getOwnCityInfo()
	return self.ownCityInfo
end
function localWarVoApi:setOwnCityInfo(cityInfo)
	self.ownCityInfo=cityInfo
	if self.ownCityInfo and self.ownCityInfo.uid then
		local uid = playerVoApi:getUid()
		if tonumber(uid)==tonumber(self.ownCityInfo.uid) then
			self.ownCityInfo.kingname=playerVoApi:getPlayerName()
		end
	end
end
function localWarVoApi:getIsOwnCity()
	return self.isOwnCity
end
function localWarVoApi:setIsOwnCity(isOwnCity)
	self.isOwnCity=isOwnCity
end


--获取部队标示
function localWarVoApi:getTankInfoFlag()
	return self.tankInfoFlag
end
function localWarVoApi:setTankInfoFlag(flag)
	self.tankInfoFlag=flag
end

--上次设置部队时间
function localWarVoApi:getLastSetFleetTime()
	return self.lastSetFleetTime
end
function localWarVoApi:setLastSetFleetTime(time)
	self.lastSetFleetTime=time
end

--获取buff的描述
function localWarVoApi:getBuffStr(buffId)
	local buffStr=""
	if buffId and localWarCfg.buff and localWarCfg.buff[buffId] then
		local cfg=localWarCfg.buff[buffId]
		local value=cfg.value*100
		if buffId==10 then
			value=cfg.value
		end
		buffStr=getlocal("local_war_buff_"..cfg.type,{value})
	end
	return buffStr
end

--获取自己的职位和过期时间，区域战的buff
--"jobs":{"job":1,"end_at":1444134600}
--return {1,2,3,4,5,6,7,8}
-- 1 build="建造速度增加%s%",
-- 2 tech="研究速度增加%s%",
-- 3 attack="行军速度增加%s%",
-- 4 challenge="关卡战斗经验增加%s%",
-- 5 resource="野外采集速度增加%s%",
-- 6 troops="生产坦克速度增加%s%",
-- 7 houseStorage="基地资源产量增加%s%",
-- 8 prop="道具生产速度增加%s%",
-- 9 houseStoragedel="资源保护减少%s%",
-- 10 allianceFunds="每日为首都军团提供%s军团资金",
function localWarVoApi:getSelfOffice()
	if base.localWarSwitch==1 then
	    if self.jobs then
	    	if self.jobs.job and self.jobs.end_at and base.serverTime<self.jobs.end_at then
	            local jobType=self.jobs.job
	            if jobType and localWarCfg and localWarCfg.jobs and localWarCfg.jobs[jobType] and localWarCfg.jobs[jobType].buff then
	                return localWarCfg.jobs[jobType].buff
	            end
	        end
	    else
			local ownCityInfo=self:getOwnCityInfo()
			if ownCityInfo and ownCityInfo.own_at and ownCityInfo.kingname then
				local endTime=tonumber(ownCityInfo.own_at)
				if base.serverTime<endTime and playerVoApi:getPlayerName()==ownCityInfo.kingname then
					return localWarCfg.jobs[1].buff
				end
			end
	    end
	end
    return {}
end
function localWarVoApi:setSelfOffice(jobs)
    self.jobs=jobs
end

-- 0可以设置,1不能设置
function localWarVoApi:getSetFleetStatus()
	local status=self:checkStatus()
	if status>=20 and status<30 then
		return 0
	end
	return 1,getlocal("local_war_troops_cannot_set_fleet")
end

function localWarVoApi:getStartTime()
	--周几 1~7对应周一到周日
	local weekDay=G_getFormatWeekDay(base.serverTime)
	local startTime=G_getWeeTs(base.serverTime)-(weekDay-1)*86400
	return startTime
end

--判断是否可以进行军团操作
--type：1.退出，2.踢人
function localWarVoApi:canQuitAlliance(type)
	if base.localWarSwitch==1 then
		local selfAlliance=allianceVoApi:getSelfAlliance()
		if selfAlliance==nil then
			do return false end
		end
		local checkStatus=self:checkStatus()
		if checkStatus==0 then
			return true
		else
			if checkStatus==21 then
				local isCanBattle=self:getIsCanBattle()
				if isCanBattle==true then
					if type==1 then
						if selfAlliance.role and tonumber(selfAlliance.role)==2 then
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("local_war_operate_alliance_tip1"),30)
						else
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("local_war_operate_alliance_tip2"),30)
						end
					else
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("local_war_operate_alliance_tip3"),30)
					end
					return false
				end
			else
				local isLimit=0
				if checkStatus==10 then
					local selfApplyData=self:getSelfApplyData()
					if selfApplyData and SizeOfTable(selfApplyData)>0 then
						isLimit=4
					end
				elseif checkStatus==20 then
					local isCanBattle=self:getIsCanBattle()
					if isCanBattle==true then
						isLimit=5
					end
				else
					local selfAlliance=allianceVoApi:getSelfAlliance()
					local ownCityInfo=self:getOwnCityInfo()
					if ownCityInfo and ownCityInfo.aid and selfAlliance and tonumber(selfAlliance.aid)==tonumber(ownCityInfo.aid) then
						isLimit=6
					end
				end
				if isLimit>0 and type==1 and selfAlliance.role and tonumber(selfAlliance.role)==2 then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("local_war_operate_alliance_tip"..(isLimit)),30)
					return false
				else
					return true
				end
			end
		end
	else
		return true
	end
end


--区域战状态
--0 未开启
--10 报名期
--20 争夺期
--21 战斗期
--30 占领期
function localWarVoApi:checkStatus()
	local timeStr=""
	--周几 1~7对应周一到周日
	local weekDay=G_getFormatWeekDay(base.serverTime)
	local startWeekDay=localWarCfg.prepareTime
	if startWeekDay==0 then
		startWeekDay=7
	end
    local battleDays=localWarCfg.battleTime
    local buffDays=localWarCfg.buffTime
	if weekDay==startWeekDay then
		local signupTime=G_getWeeTs(base.serverTime)+86400
		timeStr=getlocal("local_war_time",{G_getDataTimeStr(G_getWeeTs(base.serverTime),true,true),G_getDataTimeStr(signupTime,true,true)})
		return 10,timeStr,G_ColorYellowPro,signupTime
	elseif weekDay==(startWeekDay+battleDays) then
		local signupTime=G_getWeeTs(base.serverTime)
		local battleStartTime=signupTime+localWarCfg.startWarTime[1]*3600+localWarCfg.startWarTime[2]*60
		local battleEndTime=battleStartTime+localWarCfg.maxBattleTime
		local endTime=G_getWeeTs(base.serverTime)+86400
		local battleHour=math.floor(localWarCfg.maxBattleTime/3600)
		local battleMin=localWarCfg.maxBattleTime%3600
		local battleSt=localWarCfg.startWarTime[1]..":"..localWarCfg.startWarTime[2]
		local battleEt=(localWarCfg.startWarTime[1]+battleHour)..":"..(localWarCfg.startWarTime[2]+battleMin)
		timeStr=getlocal("local_war_time2",{G_getDataTimeStr(signupTime,true,true),battleSt,battleEt})
		if base.serverTime>=signupTime and base.serverTime<battleStartTime then
			return 20,timeStr,G_ColorRed,battleStartTime
		elseif base.serverTime>=battleStartTime and base.serverTime<battleEndTime then
			local isBattleEnd=false
			local ownCityInfo=self:getOwnCityInfo()
			if ownCityInfo and ownCityInfo.own_at and base.serverTime<tonumber(ownCityInfo.own_at) then
				isBattleEnd=true
			elseif localWarFightVoApi and localWarFightVoApi:checkIsEnd()==true then
				isBattleEnd=true
			end
			if isBattleEnd==true then
				local st=G_getWeeTs(base.serverTime)-86400*(weekDay-3)
				local et=G_getWeeTs(base.serverTime)+86400*(7-weekDay+1)-1
				timeStr=getlocal("local_war_time",{G_getDataTimeStr(st,true,true),G_getDataTimeStr(et,true,true)})
				return 30,timeStr,G_ColorGreen,et
			else
				return 21,timeStr,G_ColorRed,battleEndTime
			end
		else
			local st=G_getWeeTs(base.serverTime)-86400*(weekDay-3)
			local et=G_getWeeTs(base.serverTime)+86400*(7-weekDay+1)-1
			timeStr=getlocal("local_war_time",{G_getDataTimeStr(st,true,true),G_getDataTimeStr(et,true,true)})
			return 30,timeStr,G_ColorGreen,et
		end
	elseif weekDay>(startWeekDay+battleDays) and weekDay<=(startWeekDay+battleDays+buffDays) then
		local st=G_getWeeTs(base.serverTime)-86400*(weekDay-3)
		local et=G_getWeeTs(base.serverTime)+86400*(7-weekDay+1)-1
		timeStr=getlocal("local_war_time",{G_getDataTimeStr(st,true,true),G_getDataTimeStr(et,true,true)})
		return 30,timeStr,G_ColorGreen,et
	end

	-- if self.startTime then
	-- 	local timeStr=""
	-- 	local signupTime=G_getWeeTs(self.startTime)+86400*localWarCfg.prepareTime
	-- 	if self.startTime~=G_getWeeTs(self.startTime) then
	-- 		signupTime=G_getWeeTs(self.startTime)+86400*(localWarCfg.prepareTime+1)
	-- 	end
	-- 	local battleStartTime=signupTime+localWarCfg.startWarTime[1]*3600+localWarCfg.startWarTime[2]*60
	-- 	local battleEndTime=battleStartTime+localWarCfg.maxBattleTime
	-- 	if base.serverTime<signupTime then
	-- 		timeStr=getlocal("local_war_time",{G_getDataTimeStr(G_getWeeTs(self.startTime),true,true),G_getDataTimeStr((signupTime-1),true,true)})
	-- 		return 10,timeStr,G_ColorYellowPro,signupTime
	-- 	elseif base.serverTime>=signupTime and base.serverTime<battleEndTime then
	-- 		local battleHour=math.floor(localWarCfg.maxBattleTime/3600)
	-- 		local battleMin=localWarCfg.maxBattleTime%3600
	-- 		local battleSt=localWarCfg.startWarTime[1]..":"..localWarCfg.startWarTime[2]
	-- 		local battleEt=(localWarCfg.startWarTime[1]+battleHour)..":"..(localWarCfg.startWarTime[2]+battleMin)
	-- 		timeStr=getlocal("local_war_time2",{G_getDataTimeStr(signupTime,true,true),battleSt,battleEt})
	-- 		if base.serverTime>=signupTime and base.serverTime<battleStartTime then
	-- 			return 20,timeStr,G_ColorRed,battleEndTime
	-- 		elseif base.serverTime>=battleStartTime and base.serverTime<battleEndTime then
	-- 			return 21,timeStr,G_ColorRed,battleEndTime
	-- 		end
	-- 	else
	-- 		local st=signupTime+86400*localWarCfg.battleTime
	-- 		local et=signupTime+86400*(localWarCfg.battleTime+localWarCfg.buffTime)
	-- 		timeStr=getlocal("local_war_time",{G_getDataTimeStr(st,true,true),G_getDataTimeStr(et,true,true)})
 --    		return 30,timeStr,G_ColorGreen,et
	-- 	end
	-- end
	return 0,"",G_ColorWhite,0
end

function localWarVoApi:clear()
	if(localWarFightVoApi and localWarFightVoApi.clear)then
		localWarFightVoApi:clear()
	end
	self.initFlag=nil
	self.initBuildingFlag=false
	self.localWarId=nil
	self.startTime=nil
	self.endTime=nil
	self.lastSetFleetTime=0
	self.tankInfoFlag=-1

	self.ownCityInfo={}
	self.isOwnCity=false
	self.applyRank={}
	self.applyAllianceNum=0
	self.selfApplyData={}
	self.isCanBattle=nil
	self.officeTab={}
	self.officeFlag=nil
	self.officeLastStatus=-1
	self.slaveList={}
	self.jobs={}
	self.cityLogList={}
	self.reportList={}
	self.myReportList={}
	self.isNewReport={-1,-1}
	self.allFeatRank={}
	self.featRank={}
	self.maxRankNum={0,0}
	self.initFeatRank={-1,-1}
	self.featRankPageNum=20
	self.myFeatRankData={}
	self.allianceMemFeatList={}
	self.task={}
end