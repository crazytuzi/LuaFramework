--socketHelper太长, 所以后续的拆出到这里来

--区域战, 进入战场, 初始化数据
--inifFlag: 是否是第一次初始化数据
function socketHelper:localWarRefresh(initFlag,aid,callback,showLoading)
    local tb = {}
    tb["cmd"]="areawar.get"
    tb["params"]={aid=aid}
    if(initFlag)then
        tb["params"]["init"]=1
    end
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("区域战初始化战场数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],showLoading)
end

--区域战玩家移动
function socketHelper:localWarMove(aid,targetID,callback)
    local tb={}
    tb["cmd"]="areawar.move"
    tb["params"]={aid=aid,target=targetID}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("区域战移动",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--区域战复活
function socketHelper:localWarRevive(aid,uid,callback)
    local tb={}
    tb["cmd"]="areawar.revive"
    tb["params"]={aid=aid,uid=uid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("区域战复活",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--区域战发送指挥命令
function socketHelper:localWarOrder(aid,uid,order,callback)
    local tb={}
    tb["cmd"]="areawar.sendcommand"
    tb["params"]={aid=aid,uid=uid,command=order}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("区域战发送指挥命令",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--区域战报名
--param aid: 军团ID
--param point: 投拍军团资金
function socketHelper:areawarApply(aid,point,callback)
    local tb = {}
    tb["cmd"]="areawar.apply"
    tb["params"]={aid=aid,point=point}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("区域战报名",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--区域战报名信息
--param aid: 军团ID
function socketHelper:areawarGetapply(aid,callback)
    local tb = {}
    tb["cmd"]="areawar.getapply"
    tb["params"]={aid=aid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("区域战报名信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--区域战排行榜
--param aid: 军团ID
function socketHelper:areawarApplyrank(callback)
    local tb = {}
    tb["cmd"]="areawar.applyrank"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("区域战排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--区域战设置职位
--param aid: 军团ID
--param jobid: 职位
--param memuid: 军团成员ID
function socketHelper:areawarSetjob(aid,jobid,memuid,callback)
    local tb = {}
    tb["cmd"]="areawar.setjob"
    tb["params"]={aid=aid,jobid=jobid,memuid=memuid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("区域战设置职位",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--区域战职位信息
--param aid: 军团ID
function socketHelper:areawarGetjobs(aid,callback)
    local tb = {}
    tb["cmd"]="areawar.getjobs"
    tb["params"]={aid=aid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("区域战职位信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--区域战王城的记录信息
function socketHelper:areawarGetcitylog(callback)
    local tb = {}
    tb["cmd"]="areawar.getcitylog"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("区域战王城记录",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--区域战部队信息
function socketHelper:areawarGetinfo(callback)
    local tb = {}
    tb["cmd"]="areawar.getinfo"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("区域战部队信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--区域战设置部队
-- wcount   连胜次数    waid  王城的军团id  acount  报名的数量
function socketHelper:areawarSetinfo(fleetinfo,hero,wcount,waid,acount,callback,emblemID,planePos,aitroops,airshipId)
    local tb = {}
    tb["cmd"]="areawar.setinfo"
    tb["params"]={fleetinfo=fleetinfo,hero=hero,wcount=wcount,waid=waid,acount=acount,equip=emblemID,plane=planePos,at=aitroops,ap=airshipId}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("区域战设置部队",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--战报列表
function socketHelper:areawarList(type,id,aid,callback)
    local tb = {}
    tb["cmd"]="areawar.list"
    tb["params"]={type=type,id=id,aid=aid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("战报列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--战报播放
function socketHelper:areawarReport(type,id,callback)
    local tb = {}
    tb["cmd"]="areawar.report"
    tb["params"]={type=type,id=id}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("战报播放",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--功绩排行榜
function socketHelper:areawarDonatelist(aid,uid,page,callback)
    local tb = {}
    tb["cmd"]="areawar.donatelist"
    tb["params"]={aid=aid,uid=uid,page=page}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("功绩排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--区域战获取当前部队
function socketHelper:areawarGettroops(aid,uid,callback)
    local tb = {}
    tb["cmd"]="areawar.gettroops"
    tb["params"]={aid=aid,uid=uid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("获取当前部队",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--获取超级武器神秘组织关卡信息
function socketHelper:weaponGetSWChallenge(callback)
    local tb = {}
    tb["cmd"]="weapon.getswchallenge"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("获取关卡信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--挑战超级武器神秘组织关卡 参数 target 目标关卡，buy 是否购买额外挑战次数，是true，否false（仅正常次数用完才才能买）
function socketHelper:weaponSWChallenge(params,callback)
    local tb = {}
    tb["cmd"]="weapon.swchallenge"
    tb["params"]=params
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("挑战关卡",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--重置超级武器神秘组织关卡 参数 free 是否免费，是true，否false
function socketHelper:weaponBuyRestnum(free,callback)
    local tb = {}
    tb["cmd"]="weapon.buyrestnum"
    tb["params"]={free=free}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("重置关卡",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--超级武器神秘组织关卡扫荡 参数 target 目标关卡
function socketHelper:weaponAutoBattle(target,callback)
    local tb = {}
    tb["cmd"]="weapon.autobattle"
    tb["params"]={target=target}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("开始扫荡",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--超级武器神秘组织关卡结束扫荡 参数 usegems 是否使用金币加速完成，是true，否false
function socketHelper:weaponFinautoBattle(usegems,callback)
    local tb = {}
    tb["cmd"]="weapon.finautobattle"
    tb["params"]={usegems=usegems}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("结束扫荡",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--超级武器关卡排行榜 参数 page 页数
function socketHelper:weaponGetswchallengerank(page,callback)
    local tb = {}
    tb["cmd"]="weapon.getswchallengerank"
    tb["params"]={page=page}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("关卡排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--超级武器装备武器
--param equipTb: 六个位置的武器id, eg: {"w1","w2",0,0,"w3","w4}
function socketHelper:weaponWareEquip(equipTb,callback)
    local tb = {}
    tb["cmd"]="weapon.useweapon"
    tb["params"]={wids=equipTb}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("装备武器",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--超级武器购买专家
--param id: 1 or 2, 购买哪个专家
--param num: 购买多少次
function socketHelper:weaponBuyExpert(id,num,callback)
    local tb = {}
    tb["cmd"]="weapon.buy"
    tb["params"]={id=id,num=num}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("购买专家",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--超级武器强化重构
--param weaponID: 要强化的武器ID
--param att: 要强化的属性
--param type: 普通重构还是自动重构
function socketHelper:weaponRebuild(weaponID,att,type,callback)
    local tb = {}
    tb["cmd"]="weapon.streng"
    tb["params"]={wid=weaponID,sid=att,type=type}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("强化重构",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 获取超级武器的所有信息
function socketHelper:getWeaponInfo(callback)
    local tb = {}
    tb["cmd"]="weapon.get"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("超级武器所有数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 强化能量结晶
function socketHelper:mergeCrystal(cid,tarcid,callback,num,stableChose)
    
    local tb = {}
    tb["cmd"]="weapon.mixcrystal"
    if stableChose then
        tb["params"]={cid=cid,tarcid=tarcid,num=num,gearid=stableChose}
    else
        tb["params"]={cid=cid,tarcid=tarcid,num=num}
    end
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("强化能量结晶：",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])

end
-- 镶嵌能量结晶,cid结晶的id,wid：超级武器的id
function socketHelper:usecrystal(cid,wid,callback)
    local tb = {}
    tb["cmd"]="weapon.usecrystal"
    tb["params"]={cid=cid,wid=wid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("镶嵌能量结晶：",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 卸载能量结晶,p1第一个结晶孔,wid：超级武器的id
function socketHelper:uncrystal(p,wid,callback)
    local tb = {}
    tb["cmd"]="weapon.uncrystal"
    tb["params"]={p=p,wid=wid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("卸载能量结晶",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 合成超级武器
function socketHelper:weaponCompose(wid,callback)
    local tb = {}
    tb["cmd"]="weapon.compose"
    tb["params"]={wid=wid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("合成超级武器：",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 升级超级武器加经验
function socketHelper:weaponUpgrade(wid,useProp,callback)
    local tb = {}
    tb["cmd"]="weapon.upgrade"
    tb["params"]={wid=wid,use=useProp}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("升级超级武器：",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 超级武器抢夺列表,fid:碎片id,usegems:是否金币刷新，true是，false不是
function socketHelper:weaponGetroblist(fid,usegems,free,callback)
    local tb = {}
    tb["cmd"]="weapon.getroblist"
    tb["params"]={fid=fid,usegems=usegems,free=free}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("抢夺列表：",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:weaponGetExplorelist(fid,auto,callback)
    local tb = {}
    tb["cmd"]="weapon.explore"
    tb["params"]={fid=fid,auto=auto}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("超级武器探索列表：",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 抢夺战斗接口
function socketHelper:weaponBattle(data,callback)
    local tb = {}
    tb["cmd"]="weapon.battle"
    tb["params"]=data
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("抢夺战斗接口：",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--抢夺战报列表
function socketHelper:weaponGetlog(mineid,maxeid,isPage,callback,ifShowLoading,content)
    local tb={}
    tb["cmd"]="weapon.getlog"
    tb["params"]={mineid=mineid,maxeid=maxeid,content=content}
    if isPage~=nil then
        tb["params"].isPage=isPage
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("抢夺战报列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],ifShowLoading)
end
--抢夺战报content，战斗数据
function socketHelper:weaponRead(eid,callback,set)
    local tb={}
    tb["cmd"]="weapon.read"
    tb["params"]={eid=eid,set=set}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("抢夺战报content",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--金币购买免战
function socketHelper:weaponBuyprotect(callback)
    local tb={}
    tb["cmd"]="weapon.buyprotect"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("金币购买免战",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--金币购买体力
function socketHelper:weaponBuyenergy(callback)
    local tb={}
    tb["cmd"]="weapon.buyenergy"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("金币购买体力",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--设置防守部队
function socketHelper:weaponSettroops(fleetinfo,hero,callback,emblemId,planePos,aitroops,airshipId)
    local tb={}
    tb["cmd"]="weapon.settroops"
    tb["params"]={fleetinfo=fleetinfo,hero=hero,equip=emblemId,plane=planePos,at=aitroops,ap=airshipId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("设置防守部队",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--平台战, 初始化数据
function socketHelper:platWarInit(callback)
    local tb = {}
    tb["cmd"]="platwar.crossinit"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("平台战初始化数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--平台战刷新战场数据
function socketHelper:platWarRefresh(callback)
    local tb = {}
    tb["cmd"]="platwar.get"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("平台战刷新战场数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--平台战设置部队
function socketHelper:platwarSetinfo(line,fleetinfo,hero,callback,emblemID,planePos,aitroops,airshipId)
    local tb={}
    tb["cmd"]="platwar.setinfo"
    tb["params"]={line=line,fleetinfo=fleetinfo,hero=hero,equip=emblemID,plane=planePos,at=aitroops,ap=airshipId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("平台战设置部队",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end
--平台战获取部队
function socketHelper:platwarGetinfo(callback)
    local tb={}
    tb["cmd"]="platwar.getinfo"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("平台战获取部队",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end
--平台战设置线路
function socketHelper:platwarSetline(line,callback)
    local tb={}
    tb["cmd"]="platwar.setline"
    tb["params"]={line=line}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("平台战设置线路",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end
--平台战捐献部队和金币
-- type=1 捐金币，pid 是捐那挡的
-- type=2 捐坦克，fid 是第几档，pid 是第几个位置的坦克，num 是数量
function socketHelper:platwarDonate(type,pid,fid,num,callback)
    local tb={}
    tb["cmd"]="platwar.donate"
    tb["params"]={type=type,pid=pid,fid=fid,num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("捐献部队和金币",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end
function socketHelper:platwarRanklist(action,callback)
    local tb={}
    tb["cmd"]="platwar.ranklist"
    tb["params"]={action=action}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("平台战排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end
--平台战购买物品
function socketHelper:platwarBuy(sType,tId,callback)
    local tb={}
    tb["cmd"]="platwar.buy"
    tb["params"]={sType=sType,tId=tId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("平台战购买物品",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end
--平台战积分明细
function socketHelper:platwarGetpointlog(callback)
    local tb={}
    tb["cmd"]="platwar.getpointlog"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("平台战积分明细",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end
--平台战买buff
--buffID: 要购买的buffID
function socketHelper:platWarBuyBuff(buffID,callback)
    local tb={}
    tb["cmd"]="platwar.buybuff"
    tb["params"]={sid=buffID}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("平台战买buff",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end
--平台战战报列表
function socketHelper:platwarReport(action,callback,mineid,maxeid)
    local tb={}
    tb["cmd"]="platwar.report"
    tb["params"]={action=action,mineid=mineid,maxeid=maxeid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("平台战战报列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end
--平台战战报播放
function socketHelper:platwarGetreport(id,callback)
    local tb={}
    tb["cmd"]="platwar.getreport"
    tb["params"]={id=id}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("平台战战报播放",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end
--平台战事件
function socketHelper:platwarGetevents(mineid,maxeid,callback)
    local tb={}
    tb["cmd"]="platwar.getevents"
    tb["params"]={mineid=mineid,maxeid=maxeid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("平台战事件",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end
--领取排行榜奖励
--action：1 捐献排行，2 战斗排行
function socketHelper:platwarGetrankreward(action,rank,callback)
    local tb={}
    tb["cmd"]="platwar.getrankreward"
    tb["params"]={action=action,rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领取排行榜奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end
--发送跨平台信息
--参数：action：0内部 1公共，content：内容
function socketHelper:platwarSendmsg(action,content,callback)
    local tb={}
    tb["cmd"]="platwar.sendmsg"
    tb["params"]={action=action,content=content}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("发送跨平台信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isShowLoading)
end

--积分翻牌
function socketHelper:jifenfanpai(action,callback)
    local tb={}
    tb["cmd"]="active.jifenfanpai"
    tb["params"]={action=action}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("积分翻牌",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--购买临时建造队列
function socketHelper:buyTmpBuildSlot(callback)
    local tb={}
    tb["cmd"]="user.buytempslot"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("购买临时建造队列",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--闯关达人活动排行榜，新版个人关卡争霸
function socketHelper:getChallengeRankList(callback)
    local tb={}
    tb["cmd"]="active.challengeranknew"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("闯关达人排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--新战力大比拼活动排行榜
function socketHelper:getFightRankNewList(sIndex,eIndex,callback)
    local tb={}
    tb["cmd"]="active.fightranknew"
    tb["params"]={sIndex = sIndex, eIndex = eIndex}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新战战力大比拼排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--勇往直前活动
--param action: 1 领取关卡通过奖励 2 领取每日任务奖励
--param sid: s1，s2  领取第几关的奖励
function socketHelper:activityMoveForwardReward(action,sid,callback)
    local tb={}
    tb["cmd"]="active.yongwangzhiqian"
    tb["params"]={action=action,sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("勇往直前活动",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--勇往直前2018活动
--param action: 1 领取关卡通过奖励 2 领取每日任务奖励
--param sid: s1，s2  领取第几关的奖励
function socketHelper:activityYwzqReward(action,sid,callback)
    local tb={}
    tb["cmd"]="active.ywzq"
    tb["params"]={action=action,sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("勇往直前2018活动",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--新服拉霸 别名招财猫
function socketHelper:willLottering(action,callback)
    local tb={}
    tb["cmd"]="active.xinfulaba"
    tb["params"]={action=action}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新服拉霸",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--获取天梯榜信息
function socketHelper:getLadderInfo(callback)
    local tb={}
    tb["cmd"]="skyladder.get"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("天梯榜信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--获取各个大战对阵表数据
function socketHelper:getLadderGroup(gkey,callback)
    local tb={}
    tb["cmd"]="skyladder.getgroup"
    tb["params"]={gkey=gkey}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("对阵表信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--天梯商店兑换物品
function socketHelper:useLadderTicket(sid,callback)
    local tb={}
    tb["cmd"]="skyladder.useticket"
    tb["params"]={sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("天梯商店",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--天梯名人堂数据
function socketHelper:getLadderHistory(page,callback)
    local tb={}
    tb["cmd"]="skyladder.gethistory"
    tb["params"]={page=page}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("名人堂数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--天梯排行榜数据action 1个人 2 军团
function socketHelper:getLadderRank(action,callback)
    local tb={}
    tb["cmd"]="skyladder.getrank"
    tb["params"]={action=action}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("天梯排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--天梯积分明细数据action 1个人 2 军团
function socketHelper:getLadderLog(action,callback)
    local tb={}
    tb["cmd"]="skyladder.getlog"
    tb["params"]={action=action}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("积分明细",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--群雄争霸报名
function socketHelper:areateamwarApply(aid,callback)
    local tb={}
    tb["cmd"]="areateamwar.apply"
    tb["params"]={aid=aid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("群雄争霸报名",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 先写到 这 之后确认  秦艳兵
-- 报名军团信息 报名清单
function socketHelper:getRegistrationlist(callback)
    local tb={}
    tb["cmd"]="areateamwar.applyrank"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("群雄争霸 报名军团清单",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 群雄争霸初始化
function socketHelper:areateamwarCrossinit(callback,ref)
    local tb={}
    tb["cmd"]="areateamwar.crossinit"
    tb["params"]={ref=ref}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("群雄争霸初始化",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 群雄争霸设置部队
-- params:clear=1 清除所有部队
-- params:usegems=1000 设置带入的军饷参数
-- params:line,fleetinfo,hero 设置部队的参数
-- params:emblemID 军徽
function socketHelper:areateamwarSetinfo(usegems,line,fleetinfo,hero,callback,clear,group,emblemID,planePos,aitroops,airshipId)
    print("emblemID",emblemID)
    local tb={}
    tb["cmd"]="areateamwar.setinfo"
    tb["params"]={usegems=usegems,line=line,fleetinfo=fleetinfo,hero=hero,clear=clear,group=group,equip=emblemID,plane=planePos,at=aitroops,ap=airshipId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("群雄争霸设置部队",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 群雄争霸商店购买物品
function socketHelper:areateamwarBuy(tId,callback)
    local tb={}
    tb["cmd"]="areateamwar.buy"
    tb["params"]={tId=tId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("群雄争霸商店购买物品",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 群雄争霸获取报名信息
function socketHelper:areateamwarGetapply(callback)
    local tb={}
    tb["cmd"]="areateamwar.getapply"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("群雄争霸获取报名信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 群雄争霸提取军饷
function socketHelper:areateamwarTakegems(gems,callback)
    local tb={}
    tb["cmd"]="areateamwar.takegems"
    tb["params"]={gems=gems}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("群雄争霸提取军饷",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 群雄争霸获取积分明细
function socketHelper:areateamwarPointlog(callback)
    local tb={}
    tb["cmd"]="areateamwar.pointlog"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("群雄争霸获取积分明细",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--双十一2018
function socketHelper:doubleOnePanicBuying( callback,action,shop,sid,shophour )
    local tb={}
    tb["cmd"] ="active.new112018"
    tb["params"] ={action=action,shop=shop,sid =sid,shophour = shophour}
    self:addBaseInfo(tb)
    local  requestStr = G_Json.encode(tb)
    print("双十一2018版 抢购",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--双十一
function socketHelper:double11PanicBuying( callback,action,shop,sid,shophour )
    local tb={}
    tb["cmd"] ="active.doubleeleven"
    tb["params"] ={action=action,shop=shop,sid =sid,shophour = shophour}
    self:addBaseInfo(tb)
    local  requestStr = G_Json.encode(tb)
    print("双十一 抢购",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--双十一新版
function socketHelper:double11NewPanicBuying( callback,action,shop,sid,shophour,redid,redtype,redcount,redmethod)
    local tb={}
    tb["cmd"] ="active.doubleelevennew"
    tb["params"] ={action=action,shop=shop,sid =sid,shophour = shophour,redid = redid,redtype = redtype,redcount = redcount,redmethod = redmethod}
    self:addBaseInfo(tb)
    local  requestStr = G_Json.encode(tb)
    print("双十一新版 抢购",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--不给糖就捣蛋
function socketHelper:halloweenReward(action,callback,pid,ptype,wtype)
    local tb={}
    tb["cmd"]="active.halloween"
    tb["params"]={action=action,pid=pid,ptype=ptype,wtype=wtype}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("不给糖就捣蛋",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 万圣节大作战
-- 参数：
-- action 1 开炮消除，2 领取任务奖励
-- index 选中的位置id，tid 任务id，free 是否免费，true是，false不是
function socketHelper:activeWanshengjiedazuozhan(action,index,tid,free,callback)
    local tb={}
    tb["cmd"]="active.wanshengjiedazuozhan"
    tb["params"]={action=action,index=index,tid=tid,free=free}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("万圣节大作战",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--获取将领装备信息,hc=1返回装备探索数据
function socketHelper:getHeroEquip(callback,hc)
    local tb={}
    tb["cmd"]="equip.get"
    tb["params"]={hc=hc}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获取装备信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--获取装备探索关卡数据
function socketHelper:getEquipExploreList(minsid,maxsid,callback)
    local tb={}
    tb["cmd"]="hchallenge.list"
    tb["params"]={minsid=minsid,maxsid=maxsid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("装备探索列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--扫荡准备探索关卡action 1 单次扫荡，0为剩余全部次数，sid关卡id
function socketHelper:equipMultiplebattle(action,sid,callback,ifShowLoading)
    local tb={}
    tb["cmd"]="hchallenge.multiplebattle"
    tb["params"]={action=action,sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("扫荡装备关卡",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],ifShowLoading)
end
--装备探索打关卡
function socketHelper:equipbattle(data,callback)
    local tb={}
    tb["cmd"]="hchallenge.battle"
    tb["params"]=data
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("装备探索打关卡",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--强化装备(hid：英雄id，pid:装备id,method:1单次强化，2一键强化)
function socketHelper:equipUpgrade(hid,pid,method,callback)
    local tb={}
    tb["cmd"]="equip.upgrade"
    tb["params"]={hid=hid,pid=pid,method=method}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("强化装备",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--装备升品阶(hid：英雄id，pid:装备id)
function socketHelper:equipAdvance(hid,pid,callback)
    local tb={}
    tb["cmd"]="equip.advance"
    tb["params"]={hid=hid,pid=pid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("装备升品阶",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--装备觉醒(hid：英雄id，pid:装备id)
function socketHelper:equipAwaken(hid,pid,callback)
    local tb={}
    tb["cmd"]="equip.awaken"
    tb["params"]={hid=hid,pid=pid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("装备觉醒",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--装备研究type =1 是免费的  =2 是不免费的（pid=1是使用道具抽奖否则是花钱的）  =3是十连抽只花钱
function socketHelper:equipLottery(type,pid,callback)
    local tb={}
    tb["cmd"]="equip.lottery"
    tb["params"]={type=type,pid=pid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("装备研究",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--装备关卡购买重置次数
function socketHelper:equipBuyrestnum(sid,callback)
    local tb={}
    tb["cmd"]="hchallenge.buyrestnum"
    tb["params"]={sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("购买重置次数",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--装备关卡领取章节奖励
function socketHelper:equipGetReward(sid,callback)
    local tb={}
    tb["cmd"]="hchallenge.getreward"
    tb["params"]={sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领取章节奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 觉醒商店 购买
function socketHelper:awakeShopBuy(tId,callback)
    local tb={}
    tb["cmd"]="equip.buy"
    tb["params"]={tId=tId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("觉醒商店 购买",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 远征 扫荡
function socketHelper:expeditionRaid(callback)
    local tb = {}
    tb["cmd"]="expedition.raid"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("远征 扫荡",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 远征 手动刷新
function socketHelper:expeditionRefshop(callback)
    local tb = {}
    tb["cmd"]="expedition.refshop"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("远征 手动刷新商店",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--新军事演习 商店
function socketHelper:shamBattleGetshop(callback)
    local tb={}
    tb["cmd"]="military.getshop"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新军事演习 商店",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军演商店购买
function socketHelper:shamBattleBuy(id,pid,count,callback)
    local tb={}
    tb["cmd"]="military.buyshop"
    tb["params"]={id=id,pid=pid,count=count}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军演商店购买",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])

end

-- 军演 手动刷新
function socketHelper:shamBattleRefshop(callback)
    local tb = {}
    tb["cmd"]="military.refshop"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("军演 手动刷新商店",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 军演 手动刷新
function socketHelper:shamBattleGetScoreReward(pid,callback)
    local tb = {}
    tb["cmd"]="military.dayreward"
    tb["params"]={pid=pid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("军演 领取积分奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 军演 得到攻打玩家信息
function socketHelper:shamBattleGetFleetInfo(tid,callback)
    local tb = {}
    tb["cmd"]="military.getinfo"
    tb["params"]={tid=tid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("军演 得到攻打玩家信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 军演 刷新攻击列表
function socketHelper:shamBattleRefreshAttaklist(callback)
    local tb = {}
    tb["cmd"]="military.reflist"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("军演 刷新攻击列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 活动 感恩节回馈
function socketHelper:thanksGivingYou(callback,action,tid,type)
    local tb = {}
    tb["cmd"]="active.ganenjiehuikui"
    tb["params"]={action=action,type=type,tid=tid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("活动 感恩节回馈",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--台湾的老玩家回归活动改版
function socketHelper:activityOldUserReturnTw(action,tid,callback)
    local tb = {}
    tb["cmd"]="active.olduserreturntw"
    tb["params"]={action=action}
    if(tid)then
        tb["params"]["tid"]=tid
    end
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("台湾的老玩家回归活动改版",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 活动 圣诞前夕
function socketHelper:chrisEveSend(callback,action,method,sid,tuid,rank,user)
    local tb = {}
    tb["cmd"]="active.shengdanqianxi"
    tb["params"]={action=action,method=method,sid=sid,tuid=tuid,rank=rank,user=user}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("活动 圣诞前夕",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--战术研讨 action 1 发表意见 2 提起抗议 3 结束研讨
--        tid 1 普通意见 2 集中讨论
function socketHelper:zhanshuyantao(action,callback,tid,free)
    local tb={}
    tb["cmd"]="active.zhanshuyantao"
    tb["params"]={action=action,tid=tid,free=free}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("战术研讨~~",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


-- 购买建筑自动升级
function socketHelper:autoUpgradeBuildings(callback,useGem)
    local tb={}
    tb["cmd"]="building.buyautoupgrade"
    tb["params"]={useGem=useGem}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    -- print("购买建筑自动升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 建筑自动升级开启
function socketHelper:autoUpgradeBuildingsTurnOn(callback)
    local tb={}
    tb["cmd"]="building.switchautoupgrade"
    tb["params"]={on=1}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    -- print("开启建筑自动升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 建筑自动升级关闭
function socketHelper:autoUpgradeBuildingsTurnOff(callback)
    local tb={}
    tb["cmd"]="building.switchautoupgrade"
    tb["params"]={on=0}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    -- print("关闭建筑自动升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 建筑自动升级实时刷新
function socketHelper:autoUpgradesyc(bid,buildType,callback)
    local tb={}
    tb["cmd"]="building.upgradeautosync"
    tb["params"]={bid=bid,buildType=buildType}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    -- print("刷新建筑自动升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 圣诞节大作战活动数据
-- action = "get" 是获取恶魔状态，初始化
-- action = "rand"   抽奖   额外参数 method =1 是免费的  =2 是一次  =3 是十连抽
-- action = "rank"   排行榜   额外参数  method=1 是活跃   =2 是贡献榜
-- action = "rankreward"  排行榜奖励   额外参数 mthod=1 是活跃奖励  =2 是贡献奖励   rank =1 是前端传的排名  
-- action = "devote"  贡献到达一定值的奖励   额外参数  method =1  某档
function socketHelper:activeChristmasfight(action,method,callback,rank)
    local tb={}
    tb["cmd"]="active.christmasfight"
    tb["params"]={action=action,method=method,rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("圣诞节大作战",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--配件道具合成新道具
--param count: 合成的数目
function socketHelper:accessoryComposeProp(count,callback)
    local tb={}
    tb["cmd"]="accessory.change"
    tb["params"]={count=count}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("配件道具合成新道具",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 名将再临 method 1 十连抽 0 单抽
function socketHelper:activityMingjiangzailinChoujiang(method,shop,callback)
    local tb={}
    tb["cmd"]="active.mingjiangzailin"
    tb["params"]={method=method,action="rand",shop=shop}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("名将再临 抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:activityMingjiangzailinLog(callback)
    local tb={}
    tb["cmd"]="active.mingjiangzailin"
    tb["params"]={action="getlog"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("名将再临 记录",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--精英坦克改造成普通坦克
function socketHelper:eTankConformCommon(tank,count,callback)
    local tb = {}
    tb["cmd"]="alien.upgradetroops"
    tb["params"]={tank=tank,count=count}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("精英坦克改造成普通坦克",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--战术研讨 action 1 发表意见 2 提起抗议 3 结束研讨
--        tid 1 普通意见 2 集中讨论
function socketHelper:zhanshuyantao(action,callback,tid,free)
    local tb={}
    tb["cmd"]="active.zhanshuyantao"
    tb["params"]={action=action,tid=tid,free=free}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("战术研讨~~",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--遗迹再探 获取奖励列表
function socketHelper:activityYijizaitanRewardList(callback)
    local tb={}
    tb["cmd"]="active.yijizaitan"
    tb["params"]={action="getlist"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("遗迹再探 获取奖励列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--遗迹再探 探索
function socketHelper:activityYijizaitanTansuo(num,callback)
    local tb={}
    tb["cmd"]="active.yijizaitan"
    tb["params"]={action="getreward",num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("遗迹再探 探索",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--遗迹再探 改装坦克
function socketHelper:activityYijizaitanRefitTank(num,aid,callback)
    local tb={}
    tb["cmd"]="active.yijizaitan"
    tb["params"]={action="upgrade",num=num,aid=aid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("遗迹再探 改装坦克",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 购买建筑自动升级
function socketHelper:autoUpgradeBuildings(callback,useGem)
    local tb={}
    tb["cmd"]="building.buyautoupgrade"
    tb["params"]={useGem=useGem}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    -- print("购买建筑自动升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 建筑自动升级开启
function socketHelper:autoUpgradeBuildingsTurnOn(callback)
    local tb={}
    tb["cmd"]="building.switchautoupgrade"
    tb["params"]={on=1}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    -- print("开启建筑自动升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 建筑自动升级关闭
function socketHelper:autoUpgradeBuildingsTurnOff(callback)
    local tb={}
    tb["cmd"]="building.switchautoupgrade"
    tb["params"]={on=0}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    -- print("关闭建筑自动升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 建筑自动升级实时刷新
function socketHelper:autoUpgradesyc(bid,buildType,callback)
    local tb={}
    tb["cmd"]="building.upgradeautosync"
    tb["params"]={bid=bid,buildType=buildType}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    -- print("刷新建筑自动升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--配件绑定
function socketHelper:accessoryBind(tankID,partID,callback)
    local tb={}
    tb["cmd"]="accessory.band"
    tb["params"]={type=tankID,ptype=partID}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("配件绑定",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--配件突破 stayLv:是否保留改造等级 1为保留，需要花费金币
function socketHelper:acessoryEvolution(tankID,partID,callback,stayLv)
    local tb={}
    tb["cmd"]="accessory.breach"
    tb["params"]={type=tankID,ptype=partID,b=stayLv}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("配件突破",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--配件科技升级
function socketHelper:acessoryTechUpgrade(tankID,partID,techID,callback)
    local tb={}
    tb["cmd"]="accessory.upgradetech"
    tb["params"]={type=tankID,ptype=partID,sid=techID}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("配件科技升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--配件科技更换
function socketHelper:acessoryTechChange(tankID,partID,techID,callback)
    local tb={}
    tb["cmd"]="accessory.changetech"
    tb["params"]={type=tankID,ptype=partID,sid=techID}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("配件科技更换",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 一键合成结晶level:目标等级，ctype：类型
function socketHelper:mergeAllCrystal(level,ctype,callback)
    local tb={}
    tb["cmd"]="weapon.batchmix"
    tb["params"]={level=level,ctype=ctype}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("一键合成结晶",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--组装坦克，都用这个接口
-- "aid": "a10124", —- 坦克id
-- "num": 14,  —- 本次改造数量
-- "activeName": "yichujifa"   —- 活动名称
function socketHelper:buildUpTank(num,aid,activeName,callback)
    local tb={}
    tb["cmd"]="troop.specialupgrade"
    tb["params"]={num=num,aid=aid,activeName=activeName}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("组装坦克",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- params:
-- free:是否使用免费次数 值为1时是使用免费次数，不是使用免费时可以不传，
-- digType:挖掘类型，1是普通挖掘，其它值是深度挖掘
-- action:1是抽奖，2是重置，3是获取演示战报
-- free值为1时，后端会强制digType的值为1
function socketHelper:yichujifa(callback,action,digType,free)
    local tb={}
    tb["cmd"]="active.yichujifa"
    tb["params"]={action=action,digType=digType,free=free}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("一触即发~~",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 坦克大战 排行榜
function socketHelper:acTankBattleRanklist(callback)
    local tb={}
    tb["cmd"]="active.tankbattle"
    tb["params"]={action="ranklist"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("坦克大战 排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 坦克大战 排行榜奖励
function socketHelper:acTankBattleRankreward(rank,callback)
    local tb={}
    tb["cmd"]="active.tankbattle"
    tb["params"]={action="rankreward",rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("坦克大战 排行榜奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 坦克大战 开始
function socketHelper:acTankBattleStart(count,callback)
    local tb={}
    tb["cmd"]="active.tankbattle"
    tb["params"]={action="attack",count=count}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("坦克大战 开始",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 坦克大战 结束
function socketHelper:acTankBattleEnd(count,point,sid,callback)
    local tb={}
    tb["cmd"]="active.tankbattle"
    tb["params"]={action="endbattle",count=count,point=point,sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("坦克大战 结束",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 坦克大战 设置
function socketHelper:acTankBattleSet(sid,callback)
    local tb={}
    tb["cmd"]="active.tankbattle"
    tb["params"]={action="set",sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("坦克大战 设置",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 获取新年除夕之夜活动的信息
function socketHelper:getNewYearEvaInfo(callback,isloading)
    local tb={}
    tb["cmd"]="active.newyeareva"
    tb["params"]={action="get"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新年除夕之夜活动的信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],isloading)
end

function socketHelper:acNewYearsEveGetLog(callback )
    local tb={}
    tb["cmd"]="active.newyeareva"
    tb["params"]={action="getlog"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新年除夕之夜活动 抽奖记录",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:attackEvaTank(attackHeros,tankFleetinfo,attackCost,callback,emblemID,planePos,aitroops,airshipId)
    local tb={}
    tb["cmd"]="active.newyeareva"
    tb["params"]={action="attack",hero=attackHeros,fleetinfo=tankFleetinfo,gems=attackCost,equip=emblemID,plane=planePos,at=aitroops,ap=airshipId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("带部队攻击年兽",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:firecrackerAttack(attackType,callback)
    local tb={}
    tb["cmd"]="active.newyeareva"
    tb["params"]={action="firecracker",method=attackType}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("爆竹攻击年兽",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 除夕活动排行榜
-- action:1."ranklist"排行榜，2."rankreward"排行榜领奖
-- method=1 单次排行榜，2 累计排行榜
-- rank 名次，排行榜领奖前后台校验
function socketHelper:activeNewyeareva(action,method,rank,callback)
    local tb={}
    tb["cmd"]="active.newyeareva"
    tb["params"]={action=action,method=method,rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("除夕活动排行榜和领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 春节攀升计划活动
-- cmd : active.chunjiepansheng
-- action 
-- 1 领取任务点奖励 参数:tid 1~n 领取第几档
-- 2 领取每日任务奖励 参数:day 1~n ，tid 任务id 第几天的第几档
-- 3 领取每日所有任务完成宝箱奖励 参数: day 1~n 第几天
function socketHelper:acChunjiepanshengTaskReward(action,day,tid,callback,type)
    local tb={}
    tb["cmd"]="active.chunjiepansheng"
    tb["params"]={action=action,day=day,tid=tid,type=type}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("春节攀升 奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--使劲突击
--addType : rank(排行榜)
function socketHelper:acSmcjSocket(addType,parmTb,callback)
    local tb     = {}
    tb["cmd"]    = "active.smcj."..addType
    tb["params"] = parmTb
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("使劲突击 addType :",addType)
    print("使劲突击 ",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--免费加速升级建筑
function socketHelper:freeUpgradeBuild(bid,btype,callback)
    local tb={}
    tb["cmd"]="building.freespeedup"
    tb["params"]={bid=bid,buildType=btype}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("免费加速建筑升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--免费加速科技研究
function socketHelper:freeUpgradeTech(tid,callback)
    local slotVo=technologySlotVoApi:getSlotByTid(tid)
    if slotVo==nil then
        do return end
    end
    local tb={}
    tb["cmd"]="tech.freespeedup"
    tb["params"]={tid=tid,slotid=slotVo.slotid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("免费加速科技研究",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end
--科技升级发送军团协助
function socketHelper:techAlliancehelp(slotid,callback)
    local tb={}
    tb["cmd"]="tech.alliancehelp"
    tb["params"]={slotid=slotid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("科技升级发送军团协助",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end
--建筑升级发送军团协助
function socketHelper:buildingAlliancehelp(bid,btype,callback)
    local tb={}
    tb["cmd"]="building.alliancehelp"
    tb["params"]={bid=bid,buildType=btype}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("建筑升级发送军团协助",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end
--军团协助帮助列表
function socketHelper:allianceHelplist(maxid,minid,callback)
    local tb={}
    tb["cmd"]="alliance.helplist"
    tb["params"]={maxid=maxid,minid=minid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团协助帮助列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end
--军团协助帮助
function socketHelper:allianceHelp(id,callback)
    local tb={}
    tb["cmd"]="alliance.help"
    tb["params"]={id=id}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军团协助帮助",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end
--周年庆活动领奖
function socketHelper:activityAnniversary(action,method,callback)
    local tb={}
    tb["cmd"]="active.anniversary"
    tb["params"]={action=action,method=method}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("周年庆活动领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end
--获取自己的帮助列表和帮助信息
function socketHelper:allianceMyhelp(type,callback)
    local tb={}
    tb["cmd"]="alliance.myhelp"
    tb["params"]={type=type}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获取自己的帮助列表和帮助信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end

-----------以下新军团战------------
--新军团战报名
--param aid: 报名的军团ID
--param point: 报名投拍的军团资金数
--param areaid: 投标的城市ID
function socketHelper:alliancewarnewApply(aid,point,areaid,callback)
    local tb={}
    tb["cmd"]="alliancewarnew.apply"
    tb["params"]={aid=aid,point=point,areaid=areaid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新军团战报名",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end
--新军团战设置部队
function socketHelper:alliancewarnewSetinfo(fleetinfo,hero,callback,emblemID,planePos,aitroops,airshipId)
    local tb={}
    tb["cmd"]="alliancewarnew.setinfo"
    tb["params"]={fleetinfo=fleetinfo,hero=hero,equip=emblemID,plane=planePos,at=aitroops,ap=airshipId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新军团战设置部队",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end
--获取军团战某个城市的报名信息
--param cityID: 要获取信息的城市ID
function socketHelper:alliancewarnewGetCityInfo(paramAid,cityID,callback)
    local tb={}
    tb["cmd"]="alliancewarnew.applyrank"
    tb["params"]={aid=paramAid,areaid=cityID}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新军团战城市报名信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--获取新军团的报名和占领信息
--param paramAid: 军团的ID
--(只是开放的战场是两个,开战时间只有一个)
function socketHelper:alliancewarnewGetapply(paramAid,callback)
    local tb={}
    tb["cmd"]="alliancewarnew.getapply"
    tb["params"]={aid=paramAid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新军团的报名和占领信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 新军团战购买BUFF
function socketHelper:alliancewarnewBuybuff(buff,callback,positionId)
    local tb={}
    tb["cmd"]="alliancewarnew.buybuff"
    tb["params"]={buff=buff,positionId=positionId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新军团战购买BUFF",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 新军团战重新集结 placeId 小地点 [1-9] postionId 大战场 [1-8]
function socketHelper:alliancewarnewRegroup(placeId,positionId,callback)
    local tb={}
    tb["cmd"]="alliancewarnew.regroup"
    tb["params"]={placeId="h"..placeId,positionId=positionId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新军团战重新集结",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 新军团战获取战场信息 positionId 大战场 [1-4]
function socketHelper:alliancewarnewGet(positionId,init,callback)
    local tb={}
    tb["cmd"]="alliancewarnew.get"
    tb["params"]={positionId=positionId,init=init}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新军团战获取战场信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 新军团战战斗 placeId 小地点 [1-9] positionId 大战场 [1-8] useGem 是否直接金币直接战斗 fleetinfo 部队信息，与其它战斗格式一样
function socketHelper:alliancewarnewBattle(placeId,positionId,useGem,fleetinfo,callback,hero,aitroops)
    local tb={}
    tb["cmd"]="alliancewarnew.battle"
    tb["params"]={placeId="h"..placeId,positionId=positionId,useGem=useGem,fleetinfo=fleetinfo,hero=hero,at=aitroops}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新军团战斗",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 新军团战加速集结
function socketHelper:alliancewarnewBuycdtime(callback)
    local tb={}
    tb["cmd"]="alliancewarnew.buycdtime"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新军团战加速集结",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 新军团战战报
function socketHelper:alliancewarnewGetbattlelog(warid,type,aid,uid,minTs,maxTs,callback)
    local tb={}
    tb["cmd"]="alliancewarnew.getbattlelog"
    tb["params"]={warid=warid,type=type,aid=aid,uid=uid,minTs=minTs,maxTs=maxTs}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新军团战战报",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-----------以上新军团战------------

--口令红包发请求
function socketHelper:activeKoulinghongbao(callback)
    local tb={}
    tb["cmd"]="active.koulinghongbao"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("口令红包发请求",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end


--异元战场获取报名信息
function socketHelper:userwarGetapply(callback)
    local tb={}
    tb["cmd"]="userwar.getapply"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("异元战场获取报名信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end
--异元战场报名和设置部队
function socketHelper:userwarApply(fleetinfo,hero,callback,emblemID,planePos,aitroops,airshipId)
    local tb={}
    tb["cmd"]="userwar.apply"
    tb["params"]={fleetinfo=fleetinfo,hero=hero,equip=emblemID,plane=planePos,at=aitroops,ap=airshipId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("异元战场报名和设置部队",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end

--异次元战场初始化战场
function socketHelper:dimensionalWarRefresh(callback)
    local tb = {}
    tb["cmd"]="userwar.getmap"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("异次元战场初始化战场",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--异次元战场移动
--param line: 第几行
--param row: 第几列
function socketHelper:dimensionalWarMove(line,row,callback)
    local tb = {}
    tb["cmd"]="userwar.move"
    tb["params"]={x=line,y=row}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("异次元战场移动",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--异次元战场停留
--param type: 1普通休整，2高级休整
function socketHelper:dimensionalWarStay(type,callback)
    local tb = {}
    tb["cmd"]="userwar.stay"
    tb["params"]={action=type}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("异次元战场停留",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--异次元战场探索
--param type: 1普通探索，2高级探索
function socketHelper:dimensionalWarSearch(type,callback)
    local tb = {}
    tb["cmd"]="userwar.discovery"
    tb["params"]={action=type}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("异次元战场探索",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--异次元战场躲猫猫
function socketHelper:dimensionalWarHide(callback)
    local tb = {}
    tb["cmd"]="userwar.hide"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("异次元战场躲猫猫",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--异次元战场设置陷阱
--param type: 1陷阱 2污染
function socketHelper:dimensionalWarTrap(type,callback)
    local tb = {}
    tb["cmd"]="userwar.settrap"
    tb["params"]={action=type}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("异次元战场设置陷阱",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--异次元战场选择战斗
function socketHelper:dimensionalWarFight(callback)
    local tb = {}
    tb["cmd"]="userwar.readybattle"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("异次元战场选择战斗",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--异次元战场补给 补充体力
function socketHelper:dimensionalWarBuyEnergy(callback)
    local tb = {}
    tb["cmd"]="userwar.buyenergy"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("异次元战场补给 补充体力",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--异次元战场补给 补充部队
function socketHelper:dimensionalWarBuyTroop(callback)
    local tb = {}
    tb["cmd"]="userwar.addtroops"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("异次元战场补给 补充部队",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--异次元战场补给 清除异常状态
function socketHelper:dimensionalWarBuyDebuff(callback)
    local tb = {}
    tb["cmd"]="userwar.clearStatus"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("异次元战场补给 清除异常状态",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--异元战场商店购买
function socketHelper:userwarBuy(tId,callback)
    local tb={}
    tb["cmd"]="userwar.buy"
    tb["params"]={tId=tId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("异元战场商店购买",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end
--异元战场积分明细
function socketHelper:userwarGetpointlog(callback)
    local tb={}
    tb["cmd"]="userwar.getpointlog"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("异元战场积分明细",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end
--异元战场事件列表
function socketHelper:userwarGeteventlist(bid,maxeid,mineid,callback)
    local tb={}
    tb["cmd"]="userwar.geteventlist"
    tb["params"]={bid=bid,maxeid=maxeid,mineid=mineid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("异元战场事件列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end
--异元战场排行榜
-- status=0 生者
--       =1 是亡者
--       如果我沒在排行榜內 顯示排名100  生者積分就是point1   亡者積分 point2
function socketHelper:userwarRanklist(status,callback)
    local tb={}
    tb["cmd"]="userwar.ranklist"
    tb["params"]={status=status}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("异元战场排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end
--异元战场战报
function socketHelper:userwarGetreport(id,callback)
    local tb={}
    tb["cmd"]="userwar.getreport"
    tb["params"]={id=id}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("异元战场战报",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end

--充值大比拼
function socketHelper:activeRechargeGame(callback)
    local tb = {}
    tb["cmd"]="active.rechargecompetition"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("充值大比拼",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--每日装备计划领取奖励接口
function socketHelper:dailyEquipPlanGetRewards(curTaskId,callback)
    local tb={}
    tb["cmd"]="active.dailyequipplan"
    tb["params"]={taskId=curTaskId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("每日装备计划领取奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 经验书转成经验（一键使用经验书）
function socketHelper:bookChangeExp(pids,callback)
    local tb={}
    tb["cmd"]="hero.useprop"
    tb["params"]={pids=pids}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("经验书转成经验",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end

-- 一键升级将领
function socketHelper:oneUpgradeHero(level,hid,callback)
    local tb={}
    tb["cmd"]="hero.addheroexp"
    tb["params"]={level=level,hid=hid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("一键升级将领",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end

--活动：攻陷要塞
function socketHelper:stormFortressSock(callback,action,num,free,taskId )
    local tb={}
    tb["cmd"]="active.stormfortress"
    tb["params"]={action=action,num=num,free=free,taskId=taskId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("攻陷要塞",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])  
end

--限时精工石商店活动兑换接口
function socketHelper:seikoStoneShopBuy(propId,callback)
    local tb={}
    tb["cmd"]="active.seikoshop"
    tb["params"]={itemId=propId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("限时精工石商店活动兑换道具",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--金币恢复繁荣度
function socketHelper:renewGloryByGold(callback)
    local tb={}
    tb["cmd"]="boom.buy"
    tb["params"]={index = 1}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("金币恢复繁荣度",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--刷新繁荣度数据api_boom_test
function socketHelper:refreshGloryData(callback )
    local tb={}
    tb["cmd"]="boom.test"
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("刷新繁荣度数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--跨服战设置部队出战顺序
function socketHelper:serverWarSetline(line,callback)
    local tb={}
    tb["cmd"]="cross.setline"
    tb["params"]={line=line}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("跨服战设置部队出战顺序",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--周年狂欢活动获取每天邀请好友数量的接口
function socketHelper:syncInviteCount(count,callback)
    local tb={}
    tb["cmd"]="active.anniverbless"
    tb["params"]={action=1,invite=count}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("周年狂欢活动获取每天邀请好友数量的接口",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--周年狂欢活动获取每天邀请好友获取的五福礼包的接口
function socketHelper:receiveInviteGift(callback)
    local tb={}
    tb["cmd"]="active.anniverbless"
    tb["params"]={action=2}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("周年狂欢活动获取每天邀请好友获取的五福礼包的接口",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--周年狂欢活动赠送好友福字的接口
function socketHelper:donateWordToFriend(receiverUid,wordKeyTb,callback)
    local tb={}
    tb["cmd"]="active.anniverbless"
    tb["params"]={action=3,words=wordKeyTb,receiver=receiverUid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("周年狂欢活动赠送好友福字的接口",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--周年狂欢活动获取赠送记录的接口
function socketHelper:syncRecordList(callback)
    local tb={}
    tb["cmd"]="active.anniverbless"
    tb["params"]={action=4}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("周年狂欢活动获取赠送记录的接口",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--周年狂欢活动领取能量补给接口
function socketHelper:receiveSupplyGift(tid,callback)
    local tb={}
    tb["cmd"]="active.anniverbless"
    tb["params"]={action=5,taskId=tid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("周年狂欢活动领取能量补给接口",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--周年狂欢活动同步集齐五福玩家个数的接口
function socketHelper:syncFinishNum(callback)
    local tb={}
    tb["cmd"]="active.anniverbless"
    tb["params"]={action=6}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("周年狂欢活动同步集齐五福玩家个数的接口",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--福运转盘活动抽奖接口(freeFlag=1 时表示免费，rewardNum=1 是单抽，10为10连抽)
function socketHelper:blessWheelLottery(freeFlag,rewardNum,callback)
    local tb={}
    tb["cmd"]="active.blessingwheel"
    tb["params"]={num=rewardNum,free=freeFlag}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("福运转盘活动抽奖接口",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--获取新技能鹰眼的数据
function socketHelper:skillEagleEye(callback)
    local tb={}
    tb["cmd"]="skill.eagleeye"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获取新技能鹰眼的数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--新技能系统勋章兑换
--param pid: 要兑换的道具ID
function socketHelper:skillGetProp(pid,callback)
    local tb={}
    tb["cmd"]="skill.change"
    tb["params"]={pid=pid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获取新技能鹰眼的数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 获取军团boss副本信息
function socketHelper:allianceBossGet(callback)
    local tb={}
    tb["cmd"]="achallenge.getboss"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获取军团boss副本信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 攻击军团副本boss
function socketHelper:allianceBossAttack(data,callback)
   local tb={}
    tb["cmd"]="achallenge.battleboss"
    tb["params"]=data
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("攻击军团副本boss",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 一键领取军团副本军需箱 sids:普通副本id，boss副本军需箱的个数
function socketHelper:allianceRewardGetOneTime(sids,bcount,callback)
   local tb={}
    tb["cmd"]="achallenge.rewardlist"
    tb["params"]={sids=sids,bcount=bcount}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("一键领取军团副本军需箱",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--雷达搜索
-- "action": 1, 1是侦察基地，2是侦察采矿部队
-- "targetName": "fdsfsdf"
-- "lastTs": 没有就是0，action==2时，上侦查部队的时间
function socketHelper:mapRadarscan(action,targetName,lastTs,callback)
    local tb={}
    tb["cmd"]="map.radarscan"
    tb["params"]={action=action,targetName=targetName,lastTs=lastTs}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("雷达搜索",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--红包赠送
-- "fUid": 3000216, - 好友ID
-- "pid": 3306 - 赠送的道具ID
function socketHelper:friendsSend(fUid,pid,callback)
    local tb={}
    tb["cmd"]="friends.send"
    tb["params"]={fUid=fUid,pid=pid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("红包赠送",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 月度签到领取奖励    action =1付费领奖  0免费领奖   day = 第几天的奖励
function socketHelper:monthlysignGetReward(action,day,callback)
    local tb = {}
    tb["cmd"]="active.monthlysign"
    tb["params"]={action=action,day=day}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("月度签到领取奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:acBuyreward(action,free,aname,callback)
    local tb={}
    tb["cmd"]="active.buyreward"
    tb["params"]={action=action,free=free,aname=aname}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("韩国通用绿色活动",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--充值礼包活动的接口，（领取奖励和获取排行榜）
function socketHelper:rechargebagRequest(action,method,rank,callback)
    local tb={}
    tb["cmd"]="active.rechargebag"
    tb["params"]={action=action,method=method,rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("充值礼包活动的接口",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 配件嘉年华
function socketHelper:acPjjnh(action,free,num,aname,method,callback)
    local tb={}
    tb["cmd"]="active.pjjnh"
    tb["params"]={action=action,free=free,num=num,aname=aname,method=method}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("配件嘉年华",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--free":true,"action":1,"aname":"luckcard","awardNum":"awardNum"
function socketHelper:acLuckyPokerSoc(free,action,aname,num,callback)
    local tb={}
    tb["cmd"]="active.luckcard"
    tb["params"]={action=action,free=free,aname=aname,num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("幸运翻牌",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--"action":1,"aname":"olympic","awardNum":"awardNum"
function socketHelper:acOlympicSoc(action,aname,callback)
    local tb={}
    tb["cmd"]="active.olympic"
    tb["params"]={action=action,aname=aname}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("奥运五环",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--奔赴前线活动领取积分奖励接口
function socketHelper:receiveIntegralRewards(rewardId,callback)
    local tb={}
    tb["cmd"]="active.benfuqianxian"
    tb["params"]={rewardId=rewardId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("奔赴前线活动领取积分奖励接口",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 奥运集章活动
-- cmd : active.aoyunjizhang
-- action 
-- 1 领取任务点奖励 参数:tid 1~n 领取第几档
-- 2 领取每日任务奖励 参数:day 1~n ，tid 任务id 第几天的第几档，type：任务的key
-- 3 领取每日所有任务完成宝箱奖励 参数: day 1~n 第几天
function socketHelper:acOlympicTaskReward(action,day,tid,type,callback)
    local tb={}
    tb["cmd"]="active.aoyunjizhang"
    tb["params"]={action=action,day=day,tid=tid,type=type}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("奥运集章活动领取奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--名将培养活动抽奖以及获取抽奖记录的接口
function socketHelper:trainHeroLottery(trainType,isFree,callback)
    local tb={}
    tb["cmd"]="active.mingjiangpeiyang"
    tb["params"]={action=trainType,free=isFree}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("名将培养活动抽奖以及获取抽奖记录的接口",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--叛军初始化数据
function socketHelper:alliancerebelGet(callback,isGet)
    local tb={}
    tb["cmd"]="alliancerebel.get"
    tb["params"]={}
    if(isGet)then
        tb["params"]={get=isGet}
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("叛军初始化数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--侦查叛军
function socketHelper:mapRebelscout(target,callback)
    local tb={}
    tb["cmd"]="map.rebelscout"
    tb["params"]={target=target}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("侦查叛军",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--叛军购买体力
function socketHelper:rebelBuyEnergy(buyNum,cost,callback)
    local tb={}
    tb["cmd"]="alliancerebel.buyenergy"
    tb["params"]={num=buyNum,cost=cost}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("叛军购买体力",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 军徽进阶
-- elist：装备列表
-- useGems：是否使用钻石
--need：指定获得的进阶军徽
function socketHelper:emblemAdvance(elist,useGems,callback,need)
    local tb={}
    tb["cmd"]="sequip.upgrade"
    tb["params"]={elist=elist,useGems=useGems,need = need}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军徽进阶",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--抽军徽
--type 获取消耗稀土还是钻石   num 是抽1次 还是5次
function socketHelper:emblemAdd(type,num,callback)
    local tb={}
    if(type==1)then
        tb["cmd"]="sequip.addequip.bygold"
    else
        tb["cmd"]="sequip.addequip.byr5"
    end
    tb["params"]={count=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("抽军徽",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 军徽升级
-- eid：装备id
function socketHelper:emblemLevelUp(eid,useGems,callback)
    local tb={}
    tb["cmd"]="sequip.levelup"
    tb["params"]={eid=eid,useGems=useGems}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军徽升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 军徽分解
-- elist：装备列表
function socketHelper:emblemDecompose(eid,callback)
    local tb={}
    tb["cmd"]="sequip.resolve"
    tb["params"]={eid=eid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军徽单个分解",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 军徽批量分解
-- elist：装备列表
function socketHelper:emblemBulkSale(clist,callback)
    local tb={}
    tb["cmd"]="sequip.resolve"
    tb["params"]={clist=clist}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军徽批量分解",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 刷新军徽生产钻石邮件
function socketHelper:refreshGemsMail(callback)
    local tb={}
    tb["cmd"]="sequip.checkaward"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("刷新军徽生产钻石邮件",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--中秋赏月活动刷新任务，领取任务奖励接口
function socketHelper:midAutumnRequest(action,cost,key,num,rank,callback,taskType,gt)
    local tb={}
    tb["cmd"]="active.midautumn"
    tb["params"]={action=action,cost=cost,t=key,num=num,rank=rank,type=taskType,gt=gt}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("中秋赏月活动刷新任务，领取任务奖励接口",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--购买扫荡令
function socketHelper:challengeBuy(cost,callback)
    local tb={}
    tb["cmd"]="challenge.buy"
    tb["params"]={cost=cost}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("购买扫荡令",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--关卡扫荡 defender关卡，tanks升级精英坦克信息，num扫荡次数
-- "params":{"defender":1,"tanks":{{"a10001",1}},"num":1}
function socketHelper:challengeRaid(defender,tanks,num,callback)
    local tb={}
    tb["cmd"]="challenge.raid"
    tb["params"]={defender=defender,tanks=tanks,num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("关卡扫荡",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军资截获（打飞机）活动
function socketHelper:activityAntiAir(action,num,callback)
    local tb={}
    tb["cmd"]="active.battleplane"
    tb["params"]={action=action,num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军资截获（打飞机）活动",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 技能书熔炼
function socketHelper:heroSmelt(method,level,item,cost,callback,num)
    local tb={}
    tb["cmd"]="hero.melting"
    tb["params"]={method=method,level=level,item=item,cost=cost,num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("技能书熔炼",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--战友集结令活动初始化
function socketHelper:activeZhanyoujijieInit(callback)
    local tb={}
    tb["cmd"]="active.zhanyoujijie.init"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("战友集结令活动初始化",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--战友集结令活动绑定,inviteCode:邀请码
function socketHelper:activeZhanyoujijieBind(inviteCode,callback)
    local tb={}
    tb["cmd"]="active.zhanyoujijie.bind"
    tb["params"]={inviteCode=inviteCode}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("战友集结令活动绑定",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--大将召回活动绑定 ，inviteCode:邀请码
function socketHelper:activeGeneralRecall(cmd,params,callback)
    local tb={}
    tb["cmd"]=cmd
    tb["params"]=params or {}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("大将召回活动",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--战友集结令活动充值信息
function socketHelper:activeZhanyoujijieRechargeInfo(callback)
    local tb={}
    tb["cmd"]="active.zhanyoujijie.rechargeInfo"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("战友集结令活动充值信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--战友集结令活动充值列表,bindUid：绑定的玩家uid
function socketHelper:activeZhanyoujijieRechargeList(bindUid,callback)
    local tb={}
    tb["cmd"]="active.zhanyoujijie.rechargeList"
    tb["params"]={bindUid=bindUid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("战友集结令活动充值列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--战友集结令活动领取充值奖励,rid：领取第几个奖励
function socketHelper:activeZhanyoujijieRechargeReward(rid,callback)
    local tb={}
    tb["cmd"]="active.zhanyoujijie.rechargeReward"
    tb["params"]={rid=rid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("战友集结令活动领取充值奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--战友集结令活动领取绑定奖励,bindUid：绑定的玩家uid
function socketHelper:activeZhanyoujijieBindReward(bindUid,callback)
    local tb={}
    tb["cmd"]="active.zhanyoujijie.bindReward"
    tb["params"]={bindUid=bindUid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("战友集结令活动领取绑定奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--战友集结令活动领取回归奖励
function socketHelper:activeZhanyoujijieLoginReward(callback)
    local tb={}
    tb["cmd"]="active.zhanyoujijie.loginReward"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("战友集结令活动领取回归奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--战友集结令活动领取用户金币
function socketHelper:activeZhanyoujijieTakeUserGems(bindUid,gems,callback)
    local tb={}
    tb["cmd"]="active.zhanyoujijie.takeUserGems"
    tb["params"]={bindUid=bindUid,gems=gems}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("战友集结令活动领取用户金币",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--战友集结令活动领取全部金币
function socketHelper:activeZhanyoujijieTakeUsersGems(gems,callback)
    local tb={}
    tb["cmd"]="active.zhanyoujijie.takeUsersGems"
    tb["params"]={gems=gems}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("战友集结令活动领取全部金币",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--三周年庆活动
function socketHelper:activityThreeYear(action,tid,shop,id,cost,callback)
    local tb={}
    tb["cmd"]="active.threeyear"
    tb["params"]={action=action,tid=tid,shop=shop,id=id,cost=cost}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("三周年庆活动",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--国庆狂欢 大富翁 活动
function socketHelper:activityGqkh(action,sid,point,free,rate,callback)
    local tb={}
    tb["cmd"]="active.gqkh"
    tb["params"]={action=action,sid=sid,point=point,free=free,rate=rate}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("国庆狂欢 活动",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--抢夺战报删除（eid为nil时为删除全部战报）
function socketHelper:weaponDelete(eid,callback)
    local tb={}
    tb["cmd"]="weapon.delete"
    tb["params"]={eid=eid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("抢夺战报删除",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--每日任务最新版领取活跃奖励
function socketHelper:dailytaskRewardPoint(tid,callback)
    local tb={}
    tb["cmd"]="dailytask.reward.point"
    tb["params"]={tid=tid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("每日任务最新版领取活跃奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--每日任务最新版领取任务奖励
function socketHelper:dailytaskRewardTask(tid,callback)
    local tb={}
    tb["cmd"]="dailytask.reward.task"
    tb["params"]={tid=tid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("每日任务最新版领取任务奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
-- 万圣节大作战2
function socketHelper:activityWsjdzz(cmdStr,index,tid,free,callback)
    local tb={}
    tb["cmd"]=cmdStr
    tb["params"]={index=index,tid=tid,free=free}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("万圣节大作战2",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:activityWsjdzz2017(cmdStr,index,tid,free,callback)
    local tb={}
    tb["cmd"]=cmdStr
    tb["params"]={index=index,tid=tid,free=free}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("万圣节大作战2017",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:request(cmd,params,callback)
    local tb={}
    tb["cmd"]=cmd
    tb["params"]=params
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("requestStr-->",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],false)
end

--装扮圣诞树
function socketHelper:christmasRequest(action,free,num,floor,rank,callback)
    local tb={}
    tb["cmd"]=action
    tb["params"]={free=free,num=num,floor=floor,rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("装扮圣诞树",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 开年大吉 元旦
function socketHelper:activityOpenyear(action,callback,tid,count)
    local tb={}
    tb["cmd"]="active.openyear"
    tb["params"]={action=action,tid=tid,count=count}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("开年大吉",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 小地图 定位功能
function socketHelper:mapWorldSearch(cmdStr,mapType,mapLevel,callback)
    local tb={}
    tb["cmd"]=cmdStr
    tb["params"]={mapType=mapType,mapLevel=mapLevel}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("小地图 定位功能",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--矿洞探索活动
function socketHelper:mineExploreRequest(action,free,num,item,callback)
    local tb={}
    tb["cmd"]=action
    tb["params"]={free=free,num=num,item=item}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("矿洞探索活动",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--矿洞探索活动（绿色，韩国版）
function socketHelper:mineExploreGRequest(action,free,num,item,callback)
    local tb={}
    tb["cmd"]=action
    tb["params"]={free=free,num=num,item=item}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("矿洞探索活动(绿色)",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--情人节配对
function socketHelper:loversDayRequest(action,rand,id,callback)
    local tb = {}
    tb["cmd"] = action
    tb["params"] = {rand = rand,id = id}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("情人节配对",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 感恩由你  2016感恩节
function socketHelper:activityGej2016(action,callback,tid)
    local tb={}
    tb["cmd"]="active.ganenjie2016"
    tb["params"]={action=action,tid=tid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("2016感恩节",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--  百团争雄
function socketHelper:activityBtzx(cmd,rank,callback)
    local tb={}
    tb["cmd"]=cmd
    tb["params"]={rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("百团争雄",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end



--配件批量强化
-- type    string  配件所属坦克类型
-- ptype   int 装备的位置
-- count   int 强化次数
-- use json    使用道具
-- aid string  配件的id(背包中)
function socketHelper:accessoryBatchupgrade(tankID,partID,aID,amuletNum,count,callback)
    local tb={}
    tb["cmd"]="accessory.batchupgrade"
    if(tankID~=nil)then
        tb["params"]={type=tankID,ptype=partID}
    else
        tb["params"]={aid=aID}
    end
    if amuletNum and type(amuletNum)=="table" then
        tb["params"]["use"]=amuletNum
    end
    tb["params"]["count"]=count or 1
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("配件批量强化",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--辞旧迎新活动
function socketHelper:cjyxAcRequest(cmd,params,callback)
    local tb={}
    tb["cmd"]=cmd
    if params==nil then
        params={}
    end
    tb["params"]=params
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("辞旧迎新活动请求",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--  能量结晶
function socketHelper:activityNljj(cmd,rand,rank,callback)
    local tb={}
    tb["cmd"]=cmd
    tb["params"]={rand=rand,rank=rank}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("能量结晶",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--  全线突围
function socketHelper:activityQxtw(cmd,rand,count,callback,tid)
    local tb={}
    tb["cmd"]=cmd
    tb["params"]={rand=rand,count=count,tid=tid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("全线突围",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--  装甲矩阵 获取装甲信息
function socketHelper:armorGet(callback)
    local tb={}
    tb["cmd"]="armor.get"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获取装甲信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--  装甲矩阵 抽装甲
function socketHelper:armorRecruit(free,num,type,callback)
    local tb={}
    tb["cmd"]="armor.lottery"
    tb["params"]={free=free,num=num,type=type}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("抽装甲",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--  装甲矩阵 背包扩容
function socketHelper:armorAddbag(callback)
    local tb={}
    tb["cmd"]="armor.addbag"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("背包扩容",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--  装甲矩阵 使用和卸下
-- line =是第几只部队（共6组）
-- id  =m9320426  使用配件或者是替换  必须line 
-- pos  =1-6   卸下一只部队pos六个位置的装甲  必须line 
function socketHelper:armorUsed(line,id,pos,callback)
    local tb={}
    tb["cmd"]="armor.used"
    tb["params"]={line=line,mid=id,pos=pos}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("使用和卸下",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--  装甲矩阵 一键装配和部队位置互换
-- line   第几部队
-- line2   更换部队之间的装甲    line 装配的和line2互换
-- armors   一键装配 ['m1212',0,0,0,0,'m432432']  共6个没有用0占位 id 对应是能装配位置的
function socketHelper:armorAssembly(line,line2,armors,callback)
    local tb={}
    tb["cmd"]="armor.assembly"
    tb["params"]={line=line,line2=line2,armors=armors}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("一键装配和部队位置互换",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--  装甲矩阵 升级
function socketHelper:armorUpgrade(id,level,callback)
    local tb={}
    tb["cmd"]="armor.upgrade"
    tb["params"]={mid=id,level=level}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--  装甲矩阵 分解（遣散）
function socketHelper:armorResolve(id,quality,callback)
    local tb={}
    tb["cmd"]="armor.resolve"
    tb["params"]={mid=id,quality=quality}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("分解",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end



--检测玩家的设备是否可以充值
function socketHelper:checkRecharge(callback)
    local tb={}
    tb["cmd"]="pay.status.dev"
    self:addBaseInfo(tb)
    tb["device"]=G_getDeviceid()
    local requestStr=G_Json.encode(tb)
    print("检测玩家的设备是否可以充值",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end



--每日捷报列表
function socketHelper:dailynewsNewsList(callback)
    local tb={}
    tb["cmd"]="dailynews.news.list"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("每日捷报列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--每日捷报评论
function socketHelper:dailynewsNewsComment(newsId,comment,commenter,callback)
    local tb={}
    tb["cmd"]="dailynews.news.comment"
    tb["params"]={newsId=newsId,comment=comment,commenter=commenter}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("每日捷报评论",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--每日捷报点赞
function socketHelper:dailynewsNewsVote(newsId,callback)
    local tb={}
    tb["cmd"]="dailynews.news.vote"
    tb["params"]={newsId=newsId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("每日捷报点赞",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--每日捷报收藏
function socketHelper:mailSendnews(data,callback)
    local tb={}
    tb["cmd"]="mail.sendnews"
    tb["params"]=data
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("每日捷报收藏",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--辞旧迎新活动
function socketHelper:yswjAcRequest(cmd,params,callback)
    local tb={}
    tb["cmd"]=cmd
    if params==nil then
        params={}
    end
    tb["params"]=params
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("陨石挖掘活动请求",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--每日充值领好礼（新手版）
function socketHelper:getDailyRechargeByNewGuiderReward(callback,method)
    local tb={}
    tb["cmd"]="active.mrcz"
    tb["params"]={method = method}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("每日充值领好礼（新手版）",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getXscjReward(level,callback)
    local tb={}
    tb["cmd"]="active.xscj"
    tb["params"]={level=level}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("新手冲级 绑定新玩家",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:aczjjzReward(action,method,callback)
    local tb={}
    tb["cmd"]="active.zjjz"
    tb["params"]={action=action,method=method}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("矩阵活动 绑定新玩家",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:acxssdReward(id,callback)
    local tb={}
    tb["cmd"]="active.xssd"
    tb["params"]={id=id}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("限时商店 绑定新玩家",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--累计充值返利活动领取充值奖励
function socketHelper:ljczGetRechargeReward(method,callback)
    local tb={}
    tb["cmd"]="active.ljcz"
    tb["params"]={method=method}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("累计充值返利活动领取充值奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end


--超级累计充值返利活动领取充值奖励
function socketHelper:superLjczGetRechargeReward(method,callback)
    local tb={}
    tb["cmd"]="active.ljcz3"
    tb["params"]={method=method}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("超级累计充值返利活动领取充值奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--闪电战术活动领取充值奖励
function socketHelper:sdzsGetTaskReward(method,callback)
    local tb={}
    tb["cmd"]="active.sdzs"
    tb["params"]={method=method}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("闪电战术活动领取充值奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--连续充值送礼（新手版
function socketHelper:getContinueRechargeRewardNewGuid(callback,action,method)
    local tb={}
    tb["cmd"]="active.lxcz"
    tb["params"]={action=action,method=method}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("连续充值送礼（新手版）",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--使用加速道具
--usegem 是否花费金币
--count 道具的使用数量

--根据pid的加速类型，传入下面的参数的含义分别是：
--建筑升级  bid 建筑ID
-- 生产或改造部队  bid 建筑id  slotid生产或改造队列id
-- 科技升级  slotid 科技升级队列ID
function socketHelper:useSpeedUpProp(pid,useGem,callback,count,bid,slotid)
    local tb={}
    tb["cmd"]="prop.use"
    tb["params"]={pid=pid,useGem=useGem,count=count,bid= bid, slotid = slotid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("使用加速道具",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--同步阶段性引导的步骤
function socketHelper:funcStepSync(sid,callback)
    local tb={}
    tb["cmd"]="user.funcguide"
    tb["params"]={sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("同步阶段性引导的步骤",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],false)
end

--装甲风暴
function socketHelper:acArmoredStormReward(action,method,callback)
    local tb={}
    tb["cmd"]="active.zjfb"
    tb["params"]={action=action,method=method}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("装甲风暴",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--问卷调查活动领奖
function socketHelper:activeWjdcReward(callback)
    local tb={}
    tb["cmd"]="active.wjdc.reward"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("问卷调查活动领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 周年狂欢（三周年港台版）
function socketHelper:activeZnkh2017(callback,action,day,tid,num,type)
    local tb={}
    tb["cmd"]="active.znkh2017.reward"
    tb["params"]={action=action,day=day,tid=tid,num=num,type=type}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("周年狂欢（三周年港台版）",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--满级超级武器多余碎片检测
--param idTb: 一个tb，里面是所有满级但是还有碎片没转换纳米原件的武器id, eg: {"w1","w2"}
function socketHelper:superWeaponFix(idTb,callback)
    local tb={}
    tb["cmd"]="weapon.repairs"
    tb["params"]={winfo=idTb}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("满级超级武器多余碎片检测",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 配件革新
function socketHelper:activityPjgx(callback,action,tid,type,num,nf)
    local tb={}
    tb["cmd"]="active.pjgx.reward"
    tb["params"]={action=action,tid=tid,type=type,num=num,nf=nf}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("配件革新",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 推陈出新
-- 推陈出新抽奖日志 cmd: active.tuichenchuxin.getlog
-- 推陈出新开启奖励 cmd: active.tuichenchuxin.reward
-- 推陈出新刷新奖励 cmd: active.tuichenchuxin.refresh
-- 推陈出新购买  cmd: active.tuichenchuxin.buy
function socketHelper:activityTccx(callback,cmd,tid,free)
    local tb={}
    tb["cmd"]=cmd
    tb["params"]={tid=tid,free=free}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("推陈出新",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--空中打击获取飞机信息
function socketHelper:planeGet(callback)
    local tb={}
    tb["cmd"]="plane.plane.get"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("空中打击获取飞机信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--空中打击解锁飞机请求
function socketHelper:planeUnlock(pid,callback)
    local tb={}
    tb["cmd"]="plane.plane.unlock"
    tb["params"]={pid=pid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("空中打击解锁飞机请求",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--空中打击抽取技能请求
function socketHelper:planeLottery(cmd,count,callback)
    local tb={}
    tb["cmd"]=cmd
    tb["params"]={count=count}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("空中打击抽取技能请求",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--空中打击技能转配和卸载  action=1装配，2卸载；line：哪个飞机；pos：技能装配或卸载的位置；sid技能id
function socketHelper:planeSkillEquipOrRemove(action,line,pos,sid,callback)
    local tb={}
    tb["cmd"]="plane.skill.used"
    tb["params"]={action=action,line=line,pos=pos,sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("空中打击技能转配和卸载",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--空中打击技能升级 useGems：是否使用金币；sid：升级的技能；line飞机的解锁顺序
function socketHelper:planeSkillUpgrade(sid,line,useGems,callback)
    local tb={}
    tb["cmd"]="plane.upgrade.levelup"
    tb["params"]={useGems=useGems,sid=sid,plane=line}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("空中打击技能升级",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 飞机技能融合
-- elist：装备列表
-- useGems：是否使用金币
function socketHelper:planeSkillAdvance(slist,useGems,callback,need)
    local tb={}
    tb["cmd"]="plane.skill.upgrade"
    tb["params"]={slist=slist,useGems=useGems,need=need}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军徽进阶",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--飞机技能分解  clist：批量分解的技能品阶列表  sid：要分解的单个技能
function socketHelper:planeSkillSell(sid,clist,callback)
    local tb={}
    tb["cmd"]="plane.skill.resolve"
    tb["params"]={clist=clist,sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("飞机技能分解",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 完美组装
function socketHelper:activityWmzz(callback,action,free,num,part)
    local tb={}
    tb["cmd"]="active.wmzz.reward"
    tb["params"]={action=action,free=free,part=part,num=num,}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("完美组装",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--能源探测 探索
function socketHelper:activityYjtsgTansuo(num,callback)
    local tb={}
    tb["cmd"]="active.yjtsg.reward"
    tb["params"]={action="getreward",num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("能源探测 探索",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--能源探测 改装坦克
function socketHelper:activityYjtsgRefitTank(num,aid,callback)
    local tb={}
    tb["cmd"]="active.yjtsg.reward"
    tb["params"]={action="upgrade",num=num,aid=aid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("能源探测 改装坦克",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--能源探测 获取奖励列表
function socketHelper:activityYjtsgRewardList(callback)
    local tb={}
    tb["cmd"]="active.yjtsg.reward"
    tb["params"]={action="getlist"}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("能源探测 获取奖励列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--战力引导返回所需模块数据1accessory 2equip 3armor 4alien
--modelTb={1,2,3,4}
function socketHelper:getDataForpowerGuide(modelTb,callback)
    self:sendReq("user.getmodel",{models=modelTb},callback)
end

--改装换新 抽奖
function socketHelper:acGzhxReward(num,free,callback,aname)
    local tb={}
    tb["cmd"]="active.gzhx.reward"
    tb["params"]={action="getReward",num=num,free=free,aname=aname}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("改装换新 抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--改装换新 改装坦克
function socketHelper:acGzhxCompose(num,aid,callback,aname)
    local tb={}
    tb["cmd"]="active.gzhx.reward"
    tb["params"]={action="upgrade",num=num,aid=aid,aname=aname}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("改装换新 改装坦克",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--领取阿拉伯斋月吉庆活动的礼包奖励
function socketHelper:getRamadanRewardRequest(action,callback)
    local tb={}
    tb["cmd"]="active.ramadan.reward"
    tb["params"]={action=action}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领取阿拉伯斋月吉庆活动的礼包奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--实名认证
function socketHelper:realnameRegist(name,id,callback)
    local tb={}
    tb["cmd"]="user.real.name"
    tb["params"]={realname=name,idcard=id}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("实名认证",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--炮火连天活动请求接口
function socketHelper:acPhltRequest(args,callback)
    local tb={}
    tb["cmd"]="active.phlt.reward"
    tb["params"]=args or {}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("炮火连天活动请求接口",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--军事输送活动请求接口（军事运输）
function socketHelper:acJsysRequest(args,callback)
    local tb={}
    tb["cmd"]="active.jsss.rand"
    tb["params"]=args or {}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军事输送活动请求接口",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--不给糖就滚蛋
function socketHelper:acHalloween2018Request(cmd,args,callback)
    local tb={}
    tb["cmd"]=cmd
    tb["params"]=args or {}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("不给糖就滚蛋",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--堕落者宝藏
function socketHelper:acDlbzRequest(cmd,args,callback)
    local tb={}
    tb["cmd"]=cmd
    tb["params"]=args or {}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("堕落者宝藏~~",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--将领招贤活动请求接口
function socketHelper:acMjzxRequest(sockStr,args,callback)
    local tb={}
    tb["cmd"]="active.mjzx."..sockStr
    tb["params"]=args or {}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("将领招贤活动请求接口",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--搞怪小丑活动请求接口
function socketHelper:acYrjRequest(sockStr,args,callback)
    local tb={}
    tb["cmd"]="active.yrj."..sockStr
    tb["params"]=args or {}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("搞怪小丑活动请求接口",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
---蒸蒸日！上
function socketHelper:acThrivingRequest(cmdStr,args,callback)
    local tb={}
    tb["cmd"]=cmdStr
    tb["params"]=args or {}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("蒸蒸日！上",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

---快乐集章（套娃）
function socketHelper:acKljzRequest(cmdStr,args,callback)
    local tb={}
    tb["cmd"]=cmdStr
    tb["params"]=args or {}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("快乐集章（套娃）",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--航线规划活动请求接口
function socketHelper:acHxghRequest(args,callback)
    local tb={}
    tb["cmd"]="active.hxgh.reward"
    tb["params"]=args or {}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("航线规划活动请求接口",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--超级秒杀活动获取商店信息
--param shophour: 客户端当前是几点
--param shop: 要购买的是第几个商店
function socketHelper:acSuperShopGet(shophour,shop,callback)
    local tb={}
    tb["cmd"]="active.cjms.getshop"
    tb["params"]={shophour=shophour,shop=shop}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("超级秒杀活动获取商店信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--超级秒杀活动抢购
--param action: 1是普通商店。2是特殊商店
--param sid: 商品ID
--param shophour: 客户端当前是几点
--param shop: 要购买的是第几个商店
function socketHelper:acSuperShopBuy(action,sid,shophour,shop,callback)
    local tb={}
    tb["cmd"]="active.cjms.grab"
    tb["params"]={action=action,sid=sid,shophour=shophour,shop=shop}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("超级秒杀活动抢购",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--领土争夺战 初始化数据
function socketHelper:ltzdzCrossInit(callback)
    local tb={}
    tb["cmd"]="clanwar.crossinit"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领土争夺战 初始化数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--领土争夺战 激活部队,携带金币
function socketHelper:ltzdzActiveTroop(callback,troopTb,gems)
    local tb={}
    tb["cmd"]="clanwar.settroops"
    tb["params"]={troops=troopTb,gems=gems}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领土争夺战 激活部队",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--领土争夺战 好友列表
function socketHelper:ltzdzFriend(callback)
    local tb={}
    tb["cmd"]="clanwar.friends"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领土争夺战  好友列表",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--领土争夺战 action 1 邀请，2 接受邀请，3 拒绝邀请 4:取消邀请
function socketHelper:ltzdzOperateFriend(callback,uid,action)
    local tb={}
    tb["cmd"]="clanwar.invite"
    tb["params"]={uid=uid,action=action}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领土争夺战  好友操作",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:ltzdzJoinBattle(callback)
    local tb={}
    tb["cmd"]="clanwar.joinbattle"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领土争夺战  初始化战场",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--领土争夺战 城市建筑建造，升级和移除的操作
function socketHelper:ltzdzBuildingOperate(action,roomid,cid,btype,bid,callback)
    local tb={}
    tb["cmd"]="clanwarserver.buildings"
    tb["params"]={action=action,roomid=roomid,cid=cid,type=btype,bid=bid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领土争夺战 城市建筑建造，升级和移除的操作",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--领土争夺战 功勋商店购买
function socketHelper:ltzdzExploitShopBuy(seg,pid,callback)
    local tb={}
    tb["cmd"]="clanwar.pointshop"
    tb["params"]={seg=seg,pid=pid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领土争夺战 功勋商店购买",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--建筑提示所需数据接口
function socketHelper:tipDataRequest(callback)
    local tb={}
    tb["cmd"]="user.getpartinfo"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获取多个模块数据的接口",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],false)
end
-- 装甲精英
-- action 1：抽奖  2：抽奖记录
-- num：1 单抽，10 十连抽
function socketHelper:activeArmorElite(action,num,free,callback)
    local tb={}
    tb["cmd"]="active.zjjy.reward"
    tb["params"]={action=action,num=num,free=free}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("装甲精英",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--装甲矩阵 商店购买兑换
function socketHelper:armorShopExchange(callback,type,pid)
    local tb={}
    tb["cmd"]="armor.exchange"
    tb["params"]={type=type,pid=pid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("装甲矩阵 商店购买兑换",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--获取军团城市信息
function socketHelper:getAllianceCity(aid,callback,waiting)
    local tb={}
    tb["cmd"]="alliancecity.get"
    tb["params"]={aid=aid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获取军团城市信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],waiting)
end

--创建或搬迁军团城市(aid：军团id，pos：城市在世界地图中的坐标)
function socketHelper:createOrMoveAllianceCity(aid,pos,moveFlag,callback,oldpos)
    local tb={}
    if moveFlag==true then --搬迁城市
        tb["cmd"]="alliancecity.move"
    else
        tb["cmd"]="alliancecity.create"
    end
    tb["params"]={aid=aid,pos=pos,oldpos=oldpos}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("创建或搬迁军团城市",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--建造或收回军团城市领地（action：1：建造，2：收回）
function socketHelper:createOrRecycleTerritory(action,aid,pos,callback)
    local tb={}
    tb["cmd"]="alliancecity.build"
    tb["params"]={action=action,aid=aid,pos=pos}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("建造或收回军团城市领地",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--提高军团城市个人技能的等级上限和升级技能
function socketHelper:upgradePersonalSkill(action,aid,sid,callback,level)
    local tb={}
    tb["cmd"]="alliancecity.skillup"
    tb["params"]={action=action,aid=aid,sid=sid,level=level}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("提高军团城市个人技能的等级上限和升级技能",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--补充军团城市水晶数量
function socketHelper:addCitCrystal(aid,callback)
    local tb={}
    tb["cmd"]="alliancecity.addCrystal"
    tb["params"]={aid=aid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("补充军团城市水晶数量",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--侦查或查看军团城市
function socketHelper:scoutAllianceCity(pos,callback)
    local tb={}
    tb["cmd"]="alliancecity.scout"
    tb["params"]={pos=pos}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("侦查或查看军团城市",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--开启军团城市护盾
function socketHelper:openAllianceCityShield(aid,pos,callback)
    local tb={}
    tb["cmd"]="alliancecity.protect"
    tb["params"]={aid=aid,pos=pos}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("开启军团城市护盾",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--遣返驻防军团城市的部队
function socketHelper:backDefCityTroops(action,aid,memberId,callback)
    local tb={}
    tb["cmd"]="alliancecity.back"
    tb["params"]={action=action,aid=aid,member=memberId}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("遣返驻防军团城市的部队",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--抗战活动 购买礼包
function socketHelper:acKzhdBuyGift(callback,action,sid)
    local tb={}
    tb["cmd"]="active.kzhd.buy"
    tb["params"]={action=action,sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("抗战活动 购买礼包",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--狂欢之日 购买礼包
function socketHelper:acKhzrBuyGift(callback,sid)
    local tb={}
    tb["cmd"]="active.khzr.buy"
    tb["params"]={sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("狂欢之日 购买礼包",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--德国绑定邮箱领奖
function socketHelper:movgaBindGet(callback)
    local tb={}
    tb["cmd"]="active.bindemailreward"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("德国绑定邮箱领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--领取领土争夺战赛季任务奖励
function socketHelper:getSeasonTaskReward(tid,callback)
    local tb={}
    tb["cmd"]="clanwar.reward"
    tb["params"]={tid=tid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("领取领土争夺战赛季任务奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--2017四周年周年庆典活动领奖接口
function socketHelper:acAnniversaryFourReward(action,type,callback)
    local tb={}
    tb["cmd"]="active.znqd2017.reward"
    tb["params"]={action=action,type=type}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("周年庆典活动领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end

--2017四周年周年庆典活动获取历程排行数据
function socketHelper:acAnniversaryFourRank(callback)
    local tb={}
    tb["cmd"]="active.znqd2017.getrank"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("周年庆典活动获取历程排行数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])    
end

--神秘商店 礼包
function socketHelper:acSecretshopGift(callback,action,sid)
    local tb={}
    tb["cmd"]="active.secretshop.package"
    tb["params"]={action=action,sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("神秘商店 购买礼包",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--神秘商店 礼包
function socketHelper:acSecretshopChange(callback,sid,resp)
    local tb={}
    tb["cmd"]="active.secretshop.exchange"
    tb["params"]={resp=resp,sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("神秘商店 兑换道具",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--周年狂欢（四周年） 获取抽奖日志
function socketHelper:acZnkhLog(callback)
    local tb={}
    tb["cmd"]="active.znkh.getlog"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("周年狂欢（四周年） 获取抽奖日志",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--周年狂欢（四周年） 抽奖
--free =1 是免费   num=5是五连抽,＝1是一抽
function socketHelper:acZnkhLottery(callback,params)
    local tb={}
    tb["cmd"]="active.znkh.rand"
    tb["params"]={free=params[1],num=params[2]}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("周年狂欢（四周年） 抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--周年狂欢（四周年） 领取抽奖次数奖励
--num =是领取那次的奖励是配置里的次数
function socketHelper:acZnkhCreward(callback,params)
    local tb={}
    tb["cmd"]="active.znkh.creward"
    tb["params"]={num=params[1]}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("周年狂欢（四周年） 领取抽奖次数奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--周年狂欢（四周年） 获取排行榜
function socketHelper:acZnkhRankList(callback)
    local tb={}
    tb["cmd"]="active.znkh.ranklist"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("周年狂欢（四周年） 获取排行榜",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--周年狂欢（四周年） 领取排行榜奖励
--rank =1  是在排行榜里的排名
function socketHelper:acZnkhRankReward(callback,params)
    local tb={}
    tb["cmd"]="active.znkh.rankreward"
    tb["params"]={rank=params[1]}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("周年狂欢（四周年） 领取排行榜奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--全民圣诞
function socketHelper:activityQmsdSock(callback,cmdStr,action,num,free,limit)
    local tb={}
    tb["cmd"]=cmdStr
    tb["params"]={action=action,num=num,limit=limit,free=free}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("全民圣诞",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"]) 
end

--全民吃鸡
function socketHelper:activityEatChickenSock(callback,action,apoint,point,num,free )
   local tb={}
    tb["cmd"]="active.qmcj"
    tb["params"]={action=action,apoint=apoint,point=point,num=num,free=free}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("~~~全民吃鸡~~~",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"]) 
end

--初始化战争塑像系统数据
function socketHelper:getWarStatue(callback,flag)
    local tb={}
    tb["cmd"]="statue.get"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("初始化战争塑像系统数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],flag)
end

--激活战争塑像将领
function socketHelper:activateStatueHero(action,sid,hid,callback)
    local tb={}
    tb["cmd"]="statue.activate"
    tb["params"]={action=action,sid=sid,hid=hid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("激活战争塑像将领",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 设置聊天气泡
function socketHelper:setChatBubble(cfid,callback)
    local tb = {}
    tb["cmd"]="user.setbubble"
    tb["params"]={bb=cfid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("设置玩家聊天气泡",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

function socketHelper:getulimit(callback)
    local tb = {}
    tb["cmd"]="user.getulimit"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("获取解锁的头像、头像框、聊天框",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--百花齐放 点燃抽奖
function socketHelper:activeBhqfLottery(num,free,callback)
    local tb={}
    tb["cmd"]="active.bhqf.lottery"
    tb["params"]={num=num,free=free}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("百花齐放 点燃抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--百花齐放 任务兑换
function socketHelper:activeBhqfTask(action,callback)
    local tb={}
    tb["cmd"]="active.bhqf.task"
    tb["params"]={action=action}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("百花齐放 任务兑换",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--百花齐放 奖励日志
function socketHelper:activeBhqfGetlog(callback)
    local tb={}
    tb["cmd"]="active.bhqf.getlog"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("百花齐放 奖励日志",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--2018春节充值活动春福临门, 领取充值奖励
function socketHelper:activeCflmRecharge(day,level,act,callback)
    local tb={}
    tb["cmd"]="active.cflm.recharge"
    tb["params"]={day=day,level=level,act=act}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("春福临门领取充值奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--2018春节充值活动春福临门, 购买基金
function socketHelper:activeCflmBuy(inType,callback)
    local tb={}
    tb["cmd"]="active.cflm.buyfund"
    tb["params"]={inType=inType}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("春福临门购买基金",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--2018春节充值活动春福临门, 领取基金奖励
function socketHelper:activeCflmInvest(inType,day,callback)
    local tb={}
    tb["cmd"]="active.cflm.fundreward"
    tb["params"]={day=day,inType=inType}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("春福临门领取基金奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--浪漫情人节 拆礼盒
function socketHelper:activeLmqrjLottery(_paramTb,callback)
    local tb={}
    tb["cmd"]="active.lmqrj.draw"
    tb["params"]={num=_paramTb[1],act=_paramTb[2],type=_paramTb[3]}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("浪漫情人节 拆礼盒",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--浪漫情人节 领取魅力值奖励
function socketHelper:activeLmqrjMlzReward(_paramTb,callback)
    local tb={}
    tb["cmd"]="active.lmqrj.mlzreward"
    tb["params"]={num=_paramTb[1]}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("浪漫情人节 领取魅力值奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--浪漫情人节 赠送礼盒
function socketHelper:activeLmqrjGive(_paramTb,callback)
    local tb={}
    tb["cmd"]="active.lmqrj.give"
    tb["params"]={receiver=_paramTb[1],act=_paramTb[2],ty=_paramTb[3]}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("浪漫情人节 赠送礼盒",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--浪漫情人节 获奖记录
function socketHelper:activeLmqrjLog(callback)
    local tb={}
    tb["cmd"]="active.lmqrj.getlog"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("浪漫情人节 获奖记录",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--浪漫情人节 领取任务奖励
function socketHelper:activeLmqrjTaskReward(_paramTb,callback)
    local tb={}
    tb["cmd"]="active.lmqrj.task"
    tb["params"]={tid=_paramTb[1]}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("浪漫情人节 领取任务奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--狂热分子 商店购买
function socketHelper:believerbuyPropInShop(callback,grade,item)
    local tb={}
    tb["cmd"]="believer.believer.buy"
    tb["params"]={grade=grade,item=item}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("狂热分子 商店购买",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--狂热分子 点赞
function socketHelper:socketThumpUp(callback,season)
    local tb={}
    tb["cmd"]="believer.believer.thumbsup"
    tb["params"]={season=season}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("狂热分子 点赞",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end
--狂热分子报名
function socketHelper:believerSign(callback)
    local tb={}
    tb["cmd"]="believer.believer.apply"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("狂热分子报名",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--初始化狂热分子功能数据
function socketHelper:believerInitRequest(callback)
    local tb={}
    tb["cmd"]="believer.believer.get"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("初始化狂热分子功能数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--狂热分子匹配
function socketHelper:requestMatch(cost,grade,callback)
    local tb={}
    tb["cmd"]="believer.believer.match"
    tb["params"]={cost=cost,grade=grade}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("狂热分子匹配",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--狂热分子部队兑换
function socketHelper:believerExchange(list,callback)
    local tb={}
    tb["cmd"]="believer.believer.exchange"
    tb["params"]={list=list}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("狂热分子部队兑换",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--狂热分子挑战
function socketHelper:believerBattle(fleetTb,callback)
    local tb={}
    tb["cmd"]="believer.believer.battle"
    tb["params"]={fleetinfo=fleetTb}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("狂热分子挑战",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--狂热分子设置自动补兵
function socketHelper:believerAutoExchange(switch,callback)
    local tb={}
    tb["cmd"]="believer.believer.setting"
    tb["params"]={switch=switch}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("狂热分子设置自动补兵",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--狂热分子领取每日任务奖励
function socketHelper:getDailyTaskRewardRequest(idx,callback)
    local tb={}
    tb["cmd"]="believer.believer.dailyReward"
    tb["params"]={item=idx}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("狂热分子领取每日任务奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--狂热分子领取晋级奖励
function socketHelper:getSegRewardRequest(grade,queue,callback)
    local tb={}
    tb["cmd"]="believer.believer.gradeReward"
    tb["params"]={grade=grade,queue=queue}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("狂热分子领取晋级奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--狂热分子领取赛季奖励
function socketHelper:getSeasonRewardRequest(grade,queue,callback)
    local tb={}
    tb["cmd"]="believer.believer.seasonReward"
    tb["params"]={grade=grade,queue=queue}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("狂热分子领取赛季奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--狂热分子自动匹配战斗（扫荡）
function socketHelper:believerAutoBattle(grade,callback)
    local tb={}
    tb["cmd"]="believer.believer.autoBattle"
    tb["params"]={grade=grade}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("狂热分子自动匹配战斗（扫荡）",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--使用战机革新中的主动技能
function socketHelper:usePlaneNewSkill(sid,callback)
    local tb={}
    tb["cmd"]="plane.newskill.useSkill"
    tb["params"]={sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("使用战机革新中的主动技能",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--战机革新的新技能升级(研究)
function socketHelper:planeNewSkillUpgrade(sid,callback)
    local tb={}
    tb["cmd"]="plane.newskill.upgrade"
    tb["params"]={sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("战机革新的新技能升级(研究)",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--战机革新取消技能升级(研究)
function socketHelper:planeNewSkillCancelUpgrade(sid,callback)
    local tb={}
    tb["cmd"]="plane.newskill.cancelUp"
    tb["params"]={sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("战机革新取消技能升级(研究)",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--战机革新加速技能升级(研究)
function socketHelper:planeNewSkillSpeedUpgrade(sid,callback)
    local tb={}
    tb["cmd"]="plane.newskill.speedup"
    tb["params"]={sid=sid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("战机革新加速技能升级(研究)",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--获取成就系统数据
function socketHelper:getAchievement(callback,waitingFlag)
    local tb={}
    tb["cmd"]="achievement.achievement.get"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("获取成就系统数据",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],waitingFlag)
end

--成就系统 激活并领奖
--@ _atype:类型 1-个人,2-全服
--@ _aid:成就id
function socketHelper:achievementReward(_atype,_aid,callback)
    local tb={}
    tb["cmd"]="achievement.achievement.reward"
    tb["params"]={atype=_atype,aid=_aid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("成就系统 激活并领奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--成就系统选择要显示的奖杯
--params：action:类型 1选择成就模块要显示的奖杯 2选择各模块里全服成就线需要显示的奖杯，aid:成就线id，stype:1个人,2全服(type==1时)，index:全服成就类别索引（格式：{成就id，子成就id}）
--选择模块时传入 action，aid，stype三个参数；选择各模块全服成就奖杯时传入 action，aid，stype，index四个参数
function socketHelper:achievementCup(action,aid,stype,index,callback)
    local tb={}
    tb["cmd"]="achievement.achievement.cup"
    tb["params"]={action=action,aid=aid,stype=stype,index=index}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("成就系统 选择要显示的奖杯",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--月度充值活动升级奖励
function socketHelper:ydczRewardUpgrade(callback)
    local tb={}
    tb["cmd"]="active.ydcz.rewardUp"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("月度充值活动升级奖励",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军务管家:一键抽奖
function socketHelper:stewardLottery(callback,useCrystal)
    local tb={}
    tb["cmd"]="user.collectfunc.lottery"
    tb["params"]={useCrystal=useCrystal}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军务管家:一键抽奖",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--军务管家 一键扫荡
--eclist：补给线扫荡列表，不传默认全部扫荡
function socketHelper:stewardSweeping(callback, eclist)
   local tb={}
    tb["cmd"]="user.collectfunc.raids"
    tb["params"]={eclist=eclist}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("军务管家 一键扫荡",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"]) 
end

--交换地块
function socketHelper:swapHomeBuilding(bid,mid,callback )
   local tb={}
    tb["cmd"]="building.move"
    tb["params"]={bid=bid,mid=mid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("交换地块",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"]) 
end--activeDuanWu

--活动 : 特权补给
function socketHelper:activeTqbj(socketCall,tid)
    local tb={}
    tb["cmd"]="active.tqbj.reward"
    tb["params"]={tid=tid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("活动 : 特权补给",requestStr)
    self:sendRequest(requestStr,socketCall,tb["cmd"])
end

--活动 : 新手特权
function socketHelper:activeXstq(socketCall,tid)
    local tb={}
    tb["cmd"]="active.xstq.reward"
    tb["params"]={tid=tid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("活动 : 新手特权",requestStr)
    self:sendRequest(requestStr,socketCall,tb["cmd"])
end

--端午活动/普通版
function socketHelper:activeDuanWu(socketCall,strType,idx)
    local tb={}
    tb["cmd"]="active.duanwu."..strType
    tb["params"]= strType == "task" and {tid=idx} or {sid=idx}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("端午活动/普通版",requestStr)
    self:sendRequest(requestStr,socketCall,tb["cmd"])
end

function socketHelper:sendReq(cmd, params, callback, waitingFlag)
    local tb={cmd=cmd, params=params}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print(requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"],waitingFlag)
end

--军徽部队训练
function socketHelper:emblemTroopWash(troopId,washType,callback)
    print("军徽部队训练接口\n")
    self:sendReq("sequip.master.succinct",{mid=troopId,x=washType},callback)
end

--军徽部队自动训练
function socketHelper:emblemTroopWashAuto(troopId,washType,washTimeIndex,washSave,callback)
    print("军徽部队自动训练接口\n")
    self:sendReq("sequip.master.autox",{mid=troopId,x=washType,index=washTimeIndex,se=washSave},callback)
end

--军徽部队训练保存
function socketHelper:emblemTroopWashSave(troopId,callback)
    print("军徽部队训练保存接口\n")
    self:sendReq("sequip.master.upsuccinct",{mid=troopId},callback)
end

--军徽部队装配
function socketHelper:emblemSetTroop(troopId,equipId,posIndex,callback)
    print("军徽部队装配接口\n")
    self:sendReq("sequip.master.set",{mid=troopId,eid=equipId,p=posIndex},callback)
end

--军徽部队卸下
function socketHelper:emblemUnSetMaster(troopId,posIndex,callback)
    print("军徽部队卸下接口\n")
    self:sendReq("sequip.master.unset",{mid=troopId,p=posIndex},callback)
end

--军徽部队强度奖励激活
function socketHelper:emblemTroopActiveStrengthReward(callback)
    print("军徽部队强度奖励激活接口\n")
    self:sendReq("sequip.master.allunlock",{},callback)
end

--军徽部队强度奖励激活
function socketHelper:emblemTroopActiveStrengthReward(callback)
    print("军徽部队强度奖励激活接口\n")
    self:sendReq("sequip.master.allunlock",{},callback)
end

--军徽部队购买和洗练道具购买接口
function socketHelper:emblemTroopShopExchange(shopId,buyNum,callback)
    print("军徽部队购买和洗练道具购买接口\n")
    self:sendReq("sequip.master.exchange",{i=shopId,num=buyNum},callback)
end

--远征军战报读取接口
function socketHelper:expeditionReadReport(rid,callback)
    print("远征军战报读取接口\n")
    self:sendReq("expedition.readlog",{id=rid},callback)
end

--军团锦标赛获取服内数据接口
function socketHelper:championshipWarGet(callback,waiting)
    print("军团锦标赛获取服内数据接口\n")
    self:sendReq("alliancechampion.shipswar.get",{},callback,waiting)
end

--军团锦标赛个人战挑战接口
--defender：关卡难易程度
function socketHelper:championshipWarPersonalBattle(fleetinfo,hero,equip,plane,aitroops,airshipId,defender,callback)
    print("军团锦标赛个人战挑战接口\n")
    self:sendReq("alliancechampion.shipswar.battle",{fleetinfo=fleetinfo,hero=hero,equip=equip,plane=plane,at=aitroops,ap=airshipId,defender=defender},callback)
end

--军团锦标赛个人战选择属性接口
--@selectIndex: 选择的属性下标索引
function socketHelper:championshipWarPersonalSelectProperty(selectIndex,callback)
    print("军官锦标赛个人战选择属性接口\n")
    self:sendReq("alliancechampion.shipswar.checkbuff",{method=selectIndex},callback)
end

--军团锦标赛个人战购买带兵量和重置关卡接口
--@typeNum: 1 购买带兵量, 2 购买攻击次数（重置关卡）
function socketHelper:championshipWarPersonalBuyBuff(typeNum,callback)
    print("军团锦标赛个人战购买带兵量和重置关卡接口\n")
    self:sendReq("alliancechampion.shipswar.buybuff",{method=typeNum},callback)
end

--军团锦标赛军团战报名设置部队接口
function socketHelper:championshipWarSetTroops(fleetinfo,hero,equip,plane,aitroops,airshipId,callback)
    print("军团锦标赛军团战报名设置部队接口\n")
    self:sendReq("alliancechampion.shipswar.setinfo",{fleetinfo=fleetinfo,hero=hero,equip=equip,plane=plane,at=aitroops,ap=airshipId},callback)
end

--军团锦标赛商店购买接口
function socketHelper:championshipWarShopBuy(method, id, shop, callback)
    print("军团锦标赛商店购买接口\n")
    self:sendReq("alliancechampion.shipswar.shopbuy",{method = method, id = id, shop = shop}, callback)
end

--军团锦标赛个人战通关排行榜接口
function socketHelper:championshipWarRankList(callback)
    print("军团锦标赛个人战通关排行榜接口\n")
    self:sendReq("alliancechampion.shipswar.ranklist",{},callback)
end

--军团锦标赛个人战扫荡接口
function socketHelper:championshipWarRaid(tid,defender,callback)
    print("军团锦标赛个人战扫荡接口\n")
    self:sendReq("alliancechampion.shipswar.raid",{tid=tid,defender=defender},callback)
end

--军团锦标赛军团战对阵列表
function socketHelper:championshipWarScheduleGet(callback,waitingFlag)
    print("军团锦标赛军团战对阵列表\n")
    self:sendReq("alliancechampion.alliancewar.schedule",{},callback,waitingFlag)
end

--军团锦标赛扫荡
function socketHelper:championshipWarQuickBattle(callback)
    print("军团锦标赛扫荡接口\n")
   self:sendReq("alliancechampion.shipswar.continueraid",{},callback) 
end

--军团锦标赛拉取战报接口
function socketHelper:championshipWarReport(method,rid,round,zaid1,zaid2,callback)
    print("军团锦标赛拉取战报接口\n")
    self:sendReq("alliancechampion.alliancewar.report",{method=method,rid=rid,round=round,zaid1=zaid1,zaid2=zaid2},callback)
end

--军团锦标赛军团排名接口
function socketHelper:championshipWarAllianceRank(callback)
    print("军团锦标赛军团排名接口\n")
    self:sendReq("alliancechampion.alliancewar.ranklist",{},callback)
end

--军团锦标赛领取军团结算奖励
function socketHelper:championshipWarRankReward(rank,callback)
    print("军团锦标赛领取军团结算奖励\n")
    self:sendReq("alliancechampion.alliancewar.rankreward",{rank=rank},callback)
end

--军团锦标赛军团排行接口
function socketHelper:championshipWarAllianceRankRequest(callback)
    print("军团锦标赛军团排行接口\n")
    self:sendReq("alliancechampion.alliancewar.ranklist",{},callback)
end
--acWpbdRequest

function socketHelper:acWpbdRequest(cmdSon,params,callback)
    print("王牌部队 cmdSon==>>\n",cmdSon)
    local cmd = "active.wpbd."..cmdSon
    self:sendReq(cmd,params,callback)
end

--装甲矩阵突破接口
function socketHelper:armorMatrixTP(mid,callback)
    print("装甲矩阵突破接口\n")
    self:sendReq("armor.breach",{mid=mid},callback)
end

-- 一键领取邮件
function socketHelper:allrewardEmail(callback)
    local tb={}
    tb["cmd"]="mail.allreward"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("一键领取邮件",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

-- 购买外观
function socketHelper:acWxgxBuyexter(callback)
    local tb = {}
    tb["cmd"] = "active.wxgx.buyexter"
    tb["params"] = {}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("购买外观", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

-- 购买道具
function socketHelper:acWxgxBuyshop(callback, sid)
    local tb = {}
    tb["cmd"] = "active.wxgx.buyshop"
    tb["params"] = {sid = sid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("购买道具", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

-- 焕然一新 购买外观
function socketHelper:acHryxBuyexter(callback,list)
    local tb = {}
    tb["cmd"] = list and "active.hryx."..list or "active.hryx.buyexter"
    tb["params"] = {}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    if list then
        print("焕然一新 排行榜", requestStr)
    else
        print("焕然一新 购买外观", requestStr)
    end
    self:sendRequest(requestStr, callback, tb["cmd"])
end

-- 焕然一新 购买道具
function socketHelper:acHryxBuyshop(callback, sid, num)
    local tb = {}
    tb["cmd"] = "active.hryx.buyshop"
    tb["params"] = {sid = sid, num = num}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("焕然一新 购买道具", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

-- 军团一键捐献
function socketHelper:allianceAlldonate(callback, aid, sid, resource)
    local tb = {}
    tb["cmd"] = "alliance.alldonate"
    tb["params"] = {aid = aid, sid = sid, resource = resource}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("军团一键捐献", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--AI部队获取功能信息接口
function socketHelper:AITroopsGet(check,callback)
    print("AI部队获取功能信息接口\n")
    self:sendReq("aitroops.aitroops.get",{check=check},callback)
end

--AI部队重置生产部队坦克消耗接口
function socketHelper:AITroopsProduceCostReset(quality,callback)
    print("AI部队重置生产部队坦克消耗接口\n")
    self:sendReq("aitroops.aitroops.reset",{quality=quality},callback)
end

--AI部队生产部队接口
function socketHelper:AITroopsProduce(quality,double,callback)
    print("AI部队生产部队接口\n")
    self:sendReq("aitroops.aitroops.produce",{quality=quality,double=double},callback)
end

--AI部队生产加速接口
function socketHelper:AITroopsProduceSpeedup(qid,callback)
    print("AI部队生产加速接口\n")
    self:sendReq("aitroops.aitroops.speedup",{qid=qid},callback)
end

--AI部队生产取消接口
function socketHelper:AITroopsProduceCancel(qid,callback)
    print("AI部队生产取消接口\n")
    self:sendReq("aitroops.aitroops.cancel",{qid=qid},callback)
end

--AI部队部队升级接口
function socketHelper:AITroopsUpgrade(aid,callback)
    print("AI部队部队升级接口\n")
    self:sendReq("aitroops.aitroops.addexp",{aid=aid},callback)
end

--AI部队部队进阶接口
function socketHelper:AITroopsAdvanced(aid,callback)
    print("AI部队部队进阶接口\n")
    self:sendReq("aitroops.aitroops.gradeup",{aid=aid},callback)
end

--AI部队部队碎片兑换道具接口
function socketHelper:AITroopsFragmentExchange(fid,num,callback)
    print("AI部队部队碎片兑换道具接口\n")
    self:sendReq("aitroops.aitroops.exchange",{fid=fid,num=num},callback)
end

--AI部队部队技能升级接口
--aid：部队id，index：第几个技能，ctype：消耗类型（1.经验道具，2.ai部队碎片）
function socketHelper:AITroopsSkillUpgrade(aid,index,ctype,callback)
    print("AI部队部队技能升级接口\n")
    self:sendReq("aitroops.aitroops.skilladdexp",{aid=aid,index=index,ctype=ctype},callback)
end

--AI部队技能刷新接口
function socketHelper:AITroopsSkillRefresh(aid,callback)
    print("AI部队技能刷新接口\n")
    self:sendReq("aitroops.aitroops.succinct",{aid=aid},callback)
end

--AI部队技能替换接口
function socketHelper:AITroopsSkillExchange(aid,callback)
    print("AI部队技能替换接口\n")
    self:sendReq("aitroops.aitroops.switchskill",{aid=aid},callback)
end

--周年锦鲤活动领取每日福利接口
function socketHelper:acZnjlRewardRequest(callback)
    print("周年锦鲤活动领取每日福利接口\n")
    self:sendReq("active.znjl.dayreward",{},callback)
end

--周年赐福活动 领取每日福利接口
function socketHelper:acZncfRewardRequest(callback)
    print("周年赐福活动 领取每日福利接口\n")
    self:sendReq("active.zncf.getsignrw",{},callback)
end
--周年赐福活动，任务领取
function socketHelper:acZncfTaskRequest(callback,sid,tid)
    local tb = {}
    tb["cmd"] = "active.zncf.gettaskrw"
    tb["params"] = {sid=sid,tid=tid}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("周年赐福活动，任务领取", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--周年锦鲤活动获取锦鲤名单的接口
function socketHelper:acZnjlGet(callback)
    print("周年锦鲤活动获取锦鲤名单的接口\n")
    self:sendReq("active.znjl.get",{},callback)
end

function socketHelper:acZnkh2018GetRank(callback)
    print("周年狂欢（五周年）获取排行\n")
    self:sendReq("active.znkh2018.getrank",{},callback)
end

--批量使用统率书接口
function socketHelper:multiCommanderUpgradeRequest(callback)
    print("批量使用统率书接口\n")
    self:sendReq("user.multitroopsup",{},callback)
end
-- 设置旗帜
function socketHelper:allianceSetflag(callback, icon, frame, color)
    local tb = {}
    tb["cmd"] = "alliance.setflag"
    tb["params"] = {icon = icon, frame = frame, color = color}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("设置旗帜", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--获取坦克皮肤数据接口
function socketHelper:tankSkinGet(callback)
    print("获取坦克皮肤数据接口\n")
    self:sendReq("tankskin.tankskin.get",{},callback)
end

--使用和卸载坦克皮肤接口（stype：1使用，2卸载）
function socketHelper:useTankSkin(stype,skinId,callback)
    print("使用坦克皮肤接口\n")
    self:sendReq("tankskin.tankskin.use",{stype=stype,sid=skinId},callback)
end

--升级坦克皮肤接口
function socketHelper:upgradeTankSkin(skinId,callback)
    print("升级坦克皮肤接口\n")
    self:sendReq("tankskin.tankskin.upgrade",{sid=skinId},callback)
end

--坦克涂装商店购买涂装接口
function socketHelper:buyTankSkin(sid,callback)
    print("坦克涂装商店购买涂装接口\n")
    self:sendReq("tankskin.tankskin.shop",{sid=sid},callback)
end

function socketHelper:acKfczGetRank(callback)
    print("跨服充值获取排行\n")
    self:sendReq("active.kfcz.getrank",{},callback)
end

function socketHelper:acZntpTaskReward(tid, callback)
    print("只能突破任务领取奖励\n")
    self:sendReq("active.zntp.task",{tid=tid},callback)
end

-- 荣耀回归 生成激活码
function socketHelper:acRyhgMakeCode(callback)
    local tb = {}
    tb["cmd"] = "active.ryhg.makecode"
    tb["params"] = {}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("荣耀回归：生成激活码", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end
-- 荣耀回归 使用激活码
function socketHelper:acRyhgUseCode(callback, code)
    local tb = {}
    tb["cmd"] = "active.ryhg.usecode"
    tb["params"] = {code = code}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("荣耀回归：使用激活码", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end
-- 荣耀回归 领取老玩家奖励
function socketHelper:acRyhgReward(callback)
    local tb = {}
    tb["cmd"] = "active.ryhg.reward"
    tb["params"] = {}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("荣耀回归：领取老玩家奖励", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--将领副官：激活副官
--@ hid:将领id， adjPoint:要激活的副官槽位索引， costProps:激活所消耗的道具[道具id=数量,...]
function socketHelper:adjActivate(callback, hid, adjPoint, costProps)
    local tb = {
        cmd = "hero.activated",
        params = { hid = hid, lid = adjPoint, props = costProps },
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("将领副官：激活副官", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--将领副官：装配或替换副官
--@ hid:将领id， adjPoint:要装备或替换的副官槽位索引， adjId:要装配或替换的副官id
function socketHelper:adjEquip(callback, hid, adjPoint, adjId)
    local tb = {
        cmd = "hero.opeadjutant",
        params = { hid = hid, lid = adjPoint, adjid = adjId },
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("将领副官：装配或替换副官", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--将领副官：升级副官
--@ hid:将领id， adjPoint:要升级的副官槽位索引
function socketHelper:adjUpgrade(callback, hid, adjPoint)
    local tb = {
        cmd = "hero.upgradeadjutant",
        params = { hid = hid, lid = adjPoint }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("将领副官：升级副官", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--将领技能重置
--@ hid:将领id， sid:将领技能id
function socketHelper:heroSkillReset(callback, hid, sid)
    local tb = {
        cmd = "hero.resetskill",
        params = { hid = hid, sid = sid }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("将领技能重置", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--获取解锁聊天表情
--@ emojiId:表情ID
function socketHelper:getUnlockChatEmoji(callback)
    local tb = {
        cmd = "user.getuchatemoji",
        params = {}
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("获取解锁聊天表情", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--购买聊天表情
--@ emojiId:表情ID
function socketHelper:buyChatEmoji(callback, emojiId)
    local tb = {
        cmd = "user.buychatemoji",
        params = { fid = emojiId }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("购买聊天表情", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--军团喜乐会活动数据接口
function socketHelper:acJtxlhRequest(callback)
    print("军团喜乐会活动数据接口\n")
    self:sendReq("active.jtxlh.get",{},callback)
end

--补给商店
function socketHelper:supplyShopGet(callback)
    local tb = {
        cmd = "user.supply.get",
        params = {}
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("补给商店", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--补给商店购买
--@ stype:1 资源 2商店,   sid:商品id（资源特殊处理）
function socketHelper:supplyShopBuy(callback, stype, sid)
    local tb = {
        cmd = "user.supply.buy",
        params = { stype = stype, sid = sid }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("补给商店购买", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--补给商店订购
--@ spid:定制商店类型(id)
function socketHelper:supplyShopCustomBuy(callback, spid)
    local tb = {
        cmd = "user.supply.bjshop",
        params = { spid = spid }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("补给商店订购", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--补给商店翻倍
--@ spid:定制商店类型(id)
function socketHelper:supplyShopDouble(callback, spid)
    local tb = {
        cmd = "user.supply.double",
        params = { spid = spid }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("补给商店订购", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--军事演习一键读取战报
function socketHelper:shamBattleReportReadAll(callback)
    print("军事演习一键读取战报\n")
    self:sendReq("military.readAll",{},callback)    
end

--军事演习一键删除已读战报
function socketHelper:shamBattleReportDeleteAll(callback)
    print("军事演习一键删除已读战报\n")
    self:sendReq("military.deleteAllRead",{},callback)
end

--基地装扮兑换接口
function socketHelper:baseDecorateExchange(id,num,callback)
    print("基地装扮兑换接口\n")
    self:sendReq("map.exteriorbuy",{cid=id,num=num},callback)
end

--签到新接口
--sign 签到
--resign 补签
--getreward 累计奖励
function socketHelper:newSignSocket(callback,addCmd,rewardId,tt)
   local tb={}
    tb["cmd"]="user.newSign."..addCmd
    tb["params"]={rewardId=rewardId,tt=tt}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("签到新接口",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"]) 
end

--获取个人叛军数据
--@ isReset : 是否重置 1:重置
function socketHelper:pr_getData(callback, isReset)
    local tb = {
        cmd = "personrebles.get",
        params = { refre = isReset }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("获取个人叛军数据", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--个人叛军攻打废墟
--@ position : 个人叛军的棋盘坐标[x,y]
function socketHelper:pr_attackRuins(callback, position)
    local tb = {
        cmd = "personrebles.attackruins",
        params = { target = position }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("个人叛军攻打废墟", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--个人叛军使用道具
--@ pid : 道具id
--@ position : 个人叛军的棋盘坐标[x,y]
function socketHelper:pr_useProp(callback, pid, position)
    local tb = {
        cmd = "personrebles.useprop",
        params = { pid = pid, target = position }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("个人叛军使用道具", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--个人叛军侦察
--@ position : 个人叛军的棋盘坐标[x,y]
function socketHelper:pr_scout(callback, position)
    local tb = {
        cmd = "personrebles.rebelscout",
        params = { target = position }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("个人叛军侦察", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--个人叛军攻打
--@ position : 个人叛军的棋盘坐标[x,y]
--@ fleetinfo: 出战的部队
--@ hero: 出战将领
--@ emblemID: 军徽ID
--@ planePos: 飞机解锁位置
--@ aitroops: AI部队
--@ airShipId: 飞艇ID
function socketHelper:pr_battle(callback, position, fleetinfo, hero, emblemID, planePos, aitroops, airShipId)
    local tb = {
        cmd = "personrebles.battle",
        params = { targetid = position, fleetinfo = fleetinfo, hero = hero, equip=emblemID, plane=planePos, at=aitroops, ap = airShipId }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("个人叛军攻打", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--个人叛军获取战报列表
function socketHelper:pr_reportList(callback)
    local tb = {
        cmd = "personrebles.getreport",
        params = {}
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("个人叛军获取战报列表", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--个人叛军查看战报详情
--@ eid : 战报的id
function socketHelper:pr_reportRead(callback, eid)
    local tb = {
        cmd = "personrebles.read",
        params = { eid = eid }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("个人叛军查看战报详情", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end
--欢乐举报
-- active.hljb.set  放入操作
-- params:num 放入数量
-- active.hljb.get 取出操作
-- active.hljb.changeItem 兑换奖励
-- params:num 兑换数量 params:id 兑换id
-- active.hljb.getlog 纪录
function socketHelper:acHljbSocket(callback,addCmd,id,num)
    local tb={}
    tb["cmd"]="active.hljb."..addCmd
    tb["params"]={id=id,num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("欢乐举报",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"]) 
end

--军团礼包 ：全部领取
function socketHelper:allianceGiftRec(aid,callback)
    local tb = {
        cmd = "alliance.receivegift",
        params = { aid = aid }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("军团礼包 ：全部领取", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--自定义活动购买
--@ sid : 商品id
--@ acKey : 活动名称的key
--@ buyNum : 购买数量
function socketHelper:acCustomBuy(callback, sid, acKey, buyNum)
    local tb = {
        cmd = "active.jblb.buy",
        params = { sid = sid, aname = acKey, num = buyNum }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("自定义活动购买", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--名将成双购买
function socketHelper:acMjcsSocketBuy(callback,tid,num)
    local tb={}
    tb["cmd"]="active.mjcs.buy"
    tb["params"]={sid=tid,num=num}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("名将成双购买",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"]) 
end

--名将成双任务
function socketHelper:acMjcsSocketTask(action,callback,tid)
    local tb={}
    tb["cmd"]="active.mjcs.task"
    tb["params"]={type=action,tid=tid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("名将成双任务",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--远征军复活将领
function socketHelper:expeditionReviveHero(callback)
    local tb = {
        cmd = "expedition.revivehero",
        params = {}
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("远征军复活将领", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--排行榜查看用户信息
function socketHelper:rankUserInfo( callback,tid)
    local tb={}
    tb["cmd"]="ranking.getuser"
    tb["params"]={did=tid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("排行榜查看用户信息",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--【跨服演习战】初始化
function socketHelper:exerWarInit(callback)
    local tb = {
        cmd = "exerwar.crossinit",
        params = {}
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【跨服演习战】初始化", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【跨服演习战】设置阵容
--@lineupsTb : 阵容数据
function socketHelper:exerWarSettingsLineups(callback, lineupsTb)
    local tb = {
        cmd = "exerwar.setinfo",
        params = { setinfo = lineupsTb }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【跨服演习战】设置阵容", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

---跨服演习 服内排行信息，军演第一，竞拍最终玩家
function socketHelper:exerWarRanklist(callback)
    local tb = {
        cmd = "exerwar.ranklist",
        params = {}
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("跨服演习 服内排行信息，军演第一，竞拍最终玩家", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end
--跨服演习 服内竞拍
function socketHelper:exerWarAuction(gem,callback)
    local tb = {
        cmd = "exerwar.auction",
        params = {gem=gem}
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("跨服演习 服内竞拍====>>", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【跨服演习战】获取决赛日的16强
function socketHelper:exerWarFinal(callback)
    local tb = {
        cmd = "exerwar.battlelist",
        params = {}
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【跨服演习战】获取决赛日的16强", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【跨服演习战】点赞
function socketHelper:exerWarPraise(callback)
    local tb = {
        cmd = "exerwar.praise",
        params = {}
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【跨服演习战】点赞", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【跨服演习战】商店购买
--@ shopid:商店id
--@ num:购买数量
function socketHelper:exerWarShopBuy(callback, shopid, num)
    local tb = {
        cmd = "exerwar.shopbuy",
        params = { shopid = shopid, num = num }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【跨服演习战】商店购买", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【军令】获取数据
function socketHelper:getMilitaryOrders(callback)
    local tb = {
        cmd = "monthgive.military.get",
        params = {}
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【军令】获取数据", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【军令】激活军令(荣誉奖励)
function socketHelper:militaryOrdersActivate(callback)
    local tb = {
        cmd = "monthgive.military.activation",
        params = {}
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【军令】激活军令(荣誉奖励)", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【军令】领取奖励
--@ moLv:领取等级(一键领取 默认不传)
function socketHelper:militaryOrdersReward(callback, moLv)
    local tb = {
        cmd = "monthgive.military.reward",
        params = { sid = moLv }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【军令】领取奖励", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【军令】商店购买
--@ sid:商品id
--@ num:购买数量
function socketHelper:militaryOrdersBuy(callback, sid, num)
    local tb = {
        cmd = "monthgive.military.buy",
        params = { sid = sid, n = num }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【军令】商店购买", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【军令】解锁军令等级
--@ unlockType:解锁类型（1 解锁下一级，2 解锁至X级）
function socketHelper:militaryOrdersUnlock(callback, unlockType)
    local tb = {
        cmd = "monthgive.military.unlock",
        params = { act = unlockType }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【军令】解锁军令等级", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【战机改装】初始化数据
function socketHelper:planeRefitInit(callback)
    local tb = {
        cmd = "plane.refit.init",
        params = {},
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【战机改装】初始化数据", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【战机改装】聚能
--@placeId : 部位id
--@chargeType : 聚能类型(1-资源,2-金币)
--@chargeCount : 聚能次数
function socketHelper:planeRefitCharge(callback, placeId, chargeType, chargeCount)
    local tb = {
        cmd = "plane.refit.egather",
        params = { cid = placeId, usetype = chargeType, count = chargeCount },
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【战机改装】聚能", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【战机改装】改装
--@placeId : 部位id
--@planeId : 战机id（因后端识别成了number类型，故该id必须是处理后的number类型）
--@lockRefitTypeIndexTb : 上锁的改装类型索引（从UI界面上看是从左至右、从上至下的顺序）
function socketHelper:planeRefitRefit(callback, placeId, planeId, lockRefitTypeIndexTb)
    local tb = {
        cmd = "plane.refit.baptize",
        params = { cid = placeId, pid = planeId, lock = lockRefitTypeIndexTb },
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【战机改装】改装", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【战机改装】保存改装
--@placeId : 部位id
--@planeId : 战机id（因后端识别成了number类型，故该id必须是处理后的number类型）
function socketHelper:planeRefitSaveRefit(callback, placeId, planeId)
    local tb = {
        cmd = "plane.refit.savebaptize",
        params = { cid = placeId, pid = planeId },
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【战机改装】保存改装", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【战机改装】自动改装
--@placeId : 部位id
--@planeId : 战机id（因后端识别成了number类型，故该id必须是处理后的number类型）
--@refitCount : 改装次数
--@refitConditionIndexTb : 改装条件的索引
--@lockRefitTypeIndexTb : 上锁的改装类型索引（从UI界面上看是从左至右、从上至下的顺序）
function socketHelper:planeRefitAutoRefit(callback, placeId, planeId, refitCount, refitConditionIndexTb, lockRefitTypeIndexTb)
    local tb = {
        cmd = "plane.refit.autobaptize",
        params = { cid = placeId, pid = planeId, count = refitCount, condition = refitConditionIndexTb, lock = lockRefitTypeIndexTb },
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【战机改装】自动改装", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【战机改装】技能升级
--@placeId : 部位id
--@planeId : 战机id（因后端识别成了number类型，故该id必须是处理后的number类型）
--@refitTypeIndex : 改装类型索引（从UI界面上看是从左至右、从上至下的顺序）
--@skillIndex : 分段的索引值（从12点方向的顺时针开始）
function socketHelper:planeRefitSkillUpgrade(callback, placeId, planeId, refitTypeIndex, skillIndex)
    local tb = {
        cmd = "plane.refit.upskill",
        params = { cid = placeId, pid = planeId, pos = refitTypeIndex, sid = skillIndex },
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【战机改装】技能升级", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--周年狂欢2019获取活动数据接口
function socketHelper:acZnkh19Get(callback)
    local tb = {cmd = "active.znkh2019.get",params = {}}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("周年狂欢2019获取活动数据接口", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--周年狂欢2019获取活动抽奖
function socketHelper:acZnkh19Lottery(free, num, callback)
    local tb = {cmd = "active.znkh2019.draw",params = {free = free, num = num}}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("周年狂欢2019获取活动抽奖", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--周年狂欢2019领取充值奖励
function socketHelper:acZnkh19GemsReward(callback)
    local tb = {cmd = "active.znkh2019.rechargerd",params = {}}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("周年狂欢2019领取充值奖励", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--周年狂欢2019瓜分金币奖池
function socketHelper:acZnkh19DevideGems(callback)
    local tb = {cmd = "active.znkh2019.getgem",params = {}}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("周年狂欢2019瓜分金币奖池", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--周年狂欢2019兑换数字组合奖励
function socketHelper:acZnkh19Exchange(etb, num, callback)
    local tb = {cmd = "active.znkh2019.exchange",params = {etb = etb, num = num}}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("周年狂欢2019兑换数字组合奖励", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--周年狂欢2019赠送数字
function socketHelper:acZnkh19NumeralSend(ackey, receiver, callback)
    local tb = {cmd = "active.znkh2019.send",params = {ackey = ackey, receiver = receiver}}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("周年狂欢2019赠送数字", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

-- 远征 宝箱
function socketHelper:expeditionBox(sid,callback)
    local tb = {cmd = "expedition.stage",params = {sid = sid}}
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("远征 宝箱",requestStr)
    self:sendRequest(requestStr,callback,tb["cmd"])
end

--【充值活动（神秘宝箱）】领取奖励
--@rewardId : 奖励id
function socketHelper:acMysteryBoxReward(callback, rewardId)
    local tb = {
        cmd = "active.smbx.reward",
        params = { tid = rewardId }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【充值活动（神秘宝箱）】领取奖励", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--飞艇接口
function socketHelper:airShipSocket(callback,addCmd,newParams)
    local tb = {
        cmd = "airship.airship."..addCmd,
        params = newParams
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("飞艇借口 addCmd: ",addCmd)
    self:sendRequest(requestStr, callback, tb["cmd"])
end
--【战略中心】初始化数据
function socketHelper:strategyCenterInit(callback)
    local tb = {
        cmd = "strategy.get",
        params = {}
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【战略中心】初始化数据", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【战略中心】基础战略经验转换
function socketHelper:strategyCenterExpTransform(callback)
    local tb = {
        cmd = "strategy.basic.tranexp",
        params = {}
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【战略中心】基础战略经验转换", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【战略中心】派遣将领
--@hidTb : 要派遣的将领id
function socketHelper:strategyCenterHeroDispatch(callback, hidTb)
    local tb = {
        cmd = "strategy.basic.shero",
        params = { h = hidTb }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【战略中心】派遣将领", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【战略中心】领取派遣奖励
function socketHelper:strategyCenterRewardDispatch(callback)
    local tb = {
        cmd = "strategy.basic.heroreward",
        params = {}
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【战略中心】领取派遣奖励", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【战略中心】基础/巅峰战略洗点
--@tabType : 1-基础战略，2-巅峰战略
function socketHelper:strategyCenterResetPoint(callback, tabType)
    local tb = {
        cmd = "",
        params = {}
    }
    if tabType == 1 then
        tb.cmd = "strategy.basic.wash"
    elseif tabType == 2 then
        tb.cmd = "strategy.peak.wash"
    end
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    if tabType == 1 then
        print("【战略中心】基础战略洗点", requestStr)
    elseif tabType == 2 then
        print("【战略中心】巅峰战略洗点", requestStr)
    end
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【战略中心】基础/巅峰战略技能升级
--@tabType : 1-基础战略，2-巅峰战略
--@skillId : 技能id
function socketHelper:strategyCenterSkillUpgrade(callback, tabType, skillId)
    local tb = {
        cmd = "",
        params = { sid = skillId }
    }
    if tabType == 1 then
        tb.cmd = "strategy.basic.basicskill"
    elseif tabType == 2 then
        tb.cmd = "strategy.peak.peakskill"
    end
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    if tabType == 1 then
        print("【战略中心】基础战略技能升级", requestStr)
    elseif tabType == 2 then
        print("【战略中心】巅峰战略技能升级", requestStr)
    end
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【战略中心】巅峰战略升级
function socketHelper:strategyCenterPeakednessUpgrade(callback)
    local tb = {
        cmd = "strategy.peak.upgrade",
        params = {}
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【战略中心】巅峰战略升级", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--协力攀登商店兑换
function socketHelper:acXlpdShopBuy(callback, sid, shopNum)
    local tb = {
        cmd = "active.xlpd.buy",
        params = { sid = sid, num = shopNum},
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("协力攀登商店兑换", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end
--协力攀登
function socketHelper:acXlpdSokcet(callback,addCmd,params,sync)
    local tb = {
                cmd = "active.xlpd."..addCmd,
                params = params
            }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("协力攀登 "..addCmd, requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"], sync)
end

--【怀旧服活动】初始化数据
--@b_zoneId<int> : 已绑定的当前所在服务器id
--@b_host<string> : 已绑定的当前所在服务器地址
--@b_port<int> : 已绑定的当前所在服务器端口号
function socketHelper:acMemoryServer_initData(callback, b_zoneId, b_host, b_port)
    local tb = {
        cmd = "active.hjld.get",
        params = { bzid = b_zoneId, host = b_host, port = b_port }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【怀旧服活动】初始化数据", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【怀旧服活动】绑定老服账号
--@b_uid<int> : 要绑定的老号uid
--@b_zoneId<int> : 要绑定的老号当前所在服务器id
--@b_host<string> : 要绑定的老号当前所在服务器地址
--@b_port<int> : 要绑定的老号当前所在服务器端口号
--@b_oldZoneId<int> : 要绑定的老号初始服务器id
--@localOldZoneId<int> : 本服的初始服务器id（怀旧服新号）
function socketHelper:acMemoryServer_bind(callback, b_uid, b_zoneId, b_host, b_port, b_oldZoneId, localOldZoneId)
    local tb = {
        cmd = "active.hjld.bind",
        params = { buid = b_uid, bzid = b_zoneId, host = b_host, port = b_port, bozid = b_oldZoneId, ozid = localOldZoneId }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【怀旧服活动】绑定老服账号", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【怀旧服活动】任务领奖
--@taskType<int> : 任务类型(1-怀旧服新兵任务，2-新兵和老兵的协同任务)
--@taskId<int> : 任务序号id
--@taskIndex<int> : 任务完成进度序号
--@b_zoneId<int> : 已绑定的当前所在服务器id
--@b_host<string> : 已绑定的当前所在服务器地址
--@b_port<int> : 已绑定的当前所在服务器端口号
function socketHelper:acMemoryServer_taskReward(callback, taskType, taskId, taskIndex, b_zoneId, b_host, b_port)
    local tb = {
        cmd = "active.hjld.getreward",
        params = { ["type"] = taskType, tid = taskId, sid = taskIndex, bzid = b_zoneId, host = b_host, port = b_port }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【怀旧服活动】任务领奖", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【怀旧服活动】获取要绑定的老服玩家信息(角色名称、等级)
--@b_uid<int> : 要绑定的老号uid
--@b_zoneId<int> : 要绑定的老号当前所在服务器id
--@b_host<string> : 要绑定的老号当前所在服务器地址
--@b_port<int> : 要绑定的老号当前所在服务器端口号
function socketHelper:acMemoryServer_bindUserInfo(callback, b_uid, b_zoneId, b_host, b_port)
    local tb = {
        cmd = "active.hjld.getuserinfo",
        params = { buid = b_uid, bzid = b_zoneId, host = b_host, port = b_port }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【怀旧服活动】获取要绑定的老服玩家信息(角色名称、等级)", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--悬赏盛典任务  act 1 本服奖励， 2 个人奖励， 3 任务积分奖励
function socketHelper:acXssd2019SocketTask(act,tid,dw,callBack)
    local tb={}
    tb["cmd"]="active.xssd2019.task"
    if dw then
        tb["params"]={act=act,tid=tid,dw=dw}
    else
        tb["params"]={act=act,tid=tid}
    end
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("悬赏盛典任务",requestStr)
    self:sendRequest(requestStr,callBack,tb["cmd"])
end

--悬赏抽奖   pt : 1 奖章， 2 金币     num : 1 or 10
function socketHelper:acXssd2019SocketLottery(num,pt,callBack)
    local tb={}
    tb["cmd"]="active.xssd2019.draw"
    tb["params"]={num=num,pt=pt}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("悬赏盛典任务 :悬赏抽奖",requestStr)
    self:sendRequest(requestStr,callBack,tb["cmd"])
end

--悬赏抽奖日志
function socketHelper:acXssd2019SocketGetLog(callBack)
    local tb={}
    tb["cmd"]="active.xssd2019.getlog"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("悬赏盛典任务 :悬赏抽奖日志",requestStr)
    self:sendRequest(requestStr,callBack,tb["cmd"])
end

--破译密码奖励   tid 奖励id  1 ~ 7  如果领取全部破译奖励 tid=0
function socketHelper:acXssd2019SocketDecipher(tid,callBack)
    local tb={}
    tb["cmd"]="active.xssd2019.decipher"
    tb["params"]={tid=tid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("悬赏盛典任务 : 悬赏抽奖",requestStr)
    self:sendRequest(requestStr,callBack,tb["cmd"])
end

--悬赏领红包
function socketHelper:acXssd2019RedBag(redid,callBack)
    local tb={}
    tb["cmd"]="active.xssd2019.redbag"
    tb["params"]={redid=redid}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("悬赏盛典任务 : 悬赏领红包",requestStr)
    self:sendRequest(requestStr,callBack,tb["cmd"])
end

--悬赏领红包 get 
function socketHelper:acXssd2019GetData(callBack)
    local tb={}
    tb["cmd"]="active.xssd2019.get"
    tb["params"]={}
    self:addBaseInfo(tb)
    local requestStr=G_Json.encode(tb)
    print("悬赏盛典任务====== get ===== :",requestStr)
    self:sendRequest(requestStr,callBack,tb["cmd"])
end

--【配件】红配晋升
--@tankType<int> : 坦克类型
--@posIndex<int> : 位置索引
--@fid<string> : 碎片id
function socketHelper:accessoryPromote(callback, tankType, posIndex, fid)
    local tb = {
        cmd = "accessory.prompt",
        params = {["type"] = tankType, ptype = posIndex, of = fid}
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【配件】红配晋升", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

--【现金礼包】领取奖励
--@rewardId : 奖励id
function socketHelper:acCashGiftBagReward(callback, rewardId)
    local tb = {
        cmd = "active.xjlb.reward",
        params = { tid = rewardId }
    }
    self:addBaseInfo(tb)
    local requestStr = G_Json.encode(tb)
    print("【现金礼包】领取奖励", requestStr)
    self:sendRequest(requestStr, callback, tb["cmd"])
end

-- 紧急召回_刷新
function socketHelper:jjzz_refresh(callback)
    self:sendReq("active.jjzz.refresh",{},callback)
end
-- 紧急召回_切换将领
function socketHelper:jjzz_change(k1,k2,callback)
    self:sendReq("active.jjzz.change",{k1=k1,k2=k2},callback)
end
-- 紧急召回_抽奖
function socketHelper:jjzz_lottery(num,callback)
    self:sendReq("active.jjzz.lottery",{num=num},callback)
end
-- 紧急召回_抽奖记录
function socketHelper:jjzz_getReportLog(callback)
    self:sendReq("active.jjzz.getReportLog",{},callback)
end

-- 能量工厂__ 刷新
function socketHelper:nlgc_refresh(callback)
    self:sendReq("active.nlgc.refresh",{},callback)
end

-- 能量工厂__领奖 
function socketHelper:nlgc_reward(id,num,callback)
    self:sendReq("active.nlgc.reward",{id=id,num=num},callback)
end
-- 能量工厂__ 商店 
function socketHelper:nlgc_shop(gid,enery,callback)
    self:sendReq("active.nlgc.shop",{gid=gid,enery=enery},callback)
end
--配件仓库扩容
--@bagIdx : 配件仓库的页签索引
function socketHelper:accessoryBagDilatation(bagIdx, callBack)
    self:sendReq("accessory.expansion", {eid=bagIdx}, callBack)
end