EVENT={

LUAEVENT_INIT_GAME=0,
LUAEVENT_ASYNCLOAD_TEXTURE=1,
LUAEVENT_ASYNCLOAD_FRAMES=2,
LUAEVENT_SOCKET_ERROR=3,
LUAEVENT_ON_MESSAGE=4,

LUAEVENT_AFTER_ADD_NET_GHOST = 5,

LUAEVENT_WALK_UPDATE = 6,

LUAEVENT_ENTER_GAME=10,
LUAEVENT_ENTER_MAP=11,
LUAEVENT_SCENE_GAME_ENTER=12,
LUAEVENT_SCENE_GAME_EXIT=13,
LUAEVENT_SCENE_GAME_UPDATE=14,
LUAEVENT_SELECT_SOME_ONE=15,
LUAEVENT_ON_ATTACKED=16,

LUAEVENT_DO_ACTION=20,
LUAEVENT_AUTOMOVE_START=21,
LUAEVENT_AUTOMOVE_END=22,
LUAEVENT_MAINROLE_ATTACH=23,
LUAEVENT_MAINROLE_DETACH=24,
LUAEVENT_MAINROLE_UPDATE=25,
LUAEVENT_MAINROLE_TICK_UPDATE=26,
LUAEVENT_MAINROLE_ACTIONSTART=27,
LUAEVENT_MAINROLE_ACTIONEND=28,

LUAEVENT_MAP_MEET=29,
LUAEVENT_MAP_BYE=30,

LUAEVENT_GHOST_DIE=31,
LUAEVENT_MAINROLE_STATUS=32,
LUAEVENT_MAINROLE_AUTOMOVE=33,
LUAEVENT_CAST_SKILL=34,
LUAEVENT_DOWNLOAD_SUCCESS=35,

LUAEVENT_DOWNLOAD_PROGRESS=36,
LUAEVENT_DOWNLOAD_FAILED=37,
LUAEVENT_PROTECTBODY_CHANGE=38,

LUAEVENT_BUFF_CHANGE=39,

}

local Node = cc.Node
Node.getNameOld = Node.getName
Node.getName = nil
function Node:getName()
    local this = self
	if GameUtilBase.isObjectExist(this) then
    	return this:getNameOld()
    else
    	return ""
    end
end

local Widget = ccui.Widget
Widget.addClickOld = Widget.addClickEventListener
Widget.addClickEventListener = nil
function Widget:addClickEventListener(callback)
	local this = self
    this:addClickOld(function(event)
        if this:getDescription()=="Button" then
        	if this:getName()=="panel_close" then
				GameMusic.play("music/30.mp3")
			else
            	GameMusic.play("music/32.mp3",1)
            end
        end
        if callback then
            callback(event)
        end
    end)
    return this
end
Widget.getWidgetByNameOld = Widget.getWidgetByName
Widget.getWidgetByName = nil
function Widget:getWidgetByName(name)
	local this = self

	if not GameUtilBase.isObjectExist(this) then
		if _G.buglyReportLuaException then
	        buglyReportLuaException("parent widget is null", "getWidgetByName:"..name)
	    end
		return nil
	end

	return this:getWidgetByNameOld(name)
end

function ccui.Widget:setRedPointVisible(vis)
	if vis then
		GUIFocusDot.addRedPointToTarget(self)
		self:getWidgetByName("redPoint"):show()
	else
		if self:getWidgetByName("redPoint") then
			self:getWidgetByName("redPoint"):hide()
		end
	end
end

cc.Node.setAnchorPointOld = cc.Node.setAnchorPoint
cc.Node.setAnchorPoint = nil
function cc.Node:setAnchorPoint(x,y)
	local this,anchor = self,x
	if not x and not y then print("node setAnchorPoint params error "..this:getName()) return this end
	if y then
		anchor = cc.p(x,y)
	end
	return this:setAnchorPointOld(anchor)
end
local Text = ccui.Text
Text.setStringOld = Text.setString
Text.setString = nil
function Text:setString(string)
	local this = self
	if type(string)~="number" and type(string)~="string" then
		return this
	end
	this:setStringOld(string)

	return this
end

local Image = ccui.ImageView
Image.loadTextureOld = Image.loadTexture
function Image:loadTexture(texture,restype)
	local this = self
	if not restype then restype = ccui.TextureResType.localType end
	if restype == ccui.TextureResType.plistType then
		if cc.SpriteFrameCache:getInstance():getSpriteFrame(texture) then
			this:loadTextureOld(texture,restype)
		end
	end
	if restype == ccui.TextureResType.localType then
		if cc.FileUtils:getInstance():isFileExist(texture) then
			this:loadTextureOld(texture,restype)
		end
	end
	return this
end

local Button = ccui.Button
Button.loadTextureNormalOld = Button.loadTextureNormal
function Button:loadTextureNormal(texture,restype)
	local this = self
	if not restype then restype = ccui.TextureResType.localType end
	if restype == ccui.TextureResType.plistType then
		if cc.SpriteFrameCache:getInstance():getSpriteFrame(texture) then
			this:loadTextureNormalOld(texture,restype)
		end
	end
	if restype == ccui.TextureResType.localType then
		if cc.FileUtils:getInstance():isFileExist(texture) then
			this:loadTextureNormalOld(texture,restype)
		end
	end
	return this
end
Button.loadTexturePressedOld = Button.loadTexturePressed
function Button:loadTexturePressed(texture,restype)
	local this = self
	if not restype then restype = ccui.TextureResType.localType end
	if restype == ccui.TextureResType.plistType then
		if cc.SpriteFrameCache:getInstance():getSpriteFrame(texture) then
			this:loadTexturePressedOld(texture,restype)
		end
	end
	if restype == ccui.TextureResType.localType then
		if cc.FileUtils:getInstance():isFileExist(texture) then
			this:loadTexturePressedOld(texture,restype)
		end
	end
	return this
