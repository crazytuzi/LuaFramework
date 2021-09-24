local MsgReq = classGc(function(self, msgid)
    self.MsgID = msgid
    self:init()
end)

function MsgReq.init(self, reactTime, tabReact)
    self.ReactTime     = reactTime
    self.ReactProtocol = tabReact
end

function MsgReq.encode(self, w)
    
end

--/** AUTO_CODE_BEGIN_REQH **************** don't touch this line ********************/
--/** =============================== 自动生成的代码 =============================== **/
-- (2261手动) -- [2261]批量出售背包物品 -- 物品/背包 
REQ_GOODS_P_SELL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GOODS_P_SELL
    self:init(0, nil)
end)

function REQ_GOODS_P_SELL.encode(self, w)
    w:writeInt16Unsigned(self.count)  -- {数量}
    -- w:writeXXXGroup(self.data)  -- {信息块2260}
    for i=1,self.count do
        w:writeInt16Unsigned(self.data[i].index)  -- {物品索引}
        w:writeInt16Unsigned(self.data[i].count)  -- {物品数量}
    end
end

function REQ_GOODS_P_SELL.setArgs(self,count,data)
    self.count = count  -- {数量}
    self.data = data  -- {信息块2260}
end
-- end2261
-- (2530手动) -- [2530]装备洗练 -- 物品/打造/强化 
REQ_MAKE_WASH = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_WASH
    self:init(0, nil)
end)

function REQ_MAKE_WASH.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- {1背包2装备栏}
    w:writeInt32Unsigned(self.id)  -- {主将0|武将ID}
    w:writeInt16Unsigned(self.idx)  -- {物品的idx}
    w:writeInt8Unsigned(self.arg)  -- {洗练方式(见?CONST_MAKE_WASH_TYPE)}
    w:writeInt16Unsigned(self.count)  -- {锁定个数}
    -- w:writeXXXGroup(self.msg_pos)  -- {锁定位置}
    if self.count > 0 then
        for i=1,self.count do
            print("输出锁定位置是====",self.msg_pos[i])
            w:writeInt8Unsigned(self.msg_pos[i])  -- {锁定个数}
        end
    end
end

function REQ_MAKE_WASH.setArgs(self,type,id,idx,arg,count,msg_pos)
    self.type = type  -- {1背包2装备栏}
    self.id = id  -- {主将0|武将ID}
    self.idx = idx  -- {物品的idx}
    self.arg = arg  -- {洗练方式(见?CONST_MAKE_WASH_TYPE)}
    self.count = count  -- {锁定个数}
    self.msg_pos = msg_pos  -- {锁定位置信息块（2531）}
end
-- end2530
-- (2770手动) -- [2770]饰品分解 -- 物品/打造/强化 
REQ_MAKE_DECOMPOSE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_DECOMPOSE
    self:init(0, nil)
end)

function REQ_MAKE_DECOMPOSE.encode(self, w)
    w:writeInt16Unsigned(self.count)  -- { 数量}
    -- w:writeInt32Unsigned(self.xxx_idx)  -- { 物品信息块}
    if self.count > 0 then
        for i=1,self.count do
            w:writeInt16Unsigned(self.xxx_idx[i].idx)  -- {物品索引}
            w:writeInt16Unsigned(self.xxx_idx[i].count)  -- {物品数量}
        end
    end
end

function REQ_MAKE_DECOMPOSE.setArgs(self,count,xxx_idx)
    self.count = count  -- { 数量}
    self.xxx_idx = xxx_idx  -- { 物品信息块}
end
-- end2770
-- (4070手动) -- [4070]添加好友 -- 好友 
REQ_FRIEND_ADD = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FRIEND_ADD
    self:init(0, nil)
end)

function REQ_FRIEND_ADD.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- {类型} 
    w:writeInt16Unsigned(self.count)  -- {数量}
    -- w:writeXXXGroup(self.msg_role_xxx)  -- {人物信息块}
    print("test --->",self.msg_role_xxx)
    for i=1,self.count do
        -- local testClan = self.msg_role_xxx[i]
        -- print(testClan,"writeInt32Unsigned")
        w:writeInt32Unsigned(self.msg_role_xxx[i])
        -- w:writeInt32Unsigned(self.msg_role_xxx[i].id)
        -- w:writeString(self.msg_role_xxx[i].name)
        -- w:writeString(self.msg_role_xxx[i].clan)
        -- w:writeInt16Unsigned(self.msg_role_xxx[i].lv)
        -- w:writeInt8Unsigned(self.msg_role_xxx[i].is_online)
        -- w:writeInt8Unsigned(self.msg_role_xxx[i].pro)
        -- w:writeInt32Unsigned(self.msg_role_xxx[i].powerful)
        -- w:writeInt8Unsigned(self.msg_role_xxx[i].is)
        -- w:writeInt8Unsigned(self.msg_role_xxx[i].is2)
    end
end

function REQ_FRIEND_ADD.setArgs(self,type,count,msg_role_xxx)
    self.type = type  -- {类型}
    self.count = count  -- {数量}
    self.msg_role_xxx = msg_role_xxx  -- {人物信息块}
end
-- end4070
-- (6025手动) -- [6025]伤害统一发送 -- 战斗 
REQ_WAR_HARM_ALL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WAR_HARM_ALL
    self:init(0, nil)
end)

function REQ_WAR_HARM_ALL.encode(self, w)
    w:writeInt16Unsigned(self.count)  -- {数量}
    -- w:writeXXXGroup(self.msg_xxx)  -- {信息块 6021}
    for _,v in pairs(self.msg_xxx) do
        v:encode(w)
    end
end

function REQ_WAR_HARM_ALL.setArgs(self,count,msg_xxx)
    self.count = count  -- {数量}
    self.msg_xxx = msg_xxx  -- {信息块 6021}
end
-- end6025
-- (6120手动) -- [6120]战斗技能验证 -- 战斗 
REQ_WAR_SKILL_CHECK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WAR_SKILL_CHECK
    self:init(0, nil)
end)

function REQ_WAR_SKILL_CHECK.encode(self, w)
    w:writeInt16Unsigned(self.count)  -- { 技能个数(不包括普攻)}
    w:writeXXXGroup(self.msg_skill)  -- { 技能信息块(6125)}
end

function REQ_WAR_SKILL_CHECK.setArgs(self,count,msg_skill)
    self.count = count  -- { 技能个数(不包括普攻)}
    self.msg_skill = msg_skill  -- { 技能信息块(6125)}
end
-- end6120
-- (7031手动) -- [7031](NEW)创建进入副本 -- 副本 
REQ_COPY_NEW_CREAT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_NEW_CREAT
    self:init(0, nil)
end)

function REQ_COPY_NEW_CREAT.encode(self, w)
    w:writeInt16Unsigned(self.copy_id)  -- {副本ID}
    w:writeString(self.key)  -- {副本验证串}
end

function REQ_COPY_NEW_CREAT.setArgs(self,copy_id,key)
    self.copy_id = copy_id  -- {副本ID}
    -- self.key = key  -- {副本验证串}
    local property  = _G.GPropertyProxy.m_lpMainPlay
    local originKey = property:getPropertyKey()
    self.key = gc.Md5Crypto:md5(originKey,string.len(originKey))
    print("self.key=",self.key)
end
-- end7031
-- (8501手动) -- [8501]发送的邮件ID -- 邮件 
REQ_MAIL_ID_SEND = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAIL_ID_SEND
    self:init(0, nil)
end)

function REQ_MAIL_ID_SEND.encode(self, w)
    w:writeInt32Unsigned(self.mail_id)  -- {作为发送的邮件ID}
end

function REQ_MAIL_ID_SEND.setArgs(self,mail_id)
    self.mail_id = mail_id  -- {作为发送的邮件ID}
end
-- end8501
-- (8550手动) -- [8550]提取邮件物品 -- 邮件 
REQ_MAIL_PICK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAIL_PICK
    self:init(0, nil)
end)

function REQ_MAIL_PICK.encode(self, w)
    w:writeInt16Unsigned(self.count)  -- {数量}
    if self.count > 0 then
        for i=1,self.count do
            w:writeInt32Unsigned(self.mail_ids[i]) -- {邮件ID信息块}
        end
    end
    -- w:writeXXXGroup(self.mail_ids)  -- {邮件ID信息块(8501)}
end

function REQ_MAIL_PICK.setArgs(self,count,mail_ids)
    self.count = count  -- {数量}
    self.mail_ids = mail_ids  -- {邮件ID信息块(8501)}
end
-- end8550
-- (8560手动) -- [8560]删除邮件 -- 邮件 
REQ_MAIL_DEL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAIL_DEL
    self:init(0, nil)
end)

function REQ_MAIL_DEL.encode(self, w)
    w:writeInt16Unsigned(self.count)  -- {数量}
    for i=1,self.count do
        w:writeInt32Unsigned(self.mail_ids[i])
    end
    -- w:writeXXXGroup(self.mail_ids)  -- {邮件ID信息块(8501)}
end

function REQ_MAIL_DEL.setArgs(self,count,mail_ids)
    self.count = count  -- {邮件ID数量}
    self.mail_ids = mail_ids  -- {邮件ID信息块}
end
-- end8560
-- (8580手动) -- [8580]请求保存邮件 -- 邮件 
REQ_MAIL_SAVE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAIL_SAVE
    self:init(0, nil)
end)

function REQ_MAIL_SAVE.encode(self, w)
    w:writeInt16Unsigned(self.count)  -- {邮件ID数量}
    if self.count > 0 then
        for i=1,self.count do
            w:writeInt32Unsigned(self.mail_ids[i]) -- {邮件ID信息块}
        end
    end
end

function REQ_MAIL_SAVE.setArgs(self,count,mail_ids)
    self.count = count  -- {数量}
    self.mail_ids = mail_ids  -- {邮件ID信息块(8501)}
end
-- end8580
-- (9510手动) -- [9510]发送频道聊天 -- 聊天 
REQ_CHAT_SEND = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CHAT_SEND
    self:init(0, nil)
end)

function REQ_CHAT_SEND.encode(self, w)
    w:writeInt8Unsigned(self.channel_id)  -- {频道类型}
    w:writeInt32Unsigned(self.uid)  -- {对方UID}
    w:writeInt16Unsigned(self.team_id)  -- {组队ID}
    w:writeUTF(self.msg)  -- {聊天内容}
    w:writeInt16Unsigned(self.count)  -- {物品数量}
    
    if self.msg_goods~=nil then
        for _,goodsMsg in ipairs(self.msg_goods) do
            goodsMsg:encode(w)
        end
    end
    -- w:writeXXXGroup(self.msg_goods)  -- {物品信息块（物品Id和数量）}
end

function REQ_CHAT_SEND.setArgs(self,channel_id,uid,team_id,msg,count,msg_goods)
    self.channel_id = channel_id  -- {频道类型}
    self.uid = uid  -- {对方UID}
    self.team_id = team_id  -- {组队ID}
    self.msg = msg  -- {聊天内容}
    self.count = count  -- {物品数量}
    self.msg_goods = msg_goods  -- {物品信息块（9513）}
end
-- end9510
-- (9526手动) -- [9526]发送名字私聊 -- 聊天 
REQ_CHAT_NAME = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CHAT_NAME
    self:init(0, nil)
end)

function REQ_CHAT_NAME.encode(self, w)
    w:writeInt32(self.uid)  -- {对方UID}
    w:writeString(self.name)  -- {对方名字}
    w:writeUTF(self.msg)  -- {聊天内容}
    w:writeInt16Unsigned(self.goods_count)  -- {物品数量}
    -- w:writeXXXGroup(self.goods_list)  -- {发送物品信息块}
    if self.goods_list~=nil then
        for _,goodsMsg in ipairs(self.goods_list) do
            goodsMsg:encode(w)
        end
    end
end

function REQ_CHAT_NAME.setArgs(self,uid,name,msg,goods_count,goods_msg)
    self.uid = uid  -- {玩家UID}
    self.name = name  -- {对方名字}
    self.msg = msg  -- {聊天内容}
    self.goods_count = goods_count  -- {物品数量}
    self.goods_msg = goods_msg  -- {物品信息块(9513)}
end
-- end9526
-- (23828手动) -- [23828]挑战(新) -- 封神台 
REQ_ARENA_BATTLE_NEW = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ARENA_BATTLE_NEW
    self:init(0, nil)
end)

function REQ_ARENA_BATTLE_NEW.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- {玩家uid}
    w:writeInt16Unsigned(self.rank)  -- {被挑战者的排名}
    w:writeInt8Unsigned(self.type)  -- {类型 0:普通 1:排行挑战}
    w:writeString(self.key)  -- {验证串}
end

function REQ_ARENA_BATTLE_NEW.setArgs(self,uid,rank,type,key)
    self.uid = uid  -- {玩家uid}
    self.rank = rank  -- {被挑战者的排名}
    self.type = type  -- {类型 0:普通 1:排行挑战}
    -- self.key = key  -- {验证串}
    local property  = _G.GPropertyProxy.m_lpMainPlay
    local originKey = property:getPropertyKey()
    self.key = gc.Md5Crypto:md5(originKey,string.len(originKey))
    print("self.key=",self.key)
end
-- end23828
-- (25125手动) -- [25125]阵容保存 -- 灵妖竞技场 
REQ_LINGYAO_ARENA_BATTLE_SAVE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_ARENA_BATTLE_SAVE
    self:init(0, nil)
end)

function REQ_LINGYAO_ARENA_BATTLE_SAVE.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型(1防守2进攻)}
    w:writeInt8Unsigned(self.count)  -- { 数量}
    -- w:writeXXXGroup(self.msg)  -- { 阵容信息块（25120）}
    for k,v in pairs(self.msg) do
        w:writeInt16Unsigned(v.id)
        w:writeInt8Unsigned(v.pos)
    end
end

function REQ_LINGYAO_ARENA_BATTLE_SAVE.setArgs(self,type,count,msg)
    self.type = type  -- { 类型(1防守2进攻)}
    self.count = count  -- { 数量}
    self.msg = msg  -- { 阵容信息块（25120）}
end
-- end25125
-- (25140手动) -- [25140]挑战 -- 灵妖竞技场 
REQ_LINGYAO_ARENA_BATTLE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_ARENA_BATTLE
    self:init(0, nil)
end)

function REQ_LINGYAO_ARENA_BATTLE.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 对手id}
    w:writeInt16Unsigned(self.rank)  -- { 排名}
    w:writeString(self.key)  -- { 验证通过key}
    w:writeInt8Unsigned(self.count)  -- { 数量}
    for i=1,self.count do
        w:writeInt16Unsigned(self.tempData[i].id)  -- { 灵妖ID}
        w:writeInt8Unsigned(self.tempData[i].pos)  -- { 灵妖位置}
    end
    
end

function REQ_LINGYAO_ARENA_BATTLE.setArgs(self,uid,rank,key,count,tempData)
    self.uid = uid  -- { 对手id}
    self.rank = rank  -- { 排名}
    -- self.key = key  -- { 验证通过key}
    local property  = _G.GPropertyProxy.m_lpMainPlay
    local originKey = property:getPropertyKey()
    self.key = gc.Md5Crypto:md5(originKey,string.len(originKey))

    self.count = count  -- { 数量}
    self.tempData = tempData
    -- self.id = id  -- { 灵妖ID}
    -- self.pos = pos  -- { 灵妖位置}
end
-- end25140
-- (31560手动) -- [31560]请求副本挑战次数 -- 灵妖系统 
REQ_LINGYAO_COPY_TIMES = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_COPY_TIMES
    self:init(0, nil)
end)

function REQ_LINGYAO_COPY_TIMES.encode(self, w)
    w:writeInt8Unsigned(self.count)  -- { 数量}
    if self.count > 0 then
        for i=1,self.count do
            print("输出锁定副本ID是====",self.copy_id[i])
            w:writeInt16Unsigned(self.copy_id[i])  -- { 副本ID}
        end
    end
end

function REQ_LINGYAO_COPY_TIMES.setArgs(self,count,copy_id)
    self.count = count  -- { 数量}
    self.copy_id = copy_id  -- { 副本ID}
end
-- end31560
-- (44830手动) -- [44830]挑战 -- 跨服竞技场 
REQ_CROSS_BATTLE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CROSS_BATTLE
    self:init(0, nil)
end)

function REQ_CROSS_BATTLE.encode(self, w)
    w:writeInt16Unsigned(self.count)  -- {数量}
    --w:writeXXXGroup(self.msg_pos_xxx)  -- {位置信息块}
    for i,v in ipairs(self.msg_pos_xxx) do
        w:writeInt8Unsigned(v)
    end
end

function REQ_CROSS_BATTLE.setArgs(self,uid,rank,type,key)
    self.uid = uid  -- {玩家uid}
    self.rank = rank  -- {被挑战者的排名}
    self.type = type  -- {类型 0:普通 1:排行挑战}
    self.key = key  -- {验证串}
end
-- end44830
-- (44850手动) -- [44850]挑战结束 -- 跨服竞技场 
REQ_CROSS_FINISH = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CROSS_FINISH
    self:init(0, nil)
end)

function REQ_CROSS_FINISH.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- {玩家uid}
    w:writeInt16Unsigned(self.ranking)  -- {被挑战者的排名}
    w:writeInt8Unsigned(self.res)  -- {0:失败 1:成功}
    w:writeString(self.key)  -- {验证字符}
end

function REQ_CROSS_FINISH.setArgs(self,uid,ranking,res,key)
    self.uid = uid  -- {玩家uid}
    self.ranking = ranking  -- {被挑战者的排名}
    self.res = res  -- {0:失败 1:成功}
    self.key = key  -- {验证字符}
end
-- end44850
-- (50260手动) -- [50260]换牌 -- 翻翻乐 
REQ_FLSH_PAI_SWITCH = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FLSH_PAI_SWITCH
    self:init(0, nil)
end)

function REQ_FLSH_PAI_SWITCH.encode(self, w)
    w:writeInt16Unsigned(self.count)  -- {数量}
    -- w:writeXXXGroup(self.msg_pos_xxx)  -- {位置信息块}
    for i=1,self.count do
        w:writeInt8Unsigned(self.msg_pos_xxx[i])
    end
end

function REQ_FLSH_PAI_SWITCH.setArgs(self,count,msg_pos_xxx)
    self.count = count  -- {数量}
    self.msg_pos_xxx = msg_pos_xxx  -- {位置信息块}
end
-- end50260
-- (55390手动) -- [55390]开始挑战 -- 一骑当千 
REQ_THOUSAND_WAR_BEGIN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_THOUSAND_WAR_BEGIN
    self:init(0, nil)
end)

function REQ_THOUSAND_WAR_BEGIN.encode(self, w)
    w:writeInt8Unsigned(self.pro)  -- {职业}
    w:writeInt16Unsigned(self.count)  -- {数量}
    -- w:writeXXXGroup(self.msg_skill)  -- {技能信息块(55340)}
    if self.count > 0 then 
        for i=1,self.count do
             w:writeInt16Unsigned( self.msg_skill[i] )
        end
    end
end

function REQ_THOUSAND_WAR_BEGIN.setArgs(self,pro,count,msg_skill)
    self.pro = pro  -- {职业}
    self.count = count  -- {数量}
    self.msg_skill = msg_skill  -- {技能信息块(55340)}
end
-- end55390
-- (65340手动) -- [65340]战斗击打箱子 -- 秘宝活动 
REQ_MIBAO_BOX_HARM = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MIBAO_BOX_HARM
    self:init(0, nil)
end)

function REQ_MIBAO_BOX_HARM.encode(self, w)
    w:writeInt16Unsigned(self.count)  -- { 数量}
    for i=1,self.count do
        w:writeInt32Unsigned(self.box_idxs[i])
    end
    -- w:writeInt32Unsigned(self.box_idxs)  -- { 箱子唯一ID信息块}
end

function REQ_MIBAO_BOX_HARM.setArgs(self,count,box_idxs)
    self.count = count  -- { 数量}
    self.box_idxs = box_idxs  -- { 箱子唯一ID信息块}
end
-- end65340
--/** =============================== 自动生成的代码 =============================== **/
--/*************************** don't touch this line *********** AUTO_CODE_END_REQH **/



--/** AUTO_CODE_BEGIN_REQA **************** don't touch this line ********************/
--/** =============================== 自动生成的代码 =============================== **/

-- [501]角色心跳 -- 系统 
REQ_SYSTEM_HEART = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SYSTEM_HEART
    self:init(0.503 ,{ 1001 })
end)

-- [830]查询是否可充值 -- 系统 
REQ_SYSTEM_PAY_CHECK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SYSTEM_PAY_CHECK
    self:init(0, nil)
end)

function REQ_SYSTEM_PAY_CHECK.encode(self, w)
    w:writeInt8Unsigned(self.flag)  -- { 是否使用财神卡:1使用}
end

function REQ_SYSTEM_PAY_CHECK.setArgs(self,flag)
    self.flag = flag  -- { 是否使用财神卡:1使用}
end

-- [1010]角色登录 -- 角色 
REQ_ROLE_LOGIN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_LOGIN
    self:init(0, nil)
end)

function REQ_ROLE_LOGIN.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 用户ID	}
    w:writeInt32Unsigned(self.uuid)  -- { 用户UUID}
    w:writeInt16Unsigned(self.sid)  -- { 用户SID}
    w:writeInt16Unsigned(self.cid)  -- { 用户CID}
    w:writeString(self.os)  -- { 系统}
    w:writeString(self.pwd)  -- { 密码}
    w:writeInt32Unsigned(self.versions)  -- { 版本号}
    w:writeInt32Unsigned(self.fcm_init)  -- { 防沉迷(0:已解除 n>0:已在线时长)}
    w:writeBoolean(self.relink)  -- { 登录类型（true:短线重连 false:正常登录）}
    w:writeBoolean(self.hide)  -- { false:现在的断开 true:不需要回城}
    w:writeBoolean(self.debug)  -- { 是否调试 （web:false fb:true）}
    w:writeInt32Unsigned(self.login_time)  -- { 时间}
end

function REQ_ROLE_LOGIN.setArgs(self,uid,uuid,sid,cid,os,pwd,versions,fcm_init,relink,hide,debug,login_time)
    self.uid = uid  -- { 用户ID	}
    self.uuid = uuid  -- { 用户UUID}
    self.sid = sid  -- { 用户SID}
    self.cid = cid  -- { 用户CID}
    self.os = os  -- { 系统}
    self.pwd = pwd  -- { 密码}
    self.versions = versions  -- { 版本号}
    self.fcm_init = fcm_init  -- { 防沉迷(0:已解除 n>0:已在线时长)}
    self.relink = relink  -- { 登录类型（true:短线重连 false:正常登录）}
    self.hide = hide  -- { false:现在的断开 true:不需要回城}
    self.debug = debug  -- { 是否调试 （web:false fb:true）}
    self.login_time = login_time  -- { 时间}
end

-- [1020]创建角色 -- 角色 
REQ_ROLE_CREATE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_CREATE
    self:init(0, nil)
end)

function REQ_ROLE_CREATE.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 用户ID	}
    w:writeInt32Unsigned(self.uuid)  -- { 用户UUID}
    w:writeInt16Unsigned(self.sid)  -- { 服务器ID}
    w:writeInt16Unsigned(self.cid)  -- { 合作方ID}
    w:writeString(self.os)  -- { 客户端类型(见:CONST_CLIENT_*)}
    w:writeInt32Unsigned(self.versions)  -- { 版本号}
    w:writeString(self.uname)  -- { 用户名}
    w:writeInt8Unsigned(self.sex)  -- { 性别}
    w:writeInt8Unsigned(self.pro)  -- { 职业}
    w:writeString(self.source)  -- { 来源渠道}
    w:writeString(self.source_sub)  -- { 子渠道}
    w:writeInt32Unsigned(self.login_time)  -- { 登陆时间}
    w:writeInt16Unsigned(self.ext1)  -- { 扩展一}
    w:writeInt16Unsigned(self.ext2)  -- { 扩展二}
end

function REQ_ROLE_CREATE.setArgs(self,uid,uuid,sid,cid,os,versions,uname,sex,pro,source,source_sub,login_time,ext1,ext2)
    self.uid = uid  -- { 用户ID	}
    self.uuid = uuid  -- { 用户UUID}
    self.sid = sid  -- { 服务器ID}
    self.cid = cid  -- { 合作方ID}
    self.os = os  -- { 客户端类型(见:CONST_CLIENT_*)}
    self.versions = versions  -- { 版本号}
    self.uname = uname  -- { 用户名}
    self.sex = sex  -- { 性别}
    self.pro = pro  -- { 职业}
    self.source = source  -- { 来源渠道}
    self.source_sub = source_sub  -- { 子渠道}
    self.login_time = login_time  -- { 登陆时间}
    self.ext1 = ext1  -- { 扩展一}
    self.ext2 = ext2  -- { 扩展二}
end

-- [1024]请求随机名字 -- 角色 
REQ_ROLE_RAND_NAME = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_RAND_NAME
    self:init(0, nil)
end)

function REQ_ROLE_RAND_NAME.encode(self, w)
    w:writeInt8Unsigned(self.sex)  -- { 性别(1:女[默认],2:男)}
end

function REQ_ROLE_RAND_NAME.setArgs(self,sex)
    self.sex = sex  -- { 性别(1:女[默认],2:男)}
end

-- [1060]销毁角色 -- 角色 
REQ_ROLE_DEL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_DEL
    self:init(0, nil)
end)

function REQ_ROLE_DEL.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 用户ID}
end

function REQ_ROLE_DEL.setArgs(self,uid)
    self.uid = uid  -- { 用户ID}
end

-- [1070]角色转职 -- 角色 
REQ_ROLE_PRO_CHANGE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_PRO_CHANGE
    self:init(0, nil)
end)

function REQ_ROLE_PRO_CHANGE.encode(self, w)
    w:writeInt8Unsigned(self.pro)  -- { 转职职业}
end

function REQ_ROLE_PRO_CHANGE.setArgs(self,pro)
    self.pro = pro  -- { 转职职业}
end

-- [1101]请求玩家属性 -- 角色 
REQ_ROLE_PROPERTY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_PROPERTY
    self:init(0, nil)
end)

function REQ_ROLE_PROPERTY.encode(self, w)
    w:writeInt16Unsigned(self.sid)  -- { 服务器ID}
    w:writeInt32Unsigned(self.uid)  -- { 玩家Uid}
    w:writeInt16Unsigned(self.type)  -- { 0:玩家|伙伴IDX}
end

function REQ_ROLE_PROPERTY.setArgs(self,sid,uid,type)
    self.sid = sid  -- { 服务器ID}
    self.uid = uid  -- { 玩家Uid}
    self.type = type  -- { 0:玩家|伙伴IDX}
end

-- [1115]请求玩家排名更新 -- 角色 
REQ_ROLE_RANK_UPDATE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_RANK_UPDATE
    self:init(0, nil)
end)

-- [1121]请求玩家扩展属性(暂无效) -- 角色 
REQ_ROLE_PROPERTY_EXT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_PROPERTY_EXT
    self:init(0, nil)
end)

function REQ_ROLE_PROPERTY_EXT.encode(self, w)
    w:writeInt16Unsigned(self.sid)  -- { 服务器ID}
    w:writeInt32Unsigned(self.uid)  -- { 玩家UID}
end

function REQ_ROLE_PROPERTY_EXT.setArgs(self,sid,uid)
    self.sid = sid  -- { 服务器ID}
    self.uid = uid  -- { 玩家UID}
end

-- [1140]请求NPC -- 角色 
REQ_ROLE_REQUEST_NPC = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_REQUEST_NPC
    self:init(0, nil)
end)

function REQ_ROLE_REQUEST_NPC.encode(self, w)
    w:writeInt16Unsigned(self.npc_id)  -- { NPCID}
    w:writeInt8Unsigned(self.fun_flag)  -- { NPC功能标识}
end

function REQ_ROLE_REQUEST_NPC.setArgs(self,npc_id,fun_flag)
    self.npc_id = npc_id  -- { NPCID}
    self.fun_flag = fun_flag  -- { NPC功能标识}
end

-- [1240]腾讯玩家登陆 -- 角色 
REQ_ROLE_LOGIN_N = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_LOGIN_N
    self:init(0, nil)
end)

function REQ_ROLE_LOGIN_N.encode(self, w)
    w:writeString(self.openid)  -- { 腾讯OPENID}
    w:writeString(self.openkey)  -- { 腾讯OPENKEY}
end

function REQ_ROLE_LOGIN_N.setArgs(self,openid,openkey)
    self.openid = openid  -- { 腾讯OPENID}
    self.openkey = openkey  -- { 腾讯OPENKEY}
end

-- [1241]腾讯创建角色 -- 角色 
REQ_ROLE_CREATE_N = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_CREATE_N
    self:init(0, nil)
end)

function REQ_ROLE_CREATE_N.encode(self, w)
    w:writeString(self.name)  -- { 玩家名称}
    w:writeInt8Unsigned(self.sex)  -- { 性别}
    w:writeInt8Unsigned(self.career)  -- { 职业}
end

function REQ_ROLE_CREATE_N.setArgs(self,name,sex,career)
    self.name = name  -- { 玩家名称}
    self.sex = sex  -- { 性别}
    self.career = career  -- { 职业}
end

-- [1260]请求精力值 -- 角色 
REQ_ROLE_ENERGY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_ENERGY
    self:init(0, nil)
end)

-- [1263]请求购买精力面板 -- 角色 
REQ_ROLE_ASK_BUY_ENERGY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_ASK_BUY_ENERGY
    self:init(0, nil)
end)

-- [1265]购买精力 -- 角色 
REQ_ROLE_BUY_ENERGY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_BUY_ENERGY
    self:init(0, nil)
end)

-- [1269]使用功能 -- 角色 
REQ_ROLE_USE_SYS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_USE_SYS
    self:init(0, nil)
end)

function REQ_ROLE_USE_SYS.encode(self, w)
    w:writeInt16Unsigned(self.sys_id)  -- { 系统ID}
end

function REQ_ROLE_USE_SYS.setArgs(self,sys_id)
    self.sys_id = sys_id  -- { 系统ID}
end

-- [1310]请求VIP(自己) -- 角色 
REQ_ROLE_VIP_MY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_VIP_MY
    self:init(0, nil)
end)

-- [1312]请求玩家VIP -- 角色 
REQ_ROLE_VIP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_VIP
    self:init(0, nil)
end)

function REQ_ROLE_VIP.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家UID}
end

function REQ_ROLE_VIP.setArgs(self,uid)
    self.uid = uid  -- { 玩家UID}
end

-- [1331]请求签到面板 -- 角色 
REQ_ROLE_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_REQUEST
    self:init(0, nil)
end)

-- [1333]玩家点击签到 -- 角色 
REQ_ROLE_CLICK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_CLICK
    self:init(0, nil)
end)

function REQ_ROLE_CLICK.encode(self, w)
    w:writeInt8Unsigned(self.cltype)  -- { 签到类型-见常量[CONST_SIGN_玩家类型]}
end

function REQ_ROLE_CLICK.setArgs(self,cltype)
    self.cltype = cltype  -- { 签到类型-见常量[CONST_SIGN_玩家类型]}
end

-- [1350]领取 -- 角色 
REQ_ROLE_ONLINE_OK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_ONLINE_OK
    self:init(0, nil)
end)

-- [1351]领取等级礼包 -- 角色 
REQ_ROLE_LEVEL_GIFT_OK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_LEVEL_GIFT_OK
    self:init(0, nil)
end)

-- [1375]请求领取体力 -- 角色 
REQ_ROLE_BUFF_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_BUFF_REQUEST
    self:init(0, nil)
end)

-- [1380]属性加成请求 -- 角色 
REQ_ROLE_ATTR_ADD_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_ATTR_ADD_REQUEST
    self:init(0, nil)
end)

function REQ_ROLE_ATTR_ADD_REQUEST.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid}
end

function REQ_ROLE_ATTR_ADD_REQUEST.setArgs(self,uid)
    self.uid = uid  -- { 玩家uid}
end

