socketHelper={
    requestID=0,
    requestArr={},
    isSending=false,
    curHost=nil,
}

--取消所有队列
function socketHelper:cancleAllWaitQueue()
    for k,v in pairs(self.requestArr) do
        v=nil
    end
    self.requestArr=nil
    self.requestArr={}
    self.isSending=false
end

function socketHelper:dispose()

    self.requestID=0
    for k,v in pairs(self.requestArr) do
        v=nil
    end
    self.requestArr={}
    self.isSending=false
end

function socketHelper:receivedErr()
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

function socketHelper:receivedResponse(cmd,rnum)
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
function socketHelper:socketConnect(host,port,connectHandler)
    local function netHandler(...)
         base:netHandler(...)
    end
    base:setWait()
    SocketHandler:shared():registerCheckNetHandler(netHandler)
    SocketHandler:shared():connectServer(host,port,connectHandler) --连接服务器
    self.curHost=host
end

--连接聊天服务器
function socketHelper:chatSocketConnect(host,port)
    SocketHandler:shared():connectChatServer(host,port) --连接服务器
end
--登出聊天服务器
function socketHelper:chatServerLogout(uid,token,ts)
    local tb={}
    tb["type"]="quit"
    tb["uid"]=base.curUid
    tb["nickname"]=playerVoApi:getPlayerName()
    tb["access_token"]=base.access_token
    tb["ts"]=base.logints
    local aid=playerVoApi:getPlayerAid()
    if aid and tonumber(aid) then
        tb["channel"]=tonumber(aid)+1
    end
     tb["allianceQuit"]=1
    local requestStr=G_Json.encode(tb)
    print("登出聊天服务器",requestStr)
    --G_Json.encode(tb)
    SocketHandler:shared():sendChatRequest(requestStr)
end
--登录聊天服务器
function socketHelper:chatServerLogin(uid,token,ts,isBattle)
    local tb={}
    tb["type"]="login"
    if isBattle==true then
        tb["type"]="battle"
    end
    tb["uid"]=uid
    tb["nickname"]=playerVoApi:getPlayerName()
    tb["access_token"]=token
    tb["ts"]=ts
    --local alliance=allianceVoApi:getSelfAlliance()
    local aid=playerVoApi:getPlayerAid()
    --if alliance and alliance.aid and tonumber(alliance.aid) then
    if aid and tonumber(aid) then
        tb["channel"]=tonumber(aid)+1
    end
    tb["pic"]=playerVoApi:getPic()
    if(G_curPlatName()=="androidarab")then
        --{"zoneid":1000,"type":"chat","recivername":"","mkey":"44181966085890944724501000","reciver":0,"channel":1,"ts":1472730346,"sender":1000000099,"content":{"level":51,"language":"ar","vip":0,"ts":1472730346,"power":3118,"contentType":1,"subType":1,"message":"2","uid":1000000099,"nam    e":"Rtyu","title":"","st":0,"wr":0,"pic":1,"rank":1},"sendername":"Rtyu"}
        tb["level"]=playerVoApi:getPlayerLevel()
        tb["vip"]=playerVoApi:getVipLevel()
        tb["power"]=playerVoApi:getPlayerPower()
        tb["rank"]=playerVoApi:getRank()
    end
    tb["battle"]=10000
    


    local timeStr=deviceHelper:base64Encode(tostring(math.random(10,99)..tostring(ts)))
        
    local qStr=string.sub(timeStr,1,2)
        
    local hStr=string.sub(timeStr,3)

    local keystrs=deviceHelper:base64Encode(tostring(math.random(5,1000000)*2.3))

        
    local urlParm=qStr..string.sub(keystrs,1,5)..hStr
    
    tb["pstr"]=urlParm


    local requestStr=G_Json.encode(tb)
    print("登录聊天服务器",requestStr)
    --G_Json.encode(tb)
    SocketHandler:shared():sendChatRequest(requestStr)
end
--发送聊天信息
function socketHelper:sendChatMsg(channel,sender,sendername,reciver,recivername,content,isCheckExist)
    local sendTime=base.serverTime
    local tb={}
    tb["type"]="chat"
    tb["channel"]=channel
    tb["sender"]=base.curUid
    tb["sendername"]=sendername
    tb["reciver"]=reciver
    tb["recivername"]=recivername
	tb["content"]=content
    tb["ts"]=base.serverTime
    tb["zoneid"]=base.curZoneID
    --SocketHandler:shared():sendChatRequest("{\"type\":\"chat\",\"channel\":1,'sender':100001,\"reciver\":100006,\"content\":\"hello\"}")

    
   local function callbk(fn,data)
        local sData=G_Json.decode(data)
        socketHelper:receivedResponse(sData.cmd,sData.rnum)
        tb["mkey"]=sData.chatStr
        tb["ts"]=sendTime
        local  requestStr=G_Json.encode(tb)
        print("发送聊天信息",requestStr)
        SocketHandler:shared():sendChatRequest(requestStr)
    end
    socketHelper:ChatEncrypt(callbk,isCheckExist)
end
--阿拉伯clanplay需求
--param type: 1是军团信息，2是军团解散
--param param: 参数，下面的list字段是列表，name字段是军团名
function socketHelper:chatClanMsg(type,params)
    local tb={}
    tb["type"]="alliance"
    tb["uid"]=playerVoApi:getUid()
    if(type==1)then
        local alliance=allianceVoApi:getSelfAlliance()
        if(alliance==nil or alliance.name==nil)then
            if(params and params["list"])then
                tb["alliance"]=params["list"]
            end
            if(params and params["name"])then
                tb["aname"]=params["name"]
            end
        else
            tb["aname"]=alliance.name
            tb["alliance"]={}
            for k,v in pairs(allianceMemberVoApi:getMemberTab()) do
                table.insert(tb["alliance"],{v.uid,v.name})
            end
        end
        if(tb["aname"]==nil or tb["alliance"]==nil)then
            do return end
        end
        if(params and params["isquit"])then
            tb["isquit"]=1
        end
    elseif(type==2)then
        tb["aname"]=name
        tb["isquit"]=2
    else
        do return end
    end
    if(base.clanUserID and base.clanUserID~="")then
        tb["cpuserid"]=base.clanUserID
    end
    local requestStr=G_Json.encode(tb)
    print("军团信息变化通知聊天服务器",requestStr)
    SocketHandler:shared():sendChatRequest(requestStr)
end




--添加数据请求队列
--isCheckExist 是否检测已经存在，目前只有聊天改变数据和系统公告不检测
function socketHelper:sendRequest(str,callback,cmd,isShowLoadingWhenNetErr,isCheckExist)
    if isCheckExist==nil then
        isCheckExist=true
    end
    if isShowLoadingWhenNetErr==nil then
        isShowLoadingWhenNetErr=true
    end
    if isShowLoadingWhenNetErr==true then
        base:setWait()
    end

    local has=false
    for k,v in pairs(self.requestArr) do
        print("已经存在了吗？",cmd,v[3])
        if v~=nil and v[3]==cmd and isCheckExist==true then
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
function socketHelper:realSendRequest()
    if self.requestArr[1]~=nil then
        
        self.requestArr[1]["sendTime"]=G_getCurDeviceMillTime()
        local requestTb=G_Json.decode(tostring(self.requestArr[1][1]))
        requestTb["logints"]=base.logints
        requestTb["access_token"]=base.access_token
        local newStr=G_Json.encode(requestTb)
        SocketHandler:shared():sendRequest(newStr,self.requestArr[1][2],self.requestArr[1][3],self.requestArr[1][4])
    end
end

function  socketHelper:tick()
    SocketHandler:shared():getData()
    
end

function socketHelper:slowTick()
    if self.requestArr~=nil and self.requestArr[1]~=nil then
         if tonumber(self.requestArr[1]["sendTime"])~=nil then 
                if  (G_getCurDeviceMillTime()-tonumber(self.requestArr[1]["sendTime"]))>=12000 then
                     self:cancleAllWaitQueue()
                end
         end
    end
end


--添加公共参数
function socketHelper:addBaseInfo(tb)
    self.requestID=self.requestID+1
    print("用户ID:==",playerVoApi:getUid())
    tb["uid"]=(playerVoApi:getUid()==nil and 0 or playerVoApi:getUid())
    tb["ts"]=base.serverTime
    tb["rnum"]=self.requestID
    tb["zoneid"]=base.curZoneID
    if newGuidMgr and newGuidMgr:isNewGuiding()==true and tb["cmd"]~="user.sync" then
        tb["tutorial"]=newGuidMgr:getTaskID()
    end
    tb["access_token"]=base.access_token
    tb["logints"]=base.logints
    tb["version"]=G_Version
    tb["client_ip"]=base.client_ip
    tb["pname"]=base.platusername
    tb["platid"]=(base.platformUserId==nil and G_getTankUserName() or base.platformUserId)
    if tb["platid"] and string.find(tb["platid"],"_")~=nil then
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
        
        if G_curPlatName()=="9" then
            local tmpTb={}
            tmpTb["action"]="getPaymentStatistics"
            local cjson=G_Json.encode(tmpTb)
            local paymentStatistics=G_accessCPlusFunction(cjson)
            tb["appid"]=paymentStatistics
        end

        
        if G_curPlatName()=="11" and tonumber(base.curZoneID)>3 and tonumber(base.curZoneID)<100 then --德国ios特殊处理
                tb["appid"]=10118
        end
    end
    if(pushController:checkPushServiceVersion()==2)then
        tb["push"]={}
        tb["push"]["binid"]=pushController:getUserID()
        tb["push"]["tb"]=pushController:getModuleTb()
    end
    if(G_isIOS())then
        tb["system"]="ios"
        tb["deviceid"]="IOS_"
    else
        tb["system"]="android"
        tb["deviceid"]="AND_"
    end
    tb["bh"]=G_getBHVersion()
    tb["lang"]=G_CurLanguageName
    if base.memoryServerPlatId and base.memoryServerPlatId~="" then --怀旧服需要给后端传玩家登录的平台id，后端作校验用
        tb["mplat"]=base.memoryServerPlatId
    end

    local tmpTbGetChannel={}
    tmpTbGetChannel["action"]="getChannel"
    local cjsonGetChannel=G_Json.encode(tmpTbGetChannel)
    local thechannelid = G_accessCPlusFunction(cjsonGetChannel)

    tb["channelid"]=thechannelid
    

end

function socketHelper:upgradeSkin( ... )
    -- body
end

function socketHelper:useSkin( ... )
    -- body
end

