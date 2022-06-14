------------------typedef vector2i ----------------------------------
function sendPushvector2i(data)
-- vector x
	networkengine:pushInt(data.x);
-- vector y
	networkengine:pushInt(data.y);
end

function Parsevector2i()
	local tempArrayCount = 0;
	local data = {};

-- vector x
	data['x'] = networkengine:parseInt();
-- vector y
	data['y'] = networkengine:parseInt();

	return data;
end

------------------typedef MagicInfo ----------------------------------
function sendPushMagicInfo(data)
-- 魔法id
	networkengine:pushInt(data.id);
-- 魔法等级
	networkengine:pushInt(data.level);
-- 在快捷栏中的位置
	networkengine:pushInt(data.position);
end

function ParseMagicInfo()
	local tempArrayCount = 0;
	local data = {};

-- 魔法id
	data['id'] = networkengine:parseInt();
-- 魔法等级
	data['level'] = networkengine:parseInt();
-- 在快捷栏中的位置
	data['position'] = networkengine:parseInt();

	return data;
end

------------------typedef CardUpgrade ----------------------------------
function sendPushCardUpgrade(data)
-- 卡牌ID
	networkengine:pushInt(data.cardID);
-- 卡牌升级后的经验值
	networkengine:pushInt(data.cardExp);
-- 是否新获得
	networkengine:pushBool(data.firstGain);
-- 之前星级
	networkengine:pushInt(data.preStar);
-- 现在星级
	networkengine:pushInt(data.currentStar);
end

function ParseCardUpgrade()
	local tempArrayCount = 0;
	local data = {};

-- 卡牌ID
	data['cardID'] = networkengine:parseInt();
-- 卡牌升级后的经验值
	data['cardExp'] = networkengine:parseInt();
-- 是否新获得
	data['firstGain'] = networkengine:parseBool();
-- 之前星级
	data['preStar'] = networkengine:parseInt();
-- 现在星级
	data['currentStar'] = networkengine:parseInt();

	return data;
end

------------------typedef ShipUnitInfo ----------------------------------
function sendPushShipUnitInfo(data)
-- ship上的cardtype
	networkengine:pushInt(data.cardType);
-- ship上unit的数量
	networkengine:pushInt(data.unitCount);
end

function ParseShipUnitInfo()
	local tempArrayCount = 0;
	local data = {};

-- ship上的cardtype
	data['cardType'] = networkengine:parseInt();
-- ship上unit的数量
	data['unitCount'] = networkengine:parseInt();

	return data;
end

------------------typedef IncidentSummary ----------------------------------
function sendPushIncidentSummary(data)
-- 发生的领地事件ID
	networkengine:pushInt(data.eventID);
-- 领地事件的地图关卡位置(不管发生还是没发生)
	networkengine:pushInt(data.position);
-- 领地事件下次可触发的时间点
	networkengine:pushUInt64(data.nextTime);
end

function ParseIncidentSummary()
	local tempArrayCount = 0;
	local data = {};

-- 发生的领地事件ID
	data['eventID'] = networkengine:parseInt();
-- 领地事件的地图关卡位置(不管发生还是没发生)
	data['position'] = networkengine:parseInt();
-- 领地事件下次可触发的时间点
	data['nextTime'] = networkengine:parseUInt64();

	return data;
end

------------------typedef Reward ----------------------------------
function sendPushReward(data)
-- 奖励类型
	networkengine:pushInt(data.type);
-- 奖励id
	networkengine:pushInt(data.id);
-- 奖励数量
	networkengine:pushInt(data.count);
end

function ParseReward()
	local tempArrayCount = 0;
	local data = {};

-- 奖励类型
	data['type'] = networkengine:parseInt();
-- 奖励id
	data['id'] = networkengine:parseInt();
-- 奖励数量
	data['count'] = networkengine:parseInt();

	return data;
end

------------------typedef MailPreview ----------------------------------
function sendPushMailPreview(data)
-- 邮件id
	networkengine:pushInt(data.id);
-- 邮件标题
	networkengine:pushInt(string.len(data.caption));
	networkengine:pushString(data.caption, string.len(data.caption));
-- 邮件时间
	networkengine:pushUInt64(data.time);
-- 是否已读
	networkengine:pushBool(data.isReaded);
end

function ParseMailPreview()
	local tempArrayCount = 0;
	local data = {};

-- 邮件id
	data['id'] = networkengine:parseInt();
-- 邮件标题
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['caption'] = networkengine:parseString(strlength);
else
		data['caption'] = "";
end
-- 邮件时间
	data['time'] = networkengine:parseUInt64();
-- 是否已读
	data['isReaded'] = networkengine:parseBool();

	return data;
end

------------------typedef MailAttachment ----------------------------------
function sendPushMailAttachment(data)
-- 附件id
	networkengine:pushInt(data.id);
-- 来源
	networkengine:pushInt(data.source);
-- 附件类型
	networkengine:pushInt(data.type);
-- 附件子类型
	networkengine:pushInt(data.subType);
-- 堆叠数量
	networkengine:pushInt(data.overlay);
end

function ParseMailAttachment()
	local tempArrayCount = 0;
	local data = {};

-- 附件id
	data['id'] = networkengine:parseInt();
-- 来源
	data['source'] = networkengine:parseInt();
-- 附件类型
	data['type'] = networkengine:parseInt();
-- 附件子类型
	data['subType'] = networkengine:parseInt();
-- 堆叠数量
	data['overlay'] = networkengine:parseInt();

	return data;
end

------------------typedef ShipPlanInfo ----------------------------------
function sendPushShipPlanInfo(data)
-- 船上的卡牌ID
	networkengine:pushInt(data.cardID);
-- 位置
	sendPushvector2i(data.position);
end

function ParseShipPlanInfo()
	local tempArrayCount = 0;
	local data = {};

-- 船上的卡牌ID
	data['cardID'] = networkengine:parseInt();
-- 位置
	data['position'] = Parsevector2i();

	return data;
end

------------------typedef ShipInfo ----------------------------------
function sendPushShipInfo(data)
-- ship index
	networkengine:pushInt(data.index);
-- ship level
	networkengine:pushInt(data.level);
-- 船改造等级
	networkengine:pushInt(data.remouldLevel);
-- 船的配置信息
	local arrayLength = #data.plans;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.plans) do
		sendPushShipPlanInfo(v);
	end

end

function ParseShipInfo()
	local tempArrayCount = 0;
	local data = {};

	data['plans'] = {};
-- ship index
	data['index'] = networkengine:parseInt();
-- ship level
	data['level'] = networkengine:parseInt();
-- 船改造等级
	data['remouldLevel'] = networkengine:parseInt();
-- 船的配置信息
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['plans'][i] = ParseShipPlanInfo();
	end

	return data;
end

------------------typedef FriendInfo ----------------------------------
function sendPushFriendInfo(data)
-- 好友id
	networkengine:pushInt(data.friendID);
-- headID
	networkengine:pushInt(data.headID);
-- 等级
	networkengine:pushInt(data.level);
-- 好友vip
	networkengine:pushInt(data.vip);
-- 奇迹等级
	networkengine:pushInt(data.miracle);
-- 发送标记0:代表未发送, 1:有发送体力
	networkengine:pushInt(data.sendFlag);
-- 接受标记0:代表没有体力, 1:代表有体力, 2:代表领取过体力了
	networkengine:pushInt(data.recvFlag);
-- 好友昵称
	networkengine:pushInt(string.len(data.nickname));
	networkengine:pushString(data.nickname, string.len(data.nickname));
-- 最后一次登录时间
	networkengine:pushUInt64(data.lastLoginTime);
end

function ParseFriendInfo()
	local tempArrayCount = 0;
	local data = {};

-- 好友id
	data['friendID'] = networkengine:parseInt();
-- headID
	data['headID'] = networkengine:parseInt();
-- 等级
	data['level'] = networkengine:parseInt();
-- 好友vip
	data['vip'] = networkengine:parseInt();
-- 奇迹等级
	data['miracle'] = networkengine:parseInt();
-- 发送标记0:代表未发送, 1:有发送体力
	data['sendFlag'] = networkengine:parseInt();
-- 接受标记0:代表没有体力, 1:代表有体力, 2:代表领取过体力了
	data['recvFlag'] = networkengine:parseInt();
-- 好友昵称
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['nickname'] = networkengine:parseString(strlength);
else
		data['nickname'] = "";
end
-- 最后一次登录时间
	data['lastLoginTime'] = networkengine:parseUInt64();

	return data;
end

------------------typedef FriendMessage ----------------------------------
function sendPushFriendMessage(data)
-- 内容
	networkengine:pushInt(string.len(data.content));
	networkengine:pushString(data.content, string.len(data.content));
end

function ParseFriendMessage()
	local tempArrayCount = 0;
	local data = {};

-- 内容
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['content'] = networkengine:parseString(strlength);
else
		data['content'] = "";
end

	return data;
end

------------------typedef FriendApplicant ----------------------------------
function sendPushFriendApplicant(data)
-- 申请者id
	networkengine:pushInt(data.applyID);
-- head index
	networkengine:pushInt(data.headID);
-- level
	networkengine:pushInt(data.level);
-- 目标的vip
	networkengine:pushInt(data.vip);
-- 目标的奇迹等级
	networkengine:pushInt(data.miracle);
-- 昵称
	networkengine:pushInt(string.len(data.nickname));
	networkengine:pushString(data.nickname, string.len(data.nickname));
end

function ParseFriendApplicant()
	local tempArrayCount = 0;
	local data = {};

-- 申请者id
	data['applyID'] = networkengine:parseInt();
-- head index
	data['headID'] = networkengine:parseInt();
-- level
	data['level'] = networkengine:parseInt();
-- 目标的vip
	data['vip'] = networkengine:parseInt();
-- 目标的奇迹等级
	data['miracle'] = networkengine:parseInt();
-- 昵称
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['nickname'] = networkengine:parseString(strlength);
else
		data['nickname'] = "";
end

	return data;
end

------------------typedef FriendSearchInfo ----------------------------------
function sendPushFriendSearchInfo(data)
-- id
	networkengine:pushInt(data.id);
-- head icon
	networkengine:pushInt(data.icon);
-- nickname
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- level
	networkengine:pushInt(data.level);
-- 玩家的vip
	networkengine:pushInt(data.vip);
-- 奇迹等级
	networkengine:pushInt(data.miracle);
end

function ParseFriendSearchInfo()
	local tempArrayCount = 0;
	local data = {};

-- id
	data['id'] = networkengine:parseInt();
-- head icon
	data['icon'] = networkengine:parseInt();
-- nickname
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- level
	data['level'] = networkengine:parseInt();
-- 玩家的vip
	data['vip'] = networkengine:parseInt();
-- 奇迹等级
	data['miracle'] = networkengine:parseInt();

	return data;
end

------------------typedef ShopItemInfo ----------------------------------
function sendPushShopItemInfo(data)
-- table表的索引id
	networkengine:pushInt(data.rowIndex);
-- row中物品数组的索引
	networkengine:pushInt(data.arrayIndex);
-- 剩下的数量
	networkengine:pushInt(data.count);
end

function ParseShopItemInfo()
	local tempArrayCount = 0;
	local data = {};

-- table表的索引id
	data['rowIndex'] = networkengine:parseInt();
-- row中物品数组的索引
	data['arrayIndex'] = networkengine:parseInt();
-- 剩下的数量
	data['count'] = networkengine:parseInt();

	return data;
end

------------------typedef ItemInfoData ----------------------------------
function sendPushItemInfoData(data)
-- item server id
	networkengine:pushUInt64(data.itemSID);
-- Item Type
	networkengine:pushInt(data.itemType);
-- Bag Type
	networkengine:pushInt(data.bagType);
-- Item TableID
	networkengine:pushInt(data.tableID);
-- position
	networkengine:pushInt(data.position);
-- 叠加数量
	networkengine:pushInt(data.overlap);
-- 装备强化等级
	networkengine:pushInt(data.enhanceExp);
-- 装备强化花费了多少钱
	networkengine:pushUInt64(data.enhanceGold);
-- 物品的创建时间
	networkengine:pushUInt64(data.createTime);
end

function ParseItemInfoData()
	local tempArrayCount = 0;
	local data = {};

-- item server id
	data['itemSID'] = networkengine:parseUInt64();
-- Item Type
	data['itemType'] = networkengine:parseInt();
-- Bag Type
	data['bagType'] = networkengine:parseInt();
-- Item TableID
	data['tableID'] = networkengine:parseInt();
-- position
	data['position'] = networkengine:parseInt();
-- 叠加数量
	data['overlap'] = networkengine:parseInt();
-- 装备强化等级
	data['enhanceExp'] = networkengine:parseInt();
-- 装备强化花费了多少钱
	data['enhanceGold'] = networkengine:parseUInt64();
-- 物品的创建时间
	data['createTime'] = networkengine:parseUInt64();

	return data;
end

------------------typedef UnitInfo ----------------------------------
function sendPushUnitInfo(data)
-- UnitID
	networkengine:pushInt(data.id);
-- unit在战场上的index
	networkengine:pushInt(data.index);
-- unit是进攻方还是防守方
	networkengine:pushInt(data.force);
-- 士兵数量
	networkengine:pushInt(data.count);
-- 位置
	sendPushvector2i(data.position);
-- 船的属性
	sendPushShipAttrBase(data.shipAttr);
end

function ParseUnitInfo()
	local tempArrayCount = 0;
	local data = {};

-- UnitID
	data['id'] = networkengine:parseInt();
-- unit在战场上的index
	data['index'] = networkengine:parseInt();
-- unit是进攻方还是防守方
	data['force'] = networkengine:parseInt();
-- 士兵数量
	data['count'] = networkengine:parseInt();
-- 位置
	data['position'] = Parsevector2i();
-- 船的属性
	data['shipAttr'] = ParseShipAttrBase();

	return data;
end

------------------typedef CounterArray ----------------------------------
function sendPushCounterArray(data)
-- 计数数组
	local arrayLength = #data.counterArray;
	if arrayLength > 512 then arrayLength = 512 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.counterArray) do
		networkengine:pushChar(v);
	end

end

function ParseCounterArray()
	local tempArrayCount = 0;
	local data = {};

	data['counterArray'] = {};
-- 计数数组
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['counterArray'][i] = networkengine:parseChar();
	end

	return data;
end

------------------typedef MagicChoose ----------------------------------
function sendPushMagicChoose(data)
-- 魔法id
	networkengine:pushInt(data.id);
-- 星级
	networkengine:pushInt(data.star);
end

function ParseMagicChoose()
	local tempArrayCount = 0;
	local data = {};

-- 魔法id
	data['id'] = networkengine:parseInt();
-- 星级
	data['star'] = networkengine:parseInt();

	return data;
end

------------------typedef ActionBar ----------------------------------
function sendPushActionBar(data)
-- 快捷id
	local arrayLength = #data.shortcuts;
	if arrayLength > 16 then arrayLength = 16 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.shortcuts) do
		networkengine:pushInt(v);
	end

end

function ParseActionBar()
	local tempArrayCount = 0;
	local data = {};

	data['shortcuts'] = {};
-- 快捷id
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['shortcuts'][i] = networkengine:parseInt();
	end

	return data;
end

------------------typedef IntArray ----------------------------------
function sendPushIntArray(data)
-- 16int数组
end

function ParseIntArray()
	local tempArrayCount = 0;
	local data = {};

-- 16int数组

	return data;
end

------------------typedef IntArray32 ----------------------------------
function sendPushIntArray32(data)
-- 16int数组
	local arrayLength = #data.intarray32;
	if arrayLength > 32 then arrayLength = 32 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.intarray32) do
		networkengine:pushInt(v);
	end

end

function ParseIntArray32()
	local tempArrayCount = 0;
	local data = {};

	data['intarray32'] = {};
-- 16int数组
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['intarray32'][i] = networkengine:parseInt();
	end

	return data;
end

------------------typedef RewardList ----------------------------------
function sendPushRewardList(data)
-- 奖励列表
	local arrayLength = #data.rewardList;
	if arrayLength > 128 then arrayLength = 128 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardList) do
		sendPushReward(v);
	end

end

function ParseRewardList()
	local tempArrayCount = 0;
	local data = {};

	data['rewardList'] = {};
-- 奖励列表
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardList'][i] = ParseReward();
	end

	return data;
end

------------------typedef KingInfo ----------------------------------
function sendPushKingInfo(data)
-- 国王姓名
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- 国王图标
	networkengine:pushInt(data.icon);
-- 国王奇迹等级
	networkengine:pushInt(data.miracle);
-- 阵营
	networkengine:pushInt(data.force);
-- 等级
	networkengine:pushInt(data.level);
-- 智力
	networkengine:pushInt(data.intelligence);
-- 最大mp
	networkengine:pushInt(data.maxMP);
-- 魔法列表
	local arrayLength = #data.magics;
	if arrayLength > 16 then arrayLength = 16 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.magics) do
		sendPushMagicInfo(v);
	end

end

function ParseKingInfo()
	local tempArrayCount = 0;
	local data = {};

	data['magics'] = {};
-- 国王姓名
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 国王图标
	data['icon'] = networkengine:parseInt();
-- 国王奇迹等级
	data['miracle'] = networkengine:parseInt();
-- 阵营
	data['force'] = networkengine:parseInt();
-- 等级
	data['level'] = networkengine:parseInt();
-- 智力
	data['intelligence'] = networkengine:parseInt();
-- 最大mp
	data['maxMP'] = networkengine:parseInt();
-- 魔法列表
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['magics'][i] = ParseMagicInfo();
	end

	return data;
end

------------------typedef LadderPlayer ----------------------------------
function sendPushLadderPlayer(data)
-- 名字
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- 排名
	networkengine:pushInt(data.rank);
-- 头像
	networkengine:pushInt(data.icon);
-- 国王奇迹等级
	networkengine:pushInt(data.miracle);
-- 对应的玩家id
	networkengine:pushInt(data.playerID);
-- 对应的玩家战斗力
	networkengine:pushInt(data.playerPower);
-- 国王信息
	sendPushKingInfo(data.kingInfo);
-- 兵团信息列表
	local arrayLength = #data.units;
	if arrayLength > 21 then arrayLength = 21 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.units) do
		sendPushUnitInfo(v);
	end

-- 是否在防守战斗中
	networkengine:pushInt(data.status);
-- 源生货币
	local arrayLength = #data.primals;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.primals) do
		networkengine:pushInt(v);
	end

-- 掠夺保护时间
	networkengine:pushUInt64(data.plunderTime);
end

function ParseLadderPlayer()
	local tempArrayCount = 0;
	local data = {};

	data['units'] = {};
	data['primals'] = {};
-- 名字
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 排名
	data['rank'] = networkengine:parseInt();
-- 头像
	data['icon'] = networkengine:parseInt();
-- 国王奇迹等级
	data['miracle'] = networkengine:parseInt();
-- 对应的玩家id
	data['playerID'] = networkengine:parseInt();
-- 对应的玩家战斗力
	data['playerPower'] = networkengine:parseInt();
-- 国王信息
	data['kingInfo'] = ParseKingInfo();
-- 兵团信息列表
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['units'][i] = ParseUnitInfo();
	end
-- 是否在防守战斗中
	data['status'] = networkengine:parseInt();
-- 源生货币
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['primals'][i] = networkengine:parseInt();
	end
-- 掠夺保护时间
	data['plunderTime'] = networkengine:parseUInt64();

	return data;
end

------------------typedef Revenge ----------------------------------
function sendPushRevenge(data)
-- 数据库ID
	networkengine:pushInt(data.dbid);
-- 是否异步
	networkengine:pushBool(data.async);
-- 仇家id
	networkengine:pushInt(data.enemyID);
-- 仇家名
	networkengine:pushInt(string.len(data.enemyName));
	networkengine:pushString(data.enemyName, string.len(data.enemyName));
-- 仇家等级
	networkengine:pushInt(data.enemyLevel);
-- 仇家战力
	networkengine:pushInt(data.enemyPwoer);
-- 仇家图标
	networkengine:pushInt(data.enemyIcon);
-- 被抢的资源类型
	networkengine:pushInt(data.primalType);
-- 抢劫发生的时间
	networkengine:pushUInt64(data.time);
-- 是否新事件
	networkengine:pushBool(data.isNew);
end

function ParseRevenge()
	local tempArrayCount = 0;
	local data = {};

-- 数据库ID
	data['dbid'] = networkengine:parseInt();
-- 是否异步
	data['async'] = networkengine:parseBool();
-- 仇家id
	data['enemyID'] = networkengine:parseInt();
-- 仇家名
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['enemyName'] = networkengine:parseString(strlength);
else
		data['enemyName'] = "";
end
-- 仇家等级
	data['enemyLevel'] = networkengine:parseInt();
-- 仇家战力
	data['enemyPwoer'] = networkengine:parseInt();
-- 仇家图标
	data['enemyIcon'] = networkengine:parseInt();
-- 被抢的资源类型
	data['primalType'] = networkengine:parseInt();
-- 抢劫发生的时间
	data['time'] = networkengine:parseUInt64();
-- 是否新事件
	data['isNew'] = networkengine:parseBool();

	return data;
end

------------------typedef TopInfo ----------------------------------
function sendPushTopInfo(data)
-- 玩家ID
	networkengine:pushInt(data.playerID);
-- 玩家名称
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- 得分
	networkengine:pushInt(data.score);
-- 玩家等级
	networkengine:pushInt(data.level);
-- 玩家图标
	networkengine:pushInt(data.iconID);
-- 玩家奇迹等级
	networkengine:pushInt(data.miracle);
-- 平均攻击等级
	networkengine:pushInt(data.attack);
-- 平均暴击等级
	networkengine:pushInt(data.critical);
-- 军团配置
	networkengine:pushInt(string.len(data.unitPlan));
	networkengine:pushString(data.unitPlan, string.len(data.unitPlan));
-- 魔法配置
	networkengine:pushInt(string.len(data.magicPlan));
	networkengine:pushString(data.magicPlan, string.len(data.magicPlan));
-- 录像ID
	networkengine:pushInt(data.replayID);
end

function ParseTopInfo()
	local tempArrayCount = 0;
	local data = {};

-- 玩家ID
	data['playerID'] = networkengine:parseInt();
-- 玩家名称
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 得分
	data['score'] = networkengine:parseInt();
-- 玩家等级
	data['level'] = networkengine:parseInt();
