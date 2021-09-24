friendVoApi=
{
    friends={},             --好友的数据，等级星级战力等
    gifts={},               --礼物的数据
    friendNum=nil,          --本服内好友的数目
    giftNum=nil,            --礼物箱中的礼物数目
    sendList={},            --发送过礼物的好友列表
    requestList={},         --索要过礼物的好友
    acceptNum=0,            --今日接受的礼物数目
    getLoginReward=false,   --是否领取过facebook登录奖励
    friendNumRewards={},    --领取好友总数奖励的情况
    inviteRewardTime=0,     --上次领取每日邀请奖励的时间戳
    invitable_friends={},   --部分平台(如kakao)没有提供网页api因此invitable_friens要靠游戏传过去
}

--获取好友功能的url前缀，如果是1000服就连tank-server-test，否则连tank-server
function friendVoApi:getFriendUrlPrefix()
    local prefix
    if G_isTestServer() == true then
        prefix="http://"..base.serverIp.."/tank-server-test/public/index.php/api/friends/"
    else
        prefix="http://"..base.serverIp.."/tank-server/public/index.php/api/friends/"
    end
    return prefix
end

--获取gucenter的url前缀
function friendVoApi:getGUCenterPrefix()
    local prefix
    if G_isTestServer() == true then
        prefix="http://"..base.serverUserIp.."/gucenter_test/"
    else
        local domainIp = serverCfg:gucenterServerIp() --gucenter访问地址
        prefix="http://"..domainIp.."/gucenter/"
    end
    return prefix
end

--重新从平台获取好友数据,每次调用方法都会从平台重新取好友
--callback:获取到数据之后执行的回调函数
function friendVoApi:refreshFriend(callback)
    if self.friends~=nil then
        for k,v in pairs(self.friends) do
            self.friends[k]=nil
        end
    end
    self.friends={}
    self.friendNum=nil
    self.friendcallback=callback
    local function onGetFriend(dataJson)
        self:onRefreshFriendEnd(dataJson)
    end
    self:getFriendFromFB(onGetFriend)
end

--从facebook获取好友
function friendVoApi:getFriendFromFB(callback)
    self.fbCallback=callback
    local tmpTb={}
    tmpTb["action"]="getfriend"
    tmpTb["parms"]={}
    tmpTb["parms"]["fields"]=G_Json.encode({"picture","name","installed"})
    tmpTb["parms"]["defaultIcon"]="public/defaultFBIcon.jpg"
    tmpTb["parms"]["limit"]=1000
    local cjson = G_Json.encode(tmpTb)
    G_accessCPlusFunction(cjson)
end

--从facebook获取好友的异步回调
function friendVoApi:onGetFriendFromFB(dataJson)
    if(self.fbCallback)then
        self.fbCallback(dataJson)
        self.fbCallback=nil
    end
end

