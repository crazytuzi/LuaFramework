 --[[
 --
 -- @authors shan 
 -- @date    2014-05-07 10:46:47
 -- @version 
 --
 --]]

 

local Player = class("Player")


function Player:ctor( ... )
    -- 公告
    self.m_gamenote = nil
    self.m_extendData = {}  -- 服务器端返回的关于渠道的信息 

    self.m_serverID = 1  -- 服务器
    self.m_thirdID  = "" -- 第三方id
    self.m_uid      = "" -- user id
    self.m_playerID = "" -- player id
    self.m_sessionID = "" -- session

    self.m_zoneID = 1

    self.m_sdkID = ""
    self.m_loginName = ""

    self.m_serverKey = "" -- 服务器创建的key值，在每次连接时验证

    self.m_logout = false

    self.m_maxLevel = 0
    self.m_subMapID = 0

    self.m_battleData = {} 
    self.m_battleData.cur_bigMapId = 0 
    self.m_battleData.cur_subMapId = 0  
    self.m_battleData.new_bigMapId = 0 
    self.m_battleData.new_subMapId = 0 
    self.m_battleData.isOpenNewBigmap = false   -- 是否开启了新关卡


    self.m_mail_battle = 0
    self.m_mail_friend = 0
    self.m_mail_system = 0

    self._biwuCollTime = 0
    self._yaBiaoCollTime = 0

    -- 其他属性
                -- 所有成员
    self.m_majorHeros = {0, 0, 0, 0, 0, 0}  -- 主力成员
    self.m_heroSouls  = {}                  -- 魂魄 
    
    -- 帮派
    self.m_guildMgr = nil

    self.m_isChangedServer = false  -- 是否切换过服务器 

    self.m_appOpenData = {}         -- appStore相关的按钮开关 
    
