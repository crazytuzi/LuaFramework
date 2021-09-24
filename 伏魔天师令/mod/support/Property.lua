-- {人物普通属性}
-- 直接将协议放进来
-- attr这个属性,直接放进去CCharacterWarProperty
local Property = classGc(function(self)
    self.uid                    = nil --玩家UID
    self.name                   = nil --玩家姓名
    self.name_color             = nil --名字颜色
    self.pro                    = nil --玩家职业      --伙伴共用
    self.sex                    = nil --玩家性别
    self.lv                     = 0   --玩家等级      --伙伴共用
    self.rank                   = nil --竞技排名
    self.country                = nil --阵营类型(见常量)
    self.clan                   = nil --家族ID
    self.clan_name              = nil --家族名称
    self.clan_post              = nil --家族职位
    self.attr                   = require("mod.support.PropertyWar")()--角色基本属性块2002 --伙伴共用
    self.powerful               = nil --玩家战斗力     --伙伴共用
    self.renown                 = 0   --玩家妖魂值
    self.exp                    = 0   --经验值        --伙伴共用
    self.expn                   = nil --下级要多少经验 --伙伴共用
    self.skin_weapon            = nil --武器皮肤
    self.skin_armor             = nil --衣服皮肤
    self.power                  = nil -- 道行
    self.count                  = nil --伙伴数量 (循环)
    self.partner                = nil --伙伴ID        --伙伴共用
    self.partner_idx            = nil --伙伴标识符        --伙伴共用
    self.stata                  = nil --伙伴状态      --伙伴使用
    self.lock                   = nil --伙伴锁定
    self.normalEquip_list             = {} --装备链表
    self.artifacfEquip_list     = {} --神器链表
    self.allEquipIdx_list       = {} --所有装备对应的index链表
    self.m_partList             = {} --装备部位信息

    self.alls_power             = 0   --总战斗力
    self.is_guide               = 0   --[Base]新手指导员 (0:正常状态|1:指导员)
    self.title_msg              = {}  --称号信息

    self.m_mountId              = 0
    self.m_mountTexiao          = 0  --坐骑特效：0没有

    self.isRedName              = nil --是否红名

    self.gold                   = 0  -- {银元}
    self.rmb                    = 0  -- {金元}
    self.bind_rmb               = 0  -- {绑定金元}

    self.sum                    = 0  -- {当前体力值}
    self.max                    = 0  -- {最大体力值}

    self.vipLv                  = nil -- {自己的vip等级}
    self.vipUp                  = nil -- {已购买金元总数}

    self.team_id                = 0  -- {队伍ID}
    self.isTeam                 = false --{是否组队战}

    --与服务器下发数据无关
    self.m_copyGuideData         = nil -- {当前副本信息}

    --额外赠送精力  --角色
    self.buff_value             = nil
    --------------------------------------------------------
    self.autoStatus             = nil -- 自动状态
    self.soulStatus             = nil -- 灵魂状态
    self.ai_id                  = nil -- 伙伴用 AI
    self.funList                = {} --函数列表

    self.m_wingSkin = 0 -- {宠物}
    self.m_wingLv = 0 -- {宠物等阶}
    self.m_artifactSkillId=0 -- {神器技能ID}
    self.m_artifactSkillLv=0 -- {神器技能LV}
    self.meiren_id = 0 -- {美人Id}
    self.m_skinFeather = 0 -- {翅膀ID}
    self.m_featherLv = 0 -- {翅膀等级}
    self.ext1 = 0 -- {扩展1}
    self.ext2 = 0 -- {扩展2}
    self.ext3 = 0 -- {扩展3}
    self.ext4 = 0 -- {扩展4}
    self.ext5 = 0 -- {扩展5}

    self.m_xuanJing = 0 --玄铁

    self:initFunList()
end)

