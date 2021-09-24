acGangtierongluVoApi={}

-- 这里需要修改
function acGangtierongluVoApi:getAcVo()
	return activityVoApi:getActivityVo("gangtieronglu")
end

function acGangtierongluVoApi:canReward()
	local isfree=false	
	local _,readyTb = self:getThreeTb()
	if SizeOfTable(readyTb)==0 then
		isfree=false
	else
		isfree=true
	end
	return isfree
end

-- function acGangtierongluVoApi:isToday()
-- 	local isToday=false
-- 	local vo = self:getAcVo()
-- 	local lastTime=vo.lastTime or 0
-- 	if lastTime then
-- 		isToday=G_isToday(lastTime)
-- 	end
-- 	return isToday
-- end

function acGangtierongluVoApi:getTargetList()
	local vo = self:getAcVo()
	local tasklist=vo.tasklist or {}
	local targetList={}
	for k,v in pairs(tasklist) do
		local item = {key=k,conditions=v.conditions,reward=v.reward,index=v.index}
		table.insert(targetList,item)
	end

	local function sortFunc(a,b)
		return a.index<b.index
	end

	table.sort(targetList,sortFunc)

	return targetList
end

function acGangtierongluVoApi:getFlagTb()
	local vo = self:getAcVo()
	return vo.flagTb or {}
end

function acGangtierongluVoApi:getA()
	local vo = self:getAcVo()
	return vo.a or 0
end

function acGangtierongluVoApi:getRById(aid)
	local vo = self:getAcVo()
	local r =  vo.r or {}
	return r[aid] or 0
end

function acGangtierongluVoApi:getH()
	local vo = self:getAcVo()
	return vo.h or 0
end

function acGangtierongluVoApi:getGById(aid)
	local vo = self:getAcVo()
	local g = vo.g or {}
	return g[aid] or 0
end

function acGangtierongluVoApi:getCost()
	local vo = self:getAcVo()
	return vo.cost or 99999999
end

function acGangtierongluVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

function acGangtierongluVoApi:getTankData()
	local vo = self:getAcVo()
	vo.exchange = vo.exchange or {}

	local exchange={}
	for k,v in pairs(vo.exchange) do
		table.insert(exchange,{key=k,num=v.num,index=v.index})
	end

	local function soryFunc(a,b)
		return a.index<b.index
	end
	table.sort(exchange,soryFunc)

	local _,tankTb = tankVoApi:getAllTanksInByType()

	local tankData={}
	local myKeyTb={}
	local myTankTb={}
	for k,v in pairs(tankTb) do
		local key="a" .. k
		if vo.exchange[key] then
			myTankTb[k]=v
		end
	end

	for i=1,#exchange do
		local key = tonumber(exchange[i].key) or tonumber(RemoveFirstChar(exchange[i].key))
		if myTankTb[key] then
			table.insert(myKeyTb,{key=key})
		end
	end

	tankData[1]=myKeyTb
	tankData[2]=myTankTb

	return tankData
end

function acGangtierongluVoApi:getThreeTb()
	local targetList=self:getTargetList() or {}
	local flagTb=self:getFlagTb()

	local alreadyTb = {}
	local readyTb={}
	local noReadyTb={}

	for i=1,#targetList do
		local key = targetList[i].key
		if flagTb[key] then
			table.insert(alreadyTb,targetList[i])
		else
			local conditions = targetList[i].conditions
			local myType=conditions.type
			local num1 = conditions.num -- 需要的num
			local num2 = 0
			if myType=="a" then
				num2=acGangtierongluVoApi:getA()
			elseif myType=="r" then
				num2=acGangtierongluVoApi:getRById(conditions.name)
			elseif myType=="h" then
				num2=acGangtierongluVoApi:getH()
			else
				num2=acGangtierongluVoApi:getGById(conditions.name)
			end
			if num1>num2 then
				table.insert(noReadyTb,targetList[i])
			else
				table.insert(readyTb,targetList[i])
			end
		end
	end
	return alreadyTb,readyTb,noReadyTb

end

function acGangtierongluVoApi:getExchange()
	local vo = self:getAcVo()
	return vo.exchange or {}
end

function acGangtierongluVoApi:getVersion()
	local vo = self:getAcVo()
	if vo and vo.version then
		return tonumber(vo.version)
	end
	return 1
end

-------合成,熔炼纪录展示
function acGangtierongluVoApi:showLog(layerNum)
	local function callBack(fn,data)
		local ret,sData = base:checkServerData(data)
		local displayLogList = {}
		local displayTimeList = {}
		----------------纪录的str列表
        if ret==true then
            if sData and sData.data and sData.data.log then
           		for k,v in pairs(sData.data.log) do
           			local logLabel
           			local timeLabel
           			logLabel,timeLabel = self:handleLogData(v)
           			table.insert(displayLogList,logLabel)
           			table.insert(displayTimeList,timeLabel)
           		end
				require "luascript/script/game/scene/gamedialog/activityAndNote/acGangtierongluSmallDialog"
           		acGangtierongluSmallDialog:showLogDialog(CCSizeMake(550,G_VisibleSizeHeight-300),getlocal("activity_gangtieronglu_record_title"),30,displayLogList,displayTimeList,G_ColorWhite,layerNum)
            else
				--无纪录特殊显示
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_no_record"),30)
            end
        end
	end
	socketHelper:acGangtierongluTotal(4,nil,nil,nil,callBack)

end	
--------处理服务器返回的信息	
function acGangtierongluVoApi:handleLogData( logData )
	local LogStr
	local logLabel
	local timeLabel
	--------坦克信息，资源信息,操作时间
	local tankName
	local tankNum
	local resName
	local resNum
	local time
	-----熔炼
	if logData[1] == 1 then
		time = G_getDataTimeStr(tonumber(logData[4]))
		timeLabel = GetTTFLabel(time,23)
		tankName,tankNum = self:formatTankInfo(logData[2])
		resName,resNum = self:formatResInfo(logData[3])
		LogStr = getlocal("activity_gangtieronglu_melt_log",{tankNum,tankName,resName,resNum})
		logLabel = GetTTFLabelWrap(LogStr,23,CCSizeMake(360,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	-----合成(颜色特殊显示，黄色)
	else
		time = G_getDataTimeStr(tonumber(logData[4]))
		timeLabel = GetTTFLabel(time,23)
		tankName,tankNum = self:formatTankInfo(logData[3])
		resName,resNum = self:formatResInfo(logData[2])
		LogStr = getlocal("activity_gangtieronglu_composite_log",{resName,resNum,tankNum,tankName})
		logLabel = GetTTFLabelWrap(LogStr,23,CCSizeMake(360,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		timeLabel:setColor(G_ColorYellowPro)
		logLabel:setColor(G_ColorYellowPro)
	end
	return logLabel,timeLabel
end
--------格式化坦克信息
function acGangtierongluVoApi:formatTankInfo( tankData )
	local tankName
	local tankNum
	for k,v in pairs(tankData) do
		tankName = getlocal(tankCfg[tonumber(RemoveFirstChar(k))].name)
		tankNum = FormatNumber(tonumber(v))
	end
	return tankName,tankNum
end
--------格式化资源信息
function acGangtierongluVoApi:formatResInfo( resData )
	local resName
	local resNum
	for k,v in pairs(resData) do
		resName = getItem(k,"u")
		resNum = FormatNumber(tonumber(v))
	end
	return resName,resNum
end
function acGangtierongluVoApi:clearAll()
end