--
--    self.m_equipments    = {} -- 装备
    self.m_skills        = {}   -- 技能
    self.m_pets          = {}   -- 宠物
    self.m_petFragments  = {}   -- 宠物碎片

    self.m_unlock_levels      = {}      -- 解锁关卡
    self.m_levels_fight_count = {}  -- 关卡攻打次数
    self.m_currect_level = 11

    self.m_package = {} -- 背包
    self.m_mails   = {} -- 邮件
    self.m_friends = {} -- 好友
    --
    self.m_formation = {}


    self.m_arena    = {times = 5, rankID = 0, score = 0} -- 竞技场
    self.m_recruit  = {}    -- 抽卡 or 酒馆

        -- 收集图鉴
    self.m_collections = { { }, { }, { } }


    -- purchase iap
    self.m_Purchased = false
    self.m_giftPackages = {}

    -- 是否升级
    self.m_levelUpAry = {}
    self.m_levelUpAry.isLevelUp = false
    self.m_levelUpAry.beforeLevel = 0 
    self.m_levelUpAry.curLevel = 0

    self.m_cur_normal_fuben_ID = 1101                       --当前普通副本ID

    self.m_fubenDisOffset = CCPointMake(0, 0)               -- 当前副本的地图位置 
    self.m_submapOffset = ccp(0,0)                          -- submap list 位置
    self.m_herolistOffset = ccp(0,0)                        -- hero list position

    self:initNotification() 

    -- bigmap  pos offset
    self.setFubenDisOffset = function(_, offset)
        self.m_fubenDisOffset = offset or self.m_fubenDisOffset 
    end 

    self.getFubenDisOffset = function()
        return self.m_fubenDisOffset
    end

    -- submap pos offset
    self.setSubmapOffset = function ( _, offset )
        self.m_submapOffset = offset or self.m_submapOffset
    end

    self.getSubmapOffet = function (  )
       return self.m_submapOffset     
    end

    -- herolist  pos offset
    self.setHeroListOffset = function ( _, offset )
        self.m_herolistOffset = offset or self.m_herolistOffset
    end

    self.getHeroListOffset = function (  )
        return self.m_herolistOffset
    end


    self.getBattleData = function(param)
        return self.m_battleData 
    end 

    self.getCurSubMapID = function()
        return self.m_battleData.cur_subMapId
    end

    self.setBattleData = function(_, param) 
        self.m_battleData.new_bigMapId = param.new_bigMapId or self.m_battleData.new_bigMapId  
        self.m_battleData.new_subMapId = param.new_subMapId or self.m_battleData.new_subMapId 

        self.m_battleData.cur_bigMapId = param.cur_bigMapId or self.m_battleData.cur_bigMapId
        self.m_battleData.cur_subMapId = param.cur_subMapId or self.m_battleData.cur_subMapId     

        if param.isOpenNewBigmap ~= nil then 
            self.m_battleData.isOpenNewBigmap = param.isOpenNewBigmap 
        end 
    end


    self.getZoneID = function (  )
        return self.m_zoneID
    end

    self.setAppOpenData = function(_, data)
        self.m_appOpenData = data or {}
        self.m_appOpenData.b_liaotian    = self.m_appOpenData.b_liaotian or 0
        self.m_appOpenData.b_qiecuo      = self.m_appOpenData.b_qiecuo or 0
        self.m_appOpenData.b_siliao      = self.m_appOpenData.b_siliao or 0
        self.m_appOpenData.c_vipbtn      = self.m_appOpenData.c_vipbtn or 0
        self.m_appOpenData.c_yueka       = self.m_appOpenData.c_yueka or 0
        self.m_appOpenData.chengzhang    = self.m_appOpenData.chengzhang or 0
        self.m_appOpenData.chongwu       = self.m_appOpenData.chongwu or 0
        self.m_appOpenData.dengji       = self.m_appOpenData.dengji or 0
        self.m_appOpenData.huodong       = self.m_appOpenData.huodong or 0
        self.m_appOpenData.hy_qiecuo     = self.m_appOpenData.hy_qiecuo or 0
        self.m_appOpenData.kaifu         = self.m_appOpenData.kaifu or 0
        self.m_appOpenData.kezhan        = self.m_appOpenData.kezhan or 0
        self.m_appOpenData.lianhuashenmi = self.m_appOpenData.lianhuashenmi or 0
        self.m_appOpenData.shouchong     = self.m_appOpenData.shouchong or 0
        self.m_appOpenData.zaixian       = self.m_appOpenData.zaixian or 0
        self.m_appOpenData.zhifuqiehuan  = self.m_appOpenData.zhifuqiehuan or 0
        self.m_appOpenData.zijianbangzhu = self.m_appOpenData.zijianbangzhu or 0

        -- 【有爱支付】 1：appstore支付；0：有爱支付
        self.m_appOpenData.youai = self.m_appOpenData.youai or 1
    end 

    self.getAppOpenData = function()
        return self.m_appOpenData 
    end 
end


---
-- 帮派管理 instance
--
function Player:getGuildMgr( ... )
    if( self.m_guildMgr == nil ) then
        self.m_guildMgr = require("game.guild.GuildMgr").new()
    end

    return self.m_guildMgr
end


function Player:getGuildInfo( ... )
    return self:getGuildMgr():getGuildInfo() 
end


 local function isCanSleep(t)
    local t = t/1000
     local nowTime = os.date("*t", os.time())
     local hour = nowTime["hour"]

     if (hour >= 18 and hour < 20) or (hour >= 12 and hour < 14) then
         if t > 0 then
             local lastTime = os.date("*t", t)
             if nowTime["month"] > lastTime["month"] then
                 return 1
             elseif nowTime["month"] == lastTime["month"] then
                 if nowTime["day"] > lastTime["day"] then
                     return 1
                 elseif nowTime["day"] == lastTime["day"] then
                     if (lastTime["hour"] >= 18 and lastTime["hour"] < 20) then
                         return 0
                     elseif (nowTime["hour"] >= 18 and nowTime["hour"] < 20) then
                         return 1
                     end
                 end
             end
             return 0
         else
            return 1
         end
     else
         return 0
     end
 end