-- [1395]请求是否有属性加成 -- 角色 
REQ_ROLE_ATTR_ADD_FLAG = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_ATTR_ADD_FLAG
    self:init(0, nil)
end)

-- [1400]玩家战斗对比请求 -- 角色 
REQ_ROLE_REQUEST_COMPARE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ROLE_REQUEST_COMPARE
    self:init(0, nil)
end)

function REQ_ROLE_REQUEST_COMPARE.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 对比玩家uid}
end

function REQ_ROLE_REQUEST_COMPARE.setArgs(self,uid)
    self.uid = uid  -- { 对比玩家uid}
end

-- [2010]请求装备,背包物品信息 -- 物品/背包 
REQ_GOODS_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GOODS_REQUEST
    self:init(0, nil)
end)

function REQ_GOODS_REQUEST.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1:背包 3:临时背包}
    w:writeInt16Unsigned(self.sid)  -- { 服务器ID}
    w:writeInt32Unsigned(self.uid)  -- { 玩家UID(查看别人用到) 1345无效}
end

function REQ_GOODS_REQUEST.setArgs(self,type,sid,uid)
    self.type = type  -- { 1:背包 3:临时背包}
    self.sid = sid  -- { 服务器ID}
    self.uid = uid  -- { 玩家UID(查看别人用到) 1345无效}
end

-- [2080]物品/装备使用 -- 物品/背包 
REQ_GOODS_USE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GOODS_USE
    self:init(0, nil)
end)

function REQ_GOODS_USE.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1:背包(使,装) 2:人物装备(卸) 3:临时背包(取)}
    w:writeInt32Unsigned(self.target)  -- { 对象ID,0:自己|伙伴id}
    w:writeInt16Unsigned(self.from_index)  -- { 所在容器位置索引}
    w:writeInt16Unsigned(self.count)  -- { 使用数量}
end

function REQ_GOODS_USE.setArgs(self,type,target,from_index,count)
    self.type = type  -- { 1:背包(使,装) 2:人物装备(卸) 3:临时背包(取)}
    self.target = target  -- { 对象ID,0:自己|伙伴id}
    self.from_index = from_index  -- { 所在容器位置索引}
    self.count = count  -- { 使用数量}
end

-- [2090]使用物品(指定对象) -- 物品/背包 
REQ_GOODS_TARGET_USE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GOODS_TARGET_USE
    self:init(0, nil)
end)

function REQ_GOODS_TARGET_USE.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1:背包(使,装) 2:人物装备(卸) 3:临时背包(取)}
    w:writeInt32Unsigned(self.target)  -- { 物品位置对象ID,0:自己|伙伴id}
    w:writeInt16Unsigned(self.from_idx)  -- { 所在容器位置索引}
    w:writeInt16Unsigned(self.count)  -- { 使用数量}
    w:writeInt32Unsigned(self.object)  -- { 使用目标(0:主将|其他:武将ID)}
end

function REQ_GOODS_TARGET_USE.setArgs(self,type,target,from_idx,count,object)
    self.type = type  -- { 1:背包(使,装) 2:人物装备(卸) 3:临时背包(取)}
    self.target = target  -- { 物品位置对象ID,0:自己|伙伴id}
    self.from_idx = from_idx  -- { 所在容器位置索引}
    self.count = count  -- { 使用数量}
    self.object = object  -- { 使用目标(0:主将|其他:武将ID)}
end

-- [2095]使用物品（得话费） -- 物品/背包 
REQ_GOODS_HUAFEI_USE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GOODS_HUAFEI_USE
    self:init(0, nil)
end)

function REQ_GOODS_HUAFEI_USE.encode(self, w)
    w:writeInt16Unsigned(self.idx)  -- { 所在容器位置索引}
    w:writeString(self.num)  -- { 电话号码}
end

function REQ_GOODS_HUAFEI_USE.setArgs(self,idx,num)
    self.idx = idx  -- { 所在容器位置索引}
    self.num = num  -- { 电话号码}
end

-- [2098]使用改名卡 -- 物品/背包 
REQ_GOODS_CHANG_NAME = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GOODS_CHANG_NAME
    self:init(0, nil)
end)

function REQ_GOODS_CHANG_NAME.encode(self, w)
    w:writeInt16Unsigned(self.idx)  -- { 索引}
    w:writeString(self.uname)  -- { 新名字}
end

function REQ_GOODS_CHANG_NAME.setArgs(self,idx,uname)
    self.idx = idx  -- { 索引}
    self.uname = uname  -- { 新名字}
end

-- [2100]丢弃物品 -- 物品/背包 
REQ_GOODS_LOSE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GOODS_LOSE
    self:init(0, nil)
end)

function REQ_GOODS_LOSE.encode(self, w)
    w:writeInt16Unsigned(self.index)  -- { 物品在背包中的下标}
end

function REQ_GOODS_LOSE.setArgs(self,index)
    self.index = index  -- { 物品在背包中的下标}
end

-- [2225]请求容器扩充 -- 物品/背包 
REQ_GOODS_ENLARGE_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GOODS_ENLARGE_REQUEST
    self:init(0, nil)
end)

function REQ_GOODS_ENLARGE_REQUEST.encode(self, w)
    w:writeBoolean(self.arg)  -- { true:确认|false:询问消耗数量}
end

function REQ_GOODS_ENLARGE_REQUEST.setArgs(self,arg)
    self.arg = arg  -- { true:确认|false:询问消耗数量}
end

-- [2240]请求角色装备信息 -- 物品/背包 
REQ_GOODS_EQUIP_ASK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GOODS_EQUIP_ASK
    self:init(0, nil)
end)

function REQ_GOODS_EQUIP_ASK.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid}
    w:writeInt32Unsigned(self.partner)  -- { 主将:0|武将idx}
end

function REQ_GOODS_EQUIP_ASK.setArgs(self,uid,partner)
    self.uid = uid  -- { 玩家uid}
    self.partner = partner  -- { 主将:0|武将idx}
end

-- [2250]提取临时背包物品 -- 物品/背包 
REQ_GOODS_PICK_TEMP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GOODS_PICK_TEMP
    self:init(0, nil)
end)

function REQ_GOODS_PICK_TEMP.encode(self, w)
    w:writeInt16Unsigned(self.idx)  -- { 0:一键提取|物品idx}
end

function REQ_GOODS_PICK_TEMP.setArgs(self,idx)
    self.idx = idx  -- { 0:一键提取|物品idx}
end

-- [2260]出售物品 -- 物品/背包 
REQ_GOODS_SELL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GOODS_SELL
    self:init(0, nil)
end)

function REQ_GOODS_SELL.encode(self, w)
    w:writeInt16Unsigned(self.idx)  -- { 物品索引}
    w:writeInt16Unsigned(self.num)  -- { 物品数量}
end

function REQ_GOODS_SELL.setArgs(self,idx,num)
    self.idx = idx  -- { 物品索引}
    self.num = num  -- { 物品数量}
end

-- [2270]装备一键互换 -- 物品/背包 
REQ_GOODS_EQUIP_SWAP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GOODS_EQUIP_SWAP
    self:init(0, nil)
end)

function REQ_GOODS_EQUIP_SWAP.encode(self, w)
    w:writeInt32Unsigned(self.id1)  -- { 武将id1(主将为0)}
    w:writeInt32Unsigned(self.id2)  -- { 武将id2(主将为0)}
end

function REQ_GOODS_EQUIP_SWAP.setArgs(self,id1,id2)
    self.id1 = id1  -- { 武将id1(主将为0)}
    self.id2 = id2  -- { 武将id2(主将为0)}
end

-- [2280]请求购回 -- 物品/背包 
REQ_GOODS_BUY_BACK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GOODS_BUY_BACK
    self:init(0, nil)
end)

function REQ_GOODS_BUY_BACK.encode(self, w)
    w:writeInt16Unsigned(self.idx)  -- { 物品索引}
end

function REQ_GOODS_BUY_BACK.setArgs(self,idx)
    self.idx = idx  -- { 物品索引}
end

-- [2300]请求商店信息 -- 物品/背包 
REQ_GOODS_SHOP_ASK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GOODS_SHOP_ASK
    self:init(0, nil)
end)

function REQ_GOODS_SHOP_ASK.encode(self, w)
    w:writeInt32Unsigned(self.npc_id)  -- { npc_id}
end

function REQ_GOODS_SHOP_ASK.setArgs(self,npc_id)
    self.npc_id = npc_id  -- { npc_id}
end

-- [2320]购买商店物品 -- 物品/背包 
REQ_GOODS_SHOP_BUY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GOODS_SHOP_BUY
    self:init(0, nil)
end)

function REQ_GOODS_SHOP_BUY.encode(self, w)
    w:writeInt16Unsigned(self.npc_id)  -- { npc_id}
    w:writeInt32Unsigned(self.goods_id)  -- { 物品ID}
    w:writeInt16Unsigned(self.count)  -- { 购买数量}
end

function REQ_GOODS_SHOP_BUY.setArgs(self,npc_id,goods_id,count)
    self.npc_id = npc_id  -- { npc_id}
    self.goods_id = goods_id  -- { 物品ID}
    self.count = count  -- { 购买数量}
end

-- [2328]领取将要获得的物品 -- 物品/背包 
REQ_GOODS_LANTERN_GET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GOODS_LANTERN_GET
    self:init(0, nil)
end)

-- [2329]请求元宵活动数据 -- 物品/背包 
REQ_GOODS_LANTERN_ASK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GOODS_LANTERN_ASK
    self:init(0, nil)
end)

-- [2330]请求次数物品数据 -- 物品/背包 
REQ_GOODS_TIMES_GOODS_ASK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GOODS_TIMES_GOODS_ASK
    self:init(0, nil)
end)

-- [2336]检查特定活动物品是否可使用 -- 物品/背包 
REQ_GOODS_ACTY_USE_CHECK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GOODS_ACTY_USE_CHECK
    self:init(0, nil)
end)

function REQ_GOODS_ACTY_USE_CHECK.encode(self, w)
    w:writeInt32Unsigned(self.goods_id)  -- { 物品ID}
end

function REQ_GOODS_ACTY_USE_CHECK.setArgs(self,goods_id)
    self.goods_id = goods_id  -- { 物品ID}
end

-- [2510]装备首饰打造 -- 物品/打造/强化 
REQ_MAKE_EQUIP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_EQUIP
    self:init(0, nil)
end)

function REQ_MAKE_EQUIP.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1背包2装备栏}
    w:writeInt32Unsigned(self.id)  -- { 主将0|武将ID}
    w:writeInt16Unsigned(self.idx)  -- { 打造装备的idx}
    w:writeInt32Unsigned(self.gid)  -- { 希望打造的物品id}
end

function REQ_MAKE_EQUIP.setArgs(self,type,id,idx,gid)
    self.type = type  -- { 1背包2装备栏}
    self.id = id  -- { 主将0|武将ID}
    self.idx = idx  -- { 打造装备的idx}
    self.gid = gid  -- { 希望打造的物品id}
end

-- [2513]强化 -- 物品/打造/强化 
REQ_MAKE_KEY_STREN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_KEY_STREN
    self:init(0, nil)
end)

function REQ_MAKE_KEY_STREN.encode(self, w)
    w:writeInt8Unsigned(self.stren_type)  -- { 强化类型}
    w:writeInt8Unsigned(self.type)  -- { 1:背包2:装备栏}
    w:writeInt32Unsigned(self.id)  -- { 主将0|武将ID}
    w:writeInt16Unsigned(self.idx)  -- { 打造装备的idx}
    w:writeBoolean(self.discount)  -- { 是否打折扣}
    w:writeBoolean(self.dou)  -- { 是否双倍强化}
    w:writeInt8Unsigned(self.cost_type)  -- { 0:普通强化|1:金元强化}
end

function REQ_MAKE_KEY_STREN.setArgs(self,stren_type,type,id,idx,discount,dou,cost_type)
    self.stren_type = stren_type  -- { 强化类型}
    self.type = type  -- { 1:背包2:装备栏}
    self.id = id  -- { 主将0|武将ID}
    self.idx = idx  -- { 打造装备的idx}
    self.discount = discount  -- { 是否打折扣}
    self.dou = dou  -- { 是否双倍强化}
    self.cost_type = cost_type  -- { 0:普通强化|1:金元强化}
end

-- [2515]装备强化 -- 物品/打造/强化 
REQ_MAKE_STRENGTHEN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_STRENGTHEN
    self:init(0, nil)
end)

function REQ_MAKE_STRENGTHEN.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1:背包2:装备栏}
    w:writeInt32Unsigned(self.id)  -- { 主将0|武将ID}
    w:writeInt16Unsigned(self.idx)  -- { 打造装备的idx}
    w:writeBoolean(self.discount)  -- { 是否打折扣}
    w:writeBoolean(self.dou)  -- { 是否双倍强化}
    w:writeInt8Unsigned(self.cost_type)  -- { 0:普通强化|1:金元强化}
end

function REQ_MAKE_STRENGTHEN.setArgs(self,type,id,idx,discount,dou,cost_type)
    self.type = type  -- { 1:背包2:装备栏}
    self.id = id  -- { 主将0|武将ID}
    self.idx = idx  -- { 打造装备的idx}
    self.discount = discount  -- { 是否打折扣}
    self.dou = dou  -- { 是否双倍强化}
    self.cost_type = cost_type  -- { 0:普通强化|1:金元强化}
end

-- [2516]请求装备强化数据 -- 物品/打造/强化 
REQ_MAKE_STREN_DATA_ASK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_STREN_DATA_ASK
    self:init(0, nil)
end)

function REQ_MAKE_STREN_DATA_ASK.encode(self, w)
    w:writeInt8Unsigned(self.ref)  -- { 标识}
    w:writeInt16Unsigned(self.goods_id)  -- { 物品id}
    w:writeInt16Unsigned(self.stren_lv)  -- { 强化等级}
    w:writeInt8Unsigned(self.color)  -- { 颜色}
    w:writeInt8Unsigned(self.type)  -- { 物品大类}
    w:writeInt8Unsigned(self.type_sub)  -- { 物品子类}
    w:writeInt8Unsigned(self.equip_class)  -- { 等阶}
end

function REQ_MAKE_STREN_DATA_ASK.setArgs(self,ref,goods_id,stren_lv,color,type,type_sub,equip_class)
    self.ref = ref  -- { 标识}
    self.goods_id = goods_id  -- { 物品id}
    self.stren_lv = stren_lv  -- { 强化等级}
    self.color = color  -- { 颜色}
    self.type = type  -- { 物品大类}
    self.type_sub = type_sub  -- { 物品子类}
    self.equip_class = equip_class  -- { 等阶}
end

-- [2522]法宝升阶 -- 物品/打造/强化 
REQ_MAKE_MAGIC_UPGRADE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_MAGIC_UPGRADE
    self:init(0, nil)
end)

function REQ_MAKE_MAGIC_UPGRADE.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1:背包2:装备栏}
    w:writeInt32Unsigned(self.id)  -- { 主将0|武将ID}
    w:writeInt16Unsigned(self.idx)  -- { 物品索引}
end

function REQ_MAKE_MAGIC_UPGRADE.setArgs(self,type,id,idx)
    self.type = type  -- { 1:背包2:装备栏}
    self.id = id  -- { 主将0|武将ID}
    self.idx = idx  -- { 物品索引}
end

-- [2531]锁定属性位置 -- 物品/打造/强化 
REQ_MAKE_MSG_POS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_MSG_POS
    self:init(0, nil)
end)

function REQ_MAKE_MSG_POS.encode(self, w)
    w:writeInt8Unsigned(self.pos)  -- { 位置}
end

function REQ_MAKE_MSG_POS.setArgs(self,pos)
    self.pos = pos  -- { 位置}
end

-- [2540]是否保留洗练数据 -- 物品/打造/强化 
REQ_MAKE_WASH_SAVE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_WASH_SAVE
    self:init(0, nil)
end)

function REQ_MAKE_WASH_SAVE.encode(self, w)
    w:writeBoolean(self.save)  -- { true:保留|false:不保留}
    w:writeInt16Unsigned(self.idx)  -- { 属性索引|如是武器技发0}
end

function REQ_MAKE_WASH_SAVE.setArgs(self,save,idx)
    self.save = save  -- { true:保留|false:不保留}
    self.idx = idx  -- { 属性索引|如是武器技发0}
end

-- [2550]宝石合成 -- 物品/打造/强化 
REQ_MAKE_MAKE_COMPOSE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_MAKE_COMPOSE
    self:init(0, nil)
end)

function REQ_MAKE_MAKE_COMPOSE.encode(self, w)
    w:writeInt16Unsigned(self.goods_id)  -- { 目标物品id}
    w:writeInt16Unsigned(self.count)  -- { 需要合成的数量}
end

function REQ_MAKE_MAKE_COMPOSE.setArgs(self,goods_id,count)
    self.goods_id = goods_id  -- { 目标物品id}
    self.count = count  -- { 需要合成的数量}
end

-- [2560]宝石镶嵌 -- 物品/打造/强化 
REQ_MAKE_PEARL_INSET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_PEARL_INSET
    self:init(0, nil)
end)

function REQ_MAKE_PEARL_INSET.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1背包2装备栏}
    w:writeInt32Unsigned(self.id)  -- { 主将0|武将ID}
    w:writeInt16Unsigned(self.idx)  -- { 物品的idx}
    w:writeInt16Unsigned(self.pearl_type)  -- { 类型}
    w:writeInt8Unsigned(self.flag)  -- { 0为正常镶嵌:1为一键镶嵌}
end

function REQ_MAKE_PEARL_INSET.setArgs(self,type,id,idx,pearl_type,flag)
    self.type = type  -- { 1背包2装备栏}
    self.id = id  -- { 主将0|武将ID}
    self.idx = idx  -- { 物品的idx}
    self.pearl_type = pearl_type  -- { 类型}
    self.flag = flag  -- { 0为正常镶嵌:1为一键镶嵌}
end

-- [2570]拆除灵珠 -- 物品/打造/强化 
REQ_MAKE_PEARL_REMOVE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_PEARL_REMOVE
    self:init(0, nil)
end)

function REQ_MAKE_PEARL_REMOVE.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1背包2装备栏}
    w:writeInt32Unsigned(self.id)  -- { 主将0|武将ID}
    w:writeInt16Unsigned(self.idx)  -- { 物品的idx}
    w:writeInt32Unsigned(self.pearlid)  -- { 灵珠ID}
end

function REQ_MAKE_PEARL_REMOVE.setArgs(self,type,id,idx,pearlid)
    self.type = type  -- { 1背包2装备栏}
    self.id = id  -- { 主将0|武将ID}
    self.idx = idx  -- { 物品的idx}
    self.pearlid = pearlid  -- { 灵珠ID}
end

-- [2580]法宝拆分 -- 物品/打造/强化 
REQ_MAKE_MAGIC_PART = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_MAGIC_PART
    self:init(0, nil)
end)

function REQ_MAKE_MAGIC_PART.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1背包2装备栏}
    w:writeInt32Unsigned(self.id)  -- { 主将0|武将ID}
    w:writeInt16Unsigned(self.idx)  -- { idx}
end

function REQ_MAKE_MAGIC_PART.setArgs(self,type,id,idx)
    self.type = type  -- { 1背包2装备栏}
    self.id = id  -- { 主将0|武将ID}
    self.idx = idx  -- { idx}
end

-- [2590]装备附魔 -- 物品/打造/强化 
REQ_MAKE_ENCHANT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_ENCHANT
    self:init(0, nil)
end)

function REQ_MAKE_ENCHANT.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1背包2装备栏}
    w:writeInt32(self.id)  -- { 主将0|武将ID}
    w:writeInt16Unsigned(self.idx)  -- { 物品的idx}
end

function REQ_MAKE_ENCHANT.setArgs(self,type,id,idx)
    self.type = type  -- { 1背包2装备栏}
    self.id = id  -- { 主将0|武将ID}
    self.idx = idx  -- { 物品的idx}
end

-- [2610]请求附魔消耗 -- 物品/打造/强化 
REQ_MAKE_ENCHANT_S = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_ENCHANT_S
    self:init(0, nil)
end)

-- [2680]请求下一级升品数据 -- 物品/打造/强化 
REQ_MAKE_EQUIP_NEXT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_EQUIP_NEXT
    self:init(0, nil)
end)

function REQ_MAKE_EQUIP_NEXT.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1背包2装备栏}
    w:writeInt32Unsigned(self.id)  -- { 主将0|武将ID}
    w:writeInt16Unsigned(self.idx)  -- { 物品的idx}
end

function REQ_MAKE_EQUIP_NEXT.setArgs(self,type,id,idx)
    self.type = type  -- { 1背包2装备栏}
    self.id = id  -- { 主将0|武将ID}
    self.idx = idx  -- { 物品的idx}
end

-- [2700]装备升品 -- 物品/打造/强化 
REQ_MAKE_EQUIP_NEW = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_EQUIP_NEW
    self:init(0, nil)
end)

function REQ_MAKE_EQUIP_NEW.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1背包2装备栏}
    w:writeInt32Unsigned(self.id)  -- { 主将0|武将ID}
    w:writeInt16Unsigned(self.idx)  -- { 物品的idx}
    w:writeInt8Unsigned(self.road)  -- { 路线（单线or多线）}
end

function REQ_MAKE_EQUIP_NEW.setArgs(self,type,id,idx,road)
    self.type = type  -- { 1背包2装备栏}
    self.id = id  -- { 主将0|武将ID}
    self.idx = idx  -- { 物品的idx}
    self.road = road  -- { 路线（单线or多线）}
end

-- [2720]记录洗练锁定位置 -- 物品/打造/强化 
REQ_MAKE_LOCK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_LOCK
    self:init(0, nil)
end)

function REQ_MAKE_LOCK.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1背包2装备栏}
    w:writeInt32Unsigned(self.id)  -- { 主将0|武将ID}
    w:writeInt16Unsigned(self.idx)  -- { 物品的idx}
    w:writeInt8Unsigned(self.pos)  -- { 位置}
end

function REQ_MAKE_LOCK.setArgs(self,type,id,idx,pos)
    self.type = type  -- { 1背包2装备栏}
    self.id = id  -- { 主将0|武将ID}
    self.idx = idx  -- { 物品的idx}
    self.pos = pos  -- { 位置}
end

-- [2724]部位强化请求 -- 物品/打造/强化 
REQ_MAKE_PART_STREN_REQ = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_PART_STREN_REQ
    self:init(0, nil)
end)

function REQ_MAKE_PART_STREN_REQ.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 主将0|武将ID}
    w:writeInt16Unsigned(self.type_sub)  -- { 部位类型}
end

function REQ_MAKE_PART_STREN_REQ.setArgs(self,id,type_sub)
    self.id = id  -- { 主将0|武将ID}
    self.type_sub = type_sub  -- { 部位类型}
end

-- [2730]强化部位 -- 物品/打造/强化 
REQ_MAKE_PART_STREN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_PART_STREN
    self:init(0, nil)
end)

function REQ_MAKE_PART_STREN.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 主将0|武将ID}
    w:writeInt16Unsigned(self.type_sub)  -- { 部位类型}
    w:writeInt8Unsigned(self.type)  -- { 强化类型(1,一次;2,十次)}
end

function REQ_MAKE_PART_STREN.setArgs(self,id,type_sub,type)
    self.id = id  -- { 主将0|武将ID}
    self.type_sub = type_sub  -- { 部位类型}
    self.type = type  -- { 强化类型(1,一次;2,十次)}
end

-- [2734]请求所有部位 -- 物品/打造/强化 
REQ_MAKE_PART_ALL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_PART_ALL
    self:init(0, nil)
end)

function REQ_MAKE_PART_ALL.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 主将0|武将1}
end

function REQ_MAKE_PART_ALL.setArgs(self,id)
    self.id = id  -- { 主将0|武将1}
end

-- [2740]部位镶嵌宝石请求 -- 物品/打造/强化 
REQ_MAKE_PART_INSERT_REQ = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_PART_INSERT_REQ
    self:init(0, nil)
end)

function REQ_MAKE_PART_INSERT_REQ.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 主将0|武将1}
    w:writeInt16Unsigned(self.type_sub)  -- { 部位类型}
end

function REQ_MAKE_PART_INSERT_REQ.setArgs(self,id,type_sub)
    self.id = id  -- { 主将0|武将1}
    self.type_sub = type_sub  -- { 部位类型}
end

-- [2755]宝石镶嵌 -- 物品/打造/强化 
REQ_MAKE_PART_INSERT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_PART_INSERT
    self:init(0, nil)
end)

function REQ_MAKE_PART_INSERT.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 主将0|武将1}
    w:writeInt16Unsigned(self.type_sub)  -- { 部位类型}
    w:writeInt16Unsigned(self.goods_id)  -- { 镶嵌宝石id}
end

function REQ_MAKE_PART_INSERT.setArgs(self,id,type_sub,goods_id)
    self.id = id  -- { 主将0|武将1}
    self.type_sub = type_sub  -- { 部位类型}
    self.goods_id = goods_id  -- { 镶嵌宝石id}
end

-- [2760]部位宝石镶嵌升级 -- 物品/打造/强化 
REQ_MAKE_PART_INSERT_UP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_PART_INSERT_UP
    self:init(0, nil)
end)

function REQ_MAKE_PART_INSERT_UP.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 主将0|武将1}
    w:writeInt16Unsigned(self.type_sub)  -- { 部位类型}
    w:writeInt16Unsigned(self.pearl_type)  -- { 宝石类型}
    w:writeInt8Unsigned(self.flag)  -- { 1确认镶嵌}
end

function REQ_MAKE_PART_INSERT_UP.setArgs(self,id,type_sub,pearl_type,flag)
    self.id = id  -- { 主将0|武将1}
    self.type_sub = type_sub  -- { 部位类型}
    self.pearl_type = pearl_type  -- { 宝石类型}
    self.flag = flag  -- { 1确认镶嵌}
end

-- [2765]部位宝石拆卸 -- 物品/打造/强化 
REQ_MAKE_PART_GEM_REMOVE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_PART_GEM_REMOVE
    self:init(0, nil)
end)

function REQ_MAKE_PART_GEM_REMOVE.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 主将0|武将1}
    w:writeInt16Unsigned(self.type_sub)  -- { 部位类型}
    w:writeInt16Unsigned(self.goods_id)  -- { 宝石id}
end

function REQ_MAKE_PART_GEM_REMOVE.setArgs(self,id,type_sub,goods_id)
    self.id = id  -- { 主将0|武将1}
    self.type_sub = type_sub  -- { 部位类型}
    self.goods_id = goods_id  -- { 宝石id}
end

-- [2775]分解物品信息块 -- 物品/打造/强化 
REQ_MAKE_XXX_IDX = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_XXX_IDX
    self:init(0, nil)
end)

function REQ_MAKE_XXX_IDX.encode(self, w)
    w:writeInt16Unsigned(self.idx)  -- { 物品idx}
    w:writeInt16Unsigned(self.count)  -- { 数量}
end

function REQ_MAKE_XXX_IDX.setArgs(self,idx,count)
    self.idx = idx  -- { 物品idx}
    self.count = count  -- { 数量}
end

-- [2820]部位宝石一键镶嵌 -- 物品/打造/强化 
REQ_MAKE_PART_INSERT_ONE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_PART_INSERT_ONE
    self:init(0, nil)
end)

function REQ_MAKE_PART_INSERT_ONE.encode(self, w)
    w:writeInt8Unsigned(self.id)  -- { 主将0|武将1}
end

function REQ_MAKE_PART_INSERT_ONE.setArgs(self,id)
    self.id = id  -- { 主将0|武将1}
end

-- [2825]部位宝石一键拆卸 -- 物品/打造/强化 
REQ_MAKE_PART_REMOVE_ONE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAKE_PART_REMOVE_ONE
    self:init(0, nil)
end)

function REQ_MAKE_PART_REMOVE_ONE.encode(self, w)
    w:writeInt8Unsigned(self.id)  -- { 主将0|武将1}
end

function REQ_MAKE_PART_REMOVE_ONE.setArgs(self,id)
    self.id = id  -- { 主将0|武将1}
end

-- [3210]请求任务列表 -- 任务 
REQ_TASK_REQUEST_LIST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TASK_REQUEST_LIST
    self:init(0, nil)
end)

-- [3230]接受任务 -- 任务 
REQ_TASK_ACCEPT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TASK_ACCEPT
    self:init(0, nil)
end)

function REQ_TASK_ACCEPT.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 任务id}
end

function REQ_TASK_ACCEPT.setArgs(self,id)
    self.id = id  -- { 任务id}
end

-- [3240]放弃任务 -- 任务 
REQ_TASK_CANCEL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TASK_CANCEL
    self:init(0, nil)
end)

function REQ_TASK_CANCEL.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 任务id}
end

function REQ_TASK_CANCEL.setArgs(self,id)
    self.id = id  -- { 任务id}
end

-- [3250]提交任务 -- 任务 
REQ_TASK_SUBMIT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TASK_SUBMIT
    self:init(0, nil)
end)

function REQ_TASK_SUBMIT.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 任务id}
    w:writeInt32Unsigned(self.var)  -- { 提交数据（问答/选择类）}
end

function REQ_TASK_SUBMIT.setArgs(self,id,var)
    self.id = id  -- { 任务id}
    self.var = var  -- { 提交数据（问答/选择类）}
end

-- [3520]请求单个组队信息 -- 组队系统 
REQ_TEAM_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TEAM_REQUEST
    self:init(0, nil)
end)

function REQ_TEAM_REQUEST.encode(self, w)
    w:writeInt16Unsigned(self.copy_id)  -- { 副本ID}
end

function REQ_TEAM_REQUEST.setArgs(self,copy_id)
    self.copy_id = copy_id  -- { 副本ID}
end

-- [3540]快速加入 -- 组队系统 
REQ_TEAM_QUICK_JOIN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TEAM_QUICK_JOIN
    self:init(0, nil)
end)

function REQ_TEAM_QUICK_JOIN.encode(self, w)
    w:writeInt16Unsigned(self.copy_id)  -- { 副本ID}
end

function REQ_TEAM_QUICK_JOIN.setArgs(self,copy_id)
    self.copy_id = copy_id  -- { 副本ID}
end

-- [3570]创建队伍 -- 组队系统 
REQ_TEAM_CREAT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TEAM_CREAT
    self:init(0, nil)
end)

function REQ_TEAM_CREAT.encode(self, w)
    w:writeInt16Unsigned(self.copy_id)  -- { 副本id}
end

function REQ_TEAM_CREAT.setArgs(self,copy_id)
    self.copy_id = copy_id  -- { 副本id}
end

-- [3600]加入队伍 -- 组队系统 
REQ_TEAM_JOIN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TEAM_JOIN
    self:init(0, nil)
end)

function REQ_TEAM_JOIN.encode(self, w)
    w:writeInt32Unsigned(self.team_id)  -- { 队伍ID}
end

function REQ_TEAM_JOIN.setArgs(self,team_id)
    self.team_id = team_id  -- { 队伍ID}
end

-- [3610]离开队伍 -- 组队系统 
REQ_TEAM_LEAVE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TEAM_LEAVE
    self:init(0, nil)
end)

-- [3630]踢出队员 -- 组队系统 
REQ_TEAM_KICK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TEAM_KICK
    self:init(0, nil)
end)

function REQ_TEAM_KICK.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 队员Uid}
end

function REQ_TEAM_KICK.setArgs(self,uid)
    self.uid = uid  -- { 队员Uid}
end

-- [3640]设置新队长 -- 组队系统 
REQ_TEAM_SET_LEADER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TEAM_SET_LEADER
    self:init(0, nil)
end)

function REQ_TEAM_SET_LEADER.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 成员Uid}
end

function REQ_TEAM_SET_LEADER.setArgs(self,uid)
    self.uid = uid  -- { 成员Uid}
end

-- [3650]申请做队长 -- 组队系统 
REQ_TEAM_APPLY_LEADER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TEAM_APPLY_LEADER
    self:init(0, nil)
end)

-- [3680]邀请好友组队 -- 组队系统 
REQ_TEAM_INVITE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TEAM_INVITE
    self:init(0, nil)
end)

