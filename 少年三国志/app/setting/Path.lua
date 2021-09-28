local Path = {}

local Goods = require("app.setting.Goods")

-- 主线副本零碎图标
Path.DungeonIcoType = 
{
    MINGCI_1 = "ui/dungeon/mingci_1.png",
    MINGCI_2 = "ui/dungeon/mingci_2.png",
    MINGCI_3 = "ui/dungeon/mingci_3.png",
    INFO_1 = "ui/dungeon/info_1.png",
    INFO_2 = "ui/dungeon/info_2.png",
    INFO_3 = "ui/dungeon/info_3.png",
    YILINGQU = "ui/text/txt/yilingqu.png",
    DIANJILINGQU = "ui/text/txt/shuiyin_dianjilingqu.png",
    STAR = "fuben_star.png",
    ROAD_GREEN = "ui/dungeon/dot_green.png",
    ROAD_GRAY = "ui/dungeon/dot_gray.png",
    YUANBAO = "yuanbao.png",
    
    -- 光环
    HALO = "ui/createrole/guangquan_juse.png",
    
    -- 宝箱开启状态图片
    COPPERBOX_OPEN = "ui/dungeon/baoxiangtong_kai.png", 
    SILVERBOX_OPEN = "ui/dungeon/baoxiangyin_kai.png" ,
    GOLDBOX_OPEN = "ui/dungeon/baoxiangjin_kai.png" ,
    COPPERBOX_EMPTY = "ui/dungeon/baoxiangtong_kong.png", 
    SILVERBOX_EMPTY = "ui/dungeon/baoxiangyin_kong.png" ,
    GOLDBOX_EMPTY = "ui/dungeon/baoxiangjin_kong.png" ,
    FIRE          = "ui/dungeon/fire.png",
    FIRE_PLIST   = "ui/dungeon/fire_effect.plist",
    -- 关卡宝箱已领取
    GATEBOX_EMPTY = "ui/dungeon/bx_guanka_kong.png", 
}

-- 玩法

Path.Play = 
{
    StoryDungeon = "ui/play/juqingfuben.png",
    Arena = "ui/play/jingjichang.png",
    Mission = "ui/play/chuangguan.png",
    Plunder = "ui/play/duobao.png",
    RebelAmry = "ui/play/panjun.png",
    Vip = "ui/play/vipfuben.png",
}

-- 首页
Path.MainPage = 
{
    -- 圆盘锁定
    PEDESTAL_LOCK = "ui/mainpage/circle_lock.png",
    MASK = "res/ui/mainpage/touxiang_bg.png"
}

-- 剧情副本文本
Path.StoryDungeonIcoType =
{
    TEXT_GET = "ui/text/txt/jqfb_dianjilingqu.png",
    TEXT_ALREADYGET = "ui/text/txt/jqfb_yilingqu.png",
    
    SELECTIMG = "ui/storydungeon/wjz_fuben_bg_on.png",
    NORMALIMG = "ui/storydungeon/wjz_fuben_bg_normal.png",
    LOCKIMG = "ui/storydungeon/wjz_map_lock.png",
}

function Path.getStoryFieldIco(resId)
    return "icon/campaign/" .. resId .. ".png"
end

--装备养成里,  按钮的图片: 强化,精炼,可能需要动态修改
Path.EQUIPMENT_DEVELOPE_BTN_IMAGE ={
    REFINE = "ui/text/txt-small-btn/jinglian.png",
    REFINE_TYPE = UI_TEX_TYPE_LOCAL,
}


--------基本图标
--获取排行榜图标,只有前三名
function Path.getPHBImage(rank)
    return "ui/text/txt/phb_" .. rank .. "st.png",UI_TEX_TYPE_LOCAL
end


-- 得到语音
function Path.getVoice(resId)
    return "voice/" .. resId .. ".mp3"
end

function Path.getBasicIconMoney()
    return "icon/basic/1.png"
end

function Path.getBasicIconGold()
    return "icon/basic/2.png"
end


function Path.getBasicIconShengWang()
    return "icon/basic/3.png"
end

function Path.getBasicIconExp()
    return "icon/basic/4.png"
end

function Path.getBasicIconTili()
    return "icon/basic/5.png"
end
   

function Path.getBasicIconJingli()
   return "icon/basic/6.png"
end

function Path.getBasicIconWuhun()
   return "icon/basic/7.png"
end

function Path.getBaseIconShenhun()
    return "icon/basic/138.png"
end

function Path.getBasicIconJinengdian()
   return "icon/basic/8.png"
end

function Path.getBasicIconMoshenJifen()
   return "icon/basic/9.png"
end

function Path.getBasicIconChuangGuanJifen()
   return "icon/basic/10.png"
end

function Path.getBasicIconChuZhengLin()
   return "icon/basic/11.png"
end

function Path.getBasicIconById(res_id)
   return "icon/basic/" .. res_id .. ".png"
end


function Path.getKnightIcon(resId)
    return "icon/knight/" .. resId .. ".png" 
end

function Path.getItemIcon(resId)
    return "icon/item/" .. resId .. ".png" 
end

function Path.getItemMiniIcon(resId)
    return "icon/mini_icon/item/" .. resId .. ".png" 
end


function Path.getLegionChapterIcon( baseId )
    return "pic/corps_chapter/"..baseId..".png"
end

function Path.getLegionDungeonIcon( baseId )
    return "pic/corps_dungeon/"..baseId..".png"
end

function Path.getLegionDungeonMiniIcon( baseId )
    return "ui/legion/bz_"..baseId..".png"
end

function Path.getLegionTechIcon(resId)
    return "icon/corps_skill/" .. resId .. ".png" 
end

--时装