function Player:updateNotification(data)
    -- [ 商店--免费抽卡次数 ， 精英副本的次数 ，活动副本的次数 ，签到领奖次数 ,
    -- [开服礼包是否显示,开服礼包数] ,[等级礼包显示 ,等级礼包数] ,[领奖中心显示 ，领奖中心数]]

    if data ~= nil and type(data) == "table" then 
        dump(data)

        -- 商店免费抽卡次数
        self.m_choukaNum = data[1] or 0

        -- 精英副本的次数
        self:setJingyingNum(data[2] or 0)

        -- 活动副本的次数
        self:setHuodongNum(data[3] or 0) 

        -- 签到
        self.m_qiandaoNum = data[4] or 0

        -- 开服礼包
        local kaifu = data[5]
        if kaifu ~= nil then 
            if kaifu[1] == 1 then 
                self.m_isShowKaifuLibao = true 
            else
                self.m_isShowKaifuLibao = false 
            end

            self.m_kaifulibao = kaifu[2] or 0
        else
            self.m_isShowKaifuLibao = false
            self.m_kaifulibao = 0
        end

        -- 等级礼包
        local dengji = data[6]
        if dengji ~= nil then 
            if dengji[1] == 1 then 
                self.m_isSHowDengjiLibao = true 
            else
                self.m_isSHowDengjiLibao = false 
            end

            self.m_dengjilibao = dengji[2] or 0
        else
            self.m_isSHowDengjiLibao = false
            self.m_dengjilibao = 0
        end

        -- 奖励中心
        local rewardcenter = data[7]
        if rewardcenter ~= nil then 
            if rewardcenter[1] == 1 then 
                self.m_isShowRewardCenter = true 
            else
                self.m_isShowRewardCenter = false 
            end
            self.m_rewardcenterNum = rewardcenter[2] or 0
        else
            self.m_isShowRewardCenter = false
            self.m_rewardcenterNum = 0
        end

        if data[8] ~= nil and data[8] > 0 then
        	self.m_isShowChengzhang = true
        else 
        	self.m_isShowChengzhang = false
        end

    end
end