function REQ_TEAM_INVITE.encode(self, w)
    w:writeInt32Unsigned(self.invite_uid)  -- { 邀请好友的uid}
    w:writeInt8Unsigned(self.invite_type)  -- { 好友类型}
end

function REQ_TEAM_INVITE.setArgs(self,invite_uid,invite_type)
    self.invite_uid = invite_uid  -- { 邀请好友的uid}
    self.invite_type = invite_type  -- { 好友类型}
end

-- [3720]查询队伍是否存在 -- 组队系统 
REQ_TEAM_LIVE_REQ = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TEAM_LIVE_REQ
    self:init(0, nil)
end)

function REQ_TEAM_LIVE_REQ.encode(self, w)
    w:writeInt32Unsigned(self.team_id)  -- { 队伍id}
    w:writeInt8Unsigned(self.type)  -- { 类型}
end

function REQ_TEAM_LIVE_REQ.setArgs(self,team_id,type)
    self.team_id = team_id  -- { 队伍id}
    self.type = type  -- { 类型}
end

-- [3780]设置状态 -- 组队系统 
REQ_TEAM_READY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TEAM_READY
    self:init(0, nil)
end)

-- [3790]购买次数 -- 组队系统 
REQ_TEAM_BUY_TIMES = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TEAM_BUY_TIMES
    self:init(0, nil)
end)

-- [3810]获取邀请玩家列表 -- 组队系统 
REQ_TEAM_INVITE_LIST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TEAM_INVITE_LIST
    self:init(0, nil)
end)

function REQ_TEAM_INVITE_LIST.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型(1附近的人，2好友，3)帮派成员}
    w:writeInt16Unsigned(self.lv)  -- { 玩家需要等级}
end

function REQ_TEAM_INVITE_LIST.setArgs(self,type,lv)
    self.type = type  -- { 类型(1附近的人，2好友，3)帮派成员}
    self.lv = lv  -- { 玩家需要等级}
end

-- [3840]是否允许组队 -- 组队系统 
REQ_TEAM_INVITE_STATE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TEAM_INVITE_STATE
    self:init(0, nil)
end)

function REQ_TEAM_INVITE_STATE.encode(self, w)
    w:writeInt8Unsigned(self.state)  -- { 是否允许（1/0）}
end

function REQ_TEAM_INVITE_STATE.setArgs(self,state)
    self.state = state  -- { 是否允许（1/0）}
end

-- [4010]根据请求类型 请求好友||最近联系人||黑名单面板 -- 好友 
REQ_FRIEND_REQUES = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FRIEND_REQUES
    self:init(0, nil)
end)

function REQ_FRIEND_REQUES.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型1好友面板 2最近联系人 4领取祝福面板 5黑名单}
end

function REQ_FRIEND_REQUES.setArgs(self,type)
    self.type = type  -- { 类型1好友面板 2最近联系人 4领取祝福面板 5黑名单}
end

-- [4030]删除好友 -- 好友 
REQ_FRIEND_DEL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FRIEND_DEL
    self:init(0, nil)
end)

function REQ_FRIEND_DEL.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 人物uid}
    w:writeInt8Unsigned(self.type)  -- { 类型(1 好友，5 黑名，2 最近联系)}
end

function REQ_FRIEND_DEL.setArgs(self,uid,type)
    self.uid = uid  -- { 人物uid}
    self.type = type  -- { 类型(1 好友，5 黑名，2 最近联系)}
end

-- [4050]按名称搜索玩家 -- 好友 
REQ_FRIEND_SEARCH_ADD = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FRIEND_SEARCH_ADD
    self:init(0, nil)
end)

function REQ_FRIEND_SEARCH_ADD.encode(self, w)
    w:writeString(self.name)  -- { 名字}
end

function REQ_FRIEND_SEARCH_ADD.setArgs(self,name)
    self.name = name  -- { 名字}
end

-- [4075]人物信息块 -- 好友 
REQ_FRIEND_MSG_ROLE_XXX = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FRIEND_MSG_ROLE_XXX
    self:init(0, nil)
end)

function REQ_FRIEND_MSG_ROLE_XXX.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 人物uid}
end

function REQ_FRIEND_MSG_ROLE_XXX.setArgs(self,uid)
    self.uid = uid  -- { 人物uid}
end

-- [4100]推荐好友 -- 好友 
REQ_FRIEND_GET_FRIEND = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FRIEND_GET_FRIEND
    self:init(0, nil)
end)

-- [4210]祝福好友 -- 好友 
REQ_FRIEND_BLESS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FRIEND_BLESS
    self:init(0, nil)
end)

function REQ_FRIEND_BLESS.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 好友Uid}
end

function REQ_FRIEND_BLESS.setArgs(self,uid)
    self.uid = uid  -- { 好友Uid}
end

-- [4220]一键祝福所有好友 -- 好友 
REQ_FRIEND_BLESS_ALL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FRIEND_BLESS_ALL
    self:init(0, nil)
end)

-- [4230]领取好友祝福 -- 好友 
REQ_FRIEND_BLESS_GET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FRIEND_BLESS_GET
    self:init(0, nil)
end)

function REQ_FRIEND_BLESS_GET.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家UID}
end

function REQ_FRIEND_BLESS_GET.setArgs(self,uid)
    self.uid = uid  -- { 玩家UID}
end

-- [4240]一键领取所有好友祝福 -- 好友 
REQ_FRIEND_BLESS_GET_ALL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FRIEND_BLESS_GET_ALL
    self:init(0, nil)
end)

-- [4255]可祝福别人次数 -- 好友 
REQ_FRIEND_BLESS_OTHER_TIME = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FRIEND_BLESS_OTHER_TIME
    self:init(0, nil)
end)

-- [4270]好友(附近的人)邀请 -- 好友 
REQ_FRIEND_INVITE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FRIEND_INVITE
    self:init(0, nil)
end)

function REQ_FRIEND_INVITE.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 好友类型(1好友6附近的人)}
    w:writeInt16Unsigned(self.lv)  -- { 等级Lv}
end

function REQ_FRIEND_INVITE.setArgs(self,type,lv)
    self.type = type  -- { 好友类型(1好友6附近的人)}
    self.lv = lv  -- { 等级Lv}
end

-- [4285]里面面板次数 -- 好友 
REQ_FRIEND_TIME_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FRIEND_TIME_REQUEST
    self:init(0, nil)
end)

-- [5010]请求进入场景(飞) -- 场景 
REQ_SCENE_ENTER_FLY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_ENTER_FLY
    self:init(0, nil)
end)

function REQ_SCENE_ENTER_FLY.encode(self, w)
    w:writeInt32Unsigned(self.map_id)  -- { 目的场景地图ID}
end

function REQ_SCENE_ENTER_FLY.setArgs(self,map_id)
    self.map_id = map_id  -- { 目的场景地图ID}
end

-- [5020]请求进入场景 -- 场景 
REQ_SCENE_ENTER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_ENTER
    self:init(0, nil)
end)

function REQ_SCENE_ENTER.encode(self, w)
    w:writeInt32Unsigned(self.door_id)  -- { 即将进入的传送点Id(登录为0)}
end

function REQ_SCENE_ENTER.setArgs(self,door_id)
    self.door_id = door_id  -- { 即将进入的传送点Id(登录为0)}
end

-- [5040]行走数据 -- 场景 
REQ_SCENE_REQUEST_PLAYERS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_REQUEST_PLAYERS
    self:init(0, nil)
end)

-- [5042]请求场景玩家列表(NEW) -- 场景 
REQ_SCENE_REQ_PLAYERS_NEW = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_REQ_PLAYERS_NEW
    self:init(0, nil)
end)

-- [5060]请求场景怪物数据 -- 场景 
REQ_SCENE_REQUEST_MONSTER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_REQUEST_MONSTER
    self:init(0, nil)
end)

-- [5080]行走数据(要广播也要记录位置) -- 场景 
REQ_SCENE_MOVE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_MOVE
    self:init(0, nil)
end)

function REQ_SCENE_MOVE.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型（1玩家，2伙伴）}
    w:writeInt32Unsigned(self.move_uid)  -- { 玩家UID}
    w:writeInt8Unsigned(self.move_type)  -- { 移动类型}
    w:writeInt16Unsigned(self.pos_x)  -- { X坐标}
    w:writeInt16Unsigned(self.pos_y)  -- { Y坐标}
    w:writeInt8Unsigned(self.dir)  -- { 移动方向}
end

function REQ_SCENE_MOVE.setArgs(self,type,move_uid,move_type,pos_x,pos_y,dir)
    self.type = type  -- { 类型（1玩家，2伙伴）}
    self.move_uid = move_uid  -- { 玩家UID}
    self.move_type = move_type  -- { 移动类型}
    self.pos_x = pos_x  -- { X坐标}
    self.pos_y = pos_y  -- { Y坐标}
    self.dir = dir  -- { 移动方向}
end

-- [5085]行走数据(要广播,后端不记录位置         这条现在不管) -- 场景 
REQ_SCENE_MOVE_NEW = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_MOVE_NEW
    self:init(0, nil)
end)

function REQ_SCENE_MOVE_NEW.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型 玩家/怪物/宠物}
    w:writeInt32Unsigned(self.move_uid)  -- { 玩家uid/怪物/宠物monster_mid 生成ID}
    w:writeInt8Unsigned(self.move_type)  -- { 移动类型}
    w:writeInt16Unsigned(self.pos_x)  -- { X坐标}
    w:writeInt16Unsigned(self.pos_y)  -- { Y坐标}
end

function REQ_SCENE_MOVE_NEW.setArgs(self,type,move_uid,move_type,pos_x,pos_y)
    self.type = type  -- { 类型 玩家/怪物/宠物}
    self.move_uid = move_uid  -- { 玩家uid/怪物/宠物monster_mid 生成ID}
    self.move_type = move_type  -- { 移动类型}
    self.pos_x = pos_x  -- { X坐标}
    self.pos_y = pos_y  -- { Y坐标}
end

-- [5120]杀怪连击次数 -- 场景 
REQ_SCENE_CAROM_TIMES = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_CAROM_TIMES
    self:init(0, nil)
end)

function REQ_SCENE_CAROM_TIMES.encode(self, w)
    w:writeInt16Unsigned(self.times)  -- { 次数}
end

function REQ_SCENE_CAROM_TIMES.setArgs(self,times)
    self.times = times  -- { 次数}
end

-- [5130]击杀怪物 -- 场景 
REQ_SCENE_KILL_MONSTER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_KILL_MONSTER
    self:init(0, nil)
end)

function REQ_SCENE_KILL_MONSTER.encode(self, w)
    w:writeInt32Unsigned(self.mons_mid)  -- { 怪物ID}
end

function REQ_SCENE_KILL_MONSTER.setArgs(self,mons_mid)
    self.mons_mid = mons_mid  -- { 怪物ID}
end

-- [5140]被怪物击中 -- 场景 
REQ_SCENE_HIT_TIMES = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_HIT_TIMES
    self:init(0, nil)
end)

function REQ_SCENE_HIT_TIMES.encode(self, w)
    w:writeInt16(self.times)  -- { 被怪物击中次数}
end

function REQ_SCENE_HIT_TIMES.setArgs(self,times)
    self.times = times  -- { 被怪物击中次数}
end

-- [5150]玩家死亡 -- 场景 
REQ_SCENE_DIE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_DIE
    self:init(0, nil)
end)

-- [5155]伙伴死亡 -- 场景 
REQ_SCENE_DIE_PARTNER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_DIE_PARTNER
    self:init(0, nil)
end)

function REQ_SCENE_DIE_PARTNER.encode(self, w)
    w:writeInt32(self.partner_id)  -- { 伙伴id}
end

function REQ_SCENE_DIE_PARTNER.setArgs(self,partner_id)
    self.partner_id = partner_id  -- { 伙伴id}
end

-- [5170]玩家请求复活 -- 场景 
REQ_SCENE_RELIVE_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_RELIVE_REQUEST
    self:init(0, nil)
end)

-- [5200]退出场景 -- 场景 
REQ_SCENE_ENTER_CITY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_ENTER_CITY
    self:init(0, nil)
end)

-- [5300]请求物品掉落 -- 场景 
REQ_SCENE_GOODS_ASK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_GOODS_ASK
    self:init(0, nil)
end)

function REQ_SCENE_GOODS_ASK.encode(self, w)
    w:writeInt32Unsigned(self.monster_id)  -- { 怪物ID}
    w:writeInt16Unsigned(self.pos_x)  -- { X坐标}
    w:writeInt16Unsigned(self.pos_y)  -- { Y坐标}
end

function REQ_SCENE_GOODS_ASK.setArgs(self,monster_id,pos_x,pos_y)
    self.monster_id = monster_id  -- { 怪物ID}
    self.pos_x = pos_x  -- { X坐标}
    self.pos_y = pos_y  -- { Y坐标}
end

-- [5305]捡掉落物品 -- 场景 
REQ_SCENE_GET_GOODS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_GET_GOODS
    self:init(0, nil)
end)

function REQ_SCENE_GET_GOODS.encode(self, w)
    w:writeInt16Unsigned(self.goods_id)  -- { 物品ID}
    w:writeInt16Unsigned(self.count)  -- { 物品数量}
end

function REQ_SCENE_GET_GOODS.setArgs(self,goods_id,count)
    self.goods_id = goods_id  -- { 物品ID}
    self.count = count  -- { 物品数量}
end

-- [5320]箱子请求物品掉落 -- 场景 
REQ_SCENE_BOX_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_BOX_REQUEST
    self:init(0, nil)
end)

function REQ_SCENE_BOX_REQUEST.encode(self, w)
    w:writeInt16Unsigned(self.box_id)  -- { 箱子id}
    w:writeInt16Unsigned(self.pos_x)  -- { X坐标}
    w:writeInt16Unsigned(self.pos_y)  -- { Y坐标}
end

function REQ_SCENE_BOX_REQUEST.setArgs(self,box_id,pos_x,pos_y)
    self.box_id = box_id  -- { 箱子id}
    self.pos_x = pos_x  -- { X坐标}
    self.pos_y = pos_y  -- { Y坐标}
end

-- [5370]设置战斗状态 -- 场景 
REQ_SCENE_WAR_STATE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_WAR_STATE
    self:init(0, nil)
end)

function REQ_SCENE_WAR_STATE.encode(self, w)
    w:writeInt8Unsigned(self.state)  -- { 1自动战斗，2手动}
end

function REQ_SCENE_WAR_STATE.setArgs(self,state)
    self.state = state  -- { 1自动战斗，2手动}
end

-- [5400]场景加载完成 -- 场景 
REQ_SCENE_LOAD_READY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_LOAD_READY
    self:init(0, nil)
end)

-- [5500]请求屏蔽其他玩家 -- 场景 
REQ_SCENE_SCREEN_OTHER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_SCREEN_OTHER
    self:init(0, nil)
end)

-- [5550]取消屏蔽其他玩家信息 -- 场景 
REQ_SCENE_CANCLE_SCREEN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SCENE_CANCLE_SCREEN
    self:init(0, nil)
end)

-- [6021]战斗伤害广播new -- 战斗 
REQ_WAR_HARM_NEW = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WAR_HARM_NEW
    self:init(0, nil)
end)

function REQ_WAR_HARM_NEW.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 战斗类型 ?CONST_WAR_PARAS_1_}
    w:writeInt8Unsigned(self.a_type)  -- { 攻击方类型}
    w:writeInt32Unsigned(self.a_uid)  -- { 攻击对象唯一ID}
    w:writeInt32Unsigned(self.a_partner_id)  -- { 攻击对象ID}
    w:writeInt8Unsigned(self.v_type)  -- { 被攻击方类型}
    w:writeInt32Unsigned(self.v_uid)  -- { 被攻击方唯一ID 玩家为0|怪物唯一ID|伙伴为主人Uid}
    w:writeInt32Unsigned(self.v_partner_id)  -- { 被攻击方ID}
    w:writeInt16Unsigned(self.skill_id)  -- { 技能id}
    w:writeInt8Unsigned(self.skill_num)  -- { 第几技能段数}
    w:writeInt16Unsigned(self.skill_arg)  -- { 离体攻击技能参数(万分比)}
    w:writeInt8Unsigned(self.stata)  -- { 攻击状态见常量 ?CONST_WAR_DISPLAY_}
    w:writeInt32Unsigned(self.harm)  -- { 伤害}
end

function REQ_WAR_HARM_NEW.setArgs(self,type,a_type,a_uid,a_partner_id,v_type,v_uid,v_partner_id,skill_id,skill_num,skill_arg,stata,harm)
    self.type = type  -- { 战斗类型 ?CONST_WAR_PARAS_1_}
    self.a_type = a_type  -- { 攻击方类型}
    self.a_uid = a_uid  -- { 攻击对象唯一ID}
    self.a_partner_id = a_partner_id  -- { 攻击对象ID}
    self.v_type = v_type  -- { 被攻击方类型}
    self.v_uid = v_uid  -- { 被攻击方唯一ID 玩家为0|怪物唯一ID|伙伴为主人Uid}
    self.v_partner_id = v_partner_id  -- { 被攻击方ID}
    self.skill_id = skill_id  -- { 技能id}
    self.skill_num = skill_num  -- { 第几技能段数}
    self.skill_arg = skill_arg  -- { 离体攻击技能参数(万分比)}
    self.stata = stata  -- { 攻击状态见常量 ?CONST_WAR_DISPLAY_}
    self.harm = harm  -- { 伤害}
end

-- [6040]释放技能 -- 战斗 
REQ_WAR_USE_SKILL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WAR_USE_SKILL
    self:init(0, nil)
end)

function REQ_WAR_USE_SKILL.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 施放者类型}
    w:writeInt32Unsigned(self.id)  -- { 施放者唯一id 玩家为0|伙伴为主人Uid}
    w:writeInt16Unsigned(self.skill_id)  -- { 技能id}
    w:writeInt8Unsigned(self.dir)  -- { 技能释放方向(1向右，2向左)}
    w:writeInt16Unsigned(self.pos_x)  -- { 位置X}
    w:writeInt16Unsigned(self.pos_y)  -- { 位置Y}
end

function REQ_WAR_USE_SKILL.setArgs(self,type,id,skill_id,dir,pos_x,pos_y)
    self.type = type  -- { 施放者类型}
    self.id = id  -- { 施放者唯一id 玩家为0|伙伴为主人Uid}
    self.skill_id = skill_id  -- { 技能id}
    self.dir = dir  -- { 技能释放方向(1向右，2向左)}
    self.pos_x = pos_x  -- { 位置X}
    self.pos_y = pos_y  -- { 位置Y}
end

-- [6050]邀请PK -- 战斗 
REQ_WAR_PK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WAR_PK
    self:init(0, nil)
end)

function REQ_WAR_PK.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 被请求玩家Uid}
end

function REQ_WAR_PK.setArgs(self,uid)
    self.uid = uid  -- { 被请求玩家Uid}
end

-- [6055]取消邀请 -- 战斗 
REQ_WAR_PK_CANCEL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WAR_PK_CANCEL
    self:init(0, nil)
end)

-- [6070]切磋请求反馈 -- 战斗 
REQ_WAR_PK_REPLY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WAR_PK_REPLY
    self:init(0, nil)
end)

function REQ_WAR_PK_REPLY.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 请求者Uid}
    w:writeInt8Unsigned(self.rs)  -- { 1:同意  0:不同意}
end

function REQ_WAR_PK_REPLY.setArgs(self,uid,rs)
    self.uid = uid  -- { 请求者Uid}
    self.rs = rs  -- { 1:同意  0:不同意}
end

-- [6090]怪物击倒 -- 战斗 
REQ_WAR_DOWN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WAR_DOWN
    self:init(0, nil)
end)

function REQ_WAR_DOWN.encode(self, w)
    w:writeInt32Unsigned(self.monsterid)  -- { 怪物id}
    w:writeInt16Unsigned(self.monstermid)  -- { 怪物mid}
end

function REQ_WAR_DOWN.setArgs(self,monsterid,monstermid)
    self.monsterid = monsterid  -- { 怪物id}
    self.monstermid = monstermid  -- { 怪物mid}
end

-- [6100]请求更新血量 -- 战斗 
REQ_WAR_HP_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WAR_HP_REQUEST
    self:init(0, nil)
end)

-- [6125]技能信息块 -- 战斗 
REQ_WAR_MSG_SKILL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WAR_MSG_SKILL
    self:init(0, nil)
end)

function REQ_WAR_MSG_SKILL.encode(self, w)
    w:writeInt16Unsigned(self.skill_id)  -- { 技能ID}
    w:writeInt32Unsigned(self.agr1)  -- { 参数一}
    w:writeInt16Unsigned(self.agr2)  -- { 参数二}
end

function REQ_WAR_MSG_SKILL.setArgs(self,skill_id,agr1,agr2)
    self.skill_id = skill_id  -- { 技能ID}
    self.agr1 = agr1  -- { 参数一}
    self.agr2 = agr2  -- { 参数二}
end

-- [6130]技能持续伤害 -- 战斗 
REQ_WAR_SKILL_HARM = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WAR_SKILL_HARM
    self:init(0, nil)
end)

function REQ_WAR_SKILL_HARM.encode(self, w)
    w:writeInt16Unsigned(self.harm)  -- { 技能持续伤害值}
end

function REQ_WAR_SKILL_HARM.setArgs(self,harm)
    self.harm = harm  -- { 技能持续伤害值}
end

-- [6200]PVP时间同步(请求) -- 战斗 
REQ_WAR_PVP_TIME = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WAR_PVP_TIME
    self:init(0, nil)
end)

-- [6210]PVP玩家状态(上报) -- 战斗 
REQ_WAR_PVP_STATE_UPLOAD = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WAR_PVP_STATE_UPLOAD
    self:init(0, nil)
end)

function REQ_WAR_PVP_STATE_UPLOAD.encode(self, w)
    w:writeInt32Unsigned(self.time)  -- { 发送时间(毫秒)}
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid}
    w:writeInt16Unsigned(self.pos_x)  -- { 玩家位置x}
    w:writeInt16Unsigned(self.pos_y)  -- { 玩家位置y}
    w:writeInt16Unsigned(self.pos_z)  -- { 玩家位置z}
    w:writeInt8Unsigned(self.dir)  -- { 玩家方向}
    w:writeInt8Unsigned(self.state)  -- { 玩家状态}
end

function REQ_WAR_PVP_STATE_UPLOAD.setArgs(self,time,uid,pos_x,pos_y,pos_z,dir,state)
    self.time = time  -- { 发送时间(毫秒)}
    self.uid = uid  -- { 玩家uid}
    self.pos_x = pos_x  -- { 玩家位置x}
    self.pos_y = pos_y  -- { 玩家位置y}
    self.pos_z = pos_z  -- { 玩家位置z}
    self.dir = dir  -- { 玩家方向}
    self.state = state  -- { 玩家状态}
end

-- [6220]PVP使用技能(请求) -- 战斗 
REQ_WAR_PVP_USE_SKILL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WAR_PVP_USE_SKILL
    self:init(0, nil)
end)

function REQ_WAR_PVP_USE_SKILL.encode(self, w)
    w:writeInt32Unsigned(self.time)  -- { 发送时间(毫秒)}
    w:writeInt8Unsigned(self.type)  -- { 施放者类型}
    w:writeInt32Unsigned(self.id)  -- { 施放者唯一id 玩家为0|伙伴为主人Uid}
    w:writeInt16Unsigned(self.skill_id)  -- { 技能id}
    w:writeInt8Unsigned(self.dir)  -- { 技能释放方向(1向右，2向左)}
    w:writeInt16Unsigned(self.pos_x)  -- { 位置X}
    w:writeInt16Unsigned(self.pos_y)  -- { 位置Y}
end

function REQ_WAR_PVP_USE_SKILL.setArgs(self,time,type,id,skill_id,dir,pos_x,pos_y)
    self.time = time  -- { 发送时间(毫秒)}
    self.type = type  -- { 施放者类型}
    self.id = id  -- { 施放者唯一id 玩家为0|伙伴为主人Uid}
    self.skill_id = skill_id  -- { 技能id}
    self.dir = dir  -- { 技能释放方向(1向右，2向左)}
    self.pos_x = pos_x  -- { 位置X}
    self.pos_y = pos_y  -- { 位置Y}
end

-- [6230]PVP玩家状态信息(请求) -- 战斗 
REQ_WAR_PVP_STATE_REQ = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WAR_PVP_STATE_REQ
    self:init(0, nil)
end)

function REQ_WAR_PVP_STATE_REQ.encode(self, w)
    w:writeInt32Unsigned(self.time)  -- { 发送时间(毫秒)}
end

function REQ_WAR_PVP_STATE_REQ.setArgs(self,time)
    self.time = time  -- { 发送时间(毫秒)}
end

-- [6250]PVP发送行走数据 -- 战斗 
REQ_WAR_PVP_MOVE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WAR_PVP_MOVE
    self:init(0, nil)
end)

function REQ_WAR_PVP_MOVE.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid}
    w:writeInt8Unsigned(self.move_type)  -- { 行走类型}
    w:writeInt8Unsigned(self.dir)  -- { 方向}
    w:writeInt16Unsigned(self.sx)  -- { 初始位置x}
    w:writeInt16Unsigned(self.sy)  -- { 初始位置y}
    w:writeInt16Unsigned(self.ex)  -- { 目标位置x}
    w:writeInt16Unsigned(self.ey)  -- { 目标位置y}
end

function REQ_WAR_PVP_MOVE.setArgs(self,uid,move_type,dir,sx,sy,ex,ey)
    self.uid = uid  -- { 玩家uid}
    self.move_type = move_type  -- { 行走类型}
    self.dir = dir  -- { 方向}
    self.sx = sx  -- { 初始位置x}
    self.sy = sy  -- { 初始位置y}
    self.ex = ex  -- { 目标位置x}
    self.ey = ey  -- { 目标位置y}
end

-- [6255]PVP发送技能数据 -- 战斗 
REQ_WAR_PVP_SKILL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WAR_PVP_SKILL
    self:init(0, nil)
end)

function REQ_WAR_PVP_SKILL.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid}
    w:writeInt16Unsigned(self.skill_id)  -- { 技能id}
    w:writeInt8Unsigned(self.dir)  -- { 技能释放方向(1向右，2向左)}
    w:writeInt16Unsigned(self.pos_x)  -- { 位置X}
    w:writeInt16Unsigned(self.pos_y)  -- { 位置Y}
end

function REQ_WAR_PVP_SKILL.setArgs(self,uid,skill_id,dir,pos_x,pos_y)
    self.uid = uid  -- { 玩家uid}
    self.skill_id = skill_id  -- { 技能id}
    self.dir = dir  -- { 技能释放方向(1向右，2向左)}
    self.pos_x = pos_x  -- { 位置X}
    self.pos_y = pos_y  -- { 位置Y}
end

-- [6510]请求技能列表 -- 技能 
REQ_SKILL_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SKILL_REQUEST
    self:init(0, nil)
end)

-- [6525]升级技能 -- 技能 
REQ_SKILL_LEARN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SKILL_LEARN
    self:init(0, nil)
end)

function REQ_SKILL_LEARN.encode(self, w)
    w:writeInt16Unsigned(self.skill_id)  -- { 技能id}
    w:writeInt16Unsigned(self.lv)  -- { 当前技能等级}
end

function REQ_SKILL_LEARN.setArgs(self,skill_id,lv)
    self.skill_id = skill_id  -- { 技能id}
    self.lv = lv  -- { 当前技能等级}
end

-- [6540]装备技能 -- 技能 
REQ_SKILL_EQUIP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SKILL_EQUIP
    self:init(0, nil)
end)

function REQ_SKILL_EQUIP.encode(self, w)
    w:writeInt16Unsigned(self.equip_pos)  -- { 技能面板的位置(0为取消装备)}
    w:writeInt16Unsigned(self.skill_id)  -- { 技能id}
end

function REQ_SKILL_EQUIP.setArgs(self,equip_pos,skill_id)
    self.equip_pos = equip_pos  -- { 技能面板的位置(0为取消装备)}
    self.skill_id = skill_id  -- { 技能id}
end

-- [6550]请求伙伴技能列表 -- 技能 
REQ_SKILL_PARTNER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SKILL_PARTNER
    self:init(0, nil)
end)

function REQ_SKILL_PARTNER.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid}
    w:writeInt16Unsigned(self.parentid)  -- { 伙伴id}
end

function REQ_SKILL_PARTNER.setArgs(self,uid,parentid)
    self.uid = uid  -- { 玩家uid}
    self.parentid = parentid  -- { 伙伴id}
end

-- [6555]请求学习技能 -- 技能 
REQ_SKILL_UPPARENTLV = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SKILL_UPPARENTLV
    self:init(0, nil)
end)

function REQ_SKILL_UPPARENTLV.encode(self, w)
    w:writeInt16Unsigned(self.parentid)  -- { 伙伴id}
    w:writeInt16Unsigned(self.skill_id)  -- { 技能id}
    w:writeInt16Unsigned(self.lv)  -- { 当前技能等级}
end

function REQ_SKILL_UPPARENTLV.setArgs(self,parentid,skill_id,lv)
    self.parentid = parentid  -- { 伙伴id}
    self.skill_id = skill_id  -- { 技能id}
    self.lv = lv  -- { 当前技能等级}
end

-- [7005]请求所有通过副本 -- 副本 
REQ_COPY_REQUEST_ALL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_REQUEST_ALL
    self:init(0, nil)
end)

-- [7014]请求单个章节副本 -- 副本 
REQ_COPY_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_REQUEST
    self:init(0, nil)
end)

function REQ_COPY_REQUEST.encode(self, w)
    w:writeInt16Unsigned(self.chap_id)  -- { 章节ID}
end

function REQ_COPY_REQUEST.setArgs(self,chap_id)
    self.chap_id = chap_id  -- { 章节ID}
end

-- [7024]请求副本是否开启 -- 副本 
REQ_COPY_COPY_OPEN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_COPY_OPEN
    self:init(0, nil)
end)

function REQ_COPY_COPY_OPEN.encode(self, w)
    w:writeInt16Unsigned(self.copy_id)  -- { 副本ID}
end

function REQ_COPY_COPY_OPEN.setArgs(self,copy_id)
    self.copy_id = copy_id  -- { 副本ID}
end

-- [7028]请求一组副本 -- 副本 
REQ_COPY_REQUEST_COPY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_REQUEST_COPY
    self:init(0, nil)
end)

function REQ_COPY_REQUEST_COPY.encode(self, w)
    w:writeInt16Unsigned(self.copy_id)  -- { 副本ID}
end

function REQ_COPY_REQUEST_COPY.setArgs(self,copy_id)
    self.copy_id = copy_id  -- { 副本ID}
end

-- [7030]创建进入副本 -- 副本 
REQ_COPY_CREAT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_CREAT
    self:init(0, nil)
end)

function REQ_COPY_CREAT.encode(self, w)
    w:writeInt16Unsigned(self.copy_id)  -- { 副本ID}
end

function REQ_COPY_CREAT.setArgs(self,copy_id)
    self.copy_id = copy_id  -- { 副本ID}
end

-- [7040]副本计时 -- 副本 
REQ_COPY_TIMING = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_TIMING
    self:init(0, nil)
end)

function REQ_COPY_TIMING.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 开始或停止计时(详见CONST_COPY_*)}
end

function REQ_COPY_TIMING.setArgs(self,type)
    self.type = type  -- { 开始或停止计时(详见CONST_COPY_*)}
end

-- [7070]请求精英魔王已进入和全部次数 -- 副本 
REQ_COPY_IN_ALL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_IN_ALL
    self:init(0, nil)
end)

-- [7140]请求购买挑战次数 -- 副本 
REQ_COPY_BUY_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_BUY_REQUEST
    self:init(0, nil)
end)

function REQ_COPY_BUY_REQUEST.encode(self, w)
    w:writeInt16Unsigned(self.copy_id)  -- { 副本ID}
end

function REQ_COPY_BUY_REQUEST.setArgs(self,copy_id)
    self.copy_id = copy_id  -- { 副本ID}
end

