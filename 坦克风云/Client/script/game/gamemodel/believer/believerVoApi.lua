believerVoApi={
	ver=nil, --believerVerCfg的version版本
	user=nil, --user数据
  serverhost=nil, --服务器域名，用于请求战报和记录等相关
  exchangeRecordList=nil, --兑换部队的记录
  battleReportList=nil, --战斗报告列表

  --排行榜 --战斗榜需求
  battleNumsRankTb = {},--战斗场次 数据
  dmgRateRankTb    = {},--平均战损率 数据
  --段位榜需求
  masterSegTb      = {},--大师段位
  legendSegTb      = {},--传奇段位
  autoBattleFlag=false, --自动匹配5次的标识，（重启游戏后重置，所以只需存在内存里即可）
  superManTb       = {},--名人堂 数据
  battleType=37, --狂热集结的部队类型
  gives=nil --赠送的部队
}

function believerVoApi:clear()
	self.ver=nil
	self.user=nil
  self.serverhost=nil
  self.exchangeRecordList=nil
  self.battleReportList=nil
  self.battleNumsRankTb = {}
  self.dmgRateRankTb    = {}
  self.masterSegTb      = {}
  self.legendSegTb      = {}
  self.superManTb       = {}
  self.getRankTimeIn    = {}
  self.autoBattleFlag=false
  self.battleType=37
  self.gives=nil
end

function believerVoApi:getBelieverCfg()
	local believerCfg=G_requireLua("config/gameconfig/believer/believerCfg")
  return believerCfg
end

function believerVoApi:getBelieverVerCfg()
  -- print("self.ver-----???",self.ver)
  local believerVerCfg=G_requireLua("config/gameconfig/believer/"..string.format("believerCfgVer%d",(self.ver or 1)))
  return believerVerCfg
end

function believerVoApi:isOpen()
	if base.bRace==1 then
		local playerLv=playerVoApi:getPlayerLevel()
		local believerCfg=self:getBelieverCfg()
		if playerLv>=believerCfg.levelLimit then
			return 1,believerCfg.levelLimit
		else
			return 3,believerCfg.levelLimit
		end
	else
		return 2
	end
end

function believerVoApi:getBelieverOpenLv()
  local believerCfg=self:getBelieverCfg()
  return believerCfg.levelLimit
end

function believerVoApi:getBattleType()
  return self.battleType
end

function believerVoApi:initData(data)
	if data==nil then
		do return end
	end
	if self.user==nil then
		self.user={day={},match={},troops={}} --day：每日数据，需要跨天清空,match: 匹配信息,troops：部队池
	end
  if data.entry then --报名标识
  	self.user.entry=data.entry
  end
  if data.score then --积分
  	self.user.score=data.score
  end
 	if data.kcoin then --k币数量
 		self.user.kcoin=data.kcoin
 	end
 	if data.fight then --标准战力
 		self.user.fight=data.fight
 	end
 	if data.max_grade then --最高大段位
 		self.user.max_grade=data.max_grade
 	end
 	if data.max_queue then --最高小段位
 		self.user.max_queue=data.max_queue
 	end
  if data.grade then --当前大段位
    self.user.grade=data.grade
    if self.user.max_grade==nil or self.user.max_grade<self.user.grade then
      self.user.max_grade=self.user.grade
    end
  end
  if data.queue then --当前小段位
    self.user.queue=data.queue
    if self.user.max_queue==nil then
      self.user.max_queue=self.user.queue
    end
  end
 	if data.max_ranking then --最高排名
 		self.user.max_ranking=data.max_ranking
 	end
 	if data.max_dmg_rate then --最高战损率(整数部分)
 		self.user.max_dmg_rate=data.max_dmg_rate
 	end
 	if data.best_kill_rate then --最佳击杀率
 		self.user.best_kill_rate=data.best_kill_rate
 	end
 	if data.troops_give then --部队赠送标识
 		self.user.troops_give=data.troops_give
 	end
 	if data.total_change then --部队总兑换次数
 		self.user.total_exchange=data.total_change
 	end
 	if data.total_killed then --总击杀数
 		self.user.total_killed=data.total_killed
 	end
 	if data.total_battle_num then --当前赛季总战斗次数
    self.user.total_battle_num=data.total_battle_num
  end
  if data.grade_battle_num then --当前赛季最高段位战斗次数   (这个用来检测升级任务)
    self.user.grade_battle_num=data.grade_battle_num
  end
 	if data.image_flags then --镜像设置标识
 		self.user.image_flags=data.image_flags
 	end
  if data.grade_reward_flags then --段位晋级奖励领取标识
    self.user.grade_reward_flags=data.grade_reward_flags
  end
  if data.season_reward_flags then --赛季领取奖励的标识
    self.user.season_reward_flags=data.season_reward_flags
  end
  if data.grade_task then --已经完成任务的最高段位值
    self.user.grade_task=data.grade_task
  end
  if data.match_info then
    self:setMatchInfo(data)
  end
 	if data.troops then --可用兵池信息
 		self:setTroopsPool(data.troops)
 	end
  local day=self.user.day
 	if data.day_change then --当日部队兑换次数
 		day.day_exchange=data.day_change
 	end
 	if data.day_killed then --当日击杀数
 		day.day_killed=data.day_killed
 	end
 	if data.day_match_num then --重置匹配次数
 		day.day_match_num=data.day_match_num
 	end
 	if data.day_wins then --当日胜利次数
 		day.day_wins=data.day_wins
 	end
 	if data.day_battle_num then --当日战斗次数
 		day.day_battle_num=data.day_battle_num
 	end
 	if data.day_max_continue_wins then --当日最大连胜次数
 		day.day_max_continue_wins=data.day_max_continue_wins
 	end
 	if data.day_continue_wins then --当时连胜次数(失败会被清掉)
 		day.day_continue_wins=data.day_continue_wins
 	end
 	if data.day_troops_give then --每日部队赠送
 		day.day_troops_give=data.day_troops_give
 	end
  if data.day_grade then --每日零点结算的大段位，用于判断每日任务
    day.day_grade=data.day_grade
  end
 	if data.day_at then --当日时间戳,以此为依据跨天清数据
 		self.user.day_at=data.day_at
 	end
  if data.day_thumbs_flags then --点赞标识，跨天清除
    day.day_thumbs_flags = data.day_thumbs_flags
  end
  if data.switch then --自动补兵设置开关 1=开 0=关
    day.switch=data.switch
  end
  if data.day_reward_flags then --每日任务奖励领取标识
    day.day_reward_flags=data.day_reward_flags
  end
  if data.ave_dmg_rate then-- 平均生存率(整数部分)
    self.user.ave_dmg_rate = data.ave_dmg_rate
  end
  if data.shop then--玩家当前商店兑换信息
    self.user.curShopUseTb = data.shop
  end
  self.user.day=day
end

--用于跨天清除日常数据
function believerVoApi:clearDailyData()
  if self.user then
    self.user.day={}
  end
end

--清空赠送部队
function believerVoApi:clearTroopsGives()
  self.gives=nil
end

--获取赠送部队信息
function believerVoApi:getTroopsGives()
  return self.gives
end
----------------------排行榜 相关api----------------------
function believerVoApi:getBattleTotalNumsAndDmgRate( )--获取玩家当前赛季战斗总场次和平均战损率
    return self.user.total_battle_num or 0,self.user.ave_dmg_rate or 0
end

function believerVoApi:socketRankInfo(rankType,callback)--请求排行榜数据
    if not self.getRankTimeIn then
        self.getRankTimeIn = {}
    end
    if not self.getRankTimeIn[rankType] then
        self.getRankTimeIn[rankType] = 0--base.serverTime
    end
    if self.getRankTimeIn[rankType] > 0 and base.serverTime < (self.getRankTimeIn[rankType] + 300) then--需要用时间戳去判断是否需要从拉排行，暂定300秒的时长判断
          if callback then
              callback()
          end
    else
        if self.serverhost==nil then
          do return end
        end
        self.getRankTimeIn[rankType] = base.serverTime
        local maxGrade,maxQueue,rankStrType = 1,1,""
        if rankType == 1 then
          local seasonReward=self:getBelieverCfg()["seasonReward"]
          maxGrade = SizeOfTable(seasonReward) -1 
          maxQueue = SizeOfTable(seasonReward[maxGrade])
          rankStrType ="grade"
        elseif rankType == 2 then
          rankStrType ="tolnum"
        elseif rankType == 3 then
          rankStrType ="dmgrate"
        elseif rankType == 4 then
          local seasonReward=self:getBelieverCfg()["seasonReward"]
          maxGrade = SizeOfTable(seasonReward)
          rankStrType ="grade"
        end
        local httpUrl=believerVoApi:getHttpPrefixUrl().."ranking/"..rankStrType
        local reqStr="uid="..playerVoApi:getUid().."&zoneid="..base.curZoneID.."&season="..self:getSeason().."&grade="..maxGrade.."&queue="..maxQueue.."&start="..self.seasonSt
        -- print("httpUrl",httpUrl.."?"..reqStr)
        local retStr=G_sendHttpRequestPost(httpUrl,reqStr)
        if(retStr~="")then
            local retData=G_Json.decode(retStr)
            -- G_dayin(retData)
            if retData and retData.ret==0 then
                  ------------处理排行榜信息
                if retData.data then
                    if retData.data.ranking then
                        if rankType == 1 then
                            self.masterSegTb = retData.data.ranking--大师
                        elseif rankType == 2 then
                            self.battleNumsRankTb = retData.data.ranking--战斗场次
                        elseif rankType == 3 then
                            self.dmgRateRankTb = retData.data.ranking--平均战损率
                        elseif rankType == 4 then
                            self.legendSegTb = retData.data.ranking--传奇
                        end
                    end
                end
                if callback then
                  callback()
                end
            end
        end
    end
