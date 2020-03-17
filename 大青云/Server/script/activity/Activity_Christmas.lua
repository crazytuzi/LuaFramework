CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.MainHuman = nil
CurrentSceneScript.Scene = nil
-----------------------------------------------------------
CurrentSceneScript.ActivityClose = true

--圣诞怪朝向
CurrentSceneScript.Dir = 1.0

--怪物Id
CurrentSceneScript.christMonster = 705

--每波怪数量
CurrentSceneScript.christMonNum = 50

--圣诞怪刷新波数
CurrentSceneScript.christMonWaves = 0

--活动最大波数
CurrentSceneScript.nTotalWaves = 3

--当前圣诞活动时间
CurrentSceneScript.christMonTime = 30*60

--当前活动每波时间隔计数器
CurrentSceneScript.nCounter = 0

--每波刷怪间隔
CurrentSceneScript.spawnTime = 10*60

--怪物坐标
CurrentSceneScript.christMonsterPos ={
	{x=-353, y=498},
	{x=-766, y=496},
	{x=-732, y=503},
	{x=-790, y=438},
	{x=-776, y=406},
	{x=-735, y=362},
	{x=-671, y=409},
	{x=-674, y=465},
	{x=-685, y=505},
	{x=-745, y=448},
	{x=-637, y=423},
	{x=-573, y=414},
	{x=-576, y=453},
	{x=-531, y=448},
	{x=-534, y=414},
	{x=-498, y=413},
	{x=-489, y=444},
	{x=-456, y=445},
	{x=-446, y=409},
	{x=-404, y=445},
	{x=-385, y=401},
	{x=-378, y=352},
	{x=-390, y=514},
	{x=-380, y=480},
	{x=-346, y=510},
	{x=-312, y=511},
	{x=-273, y=504},
	{x=-271, y=431},
	{x=-350, y=422},
	{x=-222, y=375},
	{x=-283, y=353},
	{x=-215, y=441},
	{x=-236, y=478},
	{x=-209, y=513},
	{x=-309, y=451},
	{x=-340, y=345},
	{x=-165, y=432},
	{x=-110, y=438},
	{x=-70, y=461},
	{x=-59, y=405},
	{x=-37, y=466},
	{x=-7, y=486},
	{x=-12, y=522},
	{x=33, y=549},
	{x=-29, y=405},
	{x=-12, y=339},
	{x=32, y=324},
	{x=18, y=408},
	{x=31, y=337},
	{x=38, y=355},
	{x=11, y=452},
	{x=59, y=516},
	{x=96, y=545},
	{x=153, y=518},
	{x=206, y=475},
	{x=239, y=438},
	{x=168, y=315},
	{x=199, y=405},
	{x=116, y=332},
	{x=162, y=432},
	{x=192, y=519},
	{x=85, y=790},
	{x=49, y=787},
	{x=133, y=773},
	{x=139, y=718},
	{x=49, y=704},
	{x=95, y=729},
	{x=46, y=636},
	{x=134, y=641},
	{x=308, y=428},
	{x=350, y=428},
	{x=382, y=477},
	{x=404, y=516},
	{x=440, y=510},
	{x=391, y=368},
	{x=430, y=364},
	{x=505, y=352},
	{x=541, y=349},
	{x=562, y=417},
	{x=558, y=485},
	{x=514, y=506},
	{x=567, y=512},
	{x=483, y=428},
	{x=421, y=445},
	{x=481, y=288},
	{x=462, y=158},
	{x=472, y=221},
	{x=390, y=46},
	{x=340, y=86},
	{x=409, y=111},
	{x=298, y=-15},
	{x=208, y=-31},
	{x=297, y=30},
	{x=244, y=-11},
	{x=88, y=210},
	{x=98, y=137},
	{x=92, y=90},
	{x=-49, y=-23},
	{x=-112, y=-9},
	{x=-172, y=38},
	{x=-235, y=81},
	{x=-310, y=169},
	{x=-316, y=246},
	{x=67, y=-6},
	{x=72, y=-102},
	{x=4, y=-56},
	{x=101, y=-58},
	{x=53, y=26},
	{x=112, y=24},
	{x=155, y=-49},
	{x=52, y=-186},
	{x=98, y=-232},
	{x=62, y=-329},
	{x=101, y=-393},
	{x=165, y=-382},
	{x=144, y=-513},
	{x=25, y=-519},
	{x=11, y=-410},
	{x=131, y=-471},
	{x=38, y=-457},
	{x=79, y=-580},
	{x=69, y=-688},
	{x=-106, y=-752},
	{x=-153, y=-920},
	{x=-95, y=-952},
	{x=-147, y=-854},
	{x=-101, y=-867},
	{x=-38, y=-826},
	{x=-93, y=-817},
	{x=-2, y=-766},
	{x=-62, y=-781},
	{x=52, y=-834},
	{x=95, y=-843},
	{x=174, y=-857},
	{x=276, y=-928},
	{x=246, y=-930},
	{x=264, y=-819},
	{x=266, y=-764},
	{x=200, y=-775},
	{x=211, y=-825},
	{x=248, y=-877},
	{x=162, y=-809},
	{x=93, y=-774},
	{x=154, y=-752},
	{x=135, y=-714},
	{x=66, y=-744},
	{x=74, y=-823},
	{x=21, y=-740},
	{x=-86, y=-750},
	{x=-2, y=-494},
	{x=-98, y=-914},
	{x=481, y=458},
	{x=49, y=736},
	{x=78, y=760},
	{x=118, y=801},
	{x=70, y=811},
	{x=137, y=593},
	{x=57, y=556},
	{x=16, y=501},
	{x=156, y=360},
	{x=79, y=336},
	{x=-258, y=383},
	{x=-329, y=383},
	{x=-357, y=452},
	{x=-278, y=463},
	{x=-752, y=464},
	{x=-304, y=200},
	{x=-314, y=303},
	{x=-211, y=51},
	{x=43, y=-52},
	{x=100, y=-21},
	{x=375, y=63},
	{x=542, y=424},
	{x=489, y=386},
	{x=439, y=477},
	{x=118, y=-427},
	{x=90, y=-520},
	{x=40, y=-413},
	{x=-63, y=-877},
	{x=7, y=-803},
	{x=-52, y=-758},
	{x=226, y=-871},
	{x=276, y=-904},
	{x=235, y=-811},
	{x=238, y=-761},
	{x=180, y=-757},
	{x=148, y=-431},
	{x=47, y=-388},
	{x=77, y=-281},
	{x=98, y=-334},
	{x=82, y=-187},
	{x=104, y=-109},
	{x=-132, y=14},
	{x=-72, y=-10},
	{x=-275, y=159},
	{x=486, y=241},
	{x=432, y=162},
	{x=521, y=463},
	{x=12, y=-19},
	{x=36, y=-97},

}