-- [7795]通知副本完成 -- 副本 
REQ_COPY_NOTICE_OVER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_NOTICE_OVER
    self:init(0, nil)
end)

function REQ_COPY_NOTICE_OVER.encode(self, w)
    w:writeInt16Unsigned(self.count)  -- { 剩余存活人数}
    w:writeInt16Unsigned(self.hit_times)  -- { 最大连击数}
    w:writeInt32Unsigned(self.mons_hp)  -- { 怪物hp}
    w:writeInt16Unsigned(self.time)  -- { 副本通过时间}
    w:writeInt32Unsigned(self.scene_id)  -- { 场景ID}
end

function REQ_COPY_NOTICE_OVER.setArgs(self,count,hit_times,mons_hp,time,scene_id)
    self.count = count  -- { 剩余存活人数}
    self.hit_times = hit_times  -- { 最大连击数}
    self.mons_hp = mons_hp  -- { 怪物hp}
    self.time = time  -- { 副本通过时间}
    self.scene_id = scene_id  -- { 场景ID}
end

-- [7796](NEW)通知副本完成 -- 副本 
REQ_COPY_NEW_NOTICE_OVER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_NEW_NOTICE_OVER
    self:init(0, nil)
end)

function REQ_COPY_NEW_NOTICE_OVER.encode(self, w)
    w:writeInt16Unsigned(self.count)  -- { 剩余存活人数}
    w:writeInt16Unsigned(self.hit_times)  -- { 最大连击数}
    w:writeInt32Unsigned(self.mons_hp)  -- { 怪物hp}
    w:writeInt16Unsigned(self.time)  -- { 副本通过时间}
    w:writeString(self.key)  -- { 验证字符}
    w:writeInt32Unsigned(self.scene_id)  -- { 场景ID}
end

function REQ_COPY_NEW_NOTICE_OVER.setArgs(self,count,hit_times,mons_hp,time,key,scene_id)
    self.count = count  -- { 剩余存活人数}
    self.hit_times = hit_times  -- { 最大连击数}
    self.mons_hp = mons_hp  -- { 怪物hp}
    self.time = time  -- { 副本通过时间}
    self.key = key  -- { 验证字符}
    self.scene_id = scene_id  -- { 场景ID}
end

-- [7820]退出副本 -- 副本 
REQ_COPY_COPY_EXIT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_COPY_EXIT
    self:init(0, nil)
end)

-- [7840]开始挂机 -- 副本 
REQ_COPY_UP_START = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_UP_START
    self:init(0, nil)
end)

function REQ_COPY_UP_START.encode(self, w)
    w:writeInt16Unsigned(self.copy_id)  -- { 副本id}
    w:writeInt8Unsigned(self.use_all)  -- { 是否使用所有体力}
    w:writeInt16Unsigned(self.num)  -- { 挂机次数}
    w:writeInt8Unsigned(self.type)  -- { 1普通挂机2高级挂机}
end

function REQ_COPY_UP_START.setArgs(self,copy_id,use_all,num,type)
    self.copy_id = copy_id  -- { 副本id}
    self.use_all = use_all  -- { 是否使用所有体力}
    self.num = num  -- { 挂机次数}
    self.type = type  -- { 1普通挂机2高级挂机}
end

-- [7845]加速挂机 -- 副本 
REQ_COPY_UP_SPEED = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_UP_SPEED
    self:init(0, nil)
end)

-- [7848]挂机请求 -- 副本 
REQ_COPY_UP_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_UP_REQUEST
    self:init(0, nil)
end)

-- [7864]登陆请求是否挂机 -- 副本 
REQ_COPY_IS_UP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_IS_UP
    self:init(0, nil)
end)

-- [7870]停止挂机 -- 副本 
REQ_COPY_UP_STOP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_UP_STOP
    self:init(0, nil)
end)

-- [7875]请求领取挂机奖励 -- 副本 
REQ_COPY_UP_REWARD_GET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_UP_REWARD_GET
    self:init(0, nil)
end)

-- [7880]领取章节评价奖励 -- 副本 
REQ_COPY_CHAP_REWARD = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_CHAP_REWARD
    self:init(0, nil)
end)

function REQ_COPY_CHAP_REWARD.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型（1，普通；2，精英；3，魔王）}
    w:writeInt16Unsigned(self.chap_id)  -- { 章节ID}
    w:writeInt8Unsigned(self.star)  -- { 奖励对应星的数量}
end

function REQ_COPY_CHAP_REWARD.setArgs(self,type,chap_id,star)
    self.type = type  -- { 类型（1，普通；2，精英；3，魔王）}
    self.chap_id = chap_id  -- { 章节ID}
    self.star = star  -- { 奖励对应星的数量}
end

-- [7900]请求物品掉落 -- 副本 
REQ_COPY_GOODS_ASK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_GOODS_ASK
    self:init(0, nil)
end)

function REQ_COPY_GOODS_ASK.encode(self, w)
    w:writeInt32Unsigned(self.mons_mid)  -- { 怪物MID}
end

function REQ_COPY_GOODS_ASK.setArgs(self,mons_mid)
    self.mons_mid = mons_mid  -- { 怪物MID}
end

-- [7920]请求副本怪物数据 -- 副本 
REQ_COPY_REQUEST_MONSTER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_REQUEST_MONSTER
    self:init(0, nil)
end)

-- [7985]副本通关翻牌 -- 副本 
REQ_COPY_DRAW_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_DRAW_REQUEST
    self:init(0, nil)
end)

function REQ_COPY_DRAW_REQUEST.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1翻全部,0翻一张}
    w:writeInt8Unsigned(self.pos)  -- { 翻牌位置}
end

function REQ_COPY_DRAW_REQUEST.setArgs(self,type,pos)
    self.type = type  -- { 1翻全部,0翻一张}
    self.pos = pos  -- { 翻牌位置}
end

-- [7997]准备翻牌 -- 副本 
REQ_COPY_DRAW_READY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_DRAW_READY
    self:init(0, nil)
end)

function REQ_COPY_DRAW_READY.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 是否购买次数(0请求剩余购买次数1确定购买)}
end

function REQ_COPY_DRAW_READY.setArgs(self,type)
    self.type = type  -- { 是否购买次数(0请求剩余购买次数1确定购买)}
end

-- [8510]请求邮件列表 -- 邮件 
REQ_MAIL_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAIL_REQUEST
    self:init(0, nil)
end)

function REQ_MAIL_REQUEST.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 邮箱类型(收件箱:0|发件箱:1|保存箱:2)}
end

function REQ_MAIL_REQUEST.setArgs(self,type)
    self.type = type  -- { 邮箱类型(收件箱:0|发件箱:1|保存箱:2)}
end

-- [8530]请求发送邮件 -- 邮件 
REQ_MAIL_SEND = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAIL_SEND
    self:init(0, nil)
end)

function REQ_MAIL_SEND.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid(无则发0)}
    w:writeString(self.recv_name)  -- { 收件人姓名}
    w:writeString(self.title)  -- { 邮件标题}
    w:writeUTF(self.content)  -- { 邮件内容}
end

function REQ_MAIL_SEND.setArgs(self,uid,recv_name,title,content)
    self.uid = uid  -- { 玩家uid(无则发0)}
    self.recv_name = recv_name  -- { 收件人姓名}
    self.title = title  -- { 邮件标题}
    self.content = content  -- { 邮件内容}
end

-- [8540]请求读取邮件 -- 邮件 
REQ_MAIL_READ = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAIL_READ
    self:init(0, nil)
end)

function REQ_MAIL_READ.encode(self, w)
    w:writeInt32Unsigned(self.mail_id)  -- { 要读取的邮件id}
end

function REQ_MAIL_READ.setArgs(self,mail_id)
    self.mail_id = mail_id  -- { 要读取的邮件id}
end

-- [8590]登录日志检查(邮件、竞技场等) -- 邮件 
REQ_MAIL_LOGIN_CHECK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAIL_LOGIN_CHECK
    self:init(0, nil)
end)

-- [9513]物品信息块 -- 聊天 
REQ_CHAT_MSG_GOODS_XXX = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CHAT_MSG_GOODS_XXX
    self:init(0, nil)
end)

function REQ_CHAT_MSG_GOODS_XXX.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1背包2装备栏}
    w:writeInt32Unsigned(self.id)  -- { 主将0|武将ID}
    w:writeInt16Unsigned(self.idx)  -- { 物品的idx}
end

function REQ_CHAT_MSG_GOODS_XXX.setArgs(self,type,id,idx)
    self.type = type  -- { 1背包2装备栏}
    self.id = id  -- { 主将0|武将ID}
    self.idx = idx  -- { 物品的idx}
end

-- [9520]发送语音聊天 -- 聊天 
REQ_CHAT_SEND_YUYIN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CHAT_SEND_YUYIN
    self:init(0, nil)
end)

function REQ_CHAT_SEND_YUYIN.encode(self, w)
    w:writeInt8Unsigned(self.channel_id)  -- { 频道类型}
    w:writeInt8Unsigned(self.type)  -- { 类型(CONST_CHAT_TYPE_)}
    w:writeInt32Unsigned(self.uid)  -- { 对方UID}
    w:writeInt16Unsigned(self.time)  -- { 语音长度（单位秒）}
    w:writeString(self.url)  -- { 文件路径}
    w:writeString(self.word)  -- { 语音内容}
end

function REQ_CHAT_SEND_YUYIN.setArgs(self,channel_id,type,uid,time,url,word)
    self.channel_id = channel_id  -- { 频道类型}
    self.type = type  -- { 类型(CONST_CHAT_TYPE_)}
    self.uid = uid  -- { 对方UID}
    self.time = time  -- { 语音长度（单位秒）}
    self.url = url  -- { 文件路径}
    self.word = word  -- { 语音内容}
end

-- [9540]请求语音信息 -- 聊天 
REQ_CHAT_YUYIN_ASK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CHAT_YUYIN_ASK
    self:init(0, nil)
end)

function REQ_CHAT_YUYIN_ASK.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 语音Id}
end

function REQ_CHAT_YUYIN_ASK.setArgs(self,id)
    self.id = id  -- { 语音Id}
end

-- [9560]请求聊天历史记录 -- 聊天 
REQ_CHAT_HISTORY_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CHAT_HISTORY_REQUEST
    self:init(0, nil)
end)

-- [9600]GM命令 -- 聊天 
REQ_CHAT_GM = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CHAT_GM
    self:init(0, nil)
end)

function REQ_CHAT_GM.encode(self, w)
    w:writeString(self.command)  -- { 命令}
end

function REQ_CHAT_GM.setArgs(self,command)
    self.command = command  -- { 命令}
end

-- [10001]好友祝福 -- 祝福 
REQ_WISH_SENT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WISH_SENT
    self:init(0, nil)
end)

function REQ_WISH_SENT.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 用户id}
    w:writeInt16Unsigned(self.lv)  -- { 等级}
    w:writeInt8Unsigned(self.type)  -- { 祝福类型(0：真挚祝福，1：赠送卡片，2：赠送礼盒，3：赠送大礼包}
end

function REQ_WISH_SENT.setArgs(self,uid,lv,type)
    self.uid = uid  -- { 用户id}
    self.lv = lv  -- { 等级}
    self.type = type  -- { 祝福类型(0：真挚祝福，1：赠送卡片，2：赠送礼盒，3：赠送大礼包}
end

-- [10020]领取祝福经验 -- 祝福 
REQ_WISH_EXPERIENCE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WISH_EXPERIENCE
    self:init(0, nil)
end)

function REQ_WISH_EXPERIENCE.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { (1:一倍)(2:双倍)}
end

function REQ_WISH_EXPERIENCE.setArgs(self,type)
    self.type = type  -- { (1:一倍)(2:双倍)}
end

-- [10030]请求祝福经验信息 -- 祝福 
REQ_WISH_EXP_DATA = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WISH_EXP_DATA
    self:init(0, nil)
end)

-- [10050]双倍信息 -- 祝福 
REQ_WISH_DOUBLE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WISH_DOUBLE
    self:init(0, nil)
end)

-- [10710]请求称号列表 -- 称号 
REQ_TITLE_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TITLE_REQUEST
    self:init(0, nil)
end)

-- [10750]穿戴称号 -- 称号 
REQ_TITLE_DRESS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TITLE_DRESS
    self:init(0, nil)
end)

function REQ_TITLE_DRESS.encode(self, w)
    w:writeInt16Unsigned(self.tid)  -- { 称号ID}
end

function REQ_TITLE_DRESS.setArgs(self,tid)
    self.tid = tid  -- { 称号ID}
end

-- [10760]点击新激活的称号 -- 称号 
REQ_TITLE_NEW = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TITLE_NEW
    self:init(0, nil)
end)

function REQ_TITLE_NEW.encode(self, w)
    w:writeInt16Unsigned(self.tid)  -- { 称号ID}
end

function REQ_TITLE_NEW.setArgs(self,tid)
    self.tid = tid  -- { 称号ID}
end

-- [10810]请求城镇BOSS列表 -- 城镇BOSS 
REQ_CITY_BOSS_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CITY_BOSS_REQUEST
    self:init(0, nil)
end)

-- [10830]请求进入城镇BOSS -- 城镇BOSS 
REQ_CITY_BOSS_ENTER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CITY_BOSS_ENTER
    self:init(0, nil)
end)

function REQ_CITY_BOSS_ENTER.encode(self, w)
    w:writeInt32Unsigned(self.map_id)  -- { 城镇地图ID}
end

function REQ_CITY_BOSS_ENTER.setArgs(self,map_id)
    self.map_id = map_id  -- { 城镇地图ID}
end

-- [10850]BOSS信息请求 -- 城镇BOSS 
REQ_CITY_BOSS_DATA_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CITY_BOSS_DATA_REQUEST
    self:init(0, nil)
end)

function REQ_CITY_BOSS_DATA_REQUEST.encode(self, w)
    w:writeInt16Unsigned(self.boss_id)  -- { CityBossID}
end

function REQ_CITY_BOSS_DATA_REQUEST.setArgs(self,boss_id)
    self.boss_id = boss_id  -- { CityBossID}
end

-- [10910]激活真元 -- 真元 
REQ_WING_ACTIVATE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WING_ACTIVATE
    self:init(0, nil)
end)

function REQ_WING_ACTIVATE.encode(self, w)
    w:writeInt16Unsigned(self.wing_id)  -- { 真元id}
end

function REQ_WING_ACTIVATE.setArgs(self,wing_id)
    self.wing_id = wing_id  -- { 真元id}
end

-- [10930]请求真元 -- 真元 
REQ_WING_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WING_REQUEST
    self:init(0, nil)
end)

function REQ_WING_REQUEST.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid 0:自己}
end

function REQ_WING_REQUEST.setArgs(self,uid)
    self.uid = uid  -- { 玩家uid 0:自己}
end

-- [10960]真元强化 -- 真元 
REQ_WING_STRENGTHEN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WING_STRENGTHEN
    self:init(0, nil)
end)

function REQ_WING_STRENGTHEN.encode(self, w)
    w:writeInt16Unsigned(self.wing_id)  -- { 真元id}
    w:writeInt16Unsigned(self.count)  -- { 强化次数}
end

function REQ_WING_STRENGTHEN.setArgs(self,wing_id,count)
    self.wing_id = wing_id  -- { 真元id}
    self.count = count  -- { 强化次数}
end

-- [10980]真元佩戴|卸下 -- 真元 
REQ_WING_RIDE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WING_RIDE
    self:init(0, nil)
end)

function REQ_WING_RIDE.encode(self, w)
    w:writeInt16Unsigned(self.wing_id)  -- { 真元ID 0:卸下}
end

function REQ_WING_RIDE.setArgs(self,wing_id)
    self.wing_id = wing_id  -- { 真元ID 0:卸下}
end

-- [12110]骑乘|下骑 -- 坐骑 
REQ_MOUNT_RIDE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MOUNT_RIDE
    self:init(0, nil)
end)

function REQ_MOUNT_RIDE.encode(self, w)
    w:writeInt16Unsigned(self.mount_id)  -- { 坐骑ID 0:卸下}
end

function REQ_MOUNT_RIDE.setArgs(self,mount_id)
    self.mount_id = mount_id  -- { 坐骑ID 0:卸下}
end

-- [12130]坐骑系统请求 -- 坐骑 
REQ_MOUNT_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MOUNT_REQUEST
    self:init(0, nil)
end)

function REQ_MOUNT_REQUEST.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid 0:自己}
end

function REQ_MOUNT_REQUEST.setArgs(self,uid)
    self.uid = uid  -- { 玩家uid 0:自己}
end

-- [12145]坐骑培养 -- 坐骑 
REQ_MOUNT_UP_MOUNT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MOUNT_UP_MOUNT
    self:init(0, nil)
end)

function REQ_MOUNT_UP_MOUNT.encode(self, w)
    w:writeInt16Unsigned(self.mount_id)  -- { 要培养的坐骑ID}
end

function REQ_MOUNT_UP_MOUNT.setArgs(self,mount_id)
    self.mount_id = mount_id  -- { 要培养的坐骑ID}
end

-- [12160]激活坐骑 -- 坐骑 
REQ_MOUNT_ACTIVATE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MOUNT_ACTIVATE
    self:init(0, nil)
end)

function REQ_MOUNT_ACTIVATE.encode(self, w)
    w:writeInt16Unsigned(self.mount_id)  -- { 坐骑id}
end

function REQ_MOUNT_ACTIVATE.setArgs(self,mount_id)
    self.mount_id = mount_id  -- { 坐骑id}
end

-- [12210]请求界面 -- 封神榜 
REQ_EXPEDIT_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_EXPEDIT_REQUEST
    self:init(0, nil)
end)

-- [12240]开始匹配 -- 封神榜 
REQ_EXPEDIT_BEGIN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_EXPEDIT_BEGIN
    self:init(0, nil)
end)

-- [12245]开始战斗 -- 封神榜 
REQ_EXPEDIT_FIGHT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_EXPEDIT_FIGHT
    self:init(0, nil)
end)

function REQ_EXPEDIT_FIGHT.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 对手uid}
    w:writeString(self.key)  -- { 验证字符}
end

function REQ_EXPEDIT_FIGHT.setArgs(self,uid,key)
    self.uid = uid  -- { 对手uid}
    self.key = key  -- { 验证字符}
end

-- [12250]战斗结果 -- 封神榜 
REQ_EXPEDIT_FINISH = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_EXPEDIT_FINISH
    self:init(0, nil)
end)

function REQ_EXPEDIT_FINISH.encode(self, w)
    w:writeInt8Unsigned(self.result)  -- { 0失败.1成功}
    w:writeInt32Unsigned(self.uid)  -- { 对手uid}
    w:writeString(self.key)  -- { 验证字符}
end

function REQ_EXPEDIT_FINISH.setArgs(self,result,uid,key)
    self.result = result  -- { 0失败.1成功}
    self.uid = uid  -- { 对手uid}
    self.key = key  -- { 验证字符}
end

-- [12260]加次数 -- 封神榜 
REQ_EXPEDIT_MATCH_TIMES = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_EXPEDIT_MATCH_TIMES
    self:init(0, nil)
end)

-- [12270]开始匹配(new) -- 封神榜 
REQ_EXPEDIT_BEGIN_NEW = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_EXPEDIT_BEGIN_NEW
    self:init(0, nil)
end)

-- [14001]请求阵营信息 -- 阵营 
REQ_COUNTRY_INFO = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COUNTRY_INFO
    self:init(0, nil)
end)

-- [14010]选择阵营 -- 阵营 
REQ_COUNTRY_SELECT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COUNTRY_SELECT
    self:init(0, nil)
end)

function REQ_COUNTRY_SELECT.encode(self, w)
    w:writeInt8Unsigned(self.country_id)  -- { 阵营类型(见常量),随机则发0}
end

function REQ_COUNTRY_SELECT.setArgs(self,country_id)
    self.country_id = country_id  -- { 阵营类型(见常量),随机则发0}
end

-- [14020]改变阵营--前奏 -- 阵营 
REQ_COUNTRY_CHANGE_PRE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COUNTRY_CHANGE_PRE
    self:init(0, nil)
end)

function REQ_COUNTRY_CHANGE_PRE.encode(self, w)
    w:writeInt8Unsigned(self.country_id)  -- { 阵营类型(见常量)}
end

function REQ_COUNTRY_CHANGE_PRE.setArgs(self,country_id)
    self.country_id = country_id  -- { 阵营类型(见常量)}
end

-- [14025]改变阵营 -- 阵营 
REQ_COUNTRY_CHANGE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COUNTRY_CHANGE
    self:init(0, nil)
end)

function REQ_COUNTRY_CHANGE.encode(self, w)
    w:writeInt8Unsigned(self.country_id)  -- { 阵营类型(见常量)}
end

function REQ_COUNTRY_CHANGE.setArgs(self,country_id)
    self.country_id = country_id  -- { 阵营类型(见常量)}
end

-- [14030]阵营排名 -- 阵营 
REQ_COUNTRY_RANK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COUNTRY_RANK
    self:init(0, nil)
end)

function REQ_COUNTRY_RANK.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 阵营排名类型(见常量)}
end

function REQ_COUNTRY_RANK.setArgs(self,type)
    self.type = type  -- { 阵营排名类型(见常量)}
end

-- [14040]发布阵营公告 -- 阵营 
REQ_COUNTRY_PUBLISH_NOTICE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COUNTRY_PUBLISH_NOTICE
    self:init(0, nil)
end)

function REQ_COUNTRY_PUBLISH_NOTICE.encode(self, w)
    w:writeUTF(self.notice)  -- { 阵营公告文字}
end

function REQ_COUNTRY_PUBLISH_NOTICE.setArgs(self,notice)
    self.notice = notice  -- { 阵营公告文字}
end

-- [14050]任命官员 -- 阵营 
REQ_COUNTRY_POST_APPOINT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COUNTRY_POST_APPOINT
    self:init(0, nil)
end)

function REQ_COUNTRY_POST_APPOINT.encode(self, w)
    w:writeString(self.name)  -- { 玩家名字}
    w:writeInt8Unsigned(self.post)  -- { 职位类型(见常量)}
end

function REQ_COUNTRY_POST_APPOINT.setArgs(self,name,post)
    self.name = name  -- { 玩家名字}
    self.post = post  -- { 职位类型(见常量)}
end

-- [14060]罢免官员 -- 阵营 
REQ_COUNTRY_POST_RECALL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COUNTRY_POST_RECALL
    self:init(0, nil)
end)

function REQ_COUNTRY_POST_RECALL.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid}
    w:writeInt8Unsigned(self.post)  -- { 职位类型(见常量)}
end

function REQ_COUNTRY_POST_RECALL.setArgs(self,uid,post)
    self.uid = uid  -- { 玩家uid}
    self.post = post  -- { 职位类型(见常量)}
end

-- [14070]官员辞职 -- 阵营 
REQ_COUNTRY_POST_RESIGN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COUNTRY_POST_RESIGN
    self:init(0, nil)
end)

-- [16010]收集物品 -- 节日活动 
REQ_FESTIVAL_COLLECT_REQ = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FESTIVAL_COLLECT_REQ
    self:init(0, nil)
end)

-- [16020]收集物品领取(旧) -- 节日活动 
REQ_FESTIVAL_COLLECT_GET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FESTIVAL_COLLECT_GET
    self:init(0, nil)
end)

function REQ_FESTIVAL_COLLECT_GET.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 预备领取的id}
    w:writeInt8Unsigned(self.type)  -- { 页面}
end

function REQ_FESTIVAL_COLLECT_GET.setArgs(self,id,type)
    self.id = id  -- { 预备领取的id}
    self.type = type  -- { 页面}
end

-- [16030]使用礼包(旧) -- 节日活动 
REQ_FESTIVAL_PACKS_GET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FESTIVAL_PACKS_GET
    self:init(0, nil)
end)

function REQ_FESTIVAL_PACKS_GET.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 预备开启礼包id}
    w:writeInt8Unsigned(self.type)  -- { 页面}
end

function REQ_FESTIVAL_PACKS_GET.setArgs(self,id,type)
    self.id = id  -- { 预备开启礼包id}
    self.type = type  -- { 页面}
end

-- [16040]时间(旧) -- 节日活动 
REQ_FESTIVAL_TIME = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FESTIVAL_TIME
    self:init(0, nil)
end)

function REQ_FESTIVAL_TIME.encode(self, w)
    w:writeInt8Unsigned(self.req_type)  -- { 请求开启类型}
end

function REQ_FESTIVAL_TIME.setArgs(self,req_type)
    self.req_type = req_type  -- { 请求开启类型}
end

-- [16050]时间及活动返送(不用) -- 节日活动 
REQ_FESTIVAL_TIME_NEW = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FESTIVAL_TIME_NEW
    self:init(0, nil)
end)

-- [16060]收集物品奖励(新) -- 节日活动 
REQ_FESTIVAL_COLLECT_NEW = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FESTIVAL_COLLECT_NEW
    self:init(0, nil)
end)

function REQ_FESTIVAL_COLLECT_NEW.encode(self, w)
    w:writeInt16Unsigned(self.a_id)  -- { 活动ID}
    w:writeInt16Unsigned(self.id)  -- { 礼包id}
    w:writeInt8Unsigned(self.type)  -- { 页面}
end

function REQ_FESTIVAL_COLLECT_NEW.setArgs(self,a_id,id,type)
    self.a_id = a_id  -- { 活动ID}
    self.id = id  -- { 礼包id}
    self.type = type  -- { 页面}
end

-- [16070]购买礼包 -- 节日活动 
REQ_FESTIVAL_PACKS_NEW = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FESTIVAL_PACKS_NEW
    self:init(0, nil)
end)

function REQ_FESTIVAL_PACKS_NEW.encode(self, w)
    w:writeInt16Unsigned(self.a_id)  -- { 活动ID}
    w:writeInt16Unsigned(self.id)  -- { 开启礼包id}
    w:writeInt8Unsigned(self.type)  -- { 页面}
end

function REQ_FESTIVAL_PACKS_NEW.setArgs(self,a_id,id,type)
    self.a_id = a_id  -- { 活动ID}
    self.id = id  -- { 开启礼包id}
    self.type = type  -- { 页面}
end

-- [16110]开服七天 -- 开服七天 
REQ_OPEN_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_OPEN_REQUEST
    self:init(0, nil)
end)

function REQ_OPEN_REQUEST.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型 对应第几天}
end

function REQ_OPEN_REQUEST.setArgs(self,type)
    self.type = type  -- { 类型 对应第几天}
end

-- [16120]领取 -- 开服七天 
REQ_OPEN_GET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_OPEN_GET
    self:init(0, nil)
end)

function REQ_OPEN_GET.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 领取id}
    w:writeInt8Unsigned(self.day)  -- { 第几天}
end

function REQ_OPEN_GET.setArgs(self,id,day)
    self.id = id  -- { 领取id}
    self.day = day  -- { 第几天}
end

-- [16135]角标 -- 开服七天 
REQ_OPEN_ICON_TIME = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_OPEN_ICON_TIME
    self:init(0, nil)
end)

-- [16159]排行榜请求 -- 开服七天 
REQ_OPEN_RANK_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_OPEN_RANK_REQUEST
    self:init(0, nil)
end)

function REQ_OPEN_RANK_REQUEST.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 对应天数}
end

function REQ_OPEN_RANK_REQUEST.setArgs(self,type)
    self.type = type  -- { 对应天数}
end

-- [16170]开服第几天 -- 开服七天 
REQ_OPEN_DAY_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_OPEN_DAY_REQUEST
    self:init(0, nil)
end)

-- [16510]请求积分转盘 -- 积分转盘 
REQ_POINTS_WHEEL_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_POINTS_WHEEL_REQUEST
    self:init(0, nil)
end)

function REQ_POINTS_WHEEL_REQUEST.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型}
end

function REQ_POINTS_WHEEL_REQUEST.setArgs(self,type)
    self.type = type  -- { 类型}
end

-- [16540]开始充值转盘 -- 积分转盘 
REQ_POINTS_WHEEL_FULL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_POINTS_WHEEL_FULL
    self:init(0, nil)
end)

-- [16550]开始消费转盘 -- 积分转盘 
REQ_POINTS_WHEEL_USE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_POINTS_WHEEL_USE
    self:init(0, nil)
end)

-- [16610]请求练功界面 -- 练功系统 
REQ_PRACTICE_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_PRACTICE_REQUEST
    self:init(0, nil)
end)

-- [16620]领取练功经验 -- 练功系统 
REQ_PRACTICE_COLLECT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_PRACTICE_COLLECT
    self:init(0, nil)
end)

-- [16710]请求面板 -- 精彩活动 
REQ_ART_CONSUME = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ART_CONSUME
    self:init(0, nil)
end)

-- [16720]领取 -- 精彩活动 
REQ_ART_CONSUME_GET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ART_CONSUME_GET
    self:init(0, nil)
end)

function REQ_ART_CONSUME_GET.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 领取id}
    w:writeInt32Unsigned(self.id_sub)  -- { 阶段id_sub}
end

function REQ_ART_CONSUME_GET.setArgs(self,id,id_sub)
    self.id = id  -- { 领取id}
    self.id_sub = id_sub  -- { 阶段id_sub}
end

-- [16740]请求排行 -- 精彩活动 
REQ_ART_FULL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ART_FULL
    self:init(0, nil)
end)

-- [16760]角标 -- 精彩活动 
REQ_ART_ICON_TIME = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ART_ICON_TIME
    self:init(0, nil)
end)

-- [16771]领取奖励 -- 精彩活动 
REQ_ART_REWARD = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ART_REWARD
    self:init(0, nil)
end)

function REQ_ART_REWARD.encode(self, w)
    w:writeInt16Unsigned(self.type)  -- { 类型(621封测返利631充值返利)}
end

function REQ_ART_REWARD.setArgs(self,type)
    self.type = type  -- { 类型(621封测返利631充值返利)}
end

-- [16775]福泽天下请求面板 -- 精彩活动 
REQ_ART_FZTX_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ART_FZTX_REQUEST
    self:init(0, nil)
end)

-- [16790]领取福泽天下 -- 精彩活动 
REQ_ART_GET_FZTX = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ART_GET_FZTX
    self:init(0, nil)
end)

function REQ_ART_GET_FZTX.encode(self, w)
    w:writeInt32Unsigned(self.id_sub)  -- { 阶段Id}
    w:writeInt8Unsigned(self.viplv)  -- { Vip等级要求}
end

function REQ_ART_GET_FZTX.setArgs(self,id_sub,viplv)
    self.id_sub = id_sub  -- { 阶段Id}
    self.viplv = viplv  -- { Vip等级要求}
end

-- [16794]充值界面请求 -- 精彩活动 
REQ_ART_CHARG_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ART_CHARG_REQUEST
    self:init(0, nil)
end)

function REQ_ART_CHARG_REQUEST.encode(self, w)
    w:writeInt8Unsigned(self.versions)  -- { 版本（1或2）}
end

function REQ_ART_CHARG_REQUEST.setArgs(self,versions)
    self.versions = versions  -- { 版本（1或2）}
end

-- [16797]转盘活动物品 -- 精彩活动 
REQ_ART_ZHUANPAN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ART_ZHUANPAN
    self:init(0, nil)
end)

function REQ_ART_ZHUANPAN.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 活动id}
end

function REQ_ART_ZHUANPAN.setArgs(self,id)
    self.id = id  -- { 活动id}
end

-- [18010]请求界面 -- 降魔之路 
REQ_XMZL_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_XMZL_REQUEST
    self:init(0, nil)
end)

-- [18030]属性加点 -- 降魔之路 
REQ_XMZL_ATTR_POINT_ADD = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_XMZL_ATTR_POINT_ADD
    self:init(0, nil)
end)

function REQ_XMZL_ATTR_POINT_ADD.encode(self, w)
    w:writeInt16Unsigned(self.type)  -- { 属性类型}
end

function REQ_XMZL_ATTR_POINT_ADD.setArgs(self,type)
    self.type = type  -- { 属性类型}
end

-- [18040]出战星宿 -- 降魔之路 
REQ_XMZL_WING_CHEER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_XMZL_WING_CHEER
    self:init(0, nil)