end
---------段位榜--------
function believerVoApi:getMasterSegTb( )--大师
    local sortSegTb,useNum = {},SizeOfTable(self.masterSegTb)
    local useIdx = 1
    for i=useNum,1,-1 do
          sortSegTb[tostring(useIdx)] = self.masterSegTb[tostring(i)]
          useIdx = useIdx + 1
    end
    return SizeOfTable(sortSegTb),sortSegTb
end
function believerVoApi:getLegendSegTb( )--传奇
    --排行 -- 头像 -- 头像框 --段位 --
    local formatTb = {}
    for i=1,SizeOfTable(self.legendSegTb) do
        formatTb[i]    = {}
        formatTb[i][1] = self.legendSegTb[i][3]
        formatTb[i][2] = self.legendSegTb[i][5]-- 头像
        formatTb[i][3] = self.legendSegTb[i][6]-- 头像框
        formatTb[i][4] = getlocal("believer_seg_5")--段位
        formatTb[i][5] = GetServerNameByID(self.legendSegTb[i][4],true).."-"..self.legendSegTb[i][1]--名字
        formatTb[i][6] = getlocal("serverwar_point").."："..self.legendSegTb[i][2]
        formatTb[i][7] = getlocal("believer_dmgRate",{(self.legendSegTb[i][7]/10)}).."%"
        formatTb[i][8] = getlocal("believer_battleNumStr").."："..self.legendSegTb[i][8]
    end
    return SizeOfTable(formatTb),formatTb
end
---------战斗榜--------
function believerVoApi:getBattleRankDataWithBattleNums( )--战斗场次相关数据
    local formatTb = {}
    for i=1,SizeOfTable(self.battleNumsRankTb) do
        formatTb[i]    = {}
        formatTb[i][1] = self.battleNumsRankTb[i][3]
        formatTb[i][2] = GetServerNameByID(self.battleNumsRankTb[i][6],true).."-"..self.battleNumsRankTb[i][1]
        formatTb[i][3] = self:getSegmentName(tonumber(self.battleNumsRankTb[i][4]),tonumber(self.battleNumsRankTb[i][5]))--getlocal("believer_seg_"..self.battleNumsRankTb[i][4].."_"..self.battleNumsRankTb[i][5])
        formatTb[i][4] = self.battleNumsRankTb[i][2]
    end

    return SizeOfTable(formatTb),formatTb
end
function believerVoApi:getBattleRankDataWithDmgRateTb()--平均战损率相关数据
    local formatTb = {}
    for i=1,SizeOfTable(self.dmgRateRankTb) do
        formatTb[i]    = {}
        formatTb[i][1] = self.dmgRateRankTb[i][3]
        formatTb[i][2] = GetServerNameByID(self.dmgRateRankTb[i][6],true).."-"..self.dmgRateRankTb[i][1]
        formatTb[i][3] = self:getSegmentName(tonumber(self.dmgRateRankTb[i][4]),tonumber(self.dmgRateRankTb[i][5]))--getlocal("believer_seg_"...."_"..self.dmgRateRankTb[i][5])
        formatTb[i][4] = (self.dmgRateRankTb[i][2]/10).."%"
    end
    return SizeOfTable(formatTb),formatTb
end
----------------------商店  相关api----------------------
function believerVoApi:getCurKcoin()
    if self.user and self.user.kcoin then
      return tonumber(self.user.kcoin)
    end
    return 0 
end
function believerVoApi:getShopInfo( )--商店信息
    return self:getBelieverVerCfg()["raceShop"]
end
function believerVoApi:getCurShopUseInfo( )--商店使用信息
    if self.user and self.user.curShopUseTb then
      return self.user.curShopUseTb
    end
    return {}
end
function believerVoApi:returnFormatShopInfo()
    local oldShop = self:getShopInfo()
    local curUseTb,curKcoinNum = self:getCurShopUseInfo(),self:getCurKcoin()
    local curGrade,curQueue = self:getMySegment()
    local fNum = 1
    local formatShop,clockTb,kCoinLessTb,buyNumEndTb,canBuyTb = {},{},{},{},{}
    local newShopInfo = {}
    for i=1,SizeOfTable(oldShop) do
          local useSubTb = curUseTb and curUseTb[tostring(i)] or {}
          for ii=1,SizeOfTable(oldShop[i]) do
              local mm = "i"..ii
              local nn = oldShop[i][mm]
          -- for mm,nn in pairs(oldShop[i]) do              
              formatShop[fNum] = nn
              formatShop[fNum][6] = i -- 大段位限制 在第6个位置
              formatShop[fNum][7] = useSubTb and useSubTb[mm] or 0 -- 当前购买的次数放在第7个位置
              formatShop[fNum][9] = mm--物品id 用于购买使用
              if formatShop[fNum][3] > 0 and formatShop[fNum][7] >= formatShop[fNum][3] then
                  formatShop[fNum][8] = 1
                  table.insert(buyNumEndTb,formatShop[fNum])
              elseif i > curGrade or (i == curGrade and nn[1] > curQueue) then
                formatShop[fNum][8] = 3----- 8号位 放当前商品的使用信息 -- 阶位不到：3  k币不足：2 购买次数到上限：1 可购买：0
                  table.insert(clockTb,formatShop[fNum])
              elseif curKcoinNum < nn[2] then
                  formatShop[fNum][8] = 2
                  table.insert(kCoinLessTb,formatShop[fNum])
              else
                formatShop[fNum][8] = 0
                  table.insert(canBuyTb,formatShop[fNum])
              end
              fNum = fNum + 1
          end
    end
    for k,v in pairs(canBuyTb) do
        table.insert(newShopInfo,v)
    end
    for k,v in pairs(kCoinLessTb) do
        table.insert(newShopInfo,v)
    end
    for k,v in pairs(clockTb) do
        table.insert(newShopInfo,v)
    end
    for k,v in pairs(buyNumEndTb) do
        table.insert(newShopInfo,v)
    end
    return newShopInfo
end
function believerVoApi:buyPropInShop(callback,itemIdx,itemGrade,itemSeg)
  local function dataHandler(fn,data)
      local ret,sData=base:checkServerData(data)
      if ret==true then
          if sData.data then
              if sData.data.userbeliever then --如果有user数据，说明已经报过名了
                self:initData(sData.data.userbeliever)
              end
              if sData.data.believerserverhost then
                self.serverhost=sData.data.believerserverhost
              end
              smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("vip_tequanlibao_goumai_success"),30)
              if callback then
                  callback()
              end
          end
      end
  end
  socketHelper:believerbuyPropInShop(dataHandler,itemGrade,itemSeg)
end

----------------------名人堂  相关api----------------------
function believerVoApi:superManHttpPost(callback)
    if self.serverhost==nil then
      do return end
    end
    if not self.superManPostTime then
        self.superManPostTime = base.serverTime
    elseif self.superManPostTime + 600 > base.serverTime and (self.superManTb and SizeOfTable(self.superManTb) > 0) then
        if callback then
          callback()
        end
        do return end
    end
    self.superManPostTime = base.serverTime
    local httpUrl=believerVoApi:getHttpPrefixUrl().."ranking/hallofame"
    reqStr = ""
    local retStr=G_sendHttpRequestPost(httpUrl,reqStr)
    if(retStr~="")then
        local retData=G_Json.decode(retStr)
        -- G_dayin(retData)
        if retData and retData.ret==0 then
              ------------接收名人堂数据
            if retData.data then
                self.superManTb = retData.data
            end
            if callback then
                callback()
            end
        end
    end
end
function believerVoApi:getSuperManTbData()
    local useNum,useTb = SizeOfTable(self.superManTb),G_clone(self.superManTb)
    return useNum,useTb
end
function believerVoApi:initSuperManDia(layerNum,parent)
    local believerSuperManDialog=G_requireLua("game/scene/gamedialog/believer/believerSuperManDialog")
    local td=believerSuperManDialog:new(parent)
    local tbArr={}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),tbArr,nil,nil,getlocal("hallOfFame"),true,layerNum)
    sceneGame:addChild(dialog,layerNum)
end
function believerVoApi:addIconBorder(parent,iconSp,size)
    if iconSp then
      local borderSp = CCSprite:createWithSpriteFrameName("believerKingBorder.png")
      if size then
        borderSp:setScale(size/borderSp:getContentSize().height)
      end
      borderSp:setPosition(ccp(iconSp:getPositionX(),iconSp:getPositionY()))
      parent:addChild(borderSp)
      return borderSp
    else
        print("error~~~~iconSp is not get=====>>>>",iconSp)
    end
    return nil
