local GuildBattleExchangeLayer = class("GuildBattleExchangeLayer", function()
	return require("utility.ShadeLayer").new()
end)

local OPENLAYER_ZORDER = 987
local guildBattleExchangeTag = 4

function GuildBattleExchangeLayer:ctor(param)
	self._proxy = CCBProxy:create()
	self._rootnode = {}
	self:setContentSize(param.size)
	local bgNode = CCBuilderReaderLoad("guild/guild_battle_wall_layer.ccbi", self._proxy, self._rootnode, self, param.size)
	self:addChild(bgNode)
	self:setNodeEventEnabled(true)
	self._parent = display.getRunningScene()
	resetctrbtnString(self._rootnode.tab1, common:getLanguageString("@GuildBattleExploit") .. common:getLanguageString("@Shop"))
	self._rootnode.backBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.shop_info_node:setVisible(true)
	self._rootnode.defence_info_node:setVisible(false)
	local boardWidth = self._rootnode.listView_node:getContentSize().width
	local boardHeight = self._rootnode.listView_node:getContentSize().height - self._rootnode.shop_info_node:getContentSize().height - self._rootnode.up_node:getContentSize().height
	local listViewSize = cc.size(boardWidth, boardHeight)
	setTTFLabelOutline({
	label = self._rootnode.curExploitLbl
	})
	self:setGongXun(0)
	self._exchangeData = {}
	
	local function onInformation(cell)
		local infoTag = 984
		if not self._parent:getChildByTag(infoTag) then
			local index = cell:getIdx() + 1
			local icon_data = self._exchangeData[index]
			local itemInfo = require("game.Huodong.ItemInformation").new({
			id = icon_data.id,
			type = icon_data.type,
			name = icon_data.name,
			describe = icon_data.describe
			})
			self._parent:addChild(itemInfo, infoTag)
		end
	end
	
	local function createFunc(index)
		local item = require("game.Arena.ArenaExchangeCell").new(guildBattleExchangeTag)
		return item:create({
		viewSize = listViewSize,
		itemData = self._exchangeData[index + 1],
		exchangeFunc = function(cell)
			self:exchangeFunc(cell)
		end,
		informationFunc = function(cell)
			onInformation(cell)
		end
		})
	end
	
	local function refreshFunc(cell, index)
		cell:refresh(self._exchangeData[index + 1])
	end
	
	self.exchangeCellSize = require("game.Arena.ArenaExchangeCell").new():getContentSize()
	self.exchangeList = require("utility.TableViewExt").new({
	size = listViewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._exchangeData,
	cellSize = self.exchangeCellSize
	})
	self._rootnode.listView_node:addChild(self.exchangeList)
end

function GuildBattleExchangeLayer:exchangeFunc(cell)
	local index = cell:getIdx() + 1
	local itemData = self._exchangeData[index]
	if game.player:getLevel() < itemData.needLevel then
		show_tip_label(common:getLanguageString("@ExchangeCondition") .. tostring(itemData.needLevel) .. common:getLanguageString("@ExchangeConditionLevel"))
		cell:updateExchangeBtn(true)
		return
	end
	local bagObj = {}
	local function extendBag(data)
		if bagObj[1].curCnt < data["1"] then
			table.remove(bagObj, 1)
		else
			bagObj[1].cost = data["4"]
			bagObj[1].size = data["5"]
		end
		if #bagObj > 0 then
			self._parent:addChild(require("utility.LackBagSpaceLayer").new({
			bagObj = bagObj,
			callback = function(data)
				extendBag(data)
			end
			}), OPENLAYER_ZORDER)
		end
	end
	local function confirmFunc(num)
		RequestHelper.exchange.exchange({
		id = itemData.dataId,
		num = num,
		shopType = guildBattleExchangeTag,
		callback = function(data)
			if data["0"] ~= "" then
				dump(data["0"])
			else
				bagObj = data["2"]
				if #bagObj > 0 then
					self._parent:addChild(require("utility.LackBagSpaceLayer").new({
					bagObj = bagObj,
					callback = function(data)
						extendBag(data)
					end
					}), OPENLAYER_ZORDER)
				else
					local cellDatas = {}
					table.insert(cellDatas, itemData)
					self._parent:addChild(require("game.Huodong.rewardInfo.RewardInfoMsgBox").new({
					shopType = HUASHAN_SHOP_TYPE,
					cellDatas = cellDatas,
					num = num
					}), 971)
					local bRemove = false
					local itemState = data["1"]
					local curHadNum = -1
					local curItemId = -1
					for i, v in ipairs(self._exchangeData) do
						if v.dataId == itemState.id then
							v.limitNum = itemState.num1
							v.had = itemState.had
							if v.type1 == 1 and v.limitNum == 0 then
								bRemove = true
								table.remove(self._exchangeData, i)
							end
							curItemId = v.id
							curHadNum = v.had
							break
						end
					end
					if curItemId ~= -1 and curHadNum ~= -1 then
						for i, v in ipairs(self._exchangeData) do
							if v.id == curItemId then
								v.had = curHadNum
							end
						end
					end
					if bRemove then
						self.exchangeList:resetListByNumChange(#self._exchangeData)
					else
						cell:updateExchangeNum(itemState.num1, itemState.had)
					end
					self:setGongXun(data["3"])
				end
			end
		end
		})
	end
	self._parent:addChild(require("game.Arena.ExchangeCountBox").new({
	reputation = self._gongXun,
	itemData = itemData,
	shopType = ENUM_GUILDBATTLE_SHOP_TYPE,
	listener = function(num)
		confirmFunc(num)
	end,
	closeFunc = function()
		cell:updateExchangeBtn(true)
	end
	}),
	970)
end

function GuildBattleExchangeLayer:setGongXun(gongXun)
	self._gongXun = gongXun
	self._rootnode.gongXun_num:setString(tostring(gongXun))
end

function GuildBattleExchangeLayer:getData(data)
	local listAry = data["1"]
	self._exchangeData = {}
	local data_shop_jingjichang_shop_jingjichang = require("data.data_shop_jingjichang_shop_jingjichang")
	for i, v in ipairs(listAry) do
		local duihuanData = data_shop_jingjichang_shop_jingjichang[v.id]
		if duihuanData then
			local iconType = ResMgr.getResType(duihuanData.type)
			local item = ResMgr.getItemByType(duihuanData.item, iconType)
			table.insert(self._exchangeData, {
			dataId = v.id,
			id = duihuanData.item,
			type = duihuanData.type,
			num = duihuanData.num,
			type1 = duihuanData.type1,
			needLevel = duihuanData.level,
			needReputation = duihuanData.price,
			limitNum = v.num1,
			had = v.had,
			iconType = iconType,
			name = item and item.name,
			describe = item and item.describe or ""
			})
		end
	end
	self.exchangeList:resetListByNumChange(#self._exchangeData)
end

function GuildBattleExchangeLayer:onEnter()
	RequestHelper.exchange.getData({
	shopType = guildBattleExchangeTag,
	callback = function(data)
		dump(data)
		if string.len(data["0"]) > 0 then
			CCMessageBox(data["0"], "Error")
		else
			self:getData(data)
			self:setGongXun(data["2"])
		end
	end
	})
end

function GuildBattleExchangeLayer:onExit()
end

return GuildBattleExchangeLayer