function Player:initNotification()
    self.m_onlineRewardTime = 0         -- 距离下次领取在线奖励时间
    self.m_isShowOnlineReward = false   -- 是否还有在线奖励可领取
    self.m_isShowRewardCenter = false   -- 是否领奖中心有未领取的奖励
    self.m_isShowKaifuLibao = true      -- 是否显示开服礼包
    self.m_isSHowDengjiLibao = true     -- 是否显示等级礼包 
    self.m_isShowChengzhang = false    -- 成长之路

    self.m_choukaNum = 0   -- 免费抽卡次数
    self.m_qiandaoNum = 0
    self.m_kaifulibao = 0
    self.m_dengjilibao = 0
    self.m_rewardcenterNum = 0 
    self.m_chatNewNum = 0   -- 新的未读取消息的长度

    self.m_jingyingNum = 0 
    self.m_huodongNum = 0 

    self.m_guildApplyNum = 0    -- 帮派成员申请数量  

    -- 免费抽卡次数
    self.getChoukaNum = function() 
        return self.m_choukaNum
    end

    self.setChoukaNum = function(_, num)
        self.m_choukaNum = num
        if self.m_choukaNum < 0 then
            self.m_choukaNum = 0
        end
    end

    -- 签到
    self.getQiandaoNum = function()
        return self.m_qiandaoNum
    end

    self.setQiandaoNum = function(_, num)
        self.m_qiandaoNum = num
        if self.m_qiandaoNum < 0 then
            self.m_qiandaoNum = 0
        end
    end

    -- 奖励中心
    self.getRewardcenterNum = function()
        return self.m_rewardcenterNum
    end

    self.setRewardcenterNum = function(_, num)
        self.m_rewardcenterNum = num
        if self.m_rewardcenterNum <= 0 then
            self.m_rewardcenterNum = 0
            self.m_isShowRewardCenter = false
        end
    end

    -- 开服礼包
    self.getKaifuLibao = function()
        return self.m_kaifulibao
    end

    self.setKaifuLibao = function(_, num)
        self.m_kaifulibao = num
        if self.m_kaifulibao <= 0 then 
            self.m_kaifulibao = 0 
        end
    end

    -- 等级礼包
    self.getDengjilibao = function()
        return self.m_dengjilibao
    end

    self.setDengjilibao = function(_, num)
        self.m_dengjilibao = num
        if self.m_dengjilibao <= 0 then
            self.m_dengjilibao = 0 
        end
    end

    -- 未读的聊天消息
    self.getChatNewNum = function()
        return self.m_chatNewNum
    end

    self.setChatNewNum = function(_, num)
        self.m_chatNewNum = num
        if self.m_chatNewNum <= 0 then
            self.m_chatNewNum = 0 
        end
    end

    -- 精英副本
    self.getJingyingNum = function()
        return self.m_jingyingNum
    end

    self.setJingyingNum = function(_, num)
        self.m_jingyingNum = num
        if self.m_jingyingNum <= 0 then 
            self.m_jingyingNum = 0 
        end
    end 

    -- 活动副本
    self.getHuodongNum = function()
        return self.m_huodongNum
    end

    self.setHuodongNum = function(_, num)
        self.m_huodongNum = num 
        if self.m_huodongNum <= 0 then 
            self.m_huodongNum = 0 
        end
    end

    self.getIsShowChallengeNotice = function() 
        local bHasOpen_hd = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.HuoDong_FuBen, self.m_level, self.m_vip) 
        local bHasOpen_jy = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.JiYing_FuBen, self.m_level, self.m_vip)  

        if self.m_huodongNum > 0 and bHasOpen_hd then 
            return true 
        elseif self.m_jingyingNum > 0 and bHasOpen_jy then 
            return true 
        else
            return false 
        end 
    end 

    -- 帮派成员 申请数量 
    self.setGuildApplyNum = function(_, num)
        self.m_guildApplyNum = num 
        if self.m_guildApplyNum <= 0 then 
            self.m_guildApplyNum = 0 
        end 
    end 

    self.getGuildApplyNum = function()
        return self.m_guildApplyNum 
    end 

end


function Player:init( data )
    
    dump(data)
	-- 基本属性
    self.m_playerID = data.id -- 玩家id，供查询
    -- fixme 以后要用真实玩家名字
	self.m_name     = data.name or "name"-- 玩家自定义名字
	self.m_title    = ""-- 头衔	
	self.m_level    = data.level or 0 -- 等级 
	self.m_exp      = data.exp or 0 -- 玩家经验
	self.m_gold     = data.gold or 0 -- 金
	self.m_silver   = data.silver or 0 -- 银
	self.m_energy   = data.resisVal -- 耐力
	self.m_strength = data.physVal -- 体力
    self.m_battlepoint = data.attack -- 战力
    self.m_class = data.cls or 0  -- 阶数
    self.m_star  = data.star or 3
    self.m_maxStrength = data.propLimitAry[1] or 0
    self.m_maxEnergy = data.propLimitAry[2] or 0
    self.m_maxExp = data.propLimitAry[3] or 0

    self.m_gender = data.resId -- 性别

    self.m_befExp = data.exp or 0 --玩家升级前的
    -- vip
    self.m_vip      = data.vip or 0     -- VIP等级

    -- 是否充值过 
    self.m_isHasBuyGold = false        -- 是否充值过


    local _items  = {}    --背包物品
    local _spirit = {}    --精元
    local _equips = {}    --装备
    local _hero   = {}    --英雄
    local _spiritBagMax = 0
    self.setSpiritBagMax = function(_, num)
        _spiritBagMax = num
    end

    self.getSpiritBagMax = function()
        return _spiritBagMax or 0
    end

    self.getStar = function(_)
        return self.m_star  or 0
    end

    self.setSkills = function(_, skills)
        self.m_skills = skills
    end

    self.getSkills = function(_, sortFunc)
        if sortFunc then
            table.sort(self.m_skills, sortFunc)
        end
        return self.m_skills
    end

    self.setHero = function(_, hero)
       _hero = hero
       table.sort(_hero, function(lh, rh)
           if lh.pos > 0 and rh.pos == 0 then
               return true
           elseif lh.pos == 0 and rh.pos > 0 then
               return false
           else
               return lh.star > rh.star
           end
       end)
    end


    self.getHero = function(_)
        HeroModel.sort(_hero)
        return _hero
    end

    self.getEquipments = function()
        return _equips
    end

    self.setEquipments = function(_, equip)
        _equips = equip
    end

    self.getLevel = function()
        return self.m_level
    end

    self.setItem = function(_, id, num)
        _items[id] = num
    end