end

---点赞 获取标识
function believerVoApi:isThumpUp()
    if self.user and self.user.day then
      return self.user.day.day_thumbs_flags or 0
    end
    return 0 
end
function believerVoApi:socketThumpUp(callback,seasonIdx)
    local function dataHandler(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData.data then
                if sData.data.userbeliever then --如果有user数据，说明已经报过名了
                  self:initData(sData.data.userbeliever)
                end
                if sData.data.believerserverhost then
                  self.serverhost=sData.data.believerserverhost
                end
                if self.superManTb then
                    self.superManTb[1][9] = self.superManTb[1][9] + 1
                end
                if callback then
                    callback()
                end
            end
        end
    end
    socketHelper:socketThumpUp(dataHandler,seasonIdx)
end
--------------------------------------------------------
--设置匹配信息
function believerVoApi:setMatchInfo(matchinfo)
  if self.user then
    local match=self.user.match or {}
    if matchinfo.match_info and SizeOfTable(matchinfo.match_info)>0 then --匹配对手的数据
      local playerData=matchinfo.match_info
      match.player={}
      match.player.name=self:getEnemyNameStr(playerData[1]) --名字
      match.player.level=playerData[2] --等级
      match.player.pic=playerData[3]==-1 and self:getNpcHeadPic(playerData[1]) or playerData[3] --头像
      match.player.hfid=playerData[9] --不需要给默认值，在初始化头像框的地方有处理
      match.player.grade=playerData[4] --大段位
      match.player.queue=playerData[5] --小段位
      match.player.killRate=playerData[6] --击杀率
      match.player.fight=playerData[7] --战斗力
      match.player.troop=playerData[8] --部队
      match.player.zid=playerData[10] --对手所在服务器id，第11位是匹配的镜像id，后台用，前台不处理
      if playerData[12] then
        if playerData[12].skin then
          match.player.skin=playerData[12].skin --部队涂装数据
        end
      end
      if match.player.zid==nil or tonumber(match.player.zid)==0 then
        match.player.zid=base.curZoneID
      end
    end
    match.match_grade=matchinfo.match_grade or 1 --匹配的段位信息
    match.match_ocean=matchinfo.match_ocean or 1 --匹配到的地形
    match.match_weather=matchinfo.match_weather or 1 --匹配到的天气

    self.user.match=match
  end
end

--获取匹配到的数据（包括地形，天气等）
function believerVoApi:getMatchInfo()
  if self.user and self.user.match and self.user.match.player then
    return self.user.match
  end
  return nil
end

function believerVoApi:hasMatchPlayer()
  if self.user and self.user.match and self.user.match.player then
    return true,self.user.match
  end
  return false
end

--清空匹配信息
function believerVoApi:clearMathInfo()
  if self.user and self.user.match then
    self.user.match=nil
    self.user.match={}
  end
end

--设置部队池
function believerVoApi:setTroopsPool(troops)
  --当前拥有的舰队数组 k="a10005",v=数量
  self.user.troops={}

  local believerCfg=self:getBelieverCfg()
  local believerCfgVer=self:getBelieverVerCfg()
  local grade=self:getMySegment()

  local troopTb=G_clone(troops)
  --取配置，当前段位可用的兵池
  local canUseFleetCfg=believerCfgVer.troopPoolLimit[grade]
  local num,key
  for k,v in pairs(canUseFleetCfg) do
    if believerCfg.troopsMsg[v] and believerCfg.troopsMsg[v].servertroops then
      local troopsPool=believerCfg.troopsMsg[v].servertroops
      for k,tankId in pairs(troopsPool) do
        num=0
        if troopTb[tankId] then
          num=troopTb[tankId]
          troopTb[tankId]=nil
        end
        local id=tonumber(RemoveFirstChar(tankId))
        table.insert(self.user.troops,{id,num})
      end
    end
  end
  --可用的坦克先排序
  local function sortAsc(a,b)
      if a and b and a[1] and b[1] then
        local akey,bkey=a[1],b[1]
        if tankCfg[akey] and tankCfg[bkey] then
          return tankCfg[akey].sortId>tankCfg[bkey].sortId
        end
      end
      return false
  end
  table.sort(self.user.troops,sortAsc)
  --限制的船
  -- local lockTankTb={}
  -- --当前数组内只有兵池配置中的船，再加入玩家之前兑换剩余的船（此情况只有段位下降才会出现）
  -- for k,v in pairs(troopTb) do
  --   local vo={}
  --   key=tonumber(RemoveFirstChar(k))
  --   vo[1]=key --tankId
  --   vo[2]=v --数量
  --   vo[3]=true --虽然有，但是段位限制，不能使用
  --   table.insert(lockTankTb,vo)
  -- end
  -- --限制的坦克排序
  -- table.sort(lockTankTb,sortAsc)
  -- --限制的在后面
  -- for k,v in pairs(lockTankTb) do
  --   table.insert(self.user.troops,v)
  -- end
end

function believerVoApi:getTroopsPool()
  if self.user and self.user.troops then
    return self.user.troops
  end
  return {}
end

--获取可用的兵池数据（isTankSelectFormat:是否要格式化选择坦克页面所需要的数据格式）
function believerVoApi:getCanUseTroopPool(isTankSelectFormat)
  local fleetTb={}
  if self.user==nil or self.user.troops==nil then
    do return fleetTb end
  end
  --当前兵池
  local poolTb=G_clone(self.user.troops)
  --已经选择的坦克
  local selectFleetTb=tankVoApi:getTanksTbByType(self.battleType)
  for k,v in pairs(selectFleetTb) do
    for kk,vv in pairs(poolTb) do
      if v[1]==vv[1] then
        poolTb[kk][2]=poolTb[kk][2]-v[2]
        do break end
      end
    end
  end
  if isTankSelectFormat==true then
    fleetTb={{},{}}
  end
  -- 遍历兵池，筛掉段位限制状态的舰队
  for k,v in pairs(poolTb) do
    if v[3]~=true then --未限制
      if isTankSelectFormat==true then
        fleetTb[2][v[1]]={v[2]}
        table.insert(fleetTb[1],{key=v[1]})
      else
        table.insert(fleetTb,{v[1],v[2]})
      end
    end
  end
  return fleetTb
end

--检查阵型是否合法（包括坦克数量和坦克种类限制等）
function believerVoApi:checkTroopsIllegal(troopTb,isCheckNum)
  local illegalState=0
  local believerCfg=self:getBelieverCfg()
  local believerCfgVer=self:getBelieverVerCfg()
  local grade=self:getMySegment()
  local canUseFleetCfg=believerCfgVer.troopPoolLimit[grade]
  for k,v in pairs(troopTb) do
    if v[1] then
      local useFlag=false
      local tankId,tankNum=v[1],v[2]
      for kk,vv in pairs(canUseFleetCfg) do
        if tankCfg[tankId] and tankCfg[tankId].tankLevel==vv then
          useFlag=true
          do break end
        end
      end
      if useFlag==false then --部队种类限制
        illegalState=1
        do break end
      elseif tankNum<believerCfg.troopsNum and isCheckNum==true then --部队数量不够
        illegalState=2
        do break end
      end
    end
  end
  return illegalState
end

--获取npc镜像的头像
function believerVoApi:getNpcHeadPic(name)
  local firstStr=string.sub(name,1,4)
  if firstStr=="npc_" then
    local robId=string.sub(name,5,string.len(name))
    -- 个位
    local geWei=math.floor(robId%10)+1
    return 2000+geWei
  else
    return tonumber(name)
  end
end

--获取npc镜像名字
function believerVoApi:getEnemyNameStr(name)
  local firstStr=string.sub(name,1,4)
  if firstStr=="npc_" then
    return getlocal("believer_npc_name")
  else
    return name
  end
end

-- 获取段位名称
-- grade:大段位
-- queue:小段位用星星显示
function believerVoApi:getSegmentName(grade,queue)
  local nameStr=""
  if queue and queue>0 and grade~=1 and grade~=5 then
    nameStr=getlocal("believer_seg_"..grade.."_"..queue)
  else
    nameStr=getlocal("believer_seg_"..grade)
  end
  return nameStr
end

--初始化
function believerVoApi:believerInitRequest(callback)
	local function dataHandler(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data then
				if sData.data.userbeliever then --如果有user数据，说明已经报过名了
					self:initData(sData.data.userbeliever)
				end
        if sData.data.believerserverhost then
          self.serverhost=sData.data.believerserverhost
        end
        if callback then
          if sData.data.gives then --有赠送的部队
            self.gives=sData.data.gives
          end
          callback()
        end
			end
		end
	end
	socketHelper:believerInitRequest(dataHandler)
end

--报名
function believerVoApi:believerSign(callback)
	local function signCallBack(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
      self:believerInitRequest(callback) --报名完成后重新拉取一下数据
		end
	end
	socketHelper:believerSign(signCallBack)
end

--匹配
function believerVoApi:requestMatch(callback,costGems)
  local function requestCallBack(fn,data)
      local ret,sData=base:checkServerData(data)
      local flag=self:believerDataErrorHandler(sData.ret)
      if flag==true then
        do return end
      end
      if ret==true then
        if sData.data  and sData.data.userbeliever then
          self:initData(sData.data.userbeliever)
        end
        if costGems and costGems>0 then
          playerVoApi:setGems(playerVoApi:getGems()-costGems)
        end
        if callback then
          callback()
        end
      end
  end
  local grade=self:getMySegment()
  socketHelper:requestMatch(costGems,grade,requestCallBack)
end

--兑换坦克
function believerVoApi:believerExchange(list,callback)
  local function requestCallBack(fn,data)
      local ret,sData=base:checkServerData(data)
      if ret==true then
        if sData.data  and sData.data.userbeliever then
          self:initData(sData.data.userbeliever)
        end
        if callback then
          callback()
        end
      end
  end
  socketHelper:believerExchange(list,requestCallBack)
end

--获取当日已经兑换的次数
function believerVoApi:getDayExchangeNum()
  local dayExchangeNum=0
  if self.user and self.user.day and self.user.day.day_exchange then
    dayExchangeNum=self.user.day.day_exchange
  end
  return dayExchangeNum
end

--获取兑换坦克需要消耗的坦克数量
function believerVoApi:getTroopExchangeCostNum(idx)
  local believerCfg=believerVoApi:getBelieverCfg()
  --当前第几次,单次兑换时idx=1，一键兑换是idx=1~6
  local dayExchangeNum=believerVoApi:getDayExchangeNum()
  local exchangeNum=dayExchangeNum+idx
  local changeRateCfg=believerCfg.changeRate
  local rc=SizeOfTable(changeRateCfg)
  exchangeNum=math.ceil(exchangeNum/believerCfg.changeLimit)
  exchangeNum=exchangeNum<=rc and exchangeNum or rc
  --消耗数量
  local costNum=changeRateCfg[exchangeNum]
  if costNum==nil then
    costNum=changeRateCfg[rc]
  end
  return costNum
end

--挑战玩家
function believerVoApi:believerBattle(callback)
  local oldGrade,oldQueue=self:getMySegment()
  local oldScore,oldKcoin=(self.user.score or 0),(self.user.kcoin or 0)
  local function requestCallBack(fn,data)
      local ret,sData=base:checkServerData(data)
      local flag=self:believerDataErrorHandler(ret)
      if flag==true then
        do return end
      end
      if ret==true then
        if sData.data  and sData.data.userbeliever then
          self:initData(sData.data.userbeliever)
        end
        believerVoApi:clearMathInfo() --清空匹配信息
        sData.data.oldGrade=oldGrade
        sData.data.oldQueue=oldQueue
        sData.data.oldScore=oldScore
        sData.data.oldKcoin=oldKcoin
        eventDispatcher:dispatchEvent("believer.battle.prepared",{battle=sData.data})
      else
        eventDispatcher:dispatchEvent("believer.battle.error",{})
      end
  end
  local fleetTb=tankVoApi:getTanksTbByType(self.battleType)
  socketHelper:believerBattle(fleetTb,requestCallBack)
end

--进入战场
function believerVoApi:enterBattle(data)
  if data~=nil and data.report and SizeOfTable(data.report)>0 then
    local oldGrade=data.oldGrade or 1
    local oldQueue=data.oldQueue or 1
    local oldScore=data.oldScore or 0
    local oldKcoin=data.oldKcoin or 0
    local dataTb={}
    dataTb.data={}
    dataTb.data.report=data.report
    if dataTb.data.report and dataTb.data.report.p then
      if dataTb.data.report.p[1] and dataTb.data.report.p[1][1] then
        dataTb.data.report.p[1][1]=believerVoApi:getEnemyNameStr(dataTb.data.report.p[1][1]) --对手名字
      end
    end
    dataTb.battleType=self.battleType
    dataTb.believer={}
    local grade,queue=believerVoApi:getMySegment()
    --当前大段位
    dataTb.believer.grade=grade or 1
    --当前小段位
    dataTb.believer.queue=queue or 1
    --旧积分
    dataTb.believer.point=oldScore
    --添加的积分
    dataTb.believer.addPoint=(self.user.score or 0)-oldScore
    --添加的k币
    dataTb.believer.kcoin=(self.user.kcoin or 0)-oldKcoin
    --本次战斗的战损率--当前场战斗的战损率（整数部分）
    dataTb.believer.curDmgRate=data.dmgrate
    --战斗地形
    dataTb.landform={data.landform,data.landform} --敌我双方地形一致
    -- 平均战损率(整数部分)
    dataTb.believer.dmgRate=self.user.ave_dmg_rate or 0
    --每场战斗的战损率（整数部分）
    dataTb.believer.allDmgRate=self.user.all_dmg_rate or 0
    --播放战斗
    battleScene:initData(dataTb)
    --r等于1，则代表胜利
    if data.report and data.report.r and data.report.r==1 then
        --段位变化
        if grade~=oldGrade or (grade==oldGrade and queue~=oldQueue) then
          local givesTb=nil
          if data.gives then
            givesTb=data.gives
          end
          self:gradeChangeHandler(1,oldGrade,oldQueue,grade,queue,givesTb)
          self:saveLastGrade(grade,queue)
        else
          self:gradeChangeHandler(2)
        end
    else
      self:gradeChangeHandler(2)
    end
  end
end

--自动战斗
function believerVoApi:autoBattle(callback)
  local oldGrade,oldQueue=self:getMySegment()
  local function battleCallBack(fn,data)
    local ret,sData=base:checkServerData(data)
    local flag=self:believerDataErrorHandler(ret)
    if flag==true then
      do return end
    end
    if ret==true then
      if sData.data and sData.data.userbeliever then
        self:initData(sData.data.userbeliever)
      end
      if sData.data and sData.data.result then
        eventDispatcher:dispatchEvent("believer.battle.prepared",{result=sData.data.result})
        -- callback(sData.data.result)
      end
      local grade,queue=self:getMySegment()
      if grade~=oldGrade or oldQueue~=queue then
        local givesTb=nil
        if sData.data and sData.data.gives then
          givesTb=sData.data.gives
        end
        self:gradeChangeHandler(1,oldGrade,oldQueue,grade,queue,givesTb)
        self:saveLastGrade(grade,queue)
      else
        self:gradeChangeHandler(2)
      end
    else
      eventDispatcher:dispatchEvent("believer.battle.error",{})
    end
  end
  local grade=self:getMySegment()
  socketHelper:believerAutoBattle(grade,battleCallBack)
end

-- 段位变化逻辑处理
-- gives:赠送部队 不为空的时候才需要显示
function believerVoApi:gradeChangeHandler(cType,oldGrade,oldQueue,newGrade,newQueue,gives)
  -- print("gradeChangeHandler",oldGrade,oldQueue,newGrade,newQueue)
  --段位无变化
  if cType==1 and newGrade==oldGrade and newQueue==oldQueue then
    do return end
  end
  if cType==1 then --显示段位变化小面板
      --封装变化数据
      local changeData={}
      changeData.oldGrade=oldGrade
      changeData.oldQueue=oldQueue
      changeData.newGrade=newGrade
      changeData.newQueue=newQueue
      eventDispatcher:dispatchEvent("believer.main.refresh",{eType=cType,info=changeData,gives=gives})
  else --只刷新主页面数据
    eventDispatcher:dispatchEvent("believer.main.refresh",{eType=cType})
  end
end

--获取第几个阵型的坦克
function believerVoApi:getFormationByIndex(index,type)
    local tank={{},{},{},{},{},{}}
    local zoneId=base.curZoneID
    local uid=playerVoApi:getUid()
    local isSaved=false
    if index then
        local key="believer"..zoneId.."@"..uid.."@"..index
        local valueStr=CCUserDefault:sharedUserDefault():getStringForKey(key)
        if valueStr and valueStr~="" then
            if valueStr then
                if G_Json.decode(valueStr) then
                    tank=G_Json.decode(valueStr)
                    isSaved=true
                end
            end
        end
    end
    return isSaved,tank
end

--保存第几个阵型的坦克
function believerVoApi:saveFormationByIndex(index,tankTb)
    if index then
        local tank={{},{},{},{},{},{}}
        if tankTb and SizeOfTable(tankTb)>0 then
            tank=tankTb
        end
        local zoneId=base.curZoneID
        local uid=playerVoApi:getUid()
        local key="believer"..zoneId.."@"..uid.."@"..index
        local valueStr=G_Json.encode(tank)
        CCUserDefault:sharedUserDefault():setStringForKey(key,valueStr)
        CCUserDefault:sharedUserDefault():flush()
    end
end

--清空阵型
function believerVoApi:clearFormationByIndex(index)
    if index then
        local zoneId=base.curZoneID
        local uid=playerVoApi:getUid()
        local key="believer"..zoneId.."@"..uid.."@"..index
        local valueStr=""
        CCUserDefault:sharedUserDefault():setStringForKey(key,valueStr)
        CCUserDefault:sharedUserDefault():flush()
    end
end

--获取对手pos位置的坦克id
function believerVoApi:getMatchTankIdByIdx(pos)
  local tankId=nil
  if self.user and self.user.match and self.user.match.player and self.user.match.player.troop then
    tankId=self.user.match.player.troop[pos]
    if tankId then
      tankId=tonumber(RemoveFirstChar(tankId))
    end
  end
  return tankId
end

--获取推荐克制坦克
function believerVoApi:getRecommendTank(posIdx,troopTb)
  local tankId=self:getMatchTankIdByIdx(posIdx) --对手坦克id
  if tankCfg[tankId]==nil then
    do return end
  end
  local level=tankCfg[tankId].tankLevel
  local buffType=tonumber(tankCfg[tankId].buffType) --该坦克的buff类型
  --克制此坦克的type数组
  local goodTankIdTb={}
  if buffType then
    --遍历克制关系配置，查找所有克制他的坦克
    for k,v in pairs(relativeCfg.attack) do
      if v[buffType]>0 then
        goodTankIdTb[k]=true
      end
    end
  end
  local buffType=nil
  local tankLv=nil
  -- 遍历兵池，记录推荐
  for k,v in pairs(troopTb) do
    local tankId=v[1]
    if tankId and tankCfg[tankId] then
      buffType=tonumber(tankCfg[tankId].buffType)
      tankLv=tonumber(tankCfg[tankId].tankLevel)
      --既克制，也需要级别高
      if goodTankIdTb[tonumber(buffType)]==true and tankLv and level and tankLv>=level then
        troopTb[k][3]=true
      end
    end
  end
end

--是否自动补兵
function believerVoApi:checkAutoExchange()
  local switch=false
  if self.user and self.user.day then
    switch=(self.user.day.switch==1 and true or false)
  end
  return switch
end

--设置自动补兵
function believerVoApi:requestAutoExchange(switch,callback)
  local function requestCallBack(fn,data)
      local ret,sData=base:checkServerData(data)
      if ret==true then
        if self.user and self.user.day then
          self.user.day.switch=switch
        end
        if sData.data and sData.data.userbeliever then
          self:initData(sData.data.userbeliever)
        end
        if callback then
          callback()
        end
      end
  end
  socketHelper:believerAutoExchange(switch,requestCallBack)
end

--获取当前上阵部队的总战斗力
function believerVoApi:getTroopsFight()
  --当前上阵部队
  local troopTb=tankVoApi:getTanksTbByType(self.battleType)
  --战斗力
  local fight=0
  for k,v in pairs(troopTb) do
    if v[1] and v[2] and v[2]>0 then
      fight=fight+tonumber(tankCfg[v[1]].fighting)*math.pow(v[2],0.7)
    end
  end
  if math.floor(fight) then
    fight=math.floor(fight)
  end
  return fight
end

--获取本地存储的最近段位
function believerVoApi:getLastGrade()
  local retGrade,retQueue=0,0
  local dataKey="believerLastGrade@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
  local valueStr=CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
  if valueStr and valueStr~="" then
      if valueStr then
          valueStr=tonumber(valueStr)
          retGrade=math.floor(valueStr/10)
          retQueue=math.floor(valueStr%10)
      end
  end
  return retGrade,retQueue
end

--将最新段位存储到本地保存
function believerVoApi:saveLastGrade(grade,queue)
    local dataKey="believerLastGrade@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
    local valueStr=grade*10+queue
    CCUserDefault:sharedUserDefault():setStringForKey(dataKey,valueStr)
    CCUserDefault:sharedUserDefault():flush()
end

--设置初始化是否检查段位降低
function believerVoApi:setCheckGradeLessFlag(flag)
  self.checkGradeLessFlag=flag
end

function believerVoApi:checkSegmentChanged()
  local grade,queue=self:getMySegment()
  --是否有最近段位
  local lastGrade,lastQueue=self:getLastGrade()
  if lastGrade>0 and lastQueue>0 then
    --段位降低
    if (lastGrade>grade) or (lastGrade==grade and lastQueue>queue) then
      self:gradeChangeHandler(1,lastGrade,lastQueue,grade,queue)
    end
  end
  self:saveLastGrade(grade,queue)
end

--获取玩家当前的段位（包括大段位和小段位）
function believerVoApi:getMySegment()
  local grade,queue=1,1
  if self.user then
    grade=self.user.grade --大段位
    queue=self.user.queue --小段位
  end
  return grade,queue
end

--根据传的段位获取下一个段位
function believerVoApi:getNextSegment(grade,queue)
  local nextSeg,nextSmallSeg=1,1
  if grade==1 then
    nextSeg=grade+1
    nextSmallSeg=1
  elseif grade<=4 then
    if queue<3 then
      nextSeg=grade
      nextSmallSeg=queue+1
    else
      nextSeg=grade+1
      nextSmallSeg=1
    end
  else
    nextSeg,nextSmallSeg=5,1
  end
  return nextSeg,nextSmallSeg
end

--(当前段位新增的Tank)
function believerVoApi:getActiveTankBySegment(seg)
  if seg==nil then
    seg=believerVoApi:getSegment()
  end

  local showTankTb={}
  local believerCfg=self:getBelieverCfg()
  local believerCfgVer=self:getBelieverVerCfg()
  local troopLimit=believerCfgVer.troopPoolLimit[seg]
  if troopLimit==nil then
    do return showTankTb end
  end
  for k,v in pairs(troopLimit) do
    local troops=(believerCfg.troopsMsg[v]==nil) and {} or believerCfg.troopsMsg[v].servertroops --可用的坦克
    for kk,tankId in pairs(troops) do
      local id=tonumber(tankId) or tonumber(RemoveFirstChar(tankId))
      table.insert(showTankTb,{key=id,sortId=tonumber(tankCfg[id].sortId)})
    end
  end

  local function sortFunc(a,b)
    local weight1=a.sortId or 0
    local weight2=b.sortId or 0
    return weight1>weight2
  end
  table.sort(showTankTb,sortFunc)
  
  return showTankTb
end

--获取自己的数据
function believerVoApi:getMyUser()
  return self.user
end

--获取重置匹配次数的金币消耗
function believerVoApi:getResetMatchCost()
  local costGems
  if self.user and self.user.day and self.user.day.day_match_num then
    local believerCfg=self:getBelieverCfg()
    local resetNum=self.user.day.day_match_num --已经重置的次数
    if resetNum>=believerCfg.matchRule[2] then --如果大于免费次数，则计算花费
        resetNum=resetNum-believerCfg.matchRule[2]+1
        costGems=believerCfg.matchRule[3]+(resetNum-1)*believerCfg.matchRule[4]
        if costGems>believerCfg.matchRule[5] then --价格上限
            costGems=believerCfg.matchRule[5]
        end
    end
  end
  return costGems
end

-- 初始化赛季时间数据
function believerVoApi:initSeasonTimeData(data)
  if data then
    self.startTime=data.st --系统开始时间（用于计算赛季）
    self.endTime=data.et --系统结束时间
    self.seasonOffset=data.offset --赛季偏移
    self.ver=data.cfg --配置的version
  end
end

-- 计算赛季与赛季起始时间
function believerVoApi:computeSeason()
    local season=0
    local seasonSt=0  
    local seasonEt=0
    local ts=base.serverTime -- 当前服务器时间

    local believerCfg=self:getBelieverCfg()
    -- 起始时间开始需要有一个等于休赛期的等待时间
    local st=self.startTime+believerCfg.offSeason*3600*24
    -- 赛季持续时间    
    local sTime=(believerCfg.season+believerCfg.offSeason)*3600*24
    -- 休赛期持续时间
    local offTime=believerCfg.offSeason*3600*24
    -- 时差
    local tdif=ts-st
    -- 循环计算
    while(true) do
        if tdif>0 then
            season=math.floor(tdif/sTime)+1
            if season+self.seasonOffset>0 then
                seasonSt=st+(season-1)*sTime
                seasonEt=seasonSt+sTime-1
            end
        end

        if seasonSt>0 then 
        	do break end
        end
        tdif=tdif+offTime
    end
    -- 实际赛季数需要处理赛季的偏移值
    season=season+self.seasonOffset
    if season<0 then 
        season=0
    end
    self.season=season -- 第几赛季
    self.seasonSt=seasonSt -- 赛季开始时间
    self.seasonEt=seasonEt -- 赛季结束时间
end

--通过赛季开始时间计算当前状态
function believerVoApi:checkSeasonStatus()
  local believerCfg=self:getBelieverCfg()
  local status=0 --准备期
  local cdTime=0 --此状态倒计时
  local rt=base.serverTime-self.seasonSt
  if rt>0 then
	  --开战期 14天
    local battleTime=believerCfg.season*3600*24
    --休赛期 6.5天
    local offTime=(believerCfg.offSeason-0.5)*3600*24
    --数据清理期 0.5天
    local resetTime=0.5*3600*24
    if rt<battleTime then --战斗期
        status=1
        cdTime=battleTime-rt
    elseif rt<(battleTime+offTime) then --休赛期
        status=2
        cdTime=battleTime+offTime-rt
    elseif rt<(battleTime+offTime+resetTime) then --数据维护期
        status=3
        cdTime=battleTime+offTime+resetTime-rt
    end
  else
  	cdTime=0-rt
  end

  return status,cdTime
end

-- 是否显示狂热集结
function believerVoApi:isShowBeliever()
  if self.startTime<base.serverTime and self.endTime>base.serverTime then
    return true
  else
    return false
  end
end

--是否到达赛季开始时间
function believerVoApi:isReachSeasonSt()
  if self.seasonSt<base.serverTime then
    return true
  else
    return false,self.seasonSt
  end
end

function believerVoApi:getSeason()
	return self.season or 1
end

function believerVoApi:getSeasonTime()
  return self.seasonSt,self.seasonEt
end

function believerVoApi:getHttpPrefixUrl(islocal)
  if islocal and islocal==true then
    return "http://"..base.serverIp.."/tank-server/public/index.php/believer/"
  else
    return "http://"..self.serverhost.."/tank-server/public/index.php/believer/"
  end
end

--获取兑换记录
function believerVoApi:troopsExchangeRecordHttpRequest(callback)
  if self.serverhost==nil then
    do return end
  end
  local httpUrl=self:getHttpPrefixUrl(true).."report/changelist"
  local reqStr="uid="..playerVoApi:getUid().."&zoneid="..base.curZoneID.."&start="..self.seasonSt
  -- print("httpUrl",httpUrl.."?"..reqStr)
  local retStr=G_sendHttpRequestPost(httpUrl,reqStr)
  if(retStr~="")then
    local retData=G_Json.decode(retStr)
    -- G_dayin(retData)
    if retData and retData.ret==0 then
      self.exchangeRecordList=retData.data.list
      if callback then
        callback()
      end
    end
  end
end

function believerVoApi:getTroopsExchangeRecordList()
  return self.exchangeRecordList or {}
end

--获取战报列表
function believerVoApi:battleReportHttpRequest(callback)
  if self.serverhost==nil then
    do return end
  end
  local httpUrl=self:getHttpPrefixUrl(true).."report/battlelist"
  local reqStr="uid="..playerVoApi:getUid().."&zoneid="..base.curZoneID.."&start="..self.seasonSt
  -- print("httpUrl",httpUrl.."?"..reqStr)
  local retStr=G_sendHttpRequestPost(httpUrl,reqStr)
  if(retStr~="")then
    local retData=G_Json.decode(retStr)
    -- G_dayin(retData)
    if retData and retData.ret==0 then
      local believerBattleReportVo=G_requireLua("game/gamemodel/believer/believerBattleReportVo")
      self.battleReportList=nil
      self.battleReportList={}
      for k,v in pairs(retData.data.list) do
        local reportVo=believerBattleReportVo:new()
        reportVo:initWithData(v)
        table.insert(self.battleReportList,reportVo)
      end
      if callback then
        callback()
      end
    end
  end
end

--读取战报详情
function believerVoApi:readReportHttpRequest(id,callback,isRead)
  if self.serverhost==nil then
    do return end
  end
  local httpUrl=self:getHttpPrefixUrl(true).."report/battledetail"
  local reqStr="uid="..playerVoApi:getUid().."&zoneid="..base.curZoneID.."&id="..id.."&start="..self.seasonSt.."&isRead="..isRead
  -- print("httpUrl",httpUrl.."?"..reqStr)
  local retStr=G_sendHttpRequestPost(httpUrl,reqStr)
  if(retStr~="")then
    local retData=G_Json.decode(retStr)
    -- G_dayin(retData)
    if retData and retData.ret==0 then
      local reportVo=believerVoApi:getBattleReportById(id)
      reportVo:initWithData(nil,retData.data.detail)
      reportVo.isRead=1
      if callback then
        callback(reportVo)
      end
    end
  end
end

function believerVoApi:getBattleReportList()
  return self.battleReportList or {}
end

function believerVoApi:getBattleReportById(id)
  for k,v in pairs(self.battleReportList) do
    if v.id==id then
      return v
    end
  end
  return nil
end

--获取每日任务的进度
function believerVoApi:getDailyTaskByIdx(idx)
  local num=0
  if self.user==nil or self.user.day==nil then
    do return num end
  end
  if idx==1 or idx==4 or idx==5 then --战胜次数
    num=self.user.day.day_wins or 0
  elseif idx==2 then --战斗次数
    num=self.user.day.day_battle_num or 0
  elseif idx==3 then --击杀敌军数
    num=self.user.day.day_killed or 0
  end
  return num
end

--获取每日任务奖励领取标识
function believerVoApi:getDailyTaskRewardFlags()
  if self.user and self.user.day then
    return self.user.day.day_reward_flags or {}
  end
  return {}
end

--领取每日任务的奖励
function believerVoApi:getRewardRequest(action,args,callback)
  local function requestCallBack(fn,data)
      local ret,sData=base:checkServerData(data)
      if ret==true then
        if sData.data and sData.data.userbeliever then
          self:initData(sData.data.userbeliever)
        end
        if callback then
          callback()
        end
      end
  end
  if action==1 then
    socketHelper:getDailyTaskRewardRequest(args,requestCallBack)
  elseif action==2 then
    socketHelper:getSegRewardRequest(args.grade,args.queue,requestCallBack)
  elseif action==3 then
    socketHelper:getSeasonRewardRequest(args.grade,args.queue,requestCallBack)
  end
end

--获取段位奖励的完成和领取状态(flag=-1 未完成，flag=0 可领取，flag=1 已领取)
function believerVoApi:getSegmentRewardFlags(grade,queue)
  local flag=-1
  if self.user and self.user.grade_reward_flags then
    local rewardFlagTb=self.user.grade_reward_flags
    local gradeKey="g"..grade
    if rewardFlagTb[gradeKey] and rewardFlagTb[gradeKey][queue] and tonumber(rewardFlagTb[gradeKey][queue])==1 then
      flag=1
    else
      local maxGrade,maxQueue=(self.user.max_grade or 1) ,(self.user.max_queue or 1)
      if maxGrade>grade then
        flag=0
      elseif maxGrade==grade and maxQueue>=queue then
        flag=0
      end
    end
  end
  return flag
end

--获取段位奖励可以领取的最大小段位数
function believerVoApi:getMaxCanSegReward(grade)
  local queue=1
  if self.user and self.user.max_grade and self.user.max_queue then
    local maxGrade,maxQueue=(self.user.max_grade or 1),(self.user.max_queue or 1)  
    if grade==maxGrade then
      queue=maxQueue
    elseif grade>maxGrade then
      queue=0
    else
      local believerCfg=self:getBelieverCfg()
      queue=SizeOfTable(believerCfg.upReward[grade])
    end
  end
  return queue
end

--获取赛季奖励状态(flag：-1 不可领取，0：可领取，1：已领取)
function believerVoApi:getSeasonRewardFlag()
  local flag=-1
  local status=believerVoApi:checkSeasonStatus()
  if status==2 and (self.user.season_reward_flags==nil or self.user.season_reward_flags==0) then
    flag=0
  elseif status==2 and (self.user.season_reward_flags and self.user.season_reward_flags==1) then
    flag=1
  end
  return flag
end

--获取奖励可以领取的数量
function believerVoApi:getCanRewardByType(rtype)
  local canNum=0
  local believerCfg=self:getBelieverCfg()  
  if rtype==1 then --每日奖励
    local grade=self:getMySegment()
    local dailyTask=believerCfg.dailyTask[grade]
    local flags=believerVoApi:getDailyTaskRewardFlags()
    for k,v in pairs(dailyTask) do
      local num,needNum=believerVoApi:getDailyTaskByIdx(k),v[1]
      if (flags[k]==nil or tonumber(flags[k])==0) and num>=needNum then
        canNum=canNum+1
      end
    end
  elseif rtype==2 then --段位奖励
    for k,v in pairs(believerCfg.upReward) do
      local queue=SizeOfTable(v)
      for i=1,queue do
        local flag=believerVoApi:getSegmentRewardFlags(k,i)
        if flag==0 then
          canNum=canNum+1
        end
      end
    end
  elseif rtype==3 then --赛季奖励
    local flag=believerVoApi:getSeasonRewardFlag()
    if flag==0 then
      canNum=1
    end
  end
  return canNum
end

--获取段位图标
function believerVoApi:getSegmentIcon(grade,queue,iconSize,callback)
  local function touch(object,event,tag)
    if G_checkClickEnable()==false then
      do
        return
      end
    else
      base.setWaitTime=G_getCurDeviceMillTime()
    end
    if callback then
      callback(object,event,tag)
    end
  end
  local segIconSp=LuaCCSprite:createWithSpriteFrameName("believerSeg"..grade..".png",touch)
  if segIconSp then
    local scale=1
    if iconSize then
      scale=iconSize/segIconSp:getContentSize().width
    end
    segIconSp:setScale(scale) 
    if queue and queue>0 and grade~=1 and grade~=5 then
      local starWidth,space=30,5
      local starBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
      starBg:setContentSize(CCSizeMake(queue*starWidth+(queue-1)*space,starWidth))
      starBg:setPosition(segIconSp:getContentSize().width*0.5,25)
      starBg:setOpacity(0)
      starBg:setTag(101)
      segIconSp:addChild(starBg)

      for i=1,queue do
        local starSp=CCSprite:createWithSpriteFrameName("StarIcon.png")
        starSp:setScale(starWidth/starSp:getContentSize().width)
        starSp:setPosition((2*i-1)*0.5*starWidth+(i-1)*space,starWidth*0.5)
        starSp:setTag(10+i)
        starBg:addChild(starSp)
      end
    end
    return segIconSp,scale
  end
  return nil
end

--获取拼接的天气效果字符串
function believerVoApi:getWeatherStr(weatherId)
  local retStr=""
  local fontStr1="" --对象
  local fontStr2="" --属性
  local fontStr3="" --增加或减少
  local fontStr4="" --数值(百分比)
  local believerCfg=self:getBelieverCfg()
  local fleetNameMap={[1]=getlocal("tanke"),[2]=getlocal("jianjiche"),[4]=getlocal("zixinghuopao"),[8]=getlocal("huojianche"),[15]=getlocal("believer_all_fleet")}
  for k,v in pairs(believerCfg.weather) do
    if v.id==weatherId then
        fontStr1=fleetNameMap[v.effectType]
        fontStr2=getlocal(buffEffectCfg[v.attType].name)
        if v.attValue<0 then
            fontStr3=getlocal("believer_effect_less")
            fontStr4=((0-v.attValue)*100).."%%"
        else
            fontStr3=getlocal("arena_numAdd")
            fontStr4=(v.attValue*100).."%%"
        end
        retStr=getlocal("believer_match_weather_effect_"..v.id,{fontStr1,fontStr2,fontStr3,fontStr4})
      do break end
    end
  end
  return retStr
end

--根据天气来获取对应属性的icon
function believerVoApi:getWeatherAttType(weatherId)
  local believerCfg=self:getBelieverCfg()
  for k,v in pairs(believerCfg.weather) do
    if v.id==weatherId then
      local buffCfg=buffEffectCfg[v.attType]
      if buffCfg and buffCfg.icon then
        return buffCfg.icon
      end
    end
  end
  return nil
end

--设置自动匹配5次
function believerVoApi:setAutoBattleFlag(flag)
  self.autoBattleFlag=flag
end

function believerVoApi:getAutoBattleFlag()
  return self.autoBattleFlag
end

--判断当前部队是否满足自动匹配
function believerVoApi:isTroopsCanAutoBattle()
  local troops=self:getCanUseTroopPool()
  local num=0
  for k,v in pairs(troops) do
    local tankId,tankNum=v[1],v[2]
    num=num+math.floor(v[2]/200)
    if num>=6 then
      return true
    end
  end
  return false
end

--数据异常处理
function believerVoApi:believerDataErrorHandler(ret)
  if ret==-28108 or ret==-28109 then --系统数据异常，重新拉取系统数据
    local function errorHandler()
      eventDispatcher:dispatchEvent("believer.main.refresh",{eType=2})
    end
    self:believerInitRequest(errorHandler)
    return true
  end
  return false
end

function believerVoApi:showBelieverDialog(layerNum)
  local flag,openLv=self:isOpen()
  if flag==2 then
    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage9000"),30)
    do return end
  elseif flag~=1 then
    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("elite_challenge_unlock_level",{openLv}),30)
    do return end
  end

  local function showDialog()
    local believerDialog=G_requireLua("game/scene/gamedialog/believer/believerDialog")
    local td=believerDialog:new()
    local tbArr={}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),tbArr,nil,nil,getlocal("believer_title"),true,layerNum)
    sceneGame:addChild(dialog,layerNum)
  end
  self:believerInitRequest(showDialog)