end
Button.loadTextureDisabledOld = Button.loadTextureDisabled
function Button:loadTextureDisabled(texture,restype)
	local this = self
	if not restype then restype = ccui.TextureResType.localType end
	if restype == ccui.TextureResType.plistType then
		if cc.SpriteFrameCache:getInstance():getSpriteFrame(texture) then
			this:loadTextureDisabledOld(texture,restype)
		end
	end
	if restype == ccui.TextureResType.localType then
		if cc.FileUtils:getInstance():isFileExist(texture) then
			this:loadTextureDisabledOld(texture,restype)
		end
	end
	return this
end
Button.loadTexturesOld = Button.loadTextures
function Button:loadTextures(normal,selected,disabled,restype)
	local this = self
	if not restype then restype = ccui.TextureResType.localType end
	if normal and normal~="" then
		this:loadTextureNormal(normal,restype)
	end
	if selected and selected~="" then
		this:loadTexturePressed(selected,restype)
	end
	if disabled and disabled~="" then
		this:loadTextureDisabled(disabled,restype)
	end
	return this
end

local mapItemIds = {}

function set_item_name(srcid,mNameLabel)
	if not mNameLabel then return end
	local item=NetCC:getGhostByID(srcid)
	if not item then return end
	local typeid=item:NetAttr(GameConst.net_itemtype)
	if not typeid then return end
	local itemdef = GameSocket:getItemDefByID(typeid)
	if not itemdef then return end
	local itemname = item:NetAttr(GameConst.net_name)
	if not itemname then return end
	-- if GameBaseLogic.getPickState(typeid) then
		mNameLabel:setString(itemname)
	-- end
	mNameLabel:setTextColor(GameBaseLogic.getItemColor(itemdef.mEquipLevel))
end

function play_effect_sound(soundid,frame,onwer)
	if G_SwitchEffect <1 then
		-- if GameCharacter.mID and GameCharacter.mID>0 and GameCharacter.mID == onwer then
			if soundid == "10000" then
				local pixesmain = GameCharacter.updateAttr()
				if pixesmain then
					if pixesmain:NetAttr(GameConst.net_gender) == GameConst.SEX_MALE then
						soundid = "2"
					end
				end
			end

			local soundfile = "music/"..soundid..".mp3"
			GameMusic.play(soundfile)
		-- end
	end
end

-- function on_buff_change(srcid,buffid)
-- 	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_BUFF_CHANGE, srcId = srcId, buffId = buffId})
-- end
-- cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_BUFF_CHANGE,"on_buff_change")


function set_blood_pos(posy,bloodBg,netid)
	-- local ghsot = NetCC:getGhostByID(tonumber(netid))
	-- if ghsot then
	-- 	if ghsot:NetAttr(GameConst.net_type) == GameConst.GHOST_MONSTER and ghsot:NetAttr(GameConst.net_name) == "雕像" then
	-- 		bloodBg:setPositionY(posy-200)
	-- 	end
	-- end
end

function show_monster_name(flags,nameSprite,name)
	if not nameSprite then return end
	local nameLabel = nameSprite:getChildByName("mNameLabel")
	if nameLabel then
		nameLabel:setString(name)
	end
	-- if nameLabel and name == "雕像" then
	-- 	nameLabel:setPositionY(-200)
	-- end
	-- if not mNameSprite then return end
	-- local posX, posY = mNameSprite:getPosition()
	-- local mTitleSprite = nameSprite:getChildByName("mTitleSprite")
	-- if mTitleSprite then
	-- 	mTitleSprite:setPositionY(posY - (110-TILE_HEIGHT/2 + 30) + 50)
	-- end
end

function show_ghost_name(srcid,nameSprite,name)
	local pixeAvatar = CCGhostManager:getPixesAvatarByID(srcid)
	if not pixeAvatar then return end

	local ghostType = pixeAvatar:NetAttr(GameConst.net_type)
	if ghostType == GameConst.GHOST_NEUTRAL then
		-- print("/////////////////////////show_ghost_name/////////////////////////////////////", srcid)
		local nameLabel = nameSprite:getChildByName("mNameLabel")
		-- if nameLabel then nameLabel:setTextColor(GameBaseLogic.getColor(0x000000)) end
		if not nameLabel then return end

		local refreshTime = pixeAvatar:NetAttr(GameConst.net_collecttime)
		if not refreshTime then return end
		if refreshTime > 0 then

			local lblRefreshTime = nameSprite:getChildByName("lbl_refresh_time")
			if not lblRefreshTime then
				local posX, posY = nameLabel:getPosition()
				lblRefreshTime = ccui.Text:create("", FONT_NAME, 16):setTextColor(GameBaseLogic.getColor(0xFF3E3E)):addTo(nameSprite):enableOutline(GameBaseLogic.getColor(0x000000), 1)
				lblRefreshTime:setPosition(posX, posY + 25)
				lblRefreshTime:setName("lbl_refresh_time")
			end
			local endTime = os.time() + refreshTime
			lblRefreshTime:setString("复活时间："..GameUtilBase.setTimeFormat(refreshTime*1000,2))
			lblRefreshTime:stopAllActions()
			lblRefreshTime:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.cb(function (target)
				if endTime-os.time() >= 0 then
					target:setString("复活时间："..GameUtilBase.setTimeFormat((endTime - os.time())*1000,2))
				else
					target:stopAllActions()
				end
			end)})))
		end
	end
end

