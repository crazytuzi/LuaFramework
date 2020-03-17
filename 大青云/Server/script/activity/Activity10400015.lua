CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.MainHuman = nil
CurrentSceneScript.Scene = nil
----------------------------------------------------------
CurrentSceneScript.BaseMap = 10411001  --第一层地图
CurrentSceneScript.MaxLevel = 5
CurrentSceneScript.BossID = {	--bossID
	10621201,
	10622201,
	10623201,
	10624201,
	10625201,
}

CurrentSceneScript.BossPos = {	--boss出生点
	{x=-934, y=225},
	{x=-731, y=-22},
	{x=-455, y=-490},
	{x=-579, y=396},
	{x=-344, y=-424},
}

CurrentSceneScript.BossSpawntime = {
	-- 只能是整点或者半点,按顺序
	{hh = 8, mm = 00},
	{hh = 8, mm = 30},
	{hh = 9, mm = 00},
	{hh = 9, mm = 30},
	{hh = 10, mm = 00},
	{hh = 10, mm = 30},
	{hh = 11, mm = 00},
	{hh = 11, mm = 30},
	{hh = 12, mm = 00},
	{hh = 12, mm = 30},
	{hh = 13, mm = 00},
	{hh = 13, mm = 30},
	{hh = 14, mm = 00},
	{hh = 14, mm = 30},
	{hh = 15, mm = 00},
	{hh = 15, mm = 30},
	{hh = 16, mm = 00},
	{hh = 16, mm = 30},
	{hh = 17, mm = 00},
	{hh = 17, mm = 30},
	{hh = 18, mm = 00},
	{hh = 18, mm = 30},
	{hh = 19, mm = 00},
	{hh = 19, mm = 30},
	{hh = 20, mm = 00},
	{hh = 20, mm = 30},
	{hh = 21, mm = 00},
	{hh = 21, mm = 30},
	{hh = 22, mm = 00},
	{hh = 22, mm = 30},
	{hh = 23, mm = 00},
	{hh = 23, mm = 30},
}

CurrentSceneScript.BossAlive = false
CurrentSceneScript.NextSpawnTime = {}
CurrentSceneScript.CurrLevel = 1

----------------------------------------------------------
--精英怪刷新间隔
CurrentSceneScript.nbMonSpawnTime = 5*60

--精英怪刷怪点记录
CurrentSceneScript.nbMonRecords = {}

--精英怪刷新范围
CurrentSceneScript.nbRadius = 0

--精英怪刷新
CurrentSceneScript.nbMonsterId = {	--精英怪Id
     [1] = {
		10621301,
		10621302,
		10621303,
		10621304,
		10621305,
		10621306,
		10621307,
		10621308,
		10621309,
		10621310,
		10621311,
		10621312,

	},
	[2] = {
		10622301,
		10622302,
		10622303,
		10622304,
		10622305,
		10622306,
		10622307,
		10622308,
		10622309,
		10622310,
		10622311,
		10622312,

	},
	[3] = {
		10623301,
		10623302,
		10623303,
		10623304,
		10623305,
		10623306,
		10623307,
		10623308,
		10623309,
		10623310,
		10623311,
		10623312,

	},
	[4] = {
		10624301,
		10624302,
		10624303,
		10624304,
		10624305,
		10624306,
		10624307,
		10624308,
		10624309,
		10624310,
		10624311,
		10624312,


	},
	[5] = {
	},
}