function friendVoApi:onRefreshFriendEnd(dataJson)
    if(dataJson==nil or dataJson=="")then
        if(self.friendcallback~=nil)then
            self.friendcallback()
        end
        do return end
    end
    local platformFriendData = G_Json.decode(dataJson)
    --kakao special code
    if(G_isKakao())then
        if(platformFriendData.code~=0)then
            if(self.friendcallback~=nil)then
                self.friendcallback()
            end
            do return end
        end
        self.invitable_friends={}
        for k,v in pairs(platformFriendData.data.friends_info) do
            local invitableData={}
            invitableData.id=tostring(v.user_id)
            invitableData.name=v.nickname
            invitableData.picture=v.profile_image_url
            if(invitableData.picture=="")then
                invitableData.picture="public/defaultFBIcon.jpg"
            end
            invitableData.supported_device=v.supported_device       --true是安卓，false是IOS
            table.insert(self.invitable_friends,invitableData)
        end
        local tmpTb={}
        for k,v in pairs(platformFriendData.data.app_friends_info) do
            local tmp={}
            tmp.id=v.user_id
            tmp.picture=v.profile_image_url
            if(tmp.picture==nil or tmp.picture=="")then
                tmp.picture="public/defaultFBIcon.jpg"
            end
            tmp.name=v.nickname
            table.insert(tmpTb,tmp)
        end
        platformFriendData=tmpTb
    end
    local param={}
    for k,v in pairs(platformFriendData)do
        param[k]=v.id
    end

    local httpUrl=self:getGUCenterPrefix().."getuids.php"
    local reqParam="usernames="..G_Json.encode(param).."&zoneid="..base.curZoneID.."&key=uid"
    local mergeServer={}
    --合服之后的处理，需要扫一遍所有的老服
    local allServers
    if(serverCfg)then
        if(serverCfg.realAllServer)then
            allServers=serverCfg.realAllServer
        elseif(serverCfg.allserver)then
            allServers=serverCfg.allserver
        end
    end
    if allServers then
        for kk,vv in pairs(allServers) do
            for k,v in pairs(vv) do
                if(tonumber(base.curZoneID)==tonumber(v.zoneid) and v.oldzoneid)then
                    table.insert(mergeServer,tonumber(v.oldzoneid))
                end
            end
        end
    end
    if(#mergeServer>0)then
        reqParam=reqParam.."&oldzoneid="..G_Json.encode(mergeServer)
    end
    local retStr=G_sendHttpRequestPost(httpUrl,reqParam)
    deviceHelper:luaPrint(retStr)
    local friendIDs=G_Json.decode(retStr)
    local friendIDArr={}
    for uid,pid in pairs(friendIDs) do
        if(uid and pid)then
            table.insert(friendIDArr,uid)
        end
    end
    httpUrl=self:getFriendUrlPrefix().."list"
    reqParam="zoneid="..base.curZoneID.."&friends="..G_Json.encode(friendIDArr).."&uid="..playerVoApi:getUid().."&access_token=f343f395fa6d58e4a8917d787cb25ea2"
    retStr=G_sendHttpRequestPost(httpUrl,reqParam)
    deviceHelper:luaPrint(retStr)
    local friendsData=G_Json.decode(retStr)
    local hasSelf=false
    for k,v in pairs(friendsData)do
        v.username=v[1]
        v.lv=v[2]
        v.power=v[3]
        v.star=v[4]
        v[1],v[2],v[3],v[4]=nil
        v.id=k
        if(tostring(v.id)==tostring(playerVoApi:getUid()))then
            hasSelf=true
        end
        for uid,pid in pairs(friendIDs) do
            if(k==tostring(uid))then
                v.pid=pid
                break
            end
        end
        for k2,v2 in pairs(platformFriendData)do
            if(v.pid==v2.id)then
                v.picture=v2.picture
                v.pname=v2.name
                break
            end
        end
    end
    self:initFriend(friendsData)
    if(hasSelf==false)then
        local function onGetMyInfo(data)
            self:onGetMyPlatformInfo(data)
        end
        playerVoApi:getPlatformInfo({fields="picture,name"},onGetMyInfo)
    else
        if(self.friendcallback~=nil)then
            self.friendcallback()
        end        
    end
end

function friendVoApi:onGetMyPlatformInfo(data)
    if(data.id==nil or data.picture==nil or data.name==nil)then
        if(self.friendcallback~=nil)then
            self.friendcallback()
        end
        do return end
    end
    local fvo=friendVo:new()
    fvo.uid = playerVoApi:getUid()
    fvo.pid = data.id
    fvo.picture = data.picture
    if(fvo.picture==nil or fvo.picture=="")then
        fvo.picture="public/defaultFBIcon.jpg"
    end
    fvo.pname = data.name
    fvo.username = playerVoApi:getPlayerName()
    fvo.lv = playerVoApi:getPlayerLevel()
    fvo.power = playerVoApi:getPlayerPower()
    fvo.star=checkPointVoApi:getStarNum()
    table.insert(self.friends,fvo)
    if(self.friendcallback~=nil)then
        self.friendcallback()
    end
end

function friendVoApi:refreshGift(callback)
    if self.gifts~=nil then
        for k,v in pairs(self.gifts) do
            self.gifts[k]=nil
        end
    end
    self.gifts={}
    self.giftNum=nil
    local httpUrl=self:getFriendUrlPrefix().."gift/list"
    local reqParam="uid="..playerVoApi:getUid().."&zoneid="..base.curZoneID
    deviceHelper:luaPrint(httpUrl)
    deviceHelper:luaPrint(reqParam)
    local retStr=G_sendHttpRequestPost(httpUrl,reqParam)
    deviceHelper:luaPrint(retStr)
    local giftsData
    if(retStr=="")then
        giftsData=nil
    else
        giftsData=G_Json.decode(retStr)
    end
    self:initGift(giftsData)
    if(callback~=nil)then
        callback()
    end
end

function friendVoApi:initFriend(data)
    if data == nil then
        do return end
    end
    for k,v in pairs(data)do
        local fvo=friendVo:new()
        fvo:initWithData(v)
        if(fvo.pid~=nil)then
            table.insert(self.friends,fvo)
        end
    end
    self.friendNum=nil
end

function friendVoApi:initGift(data)
    if(data==nil or data.data==nil)then
        self.giftNum=0
        return
    end
    self.sendList={}
    self.requestList={}
    if(data.data[1]~=nil)then
        if(data.data[1]["gives"]~=nil)then
            for k,v in pairs(data.data[1]["gives"]) do
                if(k~="ts")then
                    table.insert(self.sendList,v)
                end
            end
        end
        if(data.data[1]["ask"]~=nil)then
            for k,v in pairs(data.data[1]["ask"]) do
                if(k~="ts")then
                    table.insert(self.requestList,v)
                end
            end
        end
        if(data.data[1]["accept"]~=nil and data.data[1]["accept"]["n"]~=nil)then
            self.acceptNum=tonumber(data.data[1]["accept"]["n"])
        end
    end
    if(data.data[2]~=nil)then
        for k,v in pairs(data.data[2])do
            local gvo=friendGiftVo:new()
            gvo:initWithData(v)
            self.gifts[k]=gvo
        end
    end
    self.giftNum=nil
end

function friendVoApi:getAllFriends()
    return self.friends;
end

function friendVoApi:getFriendNum()
    if(self.friendNum ~= nil)then
        return self.friendNum
    end
    local num = 0
    if self.friends~=nil then
        for k,v in pairs(self.friends) do
            num = num+1
        end
    end
    self.friendNum = num
    return num
end

function friendVoApi:getAllGifts()
    return self.gifts
end

function friendVoApi:getGiftNum()
    if(self.giftNum~=nil)then
        return self.giftNum
    end
    local num=0
    if(self.gifts~=nil)then
        for k,v in pairs(self.gifts)do
            num=num+1
        end
    end
    return num
end

function friendVoApi:getInvitedFriendData()
    local httpUrl=self:getFriendUrlPrefix().."invite/list"
    local reqStr="zoneid="..base.curZoneID.."&uid="..playerVoApi:getUid()
    deviceHelper:luaPrint(httpUrl)
    deviceHelper:luaPrint(reqStr)
    local retStr=G_sendHttpRequestPost(httpUrl,reqStr)
    deviceHelper:luaPrint(retStr)
    if(retStr=="" or retStr==nil)then
        retStr='{"ret":0,"data":[],"msg":"Success","count":0}'
    end
    return G_Json.decode(retStr)
end

--是否可以向该好友赠送礼物
function friendVoApi:checkCanSend(uid)
    if(tostring(uid)==tostring(playerVoApi:getUid()))then
        return false
    end
    if(self.sendList==nil)then
        return true
    end
    for k,v in pairs(self.sendList)do
        if(v==uid)then
            return false
        end
    end
    return true
end

--是否可以向该好友索取礼物
function friendVoApi:checkCanRequest(uid)
    if(tostring(uid)==tostring(playerVoApi:getUid()))then
        return false
    end
    if(self.requestList==nil)then
        return true
    end
    for k,v in pairs(self.requestList)do
        if(v==uid)then
            return false
        end
    end
    return true
end

--检查今天是否还可以收礼物
function friendVoApi:checkCanAccept()
    if(self.acceptNum==nil or self.acceptNum<5)then
        return true
    else
        return false
    end
end

--向好友赠送礼物
--return: 0表示超时，1表示赠送成功，2表示赠送失败
function friendVoApi:sendGift(fvo)
    if(self:checkCanSend(fvo.uid)==false)then
        return 2
    end
    local httpUrl=self:getFriendUrlPrefix().."gift/give"
    local reqStr="zoneid="..base.curZoneID.."&uid="..playerVoApi:getUid().."&name="..playerVoApi:getPlayerName().."&fname="..fvo.username.."&friend="..fvo.uid
        local retStr=G_sendHttpRequestPost(httpUrl,reqStr)
    if(retStr~="")then
        local ret=G_Json.decode(retStr)
        local function insertIntoSendList(fid)
            if(self.sendList==nil)then
                self.sendList={}
            end
            table.insert(self.sendList,fid)
        end
        if(ret.ret==-2008 or ret.ret==-2007)then
            insertIntoSendList(fvo.uid)
            return 2
        elseif(ret.ret==-2012)then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("friend_send_self"),nil,200)
            return 0
        elseif(ret.ret==0)then
            insertIntoSendList(fvo.uid)
            return 1
        else
            return 0
        end
    else
        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("timeout"),nil,200)
        return 0
    end
