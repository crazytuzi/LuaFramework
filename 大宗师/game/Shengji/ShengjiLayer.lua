--[[
 --
 -- add by vicky
 -- 2014.08.14
 --
 --]]

local data_shengji_shengji = require("data.data_shengji_shengji") 
local data_level_level = require("data.data_level_level") 

local ShengjiLayer = class("ShengjiLayer", function()
	return require("utility.ShadeLayer").new()	
end)

function ShengjiLayer:onEnter()
	TutoMgr.addBtn("juqingzhandoujieshu_btn_quedinganniu", self._rootnode["confirmBtn"])
	TutoMgr.active()

end

function ShengjiLayer:onExit()
	TutoMgr.removeBtn("juqingzhandoujieshu_btn_quedinganniu")
	display.removeSpriteFramesWithFile("ui/ui_shengji.plist", "ui/ui_shengji.png")

	ResMgr.ReleaseUIArmature("shengji")
end

function ShengjiLayer:ctor(param)
	self._rootnode = {}
	local proxy = CCBProxy:create()
	self:setNodeEventEnabled(true)

	-- ResMgr.createBefTutoMask(self)

	local node = CCBuilderReaderLoad("shengji/shengji_layer.ccbi", proxy, self._rootnode)
	node:setPosition(display.width/2, display.height/2)
	self:addChild(node)

	local confirmFunc = param.confirmFunc 
	self._level = param.level 		-- 升级前等级 
	self._uplevel = param.uplevel 	-- 升级后等级 
	self._naili = param.naili 		-- 升级前耐力 
	self._curExp = param.curExp 	-- 当前经验值 

	game.player:updateLevelUpData({
		isLevelUp = true,
		beforeLevel = self._level, 
		curLevel = self._uplevel 
		})

	TutoMgr.lvlupSet(self._uplevel)

	self._rootnode["confirmBtn"]:addHandleOfControlEvent(function(eventName,sender)
			PostNotice(NoticeKey.REMOVE_TUTOLAYER) 
			if confirmFunc ~= nil then 
				confirmFunc() 
			end 
            self:removeFromParentAndCleanup(true)
        end, CCControlEventTouchUpInside)
	
	-- 特效
	local effect = ResMgr.createArma({
		resType = ResMgr.UI_EFFECT, 
		armaName = "shengji", 
		isRetain = false
		})
	effect:setScale(1.3)

	effect:setPosition(display.width/2, display.height/2)
	self:addChild(effect, 100)

	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shengji))

	self:initAllData()

	-- gameWorks 玩家升级
	-- grade, user, serverno, rolemark
	SDKGameWorks.GameUpGrade(game.player.m_level, game.player.m_uid, "1", "1")
	SDKTKData.setLevel({level=game.player.m_level})
    CSDKShell.submitExtData({
        isLevelUp = true
    })
end


-- 初始化所有的升级之后的结果
function ShengjiLayer:initAllData()
	-- 检测是否只升了一级
	local function getLevelupData()
		local naili = 0
		local coin = 0
		local xiakeNum = 0
		local start_index = 1
		local end_index = 1
		-- 检测是否跳级，比如从1到3级
		for i, v in ipairs(data_shengji_shengji) do 
			if v.level == self._level then
				start_index = i
				if self._uplevel == v.uplevel then
					end_index = i
					xiakeNum = v.num
				else
					for j, vd in ipairs(data_shengji_shengji) do 
						if vd.uplevel == self._uplevel then
							end_index = j
							xiakeNum = vd.num
							break
						end
					end
				end
				break
			end
		end

		-- dump(start_index)
		-- dump(end_index)
		for j = start_index, end_index do 
			-- dump(j)
			local v = data_shengji_shengji[j]
			naili = naili + v.naili
			coin = coin + v.coin
		end


		return naili, coin, xiakeNum
	end	

	local addNaili, addCoin, xiakeNum = getLevelupData() 

	-- 等级
	local lvLeft = self._rootnode["level_left"] 
	local lvRight = self._rootnode["level_right"] 
	local lvArrow = self._rootnode["level_arrow"] 
	lvLeft:setString("LV " .. self._level)
	lvRight:setString("LV " .. self._uplevel)
	lvArrow:setPositionX(lvLeft:getPositionX() + lvLeft:getContentSize().width + 10) 
	lvRight:setPositionX(lvArrow:getPositionX() + lvArrow:getContentSize().width + 10) 

	-- 耐力
	local nailiLeft = self._rootnode["naili_left"] 
	local nailiRight = self._rootnode["naili_right"]
	local nailiArrow = self._rootnode["naili_arrow"] 
	nailiLeft:setString(self._naili)
	nailiRight:setString(tostring(self._naili + addNaili))
	self._rootnode["nailiLbl"]:setString("+" .. addNaili) 

	nailiArrow:setPositionX(nailiLeft:getPositionX() + nailiLeft:getContentSize().width + 10) 
	nailiRight:setPositionX(nailiArrow:getPositionX() + nailiArrow:getContentSize().width + 10) 

	-- 上阵侠客数
	self._rootnode["xiakeNumLbl"]:setString(xiakeNum) 

	-- 升级奖励
	self._rootnode["rewardLbl"]:setString(addCoin)	

	-- -- 经验条
	-- self._rootnode["lvLbl"]:setString(self._uplevel)

	-- local maxExp = data_level_level[self._uplevel].exp 
 --    local percent = self._curExp/maxExp 
 --    local bar = self._rootnode["addBar"] 
 --    bar:setTextureRect(CCRectMake(bar:getTextureRect().origin.x, bar:getTextureRect().origin.y, 
 --        bar:getTextureRect().size.width*percent, bar:getTextureRect().size.height))


	-- 更新玩家数据
	local endNali = self._naili + addNaili
	local endGold = game.player:getGold() + addCoin

	game.player:updateMainMenu({
		naili = endNali, 
		lv = self._uplevel, 
		gold = endGold
		})
end



return ShengjiLayer