end

---排行榜
function believerVoApi:showRankDialog(layerNum,parent)
    local function showRankDialogCall()
        local believerRankDialog=G_requireLua("game/scene/gamedialog/believer/believerRankDialog")
        local td=believerRankDialog:new(parent)
        local tbArr={getlocal("believer_rank_segmentStr"),getlocal("believer_rank_battleStr")}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),tbArr,nil,nil,getlocal("mainRank"),true,layerNum)
        sceneGame:addChild(dialog,layerNum)  
    end
    -- 假设段位榜type :1 ---------------------- 
    self:socketRankInfo(1,showRankDialogCall)
end

--商店
function believerVoApi:showShopDialog(layerNum,parent )
    local believerShopDialog=G_requireLua("game/scene/gamedialog/believer/believerShopDialog")
    local td=believerShopDialog:new(parent)
    local tbArr={}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),tbArr,nil,nil,getlocal("market"),true,layerNum)
    sceneGame:addChild(dialog,layerNum)
end

--展示匹配中页面
function believerVoApi:showMatchSmallDialog(layerNum,callback)
  local believerSmallDialog=G_requireLua("game/scene/gamedialog/believer/believerSmallDialog")
  believerSmallDialog:showMatchSmallDialog(layerNum,callback)
end

--展示已匹配玩家的信息
function believerVoApi:showMatchInfoDialog(layerNum,parent,isUseAnim,matchEffectFlag)
  local believerMatchPlayerDialog=G_requireLua("game/scene/gamedialog/believer/believerMatchPlayerDialog")
  local td=believerMatchPlayerDialog:new(parent,matchEffectFlag)
  local tbArr={}
  local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),tbArr,nil,nil,getlocal("believer_troop_look_marry"),true,layerNum,isUseAnim)
  sceneGame:addChild(dialog,layerNum)