function show_dart_name(nameSprite, name)
	if not (nameSprite and name) then return end
	local mNameLabel = nameSprite:getChildByName("mNameLabel")
	if not mNameLabel then
		mNameLabel = ccui.Text:create("", FONT_NAME, 18):setColor(cc.c3b(255, 255, 255)):addTo(nameSprite):enableOutline(GameBaseLogic.getColor(0x000000), 1)
		nameSprite:setPosition(TILE_WIDTH * 0.5, 140 - TILE_HEIGHT * 0.5);
	end
	mNameLabel:setString(name)
end

function show_npc_flags(flags,nameSprite,name)
	-- print("The Map NPC Info:",flags,GameConst.GHOST_NPC,nameSprite:getChildByName("mNameLabel"):getString())

	local function npc_task_change(flags,anim)
		local binid
		if flags == -10 then
			binid = 50010
		elseif flags == 10 then
			binid = 50011
		else
			binid = 50012
		end
		anim:stopAllActions()
		-- anim:setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
		-- if anim.posX and anim.posY then
		-- 	anim:pos(anim.posX, anim.posY);
		-- end
		--cc.AnimManager:getInstance():getPlistAnimateAsync(anim,4,binid,4,0)
		GameUtilSenior.addEffect(anim,"spriteEffect",GROUP_TYPE.EFFECT,binid,false,false,true)
		-- cc.AnimManager:getInstance():getBinAnimateAsync(anim,4,binid,0,0,true)
		-- anim:playAnimationForever(display.newAnimation(display.newFrames("npc_"..frames.."_%1d", 1, 6), 1 / 6))
	end

	if nameSprite then
		local createType = false
		if not nameSprite:getChildByName("npc_task") then
			local nameLabel = nameSprite:getChildByName("mNameLabel")
			local pos = cc.p(0,0)
			if nameLabel then pos = cc.p(nameLabel:getPosition()) end
			-- local npcName = nameLabel:getString()
			if nameLabel and name == "城主雕像" then
				nameLabel:setPositionY(-200)
			end
			local anim = cc.Sprite:create()
						:align(display.CENTER, pos.x, pos.y+50)
						:addTo(nameSprite)
						:setName("npc_task")
						:setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
						:setTag(10086)
			-- anim.posX = pos.x
			-- anim.posY = pos.y+50
			-- print("new npc task", pos.x, pos.y);
			-- local blend = anim:getBlendFunc()
			-- print("blend 111", blend.src, blend.dst, anim:getPositionX(), anim:getPositionY())
			if flags == 10 or flags == 1 or flags == -10 then
				npc_task_change(flags,anim)
			elseif flags == 0 then
				-- local npcName = nameLabel:getString()
				-- local npcType

				-- --显示气泡机制，暂时隐藏
				-- local keyWordTable = {
				-- 	["传送"] = "Transmit",
				-- 	["回收"] = "Recover",
				-- 	["暗殿"] = "SpecialMap",
				-- 	["神殿"] = "SpecialMap",
				-- 	["boss"] = "SpecialMap",
				-- 	["经验"] = "EXP",
				-- 	["活动"] = "Activity",
				-- 	["福利"] = "Material",
				-- 	["任务"] = "Task",
				-- }

				-- for k,v in pairs(keyWordTable) do
				-- 	if string.find(npcName,k) then
				-- 		npcType = v
				-- 		createType = true
				-- 		break
				-- 	end
				-- end

				-- if not createType then return end

				-- local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("img_NPC_"..npcType)
				-- if frame then
				-- 	anim:setSpriteFrame(frame)
				-- end

				-- local animSize = anim:getContentSize()
				-- anim:align(display.CENTER, pos.x, pos.y+animSize.height+10)
			end
		else
			if flags == 10 or flags == 1 then
				npc_task_change(flags,nameSprite:getChildByName("npc_task"))
			elseif flags == 0 and not createType then
				nameSprite:removeChildByName("npc_task")
			end
		end
	end
end

local fightPre = {
	[100] = {pre = "dyzs", res = "img_title_warrior_no1"},
	[101] = {pre = "dyfs", res = "img_title_wizard_no1"},
	[102] = {pre = "dyds", res = "img_title_taoist_no1"},
}

-- local titleText = {
-- 	"初出茅庐","略有所成","游刃有余","融会贯通","人中豪杰",
-- 	"威震八方","战无不胜","横扫千军","万夫莫开","盖世奇侠",
-- }

local officialTitle  = {
	"十品芝麻官","正十品芝麻官","九品仕长","正九品仕长","八品百夫长",
	"正八品百夫长","七品校尉","正七品校尉","六品护军","正六品护军",
	"五品先锋","正五品先锋","四品中郎将","正四品中郎将","三品镇远将军",
	"正三品镇远将军","二品镇国大将军","正二品镇国大将军","一品大都督","正一品大都督",
}

local titleRes = {
	["highplay"] = {"img_title_master", "img_title_warrior", "img_title_wizard", "img_title_taoist"},
	-- ["highplay"] = {"img_title_master", "img_title_warrior", "img_title_wizard", "img_title_taoist"},
}