-- 玩家图标
	data['iconID'] = networkengine:parseInt();
-- 玩家奇迹等级
	data['miracle'] = networkengine:parseInt();
-- 平均攻击等级
	data['attack'] = networkengine:parseInt();
-- 平均暴击等级
	data['critical'] = networkengine:parseInt();
-- 军团配置
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['unitPlan'] = networkengine:parseString(strlength);
else
		data['unitPlan'] = "";
end
-- 魔法配置
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['magicPlan'] = networkengine:parseString(strlength);
else
		data['magicPlan'] = "";
end
-- 录像ID
	data['replayID'] = networkengine:parseInt();

	return data;
end

------------------typedef LadderPlayerSummary ----------------------------------
function sendPushLadderPlayerSummary(data)
-- 玩家id，如果是robot，则为-1
	networkengine:pushInt(data.playerID);
-- 排名
	networkengine:pushInt(data.rank);
-- 等级
	networkengine:pushInt(data.level);
-- 名字
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- 头像
	networkengine:pushInt(data.icon);
-- 奇迹等级
	networkengine:pushInt(data.miracle);
end

function ParseLadderPlayerSummary()
	local tempArrayCount = 0;
	local data = {};

-- 玩家id，如果是robot，则为-1
	data['playerID'] = networkengine:parseInt();
-- 排名
	data['rank'] = networkengine:parseInt();
-- 等级
	data['level'] = networkengine:parseInt();
-- 名字
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 头像
	data['icon'] = networkengine:parseInt();
-- 奇迹等级
	data['miracle'] = networkengine:parseInt();

	return data;
end

------------------typedef TopSummary ----------------------------------
function sendPushTopSummary(data)
-- 排名
	networkengine:pushInt(data.rank);
-- 名字
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- 图标
	networkengine:pushInt(data.iconID);
-- 玩家奇迹等级
	networkengine:pushInt(data.miracle);
-- 等级
	networkengine:pushInt(data.level);
-- 得分
	networkengine:pushInt(data.score);
-- 录像ID
	networkengine:pushInt(data.replayID);
end

function ParseTopSummary()
	local tempArrayCount = 0;
	local data = {};

-- 排名
	data['rank'] = networkengine:parseInt();
-- 名字
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 图标
	data['iconID'] = networkengine:parseInt();
-- 玩家奇迹等级
	data['miracle'] = networkengine:parseInt();
-- 等级
	data['level'] = networkengine:parseInt();
-- 得分
	data['score'] = networkengine:parseInt();
-- 录像ID
	data['replayID'] = networkengine:parseInt();

	return data;
end

------------------typedef ReplayInfo ----------------------------------
function sendPushReplayInfo(data)
-- 录像id
	networkengine:pushInt(data.id);
-- 玩家id
	networkengine:pushInt(data.playerID);
-- 玩家等级
	networkengine:pushInt(data.playerLevel);
-- 玩家名字
	networkengine:pushInt(string.len(data.playerName));
	networkengine:pushString(data.playerName, string.len(data.playerName));
-- 玩家头像
	networkengine:pushInt(data.playerIcon);
-- 胜利失败
	networkengine:pushBool(data.win);
-- 排名变化
	networkengine:pushInt(data.rankChanged);
-- 战斗时间
	networkengine:pushUInt64(data.battleTime);
-- 自己是否是挑战者
	networkengine:pushBool(data.isChallenger);
end

function ParseReplayInfo()
	local tempArrayCount = 0;
	local data = {};

-- 录像id
	data['id'] = networkengine:parseInt();
-- 玩家id
	data['playerID'] = networkengine:parseInt();
-- 玩家等级
	data['playerLevel'] = networkengine:parseInt();
-- 玩家名字
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['playerName'] = networkengine:parseString(strlength);
else
		data['playerName'] = "";
end
-- 玩家头像
	data['playerIcon'] = networkengine:parseInt();
-- 胜利失败
	data['win'] = networkengine:parseBool();
-- 排名变化
	data['rankChanged'] = networkengine:parseInt();
-- 战斗时间
	data['battleTime'] = networkengine:parseUInt64();
-- 自己是否是挑战者
	data['isChallenger'] = networkengine:parseBool();

	return data;
end

------------------typedef SellItemInfo ----------------------------------
function sendPushSellItemInfo(data)
-- 位置信息
	networkengine:pushInt(data.position);
-- 物品数量
	networkengine:pushInt(data.itemCount);
end

function ParseSellItemInfo()
	local tempArrayCount = 0;
	local data = {};

-- 位置信息
	data['position'] = networkengine:parseInt();
-- 物品数量
	data['itemCount'] = networkengine:parseInt();

	return data;
end

------------------typedef ShakeRankInfo ----------------------------------
function sendPushShakeRankInfo(data)
-- 玩家id
	networkengine:pushInt(data.id);
-- 玩家icon
	networkengine:pushInt(data.icon);
-- 摇奖的钱数
	networkengine:pushInt64(data.money);
-- 玩家名字
	networkengine:pushInt(string.len(data.playerName));
	networkengine:pushString(data.playerName, string.len(data.playerName));
end

function ParseShakeRankInfo()
	local tempArrayCount = 0;
	local data = {};

-- 玩家id
	data['id'] = networkengine:parseInt();
-- 玩家icon
	data['icon'] = networkengine:parseInt();
-- 摇奖的钱数
	data['money'] = networkengine:parseInt64();
-- 玩家名字
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['playerName'] = networkengine:parseString(strlength);
else
		data['playerName'] = "";
end

	return data;
end

------------------typedef GuildInfo ----------------------------------
function sendPushGuildInfo(data)
-- 公会id
	networkengine:pushInt(data.id);
-- 公会名称
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- 会长名称
	networkengine:pushInt(string.len(data.creater));
	networkengine:pushString(data.creater, string.len(data.creater));
-- 玩家等级和
	networkengine:pushInt(data.allLevel);
-- 当前人数
	networkengine:pushInt(data.count);
end

function ParseGuildInfo()
	local tempArrayCount = 0;
	local data = {};

-- 公会id
	data['id'] = networkengine:parseInt();
-- 公会名称
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 会长名称
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['creater'] = networkengine:parseString(strlength);
else
		data['creater'] = "";
end
-- 玩家等级和
	data['allLevel'] = networkengine:parseInt();
-- 当前人数
	data['count'] = networkengine:parseInt();

	return data;
end

------------------typedef GuildMemberInfo ----------------------------------
function sendPushGuildMemberInfo(data)
-- 玩家的id
	networkengine:pushInt(data.id);
-- 玩家昵称
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- 头像id
	networkengine:pushInt(data.head);
-- 玩家等级
	networkengine:pushInt(data.level);
-- vip level
	networkengine:pushInt(data.vip);
-- 权限
	networkengine:pushInt(data.property);
-- 最后一次离线时间
	networkengine:pushUInt64(data.lastOfflineTIme);
-- 成员入会时间
	networkengine:pushUInt64(data.enterTime);
-- 战斗得分
	networkengine:pushInt(data.warScore);
end

function ParseGuildMemberInfo()
	local tempArrayCount = 0;
	local data = {};

-- 玩家的id
	data['id'] = networkengine:parseInt();
-- 玩家昵称
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 头像id
	data['head'] = networkengine:parseInt();
-- 玩家等级
	data['level'] = networkengine:parseInt();
-- vip level
	data['vip'] = networkengine:parseInt();
-- 权限
	data['property'] = networkengine:parseInt();
-- 最后一次离线时间
	data['lastOfflineTIme'] = networkengine:parseUInt64();
-- 成员入会时间
	data['enterTime'] = networkengine:parseUInt64();
-- 战斗得分
	data['warScore'] = networkengine:parseInt();

	return data;
end

------------------typedef GuildApplicantInfo ----------------------------------
function sendPushGuildApplicantInfo(data)
-- 申请玩家id
	networkengine:pushInt(data.id);
-- 玩家昵称
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- 头像id
	networkengine:pushInt(data.head);
-- 玩家vip
	networkengine:pushInt(data.vip);
-- 玩家等级
	networkengine:pushInt(data.level);
end

function ParseGuildApplicantInfo()
	local tempArrayCount = 0;
	local data = {};

-- 申请玩家id
	data['id'] = networkengine:parseInt();
-- 玩家昵称
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 头像id
	data['head'] = networkengine:parseInt();
-- 玩家vip
	data['vip'] = networkengine:parseInt();
-- 玩家等级
	data['level'] = networkengine:parseInt();

	return data;
end

------------------typedef GuildWarPlanInfo ----------------------------------
function sendPushGuildWarPlanInfo(data)
-- 当前的状态,可攻击,已经易主...
	networkengine:pushInt(data.status);
-- 公会id
	networkengine:pushInt(data.id);
-- 公会名称
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- 鼓舞次数
	networkengine:pushInt(data.inspireCount);
end

function ParseGuildWarPlanInfo()
	local tempArrayCount = 0;
	local data = {};

-- 当前的状态,可攻击,已经易主...
	data['status'] = networkengine:parseInt();
-- 公会id
	data['id'] = networkengine:parseInt();
-- 公会名称
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 鼓舞次数
	data['inspireCount'] = networkengine:parseInt();

	return data;
end

------------------typedef GuildWarRankInfo ----------------------------------
function sendPushGuildWarRankInfo(data)
-- 公会id
	networkengine:pushInt(data.id);
-- 公会名称
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- 会长头像
	networkengine:pushInt(data.createrHead);
-- 当前积分
	networkengine:pushInt(data.warScore);
end

function ParseGuildWarRankInfo()
	local tempArrayCount = 0;
	local data = {};

-- 公会id
	data['id'] = networkengine:parseInt();
-- 公会名称
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 会长头像
	data['createrHead'] = networkengine:parseInt();
-- 当前积分
	data['warScore'] = networkengine:parseInt();

	return data;
end

------------------typedef ShipAttrBase ----------------------------------
function sendPushShipAttrBase(data)
-- 攻击等级
	networkengine:pushInt(data.attack);
-- 防御等级
	networkengine:pushInt(data.defence);
-- 暴击等级
	networkengine:pushInt(data.critical);
-- 韧性等级
	networkengine:pushInt(data.resilience);
end

function ParseShipAttrBase()
	local tempArrayCount = 0;
	local data = {};

-- 攻击等级
	data['attack'] = networkengine:parseInt();
-- 防御等级
	data['defence'] = networkengine:parseInt();
-- 暴击等级
	data['critical'] = networkengine:parseInt();
-- 韧性等级
	data['resilience'] = networkengine:parseInt();

	return data;
end

------------------typedef ShipAttrRatio ----------------------------------
function sendPushShipAttrRatio(data)
-- 攻击等级
	networkengine:pushInt(data.attack);
-- 防御等级
	networkengine:pushInt(data.defence);
-- 暴击等级
	networkengine:pushInt(data.critical);
-- 韧性等级
	networkengine:pushInt(data.resilience);
end

function ParseShipAttrRatio()
	local tempArrayCount = 0;
	local data = {};

-- 攻击等级
	data['attack'] = networkengine:parseInt();
-- 防御等级
	data['defence'] = networkengine:parseInt();
-- 暴击等级
	data['critical'] = networkengine:parseInt();
-- 韧性等级
	data['resilience'] = networkengine:parseInt();

	return data;
end

------------------typedef MagicAchievement ----------------------------------
function sendPushMagicAchievement(data)
-- 系统公告-公告条件7-任意魔法达到4星
	networkengine:pushInt(data.condition);
-- 系统公告-公告内容7-任意魔法达到4星
	networkengine:pushInt(string.len(data.notify));
	networkengine:pushString(data.notify, string.len(data.notify));
end

function ParseMagicAchievement()
	local tempArrayCount = 0;
	local data = {};

-- 系统公告-公告条件7-任意魔法达到4星
	data['condition'] = networkengine:parseInt();
-- 系统公告-公告内容7-任意魔法达到4星
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['notify'] = networkengine:parseString(strlength);
else
		data['notify'] = "";
end

	return data;
end

------------------typedef CardAchievement ----------------------------------
function sendPushCardAchievement(data)
-- 系统公告-公告条件5-任意军团达到4星
	networkengine:pushInt(data.condition);
-- 系统公告-公告内容5-任意军团达到4星
	networkengine:pushInt(string.len(data.notify));
	networkengine:pushString(data.notify, string.len(data.notify));
end

function ParseCardAchievement()
	local tempArrayCount = 0;
	local data = {};

-- 系统公告-公告条件5-任意军团达到4星
	data['condition'] = networkengine:parseInt();
-- 系统公告-公告内容5-任意军团达到4星
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['notify'] = networkengine:parseString(strlength);
else
		data['notify'] = "";
end

	return data;
end

------------------typedef PvpOfflineCombo ----------------------------------
function sendPushPvpOfflineCombo(data)
-- 系统公告-公告条件1-天梯连胜8场
	networkengine:pushInt(data.condition);
-- 系统公告-公告内容1-天梯连胜8场
	networkengine:pushInt(string.len(data.notify));
	networkengine:pushString(data.notify, string.len(data.notify));
end

function ParsePvpOfflineCombo()
	local tempArrayCount = 0;
	local data = {};

-- 系统公告-公告条件1-天梯连胜8场
	data['condition'] = networkengine:parseInt();
-- 系统公告-公告内容1-天梯连胜8场
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['notify'] = networkengine:parseString(strlength);
else
		data['notify'] = "";
end

	return data;
end

------------------typedef ChapterRewardList ----------------------------------
function sendPushChapterRewardList(data)
-- 普通模式完美奖励类型
	local arrayLength = #data.type;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.type) do
		networkengine:pushInt(v);
	end

-- 普通模式完美奖励ID
	local arrayLength = #data.id;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.id) do
		networkengine:pushInt(v);
	end

-- 普通模式完美奖励数量
	local arrayLength = #data.count;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.count) do
		networkengine:pushInt(v);
	end

end

function ParseChapterRewardList()
	local tempArrayCount = 0;
	local data = {};

	data['type'] = {};
	data['id'] = {};
	data['count'] = {};
-- 普通模式完美奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['type'][i] = networkengine:parseInt();
	end
-- 普通模式完美奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['id'][i] = networkengine:parseInt();
	end
-- 普通模式完美奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['count'][i] = networkengine:parseInt();
	end

	return data;
end

------------------typedef InitialMeditation ----------------------------------
function sendPushInitialMeditation(data)
-- 抽卡（魔法）-第一次抽卡魔法随机范围
	local arrayLength = #data.randomRange;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.randomRange) do
		networkengine:pushInt(v);
	end

-- 抽卡（魔法）-第一次抽卡获得魔法的星级
	networkengine:pushInt(data.starLevel);
end

function ParseInitialMeditation()
	local tempArrayCount = 0;
	local data = {};

	data['randomRange'] = {};
-- 抽卡（魔法）-第一次抽卡魔法随机范围
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['randomRange'][i] = networkengine:parseInt();
	end
-- 抽卡（魔法）-第一次抽卡获得魔法的星级
	data['starLevel'] = networkengine:parseInt();

	return data;
end

------------------typedef RowBuild ----------------------------------
function sendPushRowBuild(data)
-- 建筑等级
	networkengine:pushInt(data.id);
-- 升级消耗木材
	networkengine:pushInt(data.lumberCost);
-- 消耗时间
	networkengine:pushInt(data.timeCost);
-- 提供锤子数
	networkengine:pushInt(data.hammer);
-- 建设时需要主基地等级
	networkengine:pushInt(data.levelLimit);
-- 升下一级所需英雄等级
	networkengine:pushInt(data.heroLevel);
-- 升下一级需要锤子数
	networkengine:pushInt(data.hammerRequire);
end

function ParseRowBuild()
	local tempArrayCount = 0;
	local data = {};

-- 建筑等级
	data['id'] = networkengine:parseInt();
-- 升级消耗木材
	data['lumberCost'] = networkengine:parseInt();
-- 消耗时间
	data['timeCost'] = networkengine:parseInt();
-- 提供锤子数
	data['hammer'] = networkengine:parseInt();
-- 建设时需要主基地等级
	data['levelLimit'] = networkengine:parseInt();
-- 升下一级所需英雄等级
	data['heroLevel'] = networkengine:parseInt();
-- 升下一级需要锤子数
	data['hammerRequire'] = networkengine:parseInt();

	return data;
end

------------------typedef InitialDraw ----------------------------------
function sendPushInitialDraw(data)
-- 抽卡（军团）-第一次抽卡基本体ID随机范围
	local arrayLength = #data.randomRange;
	if arrayLength > 16 then arrayLength = 16 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.randomRange) do
		networkengine:pushInt(v);
	end

-- 抽卡（军团）-第一次抽卡获得军团的星级
	networkengine:pushInt(data.starLevel);
end

function ParseInitialDraw()
	local tempArrayCount = 0;
	local data = {};

	data['randomRange'] = {};
-- 抽卡（军团）-第一次抽卡基本体ID随机范围
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['randomRange'][i] = networkengine:parseInt();
	end
-- 抽卡（军团）-第一次抽卡获得军团的星级
	data['starLevel'] = networkengine:parseInt();

	return data;
end

------------------typedef Adventure ----------------------------------
function sendPushAdventure(data)
-- 推图-普通模式消耗体力
	networkengine:pushInt(data.cost);
-- 推图-普通模式失败消耗体力
	networkengine:pushInt(data.failCost);
-- 推图-普通模式胜利获得经验
	networkengine:pushInt(data.exp);
-- 推图-普通模式失败获得经验
	networkengine:pushInt(data.failExp);
end

function ParseAdventure()
	local tempArrayCount = 0;
	local data = {};

-- 推图-普通模式消耗体力
	data['cost'] = networkengine:parseInt();
-- 推图-普通模式失败消耗体力
	data['failCost'] = networkengine:parseInt();
-- 推图-普通模式胜利获得经验
	data['exp'] = networkengine:parseInt();
-- 推图-普通模式失败获得经验
	data['failExp'] = networkengine:parseInt();

	return data;
end

------------------typedef Limit ----------------------------------
function sendPushLimit(data)
-- 普通模式关卡ID
	networkengine:pushInt(data.stageID);
-- 普通模式等级限制
	networkengine:pushInt(data.level);
-- 普通模式次数限制
	networkengine:pushInt(data.count);
end

function ParseLimit()
	local tempArrayCount = 0;
	local data = {};

-- 普通模式关卡ID
	data['stageID'] = networkengine:parseInt();
-- 普通模式等级限制
	data['level'] = networkengine:parseInt();
-- 普通模式次数限制
	data['count'] = networkengine:parseInt();

	return data;
end

------------------typedef RowGuildWarPer ----------------------------------
function sendPushRowGuildWarPer(data)
-- id
	networkengine:pushInt(data.id);
-- 增强系数
	networkengine:pushInt(data.personalRat);
end

function ParseRowGuildWarPer()
	local tempArrayCount = 0;
	local data = {};

-- id
	data['id'] = networkengine:parseInt();
-- 增强系数
	data['personalRat'] = networkengine:parseInt();

	return data;
end

------------------typedef RowGuildWarRank ----------------------------------
function sendPushRowGuildWarRank(data)
-- id
	networkengine:pushInt(data.id);
-- 排名
	networkengine:pushInt(data.rank);
-- 必得奖励类型
	local arrayLength = #data.rewardType;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardType) do
		networkengine:pushInt(v);
	end

-- 必得奖励ID
	local arrayLength = #data.rewardID;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardID) do
		networkengine:pushInt(v);
	end

-- 必得奖励数量
	local arrayLength = #data.rewardCount;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardCount) do
		networkengine:pushInt(v);
	end

end

function ParseRowGuildWarRank()
	local tempArrayCount = 0;
	local data = {};

	data['rewardType'] = {};
	data['rewardID'] = {};
	data['rewardCount'] = {};
-- id
	data['id'] = networkengine:parseInt();
-- 排名
	data['rank'] = networkengine:parseInt();
-- 必得奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardType'][i] = networkengine:parseInt();
	end
-- 必得奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardID'][i] = networkengine:parseInt();
	end
-- 必得奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardCount'][i] = networkengine:parseInt();
	end

	return data;
end

------------------typedef RowGuildWar ----------------------------------
function sendPushRowGuildWar(data)
-- 据点ID
	networkengine:pushInt(data.id);
-- 据点名称
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- 首次匹配阵容
	networkengine:pushInt(data.gwRankMatch);
-- 增强系数
	local arrayLength = #data.gwDefRat;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.gwDefRat) do
		networkengine:pushFloat(v);
	end

-- 积分给予
	local arrayLength = #data.gwScore;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.gwScore) do
		networkengine:pushInt(v);
	end

-- 据点奖励类型
	local arrayLength = #data.rewardType;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardType) do
		networkengine:pushInt(v);
	end

-- 据点奖励ID
	local arrayLength = #data.rewardID;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardID) do
		networkengine:pushInt(v);
	end

-- 据点奖励数量
	local arrayLength = #data.rewardCount;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardCount) do
		networkengine:pushInt(v);
	end

-- 默认据点阵型数量
	networkengine:pushInt(data.defaultNum);
end

function ParseRowGuildWar()
	local tempArrayCount = 0;
	local data = {};

	data['gwDefRat'] = {};
	data['gwScore'] = {};
	data['rewardType'] = {};
	data['rewardID'] = {};
	data['rewardCount'] = {};
-- 据点ID
	data['id'] = networkengine:parseInt();
-- 据点名称
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 首次匹配阵容
	data['gwRankMatch'] = networkengine:parseInt();
-- 增强系数
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['gwDefRat'][i] = networkengine:parseFloat();
	end
-- 积分给予
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['gwScore'][i] = networkengine:parseInt();
	end
-- 据点奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardType'][i] = networkengine:parseInt();
	end
-- 据点奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardID'][i] = networkengine:parseInt();
	end
-- 据点奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardCount'][i] = networkengine:parseInt();
	end
-- 默认据点阵型数量
	data['defaultNum'] = networkengine:parseInt();

	return data;
end

------------------typedef RowRedEnvelope ----------------------------------
function sendPushRowRedEnvelope(data)
-- id
	networkengine:pushInt(data.id);
-- 开启时间
	networkengine:pushInt(string.len(data.openTime));
	networkengine:pushString(data.openTime, string.len(data.openTime));
-- 关闭时间
	networkengine:pushInt(string.len(data.closeTime));
	networkengine:pushString(data.closeTime, string.len(data.closeTime));
