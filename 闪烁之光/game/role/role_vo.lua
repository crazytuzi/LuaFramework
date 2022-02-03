-- Created by IntelliJ IDEA.
-- User: lfl 1204825992@qq.com
-- Date: 2014/11/7
-- Time: 19:28
-- 文件功能：主角色的数据vo部分
RoleVo = RoleVo or BaseClass(EventDispatcher)

function RoleVo:__init()
    --基础数据部分    
    self.rid                            = 0                     -- 角色id;
    self.srv_id                         = ""                     -- 服务器id;
    self.main_srv_id                    = ""                    -- 主服务器id;
    self.name                           = 0                     -- 角色名;
    self.lev                            = 0                     -- 等级;
    self.is_vip                         = 0                     -- 是否激活vip;
    self.vip_lev                        = 0                     -- vip等级;
    self.vip_exp                        = 0                     -- vip经验;
    self.is_show_vip                    = 0                     -- 聊天是否隐藏vip标识 1隐藏 0不隐藏
    self.sex                            = 0                     -- 性别;
    self.career                         = 0                     -- 职业；
    self.face_id                        = ""                    -- 头像id;
    self.gid                            = 0                     -- 公会id;
    self.gsrv_id                        = ""                    -- 公会服务器id;
    self.position                       = 0                     -- 公会职位;
    self.gname                          = ""                    -- 所属帮派的名字
    self.signature                      = ""                    -- 个性签名
    self.exp_max                        = 0                     -- 当前等级升级到下一级的经验值上限;
    self.exp_total_nextlev              = 0                     -- 到下一级的经验值累计值
    self.buffs                          = {}                    -- buff列表
    self.reg_time                       = 0                     -- 注册时间
    self.guild_lev                      = 0                     -- 公会等级
    self.power                          = 0                     -- 战力
    self.is_first_rename                = TRUE                  -- 是否是第一次起名
    self.avatar_base_id                 = 0                     -- 头像框基础id
    self.guild_quit_time                = 0                     -- 上次退帮时间
    self.max_power                      = 0                     --最高战力
    self.fans_num                       = 0                     --粉丝数量
    self.arena_elite_lev                = 0                     --段位赛等级
    self.city_id                        = 0                     --城市id
    self.backdrop_id                    = 0                     --空间背景id
    self.is_open_home                   = 0                     --是否开启了家园
    
    --资产部分
    self.exp                            = 0                     -- 经验;
    self.gold                           = 0                     -- 蓝钻
    self.gold_acc                       = 0                     -- 充值元宝（暂时没有用）
    self.red_gold                       = 0                     -- 红钻
    self.coin                           = 0                     -- 金币
    self.silver_coin                    = 0                     -- 银币
    self.energy                         = 0                     -- 体力
    self.energy_max                     = 0                     -- 体力上限
    self.arena_cent                     = 0                     -- 竞技场积分
    self.activity                       = 0                     -- 活跃度
    self.guild                          = 0                     -- 贡献
    self.hero_soul                      = 0                     -- 将魂
    self.friend_point                   = 0                     --友情点
    -- self.god_point                      = 0                     --boss积分
    self.boss_point                     = 0                     --boss积分
    self.star_hun                       = 0                     --星魂
    self.star_point                     = 0                     --探宝积分
    self.worship                        = 0                     -- 自己被点赞次数  
    self.cross_cham_worship             = 0                     -- 周冠军赛被膜拜次数
    self.look_id                        = 0                     --使用形象id
    self.arena_coin                     = 0                     -- 冠军赛竞猜币
    self.arena_guesscent                = 0                     --冠军赛竞猜积分
    self.auto_pk                        = 0                     -- 自动pk(0:需要验证 1:不需要验证)
    self.sky_coin                       = 0                     -- 天梯积分
    self.recruit_hero                   = 0                     -- 召唤积分
    self.recruithigh_hero               = 0                     -- 先知殿积分
    self.hero_exp                       = 0                      --英雄经验
    self.open_day                       = 0                     -- 开服天数
    self.cluster_coin                   = 0                     -- 跨服竞技场声望
    self.home_coin                      = 0                     -- 家园币
    self.hallow_refine                  = 0                     -- 晶石 神器精炼消耗
    self.cluster_guess_coin             = 0                     -- 跨服冠军赛竞猜币
    self.cluster_guess_cent             = 0                     -- 跨服冠军赛积分
    self.feather_exchange               = 0                     -- 圣羽商店
    self.peak_guess_cent                = 0                     -- 巅峰冠军赛代币
    self.acc_recruit_hero               = 0                     -- 累计召唤积分(不消耗)
    self.predict_point                  = 0                     -- 先知召唤积分

    self.dic_action_assets              = {}                    --活动资产信息 self.dic_action_assets[资产id] = 数量

    self.pass_certify                   = 2                     -- 是否认证(不是2 就当做未认证)
    
    self.custom_face_file               = ""                    -- 自定义头像时候的命名
    self.face_file                      = ""                    -- 自定义头像,为空就标识没有自定义
    self.face_update_time               = 0                     -- 自定义头像更新时间戳,如果和本地缓存的不一致,则需要下载新的