end)

function REQ_XMZL_WING_CHEER.encode(self, w)
    w:writeInt16Unsigned(self.wing_id)  -- { 星宿出战}
end

function REQ_XMZL_WING_CHEER.setArgs(self,wing_id)
    self.wing_id = wing_id  -- { 星宿出战}
end

-- [18055]重置属性点 -- 降魔之路 
REQ_XMZL_ATTR_POINT_RESET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_XMZL_ATTR_POINT_RESET
    self:init(0, nil)
end)

-- [18110]请求荣誉列表 -- 荣誉 
REQ_HONOR_LIST_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_HONOR_LIST_REQUEST
    self:init(0, nil)
end)

function REQ_HONOR_LIST_REQUEST.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 0:荣誉总揽1:火影目标2:角色成长3:强者之路4:角色历练5:神宠神骑6:浴血沙场}
end

function REQ_HONOR_LIST_REQUEST.setArgs(self,type)
    self.type = type  -- { 0:荣誉总揽1:火影目标2:角色成长3:强者之路4:角色历练5:神宠神骑6:浴血沙场}
end

-- [18120]领取奖励 -- 荣誉 
REQ_HONOR_REWARD = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_HONOR_REWARD
    self:init(0, nil)
end)

function REQ_HONOR_REWARD.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1:火影目标2:角色成长3:强者之路4:角色历练5:神宠神骑6:浴血沙场}
    w:writeInt32Unsigned(self.id)  -- { 荣誉ID}
end

function REQ_HONOR_REWARD.setArgs(self,type,id)
    self.type = type  -- { 1:火影目标2:角色成长3:强者之路4:角色历练5:神宠神骑6:浴血沙场}
    self.id = id  -- { 荣誉ID}
end

-- [21110]请求参加怪物攻城 -- 活动-保卫经书 
REQ_DEFEND_BOOK_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DEFEND_BOOK_REQUEST
    self:init(0, nil)
end)

-- [21130]请求场景玩家数据 -- 活动-保卫经书 
REQ_DEFEND_BOOK_ASK_PLAYER_DATE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DEFEND_BOOK_ASK_PLAYER_DATE
    self:init(0, nil)
end)

-- [21190]请求选择战壕 -- 活动-保卫经书 
REQ_DEFEND_BOOK_ASK_TRENCH = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DEFEND_BOOK_ASK_TRENCH
    self:init(0, nil)
end)

function REQ_DEFEND_BOOK_ASK_TRENCH.encode(self, w)
    w:writeInt8Unsigned(self.num)  -- { 战壕编号：1-9}
end

function REQ_DEFEND_BOOK_ASK_TRENCH.setArgs(self,num)
    self.num = num  -- { 战壕编号：1-9}
end

-- [21210]开始战斗 -- 活动-保卫经书 
REQ_DEFEND_BOOK_START_WAR = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DEFEND_BOOK_START_WAR
    self:init(0, nil)
end)

function REQ_DEFEND_BOOK_START_WAR.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 战斗|采集|训服(类型见常量)}
    w:writeInt32Unsigned(self.monster_gmid)  -- { 怪物组生成ID}
    w:writeInt16Unsigned(self.monster_gid)  -- { 怪物组Id}
end

function REQ_DEFEND_BOOK_START_WAR.setArgs(self,type,monster_gmid,monster_gid)
    self.type = type  -- { 战斗|采集|训服(类型见常量)}
    self.monster_gmid = monster_gmid  -- { 怪物组生成ID}
    self.monster_gid = monster_gid  -- { 怪物组Id}
end

-- [21230]请求拾取击杀奖励 -- 活动-保卫经书 
REQ_DEFEND_BOOK_ASK_GET_REWARDS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DEFEND_BOOK_ASK_GET_REWARDS
    self:init(0, nil)
end)

function REQ_DEFEND_BOOK_ASK_GET_REWARDS.encode(self, w)
    w:writeInt32Unsigned(self.gmid)  -- { 被击杀的怪物生成Id}
end

function REQ_DEFEND_BOOK_ASK_GET_REWARDS.setArgs(self,gmid)
    self.gmid = gmid  -- { 被击杀的怪物生成Id}
end

-- [21240]复活 -- 活动-保卫经书 
REQ_DEFEND_BOOK_REVIVE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DEFEND_BOOK_REVIVE
    self:init(0, nil)
end)

function REQ_DEFEND_BOOK_REVIVE.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 复活类型 0普通|1金元}
end

function REQ_DEFEND_BOOK_REVIVE.setArgs(self,type)
    self.type = type  -- { 复活类型 0普通|1金元}
end

-- [21260]请求退出战斗 -- 活动-保卫经书 
REQ_DEFEND_BOOK_REQUEST_BACK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DEFEND_BOOK_REQUEST_BACK
    self:init(0, nil)
end)

-- [21280]请求领取增益 -- 活动-保卫经书 
REQ_DEFEND_BOOK_GAIN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DEFEND_BOOK_GAIN
    self:init(0, nil)
end)

-- [21300]请求更换战壕 -- 活动-保卫经书 
REQ_DEFEND_BOOK_CHANGE_TRENCH = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DEFEND_BOOK_CHANGE_TRENCH
    self:init(0, nil)
end)

function REQ_DEFEND_BOOK_CHANGE_TRENCH.encode(self, w)
    w:writeInt8Unsigned(self.trench_num)  -- { 新战壕编号}
end

function REQ_DEFEND_BOOK_CHANGE_TRENCH.setArgs(self,trench_num)
    self.trench_num = trench_num  -- { 新战壕编号}
end

-- [22110]请求浮屠静修界面 -- 浮屠静修 
REQ_FUTU_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FUTU_REQUEST
    self:init(0, nil)
end)

-- [22135]请求购买挑战次数 -- 浮屠静修 
REQ_FUTU_TIMES_BUY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FUTU_TIMES_BUY
    self:init(0, nil)
end)

-- [22145]请求查看战报 -- 浮屠静修 
REQ_FUTU_HISTORY_REQ = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FUTU_HISTORY_REQ
    self:init(0, nil)
end)

-- [22160]查看玩家 -- 浮屠静修 
REQ_FUTU_PLAYER_REQ = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FUTU_PLAYER_REQ
    self:init(0, nil)
end)

function REQ_FUTU_PLAYER_REQ.encode(self, w)
    w:writeInt8Unsigned(self.floor)  -- { 层数}
    w:writeInt8Unsigned(self.pos)  -- { 位置}
    w:writeInt32Unsigned(self.uid)  -- { 玩家ID}
end

function REQ_FUTU_PLAYER_REQ.setArgs(self,floor,pos,uid)
    self.floor = floor  -- { 层数}
    self.pos = pos  -- { 位置}
    self.uid = uid  -- { 玩家ID}
end

-- [22170]离开据点 -- 浮屠静修 
REQ_FUTU_OUT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FUTU_OUT
    self:init(0, nil)
end)

function REQ_FUTU_OUT.encode(self, w)
    w:writeInt8Unsigned(self.floor)  -- { 层数}
    w:writeInt8Unsigned(self.pos)  -- { 位置}
end

function REQ_FUTU_OUT.setArgs(self,floor,pos)
    self.floor = floor  -- { 层数}
    self.pos = pos  -- { 位置}
end

-- [22180]浮屠静修开始挑战 -- 浮屠静修 
REQ_FUTU_START = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FUTU_START
    self:init(0, nil)
end)

function REQ_FUTU_START.encode(self, w)
    w:writeInt8Unsigned(self.floor)  -- { 层数}
    w:writeInt8Unsigned(self.pos)  -- { 位置}
    w:writeInt8Unsigned(self.type)  -- { 类型（0直接占领，1挑战占领）}
end

function REQ_FUTU_START.setArgs(self,floor,pos,type)
    self.floor = floor  -- { 层数}
    self.pos = pos  -- { 位置}
    self.type = type  -- { 类型（0直接占领，1挑战占领）}
end

-- [22185]浮屠静修挑战结束 -- 浮屠静修 
REQ_FUTU_OVER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FUTU_OVER
    self:init(0, nil)
end)

function REQ_FUTU_OVER.encode(self, w)
    w:writeInt8Unsigned(self.result)  -- { 1成功/0失败}
end

function REQ_FUTU_OVER.setArgs(self,result)
    self.result = result  -- { 1成功/0失败}
end

-- [22198]查看说明，完成指引任务 -- 浮屠静修 
REQ_FUTU_TASK_FINISH = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FUTU_TASK_FINISH
    self:init(0, nil)
end)

-- [22210]每天消费界面 -- 每天消费 
REQ_COST_FACE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COST_FACE
    self:init(0, nil)
end)

-- [22220]领奖 -- 每天消费 
REQ_COST_GET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COST_GET
    self:init(0, nil)
end)

function REQ_COST_GET.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 预备领取id}
end

function REQ_COST_GET.setArgs(self,id)
    self.id = id  -- { 预备领取id}
end

-- [22310]打开板子 -- 节日转盘 
REQ_GALATURN_OPEN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GALATURN_OPEN
    self:init(0, nil)
end)

-- [22313]节日转盘面板 -- 节日转盘 
REQ_GALATURN_GALATURN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GALATURN_GALATURN
    self:init(0, nil)
end)

function REQ_GALATURN_GALATURN.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 活动Id}
    w:writeInt8Unsigned(self.bool)  -- { 0为发物品数据，1为不发}
end

function REQ_GALATURN_GALATURN.setArgs(self,id,bool)
    self.id = id  -- { 活动Id}
    self.bool = bool  -- { 0为发物品数据，1为不发}
end

-- [22320]抽奖 -- 节日转盘 
REQ_GALATURN_LOTTERY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GALATURN_LOTTERY
    self:init(0, nil)
end)

function REQ_GALATURN_LOTTERY.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 抽奖类型(1:1次,2:多次)}
    w:writeInt32Unsigned(self.id)  -- { 活动Id}
end

function REQ_GALATURN_LOTTERY.setArgs(self,type,id)
    self.type = type  -- { 抽奖类型(1:1次,2:多次)}
    self.id = id  -- { 活动Id}
end

-- [22330]排名 -- 节日转盘 
REQ_GALATURN_RANK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GALATURN_RANK
    self:init(0, nil)
end)

function REQ_GALATURN_RANK.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 活动Id}
end

function REQ_GALATURN_RANK.setArgs(self,id)
    self.id = id  -- { 活动Id}
end

-- [22340]积分奖励 -- 节日转盘 
REQ_GALATURN_POINT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GALATURN_POINT
    self:init(0, nil)
end)

-- [22350]积分领奖 -- 节日转盘 
REQ_GALATURN_POINT_GET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GALATURN_POINT_GET
    self:init(0, nil)
end)

function REQ_GALATURN_POINT_GET.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 唯一id}
end

function REQ_GALATURN_POINT_GET.setArgs(self,id)
    self.id = id  -- { 唯一id}
end

-- [22810]宠物请求 -- 宠物 
REQ_PET_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_PET_REQUEST
    self:init(0, nil)
end)

-- [22850]召唤式神 -- 宠物 
REQ_PET_CALL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_PET_CALL
    self:init(0, nil)
end)

function REQ_PET_CALL.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 式神id}
    w:writeInt16Unsigned(self.id2)  -- { 式神id}
end

function REQ_PET_CALL.setArgs(self,id,id2)
    self.id = id  -- { 式神id}
    self.id2 = id2  -- { 式神id}
end

-- [22870]宠物需消耗钻石数 -- 宠物 
REQ_PET_NEED_RMB = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_PET_NEED_RMB
    self:init(0, nil)
end)

function REQ_PET_NEED_RMB.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型}
end

function REQ_PET_NEED_RMB.setArgs(self,type)
    self.type = type  -- { 类型}
end

-- [22880]宠物修炼 -- 宠物 
REQ_PET_XIULIAN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_PET_XIULIAN
    self:init(0, nil)
end)

function REQ_PET_XIULIAN.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型}
end

function REQ_PET_XIULIAN.setArgs(self,type)
    self.type = type  -- { 类型}
end

-- [22900]宠物幻化 -- 宠物 
REQ_PET_HUANHUA = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_PET_HUANHUA
    self:init(0, nil)
end)

function REQ_PET_HUANHUA.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 式神id}
end

function REQ_PET_HUANHUA.setArgs(self,id)
    self.id = id  -- { 式神id}
end

-- [23000]请求幻化界面 -- 宠物 
REQ_PET_HUANHUA_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_PET_HUANHUA_REQUEST
    self:init(0, nil)
end)

-- [23110]请求地下皇陵 -- 活动-地下皇陵 
REQ_TOMB_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TOMB_REQUEST
    self:init(0, nil)
end)

function REQ_TOMB_REQUEST.encode(self, w)
    w:writeInt16Unsigned(self.times)  -- { 剩余挑战次数}
    w:writeInt16Unsigned(self.times_all)  -- { 总共挑战次数}
    w:writeInt16Unsigned(self.times2)  -- { 剩余挑战次数}
    w:writeInt16Unsigned(self.times_all2)  -- { 总共挑战次数}
end

function REQ_TOMB_REQUEST.setArgs(self,times,times_all,times2,times_all2)
    self.times = times  -- { 剩余挑战次数}
    self.times_all = times_all  -- { 总共挑战次数}
    self.times2 = times2  -- { 剩余挑战次数}
    self.times_all2 = times_all2  -- { 总共挑战次数}
end

-- [23120]开始探宝 -- 活动-地下皇陵 
REQ_TOMB_DIG = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TOMB_DIG
    self:init(0, nil)
end)

function REQ_TOMB_DIG.encode(self, w)
    w:writeInt16Unsigned(self.type)  -- { 挖宝类型}
end

function REQ_TOMB_DIG.setArgs(self,type)
    self.type = type  -- { 挖宝类型}
end

-- [23210]请求全民寻宝 -- 活动-全民寻宝 
REQ_ALLFIND_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ALLFIND_REQUEST
    self:init(0, nil)
end)

-- [23220]开始寻宝(旧) -- 活动-全民寻宝 
REQ_ALLFIND_DIG = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ALLFIND_DIG
    self:init(0, nil)
end)

function REQ_ALLFIND_DIG.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 寻宝类型}
end

function REQ_ALLFIND_DIG.setArgs(self,type)
    self.type = type  -- { 寻宝类型}
end

-- [23230]请求积分兑换 -- 活动-全民寻宝 
REQ_ALLFIND_SHOP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ALLFIND_SHOP
    self:init(0, nil)
end)

function REQ_ALLFIND_SHOP.encode(self, w)
    w:writeInt16Unsigned(self.goods_id)  -- { 物品id}
end

function REQ_ALLFIND_SHOP.setArgs(self,goods_id)
    self.goods_id = goods_id  -- { 物品id}
end

-- [23250]开始寻宝(新) -- 活动-全民寻宝 
REQ_ALLFIND_NEW_DIG = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ALLFIND_NEW_DIG
    self:init(0, nil)
end)

function REQ_ALLFIND_NEW_DIG.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 寻宝类型CONST_ALLFIND_}
    w:writeInt8Unsigned(self.lottery)  -- { 抽奖类型CONST_ALLFIND_}
end

function REQ_ALLFIND_NEW_DIG.setArgs(self,type,lottery)
    self.type = type  -- { 寻宝类型CONST_ALLFIND_}
    self.lottery = lottery  -- { 抽奖类型CONST_ALLFIND_}
end

-- [23310]请求奖励 -- 奖励 
REQ_REWARD_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_REWARD_REQUEST
    self:init(0, nil)
end)

function REQ_REWARD_REQUEST.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型}
end

function REQ_REWARD_REQUEST.setArgs(self,type)
    self.type = type  -- { 类型}
end

-- [23450]vip奖励信息 -- 奖励 
REQ_REWARD_VIP_MSG = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_REWARD_VIP_MSG
    self:init(0, nil)
end)

-- [23510]领取在线奖励 -- 奖励 
REQ_REWARD_ONLINE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_REWARD_ONLINE
    self:init(0, nil)
end)

-- [23520]领取等级奖励 -- 奖励 
REQ_REWARD_LV = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_REWARD_LV
    self:init(0, nil)
end)

function REQ_REWARD_LV.encode(self, w)
    w:writeInt16Unsigned(self.lv)  -- { 领取等级}
end

function REQ_REWARD_LV.setArgs(self,lv)
    self.lv = lv  -- { 领取等级}
end

-- [23530]领取每日奖励 -- 奖励 
REQ_REWARD_DAILY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_REWARD_DAILY
    self:init(0, nil)
end)

function REQ_REWARD_DAILY.encode(self, w)
    w:writeInt16Unsigned(self.day)  -- { 领取的哪天}
end

function REQ_REWARD_DAILY.setArgs(self,day)
    self.day = day  -- { 领取的哪天}
end

-- [23540]领取vip奖励 -- 奖励 
REQ_REWARD_VIP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_REWARD_VIP
    self:init(0, nil)
end)

function REQ_REWARD_VIP.encode(self, w)
    w:writeInt8Unsigned(self.vip)  -- { 领取vip}
end

function REQ_REWARD_VIP.setArgs(self,vip)
    self.vip = vip  -- { 领取vip}
end

-- [23610]更新主界面数字 -- 奖励 
REQ_REWARD_BEGIN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_REWARD_BEGIN
    self:init(0, nil)
end)

-- [23640]登陆送礼领取奖励 -- 奖励 
REQ_REWARD_LOGIN_GET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_REWARD_LOGIN_GET
    self:init(0, nil)
end)

-- [23650]请求登陆送礼界面 -- 奖励 
REQ_REWARD_LOGIN_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_REWARD_LOGIN_REQUEST
    self:init(0, nil)
end)

-- [23675]请求主界面签到 -- 奖励 
REQ_REWARD_REWARD_MAIN_REQU = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_REWARD_REWARD_MAIN_REQU
    self:init(0, nil)
end)

-- [23810]进入竞技场 -- 竞技场 
REQ_ARENA_JOIN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ARENA_JOIN
    self:init(0, nil)
end)

function REQ_ARENA_JOIN.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 0:进入 1:刷新}
end

function REQ_ARENA_JOIN.setArgs(self,type)
    self.type = type  -- { 0:进入 1:刷新}
end

-- [23841]挑战结束(新) -- 竞技场 
REQ_ARENA_FINISH_NEW = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ARENA_FINISH_NEW
    self:init(0, nil)
end)

function REQ_ARENA_FINISH_NEW.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid}
    w:writeInt16Unsigned(self.ranking)  -- { 被挑战者的排名}
    w:writeInt8Unsigned(self.res)  -- { 0:失败 1:成功}
    w:writeString(self.key)  -- { 验证字符}
end

function REQ_ARENA_FINISH_NEW.setArgs(self,uid,ranking,res,key)
    self.uid = uid  -- { 玩家uid}
    self.ranking = ranking  -- { 被挑战者的排名}
    self.res = res  -- { 0:失败 1:成功}
    self.key = key  -- { 验证字符}
end

-- [23845]请求战报 -- 竞技场 
REQ_ARENA_ASK_REDIO = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ARENA_ASK_REDIO
    self:init(0, nil)
end)

-- [23860]购买挑战次数 -- 竞技场 
REQ_ARENA_BUY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ARENA_BUY
    self:init(0, nil)
end)

-- [23880]确定购买 -- 竞技场 
REQ_ARENA_BUY_YES = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ARENA_BUY_YES
    self:init(0, nil)
end)

-- [23920]请求排行榜 -- 竞技场 
REQ_ARENA_KILLER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ARENA_KILLER
    self:init(0, nil)
end)

-- [24010]清除CD时间 -- 竞技场 
REQ_ARENA_CLEAN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ARENA_CLEAN
    self:init(0, nil)
end)

-- [24030]领取竞技铜钱 -- 竞技场 
REQ_ARENA_DRAW_GOLD = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ARENA_DRAW_GOLD
    self:init(0, nil)
end)

-- [24040]进入竞技场(新) -- 竞技场 
REQ_ARENA_JOIN_NEW = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ARENA_JOIN_NEW
    self:init(0, nil)
end)

function REQ_ARENA_JOIN_NEW.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 0:进入 1:刷新}
end

function REQ_ARENA_JOIN_NEW.setArgs(self,type)
    self.type = type  -- { 0:进入 1:刷新}
end

-- [24810]请求排行榜 -- 排行榜 
REQ_TOP_RANK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TOP_RANK
    self:init(0, nil)
end)

function REQ_TOP_RANK.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 排行榜类型}
end

function REQ_TOP_RANK.setArgs(self,type)
    self.type = type  -- { 排行榜类型}
end

-- [24830]请求全部榜首 -- 排行榜 
REQ_TOP_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TOP_REQUEST
    self:init(0, nil)
end)

-- [24910]领取卡 -- 新手卡 
REQ_CARD_GETS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CARD_GETS
    self:init(0, nil)
end)

function REQ_CARD_GETS.encode(self, w)
    w:writeString(self.ids)  -- { 卡号}
end

function REQ_CARD_GETS.setArgs(self,ids)
    self.ids = ids  -- { 卡号}
end

-- [24925]每日首充请求 -- 新手卡 
REQ_CARD_CHARGE_DAILY_ASK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CARD_CHARGE_DAILY_ASK
    self:init(0, nil)
end)

-- [24935]领取首充 -- 新手卡 
REQ_CARD_CHARGE_GET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CARD_CHARGE_GET
    self:init(0, nil)
end)

-- [25010]进入竞技场 -- 灵妖竞技场 
REQ_LINGYAO_ARENA_JOIN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_ARENA_JOIN
    self:init(0, nil)
end)

function REQ_LINGYAO_ARENA_JOIN.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 0:进入 1:刷新}
end

function REQ_LINGYAO_ARENA_JOIN.setArgs(self,type)
    self.type = type  -- { 0:进入 1:刷新}
end

-- [25040]请求对手信息 -- 灵妖竞技场 
REQ_LINGYAO_ARENA_RIVAL_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_ARENA_RIVAL_REQUEST
    self:init(0, nil)
end)

function REQ_LINGYAO_ARENA_RIVAL_REQUEST.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 对手ID}
    w:writeInt16Unsigned(self.rank)  -- { 对手排名}
end

function REQ_LINGYAO_ARENA_RIVAL_REQUEST.setArgs(self,uid,rank)
    self.uid = uid  -- { 对手ID}
    self.rank = rank  -- { 对手排名}
end

-- [25060]请求购买次数 -- 灵妖竞技场 
REQ_LINGYAO_ARENA_BUY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_ARENA_BUY
    self:init(0, nil)
end)

function REQ_LINGYAO_ARENA_BUY.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 0:购买提示1:确认购买}
end

function REQ_LINGYAO_ARENA_BUY.setArgs(self,type)
    self.type = type  -- { 0:购买提示1:确认购买}
end

-- [25070]请求排行榜 -- 灵妖竞技场 
REQ_LINGYAO_ARENA_RANK_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_ARENA_RANK_REQUEST
    self:init(0, nil)
end)

-- [25090]请求战报 -- 灵妖竞技场 
REQ_LINGYAO_ARENA_REPORT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_ARENA_REPORT
    self:init(0, nil)
end)

-- [25100]清除挑战CD -- 灵妖竞技场 
REQ_LINGYAO_ARENA_CD_CLEAN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_ARENA_CD_CLEAN
    self:init(0, nil)
end)

-- [25110]请求防守阵容 -- 灵妖竞技场 
REQ_LINGYAO_ARENA_DEF = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_ARENA_DEF
    self:init(0, nil)
end)

function REQ_LINGYAO_ARENA_DEF.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家ID(自己为0)}
end

function REQ_LINGYAO_ARENA_DEF.setArgs(self,uid)
    self.uid = uid  -- { 玩家ID(自己为0)}
end

-- [25130]领取分钟奖励 -- 灵妖竞技场 
REQ_LINGYAO_ARENA_DRAW_REWARD = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_ARENA_DRAW_REWARD
    self:init(0, nil)
end)

-- [25150]挑战完成返回 -- 灵妖竞技场 
REQ_LINGYAO_ARENA_OVER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_ARENA_OVER
    self:init(0, nil)
end)

function REQ_LINGYAO_ARENA_OVER.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 被挑战者uid}
    w:writeInt16Unsigned(self.rank)  -- { 被挑战者排名}
    w:writeInt8Unsigned(self.result1)  -- { 第一回合结果(1负2平4胜)}
    w:writeInt8Unsigned(self.result2)  -- { 第二回合结果(1负2平4胜)}
    w:writeInt8Unsigned(self.result3)  -- { 第三回合结果(1负2平4胜)}
    w:writeString(self.key)  -- { 验证key}
end

function REQ_LINGYAO_ARENA_OVER.setArgs(self,uid,rank,result1,result2,result3,key)
    self.uid = uid  -- { 被挑战者uid}
    self.rank = rank  -- { 被挑战者排名}
    self.result1 = result1  -- { 第一回合结果(1负2平4胜)}
    self.result2 = result2  -- { 第二回合结果(1负2平4胜)}
    self.result3 = result3  -- { 第三回合结果(1负2平4胜)}
    self.key = key  -- { 验证key}
end

-- [25510]请求招财貔貅 -- 招财貔貅 
REQ_WEAGOD_RMB_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WEAGOD_RMB_REQUEST
    self:init(0, nil)
end)

-- [25530]请求购买招财貔貅 -- 招财貔貅 
REQ_WEAGOD_RMB_BUY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WEAGOD_RMB_BUY
    self:init(0, nil)
end)

-- [25550]请求貔貅礼包领取 -- 招财貔貅 
REQ_WEAGOD_RMB_GIFT_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WEAGOD_RMB_GIFT_REQUEST
    self:init(0, nil)
end)

function REQ_WEAGOD_RMB_GIFT_REQUEST.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 礼包id}
end

function REQ_WEAGOD_RMB_GIFT_REQUEST.setArgs(self,id)
    self.id = id  -- { 礼包id}
end

-- [25580]请求貔貅界面 -- 招财貔貅 
REQ_WEAGOD_RMB_CALL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WEAGOD_RMB_CALL
    self:init(0, nil)
end)

-- [26000]请求NPC -- NPC 
REQ_NPC_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_NPC_REQUEST
    self:init(0, nil)
end)

function REQ_NPC_REQUEST.encode(self, w)
    w:writeInt16Unsigned(self.npc_id)  -- { NPCID}
    w:writeInt8Unsigned(self.fun_flag)  -- { NPC功能标识}
end

function REQ_NPC_REQUEST.setArgs(self,npc_id,fun_flag)
    self.npc_id = npc_id  -- { NPCID}
    self.fun_flag = fun_flag  -- { NPC功能标识}
end

-- [26010]从NPC处滚蛋 -- NPC 
REQ_NPC_SCRAM = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_NPC_SCRAM
    self:init(0, nil)
end)

-- [26040]设置队长 -- NPC 
REQ_NPC_SET_LEADER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_NPC_SET_LEADER
    self:init(0, nil)
end)

function REQ_NPC_SET_LEADER.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 新队长Uid}
end

function REQ_NPC_SET_LEADER.setArgs(self,uid)
    self.uid = uid  -- { 新队长Uid}
end

-- [26050]加入队伍 -- NPC 
REQ_NPC_JOIN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_NPC_JOIN
    self:init(0, nil)
end)

function REQ_NPC_JOIN.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 队长Uid}
end

function REQ_NPC_JOIN.setArgs(self,uid)
    self.uid = uid  -- { 队长Uid}
end

-- [26060]退出队伍 -- NPC 
REQ_NPC_LEAVE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_NPC_LEAVE
    self:init(0, nil)
end)

-- [26070]踢出队员 -- NPC 
REQ_NPC_KICK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_NPC_KICK
    self:init(0, nil)
end)

function REQ_NPC_KICK.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 队员uid}
end

function REQ_NPC_KICK.setArgs(self,uid)
    self.uid = uid  -- { 队员uid}
end

-- [26080]解散队伍 -- NPC 
REQ_NPC_DISMISS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_NPC_DISMISS
    self:init(0, nil)
end)

-- [26100]NPC进入(战场|副本|各种组队玩法) -- NPC 
REQ_NPC_TEAM_ENTER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_NPC_TEAM_ENTER
    self:init(0, nil)
end)

function REQ_NPC_TEAM_ENTER.encode(self, w)
    w:writeInt8Unsigned(self.param)  -- { 参数}
end

function REQ_NPC_TEAM_ENTER.setArgs(self,param)
    self.param = param  -- { 参数}
end

-- [28010]请求阵型系统 -- 布阵 
REQ_ARRAY_LIST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ARRAY_LIST
    self:init(0, nil)
end)

-- [28020]上阵 -- 布阵 
REQ_ARRAY_UP_ARRAY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ARRAY_UP_ARRAY
    self:init(0, nil)
end)

function REQ_ARRAY_UP_ARRAY.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 0:双击上阵,其它位置索引}
    w:writeInt16Unsigned(self.partner_id)  -- { 伙伴ID}
end

function REQ_ARRAY_UP_ARRAY.setArgs(self,type,partner_id)
    self.type = type  -- { 0:双击上阵,其它位置索引}
    self.partner_id = partner_id  -- { 伙伴ID}
end

-- [28030]下阵 -- 布阵 
REQ_ARRAY_DOWN_ARRAY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ARRAY_DOWN_ARRAY
    self:init(0, nil)
end)

function REQ_ARRAY_DOWN_ARRAY.encode(self, w)
    w:writeInt16Unsigned(self.partner_id)  -- { 伙伴ID}
    w:writeInt8Unsigned(self.position_idx)  -- { 阵位}
end

function REQ_ARRAY_DOWN_ARRAY.setArgs(self,partner_id,position_idx)
    self.partner_id = partner_id  -- { 伙伴ID}
    self.position_idx = position_idx  -- { 阵位}
end

-- [28040]交换阵位 -- 布阵 
REQ_ARRAY_EXCHANGE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ARRAY_EXCHANGE
    self:init(0, nil)
end)

function REQ_ARRAY_EXCHANGE.encode(self, w)
    w:writeInt8Unsigned(self.fpartner_idx)  -- { 交换伙伴索引}
    w:writeInt16Unsigned(self.partner_idx)  -- { 被交换伙伴索引}
end

function REQ_ARRAY_EXCHANGE.setArgs(self,fpartner_idx,partner_idx)
    self.fpartner_idx = fpartner_idx  -- { 交换伙伴索引}
    self.partner_idx = partner_idx  -- { 被交换伙伴索引}
end

-- [29010]请求洞府祈福 -- 洞府祈福 
REQ_CLIFFORD_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLIFFORD_REQUEST
    self:init(0, nil)
end)

-- [29040]祈福 -- 洞府祈福 
REQ_CLIFFORD_START = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLIFFORD_START
    self:init(0, nil)
end)

-- [29060]领取箱子 -- 洞府祈福 
REQ_CLIFFORD_LQ_REWAR = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLIFFORD_LQ_REWAR
    self:init(0, nil)
end)

function REQ_CLIFFORD_LQ_REWAR.encode(self, w)
    w:writeInt8Unsigned(self.idx)  -- { 箱子编号}
end

function REQ_CLIFFORD_LQ_REWAR.setArgs(self,idx)
    self.idx = idx  -- { 箱子编号}
end

-- [30505]请求今日活跃度 -- 攻略 
REQ_GONGLUE_HY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GONGLUE_HY
    self:init(0, nil)
end)

-- [30520]请求活动日历 -- 攻略 
REQ_GONGLUE_ACTIVITY_DAY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GONGLUE_ACTIVITY_DAY
    self:init(0, nil)
end)

function REQ_GONGLUE_ACTIVITY_DAY.encode(self, w)
    w:writeInt8Unsigned(self.week)  -- { 星期几0:当天}
end

function REQ_GONGLUE_ACTIVITY_DAY.setArgs(self,week)
    self.week = week  -- { 星期几0:当天}
end

-- [30540]请求我要变强 -- 攻略 
REQ_GONGLUE_STRONG = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GONGLUE_STRONG
    self:init(0, nil)
end)

function REQ_GONGLUE_STRONG.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型}
end

function REQ_GONGLUE_STRONG.setArgs(self,type)
    self.type = type  -- { 类型}
