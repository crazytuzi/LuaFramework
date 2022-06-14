

BUG_REPORT = {}

BUG_REPORT.values = {}
BUG_REPORT.syncKing = {}  
BUG_REPORT.SyncBattleHandler = {}  

function BUG_REPORT.onSyncBattleHandler( battleType, battleGuid, isReplay,force, attackPlan, guardPlan, attackMagics, guardMagics )
	BUG_REPORT.SyncBattleHandler = {battleType = battleType, battleGuid = battleGuid, isReplay = isReplay,force = force, attackPlan = attackPlan, guardPlan = guardPlan, attackMagics = attackMagics, guardMagics = guardMagics}
end

function BUG_REPORT.onSyncKingHandler( icon, name, myths, intelligence, force, level, mp, maxMP, costRatio)
	BUG_REPORT.syncKing[force] ={ icon = icon, name = name, myths=myths, intelligence = intelligence, force = force, level = level, mp = mp, maxMP = maxMP, costRatio = costRatio }
end

function BUG_REPORT.onBattleResultHandler( value,clear )
	if(clear == true)then
		BUG_REPORT.values = {}
	end
	table.insert(BUG_REPORT.values, clone(value))
end

function BUG_REPORT.sendLog(fileName)
	local file =  "lordlog.txt"
	local userName =   fio.readIni("login", "userName", "", "config.cfg");
	local url =  FTP_URL..userName.."/"
	ftp_post_file(url..fileName,file)
end


function BUG_REPORT.sendBattleData(info)
	
	 
	local userName =   fio.readIni("login", "userName", "", "config.cfg"); --(dataManager.playerData:getName())
	local url =  FTP_URL..userName.."/"
	
	local temp =  os.date("*t", dataManager.getServerTime())	 --dataManager.getServerTime()
	
	--(temp.year.."Y"..temp.month.."M"..temp.day.."D"..temp.hour.."h"..temp.min.."m"..temp.sec.."s")   
	local fileName = userName.."-"..(temp.year..temp.month..temp.day..temp.hour..temp.min..temp.sec)   
	
	
	local file = fio.open(fileName, 1)	 
	info = info or "no user info"
	info = info..(temp.year.."Y"..temp.month.."M"..temp.day.."D"..temp.hour.."h"..temp.min.."m"..temp.sec.."s")   
	fio.write(file, info)
	fio.write(file, "\n")
	
	if( BUG_REPORT.SyncBattleHandler )then
		local data = json.encode(BUG_REPORT.SyncBattleHandler)		
		fio.write(file, data)

	end
	fio.write(file, "\n")
	
	if( BUG_REPORT.syncKing )then
		local data = json.encode(BUG_REPORT.syncKing[enum.FORCE.FORCE_ATTACK])		
		fio.write(file, data)
		fio.write(file, "\n")
				
		data = json.encode(BUG_REPORT.syncKing[enum.FORCE.FORCE_GUARD ])		
		fio.write(file, data)
	end
	
 
	
	fio.write(file, "\n")

	local size = #BUG_REPORT.values
	for i,v in ipairs (BUG_REPORT.values) do
		local data = json.encode(v)	
		fio.write(file, data)
		if(i ~= size) then
			fio.write(file, "&&")
		end
	end

	fio.close(file)	
	ftp_post_file(url..fileName,fileName)
	
	BUG_REPORT.sendLog(fileName..".log")
	
	eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo = "bug提交成功..代号："..fileName });
end



function BUG_REPORT.replayBattle(file)
	file = file -- "反射·战士-2014Y12M11D18h0m35s"
	local file = fio.open(file, 0)	 
	local fileStr = fio.readall(file)
	fio.close(file)		
	
	BUG_REPORT.allBattleData = string.split(fileStr, "\n")
	local data = json.decode( BUG_REPORT.allBattleData[2] )
	if(data~="null" and data ~= nil)then
		SyncBattleHandler( data.battleType, data.battleGuid, data.isReplay,data.force, data.attackPlan, data.guardPlan, data.attackMagics, data.guardMagics )
	end
	data = json.decode( BUG_REPORT.allBattleData[3] )
	 
	if(data~="null" and data ~= nil)then	
		SyncKingHandler( data.icon, data.name, data.myths, data.intelligence, data.force, data.level, data.mp, data.maxMP, data.costRatio )
	end
	data = json.decode( BUG_REPORT.allBattleData[4] )
	
	if(data~="null" and data ~= nil)then	
		SyncKingHandler( data.icon, data.name, data.myths, data.intelligence, data.force, data.level, data.mp, data.maxMP, data.costRatio )
	end
	
	data =  BUG_REPORT.allBattleData[5] 
	
	local battleValue = string.split(data, "&&")
	 
	local playbattleRc	= {}
	local step = #battleValue
	for i = 1 , step  do	
		local t = json.decode(battleValue[i])
		for k, v in ipairs (t) do
			table.insert(playbattleRc,v)
		end	
	end	
	
	if( playbattleRc ~= nil)then
		battlePlayer.rePlayStatus = true
		BattleResultHandler(playbattleRc)
	end
	
	
	
end