--
    self.getItem = function(_, id)
        return _items[id] or 0
    end

    self.setSpirit = function(_, spirit)
        _spirit = spirit
    end

    self.getSpirit = function(_, sortFunc)
        _spirit = require("game.Spirit.SpiritCtrl"):getSpirit()
        if sortFunc then
            table.sort(_spirit, sortFunc)
        end
        return _spirit
    end


    local _bagCountMax = 0    --背包最大容量
    local _bagCountUsed = 0   --背包已经使用的的

    self.getGold = function(_)
        return self.m_gold  or 0
    end

    self.setGold = function(_, num)
        self.m_gold = num
    end

    self.setSilver = function(_, num)
        self.m_silver = num
    end

    self.addSilver = function(_, num)
        self.m_silver = self.m_silver + num
        return self.m_silver  or 1
    end

    self.getSilver = function()
        return self.m_silver  or 1
    end

    self.getBagCountMax = function(_)
        return _bagCountMax or 1
    end

    self.getBagCountUsed = function(_)
        return _bagCountUsed or 1
    end

    self.setBagCountMax = function(_, count)
        _bagCountMax = count
    end

    self.setBagCountUsed = function(_, count)
        _bagCountUsed = count
    end

    self.setStrength = function ( _, num )
        self.m_strength = num
    end

    self.getStrength = function()
        return self.m_strength or 0
    end

    self.addStrength = function(_, num)
        self.m_strength = self.m_strength + num
    end

    self.getBattlePoint = function()
        return self.m_battlepoint or 0
    end

    self.getPlayerName = function()
        return self.m_name or ""
    end

    self.getClass = function()
        return self.m_class + 1
    end

    self.getNaili = function()
        return self.m_energy
    end

    self.getExp = function()
        return self.m_exp  or 0
    end
    
    self.getMaxExp = function()
        return self.m_maxExp or 0
    end

    self.getGender = function()
        return self.m_gender or 0
    end
    
    self.updateLevelUpData = function(_, param) 
        self.m_levelUpAry.isLevelUp = param.isLevelUp or false 
        self.m_levelUpAry.beforeLevel = param.beforeLevel or self.m_level
        self.m_levelUpAry.curLevel = param.curLevel or self.m_level
    end

    self.getLevelUpData = function()
        return self.m_levelUpAry 
    end 

    self.getVip = function()
        return self.m_vip
    end

    self.setVip = function(_, vip)
        self.m_vip = vip or self.m_vip 
    end


    self.getIsHasBuyGold = function()
        return self.m_isHasBuyGold
    end

    self.setIsHasBuyGold = function(_, hasBuy)
        self.m_isHasBuyGold = hasBuy or self.m_isHasBuyGold 
        PostNotice(NoticeKey.MainMenuScene_Shouchong) 
    end 

    self.getPlayerIconName = function ( )
        local data_card_card = require("data.data_card_card")
        local gender = self.m_gender
        -- print("gettttclasss "..self:getClass())
        return  data_card_card[gender].arr_role_icon[self:getClass()] .. ".png"
    end

    -- 邮件红点提示

    self.setMailTip = function ( _, mailTip )
        self.m_mail_battle = mailTip.battle or 0
        self.m_mail_friend = mailTip.friend or 0
        self.m_mail_system = mailTip.system or 0

    end


    self.resetMailBattle = function ()
        self.m_mail_battle = 0
    end
    self.getMailBattle = function (  )
        return self.m_mail_battle 
    end

    self.resetMailFriend = function ()
        self.m_mail_friend = 0
    end
    self.getMailFriend = function (  )
        return self.m_mail_friend 
    end

    self.resetMailSystem = function ()
        self.m_mail_system = 0
    end
    self.getMailSystem = function (  )
        return self.m_mail_system 
    end

    self.hasMailTip = function (  )
        -- dump(self:getMailBattle())
        -- dump(self:getMailFriend())
        -- dump(self:getMailSystem())
        if( self:getMailBattle() > 0 or self:getMailFriend() > 0 or self:getMailSystem() > 0 ) then
            return true
        end
        return  false
    end
    
