local ContainerSkill = {}
local var = {}
local pageKeys = {
	"skill", "show", 
}
local state = GDivSkill.STATE
local pos1 = cc.p(120,110)
local pos2 = cc.p(390,110)
local pos3 = cc.p(180,110)
local skillConfig = GameSkill.skillConfig
local SKILL_LEVEL_MAX = 10
local SKILL_LEVEL_EXT_MAX = 13
local function hideAllPages()
	local pageName
	for i,v in ipairs(pageKeys) do
		pageName = "xmlPage"..string.ucfirst(v)
		if var[pageName] then
			var[pageName]:hide()
		end
	end
end
 -- page变量，初始化函数，刷新函数使用字符窜拼接
local function showPanelPage(index)
	local key = pageKeys[index]
	if not (key and table.indexof(pageKeys, key))then return end
	local name = "role"
	if key == "show" then
		name = "show"
	end
	var.title:loadTexture("img_"..name.."_title",ccui.TextureResType.plistType)
	var.lastTabIndex = index
	hideAllPages()
	local pageName = "xmlPage"..string.ucfirst(key)
	local initFunc = "initPage"..string.ucfirst(key)
	local openFunc = "openPage"..string.ucfirst(key)
	if not var[pageName] and ContainerSkill[initFunc] then
		ContainerSkill[initFunc]()
	end
	if var[pageName] then
		if ContainerSkill[openFunc] then
			ContainerSkill[openFunc]()
		end
		var[pageName]:show()
	end
end

--local function pushTabButtons(sender)
--	showPanelPage(sender:getTag())
--end

---------------------------------------以上为内部函数---------------------------------------
function ContainerSkill.initView(extend)
	var = {
		boxTab,
		xmlPanel,
		xmlPageSkill,
		xmlPageShow,
		title,

		-- 技能
		skillInfo={},
		jobID,
		curSelectImg=nil,
		curSkill=nil,--记录当前选中的技能（设置自动释放和升级用）
		skillsDesp = {},
		curSelectLevel,--当前选中的技能等级
		
		defaultSkill = nil,
		richLev,
		richSld,
		richBook,

		panelExtend = nil,

		gemAutoVcoin = false,

		lastTabIndex = 1,

		replaceVcion=0,

	}

	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerSkill.uif")

	if var.xmlPanel then
		var.title = var.xmlPanel:getWidgetByName("panel_title")
		var.boxTab = var.xmlPanel:getWidgetByName("box_tab")
		var.boxTab:getParent():setLocalZOrder(10)
		var.boxTab:addTabEventListener(ContainerSkill.pushTabButtons)
		var.boxTab:setItemMargin(3)
		-- var.boxTab:setSelectedTab(1)
		local hideIndex = {2,4,6,7}
		local opened = GameSocket:checkFuncOpenedByID(10015)
		if not opened then
			table.insert(hideIndex,4)
		end
		local openedReborn = GameSocket:checkFuncOpenedByID(10014)
		if not openedReborn then
			table.insert(hideIndex,5)
		end
		--暂时不显示时装
		--table.insert(hideIndex,2)
		var.boxTab:hideTab(hideIndex)
		
		ContainerSkill.updateGameMoney()
		return var.xmlPanel
	end
end

function ContainerSkill.pushTabButtons(sender)
	local opened, level, funcName
	opened = true
	local tag = sender:getTag()
	local tag = sender:getTag()
	if tag ~= 5 and tag ~= 6 and tag~=7 and tag~=8 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="main_avatar",tab=tag})
	end	
	if tag==5 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "container_reborn"})
		return
	end
	if tag==6 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "container_my_hunhuan"})
		return
	end
	if tag==7 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "container_my_zuji"})
		return
	end
	--if tag==8 then
	--	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_skill"})
	--	return
	--end
	if tag==8 then
		showPanelPage(1)
	end
end

--金币刷新函数
function ContainerSkill:updateGameMoney()
	local panel = var.xmlPanel
	if panel then
		local mainrole = GameSocket.mCharacter
		local moneyLabel = {
			{name="big_title_yb_text",btn="big_title_yb_btn",	pre=GameConst.str_vcoin,	value =	mainrole.mVCoin or 0	,	icon = "icon_coin"},
			{name="big_title_hmb_text",btn="big_title_hmb_btn",	pre=GameConst.str_vcoinb,	value =	mainrole.mVCoinBind or 0,	icon = "icon_coin_bind"},
			{name="big_title_jb_text",btn="big_title_jb_btn",	pre=GameConst.str_money,	value =	mainrole.mGameMoney or 0,	icon = "icon_money"},
			{name="lblBMoney",	pre=GameConst.str_moneyb,	value =	mainrole.mGameMoneyBind or 0,	icon = "icon_money"},
		}
		--建临时表遍历设属性
		for _,v in ipairs(moneyLabel) do
			if panel:getWidgetByName(v.name) then
				panel:getWidgetByName(v.name):setString(v.value)
				panel:getWidgetByName(v.btn):addClickEventListener( function (sender)
					GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
				end)
			end
		end
	end