-- 可摇奖次数
	networkengine:pushInt(data.lotteryNum);
-- 时段分享可增加次数
	networkengine:pushInt(data.lotteryAddNum);
-- 奖金数量
	local arrayLength = #data.moneyNum;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.moneyNum) do
		networkengine:pushFloat(v);
	end

-- 抽奖获得金额
	local arrayLength = #data.giftTypeId;
	if arrayLength > 32 then arrayLength = 32 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.giftTypeId) do
		networkengine:pushFloat(v);
	end

-- 抽奖类型对应概率
	local arrayLength = #data.giftTypeChance;
	if arrayLength > 32 then arrayLength = 32 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.giftTypeChance) do
		networkengine:pushInt(v);
	end

end

function ParseRowRedEnvelope()
	local tempArrayCount = 0;
	local data = {};

	data['moneyNum'] = {};
	data['giftTypeId'] = {};
	data['giftTypeChance'] = {};
-- id
	data['id'] = networkengine:parseInt();
-- 开启时间
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['openTime'] = networkengine:parseString(strlength);
else
		data['openTime'] = "";
end
-- 关闭时间
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['closeTime'] = networkengine:parseString(strlength);
else
		data['closeTime'] = "";
end
-- 可摇奖次数
	data['lotteryNum'] = networkengine:parseInt();
-- 时段分享可增加次数
	data['lotteryAddNum'] = networkengine:parseInt();
-- 奖金数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['moneyNum'][i] = networkengine:parseFloat();
	end
-- 抽奖获得金额
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['giftTypeId'][i] = networkengine:parseFloat();
	end
-- 抽奖类型对应概率
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['giftTypeChance'][i] = networkengine:parseInt();
	end

	return data;
end

------------------typedef RowMiracle ----------------------------------
function sendPushRowMiracle(data)
-- 奇迹等级
	networkengine:pushInt(data.id);
-- 升到下级所需军团星级
	networkengine:pushInt(data.starCount);
-- 升到下级所需金币数量
	networkengine:pushInt(data.goldCost);
-- 升到下级所需木材数量
	networkengine:pushInt(data.lumberCost);
-- ShipAttrRatio
	local arrayLength = #data.shipAttrRatio;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.shipAttrRatio) do
		sendPushShipAttrRatio(v);
	end

-- 人口
	networkengine:pushInt(data.soldier);
end

function ParseRowMiracle()
	local tempArrayCount = 0;
	local data = {};

	data['shipAttrRatio'] = {};
-- 奇迹等级
	data['id'] = networkengine:parseInt();
-- 升到下级所需军团星级
	data['starCount'] = networkengine:parseInt();
-- 升到下级所需金币数量
	data['goldCost'] = networkengine:parseInt();
-- 升到下级所需木材数量
	data['lumberCost'] = networkengine:parseInt();
-- ShipAttrRatio
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['shipAttrRatio'][i] = ParseShipAttrRatio();
	end
-- 人口
	data['soldier'] = networkengine:parseInt();

	return data;
end

------------------typedef RowContinuousSignIn ----------------------------------
function sendPushRowContinuousSignIn(data)
-- 连续签到
	networkengine:pushInt(data.id);
-- 连续签到奖励类型
	local arrayLength = #data.rewardType;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardType) do
		networkengine:pushInt(v);
	end

-- 连续签到奖励ID
	local arrayLength = #data.rewardID;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardID) do
		networkengine:pushInt(v);
	end

-- 连续签到奖励数量
	local arrayLength = #data.rewardCount;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardCount) do
		networkengine:pushInt(v);
	end

end

function ParseRowContinuousSignIn()
	local tempArrayCount = 0;
	local data = {};

	data['rewardType'] = {};
	data['rewardID'] = {};
	data['rewardCount'] = {};
-- 连续签到
	data['id'] = networkengine:parseInt();
-- 连续签到奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardType'][i] = networkengine:parseInt();
	end
-- 连续签到奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardID'][i] = networkengine:parseInt();
	end
-- 连续签到奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardCount'][i] = networkengine:parseInt();
	end

	return data;
end

------------------typedef RowFirstSignIn ----------------------------------
function sendPushRowFirstSignIn(data)
-- 首次签到
	networkengine:pushInt(data.id);
-- 首次签到奖励类型
	local arrayLength = #data.rewardType;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardType) do
		networkengine:pushInt(v);
	end

-- 首次签到奖励ID
	local arrayLength = #data.rewardID;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardID) do
		networkengine:pushInt(v);
	end

-- 首次签到奖励数量
	local arrayLength = #data.rewardCount;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardCount) do
		networkengine:pushInt(v);
	end

end

function ParseRowFirstSignIn()
	local tempArrayCount = 0;
	local data = {};

	data['rewardType'] = {};
	data['rewardID'] = {};
	data['rewardCount'] = {};
-- 首次签到
	data['id'] = networkengine:parseInt();
-- 首次签到奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardType'][i] = networkengine:parseInt();
	end
-- 首次签到奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardID'][i] = networkengine:parseInt();
	end
-- 首次签到奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardCount'][i] = networkengine:parseInt();
	end

	return data;
end

------------------typedef RowSignIn ----------------------------------
function sendPushRowSignIn(data)
-- 签到次数
	networkengine:pushInt(data.id);
-- 签到奖励类型
	local arrayLength = #data.rewardType;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardType) do
		networkengine:pushInt(v);
	end

-- 签到奖励ID
	local arrayLength = #data.rewardID;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardID) do
		networkengine:pushInt(v);
	end

-- 签到奖励数量
	local arrayLength = #data.rewardCount;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardCount) do
		networkengine:pushInt(v);
	end

end

function ParseRowSignIn()
	local tempArrayCount = 0;
	local data = {};

	data['rewardType'] = {};
	data['rewardID'] = {};
	data['rewardCount'] = {};
-- 签到次数
	data['id'] = networkengine:parseInt();
-- 签到奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardType'][i] = networkengine:parseInt();
	end
-- 签到奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardID'][i] = networkengine:parseInt();
	end
-- 签到奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardCount'][i] = networkengine:parseInt();
	end

	return data;
end

------------------typedef RowGift ----------------------------------
function sendPushRowGift(data)
-- 编号
	networkengine:pushInt(data.id);
-- 类型
	networkengine:pushInt(data.groupID);
-- 必得奖励类型
	local arrayLength = #data.rewardType;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardType) do
		networkengine:pushInt(v);
	end

-- 必得奖励ID
	local arrayLength = #data.rewardID;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardID) do
		networkengine:pushInt(v);
	end

-- 必得奖励数量
	local arrayLength = #data.rewardCount;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardCount) do
		networkengine:pushInt(v);
	end

-- 可重复领取
	networkengine:pushBool(data.isRepeatable);
end

function ParseRowGift()
	local tempArrayCount = 0;
	local data = {};

	data['rewardType'] = {};
	data['rewardID'] = {};
	data['rewardCount'] = {};
-- 编号
	data['id'] = networkengine:parseInt();
-- 类型
	data['groupID'] = networkengine:parseInt();
-- 必得奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardType'][i] = networkengine:parseInt();
	end
-- 必得奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardID'][i] = networkengine:parseInt();
	end
-- 必得奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardCount'][i] = networkengine:parseInt();
	end
-- 可重复领取
	data['isRepeatable'] = networkengine:parseBool();

	return data;
end

------------------typedef RowPlunder ----------------------------------
function sendPushRowPlunder(data)
-- 编号
	networkengine:pushInt(data.id);
-- 高难度关卡
	networkengine:pushInt(data.hard);
-- 中难度关卡
	networkengine:pushInt(data.medium);
-- 低难度关卡
	networkengine:pushInt(data.easy);
end

function ParseRowPlunder()
	local tempArrayCount = 0;
	local data = {};

-- 编号
	data['id'] = networkengine:parseInt();
-- 高难度关卡
	data['hard'] = networkengine:parseInt();
-- 中难度关卡
	data['medium'] = networkengine:parseInt();
-- 低难度关卡
	data['easy'] = networkengine:parseInt();

	return data;
end

------------------typedef RowCrusadeLevel ----------------------------------
function sendPushRowCrusadeLevel(data)
-- 远征关卡ID
	networkengine:pushInt(data.id);
-- 远征-匹配阵容
	networkengine:pushInt(data.crusadeRankMatch);
-- 远征-关卡列表
	networkengine:pushInt(data.crusadeStage);
-- 远征-匹配星级
	networkengine:pushInt(data.crusadeStarMatch);
end

function ParseRowCrusadeLevel()
	local tempArrayCount = 0;
	local data = {};

-- 远征关卡ID
	data['id'] = networkengine:parseInt();
-- 远征-匹配阵容
	data['crusadeRankMatch'] = networkengine:parseInt();
-- 远征-关卡列表
	data['crusadeStage'] = networkengine:parseInt();
-- 远征-匹配星级
	data['crusadeStarMatch'] = networkengine:parseInt();

	return data;
end

------------------typedef RowChallengeStage ----------------------------------
function sendPushRowChallengeStage(data)
-- 副本挑战关卡ID
	networkengine:pushInt(data.id);
-- 副本挑战-普通副本
	networkengine:pushInt(data.normal);
-- 副本挑战-噩梦副本
	networkengine:pushInt(data.elite);
-- 副本挑战-地狱副本
	networkengine:pushInt(data.hall);
-- 副本挑战-等级限制
	networkengine:pushInt(data.levelLimit);
end

function ParseRowChallengeStage()
	local tempArrayCount = 0;
	local data = {};

-- 副本挑战关卡ID
	data['id'] = networkengine:parseInt();
-- 副本挑战-普通副本
	data['normal'] = networkengine:parseInt();
-- 副本挑战-噩梦副本
	data['elite'] = networkengine:parseInt();
-- 副本挑战-地狱副本
	data['hall'] = networkengine:parseInt();
-- 副本挑战-等级限制
	data['levelLimit'] = networkengine:parseInt();

	return data;
end

------------------typedef RowIdolStatue ----------------------------------
function sendPushRowIdolStatue(data)
-- 神像等级
	networkengine:pushInt(data.id);
-- 升到下级所需材料数
	networkengine:pushInt(data.retuireItemCount);
-- 升到下级所需金币数
	networkengine:pushInt(data.goldCost);
-- 升到下级所需木材数
	networkengine:pushInt(data.lumberCost);
-- 人口
	networkengine:pushInt(data.soldier);
-- ShipAttrBase
	local arrayLength = #data.shipAttrBase;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.shipAttrBase) do
		sendPushShipAttrBase(v);
	end

end

function ParseRowIdolStatue()
	local tempArrayCount = 0;
	local data = {};

	data['shipAttrBase'] = {};
-- 神像等级
	data['id'] = networkengine:parseInt();
-- 升到下级所需材料数
	data['retuireItemCount'] = networkengine:parseInt();
-- 升到下级所需金币数
	data['goldCost'] = networkengine:parseInt();
-- 升到下级所需木材数
	data['lumberCost'] = networkengine:parseInt();
-- 人口
	data['soldier'] = networkengine:parseInt();
-- ShipAttrBase
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['shipAttrBase'][i] = ParseShipAttrBase();
	end

	return data;
end

------------------typedef RowCrusadeReward ----------------------------------
function sendPushRowCrusadeReward(data)
-- id
	networkengine:pushInt(data.id);
-- 战斗力
	networkengine:pushInt(data.power);
-- 奖励系数
	networkengine:pushFloat(data.ratio);
end

function ParseRowCrusadeReward()
	local tempArrayCount = 0;
	local data = {};

-- id
	data['id'] = networkengine:parseInt();
-- 战斗力
	data['power'] = networkengine:parseInt();
-- 奖励系数
	data['ratio'] = networkengine:parseFloat();

	return data;
end

------------------typedef RowSysNotify ----------------------------------
function sendPushRowSysNotify(data)
-- 无意义
	networkengine:pushInt(data.id);
-- PvpOfflineCombo
	local arrayLength = #data.pvpOfflineCombo;
	if arrayLength > 3 then arrayLength = 3 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.pvpOfflineCombo) do
		sendPushPvpOfflineCombo(v);
	end

-- 系统公告-公告条件4-竞技场胜利场次达到5
	networkengine:pushInt(data.pvpOnlineComboCondition);
-- 系统公告-公告内容4-竞技场胜利场次达到5
	networkengine:pushInt(string.len(data.pvpOnlineComboNotify));
	networkengine:pushString(data.pvpOnlineComboNotify, string.len(data.pvpOnlineComboNotify));
-- CardAchievement
	local arrayLength = #data.cardAchievement;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.cardAchievement) do
		sendPushCardAchievement(v);
	end

-- MagicAchievement
	local arrayLength = #data.magicAchievement;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.magicAchievement) do
		sendPushMagicAchievement(v);
	end

-- 系统公告-公告条件9-极速挑战排行榜进入前10
	networkengine:pushInt(data.challengeSpeedCondition);
-- 系统公告-公告内容9-极速挑战排行榜进入前10
	networkengine:pushInt(string.len(data.challengeSpeedNotify));
	networkengine:pushString(data.challengeSpeedNotify, string.len(data.challengeSpeedNotify));
-- 系统公告-公告条件10-伤害排行榜进入前10名
	networkengine:pushInt(data.challengeDamageRankCondition);
-- 系统公告-公告内容10-伤害排行榜进入前10名
	networkengine:pushInt(string.len(data.challengeDamageRankNotify));
	networkengine:pushString(data.challengeDamageRankNotify, string.len(data.challengeDamageRankNotify));
-- 系统公告-公告条件11-天梯排行榜进入前10名
	networkengine:pushInt(data.pvpOfflineRankCondition);
-- 系统公告-公告内容11-天梯排行榜进入前10名
	networkengine:pushInt(string.len(data.pvpOfflineRankNotify));
	networkengine:pushString(data.pvpOfflineRankNotify, string.len(data.pvpOfflineRankNotify));
-- 系统公告-公告内容12-同步PVP开启时间1
	networkengine:pushInt(string.len(data.pvpOnlineNotify));
	networkengine:pushString(data.pvpOnlineNotify, string.len(data.pvpOnlineNotify));
-- 系统公告-你被人家抢夺了
	networkengine:pushInt(string.len(data.plunderByAnohter));
	networkengine:pushString(data.plunderByAnohter, string.len(data.plunderByAnohter));
-- 系统公告-远征完成全部八关
	networkengine:pushInt(string.len(data.crusadeNotify));
	networkengine:pushString(data.crusadeNotify, string.len(data.crusadeNotify));
-- 系统公告-摇到大礼包
	networkengine:pushInt(string.len(data.redEnvelopeNotify));
	networkengine:pushString(data.redEnvelopeNotify, string.len(data.redEnvelopeNotify));
-- 系统公告-击破据点
	networkengine:pushInt(string.len(data.guildWarBreak));
	networkengine:pushString(data.guildWarBreak, string.len(data.guildWarBreak));
-- 字符串，守护者
	networkengine:pushInt(string.len(data.guildWarNPCName));
	networkengine:pushString(data.guildWarNPCName, string.len(data.guildWarNPCName));
-- 字符串-提示-队长鼓舞据点
	networkengine:pushInt(string.len(data.guildWarInspireDefMsg));
	networkengine:pushString(data.guildWarInspireDefMsg, string.len(data.guildWarInspireDefMsg));
-- 字符串-提示-会员攻击鼓舞
	networkengine:pushInt(string.len(data.guildWarInspireAttMsg));
	networkengine:pushString(data.guildWarInspireAttMsg, string.len(data.guildWarInspireAttMsg));
-- 字符串-提示-加入公会
	networkengine:pushInt(string.len(data.guildEnterAMsg));
	networkengine:pushString(data.guildEnterAMsg, string.len(data.guildEnterAMsg));
-- 字符串-提示-离开公会
	networkengine:pushInt(string.len(data.guildLeaveAMsg));
	networkengine:pushString(data.guildLeaveAMsg, string.len(data.guildLeaveAMsg));
-- 字符串-提示-修改权限 xx把xx任命为xx
	networkengine:pushInt(string.len(data.guildChangePower));
	networkengine:pushString(data.guildChangePower, string.len(data.guildChangePower));
end

function ParseRowSysNotify()
	local tempArrayCount = 0;
	local data = {};

	data['pvpOfflineCombo'] = {};
	data['cardAchievement'] = {};
	data['magicAchievement'] = {};
-- 无意义
	data['id'] = networkengine:parseInt();
-- PvpOfflineCombo
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['pvpOfflineCombo'][i] = ParsePvpOfflineCombo();
	end
-- 系统公告-公告条件4-竞技场胜利场次达到5
	data['pvpOnlineComboCondition'] = networkengine:parseInt();
-- 系统公告-公告内容4-竞技场胜利场次达到5
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['pvpOnlineComboNotify'] = networkengine:parseString(strlength);
else
		data['pvpOnlineComboNotify'] = "";
end
-- CardAchievement
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['cardAchievement'][i] = ParseCardAchievement();
	end
-- MagicAchievement
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['magicAchievement'][i] = ParseMagicAchievement();
	end
-- 系统公告-公告条件9-极速挑战排行榜进入前10
	data['challengeSpeedCondition'] = networkengine:parseInt();
-- 系统公告-公告内容9-极速挑战排行榜进入前10
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['challengeSpeedNotify'] = networkengine:parseString(strlength);
else
		data['challengeSpeedNotify'] = "";
end
-- 系统公告-公告条件10-伤害排行榜进入前10名
	data['challengeDamageRankCondition'] = networkengine:parseInt();
-- 系统公告-公告内容10-伤害排行榜进入前10名
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['challengeDamageRankNotify'] = networkengine:parseString(strlength);
else
		data['challengeDamageRankNotify'] = "";
end
-- 系统公告-公告条件11-天梯排行榜进入前10名
	data['pvpOfflineRankCondition'] = networkengine:parseInt();
-- 系统公告-公告内容11-天梯排行榜进入前10名
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['pvpOfflineRankNotify'] = networkengine:parseString(strlength);
else
		data['pvpOfflineRankNotify'] = "";
end
-- 系统公告-公告内容12-同步PVP开启时间1
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['pvpOnlineNotify'] = networkengine:parseString(strlength);
else
		data['pvpOnlineNotify'] = "";
end
-- 系统公告-你被人家抢夺了
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['plunderByAnohter'] = networkengine:parseString(strlength);
else
		data['plunderByAnohter'] = "";
end
-- 系统公告-远征完成全部八关
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['crusadeNotify'] = networkengine:parseString(strlength);
else
		data['crusadeNotify'] = "";
end
-- 系统公告-摇到大礼包
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['redEnvelopeNotify'] = networkengine:parseString(strlength);
else
		data['redEnvelopeNotify'] = "";
end
-- 系统公告-击破据点
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['guildWarBreak'] = networkengine:parseString(strlength);
else
		data['guildWarBreak'] = "";
end
-- 字符串，守护者
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['guildWarNPCName'] = networkengine:parseString(strlength);
else
		data['guildWarNPCName'] = "";
end
-- 字符串-提示-队长鼓舞据点
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['guildWarInspireDefMsg'] = networkengine:parseString(strlength);
else
		data['guildWarInspireDefMsg'] = "";
end
-- 字符串-提示-会员攻击鼓舞
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['guildWarInspireAttMsg'] = networkengine:parseString(strlength);
else
		data['guildWarInspireAttMsg'] = "";
end
-- 字符串-提示-加入公会
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['guildEnterAMsg'] = networkengine:parseString(strlength);
else
		data['guildEnterAMsg'] = "";
end
-- 字符串-提示-离开公会
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['guildLeaveAMsg'] = networkengine:parseString(strlength);
else
		data['guildLeaveAMsg'] = "";
end
-- 字符串-提示-修改权限 xx把xx任命为xx
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['guildChangePower'] = networkengine:parseString(strlength);
else
		data['guildChangePower'] = "";
end

	return data;
end

------------------typedef RowLimitActivity ----------------------------------
function sendPushRowLimitActivity(data)
-- id
	networkengine:pushInt(data.id);
-- 奖励类型
	local arrayLength = #data.rewardType;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardType) do
		networkengine:pushInt(v);
	end

-- 奖励ID
	local arrayLength = #data.rewardID;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardID) do
		networkengine:pushInt(v);
	end

-- 奖励数量
	local arrayLength = #data.rewardCount;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardCount) do
		networkengine:pushInt(v);
	end

-- 限时类型枚举
	networkengine:pushInt(data.limitActivityTime);
-- 开始时间
	local arrayLength = #data.beginTime;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.beginTime) do
		networkengine:pushInt(v);
	end

-- 结束时间
	local arrayLength = #data.endTime;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.endTime) do
		networkengine:pushInt(v);
	end

-- 领奖条件枚举
	networkengine:pushInt(data.limitActivityCondition);
-- 领奖条件参数
	local arrayLength = #data.params;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.params) do
		networkengine:pushInt(v);
	end

-- 每服务器限名额
	networkengine:pushInt(data.amount);
-- 邮件ID
	networkengine:pushInt(data.mailID);
end

function ParseRowLimitActivity()
	local tempArrayCount = 0;
	local data = {};

	data['rewardType'] = {};
	data['rewardID'] = {};
	data['rewardCount'] = {};
	data['beginTime'] = {};
	data['endTime'] = {};
	data['params'] = {};
-- id
	data['id'] = networkengine:parseInt();
-- 奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardType'][i] = networkengine:parseInt();
	end
-- 奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardID'][i] = networkengine:parseInt();
	end
-- 奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardCount'][i] = networkengine:parseInt();
	end
-- 限时类型枚举
	data['limitActivityTime'] = networkengine:parseInt();
-- 开始时间
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['beginTime'][i] = networkengine:parseInt();
	end
-- 结束时间
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['endTime'][i] = networkengine:parseInt();
	end
-- 领奖条件枚举
	data['limitActivityCondition'] = networkengine:parseInt();
-- 领奖条件参数
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['params'][i] = networkengine:parseInt();
	end
-- 每服务器限名额
	data['amount'] = networkengine:parseInt();
-- 邮件ID
	data['mailID'] = networkengine:parseInt();

	return data;
end

------------------typedef RowGuide ----------------------------------
function sendPushRowGuide(data)
-- ID
	networkengine:pushInt(data.id);
-- 默认激活
	networkengine:pushBool(data.active);
