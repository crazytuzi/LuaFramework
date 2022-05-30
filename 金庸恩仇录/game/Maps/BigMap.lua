local data_world_world = require("data.data_world_world")
local data_field_field = require("data.data_field_field")

local MAX_ZORDER = 1111

local BigMap = class("BigMap",function ()
	return display.newScene("BigMap")
end)

function BigMap:ctor(enterBigMapID,subMapID,worldFunc, dontReq)
	addbackevent(self)
	game.runningScene = self
	ResMgr.createBefTutoMask(self)
	local bigMapID = enterBigMapID
	self.isFirst = false
	if PageMemoModel.bigMapID ~= 0 then
		bigMapID = PageMemoModel.bigMapID
	else
		self.isFirst = true
	end
	
	PageMemoModel.bigMapID = bigMapID
	
	local TILE_WIDTH = 32
	local TILE_HEIGHT = 32
	
	local TILES_W_NUM = 20
	local TILES_H_NUM = 30
	
	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	display.addSpriteFramesWithFile("bigmap/bigmap.plist", "bigmap/bigmap.png")
	
	self.top = require("game.scenes.TopLayer").new()
	self:addChild(self.top,100)
	self.top:setInfoBgVisible(false)
	
	local bgImage
	local levelBg
	local function initBg(  bgName )
		local scrollViewBg = CCScrollView:create()
		self.bgScroll = scrollViewBg
		if scrollViewBg ~= nil then
			local bg = display.newScale9Sprite("ui/alphaBg.png")
			bgImage = display.newSprite("ui/jpg_bg/bigmap/" .. bgName .. ".jpg")
			self.bgName = bgName
			local BG_WIDTH = bgImage:getContentSize().width
			local BG_HEIGHT = bgImage:getContentSize().height
			
			if display.sizeInPixels.width > bgImage:getContentSize().width then
				local factorWidth = display.sizeInPixels.width
				if device.model == "ipad" and factorWidth == 1536 then
					factorWidth = 768
				end
				if device.platform == "android" then
					factorWidth = 768
				end
				local scale_factor = factorWidth/bgImage:getContentSize().width
				bgImage:setScale(scale_factor)
				BG_WIDTH = BG_WIDTH * scale_factor
				BG_HEIGHT = BG_HEIGHT * scale_factor
				-- TILE_WIDTH = TILE_WIDTH * scale_factor
				TILE_HEIGHT = TILE_HEIGHT * scale_factor
			end
			
			bgImage:setAnchorPoint(cc.p(0, 0))
			bgImage:setPosition(0, 0)
			bg:addChild(bgImage)
			bg:setPreferredSize(cc.size(display.width,BG_HEIGHT))
			scrollViewBg:setViewSize(cc.size(display.width, display.height- 259))
			
			scrollViewBg:setPosition(cc.p( 0,self.top:getBottomContentSize().height))
			scrollViewBg:ignoreAnchorPointForPosition(true)
			
			scrollViewBg:setContainer(bg)
			scrollViewBg:setContentSize(CCSize(display.width, BG_HEIGHT))
			scrollViewBg:updateInset()
			
			scrollViewBg:setDirection(kCCScrollViewDirectionVertical)
			scrollViewBg:setClippingToBounds(true)
			--大地图滑动效果	
			scrollViewBg:setBounceable(false)
			self:addChild(scrollViewBg)
			--重置地图位置
			if bigMapID ~= nil then
				scrollViewBg:setContentOffset(game.player:getFubenDisOffset(), false)
			end
			game.player:setFubenDisOffset(cc.p(0, 0))
		end
		
		self.bg = scrollViewBg
		-- 顶部 大关卡选择 横向列表
		levelBg = require("utility.HorizonListBg").new()
		levelBg:setPosition(display.width/2,display.height - self.top:getVoiceSize().height*0.8 - levelBg:getContentSize().height/2)
		self:addChild(levelBg)
	end
	
	local bigmapName = "bigmap_1"
	if bigMapID ~= nil then
		dump(11111111111111111)
		dump(bigMapID)
		dump(data_world_world)
		bigmapName = data_world_world[bigMapID].background
	end
	
	initBg(bigmapName)
	local function refreshBg(bgName)
		if bgImage then
			bgImage:setDisplayFrame(display.newSprite("ui/jpg_bg/bigmap/" .. bgName .. ".jpg"):getDisplayFrame())
		end
	end
	
	local function enterSubMap(index )
		if index > self._curLevel["bigMap"] then
			-- show_tip_label( "[" .. data_world_world[index].name .. "] "..  data_world_world[index].level .. " 级解锁")
		else
			PageMemoModel.bigMapID = index
			display.replaceScene(require("game.Maps.BigMap").new(index))
		end
	end
	
	local function init()
		local maxZorder = 10
		local i = 0
		for k, v in pairs(self._subMap) do
			local submapID = checkint(k)
			local subMapData = data_field_field[submapID]
			local buildBtn = require("utility.CommonButton").new({
			img = "lvl/".. subMapData.icon  ..".png",
			listener = function ()
				-- GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
				dump(self._subMap)
				dump(self._curLevel)
				dump(submapID)
				if submapID <= self._curLevel["subMap"]  and game.player.m_level >= data_field_field[submapID].level then
					--需要在这里查看是否要播放剧情	
					local curBigMapID = bigMapID
					if curBigMapID == nil then
						curBigMapID = self._curLevel["bigMap"]
					end
					DramaMgr.runDramaBefSub(submapID,function()
						game.player:setFubenDisOffset(self.bg:getContentOffset())
						PostNotice(NoticeKey.REMOVE_TUTOLAYER)
						-- ResMgr.intoSubMap = true
						-- TutoMgr.lockBtn()
						GameStateManager:ChangeState(GAME_STATE.STATE_SUBMAP, {submapID = submapID, subMap = self._subMap})
					end)
				else
					show_tip_label("[" .. data_field_field[submapID].name .. "] " .. data_field_field[submapID].level .."级开启!")
				end
				end})
				
				local btnW = buildBtn:getContentSize().width
				local btnH = buildBtn:getContentSize().height
				buildBtn:setAlign(display.CENTER)
				buildBtn:setPosition(subMapData.x_axis * TILE_WIDTH - btnW / 2, subMapData.y_axis * TILE_HEIGHT - btnH / 2)
				buildBtn:addTo(self.bg, maxZorder - i)
				i = i + 1
				
				-- 关卡箭头特效
				if submapID == self._curLevel["subMap"] then
					-- if submapID ~= 1101 and submapID ~= 1102 then
					if submapID ~= 1101  then
						-- 关卡特效
						local jiantouEff = ResMgr.createArma({
						resType = ResMgr.UI_EFFECT,
						armaName = "dangqianguankatexiao_jiantou",
						isRetain = true
						})
						jiantouEff:align(display.BOTTOM_CENTER, subMapData.x_axis * TILE_WIDTH, buildBtn:getPositionY() + buildBtn:getContentSize().height)
						:addTo(self.bg, maxZorder)
						-- 关卡特效
						local boEff = ResMgr.createArma({
						resType = ResMgr.UI_EFFECT,
						armaName = "dangqianguankatexiao_bo",
						isRetain = true
						})
						boEff:align(display.BOTTOM_CENTER, subMapData.x_axis * TILE_WIDTH, buildBtn:getPositionY())
						:addTo(self.bg, maxZorder)
					end
					
					if self.isFirst == true then
						self.isFirst = false
						self.bg:setContentOffset(cc.p(0, -(subMapData.y_axis - 1) * TILE_HEIGHT + btnH))
					end
					
				end
				
				if subMapData.id == 1101 then
					TutoMgr.addBtn("putongfuben_btn_niujiacun1",buildBtn)
					TutoMgr.active()
				end
				
				if subMapData.id == 1102 then
					TutoMgr.addBtn("bigmap_second_lvl",buildBtn)
					TutoMgr.active()
				end
				
				local nameBg = display.newSprite("lvl/lv_b_name_bg.png")
				nameBg:setPosition(buildBtn:getContentSize().width/2, 0)
				buildBtn:addChild(nameBg, maxZorder)
				
				local fontColor = display.COLOR_WHITE
				if self._curLevel["subMap"] == subMapData.id then
					fontColor = display.COLOR_RED
				end
				
				local nameLabel = ui.newTTFLabel({
				text = subMapData.name,
				font = FONTS_NAME.font_fzcy,
				size = 22,
				color = fontColor,
				x = nameBg:getContentSize().width/2,
				y = nameBg:getContentSize().height/2,
				align = ui.TEXT_ALIGN_CENTER,
				valign = ui.TEXT_VALIGN_CENTER,
				})
				nameBg:addChild(nameLabel)
				
				--star
				local star = self._subMap[tostring(subMapData.id)]
				local starLabel = ui.newBMFontLabel({
				text = star .. "/" .. data_field_field[subMapData.id].star,
				font = FONTS_NAME.font_property,
				size = 22,
				color = display.COLOR_WHITE,
				x = nameBg:getContentSize().width/2,
				y = -nameBg:getContentSize().height*0.8,
				align = ui.TEXT_ALIGN_CENTER
				})
				nameBg:addChild(starLabel)
				
				local starIcon = display.newSprite("#bigmap_star.png")
				starIcon:setPosition(nameBg:getContentSize().width*0.68 + starIcon:getContentSize().width/2, -nameBg:getContentSize().height/2)
				nameBg:addChild(starIcon)
				
				-- 未解锁关卡 用云遮罩
				if star == 0 and submapID > self._curLevel["subMap"]  then
					if data_field_field[subMapData.id].cloud_live_anim ~= nil then
						local armaName = data_field_field[subMapData.id].cloud_live_anim
						if ResMgr.isHighEndDevice() == false then
							armaName = "yun1_piaodong"
						end
						local xunhuanEffect = ResMgr.createArma({
						resType = ResMgr.UI_EFFECT,
						armaName = armaName,
						isRetain = true
						})
						local x = subMapData.x_axis * TILE_WIDTH + data_field_field[subMapData.id].cloud_x
						local y = subMapData.y_axis * TILE_HEIGHT + data_field_field[subMapData.id].cloud_y
						xunhuanEffect:setPosition(x, y)
						xunhuanEffect:align(display.CENTER)
						self.bg:addChild(xunhuanEffect, maxZorder - i +1)
					end
				elseif star == 0 and submapID == self._curLevel["subMap"] then
					local hasPlayed = CCUserDefault:sharedUserDefault():getBoolForKey("big"..submapID, false)
					if hasPlayed == false then
						CCUserDefault:sharedUserDefault():setBoolForKey("big"..submapID, true)
						local armaName = data_field_field[subMapData.id].cloud_die_anim
						if(ResMgr.isHighEndDevice() == false) then
						armaName = "yun1_sankai"
					end
					if data_field_field[subMapData.id].cloud_die_anim ~= nil then
						local xunhuanEffect = ResMgr.createArma({
						resType = ResMgr.UI_EFFECT,
						armaName = data_field_field[subMapData.id].cloud_die_anim,
						isRetain = true
						})
						local x = subMapData.x_axis * TILE_WIDTH - xunhuanEffect:getContentSize().width/2 + data_field_field[subMapData.id].cloud_x
						local y = subMapData.y_axis * TILE_HEIGHT - xunhuanEffect:getContentSize().height*0.6 + data_field_field[subMapData.id].cloud_y
						xunhuanEffect:setPosition(x,y)
						self.bg:addChild(xunhuanEffect,maxZorder- i +1)
					end
				end
			end
		end
	end
	
	
	local function initLevelChoose()
		local _data = {}
		for k, v in pairs(data_world_world) do
			table.insert(_data, v)
		end
		
		table.sort(_data, function(l, r)
			return l.id < r.id
		end)
		
		local HOLDER_SPACE_WIDTH = 80
		local viewSize = CCSizeMake(levelBg:getContentSize().width - HOLDER_SPACE_WIDTH, levelBg:getContentSize().height)
		
		-- 检测是否开启了新大地图关卡
		local function checkIsNewBigMap(id)
			local unlock = false
			local battleData = game.player:getBattleData()
			if battleData.isOpenNewBigmap and battleData.cur_bigMapId == id then
				unlock = true
			end
			return unlock
		end
		
		self._bagItemList = require("utility.TableViewExt").new({
		size        = viewSize,
		direction   = kCCScrollViewDirectionHorizontal,
		createFunc  = function(idx)
			idx = idx + 1
			local bChoose = false
			if bigMapID ~= nil and _data[idx].id == bigMapID then
				bChoose = true
			elseif bigMapID == nil and _data[idx].id == self._curLevel["bigMap"] then
				bChoose = true
			end
			
			local bLock = false
			if _data[idx].id > self._curLevel["bigMap"] then
				bLock = true
			end
			
			return require("game.Maps.BigMapUpCell").new():create({
			itemData = _data[idx],
			idx = idx,
			viewSize = viewSize,
			choose = bChoose,
			bLock = bLock,
			curUnLock = checkIsNewBigMap(_data[idx].id),
			unLockListener = function()
				game.player:setBattleData({
				isOpenNewBigmap = false
				})
			end
			})
		end,
		refreshFunc = function(cell, idx)
			idx = idx + 1
			local bChoose = false
			if bigMapID ~= nil and _data[idx].id == bigMapID then
				bChoose = true
			elseif bigMapID == nil and _data[idx].id == self._curLevel["bigMap"] then
				bChoose = true
			end
			
			local bLock = false
			if _data[idx].id > self._curLevel["bigMap"] then
				bLock = true
			end
			
			cell:refresh({
			itemData = _data[idx ],
			idx      = idx,
			choose   = bChoose,
			bLock = bLock,
			curUnLock = checkIsNewBigMap(_data[idx].id)
			})
		end,
		cellNum  = #_data,
		cellSize  = require("game.Maps.BigMapUpCell").new():getContentSize(),
		touchFunc = function(cell)
			local idx = cell:getIdx() + 1
			if PageMemoModel.bigMapID ~= nil and PageMemoModel.bigMapID ~= _data[idx].id then
				enterSubMap(_data[idx].id)
			end
			printf("====== %d",_data[idx].id)
		end,
		
		scrollFunc = function()
			if self._bagItemList ~= nil then
				PageMemoModel.saveOffset("big_map_up_icon",self._bagItemList)
			end
		end
		})
		self._bagItemList:setPosition(-levelBg:getContentSize().width / 2 + HOLDER_SPACE_WIDTH/2, -levelBg:getContentSize().height / 2 + 10)
		levelBg:addChild(self._bagItemList)
		
	end
	
	local function initBigmapData(data)
		dump(data)
		local bgName = "bigmap_1"
		
		--判断是否
		local curSubID = game.player:getCurSubMapID()
		self.isUnlockNewLvl = false
		if curSubID ~= data["2"] then
			self.isUnlockNewLvl = true
		end
		
		if data["0"] == "" then
			self._curLevel = {
			bigMap = data["1"],  --大地图	
			subMap = data["2"],  --小地图	
			level  = data["3"]   --小关卡	
			}
			self._subMap = data["4"]
			game.player:setBattleData({
			cur_bigMapId = data["1"],
			cur_subMapId = data["2"],
			new_subMapId = data["2"]
			})
			
			-- 大地图背景 
			-- 默认为最大关卡地图，否则根据选择显示
			local mapId = bigMapID or data["1"]
			bgName = data_world_world[mapId].background
			
			-- 世界地图背景音乐
			local soundName = ResMgr.getSound(data_world_world[mapId].bgm)
			GameAudio.playMusic(soundName, true)
			
			
			game.player.m_maxLevel = data["3"]
			
			-- 判断是否开启新关卡
			local battleData = game.player:getBattleData()
			if battleData.isOpenNewBigmap then
				local levelName = data_world_world[battleData.cur_bigMapId].name
				self:addChild(require("game.Maps.SubmapNewMsg").new("新世界地图开启！", levelName), MAX_ZORDER)
			end
			
			refreshBg(bgName)
			init()
			initLevelChoose()
			
			if worldFunc ~= nil then
				worldFunc()
			end
		else
			
		end
	end
	
	if dontReq == false or dontReq == nil then
		-- print("bigMapIDbigMapIDbigMapIDbigMapID "..bigMapID)
		RequestHelper.getLevelList({
		id = bigMapID,
		callback = function(data)
			--dump(data)
			initBigmapData(data)
		end
		})
	else
		print("nonnonononon")
		--dump(game.player.bigmapData)
		initBigmapData(game.player.bigmapData)
	end
	
end

function BigMap:onEnter()
	GameStateManager.currentState = GAME_STATE.STATE_FUBEN
	if self.isUnlockNewLvl ~= true then
		-- self.isUnlockNewLvl = true
		PageMemoModel.resetOffset(self.bgName,self.bgScroll)
	end
end

function BigMap:onExit()
	PageMemoModel.saveOffset(self.bgName,self.bgScroll)
	TutoMgr.removeBtn("putongfuben_btn_niujiacun1")
	TutoMgr.removeBtn("bigmap_second_lvl")
	ResMgr.ReleaseUIArmature( "dangqianguankatexiao_jiantou" )
	ResMgr.ReleaseUIArmature( "dangqianguankatexiao_bo" )
	for i=1,4 do
		local name_piaodong = string.format("yun%d_piaodong/yun_%d", i, i)
		local name_sankai = string.format("yun%d_sankai/yun_%d",i,i)
		ResMgr.ReleaseUIArmature(name_piaodong)
		ResMgr.ReleaseUIArmature(name_sankai)
	end
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
	collectgarbage("collect")
end

return BigMap