function Property.initFunList( self )
    self.funList[_G.Const.CONST_ATTR_COUNTRY]            = self.setCountry           --国家
    self.funList[_G.Const.CONST_ATTR_COUNTRY_POST]       = self.setCountryPost       --国家-职位
    self.funList[_G.Const.CONST_ATTR_CLAN]               = self.setClan              --家族ID
    self.funList[_G.Const.CONST_ATTR_CLAN_NAME]          = self.setClanName          --家族名字
    self.funList[_G.Const.CONST_ATTR_CLAN_POST]          = self.setClanPost          --家族职位
    self.funList[_G.Const.CONST_ATTR_NAME_COLOR]         = self.setNameColor         --角色名颜色
    self.funList[_G.Const.CONST_ATTR_LV]                 = self.setLv                --等级
    self.funList[_G.Const.CONST_ATTR_VIP]                = self.setVipLv             --vip等级
    self.funList[_G.Const.CONST_ATTR_ENERGY]             = self.setEnergy            --精力
    self.funList[_G.Const.CONST_ATTR_EXP]                = self.setExp               --经验值
    self.funList[_G.Const.CONST_ATTR_EXPN]               = self.setExpn              --下级要多少经验
    self.funList[_G.Const.CONST_ATTR_EXPT]               = self.setExpt              --总共集了多少 经验
    self.funList[_G.Const.CONST_ATTR_RENOWN]             = self.setRenown            --妖魂
    self.funList[_G.Const.CONST_ATTR_SOUL]               = self.setSoul              --妖灵
    self.funList[_G.Const.CONST_ATTR_SLAUGHTER]          = self.setSlaughter         --杀戮值
    self.funList[_G.Const.CONST_ATTR_HONOR]              = self.setHonor             --修为值
    self.funList[_G.Const.CONST_ATTR_POWERFUL]           = self.setPowerful          --战斗力
    self.funList[_G.Const.CONST_ATTR_NAME]               = self.setName              --名字
    self.funList[_G.Const.CONST_ATTR_RANK]               = self.setRank              --排名
    self.funList[_G.Const.CONST_ATTR_WEAPON]             = self.setSkinWeapon        --装备武器id（换装）
    self.funList[_G.Const.CONST_ATTR_ARMOR]              = self.setSkinArmor         --装备衣服id（换装）
    self.funList[_G.Const.CONST_ATTR_FASHION]            = self.setFashion           --装备时装id(换装)
    self.funList[_G.Const.CONST_ATTR_MOUNT]              = self.setMount             --坐骑
    self.funList[_G.Const.CONST_ATTR_TEXIAO]             = self.setMountTexiao       --坐骑特效
    self.funList[_G.Const.CONST_ATTR_S_HP]               = self.setSHp               --气血(现有战斗中)
    self.funList[_G.Const.CONST_ATTR_ALLS_POWER]         = self.setAllsPower         --总战斗力
    self.funList[_G.Const.CONST_CURRENCY_ADV_SKILL+1]      = self.setPower             -- 道行


end


-- {玩家UID}
function Property.getUid(self)
    return self.uid
end
function Property.setUid(self, _uid )
    self.uid = _uid
end

-- {玩家姓名}
function Property.getName(self)
    return self.name
end
function Property.setName(self, _name)
    self.name = _name
end

-- {名字颜色}
function Property.getNameColor(self)
    return self.name_color
end
function Property.setNameColor(self, _color)
    self.name_color = _color
end

-- {玩家职业}
function Property.getPro(self)
    return self.pro
end
function Property.setPro(self, _pro)
    self.pro = _pro
end

-- {玩家性别}
function Property.getSex(self)
    return self.sex
end
function Property.setSex(self, _sex)
    self.sex = _sex
end

-- {玩家等级}
function Property.getLv(self)
    print("getLv--->",self.lv)
    return self.lv
end
function Property.setLv(self, _lv)
    self.lv = _lv
end

-- {竞技排名}
function Property.getRank(self)
    return self.rank
end
function Property.setRank(self, _rank)
    self.rank =_rank
end

-- {阵营类型(见常量)}
function Property.getCountry(self)
    return self.country
end
function Property.setCountry(self, _country)
    self.country = _country
end

-- {家族ID}
function Property.getClan(self)
    return self.clan
end
function Property.setClan(self, _clan)
    self.clan = _clan
end

-- {家族名称}
function Property.getClanName(self)
    return self.clan_name
end
function Property.setClanName(self, _clanName)
    self.clan_name = _clanName
end

-- {家族职位}
function Property.getClanPost(self)
    return self.clan_post
end
function Property.setClanPost(self, _clanPost)
    self.clan_post = _clanPost
end

-- {角色基本属性块2002}
function Property.getAttr(self)
    return self.attr
end
function Property.setAttr(self, _arrt)
    self.attr = _arrt
end

-- {玩家战斗力}
function Property.getPowerful(self)
    return self.powerful
end
function Property.setPowerful(self, _powerful)
    self.powerful = _powerful
end

-- {经验值}
function Property.getExp(self)
    return self.exp
end
function Property.setExp(self, _exp)
    self.exp = _exp
