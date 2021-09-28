 --[[
 --
 -- @authors shan 
 -- @date    2014-08-04 15:35:15
 -- @version 
 --
 --]]
local data_huodong_huodong = require("data.data_huodong_huodong")

local HuodongScene = class("HuodongScene", function ( ... )
	return display.newScene("HuodongScene")
end)

local DUOBAO_TAG = 1 
local ARENA_TAG = 2
local LUNJIAN = 3
local BIWU = 4

local WORLDBOSS_TAG = 5
local YABIAO = 6



function HuodongScene:ctor( ... )
	-- body

    ResMgr.createBefTutoMask(self)
	local bg = display.newSprite("ui/ui_huodong/ui_huodong_bg.jpg")
	bg:setScale(display.width/bg:getContentSize().width)
	bg:setPosition(display.width/2, display.height/2)
	self:addChild(bg)

    self.top = require("game.scenes.TopLayer").new(true)
    self:addChild(self.top,1)

    self.topSize = self.top:getTopLayerContentSize()
    self.bottomSize = self.top:getBottomContentSize()

end

--[[
	创建活动列表，活动列表从服务器获取，服务器随时可以开启活动 
]]
function HuodongScene:toHuoDong(index)
    printf("=========== %d", index)
	if index == ARENA_TAG then 
		GameStateManager:ChangeState(GAME_STATE.STATE_ARENA)
	elseif index == DUOBAO_TAG then 
		GameStateManager:ChangeState(GAME_STATE.STATE_DUOBAO)
    elseif index == LUNJIAN then
    	if not ENABLE_LUNJIAN then 
    		show_tip_label("暂未开放")
    	else
    		GameStateManager:ChangeState(GAME_STATE.STATE_HUASHAN)
    	end 
	elseif index == WORLDBOSS_TAG then 
		if not ENABLE_WORLDBOSS then 
			show_tip_label("暂未开放") 
		else 
			RequestHelper.worldBoss.history({
		 		callback = function(data) 
		 			dump(data)
		 			if data["0"] ~= "" then 
		 				CCMessageBox(data["0"], "Error")
		 			else 
		 				if data["1"] <= 0 then 
		 					GameStateManager:ChangeState(GAME_STATE.STATE_WORLD_BOSS)
		 				else 
			 				GameStateManager:ChangeState(GAME_STATE.STATE_WORLD_BOSS_NORMAL, data)
			 			end 
		 			end 
			 	end 
	 		}) 
	 	end 

	-- elseif index == JIEFUJIPIN_TAG then
	-- 	-- local msg = {}
	-- 	local msg = 1
	-- 	GameStateManager:ChangeState(GAME_STATE.STATE_HUODONG_BATTLE,msg)		
	elseif index == BIWU then
		GameStateManager:ChangeState(GAME_STATE.STATE_BIWU)
	elseif index == YABIAO then
		GameStateManager:ChangeState(GAME_STATE.STATE_YABIAO_SCENE)
	end
end


function HuodongScene:onEnter()
	GameAudio.playMainmenuMusic(true)
	
	local curOpenHuoDong = {}


	for k,v in ipairs(data_huodong_huodong) do
		if v.open == 1 then
			curOpenHuoDong[#curOpenHuoDong + 1] = v
		end
	end



	self.itemList = require("utility.TableViewExt").new({
		size = CCSize(display.width, display.height - self.topSize.height - self.bottomSize.height),
		direction = kCCScrollViewDirectionVertical,
		createFunc = function ( idx )
            local item = require("game.Huodong.HuodongItem").new()
            idx = idx + 1
            return item:create({
                viewSize = CCSize(display.width,160),
                itemData = curOpenHuoDong[idx],
                idx      = idx,
            })
		end,
		refreshFunc = function ( cell, idx )
            idx = idx + 1
            cell:refresh({
                idx = idx,
                itemData = curOpenHuoDong[idx]
            })
		end,
		

		cellNum = #curOpenHuoDong,
		cellSize = CCSize(display.width,180),
		touchFunc = function ( cell )
			
			PostNotice(NoticeKey.REMOVE_TUTOLAYER)
			local index = cell:getIdx() + 1
			self:toHuoDong(curOpenHuoDong[index].id)
		end,

		})

	self.itemList:setPosition(0,self.bottomSize.height)
	local cell = self.itemList:cellAtIndex(0)
	local tutoBtn 
	if cell ~= nil then
		tutoBtn = cell:getBtn()
	end
	TutoMgr.addBtn("duobao_board",tutoBtn)

	local arena_cell = self.itemList:cellAtIndex(1)
	local arena_board 
	if arena_cell ~= nil then
		arena_board = arena_cell:getBtn()
	end
	TutoMgr.addBtn("jingjichang_board",arena_board)

	-- self:regNotice()
    -- PostNotice(NoticeKey.UNLOCK_BOTTOM)
	

	self:addChild(self.itemList)

	TutoMgr.active()
end


function HuodongScene:onExit()
	-- body
	TutoMgr.removeBtn("duobao_board")
	TutoMgr.removeBtn("jingjichang_board")
    -- self:unregNotice()

	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end


return HuodongScene