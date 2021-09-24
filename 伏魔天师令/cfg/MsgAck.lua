local MsgAck = classGc(function(self, msgid)
    self.MsgID = msgid
    self:init()
end)

function MsgAck.init(self)
    
end

function MsgAck.decode(self, r)  
    
end
--/** AUTO_CODE_BEGIN_ACKH **************** don't touch this line ********************/
--/** =============================== 自动生成的代码 =============================== **/
-- (700手动) -- [700]错误代码 -- 系统 
ACK_SYSTEM_ERROR = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYSTEM_ERROR
    self:init()
end)

function ACK_SYSTEM_ERROR.decode(self, r)
    self.error_code = r:readInt16Unsigned() -- {错误代码}
    self.arg_count = r:readInt16Unsigned() -- {错误参数数理}
    self.arg_type_select = r:readBoolean() -- {参数类型(false:整数 true:字符串)}
    self.arg_data = r:readInt32Unsigned() -- {参数数据}
    self.arg_data2 = r:readString() -- {参数数据}
end
-- end700
-- (810手动) -- [810]游戏广播 -- 系统 
ACK_SYSTEM_BROADCAST = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYSTEM_BROADCAST
    self:init()
end)

function ACK_SYSTEM_BROADCAST.decode(self, r)
    -- print("-- [810]游戏广播 -- 系统")
    self.broadcast_id = r:readInt16Unsigned()  -- {消息类型}
    self.position     = r:readInt8Unsigned()  -- {显示位置(1区,聊天|2区,喇叭|3区,广播)}
    self.msg_count    = r:readInt16Unsigned()  -- {消息数量}
    -- print("消息类型: "..self.broadcast_id.."显示位置: "..self.position.."消息数量: "..self.msg_count)
    --self.data = r:readXXXGroup() -- {霸气信息块【48203】}
    self.data = {}
    for i=1,self.msg_count do
        print("第 "..i.." 个消息:")
        local tempData = ACK_SYSTEM_DATA_XXX()
        tempData :decode( r)
        self.data[i] = tempData        
    end
end
-- end810
-- (811手动) -- [811]广播信息块 -- 系统 
ACK_SYSTEM_DATA_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYSTEM_DATA_XXX
    self:init()
end)

function ACK_SYSTEM_DATA_XXX.decode(self, r)
    print("-- [811]广播信息块 -- 系统 ")
    self.type = r :readInt8Unsigned() --见常量：CONST_BROAD_*
    print("+++++>>>> ", self.type)
    if self.type == _G.Const.CONST_BROAD_PLAYER_NAME then      --1     角色名字
        --self.sid           = r : readInt16Unsigned()  -- {服务器ID}
        self.uid           = r : readInt32Unsigned()  -- {玩家Uid}
        self.uname         = r : readString()         -- {玩家名字}     
        self.lv            = r : readInt16Unsigned()  -- {玩家等级}
        self.color_name    = r : readInt8Unsigned()   -- {玩家名字颜色}  
        self.pro           = r : readInt16Unsigned()  -- {玩家职业}
        print(" Uid:",self.uid," Name:",self.uname,"LV:",self.lv,"Coloe:",self.color_name,"Pro:",self.pro) 
    elseif self.type == _G.Const.CONST_BROAD_CLAN_NAME then    --2     家族名字
        self.clan_name     = r : readString()         -- {家族名字}        
    elseif self.type == _G.Const.CONST_BROAD_GROUP_NAME then   --3     团队名字
        self.group_name    = r : readString()         -- {团队名字}        
    elseif self.type == _G.Const.CONST_BROAD_COPY_ID then      --4     副本Id
        self.copy_id       = r : readInt16Unsigned()  -- {副本ID}        
    elseif self.type == _G.Const.CONST_BROAD_STRING then       --50    普通字符串
        self.string        = r : readString()         -- {普通字符串}        
    elseif self.type == _G.Const.CONST_BROAD_NUMBER then       --51    普通数字
        self.number        = r : readInt32Unsigned()  -- {普通数字}        
    elseif self.type == _G.Const.CONST_BROAD_MAPID then        --52    地图ID
        self.map_id        = r : readInt16Unsigned()  -- {地图ID}        
    elseif self.type == _G.Const.CONST_BROAD_COUNTRYID then    --53    阵营ID
        self.country_id    = r : readInt8Unsigned()   -- {阵营ID}        
    elseif self.type == _G.Const.CONST_BROAD_GOODSID then      --54    物品
        --self.goods       = r : readXXXGroup()       -- {物品信息块} 
        -- local tempData    = ACK_GOODS_XXX1()
        -- tempData :decode( r)
        -- self.goods        = tempData 
        self.goods_id    = r : readInt16Unsigned()   -- {物品id}          
    elseif self.type == _G.Const.CONST_BROAD_MONSTERID then    --55    怪物ID
        self.monster_id    = r : readInt16Unsigned()  -- {怪物ID}         
    elseif self.type == _G.Const.CONST_BROAD_CIRCLE_CHAP then  --56    三界杀卷名ID
        self.chap_id       = r : readInt16Unsigned()  -- {三界杀卷名}        
    elseif self.type == _G.Const.CONST_BROAD_REWARD then       --57    奖励内容
        self.gold          = r : readInt32Unsigned()  -- {银元}     
        self.rmb           = r : readInt32Unsigned()  -- {金元}        
        self.star          = r : readInt32Unsigned()  -- {星魂}        
        self.renown        = r : readInt32Unsigned()  -- {妖魂}        
        self.clan_value    = r : readInt32Unsigned()  -- {帮贡}        
        self.count         = r : readInt16Unsigned()  -- {物品数量}          
        --self.goods_msg_no  = r : readXXXGroup() -- {霸气信息块【48203】}
        self.goods_msg_no = {}  --用下标取物品
        for i=1,self.count do
            print("第 "..i.." 物品:")
            local tempData = ACK_GOODS_XXX1()
            tempData :decode( r)
            self.goods_msg_no[i] = tempData
        end       
    elseif self.type == _G.Const.CONST_BROAD_PILROAD_ID then   --58    取经之路名字
        self.pilroad_id    = r : readInt16Unsigned()  -- {取经之路id}        
    elseif self.type == _G.Const.CONST_BROAD_NAME_COLOR then   --59    名字颜色
        self.color         = r : readInt8Unsigned()   -- {名字颜色}        
    elseif self.type == _G.Const.CONST_BROAD_STARID then       --60    星阵图ID
        self.star_id       = r : readInt16Unsigned()  -- {星阵图ID}
    elseif self.type == _G.Const.CONST_BROAD_PARTNER_ID then   --61    伙伴名字
        self.partner_id    = r : readInt16Unsigned()  -- {伙伴名字}
        self.partner_color = r : readInt8Unsigned()   -- {伙伴名字颜色} 
    elseif self.type == _G.Const.CONST_BROAD_DOUQI_ID then     --62    获得霸气
        self.douqi_id      = r : readInt16Unsigned()
    elseif self.type == _G.Const.CONST_BROAD_VIP_LV then       --63    VIP等级 
        self.vip_lv        = r : readInt8Unsigned()
    elseif self.type == _G.Const.CONST_BROAD_MOUNT then       --64    坐骑id 
        self.mount_id      = r : readInt16Unsigned()
    elseif self.type == _G.Const.CONST_BROAD_MEIREN then       --65    美人ID 
        self.meiren_id      = r : readInt16Unsigned()
    elseif self.type == _G.Const.CONST_BROAD_TITLE then       --66    称号名称  
        self.title_id      = r : readInt16Unsigned()
    elseif self.type == _G.Const.CONST_BROAD_TOP then       --67    排行榜 
        self.top      = r : readInt8Unsigned()
    elseif self.type == _G.Const.CONST_BROAD_PLAYER_ID then  --70   活动名称ID
        self.sys_name = r : readString()
    else                                                          -- 未定义
        print("Error ----------- 未定义的广播常量:",self.type)        
    end
end
-- end811
-- (1107手动) -- [1107]玩家属性(查看其它玩家专用) -- 角色 
ACK_ROLE_PROPERTY_REVE2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_PROPERTY_REVE2
    self:init()
end)

function ACK_ROLE_PROPERTY_REVE2.decode(self, r)
    self.uid = r:readInt32Unsigned() -- {}
    self.name = r:readString() -- {}
    self.pro = r:readInt8Unsigned() -- {}
    self.lv = r:readInt16Unsigned() -- {}
    self.clan = r:readInt32Unsigned() -- {}
    self.clan_name = r:readString() -- {}
    self.attr = ACK_GOODS_XXX2()
    self.attr : decode( r )
    self.powerful = r:readInt32Unsigned() -- {}
    self.exp = r:readInt32Unsigned() -- {}
    self.expn = r:readInt32Unsigned() -- {}
    self.skin_weapon = r:readInt16Unsigned()
    self.skin_wing = r:readInt16Unsigned()
    self.skin_feather = r:readInt16Unsigned()
    self.power   =  r:readInt16Unsigned() 
    self.vip = r:readInt8Unsigned()
    self.count3 = r:readInt16Unsigned() -- {}
    self.magic_msg = {} -- 神器信息块 1111
    for i=1,self.count3 do
        self.magic_msg[i]=ACK_ROLE_MAGIC_MSG()
        self.magic_msg[i]:decode(r)
    end
    self.equip=ACK_GOODS_EQUIP_BACK()
    self.equip:decode(r)
    self.p_count=r:readInt8Unsigned()
    if self.p_count>0 then
        self.p_property=ACK_ROLE_PARTNER_DATA()
        self.p_property:decode(r)
        self.p_equip=ACK_GOODS_EQUIP_BACK()
        self.p_equip:decode(r)
    end
    print("ACK_ROLE_PROPERTY_REVE2========>>>>",self.skin_weapon)
end
-- end1107
-- (1108手动) -- [1108]玩家属性 -- 角色 
ACK_ROLE_PROPERTY_REVE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_PROPERTY_REVE
    self:init()
end)

function ACK_ROLE_PROPERTY_REVE.decode(self, r)
    -- print("ACK_ROLE_PROPERTY_REVE.decode")
    self.uid = r:readInt32Unsigned() -- {玩家UID}
    self.name = r:readString() -- {玩家姓名}
    self.name_color = r:readInt8Unsigned() -- {名字颜色}
    self.pro = r:readInt8Unsigned() -- {玩家职业}
    self.sex = r:readInt8Unsigned() -- {玩家性别}
    self.lv = r:readInt16Unsigned() -- {玩家等级}
    self.renown = r:readInt32Unsigned() -- {妖魂值}
    self.rank = r:readInt16Unsigned() -- {竞技排名}
    self.country = r:readInt8Unsigned() -- {阵营类型(见常量)}
    self.clan = r:readInt32Unsigned() -- {家族ID}
    self.clan_name = r:readString() -- {家族名称}
    self.clan_pro = r:readInt8Unsigned() -- {家族名称}
    self.attr = ACK_GOODS_XXX2()
    self.attr : decode( r )
    self.powerful = r:readInt32Unsigned() -- {玩家战斗力}
    self.exp = r:readInt32Unsigned() -- {经验值}
    self.expn = r:readInt32Unsigned() -- {下级要多少经验}
    self.skin_weapon = r:readInt16Unsigned() -- {武器皮肤}
    self.skin_armor = r:readInt16Unsigned() -- {衣服皮肤}
    self.skin_feather = r:readInt16Unsigned()
    self.skin_mount = r:readInt16Unsigned() -- {坐骑皮肤(0为没有)}
    self.mount_tx   = r:readInt8Unsigned()  -- {坐骑：0无特效}
    self.mount_grade = r:readInt8Unsigned() -- {坐骑等阶}
    self.skin_shape = r:readInt16Unsigned() -- {翅膀皮肤（时装）}
    self.meiren_id = r:readInt16Unsigned() -- {美人ID}    
    self.skin_wing = r:readInt16Unsigned() -- {宠物ID} 
    self.wing_press = r:readInt8Unsigned() -- {宠物等阶}   
    self.is_guide = r:readInt8Unsigned() -- {新手指导员 (0:正常状态|1:指导员)}
    self.power = r:readInt32Unsigned() -- {战功)}    
    self.count = r:readInt16Unsigned() -- {伙伴数量}
    self.partnerData = {}
    for i=1,self.count do
        self.partnerData[i] = {}
        self.partnerData[i].idx = r:readInt16Unsigned()
        self.partnerData[i].state = r:readInt8Unsigned()
    end
    self.count2 = r:readInt16Unsigned() -- {称号ID数量}
    self.title_msg = {}
    for i=1,self.count2 do
        self.title_msg[i] = ACK_SCENE_TITLE_MSG()
        self.title_msg[i] : decode( r )
        -- print("self.title_msg[i]=",self.title_msg[i].title_id)
    end
    
    self.count3 = r:readInt16Unsigned() -- {神器数量}
    self.magic_msg = {} -- 神器信息块 1111
    for i=1,self.count3 do
        self.magic_msg[i] = ACK_ROLE_MAGIC_MSG()
        self.magic_msg[i] : decode( r )
        -- print("1111self.magic_msg[i]=",self.magic_msg[i].magic_id)
    end
    
    self.magic_id = r:readInt32Unsigned() -- {神器Id}
    self.ext1 = r:readInt32Unsigned() -- {扩展1}
    self.ext2 = r:readInt32Unsigned() -- {扩展2}
    self.ext3 = r:readInt32Unsigned() -- {扩展3}
    self.ext4 = r:readInt32Unsigned() -- {扩展4}
    self.ext5 = r:readInt32Unsigned() -- {扩展5}
    
    -- for k,v in pairs(self) do
    --     print("self.",k,"=",v)
    -- end
end
-- end1108
-- (1109手动) -- [1109]伙伴属性 -- 角色 
ACK_ROLE_PARTNER_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_PARTNER_DATA
    self:init()
end)

function ACK_ROLE_PARTNER_DATA.decode(self, r)
    self.uid = r:readInt32Unsigned() -- {所属玩家Uid}
    self.partner_id = r:readInt16Unsigned() -- {伙伴ID}
    self.partner_pro = r:readInt8Unsigned() -- {伙伴职业}
    self.partner_lv = r:readInt8Unsigned() -- {伙伴等级}
    self.partner_idx = r:readInt16Unsigned() -- {经验}
    self.lock = r:readInt8Unsigned() -- {锁定}
    self.powerful = r:readInt32Unsigned() -- {战斗力}
    self.stata = r:readInt8Unsigned() -- {伙伴状态}
    --self.attr = r:readXXXGroup() -- {基础信息块2002}
    self.attr = ACK_GOODS_XXX2()
    self.attr : decode( r )
end
-- end1109
-- (1150手动) -- [1150]返回角色任务已开放系统 -- 角色 
ACK_ROLE_SYS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_SYS
    self:init()
end)

function ACK_ROLE_SYS.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    self.task_id = r:readInt32Unsigned() -- {系统ID（见常量：CONST_SYS_TASK_ID_*）}
end
-- end1150
-- (1271手动) -- [1271]开启的系统ID(新) -- 角色 
ACK_ROLE_SYS_ID_2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_SYS_ID_2
    self:init()
end)

function ACK_ROLE_SYS_ID_2.decode(self, r)
    self.count = r:readInt16Unsigned() -- {功能数量}
    self.sys_id = {}
    if self.count > 0 then
        for i=1, self.count do
            local temp = {}
            temp.number  = r:readInt8Unsigned()   -- {可玩次数}
            temp.id  = r:readInt16Unsigned()   -- {系统ID}
            temp.state = r:readInt8Unsigned()    -- {是否使用(1:使用过0:没使用)} 
            self.sys_id[temp.id]=temp
            -- print("ACK_ROLE_SYS_ID_2 -- i,number,id,state -->",i,temp.number,temp.id,temp.state)
        end
    end
end
-- end1271
-- (1355手动) -- [1355]buff数据(欲废除) -- 角色 
ACK_ROLE_BUFF_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_BUFF_DATA
    self:init()
end)

function ACK_ROLE_BUFF_DATA.decode(self, r)
    self.count = r:readInt16Unsigned() -- {buff数量}
    self.data = r:readInt16Unsigned() -- {buff的id}
end
-- end1355
-- (1360手动) -- [1360]buff数据 -- 角色 
ACK_ROLE_BUFF1_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_BUFF1_DATA
    self:init()
end)

function ACK_ROLE_BUFF1_DATA.decode(self, r)
    self.count = r:readInt16Unsigned() -- {buff数量}
    self.data = r:readXXXGroup() -- {buffs数据(1365)}
end
-- end1360
-- (1385手动) -- [1385]属性加成返回 -- 角色 
ACK_ROLE_ATTR_ADD_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_ATTR_ADD_REPLY
    self:init()
end)

function ACK_ROLE_ATTR_ADD_REPLY.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    -- self.msg_xxx = r:readXXXGroup() -- {信息块(1390)}
    self.msg_xxx = {}
    if self.count > 0 then
        for i=1,self.count do
            local tempData = ACK_ROLE_MSG_ATTR_ADD()
            tempData : decode( r)
            self.msg_xxx[i] = tempData
        end
    end
end
-- end1385
-- (1397手动) -- [1397]玩家属性(新) -- 角色 
ACK_ROLE_PRORERTY_REVENEW = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_PRORERTY_REVENEW
    self:init()
end)

function ACK_ROLE_PRORERTY_REVENEW.decode(self, r)
    self.uid = r:readInt32Unsigned() -- {玩家UID}
    self.name = r:readString() -- {玩家姓名}
    self.name_color = r:readInt8Unsigned() -- {名字颜色}
    self.pro = r:readInt8Unsigned() -- {玩家职业}
    self.sex = r:readInt8Unsigned() -- {玩家性别}
    self.lv = r:readInt16Unsigned() -- {玩家等级}
    self.renown = r:readInt32Unsigned() -- {妖魂}
    self.rank = r:readInt16Unsigned() -- {竞技排名}
    self.country = r:readInt8Unsigned() -- {阵营类型(见常量)}
    self.clan = r:readInt32Unsigned() -- {门派id}
    self.clan_name = r:readString() -- {门派名称}
    self.attr = r:readXXXGroup() -- {角色基本属性块2002}
    self.powerful = r:readInt32Unsigned() -- {玩家战斗力}
    self.exp = r:readInt32Unsigned() -- {经验值}
    self.expn = r:readInt32Unsigned() -- {下级要多少经验}
    self.skin_weapon = r:readInt16Unsigned() -- {武器皮肤}
    self.skin_armor = r:readInt16Unsigned() -- {衣服皮肤}
    self.skin_mount = r:readInt16Unsigned() -- {坐骑id(0为没有)}
    self.skin_shape = r:readInt16Unsigned() -- {翅膀皮肤（时装）}
    self.meiren_id = r:readInt16Unsigned() -- {美人ID}
    self.is_guide = r:readInt8Unsigned() -- {新手指导员 (0:正常状态|1:指导员)}
    self.power = r:readInt32Unsigned() -- {战功}
    self.count = r:readInt16Unsigned() -- {伙伴数量}
    self.partner = r:readInt16Unsigned() -- {伙伴ID}
    self.count2 = r:readInt16Unsigned() -- {称号ID数量}
    self.title_msg = r:readXXXGroup() -- {称号信息块(1110)}
    self.count3 = r:readInt16Unsigned() -- {神器数量}
    self.magic_msg = r:readXXXGroup() -- {神器信息块(1111)}
end
-- end1397
-- (1405手动) -- [1405]玩家战斗对比返回 -- 角色 
ACK_ROLE_REPLY_COMPARE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_REPLY_COMPARE
    self:init()
end)

function ACK_ROLE_REPLY_COMPARE.decode(self, r)
    self.count = r:readInt16Unsigned() -- { 数量 }
    self.powerful_xxxx = {} -- { 自己战斗力信息块 }
    for i=1,self.count do
        local msg = ACK_ROLE_POWERFUL_XXX()
        msg : decode(r)
        self.powerful_xxxx[i] = msg
    end
    self.uid = r:readInt32Unsigned() -- { 对手uid }
    self.name = r:readString() -- { 对比玩家名字 }
    self.lv  = r:readInt16Unsigned() -- { 对比玩家等级 }
    self.pro = r:readInt8Unsigned() -- { 对比玩家职业 }
    self.vip_lv = r:readInt8Unsigned() -- { 对比玩家vip等级 }
    self.count2 = r:readInt16Unsigned() -- { 数量 }
    self.powerful_xxxx2 = {} -- { 对比玩家战斗力信息块 }
    for i=1,self.count2 do
        local msg = ACK_ROLE_POWERFUL_XXX()
        msg : decode(r)
        self.powerful_xxxx2[i] = msg
    end
end
-- end1405
-- (1432手动) -- [1432]系统标点(切换守护专用) -- 角色 
ACK_ROLE_SYS_POINTS_INN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_SYS_POINTS_INN
    self:init()
end)

function ACK_ROLE_SYS_POINTS_INN.decode(self, r)
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.msg_xxx = {} -- { 信息块(1433) }
    for i=1,self.count do
        local msg = ACK_ROLE_MSG_LINGYAO()
        msg : decode(r)
        self.msg_xxx[i] = msg
    end
end
-- end1432
-- (2001手动) -- [2001]物品信息块 -- 物品/背包 
ACK_GOODS_XXX1 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_XXX1
    self:init()
end)

function ACK_GOODS_XXX1.decode(self, r)
    self.is_data     = r: readBoolean()
    self.index       = r: readInt16Unsigned()
    self.goods_id    = r: readInt16Unsigned()
    self.goods_num   = r: readInt32Unsigned()
    self.expiry      = r: readInt32Unsigned()
    self.time        = r: readInt32Unsigned()
    self.price       = r: readInt32Unsigned()
    self.goods_type  = r: readInt8Unsigned()
    -- print(" 物品ID:"..self.goods_id.."索引Index:"..self.index.."数量:"..self.goods_num.."价格:"..self.price)
    
    if self.goods_type == _G.Const.CONST_GOODS_EQUIP or self.goods_type == _G.Const.CONST_GOODS_WEAPON or self.goods_type == _G.Const.CONST_GOODS_MAGIC then   --装备大类 1 2 5
        self.powerful    = r: readInt32Unsigned()
        self.star        = r: readInt8Unsigned()
        self.pearl_score = r: readInt32Unsigned()
        self.suit_id     = r: readInt16Unsigned()
        self.wskill_id   = r: readInt16Unsigned()

        -- 神器专用,其他装备走部位的
        self.strengthen = r: readInt8Unsigned()
        self.attr_count = r: readInt16Unsigned()

        self.attr_data  = {}
        for i=1,self.attr_count do
            local tempData = ACK_GOODS_ATTR_BASE()
            tempData : decode(r)
            self.attr_data[i] = tempData
        end

        self.plus_count  = r: readInt16Unsigned()
        self.plus_msg_no = {}
        for i=1,self.plus_count do
            -- print("第 "..i.." 个附加属性:")
            local tempData = ACK_GOODS_XXX4()
            tempData :decode( r)
            self.plus_msg_no[i] = tempData
        end
        
        -- self.slots_count = r: readInt16Unsigned()
        -- local icount3 = 1
        -- self.slot_group = {}
        -- while icount3 <= self.slots_count do
        --     -- print("第 "..icount3.." 个插槽属性:")
        --     local tempData = ACK_GOODS_XXX3()
        --     tempData :decode( r)
        --     self.slot_group[icount3] = tempData
        --     icount3 = icount3 + 1
        -- end
        self.fumo  = r: readInt16Unsigned()
        self.fumoz = r: readInt16Unsigned()
        self.fumov = r: readInt32Unsigned()
        -- print("###############################################", self.fumo, self.fumoz)
    else --非装备
        self.attr1      = r: readInt32Unsigned()
        self.attr2      = r: readInt32Unsigned()
        self.attr3      = r: readInt32Unsigned()
        self.attr4      = r: readInt32Unsigned()
    end --if
end
-- end2001
-- (2002手动) -- [2002]属性信息块 -- 物品/背包 
ACK_GOODS_XXX2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_XXX2
    self:init()
end)

function ACK_GOODS_XXX2.decode(self, r)
    self.is_data = r:readBoolean() -- {是否有数据 false:没 true:有}
    self.sp = r:readInt16Unsigned() -- {怒气}
    self.hp = r:readInt32Unsigned() -- {气血}
    self.att = r:readInt32Unsigned() -- {攻击}
    self.def = r:readInt32Unsigned() -- {防御}
    self.wreck = r:readInt32Unsigned() -- {破甲}
    self.hit = r:readInt32Unsigned() -- {命中}
    self.dod = r:readInt32Unsigned() -- {闪避}
    self.crit = r:readInt32Unsigned() -- {暴击}
    self.crit_res = r:readInt32Unsigned() -- {抗暴}
    self.bonus = r:readInt32Unsigned() -- {伤害率}
    self.reduction = r:readInt32Unsigned() -- {免伤率}
end
-- end2002
-- (2003手动) -- [2003]插槽信息块 -- 物品/背包 
ACK_GOODS_XXX3 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_XXX3
    self:init()
end)

function ACK_GOODS_XXX3.decode(self, r)
    self.slot_flag     = r: readBoolean()
    -- print("插槽信息块是否有值:"..type(self.slot_flag))
    if self.slot_flag then
        self.slot_pearl_id = r: readInt16Unsigned();
        self.count         = r: readInt16Unsigned();
        -- print("插槽信息块 ID:"..self.slot_pearl_id.."数量:"..sel1f.count)
        --msggroup = msg.readXXXGroup();  -- {插槽属性块(2003 P_GOODS_XXX5)}       
        local icount = 1
        self.msg_group = {}
        while icount <= self.count do
            -- print("第 "..icount.." 个插槽属性:")
            local tempData = ACK_GOODS_XXX5()
            tempData :decode( r)
            self.msg_group[icount] = tempData
            icount = icount + 1
        end
    end
end
-- end2003
-- (2020手动) -- [2020]请求返回数据 -- 物品/背包 
ACK_GOODS_REVERSE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_REVERSE
    self:init()
end)

function ACK_GOODS_REVERSE.decode(self, r)
    self.uid         = r:readInt32Unsigned() -- {玩家UID}
    self.type        = r:readInt8Unsigned() -- {1:背包 2:装备 3:临时背包}
    self.maximum     = r:readInt16Unsigned() -- {最大容量，装备时为0}
    self.goods_count = r:readInt16Unsigned() -- {物品数量}
    
    --self.goods_msg_no = r:readXXXGroup()   -- {物品信息块(2001 P_GOODS_XXX1)}
    local icount = 1
    self.goods_msg_no = {}
    while icount <= self.goods_count do
        -- print("第 "..icount.." 个物品:")
        local tempData = ACK_GOODS_XXX1()
        tempData :decode( r)
        self.goods_msg_no[icount] = tempData
        icount = icount + 1
    end
end
-- end2020
-- (2040手动) -- [2040]消失物品/装备 -- 物品/背包 
ACK_GOODS_REMOVE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_REMOVE
    self:init()
end)

function ACK_GOODS_REMOVE.decode(self, r)
    self.type = r:readInt8Unsigned() -- {1:背包 2:装备 3:临时背包}
    self.id = r:readInt32Unsigned() -- {装备栏时,0:主将|伙伴ID}
    self.count = r:readInt16Unsigned() -- {物品数量}
    self.index = {}--r:readInt16Unsigned() -- {所在容器位置索引}
    local  icount = 1
    while icount <= self.count do
        --self.index[icount] ={}
        local _index = r:readInt16Unsigned()
        self.index[_index] = true
        icount = icount + 1
    end
end
-- end2040
-- (2050手动) -- [2050]物品/装备属性变化 -- 物品/背包 
ACK_GOODS_CHANGE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_CHANGE
    self:init()
end)

function ACK_GOODS_CHANGE.decode(self, r)
    self.type        = r:readInt8Unsigned()  -- {1:背包 2:装备 3:临时背包}
    self.id          = r:readInt32Unsigned() -- {装备栏时,0:主将|伙伴ID}
    self.count       = r:readInt16Unsigned() -- {装备数量}
    print("YYYYYYYYYYYYYYYY", self.type, self.id, self.count)    
    --self.goods_msg_no = r:readXXXGroup()
    print(self.type,self.id,self.count)            -- {物品信息块(2001 P_GOODS_XXX1)}
    local icount = 1
    self.goods_msg_no = {}
    while icount <= self.count do
        -- print("第 "..icount.." 个物品:")
        local tempData = ACK_GOODS_XXX1()
        tempData :decode( r)
        self.goods_msg_no[icount] = tempData
        icount = icount + 1
    end
end
-- end2050
-- (2060手动) -- [2060]获得|失去物品通知 -- 物品/背包 
ACK_GOODS_CHANGE_NOTICE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_CHANGE_NOTICE
    self:init()
end)

function ACK_GOODS_CHANGE_NOTICE.decode(self, r)
    self.switchs = r:readBoolean() -- {true:获得 | false:失去}
    self.type = r:readInt8Unsigned() -- {1:背包 3:临时背包}
    self.count = r:readInt16Unsigned() -- {数量}
    self.goods_id = r:readInt32Unsigned() -- {物品ID}
    self.goods_count = r:readInt16Unsigned() -- {物品数量}
end
-- end2060
-- (2242手动) -- [2242]角色装备信息返回 -- 物品/背包 
ACK_GOODS_EQUIP_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_EQUIP_BACK
    self:init()
end)

function ACK_GOODS_EQUIP_BACK.decode(self, r)
    self.uid         = r:readInt32Unsigned() -- {玩家UID}
    self.partner     = r:readInt32Unsigned() -- {主将:0|武将id}
    self.count       = r:readInt16Unsigned() -- {装备数量}
    
    --self.msg_group = r:readXXXGroup()      -- {物品信息块(2001 P_GOODS_XXX1)}
    local icount = 1
    self.msg_group = {}
    while icount <= self.count do
        -- print("第 "..icount.." 个物品:")
        local tempData = ACK_GOODS_XXX1()
        tempData :decode( r)
        self.msg_group[icount] = tempData
        icount = icount + 1
    end

    self.count2      = r:readInt16Unsigned() -- {部位数量}
    self.msg_group2  = {}
    print("ACK_GOODS_EQUIP_BACK=========>>>>",self.count2)
    for i=1,self.count2 do
        local tempData = ACK_MAKE_PART_ALL_XXX()
        tempData :decode(r)
        self.msg_group2[tempData.type_sub] = tempData
        -- for k,v in pairs(tempData) do
        --     print(k,v)
        -- end
    end
end
-- end2242
-- (2245手动) -- [2245]部位信息块 -- 物品/背包 
ACK_GOODS_MSG_PART_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_MSG_PART_XXX
    self:init()
end)

function ACK_GOODS_MSG_PART_XXX.decode(self, r)
    self.type_sub = r:readInt16Unsigned() -- { 部位类型 }
    self.lv = r:readInt16Unsigned() -- { 强化等级 }
    self.count = r:readInt16Unsigned() -- { 数量 }
    self.gem_xxx = r:readXXXGroup() -- { 宝石信息块(2003) }
end
-- end2245
-- (2310手动) -- [2310]商店数据返回 -- 物品/背包 
ACK_GOODS_SHOP_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_SHOP_BACK
    self:init()
end)

function ACK_GOODS_SHOP_BACK.decode(self, r)
    self.price_type   = r:readInt8Unsigned()  -- {价格类型}
    self.count        = r:readInt16Unsigned() -- {物品数量}
    
    local i = 1
    self.msgxxx = {}
    while i <= self.count do
        self.msgxxx = {}
        self.msgxxx[i].id     = r:readInt32Unsigned() -- {物品ID}
        self.msgxxx[i].price  = r:readInt32Unsigned() -- {物品价格}
        i = i + 1
    end
end
-- end2310
-- (2331手动) -- [2331]元宵活动数据返回 -- 物品/背包 
ACK_GOODS_LANTERN_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_LANTERN_BACK
    self:init()
end)

function ACK_GOODS_LANTERN_BACK.decode(self, r)
    self.xxx1 = r:readXXXGroup() -- {汤圆数据2333}
    self.count_e = r:readInt16Unsigned() -- {次数物品日志数量 (循环)}
    self.xxx2 = r:readXXXGroup() -- {数据块2334}
    self.count_goods = r:readInt16Unsigned() -- {可抽奖的12格物品}
    self.xxx3 = r:readXXXGroup() -- {数据块2335}
end
-- end2331
-- (2332手动) -- [2332]次数物品数据返回 -- 物品/背包 
ACK_GOODS_TIMES_GOODS_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_TIMES_GOODS_BACK
    self:init()
end)

function ACK_GOODS_TIMES_GOODS_BACK.decode(self, r)
    self.count_g = r:readInt16Unsigned() -- {次数物品数据数量}
    self.xxx1 = r:readXXXGroup() -- {数据块2333}
    self.count_e = r:readInt16Unsigned() -- {次数物品日志数量}
    self.xxx2 = r:readXXXGroup() -- {数据块2334}
end
-- end2332
-- (2517手动) -- [2517]下一级装备强化数据返回 -- 物品/打造/强化 
ACK_MAKE_STREN_DATA_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_STREN_DATA_BACK
    self:init()
end)

function ACK_MAKE_STREN_DATA_BACK.decode(self, r)
    self.ref      = r:readInt8Unsigned() -- {标识}
    self.goods_id = r:readInt16Unsigned() -- {物品ID}
    self.lv       = r:readInt16Unsigned() -- {物品等级}
    self.color    = r:readInt8Unsigned() -- {物品颜色}
    self.cost_coin = r:readInt32Unsigned() -- {消耗银元}
    self.count = r:readInt16Unsigned() -- {属性数量}
    -- print("2517 你看你发的是什么东西",self.ref,self.goods_id,self.lv,self.color,self.cost_coin,self.count)
    --self.msg_xxx = r:readXXXGroup() -- {信息块2518}
    self.data = {}
    if self.count > 0 then
        for icount=1, self.count do
            self.data[icount] = {}
            self.data[icount].type       = r:readInt16Unsigned() -- 属性类型
            self.data[icount].type_value = r:readInt16Unsigned() -- 属性值
        end
    end
end
-- end2517
-- (2532手动) -- [2532]洗练数据返回 -- 物品/打造/强化 
ACK_MAKE_WASH_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_WASH_BACK
    self:init()
end)

function ACK_MAKE_WASH_BACK.decode(self, r)
    self.arg = r:readInt8Unsigned() -- {洗练方式(常量定义)}
    if self.arg ~= 3 then 
        self.count = r:readInt16Unsigned() -- {数量}
        self.msg = {}
        if self.count > 0 then
            for i=1,self.count do
                self.msg[i] = ACK_MAKE_PLUS_MSG_XXX()
                self.msg[i] : decode( r )
            end
        end
    else
        self.skill_id = r:readInt32Unsigned() -- {技能ID}
    end
    
end
-- end2532
-- (2535手动) -- [2535]附加属性数据块 -- 物品/打造/强化 
ACK_MAKE_PLUS_MSG_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_PLUS_MSG_XXX
    self:init()
end)

function ACK_MAKE_PLUS_MSG_XXX.decode(self, r)
    self.idex  = r:readInt16Unsigned() -- {索引}
    self.count = r:readInt16Unsigned() -- {数量}
    self.msg_xxx = {}
    for i=1,self.count do
        self.msg_xxx[i] = ACK_MAKE_PLUS_MSG_XXX2() -- {附加属性块2536}
        self.msg_xxx[i] : decode( r )
    end
    
end
-- end2535
-- (2690手动) -- [2690]下一级打造装备数据返回 -- 物品/打造/强化 
ACK_MAKE_EQUIP_NEXT_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_EQUIP_NEXT_REPLY
    self:init()
end)

function ACK_MAKE_EQUIP_NEXT_REPLY.decode(self, r)
    -- self.attr_xxx = r:readXXXGroup() -- { 下一阶属性块(2002) }
    self.attr_xxx = ACK_GOODS_XXX2()-- {信息块(2002)}
    self.attr_xxx : decode( r )    
end
-- end2690
-- (2726手动) -- [2726]强化返回 -- 物品/打造/强化 
ACK_MAKE_PART_STREN_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_PART_STREN_REPLY
    self:init()
end)

function ACK_MAKE_PART_STREN_REPLY.decode(self, r)
    self.lv    = r:readInt16Unsigned() -- { 当前等级 }
    self.money = r:readInt32Unsigned() -- { 消耗铜钱 }
    self.odds  = r:readInt16Unsigned() -- { 升级几率 }
    self.odds_vip = r:readInt16Unsigned() -- { 增加几率VIP }
    self.count = r:readInt16Unsigned() -- { 当前属性数量  }

    -- self.msg_xxx = r:readXXXGroup() -- { 信息块2518 }
    self.msg_xxx = {}
    if self.count > 0 then
        for i=1,self.count do
            self.msg_xxx[i] = ACK_MAKE_STREN_COST_XXX() --2518
            self.msg_xxx[i] : decode( r )
        end
    end
    self.count2 = r:readInt16Unsigned() -- { 下一级属性数量 }
    -- self.msg_xxx2 = r:readXXXGroup() -- { 信息块2518 }
    self.msg_xxx2 = {}
    if self.count2 > 0 then
        for i=1,self.count2 do
            self.msg_xxx2[i] = ACK_MAKE_STREN_COST_XXX() --2518
            self.msg_xxx2[i] : decode( r )
        end
    end
end
-- end2726
-- (2736手动) -- [2736]所有部位返回 -- 物品/打造/强化 
ACK_MAKE_PART_ALL_REP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_PART_ALL_REP
    self:init()
end)

function ACK_MAKE_PART_ALL_REP.decode(self, r)
    self.id = r:readInt32Unsigned() -- { 部位数量 }
    self.count = r:readInt16Unsigned() -- { 部位数量 }
    -- self.msg_xxx = r:readXXXGroup() -- { 部位信息块 }
    self.msg_xxx = {}
    for i=1,self.count do
        self.msg_xxx[i] = ACK_MAKE_PART_ALL_XXX() --2737
        self.msg_xxx[i] : decode( r )
    end
end
-- end2736
-- (2737手动) -- [2737]部位信息块 -- 物品/打造/强化 
ACK_MAKE_PART_ALL_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_PART_ALL_XXX
    self:init()
end)

function ACK_MAKE_PART_ALL_XXX.decode(self, r)
    self.type_sub = r:readInt16Unsigned() -- { 部位类型 }
    self.lv = r:readInt16Unsigned() -- { 强化等级 }

    self.attr_count = r:readInt16Unsigned()
    self.attr_data = {}
    for i=1,self.attr_count do
        local tempData=ACK_GOODS_ATTR_BASE()
        tempData:decode(r)
        self.attr_data[i]=tempData
    end

    self.count = r:readInt16Unsigned() -- { 数量(镶嵌宝石) }
    self.gem_xxx = {}
    for i=1,self.count do
        self.gem_xxx[i] = ACK_MAKE_GEM_XXX() --2738
        self.gem_xxx[i] : decode( r )
    end
end
-- end2737
-- (2745手动) -- [2745]部位镶嵌宝石返回 -- 物品/打造/强化 
ACK_MAKE_PART_INSERT_REP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_PART_INSERT_REP
    self:init()
end)

function ACK_MAKE_PART_INSERT_REP.decode(self, r)
    self.type_sub = r:readInt16Unsigned() -- { 部位类型 }
    self.count = r:readInt16Unsigned() -- { 数量 }
    -- self.msg_xxx = r:readXXXGroup() -- { 信息块(2003) }
    self.msg_xxx = {}
    if self.count > 0 then
        for i=1,self.count do
            self.msg_xxx[i] = ACK_GOODS_XXX3() --2003
            self.msg_xxx[i] : decode( r )
        end
    end
end
-- end2745
-- (3220手动) -- [3220]返回任务数据 -- 任务 
ACK_TASK_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TASK_DATA
    self:init()
end)

function ACK_TASK_DATA.decode(self, r)
    self.count       = r :readInt16Unsigned()    --任务数量(要弃用)
    
    self.id          = r :readInt32Unsigned()    --任务id
    self.state       = r :readInt8Unsigned()     --任务状态 2:可接受 3:进行中 4:已完成
    self.target_type = r :readInt8Unsigned()     --任务目标类型1:对话 2:收集怪物3:击杀怪物 4:击杀玩家 5:问答 6:其它7:副本
    
    print("[3220]任务id->", self.id, " 任务状态->", self.state, " 任务目标类型->", self.target_type)
    
    if self.target_type == 1 then                     --对话任务
        CCLOG("1:完成对话任务解析")
        
    elseif self.target_type == 2 then
        CCLOG("2:收集怪物")
        
    elseif self.target_type == 3 then                 --击杀怪物
        CCLOG("3:击杀怪物")
        self.monster_count = r :readInt16Unsigned()        --击杀怪物种数
        if self.monster_count ~= nil and self.monster_count > 0 then
            self.monster_detail = {}                  --3223
            
            for i=1, self.monster_count do
                self.monster_detail.monster_id   = r :readInt16Unsigned()          --怪物ID
                self.monster_detail.monster_nums = r :readInt8Unsigned()           --怪物数量
                self.monster_detail.monster_max  = r :readInt8Unsigned()           --达成所需数量
            end
        end
    elseif self.target_type == 4 then
        CCLOG("4:击杀玩家")
        
    elseif self.target_type == 5 then
        CCLOG("5:问答")
        
    elseif self.target_type == 6 then                 --其他任务
        CCLOG("6:其他任务")
        self.other_id = r :readInt16Unsigned()--其他id
        self.current = r :readInt32Unsigned()--预留2 暂定为完成度
        self.max = r :readInt32Unsigned()--预留1 暂定为完成度
        print( "  任务目标ID->",self.other_id,"  当前次数=", self.current, "  最大次数=", self.max )
    elseif self.target_type == 7 then                 --副本任务
        CCLOG("7;副本任务")
        self.copy    = r :readInt16Unsigned()
        self.current = r :readInt16Unsigned()
        self.max     = r :readInt16Unsigned()
        
        print( "副本id=", self.copy, "当前次数=", self.current, "最大次数=", self.max)
    end
end
-- end3220
-- (3526手动) -- [3526]组队副本信息返回 -- 组队系统 
ACK_TEAM_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TEAM_REPLY
    self:init()
end)

function ACK_TEAM_REPLY.decode(self, r)
    self.copy_id = r:readInt16Unsigned() -- {副本ID}
    self.times = r:readInt16Unsigned() -- {剩余次数}
    self.buy_times = r:readInt8Unsigned() -- {剩余次数}
    self.rmb = r:readInt16Unsigned() -- {购买所需元宝数}
    self.count = r:readInt16Unsigned() -- {数量}
    -- self.reply_msg = r:readXXXGroup() -- {队伍信息块}
    self.reply_msg = {}
    if self.count > 0 then
        for i=1,self.count do
            self.reply_msg[i] = ACK_TEAM_REPLY_MSG()
            self.reply_msg[i] : decode( r )
        end
    end
    self.count_2 = r:readInt16Unsigned() -- {数量}
    -- self.reply_msg = r:readXXXGroup() -- {队伍信息块}
    self.msg_eva = {}
    if self.count_2 > 0 then
        for i=1,self.count_2 do
            self.msg_eva[i] = ACK_TEAM_MSG_EVA_XXX()
            self.msg_eva[i] : decode( r )
        end
    end
end
-- end3526
-- (3572手动) -- [3572]队伍信息返回(new) -- 组队系统 
ACK_TEAM_TEAM_INFO_NEW = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TEAM_TEAM_INFO_NEW
    self:init()
end)

function ACK_TEAM_TEAM_INFO_NEW.decode(self, r)
    self.team_id = r:readInt32Unsigned() -- {队伍id}
    self.copy_id = r:readInt16Unsigned() -- {副本id}
    self.leader_uid = r:readInt32Unsigned() -- {队长uid}
    self.count = r:readInt16Unsigned() -- {队伍成员数量}
    local icount = 1
    self.data = {}
    while icount <=  self.count do
        self.data[icount] = ACK_TEAM_MEM_MSG_NEW()
        self.data[icount] : decode( r )
        
        icount = icount + 1
    end
end
-- end3572
-- (3820手动) -- [3820]邀请玩家列表返回 -- 组队系统 
ACK_TEAM_LIST_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TEAM_LIST_REPLY
    self:init()
end)

function ACK_TEAM_LIST_REPLY.decode(self, r)
    self.type = r:readInt8Unsigned() -- {类型(1附近的人，2好友，3)门派成员}
    self.count = r:readInt16Unsigned() -- {数量}
    -- self.msg = r:readXXXGroup() -- {玩家信息块(3830)}
    self.msg = {}
    if self.count > 0 then
        for i=1,self.count do
            self.msg[i] = ACK_TEAM_MSG_PLAYER()
            self.msg[i] : decode( r )
        end
    end
end
-- end3820
-- (4020手动) -- [4020]请求好友数据返回 -- 好友 
ACK_FRIEND_INFO = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FRIEND_INFO
    self:init()
end)

function ACK_FRIEND_INFO.decode(self, r)
    self.type = r:readInt8Unsigned() -- {返回好友类型（1：好友列表；2：最近联系人列表；3：黑名单列表）}
    self.count = r:readInt16Unsigned() -- {好友数量}
    --self.data = r:readXXXGroup() -- {好友信息块}
    if self.count > 0 then
        self.data = {}
        for i=1, self.count do
            self.data[i] = ACK_FRIEND_MSG_ROLE_XX()
            self.data[i] : decode( r )
        end
    end
end
-- end4020
-- (4060手动) -- [4060]查找好友返回 -- 好友 
ACK_FRIEND_SEARCH_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FRIEND_SEARCH_REPLY
    self:init()
end)

function ACK_FRIEND_SEARCH_REPLY.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    self.data = {} -- {信息块(4025)}
    -- print( "ACK_FRIEND_SEARCH_REPLY.decode", self.count)
    if self.count > 0 then
        for i=1, self.count do
            self.data[i] = ACK_FRIEND_MSG_ROLE_XX()
            self.data[i] : decode( r )
        end
    end
    -- print( "ACK_FRIEND_SEARCH_REPLY.decode", self.count)
    
    -- if self.data then
    --     for k, v in pairs( self.data) do
    --         print("self.data", k, v.id, v.name, v.clan, v.is_online, v.pro)
    --     end
    -- else
    --     CCLOG("codeError!!!! 没有该玩家")
    -- end
end
-- end4060
-- (4110手动) -- [4110] 好友界面中的推荐好友 -- 好友 
ACK_FRIEND_GET_FRIEND_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FRIEND_GET_FRIEND_CB
    self:init()
end)

function ACK_FRIEND_GET_FRIEND_CB.decode(self, r)
    self.count = r:readInt16Unsigned() -- { 数量 }
    self.msg_role_xxx = {} -- { 人物信息块（4025） }
    for i=1, self.count do
        self.msg_role_xxx[i] = ACK_FRIEND_MSG_ROLE_XX()
        self.msg_role_xxx[i] : decode( r )
    end
end
-- end4110
-- (4200手动) -- [4200]系统推荐玩家数据返回 -- 好友 
ACK_FRIEND_SYS_FRIEND = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FRIEND_SYS_FRIEND
    self:init()
end)

function ACK_FRIEND_SYS_FRIEND.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    self.msg_role_xxx = {}--r:readXXXGroup() -- {人物信息块（4025）}
    local iCount = 1
    while iCount <= self.count do
        self.msg_role_xxx[iCount] = {}
        self.msg_role_xxx[iCount].id       = r:readInt32Unsigned()
        self.msg_role_xxx[iCount].name      = r:readString()
        self.msg_role_xxx[iCount].clan      = r:readString()
        self.msg_role_xxx[iCount].lv        = r:readInt16Unsigned()
        self.msg_role_xxx[iCount].is_online = r:readInt8Unsigned()
        self.msg_role_xxx[iCount].pro       = r:readInt8Unsigned()
        self.msg_role_xxx[iCount].powerful  = r:readInt32Unsigned()
        self.msg_role_xxx[iCount].is        = r:readInt8Unsigned()
        self.msg_role_xxx[iCount].is2       = r:readInt8Unsigned()
        iCount = iCount + 1
    end
end
-- end4200
-- (4275手动) -- [4275]好友邀请返回 -- 好友 
ACK_FRIEND_INVITE_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FRIEND_INVITE_REPLY
    self:init()
end)

function ACK_FRIEND_INVITE_REPLY.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    self.invite_msg = r:readXXXGroup() -- {好友信息块}
end
-- end4275
-- (5005手动) -- [5005]场景[行走,扣血,技能]打包 -- 场景 
ACK_SCENE_PACKAGE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_PACKAGE
    self:init()
end)

function ACK_SCENE_PACKAGE.decode(self, r)
    self.count_move = r:readInt16Unsigned() -- {数量}
    self.moveMsgs={}
    for i=1,self.count_move do
        local msg = ACK_SCENE_MOVE_RECE()
        msg:decode(r)
        self.moveMsgs[i]=msg
    end
    -- self.move = r:readXXXGroup() -- {1:行走  信息块5090}
    self.count_cut_hp = r:readInt16Unsigned() -- {数量}
    self.updateUpMsgs={}
    for i=1,self.count_cut_hp do
        local msg = ACK_SCENE_HP_UPDATE()
        msg:decode(r)
        self.updateUpMsgs[i]=msg
    end
    -- self.cut_hp = r:readXXXGroup() -- {2:扣血  信息块5190}
    self.count_skill = r:readInt16Unsigned() -- {数量}
    self.skillMsgs={}
    for i=1,self.count_skill do
        local msg = ACK_WAR_SKILL()
        msg:decode(r)
        self.skillMsgs[i]=msg
    end
    -- self.skill = r:readXXXGroup() -- {3: 放技能  信息块6030}
end
-- end5005
-- (5029手动) -- [5029]各种人物资源预加载 -- 场景 
ACK_SCENE_ALL_SKIN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_ALL_SKIN
    self:init()
end)

function ACK_SCENE_ALL_SKIN.decode(self, r)
    self.mount_count = r:readInt16Unsigned() -- {坐骑数量}
    self.mount_ids = r:readInt16Unsigned() -- {坐骑ID}
    self.meiren_count = r:readInt16Unsigned() -- {美人数量}
    self.meiren_ids = r:readInt16Unsigned() -- {美人Id}
    self.magic_count = r:readInt16Unsigned() -- {神器数量}
    self.magic_ids = r:readInt16Unsigned() -- {神器ID}
end
-- end5029
-- (5045手动) -- [5045]玩家信息列表 -- 场景 
ACK_SCENE_PLAYER_LIST = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_PLAYER_LIST
    self:init()
end)

function ACK_SCENE_PLAYER_LIST.decode(self, r)
    self.count = r:readInt16Unsigned() -- {地图玩家数量}
    --self.data = r:readXXXGroup() -- {玩家信息块(5050)}
    self.data = {}
    for i=1,self.count do
        self.data[i] = ACK_SCENE_ROLE_DATA()
        self.data[i] : decode( r )
    end
end
-- end5045
-- (5050手动) -- [5050]地图玩家数据 -- 场景 
ACK_SCENE_ROLE_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_ROLE_DATA
    self:init()
end)

function ACK_SCENE_ROLE_DATA.decode(self, r)
    self.type = r:readInt8Unsigned() -- {类型 玩家/怪物/宠物}
    self.uid = r:readInt32Unsigned() -- {玩家ID}
    self.name = r:readString() -- {昵称char[16]}
    self.name_color = r:readInt8Unsigned() -- {角色名颜色}
    self.sex = r:readInt8Unsigned() -- {性别}
    self.pro = r:readInt8Unsigned() -- {职业}
    self.lv = r:readInt16Unsigned() -- {等级}
    self.is_war = r:readInt8Unsigned() -- {状态flag 战斗/打造/整理仓库/}
    self.is_guide = r:readInt8Unsigned() -- {[Base]新手指导员 (0:正常状态|1:指导员)}
    self.team_id = r:readInt32Unsigned() -- {队伍ID}
    self.pos_x = r:readInt16Unsigned() -- {X坐标}
    self.pos_y = r:readInt16Unsigned() -- {Y坐标}
    self.speed = r:readInt16Unsigned() -- {移动速度}
    self.dir = r:readInt8Unsigned() -- {方向}
    self.distance = r:readInt8Unsigned() -- {距离}
    self.country = r:readInt8Unsigned() -- {国家：显示玩家的国家}
    self.country_post = r:readInt8Unsigned() -- {国家：职位}
    self.clan = r:readInt32Unsigned() -- {家族：显示玩家的家族}
    self.clan_name = r:readString() -- {家族：显示玩家的家族名称}
    self.clan_post = r:readInt8Unsigned() -- {家族：职位}
    self.vip = r:readInt8Unsigned() -- {VIP等级(0:0级  N:N级  非#vip{} )}
    self.skin_mount = r:readInt16Unsigned() -- {坐骑皮肤}
    self.skin_armor = r:readInt16Unsigned() -- {衣服皮肤}
    self.skin_weapon = r:readInt16Unsigned() -- {武器皮肤}
    self.skin_meiren = r:readInt16Unsigned() -- {魔宠皮肤}
    self.skin_feather = r:readInt16Unsigned()
    self.hp_now = r:readInt32Unsigned() -- {当前血量}
    self.hp_max = r:readInt32Unsigned() -- {最大血量}
    self.count = r:readInt16Unsigned() -- {数量}
    self.title_msg = {}--r:readXXXGroup() -- {称号信息块}
    for i=1,self.count do
        self.title_msg[i] = ACK_SCENE_TITLE_MSG()
        self.title_msg[i] : decode(r)
        -- print("-->>>>>>",self.title_msg[i].title_id)
    end
    self.count2    = r:readInt16Unsigned() -- {数量}
    self.magic_msg = {}--r:readXXXGroup() -- {神器信息块}
    for i=1,self.count2 do
        self.magic_msg[i] = ACK_SCENE_MAGIC_MSG()
        self.magic_msg[i] : decode(r)
        -- print("magic_msg-->>>>>>",self.magic_msg[i].magic_id)
    end   
    
    self.skin_wing = r:readInt16Unsigned() -- {宠物皮肤}
    self.mount_tx   = r:readInt8Unsigned()  -- {坐骑特效}
    -- print("ACK_SCENE_ROLE_DATA    name>>>>",self.name)
    -- print("ACK_SCENE_ROLE_DATA    titlecount>>>>",self.count)
    -- print("ACK_SCENE_ROLE_DATA    skin_mount>>>>",self.skin_mount)
end
-- end5050
-- (5052手动) -- [5052]地图伙伴列表 -- 场景 
ACK_SCENE_PARTNER_LIST = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_PARTNER_LIST
    self:init()
end)

function ACK_SCENE_PARTNER_LIST.decode(self, r)
    self.count = r:readInt16Unsigned() -- {伙伴数量}
    --self.data = r:readXXXGroup() -- {伙伴信息块(5055)}
    self.data = {}
    for i=1,self.count do
        self.data[i] = ACK_SCENE_PARTNER_DATA()
        self.data[i] : decode( r )
    end
end
-- end5052
-- (5065手动) -- [5065]场景刷出第几波怪 -- 场景 
ACK_SCENE_IDX_MONSTER = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_IDX_MONSTER
    self:init()
end)

function ACK_SCENE_IDX_MONSTER.decode(self, r)
    self.idx = r:readInt16Unsigned() -- {第几波}
    self.count = r:readInt16Unsigned() -- {怪物数量}
    --self.data = r:readXXXGroup() -- {5070}
    self.data = {}
    for i=1,self.count do
        self.data[i] = ACK_SCENE_MONSTER_DATA()
        self.data[i] : decode( r )
    end
end
-- end5065
-- (5072手动) -- [5072]场景刷出第几波怪 -- 场景 
ACK_SCENE_IDX_MONSTER2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_IDX_MONSTER2
    self:init()
end)

function ACK_SCENE_IDX_MONSTER2.decode(self, r)
    self.snow = r:readInt16Unsigned() -- {怪物打到第几屏}
    self.lv = r:readInt16Unsigned() -- {等级}
    self.count = r:readInt16Unsigned() -- {数量}
    self.msg_monster_data = {} -- {怪物信息块 5070}
    for i=1,self.count do
        self.msg_monster_data[i] = ACK_SCENE_MONSTER_DATA()
        self.msg_monster_data[i] : decode( r )
    end
end
-- end5072
-- (5185手动) -- [5185]血量更新(统一扣血) -- 场景 
ACK_SCENE_HP_UPDATE_ALL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_HP_UPDATE_ALL
    self:init()
end)

function ACK_SCENE_HP_UPDATE_ALL.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    -- self.msg_xxx = r:readXXXGroup() -- {信息块（5190）}
    self.msg_xxx={}
    for i=1,self.count do
        local data = ACK_SCENE_HP_UPDATE()
        data:decode(r)
        self.msg_xxx[i]=data
    end
end
-- end5185
-- (5700手动) -- [5700]组队副本雇佣玩家 -- 场景 
ACK_SCENE_TEAM_HIRE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_TEAM_HIRE
    self:init()
end)

function ACK_SCENE_TEAM_HIRE.decode(self, r)
    self.uid_own = r:readInt32Unsigned() -- { 队长ID }
    self.uid = r:readInt32Unsigned() -- { 被雇佣玩家ID }
    self.name = r:readString() -- { 被雇佣玩家名字 }
    self.lv = r:readInt16Unsigned() -- { 被雇佣玩家等级 }
    self.pro = r:readInt8Unsigned() -- { 被雇佣玩家职业 }
    self.hp_now = r:readInt32Unsigned() -- { 被雇佣玩家当前血量 }
    self.pos_x = r:readInt16Unsigned() -- { 被雇佣玩家位置X }
    self.pos_y = r:readInt16Unsigned() -- { 被雇佣玩家位置Y }
    self.skin_weapon = r:readInt16Unsigned() -- {}
    self.skin_feather = r:readInt16Unsigned() -- {}
    self.count = r:readInt16Unsigned() -- { 被雇佣玩家技能数量 }
    self.skill = {}
    for i=1,self.count do
        self.skill[i]={}
        self.skill[i].skill_id= r:readInt16Unsigned()
        self.skill[i].skill_lv= r:readInt16Unsigned()
    end
    self.attr = ACK_GOODS_XXX2()-- {信息块(2002)}
    self.attr : decode( r )
end
-- end5700
-- (5990手动) -- [5990]场景广播-称号 -- 场景 
ACK_SCENE_CHANG_TITLE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_CHANG_TITLE
    self:init()
end)

function ACK_SCENE_CHANG_TITLE.decode(self, r)
    self.uid = r:readInt32Unsigned() -- {玩家ID}
    self.count = r:readInt16Unsigned() -- {数量}
    self.title_msg = {}--r:readXXXGroup() -- {称号信息块（5051）}
    for i=1,self.count do
        self.title_msg[i] = ACK_SCENE_TITLE_MSG()
        self.title_msg[i] : decode(r)
    end
end
-- end5990
-- (5992手动) -- [5992]场景广播-神器 -- 场景 
ACK_SCENE_CHANG_MAGIC = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_CHANG_MAGIC
    self:init()
end)

function ACK_SCENE_CHANG_MAGIC.decode(self, r)
    self.uid       = r:readInt32Unsigned() -- {玩家ID}
    self.count     = r:readInt16Unsigned() -- {数量}
    self.magic_msg = {}--r:readXXXGroup() -- {神器信息块}
    for i=1,self.count do
        self.magic_msg[i] = {}
        self.magic_msg[i].magic_id = r:readInt16Unsigned() -- {神器id}
        
    end   

end
-- end5992
-- (6010手动) -- [6010]战斗数据块 -- 战斗 
ACK_WAR_PLAYER_WAR = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WAR_PLAYER_WAR
    self:init()
end)

function ACK_WAR_PLAYER_WAR.decode(self, r)
    self.uid = r:readInt32Unsigned() -- {用户ID}
    self.name = r:readString() -- {玩家名字}
    self.lv = r:readInt8Unsigned() -- {玩家等级}
    self.pro = r:readInt8Unsigned() -- {玩家职业}
    self.sex = r:readInt8Unsigned() -- {玩家性别}
    self.skin_weapon = r:readInt16Unsigned() -- {武器皮肤}
    self.skin_armor = r:readInt16Unsigned() -- {衣服皮肤}
    self.rank = r:readInt16Unsigned() -- {逐鹿台排名}
    self.attr = ACK_GOODS_XXX2()-- {信息块(2002)}
    self.attr : decode( r )
    self.skill_count = r:readInt16Unsigned() -- {技能数量}
    self.skill_data = {}
    for i=1,self.skill_count do
        self.skill_data[i] = ACK_SKILL_EQUIP_INFO()-- {技能信息块(6545)}
        self.skill_data[i] : decode( r )
    end
    
    self.partner_count=r:readInt8Unsigned() -- {伙伴数量}
    
    print("self.partner_count=",self.partner_count)
    
    self.partner_data={}
    for i=1,self.partner_count do
        self.partner_data[i] = ACK_ROLE_PARTNER_DATA()-- {信息块(1109)}
        self.partner_data[i] : decode( r )
    end
    self.wid = r:readInt16Unsigned()
    self.wgrade = r:readInt8Unsigned()
    self.mgrade = r:readInt8Unsigned()
end
-- end6010
-- (6015手动) -- [6015]自身战斗属性加成 -- 战斗 
ACK_WAR_SELF_ADD = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WAR_SELF_ADD
    self:init()
end)

function ACK_WAR_SELF_ADD.decode(self, r)
    self.sy_hp = r:readInt32Unsigned() -- { 对方剩余血量 }
    self.num = r:readInt8Unsigned() -- { 数量 }
    -- self.type = r:readInt8Unsigned() -- { 属性类型 }
    -- self.value = r:readInt32Unsigned() -- { 属性值 }
    self.data = {}
    for i=1,self.num do
        self.data[i] = {}
        self.data[i].id = r:readInt8Unsigned()
        self.data[i].value = r:readInt32Unsigned()
    end
end
-- end6015
-- (6225手动) -- [6225]PVP使用技能返回 -- 战斗 
ACK_WAR_PVP_SKILL_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WAR_PVP_SKILL_BACK
    self:init()
end)

function ACK_WAR_PVP_SKILL_BACK.decode(self, r)
    self.time = r:readInt32Unsigned() -- { 发送时间(毫秒) }
    -- self.skill_group = r:readXXXGroup() -- { 协议块(6040) }
    self.skill_group=ACK_WAR_SKILL()
    self.skill_group:decode(r)

    self.count = r:readInt8Unsigned() -- { 玩家数量 }
    -- self.state_group = r:readXXXGroup() -- { 协议块(6215) }
    self.state_group={}
    for i=1,self.count do
        self.state_group[i]=ACK_WAR_PVP_STATE_GROUP()
        self.state_group[i]:decode(r)
    end
end
-- end6225
-- (6235手动) -- [6235]PVP玩家状态(返回) -- 战斗 
ACK_WAR_PVP_STATE_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WAR_PVP_STATE_BACK
    self:init()
end)

function ACK_WAR_PVP_STATE_BACK.decode(self, r)
    self.time = r:readInt32Unsigned() -- { 发送时间(毫秒) }
    self.count = r:readInt8Unsigned() -- { 玩家数量 }
    -- self.state_group_g = r:readXXXGroup() -- { 协议块(6215) }
    self.state_group={}
    for i=1,self.count do
        self.state_group[i]=ACK_WAR_PVP_STATE_GROUP()
        self.state_group[i]:decode(r)
    end
end
-- end6235
-- (6260手动) -- [6260]PVP指令数据返回 -- 战斗 
ACK_WAR_PVP_FRAME_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WAR_PVP_FRAME_MSG
    self:init()
end)

function ACK_WAR_PVP_FRAME_MSG.decode(self, r)
    self.count = r:readInt8Unsigned() -- { 数量 }
    if self.count>0 then
        self.order_array={}
        for i=1,self.count do
            self.order_array[i]={}

            self.order_array[i].times = r:readInt16Unsigned() -- { 距离帧开始多少毫秒 }
            self.order_array[i].uid = r:readInt32Unsigned() -- { 玩家uid }
            self.order_array[i].type = r:readInt8Unsigned() -- { 指令类型 }

            if self.order_array[i].type==1 then
                 self.order_array[i].move_type = r:readInt8Unsigned() -- { 行走-行走类型 }
                self.order_array[i].move_dir = r:readInt8Unsigned() -- { 行走-方向 }
                self.order_array[i].sx = r:readInt16Unsigned() -- { 行走-初始x }
                self.order_array[i].sy = r:readInt16Unsigned() -- { 行走-初始y }
                self.order_array[i].ex = r:readInt16Unsigned() -- { 行走-目标x }
                self.order_array[i].ey = r:readInt16Unsigned() -- { 行走-目标y }
            elseif self.order_array[i].type==2 then
                self.order_array[i].skill_id = r:readInt16Unsigned() -- { 释放技能-技能id }
                self.order_array[i].skill_dir = r:readInt8Unsigned() -- { 释放技能-方向 }
                self.order_array[i].pos_x = r:readInt16Unsigned() -- { 释放技能-位置x }
                self.order_array[i].pos_y = r:readInt16Unsigned() -- { 释放技能-位置y }
            end
        end
    end
end
-- end6260
-- (7008手动) -- [7008]请求所有通过副本返回 -- 副本 
ACK_COPY_ALL_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_ALL_REPLY
    self:init()
end)

function ACK_COPY_ALL_REPLY.decode(self, r)
    self.count = r:readInt8Unsigned() -- { 数量 }
    -- self.chap_data = r:readXXXGroup() -- { 全部章节信息块(7010) }
    self.chap_data = {}
    for i=1,self.count do
        local tempData=ACK_COPY_CHAP_DATA()
        tempData:decode(r)
        self.chap_data[i]=tempData
    end
end
-- end7008
-- (7018手动) -- [7018]单个章节副本返回 -- 副本 
ACK_COPY_CHAP_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_CHAP_REPLY
    self:init()
end)

function ACK_COPY_CHAP_REPLY.decode(self, r)
    self.chap_id = r:readInt16Unsigned()
    self.count = r:readInt16Unsigned() -- { 副本数量 }
    self.msg_xxx = {} --r:readXXXGroup() -- { 副本信息块(7022) }
    for i=1,self.count do
        local tempData=ACK_COPY_COPY_DATA()
        tempData:decode(r)
        self.msg_xxx[i]=tempData
    end
    self.count2 = r:readInt8Unsigned()
    self.box_idx = {}
    for i=1,self.count2 do
        local idx=r:readInt8Unsigned()
        self.box_idx[idx]=true
    end
end
-- end7018
-- (7022手动) -- [7022]副本信息块 -- 副本 
ACK_COPY_COPY_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_COPY_DATA
    self:init()
end)

function ACK_COPY_COPY_DATA.decode(self, r)
    self.times = r:readInt8Unsigned() -- {已挑战次数}
    self.times_all = r:readInt8Unsigned() -- {全部挑战次数}
    self.count = r:readInt8Unsigned() -- {数量}
    
    self.copy_one_data = {}   -- {单个副本信息块(7026)}
    local icount = 1
    while icount <= self.count do
        local tempData = ACK_COPY_COPY_ONE()
        tempData :decode( r)
        self.copy_one_data[icount] = tempData
        icount = icount + 1
    end
end
-- end7022
-- (7800手动) -- [7800]副本完成 -- 副本 
ACK_COPY_OVER = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_OVER
    self:init()
end)

function ACK_COPY_OVER.decode(self, r)
    self.copy_id = r:readInt16Unsigned() -- {副本ID}
    self.copy_type = r:readInt8Unsigned() -- {副本类型}
    self.condition = r:readInt8Unsigned() -- {通过条件一}
    self.condition2 = r:readInt8Unsigned() -- {通过条件二}
    self.eva = r:readInt8Unsigned() -- {副本评价}
    self.exp = r:readInt32Unsigned() -- {经验}
    self.exp_d = r:readInt32Unsigned() -- {e倍数}
    self.gold = r:readInt32Unsigned() -- {铜钱}
    self.gold_d = r:readInt32Unsigned() -- {g倍数}
    self.count = r:readInt16Unsigned() -- {物品数量}
    self.data = {}
    for i=1,self.count do   -- {物品信息块(7805)}
        local temp_id   = r:readInt16Unsigned()
        local temp_count = r:readInt16Unsigned()
        self.data[i] = {goods_id=temp_id, count=temp_count}
    end
    self.flag = r:readInt8Unsigned() -- {是否翻牌}
    self.times = r:readInt8Unsigned() -- {可翻牌次数}
    self.copy_next = r:readInt16Unsigned() -- {下一关副本id：0已完成任务}
end
-- end7800
-- (7850手动) -- [7850]挂机返回 -- 副本 
ACK_COPY_UP_RESULT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_UP_RESULT
    self:init()
end)

function ACK_COPY_UP_RESULT.decode(self, r)
    self.nowtimes = r:readInt16Unsigned() -- {第几轮}
    self.sumtimes = r:readInt16Unsigned() -- {总共多少轮}
    self.exp = r:readInt32Unsigned() -- {经验}
    self.gold = r:readInt32Unsigned() -- {铜钱}
    self.count = r:readInt16Unsigned() -- {物品数量}

    self.data = {} -- {物品信息块(7805)}
    for i=1,self.count do
        self.data[i]={}
        self.data[i].goods_id=r:readInt16Unsigned()
        self.data[i].count=r:readInt16Unsigned()
    end
end
-- end7850
-- (7865手动) -- [7865]登陆提醒挂机 -- 副本 
ACK_COPY_LOGIN_NOTICE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_LOGIN_NOTICE
    self:init()
end)

function ACK_COPY_LOGIN_NOTICE.decode(self, r)
    self.copy_id = r:readInt16Unsigned() -- {副本ID}

    if self.copy_id==0 then return end

    self.nowtimes = r:readInt16Unsigned() -- {第几轮}
    self.sumtimes = r:readInt16Unsigned() -- {总共多少轮}
    self.time = r:readInt32Unsigned() -- {剩余挂机时间(秒)}
    self.eva  = r:readInt8Unsigned() -- {评价}
    self.count = r:readInt16Unsigned() -- {挂机历史次数}
    self.data = {} --r:readXXXGroup() -- {挂机历史信息块}
    for i=1,self.count do
        self.data[i]=ACK_COPY_UP_RESULT()
        self.data[i]:decode(r)
    end
end
-- end7865
-- (7925手动) -- [7925]刷出第几波怪 -- 副本 
ACK_COPY_IDX_MONSTER = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_IDX_MONSTER
    self:init()
end)

function ACK_COPY_IDX_MONSTER.decode(self, r)
    self.snow = r:readInt16Unsigned() -- {怪物打到第几屏}
    self.count = r:readInt16Unsigned() -- {数量}
    self.monster_datas={}   -- {怪物数据块（7930）}
    for i=1,self.count do
        local monster_data=ACK_COPY_MONSTER_DATA()
        monster_data:decode(r)
        self.monster_datas[i]=monster_data
        -- table.insert(self.monster_datas,monster_data)
    end
end
-- end7925
-- (7940手动) -- [7940]所有已经领取奖励章节 -- 副本 
ACK_COPY_CHAP_REAWARD = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_CHAP_REAWARD
    self:init()
end)

function ACK_COPY_CHAP_REAWARD.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    self.msg_chap_id = {}
    for i=1,self.count do
        self.msg_chap_id[i] = r:readInt16Unsigned() -- {章节信息块}
    end
end
-- end7940
-- (7970手动) -- [7970]组队开始前发送全部组员皮肤 -- 副本 
ACK_COPY_TEAM_SKINS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_TEAM_SKINS
    self:init()
end)

function ACK_COPY_TEAM_SKINS.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    -- self.msg_skins = r:readXXXGroup() -- {皮肤信息块(7975)}
    self.msg_skins ={}
    for i=1,self.count do
        local msg = ACK_COPY_MSG_SKINS()
        msg:decode(r)
        self.msg_skins[i]=msg
    end
end
-- end7970
-- (7975手动) -- [7975]皮肤信息块 -- 副本 
ACK_COPY_MSG_SKINS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_MSG_SKINS
    self:init()
end)

function ACK_COPY_MSG_SKINS.decode(self, r)
    self.skin = r:readInt16Unsigned() -- {皮肤id}
    self.count = r:readInt16Unsigned() -- {技能数量}
    -- self.msg_skills = r:readXXXGroup() -- {技能信息块}
    self.msg_skills ={}
    for i=1,self.count do
        local msg = ACK_COPY_MSG_SKILLS()
        msg:decode(r)
        self.msg_skills[i]=msg
    end
end
-- end7975
-- (7990手动) -- [7990]通关翻牌返回 -- 副本 
ACK_COPY_DRAW_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_DRAW_REPLY
    self:init()
end)

function ACK_COPY_DRAW_REPLY.decode(self, r)
    self.count = r:readInt16Unsigned() -- { 数量 }
    self.msg_draw_xxx = {}--r:readXXXGroup() -- { 物品信息块 }
    for i=1,self.count do
        self.msg_draw_xxx[i]=ACK_COPY_MSG_DRAW_XXX()
        self.msg_draw_xxx[i]:decode(r)
    end
end
-- end7990
-- (8512手动) -- [8512]请求列表成功 -- 邮件 
ACK_MAIL_LIST = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAIL_LIST
    self:init()
end)

function ACK_MAIL_LIST.decode(self, r)
    self.boxtype = r:readInt8Unsigned()    -- {邮箱类型(收件箱:0|发件箱:1|保存箱:2}
    self.count = r:readInt16Unsigned()     -- {数量}
    
    CCLOG( "{邮箱类型(收件箱:0|发件箱:1|保存箱:2}==%d, {数量}==%d\n", self.boxtype, self.count)
    
    if self.count > 0 then
        self.models = {}                        -- {邮件模块[8513]}
        
        for i=1, self.count do
            self.models[i] = {}
            
            self.models[i].mail_id  = r:readInt32Unsigned()    --邮件ID
            self.models[i].mtype    = r:readInt8Unsigned()     --邮件类型(系统:0|私人:1)
            self.models[i].name     = r:readString()           --名字
            self.models[i].title    = r:readString()           --标题
            self.models[i].date     = r:readInt32Unsigned()    --发送日期
            self.models[i].state    = r:readInt8Unsigned()     --邮件状态(未读:0|已读:1)
            self.models[i].pick     = r:readInt8Unsigned()     --附件是否提取(无附件:0|未提取:1|已提取:2)
            
        end
    end
    
    
    -- if self.models then
    --     print("k标记", "邮件ID", "邮件类型01","名字","标题","发送日期","邮件状态01","附件是否提取012", #self.models )
    -- for k, v in pairs( self.models) do
    --print(k, v.mail_id, v.mtype, v.name, v.title, v.date, v.state, v.pick)
    -- end
    -- else
    --     CCLOG("没有信件  "..self.count)
    -- end
end
-- end8512
-- (8542手动) -- [8542]读取邮件成功 -- 邮件 
ACK_MAIL_INFO = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAIL_INFO
    self:init()
end)

function ACK_MAIL_INFO.decode(self, r)
    self.mail_id        = r:readInt32Unsigned()
    self.send_uid       = r:readInt32Unsigned()
    self.state          = r:readInt8Unsigned()
    self.pick           = r:readInt8Unsigned()
    self.content        = r:readUTF()
    
    --附件虚拟物品数量
    self.count_v        = r:readInt16Unsigned()
    print("ACK_MAIL_INFO1===",self.mail_id,self.send_uid,self.state,self.pick,self.content,self.count_v)

    local icount = 1
    self.vgoods_msg = {}
    while icount <= self.count_v do
        -- print("第 "..icount.." 个物品:")
        local tempData = ACK_MAIL_VGOODS_MODEL()-- {虚拟物品信息块[8543]}
        tempData :decode( r)
        self.vgoods_msg[icount] = tempData
        icount = icount + 1
    end
    
    --附件实体物品数量
    self.count_u        = r:readInt16Unsigned() -- {物品信息块(2001 P_GOODS_XXX1)}    
    local icount = 1
    self.ugoods_msg = {}
    while icount <= self.count_u do
        -- print("第 "..icount.." 个物品:")
        local tempData = ACK_GOODS_XXX1()
        tempData :decode( r)
        self.ugoods_msg[icount] = tempData
        icount = icount + 1
    end
end
-- end8542
-- (8552手动) -- [8552]提取物品成功 -- 邮件 
ACK_MAIL_OK_PICK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAIL_OK_PICK
    self:init()
end)

function ACK_MAIL_OK_PICK.decode(self, r)
    self.count = r:readInt16Unsigned() -- {已提取邮件ID数量}
    --self.id_msg = r:readXXXGroup() -- {删除邮件信息块 【8563】}
    if self.count > 0 then
        self.id_msg = {}
        
        for i=1, self.count do
            self.id_msg[i] = r:readInt32Unsigned()
        end
    end
end
-- end8552
-- (8562手动) -- [8562]邮件移出 -- 邮件 
ACK_MAIL_OK_DEL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAIL_OK_DEL
    self:init()
end)

function ACK_MAIL_OK_DEL.decode(self, r)
    self.count = r:readInt16Unsigned()  
    if self.count > 0 then
        self.data = {}
        for i=1, self.count do
            self.data[i] = r:readInt32Unsigned()
        end
    end
end
-- end8562
-- (9515手动) -- [9515]收到频道聊天 -- 聊天 
ACK_CHAT_RECE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CHAT_RECE
    self:init()
end)

function ACK_CHAT_RECE.decode(self, r)
    self.channel_id = r:readInt8Unsigned() -- {频道类型}
    self.team_id = r:readInt16Unsigned() -- {队伍类型}
    self.uid = r:readInt32Unsigned() -- {用户id}
    self.uname = r:readString() -- {用户名称}
    self.msg = r:readUTF() -- {聊天内容}
    self.goods_count = r:readInt16Unsigned() -- {物品数量}
    self.goods_msg_no =  {}
    if self.goods_count > 0 then
        for i=1,self.goods_count do
            local tempData = ACK_GOODS_XXX1()
            tempData:decode(r)
            self.goods_msg_no[i] = tempData
            
            -- for k,v in pairs(tempData) do
            --     print(k,v)
            -- end
        end
    end
    -- self.goods_msg_no = r:readXXXGroup() -- {物品信息块(物品id和数量)}
    
    self.is_guide=r:readInt8Unsigned() -- {是否是新手指导员}
    self.vip=r:readInt8Unsigned() -- {vip等级(0为不是vip)}
end
-- end9515
-- (9530手动) -- [9530]收到私聊 -- 聊天 
ACK_CHAT_RECE_PM = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CHAT_RECE_PM
    self:init()
end)

function ACK_CHAT_RECE_PM.decode(self, r)
    -- self.channel_id = r:readInt8Unsigned() -- {频道类型}
    -- self.team_id = r:readInt16Unsigned() -- {队伍类型}
    
    self.p_uid = r:readInt32Unsigned() -- {接受者玩家id}
    self.p_name = r:readString() -- {接受者玩家名字}
    
    self.uid = r:readInt32Unsigned() -- {发送者玩家id}
    self.uname = r:readString() -- {发送者玩家名字}
    
    self.msg = r:readUTF() -- {聊天内容}
    self.goods_count = r:readInt16Unsigned() -- {物品数量}
    self.goods_msg_no= {}
    for i=1,self.goods_count do
        local tempData = ACK_GOODS_XXX1()
        tempData:decode(r)
        self.goods_msg_no[i] = tempData
        
        -- for k,v in pairs(tempData) do
        --     print(k,v)
        -- end
    end
    -- self.goods_msg_no = r:readXXXGroup() -- {物品信息块(物品id和数量)}
    self.is_guide=r:readInt8Unsigned() -- {是否是新手指导员}
    self.vip=r:readInt8Unsigned() -- {vip等级(0为不是vip)}

end
-- end9530
-- (9550手动) -- [9550]语音信息返回 -- 聊天 
ACK_CHAT_YUYIN_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CHAT_YUYIN_REPLY
    self:init()
end)

function ACK_CHAT_YUYIN_REPLY.decode(self, r)
    self.yuyin_id = r:readInt32Unsigned() -- {语音ID}
    -- self.msg = r:readBinary() -- {语音内容}
    CCPlayerRecorder:sharedPlayerRecorder():receiveAudioData(self.yuyin_id,r)
end
-- end9550
-- (10730手动) -- [10730]称号列表数据返回 -- 称号 
ACK_TITLE_LIST_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TITLE_LIST_BACK
    self:init()
end)

function ACK_TITLE_LIST_BACK.decode(self, r)
	self.tid = r:readInt16Unsigned()
    self.count = r:readInt16Unsigned() -- {数量}
    self.data = {} -- {信息块10740}
    for i=1,self.count do
        local tempData = ACK_TITLE_MSG()
        tempData :decode(r)
        self.data[tempData.tid] = tempData
    end
end
-- end10730
-- (10820手动) -- [10820]城镇BOSS请求返回 -- 城镇BOSS 
ACK_CITY_BOSS_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CITY_BOSS_REPLY
    self:init()
end)

function ACK_CITY_BOSS_REPLY.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    self.msg_boos_xxx = {}--r:readXXXGroup() -- {信息块}
    for i=1,self.count do
        local tempData = ACK_CITY_BOSS_MSG_XXX()
        tempData :decode(r)
        self.msg_boos_xxx[i] = tempData
    end
end
-- end10820
-- (10870手动) -- [10870]玩家死亡协议 -- 城镇BOSS 
ACK_CITY_BOSS_PLAYER_DIE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CITY_BOSS_PLAYER_DIE
    self:init()
end)

function ACK_CITY_BOSS_PLAYER_DIE.decode(self, r)
    self.type = r:readInt8Unsigned() -- {类型(1玩家,2BOSS)}
    if self.type == 1 then
        self.clan_name = r:readString() -- {门派名字}
        self.player_name = r:readString() -- {玩家名字}
    else
        self.boss_id = r:readInt16Unsigned() -- {BossId}
    end
    self.time = r:readInt8Unsigned() -- {剩余复活时间}
end
-- end10870
-- (10940手动) -- [10940]宠物信息返回 -- 宠物 
ACK_WING_REPLAY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WING_REPLAY
    self:init()
end)

function ACK_WING_REPLAY.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
    self.pro = r:readInt8Unsigned() -- { 职业 }
    self.wing_id = r:readInt16Unsigned() -- { 宠物id }
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.data = {} -- { 信息块10950 }
    for i=1,self.count do
        local tempData = ACK_WING_XXX_DATA()
        tempData : decode(r)
        self.data[i]=tempData
    end
    self.count2 = r:readInt8Unsigned() -- { 数量 }
    self.datas = {} -- { 信息块10950 }
    for i=1,self.count2 do
        local tempData = ACK_WING_XXXX()
        tempData : decode(r)
        self.datas[i]=tempData
    end
    self.dat  = ACK_GOODS_XXX2()--reader:readXXXGroup() -- {属性加成 信息块 2002}
    self.dat  : decode(r)
end
-- end10940
-- (10970手动) -- [10970]强化结果 -- 宠物 
ACK_WING_CUL_RESULT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WING_CUL_RESULT
    self:init()
end)

function ACK_WING_CUL_RESULT.decode(self, r)
    self.data = ACK_WING_XXX_DATA()
    self.data : decode(r)
    self.dat  = ACK_GOODS_XXX2()--reader:readXXXGroup() -- {属性加成 信息块 2002}
    self.dat  : decode(r)
end
-- end10970
-- (11010手动) -- [11010]已激活的技能 -- 真元 
ACK_WING_JH_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WING_JH_BACK
    self:init()
end)

function ACK_WING_JH_BACK.decode(self, r)
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.data = {} -- { 信息块11000 }
    for i=1,self.count do
        local msg = ACK_WING_XXXX()
        msg : decode(r)
        self.data[i]=msg
    end
end
-- end11010
-- (12135手动) -- [12135]坐骑系统请求返回 -- 坐骑 
ACK_MOUNT_MOUNT_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MOUNT_MOUNT_REPLY
    self:init()
end)

function ACK_MOUNT_MOUNT_REPLY.decode(self, r)
    self.uid = r:readInt32Unsigned() -- {玩家uid 0:自己}
    self.pro = r:readInt8Unsigned() -- {职业}
    self.skin_wuqi = r:readInt16Unsigned()
    self.skin_feather = r:readInt16Unsigned()
    self.opentime = r:readInt32Unsigned() -- {坐骑ID}
    self.mount_id = r:readInt16Unsigned() -- {坐骑ID}
    self.count    = r:readInt8Unsigned()
    self.mount_data = {}
    print("ACK_MOUNT_MOUNT_REPLY",self.count,self.uid,self.pro,self.mount_id)
    for i=1,self.count do
        local tempData = ACK_MOUNT_XXX_DATA()
        tempData : decode(r)
        self.mount_data[i]=tempData
    end
end
-- end12135
-- (12155手动) -- [12155]坐骑培养结果 -- 坐骑 
ACK_MOUNT_CUL_RESULT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MOUNT_CUL_RESULT
    self:init()
end)

function ACK_MOUNT_CUL_RESULT.decode(self, r)
    self.result = r:readInt8Unsigned() -- { 结果0:失败 1:成功 }
    self.data = {}--r:readXXXGroup() -- { 信息块12140 }
    local tempData = ACK_MOUNT_XXX_DATA()
    tempData : decode(r)
    -- self.data = tempData
    self.data[1]=tempData
end
-- end12155
-- (12220手动) -- [12220]面板信息 -- 群雄争霸 
ACK_EXPEDIT_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_EXPEDIT_REPLY
    self:init()
end)

function ACK_EXPEDIT_REPLY.decode(self, r)
    self.honor = r:readInt32Unsigned() -- {修为值}
    self.num = r:readInt16Unsigned() -- {剩余的挑战次数}
    self.pk_num = r:readInt16Unsigned() -- {总的参战次数}
    self.win_num = r:readInt16Unsigned() -- {胜利的次数}
    self.s_id = r:readInt16Unsigned() -- {服务器id}
    self.grade = r:readInt16Unsigned() -- {军衔}
    self.buy_times = r:readInt16Unsigned() -- {购买挑战次数}
    self.count = r:readInt8Unsigned() -- {数量}
    self.data = {}--r:readXXXGroup() -- {战报信息块}
    for i=1,self.count do
        print("ACK_EXPEDIT_REPLY ---> i = ",i)
        local msg = ACK_EXPEDIT_LOGS()
        msg : decode( r )
        self.data[i]=msg
    end
end
-- end12220
-- (14002手动) -- [14002]阵营信息 -- 阵营 
ACK_COUNTRY_INFO_RESULT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COUNTRY_INFO_RESULT
    self:init()
end)

function ACK_COUNTRY_INFO_RESULT.decode(self, r)
    self.is_data = r:readBoolean() -- {是否有数据 false:没 true:有 (选择)}
    self.sid = r:readInt16Unsigned() -- {服务器ID}
    self.country_id = r:readInt8Unsigned() -- {阵营类型(见常量)}
    self.num = r:readInt16Unsigned() -- {阵营人数}
    self.powerful = r:readInt32Unsigned() -- {阵营综合实力}
    self.resource = r:readInt32Unsigned() -- {阵营资源}
    self.post_count = r:readInt8Unsigned() -- {职位数量}
    self.post_type = r:readInt8Unsigned() -- {职位类型(见常量)}
    self.post_uid = r:readInt32Unsigned() -- {职位UID}
    self.post_name = r:readString() -- {职位昵称}
    self.notice = r:readUTF() -- {公告}
end
-- end14002
-- (14035手动) -- [14035]阵营排名结果 -- 阵营 
ACK_COUNTRY_RANK_RESULT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COUNTRY_RANK_RESULT
    self:init()
end)

function ACK_COUNTRY_RANK_RESULT.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    self.idx = r:readInt8Unsigned() -- {名次}
    self.sid = r:readInt16Unsigned() -- {服务器ID}
    self.country_id = r:readInt8Unsigned() -- {阵营类型(见常量)}
    self.value = r:readInt8Unsigned() -- {排名值}
end
-- end14035
-- (14090手动) -- [14090]阵营事件广播 -- 阵营 
ACK_COUNTRY_EVENT_BROADCAST = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COUNTRY_EVENT_BROADCAST
    self:init()
end)

function ACK_COUNTRY_EVENT_BROADCAST.decode(self, r)
    self.type = r:readInt8Unsigned() -- {事件类型(见常量)}
    self.post_kill = r:readInt8Unsigned() -- {被杀玩家职位}
    self.name_kill = r:readString() -- {被杀玩家名字}
    self.name_kill2 = r:readString() -- {杀人玩家名字}
    self.post_deal = r:readInt8Unsigned() -- {操作人职位}
    self.name_deal = r:readString() -- {操作人名字}
    self.post_deal2 = r:readInt8Unsigned() -- {被操作人职位}
    self.name_deal2 = r:readString() -- {被操作人名字}
    self.post_resign = r:readInt8Unsigned() -- {辞职人职位}
    self.name_resign = r:readString() -- {辞职人名字}
    self.state = r:readBoolean() -- {活动开始结束true | false}
    self.activity_id = r:readInt32Unsigned() -- {活动id}
end
-- end14090
-- (16012手动) -- [16012]收集面板返回 -- 节日活动 
ACK_FESTIVAL_COLLECT_REP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FESTIVAL_COLLECT_REP
    self:init()
end)

function ACK_FESTIVAL_COLLECT_REP.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    self.packslist = {}--r:readXXXGroup() -- {lv信息块(16015)}
    for i=1,self.count do
        print("ACK_FESTIVAL_COLLECT_REP ---> ",i)
        local msg = ACK_FESTIVAL_PACKS()
        msg : decode( r )
        self.packslist[i] = msg
    end
end
-- end16012
-- (16052手动) -- [16052]时间及活动返送(新) -- 节日活动 
ACK_FESTIVAL_GETTIME_NEW = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FESTIVAL_GETTIME_NEW
    self:init()
end)

function ACK_FESTIVAL_GETTIME_NEW.decode(self, r)
    self.a_id = r:readInt16Unsigned() -- {活动ID}
    self.start_date = r:readInt32Unsigned() -- {开始时间}
    self.end_date = r:readInt32Unsigned() -- {结束时间}
end
-- end16052
-- (16112手动) -- [16112]开服返回 -- 开服七天 
ACK_OPEN_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_OPEN_REPLY
    self:init()
end)

function ACK_OPEN_REPLY.decode(self, r)
    -- self.day = r:readInt16Unsigned() -- {开服日期}
    self.type  = r:readInt8Unsigned() -- {第几天}
    self.endtime = r:readInt32Unsigned() -- {结算时间}
    self.count = r:readInt8Unsigned() -- {数量}
    --self.lv_times = r:readXXXGroup() -- {领取id对应剩余次数信息块}
    self.msg_times = {}
    for i=1,self.count do
        local msg = ACK_OPEN_MSG_TIMES()
        msg : decode( r )
        self.msg_times[i]=msg
    end
end
-- end16112
-- (16142手动) -- [16142]返回所有类型上标次数 -- 开服七天 
ACK_OPEN_ALLLOGO = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_OPEN_ALLLOGO
    self:init()
end)

function ACK_OPEN_ALLLOGO.decode(self, r)
    self.count = r:readInt8Unsigned() -- {数量（总天数7）}
    self.msg_alllogo = {} --r:readXXXGroup() -- {类型与上标次数(16144)}
    for i=1,self.count do
        local msg = ACK_OPEN_MSG_ALLLOGO()
        msg : decode( r )
        self.msg_alllogo[i]=msg
    end
end
-- end16142
-- (16160手动) -- [16160]排行榜 -- 开服七天 
ACK_OPEN_OPEN_RANK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_OPEN_OPEN_RANK
    self:init()
end)

function ACK_OPEN_OPEN_RANK.decode(self, r)
    self.day   = r:readInt8Unsigned() -- { 天数 }
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.msg_rank = {} -- { 玩家排行信息16165 }
    for i=1,self.count do
        local msg = ACK_OPEN_OPEN_RANK_MSG()
        msg : decode( r )
        self.msg_rank[i]=msg
    end
end
-- end16160
-- (16712手动) -- [16712]消费达人返回 -- 精彩活动(不使用) 
ACK_ART_CONSUME_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_CONSUME_REPLY
    self:init()
end)

function ACK_ART_CONSUME_REPLY.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    self.msg = {} -- {领取过的信息块}
    for i=1,self.count do
        local msg = ACK_ART_MSG_CONSUME()
        msg : decode( r )
        self.msg[i]=msg
    end
end
-- end16712
-- (16715手动) -- [16715]活动id的信息块 -- 精彩活动(不使用) 
ACK_ART_MSG_CONSUME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_MSG_CONSUME
    self:init()
end)

function ACK_ART_MSG_CONSUME.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 活动Id }
    self.start = r:readInt32Unsigned() -- { 开始时间 }
    self.endtime = r:readInt32Unsigned() -- { 结束时间 }
    self.cmp = r:readInt32Unsigned()   -- { 当前值 }
    self.value2 = r:readInt32Unsigned()   -- { 当前值 }
    self.count = r:readInt16Unsigned() -- { 数量 }
    self.msg2 = {} -- { 信息快16716 }
    for i=1,self.count do
        local msg = ACK_ART_ID_STATE()
        msg : decode( r )
        self.msg2[i]=msg
    end
end
-- end16715
-- (16716手动) -- [16716]Id_sub状态 -- 精彩活动 
ACK_ART_ID_STATE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_ID_STATE
    self:init()
end)

function ACK_ART_ID_STATE.decode(self, r)
    self.id_sub = r:readInt32Unsigned() -- { 阶段Id }
    self.state = r:readInt8Unsigned() -- { 状态 }
    self.ex_value = r:readInt32Unsigned() -- { 额外值 }
    self.ex_good = r:readInt32Unsigned() -- { 额外奖励物品id }
    self.ex_count = r:readInt16Unsigned() -- { 额外奖励物品数量 }
    self.value = r:readInt16Unsigned() -- { 阶段值 }
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.msg = {}
    for i=1,self.count do
        local msg = ACK_ART_GOOD_INFO()
        msg : decode( r )
        self.msg[i]=msg
    end
end
-- end16716
-- (16749手动) -- [16749]排行 -- 精彩活动(不使用) 
ACK_ART_RANK_TOP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_RANK_TOP
    self:init()
end)

function ACK_ART_RANK_TOP.decode(self, r)
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.msg = {} -- { 信息16750 }
    for i=1,self.count do
        local msg = ACK_ART_RANK()
        msg : decode( r )
        self.msg[i]=msg
    end
end
-- end16749
-- (16750手动) -- [16750]排行榜 -- 精彩活动(不使用) 
ACK_ART_RANK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_RANK
    self:init()
end)

function ACK_ART_RANK.decode(self, r)
    self.id = r:readInt32Unsigned() -- { 活动id }
    self.selfrank = r:readInt32Unsigned() -- { 自身排名 }
    self.start = r:readInt32Unsigned() -- { 开始时间 }
    self.endtime = r:readInt32Unsigned() -- { 结束时间 }
    self.cmp = r:readInt32Unsigned()   -- { 当前值 }
    self.count = r:readInt16Unsigned() -- { 数量 }
    self.msg = {} -- { msg16755 }
    for i=1,self.count do
        local msg = ACK_ART_MSG_RANK()
        msg : decode( r )
        self.msg[i]=msg
    end
end
-- end16750
-- (16765手动) -- [16765]角标返回 -- 精彩活动 
ACK_ART_ICON_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_ICON_CB
    self:init()
end)

function ACK_ART_ICON_CB.decode(self, r)
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.msg = {} -- { 16770 }
    for i=1,self.count do
        local msg = ACK_ART_ICON_MSG()
        msg : decode( r )
        self.msg[i]=msg
    end
end
-- end16765
-- (16780手动) -- [16780]福泽天下请求回 -- 精彩活动 
ACK_ART_FZTX_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_FZTX_CB
    self:init()
end)

function ACK_ART_FZTX_CB.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 活动id }
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.msg = {} -- { 16783 }
    for i=1,self.count do
        local msg = ACK_ART_MSG1()
        msg : decode( r )
        self.msg[i]=msg
    end
end
-- end16780
-- (16783手动) -- [16783]福泽天下信息块 -- 精彩活动 
ACK_ART_MSG1 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_MSG1
    self:init()
end)

function ACK_ART_MSG1.decode(self, r)
    self.id_sub = r:readInt32Unsigned() -- {阶段Id}
    self.count2 = r:readInt8Unsigned() -- { 数量 }
    self.msg2 = {} -- { 信息块16785 }
    for i=1,self.count2 do
        local msg = ACK_ART_MSG2()
        msg : decode( r )
        self.msg2[i]=msg
    end
end
-- end16783
-- (16795手动) -- [16795]充值界面倍数显示 -- 精彩活动 
ACK_ART_PER_CHARGE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_PER_CHARGE
    self:init()
end)

function ACK_ART_PER_CHARGE.decode(self, r)
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.msg = {} -- { 信息块16796 }
    for i=1,self.count do
        local msg = ACK_ART_MSG_CHARGE()
        msg : decode( r )
        self.msg[i]=msg
    end
end
-- end16795
-- (16798手动) -- [16798]转盘物品(回) -- 精彩活动 
ACK_ART_ZHUANPAN_GOOD = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_ZHUANPAN_GOOD
    self:init()
end)

function ACK_ART_ZHUANPAN_GOOD.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 活动id }
    self.use_id = r:readInt32Unsigned() -- { 活动id }
    self.use_count = r:readInt8Unsigned() -- { 数量 }
    self.count = r:readInt16Unsigned() -- { 数量 }
    self.msg = {} -- { 信息快16799 }
    for i=1,self.count do
        local msg = ACK_ART_ZHUANPAN_GOODMSG()
        msg : decode( r )
        self.msg[msg.idx]=msg
    end
end
-- end16798
-- (18020手动) -- [18020]请求界面返回 -- 降魔之路 
ACK_XMZL_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_XMZL_REPLY
    self:init()
end)

function ACK_XMZL_REPLY.decode(self, r)
    self.floor = r:readInt16Unsigned() -- { 层数 }
    self.hp = r:readInt32Unsigned() -- { 剩余血量 }
    self.wing_id = r:readInt16Unsigned() -- { 出战宠物 }
    self.attr_point = r:readInt16Unsigned() -- { 剩余属性点 }
    self.attr_point_all = r:readInt16Unsigned() -- { 总共属性点 }
    self.count = r:readInt16Unsigned() -- { 数量 }
    self.msg_attr = {} -- { 属性块(18025) }
    for i=1,self.count do
        local msg = ACK_XMZL_ATTR_XXX()
        msg : decode( r )
        self.msg_attr[i]=msg
    end
end
-- end18020
-- (18070手动) -- [18070]副本信息 -- 降魔之路 
ACK_XMZL_COPYS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_XMZL_COPYS
    self:init()
end)

function ACK_XMZL_COPYS.decode(self, r)
    self.count = r:readInt16Unsigned() -- { 副本数量 }
    self.msg_xxx = {} -- { 副本信息块 }
    for i=1,self.count do
        local msg = ACK_XMZL_COPY_XXX()
        msg : decode( r )
        self.msg_xxx[i]=msg
    end
end
-- end18070
-- (18080手动) -- [18080]进入副本信息 -- 降魔之路 
ACK_XMZL_PLAYER_INFO = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_XMZL_PLAYER_INFO
    self:init()
end)

function ACK_XMZL_PLAYER_INFO.decode(self, r)
    self.hp = r:readInt32Unsigned() -- { 玩家剩余血量 }
    self.powerful = r:readInt32Unsigned() -- { 玩家最高战斗力 }
    self.relive_times = r:readInt8Unsigned() -- { 可复活次数 }
    self.count = r:readInt16Unsigned() -- { 数量 }
    self.msg_attr = {} -- { 属性块(18025) }
    for i=1,self.count do
        local msg = ACK_XMZL_ATTR_XXX()
        msg : decode( r )
        self.msg_attr[i]=msg
    end
end
-- end18080
-- (18130手动) -- [18130]修为状态列表 -- 修为 
ACK_HONOR_LIST_RETURN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HONOR_LIST_RETURN
    self:init()
end)

function ACK_HONOR_LIST_RETURN.decode(self, r)
    self.type = r:readInt8Unsigned() -- {1:火影目标2:角色成长3:强者之路4:角色历练5:神宠神骑6:浴血沙场}
    self.count = r:readInt16Unsigned() -- {数量}
    self.id = r:readInt32Unsigned() -- {修为ID}
    self.state = r:readInt8Unsigned() -- {0:未完成1:完成未领取2:已领取}
    self.value = r:readInt16Unsigned() -- {进度当前值}
end
-- end18130
-- (18150手动) -- [18150]修为达成提示 -- 修为 
ACK_HONOR_REACH_TIP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HONOR_REACH_TIP
    self:init()
end)

function ACK_HONOR_REACH_TIP.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    self.type = r:readInt16Unsigned() -- {修为类型}
    self.type_sub = r:readInt16Unsigned() -- {修为子类型}
    self.id = r:readInt32Unsigned() -- {修为ID}
end
-- end18150
-- (21135手动) -- [21135]所有怪物数据返回 -- 活动-保卫经书 
ACK_DEFEND_BOOK_OK_MONST_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_OK_MONST_DATA
    self:init()
end)

function ACK_DEFEND_BOOK_OK_MONST_DATA.decode(self, r)
    self.num = r:readInt8Unsigned() -- {第几波怪物}
    self.count = r:readInt16Unsigned() -- {数量}
    self.monst_data = r:readXXXGroup() -- {怪物组协议块【21136】}
end
-- end21135
-- (21145手动) -- [21145]对怪物累计伤害前10排名 -- 活动-保卫经书 
ACK_DEFEND_BOOK_RANKING = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_RANKING
    self:init()
end)

function ACK_DEFEND_BOOK_RANKING.decode(self, r)
    self.next_harm = r:readInt32Unsigned() -- {开启下一级增益需要的伤害值}
    self.count = r:readInt16Unsigned() -- {数量}
    self.rank_date = r:readXXXGroup() -- {伤害前10排名数据块 [21150]}
end
-- end21145
-- (21170手动) -- [21170]战壕数据 -- 活动-保卫经书 
ACK_DEFEND_BOOK_TRENCH_DATE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_TRENCH_DATE
    self:init()
end)

function ACK_DEFEND_BOOK_TRENCH_DATE.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    self.data_trench = r:readXXXGroup() -- {战壕信息块[21147]}
end
-- end21170
-- (21175手动) -- [21175]单个防守圈玩家数据 -- 活动-保卫经书 
ACK_DEFEND_BOOK_PLAYER_DATE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_PLAYER_DATE
    self:init()
end)

function ACK_DEFEND_BOOK_PLAYER_DATE.decode(self, r)
    self.trench_num = r:readInt8Unsigned() -- {防守圈编号：1-9}
    self.count = r:readInt16Unsigned() -- {数量}
    self.data_palyer = r:readXXXGroup() -- {防守圈内玩家信息块【21180】}
end
-- end21175
-- (21227手动) -- [21227]击杀掉落 -- 活动-保卫经书 
ACK_DEFEND_BOOK_KILL_REWARDS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_KILL_REWARDS
    self:init()
end)

function ACK_DEFEND_BOOK_KILL_REWARDS.decode(self, r)
    self.gmid = r:readInt32Unsigned() -- {被击杀的怪物生成Id}
    self.count = r:readInt16Unsigned() -- {数量}
    self.rewards = r:readXXXGroup() -- {物品信息块2001}
end
-- end21227
-- (21270手动) -- [21270]开启增益 -- 活动-保卫经书 
ACK_DEFEND_BOOK_START_BUFF = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_START_BUFF
    self:init()
end)

function ACK_DEFEND_BOOK_START_BUFF.decode(self, r)
    self.type = r:readInt8Unsigned() -- {增益类型}
    self.buff_val = r:readInt32Unsigned() -- {增益数值}
    self.count = r:readInt16Unsigned() -- {数量}
    self.player_data = r:readXXXGroup() -- {战壕玩家信息块[21180]}
end
-- end21270
-- (21290手动) -- [21290]领取增益成功 -- 活动-保卫经书 
ACK_DEFEND_BOOK_OK_GAIN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_OK_GAIN
    self:init()
end)
-- end21290
-- (22120手动) -- [22120]浮屠静修返回 -- 浮屠静修 
ACK_FUTU_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FUTU_REPLY
    self:init()
end)

function ACK_FUTU_REPLY.decode(self, r)
    self.floor = r:readInt8Unsigned() -- { 自己最高层数 }
    self.floor2 = r:readInt8Unsigned() -- { 当前占领层数 }
    self.times = r:readInt16Unsigned() -- { 剩余挑战次数 }
    self.pos   = r:readInt8Unsigned() -- { 当前占领位置 }
    self.buy_time = r:readInt8Unsigned() -- { 剩余购买次数 }
    self.count = r:readInt16Unsigned() -- { 数量 }
    local icount = 1
    self.msg_xxx = {}
    while icount <= self.count do
        local tempData = ACK_FUTU_MSG()
        tempData :decode( r)
        self.msg_xxx[tempData.floor] = tempData
        icount = icount + 1
    end
end
-- end22120
-- (22125手动) -- [22125]浮屠静修信息块 -- 浮屠静修 
ACK_FUTU_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FUTU_MSG
    self:init()
end)

function ACK_FUTU_MSG.decode(self, r)
    self.floor = r:readInt8Unsigned() -- { 层数 }
    self.count = r:readInt16Unsigned() -- { 数量 }
    local icount = 1
    self.msg_xxx2 = {}
    while icount <= self.count do
        print("第 "..self.floor.." 层数据:")
        local tempData = ACK_FUTU_MSG2()
        tempData :decode( r)
        self.msg_xxx2[tempData.pos+1] = tempData
        print("pos:",self.msg_xxx2[tempData.pos+1].pos,"  uid:",self.msg_xxx2[tempData.pos+1].uid,"  pro:",self.msg_xxx2[tempData.pos+1].pro," name:",self.msg_xxx2[tempData.pos+1].name)
        icount = icount + 1
    end

end
-- end22125
-- (22150手动) -- [22150]战报返回 -- 浮屠静修 
ACK_FUTU_HISTORY_REP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FUTU_HISTORY_REP
    self:init()
end)

function ACK_FUTU_HISTORY_REP.decode(self, r)
    self.count = r:readInt16Unsigned() -- { 数量 }
   
    local icount = 1
    self.msg_xxx = {}
    while icount <= self.count do
        print("第 "..icount.." 个社团活动数据:")
        local tempData = ACK_FUTU_HISTORY_MSG()
        tempData :decode( r)
        self.msg_xxx[icount] = tempData
        print("战报类型：",tempData.type)
        icount = icount + 1
    end
end
-- end22150
-- (22155手动) -- [22155]历史信息块 -- 浮屠静修 
ACK_FUTU_HISTORY_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FUTU_HISTORY_MSG
    self:init()
end)

function ACK_FUTU_HISTORY_MSG.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 类型 }
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.name = r:readString() -- { 玩家名字 }
    self.floor = r:readInt8Unsigned() -- { 层数 }
    self.flag = r:readInt8Unsigned() -- { 1成功/0失败 }
    self.time = r:readInt32Unsigned() -- { 时间戳 }
    self.time2 = r:readInt32Unsigned() -- { 占领时间长度 }
    self.count = r:readInt16Unsigned()
    local icount = 1
    self.msg_xxx2 = {}
    while icount <= self.count do
        print("第 "..icount.." 个社团活动数据:")
        local tempData = ACK_FUTU_HISTORY_MSG2()
        tempData :decode( r)
        self.msg_xxx2[tempData.good_id] = tempData
        icount = icount + 1
    end
end
-- end22155
-- (22212手动) -- [22212]消费板子返回 -- 每天消费 
ACK_COST_FACE_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COST_FACE_BACK
    self:init()
end)

function ACK_COST_FACE_BACK.decode(self, r)
    self.rmb = r:readInt32Unsigned() -- {消费rmb}
    self.count = r:readInt8Unsigned() -- {数量}
    -- self.use_list = r:readXXXGroup() -- {已领取奖励(22215)}
    self.use_list = {}
    if self.count > 0 then
        for i=1,self.count do
            local msg = ACK_COST_USE_ID()
            msg : decode( r )
            self.use_list[i]=msg
        end
    end
end
-- end22212
-- (22311手动) -- [22311]节日活动返回 -- 节日转盘 
ACK_GALATURN_FUN_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GALATURN_FUN_CB
    self:init()
end)

function ACK_GALATURN_FUN_CB.decode(self, r)
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.msg = {} -- { 信息22312 }
    for i=1,self.count do
        local msg = ACK_GALATURN_MSG_ID()
        msg : decode( r )
        self.msg[i]=msg
    end
end
-- end22311
-- (22314手动) -- [22314]板子内容 -- 节日转盘 
ACK_GALATURN_IN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GALATURN_IN
    self:init()
end)

function ACK_GALATURN_IN.decode(self, r)
    self.times = r:readInt16Unsigned() -- { 免费次数 }
    self.selfrank = r:readInt16Unsigned() -- { 排名 }
    self.point = r:readInt32Unsigned() -- { 积分 }
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.msg = {} -- { 物品信息块22315 }
    for i=1,self.count do
        local msg = ACK_GALATURN_MSG_TURN_GOOD()
        msg : decode( r )
        self.msg[i]=msg
    end
end
-- end22314
-- (22332手动) -- [22332]排名板子内容 -- 节日转盘 
ACK_GALATURN_RANK_IN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GALATURN_RANK_IN
    self:init()
end)

function ACK_GALATURN_RANK_IN.decode(self, r)
    self.selfrank = r:readInt16Unsigned() -- {自己排名}
    self.count2 = r:readInt8Unsigned() -- {物品数}
    self.rank_good = {}--r:readXXXGroup() -- {总物品信息块(22335)}
    if self.count2 <= 0 then return end
    for i=1,self.count2 do
        local msg = ACK_GALATURN_RANK_GOOD()
        msg : decode( r )
        self.rank_good[i]=msg
    end

    self.count = r:readInt8Unsigned() -- {排名数}
    self.rank_msg = {}--r:readXXXGroup() -- {总排行信息块(22335)}
    if self.count <= 0 then return end
    for i=1,self.count do
        local msg = ACK_GALATURN_RANK_MSG()
        msg : decode( r )
        self.rank_msg[i]=msg
    end
end
-- end22332
-- (22337手动) -- [22337]排名物品奖励信息 -- 节日转盘 
ACK_GALATURN_RANK_GOOD = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GALATURN_RANK_GOOD
    self:init()
end)

function ACK_GALATURN_RANK_GOOD.decode(self, r)
    self.id_sub = r:readInt8Unsigned() -- { 排名 }
    self.point = r:readInt32Unsigned() -- { 额外奖励积分要求 }
    self.ex_goodid = r:readInt32Unsigned() -- { 额外奖励物品id }
    self.ex_count = r:readInt16Unsigned() -- { 额外奖励数量 }
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.msg = {} -- { 物品信息22338 }
    for i=1,self.count do
        local msg = ACK_GALATURN_MSG_RANK2_GOOD()
        msg : decode( r )
        self.msg[i]=msg
    end
end
-- end22337
-- (22342手动) -- [22342]积分板子 -- 节日转盘 
ACK_GALATURN_POINT_IN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GALATURN_POINT_IN
    self:init()
end)

function ACK_GALATURN_POINT_IN.decode(self, r)
    self.point = r:readInt32Unsigned() -- {自己积分}
    self.count = r:readInt8Unsigned() -- {数量}
    self.get_msg = {}--r:readXXXGroup() -- {领取信息快}
    if self.count <= 0 then return end
    for i=1,self.count do
        local msg = ACK_GALATURN_GET_ID()
        msg : decode( r )
        self.get_msg[i]=msg
        print("ACK_GALATURN_RANK_IN --22342-->",i,msg.name,msg.point)
    end
end
-- end22342
-- (22355手动) -- [22355]角标返回 -- 节日转盘 
ACK_GALATURN_ICON_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GALATURN_ICON_CB
    self:init()
end)

function ACK_GALATURN_ICON_CB.decode(self, r)
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.msg = {} -- { 信息快22360 }
    for i=1,self.count do
        local msg = ACK_GALATURN_MSG_ICON()
        msg : decode( r )
        self.msg[i]=msg
    end
end
-- end22355
-- (22760手动) -- [22760]获得|失去通知 -- 日志 
ACK_GAME_LOGS_NOTICES = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GAME_LOGS_NOTICES
    self:init()
end)

function ACK_GAME_LOGS_NOTICES.decode(self, r)
    self.type = r:readInt8Unsigned() -- {类型：CONST_LOGS_TYPE_XX 1 - 4}
    self.count = r:readInt16Unsigned() -- {数量}
    --self.mess = r:readXXXGroup() -- {信息组协议块 [22770]}
    self.mess = {}
    for i=1,self.count do
        local mess = ACK_GAME_LOGS_MESS()
        mess : decode( r )
        self.mess[i]=mess
    end
end
-- end22760
-- (22780手动) -- [22780]事件通知 -- 日志 
ACK_GAME_LOGS_EVENT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GAME_LOGS_EVENT
    self:init()
end)

function ACK_GAME_LOGS_EVENT.decode(self, r)
    self.id = r:readInt16Unsigned() -- {事件ID}
    print("LOG ID: ",self.id)
    self.count_str = r:readInt16Unsigned() -- {字符串数量}
    self.str_module = {} --r:readXXXGroup() -- {字符串信息块[22781]}
    for i=1,self.count_str do
        local tmp = ACK_GAME_LOGS_STR_XXX()
        tmp : decode( r )
        self.str_module[i]=tmp
    end
    self.count_int = r:readInt16Unsigned() -- {数字数量}
    self.int_module = {}--r:readXXXGroup() -- {数字信息块[22782]}
    for i=1,self.count_int do
        local tmp = ACK_GAME_LOGS_INT_XXX()
        tmp : decode( r )
        self.int_module[i]=tmp
    end
end
-- end22780
-- (22820手动) -- [22820]返回宠物列表 -- 宠物 
ACK_PET_REVERSE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_PET_REVERSE
    self:init()
end)

function ACK_PET_REVERSE.decode(self, r)
    self.lv       = r:readInt8Unsigned()   -- {宠物等级}
    self.skin_id  = r:readInt16Unsigned()  -- {皮肤id}
    self.skill_id = r:readInt16Unsigned()  -- {技能id}
    self.exp      = r:readInt16Unsigned()  -- {当前经验值}
    
    self.count    = r:readInt8Unsigned()   -- {式神数量}
    print("-----------------44444--------",self.lv,self.skin_id,self.skill_id,self.exp,self.count)
    self.MsgSkill = {}
    local icount  = 1
    while icount <= self.count do
        self.MsgSkill[icount] = r:readInt16Unsigned()
        icount = icount + 1
    end
    
    self.count2    = r:readInt8Unsigned()   -- {皮肤数量} 
    print("self.count2===",self.count2)
    self.MsgSkin   = {}
    local icount2  = 1
    while icount2 <= self.count2 do
        --print ("妥妥的是不是",r:readInt16Unsigned())
        self.MsgSkin[icount2] = r:readInt16Unsigned()
        print("然后呢？？",self.MsgSkin[icount2])
        icount2 = icount2 + 1
    end
end
-- end22820
-- (23010手动) -- [23010]幻化界面返回 -- 宠物 
ACK_PET_HH_REPLY_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_PET_HH_REPLY_MSG
    self:init()
end)

function ACK_PET_HH_REPLY_MSG.decode(self, r)
    self.count   = r:readInt8Unsigned()  -- {皮肤数量}
    self.skin_id = r:readInt16Unsigned() -- {使用中的皮肤id}
    --self.skin_id = r:readInt16Unsigned() -- {皮肤id}
    self.MsgSkin = {}
    local icount  = 1
    while icount <= self.count do
        self.MsgSkin[icount] = r:readInt16Unsigned()
        icount = icount + 1
    end
end
-- end23010
-- (23212手动) -- [23212]寻宝界面返回(旧) -- 活动-全民寻宝 
ACK_ALLFIND_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ALLFIND_REPLY
    self:init()
end)

function ACK_ALLFIND_REPLY.decode(self, r)
    self.count1 = r:readInt16Unsigned()
    self.data1 = {}--r:readInt16Unsigned()
    for i=1,self.count1 do
        -- {领取等级}
        self.data1[i] = ACK_ALLFIND_MSG2()
        self.data1[i] : decode(r)
    end
    
    self.count2 = r:readInt16Unsigned() -- {数量}
    self.data2 = {} -- {寻宝历史}
    for i=1,self.count2 do
        -- {领取等级}
        self.data2[i] = ACK_ALLFIND_MSG1()
        self.data2[i] : decode(r)
    end
end
-- end23212
-- (23242手动) -- [23242]寻宝界面返回(新) -- 活动-全民寻宝 
ACK_ALLFIND_REP_NEW = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ALLFIND_REP_NEW
    self:init()
end)

function ACK_ALLFIND_REP_NEW.decode(self, r)
    self.count1 = r:readInt16Unsigned() -- {抽取数}
    -- self.msg1 = r:readXXXGroup() -- {次数信息块(新)23218}
    self.msg1 = {}
    if self.count1 > 0 then
        for i=1,self.count1 do
            self.msg1[i] = ACK_ALLFIND_MSG2()
            self.msg1[i] : decode(r)
        end
    end
    self.count2 = r:readInt16Unsigned() -- {历史}
    -- self.msg2 = r:readXXXGroup() -- {历史信息块(新)23245}
    self.msg2 = {}
    if self.count2 > 0 then
        for i=1,self.count2 do
            self.msg2[i] = ACK_ALLFIND_MSG1()
            self.msg2[i] : decode(r)
        end
    end
    
end
-- end23242
-- (23322手动) -- [23322]等级奖励返回 -- 奖励 
ACK_REWARD_LV_REP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_LV_REP
    self:init()
end)

function ACK_REWARD_LV_REP.decode(self, r)
    self.count = r:readInt16Unsigned() -- {个数}
    -- self.lv_msg = r:readXXXGroup() -- {等级领取信息块(P_REWARD_LV_MSG)}
    self.lv_msg = {}
    if self.count > 0 then
        for i=1,self.count do
            self.lv_msg[i] = ACK_REWARD_LV_MSG()
            self.lv_msg[i] : decode(r)
        end
    end
end
-- end23322
-- (23332手动) -- [23332]每日领奖返回 -- 奖励 
ACK_REWARD_DAILY_REP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_DAILY_REP
    self:init()
end)

function ACK_REWARD_DAILY_REP.decode(self, r)
    self.day_num = r:readInt16Unsigned() -- {登录天数}
    self.count   = r:readInt16Unsigned() -- {领取数量}
    -- self.daily_msg = r:readXXXGroup() -- {每日领取信息块P_REWARD_DAILY_MSG}
    self.daily_msg = {}
    if self.count > 0 then
        for i=1,self.count do
            self.daily_msg[i] = r:readInt16Unsigned() -- {领取等级}
        end
    end
end
-- end23332
-- (23495手动) -- [23495]vip奖励信息(返回) -- 奖励 
ACK_REWARD_VIP_MSG_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_VIP_MSG_CB
    self:init()
end)

function ACK_REWARD_VIP_MSG_CB.decode(self, r)
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.msg = {} -- { 物品信息块(23500) }
    if self.count > 0 then
        for i=1,self.count do
            local msg = ACK_REWARD_VIP_MSG_XXX()
            msg : decode( r )
            self.msg[i]=msg
        end
    end
end
-- end23495
-- (23500手动) -- [23500]vip奖励信息块 -- 奖励 
ACK_REWARD_VIP_MSG_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_VIP_MSG_XXX
    self:init()
end)

function ACK_REWARD_VIP_MSG_XXX.decode(self, r)
    self.viplv = r:readInt8Unsigned() -- { vip等级 }
    self.state = r:readInt8Unsigned() -- { 领取状态 }
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.msg_xxx = {} -- { 信息快 }
    if self.count > 0 then
        for i=1,self.count do
            local msg = ACK_REWARD_VIP_MSG_XXX2()
            msg : decode( r )
            self.msg_xxx[i]=msg
        end
    end
end
-- end23500
-- (23630手动) -- [23630]所有已经冲过值的金额 -- 奖励 
ACK_REWARD_LOGS_PAY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_LOGS_PAY
    self:init()
end)

function ACK_REWARD_LOGS_PAY.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    -- self.msg_xxx = r:readXXXGroup() -- {充值金额信息块}
    self.msg_xxx = {}
    if self.count  > 0 then
        for i=1,self.count do
            local msg = ACK_REWARD_MSG_LOGS_PAY()
            msg : decode( r )
            self.msg_xxx[i]=msg
        end
    end
end
-- end23630
-- (23660手动) -- [23660]登陆界面返回 -- 奖励 
ACK_REWARD_LOGIN_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_LOGIN_REPLY
    self:init()
end)

function ACK_REWARD_LOGIN_REPLY.decode(self, r)
    self.time_begin = r:readInt32Unsigned() -- {开始时间戳}
    self.time_end = r:readInt32Unsigned() -- {结束时间戳}
    self.state = r:readInt8Unsigned() -- {领取状态(1已领取0未领取)}
    self.count = r:readInt16Unsigned() -- {数量}
    -- self.msg_xxx = r:readXXXGroup() -- {物品信息块(23670)}
    self.m_msg = {}
    if self.count > 0 then
        for i=1,self.count do
            
            local tempData = ACK_REWARD_LOGIN_MSG_XXX()
            tempData:decode(r)
            self.m_msg[i] = tempData
        end
    end
end
-- end23660
-- (23820手动) -- [23820]可以挑战的玩家列表(新) -- 封神台 
ACK_ARENA_DEKARON = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ARENA_DEKARON
    self:init()
end)

function ACK_ARENA_DEKARON.decode(self, r)
    print( "##########################\n逐鹿台协议返回")
    self.arena_lv     = r:readInt16Unsigned()  -- {世界封神等级}
    self.time         = r:readInt32Unsigned()   -- {冷却剩余时间}
    self.renown       = r:readInt32Unsigned()  -- {妖魂}
    self.count        = r:readInt16Unsigned()  -- {玩家个数}
    print( "世界封神等级:",self.arena_lv,"\n冷却剩余时间:",self.time,"\n我的妖魂:",self.renown,"\n玩家个数:",self.count)
    
    --self.challageplayerdata = r:readXXXGroup()
    self.challageplayerdata = {}   -- {[23821]可以挑战的玩家 -- 逐鹿台  ACK_ARENA_CANBECHALLAGE }
    local icount = 1
    while icount <= self.count do
        self.challageplayerdata[icount] = {}
        self.challageplayerdata[icount].sid       = r:readInt16Unsigned() -- {服务器ID}
        self.challageplayerdata[icount].pro       = r:readInt8Unsigned() -- {玩家职业}
        self.challageplayerdata[icount].sex       = r:readInt8Unsigned() -- {玩家性别}
        self.challageplayerdata[icount].lv        = r:readInt16Unsigned() -- {玩家等级}
        self.challageplayerdata[icount].uid       = r:readInt32Unsigned() -- {玩家UID}
        self.challageplayerdata[icount].name      = r:readUTF() -- {玩家名字}
        self.challageplayerdata[icount].ranking   = r:readInt16Unsigned() -- {玩家排名}
        self.challageplayerdata[icount].win_count = r:readInt8Unsigned() -- {连胜次数}
        self.challageplayerdata[icount].surplus   = r:readInt8Unsigned() -- {剩余挑战次数}
        self.challageplayerdata[icount].power   = r:readInt32Unsigned() -- {战斗力}
        print( "玩家名字：",self.challageplayerdata[icount].name, "玩家等级：",self.challageplayerdata[icount].lv,"玩家排名",self.challageplayerdata[icount].ranking,"连胜次数",self.challageplayerdata[icount].win_count,"战斗力",self.challageplayerdata[icount].power)
        icount = icount +1
    end
end
-- end23820
-- (23831手动) -- [23831]战斗信息块 -- 封神台 
ACK_ARENA_WAR_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ARENA_WAR_DATA
    self:init()
end)

function ACK_ARENA_WAR_DATA.decode(self, r)
    self.msg_war_xxx = r:readXXXGroup() -- {战斗数据块 [6010]}
end
-- end23831
-- (23930手动) -- [23930]返回高手信息 -- 封神台 
ACK_ARENA_KILLER_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ARENA_KILLER_DATA
    self:init()
end)

function ACK_ARENA_KILLER_DATA.decode(self, r)
    print( "##########################\n高手信息 -- 封神台 返回")
    self.rank    = r:readInt16Unsigned()  -- {自己的排名}
    self.zrenown = r:readInt32Unsigned()  -- {自己可获得的妖魂}
    self.zgold   = r:readInt32Unsigned()  -- {自己可获得的铜钱}
    self.count   = r:readInt16Unsigned()  -- {数量}    
    print("玩家排名:",self.rank,"玩家可获得妖魂:",self.zrenown,"玩家可获得铜钱:",self.zgold,"玩家高手数量:",self.count)

    --self.AAA = r:readXXXGroup()
    self.msg_killer_xxx = {}   -- {[23931]高手信息 -- 封神台  ACK_ARENA_ACE}
    local icount = 1
    while icount <= self.count do
        self.msg_killer_xxx[icount] = {}
        self.msg_killer_xxx[icount].ranking   = r:readInt16Unsigned() -- {玩家排名}        
        self.msg_killer_xxx[icount].uid       = r:readInt32Unsigned() -- {玩家UID}
        self.msg_killer_xxx[icount].name      = r:readUTF()           -- {玩家名字}        
        self.msg_killer_xxx[icount].lv        = r:readInt16Unsigned() -- {玩家等级}
        self.msg_killer_xxx[icount].pro        = r:readInt8Unsigned()  -- {玩家等级}
        self.msg_killer_xxx[icount].power     = r:readInt32Unsigned() -- {玩家战斗力}
        self.msg_killer_xxx[icount].renown    = r:readInt32Unsigned() -- {玩家可获得妖魂}
        self.msg_killer_xxx[icount].gold      = r:readInt32Unsigned() -- {玩家可获得铜钱}

        print( "玩家名字：",self.msg_killer_xxx[icount].name, "玩家等级：",self.msg_killer_xxx[icount].lv,"玩家排名",self.msg_killer_xxx[icount].ranking,"玩家可获得妖魂",self.msg_killer_xxx[icount].renown,"玩家职业:",self.msg_killer_xxx[icount].pro)
        icount = icount +1
    end --while
end
-- end23930
-- (23940手动) -- [23940]返回最竞技场信息 -- 封神台 
ACK_ARENA_MAX_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ARENA_MAX_DATA
    self:init()
end)

function ACK_ARENA_MAX_DATA.decode(self, r)
    self.count = r:readInt16Unsigned() -- {竞技场挑战结果信息}
    self.data = {}--r:readXXXGroup() -- {信息块（23850）}
    for i=1,self.count do
        local tempData = ACK_ARENA_RADIO()
        tempData:decode(r)
        self.data[i] = tempData
    end
    print("ACK_ARENA_MAX_DATA.decode--->>>",self.count)
end
-- end23940
-- (23970手动) -- [23970]领取结果 -- 封神台 
ACK_ARENA_GET_REWARD = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ARENA_GET_REWARD
    self:init()
end)

function ACK_ARENA_GET_REWARD.decode(self, r)
    self.gold     = r:readInt32Unsigned() -- {银元}
    self.renown   = r:readInt32Unsigned() -- {妖魂}
    self.star     = r:readInt32Unsigned() -- {星魂}
    self.count    = r:readInt16Unsigned() -- {物品数量}
    self.data = {}   -- {物品信息块( P_GOODS_XXX1)}
    local icount = 1
    while icount <= self.count do
        self.data[icount].goods_id     = r:readInt16Unsigned()
        icount = icount +1
    end --while
end
-- end23970
-- (24050手动) -- [24050]可以挑战的玩家列表(新) -- 竞技场 
ACK_ARENA_DEKARON_NEW = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ARENA_DEKARON_NEW
    self:init()
end)

function ACK_ARENA_DEKARON_NEW.decode(self, r)
    self.arena_lv = r:readInt16Unsigned() -- { 竞技等级 }
    self.time = r:readInt32Unsigned() -- {  }
    self.renown = r:readInt32Unsigned() -- {  }
    self.count = r:readInt16Unsigned() -- { 数量 }
    -- self.data = r:readXXXGroup() -- { 信息块24060 }
    self.challageplayerdata = {}   -- {[23821]可以挑战的玩家 -- 逐鹿台  ACK_ARENA_CANBECHALLAGE }
    local icount = 1
    while icount <= self.count do
        self.challageplayerdata[icount] = {}
        self.challageplayerdata[icount].sid       = r:readInt16Unsigned() -- {服务器ID}
        self.challageplayerdata[icount].pro       = r:readInt8Unsigned() -- {玩家职业}
        self.challageplayerdata[icount].sex       = r:readInt8Unsigned() -- {玩家性别}
        self.challageplayerdata[icount].lv        = r:readInt16Unsigned() -- {玩家等级}
        self.challageplayerdata[icount].uid       = r:readInt32Unsigned() -- {玩家UID}
        self.challageplayerdata[icount].name      = r:readUTF() -- {玩家名字}
        self.challageplayerdata[icount].ranking   = r:readInt16Unsigned() -- {玩家排名}
        self.challageplayerdata[icount].win_count = r:readInt8Unsigned() -- {连胜次数}
        self.challageplayerdata[icount].surplus   = r:readInt8Unsigned() -- {剩余挑战次数}
        self.challageplayerdata[icount].power   = r:readInt32Unsigned() -- {战斗力}
        self.challageplayerdata[icount].lqid   = r:readInt16Unsigned() -- {武器ID}
        self.challageplayerdata[icount].syid   = r:readInt16Unsigned() -- {翅膀ID}
        print( "玩家名字：",self.challageplayerdata[icount].name, "玩家等级：",self.challageplayerdata[icount].lv,"玩家排名",self.challageplayerdata[icount].ranking,"连胜次数",self.challageplayerdata[icount].win_count,"战斗力",self.challageplayerdata[icount].power)
        icount = icount +1
    end
end
-- end24050
-- (24823手动) -- [24823]排行榜信息(新) -- 排行榜 
ACK_TOP_DATE_NEW2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TOP_DATE_NEW2
    self:init()
end)

function ACK_TOP_DATE_NEW2.decode(self, r)
    self.type = r:readInt8Unsigned() -- {排行类型(见常量?CONST_TOP_TYPE_)}
    self.self_rank = r:readInt16Unsigned() --{自己的排名}
    self.count = r:readInt16Unsigned() -- {数量}
    self.data = {} -- {信息块（24820）}
    for i=1,self.count do
        self.data[i]             = {}
        self.data[i].rank        = r:readInt16Unsigned()
        self.data[i].uid         = r:readInt32Unsigned()
        self.data[i].name        = r:readString()
        -- self.data[i].name_color  = r:readInt8Unsigned()
        self.data[i].lv          = r:readInt16Unsigned()
        self.data[i].pro          = r:readInt8Unsigned()
        self.data[i].clan_id     = r:readInt32Unsigned()
        self.data[i].clan_name   = r:readString()
        self.data[i].clan_master = r:readString()
        self.data[i].clan_lv     = r:readInt16Unsigned()
        self.data[i].power       = r:readInt32Unsigned()
        self.data[i].power_equip = r:readInt32Unsigned()
        self.data[i].power_magic = r:readInt32Unsigned()
        self.data[i].power_mount = r:readInt32Unsigned()
        self.data[i].power_matrix= r:readInt32Unsigned()
        self.data[i].fighter     = r:readInt16Unsigned()
        self.data[i].power_clan  = r:readInt32Unsigned() -- {门派总战斗力}
        self.data[i].power_baqi  = r:readInt32Unsigned()
        self.data[i].meiren      = r:readInt32Unsigned() --美人(星侣)战斗力
        self.data[i].power_wing  = r:readInt32Unsigned() --宠物战斗力
        self.data[i].star        = r:readInt16Unsigned() --副本星星颗数
        self.data[i].power_equip_gem = r:readInt32Unsigned() --副本星星颗数
        self.data[i].power_equip_streng = r:readInt32Unsigned() --副本星星颗数
        self.data[i].power_equip_equip = r:readInt32Unsigned() --副本星星颗数
        self.data[i].power_wuqi = r:readInt32Unsigned() --武器战力
        self.data[i].power_feather = r:readInt32Unsigned() --翅膀战力
        self.data[i].power_lingyao = r:readInt32Unsigned() --灵妖战力
    end
end
-- end24823
-- (24840手动) -- [24840]全部榜首返回 -- 排行榜 
ACK_TOP_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TOP_REPLY
    self:init()
end)

function ACK_TOP_REPLY.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    self.typeArray = {} -- {信息块(24850)}
    for i=1,self.count do
        self.typeArray[i]      = {}
        self.typeArray[i].type = r:readInt8Unsigned()
        self.typeArray[i].name = r:readString()
    end
end
-- end24840
-- (24920手动) -- [24920]领取成功 -- 新手卡 
ACK_CARD_SUCCEED = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CARD_SUCCEED
    self:init()
end)

function ACK_CARD_SUCCEED.decode(self, r)
    self.goods_count = r:readInt16Unsigned() -- {物品数量}
    self.goods_msg_no = r:readXXXGroup() -- {物品信息块(2001)}
end
-- end24920
-- (25020手动) -- [25020]可挑战玩家列表 -- 灵妖竞技场 
ACK_LINGYAO_ARENA_DEKARON = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ARENA_DEKARON
    self:init()
end)

function ACK_LINGYAO_ARENA_DEKARON.decode(self, r)
    self.time = r:readInt32Unsigned() -- { 倒计时秒 }
    self.count = r:readInt16Unsigned() -- { 数量 }
    self.challage_player_data = {}--r:readXXXGroup() -- { 信息块(25025) }
    for i=1,self.count do
        self.challage_player_data[i] = ACK_LINGYAO_ARENA_CANBECHALLAGE()
        self.challage_player_data[i] : decode(r)
    end
end
-- end25020
-- (25045手动) -- [25045]对手信息返回 -- 灵妖竞技场 
ACK_LINGYAO_ARENA_RIVAL_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ARENA_RIVAL_REPLY
    self:init()
end)

function ACK_LINGYAO_ARENA_RIVAL_REPLY.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.reval_data = {}--r:readXXXGroup() -- { 对手信息块(25050) }
    for i=1,self.count do
        self.reval_data[i] = ACK_LINGYAO_ARENA_RIVAL_DATA()
        self.reval_data[i] : decode(r)
    end
end
-- end25045
-- (25075手动) -- [25075]排行榜返回 -- 灵妖竞技场 
ACK_LINGYAO_ARENA_RANK_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ARENA_RANK_REPLY
    self:init()
end)

function ACK_LINGYAO_ARENA_RANK_REPLY.decode(self, r)
    self.rank = r:readInt16Unsigned() -- { 自己排名 }
    self.powerful = r:readInt32Unsigned() -- { 自己防守战斗力 }
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.goods_data = {}--r:readXXXGroup() -- { 排行榜数据块 }
    for i=1,self.count do
        self.goods_data[i] = ACK_LINGYAO_ARENA_GOODS_DATA()
        self.goods_data[i] : decode(r)
    end
    self.count2 = r:readInt8Unsigned() -- { 数量 }
    self.rank_data = {}--r:readXXXGroup() -- { 排行榜数据块 }
    for i=1,self.count2 do
        self.rank_data[i] = ACK_LINGYAO_ARENA_RANK_DATA()
        self.rank_data[i] : decode(r)
    end
end
-- end25075
-- (25080手动) -- [25080]排行榜数据块 -- 灵妖竞技场 
ACK_LINGYAO_ARENA_RANK_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ARENA_RANK_DATA
    self:init()
end)

function ACK_LINGYAO_ARENA_RANK_DATA.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.name = r:readString() -- { 玩家名字 }
    self.lv = r:readInt16Unsigned() -- { 玩家等级 }
    self.powerful = r:readInt32Unsigned() -- { 玩家战斗力 }
    self.rank = r:readInt16Unsigned() -- { 玩家排名 }
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.goods_data = {}--r:readXXXGroup() -- { 物品信息块(25078) }
    for i=1,self.count do
        self.goods_data[i] = ACK_LINGYAO_ARENA_GOODS_DATA()
        self.goods_data[i] : decode(r)
    end
end
-- end25080
-- (25092手动) -- [25092]战报返回 -- 灵妖竞技场 
ACK_LINGYAO_ARENA_REPORT_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ARENA_REPORT_REPLY
    self:init()
end)

function ACK_LINGYAO_ARENA_REPORT_REPLY.decode(self, r)
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.report_data = {}--r:readXXXGroup() -- { 战报数据块(25095) }
    for i=1,self.count do
        self.report_data[i] = ACK_LINGYAO_ARENA_REPORT_DATA()
        self.report_data[i] : decode(r)
    end
end
-- end25092
-- (25115手动) -- [25115]防守阵容返回 -- 灵妖竞技场 
ACK_LINGYAO_ARENA_DEF_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ARENA_DEF_REPLY
    self:init()
end)

function ACK_LINGYAO_ARENA_DEF_REPLY.decode(self, r)
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.def_data = {}--r:readXXXGroup() -- { 阵容信息块 }
    for i=1,self.count do
        self.def_data[i] = ACK_LINGYAO_ARENA_DEF_DATA()
        self.def_data[i] : decode(r)
    end
end
-- end25115
-- (25142手动) -- [25142]挑战返回 -- 灵妖竞技场 
ACK_LINGYAO_ARENA_BATTLE_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ARENA_BATTLE_REPLY
    self:init()
end)

function ACK_LINGYAO_ARENA_BATTLE_REPLY.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 被挑战者的id }
    self.name = r:readString() -- { 被挑战者的名字 }
    self.lv = r:readInt16() -- { 被挑战者的等级 }
    self.pro = r:readInt8Unsigned() -- { 被挑战者的职业 }
    self.rank = r:readInt16Unsigned() -- { 被挑战者的排名 }
    self.key = r:readString() -- { 验证字符串 }
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.lingyao_data = {} --r:readXXXGroup() -- { 自己的灵妖信息块 }
    for i=1,self.count do
        local tempData=ACK_LINGYAO_ARENA_DATA()
        tempData:decode(r)
        self.lingyao_data[i]=tempData
    end
    self.count2 = r:readInt8Unsigned() -- { 数量 }
    self.lingyao_data2 = {} --r:readXXXGroup() -- { 被挑战者的灵妖信息块 }
    for i=1,self.count2 do
        local tempData=ACK_LINGYAO_ARENA_DATA()
        tempData:decode(r)
        self.lingyao_data2[i]=tempData
    end
end
-- end25142
-- (25144手动) -- [25144]灵妖信息块 -- 灵妖竞技场 
ACK_LINGYAO_ARENA_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ARENA_DATA
    self:init()
end)

function ACK_LINGYAO_ARENA_DATA.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 灵妖id }
    self.lv = r:readInt16Unsigned() -- { 灵妖等级 }
    self.pos = r:readInt8Unsigned() -- { 灵妖位置 }
    -- self.attr = r:readInt8Unsigned() -- { 2002 }
    self.attr = ACK_GOODS_XXX2()
    self.attr:decode(r)
end
-- end25144
-- (25155手动) -- [25155]挑战完成返回 -- 灵妖竞技场 
ACK_LINGYAO_ARENA_OVER_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ARENA_OVER_REPLY
    self:init()
end)

function ACK_LINGYAO_ARENA_OVER_REPLY.decode(self, r)
    self.result = r:readInt8Unsigned() -- { 最终结果 结果(1完胜:2胜利:3平局4:失败5:完败) }
    self.rank = r:readInt16Unsigned() -- { 挑战后的排名 }
    self.up = r:readInt16Unsigned() -- { 上升多少名 }
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.goods_data = {}
    for i=1,self.count do
        local tempData={}
        tempData.goods_id = r:readInt16Unsigned() -- { 物品ID }
        tempData.goods_count = r:readInt16Unsigned() -- { 物品数量 }
        self.goods_data[i]=tempData
    end
end
-- end25155
-- (25520手动) -- [25520]返回招财貔貅 -- 招财貔貅 
ACK_WEAGOD_RMB_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WEAGOD_RMB_REPLY
    self:init()
end)

function ACK_WEAGOD_RMB_REPLY.decode(self, r)
    self.time = r:readInt32Unsigned() -- { 时间 }
    self.flag = r:readInt8Unsigned() -- { 是否领取 }
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.msg={}
    for i=1,self.count do
        self.msg[i]={}
        self.msg[i].id = r:readInt16Unsigned() -- { 已经领取id }
    end
end
-- end25520
-- (26005手动) -- [26005]队伍列表 -- NPC 
ACK_NPC_LIST = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_NPC_LIST
    self:init()
end)

function ACK_NPC_LIST.decode(self, r)
    self.count = r:readInt16Unsigned() -- {队伍数量}
    self.uid = r:readInt32Unsigned() -- {队长Uid}
    self.name = r:readString() -- {队长名}
end
-- end26005
-- (28000手动) -- [28000]返回伙伴信息数据 -- 布阵 
ACK_ARRAY_LIST_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ARRAY_LIST_DATA
    self:init()
end)

function ACK_ARRAY_LIST_DATA.decode(self, r)
    self.sum = r:readInt8Unsigned() -- {可上阵人数}
    self.count = r:readInt16Unsigned() -- {数量}
    self.role_info = r:readXXXGroup() -- {布阵伙伴信息块(28050)}
end
-- end28000
-- (29020手动) -- [29020]祈福界面 -- 门派祈福 
ACK_CLIFFORD_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLIFFORD_REPLY
    self:init()
end)

function ACK_CLIFFORD_REPLY.decode(self, r)
    self.num   = r:readInt8Unsigned() -- { 剩余祈福次数 }
    self.value = r:readInt16Unsigned() -- { 总的祈福值 }
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.data  = {} -- { 信息块29030 }
    for i=1,self.count do
        self.data[i] = ACK_CLIFFORD_XXX()
        self.data[i] : decode(r)
    end
    self.counts  = r:readInt8Unsigned() -- { 数量 }
    self.xz_data = {} -- { 信息块29035 }
    for i=1,self.counts do
        self.xz_data[i] = ACK_CLIFFORD_XXXX()
        self.xz_data[i] : decode(r)
    end

end
-- end29020
-- (30510手动) -- [30510]活跃度信息反回 -- 攻略 
ACK_GONGLUE_HY_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GONGLUE_HY_DATA
    self:init()
end)

function ACK_GONGLUE_HY_DATA.decode(self, r)
    self.hy_value = r:readInt16Unsigned() -- { 今日活的活跃值 }
    self.box_count = r:readInt16Unsigned() -- { 已经领取的宝箱数量 }
    local boxcount   = 1
    self.boxs      = {}
    while boxcount <= self.box_count do
        print("第 "..boxcount.." 个箱子:")
        self.boxs[boxcount] = r:readInt8Unsigned()
        boxcount = boxcount + 1
    end
    self.hy_count = r:readInt16Unsigned() -- { 已经开启的活跃度数量 }
    local hycount = 1
    self.hy       = {}
    while hycount <= self.hy_count do
        print("第 "..hycount.." 个活跃ID:")
        local hys = {}
        hys["hy_id"] = r:readInt8Unsigned()
        hys["hy_num"] = r:readInt8Unsigned()
        self.hy[hycount] = hys
        hycount=hycount+1
    end
end
-- end30510
-- (30530手动) -- [30530]当天日历数据 -- 攻略 
ACK_GONGLUE_DAY_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GONGLUE_DAY_DATA
    self:init()
end)

function ACK_GONGLUE_DAY_DATA.decode(self, r)
    self.day = r:readInt8Unsigned() -- { 今天星期 }
    self.activity_count = r:readInt16Unsigned() -- { 活动开启数量 }
    self.activitys={}
    local count = 1
    while count <= self.activity_count do
        print("第 "..count.." 个活动ID:")
        self.activitys[count] = r:readInt16Unsigned()
        count = count+1
    end
end
-- end30530
-- (30550手动) -- [30550]变强数据反回 -- 攻略 
ACK_GONGLUE_STRONG_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GONGLUE_STRONG_DATA
    self:init()
end)

function ACK_GONGLUE_STRONG_DATA.decode(self, r)-- self.power = r:readInt32Unsigned()
    
    self.type = r:readInt8Unsigned() -- { 类型 }
    print("self.type",self.type)
    self.strong_count = r:readInt16Unsigned() -- { 可前往的数量 }
    self.strongs = {}
    local count = 1
    while count <= self.strong_count do
        print("第 "..count.." 功能ID:")
        self.strongs[count] = r:readInt16Unsigned()  -- { 可前往的ID }
        count = count + 1
    end
end
-- end30550
-- (31120手动) -- [31120]伙伴列表 -- 客栈 
ACK_LINGYAO_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_REPLY
    self:init()
end)

function ACK_LINGYAO_REPLY.decode(self, r)
    self.type  = r:readInt8Unsigned()  -- {数量}
    self.count  = r:readInt16Unsigned()  -- {数量}
    --self.msg_xxx = r:readXXXGroup() -- {信息块（31130）}
    self.msg_xxx = {}
    for i=1,self.count do
        self.msg_xxx[i] = ACK_LINGYAO_MSG_XXX()
        self.msg_xxx[i] : decode( r )
    end
end

-- end31120
-- (31130手动) -- [31130]灵妖信息块 -- 灵妖系统 
ACK_LINGYAO_MSG_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_MSG_XXX
    self:init()
end)

function ACK_LINGYAO_MSG_XXX.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 灵妖id }
    self.lv = r:readInt16Unsigned() -- { 等级 }
    self.class = r:readInt8Unsigned() -- { 等阶 }
    self.powerful = r:readInt16Unsigned() -- { 战斗力 }
    self.country = r:readInt8Unsigned() -- { 阵容 }
    self.attr_msg = ACK_GOODS_XXX2()
    self.attr_msg : decode( r )
    self.count = r:readInt8Unsigned() -- { 符文数量 }
    self.fuwendata={}
    for i=1,self.count do
        self.fuwendata[i]={}
        self.fuwendata[i].goods_id=r:readInt16Unsigned()
        self.fuwendata[i].flag=r:readInt8Unsigned()
    end
end
-- end31130
-- (31545手动) -- [31545]查看总属性返回 -- 灵妖系统 
ACK_LINGYAO_ATTR_ALL_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ATTR_ALL_REPLY
    self:init()
end)

function ACK_LINGYAO_ATTR_ALL_REPLY.decode(self, r)
    -- self.attr_xxx = r:readXXXGroup() -- { 属性块(2002) }
    self.attr_xxx  = ACK_GOODS_XXX2()--reader:readXXXGroup() -- {属性加成 信息块 2002}
    self.attr_xxx  : decode(r)
end
-- end31545
-- (31563手动) -- [31563]副本是否开启 -- 灵妖系统 
ACK_LINGYAO_COPY_OPEN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_COPY_OPEN
    self:init()
end)

function ACK_LINGYAO_COPY_OPEN.decode(self, r)
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.copydata={}
    for i=1,self.count do
        self.copydata[i]={}
        self.copydata[i].copy_id = r:readInt16Unsigned() -- { 副本ID }
        self.copydata[i].flag = r:readInt8Unsigned() -- { 1已开启0未开启 }
        self.copydata[i].times = r:readInt8Unsigned() -- { 剩余次数  }
        self.copydata[i].times_all = r:readInt8Unsigned() -- { 全部次数 }
    end
end
-- end31563
-- (32020手动) -- [32020]财神面板请求返回 -- 摇钱树 
ACK_WEAGOD_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WEAGOD_REPLY
    self:init()
end)

function ACK_WEAGOD_REPLY.decode(self, r)
    self.free_time = r:readInt8Unsigned() -- { 剩余免费招财 }
    self.times = r:readInt16Unsigned() -- { 总剩余次数 }
    self.max_times = r:readInt16Unsigned() -- { 总次数 }
    self.gold = r:readInt32Unsigned() -- { 单倍金钱数 }
    self.count = r:readInt8Unsigned() -- { 信息块数量 }
    --self.msg = r:readXXXGroup() -- { 信息32025 }
    self.data={}
    for icount=1,self.count do
        self.data[icount] = {}
        self.data[icount].adds = r:readInt8Unsigned() -- { 赔率 }
        self.data[icount].gold = r:readInt32Unsigned() -- { 获得金钱 }
    end
end
-- end32020
-- (33025手动) -- [33025]返加社团日志数据3 -- 门派 
ACK_CLAN_CLAN_LOGS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_CLAN_LOGS
    self:init()
end)

function ACK_CLAN_CLAN_LOGS.decode(self, r)
    self.count = r:readInt16Unsigned() -- {社团日志数量}
    -- print( "a#########:",self.count)
    --self.logs_data = r:readXXXGroup() -- {社团日志数据块【33026】}
    local icount = 1
    self.logs_data = {}
    while icount <= self.count do
        self.logs_data[icount] = {}
        self.logs_data[icount].type   = r:readInt8Unsigned() -- {日志类型| CONST_CLAN_EVENT_XX}
        self.logs_data[icount].time   = r:readInt32Unsigned() -- {时间戳(s)}
        -- print( icount.."@#########:",self.logs_data[icount].type,self.logs_data[icount].time)
        self.logs_data[icount].count1 = r:readInt16Unsigned() -- {string数量}
        -- print( "b#########:",self.logs_data[icount].count1)
        --self.string_msg = r:readXXXGroup() -- {string数据块【33027】}
        local icount1 = 1
        self.logs_data[icount].string_msg = {}
        while icount1 <= self.logs_data[icount].count1 do
            self.logs_data[icount].string_msg[icount1] = {}
            self.logs_data[icount].string_msg[icount1].name       = r:readString() -- {名字}
            self.logs_data[icount].string_msg[icount1].name_color = r:readInt8Unsigned() -- {名字颜色}
            -- print( "STRING#########:",self.logs_data[icount].string_msg[icount1].name,self.logs_data[icount].string_msg[icount1].name_color)
            icount1 = icount1 + 1
        end
        self.logs_data[icount].count2 = r:readInt16Unsigned() -- {int数量}
        --self.int_msg = r:readXXXGroup() -- {int数据块【33028】}
        -- print( "b#########:",self.logs_data[icount].count2)
        local icount2 = 1
        self.logs_data[icount].int_msg = {}
        while icount2 <= self.logs_data[icount].count2 do
            self.logs_data[icount].int_msg[icount2] = {}
            self.logs_data[icount].int_msg[icount2].value  = r:readInt32Unsigned() -- {数值}
            -- print( "d#########:",self.logs_data[icount].int_msg[icount2].value)
            icount2 = icount2 + 1
        end
        icount = icount + 1
    end
end
-- end33025
-- (33026手动) -- [33026]社团日志数据块 -- 门派 
ACK_CLAN_LOGS_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_LOGS_MSG
    self:init()
end)

function ACK_CLAN_LOGS_MSG.decode(self, r)
    self.type = r:readInt8Unsigned() -- {日志类型| CONST_CLAN_EVENT_XX}
    self.time = r:readInt32Unsigned() -- {时间戳(s)}
    self.count1 = r:readInt16Unsigned() -- {string数量}
    self.string_msg = r:readXXXGroup() -- {string数据块【33027】}
    self.count2 = r:readInt16Unsigned() -- {int数量}
    self.int_msg = r:readXXXGroup() -- {int数据块【33028】}
end
-- end33026
-- (33034手动) -- [33034]社团列表返回 -- 门派 
ACK_CLAN_OK_CLANLIST = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_OK_CLANLIST
    self:init()
end)

function ACK_CLAN_OK_CLANLIST.decode(self, r)
    self.page      = r:readInt16Unsigned() -- {当前页数}
    self.all_pages = r:readInt16Unsigned() -- {总计页数}
    self.count     = r:readInt16Unsigned() -- {数量}
    print( "ACK_CLAN_OK_CLANLIST:"..self.page..":"..self.all_pages..":"..self.count)
    --self.clandata_msg = r:readXXXGroup() -- {社团数据信息块【33020】}
    local icount = 1
    self.clandata_msg = {}
    while icount <= self.count do
        self.clandata_msg[icount] = {}
        self.clandata_msg[icount].clan_id          = r:readInt32Unsigned() -- {社团ID}
        -- print( icount.."#########",self.clandata_msg[icount].clan_id)
        self.clandata_msg[icount].clan_name        = r:readString()        -- {社团名字}
        -- print( icount.."#########",self.clandata_msg[icount].clan_name)
        self.clandata_msg[icount].clan_lv          = r:readInt8Unsigned()  -- {社团等级}
        -- print( icount.."#########",self.clandata_msg[icount].clan_lv)
        self.clandata_msg[icount].clan_rank        = r:readInt16Unsigned() -- {社团排名}
        -- print( icount.."#########",self.clandata_msg[icount].clan_rank)
        self.clandata_msg[icount].clan_members     = r:readInt16Unsigned() -- {社团当前成员数}
        self.clandata_msg[icount].clan_all_members = r:readInt16Unsigned() -- {社团成员上限数}
        -- print( icount.."#########",self.clandata_msg[icount].clan_members.."/"..self.clandata_msg[icount].clan_all_members)
        icount = icount + 1
    end
end
-- end33034
-- (33036手动) -- [33036]已申请社团列表 -- 门派 
ACK_CLAN_APPLIED_CLANLIST = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_APPLIED_CLANLIST
    self:init()
end)

function ACK_CLAN_APPLIED_CLANLIST.decode(self, r)
    self.is    = r:readInt8Unsigned()  -- {是否可创建门派}
    self.count = r:readInt16Unsigned() -- {数量}
    print( "已申请社团列表：", self.count)
    --self.clan_list = r:readXXXGroup() -- {int数据块【33028】}
    local icount = 1
    self.clan_list = {}
    while icount <= self.count do
        self.clan_list[icount] = {}
        self.clan_list[icount].value       = r:readInt32Unsigned() -- {数值}
        print( icount..">>>>>"..self.clan_list[icount].value)
        icount = icount + 1
    end
end
-- end33036
-- (33080手动) -- [33080]返回入帮申请列表 -- 门派 
ACK_CLAN_OK_JOIN_LIST = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_OK_JOIN_LIST
    self:init()
end)

function ACK_CLAN_OK_JOIN_LIST.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    print( "入帮申请列表:", self.count)
    --self.user_data = r:readXXXGroup() -- {入帮申请玩家信息块【33085】}
    local icount = 1
    self.user_data = {}
    while icount <= self.count do
        self.user_data[icount] = {}
        self.user_data[icount].uid        = r:readInt32Unsigned() -- {玩家Uid}
        self.user_data[icount].name       = r:readString() -- {玩家名字}
        self.user_data[icount].name_color = r:readInt8Unsigned() -- {玩家名字颜色}
        self.user_data[icount].lv         = r:readInt16Unsigned() -- {等级}
        self.user_data[icount].pro        = r:readInt8Unsigned() -- {职业}
        self.user_data[icount].power      = r:readInt32Unsigned() -- 战斗力     
        print("DDDDDD:",self.user_data[icount].name,self.user_data[icount].lv)
        icount = icount + 1
    end
end
-- end33080
-- (33140手动) -- [33140]返回门派成员列表 -- 门派 
ACK_CLAN_OK_MEMBER_LIST = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_OK_MEMBER_LIST
    self:init()
end)

function ACK_CLAN_OK_MEMBER_LIST.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    -- print("社团成员列表:", self.count)
    --self.member_msg = r:readXXXGroup() -- {成员数据信息块【33145】}
    local icount = 1
    self.member_msg = {}
    while icount <= self.count do
        self.member_msg[icount] = {}
        self.member_msg[icount].uid         = r:readInt32Unsigned() -- {玩家Uid}
        self.member_msg[icount].name        = r:readString()        -- {玩家名字}
        self.member_msg[icount].name_color  = r:readInt8Unsigned()  -- {玩家名字颜色}
        self.member_msg[icount].lv          = r:readInt16Unsigned() -- {玩家等级}
        self.member_msg[icount].pro         = r:readInt8Unsigned()  -- {职业}
        self.member_msg[icount].post        = r:readInt8Unsigned()  -- {职位}
        self.member_msg[icount].power       = r:readInt32Unsigned() -- {战斗力}
        self.member_msg[icount].today_gx    = r:readInt32Unsigned() -- {今日贡献}
        self.member_msg[icount].all_gx      = r:readInt32Unsigned() -- {总贡献}
        self.member_msg[icount].time        = r:readInt32Unsigned() -- {离线时间(s) 1表示在线}   
        -- print("玩家名字:", self.member_msg[icount].name)
        icount = icount + 1
    end
end
-- end33140
-- (33210手动) -- [33210]返回社团技能面板数据 -- 门派 
ACK_CLAN_OK_CLAN_SKILL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_OK_CLAN_SKILL
    self:init()
end)

function ACK_CLAN_OK_CLAN_SKILL.decode(self, r)
    self.stamina = r:readInt32Unsigned() -- {体能点数}
    self.count = r:readInt16Unsigned() -- {数量}
    self.attr_msg = {} -- {属性数据块【33215】}
    for i=1,self.count do
        self.attr_msg[i] = ACK_CLAN_CLAN_ATTR_DATA()
        self.attr_msg[i] : decode( r )
    end
end
-- end33210
-- (33310手动) -- [33310]返回活动面板数据 -- 门派 
ACK_CLAN_OK_ACTIVE_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_OK_ACTIVE_DATA
    self:init()
end)

function ACK_CLAN_OK_ACTIVE_DATA.decode(self, r)
    self.clan_lv = r:readInt8Unsigned()
    self.count   = r:readInt16Unsigned() -- {数量}
    print("社团活动数量 :"..self.count)
    --self.active_data = r:readXXXGroup() -- {社团活动数据块【33315】} ACK_CLAN_ACTIVE_MSG
    local icount = 1
    self.active_data = {}
    while icount <= self.count do
        print("第 "..icount.." 个社团活动数据:")
        local tempData = ACK_CLAN_ACTIVE_MSG()
        tempData :decode( r)
        self.active_data[icount] = tempData
        icount = icount + 1
    end
end
-- end33310
-- (33410手动) -- [33410]门派角标 -- 门派 
ACK_CLAN_CORNER = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_CORNER
    self:init()
end)

function ACK_CLAN_CORNER.decode(self, r)
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.data  = {} -- { 信息块 }
    for i=1,self.count do
        self.data[i] = ACK_CLAN_XXX()
        self.data[i] : decode( r )
    end
end
-- end33410
-- (34040手动) -- [34040]寻宝结果_旧 -- 活动-龙宫寻宝 
ACK_DRAGON_OK_START_DRAGON = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DRAGON_OK_START_DRAGON
    self:init()
end)

function ACK_DRAGON_OK_START_DRAGON.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    self.rewards = r:readXXXGroup() -- {奖励信息块 【2001】}
end
-- end34040
-- (34042手动) -- [34042]寻宝结果 -- 活动-龙宫寻宝 
ACK_DRAGON_OK_START_NEW = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DRAGON_OK_START_NEW
    self:init()
end)

function ACK_DRAGON_OK_START_NEW.decode(self, r)
    self.sid = r:readInt16Unsigned() -- {服务器Id}
    self.uid = r:readInt32Unsigned() -- {玩家Uid}
    self.name = r:readString() -- {玩家名字}
    self.name_color = r:readInt8Unsigned() -- {名字颜色}
    self.count = r:readInt16Unsigned() -- {数量}
    self.rewards = r:readXXXGroup() -- {奖励信息块 【34050】}
end
-- end34042
-- (34501手动) -- [34501]店铺物品信息块 -- 商城 
ACK_SHOP_XXX1 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SHOP_XXX1
    self:init()
end)

function ACK_SHOP_XXX1.decode(self, r)
    self.idx = r:readInt16Unsigned() -- {物品数据索引}
    self.state = r:readInt16() --{是否限购}
    local tempData = ACK_GOODS_XXX1()
    tempData : decode(r)
    self.msg_xxx = tempData -- {信息块2001} -- {信息块2001}
    self.type = r:readInt8Unsigned() -- {价格类型}
    self.v_price = r:readInt32Unsigned() -- {物品原价}
    self.s_price = r:readInt32Unsigned() -- {物品现价}
    self.total_remaider_num = r:readInt16() -- {剩余总数量}
    self.discount = r:readInt8Unsigned() -- {0:不可用打折卡 1:可以}
end
-- end34501
-- (34502手动) -- [34502]店铺物品信息块 -- 商城 
ACK_SHOP_INFO_NEW = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SHOP_INFO_NEW
    self:init()
end)

function ACK_SHOP_INFO_NEW.decode(self, r)
    self.idx = r:readInt16Unsigned() -- { 物品数据索引 }
    self.state = r:readInt8Unsigned() -- { 1:可以购买|0:不可购买 }
    local tempData = ACK_GOODS_XXX1()
    tempData : decode(r)
    self.msg = tempData -- { 信息块2001 }
    self.type = r:readInt8Unsigned() -- { 价格类型 }
    self.s_price = r:readInt32Unsigned() -- { 物品现价 }
    self.v_price = r:readInt32Unsigned() -- { 物品vip价格 }
    self.etra_type = r:readInt8Unsigned() -- { 拓展类型|0:此字段无效 }
    self.etra_value = r:readInt16Unsigned() -- { 拓展类型值 }
end
-- end34502
-- (34511手动) -- [34511] 请求店铺面板成功 -- 商城 
ACK_SHOP_REQUEST_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SHOP_REQUEST_OK
    self:init()
end)

function ACK_SHOP_REQUEST_OK.decode(self, r)
    self.type = r:readInt16Unsigned() -- {店铺类型}
    self.type_bb = r:readInt16Unsigned() -- {子店铺类型}
    self.good_id = r:readInt16Unsigned() -- {打折卡id 0:无}
    self.count = r:readInt16Unsigned() -- {物品数量}
    -- self.msg = r:readXXXGroup() -- {信息块34501}
    self.msg = {}
    for i=1,self.count do
        self.msg[i] = {}
        local tempData = ACK_SHOP_XXX1()
        tempData : decode( r)
        self.msg[i] = tempData
    end
    self.end_time = r:readInt32Unsigned() -- {结束时间}
end
-- end34511
-- (34512手动) -- [34512]请求店铺面板成功 -- 商城 
ACK_SHOP_REQUEST_OK_NEW = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SHOP_REQUEST_OK_NEW
    self:init()
end)

function ACK_SHOP_REQUEST_OK_NEW.decode(self, r)
    self.type    = r:readInt16Unsigned() -- {店铺类型}
    self.type_bb = r:readInt16Unsigned() -- {子店铺类型}
    self.count   = r:readInt16Unsigned() -- {物品数量}
    --self.msg = r:readXXXGroup() -- {信息块34502}
    
    self.goods_msg_no = {}   -- {物品信息块(34501 P_GOODS_XXX1)}
    for i=1,self.count do
        self.goods_msg_no[i] = {}
        local tempData = ACK_SHOP_INFO_NEW()
        tempData : decode( r)
        self.goods_msg_no[i] = tempData
    end
    -- local icount = 1
    -- while icount <= self.count do
    --     self.goods_msg_no[icount] = {}
    --     self.goods_msg_no[icount].idx                = r: readInt16Unsigned()
    --     self.goods_msg_no[icount].state              = r: readInt8Unsigned()
        
    --     --self.goods_msg_no[icount].msg                = r: readInt8Unsigned()-- {物品信息块(2001 P_GOODS_XXX1)}
    --     ----------------------------------------------------------------------------------------------------------
    --     -- print("ACK_SHOP_REQUEST_OK第 "..icount.." 个物品:",self.goods_msg_no[icount].idx)
        
    --     self.goods_msg_no[icount].is_data     = r: readBoolean()
    --     self.goods_msg_no[icount].index       = r: readInt16Unsigned()
    --     self.goods_msg_no[icount].goods_id    = r: readInt16Unsigned()
    --     self.goods_msg_no[icount].goods_num   = r: readInt16Unsigned()
    --     self.goods_msg_no[icount].expiry      = r: readInt32Unsigned()
    --     self.goods_msg_no[icount].time        = r: readInt32Unsigned()
    --     self.goods_msg_no[icount].price       = r: readInt32Unsigned()
    --     self.goods_msg_no[icount].goods_type  = r: readInt8Unsigned()
    --     --print(" 物品ID:"..self.goods_id.."索引Index:"..self.index.."数量:"..self.goods_num.."价格:"..self.price)
    --     self.goods_type = self.goods_msg_no[icount].goods_type
    --     if self.goods_type == _G.Const.CONST_GOODS_EQUIP or self.goods_type == _G.Const.CONST_GOODS_WEAPON or self.goods_type == _G.Const.CONST_GOODS_MAGIC then   --装备大类 1 2 5
    --         self.goods_msg_no[icount].powerful    = r: readInt32Unsigned()
    --         self.goods_msg_no[icount].pearl_score = r: readInt32Unsigned()
    --         self.goods_msg_no[icount].suit_id     = r: readInt16Unsigned()
    --         self.goods_msg_no[icount].wskill_id   = r: readInt16Unsigned()
    --         self.goods_msg_no[icount].attr_count  = r: readInt16Unsigned()
    --         self.attr_count = self.goods_msg_no[icount].attr_count
    --         --attr_data  = msg.readXXXGroup(); -- {基础信息块(2006 P_GOODS_ATTR_BASE)}
    --         local icount1 = 1
    --         self.goods_msg_no[icount].attr_data = {}
    --         while icount1 <= self.attr_count do
    --             -- print("第 "..icount.." 个属性:")
    --             local tempData = ACK_GOODS_ATTR_BASE()
    --             tempData :decode( r)
    --             self.goods_msg_no[icount].attr_data[icount1] = tempData
    --             icount1 = icount1 + 1
    --         end
    --         self.goods_msg_no[icount].strengthen  = r: readInt8Unsigned()
    --         self.goods_msg_no[icount].plus_count  = r: readInt16Unsigned()
    --         self.plus_count = self.goods_msg_no[icount].plus_count
    --         --plusmsgno = msg.readXXXGroup();  -- {装备打造附加块(2004 P_GOODS_XXX4)} ACK_GOODS_XXX4
    --         local icount2 = 1
    --         self.goods_msg_no[icount].plus_msg_no = {}
    --         while icount2 <= self.plus_count do
    --             -- print("第 "..icount2.." 个附加属性:")
    --             local tempData = ACK_GOODS_XXX4()
    --             tempData :decode( r)
    --             self.goods_msg_no[icount].plus_msg_no[icount2] = tempData
    --             icount2 = icount2 + 1
    --         end
    --         self.goods_msg_no[icount].slots_count = r: readInt16Unsigned()
    --         self.slots_count = self.goods_msg_no[icount].slots_count
    --         --slotgroup = msg.readXXXGroup();  -- {插槽信息块(2003 P_GOODS_XXX3)} ACK_GOODS_XXX3
    --         local icount3 = 1
    --         self.goods_msg_no[icount].slot_group = {}
    --         while icount3 <= self.slots_count do
    --             -- print("第 "..icount3.." 个插槽属性:")
    --             local tempData = ACK_GOODS_XXX3()
    --             tempData :decode( r)
    --             self.goods_msg_no[icount].slot_group[icount3] = tempData
    --             icount3 = icount3 + 1
    --         end
    --         self.goods_msg_no[icount].fumo  = r: readInt16Unsigned()
    --         self.goods_msg_no[icount].fumoz = r: readInt16Unsigned()
    --         -- print("###############################################", self.fumo, self.fumoz)
    --     else 
    --         self.goods_msg_no[icount].attr1      = r: readInt32Unsigned()
    --         self.goods_msg_no[icount].attr2      = r: readInt32Unsigned()
    --         self.goods_msg_no[icount].attr3      = r: readInt32Unsigned()
    --         self.goods_msg_no[icount].attr4      = r: readInt32Unsigned()
    --     end 
    --     ----------------------------------------------------------------------------------------------------------
    --     self.goods_msg_no[icount].type               = r: readInt8Unsigned()
    --     self.goods_msg_no[icount].s_price            = r: readInt32Unsigned()
    --     self.goods_msg_no[icount].v_price            = r: readInt32Unsigned()
    --     self.goods_msg_no[icount].etra_type          = r: readInt8Unsigned()
    --     self.goods_msg_no[icount].etra_value         = r: readInt16Unsigned()
        
    --     icount = icount + 1
    -- end
    
    self.end_time = r:readInt32Unsigned() 
end
-- end34512
-- (35020手动) -- [35020]返回自己身份信息 -- 苦工 
ACK_MOIL_MOIL_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MOIL_MOIL_DATA
    self:init()
end)

function ACK_MOIL_MOIL_DATA.decode(self, r)
    self.type_id       = r:readInt8Unsigned() -- {身份Id}
    self.l_uid         = r:readInt32Unsigned() -- {主人uid}
    self.l_name        = r:readString() -- {主人名字}
    self.l_lv          = r:readInt16Unsigned() -- {主人等级}
    self.l_power       = r:readInt32Unsigned() -- {主人战斗力}
    self.captrue_count = r:readInt8Unsigned() -- {抓捕次数}
    self.active_count  = r:readInt8Unsigned() -- {互动次数}
    self.calls_count   = r:readInt8Unsigned() -- {求救次数}
    self.protest_count = r:readInt8Unsigned() -- {反抗次数}
    self.rescue_count  = r:readInt8Unsigned() -- {解救次数}
    self.expn          = r:readInt32Unsigned() -- {当前经验}
    self.exp           = r:readInt32Unsigned() -- {经验上限}
    self.count         = r:readInt16Unsigned() -- {数量}
    -- self.data = r:readXXXGroup() -- {信息块 35021}for
    -- print("ACK_MOIL_MOIL_DATA11====",self.type_id,self.l_uid,self.l_name,self.l_lv,self.captrue_count,self.active_count,self.calls_count,self.protest_count,self.rescue_count,self.expn,self.exp,self.count)
    self.data          = {}
    if self.count > 0 then
        for i=1,self.count do
            local tempObject = ACK_MOIL_MOIL_RS()
            tempObject : decode( r )
            self.data[i] = tempObject
        end
    end
    
end
-- end35020
-- (35021手动) -- [35021]苦工操作信息 -- 苦工 
ACK_MOIL_MOIL_RS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MOIL_MOIL_RS
    self:init()
end)

function ACK_MOIL_MOIL_RS.decode(self, r)
    self.time       = r:readInt32Unsigned() -- {时间}
    self.uid        = r:readInt32Unsigned() -- {主动方Uid}
    self.name       = r:readString()        -- {主动方姓名}
    self.buid       = r:readInt32Unsigned() -- {被动方Uid}
    self.bname      = r:readString() -- {被动方姓名}
    self.type       = r:readInt8Unsigned() -- {类型：抓捕,互动...}
    if  self.type == _G.Const.CONST_MOIL_FUNCTION_CATCH or 
    	self.type == _G.Const.CONST_MOIL_FUNCTION_REVOLT then
        self.res    = r:readInt8Unsigned() -- {1:成功0:失败}
    end
    if  self.type == _G.Const.CONST_MOIL_FUNCTION_INTER then
        self.active_id  = r:readInt8Unsigned() -- {互动Id}
        self.active_exp = r:readInt32Unsigned() -- {互动经验}
    end

    if  self.type == _G.Const.CONST_MOIL_FUNCTION_SNATCH then
    	self.res2       = r:readInt8Unsigned() -- {1:成功0:失败}
    	self.mname = r:readString()			--奴仆姓名
    end

    if  self.type == _G.Const.CONST_MOIL_FUNCTION_SHIFAN then
    	self.exp       = r:readInt32Unsigned() 
    end
end
-- end35021
-- (35025手动) -- [35025]玩家信息列表(抓捕,求救) -- 苦工 
ACK_MOIL_PLAYER_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MOIL_PLAYER_DATA
    self:init()
end)

function ACK_MOIL_PLAYER_DATA.decode(self, r)
    self.type  = r:readInt8Unsigned() -- {1:抓捕6:求救(CONST_MOIL_FUNCTION*) (选择)}
    self.count = r:readInt16Unsigned() -- {数量}
    -- self.data = r:readXXXGroup() -- {信息块35026}
    self.data = {}
    if self.count > 0 then
        for i=1,self.count do
            local tempObject = ACK_MOIL_MOIL_XXXX1()
            tempObject : decode( r )
            self.data[i] = tempObject
        end
    end
end
-- end35025
-- (35061手动) -- [35061]互动界面 -- 苦工 
ACK_MOIL_PRESS_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MOIL_PRESS_DATA
    self:init()
end)

function ACK_MOIL_PRESS_DATA.decode(self, r)
    -- self.type      = r:readInt8Unsigned() -- {3:互动4:压榨}
    self.count     = r:readInt16Unsigned() -- {数量}
    self.moil_data = {}
    -- self.moil_data = r:readXXXGroup() -- {苦工信息}
    if self.count > 0 then
        for i=1,self.count do
            local tempObject = ACK_MOIL_MOIL_XXXX2()
            tempObject : decode( r )
            self.moil_data[i] = tempObject
            
            self.moil_data[i].time= r:readInt32Unsigned() -- {剩下保护秒数}
        end
    end
end
-- end35061
-- (35065手动) -- [35065]压榨苦工界面 -- 苦工 
ACK_MOIL_PRESS_YDATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MOIL_PRESS_YDATA
    self:init()
end)

function ACK_MOIL_PRESS_YDATA.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    -- self.moil_data = r:readXXXGroup() -- {苦工信息块35062}
    -- self.data = r:readXXXGroup() -- {信息块35064}
    self.moil_data = {}
    if self.count > 0 then
        for i=1,self.count do
            local tempObject = ACK_MOIL_MOIL_XXXX2()
            tempObject : decode( r )
            self.moil_data[i] = tempObject
            
            self.moil_data[i].expn    = r:readInt32Unsigned() -- {可提取经验}
            self.moil_data[i].time    = r:readInt32Unsigned() -- {剩余干活时间}
            self.moil_data[i].is_over = r:readInt8Unsigned() -- {是否榨干 0:否 1:是}
        end
    end
end
-- end35065
-- (35080手动) -- [35080] 压榨结果 -- 苦工 
ACK_MOIL_PRESS_RS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MOIL_PRESS_RS
    self:init()
end)

function ACK_MOIL_PRESS_RS.decode(self, r)
    self.type = r:readInt8Unsigned() -- {1:提取2:压榨3:抽取 (选择)}
    self.uid = r:readInt32Unsigned() -- {苦工uid}
    self.exp = r:readInt16Unsigned() -- {可获经验}
    self.time = r:readInt32Unsigned() -- {剩下的时间}
end
-- end35080
-- (35170手动) -- [35170]苦工列表 -- 苦工 
ACK_MOIL_TMOILS_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MOIL_TMOILS_BACK
    self:init()
end)

function ACK_MOIL_TMOILS_BACK.decode(self, r)
    self.count = r:readInt8Unsigned() -- {数量}
    -- self.data = r:readXXXGroup() -- {信息块 35062}
    self.data = {}
    if self.count > 0 then
        for i=1,self.count do
            local tempObject = ACK_MOIL_MOIL_XXXX2()
            tempObject : decode( r )
            self.data[i] = tempObject
        end
        
    end
end
-- end35170
-- (36011手动) -- [36011]当前章节信息(新) -- 三界杀 
ACK_CIRCLE_2_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CIRCLE_2_DATA
    self:init()
end)

function ACK_CIRCLE_2_DATA.decode(self, r)
    self.chap = r:readInt8Unsigned() -- {当前章节}
    self.next_chap = r:readInt8Unsigned() -- {1:可去，0:不可}
    self.count = r:readInt16Unsigned() -- {数量}
    self.chap_data = r:readXXXGroup() -- {36022}
end
-- end36011
-- (36020手动) -- [36020]当前章节信息(废除) -- 三界杀 
ACK_CIRCLE_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CIRCLE_DATA
    self:init()
end)

function ACK_CIRCLE_DATA.decode(self, r)
    self.chap = r:readInt8Unsigned() -- {当前章节}
    self.next_chap = r:readInt8Unsigned() -- {1:可去，0:不可}
    self.count = r:readInt16Unsigned() -- {数量}
    self.chap_data = r:readXXXGroup() -- {36021}
end
-- end36020
-- (37005手动) -- [37005]世界BOSS面板返回 -- 世界BOSS 
ACK_WORLD_BOSS_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WORLD_BOSS_REPLY
    self:init()
end)

function ACK_WORLD_BOSS_REPLY.decode(self, r)
    self.count = r:readInt16Unsigned() -- { 数量 }
    --self.msg_xxx = r:readXXXGroup() -- { 世界BOSS状态 }
    self.data = {}
    for icount=1, self.count do
        self.data[icount] = {}
        self.data[icount].type = r:readInt8Unsigned() -- { 唯一id }
        self.data[icount].state = r:readInt8Unsigned() -- { Boss状态 }
    end
end
-- end37005
-- (37060手动) -- [37060]DPS排行 -- 世界BOSS 
ACK_WORLD_BOSS_DPS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WORLD_BOSS_DPS
    self:init()
end)

function ACK_WORLD_BOSS_DPS.decode(self, r)
    self.uid = r:readInt32Unsigned() -- {玩家uid}
    self.self_harm  = r:readInt32Unsigned() -- {自己伤害}
    self.self_rank = r:readInt16Unsigned() -- {自己伤害率}
    self.boss_hp=r:readInt32Unsigned()
    self.count = r:readInt16Unsigned() -- {数量}
    --self.data = r:readXXXGroup() -- {信息块(37070)}
    
    self.data = {}
    for i=1,self.count do
        local temp = ACK_WORLD_BOSS_DPS_XX()
        temp : decode( r )
        self.data[temp.rank] = temp
    end
end
-- end37060
-- (37170手动) -- [37170]结算榜显示 -- 世界BOSS 
ACK_WORLD_BOSS_SETTLEMENT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WORLD_BOSS_SETTLEMENT
    self:init()
end)

function ACK_WORLD_BOSS_SETTLEMENT.decode(self, r)
    self.type  = r:readInt8Unsigned() -- {1:世界boss 2:门派boss}
    self.count = r:readInt8Unsigned() -- {数量}
    self.data = {}
    for i=1,self.count do
        local temp = ACK_WORLD_BOSS_SETTLE_DATA()
        temp : decode( r )
        self.data[i] = temp
    end
end
-- end37170
-- (37240手动) -- [37240]玩家死亡 -- 世界BOSS 
ACK_WORLD_BOSS_PLAYER_DIE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WORLD_BOSS_PLAYER_DIE
    self:init()
end)

function ACK_WORLD_BOSS_PLAYER_DIE.decode(self, r)
    self.time = r:readInt8Unsigned() -- { 剩余复活时间 }
    self.rmb  = r:readInt8Unsigned() -- { 复活需要元宝 }
    self.type = r:readInt8Unsigned() -- { 1被玩家杀死2被boss杀死 }
    if self.type == 1 then
        self.clan_name = r:readString() -- {门派名字}
        self.player_name = r:readString() -- {玩家名字}
    else
        self.boss_id = r:readInt16Unsigned() -- {BossId}
    end
end
-- end37240
-- (38010手动) -- [38010]目标数据返回 -- 目标任务 
ACK_TARGET_LIST_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TARGET_LIST_BACK
    self:init()
end)

function ACK_TARGET_LIST_BACK.decode(self, r)
    self.count = r:readInt16Unsigned() -- {目标数量}
    self.data = r:readXXXGroup() -- {(38015)}
end
-- end38010
-- (39018手动) -- [39018]全部章节信息 -- 英雄副本 
ACK_HERO_ALL_CHAP_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HERO_ALL_CHAP_DATA
    self:init()
end)

function ACK_HERO_ALL_CHAP_DATA.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    self.data = {}--r:readXXXGroup() -- {全部章节信息块（39020）}
    local iCount = 1
    while iCount <= self.count do
        local tempData = ACK_HERO_CHAP_DATA_NEW()
        tempData :decode(r)
        self.data[iCount] = tempData
        iCount = iCount + 1
    end
end
-- end39018
-- (39020手动) -- [39020]当前章节信息 -- 英雄副本 
ACK_HERO_CHAP_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HERO_CHAP_DATA
    self:init()
end)

function ACK_HERO_CHAP_DATA.decode(self, r)
    self.chap      = r:readInt16Unsigned() -- {当前章节}
    self.next_chap = r:readInt8Unsigned() -- {下一章节 1：可去 | 0：不可去}
    self.times     = r:readInt16Unsigned() --{可进入次数}
    self.buy_times = r:readInt16Unsigned()  --｛以购买次数｝
    self.free_times= r:readInt16Unsigned() -- {可购买次数}
    self.count     = r:readInt16Unsigned() -- {战役数量}    
    print("英雄副本\n当前章节:"..self.chap.."\n下一章节是否可去:"..self.next_chap.."\n可进入次数:"..self.times.."\n战役数量:"..self.count)
    print("buy_times/free_times :",self.buy_times,"/",self.free_times)
    --self.battle_data = r:readXXXGroup() -- {战役数据信息块(39015)}
    self.battle_data = {}   -- {战役数据信息块(39015)}
    local icount = 1
    while icount <= self.count do
        self.battle_data[icount] = {}
        self.battle_data[icount].copy_id       = r: readInt16Unsigned()
        self.battle_data[icount].is_pass       = r: readInt8Unsigned()
        print("FFFFFFFFFFFF副本ID：",self.battle_data[icount].copy_id,"\nFFFFFFFFFFFFIs_pass:",self.battle_data[icount].is_pass)
        icount = icount+1
    end
end
-- end39020
-- (39070手动) -- [39070]当前章节信息(new) -- 英雄副本 
ACK_HERO_CHAP_DATA_NEW = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HERO_CHAP_DATA_NEW
    self:init()
end)

function ACK_HERO_CHAP_DATA_NEW.decode(self, r)
    self.chap = r:readInt16Unsigned() -- {当前章节}
    self.next_chap = r:readInt8Unsigned() -- {下一章节 1：可去 | 0：不可去}
    self.times = r:readInt16Unsigned() -- {可以进入次数}
    self.buy_times = r:readInt16Unsigned() -- {已购买次数}
    self.free_times = r:readInt16Unsigned() -- {剩余购买次数}
    self.count = r:readInt16Unsigned() -- {战役数量}
    --self.data = r:readXXXGroup() -- {战役数据信息块(39080)}
    print("普通副本\n当前章节:"..self.chap.."\n下一章节是否可去:"..self.next_chap.."\n战役数量:"..self.count)
    self.data = {}   -- {战役数据信息块(39080)}
    local icount = 1
    while icount <= self.count do
        print("第 "..icount.." 个副本数据:")
        local tempData = ACK_HERO_MSG_BATTLE_NEW()
        tempData :decode( r)
        self.data[icount] = tempData
        icount = icount + 1
    end
end
-- end39070
-- (39530手动) -- [39530]返回全部珍宝副本 -- 珍宝副本 
ACK_COPY_GEM_CHAP_DATA_ALL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_GEM_CHAP_DATA_ALL
    self:init()
end)

function ACK_COPY_GEM_CHAP_DATA_ALL.decode(self, r)
    self.count = r:readInt16Unsigned() -- { 数量 }
    print("ACK_COPY_GEM_CHAP_DATA_ALL==================>>>>>>>>",self.count)
    self.data = {}
    local iCount = 1
    while iCount <= self.count do
        local tempData = ACK_COPY_GEM_CHAP_DATA()
        tempData :decode(r)
        self.data[iCount] = tempData
        iCount = iCount + 1
    end
end
-- end39530
-- (39535手动) -- [39535]当前章节信息 -- 珍宝副本 
ACK_COPY_GEM_CHAP_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_GEM_CHAP_DATA
    self:init()
end)

function ACK_COPY_GEM_CHAP_DATA.decode(self, r)
    self.chap = r:readInt16Unsigned() -- {当前章节}
    self.next_chap = r:readInt8Unsigned() -- {下一章节 1：可去 | 0：不可去}
    self.count = r:readInt16Unsigned() -- {战役数量}
    --self.data = r:readXXXGroup() -- {战役数据信息块(39080)}
    print("普通副本\n当前章节:"..self.chap.."\n下一章节是否可去:"..self.next_chap.."\n战役数量:"..self.count)
    self.data = {}   -- {战役数据信息块(39080)}
    local icount = 1
    while icount <= self.count do
        print("第 "..icount.." 个副本数据:")
        local tempData = ACK_COPY_GEM_MSG_COPYS()
        tempData :decode( r)
        self.data[icount] = tempData
        icount = icount + 1
    end
end
-- end39535
-- (40022手动) -- [40022]登陆签到过的物品 -- 签到抽奖 
ACK_SIGN_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SIGN_REPLY
    self:init()
end)

function ACK_SIGN_REPLY.decode(self, r)
    self.times = r:readInt8Unsigned() -- {次数}
    self.count = r:readInt16Unsigned() -- {数量}
    self.sign_yes = {} -- {信息块(40032)}
    for i=1,self.count do
        self.sign_yes[i] = r:readInt16Unsigned()
    end
end
-- end40022
-- (40035手动) -- [40035]12天抽奖记录 -- 签到抽奖 
ACK_SIGN_HISTORY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SIGN_HISTORY
    self:init()
end)

function ACK_SIGN_HISTORY.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    self.history = {} --r:readXXXGroup() -- {历史信息块}
    for i=1,self.count do
        self.history[i] = ACK_SIGN_HISTORY_REP() --r:readInt16Unsigned()
    end
end
-- end40035
-- (40510手动) -- [40510]分组信息 -- 门派战 
ACK_GANG_WARFARE_GROUP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GANG_WARFARE_GROUP
    self:init()
end)

function ACK_GANG_WARFARE_GROUP.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量(组)}
    self.data = {}--r:readXXXGroup() -- {信息块(40515)}
    for i=1,self.count do
        self.data[i]=ACK_GANG_WARFARE_GROUP_DATA()
        self.data[i]:decode(r)
    end
end
-- end40510
-- (40515手动) -- [40515]层信息块 -- 门派战 
ACK_GANG_WARFARE_GROUP_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GANG_WARFARE_GROUP_DATA
    self:init()
end)

function ACK_GANG_WARFARE_GROUP_DATA.decode(self, r)
    self.ceng = r:readInt8Unsigned() -- {第几层}
    self.group_count = r:readInt16Unsigned() -- {第几组}
    self.data = {}--r:readXXXGroup() -- {信息块(40517)}
    for i=1,self.group_count do
        self.data[i]=ACK_GANG_WARFARE_GROUP_XXXX()
        self.data[i]:decode(r)
    end
end
-- end40515
-- (40517手动) -- [40517]组信息块 -- 门派战 
ACK_GANG_WARFARE_GROUP_XXXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GANG_WARFARE_GROUP_XXXX
    self:init()
end)

function ACK_GANG_WARFARE_GROUP_XXXX.decode(self, r)
    self.group = r:readInt8Unsigned() -- {第几组}
    self.clan_count = r:readInt16Unsigned() -- {门派数量}
    self.data = {}--r:readXXXGroup() -- {信息块(40516)}
    for i=1,self.clan_count do
        self.data[i]=ACK_GANG_WARFARE_CLAN_XXXX()
        self.data[i]:decode(r)
    end
end
-- end40517
-- (40535手动) -- [40535]帮排战况信息 -- 门派战 
ACK_GANG_WARFARE_LIVE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GANG_WARFARE_LIVE
    self:init()
end)

function ACK_GANG_WARFARE_LIVE.decode(self, r)
    self.count = r:readInt16Unsigned() -- {门派数量}
    self.data = {} -- {门派战况块(40540)}
    for i=1,self.count do
        local data = ACK_GANG_WARFARE_LIVE_DATA()
        data : decode(r)
        self.data[i] = data
    end
end
-- end40535
-- (40550手动) -- [40550]初赛战果 -- 门派战 
ACK_GANG_WARFARE_C_FINISH = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GANG_WARFARE_C_FINISH
    self:init()
end)

function ACK_GANG_WARFARE_C_FINISH.decode(self, r)
    self.type  = r:readInt8Unsigned()  -- {类型}
    self.res   = r:readInt8Unsigned()  -- {输赢}
    self.count = r:readInt16Unsigned() -- {参赛门派数量}
    self.data = {}--r:readXXXGroup()   -- {参赛门派战况块(40550)}
    for i=1,self.count do
        self.data[i]=ACK_GANG_WARFARE_PART_DATA()
        self.data[i]:decode(r)
    end
end
-- end40550
-- (41520手动) -- [41520]成就系统返回 -- 成就系统 
ACK_ACHIEVE_RELPY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ACHIEVE_RELPY
    self:init()
end)

function ACK_ACHIEVE_RELPY.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    self.data = {} -- {成就信息块}
    for i=1,self.count do
        local temp = ACK_ACHIEVE_MSG()
        temp:decode( r )
        self.data[i]=temp
    end
end
-- end41520

-- (41560手动) -- [41560]成就角标返回 -- 成就系统 
ACK_ACHIEVE_ANS_POINT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ACHIEVE_ANS_POINT
    self:init()
end)

function ACK_ACHIEVE_ANS_POINT.decode(self, r)
    self.count = r:readInt16Unsigned() -- { 数量 }
    self.msg_xxx = {}--r:readXXXGroup() -- { 信息块(41570) }
    for i=1,self.count do
        local temp = ACK_ACHIEVE_MSG_POINTS()
        temp:decode( r )
        self.msg_xxx[i]=temp
    end
end
-- end41560
-- (42522手动) -- [42522]卡片套装和奖励数据返回 -- 收集卡片 
ACK_COLLECT_CARD_DATA_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COLLECT_CARD_DATA_BACK
    self:init()
end)

function ACK_COLLECT_CARD_DATA_BACK.decode(self, r)
    self.count = r:readInt16Unsigned() -- {套装数据数量}
    self.msg_xxx = r:readXXXGroup() -- {数据信息块42524}
end
-- end42522
-- (42524手动) -- [42524]套装数据信息块 -- 收集卡片 
ACK_COLLECT_CARD_XXX1 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COLLECT_CARD_XXX1
    self:init()
end)

function ACK_COLLECT_CARD_XXX1.decode(self, r)
    self.id = r:readInt16Unsigned() -- {卡片套装ID}
    self.count1 = r:readInt16Unsigned() -- {卡片数量}
    self.msg_xxx1 = r:readXXXGroup() -- {需要卡片数据块42526}
    self.count2 = r:readInt16Unsigned() -- {奖励虚拟货币数量}
    self.msg_xxx2 = r:readXXXGroup() -- {虚拟货币信息块42528}
    self.count3 = r:readInt16Unsigned() -- {奖励物品数量}
    self.msg_xxx3 = r:readXXXGroup() -- {奖励物品信息块42526}
end
-- end42524
-- (43541手动) -- [43541]排行榜 -- 跨服战 
ACK_STRIDE_RANK_HAIG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_STRIDE_RANK_HAIG
    self:init()
end)

function ACK_STRIDE_RANK_HAIG.decode(self, r)
    self.type = r:readInt8Unsigned() -- {排行榜类型}
    
    self.zdata = {}    -- {信息块43543}
    self.zdata = ACK_STRIDE_SELF_HAIG() 
    self.zdata : decode(r)
    
    self.count = r:readInt16Unsigned() -- {数量}
    self.data = {} -- {信息块43542}
    for i=1,self.count do
        self.data[i] = ACK_STRIDE_HAIG_DATA()
        self.data[i] : decode(r)
    end  
    print("ACK_STRIDE_RANK_HAIG----")
    for k,v in pairs(self) do
        print(k,v)
    end
end
-- end43541
-- (43549手动) -- [43549]越级挑战的所有组别 -- 跨服战 
ACK_STRIDE_YJ_GROUP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_STRIDE_YJ_GROUP
    self:init()
end)

function ACK_STRIDE_YJ_GROUP.decode(self, r)
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.group = {} -- { 组别 }
    for i=1,self.count do
        self.group[i] = r:readInt8Unsigned()
    end
end
-- end43549
-- (43550手动) -- [43550]挑战列表 -- 跨服战 
ACK_STRIDE_RANK_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_STRIDE_RANK_DATA
    self:init()
end)

function ACK_STRIDE_RANK_DATA.decode(self, r)
    self.type = r:readInt8Unsigned() -- {1:挑战信息2:三界榜3:巅峰榜4:巅峰之战挑战信息5:18位挑战榜信息6:越级挑战信息}
    self.count = r:readInt16Unsigned() -- {数量}
    self.data = {} -- {信息块(43551)}
    for i=1,self.count do
        self.data[i] = ACK_STRIDE_RANK_2_DATA()
        self.data[i] : decode(r)
    end   
    
    self.zdata = {}    -- {信息块43543}
    self.zdata = ACK_STRIDE_SELF_HAIG() 
    self.zdata : decode(r)
    
    self.num = r:readInt16Unsigned()
    self.times = r:readInt32Unsigned()
    self.group = r:readInt8Unsigned()
    self.buy_num = r:readInt16Unsigned()
end
-- end43550
-- (43552手动) -- [43552]可领的宝箱 -- 跨服战 
ACK_STRIDE_CAN_AWARD = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_STRIDE_CAN_AWARD
    self:init()
end)

function ACK_STRIDE_CAN_AWARD.decode(self, r)
    self.count = r:readInt8Unsigned() -- {数量}
    self.cenci = {}
    for i=1,self.count do
        self.cenci[i] = r:readInt8Unsigned()
        -- self.cenci : decode(r)
        print("ACK_STRIDE_CAN_AWARD ----> ",self.cenci[i])
    end
    --self.cenci = r:readInt8Unsigned() -- {层次编号}
end
-- end43552
-- (43555手动) -- [43555]战报日志 -- 跨服战 
ACK_STRIDE_WAR_LOGS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_STRIDE_WAR_LOGS
    self:init()
end)

function ACK_STRIDE_WAR_LOGS.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    self.data = {} -- {信息块(43556)}
    for i = 1,self.count do
        self.data[i] = ACK_STRIDE_WAR_2_LOGS()
        self.data[i] : decode(r)
    end
    
end
-- end43555
-- (43633手动) -- [43633]挑战结果--玉清元始 -- 跨服战 
ACK_STRIDE_STRIDE_WAR_RS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_STRIDE_STRIDE_WAR_RS
    self:init()
end)

function ACK_STRIDE_STRIDE_WAR_RS.decode(self, r)
    self.rs = r:readInt8Unsigned() -- { 1:胜利0:失败 }
    self.jf = r:readInt32Unsigned() -- { 获得积分 }
    self.count = r:readInt16Unsigned() -- { 物品数量 }
    self.rewardMsg = {}
    for i=1,self.count do
        self.rewardMsg[i] = {}
        self.rewardMsg[i].goods_id = r:readInt16Unsigned() -- {物品id}
        self.rewardMsg[i].count2 = r:readInt16Unsigned() -- {物品数量}
    end
end
-- end43633
-- (43760手动) -- [43760]可领的宝箱 -- 跨服战 
ACK_STRIDE_CAN_AWARD_SEC = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_STRIDE_CAN_AWARD_SEC
    self:init()
end)

function ACK_STRIDE_CAN_AWARD_SEC.decode(self, r)
    self.count = r:readInt8Unsigned() -- {数量}
    self.rewardMsg = {}
    for i=1,self.count do
        self.rewardMsg[i] = {}
        self.rewardMsg[i].cenci = r:readInt8Unsigned() -- {层次编号}
        self.rewardMsg[i].state = r:readInt8Unsigned() -- {0:未领 1:可领 2:已领}
    end
    -- self.cenci = r:readInt8Unsigned() -- {层次编号}
    -- self.state = r:readInt8Unsigned() -- {0:未领 1:可领 2:已领}
end
-- end43760
-- (44520手动) -- [44520]答题面板返回 -- 御前科举 
ACK_KEJU_ASK_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_KEJU_ASK_REPLY
    self:init()
end)

function ACK_KEJU_ASK_REPLY.decode(self, r)
    self.type   = r:readInt8Unsigned()  -- { 1:类型 }
    if self.type == 1 then
        self.name   = r:readString()        -- { 1:玩家名字}
        self.times  = r:readInt8Unsigned()  -- { 1:剩余答题次数 }
        self.rank   = r:readInt16Unsigned() -- { 1:最佳排名 }
        self.score  = r:readInt16Unsigned() -- { 1:得分 }
        self.time   = r:readInt16Unsigned() -- { 1:耗时 }
        self.reward = r:readInt32Unsigned() -- { 1:所获奖励 }
        self.count  = r:readInt16Unsigned() -- { 1:数量 }
        self.msg_xxx = {}
        for i=1,self.count do               -- { 1:排行榜信息块44525 }        
            local msg = ACK_KEJU_XXX_RANK()
            msg : decode( r )
            self.msg_xxx[i] = msg
        end
    elseif self.type == 2 then 
        self.name2  = r:readString()        -- { 2:玩家名字}
        self.times2 = r:readInt8Unsigned()  -- { 2:剩余答题次数 }
        self.rank2  = r:readInt16Unsigned() -- { 2:最佳排名 }
        self.score2 = r:readInt16Unsigned() -- { 2:得分 }
        self.time2  = r:readInt16Unsigned() -- { 2:耗时 }
        self.reward2= r:readInt32Unsigned() -- { 2:所获奖励 }              
        local msg = ACK_KEJU_XXX_ANSWER()
        msg : decode(r)
        self.msg_xxx2 = msg                 -- { 2:答题信息块 }
    end
end
-- end44520
-- (44530手动) -- [44530]答题信息块（44540） -- 御前科举 
ACK_KEJU_XXX_ANSWER = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_KEJU_XXX_ANSWER
    self:init()
end)

function ACK_KEJU_XXX_ANSWER.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 题目ID }
    self.num = r:readInt8Unsigned() -- { 第几题 }
    self.right = r:readInt8Unsigned() -- { 答对题目数量 }
    self.time = r:readInt32Unsigned() -- { 剩余答题时间 }
    self.times1 = r:readInt8Unsigned() -- { 剩余算卦次数 }
    self.times2 = r:readInt8Unsigned() -- { 剩余贿赂次数 }
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.msg_options = {}
    for i=1,self.count do               -- { 1:排行榜信息块44540 }        
        local msg = ACK_KEJU_MSG_OPTIONS()
        msg : decode( r )
        self.msg_options[i] = msg
    end
end
-- end44530
-- (44620手动) -- [44620]任务返回 -- 悬赏任务 
ACK_REWARD_TASK_REPLAY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_TASK_REPLAY
    self:init()
end)

function ACK_REWARD_TASK_REPLAY.decode(self, r)
    self.num = r:readInt8Unsigned() -- {已完成次数}
    self.sg_num = r:readInt16Unsigned() -- {剩余刷新符}
    self.count = r:readInt8Unsigned() -- {任务数量}
    self.data={}
    for i=1,self.count do
        self.data[i]=ACK_REWARD_TASK_DATA()
        self.data[i]:decode(r)
    end
end
-- end44620
-- (44820手动) -- [44820]可以挑战的玩家列表 -- 跨服竞技场 
ACK_CROSS_DEKARON = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CROSS_DEKARON
    self:init()
end)

function ACK_CROSS_DEKARON.decode(self, r)
    self.lack_num = r:readInt8Unsigned() -- {幸运数字}
    self.time = r:readInt32Unsigned() -- {倒计时 秒}
    self.renown = r:readInt32Unsigned() -- {妖魂}
    self.count = r:readInt16Unsigned() -- {玩家个数}
    self.challage_player_data = r:readXXXGroup() -- {信息块 23821}
end
-- end44820
-- (44890手动) -- [44890]返回排行榜信息 -- 跨服竞技场 
ACK_CROSS_RANKING_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CROSS_RANKING_DATA
    self:init()
end)

function ACK_CROSS_RANKING_DATA.decode(self, r)
    self.rank = r:readInt16Unsigned() -- {自己的排名}
    self.count = r:readInt16Unsigned() -- {数量}
    self.msg_rank_xxx = r:readXXXGroup() -- {44891}
end
-- end44890
-- (44900手动) -- [44900]返回战报信息 -- 跨服竞技场 
ACK_CROSS_MAX_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CROSS_MAX_DATA
    self:init()
end)

function ACK_CROSS_MAX_DATA.decode(self, r)
    self.count = r:readInt16Unsigned() -- {竞技场挑战结果信息}
    self.data = r:readXXXGroup() -- {信息块（23850）}
end
-- end44900
-- (45650手动) -- [45650]连胜榜数据 -- 活动-阵营战 
ACK_CAMPWAR_WINNING_STREAK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CAMPWAR_WINNING_STREAK
    self:init()
end)

function ACK_CAMPWAR_WINNING_STREAK.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    self.ply_data = r:readXXXGroup() -- {连胜玩家信息块【45655】}
end
-- end45650
-- (45690手动) -- [45690]请求振奋成功 -- 活动-阵营战 
ACK_CAMPWAR_OK_BESTIR = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CAMPWAR_OK_BESTIR
    self:init()
end)

function ACK_CAMPWAR_OK_BESTIR.decode(self, r)
    self.num = r:readInt16Unsigned() -- {已振奋次数}
    self.gold = r:readInt8Unsigned() -- {下次振奋需花费金元数}
    self.count = r:readInt16Unsigned() -- {数量}
    self.attr_data = r:readXXXGroup() -- {属性加成信息块【45695】}
end
-- end45690
-- (45755手动) -- [45755]战报数据 -- 活动-阵营战 
ACK_CAMPWAR_WAR_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CAMPWAR_WAR_DATA
    self:init()
end)

function ACK_CAMPWAR_WAR_DATA.decode(self, r)
    self.type = r:readInt8Unsigned() -- {战报类型：CONST_CAMPWAR_TYPE_*}
    self.y_camp = r:readInt8Unsigned() -- {胜方阵营}
    self.y_sid = r:readInt16Unsigned() -- {胜方服务器id}
    self.y_uid = r:readInt32Unsigned() -- {胜方玩家uid}
    self.y_name = r:readString() -- {胜方名字}
    self.y_name_color = r:readInt8Unsigned() -- {胜方名字颜色}
    self.y_wars = r:readInt16Unsigned() -- {胜方连胜次数}
    self.n_camp = r:readInt8Unsigned() -- {败方阵营}
    self.n_sid = r:readInt16Unsigned() -- {战败服务器id}
    self.n_uid = r:readInt32Unsigned() -- {战败玩家uid}
    self.n_name = r:readInt8Unsigned() -- {战败名字}
    self.n_name_color = r:readInt8Unsigned() -- {战败名字颜色}
    self.n_wars = r:readInt16Unsigned() -- {战败连胜次数}
    self.show_id = r:readInt16Unsigned() -- {战报id：0无战报}
    self.count = r:readInt16Unsigned() -- {数量}
    self.rewards_msg = r:readXXXGroup() -- {奖励数据块【45677】}
end
-- end45755
-- (45810手动) -- [45810]战报数据返回 -- 活动-阵营战 
ACK_CAMPWAR_OK_WARDATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CAMPWAR_OK_WARDATA
    self:init()
end)

function ACK_CAMPWAR_OK_WARDATA.decode(self, r)
    self.wtype = r:readInt8Unsigned() -- {战报类型：CONST_CAMPWAR_WARDATA_TYPE_*}
    self.count = r:readInt16Unsigned() -- {数量}
    self.wardata = r:readXXXGroup() -- {战报信息块【45755】}
end
-- end45810
-- (46012手动) -- [46012]转盘返回 -- 每日转盘 
ACK_WHEEL_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WHEEL_REPLY
    self:init()
end)

function ACK_WHEEL_REPLY.decode(self, r)
    self.freetimes = r:readInt16Unsigned() -- {免费次数}
    self.count = r:readInt16Unsigned() -- {数量}
    self.msg = {} -- {历史信息块}
    for i = 1,self.count do
        self.msg[i] = ACK_WHEEL_LOTTERY_MSG()
        self.msg[i] : decode(r)
    end
    print("ACK_WHEEL_REPLY.decode----self.count",self.count)
    for k,v in ipairs(self.msg) do
        print(k,v.name,v.id)
    end
end
-- end46012
-- (46218手动) -- [46218]全部章节信息 -- 魔王副本 
ACK_FIEND_CHAP_DATA_ALL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FIEND_CHAP_DATA_ALL
    self:init()
end)

function ACK_FIEND_CHAP_DATA_ALL.decode(self, r)
    self.buy_times = r:readInt16Unsigned() -- {已经购买次数}
    self.count = r:readInt16Unsigned() -- {数量}
    self.data = {} --r:readXXXGroup() -- {全部章节信息块}
    local iCount = 1
    while iCount <= self.count do
        local tempData = ACK_FIEND_CHAP_DATA_NEW()
        tempData :decode(r)
        self.data[iCount] = tempData
        iCount = iCount + 1
    end
end
-- end46218
-- (46220手动) -- [46220]当前章节信息 -- 魔王副本 
ACK_FIEND_CHAP_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FIEND_CHAP_DATA
    self:init()
end)

function ACK_FIEND_CHAP_DATA.decode(self, r)
    self.chap = r:readInt16Unsigned() -- {当前章节}
    self.next_chap = r:readInt8Unsigned() -- {下一章节 1：可去 | 0：不可去}
    self.times = r:readInt16Unsigned() -- {可刷新次数}
    self.count = r:readInt16Unsigned() -- {战役数量}
    
    print("魔王副本\n当前章节:"..self.chap.."\n下一章节是否可去:"..self.next_chap.."\n可刷新次数:"..self.times.."\n战役数量:"..self.count)
    --self.data = r:readInt16Unsigned() -- {战役数据信息块(46230)}
    self.data = {}   -- {战役数据信息块(39015)}
    local icount = 1
    while icount <= self.count do
        self.data[icount] = {}
        self.data[icount].copy_id       = r: readInt16Unsigned()
        self.data[icount].times         = r: readInt16Unsigned() --可以进入次数
        self.data[icount].is_pass       = r: readInt8Unsigned()
        print("FFFFFFFFFFFFF副本ID：",self.data[icount].copy_id,"\nFFFFFFFFF可以进入次数",self.data[icount].times,"\nFFFFFFFFFFFFIs_pass:",self.data[icount].is_pass)
        icount = icount+1
    end
end
-- end46220
-- (46270手动) -- [46270]当前章节信息(new) -- 魔王副本 
ACK_FIEND_CHAP_DATA_NEW = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FIEND_CHAP_DATA_NEW
    self:init()
end)

function ACK_FIEND_CHAP_DATA_NEW.decode(self, r)
    self.chap = r:readInt16Unsigned() -- {当前章节}
    self.next_chap = r:readInt8Unsigned() -- {下一章节 1：可去 | 0：不可去}
    self.times = r:readInt16Unsigned() -- {可刷新次数}
    self.count = r:readInt16Unsigned() -- {战役数量}
    --self.data = r:readXXXGroup() -- {战役信息块(46280)}
    print("普通副本\n当前章节:"..self.chap.."\n下一章节是否可去:"..self.next_chap.."\n战役数量:"..self.count)
    self.data = {}   -- {战役信息块(46280)}
    local icount = 1
    while icount <= self.count do
        print("第 "..icount.." 个副本数据:")
        local tempData = ACK_FIEND_MSG_BATTLE_NEW()
        tempData :decode( r)
        self.data[icount] = tempData
        icount = icount + 1
    end
end
-- end46270
-- (47210手动) -- [47210]处理藏宝阁面板请求 -- 珍宝阁 
ACK_TREASURE_REQUEST_INFO = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TREASURE_REQUEST_INFO
    self:init()
end)

function ACK_TREASURE_REQUEST_INFO.decode(self, r)
	local tempData = ACK_GOODS_XXX2()
    tempData :decode( r)
    self.attr = {}
    self.attr[_G.Const.CONST_ATTR_HP] = tempData.hp
    self.attr[_G.Const.CONST_ATTR_STRONG_ATT] = tempData.att
    self.attr[_G.Const.CONST_ATTR_STRONG_DEF] = tempData.def
    self.attr[_G.Const.CONST_ATTR_DEFEND_DOWN] = tempData.wreck
    self.attr[_G.Const.CONST_ATTR_HIT] = tempData.hit
    self.attr[_G.Const.CONST_ATTR_DODGE] = tempData.dod
    self.attr[_G.Const.CONST_ATTR_CRIT] = tempData.crit
    self.attr[_G.Const.CONST_ATTR_RES_CRIT] = tempData.crit_res


    self.level_id = r:readInt32Unsigned() -- {藏宝阁层次id}
    self.count = r:readInt16Unsigned() -- {循环变量}
    self.goods_msg_no = {}   -- {物品信息块(47215 P_GOODS_XXX1)}
    local icount = 1
    while icount <= self.count do
        self.goods_msg_no[icount] = {}
        self.goods_msg_no[icount].goods_id    = r: readInt32Unsigned()
        self.goods_msg_no[icount].state       = r: readInt8Unsigned()
        icount = icount + 1 
    end
end
-- end47210
-- (48201手动) -- [48201]仓库数据 -- 霸气系统 
ACK_SYS_DOUQI_STORAGE_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYS_DOUQI_STORAGE_DATA
    self:init()
end)

function ACK_SYS_DOUQI_STORAGE_DATA.decode(self, r)
    self.type  = r:readInt8Unsigned()  -- {仓库类型  0领悟仓库| 1装备仓库}
    self.count = r:readInt16Unsigned() -- {霸气个数}
    local temptype = "(领悟仓库)"
    if self.type == 1 then
        temptype = "(装备仓库)"
    end
    print( "仓库类型: "..self.type..temptype.."霸气个数:"..self.count)
    --self.dq_msg = r:readXXXGroup() -- {霸气信息块【48203】}
    local icount = 1
    self.dq_msg = {}
    while icount <= self.count do
        print("第 "..icount.." 个霸气:")
        local tempData = ACK_SYS_DOUQI_DOUQI_DATA()
        tempData :decode( r)
        self.dq_msg[icount] = tempData
        icount = icount + 1
    end
end
-- end48201
-- (48223手动) -- [48223]一键领悟数据返回 -- 霸气系统 
ACK_SYS_DOUQI_MORE_GRASP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYS_DOUQI_MORE_GRASP
    self:init()
end)

function ACK_SYS_DOUQI_MORE_GRASP.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    --self.msg_more = r:readXXXGroup() -- {48225}
    local icount = 1
    self.msg_more = {}
    while icount <= self.count do
        print( self.count.." 第 "..icount.." 个霸气信息:")
        local tempData = ACK_SYS_DOUQI_MSG_MORE()
        tempData :decode( r)
        self.msg_more[icount] = tempData
        icount = icount + 1
    end
end
-- end48223
-- (48225手动) -- [48225]一键领悟数据 -- 霸气系统 
ACK_SYS_DOUQI_MSG_MORE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYS_DOUQI_MSG_MORE
    self:init()
end)

function ACK_SYS_DOUQI_MSG_MORE.decode(self, r)
    self.type_grasp = r:readInt16Unsigned() -- {新领悟方式}
    --self.msg_dq     = r:readXXXGroup() -- {48203}
    print("新的领悟方式: ",self.type_grasp)
    local tempData = ACK_SYS_DOUQI_DOUQI_DATA()
    tempData :decode( r)
    self.msg_dq = tempData  
end
-- end48225
-- (48242手动) -- [48242]装备界面信息返回 最新 -- 霸气系统 
ACK_SYS_DOUQI_ROLE_NEW = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYS_DOUQI_ROLE_NEW
    self:init()
end)

function ACK_SYS_DOUQI_ROLE_NEW.decode(self, r)
    self.lan_count = r:readInt8Unsigned() -- {装备栏个数(主普通)}
    self.god_count = r:readInt8Unsigned() -- {装备栏个数(主神)}
    self.lan_count2 = r:readInt8Unsigned() -- {装备栏个数(伙伴普通)}
    self.god_count2 = r:readInt8Unsigned() -- {装备栏个数(伙伴神)}
    self.count = r:readInt8Unsigned() -- {数量}
    --self.role_msg = r:readXXXGroup() -- {伙伴数据信息块（48245）}
    local icount = 1
    self.role_msg = {}
    while icount <= self.count do
        local tempData = ACK_SYS_DOUQI_ROLE_DATA()
        tempData :decode( r)
        self.role_msg[icount] = tempData
        icount = icount + 1
    end
end
-- end48242
-- (48245手动) -- [48245]伙伴数据信息块 -- 霸气系统 
ACK_SYS_DOUQI_ROLE_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYS_DOUQI_ROLE_DATA
    self:init()
end)

function ACK_SYS_DOUQI_ROLE_DATA.decode(self, r)
    self.role_id = r:readInt16Unsigned() -- {角色Id}
    self.msg_count = r:readInt16Unsigned() -- {信息块长度}
    --self.msg_storage_xxx = r:readXXXGroup() -- {信息块（48248）}
    local icount = 1
    self.msg_storage_xxx = {}
    while icount <= self.msg_count do
        local tempData = ACK_SYS_DOUQI_DOUQI_DATA()
        tempData :decode( r)
        self.msg_storage_xxx[icount] = tempData
        icount = icount + 1
    end
end
-- end48245
-- (48285手动) -- [48285]吞噬结果 -- 霸气系统 
ACK_SYS_DOUQI_EAT_STATE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYS_DOUQI_EAT_STATE
    self:init()
end)

function ACK_SYS_DOUQI_EAT_STATE.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    --self.eat_data = r:readXXXGroup() -- {吞噬结果信息块【48290】}
    print("一键吞噬总数量:"..self.count)
    local icount = 1
    self.eat_data = {}
    while icount <= self.count do
        print("一键吞噬第:"..icount.." 个吞噬者。")
        local tempData = ACK_SYS_DOUQI_EAT_DATA()
        tempData :decode( r)
        self.eat_data[icount] = tempData
        icount = icount + 1
    end
end
-- end48285
-- (48290手动) -- [48290]吞噬结果信息块 -- 霸气系统 
ACK_SYS_DOUQI_EAT_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYS_DOUQI_EAT_DATA
    self:init()
end)

function ACK_SYS_DOUQI_EAT_DATA.decode(self, r)
    self.lan_id = r:readInt8Unsigned() -- {吞噬者位置ID}
    self.count = r:readInt16Unsigned() -- {数量}
    --self.id_data = r:readXXXGroup() -- {被吞者位置ID列表【48295】}
    print("成功吞噬:"..self.count.." 个霸气")
    local icount = 1
    self.id_data = {}
    while icount <= self.count do
        print("第 "..icount.." 个被吞噬。")
        local tempData = ACK_SYS_DOUQI_LAN_MSG()
        tempData :decode( r)
        self.id_data[icount] = tempData
        icount = icount + 1
    end
end
-- end48290
-- (48310手动) -- [48310]拾取成功 -- 霸气系统 
ACK_SYS_DOUQI_OK_GET_DQ = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYS_DOUQI_OK_GET_DQ
    self:init()
end)

function ACK_SYS_DOUQI_OK_GET_DQ.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    --self.lan_msg = r:readXXXGroup() -- {栏位ID列表【48295】}
    print("成功拾取:"..self.count.." 个霸气")
    local icount = 1
    self.lan_msg = {}
    while icount <= self.count do
        print("第 "..icount.." 个被拾取。")
        local tempData = ACK_SYS_DOUQI_LAN_MSG()
        tempData :decode( r)
        self.lan_msg[icount] = tempData        
        icount = icount + 1
    end
end
-- end48310
-- (48390手动) -- [48390]移动霸气成功 -- 霸气系统 
ACK_SYS_DOUQI_OK_USE_DOUQI = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYS_DOUQI_OK_USE_DOUQI
    self:init()
end)

function ACK_SYS_DOUQI_OK_USE_DOUQI.decode(self, r)
    self.role_id     = r:readInt16Unsigned() -- {伙伴ID | 0 自己}
    self.dq_id       = r:readInt32Unsigned() -- {霸气唯一ID}
    self.lanid_start = r:readInt8Unsigned()  -- {起始位置}
    self.lanid_end   = r:readInt8Unsigned()  -- {目标位置}
    self.count       = r:readInt16Unsigned() -- {数量}
    print("移动霸气成功:",self.role_id,self.dq_id,self.lanid_start,self.lanid_end)
    --self.dq_msg      = r:readXXXGroup()      -- {移动后的霸气信息块【48203】}
    print("霸气数量:",self.count)
    local icount = 1
    self.dq_msg = {}
    while icount <= self.count do
        print("第 "..icount.." 个霸气:")
        local tempData = ACK_SYS_DOUQI_DOUQI_DATA()
        tempData :decode( r)
        self.dq_msg[icount] = tempData
        icount = icount + 1
        print("移动完毕了")
    end
end
-- end48390
-- (48396手动) -- [48396]卦阵信息 -- 八卦系统 
ACK_SYS_DOUQI_CLEAR_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYS_DOUQI_CLEAR_BACK
    self:init()
end)

function ACK_SYS_DOUQI_CLEAR_BACK.decode(self, r)
	self.role_id = r:readInt8Unsigned() -- (身份id)
    self.count = r:readInt8Unsigned() -- { 数量(已升级过的) }
    print("role_id:",self.role_id)
    print("count: ",self.count)
    self.data = {}
    local iCount = 1
    while iCount <= self.count do
        self.data[iCount] = {}
        self.data[iCount].lan_id = r:readInt8Unsigned()
        self.data[iCount].lan_lv = r:readInt16Unsigned()
        print("id:",self.data[iCount].lan_id,"  lv:",self.data[iCount].lan_lv)
        iCount = iCount + 1
    end
    --self.lan_id = r:readInt8Unsigned() -- { 栏Id }
    --self.lan_lv = r:readInt16Unsigned() -- { 等级 }
end
-- end48396
-- (50240手动) -- [50240]牌返回 -- 翻翻乐 
ACK_FLSH_PAI_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FLSH_PAI_REPLY
    self:init()
end)

function ACK_FLSH_PAI_REPLY.decode(self, r)
    print("--------------ACK_FLSH_PAI_REPLY.decode---------------")
    self.times = r:readInt16Unsigned() -- {已换牌次数}
    self.count = r:readInt16Unsigned() -- {牌语数量}
    self.data = {} -- {牌语信息块(50250)}
    print("times="..self.times)
    print("count="..self.count)
    local iCount = 1
    while iCount <= self.count do
        self.data[iCount] = {}
        self.data[iCount].pos = r:readInt8Unsigned()
        self.data[iCount].num = r:readInt8Unsigned()
        print(iCount,self.data[iCount].pos,self.data[iCount].num)
        iCount = iCount + 1
    end
    print("-----------------------------")
end
-- end50240
-- (50705手动) -- [50705]面板回复 -- 对牌 
ACK_MATCH_CARD_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MATCH_CARD_REPLY
    self:init()
end)

function ACK_MATCH_CARD_REPLY.decode(self, r)
	self.step = r:readInt8Unsigned() -- { 已发次数 }
    self.times = r:readInt8Unsigned() -- { 剩余翻牌次数 }
    self.free_one = r:readInt8Unsigned() -- { 剩余翻牌次数（一张） }
    self.free_two = r:readInt8Unsigned() -- { 剩余翻牌次数（二张） }
    self.count = r:readInt8Unsigned() -- { msg数量(50710) }
    self.data = {}
    local iCount = 1
    while iCount <= self.count do
    	local temp = ACK_MATCH_CARD_CARD_MSG()
        temp : decode( r )
        self.data[temp.pos] = {}
        self.data[temp.pos].type = temp.type
        self.data[temp.pos].is_open = temp.is_open
        iCount = iCount + 1
    end
end
-- end50705
-- (51215手动) -- [51215]返回解锁章节 -- 道劫 
ACK_HOOK_RETURN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HOOK_RETURN
    self:init()
end)

function ACK_HOOK_RETURN.decode(self, r)
    self.alltimes = r:readInt8Unsigned() -- { 扫荡总次数 }
    self.times = r:readInt8Unsigned() -- { 扫荡可用次数 }
    self.chap_id = r:readInt16Unsigned()
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.chaps = {}--  r:readXXXGroup() -- { 章节信息块 }
    for i = 1, self.count do 
      local tempData =  ACK_HOOK_CHAP_DATA()   --  51220
      tempData : decode(r)
      self.chaps[i] = tempData
    end 

    self.count2 = r:readInt8Unsigned() -- { 数量 }
    self.copys = {} --  r:readXXXGroup() -- { 副本信息块 }
    for i = 1 ,self.count2 do 
      local tempData =  ACK_HOOK_COPY_DATA()   --  51225
      tempData : decode(r)
      self.copys[i] = tempData
    end

end
-- end51215
-- (52125手动) -- [52125]翅膀界面返回 -- 翅膀 
ACK_FEATHER_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FEATHER_REPLY
    self:init()
end)

function ACK_FEATHER_REPLY.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.pro = r:readInt8Unsigned() -- { 玩家职业 }
    self.skin_wuqi = r:readInt16Unsigned() -- { 武器皮肤 }
    self.skin_feather = r:readInt16Unsigned() -- { 翅膀皮肤 }
    self.count = r:readInt16Unsigned() -- { 数量 }
    self.data = {}--r:readXXXGroup() -- { 信息块(52130) }
    for i=1,self.count do
        local tempData = ACK_FEATHER_XXX_DATA() --信息块（52130） 
        tempData       : decode( r)
        self.data[i] = tempData
    end
end
-- end52125
-- (52210手动) -- [52210]强化面板返回 -- 神器 
ACK_MAGIC_EQUIP_STRENG_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_STRENG_BACK
    self:init()
end)

function ACK_MAGIC_EQUIP_STRENG_BACK.decode(self, r)
    self.streng = r:readInt8Unsigned() -- { 强化等级 }
    self.per    = r:readInt16Unsigned()
    self.count1 = r:readInt8Unsigned() -- { 数量1 }
    self.attr1  = {}
    for i=1,self.count1 do
    	local tempData = ACK_MAGIC_EQUIP_MSG_ATTR() --信息块（52350） 
        tempData       : decode( r)
        self.attr1[i] = tempData
    end
    self.count2 = r:readInt8Unsigned() -- { 数量2 }
    self.attr2  = {}
    for i=1,self.count2 do
    	local tempData = ACK_MAGIC_EQUIP_MSG_ATTR() --信息块（52350） 
        tempData       : decode( r)
        self.attr2[i]  = tempData
    end
end
-- end52210
-- (52217手动) -- [52217]请求进阶面板返回 -- 神器 
ACK_MAGIC_EQUIP_ADVANCE_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_ADVANCE_BACK
    self:init()
end)

function ACK_MAGIC_EQUIP_ADVANCE_BACK.decode(self, r)
	self.power  = r:readInt32Unsigned() 
    self.count1 = r:readInt8Unsigned() -- { 数量1 }
    self.attr1  = {}
    for i=1,self.count1 do
    	local tempData = ACK_MAGIC_EQUIP_MSG_ATTR() --信息块（52350） 
        tempData       : decode( r)
        self.attr1[i] = tempData
    end
    self.count2 = r:readInt8Unsigned() -- { 数量2 }
    self.attr2  = {}
    for i=1,self.count2 do
    	local tempData = ACK_MAGIC_EQUIP_MSG_ATTR() --信息块（52350） 
        tempData       : decode( r)
        self.attr2[i]  = tempData
    end

    local tempData = ACK_GOODS_XXX1() --信息块（52350） 
    tempData       : decode( r)
    self.msg_goods = tempData
end
-- end52217
-- (52227手动) -- [52227]洗练面板返回 -- 神器 
ACK_MAGIC_EQUIP_WASH_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_WASH_BACK
    self:init()
end)

function ACK_MAGIC_EQUIP_WASH_BACK.decode(self, r)
    self.count1 = r:readInt8Unsigned() -- { 数量1 }
    self.attr1  = {}
    for i=1,self.count1 do
    	local tempData = ACK_MAGIC_EQUIP_MSG_WASH_ATTR() --信息块（52350） 
        tempData       : decode( r)
        self.attr1[i] = tempData
    end
    self.count2 = r:readInt8Unsigned() -- { 数量2 }
    self.attr2  = {}
    for i=1,self.count2 do
    	local tempData = ACK_MAGIC_EQUIP_MSG_WASH_ATTR2() --信息块（52350） 
        tempData       : decode( r)
        self.attr2[i]  = tempData
    end
end
-- end52227
-- (52310手动) -- [52310]属性返回 -- 神器 
ACK_MAGIC_EQUIP_ATTR_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_ATTR_REPLY
    self:init()
end)

function ACK_MAGIC_EQUIP_ATTR_REPLY.decode(self, r)
    self.money = r:readInt32Unsigned() -- {消耗的铜钱}
    self.odds  = r:readInt16Unsigned() -- {概率}
    
    self.count1 = r:readInt8Unsigned() -- {属性数量}
    self.msg_xxx1 = {} --r:readXXXGroup() -- {信息块52320}
    
    print("-------------------------消耗铜钱->"..self.money.."   概率->"..self.odds.."    属性数量->"..self.count1)
    local iCount = 1
    while self.count1 >= iCount do
        self.msg_xxx1[iCount] = {}
        self.msg_xxx1[iCount].type = r:readInt16Unsigned()
        self.msg_xxx1[iCount].type_value = r:readInt16Unsigned()
        
        print("  类型->"..self.msg_xxx1[iCount].type.."      值->"..self.msg_xxx1[iCount].type_value)
        iCount = iCount + 1
    end
    
    
    self.count2 = r:readInt8Unsigned() -- {材料数量}
    self.msg_xxx2 = {} --r:readXXXGroup() -- {信息块52315}
    
    
    print("----------------------材料数量->"..self.count2)
    iCount = 1
    while self.count2 >= iCount do
        self.msg_xxx2[iCount] = {}
        self.msg_xxx2[iCount].item_id = r:readInt16Unsigned()
        self.msg_xxx2[iCount].count   = r:readInt16Unsigned()
        
        print("   材料ID->"..self.msg_xxx2[iCount].item_id.."    数量->"..self.msg_xxx2[iCount].count)
        
        iCount = iCount + 1
    end
end
-- end52310
-- (52340手动) -- [52340]幻化界面返回 -- 神器 
ACK_MAGIC_EQUIP_REPLY_HUANHUA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_REPLY_HUANHUA
    self:init()
end)

function ACK_MAGIC_EQUIP_REPLY_HUANHUA.decode(self, r)
    self.type = r:readInt8Unsigned() -- {类型 1时装，2翅膀}
    self.magic_id = r:readInt16Unsigned() -- {神器ID}
    self.count = r:readInt16Unsigned() -- {数量}
    -- self.msg_magics = r:readXXXGroup() -- {神器ID信息块}
    self.msg_magics = {}
    if self.count > 0  then
        for i=1,self.count do
            local tempData = ACK_MAGIC_EQUIP_MSG_MAGICS() --信息块（52350） 
            tempData       : decode( r)
            self.msg_magics[i] = tempData
        end
    end
end
-- end52340
-- (52405手动) -- [52405]神器界面返回 -- 神器 
ACK_MAGIC_EQUIP_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_REPLY
    self:init()
end)

function ACK_MAGIC_EQUIP_REPLY.decode(self, r)
    self.idx_use = r:readInt32Unsigned() -- { 当前使用神器idx }
    self.attr  = ACK_GOODS_XXX2()--reader:readXXXGroup() -- {属性加成 信息块 2002}
    self.attr  : decode(r)
    self.count = r:readInt8Unsigned() -- { 已激活神器数量 }
    self.msg = {}
    for i=1,self.count do
        self.msg[i]={}
        self.msg[i].id=r:readInt16Unsigned() -- { 神器Id }
        self.msg[i].idx=r:readInt32Unsigned() -- { 神器Idx }
        self.msg[i].type=r:readInt8Unsigned() -- { 神器类型 }
    end
end
-- end52405
-- (52415手动) -- [52415]单个神兵请求返回 -- 神兵系统 
ACK_MAGIC_EQUIP_REPLY_ONE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_REPLY_ONE
    self:init()
end)

function ACK_MAGIC_EQUIP_REPLY_ONE.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 神兵Id }
    self.idx = r:readInt32Unsigned() -- { 神兵idx }
    self.skill_lv = r:readInt16Unsigned() -- { 技能等级 }
    self.flag = r:readInt8Unsigned() -- { 是否使用1是0不是 }
    self.attr_xxx  = ACK_GOODS_XXX2()--reader:readXXXGroup() -- {属性加成 信息块 2002}
    self.attr_xxx  : decode(r)
end
-- end52415
-- (52425手动) -- [52425]使用神兵返回 -- 神兵系统 
ACK_MAGIC_EQUIP_USE_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_USE_REPLY
    self:init()
end)

function ACK_MAGIC_EQUIP_USE_REPLY.decode(self, r)
    self.idx = r:readInt32Unsigned() -- { 神兵idx }
    self.lv = r:readInt16Unsigned() -- { 技能等级 }
    self.count = r:readInt8Unsigned() -- { 技能数量 }
    self.skill_id = r:readInt16Unsigned() -- { 技能id }
end
-- end52425
-- (53220手动) -- [53220]面板返回 -- 三国基金 
ACK_PRIVILEGE_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_PRIVILEGE_REPLY
    self:init()
end)

function ACK_PRIVILEGE_REPLY.decode(self, r)
    self.type = r:readInt8Unsigned() -- {类型（0为未开通）}
    --未开通 此信息块是购买基金模块
    if self.type == _G.Const.CONST_PRIVILEGE_STATA0 then
        self.seconds = r:readInt32Unsigned() -- {数量}
        self.count2  = r:readInt16Unsigned() -- {数量}
        self.msg2    = {}
        if self.count2 > 0 then
            for i=1,self.count2 do
                
                local tempData = ACK_PRIVILEGE_MSG() --信息块（53225） 
                tempData       : decode( r)
                self.msg2[i]   = tempData   
            end
        end
        --已经开通了 此信息块是领取基金模块
    elseif self.type == _G.Const.CONST_PRIVILEGE_STATA1 then
        self.count1 = r:readInt16Unsigned() -- {数量}
        self.msg1   = {}
        if self.count1 > 0 then
            for i=1,self.count1 do
                
                local tempData = ACK_PRIVILEGE_MSG_GET() --领取信息块（53223） 
                tempData       : decode( r)
                self.msg1[i]   = tempData   
            end
        end
    end
end
-- end53220
-- (53255手动) -- [53255]返回基金信息 -- 三国基金 
ACK_PRIVILEGE_FUND_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_PRIVILEGE_FUND_MSG
    self:init()
end)

function ACK_PRIVILEGE_FUND_MSG.decode(self, r)
    self.seconds = r:readInt32Unsigned() -- { 活动结束的秒数 }
    self.type = r:readInt8Unsigned() -- { 基金类型 }
    self.is = r:readInt8Unsigned() -- { 基金是否开通 0为未开通 }
    self.bool = r:readInt8Unsigned() -- { 0为不可领取，1为可以 }
    self.acc = r:readInt8Unsigned() -- { 累计登录天数 }
end
-- end53255
-- (54820手动) -- [54820]三界争锋界面返回 -- 天下第一 
ACK_WRESTLE_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WRESTLE_REPLY
    self:init()
end)

function ACK_WRESTLE_REPLY.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 类型(1,报名,2,没有报名3,初赛4决赛) }
    -- self.book_xxx = r:readXXXGroup() -- { 报名信息块(54830) }
    -- self.book_no_xxx = r:readXXXGroup() -- { 没有报名信息块(54840) }
    -- self.group_xxx = r:readXXXGroup() -- { 初赛信息块(54850) }
    -- self.final_xxx = r:readXXXGroup() -- { 决赛信息块(54860) }
    if self.type == 1 then
        self.state = r:readInt8Unsigned()
    elseif self.type == 3 then
    	self.group_id = r:readInt8Unsigned()
        self.data = {}
        self.count = r:readInt16Unsigned()
        if self.count > 0 then
            for i=1,self.count do
                self.data[i] = {}
                self.data[i].uid = r:readInt32Unsigned() -- { 玩家ID }
                self.data[i].name = r:readString() -- { 玩家名字 }
                self.data[i].powerful = r:readInt32Unsigned() -- { 玩家战斗力 }
                self.data[i].win = r:readInt8Unsigned() -- { 赢场数 }
                self.data[i].lose = r:readInt8Unsigned() -- { 输场数 }
                self.data[i].score = r:readInt8Unsigned() -- { 分数 }
            end
        end
    elseif self.type == 4 then
        self.data  = {}
        self.turn  = r:readInt8Unsigned()
        self.state = r:readInt8Unsigned()
        self.count = r:readInt16Unsigned()
        if self.count > 0 then
            for i=1,self.count do
            	local index  = r:readInt8Unsigned()
                self.data[index] = {}
                self.data[index].uid = r:readInt32Unsigned() -- { 玩家ID }
                self.data[index].name = r:readString() -- { 玩家名字 }
                self.data[index].lv = r:readInt16Unsigned() -- { 玩家等级 }
                self.data[index].pro = r:readInt8Unsigned() -- { 玩家职业 }
                self.data[index].powerful = r:readInt32Unsigned() -- { 玩家战斗力 }
                self.data[index].is_fail = r:readInt8Unsigned() -- { 玩家是否失败过 }
                self.data[index].fail_turn = r:readInt8Unsigned() -- { 玩家失败轮次 }
            end
        end
    end
end
-- end54820
-- (54850手动) -- [54850]初赛信息块 -- 天下第一 
ACK_WRESTLE_GROUP_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WRESTLE_GROUP_XXX
    self:init()
end)

function ACK_WRESTLE_GROUP_XXX.decode(self, r)
    self.group_id = r:readInt8Unsigned()
    self.data = {}
    self.count = r:readInt16Unsigned()
    if self.count > 0 then
        for i=1,self.count do
            self.data[i] = {}
            self.data[i].uid = r:readInt32Unsigned() -- { 玩家ID }
            self.data[i].name = r:readString() -- { 玩家名字 }
            self.data[i].powerful = r:readInt32Unsigned() -- { 玩家战斗力 }
            self.data[i].win = r:readInt8Unsigned() -- { 赢场数 }
            self.data[i].lose = r:readInt8Unsigned() -- { 输场数 }
            self.data[i].score = r:readInt8Unsigned() -- { 分数 }
        end
    end
end
-- end54850
-- (54860手动) -- [54860]决赛信息块 -- 天下第一 
ACK_WRESTLE_FINAL_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WRESTLE_FINAL_XXX
    self:init()
end)

function ACK_WRESTLE_FINAL_XXX.decode(self, r)
    self.turn = r:readInt8Unsigned() -- { 轮次 }
    self.count = r:readInt16Unsigned() -- { 数量 }
    self.final_xxx2 = r:readXXXGroup() -- { 决赛详情信息块(54865) }
end
-- end54860
-- (54960手动) -- [54960]王者争霸界面返回 -- 天下第一 
ACK_WRESTLE_REPLY_KING = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WRESTLE_REPLY_KING
    self:init()
end)

function ACK_WRESTLE_REPLY_KING.decode(self, r)
    self.pos = r:readInt8Unsigned() -- { 位置(1左边，2右边) }
    self.name = r:readString() -- { 名字 }
    self.pro = r:readInt8Unsigned() -- { 职业 }
    self.powerful = r:readInt32Unsigned() -- { 战斗力 }
    self.lv = r:readInt16Unsigned() -- { 等级 }
    self.count = r:readInt16Unsigned() -- { 数量 }
    self.result = {}
    for i=1,self.count do
        local msg = ACK_WRESTLE_MSG_RES()
        msg : decode( r )
        self.result[i] = msg.result
    end
end
-- end54960
-- (55023手动) -- [55023]太清混元请求返回 -- 太清混元 
ACK_TXDY_SUPER_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TXDY_SUPER_REPLY
    self:init()
end)

function ACK_TXDY_SUPER_REPLY.decode(self, r)
    self.state   = r:readInt8Unsigned() -- { 当前比赛状态(const_txdy_super_state_*) }
    self.msg_xxx = {}
    if self.state == _G.Const.CONST_TXDY_SUPER_STATE_GROUP then
        self.msg_xxx = ACK_TXDY_SUPER_REPLY_GROUP()
        self.msg_xxx : decode(r)
    elseif self.state == _G.Const.CONST_TXDY_SUPER_STATE_FINAL
        or self.state == _G.Const.CONST_TXDY_SUPER_STATE_GROUP_OVER
        or self.state == _G.Const.CONST_TXDY_SUPER_STATE_KING 
        or self.state == _G.Const.CONST_TXDY_SUPER_STATE_OVER then
        self.msg_xxx = ACK_TXDY_SUPER_REPLY_FINAL()
        self.msg_xxx : decode(r)
    else
        print( "在MsgAck中，条件判断语句出错:", self.state )
    end
end
-- end55023
-- (55025手动) -- [55025]小组信息返回 -- 跨服天下第一 
ACK_TXDY_SUPER_REPLY_GROUP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TXDY_SUPER_REPLY_GROUP
    self:init()
end)

function ACK_TXDY_SUPER_REPLY_GROUP.decode(self, r)
    self.group_id = r:readInt8Unsigned()  -- {组别}
    self.turn     = r:readInt8Unsigned() -- {轮次}
    self.count    = r:readInt16Unsigned() -- {数量}
    self.msg_xxx  = {} -- {小组信息块}
    for i=1,self.count do
        local msg = ACK_TXDY_SUPER_MSG_XXX()
        msg : decode( r )
        self.msg_xxx[i] = msg
    end
end
-- end55025
-- (55040手动) -- [55040]决赛界面返回 -- 跨服天下第一 
ACK_TXDY_SUPER_REPLY_FINAL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TXDY_SUPER_REPLY_FINAL
    self:init()
end)

function ACK_TXDY_SUPER_REPLY_FINAL.decode(self, r)
    self.turn  = r:readInt8Unsigned()  -- 轮次
    self.count = r:readInt16Unsigned() -- {}
    self.msg_xxx2 = {} -- {}
    for i=1,self.count do
        local msg = ACK_TXDY_SUPER_MSG_XXX()
        msg : decode(r)
        self.msg_xxx2[i] = msg
    end
end
-- end55040
-- (55050手动) -- [55050]王者争霸界面返回 -- 跨服天下第一 
ACK_TXDY_SUPER_REPLY_KING = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TXDY_SUPER_REPLY_KING
    self:init()
end)

function ACK_TXDY_SUPER_REPLY_KING.decode(self, r)
    self.pos = r:readInt8Unsigned()    -- {位置(1左边，2右边)}
    self.uid = r:readInt32Unsigned()   -- {玩家id}
    self.name = r:readString()         -- {名字}
    self.lv  = r:readInt16Unsigned()   -- {等级}
    self.pro = r:readInt8Unsigned()    -- {职业}
    self.sid = r:readInt16Unsigned()   -- {服务器id}
    self.power = r:readInt32Unsigned() -- {玩家战斗力}
    self.rank = r:readInt8Unsigned()   -- {排名 1为冠军 2为亚军 0未分胜负}
    self.count = r:readInt16Unsigned() -- {数量}
    self.msg_result = {} -- {信息块(55055)}
    for i=1,self.count do
        local msg = ACK_TXDY_SUPER_MSG_RESULT()
        msg : decode(r)
        self.msg_result[i] = msg
    end
end
-- end55050
-- (55070手动) -- [55070]竞猜榜返回 -- 跨服天下第一 
ACK_TXDY_SUPER_REPLY_GUESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TXDY_SUPER_REPLY_GUESS
    self:init()
end)

function ACK_TXDY_SUPER_REPLY_GUESS.decode(self, r)
    self.count = r:readInt16Unsigned() -- { 数量 }
    self.msg_guess_xxx = {} -- { 竞猜数据块 }
    for i=1,self.count do
        local msg = ACK_TXDY_SUPER_GUESS_XXX()
        msg : decode(r)
        self.msg_guess_xxx[i] = msg
    end
end
-- end55070
-- (55320手动) -- [55320]准备界面返回 -- 一骑当千 
ACK_THOUSAND_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_THOUSAND_REPLY
    self:init()
end)

function ACK_THOUSAND_REPLY.decode(self, r)
    self.times = r:readInt8Unsigned() -- {剩余挑战次数}
    self.harm = r:readInt32Unsigned() -- {玩家最高伤害}
    self.time = r:readInt16Unsigned() -- {消耗时间值}
    self.self_rank = r:readInt16Unsigned() -- {当前自己排名}
    self.pro = r:readInt8Unsigned() -- {默认选择职业(没有则为0)}
    self.count = r:readInt16Unsigned() -- {数量}
    self.msg_xxx = {} -- {信息块(55330)}
    for i=1,self.count do
        local msg = ACK_THOUSAND_MSG_XXX()
        msg : decode( r )
        self.msg_xxx[i] = msg
    end
end
-- end55320
-- (55330手动) -- [55330]信息块 -- 一骑当千 
ACK_THOUSAND_MSG_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_THOUSAND_MSG_XXX
    self:init()
end)

function ACK_THOUSAND_MSG_XXX.decode(self, r)
    self.pro = r:readInt8Unsigned() -- {职业}
    self.count = r:readInt16Unsigned() -- {已装备技能数量}
    self.msg_skill = {} -- {技能信息块(55340)}
    for i=1,self.count do
        local msg = ACK_THOUSAND_MSG_SKILL()
        msg : decode( r )
        self.msg_skill[i] = msg
    end
end
-- end55330
-- (55395手动) -- [55395]开始挑战返回 -- 一骑当千 
ACK_THOUSAND_WAR_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_THOUSAND_WAR_REPLY
    self:init()
end)

function ACK_THOUSAND_WAR_REPLY.decode(self, r)
    self.pro = r:readInt8Unsigned() -- {职业}
    self.count = r:readInt16Unsigned() -- {数量}
    self.msg_skill = {} -- {技能信息块(55340)}
    for i=1,self.count do
        local msg = ACK_THOUSAND_MSG_SKILL()
        msg : decode( r )
        self.msg_skill[i] = msg
    end
end
-- end55395
-- (55455手动) -- [55455]排行榜返回 -- 一骑当千 
ACK_THOUSAND_REPLY_RANK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_THOUSAND_REPLY_RANK
    self:init()
end)

function ACK_THOUSAND_REPLY_RANK.decode(self, r)
    self.self_rank = r:readInt16Unsigned() -- {自己排名}
    self.count = r:readInt16Unsigned() -- {数量}
    self.msg_rank = {} -- {排行榜信息块}
    for i=1,self.count do
        local msg = ACK_THOUSAND_MSG_RANK()
        msg : decode( r )
        self.msg_rank[i] = msg
    end
end
-- end55455
-- (55820手动) -- [55820]当前章节信息 -- 拳皇生涯 
ACK_FIGHTERS_CHAP_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FIGHTERS_CHAP_DATA
    self:init()
end)

function ACK_FIGHTERS_CHAP_DATA.decode(self, r)
    self.chap        = r:readInt16Unsigned() -- {当前章节}
    -- self.next_chap   = r:readInt8Unsigned()  -- {下一章节 1：可去 | 0：不可去}
    self.times       = r:readInt16Unsigned() -- {剩余重置次数}
    self.times_used  = r:readInt16Unsigned() -- {已重置次数}
    self.count       = r:readInt16Unsigned() -- {战役数量}
    --self.data = r:readXXXGroup() -- {战役信息块(55830)}
    local i = 1
    self.copyData = {}
    while i <= self.count do
        local tempT={}
        tempT.copy_id  = r:readInt16Unsigned() -- {可以挑战的副本Id}
        tempT.is_pass  = r:readInt8Unsigned()  -- {是否通关过(1：是 0：否)}

        self.copyData[i] = tempT

        if not self.curCopyId then
            if tempT.is_pass==0 then
                self.curCopyId=tempT.copy_id
                self.curPos=i
            elseif i==5 then
                self.curCopyId=tempT.copy_id
                self.curPos=i
                self.allPass=true
            end
        end

        i = i + 1
    end
end
-- end55820
-- (55870手动) -- [55870]挂机返回 -- 拳皇生涯 
ACK_FIGHTERS_UP_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FIGHTERS_UP_REPLY
    self:init()
end)

function ACK_FIGHTERS_UP_REPLY.decode(self, r)
    -- self.chap_id = r:readInt16Unsigned() -- {挂到这个章节}
    -- self.copy_id = r:readInt16Unsigned() -- {挂机这个副本}
    -- self.exp = r:readInt32Unsigned()     -- {经验}
    -- self.gold = r:readInt32Unsigned()    -- {铜钱}
    -- self.power = r:readInt32Unsigned()   -- {战功}
    self.num = r:readInt16Unsigned()     -- {物品数量}
    --self.data = r:readXXXGroup()       -- {物品信息块(5575)}
    local i = 1
    self.goods = {}
    while i <= self.num do
        self.goods[i] = {}
        self.goods[i].goods_id  = r:readInt16Unsigned() -- {物品Id}
        self.goods[i].count     = r:readInt16Unsigned()  -- {物品数量}
        print("------>>lllllll",self.goods[i].goods_id,self.goods[i].count )
        i = i + 1
    end
end
-- end55870
-- (56820手动) -- [56820]各功能状态 -- 系统设置 
ACK_SYS_SET_TYPE_STATE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYS_SET_TYPE_STATE
    self:init()
end)

function ACK_SYS_SET_TYPE_STATE.decode(self, r)
    self.count = r:readInt16Unsigned() -- {功能数量}
    self.data = {}--r:readXXXGroup() -- {信息快(56830)}
    local iCount = 1
    
    while iCount <= self.count do
        self.data[iCount] = {}
        
        self.data[iCount].type  = r:readInt16Unsigned()
        self.data[iCount].state = r:readInt8Unsigned()
        
        iCount = iCount + 1
    end
end
-- end56820
-- (57820手动) -- [57820]当前阵法信息 -- 阵法系统 
ACK_MATRIX_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MATRIX_REPLY
    self:init()
end)

function ACK_MATRIX_REPLY.decode(self, r)
    self.uid = r:readInt32Unsigned() -- {玩家uid 0:自己}
    self.grade = r:readInt8Unsigned() -- {阵法等阶}
    self.node = r:readInt8Unsigned() -- {当前层次最后点亮的节点}
    self.stone = r:readInt32Unsigned() -- {星石值}
    -- self.msg_xxx = r:readXXXGroup() -- {属性加成 信息块 2002}
    self.msg_xxx  = ACK_GOODS_XXX2()--reader:readXXXGroup() -- {属性加成 信息块 2002}
    self.msg_xxx  : decode(r)
    self.skill_id = r:readInt16Unsigned() -- {技能id}
    self.skill_lv = r:readInt16Unsigned() -- {技能等级}

    print("÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷")
    print("ACK_MATRIX_REPLY.deserialize")
    print("{玩家UID}->",self.uid)
    print("{阵法等阶}->",self.grade)
    print("{当前层次最后点亮的节点}->",self.node)
    print("{星石值}->",self.stone)
    print("÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷")
end
-- end57820
-- (58005手动) -- [58005]月卡信息返回 -- 月卡 
ACK_YUEKA_REQUEST_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_YUEKA_REQUEST_CB
    self:init()
end)

function ACK_YUEKA_REQUEST_CB.decode(self, r)
    self.isbuy = r:readInt8Unsigned() -- { 状态 1：需要购买 0：不需要 }
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.msg = {} -- { 信息块 }
    for i=1,self.count do
        local temp = ACK_YUEKA_KA_MSG()
        temp : decode( r )
        self.msg[i] = temp
    end
end
-- end58005
-- (58408手动) -- [58408]抽奖十次(放回) -- 精彩活动转盘 
ACK_ART_ZHUANPAN_TEN_UNLIMIT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_ZHUANPAN_TEN_UNLIMIT
    self:init()
end)

function ACK_ART_ZHUANPAN_TEN_UNLIMIT.decode(self, r)
    self.id = r:readInt32Unsigned() -- { 活动id }
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.msg = {}--r:readXXXGroup() -- { 58409 }
    for i=1,self.count do
        local temp = ACK_ART_ZHUANPAN_TEN_MSG()
        temp : decode( r )
        self.msg[i] = temp
    end
end
-- end58408
-- (58413手动) -- [58413]请求返回（不放回） -- 精彩活动转盘 
ACK_ART_ZHUANPAN_LIMIT_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_ZHUANPAN_LIMIT_CB
    self:init()
end)

function ACK_ART_ZHUANPAN_LIMIT_CB.decode(self, r)
    self.id = r:readInt32Unsigned() -- { 活动Id }
    self.count = r:readInt32Unsigned() -- { 拥有物品数量 }
    self.count2 = r:readInt8Unsigned() -- { 数量 }
    self.msg = {}--r:readXXXGroup() -- { 信息块58415 }
    for i=1,self.count2 do
        local temp = ACK_ART_ZHUANPAN_MSG()
        temp : decode( r )
        self.msg[i] = temp
    end
end
-- end58413
-- (59820手动) -- [59820]美人界面返回 -- 美人系统 
ACK_MEIREN_MID = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MEIREN_MID
    self:init()
end)

function ACK_MEIREN_MID.decode(self, r)
    --self.meiren_id = r:readInt16Unsigned() -- { 美人ID }
    self.count = r:readInt8Unsigned() -- {数量}
    self.msg = {}-- {美人信息块（59830）}
    local iCount = 1
    while iCount <= self.count do
        self.msg[iCount] = {}
        self.msg[iCount] = r:readInt32Unsigned()
        iCount = iCount + 1
    end
end
-- end59820
-- (59840手动) -- [59840]美人缠绵面板（回） -- 美人系统 
ACK_MEIREN_LINGERING_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MEIREN_LINGERING_CB
    self:init()
end)

function ACK_MEIREN_LINGERING_CB.decode(self, r)
    self.mid = r:readInt32Unsigned() -- { 美人id }
    self.lv = r:readInt16Unsigned() -- { 等级 }
    self.exp = r:readInt32Unsigned() -- { 经验 }
    self.power = r:readInt32Unsigned() -- { 战斗力 }
    self.n_count = r:readInt8Unsigned() -- { 需要消耗的数量 }
    self.g_count = r:readInt16Unsigned() -- { 拥有的消耗品数量 }
    self.count = r:readInt8Unsigned()
    self.attr = {}
    for i=1,self.count do
    	local tempData   = ACK_MEIREN_PERCENT_ATTR()
        tempData         : decode( r)
        self.attr[tempData.attr_id] = tempData.percent
        print("属性：",tempData.attr_id,"比率：",tempData.percent)
    end
end
-- end59840
-- (59940手动) -- [59940]亲密属性列表（回） -- 美人系统 
ACK_MEIREN_HONNEY_LIST = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MEIREN_HONNEY_LIST
    self:init()
end)

function ACK_MEIREN_HONNEY_LIST.decode(self, r)
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.attr = {}
    for i=1,self.count do
    	local tempData   = ACK_MEIREN_HONNEY_MSG()
        tempData         : decode( r)
        self.attr[tempData.attr_id] = {tempData.lv,tempData.rate}
        print("属性：",tempData.attr_id,"比率：",tempData.rate,"等级：",tempData.lv)
    end
end
-- end59940
-- (60820手动) -- [60820]护送信息返回 -- 押镖 
ACK_ESCORT_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ESCORT_REPLY
    self:init()
end)

function ACK_ESCORT_REPLY.decode(self, r)
    self.count    = r:readInt16Unsigned() -- {所有正在押送的镖}
    print("ACK_ESCORT_REPLY self.count=",self.count)
    self.msg_xxx1 = {}
    
    if self.count > 0 then
        for i=1,self.count do
            self.msg_xxx1[i] = {}
            local tempData   = ACK_ESCORT_XXX1()
            tempData         : decode( r)
            self.msg_xxx1[i] = tempData   
        end
    end
    --------------------------------------------------------------
    self.all_num  = r:readInt16Unsigned() -- {所有的人战报}
    print("ACK_ESCORT_REPLY self.all_num=",self.all_num)
    self.msg_xxx2 = {}
    
    if self.all_num > 0 then
        for i=1,self.all_num do
            self.msg_xxx2[i] = {}
            local tempData   = ACK_ESCORT_XXX2()
            tempData         : decode( r)
            self.msg_xxx2[i] = tempData   
        end
    end
end
-- end60820
-- (60824手动) -- [60824]可邀请的好友 -- 押镖 
ACK_ESCORT_FRIEND_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ESCORT_FRIEND_DATA
    self:init()
end)

function ACK_ESCORT_FRIEND_DATA.decode(self, r)
    self.id_num = r:readInt16Unsigned() -- {可邀请的好友数量}
    self.data   = {} 
    if self.id_num > 0 then
        for i=1,self.id_num do
            self.data[i]      = {} 
            self.data[i].uid  = r:readInt32Unsigned() -- {好友uid}
            self.data[i].name = r:readString() -- {好友名字}
            self.data[i].lv   = r:readInt16Unsigned() -- {好友等级}
        end
    end
end
-- end60824
-- (60829手动) -- [60829]个人的战报 -- 押镖 
ACK_ESCORT_OWN_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ESCORT_OWN_DATA
    self:init()
end)

function ACK_ESCORT_OWN_DATA.decode(self, r)
    self.num  = r:readInt8Unsigned() -- {数量}
    self.data = {}
    if self.num > 0 then
        for i=1,self.num do
            self.data[i] = {}
            self.data[i].type = r:readInt8Unsigned() -- {类型 1抢 2被抢 3最终}
            self.data[i].uname = r:readString() -- {名字}
            self.data[i].dgold = r:readInt32Unsigned() -- {铜钱}
            self.data[i].dpower = r:readInt32Unsigned() -- {战功}
        end
    end
end
-- end60829
-- (62820手动) -- [62820]界面返回 -- 系统拍卖 
ACK_AUCTION_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_AUCTION_REPLY
    self:init()
end)

function ACK_AUCTION_REPLY.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    print("{信息块（62830）}", self.count)
    self.data = {} -- {信息块（62830）}
    for i=1,self.count do
        temp = ACK_AUCTION_MSG()
        temp : decode( r )
        self.data[temp.pos] = {}
        print(temp.pos,"id",temp.id)
        self.data[temp.pos] = temp
    end
end
-- end62820
-- (62830手动) -- [62830]竞拍内容信息块 -- 系统拍卖 
ACK_AUCTION_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_AUCTION_MSG
    self:init()
end)

function ACK_AUCTION_MSG.decode(self, r)
    self.pos = r:readInt8Unsigned() -- { 识标 }
    self.id = r:readInt16Unsigned() -- { 物品ID }
    self.rmb = r:readInt16Unsigned() -- { 当前竞拍价 }
    self.flag = r:readInt8Unsigned() -- { 拍卖状态（1还未被拍卖/2正在被拍卖/3已经被拍卖/4流拍） }
    if self.flag == 1 then
    	self.next_rmb = r:readInt16Unsigned() -- { 下一次加价元宝 }
    elseif self.flag == 2 then
    	self.time = r:readInt32Unsigned() -- { 上次竞拍时间 }
    	self.next_rmb = r:readInt16Unsigned() -- { 下一次加价元宝 }
    	self.name = r:readString() -- { 名字 }
        self.expend_bind=r:readInt16Unsigned() -- { 当前消耗元宝 }
        self.expend_rmb=r:readInt16Unsigned() -- { 当前消耗钻石 }
    elseif self.flag == 3 then
    	self.name = r:readString() -- { 名字 }
    elseif self.flag == 4 then
    	self.next_rmb = r:readInt16Unsigned() -- { 下一次加价元宝 }
    end
end
-- end62830
-- (63804手动) -- [63804]上下阵成功 -- 门派守卫战 
ACK_DEFENSE_REPLAY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFENSE_REPLAY
    self:init()
end)

function ACK_DEFENSE_REPLAY.decode(self, r)
    self.upd = r:readInt8Unsigned() -- {1 上阵 0下阵}
    self.uid = r:readInt32Unsigned() -- {玩家uid}
    self.type = r:readInt8Unsigned() -- {组别}
    self.count = r:readInt8Unsigned() -- {数量}
    self.data = {} -- {63805}
    for i=1,self.count do
        -- self.data[i] = {}
        local temp = ACK_DEFENSE_USER_SEAT()
        temp : decode( r )
        self.data[i] = temp
    end
    
end
-- end63804
-- (63806手动) -- [63806]分组所有信息 -- 门派守卫战 
ACK_DEFENSE_ALL_GROUP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFENSE_ALL_GROUP
    self:init()
end)

function ACK_DEFENSE_ALL_GROUP.decode(self, r)
    self.num = r:readInt8Unsigned() -- {组别数量}
    self.data = {}
    for j=1,self.num do
        local nType=r:readInt8Unsigned() -- {组别}
        local nCount=r:readInt8Unsigned() -- {数量}
        self.data[nType]={}
        -- self.data[nType].data = {} -- {63805}
        for i=1,nCount do
            -- self.data[j].data[i] = {}
            local temp = ACK_DEFENSE_USER_SEAT()
            temp : decode( r )
            -- self.data[j].data[i] = temp
            self.data[nType][temp.uid]=temp
        end
    end
    
end
-- end63806
-- (63809手动) -- [63809]界面返回 -- 门派守卫战 
ACK_DEFENSE_BWJM_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFENSE_BWJM_BACK
    self:init()
end)

function ACK_DEFENSE_BWJM_BACK.decode(self, r)
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.group = {}                   -- { 可进组别 }
    for i=1,self.count do
       self.group[i] = r:readInt8Unsigned() 
    end
   
end
-- end63809
-- (63940手动) -- [63940]战报返回 -- 门派守卫战 
ACK_DEFENSE_ZHANBAO = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFENSE_ZHANBAO
    self:init()
end)

function ACK_DEFENSE_ZHANBAO.decode(self, r)
    self.data = ACK_DEFENSE_XXX()
    self.data : decode(r)
end
-- end63940
-- (63990手动) -- [63990]结算 -- 门派守卫战 
ACK_DEFENSE_OVER = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFENSE_OVER
    self:init()
end)

function ACK_DEFENSE_OVER.decode(self, r)
    self.data = ACK_DEFENSE_XXX()
    self.data : decode(r)
end
-- end63990
-- (64000手动) -- [64000]战斗中信息 -- 门派守卫战 
ACK_DEFENSE_COMBAT_INFOR = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFENSE_COMBAT_INFOR
    self:init()
end)

function ACK_DEFENSE_COMBAT_INFOR.decode(self, r)
    self.data = ACK_DEFENSE_XXX()
    self.data : decode(r)
end
-- end64000
-- (64120手动) -- [64120]界面返回 -- 第一门派 
ACK_HILL_REPLAY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HILL_REPLAY
    self:init()
end)

function ACK_HILL_REPLAY.decode(self, r)
    self.clan_name = r:readString()    -- { 防守门派 }
    self.res   = r:readInt8Unsigned()  -- { 挑战情况 }
    self.bonus = r:readInt32Unsigned() -- { 伤害加成 }
    self.reduction = r:readInt32Unsigned() -- { 免伤加成 }
    self.time = r:readInt32Unsigned() -- { 挑战cd }
    self.count = r:readInt8Unsigned() -- { 数量 }
    self.data = {} -- { 64130信息块 }
    for i=1,self.count do
        local date = ACK_HILL_FS_DATA()
        date : decode( r )
        self.data[i] = date
    end
end
-- end64120
-- (64150手动) -- [64150]门派排行 -- 第一门派 
ACK_HILL_CLAN_TOP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HILL_CLAN_TOP
    self:init()
end)

function ACK_HILL_CLAN_TOP.decode(self, r)
    self.type  = r:readInt8Unsigned() -- { 0:门派排行1:个人排行 }
    self.zrank = r:readInt16Unsigned()  -- 个人/门派 排名
    self.zharm = r:readInt32Unsigned()  -- 个人/门派 伤害
    self.zkill = r:readInt16Unsigned()  -- 个人/门派 击杀
    self.count = r:readInt16Unsigned()  -- 循环 
    self.clan_id    = {}
    self.clan_name  = {}
    self.uid        = {}
    self.name       = {}
    self.rank       = {}
    self.all_bonus  = {}
    self.killed     = {}
    if self.type == 0 then
        for i=1,self.count do     
            self.clan_id[i]    = r:readInt32Unsigned() -- { 门派id }
            self.clan_name[i]  = r:readString() -- { 门派名 }
            self.rank[i]       = r:readInt16Unsigned() -- { 排名 }
            self.all_bonus[i]  = r:readInt32Unsigned() -- { 总伤害 }
            self.killed[i]     = r:readInt16Unsigned() -- { 总击杀 }
        end
    elseif self.type == 1 then 
        for i=1,self.count do  
            self.uid[i]        = r:readInt32Unsigned() -- { 玩家uid }
            self.name[i]       = r:readString() -- { 玩家名 }
            self.rank[i]       = r:readInt16Unsigned() -- { 排名 }
            self.all_bonus[i]  = r:readInt32Unsigned() -- { 总伤害 }
            self.killed[i]     = r:readInt16Unsigned() -- { 总击杀 }
        end
    end
      
        
end
-- end64150
-- (64170手动) -- [64170]战报信息 -- 第一门派 
ACK_HILL_REDIO_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HILL_REDIO_BACK
    self:init()
end)

function ACK_HILL_REDIO_BACK.decode(self, r)
    self.count = r:readInt16Unsigned() -- { 数量 }
    self.data  = {} -- { 64180信息块 }
    for i=1,self.count do
        local date = ACK_HILL_REDIO_DATA()
        date:decode( r )
        self.data[i] = date
    end
end
-- end64170
-- (64860手动) -- [64860]兑换面板返回 -- 挑战迷宫 
ACK_MAZE_SHOP_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAZE_SHOP_REPLY
    self:init()
end)

function ACK_MAZE_SHOP_REPLY.decode(self, r)
    self.dgoods = r:readXXXGroup() -- {物品数据块64870}
end
-- end64860
-- (64890手动) -- [64890]探险结束 -- 挑战迷宫 
ACK_MAZE_OVER_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAZE_OVER_BACK
    self:init()
end)

function ACK_MAZE_OVER_BACK.decode(self, r)
    self.num   = r:readInt8Unsigned() -- {骰子点数 0:多次}
    self.count = r:readInt16Unsigned() -- {获得的物品的数量}
    self.goods_id_no = {}--r:readXXXGroup() -- {物品数据块64870}
    for i=1,self.count do
        self.goods_id_no[i] = ACK_MAZE_GOODS_XXX()
        self.goods_id_no[i] : decode(r)
    end
end
-- end64890
-- (65100手动) -- [65100]探险包裹 -- 挑战迷宫 
ACK_MAZE_BAG_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAZE_BAG_BACK
    self:init()
end)

function ACK_MAZE_BAG_BACK.decode(self, r)
    self.count = r:readInt16Unsigned() -- {数量}
    -- self.idx = r:readInt16Unsigned() -- {物品所在容器位置}
    self.data = {}--r:readXXXGroup() -- {物品数据块64870}
    for i=1,self.count do
        self.data[i]     = {}
        self.data[i].idx = r:readInt16Unsigned()
        self.data[i].goods_id = r:readInt32Unsigned()
        self.data[i].goods_num = r:readInt32Unsigned()
    end
end
-- end65100
-- (65315手动) -- [65315]秘宝活动界面返回 -- 秘宝活动 
ACK_MIBAO_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MIBAO_REPLY
    self:init()
end)

function ACK_MIBAO_REPLY.decode(self, r)
    self.count = r:readInt16Unsigned() -- { 数量 }
    self.msg_xxx = {}--r:readXXXGroup() -- { 信息块(65320) }
    for i=1,self.count do
        local tempData=ACK_MIBAO_REPLY_DATA()
        tempData:decode(r)
        self.msg_xxx[i]=tempData
    end
end
-- end65315
-- (65350手动) -- [65350]箱子返回 -- 秘宝活动 
ACK_MIBAO_BOX_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MIBAO_BOX_REPLY
    self:init()
end)

function ACK_MIBAO_BOX_REPLY.decode(self, r)
    self.count = r:readInt16Unsigned() -- { 数量 }
    self.box_xxx = {}--r:readXXXGroup() -- { 箱子信息块 }
    for i=1,self.count do
        local tempData=ACK_MIBAO_BOX_DATA()
        tempData:decode(r)
        self.box_xxx[i]=tempData
    end
end
-- end65350
-- (65360手动) -- [65360]箱子消失 -- 秘宝活动 
ACK_MIBAO_BOX_DISAPPEAR = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MIBAO_BOX_DISAPPEAR
    self:init()
end)

function ACK_MIBAO_BOX_DISAPPEAR.decode(self, r)
    self.box_idx = r:readInt32Unsigned() -- { 箱子id }
    self.type = r:readInt8Unsigned() -- { 消失类型(1消失2物品3怪物) }

    if self.type==2 then
        self.count = r:readInt16Unsigned() -- { 数量 }
        self.xxx = {} -- { 怪物or物品 信息块 }
        for i=1,self.count do
            local tempData=ACK_MIBAO_GOODS_LIST()
            tempData:decode(r)
            self.xxx[i]=tempData
        end
    elseif self.type==3 then
        self.count = r:readInt16Unsigned() -- { 数量 }
        self.xxx = {} -- { 怪物or物品 信息块 }
        for i=1,self.count do
            local tempData=ACK_SCENE_MONSTER_DATA()
            tempData:decode(r)
            self.xxx[i]=tempData
        end
    end
end
-- end65360
-- (65370手动) -- [65370]所有物品掉落信息 -- 秘宝活动 
ACK_MIBAO_GOODS_ALL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MIBAO_GOODS_ALL
    self:init()
end)

function ACK_MIBAO_GOODS_ALL.decode(self, r)
    self.count = r:readInt16Unsigned() -- { 数量 }
    self.xxx_goods = {}--r:readXXXGroup() -- { 物品信息块 }
    for i=1,self.count do
        local tempData=ACK_MIBAO_GOODS_LIST()
        tempData:decode(r)
        self.xxx_goods[i]=tempData
    end
end
-- end65370
-- (65390手动) -- [65390]玩家死亡 -- 秘宝活动 
ACK_MIBAO_PLAYER_DIE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MIBAO_PLAYER_DIE
    self:init()
end)

function ACK_MIBAO_PLAYER_DIE.decode(self, r)
    self.time = r:readInt16Unsigned() -- { 剩余复活时间 }
    self.rmb  = r:readInt8Unsigned() -- { 复活需要元宝 }
    self.type = r:readInt8Unsigned() -- { 1被玩家杀死2被boss杀死 }
    if self.type == 1 then
        self.player_name = r:readString() -- {玩家名字}
    else
        self.boss_id = r:readInt16Unsigned() -- {BossId}
    end
end
-- end65390
--/** =============================== 自动生成的代码 =============================== **/
--/*************************** don't touch this line *********** AUTO_CODE_END_ACKH **/



--/** AUTO_CODE_BEGIN_ACKA **************** don't touch this line ********************/
--/** =============================== 自动生成的代码 =============================== **/

-- [502]服务器将断开连接 -- 系统 
ACK_SYSTEM_DISCONNECT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYSTEM_DISCONNECT
    self:init()
end)

function ACK_SYSTEM_DISCONNECT.decode(self, r)
    self.error_code = r:readInt16Unsigned() -- { 错误代码 }
    self.msg = r:readUTF() -- { 信息数据 }
end

-- [510]时间校正 -- 系统 
ACK_SYSTEM_TIME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYSTEM_TIME
    self:init()
end)

function ACK_SYSTEM_TIME.decode(self, r)
    self.srv_time = r:readInt32Unsigned() -- { 服务器时间戳 }
end

-- [520]GM修改服务器时间 -- 系统 
ACK_SYSTEM_TIME_GM = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYSTEM_TIME_GM
    self:init()
end)

function ACK_SYSTEM_TIME_GM.decode(self, r)
    self.srv_time = r:readInt32Unsigned() -- { 服务器时间戳 }
end

-- [800]系统通知 -- 系统 
ACK_SYSTEM_NOTICE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYSTEM_NOTICE
    self:init()
end)

function ACK_SYSTEM_NOTICE.decode(self, r)
    self.show_time = r:readInt32Unsigned() -- { 显示时长(小于默认时长或于最大,为默认时长)<br />见常量:CONST_NOTICE_SHOW_* }
    self.msg_type = r:readInt16Unsigned() -- { 消息类型 }
    self.msg_data = r:readUTF() -- { 消息内容 }
end

-- [820]游戏提示 -- 系统 
ACK_SYSTEM_TIPS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYSTEM_TIPS
    self:init()
end)

function ACK_SYSTEM_TIPS.decode(self, r)
    self.type_id = r:readInt16Unsigned() -- { 提示类型 }
    self.count = r:readInt16Unsigned() -- { 消息数量 }
    self.tips_data = r:readInt32() -- { 提示数据 }
end

-- [840]充值查询结果返回 -- 系统 
ACK_SYSTEM_PAY_STATE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYSTEM_PAY_STATE
    self:init()
end)

function ACK_SYSTEM_PAY_STATE.decode(self, r)
    self.state = r:readInt8Unsigned() -- { 状态 }
end

-- [850]系统活动限时开放 -- 系统 
ACK_SYSTEM_ACTIVE_OPEN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYSTEM_ACTIVE_OPEN
    self:init()
end)

function ACK_SYSTEM_ACTIVE_OPEN.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 活动id }
    self.state = r:readInt8Unsigned() -- { 是否开启 }
end

-- [1012]断线重连返回 -- 角色 
ACK_ROLE_LOGIN_AG_ERR = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_LOGIN_AG_ERR
    self:init()
end)

function ACK_ROLE_LOGIN_AG_ERR.decode(self, r)
    self.result = r:readInt8Unsigned() -- { 0:失败|1:成功 }
end

-- [1021]创建/登录(有角色)成功 -- 角色 
ACK_ROLE_LOGIN_OK_HAVE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_LOGIN_OK_HAVE
    self:init()
end)

function ACK_ROLE_LOGIN_OK_HAVE.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 用户ID }
    self.uname = r:readString() -- { 角色名 }
    self.sex = r:readInt8Unsigned() -- { 性别 }
    self.pro = r:readInt8Unsigned() -- { 职业 }
    self.lv = r:readInt16Unsigned() -- { 等级 }
    self.country = r:readInt8Unsigned() -- { 阵营 }
    self.is_red_name = r:readInt8Unsigned() -- { 是否红名(CONST_PLAYER_FLAG_*) }
    self.skin_armor = r:readInt16Unsigned() -- { 装备衣服皮肤ID }
end

-- [1022]货币 -- 角色 
ACK_ROLE_CURRENCY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_CURRENCY
    self:init()
end)

function ACK_ROLE_CURRENCY.decode(self, r)
    self.gold = r:readInt32Unsigned() -- { 银元 }
    self.rmb = r:readInt32Unsigned() -- { 金元 }
    self.bind_rmb = r:readInt32Unsigned() -- { 绑定金元 }
end

-- [1023]登录成功(没有角色) -- 角色 
ACK_ROLE_LOGIN_OK_NO_ROLE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_LOGIN_OK_NO_ROLE
    self:init()
end)

function ACK_ROLE_LOGIN_OK_NO_ROLE.decode(self, r)
    self.pro = r:readInt8Unsigned() -- { 默认职业 }
end

-- [1025]返回名字 -- 角色 
ACK_ROLE_NAME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_NAME
    self:init()
end)

function ACK_ROLE_NAME.decode(self, r)
    self.name = r:readUTF() -- { 名字 }
end

-- [1026]角色创建时间 -- 角色 
ACK_ROLE_CREATE_TIME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_CREATE_TIME
    self:init()
end)

function ACK_ROLE_CREATE_TIME.decode(self, r)
    self.time_reg = r:readInt32Unsigned() -- { 注册时间戳 }
    self.time_lv_up = r:readInt32Unsigned() -- { 升级时间戳 }
end

-- [1027]角色生一级消耗时间 -- 角色 
ACK_ROLE_TIME_USE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_TIME_USE
    self:init()
end)

function ACK_ROLE_TIME_USE.decode(self, r)
    self.lv = r:readInt16Unsigned() -- { 等级 }
    self.time = r:readInt32Unsigned() -- { 时间 }
end

-- [1030]登录失败 -- 角色 
ACK_ROLE_LOGIN_FAIL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_LOGIN_FAIL
    self:init()
end)

-- [1050]创建失败 -- 角色 
ACK_ROLE_CREATE_FAIL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_CREATE_FAIL
    self:init()
end)

function ACK_ROLE_CREATE_FAIL.decode(self, r)
    self.error_code = r:readInt16Unsigned() -- { 错误代码 }
end

-- [1061]销毁角色(成功) -- 角色 
ACK_ROLE_DEL_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_DEL_OK
    self:init()
end)

function ACK_ROLE_DEL_OK.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 用户ID }
end

-- [1063]销毁角色(失败) -- 角色 
ACK_ROLE_DEL_FAIL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_DEL_FAIL
    self:init()
end)

function ACK_ROLE_DEL_FAIL.decode(self, r)
    self.error_code = r:readInt16Unsigned() -- { 错误代码 }
end

-- [1075]转职成功 -- 角色 
ACK_ROLE_CHANGE_PRO_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_CHANGE_PRO_REPLY
    self:init()
end)

-- [1110]称号信息块 -- 角色 
ACK_ROLE_TITLE_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_TITLE_MSG
    self:init()
end)

function ACK_ROLE_TITLE_MSG.decode(self, r)
    self.title_id = r:readInt16Unsigned() -- { 称号ID }
end

-- [1111]神器信息块 -- 角色 
ACK_ROLE_MAGIC_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_MAGIC_MSG
    self:init()
end)

function ACK_ROLE_MAGIC_MSG.decode(self, r)
    self.magic_id = r:readInt16Unsigned() -- { 神器ID }
end

-- [1128]玩家扩展属性(暂无效) -- 角色 
ACK_ROLE_PROPERTY_EXT_R = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_PROPERTY_EXT_R
    self:init()
end)

function ACK_ROLE_PROPERTY_EXT_R.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家UID }
    self.renown = r:readInt32Unsigned() -- { 声望 }
    self.slaughter = r:readInt32Unsigned() -- { 杀戮值 }
    self.honor = r:readInt32Unsigned() -- { 荣誉值 }
    self.ext2 = r:readInt32Unsigned() -- { 扩展 }
    self.ext3 = r:readInt32Unsigned() -- { 扩展 }
    self.ext4 = r:readInt32Unsigned() -- { 扩展 }
    self.ext5 = r:readInt32Unsigned() -- { 扩展 }
    self.ext6 = r:readInt32Unsigned() -- { 扩展 }
    self.ext7 = r:readInt32Unsigned() -- { 扩展 }
end

-- [1130]玩家单个属性更新 -- 角色 
ACK_ROLE_PROPERTY_UPDATE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_PROPERTY_UPDATE
    self:init()
end)

function ACK_ROLE_PROPERTY_UPDATE.decode(self, r)
    self.id = r:readInt32Unsigned() -- { 0:玩家|伙伴ID }
    self.type = r:readInt8Unsigned() -- { 详见:通用常量--玩家属性 }
    self.value = r:readInt32Unsigned() -- { 新值 }
end

-- [1131]玩家单个属性更新[字符串] -- 角色 
ACK_ROLE_PROPERTY_UPDATE2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_PROPERTY_UPDATE2
    self:init()
end)

function ACK_ROLE_PROPERTY_UPDATE2.decode(self, r)
    self.id = r:readInt32Unsigned() -- { 0:玩家|伙伴ID }
    self.type = r:readInt8Unsigned() -- { 详见:通用常量--玩家属性 }
    self.value = r:readString() -- { 新值 }
end

-- [1160]角色任务开放系统 -- 角色 
ACK_ROLE_OPEN_SYS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_OPEN_SYS
    self:init()
end)

function ACK_ROLE_OPEN_SYS.decode(self, r)
    self.task_id = r:readInt32Unsigned() -- { 任务ID（见常量：CONST_SYS_TASK_ID_*） }
end

-- [1261]请求精力值成功 -- 角色 
ACK_ROLE_ENERGY_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_ENERGY_OK
    self:init()
end)

function ACK_ROLE_ENERGY_OK.decode(self, r)
    self.sum = r:readInt16Unsigned() -- { 当前精力值 }
    self.max = r:readInt16Unsigned() -- { 最大精力值 }
end

-- [1262]额外赠送精力 -- 角色 
ACK_ROLE_BUFF_ENERGY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_BUFF_ENERGY
    self:init()
end)

function ACK_ROLE_BUFF_ENERGY.decode(self, r)
    self.buff_value = r:readInt32Unsigned() -- { 额外加的体力 }
end

-- [1264]请求购买面板成功 -- 角色 
ACK_ROLE_OK_ASK_BUYE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_OK_ASK_BUYE
    self:init()
end)

function ACK_ROLE_OK_ASK_BUYE.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 购买精力类型-[见常量CONST_ENERGY_购买精力类型] }
    self.num = r:readInt8Unsigned() -- { 第几次购买 }
    self.sumnum = r:readInt8Unsigned() -- { 可购买总次数 }
    self.rmb = r:readInt16Unsigned() -- { 购买需花费的元宝数 }
end

-- [1267]购买精力成功 -- 角色 
ACK_ROLE_OK_BUY_ENERGY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_OK_BUY_ENERGY
    self:init()
end)

-- [1280]单个活动次数更新 -- 角色 
ACK_ROLE_SYS_CHANGE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_SYS_CHANGE
    self:init()
end)

function ACK_ROLE_SYS_CHANGE.decode(self, r)
    self.sys_id = r:readInt16Unsigned() -- { 系统ID }
    self.num = r:readInt8Unsigned() -- { 可玩次数 }
end

-- [1311]请求vip回复 -- 角色 
ACK_ROLE_LV_MY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_LV_MY
    self:init()
end)

function ACK_ROLE_LV_MY.decode(self, r)
    self.lv = r:readInt8Unsigned() -- { 自己的vip等级 }
    self.vip_up = r:readInt32() -- { 已购买金元总数 }
end

-- [1313]玩家VIP等级 -- 角色 
ACK_ROLE_VIP_LV = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_VIP_LV
    self:init()
end)

function ACK_ROLE_VIP_LV.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家UID }
    self.lv = r:readInt8Unsigned() -- { vip等级 }
end

-- [1330]提醒签到 -- 角色 
ACK_ROLE_NOTICE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_NOTICE
    self:init()
end)

-- [1332]请求签到面板成功 -- 角色 
ACK_ROLE_OK_REQUEST = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_OK_REQUEST
    self:init()
end)

function ACK_ROLE_OK_REQUEST.decode(self, r)
    self.viplv = r:readInt8Unsigned() -- { 当前vip等级 }
    self.num = r:readInt8Unsigned() -- { 第几天签到 }
    self.signvip = r:readInt8Unsigned() -- { Vip签到标记[见常量CONST_SIGN_*] }
    self.signcom = r:readInt8Unsigned() -- { 普通签到标记[见常量CONST_SIGN_*] }
end

-- [1334]玩家签到成功 -- 角色 
ACK_ROLE_OK_CLICK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_OK_CLICK
    self:init()
end)

function ACK_ROLE_OK_CLICK.decode(self, r)
    self.cltype = r:readInt8Unsigned() -- { 签到类型-见常量[CONST_SIGN_玩家类型] }
end

-- [1340]在线奖励 -- 角色 
ACK_ROLE_ONLINE_REWARD = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_ONLINE_REWARD
    self:init()
end)

function ACK_ROLE_ONLINE_REWARD.decode(self, r)
    self.time = r:readInt8Unsigned() -- { 时间 }
    self.stime = r:readInt32Unsigned() -- { 剩余时间 }
end

-- [1341]等级礼包 -- 角色 
ACK_ROLE_LEVEL_GIFT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_LEVEL_GIFT
    self:init()
end)

function ACK_ROLE_LEVEL_GIFT.decode(self, r)
    self.leveled = r:readInt8Unsigned() -- { 等级 }
end

-- [1365]buffs数据 -- 角色 
ACK_ROLE_XXFFS_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_XXFFS_DATA
    self:init()
end)

function ACK_ROLE_XXFFS_DATA.decode(self, r)
    self.id = r:readInt16Unsigned() -- { buff的id，详见CONST_BUFF_* }
    self.add_gold = r:readInt16Unsigned() -- { buff铜钱加成 }
    self.add_exp = r:readInt16Unsigned() -- { buff经验加成 }
end

-- [1370]通知加buff -- 角色 
ACK_ROLE_BUFF = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_BUFF
    self:init()
end)

function ACK_ROLE_BUFF.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 12点18点赠送体力 }
    self.state = r:readInt8Unsigned() -- { 状态 }
end

-- [1376]领取体力返回 -- 角色 
ACK_ROLE_BUFF_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_BUFF_REPLY
    self:init()
end)

-- [1390]属性加成信息块 -- 角色 
ACK_ROLE_MSG_ATTR_ADD = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_MSG_ATTR_ADD
    self:init()
end)

function ACK_ROLE_MSG_ATTR_ADD.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 类型 }
    self.value = r:readInt16Unsigned() -- { 值(万分之) }
    self.time = r:readInt32Unsigned() -- { 到期时间戳 }
end

-- [1396]是否有属性加成返回 -- 角色 
ACK_ROLE_ATTR_FLAG_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_ATTR_FLAG_REPLY
    self:init()
end)

function ACK_ROLE_ATTR_FLAG_REPLY.decode(self, r)
    self.flag = r:readInt8Unsigned() -- { 1：有,0没有 }
end

-- [1408]战斗力信息块 -- 角色 
ACK_ROLE_POWERFUL_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_POWERFUL_XXX
    self:init()
end)

function ACK_ROLE_POWERFUL_XXX.decode(self, r)
    self.type = r:readInt16Unsigned() -- { 类型 }
    self.powerful = r:readInt32Unsigned() -- { 战斗力 }
end

-- [1430]系统标点 -- 角色 
ACK_ROLE_SYS_POINTS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_SYS_POINTS
    self:init()
end)

function ACK_ROLE_SYS_POINTS.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 功能id }
    self.is_have = r:readInt8Unsigned() -- { 0:消失 1:出现 }
end

-- [1433]灵妖信息块 -- 角色 
ACK_ROLE_MSG_LINGYAO = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ROLE_MSG_LINGYAO
    self:init()
end)

function ACK_ROLE_MSG_LINGYAO.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 灵妖ID }
end

-- [2004]装备打造附加块 -- 物品/背包 
ACK_GOODS_XXX4 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_XXX4
    self:init()
end)

function ACK_GOODS_XXX4.decode(self, r)
    self.plus_type = r:readInt8Unsigned() -- { 附加属性类型 (组:装备-打造-附加) }
    self.plus_current = r:readInt16Unsigned() -- { 当前附加属性 (组:装备-打造-附加) }
    self.plus_max = r:readInt16Unsigned() -- { 附加属性上限 (组:装备-打造-附加) }
end

-- [2005]插槽属性块 -- 物品/背包 
ACK_GOODS_XXX5 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_XXX5
    self:init()
end)

function ACK_GOODS_XXX5.decode(self, r)
    self.slot_attr_type = r:readInt8Unsigned() -- { 插槽属性类型 }
    self.slot_attr_value = r:readInt32Unsigned() -- { 插槽属性值 }
end

-- [2006]基础属性块 -- 物品/背包 
ACK_GOODS_ATTR_BASE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_ATTR_BASE
    self:init()
end)

function ACK_GOODS_ATTR_BASE.decode(self, r)
    self.attr_base_type = r:readInt16Unsigned() -- { 类型 }
    self.attr_base_value = r:readInt32Unsigned() -- { 值 }
end

-- [2070]获得|失去货币通知 -- 物品/背包 
ACK_GOODS_CURRENCY_CHANGE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_CURRENCY_CHANGE
    self:init()
end)

function ACK_GOODS_CURRENCY_CHANGE.decode(self, r)
    self.type = r:readBoolean() -- { true:获得 | false:失去 }
    self.money_type = r:readInt8Unsigned() -- { 货币类型 }
    self.money_num = r:readInt32Unsigned() -- { 货币数量 }
end

-- [2081]伙伴经验丹使用成功 -- 物品/背包 
ACK_GOODS_P_EXP_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_P_EXP_OK
    self:init()
end)

-- [2097]使用充值卡成功 -- 物品/背包 
ACK_GOODS_HUAFEI_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_HUAFEI_SUCCESS
    self:init()
end)

-- [2099]改名成功 -- 物品/背包 
ACK_GOODS_CHANG_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_CHANG_SUCCESS
    self:init()
end)

-- [2227]扩充需要的道具数量 -- 物品/背包 
ACK_GOODS_ENLARGE_COST = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_ENLARGE_COST
    self:init()
end)

function ACK_GOODS_ENLARGE_COST.decode(self, r)
    self.goods_id = r:readInt32Unsigned() -- { 物品id }
    self.count = r:readInt16Unsigned() -- { 需要消耗道具数 }
    self.enlargh_c = r:readInt16Unsigned() -- { 已扩充次数 }
end

-- [2230]容器扩充成功 -- 物品/背包 
ACK_GOODS_ENLARGE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_ENLARGE
    self:init()
end)

function ACK_GOODS_ENLARGE.decode(self, r)
    self.max = r:readInt16Unsigned() -- { 当前背包最大格子数 }
end

-- [2262]出售成功 -- 物品/背包 
ACK_GOODS_SELL_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_SELL_OK
    self:init()
end)

-- [2272]一键互换成功 -- 物品/背包 
ACK_GOODS_SWAP_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_SWAP_OK
    self:init()
end)

-- [2301]商店物品信息块 -- 物品/背包 
ACK_GOODS_SHOP_XXX1 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_SHOP_XXX1
    self:init()
end)

function ACK_GOODS_SHOP_XXX1.decode(self, r)
    self.id = r:readInt32Unsigned() -- { 物品id }
    self.price = r:readInt32Unsigned() -- { 价格 }
end

-- [2321]商店购买成功 -- 物品/背包 
ACK_GOODS_SHOP_BUY_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_SHOP_BUY_OK
    self:init()
end)

-- [2327]元宵节活动将会获得的物品索引(0~11) -- 物品/背包 
ACK_GOODS_LANTERN_INDEX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_LANTERN_INDEX
    self:init()
end)

function ACK_GOODS_LANTERN_INDEX.decode(self, r)
    self.index = r:readInt8Unsigned() -- {  }
end

-- [2333]次数物品数据块 -- 物品/背包 
ACK_GOODS_TIMES_XXX1 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_TIMES_XXX1
    self:init()
end)

function ACK_GOODS_TIMES_XXX1.decode(self, r)
    self.goods_id = r:readInt32Unsigned() -- { 物品ID }
    self.count = r:readInt16Unsigned() -- { 已使用次数 }
    self.cost_type = r:readInt8Unsigned() -- { 消耗货币类型 }
    self.cost_value = r:readInt32Unsigned() -- { 消耗货币值 }
    self.idx = r:readInt16Unsigned() -- { 物品索引 }
    self.sum = r:readInt16Unsigned() -- { 物品总数 }
end

-- [2334]次数物品日志数据块 -- 物品/背包 
ACK_GOODS_TIMES_XXX2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_TIMES_XXX2
    self:init()
end)

function ACK_GOODS_TIMES_XXX2.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 使用者uid }
    self.name = r:readString() -- { 使用者名字 }
    self.name_color = r:readInt8Unsigned() -- { 使用者名字颜色 }
    self.gid_use = r:readInt32Unsigned() -- { 使用的物品ID }
    self.count_use = r:readInt16Unsigned() -- { 使用的物品数量 }
    self.gid_get = r:readInt32Unsigned() -- { 获得的物品ID }
    self.count_get = r:readInt16Unsigned() -- { 获得的物品数量 }
    self.seconds = r:readInt32Unsigned() -- { 使用时间戳 }
end

-- [2335]元宵活动物品信息块 -- 物品/背包 
ACK_GOODS_TIMES_XXX3 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_TIMES_XXX3
    self:init()
end)

function ACK_GOODS_TIMES_XXX3.decode(self, r)
    self.goods_id = r:readInt16Unsigned() -- {  }
    self.count = r:readInt16Unsigned() -- {  }
end

-- [2338]特定活动物品是否可使用 -- 物品/背包 
ACK_GOODS_ACTY_USE_STATE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GOODS_ACTY_USE_STATE
    self:init()
end)

function ACK_GOODS_ACTY_USE_STATE.decode(self, r)
    self.goods_id = r:readInt32Unsigned() -- { 物品ID }
    self.state = r:readBoolean() -- { true:可使用 | false:不可使用 }
end

-- [2512]打造成功 -- 物品/打造/强化 
ACK_MAKE_MAKE_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_MAKE_OK
    self:init()
end)

function ACK_MAKE_MAKE_OK.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 1背包2装备栏 }
    self.id = r:readInt32Unsigned() -- { 主将0|武将ID }
    self.idx = r:readInt16Unsigned() -- { 物品的idx }
end

-- [2518]强化消耗材料信息块 -- 物品/打造/强化 
ACK_MAKE_STREN_COST_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_STREN_COST_XXX
    self:init()
end)

function ACK_MAKE_STREN_COST_XXX.decode(self, r)
    self.type = r:readInt16Unsigned() -- { 类型 }
    self.type_value = r:readInt32Unsigned() -- { 类型值 }
end

-- [2519]已强化到最高级 -- 物品/打造/强化 
ACK_MAKE_STREN_MAX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_STREN_MAX
    self:init()
end)

-- [2520]装备强化成功 -- 物品/打造/强化 
ACK_MAKE_STRENGTHEN_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_STRENGTHEN_OK
    self:init()
end)

function ACK_MAKE_STRENGTHEN_OK.decode(self, r)
    self.flag = r:readInt8Unsigned() -- { 是否成功 }
    self.type = r:readInt8Unsigned() -- { 1背包2装备栏 }
    self.id = r:readInt32Unsigned() -- { 主将0|武将ID }
    self.idx = r:readInt8Unsigned() -- { 强化后的物品idx }
end

-- [2525]法宝升阶成功 -- 物品/打造/强化 
ACK_MAKE_UPGRADE_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_UPGRADE_OK
    self:init()
end)

function ACK_MAKE_UPGRADE_OK.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 1背包2装备栏 }
    self.id = r:readInt32Unsigned() -- { 主将0|武将ID }
    self.idx = r:readInt16Unsigned() -- { 物品的idx }
end

-- [2536]附加属性数据块2 -- 物品/打造/强化 
ACK_MAKE_PLUS_MSG_XXX2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_PLUS_MSG_XXX2
    self:init()
end)

function ACK_MAKE_PLUS_MSG_XXX2.decode(self, r)
    self.plus_pos = r:readInt8Unsigned() -- { 属性位置 }
    self.plus_type = r:readInt8Unsigned() -- { 属性类型 }
    self.plus_color	 = r:readInt8Unsigned() -- { 属性颜色 }
    self.plus_value = r:readInt32Unsigned() -- { 属性值 }
    self.plus_max = r:readInt32Unsigned() -- { 最大属性值 }
    self.plus_lock = r:readInt8Unsigned() -- { 是否锁定(1锁定0没锁定) }
end

-- [2542]保留洗练属性成功 -- 物品/打造/强化 
ACK_MAKE_WASH_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_WASH_OK
    self:init()
end)

function ACK_MAKE_WASH_OK.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 1背包2装备栏 }
    self.id = r:readInt32Unsigned() -- { 主将0|武将ID }
    self.idx = r:readInt16Unsigned() -- { 物品的idx }
end

-- [2552]灵珠合成成功 -- 物品/打造/强化 
ACK_MAKE_COMPOSE_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_COMPOSE_OK
    self:init()
end)

-- [2561]镶嵌宝石成功 -- 物品/打造/强化 
ACK_MAKE_PEARL_INSET_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_PEARL_INSET_OK
    self:init()
end)

-- [2565]宝石一键镶嵌元宝数 -- 物品/打造/强化 
ACK_MAKE_INSET_RMB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_INSET_RMB
    self:init()
end)

function ACK_MAKE_INSET_RMB.decode(self, r)
    self.rmb = r:readInt32Unsigned() -- { 元宝数 }
end

-- [2582]法宝拆分成功 -- 物品/打造/强化 
ACK_MAKE_MAGIC_PART_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_MAGIC_PART_OK
    self:init()
end)

-- [2600]附魔成功 -- 物品/打造/强化 
ACK_MAKE_ENCHANT_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_ENCHANT_OK
    self:init()
end)

function ACK_MAKE_ENCHANT_OK.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 类型 }
    self.id = r:readInt32Unsigned() -- { 主将0|武将ID }
    self.idx = r:readInt16Unsigned() -- { 物品的idx }
end

-- [2620]附魔消耗 -- 物品/打造/强化 
ACK_MAKE_ENCHANT_PAY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_ENCHANT_PAY
    self:init()
end)

function ACK_MAKE_ENCHANT_PAY.decode(self, r)
    self.rmb = r:readInt32Unsigned() -- { 钻石数 }
end

-- [2710]装备升品返回(新的) -- 物品/打造/强化 
ACK_MAKE_EQUIP_NEW_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_EQUIP_NEW_REPLY
    self:init()
end)

function ACK_MAKE_EQUIP_NEW_REPLY.decode(self, r)
    self.flag = r:readInt8Unsigned() -- { 是否打造成功 }
    self.type = r:readInt8Unsigned() -- { 1背包2装备栏 }
    self.id = r:readInt32Unsigned() -- { 主将0|武将ID }
    self.idx = r:readInt16Unsigned() -- { 物品的idx }
end

-- [2738]宝石信息块 -- 物品/打造/强化 
ACK_MAKE_GEM_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_GEM_XXX
    self:init()
end)

function ACK_MAKE_GEM_XXX.decode(self, r)
    self.type = r:readInt16Unsigned() -- { 宝石类型 }
    self.pearl_id = r:readInt16Unsigned() -- { 宝石ID(已镶嵌) }
end

-- [2739]强化属性信息块 -- 物品/打造/强化 
ACK_MAKE_PART_STREN_ATTR = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_PART_STREN_ATTR
    self:init()
end)

function ACK_MAKE_PART_STREN_ATTR.decode(self, r)
    self.type = r:readInt16Unsigned() -- { 类型 }
    self.value = r:readInt32Unsigned() -- { 属性值 }
end

-- [2778]装备分解成功返回 -- 物品/打造/强化 
ACK_MAKE_DECOMPOSE_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_DECOMPOSE_REPLY
    self:init()
end)

-- [2800]玄晶 -- 物品/打造/强化 
ACK_MAKE_XUANJING = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_XUANJING
    self:init()
end)

function ACK_MAKE_XUANJING.decode(self, r)
    self.xuanjing = r:readInt32Unsigned() -- { 玄晶剩余 }
end

-- [2805]部位强化成功 -- 物品/打造/强化 
ACK_MAKE_STREN_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_STREN_SUCCESS
    self:init()
end)

function ACK_MAKE_STREN_SUCCESS.decode(self, r)
    self.flag = r:readInt8Unsigned() -- { 1成功0失败 }
end

-- [2810]部位镶嵌宝石结果返回 -- 物品/打造/强化 
ACK_MAKE_PART_INSERT_FLAG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_PART_INSERT_FLAG
    self:init()
end)

function ACK_MAKE_PART_INSERT_FLAG.decode(self, r)
    self.flag = r:readInt8Unsigned() -- { 1成功0失败 }
end

-- [2815]部位升级宝石结果返回 -- 物品/打造/强化 
ACK_MAKE_PART_UP_FLAG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAKE_PART_UP_FLAG
    self:init()
end)

function ACK_MAKE_PART_UP_FLAG.decode(self, r)
    self.flag = r:readInt8Unsigned() -- { 1成功0失败 }
end

-- [3223]怪物信息块 -- 任务 
ACK_TASK_MONSTER_DETAIL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TASK_MONSTER_DETAIL
    self:init()
end)

function ACK_TASK_MONSTER_DETAIL.decode(self, r)
    self.monster_id = r:readInt16Unsigned() -- { 怪物ID }
    self.monster_nums = r:readInt8Unsigned() -- { 怪物数量 }
    self.monster_max = r:readInt8Unsigned() -- { 达成所需数量 }
end

-- [3225]任务剧情通知 -- 任务 
ACK_TASK_TASK_DRAMA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TASK_TASK_DRAMA
    self:init()
end)

function ACK_TASK_TASK_DRAMA.decode(self, r)
    self.drama_id = r:readInt16Unsigned() -- { 剧情id }
end

-- [3265]从列表中移除任务 -- 任务 
ACK_TASK_REMOVE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TASK_REMOVE
    self:init()
end)

function ACK_TASK_REMOVE.decode(self, r)
    self.id = r:readInt32Unsigned() -- { 任务id }
    self.reason = r:readInt8Unsigned() -- { 任务移除原因（1：完成|2：放弃|） }
end

-- [3528]副本评星信息块 -- 组队系统 
ACK_TEAM_MSG_EVA_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TEAM_MSG_EVA_XXX
    self:init()
end)

function ACK_TEAM_MSG_EVA_XXX.decode(self, r)
    self.copy_id = r:readInt16Unsigned() -- { 副本 }
    self.eva = r:readInt8Unsigned() -- { 星级 }
end

-- [3530]队伍信息块 -- 组队系统 
ACK_TEAM_REPLY_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TEAM_REPLY_MSG
    self:init()
end)

function ACK_TEAM_REPLY_MSG.decode(self, r)
    self.team_id = r:readInt32Unsigned() -- { 队伍ID }
    self.name = r:readString() -- { 姓名 }
    self.lv = r:readInt16Unsigned() -- { 等级 }
    self.pro = r:readInt8Unsigned() -- { 职业 }
    self.men = r:readInt16Unsigned() -- { 成员个数 }
end

-- [3574]队伍成员信息块(new) -- 组队系统 
ACK_TEAM_MEM_MSG_NEW = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TEAM_MEM_MSG_NEW
    self:init()
end)

function ACK_TEAM_MEM_MSG_NEW.decode(self, r)
    self.uid = r:readInt32() -- { 玩家uid }
    self.name = r:readString() -- { 玩家名字 }
    self.name_color = r:readInt8Unsigned() -- { 名字颜色 }
    self.lv = r:readInt16Unsigned() -- { 玩家等级 }
    self.pos = r:readInt8Unsigned() -- { 队伍成员显示位置 }
    self.power = r:readInt32Unsigned() -- { 队伍成员战斗力 }
    self.clan_name = r:readString() -- { 社团名字 }
    self.pro = r:readInt8Unsigned() -- { 队伍成员职业 }
    self.times = r:readInt16Unsigned() -- { 剩余次数 }
    self.skin_wuqi = r:readInt16Unsigned() -- { 武器皮肤 }
    self.skin_feather = r:readInt16Unsigned() -- { 神羽皮肤 }
    self.state = r:readInt8Unsigned() -- { 是否准备(1:已准备) }
end

-- [3620]离队通知 -- 组队系统 
ACK_TEAM_LEAVE_NOTICE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TEAM_LEAVE_NOTICE
    self:init()
end)

function ACK_TEAM_LEAVE_NOTICE.decode(self, r)
    self.reason = r:readInt8Unsigned() -- { 离队原因(CONST_TEAM_OUT_*) }
end

-- [3660]申请队长通知 -- 组队系统 
ACK_TEAM_APPLY_NOTICE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TEAM_APPLY_NOTICE
    self:init()
end)

function ACK_TEAM_APPLY_NOTICE.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 队员Uid }
    self.name = r:readString() -- { 队员名字 }
    self.name_color = r:readInt8Unsigned() -- { 队员姓名颜色 }
end

-- [3670]新队长通知 -- 组队系统 
ACK_TEAM_NEW_LEADER = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TEAM_NEW_LEADER
    self:init()
end)

-- [3690]邀请好友成功 -- 组队系统 
ACK_TEAM_INVITE_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TEAM_INVITE_SUCCESS
    self:init()
end)

-- [3700]好友邀请返回 -- 组队系统 
ACK_TEAM_INVITE_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TEAM_INVITE_BACK
    self:init()
end)

function ACK_TEAM_INVITE_BACK.decode(self, r)
    self.type = r:readInt32Unsigned() -- { 好友类型(CONST_TEAM_INVITE_*) }
    self.powerful = r:readInt32Unsigned() -- { 队长战力 }
    self.copy_id = r:readInt8Unsigned() -- { 副本id }
    self.team_id = r:readInt8Unsigned() -- { 队伍id }
    self.uname = r:readInt16Unsigned() -- { 玩家名字 }
end

-- [3730]查询队伍返回 -- 组队系统 
ACK_TEAM_LIVE_REP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TEAM_LIVE_REP
    self:init()
end)

function ACK_TEAM_LIVE_REP.decode(self, r)
    self.rep = r:readInt8Unsigned() -- { 是否存在 0:否 1:是 }
    self.type = r:readInt8Unsigned() -- { 类型 }
end

-- [3770]邀请好友返回 -- 组队系统 
ACK_TEAM_INVITE_NOTICE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TEAM_INVITE_NOTICE
    self:init()
end)

function ACK_TEAM_INVITE_NOTICE.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 类型 }
    self.uname = r:readString() -- { 玩家名字 }
    self.powerful = r:readInt32Unsigned() -- { 队长战力 }
    self.copy_id = r:readInt16Unsigned() -- { 副本id }
    self.team_id = r:readInt32Unsigned() -- { 队伍id }
end

-- [3800]购买成功 -- 组队系统 
ACK_TEAM_BUY_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TEAM_BUY_SUCCESS
    self:init()
end)

function ACK_TEAM_BUY_SUCCESS.decode(self, r)
    self.reward_times = r:readInt16Unsigned() -- { 剩余奖励次数 }
    self.buy_times = r:readInt8Unsigned() -- { 剩余购买次数 }
    self.rmb = r:readInt16Unsigned() -- { 购买所需元宝 }
end

-- [3830]玩家信息块 -- 组队系统 
ACK_TEAM_MSG_PLAYER = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TEAM_MSG_PLAYER
    self:init()
end)

function ACK_TEAM_MSG_PLAYER.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家UID }
    self.name = r:readString() -- { 玩家名字 }
    self.pro = r:readInt8Unsigned() -- { 玩家职业 }
    self.powerful = r:readInt32Unsigned() -- { 玩家战斗力 }
    self.lv = r:readInt16Unsigned() -- { 玩家等级 }
    self.state = r:readInt8Unsigned() -- { 是否已邀请(1已邀请，0未邀请) }
end

-- [3835]购买次数信息 -- 组队系统 
ACK_TEAM_BUY_INFO = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TEAM_BUY_INFO
    self:init()
end)

function ACK_TEAM_BUY_INFO.decode(self, r)
    self.times = r:readInt8Unsigned() -- { 剩余购买次数 }
    self.rmb = r:readInt8Unsigned() -- { 购买元宝数量 }
end

-- [4025]联系人信息块 -- 好友 
ACK_FRIEND_MSG_ROLE_XX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FRIEND_MSG_ROLE_XX
    self:init()
end)

function ACK_FRIEND_MSG_ROLE_XX.decode(self, r)
    self.id = r:readInt32Unsigned() -- { 人物id }
    self.name = r:readString() -- { 名字 }
    self.clan = r:readString() -- { 帮派名字 }
    self.lv = r:readInt16Unsigned() -- { 等级 }
    self.is_online = r:readInt8Unsigned() -- { 是否在线 }
    self.pro = r:readInt8Unsigned() -- { 职业 }
    self.powerful = r:readInt32Unsigned() -- { 战斗力 }
    self.is = r:readInt8Unsigned() -- { 1为是好友、已祝福、已领取、已添加 }
    self.is2 = r:readInt8Unsigned() -- { 1为已添加 }
end

-- [4040]好友删除成功 -- 好友 
ACK_FRIEND_DEL_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FRIEND_DEL_OK
    self:init()
end)

function ACK_FRIEND_DEL_OK.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
    self.type = r:readInt8Unsigned() -- { 类型 }
end

-- [4090]发送添加好友通知 -- 好友 
ACK_FRIEND_ADD_NOTICE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FRIEND_ADD_NOTICE
    self:init()
end)

function ACK_FRIEND_ADD_NOTICE.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
    self.name = r:readString() -- { 玩家名字 }
end

-- [4215]祝福好友成功 -- 好友 
ACK_FRIEND_BLESS_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FRIEND_BLESS_REPLY
    self:init()
end)

function ACK_FRIEND_BLESS_REPLY.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家UID }
end

-- [4217]祝福好友失败(让按钮变暗) -- 好友 
ACK_FRIEND_BLESS_FAIL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FRIEND_BLESS_FAIL
    self:init()
end)

function ACK_FRIEND_BLESS_FAIL.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 好友Uid }
end

-- [4235]领取好友祝福成功返回 -- 好友 
ACK_FRIEND_BLESS_GET_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FRIEND_BLESS_GET_REPLY
    self:init()
end)

function ACK_FRIEND_BLESS_GET_REPLY.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家Uid }
end

-- [4250]添加好友成功 -- 好友 
ACK_FRIEND_ADD_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FRIEND_ADD_SUCCESS
    self:init()
end)

function ACK_FRIEND_ADD_SUCCESS.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家Uid }
    self.type = r:readInt8Unsigned() -- { 添加好友类型 }
end

-- [4260]剩余次数 -- 好友 
ACK_FRIEND_REMAIN_TIMES = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FRIEND_REMAIN_TIMES
    self:init()
end)

function ACK_FRIEND_REMAIN_TIMES.decode(self, r)
    self.times = r:readInt16Unsigned() -- { 剩余次数 }
end

-- [4280]好友邀请返回信息块 -- 好友 
ACK_FRIEND_INVITE_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FRIEND_INVITE_MSG
    self:init()
end)

function ACK_FRIEND_INVITE_MSG.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家UID }
    self.name = r:readString() -- { 玩家名字 }
    self.lv = r:readInt16Unsigned() -- { 玩家等级 }
    self.powerful = r:readInt32Unsigned() -- { 玩家战斗力 }
    self.pro = r:readInt8Unsigned() -- { 玩家职业 }
end

-- [4290]次数返回 -- 好友 
ACK_FRIEND_TIMES_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FRIEND_TIMES_REPLY
    self:init()
end)

function ACK_FRIEND_TIMES_REPLY.decode(self, r)
    self.times1 = r:readInt8Unsigned() -- { 可祝福别人次数 }
    self.times2 = r:readInt8Unsigned() -- { 可以领取祝福次数 }
end

-- [5030]进入场景 -- 场景 
ACK_SCENE_ENTER_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_ENTER_OK
    self:init()
end)

function ACK_SCENE_ENTER_OK.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家UID }
    self.map_id = r:readInt32Unsigned() -- { 当前地图（非地图） }
    self.pos_x = r:readInt16Unsigned() -- { X坐标 }
    self.pos_y = r:readInt16Unsigned() -- { Y坐标 }
    self.speed = r:readInt16Unsigned() -- { 移动速度 }
    self.dir = r:readInt8Unsigned() -- { 方向 }
    self.distance = r:readInt16Unsigned() -- { 距离 }
    self.enter_type = r:readInt8Unsigned() -- { 类型（详情CONST_MAP_ENTER_*） }
    self.team_id = r:readInt32Unsigned() -- { 组队ID }
    self.hp_now = r:readInt32Unsigned() -- { 当前血量 }
    self.hp_max = r:readInt32Unsigned() -- { 最大血量 }
end

-- [5051]称号信息块 -- 场景 
ACK_SCENE_TITLE_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_TITLE_MSG
    self:init()
end)

function ACK_SCENE_TITLE_MSG.decode(self, r)
    self.title_id = r:readInt16Unsigned() -- { 称号ID }
end

-- [5053]神器信息块 -- 场景 
ACK_SCENE_MAGIC_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_MAGIC_MSG
    self:init()
end)

function ACK_SCENE_MAGIC_MSG.decode(self, r)
    self.magic_id = r:readInt16Unsigned() -- { 神器ID }
end

-- [5055]地图伙伴数据 -- 场景 
ACK_SCENE_PARTNER_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_PARTNER_DATA
    self:init()
end)

function ACK_SCENE_PARTNER_DATA.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.partner_id = r:readInt16Unsigned() -- { 伙伴ID }
    self.partner_idx = r:readInt16Unsigned() -- { 伙伴唯一ID }
    self.lv = r:readInt16Unsigned() -- { 等级 }
    self.team_id = r:readInt32Unsigned() -- { 队伍Id }
    self.hp_now = r:readInt32Unsigned() -- { 当前血量 }
    self.hp_max = r:readInt32Unsigned() -- { 最大血量 }
end

-- [5070]怪物数据(刷新) -- 场景 
ACK_SCENE_MONSTER_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_MONSTER_DATA
    self:init()
end)

function ACK_SCENE_MONSTER_DATA.decode(self, r)
    self.monster_mid = r:readInt32Unsigned() -- { 怪物MID }
    self.monster_id = r:readInt32Unsigned() -- { 怪物ID }
    self.pos_x = r:readInt16Unsigned() -- { X坐标 }
    self.pos_y = r:readInt16Unsigned() -- { Y坐标 }
    self.speed = r:readInt16Unsigned() -- { 速度 }
    self.dir = r:readInt8Unsigned() -- { 方向 }
    self.hp = r:readInt32Unsigned() -- { 当前HP }
    self.hp_max = r:readInt32Unsigned() -- { 最大HP }
end

-- [5075]怪物数据2(刷新) -- 场景 
ACK_SCENE_MONSTER_DATA2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_MONSTER_DATA2
    self:init()
end)

function ACK_SCENE_MONSTER_DATA2.decode(self, r)
    self.monster_mid = r:readInt32Unsigned() -- { 怪物MID }
    self.skin_id = r:readInt32Unsigned() -- { 皮肤ID }
    self.pos_x = r:readInt16Unsigned() -- { X坐标 }
    self.pos_y = r:readInt16Unsigned() -- { Y坐标 }
    self.speed = r:readInt8Unsigned() -- { 速度 }
    self.dir = r:readInt8Unsigned() -- { 方向 }
    self.hp = r:readInt32Unsigned() -- { 当前血量 }
    self.hp_max = r:readInt32Unsigned() -- { 最大血量 }
end

-- [5086]世界boss移动位置 -- 场景 
ACK_SCENE_WORLD_BOSS_POS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_WORLD_BOSS_POS
    self:init()
end)

function ACK_SCENE_WORLD_BOSS_POS.decode(self, r)
    self.m_id = r:readInt16Unsigned() -- { 怪物id }
    self.pos = r:readInt8Unsigned() -- { 1左2右 }
    self.hide = r:readInt8Unsigned() -- { 1出现2隐藏 }
end

-- [5090]行走数据(地图广播) -- 场景 
ACK_SCENE_MOVE_RECE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_MOVE_RECE
    self:init()
end)

function ACK_SCENE_MOVE_RECE.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 类型  玩家/怪物/宠物 }
    self.uid = r:readInt32Unsigned() -- { 玩家uid/怪物/宠物monster_mid 生成ID }
    self.move_type = r:readInt8Unsigned() -- { 移动方式,见CONST_MAP_MOVE_* }
    self.pos_x = r:readInt16Unsigned() -- { X坐标 }
    self.pos_y = r:readInt16Unsigned() -- { Y坐标 }
    self.dir = r:readInt8Unsigned() -- { 行走方向 }
    self.owner_uid = r:readInt32Unsigned() -- { 所属者Uid(当为伙伴时) }
    self.time = r:readInt32Unsigned() -- { 时间戳 }
end

-- [5100]强设玩家坐标 -- 场景 
ACK_SCENE_SET_PLAYER_XY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_SET_PLAYER_XY
    self:init()
end)

function ACK_SCENE_SET_PLAYER_XY.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.pos_x = r:readInt16Unsigned() -- { X坐标 }
    self.pos_y = r:readInt16Unsigned() -- { Y坐标 }
end

-- [5110]离开场景 -- 场景 
ACK_SCENE_OUT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_OUT
    self:init()
end)

function ACK_SCENE_OUT.decode(self, r)
    self.id_type = r:readInt8Unsigned() -- { 类型（1玩家，2伙伴，3怪物） }
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.out_type = r:readInt8Unsigned() -- { 离开类型（?CONST_MAP_OUT） }
    self.owner_uid = r:readInt32Unsigned() -- { 默认0 }
end

-- [5160]玩家可以复活 -- 场景 
ACK_SCENE_RELIVE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_RELIVE
    self:init()
end)

function ACK_SCENE_RELIVE.decode(self, r)
    self.rmb = r:readInt32Unsigned() -- { 复活需要的RMB }
end

-- [5180]玩家复活成功 -- 场景 
ACK_SCENE_RELIVE_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_RELIVE_OK
    self:init()
end)

-- [5190]玩家|伙伴血量更新 -- 场景 
ACK_SCENE_HP_UPDATE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_HP_UPDATE
    self:init()
end)

function ACK_SCENE_HP_UPDATE.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 详见：CONST_* }
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.partner_id = r:readInt32Unsigned() -- { 伙伴ID }
    self.stata = r:readInt8Unsigned() -- { 见常量?CONST_WAR_DISPLAY_ }
    self.hp_now = r:readInt32Unsigned() -- { 当前血量 }
    self.skill = r:readInt16Unsigned() -- { 技能ID }
end

-- [5310]物品掉落返回 -- 场景 
ACK_SCENE_GOODS_REPLY_NEW = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_GOODS_REPLY_NEW
    self:init()
end)

function ACK_SCENE_GOODS_REPLY_NEW.decode(self, r)
    self.pos_x = r:readInt16Unsigned() -- { X坐标 }
    self.pos_y = r:readInt16Unsigned() -- { Y坐标 }
    self.goods_id = r:readInt16Unsigned() -- { 物品ID }
    self.count = r:readInt16Unsigned() -- { 物品数量 }
end

-- [5340]加成属性(吃物品) -- 场景 
ACK_SCENE_UP_ATTR = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_UP_ATTR
    self:init()
end)

function ACK_SCENE_UP_ATTR.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 属性类型见常量 }
    self.value = r:readInt16Unsigned() -- { 加成万分比 }
end

-- [5350]帮派塔防倒计时 -- 场景 
ACK_SCENE_CLAN_DEF_TIME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_CLAN_DEF_TIME
    self:init()
end)

function ACK_SCENE_CLAN_DEF_TIME.decode(self, r)
    self.time = r:readInt16Unsigned() -- { 剩余时间（秒） }
end

-- [5360]下一波波次 -- 场景 
ACK_SCENE_NEXT_GATE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_NEXT_GATE
    self:init()
end)

function ACK_SCENE_NEXT_GATE.decode(self, r)
    self.boci = r:readInt8Unsigned() -- { 波次 }
    self.time = r:readInt8Unsigned() -- { 秒数 }
end

-- [5362]30秒后刷新下一层怪物 -- 场景 
ACK_SCENE_REFRESH_NEXT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_REFRESH_NEXT
    self:init()
end)

-- [5365]请选择正确的传送门进入下一层 -- 场景 
ACK_SCENE_CHOOSE_DOOR = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_CHOOSE_DOOR
    self:init()
end)

-- [5380]战斗状态返回 -- 场景 
ACK_SCENE_WAR_STATE_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_WAR_STATE_REPLY
    self:init()
end)

function ACK_SCENE_WAR_STATE_REPLY.decode(self, r)
    self.state = r:readInt8Unsigned() -- { 1自动战斗，2手动 }
end

-- [5600]玩家或守护复活(真元技能) -- 场景 
ACK_SCENE_WING_RELIVE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_WING_RELIVE
    self:init()
end)

function ACK_SCENE_WING_RELIVE.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 类型 玩家/守护 }
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
    self.partner_id = r:readInt16Unsigned() -- { 武将id }
    self.hp = r:readInt32Unsigned() -- { 恢复血量 }
end

-- [5610]恢复血量(真元技能) -- 场景 
ACK_SCENE_WING_HP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_WING_HP
    self:init()
end)

function ACK_SCENE_WING_HP.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 类型 玩家/守护 }
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
    self.partner_id = r:readInt16Unsigned() -- { 守护id }
    self.hp = r:readInt32Unsigned() -- { 恢复血量 }
end

-- [5630]切换场景前检查人物是否死亡 -- 场景 
ACK_SCENE_CHECK_DEATH = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_CHECK_DEATH
    self:init()
end)

function ACK_SCENE_CHECK_DEATH.decode(self, r)
    self.flag = r:readInt8Unsigned() -- { 1死亡0没死 }
end

-- [5705]技能信息块 -- 场景 
ACK_SCENE_MSG_SKILL_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_MSG_SKILL_XXX
    self:init()
end)

function ACK_SCENE_MSG_SKILL_XXX.decode(self, r)
    self.skill_id = r:readInt16Unsigned() -- { 技能ID }
    self.skill_lv = r:readInt16Unsigned() -- { 技能等级 }
end

-- [5920]场景广播-无敌 -- 场景 
ACK_SCENE_CHANGE_WUDI = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_CHANGE_WUDI
    self:init()
end)

function ACK_SCENE_CHANGE_WUDI.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
    self.state = r:readInt8Unsigned() -- { 状态(1无敌;0非无敌) }
end

-- [5921]场景广播-武器 -- 场景 
ACK_SCENE_CHANGE_WUQI = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_CHANGE_WUQI
    self:init()
end)

function ACK_SCENE_CHANGE_WUQI.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
    self.lv = r:readInt16Unsigned() -- { 武器等级 }
end

-- [5922]场景广播-神羽 -- 场景 
ACK_SCENE_CHANGE_FEATHER = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_CHANGE_FEATHER
    self:init()
end)

function ACK_SCENE_CHANGE_FEATHER.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.feather = r:readInt16Unsigned() -- { 神羽ID }
end

-- [5930]场景广播-帮派 -- 场景 
ACK_SCENE_CHANGE_CLAN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_CHANGE_CLAN
    self:init()
end)

function ACK_SCENE_CHANGE_CLAN.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.clan_id = r:readInt32Unsigned() -- { 帮派ID }
    self.clan_name = r:readString() -- { 帮派名字 }
end

-- [5940]场景广播-升级 -- 场景 
ACK_SCENE_LEVEL_UP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_LEVEL_UP
    self:init()
end)

function ACK_SCENE_LEVEL_UP.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.level = r:readInt16Unsigned() -- { 等级 }
end

-- [5950]场景广播-改变组队 -- 场景 
ACK_SCENE_CHANGE_TEAM = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_CHANGE_TEAM
    self:init()
end)

function ACK_SCENE_CHANGE_TEAM.decode(self, r)
    self.new_leader_uid = r:readInt32Unsigned() -- { 新队长ID }
    self.old_leader_uid = r:readInt32Unsigned() -- { 旧队长ID }
end

-- [5960]场景广播--改变坐骑 -- 场景 
ACK_SCENE_CHANGE_MOUNT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_CHANGE_MOUNT
    self:init()
end)

function ACK_SCENE_CHANGE_MOUNT.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.mount = r:readInt16Unsigned() -- { 坐骑ID }
    self.speed = r:readInt16Unsigned() -- { 速度 }
    self.mount_tx = r:readInt8Unsigned() -- { 0:无 1:特效一 2:特效二 }
    self.plies = r:readInt8Unsigned() -- { 等阶 }
end

-- [5965]场景广播--改变真元 -- 场景 
ACK_SCENE_WING = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_WING
    self:init()
end)

function ACK_SCENE_WING.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家id }
    self.wing = r:readInt16Unsigned() -- { 真元皮肤ID }
    self.plies = r:readInt8Unsigned() -- { 等阶 }
end

-- [5970]场景广播-改变战斗状态(is_war) -- 场景 
ACK_SCENE_CHANGE_STATE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_CHANGE_STATE
    self:init()
end)

function ACK_SCENE_CHANGE_STATE.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.state_new = r:readInt8Unsigned() -- { 新状态 }
end

-- [5980]场景广播-VIP -- 场景 
ACK_SCENE_CHANGE_VIP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_CHANGE_VIP
    self:init()
end)

function ACK_SCENE_CHANGE_VIP.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.vip_lv = r:readInt16Unsigned() -- { vip等级 }
end

-- [5994]场景广播-美人 -- 场景 
ACK_SCENE_CHANG_MEIREN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_CHANG_MEIREN
    self:init()
end)

function ACK_SCENE_CHANG_MEIREN.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.skin_id = r:readInt16Unsigned() -- { 美人皮肤ID }
end

-- [5996]场景广播-新手指导员 -- 场景 
ACK_SCENE_CHANG_GUIDE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_CHANG_GUIDE
    self:init()
end)

function ACK_SCENE_CHANG_GUIDE.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.is_guide = r:readInt8Unsigned() -- { 是否新手指导员(1是，0不是) }
end

-- [5997]场景广播-改名 -- 场景 
ACK_SCENE_CHANG_UNAME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_CHANG_UNAME
    self:init()
end)

function ACK_SCENE_CHANG_UNAME.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
    self.uname = r:readString() -- { 新名字 }
end

-- [5998]场景广播-幽灵 -- 场景 
ACK_SCENE_CHANGE_STATE_DIE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SCENE_CHANGE_STATE_DIE
    self:init()
end)

function ACK_SCENE_CHANGE_STATE_DIE.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
    self.state = r:readInt8Unsigned() -- { 状态0正常1幽灵 }
end

-- [6030]释放技能广播 -- 战斗 
ACK_WAR_SKILL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WAR_SKILL
    self:init()
end)

function ACK_WAR_SKILL.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 施放者类型 }
    self.uid = r:readInt32Unsigned() -- { 主角0 伙伴ID:玩家uid }
    self.id = r:readInt32Unsigned() -- { 施放者唯一id 玩家为0|伙伴为主人Uid }
    self.skill_id = r:readInt16Unsigned() -- { 技能id }
    self.dir = r:readInt8Unsigned() -- { 技能释放方向(1向右，2向左) }
    self.pos_x = r:readInt16Unsigned() -- { 位置X }
    self.pos_y = r:readInt16Unsigned() -- { 位置Y }
end

-- [6053]邀请PK返回 -- 战斗 
ACK_WAR_PK_REPLY_SELF = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WAR_PK_REPLY_SELF
    self:init()
end)

function ACK_WAR_PK_REPLY_SELF.decode(self, r)
    self.type = r:readInt16Unsigned() -- { 0正常其他为700错误代码 }
end

-- [6057]取消邀请返回 -- 战斗 
ACK_WAR_PK_CANCEL_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WAR_PK_CANCEL_REPLY
    self:init()
end)

function ACK_WAR_PK_CANCEL_REPLY.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 对方uid }
end

-- [6060]收到切磋请求 -- 战斗 
ACK_WAR_PK_RECEIVE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WAR_PK_RECEIVE
    self:init()
end)

function ACK_WAR_PK_RECEIVE.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 请求者Uid }
    self.name = r:readString() -- { 请求者名称 }
    self.time = r:readInt32Unsigned() -- { 邀请的时间戳 }
end

-- [6061]PK时间 -- 战斗 
ACK_WAR_PK_TIME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WAR_PK_TIME
    self:init()
end)

function ACK_WAR_PK_TIME.decode(self, r)
    self.endtime = r:readInt32Unsigned() -- { 准备时间倒计时 }
    self.endtime2 = r:readInt32Unsigned() -- { 结束时间戳 }
end

-- [6080]PK结束死亡广播 -- 战斗 
ACK_WAR_PK_LOSE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WAR_PK_LOSE
    self:init()
end)

function ACK_WAR_PK_LOSE.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 死亡者uid }
end

-- [6110]血量更新返回 -- 战斗 
ACK_WAR_HP_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WAR_HP_REPLY
    self:init()
end)

function ACK_WAR_HP_REPLY.decode(self, r)
    self.hp = r:readInt32Unsigned() -- { 当前血量 }
end

-- [6115]组队血量更新返回 -- 战斗 
ACK_WAR_HP_REPLY2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WAR_HP_REPLY2
    self:init()
end)

function ACK_WAR_HP_REPLY2.decode(self, r)
    self.hp = r:readInt32Unsigned() -- { 当前血量 }
end

-- [6205]PVP时间同步(返回) -- 战斗 
ACK_WAR_PVP_TIME_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WAR_PVP_TIME_BACK
    self:init()
end)

function ACK_WAR_PVP_TIME_BACK.decode(self, r)
    self.time = r:readInt32Unsigned() -- { 毫秒 }
end

-- [6215]PVP玩家状态信息(接收协议快) -- 战斗 
ACK_WAR_PVP_STATE_GROUP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WAR_PVP_STATE_GROUP
    self:init()
end)

function ACK_WAR_PVP_STATE_GROUP.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家UID }
    self.pos_x = r:readInt16Unsigned() -- { 玩家位置x }
    self.pos_y = r:readInt16Unsigned() -- { 玩家位置y }
    self.pos_z = r:readInt16Unsigned() -- { 玩家位置z }
    self.dir = r:readInt8Unsigned() -- { 玩家方向 }
    self.state = r:readInt8Unsigned() -- { 玩家状态 }
end

-- [6520]技能列表数据 -- 技能 
ACK_SKILL_LIST = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SKILL_LIST
    self:init()
end)

function ACK_SKILL_LIST.decode(self, r)
    self.power = r:readInt32Unsigned() -- { 战功 }
end

-- [6530]技能信息 -- 技能 
ACK_SKILL_INFO = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SKILL_INFO
    self:init()
end)

function ACK_SKILL_INFO.decode(self, r)
    self.skill_id = r:readInt16Unsigned() -- { 技能id }
    self.skill_lv = r:readInt16Unsigned() -- { 技能等级 }
end

-- [6545]装备技能信息 -- 技能 
ACK_SKILL_EQUIP_INFO = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SKILL_EQUIP_INFO
    self:init()
end)

function ACK_SKILL_EQUIP_INFO.decode(self, r)
    self.equip_pos = r:readInt16Unsigned() -- { 技能面板的位置（0位取消装备） }
    self.skill_id = r:readInt16Unsigned() -- { 技能id }
    self.skill_lv = r:readInt16Unsigned() -- { 技能等级 }
end

-- [6560]伙伴技能信息 -- 技能 
ACK_SKILL_PARENTINFO = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SKILL_PARENTINFO
    self:init()
end)

function ACK_SKILL_PARENTINFO.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
    self.parentid = r:readInt16Unsigned() -- { 伙伴id }
    self.skill_id = r:readInt16Unsigned() -- { 技能id }
    self.skill_lv = r:readInt16Unsigned() -- { 技能等级 }
end

-- [7010]章节信息 -- 副本 
ACK_COPY_CHAP_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_CHAP_DATA
    self:init()
end)

function ACK_COPY_CHAP_DATA.decode(self, r)
    self.chap_id = r:readInt16Unsigned() -- { 章节ID }
    self.star = r:readInt8Unsigned() -- { 总星星数 }
    self.state = r:readInt8Unsigned() -- { 1有可领取宝箱，0没有 }
end

-- [7025]副本是否开启返回 -- 副本 
ACK_COPY_COPY_OPEN_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_COPY_OPEN_REPLY
    self:init()
end)

function ACK_COPY_COPY_OPEN_REPLY.decode(self, r)
    self.flag = r:readInt8Unsigned() -- { 1已开启0未开启 }
    self.copy_id = r:readInt16Unsigned() -- { 最新开启CopyId }
end

-- [7026]单个副本信息块 -- 副本 
ACK_COPY_COPY_ONE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_COPY_ONE
    self:init()
end)

function ACK_COPY_COPY_ONE.decode(self, r)
    self.copy_id = r:readInt16Unsigned() -- { 副本ID }
    self.pass = r:readInt8Unsigned() -- { 是否通关(1已通过) }
end

-- [7032]验证通过 -- 副本 
ACK_COPY_THROUGH = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_THROUGH
    self:init()
end)

function ACK_COPY_THROUGH.decode(self, r)
    self.key = r:readString() -- { 验证通过key }
end

-- [7050]时间同步 -- 副本 
ACK_COPY_TIME_UPDATE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_TIME_UPDATE
    self:init()
end)

function ACK_COPY_TIME_UPDATE.decode(self, r)
    self.time = r:readInt32Unsigned() -- { 时间 }
end

-- [7060]场景时间同步(生存,限时类型),倒计时 -- 副本 
ACK_COPY_SCENE_TIME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_SCENE_TIME
    self:init()
end)

function ACK_COPY_SCENE_TIME.decode(self, r)
    self.time = r:readInt32Unsigned() -- { 时间 }
end

-- [7065]场景时间开始计时 -- 副本 
ACK_COPY_SCENE_TIME2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_SCENE_TIME2
    self:init()
end)

function ACK_COPY_SCENE_TIME2.decode(self, r)
    self.time = r:readInt32Unsigned() -- { 开始时间戳 }
end

-- [7080]已进入和完成次数返回 -- 副本 
ACK_COPY_IN_ALL_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_IN_ALL_REPLY
    self:init()
end)

function ACK_COPY_IN_ALL_REPLY.decode(self, r)
    self.times1 = r:readInt16Unsigned() -- { 精英已完成次数 }
    self.times_all1 = r:readInt16Unsigned() -- { 精英全部次数 }
    self.times2 = r:readInt16Unsigned() -- { 魔王已完成次数 }
    self.times_all2 = r:readInt16Unsigned() -- { 魔王全部次数 }
    self.times3 = r:readInt16Unsigned() -- { 珍宝副本已完成次数 }
    self.times_all3 = r:readInt16Unsigned() -- { 珍宝副本全部次数 }
end

-- [7110]挂机状态 -- 副本 
ACK_COPY_UP_STATE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_UP_STATE
    self:init()
end)

function ACK_COPY_UP_STATE.decode(self, r)
    self.state = r:readInt8Unsigned() -- { 0没有挂机1挂机中2挂机完成 }
end

-- [7120]妖王来袭通知 -- 副本 
ACK_COPY_BOSS_NOTICE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_BOSS_NOTICE
    self:init()
end)

-- [7130]功能开放状态 -- 副本 
ACK_COPY_STRONG_STATE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_STRONG_STATE
    self:init()
end)

function ACK_COPY_STRONG_STATE.decode(self, r)
    self.sub_id = r:readInt16Unsigned() -- { sub_id }
end

-- [7710]进入副本场景返回信息 -- 副本 
ACK_COPY_ENTER_SCENE_INFO = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_ENTER_SCENE_INFO
    self:init()
end)

function ACK_COPY_ENTER_SCENE_INFO.decode(self, r)
    self.copy_id = r:readInt16Unsigned() -- { 副本ID }
    self.scene_sum = r:readInt8Unsigned() -- { 场景总数 }
    self.scene_idx = r:readInt8Unsigned() -- { 场景索引 }
end

-- [7790]场景目标完成 -- 副本 
ACK_COPY_SCENE_OVER = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_SCENE_OVER
    self:init()
end)

-- [7805]副本物品信息块 -- 副本 
ACK_COPY_MSG_GOODS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_MSG_GOODS
    self:init()
end)

function ACK_COPY_MSG_GOODS.decode(self, r)
    self.goods_id = r:readInt16Unsigned() -- { 物品ID }
    self.goods_count = r:readInt16Unsigned() -- { 物品数量 }
end

-- [7810]副本失败 -- 副本 
ACK_COPY_FAIL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_FAIL
    self:init()
end)

-- [7830]退出副本成功 -- 副本 
ACK_COPY_EXIT_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_EXIT_OK
    self:init()
end)

-- [7860]挂机完成 -- 副本 
ACK_COPY_UP_OVER = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_UP_OVER
    self:init()
end)

function ACK_COPY_UP_OVER.decode(self, r)
    self.upcopy_id = r:readInt16Unsigned() -- { 挂机副本ID }
    self.type = r:readInt8Unsigned() -- { 挂机完成类型 }
end

-- [7877]领取挂机奖励返回 -- 副本 
ACK_COPY_UP_REWARD_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_UP_REWARD_REPLY
    self:init()
end)

-- [7890]查询章节奖励返回 -- 副本 
ACK_COPY_CHAP_RE_REP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_CHAP_RE_REP
    self:init()
end)

function ACK_COPY_CHAP_RE_REP.decode(self, r)
    self.chap_id = r:readInt16Unsigned() -- { 章节ID }
    self.star = r:readInt8Unsigned() -- { 星数量 }
    self.result = r:readInt8Unsigned() -- { 结果(1：已领取|0：没领取 }
end

-- [7910]物品掉落返回 -- 副本 
ACK_COPY_GOODS_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_GOODS_REPLY
    self:init()
end)

function ACK_COPY_GOODS_REPLY.decode(self, r)
    self.monster_mid = r:readInt32Unsigned() -- { 怪物MID }
    self.goods_id = r:readInt16Unsigned() -- { 物品Id }
end

-- [7930]怪物刷新 -- 副本 
ACK_COPY_MONSTER_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_MONSTER_DATA
    self:init()
end)

function ACK_COPY_MONSTER_DATA.decode(self, r)
    self.monster_mid = r:readInt32Unsigned() -- { 怪物MID }
    self.monster_id = r:readInt32Unsigned() -- { 怪物ID }
    self.pos_x = r:readInt16Unsigned() -- { X坐标 }
    self.pos_y = r:readInt16Unsigned() -- { Y坐标 }
    self.speed = r:readInt16Unsigned() -- { 速度 }
    self.dir = r:readInt8Unsigned() -- { 方向 }
    self.hp = r:readInt32Unsigned() -- { 当前HP }
    self.hp_max = r:readInt32Unsigned() -- { 最大HP }
end

-- [7950]章节信息块 -- 副本 
ACK_COPY_MSG_CHAP_ID = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_MSG_CHAP_ID
    self:init()
end)

function ACK_COPY_MSG_CHAP_ID.decode(self, r)
    self.chap_id = r:readInt16Unsigned() -- { 章节ID }
end

-- [7960]后端通知副本完成 -- 副本 
ACK_COPY_COPY_OVER_SERVER = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_COPY_OVER_SERVER
    self:init()
end)

-- [7980]技能信息块 -- 副本 
ACK_COPY_MSG_SKILLS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_MSG_SKILLS
    self:init()
end)

function ACK_COPY_MSG_SKILLS.decode(self, r)
    self.skill_id = r:readInt16Unsigned() -- { 技能Id }
end

-- [7995]翻牌物品信息块 -- 副本 
ACK_COPY_MSG_DRAW_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_MSG_DRAW_XXX
    self:init()
end)

function ACK_COPY_MSG_DRAW_XXX.decode(self, r)
    self.pos = r:readInt8Unsigned() -- { 翻牌位置 }
    self.goods_id = r:readInt16Unsigned() -- { 物品ID }
    self.count = r:readInt16Unsigned() -- { 物品数量 }
end

-- [7998]翻牌组队返回 -- 副本 
ACK_COPY_DRAW_TEAM_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_DRAW_TEAM_REPLY
    self:init()
end)

-- [8513]邮件模块 -- 邮件 
ACK_MAIL_MODEL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAIL_MODEL
    self:init()
end)

function ACK_MAIL_MODEL.decode(self, r)
    self.mail_id = r:readInt32Unsigned() -- { 邮件ID }
    self.mtype = r:readInt8Unsigned() -- { 邮件类型(系统:0|私人:1) }
    self.name = r:readString() -- { 名字 }
    self.title = r:readString() -- { 标题 }
    self.date = r:readInt32Unsigned() -- { 发送日期 }
    self.state = r:readInt8Unsigned() -- { 邮件状态(未读:0|已读:1) }
    self.pick = r:readInt8Unsigned() -- { 附件是否提取(无附件:0|未提取:1|已提取:2) }
end

-- [8532]发送邮件成功 -- 邮件 
ACK_MAIL_OK_SEND = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAIL_OK_SEND
    self:init()
end)

-- [8543]虚拟物品协议块 -- 邮件 
ACK_MAIL_VGOODS_MODEL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAIL_VGOODS_MODEL
    self:init()
end)

function ACK_MAIL_VGOODS_MODEL.decode(self, r)
    self.type1 = r:readInt8Unsigned() -- { 虚拟物品类型 }
    self.count = r:readInt32Unsigned() -- { 数量 }
end

-- [8563]删除邮件信息块 -- 邮件 
ACK_MAIL_IDLIST = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAIL_IDLIST
    self:init()
end)

function ACK_MAIL_IDLIST.decode(self, r)
    self.idlist = r:readInt32Unsigned() -- { 删除邮件信息块 }
end

-- [9020]防沉迷提示 -- 防沉迷 
ACK_FCM_PROMPT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FCM_PROMPT
    self:init()
end)

function ACK_FCM_PROMPT.decode(self, r)
    self.show = r:readBoolean() -- { 是否显示(true:显示;false:不显示) }
    self.state = r:readInt8Unsigned() -- { 防沉迷状态 0:正常 1:收益减半 2:收益为0 }
    self.time = r:readInt32Unsigned() -- { 上网时长(秒) }
end

-- [9518]聊天错误提示 -- 聊天 
ACK_CHAT_ERROR = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CHAT_ERROR
    self:init()
end)

function ACK_CHAT_ERROR.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 类型(const_chat_type) }
end

-- [9525]收到语音聊天 -- 聊天 
ACK_CHAT_RECE_YUYIN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CHAT_RECE_YUYIN
    self:init()
end)

function ACK_CHAT_RECE_YUYIN.decode(self, r)
    self.channel_id = r:readInt8Unsigned() -- { 频道类型 }
    self.team_id = r:readInt8Unsigned() -- { 类型(2组队3帮派) }
    self.p_uid = r:readInt32Unsigned() -- { 接受者玩家id }
    self.p_uname = r:readString() -- { 接受者玩家名字 }
    self.uid = r:readInt32Unsigned() -- { 发送者玩家id }
    self.uname = r:readString() -- { 发送者玩家名字 }
    self.time = r:readInt16Unsigned() -- { 语音长度 }
    self.url = r:readString() -- { url路径 }
    self.word = r:readString() -- { 语音内容 }
    self.is_guide = r:readInt8Unsigned() -- { 是否是新手指导员 }
    self.vip = r:readInt8Unsigned() -- { vip等级 }
end

-- [9527]玩家不在线 -- 聊天 
ACK_CHAT_OFFICE_PLAYER = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CHAT_OFFICE_PLAYER
    self:init()
end)

-- [10010]祝福成功 -- 祝福 
ACK_WISH_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WISH_SUCCESS
    self:init()
end)

function ACK_WISH_SUCCESS.decode(self, r)
    self.exp = r:readInt32Unsigned() -- { 经验 }
end

-- [10012]收到好友祝福 -- 祝福 
ACK_WISH_RECV = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WISH_RECV
    self:init()
end)

function ACK_WISH_RECV.decode(self, r)
    self.name = r:readString() -- { 名字 }
    self.exp = r:readInt32Unsigned() -- { 经验 }
end

-- [10022]领取祝福经验成功 -- 祝福 
ACK_WISH_EXP_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WISH_EXP_SUCCESS
    self:init()
end)

-- [10032]祝福经验信息返回 -- 祝福 
ACK_WISH_EXP_DATA_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WISH_EXP_DATA_BACK
    self:init()
end)

function ACK_WISH_EXP_DATA_BACK.decode(self, r)
    self.lv = r:readInt16Unsigned() -- { 领取等级 }
    self.exp = r:readInt32Unsigned() -- { 可领取经验 }
    self.bget = r:readInt8Unsigned() -- { 是否可以领取(1:可领取 0:不可以) }
end

-- [10040]好友升级提示 -- 祝福 
ACK_WISH_LV_UP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WISH_LV_UP
    self:init()
end)

function ACK_WISH_LV_UP.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 用户id }
    self.name = r:readString() -- { 姓名 }
    self.county = r:readInt8Unsigned() -- { 国家 }
    self.lv = r:readInt16Unsigned() -- { 等级 }
end

-- [10052]双倍信息返回 -- 祝福 
ACK_WISH_DOUBLE_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WISH_DOUBLE_DATA
    self:init()
end)

function ACK_WISH_DOUBLE_DATA.decode(self, r)
    self.cost_type = r:readInt16Unsigned() -- { 花费类型 }
    self.cost_value = r:readInt16Unsigned() -- { 花费值 }
    self.exp = r:readInt32Unsigned() -- { 可领取经验 }
end

-- [10740]称号信息块 -- 称号 
ACK_TITLE_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TITLE_MSG
    self:init()
end)

function ACK_TITLE_MSG.decode(self, r)
    self.tid = r:readInt16Unsigned() -- { 称号ID }
    self.state = r:readInt8Unsigned() -- { 状态（见CONST_TITLE_STATA） }
    self.type = r:readInt8Unsigned() -- { 1为永久，2为限时，3为实时 }
    self.new = r:readInt8Unsigned() -- { 是否为新称号（0旧/1新） }
    self.times = r:readInt32Unsigned() -- { 总共完成次数or其他 }
    self.times_max = r:readInt32Unsigned() -- { 最大次数 }
    self.end_time = r:readInt32Unsigned() -- { 结束时间 }
end

-- [10755]穿戴称号返回结果 -- 称号 
ACK_TITLE_DRESS_RES = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TITLE_DRESS_RES
    self:init()
end)

function ACK_TITLE_DRESS_RES.decode(self, r)
    self.result = r:readInt8Unsigned() -- { 0失败/1成攻 }
end

-- [10765]点击新称号返回 -- 称号 
ACK_TITLE_NEW_RES = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TITLE_NEW_RES
    self:init()
end)

function ACK_TITLE_NEW_RES.decode(self, r)
    self.result = r:readInt8Unsigned() -- { 0失败/1成攻 }
end

-- [10770]刷新面板 -- 称号 
ACK_TITLE_REFRESH = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TITLE_REFRESH
    self:init()
end)

-- [10825]BOSS信息块 -- 城镇BOSS 
ACK_CITY_BOSS_MSG_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CITY_BOSS_MSG_XXX
    self:init()
end)

function ACK_CITY_BOSS_MSG_XXX.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 唯一ID }
    self.state = r:readInt8Unsigned() -- { 刷新状态 }
end

-- [10920]激活成功 -- 真元 
ACK_WING_ACTIVATE_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WING_ACTIVATE_BACK
    self:init()
end)

-- [10950]真元信息块 -- 真元 
ACK_WING_XXX_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WING_XXX_DATA
    self:init()
end)

function ACK_WING_XXX_DATA.decode(self, r)
    self.wing_id = r:readInt16Unsigned() -- { 真元id }
    self.grade = r:readInt8Unsigned() -- { 等阶 }
    self.lv = r:readInt8Unsigned() -- { 等级 }
    self.exp = r:readInt16Unsigned() -- { 当前经验 }
    self.powerful = r:readInt32Unsigned() -- { 战力 }
end

-- [10990]佩戴|卸下成功 -- 真元 
ACK_WING_RIDE_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WING_RIDE_BACK
    self:init()
end)

function ACK_WING_RIDE_BACK.decode(self, r)
    self.wing_id = r:readInt16Unsigned() -- { 当前佩戴的真元id 0:无 }
end

-- [11000]技能信息块 -- 真元 
ACK_WING_XXXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WING_XXXX
    self:init()
end)

function ACK_WING_XXXX.decode(self, r)
    self.skill_id = r:readInt16Unsigned() -- { 已激活技能id }
end

-- [12120]骑乘|下骑成功 -- 坐骑 
ACK_MOUNT_RIDE_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MOUNT_RIDE_BACK
    self:init()
end)

function ACK_MOUNT_RIDE_BACK.decode(self, r)
    self.mount_id = r:readInt16Unsigned() -- { 当前骑乘的坐骑id 0:无 }
end

-- [12140]坐骑信息块 -- 坐骑 
ACK_MOUNT_XXX_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MOUNT_XXX_DATA
    self:init()
end)

function ACK_MOUNT_XXX_DATA.decode(self, r)
    self.mid = r:readInt16Unsigned() -- { 坐骑id }
    self.grade = r:readInt8Unsigned() -- { 阶数 }
    self.star = r:readInt8Unsigned() -- { 星级 }
    self.zf_value = r:readInt16Unsigned() -- { 祝福值 }
    self.powerful = r:readInt32Unsigned() -- { 战力 }
end

-- [12170]激活成功 -- 坐骑 
ACK_MOUNT_ACTIVATE_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MOUNT_ACTIVATE_BACK
    self:init()
end)

-- [12230]战报信息块 -- 封神榜 
ACK_EXPEDIT_LOGS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_EXPEDIT_LOGS
    self:init()
end)

function ACK_EXPEDIT_LOGS.decode(self, r)
    self.time = r:readInt32Unsigned() -- { 挑战时间戳 }
    self.uname = r:readString() -- { 对手的名字 }
    self.us_id = r:readInt16Unsigned() -- { 服务器id }
    self.result = r:readInt8Unsigned() -- { 战斗结果 0:失败 1:成功 }
    self.honor = r:readInt32Unsigned() -- { 获得荣誉值 }
end

-- [12242]对手信息 -- 封神榜 
ACK_EXPEDIT_PK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_EXPEDIT_PK
    self:init()
end)

function ACK_EXPEDIT_PK.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 对手uid }
    self.uname = r:readString() -- { 对手名字 }
    self.us_id = r:readInt16Unsigned() -- { 服务器id }
    self.lv = r:readInt16Unsigned() -- { 对手等级 }
    self.grade = r:readInt16Unsigned() -- { 对手军衔 }
    self.pk_num = r:readInt16Unsigned() -- { 总pk次数 }
    self.win_num = r:readInt16Unsigned() -- { 胜利次数 }
    self.pro = r:readInt8Unsigned() -- { 职业 }
    self.power = r:readInt32Unsigned() -- { 战斗力 }
end

-- [12252]结果返回 -- 封神榜 
ACK_EXPEDIT_FINISH_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_EXPEDIT_FINISH_MSG
    self:init()
end)

function ACK_EXPEDIT_FINISH_MSG.decode(self, r)
    self.result = r:readInt8Unsigned() -- { 0失败1成功 }
    self.get_honor = r:readInt32Unsigned() -- { 获得荣誉值 }
    self.id = r:readInt16Unsigned() -- { 神职id }
    self.up_need = r:readInt32Unsigned() -- { 差多少升级 }
end

-- [12262]加次数成功 -- 封神榜 
ACK_EXPEDIT_TIMES_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_EXPEDIT_TIMES_SUCCESS
    self:init()
end)

function ACK_EXPEDIT_TIMES_SUCCESS.decode(self, r)
    self.num = r:readInt16Unsigned() -- { 剩余战斗次数 }
end

-- [12275]对手信息(new) -- 封神榜 
ACK_EXPEDIT_PK_NEW = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_EXPEDIT_PK_NEW
    self:init()
end)

function ACK_EXPEDIT_PK_NEW.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 对手uid }
    self.uname = r:readString() -- { 对手名字 }
    self.us_id = r:readInt16Unsigned() -- { 服务器id }
    self.lv = r:readInt16Unsigned() -- { 对手等级 }
    self.grade = r:readInt16Unsigned() -- { 对手军衔 }
    self.pk_num = r:readInt16Unsigned() -- { 总pk次数 }
    self.win_num = r:readInt16Unsigned() -- { 胜利次数 }
    self.pro = r:readInt8Unsigned() -- { 职业 }
    self.power = r:readInt32Unsigned() -- { 战斗力 }
    self.lqid = r:readInt16Unsigned() -- { 灵器id }
    self.syid = r:readInt16Unsigned() -- { 神羽id }
end

-- [14015]选择阵营结果 -- 阵营 
ACK_COUNTRY_SELECT_RESULT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COUNTRY_SELECT_RESULT
    self:init()
end)

function ACK_COUNTRY_SELECT_RESULT.decode(self, r)
    self.country_id = r:readInt8Unsigned() -- { 阵营类型(见常量) }
end

-- [14027]改变阵营返回 -- 阵营 
ACK_COUNTRY_CHANGE_RESULT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COUNTRY_CHANGE_RESULT
    self:init()
end)

function ACK_COUNTRY_CHANGE_RESULT.decode(self, r)
    self.country_id_old = r:readInt8Unsigned() -- { 旧阵营类型(见常量) }
    self.country_id_new = r:readInt8Unsigned() -- { 新阵营类型(见常量) }
end

-- [14045]发布阵营公告返回(阵营广播) -- 阵营 
ACK_COUNTRY_PUBLISH_NOTICE_R = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COUNTRY_PUBLISH_NOTICE_R
    self:init()
end)

function ACK_COUNTRY_PUBLISH_NOTICE_R.decode(self, r)
    self.notice = r:readUTF() -- { 阵营公告文字 }
end

-- [14080]阵营职位改变消息通知(阵营广播) -- 阵营 
ACK_COUNTRY_POST_NOTICE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COUNTRY_POST_NOTICE
    self:init()
end)

function ACK_COUNTRY_POST_NOTICE.decode(self, r)
    self.type = r:readBoolean() -- { true : 任命 | false : 罢免(辞职) }
    self.post = r:readInt8Unsigned() -- { 职位类型(见常量) }
    self.uid = r:readInt32Unsigned() -- { uid }
    self.name = r:readString() -- { 名字 }
end

-- [16015]礼包领取次数 -- 节日活动 
ACK_FESTIVAL_PACKS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FESTIVAL_PACKS
    self:init()
end)

function ACK_FESTIVAL_PACKS.decode(self, r)
    self.pack_id = r:readInt16Unsigned() -- { 礼包id }
    self.times = r:readInt8Unsigned() -- { 已经使用次数 }
end

-- [16022]领取成功 -- 节日活动 
ACK_FESTIVAL_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FESTIVAL_OK
    self:init()
end)

function ACK_FESTIVAL_OK.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 礼包id }
end

-- [16032]购买成功 -- 节日活动 
ACK_FESTIVAL_OPEN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FESTIVAL_OPEN
    self:init()
end)

function ACK_FESTIVAL_OPEN.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 礼包id }
end

-- [16042]时间返送(旧) -- 节日活动 
ACK_FESTIVAL_GET_TIME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FESTIVAL_GET_TIME
    self:init()
end)

function ACK_FESTIVAL_GET_TIME.decode(self, r)
    self.open_type = r:readInt8Unsigned() -- { 开启状态（0：关闭） }
    self.start_date = r:readInt32Unsigned() -- { 开始时间 }
    self.end_date = r:readInt32Unsigned() -- { 结束时间 }
end

-- [16114]领取id对应剩余次数 -- 开服七天 
ACK_OPEN_MSG_TIMES = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_OPEN_MSG_TIMES
    self:init()
end)

function ACK_OPEN_MSG_TIMES.decode(self, r)
    self.id = r:readInt32Unsigned() -- { 领取id }
    self.state = r:readInt8Unsigned() -- { 自己领取情况1：不可领取2：可领取3：已领取 }
end

-- [16125]领取成功返回 -- 开服七天 
ACK_OPEN_OPEN_GET_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_OPEN_OPEN_GET_CB
    self:init()
end)

-- [16130]服务器次数 -- 开服七天 
ACK_OPEN_SERVER = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_OPEN_SERVER
    self:init()
end)

function ACK_OPEN_SERVER.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 领取id }
    self.times = r:readInt16Unsigned() -- { 服务器剩余次数 }
end

-- [16144]类型与上标次数 -- 开服七天 
ACK_OPEN_MSG_ALLLOGO = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_OPEN_MSG_ALLLOGO
    self:init()
end)

function ACK_OPEN_MSG_ALLLOGO.decode(self, r)
    self.day = r:readInt8Unsigned() -- { 第几天 }
    self.logo_times = r:readInt16Unsigned() -- { 上标次数 }
end

-- [16165]排行信息块 -- 开服七天 
ACK_OPEN_OPEN_RANK_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_OPEN_OPEN_RANK_MSG
    self:init()
end)

function ACK_OPEN_OPEN_RANK_MSG.decode(self, r)
    self.name = r:readString() -- { 名字 }
    self.lv = r:readInt16Unsigned() -- { 等级 }
    self.exp = r:readInt32Unsigned() -- { 经验 }
    self.mount = r:readInt32Unsigned() -- { 坐骑战斗力 }
    self.equip = r:readInt32Unsigned() -- { 装备战斗力 }
    self.baqi = r:readInt32Unsigned() -- { 霸气战斗力 }
    self.fighter = r:readInt32Unsigned() -- { 通关镇妖塔层数 }
    self.powerful = r:readInt32Unsigned() -- { 总战斗力 }
end

-- [16175]开服返回 -- 开服七天 
ACK_OPEN_DAY_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_OPEN_DAY_CB
    self:init()
end)

function ACK_OPEN_DAY_CB.decode(self, r)
    self.day = r:readInt8Unsigned() -- { 第几天 }
end

-- [16522]充值积分转盘 -- 积分转盘 
ACK_POINTS_WHEEL_FULL_REP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_POINTS_WHEEL_FULL_REP
    self:init()
end)

function ACK_POINTS_WHEEL_FULL_REP.decode(self, r)
    self.full_points = r:readInt16Unsigned() -- { 充值积分 }
end

-- [16532]消费积分转盘 -- 积分转盘 
ACK_POINTS_WHEEL_USE_REP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_POINTS_WHEEL_USE_REP
    self:init()
end)

function ACK_POINTS_WHEEL_USE_REP.decode(self, r)
    self.use_points = r:readInt16Unsigned() -- { 消费积分 }
end

-- [16542]充值转盘获得返回 -- 积分转盘 
ACK_POINTS_WHEEL_FULLREP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_POINTS_WHEEL_FULLREP
    self:init()
end)

function ACK_POINTS_WHEEL_FULLREP.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 唯一物品id }
end

-- [16552]消费转盘获得返回 -- 积分转盘 
ACK_POINTS_WHEEL_USEREP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_POINTS_WHEEL_USEREP
    self:init()
end)

function ACK_POINTS_WHEEL_USEREP.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 唯一物品id }
end

-- [16612]练功返回 -- 练功系统 
ACK_PRACTICE_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_PRACTICE_REPLY
    self:init()
end)

function ACK_PRACTICE_REPLY.decode(self, r)
    self.time_totel = r:readInt32Unsigned() -- { 练功时间(秒) }
    self.exp_totel = r:readInt32Unsigned() -- { 练功经验值 }
end

-- [16622]领取成功 -- 练功系统 
ACK_PRACTICE_COLLECT_REP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_PRACTICE_COLLECT_REP
    self:init()
end)

-- [16717]奖励物品信息快 -- 精彩活动 
ACK_ART_GOOD_INFO = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_GOOD_INFO
    self:init()
end)

function ACK_ART_GOOD_INFO.decode(self, r)
    self.id = r:readInt32Unsigned() -- { 物品id }
    self.num = r:readInt16Unsigned() -- { 数量 }
end

-- [16725]精彩活动节日奖励翻倍 -- 精彩活动 
ACK_ART_HOLIDAY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_HOLIDAY
    self:init()
end)

function ACK_ART_HOLIDAY.decode(self, r)
    self.value = r:readInt16Unsigned() -- { 值 }
end

-- [16742]领取成功返回 -- 精彩活动 
ACK_ART_SUCCESS_GET = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_SUCCESS_GET
    self:init()
end)

function ACK_ART_SUCCESS_GET.decode(self, r)
    self.id = r:readInt32Unsigned() -- { 活动ID }
    self.id_sub = r:readInt32Unsigned() -- { 阶段Id }
    self.state = r:readInt8Unsigned() -- { 状态 }
    self.num = r:readInt32Unsigned() -- { 以小博大的奖励数 }
end

-- [16755]信息块 -- 精彩活动 
ACK_ART_MSG_RANK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_MSG_RANK
    self:init()
end)

function ACK_ART_MSG_RANK.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
    self.name = r:readString() -- { 名字 }
    self.powerful = r:readInt32Unsigned() -- { 战斗力 }
    self.rank = r:readInt32Unsigned() -- { 竞技场排名 }
    self.rmb_charge = r:readInt32Unsigned() -- { 充值数量 }
    self.cost = r:readInt32Unsigned() -- { 消费数量 }
    self.id_sub = r:readInt32Unsigned() -- { 阶段id }
end

-- [16770]信息块 -- 精彩活动 
ACK_ART_ICON_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_ICON_MSG
    self:init()
end)

function ACK_ART_ICON_MSG.decode(self, r)
    self.id = r:readInt32Unsigned() -- { 活动Id }
    self.count = r:readInt8() -- { 数量 }
end

-- [16772]领取奖励成功 -- 精彩活动 
ACK_ART_REWARD_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_REWARD_OK
    self:init()
end)

function ACK_ART_REWARD_OK.decode(self, r)
    self.type = r:readInt16Unsigned() -- { 类型 }
end

-- [16785]福泽天下信息块2 -- 精彩活动 
ACK_ART_MSG2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_MSG2
    self:init()
end)

function ACK_ART_MSG2.decode(self, r)
    self.idx = r:readInt8Unsigned() -- { 唯一id }
    self.bool = r:readInt8Unsigned() -- { 是否可领取 }
    self.viplv = r:readInt8Unsigned() -- { vip等级 }
    self.times = r:readInt8Unsigned() -- { 可领取次数 }
end

-- [16793]福泽天下领取返回 -- 精彩活动 
ACK_ART_GET_FZTX_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_GET_FZTX_CB
    self:init()
end)

function ACK_ART_GET_FZTX_CB.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 活动id }
    self.idx = r:readInt8Unsigned() -- { 唯一id }
    self.times = r:readInt8Unsigned() -- { 剩余次数 }
end

-- [16796]充值信息块 -- 精彩活动 
ACK_ART_MSG_CHARGE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_MSG_CHARGE
    self:init()
end)

function ACK_ART_MSG_CHARGE.decode(self, r)
    self.rmb = r:readInt32Unsigned() -- { 金钱数量 }
    self.per = r:readInt16Unsigned() -- { 倍数(0:不显示) }
end

-- [16799]信息块1798 -- 精彩活动 
ACK_ART_ZHUANPAN_GOODMSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_ZHUANPAN_GOODMSG
    self:init()
end)

function ACK_ART_ZHUANPAN_GOODMSG.decode(self, r)
    self.idx = r:readInt8Unsigned() -- { 排序位置 }
    self.items_id = r:readInt32Unsigned() -- { 物品ID }
    self.value = r:readInt16Unsigned() -- { 物品值 }
end

-- [18025]属性块 -- 降魔之路 
ACK_XMZL_ATTR_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_XMZL_ATTR_XXX
    self:init()
end)

function ACK_XMZL_ATTR_XXX.decode(self, r)
    self.type = r:readInt16Unsigned() -- { 属性类型 }
    self.value = r:readInt16Unsigned() -- { 属性值 }
end

-- [18050]出战星宿返回 -- 降魔之路 
ACK_XMZL_WING_CHEER_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_XMZL_WING_CHEER_REPLY
    self:init()
end)

function ACK_XMZL_WING_CHEER_REPLY.decode(self, r)
    self.wing_id = r:readInt16Unsigned() -- { 星宿出战id }
end

-- [18060]属性重置成功 -- 降魔之路 
ACK_XMZL_ATTR_POINT_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_XMZL_ATTR_POINT_REPLY
    self:init()
end)

-- [18065]属性点更新 -- 降魔之路 
ACK_XMZL_ATTR_POINT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_XMZL_ATTR_POINT
    self:init()
end)

function ACK_XMZL_ATTR_POINT.decode(self, r)
    self.point = r:readInt16Unsigned() -- { 属性点数 }
    self.point_all = r:readInt16Unsigned() -- { 属性总点数 }
end

-- [18075]副本信息块 -- 降魔之路 
ACK_XMZL_COPY_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_XMZL_COPY_XXX
    self:init()
end)

function ACK_XMZL_COPY_XXX.decode(self, r)
    self.copy_id = r:readInt16Unsigned() -- { 副本ID }
end

-- [18125]领取成功 -- 荣誉 
ACK_HONOR_REWARD_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HONOR_REWARD_OK
    self:init()
end)

-- [21120]进入场景 -- 活动-保卫经书 
ACK_DEFEND_BOOK_INTER_SCENE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_INTER_SCENE
    self:init()
end)

function ACK_DEFEND_BOOK_INTER_SCENE.decode(self, r)
    self.start_time = r:readInt32Unsigned() -- { 开始时间 }
    self.end_time = r:readInt32Unsigned() -- { 结束时间 }
    self.map_id = r:readInt16Unsigned() -- { 地图ID }
    self.uid = r:readInt32Unsigned() -- { 玩家Uid }
    self.sid = r:readInt8Unsigned() -- { 服务器ID }
    self.entertype = r:readInt8Unsigned() -- { 类型 1:普通 2:副本 3:瞬移 4:校正 }
end

-- [21122]倒计时 -- 活动-保卫经书 
ACK_DEFEND_BOOK_TIME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_TIME
    self:init()
end)

function ACK_DEFEND_BOOK_TIME.decode(self, r)
    self.time_value = r:readInt16Unsigned() -- { 当前倒计时秒数 }
end

-- [21136]怪物数据组 -- 活动-保卫经书 
ACK_DEFEND_BOOK_MONSTER = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_MONSTER
    self:init()
end)

function ACK_DEFEND_BOOK_MONSTER.decode(self, r)
    self.gmid = r:readInt32Unsigned() -- { 怪物编号ID }
    self.mid = r:readInt16Unsigned() -- { 怪物id }
    self.pos_x = r:readInt8Unsigned() -- { X轴格位 }
    self.pos_y = r:readInt8Unsigned() -- { Y轴格位 }
    self.mhp = r:readInt32Unsigned() -- { 怪物当前血量 }
    self.allmhp = r:readInt32Unsigned() -- { 怪物总血量 }
end

-- [21137]怪物数据刷新 -- 活动-保卫经书 
ACK_DEFEND_BOOK_MONSTER_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_MONSTER_DATA
    self:init()
end)

function ACK_DEFEND_BOOK_MONSTER_DATA.decode(self, r)
    self.gmid = r:readInt32Unsigned() -- { 怪物组生成ID }
    self.mhp = r:readInt32Unsigned() -- { 怪物当前血量 }
    self.allmhp = r:readInt32Unsigned() -- { 怪物总血量 }
end

-- [21140]玩家对怪伤害值 -- 活动-保卫经书 
ACK_DEFEND_BOOK_SELF_HARM = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_SELF_HARM
    self:init()
end)

function ACK_DEFEND_BOOK_SELF_HARM.decode(self, r)
    self.harm = r:readInt32Unsigned() -- { 玩家对怪伤害值 }
end

-- [21150]排行榜数据 -- 活动-保卫经书 
ACK_DEFEND_BOOK_RANK_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_RANK_DATA
    self:init()
end)

function ACK_DEFEND_BOOK_RANK_DATA.decode(self, r)
    self.sid = r:readInt8Unsigned() -- { 服务器ID }
    self.uid = r:readInt32Unsigned() -- { 玩家Uid }
    self.name = r:readString() -- { 玩家名字 }
    self.harm_hp = r:readInt32Unsigned() -- { 伤害血量 }
end

-- [21160]阵营积分数据 -- 活动-保卫经书 
ACK_DEFEND_BOOK_CAMP_INTEGRAL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_CAMP_INTEGRAL
    self:init()
end)

function ACK_DEFEND_BOOK_CAMP_INTEGRAL.decode(self, r)
    self.camp_human = r:readInt16Unsigned() -- { 阵营积分--人 }
    self.camp_god = r:readInt16Unsigned() -- { 阵营积分--仙 }
    self.camp_devil = r:readInt16Unsigned() -- { 阵营积分--魔 }
end

-- [21165]阵营积分数据_新 -- 活动-保卫经书 
ACK_DEFEND_BOOK_CAMP_INTEGRAL_N = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_CAMP_INTEGRAL_N
    self:init()
end)

function ACK_DEFEND_BOOK_CAMP_INTEGRAL_N.decode(self, r)
    self.camp_human = r:readInt32Unsigned() -- { 阵营积分--人 }
    self.camp_god = r:readInt32Unsigned() -- { 阵营积分--仙 }
    self.camp_devil = r:readInt32Unsigned() -- { 阵营积分--魔 }
end

-- [21180]战壕玩家信息块 -- 活动-保卫经书 
ACK_DEFEND_BOOK_DATE_TRENCH = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_DATE_TRENCH
    self:init()
end)

function ACK_DEFEND_BOOK_DATE_TRENCH.decode(self, r)
    self.sid = r:readInt16Unsigned() -- { 服务器ID }
    self.uid = r:readInt32Unsigned() -- { 玩家UID }
    self.name = r:readString() -- { 角色名 }
    self.name_color = r:readInt16Unsigned() -- { 角色名颜色 }
    self.lv = r:readInt16Unsigned() -- { 等级 }
    self.sex = r:readInt8Unsigned() -- { 性别 }
    self.pro = r:readInt8Unsigned() -- { 职业 }
end

-- [21200]请求战壕结果 -- 活动-保卫经书 
ACK_DEFEND_BOOK_OK_TRENCH = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_OK_TRENCH
    self:init()
end)

function ACK_DEFEND_BOOK_OK_TRENCH.decode(self, r)
    self.num = r:readInt8Unsigned() -- { 战壕编号：1-9 }
    self.count = r:readInt16Unsigned() -- { 已更换战壕次数 }
    self.rmb = r:readInt8Unsigned() -- { 下次更换战壕需消耗的金元数 }
end

-- [21220]战斗结果返回 -- 活动-保卫经书 
ACK_DEFEND_BOOK_WAR_RETRUN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_WAR_RETRUN
    self:init()
end)

function ACK_DEFEND_BOOK_WAR_RETRUN.decode(self, r)
    self.gmid = r:readInt32Unsigned() -- { 被攻击的怪物 Id }
    self.harm = r:readInt32Unsigned() -- { 伤害量 }
end

-- [21223]战斗怪物更新 -- 活动-保卫经书 
ACK_DEFEND_BOOK_WAR_MONSTERS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_WAR_MONSTERS
    self:init()
end)

function ACK_DEFEND_BOOK_WAR_MONSTERS.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 击杀类型 见常量CONST_DEFEND_BOOK_KILL_TYPE }
    self.gmid = r:readInt32Unsigned() -- { 被击杀的怪物Id }
    self.time = r:readInt8Unsigned() -- { 下一波怪物刷新时间 }
end

-- [21225]玩家死亡 -- 活动-保卫经书 
ACK_DEFEND_BOOK_KILL_PLAYERS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_KILL_PLAYERS
    self:init()
end)

function ACK_DEFEND_BOOK_KILL_PLAYERS.decode(self, r)
    self.num = r:readInt16Unsigned() -- { 元宝复活次数 }
    self.rmb = r:readInt8Unsigned() -- { 玩家复活需消耗的元宝数 }
    self.time = r:readInt8Unsigned() -- { 复活CD }
end

-- [21232]拾取击杀奖励 -- 活动-保卫经书 
ACK_DEFEND_BOOK_OK_GET_REWARDS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_OK_GET_REWARDS
    self:init()
end)

function ACK_DEFEND_BOOK_OK_GET_REWARDS.decode(self, r)
    self.gmid = r:readInt32Unsigned() -- { 被击杀的怪物生成Id }
end

-- [21250]复活成功 -- 活动-保卫经书 
ACK_DEFEND_BOOK_OK_REVIVE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFEND_BOOK_OK_REVIVE
    self:init()
end)

-- [22130]浮屠静修单层信息块 -- 浮屠静修 
ACK_FUTU_MSG2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FUTU_MSG2
    self:init()
end)

function ACK_FUTU_MSG2.decode(self, r)
    self.pos = r:readInt8Unsigned() -- { 位置 }
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.pro = r:readInt8Unsigned() -- { 职业 }
    self.name = r:readString() -- { 名字 }
end

-- [22140]购买次数返回 -- 浮屠静修 
ACK_FUTU_TIMES_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FUTU_TIMES_REPLY
    self:init()
end)

function ACK_FUTU_TIMES_REPLY.decode(self, r)
    self.times = r:readInt16Unsigned() -- { 剩余挑战次数 }
    self.buy_time = r:readInt8Unsigned() -- { 剩余购买次数 }
end

-- [22156]奖励物品信息块 -- 浮屠静修 
ACK_FUTU_HISTORY_MSG2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FUTU_HISTORY_MSG2
    self:init()
end)

function ACK_FUTU_HISTORY_MSG2.decode(self, r)
    self.good_id = r:readInt16Unsigned() -- { 物品ID }
    self.good_num = r:readInt16Unsigned() -- { 物品数量 }
end

-- [22165]查看玩家返回 -- 浮屠静修 
ACK_FUTU_PLAYER_REP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FUTU_PLAYER_REP
    self:init()
end)

function ACK_FUTU_PLAYER_REP.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.name = r:readString() -- { 玩家名字 }
    self.pro = r:readInt8Unsigned() -- { 职业 }
    self.powerful = r:readInt32Unsigned() -- { 玩家战斗力 }
    self.clan_name = r:readString() -- { 帮派名字 }
    self.time = r:readInt32Unsigned() -- { 玩家开始占领的时间 }
    self.floor = r:readInt8Unsigned() -- { 层数 }
    self.pos = r:readInt8Unsigned() -- { 位置 }
end

-- [22175]离开据点成功 -- 浮屠静修 
ACK_FUTU_OUT_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FUTU_OUT_SUCCESS
    self:init()
end)

-- [22190]浮屠静修挑战结束返回 -- 浮屠静修 
ACK_FUTU_OVER_REP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FUTU_OVER_REP
    self:init()
end)

function ACK_FUTU_OVER_REP.decode(self, r)
    self.result = r:readInt8Unsigned() -- { 1成功/0失败 }
end

-- [22195]浮屠静修剩余占领时间 -- 浮屠静修 
ACK_FUTU_LEFT_TIME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FUTU_LEFT_TIME
    self:init()
end)

function ACK_FUTU_LEFT_TIME.decode(self, r)
    self.time = r:readInt32Unsigned() -- { 开始占领时间戳 }
    self.time2 = r:readInt32Unsigned() -- { 已占领时间长度 }
end

-- [22215]已领取奖励 -- 每天消费 
ACK_COST_USE_ID = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COST_USE_ID
    self:init()
end)

function ACK_COST_USE_ID.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 领过id }
end

-- [22222]成功 -- 每天消费 
ACK_COST_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COST_SUCCESS
    self:init()
end)

-- [22312]信息块(id) -- 节日转盘 
ACK_GALATURN_MSG_ID = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GALATURN_MSG_ID
    self:init()
end)

function ACK_GALATURN_MSG_ID.decode(self, r)
    self.id = r:readInt32Unsigned() -- { 活动Id }
    self.start_time = r:readInt32Unsigned() -- { 开始时间 }
    self.end_time = r:readInt32Unsigned() -- { 结束时间 }
end

-- [22315]转盘物品信息 -- 节日转盘 
ACK_GALATURN_MSG_TURN_GOOD = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GALATURN_MSG_TURN_GOOD
    self:init()
end)

function ACK_GALATURN_MSG_TURN_GOOD.decode(self, r)
    self.idx = r:readInt8Unsigned() -- { 位置 }
    self.items_id = r:readInt32Unsigned() -- { 物品id }
    self.value = r:readInt16Unsigned() -- { 数量 }
end

-- [22322]抽奖成功 -- 节日转盘 
ACK_GALATURN_LOT_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GALATURN_LOT_SUCCESS
    self:init()
end)

function ACK_GALATURN_LOT_SUCCESS.decode(self, r)
    self.id_sub = r:readInt16Unsigned() -- { 唯一id }
    self.type = r:readInt8Unsigned() -- { 抽奖类型(0:1次,1:多次) }
    self.id = r:readInt32Unsigned() -- { 活动Id }
end

-- [22335]排名信息块 -- 节日转盘 
ACK_GALATURN_RANK_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GALATURN_RANK_MSG
    self:init()
end)

function ACK_GALATURN_RANK_MSG.decode(self, r)
    self.name = r:readString() -- { 玩家名 }
    self.point = r:readInt32Unsigned() -- { 积分 }
end

-- [22338]排行物品信息快 -- 节日转盘 
ACK_GALATURN_MSG_RANK2_GOOD = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GALATURN_MSG_RANK2_GOOD
    self:init()
end)

function ACK_GALATURN_MSG_RANK2_GOOD.decode(self, r)
    self.good_id = r:readInt32Unsigned() -- { 物品id }
    self.count = r:readInt16Unsigned() -- { 数量 }
end

-- [22345]已领奖id -- 节日转盘 
ACK_GALATURN_GET_ID = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GALATURN_GET_ID
    self:init()
end)

function ACK_GALATURN_GET_ID.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 唯一id }
end

-- [22352]领奖成功 -- 节日转盘 
ACK_GALATURN_POI_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GALATURN_POI_SUCCESS
    self:init()
end)

function ACK_GALATURN_POI_SUCCESS.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 领取id }
end

-- [22360]活动角标信息块 -- 节日转盘 
ACK_GALATURN_MSG_ICON = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GALATURN_MSG_ICON
    self:init()
end)

function ACK_GALATURN_MSG_ICON.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 活动Id }
    self.times = r:readInt8Unsigned() -- { 次数 }
end

-- [22770]信息组协议块 -- 日志 
ACK_GAME_LOGS_MESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GAME_LOGS_MESS
    self:init()
end)

function ACK_GAME_LOGS_MESS.decode(self, r)
    self.states = r:readInt8Unsigned() -- { 状态[得|失 增|减] }
    self.id = r:readInt32Unsigned() -- { 具体事件 }
    self.value = r:readInt32Unsigned() -- { 数量 }
end

-- [22781]字符串信息块 -- 日志 
ACK_GAME_LOGS_STR_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GAME_LOGS_STR_XXX
    self:init()
end)

function ACK_GAME_LOGS_STR_XXX.decode(self, r)
    self.type1 = r:readString() -- { 字符串 }
    self.colour = r:readInt16Unsigned() -- {  }
end

-- [22782]数字信息块 -- 日志 
ACK_GAME_LOGS_INT_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GAME_LOGS_INT_XXX
    self:init()
end)

function ACK_GAME_LOGS_INT_XXX.decode(self, r)
    self.type2 = r:readInt32Unsigned() -- { 数据 }
end

-- [22825]技能信息块 -- 宠物 
ACK_PET_SKILLS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_PET_SKILLS
    self:init()
end)

function ACK_PET_SKILLS.decode(self, r)
    self.skill_id = r:readInt16Unsigned() -- { 技能id }
end

-- [22827]皮肤信息块 -- 宠物 
ACK_PET_SKINS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_PET_SKINS
    self:init()
end)

function ACK_PET_SKINS.decode(self, r)
    self.skin_id = r:readInt16Unsigned() -- { 皮肤id }
end

-- [22860]召唤式神成功返回 -- 宠物 
ACK_PET_CALL_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_PET_CALL_OK
    self:init()
end)

-- [22875]修炼需要钻石返回 -- 宠物 
ACK_PET_NEED_RMB_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_PET_NEED_RMB_REPLY
    self:init()
end)

function ACK_PET_NEED_RMB_REPLY.decode(self, r)
    self.rmb = r:readInt16Unsigned() -- { 钻石数 }
end

-- [22885]魔宠修炼成功返回 -- 宠物 
ACK_PET_XIULIAN_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_PET_XIULIAN_OK
    self:init()
end)

-- [22950]幻化成功返回 -- 宠物 
ACK_PET_HUANHUA_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_PET_HUANHUA_REPLY
    self:init()
end)

function ACK_PET_HUANHUA_REPLY.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 类型 }
end

-- [23112]探宝返回 -- 活动-地下皇陵 
ACK_TOMB_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TOMB_REPLY
    self:init()
end)

function ACK_TOMB_REPLY.decode(self, r)
    self.times = r:readInt16Unsigned() -- { 剩余总次数 }
    self.freetimes = r:readInt16Unsigned() -- { 免费次数 }
end

-- [23122]获得返回 -- 活动-地下皇陵 
ACK_TOMB_DIG_REP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TOMB_DIG_REP
    self:init()
end)

function ACK_TOMB_DIG_REP.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 唯一id }
    self.times = r:readInt16Unsigned() -- { 剩余次数 }
end

-- [23215]寻宝历史信息块返回(旧) -- 活动-全民寻宝 
ACK_ALLFIND_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ALLFIND_MSG
    self:init()
end)

function ACK_ALLFIND_MSG.decode(self, r)
    self.name = r:readString() -- { 玩家名 }
    self.id = r:readInt16Unsigned() -- { 物品唯一id }
end

-- [23218]次数信息块(新) -- 活动-全民寻宝 
ACK_ALLFIND_MSG2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ALLFIND_MSG2
    self:init()
end)

function ACK_ALLFIND_MSG2.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 寻宝类型CONST_ALLFIND_ }
    self.times = r:readInt16Unsigned() -- { 免费次数 }
end

-- [23222]寻宝返回 -- 活动-全民寻宝 
ACK_ALLFIND_DIG_REP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ALLFIND_DIG_REP
    self:init()
end)

function ACK_ALLFIND_DIG_REP.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 物品唯一id }
    self.type = r:readInt16Unsigned() -- { 抽奖类型CONST_ALLFIND_ }
end

-- [23232]购买成功 -- 活动-全民寻宝 
ACK_ALLFIND_SHOP_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ALLFIND_SHOP_SUCCESS
    self:init()
end)

-- [23245]历史信息块(新) -- 活动-全民寻宝 
ACK_ALLFIND_MSG1 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ALLFIND_MSG1
    self:init()
end)

function ACK_ALLFIND_MSG1.decode(self, r)
    self.name = r:readString() -- { 玩家名 }
    self.id = r:readInt16Unsigned() -- { 物品唯一id }
    self.type = r:readInt8Unsigned() -- { 寻宝类型CONST_ALLFIND_ }
end

-- [23312]在线领奖返回 -- 奖励 
ACK_REWARD_ONLINE_REP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_ONLINE_REP
    self:init()
end)

function ACK_REWARD_ONLINE_REP.decode(self, r)
    self.time = r:readInt32Unsigned() -- { 下次领取时间秒数 }
    self.id = r:readInt8Unsigned() -- { 领取类型 }
end

-- [23325]等级奖励信息块 -- 奖励 
ACK_REWARD_LV_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_LV_MSG
    self:init()
end)

function ACK_REWARD_LV_MSG.decode(self, r)
    self.lv = r:readInt16Unsigned() -- { 领取等级 }
end

-- [23335]每日领奖信息块 -- 奖励 
ACK_REWARD_DAILY_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_DAILY_MSG
    self:init()
end)

function ACK_REWARD_DAILY_MSG.decode(self, r)
    self.day = r:readInt16Unsigned() -- { 领取过的日子 }
end

-- [23505]vip奖励信息块2 -- 奖励 
ACK_REWARD_VIP_MSG_XXX2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_VIP_MSG_XXX2
    self:init()
end)

function ACK_REWARD_VIP_MSG_XXX2.decode(self, r)
    self.id = r:readInt32Unsigned() -- { 物品 }
    self.count = r:readInt16Unsigned() -- { 物品数量 }
end

-- [23545]领取vip奖励返回 -- 奖励 
ACK_REWARD_VIP_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_VIP_REPLY
    self:init()
end)

-- [23600]怀孕奖励刷新 -- 奖励 
ACK_REWARD_PREGNANCY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_PREGNANCY
    self:init()
end)

-- [23615]角标返回 -- 奖励 
ACK_REWARD_ICON_TIME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_ICON_TIME
    self:init()
end)

function ACK_REWARD_ICON_TIME.decode(self, r)
    self.num1 = r:readInt8Unsigned() -- { 在线 }
    self.num2 = r:readInt8Unsigned() -- { 签到 }
    self.num3 = r:readInt8Unsigned() -- { 体力 }
end

-- [23620]vip等级和总数 -- 奖励 
ACK_REWARD_VIP_LV_RMB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_VIP_LV_RMB
    self:init()
end)

function ACK_REWARD_VIP_LV_RMB.decode(self, r)
    self.lv = r:readInt16Unsigned() -- { vip等级 }
    self.rmb = r:readInt32Unsigned() -- { 总数 }
end

-- [23635]充值金额信息块 -- 奖励 
ACK_REWARD_MSG_LOGS_PAY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_MSG_LOGS_PAY
    self:init()
end)

function ACK_REWARD_MSG_LOGS_PAY.decode(self, r)
    self.rmb = r:readInt16Unsigned() -- { 元宝数 }
end

-- [23645]领取奖励成功 -- 奖励 
ACK_REWARD_LOGIN_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_LOGIN_SUCCESS
    self:init()
end)

-- [23670]物品信息块 -- 奖励 
ACK_REWARD_LOGIN_MSG_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_LOGIN_MSG_XXX
    self:init()
end)

function ACK_REWARD_LOGIN_MSG_XXX.decode(self, r)
    self.goods_id = r:readInt16Unsigned() -- { 物品ID }
    self.count = r:readInt16Unsigned() -- { 数量 }
end

-- [23680]主界面签到 -- 奖励 
ACK_REWARD_MAIN_LOGIN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_MAIN_LOGIN
    self:init()
end)

function ACK_REWARD_MAIN_LOGIN.decode(self, r)
    self.day = r:readInt8Unsigned() -- { 第几天 }
    self.good_id = r:readInt32Unsigned() -- { 物品id }
    self.count = r:readInt16Unsigned() -- { 数量 }
    self.state = r:readInt8Unsigned() -- { 1不可领取，2可领取 }
end

-- [23821]可以挑战的玩家 -- 竞技场 
ACK_ARENA_CANBECHALLAGE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ARENA_CANBECHALLAGE
    self:init()
end)

function ACK_ARENA_CANBECHALLAGE.decode(self, r)
    self.sid = r:readInt16Unsigned() -- { 服务器ID }
    self.pro = r:readInt8Unsigned() -- { 玩家职业 }
    self.sex = r:readInt8Unsigned() -- { 玩家性别 }
    self.lv = r:readInt16Unsigned() -- { 玩家等级 }
    self.uid = r:readInt32Unsigned() -- { 玩家UID }
    self.name = r:readUTF() -- { 玩家名字 }
    self.ranking = r:readInt16Unsigned() -- { 玩家排名 }
    self.win_count = r:readInt8Unsigned() -- { 连胜次数 }
    self.surplus = r:readInt8Unsigned() -- { 剩余挑战次数 }
    self.power = r:readInt32Unsigned() -- { 战斗力 }
end

-- [23829]验证通过 -- 竞技场 
ACK_ARENA_THROUGH = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ARENA_THROUGH
    self:init()
end)

function ACK_ARENA_THROUGH.decode(self, r)
    self.key = r:readString() -- { 验证通过key }
end

-- [23835]挑战奖励 -- 竞技场 
ACK_ARENA_WAR_REWARD = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ARENA_WAR_REWARD
    self:init()
end)

function ACK_ARENA_WAR_REWARD.decode(self, r)
    self.res = r:readInt8Unsigned() -- { 结果 }
    self.gold = r:readInt32Unsigned() -- { 获得铜钱 }
    self.renown = r:readInt32Unsigned() -- { 获得声望 }
    self.rank = r:readInt16Unsigned() -- { 挑战后的排名 }
    self.up = r:readInt32Unsigned() -- { 上升多少名 }
    self.rmb_band = r:readInt32Unsigned() -- { 奖励元宝(刷新记录) }
    self.rank_poor = r:readInt16Unsigned() -- { 上升多少名(刷新记录) }
end

-- [23850]战报 -- 竞技场 
ACK_ARENA_RADIO = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ARENA_RADIO
    self:init()
end)

function ACK_ARENA_RADIO.decode(self, r)
    self.start_time = r:readInt32Unsigned() -- { 挑战时间 }
    self.type = r:readInt8Unsigned() -- { 广播类型(传闻,竞技场 见常量CONST_CHAT_*) }
    self.event = r:readInt8Unsigned() -- { 事件(排名第一、连赢10次...见常量CONST_ARENA_*) }
    self.t_uid = r:readInt32Unsigned() -- { 挑战玩家uid }
    self.t_name = r:readUTF() -- { 挑战玩家名字 }
    self.t_ranking = r:readInt16Unsigned() -- { 挑战玩家排名 }
    self.b_uid = r:readInt32Unsigned() -- { 被挑战玩家uid }
    self.b_name = r:readUTF() -- { 被挑战玩家名字 }
    self.b_ranking = r:readInt16Unsigned() -- { 被挑战玩家排名 }
    self.result = r:readInt8Unsigned() -- { 1:成功 2:失败 }
end

-- [23870]结果 -- 竞技场 
ACK_ARENA_RESULT2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ARENA_RESULT2
    self:init()
end)

function ACK_ARENA_RESULT2.decode(self, r)
    self.buy_count = r:readInt16Unsigned() -- { 当前购买 属第几次 }
end

-- [23890]返回结果 -- 竞技场 
ACK_ARENA_BUY_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ARENA_BUY_OK
    self:init()
end)

function ACK_ARENA_BUY_OK.decode(self, r)
    self.scount = r:readInt16Unsigned() -- { 剩余挑战次数 }
end

-- [23931]高手信息 -- 竞技场 
ACK_ARENA_ACE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ARENA_ACE
    self:init()
end)

function ACK_ARENA_ACE.decode(self, r)
    self.ranking = r:readInt16Unsigned() -- { 排名 }
    self.uid = r:readInt32Unsigned() -- { uid }
    self.name = r:readUTF() -- { 名字 }
    self.lv = r:readInt16Unsigned() -- { 等级 }
    self.pro = r:readInt8Unsigned() -- { 职业 }
    self.power = r:readInt32Unsigned() -- { 战斗力 }
    self.renown = r:readInt32Unsigned() -- { 声望 }
    self.gold = r:readInt32Unsigned() -- { 铜钱 }
end

-- [23950]每日竞技场排行榜奖励 -- 竞技场 
ACK_ARENA_RANK_REWARD = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ARENA_RANK_REWARD
    self:init()
end)

-- [24000]领取倒计时 -- 竞技场 
ACK_ARENA_REWARD_TIMES = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ARENA_REWARD_TIMES
    self:init()
end)

function ACK_ARENA_REWARD_TIMES.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 类型（0或者1） }
    self.times = r:readInt32Unsigned() -- { 上次领取时间 }
    self.gold = r:readInt32Unsigned() -- { 当前职位可获铜钱 }
    self.renown = r:readInt32Unsigned() -- { 可领取铜钱 }
end

-- [24005]cd冷却中 -- 竞技场 
ACK_ARENA_CD_SEC = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ARENA_CD_SEC
    self:init()
end)

function ACK_ARENA_CD_SEC.decode(self, r)
    self.rmb = r:readInt16Unsigned() -- { 需花费元宝 }
    self.surplus = r:readInt8Unsigned() -- { 是否有挑战次数 }
end

-- [24020]清除成功 -- 竞技场 
ACK_ARENA_CLEAN_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ARENA_CLEAN_OK
    self:init()
end)

-- [24060]玩家数据 -- 竞技场 
ACK_ARENA_CHALL_NEW = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ARENA_CHALL_NEW
    self:init()
end)

function ACK_ARENA_CHALL_NEW.decode(self, r)
    self.sid = r:readInt16Unsigned() -- { 服务器id }
    self.pro = r:readInt8Unsigned() -- { 职业 }
    self.sex = r:readInt8Unsigned() -- { 性别 }
    self.lv = r:readInt16Unsigned() -- { 等级 }
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
    self.name = r:readUTF() -- { 玩家名字 }
    self.ranking = r:readInt16Unsigned() -- { 排名 }
    self.win_count = r:readInt8Unsigned() -- { 连胜次数 }
    self.surplus = r:readInt8Unsigned() -- { 剩余次数 }
    self.power = r:readInt32Unsigned() -- { 战斗力 }
    self.lqid = r:readInt16Unsigned() -- { 灵器id }
    self.syid = r:readInt16Unsigned() -- { 神羽id }
end

-- [24850]信息块 -- 排行榜 
ACK_TOP_MSG_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TOP_MSG_XXX
    self:init()
end)

function ACK_TOP_MSG_XXX.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 排行榜类型 }
    self.name = r:readString() -- { 名字 }
end

-- [24930]每日首充回 -- 新手卡 
ACK_CARD_CHARGE_DAILY_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CARD_CHARGE_DAILY_CB
    self:init()
end)

function ACK_CARD_CHARGE_DAILY_CB.decode(self, r)
    self.day = r:readInt8Unsigned() -- { 已领取的day }
    self.is = r:readInt8Unsigned() -- { 今天是否已经领取 }
end

-- [24940]领取成功返回 -- 新手卡 
ACK_CARD_CHARGE_SUC = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CARD_CHARGE_SUC
    self:init()
end)

-- [25025]可以挑战的玩家信息块 -- 灵妖竞技场 
ACK_LINGYAO_ARENA_CANBECHALLAGE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ARENA_CANBECHALLAGE
    self:init()
end)

function ACK_LINGYAO_ARENA_CANBECHALLAGE.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家UID }
    self.name = r:readString() -- { 玩家名字 }
    self.lingyao_id = r:readInt16Unsigned() -- { 灵妖ID }
    self.rank = r:readInt16Unsigned() -- { 排名 }
    self.power = r:readInt16Unsigned() -- { 战斗力 }
end

-- [25050]对手信息块 -- 灵妖竞技场 
ACK_LINGYAO_ARENA_RIVAL_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ARENA_RIVAL_DATA
    self:init()
end)

function ACK_LINGYAO_ARENA_RIVAL_DATA.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 灵妖ID }
    self.lv = r:readInt16Unsigned() -- { 灵妖等级 }
    self.pos = r:readInt8Unsigned() -- { 灵妖位置 }
    self.camp = r:readInt8Unsigned() -- { 阵营 }
end

-- [25062]购买提示返回 -- 灵妖竞技场 
ACK_LINGYAO_ARENA_BUY_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ARENA_BUY_REPLY
    self:init()
end)

function ACK_LINGYAO_ARENA_BUY_REPLY.decode(self, r)
    self.times = r:readInt8Unsigned() -- { 剩余购买次数 }
end

-- [25065]竞技场剩余次数返回 -- 灵妖竞技场 
ACK_LINGYAO_ARENA_TIMES = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ARENA_TIMES
    self:init()
end)

function ACK_LINGYAO_ARENA_TIMES.decode(self, r)
    self.times = r:readInt8Unsigned() -- { 次数 }
end

-- [25078]物品信息块 -- 灵妖竞技场 
ACK_LINGYAO_ARENA_GOODS_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ARENA_GOODS_DATA
    self:init()
end)

function ACK_LINGYAO_ARENA_GOODS_DATA.decode(self, r)
    self.goods_id = r:readInt16Unsigned() -- { 物品ID }
    self.goods_count = r:readInt8Unsigned() -- { 物品数量 }
end

-- [25095]战报返回 -- 灵妖竞技场 
ACK_LINGYAO_ARENA_REPORT_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ARENA_REPORT_DATA
    self:init()
end)

function ACK_LINGYAO_ARENA_REPORT_DATA.decode(self, r)
    self.time = r:readInt32Unsigned() -- { 时间 }
    self.uid = r:readInt32Unsigned() -- { 挑战者id }
    self.name = r:readString() -- { 挑战者名字 }
    self.rank = r:readInt16Unsigned() -- { 挑战者排名 }
    self.uid2 = r:readInt32Unsigned() -- { 被挑战者id }
    self.name2 = r:readString() -- { 被挑战者名字 }
    self.rank2 = r:readInt16Unsigned() -- { 被挑战者排名 }
    self.result = r:readInt8Unsigned() -- { 结果(1完胜:2胜利:3平局4:失败5:完败) }
end

-- [25097]cd冷却中 -- 灵妖竞技场 
ACK_LINGYAO_ARENA_CD_SEC = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ARENA_CD_SEC
    self:init()
end)

function ACK_LINGYAO_ARENA_CD_SEC.decode(self, r)
    self.rmb = r:readInt16Unsigned() -- { 需花费元宝 }
    self.surplus = r:readInt8Unsigned() -- { 是否有挑战次数 }
end

-- [25105]CD清除返回 -- 灵妖竞技场 
ACK_LINGYAO_ARENA_CD_CLEAN_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ARENA_CD_CLEAN_OK
    self:init()
end)

-- [25120]阵容信息块 -- 灵妖竞技场 
ACK_LINGYAO_ARENA_DEF_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ARENA_DEF_DATA
    self:init()
end)

function ACK_LINGYAO_ARENA_DEF_DATA.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 灵妖ID }
    self.lv = r:readInt8Unsigned() -- { 灵妖等级 }
    self.camp = r:readInt8Unsigned() -- { 灵妖阵营 }
    self.pos = r:readInt8Unsigned() -- { 灵妖位置 }
end

-- [25135]分钟奖励信息 -- 灵妖竞技场 
ACK_LINGYAO_ARENA_REWARD_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ARENA_REWARD_DATA
    self:init()
end)

function ACK_LINGYAO_ARENA_REWARD_DATA.decode(self, r)
    self.goods_id = r:readInt16Unsigned() -- { 物品ID }
    self.count_all = r:readInt16Unsigned() -- { 物品数量(累积) }
    self.count = r:readInt16Unsigned() -- { 物品数量(每分钟) }
    self.time = r:readInt32Unsigned() -- { 上次领取时间 }
end

-- [25148]验证通过 -- 灵妖竞技场 
ACK_LINGYAO_ARENA_THROUGH = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_ARENA_THROUGH
    self:init()
end)

function ACK_LINGYAO_ARENA_THROUGH.decode(self, r)
    self.key = r:readString() -- { 验证通过key }
end

-- [25540]成功购买招财貔貅 -- 招财貔貅 
ACK_WEAGOD_RMB_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WEAGOD_RMB_SUCCESS
    self:init()
end)

-- [25560]礼包领取返回 -- 招财貔貅 
ACK_WEAGOD_RMB_GIFT_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WEAGOD_RMB_GIFT_BACK
    self:init()
end)

function ACK_WEAGOD_RMB_GIFT_BACK.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 信息块 }
end

-- [25570]貔貅界面控制 -- 招财貔貅 
ACK_WEAGOD_RMB_GUI_CONTROL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WEAGOD_RMB_GUI_CONTROL
    self:init()
end)

function ACK_WEAGOD_RMB_GUI_CONTROL.decode(self, r)
    self.flag = r:readInt8Unsigned() -- { 控制1显示0取消 }
end

-- [26007]返回NPC副本ID -- NPC 
ACK_NPC_COPY_ID = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_NPC_COPY_ID
    self:init()
end)

function ACK_NPC_COPY_ID.decode(self, r)
    self.copy_id = r:readInt16Unsigned() -- { 副本ID }
end

-- [26015]关闭组队面板 -- NPC 
ACK_NPC_CLOSE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_NPC_CLOSE
    self:init()
end)

-- [26020]通知--删除队伍 -- NPC 
ACK_NPC_NOTICE_DELETE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_NPC_NOTICE_DELETE
    self:init()
end)

function ACK_NPC_NOTICE_DELETE.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 队长Uid }
end

-- [26110]隐藏队伍 -- NPC 
ACK_NPC_NOTICE_HIDE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_NPC_NOTICE_HIDE
    self:init()
end)

function ACK_NPC_NOTICE_HIDE.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { UID }
end

-- [28050]布阵伙伴信息块 -- 布阵 
ACK_ARRAY_ROLE_INFO = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ARRAY_ROLE_INFO
    self:init()
end)

function ACK_ARRAY_ROLE_INFO.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 1:玩家,2:伙伴 }
    self.id = r:readInt16Unsigned() -- { 伙伴ID/玩家UID }
    self.position_idx = r:readInt8Unsigned() -- { 阵位 }
    self.lv = r:readInt16Unsigned() -- { 等级 }
end

-- [29030]信息块 -- 洞府祈福 
ACK_CLIFFORD_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLIFFORD_XXX
    self:init()
end)

function ACK_CLIFFORD_XXX.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 日志类型| CONST_CLAN_EVENT_XX }
    self.name = r:readString() -- { 玩家名字 }
    self.time = r:readInt32Unsigned() -- { 时间戳 }
end

-- [29035]信息块 -- 洞府祈福 
ACK_CLIFFORD_XXXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLIFFORD_XXXX
    self:init()
end)

function ACK_CLIFFORD_XXXX.decode(self, r)
    self.idx = r:readInt8Unsigned() -- { 可领编号 }
end

-- [29050]祈福成功 -- 洞府祈福 
ACK_CLIFFORD_OVER = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLIFFORD_OVER
    self:init()
end)

-- [29070]领取箱子成功 -- 洞府祈福 
ACK_CLIFFORD_LQ_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLIFFORD_LQ_BACK
    self:init()
end)

function ACK_CLIFFORD_LQ_BACK.decode(self, r)
    self.idx = r:readInt8Unsigned() -- { 编号 }
end

-- [30560]领取宝箱成功 -- 攻略 
ACK_GONGLUE_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GONGLUE_SUCCESS
    self:init()
end)

function ACK_GONGLUE_SUCCESS.decode(self, r)
    self.id = r:readInt8Unsigned() -- { 宝箱阶段ID }
end

-- [31365]灵妖升阶返回 -- 灵妖系统 
ACK_LINGYAO_SHENJIE_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_SHENJIE_BACK
    self:init()
end)

-- [31515]妖魂 -- 灵妖系统 
ACK_LINGYAO_RENOWN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_RENOWN
    self:init()
end)

function ACK_LINGYAO_RENOWN.decode(self, r)
    self.renown = r:readInt32Unsigned() -- { 声望 }
end

-- [31570]元魂 -- 灵妖系统 
ACK_LINGYAO_YUANHUN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LINGYAO_YUANHUN
    self:init()
end)

function ACK_LINGYAO_YUANHUN.decode(self, r)
    self.yuanhun = r:readInt32Unsigned() -- { 元魂数量 }
end

-- [32025]招财信息块 -- 摇钱树 
ACK_WEAGOD_WEAGOD_R_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WEAGOD_WEAGOD_R_MSG
    self:init()
end)

function ACK_WEAGOD_WEAGOD_R_MSG.decode(self, r)
    self.odds = r:readInt8Unsigned() -- { 赔率 }
    self.gold = r:readInt32Unsigned() -- { 获得金钱 }
end

-- [32060]招财成功返回 -- 摇钱树 
ACK_WEAGOD_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WEAGOD_SUCCESS
    self:init()
end)

function ACK_WEAGOD_SUCCESS.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 类型1为一次，2为批量 }
end

-- [32070]招财暴击 -- 摇钱树 
ACK_WEAGOD_CRIT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WEAGOD_CRIT
    self:init()
end)

function ACK_WEAGOD_CRIT.decode(self, r)
    self.double = r:readInt8Unsigned() -- { 两倍暴击次数 }
    self.decuple = r:readInt8Unsigned() -- { 十倍暴击次数 }
end

-- [33020]返加帮派基础数据1 -- 帮派 
ACK_CLAN_OK_CLAN_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_OK_CLAN_DATA
    self:init()
end)

function ACK_CLAN_OK_CLAN_DATA.decode(self, r)
    self.clan_id = r:readInt32Unsigned() -- { 帮派id }
    self.clan_name = r:readString() -- { 帮派名字 }
    self.clan_lv = r:readInt8Unsigned() -- { 帮派等级 }
    self.clan_rank = r:readInt16Unsigned() -- { 帮派排名 }
    self.clan_members = r:readInt16Unsigned() -- { 帮派成员个数 }
    self.clan_all_members = r:readInt16Unsigned() -- { 最大成员个数 }
end

-- [33023]返加帮派基础数据2 -- 帮派 
ACK_CLAN_OK_OTHER_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_OK_OTHER_DATA
    self:init()
end)

function ACK_CLAN_OK_OTHER_DATA.decode(self, r)
    self.master_uid = r:readInt32Unsigned() -- { 帮主uid }
    self.master_name = r:readString() -- { 帮主名字 }
    self.master_name_color = r:readInt8Unsigned() -- { 帮主名字颜色 }
    self.master_lv = r:readInt16Unsigned() -- { 帮主等级 }
    self.sum_power = r:readInt32Unsigned() -- { 帮派总战斗力 }
    self.clan_all_contribute = r:readInt32Unsigned() -- { 帮派贡献 }
    self.clan_contribute = r:readInt32Unsigned() -- { 帮派升级所需贡献 }
    self.clan_broadcast = r:readUTF() -- { 帮派公告 }
    self.upost = r:readInt8Unsigned() -- { 自己的职位 }
end

-- [33027]string数据块 -- 帮派 
ACK_CLAN_STING_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_STING_MSG
    self:init()
end)

function ACK_CLAN_STING_MSG.decode(self, r)
    self.name = r:readString() -- { 名字 }
    self.name_color = r:readInt8Unsigned() -- { 名字颜色 }
end

-- [33028]int数据块 -- 帮派 
ACK_CLAN_INT_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_INT_MSG
    self:init()
end)

function ACK_CLAN_INT_MSG.decode(self, r)
    self.value = r:readInt32Unsigned() -- { 数值 }
end

-- [33040]申请成功 -- 帮派 
ACK_CLAN_OK_JOIN_CLAN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_OK_JOIN_CLAN
    self:init()
end)

function ACK_CLAN_OK_JOIN_CLAN.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 操作类型0取消| 1申请 }
    self.clan_id = r:readInt32Unsigned() -- { 帮派ID }
end

-- [33060]创建成功 -- 帮派 
ACK_CLAN_OK_REBUILD_CLAN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_OK_REBUILD_CLAN
    self:init()
end)

-- [33085]入帮申请玩家信息块 -- 帮派 
ACK_CLAN_USER_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_USER_DATA
    self:init()
end)

function ACK_CLAN_USER_DATA.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家Uid }
    self.name = r:readString() -- { 玩家名字 }
    self.name_color = r:readInt8Unsigned() -- { 玩家名字颜色 }
    self.lv = r:readInt16Unsigned() -- { 等级 }
    self.pro = r:readInt8Unsigned() -- { 职业 }
    self.power = r:readInt32Unsigned() -- { 战斗力 }
end

-- [33095]返回审核结果 -- 帮派 
ACK_CLAN_OK_AUDIT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_OK_AUDIT
    self:init()
end)

function ACK_CLAN_OK_AUDIT.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家Uid }
    self.state = r:readInt8Unsigned() -- { 审核结果 1 true| 0 false }
end

-- [33098]申请帮派审核成功 -- 帮派 
ACK_CLAN_AUDIT_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_AUDIT_SUCCESS
    self:init()
end)

-- [33120]返回修改公告结果 -- 帮派 
ACK_CLAN_OK_RESET_CAST = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_OK_RESET_CAST
    self:init()
end)

-- [33145]成员数据信息块 -- 帮派 
ACK_CLAN_MEMBER_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_MEMBER_MSG
    self:init()
end)

function ACK_CLAN_MEMBER_MSG.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家Uid }
    self.name = r:readString() -- { 玩家名字 }
    self.name_color = r:readInt8Unsigned() -- { 玩家名字颜色 }
    self.lv = r:readInt16Unsigned() -- { 玩家等级 }
    self.pro = r:readInt8Unsigned() -- { 职业 }
    self.post = r:readInt8Unsigned() -- { 职位 }
    self.power = r:readInt32Unsigned() -- { 总战斗力 }
    self.today_gx = r:readInt32Unsigned() -- { 今日贡献 }
    self.all_gx = r:readInt32Unsigned() -- { 总贡献 }
    self.time = r:readInt32Unsigned() -- { 离线时间(s) 1表示在线 }
end

-- [33160]退出帮派成功 -- 帮派 
ACK_CLAN_OK_OUT_CLAN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_OK_OUT_CLAN
    self:init()
end)

-- [33215]帮派技能属性数据块【33215】 -- 帮派 
ACK_CLAN_CLAN_ATTR_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_CLAN_ATTR_DATA
    self:init()
end)

function ACK_CLAN_CLAN_ATTR_DATA.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 属性类型 }
    self.skill_lv = r:readInt8Unsigned() -- { 技能等级 }
    self.value = r:readInt32Unsigned() -- { 原有属性值 }
    self.add_value = r:readInt16Unsigned() -- { 培养可增加属性值 }
    self.cast = r:readInt32Unsigned() -- { 消费体能点数 }
end

-- [33305]玩家现有帮贡值 -- 帮派 
ACK_CLAN_NOW_STAMINA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_NOW_STAMINA
    self:init()
end)

function ACK_CLAN_NOW_STAMINA.decode(self, r)
    self.stamina = r:readInt32Unsigned() -- { 贡献值 }
end

-- [33315]帮派活动面板数据块 -- 帮派 
ACK_CLAN_ACTIVE_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_ACTIVE_MSG
    self:init()
end)

function ACK_CLAN_ACTIVE_MSG.decode(self, r)
    self.active_id = r:readInt16Unsigned() -- { 活动ID }
    self.limite_clanlv = r:readInt8Unsigned() -- { 帮派等级限制 }
    self.times = r:readInt8Unsigned() -- { 已使用次数 }
    self.all_times = r:readInt8Unsigned() -- { 总计可使用次数 }
    self.state = r:readInt8Unsigned() -- { 活动状态 0待开| 1已开| 2结束 }
end

-- [33330]返回浇水面板数据 -- 帮派 
ACK_CLAN_OK_WATER_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_OK_WATER_DATA
    self:init()
end)

function ACK_CLAN_OK_WATER_DATA.decode(self, r)
    self.state = r:readInt8Unsigned() -- { 是否可以互动 0:否1:是 }
end

-- [33400]个人职位 -- 帮派 
ACK_CLAN_POST_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_POST_BACK
    self:init()
end)

function ACK_CLAN_POST_BACK.decode(self, r)
    self.post = r:readInt8Unsigned() -- { CONST_CLAN_POST_* }
end

-- [33420]角标信息块 -- 帮派 
ACK_CLAN_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_XXX
    self:init()
end)

function ACK_CLAN_XXX.decode(self, r)
    self.idx = r:readInt8Unsigned() -- { 编号1:申请2:祈福 }
    self.num = r:readInt8Unsigned() -- { 数量 }
end

-- [34020]请求界面成功 -- 活动-龙宫寻宝 
ACK_DRAGON_OK_JOIN_DRAGON = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DRAGON_OK_JOIN_DRAGON
    self:init()
end)

function ACK_DRAGON_OK_JOIN_DRAGON.decode(self, r)
    self.viplv = r:readInt8Unsigned() -- { VIP等级 }
    self.treasure = r:readInt32Unsigned() -- { 寻宝令数量 }
end

-- [34050]寻宝奖励信息块 -- 活动-龙宫寻宝 
ACK_DRAGON_REWARDS_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DRAGON_REWARDS_MSG
    self:init()
end)

function ACK_DRAGON_REWARDS_MSG.decode(self, r)
    self.good_id = r:readInt32Unsigned() -- { 物品ID }
    self.count = r:readInt8Unsigned() -- { 物品数量 }
end

-- [34265]武器界面返回 -- 武器 
ACK_WUQI_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WUQI_REPLY
    self:init()
end)

function ACK_WUQI_REPLY.decode(self, r)
    self.lv = r:readInt16Unsigned() -- { 武器等级(0未激活) }
    self.pro = r:readInt8Unsigned() -- { 职业 }
    self.time = r:readInt32Unsigned() -- { 功能开放时间 }
end

-- [34516]购买成功 -- 商城 
ACK_SHOP_BUY_SUCC = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SHOP_BUY_SUCC
    self:init()
end)

function ACK_SHOP_BUY_SUCC.decode(self, r)
    self.type = r:readInt16Unsigned() -- { 商城类型 }
    self.type_bb = r:readInt16Unsigned() -- { 子店铺类型 }
    self.idx = r:readInt16Unsigned() -- { 索引 }
    self.state = r:readInt16() -- { -1:不限购|其它:还可购买数量 }
    self.good_id = r:readInt16Unsigned() -- { 打折卡id 0:无 }
end

-- [34522]玩家积分数据 -- 商城 
ACK_SHOP_INTEGRAL_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SHOP_INTEGRAL_BACK
    self:init()
end)

function ACK_SHOP_INTEGRAL_BACK.decode(self, r)
    self.integral = r:readInt32Unsigned() -- { 积分 }
end

-- [34530]活动时间返回 -- 商城 
ACK_SHOP_ACTIVE_TIME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SHOP_ACTIVE_TIME
    self:init()
end)

function ACK_SHOP_ACTIVE_TIME.decode(self, r)
    self.starttime = r:readInt32Unsigned() -- { 开始时间戳 }
    self.endtime = r:readInt32Unsigned() -- { 结束时间戳 }
end

-- [35026]玩家信息块(抓捕,求救) -- 苦工 
ACK_MOIL_MOIL_XXXX1 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MOIL_MOIL_XXXX1
    self:init()
end)

function ACK_MOIL_MOIL_XXXX1.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
    self.name = r:readString() -- { 玩家姓名 }
    self.sex = r:readInt8Unsigned() -- { 玩家性别 }
    self.pro = r:readInt8Unsigned() -- { 玩家职业 }
    self.lv = r:readInt16Unsigned() -- { 玩家等级 }
    self.lord_name = r:readString() -- { 主人名字 }
    self.type_id = r:readInt8Unsigned() -- { 身份id }
    self.power = r:readInt32Unsigned() -- { 战斗力 }
end

-- [35045]抓捕返回 -- 苦工 
ACK_MOIL_CAPTRUE_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MOIL_CAPTRUE_BACK
    self:init()
end)

function ACK_MOIL_CAPTRUE_BACK.decode(self, r)
    self.res = r:readInt8Unsigned() -- { 0:失败 1:成功 }
    self.name1 = r:readString() -- { 名字 }
end

-- [35062]苦工信息 -- 苦工 
ACK_MOIL_MOIL_XXXX2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MOIL_MOIL_XXXX2
    self:init()
end)

function ACK_MOIL_MOIL_XXXX2.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 苦工uid }
    self.pro = r:readInt8Unsigned() -- { 苦工职业 }
    self.sex = r:readInt8Unsigned() -- { 苦工性别 }
    self.name = r:readString() -- { 苦工名字 }
    self.lv = r:readInt16Unsigned() -- { 被抓捕时等级 }
    self.zuid = r:readInt32Unsigned() -- { 主人uid }
    self.zname = r:readString() -- { 主人名字 }
    self.zpower = r:readInt32Unsigned() -- { 主人战斗力 }
end

-- [35064]苦工具体信息 -- 苦工 
ACK_MOIL_MOIL_XXXX3 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MOIL_MOIL_XXXX3
    self:init()
end)

function ACK_MOIL_MOIL_XXXX3.decode(self, r)
    self.expn = r:readInt32Unsigned() -- { 可提取经验 }
    self.time = r:readInt32Unsigned() -- { 剩余干活时间 }
    self.is_over = r:readInt8Unsigned() -- { 是否榨干 0:否 1:是 }
end

-- [35110]结果 -- 苦工 
ACK_MOIL_RELEASE_RS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MOIL_RELEASE_RS
    self:init()
end)

function ACK_MOIL_RELEASE_RS.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 身份ID }
end

-- [35130]返回消耗信息 -- 苦工 
ACK_MOIL_BUY_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MOIL_BUY_OK
    self:init()
end)

function ACK_MOIL_BUY_OK.decode(self, r)
    self.sy_znum = r:readInt8Unsigned() -- { 剩余抓捕次数 }
    self.sy_gnum = r:readInt8Unsigned() -- { 剩余购买次数 }
end

-- [35150]解救/求解结果 -- 苦工 
ACK_MOIL_CALL_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MOIL_CALL_BACK
    self:init()
end)

function ACK_MOIL_CALL_BACK.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 常量CONST_MOIL_FUNCTION* }
    self.zlv = r:readInt16Unsigned() -- { 挑战者的等级 }
    self.zpro = r:readInt8Unsigned() -- { 挑战者的职业 }
    self.zname = r:readString() -- { 挑战者的名字 }
    self.zpower = r:readInt32Unsigned() -- { 挑战者的战力 }
    self.blv = r:readInt16Unsigned() -- { 被挑战者的等级 }
    self.bpro = r:readInt8Unsigned() -- { 被挑战者的职业 }
    self.bname = r:readString() -- { 被挑战者的名字 }
    self.bpower = r:readInt32Unsigned() -- { 被挑战者的战力 }
    self.result = r:readInt8Unsigned() -- { 战斗结果 }
end

-- [36021]当前信息块(废除) -- 三界杀 
ACK_CIRCLE_DATA_GROUP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CIRCLE_DATA_GROUP
    self:init()
end)

function ACK_CIRCLE_DATA_GROUP.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 武将ID }
    self.idx = r:readInt8Unsigned() -- { 位置 }
    self.stata = r:readInt8Unsigned() -- { 是否可以挑战 }
    self.is_one = r:readInt8Unsigned() -- { 是否第一次挑战 }
    self.is_rs = r:readInt8Unsigned() -- { 是否可重置 }
    self.best_sid = r:readInt16Unsigned() -- { 最佳玩家sid }
    self.best_uid = r:readInt32Unsigned() -- { 最佳玩家uid }
    self.best_name = r:readString() -- { 最佳玩家名字 }
    self.bets_war_id = r:readInt16Unsigned() -- { 最佳玩家战报ID }
    self.first_sid = r:readInt16Unsigned() -- { 首次击杀玩家sid }
    self.first_uid = r:readInt32Unsigned() -- { 首次击杀玩家uid }
    self.first_name = r:readString() -- { 首次击杀玩家名字 }
    self.first_war_id = r:readInt16Unsigned() -- { 首次击杀玩家战报ID }
end

-- [36022]当前信息块(新) -- 三界杀 
ACK_CIRCLE_2_DATA_GROUP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CIRCLE_2_DATA_GROUP
    self:init()
end)

function ACK_CIRCLE_2_DATA_GROUP.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 武将ID }
    self.idx = r:readInt8Unsigned() -- { 位置 }
    self.stata = r:readInt8Unsigned() -- { 是否可以挑战 }
    self.is_one = r:readInt8Unsigned() -- { 是否第一次挑战 }
    self.is_rs = r:readInt8Unsigned() -- { 是否可重置 }
    self.best_sid = r:readInt16Unsigned() -- { 最佳玩家sid }
    self.best_uid = r:readInt32Unsigned() -- { 最佳玩家uid }
    self.best_name = r:readString() -- { 最佳玩家名字 }
    self.bets_war_id = r:readInt32Unsigned() -- { 最佳玩家战报ID }
    self.first_sid = r:readInt16Unsigned() -- { 首次击杀玩家sid }
    self.first_uid = r:readInt32Unsigned() -- { 首次击杀玩家uid }
    self.first_name = r:readString() -- { 首次击杀玩家名字 }
    self.first_war_id = r:readInt32Unsigned() -- { 首次击杀玩家战报ID }
end

-- [37007]世界BOSS状态信息块 -- 世界BOSS 
ACK_WORLD_BOSS_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WORLD_BOSS_XXX
    self:init()
end)

function ACK_WORLD_BOSS_XXX.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 唯一ID }
    self.state = r:readInt8Unsigned() -- { BOSS状态(0未刷新 1 进行中  2 已杀死 3 逃脱) }
end

-- [37020]返回地图数据 -- 世界BOSS 
ACK_WORLD_BOSS_MAP_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WORLD_BOSS_MAP_DATA
    self:init()
end)

function ACK_WORLD_BOSS_MAP_DATA.decode(self, r)
    self.time = r:readInt32Unsigned() -- { 开始时间 }
    self.stime = r:readInt32Unsigned() -- { 结束时间 }
    self.is_start = r:readInt8Unsigned() -- { 是否开始 0:否 1:是 }
end

-- [37053]自己伤害 -- 世界BOSS 
ACK_WORLD_BOSS_SELF_HP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WORLD_BOSS_SELF_HP
    self:init()
end)

function ACK_WORLD_BOSS_SELF_HP.decode(self, r)
    self.hp = r:readInt32Unsigned() -- { 伤害 }
end

-- [37070]DPS排行块 -- 世界BOSS 
ACK_WORLD_BOSS_DPS_XX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WORLD_BOSS_DPS_XX
    self:init()
end)

function ACK_WORLD_BOSS_DPS_XX.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
    self.name = r:readString() -- { 名字 }
    self.rank = r:readInt16Unsigned() -- { 排名 }
    self.harm = r:readInt32Unsigned() -- { 伤害 }
end

-- [37090]返回结果 -- 世界BOSS 
ACK_WORLD_BOSS_WAR_RS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WORLD_BOSS_WAR_RS
    self:init()
end)

function ACK_WORLD_BOSS_WAR_RS.decode(self, r)
    self.time = r:readInt32Unsigned() -- { 复活时间 }
    self.rmb = r:readInt16Unsigned() -- { 复活要使用的元宝 }
end

-- [37120]复活成功 -- 世界BOSS 
ACK_WORLD_BOSS_REVIVE_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WORLD_BOSS_REVIVE_OK
    self:init()
end)

function ACK_WORLD_BOSS_REVIVE_OK.decode(self, r)
    self.pos_x = r:readInt16Unsigned() -- { 出生点X轴 }
    self.pos_y = r:readInt16Unsigned() -- { 出生点Y轴 }
end

-- [37180]结算块 -- 世界BOSS 
ACK_WORLD_BOSS_SETTLE_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WORLD_BOSS_SETTLE_DATA
    self:init()
end)

function ACK_WORLD_BOSS_SETTLE_DATA.decode(self, r)
    self.flag = r:readInt8Unsigned() -- { 0:不加购买双倍，1:加购买双倍 }
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
    self.name = r:readString() -- { 名字 }
    self.rank = r:readInt8Unsigned() -- { 排名 }
    self.lv = r:readInt16Unsigned() -- { 等级 }
    self.pro = r:readInt8Unsigned() -- { 职业 }
    self.powerful = r:readInt32Unsigned() -- { 战斗力 }
    self.harm = r:readInt32Unsigned() -- { 伤害 }
    self.rates = r:readInt16Unsigned() -- { 伤害率万分比 }
    self.gold = r:readInt32Unsigned() -- { 铜钱奖励 }
    self.goods_id = r:readInt16Unsigned() -- { 物品id }
    self.num = r:readInt16Unsigned() -- { 物品数量 }
    self.last_kill = r:readInt8Unsigned() -- { 0:排行 1:击杀 2:自己 }
end

-- [37190]移除boss -- 世界BOSS 
ACK_WORLD_BOSS_BOSS_LEVEL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WORLD_BOSS_BOSS_LEVEL
    self:init()
end)

-- [37205]鼓舞消耗 -- 世界BOSS 
ACK_WORLD_BOSS_RMB_USE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WORLD_BOSS_RMB_USE
    self:init()
end)

function ACK_WORLD_BOSS_RMB_USE.decode(self, r)
    self.rmb = r:readInt16Unsigned() -- { 消耗数量 }
    self.times = r:readInt8Unsigned() -- { 已鼓舞次数 }
    self.times_max = r:readInt8Unsigned() -- { 最多次数 }
    self.value = r:readInt16Unsigned() -- { 加成伤害百分比 }
end

-- [37210]加成伤害 -- 世界BOSS 
ACK_WORLD_BOSS_UP_ATTR = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WORLD_BOSS_UP_ATTR
    self:init()
end)

function ACK_WORLD_BOSS_UP_ATTR.decode(self, r)
    self.value = r:readInt16Unsigned() -- { 加成百分比 }
end

-- [37230]boss的当前血量 -- 世界BOSS 
ACK_WORLD_BOSS_NOW_HP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WORLD_BOSS_NOW_HP
    self:init()
end)

function ACK_WORLD_BOSS_NOW_HP.decode(self, r)
    self.boss_id = r:readInt16Unsigned() -- { boss_id }
    self.boss_hp = r:readInt32Unsigned() -- { boss血量 }
end

-- [37304]世界BOSS购买信息返回 -- 世界BOSS 
ACK_WORLD_BOSS_BUY_INFO_ANS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WORLD_BOSS_BUY_INFO_ANS
    self:init()
end)

function ACK_WORLD_BOSS_BUY_INFO_ANS.decode(self, r)
    self.call_demand = r:readInt16Unsigned() -- { 竞技排名要求 }
    self.p_call_time = r:readInt8Unsigned() -- { 个人剩余召唤次数 }
    self.w_call_time = r:readInt8Unsigned() -- { 世界剩余召唤次数 }
    self.call_cost = r:readInt32Unsigned() -- { 召唤需花费砖石 }
    self.flag = r:readInt8Unsigned() -- { 是否满足购买条件(0/不满足,1/满足) }
end

-- [37308]请求购买世界BOSS返回 -- 世界BOSS 
ACK_WORLD_BOSS_BUY_ANS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WORLD_BOSS_BUY_ANS
    self:init()
end)

function ACK_WORLD_BOSS_BUY_ANS.decode(self, r)
    self.flag = r:readInt8Unsigned() -- { 0/失败，1/成功 }
end

-- [38015]目标数据信息块 -- 目标任务 
ACK_TARGET_MSG_GROUP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TARGET_MSG_GROUP
    self:init()
end)

function ACK_TARGET_MSG_GROUP.decode(self, r)
    self.serial = r:readInt16Unsigned() -- { 目标序号 }
    self.state = r:readInt8Unsigned() -- { 目标状态 }
end

-- [39030]战役数据信息块 -- 噩梦副本 
ACK_HERO_MSG_BATTLE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HERO_MSG_BATTLE
    self:init()
end)

function ACK_HERO_MSG_BATTLE.decode(self, r)
    self.copy_id = r:readInt16Unsigned() -- { 副本ID }
    self.is_pass = r:readInt8Unsigned() -- { 是否通过过 }
end

-- [39060]购买次数返回 -- 噩梦副本 
ACK_HERO_BACK_TIMES = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HERO_BACK_TIMES
    self:init()
end)

function ACK_HERO_BACK_TIMES.decode(self, r)
    self.times = r:readInt16Unsigned() -- { 总购买次数 }
end

-- [39080]战役数据信息块(new) -- 噩梦副本 
ACK_HERO_MSG_BATTLE_NEW = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HERO_MSG_BATTLE_NEW
    self:init()
end)

function ACK_HERO_MSG_BATTLE_NEW.decode(self, r)
    self.copy_id = r:readInt16Unsigned() -- { 副本ID }
    self.is_pass = r:readInt8Unsigned() -- { 是否通过过 }
    self.eva = r:readInt8Unsigned() -- { 评价 }
end

-- [39095]精英次数返回 -- 噩梦副本 
ACK_HERO_TIMES_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HERO_TIMES_REPLY
    self:init()
end)

function ACK_HERO_TIMES_REPLY.decode(self, r)
    self.times = r:readInt16Unsigned() -- { 次数 }
end

-- [39540]副本信息块 -- 珍宝副本 
ACK_COPY_GEM_MSG_COPYS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_GEM_MSG_COPYS
    self:init()
end)

function ACK_COPY_GEM_MSG_COPYS.decode(self, r)
    self.copy_id = r:readInt16Unsigned() -- { 副本ID }
    self.is_pass = r:readInt8Unsigned() -- { 是否已经通过 }
    self.eva = r:readInt8Unsigned() -- { 过关评分 }
end

-- [39555]次数购买返回 -- 珍宝副本 
ACK_COPY_GEM_TIMES_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_GEM_TIMES_REPLY
    self:init()
end)

function ACK_COPY_GEM_TIMES_REPLY.decode(self, r)
    self.times = r:readInt8Unsigned() -- { 次数 }
end

-- [40032]是否领取信息块 -- 签到抽奖 
ACK_SIGN_YES_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SIGN_YES_MSG
    self:init()
end)

function ACK_SIGN_YES_MSG.decode(self, r)
    self.yes_id = r:readInt16Unsigned() -- { 抽取过的唯一id }
end

-- [40038]历史记录 -- 签到抽奖 
ACK_SIGN_HISTORY_REP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SIGN_HISTORY_REP
    self:init()
end)

function ACK_SIGN_HISTORY_REP.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
    self.good_id = r:readInt32Unsigned() -- { 物品id }
end

-- [40052]返回抽取奖励信息 -- 签到抽奖 
ACK_SIGN_GET_REP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SIGN_GET_REP
    self:init()
end)

function ACK_SIGN_GET_REP.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 当前抽取的唯一id }
end

-- [40062]弹窗数据 -- 签到抽奖 
ACK_SIGN_POP_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SIGN_POP_DATA
    self:init()
end)

function ACK_SIGN_POP_DATA.decode(self, r)
    self.pop = r:readInt8Unsigned() -- { 3.公告 2.签到 1.不弹 }
end

-- [40112]7天抽奖返回 -- 签到抽奖 
ACK_SIGN_SEVEN_REP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SIGN_SEVEN_REP
    self:init()
end)

function ACK_SIGN_SEVEN_REP.decode(self, r)
    self.times = r:readInt8Unsigned() -- { 抽取次数 }
    self.day_num = r:readInt16Unsigned() -- { 登录天数 }
end

-- [40503]界面返回 -- 帮派战 
ACK_GANG_WARFARE_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GANG_WARFARE_BACK
    self:init()
end)

function ACK_GANG_WARFARE_BACK.decode(self, r)
    self.enter = r:readInt8Unsigned() -- { 0:不可以1：可以 }
end

-- [40516]小组帮派信息 -- 帮派战 
ACK_GANG_WARFARE_CLAN_XXXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GANG_WARFARE_CLAN_XXXX
    self:init()
end)

function ACK_GANG_WARFARE_CLAN_XXXX.decode(self, r)
    self.idx = r:readInt8Unsigned() -- { 位置 }
    self.clan_name = r:readString() -- { 帮派名字 }
end

-- [40525]返回帮派战基本信息 -- 帮派战 
ACK_GANG_WARFARE_TIME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GANG_WARFARE_TIME
    self:init()
end)

function ACK_GANG_WARFARE_TIME.decode(self, r)
    self.start_time = r:readInt32Unsigned() -- { 开始时间 }
    self.end_time = r:readInt32Unsigned() -- { 结束时间 }
end

-- [40530]帮派战个人信息 -- 帮派战 
ACK_GANG_WARFARE_ONCE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GANG_WARFARE_ONCE
    self:init()
end)

function ACK_GANG_WARFARE_ONCE.decode(self, r)
    self.kill = r:readInt8Unsigned() -- { 个人击杀数量 }
    self.batter_kill = r:readInt8Unsigned() -- { 个人连击数 }
    self.rec = r:readInt8Unsigned() -- { 复活次数 }
end

-- [40540]帮派战况信息块 -- 帮派战 
ACK_GANG_WARFARE_LIVE_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GANG_WARFARE_LIVE_DATA
    self:init()
end)

function ACK_GANG_WARFARE_LIVE_DATA.decode(self, r)
    self.clan_name = r:readString() -- { 帮派名字 }
    self.surplus = r:readInt8Unsigned() -- { 剩余人数 }
    self.max = r:readInt8Unsigned() -- { 帮派参战人数 }
end

-- [40541]比赛开始 -- 帮派战 
ACK_GANG_WARFARE_WAR_START = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GANG_WARFARE_WAR_START
    self:init()
end)

-- [40542]self血量校正 -- 帮派战 
ACK_GANG_WARFARE_SELF_HP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GANG_WARFARE_SELF_HP
    self:init()
end)

function ACK_GANG_WARFARE_SELF_HP.decode(self, r)
    self.hp = r:readInt32Unsigned() -- { 血量校正 }
end

-- [40545]死亡/复活协议 -- 帮派战 
ACK_GANG_WARFARE_DIE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GANG_WARFARE_DIE
    self:init()
end)

function ACK_GANG_WARFARE_DIE.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 类型(见常量:CONST_GANG_WARFARE) }
    self.kill_clan = r:readString() -- { 击杀帮派 }
    self.kill_name = r:readString() -- { 击杀名字 }
    self.time = r:readInt8Unsigned() -- { 复活待机秒数 }
end

-- [40546]复活成功 -- 帮派战 
ACK_GANG_WARFARE_REC_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GANG_WARFARE_REC_SUCCESS
    self:init()
end)

-- [40555]参赛战况信息块 -- 帮派战 
ACK_GANG_WARFARE_PART_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GANG_WARFARE_PART_DATA
    self:init()
end)

function ACK_GANG_WARFARE_PART_DATA.decode(self, r)
    self.clan = r:readString() -- { 帮派名字 }
    self.sum_kill = r:readInt16Unsigned() -- { 帮派击杀人数 }
    self.s_role = r:readInt8Unsigned() -- { 帮派剩余人数 }
    self.clan_lv = r:readInt8Unsigned() -- { 帮派等级 }
    self.s_power = r:readInt32Unsigned() -- { 帮派剩余平均战力 }
end

-- [40565]是否已经阵亡 -- 帮派战 
ACK_GANG_WARFARE_IS_OVER = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_GANG_WARFARE_IS_OVER
    self:init()
end)

function ACK_GANG_WARFARE_IS_OVER.decode(self, r)
    self.state = r:readInt8Unsigned() -- { 0:否 1:是 }
end

-- [41530]成就信息块 -- 成就系统 
ACK_ACHIEVE_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ACHIEVE_MSG
    self:init()
end)

function ACK_ACHIEVE_MSG.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 成就阶段 }
    self.class = r:readInt32Unsigned() -- { 当前完成值 }
    self.state = r:readInt8Unsigned() -- { 领取状态（CONST_ACHIEVE_STATE） }
end

-- [41570]成就角标信息块 -- 成就系统 
ACK_ACHIEVE_MSG_POINTS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ACHIEVE_MSG_POINTS
    self:init()
end)

function ACK_ACHIEVE_MSG_POINTS.decode(self, r)
    self.type = r:readInt16Unsigned() -- { 成就主类 }
    self.number = r:readInt8Unsigned() -- { 成就可领取数量 }
end

-- [41620]界面返回 -- 节日活动-金钱副本 
ACK_COPY_MONEY_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_MONEY_REPLY
    self:init()
end)

function ACK_COPY_MONEY_REPLY.decode(self, r)
    self.times = r:readInt16Unsigned() -- { 剩余挑战次数 }
    self.times_all = r:readInt16Unsigned() -- { 总共挑战次数 }
    self.first = r:readInt8Unsigned() -- { 是否为第一次(1:是) }
end

-- [41635]开始挑战返回 -- 节日活动-金钱副本 
ACK_COPY_MONEY_START_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_MONEY_START_REPLY
    self:init()
end)

-- [51640]挑战结束返回 -- 节日活动-金钱副本 
ACK_COPY_MONEY_OVER_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COPY_MONEY_OVER_REPLY
    self:init()
end)

function ACK_COPY_MONEY_OVER_REPLY.decode(self, r)
    self.harm = r:readInt32Unsigned() -- { 总伤害值 }
    self.money = r:readInt32Unsigned() -- { 可获得铜钱数 }
end

-- [42511]卡片活动状态有变化 -- 收集卡片 
ACK_COLLECT_CARD_STATE_REFRESH = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COLLECT_CARD_STATE_REFRESH
    self:init()
end)

-- [42512]卡片活动开放结果 -- 收集卡片 
ACK_COLLECT_CARD_LIMIT_RESULT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COLLECT_CARD_LIMIT_RESULT
    self:init()
end)

function ACK_COLLECT_CARD_LIMIT_RESULT.decode(self, r)
    self.result = r:readBoolean() -- { true:有|false:无 }
    self.seconds_s = r:readInt32Unsigned() -- { 开始日期时间戳 }
    self.seconds_e = r:readInt32Unsigned() -- { 结束日期时间戳 }
end

-- [42526]物品信息块 -- 收集卡片 
ACK_COLLECT_CARD_XXX2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COLLECT_CARD_XXX2
    self:init()
end)

function ACK_COLLECT_CARD_XXX2.decode(self, r)
    self.goods_id = r:readInt16Unsigned() -- { 物品ID }
    self.count = r:readInt16Unsigned() -- { 物品数量 }
end

-- [42528]虚拟货币信息块 -- 收集卡片 
ACK_COLLECT_CARD_XXX3 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COLLECT_CARD_XXX3
    self:init()
end)

function ACK_COLLECT_CARD_XXX3.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 货币类型 }
    self.value = r:readInt32Unsigned() -- { 货币值 }
end

-- [42532]兑换成功 -- 收集卡片 
ACK_COLLECT_CARD_EXCHANGE_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COLLECT_CARD_EXCHANGE_OK
    self:init()
end)

-- [42542]兑换所需金元 -- 收集卡片 
ACK_COLLECT_CARD_COST_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_COLLECT_CARD_COST_BACK
    self:init()
end)

function ACK_COLLECT_CARD_COST_BACK.decode(self, r)
    self.cost = r:readInt32Unsigned() -- { 兑换所需金元 }
end

-- [43520]进入成功 -- 跨服战 
ACK_STRIDE_ENJOY_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_STRIDE_ENJOY_BACK
    self:init()
end)

function ACK_STRIDE_ENJOY_BACK.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 1:问鼎天宫 2:凌霄 3 :独尊 }
end

-- [43542]排行榜数据块 -- 跨服战 
ACK_STRIDE_HAIG_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_STRIDE_HAIG_DATA
    self:init()
end)

function ACK_STRIDE_HAIG_DATA.decode(self, r)
    self.rank = r:readInt8Unsigned() -- { 排名 }
    self.sid = r:readInt16Unsigned() -- { 服务器id }
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
    self.name = r:readString() -- { 玩家名字 }
    self.arg = r:readInt32Unsigned() -- { 战斗积分 }
    self.lv = r:readInt16Unsigned() -- { 等级 }
end

-- [43543]个人排名信息 -- 跨服战 
ACK_STRIDE_SELF_HAIG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_STRIDE_SELF_HAIG
    self:init()
end)

function ACK_STRIDE_SELF_HAIG.decode(self, r)
    self.rank = r:readInt32Unsigned() -- { 当前排名 }
    self.zrank = r:readInt32Unsigned() -- { 昨日排名 }
    self.group = r:readInt8Unsigned() -- { 级别组 }
    self.calculus = r:readInt32Unsigned() -- { 当前积分 }
    self.zcalculus = r:readInt32Unsigned() -- { 昨日积分 }
    self.power = r:readInt32Unsigned() -- { 战斗力 }
    self.is_buy = r:readInt8Unsigned() -- { 越级 0:未买 1:已买 }
end

-- [43551]数据块 -- 跨服战 
ACK_STRIDE_RANK_2_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_STRIDE_RANK_2_DATA
    self:init()
end)

function ACK_STRIDE_RANK_2_DATA.decode(self, r)
    self.rank = r:readInt32Unsigned() -- { 排名 }
    self.sid = r:readInt16Unsigned() -- { 服务器ID }
    self.uid = r:readInt32Unsigned() -- { 玩家UID }
    self.name = r:readUTF() -- { 玩家姓名 }
    self.lv = r:readInt16Unsigned() -- { 玩家等级 }
    self.sex = r:readInt8Unsigned() -- { 性别 }
    self.pro = r:readInt8Unsigned() -- { 职业 }
    self.is_war = r:readInt8Unsigned() -- { 1:可挑战 0:不能挑战 2:未预亮 }
    self.power = r:readInt32Unsigned() -- { 战斗力 }
end

-- [43554]领取宝箱成功 -- 跨服战 
ACK_STRIDE_AWARD_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_STRIDE_AWARD_OK
    self:init()
end)

function ACK_STRIDE_AWARD_OK.decode(self, r)
    self.cenci = r:readInt8Unsigned() -- { 编号 }
end

-- [43556]战报日志信息块 -- 跨服战 
ACK_STRIDE_WAR_2_LOGS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_STRIDE_WAR_2_LOGS
    self:init()
end)

function ACK_STRIDE_WAR_2_LOGS.decode(self, r)
    self.sid = r:readInt16Unsigned() -- { 玩家服务器ID }
    self.uid = r:readInt32Unsigned() -- { 玩家UID }
    self.name = r:readUTF() -- { 玩家名字 }
    self.t_sid = r:readInt16Unsigned() -- { 被挑战玩家服务器id }
    self.t_uid = r:readInt32Unsigned() -- { 被挑战玩家Uid }
    self.t_name = r:readUTF() -- { 被挑战玩家名字 }
    self.res = r:readInt8Unsigned() -- { 结果 }
    self.jf = r:readInt16Unsigned() -- { 获得积分 0:不显示 }
end

-- [43625]战力返回 -- 跨服战 
ACK_STRIDE_POWER_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_STRIDE_POWER_BACK
    self:init()
end)

function ACK_STRIDE_POWER_BACK.decode(self, r)
    self.power = r:readInt32Unsigned() -- { 最新战力 }
end

-- [43637]挑战结果--决战凌霄 -- 跨服战 
ACK_STRIDE_SUPERIOR_RS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_STRIDE_SUPERIOR_RS
    self:init()
end)

function ACK_STRIDE_SUPERIOR_RS.decode(self, r)
    self.rs = r:readInt8Unsigned() -- { 1:胜利0:失败 }
    self.gold = r:readInt32Unsigned() -- { 获得铜钱 }
    self.rank = r:readInt16Unsigned() -- { 挑战后的排名 }
    self.up = r:readInt16Unsigned() -- { 上升排名 }
end

-- [43655]越级购买成功 -- 跨服战 
ACK_STRIDE_BUY_CG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_STRIDE_BUY_CG
    self:init()
end)

-- [43670]购买成功 -- 跨服战 
ACK_STRIDE_BUY_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_STRIDE_BUY_OK
    self:init()
end)

function ACK_STRIDE_BUY_OK.decode(self, r)
    self.count = r:readInt16Unsigned() -- { 返回剩余次数 }
    self.buy_num = r:readInt16Unsigned() -- { 剩余购买次数 }
end

-- [44525]排行榜信息块 -- 御前科举 
ACK_KEJU_XXX_RANK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_KEJU_XXX_RANK
    self:init()
end)

function ACK_KEJU_XXX_RANK.decode(self, r)
    self.rank = r:readInt8Unsigned() -- { 名次 }
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.name = r:readString() -- { 玩家名字 }
    self.score = r:readInt8Unsigned() -- { 得分 }
    self.times = r:readInt16Unsigned() -- { 耗时 }
    self.reward_rank = r:readInt32Unsigned() -- { 所获奖励 }
end

-- [44540]可选答案信息 -- 御前科举 
ACK_KEJU_MSG_OPTIONS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_KEJU_MSG_OPTIONS
    self:init()
end)

function ACK_KEJU_MSG_OPTIONS.decode(self, r)
    self.answer = r:readInt8Unsigned() -- { 答案选项 }
end

-- [44560]开始答题返回 -- 御前科举 
ACK_KEJU_START_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_KEJU_START_REPLY
    self:init()
end)

function ACK_KEJU_START_REPLY.decode(self, r)
    self.num = r:readInt8Unsigned() -- { 当前第几题 }
    self.id = r:readInt16Unsigned() -- { 问题ID }
    self.time = r:readInt32Unsigned() -- { 剩余答题时间 }
    self.num_right = r:readInt8Unsigned() -- { 正确题目数量 }
end

-- [44565]答题返回 -- 御前科举 
ACK_KEJU_ANSWER_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_KEJU_ANSWER_REPLY
    self:init()
end)

function ACK_KEJU_ANSWER_REPLY.decode(self, r)
    self.choose = r:readInt8Unsigned() -- { 玩家选择答案 }
    self.right = r:readInt8Unsigned() -- { 正确答案 }
    self.next = r:readInt16Unsigned() -- { 下一个题目ID }
end

-- [44575]算卦去错返回 -- 御前科举 
ACK_KEJU_OUT_WRONG_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_KEJU_OUT_WRONG_REPLY
    self:init()
end)

function ACK_KEJU_OUT_WRONG_REPLY.decode(self, r)
    self.times = r:readInt8Unsigned() -- { 剩余算卦次数 }
    self.out_answer = r:readInt8Unsigned() -- { 去错的答案 }
end

-- [44585]贿赂考官返回 -- 御前科举 
ACK_KEJU_BRIBE_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_KEJU_BRIBE_REPLY
    self:init()
end)

function ACK_KEJU_BRIBE_REPLY.decode(self, r)
    self.times = r:readInt8Unsigned() -- { 剩余贿赂次数 }
    self.answer = r:readInt8Unsigned() -- { 正确答案 }
end

-- [44630]任务信息块 -- 悬赏任务 
ACK_REWARD_TASK_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_TASK_DATA
    self:init()
end)

function ACK_REWARD_TASK_DATA.decode(self, r)
    self.idx = r:readInt8Unsigned() -- { 唯一索引 }
    self.task_id = r:readInt16Unsigned() -- { 任务id }
    self.gold = r:readInt32Unsigned() -- { 奖励铜钱 }
    self.exp = r:readInt32Unsigned() -- { 奖励经验 }
    self.state = r:readInt8Unsigned() -- { 0:未接受|1:接受未完成 | 2 : 已完成 }
    self.value = r:readInt16Unsigned() -- { 完成值 }
end

-- [44645]接受成功 -- 悬赏任务 
ACK_REWARD_TASK_ACCEPT_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_TASK_ACCEPT_BACK
    self:init()
end)

function ACK_REWARD_TASK_ACCEPT_BACK.decode(self, r)
    self.idx = r:readInt8Unsigned() -- { 索引 }
end

-- [44690]任务完成 -- 悬赏任务 
ACK_REWARD_TASK_FINISH = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_REWARD_TASK_FINISH
    self:init()
end)

function ACK_REWARD_TASK_FINISH.decode(self, r)
    self.idx = r:readInt8Unsigned() -- { 索引 }
end

-- [44835]cd冷却中 -- 跨服竞技场 
ACK_CROSS_CD_ONLINE_SEC = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CROSS_CD_ONLINE_SEC
    self:init()
end)

function ACK_CROSS_CD_ONLINE_SEC.decode(self, r)
    self.rmb = r:readInt16Unsigned() -- { 需花费元宝 }
    self.surplus = r:readInt8Unsigned() -- { 剩余挑战次数 }
end

-- [44840]验证通过 -- 跨服竞技场 
ACK_CROSS_THROUGH = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CROSS_THROUGH
    self:init()
end)

function ACK_CROSS_THROUGH.decode(self, r)
    self.key = r:readString() -- { 验证通过key }
end

-- [44860]挑战奖励 -- 跨服竞技场 
ACK_CROSS_WAR_REWARD = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CROSS_WAR_REWARD
    self:init()
end)

function ACK_CROSS_WAR_REWARD.decode(self, r)
    self.res = r:readInt8Unsigned() -- { 0:失败 1:成功 }
    self.gold = r:readInt32Unsigned() -- { 获得铜钱 }
    self.renown = r:readInt32Unsigned() -- { 获得声望 }
end

-- [44891]高手信息 -- 跨服竞技场 
ACK_CROSS_RANK_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CROSS_RANK_XXX
    self:init()
end)

function ACK_CROSS_RANK_XXX.decode(self, r)
    self.rank = r:readInt16Unsigned() -- { 排名 }
    self.sid = r:readInt32Unsigned() -- { 服务器id }
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
    self.name = r:readString() -- { 玩家名字 }
    self.lv = r:readInt16Unsigned() -- { 玩家等级 }
    self.power = r:readInt32Unsigned() -- { 战力 }
end

-- [44906]询价返回 -- 跨服竞技场 
ACK_CROSS_ASK_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CROSS_ASK_BACK
    self:init()
end)

function ACK_CROSS_ASK_BACK.decode(self, r)
    self.buy_count = r:readInt16Unsigned() -- { 购买次数 }
end

-- [44920]购买成功 -- 跨服竞技场 
ACK_CROSS_BUY_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CROSS_BUY_OK
    self:init()
end)

function ACK_CROSS_BUY_OK.decode(self, r)
    self.scount = r:readInt16Unsigned() -- { 剩余次数 }
end

-- [44950]奖励倒计时 -- 跨服竞技场 
ACK_CROSS_REWARD_TIME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CROSS_REWARD_TIME
    self:init()
end)

function ACK_CROSS_REWARD_TIME.decode(self, r)
    self.times = r:readInt32Unsigned() -- { 倒计时 }
    self.gold = r:readInt32Unsigned() -- { 铜钱 }
    self.renown = r:readInt32Unsigned() -- { 声望 }
end

-- [44970]清除成功 -- 跨服竞技场 
ACK_CROSS_CLEAN_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CROSS_CLEAN_OK
    self:init()
end)

-- [45620]界面请求返回 -- 活动-阵营战 
ACK_CAMPWAR_OK_ASK_WAR = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CAMPWAR_OK_ASK_WAR
    self:init()
end)

function ACK_CAMPWAR_OK_ASK_WAR.decode(self, r)
    self.time = r:readInt16Unsigned() -- { 活动时长（s） }
    self.sid = r:readInt16Unsigned() -- { 服务器Id }
    self.uid = r:readInt32Unsigned() -- { 玩家Uid }
    self.camp = r:readInt8Unsigned() -- { 玩家阵营 }
end

-- [45630]各种倒计时 -- 活动-阵营战 
ACK_CAMPWAR_D_TIME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CAMPWAR_D_TIME
    self:init()
end)

function ACK_CAMPWAR_D_TIME.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 类型： }
    self.value = r:readInt16Unsigned() -- { 数值 }
end

-- [45640]阵营积分数据 -- 活动-阵营战 
ACK_CAMPWAR_CAMP_POINTS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CAMPWAR_CAMP_POINTS
    self:init()
end)

function ACK_CAMPWAR_CAMP_POINTS.decode(self, r)
    self.camp_human = r:readInt32Unsigned() -- { 阵营积分--人 }
    self.camp_god = r:readInt32Unsigned() -- { 阵营积分--仙 }
    self.camp_magic = r:readInt32Unsigned() -- { 阵营积分--魔 }
end

-- [45655]连胜玩家信息块 -- 活动-阵营战 
ACK_CAMPWAR_PLY_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CAMPWAR_PLY_DATA
    self:init()
end)

function ACK_CAMPWAR_PLY_DATA.decode(self, r)
    self.sid = r:readInt16Unsigned() -- { 服务器Id }
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
    self.name = r:readString() -- { 名字 }
    self.name_color = r:readInt8Unsigned() -- { 名字颜色 }
    self.sex = r:readInt8Unsigned() -- { 性别 }
    self.pro = r:readInt8Unsigned() -- { 职业 }
    self.count = r:readInt16Unsigned() -- { 连胜次数 }
end

-- [45670]个人战绩 -- 活动-阵营战 
ACK_CAMPWAR_SELF_WAR = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CAMPWAR_SELF_WAR
    self:init()
end)

function ACK_CAMPWAR_SELF_WAR.decode(self, r)
    self.wins = r:readInt16Unsigned() -- { 战胜总次数 }
    self.fails = r:readInt16Unsigned() -- { 战败总次数 }
    self.wars_now = r:readInt8Unsigned() -- { 当前连胜次数 }
    self.wars_max = r:readInt8Unsigned() -- { 最大连胜次数 }
    self.integral = r:readInt32Unsigned() -- { 个人积分 }
end

-- [45695]属性加成信息块 -- 活动-阵营战 
ACK_CAMPWAR_ATTR_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CAMPWAR_ATTR_MSG
    self:init()
end)

function ACK_CAMPWAR_ATTR_MSG.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 类型：CONST_ATTR_** }
    self.value = r:readInt16Unsigned() -- { 数值5000=50% }
end

-- [45757]奖励数据块 -- 活动-阵营战 
ACK_CAMPWAR_REWARDS_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CAMPWAR_REWARDS_DATA
    self:init()
end)

function ACK_CAMPWAR_REWARDS_DATA.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 虚拟物品类型：CONST_CURRENCY_* }
    self.value = r:readInt32Unsigned() -- { 数量 }
end

-- [45760]玩家死亡 -- 活动-阵营战 
ACK_CAMPWAR_DIE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CAMPWAR_DIE
    self:init()
end)

function ACK_CAMPWAR_DIE.decode(self, r)
    self.count = r:readInt16Unsigned() -- { 第几次复活 }
    self.rmb = r:readInt16Unsigned() -- { 需花费的金元数量 }
end

-- [45780]复活成功（废） -- 活动-阵营战 
ACK_CAMPWAR_OK_RELIVE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CAMPWAR_OK_RELIVE
    self:init()
end)

-- [45850]活动结束 -- 活动-阵营战 
ACK_CAMPWAR_CAMP_END = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CAMPWAR_CAMP_END
    self:init()
end)

-- [46015]抽奖信息块返回 -- 每日转盘 
ACK_WHEEL_LOTTERY_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WHEEL_LOTTERY_MSG
    self:init()
end)

function ACK_WHEEL_LOTTERY_MSG.decode(self, r)
    self.name = r:readString() -- { 玩家名 }
    self.id = r:readInt16Unsigned() -- { 物品唯一id }
end

-- [46022]抽奖信息返回 -- 每日转盘 
ACK_WHEEL_LOTTERY_REP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WHEEL_LOTTERY_REP
    self:init()
end)

function ACK_WHEEL_LOTTERY_REP.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 物品唯一id }
end

-- [46230]战役数据信息块 -- 魔王副本 
ACK_FIEND_MSG_BATTLE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FIEND_MSG_BATTLE
    self:init()
end)

function ACK_FIEND_MSG_BATTLE.decode(self, r)
    self.copy_id = r:readInt16Unsigned() -- { 章节ID }
    self.times = r:readInt16Unsigned() -- { 剩余可进入次数 }
    self.is_pass = r:readInt8Unsigned() -- { 是否通过 }
    self.buy_times = r:readInt16Unsigned() -- { 已经购买次数 }
end

-- [46260]刷新魔王副本返回 -- 魔王副本 
ACK_FIEND_FRESH_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FIEND_FRESH_BACK
    self:init()
end)

function ACK_FIEND_FRESH_BACK.decode(self, r)
    self.copy_id = r:readInt16Unsigned() -- { 副本ID }
    self.times = r:readInt16Unsigned() -- { 剩余可进入次数 }
end

-- [46280]战役数据信息块(new -- 魔王副本 
ACK_FIEND_MSG_BATTLE_NEW = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FIEND_MSG_BATTLE_NEW
    self:init()
end)

function ACK_FIEND_MSG_BATTLE_NEW.decode(self, r)
    self.copy_id = r:readInt16Unsigned() -- { 章节ID }
    self.times = r:readInt16Unsigned() -- { 剩余可进入次数 }
    self.is_pass = r:readInt8Unsigned() -- { 是否通过 }
    self.eva = r:readInt8Unsigned() -- { 评价 }
end

-- [47215]物品信息块 -- 珍宝阁 
ACK_TREASURE_GOODSMSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TREASURE_GOODSMSG
    self:init()
end)

function ACK_TREASURE_GOODSMSG.decode(self, r)
    self.goods_id = r:readInt32Unsigned() -- { 物品id }
    self.state = r:readInt8Unsigned() -- { 打造状态1：成功|0：没打造完 }
end

-- [47230]打造成功 -- 珍宝阁 
ACK_TREASURE_SUCCESS_DZ = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TREASURE_SUCCESS_DZ
    self:init()
end)

-- [48203]卦象信息块 -- 八卦系统 
ACK_SYS_DOUQI_DOUQI_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYS_DOUQI_DOUQI_DATA
    self:init()
end)

function ACK_SYS_DOUQI_DOUQI_DATA.decode(self, r)
    self.lan_id = r:readInt8Unsigned() -- { 卦象栏编号1-8 }
    self.dq_id = r:readInt32Unsigned() -- { 卦象唯一ID }
    self.dq_type = r:readInt16Unsigned() -- { 卦象类型ID }
    self.dq_lv = r:readInt8Unsigned() -- { 卦象等级 }
    self.dq_exp = r:readInt32Unsigned() -- { 卦象经验 }
    self.is_lock = r:readInt8Unsigned() -- { 是否锁定 0未锁| 1锁定} }
end

-- [48220]占卦界面信息返回 -- 八卦系统 
ACK_SYS_DOUQI_OK_GRASP_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYS_DOUQI_OK_GRASP_DATA
    self:init()
end)

function ACK_SYS_DOUQI_OK_GRASP_DATA.decode(self, r)
    self.type_grasp = r:readInt8Unsigned() -- { 当前占卦位置 }
    self.ok_times = r:readInt16Unsigned() -- { 已元宝占卦次数 }
    self.all_times = r:readInt16Unsigned() -- { 总计可元宝占卦次数 }
    self.adam_war = r:readInt32Unsigned() -- { 战魂值 }
end

-- [48237]玩家vip等级信息 -- 八卦系统 
ACK_SYS_DOUQI_VIP_LV = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYS_DOUQI_VIP_LV
    self:init()
end)

function ACK_SYS_DOUQI_VIP_LV.decode(self, r)
    self.vip = r:readInt8Unsigned() -- { vip等级 }
    self.lv = r:readInt16Unsigned() -- { 人物等级 }
end

-- [48295]被吞者位置ID列表 -- 八卦系统 
ACK_SYS_DOUQI_LAN_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYS_DOUQI_LAN_MSG
    self:init()
end)

function ACK_SYS_DOUQI_LAN_MSG.decode(self, r)
    self.lan_id = r:readInt8Unsigned() -- { 仓库位置ID }
end

-- [48410]升级卦阵返回 -- 八卦系统 
ACK_SYS_DOUQI_STORAG_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYS_DOUQI_STORAG_BACK
    self:init()
end)

function ACK_SYS_DOUQI_STORAG_BACK.decode(self, r)
    self.role_id = r:readInt16Unsigned() -- { 0:自己|1 :伙伴 }
    self.lan_id = r:readInt8Unsigned() -- { 位置id }
    self.lan_lv = r:readInt16Unsigned() -- { 等级 }
end

-- [49201]日常任务数据返回 -- 日常任务 
ACK_DAILY_TASK_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DAILY_TASK_DATA
    self:init()
end)

function ACK_DAILY_TASK_DATA.decode(self, r)
    self.node = r:readInt16Unsigned() -- { 任务节点 }
    self.left = r:readInt8Unsigned() -- { 次数 }
    self.value = r:readInt8Unsigned() -- { 事件当前值 }
    self.state = r:readInt8Unsigned() -- { 0:未完成|1:已完成 }
    self.vip_count = r:readInt8Unsigned() -- { 剩余的刷新次数 }
    self.give_exp = r:readInt32Unsigned() -- { 可获经验 }
end

-- [49206]日常任务当前轮次 -- 日常任务 
ACK_DAILY_TASK_TURN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DAILY_TASK_TURN
    self:init()
end)

function ACK_DAILY_TASK_TURN.decode(self, r)
    self.turn = r:readInt16Unsigned() -- { 当前已经刷新次数 }
end

-- [50220]次数返回 -- 翻翻乐 
ACK_FLSH_TIMES_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FLSH_TIMES_REPLY
    self:init()
end)

function ACK_FLSH_TIMES_REPLY.decode(self, r)
    self.times = r:readInt8Unsigned() -- { 剩余次数 }
    self.times1 = r:readInt16Unsigned() -- { 已换牌次数 }
    self.is_get = r:readInt8Unsigned() -- { 是否获得 }
end

-- [50245]牌信息块 -- 翻翻乐 
ACK_FLSH_MSG_PAI_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FLSH_MSG_PAI_XXX
    self:init()
end)

function ACK_FLSH_MSG_PAI_XXX.decode(self, r)
    self.pos = r:readInt8Unsigned() -- { 位置 }
    self.num = r:readInt8Unsigned() -- { 牌大小 }
end

-- [50290]奖励OK -- 翻翻乐 
ACK_FLSH_REWARD_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FLSH_REWARD_OK
    self:init()
end)

function ACK_FLSH_REWARD_OK.decode(self, r)
    self.sz_num = r:readInt16Unsigned() -- { 顺子数量 }
    self.same_num = r:readInt16Unsigned() -- { 相同数量 }
    self.dz_num = r:readInt16Unsigned() -- { 对子数量 }
end

-- [50295]奖励返回 -- 翻翻乐 
ACK_FLSH_FLSH_REWARD_POS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FLSH_FLSH_REWARD_POS
    self:init()
end)

function ACK_FLSH_FLSH_REWARD_POS.decode(self, r)
    self.pos = r:readInt8Unsigned() -- { 位置 }
end

-- [50405]领取等级及状态 -- 人物升级奖励 
ACK_LV_REWARD_LV_STATE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_LV_REWARD_LV_STATE
    self:init()
end)

function ACK_LV_REWARD_LV_STATE.decode(self, r)
    self.lv = r:readInt8Unsigned() -- { 领取的等级 }
    self.state = r:readInt8Unsigned() -- { 状态 1不能领取，2可以领取 }
    self.autoo = r:readInt8Unsigned() -- { 是否自动 }
end

-- [50710]牌位置与内容 -- 对牌 
ACK_MATCH_CARD_CARD_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MATCH_CARD_CARD_MSG
    self:init()
end)

function ACK_MATCH_CARD_CARD_MSG.decode(self, r)
    self.pos = r:readInt8Unsigned() -- { 位置 }
    self.is_open = r:readInt8Unsigned() -- { 是否翻开 }
    self.type = r:readInt8Unsigned() -- { 类型 }
end

-- [50720]对牌回复 -- 对牌 
ACK_MATCH_CARD_MATCH_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MATCH_CARD_MATCH_REPLY
    self:init()
end)

function ACK_MATCH_CARD_MATCH_REPLY.decode(self, r)
    self.bool = r:readInt8Unsigned() -- { 0为不对，1为成功 }
    self.step = r:readInt8Unsigned() -- { 已翻牌次数 }
    self.times = r:readInt8Unsigned() -- { 剩余翻牌次数 }
end

-- [50730]偷看回复 -- 对牌 
ACK_MATCH_CARD_LOOK_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MATCH_CARD_LOOK_REPLY
    self:init()
end)

function ACK_MATCH_CARD_LOOK_REPLY.decode(self, r)
    self.pos = r:readInt8Unsigned() -- { 位置 }
    self.type = r:readInt8Unsigned() -- { 类型 }
end

-- [50735]偷看一对 -- 对牌 
ACK_MATCH_CARD_LOOK_DOUBLE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MATCH_CARD_LOOK_DOUBLE
    self:init()
end)

function ACK_MATCH_CARD_LOOK_DOUBLE.decode(self, r)
    self.pos1 = r:readInt8Unsigned() -- { 位置 }
    self.type1 = r:readInt8Unsigned() -- { 类型 }
    self.pos2 = r:readInt8Unsigned() -- { 位置 }
    self.type2 = r:readInt8Unsigned() -- { 类型 }
end

-- [51220]章节信息 -- 道劫 
ACK_HOOK_CHAP_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HOOK_CHAP_DATA
    self:init()
end)

function ACK_HOOK_CHAP_DATA.decode(self, r)
    self.chap_id = r:readInt16Unsigned() -- { 章节id }
end

-- [51225]副本信息 -- 道劫 
ACK_HOOK_COPY_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HOOK_COPY_DATA
    self:init()
end)

function ACK_HOOK_COPY_DATA.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 副本id }
end

-- [51235]请求副本信息返回 -- 道劫 
ACK_HOOK_MSG_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HOOK_MSG_BACK
    self:init()
end)

function ACK_HOOK_MSG_BACK.decode(self, r)
    self.flag = r:readInt8Unsigned() -- { 0-条件不足，1达到条件未通关，2通关 }
    self.value = r:readInt32Unsigned() -- { 条件值 }
end

-- [52115]穿戴神羽返回 -- 神羽 
ACK_FEATHER_DRESS_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FEATHER_DRESS_REPLY
    self:init()
end)

function ACK_FEATHER_DRESS_REPLY.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 当前穿戴神羽ID 0:无 }
end

-- [52130]神羽信息块 -- 神羽 
ACK_FEATHER_XXX_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FEATHER_XXX_DATA
    self:init()
end)

function ACK_FEATHER_XXX_DATA.decode(self, r)
    self.id_feather = r:readInt16Unsigned() -- { 神羽ID }
    self.lv = r:readInt16Unsigned() -- { 神羽等级 }
    self.exp = r:readInt32Unsigned() -- { 神羽当前经验值 }
    self.quality = r:readInt16Unsigned() -- { 神羽品阶 }
    self.powerful = r:readInt32Unsigned() -- { 神羽战斗力 }
end

-- [52140]神羽升级经验值飘字 -- 神羽 
ACK_FEATHER_EXP_ADD = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FEATHER_EXP_ADD
    self:init()
end)

function ACK_FEATHER_EXP_ADD.decode(self, r)
    self.exp = r:readInt16Unsigned() -- { 增加经验值 }
end

-- [52180]神羽技能 -- 神羽 
ACK_FEATHER_SKILL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FEATHER_SKILL
    self:init()
end)

function ACK_FEATHER_SKILL.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 神羽ID }
    self.lv = r:readInt16Unsigned() -- { 神羽等级 }
end

-- [52213]属性信息块 -- 神兵系统 
ACK_MAGIC_EQUIP_MSG_ATTR = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_MSG_ATTR
    self:init()
end)

function ACK_MAGIC_EQUIP_MSG_ATTR.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 属性类型 }
    self.attr = r:readInt32Unsigned() -- { 属性值 }
end

-- [52218]洗练属性信息块 -- 神兵系统 
ACK_MAGIC_EQUIP_MSG_WASH_ATTR = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_MSG_WASH_ATTR
    self:init()
end)

function ACK_MAGIC_EQUIP_MSG_WASH_ATTR.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 属性类型 }
    self.attr = r:readInt16Unsigned() -- { 属性值 }
    self.max = r:readInt16Unsigned() -- { 属性最大值 }
end

-- [52219]洗练属性信息块2 -- 神兵系统 
ACK_MAGIC_EQUIP_MSG_WASH_ATTR2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_MSG_WASH_ATTR2
    self:init()
end)

function ACK_MAGIC_EQUIP_MSG_WASH_ATTR2.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 属性类型 }
    self.attr = r:readInt16() -- { 属性值 }
end

-- [52240]强化返回 -- 神兵系统 
ACK_MAGIC_EQUIP_ENHANCED_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_ENHANCED_REPLY
    self:init()
end)

function ACK_MAGIC_EQUIP_ENHANCED_REPLY.decode(self, r)
    self.streng = r:readInt8Unsigned() -- { 强化等级 }
    self.result = r:readInt8Unsigned() -- { 强化结果（0失败/1成功） }
end

-- [52243]进阶返回 -- 神兵系统 
ACK_MAGIC_EQUIP_ADVANCE_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_ADVANCE_REPLY
    self:init()
end)

function ACK_MAGIC_EQUIP_ADVANCE_REPLY.decode(self, r)
    self.streng = r:readInt8Unsigned() -- { 强化等级 }
end

-- [52245]洗练返回 -- 神兵系统 
ACK_MAGIC_EQUIP_WASH_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_WASH_REPLY
    self:init()
end)

function ACK_MAGIC_EQUIP_WASH_REPLY.decode(self, r)
    self.streng = r:readInt8Unsigned() -- { 强化等级 }
end

-- [52260]神器强化所需要钱数返回 -- 神兵系统 
ACK_MAGIC_EQUIP_NEED_MONEY_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_NEED_MONEY_REPLY
    self:init()
end)

function ACK_MAGIC_EQUIP_NEED_MONEY_REPLY.decode(self, r)
    self.bless_rmb = r:readInt16Unsigned() -- { 祝福石钻石数 }
    self.protect_rmb = r:readInt16Unsigned() -- { 保护石钻石数 }
    self.total_rmb = r:readInt16Unsigned() -- { 总共钻石数 }
end

-- [52315]材料信息块 -- 神兵系统 
ACK_MAGIC_EQUIP_MSG_ITEM_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_MSG_ITEM_XXX
    self:init()
end)

function ACK_MAGIC_EQUIP_MSG_ITEM_XXX.decode(self, r)
    self.item_id = r:readInt16Unsigned() -- { 材料id }
    self.count = r:readInt16Unsigned() -- { 数量 }
end

-- [52320]属性值 -- 神兵系统 
ACK_MAGIC_EQUIP_ATTR = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_ATTR
    self:init()
end)

function ACK_MAGIC_EQUIP_ATTR.decode(self, r)
    self.type = r:readInt16Unsigned() -- { 类型 }
    self.type_value = r:readInt16Unsigned() -- { 类型值 }
end

-- [52350]神器信息块 -- 神兵系统 
ACK_MAGIC_EQUIP_MSG_MAGICS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_MSG_MAGICS
    self:init()
end)

function ACK_MAGIC_EQUIP_MSG_MAGICS.decode(self, r)
    self.magic_id = r:readInt16Unsigned() -- { 神器ID }
end

-- [52380]返回当前身上时装和翅膀 -- 神兵系统 
ACK_MAGIC_EQUIP_REPLY_SKINS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_REPLY_SKINS
    self:init()
end)

function ACK_MAGIC_EQUIP_REPLY_SKINS.decode(self, r)
    self.id_wind = r:readInt16Unsigned() -- { 翅膀ID }
    self.id_clothes = r:readInt16Unsigned() -- { 时装ID }
end

-- [52390]幻化成功 -- 神兵系统 
ACK_MAGIC_EQUIP_HUANHUA_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_HUANHUA_SUCCESS
    self:init()
end)

-- [52430]卸下神兵成功 -- 神兵系统 
ACK_MAGIC_EQUIP_OFF_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAGIC_EQUIP_OFF_OK
    self:init()
end)

-- [53223]领取信息块 -- 三国基金 
ACK_PRIVILEGE_MSG_GET = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_PRIVILEGE_MSG_GET
    self:init()
end)

function ACK_PRIVILEGE_MSG_GET.decode(self, r)
    self.type_id = r:readInt8Unsigned() -- { 类型id }
    self.day = r:readInt8Unsigned() -- { 第几天 }
    self.state = r:readInt8Unsigned() -- { 状态是否领取(1:已经领取;0:未领取) }
end

-- [53225]全部投资信息块 -- 三国基金 
ACK_PRIVILEGE_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_PRIVILEGE_MSG
    self:init()
end)

function ACK_PRIVILEGE_MSG.decode(self, r)
    self.type_id = r:readInt16Unsigned() -- { 类型id（const_privilege_type_*） }
end

-- [53240]开启/领取基金返回 -- 三国基金 
ACK_PRIVILEGE_OPEN_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_PRIVILEGE_OPEN_CB
    self:init()
end)

function ACK_PRIVILEGE_OPEN_CB.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 2 平民 ， 3土豪 }
end

-- [53251]领取成功返回 -- 三国基金 
ACK_PRIVILEGE_GET_REWARDS_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_PRIVILEGE_GET_REWARDS_CB
    self:init()
end)

function ACK_PRIVILEGE_GET_REWARDS_CB.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 2 平民 ， 3土豪 }
    self.day = r:readInt8Unsigned() -- { 日期 }
end

-- [54230]洞府boss挑战状态 -- 帮派BOSS 
ACK_CLAN_BOSS_STATE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_CLAN_BOSS_STATE
    self:init()
end)

function ACK_CLAN_BOSS_STATE.decode(self, r)
    self.state = r:readInt8Unsigned() -- { 0:不可挑战 1:可以 2:结束 }
end

-- [54830]报名信息块 -- 三界争锋 
ACK_WRESTLE_BOOK_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WRESTLE_BOOK_XXX
    self:init()
end)

function ACK_WRESTLE_BOOK_XXX.decode(self, r)
    self.state = r:readInt8Unsigned() -- { 报名状态0可报名1已报名2不可报名 }
end

-- [54840]没有报名信息块 -- 三界争锋 
ACK_WRESTLE_BOOK_NO_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WRESTLE_BOOK_NO_XXX
    self:init()
end)

-- [54855]排名信息块 -- 三界争锋 
ACK_WRESTLE_RANK_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WRESTLE_RANK_XXX
    self:init()
end)

function ACK_WRESTLE_RANK_XXX.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.name = r:readString() -- { 玩家名字 }
    self.powerful = r:readInt32Unsigned() -- { 玩家战斗力 }
    self.win = r:readInt8Unsigned() -- { 赢场数 }
    self.lose = r:readInt8Unsigned() -- { 输场数 }
    self.score = r:readInt8Unsigned() -- { 分数 }
end

-- [54865]决赛详情信息块 -- 三界争锋 
ACK_WRESTLE_FINAL_XXX2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WRESTLE_FINAL_XXX2
    self:init()
end)

function ACK_WRESTLE_FINAL_XXX2.decode(self, r)
    self.index = r:readInt8Unsigned() -- { 位置索引 }
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.name = r:readString() -- { 玩家名字 }
    self.lv = r:readInt16Unsigned() -- { 玩家等级 }
    self.pro = r:readInt8Unsigned() -- { 玩家职业 }
    self.powerful = r:readInt32Unsigned() -- { 玩家战斗力 }
    self.is_fail = r:readInt8Unsigned() -- { 玩家是否失败过 }
    self.fail_turn = r:readInt8Unsigned() -- { 玩家失败轮次 }
end

-- [54880]欢乐竞猜界面返回 -- 三界争锋 
ACK_WRESTLE_REPLY_GUESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WRESTLE_REPLY_GUESS
    self:init()
end)

function ACK_WRESTLE_REPLY_GUESS.decode(self, r)
    self.state = r:readInt8Unsigned() -- { 状态(0未下过注,1已下过注) }
    self.uid_1 = r:readInt32Unsigned() -- { 冠军uid }
    self.name_1 = r:readString() -- { 冠军名字 }
    self.uid_2 = r:readInt32Unsigned() -- { 亚军uid }
    self.name_2 = r:readString() -- { 亚军名字 }
    self.rmb = r:readInt32Unsigned() -- { 已经下注元宝数 }
end

-- [54885]欢乐竞猜总竞猜金额 -- 三界争锋 
ACK_WRESTLE_GUESS_TOTAL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WRESTLE_GUESS_TOTAL
    self:init()
end)

function ACK_WRESTLE_GUESS_TOTAL.decode(self, r)
    self.rmb = r:readInt32Unsigned() -- { 总下注元宝数 }
end

-- [54900]请求报名返回 -- 三界争锋 
ACK_WRESTLE_REPLY_BOOK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WRESTLE_REPLY_BOOK
    self:init()
end)

function ACK_WRESTLE_REPLY_BOOK.decode(self, r)
    self.rank = r:readInt16Unsigned() -- { 竞技场排名 }
end

-- [54910]报名成功返回 -- 三界争锋 
ACK_WRESTLE_BOOK_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WRESTLE_BOOK_SUCCESS
    self:init()
end)

-- [54935]我的比赛返回 -- 三界争锋 
ACK_WRESTLE_REPLY_MY_GAME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WRESTLE_REPLY_MY_GAME
    self:init()
end)

function ACK_WRESTLE_REPLY_MY_GAME.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 对手ID(0为轮空) }
    self.name = r:readString() -- { 对手名字 }
    self.powerful = r:readInt32Unsigned() -- { 对手战斗力 }
    self.pro = r:readInt8Unsigned() -- { 对手职业 }
    self.lv = r:readInt16Unsigned() -- { 对手等级 }
    self.turn = r:readInt8Unsigned() -- { 轮次 }
end

-- [54940]时间倒计时 -- 三界争锋 
ACK_WRESTLE_TIME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WRESTLE_TIME
    self:init()
end)

function ACK_WRESTLE_TIME.decode(self, r)
    self.state = r:readInt8Unsigned() -- { 比赛状态(CONST_WRESTLE_STATE_*) }
    self.time = r:readInt32Unsigned() -- { 时间戳(0不用倒计时) }
    self.state2 = r:readInt8Unsigned() -- { 状态（1，下一轮开始时间，2，本轮结束时间） }
    self.round = r:readInt8Unsigned() -- { 当前轮次 }
end

-- [54950]战斗结束结算 -- 三界争锋 
ACK_WRESTLE_WAR_STATE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WRESTLE_WAR_STATE
    self:init()
end)

function ACK_WRESTLE_WAR_STATE.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 失败玩家uid }
    self.state = r:readInt8Unsigned() -- { 比赛状态(CONST_WRESTLE_STATE_*) }
    self.round = r:readInt8Unsigned() -- { 轮次 }
    self.rank = r:readInt8Unsigned() -- { 名次 }
end

-- [54965]输赢结果信息块 -- 三界争锋 
ACK_WRESTLE_MSG_RES = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_WRESTLE_MSG_RES
    self:init()
end)

function ACK_WRESTLE_MSG_RES.decode(self, r)
    self.result = r:readInt8Unsigned() -- { 1赢0输 }
end

-- [55015]我的比赛返回 -- 独尊三界 
ACK_TXDY_SUPER_REPLY_MY_GAME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TXDY_SUPER_REPLY_MY_GAME
    self:init()
end)

function ACK_TXDY_SUPER_REPLY_MY_GAME.decode(self, r)
    self.sid_mind = r:readInt16Unsigned() -- { 我的服务器ID }
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.name = r:readString() -- { 玩家名字 }
    self.lv = r:readInt16Unsigned() -- { 玩家等级 }
    self.pro = r:readInt8Unsigned() -- { 玩家职业 }
    self.sid = r:readInt16Unsigned() -- { 玩家服务器id }
    self.powerful = r:readInt32Unsigned() -- { 玩家战斗力 }
end

-- [55030]小组信息块 -- 独尊三界 
ACK_TXDY_SUPER_MSG_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TXDY_SUPER_MSG_XXX
    self:init()
end)

function ACK_TXDY_SUPER_MSG_XXX.decode(self, r)
    self.index = r:readInt16Unsigned() -- { 索引 }
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.name = r:readString() -- { 玩家名字 }
    self.pro = r:readInt8Unsigned() -- { 职业 }
    self.powerful = r:readInt32Unsigned() -- { 战斗力 }
    self.sid = r:readInt16Unsigned() -- { 服务器ID }
    self.lv = r:readInt16Unsigned() -- { 等级 }
    self.is_fail = r:readInt8Unsigned() -- { 是否失败过 }
    self.fail_turn = r:readInt8Unsigned() -- { 失败轮次 }
end

-- [55055]结果信息块 -- 独尊三界 
ACK_TXDY_SUPER_MSG_RESULT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TXDY_SUPER_MSG_RESULT
    self:init()
end)

function ACK_TXDY_SUPER_MSG_RESULT.decode(self, r)
    self.flag = r:readInt8Unsigned() -- { 结果(1赢 0输) }
end

-- [55060]各种倒计时 -- 独尊三界 
ACK_TXDY_SUPER_TIME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TXDY_SUPER_TIME
    self:init()
end)

function ACK_TXDY_SUPER_TIME.decode(self, r)
    self.state = r:readInt8Unsigned() -- { 当前比赛状态(const_txdy_super_state_*) }
    self.state2 = r:readInt8Unsigned() -- { 状态（1，下一轮开始时间，2，本轮战斗结束时间） }
    self.time = r:readInt32Unsigned() -- { 时间戳 }
    self.turn = r:readInt8Unsigned() -- { 轮次(0,不显示) }
end

-- [55075]竞猜数据块 -- 独尊三界 
ACK_TXDY_SUPER_GUESS_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TXDY_SUPER_GUESS_XXX
    self:init()
end)

function ACK_TXDY_SUPER_GUESS_XXX.decode(self, r)
    self.rank = r:readInt8Unsigned() -- { 名次 }
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.name = r:readString() -- { 玩家名字 }
    self.sid = r:readInt16Unsigned() -- { 服务器ID }
    self.pebble = r:readInt32Unsigned() -- { 获得水晶数量 }
end

-- [55085]欢乐竞猜下注返回 -- 独尊三界 
ACK_TXDY_SUPER_GUESS_BET_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TXDY_SUPER_GUESS_BET_REPLY
    self:init()
end)

function ACK_TXDY_SUPER_GUESS_BET_REPLY.decode(self, r)
    self.state = r:readInt8Unsigned() -- { 状态(0未下过注,1已下过注) }
    self.uid_1 = r:readInt32Unsigned() -- { 冠军uid }
    self.name_1 = r:readString() -- { 冠军名字 }
    self.uid_2 = r:readInt32Unsigned() -- { 亚军uid }
    self.name_2 = r:readString() -- { 亚军名字 }
    self.rmb = r:readInt32Unsigned() -- { 已经下注元宝数 }
end

-- [55095]欢乐竞猜总竞猜金额 -- 独尊三界 
ACK_TXDY_SUPER_GUESS_TOTAL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TXDY_SUPER_GUESS_TOTAL
    self:init()
end)

function ACK_TXDY_SUPER_GUESS_TOTAL.decode(self, r)
    self.pebble = r:readInt32Unsigned() -- { 总下注水晶数 }
end

-- [55100]战斗结算 -- 独尊三界 
ACK_TXDY_SUPER_WAR_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TXDY_SUPER_WAR_REPLY
    self:init()
end)

function ACK_TXDY_SUPER_WAR_REPLY.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 失败玩家uid }
    self.name = r:readString() -- { 失败玩家名字 }
    self.state = r:readInt8Unsigned() -- { 当前比赛状态(const_txdy_super_state_*) }
    self.turn = r:readInt8Unsigned() -- { 轮次 }
    self.rank = r:readInt8Unsigned() -- { 名次(1为最终赢家) }
end

-- [55125]请求三界界主返回 -- 独尊三界 
ACK_TXDY_SUPER_REPLY_FIRST = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_TXDY_SUPER_REPLY_FIRST
    self:init()
end)

function ACK_TXDY_SUPER_REPLY_FIRST.decode(self, r)
    self.name = r:readString() -- { 界主名字 }
end

-- [55340]技能信息块 -- 一骑当千 
ACK_THOUSAND_MSG_SKILL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_THOUSAND_MSG_SKILL
    self:init()
end)

function ACK_THOUSAND_MSG_SKILL.decode(self, r)
    self.skill_id = r:readInt16Unsigned() -- { 技能ID }
end

-- [55360]购买页面返回 -- 一骑当千 
ACK_THOUSAND_REPLY_BUY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_THOUSAND_REPLY_BUY
    self:init()
end)

function ACK_THOUSAND_REPLY_BUY.decode(self, r)
    self.times = r:readInt8Unsigned() -- { 剩余购买次数 }
    self.rmb = r:readInt16Unsigned() -- { 购买次数所需元宝数 }
end

-- [55380]购买成功返回 -- 一骑当千 
ACK_THOUSAND_BUY_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_THOUSAND_BUY_SUCCESS
    self:init()
end)

function ACK_THOUSAND_BUY_SUCCESS.decode(self, r)
    self.times = r:readInt8Unsigned() -- { 剩余次数 }
end

-- [55410]是否为新纪录 -- 一骑当千 
ACK_THOUSAND_NEW_RECORD = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_THOUSAND_NEW_RECORD
    self:init()
end)

function ACK_THOUSAND_NEW_RECORD.decode(self, r)
    self.flag = r:readInt8Unsigned() -- { 1是0否 }
    self.harm = r:readInt32Unsigned() -- { 总共伤害 }
    self.time = r:readInt16Unsigned() -- { 消耗时间 }
    self.id = r:readInt8Unsigned() -- { 评分ID }
end

-- [55460]排行榜信息块 -- 一骑当千 
ACK_THOUSAND_MSG_RANK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_THOUSAND_MSG_RANK
    self:init()
end)

function ACK_THOUSAND_MSG_RANK.decode(self, r)
    self.rank = r:readInt16Unsigned() -- { 排名 }
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.name = r:readString() -- { 玩家名字 }
    self.harm = r:readInt32Unsigned() -- { 伤害值 }
    self.time = r:readInt16Unsigned() -- { 消耗时间 }
end

-- [55830]战役数据信息块 -- 拳皇生涯 
ACK_FIGHTERS_MSG_BATTLE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FIGHTERS_MSG_BATTLE
    self:init()
end)

function ACK_FIGHTERS_MSG_BATTLE.decode(self, r)
    self.copy_id = r:readInt16Unsigned() -- { 副本ID }
    self.is_pass = r:readInt8Unsigned() -- { 是否通关过 }
end

-- [55840]下一层副本ID -- 拳皇生涯 
ACK_FIGHTERS_NEXT_COPY_ID = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FIGHTERS_NEXT_COPY_ID
    self:init()
end)

function ACK_FIGHTERS_NEXT_COPY_ID.decode(self, r)
    self.copy_id = r:readInt16Unsigned() -- { 副本ID }
end

-- [55875]物品信息块 -- 拳皇生涯 
ACK_FIGHTERS_MSG_GOOD = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_FIGHTERS_MSG_GOOD
    self:init()
end)

function ACK_FIGHTERS_MSG_GOOD.decode(self, r)
    self.goods_id = r:readInt16Unsigned() -- { 物品ID }
    self.goods_count = r:readInt16Unsigned() -- { 物品数量 }
end

-- [56830]状态信息块 -- 系统设置 
ACK_SYS_SET_XXXXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYS_SET_XXXXX
    self:init()
end)

function ACK_SYS_SET_XXXXX.decode(self, r)
    self.type = r:readInt16Unsigned() -- { 类型 }
    self.state = r:readInt8Unsigned() -- { 状态 0|1 }
end

-- [56842]领取成功 -- 系统设置 
ACK_SYS_SET_WX_PLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYS_SET_WX_PLY
    self:init()
end)

-- [56850]微信奖励状态 -- 系统设置 
ACK_SYS_SET_WX_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_SYS_SET_WX_BACK
    self:init()
end)

function ACK_SYS_SET_WX_BACK.decode(self, r)
    self.state = r:readInt8Unsigned() -- { 0:不可领1:可领2:已领 }
end

-- [57840]成功点亮 -- 阵法系统 
ACK_MATRIX_LIGHTS_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MATRIX_LIGHTS_OK
    self:init()
end)

function ACK_MATRIX_LIGHTS_OK.decode(self, r)
    self.grade = r:readInt8Unsigned() -- { 阶数 }
    self.node = r:readInt8Unsigned() -- { 节点数 }
    self.stone = r:readInt32Unsigned() -- { 星石 }
end

-- [57860]升阶返回 -- 阵法系统 
ACK_MATRIX_UP_GRADE_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MATRIX_UP_GRADE_BACK
    self:init()
end)

function ACK_MATRIX_UP_GRADE_BACK.decode(self, r)
    self.result = r:readInt8Unsigned() -- { 0:失败 1:成功 }
end

-- [57875]星石更新 -- 阵法系统 
ACK_MATRIX_STONE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MATRIX_STONE
    self:init()
end)

function ACK_MATRIX_STONE.decode(self, r)
    self.stone = r:readInt32Unsigned() -- { 星石剩余数目 }
end

-- [58010]月卡信息块 -- 月卡 
ACK_YUEKA_KA_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_YUEKA_KA_MSG
    self:init()
end)

function ACK_YUEKA_KA_MSG.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 类型 }
    self.endday = r:readInt32Unsigned() -- { 结束时间 }
    self.state = r:readInt8Unsigned() -- { 领取状态 }
    self.state2 = r:readInt8Unsigned() -- { 领取装态2 }
end

-- [58020]购买月卡返回 -- 月卡 
ACK_YUEKA_BUY_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_YUEKA_BUY_CB
    self:init()
end)

function ACK_YUEKA_BUY_CB.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 类型 }
    self.endday = r:readInt32Unsigned() -- { 结束日期 }
    self.state = r:readInt8Unsigned() -- { 领取状态 }
    self.state2 = r:readInt8Unsigned() -- { 领取状态2 }
end

-- [58030]领取月卡返回 -- 月卡 
ACK_YUEKA_GET_REWARDS_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_YUEKA_GET_REWARDS_CB
    self:init()
end)

function ACK_YUEKA_GET_REWARDS_CB.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 类型 }
    self.idx = r:readInt8Unsigned() -- { 位置 }
end

-- [58204]请求第几天数据（回） -- N日首充 
ACK_N_CHARGE_REQUEST_N_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_N_CHARGE_REQUEST_N_CB
    self:init()
end)

function ACK_N_CHARGE_REQUEST_N_CB.decode(self, r)
    self.state = r:readInt8Unsigned() -- { 领取状态 }
end

-- [58205]请求返回 -- N日首充 
ACK_N_CHARGE_REQUEST_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_N_CHARGE_REQUEST_CB
    self:init()
end)

function ACK_N_CHARGE_REQUEST_CB.decode(self, r)
    self.n_day = r:readInt8Unsigned() -- { 第几天 }
    self.state = r:readInt8Unsigned() -- { 领取状态 }
end

-- [58215]领取返回 -- N日首充 
ACK_N_CHARGE_GET_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_N_CHARGE_GET_REPLY
    self:init()
end)

-- [28301]通知 -- 抢红包 
ACK_HONGBAO_SEND_ALL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HONGBAO_SEND_ALL
    self:init()
end)

function ACK_HONGBAO_SEND_ALL.decode(self, r)
    self.name = r:readString() -- { 名字 }
    self.jifen = r:readInt32Unsigned() -- { 可领取积分 }
    self.is = r:readInt8Unsigned() -- { 是否有领取按钮 }
    self.idx = r:readInt32Unsigned() -- { 唯一标识符 }
end

-- [58305]关闭通知 -- 抢红包 
ACK_HONGBAO_SHUTDOWN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HONGBAO_SHUTDOWN
    self:init()
end)

function ACK_HONGBAO_SHUTDOWN.decode(self, r)
    self.idx = r:readInt32Unsigned() -- { 唯一标识符 }
end

-- [58315]领取成功返回 -- 抢红包 
ACK_HONGBAO_GET_REWARDS_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HONGBAO_GET_REWARDS_CB
    self:init()
end)

function ACK_HONGBAO_GET_REWARDS_CB.decode(self, r)
    self.name = r:readString() -- { 名字 }
    self.jifen = r:readInt8Unsigned() -- { 获得的积分 }
end

-- [58330]拥有的红包积分 -- 抢红包 
ACK_HONGBAO_OWN_JIFEN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HONGBAO_OWN_JIFEN
    self:init()
end)

function ACK_HONGBAO_OWN_JIFEN.decode(self, r)
    self.jifen = r:readInt32Unsigned() -- { 红包积分 }
end

-- [58403]请求返回（放回） -- 精彩活动转盘 
ACK_ART_ZHUANPAN_UNLIMIT_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_ZHUANPAN_UNLIMIT_CB
    self:init()
end)

function ACK_ART_ZHUANPAN_UNLIMIT_CB.decode(self, r)
    self.count = r:readInt32Unsigned() -- { 拥有物品数量 }
    self.id = r:readInt32Unsigned() -- { 活动Id }
end

-- [58406]抽奖返回(放回式) -- 精彩活动转盘 
ACK_ART_ZHUANPAN_UNLOTTERY_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_ZHUANPAN_UNLOTTERY_CB
    self:init()
end)

function ACK_ART_ZHUANPAN_UNLOTTERY_CB.decode(self, r)
    self.idx = r:readInt8Unsigned() -- { 位置 }
    self.id = r:readInt32Unsigned() -- { 活动id }
end

-- [58409]信息快 -- 精彩活动转盘 
ACK_ART_ZHUANPAN_TEN_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_ZHUANPAN_TEN_MSG
    self:init()
end)

function ACK_ART_ZHUANPAN_TEN_MSG.decode(self, r)
    self.idx = r:readInt8Unsigned() -- { 位置 }
end

-- [58415]信息块 -- 精彩活动转盘 
ACK_ART_ZHUANPAN_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_ZHUANPAN_MSG
    self:init()
end)

function ACK_ART_ZHUANPAN_MSG.decode(self, r)
    self.idx = r:readInt8Unsigned() -- { 已抽取的物品位置 }
end

-- [58420]抽奖返回(不放回式) -- 精彩活动转盘 
ACK_ART_ZHUANPAN_LOTTERY_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ART_ZHUANPAN_LOTTERY_CB
    self:init()
end)

function ACK_ART_ZHUANPAN_LOTTERY_CB.decode(self, r)
    self.idx = r:readInt8Unsigned() -- { 物品位置 }
    self.id = r:readInt32Unsigned() -- { 活动id }
end

-- [58820]掷骰子任务数据返回 -- 侠客行 
ACK_KNIGHT_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_KNIGHT_REPLY
    self:init()
end)

function ACK_KNIGHT_REPLY.decode(self, r)
    self.node = r:readInt16Unsigned() -- { 位置节点 }
    self.task_node = r:readInt16Unsigned() -- { 任务节点 }
    self.count = r:readInt16Unsigned() -- { 剩余次数 }
    self.rand = r:readInt8Unsigned() -- { 随机步数 }
    self.is_have = r:readBoolean() -- { 事件类型 fale:没有任务 }
    self.state = r:readBoolean() -- { 是否完成 }
    self.value = r:readInt16Unsigned() -- { 任务完成值 }
end

-- [59815]美人主界面属性 -- 美人系统 
ACK_MEIREN_MAIN_ATTR = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MEIREN_MAIN_ATTR
    self:init()
end)

function ACK_MEIREN_MAIN_ATTR.decode(self, r)
    self.sp = r:readInt16Unsigned() -- { 怒气 }
    self.hp = r:readInt32Unsigned() -- { 气血 }
    self.att = r:readInt32Unsigned() -- { 攻击 }
    self.def = r:readInt32Unsigned() -- { 防御 }
    self.wreck = r:readInt32Unsigned() -- { 破甲 }
    self.hit = r:readInt16Unsigned() -- { 命中 }
    self.dod = r:readInt16Unsigned() -- { 闪避 }
    self.crit = r:readInt16Unsigned() -- { 暴击 }
    self.crit_res = r:readInt16Unsigned() -- { 抗暴 }
    self.bonus = r:readInt16Unsigned() -- { 伤害率 }
    self.reduction = r:readInt16Unsigned() -- { 免伤率 }
end

-- [59816]更随美人id -- 美人系统 
ACK_MEIREN_GENSUI_MEIREN = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MEIREN_GENSUI_MEIREN
    self:init()
end)

function ACK_MEIREN_GENSUI_MEIREN.decode(self, r)
    self.id = r:readInt32Unsigned() -- { 美人id }
end

-- [59825]信息块(id) -- 美人系统 
ACK_MEIREN_MSG_ID = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MEIREN_MSG_ID
    self:init()
end)

function ACK_MEIREN_MSG_ID.decode(self, r)
    self.mid = r:readInt32Unsigned() -- { 美人id }
end

-- [59845]各个属性加成比率 -- 美人系统 
ACK_MEIREN_PERCENT_ATTR = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MEIREN_PERCENT_ATTR
    self:init()
end)

function ACK_MEIREN_PERCENT_ATTR.decode(self, r)
    self.attr_id = r:readInt16Unsigned() -- { 属性id }
    self.percent = r:readInt32Unsigned() -- { 加成比率 }
end

-- [59870]缠绵回复 -- 美人系统 
ACK_MEIREN_LINGERING_SUC = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MEIREN_LINGERING_SUC
    self:init()
end)

function ACK_MEIREN_LINGERING_SUC.decode(self, r)
    self.lv = r:readInt8Unsigned() -- { 美人等级 }
    self.exp = r:readInt32Unsigned() -- { 美人现在的经验 }
    self.n_count = r:readInt8Unsigned() -- { 需要消耗数量 }
    self.g_count = r:readInt16Unsigned() -- { 拥有消耗物品数量 }
    self.times = r:readInt8Unsigned() -- { 缠绵次数 }
    self.get_exp = r:readInt32Unsigned() -- { 获得的经验 }
    self.power = r:readInt32Unsigned() -- { 战斗力 }
end

-- [59910]获得美人成功 -- 美人系统 
ACK_MEIREN_GET_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MEIREN_GET_SUCCESS
    self:init()
end)

-- [59925]美人跟随取消成功（回） -- 美人系统 
ACK_MEIREN_FOLLOW_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MEIREN_FOLLOW_CB
    self:init()
end)

-- [59935]亲密面板（回） -- 美人系统 
ACK_MEIREN_HONEY_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MEIREN_HONEY_CB
    self:init()
end)

function ACK_MEIREN_HONEY_CB.decode(self, r)
    self.power = r:readInt32Unsigned() -- { 战斗力 }
    self.ncount = r:readInt32Unsigned() -- { 每次消耗物品数量 }
    self.gcount = r:readInt32Unsigned() -- { 拥有物品数量 }
    self.lv = r:readInt8Unsigned() -- { 技能等级 }
    self.rate = r:readInt32Unsigned() -- { 现有加成率 }
end

-- [59945]亲密信息块 -- 美人系统 
ACK_MEIREN_HONNEY_MSG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MEIREN_HONNEY_MSG
    self:init()
end)

function ACK_MEIREN_HONNEY_MSG.decode(self, r)
    self.lv = r:readInt8Unsigned() -- { 属性等级 }
    self.attr_id = r:readInt16Unsigned() -- { 属性id }
    self.rate = r:readInt32Unsigned() -- { 加成比率 }
end

-- [60000]亲密（回） -- 美人系统 
ACK_MEIREN_ONE_HONEY_CB = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MEIREN_ONE_HONEY_CB
    self:init()
end)

function ACK_MEIREN_ONE_HONEY_CB.decode(self, r)
    self.count = r:readInt8Unsigned() -- { 亲密次数 }
    self.gexp = r:readInt32Unsigned() -- { 得到的加成率 }
end

-- [60005]亲密后战力 -- 美人系统 
ACK_MEIREN_HONEY_POWER = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MEIREN_HONEY_POWER
    self:init()
end)

function ACK_MEIREN_HONEY_POWER.decode(self, r)
    self.power = r:readInt32Unsigned() -- { 战斗力 }
end

-- [60007]亲密后缠绵面板刷新 -- 美人系统 
ACK_MEIREN_HONEY_SKID = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MEIREN_HONEY_SKID
    self:init()
end)

function ACK_MEIREN_HONEY_SKID.decode(self, r)
    self.skid = r:readInt16Unsigned() -- { 技能id }
    self.rate = r:readInt32Unsigned() -- { 加成比率 }
end

-- [60815]个人护送时间 -- 押镖 
ACK_ESCORT_TIME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ESCORT_TIME
    self:init()
end)

function ACK_ESCORT_TIME.decode(self, r)
    self.sec = r:readInt32Unsigned() -- { 自己镖到终点的时间戳 }
end

-- [60821]正在押送的镖 -- 押镖 
ACK_ESCORT_XXX1 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ESCORT_XXX1
    self:init()
end)

function ACK_ESCORT_XXX1.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 镖主uid }
    self.uname = r:readString() -- { 镖主名字 }
    self.fname = r:readString() -- { 帮手的名字 }
    self.mid = r:readInt16Unsigned() -- { 此趟镖的美人id }
    self.num = r:readInt8Unsigned() -- { 此趟镖剩余的可劫次数 }
    self.gold = r:readInt32Unsigned() -- { 此趟镖可获铜钱 }
    self.power = r:readInt32Unsigned() -- { 此趟镖可获战功 }
    self.seconds = r:readInt32Unsigned() -- { 此趟镖到终点的时间戳 }
    self.orbit = r:readInt8Unsigned() -- { 所在轨道 }
end

-- [60822]所有的人战报 -- 押镖 
ACK_ESCORT_XXX2 = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ESCORT_XXX2
    self:init()
end)

function ACK_ESCORT_XXX2.decode(self, r)
    self.zname = r:readString() -- { 打劫者名字 }
    self.bname = r:readString() -- { 被打劫者名字 }
    self.dgold = r:readInt32Unsigned() -- { 打劫获得的铜钱 }
    self.dpower = r:readInt32Unsigned() -- { 打劫获得的战功 }
end

-- [60826]护送面板返回 -- 押镖 
ACK_ESCORT_HUSONG = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ESCORT_HUSONG
    self:init()
end)

function ACK_ESCORT_HUSONG.decode(self, r)
    self.rob_num = r:readInt8Unsigned() -- { 剩余的打劫次数 }
    self.esc_num = r:readInt8Unsigned() -- { 剩余的护送次数 }
    self.free_num = r:readInt8Unsigned() -- { 剩余的免费刷新次数 }
    self.next_mid = r:readInt8Unsigned() -- { 刷新到的美人id }
    self.ref_use = r:readInt8Unsigned() -- { 下一次刷新的花费 }
    self.zhao_use = r:readInt16Unsigned() -- { 召唤花费 }
end

-- [60915]加速护送返回 -- 押镖 
ACK_ESCORT_ACCEL_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ESCORT_ACCEL_BACK
    self:init()
end)

-- [60955]打劫结束返回 -- 押镖 
ACK_ESCORT_OVER_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_ESCORT_OVER_BACK
    self:init()
end)

function ACK_ESCORT_OVER_BACK.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 0:失败 1:成功 }
    self.gold = r:readInt32Unsigned() -- { 抢得的铜钱 }
    self.power = r:readInt32Unsigned() -- { 抢得的战功 }
end

-- [61820]抽奖界面返回 -- 每日抽奖 
ACK_DRAW_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DRAW_REPLY
    self:init()
end)

function ACK_DRAW_REPLY.decode(self, r)
    self.times = r:readInt8Unsigned() -- { 剩余抽奖次数 }
    self.days = r:readInt16Unsigned() -- { 连续登陆次数 }
    self.all_times = r:readInt8Unsigned() -- { 全部抽奖次数 }
    self.id = r:readInt16Unsigned() -- { 获得id }
end

-- [62850]竞拍成功 -- 系统拍卖 
ACK_AUCTION_SUCCESS = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_AUCTION_SUCCESS
    self:init()
end)

-- [63805]玩家位子信息块 -- 帮派守卫战 
ACK_DEFENSE_USER_SEAT = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFENSE_USER_SEAT
    self:init()
end)

function ACK_DEFENSE_USER_SEAT.decode(self, r)
    self.idx = r:readInt8Unsigned() -- { 位子 }
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
end

-- [63820]返回地图数据 -- 帮派守卫战 
ACK_DEFENSE_INTER = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFENSE_INTER
    self:init()
end)

function ACK_DEFENSE_INTER.decode(self, r)
    self.start_time = r:readInt32Unsigned() -- { 开始时间 }
    self.end_time = r:readInt32Unsigned() -- { 结束时间 }
    self.is_start = r:readInt8Unsigned() -- { 是否开始 0:否 1:是 }
end

-- [63830]波次信息 -- 帮派守卫战 
ACK_DEFENSE_CEN_BO = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFENSE_CEN_BO
    self:init()
end)

function ACK_DEFENSE_CEN_BO.decode(self, r)
    self.cen = r:readInt8Unsigned() -- { 当前层 }
    self.boci = r:readInt8Unsigned() -- { 当前波次 }
    self.all = r:readInt8Unsigned() -- { 总波次 }
end

-- [63840]自己当前血量 -- 帮派守卫战 
ACK_DEFENSE_SELF_HP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFENSE_SELF_HP
    self:init()
end)

function ACK_DEFENSE_SELF_HP.decode(self, r)
    self.hp = r:readInt32Unsigned() -- { 血量 }
end

-- [63890]个人击杀 -- 帮派守卫战 
ACK_DEFENSE_SELF_KILL = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFENSE_SELF_KILL
    self:init()
end)

function ACK_DEFENSE_SELF_KILL.decode(self, r)
    self.kill_num = r:readInt16Unsigned() -- { 击杀数量 }
end

-- [63930]状态返回 -- 帮派守卫战 
ACK_DEFENSE_DIED_STATE = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFENSE_DIED_STATE
    self:init()
end)

function ACK_DEFENSE_DIED_STATE.decode(self, r)
    self.type = r:readInt8Unsigned() -- { 0:分配 1:复活 }
    self.time = r:readInt32Unsigned() -- { 倒计时时长（s） }
end

-- [64010]信息块 -- 帮派守卫战 
ACK_DEFENSE_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFENSE_XXX
    self:init()
end)

function ACK_DEFENSE_XXX.decode(self, r)
    self.hp1 = r:readInt32Unsigned() -- { 剩余血青龙 }
    self.all_hp1 = r:readInt32Unsigned() -- { 总血青龙 }
    self.cen1 = r:readInt8Unsigned() -- { 层次 }
    self.state1 = r:readInt8Unsigned() -- { 是否通关0:否 1:是 }
    self.hp2 = r:readInt32Unsigned() -- { 剩余血白虎 }
    self.all_hp2 = r:readInt32Unsigned() -- { 总血白虎 }
    self.cen2 = r:readInt8Unsigned() -- { 层次 }
    self.state2 = r:readInt8Unsigned() -- { 是否通关0:否 1:是 }
    self.hp3 = r:readInt32Unsigned() -- { 剩余血朱雀 }
    self.all_hp3 = r:readInt32Unsigned() -- { 总血朱雀 }
    self.cen3 = r:readInt8Unsigned() -- { 层次 }
    self.state3 = r:readInt8Unsigned() -- { 是否通关0:否 1:是 }
    self.hp4 = r:readInt32Unsigned() -- { 剩余血玄武 }
    self.all_hp4 = r:readInt32Unsigned() -- { 总血玄武 }
    self.cen4 = r:readInt8Unsigned() -- { 层次 }
    self.state4 = r:readInt8Unsigned() -- { 是否通关0:否 1:是 }
end

-- [64040]复活成功 -- 帮派守卫战 
ACK_DEFENSE_RESURREC_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_DEFENSE_RESURREC_OK
    self:init()
end)

-- [64130]防守方信息块 -- 占山为王 
ACK_HILL_FS_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HILL_FS_DATA
    self:init()
end)

function ACK_HILL_FS_DATA.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家uid }
    self.name = r:readString() -- { 玩家名字 }
    self.kill = r:readInt16Unsigned() -- { 击杀数量 }
    self.sy_hp = r:readInt32Unsigned() -- { 剩余血量 }
    self.hp = r:readInt32Unsigned() -- { 总血量 }
    self.pro = r:readInt8Unsigned() -- { 职业 }
end

-- [64180]战报信息块 -- 占山为王 
ACK_HILL_REDIO_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HILL_REDIO_DATA
    self:init()
end)

function ACK_HILL_REDIO_DATA.decode(self, r)
    self.t_uid = r:readInt32Unsigned() -- { 挑战玩家uid }
    self.t_name = r:readString() -- { 挑战玩家名字 }
    self.b_uid = r:readInt32Unsigned() -- { 被挑战玩家uid }
    self.b_name = r:readString() -- { 被挑战玩家名字 }
    self.result = r:readInt8Unsigned() -- { 1:成功 2:失败 }
    self.bonus = r:readInt32Unsigned() -- { 造成伤害 }
    self.time = r:readInt32Unsigned() -- { 挑战时间戳 }
end

-- [64185]cd冷却中 -- 占山为王 
ACK_HILL_CD_SEC = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HILL_CD_SEC
    self:init()
end)

function ACK_HILL_CD_SEC.decode(self, r)
    self.rmb = r:readInt16Unsigned() -- { 需要花费元宝数 }
end

-- [64205]挑战结果 -- 占山为王 
ACK_HILL_FINISH_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HILL_FINISH_BACK
    self:init()
end)

function ACK_HILL_FINISH_BACK.decode(self, r)
    self.res = r:readInt8Unsigned() -- { 0:失败 1:成功 }
    self.contribute = r:readInt16Unsigned() -- { 奖励帮贡 }
end

-- [64220]清除成功 -- 占山为王 
ACK_HILL_CLEAN_OK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_HILL_CLEAN_OK
    self:init()
end)

-- [64820]迷宫界面返回 -- 挑战迷宫 
ACK_MAZE_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAZE_REPLY
    self:init()
end)

function ACK_MAZE_REPLY.decode(self, r)
    self.node = r:readInt8Unsigned() -- { 当前所在节点 }
    self.num = r:readInt8Unsigned() -- { 剩余的免费次数 }
    self.is_have = r:readInt8Unsigned() -- { 背包是否有东西 0:否 1:是 }
end

-- [64870]物品数据块 -- 挑战迷宫 
ACK_MAZE_GOODS_XXX = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAZE_GOODS_XXX
    self:init()
end)

function ACK_MAZE_GOODS_XXX.decode(self, r)
    self.goods_id = r:readInt32Unsigned() -- { 物品id }
    self.goods_num = r:readInt32Unsigned() -- { 物品数量 }
end

-- [64910]兑换成功返回 -- 挑战迷宫 
ACK_MAZE_EXCHANGE_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAZE_EXCHANGE_BACK
    self:init()
end)

-- [65160]入包成功 -- 挑战迷宫 
ACK_MAZE_PECK_BACK = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MAZE_PECK_BACK
    self:init()
end)

-- [65320]秘宝活动界面信息块 -- 秘宝活动 
ACK_MIBAO_REPLY_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MIBAO_REPLY_DATA
    self:init()
end)

function ACK_MIBAO_REPLY_DATA.decode(self, r)
    self.id = r:readInt16Unsigned() -- { 活动ID }
    self.state = r:readInt8Unsigned() -- { 活动状态(0未刷新 1已刷新 2已结束) }
    self.time = r:readInt32Unsigned() -- { 下一波箱子刷新时间 }
end

-- [65355]箱子信息块 -- 秘宝活动 
ACK_MIBAO_BOX_DATA = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MIBAO_BOX_DATA
    self:init()
end)

function ACK_MIBAO_BOX_DATA.decode(self, r)
    self.box_idx = r:readInt32Unsigned() -- { 箱子唯一ID }
    self.box_id = r:readInt16Unsigned() -- { 箱子ID }
    self.hp_now = r:readInt32Unsigned() -- { 当前血量 }
    self.hp_max = r:readInt32Unsigned() -- { 最大血量 }
    self.uid = r:readInt32Unsigned() -- { 玩家Uid }
    self.name = r:readString() -- { 玩家名字 }
    self.pos_x = r:readInt16Unsigned() -- { 位置X }
    self.pos_y = r:readInt16Unsigned() -- { 位置Y }
end

-- [65365]物品信息块 -- 秘宝活动 
ACK_MIBAO_GOODS_LIST = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MIBAO_GOODS_LIST
    self:init()
end)

function ACK_MIBAO_GOODS_LIST.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.name = r:readString() -- { 玩家名字 }
    self.goods_idx = r:readInt32Unsigned() -- { 物品唯一ID }
    self.goods_id = r:readInt16Unsigned() -- { 物品ID }
    self.goods_count = r:readInt16Unsigned() -- { 物品数量 }
    self.goods_x = r:readInt16Unsigned() -- { 物品位置X }
    self.goods_y = r:readInt16Unsigned() -- { 物品位置Y }
end

-- [65380]物品消失 -- 秘宝活动 
ACK_MIBAO_GOODS_DISAPPEAR = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MIBAO_GOODS_DISAPPEAR
    self:init()
end)

function ACK_MIBAO_GOODS_DISAPPEAR.decode(self, r)
    self.uid = r:readInt32Unsigned() -- { 玩家ID }
    self.goods_idx = r:readInt32Unsigned() -- { 物品唯一ID }
    self.goods_id = r:readInt32Unsigned() -- { 物品ID }
    self.goods_count = r:readInt16Unsigned() -- { 物品数量 }
end

-- [65385]玩家当前血量 -- 秘宝活动 
ACK_MIBAO_PLAYER_HP = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MIBAO_PLAYER_HP
    self:init()
end)

function ACK_MIBAO_PLAYER_HP.decode(self, r)
    self.hp = r:readInt32Unsigned() -- { 玩家当前血量 }
end

-- [65405]玩家复活返回 -- 秘宝活动 
ACK_MIBAO_REVIVE_REPLY = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MIBAO_REVIVE_REPLY
    self:init()
end)

function ACK_MIBAO_REVIVE_REPLY.decode(self, r)
    self.pos_x = r:readInt16Unsigned() -- { 玩家出生点X }
    self.pos_y = r:readInt16Unsigned() -- { 玩家出生点Y }
end

-- [65410]下一次箱子刷新时间 -- 秘宝活动 
ACK_MIBAO_BOX_REFRESH_TIME = classGc(MsgAck,function(self)
    self.MsgID = Msg.ACK_MIBAO_BOX_REFRESH_TIME
    self:init()
end)

function ACK_MIBAO_BOX_REFRESH_TIME.decode(self, r)
    self.state = r:readInt8Unsigned() -- { 活动状态 }
    self.time = r:readInt32Unsigned() -- { 下一次时间 }
end
--/** =============================== 自动生成的代码 =============================== **/
--/*************************** don't touch this line *********** AUTO_CODE_END_ACKA **/