end

--向好友索要礼物
--return: 0表示超时，1表示赠送成功，2表示赠送失败
function friendVoApi:sendRequest(fvo)
    if(self:checkCanRequest(fvo.uid)==false)then
        return 2
    end
    local httpUrl=self:getFriendUrlPrefix().."gift/ask"
    local reqStr="zoneid="..base.curZoneID.."&uid="..playerVoApi:getUid().."&name="..playerVoApi:getPlayerName().."&fname="..fvo.username.."&friend="..fvo.uid
        local retStr=G_sendHttpRequestPost(httpUrl,reqStr)
    if(retStr~="")then
        local ret=G_Json.decode(retStr)
        local function insertIntoRequestList(fid)
            if(self.requestList==nil)then
                self.requestList={}
            end
            table.insert(self.requestList,fid)
        end
        if(ret.ret==-2008 or ret.ret==-2007)then
            insertIntoRequestList(fvo.uid)
            return 2
        elseif(ret.ret==-2012)then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("friend_ask_self"),nil,200)
            return 0
        elseif(ret.ret==0)then
            insertIntoRequestList(fvo.uid)
            return 1
        else
            return 0
        end
    else
        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("timeout"),nil,200)
        return 0
    end
end

--接收好友赠送的礼物
function friendVoApi:acceptGift(gvo,callback)
    local function onRequestCallback(fn,data)
        local ret,sData=base:checkServerData(data)
        if(ret==true)then
            for k,v in pairs(self.gifts) do
                if(v.id==gvo.id)then
                    table.remove(self.gifts,k)
                    break
                end
            end
            self.giftNum=nil
            self.acceptNum=self.acceptNum+1
            eventDispatcher:dispatchEvent("friend.gift")
        end
        callback(ret,sData)
    end
    socketHelper:getFriendGift(gvo.id,onRequestCallback)
