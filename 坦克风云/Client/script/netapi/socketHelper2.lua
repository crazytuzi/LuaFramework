socketHelper2={
    requestID=0,
    requestArr={},
    isSending=false,
    isConnected=false
}

--取消所有队列
function socketHelper2:cancleAllWaitQueue()
    for k,v in pairs(self.requestArr) do
        v=nil
    end
    self.requestArr=nil
    self.requestArr={}
    self.isSending=false
end

function socketHelper2:dispose()
    self.requestID=0
    for k,v in pairs(self.requestArr) do
        v=nil
    end
    self.requestArr={}
    self.isSending=false
    if SocketHandler2~=nil then
        SocketHandler2:shared():disConnect()
    end
end

function socketHelper2:receivedResponse(cmd,rnum)
    if self.requestArr[1]~=nil then
         if self.requestArr[1][3]==cmd and  (cmd=="user.login" or self.requestArr[1][5]==rnum) then
              self.requestArr[1]=nil
              local waitRequest={}
              for k,v in pairs(self.requestArr) do
                    if v~=nil then
                        table.insert(waitRequest,v)
                    end
              end
              self.requestArr=nil
              self.requestArr=waitRequest
              self.isSending=false
              self:realSendRequest()
         end
    end
end

--连接服务器
function socketHelper2:socketConnect(host,port,connectHandler)
    local function netHandler(...)
         base:netHandler2(...)
    end
    local function onConnect( ... )
        self.isConnected=true
        base:cancleNetWait()
        base:cancleWait()
        if(connectHandler)then
            connectHandler()
        end
    end
    base:setWait()
    if SocketHandler2~=nil then
        SocketHandler2:shared():registerCheckNetHandler(netHandler)
        SocketHandler2:shared():connectServer(host,port,onConnect) --连接服务器
    end
    
end

--添加数据请求队列
function socketHelper2:sendRequest(str,callback,cmd,isShowLoadingWhenNetErr)
    if isShowLoadingWhenNetErr==nil then
        isShowLoadingWhenNetErr=true
    end
    if isShowLoadingWhenNetErr==true then
        base:setWait()
    end
    local has=false
    for k,v in pairs(self.requestArr) do
        print("已经存在了吗？",cmd,v[3])
        if v~=nil and v[3]==cmd then
            has=true
        end
    end
    if has==false then
        table.insert(self.requestArr,{str,callback,cmd,isShowLoadingWhenNetErr,self.requestID})
    else
        do
            return
        end
    end
    if self.isSending==false and  #self.requestArr==1 then
        self.isSending=true
        self:realSendRequest()
    end
end
--真正发送请求
function socketHelper2:realSendRequest()
    if self.requestArr[1]~=nil then
        
        self.requestArr[1]["sendTime"]=G_getCurDeviceMillTime()
        local requestTb=G_Json.decode(tostring(self.requestArr[1][1]))
        requestTb["logints"]=base.logints
        requestTb["access_token"]=base.access_token
        local newStr=G_Json.encode(requestTb)
        if SocketHandler2~=nil then
            SocketHandler2:shared():sendRequest(newStr,self.requestArr[1][2],self.requestArr[1][3],self.requestArr[1][4])
        end
    end
end

function  socketHelper2:tick()
    if SocketHandler2~=nil then
        SocketHandler2:shared():getData()
    end
    
end

function socketHelper2:slowTick()
    if self.requestArr~=nil and self.requestArr[1]~=nil then
         if tonumber(self.requestArr[1]["sendTime"])~=nil then 
                if  (G_getCurDeviceMillTime()-tonumber(self.requestArr[1]["sendTime"]))>=12000 then
                     self:cancleAllWaitQueue()
                end
         end
    end
end