end

function ContainerSkill.onPanelOpen(extend)
	var.panelExtend = extend
	--技能特殊处理
	var.defaultSkill = nil
	if var.panelExtend then
		if var.panelExtend.skillId and var.panelExtend.skillId > 0 and GameSocket.m_netSkill[var.panelExtend.skillId] then
			var.defaultSkill = var.panelExtend.skillId
		end
	end

	if extend and GameUtilSenior.isNumber(extend.index) then
		var.boxTab:setSelectedTab(extend.index)
	else
		var.boxTab:setSelectedTab(8)
	end
end

function ContainerSkill.onPanelClose()
	
end

--------------------------------------技能--------------------------------------
function ContainerSkill.openPageSkill()

end
function ContainerSkill.initPageSkill()
	--------获取技能是否自动释放
	local function getAutoCastState(skill_type)
		return table.indexof(GameSocket.NetAutoSkills, skill_type) and true or false
	end

	--------更新自动释放按钮状态
	local function updateAutoCastButton()
		local imgSwitch = var.xmlPageSkill:getWidgetByName("imgSwitch")
		if imgSwitch then
			local value = getAutoCastState(var.curSkill)
			if  var.curSkill==GameConst.SKILL_TYPE_BanYueWanDao then
				value = GameSocket.m_bBanYueOn
			elseif var.curSkill==GameConst.SKILL_TYPE_CiShaJianShu then
				value = GameSocket.m_bCiShaOn
			end
			if value then
				imgSwitch:loadTexture("ContainerSkill_check_open.png",ccui.TextureResType.plistType)
			else
				imgSwitch:loadTexture("ContainerSkill_check_close.png",ccui.TextureResType.plistType)
			end
		end
	end

	local function updateSkillDesp(nsd)
		nsd = nsd or GameBaseLogic.getSkillDesp(var.curSkill)
		local netSkill = GameSocket.m_netSkill[var.curSkill]
		var.xmlPageSkill:getWidgetByName("curSkillName"):setString(nsd.mName)
		var.xmlPageSkill:getWidgetByName("cur_fw"):setString(nsd.mRangeDesp)--技能范围
		-- var.xmlPageSkill:getWidgetByName("cur_sh"):setString(nsd.mDamageDesp)
		var.xmlPageSkill:getWidgetByName("cur_cd"):setString(nsd.mCDDesp)
		-- var.xmlPageSkill:getWidgetByName("cur_xg"):setString(nsd.mExtEffectDesp)--附加效果


		-- print("next info is ", nsd.mName, nsd.mRangeDespNext, nsd.mDamageDespNext, nsd.mCDDespNext, nsd.mExtEffectDespNext)
		var.xmlPageSkill:getWidgetByName("nextSkillName"):setString(nsd.mName)
		var.xmlPageSkill:getWidgetByName("next_fw"):setString(nsd.mRangeDespNext)
		-- var.xmlPageSkill:getWidgetByName("next_sh"):setString(nsd.mDamageDespNext)
		var.xmlPageSkill:getWidgetByName("next_cd"):setString(nsd.mCDDespNext)
		-- var.xmlPageSkill:getWidgetByName("next_xg"):setString(nsd.mExtEffectDespNext)
		-- if var.xmlPageSkill:getChildByName(T)
		local cur_sh = var.xmlPageSkill:getWidgetByName("contentCur"):getChildByName("richcur_sh")
		if not cur_sh then
			cur_sh = GUIRichLabel.new({size=cc.size(370,25), space=3, name="richcur_sh",outline = {0,0,0,255,1}})
			cur_sh:addTo(var.xmlPageSkill:getWidgetByName("contentCur")):pos(219,103)
		end
		cur_sh:setRichLabel("<font color=#fddfae>"..nsd.mDamageDesp.."</font>",nil,18)

		local next_sh = var.xmlPageSkill:getWidgetByName("contentCur_0"):getChildByName("rinext_sh")
		if not next_sh then
			next_sh = GUIRichLabel.new({size=cc.size(370,25), space=3, name="rinext_sh",outline = {0,0,0,255,1}})
			next_sh:addTo(var.xmlPageSkill:getWidgetByName("contentCur_0")):pos(219,108)
		end
		next_sh:setRichLabel("<font color=#fddfae>"..nsd.mDamageDespNext.."</font>",nil,18)

		local cur_xg = var.xmlPageSkill:getWidgetByName("contentCur"):getChildByName("ricur_xg")
		if not cur_xg then
			cur_xg = GUIRichLabel.new({size=cc.size(370,25), space=3, name="ricur_xg",outline = {0,0,0,255,1}})
			cur_xg:addTo(var.xmlPageSkill:getWidgetByName("contentCur")):pos(219,25)
		end
		cur_xg:setRichLabel("<font color=#fddfae>"..nsd.mExtEffectDesp.."</font>",nil,18)

		local next_xg = var.xmlPageSkill:getWidgetByName("contentCur_0"):getChildByName("rinext_xg")
		if not next_xg then
			next_xg = GUIRichLabel.new({size=cc.size(370,25), space=3, name="rinext_xg",outline = {0,0,0,255,1}})
			next_xg:addTo(var.xmlPageSkill:getWidgetByName("contentCur_0")):pos(219,32)
		end
		next_xg:setRichLabel("<font color=#fddfae>"..nsd.mExtEffectDespNext.."</font>",nil,18)


		local curLevel = GameCharacter._mainAvatar:NetAttr(GameConst.net_level)
		-- var.xmlPageSkill:getWidgetByName("needLev"):setString(GameCharacter._mainAvatar:NetAttr(GameConst.net_level).."/"..nsd.mNeedLevel)--角色等级需求
		-- var.xmlPageSkill:getWidgetByName("skill_sld"):setString(netSkill.mExp.."/"..nsd.mNeedExp)--技能熟练度
		if curLevel>=nsd.mNeedLevel then
			var.richLev:setRichLabel("<font color=#18d129>"..curLevel.."/"..nsd.mNeedLevel.."</font>","ContainerSkill",20)
		else
			var.richLev:setRichLabel("<font color=#FF3E3f>"..curLevel.."/"..nsd.mNeedLevel.."</font>","ContainerSkill",20)
		end
		if netSkill.mExp>=nsd.mNeedExp then
			var.richSld:setRichLabel("<font color=#18d129>"..netSkill.mExp.."/"..nsd.mNeedExp.."</font>","ContainerSkill",20)
		else
			var.richSld:setRichLabel("<font color=#FF3E3f>"..netSkill.mExp.."/"..nsd.mNeedExp.."</font>","ContainerSkill",20)
		end

		if netSkill.mLevel == 10 then
			--特殊处理
			local needBook = "怒之"..nsd.mName;
			if GameSocket:hasItem(needBook) then
				var.richBook:setRichLabel("<font color=#18d129>"..needBook.."</font>", 20)
			else
				var.richBook:setRichLabel("<font color=#FF3E3f>"..needBook.."</font>", 20)
			end
		else
			var.richBook:setRichLabel("<font color=#FF3E3f>".."无".."</font>", 20)
		end

		if netSkill.mLevel>=SKILL_LEVEL_EXT_MAX or 
			(netSkill.mLevel>=SKILL_LEVEL_MAX and (netSkill.skill_id == GameConst.SKILL_TYPE_JiChuJianShu 
				or netSkill.skill_id == GameConst.SKILL_TYPE_JinShenLiZhanFa)
			) then
			var.richLev:setRichLabel("<font color=#FFFF00>Max</font>","ContainerSkill",20)
			var.richSld:setRichLabel("<font color=#FFFF00>Max</font>","ContainerSkill",20)
		end
		var.xmlPageSkill:getWidgetByName("curSkillLev"):setString("Lv"..netSkill.mLevel)
		var.curSelectLevel=netSkill.mLevel
		if netSkill.mLevel < nsd.mLevelMax then
			var.xmlPageSkill:getWidgetByName("nextSkillLev"):setString("Lv"..netSkill.mLevel+1)
		else
			var.xmlPageSkill:getWidgetByName("nextSkillLev"):setString("")
		end

		local btnUp = var.xmlPageSkill:getWidgetByName("btnUp")
		local imgRed = var.xmlPageSkill:getWidgetByName("imgRed"):hide()
		if GameCharacter._mainAvatar:NetAttr(GameConst.net_level)<nsd.mNeedLevel or netSkill.mExp<nsd.mNeedExp then
			btnUp:setEnabled(false)
			btnUp:removeChildByName("img_bln")
			-- imgRed:setVisible(false)
		else
			btnUp:setEnabled(true)
			GameUtilSenior.addHaloToButton(btnUp, "btn_normal_light3")
			-- imgRed:setVisible(true)
		end

		if var.curSkill==GameConst.SKILL_TYPE_LeiDianShu or var.curSkill==GameConst.SKILL_TYPE_LingHunHuoFu then
			var.xmlPageSkill:getWidgetByName("ConAuto"):setVisible(false)
		else
			var.xmlPageSkill:getWidgetByName("ConAuto"):setVisible(true)
		end
	end

	local function prsSkillItem(sender)
		local nsd = var.skillsDesp[sender.tag]
		if not GameSocket.m_netSkill[nsd.skill_id] then
			return
		end

		if var.curSelectImg then var.curSelectImg:setVisible(false) end
		var.curSelectImg = sender:getWidgetByName("imgClick"):setVisible(true)

		var.curSkill = nsd.skill_id
		updateSkillDesp(nsd);
		updateAutoCastButton()
	end

	local function initListSkill()
		local listSkill = var.xmlPageSkill:getWidgetByName("listSkill")

		local function updateSkillRedDot(item)
			local skillIcon = item:getWidgetByName("skillIcon")
			if not skillIcon then return end
			local redDot = skillIcon:getChildByName("redPoint")
			if not redDot then
				GUIFocusDot.addRedPointToTarget(skillIcon)
				redDot = skillIcon:getChildByName("redPoint")
				if redDot then
					-- local pSize = skillIcon:getContentSize()
					-- redDot:align(display.CENTER, pSize.width * 0.85, pSize.height * 0.85)
				end
			end
			if not redDot then return end
			local nsd = var.skillsDesp[item.tag]
			redDot:setVisible(GameSocket.skillRed[nsd.skill_id] and true or false)
		end

		var.skillsDesp = {}
		for k,v in pairs(GameSocket.m_netSkill) do
			if v.mTypeID ~= GameConst.SKILL_TYPE_YiBanGongJi then -- todo
				table.insert(var.skillsDesp, GameBaseLogic.getSkillDesp(v.mTypeID))
			end
		end
		
		local function sortF(nsd1, nsd2)
			return nsd1.mOrderID < nsd2.mOrderID
		end
		table.sort(var.skillsDesp, sortF)

		-- print("var.skillsDesp", GameUtilSenior.encode(var.skillsDesp))
		local skillIcon, path
		local function updateSkillList(item)
			item:setTouchEnabled(true)
			GUIFocusPoint.addUIPoint(item , prsSkillItem)

			local nsd = var.skillsDesp[item.tag]
			local netSkill = GameSocket.m_netSkill[nsd.skill_id]

			skillIcon = item:getWidgetByName("skillIcon")

			path = "image/icon/skill"..nsd.skill_id..".png"
			if netSkill.mLevel > 10 then
				path = "image/icon/skill"..nsd.skill_id.."_angry.png"
			end
			asyncload_callback(path, skillIcon, function(path, texture)
				skillIcon:loadTexture(path)
			end)
			
			item:getWidgetByName("skillName"):setString(nsd.mName)
			item:getWidgetByName("skillOpen"):setString(""):hide()
			local skillBar = item:getWidgetByName("skillBar")
			if not iskindof(skillBar,"GUILoaderBar") then
				skillBar = GUILoaderBar.new({image = skillBar})
				skillBar:setFontSize( 14 ):setName("skillBar"):setVisible(false)
			end 
			if netSkill then
				item:getWidgetByName("skillLev"):setString("Lv."..netSkill.mLevel)
				skillBar:setPercent(netSkill.mExp,nsd.mNeedExp)
				skillIcon:getVirtualRenderer():setState(0)
				if netSkill.mLevel>=SKILL_LEVEL_EXT_MAX or 
					(netSkill.mLevel>=SKILL_LEVEL_MAX and (netSkill.skill_id == GameConst.SKILL_TYPE_JiChuJianShu 
						or netSkill.skill_id == GameConst.SKILL_TYPE_JinShenLiZhanFa)
					) then
					skillBar:setFormatString("")
					skillBar:setFormat2String("Max")
				end
			else
				item:getWidgetByName("skillLev"):setString("Lv.0")
				skillBar:setPercent(0,nsd.mNeedExp)
				skillIcon:getVirtualRenderer():setState(1)
			end
			
			if not var.curSelectImg then
				if not var.defaultSkill then
					if item.tag == 1 then
						prsSkillItem(item)
					end
				elseif var.defaultSkill == nsd.skill_id then
					prsSkillItem(item)
				end
			end
			updateSkillRedDot(item)
		end
		listSkill:reloadData(#var.skillsDesp, updateSkillList)--:setSliderVisible(false)
	end

	local function onSkillStateChange(event)
		if  event.skill_type==GameConst.SKILL_TYPE_BanYueWanDao or event.skill_type==GameConst.SKILL_TYPE_CiShaJianShu then
			updateAutoCastButton()
		end
	end

	local function onSkillLevelUp(event)
		if event.skill_type == var.curSkill then
			updateSkillDesp()
			
		end
		initListSkill()
	end

	local function initBtnClick()
		local btnArr = {"btnUp","btnSet","imgSwitch"}
		local function prsBtnClick(sender)
			local btnName = sender:getName()
			if btnName=="imgSwitch" then
				-- ContainerSkill.updateAutoCastButton(skill_type)
				local state = not getAutoCastState(var.curSkill)
				GameSocket:PushLuaTable("gui.ContainerSkill.onPanelData", GameUtilSenior.encode({cmd = "autoCast", skillType = var.curSkill, state = state}))
				
				----测试代码,提前设置按钮状态
				-- local imgSwitch = var.xmlPageSkill:getWidgetByName("imgSwitch")
				-- if imgSwitch then
					if  var.curSkill==GameConst.SKILL_TYPE_BanYueWanDao then
						GameSocket:UseSkill(GameConst.SKILL_TYPE_BanYueWanDao,GameCharacter.mX,GameCharacter.mY,0)
						state = GameSocket.m_bBanYueOn
					elseif var.curSkill==GameConst.SKILL_TYPE_CiShaJianShu then
						GameSocket:UseSkill(GameConst.SKILL_TYPE_CiShaJianShu,GameCharacter.mX,GameCharacter.mY,0)
						state = GameSocket.m_bCiShaOn
					end
					-- btnAutoCast:setBrightStyle(state and ccui.BrightStyle.normal or ccui.BrightStyle.highlight )
					if state then
						sender:loadTexture("btn_skill_open",ccui.TextureResType.plistType)
					else
						sender:loadTexture("btn_skill_close",ccui.TextureResType.plistType)
					end

				-- end
			elseif btnName=="btnUp" then
				GameSocket:PushLuaTable("gui.ContainerSkill.onPanelData", GameUtilSenior.encode({cmd = "levelUp", skillLevel=var.curSelectLevel,skillType = var.curSkill}))
			elseif btnName=="btnSet" then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_quickset",mParam={type=1}})
			end
		end
		for i=1,#btnArr do
			local btn = var.xmlPageSkill:getWidgetByName(btnArr[i])
			btn:setTouchEnabled(true)
			GUIFocusPoint.addUIPoint(btn,prsBtnClick)
		end
	end

	var.xmlPageSkill = GUIAnalysis.load("ui/layout/ContainerCharacter_skill.uif")
	if var.xmlPageSkill then
		GameUtilSenior.asyncload(var.xmlPageSkill, "img_border", "ui/image/panel_skill_bg.jpg")
		-- print("////////////////////////", var.xmlPageSkill, var.xmlPanel)
		var.xmlPageSkill:align(display.LEFT_BOTTOM, 0, 0):addTo(var.xmlPanel)

		var.jobID = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)
		
		initListSkill()
		initBtnClick()

		cc.EventProxy.new(GameSocket, var.xmlPageSkill)
			:addEventListener(GameMessageCode.EVENT_SKILL_LEVEL_UP, onSkillLevelUp)
			:addEventListener(GameMessageCode.EVENT_SKILL_STATE, onSkillStateChange)
			:addEventListener(GameMessageCode.EVENT_SWITCH_AUTO_SKILL, function (event)
				if event.skillType == var.curSkill and event.skillType~=GameConst.SKILL_TYPE_BanYueWanDao and event.skillType~=GameConst.SKILL_TYPE_CiShaJianShu then
					updateAutoCastButton()
				end
			end)
		
		var.richLev=GUIRichLabel.new({size=cc.size(200,25), space=3, name="richWidget"})
		var.richLev:addTo(var.xmlPageSkill):pos(330,182)
		var.richLev:setRichLabel("0/0","pageSkill",20)

		var.richSld=GUIRichLabel.new({size=cc.size(200,25), space=3, name="richWidget"})
		var.richSld:addTo(var.xmlPageSkill):pos(310,152)
		var.richSld:setRichLabel("0/0","pageSkill",20)

		var.richBook=GUIRichLabel.new({size=cc.size(200,25), space=3, name="richWidget"})
		var.richBook:addTo(var.xmlPageSkill):pos(310,122)
		var.richBook:setRichLabel("无","pageSkill",20)
	end

