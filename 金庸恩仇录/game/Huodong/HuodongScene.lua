local data_huodong_huodong = require("data.data_huodong_huodong")

local HuodongScene = class("HuodongScene", function(...)
	return display.newScene("HuodongScene")
end)

local DUOBAO_TAG = 1
local ARENA_TAG = 2
local LUNJIAN = 3
local BIWU = 4
local WORLDBOSS_TAG = 5
local YABIAO = 6
local KUAFU_TAG = 7
local CHUANGDANG_TAG = 8

function HuodongScene:ctor()
	ResMgr.createBefTutoMask(self)
	local bg = display.newSprite("ui/ui_huodong/ui_huodong_bg.jpg")
	bg:setScale(display.width / bg:getContentSize().width)
	bg:setPosition(display.cx, display.cy)
	self:addChild(bg)
	self.top = require("game.scenes.TopLayer").new(true)
	self:addChild(self.top, 1)
	self.topSize = self.top:getTopLayerContentSize()
	self.bottomSize = self.top:getBottomContentSize()
	addbackevent(self)
end

function HuodongScene:toHuoDong(index)
	printf("=========== %d", index)
	if index == ARENA_TAG then
		GameStateManager:ChangeState(GAME_STATE.STATE_ARENA)
	elseif index == DUOBAO_TAG then
		GameStateManager:ChangeState(GAME_STATE.STATE_DUOBAO)
	elseif index == CHUANGDANG_TAG then
		GameStateManager:ChangeState(GAME_STATE.STATE_CHUANGDANG)
	elseif index == LUNJIAN then
		if not ENABLE_LUNJIAN then
			show_tip_label(common:getLanguageString("@HintPause"))
		else
			GameStateManager:ChangeState(GAME_STATE.STATE_HUASHAN)
		end
	elseif index == WORLDBOSS_TAG then
		if not ENABLE_WORLDBOSS then
			show_tip_label(common:getLanguageString("@HintPause"))
		else
			RequestHelper.worldBoss.history({
			callback = function(data)
				dump(data)
				if data["0"] ~= "" then
					show_tip_label(data["0"])
					--CCMessageBox(data["0"], "Error")
				elseif data["1"] <= 0 then
					GameStateManager:ChangeState(GAME_STATE.STATE_WORLD_BOSS)
				else
					GameStateManager:ChangeState(GAME_STATE.STATE_WORLD_BOSS_NORMAL, data)
				end
			end
			})
		end
	elseif index == BIWU then
		GameStateManager:ChangeState(GAME_STATE.STATE_BIWU)
	elseif index == YABIAO then
		GameStateManager:ChangeState(GAME_STATE.STATE_YABIAO_SCENE)
	elseif index == KUAFU_TAG then
		GameStateManager:ChangeState(GAME_STATE.STATE_KUAFU_MAIN, 1)
		--if not ENABLE_KUAFU then
		--	show_tip_label(common:getLanguageString("@HintPause"))
		--else
		--	GameStateManager:ChangeState(GAME_STATE.STATE_KUAFU_MAIN, 1)
		--end
	end
end

function HuodongScene:onEnter()
	GameAudio.playMainmenuMusic(true)
	local curOpenHuoDong = {}
	for k, v in ipairs(data_huodong_huodong) do
		if v.open == 1 and (v.huodong ~= KUAFU_TAG or game.player:getAppOpenData().appstore == APPOPEN_STATE.open) then
			curOpenHuoDong[#curOpenHuoDong + 1] = v
		end
	end
	table.sort(curOpenHuoDong, function(a, b)
		return a.id < b.id
	end)
	self.itemList = require("utility.TableViewExt").new({
	size = cc.size(display.width, display.height - self.topSize.height - self.bottomSize.height),
	direction = kCCScrollViewDirectionVertical,
	createFunc = function(idx)
		local item = require("game.Huodong.HuodongItem").new()
		idx = idx + 1
		return item:create({
		viewSize = cc.size(display.width, 160),
		itemData = curOpenHuoDong[idx],
		idx = idx
		})
	end,
	refreshFunc = function(cell, idx)
		idx = idx + 1
		cell:refresh({
		idx = idx,
		itemData = curOpenHuoDong[idx]
		})
	end,
	cellNum = #curOpenHuoDong,
	cellSize = cc.size(display.width, 180),
	touchFunc = function(cell)
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		local index = cell:getIdx() + 1
		self:toHuoDong(curOpenHuoDong[index].huodong)
	end
	})
	self.itemList:setPosition(0, self.bottomSize.height)
	local cell = self.itemList:cellAtIndex(0)
	local tutoBtn
	if cell ~= nil then
		tutoBtn = cell:getBtn()
	end
	TutoMgr.addBtn("duobao_board", tutoBtn)
	local arena_cell = self.itemList:cellAtIndex(1)
	local arena_board
	if arena_cell ~= nil then
		arena_board = arena_cell:getBtn()
	end
	arena_cell = self.itemList:cellAtIndex(2)
	local chuangdang_board
	if arena_cell ~= nil then
		chuangdang_board = arena_cell:getBtn()
	end
	TutoMgr.addBtn("jingjichang_board", arena_board)
	TutoMgr.addBtn("chuangdang_board", chuangdang_board)
	self:addChild(self.itemList)
	TutoMgr.active()
end

function HuodongScene:onExit()
	TutoMgr.removeBtn("duobao_board")
	TutoMgr.removeBtn("jingjichang_board")
	TutoMgr.removeBtn("chuangdang_board")
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return HuodongScene