end

-- {下级要多少经验}
function Property.getExpn(self)
    return self.expn
end
function Property.setExpn(self, _expn)
    self.expn = _expn
end

-- {妖魂值}
function Property.getRenown(self)
    return self.renown
end
function Property.setRenown(self, _renown)
    print("setRenown==>>",_renown)
    self.renown = _renown
end

-- {妖灵值}
function Property.getSoul(self)
    return self.soul
end
function Property.setSoul(self, _soul)
    self.soul = _soul
end

-- {武器皮肤}
function Property.getSkinWeapon(self)
    return self.skin_weapon
end
function Property.setSkinWeapon(self, _skinWeapon)
    self.skin_weapon = _skinWeapon
end

-- {衣服皮肤}
function Property.getSkinArmor(self)
    return self.skin_armor
end
function Property.setSkinArmor(self, _skinArmor)
    self.skin_armor = _skinArmor
end

-- {伙伴数量}
function Property.getCount(self)
    return self.count
end
function Property.setCount(self, _count)
    self.count = _count
end

-- {伙伴ID}
function Property.getPartnerId(self)
    return self.partner
end

function Property.setPartnerId(self, _partner)
    self.partner = _partner
end

function Property.setWarPartner(self,_property)
    print("setWarPartner=======>>>",_property)
    self.m_warPartner=_property
end
function Property.getWarPartner(self)
    print("getWarPartner=======>>>", self.m_warPartner)
    return self.m_warPartner
end

--{伙伴道行}
function Property.setPower(self,_power)
  print("setPower======>>>",_power)
  self.power  = _power
end 

function Property.getPower(self,_power)
  print("getPower======>>>",self.power)
  return   self.power
end 

-- {伙伴ID标识符}
function Property.getPartner_idx(self)
    return self.partner_idx
end

function Property.setPartner_idx(self, _partner)
    self.partner_idx = _partner
end

-- {伙伴状态}
function Property.getStata(self)
    return self.stata
end
function Property.setStata(self, _stata)
    self.stata = _stata
end

-- {伙伴锁定}
function Property.getLock(self)
    return self.lock
end
function Property.setLock(self, _lock)
    self.lock = _lock
end

-- {装备数量}
function Property.getEquipCount( self)
    return #self:getEquipList()
end
-- {装备链表}
function Property.getEquipList( self)
    return self.normalEquip_list
end

-- {神器装备数量}
function Property.getArtifactEquipCount( self)
    return #self:getArtifactEquipList()
end
-- {神器装备链表}
function Property.getArtifactEquipList( self)
    return self.artifacfEquip_list
end

function Property.setAllEquipList( self, _goodsList )
    self.normalEquip_list   = {}
    self.artifacfEquip_list = {}
    self.allEquipIdx_list   = {}
    for _,goodMsg in ipairs(_goodsList) do
        goodMsg.isEquip=true
        goodMsg.user=self.uid
        local index = goodMsg.index
        local _type = goodMsg.goods_type
        local _pos  = 1

        if _type == _G.Const.CONST_GOODS_MAGIC then
            --神器
            table.insert( self.artifacfEquip_list, goodMsg )
            _pos = #self.artifacfEquip_list
        else
            table.insert( self.normalEquip_list, goodMsg )
            _pos = #self.normalEquip_list
        end
        print("[装备更新] 新装备->1  index="..index.."  id="..goodMsg.goods_id.."  type=".._type.."   pos=".._pos)

        self.allEquipIdx_list[index] = {}
        self.allEquipIdx_list[index].type = _type
        self.allEquipIdx_list[index].pos  = _pos
    end
end

-- {装备部位信息}
function Property.setEquipPartList(self,_partList)
    self.m_partList=_partList or {}
end
function Property.updateEquipPart(self,_partMsg)
    self.m_partList[_partMsg.type_sub]=_partMsg
end
function Property.getEquipPartByIdx(self,_idx)
    return self.m_partList[_idx]
end
function Property.getEquipPartList(self)
    return self.m_partList
end
function Property.getEquipPartListBySort(self)
    local newArray={}
    local newCount=0
    for k,v in pairs(self.m_partList) do
        newCount=newCount+1
        newArray[newCount]=v
    end
    if newCount>1 then
        local function sort(v1,v2)
            return v1.type_sub<v2.type_sub
        end
        table.sort(newArray,sort)
    end
    return newArray
end