function Path.getDressIconById(resId)
    return "icon/dress/" .. resId .. ".png" 
end

-- 得到表情图标路径
function Path.getFaceIco(resId)
    return "ui/chat/face/" .. resId .. ".png"
end

-- 得到对话背景图片
function Path.getStoryBackGroundImgage(resId)
    return "pic/storydialogue/" .. resId .. ".png"
end

-- 得到剧情对话箭头
function Path.getStoryArrow(dialogue_type)
    if dialogue_type == 1 then
        return "ui/dialog/duihua_qipao1_jiao.png"
    else
        return "ui/dialog/duihua_qipao2_jiao.png"
    end
end

function Path.getLegionIconByIndex( index )
    index = index or 1
    if index < 1 or index > 3 then 
        index = 1
    end
    
    return "ui/legion/juntuan_biaozhi_"..index..".png", UI_TEX_TYPE_LOCAL
end

function Path.getLegionIconBackByIndex( index )
    index = index or 1
    if type(index) ~= "number" then 
        index = 1 
    end

    local iconBack = {
    [1] = "ui/legion/icon_biankuang_putong.png",
    [2] = "ui/legion/icon_biankuang_jingying.png",
    [3] = "ui/legion/icon_biankuang_guanjun.png",
    }

    if index < 1 or index > 3 then 
        index = 1
    end
    return iconBack[index], UI_TEX_TYPE_LOCAL
end

function Path.getLegionMemberPosition( position )
    position = position or 1
    if type(position) ~= "number" then 
        position = 0
    end

    if position < 0 or position > 2 then 
        position = 0
    end
    return "ui/text/txt/chenghao_"..position..".png", UI_TEX_TYPE_LOCAL
end

--得到剧情对话 对话单元背景
function Path.getItemBg(dialogue_type)
    if dialogue_type == 1 then
        return "ui/dialog/duihua_qipao1.png"
    elseif dialogue_type == 2 then
        return "ui/dialog/duihua_qipao2.png"
    else
        return "ui/dialog/duihua_pangbai.png"
    end
end

-- 宝箱大图标
function Path.getBoxPic(resId)
    if resId == 1 then 
        return "ui/dungeon/bx_guanka_guan.png"
    elseif resId == 2 then
        return "ui/dungeon/bx_guanka_kai.png"
    else
        return "ui/dungeon/bx_guanka_kong.png"
    end
end

function Path.getGrowupIcon( isGrowup )
    return isGrowup and "ui/yangcheng/arrow_green.png" or "ui/yangcheng/arrow_red.png", UI_TEX_TYPE_LOCAL
end

function Path.getBackground(png)
    return "ui/background/" .. png 
end

-- 装备部位的文字图片: 武器,披风这些, 垂直文字
local equipmentTypeImages = {
    "ui/text/txt/zb_wuqi.png",
    "ui/text/txt/zb_yifu.png",
    "ui/text/txt/zb_pifeng.png",
    "ui/text/txt/zb_yaodai.png",
    "ui/text/txt/zb_gongjibaowu.png",
    "ui/text/txt/zb_fangyubaowu.png",
    "ui/text/txt/zb_jingyanbaowu.png",
}
function Path.getEquipmentTypeImage(type)
    return equipmentTypeImages[type], UI_TEX_TYPE_LOCAL
end

function Path.getTreasureTypeImage(_type)
    return Path.getEquipmentTypeImage(_type+4)
end


-- 装备的颜色图片: 紫装, 绿装等
local equipmentColorImages = {
    "ui/text/txt/xinxi_baizhuang.png", --白色
    "ui/text/txt/xinxi_lvzhuang.png", --绿色
    "ui/text/txt/xinxi_lanzhuang.png", --蓝色
    "ui/text/txt/xinxi_zizhuang.png", --紫色
    "ui/text/txt/xinxi_chengzhuang.png", --橙色
    "ui/text/txt/xinxi_hongzhuang.png", --红色
    "ui/text/txt/xinxi_jinzhuang.png", --金色

}

function Path.getEquipmentColorImage(quality)
    return equipmentColorImages[quality], UI_TEX_TYPE_LOCAL
end

function Path.getEquipmentPic(resId)
    return "pic/equipment/" .. resId .. ".png" 
end

-- nReadyId对应pet_info中的ready_id字段
function Path.getPetReadyEffect(nReadyId)
    return "effect_zhanchong_"..nReadyId.."_ready"
end

function Path.getPetReadyGuangEffect(nReadyId)
    return "effect_zhanchongguang_"..nReadyId.."_ready"
end

function Path.getPetPicConfig(resId)
    return "pic/pet/" .. resId .. ".json" 
end

function Path.getTreasurePic(resId)
    return "pic/treasure/" .. resId .. ".png" 
end

function Path.getPetPic(resId)
    return "pic/pet/" .. resId .. ".png" 
end

--战斗结算用到的图片文件夹
function Path.getFightEndDir()
    return "ui/fightend/"
end

--抽卡用到的图片文件夹
function Path.getShopCardDir()
    return "ui/shop/animation/"
end

function Path.getTextPath(txt)
    return "ui/text/txt/"  .. txt
end

function Path.getKnightShadow()
    return "ui/zhengrong/shadow.png" 
end


function Path.getKnightPic(resId)
    return "pic/knight/" .. resId .. ".png" 
end

function Path.getKnightPicConfig(resId)
    return "pic/knight/" .. resId .. ".json" 
end

--获取活动icon
function Path.getActivityIcon(resId)
    return "icon/activity/" .. resId .. ".png" 
end

function Path.getEquipmentIcon(resId)
    return "icon/equipment/" .. resId .. ".png" 
end