end

-- [30555]领取活跃宝箱 -- 攻略 
REQ_GONGLUE_BOX = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GONGLUE_BOX
    self:init(0, nil)
end)

function REQ_GONGLUE_BOX.encode(self, w)
    w:writeInt8Unsigned(self.id)  -- { 宝箱阶段ID}
end

function REQ_GONGLUE_BOX.setArgs(self,id)
    self.id = id  -- { 宝箱阶段ID}
end

-- [31110]请求灵妖界面 -- 灵妖系统 
REQ_LINGYAO_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_REQUEST
    self:init(0, nil)
end)

function REQ_LINGYAO_REQUEST.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1:灵妖;2:灵妖竞技场}
end

function REQ_LINGYAO_REQUEST.setArgs(self,type)
    self.type = type  -- { 1:灵妖;2:灵妖竞技场}
end

-- [31150]灵妖激活 -- 灵妖系统 
REQ_LINGYAO_JIHUO = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_JIHUO
    self:init(0, nil)
end)

function REQ_LINGYAO_JIHUO.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 灵妖id}
    w:writeInt8Unsigned(self.type)  -- { 1 直接激活；2碎片激活}
end

function REQ_LINGYAO_JIHUO.setArgs(self,id,type)
    self.id = id  -- { 灵妖id}
    self.type = type  -- { 1 直接激活；2碎片激活}
end

-- [31280]灵妖升级 -- 灵妖系统 
REQ_LINGYAO_UPGRADE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_UPGRADE
    self:init(0, nil)
end)

function REQ_LINGYAO_UPGRADE.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 灵妖id}
end

function REQ_LINGYAO_UPGRADE.setArgs(self,id)
    self.id = id  -- { 灵妖id}
end

-- [31360]灵妖升阶 -- 灵妖系统 
REQ_LINGYAO_SHENGJIE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_SHENGJIE
    self:init(0, nil)
end)

function REQ_LINGYAO_SHENGJIE.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 灵妖id}
end

function REQ_LINGYAO_SHENGJIE.setArgs(self,id)
    self.id = id  -- { 灵妖id}
end

-- [31520]灵妖镶嵌符文(背包) -- 灵妖系统 
REQ_LINGYAO_EQUIP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_EQUIP
    self:init(0, nil)
end)

function REQ_LINGYAO_EQUIP.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 灵妖id}
    w:writeInt16Unsigned(self.goods_id)  -- { 物品ID}
end

function REQ_LINGYAO_EQUIP.setArgs(self,id,goods_id)
    self.id = id  -- { 灵妖id}
    self.goods_id = goods_id  -- { 物品ID}
end

-- [31530]灵妖镶嵌符文(其他灵妖身上) -- 灵妖系统 
REQ_LINGYAO_EQUIP_OTHER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_EQUIP_OTHER
    self:init(0, nil)
end)

function REQ_LINGYAO_EQUIP_OTHER.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 灵妖id}
    w:writeInt16Unsigned(self.id2)  -- { 另一只灵妖id}
    w:writeInt16Unsigned(self.goods_id)  -- { 物品id}
end

function REQ_LINGYAO_EQUIP_OTHER.setArgs(self,id,id2,goods_id)
    self.id = id  -- { 灵妖id}
    self.id2 = id2  -- { 另一只灵妖id}
    self.goods_id = goods_id  -- { 物品id}
end

-- [31535]灵妖卸下符文 -- 灵妖系统 
REQ_LINGYAO_EQUIP_OFF = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_EQUIP_OFF
    self:init(0, nil)
end)

function REQ_LINGYAO_EQUIP_OFF.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 灵妖id}
    w:writeInt16Unsigned(self.goods_id)  -- { 物品ID}
end

function REQ_LINGYAO_EQUIP_OFF.setArgs(self,id,goods_id)
    self.id = id  -- { 灵妖id}
    self.goods_id = goods_id  -- { 物品ID}
end

-- [31540]查看总属性加成 -- 灵妖系统 
REQ_LINGYAO_ATTR_ALL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_ATTR_ALL
    self:init(0, nil)
end)

-- [31550]一键镶嵌 -- 灵妖系统 
REQ_LINGYAO_EQUIP_ALL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LINGYAO_EQUIP_ALL
    self:init(0, nil)
end)

function REQ_LINGYAO_EQUIP_ALL.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 灵妖id}
end

function REQ_LINGYAO_EQUIP_ALL.setArgs(self,id)
    self.id = id  -- { 灵妖id}
end

-- [32010]财神面板请求 -- 摇钱树 
REQ_WEAGOD_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WEAGOD_REQUEST
    self:init(0, nil)
end)

-- [32030]招财 -- 摇钱树 
REQ_WEAGOD_GET_MONEY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WEAGOD_GET_MONEY
    self:init(0, nil)
end)

-- [32040]批量招财 -- 摇钱树 
REQ_WEAGOD_PL_MONEY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WEAGOD_PL_MONEY
    self:init(0, nil)
end)

-- [32050]自动招财 -- 摇钱树 
REQ_WEAGOD_AUTO_GET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WEAGOD_AUTO_GET
    self:init(0, nil)
end)

-- [33010]请求帮派信息 -- 帮派 
REQ_CLAN_ASK_CLAN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLAN_ASK_CLAN
    self:init(0, nil)
end)

function REQ_CLAN_ASK_CLAN.encode(self, w)
    w:writeInt32Unsigned(self.clan_id)  -- { 帮派id}
end

function REQ_CLAN_ASK_CLAN.setArgs(self,clan_id)
    self.clan_id = clan_id  -- { 帮派id}
end

-- [33030]请求帮派列表 -- 帮派 
REQ_CLAN_ASL_CLANLIST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLAN_ASL_CLANLIST
    self:init(0, nil)
end)

function REQ_CLAN_ASL_CLANLIST.encode(self, w)
    w:writeInt16Unsigned(self.page)  -- { 第几页}
end

function REQ_CLAN_ASL_CLANLIST.setArgs(self,page)
    self.page = page  -- { 第几页}
end

-- [33037]请求|取消加入帮 -- 帮派 
REQ_CLAN_ASK_CANCEL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLAN_ASK_CANCEL
    self:init(0, nil)
end)

function REQ_CLAN_ASK_CANCEL.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { type}
    w:writeInt32Unsigned(self.clan_id)  -- { clanId}
end

function REQ_CLAN_ASK_CANCEL.setArgs(self,type,clan_id)
    self.type = type  -- { type}
    self.clan_id = clan_id  -- { clanId}
end

-- [33050]请求创建帮派 -- 帮派 
REQ_CLAN_ASK_REBUILD_CLAN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLAN_ASK_REBUILD_CLAN
    self:init(0, nil)
end)

function REQ_CLAN_ASK_REBUILD_CLAN.encode(self, w)
    w:writeString(self.clan_name)  -- { 帮派名字}
end

function REQ_CLAN_ASK_REBUILD_CLAN.setArgs(self,clan_name)
    self.clan_name = clan_name  -- { 帮派名字}
end

-- [33070]请求入帮申请列表 -- 帮派 
REQ_CLAN_ASK_JOIN_LIST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLAN_ASK_JOIN_LIST
    self:init(0, nil)
end)

-- [33090]请求审核操作 -- 帮派 
REQ_CLAN_ASK_AUDIT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLAN_ASK_AUDIT
    self:init(0, nil)
end)

function REQ_CLAN_ASK_AUDIT.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家Uid}
    w:writeInt8Unsigned(self.state)  -- { 1 true| 0 false}
end

function REQ_CLAN_ASK_AUDIT.setArgs(self,uid,state)
    self.uid = uid  -- { 玩家Uid}
    self.state = state  -- { 1 true| 0 false}
end

-- [33110]请求修改帮派公告 -- 帮派 
REQ_CLAN_ASK_RESET_CAST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLAN_ASK_RESET_CAST
    self:init(0, nil)
end)

function REQ_CLAN_ASK_RESET_CAST.encode(self, w)
    w:writeUTF(self.string)  -- { 公告内容}
end

function REQ_CLAN_ASK_RESET_CAST.setArgs(self,string)
    self.string = string  -- { 公告内容}
end

-- [33130]请求帮派成员列表 -- 帮派 
REQ_CLAN_ASK_MEMBER_MSG = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLAN_ASK_MEMBER_MSG
    self:init(0, nil)
end)

-- [33135]请求设置成员职位 -- 帮派 
REQ_CLAN_ASK_SET_POST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLAN_ASK_SET_POST
    self:init(0, nil)
end)

function REQ_CLAN_ASK_SET_POST.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid}
    w:writeInt8Unsigned(self.post)  -- { 新职位类型 CONST_CLAN_POST_}
end

function REQ_CLAN_ASK_SET_POST.setArgs(self,uid,post)
    self.uid = uid  -- { 玩家uid}
    self.post = post  -- { 新职位类型 CONST_CLAN_POST_}
end

-- [33150]请求退出|解散帮派 -- 帮派 
REQ_CLAN_ASK_OUT_CLAN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLAN_ASK_OUT_CLAN
    self:init(0, nil)
end)

function REQ_CLAN_ASK_OUT_CLAN.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1 退出帮派| 0 解散帮派}
end

function REQ_CLAN_ASK_OUT_CLAN.setArgs(self,type)
    self.type = type  -- { 1 退出帮派| 0 解散帮派}
end

-- [33200]请求帮派技能面板 -- 帮派 
REQ_CLAN_ASK_CLAN_SKILL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLAN_ASK_CLAN_SKILL
    self:init(0, nil)
end)

-- [33220]请求学习帮派技能 -- 帮派 
REQ_CLAN_STUDY_SKILL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLAN_STUDY_SKILL
    self:init(0, nil)
end)

function REQ_CLAN_STUDY_SKILL.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 学习类型 接【33215】}
end

function REQ_CLAN_STUDY_SKILL.setArgs(self,type)
    self.type = type  -- { 学习类型 接【33215】}
end

-- [33320]请求互动面板 -- 帮派 
REQ_CLAN_ASK_WATER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLAN_ASK_WATER
    self:init(0, nil)
end)

-- [33325]请求开始互动 -- 帮派 
REQ_CLAN_START_WATER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLAN_START_WATER
    self:init(0, nil)
end)

function REQ_CLAN_START_WATER.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型 1 低级| 2中级|3高级}
end

function REQ_CLAN_START_WATER.setArgs(self,type)
    self.type = type  -- { 类型 1 低级| 2中级|3高级}
end

-- [33380]招募帮众 -- 帮派 
REQ_CLAN_ZAOMU = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLAN_ZAOMU
    self:init(0, nil)
end)

-- [33390]请求个人职位 -- 帮派 
REQ_CLAN_SELF_POST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLAN_SELF_POST
    self:init(0, nil)
end)

-- [33430]离开界面 -- 帮派 
REQ_CLAN_LEAVE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLAN_LEAVE
    self:init(0, nil)
end)

-- [33440]弹劾洞主 -- 帮派 
REQ_CLAN_TH_MASTER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLAN_TH_MASTER
    self:init(0, nil)
end)

-- [34010]请求寻宝界面 -- 活动-龙宫寻宝 
REQ_DRAGON_ASK_JOIN_DRAGON = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DRAGON_ASK_JOIN_DRAGON
    self:init(0, nil)
end)

-- [34030]开始寻宝 -- 活动-龙宫寻宝 
REQ_DRAGON_START_DRAGON = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DRAGON_START_DRAGON
    self:init(0, nil)
end)

function REQ_DRAGON_START_DRAGON.encode(self, w)
    w:writeInt32(self.num)  -- { 寻宝次数}
end

function REQ_DRAGON_START_DRAGON.setArgs(self,num)
    self.num = num  -- { 寻宝次数}
end

-- [34260]请求武器界面 -- 武器 
REQ_WUQI_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WUQI_REQUEST
    self:init(0, nil)
end)

function REQ_WUQI_REQUEST.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid 0:自己}
end

function REQ_WUQI_REQUEST.setArgs(self,uid)
    self.uid = uid  -- { 玩家uid 0:自己}
end

-- [34270]武器升级 -- 武器 
REQ_WUQI_LV_UP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WUQI_LV_UP
    self:init(0, nil)
end)

-- [34510] 请求店铺面板 -- 商城 
REQ_SHOP_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SHOP_REQUEST
    self:init(0, nil)
end)

function REQ_SHOP_REQUEST.encode(self, w)
    w:writeInt16Unsigned(self.type)  -- { 店铺类型}
    w:writeInt16Unsigned(self.type_bb)  -- { 子店铺类型}
end

function REQ_SHOP_REQUEST.setArgs(self,type,type_bb)
    self.type = type  -- { 店铺类型}
    self.type_bb = type_bb  -- { 子店铺类型}
end

-- [34515]请求购买 -- 商城 
REQ_SHOP_BUY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SHOP_BUY
    self:init(0, nil)
end)

function REQ_SHOP_BUY.encode(self, w)
    w:writeInt16Unsigned(self.type)  -- { 商城类型}
    w:writeInt16Unsigned(self.type_bb)  -- { 子店铺类型}
    w:writeInt16Unsigned(self.idx)  -- { 物品数据索引}
    w:writeInt16Unsigned(self.goods_id)  -- { 物品id}
    w:writeInt16Unsigned(self.count)  -- { 购买数量}
    w:writeInt16Unsigned(self.c_type)  -- { 消耗类型}
end

function REQ_SHOP_BUY.setArgs(self,type,type_bb,idx,goods_id,count,c_type)
    self.type = type  -- { 商城类型}
    self.type_bb = type_bb  -- { 子店铺类型}
    self.idx = idx  -- { 物品数据索引}
    self.goods_id = goods_id  -- { 物品id}
    self.count = count  -- { 购买数量}
    self.c_type = c_type  -- { 消耗类型}
end

-- [34520]请求积分数据 -- 商城 
REQ_SHOP_ASK_INTEGRAL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SHOP_ASK_INTEGRAL
    self:init(0, nil)
end)

-- [35010]进入苦工系统 -- 苦工 
REQ_MOIL_ENJOY_MOIL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MOIL_ENJOY_MOIL
    self:init(0, nil)
end)

-- [35030]苦工系统操作 -- 苦工 
REQ_MOIL_OPER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MOIL_OPER
    self:init(0, nil)
end)

function REQ_MOIL_OPER.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1:抓捕6:求救7:夺扑之敌(CONST_MOIL_FUNCTION*)}
end

function REQ_MOIL_OPER.setArgs(self,type)
    self.type = type  -- { 1:抓捕6:求救7:夺扑之敌(CONST_MOIL_FUNCTION*)}
end

-- [35040]抓捕 -- 苦工 
REQ_MOIL_CAPTRUE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MOIL_CAPTRUE
    self:init(0, nil)
end)

function REQ_MOIL_CAPTRUE.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1:抓捕5:反抗6:求救 (选择)(CONST_MOIL_FUNCTION*)}
    w:writeInt32Unsigned(self.uid)  -- { 被抓uid}
end

function REQ_MOIL_CAPTRUE.setArgs(self,type,uid)
    self.type = type  -- { 1:抓捕5:反抗6:求救 (选择)(CONST_MOIL_FUNCTION*)}
    self.uid = uid  -- { 被抓uid}
end

-- [35041]抓捕结果 -- 苦工 
REQ_MOIL_CALL_RES = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MOIL_CALL_RES
    self:init(0, nil)
end)

function REQ_MOIL_CALL_RES.encode(self, w)
    w:writeInt8Unsigned(self.type_id)  -- { 类型id}
    w:writeInt32Unsigned(self.uid)  -- { 被动方uid}
    w:writeInt8Unsigned(self.res)  -- { res}
end

function REQ_MOIL_CALL_RES.setArgs(self,type_id,uid,res)
    self.type_id = type_id  -- { 类型id}
    self.uid = uid  -- { 被动方uid}
    self.res = res  -- { res}
end

-- [35050]互动 -- 苦工 
REQ_MOIL_ACTIVE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MOIL_ACTIVE
    self:init(0, nil)
end)

function REQ_MOIL_ACTIVE.encode(self, w)
    w:writeInt8Unsigned(self.active_id)  -- { 互动Id}
    w:writeInt32Unsigned(self.uid)  -- { 苦工uid}
end

function REQ_MOIL_ACTIVE.setArgs(self,active_id,uid)
    self.active_id = active_id  -- { 互动Id}
    self.uid = uid  -- { 苦工uid}
end

-- [35060]请求压榨/互动界面 -- 苦工 
REQ_MOIL_PRESS_START = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MOIL_PRESS_START
    self:init(0, nil)
end)

function REQ_MOIL_PRESS_START.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 3:互动4:压榨}
end

function REQ_MOIL_PRESS_START.setArgs(self,type)
    self.type = type  -- { 3:互动4:压榨}
end

-- [35070]压榨/抽取/提取 -- 苦工 
REQ_MOIL_PRESS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MOIL_PRESS
    self:init(0, nil)
end)

function REQ_MOIL_PRESS.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1:提取2:压榨3:抽取}
    w:writeInt32Unsigned(self.uid)  -- { 苦工uid}
end

function REQ_MOIL_PRESS.setArgs(self,type,uid)
    self.type = type  -- { 1:提取2:压榨3:抽取}
    self.uid = uid  -- { 苦工uid}
end

-- [35100]释放苦工 -- 苦工 
REQ_MOIL_RELEASE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MOIL_RELEASE
    self:init(0, nil)
end)

function REQ_MOIL_RELEASE.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 苦工uid}
    w:writeInt8Unsigned(self.type)  -- { 刷新类型 3:互动面板 4:压榨面板  常量 CONST_MOIL_FUNCTION_*}
end

function REQ_MOIL_RELEASE.setArgs(self,uid,type)
    self.uid = uid  -- { 苦工uid}
    self.type = type  -- { 刷新类型 3:互动面板 4:压榨面板  常量 CONST_MOIL_FUNCTION_*}
end

-- [35120]购买抓捕次数 -- 苦工 
REQ_MOIL_BUY_CAPTRUE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MOIL_BUY_CAPTRUE
    self:init(0, nil)
end)

-- [35160]查看玩家苦工 -- 苦工 
REQ_MOIL_LOOK_TMOILS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MOIL_LOOK_TMOILS
    self:init(0, nil)
end)

function REQ_MOIL_LOOK_TMOILS.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid}
end

function REQ_MOIL_LOOK_TMOILS.setArgs(self,uid)
    self.uid = uid  -- { 玩家uid}
end

-- [36010]请求三界杀 -- 三界杀 
REQ_CIRCLE_ENJOY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CIRCLE_ENJOY
    self:init(0, nil)
end)

function REQ_CIRCLE_ENJOY.encode(self, w)
    w:writeInt8Unsigned(self.chap)  -- { 章节0：为默认章节}
end

function REQ_CIRCLE_ENJOY.setArgs(self,chap)
    self.chap = chap  -- { 章节0：为默认章节}
end

-- [36030]请求重置 -- 三界杀 
REQ_CIRCLE_RESET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CIRCLE_RESET
    self:init(0, nil)
end)

function REQ_CIRCLE_RESET.encode(self, w)
    w:writeInt16Unsigned(self.type)  -- { 0:全部重置|武将ID}
end

function REQ_CIRCLE_RESET.setArgs(self,type)
    self.type = type  -- { 0:全部重置|武将ID}
end

-- [36040]开始挑战 -- 三界杀 
REQ_CIRCLE_WAR_START = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CIRCLE_WAR_START
    self:init(0, nil)
end)

function REQ_CIRCLE_WAR_START.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 武将ID}
end

function REQ_CIRCLE_WAR_START.setArgs(self,id)
    self.id = id  -- { 武将ID}
end

-- [37004]请求面板 -- 世界BOSS 
REQ_WORLD_BOSS_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WORLD_BOSS_REQUEST
    self:init(0, nil)
end)

-- [37010]进入boss -- 世界BOSS 
REQ_WORLD_BOSS_CITY_BOOSS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WORLD_BOSS_CITY_BOOSS
    self:init(0, nil)
end)

-- [37100]退出世界BOSS -- 世界BOSS 
REQ_WORLD_BOSS_EXIT_S = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WORLD_BOSS_EXIT_S
    self:init(0, nil)
end)

-- [37110]复活 -- 世界BOSS 
REQ_WORLD_BOSS_REVIVE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WORLD_BOSS_REVIVE
    self:init(0, nil)
end)

function REQ_WORLD_BOSS_REVIVE.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1:立即复活 0:复活}
end

function REQ_WORLD_BOSS_REVIVE.setArgs(self,type)
    self.type = type  -- { 1:立即复活 0:复活}
end

-- [37160]请求排行版 -- 世界BOSS 
REQ_WORLD_BOSS_ASK_SETTLE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WORLD_BOSS_ASK_SETTLE
    self:init(0, nil)
end)

function REQ_WORLD_BOSS_ASK_SETTLE.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型}
end

function REQ_WORLD_BOSS_ASK_SETTLE.setArgs(self,type)
    self.type = type  -- { 类型}
end

-- [37200]元宝鼓舞 -- 世界BOSS 
REQ_WORLD_BOSS_RMB_ATTR = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WORLD_BOSS_RMB_ATTR
    self:init(0, nil)
end)

function REQ_WORLD_BOSS_RMB_ATTR.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 0:问价 1:是}
end

function REQ_WORLD_BOSS_RMB_ATTR.setArgs(self,type)
    self.type = type  -- { 0:问价 1:是}
end

-- [37302]请求购买世界BOSS信息 -- 世界BOSS 
REQ_WORLD_BOSS_BUY_INFO = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WORLD_BOSS_BUY_INFO
    self:init(0, nil)
end)

function REQ_WORLD_BOSS_BUY_INFO.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 0/马面，1/牛头}
end

function REQ_WORLD_BOSS_BUY_INFO.setArgs(self,type)
    self.type = type  -- { 0/马面，1/牛头}
end

-- [37306]请求购买世界BOSS -- 世界BOSS 
REQ_WORLD_BOSS_BUY_REQ = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WORLD_BOSS_BUY_REQ
    self:init(0, nil)
end)

function REQ_WORLD_BOSS_BUY_REQ.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 0/马面，1/牛头}
end

function REQ_WORLD_BOSS_BUY_REQ.setArgs(self,type)
    self.type = type  -- { 0/马面，1/牛头}
end

-- [38005]请求目标数据 -- 目标任务 
REQ_TARGET_LIST_ASK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TARGET_LIST_ASK
    self:init(0, nil)
end)

-- [38030]领取目标奖励 -- 目标任务 
REQ_TARGET_REWARD_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TARGET_REWARD_REQUEST
    self:init(0, nil)
end)

function REQ_TARGET_REWARD_REQUEST.encode(self, w)
    w:writeInt16Unsigned(self.serial)  -- { 目标序号}
end

function REQ_TARGET_REWARD_REQUEST.setArgs(self,serial)
    self.serial = serial  -- { 目标序号}
end

-- [39010]请求英雄副本 -- 噩梦副本 
REQ_HERO_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_HERO_REQUEST
    self:init(0, nil)
end)

function REQ_HERO_REQUEST.encode(self, w)
    w:writeInt16Unsigned(self.chap_id)  -- { 章节ID}
end

function REQ_HERO_REQUEST.setArgs(self,chap_id)
    self.chap_id = chap_id  -- { 章节ID}
end

-- [39015]请求全部英雄副本 -- 噩梦副本 
REQ_HERO_REQUEST_ALL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_HERO_REQUEST_ALL
    self:init(0, nil)
end)

-- [39050]购买英雄副本次数 -- 噩梦副本 
REQ_HERO_BUY_TIMES = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_HERO_BUY_TIMES
    self:init(0, nil)
end)

function REQ_HERO_BUY_TIMES.encode(self, w)
    w:writeInt16Unsigned(self.times)  -- { }
end

function REQ_HERO_BUY_TIMES.setArgs(self,times)
    self.times = times  -- { }
end

-- [39090]请求精英副本次数 -- 噩梦副本 
REQ_HERO_TIMES = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_HERO_TIMES
    self:init(0, nil)
end)

-- [39510]请求珍宝副本 -- 珍宝副本 
REQ_COPY_GEM_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_GEM_REQUEST
    self:init(0, nil)
end)

function REQ_COPY_GEM_REQUEST.encode(self, w)
    w:writeInt16Unsigned(self.chap_id)  -- { 章节}
end

function REQ_COPY_GEM_REQUEST.setArgs(self,chap_id)
    self.chap_id = chap_id  -- { 章节}
end

-- [39520]请求全部珍宝副本 -- 珍宝副本 
REQ_COPY_GEM_REQUEST_ALL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_GEM_REQUEST_ALL
    self:init(0, nil)
end)

-- [39550]购买次数 -- 珍宝副本 
REQ_COPY_GEM_TIMES_BUY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_GEM_TIMES_BUY
    self:init(0, nil)
end)

function REQ_COPY_GEM_TIMES_BUY.encode(self, w)
    w:writeInt8Unsigned(self.times)  -- { 购买次数}
end

function REQ_COPY_GEM_TIMES_BUY.setArgs(self,times)
    self.times = times  -- { 购买次数}
end

-- [40010]登录抽奖页面 -- 签到抽奖 
REQ_SIGN_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SIGN_REQUEST
    self:init(0, nil)
end)

function REQ_SIGN_REQUEST.encode(self, w)
    w:writeInt8Unsigned(self.style)  -- { 抽奖类型(1:12天,2:7天)}
end

function REQ_SIGN_REQUEST.setArgs(self,style)
    self.style = style  -- { 抽奖类型(1:12天,2:7天)}
end

-- [40040]抽取奖励 -- 签到抽奖 
REQ_SIGN_GET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SIGN_GET
    self:init(0, nil)
end)

function REQ_SIGN_GET.encode(self, w)
    w:writeInt8Unsigned(self.style)  -- { 抽奖类型(1:12天,2:7天)}
end

function REQ_SIGN_GET.setArgs(self,style)
    self.style = style  -- { 抽奖类型(1:12天,2:7天)}
end

-- [40060]弹窗 -- 签到抽奖 
REQ_SIGN_IS_POP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SIGN_IS_POP
    self:init(0, nil)
end)

-- [40502]请求帮派战界面 -- 帮派战 
REQ_GANG_WARFARE_REPLAY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GANG_WARFARE_REPLAY
    self:init(0, nil)
end)

-- [40505]请求帮派分组信息 -- 帮派战 
REQ_GANG_WARFARE_REQ = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GANG_WARFARE_REQ
    self:init(0, nil)
end)

-- [40520]帮派战个人信息 -- 帮派战 
REQ_GANG_WARFARE_ONCE_REQ = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GANG_WARFARE_ONCE_REQ
    self:init(0, nil)
end)

-- [40521]请求进入帮派战 -- 帮派战 
REQ_GANG_WARFARE_ENTER_MAP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GANG_WARFARE_ENTER_MAP
    self:init(0, nil)
end)

-- [40522]请求战报 -- 帮派战 
REQ_GANG_WARFARE_WAR_REPORT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GANG_WARFARE_WAR_REPORT
    self:init(0, nil)
end)

-- [40544]主动复活 -- 帮派战 
REQ_GANG_WARFARE_INITIATIVE_REC = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GANG_WARFARE_INITIATIVE_REC
    self:init(0, nil)
end)

-- [40560]退出帮派战 -- 帮派战 
REQ_GANG_WARFARE_EXIT_WAR = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_GANG_WARFARE_EXIT_WAR
    self:init(0, nil)
end)

-- [41510]请求成就系统面板 -- 成就系统 
REQ_ACHIEVE_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ACHIEVE_REQUEST
    self:init(0, nil)
end)

function REQ_ACHIEVE_REQUEST.encode(self, w)
    w:writeInt16Unsigned(self.type)  -- { 成就主类ID}
end

function REQ_ACHIEVE_REQUEST.setArgs(self,type)
    self.type = type  -- { 成就主类ID}
end

-- [41540]成就领取 -- 成就系统 
REQ_ACHIEVE_GET_REWARD = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ACHIEVE_GET_REWARD
    self:init(0, nil)
end)

function REQ_ACHIEVE_GET_REWARD.encode(self, w)
    w:writeInt16Unsigned(self.type)  -- { 成就ID}
    w:writeInt8Unsigned(self.id)  -- { 成就子ID}
end

function REQ_ACHIEVE_GET_REWARD.setArgs(self,type,id)
    self.type = type  -- { 成就ID}
    self.id = id  -- { 成就子ID}
end

-- [41550]请求成就角标 -- 成就系统 
REQ_ACHIEVE_REQ_POINT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ACHIEVE_REQ_POINT
    self:init(0, nil)
end)

-- [41610]请求界面 -- 节日活动-金钱副本 
REQ_COPY_MONEY_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_MONEY_REQUEST
    self:init(0, nil)
end)

-- [41630]开始挑战 -- 节日活动-金钱副本 
REQ_COPY_MONEY_START_WAR = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COPY_MONEY_START_WAR
    self:init(0, nil)
end)

-- [42510]查询是否有卡片活动 -- 收集卡片 
REQ_COLLECT_CARD_ASK_LIMIT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COLLECT_CARD_ASK_LIMIT
    self:init(0, nil)
end)

-- [42520]请求卡片套装和奖励数据 -- 收集卡片 
REQ_COLLECT_CARD_ASK_DATA = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COLLECT_CARD_ASK_DATA
    self:init(0, nil)
end)

-- [42530]请求兑换卡片套装奖励 -- 收集卡片 
REQ_COLLECT_CARD_EXCHANGE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COLLECT_CARD_EXCHANGE
    self:init(0, nil)
end)

function REQ_COLLECT_CARD_EXCHANGE.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 0:普通|1:金元兑换}
    w:writeInt16Unsigned(self.id)  -- { 卡片套装ID}
end

function REQ_COLLECT_CARD_EXCHANGE.setArgs(self,type,id)
    self.type = type  -- { 0:普通|1:金元兑换}
    self.id = id  -- { 卡片套装ID}
end

-- [42540]请求兑换所需金元 -- 收集卡片 
REQ_COLLECT_CARD_EXCHANGE_COST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_COLLECT_CARD_EXCHANGE_COST
    self:init(0, nil)
end)

function REQ_COLLECT_CARD_EXCHANGE_COST.encode(self, w)
    w:writeInt16Unsigned(self.id	)  -- { 卡片套装ID}
end

function REQ_COLLECT_CARD_EXCHANGE_COST.setArgs(self,id	)
    self.id	 = id	  -- { 卡片套装ID}
end

-- [43510]请求问鼎天宫 -- 跨服战 
REQ_STRIDE_ENJOY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_STRIDE_ENJOY
    self:init(0, nil)
end)

function REQ_STRIDE_ENJOY.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1:问鼎天宫 2:凌霄 3 :独尊}
end

function REQ_STRIDE_ENJOY.setArgs(self,type)
    self.type = type  -- { 1:问鼎天宫 2:凌霄 3 :独尊}
end

-- [43540]请求排行榜 -- 跨服战 
REQ_STRIDE_RANK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_STRIDE_RANK
    self:init(0, nil)
end)

function REQ_STRIDE_RANK.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 见常量CONST_OVER_SERVER_STRIDE_TYPR_*}
end

function REQ_STRIDE_RANK.setArgs(self,type)
    self.type = type  -- { 见常量CONST_OVER_SERVER_STRIDE_TYPR_*}
end

-- [43545]请求挑战列表 -- 跨服战 
REQ_STRIDE_ASK_RANK_DATA = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_STRIDE_ASK_RANK_DATA
    self:init(0, nil)
end)

function REQ_STRIDE_ASK_RANK_DATA.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { (5,6)见常量CONST_OVER_SERVER_STRIDE_TYPR_*}
end

function REQ_STRIDE_ASK_RANK_DATA.setArgs(self,type)
    self.type = type  -- { (5,6)见常量CONST_OVER_SERVER_STRIDE_TYPR_*}
end

-- [43553]领取宝箱 -- 跨服战 
REQ_STRIDE_AWARD_NUM = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_STRIDE_AWARD_NUM
    self:init(0, nil)
end)