function show_player_title(srcid, nameSprite)
	--print(mNetGhost:NetAttr(GameConst.net_guild_title))
	if not nameSprite then return end
	local mNetGhost = NetCC:getGhostByID(srcid)
	local mPixesAvatar = CCGhostManager:getPixesAvatarByID(srcid)
	if mNetGhost then
		if not PLATFORM_BANSHU then
			--显示左侧VIP称号
			show_player_vip(srcid)
		end
		local frameName, kingGuild, officialIndex, highplayIndex,shiwangflag,newTitle,kuangbao

		--------优先玛法主宰者--------
		if mNetGhost:NetAttr(GameConst.net_guild_name) == GameSocket.mKingGuild or mNetGhost:NetAttr(GameConst.net_guild_name) == GameSocket.KHcandidate then
			kingGuild = true
			if mNetGhost:NetAttr(GameConst.net_guild_title) == 1000 then
				frameName = titleRes["highplay"][1]
			end
		end


		local namePreValue = mNetGhost:NetAttr(GameConst.net_name_pre)
		if namePreValue and namePreValue ~= "" then
			local namePre = string.split(namePreValue,"|")
			--print(">---->",namePreValue)
			for k,v in pairs(namePre) do
				if string.find(v, "guanwei_") then
					officialIndex = tonumber(string.sub(v, 9))
				elseif not frameName then
					if string.find(v, "highplay_") then
						highplayIndex = tonumber(string.sub(v, 10))
					end
				end
				if string.find(v,"shiwangTime_") then

					shiwangflag=tonumber(string.sub(v, 13,23))
					--print(shiwangflag,v,">>>>>>>>>>>>>")
				end
				if string.find(v,"newTitle_") then

					newTitle=string.sub(v, 10,string.len(v))
					print(newTitle,v,">>>>>>>>>>>>>")
				end
				if string.find(v,"kuangbao_") then

					kuangbao=string.sub(v, 10,string.len(v))
					print(kuangbao,v,">>>>>>>>>>>>>")
				end
				--print("shiwangflag",shiwangflag)
			end

			if highplayIndex and titleRes["highplay"][highplayIndex] then
				frameName = titleRes["highplay"][highplayIndex]
			end
		end
		--------------------倒计时-----------img_flag_shiwang
		-- if time>0 then
		-- 	labTime:stopAllActions()
		-- 	labTime:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function ()
		-- 	shiwangflag = data.time - 1000
		-- 	if data.time > 0 then
		-- 		labTime:setString(GameUtilSenior.setTimeFormat(data.time,3))
		-- 	else
		-- 		labTime:stopAllActions()
		-- 	end
		-- 	end)})))
		-- end
		-- local mTitleTime = nameSprite:getChildByName("mTitleTime")
		-- local time = 30*1000

		-- if namePreValue and namePreValue ~= "" then
		-- 	local namePre = string.split(namePreValue,"|")
		-- 	if table.indexof(namePre, "time") then
		-- 		frameName = "img_star_big"
		-- 		if not mTitleTime then
		-- 			mTitleTime = ccui.Text:create()
		-- 			:align(display.CENTER,0, -50)
		-- 			:addTo(nameSprite)
		-- 			:setName("mTitleTime")
		-- 			:setString("00:30")
		-- 			:setFontSize(18)
		-- 			:setFontName(FONT_NAME)
		-- 			:setColor(cc.c3b(0,255,0))
		-- 		mTitleTime:stopAllActions()
		-- 		mTitleTime:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function ()
		-- 		time = time - 1000
		-- 		if time > 0 then
		-- 			mTitleTime:setString(GameUtilSenior.setTimeFormat(time,3))
		-- 		else
		-- 			mTitleTime:stopAllActions()
		-- 		end
		-- 	end)})))
		-- 		end
		-- 		local height = 20
		-- 		height = height + (mTitleLabel and 30 or 0)
		-- 		height = height + (kingGuild and 10 or 0)
		-- 		mTitleTime:pos(0, height)
		-- 	end
		-- elseif mTitleTime then
		-- 	mTitleTime:removeFromParent()
		-- end

		------------------------------------

		-- 官职称号
		local mOfficialTitle = nameSprite:getChildByName("mOfficialTitle")
		if officialIndex and officialIndex > 0 then
			local tempText = officialTitle[officialIndex]
			if tempText then
				if not mOfficialTitle then
					mOfficialTitle = ccui.Text:create("", FONT_NAME, 16)
						:enableOutline(GameBaseLogic.getColor(0x000000),1)
						:setColor(GameBaseLogic.getColor(0xFEF539))
						:setName("mOfficialTitle")
						:addTo(nameSprite)
						:pos(0, 23)
				end
				mOfficialTitle:setString(tempText)
			end
		elseif mOfficialTitle then
			mOfficialTitle:removeFromParent()
			mOfficialTitle = nil
		end
		---暂时隐藏官职称号
		if mOfficialTitle~=nil then
			mOfficialTitle:setVisible(false)
		end

		------ 尸王倒计时
		local mCountDown = nameSprite:getChildByName("mCountDown")
		local icon_book = nameSprite:getChildByName("icon_book")
		if not icon_book then
			icon_book = cc.Sprite:createWithSpriteFrameName("img_flag_shiwang")
				:setName("icon_book")
				:addTo(nameSprite)
				:pos(0, 144)
		else
			icon_book:initWithSpriteFrameName("img_flag_shiwang")
		end
		icon_book:setVisible(false)
		--print(">>>>>>>>>>>>>",shiwangflag)
		if shiwangflag and shiwangflag > 0 then
			if shiwangflag then
				if not mCountDown then
					mCountDown = ccui.Text:create("00:00", FONT_NAME, 20)
						:enableOutline(GameBaseLogic.getColor(0x000000),1)
						:setColor(GameBaseLogic.getColor(0xFF0000))
						:setName("mCountDown")
						:addTo(nameSprite)
						:pos(0, 144)
				end

				if icon_book then
					local nameWidth = mCountDown:getContentSize().width
					local vipWidth = icon_book:getContentSize().width
					icon_book:setPositionX(- nameWidth * 0.5 - 20)
					mCountDown:setPositionX(vipWidth * 0.5)
				end

				if shiwangflag>0 then
					--print(">>>>>-----",shiwangflag)
						mCountDown:stopAllActions():setVisible(true):setString(GameUtilBase.setTimeFormat(shiwangflag+180-os.time(),3))
						icon_book:setVisible(true)
						mCountDown:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function ()
							--shiwangflag = shiwangflag - 1000
							--print(shiwangflag+180-os.time()-1)
							if shiwangflag+180-os.time() > 0 then
								mCountDown:setString(GameUtilBase.setTimeFormat((shiwangflag+180-os.time())*1000,3))

							else
								mCountDown:stopAllActions():setVisible(false)
								icon_book:setVisible(false)
							end
						end)})))
				end
				--mCountDown:setString(shiwangflag)
			end
		elseif mCountDown then
			mCountDown:removeFromParent()
			mCountDown = nil
		end
		--------------------------



		local mTitleSprite = nameSprite:getChildByName("mTitleSprite")
		if frameName and G_ShieldTitle==0 then
			if not mTitleSprite then
				mTitleSprite = cc.Sprite:createWithSpriteFrameName(frameName)
					:setName("mTitleSprite")
					:addTo(nameSprite)
			else
				mTitleSprite:initWithSpriteFrameName(frameName)
			end
			local height = 90
			height = height + (mTitleLabel and 30 or 0)
			height = height + (kingGuild and 10 or 0)
			print(height,"mTitleSprite=====")
			mTitleSprite:pos(0, height)
		elseif mTitleSprite then
			mTitleSprite:removeFromParent()
			mTitleSprite = nil
		end
		

		if mOfficialTitle then mOfficialTitle:setPositionY(23) end

		local mGuildLabel = nameSprite:getChildByName("mGuildLabel")
		local guildName = ""
		if mGuildLabel then
			guildName = mNetGhost:NetAttr(GameConst.net_guild_name)
			local guildTitle = mNetGhost:NetAttr(GameConst.net_guild_title)

			if guildTitle < 102 then
				guildName = ""
			elseif guildTitle == 102 then
				guildName = guildName.."(帮众)"
			elseif guildTitle == 200 then
				guildName = guildName.."(长老)"
			elseif guildTitle == 300 then
				guildName = guildName.."(副帮主)"
			elseif guildTitle == 1000 then
				guildName = guildName.."(帮主)"
			end
			if guildName ~= "" then
				local guildPrefix = mNetGhost:NetAttr(GameConst.net_guild_name) == GameSocket.KHcandidate and "[皇城]" or nil
				if guildPrefix then
					mGuildLabel:setString(guildPrefix..guildName)
					-- mGuildLabel:setTextColor(cc.c4f(255,204, 204, 255))
				elseif kingGuild then
					mGuildLabel:setString("[皇城]"..guildName)
					-- mGuildLabel:setTextColor(cc.c4f(89,165,239, 255))
				else
					mGuildLabel:setString(guildName)
					mGuildLabel:setTextColor(cc.c4f(251, 210, 142, 255))
				end
			else
				mGuildLabel:setString(guildName)
				mGuildLabel:setTextColor(cc.c4f(251, 210, 142, 255))
			end
			if mOfficialTitle then mOfficialTitle:setPositionY(23 + 24) end
		end
		updateNameColor(srcid)

		local mNewTitleSprite = nameSprite:getChildByName("mNewTitleSprite")
		if newTitle and G_ShieldTitle==0 then
			if not mNewTitleSprite then
				mNewTitleSprite = cc.Sprite:create()
					:setName("mNewTitleSprite")
					:addTo(nameSprite)
			else
				--mNewTitleSprite:initWithSpriteFrameName(newTitle)
			end
			
			mNewTitleSprite:removeChildByName("spriteEffect")
			--GameUtilSenior.addEffect(mNewTitleSprite,"spriteEffect",4,newTitle,false,false,true)
			GameUtilSenior.addEffect(mNewTitleSprite,"spriteEffect",GROUP_TYPE.TITLE,newTitle,false,false,true)
	
			local height = 0
			height = height + (mTitleLabel and 30 or 0)
			--height = height + (kingGuild and 10 or 0)
			if guildName~="" then
				height = height + 24
			end
			print("mNewTitleSprite",height)
			mNewTitleSprite:pos(0, height-130)
			mNewTitleSprite:setAnchorPoint(cc.p(0.5,0))
		elseif mNewTitleSprite then
			mNewTitleSprite:removeFromParent()
			mNewTitleSprite = nil
		end
		
		--狂暴
		if kuangbao then
			local mKuangBaoLabel = nameSprite:getChildByName("mKuangBaoLabel")
			if not mKuangBaoLabel then
				mKuangBaoLabel = cc.Sprite:create()
					:setName("mKuangBaoLabel")
					:addTo(nameSprite)
					:setPosition(0,30)
					:setAnchorPoint(cc.p(0.5,0))
			end
			mKuangBaoLabel:removeChildByName("spriteEffect1")
			mKuangBaoLabel:removeChildByName("spriteEffect2")
			if tonumber(kuangbao)>0 then
				GameUtilSenior.addEffect(mKuangBaoLabel,"spriteEffect1",4,kuangbao,false,false,true)
				GameUtilSenior.addEffect(mKuangBaoLabel,"spriteEffect2",4,tonumber(kuangbao)+1,false,false,true)
			end
		end
		
		
		--VIP显示
		show_player_vip(srcid)
		
		
		--依据死亡状态控制和显示称号
		if mTitleSprite then
			if mNetGhost:NetAttr(GameConst.net_dead) or mNetGhost:NetAttr(GameConst.net_hp) <= 0 then
				mTitleSprite:hide()
			else
				mTitleSprite:show()
			end
		end
	end