end 

--获取角色的唯一id号(服务器id_rid)
function RoleVo:getRoleSrid()
    return getNorKey(self.srv_id, self.rid)
end

-- 是否是自己
function RoleVo:isSameRole(srv_id, rid)
    return self.srv_id == srv_id and self.rid == rid
end

--获取角色公会的唯一id号
function RoleVo:getGuildSrid()
    return self.gsrv_id .. "_" .. self.gid
end

--判断是否有加入宗派
function RoleVo:isHasGuild()
    return self.gid ~= 0
end

--[[
    角色初始数据,极可能是场景上的数据,也可能是面板上的相关数据
]]
function RoleVo:initAttributeData(data_list)
    local data_list = data_list or {}
    for k, v in pairs(data_list) do
        if type(v) ~= "table" then
            self:setRoleAttribute(k, v)
        end
    end
end

--[[角色活动资产信息]]
--@is_update 是否数据更新
function RoleVo:initActionAssetsData(holiday_assets, is_update)
    if not self.dic_action_assets then return end
    local holiday_assets = holiday_assets or {}
    for i,v in ipairs(holiday_assets) do
        self.dic_action_assets[v.id] = v.val
        if is_update then
            self:Fire(RoleEvent.UPDATE_ROLE_ACTION_ASSETS, v.id, v.val)
        end
    end
end
--获取活动资产数量
function RoleVo:getActionAssetsNumByBid(bid)
    if self.dic_action_assets and self.dic_action_assets[bid] then
        return self.dic_action_assets[bid]
    else
        return 0
    end
end

function RoleVo:setRoleAttribute(key, value)
    if self[key] ~= value or key == "face_id" then  -- 这里头像特殊处理一下，因为可能存在设置了自定义都想之后在设置系统头像  还是之前的值
        self[key] = value
        self:dispatchUpdateAttrByKey(key, value)
    end
end

--派发单个属性数据的变化
function RoleVo:dispatchUpdateAttrByKey(key, value)
    self:Fire(RoleEvent.UPDATE_ROLE_ATTRIBUTE, key, value)
end

--设置战力
function RoleVo:setPower(value)
    local old_value = self.power
    self.power = value or 0
    if self.power ~= old_value then
        self:dispatchUpdateAttrByKey("power",self.power)
        self:Fire(RoleEvent.UPDATE_POWER_VALUE, self.power, old_value)
    end
end

--设置最高战力
function RoleVo:setMaxPower(value)
    local old_value = self.max_power
    self.max_power = value or 0
    if self.max_power ~= old_value then
        self:dispatchUpdateAttrByKey("max_power",self.max_power)
    end
end

--设置角色的buff数据
function RoleVo:setBuffVo(vo)
    local temp = {}
    for k1, v1 in pairs(vo) do
        local bid = v1["bid"]
        local buff_vo
        if self.buffs[bid] then
            buff_vo = self.buffs[bid]
        else
            buff_vo = BuffVo.New()
        end
        buff_vo:initVo(v1)
        temp[bid] = buff_vo
    end
    self:setRoleAttribute("buffs", temp)
end

function RoleVo:getBuffVo()
    return self.buffs
end

--对资产进行设置
function RoleVo:setRoleAssset(data)
    for k, v in pairs(data) do
        local key = Config.ItemData.data_assets_id2label[v.label]
        if key ~= nil then
            self:setRoleAttribute(key, v.val)
        end
    end
    -- self:dispatchUpdateAssets()
end

--设置请求全部数据的状态
function RoleVo:setAllDataStatus(bool)
    self.is_get_all_data = bool
end

function RoleVo:isGetAllData()
    return self.is_get_all_data
end

function RoleVo:getRoleName()
    return self.name
end
function RoleVo:getRoleMainSrvId()
    return self.main_srv_id or ""
end

function RoleVo:setVolume(value)
    self.volume = value or 0
end

--派发基础数据变化
function RoleVo:dispatchUpdateBaseAttr()
    self:Fire(RoleEvent.UPDATE_ROLE_BASE_ATTR)
end

--派发资产数据变化
function RoleVo:dispatchUpdateAssets()
    self:Fire(RoleEvent.UPDATE_ROLE_ASSETS)
end

-- 设置角色拥有的头像
function RoleVo:setRoleHeadList(data)
    self:setRoleAttribute("face_list", data.face_list)
end

function RoleVo:__delete()
end
