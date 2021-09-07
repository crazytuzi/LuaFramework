-- -------------------------------------------
-- 解析出来的元素
-- -------------------------------------------
MsgElement = MsgElement or BaseClass()

function MsgElement:__init()
    -- 区块id,用于图文混排定位
    self.partId = 0
    -- 标签
    self.tag = ""
    -- 值字符串
    self.val = ""
    -- 未处理空格前的原文本
    self.fatherStr = ""
    -- 未解析原文本
    self.srcStr = ""
    -- 替换字符串显示用
    self.showStr = ""
    -- 用来匹配的内容
    self.matchStr = "matchStr"
    -- 纯文本，不带任何标签的
    self.pureStr = ""
    -- 文本
    self.content = ""
    -- 颜色值,对应公用颜色枚举
    self.color = 0
    -- 场景id
    self.battleId = 0
    -- 单位id
    self.unitId = 0
    -- 单位基础id
    self.unitBaseId = 0
    -- 角色id
    self.rid = 0
    -- 平台id
    self.platform = ""
    -- 区号
    self.zoneId = 0
    -- 道具id
    self.itemId = 0
    -- 绑定
    self.bind = 0
    -- 数量
    self.num = 0
    -- 任务id
    self.questId = 0
    -- 表情id
    self.faceId = 0
    -- 面板id
    self.panelId = 0
    -- 宠物id
    self.petId = 0
    -- 守护id
    self.guardId = 0
    -- 资产id
    self.assetId = 0
    -- 自定义连接
    self.linkUrl = ""
    -- 详细信息缓存id,在服务端登记的返回
    self.cacheId = 0
    -- 图标id
    self.iconId = 0
    -- 格子id
    self.cellId = 0
    -- 称号id
    self.honorId = 0
    -- 进队伍
    self.isEnterTeam = false
    -- 等级
    self.lev = 0
    -- 语音图标
    self.voiceIcon = false
    -- 是否是种花
    self.isFlower = false
    -- 是否是按钮unit寻路
    self.isUnitBtn = false
    -- 成就id
    self.achievement_id = 0
    -- 歌曲id
    self.singId = 0
    -- 小图
    self.showSprite = false
    -- 随机值
    self.randomVal = 0
    -- 不需要滚
    self.noRoll = false
    -- 地图id
    self.mapId = 0
    self.posX = 0
    self.posY = 0
    self.childId = 0

    -- 在字符串中的位置
    self.startIndex = 0
    self.endIndex = 0
    -- 元素出现的位置
    self.startX = 0
    self.width = 0
    -- 内部偏移
    self.offsetX = 0
    self.offsetY = 0
    -- 偏移的字符个数
    self.offsetChar = 0

    --神器id
    self.shenqi_id = 0
    --神器品阶
    self.shenqi_flag = 0
    -- 前缀@
    self.prefix1 = ""
    -- 匹配id
    self.matchId = 0
end

-- ----------------------------
-- 消息解析器
-- hosr
-- ----------------------------
MessageParser = MessageParser or {}

-- --------------------------------------------------------------------------------------------------------------------------
-- Example:
-- <li> {prefix_1, 角色名称, @角色, 角色id, 角色平台, 角色区号, 频道} 角色前缀 @xxx</li>
-- <li> {color_1, 颜色值} 在此标签之后的字符都默认使用指定的颜色</li>
-- <li> {string_1, 文字内容} 以默认文字显示字符串</li>
-- <li> {string_2, 颜色值, 字符内容} 以指定颜色显示字符串</li>
-- <li> {link_1, 链接地址} 显示一个链接地址，可点击</li>
-- <li> {link_2, 链接地址, 显示文本} 以指定的文本显示一个链接地址，可点击</li>
-- <li> {panel_1, 面板编号} 显示一个游戏界面的链接，点击后弹出该界面</li>
-- <li> {panel_2, 面板id, 颜色标示, 描述, 等级限制, 参数1,参数2, 参数3} 显示一个游戏界面的链接，使用自定义字符串，点击后弹出该界面</li>
-- <li> {role_1, 角色ID, 平台标识, 区号, 角色名} 使用默认颜色显示一个角色名，点击可查看属性</li>
-- <li> {role_2, 角色名} 使用默认颜色显示一个角色名</li>
-- <li> {role_3, 角色id, 平台标识, 区号, 角色名, 等级, 公会名} 使用默认颜色显示一个角色名</li>
-- <li> {item_1, 平台标识，区号，物品信息缓存ID , 基础ID, 数量} 显示一个物品名称，带有数量显示，点击后弹出tips</li>
-- <li> {item_2, 基础ID, 绑定, 数量} 显示一个物品名称，带有数量显示，点击后弹出tips</li>
-- <li> {item_3, 基础ID, 绑定, 数量, 神器id，神器品阶} 显示一个神器名称，带有数量显示，点击后弹出tips</li>
-- <li> {item_4, 基础ID, 缓存id} 显示一个法宝名称，点击后弹出tips</li>
-- <li> {assets_1, 资产ID, 数量} 显示一个资产，带有数量显示</li>
-- <li> {assets_2, 资产ID} 显示一个资产图标</li>
-- <li> {pet_1, 平台标识, 区号, 宠物信息缓存id, 基础ID} 显示一个动态宠物，带有数量显示</li>
-- <li> {pet_2, 基础ID} 显示一个基础宠物，带有数量显示</li>
-- <li> {guard_1, 平台标识, 区号, 守护信息缓存id, 基础ID，品质} 显示一个动态守护，带有数量显示</li>
-- <li> {guard_2, 基础ID} 显示一个基础守护，带有数量显示</li>
-- <li> {guard_3, role_id, zone_id, platform, role_name} 显示一个基础守护，带有数量显示</li>
-- <li> {dianhua_1, role_id, zone_id, platform, role_name, flag, classes} 显示一个点化装备</li>
-- <li> {face_1, Id} 显示一个表情</li>
-- <li> {face_2, Id, val} 显示一个特殊表情</li>
-- <li> {face_3, Id} 大表情</li>
-- <li> {quest_1, Id} 显示一个任务</li>
-- <li> {unit_1, 单位基础id, 单位名称} </li>
-- <li> {unit_2, 场景id, 唯一id, 单位基础id, 显示名称} </li>
-- <li> {unit_3, 单位名称} </li>
-- <li> {unit_4, 场景id, 唯一id, 单位基础id} </li>
-- <li> {ship_1, 角色id, 平台, 区号, 角色名, 格子} 远航求助</li>
-- <li> {flower_1, battleId, unitid, unitBaseId, 显示内容} 种花求助</li>
-- <li> {honor_1, HonorId} 称号</li>
-- <li> {honor_2, HonorId, showName} 称号</li>
-- <li> {honor_3, HonorId, rid, platform, zone_id,showName} 称号</li>
-- <li> {team_1, 角色id, 平台, 区号, showName} 发送求助，点击进队</li>
-- <li> {achievement_1, id, 角色id, 平台标识, 区号, 当前进度, 最大进度, 完成时间} 成就</li>
-- <li> {exp_1, 经验值, 储备值} 经验里面包含储备经验</li>
-- <li> {rec_1, 录像类型, 录像id, 录像平台, 录像区号, 名字1, 名字2} 战斗录像</li>
-- <li> {strategy_1, 攻略id, 攻略标题} 查看攻略 </li>
-- <li> {wing_1,平台,职业,阶数,品质,id,基础id,角色名} 翅膀 </li>
-- <li> {map_1, map_id, MapName} </li>
-- <li> {map_2, map_id, MapName, x, y} </li>
-- <li> {sing_1, rid, platform, zone_id, name,singid} 好声音</li>
-- <li> {ride_1, 平台标识, 区号, 宠物信息缓存id, 基础ID} 显示一个动态坐骑，带有数量显示</li>
-- <li> {ride_2, 基础ID} 显示一个基础宠物，带有数量显示</li>
-- <li> {home_1,rid,platform,zone_id} </li> -- 某人家园的链接
-- <li> {watch_1,rid,platform,zone_id} </li> -- 观战连接
-- <li> {mention_1,name,rid,platform,zone_id} </li> -- 空间@某人
-- <li> {sing_1,rid,platform,zone_id,content,singid} </li> -- 好声音宣传
-- <li> {sound_1, ID} 播放声音</li>
-- <li> {guildpray_1, 1}
-- <li> {marriagecertificate_1, 男方名字, 男方性别, 男方职业, 男方id, 男方平台, 男方区号, 女方名字, 女方性别, 女方职业, 女方id, 女方平台, 女方区号, 恩爱值, 结婚时间} 显示结婚证</li>
-- <li> {match_1,name,rid,platform,zone_id,type} </li> -- 招募通知
-- <li> {tournament_1,rid,platform,zone_id} </li> 武道大会战绩分享
-- <li> {marriagecertificate_1,content,rid,platform,zone_id} </li> -- 结婚纪念日--
-- <li> {img_1, width, height} </li> -- 结婚纪念日--
-- <li> {magpiefestival_1,content,rid,platform,zone_id} </li> -- 情缘组队--
-- <li> {bargain_1,rid,platform,zone_id,campId} </li> -- 砍价活动 --
-- <li> {noonebadge_1,badgeList,combinationList,role_classes} </li> 王者徽章分享
-- <li> {fationselection_1,fashion_id,role_classes,weaponlooks_id} </li> 时装评选
-- <li> {godswar_1,rid,platform,zone_id} </li> 王者徽章分享
-- <li> {crossarena_1,cross_arena_room_id,cross_arena_room_name,cross_arena_room_password} </li> 跨服擂台分享 -- 对手
-- <li> {crossarena_2,cross_arena_room_id,cross_arena_room_name,cross_arena_room_password} </li> 跨服擂台分享 -- 队友
-- <li> {crossarena_3,cross_arena_room_id,cross_arena_room_name,cross_arena_room_password} </li> 跨服擂台分享 -- 招募
-- <li> {action_1,显示文本,颜色值,执行参数} </li> 自定义方法，执行函数在MessageAction.DoAction方法中