function Property.chuangeSomeEquip( self, _goodsList )
    for i,goodMsg in ipairs(_goodsList) do
        goodMsg.isEquip=true
        goodMsg.user=self.uid
        local index = goodMsg.index
        local _type = goodMsg.goods_type
        if self.allEquipIdx_list[index] == nil then
            --新装备
            local _pos  = 1
            if _type == _G.Const.CONST_GOODS_MAGIC then
                --神器
                table.insert( self.artifacfEquip_list, goodMsg )
                _pos = #self.artifacfEquip_list
            else
                table.insert( self.normalEquip_list, goodMsg )
                _pos = #self.normalEquip_list
            end
            print("[装备更新] 新装备->2  index="..index.."  id="..goodMsg.goods_id.."  type=".._type.."   pos=".._pos)
            _G.Util:playAudioEffect("balance_reward")
            self.allEquipIdx_list[index] = {}
            self.allEquipIdx_list[index].type = _type
            self.allEquipIdx_list[index].pos  = _pos
        else
            local pos = self.allEquipIdx_list[index].pos
            print("[装备更新] 替换装备->  index="..index.."  id="..goodMsg.goods_id.."  type=".._type.."  pos="..pos)
            --更新装备
            if _type == _G.Const.CONST_GOODS_MAGIC then
                self.artifacfEquip_list[pos] = goodMsg
            else
                self.normalEquip_list[pos] = goodMsg
            end
            self.allEquipIdx_list[index].type = _type
        end
    end
end