end

--魂环
function show_player_shadow(srcid, shadowSprite)
	local mPixesAvatar = CCGhostManager:getPixesAvatarByID(srcid)
	if not mPixesAvatar then return end
	
	--local mNetGhost = NetCC:getGhostByID(srcid)

	shadowSprite:removeChildByName("spriteEffect")
	local shadowValue = mPixesAvatar:NetAttr(GameConst.net_shadow_id)
	if shadowValue and shadowValue ~= "" then
		GameUtilSenior.addEffect(shadowSprite,"spriteEffect",4,shadowValue,{x = 0 , y = 0},false,true)
	end
end

--怪物称号部分
function show_monster_title(srcid, nameSprite)
	local mPixesAvatar = CCGhostManager:getPixesAvatarByID(srcid)
	if not mPixesAvatar then return end

	local ghostType = mPixesAvatar:NetAttr(GameConst.net_type)
	if ghostType == GameConst.GHOST_DART then
		return GUIMain.showDartHalo(ghostType, mPixesAvatar)
	end

	if ghostType == GameConst.GHOST_MONSTER then
		handleMonsterVisible(ghostType, mPixesAvatar)
	end

	-- if ghostType == GameConst.GHOST_NEUTRAL then
	-- 	show_ghost_name(srcid,nameSprite)
	-- end

	-- local nameSprite = mPixesAvatar:getNameSprite()
	if not nameSprite then return end
	local frameName
	local index = mPixesAvatar:NetAttr(GameConst.net_show_head)
	if tonumber(index) and titleRes["highplay"][index] then
		frameName = titleRes["highplay"][index]
	end
	nameSprite:setPosition(TILE_WIDTH * 0.5, 110-TILE_HEIGHT/2)
	local mTitleSprite = nameSprite:getChildByName("mTitleSprite")
	if frameName and G_ShieldTitle==0 then
		if not mTitleSprite then
			mTitleSprite = cc.Sprite:createWithSpriteFrameName(frameName)
				:setName("mTitleSprite")
				:align(display.CENTER, 0 , 60)
				:addTo(nameSprite)
		else
			mTitleSprite:initWithSpriteFrameName(frameName)
		end
	elseif mTitleSprite then
		mTitleSprite:removeFromParent()
		mTitleSprite = nil
	end

	--依据死亡状态控制和显示称号
	if mTitleSprite then
		if mPixesAvatar:NetAttr(GameConst.net_dead) or mPixesAvatar:NetAttr(GameConst.net_hp) <= 0 then
			mTitleSprite:hide()
		else
			mTitleSprite:show()
		end
	end