end

function ParseRowGuide()
	local tempArrayCount = 0;
	local data = {};

-- ID
	data['id'] = networkengine:parseInt();
-- 默认激活
	data['active'] = networkengine:parseBool();

	return data;
end

------------------typedef RowRecharge ----------------------------------
function sendPushRowRecharge(data)
-- 编号
	networkengine:pushInt(data.id);
-- 名称
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- 类型
	networkengine:pushInt(data.type);
-- iosID
	networkengine:pushInt(string.len(data.iosid));
	networkengine:pushString(data.iosid, string.len(data.iosid));
-- 价格（元）
	networkengine:pushInt(data.rmb);
-- 钻石数量
	networkengine:pushInt(data.diamond);
-- 物品ID
	networkengine:pushInt(data.itemID);
end

function ParseRowRecharge()
	local tempArrayCount = 0;
	local data = {};

-- 编号
	data['id'] = networkengine:parseInt();
-- 名称
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 类型
	data['type'] = networkengine:parseInt();
-- iosID
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['iosid'] = networkengine:parseString(strlength);
else
		data['iosid'] = "";
end
-- 价格（元）
	data['rmb'] = networkengine:parseInt();
-- 钻石数量
	data['diamond'] = networkengine:parseInt();
-- 物品ID
	data['itemID'] = networkengine:parseInt();

	return data;
end

------------------typedef RowRemould ----------------------------------
function sendPushRowRemould(data)
-- 战船等级
	networkengine:pushInt(data.id);
-- 升级所需物品
	local arrayLength = #data.requireItem;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.requireItem) do
		networkengine:pushInt(v);
	end

-- 所需物品数量
	local arrayLength = #data.retuireItemCount;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.retuireItemCount) do
		networkengine:pushInt(v);
	end

-- 人口容量
	networkengine:pushInt(data.soldier);
end

function ParseRowRemould()
	local tempArrayCount = 0;
	local data = {};

	data['requireItem'] = {};
	data['retuireItemCount'] = {};
-- 战船等级
	data['id'] = networkengine:parseInt();
-- 升级所需物品
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['requireItem'][i] = networkengine:parseInt();
	end
-- 所需物品数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['retuireItemCount'][i] = networkengine:parseInt();
	end
-- 人口容量
	data['soldier'] = networkengine:parseInt();

	return data;
end

------------------typedef RowMagicRound ----------------------------------
function sendPushRowMagicRound(data)
-- 军团总和
	networkengine:pushInt(data.id);
-- 魔法准备回合
	networkengine:pushInt(data.round);
end

function ParseRowMagicRound()
	local tempArrayCount = 0;
	local data = {};

-- 军团总和
	data['id'] = networkengine:parseInt();
-- 魔法准备回合
	data['round'] = networkengine:parseInt();

	return data;
end

------------------typedef RowStrengthen ----------------------------------
function sendPushRowStrengthen(data)
-- 强化等级
	networkengine:pushInt(data.id);
-- 该级的属性系数
	networkengine:pushFloat(data.attrFactor);
-- 升到该级的金币消耗系数
	networkengine:pushFloat(data.costFactor);
end

function ParseRowStrengthen()
	local tempArrayCount = 0;
	local data = {};

-- 强化等级
	data['id'] = networkengine:parseInt();
-- 该级的属性系数
	data['attrFactor'] = networkengine:parseFloat();
-- 升到该级的金币消耗系数
	data['costFactor'] = networkengine:parseFloat();

	return data;
end

------------------typedef RowStage ----------------------------------
function sendPushRowStage(data)
-- id
	networkengine:pushInt(data.id);
-- 名称
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- 英雄等级
	networkengine:pushInt(data.heroLevel);
-- ShipAttrBase
	local arrayLength = #data.shipAttrBase;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.shipAttrBase) do
		sendPushShipAttrBase(v);
	end

-- 智力
	networkengine:pushInt(data.intelligence);
-- 魔法值
	networkengine:pushInt(data.mp);
-- 魔法列表
	local arrayLength = #data.magics;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.magics) do
		networkengine:pushInt(v);
	end

-- 魔法等级
	local arrayLength = #data.magicLevels;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.magicLevels) do
		networkengine:pushInt(v);
	end

-- 军团
	local arrayLength = #data.units;
	if arrayLength > 16 then arrayLength = 16 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.units) do
		networkengine:pushInt(v);
	end

-- 数量
	local arrayLength = #data.unitCount;
	if arrayLength > 16 then arrayLength = 16 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.unitCount) do
		networkengine:pushInt(v);
	end

-- X坐标
	local arrayLength = #data.positionsX;
	if arrayLength > 16 then arrayLength = 16 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.positionsX) do
		networkengine:pushInt(v);
	end

-- Y坐标
	local arrayLength = #data.positionsY;
	if arrayLength > 16 then arrayLength = 16 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.positionsY) do
		networkengine:pushInt(v);
	end

-- 首通奖励类型
	local arrayLength = #data.firstRewardType;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.firstRewardType) do
		networkengine:pushInt(v);
	end

-- 首通奖励ID
	local arrayLength = #data.firstRewardID;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.firstRewardID) do
		networkengine:pushInt(v);
	end

-- 首通奖励数量
	local arrayLength = #data.firstRewardCount;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.firstRewardCount) do
		networkengine:pushInt(v);
	end

-- 必得奖励类型
	local arrayLength = #data.rewardType;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardType) do
		networkengine:pushInt(v);
	end

-- 必得奖励ID
	local arrayLength = #data.rewardID;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardID) do
		networkengine:pushInt(v);
	end

-- 必得奖励数量
	local arrayLength = #data.rewardCount;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardCount) do
		networkengine:pushInt(v);
	end

-- 组1随机次数
	networkengine:pushInt(data.randomCount1);
-- 随机奖励类型
	local arrayLength = #data.randomReward1Type;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.randomReward1Type) do
		networkengine:pushInt(v);
	end

-- 随机奖励ID
	local arrayLength = #data.randomReward1ID;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.randomReward1ID) do
		networkengine:pushInt(v);
	end

-- 随机奖励数量
	local arrayLength = #data.randomReward1Count;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.randomReward1Count) do
		networkengine:pushInt(v);
	end

-- 概率
	local arrayLength = #data.chance1;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.chance1) do
		networkengine:pushInt(v);
	end

-- 组2随机次数
	networkengine:pushInt(data.randomCount2);
-- 随机奖励类型
	local arrayLength = #data.randomReward2Type;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.randomReward2Type) do
		networkengine:pushInt(v);
	end

-- 随机奖励ID
	local arrayLength = #data.randomReward2ID;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.randomReward2ID) do
		networkengine:pushInt(v);
	end

-- 随机奖励数量
	local arrayLength = #data.randomReward2Count;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.randomReward2Count) do
		networkengine:pushInt(v);
	end

-- 概率
	local arrayLength = #data.chance2;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.chance2) do
		networkengine:pushInt(v);
	end

-- 国王名称
	networkengine:pushInt(string.len(data.kingName));
	networkengine:pushString(data.kingName, string.len(data.kingName));
-- 国王头像ID
	networkengine:pushInt(data.kingIcon);
-- 是否适应等级
	networkengine:pushBool(data.needAdjust);
-- 等级offset
	networkengine:pushInt(data.adjustLevel);
-- 奇迹等级
	networkengine:pushInt(data.miracleLevel);
end

function ParseRowStage()
	local tempArrayCount = 0;
	local data = {};

	data['shipAttrBase'] = {};
	data['magics'] = {};
	data['magicLevels'] = {};
	data['units'] = {};
	data['unitCount'] = {};
	data['positionsX'] = {};
	data['positionsY'] = {};
	data['firstRewardType'] = {};
	data['firstRewardID'] = {};
	data['firstRewardCount'] = {};
	data['rewardType'] = {};
	data['rewardID'] = {};
	data['rewardCount'] = {};
	data['randomReward1Type'] = {};
	data['randomReward1ID'] = {};
	data['randomReward1Count'] = {};
	data['chance1'] = {};
	data['randomReward2Type'] = {};
	data['randomReward2ID'] = {};
	data['randomReward2Count'] = {};
	data['chance2'] = {};
-- id
	data['id'] = networkengine:parseInt();
-- 名称
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 英雄等级
	data['heroLevel'] = networkengine:parseInt();
-- ShipAttrBase
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['shipAttrBase'][i] = ParseShipAttrBase();
	end
-- 智力
	data['intelligence'] = networkengine:parseInt();
-- 魔法值
	data['mp'] = networkengine:parseInt();
-- 魔法列表
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['magics'][i] = networkengine:parseInt();
	end
-- 魔法等级
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['magicLevels'][i] = networkengine:parseInt();
	end
-- 军团
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['units'][i] = networkengine:parseInt();
	end
-- 数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['unitCount'][i] = networkengine:parseInt();
	end
-- X坐标
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['positionsX'][i] = networkengine:parseInt();
	end
-- Y坐标
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['positionsY'][i] = networkengine:parseInt();
	end
-- 首通奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['firstRewardType'][i] = networkengine:parseInt();
	end
-- 首通奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['firstRewardID'][i] = networkengine:parseInt();
	end
-- 首通奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['firstRewardCount'][i] = networkengine:parseInt();
	end
-- 必得奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardType'][i] = networkengine:parseInt();
	end
-- 必得奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardID'][i] = networkengine:parseInt();
	end
-- 必得奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardCount'][i] = networkengine:parseInt();
	end
-- 组1随机次数
	data['randomCount1'] = networkengine:parseInt();
-- 随机奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['randomReward1Type'][i] = networkengine:parseInt();
	end
-- 随机奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['randomReward1ID'][i] = networkengine:parseInt();
	end
-- 随机奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['randomReward1Count'][i] = networkengine:parseInt();
	end
-- 概率
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['chance1'][i] = networkengine:parseInt();
	end
-- 组2随机次数
	data['randomCount2'] = networkengine:parseInt();
-- 随机奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['randomReward2Type'][i] = networkengine:parseInt();
	end
-- 随机奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['randomReward2ID'][i] = networkengine:parseInt();
	end
-- 随机奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['randomReward2Count'][i] = networkengine:parseInt();
	end
-- 概率
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['chance2'][i] = networkengine:parseInt();
	end
-- 国王名称
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['kingName'] = networkengine:parseString(strlength);
else
		data['kingName'] = "";
end
-- 国王头像ID
	data['kingIcon'] = networkengine:parseInt();
-- 是否适应等级
	data['needAdjust'] = networkengine:parseBool();
-- 等级offset
	data['adjustLevel'] = networkengine:parseInt();
-- 奇迹等级
	data['miracleLevel'] = networkengine:parseInt();

	return data;
end

------------------typedef RowSkill ----------------------------------
function sendPushRowSkill(data)
-- 技能ID
	networkengine:pushInt(data.id);
-- 技能名称
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- 取消攻击
	networkengine:pushBool(data.cancelAttack);
-- 不取消反击
	networkengine:pushBool(data.canRetaliate);
-- 触发时刻
	networkengine:pushInt(data.moment);
-- 优先级
	networkengine:pushInt(data.priority);
-- 可被沉默
	networkengine:pushBool(data.canBeSilent);
-- 出生冷却
	networkengine:pushInt(data.bornCooldown);
-- 冷却
	networkengine:pushInt(data.cooldown);
-- 主目标
	networkengine:pushInt(data.targetType);
-- 距离
	networkengine:pushInt(data.casterRange);
-- 目标类型
	networkengine:pushInt(data.side);
-- 范围类型
	networkengine:pushInt(data.skillShape);
-- 范围参数
	networkengine:pushInt(data.targetRange);
end

function ParseRowSkill()
	local tempArrayCount = 0;
	local data = {};

-- 技能ID
	data['id'] = networkengine:parseInt();
-- 技能名称
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 取消攻击
	data['cancelAttack'] = networkengine:parseBool();
-- 不取消反击
	data['canRetaliate'] = networkengine:parseBool();
-- 触发时刻
	data['moment'] = networkengine:parseInt();
-- 优先级
	data['priority'] = networkengine:parseInt();
-- 可被沉默
	data['canBeSilent'] = networkengine:parseBool();
-- 出生冷却
	data['bornCooldown'] = networkengine:parseInt();
-- 冷却
	data['cooldown'] = networkengine:parseInt();
-- 主目标
	data['targetType'] = networkengine:parseInt();
-- 距离
	data['casterRange'] = networkengine:parseInt();
-- 目标类型
	data['side'] = networkengine:parseInt();
-- 范围类型
	data['skillShape'] = networkengine:parseInt();
-- 范围参数
	data['targetRange'] = networkengine:parseInt();

	return data;
end

------------------typedef RowShop ----------------------------------
function sendPushRowShop(data)
-- id
	networkengine:pushInt(data.id);
-- 等级段划分点
	networkengine:pushInt(data.level);
-- 金币商店商品类型
	local arrayLength = #data.goldGoodsType;
	if arrayLength > 128 then arrayLength = 128 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.goldGoodsType) do
		networkengine:pushInt(v);
	end

-- 金币商店商品ID
	local arrayLength = #data.goldGoodsID;
	if arrayLength > 128 then arrayLength = 128 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.goldGoodsID) do
		networkengine:pushInt(v);
	end

-- 金币商店商品数量
	local arrayLength = #data.goldGoodsCount;
	if arrayLength > 128 then arrayLength = 128 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.goldGoodsCount) do
		networkengine:pushInt(v);
	end

-- 金币商店商品价格
	local arrayLength = #data.goldGoodsPrice;
	if arrayLength > 128 then arrayLength = 128 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.goldGoodsPrice) do
		networkengine:pushInt(v);
	end

-- 金币商品出现几率（权值相加）
	local arrayLength = #data.goldGoodsChance;
	if arrayLength > 128 then arrayLength = 128 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.goldGoodsChance) do
		networkengine:pushInt(v);
	end

-- 钻石商店商品类型
	local arrayLength = #data.diamondGoodsType;
	if arrayLength > 64 then arrayLength = 64 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.diamondGoodsType) do
		networkengine:pushInt(v);
	end

-- 钻石商店商品ID
	local arrayLength = #data.diamondGoodsID;
	if arrayLength > 64 then arrayLength = 64 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.diamondGoodsID) do
		networkengine:pushInt(v);
	end

-- 钻石商店商品数量
	local arrayLength = #data.diamondGoodsCount;
	if arrayLength > 64 then arrayLength = 64 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.diamondGoodsCount) do
		networkengine:pushInt(v);
	end

-- 钻石商店商品价格
	local arrayLength = #data.diamondGoodsPrice;
	if arrayLength > 64 then arrayLength = 64 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.diamondGoodsPrice) do
		networkengine:pushInt(v);
	end

-- 钻石商品出现几率（权值相加）
	local arrayLength = #data.diamondGoodsChance;
	if arrayLength > 64 then arrayLength = 64 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.diamondGoodsChance) do
		networkengine:pushInt(v);
	end

-- 荣誉商店商品类型
	local arrayLength = #data.honorGoodsType;
	if arrayLength > 128 then arrayLength = 128 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.honorGoodsType) do
		networkengine:pushInt(v);
	end

-- 荣誉商店商品ID
	local arrayLength = #data.honorGoodsID;
	if arrayLength > 128 then arrayLength = 128 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.honorGoodsID) do
		networkengine:pushInt(v);
	end

-- 荣誉商店商品数量
	local arrayLength = #data.honorGoodsCount;
	if arrayLength > 128 then arrayLength = 128 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.honorGoodsCount) do
		networkengine:pushInt(v);
	end

-- 荣誉商店商品价格
	local arrayLength = #data.honorGoodsPrice;
	if arrayLength > 128 then arrayLength = 128 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.honorGoodsPrice) do
		networkengine:pushInt(v);
	end

-- 荣誉商品出现几率（权值相加）
	local arrayLength = #data.honorGoodsChance;
	if arrayLength > 128 then arrayLength = 128 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.honorGoodsChance) do
		networkengine:pushInt(v);
	end

-- 徽章商店商品类型
	local arrayLength = #data.conquestGoodsType;
	if arrayLength > 64 then arrayLength = 64 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.conquestGoodsType) do
		networkengine:pushInt(v);
	end

-- 徽章商店商品ID
	local arrayLength = #data.conquestGoodsID;
	if arrayLength > 64 then arrayLength = 64 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.conquestGoodsID) do
		networkengine:pushInt(v);
	end

-- 徽章商店商品数量
	local arrayLength = #data.conquestGoodsCount;
	if arrayLength > 64 then arrayLength = 64 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.conquestGoodsCount) do
		networkengine:pushInt(v);
	end

-- 徽章商店商品价格
	local arrayLength = #data.conquestGoodsPrice;
	if arrayLength > 64 then arrayLength = 64 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.conquestGoodsPrice) do
		networkengine:pushInt(v);
	end

-- 徽章商品出现几率（权值相加）
	local arrayLength = #data.conquestGoodsChance;
	if arrayLength > 64 then arrayLength = 64 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.conquestGoodsChance) do
		networkengine:pushInt(v);
	end

end

function ParseRowShop()
	local tempArrayCount = 0;
	local data = {};

	data['goldGoodsType'] = {};
	data['goldGoodsID'] = {};
	data['goldGoodsCount'] = {};
	data['goldGoodsPrice'] = {};
	data['goldGoodsChance'] = {};
	data['diamondGoodsType'] = {};
	data['diamondGoodsID'] = {};
	data['diamondGoodsCount'] = {};
	data['diamondGoodsPrice'] = {};
	data['diamondGoodsChance'] = {};
	data['honorGoodsType'] = {};
	data['honorGoodsID'] = {};
	data['honorGoodsCount'] = {};
	data['honorGoodsPrice'] = {};
	data['honorGoodsChance'] = {};
	data['conquestGoodsType'] = {};
	data['conquestGoodsID'] = {};
	data['conquestGoodsCount'] = {};
	data['conquestGoodsPrice'] = {};
	data['conquestGoodsChance'] = {};
-- id
	data['id'] = networkengine:parseInt();
-- 等级段划分点
	data['level'] = networkengine:parseInt();
-- 金币商店商品类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['goldGoodsType'][i] = networkengine:parseInt();
	end
-- 金币商店商品ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['goldGoodsID'][i] = networkengine:parseInt();
	end
-- 金币商店商品数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['goldGoodsCount'][i] = networkengine:parseInt();
	end
-- 金币商店商品价格
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['goldGoodsPrice'][i] = networkengine:parseInt();
	end
-- 金币商品出现几率（权值相加）
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['goldGoodsChance'][i] = networkengine:parseInt();
	end
-- 钻石商店商品类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['diamondGoodsType'][i] = networkengine:parseInt();
	end
-- 钻石商店商品ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['diamondGoodsID'][i] = networkengine:parseInt();
	end
-- 钻石商店商品数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['diamondGoodsCount'][i] = networkengine:parseInt();
	end
-- 钻石商店商品价格
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['diamondGoodsPrice'][i] = networkengine:parseInt();
	end
-- 钻石商品出现几率（权值相加）
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['diamondGoodsChance'][i] = networkengine:parseInt();
	end
-- 荣誉商店商品类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['honorGoodsType'][i] = networkengine:parseInt();
	end
-- 荣誉商店商品ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['honorGoodsID'][i] = networkengine:parseInt();
	end
-- 荣誉商店商品数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['honorGoodsCount'][i] = networkengine:parseInt();
	end
-- 荣誉商店商品价格
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['honorGoodsPrice'][i] = networkengine:parseInt();
	end
-- 荣誉商品出现几率（权值相加）
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['honorGoodsChance'][i] = networkengine:parseInt();
	end
-- 徽章商店商品类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['conquestGoodsType'][i] = networkengine:parseInt();
	end
-- 徽章商店商品ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['conquestGoodsID'][i] = networkengine:parseInt();
	end
-- 徽章商店商品数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['conquestGoodsCount'][i] = networkengine:parseInt();
	end
-- 徽章商店商品价格
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['conquestGoodsPrice'][i] = networkengine:parseInt();
	end
-- 徽章商品出现几率（权值相加）
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['conquestGoodsChance'][i] = networkengine:parseInt();
	end

	return data;
end

------------------typedef RowShip ----------------------------------
function sendPushRowShip(data)
-- 战船等级
	networkengine:pushInt(data.id);
-- 升级所需金钱
	networkengine:pushInt(data.money);
-- 升级所需木材
	networkengine:pushInt(data.wood);
-- 升级所需物品
	local arrayLength = #data.requireItem;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.requireItem) do
		networkengine:pushInt(v);
	end

-- 所需物品数量
	local arrayLength = #data.retuireItemCount;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.retuireItemCount) do
		networkengine:pushInt(v);
	end

-- 人口容量
	networkengine:pushInt(data.soldier);
end

function ParseRowShip()
	local tempArrayCount = 0;
	local data = {};

	data['requireItem'] = {};
	data['retuireItemCount'] = {};
-- 战船等级
	data['id'] = networkengine:parseInt();
-- 升级所需金钱
	data['money'] = networkengine:parseInt();
-- 升级所需木材
	data['wood'] = networkengine:parseInt();
-- 升级所需物品
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['requireItem'][i] = networkengine:parseInt();
	end
-- 所需物品数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['retuireItemCount'][i] = networkengine:parseInt();
	end
-- 人口容量
	data['soldier'] = networkengine:parseInt();

	return data;
end

------------------typedef RowPvpOnline ----------------------------------
function sendPushRowPvpOnline(data)
-- id
	networkengine:pushInt(data.id);
-- 胜场数
	networkengine:pushInt(data.wins);
-- 必得奖励类型
	local arrayLength = #data.rewardType;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardType) do
		networkengine:pushInt(v);
	end

-- 必得奖励ID
	local arrayLength = #data.rewardID;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardID) do
		networkengine:pushInt(v);
	end

-- 必得奖励数量
	local arrayLength = #data.rewardCount;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardCount) do
		networkengine:pushInt(v);
	end

end

function ParseRowPvpOnline()
	local tempArrayCount = 0;
	local data = {};

	data['rewardType'] = {};
	data['rewardID'] = {};
	data['rewardCount'] = {};
-- id
	data['id'] = networkengine:parseInt();
-- 胜场数
	data['wins'] = networkengine:parseInt();
-- 必得奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardType'][i] = networkengine:parseInt();
	end
-- 必得奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardID'][i] = networkengine:parseInt();
	end