-- 去掉空格,不然u3d自己换行了
function MessageParser.NoSpace(str)
    -- 这两个空格不一样，注意拉
    str = string.gsub(str, "%s+", "")
    return str
end

-- 把换行空格替换成占位空格
function MessageParser.ReplaceSpace(str)
    -- 这两个空格不一样，注意拉
    str = string.gsub(str, " ", " ")
    return str
end

-- 把带空格的标签替换成不带空格的标签
function MessageParser.ReplaceTags(tags, str)
    for i,msg in ipairs(tags) do
        str = string.gsub(str, msg.fatherStr, msg.srcStr, 1)
    end
    return str
end

-- function MessageParser.Filter(str)
--     local tags = {}
--     for tag,val in string.gmatch(str, "{(%l-_%d-),(.-)}") do
--         local msg = MsgElement.New()
--         msg.fatherStr = string.format("{%s,%s}", tag, val)
--         msg.tag = MessageParser.NoSpace(tag)
--         msg.val = MessageParser.NoSpace(val)
--         msg.srcStr = string.format("{%s,%s}", msg.tag, msg.val)
--         table.insert(tags, msg)
--     end
--     return tags
-- end

-- function MessageParser.Baked(str)
--     local tags = MessageParser.Filter(str)
--     for i,msg in ipairs(tags) do
--         local tag = msg.tag
--         msg.offsetX = 0
--         msg.offsetY = 0
--         if tag == "color_1" then
--             msg.color = msg.val
--         elseif tag == "string_1" then
--             msg.content = msg.val
--             msg.showStr = msg.val
--             msg.matchStr = msg.val
--         elseif tag == "string_2" then
--             local args = StringHelper.Split(msg.val, ",")
--             msg.color = args[1]
--             msg.content = args[2]
--             msg.showStr = string.format("<color='%s'>%s</color>", ColorHelper.GetColor(msg.color), args[2])
--             msg.matchStr = msg.showStr
--         elseif tag == "panel_1" then
--             msg.panelId = tonumber(msg.val)
--         elseif tag == "panel_2" then
--             local args = StringHelper.Split(msg.val, ",")
--             msg.panelId = tonumber(args[1])
--             msg.color = args[2]
--             msg.content = args[3]
--             msg.showStr = string.format("<color='%s'>%s</color>", ColorHelper.GetColor(msg.color), args[3])
--             msg.matchStr = msg.showStr
--         elseif tag == "panel_3" then
--             local args = StringHelper.Split(msg.val, ",")
--             msg.panelId = tonumber(args[1])
--             msg.color = args[2]
--             msg.content = args[3]
--         elseif tag == "role_1" then
--             local args = StringHelper.Split(msg.val, ",")
--             msg.rid = tonumber(args[1])
--             msg.platform = args[2]
--             msg.zoneId = tonumber(args[3])
--             msg.content = args[4]
--             msg.showStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Role], args[4])
--             msg.matchStr = msg.showStr
--         elseif tag == "role_2" then
--             msg.content = msg.val
--             msg.showStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Role], msg.val)
--             msg.matchStr = msg.showStr
--         elseif tag == "assets_1" then
--             local args = StringHelper.Split(msg.val, ",")
--             msg.assetId = tonumber(args[1])
--             msg.num = tonumber(args[2])
--             msg.offsetX = NoticeManager.Instance.model.calculator:SimpleGetWidth(args[2])
--             msg.offsetY = 5
--             if msg.num == 0 then
--                 msg.showStr = "   "
--             else
--                 msg.showStr = string.format("<color='#00ff00'><b>%s</b></color>   ", msg.num)
--             end
--             msg.matchStr = msg.showStr
--         elseif tag == "assets_2" then
--             msg.assetId = tonumber(msg.val)
--             msg.offsetX = 0
--             msg.offsetY = 5
--             msg.showStr = "   "
--             msg.matchStr = msg.showStr
--         elseif tag == "exp_1" then
--             local args = StringHelper.Split(msg.val, ",")
--             msg.assetId = 90010
--             msg.num = tonumber(args[1])
--             msg.offsetX = NoticeManager.Instance.model.calculator:SimpleGetWidth(args[1])
--             msg.offsetY = 5
--             if msg.num == 0 then
--                 msg.showStr = "   "
--             else
--                 msg.showStr = string.format("<color='#00ff00'><b>%s</b></color>   储<color='#00ff00'><b>%s</b></color>", msg.num, tonumber(args[2]))
--             end
--             msg.matchStr = msg.showStr
--         elseif tag == "pet_1" then
--             local args = StringHelper.Split(msg.val, ",")
--             msg.platform = args[1]
--             msg.zoneId = tonumber(args[2])
--             msg.cacheId = tonumber(args[3])
--             msg.petId = tonumber(args[4])
--             local petData = DataPet.data_pet[msg.petId]
--             if petData ~= nil then
--                 msg.iconId = petData.head_id
--                 msg.showStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Pet], string.format("[%s]", petData.name))
--                 msg.matchStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Pet], string.format("%%[%s%%]", petData.name))
--             end
--         elseif tag == "pet_2" then
--             msg.petId = tonumber(msg.val)
--             local petData = DataPet.data_pet[msg.petId]
--             if petData ~= nil then
--                 msg.iconId = petData.head_id
--                 msg.showStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Pet], string.format("[%s]", petData.name))
--                 msg.matchStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Pet], string.format("%%[%s%%]", petData.name))
--             end
--         elseif tag == "guard_1" then
--             local args = StringHelper.Split(msg.val, ",")
--             msg.platform = args[1]
--             msg.zoneId = tonumber(args[2])
--             msg.cacheId = tonumber(args[3])
--             msg.guardId = tonumber(args[4])
--             local guardData = DataShouhu.data_guard_base_cfg[msg.guardId]
--             if guardData ~= nil then
--                 msg.showStr = ColorHelper.color_item_name(guardData.quality, string.format("[%s]", guardData.name))
--                 msg.matchStr = msg.showStr
--             end
--         elseif tag == "guard_2" then
--             msg.guardId = tonumber(msg.val)
--             local guardData = DataShouhu.data_guard_base_cfg[msg.guardId]
--             if guardData ~= nil then
--                 msg.showStr = ColorHelper.color_item_name(guardData.quality, string.format("[%s]", guardData.name))
--                 msg.matchStr = msg.showStr
--             end
--         elseif tag == "unit_1" then
--             local args = StringHelper.Split(msg.val, ",")
--             msg.unitBaseId = tonumber(args[1])
--             msg.content = args[2]
--             msg.showStr = msg.content
--             msg.showStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Unit], msg.content)
--             msg.matchStr = msg.showStr
--         elseif tag == "unit_2" then
--             local args = StringHelper.Split(msg.val, ",")
--             msg.battleId = tonumber(args[1])
--             msg.unitId = tonumber(args[2])
--             msg.unitBaseId = tonumber(args[3])
--             msg.content = args[4]
--             msg.showStr = msg.content
--             msg.showStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Unit], msg.content)
--             msg.matchStr = msg.showStr
--         elseif tag == "quest_1" then
--             msg.questId = tonumber(msg.val)
--             local questData = DataQuest.data_get[msg.questId]
--             if questData ~= nil then
--                 msg.showStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Pet], string.format("[%s]", questData.name))
--             end
--             msg.matchStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Pet], string.format("%%[%s%%]", questData.name))
--         elseif tag == "item_1" then
--             local args = StringHelper.Split(msg.val, ",")
--             msg.platform = args[1]
--             msg.zoneId = tonumber(args[2])
--             msg.cacheId = tonumber(args[3])
--             msg.itemId = tonumber(args[4])
--             msg.num = tonumber(args[5])
--             local itemData = DataItem.data_get[msg.itemId]
--             if itemData ~= nil then
--                 msg.iconId = itemData.icon
--                 msg.content = itemData.name
--                 if msg.num > 1 then
--                     msg.showStr = ColorHelper.color_item_name(itemData.quality , string.format("[%sx%s]", itemData.name, msg.num))
--                 else
--                     msg.showStr = ColorHelper.color_item_name(itemData.quality ,string.format("[%s]", itemData.name))
--                 end
--                 msg.matchStr = ColorHelper.color_item_name(itemData.quality ,string.format("%%[%s%%]", itemData.name))
--             end
--         elseif tag == "item_2" then
--             local args = StringHelper.Split(msg.val, ",")
--             msg.itemId = tonumber(args[1])
--             msg.bind = tonumber(args[2])
--             msg.num = tonumber(args[3])
--             local itemData = DataItem.data_get[msg.itemId]
--             if itemData ~= nil then
--                 msg.iconId = itemData.icon
--                 msg.content = itemData.name
--                 if msg.num > 1 then
--                     msg.showStr = ColorHelper.color_item_name(itemData.quality , string.format("[%sx%s]", itemData.name, msg.num))
--                 else
--                     msg.showStr = ColorHelper.color_item_name(itemData.quality ,string.format("[%s]", itemData.name))
--                 end
--                 msg.matchStr = ColorHelper.color_item_name(itemData.quality ,string.format("%%[%s%%]", itemData.name))
--             end
--         elseif tag == "face_1" then
--             msg.faceId = tonumber(msg.val)
--             msg.content = string.format("#%s", msg.val)
--             if msg.faceId == 7 or msg.faceId == 16 or msg.faceId == 34 or msg.faceId == 41 then
--                 msg.showStr = "      "
--             else
--                 msg.showStr = "   "
--             end
--             msg.matchStr = msg.showStr
--         elseif tag == "face_2" then
--             local args = StringHelper.Split(msg.val, ",")
--             msg.faceId = tonumber(args[1])
--             msg.randomVal = tonumber(args[2])
--             msg.content = string.format("#%s", msg.faceId)
--             if msg.faceId == 7 or msg.faceId == 16 or msg.faceId == 34 or msg.faceId == 41 then
--                 msg.showStr = "      "
--             else
--                 msg.showStr = "   "
--             end
--             msg.matchStr = msg.showStr
--         elseif tag == "link_1" then
--             msg.linkUrl = msg.val
--             msg.content = "点击跳转"
--             msg.showStr = msg.content
--             msg.matchStr = msg.showStr
--         elseif tag == "link_2" then
--             local args = StringHelper.Split(msg.val, ",")
--             msg.linkUrl = args[1]
--             msg.content = args[2]
--             msg.showStr = args[2]
--             msg.matchStr = msg.showStr
--         elseif tag == "ship_1" then
--             local args = StringHelper.Split(msg.val, ",")
--             msg.rid = tonumber(args[1])
--             msg.platform = args[2]
--             msg.zoneId = tonumber(args[3])
--             msg.content = args[4]
--             msg.cellId = tonumber(args[5])
--         elseif tag == "flower_1" then
--             msg.isFlower = true
--             local args = StringHelper.Split(msg.val, ",")
--             msg.battleId = tonumber(args[1])
--             msg.unitId = tonumber(args[2])
--             msg.unitBaseId = tonumber(args[3])
--             msg.content = args[4]
--         elseif tag == "honor_1" then
--             msg.honorId = tonumber(msg.val)
--             local honorData = nil
--             if msg.honorId > 100000 then
--                 honorData = DataAchievement.data_list[msg.honorId]
--             else
--                 honorData = DataHonor.data_get_honor_list[msg.honorId]
--             end
--             if honorData ~= nil then
--                 msg.content = string.format("<color='%s'>%s</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Honor], honorData.name)
--                 msg.showStr = string.format("<color='%s'>[%s]</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Honor], honorData.name)
--                 msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Honor], honorData.name)
--             end
--         elseif tag == "honor_2" then
--             local args = StringHelper.Split(msg.val, ",")
--             msg.honorId = tonumber(args[1])
--             msg.content = args[2]