end

--显示据点页面
function believerVoApi:showTankExchangeDialog(layerNum,parent)
  local believerTankExchangeDialog=G_requireLua("game/scene/gamedialog/believer/believerTankExchangeDialog")
  local td=believerTankExchangeDialog:new(parent)
  local tbArr={}
  local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),tbArr,nil,nil,getlocal("believer_exchange_place"),true,layerNum)
  sceneGame:addChild(dialog,layerNum)
end

--阵型页面
function believerVoApi:showTroopsFormationSmallDialog(troopType,layerNum,readCallBack)
  local believerSmallDialog=G_requireLua("game/scene/gamedialog/believer/believerSmallDialog")
  believerSmallDialog:showTroopsFormationSmallDialog(troopType,layerNum,readCallBack)
end

--选择坦克的面板
function believerVoApi:believerSelectTankSmallDialog(layerNum,callback,posIdx)
  local believerSmallDialog=G_requireLua("game/scene/gamedialog/believer/believerSelectTankSmallDialog")
  local td=believerSmallDialog:new()
  td:init(layerNum,callback,posIdx)
end

--兑换坦克的小面板
function believerVoApi:showTroopExchangeSmallDialog(exchangeList,exchangeRateTb,isShowRate,layerNum,confirmHandler,oneKeyState,oneKeyConfirmHandler,oneKeyCancelHandler)
  local believerTroopExchangeSmallDialog=G_requireLua("game/scene/gamedialog/believer/believerTroopExchangeSmallDialog")
  local td=believerTroopExchangeSmallDialog:new()
  td:init(exchangeList,exchangeRateTb,isShowRate,layerNum,confirmHandler,oneKeyState,oneKeyConfirmHandler,oneKeyCancelHandler)