end

function Player:getPlayerID()
    return self.m_playerID
end

function Player:updateMainMenu( param )
    self.m_silver      = param.silver or self.m_silver
    self.m_gold        = param.gold or self.m_gold
    self.m_battlepoint = param.zhanli or self.m_battlepoint
    
    self.m_energy      = param.naili or self.m_energy
    self.m_maxEnergy   = param.maxNaili or self.m_maxEnergy
    
    self.m_strength    = param.tili or self.m_strength
    self.m_maxStrength = param.maxTili or self.m_maxStrength

    self.m_befExp      = self.m_exp or param.exp  --保存之前的经验值
    
    self.m_exp         = param.exp or self.m_exp
    self.m_maxExp      = param.maxExp or self.m_maxExp
    self.m_level       = param.lv or self.m_level
    self.m_vip         = param.vip or self.m_vip

    if param.hasBuyGold ~= nil then 
        if param.hasBuyGold == 1 then 
            self.m_isHasBuyGold = true 
        elseif param.hasBuyGold == 0 then 
            self.m_isHasBuyGold = false 
        end 
    end 

        
         -- 8: 睡觉  9：boss  10：现实豪杰
        local guildBoss = param.unionBossState or 0
        local sleepState = param.sleepState or 0
        dump(param)
        self.m_quickAccessState = {
            [QuickAccess.SLEEP] = isCanSleep(sleepState),
            [QuickAccess.BOSS] = param.bossState or 0,
            [QuickAccess.LIMITCARD] = param.limitCardstate or 0,
            [QuickAccess.GUILD_BOSS] = guildBoss - 1,
            [QuickAccess.GUILD_BBQ] = param.bbqState,
            [QuickAccess.CAIQUAN] = param.caiquan or 0,
            [QuickAccess.YABIAO] = param.yabiao or 0,
            [QuickAccess.TANBAO] = param.rouletteStatus or 0,

--            [QuickAccess.SLEEP] = 1,
--            [QuickAccess.BOSS] = 1,
--            [QuickAccess.LIMITCARD] = 1
        }


        dump(self.m_quickAccessState)
end

