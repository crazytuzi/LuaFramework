local OPENLAYER_ZORDER = 1111


local BaseScene = require("game.BaseScene")
local DuobaoQiangduoListScene = class("DuobaoQiangduoListScene", BaseScene)

function DuobaoQiangduoListScene:updateNaiLiLbl()
	self._rootnode.naili_num:setString(game.player.m_energy .. "/" .. game.player.m_maxEnergy)
	PostNotice(NoticeKey.CommonUpdate_Label_Naili)
	PostNotice(NoticeKey.CommonUpdate_Label_Tili)
end

function DuobaoQiangduoListScene:snatchAgain(index)
	game.runningScene = self
	self:startSnatch(index, true)
end

function DuobaoQiangduoListScene:extendBag(data)
	if self._bagObj[1].curCnt < data["1"] then
		table.remove(self._bagObj, 1)
	else
		self._bagObj[1].cost = data["4"]
		self._bagObj[1].size = data["5"]
	end
	if #self._bagObj > 0 then
		self:addChild(require("utility.LackBagSpaceLayer").new({
		bagObj = self._bagObj,
		callback = function(data)
			self:extendBag(data)
		end
		}), OPENLAYER_ZORDER)
	else
		self._isBagFull = false
	end
end

function DuobaoQiangduoListScene:startSnatch(index, isSnatchAgain)
	local isNPC = true
	if self._itemsData[index].type == 1 then
		isNPC = false
	end
	local function snatch()
		local snatchAgain = false
		if isSnatchAgain ~= nil then
			snatchAgain = isSnatchAgain
		end
		if game.player.m_energy < 2 then
			local layer = require("game.Duobao.DuobaoBuyMsgBox").new({
			updateListen = handler(self, DuobaoQiangduoListScene.updateNaiLiLbl)
			})
			game.runningScene:addChild(layer, 10000)
			return
		end
		if self._isBagFull then
			self:addChild(require("utility.LackBagSpaceLayer").new({
			bagObj = self._bagObj,
			callback = function(data)
				self:extendBag(data)
			end
			}), OPENLAYER_ZORDER)
			return
		end
		if not isNPC then
			self._warFreeTime = 0
		end
		RequestHelper.Duobao.snatch({
		id = self._debrisId,
		data = self._itemsData[index],
		callback = function(data)
			dump(data)
			if data["0"] ~= "" then
				dump(data["0"])
			else
				local isSnatch = data["8"]
				if isSnatch == 1 then
					if snatchAgain == true then
						pop_scene()
					end
					game.player:updateMainMenu({
					naili = game.player.m_energy - data["6"]
					})
					self:updateNaiLiLbl()
					push_scene(require("game.Duobao.DuobaoBattleScene").new({
					data = data,
					resultFunc = function()
						self:createResult({
						data = data,
						name = self._itemsData[index].name,
						enemyAcc = self._itemsData[index].acc,
						isNPC = isNPC,
						title = self._title,
						snatchIndex = index,
						debrisId = self._debrisId,
						snatchAgain = handler(self, DuobaoQiangduoListScene.snatchAgain)
						})
					end
					}))
				elseif isSnatch == 2 then
					show_tip_label(common:getLanguageString("@Reselect1"))
					self:requestUpdateList()
				elseif isSnatch == 3 then
					show_tip_label(common:getLanguageString("@Reselect2"))
					self:requestUpdateList()
				end
			end
		end
		})
	end
	dump("warFreeTime: " .. self._warFreeTime)
	if not isNPC and self._warFreeTime > 0 then
		local layer = require("utility.MsgBox").new({
		size = cc.size(500, 250),
		leftBtnName = common:getLanguageString("@NO"),
		rightBtnName = common:getLanguageString("@Confirm"),
		content = common:getLanguageString("@IsContinue"),
		leftBtnFunc = function()
		end,
		rightBtnFunc = function()
			snatch()
		end
		})
		self:addChild(layer, OPENLAYER_ZORDER)
	else
		snatch()
	end
end

function DuobaoQiangduoListScene:updateDebrisItem()
end

function DuobaoQiangduoListScene:createResult(param)
	dump(param)
	game.runningScene:addChild(require("game.Duobao.DuobaoResult").new(param), 3000)
end

function DuobaoQiangduoListScene:requestUpdateList()
	RequestHelper.Duobao.getSnatchList({
	id = tostring(self._debrisId),
	callback = function(data)
		self:updateQiangduoList(data)
	end
	})
end

function DuobaoQiangduoListScene:updateQiangduoList(data)
	if string.len(data["0"]) > 0 then
		CCMessageBox:create(data["0"], "Tip")
		return
	end
	local nailiAry = data["2"]
	game.player:updateMainMenu({
	naili = nailiAry[2],
	maxNaili = nailiAry[3]
	})
	self._rootnode.naili_num:setString(game.player.m_energy .. "/" .. game.player.m_maxEnergy)
	self._itemsData = data["1"]
	self:createListView()
end

