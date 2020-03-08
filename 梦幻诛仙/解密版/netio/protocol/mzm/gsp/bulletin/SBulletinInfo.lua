local SBulletinInfo = class("SBulletinInfo")
SBulletinInfo.TYPEID = 12586497
SBulletinInfo.ROLE_GET_ITEM = 1
SBulletinInfo.ROLE_WABAO_GET_ITEM = 2
SBulletinInfo.ROLE_WABAO_FENGYAO = 3
SBulletinInfo.ROLE_EQUIP_LING_LEVEL = 4
SBulletinInfo.ACTIVITY_OPEN = 5
SBulletinInfo.YAOSHOUTUXI_FIGHT_WIN = 6
SBulletinInfo.YAOSHOUTUXI_FIGHT_LOSE = 7
SBulletinInfo.GANG_CREATE = 8
SBulletinInfo.BAOTU_TRIGGER_CTRL = 9
SBulletinInfo.YAOSHOUTUXI_MONSTER_BORN = 10
SBulletinInfo.SHENGXIAO_MONSTER_BORN = 11
SBulletinInfo.BAOTU_AWARD_ITEM = 12
SBulletinInfo.ROLE_RENAME = 13
SBulletinInfo.ROLE_USE_LOTTERY = 14
SBulletinInfo.ROLE_JINGJI_PVP_VICTORY = 15
SBulletinInfo.ROLE_JINGJI_PVP_CHUANSHUO = 16
SBulletinInfo.JIU_XIAO_END_TIP = 17
SBulletinInfo.FLOWER_GIVE = 18
SBulletinInfo.YAOSHOUTUXI_STAR_LEVELUP = 19
SBulletinInfo.KEJU_TOP3 = 20
SBulletinInfo.BIGBOSS_RANK = 21
SBulletinInfo.BIGBOSS_MONSTER = 22
SBulletinInfo.SHENSHOU_REDEEM = 23
SBulletinInfo.BIGBOSS_ACTIVITY_END = 24
SBulletinInfo.KEJU_DIANSHI_KAISHI = 25
SBulletinInfo.MOSHOU_REDEEM = 26
SBulletinInfo.PET_HUASHENG = 27
SBulletinInfo.HB_TIME_DESC = 28
SBulletinInfo.PET_COMPREHEND_SKILL = 29
SBulletinInfo.PET_SKILL_LEVELUP = 30
SBulletinInfo.ONLINE_TREASURE_BOX = 31
SBulletinInfo.MI_BAO_DRAW_LOTTERY = 32
SBulletinInfo.EXPLORE_CAT_BEST_PARTNER = 33
SBulletinInfo.REFRESH_LUCKY_BAG = 34
SBulletinInfo.PAY_NEW_YEAR = 35
SBulletinInfo.SIGN_PRECIOUS = 36
SBulletinInfo.CROSS_BATTLE_SELECTION_BEGIN = 37
SBulletinInfo.MYSTERY_SHOP_BUY = 38
SBulletinInfo.CROSS_BATTLE_SELECTION_RANK_UP = 39
SBulletinInfo.CROSS_BATTLE_SELECTION_RANK_UP_FINAL = 40
SBulletinInfo.CROSS_BATTLE_SELECTION_WIN_TITLE = 41
SBulletinInfo.CROSS_BATTLE_FINAL_BEGIN = 42
SBulletinInfo.CROSS_BATTLE_FINAL_RANK_UP = 43
SBulletinInfo.CROSS_BATTLE_FINAL_WIN_TITLE = 44
SBulletinInfo.CROSS_BATTLE_COMPETE_FINAL = 45
SBulletinInfo.FRIENDS_CIRCLE_GIVE_GIFT = 46
SBulletinInfo.XIAO_HUI_KUAI_PAO_INNER_DRAW = 47
SBulletinInfo.XIAO_HUI_KUAI_PAO_OUTER_DRAW = 48
SBulletinInfo.AUCTION_END_BID = 49
SBulletinInfo.AUCTION_WIN_BID = 50
SBulletinInfo.CROSS_BATTLE_COMPETE_SELECTION = 51
SBulletinInfo.COMMON_VISIBLE_MONSTER_TRIGGER = 52
SBulletinInfo.CHRISTMAS_STOCKING_AWARD = 53
SBulletinInfo.DRAW_CARNIVAL_ACTIVITY_DRAW = 54
function SBulletinInfo:ctor(bulletinType, params)
  self.id = 12586497
  self.bulletinType = bulletinType or nil
  self.params = params or {}
end
function SBulletinInfo:marshal(os)
  os:marshalInt32(self.bulletinType)
  local _size_ = 0
  for _, _ in pairs(self.params) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.params) do
    os:marshalInt32(k)
    os:marshalString(v)
  end
end
function SBulletinInfo:unmarshal(os)
  self.bulletinType = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalString()
    self.params[k] = v
  end
end
function SBulletinInfo:sizepolicy(size)
  return size <= 65535
end
return SBulletinInfo