-- 必得奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardCount'][i] = networkengine:parseInt();
	end

	return data;
end

------------------typedef RowPvpOffline ----------------------------------
function sendPushRowPvpOffline(data)
-- id
	networkengine:pushInt(data.id);
-- 名次
	networkengine:pushInt(data.rank);
-- 匹配分档点
	local arrayLength = #data.bracket;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.bracket) do
		networkengine:pushInt(v);
	end

-- 必得奖励类型
	local arrayLength = #data.rewardType;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardType) do
		networkengine:pushInt(v);
	end

-- 必得奖励ID
	local arrayLength = #data.rewardID;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardID) do
		networkengine:pushInt(v);
	end

-- 必得奖励数量
	local arrayLength = #data.rewardCount;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardCount) do
		networkengine:pushInt(v);
	end

-- 钻石奖励
	networkengine:pushFloat(data.diamondPerRank);
-- 国王名字
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- 国王头像
	networkengine:pushInt(data.icon);
-- 英雄等级
	networkengine:pushInt(data.heroLevel);
-- ShipAttrBase
	local arrayLength = #data.shipAttrBase;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.shipAttrBase) do
		sendPushShipAttrBase(v);
	end

-- 智力
	networkengine:pushInt(data.intelligence);
-- 魔法值
	networkengine:pushInt(data.mp);
-- 魔法列表
	local arrayLength = #data.magics;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.magics) do
		networkengine:pushInt(v);
	end

-- 魔法等级
	local arrayLength = #data.magicLevels;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.magicLevels) do
		networkengine:pushInt(v);
	end

-- 军团
	local arrayLength = #data.units;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.units) do
		networkengine:pushInt(v);
	end

-- 数量
	local arrayLength = #data.unitCount;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.unitCount) do
		networkengine:pushInt(v);
	end

-- X坐标
	local arrayLength = #data.positionsX;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.positionsX) do
		networkengine:pushInt(v);
	end

-- Y坐标
	local arrayLength = #data.positionsY;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.positionsY) do
		networkengine:pushInt(v);
	end

-- 奇迹等级
	networkengine:pushInt(data.miracleLevel);
end

function ParseRowPvpOffline()
	local tempArrayCount = 0;
	local data = {};

	data['bracket'] = {};
	data['rewardType'] = {};
	data['rewardID'] = {};
	data['rewardCount'] = {};
	data['shipAttrBase'] = {};
	data['magics'] = {};
	data['magicLevels'] = {};
	data['units'] = {};
	data['unitCount'] = {};
	data['positionsX'] = {};
	data['positionsY'] = {};
-- id
	data['id'] = networkengine:parseInt();
-- 名次
	data['rank'] = networkengine:parseInt();
-- 匹配分档点
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['bracket'][i] = networkengine:parseInt();
	end
-- 必得奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardType'][i] = networkengine:parseInt();
	end
-- 必得奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardID'][i] = networkengine:parseInt();
	end
-- 必得奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardCount'][i] = networkengine:parseInt();
	end
-- 钻石奖励
	data['diamondPerRank'] = networkengine:parseFloat();
-- 国王名字
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 国王头像
	data['icon'] = networkengine:parseInt();
-- 英雄等级
	data['heroLevel'] = networkengine:parseInt();
-- ShipAttrBase
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['shipAttrBase'][i] = ParseShipAttrBase();
	end
-- 智力
	data['intelligence'] = networkengine:parseInt();
-- 魔法值
	data['mp'] = networkengine:parseInt();
-- 魔法列表
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['magics'][i] = networkengine:parseInt();
	end
-- 魔法等级
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['magicLevels'][i] = networkengine:parseInt();
	end
-- 军团
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['units'][i] = networkengine:parseInt();
	end
-- 数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['unitCount'][i] = networkengine:parseInt();
	end
-- X坐标
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['positionsX'][i] = networkengine:parseInt();
	end
-- Y坐标
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['positionsY'][i] = networkengine:parseInt();
	end
-- 奇迹等级
	data['miracleLevel'] = networkengine:parseInt();

	return data;
end

------------------typedef RowPrice ----------------------------------
function sendPushRowPrice(data)
-- 次数
	networkengine:pushInt(data.id);
-- 买体力消耗钻石
	networkengine:pushInt(data.vigor);
-- 买金币消耗钻石
	networkengine:pushInt(data.gold);
-- 买木材消耗钻石
	networkengine:pushInt(data.lumber);
-- 重置冒险关卡次数消耗钻石
	networkengine:pushInt(data.resetStage);
-- 刷新商店消耗钻石
	networkengine:pushInt(data.resetShop);
-- 每日回购经验消耗钻石
	networkengine:pushInt(data.lostExp);
-- 买魔法精华消耗钻石
	networkengine:pushInt(data.magicExp);
-- 购买掠夺次数消耗钻石
	networkengine:pushInt(data.resetPlunder);
-- 购买公会战挑战次数消耗钻石
	networkengine:pushInt(data.guildWarTime);
-- 购买公会战防御鼓舞消耗钻石
	networkengine:pushInt(data.guildWarDef);
-- 购买公会战攻击鼓舞消耗木材
	networkengine:pushInt(data.guildWarAtkWood);
end

function ParseRowPrice()
	local tempArrayCount = 0;
	local data = {};

-- 次数
	data['id'] = networkengine:parseInt();
-- 买体力消耗钻石
	data['vigor'] = networkengine:parseInt();
-- 买金币消耗钻石
	data['gold'] = networkengine:parseInt();
-- 买木材消耗钻石
	data['lumber'] = networkengine:parseInt();
-- 重置冒险关卡次数消耗钻石
	data['resetStage'] = networkengine:parseInt();
-- 刷新商店消耗钻石
	data['resetShop'] = networkengine:parseInt();
-- 每日回购经验消耗钻石
	data['lostExp'] = networkengine:parseInt();
-- 买魔法精华消耗钻石
	data['magicExp'] = networkengine:parseInt();
-- 购买掠夺次数消耗钻石
	data['resetPlunder'] = networkengine:parseInt();
-- 购买公会战挑战次数消耗钻石
	data['guildWarTime'] = networkengine:parseInt();
-- 购买公会战防御鼓舞消耗钻石
	data['guildWarDef'] = networkengine:parseInt();
-- 购买公会战攻击鼓舞消耗木材
	data['guildWarAtkWood'] = networkengine:parseInt();

	return data;
end

------------------typedef RowPlayer ----------------------------------
function sendPushRowPlayer(data)
-- 英雄等级
	networkengine:pushInt(data.id);
-- 升到下级所需经验
	networkengine:pushInt(data.exp);
-- 法强
	networkengine:pushInt(data.intelligence);
-- 魔法值上限
	networkengine:pushInt(data.maxMP);
-- 升级后获得的体力
	networkengine:pushInt(data.vigorRegeneration);
-- ShipAttrBase
	local arrayLength = #data.shipAttrBase;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.shipAttrBase) do
		sendPushShipAttrBase(v);
	end

-- 数量系数
	networkengine:pushInt(data.numberRatio);
-- 奖励系数
	networkengine:pushFloat(data.rewardRatio);
-- 远征数量匹配
	local arrayLength = #data.crusadeCountMatch;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.crusadeCountMatch) do
		networkengine:pushFloat(v);
	end

-- 远征装备匹配
	local arrayLength = #data.crusadeAttrMatch;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.crusadeAttrMatch) do
		networkengine:pushFloat(v);
	end

-- 抢夺能获得的金币
	networkengine:pushInt(data.plunderWinGold);
end

function ParseRowPlayer()
	local tempArrayCount = 0;
	local data = {};

	data['shipAttrBase'] = {};
	data['crusadeCountMatch'] = {};
	data['crusadeAttrMatch'] = {};
-- 英雄等级
	data['id'] = networkengine:parseInt();
-- 升到下级所需经验
	data['exp'] = networkengine:parseInt();
-- 法强
	data['intelligence'] = networkengine:parseInt();
-- 魔法值上限
	data['maxMP'] = networkengine:parseInt();
-- 升级后获得的体力
	data['vigorRegeneration'] = networkengine:parseInt();
-- ShipAttrBase
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['shipAttrBase'][i] = ParseShipAttrBase();
	end
-- 数量系数
	data['numberRatio'] = networkengine:parseInt();
-- 奖励系数
	data['rewardRatio'] = networkengine:parseFloat();
-- 远征数量匹配
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['crusadeCountMatch'][i] = networkengine:parseFloat();
	end
-- 远征装备匹配
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['crusadeAttrMatch'][i] = networkengine:parseFloat();
	end
-- 抢夺能获得的金币
	data['plunderWinGold'] = networkengine:parseInt();

	return data;
end

------------------typedef RowMainBase ----------------------------------
function sendPushRowMainBase(data)
-- 领地1等级
	local arrayLength = #data.home;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.home) do
		networkengine:pushInt(v);
	end

-- 兵粮上限
	networkengine:pushInt(data.maxFood);
end

function ParseRowMainBase()
	local tempArrayCount = 0;
	local data = {};

	data['home'] = {};
-- 领地1等级
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['home'][i] = networkengine:parseInt();
	end
-- 兵粮上限
	data['maxFood'] = networkengine:parseInt();

	return data;
end

------------------typedef RowMailString ----------------------------------
function sendPushRowMailString(data)
-- ID
	networkengine:pushInt(data.id);
-- 邮件标题
	networkengine:pushInt(string.len(data.caption));
	networkengine:pushString(data.caption, string.len(data.caption));
-- 邮件内容
	networkengine:pushInt(string.len(data.text));
	networkengine:pushString(data.text, string.len(data.text));
end

function ParseRowMailString()
	local tempArrayCount = 0;
	local data = {};

-- ID
	data['id'] = networkengine:parseInt();
-- 邮件标题
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['caption'] = networkengine:parseString(strlength);
else
		data['caption'] = "";
end
-- 邮件内容
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['text'] = networkengine:parseString(strlength);
else
		data['text'] = "";
end

	return data;
end

------------------typedef RowMagicTower ----------------------------------
function sendPushRowMagicTower(data)
-- 法师塔候选技能数量
	networkengine:pushInt(data.candidateSkillNum);
-- 概率
	local arrayLength = #data.starChance;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.starChance) do
		networkengine:pushInt(v);
	end

-- 每次消耗的冥想点数
	networkengine:pushInt(data.meditationCost);
-- 冥想点数上限
	networkengine:pushInt(data.meditationCostLimit);
end

function ParseRowMagicTower()
	local tempArrayCount = 0;
	local data = {};

	data['starChance'] = {};
-- 法师塔候选技能数量
	data['candidateSkillNum'] = networkengine:parseInt();
-- 概率
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['starChance'][i] = networkengine:parseInt();
	end
-- 每次消耗的冥想点数
	data['meditationCost'] = networkengine:parseInt();
-- 冥想点数上限
	data['meditationCostLimit'] = networkengine:parseInt();

	return data;
end

------------------typedef RowMagic ----------------------------------
function sendPushRowMagic(data)
-- ID
	networkengine:pushInt(data.id);
-- 魔法名称
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- 可施放次数
	networkengine:pushInt(data.castTimes);
-- 法力消耗
	local arrayLength = #data.cost;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.cost) do
		networkengine:pushInt(v);
	end

-- 开场冷却
	networkengine:pushInt(data.cooldownOnStart);
-- 冷却
	networkengine:pushInt(data.cooldown);
-- 交互类型
	networkengine:pushInt(data.targetType);
-- 范围类型
	networkengine:pushInt(data.shape);
-- 范围参数
	networkengine:pushInt(data.scope);
-- 作用类型
	networkengine:pushInt(data.side);
-- 添加buffID
	networkengine:pushInt(data.buffID);
-- AI
	networkengine:pushInt(data.magicAI);
-- 初始星级
	networkengine:pushInt(data.startLevel);
-- 是否极速挑战活动魔法
	networkengine:pushBool(data.isGreatMagic);
end

function ParseRowMagic()
	local tempArrayCount = 0;
	local data = {};

	data['cost'] = {};
-- ID
	data['id'] = networkengine:parseInt();
-- 魔法名称
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 可施放次数
	data['castTimes'] = networkengine:parseInt();
-- 法力消耗
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['cost'][i] = networkengine:parseInt();
	end
-- 开场冷却
	data['cooldownOnStart'] = networkengine:parseInt();
-- 冷却
	data['cooldown'] = networkengine:parseInt();
-- 交互类型
	data['targetType'] = networkengine:parseInt();
-- 范围类型
	data['shape'] = networkengine:parseInt();
-- 范围参数
	data['scope'] = networkengine:parseInt();
-- 作用类型
	data['side'] = networkengine:parseInt();
-- 添加buffID
	data['buffID'] = networkengine:parseInt();
-- AI
	data['magicAI'] = networkengine:parseInt();
-- 初始星级
	data['startLevel'] = networkengine:parseInt();
-- 是否极速挑战活动魔法
	data['isGreatMagic'] = networkengine:parseBool();

	return data;
end

------------------typedef RowLumberMill ----------------------------------
function sendPushRowLumberMill(data)
-- 每根原木的产出基数
	networkengine:pushInt(data.criticalBase);
-- 钻石购买获得木材量
	networkengine:pushInt(data.diamondToLumber);
end

function ParseRowLumberMill()
	local tempArrayCount = 0;
	local data = {};

-- 每根原木的产出基数
	data['criticalBase'] = networkengine:parseInt();
-- 钻石购买获得木材量
	data['diamondToLumber'] = networkengine:parseInt();

	return data;
end

------------------typedef RowLoginReward ----------------------------------
function sendPushRowLoginReward(data)
-- 登陆天数
	networkengine:pushInt(data.id);
-- 奖励类型
	local arrayLength = #data.rewardType;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardType) do
		networkengine:pushInt(v);
	end

-- 奖励ID
	local arrayLength = #data.rewardID;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardID) do
		networkengine:pushInt(v);
	end

-- 奖励数量
	local arrayLength = #data.rewardCount;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardCount) do
		networkengine:pushInt(v);
	end

end

function ParseRowLoginReward()
	local tempArrayCount = 0;
	local data = {};

	data['rewardType'] = {};
	data['rewardID'] = {};
	data['rewardCount'] = {};
-- 登陆天数
	data['id'] = networkengine:parseInt();
-- 奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardType'][i] = networkengine:parseInt();
	end
-- 奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardID'][i] = networkengine:parseInt();
	end
-- 奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardCount'][i] = networkengine:parseInt();
	end

	return data;
end

------------------typedef RowLevelReward ----------------------------------
function sendPushRowLevelReward(data)
-- id
	networkengine:pushInt(data.id);
-- 所需等级
	networkengine:pushInt(data.level);
-- 奖励类型
	local arrayLength = #data.rewardType;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardType) do
		networkengine:pushInt(v);
	end

-- 奖励ID
	local arrayLength = #data.rewardID;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardID) do
		networkengine:pushInt(v);
	end

-- 奖励数量
	local arrayLength = #data.rewardCount;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardCount) do
		networkengine:pushInt(v);
	end

end

function ParseRowLevelReward()
	local tempArrayCount = 0;
	local data = {};

	data['rewardType'] = {};
	data['rewardID'] = {};
	data['rewardCount'] = {};
-- id
	data['id'] = networkengine:parseInt();
-- 所需等级
	data['level'] = networkengine:parseInt();
-- 奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardType'][i] = networkengine:parseInt();
	end
-- 奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardID'][i] = networkengine:parseInt();
	end
-- 奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardCount'][i] = networkengine:parseInt();
	end

	return data;
end

------------------typedef RowUseItem ----------------------------------
function sendPushRowUseItem(data)
-- ID
	networkengine:pushInt(data.id);
-- 国王等级限制
	networkengine:pushInt(data.kingLevelLimit);
-- 所需钥匙数量
	networkengine:pushInt(data.needCount);
-- 所需钥匙ID
	networkengine:pushInt(data.needItemID);
-- 随机获得物品
	networkengine:pushBool(data.isRandItem);
-- 奖励类型
	local arrayLength = #data.rewardType;
	if arrayLength > 128 then arrayLength = 128 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardType) do
		networkengine:pushInt(v);
	end

-- 奖励ID
	local arrayLength = #data.rewardID;
	if arrayLength > 128 then arrayLength = 128 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardID) do
		networkengine:pushInt(v);
	end

-- 奖励数量
	local arrayLength = #data.rewardNum;
	if arrayLength > 128 then arrayLength = 128 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardNum) do
		networkengine:pushInt(v);
	end

-- 奖励概率
	local arrayLength = #data.rewardOdds;
	if arrayLength > 128 then arrayLength = 128 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardOdds) do
		networkengine:pushInt(v);
	end

end

function ParseRowUseItem()
	local tempArrayCount = 0;
	local data = {};

	data['rewardType'] = {};
	data['rewardID'] = {};
	data['rewardNum'] = {};
	data['rewardOdds'] = {};
-- ID
	data['id'] = networkengine:parseInt();
-- 国王等级限制
	data['kingLevelLimit'] = networkengine:parseInt();
-- 所需钥匙数量
	data['needCount'] = networkengine:parseInt();
-- 所需钥匙ID
	data['needItemID'] = networkengine:parseInt();
-- 随机获得物品
	data['isRandItem'] = networkengine:parseBool();
-- 奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardType'][i] = networkengine:parseInt();
	end
-- 奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardID'][i] = networkengine:parseInt();
	end
-- 奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardNum'][i] = networkengine:parseInt();
	end
-- 奖励概率
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardOdds'][i] = networkengine:parseInt();
	end

	return data;
end

------------------typedef RowDebris ----------------------------------
function sendPushRowDebris(data)
-- ID
	networkengine:pushInt(data.id);
-- 成品ID
	networkengine:pushInt(data.productID);
-- 合成所需数量
	networkengine:pushInt(data.needCount);
end

function ParseRowDebris()
	local tempArrayCount = 0;
	local data = {};

-- ID
	data['id'] = networkengine:parseInt();
-- 成品ID
	data['productID'] = networkengine:parseInt();
-- 合成所需数量
	data['needCount'] = networkengine:parseInt();

	return data;
end

------------------typedef RowEquip ----------------------------------
function sendPushRowEquip(data)
-- ID
	networkengine:pushInt(data.id);
-- 部位
	networkengine:pushInt(data.part);
-- 所需国王等级
	networkengine:pushInt(data.requireLevel);
-- 属性1类型
	networkengine:pushInt(data.attr);
-- 属性1基础值
	networkengine:pushInt(data.baseAttrValue);
-- 属性1强化值
	networkengine:pushInt(data.enhanceValue);
-- 属性2类型
	networkengine:pushInt(data.attr2);
-- 属性2基础值
	networkengine:pushInt(data.baseAttrValue2);
-- 属性2强化值
	networkengine:pushInt(data.enhanceValue2);
-- 不可强化
	networkengine:pushBool(data.noEnhance);
-- 强化上限
	networkengine:pushInt(data.enhanceMax);
-- 强化费用基数
	networkengine:pushInt(data.enhanceCost);
end

function ParseRowEquip()
	local tempArrayCount = 0;
	local data = {};

-- ID
	data['id'] = networkengine:parseInt();
-- 部位
	data['part'] = networkengine:parseInt();
-- 所需国王等级
	data['requireLevel'] = networkengine:parseInt();
-- 属性1类型
	data['attr'] = networkengine:parseInt();
-- 属性1基础值
	data['baseAttrValue'] = networkengine:parseInt();
-- 属性1强化值
	data['enhanceValue'] = networkengine:parseInt();
-- 属性2类型
	data['attr2'] = networkengine:parseInt();
-- 属性2基础值
	data['baseAttrValue2'] = networkengine:parseInt();
-- 属性2强化值
	data['enhanceValue2'] = networkengine:parseInt();
-- 不可强化
	data['noEnhance'] = networkengine:parseBool();
-- 强化上限
	data['enhanceMax'] = networkengine:parseInt();
-- 强化费用基数
	data['enhanceCost'] = networkengine:parseInt();

	return data;
end

------------------typedef RowItem ----------------------------------
function sendPushRowItem(data)
-- ID
	networkengine:pushInt(data.id);
-- 类别
	networkengine:pushInt(data.type);
-- 子类ID
	networkengine:pushInt(data.subID);
-- 名称
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- 星级
	networkengine:pushInt(data.star);
-- 不可卖店
	networkengine:pushBool(data.noSell);
-- 卖店价
	networkengine:pushInt(data.sellToShop);
-- 不可堆叠
	networkengine:pushBool(data.noOverlap);
end

function ParseRowItem()
	local tempArrayCount = 0;
	local data = {};

-- ID
	data['id'] = networkengine:parseInt();
-- 类别
	data['type'] = networkengine:parseInt();
-- 子类ID
	data['subID'] = networkengine:parseInt();
-- 名称
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 星级
	data['star'] = networkengine:parseInt();
-- 不可卖店
	data['noSell'] = networkengine:parseBool();
-- 卖店价
	data['sellToShop'] = networkengine:parseInt();
-- 不可堆叠
	data['noOverlap'] = networkengine:parseBool();

	return data;
end

------------------typedef RowUnitCompatable ----------------------------------
function sendPushRowUnitCompatable(data)
-- 卡牌ID
	networkengine:pushInt(data.id);
-- 军团ID
	local arrayLength = #data.starLevel;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.starLevel) do
		networkengine:pushInt(v);
	end

end

function ParseRowUnitCompatable()
	local tempArrayCount = 0;
	local data = {};

	data['starLevel'] = {};
-- 卡牌ID
	data['id'] = networkengine:parseInt();
-- 军团ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['starLevel'][i] = networkengine:parseInt();
	end

	return data;
end

------------------typedef RowIncidentChance ----------------------------------
function sendPushRowIncidentChance(data)
-- id
	networkengine:pushInt(data.id);
-- 随机范围
	local arrayLength = #data.chance;
	if arrayLength > 64 then arrayLength = 64 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.chance) do
		networkengine:pushInt(v);
	end

end

function ParseRowIncidentChance()
	local tempArrayCount = 0;
	local data = {};

	data['chance'] = {};
-- id
	data['id'] = networkengine:parseInt();
-- 随机范围
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['chance'][i] = networkengine:parseInt();
	end

	return data;
end

------------------typedef RowIncident ----------------------------------
function sendPushRowIncident(data)
-- id
	networkengine:pushInt(data.id);