--添加公共参数
function socketHelper2:addBaseInfo(tb)
    self.requestID=self.requestID+1
    print("用户ID:==",playerVoApi:getUid())
    tb["uid"]=(playerVoApi:getUid()==nil and 0 or playerVoApi:getUid())
    tb["ts"]=base.serverTime
    tb["rnum"]=self.requestID
    tb["zoneid"]=base.curZoneID
    if newGuidMgr:isNewGuiding()==true and tb["cmd"]~="user.sync" then
        tb["tutorial"]=newGuidMgr:getTaskID()
    end
    tb["access_token"]=base.access_token
    tb["logints"]=base.logints
    tb["version"]=G_Version
    tb["client_ip"]=base.client_ip
    tb["pname"]=base.platusername
    tb["platid"]=(base.platformUserId==nil and G_getTankUserName() or base.platformUserId)
    if string.find(tb["platid"],"_")~=nil then
        tb["rplatid"]=Split(tb["platid"],"_")[2]
    end

    if platCfg.platFormNameFromClient~=nil then
        tb["bplat"]=platCfg.platFormNameFromClient[G_curPlatName()]
        if tb["bplat"]==nil then
            tb["bplat"]=G_curPlatName()
        end
    else
        tb["bplat"]=G_curPlatName()
    end
    if G_getPlatAppID()~=nil then
        tb["appid"]=G_getPlatAppID()
        
        if G_curPlatName()=="11" and tonumber(base.curZoneID)>3 and tonumber(base.curZoneID)<100 then --德国ios特殊处理
                tb["appid"]=10118
        end
    end
end

function socketHelper2:disConnect()
    self.isConnected=false
end