end

--同意好友的索取
function friendVoApi:acceptRequest(gvo)
    if(self:checkCanSend(gvo.receiverid)==false)then
        return 2
    end
    local httpUrl=self:getFriendUrlPrefix().."gift/give"
    local reqStr="zoneid="..base.curZoneID.."&uid="..playerVoApi:getUid().."&name="..playerVoApi:getPlayerName().."&fname="..gvo.receivername.."&friend="..gvo.receiverid.."&gid="..gvo.id
        local retStr=G_sendHttpRequestPost(httpUrl,reqStr)
    if(retStr~="")then
        local ret=G_Json.decode(retStr)
        if(ret.ret==-2008 or ret.ret==-2007)then
            return 2
        elseif(ret.ret==-2012)then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("friend_send_self"),nil,200)
            return 0
        elseif(ret.ret==0)then
            for k,v in pairs(self.gifts) do
                if(v.id==gvo.id)then
                    table.remove(self.gifts,k)
                    break
                end
            end
            if(self.sendList==nil)then
                self.sendList={}
            end
            table.insert(self.sendList,gvo.receiverid)
            self.giftNum=nil
            return 1
        else
            return 0
        end
    else
        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("timeout"),nil,200)
        return 0
    end
end

function friendVoApi:showSocialView()
    local socialCfg=platCfg.platSocialViewCfg[G_curPlatName()]
    if(socialCfg==nil)then
        do return end
    end
    local httpUrl=self:getFriendUrlPrefix().."invite/list"
    local reqStr="zoneid="..base.curZoneID.."&uid="..playerVoApi:getUid()
        local retStr=G_sendHttpRequestPost(httpUrl,reqStr)
    deviceHelper:luaPrint(retStr)
    if(retStr~="")then
        local retData=G_Json.decode(retStr)
        if(retData["ret"]==0 or retData["ret"]=="0")then
            local tmpTb={}
            tmpTb["action"]="showSocialView"
            tmpTb["parms"]={}
            local pageIP
            local platName=G_curPlatName()
            --全球混服页面不在入口机，还在原平台的入口机
            --港台
            if(platName=="efunandroidtw" or platName=="3" or platName=="androidlongzhong" or platName=="0")then
                pageIP="tank001.efuntw.com"
            --北美
            elseif(platName=="14" or platName=="androidkunlun" or platName=="androidkunlunz")then
                pageIP="tank-na-in.raysns.com"
            --德国
            elseif(platName=="androidsevenga" or platName=="11")then
                pageIP="tank-ger-web01.raysns.com"
            else
                pageIP=base.serverUserIp
            end
            tmpTb["parms"]["url"]="http://"..pageIP.."/tankheroclient/webpage/rsocial/rayjoysocial.php"
            if((G_curPlatName()=="3" and G_Version>4) or (G_curPlatName()=="efunandroidtw" and G_Version>=10) or (G_curPlatName()=="androidlongzhong" and G_Version>=8) or G_curPlatName()=="efunandroidhuashuo" or G_curPlatName()=="androidlongzhong2")then
                tmpTb["parms"]["url"]="http://"..pageIP.."/tankheroclient/webpage2/rsocial/rayjoysocial.php"
            end
            tmpTb["parms"]["param"]={}
            tmpTb["parms"]["param"]["gamecode"]=socialCfg["gamecode"]
            tmpTb["parms"]["param"]["lang"]=G_getCurChoseLanguage()
            tmpTb["parms"]["param"]["num"]=retData["count"]
            if(retData["reward"])then
                tmpTb["parms"]["param"]["get"]=retData["reward"]
            end
            if(retData["inviteds"])then
                tmpTb["parms"]["param"]["invite"]=retData["inviteds"]
            end
            local cjson=G_Json.encode(tmpTb)
            G_accessCPlusFunction(cjson)
        end
    end