-- 关卡id
	networkengine:pushInt(data.stageId);
-- 必得奖励类型
	local arrayLength = #data.rewardType;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardType) do
		networkengine:pushInt(v);
	end

-- 必得奖励ID
	local arrayLength = #data.rewardID;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardID) do
		networkengine:pushInt(v);
	end

-- 必得奖励数量
	local arrayLength = #data.rewardCount;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardCount) do
		networkengine:pushInt(v);
	end

-- 时间间隔（秒）
	networkengine:pushInt(data.incidentInterval);
-- 约束条件类别
	networkengine:pushInt(data.condition);
-- 约束条件判断
	networkengine:pushInt(data.compare);
-- 约束条件参数
	networkengine:pushInt(data.argument);
end

function ParseRowIncident()
	local tempArrayCount = 0;
	local data = {};

	data['rewardType'] = {};
	data['rewardID'] = {};
	data['rewardCount'] = {};
-- id
	data['id'] = networkengine:parseInt();
-- 关卡id
	data['stageId'] = networkengine:parseInt();
-- 必得奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardType'][i] = networkengine:parseInt();
	end
-- 必得奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardID'][i] = networkengine:parseInt();
	end
-- 必得奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardCount'][i] = networkengine:parseInt();
	end
-- 时间间隔（秒）
	data['incidentInterval'] = networkengine:parseInt();
-- 约束条件类别
	data['condition'] = networkengine:parseInt();
-- 约束条件判断
	data['compare'] = networkengine:parseInt();
-- 约束条件参数
	data['argument'] = networkengine:parseInt();

	return data;
end

------------------typedef RowGoldMine ----------------------------------
function sendPushRowGoldMine(data)
-- 每小时金币产量
	networkengine:pushInt(data.output);
end

function ParseRowGoldMine()
	local tempArrayCount = 0;
	local data = {};

-- 每小时金币产量
	data['output'] = networkengine:parseInt();

	return data;
end

------------------typedef RowDailyTask ----------------------------------
function sendPushRowDailyTask(data)
-- id
	networkengine:pushInt(data.id);
-- 任务名称
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- 接取所需等级
	networkengine:pushInt(data.level);
-- 经验奖励
	networkengine:pushInt(data.exp);
-- 其他奖励类型
	local arrayLength = #data.rewardType;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardType) do
		networkengine:pushInt(v);
	end

-- 其他奖励ID
	local arrayLength = #data.rewardID;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardID) do
		networkengine:pushInt(v);
	end

-- 其他奖励数量
	local arrayLength = #data.rewardCount;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardCount) do
		networkengine:pushInt(v);
	end

-- 完成条件类型
	networkengine:pushInt(data.finishType);
-- 完成条件参数
	networkengine:pushInt(data.finishParam);
end

function ParseRowDailyTask()
	local tempArrayCount = 0;
	local data = {};

	data['rewardType'] = {};
	data['rewardID'] = {};
	data['rewardCount'] = {};
-- id
	data['id'] = networkengine:parseInt();
-- 任务名称
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 接取所需等级
	data['level'] = networkengine:parseInt();
-- 经验奖励
	data['exp'] = networkengine:parseInt();
-- 其他奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardType'][i] = networkengine:parseInt();
	end
-- 其他奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardID'][i] = networkengine:parseInt();
	end
-- 其他奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardCount'][i] = networkengine:parseInt();
	end
-- 完成条件类型
	data['finishType'] = networkengine:parseInt();
-- 完成条件参数
	data['finishParam'] = networkengine:parseInt();

	return data;
end

------------------typedef RowConfig ----------------------------------
function sendPushRowConfig(data)
-- 无意义
	networkengine:pushInt(data.id);
-- 开服时间
	networkengine:pushInt(string.len(data.openServerData));
	networkengine:pushString(data.openServerData, string.len(data.openServerData));
-- 综合-玩家等级上限
	networkengine:pushInt(data.playerMaxLevel);
-- 综合-军团星级对应的经验值
	local arrayLength = #data.startLevelTable;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.startLevelTable) do
		networkengine:pushInt(v);
	end

-- 综合-魔法星级对应的经验值
	local arrayLength = #data.magicLevelExp;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.magicLevelExp) do
		networkengine:pushInt(v);
	end

-- 综合-初始军团基本体ID
	local arrayLength = #data.bornCardID;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.bornCardID) do
		networkengine:pushInt(v);
	end

-- 综合-初始军团星级
	local arrayLength = #data.bornCardStarLevel;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.bornCardStarLevel) do
		networkengine:pushInt(v);
	end

-- 综合-溢出卡牌碎片转荣誉的倍率
	networkengine:pushInt(data.overflowCardexpToHonor);
-- 综合-初始魔法ID
	local arrayLength = #data.bornMagicID;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.bornMagicID) do
		networkengine:pushInt(v);
	end

-- 综合-初始魔法星级
	local arrayLength = #data.bornMagicStarLevel;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.bornMagicStarLevel) do
		networkengine:pushInt(v);
	end

-- 综合-月卡有效期限
	networkengine:pushInt(data.monthCardDays);
-- 综合-玩家逻辑刷新时间点
	networkengine:pushInt(string.len(data.playerRefleshTime));
	networkengine:pushString(data.playerRefleshTime, string.len(data.playerRefleshTime));
-- 综合-1钻石对应购买的建筑时间（秒）
	networkengine:pushInt(data.diamondCost_upgradeImmediate);
-- 综合-更换名称花费钻石
	networkengine:pushInt(data.renameCost);
-- 战斗平衡性-战斗伤害暴击倍率
	networkengine:pushFloat(data.criticalFactor);
-- 战斗平衡性-战斗基础暴击率
	networkengine:pushFloat(data.baseCritical);
-- 战斗平衡性-每场战斗最多回合数
	networkengine:pushInt(data.maxRounds);
-- 战斗平衡性-远程军团对近身目标的伤害系数
	networkengine:pushFloat(data.damageDistanceRatio);
-- 首充奖励-奖励类型
	local arrayLength = #data.firstChargeRewardType;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.firstChargeRewardType) do
		networkengine:pushInt(v);
	end

-- 首充奖励-奖励ID
	local arrayLength = #data.firstChargeRewardID;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.firstChargeRewardID) do
		networkengine:pushInt(v);
	end

-- 首充奖励-奖励数量
	local arrayLength = #data.firstChargeRewardCount;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.firstChargeRewardCount) do
		networkengine:pushInt(v);
	end

-- 体力-钻石购买获得的体力
	networkengine:pushInt(data.diamondToVigor);
-- 体力-免费领取获得的体力
	networkengine:pushInt(data.freeVigor);
-- 体力-自动恢复间隔（秒）
	networkengine:pushInt(data.vigorRegenerationInterval);
-- 推图-扫荡券ID
	networkengine:pushInt(data.sweepScrollID);
-- 推图-扫荡券每日任务ID
	networkengine:pushInt(data.sweepTaskID);
-- 推图-vip改变扫荡券补偿邮件ID
	networkengine:pushInt(data.sweepCompensateMailID);
-- 推图-完美评价所需最大灭亡数
	networkengine:pushInt(data.adventurePerfectLimit);
-- 推图-精英关卡开启所需普通关卡进度（关数）
	networkengine:pushInt(data.eliteAdventureLimit);
-- Adventure
	local arrayLength = #data.adventure;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.adventure) do
		sendPushAdventure(v);
	end

-- 金矿-钻石购买获得相当于几小时金矿产量的金币
	networkengine:pushInt(data.diamondToGold);
-- 金矿-金矿初始金币（秒）
	networkengine:pushInt(data.goldMineStack);
-- 法师塔-法师塔初始冥想点数（点）
	networkengine:pushInt(data.meditationStack);
-- 每次用钻石购买魔法精华的个数
	networkengine:pushInt(data.diamondToMagicExp);
-- InitialMeditation
	local arrayLength = #data.initialMeditation;
	if arrayLength > 3 then arrayLength = 3 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.initialMeditation) do
		sendPushInitialMeditation(v);
	end

-- 伐木场-伐木场初始原木数
	networkengine:pushInt(data.lumberMillStack);
-- 伐木场-伐木场原木产生间隔（秒）
	networkengine:pushInt(data.lumberMillInterval);
-- 伐木场-木材加工方式出现概率
	local arrayLength = #data.woodToLumber_p;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.woodToLumber_p) do
		networkengine:pushInt(v);
	end

-- 伐木场-加工方式对应的产出系数
	local arrayLength = #data.woodToLumber_output;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.woodToLumber_output) do
		networkengine:pushInt(v);
	end

-- 铁匠铺-装备强化暴击出现概率
	local arrayLength = #data.equipEhanceChance;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.equipEhanceChance) do
		networkengine:pushInt(v);
	end

-- 铁匠铺-装备强化增加的完成度
	local arrayLength = #data.equipEhanceValue;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.equipEhanceValue) do
		networkengine:pushInt(v);
	end

-- 抽卡（军团）-免费抽卡的时间间隔（小时）
	networkengine:pushInt(data.freeDrawInterval);
-- 抽卡（军团）-抽一次消耗钻石数量
	networkengine:pushInt(data.drawOnceCost);
-- 抽卡（军团）-抽十次消耗钻石数量
	networkengine:pushInt(data.drawTentimesCost);
-- 抽卡（军团）-抽军团几次触发防脸黑机制
	networkengine:pushInt(data.cardAwardsNode);
-- 抽卡（军团）-抽卡系统各星级出现概率
	local arrayLength = #data.drawCardProbabilty;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.drawCardProbabilty) do
		networkengine:pushInt(v);
	end

-- InitialDraw
	local arrayLength = #data.initialDraw;
	if arrayLength > 3 then arrayLength = 3 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.initialDraw) do
		sendPushInitialDraw(v);
	end

-- 商店-开启商店功能所需玩家等级
	networkengine:pushInt(data.shopLevelLimit);
-- 商店-商店自动刷新时间点
	local arrayLength = #data.shopRefleshTimes;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.shopRefleshTimes) do
		networkengine:pushInt(string.len(v));
		networkengine:pushString(v, string.len(v));
	end

-- 同步pvp-等级限制
	networkengine:pushInt(data.pvpOnlineLevelLimit);
-- 同步pvp-最多胜利场次
	networkengine:pushInt(data.pvpOnlineWinLimit);
-- 同步pvp-最多失败场次
	networkengine:pushInt(data.pvpOnlineFailLimit);
-- 同步pvp-开始时间
	local arrayLength = #data.pvpBeginTime;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.pvpBeginTime) do
		networkengine:pushInt(string.len(v));
		networkengine:pushString(v, string.len(v));
	end

-- 同步pvp-结束时间
	local arrayLength = #data.pvpEndTime;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.pvpEndTime) do
		networkengine:pushInt(string.len(v));
		networkengine:pushString(v, string.len(v));
	end

-- 同步PVP-奖励发放时间
	networkengine:pushInt(string.len(data.pvpOnlineRewardTime));
	networkengine:pushString(data.pvpOnlineRewardTime, string.len(data.pvpOnlineRewardTime));
-- 同步PVP-容差时间组（秒）
	local arrayLength = #data.pvpTolerance;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.pvpTolerance) do
		networkengine:pushInt(v);
	end

-- 同步PVP匹配CD时间
	networkengine:pushInt(data.pvpOnlineCoolDown);
-- 同步PVP魔法释放超时时间（秒）
	networkengine:pushInt(data.pvpOnlineTimeOut);
-- 同步PVP-邮件文本ID
	networkengine:pushInt(data.pvpOnlineMailStringID);
-- 异步PVP-等级限制
	networkengine:pushInt(data.pvpOfflineLevelLimit);
-- 异步PVP-奖励发放时间
	networkengine:pushInt(string.len(data.pvpOfflineRewardTime));
	networkengine:pushString(data.pvpOfflineRewardTime, string.len(data.pvpOfflineRewardTime));
-- 异步PVP-排行榜保存时间
	networkengine:pushInt(string.len(data.ladderSaveTime));
	networkengine:pushString(data.ladderSaveTime, string.len(data.ladderSaveTime));
-- 异步PVP-挑战次数刷新时间点
	local arrayLength = #data.pvpOfflineRefleshTimes;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.pvpOfflineRefleshTimes) do
		networkengine:pushInt(string.len(v));
		networkengine:pushString(v, string.len(v));
	end

-- 异步PVP-挑战次数
	networkengine:pushInt(data.pvpOfflineFightTimes);
-- 异步PVP-重置挑战次数花费的钻石
	networkengine:pushInt(data.pvpOfflineResetTimes);
-- 异步PVP-挑战冷却时间（秒）
	networkengine:pushInt(data.pvpOfflineCD);
-- 异步PVP-VIP等级大于等于该值时无挑战冷却时间
	networkengine:pushInt(data.pvpOfflineCDVipLevel);
-- 异步PVP-1钻石对应的冷却时间（秒）
	networkengine:pushInt(data.pvpOfflineDiamondCost);
-- 异步PVP-排行榜最低排名
	networkengine:pushInt(data.pvpOfflineMaxRank);
-- 异步PVP-重新匹配按钮的冷却时间（秒）
	networkengine:pushInt(data.pvpOfflineRematchCD);
-- 异步PVP-邮件文本ID
	networkengine:pushInt(data.pvpOfflineMailStringID);
-- 极速挑战-等级限制
	networkengine:pushInt(data.challengeSpeedLevelLimit);
-- 极速挑战-关闭时间
	networkengine:pushInt(string.len(data.challengeSpeedCloseTime));
	networkengine:pushString(data.challengeSpeedCloseTime, string.len(data.challengeSpeedCloseTime));
-- 极速挑战-关卡ID
	local arrayLength = #data.challengeSpeedStageID;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.challengeSpeedStageID) do
		networkengine:pushInt(v);
	end

-- 极速挑战-魔法ID
	local arrayLength = #data.challengeSpeedMagicID;
	if arrayLength > 16 then arrayLength = 16 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.challengeSpeedMagicID) do
		networkengine:pushInt(v);
	end

-- 极速挑战-邮件文本ID
	networkengine:pushInt(data.challengeSpeedMailStringID);
-- 急速挑战-输出日志
	networkengine:pushBool(data.challengeSpeedLog);
-- 伤害排行榜-等级限制
	networkengine:pushInt(data.challengeDamageLevelLimit);
-- 伤害排行榜-关闭时间
	networkengine:pushInt(string.len(data.challengeDamageCloseTime));
	networkengine:pushString(data.challengeDamageCloseTime, string.len(data.challengeDamageCloseTime));
-- 伤害排行榜-每日次数限制
	networkengine:pushInt(data.challengeDamageTimesLimit);
-- 伤害排行榜-关卡ID
	local arrayLength = #data.challengeDamageStageID;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.challengeDamageStageID) do
		networkengine:pushInt(v);
	end

-- 伤害排行版-多少名以前的保存录像
	networkengine:pushInt(data.challengeDamageMaxSaveRank);
-- 伤害排行榜-文本ID
	networkengine:pushInt(data.challengeDamageMailStringID);
-- 伤害排行榜-难度系数
	networkengine:pushFloat(data.challengeDamageDegree);
-- （废弃）副本挑战-每日挑战次数(废弃)
	networkengine:pushInt(data.challengeStageTimesLimit);
-- 副本挑战-挑战冷却时间（秒）
	networkengine:pushInt(data.challengeStageCD);
-- （废弃）兵粮发放时间（废弃）
	local arrayLength = #data.FoodReleaseTime;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.FoodReleaseTime) do
		networkengine:pushInt(v);
	end

-- （废弃）兵粮发放比例（废弃）
	networkengine:pushInt(data.FoodReleaseRatio);
-- 战斗力计算-军团星级系数
	local arrayLength = #data.startLevelRatio;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.startLevelRatio) do
		networkengine:pushFloat(v);
	end

-- 战斗力计算-军团品阶系数
	local arrayLength = #data.classLevelRatio;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.classLevelRatio) do
		networkengine:pushFloat(v);
	end

-- 战斗力计算-魔法星级系数
	local arrayLength = #data.magicLevelRatio;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.magicLevelRatio) do
		networkengine:pushFloat(v);
	end

-- 战斗力计算-战斗力系数A
	networkengine:pushFloat(data.fightingCapacityRatioA);
-- 战斗力计算-战斗力系数B
	networkengine:pushFloat(data.fightingCapacityRatioB);
-- 战斗力计算-战斗力系数C
	networkengine:pushFloat(data.fightingCapacityRatioC);
-- 新手引导-战船自动升级等级界限
	networkengine:pushInt(data.shipAutoLvUpLv);
-- 初始战船位置X
	local arrayLength = #data.initShipPosX;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.initShipPosX) do
		networkengine:pushInt(v);
	end

-- 初始战船位置Y
	local arrayLength = #data.initShipPosY;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.initShipPosY) do
		networkengine:pushInt(v);
	end

-- 拒绝清空时间
	networkengine:pushInt(string.len(data.clearFriendReject));
	networkengine:pushString(data.clearFriendReject, string.len(data.clearFriendReject));
-- 天梯争霸活动结算时间（第一个参数代表开服第几天）
	local arrayLength = #data.limitActivityPvpOfflineStamp;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.limitActivityPvpOfflineStamp) do
		networkengine:pushInt(v);
	end

-- 天梯争霸活动奖励ID组（limitActivity.xls中的ID）
	local arrayLength = #data.limitActivityPvpOfflineID;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.limitActivityPvpOfflineID) do
		networkengine:pushInt(v);
	end

-- 远征装备系数
	networkengine:pushFloat(data.crusadeEquipRatio);
-- 远征计算-军团星级系数
	local arrayLength = #data.starCrusadeRatio;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.starCrusadeRatio) do
		networkengine:pushFloat(v);
	end

-- 远征计算-军团品阶系数
	local arrayLength = #data.classCrusadeRatio;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.classCrusadeRatio) do
		networkengine:pushFloat(v);
	end

-- 远征-开服天数限制
	networkengine:pushInt(data.crusadeDayLimit);
-- 远征-等级限制
	networkengine:pushInt(data.crusadeLevelLimit);
-- 远征-每日关闭时间
	networkengine:pushInt(string.len(data.crusadeCloseTime));
	networkengine:pushString(data.crusadeCloseTime, string.len(data.crusadeCloseTime));
-- 远征-额外奖励条件
	networkengine:pushFloat(data.crusadeExtraCondition);
-- 远征奖励类型
	local arrayLength = #data.crusadeExtraRewardType;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.crusadeExtraRewardType) do
		networkengine:pushInt(v);
	end

-- 远征奖励ID
	local arrayLength = #data.crusadeExtraRewardID;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.crusadeExtraRewardID) do
		networkengine:pushInt(v);
	end

-- 远征奖励数量
	local arrayLength = #data.crusadeExtraRewardCount;
	if arrayLength > 1 then arrayLength = 1 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.crusadeExtraRewardCount) do
		networkengine:pushInt(v);
	end

-- 经验回购-每次购买数量
	networkengine:pushInt(data.redeemExpCount);
-- 免费体力-VIP等级限制
	networkengine:pushInt(data.redeemVigorLimit);
-- 免费体力-返还邮件id
	networkengine:pushInt(data.redeemVigorMailID);
-- 奖励找回-极速挑战VIP等级限制
	networkengine:pushInt(data.redeemChallengeSpeedLimit);
-- 奖励找回-极速挑战返还邮件id
	networkengine:pushInt(data.redeemChallengeSpeedMailID);
-- 奖励找回-急速挑战返还奖励系数
	networkengine:pushFloat(data.redeemChallengeSpeedRatio);
-- 奖励找回-远征VIP等级限制
	networkengine:pushInt(data.redeemCrusadeLimit);
-- 奖励找回-远征返还邮件id
	networkengine:pushInt(data.redeemCrusadeMailID);
-- 奖励找回-远征奖励系数
	networkengine:pushFloat(data.redeemCrusadeRatio);
-- 好友-赠送体力次数
	networkengine:pushInt(data.friendsGiftsVigorTimes);
-- 好友-领取体力次数
	networkengine:pushInt(data.friendsGetVigorTimes);
-- 好友-每次领取体力数量
	networkengine:pushInt(data.friendsVigorCount);
-- 神像系统-开启所需国王等级
	networkengine:pushInt(data.idolLevelLimit);
-- 神像系统-该系统目前开放的最大等级
	networkengine:pushInt(data.idolMaxLevel);
-- 抢夺系统-多少级才能被抢，用于保护新手
	networkengine:pushInt(data.plunderLevelLimit);
-- 抢夺系统-每次刷新期，能抢多少次（一天刷3次呢）
	networkengine:pushInt(data.plunderTimes);
-- 抢夺系统-每次刷新的CD时间，单位为秒
	networkengine:pushInt(data.plunderCollDown);
-- 抢夺系统-能抢到资源的概率（从高到低）
	local arrayLength = #data.plunderProbability;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.plunderProbability) do
		networkengine:pushInt(v);
	end

-- 抢夺胜利必得荣誉点数
	networkengine:pushInt(data.plunderWinHonor);
-- 被抢夺或者复仇之后系统赠予的保护时间
	networkengine:pushInt(data.plunderProtectTime);
-- 抢夺保护时间,每次购买的价格
	networkengine:pushInt(data.purchaseProtectTimePrice);
-- 抢夺保护时间，每次购买的时长（可买多次，累加）
	networkengine:pushInt(data.purchaseProtectTime);
-- 微信签到-七日签到奖励返还邮件id
	networkengine:pushInt(data.signInMailID);
-- 微信签到-首次签到奖励返还邮件id
	networkengine:pushInt(data.firstSignInMailID);
-- 微信签到-七日连续签到奖励返还邮件id
	networkengine:pushInt(data.continuousSignInMailID);
-- 摇红包开启时间
	networkengine:pushInt(string.len(data.redEnvelopeOpenTime));
	networkengine:pushString(data.redEnvelopeOpenTime, string.len(data.redEnvelopeOpenTime));
-- 摇红包结束时间
	networkengine:pushInt(string.len(data.redEnvelopeCloseTime));
	networkengine:pushString(data.redEnvelopeCloseTime, string.len(data.redEnvelopeCloseTime));
-- 摇红包等级限制
	networkengine:pushInt(data.redEnvelopeLevelLimit);
-- 摇红包奖金段控制
	local arrayLength = #data.redEnvelopeLotteryLimit;
	if arrayLength > 16 then arrayLength = 16 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.redEnvelopeLotteryLimit) do
		networkengine:pushFloat(v);
	end