--跨服军团战初始化战场数据
function socketHelper2:serverWarTeamFightInit(bid,aid,roundID,battleID,callback,isShowLoading)
    local tb={}
    tb["cmd"]="acrossserver.get"
    tb["params"]={bid=bid,aid=aid,round=roundID,group=battleID}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("跨服军团战初始化战场数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end

--跨服军团战玩家移动
function socketHelper2:serverWarTeamMove(bid,aid,roundID,battleID,targetID,callback,isShowLoading)
    local tb={}
    tb["cmd"]="acrossserver.move"
    tb["params"]={bid=bid,aid=aid,round=roundID,group=battleID,target=targetID}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("跨服军团战移动",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end

--跨服军团战购买buff
function socketHelper2:serverWarTeamBuyBuff(bid,aid,roundID,battleID,buffID,callback,isShowLoading)
    local tb={}
    tb["cmd"]="acrossserver.buybuff"
    tb["params"]={bid=bid,aid=aid,round=roundID,group=battleID,buff=buffID}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("跨服军团战购买buff",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end

--跨服军团战加速
function socketHelper2:serverWarTeamAccelerate(bid,aid,roundID,battleID,callback,isShowLoading)
    local tb={}
    tb["cmd"]="acrossserver.speedup"
    tb["params"]={bid=bid,aid=aid,round=roundID,group=battleID}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("跨服军团战加速",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end

--跨服军团战复活
function socketHelper2:serverWarTeamRevive(bid,aid,roundID,battleID,callback,isShowLoading)
    local tb={}
    tb["cmd"]="acrossserver.revive"
    tb["params"]={bid=bid,aid=aid,round=roundID,group=battleID}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("跨服军团战复活",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end

--跨服军团战刷新比分
function socketHelper2:serverWarTeamGetPoints(bid,aid,roundID,battleID,callback,isShowLoading)
    local tb={}
    tb["cmd"]="acrossserver.getpoint"
    tb["params"]={bid=bid,aid=aid,round=roundID,group=battleID}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("跨服军团战刷新比分",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end

--群雄争霸初始化战场
--param aid: 军团的id
--param bid: 本次群雄争霸赛的id
--param group: 所在军团的分组
function socketHelper2:serverWarLocalInit(aid,bid,group,callback,isShowLoading)
    local tb={}
    tb["cmd"]="areateamwarserver.get"
    tb["params"]={aid=aid,bid=bid,group=group}
    if(isShowLoading)then
        tb["params"]["init"]=true
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("群雄争霸初始化战场",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end

--群雄争霸移动
--param aid: 军团的id
--param bid: 本次群雄争霸赛的id
--param group: 所在军团的分组
--param target: 目标城市
--param troop: 部队编号, 1,2,3
function socketHelper2:serverWarLocalMove(aid,bid,group,target,troop,callback)
    local tb={}
    tb["cmd"]="areateamwarserver.move"
    tb["params"]={aid=aid,bid=bid,group=group,target=target,sn=troop}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("群雄争霸移动",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--群雄争霸买活
--param aid: 军团的id
--param bid: 本次群雄争霸赛的id
--param group: 所在军团的分组
--param troop: 部队编号, 1,2,3
function socketHelper2:serverWarLocalRevive(aid,bid,group,troop,callback)
    local tb={}
    tb["cmd"]="areateamwarserver.revive"
    tb["params"]={aid=aid,bid=bid,group=group,sn=troop}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("群雄争霸买活",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--群雄争霸发送指令
--param aid: 军团的id
--param bid: 本次群雄争霸赛的id
--param group: 所在军团的分组
--param target: 要发命令的城市ID
--param type: 发的是哪个指令
function socketHelper2:serverWarLocalOrder(aid,bid,group,order,callback)
    local tb={}
    tb["cmd"]="areateamwarserver.sendcommand"
    tb["params"]={aid=aid,bid=bid,group=group,command=order}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("群雄争霸发送指令",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--群雄争霸买buff
--param aid: 军团的id
--param bid: 本次群雄争霸赛的id
--param group: 所在军团的分组
--param buffID: 要买的buffID
function socketHelper2:serverWarLocalBuyBuff(aid,bid,group,buffID,callback)
    local tb={}
    tb["cmd"]="areateamwarserver.buybuff"
    tb["params"]={aid=aid,bid=bid,group=group,buff=buffID}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("群雄争霸买buff",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--群雄争霸刷新部队信息
--param aid: 军团的id
--param bid: 本次群雄争霸赛的id
--param group: 所在军团的分组
function socketHelper2:serverWarLocalTroop(aid,bid,group,callback)
    local tb={}
    tb["cmd"]="areateamwarserver.getactiontroops"
    tb["params"]={aid=aid,bid=bid,group=group}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("群雄争霸刷新部队信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--跨服军团战发送指令
function socketHelper2:serverWarTeamOrder(bid,aid,roundID,battleID,order,callback)
    local tb={}
    tb["cmd"]="acrossserver.sendcommand"
    tb["params"]={bid=bid,aid=aid,round=roundID,group=battleID,command=order}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("跨服军团战发送指令",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--跨服军团战获取当前部队信息
function socketHelper2:acrossserverGetactiontroops(bid,aid,roundID,battleID,callback)
    local tb={}
    tb["cmd"]="acrossserver.getactiontroops"
    tb["params"]={bid=bid,aid=aid,round=roundID,group=battleID}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("跨服军团战当前部队信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 领土争夺战 验证
function socketHelper2:ltzdzVerify(callback,tid)
    local tb={}
    tb["cmd"]="setTid"
    tb["tid"]=tid
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领土争夺战 验证",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 领土争夺战 初始化战场信息，flag：是否需要拉取binfo数据的标识（1：不拉取binfo，0：拉取binfo，第一次进功能时需要拉取binfo，之后无需拉取）
function socketHelper2:ltzdzGetinfo(callback,uid,roomid,isShowLoading,tid,flag)
    local loadingFlag=isShowLoading or true
    local tb={}
    tb["cmd"]="clanwarserver.get"
    tb["tid"]=tid
    tb["params"]={uid=uid,roomid=roomid,flag=flag}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领土争夺战 初始化战场信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],loadingFlag)
end

--领土争夺战 城市建筑建造，升级和移除，开启和取消自动升级的操作
--args：action 1 建造和升级，2 拆除，3 批量建造，4 批量升级，5 开始自动升级，6 取消自动升级
-- roomid, cid 城市id, type 建筑类型, bid 建筑id(主基地和批量操作没有)，num 自动升级次数
function socketHelper2:ltzdzBuildingOperate(args,callback,tid)
    local tb={}
    tb["cmd"]="clanwarserver.buildings"
    tb["params"]=args or {}
    tb["tid"]=tid
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领土争夺战 城市建筑建造，升级和移除的操作",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--领土争夺战 获取城市信息
--action 1.更新和获取城市数据，2.侦查 须有cid
function socketHelper2:ltzdzGetCity(roomid,cid,callback,action,tid)
    local tb={}
    tb["cmd"]="clanwarserver.city"
    tb["tid"]=tid
    tb["params"]={roomid=roomid,cid=cid,action=action}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领土争夺战 获取城市信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--领土争夺战 设置部队
-- action：1 设置防守部队，2 设置自动补充防守部队状态 3 进攻，4 运输
-- cid 城市id，fleetinfo 坦克，hero 将领，sequip 军徽，plane 飞机
-- state 自动补充防守部队状态
-- line 行军路线，n 预备役数量
function socketHelper2:ltzdzSetTroops(callback,action,roomid,state,cid,fleetinfo,hero,sequip,plane,line,n,tid,aitroops)
    local tb={}
    tb["cmd"]="clanwarserver.troops"
    tb["tid"]=tid
    tb["params"]={action=action,roomid=roomid,state=state,cid=cid,fleetinfo=fleetinfo,hero=hero,sequip=sequip,plane=plane,line=line,n=n,at=aitroops}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领土争夺战 设置部队",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--领土争夺战 计策商店购买和使用
-- action 1购买道具，2使用道具，3重置
-- tid 商店物品id，usegems 是否花费金币(使用) 1是
-- cid 城市id，tqid 出征部队id
function socketHelper2:ltzdzBuyOrUseProps(action,tid,usegems,cid,tqid,roomid,callback,stid)
    local tb={}
    tb["cmd"]="clanwarserver.props"
    tb["tid"]=stid
    tb["params"]={action=action,tid=tid,usegems=usegems,roomid=roomid,cid=cid,tqid=tqid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领土争夺战 计策商店购买和使用",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--领土争夺战 一分钟同步资源接口
function socketHelper2:ltzdzResSync(callback,roomid,tid)
    local tb={}
    tb["cmd"]="clanwarserver.ressync"
    tb["tid"]=tid
    local uid=playerVoApi:getUid()
    tb["params"]={uid=uid,roomid=roomid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领土争夺战 一分钟同步资源接口",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],false)
end

-- 领土争夺战 聊天
-- type 1公共，2私聊   receive --私聊玩家id 
function socketHelper2:ltzdzChat(callback,roomid,type,msg,receive,rname,tid)
    if base.shutChatSwitch == 1 then
        do return end
    end
    local tb={}
    tb["cmd"]="clanwarserver.chat"
    tb["tid"]=tid
    tb["params"]={roomid=roomid,type=type,msg=msg,receive=receive,rname=rname}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领土争夺战 聊天",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--领土争夺战 邀请盟友
function socketHelper2:ltzdzAllyOperate(action,roomid,uid,callback,tid)
    local tb={}
    tb["cmd"]="clanwarserver.invite"
    tb["tid"]=tid
    tb["params"]={action=action,roomid=roomid,uid=uid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领土争夺战 申请或取消，同意或拒绝结盟",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--领土争夺战 投降
function socketHelper2:ltzdzGiveUp(roomid,callback,tid)
    local tb={}
    tb["cmd"]="clanwarserver.endbattle"
    tb["tid"]=tid
    tb["params"]={roomid=roomid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领土争夺战 投降",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--领土争夺战 同步行军队列
function socketHelper2:ltzdzFleetsync(tqid,roomid,callback,tid)
    local tb={}
    tb["cmd"]="clanwarserver.fleetsync"
    tb["tid"]=tid
    tb["params"]={tqid=tqid,roomid=roomid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领土争夺战 同步行军队列",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 领土争夺战后台进前台同步
function socketHelper2:ltzdzEnterForegroundSync(roomid,callback,tid)
    local tb={}
    tb["cmd"]="clanwarserver.update"
    tb["tid"]=tid
    tb["params"]={roomid=roomid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领土争夺战后台进前台同步",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end