function REQ_STRIDE_AWARD_NUM.encode(self, w)
    w:writeInt8Unsigned(self.cenci)  -- { 宝箱层次编号}
end

function REQ_STRIDE_AWARD_NUM.setArgs(self,cenci)
    self.cenci = cenci  -- { 宝箱层次编号}
end

-- [43620]请求挑战 -- 跨服战 
REQ_STRIDE_ASK_POWER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_STRIDE_ASK_POWER
    self:init(0, nil)
end)

function REQ_STRIDE_ASK_POWER.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid}
end

function REQ_STRIDE_ASK_POWER.setArgs(self,uid)
    self.uid = uid  -- { 玩家uid}
end

-- [43630]挑战--问鼎天宫 -- 跨服战 
REQ_STRIDE_STRIDE_WAR = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_STRIDE_STRIDE_WAR
    self:init(0, nil)
end)

function REQ_STRIDE_STRIDE_WAR.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 5:常规模式 6:越级模式}
    w:writeInt32Unsigned(self.uid)  -- { 玩家UID}
    w:writeString(self.key)  -- { 验证字符串}
end

function REQ_STRIDE_STRIDE_WAR.setArgs(self,type,uid,key)
    self.type = type  -- { 5:常规模式 6:越级模式}
    self.uid = uid  -- { 玩家UID}
    self.key = key  -- { 验证字符串}
end

-- [43631]挑战结束--问鼎天宫 -- 跨服战 
REQ_STRIDE_WAR_OVER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_STRIDE_WAR_OVER
    self:init(0, nil)
end)

function REQ_STRIDE_WAR_OVER.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 5:常规模式 6:越级模式}
    w:writeInt16Unsigned(self.sid)  -- { 服务器id}
    w:writeInt32Unsigned(self.uid)  -- { 被挑战者uid}
    w:writeInt8Unsigned(self.res)  -- { 0:失败 1:成功}
    w:writeString(self.key)  -- { 验证字符串}
end

function REQ_STRIDE_WAR_OVER.setArgs(self,type,sid,uid,res,key)
    self.type = type  -- { 5:常规模式 6:越级模式}
    self.sid = sid  -- { 服务器id}
    self.uid = uid  -- { 被挑战者uid}
    self.res = res  -- { 0:失败 1:成功}
    self.key = key  -- { 验证字符串}
end

-- [43634]挑战--决战凌霄 -- 跨服战 
REQ_STRIDE_SUPERIOR_WAR = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_STRIDE_SUPERIOR_WAR
    self:init(0, nil)
end)

function REQ_STRIDE_SUPERIOR_WAR.encode(self, w)
    w:writeInt16Unsigned(self.rank)  -- { 被挑战者的排名}
    w:writeString(self.key)  -- { 验证字符串}
end

function REQ_STRIDE_SUPERIOR_WAR.setArgs(self,rank,key)
    self.rank = rank  -- { 被挑战者的排名}
    self.key = key  -- { 验证字符串}
end

-- [43636]挑战结束--决战凌霄 -- 跨服战 
REQ_STRIDE_SUPERIOR_OVER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_STRIDE_SUPERIOR_OVER
    self:init(0, nil)
end)

function REQ_STRIDE_SUPERIOR_OVER.encode(self, w)
    w:writeInt16Unsigned(self.rank)  -- { 排名}
    w:writeInt8Unsigned(self.res)  -- { 0:失败 1:成功}
    w:writeString(self.key)  -- { 验证字符串}
end

function REQ_STRIDE_SUPERIOR_OVER.setArgs(self,rank,res,key)
    self.rank = rank  -- { 排名}
    self.res = res  -- { 0:失败 1:成功}
    self.key = key  -- { 验证字符串}
end

-- [43650]购买越级挑战 -- 跨服战 
REQ_STRIDE_STRIDE_UP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_STRIDE_STRIDE_UP
    self:init(0, nil)
end)

-- [43660]购买挑战次数 -- 跨服战 
REQ_STRIDE_BUY_COUNT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_STRIDE_BUY_COUNT
    self:init(0, nil)
end)

function REQ_STRIDE_BUY_COUNT.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1:三界挑战 2:巅峰挑战}
end

function REQ_STRIDE_BUY_COUNT.setArgs(self,type)
    self.type = type  -- { 1:三界挑战 2:巅峰挑战}
end

-- [44510]请求答题面板 -- 御前科举 
REQ_KEJU_ASK_KEJU = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_KEJU_ASK_KEJU
    self:init(0, nil)
end)

-- [44550]开始答题 -- 御前科举 
REQ_KEJU_START = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_KEJU_START
    self:init(0, nil)
end)

-- [44562]答题 -- 御前科举 
REQ_KEJU_ANSWER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_KEJU_ANSWER
    self:init(0, nil)
end)

function REQ_KEJU_ANSWER.encode(self, w)
    w:writeInt8Unsigned(self.choose)  -- { 玩家选择答案}
end

function REQ_KEJU_ANSWER.setArgs(self,choose)
    self.choose = choose  -- { 玩家选择答案}
end

-- [44570]算卦去错 -- 御前科举 
REQ_KEJU_OUT_WRONG = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_KEJU_OUT_WRONG
    self:init(0, nil)
end)

-- [44580]贿赂考官 -- 御前科举 
REQ_KEJU_BRIBE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_KEJU_BRIBE
    self:init(0, nil)
end)

-- [44610]请求任务 -- 悬赏任务 
REQ_REWARD_TASK_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_REWARD_TASK_REQUEST
    self:init(0, nil)
end)

-- [44640]接受任务 -- 悬赏任务 
REQ_REWARD_TASK_ACCEPT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_REWARD_TASK_ACCEPT
    self:init(0, nil)
end)

function REQ_REWARD_TASK_ACCEPT.encode(self, w)
    w:writeInt8Unsigned(self.idx)  -- { 索引}
end

function REQ_REWARD_TASK_ACCEPT.setArgs(self,idx)
    self.idx = idx  -- { 索引}
end

-- [44650]提交领奖 -- 悬赏任务 
REQ_REWARD_TASK_SUBMIT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_REWARD_TASK_SUBMIT
    self:init(0, nil)
end)

function REQ_REWARD_TASK_SUBMIT.encode(self, w)
    w:writeInt8Unsigned(self.idx)  -- { 索引}
end

function REQ_REWARD_TASK_SUBMIT.setArgs(self,idx)
    self.idx = idx  -- { 索引}
end

-- [44660]快速完成任务 -- 悬赏任务 
REQ_REWARD_TASK_COMPLETE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_REWARD_TASK_COMPLETE
    self:init(0, nil)
end)

function REQ_REWARD_TASK_COMPLETE.encode(self, w)
    w:writeInt8Unsigned(self.idx)  -- { 索引}
end

function REQ_REWARD_TASK_COMPLETE.setArgs(self,idx)
    self.idx = idx  -- { 索引}
end

-- [44680]刷新任务 -- 悬赏任务 
REQ_REWARD_TASK_REFRESH = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_REWARD_TASK_REFRESH
    self:init(0, nil)
end)

-- [44810]进入 -- 跨服竞技场 
REQ_CROSS_JOIN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CROSS_JOIN
    self:init(0, nil)
end)

-- [44880]请求排行榜 -- 跨服竞技场 
REQ_CROSS_RANKING_LISTS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CROSS_RANKING_LISTS
    self:init(0, nil)
end)

-- [44905]请求购买次数 -- 跨服竞技场 
REQ_CROSS_ASK_BUY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CROSS_ASK_BUY
    self:init(0, nil)
end)

-- [44910]购买挑战次数 -- 跨服竞技场 
REQ_CROSS_BUY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CROSS_BUY
    self:init(0, nil)
end)

-- [44960]清除CD时间 -- 跨服竞技场 
REQ_CROSS_CLEAN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CROSS_CLEAN
    self:init(0, nil)
end)

-- [45610]请求阵营战界面 -- 活动-阵营战 
REQ_CAMPWAR_ASK_WAR = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CAMPWAR_ASK_WAR
    self:init(0, nil)
end)

-- [45680]请求振奋 -- 活动-阵营战 
REQ_CAMPWAR_ASK_BESTIR = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CAMPWAR_ASK_BESTIR
    self:init(0, nil)
end)

-- [45720]开始匹配战斗 -- 活动-阵营战 
REQ_CAMPWAR_START_MACHING = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CAMPWAR_START_MACHING
    self:init(0, nil)
end)

-- [45750]战斗结束 -- 活动-阵营战 
REQ_CAMPWAR_END_WAR = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CAMPWAR_END_WAR
    self:init(0, nil)
end)

-- [45770]复活（废） -- 活动-阵营战 
REQ_CAMPWAR_RELIVE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CAMPWAR_RELIVE
    self:init(0, nil)
end)

function REQ_CAMPWAR_RELIVE.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 复活类型1金元|0普通 0可不发}
end

function REQ_CAMPWAR_RELIVE.setArgs(self,type)
    self.type = type  -- { 复活类型1金元|0普通 0可不发}
end

-- [45790]请求退出活动 -- 活动-阵营战 
REQ_CAMPWAR_ASK_BACK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CAMPWAR_ASK_BACK
    self:init(0, nil)
end)

-- [45800]请求设置战报数据类型 -- 活动-阵营战 
REQ_CAMPWAR_ASK_WAR_DATA = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CAMPWAR_ASK_WAR_DATA
    self:init(0, nil)
end)

function REQ_CAMPWAR_ASK_WAR_DATA.encode(self, w)
    w:writeInt8Unsigned(self.wtype)  -- { 战报类型：CONST_CAMPWAR_WARDATA_TYPE_*}
end

function REQ_CAMPWAR_ASK_WAR_DATA.setArgs(self,wtype)
    self.wtype = wtype  -- { 战报类型：CONST_CAMPWAR_WARDATA_TYPE_*}
end

-- [46010]请求转盘 -- 每日转盘 
REQ_WHEEL_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WHEEL_REQUEST
    self:init(0, nil)
end)

-- [46020]开始抽奖 -- 每日转盘 
REQ_WHEEL_LOTTERY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WHEEL_LOTTERY
    self:init(0, nil)
end)

-- [46210]请求魔王副本 -- 魔王副本 
REQ_FIEND_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FIEND_REQUEST
    self:init(0, nil)
end)

function REQ_FIEND_REQUEST.encode(self, w)
    w:writeInt16Unsigned(self.chap_id)  -- { 章节ID}
end

function REQ_FIEND_REQUEST.setArgs(self,chap_id)
    self.chap_id = chap_id  -- { 章节ID}
end

-- [46215]请求全部魔王副本 -- 魔王副本 
REQ_FIEND_REQUEST_ALL = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FIEND_REQUEST_ALL
    self:init(0, nil)
end)

-- [46250]刷新魔王副本 -- 魔王副本 
REQ_FIEND_FRESH_COPY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FIEND_FRESH_COPY
    self:init(0, nil)
end)

function REQ_FIEND_FRESH_COPY.encode(self, w)
    w:writeInt16Unsigned(self.copy_id)  -- { 副本ID}
end

function REQ_FIEND_FRESH_COPY.setArgs(self,copy_id)
    self.copy_id = copy_id  -- { 副本ID}
end

-- [47201]请求珍宝 -- 珍宝阁 
REQ_TREASURE_LEVEL_ID = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TREASURE_LEVEL_ID
    self:init(0, nil)
end)

-- [47220]物品打造数据请求 -- 珍宝阁 
REQ_TREASURE_GOODS_ID = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TREASURE_GOODS_ID
    self:init(0, nil)
end)

function REQ_TREASURE_GOODS_ID.encode(self, w)
    w:writeInt32Unsigned(self.goods_id)  -- { 物品id}
end

function REQ_TREASURE_GOODS_ID.setArgs(self,goods_id)
    self.goods_id = goods_id  -- { 物品id}
end

-- [48210]请求占卦界面 -- 八卦系统 
REQ_SYS_DOUQI_ASK_GRASP_DOUQI = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SYS_DOUQI_ASK_GRASP_DOUQI
    self:init(0, nil)
end)

-- [48211]请求开始占卦 -- 八卦系统 
REQ_SYS_DOUQI_ASK_START_GRASP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SYS_DOUQI_ASK_START_GRASP
    self:init(0, nil)
end)

function REQ_SYS_DOUQI_ASK_START_GRASP.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型CONST_DOUQI_GRASP_TYPE_*}
end

function REQ_SYS_DOUQI_ASK_START_GRASP.setArgs(self,type)
    self.type = type  -- { 类型CONST_DOUQI_GRASP_TYPE_*}
end

-- [48230]请求装备卦象界面 -- 八卦系统 
REQ_SYS_DOUQI_ASK_USR_GRASP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SYS_DOUQI_ASK_USR_GRASP
    self:init(0, nil)
end)

-- [48235]请求玩家已装备的卦象 -- 八卦系统 
REQ_SYS_DOUQI_OTHER_USR_GRASP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SYS_DOUQI_OTHER_USR_GRASP
    self:init(0, nil)
end)

function REQ_SYS_DOUQI_OTHER_USR_GRASP.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid}
end

function REQ_SYS_DOUQI_OTHER_USR_GRASP.setArgs(self,uid)
    self.uid = uid  -- { 玩家uid}
end

-- [48280]请求一键吞噬 -- 八卦系统 
REQ_SYS_DOUQI_ASK_EAT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SYS_DOUQI_ASK_EAT
    self:init(0, nil)
end)

function REQ_SYS_DOUQI_ASK_EAT.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型 CONST_DOUQI_STORAGE_TYPE_*}
end

function REQ_SYS_DOUQI_ASK_EAT.setArgs(self,type)
    self.type = type  -- { 类型 CONST_DOUQI_STORAGE_TYPE_*}
end

-- [48300]请求拾取卦象 -- 八卦系统 
REQ_SYS_DOUQI_ASK_GET_DQ = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SYS_DOUQI_ASK_GET_DQ
    self:init(0, nil)
end)

function REQ_SYS_DOUQI_ASK_GET_DQ.encode(self, w)
    w:writeInt8Unsigned(self.lan_id)  -- { 位置Id  0:一键}
end

function REQ_SYS_DOUQI_ASK_GET_DQ.setArgs(self,lan_id)
    self.lan_id = lan_id  -- { 位置Id  0:一键}
end

-- [48380]请求移动卦象位置 -- 八卦系统 
REQ_SYS_DOUQI_ASK_USE_DOUQI = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SYS_DOUQI_ASK_USE_DOUQI
    self:init(0, nil)
end)

function REQ_SYS_DOUQI_ASK_USE_DOUQI.encode(self, w)
    w:writeInt16Unsigned(self.role_id)  -- { 角色Id}
    w:writeInt32Unsigned(self.dq_id)  -- { 卦象Id}
    w:writeInt8Unsigned(self.lanid_start)  -- { 卦象起始位置}
    w:writeInt8Unsigned(self.lanid_end)  -- { 卦象目标位置}
end

function REQ_SYS_DOUQI_ASK_USE_DOUQI.setArgs(self,role_id,dq_id,lanid_start,lanid_end)
    self.role_id = role_id  -- { 角色Id}
    self.dq_id = dq_id  -- { 卦象Id}
    self.lanid_start = lanid_start  -- { 卦象起始位置}
    self.lanid_end = lanid_end  -- { 卦象目标位置}
end

-- [48394]请求玩家挂阵 -- 八卦系统 
REQ_SYS_DOUQI_OTHER_CLEAR = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SYS_DOUQI_OTHER_CLEAR
    self:init(0, nil)
end)

function REQ_SYS_DOUQI_OTHER_CLEAR.encode(self, w)
    w:writeInt32Unsigned(self.tuid)  -- { 玩家uid}
    w:writeInt8Unsigned(self.role_id)  -- { 伙伴ID | 0 自己}
end

function REQ_SYS_DOUQI_OTHER_CLEAR.setArgs(self,tuid,role_id)
    self.tuid = tuid  -- { 玩家uid}
    self.role_id = role_id  -- { 伙伴ID | 0 自己}
end

-- [48395]请求卦阵 -- 八卦系统 
REQ_SYS_DOUQI_ASK_CLEAR = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SYS_DOUQI_ASK_CLEAR
    self:init(0, nil)
end)

function REQ_SYS_DOUQI_ASK_CLEAR.encode(self, w)
    w:writeInt8Unsigned(self.role_id)  -- { 伙伴ID | 0 自己}
end

function REQ_SYS_DOUQI_ASK_CLEAR.setArgs(self,role_id)
    self.role_id = role_id  -- { 伙伴ID | 0 自己}
end

-- [48400]请求升级卦阵 -- 八卦系统 
REQ_SYS_DOUQI_ASK_CLEAR_STORAG = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SYS_DOUQI_ASK_CLEAR_STORAG
    self:init(0, nil)
end)

function REQ_SYS_DOUQI_ASK_CLEAR_STORAG.encode(self, w)
    w:writeInt16Unsigned(self.role_id)  -- { 0:自己|1 :伙伴}
    w:writeInt8Unsigned(self.lan_id)  -- { 位置id}
end

function REQ_SYS_DOUQI_ASK_CLEAR_STORAG.setArgs(self,role_id,lan_id)
    self.role_id = role_id  -- { 0:自己|1 :伙伴}
    self.lan_id = lan_id  -- { 位置id}
end

-- [49202]请求任务数据 -- 日常任务 
REQ_DAILY_TASK_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DAILY_TASK_REQUEST
    self:init(0, nil)
end)

-- [49203]请求放弃任务 -- 日常任务 
REQ_DAILY_TASK_DROP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DAILY_TASK_DROP
    self:init(0, nil)
end)

-- [49204]领取奖励 -- 日常任务 
REQ_DAILY_TASK_REWARD = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DAILY_TASK_REWARD
    self:init(0, nil)
end)

-- [49205]vip刷新次数 -- 日常任务 
REQ_DAILY_TASK_VIP_REFRESH = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DAILY_TASK_VIP_REFRESH
    self:init(0, nil)
end)

-- [49207]一键完成日常任务 -- 日常任务 
REQ_DAILY_TASK_KEY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DAILY_TASK_KEY
    self:init(0, nil)
end)

-- [50210]请求剩余次数 -- 翻翻乐 
REQ_FLSH_TIMES_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FLSH_TIMES_REQUEST
    self:init(0, nil)
end)

-- [50230]开始游戏 -- 翻翻乐 
REQ_FLSH_GAME_START = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FLSH_GAME_START
    self:init(0, nil)
end)

-- [50261]牌的位置 -- 翻翻乐 
REQ_FLSH_CARD_POS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FLSH_CARD_POS
    self:init(0, nil)
end)

function REQ_FLSH_CARD_POS.encode(self, w)
    w:writeInt8Unsigned(self.pos)  -- { 位置}
end

function REQ_FLSH_CARD_POS.setArgs(self,pos)
    self.pos = pos  -- { 位置}
end

-- [50280]领取奖励 -- 翻翻乐 
REQ_FLSH_GET_REWARD = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FLSH_GET_REWARD
    self:init(0, nil)
end)

-- [50401]申请 等级及状态 -- 人物升级奖励 
REQ_LV_REWARD_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LV_REWARD_REQUEST
    self:init(0, nil)
end)

-- [50410]领取奖励 -- 人物升级奖励 
REQ_LV_REWARD_REWARD_GET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_LV_REWARD_REWARD_GET
    self:init(0, nil)
end)

-- [50701]请求面板或重新开始 -- 对牌 
REQ_MATCH_CARD_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MATCH_CARD_REQUEST
    self:init(0, nil)
end)

function REQ_MATCH_CARD_REQUEST.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 0为面板，1为重新开始}
end

function REQ_MATCH_CARD_REQUEST.setArgs(self,type)
    self.type = type  -- { 0为面板，1为重新开始}
end

-- [50712]翻开一张 -- 对牌 
REQ_MATCH_CARD_SIGN_CARD = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MATCH_CARD_SIGN_CARD
    self:init(0, nil)
end)

function REQ_MATCH_CARD_SIGN_CARD.encode(self, w)
    w:writeInt8Unsigned(self.pos)  -- { 位置}
end

function REQ_MATCH_CARD_SIGN_CARD.setArgs(self,pos)
    self.pos = pos  -- { 位置}
end

-- [50715]对牌 -- 对牌 
REQ_MATCH_CARD_REQUEST_MATCH = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MATCH_CARD_REQUEST_MATCH
    self:init(0, nil)
end)

function REQ_MATCH_CARD_REQUEST_MATCH.encode(self, w)
    w:writeInt8Unsigned(self.pos1)  -- { 位置1}
    w:writeInt8Unsigned(self.pos2)  -- { 位置2}
end

function REQ_MATCH_CARD_REQUEST_MATCH.setArgs(self,pos1,pos2)
    self.pos1 = pos1  -- { 位置1}
    self.pos2 = pos2  -- { 位置2}
end

-- [50725]申请偷看（1为一张，2为二张） -- 对牌 
REQ_MATCH_CARD_LOOK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MATCH_CARD_LOOK
    self:init(0, nil)
end)

function REQ_MATCH_CARD_LOOK.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1为一张，2为二张}
end

function REQ_MATCH_CARD_LOOK.setArgs(self,type)
    self.type = type  -- { 1为一张，2为二张}
end

-- [51210]请求道劫界面 -- 道劫 
REQ_HOOK_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_HOOK_REQUEST
    self:init(0, nil)
end)

-- [51230]请求副本信息 -- 道劫 
REQ_HOOK_REQUEST_MSG = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_HOOK_REQUEST_MSG
    self:init(0, nil)
end)

function REQ_HOOK_REQUEST_MSG.encode(self, w)
    w:writeInt16Unsigned(self.copy_id)  -- { 副本id}
end

function REQ_HOOK_REQUEST_MSG.setArgs(self,copy_id)
    self.copy_id = copy_id  -- { 副本id}
end

-- [52110]穿戴神羽 -- 神羽 
REQ_FEATHER_DRESS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FEATHER_DRESS
    self:init(0, nil)
end)

function REQ_FEATHER_DRESS.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 神羽ID 0:脱下}
end

function REQ_FEATHER_DRESS.setArgs(self,id)
    self.id = id  -- { 神羽ID 0:脱下}
end

-- [52120]请求神羽界面 -- 神羽 
REQ_FEATHER_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FEATHER_REQUEST
    self:init(0, nil)
end)

function REQ_FEATHER_REQUEST.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid 0:自己}
end

function REQ_FEATHER_REQUEST.setArgs(self,uid)
    self.uid = uid  -- { 玩家uid 0:自己}
end

-- [52135]神羽升级 -- 神羽 
REQ_FEATHER_LV_UP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FEATHER_LV_UP
    self:init(0, nil)
end)

function REQ_FEATHER_LV_UP.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 神羽ID}
end

function REQ_FEATHER_LV_UP.setArgs(self,id)
    self.id = id  -- { 神羽ID}
end

-- [52145]神羽升阶 -- 神羽 
REQ_FEATHER_QUALITY_UP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FEATHER_QUALITY_UP
    self:init(0, nil)
end)

function REQ_FEATHER_QUALITY_UP.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 神羽ID}
end

function REQ_FEATHER_QUALITY_UP.setArgs(self,id)
    self.id = id  -- { 神羽ID}
end

-- [52150]神羽激活 -- 神羽 
REQ_FEATHER_ACTIVATE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FEATHER_ACTIVATE
    self:init(0, nil)
end)

function REQ_FEATHER_ACTIVATE.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 神羽ID}
end

function REQ_FEATHER_ACTIVATE.setArgs(self,id)
    self.id = id  -- { 神羽ID}
end

-- [52205]请求强化面板 -- 神兵系统 
REQ_MAGIC_EQUIP_STRENG = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAGIC_EQUIP_STRENG
    self:init(0, nil)
end)

function REQ_MAGIC_EQUIP_STRENG.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 0角色/1守护}
    w:writeInt8Unsigned(self.pos)  -- { 装备索引位置}
end

function REQ_MAGIC_EQUIP_STRENG.setArgs(self,type,pos)
    self.type = type  -- { 0角色/1守护}
    self.pos = pos  -- { 装备索引位置}
end

-- [52215]请求进阶面板 -- 神兵系统 
REQ_MAGIC_EQUIP_REQUEST_ADVANCE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAGIC_EQUIP_REQUEST_ADVANCE
    self:init(0, nil)
end)

function REQ_MAGIC_EQUIP_REQUEST_ADVANCE.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 0角色/1守护}
    w:writeInt8Unsigned(self.pos)  -- { 装备索引位置}
end

function REQ_MAGIC_EQUIP_REQUEST_ADVANCE.setArgs(self,type,pos)
    self.type = type  -- { 0角色/1守护}
    self.pos = pos  -- { 装备索引位置}
end

-- [52220]强化 -- 神兵系统 
REQ_MAGIC_EQUIP_ENHANCED = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAGIC_EQUIP_ENHANCED
    self:init(0, nil)
end)

function REQ_MAGIC_EQUIP_ENHANCED.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型（0角色/1守护)}
    w:writeInt8Unsigned(self.pos)  -- { 装备位置}
    w:writeInt8Unsigned(self.bless)  -- { 是否使用祝福石1是，0否}
    w:writeInt8Unsigned(self.protection)  -- { 是否使用保护符1是0否}
end

function REQ_MAGIC_EQUIP_ENHANCED.setArgs(self,type,pos,bless,protection)
    self.type = type  -- { 类型（0角色/1守护)}
    self.pos = pos  -- { 装备位置}
    self.bless = bless  -- { 是否使用祝福石1是，0否}
    self.protection = protection  -- { 是否使用保护符1是0否}
end

-- [52225]洗练面板 -- 神兵系统 
REQ_MAGIC_EQUIP_WASH_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAGIC_EQUIP_WASH_REQUEST
    self:init(0, nil)
end)

function REQ_MAGIC_EQUIP_WASH_REQUEST.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型（0角色/1守护）}
    w:writeInt8Unsigned(self.pos)  -- { 装备位置索引}
end

function REQ_MAGIC_EQUIP_WASH_REQUEST.setArgs(self,type,pos)
    self.type = type  -- { 类型（0角色/1守护）}
    self.pos = pos  -- { 装备位置索引}
end

-- [52230]进阶 -- 神兵系统 
REQ_MAGIC_EQUIP_ADVANCE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAGIC_EQUIP_ADVANCE
    self:init(0, nil)
end)

function REQ_MAGIC_EQUIP_ADVANCE.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型（0角色/1守护)}
    w:writeInt8Unsigned(self.pos)  -- { 装备位置}
end

function REQ_MAGIC_EQUIP_ADVANCE.setArgs(self,type,pos)
    self.type = type  -- { 类型（0角色/1守护)}
    self.pos = pos  -- { 装备位置}
end

-- [52235]神器洗练 -- 神兵系统 
REQ_MAGIC_EQUIP_WASH = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAGIC_EQUIP_WASH
    self:init(0, nil)
end)

function REQ_MAGIC_EQUIP_WASH.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型（0角色/1守护)}
    w:writeInt8Unsigned(self.pos)  -- { 装备位置索引}
end

function REQ_MAGIC_EQUIP_WASH.setArgs(self,type,pos)
    self.type = type  -- { 类型（0角色/1守护)}
    self.pos = pos  -- { 装备位置索引}
end

-- [52237]洗练保存 -- 神兵系统 
REQ_MAGIC_EQUIP_WASH_SAVE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAGIC_EQUIP_WASH_SAVE
    self:init(0, nil)
end)

function REQ_MAGIC_EQUIP_WASH_SAVE.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型（0角色/1守护）}
    w:writeInt8Unsigned(self.pos)  -- { 装备位置索引}
end

function REQ_MAGIC_EQUIP_WASH_SAVE.setArgs(self,type,pos)
    self.type = type  -- { 类型（0角色/1守护）}
    self.pos = pos  -- { 装备位置索引}
end

-- [52250]需要多少钱 -- 神兵系统 
REQ_MAGIC_EQUIP_NEED_MONEY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAGIC_EQUIP_NEED_MONEY
    self:init(0, nil)
end)

function REQ_MAGIC_EQUIP_NEED_MONEY.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 容器类型(背包还是在武将身上)}
    w:writeInt32Unsigned(self.id)  -- { 人物id}
    w:writeInt16Unsigned(self.idx)  -- { 神器idx}
    w:writeInt8Unsigned(self.is_bless)  -- { 是否使用祝福石}
    w:writeInt8Unsigned(self.is_protect)  -- { 是否使用保护符}
end

function REQ_MAGIC_EQUIP_NEED_MONEY.setArgs(self,type,id,idx,is_bless,is_protect)
    self.type = type  -- { 容器类型(背包还是在武将身上)}
    self.id = id  -- { 人物id}
    self.idx = idx  -- { 神器idx}
    self.is_bless = is_bless  -- { 是否使用祝福石}
    self.is_protect = is_protect  -- { 是否使用保护符}
end

-- [52300]请求下一级神器 -- 神兵系统 
REQ_MAGIC_EQUIP_ASK_NEXT_ATTR = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAGIC_EQUIP_ASK_NEXT_ATTR
    self:init(0, nil)
end)

function REQ_MAGIC_EQUIP_ASK_NEXT_ATTR.encode(self, w)
    w:writeInt8Unsigned(self.type_sub)  -- { 神器子类}
    w:writeInt8Unsigned(self.lv)  -- { 等级}
    w:writeInt8Unsigned(self.color)  -- { 颜色}
    w:writeInt8Unsigned(self.class)  -- { 等阶}
end

function REQ_MAGIC_EQUIP_ASK_NEXT_ATTR.setArgs(self,type_sub,lv,color,class)
    self.type_sub = type_sub  -- { 神器子类}
    self.lv = lv  -- { 等级}
    self.color = color  -- { 颜色}
    self.class = class  -- { 等阶}
end

-- [52330]请求幻化界面 -- 神兵系统 
REQ_MAGIC_EQUIP_REQUEST_HUANHUA = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAGIC_EQUIP_REQUEST_HUANHUA
    self:init(0, nil)
end)

function REQ_MAGIC_EQUIP_REQUEST_HUANHUA.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型 1时装，2翅膀}
end

function REQ_MAGIC_EQUIP_REQUEST_HUANHUA.setArgs(self,type)
    self.type = type  -- { 类型 1时装，2翅膀}
end

-- [52360]开始幻化 -- 神兵系统 
REQ_MAGIC_EQUIP_HUANHUA = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAGIC_EQUIP_HUANHUA
    self:init(0, nil)
end)

function REQ_MAGIC_EQUIP_HUANHUA.encode(self, w)
    w:writeInt16Unsigned(self.idx)  -- { 神器容器Idx}
    w:writeInt16Unsigned(self.id)  -- { 要幻化成的神器Id}
    w:writeInt8Unsigned(self.type)  -- { 类型 1时装，2翅膀}
end

function REQ_MAGIC_EQUIP_HUANHUA.setArgs(self,idx,id,type)
    self.idx = idx  -- { 神器容器Idx}
    self.id = id  -- { 要幻化成的神器Id}
    self.type = type  -- { 类型 1时装，2翅膀}
end

-- [52370]请求当前身上时装和翅膀 -- 神兵系统 
REQ_MAGIC_EQUIP_REQUEST_SKINS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAGIC_EQUIP_REQUEST_SKINS
    self:init(0, nil)
end)

function REQ_MAGIC_EQUIP_REQUEST_SKINS.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家id 自己为0}
end

function REQ_MAGIC_EQUIP_REQUEST_SKINS.setArgs(self,uid)
    self.uid = uid  -- { 玩家id 自己为0}
end

-- [52400]请求神器界面 -- 神兵系统 
REQ_MAGIC_EQUIP_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAGIC_EQUIP_REQUEST
    self:init(0, nil)
end)

-- [52410]请求单个神兵 -- 神兵系统 
REQ_MAGIC_EQUIP_REQUEST_ONE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAGIC_EQUIP_REQUEST_ONE
    self:init(0, nil)
end)

function REQ_MAGIC_EQUIP_REQUEST_ONE.encode(self, w)
    w:writeInt32Unsigned(self.idx)  -- { 神兵Idx}
end