end

function updateNameColor(srcid) -- 战场，帮会，红名
	local mPixesAvatar = CCGhostManager:getPixesAvatarByID(srcid)
	if mPixesAvatar and mPixesAvatar:getNameSprite() then
		local nameSprite = mPixesAvatar:getNameSprite()
		local mNameLabel = nameSprite:getChildByName("mNameLabel")
		if not mNameLabel then return end
		local nameColor = cc.c4f(255, 255, 255, 255)

		-- 依据pk值修改
		local pkvalue = mPixesAvatar:NetAttr(GameConst.net_pkvalue) or 0
		local pkstate = mPixesAvatar:NetAttr(GameConst.net_pkstate) or 0
		-- print("//////////////////////////updateNameColor////////////////////", mPixesAvatar:NetAttr(GameConst.net_name), pkvalue, pkstate)
		if pkvalue >= 400 then
			nameColor = GameBaseLogic.getColor4(0xf50428)
		elseif pkstate > 0 then
			nameColor = GameBaseLogic.getColor4(0x7e5d48)
		elseif pkvalue >= 100 then
			nameColor = GameBaseLogic.getColor4(0xe4ed50)
		end

		-- 依据攻击模式修改
		local ghostType, mainAvatar
		if GameSocket.mAttackMode == 102 then -- 组队
			mainAvatar = cc.GhostManager:getInstance():getMainAvatar()
			ghostType = mPixesAvatar:NetAttr(GameConst.net_type)
			if not (ghostType == GameConst.GHOST_THIS) then
				-- print("//////////////////////////teammode///////////////////", mainAvatar:NetAttr(GameConst.net_teamid), mPixesAvatar:NetAttr(GameConst.net_teamid))
				-- if mainAvatar:NetAttr(GameConst.net_teamid) == mPixesAvatar:NetAttr(GameConst.net_teamid) then
				if GameSocket:isGroupMember(mPixesAvatar:NetAttr(GameConst.net_name)) then
					nameColor = cc.c4b(11, 232, 0, 255)
				end
			end
		elseif GameSocket.mAttackMode == 103 then -- 帮会
			mainAvatar = cc.GhostManager:getInstance():getMainAvatar()
			ghostType = mPixesAvatar:NetAttr(GameConst.net_type)
			if ghostType == GameConst.GHOST_THIS then
				nameColor = cc.c4b(0, 0, 255, 255)
			elseif ghostType == GameConst.GHOST_PLAYER then
				if mainAvatar:NetAttr(GameConst.net_guild_name) == mPixesAvatar:NetAttr(GameConst.net_guild_name) then
					nameColor = cc.c4b(0, 0, 255, 255)
				else
					-- nameColor = cc.c4b(255, 255, 0, 255)
					nameColor = cc.c4b(255, 156, 0, 255)
				end
			end
		elseif GameSocket.mAttackMode == 105 then --阵营
			local teamId = mPixesAvatar:NetAttr(GameConst.net_teamid)
			local teamName = mPixesAvatar:NetAttr(GameConst.net_team_name)
			if teamId == 1 then
				nameColor = cc.c4b(255,0,0,255)
			elseif teamId == 2 then
				nameColor = cc.c4b(0,0,255,255)
			end
		end

		-- local mainAvatar = cc.GhostManager:getInstance():getMainAvatar()
		-- local selfGuild = mainAvatar:NetAttr(GameConst.net_guild_name)

		-- local avatarGuild = mPixesAvatar:NetAttr(GameConst.net_guild_name)
		-- if G_AttackGuild == 1 and selfGuild and avatarGuild then
		-- 	nameColor = selfGuild == avatarGuild and cc.c4b(0, 255, 0, 255) or cc.c4b(0, 0, 255, 255)
		-- end

		if nameColor then mNameLabel:setTextColor(nameColor) end
	end