end

--显示部队兑换记录
function believerVoApi:showTroopExchangeRecordDialog(layerNum)
  local believerExchangeTroopRecordDialog=G_requireLua("game/scene/gamedialog/believer/believerExchangeTroopRecordDialog")
  local td=believerExchangeTroopRecordDialog:new()
  local tbArr={}
  local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),tbArr,nil,nil,getlocal("believer_exchange_report"),true,layerNum)
  sceneGame:addChild(dialog,layerNum)
end

--显示奖励面板（每日奖励，晋级奖励，赛季奖励）
function believerVoApi:showRewardDialog(layerNum,parent)
  local believerRewardDialog=G_requireLua("game/scene/gamedialog/believer/believerRewardDialog")
  local td=believerRewardDialog:new(parent)
  local tbArr={getlocal("believer_reward_daily"),getlocal("believer_reward_grade"),getlocal("believer_reward_season")}
  local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),tbArr,nil,nil,getlocal("award"),true,layerNum)
  sceneGame:addChild(dialog,layerNum)
end

--显示段位介绍面板
function believerVoApi:showSegmentInfoDialog(layerNum,parent)
  local believerSegmentInfoDialog=G_requireLua("game/scene/gamedialog/believer/believerSegmentInfoDialog")
  local td=believerSegmentInfoDialog:new(parent)
  local tbArr={}
  local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),tbArr,nil,nil,getlocal("ltzdz_segment_introduce"),true,layerNum)
  sceneGame:addChild(dialog,layerNum)
