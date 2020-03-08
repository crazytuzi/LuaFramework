local OctetsStream = require("netio.OctetsStream")
local BulletinParamKey = class("BulletinParamKey")
BulletinParamKey.ROLE_NAME1 = 1
BulletinParamKey.ROLE_NAME2 = 2
BulletinParamKey.ACTIVITY_NAME = 3
BulletinParamKey.ITEM_ID = 4
BulletinParamKey.PLACE_NAME = 5
BulletinParamKey.EQUIP_LING_LEVEL = 6
BulletinParamKey.MONSTER_ID = 7
BulletinParamKey.GANG_NAME = 8
BulletinParamKey.GANG_ID = 9
BulletinParamKey.IS_SUPER = 10
BulletinParamKey.BAOTU_ID = 11
BulletinParamKey.LOTTERY_ID = 12
BulletinParamKey.VICTORY_COUNT = 13
BulletinParamKey.JIU_XIAO_LEFT_MINUTE = 14
BulletinParamKey.ITEM_NUM = 15
BulletinParamKey.MONSTER_NAME = 16
BulletinParamKey.STAR_LEVEL = 17
BulletinParamKey.ROLE_NAME3 = 18
BulletinParamKey.RANK = 19
BulletinParamKey.RATE = 20
BulletinParamKey.PET_ID = 21
BulletinParamKey.NEXT_MONSTER_NAME = 22
BulletinParamKey.HUASHENG_X_SKILL = 23
BulletinParamKey.HB_TIME = 24
BulletinParamKey.SKILL_ID = 25
BulletinParamKey.SKILL_ID2 = 26
BulletinParamKey.JIU_XIAO_ACTIVITYID = 27
BulletinParamKey.EXPLORE_CAT_PARTNER_CFG_ID = 28
BulletinParamKey.CORPS_NAME = 29
BulletinParamKey.RANK_UP_SELECTION_STAGE = 30
BulletinParamKey.SELECTION_TITLE = 31
BulletinParamKey.SELECTION_FIGHT_ZONE = 32
BulletinParamKey.ZONE_ID = 33
BulletinParamKey.EFFECT_ID = 34
BulletinParamKey.MESSAGE = 35
BulletinParamKey.VISIBLE_MONSTER_TYPE_ID = 36
BulletinParamKey.VISIBLE_MONSTER_TYPE_ID_2 = 37
function BulletinParamKey:ctor()
end
function BulletinParamKey:marshal(os)
end
function BulletinParamKey:unmarshal(os)
end
return BulletinParamKey
