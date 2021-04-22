--
-- Author: wkwang
-- Date: 2014-09-01 17:49:54
-- 自定义标志位管理类
--
local QBaseModel = import("..models.QBaseModel")
local QFlag = class("QFlag",QBaseModel)

QFlag.EVENT_UPDATE = "EVENT_UPDATE" --更新标志位

QFlag.FLAG_TUTORIAL_STAGE = "FLAG_TUTORIAL_STAGE" --设置新手引导步骤
QFlag.FLAG_TUTORIAL_LOCK = "FLAG_TUTORIAL_LOCK" --设置新手是否开启
QFlag.FLAG_FRIST_GOLD_CHEST = "FLAG_FRIST_GOLD_CHEST" --第一次开黄金宝箱
QFlag.FLAG_FRIST_SILVER_CHEST = "FLAG_FRIST_SILVER_CHEST" --第一次开瑟银宝箱
QFlag.FLAG_UNLOCK_TUTORIAL = "FLAG_UNLOCK_TUTORIAL" --设置功能解锁引导
QFlag.FLAG_SHOP_REFRESH_TIME = "FLAG_SHOP_REFRESH_TIME" --设置功能解锁引导
QFlag.FLAG_MAP = "FLAG_MAP" --设置地图解锁
QFlag.FLAG_ELITE_MAP = "FLAG_ELITE_MAP" --设置精英地图解锁
QFlag.FLAG_WELFARE_MAP = "FLAG_WELFARE_MAP" --设置史诗地图解锁
QFlag.FLAG_NIGHTMARE_MAP = "FLAG_NIGHTMARE_MAP" --设置噩梦副本地图解锁
QFlag.FLAG_FRIST_MAP = "FLAG_FRIST_MAP" --设置地图解锁
QFlag.FLAG_FRIST_THUNDER_FAST = "FLAG_FRIST_THUNDER_FAST" --设置雷电王座扫荡
QFlag.FLAG_SOCIETY_MAP = "FLAG_SOCIETY_MAP" --设置宗门副本地图解锁
QFlag.FLAG_FRIST_GOLDPICKAXE = "FLAG_FRIST_GOLDPICKAXE" --第一次点诱魂草
QFlag.FLAG_FRIST_QUICKCHANGETEAM = "FLAG_FRIST_QUICKCHANGETEAM" --第一次点一键换队
QFlag.FLAG_FRIST_ROBOTFORSOCIETY = "FLAG_FRIST_ROBOTFORSOCIETY" --第一次宗门副本扫荡
QFlag.FLAG_DUNGEON_ASIDE = "FLAG_DUNGEON_ASIDE" --普通副本章节介绍
QFlag.FLAG_WENJUAN_CLICK = "FLAG_WENJUAN_CLICK" --第一次问卷调查点击
QFlag.HEAD_AVATAR_FLAG = "HEAD_AVATAR_FLAG" --
QFlag.SOULTRIAL_FLAG = "SOULTRIAL_FLAG" --魂力试炼第一次觉醒动画
QFlag.VIP_PREROGATIVE = "VIP_PREROGATIVE" --VIP特权展示
QFlag.ANIMATION_LINKAGE = "ANIMATION_LINKAGE" --动漫联动相关
QFlag.ANIMATION_NEW_SECTION = "ANIMATION_NEW_SECTION" --新一季动漫联动奖励弹脸
QFlag.DYNAMIC_CONFIG_KEY = "DYNAMIC_CONFIG_KEY" --动态频道设置相关
QFlag.FLAG_FRIST_SOIL_LETTER_ACTIVE = "FLAG_FRIST_SOIL_LETTER_ACTIVE" --第一次购买魂师手札

function QFlag:ctor(options)
	QFlag.super.ctor(self)
	self.data = {}
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QFlag:initGet(callBack)
	local tbl = {}
	table.insert(tbl, QFlag.FLAG_MAP)
	table.insert(tbl, QFlag.FLAG_FRIST_MAP)
	table.insert(tbl, QFlag.FLAG_TUTORIAL_STAGE)
	table.insert(tbl, QFlag.FLAG_TUTORIAL_LOCK)
	table.insert(tbl, QFlag.FLAG_UNLOCK_TUTORIAL)
	table.insert(tbl, QFlag.FLAG_SHOP_REFRESH_TIME)
	table.insert(tbl, QFlag.FLAG_FRIST_THUNDER_FAST)
	table.insert(tbl, QFlag.FLAG_SOCIETY_MAP)
	table.insert(tbl, QFlag.FLAG_NIGHTMARE_MAP)
	table.insert(tbl, QFlag.FLAG_FRIST_GOLDPICKAXE)
	table.insert(tbl, QFlag.FLAG_FRIST_QUICKCHANGETEAM)
	table.insert(tbl, QFlag.FLAG_DUNGEON_ASIDE)
	table.insert(tbl, QFlag.HEAD_AVATAR_FLAG)
	table.insert(tbl, QFlag.SOULTRIAL_FLAG)
	table.insert(tbl, QFlag.VIP_PREROGATIVE)
	table.insert(tbl, QFlag.ANIMATION_LINKAGE)
	table.insert(tbl, QFlag.ANIMATION_NEW_SECTION)
	table.insert(tbl, QFlag.DYNAMIC_CONFIG_KEY)
	table.insert(tbl, QFlag.FLAG_FRIST_SOIL_LETTER_ACTIVE)
	self:get(tbl, callBack)
end

function QFlag:set(key, value, callBack)
	if tostring(self.data[key]) == tostring(value) then
		if callBack ~= nil then
			callBack(value)
		end
		return
	end
	app:getClient():putFlag(tostring(key), tostring(value), function()
			self:saveData(key,value)
			if callBack ~= nil then
				callBack(value)
			end
		end)
end

function QFlag:get(tbl, callBack)
	local value = nil
	local resultTbl = {}
	local reqTbl = {}

	--过滤已经拉取的信息
	for _, key in pairs(tbl) do
		if self.data[key] == nil then
			if value == nil then
				value = key
			else
				value = value..";"..key
			end
			table.insert(reqTbl, key)
		else
			resultTbl[key] = self.data[key]
		end
	end

	--如果没有需要拉取的信息则直接返回
	if value == nil then
		callBack(resultTbl)
		return 
	end
	--拉取需要的信息再组合
	app:getClient():getFlag(tostring(value), function(data)
			if data.payloads == nil then
				data.payloads = {}
			end
			for _,key in pairs(reqTbl) do
				local value = ""
				for _,payload in pairs(data.payloads) do
					if payload.key == key then
						value = payload.value
					end
				end
				self:saveData(key,value)
				resultTbl[key] = self.data[key]
			end
			callBack(resultTbl)
		end)
end

function QFlag:saveData(key, value)
	self.data[key] = value
	self:dispatchEvent({name = QFlag.EVENT_UPDATE})
end

function QFlag:getLocalData(key)
	return self.data[key]
end

function QFlag:disappear()
	self.data = {}
end

return QFlag