end

function friendVoApi:onSendAppRequest(dataJson)
    local data=G_Json.decode(dataJson)
    -- print("data[result]=============",data["result"])
    if(data["result"]=="0" or data["result"]==0)then
        -- print("G_curPlatName()=======",G_curPlatName())
        -- print("G_Version=============",G_Version)
        if (G_curPlatName()=="efunandroidtw" or G_curPlatName()=="3" or G_curPlatName()=="androidlongzhong" or G_curPlatName()=="androidlongzhong2" or G_curPlatName()=="0") then
            -- print("*********邀请好友成功*********")
            eventDispatcher:dispatchEvent("friend.onInviteFriend",data)
        end
       
        if(G_isKakao() or G_curPlatName()=="0")then
            eventDispatcher:dispatchEvent("friend.onSendAppRequest",data)
            return
        end
        local showNewSystem
        --如果是低版本的Efun港澳台, 那么无论是否配置了platFriendSystem2都走旧版逻辑
        if((G_curPlatName()=="efunandroidtw" and G_Version<10) or (G_curPlatName()=="3" and G_Version<=4))then
            showNewSystem=false
        --否则就根据platFriendSystem2配置来决定是否要走新版逻辑
        else
            if(platCfg.platFriendSystem2[G_curPlatName()])then
                showNewSystem=true
            else
                showNewSystem=false
            end            
        end
        if(showNewSystem)then
            if(self.inviteRewardTime==nil or self.inviteRewardTime<G_getWeeTs(base.serverTime))then
                local function onRequestEnd(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        local rewardCfg=friendCfg.inviteReward.reward
                        local reward=FormatItem(rewardCfg)
                        for k,v in pairs(reward) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num)
                        end
                    end
                end
                socketHelper:getFacebookReward("dailyFirst",nil,nil,onRequestEnd)
            end
        else
            local uid=data["uid"]
            if(uid and (#uid)>0)then
                local httpUrl=self:getFriendUrlPrefix().."invite/success"
                local reqStr="zoneid="..base.curZoneID.."&uid="..playerVoApi:getUid().."&fid="..table.concat(uid, ",")
                local retStr=G_sendHttpRequestPost(httpUrl,reqStr)
                if(retStr~="")then
                    local retData=G_Json.decode(retStr)
                    if(retData["ret"]==0 or retData["ret"]=="0")then
                        local tmpTb={}
                        tmpTb["action"]="removeWebView"
                        tmpTb["parms"]={}
                        local cjson=G_Json.encode(tmpTb)
                        G_accessCPlusFunction(cjson)
                        self:showSocialView()
                        local award=FormatItem(retData.reward) or {}
                        for k,v in pairs(award) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num)
                        end
                     end
                end
            end
        end
    end
end

function friendVoApi:getInviteFriendReward(dataJson)
    local data=G_Json.decode(dataJson)
    if(data["rewardIndex"])then
        local httpUrl=self:getFriendUrlPrefix().."invite/reward"
        local reqStr="zoneid="..base.curZoneID.."&uid="..playerVoApi:getUid().."&box="..data["rewardIndex"].."&platform="..G_curPlatName()
        deviceHelper:luaPrint(httpUrl)
        deviceHelper:luaPrint(reqStr)
            local retStr=G_sendHttpRequestPost(httpUrl,reqStr)
        deviceHelper:luaPrint(retStr)
        if(retStr~="")then
            local retData=G_Json.decode(retStr)
            if(retData["ret"]==0 or retData["ret"]=="0")then
                local award=FormatItem(retData.reward) or {}
                for k,v in pairs(award) do
                    G_addPlayerAward(v.type,v.key,v.id,v.num)
                end
            end
        end
    end
end

--因为FB把好友列表的机制做了调整, 所以新平台只能把邀请好友改成发feed了
function friendVoApi:sendInviteFeed()
    local function onSendFeedCallback()
        local isUpdateActive=false
        local activeName
        if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
            if acRoulette4VoApi then
                local vo=acRoulette4VoApi:getAcVo()
                if vo and activityVoApi:isStart(vo) then
                    if vo.feedNum and vo.feedNum==0 then
                        isUpdateActive=true
                        activeName=vo.type
                    end
                end
            end
        end
        local function onRequestEnd(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if isUpdateActive==true then
                    acRoulette4VoApi:addNum()
                end
            end
        end
        if(G_isKakao()==false)then
        if isUpdateActive==true then
            socketHelper:feedsaward(2,onRequestEnd,activeName)
        else
            socketHelper:feedsaward(2,onRequestEnd)
        end
    end
    end
    G_sendFeed(4,onSendFeedCallback)
end

--是否使用简版的好友功能，不用之前做的好友webview
function friendVoApi:checkIfSimpleFriend()
    if(platCfg.platSimpleFriend[G_curPlatName()]~=nil)then
        return true
    else
        return false
    end
end

function friendVoApi:showFriendDialog()
    require "luascript/script/game/scene/gamedialog/friend/friendDialog"
    require "luascript/script/config/gameconfig/friendCfg"
    if(platCfg.platFriendSystem2[G_curPlatName()])then
        require "luascript/script/game/scene/gamedialog/friend/friendDialogNew"
        require "luascript/script/game/scene/gamedialog/friend/friendDialogNewTabG"
        require "luascript/script/game/scene/gamedialog/friend/friendDialogNewTabGF"
        require "luascript/script/game/scene/gamedialog/friend/friendDialogNewTabGL"
        require "luascript/script/game/scene/gamedialog/friend/friendDialogNewTabF"
        if(G_isKakao() or G_curPlatName()=="0")then
            require "luascript/script/game/scene/gamedialog/friend/friendDialogNewTabGF_Kakao"
        end
        local td=friendDialogNew:new()
        local title=getlocal("friend_title")
        local tbArr={getlocal("friend_tab_gift"),getlocal("friend_title")}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,title,true,3)
        sceneGame:addChild(dialog,3)
    else
        require "luascript/script/game/scene/gamedialog/friend/friendDialogTab1"
        require "luascript/script/game/scene/gamedialog/friend/friendDialogTab2"
        local td=friendDialog:new()
        local title=getlocal("friend_title")
        local tbArr={getlocal("friend_tab_gift"),getlocal("friend_title")}
        local tbSubArr={getlocal("RankScene_level"),getlocal("showAttackRank"),getlocal("RankScene_star_num")}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,tbSubArr,nil,title,true,3)
        sceneGame:addChild(dialog,3)
    end