--             local honorData = nil
--             if msg.honorId > 100000 then
--                 honorData = DataAchievement.data_list[msg.honorId]
--             else
--                 honorData = DataHonor.data_get_honor_list[msg.honorId]
--             end

--             if honorData ~= nil then
--                 msg.content = string.format("<color='%s'>%s</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Honor], msg.content)
--                 msg.showStr = string.format("<color='%s'>[%s]</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Honor], msg.content)
--                 msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Honor], msg.content)
--             end
--         elseif tag == "team_1" then
--             --  {team_1, 角色id, 平台, 区号, showName}
--             msg.isEnterTeam = true
--             local args = StringHelper.Split(msg.val, ",")
--             msg.rid = tonumber(args[1])
--             msg.platform = args[2]
--             msg.zoneId = tonumber(args[3])
--             msg.content = args[4]
--         elseif tag == "achievement_1"then
--             local args = StringHelper.Split(msg.val, ",")
--             msg.content = args[1]

--             msg.achievement_id = tonumber(args[1])
--             msg.achievement_role_name = args[2]
--             msg.achievement_rid = tonumber(args[3])
--             msg.achievement_platform = args[4]
--             msg.achievement_zoneId = tonumber(args[5])
--             msg.progress = tonumber(args[6])
--             msg.progress_max = tonumber(args[7])
--             msg.time = tonumber(args[8])
--             local achievementData = DataAchievement.data_list[msg.achievement_id]
--             if achievementData ~= nil then
--                 msg.content = string.format("<color='%s'>%s</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Achievement], achievementData.name)
--                 msg.showStr = string.format("<color='%s'>[%s]</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Achievement], msg.content)
--                 msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Achievement], msg.content)
--             end
--         elseif tag == "rec_1"then
--             local args = StringHelper.Split(msg.val, ",")
--             msg.content = args[1]
--             msg.rec_type = tonumber(args[1])
--             msg.rec_id = tonumber(args[2])
--             msg.rec_platform = (args[3])
--             msg.rec_zoneId = tonumber(args[4])
--             msg.rec_name1 = args[5]
--             msg.rec_name2 = args[6]
--             msg.content = string.format("<color='%s'>%s</color>VS<color='%s'>%s</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Rec], msg.rec_name1, ColorHelper.MessageColor[ColorHelper.MsgType.Rec], msg.rec_name2)
--             msg.showStr = string.format("<color='#ffa500'>[战斗录像：%s]</color>", msg.content)
--             msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Rec], msg.content)
--         elseif tag == "wing_1"then
--             local numberToChinese = {"一", "二", "三", "四", "五","六"}
--             local args = StringHelper.Split(msg.val, ",")
--             msg.wing_platform = args[1]
--             msg.wing_zoneid = tonumber(args[2])
--             msg.wing_classes = tonumber(args[3])
--             msg.wing_grade = tonumber(args[4])
--             msg.wing_growth = tonumber(args[5])
--             msg.wing_id = tonumber(args[6])
--             msg.wing_baseid = tonumber(args[7])
--             local base = DataWing.data_base[msg.wing_baseid]
--             msg.showStr = ColorHelper.color_item_name(msg.wing_growth, string.format("[%s]", base.name))
--         end
--         msg.showStr = string.gsub(msg.showStr, "<.->", "")
--     end
--     return tags
-- end

-- -- 对标签定位
-- function MessageParser.Locate(str, tags)
--     local list = {}
--     local beginIndex = 1
--     local tempWidth = 0
--     local nowStr = ""
--     for i,msg in ipairs(tags) do
--         local startIndex, endIndex = string.find(str, msg.srcStr, beginIndex, true)
--         msg.startIndex = startIndex
--         msg.endIndex = endIndex

--         if startIndex ~= beginIndex then
--             local str = string.sub(str, beginIndex, startIndex - 1)
--             tempWidth = tempWidth + NoticeManager.Instance.model.calculator:SimpleGetWidth(str)
--             table.insert(list, str)
--             nowStr = nowStr .. str
--         end
--         msg.beforeStr = nowStr
--         msg.startX = tempWidth
--         msg.width = NoticeManager.Instance.model.calculator:SimpleGetWidth(msg.showStr)
--         tempWidth = tempWidth + msg.width
--         beginIndex = endIndex + 1
--         nowStr = nowStr .. msg.showStr
--         table.insert(list, msg.showStr)
--     end

--     local str = string.sub(str, beginIndex, string.len(str))
--     if str ~= nil and str ~= "" then
--         table.insert(list, str)
--     end
--     return list
-- end