end

--显示战报列表
function believerVoApi:showReportListDialog(layerNum,parent)
  local believerReportDialog=G_requireLua("game/scene/gamedialog/believer/believerReportDialog")
  local td=believerReportDialog:new(parent)
  local tbArr={}
  local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),tbArr,nil,nil,getlocal("arena_fightRecord"),true,layerNum)
  sceneGame:addChild(dialog,layerNum)
end

--显示战报详情
function believerVoApi:showReportDetailDialog(layerNum,reportVo,chatReport)
  local believerReportDetailDialog=G_requireLua("game/scene/gamedialog/believer/believerReportDetailDialog")
  local td=believerReportDetailDialog:new(reportVo,chatReport)
  local tbArr={}
  local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),tbArr,nil,nil,getlocal("fight_content_fight_title"),true,layerNum)
  sceneGame:addChild(dialog,layerNum)
end

--显示坦克克制关系
function believerVoApi:showTankKezhiSmallDialog(layerNum)
  local believerTankKezhiSmallDialog=G_requireLua("game/scene/gamedialog/believer/believerTankKezhiSmallDialog")
  local td=believerTankKezhiSmallDialog:new()
  td:init(layerNum)
end

--显示段位发生变化的面板
function believerVoApi:showGradeChangeSmallDialog(changeData,callBack,layerNum)
  local believerSegmentChangeSmallDialog=G_requireLua("game/scene/gamedialog/believer/believerSegmentChangeSmallDialog")
  local td=believerSegmentChangeSmallDialog:new()
  td:init(changeData,callBack,layerNum)