CurrentSceneScript.nbMonsterPos = {	--精英怪出生点
	[1] = {
		{x=-452, y=911},
	    {x=-656, y=405},
	    {x=103,  y=345},
	    {x=941,  y=-289},
	    {x=-76,  y=-480},
	    {x=-394, y=-949},
	    {x=-780, y=-432},
	    {x=740,  y=298},
		{x=-342,  y=-270},
	    {x=-659, y=968},
	    {x=144, y=-802},
	    {x=440,  y=766},
		{x=-843,  y=596},
	    {x=33, y=-226},
	    {x=-638, y=-199},
	    {x=372,  y=-185},
		{x=-381, y=740},
	    {x=-211, y=717},
	    {x=234,  y=415},
	    {x=647,  y=-176},
	    {x=941,  y=-8},
	    {x=-399, y=514},
	    {x=-947, y=397},
	    {x=-497,  y=-389},
		{x=158,  y=-460},
	    {x=314, y=61},
	    {x=875, y=-128},
	    {x=1008,  y=685},
		{x=392,  y=904},
	    {x=449, y=-991},
	    {x=-767, y=-795},
	    {x=39,  y=569},
	},
	[2] = {
		{x=250, y=443},
	    {x=-40, y=760},
	    {x=408,  y=169},
	    {x=238,  y=-16},
	    {x=712,  y=-302},
	    {x=400, y=-746},
	    {x=131, y=-567},
	    {x=326,  y=-444},
		{x=-382,  y=170},
	    {x=-658, y=428},
	    {x=-496, y=-436},
	    {x=-379,  y=-775},
		{x=-521,  y=-104},
	    {x=68, y=-759},
	    {x=-20, y=-132},
	    {x=-97,  y=193},
		{x=-337, y=715},
	    {x=246, y=672},
	    {x=710,  y=419},
	    {x=659,  y=163},
	    {x=486,  y=-65},
	    {x=726, y=-507},
	    {x=-228, y=15},
	    {x=-61,  y=-465},
		{x=-747,  y=308},
	    {x=-778, y=-356},
	    {x=-228, y=-279},
	    {x=-146,  y=-757},
		{x=-102,  y=469},
	    {x=441, y=449},
	    {x=211, y=237},
	    {x=749,  y=-31},
	},
	[3] = {
		{x=-459, y=506},
	    {x=-312, y=351},
	    {x=-68,  y=498},
	    {x=196,  y=616},
	    {x=292,  y=379},
	    {x=545, y=370},
	    {x=491, y=-99},
	    {x=235,  y=-192},
		{x=55,  y=-477},
	    {x=-76, y=-344},
	    {x=-466, y=-97},
	    {x=-231,  y=-485},
		{x=-494,  y=279},
	    {x=17,  y=344},
	    {x=-225,  y=208},
	    {x=281, y=232},
	    {x=-236, y=-70},
	    {x=-130,  y=-215},
		{x=-460,  y=-267},
	    {x=118, y=-43},
	    {x=417, y=-288},
	    {x=216,  y=-390},
		{x=397,  y=538},
		{x=63,  y=-205},
	},
	[4] = {
		{x=577, y=312},
	    {x=457, y=191},
	    {x=189,  y=355},
	    {x=-16,  y=580},
	    {x=-232,  y=606},
	    {x=-159, y=381},
	    {x=25, y=206},
	    {x=234,  y=165},
		{x=371,  y=-9},
	    {x=627, y=-186},
	    {x=369, y=-380},
	    {x=241,  y=-573},
		{x=-96,  y=-325},
	    {x=-174, y=73},
	    {x=-424, y=36},
	    {x=-512,  y=-188},
		{x=-385,  y=-521},
		{x=-143,  y=-541},
	    {x=-248, y=-86},
	    {x=10, y=-125},
	    {x=98,  y=-341},
		{x=-385,  y=-521},
		{x=656,  y=-414},
		{x=-331,  y=220},
	},
	[5] = {
	},
}
----------------------------------------------------------

function CurrentSceneScript:SpawnBoss()
	local pos = self.BossPos[self.CurrLevel]
	self.Scene:GetModSpawn():Spawn(self.BossID[self.CurrLevel], pos.x, pos.y, 0)
	self.BossAlive = true
end

function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	self.CurrLevel = self.Scene:GetBaseMapID() - self.BaseMap + 1
	if self.CurrLevel < 1 or self.CurrLevel > self.MaxLevel then self.CurrLevel = 1 end
	_RegSceneEventHandler(SceneEvents.SceneCreated,"OnSceneCreated")
	_RegSceneEventHandler(SceneEvents.SceneDestroy, "OnSceneDestroy")
	_RegSceneEventHandler(SceneEvents.HalfHourTimerExpired,"OnHalfHourTimerExpired")
	-- _RegSceneEventHandler(SceneEvents.TimerExpired,"OnTimerExpired")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnBossKilled", {param1=self.BossID[self.CurrLevel]})
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled")
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
end

function CurrentSceneScript:Cleanup() 
	
end

function CurrentSceneScript:OnSceneDestroy()
	self.nbMonRecords = {}
end

function CurrentSceneScript:OnHalfHourTimerExpired(mo,dd,hh,mm)  
	-- 每半小时触发一次 todo:
	for i,v in ipairs(self.BossSpawntime) do
		if hh == v.hh and mm == v.mm then 
			--if self.CurrLevel == 1 then 	
				--_SendNotice(10501)   -- 发送开启公告
			--end

			if self.BossAlive == false then
				self:SpawnBoss()
				self:SendDiffHangBossInfo()
			end
		end
	end
