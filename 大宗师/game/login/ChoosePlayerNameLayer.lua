 --[[
 --
 -- add by vicky 
 -- 2014.08.30
 --
 --]]

local data_playername_first_name = require("data.data_playername_first_name")
local data_playername_male = require("data.data_playername_male")
local data_playername_female = require("data.data_playername_female")
local data_pingbi_pingbi = require("data.data_pingbi_pingbi")

require("game.GameConst")

local PLAYERTYPE = {
	BOY     	= 1, 
	GIRL     	= 2  
 }


local ChoosePlayerNameLayer = class("ChoosePlayerNameLayer", function ( ... )
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

    -- 默认为女主角
    -- self._sexType = PLAYERTYPE.GIRL 
    -- self._lastSexType = self._sexType 
    -- self._rootnode["playerIcon"]:setDisplayFrame(ResMgr.getHeroFrame(self._sexType, 0))
    self:changeSex(PLAYERTYPE.GIRL) 

    self._rootnode["boyBtn"]:addHandleOfControlEvent(function()
    		self:changeSex(PLAYERTYPE.BOY)
	    end, CCControlEventTouchUpInside)

    self._rootnode["girlBtn"]:addHandleOfControlEvent(function()
    		self:changeSex(PLAYERTYPE.GIRL)
	    end, CCControlEventTouchUpInside)

    self._rootnode["nextBtn"]:addHandleOfControlEvent(function()
    		self:createNameLayer()
	    end, CCControlEventTouchUpInside) 

    self._isSystemName = false 

end


function ChoosePlayerNameLayer:changeSex(type) 
	self._sexType = type 
	if self._sexType ~= self._lastSexType then 

		self._lastSexType = self._sexType 
	    self._rootnode["playerIcon"]:setDisplayFrame(ResMgr.getHeroFrame(self._sexType, 0))

		-- 特效
		local effNode = self._rootnode["effect_node"] 

        local effect = ResMgr.createArma({
            resType = ResMgr.UI_EFFECT,
            armaName = "huanren",
            isRetain = false, 
        })

        effect:setAnchorPoint(ccp(0.5, 0)) 
        effect:setScaleX(1.2)
        effect:setPosition(effNode:getContentSize().width/2, 0)
        effNode:addChild(effect) 
	end 
end


function ChoosePlayerNameLayer:setBtnDisabled()
	self.m_hascreated = true 
	self:performWithDelay(function()
        self.m_hascreated = false 
    end, 2)
end


function ChoosePlayerNameLayer:createNameLayer()
	local proxy = CCBProxy:create()
    local rootnode = {}
	local node = CCBuilderReaderLoad("choosePlayer/choose_player_name_bg.ccbi", proxy, rootnode, self, CCSizeMake(display.width, display.height))
    node:setPosition(display.cx, display.cy)
    self:addChild(node, 2)

    rootnode["playerIcon"]:setDisplayFrame(ResMgr.getHeroFrame(self._sexType, 0))

    rootnode["returnBtn"]:addHandleOfControlEvent(function()
    		node:removeFromParentAndCleanup(true)
	    end, CCControlEventTouchUpInside)

    rootnode["createBtn"]:addHandleOfControlEvent(function()
    		if( self.m_hascreated == false ) then
    			self:setBtnDisabled() 
	    		self:chooseEnd()
	    	end
	    end, CCControlEventTouchUpInside)

    rootnode["randomBtn"]:addHandleOfControlEvent(function()
    		if self._editBox ~= nil then
    			self._editBox:setText(self:genName())
    		end
	    end, CCControlEventTouchUpInside)

    local nameNode = rootnode["name_tag"]
    local cntSize = nameNode:getContentSize()

    self._editBox = ui.newEditBox({
        image = "#nameBg.png",
        size = CCSizeMake(cntSize.width * 0.98, cntSize.height * 0.98),
        x = cntSize.width/2, 
        y = cntSize.height/2, 
        listener = function(event, editbox)   --监听事件  
            if event == "began" then          --点击editBox时触发（触发顺序1）  
                dump("began")
            elseif event == "ended" then        --输入结束时触发 （触发顺序3）  
                dump("ended")  
            elseif event == "return" then        --输入结束时触发（触发顺序4）  
                dump("return")  
            elseif event == "changed" then       --输入结束时触发（触发顺序2）  
                dump("changed") 
                self._isSystemName = false 
            else  
                -- printf("EditBox event %s", tostring(event))  
            end  
        end  
    })

    self._editBox:setFont(FONTS_NAME.font_fzcy, 32)
    self._editBox:setMaxLength(21)
    self._editBox:setPlaceholderFont(FONTS_NAME.font_fzcy, 32)
    self._editBox:setPlaceHolder("用户名(2-9个字符)")
    self._editBox:setPlaceholderFontColor(FONT_COLOR.GRAY)
    self._editBox:setReturnType(1)
    self._editBox:setInputMode(0)

    nameNode:addChild(self._editBox, 10011)

    local defaultName = game.player.m_loginName
    if(defaultName == "" or defaultName == nil) then
    	defaultName = self:genName()
    end
    self._editBox:setText(defaultName)
end


-- 名字要根据性别生成
function ChoosePlayerNameLayer:genName( ... )
	-- local middleName = BaseData_names_2[math.random(1,BaseData_names_2)].name
	local prefixName = "" 
	local postfixName = "" 
	local genName = "" 

	local function createName() 
		prefixName = data_playername_first_name[math.random(1,#data_playername_first_name)].name 

		if(self._sexType == PLAYERTYPE.BOY) then
			postfixName = data_playername_male[math.random(1,#data_playername_male)].name 
		else
			postfixName = data_playername_female[math.random(1,#data_playername_female)].name 
		end 

		genName = prefixName  .. postfixName  

		if postfixName == genName then 
			createName() 
		end 
	end 
	
	createName() 

	dump(genName) 

	self._isSystemName = true  

	return genName  
end


-- 检测是否含有敏感词汇 
function ChoosePlayerNameLayer:checkSensitiveWord(wordStr)
	if self._isSystemName then 
		return false 
	end 

	return ResMgr.checkSensitiveWord(wordStr) 

	-- while string.find(wordStr, " ") do 
	--  	wordStr = string.gsub(wordStr, " ", "") 
	-- end 

	-- if(string.len(wordStr) == 0) then
	-- 	return true
	-- end
	
	-- local contian 
	-- for i, v in ipairs(data_pingbi_pingbi) do 
	-- 	contian = string.find(wordStr, v.words)
	-- 	if contian ~= nil then 
	-- 		dump(contian)
	-- 		dump(v.id)
	-- 		dump(v.words)
	-- 		break
	-- 	end
	-- end 

	-- if contian ~= nil then 
	-- 	return true 
	-- else
	-- 	return false
	-- end 
	
end


-- 创建角色
function ChoosePlayerNameLayer:chooseEnd()
	if self._editBox ~= nil and self._editBox:getText() ~= nil then
		-- 实际字的个数
		local playname = self._editBox:getText()
		local isCnChar = isCnChar(playname)
		local length = string.utf8len(playname)
		local GameDevice = require("sdk.GameDevice")
		if(GameDevice.isContainsEmoji( playname ) == true) then
			show_tip_label("含有非法字符，请重新输入")
			return
		end

		local maxLen = 6
		if(isCnChar ~= true) then
			maxLen = 9
		end

		if length > 0 then
			local bContain = self:checkSensitiveWord(playname)

			if bContain then
				show_tip_label("含有敏感词汇，请重新输入")
			elseif(hasIllegalChar(playname)) then
				show_tip_label("含有非法字符，请重新输入")
			elseif length < 2 or length > maxLen then
				show_tip_label("昵称长度须为2~9个字符")
			else
				CCUserDefault:sharedUserDefault():setStringForKey("accid", os.time())
				CCUserDefault:sharedUserDefault():flush() 
				local function enterGame(info)
					
					dump(info)
					-- gameworks 创建角色
					SDKGameWorks.CreateRole(info.account, "1", "1")

					CCUserDefault:sharedUserDefault():setStringForKey("playerName", playname)
					CCUserDefault:sharedUserDefault():flush()

                    if self._listener then
                        self._listener()
                    end
				    self:removeSelf()

				end
				dump("==================register=====")
				-- 玩家注册
			    RequestHelper.game.register({
					rid        = self._sexType,
					sessionId  = game.player.m_sessionID,
					acc        = game.player.m_uid,
					platformID = game.player.m_platformID,
					name       = playname,
		            callback = function(data)
		            	dump(data)
		                if(#data["0"] > 0 ) then
                            -- device.showAlert("DATA ERROR", data["0"])
                            show_tip_label(data_error_error[100001].prompt)
		                else
                            enterGame(data["1"])
		                end
		            end,
		            
		        })
			end
		else
			show_tip_label("请输入或选择角色昵称")
		end
	end
end

function ChoosePlayerNameLayer:onExit()
	ResMgr.ReleaseUIArmature("huanren")
	display.removeUnusedSpriteFrames()
end

return ChoosePlayerNameLayer