-- -----------------------------------------------
-- 简化处理，为新的处理方式做数据收集整理
-- hosr 20160616
-- TextGenerator版本
-- -----------------------------------------------
function MessageParser.OneMethod(str)
    local msgData = MsgData.New()
    local elements = {}
    local lastIdx = 1
    local result1 = ""
    local result2 = ""
    local beforeStr = ""
    local atTab = {} -- @列表

    -- for tag, val in string.gmatch(str, "{(%l-_%d-),(.-)}") do
    for tag, val in string.gmatch(str, "{(%l-_%d.-),(.-)}") do
        local tagStr = string.format("{%s,%s}", tag, val)
        -- print("str="..str)
        -- print("tagStr="..tagStr)
        -- print("lastIdx="..lastIdx)
        local startIndex, endIndex = string.find(str, tagStr, lastIdx, true)
        beforeStr = string.sub(str, lastIdx, startIndex - 1)
        -- print("beforeStr="..beforeStr)
        -- local tagStr = string.sub(str, startIndex, endIndex, 1)
        -- 补上标签与标签之间的字符
        result1 = result1 .. beforeStr
        result2 = result2 .. beforeStr

        -- print("result1="..result1)
        -- print("result2="..result2)
        tag = string.gsub(tag, "　", "")
        val = string.gsub(val, "　", "")

        local msg = MsgElement.New()
        msg.fatherStr = tagStr
        msg.srcStr = tagStr
        msg.tag = tag
        msg.val = val
        msg.offsetX = 0
        msg.offsetY = 0
        if tag == "color_1" then
            msg.color = msg.val
        elseif tag == "prefix_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.content = tostring(args[1])
            msg.prefix1 = tostring(args[2])
            msg.rid = tonumber(args[3])
            msg.platform = args[4]
            msg.zoneId = tonumber(args[5])
            msg.showStr = string.format("<color='#c32dfa'>@%s</color>", msg.prefix1)
            msg.matchStr = string.format("<color='#c32dfa'>@%s</color>", msg.prefix1)
            msg.pureStr = string.format("@%s", msg.prefix1)
            if string.format("%s_%s_%s", msg.platform, msg.zoneId, msg.rid) == BaseUtils.get_self_id() then
                local channel = tonumber(args[6])
                local k = string.format("%s_%s", msg.content, channel)
                local lastTime = ChatManager.Instance.atLimitTab[k]
                if lastTime == nil or (lastTime ~= nil and BaseUtils.BASE_TIME - lastTime >= 60) then
                    atTab[k] = string.format(TI18N("<color='#31f2f9'>%s</color>在<color='#ffff00'>%s</color>频道<color='#c32dfa'>@</color>了你一下"), msg.content, MsgEumn.ChatChannelName[channel])
                end
            end
        elseif tag == "string_1" then
            -- msg={string_1,通关{string_2,#00ff00,[困难极寒试炼]}}
            -- val1=通关{string_2,#00ff00,[困难极寒试炼]
            msg.val = string.gsub(msg.val, "{string_2,(.-),(.-)", "%2")
            msg.content = msg.val
            msg.showStr = msg.val
            msg.matchStr = msg.val
            msg.pureStr = string.gsub(msg.content, "<.->", "")
        elseif tag == "string_2" then
            local args = StringHelper.Split(msg.val, ",")
            msg.color = args[1]
            msg.content = args[2]
            msg.showStr = string.format("<color='%s'>%s</color>", ColorHelper.GetColor(msg.color), args[2])
            msg.matchStr = msg.showStr
            msg.pureStr = msg.content
        elseif tag == "panel_1" then
            msg.panelId = tonumber(msg.val)
        elseif tag == "panel_2" then
            local args = StringHelper.Split(msg.val, ",")
            msg.panelId = tonumber(args[1])
            msg.color = args[2]
            msg.content = args[3]
            msg.levlimit = tonumber(args[4])
            msg.args = {}
            if args[5] ~= nil then
                table.insert(msg.args, tonumber(args[5]))
            end
            if args[6] ~= nil then
                table.insert(msg.args, tonumber(args[6]))
            end
            if args[7] ~= nil then
                table.insert(msg.args, tonumber(args[7]))
            end
            msg.showStr = string.format("<color='%s'>[%s]</color>", ColorHelper.GetColor(msg.color), args[3])
            msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", ColorHelper.GetColor(msg.color), args[3])
            msg.pureStr = string.format("[%s]", args[3])
        elseif tag == "panel_3" then
            local args = StringHelper.Split(msg.val, ",")
            msg.panelId = tonumber(args[1])
            msg.color = args[2]
            msg.content = args[3]
            msg.pureStr = msg.content
        elseif tag == "role_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.rid = tonumber(args[1])
            msg.platform = args[2]
            msg.zoneId = tonumber(args[3])
            msg.content = args[4]
            msg.showStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Role], args[4])
            msg.matchStr = msg.showStr
            msg.pureStr = msg.content
        elseif tag == "role_2" then
            msg.content = msg.val
            msg.showStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Role], msg.val)
            msg.matchStr = msg.showStr
            msg.pureStr = msg.content
        elseif tag == "assets_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.assetId = tonumber(args[1])
            msg.num = tonumber(args[2])
            msg.offsetX = 3
            msg.offsetY = 5
            if msg.num == 0 then
                msg.showStr = "　　"
            else
                msg.showStr = string.format("<color='#00ff00'>%s</color>　　", msg.num)
            end
            msg.matchStr = msg.showStr
            -- 纯净的字符串
            msg.pureStr = string.format("%s　　", msg.num)
            -- 偏移的字符串个数
            msg.offsetChar = #StringHelper.ConvertStringTable(tostring(msg.num))
        elseif tag == "assets_2" then
            msg.assetId = tonumber(msg.val)
            msg.offsetX = 3
            msg.offsetY = 5
            msg.showStr = "　　"
            msg.pureStr = msg.showStr
            msg.matchStr = msg.showStr
        elseif tag == "exp_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.assetId = 90010
            msg.num = tonumber(args[1])
            msg.offsetX = 2
            msg.offsetY = 5
            if msg.num == 0 then
                msg.showStr = "　　"
            else
                msg.showStr = string.format(TI18N("<color='#00ff00'>%s</color>　　储<color='#00ff00'>%s</color>"), msg.num, tonumber(args[2]))
                msg.offsetChar = #StringHelper.ConvertStringTable(tostring(msg.num))
            end
            msg.pureStr = string.format(TI18N("%s　　储%s"), msg.num, tonumber(args[2]))
            msg.matchStr = msg.showStr
        elseif tag == "pet_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.platform = args[1]
            msg.zoneId = tonumber(args[2])
            msg.cacheId = tonumber(args[3])
            msg.petId = tonumber(args[4])
            msg.growth_type = tonumber(args[5])
            local petData = DataPet.data_pet[msg.petId]
            if petData ~= nil then
                msg.iconId = petData.head_id
                msg.showStr = ColorHelper.color_item_name(msg.growth_type, string.format("[%s]", petData.name))
                msg.matchStr = msg.showStr
                msg.pureStr = string.format("[%s]", petData.name)
            end
        elseif tag == "pet_2" then
            msg.petId = tonumber(msg.val)
            local petData = DataPet.data_pet[msg.petId]
            if petData ~= nil then
                msg.iconId = petData.head_id
                msg.showStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Pet], string.format("[%s]", petData.name))
                msg.matchStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Pet], string.format("%%[%s%%]", petData.name))
                msg.pureStr = string.format("[%s]", petData.name)
            end
        elseif tag == "child_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.platform = args[1]
            msg.zoneId = tonumber(args[2])
            msg.cacheId = tonumber(args[3])
            msg.childId = tonumber(args[4])
            msg.showname = args[5]
            msg.growth_type = tonumber(args[6])
            local childData = DataChild.data_child[msg.childId]
            if childData ~= nil then
                msg.iconId = childData.head_id
                msg.showStr = ColorHelper.color_item_name(msg.growth_type, string.format("[%s]", msg.showname))
                msg.matchStr = msg.showStr
                msg.pureStr = string.format("[%s]", msg.showname)
            end
        elseif tag == "child_2" then
            msg.childId = tonumber(msg.val)
            local childData = DataChild.data_child[msg.childId]
            if childData ~= nil then
                msg.iconId = childData.head_id
                msg.showStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Pet], string.format("[%s]", childData.name))
                msg.matchStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Pet], string.format("%%[%s%%]", childData.name))
                msg.pureStr = string.format("[%s]", childData.name)
            end
        elseif tag == "guard_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.platform = args[1]
            msg.zoneId = tonumber(args[2])
            msg.cacheId = tonumber(args[3])
            msg.guardId = tonumber(args[4])
            msg.quality = tonumber(args[5])
            local guardData = DataShouhu.data_guard_base_cfg[msg.guardId]
            if guardData ~= nil then
                msg.showStr = ColorHelper.color_item_name(msg.quality, string.format("[%s]", guardData.name))
                msg.matchStr = msg.showStr
                msg.pureStr = string.format("[%s]", guardData.name)
            end
        elseif tag == "guard_2" then
            msg.guardId = tonumber(msg.val)
            local guardData = DataShouhu.data_guard_base_cfg[msg.guardId]
            if guardData ~= nil then
                msg.showStr = ColorHelper.color_item_name(guardData.quality, string.format("[%s]", guardData.name))
                msg.matchStr = msg.showStr
                msg.pureStr = string.format("[%s]", guardData.name)
            end
         elseif tag == "dianhua_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.dianhuaBadge = 1
            msg.roleId = tonumber(args[1])
            msg.zoneId = tonumber(args[2])
            msg.platform = tostring(args[3])
            msg.roleName = tostring(args[4])
            msg.flag = tonumber(args[5])
            msg.classes = tonumber(args[6])
            local levStr = EquipStrengthManager.Instance.model.dianhua_name[msg.flag]
            msg.showStr = string.format("<color='#ff00ff'>[%s%s]</color>", levStr, TI18N("精炼徽章"))
            msg.matchStr = string.format("<color='#ff00ff'>%%[%s%s%%]</color>", levStr, TI18N("精炼徽章"))
            msg.pureStr = string.format("[%s%s]", levStr, TI18N("精炼徽章"))
        elseif tag == "guard_3" then
            local args = StringHelper.Split(msg.val, ",")
            msg.guardWakeup = 1
            msg.roleId = tonumber(args[1])
            msg.zoneId = tonumber(args[2])
            msg.platform = tostring(args[3])
            msg.roleName = tostring(args[4])
            msg.showStr = string.format("<color='#ff00ff'>[%s%s]</color>", msg.roleName, TI18N("的守护魂石"))
            msg.matchStr = string.format("<color='#ff00ff'>%%[%s%s%%]</color>", msg.roleName, TI18N("的守护魂石"))
            msg.pureStr = string.format("[%s%s]", msg.roleName, TI18N("的守护魂石"))
        elseif tag == "unit_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.unitBaseId = tonumber(args[1])
            msg.content = args[2]
            msg.showStr = msg.content
            msg.showStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Unit], msg.content)
            msg.matchStr = msg.showStr
            msg.pureStr = msg.content
        elseif tag == "v dscacas " then
        elseif tag == "unit_2" then
            local args = StringHelper.Split(msg.val, ",")
            msg.battleId = tonumber(args[1])
            msg.unitId = tonumber(args[2])
            msg.unitBaseId = tonumber(args[3])
            msg.content = args[4]
            msg.showStr = msg.content
            msg.showStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Unit], msg.content)
            msg.matchStr = msg.showStr
            msg.pureStr = msg.content
        elseif tag == "unit_3" then
            msg.content = msg.val
            msg.showStr = string.format("<color='#017dd7'>%s</color>", msg.val)
            msg.matchStr = msg.showStr
            msg.pureStr = msg.content
        elseif tag == "unit_4" then
            local args = StringHelper.Split(msg.val, ",")
            msg.battleId = tonumber(args[1])
            msg.unitId = tonumber(args[2])
            msg.unitBaseId = tonumber(args[3])
            msg.isUnitBtn = true
        elseif tag == "quest_1" then
            msg.questId = tonumber(msg.val)
            local questData = DataQuest.data_get[msg.questId]
            if questData ~= nil then
                msg.showStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Pet], string.format("[%s]", questData.name))
                msg.matchStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Pet], string.format("%%[%s%%]", questData.name))
                msg.pureStr = string.format("[%s]", questData.name)
            end
        elseif tag == "item_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.platform = args[1]
            msg.zoneId = tonumber(args[2])
            msg.cacheId = tonumber(args[3])
            msg.itemId = tonumber(args[4])
            msg.num = tonumber(args[5])
            local itemData = DataItem.data_get[msg.itemId]
            if itemData ~= nil then
                msg.iconId = itemData.icon
                msg.content = itemData.name
                if msg.num > 1 then
                    msg.showStr = ColorHelper.color_item_name(itemData.quality , string.format("[%sx%s]", itemData.name, msg.num))
                    msg.matchStr = ColorHelper.color_item_name(itemData.quality ,string.format("%%[%sx%s%%]", itemData.name, msg.num))
                    msg.pureStr = string.format("[%sx%s]", itemData.name, msg.num)
                else
                    msg.showStr = ColorHelper.color_item_name(itemData.quality ,string.format("[%s]", itemData.name))
                    msg.matchStr = ColorHelper.color_item_name(itemData.quality ,string.format("%%[%s%%]", itemData.name))
                    msg.pureStr = string.format("[%s]", itemData.name)
                end
            end
        elseif tag == "item_2" then
            local args = StringHelper.Split(msg.val, ",")
            msg.itemId = tonumber(args[1])
            msg.bind = tonumber(args[2])
            msg.num = tonumber(args[3])
            local itemData = DataItem.data_get[msg.itemId]
            if itemData ~= nil then
                msg.iconId = itemData.icon
                msg.content = itemData.name
                if msg.num > 1 then
                    msg.showStr = ColorHelper.color_item_name(itemData.quality , string.format("[%sx%s]", itemData.name, msg.num))
                    msg.matchStr = ColorHelper.color_item_name(itemData.quality ,string.format("%%[%sx%s%%]", itemData.name, msg.num))
                    msg.pureStr = string.format("[%sx%s]", itemData.name, msg.num)
                else
                    msg.showStr = ColorHelper.color_item_name(itemData.quality ,string.format("[%s]", itemData.name))
                    msg.matchStr = ColorHelper.color_item_name(itemData.quality ,string.format("%%[%s%%]", itemData.name))
                    msg.pureStr = string.format("[%s]", itemData.name)
                end
            end
        elseif tag == "item_3" then
            --神器
            local args = StringHelper.Split(msg.val, ",")
            msg.platform = args[1]
            msg.zoneId = tonumber(args[2])
            msg.cacheId = tonumber(args[3])
            msg.itemId = tonumber(args[4])
            msg.num = tonumber(args[5])
            msg.shenqi_id = tonumber(args[6])
            msg.shenqi_flag = tonumber(args[7])
            local itemData = DataItem.data_get[msg.itemId]
            if itemData ~= nil then
                msg.iconId = itemData.icon
                local match_name_str = itemData.name
                local append_name_str = itemData.name
                if msg.shenqi_id ~= 0 then
                    match_name_str = DataItem.data_get[msg.shenqi_id].name
                    append_name_str = DataItem.data_get[msg.shenqi_id].name
                    if msg.shenqi_flag ~= 0 then
                        local name_pre = EquipStrengthManager.Instance.model.dianhua_name[msg.shenqi_flag]
                        match_name_str = string.format("%s[%s%s]%s", "%", name_pre, "%",match_name_str)
                        append_name_str = string.format("[%s]%s", name_pre, append_name_str)
                    end
                end

                msg.content = append_name_str
                if msg.num > 1 then
                    msg.showStr = ColorHelper.color_item_name(itemData.quality , string.format("[%sx%s]", append_name_str, msg.num))
                    msg.matchStr = ColorHelper.color_item_name(itemData.quality ,string.format("%%[%sx%s%%]", append_name_str, msg.num))
                    msg.pureStr = string.format("[%sx%s]", match_name_str, msg.num)
                else
                    msg.showStr = ColorHelper.color_item_name(itemData.quality ,string.format("[%s]", append_name_str))
                    msg.matchStr = ColorHelper.color_item_name(itemData.quality ,string.format("%%[%s%%]", match_name_str))
                    msg.pureStr = string.format("[%s]", append_name_str)
                end
            end
        elseif tag == "item_4" then
            --法宝
            local args = StringHelper.Split(msg.val, ",")
            msg.platform = args[1]
            msg.zoneId = tonumber(args[2])
            msg.itemId = tonumber(args[3])
            msg.talismancacheId = tonumber(args[4])
            local itemData = DataTalisman.data_get[msg.itemId]
            if itemData == nil then
                Log.Error(string.format("[聊天]{item_4}类型参数错误:  %s",  msg.srcStr))
            end
            if itemData.quality >= 3 then
                msg.showStr = ColorHelper.color_item_name(itemData.quality ,string.format("[[%s]%s]", TalismanEumn.QualifyName[itemData.quality], itemData.name))
                msg.matchStr = ColorHelper.color_item_name(itemData.quality ,string.format("%%[%%[%s%%]%s%%]", TalismanEumn.QualifyName[itemData.quality], itemData.name))
                msg.pureStr = string.format("[[%s]%s]", TalismanEumn.QualifyName[itemData.quality], itemData.name)
            else
                msg.showStr = ColorHelper.color_item_name(itemData.quality ,string.format("[%s]", itemData.name))
                msg.matchStr = ColorHelper.color_item_name(itemData.quality ,string.format("%%[%s%%]", itemData.name))
                msg.pureStr = string.format("[%s]", itemData.name)
            end
        elseif tag == "face_1" then
            msg.faceId = tonumber(msg.val)
            msg.content = string.format("#%s", msg.val)
            if msg.faceId == 7 or msg.faceId == 16 or msg.faceId == 34 or msg.faceId == 41 or msg.faceId == 114 or msg.faceId == 123 or msg.faceId == 124 or msg.faceId == 125 or msg.faceId  == 126 or msg.faceId  == 128 or msg.faceId  == 135 then
                msg.showStr = "　　　"
                msg.offsetX = -3
            else
                msg.showStr = "　　"
                msg.offsetX = 1
            end
            msg.matchStr = msg.showStr
            msg.pureStr = msg.showStr
        elseif tag == "face_2" then
            local args = StringHelper.Split(msg.val, ",")
            msg.faceId = tonumber(args[1])
            msg.randomVal = tonumber(args[2])
            msg.content = string.format("#%s", msg.faceId)
            if msg.faceId == 7 or msg.faceId == 16 or msg.faceId == 34 or msg.faceId == 41 then
                msg.showStr = "　　　"
                msg.offsetX = -3
            else
                msg.showStr = "　　"
                msg.offsetX = 1
            end
            msg.matchStr = msg.showStr
            msg.pureStr = msg.showStr
        elseif tag == "face_3" then
            msg.faceId = tonumber(msg.val)
            msg.showStr = "　　　　　\n　　　　　\n　　　　　\n　　　　　"
            msg.offsetX = 3
            msg.offsetY = -5
            msg.pureStr = msg.showStr
            msg.matchStr = msg.showStr
        elseif tag == "link_1" then
            msg.linkUrl = msg.val
            msg.content = TI18N("点击跳转")
            msg.showStr = msg.content
            msg.matchStr = msg.showStr
            msg.pureStr = msg.showStr
        elseif tag == "link_2" then
            local args = StringHelper.Split(msg.val, ",")
            msg.linkUrl = args[1]
            msg.content = args[2]
            msg.showStr = string.format("<color='#ffff00'>%s</color>", args[2])
            msg.matchStr = args[2]
            msg.pureStr = args[2]
        elseif tag == "ship_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.rid = tonumber(args[1])
            msg.platform = args[2]
            msg.zoneId = tonumber(args[3])
            msg.content = args[4]
            msg.cellId = tonumber(args[5])
        elseif tag == "flower_1" then
            msg.isFlower = true
            local args = StringHelper.Split(msg.val, ",")
            msg.battleId = tonumber(args[1])
            msg.unitId = tonumber(args[2])
            msg.unitBaseId = tonumber(args[3])
            msg.content = args[4]
        elseif tag == "honor_1" then
            msg.honorId = tonumber(msg.val)
            local honorData = nil
            if msg.honorId > 100000 then
                honorData = DataAchievement.data_list[msg.honorId]
            else
                honorData = DataHonor.data_get_honor_list[msg.honorId]
            end
            if honorData ~= nil then
                msg.content = string.format("<color='%s'>%s</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Honor], honorData.name)
                msg.showStr = string.format("<color='%s'>[%s]</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Honor], honorData.name)
                msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Honor], honorData.name)
                msg.pureStr = string.format("[%s]", honorData.name)
            end
        elseif tag == "honor_2" then
            local args = StringHelper.Split(msg.val, ",")
            msg.honorId = tonumber(args[1])
            msg.content = args[2]

            local honorData = nil
            if msg.honorId > 100000 then
                honorData = DataAchievement.data_list[msg.honorId]
            else
                honorData = DataHonor.data_get_honor_list[msg.honorId]
            end

            if honorData ~= nil then
                msg.pureStr = string.format("[%s]", msg.content)
                msg.content = string.format("<color='%s'>%s</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Honor], msg.content)
                msg.showStr = string.format("<color='%s'>[%s]</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Honor], msg.content)
                msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Honor], msg.content)
            end

        elseif tag == "honor_3" then
            local args = StringHelper.Split(msg.val, ",")
            msg.honorId = tonumber(args[1])
            msg.panelId = WindowConfig.WinID.worldchampionshare
            msg.args = args
            msg.content = args[5]
            msg.pureStr = string.format("[%s]", msg.content)
            msg.content = string.format("<color='%s'>%s</color>", "#FFA500", msg.content)
            msg.showStr = string.format("<color='%s'>[%s]</color>", "#FFA500", msg.content)
            msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", "#FFA500", msg.content)
        elseif tag == "honor_4" then
            local args = StringHelper.Split(msg.val, ",")
            msg.honorId = tonumber(args[1])
            msg.panelId = WindowConfig.WinID.worldchampionshare
            msg.args = args
            msg.content = args[5]
            msg.pureStr = string.format("[%s]", TI18N("武道战绩"))
            -- msg.content = string.format("<color='%s'>%s</color>%s", "#FFA500", TI18N("武道战绩"))
            msg.showStr = string.format("<color='%s'>[%s]</color>", "#FFA500", TI18N("武道战绩"))
            msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", "#FFA500", TI18N("武道战绩"))
        elseif tag == "noonebadge_1" then
            local args = StringHelper.Split(msg.val, ",")
            --msg.honorId = tonumber(args[1])
            msg.badgeList = args[1]
            msg.args = args
            msg.pureStr = string.format("[%s]", TI18N("王者徽章"))
            msg.showStr = string.format("<color='%s'>[%s]</color>", "#FFA500", TI18N("王者徽章"))
            msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", "#FFA500", TI18N("王者徽章"))
        elseif tag == "honor_5" then
            local args = StringHelper.Split(msg.val, ",")
            msg.honorId = tonumber(args[1])
            msg.panelId = WindowConfig.WinID.constellation_profile_window
            msg.args = args
            msg.content = args[5]
            msg.pureStr = string.format("[%s]", msg.content)
            msg.content = string.format("<color='%s'>%s</color>", "#FFA500", msg.content)
            msg.showStr = string.format("<color='%s'>[%s]</color>", "#FFA500", msg.content)
            msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", "#FFA500", msg.content)
        elseif tag == "honor_6" then
            local args = StringHelper.Split(msg.val, ",")
            msg.honorId = tonumber(args[1])
            msg.panelId = WindowConfig.WinID.constellation_profile_window
            msg.args = args
            msg.content = args[5]
            msg.pureStr = string.format("[%s]", TI18N("星座驾照"))
            -- msg.content = string.format("<color='%s'>%s</color>%s", "#FFA500", TI18N("武道战绩"))
            msg.showStr = string.format("<color='%s'>[%s]</color>", "#FFA500", TI18N("星座驾照"))
            msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", "#FFA500", TI18N("星座驾照"))
        elseif tag == "team_1" then
            --  {team_1, 角色id, 平台, 区号, showName}
            msg.isEnterTeam = true
            local args = StringHelper.Split(msg.val, ",")
            msg.rid = tonumber(args[1])
            msg.platform = args[2]
            msg.zoneId = tonumber(args[3])
            msg.content = args[4]
            msg.pureStr = msg.content
        elseif tag == "achievement_1"then
            local args = StringHelper.Split(msg.val, ",")
            msg.content = args[1]

            msg.achievement_id = tonumber(args[1])
            msg.achievement_role_name = args[2]
            msg.achievement_rid = tonumber(args[3])
            msg.achievement_platform = args[4]
            msg.achievement_zoneId = tonumber(args[5])
            msg.progress = tonumber(args[6])
            msg.progress_max = tonumber(args[7])
            msg.time = tonumber(args[8])
            local achievementData = DataAchievement.data_list[msg.achievement_id]
            if achievementData ~= nil then
                msg.pureStr = string.format("[%s]", achievementData.name)
                msg.content = string.format("<color='%s'>%s</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Achievement], achievementData.name)
                msg.showStr = string.format("<color='%s'>[%s]</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Achievement], msg.content)
                msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Achievement], msg.content)
            end
        elseif tag == "rec_1"then
            local args = StringHelper.Split(msg.val, ",")
            msg.content = args[1]
            msg.rec_type = tonumber(args[1])
            msg.rec_id = tonumber(args[2])
            msg.rec_platform = (args[3])
            msg.rec_zoneId = tonumber(args[4])
            msg.rec_name1 = args[5]
            msg.rec_name2 = args[6]
            msg.content = string.format("<color='%s'>%s</color>VS<color='%s'>%s</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Rec], msg.rec_name1, ColorHelper.MessageColor[ColorHelper.MsgType.Rec], msg.rec_name2)
            msg.showStr = string.format(TI18N("<color='#ffa500'>[战斗录像：%s]</color>"), msg.content)
            msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Rec], msg.content)
            msg.pureStr = string.format(TI18N("[战斗录像：%sVS%s]"), msg.rec_name1, msg.rec_name2)
        elseif tag == "watch_1"then
            local args = StringHelper.Split(msg.val, ",")
            msg.content = args[1]
            msg.watch_id = tonumber(args[1])
            msg.watch_platform = (args[2])
            msg.watch_zoneId = tonumber(args[3])
            msg.pureStr = string.format("[%s]", TI18N("点击观战"))
            msg.content = string.format("<color='%s'>%s</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Achievement], TI18N("点击观战"))
            msg.showStr = string.format("<color='%s'>[%s]</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Achievement], msg.content)
            msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", ColorHelper.MessageColor[ColorHelper.MsgType.Achievement], msg.content)
            -- msg.content = TI18N("<color='#01c0ff'>[点击观战]</color>")
            -- msg.showStr = TI18N("<color='#01c0ff'>[点击观战]</color>")
            -- msg.matchStr = TI18N("<color='#01c0ff'>%%[%s%%]</color>")
            -- msg.pureStr = TI18N("<color='#01c0ff'>[点击观战]</color>")
        elseif tag == "wing_1"then
            local numberToChinese = {TI18N("一"), TI18N("二"), TI18N("三"), TI18N("四"), TI18N("五"),TI18N("六")}
            local args = StringHelper.Split(msg.val, ",")
            msg.wing_platform = args[1]
            msg.wing_zoneid = tonumber(args[2])
            msg.wing_classes = tonumber(args[3])
            msg.wing_grade = tonumber(args[4])
            msg.wing_growth = tonumber(args[5])
            msg.wing_id = tonumber(args[6])
            msg.wing_baseid = tonumber(args[7])
            msg.owner = args[8]
            local base = DataWing.data_base[msg.wing_baseid]
            if base ~= nil then
                msg.showStr = string.format(TI18N("<color='#ff0000'>[%s阶翅膀]</color>"), BaseUtils.NumToChn(msg.wing_grade)) -- ColorHelper.color_item_name(msg.wing_growth, string.format("[%s]", base.name))
                msg.pureStr = string.format(TI18N("[%s阶翅膀]"), BaseUtils.NumToChn(msg.wing_grade))
            end
        elseif tag == "strategy_1" then
            -- 攻略
            local args = StringHelper.Split(msg.val, ",")
            msg.strategy_id = tonumber(args[1])
            msg.content = args[2]
            msg.showStr = string.format("<color='#00AA00'>%s</color>", args[2])
            msg.matchStr = msg.showStr
            msg.pureStr = msg.content
        elseif tag == "sound_1"then
            msg.sound_id = tonumber(msg.val)
        elseif tag == "map_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.mapId = tonumber(args[1])
            msg.content = args[2]
            msg.showStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Map], msg.content)
            msg.matchStr = msg.showStr
            msg.pureStr = msg.content
        elseif tag == "map_2" then
            local args = StringHelper.Split(msg.val, ",")
            msg.mapId = tonumber(args[1])
            msg.content = args[2]
            msg.posX = tonumber(args[3])
            msg.posY = tonumber(args[4])
            msg.showStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Map], msg.content)
            msg.matchStr = msg.showStr
            msg.pureStr = msg.content
        elseif tag == "sing_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.rid = tonumber(args[1])
            msg.platform = args[2]
            msg.zoneId = tonumber(args[3])
            msg.content = args[4]
            msg.singId = tonumber(args[5])
            msg.showStr = string.format(TI18N("<color='#00CCFF'>[%s的好声音]</color>快来支持我吧~"), msg.content)
            msg.matchStr = string.format(TI18N("%%[%s%%的好声音]快来支持我吧~"), msg.content)
            msg.pureStr = string.format(TI18N("[%s的好声音]快来支持我吧~"), msg.content)
        elseif tag == "mention_1" then --@某人
            local args = StringHelper.Split(msg.val, ",")
            msg.name = args[1]
            msg.rid = tonumber(args[2])
            msg.platform = args[3]
            msg.zoneId = tonumber(args[4])
            msg.showStr = string.format("<color='#2e5cdf'>@%s</color>", msg.name)
            msg.matchStr = string.format("%%@%s", msg.name)
            msg.pureStr = string.format("@%s", msg.name)
        elseif tag == "home_1" then --某人家园链接
            local args = StringHelper.Split(msg.val, ",")
            msg.name = args[1]
            msg.rid = tonumber(args[2])
            msg.platform = args[3]
            msg.zoneId = tonumber(args[4])
            msg.homeTag = true
            msg.showStr = string.format("<color='#00ff00'>[%s]</color>", msg.name)
            msg.matchStr = string.format("%%[%%s%%]", msg.name)
            msg.pureStr = string.format("[%s]", msg.name)
        elseif tag == "ride_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.platform = args[1]
            msg.zoneId = tonumber(args[2])
            msg.cacheId = tonumber(args[3])
            msg.rideId = tonumber(args[4])
            msg.growth = tonumber(args[5])
            local rideData = DataMount.data_ride_data[msg.rideId]
            if rideData ~= nil then
                msg.iconId = rideData.head_id
                if msg.growth == 0 then
                    msg.showStr = string.format("[%s]", rideData.name)
                else
                    msg.showStr = ColorHelper.color_item_name(msg.growth, string.format("[%s]", rideData.name))
                end
                msg.matchStr = msg.showStr
                msg.pureStr = string.format("[%s]", rideData.name)
            end
        elseif tag == "ride_2" then
            msg.rideId = tonumber(msg.val)
            local rideData = DataMount.data_ride_data[msg.rideId]
            if rideData ~= nil then
                msg.iconId = rideData.head_id
                msg.showStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Ride], string.format("[%s]", rideData.name))
                msg.matchStr = ColorHelper.Fill(ColorHelper.MessageColor[ColorHelper.MsgType.Ride], string.format("%%[%s%%]", rideData.name))
                msg.pureStr = string.format("[%s]", rideData.name)
            end
        elseif tag == "tournament_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.tid = tonumber(args[1])
            msg.tplatform = args[2]
            msg.tzone_id = tonumber(args[3])
            msg.showStr = TI18N("<color='#c03e39'>[天下第一武道会战绩]</color>")
            msg.matchStr = TI18N("<color='#c03e39'>%%[天下第一武道会战绩%%]</color>")
            msg.pureStr = TI18N("[天下第一武道会战绩]")
        elseif tag == "marriagecertificate_1"then
            local args = StringHelper.Split(msg.val, ",")
            msg.content = args[1]
            msg.marriagecertificate_id = tonumber(args[2])
            msg.marriagecertificate_platform = args[3]
            msg.marriagecertificate_zoneId = tonumber(args[4])

            msg.showStr = string.format("<color='#c03e39'>[%s]</color>", msg.content)
            msg.matchStr = string.format("<color='#c03e39'>%%[%s%%]</color>", msg.content)
            msg.pureStr = string.format("[%s]", msg.content)
        elseif tag == "bargain_1" then
            local args = StringHelper.Split(msg.val, ",")

            msg.content = args[1]
            msg.bargain_id = tonumber(args[2])
            msg.bargain_platform = args[3]
            msg.bargain_zoneId = tonumber(args[4])
            msg.bargain_name = args[5]
            msg.campId = tonumber(args[6])

            msg.showStr = string.format("<color='#248813'>[%s]</color>", msg.content)
            msg.matchStr = string.format("<color='#248813'>%%[%s%%]</color>", msg.content)
            msg.pureStr = string.format("[%s]", msg.content)
            -- msg.bargain_name = tonumber(args[4])
        elseif tag == "fationselection_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.content = args[1]
            msg.fation_selection_fashionId = tonumber(args[2])
            msg.fation_selection_roleClasses = args[3]
            msg.fation_selection_sex = args[4]
            msg.fation_selection_weapModel = tonumber(args[5])
            msg.fation_selection_weapVal = tonumber(args[6])
            msg.fation_selection_Id = tonumber(args[7])
            msg.fation_selection_platform = args[8]
            msg.fation_selection_zoneId = tonumber(args[9])
            msg.fation_selection_name = args[10]
            msg.fation_selection_lev = tonumber(args[11])


            msg.showStr = string.format("<color='#248813'>[%s]</color>", msg.content)
            msg.matchStr = string.format("<color='#248813'>%%[%s%%]</color>", msg.content)
            msg.pureStr = string.format("[%s]", msg.content)
        elseif tag == "godswar_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.content = args[1]
            msg.godWarRid = tonumber(args[2])
            msg.godWarPlatform = tostring(args[3])
            msg.godWarZoneId = tonumber(args[4])

            msg.showStr = string.format("<color='%s'>[%s]</color>", "#FFA500", msg.content)
            msg.matchStr = string.format("<color='%s'>[%s]</color>", "#FFA500", msg.content)
            msg.pureStr = string.format("[%s]", msg.content)
        elseif tag == "magpiefestival_1"then
            local args = StringHelper.Split(msg.val, ",")
            msg.content = args[1]
            msg.magpiefestival_id = tonumber(args[2])
            msg.magpiefestival_platform = args[3]
            msg.magpiefestival_zoneId = tonumber(args[4])

            msg.showStr = string.format("<color='#248813'>[%s]</color>", msg.content)
            msg.matchStr = string.format("<color='#248813'>%%[%s%%]</color>", msg.content)
            msg.pureStr = string.format("[%s]", msg.content)
        elseif tag == "match_1" then
            local args = StringHelper.Split(msg.val, ",")
            local name = tostring(args[1])
            msg.rid = tonumber(args[2])
            msg.platform = tostring(args[3])
            msg.zoneId = tonumber(args[4])
            msg.matchId = tonumber(args[5])
            msg.content = ""
            msg.showStr = ""
            msg.matchStr = ""
            msg.pureStr = ""
        elseif tag == "guildpray_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.guildpray_1 = tonumber(args[1])
            msg.color = args[2]
            msg.content = args[3]
            msg.levlimit = tonumber(args[4])
            msg.args = {}
            if args[5] ~= nil then
                table.insert(msg.args, tonumber(args[5]))
            end
            if args[6] ~= nil then
                table.insert(msg.args, tonumber(args[6]))
            end
            if args[7] ~= nil then
                table.insert(msg.args, tonumber(args[7]))
            end
            msg.showStr = string.format("<color='%s'>[%s]</color>", ColorHelper.GetColor(msg.color), args[3])
            msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", ColorHelper.GetColor(msg.color), args[3])
            msg.pureStr = string.format("[%s]", args[3])
        elseif tag == "protocal_1"then
            local args = StringHelper.Split(msg.val, ",")
            msg.name = args[1]
            msg.cmd = tonumber(args[2])
            msg.arg1 = tonumber(args[3])
            msg.arg2 = tostring(args[4])
            msg.arg3 = tonumber(args[5])
            msg.pureStr = string.format("[%s]", msg.name)
            msg.content = string.format("<color='%s'>%s</color>", ColorHelper.color[1], msg.name)
            msg.showStr = string.format("<color='%s'>[%s]</color>", ColorHelper.color[1], msg.name)
            msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", ColorHelper.color[1], msg.name)
        elseif tag == "img_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.imgWidth = tonumber(args[1]) * 28 / tonumber(args[2])
            msg.imgHeight = 28
            msg.showSprite = true
            msg.showStr = "　　"
            msg.pureStr = msg.showStr
            msg.matchStr = msg.showStr
        elseif tag == "crossarena_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.cross_arena_room_id = tonumber(args[1])
            msg.cross_arena_room_name = args[2]
            msg.cross_arena_room_password = args[3]
            msg.cross_arena_room_rid = tonumber(args[4])
            msg.cross_arena_room_platform = args[5]
            msg.cross_arena_room_zone_id = tonumber(args[6])
            msg.cross_arena_msg_type = 1
            msg.pureStr = string.format("[%s]", msg.cross_arena_room_name)
            msg.content = string.format("<color='%s'>%s</color>", ColorHelper.color[1], msg.cross_arena_room_name)
            msg.showStr = string.format("<color='%s'>[%s]</color>", ColorHelper.color[1], msg.cross_arena_room_name)
            msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", ColorHelper.color[1], msg.cross_arena_room_name)
        elseif tag == "crossarena_2" then
            local args = StringHelper.Split(msg.val, ",")
            msg.cross_arena_room_id = tonumber(args[1])
            msg.cross_arena_room_name = args[2]
            msg.cross_arena_room_password = args[3]
            msg.cross_arena_room_rid = tonumber(args[4])
            msg.cross_arena_room_platform = args[5]
            msg.cross_arena_room_zone_id = tonumber(args[6])
            msg.cross_arena_msg_type = 2
            msg.pureStr = string.format("[%s]", msg.cross_arena_room_name)
            msg.content = string.format("<color='%s'>%s</color>", ColorHelper.color[1], msg.cross_arena_room_name)
            msg.showStr = string.format("<color='%s'>[%s]</color>", ColorHelper.color[1], msg.cross_arena_room_name)
            msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", ColorHelper.color[1], msg.cross_arena_room_name)
        elseif tag == "crossarena_3" then
            local args = StringHelper.Split(msg.val, ",")
            msg.cross_arena_room_id = tonumber(args[1])
            msg.cross_arena_room_name = args[2]
            msg.cross_arena_room_password = args[3]
            msg.cross_arena_room_rid = tonumber(args[4])
            msg.cross_arena_room_platform = args[5]
            msg.cross_arena_room_zone_id = tonumber(args[6])
            msg.cross_arena_msg_type = 3
            -- msg.pureStr = string.format("[%s]", msg.cross_arena_room_name)
            -- msg.content = string.format("<color='%s'>%s</color>", ColorHelper.color[1], msg.cross_arena_room_name)
            -- msg.showStr = string.format("<color='%s'>[%s]</color>", ColorHelper.color[1], msg.cross_arena_room_name)
            -- msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", ColorHelper.color[1], msg.cross_arena_room_name)
            msg.content = ""
            msg.showStr = ""
            msg.matchStr = ""
            msg.pureStr = ""
        elseif tag == "action_1" then
            local args = StringHelper.Split(msg.val, ",")
            msg.name = args[1]
            msg.color = tostring(args[2])
            msg.action = tonumber(args[3])
            msg.pureStr = string.format("[%s]", msg.name)
            msg.content = string.format("<color='%s'>%s</color>", msg.color, msg.name)
            msg.showStr = string.format("<color='%s'>[%s]</color>", msg.color, msg.name)
            msg.matchStr = string.format("<color='%s'>%%[%s%%]</color>", msg.color, msg.name)
        end

        -- 元素开始的字符串位置
        msg.tagIndex = #StringHelper.ConvertStringTable(result2) + 1
        -- 元素结束的字符串位置
        msg.tagEndIndex = msg.tagIndex + #StringHelper.ConvertStringTable(msg.pureStr) - 1

        result1 = result1 .. msg.showStr
        result2 = result2 .. msg.pureStr

        -- 存好封装好的元素
        table.insert(elements, msg)
        -- 把处理完后tag覆盖掉原字符串的tag
        -- print("showStr="..msg.showStr)
        -- 这个正则的替换，限制好大，内容带有特殊符合就傻逼了，还好我已经知道了开始结束的下标，直接截取字符就好,强无敌
        -- str = string.gsub(str, tagStr, msg.showStr, 1)
        -- print("str2="..str)
        -- 下一个开始检索的位置
        lastIdx = string.len(result1) + 1
        str = result1 .. string.sub(str, endIndex+1, string.len(str))
    end

    -- 补上最后一个标签到最后的字符
    local lastStr = string.sub(str, lastIdx, string.len(str))
    result1 = result1 .. lastStr
    result2 = result2 .. lastStr
    -- print("lastIdx=" .. lastIdx)
    -- print("len=" .. string.len(str))
    -- print("str=" .. str)
    -- print("lastStr=" .. lastStr)
    -- print("result1=" .. result1)
    -- print("result2=" .. result2)

    msgData.sourceString = result1
    msgData.showString = result1
    msgData.pureString = result2
    -- print("showString=" .. msgData.showString)
    -- print("pureString=" .. msgData.pureString)
    msgData.elements = elements
    msgData.atTab = atTab

    return msgData