---------------------------------------------------------
function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()

	_RegSceneEventHandler(SceneEvents.TimerExpired,"OnTimerExpired")
	_RegSceneEventHandler(SceneEvents.ActivityClose,"OnActivityClose")
	_RegSceneEventHandler(SceneEvents.ChristStart,"ChristStart")
end

function CurrentSceneScript:OnActivityClose()
	self.ActivityClose = true
end

function CurrentSceneScript:ChristMonsterTimer()
	-- body
	self.christMonWaves = 0
end

function CurrentSceneScript:Cleanup()
	
end

function CurrentSceneScript:OnTimerExpired(time) 
	if self.ActivityClose then return end
    
    if self.christMonWaves > self.nTotalWaves then
        return
    end
	--圣诞活动每隔10分钟刷一次雪怪
	self.nCounter = self.nCounter + 1

    if self.nCounter >= self.spawnTime then
    	self:ChristMonster()
    end
end

function CurrentSceneScript:ChristStart()
	-- body
	self:ChristMonster()
	self.ActivityClose = false
    
   self.SModScript:CreateTimer(self.christMonTime, "ChristMonsterTimer")
end

function CurrentSceneScript:ChristMonster()
	self.christMonWaves = self.christMonWaves + 1
    self.nCounter = 0
	-- body
	if self.christMonWaves > self.nTotalWaves then
	    return
	end

	for i=1,self.christMonNum do
		self:SpawnMonster()
	end

	_SendNotice(11640)
end

function CurrentSceneScript:SpawnMonster()
	-- body
	local len = #self.christMonsterPos
	local pos_index = math.random(1, len)

	if pos_index < 1 or pos_index > len then
	 	return
	 end
    
	local pos = self.christMonsterPos[pos_index]
	if pos ~= nil then
		local data = {}
        data[1] = self.christMonster
        data[2] = pos.x
        data[3] = pos.y

		self.SModScript:SpawnOlaf(data,self.Dir)
	end
end