-- 摇红包邮件ID
	networkengine:pushInt(data.redEnvelopeMailID);
-- 公会-开启等级
	networkengine:pushInt(data.guildLevelLimit);
-- 公会-创建公会所需钻石数量
	networkengine:pushInt(data.createGuildPrice);
-- 公会-人数上限
	networkengine:pushInt(data.guildPeopleLimit);
-- 公会-金币签到奖励数量
	networkengine:pushInt(data.guildSignInGoldRewardCount);
-- 公会-申请列表人数限制
	networkengine:pushInt(data.guildApplicationListPeopleLimit);
-- 公会开始时间
	networkengine:pushInt(string.len(data.guildWarBegin));
	networkengine:pushString(data.guildWarBegin, string.len(data.guildWarBegin));
-- 公会结束时间
	networkengine:pushInt(string.len(data.guildWarFinish));
	networkengine:pushString(data.guildWarFinish, string.len(data.guildWarFinish));
-- 公会战成员最多攻击次数
	networkengine:pushInt(data.guildMaxFightCount);
-- 公会中长老的最大人数
	networkengine:pushInt(data.guildMaxMangers);
-- 公会战进攻鼓舞增加军团数量
	networkengine:pushInt(data.guildWarBuffAtk);
-- 公会战防御鼓舞增加军团数量
	networkengine:pushInt(data.guildWarBuffDef);
-- 据点击破奖励会阶系数加成
	local arrayLength = #data.guildWarTypeRat;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.guildWarTypeRat) do
		networkengine:pushInt(v);
	end

-- 公会战开启条件，开服第几天
	networkengine:pushInt(data.guildWarOpenDays);
-- 公会战鼓舞最大次数（攻防次数最大都这个）
	networkengine:pushInt(data.guildWarInspireTime);
-- 公会战结束邮件id
	networkengine:pushInt(data.guildWarRewardMailID);
-- 公会战击破据点奖励
	networkengine:pushInt(data.guildWarBreakPostMailID);
-- 公会日志-公会会长
	networkengine:pushInt(string.len(data.guildLeaderName));
	networkengine:pushString(data.guildLeaderName, string.len(data.guildLeaderName));
-- 公会日志-公会长老
	networkengine:pushInt(string.len(data.guildManagerName));
	networkengine:pushString(data.guildManagerName, string.len(data.guildManagerName));
-- 公会日志-公会会员
	networkengine:pushInt(string.len(data.guildMemberName));
	networkengine:pushString(data.guildMemberName, string.len(data.guildMemberName));
end

function ParseRowConfig()
	local tempArrayCount = 0;
	local data = {};

	data['startLevelTable'] = {};
	data['magicLevelExp'] = {};
	data['bornCardID'] = {};
	data['bornCardStarLevel'] = {};
	data['bornMagicID'] = {};
	data['bornMagicStarLevel'] = {};
	data['firstChargeRewardType'] = {};
	data['firstChargeRewardID'] = {};
	data['firstChargeRewardCount'] = {};
	data['adventure'] = {};
	data['initialMeditation'] = {};
	data['woodToLumber_p'] = {};
	data['woodToLumber_output'] = {};
	data['equipEhanceChance'] = {};
	data['equipEhanceValue'] = {};
	data['drawCardProbabilty'] = {};
	data['initialDraw'] = {};
	data['shopRefleshTimes'] = {};
	data['pvpBeginTime'] = {};
	data['pvpEndTime'] = {};
	data['pvpTolerance'] = {};
	data['pvpOfflineRefleshTimes'] = {};
	data['challengeSpeedStageID'] = {};
	data['challengeSpeedMagicID'] = {};
	data['challengeDamageStageID'] = {};
	data['FoodReleaseTime'] = {};
	data['startLevelRatio'] = {};
	data['classLevelRatio'] = {};
	data['magicLevelRatio'] = {};
	data['initShipPosX'] = {};
	data['initShipPosY'] = {};
	data['limitActivityPvpOfflineStamp'] = {};
	data['limitActivityPvpOfflineID'] = {};
	data['starCrusadeRatio'] = {};
	data['classCrusadeRatio'] = {};
	data['crusadeExtraRewardType'] = {};
	data['crusadeExtraRewardID'] = {};
	data['crusadeExtraRewardCount'] = {};
	data['plunderProbability'] = {};
	data['redEnvelopeLotteryLimit'] = {};
	data['guildWarTypeRat'] = {};
-- 无意义
	data['id'] = networkengine:parseInt();
-- 开服时间
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['openServerData'] = networkengine:parseString(strlength);
else
		data['openServerData'] = "";
end
-- 综合-玩家等级上限
	data['playerMaxLevel'] = networkengine:parseInt();
-- 综合-军团星级对应的经验值
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['startLevelTable'][i] = networkengine:parseInt();
	end
-- 综合-魔法星级对应的经验值
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['magicLevelExp'][i] = networkengine:parseInt();
	end
-- 综合-初始军团基本体ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['bornCardID'][i] = networkengine:parseInt();
	end
-- 综合-初始军团星级
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['bornCardStarLevel'][i] = networkengine:parseInt();
	end
-- 综合-溢出卡牌碎片转荣誉的倍率
	data['overflowCardexpToHonor'] = networkengine:parseInt();
-- 综合-初始魔法ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['bornMagicID'][i] = networkengine:parseInt();
	end
-- 综合-初始魔法星级
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['bornMagicStarLevel'][i] = networkengine:parseInt();
	end
-- 综合-月卡有效期限
	data['monthCardDays'] = networkengine:parseInt();
-- 综合-玩家逻辑刷新时间点
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['playerRefleshTime'] = networkengine:parseString(strlength);
else
		data['playerRefleshTime'] = "";
end
-- 综合-1钻石对应购买的建筑时间（秒）
	data['diamondCost_upgradeImmediate'] = networkengine:parseInt();
-- 综合-更换名称花费钻石
	data['renameCost'] = networkengine:parseInt();
-- 战斗平衡性-战斗伤害暴击倍率
	data['criticalFactor'] = networkengine:parseFloat();
-- 战斗平衡性-战斗基础暴击率
	data['baseCritical'] = networkengine:parseFloat();
-- 战斗平衡性-每场战斗最多回合数
	data['maxRounds'] = networkengine:parseInt();
-- 战斗平衡性-远程军团对近身目标的伤害系数
	data['damageDistanceRatio'] = networkengine:parseFloat();
-- 首充奖励-奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['firstChargeRewardType'][i] = networkengine:parseInt();
	end
-- 首充奖励-奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['firstChargeRewardID'][i] = networkengine:parseInt();
	end
-- 首充奖励-奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['firstChargeRewardCount'][i] = networkengine:parseInt();
	end
-- 体力-钻石购买获得的体力
	data['diamondToVigor'] = networkengine:parseInt();
-- 体力-免费领取获得的体力
	data['freeVigor'] = networkengine:parseInt();
-- 体力-自动恢复间隔（秒）
	data['vigorRegenerationInterval'] = networkengine:parseInt();
-- 推图-扫荡券ID
	data['sweepScrollID'] = networkengine:parseInt();
-- 推图-扫荡券每日任务ID
	data['sweepTaskID'] = networkengine:parseInt();
-- 推图-vip改变扫荡券补偿邮件ID
	data['sweepCompensateMailID'] = networkengine:parseInt();
-- 推图-完美评价所需最大灭亡数
	data['adventurePerfectLimit'] = networkengine:parseInt();
-- 推图-精英关卡开启所需普通关卡进度（关数）
	data['eliteAdventureLimit'] = networkengine:parseInt();
-- Adventure
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['adventure'][i] = ParseAdventure();
	end
-- 金矿-钻石购买获得相当于几小时金矿产量的金币
	data['diamondToGold'] = networkengine:parseInt();
-- 金矿-金矿初始金币（秒）
	data['goldMineStack'] = networkengine:parseInt();
-- 法师塔-法师塔初始冥想点数（点）
	data['meditationStack'] = networkengine:parseInt();
-- 每次用钻石购买魔法精华的个数
	data['diamondToMagicExp'] = networkengine:parseInt();
-- InitialMeditation
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['initialMeditation'][i] = ParseInitialMeditation();
	end
-- 伐木场-伐木场初始原木数
	data['lumberMillStack'] = networkengine:parseInt();
-- 伐木场-伐木场原木产生间隔（秒）
	data['lumberMillInterval'] = networkengine:parseInt();
-- 伐木场-木材加工方式出现概率
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['woodToLumber_p'][i] = networkengine:parseInt();
	end
-- 伐木场-加工方式对应的产出系数
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['woodToLumber_output'][i] = networkengine:parseInt();
	end
-- 铁匠铺-装备强化暴击出现概率
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['equipEhanceChance'][i] = networkengine:parseInt();
	end
-- 铁匠铺-装备强化增加的完成度
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['equipEhanceValue'][i] = networkengine:parseInt();
	end
-- 抽卡（军团）-免费抽卡的时间间隔（小时）
	data['freeDrawInterval'] = networkengine:parseInt();
-- 抽卡（军团）-抽一次消耗钻石数量
	data['drawOnceCost'] = networkengine:parseInt();
-- 抽卡（军团）-抽十次消耗钻石数量
	data['drawTentimesCost'] = networkengine:parseInt();
-- 抽卡（军团）-抽军团几次触发防脸黑机制
	data['cardAwardsNode'] = networkengine:parseInt();
-- 抽卡（军团）-抽卡系统各星级出现概率
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['drawCardProbabilty'][i] = networkengine:parseInt();
	end
-- InitialDraw
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['initialDraw'][i] = ParseInitialDraw();
	end
-- 商店-开启商店功能所需玩家等级
	data['shopLevelLimit'] = networkengine:parseInt();
-- 商店-商店自动刷新时间点
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
	local strlength = networkengine:parseInt();
if strlength > 0 then
			data['shopRefleshTimes'][i] = networkengine:parseString(strlength);
else
			data['shopRefleshTimes'][i] = "";
end
	end
-- 同步pvp-等级限制
	data['pvpOnlineLevelLimit'] = networkengine:parseInt();
-- 同步pvp-最多胜利场次
	data['pvpOnlineWinLimit'] = networkengine:parseInt();
-- 同步pvp-最多失败场次
	data['pvpOnlineFailLimit'] = networkengine:parseInt();
-- 同步pvp-开始时间
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
	local strlength = networkengine:parseInt();
if strlength > 0 then
			data['pvpBeginTime'][i] = networkengine:parseString(strlength);
else
			data['pvpBeginTime'][i] = "";
end
	end
-- 同步pvp-结束时间
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
	local strlength = networkengine:parseInt();
if strlength > 0 then
			data['pvpEndTime'][i] = networkengine:parseString(strlength);
else
			data['pvpEndTime'][i] = "";
end
	end
-- 同步PVP-奖励发放时间
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['pvpOnlineRewardTime'] = networkengine:parseString(strlength);
else
		data['pvpOnlineRewardTime'] = "";
end
-- 同步PVP-容差时间组（秒）
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['pvpTolerance'][i] = networkengine:parseInt();
	end
-- 同步PVP匹配CD时间
	data['pvpOnlineCoolDown'] = networkengine:parseInt();
-- 同步PVP魔法释放超时时间（秒）
	data['pvpOnlineTimeOut'] = networkengine:parseInt();
-- 同步PVP-邮件文本ID
	data['pvpOnlineMailStringID'] = networkengine:parseInt();
-- 异步PVP-等级限制
	data['pvpOfflineLevelLimit'] = networkengine:parseInt();
-- 异步PVP-奖励发放时间
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['pvpOfflineRewardTime'] = networkengine:parseString(strlength);
else
		data['pvpOfflineRewardTime'] = "";
end
-- 异步PVP-排行榜保存时间
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['ladderSaveTime'] = networkengine:parseString(strlength);
else
		data['ladderSaveTime'] = "";
end
-- 异步PVP-挑战次数刷新时间点
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
	local strlength = networkengine:parseInt();
if strlength > 0 then
			data['pvpOfflineRefleshTimes'][i] = networkengine:parseString(strlength);
else
			data['pvpOfflineRefleshTimes'][i] = "";
end
	end
-- 异步PVP-挑战次数
	data['pvpOfflineFightTimes'] = networkengine:parseInt();
-- 异步PVP-重置挑战次数花费的钻石
	data['pvpOfflineResetTimes'] = networkengine:parseInt();
-- 异步PVP-挑战冷却时间（秒）
	data['pvpOfflineCD'] = networkengine:parseInt();
-- 异步PVP-VIP等级大于等于该值时无挑战冷却时间
	data['pvpOfflineCDVipLevel'] = networkengine:parseInt();
-- 异步PVP-1钻石对应的冷却时间（秒）
	data['pvpOfflineDiamondCost'] = networkengine:parseInt();
-- 异步PVP-排行榜最低排名
	data['pvpOfflineMaxRank'] = networkengine:parseInt();
-- 异步PVP-重新匹配按钮的冷却时间（秒）
	data['pvpOfflineRematchCD'] = networkengine:parseInt();
-- 异步PVP-邮件文本ID
	data['pvpOfflineMailStringID'] = networkengine:parseInt();
-- 极速挑战-等级限制
	data['challengeSpeedLevelLimit'] = networkengine:parseInt();
-- 极速挑战-关闭时间
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['challengeSpeedCloseTime'] = networkengine:parseString(strlength);
else
		data['challengeSpeedCloseTime'] = "";
end
-- 极速挑战-关卡ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['challengeSpeedStageID'][i] = networkengine:parseInt();
	end
-- 极速挑战-魔法ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['challengeSpeedMagicID'][i] = networkengine:parseInt();
	end
-- 极速挑战-邮件文本ID
	data['challengeSpeedMailStringID'] = networkengine:parseInt();
-- 急速挑战-输出日志
	data['challengeSpeedLog'] = networkengine:parseBool();
-- 伤害排行榜-等级限制
	data['challengeDamageLevelLimit'] = networkengine:parseInt();
-- 伤害排行榜-关闭时间
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['challengeDamageCloseTime'] = networkengine:parseString(strlength);
else
		data['challengeDamageCloseTime'] = "";
end
-- 伤害排行榜-每日次数限制
	data['challengeDamageTimesLimit'] = networkengine:parseInt();
-- 伤害排行榜-关卡ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['challengeDamageStageID'][i] = networkengine:parseInt();
	end
-- 伤害排行版-多少名以前的保存录像
	data['challengeDamageMaxSaveRank'] = networkengine:parseInt();
-- 伤害排行榜-文本ID
	data['challengeDamageMailStringID'] = networkengine:parseInt();
-- 伤害排行榜-难度系数
	data['challengeDamageDegree'] = networkengine:parseFloat();
-- （废弃）副本挑战-每日挑战次数(废弃)
	data['challengeStageTimesLimit'] = networkengine:parseInt();
-- 副本挑战-挑战冷却时间（秒）
	data['challengeStageCD'] = networkengine:parseInt();
-- （废弃）兵粮发放时间（废弃）
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['FoodReleaseTime'][i] = networkengine:parseInt();
	end
-- （废弃）兵粮发放比例（废弃）
	data['FoodReleaseRatio'] = networkengine:parseInt();
-- 战斗力计算-军团星级系数
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['startLevelRatio'][i] = networkengine:parseFloat();
	end
-- 战斗力计算-军团品阶系数
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['classLevelRatio'][i] = networkengine:parseFloat();
	end
-- 战斗力计算-魔法星级系数
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['magicLevelRatio'][i] = networkengine:parseFloat();
	end
-- 战斗力计算-战斗力系数A
	data['fightingCapacityRatioA'] = networkengine:parseFloat();
-- 战斗力计算-战斗力系数B
	data['fightingCapacityRatioB'] = networkengine:parseFloat();
-- 战斗力计算-战斗力系数C
	data['fightingCapacityRatioC'] = networkengine:parseFloat();
-- 新手引导-战船自动升级等级界限
	data['shipAutoLvUpLv'] = networkengine:parseInt();
-- 初始战船位置X
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['initShipPosX'][i] = networkengine:parseInt();
	end
-- 初始战船位置Y
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['initShipPosY'][i] = networkengine:parseInt();
	end
-- 拒绝清空时间
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['clearFriendReject'] = networkengine:parseString(strlength);
else
		data['clearFriendReject'] = "";
end
-- 天梯争霸活动结算时间（第一个参数代表开服第几天）
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['limitActivityPvpOfflineStamp'][i] = networkengine:parseInt();
	end
-- 天梯争霸活动奖励ID组（limitActivity.xls中的ID）
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['limitActivityPvpOfflineID'][i] = networkengine:parseInt();
	end
-- 远征装备系数
	data['crusadeEquipRatio'] = networkengine:parseFloat();
-- 远征计算-军团星级系数
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['starCrusadeRatio'][i] = networkengine:parseFloat();
	end
-- 远征计算-军团品阶系数
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['classCrusadeRatio'][i] = networkengine:parseFloat();
	end
-- 远征-开服天数限制
	data['crusadeDayLimit'] = networkengine:parseInt();
-- 远征-等级限制
	data['crusadeLevelLimit'] = networkengine:parseInt();
-- 远征-每日关闭时间
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['crusadeCloseTime'] = networkengine:parseString(strlength);
else
		data['crusadeCloseTime'] = "";
end
-- 远征-额外奖励条件
	data['crusadeExtraCondition'] = networkengine:parseFloat();
-- 远征奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['crusadeExtraRewardType'][i] = networkengine:parseInt();
	end
-- 远征奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['crusadeExtraRewardID'][i] = networkengine:parseInt();
	end
-- 远征奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['crusadeExtraRewardCount'][i] = networkengine:parseInt();
	end
-- 经验回购-每次购买数量
	data['redeemExpCount'] = networkengine:parseInt();
-- 免费体力-VIP等级限制
	data['redeemVigorLimit'] = networkengine:parseInt();
-- 免费体力-返还邮件id
	data['redeemVigorMailID'] = networkengine:parseInt();
-- 奖励找回-极速挑战VIP等级限制
	data['redeemChallengeSpeedLimit'] = networkengine:parseInt();
-- 奖励找回-极速挑战返还邮件id
	data['redeemChallengeSpeedMailID'] = networkengine:parseInt();
-- 奖励找回-急速挑战返还奖励系数
	data['redeemChallengeSpeedRatio'] = networkengine:parseFloat();
-- 奖励找回-远征VIP等级限制
	data['redeemCrusadeLimit'] = networkengine:parseInt();
-- 奖励找回-远征返还邮件id
	data['redeemCrusadeMailID'] = networkengine:parseInt();
-- 奖励找回-远征奖励系数
	data['redeemCrusadeRatio'] = networkengine:parseFloat();
-- 好友-赠送体力次数
	data['friendsGiftsVigorTimes'] = networkengine:parseInt();
-- 好友-领取体力次数
	data['friendsGetVigorTimes'] = networkengine:parseInt();
-- 好友-每次领取体力数量
	data['friendsVigorCount'] = networkengine:parseInt();
-- 神像系统-开启所需国王等级
	data['idolLevelLimit'] = networkengine:parseInt();
-- 神像系统-该系统目前开放的最大等级
	data['idolMaxLevel'] = networkengine:parseInt();
-- 抢夺系统-多少级才能被抢，用于保护新手
	data['plunderLevelLimit'] = networkengine:parseInt();
-- 抢夺系统-每次刷新期，能抢多少次（一天刷3次呢）
	data['plunderTimes'] = networkengine:parseInt();
-- 抢夺系统-每次刷新的CD时间，单位为秒
	data['plunderCollDown'] = networkengine:parseInt();
-- 抢夺系统-能抢到资源的概率（从高到低）
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['plunderProbability'][i] = networkengine:parseInt();
	end
-- 抢夺胜利必得荣誉点数
	data['plunderWinHonor'] = networkengine:parseInt();
-- 被抢夺或者复仇之后系统赠予的保护时间
	data['plunderProtectTime'] = networkengine:parseInt();
-- 抢夺保护时间,每次购买的价格
	data['purchaseProtectTimePrice'] = networkengine:parseInt();
-- 抢夺保护时间，每次购买的时长（可买多次，累加）
	data['purchaseProtectTime'] = networkengine:parseInt();
-- 微信签到-七日签到奖励返还邮件id
	data['signInMailID'] = networkengine:parseInt();
-- 微信签到-首次签到奖励返还邮件id
	data['firstSignInMailID'] = networkengine:parseInt();
-- 微信签到-七日连续签到奖励返还邮件id
	data['continuousSignInMailID'] = networkengine:parseInt();
-- 摇红包开启时间
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['redEnvelopeOpenTime'] = networkengine:parseString(strlength);
else
		data['redEnvelopeOpenTime'] = "";
end
-- 摇红包结束时间
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['redEnvelopeCloseTime'] = networkengine:parseString(strlength);
else
		data['redEnvelopeCloseTime'] = "";
end
-- 摇红包等级限制
	data['redEnvelopeLevelLimit'] = networkengine:parseInt();
-- 摇红包奖金段控制
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['redEnvelopeLotteryLimit'][i] = networkengine:parseFloat();
	end
-- 摇红包邮件ID
	data['redEnvelopeMailID'] = networkengine:parseInt();
-- 公会-开启等级
	data['guildLevelLimit'] = networkengine:parseInt();
-- 公会-创建公会所需钻石数量
	data['createGuildPrice'] = networkengine:parseInt();
-- 公会-人数上限
	data['guildPeopleLimit'] = networkengine:parseInt();
-- 公会-金币签到奖励数量
	data['guildSignInGoldRewardCount'] = networkengine:parseInt();
-- 公会-申请列表人数限制
	data['guildApplicationListPeopleLimit'] = networkengine:parseInt();
-- 公会开始时间
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['guildWarBegin'] = networkengine:parseString(strlength);
else
		data['guildWarBegin'] = "";
end
-- 公会结束时间
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['guildWarFinish'] = networkengine:parseString(strlength);
else
		data['guildWarFinish'] = "";
end
-- 公会战成员最多攻击次数
	data['guildMaxFightCount'] = networkengine:parseInt();
-- 公会中长老的最大人数
	data['guildMaxMangers'] = networkengine:parseInt();
-- 公会战进攻鼓舞增加军团数量
	data['guildWarBuffAtk'] = networkengine:parseInt();
-- 公会战防御鼓舞增加军团数量
	data['guildWarBuffDef'] = networkengine:parseInt();