function REQ_MAGIC_EQUIP_REQUEST_ONE.setArgs(self,idx)
    self.idx = idx  -- { 神兵Idx}
end

-- [52420]使用神兵 -- 神兵系统 
REQ_MAGIC_EQUIP_USE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAGIC_EQUIP_USE
    self:init(0, nil)
end)

function REQ_MAGIC_EQUIP_USE.encode(self, w)
    w:writeInt32Unsigned(self.idx)  -- { 神兵idx(0卸下)}
end

function REQ_MAGIC_EQUIP_USE.setArgs(self,idx)
    self.idx = idx  -- { 神兵idx(0卸下)}
end

-- [53210]请求三国基金面板 -- 三国基金 
REQ_PRIVILEGE_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_PRIVILEGE_REQUEST
    self:init(0, nil)
end)

function REQ_PRIVILEGE_REQUEST.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型（2为平民，3为土豪）}
end

function REQ_PRIVILEGE_REQUEST.setArgs(self,type)
    self.type = type  -- { 类型（2为平民，3为土豪）}
end

-- [53230]开启投资理财 -- 三国基金 
REQ_PRIVILEGE_OPEN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_PRIVILEGE_OPEN
    self:init(0, nil)
end)

function REQ_PRIVILEGE_OPEN.encode(self, w)
    w:writeInt8Unsigned(self.type_id)  -- { 类型id(2为平民，3为土豪)}
end

function REQ_PRIVILEGE_OPEN.setArgs(self,type_id)
    self.type_id = type_id  -- { 类型id(2为平民，3为土豪)}
end

-- [53250]领取 -- 三国基金 
REQ_PRIVILEGE_GET_REWARDS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_PRIVILEGE_GET_REWARDS
    self:init(0, nil)
end)

function REQ_PRIVILEGE_GET_REWARDS.encode(self, w)
    w:writeInt8Unsigned(self.type_id)  -- { 类型id（2为平民，3为土豪）}
end

function REQ_PRIVILEGE_GET_REWARDS.setArgs(self,type_id)
    self.type_id = type_id  -- { 类型id（2为平民，3为土豪）}
end

-- [54220]请求开启社团BOSS -- 帮派BOSS 
REQ_CLAN_BOSS_START_BOSS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_CLAN_BOSS_START_BOSS
    self:init(0, nil)
end)

-- [54810]请求三界争锋界面 -- 三界争锋 
REQ_WRESTLE_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WRESTLE_REQUEST
    self:init(0, nil)
end)

-- [54870]请求欢乐竞猜下注界面 -- 三界争锋 
REQ_WRESTLE_REQUEST_GUESS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WRESTLE_REQUEST_GUESS
    self:init(0, nil)
end)

-- [54890]欢乐竞猜下注 -- 三界争锋 
REQ_WRESTLE_GUESS_BET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WRESTLE_GUESS_BET
    self:init(0, nil)
end)

function REQ_WRESTLE_GUESS_BET.encode(self, w)
    w:writeInt32Unsigned(self.uid_1)  -- { 冠军uid}
    w:writeInt32Unsigned(self.uid_2)  -- { 亚军uid}
end

function REQ_WRESTLE_GUESS_BET.setArgs(self,uid_1,uid_2)
    self.uid_1 = uid_1  -- { 冠军uid}
    self.uid_2 = uid_2  -- { 亚军uid}
end

-- [54895]请求报名 -- 三界争锋 
REQ_WRESTLE_REQUEST_BOOK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WRESTLE_REQUEST_BOOK
    self:init(0, nil)
end)

function REQ_WRESTLE_REQUEST_BOOK.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 0请求竞技场排名1确认报名}
end

function REQ_WRESTLE_REQUEST_BOOK.setArgs(self,type)
    self.type = type  -- { 0请求竞技场排名1确认报名}
end

-- [54920]请求其他小组数据 -- 三界争锋 
REQ_WRESTLE_REQUEST_GROUP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WRESTLE_REQUEST_GROUP
    self:init(0, nil)
end)

function REQ_WRESTLE_REQUEST_GROUP.encode(self, w)
    w:writeInt8Unsigned(self.group_id)  -- { 小组ID}
end

function REQ_WRESTLE_REQUEST_GROUP.setArgs(self,group_id)
    self.group_id = group_id  -- { 小组ID}
end

-- [54930]请求我的比赛页面 -- 三界争锋 
REQ_WRESTLE_REQUEST_MY_GAME = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WRESTLE_REQUEST_MY_GAME
    self:init(0, nil)
end)

-- [54955]请求王者争霸界面 -- 三界争锋 
REQ_WRESTLE_REQUEST_KING = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_WRESTLE_REQUEST_KING
    self:init(0, nil)
end)

-- [55010]请求我的比赛页面 -- 独尊三界 
REQ_TXDY_SUPER_REQUEST_MY_GAME = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TXDY_SUPER_REQUEST_MY_GAME
    self:init(0, nil)
end)

-- [55020]请求独尊三界界面 -- 独尊三界 
REQ_TXDY_SUPER_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TXDY_SUPER_REQUEST
    self:init(0, nil)
end)

function REQ_TXDY_SUPER_REQUEST.encode(self, w)
    w:writeInt8Unsigned(self.group)  -- { 组别(默认0)}
end

function REQ_TXDY_SUPER_REQUEST.setArgs(self,group)
    self.group = group  -- { 组别(默认0)}
end

-- [55045]请求王者争霸界面 -- 独尊三界 
REQ_TXDY_SUPER_REQUEST_KING = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TXDY_SUPER_REQUEST_KING
    self:init(0, nil)
end)

-- [55065]请求竞猜榜 -- 独尊三界 
REQ_TXDY_SUPER_REQUEST_GUESS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TXDY_SUPER_REQUEST_GUESS
    self:init(0, nil)
end)

-- [55080]欢乐竞猜下注 -- 独尊三界 
REQ_TXDY_SUPER_GUESS_BET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TXDY_SUPER_GUESS_BET
    self:init(0, nil)
end)

function REQ_TXDY_SUPER_GUESS_BET.encode(self, w)
    w:writeInt32Unsigned(self.uid_1)  -- { 冠军uid}
    w:writeInt32Unsigned(self.uid_2)  -- { 亚军uid}
end

function REQ_TXDY_SUPER_GUESS_BET.setArgs(self,uid_1,uid_2)
    self.uid_1 = uid_1  -- { 冠军uid}
    self.uid_2 = uid_2  -- { 亚军uid}
end

-- [55090]请求欢乐竞猜下注界面 -- 独尊三界 
REQ_TXDY_SUPER_GUESS_BET_REQ = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TXDY_SUPER_GUESS_BET_REQ
    self:init(0, nil)
end)

-- [55120]请求三界界主 -- 独尊三界 
REQ_TXDY_SUPER_REQUEST_FIRST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_TXDY_SUPER_REQUEST_FIRST
    self:init(0, nil)
end)

-- [55310]请求准备界面 -- 一骑当千 
REQ_THOUSAND_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_THOUSAND_REQUEST
    self:init(0, nil)
end)

-- [55350]请求购买页面 -- 一骑当千 
REQ_THOUSAND_REQUEST_BUY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_THOUSAND_REQUEST_BUY
    self:init(0, nil)
end)

-- [55370]确认购买 -- 一骑当千 
REQ_THOUSAND_BUY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_THOUSAND_BUY
    self:init(0, nil)
end)

-- [55450]请求排行榜 -- 一骑当千 
REQ_THOUSAND_REQUEST_RANK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_THOUSAND_REQUEST_RANK
    self:init(0, nil)
end)

-- [55465]点击说明-完成任务指引 -- 一骑当千 
REQ_THOUSAND_TASK_FINISH = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_THOUSAND_TASK_FINISH
    self:init(0, nil)
end)

-- [55810]请求拳皇信息 -- 拳皇生涯 
REQ_FIGHTERS_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FIGHTERS_REQUEST
    self:init(0, nil)
end)

function REQ_FIGHTERS_REQUEST.encode(self, w)
    w:writeInt16Unsigned(self.chap_id)  -- { 章节ID}
end

function REQ_FIGHTERS_REQUEST.setArgs(self,chap_id)
    self.chap_id = chap_id  -- { 章节ID}
end

-- [55860]开始挂机 -- 拳皇生涯 
REQ_FIGHTERS_UP_START = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FIGHTERS_UP_START
    self:init(0, nil)
end)

-- [55960]重置挂机 -- 拳皇生涯 
REQ_FIGHTERS_UP_RESET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_FIGHTERS_UP_RESET
    self:init(0, nil)
end)

-- [56810]勾选功能 -- 系统设置 
REQ_SYS_SET_CHECK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SYS_SET_CHECK
    self:init(0, nil)
end)

function REQ_SYS_SET_CHECK.encode(self, w)
    w:writeInt16Unsigned(self.type)  -- { 类型}
end

function REQ_SYS_SET_CHECK.setArgs(self,type)
    self.type = type  -- { 类型}
end

-- [56840]领取奖励(微信) -- 系统设置 
REQ_SYS_SET_WX_REPLY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SYS_SET_WX_REPLY
    self:init(0, nil)
end)

-- [56845]请求微信奖励 -- 系统设置 
REQ_SYS_SET_WX_ASK = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_SYS_SET_WX_ASK
    self:init(0, nil)
end)

-- [57810]请求阵法信息 -- 阵法系统 
REQ_MATRIX_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MATRIX_REQUEST
    self:init(0, nil)
end)

function REQ_MATRIX_REQUEST.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid 0:自己}
end

function REQ_MATRIX_REQUEST.setArgs(self,uid)
    self.uid = uid  -- { 玩家uid 0:自己}
end

-- [57830]点亮节点 -- 阵法系统 
REQ_MATRIX_LIGHTS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MATRIX_LIGHTS
    self:init(0, nil)
end)

-- [57850]阵法升阶 -- 阵法系统 
REQ_MATRIX_UP_GRADE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MATRIX_UP_GRADE
    self:init(0, nil)
end)

-- [57855]自动升阶 -- 阵法系统 
REQ_MATRIX_AUTOMATIC = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MATRIX_AUTOMATIC
    self:init(0, nil)
end)

-- [57870]激活高阶阵法技能 -- 阵法系统 
REQ_MATRIX_OPEN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MATRIX_OPEN
    self:init(0, nil)
end)

function REQ_MATRIX_OPEN.encode(self, w)
    w:writeInt16Unsigned(self.skill_id)  -- { 高阶技能id}
end

function REQ_MATRIX_OPEN.setArgs(self,skill_id)
    self.skill_id = skill_id  -- { 高阶技能id}
end

-- [58001]请求月卡信息 -- 月卡 
REQ_YUEKA_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_YUEKA_REQUEST
    self:init(0, nil)
end)

-- [58025]领取月卡奖励 -- 月卡 
REQ_YUEKA_GET_REWARDS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_YUEKA_GET_REWARDS
    self:init(0, nil)
end)

function REQ_YUEKA_GET_REWARDS.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型}
    w:writeInt8Unsigned(self.idx)  -- { 位置}
end

function REQ_YUEKA_GET_REWARDS.setArgs(self,type,idx)
    self.type = type  -- { 类型}
    self.idx = idx  -- { 位置}
end

-- [58201]N日首充请求 -- N日首充 
REQ_N_CHARGE_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_N_CHARGE_REQUEST
    self:init(0, nil)
end)

-- [58203]请求第几天数据 -- N日首充 
REQ_N_CHARGE_REQUEST_N = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_N_CHARGE_REQUEST_N
    self:init(0, nil)
end)

function REQ_N_CHARGE_REQUEST_N.encode(self, w)
    w:writeInt8Unsigned(self.n_day)  -- { 第几天}
end

function REQ_N_CHARGE_REQUEST_N.setArgs(self,n_day)
    self.n_day = n_day  -- { 第几天}
end

-- [58210]领取 -- N日首充 
REQ_N_CHARGE_GET_REWARDS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_N_CHARGE_GET_REWARDS
    self:init(0, nil)
end)

-- [58310]领取 -- 抢红包 
REQ_HONGBAO_GET_REWARDS = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_HONGBAO_GET_REWARDS
    self:init(0, nil)
end)

function REQ_HONGBAO_GET_REWARDS.encode(self, w)
    w:writeInt32Unsigned(self.idx)  -- { 唯一标识符}
end

function REQ_HONGBAO_GET_REWARDS.setArgs(self,idx)
    self.idx = idx  -- { 唯一标识符}
end

-- [58401]请求转盘（放回） -- 精彩活动转盘 
REQ_ART_ZHUANPAN_REQUEST_UNLIMIT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ART_ZHUANPAN_REQUEST_UNLIMIT
    self:init(0, nil)
end)

function REQ_ART_ZHUANPAN_REQUEST_UNLIMIT.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 活动id}
end

function REQ_ART_ZHUANPAN_REQUEST_UNLIMIT.setArgs(self,id)
    self.id = id  -- { 活动id}
end

-- [58405]抽奖(放回) -- 精彩活动转盘 
REQ_ART_ZHUANPAN_LOTTERY_UNLIMIT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ART_ZHUANPAN_LOTTERY_UNLIMIT
    self:init(0, nil)
end)

function REQ_ART_ZHUANPAN_LOTTERY_UNLIMIT.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 活动Id}
end

function REQ_ART_ZHUANPAN_LOTTERY_UNLIMIT.setArgs(self,id)
    self.id = id  -- { 活动Id}
end

-- [58407]抽奖十次(放回) -- 精彩活动转盘 
REQ_ART_ZHUANPAN_LOTTERY_TEN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ART_ZHUANPAN_LOTTERY_TEN
    self:init(0, nil)
end)

function REQ_ART_ZHUANPAN_LOTTERY_TEN.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 活动Id}
end

function REQ_ART_ZHUANPAN_LOTTERY_TEN.setArgs(self,id)
    self.id = id  -- { 活动Id}
end

-- [58410]请求转盘（不放回） -- 精彩活动转盘 
REQ_ART_ZHUANPAN_REQUEST_LIMIT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ART_ZHUANPAN_REQUEST_LIMIT
    self:init(0, nil)
end)

function REQ_ART_ZHUANPAN_REQUEST_LIMIT.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 活动id}
end

function REQ_ART_ZHUANPAN_REQUEST_LIMIT.setArgs(self,id)
    self.id = id  -- { 活动id}
end

-- [58417]抽奖（不放回） -- 精彩活动转盘 
REQ_ART_ZHUANPAN_LOTTERY_LIMIT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ART_ZHUANPAN_LOTTERY_LIMIT
    self:init(0, nil)
end)

function REQ_ART_ZHUANPAN_LOTTERY_LIMIT.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 活动id}
end

function REQ_ART_ZHUANPAN_LOTTERY_LIMIT.setArgs(self,id)
    self.id = id  -- { 活动id}
end

-- [58810]请求侠客行任务数据 -- 侠客行 
REQ_KNIGHT_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_KNIGHT_REQUEST
    self:init(0, nil)
end)

-- [58830]请求掷骰子 -- 侠客行 
REQ_KNIGHT_DO = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_KNIGHT_DO
    self:init(0, nil)
end)

-- [58840]放弃侠客行任务 -- 侠客行 
REQ_KNIGHT_DROP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_KNIGHT_DROP
    self:init(0, nil)
end)

-- [58850]提交侠客行任务 -- 侠客行 
REQ_KNIGHT_SUBMIT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_KNIGHT_SUBMIT
    self:init(0, nil)
end)

-- [58860]快速完成侠客行任务(vip金元) -- 侠客行 
REQ_KNIGHT_FAST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_KNIGHT_FAST
    self:init(0, nil)
end)

-- [59810]请求美人主界面（属性加成） -- 美人系统 
REQ_MEIREN_REQUEST_MAIN_ATT = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MEIREN_REQUEST_MAIN_ATT
    self:init(0, nil)
end)

function REQ_MEIREN_REQUEST_MAIN_ATT.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 0为自己,其他为别人}
end

function REQ_MEIREN_REQUEST_MAIN_ATT.setArgs(self,uid)
    self.uid = uid  -- { 0为自己,其他为别人}
end

-- [59830]美人缠绵面板 -- 美人系统 
REQ_MEIREN_REQUES_LINGERING = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MEIREN_REQUES_LINGERING
    self:init(0, nil)
end)

function REQ_MEIREN_REQUES_LINGERING.encode(self, w)
    w:writeInt32Unsigned(self.mid)  -- { 美人id}
    w:writeInt32Unsigned(self.uid)  -- { 0为自己,其他为别人}
end

function REQ_MEIREN_REQUES_LINGERING.setArgs(self,mid,uid)
    self.mid = mid  -- { 美人id}
    self.uid = uid  -- { 0为自己,其他为别人}
end

-- [59860]缠绵一次 -- 美人系统 
REQ_MEIREN_LINGERING = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MEIREN_LINGERING
    self:init(0, nil)
end)

function REQ_MEIREN_LINGERING.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 美人ID}
end

function REQ_MEIREN_LINGERING.setArgs(self,id)
    self.id = id  -- { 美人ID}
end

-- [59865]缠绵十次 -- 美人系统 
REQ_MEIREN_LINGERING_TEN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MEIREN_LINGERING_TEN
    self:init(0, nil)
end)

function REQ_MEIREN_LINGERING_TEN.encode(self, w)
    w:writeInt32Unsigned(self.mid)  -- { 美人id}
end

function REQ_MEIREN_LINGERING_TEN.setArgs(self,mid)
    self.mid = mid  -- { 美人id}
end

-- [59900]获得美人 -- 美人系统 
REQ_MEIREN_GET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MEIREN_GET
    self:init(0, nil)
end)

function REQ_MEIREN_GET.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 美人ID}
end

function REQ_MEIREN_GET.setArgs(self,id)
    self.id = id  -- { 美人ID}
end

-- [59920]美人跟随取消 -- 美人系统 
REQ_MEIREN_FOLLOW = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MEIREN_FOLLOW
    self:init(0, nil)
end)

function REQ_MEIREN_FOLLOW.encode(self, w)
    w:writeInt32Unsigned(self.id)  -- { 美人ID}
end

function REQ_MEIREN_FOLLOW.setArgs(self,id)
    self.id = id  -- { 美人ID}
end

-- [59930]请求亲密面板 -- 美人系统 
REQ_MEIREN_HONEY_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MEIREN_HONEY_REQUEST
    self:init(0, nil)
end)

function REQ_MEIREN_HONEY_REQUEST.encode(self, w)
    w:writeInt32Unsigned(self.mid)  -- { 美人id}
    w:writeInt8Unsigned(self.skid)  -- { 属性id}
    w:writeInt32Unsigned(self.uid)  -- { 0为自己,其他为别人}
end

function REQ_MEIREN_HONEY_REQUEST.setArgs(self,mid,skid,uid)
    self.mid = mid  -- { 美人id}
    self.skid = skid  -- { 属性id}
    self.uid = uid  -- { 0为自己,其他为别人}
end

-- [59937]请求美人亲密属性列表 -- 美人系统 
REQ_MEIREN_ATTR_LIST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MEIREN_ATTR_LIST
    self:init(0, nil)
end)

function REQ_MEIREN_ATTR_LIST.encode(self, w)
    w:writeInt32Unsigned(self.mid)  -- { 美人id}
    w:writeInt32Unsigned(self.uid)  -- { 0为自己,其他为别人}
end

function REQ_MEIREN_ATTR_LIST.setArgs(self,mid,uid)
    self.mid = mid  -- { 美人id}
    self.uid = uid  -- { 0为自己,其他为别人}
end

-- [59950]亲密一次 -- 美人系统 
REQ_MEIREN_ONE_HONEY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MEIREN_ONE_HONEY
    self:init(0, nil)
end)

function REQ_MEIREN_ONE_HONEY.encode(self, w)
    w:writeInt32Unsigned(self.mid)  -- { 美人id}
    w:writeInt16Unsigned(self.skid)  -- { 技能id}
end

function REQ_MEIREN_ONE_HONEY.setArgs(self,mid,skid)
    self.mid = mid  -- { 美人id}
    self.skid = skid  -- { 技能id}
end

-- [59955]亲密十次 -- 美人系统 
REQ_MEIREN_TEN_HONEY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MEIREN_TEN_HONEY
    self:init(0, nil)
end)

function REQ_MEIREN_TEN_HONEY.encode(self, w)
    w:writeInt32Unsigned(self.mid)  -- { 美人id}
    w:writeInt16Unsigned(self.skid)  -- { 技能id}
end

function REQ_MEIREN_TEN_HONEY.setArgs(self,mid,skid)
    self.mid = mid  -- { 美人id}
    self.skid = skid  -- { 技能id}
end

-- [60810]请求押镖信息 -- 押镖 
REQ_ESCORT_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ESCORT_REQUEST
    self:init(0, nil)
end)

-- [60823]请求可邀请好友面板 -- 押镖 
REQ_ESCORT_ASK_FRIEND = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ESCORT_ASK_FRIEND
    self:init(0, nil)
end)

function REQ_ESCORT_ASK_FRIEND.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 类型常量}
end

function REQ_ESCORT_ASK_FRIEND.setArgs(self,type)
    self.type = type  -- { 类型常量}
end

-- [60825]请求护送面板 -- 押镖 
REQ_ESCORT_ASK_HU = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ESCORT_ASK_HU
    self:init(0, nil)
end)

-- [60828]请求个人战报 -- 押镖 
REQ_ESCORT_OWN_REW = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ESCORT_OWN_REW
    self:init(0, nil)
end)

-- [60830]刷新护送美女 -- 押镖 
REQ_ESCORT_REFRESH = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ESCORT_REFRESH
    self:init(0, nil)
end)

-- [60835]直接召唤最高级美女 -- 押镖 
REQ_ESCORT_CALL_MAX = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ESCORT_CALL_MAX
    self:init(0, nil)
end)

-- [60880]开始护送 -- 押镖 
REQ_ESCORT_BEGIN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ESCORT_BEGIN
    self:init(0, nil)
end)

function REQ_ESCORT_BEGIN.encode(self, w)
    w:writeInt32Unsigned(self.fid)  -- { 邀请好友的uid 无:0}
end

function REQ_ESCORT_BEGIN.setArgs(self,fid)
    self.fid = fid  -- { 邀请好友的uid 无:0}
end

-- [60910]加速护送（直接到终点） -- 押镖 
REQ_ESCORT_ACCELERATE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ESCORT_ACCELERATE
    self:init(0, nil)
end)

-- [60930]打劫 -- 押镖 
REQ_ESCORT_ROBBERY = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ESCORT_ROBBERY
    self:init(0, nil)
end)

function REQ_ESCORT_ROBBERY.encode(self, w)
    w:writeInt32Unsigned(self.hid)  -- { 镖主uid}
end

function REQ_ESCORT_ROBBERY.setArgs(self,hid)
    self.hid = hid  -- { 镖主uid}
end

-- [60950]打劫结果 -- 押镖 
REQ_ESCORT_ROB_OVER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ESCORT_ROB_OVER
    self:init(0, nil)
end)

function REQ_ESCORT_ROB_OVER.encode(self, w)
    w:writeInt32Unsigned(self.hid)  -- { 镖主uid}
    w:writeInt8Unsigned(self.res)  -- { 0:失败 1:成功}
end

function REQ_ESCORT_ROB_OVER.setArgs(self,hid,res)
    self.hid = hid  -- { 镖主uid}
    self.res = res  -- { 0:失败 1:成功}
end

-- [60960]离开面板 -- 押镖 
REQ_ESCORT_LEAVE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_ESCORT_LEAVE
    self:init(0, nil)
end)

-- [61810]请求抽奖界面 -- 每日抽奖 
REQ_DRAW_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DRAW_REQUEST
    self:init(0, nil)
end)

-- [61830]抽奖 -- 每日抽奖 
REQ_DRAW_DRAW = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DRAW_DRAW
    self:init(0, nil)
end)

-- [62810]请求竞拍界面 -- 系统拍卖 
REQ_AUCTION_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_AUCTION_REQUEST
    self:init(0, nil)
end)

-- [62840]竞拍一下 -- 系统拍卖 
REQ_AUCTION_AUCTION = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_AUCTION_AUCTION
    self:init(0, nil)
end)

function REQ_AUCTION_AUCTION.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 物品ID}
end

function REQ_AUCTION_AUCTION.setArgs(self,id)
    self.id = id  -- { 物品ID}
end

-- [63803]分配 -- 帮派守卫战 
REQ_DEFENSE_UPORD = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DEFENSE_UPORD
    self:init(0, nil)
end)

function REQ_DEFENSE_UPORD.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 哪一组}
    w:writeInt8Unsigned(self.upd)  -- { 1 上阵 0下阵}
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid}
end

function REQ_DEFENSE_UPORD.setArgs(self,type,upd,uid)
    self.type = type  -- { 哪一组}
    self.upd = upd  -- { 1 上阵 0下阵}
    self.uid = uid  -- { 玩家uid}
end

-- [63807]查看分配信息 -- 帮派守卫战 
REQ_DEFENSE_VIEW = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DEFENSE_VIEW
    self:init(0, nil)
end)

-- [63808]请求保卫圣兽 -- 帮派守卫战 
REQ_DEFENSE_BWJM = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DEFENSE_BWJM
    self:init(0, nil)
end)

-- [63810]请求参加守卫战 -- 帮派守卫战 
REQ_DEFENSE_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DEFENSE_REQUEST
    self:init(0, nil)
end)

function REQ_DEFENSE_REQUEST.encode(self, w)
    w:writeInt8Unsigned(self.group)  -- { 组别}
end

function REQ_DEFENSE_REQUEST.setArgs(self,group)
    self.group = group  -- { 组别}
end

-- [63815]请求地图数据 -- 帮派守卫战 
REQ_DEFENSE_MAP_DATA = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DEFENSE_MAP_DATA
    self:init(0, nil)
end)

-- [63925]查看战报 -- 帮派守卫战 
REQ_DEFENSE_PRE_DATA = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DEFENSE_PRE_DATA
    self:init(0, nil)
end)

-- [64030]请求复活 -- 帮派守卫战 
REQ_DEFENSE_RESURREC = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_DEFENSE_RESURREC
    self:init(0, nil)
end)

-- [64110]请求活动界面 -- 占山为王 
REQ_HILL_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_HILL_REQUEST
    self:init(0, nil)
end)

-- [64140]请求排行榜 -- 占山为王 
REQ_HILL_TOP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_HILL_TOP
    self:init(0, nil)
end)

function REQ_HILL_TOP.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 0:洞府排行1:个人排行}
end

function REQ_HILL_TOP.setArgs(self,type)
    self.type = type  -- { 0:洞府排行1:个人排行}
end

-- [64160]请求战报 -- 占山为王 
REQ_HILL_REDIO = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_HILL_REDIO
    self:init(0, nil)
end)

-- [64190]挑战 -- 占山为王 
REQ_HILL_BATTLE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_HILL_BATTLE
    self:init(0, nil)
end)

function REQ_HILL_BATTLE.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid}
    w:writeString(self.key)  -- { 验证串}
end

function REQ_HILL_BATTLE.setArgs(self,uid,key)
    self.uid = uid  -- { 玩家uid}
    self.key = key  -- { 验证串}
end

-- [64195]请求个人加成 -- 占山为王 
REQ_HILL_ASK_ADD = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_HILL_ASK_ADD
    self:init(0, nil)
end)

function REQ_HILL_ASK_ADD.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 对手uid}
end

function REQ_HILL_ASK_ADD.setArgs(self,uid)
    self.uid = uid  -- { 对手uid}
end

-- [64200]挑战结束 -- 占山为王 
REQ_HILL_FINISH = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_HILL_FINISH
    self:init(0, nil)
end)

function REQ_HILL_FINISH.encode(self, w)
    w:writeInt32Unsigned(self.uid)  -- { 玩家uid}
    w:writeInt8Unsigned(self.res)  -- { 0:失败 1:成功}
    w:writeInt32Unsigned(self.harm)  -- { 伤害值}
    w:writeString(self.key)  -- { 验证字符}
    w:writeInt8Unsigned(self.type)  -- { 0:扣血1：加血}
end

function REQ_HILL_FINISH.setArgs(self,uid,res,harm,key,type)
    self.uid = uid  -- { 玩家uid}
    self.res = res  -- { 0:失败 1:成功}
    self.harm = harm  -- { 伤害值}
    self.key = key  -- { 验证字符}
    self.type = type  -- { 0:扣血1：加血}
end

-- [64210]清除cd -- 占山为王 
REQ_HILL_CLEAN = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_HILL_CLEAN
    self:init(0, nil)
end)

-- [64810]请求进入迷宫 -- 挑战迷宫 
REQ_MAZE_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAZE_REQUEST
    self:init(0, nil)
end)

-- [64850]请求打开兑换商店 -- 挑战迷宫 
REQ_MAZE_SHOP_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAZE_SHOP_REQUEST
    self:init(0, nil)
end)

-- [64880]开始探险 -- 挑战迷宫 
REQ_MAZE_START = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAZE_START
    self:init(0, nil)
end)

function REQ_MAZE_START.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 探险类型见常量}
end

function REQ_MAZE_START.setArgs(self,type)
    self.type = type  -- { 探险类型见常量}
end

-- [64900]兑换物品 -- 挑战迷宫 
REQ_MAZE_EXCHANGE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAZE_EXCHANGE
    self:init(0, nil)
end)

function REQ_MAZE_EXCHANGE.encode(self, w)
    w:writeInt32Unsigned(self.goods_id)  -- { 物品id}
    w:writeInt16Unsigned(self.goods_num)  -- { 兑换数量}
end

function REQ_MAZE_EXCHANGE.setArgs(self,goods_id,goods_num)
    self.goods_id = goods_id  -- { 物品id}
    self.goods_num = goods_num  -- { 兑换数量}
end

-- [65090]打开探险包裹 -- 挑战迷宫 
REQ_MAZE_OPEN_BAG = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAZE_OPEN_BAG
    self:init(0, nil)
end)

-- [65150]一键入包 -- 挑战迷宫 
REQ_MAZE_PECK_UP = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MAZE_PECK_UP
    self:init(0, nil)
end)

-- [65310]请求秘宝活动界面 -- 秘宝活动 
REQ_MIBAO_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MIBAO_REQUEST
    self:init(0, nil)
end)

-- [65330]请求进入秘宝活动场景 -- 秘宝活动 
REQ_MIBAO_ENTER = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MIBAO_ENTER
    self:init(0, nil)
end)

function REQ_MIBAO_ENTER.encode(self, w)
    w:writeInt16Unsigned(self.id)  -- { 活动ID}
end

function REQ_MIBAO_ENTER.setArgs(self,id)
    self.id = id  -- { 活动ID}
end

-- [65345]箱子请求 -- 秘宝活动 
REQ_MIBAO_BOX_REQUEST = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MIBAO_BOX_REQUEST
    self:init(0, nil)
end)

-- [65375]捡物品 -- 秘宝活动 
REQ_MIBAO_GOODS_GET = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MIBAO_GOODS_GET
    self:init(0, nil)
end)

function REQ_MIBAO_GOODS_GET.encode(self, w)
    w:writeInt32Unsigned(self.goods_idx)  -- { 物品IDX}
end

function REQ_MIBAO_GOODS_GET.setArgs(self,goods_idx)
    self.goods_idx = goods_idx  -- { 物品IDX}
end

-- [65400]玩家请求复活 -- 秘宝活动 
REQ_MIBAO_REVIVE = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MIBAO_REVIVE
    self:init(0, nil)
end)

function REQ_MIBAO_REVIVE.encode(self, w)
    w:writeInt8Unsigned(self.type)  -- { 1:立即复活 0:复活}
end

function REQ_MIBAO_REVIVE.setArgs(self,type)
    self.type = type  -- { 1:立即复活 0:复活}
end

-- [65415]进入秘宝界面-完成任务指引 -- 秘宝活动 
REQ_MIBAO_TASK_FINISH = classGc(MsgReq,function(self)
    self.MsgID = Msg.REQ_MIBAO_TASK_FINISH
    self:init(0, nil)
end)
--/** =============================== 自动生成的代码 =============================== **/
--/*************************** don't touch this line *********** AUTO_CODE_END_REQA **/