end

function show_player_vip(srcid)
	local mPixesAvatar = CCGhostManager:getPixesAvatarByID(srcid)
	if mPixesAvatar and mPixesAvatar:getNameSprite() then
		local nameSprite = mPixesAvatar:getNameSprite()
		local mNameLabel = nameSprite:getChildByName("mNameLabel")
		if not mNameLabel then return end
		-- local mModels = GameSocket.mModels[srcid]
		local vipLv
		if GameSocket:getPlayerModel(srcid,5)>0 then -- 取vip信息
			vipLv = GameSocket:getPlayerModel(srcid,5)
		else
			local netState = mPixesAvatar:NetAttr(GameConst.net_state)-- 取vip信息(他人)
			if netState then
				vipLv = tonumber(netState)
			end
		end
		if vipLv and vipLv > 0 then
			local mVipSprite = nameSprite:getChildByName("mVipSprite")
			if not mVipSprite then
				--[[
				mVipSprite = cc.Sprite:createWithSpriteFrameName("img_title_V"..vipLv)
					:setName("mVipSprite")
					:addTo(nameSprite)
					]]
				mVipSprite = cc.Sprite:create()
					:setName("mVipSprite")
					:setPosition(0,7)
					:setAnchorPoint(cc.p(1,0))
					:setContentSize(cc.size(30,26))
					:addTo(nameSprite)
			else
				--mVipSprite:initWithSpriteFrameName("img_title_V"..vipLv)
			end
			mVipSprite:removeChildByName("spriteEffect")
			GameUtilSenior.addEffect(mVipSprite,"spriteEffect",GROUP_TYPE.TITLE,30000+tonumber(vipLv)-1,false,false,true)

			GameUtilBase.updateNamePos(nameSprite)
		end
	end
end

function set_relive_time(time,label)
	if time >= 5 then
		local cal_time = time
		local hour = math.floor(cal_time/(60*60))
		cal_time = cal_time%(60*60)
		local minute = math.floor(cal_time/60)
		cal_time = cal_time%60
		local second = cal_time
		if hour > 0 then
			label:setString(string.format("%02d",hour)..":"..string.format("%02d",minute)..":"..string.format("%02d",second)..GameConst.str_relive)
		elseif minute > 0 then
			label:setString(string.format("%02d",minute)..":"..string.format("%02d",second)..GameConst.str_relive)
		else
			label:setString(string.format("%02d",second)..GameConst.str_second..GameConst.str_relive)
		end
	else
		label:setString(GameConst.str_soon_relive)
	end
end

function on_message(type,bytearray)
	GameSocket:ParseMsg(bytearray)
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_ON_MESSAGE,"on_message")

function on_socket_error(code)
	print("on_socket_error "..code)

	GameSocket._connected = false
	GameSocket:dispatchEvent({ name = GameMessageCode.EVENT_SOCKET_ERROR, code=code})
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_SOCKET_ERROR,"on_socket_error")

local skill_sound = {
	-- ["0"] = {mp3 = "zhang_attack.mp3"},
	-- ["11031"] = {mp3 = "31.mp3"},
	-- ["11051"] = {mp3 = "54.mp3"},
	-- ["11061"] = {mp3 = "41.mp3"},
	-- ["11021"] = {mp3 = "36.mp3"},
	-- ["11041"] = {mp3 = "27.mp3"},
	-- ["24051"] = {mp3 = "52.mp3"},
	-- ["24091"] = {mp3 = "37.mp3"},
	-- ["24141"] = {mp3 = "28.mp3"},
	-- ["24021"] = {mp3 = "39.mp3"},
	-- ["24121"] = {mp3 = "45.mp3"},
	-- ["35041"] = {mp3 = "42.mp3"},
	-- ["35121"] = {mp3 = "zhiliaoshu.mp3"},
	-- ["35071"] = {mp3 = "yinshenshu.mp3"},
	-- ["35081"] = {mp3 = "youlinghuzhao.mp3"},
	-- ["35131"] = {mp3 = "55.mp3"},
}

function cast_skill_effect(srcid,type,rid)
	local mainAvatar = cc.NetClient:getInstance():getMainGhost()
	if mainAvatar and mainAvatar:NetAttr(GameConst.net_id) == srcid then
		if rid and tostring(rid) and skill_sound[tostring(rid)] then
			-- GameMusic.play("music/"..skill_sound[tostring(rid)].mp3)
		end
		-- print("cast_skill_effectcast_skill_effect", type, rid)
	end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_CAST_SKILL,"cast_skill_effect")


local framescallback={}

function clearFramesCallback()
	framescallback={}
end

function asyncload_frames(filename,filetype,callback,node)
	if type(filename) == "string" then
		if not framescallback[filename] then
			framescallback[filename]={}
		end
		table.insert(framescallback[filename],{callback=callback,node=node})
	end
	cc.SpriteManager:getInstance():asyncLoadSpriteFrames(filename,filetype)
end

function remove_frames(filename,filetype)
	cc.SpriteManager:getInstance():removeFramesByFile(filename)  

	if filetype then
		cc.CacheManager:getInstance():releaseCache(filename..filetype)
	end