end

---------------------------------------展示-----------------------------------------
function ContainerSkill.openPageShow()
	
	GameSocket:PushLuaTable("gui.ContainerSkill.onPanelData", GameUtilSenior.encode({cmd = "skillPreview"}))
end

function ContainerSkill.initPageShow()
	local function initListSkill()
		local listSkill = var.xmlPageShow:getWidgetByName("listSkill")
		local playGround = var.xmlPageShow:getWidgetByName("playGround")

		local btnStart = var.xmlPageShow:getWidgetByName("btnStart"):setLocalZOrder(6)
		local curSelectImg = nil
		local curSkill = nil
		-- local showSprite = cc.Sprite:create():addTo(var.xmlPageShow):pos(561, 250)
		local gender = GameCharacter._mainAvatar:NetAttr(GameConst.net_gender)
		local job = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)

		local function runAvatarAction(target,action,dir,cloth,weapon,wing)
			dir = dir or 2
			local flip = dir>4
			dir = dir>4 and 8-dir or dir
			local clothId = cloth or GameCharacter._mainAvatar:NetAttr(GameConst.net_cloth)
			local weaponId = weapon or GameCharacter._mainAvatar:NetAttr(GameConst.net_weapon)
			local wingId = wing or GameCharacter._mainAvatar:NetAttr(GameConst.net_wing)
			local shadowId = 28000
			clothId = clothId
			-- weaponId = weaponId*100 + action
			-- wingId = wingId*100 + action
			local clothSprite = target:getChildByName("clothSprite") or cc.Sprite:create():addTo(target):pos(0,0):setName("clothSprite")
			local weaponSprite = target:getChildByName("weaponSprite") or  cc.Sprite:create():addTo(target):pos(0,0):setName("weaponSprite")
			local wingSprite = target:getChildByName("wingSprite") or  cc.Sprite:create():addTo(target):pos(0,0):setName("wingSprite")
			local shadowSprite = target:getChildByName("shadowSprite") or  cc.Sprite:create():addTo(target):pos(0,0):setName("shadowSprite")
			clothSprite:setOpacity(255):setLocalZOrder(table.indexof(GDivSkill.zorderTable[dir+1], "cloth"))
			weaponSprite:setOpacity(255):setLocalZOrder(table.indexof(GDivSkill.zorderTable[dir+1], "weapon"))
			wingSprite:setOpacity(255):setLocalZOrder(table.indexof(GDivSkill.zorderTable[dir+1], "wing"))
			shadowSprite:setOpacity(255):setLocalZOrder(table.indexof(GDivSkill.zorderTable[dir+1], "shadow"))
			local clothAnimate = clothId>0 and GDivSkill.getActionAnimate(0,clothId,action,dir) or cca.hide()
			local weaponAnimate = weaponId >0 and GDivSkill.getActionAnimate(1,weaponId,action,dir) or cca.hide()
			local wingAnimate = wingId>0 and GDivSkill.getActionAnimate(3,wingId,action,dir) or cca.hide()
			local shadowAnimate = shadowId>0 and GDivSkill.getActionAnimate(0,shadowId,action,dir) or cca.hide()
			clothSprite:setFlippedX(flip)
			weaponSprite:setFlippedX(flip)
			wingSprite:setFlippedX(flip)
			-- shadowSprite:setFlippedX(flip)
			local actionOnce
			if action == GDivSkill.STATE.PREPARE then
				actionOnce = cca.spawn({
					cc.TargetedAction:create(clothSprite,cca.rep(clothAnimate,30)),
					cc.TargetedAction:create(weaponSprite,cca.rep(weaponAnimate,30)),
					cc.TargetedAction:create(wingSprite,cca.rep(wingAnimate,30)),
					cc.TargetedAction:create(shadowSprite,cca.rep(shadowAnimate,30)),
				})
			elseif action == GDivSkill.STATE.IDLE then 
				actionOnce = cca.spawn({
					cc.TargetedAction:create(clothSprite,clothAnimate),
					cc.TargetedAction:create(weaponSprite,weaponAnimate),
					cc.TargetedAction:create(wingSprite,wingAnimate),
					cc.TargetedAction:create(shadowSprite,shadowAnimate),
				})
			else
				actionOnce = cca.spawn({
					cc.TargetedAction:create(clothSprite,cca.seq({clothAnimate})),
					cc.TargetedAction:create(weaponSprite,cca.seq({weaponAnimate})),
					cc.TargetedAction:create(wingSprite,cca.seq({wingAnimate})),
					cc.TargetedAction:create(shadowSprite,cca.seq({shadowAnimate})),
				})
			end
			return actionOnce
		end

		local function newSkillAnimate(selfNode,otherNode,dir)
			local actionOnce
			if not dir then
				dir = job == 100 and 2 or 4
			end
			local showSprite = selfNode:getParent():getChildByName("showSprite") or cc.Sprite:create():addTo(selfNode:getParent()):setName("showSprite")
			showSprite:pos(selfNode:getPosition()):stopAllActions()
			local resId = var.previewSkills[curSkill].mEffectResID
			local conf = skillConfig[resId]
			-- resId = 30702
			local zorder = conf.mine.zorder or 1
			if conf.mine.rep2  then--魔法盾
				local animate1 = GDivSkill.newSkillAnimateWithFrameData(conf.mine.res1,dir)--施法
				local animate2 = GDivSkill.newSkillAnimateWithFrameData(conf.mine.res2,dir)--持续
				local animate3 = GDivSkill.newSkillAnimateWithFrameData(conf.mine.res3,dir)--消失
				actionOnce = cca.seq({animate1,cca.rep(animate2,conf.mine.rep2),animate3,cca.removeSelf()})
			elseif not conf.huoqiang and conf.other and conf.other.res1 then
				local animate1 = GDivSkill.newSkillAnimateWithFrameData(resId,dir)--施法
				local animate2 = GDivSkill.newSkillAnimateWithFrameData(conf.other.res1,dir)--持续
				local animate3 = cca.show()
				if conf.mine.res2 then
					local spritefly = cc.Sprite:create():addTo(selfNode:getParent()):setPosition(selfNode:getPositionX(),60+otherNode:getPositionY()):setRotation(90)
					local animatefly = GDivSkill.newSkillAnimateWithFrameData(conf.mine.res2,dir)--飞行
					animate3 = cc.TargetedAction:create(spritefly,cca.seq({
						cca.spawn({
							animatefly,
							cca.moveTo(12/30,otherNode:getPositionX(),60+otherNode:getPositionY()),
						}),
						cca.removeSelf()
					}))
				end
				actionOnce = cca.seq({animate1,animate3,cca.place(otherNode:getPosition()),animate2,cca.cb(function(target)
					if resId == 30200 or resId == 30202 then
						for k,v in pairs(otherNode:getChildren()) do
							v:setColor(cc.GREEN)
						end
					end
				end),cca.removeSelf()})
			elseif conf.huoqiang then--火墙
				local animate1 = GDivSkill.newSkillAnimateWithFrameData(conf.mine.res1,dir)
				local animate2 = GDivSkill.newSkillAnimateWithFrameData(conf.other.res1,dir)
				local ozorder= otherNode:getLocalZOrder()
				local ox,oy = otherNode:getPosition()
				local sprite1 = cc.Sprite:create():addTo(otherNode:getParent()):setLocalZOrder(ozorder-1):pos(ox-66,oy)
				local sprite2 = cc.Sprite:create():addTo(otherNode:getParent()):setLocalZOrder(ozorder+1):pos(ox,oy-44)
				local sprite3 = cc.Sprite:create():addTo(otherNode:getParent()):setLocalZOrder(ozorder-1):pos(ox+66,oy)
				local sprite4 = cc.Sprite:create():addTo(otherNode:getParent()):setLocalZOrder(ozorder-1):pos(ox,oy+44)
				local sprite5 = cc.Sprite:create():addTo(otherNode:getParent()):setLocalZOrder(ozorder-1):pos(ox,oy)
				actionOnce = cca.seq({
					animate1,
					cca.hide(),
					cca.spawn({
						cc.TargetedAction:create(sprite1,cca.seq({cca.rep(animate2:clone(),30),cca.removeSelf()})),
						cc.TargetedAction:create(sprite2,cca.seq({cca.rep(animate2:clone(),30),cca.removeSelf()})),
						cc.TargetedAction:create(sprite3,cca.seq({cca.rep(animate2:clone(),30),cca.removeSelf()})),
						cc.TargetedAction:create(sprite4,cca.seq({cca.rep(animate2:clone(),30),cca.removeSelf()})),
						cc.TargetedAction:create(sprite5,cca.seq({cca.rep(animate2:clone(),30),cca.removeSelf()})),
					}),
					cca.removeSelf(),
				})
			elseif conf.mine.opacity then--群体隐身
				local animate = GDivSkill.newSkillAnimateWithFrameData(resId,dir)
				actionOnce = cca.seq({
					animate,
					cca.cb(function()
						selfNode:getChildByName("clothSprite"):setOpacity(conf.mine.opacity)
						selfNode:getChildByName("weaponSprite"):setOpacity(conf.mine.opacity)
						selfNode:getChildByName("wingSprite"):setOpacity(conf.mine.opacity)
						selfNode:getChildByName("shadowSprite"):setOpacity(conf.mine.opacity)
					end),
					cca.removeSelf()
				})
			else
				local animate = GDivSkill.newSkillAnimateWithFrameData(resId,dir)
				if animate then
					showSprite:stopAllActions():show()
					actionOnce = cca.seq({animate,cca.cb(function()
						if resId == 30700 or resId == 30701 then--虎卫
							otherNode:show()
						end
					end),cca.removeSelf()})
				else
					GameSocket:alertLocalMsg("该技能无特效", "alert")
					btnStart:show()
					actionOnce = cca.hide()
				end
			end
			showSprite:setLocalZOrder(zorder)
			if conf.mine.move then
				selfNode:runAction(cca.moveBy(0.6,conf.mine.move.x,conf.mine.move.y))
				showSprite:runAction(cca.spawn({
					cca.moveBy(0.6,conf.mine.move.x,conf.mine.move.y),
					actionOnce
				}))
			else
				showSprite:runAction(actionOnce)				
			end
		end

		local function resetAnimatePlayer(resId)
			local conf = skillConfig[resId]
			assert(resId==0 or conf,"conf nil"..resId)
			playGround:removeAllChildren()
			local avatarSprite = playGround:getChildByName("avatarSprite") or cc.Sprite:create():addTo(playGround):setName("avatarSprite"):setPosition(pos1)
			local otherSprite = playGround:getChildByName("otherSprite") or cc.Sprite:create():addTo(playGround):setName("otherSprite"):setPosition(pos2)
			if conf and conf.mine then
				local skillaction = runAvatarAction(avatarSprite,GDivSkill.STATE.STAND,conf.mine.dir)
				avatarSprite:setPosition(conf.mine.pos)
				avatarSprite:runAction(cca.loop(skillaction))
				avatarSprite:show():setLocalZOrder(1)
			end
			if conf and conf.other then
				local skillaction = runAvatarAction(otherSprite,GDivSkill.STATE.STAND,conf.other.dir,conf.other.cloth,conf.other.weapon,conf.other.wing)
				otherSprite:setPosition(conf.other.pos)
				otherSprite:runAction(cca.loop(skillaction))
				otherSprite:setVisible(conf.other.vis==1):setLocalZOrder(1)
			end
			return avatarSprite,otherSprite
		end
		local function stopPlay()
			btnStart:show()
			resetAnimatePlayer(0)
		end
		local function startPlay()
			if curSkill then
				btnStart:hide()
				local resId = var.previewSkills[curSkill].mEffectResID;
				local conf = skillConfig[resId];
				local dir = conf.mine.dir;
				local avatarSprite,otherSprite = resetAnimatePlayer(resId)
				local action = job == 100 and GDivSkill.STATE.ATTACK or GDivSkill.STATE.SKILL
				if conf.mine.action then
					action = conf.mine.action
				end
				local skillaction = runAvatarAction(avatarSprite,action,dir)
				local prepareAction = runAvatarAction(avatarSprite,GDivSkill.STATE.PREPARE,dir)
				avatarSprite:setPosition(conf.mine.pos)

				avatarSprite:runAction(cca.seq({
					cca.rep(
						cca.seq({
							cca.cb(function(target)
								newSkillAnimate(avatarSprite,otherSprite,conf.mine.skilldir)
							end),
							skillaction,prepareAction
						}),
						conf.rep or 1
					),
					cca.cb(function(target)
						btnStart:show()
						otherSprite:show()
						local idleaction = runAvatarAction(avatarSprite,GDivSkill.STATE.IDLE,dir)
						target:stopAllActions():runAction(cca.repeatForever(idleaction))
					end)
				}))
			end
		end
		GUIFocusPoint.addUIPoint(btnStart, startPlay)

		local function prsSkillItem(sender)
			local nsd = var.previewSkills[sender.tag]
			if curSelectImg then curSelectImg:hide() end
			curSelectImg = sender:getWidgetByName("imgClick"):show()
			curSelectImg:show()
			stopPlay()
			curSkill = sender.tag
			resetAnimatePlayer(nsd.mEffectResID);
			-- print("prsSkillItem//////", GameUtilSenior.encode(nsd))
			var.xmlPageShow:getWidgetByName("lbl_skill_desp"):setString(nsd.desp)
			var.xmlPageShow:getWidgetByName("lbl_skill_name"):setString(nsd.name)
		end

		local skillIcon = nil
		local function updateSkillList(item)
			item:setTouchEnabled(true)
			GUIFocusPoint.addUIPoint(item, prsSkillItem)

			local nsd = var.previewSkills[item.tag]
			skillIcon = item:getWidgetByName("skillIcon")
			local icon = nsd.skill_id
			local imgFire = item:getWidgetByName("imgFire")
			-- if nsd.level == 11 then
			if nsd.angrySkill then
				icon = icon.."_angry"
				--imgFire:loadTexture("img_fire_angry", ccui.TextureResType.plistType):show()
			elseif nsd.staticSkill then
				--imgFire:loadTexture("img_fire_peace", ccui.TextureResType.plistType):show()
			else
				--imgFire:loadTexture("img_fire_peace", ccui.TextureResType.plistType):hide()
			end
			-- print(nsd.skill_id,nsd.name,"image/icon/skill"..icon..".png")
			--skillIcon:loadTexture("image/icon/skill"..icon..".png")
			local path = "image/icon/skill"..icon..".png"
			asyncload_callback(path, skillIcon, function(path, texture)
				skillIcon:loadTexture(path)
			end)
			item:getWidgetByName("skillName"):setString(nsd.name)

			item:getWidgetByName("imgClick"):setVisible(curSkill == item.tag)
			if not curSelectImg then
				-- if not var.defaultSkill then
					if item.tag == 1 then
						prsSkillItem(item)
					end
				-- elseif var.defaultSkill == nsd.skill_id then
				-- 	prsSkillItem(item)
				-- end
			end
		end


		local function handlePanelData(event)
			if event.type ~= "ContainerSkill" then return end
			local data = GameUtilSenior.decode(event.data)
			if data.cmd == "preview" then
				var.previewSkills = data.skills
				local listSkill = var.xmlPageShow:getWidgetByName("listSkill")
				-- if curSelectImg then curSelectImg:hide() end
				curSelectImg = nil
				listSkill:reloadData(#var.previewSkills, updateSkillList):setSliderVisible(false)
			end
		end

		cc.EventProxy.new(GameSocket, var.xmlPageShow)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, handlePanelData)
	end


	var.xmlPageShow = GUIAnalysis.load("ui/layout/ContainerSkill_show.uif")
	if var.xmlPageShow then

		--GameUtilSenior.asyncload(var.xmlPageShow, "img_border", "ui/image/panel_skill_show_bg.jpg")
		var.xmlPageShow:align(display.LEFT_BOTTOM, 0, 0):addTo(var.xmlPanel)

		var.jobID = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)

		initListSkill()
	end

end


return ContainerSkill