function Path.getPetIcon(resId)
    return "icon/pet/" .. resId .. ".png" 
end

function Path.getSkillIcon(resId)
    return "icon/skill/" .. resId .. ".png" 
end

function Path.getBuffIcon(resId)
    return "icon/buff/" .. resId .. ".png" 
end

function Path.getWayIcon(resId)
    return "icon/basic/"..resId..".png"
end

--获取头像框
function Path.getAvatarFrame(resId)
    return "ui/frame/" .. resId .. ".png" 
end

-- 百战沙场对手形象
function Path.getBattleFieldPic(resId)
    return "pic/battlefield/" .. resId .. ".png" 
end


-- --精炼阶数的标题图
-- function Path.getRefineLevelPic(level)
--     ----todo~!!!!!!!
--     --由于精炼10阶以上图片还没切图,后面需要做成FNT, 暂时 >10的返回10
--     if level > 10 then
--         level = 10
--     end
--     return "zbyc_" .. level .. "_jinglianshengjie.png", UI_TEX_TYPE_PLIST
-- end

-- 三国志残片大图
function Path.getFragmentPic(resId)
    return "pic/fragment/" .. resId .. ".png" 
end

-- 根据根据怪物等级得到底板
function Path.getMonsterNameBg(difficulty)
    if difficulty == 2 then
        return "ui/dungeon/mingpai_jingying.png" 
    elseif difficulty == 3 then
         return "ui/dungeon/mingpai_boss.png"
    else
        return "ui/dungeon/mingpai_putong.png" 
    end
end

-- 主线副本城池图标
function Path.getCityIcon(resId)
    return "pic/dungeocity/map_icon_" .. resId .. ".png" 
end

-- 主线副本地域图标
-- @prarm isLight 是否加亮
function Path.getFieldIcon(resId,isLight)
    if isLight then
        return "ui/dungeon/map_" .. resId .. "_light.png"
    else
        return "ui/dungeon/map_" .. resId .. ".png"
    end
end

-- 剧情副本事件图片
function Path.getStoryDungeonEventPic(resId)
    return "pic/storydungeon_event/" .. resId .. ".png" 
end

-- 主线副本战斗地图
function Path.getDungeonBattleMap(resId)
    return "pic/dungeonbattle_map/" .. resId .. ".png" 
end

-- 剧情副本武将图片
function Path.getStoryDungeonKnightPic(resId)
    return "pic/storydungeon_knight/" .. resId .. ".png" 
end

-- 剧情副本武将背景图
function Path.getStoryDungeonListKnightBg()
    return "ui/storydungeon/zhuangliaozhuankuang.png" 
end

-- 剧情副本大事件背景图
function Path.getStoryDungeonListEventBg()
    return "second-board-2.png" 
end

--[[
    价格类型
    1-银两
    2-元宝
    3-竞技场积分
    4-魔神积分
    5-闯关积分
    6-武魂
    7-体力
    8-精力
    9-军团贡献
    10-转盘积分
    11-神魂
]]
function Path.getPriceType(priceType)
    if priceType == nil or type(priceType) ~= "number" then
        return nil
    end
    local goodType = nil
    if priceType == 1 then
        goodType = G_Goods.TYPE_MONEY
    elseif priceType == 2 then 
        goodType = G_Goods.TYPE_GOLD
    elseif priceType == 3 then
        goodType = G_Goods.TYPE_SHENGWANG
    elseif priceType == 4 then
        goodType = G_Goods.TYPE_MOSHEN
    elseif priceType == 5 then
        goodType = G_Goods.TYPE_CHUANGUAN
    elseif priceType == 6 then
        goodType = G_Goods.TYPE_WUHUN
    elseif priceType == 7 then
        goodType = G_Goods.TYPE_TILI
    elseif priceType == 8 then
        goodType = G_Goods.TYPE_JINGLI
    elseif priceType == 9 then
        goodType = G_Goods.TYPE_CORP_DISTRIBUTION
    elseif priceType == 10 then
        goodType = G_Goods.TYPE_ZHUAN_PAN_SCORE
    elseif priceType == 11 then
        goodType = G_Goods.TYPE_SHENHUN
    elseif priceType == 12 then
        goodType = G_Goods.TYPE_CROSSWAR_MEDAL
    elseif priceType == 13 then
        goodType = G_Goods.TYPE_INVITOR_SCORE
    elseif priceType == 16 then
        goodType = G_Goods.TYPE_HERO_SOUL_POINT
    elseif priceType == 17 then
        goodType = G_Goods.TYPE_QIYU_POINT
    end
    return goodType
end

function Path.getPriceTypeIcon(priceType)
    local goodType = Path.getPriceType(priceType) 
    if goodType then
        local good = G_Goods.convert(goodType)
        if good then
            return good.icon_mini,good.texture_type
        else
            return nil
        end
    end
    return nil    
end

--三国志残卷icon
function Path.getSanguozhiIcon(resId)
    return "icon/main_growth/" .. resId .. ".png" 
end

-- 排名的图片（冠，亚季军的奖杯图片）
function Path.getRankTopThreeIcon( rankIndex )
    local _icons = {
    [1] = "ui/top/mrt_huangguan1.png",
    [2] = "ui/top/mrt_huangguan2.png",
    [3] = "ui/top/mrt_huangguan3.png",
}

    if type(rankIndex) ~= "number" then 
        rankIndex = 3 
    end

    if rankIndex < 1 or rankIndex > 3 then 
        rankIndex = 3
    end

    return _icons[rankIndex]
end

--获取掉落库的里的内容ICON
function Path.getDropIcon(resId)
    return "icon/drop/" .. resId .. ".png" 
end

-- 宝物图片
function Path.getTreasureIcon(resId)
    return "icon/treasure/" .. resId .. ".png" 