function DuobaoQiangduoListScene:createListView()
	if self._listTable ~= nil then
		self._listTable:removeSelf()
		self._listTable = nil
	end
	local boardWidth = self._rootnode.listView:getContentSize().width
	local boardHeight = self._rootnode.listView:getContentSize().height - self._rootnode.top_node:getContentSize().height
	local function onRob10Btn(index)
		if self._isBagFull then
			self:addChild(require("utility.LackBagSpaceLayer").new({
			bagObj = self._bagObj,
			callback = function(data)
				self:extendBag(data)
			end
			}), OPENLAYER_ZORDER)
			return
		else
			printf("bag is not full")
		end
		if game.player:getNaili() < 2 then
			local layer = require("game.Duobao.DuobaoBuyMsgBox").new({
			updateListen = handler(self, DuobaoQiangduoListScene.updateNaiLiLbl)
			})
			game.runningScene:addChild(layer, 100)
		else
			RequestHelper.Duobao.rob10({
			id = self._debrisId,
			data = self._itemsData[index],
			callback = function(data)
				dump(data)
				game.player:setNaili(data.naili)
				self:updateNaiLiLbl()
				local layer = require("game.Duobao.Duobao10ResultLayer").new(data, self._debrisId)
				self:addChild(layer, 100)
			end
			})
		end
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
	end
	local function createFunc(index)
		dump(self._itemsData[index + 1])
		local item = require("game.Duobao.DuobaoQiangduoItem").new()
		local itemData = self._itemsData[index + 1]
		return item:create({
		itemData = itemData,
		viewSize = cc.size(boardWidth, boardHeight),
		snatchListener = handler(self, DuobaoQiangduoListScene.startSnatch),
		rob10Listener = onRob10Btn
		})
	end
	local function refreshFunc(cell, index)
		local itemData = self._itemsData[index + 1]
		cell:refresh(itemData)
	end
	local cellContentSize = require("game.Duobao.DuobaoQiangduoItem").new():getContentSize()
	self._listTable = require("utility.TableViewExt").new({
	size = cc.size(boardWidth, boardHeight),
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self._itemsData,
	cellSize = cellContentSize
	})
	self._rootnode.listView:addChild(self._listTable)
end

function DuobaoQiangduoListScene:ctor(param)
	game.runningScene = self
	
	DuobaoQiangduoListScene.super.ctor(self, {
	subTopFile = "duobao/duobao_qiangduo_up_tab.ccbi",
	contentFile = "duobao/duobao_qiangduo_bg.ccbi",
	topFile = "public/top_frame_other.ccbi",
	isOther = true
	})
	
	ResMgr.createBefTutoMask(self)
	local _bg = display.newSprite("ui_common/common_bg.png")
	local _bgW = display.width
	local _bgH = display.height - self._rootnode.bottomMenuNode:getContentSize().height - self._rootnode.topFrameNode:getContentSize().height
	_bg:setPosition(_bgW / 2, _bgH / 2 + self._rootnode.bottomMenuNode:getContentSize().height)
	_bg:setScaleX(_bgW / _bg:getContentSize().width)
	_bg:setScaleY(_bgH / _bg:getContentSize().height)
	self:addChild(_bg, 0)
	self._debrisId = param.id
	self._itemsData = param.data["1"]
	self._title = param.title
	self._isBagFull = param.data["3"]
	self._bagObj = param.data["4"]
	self._warFreeTime = param.warFreeTime
	local nailiAry = param.data["2"]
	game.player:updateMainMenu({
	naili = nailiAry[2],
	maxNaili = nailiAry[3]
	})
	
	self._rootnode.xiaohao_num:setString(tostring(math.abs(nailiAry[1])))
	self._rootnode.naili_num:setString(game.player.m_energy .. "/" .. game.player.m_maxEnergy)
	alignNodesOneByOne(self._rootnode.duobao_qiangduo_label_1, self._rootnode.naili_num)
	alignNodesOneByOne(self._rootnode.duobaoxiaohao_lbl, self._rootnode.xiaohao_num)
	
	self._rootnode.backBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		CCDirector:sharedDirector():popToRootScene()
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.changeBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:requestUpdateList()
	end,
	CCControlEventTouchUpInside)
	
	self:createListView()
	self:schedule(function()
		if self._warFreeTime > 0 then
			self._warFreeTime = self._warFreeTime - 1
		end
	end,
	1)
end

function DuobaoQiangduoListScene:onExit()
	DuobaoQiangduoListScene.super.onExit(self)
	TutoMgr.removeBtn("qiangduo_board_btn")
	TutoMgr.removeBtn("qiangduo_ten_btn")
	self:unscheduleUpdate()
	--self:unregNotice()
end

function DuobaoQiangduoListScene:onEnter()
	game.runningScene = self
	--self:regNotice()
	DuobaoQiangduoListScene.super.onEnter(self)
	GameAudio.playMainmenuMusic(true)
	self:updateNaiLiLbl()
	local levelData = game.player:getLevelUpData()
	if levelData.isLevelUp then
		do
			local _, systemIds = OpenCheck.checkIsOpenNewFuncByLevel(levelData.beforeLevel, levelData.curLevel)
			game.player:updateLevelUpData({isLevelUp = false})
			local function createOpenLayer()
				if #systemIds > 0 then
					local systemId = systemIds[1]
					self:addChild(require("game.OpenSystem.OpenLayer").new({systemId = systemId, confirmFunc = createOpenLayer}), OPENLAYER_ZORDER)
					table.remove(systemIds, 1)
				end
			end
			createOpenLayer()
		end
	end
	
	local num = self._listTable:getCellNum()
	for i = 1, num do
		if self._itemsData[i].type == 2 then
			local cell = self._listTable:cellAtIndex(i - 1)
			if cell ~= nil then
				local tutoBtn = cell:getTutoBtn()
				local tutoTenBtn = cell:getTenTutoBtn()
				TutoMgr.addBtn("qiangduo_board_btn", tutoBtn)
				TutoMgr.addBtn("qiangduo_ten_btn", tutoTenBtn)
				break
			end
		end
	end
	TutoMgr.active()
end

return DuobaoQiangduoListScene