-- 据点击破奖励会阶系数加成
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['guildWarTypeRat'][i] = networkengine:parseInt();
	end
-- 公会战开启条件，开服第几天
	data['guildWarOpenDays'] = networkengine:parseInt();
-- 公会战鼓舞最大次数（攻防次数最大都这个）
	data['guildWarInspireTime'] = networkengine:parseInt();
-- 公会战结束邮件id
	data['guildWarRewardMailID'] = networkengine:parseInt();
-- 公会战击破据点奖励
	data['guildWarBreakPostMailID'] = networkengine:parseInt();
-- 公会日志-公会会长
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['guildLeaderName'] = networkengine:parseString(strlength);
else
		data['guildLeaderName'] = "";
end
-- 公会日志-公会长老
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['guildManagerName'] = networkengine:parseString(strlength);
else
		data['guildManagerName'] = "";
end
-- 公会日志-公会会员
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['guildMemberName'] = networkengine:parseString(strlength);
else
		data['guildMemberName'] = "";
end

	return data;
end

------------------typedef RowChapter ----------------------------------
function sendPushRowChapter(data)
-- 序号
	networkengine:pushInt(data.id);
-- 关卡节点
	networkengine:pushInt(data.adventureID);
-- ChapterRewardList
	local arrayLength = #data.chapterRewardList;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.chapterRewardList) do
		sendPushChapterRewardList(v);
	end

end

function ParseRowChapter()
	local tempArrayCount = 0;
	local data = {};

	data['chapterRewardList'] = {};
-- 序号
	data['id'] = networkengine:parseInt();
-- 关卡节点
	data['adventureID'] = networkengine:parseInt();
-- ChapterRewardList
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['chapterRewardList'][i] = ParseChapterRewardList();
	end

	return data;
end

------------------typedef RowChallengeSpeed ----------------------------------
function sendPushRowChallengeSpeed(data)
-- id
	networkengine:pushInt(data.id);
-- 排名
	networkengine:pushInt(data.rank);
-- 必得奖励类型
	local arrayLength = #data.rewardType;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardType) do
		networkengine:pushInt(v);
	end

-- 必得奖励ID
	local arrayLength = #data.rewardID;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardID) do
		networkengine:pushInt(v);
	end

-- 必得奖励数量
	local arrayLength = #data.rewardCount;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardCount) do
		networkengine:pushInt(v);
	end

end

function ParseRowChallengeSpeed()
	local tempArrayCount = 0;
	local data = {};

	data['rewardType'] = {};
	data['rewardID'] = {};
	data['rewardCount'] = {};
-- id
	data['id'] = networkengine:parseInt();
-- 排名
	data['rank'] = networkengine:parseInt();
-- 必得奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardType'][i] = networkengine:parseInt();
	end
-- 必得奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardID'][i] = networkengine:parseInt();
	end
-- 必得奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardCount'][i] = networkengine:parseInt();
	end

	return data;
end

------------------typedef RowChallengeDamage ----------------------------------
function sendPushRowChallengeDamage(data)
-- id
	networkengine:pushInt(data.id);
-- 排名
	networkengine:pushInt(data.rank);
-- 必得奖励类型
	local arrayLength = #data.rewardType;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardType) do
		networkengine:pushInt(v);
	end

-- 必得奖励ID
	local arrayLength = #data.rewardID;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardID) do
		networkengine:pushInt(v);
	end

-- 必得奖励数量
	local arrayLength = #data.rewardCount;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.rewardCount) do
		networkengine:pushInt(v);
	end

end

function ParseRowChallengeDamage()
	local tempArrayCount = 0;
	local data = {};

	data['rewardType'] = {};
	data['rewardID'] = {};
	data['rewardCount'] = {};
-- id
	data['id'] = networkengine:parseInt();
-- 排名
	data['rank'] = networkengine:parseInt();
-- 必得奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardType'][i] = networkengine:parseInt();
	end
-- 必得奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardID'][i] = networkengine:parseInt();
	end
-- 必得奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['rewardCount'][i] = networkengine:parseInt();
	end

	return data;
end

------------------typedef RowBuff ----------------------------------
function sendPushRowBuff(data)
-- ID
	networkengine:pushInt(data.id);
-- 场景名
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- Buff影响类型
	networkengine:pushInt(data.type);
-- 减持续时刻
	networkengine:pushInt(data.moment);
-- 最大层数
	networkengine:pushInt(data.maxOverlapCount);
-- 正负状态类型
	networkengine:pushInt(data.buffFlag);
-- 不可驱散
	networkengine:pushBool(data.disperse);
-- 濒死消失
	networkengine:pushBool(data.dieDisappear);
-- 死透了消失
	networkengine:pushBool(data.absoluteDieDisappear);
-- 受伤消失
	networkengine:pushBool(data.injuredDisappear);
-- 施法者死亡消失
	networkengine:pushBool(data.casterDieDisappear);
-- 递增型
	networkengine:pushBool(data.increase);
-- 新的覆盖老的
	networkengine:pushBool(data.override);
-- 标签
	networkengine:pushInt(data.tag);
-- 特殊属性
	networkengine:pushInt(data.special);
-- 携带技能
	networkengine:pushBool(data.addskill);
-- 持续加血
	networkengine:pushBool(data.hot);
-- 持续伤害
	networkengine:pushInt(data.dot);
-- 属性1
	networkengine:pushInt(data.attr1);
-- 属性百分比1
	networkengine:pushInt(data.percent1);
-- 状态1
	networkengine:pushInt(data.status1);
-- 属性2
	networkengine:pushInt(data.attr2);
-- 属性百分比2
	networkengine:pushInt(data.percent2);
-- 状态2
	networkengine:pushInt(data.status2);
-- 属性3
	networkengine:pushInt(data.attr3);
-- 属性百分比3
	networkengine:pushInt(data.percent3);
-- 状态3
	networkengine:pushInt(data.status3);
-- 属性4
	networkengine:pushInt(data.attr4);
-- 属性百分比4
	networkengine:pushInt(data.percent4);
-- 状态4
	networkengine:pushInt(data.status4);
end

function ParseRowBuff()
	local tempArrayCount = 0;
	local data = {};

-- ID
	data['id'] = networkengine:parseInt();
-- 场景名
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- Buff影响类型
	data['type'] = networkengine:parseInt();
-- 减持续时刻
	data['moment'] = networkengine:parseInt();
-- 最大层数
	data['maxOverlapCount'] = networkengine:parseInt();
-- 正负状态类型
	data['buffFlag'] = networkengine:parseInt();
-- 不可驱散
	data['disperse'] = networkengine:parseBool();
-- 濒死消失
	data['dieDisappear'] = networkengine:parseBool();
-- 死透了消失
	data['absoluteDieDisappear'] = networkengine:parseBool();
-- 受伤消失
	data['injuredDisappear'] = networkengine:parseBool();
-- 施法者死亡消失
	data['casterDieDisappear'] = networkengine:parseBool();
-- 递增型
	data['increase'] = networkengine:parseBool();
-- 新的覆盖老的
	data['override'] = networkengine:parseBool();
-- 标签
	data['tag'] = networkengine:parseInt();
-- 特殊属性
	data['special'] = networkengine:parseInt();
-- 携带技能
	data['addskill'] = networkengine:parseBool();
-- 持续加血
	data['hot'] = networkengine:parseBool();
-- 持续伤害
	data['dot'] = networkengine:parseInt();
-- 属性1
	data['attr1'] = networkengine:parseInt();
-- 属性百分比1
	data['percent1'] = networkengine:parseInt();
-- 状态1
	data['status1'] = networkengine:parseInt();
-- 属性2
	data['attr2'] = networkengine:parseInt();
-- 属性百分比2
	data['percent2'] = networkengine:parseInt();
-- 状态2
	data['status2'] = networkengine:parseInt();
-- 属性3
	data['attr3'] = networkengine:parseInt();
-- 属性百分比3
	data['percent3'] = networkengine:parseInt();
-- 状态3
	data['status3'] = networkengine:parseInt();
-- 属性4
	data['attr4'] = networkengine:parseInt();
-- 属性百分比4
	data['percent4'] = networkengine:parseInt();
-- 状态4
	data['status4'] = networkengine:parseInt();

	return data;
end

------------------typedef RowAura ----------------------------------
function sendPushRowAura(data)
-- ID
	networkengine:pushInt(data.id);
-- 场景名
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- 光环类型
	networkengine:pushInt(data.type);
-- 范围
	networkengine:pushInt(data.range);
-- 敌我筛选
	networkengine:pushInt(data.forceSelect);
-- 种族筛选
	networkengine:pushInt(data.raceSelect);
-- 近远程筛选
	networkengine:pushInt(data.rangeSelect);
-- 移动类型筛选
	networkengine:pushInt(data.moveTypeSelect);
-- 伤害类型筛选
	networkengine:pushInt(data.damageTypeSelect);
-- 携带技能
	networkengine:pushBool(data.addskill);
-- 属性1
	networkengine:pushInt(data.attr1);
-- 属性百分比1
	networkengine:pushInt(data.percent1);
-- 状态1
	networkengine:pushInt(data.status1);
-- 属性2
	networkengine:pushInt(data.attr2);
-- 属性百分比2
	networkengine:pushInt(data.percent2);
-- 状态2
	networkengine:pushInt(data.status2);
-- 属性3
	networkengine:pushInt(data.attr3);
-- 属性百分比3
	networkengine:pushInt(data.percent3);
-- 状态3
	networkengine:pushInt(data.status3);
-- 属性4
	networkengine:pushInt(data.attr4);
-- 属性百分比4
	networkengine:pushInt(data.percent4);
-- 状态4
	networkengine:pushInt(data.status4);
end

function ParseRowAura()
	local tempArrayCount = 0;
	local data = {};

-- ID
	data['id'] = networkengine:parseInt();
-- 场景名
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 光环类型
	data['type'] = networkengine:parseInt();
-- 范围
	data['range'] = networkengine:parseInt();
-- 敌我筛选
	data['forceSelect'] = networkengine:parseInt();
-- 种族筛选
	data['raceSelect'] = networkengine:parseInt();
-- 近远程筛选
	data['rangeSelect'] = networkengine:parseInt();
-- 移动类型筛选
	data['moveTypeSelect'] = networkengine:parseInt();
-- 伤害类型筛选
	data['damageTypeSelect'] = networkengine:parseInt();
-- 携带技能
	data['addskill'] = networkengine:parseBool();
-- 属性1
	data['attr1'] = networkengine:parseInt();
-- 属性百分比1
	data['percent1'] = networkengine:parseInt();
-- 状态1
	data['status1'] = networkengine:parseInt();
-- 属性2
	data['attr2'] = networkengine:parseInt();
-- 属性百分比2
	data['percent2'] = networkengine:parseInt();
-- 状态2
	data['status2'] = networkengine:parseInt();
-- 属性3
	data['attr3'] = networkengine:parseInt();
-- 属性百分比3
	data['percent3'] = networkengine:parseInt();
-- 状态3
	data['status3'] = networkengine:parseInt();
-- 属性4
	data['attr4'] = networkengine:parseInt();
-- 属性百分比4
	data['percent4'] = networkengine:parseInt();
-- 状态4
	data['status4'] = networkengine:parseInt();

	return data;
end

------------------typedef RowAdventure ----------------------------------
function sendPushRowAdventure(data)
-- 序号
	networkengine:pushInt(data.id);
-- Limit
	local arrayLength = #data.limit;
	if arrayLength > 2 then arrayLength = 2 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.limit) do
		sendPushLimit(v);
	end

-- 是主要关卡
	networkengine:pushBool(data.isMain);
-- 对话_进入备战前
	networkengine:pushInt(data.textPrepare);
-- 对话_开战时
	networkengine:pushInt(data.textBefore);
-- 对话_战斗胜利后
	networkengine:pushInt(data.testAfter);
end

function ParseRowAdventure()
	local tempArrayCount = 0;
	local data = {};

	data['limit'] = {};
-- 序号
	data['id'] = networkengine:parseInt();
-- Limit
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['limit'][i] = ParseLimit();
	end
-- 是主要关卡
	data['isMain'] = networkengine:parseBool();
-- 对话_进入备战前
	data['textPrepare'] = networkengine:parseInt();
-- 对话_开战时
	data['textBefore'] = networkengine:parseInt();
-- 对话_战斗胜利后
	data['testAfter'] = networkengine:parseInt();

	return data;
end

------------------typedef RowVip ----------------------------------
function sendPushRowVip(data)
-- VIP等级
	networkengine:pushInt(data.id);
-- 充值界限(分)
	networkengine:pushInt(data.rmb);
-- 每日可买体力次数
	networkengine:pushInt(data.buyVigorTimes);
-- 每日可买金币次数
	networkengine:pushInt(data.buyGoldTimes);
-- 每日可买木材次数
	networkengine:pushInt(data.buyLumberTimes);
-- 每日每关卡可重置次数次数
	networkengine:pushInt(data.resetTimes);
-- 每日获得扫荡券数量
	networkengine:pushInt(data.sweepScrollCount);
-- 体力上限
	networkengine:pushInt(data.maxVigor);
-- 金矿存储上限系数
	networkengine:pushInt(data.maxGoldRatio);
-- 伐木场原木存储上限
	networkengine:pushInt(data.maxLumberRatio);
-- 可使用多次扫荡功能
	networkengine:pushBool(data.canSweep);
-- 每日回购经验次数
	networkengine:pushInt(data.buyLostExpTimes);
-- 副本挑战次数
	networkengine:pushInt(data.challengeStageTimes);
-- 每日魔法精华购买次数
	networkengine:pushInt(data.buyMagicExpTimes);
-- vip礼包奖励类型
	local arrayLength = #data.giftType;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.giftType) do
		networkengine:pushInt(v);
	end

-- vip礼包奖励ID
	local arrayLength = #data.giftID;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.giftID) do
		networkengine:pushInt(v);
	end

-- vip礼包奖励数量
	local arrayLength = #data.giftCount;
	if arrayLength > 4 then arrayLength = 4 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.giftCount) do
		networkengine:pushInt(v);
	end

-- vip礼包价格
	networkengine:pushInt(data.giftPrice);
-- 急速挑战失败次数限制
	networkengine:pushInt(data.challengeSpeedFailLimit);
-- 金币产量系数
	networkengine:pushFloat(data.goldRatio);
end

function ParseRowVip()
	local tempArrayCount = 0;
	local data = {};

	data['giftType'] = {};
	data['giftID'] = {};
	data['giftCount'] = {};
-- VIP等级
	data['id'] = networkengine:parseInt();
-- 充值界限(分)
	data['rmb'] = networkengine:parseInt();
-- 每日可买体力次数
	data['buyVigorTimes'] = networkengine:parseInt();
-- 每日可买金币次数
	data['buyGoldTimes'] = networkengine:parseInt();
-- 每日可买木材次数
	data['buyLumberTimes'] = networkengine:parseInt();
-- 每日每关卡可重置次数次数
	data['resetTimes'] = networkengine:parseInt();
-- 每日获得扫荡券数量
	data['sweepScrollCount'] = networkengine:parseInt();
-- 体力上限
	data['maxVigor'] = networkengine:parseInt();
-- 金矿存储上限系数
	data['maxGoldRatio'] = networkengine:parseInt();
-- 伐木场原木存储上限
	data['maxLumberRatio'] = networkengine:parseInt();
-- 可使用多次扫荡功能
	data['canSweep'] = networkengine:parseBool();
-- 每日回购经验次数
	data['buyLostExpTimes'] = networkengine:parseInt();
-- 副本挑战次数
	data['challengeStageTimes'] = networkengine:parseInt();
-- 每日魔法精华购买次数
	data['buyMagicExpTimes'] = networkengine:parseInt();
-- vip礼包奖励类型
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['giftType'][i] = networkengine:parseInt();
	end
-- vip礼包奖励ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['giftID'][i] = networkengine:parseInt();
	end
-- vip礼包奖励数量
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['giftCount'][i] = networkengine:parseInt();
	end
-- vip礼包价格
	data['giftPrice'] = networkengine:parseInt();
-- 急速挑战失败次数限制
	data['challengeSpeedFailLimit'] = networkengine:parseInt();
-- 金币产量系数
	data['goldRatio'] = networkengine:parseFloat();

	return data;
end

------------------typedef RowVigorReward ----------------------------------
function sendPushRowVigorReward(data)
-- id
	networkengine:pushInt(data.id);
-- 起始时间
	networkengine:pushInt(string.len(data.beginTime));
	networkengine:pushString(data.beginTime, string.len(data.beginTime));
-- 结束时间
	networkengine:pushInt(string.len(data.endTime));
	networkengine:pushString(data.endTime, string.len(data.endTime));
-- 领取后获得体力
	networkengine:pushInt(data.vigor);
end

function ParseRowVigorReward()
	local tempArrayCount = 0;
	local data = {};

-- id
	data['id'] = networkengine:parseInt();
-- 起始时间
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['beginTime'] = networkengine:parseString(strlength);
else
		data['beginTime'] = "";
end
-- 结束时间
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['endTime'] = networkengine:parseString(strlength);
else
		data['endTime'] = "";
end
-- 领取后获得体力
	data['vigor'] = networkengine:parseInt();

	return data;
end

------------------typedef RowUnit ----------------------------------
function sendPushRowUnit(data)
-- 军团ID
	networkengine:pushInt(data.id);
-- 军团名称
	networkengine:pushInt(string.len(data.name));
	networkengine:pushString(data.name, string.len(data.name));
-- 卡牌ID
	networkengine:pushInt(data.cardID);
-- 品阶
	networkengine:pushInt(data.quality);
-- 人口
	networkengine:pushInt(data.food);
-- 星级
	networkengine:pushInt(data.starLevel);
-- 性别
	networkengine:pushInt(data.sex);
-- 种族
	networkengine:pushInt(data.race);
-- 兵粮消耗
	networkengine:pushInt(data.foodRatio);
-- 单兵生命
	networkengine:pushInt(data.soldierHP);
-- 护甲值
	networkengine:pushInt(data.defence);
-- 是远程军团
	networkengine:pushBool(data.isRange);
-- 伤害类型
	networkengine:pushInt(data.damageType);
-- 单兵攻击力
	networkengine:pushInt(data.soldierDamage);
-- 攻击射程
	networkengine:pushInt(data.attackRange);
-- 移动类型
	networkengine:pushInt(data.moveType);
-- 行动速度
	networkengine:pushInt(data.actionSpeed);
-- 移动力
	networkengine:pushInt(data.moveRange);
-- 技能ID
	local arrayLength = #data.skill;
	if arrayLength > 8 then arrayLength = 8 end;
	networkengine:pushInt(arrayLength);
	for i,v in ipairs(data.skill) do
		networkengine:pushInt(v);
	end

end

function ParseRowUnit()
	local tempArrayCount = 0;
	local data = {};

	data['skill'] = {};
-- 军团ID
	data['id'] = networkengine:parseInt();
-- 军团名称
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['name'] = networkengine:parseString(strlength);
else
		data['name'] = "";
end
-- 卡牌ID
	data['cardID'] = networkengine:parseInt();
-- 品阶
	data['quality'] = networkengine:parseInt();
-- 人口
	data['food'] = networkengine:parseInt();
-- 星级
	data['starLevel'] = networkengine:parseInt();
-- 性别
	data['sex'] = networkengine:parseInt();
-- 种族
	data['race'] = networkengine:parseInt();
-- 兵粮消耗
	data['foodRatio'] = networkengine:parseInt();
-- 单兵生命
	data['soldierHP'] = networkengine:parseInt();
-- 护甲值
	data['defence'] = networkengine:parseInt();
-- 是远程军团
	data['isRange'] = networkengine:parseBool();
-- 伤害类型
	data['damageType'] = networkengine:parseInt();
-- 单兵攻击力
	data['soldierDamage'] = networkengine:parseInt();
-- 攻击射程
	data['attackRange'] = networkengine:parseInt();
-- 移动类型
	data['moveType'] = networkengine:parseInt();
-- 行动速度
	data['actionSpeed'] = networkengine:parseInt();
-- 移动力
	data['moveRange'] = networkengine:parseInt();
-- 技能ID
	tempArrayCount = networkengine:parseInt();
	for i=1, tempArrayCount do
		data['skill'][i] = networkengine:parseInt();
	end

	return data;
end

------------------typedef DeviceInfo ----------------------------------
function sendPushDeviceInfo(data)
-- mac地址或设备唯一标识
	networkengine:pushInt(string.len(data.mac));
	networkengine:pushString(data.mac, string.len(data.mac));
-- 设备登陆的渠道编号
	networkengine:pushInt(string.len(data.platform));
	networkengine:pushString(data.platform, string.len(data.platform));
-- password
	networkengine:pushInt(string.len(data.password));
	networkengine:pushString(data.password, string.len(data.password));
-- phoneNum
	networkengine:pushInt(string.len(data.phoneNum));
	networkengine:pushString(data.phoneNum, string.len(data.phoneNum));
-- 设备登陆的平台ID
	networkengine:pushInt(data.os);
-- 游戏登陆的入口ID
	networkengine:pushInt(data.entry);
end

function ParseDeviceInfo()
	local tempArrayCount = 0;
	local data = {};

-- mac地址或设备唯一标识
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['mac'] = networkengine:parseString(strlength);
else
		data['mac'] = "";
end
-- 设备登陆的渠道编号
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['platform'] = networkengine:parseString(strlength);
else
		data['platform'] = "";
end
-- password
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['password'] = networkengine:parseString(strlength);
else
		data['password'] = "";
end
-- phoneNum
	local strlength = networkengine:parseInt();
if strlength > 0 then
		data['phoneNum'] = networkengine:parseString(strlength);
else
		data['phoneNum'] = "";
end
-- 设备登陆的平台ID
	data['os'] = networkengine:parseInt();
-- 游戏登陆的入口ID
	data['entry'] = networkengine:parseInt();

	return data;
end

------------------typedef GuideInfo ----------------------------------
function sendPushGuideInfo(data)
-- 编号
	networkengine:pushInt(data.id);
-- 状态
	networkengine:pushBool(data.active);
end

function ParseGuideInfo()
	local tempArrayCount = 0;
	local data = {};

-- 编号
	data['id'] = networkengine:parseInt();
-- 状态
	data['active'] = networkengine:parseBool();

	return data;
end