end

--宝物碎片
function Path.getTreasureFragmentIcon(resId)
    return "icon/treasure_fragment/" .. resId .. ".png" 
end


function Path.getTooltipBg()
    return "ui/common/xitongtishi_bg.png"
end


function Path.getJobTipsIcon( job )
    local jobType = {
    "ui/text/txt/leixing_wugongxing.png",
    "ui/text/txt/leixing_fagongxing.png",
    "ui/text/txt/leixing_fangyu.png",
    "ui/text/txt/leixing_fuzhuxing.png",
    }

    if job >= 1 and job <= 4 then
        return jobType[job], UI_TEX_TYPE_LOCAL
    else
        return nil
    end
end

-- function Path.getJobTipsIcon_List( job )
--     local jobType = {
--     "ui/text/txt/leixing_gongji_list.png",
--     "ui/text/txt/leixing_mofa_list.png",
--     "ui/text/txt/leixing_fangyu_list.png",
--     "ui/text/txt/leixing_fuzhu_list.png",
--     }

--     if job >= 1 and job <= 4 then
--         return jobType[job], UI_TEX_TYPE_LOCAL
--     else
--         return nil
--     end
-- end

function Path.getDamageTypeIcon( damage )
    local damageType = {
    "ui/text/txt/shanghai_wuli.png",
    "ui/text/txt/shanghai_fashu.png",
    }

    if damage >= 1 and damage <= 2 then
        return damageType[damage], UI_TEX_TYPE_LOCAL
    else
        return nil
    end
end

function Path.getEquipColorImage ( quality, goodType, typeValue )
    goodType = goodType or Goods.TYPE_EQUIPMENT


    local knightImgs = {
        "pinji_icon_bai.png",
        "pinji_icon_lv.png",
        "pinji_icon_lan.png",
        "pinji_icon_zi.png",
        "pinji_icon_cheng.png",
        "pinji_icon_hong.png",
        "pinji_icon_jin.png",
    }
    local fragementImgs = {
        "suipian_icon_bai.png",
        "suipian_icon_lv.png",
        "suipian_icon_lan.png",
        "suipian_icon_zi.png",
        "suipian_icon_cheng.png",
        "suipian_icon_hong.png",
        "suipian_icon_jin.png",
    }
    local soulImgs = {
        "ui/herosoul/ling_icon_bai.png",
        "ui/herosoul/ling_icon_lv.png",
        "ui/herosoul/ling_icon_lan.png",
        "ui/herosoul/ling_icon_zi.png",
        "ui/herosoul/ling_icon_cheng.png",
        "ui/herosoul/ling_icon_hong.png",
        "ui/herosoul/ling_icon_jin.png",
    }

    if goodType == Goods.TYPE_HERO_SOUL then
        if quality >= 1 and quality <= 7 then
            return soulImgs[quality], UI_TEX_TYPE_LOCAL
        else
            return soulImgs[1], UI_TEX_TYPE_LOCAL
        end
    end

    local isFragement = (goodType == Goods.TYPE_FRAGMENT) or (goodType == Goods.TYPE_TREASURE_FRAGMENT)
    if not isFragement then 
        if quality >= 1 and quality <= 7 then
            return knightImgs[quality], UI_TEX_TYPE_PLIST
        else
            return knightImgs[1], UI_TEX_TYPE_PLIST
        end
    else
        if quality >= 1 and quality <= 7 then
            return fragementImgs[quality], UI_TEX_TYPE_PLIST
        else
            return fragementImgs[1], UI_TEX_TYPE_PLIST
        end
    end
end

function Path.getKnightGroupIcon( group )
    local groupType = {
    --"ui/text/txt/zhenrong_zhujue.png",
    "ui/text/txt/zhenying_wei.png",
    "ui/text/txt/zhenying_shu.png",
    "ui/text/txt/zhenying_wu.png",
    "ui/text/txt/zhenying_qun.png",
    }

    if group >= 1 and group <= 4 then
        return groupType[group], UI_TEX_TYPE_LOCAL
    else
        return nil
    end
end

function Path.getKnightGroupIconSelected( group )
    local groupType = {
    --"ui/text/txt/zhenrong_zhujue.png",
    "ui/text/txt/zhenying_wei_xuanzhong.png",
    "ui/text/txt/zhenying_shu_xuanzhong.png",
    "ui/text/txt/zhenying_wu_xuanzhong.png",
    "ui/text/txt/zhenying_qun_xuanzhong.png",
    }

    if group >= 1 and group <= 4 then
        return groupType[group], UI_TEX_TYPE_LOCAL
    else
        return nil
    end
end

function Path.getZhenYingDropImage(group)
    group = group or 1
    local image = ""
    if group == 1 then
        image = "ui/shop/knight_drop/weijiang.png"
    elseif group == 2 then
        image = "ui/shop/knight_drop/shujiang.png"
    elseif group == 3 then
        image = "ui/shop/knight_drop/wujiang.png"
    else
        image = "ui/shop/knight_drop/qunxiong.png"
    end
    return image,UI_TEX_TYPE_LOCAL
end

--获取阵营招将的title
function Path.getZhenYingDropTitleImage(group)
    group = group or 1
    local image = ""
    if group == 1 then
        image = Path.getTitleTxt("weijiangzhaomu.png")
    elseif group == 2 then
        image = Path.getTitleTxt("shujiangzhaomu.png")
    elseif group == 3 then
        image = Path.getTitleTxt("wujiangzhaomu.png")
    else
        image = Path.getTitleTxt("qunxiongzhaomu.png")
    end
    return image,UI_TEX_TYPE_LOCAL
end