end

--用userinfo里面的数据进行初始化
function friendVoApi:initFBData(data)
    if(tonumber(data.us)==1)then
        self.getLoginReward=true
    else
        self.getLoginReward=false
    end
    local userRewards={}
    if(data.nt)then
        for k,v in pairs(data.nt) do
            userRewards[k]=tonumber(v)
        end
    end
    local oldLength=#self.friendNumRewards
    local newLength=#userRewards
    local dest
    if(oldLength>=newLength)then
        dest=oldLength
    else
        dest=newLength
    end
    for i=1,dest do
        if(self.friendNumRewards[i]==nil or self.friendNumRewards[i]==0)then
            self.friendNumRewards[i]=userRewards[i]
        end
    end
    self.inviteRewardTime=tonumber(data.dy)
    if(self.inviteRewardTime==nil)then
        self.inviteRewardTime=0
    end
end

--获取当前哪档好友数目奖励没有领取
--return result: 未领取的档次配置, 如果为nil表示所有奖励都已经领取
--return index: 未领取的是第几档奖励, 为0则表示全都领过了
function friendVoApi:getCurFriendsNumRewardCfg()
    local cfg=nil
    local index=0
    local length=#friendCfg.totalReward
    for i=length,1,-1 do
        if(self.friendNumRewards[i]==1)then
            cfg=friendCfg.totalReward[i+1]
            index=i+1
            if(index>length)then
                index=0
            end
            break
        end
        if(i==1 and self.friendNumRewards[i]~=1)then
            cfg=friendCfg.totalReward[1]
            index=1
            break
        end
    end
    return cfg,index
