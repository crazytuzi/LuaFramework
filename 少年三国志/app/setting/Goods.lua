require("app.cfg.item_info")
require("app.cfg.knight_info")
require("app.cfg.equipment_info")
require("app.cfg.fragment_info")
require("app.cfg.drop_info")
require("app.cfg.treasure_info")
require("app.cfg.treasure_fragment_info")
require("app.cfg.dress_info")
require("app.cfg.item_awaken_info")
require("app.cfg.pet_info")

local Goods = {}


Goods.TYPE_MONEY  = 1
Goods.TYPE_GOLD  = 2
Goods.TYPE_ITEM  = 3
Goods.TYPE_KNIGHT  = 4
Goods.TYPE_EQUIPMENT  = 5
Goods.TYPE_FRAGMENT  = 6
Goods.TYPE_TREASURE  = 7
Goods.TYPE_TREASURE_FRAGMENT  = 8
Goods.TYPE_SHENGWANG = 9
Goods.TYPE_EXP  = 10
Goods.TYPE_TILI  = 11
Goods.TYPE_JINGLI  = 12
Goods.TYPE_WUHUN  = 13
Goods.TYPE_JINENGDIAN  = 14
Goods.TYPE_MOSHEN = 15
Goods.TYPE_CHUANGUAN  = 16
Goods.TYPE_CHUZHENGLING  = 17
Goods.TYPE_DROP  = 18
Goods.TYPE_VIP_EXP = 19
Goods.TYPE_CORP_DISTRIBUTION = 20  --军团贡献
Goods.TYPE_SHI_ZHUANG = 21   --时装
Goods.TYPE_AWAKEN_ITEM = 22     -- 觉醒道具

Goods.TYPE_SHENHUN = 23
Goods.TYPE_ZHUAN_PAN_SCORE = 24
Goods.TYPE_CROSSWAR_MEDAL = 25  -- 演武勋章
Goods.TYPE_INVITOR_SCORE = 26  -- 推广积分
Goods.TYPE_COUPON = 27 -- 团购券
Goods.TYPE_PET = 28 -- 战宠
Goods.TYPE_PET_SCORE = 29 -- 战宠积分
Goods.TYPE_RECHARGE = 30 -- 充值额度
Goods.TYPE_DAILY_PVP_SCORE = 31 -- 虎牢商店积分

Goods.TYPE_HERO_SOUL = 33 -- 将灵
Goods.TYPE_HERO_SOUL_POINT = 34 -- 灵玉
Goods.TYPE_QIYU_POINT = 35 --奇遇值（将灵系统）

--[[
    _desc描述
    _quality品质
    _ico 图片res
    _size 默认数量或者最小数量
    _maxSize 最大值，概率掉落时有效
]]

