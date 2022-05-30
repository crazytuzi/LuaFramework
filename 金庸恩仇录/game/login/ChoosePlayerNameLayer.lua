local data_playername_first_name = require("data.data_playername_first_name")
local data_playername_male = require("data.data_playername_male")
local data_playername_female = require("data.data_playername_female")
local data_pingbi_pingbi = require("data.data_pingbi_pingbi")
require("game.GameConst")

local PLAYERTYPE = {BOY = 1, GIRL = 2}

local ChoosePlayerNameLayer = class("ChoosePlayerNameLayer", function (...)
	display.addSpriteFramesWithFile("ui/ui_choose_player.plist", "ui/ui_choose_player.png")
	return require("utility.ShadeLayer").new()
end)


function ChoosePlayerNameLayer:ctor(listener)
	self.m_hascreated = false
	GameAudio.playMainmenuMusic(true)
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	self._listener = listener
	self._lastSexType = -1
	self._lastGenName = ""
	local proxy = CCBProxy:create()
	self._rootnode = {}
	self._startNode = CCBuilderReaderLoad("choosePlayer/choose_player_start_bg.ccbi", proxy, self._rootnode)
	self._startNode:setPosition(display.cx, display.cy)
	self:addChild(self._startNode, 1)
	self:changeSex(PLAYERTYPE.GIRL)
	
	--男主角
	self._rootnode.boyBtn:addHandleOfControlEvent(function ()
		self:changeSex(PLAYERTYPE.BOY)
	end,
	CCControlEventTouchUpInside)
	
	--女主角
	self._rootnode.girlBtn:addHandleOfControlEvent(function ()
		self:changeSex(PLAYERTYPE.GIRL)
	end,
	CCControlEventTouchUpInside)
	
	--下一步
	self._rootnode.nextBtn:addHandleOfControlEvent(function ()
		self:createNameLayer()
	end,
	CCControlEventTouchUpInside)
	
	self._isSystemName = false
end

function ChoosePlayerNameLayer:changeSex(type)
	self._sexType = type
	if self._sexType ~= self._lastSexType then
		self._lastSexType = self._sexType
		self._rootnode.playerIcon:setDisplayFrame(ResMgr.getHeroFrame(self._sexType, 0, 0))
		local effNode = self._rootnode.effect_node
		local effect = ResMgr.createArma({
		resType = ResMgr.UI_EFFECT,
		armaName = "huanren",
		isRetain = false
		})
		effect:setAnchorPoint(cc.p(0.5, 0))
		effect:setScaleX(1.2)
		effect:setPosition(effNode:getContentSize().width / 2, 0)
		effNode:addChild(effect)
	end
end


function ChoosePlayerNameLayer:setBtnDisabled()
	self.m_hascreated = true
	self:performWithDelay(function ()
		self.m_hascreated = false
	end,
	2)
end


function ChoosePlayerNameLayer:createNameLayer()
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("choosePlayer/choose_player_name_bg.ccbi", proxy, rootnode, self, CCSizeMake(display.width, display.height))
	node:setPosition(display.cx, display.cy)
	self:addChild(node, 2)
	rootnode.playerIcon:setDisplayFrame(ResMgr.getHeroFrame(self._sexType, 0, 0))
	
	--返回按钮
	rootnode.returnBtn:addHandleOfControlEvent(function ()
		node:removeFromParentAndCleanup(true)
	end,
	CCControlEventTouchUpInside)
	
	--创建角色
	rootnode.createBtn:addHandleOfControlEvent(function ()
		if self.m_hascreated == false then
			self:setBtnDisabled()
			self:chooseEnd()
		end
	end,
	CCControlEventTouchUpInside)
	
	--随机名字
	rootnode.randomBtn:addHandleOfControlEvent(function ()
		if self._editBox ~= nil then
			self._editBox:setText(self:genName())
		end
	end,
	CCControlEventTouchUpInside)
	
	local nameNode = rootnode.name_tag
	local cntSize = nameNode:getContentSize()
	self._editBox = ui.newEditBox({
	image = "#nameBg.png",
	size = cc.size(cntSize.width * 0.98, cntSize.height * 0.98),
	x = cntSize.width / 2,
	y = cntSize.height / 2,
	listener = function (event, editbox)
		if event == "began" then
			dump("began")
		elseif event == "ended" then
			dump("ended")
		elseif event == "return" then
			dump("return")
		else
			if event == "changed" then
				dump("changed")
				self._isSystemName = false
			else
			end
		end
	end
	})
	
	self._editBox:setFont(FONTS_NAME.font_fzcy, 32)
	self._editBox:setMaxLength(21)
	self._editBox:setPlaceholderFont(FONTS_NAME.font_fzcy, 32)
	self._editBox:setPlaceHolder(common:getLanguageString("@PlayerNameError"))
	self._editBox:setPlaceholderFontColor(FONT_COLOR.GRAY)
	self._editBox:setReturnType(1)
	self._editBox:setInputMode(0)
	nameNode:addChild(self._editBox, 10011)
	local defaultName = self:genName()
	self._editBox:setText(defaultName)
	