end

--赠送部队的面板
function believerVoApi:showReceiveTroopsDialog(gives,layerNum)
  local believerSmallDialog=G_requireLua("game/scene/gamedialog/believer/believerSmallDialog")
  believerSmallDialog:showReceiveTroopsDialog(CCSizeMake(550,630),gives,layerNum)
end

--显示自动匹配战斗结算面板
function believerVoApi:showAutoBattleResultDialog(result,layerNum,callback,parent)
  local believerAutoBattleResultSmallDialog=G_requireLua("game/scene/gamedialog/believer/believerAutoBattleResultSmallDialog")
  believerAutoBattleResultSmallDialog:showBattleResultDialog(result,layerNum,callback,parent)
end

--显示各个段位可以使用的部队
function believerVoApi:showActiveTankDialog(layerNum)
  local believerActiveTankDialog=G_requireLua("game/scene/gamedialog/believer/believerActiveTankDialog")
  believerActiveTankDialog:showActiveTankDialog(layerNum)
end

---boomboom特效
function believerVoApi:runBoomBoomFlower(layerNum,boomPos)
    -- print("runBoomBoomFlower~~~~!!!!!!!!@@@@@@@######$$$$$$$$$$$$")
    local dialogLayer=CCLayer:create()
    dialogLayer:setPosition(ccp(0,0))
    sceneGame:addChild(dialogLayer,layerNum)

    local starSp = CCSprite:createWithSpriteFrameName("believerZhakai1.png")
    -- starSp:setPosition(ccp(G_VisibleSizeWidth * 0.145,G_VisibleSizeHeight * 0.82))
    starSp:setPosition(boomPos)
    starSp:setVisible(false)
    dialogLayer:addChild(starSp)
     local boomArr=CCArray:create()
     for kk=1,11 do
          local nameStr="believerZhakai"..kk..".png"
          local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
          boomArr:addObject(frame)
     end
     local animation=CCAnimation:createWithSpriteFrames(boomArr)
     animation:setDelayPerUnit(0.05)
     local animate=CCAnimate:create(animation)
     local function endCall( )
        dialogLayer:removeFromParentAndCleanup(true)
     end
     local function showSelfCall()
       starSp:setVisible(true)
     end 
     local call1 = CCCallFuncN:create(showSelfCall)
     local call2 = CCCallFuncN:create(endCall)
     local arr = CCArray:create()
     -- local disTime = CCDelayTime:create(0.4)
     -- arr:addObject(disTime)
     arr:addObject(call1)
     arr:addObject(animate)
     arr:addObject(call2)
     local seq = CCSequence:create(arr)
     starSp:runAction(seq)
end

function believerVoApi:tick()
  --0点重置每日类数据
  if base.bRace==1 and self.user and self.user.day_at then
    local dayAt=self.user.day_at
    if dayAt and dayAt>0 then
      if G_isToday(dayAt)==false and self.user.day and self.user.day.switch~=nil then
        local function dayRefresh()
          eventDispatcher:dispatchEvent("believer.day.refresh",{}) --跨天数据刷新
        end
        self:believerInitRequest(dayRefresh)
        self:clearDailyData()
        self.user.day_at=base.serverTime+60
      end
    end
  end
end

function believerVoApi:showParticFunc(layerNum,jumpPos,callBack)
    local dialogLayer=CCLayer:create()
    dialogLayer:setPosition(ccp(0,0))
    sceneGame:addChild(dialogLayer,layerNum)

      local particleS2 = CCParticleSystemQuad:create("public/believer/battle_fail.plist")
      particleS2.positionType=kCCPositionTypeFree
      particleS2:setPosition(G_VisibleSizeWidth * 0.5 + 180,G_VisibleSizeHeight * 0.5)
      particleS2:setAutoRemoveOnFinish(true) -- 自动移除
      dialogLayer:addChild(particleS2,99)
      particleS2:setVisible(false)
      --1.85
      local posyS = G_isIphone5() and 0.8 or 0.65
      local endPosx = G_isIphone5() and 70 or 60
      local disTime = CCDelayTime:create(0.1)
      -- local JumpTo = CCJumpTo:create(0.5,ccp(endPosx,G_VisibleSizeHeight * posyS),120,1)
      local JumpTo = CCJumpTo:create(0.5,jumpPos,120,1)
      local function particCallShow()
          particleS2:setVisible(true)
      end
      local function particCall( )
          dialogLayer:removeFromParentAndCleanup(true)
          dialogLayer=nil
          if callBack then
            callBack()
          end
      end
      local particFunc1=CCCallFunc:create(particCallShow)
      local particFunc=CCCallFunc:create(particCall)
      local acArr=CCArray:create()

      acArr:addObject(disTime)
      acArr:addObject(particFunc1)
      acArr:addObject(JumpTo)
      acArr:addObject(particFunc)
      local seq = CCSequence:create(acArr)
      particleS2:runAction(seq)
end
function believerVoApi:showRandomStr(pSp)
    local xingRandomCfg={
      {ccp(16,42),ccp(92,59),ccp(56,55),ccp(35,87)},
      -- {ccp(124,22),ccp(67,56),ccp(187,92),ccp(127,152)},
      -- {ccp(129,153),ccp(187,90),ccp(70,58),ccp(126,23)},
      -- {ccp(128,148),ccp(188,81),ccp(67,58),ccp(127,18)},
      -- {ccp(128,143),ccp(184,94),ccp(69,64),ccp(127,11)},
      -- {ccp(185,83),ccp(67,57),ccp(127,139),ccp(127,16)},
    }
    local xingColorCfg={
      ccc3(255,255,255),
      ccc3(255,206,187),
      ccc3(222,255,193),
      ccc3(255,255,187),
      ccc3(255,255,255),
      ccc3(255,255,187),
    }
    local acArr=CCArray:create()
      local function playxingxing()
        local useIdx = math.random(1,SizeOfTable(xingRandomCfg))
        local cfg=G_clone(xingRandomCfg[useIdx])
        local timeCfg={0.3,0.6,1,1.5}
        for i=1,3 do
          local idx=math.random(1,SizeOfTable(cfg))
          local pos=cfg[idx]
          table.remove(cfg,idx)
          local dt=timeCfg[math.random(1,SizeOfTable(timeCfg))]
          local xingSp=CCSprite:createWithSpriteFrameName("segxing.png")
          xingSp:setPosition(pos.x,pSp:getContentSize().height-pos.y)
          xingSp:setColor(xingColorCfg[useIdx])
          xingSp:setScale(0)
          local blendFunc=ccBlendFunc:new()
          blendFunc.src=GL_ONE
          blendFunc.dst=GL_ONE_MINUS_SRC_COLOR
          xingSp:setBlendFunc(blendFunc)
          pSp:addChild(xingSp)

          local acArr=CCArray:create()
          local delayAc=CCDelayTime:create(dt)
          acArr:addObject(delayAc)

          local spawnArr1=CCArray:create()
          local rotateAC1=CCRotateBy:create(0.5,30)
          local scaleTo1=CCScaleTo:create(0.5,1)
          spawnArr1:addObject(rotateAC1)
          spawnArr1:addObject(scaleTo1)
          local spawnAc1=CCSpawn:create(spawnArr1)
          acArr:addObject(spawnAc1)

          local spawnArr2=CCArray:create()
          local rotateAC2=CCRotateBy:create(0.5,30)
          local scaleTo2=CCScaleTo:create(0.5,0)
          spawnArr2:addObject(rotateAC2)
          spawnArr2:addObject(scaleTo2)
          local spawnAc2=CCSpawn:create(spawnArr2)
          acArr:addObject(spawnAc2)

          local function removeSp()
            xingSp:removeFromParentAndCleanup(true)
          end
          local callFunc=CCCallFuncN:create(removeSp)
          acArr:addObject(callFunc)
          local seq=CCSequence:create(acArr)
          xingSp:runAction(seq)
        end
      end
      local callFunc=CCCallFuncN:create(playxingxing)
      acArr:addObject(callFunc)
      local delayAc=CCDelayTime:create(2.5)
      acArr:addObject(delayAc)
      local seq=CCSequence:create(acArr)
      pSp:runAction(CCRepeatForever:create(seq))
end

--显示进入战场的等待页面
function believerVoApi:showWaitingBattleDialog(layerNum,callback,parent)
  local believerSmallDialog=G_requireLua("game/scene/gamedialog/believer/believerSmallDialog")
  believerSmallDialog:showWaitingBattleLayer(layerNum,callback,parent)
end