function Goods.convert(_type,_value,_size,_maxSize)
    if not _type or type(_type) ~= "number" or _type == 0 then
        return nil
    end
    if not Goods._checkGoodsExist(_type,_value) then
        return nil
    end
    local _name = Goods.getNameByType(_type)
    local goods = nil
    local _ico = nil
    local _quality = nil
    local _desc = nil --描述
    local size = 1  --默认为1
    local _icon_mini = nil -- 小icon
    local _texture_type = UI_TEX_TYPE_LOCAL

    if _type == 1  then-- icon,银两 
        goods = {name=_name}
        _desc = G_lang:get("LANG_GOODS_YIN_LIANG_DESC")
        _quality = 1
        _ico = G_Path.getBasicIconMoney()
        _icon_mini = "icon_mini_yingzi.png"
        _texture_type = UI_TEX_TYPE_PLIST
    elseif _type == 2 then
        goods = {name=_name}
        _desc = G_lang:get("LANG_GOODS_YUAN_BAO_DESC")
        _quality = 7
        _ico = G_Path.getBasicIconGold()
        _icon_mini = "icon_mini_yuanbao.png"
        _texture_type = UI_TEX_TYPE_PLIST
    elseif _type == 3 then --item_info
        goods = item_info.get(_value)
        _desc = goods.directions
        _quality =goods.quality
        _ico = G_Path.getItemIcon(goods.res_id)
        _icon_mini = G_Path.getItemMiniIcon(goods.res_id)
    elseif _type == 4 then --knight_info
        goods = knight_info.get(_value)
        _desc = goods.directions
        _quality = goods.quality
        _ico = G_Path.getKnightIcon(goods.res_id)
    elseif _type == 5 then --equipment_info
         goods = equipment_info.get(_value)
         _desc = goods.directions
         _quality = goods.quality
         _ico = G_Path.getEquipmentIcon(goods.res_id)
    elseif _type == 6 then --fragment_info
         goods = fragment_info.get(_value)
         if goods.fragment_type == 1 then
            _ico = G_Path.getKnightIcon(goods.res_id)
         elseif goods.fragment_type == 2 then
            _ico = G_Path.getEquipmentIcon(goods.res_id)
         elseif goods.fragment_type == 3 then
            _ico = G_Path.getPetIcon(goods.res_id)
         end
          _desc = goods.directions
          _quality = goods.quality
    elseif _type == 7 then
        goods = treasure_info.get(_value)
        _desc = goods.directions
        _quality = goods.quality
        _ico = G_Path.getTreasureIcon(goods.res_id)
    elseif _type == 8 then 
        goods = treasure_fragment_info.get(_value)
        _desc = goods.directions
        _quality = goods.quality
        _ico = G_Path.getTreasureFragmentIcon(goods.res_id)
    elseif _type == 9 then   --竞技场积分
        goods={name=_name}
        _desc = G_lang:get("LANG_GOODS_SHENG_WANG_DESC")
        _ico = G_Path.getBasicIconShengWang()
        _icon_mini = "icon_mini_shenwang.png"
        _texture_type = UI_TEX_TYPE_PLIST
        _quality = 4
    elseif _type == 10 then  -- 角色经验
        goods={name=_name}
        _desc = G_lang:get("LANG_GOODS_EXP_DESC")
        _ico = G_Path.getBasicIconExp()
        _icon_mini = "icon_mini_jinyan.png"
        _texture_type = UI_TEX_TYPE_PLIST
        _quality = 1
    elseif _type == 11 then --体力
        goods={name=_name}
        _desc = G_lang:get("LANG_GOODS_TI_LI_DESC")
        _ico = G_Path.getBasicIconTili()
        _icon_mini = G_Path.getTextPath("sy_tili.png")
        _quality = 3
    elseif _type == 12 then --精力
        goods={name=_name}
        _desc = G_lang:get("LANG_GOODS_JING_LI_DESC")
        _ico = G_Path.getBasicIconJingli()
        _icon_mini = G_Path.getTextPath("sy_jinli.png")
        _quality = 4
    elseif _type == 13 then --武魂
        goods={name=_name}
        _desc = G_lang:get("LANG_GOODS_JIANG_HUN_DESC")
        _ico = G_Path.getBasicIconWuhun()
        _icon_mini = "icon_mini_hunyu.png"
        _texture_type = UI_TEX_TYPE_PLIST
        _quality = 4
    elseif _type == 14 then --技能点
        goods={name=_name}
        _desc = _name
        _ico = G_Path.getBasicIconJinengdian()
        _quality = 1
    elseif _type == 15 then --魔神积分
        goods={name=_name}
        _desc = G_lang:get("LANG_GOODS_ZHAN_GONG_DESC")
        _ico = G_Path.getBasicIconMoshenJifen()
        _icon_mini = "icon_mini_jiangzhang.png"
        _texture_type = UI_TEX_TYPE_PLIST
        _quality = 4
    elseif _type == 16 then --闯关积分
        goods={name=_name}
        _desc = G_lang:get("LANG_GOODS_WEI_MING_DESC")
        _ico = G_Path.getBasicIconChuangGuanJifen()
        _icon_mini = "icon_mini_patajifen.png"
        _texture_type = UI_TEX_TYPE_PLIST
        _quality = 4
    elseif _type == 17 then --出征令（魔神消耗）
        goods={name=_name}
        _desc = G_lang:get("LANG_GOODS_ZHENG_TAO_LING_DESC")
        _ico = G_Path.getBasicIconChuZhengLin()
        _icon_mini = "icon_mini_chuzhengling.png"
        _texture_type = UI_TEX_TYPE_PLIST
        _quality = 5   --和item_info一致
    elseif _type == 18 then --掉落库
        local Drops = require("app.setting.Drops")
        return Drops.convert(_value)
    elseif _type == Goods.TYPE_VIP_EXP then
        goods={name=_name}
        _desc = G_lang:get("LANG_GOODS_VIP_EXP_DESC")
        _ico = G_Path.getBasicIconById(15)
        _quality = 7
    elseif _type == Goods.TYPE_CORP_DISTRIBUTION then 
        goods={name=_name}
        _desc = G_lang:get("LANG_GOODS_JUN_TUAN_GONG_XIAN_DESC")
        _ico = G_Path.getBasicIconById(13)
        _icon_mini = "icon_mini_juntuangongxian.png"
        _texture_type = UI_TEX_TYPE_PLIST
        _quality = 4
    elseif _type == Goods.TYPE_SHI_ZHUANG then
        goods = dress_info.get(_value)
        _desc = goods.directions
        --通过id去读时装的icon
        _ico = G_Path.getDressIconById(_value)
        _quality = goods.quality
    elseif _type == Goods.TYPE_AWAKEN_ITEM then -- 觉醒道具
        goods = item_awaken_info.get(_value)
        _desc = goods.comment
        _ico = goods.icon
        _quality = goods.quality
    elseif _type == Goods.TYPE_SHENHUN  then
        goods={name=_name}
        _ico = G_Path.getBaseIconShenhun()
        _desc = G_lang:get("LANG_GOODS_SHEN_HUN_DESC")
        _icon_mini = "icon_juexingdaojushenhun.png"
        _texture_type = UI_TEX_TYPE_PLIST
        _quality = 5
    elseif _type == Goods.TYPE_ZHUAN_PAN_SCORE then
        goods={name=_name}
        _ico = G_Path.getBasicIconById(137)
        _icon_mini = "icon_mini_youxijifen.png"
        _texture_type = UI_TEX_TYPE_PLIST
        _quality = 4
    elseif _type == Goods.TYPE_CROSSWAR_MEDAL then
        goods = {name = _name}
        _ico = G_Path.getBasicIconById(14)
        _desc = G_lang:get("LANG_GOODS_CROSSWAR_MEDAL_DESC")
        _icon_mini = "icon_yanwuxunzhang.png"
        _texture_type = UI_TEX_TYPE_PLIST
        _quality = 5
    elseif _type == Goods.TYPE_INVITOR_SCORE then
        goods = {name = _name}
        _ico = G_Path.getBasicIconById(149)
        _desc = G_lang:get("LANG_GOODS_INVITOR_SCORE_DESC")
        _icon_mini = "icon_mini_tuiguangjifen.png"
        _texture_type = UI_TEX_TYPE_PLIST
        _quality = 5
    elseif _type == Goods.TYPE_COUPON then
        goods = {name = _name}
        _ico = G_Path.getItemIcon(40070)
        _desc = G_lang:get("LANG_GOODS_COUPON_DESC")
        _icon_mini = "icon_mini_tuiguangjifen.png"
        _texture_type = UI_TEX_TYPE_PLIST
        _quality = 5
    elseif _type == Goods.TYPE_PET then
        goods = pet_info.get(_value)
        _ico = G_Path.getPetIcon(goods.res_id)
        _desc = goods.directions
        _quality = goods.quality
    elseif _type == Goods.TYPE_PET_SCORE then
        goods = {name = _name}
        _ico = G_Path.getItemIcon(41035)
        _desc = G_lang:get("LANG_GOODS_PET_SCORE_DESC")
        _icon_mini = "icon_mini_shouhun.png"
        _texture_type = UI_TEX_TYPE_PLIST
        _quality = 5
    elseif _type == Goods.TYPE_RECHARGE then
        goods = {name = _name}
        _ico = G_Path.getBasicIconById(16)
        _desc = G_lang:get("LANG_GOODS_RECHARGE_DESC")
        _quality = 7
    elseif _type == Goods.TYPE_DAILY_PVP_SCORE then
        goods = {name = _name}
        _ico = G_Path.getBasicIconById(17)
        _icon_mini = "icon_mini_jizhanjifen.png"
        _texture_type = UI_TEX_TYPE_PLIST
        _quality = 5
        _desc = G_lang:get("LANG_GOODS_HULAO_DESC")
    elseif _type == Goods.TYPE_HERO_SOUL_POINT then
        goods = {name = _name}
        _ico = G_Path.getBasicIconById(161) 
        _icon_mini = "icon_mini_lingyu.png"
        _texture_type = UI_TEX_TYPE_PLIST
        _quality = 5
        _desc = G_lang:get("LANG_GOODS_HERO_SOUL_SCORE_DESC")
    elseif _type == Goods.TYPE_HERO_SOUL then 
        goods = ksoul_info.get(_value)
        _desc = goods.directions
        _quality = goods.quality
        _ico = G_Path.getKnightIcon(goods.res_id)
    elseif _type == Goods.TYPE_QIYU_POINT then
        goods = {name = _name}
        _ico = G_Path.getBasicIconById(162) 
        _icon_mini = "icon_qiyudian.png"
        _texture_type = UI_TEX_TYPE_PLIST
        _quality = 6
        _desc = G_lang:get("LANG_GOODS_QIYU_DESC")
    end

    if goods then
        if _size == nil then
            _size = 1
        elseif _maxSize ~= nil and _size ~= _maxSize then
            --表示概率掉落  ,名称改成 类似:将魂(4-6)
            goods.name = string.format("%s\n(%d~%d)",goods.name,_size,_maxSize)
            size = 0
        else
            size = _size
        end
        local tGoods = {name = goods.name,icon = _ico,info=goods,quality=_quality,desc=_desc,size=size,type=_type,value = _value,icon_mini = _icon_mini, texture_type=_texture_type}
        return tGoods
    else
        return goods
    end