end

function frames_callback(filename)
	if framescallback[filename] and type(framescallback[filename])=="table" then
		for _,v in pairs(framescallback[filename]) do
			if v.callback then
				if not v.node or GameUtilBase.isObjectExist(v.node) then
					v.callback(filename)
				end
			end
		end
		framescallback[filename]=nil
	end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_ASYNCLOAD_FRAMES,"frames_callback")

-- local loadcallback={}

function asyncload_callback(filepath,ccnode,callback,retain)
	if not retain then retain =false end

	if not cc.FileUtils:getInstance():isFileExist(filepath) then
		--return false  --做了热加载,不判断是否有文件了
	end

	local isexit=false

	if type(filepath) == "string" then
		if cc.CacheManager:getInstance():asyncLoadAndListener(filepath,function(path,texture)
			if callback and not isexit then
				if not ccnode or GameUtilBase.isObjectExist(ccnode) then
					callback(path,texture)
				end
			else
				-- print("asyncload_callback callback exit")
			end
		end,retain)==true then
			if ccnode then
				cc(ccnode):addNodeEventListener(cc.NODE_EVENT, function (event)
					-- print("cc(ccnode):addNodeEventListener",event.name)
		            if event.name == "exit" then
		                -- print("asyncload_callback",event.name)
		                isexit=true
		            end
		        end)
			else
				-- print("asyncload_callback has not target !!!")
			end
		end
	end
end

function asyncload_list(filelist,ccnode,callback)
	if type(filelist)=="table" then
		local len=#filelist
		local step=0
		local res={}
		for i=1,len do
			local ret=asyncload_callback(filelist[i],ccnode,function (path,pic)
				step=step+1
				res[path]=pic
				pic:retain()
				if step>=len then
					if not ccnode or GameUtilBase.isObjectExist(ccnode) then
						callback(filelist,res)
					end
					for _,v in pairs(res) do
						if v and v.release then
							v:release()
						end
					end
					res=nil
				end
			end)
			if ret==false then
				if res then
					for _,v in pairs(res) do
						if v and v.release then
							v:release()
						end
					end
					res=nil
					print("async list load stop !!!")
				end
				return
			end
		end
		if ccnode then
			cc(ccnode):addNodeEventListener(cc.NODE_EVENT, function (event)
	            if event.name == "exit" then
	                if res then
						for _,v in pairs(res) do
							if v and v.release then
								v:release()
							end
						end
						res=nil
						print("async list load stop !!!")
					end
	            end
	        end)
		else
			print("asyncload_callback has not target !!!")
		end
	end
end

-- function texture_callback(filepath,texture)
-- 	if loadcallback[filepath] and type(loadcallback[filepath])=="table" then
-- 		for _,v in pairs(loadcallback[filepath]) do
-- 			if v then
-- 				v(filepath,texture)
-- 			end
-- 		end
-- 		loadcallback[filepath]=nil
-- 	end
-- end
-- cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_ASYNCLOAD_TEXTURE,"texture_callback")

-- function attacked_callback(type)
	-- if G_SwitchEffect < 1 then
	-- 	local MainAvatar = CCGhostManager:getMainAvatar()
	-- 	local gender = MainAvatar:NetAttr(GameConst.net_gender)

	-- 	if MainAvatar:NetAttr(GameConst.net_hp) > 0 then
	-- 		if gender == GameConst.SEX_MALE then
	-- 			GameMusic.play(GameConst.SOUND.injure_male)
	-- 		else
	-- 			GameMusic.play(GameConst.SOUND.injure_female)
	-- 		end
	-- 	end
	-- end
-- end
-- cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_ON_ATTACKED,"attacked_callback")

function walk_update(typed)
	---------typed(1:走，2：跑，11：坐骑慢行，12：坐骑全速)--------
	if G_SwitchEffect < 1 then
		-- if typed == 1 then
		-- 	GameMusic.play(GameConst.SOUND.walk)
		-- elseif typed == 2 then
		-- 	GameMusic.play(GameConst.SOUND.run)
		-- end
		GameMusic.play("music/53.mp3",1)
	end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_WALK_UPDATE,"walk_update")

function mainrole_status(statusid,dura,param)
	if MainRole then
		GameCharacter.setStatus(statusid,dura,param)
	end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_MAINROLE_STATUS,"mainrole_status")

function downFileSuccess(filename)
	if filename then
		if (GameBaseLogic.totalLoadNum >0 or GameBaseLogic.isDownloadAllState) and not GameBaseLogic.downloadAll then
			if GameBaseLogic.needLoadNum >0 then
				GameBaseLogic.needLoadNum=GameBaseLogic.needLoadNum-1
			end
			if GameBaseLogic.totalLoadNum>0 and GameBaseLogic.needLoadNum<=0 then
				GameBaseLogic.downloadAll=true
			end
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_DOWNLOAD_SUCCESS,file = filename})
			if GameBaseLogic.isGetLoadAwarded <= 0 and GameBaseLogic.downloadAll and MAIN_IS_IN_GAME then
				-- 通知服务器下载完成
				GameSocket:PushLuaTable("gui.PanelDownLoad.handlePanelData","downall")
			end
		end
	end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_DOWNLOAD_SUCCESS,"downFileSuccess")

function handleMonsterVisible(ghostType, pixesAvatar)
	local isBoss = pixesAvatar:NetAttr(GameConst.net_isboss)
	isBoss = type(isBoss) == "boolean" and 0 or isBoss
	if isBoss == 0 then
		local visible = true
		if _G["G_ShieldMonster"] == 1 then
			visible = false
		end
		pixesAvatar:setVisible(visible);
	else
		pixesAvatar:setVisible(true);
	end
end