end

function CurrentSceneScript:OnSceneCreated()
	self:SpawnNbMonster()
	self:SpawnBoss()
end

function CurrentSceneScript:OnHumanEnter(human)
	self:SendDiffHangBossInfo(human:GetID())
end


function CurrentSceneScript:OnBossKilled(mon, killer)
	self.BossAlive = false
	--local tab = os.date("*t")
	--self:CalcBossSpawn(tab.hour, tab.min)
	self:SendDiffHangBossInfo()
end

function CurrentSceneScript:GetNextSpawnTime()
	-- body    
	local tab = os.date("*t")
	for i,v in ipairs(self.BossSpawntime) do
		if tab.hour < v.hh or (tab.hour == v.hh and tab.min < v.mm) then
			print("Next:", v.hh, v.mm)
			return v
		end
	end
	return self.BossSpawntime[1]
end

function CurrentSceneScript:SendDiffHangBossInfo(humanid)
	local data = {}
	data[1] = self.BossID[self.CurrLevel]
	if self.BossAlive == false then
		local tab = os.date("*t")

		local time = self:GetNextSpawnTime()
		if time.hh == nil or time.mm == nil then return end
		local sec = (0 - tab.sec) + (time.mm - tab.min)*60 + (time.hh - tab.hour)*60*60
		if sec < 0 then sec = sec + 24*60*60 end
		data[2] = sec
	else
		data[2] = -1
	end
	self.Scene:GetModScript():SendDiffHangBoss(data, humanid or 0)
end

-------------------------------nbmonster-----------------------------------
function CurrentSceneScript:SpawnNbMonster()
	-- body
	local len = #self.nbMonsterId[self.CurrLevel]
	for i=1,len do
		self:OnSpawnMonster()
	end
end

function CurrentSceneScript:OnMonsterKilled(monster,killer)
	-- body
	if monster:GetMonType() ~= 2 then
		return
	end
    
    local pos = monster:GetSpawnPos()
    self:ClearRecord(pos)
    self.SModScript:CreateTimer(self.nbMonSpawnTime, "SpawnNbMonsterTimer")
end

function CurrentSceneScript:SpawnNbMonsterTimer(tid)
	-- body
	self:OnSpawnMonster()
end

function CurrentSceneScript:OnSpawnMonster()
	-- body
	local level = self.CurrLevel
	local id_len  = #self.nbMonsterId[level]
    local pos_len = #self.nbMonsterPos[level]
    if id_len < 1 or pos_len < 1 then return end
    
    local freeMark = {}
    for i=1,pos_len do
    	if self:GetFreeMark(i) > 0 then
    		local data = {}
    		data.mark = i
    		table.insert(freeMark, data)
    	end
    end
    
    local id_index   = math.random(1, id_len)
    local monster_id = self.nbMonsterId[level][id_index]
    
    local len = #freeMark
    local pos_index = 0

    if len < 1 then
    	print("OnSpawnMonster len Err.",len)
    	return
    else
    	local index = math.random(1, len)
    	local data = freeMark[index]
    	if data ~= nil then
    		pos_index = data.mark
    	end
    end

    if pos_index < 1 or pos_index > pos_len then
    	print("OnSpawnMonster pos_index Err.",pos_index)
    	return
    end
    
    local pos = self.nbMonsterPos[level][pos_index]
	if pos ~= nil then
		self.Scene:GetModSpawn():SpawnBatch(monster_id, 1, pos.x, pos.y, self.nbRadius)

		local record = {}
		record.id   = monster_id
		record.mark = pos_index
		table.insert(self.nbMonRecords, record)
		--print("OnSpawnMonster pos:", level,pos_index)
	end
end

function CurrentSceneScript:GetFreeMark(index)
	for k,v in pairs(self.nbMonRecords) do
    	if v.mark == index then
    		return 0
    	end
    end

    return index
end

function CurrentSceneScript:ClearRecord(pos)
	if pos == nil then return end
	for i=#self.nbMonRecords,1,-1 do
		local records = self.nbMonRecords[i]
		if records ~= nil then
			local markdata = self.nbMonsterPos[self.CurrLevel][records.mark]
			if markdata ~= nil then
				if markdata.x == math.floor(pos[1]) and markdata.y == math.floor(pos[3]) then
				    table.remove(self.nbMonRecords,i)
				    --print("ClearRecord***********",i)
		        end
			end
		end
	end
end