end


--[[
    Goods.TYPE_MONEY  = 1
    Goods.TYPE_GOLD  = 2
    Goods.TYPE_ITEM  = 3
    Goods.TYPE_KNIGHT  = 4
    Goods.TYPE_EQUIPMENT  = 5
    Goods.TYPE_FRAGMENT  = 6
    Goods.TYPE_TREASURE  = 7
    Goods.TYPE_TREASURE_FRAGMENT  = 8
    Goods.TYPE_SHENGWANG = 9
    Goods.TYPE_EXP  = 10
    Goods.TYPE_TILI  = 11
    Goods.TYPE_JINGLI  = 12
    Goods.TYPE_WUHUN  = 13
    Goods.TYPE_JINENGDIAN  = 14
    Goods.TYPE_MOSHEN = 15
    Goods.TYPE_CHUANGUAN  = 16
    Goods.TYPE_CHUZHENGLING  = 17
    Goods.TYPE_DROP  = 18
    Goods.TYPE_VIP_EXP = 19
]]

function Goods.getNameByType(_type)
    if _type == Goods.TYPE_MONEY then  --银两
        return G_lang:get("LANG_SILVER") 
    elseif _type == Goods.TYPE_GOLD then  --元宝
        return G_lang:get("LANG_GOLDEN")
    elseif _type == Goods.TYPE_SHENGWANG then  --声望
        return G_lang:get("LANG_GOODS_SHENG_WANG")
    elseif _type == Goods.TYPE_EXP then   --经验
        return  G_lang:get("LANG_EXP")
    elseif _type == Goods.TYPE_TILI then --体力
        return G_lang:get("LANG_STORYDUNGEON_VIT")
    elseif _type == Goods.TYPE_JINGLI then  --精力
        return G_lang:get("LANG_GOODS_JING_LI")
    elseif _type == Goods.TYPE_WUHUN then --将魂
        return G_lang:get("LANG_GOODS_JIANG_HUN")
    elseif _type == Goods.TYPE_JINENGDIAN then --技能点
        return G_lang:get("LANG_GOODS_JI_NENG_DIAN")
    elseif _type == Goods.TYPE_MOSHEN then   --奖章
        return G_lang:get("LANG_GOODS_JIANG_ZHANG")
    elseif _type == Goods.TYPE_CHUANGUAN then   --战功
        return G_lang:get("LANG_GOODS_ZHAN_GONG")
    elseif _type == Goods.TYPE_CHUZHENGLING then  --出征令
        return G_lang:get("LANG_INFO_CHUZHENGLING")
    elseif _type == Goods.TYPE_VIP_EXP then   --VIP经验
        return G_lang:get("LANG_GOODS_VIP_EXP")
    elseif _type == Goods.TYPE_CORP_DISTRIBUTION then
        return G_lang:get("LANG_GOODS_CORP_DISTRIBUTION")
    elseif _type == Goods.TYPE_SHENHUN then -- 神魂
        return G_lang:get("LANG_GOODS_SHENHUN")
    elseif _type == Goods.TYPE_ZHUAN_PAN_SCORE then
        return G_lang:get("LANG_GOODS_ZHUAN_PAN_SCORE")
    elseif _type == Goods.TYPE_CROSSWAR_MEDAL then
        return G_lang:get("LANG_GOODS_CROSSWAR_MEDAL")
    elseif _type == Goods.TYPE_INVITOR_SCORE then
        return G_lang:get("LANG_GOODS_INVITOR_SCORE")
    elseif _type == Goods.TYPE_COUPON then
        return G_lang:get("LANG_GOODS_COUPON")
    elseif _type == Goods.TYPE_PET_SCORE then
        return G_lang:get("LANG_GOODS_PET_SCORE")
    elseif _type == Goods.TYPE_RECHARGE then
        return G_lang:get("LANG_GOODS_RECHARGE")
    elseif _type == Goods.TYPE_DAILY_PVP_SCORE then
        return G_lang:get("LANG_GOODS_DAILY_PVP_SCORE")
    elseif _type == Goods.TYPE_HERO_SOUL_POINT then
        return G_lang:get("LANG_GOODS_HERO_SOUL_SCORE")
    elseif _type == Goods.TYPE_QIYU_POINT then
        return G_lang:get("LANG_GOODS_QIYU_POINT")
    end
    return nil