function Path.getKnightColorText( star )
    local colorImgs = {
        "ui/text/txt/xinxi_baijiang.png",
        "ui/text/txt/xinxi_lvjiang.png",
        "ui/text/txt/xinxi_lanjiang.png",
        "ui/text/txt/xinxi_zijiang.png",
        "ui/text/txt/xinxi_chengjiang.png",
        "ui/text/txt/xinxi_hongjiang.png",
        "ui/text/txt/xinxi_jinjiang.png",
    }

    if star >= 1 and star <= 7 then
        return colorImgs[star], UI_TEX_TYPE_LOCAL
    else
        return colorImgs[1], UI_TEX_TYPE_LOCAL
    end
end

function Path.getAddtionKnightColorImage ( star )
    local colorImgs = {
        "pinji_icon_bai.png",
        "pinji_icon_lv.png",
        "pinji_icon_lan.png",
        "pinji_icon_zi.png",
        "pinji_icon_cheng.png",
        "pinji_icon_hong.png",
        "pinji_icon_jin.png",
    }

    if star < 1 then
        return colorImgs[1], UI_TEX_TYPE_PLIST
    elseif star >= 1 and star <= 7 then
        return colorImgs[star], UI_TEX_TYPE_PLIST
    else
        return colorImgs[7], UI_TEX_TYPE_PLIST
    end
end

function Path.getAddtionKnightColorPieceImage ( star )
    local colorImgs = {
        "dengji_icon_bai.png",
        "dengji_icon_lv.png",
        "dengji_icon_lan.png",
        "dengji_icon_zi.png",
        "dengji_icon_cheng.png",
        "dengji_icon_hong.png",
        "dengji_icon_jin.png",
    }

    if star < 1 then
        return colorImgs[1], UI_TEX_TYPE_PLIST
    elseif star >= 1 and star <= 7 then
        return colorImgs[star], UI_TEX_TYPE_PLIST
    else
        return colorImgs[7], UI_TEX_TYPE_PLIST
    end
end

function Path.getEquipmentPartBack ( equipIndex )
    local colorImgs = {
        "ui/zhengrong/dikuang_wuqi.png",
        "ui/zhengrong/dikuang_yifu.png",
        "ui/zhengrong/dikuang_pifeng.png",
        "ui/zhengrong/dikuang_yaodai.png",
        "ui/zhengrong/dikuang_baowu.png",
        "ui/zhengrong/dikuang_baowu.png",
    }

    if equipIndex < 1 then
        return colorImgs[1]
    elseif equipIndex >= 1 and equipIndex <= 6 then
        return colorImgs[equipIndex]
    else
        return colorImgs[6]
    end
end

function Path.getEquipIconBack( quality )
    local colorImgs = {
        "icon_bg_bai.png",
        "icon_bg_lv.png",
        "icon_bg_lan.png",
        "icon_bg_zi.png",
        "icon_bg_cheng.png",
        "icon_bg_hong.png",
        "icon_bg_jin.png",
    }

    if quality < 1 then
        return colorImgs[1], UI_TEX_TYPE_PLIST
    elseif quality >= 1 and quality <= 7 then
        return colorImgs[quality], UI_TEX_TYPE_PLIST
    else
        return colorImgs[7], UI_TEX_TYPE_PLIST
    end
end

function Path.getDropKnightQualityImage(quality)
    if type(quality) ~= "number" then
        quality = 2
    end
    quality = quality or 2
    local imageList = {
        "ui/text/txt/xinxi_baijiang.png",
        "ui/text/txt/xinxi_lvjiang.png",
        "ui/text/txt/xinxi_lanjiang.png",
        "ui/text/txt/xinxi_zijiang.png",
        "ui/text/txt/xinxi_chengjiang.png",
        "ui/text/txt/xinxi_hongjiang.png",
        "ui/text/txt/xinxi_jinjiang.png",
    }
    return imageList[quality],UI_TEX_TYPE_LOCAL

end

function Path.getTreasureFragmentBack(quality)
    local colorImgs = {
        "ui/treasure/duobao/suipian_bg_bai.png",
        "ui/treasure/duobao/suipian_bg_lv.png",
        "ui/treasure/duobao/suipian_bg_lan.png",
        "ui/treasure/duobao/suipian_bg_zi.png",
        "ui/treasure/duobao/suipian_bg_cheng.png",
        "ui/treasure/duobao/suipian_bg_hong.png",
        "ui/treasure/duobao/suipian_bg_jin.png",
    }

    if quality < 1 then
        return colorImgs[1]
    elseif quality >= 1 and quality <= 7 then
        return colorImgs[quality], UI_TEX_TYPE_LOCAL
    else
        return colorImgs[7], UI_TEX_TYPE_LOCAL
    end
end

function Path.getAddKnightIcon( )
    return "jia_bg.png", UI_TEX_TYPE_PLIST
end

function Path.getChatVipPiece(  )
    return "ui/chat/VIP.png",UI_TEX_TYPE_LOCAL
end

function Path.getVipLevelImage(_vip)
    return "ui/vip/vip_lv_".._vip..".png",UI_TEX_TYPE_LOCAL
end

function Path.getShopVipLevelImage( _vip )
    return "ui/shop/vip_" .. _vip .. ".png", UI_TEX_TYPE_LOCAL
end

function Path.getKnightNameBack( ... )
    return "ui/zhengrong/tiny_tittle.png", UI_TEX_TYPE_LOCAL
end

function Path.getListStarIcon(  )
    return "liebiao_star.png", "liebiao_star_empty.png"
end

function Path.getNormalStarIcon(  )
    return "quanping_star.png", "quanping_star_empty.png"
end