end

-- --------------------------------
-- 不用这个替换的方法了
-- 在替换的串里面出现魔法字符时还要处理
-- 魔法字符的转义，效率不高
-- 所以改用table.concat方法
-- 因为已经取到了要展示的标签的列表了
-- --------------------------------
-- function MessageParser.Replace(str, tags)
--     local tarStr = str
--     for i,msg in ipairs(tags) do
--         -- 只匹配一次
--         tarStr = string.gsub(tarStr, msg.srcStr, msg.showStr, 1)
--     end
--     return tarStr
-- end

-- 返回一个封装好的数据结构
function MessageParser.GetMsgData(msg, fontSize)
    -- fontSize = fontSize or 17
    -- NoticeManager.Instance.model.calculator:ChangeFoneSize(fontSize)
    -- msg = MessageParser.NoSpace(msg)
    -- -- msg = MessageParser.ReplaceSpace(msg)
    -- local tags = MessageParser.Baked(msg)
    -- -- msg = MessageParser.ReplaceTags(tags, msg)
    -- local list = MessageParser.Locate(msg, tags)
    local msgData = MsgData.New()
    msgData.sourceString = msg
    -- if #list == 0 then
    msgData.showString = msg
    -- else
        -- msgData.showString = table.concat(list)
    -- end
    -- msgData.elements = tags
    -- msgData.allWidth = math.ceil(NoticeManager.Instance.model.calculator:SimpleGetWidth(msgData.showString))
    return msgData