--[[
    初始化 玩家基本信息
    m_uid       : 唯一标识
    session     : 有些平台需要
    platformID  : 平台标识
]]
function Player:initBaseInfo( param )

    dump("param.platformID: " .. tostring(param.platformID))
    dump(param)
    local function loadStorge(  )
        local uid = CCUserDefault:sharedUserDefault():getStringForKey("accid") 
        if(uid == nil or uid == "") then
            uid = os.time()
            CCUserDefault:sharedUserDefault():setStringForKey("accid", uid)
            CCUserDefault:sharedUserDefault():flush()
        end
        self.m_uid = uid 

        self.m_sessionID = 0
        self.m_platformID = param.platformID
        self.m_loginName = param.nickname or ""
    end

    if(GAME_DEBUG == true) then
		-- simultor
		if(device.platform == "mac" or device.platform == "windows") then

			loadStorge()
			
		-- device
		else
			-- pure package without any SDK
			if(ANDROID_NO_SDK == true) then
				if(device.platform == "android") then
					if(GAME_DEBUG == true) then
						loadStorge()
					end
				end
			else
				if CSDKShell.GetSDKTYPE() == SDKType.SIMULATOR then
					loadStorge()
				else
					self.m_sdkID = param.uin

					self.m_sessionID  = param.sessionId
					self.m_platformID = param.platformID
					if(game.nickname ~= "") then
						self.m_loginName = param.nickname or ""
					end
				end
			end
			-- device.showAlert(self.m_loginName, "")
		end
	else
		self.m_sdkID = param.uin
	
		self.m_sessionID  = param.sessionId
		self.m_platformID = param.platformID
		if(game.nickname ~= "") then
			self.m_loginName = param.nickname or ""
		end
	end


 
end

function Player:deleteUID()
    -- self.m_uid = nil 
    CCUserDefault:sharedUserDefault():setStringForKey("accid", "")
    CCUserDefault:sharedUserDefault():flush() 
end


function Player:setUid(uid)
    if uid ~= nil then 
        self.m_uid = uid 
        -- CCUserDefault:sharedUserDefault():setStringForKey("accid", self.m_uid)
        -- CCUserDefault:sharedUserDefault():flush() 
    end 
end 


function Player:setExtendData(extend)
    if extend ~= nil then 
        self.m_extendData = extend 
    end 
end


function Player:canSetSpeed( nextSpeed ,isShowLabel)
    local data_item_speed = require("data.data_item_speed")
    if(self.m_level >= data_item_speed[nextSpeed].level) then        
        return true
    else
        if isShowLabel ~= false then
            show_tip_label("[" ..data_item_speed[nextSpeed].level .. "级]开放 " .. nextSpeed .. " 倍速")
        end
        local isDebug = false
        if GAME_DEBUG == true then
            isDebug = true
        end
        return isDebug
    end
end

-- 根据acc判断是否是玩家自己
function Player:checkIsSelfByAcc(acc)
    local bSelf = false 
    local selfAcc = self.m_uid 

    if(GAME_DEBUG == true) then 
        -- mac or win 模拟器使用本地accid
        if(device.platform == "mac" or device.platform == "windows") then
            selfAcc = "simulate__" .. self.m_uid
        end 

    end

    if acc == selfAcc then 
        bSelf = true 
    end 

    return bSelf 
end 

function Player:getBagReq( cb )
    local RequestInfo = require("network.RequestInfo")
    local reqs = {}
    local data1, data2
        --请求内外功
    table.insert(reqs, RequestInfo.new({
        modulename = "skill",
        funcname = "list",
        param = {},
        oklistener = function(data)
            data1 = data
            -- game.player:setSkills(data["1"])
            -- -- dump(data["1"])
            -- self._item[VIEW_TYPE.BAG_SKILL] = game.player:getSkills()
            -- self._cap[VIEW_TYPE.BAG_SKILL] = {data["2"], data["3"] }
            -- self._cost[VIEW_TYPE.BAG_SKILL] = {data["4"], data["5"]}
        end
    }))

    table.insert(reqs, RequestInfo.new({
        modulename = "packet",
        funcname   = "list",
        param      = {},
        oklistener = function(data)

            -- self._item[VIEW_TYPE.BAG_ITEM] = data["1"]
            -- self._cap[VIEW_TYPE.BAG_ITEM] = {data["2"], data["3"] }
            -- self._cost[VIEW_TYPE.BAG_ITEM] = {data["4"], data["5"]}
            data2 = data
        end
    }))

    RequestHelperV2.request2(reqs, function()
        cb(data1, data2)
    end)
end

return Player