-- 获取一般的UI资源路径
function Path.getUIImage(dir, name)
    return "ui/"..dir.."/"..name
end

-- 战斗用路径

function Path.getBattleImage(name)
    return 'ui/battle/'..name
end

function Path.getBattleImageJson(name)
    return 'ui/battle/'..name..'.json'
end

function Path.getBattleTxtImage(name)
    return 'ui/text/battle/'..name
end

function Path.getBattleConfig(dir, name)
    return 'battle/'..dir..'/'..name..".json"
end

function Path.getBattleConfigImage(dir, name)
    return 'battle/'..dir..'/'..name
end

function Path.getBattleImagePlist(dir, name)
    return 'battle/'..dir..'/'..name..".plist"
end

function Path.getBattleSkillTextImage(name)
    return "ui/text/skill/"..name
end

function Path.getBattleLabelFont()
    return "ui/font/FZYiHei-M20S.ttf"
end

--[[
    战斗评价 图片
    不死人 = 完胜  -------------------1
    死一人 = 胜利  -------------------2
    死二、三、四、五人 = 险胜；-------3
    对方剩余1人 = 惜败； -------------4
    对方剩余2、3、4、5人 = 失败；-----5
    对方不死人 = 惨败  -------------- 6
]]
function Path.getBattleResultImage(result)
    if result == "1" then
        return "zd_wansheng.png"
    elseif result == "2" or result == "win" then
        return "zd_shengli.png"
    elseif result == "3" then
        return "zd_xiansheng.png"
    elseif result == "4" then
        return "zd_xibai.png"
    elseif result == "5" or result == "lost" then
        return "zd_shibai.png"
    elseif result == "6" then
        return "zd_canbai.png"
    else
        return "vip_zhandoujieshu.png"
    end
end
-- 伤害数字
function Path.getBattleDamageLabelFont()
    return "ui/font/num_berlin_red.fnt"
end

-- 加血数字
function Path.getBattleRecoverLabelFont()
    return "ui/font/num_berlin_green.fnt"
end

-- 暴击数字
function Path.getBattleCriticalLabelFont()
    return "ui/font/num_berlin_yellow_red.fnt"
end

-- 连击数字
function Path.getBattleComboLabelFont()
    return 'ui/font/num_double_hit.fnt'
end

-- 魔神战斗用

function Path.getMoshenBattleUIImage(name)
    return 'ui/moshen/'..name
end

-- 获取魔神动画用font

function Path.getMoshenBattleFont()
    return 'ui/font/font_rebel_numup.fnt'
end

function Path.getCustomButtonPath( customBtnId )
    local customBtn = {
        "ui/text/txt-big-btn/queding.png",
        "ui/text/txt-big-btn/chongzhi_2.png",
        "ui/text/txt-big-btn/quzhuxian.png",
    }

    if customBtnId >= 1 and customBtnId <= #customBtn then
        return customBtn[customBtnId], UI_TEX_TYPE_LOCAL
    else
        return customBtn[1], UI_TEX_TYPE_LOCAL
    end
end

function Path.getOKNOButtonPath( OKNOBtnId )
    local OKBtn = {
        "ui/text/txt-middle-btn/queding.png",
        "ui/text/txt-middle-btn/quchongzhi.png",
        "ui/text/txt-middle-btn/jixuzou.png",
    }
    local NOBtn = {
        "ui/text/txt-middle-btn/quxiao.png",
        "ui/text/txt-middle-btn/zaixiangxiang.png",
        "ui/text/txt-middle-btn/zaikankan.png",
    }

    if OKNOBtnId >= 1 and OKNOBtnId <= #OKBtn then
        return OKBtn[OKNOBtnId],NOBtn[OKNOBtnId], UI_TEX_TYPE_LOCAL
    else
        return OKBtn[1],NOBtn[1], UI_TEX_TYPE_LOCAL
    end
end

function Path.getButtonTextureByItemType(use_type)
    local imgPath = nil
    if use_type == 1 then
        imgPath = "shiyong.png"
    elseif use_type == 2 then
        imgPath = "qujinjie.png"
    elseif use_type == 3 then
        imgPath = "qujinglian.png"
    elseif use_type == 4 then
        imgPath = "quxilian.png"
    elseif use_type == 5 then
        -- imgPath = "quguanghuan.png"
        imgPath = "shiyong.png"
    elseif use_type == 6 then
        imgPath = "shenmishangdian.png"
    elseif use_type == 7 then
        imgPath = "baowujinglian.png"
    elseif use_type == 8 then
        imgPath = "quchouka.png"
    elseif use_type == 10 then
        imgPath = "qumingxing.png"
    elseif use_type == 12 then
        imgPath = "qujuexing.png"
    elseif use_type == 15 then
        imgPath = "qujihuo.png"
    elseif use_type == 16 then
        imgPath = "qushengji.png"
    elseif use_type == 17 then
        imgPath = "qushenlian.png"
    elseif use_type == 18 then
        imgPath = "qushengxing.png"
    elseif use_type == 19 then
        imgPath = "quduihuan.png"
    elseif use_type == 20 then
        imgPath = "quhuashen.png"
    else
        imgPath = "shiyong.png"
    end
    imgPath = "ui/text/txt-small-btn/" .. imgPath
    return imgPath, UI_TEX_TYPE_LOCAL
end

---------------------------获取文字函数 START--------------------------------------
--获取文字 带后缀.png
function Path.getTxt(textName)
    return "ui/text/txt/" .. textName
end

function Path.getTabTxt(textName)
    return "ui/text/txt-tab/" .. textName
end

function Path.getSmallBtnTxt(textName)
    return "ui/text/txt-small-btn/" .. textName
end

function Path.getMiddleBtnTxt(textName)
    return "ui/text/txt-middle-btn/" .. textName