end

-- 把消息里面的表情替代符替换成标签，最多5个
function MessageParser.ConvertToTag_Face(msg)
    local faces = {}
    local hasRoll = false
    local hasGuess = false
    local msgTemp = string.gsub(msg, "<.->", "")
    for faceId in string.gmatch(msgTemp, "#(%d+)") do
        if  MessageParser.CheckFaceHas(faceId) == true then
            if tonumber(faceId) == 1000 and not hasRoll then
                hasRoll = true
                table.insert(faces, faceId)
            elseif tonumber(faceId) == 1001 and not hasGuess then
                hasGuess = true
                table.insert(faces, faceId)
            elseif #faces < 5 then
                if tonumber(faceId) <= 200 then
                    if MessageParser.CheckFace(faceId) then
                        table.insert(faces, faceId)
                    end
                end

                -- and tonumber(faceId) >= 100 then
                -- -- 3位数以上的取两位
                -- local nfaceId = tonumber(string.sub(faceId, 1, 2))
                -- if MessageParser.CheckFace(nfaceId) then
                --     table.insert(faces, nfaceId)
                -- end
            -- elseif #faces < 5 then
            --     if MessageParser.CheckFace(faceId) then
            --         table.insert(faces, faceId)
            --     end
            end
        end
    end

    for i,faceId in ipairs(faces) do
        if i <= 5 then
            local src = string.format("#%s", faceId)
            local rep = string.format("{face_1,%s}", faceId)
            if tonumber(faceId) >= 1000 then
                rep = string.format("{face_2,%s,0}", faceId)
            end
            msg = string.gsub(msg, src, rep, 1)
        end
    end

    return msg