end



function Goods._checkGoodsExist(_type,_value)
    if _type == nil then
        G_MovingTip:showMovingTip()
        -- MessageBoxEx.show
        MessageBoxEx.showOkMessage( "提示", "传入type为空")
        return false
    end
    local goods = 0
    if _type == 3 then --item_info
        goods = item_info.get(_value)
    elseif _type == 4 then --knight_info
        goods = knight_info.get(_value)
    elseif _type == 5 then --equipment_info
         goods = equipment_info.get(_value)
    elseif _type == 6 then --fragment_info
         goods = fragment_info.get(_value)
    elseif _type == 7 then
        goods = treasure_info.get(_value)
    elseif _type == 8 then 
        goods = treasure_fragment_info.get(_value)
    elseif _type == Goods.TYPE_AWAKEN_ITEM then
        goods = item_awaken_info.get(_value)
    end
    if goods == nil then
        local tips = string.format("type=%s,value=%s不存在",_type,_value)
        -- G_MovingTip:showMovingTip(tips)
        MessageBoxEx.showOkMessage( nil, tips)
        return false
    elseif goods == 0 then
        return true
    end
    return true
end



--[[
    Goods.TYPE_MONEY  = 1
    Goods.TYPE_GOLD  = 2
    Goods.TYPE_ITEM  = 3
    Goods.TYPE_KNIGHT  = 4
    Goods.TYPE_EQUIPMENT  = 5
    Goods.TYPE_FRAGMENT  = 6
    Goods.TYPE_TREASURE  = 7
    Goods.TYPE_TREASURE_FRAGMENT  = 8
    Goods.TYPE_SHENGWANG = 9
    Goods.TYPE_EXP  = 10
    Goods.TYPE_TILI  = 11
    Goods.TYPE_JINGLI  = 12
    Goods.TYPE_WUHUN  = 13
    Goods.TYPE_JINENGDIAN  = 14
    Goods.TYPE_MOSHEN = 15
    Goods.TYPE_CHUANGUAN  = 16
    Goods.TYPE_CHUZHENGLING  = 17
    Goods.TYPE_DROP  = 18
    Goods.TYPE_VIP_EXP = 19

    Goods.TYPE_CORP_DISTRIBUTION = 20  --军团贡献
    Goods.TYPE_SHI_ZHUANG = 21   --时装
    Goods.TYPE_AWAKEN_ITEM = 22     -- 觉醒道具

    Goods.TYPE_SHENHUN = 23
    Goods.TYPE_ZHUAN_PAN_SCORE = 24
    Goods.TYPE_CROSSWAR_MEDAL = 25  -- 演武勋章
]]
--检查是否已经拥有该good了
function Goods.checkOwnGood(good)
    if not good then
        return false
    end
    local _type = good.type
    local size = 1
    if good.size ~= nil and good.size > 0 then
        size = good.size
    end
    local ownNum = G_Me.bagData:getNumByTypeAndValue(good.type,good.value)
    return ownNum >= size
end

function Goods.checkHolidayByTypeValue(type,value,size)
    local good = Goods.convert(type,value,size)
    return Goods.checkHolidayGood(good)
end

--活动道具不显示
-- Goods.holidayItemList = {77,78,79.80}
function Goods.checkHolidayGood(good)
    --[[
        新增了活动道具类型
        0:普通道具
        1:掉落活动道具
        2:SpecialActivity item
    ]]
    if not good then
        return 0
    end
    if good.type == Goods.TYPE_ITEM then
        return good.info.is_holiday   
    end
    return 0
end

function Goods.checkGoodCount(good)
    if not good then
        return 0
    end
    local _type = good.type
    local size = 1
    if good.size ~= nil and good.size > 0 then
        size = good.size
    end
    if size == 0 then
        return -1
    end
    local ownNum = G_Me.bagData:getNumByTypeAndValue(good.type,good.value)
    return math.floor(ownNum/size)
end

return Goods