end

function Path.getBigBtnTxt(textName)
    return "ui/text/txt-big-btn/" .. textName
end

function Path.getTitleTxt(textName)
    return "ui/text/txt-title/" .. textName
end

--------------获取文字函数 END------------------------------

function Path.getRechargeIcon(_resId)
    return "icon/recharge/" .. _resId .. ".png"
end

function Path.getAchievementItemBack()
    return "ui/dailytask/achievement_back.png"
end


Path.DAY_NIGHT_EFFECT = {
    MAIN_SCENE = 1,
    KNIGHT_ARRAY = 2,
}

function Path.getDayEffect( scenePart )
    local DAY_EFFECT = {
    [1] = {"effect_zjmbt",},
    [2] = {"effect_zrbt", },
    }

    if type(scenePart) ~= "number" then 
        scenePart = Path.DAY_NIGHT_EFFECT.MAIN_SCENE
    end

    if scenePart < Path.DAY_NIGHT_EFFECT.MAIN_SCENE then 
       scenePart = Path.DAY_NIGHT_EFFECT.MAIN_SCENE
    end 

    if scenePart > Path.DAY_NIGHT_EFFECT.KNIGHT_ARRAY then 
       scenePart = Path.DAY_NIGHT_EFFECT.KNIGHT_ARRAY
    end 

    return DAY_EFFECT[scenePart]
end

function Path.getNightEffect( scenePart )
    local DAY_EFFECT = {
    [1] = {"effect_zjmhy", },
    [2] = {"effect_zrhy", },
    }

    if type(scenePart) ~= "number" then 
        scenePart = Path.DAY_NIGHT_EFFECT.MAIN_SCENE
    end

    if scenePart < Path.DAY_NIGHT_EFFECT.MAIN_SCENE then 
       scenePart = Path.DAY_NIGHT_EFFECT.MAIN_SCENE
    end 

    if scenePart > Path.DAY_NIGHT_EFFECT.KNIGHT_ARRAY then 
       scenePart = Path.DAY_NIGHT_EFFECT.KNIGHT_ARRAY
    end 

    return DAY_EFFECT[scenePart]
end

-- 排行类型图标
function Path.getTopValueIco(top_type)
    local TopTypeConst = require("app.const.TopTypeConst")
    if top_type == TopTypeConst.TYPE_FIGHT then
        return {txt="ui/text/txt/zhanli.png",textype = UI_TEX_TYPE_LOCAL}
    else
         return {txt="ui/text/txt/dengji_paihangbang.png",textype = UI_TEX_TYPE_LOCAL}
    end
end

-- 排行类型背景
function Path.getRankIco(rank)
    return "ui/top/" .. "mrt_huangguan" .. rank .. ".png"
end


-- 排行类型图标
function Path.getHallOfFrameValueIco(top_type)
    local TopTypeConst = require("app.const.TopTypeConst")
    if top_type == TopTypeConst.TYPE_FIGHT then
        return {txt="ui/text/txt/zhanlikuangren.png",textype = UI_TEX_TYPE_LOCAL}
    else
         return {txt="ui/text/txt/chongjidaren.png",textype = UI_TEX_TYPE_LOCAL}
    end
end

-- 领地相关

-- state 4可收获 5有暴动

function Path.getCityStatePathWithState(state)
    if state == 5 then return 'ui/text/txt/tf_fashengbaodong.png'
    elseif state == 4 then return 'ui/text/txt/tf_keshouhuo.png'
    end
end

function Path.getCityStateBubblePathWithState(state)
    if state == 5 then return 'ui/city/icon_baodong.png'
    elseif state == 4 then return 'ui/city/icon_shouhuo.png'
    end
end

function Path.getCityNamePathWithId(index)
    if index == 1 then return 'ui/text/txt/tf_taoyuancun.png'
    elseif index == 2 then return 'ui/text/txt/tf_wancheng.png'
    elseif index == 3 then return 'ui/text/txt/tf_luoyang.png'
    elseif index == 4 then return 'ui/text/txt/tf_jinzhou.png'
    elseif index == 5 then return 'ui/text/txt/tf_wuzhangyuan.png'
    elseif index == 6 then return 'ui/text/txt/tf_chibi.png'
    end
end

function Path.getCityBGPathWithId(index)
    return 'ui/city/'..index..'.png'
end

-- 获取价格显示用icon
function Path.getPriceTypeIconWithIndex(index)
    return 'icon/mini_icon/'..index..".png"
end

function Path.getDialogQipao()
    return 'ui/dungeon/qipao.png'
end

function Path.getRichManIcon(index)
    local customBtn = {
        "ui/dafuweng/qizi_yinliang.png",
        "ui/dafuweng/qizi_daoju.png",
        "ui/dafuweng/qizi_shijian.png",
        "ui/dafuweng/qizi_shenmishangdian.png",
        "ui/dafuweng/qizi_yidong.png",
    }
    return customBtn[index]
end

local TIME_DUNGEON_CHAPTER_NAME_PATH = {
    "ui/text/txt/titile_dandaofuhui.png",
    "ui/text/txt/titile_qiqinmenghuo.png",
    "ui/text/txt/titile_liuchuqishan.png",
    "ui/text/txt/titile_kongchengji.png",
    "ui/text/txt/titile_hefeizhizhan.png",
    "ui/text/txt/titile_weishuizhizhan.png",
    "ui/text/txt/titile_yilingzhizhan.png",
    "ui/text/txt/titile_jiangweibeifa.png",
}
function Path.getTimeDungeonChapterNameImage(nChapterId)
    nChapterId = nChapterId or 1
    return TIME_DUNGEON_CHAPTER_NAME_PATH[nChapterId] or TIME_DUNGEON_CHAPTER_NAME_PATH[1]