end

--获取下一档好友数目奖励
--return 下一档的配置, 如果为nil表示没有下一档了
function friendVoApi:getNextFriendsNumRewardCfg()
    local cfg=nil
    local length=#friendCfg.totalReward
    for i=length,1,-1 do
        if(self.friendNumRewards[i]==1)then
            cfg=friendCfg.totalReward[i+2]
            break
        end
        if(i==1 and self.friendNumRewards[i]~=1)then
            cfg=friendCfg.totalReward[2]
            index=2
            break
        end
    end
    return cfg
end

--领取好友数目奖励
--param index: 要领取的是第几档奖励 (1，2，3，4，5，6，7...)
--param fbID: 领奖的Facebook ID
function friendVoApi:getFriendNumReward(index,fbID,callback)
    local function onRequestEnd(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            local rewardCfg=friendCfg.totalReward[index].reward
            local reward=FormatItem(rewardCfg)
            for k,v in pairs(reward) do
                G_addPlayerAward(v.type,v.key,v.id,v.num)
            end
            self.friendNumRewards[index]=1
            if(callback)then
                callback()
            end
        end
    end
    socketHelper:getFacebookReward("invitation",index,fbID,onRequestEnd)
end

--从后台拉取某个Facebook号的好友数目领奖情况
--param fbID: 用户所用的Facebook ID
function friendVoApi:requestFriendNumRewardInfo(fbID,callback)
    local function onRequestEnd(fn,data)
        local ret,sData=base:checkServerData(data)
        if(ret==true)then
            local userRewards={}
            if(sData.data and sData.data.nt)then
                for k,v in pairs(sData.data.nt) do
                    userRewards[k]=tonumber(v)
                end
            end
            local oldLength=#self.friendNumRewards
            local newLength=#userRewards
            local dest
            if(oldLength>=newLength)then
                dest=oldLength
            else
                dest=newLength
            end
            for i=1,dest do
                if(self.friendNumRewards[i]==nil or self.friendNumRewards[i]==0)then
                    self.friendNumRewards[i]=userRewards[i]
                end
            end
            if(callback)then
                callback()
            end
        end
    end
    socketHelper:getFacebookReward("facebookUserinfo",nil,fbID,onRequestEnd)
end

function friendVoApi:clear()
    if self.friends~=nil then
        for k,v in pairs(self.friends) do
            self.friends[k]=nil
        end
    end
    self.friends={}
    self.friendNum=nil
    if(self.gifts~=nil)then
        for k,v in pairs(self.gifts)do
            self.gifts[k]=nil
        end
        self.gifts=nil
    end
    self.gifts={}
    self.giftNum=nil
    self.sendList={}
    self.requestList={}
    self.acceptNum=0
    self.getLoginReward=false
    self.friendNumRewards={}
    self.inviteRewardTime=0
    self.invitable_friends={}
end