function Property.removeSomeEquip( self, _goodsIndexList )
    local normalList   = {}
    local artifacfList = {}
    self.allEquipIdx_list = {}
    print("[装备更新] 移除装备")
    for i,goodMsg in ipairs(self.normalEquip_list) do
        local index = goodMsg.index
        if _goodsIndexList[index] ~= true then
            --还存在此装备
            table.insert( normalList, goodMsg )
            self.allEquipIdx_list[index] = {}
            self.allEquipIdx_list[index].type = goodMsg.goods_type
            self.allEquipIdx_list[index].pos  = #normalList

            print("[装备更新] 剩下的装备->  index="..index.."  id="..goodMsg.goods_id.."  type="..goodMsg.goods_type.."  pos="..#normalList)
        end
    end
    for i,goodMsg in ipairs(self.artifacfEquip_list) do
        local index = goodMsg.index
        if _goodsIndexList[index] ~= true then
            --还存在此装备
            table.insert( artifacfList, goodMsg )
            self.allEquipIdx_list[index] = {}
            self.allEquipIdx_list[index].type = goodMsg.goods_type
            self.allEquipIdx_list[index].pos  = #artifacfList

            print("[装备更新] 剩下的装备->  index="..index.."  id="..goodMsg.goods_id.."  type="..goodMsg.goods_type.."  pos="..#normalList)
        end
    end
    self.normalEquip_list   = normalList
    self.artifacfEquip_list = artifacfList
end


-- {是否红名}
function Property.getIsRedName(self)
    return self.isRedName
end
function Property.setIsRedName(self, _isRedName)
    self.isRedName = _isRedName
end

-- {银元}
function Property.getGold(self)
    return self.gold
end
function Property.setGold(self, _gold)
    self.gold = _gold
end

-- {金元}
function Property.getRmb(self)
    return self.rmb
end
function Property.setRmb(self, _rmb)
    self.rmb = _rmb
end

-- {绑定金元}
function Property.getBindRmb(self)
    return self.bind_rmb
end
function Property.setBindRmb(self, _bindRmb)
    self.bind_rmb = _bindRmb
end

-- {玄铁}
function Property.getXuanJing(self)
    return self.m_xuanJing
end
function Property.setXuanJing(self, _xuanJing)
    self.m_xuanJing = _xuanJing
end

-- {妖灵}
function Property.getYaoLing(self)
    return self.m_yaoling
end
function Property.setYaoLing(self, _yaoling)
    self.m_yaoling = _yaoling
end

function Property.getAllRmb( self )
    local rmb=self:getRmb() or 0
    local bind_rmb=self:getBindRmb() or 0
    return rmb+bind_rmb
end

-- {当前体力值}
function Property.getSum(self)
    return self.sum
end
function Property.setSum(self, _sum)
    self.sum = _sum
end

-- {最大体力值}
function Property.getMax(self)
    return self.max
end
-- {最大体力值}
function Property.setMax(self, _max)
    self.max = _max
end

-- {自己的vip等级}
function Property.getVipLv(self)
    print("getVipLv.vipLv--->",self.vipLv)
    return self.vipLv
end
function Property.setVipLv(self, _lv)
    print("setVipLv------>",_lv) 
    self.vipLv = _lv
end

-- {已购买金元总数}
function Property.getVipUp(self)
    return self.vipUp
end
function Property.setVipUp(self, _vipUp)
    self.vipUp = _vipUp
end

-- {队伍ID}
function Property.getTeamID( self )
    return self.team_id or 0
end
function Property.setTeamID( self, _teamID )
    self.team_id = _teamID
end

function Property.getIsTeam( self )
    return self.isTeam
end
function Property.setIsTeam( self, _isTeam )
    self.isTeam = _isTeam
end

-- {总战斗力}
function Property.setAllsPower( self, _allsPower )
    self.alls_power = _allsPower
end
function Property.getAllsPower( self )
    return self.alls_power
end

-- {新手指导员}
function Property.setIs_guide( self, _is_guide )
    self.is_guide = _is_guide
end
function Property.getIs_guide( self )
    return self.is_guide
end
--[[
-- {战功}
function Property.setPower( self, _power )
    self.power = _power
end
function Property.getPower( self )
    return self.power
end
--]]

-- {称号信息}
function Property.setTitle_msg( self, _title_msg )
    self.title_msg = _title_msg
end
function Property.getTitle_msg( self )
    return self.title_msg
end

-- {神器信息}
function Property.setmagicSkinIdmsg( self, _magic_msg )
    self.magic_msg = _magic_msg
end
function Property.getmagicSkinIdmsg( self )
    return self.magic_msg
end


-- {AI}
function Property.getAI(self)
    return self.ai_id
end
function Property.setAI(self, _AI)
    self.ai_id = _AI
end

-- [1262]额外赠送精力 -- 角色
function Property.setBuffValue( self, valueForKey)
    self.buff_value = valueForKey
end
function Property.getBuffValue( self)
    return self.buff_value
end

-- 总体力
function Property.getAllEnergy(self)
    local buff      = self:getBuffValue() or 0
    local energyHas = self:getSum() + buff
    return energyHas
end

--技能信息
function Property.setSkillData( self, _data)
    self.m_skillData = _data
end
function Property.getSkillData( self)
     if self.m_skillData == nil then
        self.m_skillData = require("mod.support.SkillData")()
    end
    return self.m_skillData
end

function Property.setMountId( self,_mountId )
    self.m_mountId=_mountId
end
function Property.getMountID( self )
    return self.m_mountId
end
function Property.setMountLv( self,_lv )
    self.m_mountLv=_lv
end
function Property.getMountLv( self )
    return self.m_mountLv
end

function Property.setMountTexiao( self, _mountTexiao )
    print( "Property.setMountTexiao, _mountTexiao = ", _mountTexiao )
    self.m_mountTexiao=_mountTexiao
end
function Property.getMountTexiao( self )
    return  self.m_mountTexiao
end

--翅膀id
function Property.setSkinshapedId( self,_skin_shapeId )
    self.m_skin_shapeId=_skin_shapeId
end

function Property.getSkinshapedId( self )
    return self.m_skin_shapeId
end

-------------------
--后期添加神器

function Property.getWingSkin(self)
    return self.m_wingSkin
end
function Property.setWingSkin(self,_skin)
    self.m_wingSkin=_skin
end
function Property.getWingLv(self)
    return self.m_wingLv
end
function Property.setWingLv(self,_lv)
    self.m_wingLv=_lv
end

function Property.getArtifactSkillId(self)
    return self.m_artifactSkillId
end
function Property.setArtifactSkillId(self,_value)
    self.m_artifactSkillId=_value or 0
end
function Property.getArtifactSkillLv(self)
    return self.m_artifactSkillLv
end
function Property.setArtifactSkillLv(self,_value)
    self.m_artifactSkillLv=_value or 0
end

--{美人id}
function Property.getMeirenId(self)
    return self.meiren_id
end
function Property.setMeirenId(self, _meiren_id)
    self.meiren_id = _meiren_id
end
--{翅膀ID}
function Property.setSkinFeather(self,_feather)
    self.m_skinFeather=_feather

    -- if self.isMainPlay then
    --     cc.UserDefault:getInstance():setStringForKey(string.format("ROLE_SY_%d",self.uid or 0), tostring(_feather or 0))
    -- end
end
function Property.getSkinFeather(self)
    return self.m_skinFeather
end
function Property.setFeatherLv(self,_lv)
    self.m_featherLv=_lv
end
function Property.getFeatherLv(self)
    return self.m_featherLv
end

-- {扩展1}
function Property.getExt1(self)
    return self.ext1
end
function Property.setExt1(self, _ext1)
    self.ext1 = _ext1
end

-- {扩展2}
function Property.getExt2(self)
    return self.ext2
end
function Property.setExt2(self, _ext2)
    self.ext2 = _ext2
end

-- {扩展3}
function Property.getExt3(self)
    return self.ext3
end
function Property.setExt3(self, _ext3)
    self.ext3 = _ext3
end

-- {扩展4}
function Property.getExt4(self)
    return self.ext4
end
function Property.setExt4(self, _ext4)
    self.ext4 = _ext4
end

-- {扩展5}
function Property.getExt5(self)
    return self.ext5
end
function Property.setExt5(self, _ext5)
    self.ext5 = _ext5
end




--｛当前副本任务显示类型｝
--与服务器下发数据无关
function Property.getTaskInfo( self )
    -- return self.taskType, self.copyId, self.chapId
    return self.m_copyGuideData
end

function Property.getTaskCount( self)
    -- if self.m_copyGuideData.type==_G.Const.CONST_TASK_TRACE_MATERIAL then
    --     self.m_copyGuideData.haveCount=_G.GBagProxy:getGoodsCountById(self.m_copyGuideData.ortherData)
    -- end
    print("[获取副本引导信息] ",self.m_copyGuideData.ortherData,self.m_copyGuideData.haveCount, self.m_copyGuideData.allCount)
    return self.m_copyGuideData.haveCount, self.m_copyGuideData.allCount
end

function Property.setTaskInfo( self, _taskType, _copyId, _chapId,_haveCount,_allCount,_data)
    if _taskType == nil then
        self.m_copyGuideData = nil
        return
    end
    print("[要打的副本信息] ",_haveCount,_allCount)

    self.m_copyGuideData            = {}
    self.m_copyGuideData.type       = _taskType   --任务类型， 日常任务， 材料任务， 主线任务
    self.m_copyGuideData.copyId     = _copyId
    self.m_copyGuideData.chapId     = _chapId
    self.m_copyGuideData.haveCount  = _haveCount
    self.m_copyGuideData.allCount   = _allCount
    self.m_copyGuideData.ortherData = _data --其他数据(任务：任务ID，珍宝：物品ID)
end
---------------------------------------------------------

function Property.getStringByType( self, _type)
    local tmpStr = _G.Lang.type_name[_type]
    return tmpStr or _type
end


-- {更新数据  根据类型}
function Property.updateProperty( self, _type, _value )
    -- print("Property.CONST_ATTR_VIP 玩家/伙伴属性:"..self :getStringByType( _type).."==".._value)
   -- print("_type-->", _type, "_value-->", _value)
    local func=self.funList[_type]
    if func==nil then
        -- print("更新战斗类型属性")
        self.attr:updateProperty( _type, _value )
        return
    end
    -- print( " 基本属性数据：".._value)
    func(self,_value)
end

function Property.getPropertyKey(self)
    local szKey = string.format("%d%d%d%d%d%d%d%d%d%d%d",
                                self.lv,
                                self.attr.hp,
                                self.attr.strong_att,
                                self.attr.strong_def,
                                self.attr.wreck,
                                self.attr.hit,
                                self.attr.dodge,
                                self.attr.crit,
                                self.attr.crit_res,
                                self.attr.bonus,
                                self.attr.reduction)
    if self:getWarPartner()~=nil then
        local pszKey = string.format("%d%d%d%d%d%d%d%d%d%d%d",
                            self.m_warPartner.lv,
                            self.m_warPartner.attr.hp,
                            self.m_warPartner.attr.strong_att,
                            self.m_warPartner.attr.strong_def,
                            self.m_warPartner.attr.wreck,
                            self.m_warPartner.attr.hit,
                            self.m_warPartner.attr.dodge,
                            self.m_warPartner.attr.crit,
                            self.m_warPartner.attr.crit_res,
                            self.m_warPartner.attr.bonus,
                            self.m_warPartner.attr.reduction)
        szKey=string.format("%s%s",szKey,pszKey)
    end
    return szKey
end
function Property.setBattleKey(self,_key)
    gcprint("setBattleKey================>>>",_key)
    self.m_battleKey=_key
end
function Property.getBattleKey(self)
    return self.m_battleKey or "nil"
end

return Property