--升级建筑请求接口
function socketHelper:upgradeBuild(bid,btype,callback,usegem)
    local tb={}
    tb["cmd"]="building.upgrade"
    tb["params"]={bid=bid,buildType=btype,usegem=usegem}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("请求",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--拆除建筑
function socketHelper:removeBuild(bid,btype,callback)
    local tb={}
    tb["cmd"]="building.remove"
    tb["params"]={bid=bid,buildType=btype}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("拆除",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--取消建筑升级
function socketHelper:cancleUpgradeBuild(bid,btype,callback)
    local tb={}
    tb["cmd"]="building.cancel"
    tb["params"]={bid=bid,buildType=btype}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("取消建筑升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--加速升级建筑
function socketHelper:superUpgradeBuild(bid,btype,callback)
    local tb={}
    tb["cmd"]="building.speedup"
    tb["params"]={bid=bid,buildType=btype}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("加速建筑升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--生产道具接口
function socketHelper:produceProps(pid,nums,callback)
    local tb={}
    --tb["cmd"]="proc.upgrade"
	tb["cmd"]="prop.upgrade"
    tb["params"]={pid=pid,nums=nums}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("生产道具",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--加速生产道具接口
function socketHelper:speedUpProps(slotid,pid,nums,callback)
    local tb={}
    --tb["cmd"]="proc.speedup"
	tb["cmd"]="prop.speedup"
    tb["params"]={pid=pid,nums=nums,slotid=slotid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("加速生产道具",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--取消生产道具接口
function socketHelper:cancelProps(slotid,pid,nums,callback)
    local tb={}
    --tb["cmd"]="proc.cancel"
	tb["cmd"]="prop.cancel"
    tb["params"]={pid=pid,nums=nums,slotid=slotid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("删除生产道具",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--科技研究
function socketHelper:upgradeTech(tid,callback)
    local tb={}
    tb["cmd"]="tech.upgrade"
    tb["params"]={tid=tid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("科技研究",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--取消科技研究
function socketHelper:cancleUpgradeTech(tid,callback)
    local tb={}
    tb["cmd"]="tech.cancel"
    tb["params"]={tid=tid,slotid=technologySlotVoApi:getSlotByTid(tid).slotid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("取消科技研究",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--加速科技研究
function socketHelper:superUpgradeTech(tid,callback)
        local tb={}
    tb["cmd"]="tech.speedup"
    tb["params"]={tid=tid,slotid=technologySlotVoApi:getSlotByTid(tid).slotid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("加速科技研究",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end

--生产坦克接口
function socketHelper:addTanks(bid,aid,nums,callback)
    local tb={}
    tb["cmd"]="troop.add"
    tb["params"]={bid=bid,aid=aid,nums=nums}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("生产坦克",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--加速坦克接口
function socketHelper:speedupTanks(bid,slotid,aid,nums,callback)
    local tb={}
    tb["cmd"]="troop.speedup"
    tb["params"]={bid=bid,aid=aid,nums=nums,slotid=slotid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("加速生产坦克",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--取消坦克接口
function socketHelper:cancleTanks(bid,slotid,aid,nums,callback)
    local tb={}
    tb["cmd"]="troop.cancel"
    tb["params"]={bid=bid,aid=aid,nums=nums,slotid=slotid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("取消生产坦克",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--改装坦克接口 enum:精英坦克数量
function socketHelper:upgradeTanks(bid,aid,nums,callback,enum)
    local tb={}
    tb["cmd"]="troop.upgrade"
    tb["params"]={bid=bid,aid=aid,nums=nums,enum=enum}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("改装坦克",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--加速改装坦克接口
function socketHelper:speedupUpgradeTanks(bid,slotid,aid,nums,callback)
    local tb={}
    tb["cmd"]="troop.upgradespeedup"
    tb["params"]={bid=bid,aid=aid,nums=nums,slotid=slotid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("加速改装坦克",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--取消改装坦克接口
function socketHelper:cancelUpgradeTanks(bid,slotid,aid,nums,callback)
    local tb={}
    tb["cmd"]="troop.upgradecancel"
    tb["params"]={bid=bid,aid=aid,nums=nums,slotid=slotid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("取消改装坦克",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--升级技能接口
function socketHelper:upgradeSkill(sid,lv,callback)
    local tb={}
    tb["cmd"]="skill.upgrade"
    tb["params"]={sid=sid,lv=lv}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("升级技能",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--重置技能接口
function socketHelper:resetSkill(callback)
    local tb={}
    tb["cmd"]="skill.reset"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("重置技能",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--购买道具
function socketHelper:buyProc(pid,callback,num, activeName)
    local tb={}
    tb["cmd"]="prop.buy"
	--tb["cmd"]="prop.cancel"
    tb["params"]={pid=pid,num=num,activeName = activeName}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("购买道具",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--使用道具
--usegem 是否花费金币
--ug 使用需要消耗其他道具时：1.道具不足时会消耗金币
--nickname 使用雷达的时候传的nickname
function socketHelper:useProc(pid,useGem,callback,ug,nickname,count,get)
    local tb={}
    --tb["cmd"]="proc.use"
	tb["cmd"]="prop.use"
    tb["params"]={pid=pid,useGem=useGem,ug=ug,nickname=nickname,count=count,get=get}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("使用道具",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--关卡战斗
function socketHelper:startBattleForNPC(data,callback)
    local tb={}
    tb["cmd"]="challenge.battle"
    tb["params"]=data
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("进攻关卡",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:userLogin(callback,uid,name,pwd,ifShowLoading)
    local tb={}
    tb["cmd"]="user.login"
    self:addBaseInfo(tb)
    if uid~=0 then
        tb["uid"]=uid
    end
    local uname,upwd
    if name~=nil and name~="" then
         uname=name
    else
         uname=G_getTankUserName()
    end
    
    if pwd~=nil and pwd~="" then
        upwd=pwd
    else
        upwd=G_getTankUserPassWord()
    end
    tb["isbind"]=G_getIsBind(uname)
    tb["params"]={username=uname,password=upwd}
    tb["luaV"]=G_luaVersion()
    tb["device"]=G_getDeviceid()
    local requestStr=G_Json.encode(tb)
    print("用户登陆",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],ifShowLoading)
end

--购买建筑队列
function socketHelper:buyBuildingSlot(callback)
    local tb={}
    tb["cmd"]="user.buyslot"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("购买建筑队列",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])

end


--请求获取世界地图数据
--param x1,y1,x2,y2: 要请求哪片区域
--param isEagleEye: 新增技能猎鹰之眼，第一次进世界地图的时候需要向后台拉取相关数据
function socketHelper:getWorldMap(x1,y1,x2,y2,isEagleEye,goldmine,privatemine,callback)
    local tb={}
    tb["cmd"]="map.get"
    tb["params"]={x1=x1,y1=y1,x2=x2,y2=y2,goldMine=goldmine,privateMine=privatemine}
    if(isEagleEye)then
        tb["params"]["eagleEye"]=isEagleEye
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("请求世界地图",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],false)
end

--资源同步
function socketHelper:userSync(callback)
    local tb={}
    tb["cmd"]="user.sync"
    tb["params"]={}
    self:addBaseInfo(tb)
    tb["device"]=G_getDeviceid()
    local requestStr=G_Json.encode(tb)
    print("资源同步",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],false)
end

--修理坦克
function socketHelper:repairTanks(costtype,aid,num,callback)
    local tb={}
    tb["cmd"]="troop.repair"
    tb["params"]={costtype=costtype,aid=aid,num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("修理坦克",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--打开邮件列表
function socketHelper:emailList(type,mineid,maxeid,callback,isPage,ifShowLoading)
    local tb={}
    tb["cmd"]="mail.list"
	tb["params"]={type=type,mineid=mineid,maxeid=maxeid}
	if isPage~=nil then
		tb["params"].isPage=isPage
	end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("打开邮件列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],ifShowLoading)
end

--发送邮件
function socketHelper:sendEmail(data,callback)
    local tb={}
    tb["cmd"]="mail.send"
    tb["params"]=data
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("发送邮件",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--邮件设置已读  战报返回战报数据
function socketHelper:readEmail(type,eid,callback)
    local tb={}
    tb["cmd"]="mail.read"
    tb["params"]={type=type,eid=eid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("邮件设置已读",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--删除邮件 无eid则按类型删除
function socketHelper:deleteEmail(type,eid,callback)
    local tb={}
    tb["cmd"]="mail.delete"
	tb["params"]={type=type}
	if eid then
		tb["params"]={type=type,eid=eid}
	end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("删除邮件",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--所有邮件标为 已读
function socketHelper:readedAllEmail(type, callback)
    local tb = {}
    tb["cmd"] = "mail.setread"
    tb["params"] = {type=type}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("所有邮件标为 已读",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--收藏坐标
function socketHelper:markBookmark(type,name,mapx,mapy,callback)
    local tb={}
    tb["cmd"]="bookmark.mark"
    tb["params"]={type=type,name=name,mapx=mapx,mapy=mapy}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("收藏坐标",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--收藏坐标
function socketHelper:updateBookmark(mark,callback)
    local tb={}
    tb["cmd"]="bookmark.update"
    tb["params"]={mark=mark}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("更新收藏坐标",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--删除坐标
function socketHelper:removeBookmark(mid,callback)
    local tb={}
    tb["cmd"]="bookmark.delete"
    tb["params"]={mid=mid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("删除坐标",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--设置防守坦克
function socketHelper:setdefenseTroop(fleetinfo,callback,hero,emblemID,planePos,aitroops,airshipId)
    local tb={}
    tb["cmd"]="troop.setdefense"
    tb["params"]={fleetinfo=fleetinfo,hero=hero,equip=emblemID,plane=planePos,at=aitroops,ap=airshipId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("设置防守坦克",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--打开关卡面板
function socketHelper:challengelist(minsid,maxsid,callback)
    local tb={}
    tb["cmd"]="challenge.list"
    tb["params"]={minsid=minsid,maxsid=maxsid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("打开关卡面板",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--进攻地图
--param targetid: 进攻的坐标
--param fleetinfo: 出战的部队
--param isGather: 是否驻守采集
--param isHelp: 是否驻防
--param callback: 回调
--param hero: 出战将领
--param rebelType: 攻击叛军的时候使用，是否是高级攻击
--param emblemID: 军徽ID
--param planePos: 飞机解锁位置
--param aitroops: AI部队
--param airshipId: 飞艇ID
--param atkNum: 进攻次数
function socketHelper:attackTroop(targetid,fleetinfo,isGather,isHelp,callback,hero,apc,rebelType,emblemID,planePos,aitroops,city,airshipId,atkNum)
    local tb={}
    tb["cmd"]="troop.attack"
    tb["params"]={targetid=targetid,fleetinfo=fleetinfo,isGather=isGather,isHelp=isHelp,hero=hero,apc=apc,city=city}
    if(rebelType)then
        tb["params"].rebel=rebelType
    end
    if(emblemID)then
        tb["params"].equip=emblemID
    end
    if(planePos)then
        tb["params"].plane=planePos
    end
    if aitroops then
        tb["params"].at=aitroops
    end
    if airshipId then
        tb["params"].ap=airshipId
    end
    if atkNum then
        tb["params"].ship=atkNum
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("进攻地图",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--地图侦查
function socketHelper:mapScout(target,callback)
    local tb={}
    tb["cmd"]="map.scout"
    tb["params"]={target=target}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("地图侦查",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--舰队返回
function socketHelper:troopBack(cid,callback,isAuto,city)
    if isAuto==nil then
        isAuto=0
    end
    local tb={}
    tb["cmd"]="troop.back"
    tb["params"]={cid=cid,auto=isAuto,city=city}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("舰队返回",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--协防舰队返回
function socketHelper:helpTroopBack(cid,huid,callback)
    local tb={}
    tb["cmd"]="troop.back"
    tb["params"]={cid=cid,huid=huid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("协防舰队返回",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--舰队进攻加速
function socketHelper:cronAttack(cronid,target,attacker,usegem,callback)
    local tb={}
    tb["cmd"]="cron.attack"
    tb["params"]={cronid=cronid,target=target,attacker=attacker,usegem=usegem}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("舰队进攻加速",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--舰队返回加速
function socketHelper:troopBackSpeedup(cid,callback)
    local tb={}
    tb["cmd"]="troop.backspeedup"
    tb["params"]={cid=cid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("舰队返回加速",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--岛屿搬迁
function socketHelper:baseChange(callback,x,y)
    local tb={}
    tb["cmd"]="user.basemove"
    if x==nil then
        tb["params"]={}
    else
        tb["params"]={target={x,y}}
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("岛屿搬迁",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])

end

--统御升级 说明:有书则先用书，无书会自动使用宝石
function socketHelper:troopsUp(callback)
    local tb={}
    tb["cmd"]="user.troopsup"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("统御升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--授勋
function socketHelper:dailyHonors(type,callback)
    local tb={}
    --tb["cmd"]="userinfo_ext.dailyhonors"
	tb["cmd"]="user.dailyhonors"
    tb["params"]={type=type}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("授勋",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--升级军衔
function socketHelper:rankUp(callback)
    local tb={}
    tb["cmd"]="user.rankup"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("升级军衔",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--每日军响
function socketHelper:gratisgoods(callback)
    local tb={}
    --tb["cmd"]="userinfo_ext.gratisgoods"
	tb["cmd"]="user.dailyaward"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("每日军响",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--每日乐透
function socketHelper:luckygoods(type,free,gems,check,callback)
    local tb={}
    --tb["cmd"]="userinfo_ext.luckygoods"
	tb["cmd"]="user.dailylottery"
    tb["params"]={type=type,free=free,gems=gems,check=check}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("每日乐透",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--购买能量
function socketHelper:buyEnergy(callback)
    local tb={}
    --tb["cmd"]="userinfo_ext.buyenergy"
	tb["cmd"]="user.buyenergy"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("购买能量",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--完成任务
function socketHelper:taskFinish(taskid,callback)
    local tb={}
    tb["cmd"]="task.finish"
    tb["params"]={taskid=taskid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("完成任务",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--选择日常任务
function socketHelper:dailytaskSelect(taskid,callback)
    local tb={}
    tb["cmd"]="dailytask.select"
    tb["params"]={taskid=taskid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("选择日常任务",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--放弃日常任务
function socketHelper:dailytaskCancel(taskid,callback)
    local tb={}
    tb["cmd"]="dailytask.cancel"
    tb["params"]={taskid=taskid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("放弃日常任务",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--重置日常任务
function socketHelper:dailytaskReset(callback)
    local tb={}
    tb["cmd"]="dailytask.reset"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("重置日常任务",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--完成日常任务
function socketHelper:dailytaskFinish(taskid,useGem,callback)
    local tb={}
    tb["cmd"]="dailytask.finish"
    tb["params"]={taskid=taskid}
	if useGem then
		tb["params"]["useGem"]=1
	end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("完成日常任务",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--刷新日常任务
function socketHelper:dailytaskRefresh(callback)
    local tb={}
    tb["cmd"]="dailytask.refresh"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("完成日常任务",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--完成新的日常任务
function socketHelper:dailytaskFinishNew(taskid,callback)
    local tb={}
    tb["cmd"]="dailytask.finishnew"
    tb["params"]={taskid=taskid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("完成新的日常任务",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--获取新的日常任务
function socketHelper:dailytaskGet(callback)
    local tb={}
    tb["cmd"]="dailytask.get"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获取新的日常任务",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--跳过新手引导
function socketHelper:skipNewGuid(callback)
    local tb={}
    tb["cmd"]="user.sync"
    tb["params"]={}
    self:addBaseInfo(tb)
    tb["tutorial"]=9
    local requestStr=G_Json.encode(tb)
    print("跳过新手",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],false)
end

--排行榜 type类型 1为战斗力 2为关卡 3为荣誉
function socketHelper:ranking(type,page,callback)
    local tb={}
	if type==nil or type==1 then
		tb["cmd"]="ranking.fc"
	elseif type==2 then
		tb["cmd"]="ranking.challenge"
	elseif type==3 then
		tb["cmd"]="ranking.honors"
	end
    tb["params"]={}
	if page~=nil then
		tb["params"].page=page
	end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--同步 请求是否有新事件
function socketHelper:userEvent(callback)
    local tb={}
	tb["cmd"]="user.event"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新事件",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],false)
end

--游戏设置开关 sid:s1"建造,生产完成",s2"能量恢复满",s3"自动补充防御舰队",s4"攻打野地默认驻守",s5"音乐设置",s6"音效设置",switch:1开,0关
function socketHelper:gameSettings(sid,switch,callback)
    local tb={}
	tb["cmd"]="user.gamesetting"
    tb["params"]={sid=sid,switch=switch}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("自动补充防御舰队",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--检测此玩家是否创建过账号
function socketHelper:userCheck(uid,username,callback)
    local tb={}
	tb["cmd"]="user.check"
    tb["params"]={username=username}
    self:addBaseInfo(tb)
    tb["uid"]=uid
    local requestStr=G_Json.encode(tb)
    print("检测用户账号",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],false)
end

function socketHelper:userSigup(uid,username,password,nickname,pic,callback)
    local tb={}
	tb["cmd"]="user.sigup"
    tb["params"]={username=username,password=password,nickname=nickname,pic=pic}
    self:addBaseInfo(tb)
    tb["uid"]=uid
    local requestStr=G_Json.encode(tb)
    --print("user.sigup",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],false)
end
--绑定账号
function socketHelper:bindingAccount(callback)
    local tb={}
	tb["cmd"]="user.bind"
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("绑定账号领取金币",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--修改密码
function socketHelper:changePassword(oldpassword,newpassword,callback)
    local tb={}
	tb["cmd"]="user.pwdupdate"
    tb["params"]={oldpassword=oldpassword,newpassword=newpassword}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("修改密码",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--支付请求
function socketHelper:userPayment(iapOrder,sandbox,callback,key)
    sandbox=nil
    local tb={}
	tb["cmd"]="user.payment"
        local thepid = tostring((base.platformUserId==nil and G_getTankUserName() or base.platformUserId))
    tb["params"]={iapOrder=iapOrder,sandbox=sandbox,pid=thepid,ulvl=playerVoApi:getPlayerLevel(),viplvl=playerVoApi:getVipLevel(),curType=GetMoneyName()}
    tb["params"]["device"]=G_getDeviceid()
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    if G_curPlatName()=="0" then --坦克台湾版目前还是socket的形式
        print("支付请求socket形式",requestStr)
        self:sendRequest(requestStr,callback,tb["cmd"],false)
    elseif G_curPlatName()=="5" or G_curPlatName()=="58" then --坦克飞流版http形式
        --[[
        local httpUrl=base.payurl
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        if tonumber(retstr)>=0 then
            G_removePayment(key)
        end
        ]]
        local httpUrl=G_getPlatFormPayUrl()
        base.pauseSync=true  --暂停发送同步请求
        --print("requestStr=",requestStr,"httpUrl=",httpUrl)

        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        base.pauseSync=false --恢复发送同步请求
        print("=========*******======支付好了retstrpay=",retstr)
        if tonumber(retstr)>0 then
            --print("G_removePayment")
            G_removePayment(key)
            
            local gems=playerVoApi:getGems()+tonumber(retstr)
            playerVoApi:setGems(gems)
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buyGoldSuccess"),nil,20)
        elseif tonumber(retstr)==0 then
            G_removePayment(key)
        end
    elseif G_curPlatName()=="58" then --坦克飞流霸天坦克http形式
        local httpUrl=G_getPlatFormPayUrl()
        base.pauseSync=true  --暂停发送同步请求

        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        base.pauseSync=false --恢复发送同步请求
        print("=========*******======支付好了retstrpay=",retstr)
        if tonumber(retstr)>0 then
            G_removePayment(key)
            
            local gems=playerVoApi:getGems()+tonumber(retstr)
            playerVoApi:setGems(gems)
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buyGoldSuccess"),nil,20)
        elseif tonumber(retstr)==0 then
            G_removePayment(key)
        end
    elseif G_curPlatName()=="60" then --坦克飞流战地坦克备用包http形式
        local httpUrl=G_getPlatFormPayUrl()
        base.pauseSync=true  --暂停发送同步请求

        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        base.pauseSync=false --恢复发送同步请求
        print("=========*******======支付好了retstrpay=",retstr)
        if tonumber(retstr)>0 then
            G_removePayment(key)
            
            local gems=playerVoApi:getGems()+tonumber(retstr)
            playerVoApi:setGems(gems)
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buyGoldSuccess"),nil,20)
        elseif tonumber(retstr)==0 then
            G_removePayment(key)
        end
    elseif G_curPlatName()=="64" then
        local httpUrl=G_getPlatFormPayUrl()
        base.pauseSync=true
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        base.pauseSync=false
        print("=========*******======支付好了retstrpay=",retstr)
        if tonumber(retstr)>0 then
            G_removePayment(key)

            local gems=playerVoApi:getGems()+tonumber(retstr)
            playerVoApi:setGems(gems)
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buyGoldSuccess"),nil,20)
        elseif tonumber(retstr)==0 then
            G_removePayment(key)
        end
    elseif G_curPlatName()=="66" then --飞流正版王牌坦克http形式
        local httpUrl=G_getPlatFormPayUrl()
        base.pauseSync=true
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        base.pauseSync=false
        -- print("=========*******======支付好了retstrpay=",retstr)
        if tonumber(retstr)>0 then
            G_removePayment(key)

            local gems=playerVoApi:getGems()+tonumber(retstr)
            playerVoApi:setGems(gems)
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buyGoldSuccess"),nil,20)
        elseif tonumber(retstr)==0 then
            G_removePayment(key)
        end
     elseif G_curPlatName()=="61" then --坦克飞流战地坦克备用包http形式
        local httpUrl=G_getPlatFormPayUrl()
        base.pauseSync=true  --暂停发送同步请求

        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        base.pauseSync=false --恢复发送同步请求
        print("=========*******======支付好了retstrpay=",retstr)
        if tonumber(retstr)>0 then
            G_removePayment(key)
            
            local gems=playerVoApi:getGems()+tonumber(retstr)
            playerVoApi:setGems(gems)
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buyGoldSuccess"),nil,20)
        elseif tonumber(retstr)==0 then
            G_removePayment(key)
        end
    elseif G_curPlatName()=="48" then --坦克百度版http形式
        local httpUrl=G_getPlatFormPayUrl()
        base.pauseSync=true  --暂停发送同步请求
        --print("requestStr=",requestStr,"httpUrl=",httpUrl)
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        base.pauseSync=false --恢复发送同步请求
        print("=========*******======支付好了retstrpay=",retstr)
        if tonumber(retstr)>0 then
            --print("G_removePayment")
            G_removePayment(key)

            local gems=playerVoApi:getGems()+tonumber(retstr)
            playerVoApi:setGems(gems)
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buyGoldSuccess"),nil,20)
        elseif tonumber(retstr)==0 then
            G_removePayment(key)
        end
    elseif G_curPlatName()=="45" then --坦克飞流版http形式
        local httpUrl=G_getPlatFormPayUrl()
        base.pauseSync=true  --暂停发送同步请求
        --print("requestStr=",requestStr,"httpUrl=",httpUrl)
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        base.pauseSync=false --恢复发送同步请求
        print("=========*******======支付好了retstrpay=",retstr)
        if tonumber(retstr)>0 then
            --print("G_removePayment")
            G_removePayment(key)

            local gems=playerVoApi:getGems()+tonumber(retstr)
            playerVoApi:setGems(gems)
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buyGoldSuccess"),nil,20)
        elseif tonumber(retstr)==0 then
            G_removePayment(key)
        end
    elseif G_curPlatName()=="51" then --坦克飞流换皮包版http形式
        local httpUrl=G_getPlatFormPayUrl()
        base.pauseSync=true  --暂停发送同步请求
        --print("requestStr=",requestStr,"httpUrl=",httpUrl)
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        base.pauseSync=false --恢复发送同步请求
        print("=========*******======支付好了retstrpay=",retstr)
        if tonumber(retstr)>0 then
            --print("G_removePayment")
            G_removePayment(key)

            local gems=playerVoApi:getGems()+tonumber(retstr)
            playerVoApi:setGems(gems)
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buyGoldSuccess"),nil,20)
        elseif tonumber(retstr)==0 then
            G_removePayment(key)
        end
    elseif G_curPlatName()=="52" then --坦克gNetop俄罗斯版http形式
        local httpUrl=G_getPlatFormPayUrl()
        base.pauseSync=true  --暂停发送同步请求
        --print("requestStr=",requestStr,"httpUrl=",httpUrl)
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        base.pauseSync=false --恢复发送同步请求
        print("=========*******======支付好了retstrpay=",retstr)
        if tonumber(retstr)>0 then
            --print("G_removePayment")
            G_removePayment(key)

            local gems=playerVoApi:getGems()+tonumber(retstr)
            playerVoApi:setGems(gems)
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buyGoldSuccess"),nil,20)
        elseif tonumber(retstr)==0 then
            G_removePayment(key)
        end
    elseif G_curPlatName()=="12"  then --坦克中手游俄罗斯http形式
        --[[
        local httpUrl=base.payurl
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        if tonumber(retstr)>=0 then
            G_removePayment(key)
        end
        ]]
        local httpUrl=base.payurl
        base.pauseSync=true  --暂停发送同步请求
        --print("requestStr=",requestStr,"httpUrl=",httpUrl)
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        base.pauseSync=false --恢复发送同步请求
        print("=========*******======支付好了retstrpay=",retstr)
        if tonumber(retstr)>0 then
            --print("G_removePayment")
            G_removePayment(key)
            
            local gems=playerVoApi:getGems()+tonumber(retstr)
            playerVoApi:setGems(gems)
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buyGoldSuccess"),nil,20)
        elseif tonumber(retstr)==0 then
            G_removePayment(key)
        end
    elseif  G_curPlatName()=="13" then --坦克中手游韩国http形式
        --[[
        local httpUrl=base.payurl
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        if tonumber(retstr)>=0 then
            G_removePayment(key)
        end
        ]]
        local httpUrl=base.payurl
        base.pauseSync=true  --暂停发送同步请求
        --print("requestStr=",requestStr,"httpUrl=",httpUrl)
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        base.pauseSync=false --恢复发送同步请求
        print("=========*******======支付好了retstrpay=",retstr)
        if tonumber(retstr)>0 then
            --[[
            --print("G_removePayment")
            G_removePayment(key)
            
            local gems=playerVoApi:getGems()+tonumber(retstr)
            playerVoApi:setGems(gems)

            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buyGoldSuccess"),nil,20)
            ]]
        elseif tonumber(retstr)==0 then
            G_removePayment(key)
        end
    elseif  G_curPlatName()=="20" then --坦克日本http形式
        --[[
        local httpUrl=base.payurl
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        if tonumber(retstr)>=0 then
            G_removePayment(key)
        end
        ]]
        local httpUrl=base.payurl
        base.pauseSync=true  --暂停发送同步请求
        --print("requestStr=",requestStr,"httpUrl=",httpUrl)
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        print("httpUrl=",httpUrl,"retstr=",retstr)
        base.pauseSync=false --恢复发送同步请求
        print("=========*******======支付好了retstrpay=",retstr)
        if tonumber(retstr)>0 then
            --print("G_removePayment")
            G_removePayment(key)
            
            local gems=playerVoApi:getGems()+tonumber(retstr)
            playerVoApi:setGems(gems)

            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buyGoldSuccess"),nil,20)
        elseif tonumber(retstr)==0 then
            G_removePayment(key)
        end
    elseif  G_curPlatName()=="41" or G_curPlatName()=="62" then --坦克日本http形式
        --[[
            local httpUrl=base.payurl
            local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
            if tonumber(retstr)>=0 then
            G_removePayment(key)
            end
            ]]
        local httpUrl=base.payurl
        base.pauseSync=true  --暂停发送同步请求
        --print("requestStr=",requestStr,"httpUrl=",httpUrl)
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        print("httpUrl=",httpUrl,"retstr=",retstr)
        base.pauseSync=false --恢复发送同步请求
        print("=========*******======支付好了retstrpay=",retstr)
        if tonumber(retstr)>0 then
        --print("G_removePayment")
        G_removePayment(key)

        local gems=playerVoApi:getGems()+tonumber(retstr)
        playerVoApi:setGems(gems)

        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buyGoldSuccess"),nil,20)
        elseif tonumber(retstr)==0 then
            G_removePayment(key)
        end
    elseif  G_curPlatName()=="31" then --坦克日本http形式
        --[[
        local httpUrl=base.payurl
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        if tonumber(retstr)>=0 then
            G_removePayment(key)
        end
        ]]
        local httpUrl=base.payurl
        base.pauseSync=true  --暂停发送同步请求
        --print("requestStr=",requestStr,"httpUrl=",httpUrl)
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        print("httpUrl=",httpUrl,"retstr=",retstr)
        base.pauseSync=false --恢复发送同步请求
        print("=========*******======支付好了retstrpay=",retstr)
        if tonumber(retstr)>0 then
            --print("G_removePayment")
            G_removePayment(key)
            
            local gems=playerVoApi:getGems()+tonumber(retstr)
            playerVoApi:setGems(gems)

            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buyGoldSuccess"),nil,20)
        elseif tonumber(retstr)==0 then
            G_removePayment(key)
        end
    elseif  G_curPlatName()=="21" then --坦克http形式
        --[[
        local httpUrl=base.payurl
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        if tonumber(retstr)>=0 then
            G_removePayment(key)
        end
        ]]
        local httpUrl=base.payurl
        base.pauseSync=true  --暂停发送同步请求
        --print("requestStr=",requestStr,"httpUrl=",httpUrl)
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        print("httpUrl=",httpUrl,"retstr=",retstr)
        base.pauseSync=false --恢复发送同步请求
        print("=========*******======支付好了retstrpay=",retstr)
        if tonumber(retstr)>0 then
            --print("G_removePayment")
            G_removePayment(key)
            
            local gems=playerVoApi:getGems()+tonumber(retstr)
            playerVoApi:setGems(gems)

            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buyGoldSuccess"),nil,20)
        elseif tonumber(retstr)==0 then
            G_removePayment(key)
        end
    elseif G_curPlatName()=="66" then   --雷尚自有App Store开炮吧坦克渠道
        local httpUrl=base.payurl
        base.pauseSync=true  --暂停发送同步请求
        --print("requestStr=",requestStr,"httpUrl=",httpUrl)
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        print("httpUrl=",httpUrl,"retstr=",retstr)
        base.pauseSync=false --恢复发送同步请求
        print("=========*******======支付好了retstrpay=",retstr)
        if tonumber(retstr)>0 then
            --print("G_removePayment")
            G_removePayment(key)
            local gems=playerVoApi:getGems()+tonumber(retstr)
            playerVoApi:setGems(gems)
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buyGoldSuccess"),nil,20)
        elseif tonumber(retstr)==0 then
            G_removePayment(key)
        end
    elseif  G_curPlatName()=="25" then --坦克澳大利亚360 http形式
        --[[
        local httpUrl=base.payurl
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        if tonumber(retstr)>=0 then
            G_removePayment(key)
        end
        ]]
        local httpUrl=base.payurl
        base.pauseSync=true  --暂停发送同步请求
        --print("requestStr=",requestStr,"httpUrl=",httpUrl)
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        print("httpUrl=",httpUrl,"retstr=",retstr)
        base.pauseSync=false --恢复发送同步请求
        print("=========*******======AU支付好了retstrpay=",retstr)
        if tonumber(retstr)>0 then
            --print("G_removePayment")
            G_removePayment(key)
            
            local gems=playerVoApi:getGems()+tonumber(retstr)
            playerVoApi:setGems(gems)

            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("buyGoldSuccess"),nil,20)
        elseif tonumber(retstr)==0 then
            G_removePayment(key)
        end
    
    

    elseif G_curPlatName()=="2" then --yeahmobi台湾版本用http形式

        
        local httpUrl=serverCfg.payUrl
        local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
        callback("",retstr)
    end
    self:receivedResponse(tb["cmd"],tb["rnum"])
end


--安卓支付请求
function socketHelper:userPaymentForAndroid(parmTb,platform,callback)
    self:addBaseInfo(parmTb)
    
    parmTb["rulv"]=tostring(playerVoApi:getPlayerLevel())
    parmTb["rvlv"]=tostring(playerVoApi:getVipLevel())
   -- parmTb["rpid"] = tostring((base.platformUserId==nil and G_getTankUserName() or base.platformUserId))

    

    requestStr=G_Json.encode(parmTb)
    deviceHelper:luaPrint(requestStr)
    requestStr = deviceHelper:base64Encode(requestStr)
    deviceHelper:luaPrint(requestStr)  
    local httpUrl= G_getPlatFormPayUrl()    -- "http://test.raysns.com:8082/googleplay/payment.php" --  serverCfg.payUrl 
   deviceHelper:luaPrint("pay success")
   deviceHelper:luaPrint(httpUrl)  
    local retstr=G_sendHttpRequestPost(httpUrl,"pm="..requestStr)
    callback("",retstr)
end



--新手7日礼包
function socketHelper:newuseraward(day,callback)
    local tb={}
	tb["cmd"]="user.newuseraward"
    tb["params"]={day=day}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新手7日礼包",requestStr)
	self:sendRequest(requestStr,callback,tb["cmd"])
end

--发送feed奖励,每日前3次奖励
function socketHelper:feedsaward(paramType,callback,activeName)
    local tb={}
	tb["cmd"]="user.feedsaward"
    tb["params"]={type=paramType,activeName=activeName}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("发送feed奖励",requestStr)
	self:sendRequest(requestStr,callback,tb["cmd"])
end

--军团列表
function socketHelper:allianceList(callback,rc)
    local tb={}
    tb["cmd"]="alliance.list"
    tb["params"]={rc=rc}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--活动奖励
function socketHelper:activeReward(type,callback)
    local tb={}
	tb["cmd"]="active."..type
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("活动奖励",requestStr)
	self:sendRequest(requestStr,callback,tb["cmd"])
end

--创建军团
function socketHelper:allianceCreate(consumeType,foreignNotice,name,joinType,callback)
    local tb={}
    tb["cmd"]="alliance.create"
    tb["params"]={consumeType=consumeType,foreignNotice=foreignNotice,name=name,joinType=joinType}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("创建军团",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--申请加入军团
function socketHelper:allianceJoin(aid,callback)
    local tb={}
    tb["cmd"]="alliance.join"
    tb["params"]={aid=aid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("申请加入军团",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--检索军团 返回data.alliance.findlist
function socketHelper:allianceFind(name,callback)
    local tb={}
    tb["cmd"]="alliance.find"
    tb["params"]={name=name}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("检索军团",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 修改成员信息(职位和签名) 返回data.alliance
-- 参数：
-- int aid 军团id
-- 修改签名：string signature 成员签名    修改签名
-- 修改职位：int memuid=1000333 成员id，int role=1 权限标识
function socketHelper:allianceEditmember(aid,signature,memuid,role,callback)
    local tb={}
    tb["cmd"]="alliance.editmember"
    tb["params"]={aid=aid,signature=signature,memuid=memuid,role=role}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("修改成员信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:allianceSetrole(aid,role,memuid,callback)
    local tb={}
    tb["cmd"]="alliance.setrole"
    tb["params"]={aid=aid,role=role,memuid=memuid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("修改成员职位",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 离开或踢出军团 返回data.alliance
-- 参数：
-- int aid 申请的军团id 
-- int memuid 成员uid  如果有此参数，则踢除此用户（权限检测），否则是离开
function socketHelper:allianceQuit(aid,memuid,callback)
    local tb={}
    tb["cmd"]="alliance.quit"
    tb["params"]={aid=aid,memuid=memuid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("离开或踢出军团",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 拒绝成员的申请 返回data.alliance
-- 参数：
-- int aid 申请的军团id 
-- int memuid 申请人的uid，如果无，则是全部拒绝
function socketHelper:allianceDeny(aid,memuid,callback)
    local tb={}
    tb["cmd"]="alliance.deny"
    tb["params"]={aid=aid,memuid=memuid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("拒绝成员的申请",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 取消申请
-- 参数：
-- int aid 申请的军团id 
-- int joinuid 申请人的uid，如果无，则是全部拒绝
function socketHelper:allianceCanceljoin(aid,joinuid,callback)
    local tb={}
    tb["cmd"]="alliance.canceljoin"
    tb["params"]={aid=aid,joinuid=joinuid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("取消申请",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 修改工会信息   返回更新后的军团信息
-- 参数：
-- int aid 军团id 
-- string internalNotice 内部公告
-- string foreignNotice 外部公告
-- int joinNeedLv 加入需要的等级
-- int joinNeedFc 加入需要的战斗力
-- int joinType 0是自由加入，1是需要审批
function socketHelper:allianceEdit(aid,internalNotice,foreignNotice,joinNeedLv,joinNeedFc,joinType,callback)
    local tb={}
    tb["cmd"]="alliance.edit"
    tb["params"]={aid=aid,internalNotice=internalNotice,foreignNotice=foreignNotice,joinNeedLv=joinNeedLv,joinNeedFc=joinNeedFc,joinType=joinType}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("修改工会信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--批准成员加入
--参数：
--int aid 军团id
--int memuid 申请人id
function socketHelper:allianceAccept(aid,memuid,callback)
    local tb={}
    tb["cmd"]="alliance.accept"
    tb["params"]={aid=aid,memuid=memuid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("批准成员加入",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--军团信息Get
function socketHelper:allianceGet(aid,updated_at,callback,isWaitting)
    local tb={}
    tb["cmd"]="alliance.get"
    tb["params"]={aid=aid,updated_at=updated_at}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团信息Get",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isWaitting)
end

-- 军团邮件
-- int aid 军团id 
-- string subject 标题
-- string content 邮件内容
function socketHelper:allianceMail(aid,subject,content,callback)
    local tb={}
    tb["cmd"]="alliance.mail"
    tb["params"]={aid=aid,subject=subject,content=content}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团邮件",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


-- 军团捐献
-- int aid 军团id 
-- string sid 技能标识（s1,s2.... 如果是军团，直接传字串 alliance）
-- int count 第几次捐献 (当前捐献次数+1)
-- int consumeType 使用资源类型 1是资源，2是金币
-- string rname 捐献用的资源类型（r1-r4，gold）如果是金币代付，需要以此确认使用的资源类型
function socketHelper:allianceDonate(aid,sid,count,consumeType,rname,callback)
    local tb={}
    tb["cmd"]="alliance.donate"
    tb["params"]={aid=aid,sid=sid,count=count,consumeType=consumeType,rname=rname}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团捐献",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


-- 军团事件
-- int page 军团事件页数
function socketHelper:allianceGetevents(page,callback)
    local tb={}
    tb["cmd"]="alliance.getevents"
    tb["params"]={page=page}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团事件",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


-- 获取协防部队兵力
-- uid
-- cronid   部队编号
function socketHelper:troopGethelpdefense(cronid,uid,callback)
    local tb={}
    tb["cmd"]="troop.gethelpdefense"
    tb["params"]={cronid=cronid,uid=uid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获取协防部队兵力",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 设置协防部队
-- cmd: troop.sethelpdefense
-- 参数：uid , cronid(部队编号)
function socketHelper:troopSethelpdefense(cronid,uid,callback)
    local tb={}
    tb["cmd"]="troop.sethelpdefense"
    tb["params"]={cronid=cronid,uid=uid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("设置协防部队",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 签到
-- params addSign 1 如果为1表示补签，否则视为放弃
function socketHelper:userSign(addSign,callback)
    local tb={}
    tb["cmd"]="user.sign"
    tb["params"]={addSign=addSign}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("签到",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 领取累积签到奖励
function socketHelper:userSignaward(callback)
    local tb={}
    tb["cmd"]="user.signaward"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领取累积签到奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getActivityList(callback,isShowLoading)
    local tb={}
    tb["cmd"]="active.list"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("活动配置list",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end
-- 军团副本列表
function socketHelper:achallengeGet(callback)
    local tb={}
    tb["cmd"]="achallenge.get"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团副本列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:activityFinished(type,callback)
    local tb={}
    tb["cmd"]="active.finish"
    tb["params"]={aname = type}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
    
end
-- 军团副本关卡
-- minsid 起始关卡id
-- maxsid 最末关卡id
function socketHelper:achallengeList(minsid,maxsid,callback)
    local tb={}
    tb["cmd"]="achallenge.list"
    tb["params"]={minsid=minsid,maxsid=maxsid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团副本关卡",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getNoteList(callback)
    local tb={}
    tb["cmd"]="notice.list"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:noteRead(nid,callback)
    local tb={}
    tb["cmd"]="notice.read"
    tb["params"]={nid = nid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 坦克抽奖活动
-- int action  1/2 1表示抽奖，2表示改装
-- int part    part 1/2 两种碎片
-- int num     抽奖次数
function socketHelper:activeMoscowgambling(action,part,num,callback)
    local tb={}
    tb["cmd"]="active.moscowgambling"
    tb["params"]={action=action,part=part,num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("坦克抽奖活动",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
function socketHelper:activeMoscowgamblingGai(action,part,num,callback)
    local tb = {}
    tb["cmd"]="active.moscowgamblinggai"
    tb["params"]={action=action,part=part,num=num}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("莫斯科的赌局改，",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 军团副本关卡领奖
-- sid 关卡id
function socketHelper:achallengeGetreward(sid,callback)
    local tb={}
    tb["cmd"]="achallenge.getreward"
    tb["params"]={sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团副本关卡领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 军团副本战斗
function socketHelper:achallengeBattle(data,callback)
    local tb={}
    tb["cmd"]="achallenge.battle"
    tb["params"]=data
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团副本战斗",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getFriendGift(gid,callback)
    local tb={}
    tb["cmd"]="giftbag.dailyfriend"
    tb["params"]={gid=gid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--韩国交叉广告，随机礼包
function socketHelper:getrandomgift(callback)
    local tb={}
    tb["cmd"]="giftbag.addrandomgift"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("韩国交叉广告，随机礼包",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


function socketHelper:getFbRewardRankList(callback)
    local tb={}
    tb["cmd"]="achallenge.unlockranking"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("冲击副本赢好礼",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


function socketHelper:getFbReward(rank,callback)
    local tb={}
    tb["cmd"]="active.fbreward"
    tb["params"]={rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("冲击副本赢好礼领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--序列号 礼包兑换
--参数：int card 卡号
function socketHelper:giftbagGet(card,callback)
    local tb={}
    --如果是微信礼包的话调用另外一个接口
    if(card and string.find(card,"TKWX-")==1)then
        tb["cmd"]="giftbag.wxget"
    else
        tb["cmd"]="giftbag.get"
    end
    tb["params"]={card=card}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("礼包兑换",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--公告领奖
--nid 公告id
function socketHelper:noticeReward(nid,callback)
    local tb={}
    tb["cmd"]="notice.reward"
    tb["params"]={nid=nid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("公告领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


function socketHelper:getDayRechargeReward(callback)
    local tb={}
    tb["cmd"]="active.dayrecharge"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("每日充值领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军备升级
function socketHelper:getDayRechargeForequipReward(callback)
    local tb={}
    tb["cmd"]="active.dayrechargeforequip"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军备升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- todo 开服七日战力大比拼 的后台交互接口
function socketHelper:getFightRankList(sIndex,eIndex,callback)
    local tb={}
    tb["cmd"]="active.fightrank"
    tb["params"]={sIndex = sIndex, eIndex = eIndex}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("开服七日战力大比拼排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


function socketHelper:getFightReward(rank,callback)
    local tb={}
    tb["cmd"]="active.fightrankreward"
    tb["params"]={rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("开服七日战力大比拼领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getBaseLevelingReward(level,callback)
    local tb={}
    tb["cmd"]="active.baselevelreward"
    tb["params"]={level=level}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新手冲级送礼领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 幸运转盘
-- 参数：
-- int action 1为抽奖，2为拉取排行列表,3为领取积分奖励（直接领取）
-- int rank 排名领奖名次
function socketHelper:activeWheelfortune(action,callback,rank)
    local tb={}
    tb["cmd"]="active.wheelfortune"
    tb["params"]={action=action,rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("幸运转盘",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--真情回馈 抽奖信息
--参数：
--action:reward 
--num:1或是10 抽奖次数
function socketHelper:activeZhenqinghuikui( aCtion,nUm ,callback)
    local tb = {}
    tb["cmd"]="active.zhenqinghuikui"
    tb["params"]={action=aCtion,num=nUm}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("真情回馈 抽奖申请",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--真情回馈 每日刷新免费次数
--参数：
function  socketHelper:activeZhenqinghuikuiRefreshTime(aCtion,callback)
    local tb = {}
    tb["cmd"]="active.zhenqinghuikui"
    tb["params"]={action=aCtion}
    self:addBaseInfo(tb)
    local  requestStr = G_Json.encode(tb)
    print("真情回馈 刷新免费次数",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- --真情回馈 获奖列表
function socketHelper:activeZhenqinghuikuiList( lIst,callback )
    local tb = {}
    tb["cmd"]="active.zhenqinghuikui"
    tb["params"]={action=lIst}
    self:addBaseInfo(tb)
    local  requestStr = G_Json.encode(tb)
    print("真情回馈 获奖列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 坦克轮盘
-- 参数：
-- int action 1为抽奖,2为领取在线时间奖励的抽奖次数,3为查看领奖名单
-- num：1或10 次数
function socketHelper:activeWheelfortune4(action,num,callback,useProp)
    local tb={}
    tb["cmd"]="active.wheelfortune4"
    tb["params"]={action=action,num=num,useProp=useProp}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("坦克轮盘",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 幸运转盘
-- 参数：
-- int action 1为抽奖，2为拉取排行列表,3为领取积分奖励（直接领取）,5十连抽
-- int rank 排名领奖名次
function socketHelper:activeWheelfortune2(action,callback,rank)
    local tb={}
    tb["cmd"]="active.wheelfortune2"
    tb["params"]={action=action,rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("幸运转盘2",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 幸运转盘
-- 参数：
-- int action 1为抽奖，2为拉取排行列表,3为领取积分奖励（直接领取）,5十连抽
-- int rank 排名领奖名次
function socketHelper:activeWheelfortune3(action,callback,rank)
    local tb={}
    tb["cmd"]="active.wheelfortune3"
    tb["params"]={action=action,rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("转盘之约",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--改名
function socketHelper:userRename(nickname,pic,callback,isRenameCard)
    local tb={}
    tb["cmd"]="user.rename"
    tb["params"]={nickname=nickname,pic=pic,usep=isRenameCard}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("改名",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end





function socketHelper:getAllianceLevelList(allianceId,callback)
    local tb={}
    tb["cmd"]="active.alliancelevelrank" -- todo 
    tb["params"]={aid = allianceId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团冲级排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getAllianceLevelReward(rank,callback)
    local tb={}
    tb["cmd"]="active.alliancelevelreward" -- todo 
    tb["params"]={rank = rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团冲级排行榜奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getAllianceFightList(allianceId,callback)
    local tb={}
    tb["cmd"]="active.alliancefightrank" -- todo 
    tb["params"]={aid=allianceId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团战力争霸",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getAllianceFightReward(rank, callback)
    local tb={}
    tb["cmd"]="active.alliancefightreward" -- todo 
    tb["params"]={rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团战力争霸奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
function socketHelper:getPersonalHonorList(callback)
    local tb={}
    tb["cmd"]="active.personalhonorrank" -- todo 
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("个人荣誉排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getPersonalHonorReward(rank,callback)
    local tb={}
    tb["cmd"]="active.personalhonorreward" -- todo 
    tb["params"]={rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("个人荣誉排行榜奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getPersonalCheckPointList(callback)
    local tb={}
    tb["cmd"]="active.personalcheckrank"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("个人关卡排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])

end

function socketHelper:getPersonalCheckPointReward(rank,callback)
    local tb={}
    tb["cmd"]="active.personalcheckreward"
    tb["params"]={rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("个人关卡排行榜奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getTotalRechargeReward(callback)
    local tb={}
    tb["cmd"]="active.totalrecharge"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("累计充值领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getTotalRecharge2Reward(callback)
    local tb={}
    tb["cmd"]="active.totalrecharge2"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("累计充值领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--获取所有配件的信息
function socketHelper:getAllAccesory(callback,isShowLoading)
    local tb={}
    tb["cmd"]="accessory.list"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end

--穿配件
--param id: 要穿上的配件的id
function socketHelper:wareAccessory(id,callback)
    local tb={}
    tb["cmd"]="accessory.useaccessory"
    tb["params"]={eid=id}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--脱配件
--param tankID: 脱下配件的坦克
--param partID: 脱下配件的部位
function socketHelper:takeoffAccessory(tankID,partID,callback)
    local tb={}
    tb["cmd"]="accessory.removeaccessory"
    tb["params"]={type=tankID,ptype=partID}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--强化配件
--param tankID: 强化的配件所在的坦克id
--param partID: 强化的配件所在的部位id
--param aID: 如果强化的是背包里面的配件, 那么就传这个id
--param amuletNum: 使用的神符的数目
function socketHelper:upgradeAccessory(tankID,partID,aID,amuletNum,callback)
    local tb={}
    tb["cmd"]="accessory.upgradeaccessory"
    if(tankID~=nil)then
        tb["params"]={type=tankID,ptype=partID}
    else
        tb["params"]={aid=aID}
    end
    if(amuletNum~=nil and amuletNum>0)then
        tb["params"]["use"]=amuletNum
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--param tankID: 精炼的配件所在的坦克id
--param partID: 精炼的配件所在的部位id
--param aID: 如果精炼的是背包里面的配件, 那么就传这个id
--param useAmulet: 是否使用保级符,true or false
function socketHelper:smeltAccesory(tankID,partID,aID,useAmulet,callback)
    local tb={}
    tb["cmd"]="accessory.refineaccessory"
    if(tankID~=nil)then
        tb["params"]={type=tankID,ptype=partID}
    else
        tb["params"]={aid=aID}
    end
    if(useAmulet~=nil and useAmulet==true)then
        tb["params"]["use"]=1
    else
        tb["params"]["use"]=0
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--出售配件
--param type: 1是单个出售, 2是批量出售
--param param: type=1的时候是配件ID, eg: a8668064; type=2的时候是一个品质table, eg: {1,2}
function socketHelper:sellAccessory(type,param,callback)
    local tb={}
    tb["cmd"]="accessory.resolveaccessory"
    if(type==1)then
        tb["params"]={type=type,aid=param}
    else
        tb["params"]={type=type,quality=param}
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--出售碎片
--param type: 1是单个出售, 2是批量出售
--param param: type=1的时候是配件ID, eg: a8668064; type=2的时候是一个品质table, eg: {1,2}
function socketHelper:sellAccessoryFragment(type,param,callback)
    local tb={}
    tb["cmd"]="accessory.resolvefragment"
    if(type==1)then
        tb["params"]={type=type,fid=param}
    else
        tb["params"]={type=type,quality=param}
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--碎片合成配件
--param id: 要合成的碎片的id
--param useMulti: 是否使用万能碎片
function socketHelper:composeAccessory(id,useMulti,callback)
    local tb={}
    tb["cmd"]="accessory.upgradefragment"
    tb["params"]={fid=id}
    if(useMulti)then
        tb["params"].use=1
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--精英关卡列表
function socketHelper:echallengeList(callback)
    local tb={}
    tb["cmd"]="echallenge.list"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("精英关卡列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 攻打精英关卡
-- 参数：
-- fleetinfo  table 派出的舰队信息 -- [坦克id：数量],[坦克id：数量],...... 如果该位置是空，则用空table {} 占位
-- defender string  s1 关卡id
function socketHelper:echallengeBattle(data,callback)
    local tb={}
    tb["cmd"]="echallenge.battle"
    tb["params"]=data
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("攻打精英关卡",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 重置精英关卡
function socketHelper:echallengeReset(callback)
    local tb={}
    tb["cmd"]="echallenge.reset"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("重置精英关卡",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 精英关卡扫荡
-- eid 需要扫荡的关卡列表
function socketHelper:echallengeRaid(callback,eid)
    local tb={}
    tb["cmd"]="echallenge.raid"
    tb["params"]={eid=eid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("精英关卡扫荡",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--水晶丰收周活动 active.crystalHarvest
function socketHelper:activeCrystalHarvest(callback)
    local tb={}
    tb["cmd"]="active.crystalharvest"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("水晶丰收周活动",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--明日战力暴增领取 user.nextdayreward
function socketHelper:userNextdayReward(callback)
    local tb={}
    tb["cmd"]="user.nextdayreward"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("明日战力暴增领取",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 配件探索
-- 参数：
-- int action 1为探索，2为拉取排行列表,3为领取积分奖励（直接领取）
-- int num 探索：1为1次，10为10次
function socketHelper:activeEquipsearch(action,callback,num,rank)
    local tb={}
    tb["cmd"]="active.equipsearch"
    tb["params"]={action=action,num=num,rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("配件探索",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--卡夫卡秘密 配置3  "params":{"activeName":"equipSearchII","dtype":1}}
function socketHelper:activeTreasureOfKafukaRecord(callback)
    local tb = {}
    tb["cmd"]="active.getrecordlist"
    tb["params"]={activeName="equipSearchII",dtype=1}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("卡夫卡的秘密—配置3",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 充值返利
function socketHelper:activeRechargerebate(callback)
    local tb={}
    tb["cmd"]="active.rechargerebate"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("充值返利",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 军团弹劾 alliance.impeach
function socketHelper:allianceImpeach(memuid,aid,callback)
    local tb={}
    tb["cmd"]="alliance.impeach"
    tb["params"]={memuid=memuid,aid=aid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团弹劾",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 军团晋升 alliance.promotion
function socketHelper:alliancePromotion(role,aid,callback)
    local tb={}
    tb["cmd"]="alliance.promotion"
    tb["params"]={role=role,aid=aid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团晋升",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 巨兽再现活动
-- int action   1/2 1表示抽奖，2表示改装
-- int part     part 1/2 两种碎片
-- int num      抽奖次数
-- int usePoint 1为使用分数抽奖
function socketHelper:activeMonsterComeback(action,part,num,callback,usePoint)
    local tb={}
    tb["cmd"]="active.monstercomeback"
    tb["params"]={action=action,part=part,num=num,usePoint=usePoint}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("巨兽再现活动",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:activeReturnInit(callback)
    local tb={}
    tb["cmd"]="active.olduserreturn"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:activeReturnGetReward(type,callback)
    local tb={}
    tb["cmd"]="active.olduserreturnreward"
    tb["params"]={tid=type}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:activeAccessoryUpgradeBuy(callback)
    local tb={}
    tb["cmd"]="active.accessoryevolution"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:activeAllianceDonateGetList(paramAid,callback)
    local tb={}
    tb["cmd"]="active.alliancedonaterank"
    tb["params"]={aid=paramAid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:activeAllianceDonateGetReward(paramRank,callback)
    local tb={}
    tb["cmd"]="active.alliancedonatereward"
    tb["params"]={rank=paramRank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--每档充值双倍的接口
--param paramAction: 要进行什么操作, 1是初始化数据, 2是领奖
--param id: 要领取的档次id, 格式是"p"+购买的金币数
function socketHelper:getRechargeDouble(paramAction,id,callback)
    local tb={}
    tb["cmd"]="active.rechargedouble"
    tb["params"]={action=paramAction}
    if(id)then
        tb["params"]["cost"]=id
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 成长计划：购买成长计划
function socketHelper:buyGrowingPlan(callback)
    local tb={}
    tb["cmd"]="user.buygrow"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("购买成长计划",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--获取军团的报名和占领信息
--param paramAid: 军团的ID
function socketHelper:allianceWarGetInfo(paramAid,callback)
    local tb={}
    tb["cmd"]="alliance.getapply"
    tb["params"]={aid=paramAid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--获取某个城市的军团战信息
--param cityID: 要获取信息的城市ID
function socketHelper:allianceWarGetCityInfo(paramAid,cityID,callback)
    local tb={}
    tb["cmd"]="alliance.applyrank"
    tb["params"]={aid=paramAid,areaid=cityID}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--报名军团据点战
--param paramAid: 报名的军团ID
--param funds: 报名投拍的军团资金数
--param cityID: 投标的城市ID
function socketHelper:allianceWarSignUp(paramAid,funds,cityID,callback)
    local tb={}
    tb["cmd"]="alliance.apply"
    tb["params"]={aid=paramAid,point=funds,areaid=cityID}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--军团战，参战
--param paramAid: 参战玩家的军团ID
function socketHelper:allianceWarJoinBattle(paramAid,callback)
    local tb={}
    tb["cmd"]="alliance.joinline"
    tb["params"]={aid=paramAid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 成长计划：领取奖励
-- 参数：level:领取奖励所需的玩家等级
function socketHelper:growingPlanReward(lv,callback)
    local tb={}
    tb["cmd"]="user.growreward"
    tb["params"]={level=lv}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("成长计划：领取奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 军团战购买BUFF
function socketHelper:alliancewarBuybuff(buff,callback)
    local tb={}
    tb["cmd"]="alliancewar.buybuff"
    tb["params"]={buff=buff}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团战购买BUFF",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 军团战重新集结 placeId 小地点 [1-9] postionId 大战场 [1-8]
function socketHelper:alliancewarRegroup(placeId,positionId,callback)
    local tb={}
    tb["cmd"]="alliancewar.regroup"
    tb["params"]={placeId=placeId,positionId=positionId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团战重新集结",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 军团战获取战场信息 positionId 大战场 [1-8]
function socketHelper:alliancewarGet(positionId,callback)
    local tb={}
    tb["cmd"]="alliancewar.get"
    tb["params"]={positionId=positionId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团战获取战场信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 军团战战斗 placeId 小地点 [1-9] positionId 大战场 [1-8] useGem 是否直接金币直接战斗 fleetinfo 部队信息，与其它战斗格式一样
function socketHelper:alliancewarBattle(placeId,positionId,useGem,fleetinfo,callback,hero)
    local tb={}
    tb["cmd"]="alliancewar.battle"
    tb["params"]={placeId=placeId,positionId=positionId,useGem=useGem,fleetinfo=fleetinfo,hero=hero}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团战斗",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 军团战成员列表
-- 参数：aid：军团id
function socketHelper:allianceGetqueue(aid,callback)
    local tb={}
    tb["cmd"]="alliance.getqueue"
    tb["params"]={aid=aid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团战成员列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 军团战上下阵
-- 参数：aid：军团id，memuid：成员uid，type：1上阵 2下阵，q：位置 q15
function socketHelper:allianceUpdatequeue(aid,memuid,type,q,callback)
    local tb={}
    tb["cmd"]="alliance.updatequeue"
    tb["params"]={aid=aid,memuid=memuid,type=type,q=q}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团战上下阵",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 军团战加速集结
function socketHelper:alliancewarBuycdtime(callback)
    local tb={}
    tb["cmd"]="alliancewar.buycdtime"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团战加速集结",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 军团战10秒请求
function socketHelper:alliancewarGetwarpoint(positionId,callback,isShowLoading)
    local tb={}
    tb["cmd"]="alliancewar.getwarpoint"
    tb["params"]={positionId=positionId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团战10秒请求",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end


-- 军团战报
function socketHelper:allianceGetbattlelog(warid,type,aid,uid,minTs,maxTs,callback)
    local tb={}
    tb["cmd"]="alliance.getbattlelog"
    tb["params"]={warid=warid,type=type,aid=aid,uid=uid,minTs=minTs,maxTs=maxTs}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团战报",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--获取军团商店的商店数据
--param type: 类型, 1为获取个人商店的数据, 2为获取全军团珍品的数据
function socketHelper:allianceShopGetData(paramType,callback)
    local tb={}
    tb["cmd"]="alliance.getshop"
    tb["params"]={type=paramType}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 配件探索II期
-- 参数：
-- int action 1为探索，2为拉取排行列表,3为领取积分奖励（直接领取）
-- int num 探索：1为1次，10为10次
function socketHelper:activeEquipsearchII(action,callback,num,rank)
    local tb={}
    tb["cmd"]="active.equipsearchii"
    tb["params"]={action=action,num=num,rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("配件探索",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--购买军团商店的商品
--param type: 类型, 1为购买个人商品, 2为购买全军团珍品
--param id: 要购买的商品ID
--param index: 因为军团珍品有可能刷出两件相同的商品来，所以需要另外一个字段来区分一下
function socketHelper:allianceShopBuyItem(paramType,paramID,index,callback)
    local tb={}
    tb["cmd"]="alliance.buyshop"
    tb["params"]={type=paramType,id=paramID}
    if(index)then
        tb["params"].slot=index
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 收获日军团战活动获取数据
function socketHelper:activeHarvestday(callback)
    local tb={}
    tb["cmd"]="active.harvestday"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("收获日数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 收获日军团战活动领奖
function socketHelper:activeHarvestdayReward(rank,join,win,callback)
    local tb={}
    tb["cmd"]="active.harvestdayreward"
    tb["params"]={rank=rank,join=join,win=win}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("收获日领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 钢铁之心领奖
--method,1主基地等级,2玩家等级,3配件,4军团副本,5关卡星星,6科技任务,7坦克任务
function socketHelper:activeHeartofironReward(method,callback)
    local tb={}
    tb["cmd"]="active.heartofironreward"
    tb["params"]={method=method}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("钢铁之心领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 基金计划充值奖励
function socketHelper:activeUserfund(callback)
    local tb={}
    tb["cmd"]="active.userfund"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("基金计划充值奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 基金计划额外返还奖励
function socketHelper:activeUserfundreward(callback)
    local tb={}
    tb["cmd"]="active.userfundreward"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("基金计划返还奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getOnlinePackage(cd,callback)
    local tb={}
    tb["cmd"]="user.onlinereward"
    tb["params"]={cd = cd}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领取在线礼包",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:activeTenDaysReward(day,callback)
    local tb={}
    tb["cmd"]="active.tendayslogin"
    tb["params"]={day=day}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getVipActionReward(total,num,callback)
    local tb={}
    tb["cmd"]="active.vipactionreward"
    tb["params"]={total=total,num=num} --total== 1 代表领取累计充值的奖励，0代表领取每日充值的奖励 num 代表领取的是每日充值的第几档奖励
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("vip总动员领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 投资计划领取奖励
function socketHelper:activeInvestplan(callback)
    local tb={}
    tb["cmd"]="active.investplan"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("投资计划领取奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


-- 勤劳致富获取排行榜 "rid":"r1" "r2" "r3" "r4" "gold"
function socketHelper:activeHardgetrichrank(rid,callback)
    local tb={}
    tb["cmd"]="active.hardgetrichrank"
    tb["params"]={rid=rid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("勤劳致富获取排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--领取个人目标奖励请求串 "rid":"r1","method":1
function socketHelper:activeHardgetrich(rid,method,callback)
    local tb={}
    tb["cmd"]="active.hardgetrich"
    tb["params"]={rid=rid,method=method}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领取个人目标奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--领取排行榜奖励
function socketHelper:activeHardgetrichRank(rid,rank,callback)
    local tb={}
    tb["cmd"]="active.hardgetrich"
    tb["params"]={rid=rid,rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领取排行榜奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--获取用户采集量
function socketHelper:activeGethardgetrich(callback)
    local tb={}
    tb["cmd"]="active.gethardgetrich"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获取用户采集量",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--获取自己军事演习数据
function socketHelper:militaryGet(callback)
    local tb={}
    tb["cmd"]="military.get"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获取自己军事演习数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--设置军事演习部队镜像
function socketHelper:militarySettroops(fleetinfo,callback,hero,emblemID,planePos,aitroops,airshipId)
    local tb={}
    tb["cmd"]="military.settroops"
    tb["params"]={fleetinfo=fleetinfo,hero=hero,equip=emblemID,plane=planePos,at=aitroops,ap=airshipId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("设置军事演习部队镜像",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--获取军事演习前100的排行榜
function socketHelper:militaryRanklist(callback)
    local tb={}
    tb["cmd"]="military.ranklist"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获取军事演习前100的排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--军事演习购买时间和购买攻击次数 buy =1 是购买时间  =2 是购买次数
function socketHelper:militaryBuy(buy,callback)
    local tb={}
    tb["cmd"]="military.buy"
    tb["params"]={buy=buy}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军事演习购买时间和购买攻击次数",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--领取开服献礼的免费礼品（水晶）或 获取开服献礼的折扣信息
function socketHelper:getOpenGift(callback,action)--action: 为1的时候是请求今日可购买物品，为2时领取赠送的水晶
    local tb={}
    tb["cmd"]="active.opengift"
    tb["params"]={action=action}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    if action == 1 then
       print("获取开服献礼的折扣信息",requestStr)
    elseif action == 2 then
       print("领取开服献礼的免费礼品（水晶）",requestStr)
    end
    
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--军事演习攻击
function socketHelper:militaryBattle(rank,callback)
    local tb={}
    tb["cmd"]="military.battle"
    tb["params"]={rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军事演习攻击",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--飓风来袭活动
--param action: 操作类型，1为抽奖 2为合成坦克 3为购买碎片
--param data: 要传给后台的参数，是一个table
function socketHelper:activeStormRocket(action,data,callback)
    local tb={}
    tb["cmd"]="active.stormrocket"
    tb["params"]={action=action}
    for k,v in pairs(data) do
        tb["params"][k]=v
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军事演习领取排名奖励
function socketHelper:militaryGetreward(callback)
    local tb={}
    tb["cmd"]="military.getreward"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军事演习领取排名奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--军事演习战报列表
function socketHelper:militaryGetlog(mineid,maxeid,isPage,callback,ifShowLoading,content)
    local tb={}
    tb["cmd"]="military.getlog"
    tb["params"]={mineid=mineid,maxeid=maxeid,content=content}
    if isPage~=nil then
        tb["params"].isPage=isPage
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军事演习战报列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],ifShowLoading)
end

-- 军事演习战报优化后单独请求content
function socketHelper:militaryGetContent(eid,callback)
    local tb={}
    tb["cmd"]="military.report"
    tb["params"]={eid=eid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军事演习 战报content",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军事演习读战报
function socketHelper:militaryRead(eid,callback)
    local tb={}
    tb["cmd"]="military.read"
    tb["params"]={eid=eid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军事演习读战报",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军事演习幸运榜
function socketHelper:militaryGetluckrank(callback)
    local tb={}
    tb["cmd"]="military.getluckrank"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军事演习幸运榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军事演习删除战报
function socketHelper:militaryDelete(eid,callback)
    local tb={}
    tb["cmd"]="military.delete"
    tb["params"]={eid=eid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军事演习删除战报",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--评价给礼包
function socketHelper:userEvaluate(callback)
    local tb={}
    tb["cmd"]="user.evaluate"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("评价给礼包",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:buyGrabRedBox(callback)
    local tb={}
    tb["cmd"]="active.buyredbag"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("购买抢红包宝箱",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


function socketHelper:getRedInformation(redid, callback)
    local tb={}
    tb["cmd"]="active.grabredbaglog"
    tb["params"]={redid=redid} -- id 红包id
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获取红包详细信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:grabRed(redid, callback)
    local tb={}
    tb["cmd"]="active.grabredbag"
    tb["params"]={redid=redid} -- id 红包id
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("抢红包",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end



function socketHelper:getArmsRaceRecode(callback)
    local tb={}
    tb["cmd"]="active.getarmsracelog"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获取军备竞赛的领奖记录信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getArmsRaceReward(rid,callback)
    local tb={}
    tb["cmd"]="active.getarmsracereward"
    tb["params"]={rid=rid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获取军备竞赛的领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getSlotMachineReward(free,num, callback)
    local tb={}
    tb["cmd"]="active.soltmachine"
    tb["params"]={free=free,num=num} -- num 代表是否选择了倍数设置
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("老虎机抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getSlotMachine2Reward(free,num, callback)
    local tb={}
    tb["cmd"]="active.soltmachine2"
    tb["params"]={free=free,num=num} -- num 代表是否选择了倍数设置
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("老虎机2抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getSlotMachineCommonReward(free,num, callback)
    local tb={}
    tb["cmd"]="active.soltmachine3"
    tb["params"]={free=free,num=num} -- num 代表是否选择了倍数设置
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("老虎机3-8抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 得到分享列表（有福同享）
function socketHelper:getShareHappinessList(callback)
    local tb={}
    tb["cmd"]="active.sharehappiness"
    tb["params"]={action="getList"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("得到有福同享活动的分享列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 领取礼包（有福同享）
function socketHelper:getShareHappinessAllGifts(callback)
    local tb={}
    tb["cmd"]="active.sharehappiness"
    tb["params"]={action="getShare"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领取有福同享活动的所有礼包",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--facebook相关的操作
--param action: "user"表示领取Facebook用户登录奖励, "invitation"表示获取游戏好友数目的奖励, "dailyFirst"表示获取每日邀请好友奖励, "facebookUserinfo"表示获取某个Facebook账号的领奖信息
--param index: 要领取的是哪一档的奖励, 只有在action为invitation的时候有用
--param facebookID: 玩家的Facebook ID, 领奖还有获取领奖信息的时候要用
function socketHelper:getFacebookReward(action,index,facebookID,callback)
    local tb={}
    tb["cmd"]="user.facebook"
    tb["params"]={action=action}
    if(action=="invitation")then
        tb["params"]["category"]=index
    end
    if(facebookID)then
        tb["params"]["facebookid"]=facebookID
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--坚守阵地领奖
function socketHelper:activeHoldground(num,callback)
    local tb={}
    tb["cmd"]="active.holdground"
    tb["params"]={num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("坚守阵地领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--秘宝探寻拼合
function socketHelper:miBaoPinHe(callback)
    local tb={}
    tb["cmd"]="active.mibao"
    tb["params"]={action="getOldMap"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("秘宝探寻拼合",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--
--军团资金招募
function socketHelper:activeFundsRecruit(str,callback)
    local tb={}
    tb["cmd"]="active.fundsrecruit"
    tb["params"]={action=str}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("资金招募",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--月卡领奖
function socketHelper:getMonthlyCardReward(callback)
    local tb={}
    tb["cmd"]="user.mcreward"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:continueRechargeRevise(day,callback)
    local tb={}
    tb["cmd"]="active.continuerecharge"
    tb["params"]={action="modify",day=day}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("连续充值送礼-修改充值记录",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
function socketHelper:getContinueRechargeReward(callback)
    local tb={}
    tb["cmd"]="active.continuerecharge"
    tb["params"]={action="getReward"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("连续充值送礼",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--满载而归领取奖励
function socketHelper:activeRewardingBack(callback)
    local tb={}
    tb["cmd"]="active.rewardingback"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("满载而归",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


function socketHelper:getLevelingReward(action,callback)
    local tb={}
    tb["cmd"]="active.leveling"
    tb["params"]={action=action}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("冲级三重奏领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getLeveling2Reward(action,callback)
    local tb={}
    tb["cmd"]="active.leveling2"
    tb["params"]={action=action}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("冲级三重奏领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--首次加入军团领奖
function socketHelper:allianceOncereward(callback)
    local tb={}
    tb["cmd"]="alliance.oncereward"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("首次加入军团领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--新兵军饷领奖
function socketHelper:activeHoldground1(num,callback)
    local tb={}
    tb["cmd"]="active.holdground1"
    tb["params"]={num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新兵军饷领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--中秋狂欢开宝箱
function socketHelper:activeAutumnCarnivalOpen(bid,callback)
    local tb={}
    tb["cmd"]="active.autumncarnival"
    tb["params"]={bid=bid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("中秋狂欢开宝箱",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:callsRecharge(phoneNum,callback)
    local tb={}
    tb["cmd"]="active.calls"
    tb["params"]={phoneNum=phoneNum}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("战地通讯充值",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getCallsStatus(tradeId,callback)
    local tb={}
    tb["cmd"]="active.calls"
    tb["params"]={tradeId=tradeId,action="search"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获得战地通讯的订单状态",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- num 兑换次数 1还是10
function socketHelper:getNewTechReward(action, pid, num,callback)
    local tb={}
    tb["cmd"]="active.newtech"
    tb["params"]={action=action, pid = pid, num = num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("技术革新兑换奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--邮件领奖
function socketHelper:mailReward(type, mid,callback)
    local tb={}
    tb["cmd"]="mail.reward"
    tb["params"]={type=type, mid=mid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("邮件领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--共和国之辉 组装坦克
function socketHelper:activeRepublicHuiCompose(callback)
    local tb={}
    tb["cmd"]="active.republichui"
    tb["params"]={action="combine"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("共和国之辉 组装坦克",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--共和国之辉 抽奖
function socketHelper:activityRepublicHuiReward(type,callback)
    local tb={}
    tb["cmd"]="active.republichui"
    tb["params"]={action="rand",type=type}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("共和国之辉 抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--国庆攻势 随机抽取限时售卖道具
function socketHelper:activityNationalCampaignProp(callback)
    local tb={}
    tb["cmd"]="active.nationalcampaign"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("国庆攻势 随机抽取限时售卖道具",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--关卡领取奖励
-- sid 章节 
-- category 领取奖励类型 取值范围1-3对应配置里的每章第1-3个的奖励
function socketHelper:challengeGetreward(sid,category,callback)
    local tb={}
    tb["cmd"]="challenge.getreward"
    tb["params"]={sid=sid,category=category}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("关卡领取奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--已经领取的奖励列表
function socketHelper:challengeRewardlist(callback)
    local tb={}
    tb["cmd"]="challenge.rewardlist"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("已经领取的奖励列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

----------个人跨服战-----------
--个人跨服战设置部队
--line：1，2，3场次部队 fleetinfo：部队
function socketHelper:crossSetInfo(line,fleetinfo,aName,hero,clear,callback,emblemID,planePos,aitroops,airshipId)
    local tb={}
    tb["cmd"]="cross.setinfo"
    tb["params"]={line=line,fleetinfo=fleetinfo,aName=aName,hero=hero,clear=clear,equip=emblemID,plane=planePos,at=aitroops,ap=airshipId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("个人跨服战设置部队",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--个人跨服战获取设置的部队
function socketHelper:crossGetInfo(callback)
    local tb={}
    tb["cmd"]="cross.getinfo"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("个人跨服战部队",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--个人跨服战初始化数据
function socketHelper:crossInit(callback)
    local tb={}
    tb["cmd"]="cross.crossinit"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("个人跨服战初始化数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--个人跨服战获取赛程表
function socketHelper:crossSchedule(callback)
    local tb={}
    tb["cmd"]="cross.schedule"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("个人跨服战获取赛程表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--个人跨服战献花
-- matchId，本期跨服战id "matchId":"4278_1"
-- detailId，matchId_分组赛or淘汰赛_第几轮_胜者组or败者组_a or b or c..... "detailId":"4278_1_1_1_1_a"
-- joinUser，参赛用户Id
function socketHelper:crossBet(matchId,detailId,joinUser,callback)
    local tb={}
    tb["cmd"]="cross.bet"
    tb["params"]={matchId=matchId,detailId=detailId,joinUser=joinUser}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("个人跨服战献花",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--领取押注奖励
-- matchId，本期跨服战id "matchId":"4278_1"
-- detailId，matchId_分组赛or淘汰赛_第几轮_胜者组or败者组_a or b or c..... "detailId":"4278_1_1_1_1_a"
function socketHelper:crossGetbetreward(matchId,detailId,callback)
    local tb={}
    tb["cmd"]="cross.getbetreward"
    tb["params"]={matchId=matchId,detailId=detailId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领取押注奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--购买物品
-- matchId，本期跨服战id "matchId":"4278_1"
-- sType，"pShopItems" or aShopItems 普通商店或者精品商店
-- tId，对应配置表的下标Id
function socketHelper:crossBuy(matchId,sType,tId,callback)
    local tb={}
    tb["cmd"]="cross.buy"
    tb["params"]={matchId=matchId,sType=sType,tId=tId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("购买物品",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--积分明细记录
-- matchId，本期跨服战id "matchId":"4278_1"
-- sType，"pShopItems" or aShopItems 普通商店或者精品商店
-- tId，对应配置表的下标Id
function socketHelper:crossRecord(callback)
    local tb={}
    tb["cmd"]="cross.record"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("积分明细记录",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--战斗记录
-- bid 比赛Id
-- round 0小组赛的   1-7 淘汰赛
-- group 胜者组 or 败者组
-- pos  每轮的第几场 a b c d
-- inning 三局比赛的第几场
function socketHelper:crossReport(bid,round,group,pos,inning,callback)
    local tb={}
    tb["cmd"]="cross.report"
    tb["params"]={bid=bid,round=round,group=group,pos=pos,inning=inning}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("战斗记录",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--跨服战排行榜
function socketHelper:crossRanking(callback)
    local tb={}
    tb["cmd"]="cross.ranking"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("跨服战排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--跨服战排行榜奖励
function socketHelper:crossGetrankingreward(callback)
    local tb={}
    tb["cmd"]="cross.getrankingreward"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("跨服战排行榜奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
----------个人跨服战-----------

--定制化抽奖 抽奖 --isJapan是否是给日本开的拉霸活动
function socketHelper:activityCustomLottery(callback,isJapan,num,aname)
    local tb={}
    if isJapan and isJapan==true then
        tb["cmd"]="active.customlottery1"
    else
        tb["cmd"]="active.customlottery"
    end
    tb["params"]={num=num,aname=aname}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("定制化抽奖 抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--定制化抽奖 获取已抽到的奖励 --isJapan是否是给日本开的拉霸活动
function socketHelper:activityCustomLotteryList(callback,isJapan,aname)
    local tb={}
    if isJapan and isJapan==true then
        tb["cmd"]="active.customlottery1"
    else
        tb["cmd"]="active.customlottery"
    end
    tb["params"]={action="getlist",aname=aname}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("定制化抽奖 获取已抽到的奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--改装计划抽奖
function socketHelper:activityRefitPlanReward(num,free,callback)
    local tb={}
    tb["cmd"]="active.refitplant99"
    tb["params"]={action="getReward",num=num,free=free}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("改装计划抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end




--万圣节门后有鬼 初始化活动数据
function socketHelper:activityDoorGhostGetReward(callback)
    local tb={}
    tb["cmd"]="active.doorget"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("万圣节门后有鬼 初始化活动数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--万圣节门后有鬼 重置活动数据
function socketHelper:activityDoorGhostRefresh(method,callback)
    local tb={}
    tb["cmd"]="active.doorref"
    tb["params"]={method=method}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("万圣节门后有鬼 重置活动数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--万圣节门后有鬼 开门抓鬼
function socketHelper:activityDoorGhostOpenDoor(door,callback)
    local tb={}
    tb["cmd"]="active.doorlottery"
    tb["params"]={door=door}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("万圣节门后有鬼 开门抓鬼",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--万圣节门后有鬼 领取奖励
function socketHelper:activityDoorGhostReward(callback)
    local tb={}
    tb["cmd"]="active.doorreward"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("万圣节门后有鬼 领取奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--改装计划改装坦克
function socketHelper:activityRefitPlanTank(num,aid,callback)
    local tb={}
    tb["cmd"]="active.refitplant99"
    tb["params"]={action="upgrade",num=num,aid=aid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("改装计划抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--脱光行动活动 每日领取奖励
function socketHelper:activitySinglesDailyReward(callback)
    local tb={}
    tb["cmd"]="active.singles"
    tb["params"]={action="daily"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("脱光行动活动 每日领取奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--脱光行动活动 抽奖
function socketHelper:activitySinglesLotteryReward(num,callback)
    local tb={}
    tb["cmd"]="active.singles"
    tb["params"]={action="rank",num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("改装计划抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--脱光行动活动 商店兑换奖励
function socketHelper:activitySinglesShop(id,callback)
    local tb={}
    tb["cmd"]="active.singles"
    tb["params"]={action="shop",item=id}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("改装计划抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end



--添加玩家到每日的黑名单，隔天清空
function socketHelper:userAddblack(uid,callback)
    local tb={}
    tb["cmd"]="user.addblack"
    tb["params"]={uid=uid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("添加玩家到每日黑名单",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--感恩节活动 鸡动部队 抽奖
function socketHelper:activityJidongbuduiLottery(callback)
    local tb={}
    tb["cmd"]="active.jidongbudui"
    tb["params"]={action="rank"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("感恩节活动 鸡动部队 抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--摧枯拉朽活动 领取军功奖励
function socketHelper:activityCuikulaxiuPointReward(id,callback)
    local tb={}
    tb["cmd"]="active.cuikulaxiu"
    tb["params"]={action="getPointReward",item=id}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("摧枯拉朽活动 领取军功奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--感恩节活动 鸡动部队 兑换坦克
function socketHelper:activityJidongbuduiExchangeTank(num,callback)
    local tb={}
    tb["cmd"]="active.jidongbudui"
    tb["params"]={action="combine",num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("感恩节活动 鸡动部队 兑换坦克",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--摧枯拉朽活动 获取排行榜List
function socketHelper:activityCuikulaxiuList(callback)
    local tb={}
    tb["cmd"]="active.cuikulaxiu"
    tb["params"]={action="getRankList"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("摧枯拉朽活动 获取排行榜List",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--摧枯拉朽活动 领取排行奖励
function socketHelper:activityCuikulaxiuRankReward(callback)
    local tb={}
    tb["cmd"]="active.cuikulaxiu"
    tb["params"]={action="getRankReward"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("摧枯拉朽活动 领取排行奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end



--感恩节活动 鸡动部队 兑换其他道具
function socketHelper:activityJidongbuduiExchangeOthers(index,callback)
    local tb={}
    tb["cmd"]="active.jidongbudui"
    tb["params"]={action="other",index=index}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("感恩节活动 鸡动部队 兑换其他道具",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--感恩节活动 鸡动部队 得到剩余的全服坦克数量
function socketHelper:activityJidongbuduiServerLeftTank(callback)
    local tb={}
    tb["cmd"]="active.jidongbudui"
    tb["params"]={action="getTotal"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("感恩节活动 鸡动部队 兑换其他道具",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--百服大礼 领取金币奖励
function socketHelper:activityBaifudaliRecGold(callback)
    local tb={}
    tb["cmd"]="active.baifudali"
    tb["params"]={action="getreward"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("百服大礼 领取金币奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--军功排行榜
--param page: 分页
function socketHelper:userGetnewranklist(page,callback)
    local tb={}
    tb["cmd"]="user.getnewranklist"
    tb["params"]={page=page}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军功排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--废墟探索 探索
function socketHelper:activityFeixutansuoTansuo(num,callback)
    local tb={}
    tb["cmd"]="active.feixutansuo"
    tb["params"]={action="getreward",num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("废墟探索 探索",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--百服大礼 领取每日奖励
function socketHelper:activityBaifudaliRecReward(callback)
   local tb={}
    tb["cmd"]="active.baifudali"
    tb["params"]={action="dailyreward"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("百服大礼 领取每日奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--获取英雄列表
function socketHelper:heroGetlist(callback)
    local tb={}
    tb["cmd"]="hero.getlist"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获取英雄列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--废墟探索 改装坦克
function socketHelper:activityFeixutansuoRefitTank(num,aid,callback)
    local tb={}
    tb["cmd"]="active.feixutansuo"
    tb["params"]={action="upgrade",num=num,aid=aid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("废墟探索 改装坦克",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--废墟探索 获取奖励列表
function socketHelper:activityFeixutansuoRewardList(callback)
    local tb={}
    tb["cmd"]="active.feixutansuo"
    tb["params"]={action="getlist"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("废墟探索 获取奖励列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--引导添加英雄 hid:哪个引导 1，2
function socketHelper:heroAddhero(hid,callback)
    local tb={}
    tb["cmd"]="hero.addhero"
    tb["params"]={hid=hid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("引导添加英雄",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--英雄进阶 hid:英雄id
function socketHelper:heroAdvance(hid,callback)
    local tb={}
    tb["cmd"]="hero.advance"
    tb["params"]={hid=hid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("英雄进阶",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--英雄合成 hid:英雄id
function socketHelper:heroFusion(hid,callback)
    local tb={}
    tb["cmd"]="hero.fusion"
    tb["params"]={hid=hid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("英雄合成",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])

end

--英雄技能升级 hid:英雄id sid：s1001
function socketHelper:heroUpgradeskill(hid,sid,callback)
    local tb={}
    tb["cmd"]="hero.upgradeskill"
    tb["params"]={hid=hid,sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("英雄技能升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--英雄抽奖 method:方式1:普通 2：高级 如果有free=1 则为高级免费
function socketHelper:heroLottery(method,free,callback)
    local tb={}
    tb["cmd"]="hero.lottery"
    tb["params"]={method=method,free=free}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("英雄抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--英雄十连抽
function socketHelper:heroTenlottery(callback)
    local tb={}
    tb["cmd"]="hero.tenlottery"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("英雄十连抽",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--英雄升级
function socketHelper:heroUpgrade(hid,pid,count,callback)
    local tb={}
    tb["cmd"]="hero.upgrade"
    tb["params"]={hid=hid,pid=pid,count=count}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("英雄升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--刷新vip user.refvip
function socketHelper:userefvip(callback)
    local tb={}
    tb["cmd"]="user.refvip"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("刷新vip",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--获取好友列表
function socketHelper:friendsList(callback,_params)
    local tb={}
    tb["cmd"]="friends.list"
    if _params then
        tb["params"]={aname=_params}
    else
        tb["params"]={}
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获取好友列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 发送好友申请 fid,好友id
function socketHelper:sendfriendApply(_fid,callback)
    local tb={}
    tb["cmd"]="friends.new.invite"
    tb["params"]={fid=_fid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("发送好友申请",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 同意好友申请,_fidTb同意好友申请table列表
function socketHelper:agreefriendApply(_fidTb,callback)
    local tb={}
    tb["cmd"]="friends.new.agree"
    tb["params"]={fid=_fidTb}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("同意好友申请",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 拒绝好友申请，_fidTb拒绝好友申请table列表
function socketHelper:rejectApply(_fidTb,callback)
    local tb={}
    tb["cmd"]="friends.new.reject"
    tb["params"]={fid=_fidTb}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("拒绝好友申请",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:sendFriendGift(_fidTb,callback)
    local tb={}
    tb["cmd"]="friends.new.sendgift"
    tb["params"]={fid=_fidTb}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("送好友礼物",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getFriendNewGift(_fidTb,callback)
    local tb={}
    tb["cmd"]="friends.new.getgift"
    tb["params"]={fid=_fidTb}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获得好友礼物",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军团跨服战初始化数据
--param ref: 是否需要刷新
function socketHelper:acrossInit(ref,callback)
    local tb={}
    tb["cmd"]="across.crossinit"
    if(ref==nil)then
        ref=0
    end
    tb["params"]={ref=ref}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团跨服战初始化数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--添加好友
function socketHelper:friendsAdd(uid,name,callback)
    local tb={}
    tb["cmd"]="friends.add"
    tb["params"]={uid=uid,name=name}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("添加好友",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--军团跨服战报名
function socketHelper:acrossApply(method,callback)
    local tb={}
    tb["cmd"]="across.apply"
    tb["params"]={method=method}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团跨服战报名",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--删除好友
function socketHelper:friendsDel(uid,name,callback)
    local tb={}
    tb["cmd"]="friends.del"
    tb["params"]={uid=uid,name=name}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("删除好友",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--搜索好友
function socketHelper:friendsSearch(name,callback)
    local tb={}
    tb["cmd"]="friends.search"
    tb["params"]={name=name}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("搜索好友",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--狂怒之师 抽奖
function socketHelper:activityKuangnuzhishiLottery(num,callback)
    local tb={}
    tb["cmd"]="active.kuangnuzhishi"
    tb["params"]={action="getReward",num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("狂怒之师 抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--狂怒之师 排行榜
function socketHelper:activityKuangnuzhishiRankList(callback)
    local tb={}
    tb["cmd"]="active.kuangnuzhishi"
    tb["params"]={action="getlist"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("狂怒之师 排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--狂怒之师 领取排行榜奖励
function socketHelper:activityKuangnuzhishiRankReward(callback)
   local tb={}
    tb["cmd"]="active.kuangnuzhishi"
    tb["params"]={action="getRankReward"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("狂怒之师 领取排行榜奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--真情回馈 坦克轮盘 （飞流）
function socketHelper:activityZhenqinghuikui( callback )
    local tb={}
    tb["cmd"]="active.zhenqinghuikui"
    --tb["params"]={action=""}

    local requestStr = G_Json.encode(tb)
    print("真情回馈 坦克轮盘（飞流）",requestStr)
    self.sendRequest(requestStr,callback,tb["cmd"])
end


--圣诞宝藏 获取奖励List
function socketHelper:activityShengdanbaozangRewardList(callback)
   local tb={}
    tb["cmd"]="active.shengdanbaozang"
    tb["params"]={action="list"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("圣诞宝藏 获取奖励List",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--圣诞宝藏 单次挖掘付费
function socketHelper:activityShengdanbaozangCost(callback)
   local tb={}
    tb["cmd"]="active.shengdanbaozang"
    tb["params"]={action="pay"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("圣诞宝藏 单次挖掘付费",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--圣诞宝藏 单次挖掘
function socketHelper:activityShengdanbaozangLotteryOne(num,callback)
   local tb={}
    tb["cmd"]="active.shengdanbaozang"
    tb["params"]={action="rand",category=1,num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("圣诞宝藏 单次挖掘",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--圣诞宝藏 全部挖掘
function socketHelper:activityShengdanbaozangLotteryAll(callback)
   local tb={}
    tb["cmd"]="active.shengdanbaozang"
    tb["params"]={action="rand",category=2}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("圣诞宝藏 全部挖掘",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--圣诞宝藏 放弃挖宝
function socketHelper:activityShengdanbaozangGiveUp(callback)
   local tb={}
    tb["cmd"]="active.shengdanbaozang"
    tb["params"]={action="refresh"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("圣诞宝藏 放弃挖宝",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--圣诞宝藏 商店兑换奖励
function socketHelper:activityShengdanbaozangShop(id,callback)
    local tb={}
    tb["cmd"]="active.shengdanbaozang"
    tb["params"]={action="shop",item=id}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("改装计划抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end




--圣诞狂欢 查看圣诞树养分值
function socketHelper:activityShengdankuanghuanTreePoint(callback)
   local tb={}
    tb["cmd"]="active.shengdankuanghuan"
    tb["params"]={action="treeNum"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("圣诞狂欢 查看圣诞树养分值",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--圣诞狂欢 领取充值返利奖励
function socketHelper:activityShengdankuanghuanGoldReward(mtype,callback)
   local tb={}
    tb["cmd"]="active.shengdankuanghuan"
    tb["params"]={action="getGoldReward",mType=mtype}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("圣诞狂欢 领取充值返利奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--圣诞狂欢 领取全部充值返利奖励
function socketHelper:activityShengdankuanghuanAllGoldReward(callback)
   local tb={}
    tb["cmd"]="active.shengdankuanghuan"
    tb["params"]={action="wholeReward"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("圣诞狂欢 领取充值返利奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--圣诞狂欢 领取圣诞树奖励
function socketHelper:activityShengdankuanghuanTreeReward(mtype,callback)
   local tb={}
    tb["cmd"]="active.shengdankuanghuan"
    tb["params"]={action="getTreeReward",mType=mtype}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("圣诞狂欢 领取圣诞树奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--远征取出信息
function socketHelper:expeditionGet(callback)
    local tb={}
    tb["cmd"]="expedition.get"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("远征信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--远征攻打
function socketHelper:expeditionBattle(fleetinfo,hero,callback,emblemID,planePos,aitroops,airshipId)
    local tb={}
    tb["cmd"]="expedition.battle"
    tb["params"]={fleetinfo=fleetinfo,hero=hero,equip=emblemID,plane=planePos,at=aitroops,ap=airshipId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("远征攻打",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--远征领奖
function socketHelper:expeditionReward(id,callback)
    local tb={}
    tb["cmd"]="expedition.reward"
    tb["params"]={id=id}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("远征领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--远征重置
function socketHelper:expeditionReset(callback,t)
    local tb={}
    local flag = t or 0
    tb["cmd"]="expedition.reset"
    tb["params"]={t=flag}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("重置远征军",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--远征商店
function socketHelper:expeditionGetshop(callback)
    local tb={}
    tb["cmd"]="expedition.getshop"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("远征商店",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--远征战报
function socketHelper:expeditionGetlog(callback)
    local tb={}
    tb["cmd"]="expedition.getlog"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("远征战报",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--远征删除战报
function socketHelper:expeditionDelete(id,callback)
    local tb={}
    tb["cmd"]="expedition.delete"
    tb["params"]={id=id}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("远征删除战报",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--远征商店购买
function socketHelper:expeditionBuy(id,pid,count,callback)
    local tb={}
    tb["cmd"]="expedition.buy"
    tb["params"]={id=id,pid=pid,count=count}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("远征商店购买",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])

end


--元旦献礼 1次抽奖/10次抽奖
function socketHelper:activityYuandanxianli( aCtion,nUm,callback )
    local tb = {}
    tb["cmd"]="active.yuandanxianli"
    tb["params"]={action=aCtion,num=nUm}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("元旦献礼，1或10次抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--元旦献礼 7天充值大奖
function socketHelper:activityYuandanxianliBig( aCtion,callback )
    local tb = {}
    tb["cmd"]="active.yuandanxianli"
    tb["params"]={action =aCtion}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("元旦献礼，7天充值最终大奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--元旦献礼 7天每天的领奖信息
function socketHelper:activityYuandanxianliSeven( aCtion,nUm,callback)
    local tb = {}
    tb["cmd"]="active.yuandanxianli"
    tb["params"]={action = aCtion,num = nUm}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("元旦献礼，7天领取每天充值奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--元旦献礼 补签
function socketHelper:activityYuandanxianliSevenBQ( aCtion,nUm,callback)
    local tb = {}
    tb["cmd"]="active.yuandanxianli"
    tb["params"]={action = aCtion,num = nUm}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("元旦献礼，补签",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--配件商店兑换
--param id: 要兑换的商品ID
function socketHelper:accessoryBuy(id,callback,num)
   local tb={}
    tb["cmd"]="accessory.buy"
    tb["params"]={id=id,num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("配件商店兑换",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--领取 在线奖励
function socketHelper:activityOnlineReward(mtype,callback)
   local tb={}
    tb["cmd"]="active.onlinereward"
    tb["params"]={category=mtype}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领取 在线奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--领取 在线奖励2018
function socketHelper:activityOnlineRewardXVIII(mtype,callback)
   local tb={}
    tb["cmd"]="active.online2018"
    tb["params"]={category=mtype}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领取 在线奖励2018",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--坦克嘉年华 抽奖
function socketHelper:activityTankjianianhuaReward(dtype,callback)
    local tb = {}
    tb["cmd"]="active.jianianhua"
    tb["params"]={dtype = dtype}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("坦克嘉年华 抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军团跨服战确定修改上阵人员
function socketHelper:acrossSetteams(members,callback)
    local tb={}
    tb["cmd"]="across.setteams"
    tb["params"]={members=members}
    for k,v in pairs(members) do
        print("k",k,v,type(v))
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("修改上阵人员",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军团跨服战同步数据
--usegems：军备资金，fleetinfo：部队，hero：英雄，clear：1清除部队和英雄，emblemID：军徽
function socketHelper:acrossSetinfo(usegems,fleetinfo,hero,aName,clear,callback,emblemID,planePos,aitroops,airshipId)
    local tb={}
    tb["cmd"]="across.setinfo"
    tb["params"]={usegems=usegems,fleetinfo=fleetinfo,hero=hero,aName=aName,clear=clear,equip=emblemID,plane=planePos,at=aitroops,ap=airshipId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团跨服战同步数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军团跨服战基地捐献
--method：1 金币，2 资源
function socketHelper:acrossDonate(method,callback)
    local tb={}
    tb["cmd"]="across.donate"
    tb["params"]={method=method}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团跨服战基地捐献",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军团跨服战商店信息和押注信息初始化接口
function socketHelper:acrossBetpointinfo(callback)
    local tb={}
    tb["cmd"]="across.betpointinfo"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团跨服战商店和押注初始化",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军团跨服战积分明细接口
function socketHelper:acrossRecord(callback)
    local tb={}
    tb["cmd"]="across.record"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团跨服战积分明细",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军团跨服战购买商品接口 "matchId":"b16","sType":"aShopItems","tId":"a6"}}
--matchId 战斗id
--sType 珍品还是普通
--tId 物品id
function socketHelper:acrossBuy(matchId,sType,tId,callback)
    local tb={}
    tb["cmd"]="across.buy"
    tb["params"]={matchId=matchId,sType=sType,tId=tId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团跨服战购买商品",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军团跨服战获取赛程表
function socketHelper:acrossSchedule(callback)
    local tb={}
    tb["cmd"]="across.schedule"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团跨服战获取赛程表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军团跨服战提取全部资金
function socketHelper:acrossTakegems(callback)
    local tb={}
    tb["cmd"]="across.takegems"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团跨服战提取全部资金",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军团跨服战战报 "category":2,"bid":"b111","round":1,"did":"a","page":1
--"category": 类别 1服内赛， 2跨服赛
--"bid":"b111", 战斗Id
--"round":1, 第几轮
--"did":"a", 第几场
--"page":1  数据的第几页
--dtype:0 军团战报，1 个人战报
--noCache:1 及时刷新战报，在战场内用
function socketHelper:acrossReport(category,bid,round,did,page,callback,dtype,noCache)
    local tb={}
    tb["cmd"]="across.report"
    tb["params"]={category=category,bid=bid,round=round,did=did,page=page,dtype=dtype,noCache=noCache}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团跨服战战报",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军团跨服战击毁坦克统计 "category":2,"bid":"b111","round":1,"did":"a"
--"category": 类别 1服内赛， 2跨服赛
--"bid":"b111", 战斗Id
--"round":1, 第几轮
--"did":"a", 第几场
function socketHelper:acrossTroopsreport(category,bid,round,did,callback)
    local tb={}
    tb["cmd"]="across.troopsreport"
    tb["params"]={category=category,bid=bid,round=round,did=did}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团跨服战击毁坦克统计",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军团跨服战领取献花奖励 "matchId":"b16","detailId":"b16_2_1_a"
-- matchId，本期跨服战id "matchId":"b16"
-- detailId，matchId_服内赛or淘汰赛_第几轮_a or b or c..... "detailId":"b16_2_1_a"
function socketHelper:acrossGetbetreward(matchId,detailId,callback)
    local tb={}
    tb["cmd"]="across.getbetreward"
    tb["params"]={matchId=matchId,detailId=detailId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团跨服战领取献花奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军团跨服战排行榜
function socketHelper:acrossRanking(callback)
    local tb={}
    tb["cmd"]="across.ranking"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团跨服战排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军团跨服战领取排名奖励
function socketHelper:acrossGetrankingreward(callback)
    local tb={}
    tb["cmd"]="across.getrankingreward"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团跨服战领取排名奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军团跨服战献花
function socketHelper:acrossBet(matchId,detailId,aid,callback)
    local tb={}
    tb["cmd"]="across.bet"
    tb["params"]={matchId=matchId,detailId=detailId,aid=aid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团跨服战献花",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军团跨服战个人战报详情
function socketHelper:acrossDetailreport(bid,rid,callback)
    local tb={}
    tb["cmd"]="across.detailreport"
    tb["params"]={bid=bid,rid=rid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("个人战报详情",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--许愿炉 金币炉许愿
function socketHelper:activityXuyuanluGoldWish(callback)
    local tb = {}
    tb["cmd"]="active.xuyuanlu"
    tb["params"]={action="gold"}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("许愿炉 金币炉许愿",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--许愿炉 道具炉许愿
function socketHelper:activityXuyuanluPropWish(callback)
    local tb = {}
    tb["cmd"]="active.xuyuanlu"
    tb["params"]={action="resource"}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("许愿炉 道具炉许愿",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--查看关卡详情
function socketHelper:challengeInfo(cid,callback)
    local tb = {}
    tb["cmd"]="challenge.info"
    tb["params"]={cid = cid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("查看关卡详情",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--刷新军功商店信息
function socketHelper:rpShopRefresh(callback)
    local tb = {}
    tb["cmd"]="user.creditshopget"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("刷新军功商店信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军功商店信息购买
function socketHelper:rpShopBuy(id,callback)
    local tb = {}
    tb["cmd"]="user.creditshopbuy"
    tb["params"]={id=id}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("军功商店信息购买",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--配件碎片批量合成
function socketHelper:accessoryBulkCompose(idTb,callback)
    local tb = {}
    tb["cmd"]="accessory.moreupfragment"
    tb["params"]={info=idTb}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("配件碎片批量合成",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--百度云推送初始化之后给后台发个初始化请求
--param bindID: 云推送SDK返回的接口
function socketHelper:pushInit(bindID,callback)
    local tb={}
    tb["cmd"]="user.setpushbind"
    tb["params"]={bind=bindID}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("百度云推送初始化",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end



--水晶回馈 充值返水晶奖励
function socketHelper:activityShuijinghuikuiReward(gems,callback )
    local tb = {}
    tb["cmd"]="active.shuijinghuikui"
    tb["params"]={action="gemsReward",gems=gems}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("元旦献礼，1或10次抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--水晶回馈 每日首次充值奖励
function socketHelper:activityShuijinghuikuiDailyReward(callback )
    local tb = {}
    tb["cmd"]="active.shuijinghuikui"
    tb["params"]={action="dailyReward"}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("元旦献礼，1或10次抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--新春红包 开启红包
function socketHelper:activityXinchunhongbaoOpenGift(mtype,callback)
   local tb={}
    tb["cmd"]="active.xinchunhongbao"
    tb["params"]={action="getreward",type=mtype}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新春红包 开启红包",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--新春红包 赠送红包
function socketHelper:activityXinchunhongbaoGiveGift(mtype,uid,callback)
   local tb={}
    tb["cmd"]="active.xinchunhongbao"
    tb["params"]={action="give",type=mtype,giftUid=uid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新春红包 开启红包",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--新春红包 记录
function socketHelper:activityXinchunhongbaoReportList(callback)
   local tb={}
    tb["cmd"]="active.xinchunhongbao"
    tb["params"]={action="record"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新春红包 记录",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
function socketHelper:activityHuoxianmingjiangChoujiang(methodID,callback)
    local tb={}
    tb["cmd"]="active.huoxianmingjiang"
    tb["params"]={method=methodID}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("火线名将抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:activityHuoxianmingjiangChoujiangLog(callback)
    local tb={}
    tb["cmd"]="active.huoxianmingjianglog"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("火线名将抽奖记录",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- playerSkills自动升级
function socketHelper:autoUpdateSkill(callback)
    local tb={}
    tb["cmd"]="skill.checkupgrade"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("技能自动升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--军资派送活动 抽奖
function socketHelper:activityJunzipaisongLottery(num,callback)
    local tb={}
    tb["cmd"]="active.junzipaisong"
    tb["params"]={dtype=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军资派送活动 抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 腾讯活动
function socketHelper:activityGetqqreward(callback)
    local tb={}
    tb["cmd"]="user.getqqreward"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("腾讯 活动奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--每日答题 当天领奖信息
function socketHelper:dailyAnswerSelfRank(callback)
    local tb = {}
    tb["cmd"]="dailyactive.meiridati"
    tb["params"]={action="getRankReward"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("每日答题 自己中奖记录",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--每日答题 每题的排名信息
function socketHelper:dailyAnswerRankList(callback)
    local tb = {}
    tb["cmd"]="dailyactive.meiridati"
    tb["params"]={action="getUserStatus"}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("每日答题 当前每题的排名信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 每日答题(获取题目列表)
function socketHelper:dailyAnswerGetTitlelist(callback)
   local tb={}
    tb["cmd"]="dailyactive.meiridati"
    tb["params"]={action="getTitlelist"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print(" 每日答题 题目列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 每日答题（选择题目）
function socketHelper:dailyAnswerChoice(questionNum, userChoice, callback)
   local tb={}
    tb["cmd"]="dailyactive.meiridati"
    tb["params"]={action="choice",dtype=questionNum,choice=userChoice}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print(" 每日答题 选择题目",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 每日答题（用户的初始状态）
function socketHelper:dailyAnswerGetUserStatus(callback)
   local tb={}
    tb["cmd"]="dailyactive.meiridati"
    tb["params"]={action="getUserStatus"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print(" 每日答题 用户的初始状态",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--每日答题 排名列表
function socketHelper:dailyAnswerAllRankList(callback)
    local tb = {}
    tb["cmd"]="dailyactive.meiridati"
    tb["params"]={action="getRanklist",dtype=1}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("每日答题 所有人中奖记录",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 每日答题 刷新排名和积分
function socketHelper:dailyAnswerGetChoiceStatus(callback)
   local tb={}
    tb["cmd"]="dailyactive.meiridati"
    tb["params"]={action="getChoiceStatus"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print(" 每日答题 刷新排名和积分",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--世界Boss获取Boss信息
function socketHelper:BossBattleInfo(callback)
    local tb={}
    tb["cmd"]="boss.get"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("世界Boss获取Boss信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--设置世界Boss部队镜像
function socketHelper:BossBattleSettroops(fleetinfo,callback,hero,auto,emblemID,planePos,aitroops,isOnlySet,airshipId)
    local tb={}
    tb["cmd"]="boss.setinfo"
    tb["params"]={}
    if isOnlySet then
        tb["params"]={fleetinfo=fleetinfo,hero=hero,auto=auto,equip=emblemID,plane=planePos,at=aitroops,ap=airshipId}
    else
        tb["params"]={auto=auto}
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("设置世界Boss部队镜像",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--世界Boss购买buff
function socketHelper:BossBattleBuyBuff(bid,callback)
    local tb={}
    tb["cmd"]="boss.buybuff"
    tb["params"]={bid=bid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("设置世界Boss购买buff",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--世界Boss伤害排行榜
function socketHelper:BossBattleRank(callback)
    local tb={}
    tb["cmd"]="boss.getrank"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("世界Boss伤害排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--世界Boss领取奖励
function socketHelper:BossBattleGetReward(rank,callback)
    local tb={}
    tb["cmd"]="boss.reward"
    tb["params"]={rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("世界Boss领取奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--世界Boss攻打Boss
function socketHelper:BossBattleAttack(reborn,callback)
    local tb={}
    tb["cmd"]="boss.battle"
    tb["params"]={reborn=reborn}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("世界Boss攻打Boss",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--每日答题 当天领奖信息
function socketHelper:dailyAnswerSelfRank(callback)
    local tb = {}
    tb["cmd"]="dailyactive.meiridati"
    tb["params"]={action="getRankReward"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("每日答题 自己中奖记录",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--每日答题 每题的排名信息
function socketHelper:dailyAnswerRankList(callback)
    local tb = {}
    tb["cmd"]="dailyactive.meiridati"
    tb["params"]={action="getUserStatus"}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("每日答题 当前每题的排名信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 每日答题(获取题目列表)
function socketHelper:dailyAnswerGetTitlelist(callback)
   local tb={}
    tb["cmd"]="dailyactive.meiridati"
    tb["params"]={action="getTitlelist"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print(" 每日答题 题目列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 每日答题（选择题目）
function socketHelper:dailyAnswerChoice(questionNum, userChoice, callback)
   local tb={}
    tb["cmd"]="dailyactive.meiridati"
    tb["params"]={action="choice",dtype=questionNum,choice=userChoice}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print(" 每日答题 选择题目",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 每日答题（用户的初始状态）
function socketHelper:dailyAnswerGetUserStatus(callback)
   local tb={}
    tb["cmd"]="dailyactive.meiridati"
    tb["params"]={action="getUserStatus"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print(" 每日答题 用户的初始状态",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--每日答题 排名列表
function socketHelper:dailyAnswerAllRankList(callback)
    local tb = {}
    tb["cmd"]="dailyactive.meiridati"
    tb["params"]={action="getRanklist",dtype=1}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("每日答题 所有人中奖记录",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 每日答题 刷新排名和积分
function socketHelper:dailyAnswerGetChoiceStatus(callback)
   local tb={}
    tb["cmd"]="dailyactive.meiridati"
    tb["params"]={action="getChoiceStatus"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print(" 每日答题 刷新排名和积分",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:dailyAnswerGetNowTime(callback)
   local tb={}
    tb["cmd"]="dailyactive.meiridati"
    tb["params"]={action="getnowtime"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print(" 每日答题 返回前台同步时间",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 每日领取体力
function socketHelper:activityGetenergy(num,callback)
    local tb={}
    tb["cmd"]="dailyactive.getenergy"
    tb["params"]={dtype=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("每日领取体力",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--真情有礼
function socketHelper:activeChongZhiYouLi(callback)
    local tb={}
    tb["cmd"]="active.chongzhiyouli"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("真情有礼",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军团活跃 获取可领取的资源奖励
function socketHelper:allianceActiveCanReward(callback)
    local tb={}
    tb["cmd"]="alliance.getresource"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团活跃获取可领取的资源奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军团活跃 领取资源奖励
function socketHelper:allianceActiveReward(res,callback)
    local tb={}
    tb["cmd"]="alliance.alliancereward"
    tb["params"]={res=res}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团活跃领取资源奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


-- 军事讲坛活动
function socketHelper:activityJunshijiangtanStudy(rType,num,callback)
    local tb={}
    tb["cmd"]="active.junshijiangtan"
    tb["params"]={rType=rType,num=num,action="rand"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军事讲坛 学习",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 军事讲坛活动
function socketHelper:activityJunshijiangtanGetReward(callback)
    local tb={}
    tb["cmd"]="active.junshijiangtan"
    tb["params"]={action="rankReward"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军事讲坛 领取奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 军事讲坛活动
function socketHelper:activityJunshijiangtanGetanklist(callback)
    local tb={}
    tb["cmd"]="active.junshijiangtan"
    tb["params"]={action="ranklist"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军事讲坛 排名列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end



--军团改名
function socketHelper:changeAllianceName(uid,name,callback)
    local tb={}
    tb["cmd"]="alliance.setname"
    tb["params"]={uid=uid,name=name}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("真情有礼",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--异星科技获取数据
--返回 "data": {"alien": {"used": {},"info": {}}},
-- used  是装备在坦克上的科技
-- info  是解锁的科技和科技等级
function socketHelper:alienGet(callback)
    local tb={}
    tb["cmd"]="alien.get"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("异星科技数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--异星科技升级科技  id  是科技的id
function socketHelper:alienUpgrade(id,callback,enum)
    local tb={}
    tb["cmd"]="alien.upgrade"
    tb["params"]={id=id,enum=enum}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("异星科技升级科技",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--异星科技使用科技到坦克上
-- id  是科技的id:t1
-- ttype  是坦克的id:a10001
-- p 是要装配的位置:1
function socketHelper:alienUse(id,ttype,p,callback)
    local tb={}
    tb["cmd"]="alien.use"
    tb["params"]={id=id,ttype=ttype,p=p}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("异星科技使用科技",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--异星科技解锁科技，卡槽位置
-- ttype  是坦克的id:a10001
-- solt 解锁第几个位置
function socketHelper:alienOpensolt(ttype,solt,callback,enum)
    local tb={}
    tb["cmd"]="alien.opensolt"
    tb["params"]={ttype=ttype,solt=solt,enum=enum}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("异星科技解锁科技",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--异星科技改装坦克
--id 科技id
--count 数量
function socketHelper:alienAddtroops(id,count,tid,callback,enum)
    local tb={}
    tb["cmd"]="alien.addtroops"
    tb["params"]={id=id,count=count,tid=tid,enum=enum}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("异星科技改装坦克",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--异星科技礼物操作
--param action: 初始化还是送礼还是接受
--param uidTb: 收取和赠送时候的参数uid
function socketHelper:alienGift(action,uidTb,callback)
    local tb={}
    tb["cmd"]="alien.gift"
    tb["params"]={action=action}
    if(uidTb)then
        tb["params"]["uids"]=uidTb
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("异星科技初始化礼物",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--世界争霸初始化数据
function socketHelper:worldWarInit(callback)
    local tb={}
    tb["cmd"]="worldwar.crossinit"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("世界争霸初始化数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--世界争霸报名
--param type: 1是NB赛，2是SB赛
function socketHelper:worldWarSign(type,callback)
    local tb={}
    tb["cmd"]="worldwar.apply"
    tb["params"]={join=type}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("世界争霸报名",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--世界争霸设置部队
--line：1，2，3场次部队 fleetinfo：部队
function socketHelper:worldwarSetinfo(line,fleetinfo,aName,hero,clear,callback,emblemID,planePos,aitroops,airshipId)
    local tb={}
    tb["cmd"]="worldwar.setinfo"
    tb["params"]={line=line,fleetinfo=fleetinfo,aName=aName,hero=hero,clear=clear,equip=emblemID,plane=planePos,at=aitroops,ap=airshipId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("世界争霸设置部队",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--设置策略和出阵顺序
-- strategy={1，2，3} 策略值
-- line   ={3,2,1} 每只部队出阵顺序
function socketHelper:worldwarSetstrategy(line,strategy,callback)
    local tb={}
    tb["cmd"]="worldwar.setstrategy"
    tb["params"]={line=line,strategy=strategy}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("设置策略和出阵顺序",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--世界争霸对阵表
--param type: 1NB, 2SB
function socketHelper:worldwarSchedule(type,callback)
    local tb={}
    tb["cmd"]="worldwar.schedule"
    tb["params"]={jointype=type}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("世界争霸对阵表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--世界争霸献花
-- matchId，本期世界争霸id "matchId":"b319"
-- detailId，matchId_第几轮_g+第几场 "detailId":"b319_6_g1"
-- joinUser，用户Id
-- type，1 大师，2 精英
function socketHelper:worldwarBet(matchId,detailId,joinUser,type,callback)
    local tb={}
    tb["cmd"]="worldwar.bet"
    tb["params"]={matchId=matchId,detailId=detailId,joinUser=joinUser,jointype=type}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("世界争霸献花",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--世界争霸献花领奖
-- matchId，本期世界争霸id "matchId":"b319"
-- detailId，matchId_第几轮_g+第几场 "detailId":"b319_6_g1"
-- joinUser，用户Id
-- type，1 大师，2 精英
function socketHelper:worldwarGetbetreward(matchId,detailId,joinUser,type,callback)
    local tb={}
    tb["cmd"]="worldwar.getbetreward"
    tb["params"]={matchId=matchId,detailId=detailId,joinUser=joinUser,jointype=type}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("世界争霸献花领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--世界争霸购买物品
-- matchId，本期世界争霸id "matchId":"b319"
-- sType，"pShopItems" or aShopItems 普通商店或者精品商店
-- tId，对应配置表的下标Id
function socketHelper:worldwarBuy(matchId,sType,tId,callback)
    local tb={}
    tb["cmd"]="worldwar.buy"
    tb["params"]={matchId=matchId,sType=sType,tId=tId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("世界争霸购买物品",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--世界争霸积分明细
-- jointype，参加精英组还是大师组，没参加传0
function socketHelper:worldwarRecord(jointype,callback)
    local tb={}
    tb["cmd"]="worldwar.record"
    tb["params"]={jointype=jointype}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("世界争霸积分明细",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--世界争霸战斗记录
-- matchType 1大师，2精英
-- bid 比赛Id
-- round 第几轮
-- pos  每轮的第几场 g1 g3
-- inning 三局比赛的第几场
function socketHelper:worldwarReport(matchType,bid,round,pos,inning,callback)
    local tb={}
    tb["cmd"]="worldwar.report"
    tb["params"]={matchType=matchType,bid=bid,round=round,pos=pos,inning=inning}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("世界争霸战斗记录",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end



--连续充值送将领 补签
function socketHelper:activitySendGeneralSevenBQ( aCtion,nUm,callback)
    local tb = {}
    tb["cmd"]="active.songjiangling"
    tb["params"]={action = aCtion,num = nUm}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("连续充值送将领，补签",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--连续充值送将领 领取最终大奖
function socketHelper:activitySendGeneralLastReward( aCtion,callback)
    local tb = {}
    tb["cmd"]="active.songjiangling"
    tb["params"]={action = aCtion}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("连续充值送将领，领取最终大奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--名将
function socketHelper:activeMingjiangchoujiang(num,callback)
    local tb={}
    tb["cmd"]="active.huoxianmingjianggai"
    tb["params"]={action="rand",method=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("名将 抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--名将
function socketHelper:activeMingjiangLog(callback)
    local tb={}
    tb["cmd"]="active.huoxianmingjianggailog"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("名将 抽奖记录",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--名将
function socketHelper:activeMingjiangRank(callback)
    local tb={}
    tb["cmd"]="active.huoxianmingjianggai"
    tb["params"]={action="ranklist"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("名将 排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--名将
function socketHelper:activityMingjiangGetReward(callback)
    local tb={}
    tb["cmd"]="active.huoxianmingjianggai"
    tb["params"]={action="rankReward"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("名将 领取排名奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--名将
function socketHelper:activityMingjianggetScoreReward(callback)
    local tb={}
    tb["cmd"]="active.huoxianmingjianggai"
    tb["params"]={action="getScoreReward"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("名将 领取荣誉点奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])

end
-- vip特权礼包
function socketHelper:vipgiftreward(callback)
    local tb={}
    tb["cmd"]="user.vipgiftreward"
    tb["params"]={group="a",config=1}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("vip特权礼包 奖励列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- vip特权礼包
function socketHelper:vipgiftLingquOrGoumai(num,callback)
    local tb={}
    tb["cmd"]="user.vipgiftreward"
    tb["params"]={group="a",num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("vip特权礼包 领取or购买",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])

end

-- 限时挑战获取任务接口
function socketHelper:xstzGetTask(callback)
    local tb={}
    tb["cmd"]="limittask.limittask.get"
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("限时挑战获取任务",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--精炼
function socketHelper:accessoryPurifying(count,method,key,tank,value,callback)
    local tb={}
    tb["cmd"]="accessory.succinct"
    tb["params"]={count=count,method=method,p=key,tank=tank,value=value}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("配件 精炼",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--精炼 保存
function socketHelper:accessoryPurifyingSave(use,callback)
    local tb={}
    tb["cmd"]="accessory.usesuccinct"
    tb["params"]={use=use}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("精炼 保存",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--幸运转盘
function socketHelper:mayDay(method,rate,callback)
    local tb = {}
    tb["cmd"]="active.xingyunzhuanpan"
    tb["params"]={method=method,rate=rate}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("幸运转盘 抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--幸运转盘购买
function socketHelper:mayDayBuy(id,callback)
    local tb = {}
    tb["cmd"]="active.xingyunzhuanpanbuy"
    tb["params"]={id=id}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("幸运转盘 商店购买",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--钛矿丰收周
-- day 是领取每天充值金币对应给的资源 就是pf中的key
-- l   是每天登录的奖励
-- t   是生产坦克的奖励
-- r  =1 =2 是领取两档的奖励 
function socketHelper:TitaniumOfharvestGetReward(day,l,t,r,callback)
    local tb={}
    tb["cmd"]="active.taibumperweek"
    tb["params"]={day=day,l=l,t=t,r=r}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("钛矿丰收周 领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--回炉再造
function socketHelper:activityhuiluzaizao(num,callback)
    local tb={}
    tb["cmd"]="active.huiluzaizao"
    tb["params"]={action="getreward",num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("回炉再造 探索",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--回炉再造 获取奖励列表
function socketHelper:activityhuiluzaizaoRewardList(callback)
    local tb={}
    tb["cmd"]="active.huiluzaizao"
    tb["params"]={action="getlist"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("回炉再造 获取奖励列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--回炉再造 改装坦克
function socketHelper:activityhuiluzaizaoRefitTank(num,aid,callback)
    local tb={}
    tb["cmd"]="active.huiluzaizao"
    tb["params"]={action="upgrade",num=num,aid=aid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("回炉再造 改装坦克",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--请求获取异星矿场地图数据
function socketHelper:getAlienMinesMap(x1,y1,x2,y2,callback)
    local tb={}
    tb["cmd"]="map.get"
    tb["params"]={x1=x1,y1=y1,x2=x2,y2=y2,map=2}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("请求世界地图",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--进攻异星矿场
function socketHelper:alienMinesAttackTroop(targetid,fleetinfo,isGather,isHelp,callback,hero,apc,emblemID,planePos,aitroops,airshipId)
    local tb={}
    tb["cmd"]="alienmine.attack"
    tb["params"]={targetid=targetid,fleetinfo=fleetinfo,isGather=isGather,isHelp=isHelp,hero=hero,apc=apc,equip=emblemID,plane=planePos,at=aitroops,ap=airshipId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("进攻异星矿场",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--异星矿场侦查
function socketHelper:alienMinesScout(target,callback)
    local tb={}
    tb["cmd"]="map.alienscout"
    tb["params"]={target=target}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("异星矿场侦查",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--异星矿场部队返回
function socketHelper:alienMinesTroopBack(cid,callback)
    local tb={}
    tb["cmd"]="alienmine.back"
    tb["params"]={cid=cid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("异星矿场部队返回",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--异星矿场获取排行榜
function socketHelper:alienMinesGetRank(method,callback)
    local tb={}
    tb["cmd"]="alienmine.ranklist"
    tb["params"]={method=method}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("异星矿场 获取排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--异星矿场所有部队返回
function socketHelper:alienMinesTroopBackAll(callback)
    local tb={}
    tb["cmd"]="alienmine.backall"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("异星矿场所有部队返回",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--异星矿场信息
function socketHelper:alienMinesGet(callback)
    local tb={}
    tb["cmd"]="alienmine.get"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("异星矿场信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--异星矿场获得排名奖励
function socketHelper:alienMinesGetRankReward(callback)
    local tb={}
    tb["cmd"]="alienmine.rankreward"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("异星矿场 获得排名奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--异星矿场获得敌人信息
function socketHelper:alienMinesGetEnemyInfo(oid,callback)
    local tb={}
    tb["cmd"]="user.getinfo"
    tb["params"]={uid=oid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("异星矿场 获得敌人信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--驻防状态：1，2，3
function socketHelper:GarrsionOfState(stats,callback)
    local tb = {}
    tb["cmd"]="troop.setdefensestatus"
    tb["params"]={stats=stats}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("修改驻防状态",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--聊天加密
function socketHelper:ChatEncrypt(callback,isCheckExist)
    local tb = {}
    tb["cmd"]="chat.encrypt"
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"],false,isCheckExist)

end

--红场yuebing活动
--param action: 操作类型，1为抽奖 2为合成坦克 3为购买碎片
--param data: 要传给后台的参数，是一个table
function socketHelper:activeHongchangyuebingRocket(action,data,callback)
    local tb={}
    tb["cmd"]="active.hongchangyuebing"
    tb["params"]={action=action}
    for k,v in pairs(data) do
        tb["params"][k]=v
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--邮件屏蔽列表
function socketHelper:mailBlacklist(callback)
    local tb = {}
    tb["cmd"]="mail.blacklist"
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("邮件屏蔽列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--邮件加入屏蔽玩家
function socketHelper:mailAddblack(tid,list,callback,name)
    local tb={}
    tb["cmd"]="mail.addblack"
    tb["params"]={}
    if tid then
        tb["params"]["tid"]=tonumber(tid)
    end
    if list then
        tb["params"]["list"]=list
    end
    if name then
        tb["params"]["name"]=name
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("邮件加入屏蔽玩家",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--邮件移除屏蔽玩家
function socketHelper:mailRemoveblack(tid,tids,callback)
    local tb = {}
    tb["cmd"]="mail.removeblack"
    tb["params"]={}

    if tid then
        tb["params"]["tid"] = tid
    end

    if tids then
        tb["params"]["tids"] = tids
    end
    
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("邮件移除屏蔽玩家",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--将领授勋: 接受授勋任务
--param hid: 要开始授勋任务的将领id
function socketHelper:heroHonorAccept(hid,callback)
    local tb = {}
    tb["cmd"]="hero.acceptfeat"
    tb["params"]={hid=hid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("接受授勋任务",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--将领授勋：执行授勋
--param hid: 要授勋的英雄ID
function socketHelper:heroHonorWakeUp(hid,callback)
    local tb = {}
    tb["cmd"]="hero.feathero"
    tb["params"]={hid=hid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("执行授勋",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--将领授勋：放弃授勋任务
--param hid: 要授勋的英雄ID
function socketHelper:heroHonorCancel(hid,callback)
    local tb = {}
    tb["cmd"]="hero.canceltask"
    tb["params"]={hid=hid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("放弃授勋任务",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--将领授勋：领悟
--param hid: 领悟的将领ID
--param type: 用金币还是勋章
--param position: 领悟的是第几个位置的授勋技能
function socketHelper:heroApperception(hid,type,position,callback)
    local tb = {}
    tb["cmd"]="hero.apperception"
    tb["params"]={hid=hid,type=type}
    if(position)then
        tb["params"]["ption"]=position
    end
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("将领领悟",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--将领授勋：替换领悟技能
--param hid: 领悟的将领ID
--param sid: 选中替换的技能ID
--param position: 替换的是第几个位置的授勋技能，从1开始
function socketHelper:heroUseskill(hid,sid,position,callback)
    local tb = {}
    tb["cmd"]="hero.useskill"
    tb["params"]={hid=hid,sid=sid}
    if(position)then
        tb["params"]["ption"]=position
    end
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("替换领悟技能",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 班长试炼 
-- param action:
--     refresh 刷新坦克
--     getTroops 设置打关卡奖励的坦克类型，id 第几个位置索引
--     attack 攻击，id 第几关id，fleetinfo 部队信息
--     rankList 排行榜
--     reprot 每关前5名，id 第几关id
--     rankReward 排行榜领奖，rank 第几名
function socketHelper:activeBanzhangshilian(action,id,fleetinfo,rank,callback)
    local tb = {}
    tb["cmd"]="active.banzhangshilian"
    tb["params"]={action=action,id=id,fleetinfo=fleetinfo,rank=rank}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("班长试炼",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 班长试炼排行榜
function socketHelper:acBanzhangshilianRank(callback)
    local tb = {}
    tb["cmd"]="active.banzhangshilian"
    tb["params"]={action="rankList"}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("班长试炼 排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 班长试炼排行榜奖励
function socketHelper:acBanzhangshilianRankReward(rank,callback)
    local tb = {}
    tb["cmd"]="active.banzhangshilian"
    tb["params"]={action="rankReward",rank=rank}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("班长试炼 排行榜奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 每关前五名
function socketHelper:acBanzhangshilianLog(id,callback)
    local tb = {}
    tb["cmd"]="active.banzhangshilian"
    tb["params"]={action="reprot",id=id}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("班长试炼 每关的前5名",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--param mthod=0 是免费和倍率是1
-- mthod=1 倍率是10倍
function socketHelper:acMeteoriteLandingChoujiang(method,callback)
    local tb = {}
    tb["cmd"]="active.yunxingjianglin"
    tb["params"]={action="rand",method=method}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("陨星降临 抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:acMeteoriteLandingRank(callback)
    local tb = {}
    tb["cmd"]="active.yunxingjianglin"
    tb["params"]={action="ranklist",method=0}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("陨星降临 排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:acMeteoriteLandingRankReward(callback)
    local tb = {}
    tb["cmd"]="active.yunxingjianglin"
    tb["params"]={action="rankReward"}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("陨星降临 排行榜奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 资源兑换
function socketHelper:acMeteoriteLandingGetResource(method,count,callback)
    local tb = {}
    tb["cmd"]="active.yunxingjianglin"
    tb["params"]={action="getResource",method=method,count=count}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("陨星降临 资源兑换",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 天降雄狮抽奖
function socketHelper:acTianjiangxiongshiChoujiang(method,callback)
    local tb = {}
    tb["cmd"]="active.tianjiangxiongshi"
    tb["params"]={method=method}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("天降雄狮 抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 卡夫卡的馈赠 -- action 1 选择奖励，2 领取奖励  -- cid 金币档位序号，mid 奖励序号
function socketHelper:acKafkaGift(action,cid,mid,callback)
    local tb = {}
    tb["cmd"]="active.kafkagift"
    tb["params"]={action=action,cid=cid,mid=mid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("卡夫卡的馈赠",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 全民坦克抽奖
function socketHelper:acQuanmintankeChoujiang(method,callback)
    local tb = {}
    tb["cmd"]="active.quanmintanke"
    tb["params"]={method=method}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("全名坦克 抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 头像和称号
function socketHelper:buyHeadIcon(hid,callback)
    local tb = {}
    tb["cmd"]="user.buyhead"
    tb["params"]={hid=hid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("金币解锁头像",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 头像和称号
function socketHelper:setHeadIcon(pic,hfid,callback)
    local tb = {}
    tb["cmd"]="user.sethead"
    tb["params"]={pic=pic,hb=hfid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("设置玩家头像",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 头像和称号
function socketHelper:setTitle(title,callback)
    local tb = {}
    tb["cmd"]="user.settitle"
    tb["params"]={title=title}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("设置 称号",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 输入验证码领取奖励接口
function socketHelper:checkcodereward(callback)
    local tb = {}
    tb["cmd"]="user.checkcodereward"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("输入验证码领取奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 异星资源丰收周
function socketHelper:acalienbumperweekChoujiang(id,callback)
    local tb = {}
    tb["cmd"]="active.alienbumperweek"
    tb["params"]={id=id}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("异星资源丰收周领取奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 电磁坦克 组装
function socketHelper:acDiancitankeZuzhuang(num,aid,callback)
    local tb = {}
    tb["cmd"]="active.diancitanke"
    tb["params"]={action=2,aid=aid,num=num}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("电磁坦克 组装",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 电磁坦克 抽奖
function socketHelper:acDiancitankeChoujiang(mul,tid,free,callback)
    local tb = {}
    tb["cmd"]="active.diancitanke"
    tb["params"]={action=1,tid=tid,mul=mul,free=free}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("电磁坦克 抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 获取奖励中心数据
function socketHelper:getRewardCenterList(page,limit,callback)
    local tb = {}
    tb["cmd"]="rewardcenter.getlist"
    tb["params"]={page=page,limit=limit}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("获取奖励中心数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 领取奖励中心的奖励
function socketHelper:getRewardCenterReward(ids,callback)
    local tb = {}
    tb["cmd"]="rewardcenter.receive"
    tb["params"]={ids=ids}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("领取奖励中心的奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 月度将领 领奖
function socketHelper:acYueduHeroLingjiang(action,callback)
    local tb = {}
    tb["cmd"]="active.yuedujiangling"
    tb["params"]={action=action}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("月度将领 领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 月度将领2 领奖 "cmd":"active.ydjl2.reward"    刷新 "cmd":"active.ydjl2.refreward"
function socketHelper:acYueduHeroLingjiangTwo(action,sockStr,callback)
    local tb = {}
    tb["cmd"]=sockStr
    tb["params"]={action=action}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("月度将领2 领奖 或 刷新",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


-- 将领礼包（两将领） 抽奖  method =1  免费   2  是一次    3 是10次  action =rand  抽奖  ranklist  排行榜 rankreward  领取排行榜奖励  ? 是当前你自己的排行
function socketHelper:acHeroGiftSending(aCtion,method,callback,rank)
    local tb = {}
    tb["cmd"]="active.twohero"
    tb["params"]={action=aCtion,method=method,rank=rank}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("两将领 抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 配件互赠 领奖
function socketHelper:acPeijianhuzengLingjiang(id,callback)
    local tb = {}
    tb["cmd"]="active.sendaccessory"
    tb["params"]={id=id}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("配件互赠 领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 配件互赠 赠送
function socketHelper:acPeijianhuzengSendAccessory(mid,aid,callback)
    local tb = {}
    tb["cmd"]="accessory.send"
    tb["params"]={mid=mid,aid=aid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("配件互赠 赠送",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:acHaoshichengshuang(type,index,time,callback)
    local tb={}
    tb["cmd"]="active.haoshichengshuang"
    tb["params"]={action=type,index=index,refreshTs=time}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("好事成双",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 钢铁熔炉 action 1:熔炼 2:合成 3:任务奖励
function socketHelper:acGangtierongluTotal(action,tid,num,taskid,callback)
    local tb = {}
    tb["cmd"]="active.gangtieronglu"
    tb["params"]={action=action,tid=tid,num=num,taskid=taskid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("配件互赠 赠送",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:dailyTtjjLog(callback)
    local tb = {}
    tb["cmd"]="dailyactive.ttjj"
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("天天基金日志",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:dailyYdhkGetData(callback)
    local tb = {}
    tb["cmd"]="monthgive.monthgive.get"
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("月度回馈拉取数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:dailyYdhkGetReward(callback)
    local tb = {}
    tb["cmd"]="monthgive.monthgive.reward"
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("月度回馈领取金币",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- id对应的奖池,num抽奖的次数
function socketHelper:acSmbdGetReward(id,num,callback)
    local tb = {}
    tb["cmd"]="active.smbd.reward"
    tb["params"]={pool=id,count=num}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("使命必达抽奖结果",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:acThfbGetReward(id,num,callback)
    local tb = {}
    tb["cmd"]="active.thfb.buygift"
    tb["params"]={sid=id,num=num}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("特惠风暴购买礼包",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:acThfbGetTaskReward(id,callback)
    local tb = {}
    tb["cmd"]="active.thfb.taskreward"
    tb["params"]={tid=id}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("特惠风暴领取任务奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


function socketHelper:acMjzyGetReward(num,free,callback)
    local tb = {}
    tb["cmd"]="active.mjzy.draw"
    tb["params"]={num=num,free=free}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("名将支援抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:acMjzyGetLog(callback)
    local tb = {}
    tb["cmd"]="active.mjzy.getlog"
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("名将支援获取日志",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:acMjzyHeroSetting(sid,type,callback)
    local tb = {}
    tb["cmd"]="active.mjzy.appoint"
    tb["params"]={sid=sid,type=type}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("名将支援设置将领",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:acMjzyShopBuy(tid,tnum,callback)
    local tb = {}
    tb["cmd"]="active.mjzy.buyshop"
    tb["params"]={tid=tid,tnum=tnum}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("名将支援商店购买",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:xsjxGetReward(callback)
    local tb = {}
    tb["cmd"]="dailyactive.xsjx.reward"
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("限时惊喜领取奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:sxjxRefresh(callback)
    local tb = {}
    tb["cmd"]="dailyactive.xsjx.refresh"
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("限时惊喜刷新数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:xsjxDadian(t,callback)
    local tb = {}
    tb["cmd"]="dailyactive.xsjx.dadian"
    tb["params"]={t=t}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("限时惊喜打点",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:acXlysTask(tid,callback)
    local tb = {}
    tb["cmd"]="active.xlys.task"
    tb["params"]={tid=tid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("训练有素任务领取",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:acXlysTrain(num,free,callback)
    local tb = {}
    tb["cmd"]="active.xlys.draw"
    tb["params"]={num=num,free=free}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("训练有素训练",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:acXlysLog(callback)
    local tb = {}
    tb["cmd"]="active.xlys.getlog"
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("训练有素抽奖日志",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:acXcjhGetReward(num,free,callback)
    local tb = {}
    tb["cmd"]="active.xcjh.draw"
    tb["params"]={num=num,free=free}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("新春聚惠抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:acXcjhGetLog(callback)
    local tb = {}
    tb["cmd"]="active.xcjh.getlog"
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("新春聚惠日志",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:acXcjhGetNumber(callback)
    local tb = {}
    tb["cmd"]="active.xcjh.get"
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("获取奖券号码",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:acXcjhModify(lid,isall,callback)
    local tb = {}
    tb["cmd"]="active.xcjh.modify"
    tb["params"]={lid=lid,isall=isall}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("修改奖券号码",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:acXcjhTask(tid,callback)
    local tb = {}
    tb["cmd"]="active.xcjh.task"
    tb["params"]={tid=tid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("新春聚惠任务领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])

end

function socketHelper:acSmbdLog(callback)
    local tb = {}
    tb["cmd"]="active.smbd.getlog"
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("使命必达日志",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 装扮升级
function socketHelper:buildDecorateUpgrade(bid,callback)
    local tb = {}
    tb["cmd"]="map.exteriorup"
    tb["params"]={bid=bid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("基地装扮升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 装扮使用
function socketHelper:buildDecorateUse(bid,callback)
    local tb = {}
    tb["cmd"]="map.exteriorused"
    tb["params"]={bid=bid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("基地装扮使用",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 幸运拼点
function socketHelper:acXingyunpindianChoujiang(ctype,callback)
    local tb = {}
    tb["cmd"]="active.xingyunpindian"
    tb["params"]={ctype=ctype}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("幸运拼点 抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 单日消费  -- cid 金币档位序号，mid 奖励序号
function socketHelper:acDanrixiaofei(cid,mid,callback)
    local tb = {}
    tb["cmd"]="active.danrixiaofei"
    tb["params"]={cid=cid,mid=mid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("单日消费",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 单日充值  -- cid 金币档位序号，mid 奖励序号
function socketHelper:acDanrichongzhi(cid,mid,callback)
    local tb = {}
    tb["cmd"]="active.danrichongzhi"
    tb["params"]={cid=cid,mid=mid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("单日充值",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 充值送礼  -- cid 金币档位序号，mid 奖励序号
function socketHelper:acChongzhisongli(cid,mid,callback)
    local tb = {}
    tb["cmd"]="active.chongzhisongli"
    tb["params"]={cid=cid,mid=mid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("充值送礼",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 消费送礼  -- cid 金币档位序号，mid 奖励序号
function socketHelper:acXiaofeisongli(cid,mid,callback)
    local tb = {}
    tb["cmd"]="active.xiaofeisongli"
    tb["params"]={cid=cid,mid=mid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("xiaofeisongli",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 阅兵审查 改造
function socketHelper:acYuebingshenchaGaizao(num,aid,callback)
    local tb = {}
    tb["cmd"]="active.yuebingshencha"
    tb["params"]={action="upgrade",aid=aid,num=num}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("阅兵审查 改造",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 阅兵审查 抽奖
function socketHelper:acYuebingshenchaChoujiang(type,callback)
    local tb = {}
    tb["cmd"]="active.yuebingshencha"
    tb["params"]={action="rand",type=type}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("阅兵审查 抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 结晶开采 抽奖  type =0 免费  1 是普通  2是高级
function socketHelper:acJinjingkaicaiChoujiang(type,callback)
    local tb = {}
    tb["cmd"]="active.jiejingkaicai"
    tb["params"]={action="rand",type=type}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("结晶开采 抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 结晶开采 升级
function socketHelper:acJinjingkaicaiUpgrade(callback)
    local tb = {}
    tb["cmd"]="active.jiejingkaicai"
    tb["params"]={action="upgrade"}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("结晶开采 升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 结晶开采 领奖
function socketHelper:acJinjingkaicaiLingjiang(callback)
    local tb = {}
    tb["cmd"]="active.jiejingkaicai"
    tb["params"]={action="reward"}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("结晶开采 领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 每天答题数据中有未领取奖励的用户并且时间超过12点50没有收到后台主动推送的数据，则请求这个接口：
function socketHelper:sendReward(callback)
    local tb = {}
    tb["cmd"]="dailyactive.meiridati"
    tb["params"]={action="sendReward"}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("每日答题 领奖中心",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 元旦活动领取金币和礼包奖励，则请求这个接口：
function socketHelper:newyeargiftRequest(actionType,rewardType,callback)
    local tb = {}
    tb["cmd"]="active.newyeargift"
    tb["params"]={action=actionType,method=rewardType}
    
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("元旦获取领取金币或礼包",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--[[
福利双收活动请求接口
action : 
    1   暂时无用(帝国：点击加冕)
    2   赠送（额外参数: receiver:接收者UID  word:要赠送的道具ID）
    3   暂时无用(帝国：赠送记录)
    4   抽奖（额外参数: method: 1:单抽 2:十连抽   free: 1:免费 0:收费(或不传该参数)）
    5   兑换奖励（额外参数: tid:要兑换的序号   useprops:要扣除的道具id）
    6   领取钻石
    7   获取瓜分钻石数
    8   获取抽奖记录
--]]
function socketHelper:acFyssRequest(_paramsTab,_callback)
    local tb = {}
    tb["cmd"]="active.fuyunshuangshou"
    if _paramsTab[1] == 2 then
        tb["params"]={action=_paramsTab[1],receiver=_paramsTab[2],word=_paramsTab[3]}
    elseif _paramsTab[1] == 4 then
        tb["params"]={action=_paramsTab[1],method=_paramsTab[2],free=_paramsTab[3]}
    elseif _paramsTab[1] == 5 then
        tb["params"]={action=_paramsTab[1],tid=_paramsTab[2],useprops=_paramsTab[3]}
    else
        tb["params"]={action=_paramsTab[1]}
    end
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("福利双收活动请求接口：",requestStr)
    self:sendRequest(requestStr,_callback,tb["cmd"])
end