end


function ChoosePlayerNameLayer:genName(...)
	local prefixName = ""
	local postfixName = ""
	local genName = ""
	local safe_count = 0
	local function createName()
		safe_count = safe_count + 1
		local str_log = "random name count:" .. safe_count
		dump(str_log)
		if safe_count > 20 then
			return
		end
		prefixName = data_playername_first_name[math.random(1, #data_playername_first_name)].name
		if self._sexType == PLAYERTYPE.BOY then
			postfixName = data_playername_male[math.random(1, #data_playername_male)].name
		else
			postfixName = data_playername_female[math.random(1, #data_playername_female)].name
		end
		genName = prefixName .. postfixName
		if postfixName == genName then
			createName()
		end
		local maxLen = 12
		local length = string.utf8len(genName)
		dump("random str count:" .. length)
		if hasIllegalChar(genName) then
			createName()
		elseif length < 2 or maxLen < length then
			createName()
		end
	end
	
	createName()
	safe_count = 0
	dump(genName)
	self._isSystemName = true
	return genName
end

function ChoosePlayerNameLayer:checkSensitiveWord(wordStr)
	if self._isSystemName then
		dump("系统生成")
		return false
	end
	if common:checkSensitiveWord(wordStr) then
		return true
	end
	return ResMgr.checkSensitiveWord(wordStr)
end

function ChoosePlayerNameLayer:chooseEnd()
	if self._editBox ~= nil and self._editBox:getText() ~= nil then
		local playname = self._editBox:getText()
		local length = string.utf8len(playname)
		local GameDevice = require("sdk.GameDevice")
		if GameDevice.isContainsEmoji(playname) == true then
			show_tip_label(common:getLanguageString("@HintErrorTyping"))
			return
		end
		local maxLen = 12
		if length > 0 then
			local bContain = self:checkSensitiveWord(playname)
			if bContain then
				show_tip_label(common:getLanguageString("@ContentSensitive"))
			elseif hasIllegalChar(playname) then
				show_tip_label(common:getLanguageString("@HintErrorTyping"))
			elseif length < 2 or length > maxLen then
				show_tip_label(common:getLanguageString("@PlayerNameError"))
			else
				local function enterGame(info)
					dump("创建角色")
					SDKTKData.onCreateRole({
					name = info.account
					})
					if TargetPlatForm == PLATFORMS.THB then
						CSDKShell.regist({
						roleid = info.account,
						roleName = playname
						})
					end
					CCUserDefault:sharedUserDefault():setStringForKey("playerName", playname)
					CCUserDefault:sharedUserDefault():flush()
					if self._listener then
						self._listener()
					end
					self:removeSelf()
				end
				
				dump("==================register=====")
				SDKTKData.onRegister({
				account = game.player.m_uid
				})
				
				RequestHelper.game.register({
				rid = self._sexType,
				sessionId = game.player.m_sessionID,
				acc = game.player.m_uid,
				platformID = game.player.m_platformID,
				chn_flag = game.player.chn_flag or "",
				name = playname,
				callback = function (data)
					dump(data)
					if #data["0"] > 0 then
						show_tip_label(data_error_error[tonumber(data["0"])].prompt)
					else
						enterGame(data["1"])
					end
				end
				})
			end
		else
			show_tip_label(common:getLanguageString("@CreatePlayerName"))
		end
	end
end

function ChoosePlayerNameLayer:onExit()
	ResMgr.ReleaseUIArmature("huanren")
	display.removeUnusedSpriteFrames()
end

return ChoosePlayerNameLayer