end

local TIME_DUNGEON_CITY_IMAGE_PATH = {
    "ui/legion/junying_hong.png",
    "ui/legion/junying_lan.png",
    "ui/legion/junying_lv.png",
    "ui/legion/junying_zi.png",
}
function Path.getTimeDungeonCityImage(nChapterId)
    nChapterId = nChapterId or 1
    return TIME_DUNGEON_CITY_IMAGE_PATH[nChapterId] or TIME_DUNGEON_CITY_IMAGE_PATH[1]
end

-- 获得阵营中文文字
function Path.getGroupName(nGroup)
    local szGroupName = ""
    if nGroup == 1 then
        szGroupName = G_lang:get("LANG_REBEL_BOSS_GROUP_WEI")
    elseif nGroup == 2 then
        szGroupName = G_lang:get("LANG_REBEL_BOSS_GROUP_SHU")
    elseif nGroup == 3 then
        szGroupName = G_lang:get("LANG_REBEL_BOSS_GROUP_WU")
    elseif nGroup == 4 then
        szGroupName = G_lang:get("LANG_REBEL_BOSS_GROUP_QUN")
    else
    --    assert(false, "error group")
        szGroupName = G_lang:get("LANG_REBEL_BOSS_GROUP_NO_GROUP")
    end
    return szGroupName
end

-- 获取排行的皇冠
local RankCrownImages = { 
    "ui/top/mrt_huangguan1.png",
    "ui/top/mrt_huangguan2.png",
    "ui/top/mrt_huangguan3.png",
}
function Path.getRankCrownImage(nRank)
--    assert(nRank < 0 and nRank > 3, " error rank number ~ rank = " .. tostring(nRank))
    return RankCrownImages[nRank]
end

-- 获取自己阵营的荣誉排行榜
local GROUP_HONOR_IMAGE = {
    "ui/text/txt/pj_weiguorongyu.png",
    "ui/text/txt/pj_shuguorongyu.png",
    "ui/text/txt/pj_wuguorongyu.png",
    "ui/text/txt/pj_qunxiongrongyu.png",
}
function Path.getGroupHonorImage(nGroup)
--    assert(nGroup < 0 or nGroup > 4, "error group number ~")
    return GROUP_HONOR_IMAGE[nGroup], UI_TEX_TYPE_LOCAL
end

-- 限时优惠，折扣图片
local TIME_PRIVILEGE_DISCOUNT_IMAGE = {
    [10] = "ui/text/txt/xsyh_zhekou_1.png",
    [15] = "ui/text/txt/xsyh_zhekou_15.png",
    [20] = "ui/text/txt/xsyh_zhekou_2.png",
    [25] = "ui/text/txt/xsyh_zhekou_25.png",
    [30] = "ui/text/txt/xsyh_zhekou_3.png",
    [35] = "ui/text/txt/xsyh_zhekou_35.png",
    [40] = "ui/text/txt/xsyh_zhekou_4.png",
    [45] = "ui/text/txt/xsyh_zhekou_45.png",
    [50] = "ui/text/txt/xsyh_zhekou_5.png",
    [55] = "ui/text/txt/xsyh_zhekou_55.png",
    [60] = "ui/text/txt/xsyh_zhekou_6.png",
    [65] = "ui/text/txt/xsyh_zhekou_65.png",
    [70] = "ui/text/txt/xsyh_zhekou_7.png",
    [75] = "ui/text/txt/xsyh_zhekou_75.png",
    [80] = "ui/text/txt/xsyh_zhekou_8.png",
    [85] = "ui/text/txt/xsyh_zhekou_85.png",
    [90] = "ui/text/txt/xsyh_zhekou_9.png",
    [95] = "ui/text/txt/xsyh_zhekou_95.png",
}
function Path.getDiscountImage(nDiscount)
    return TIME_PRIVILEGE_DISCOUNT_IMAGE[nDiscount] or TIME_PRIVILEGE_DISCOUNT_IMAGE[40]
end

-- 根据宠物的品质，现在品质图
-- "白宠"、"绿宠"...
function Path.getPetQualityImage(nQuality)
    local tImageList = {
        [1] = "ui/text/txt/xinxi_baichong.png",
        [2] = "ui/text/txt/xinxi_lvchong.png",
        [3] = "ui/text/txt/xinxi_lanchong.png",
        [4] = "ui/text/txt/xinxi_zichong.png",
        [5] = "ui/text/txt/xinxi_chengchong.png",
        [6] = "ui/text/txt/xinxi_hongchong.png",
        [7] = "ui/text/txt/xinxi_jinchong.png",
    }

    if type(nQuality) ~= "number" then
        return tImageList[1]
    end

    if nQuality < 1 then
        return tImageList[1]
    elseif nQuality >= 1 and nQuality <= 7 then
        return tImageList[nQuality], UI_TEX_TYPE_LOCAL
    else
        return tImageList[7], UI_TEX_TYPE_LOCAL
    end
end

function Path.getExDungeonPassType(nPassType)
    local ExpansionDungeonConst = require("app.const.ExpansionDungeonConst")
    local tList = {
        "ui/text/txt/zuiqiangtongguan.png",
        "ui/text/txt/jixiantongguan.png",
    }
    if type(nPassType) ~= "number" then
        return tList[1]
    end

    return tList[nPassType] or tList[1]
end

-- 化神等级水印
function Path.getGodQualityShuiYin(quality)
    if quality == 5 then
        return "ui/common/shenjie_cheng.png"
    elseif quality == 6 then
        return "ui/common/shenjie_hong.png"
    end
end

return Path

