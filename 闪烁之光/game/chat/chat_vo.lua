
-- User: cloud
-- Date: 2016.12.23
-- 文件功能：各种聊天的数据vo
ChatVo = ChatVo or BaseClass()
function ChatVo:__init()
    self.channel  = 0   -- 频道
    self.id       = 0   -- 唯一id
    self.type     = 0   -- 说话者类型;1:玩家2:gm4:传闻8:系统
    self.rid      = 0
    self.srv_id   = 0
    self.name     = 0   --玩家名字
    self.lev      = 0   --等级
    self.career   = 0   --职业
    self.face_id  = 0   --头像id
    self.len      = 0   --语音长度
    self.msg      = 0   --文字或是语音
    self.sex      = 0   --性别
    self.tick     = nil --时间戳
    self.flag     = nil --自定义标记 1不显示表头
    self.vip_lev  = 0   --说话者vip等级
    self.is_show_vip = 0 -- 是否隐藏vip
    self.capacity = 0   --0玩家 1GM 2新手指导员
    self.head_bid = 0   --头像框
    self.gid = 0        --公会id
    self.gsrv_id = ""   --公会服务器id
    self.gname = ""     --公会名字
    self.province = ""  --省份
    self.city = ""      --市区
    self.bubble_bid = 0
    self.ext_list = {}
    self.face_file                      = ""
    self.face_update_time               = 0
end

--设置对象信息
function ChatVo:setObjectAttr(data)
    self.id       = data.id
    self.type     = data.type
    self.len      = data.len
    self.msg      = data.msg
    self.tick     = data.tick
    self.flag     = data.flag
end

function ChatVo:setMessageAttr(data)
    self.rid      = data.rid      or 0
    self.srv_id   = data.srv_id   or 0
    self.name     = data.name     or ""
    self.lev      = data.lev      or 0
    self.face_id  = data.face_id  or 0
    self.career   = data.career   or 1
    self.sex      = data.sex      or 0
    self.vip_lev  = data.vip_lev  or 0
    self.is_show_vip = data.is_show_vip or 0
    self.capacity = data.capacity or 0
    self.head_bid = data.head_bid or 0
    self.gid      = data.gid or 0 
    self.gsrv_id  = data.gsrv_id or ""
    self.gname    = data.g_name or ""
    self.province = data.province or ""
    self.city = data.city or ""
    self.ext_list = data.ext_list or {}
    self.face_file = data.face_file or ""
    self.face_update_time = data.face_update_time or 0
    if data.chat_bubble then
        self.bubble_bid =  data.chat_bubble
    elseif data.bubble_bid then
        self.bubble_bid =  data.bubble_bid 
    else
        self.bubble_bid = 0
    end
    
end

function ChatVo:getChatId()
    return self.srv_id.."_"..self.rid
end

--私聊的数据vo------------------------
PrivateChatVo = PrivateChatVo or BaseClass()
function PrivateChatVo:__init()
    self.flag    = 0  -- 1:我对B说;2:B对我说;11:我对B说，B不在线
    self.rid     = 0  -- 角色id
    self.srv_id  = 0  -- 服务器id
    self.name    = 0  -- 角色名称
    self.lev     = 0  -- 等级
    self.career  = 0  -- 职业
    self.face_id = 0  -- 头像id
    self.len     = 0  -- 标识，客户端用
    self.msg     = 0  -- 消息
    self.sex     = 0  -- 性别
    self.talk_time = 0 --交谈时间
    self.capacity = 0
    self.head_bid = 0 --头像框
    --对方数据
    self.other_rid = 0
    self.other_srv_id = 0
    self.other_name = 0
    self.other_lev = 0
    self.other_face_id = 0
    self.face_file                      = ""
    self.face_update_time               = 0
end

function PrivateChatVo:setChatVo(data)
    for k, v in pairs(data) do
        self[k] = v
    end
end

function PrivateChatVo:isChatNow(srv_id, rid)
    if self.srv_id == srv_id and self.rid == rid then
        return true
    end
end

function PrivateChatVo:isMine()
    if self.flag == 1 then return true end
end

function PrivateChatVo:isOhter()
    if self.flag == 2 then return true end
end