end

function MessageParser.CheckFace(faceId)
    local _type = PrivilegeManager.Instance:GetValueByType(PrivilegeEumn.Type.specialFacePack)
    local cfg_data = DataChatFace.data_get_chat_face_privilege[tonumber(faceId)]
    if cfg_data ~= nil and cfg_data.privilege <= _type then
        return true
    end
    cfg_data = DataChatFace.data_new_face[tonumber(faceId)]
    if cfg_data ~= nil then
        return true
    end
    return false
end
function MessageParser.CheckFaceHas(faceId)
    local _type = PrivilegeManager.Instance:GetValueByType(PrivilegeEumn.Type.specialFacePack)
    local cfg_data = DataChatFace.data_get_chat_face_privilege[tonumber(faceId)]
    if cfg_data ~= nil and cfg_data.privilege <= _type then
        return true
    end

    if ChatManager.Instance.miniFaceDic ~= nil then
        if ChatManager.Instance.miniFaceDic[tonumber(faceId)] ~= nil then
            return true
        end
    end

    if ChatManager.Instance.bigFaceDic ~= nil then
        if ChatManager.Instance.bigFaceDic[tonumber(faceId)] ~= nil then
            return true
        end
    end
    return false

end

-- 查询是否包含某标签
function MessageParser.ContainTag(elements, tag)
    for i,element in ipairs(elements) do
        if element.tag == tag then
            return element
        end
    end
    return nil
end

-- 根据分辨率进行转换
function MessageParser.ScaleVal(val, isSceneFace)
    if isSceneFace then
        return val
    end
    local origin = 960 / 540
    local currentScale = ctx.ScreenWidth / ctx.ScreenHeight
    local cw = 0
    local ch = 0
    if currentScale > origin then
        -- 以宽为准
        cw = 960 * currentScale / origin
        ch = 540
    else
        -- 以高为准
        cw = 960
        ch = 540 * origin / currentScale
    end
    val = val * cw / ctx.ScreenWidth
    return val
end
