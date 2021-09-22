local ContainerCharacter_HunHuan = {}
local var = {}
 -- page变量，初始化函数，刷新函数使用字符窜拼接
local function showPanelPage(index)
	print("fffffffffffffffffffffffffffffff",index)
	if index==5 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "container_reborn"})
		return
	end
	if index==6 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_skill"})
		return
	end
	local key = pageKeys[index]
	if not (key and table.indexof(pageKeys, key))then return end
	var.lastTabIndex = index
	hideAllPages()
	local pageName = "xmlPage"..string.ucfirst(key)
	local initFunc = "initPage"..string.ucfirst(key)
	local openFunc = "openPage"..string.ucfirst(key)
	if not var[pageName] and ContainerCharacter_HunHuan[initFunc] then
		ContainerCharacter_HunHuan[initFunc]()
	end
	if var[pageName] then
		if ContainerCharacter_HunHuan[openFunc] then
			ContainerCharacter_HunHuan[openFunc]()
		end
		var[pageName]:show()
	end
end

function ContainerCharacter_HunHuan.pushTabButtons(sender)
	local tag = sender:getTag()
	if tag ~= 5 and tag ~= 6 and tag~=7 and tag~=8 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="main_avatar",tab=tag})
	end	
	if tag==5 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "container_reborn"})
		return
	end
	--if tag==6 then
	--	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "container_my_hunhuan"})
	--	return
	--end
	if tag==7 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "container_my_zuji"})
		return
	end
	if tag==8 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_skill"})
		return
	end
end

---------------------------------------以上为内部函数---------------------------------------
function ContainerCharacter_HunHuan.initView(extend)
	var = {
		boxTab,
		xmlPanel,
		xmlPageGem,
		xmlPageRole,
		xmlPageReborn,
		xmlPageFashion,
		xmlPageInnerPower,

		powerNum,
		powerFashionNum,
		curClothId,
		curWeaponId,

		barHp,
		barMp,
		barPower,

		shopData = {},
		zsLevel,

		fightNum,
		imgEquipSelected,
		curEquipIndex,

		mSelectedEquip,

		mShowMainEquips,
		mShowSXEquips,
		fashion_data={},
		fashion_preview={},
		fashion_list_cells={},
		curFashionListIndex=1,
	}
	
	--加载称号素材
	asyncload_frames("ui/sprite/ContainerHunHuan",".png")

	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerCharacter_HunHuan.uif")

	if var.xmlPanel then
		var.xmlPanel:getWidgetByName("panel_close"):setLocalZOrder(10)
		var.boxTab = var.xmlPanel:getWidgetByName("box_tab")
		var.boxTab:getParent():setLocalZOrder(10)
		var.boxTab:addTabEventListener(ContainerCharacter_HunHuan.pushTabButtons)		
		return var.xmlPanel
	end
end

function ContainerCharacter_HunHuan.onPanelOpen(extend)
	var.panelExtend = extend
	var.boxTab:setItemMargin(3)
	var.boxTab:hideTab(4)
	var.boxTab:setSelectedTab(6)
	ContainerCharacter_HunHuan.initPageTitle()
end

function ContainerCharacter_HunHuan.onPanelClose()

end




--------------------------------------魂环--------------------------------------
function ContainerCharacter_HunHuan.initPageTitle()

	local function updateInnerLooks()
		ContainerCharacter_HunHuan.tryOnTitle()
	end

	var.xmlPanel:getWidgetByName("lbl_role_name"):setString(GameCharacter._mainAvatar:NetAttr(GameConst.net_name))

	local job = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)
	local imgJob = var.xmlPanel:getWidgetByName("img_Job")
	local jobres = {"img_role_zhan_delete","img_role_fa_delete","img_role_dao_delete"}
	imgJob:loadTexture(jobres[job-99], ccui.TextureResType.plistType)

	local tabhtitle = var.xmlPanel:getWidgetByName("tabhtitle")
	tabhtitle:setItemMargin(0):setTabColor(GameBaseLogic.getColor4(0xefddca),GameBaseLogic.getColor4(0xefddca)):setTabRes("btn_title", "btn_title_sel", ccui.TextureResType.plistType)
	tabhtitle:addTabEventListener(ContainerCharacter_HunHuan.ckickTitleTab)
	
	var.xmlPanel:getWidgetByName("title_wear"):addClickEventListener(ContainerCharacter_HunHuan.ckickDressTitleButton)
	

	local btn_info = var.xmlPanel:getWidgetByName("btn_info")
	btn_info:setTouchEnabled(true):addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.began then
			GameSocket:dispatchEvent({
				name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "tips", visible = true, infoTable = chlblhint,
			})
		elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled  then
			GameSocket:dispatchEvent({
				name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "all", visible = false })
		end
	end)
		GameSocket:PushLuaTable("gui.ContainerHunHuan.handlePanelData",GameUtilSenior.encode({actionid = "alltitlelist"}))
	GameSocket:PushLuaTable("gui.ContainerHunHuan.handlePanelData",GameUtilSenior.encode({actionid = "mycurrenttitle"}))
	GameSocket:PushLuaTable("gui.ContainerHunHuan.handlePanelData",GameUtilSenior.encode({actionid = "mytitlelist"}))
	updateInnerLooks()
	cc.EventProxy.new(GameSocket, var.xmlPanel)
		:addEventListener(GameMessageCode.EVENT_ITEM_CHANGE, ContainerCharacter_HunHuan.freshTitlePage)
		:addEventListener(GameMessageCode.EVENT_AVATAR_CHANGE, updateInnerLooks)

		:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA,ContainerCharacter_HunHuan.setTitledata)

end
function ContainerCharacter_HunHuan.setTitledata(event)
	--GameUtilSenior.print_table(event)
	if event.type == "Title" then
		local pData = GameUtilSenior.decode(event.data)
		if pData then
			if pData.cmd == "dress_title" then
				var.title_data= pData.data
			end
		end
	elseif event.type == "ContainerHunHuan" then
		local data = GameUtilSenior.decode(event.data)
		
		if data.cmd == "alltitlelist" then
			var.title_preview = data.Data;
			--GameSocket:PushLuaTable("gui.ContainerHunHuan.handlePanelData",GameUtilSenior.encode({actionid = "alltitlelist_2"}))
		end
		if data.cmd == "mytitlelist" then
			var.my_title_preview = data.Data;
			ContainerCharacter_HunHuan.freshTitleAttr()
			ContainerCharacter_HunHuan.ckickTitleTab(var.xmlPanel:getWidgetByName("tabhtitle"):getItemByIndex(1))
		end
		if data.cmd == "mycurrenttitle" then
			var.mycurrenttitle = data.Data;
			ContainerCharacter_HunHuan.freshTitleAttr()
			ContainerCharacter_HunHuan.ckickTitleTab(var.xmlPanel:getWidgetByName("tabhtitle"):getItemByIndex(1))
		end
		if data.cmd == "titleAttr" then

			ContainerCharacter_HunHuan.showTitleAttr(data.Data)
			--ContainerCharacter_HunHuan.freshTitleAttr()
			
		end
		
	end
end
function ContainerCharacter_HunHuan.freshTitlePage(event)
	local tabhtitle = var.xmlPanel:getWidgetByName("tabhtitle")
	--if pageKeys[var.boxTab:getCurIndex()] == "title" then
		-- if tabhtitle:getCurIndex() == table.indexof(titlePos,event.pos) then
			ContainerCharacter_HunHuan.ckickTitleTab(tabhtitle:getItemByIndex(tabhtitle:getCurIndex()))
		-- end
		if table.indexof(titlePos,event.pos)  then
			ContainerCharacter_HunHuan.freshTitleAttr(event)
		end
	--end
end
--显示已装备称号属性
function ContainerCharacter_HunHuan.freshTitleAttr(event)
	var.xmlPanel:getWidgetByName("image_title"):stopAllActions():setVisible(false)
	if var.mycurrenttitle ~= nil and var.mycurrenttitle ~="" and var.my_title_preview~=nil and var.my_title_preview~="" then
		for k,val in ipairs(var.my_title_preview) do
			if val.id==var.mycurrenttitle then
				local image_title = var.xmlPanel:getWidgetByName("image_title")
				
				image_title:removeChildByName("spriteEffect")
				GameUtilSenior.addEffect(image_title,"spriteEffect",4,val.res,false,false,true)
				image_title:setVisible(true)
			
				--ContainerCharacter_HunHuan.showTitleAttr(val.detail)
				GameSocket:PushLuaTable("gui.ContainerHunHuan.handlePanelData",GameUtilSenior.encode({actionid = "titleAttr",typeID=val.type_id}))
				local lbllefttime = var.xmlPanel:getWidgetByName("lbllefttime"):hide():stopAllActions()
				local lblleftstr = var.xmlPanel:getWidgetByName("lblleftstr"):hide()
				lblleftstr:show()
				lbllefttime:show()
				local sec = val.expire - os.time()
				if val.expire == 0 then
					lbllefttime:setString("永久")
				else
					GameUtilSenior.runCountDown(lbllefttime,sec,function(target,count)
						target:setString(GameUtilSenior.setTimeFormat(count*1000,6))
					end)
				end
			end
		end
	end
end

function ContainerCharacter_HunHuan.showTitleAttr(val)
	if val==nil or val=="" or not GameUtilSenior.isTable(val) then
		return
	end
	local attrList = var.xmlPanel:getWidgetByName("attrList"):removeAllItems()
	local model = var.xmlPanel:getWidgetByName("model")
	local baseAttrs = {
		--[[
		{key = "物理攻击：", value = {min = val.dc, max = val.dc2}, color=""},
		{key = "魔法攻击：", value = {min = val.mc, max = val.mc2}, color=""},
		{key = "道士攻击：", value = {min = val.sc, max = val.sc2}, color=""},
		{key = "物理防御：", value = {min = val.ac, max = val.ac2}, color=""},
		{key = "魔法防御：", value = {min = val.mac, max = val.mac2}, color=""},
		{key = "生命上限：", value = val.max_hp, color=""},
		{key = "生命增加比例：", value = val.max_hp_pres, color=""},
		]]--
		{key = "生命增加比例：", value = val.v1, color=""},
		--[[
		{key = "暴击率：", value = val.special_attr.baoji_prob, color=""},
		{key = "暴击：", value = val.special_attr.baoji_pres, color=""},
		{key = "内功：", value = val.add_power, color=""},
		{key = "幸运值：", value = val.luck, color=""},
		{key = "反弹比例：", value = val.special_attr.fantan_prob, color="#8a059d"},
		{key = "反弹概率：", value = val.special_attr.fantan_pres, color="#3d16d0"},
		{key = "吸血比例：", value = val.special_attr.xixue_prob, color="#36deb8"},
		]]--
		--[[
		{key = "吸血概率：", value = val.special_attr.xixue_pres, color="#476986"},
		{key = "麻痹时间：", value = val.special_attr.mabi_dura, color="#57a065"},
		{key = "麻痹概率：", value = val.special_attr.mabi_prob, color="#a8c87a"},
		{key = "护身概率：", value = val.special_attr.dixiao_pres, color="#8c3936"},
		{key = "复原CD时间：", value = val.special_attr.fuyuan_cd, color="#faa74c"},
		{key = "复原概率：", value = val.special_attr.fuyuan_pres, color="#d2ee64"},
		{key = "倍伤倍数：", value = val.special_attr.beishang, color="#38d4b9"},
		{key = "免伤倍数：", value = val.special_attr.mianshang, color="#3537c5"},
		{key = "吸收伤害比例：", value = val.special_attr.xishou_prob, color="#15da88"},
		{key = "吸收伤害概率：", value = val.special_attr.xishou_pres, color="#c43e75"},
		{key = "总体物防比例：", value = val.special_attr.mACRatio, color="#18a335"},
		]]--
		{key = "总体物防比例：", value = val.v1, color="#18a335"},
		--[[
		{key = "总体魔防比例：", value = val.special_attr.mMCRatio, color="#f8a14a"},
		{key = "总体物攻比例：", value = val.special_attr.mDCRatio, color="#9c44a6"},
		]]--
		{key = "总体物攻比例：", value = val.v1, color="#9c44a6"},
		{key = "吸血比例：", value = val.v2, color="#36deb8"},
		--[[
		{key = "忽视防御比例：", value = val.special_attr.mIgnoreDCRatio, color="#8addf9"},
		{key = "杀人爆率提升：", value = val.special_attr.mPlayDrop, color="#f9f2b6"},
		{key = "怪物爆率提升：", value = val.special_attr.mMonsterDrop, color="#29ed8e"},
		{key = "死亡爆率下降：", value = val.special_attr.mDropProtect, color="#1952a1"},
		{key = "防止麻痹概率：", value = val.special_attr.mMabiProtect, color="#bda134"},
		]]--
	}
	--print(GameUtilSenior.encode(baseAttrs))
	--GameUtilSenior.print_table(baseAttrs)

	for i,v in ipairs(baseAttrs) do
		if GameUtilSenior.isTable(v.value) then
			if v.value.max > 0 then
				local modeli = model:clone()
				modeli:getWidgetByName("attrName"):setString(v.key)
				modeli:getWidgetByName("attrValue"):setString(v.value.min.."-"..v.value.max)
				attrList:pushBackCustomItem(modeli)
			end
		elseif v.value > 0 then
			if string.find(v.key,"率") ~= nil or string.find(v.key,"例") ~= nil or string.find(v.key,"倍") ~= nil then
				v.value = (v.value / 100).."%"
			end
			local modeli = model:clone()
			if v.color~= nil and v.color~= "" and false then
				--str = str.."<font color="..v.color..">"..v.key..v.value.."</font><br>"
				modeli:getWidgetByName("attrName"):setString("<font color="..v.color..">"..v.key.."</font>")
				modeli:getWidgetByName("attrValue"):setString("<font color="..v.color..">"..v.value.."</font>")
			else
				--str = str..v.key..v.value.."<br>"
				modeli:getWidgetByName("attrName"):setString(v.key)
				modeli:getWidgetByName("attrValue"):setString(v.value)
			end
			attrList:pushBackCustomItem(modeli)
		end
	end
end

function ContainerCharacter_HunHuan.tryOnTitle(titleId)
		--翅膀
		local img_wing = var.xmlPanel:getChildByName("img_wing")

		--设置翅膀内观
		if not img_wing then
			img_wing = cc.Sprite:create()
			img_wing:addTo(var.xmlPanel):align(display.CENTER, 386, 370):setName("img_wing"):setVisible(false)
		end
		-- local weaponDef = GameSocket:getItemDefByPos(GameConst.ITEM_WEAPON_POSITION)
		local wing = GameCharacter._mainAvatar:NetAttr(GameConst.net_wing)
		if wing then
			--if wing~=var.curwingId then
				img_wing:removeChildByName("spriteEffect")
				GameUtilSenior.addEffect(img_wing,"spriteEffect",GROUP_TYPE.WING_REVIEW,wing,{x=0,y=-100},false,true)
				--var.curwingId=wing
			---end
		else
			img_wing:setTexture(nil)
			img_wing:setVisible(false)
			var.curwingId=nil
		end
		
		--武器
		local img_weapon = var.xmlPanel:getChildByName("img_weapon")
	    --设置武器内观
		if not img_weapon then
			img_weapon = cc.Sprite:create()
			img_weapon:addTo(var.xmlPanel):setAnchorPoint(cc.p(0.52,0.3)):setPosition(296, 370):setName("img_weapon"):setLocalZOrder(3):setVisible(false)
		end
		local weaponDef
		if not GameSocket:getItemDefByPos(GameConst.ITEM_FASHION_CLOTH_POSITION) then
			weaponDef = GameSocket:getItemDefByPos(GameConst.ITEM_WEAPON_POSITION)
		end
		if weaponDef then
			if weaponDef.mResMale~=img_weapon.curWeaponId then
				
				img_weapon:removeChildByName("spriteEffect")
				GameUtilSenior.addEffect(img_weapon,"spriteEffect",GROUP_TYPE.WEAPON_REVIEW,weaponDef.mResMale,{x=-150,y=241},false,true)
				
				
				img_weapon.curWeaponId=weaponDef.mResMale
			end
		else
			img_weapon:stopAllActions()
			img_weapon:setTexture(nil)
			img_weapon:setVisible(false)
			img_weapon.curWeaponId=nil
		end
		--衣服
		local img_role = var.xmlPanel:getChildByName("img_role")
		--设置衣服内观
		if not img_role then
			img_role = cc.Sprite:create()
			img_role:addTo(var.xmlPanel):align(display.CENTER, 270, 270):setName("img_role"):setLocalZOrder(2):setVisible(false)
		end
		local clothDef,clothId
		local isFashion = false
		--if GameSocket:getItemDefByPos(GameConst.ITEM_FASHION_CLOTH_POSITION) then
			local fashion = GameCharacter._mainAvatar:NetAttr(GameConst.net_fashion)
			local cloth = GameCharacter._mainAvatar:NetAttr(GameConst.net_cloth)
			if fashion >0 then
				clothId = fashion
				isFashion = true
			else
				clothDef = GameSocket:getItemDefByPos(GameConst.ITEM_CLOTH_POSITION)
				if clothDef then
					clothId = clothDef.mResMale
				else 
					clothId = cloth
				end
			end
		--end
		if not clothId then
			local gender = GameCharacter._mainAvatar:NetAttr(GameConst.net_gender)
			local luoti= gender==200 and  10000000 or 10000001
			clothId = luoti
		end
		
		if titleId then
			for k,v in ipairs(var.title_preview) do
			
				if tonumber(v.type_id)==tonumber(titleId) then
				
					local image_title = var.xmlPanel:getWidgetByName("image_title")
					
					image_title:removeChildByName("spriteEffect")
					GameUtilSenior.addEffect(image_title,"spriteEffect",4,v.res,false,false,true)
					image_title:setVisible(true)
					
					GameSocket:PushLuaTable("gui.ContainerHunHuan.handlePanelData",GameUtilSenior.encode({actionid = "titleAttr",typeID=v.type_id}))
					--ContainerCharacter_HunHuan.showTitleAttr(v)
				end
			end
			for k,v in ipairs(var.my_title_preview) do
				if tonumber(v.id)==tonumber(titleId) then

					local image_title = var.xmlPanel:getWidgetByName("image_title")
					
					
					image_title:removeChildByName("spriteEffect")
					GameUtilSenior.addEffect(image_title,"spriteEffect",4,v.res,false,false,true)
					image_title:setVisible(true)
					
					GameSocket:PushLuaTable("gui.ContainerHunHuan.handlePanelData",GameUtilSenior.encode({actionid = "titleAttr",typeID=v.type_id}))
					--ContainerCharacter_HunHuan.showTitleAttr(v)
					
					local lbllefttime = var.xmlPanel:getWidgetByName("lbllefttime"):hide():stopAllActions()
					local lblleftstr = var.xmlPanel:getWidgetByName("lblleftstr"):hide()
					lblleftstr:show()
					lbllefttime:show()
					local sec = v.expire - os.time()
					if v.expire == 0 then
						lbllefttime:setString("永久")
					else
						GameUtilSenior.runCountDown(lbllefttime,sec,function(target,count)
							target:setString(GameUtilSenior.setTimeFormat(count*1000,6))
						end)
					end
				end
			end
			
		end
		--print("img_role.curClothId",clothId,img_role.curClothId)
		img_role:removeChildByName("spriteEffect")
		if isFashion then
			GameUtilSenior.addEffect(img_role,"spriteEffect",GROUP_TYPE.FDRESS_REVIEW,clothId,{x=-122,y=330},false,true)
		else
			GameUtilSenior.addEffect(img_role,"spriteEffect",GROUP_TYPE.CLOTH_REVIEW,clothId,{x=-122,y=330},false,true)
		end

end
--function ContainerCharacter_HunHuan.ckickDressTitleButton( sender )
function ContainerCharacter_HunHuan.ckickDressTitleButton(  )
	--GameSocket:PushLuaTable("gui.ContainerHunHuan.handlePanelData",GameUtilSenior.encode({actionid = "settitle",titleid = sender.titleid}))
	if var.curTitleListIndex~=nil and tonumber(var.curTitleListIndex)>0 then
		GameSocket:PushLuaTable("gui.ContainerHunHuan.handlePanelData",GameUtilSenior.encode({actionid = "settitle",titleid = var.my_title_preview[var.curTitleListIndex].id}))
	else
		GameSocket:PushLuaTable("gui.ContainerHunHuan.handlePanelData",GameUtilSenior.encode({actionid = "settitle",titleid = 0}))
		ContainerCharacter_HunHuan.ckickTitleTab(var.xmlPanel:getWidgetByName("tabhtitle"):getItemByIndex(1))
	end
end

--刷新称号列表
function ContainerCharacter_HunHuan.ckickTitleTab(tab)
	--if var.mycurrenttitle == nil or var.title_preview==nil then
	--	return
	--end
	ContainerCharacter_HunHuan.tryOnTitle();
	local function pushSelectItem(item)
		if item and item.tagTitleOnlyId ~=nil and item.tagTitleOnlyId ~="" and item.tagTitleOnlyId~=0 then
			ContainerCharacter_HunHuan.TryTitleShow(item.tagTitleId,item.tag);
		elseif item and item.tagTitleId ~=nil and item.tagTitleId ~="" then
			--ContainerCharacter_HunHuan.tryOnTitle(item.tagTitleId)
			--print(item.tagTitleId)
			ContainerCharacter_HunHuan.TryTitleShow(item.tagTitleId,item.tag);
		end
	end
	local tag = tab:getTag()
	var.title_list_cells={};
	var.curTitleListIndex = 0;
	if tag == 1 then

		--新版本称号列表开始
		if var.my_title_preview ==nil then
			var.my_title_preview = {}
		end
		
		local currentIndex = 1
		
		if var.mycurrenttitle~=0 and var.mycurrenttitle~="" and var.mycurrenttitle~=nil then
			currentIndex = tonumber(var.mycurrenttitle)
		end
		
		if currentIndex==1 then
			if #var.my_title_preview>0 then
				currentIndex = var.my_title_preview[1].id
			end
		end
		
		local items={}
		local list_btn = var.xmlPanel:getWidgetByName("list_btn"):setVisible(true)
		list_btn:reloadData(#var.my_title_preview,function( subItem )
			table.insert(items,subItem)
			local function  showMapDetail( sender )
				for i,v in ipairs(items) do
					v:getWidgetByName("title_btn_font"):loadTexture(string.format("ContainerHunHuan_left_btn_%d_1.png",(tonumber(v:getWidgetByName("title_btn_font").titleTypeid))),ccui.TextureResType.plistType)
					--v:getWidgetByName("title_btn_font"):loadTexturePressed(string.format("ContainerHunHuan_left_btn_%d_3.png",(tonumber(v:getWidgetByName("title_btn_font").titleTypeid))),ccui.TextureResType.plistType)
					v:getWidgetByName("title_btn"):loadTexture("ContainerHunHuan_2.png",ccui.TextureResType.plistType)
					v:getWidgetByName("title_btn_animal"):setVisible(false)
				end
				subItem:getWidgetByName("title_btn"):loadTexture("ContainerHunHuan_3.png",ccui.TextureResType.plistType)
				subItem:getWidgetByName("title_btn_font"):loadTexture(string.format("ContainerHunHuan_left_btn_%d_2.png",(tonumber(var.my_title_preview[subItem.tag].type_id))),ccui.TextureResType.plistType)
				--subItem:getWidgetByName("title_btn_font"):loadTexturePressed(string.format("ContainerHunHuan_left_btn_%d_2.png",(tonumber(var.my_title_preview[subItem.tag].type_id))),ccui.TextureResType.plistType)
				subItem:getWidgetByName("title_btn_animal"):setVisible(true)
				var.xmlPanel:getWidgetByName("title_wear"):loadTextureNormal("title_wear.png",ccui.TextureResType.plistType)
				pushSelectItem(sender:getWidgetByName("title_btn_font"))
				if var.mycurrenttitle==var.my_title_preview[subItem.tag].id then
					var.xmlPanel:getWidgetByName("title_wear"):loadTextureNormal("title_undress.png",ccui.TextureResType.plistType)
					var.curTitleListIndex = 0
				end
			end
			subItem:getWidgetByName("title_btn_font"):loadTexture(string.format("ContainerHunHuan_left_btn_%d_1.png",(tonumber(var.my_title_preview[subItem.tag].type_id))),ccui.TextureResType.plistType)
			--subItem:getWidgetByName("title_btn_font"):loadTexturePressed(string.format("ContainerHunHuan_left_btn_%d_3.png",(tonumber(var.my_title_preview[subItem.tag].type_id))),ccui.TextureResType.plistType)
			subItem:getWidgetByName("title_btn"):loadTexture("ContainerHunHuan_2.png",ccui.TextureResType.plistType)
			subItem:getWidgetByName("title_btn_animal"):setVisible(false)
			subItem:getWidgetByName("title_btn_font").titleid = var.my_title_preview[subItem.tag].id
			subItem:getWidgetByName("title_btn_font").tagTitleOnlyId = var.my_title_preview[subItem.tag].id
			subItem:getWidgetByName("title_btn_font").titleTypeid = var.my_title_preview[subItem.tag].type_id
			subItem:getWidgetByName("title_btn_font").tagTitleId = var.my_title_preview[subItem.tag].type_id
			subItem:getWidgetByName("title_btn_font").tag = subItem.tag
			--GUIFocusPoint.addUIPoint(subItem:getWidgetByName("title_btn_font"), showMapDetail)
			
			subItem:setTouchEnabled(true)
			subItem:addClickEventListener(function ( sender )
				currentIndex = sender:getWidgetByName("title_btn_font").tagTitleOnlyId
				showMapDetail(sender)
			end)
			
			--动画
			local title_animal = subItem:getWidgetByName("title_btn_animal")
			local startNum = 50
			local function startShowTitleBg()
				
				title_animal:loadTexture(string.format("ContainerHunHuan_%d.png",startNum), ccui.TextureResType.plistType)
				
				startNum= startNum+1
				if startNum ==112 then
					startNum =50
				end
			end
			title_animal:stopAllActions()
			title_animal:runAction(cca.repeatForever(cca.seq({cca.delay(0.01),cca.cb(startShowTitleBg)}),tonumber(63)))
			
			if tonumber(subItem:getWidgetByName("title_btn_font").tagTitleOnlyId)==tonumber(currentIndex) then
				showMapDetail(subItem)
			end
		end)
		
	elseif tag == 2 then
		--GameUtilSenior.print_table(#var.title_preview)
		var.xmlPanel:getWidgetByName("titleList"):reloadData(#var.title_preview,function(subItem)
			--GameUtilSenior.print_table(subItem)
		
			local previewdata = var.title_preview[subItem.tag]
			
			local icon = subItem:getWidgetByName("icon")
			local icon_img = icon:getChildByName("icon_img")
			if not icon_img then
				local pSize = icon:getContentSize()
				icon_img = cc.Sprite:create()
				icon_img:addTo(icon):align(display.CENTER, pSize.width * 0.5, pSize.height * 0.5):setName("icon_img"):setLocalZOrder(2)
			end
			local filepath = "image/icon/"..previewdata.icon_id..".png"
			asyncload_callback(filepath, icon_img, function(filepath, texture)
				icon_img:setVisible(true)
				icon_img:setTexture(filepath)
			end)
			
			subItem:getWidgetByName("img_selected"):setVisible(false);
			subItem:getWidgetByName("itemname"):setString(previewdata.name)
			subItem:getWidgetByName("btn_dress"):setVisible(false)
			subItem:getWidgetByName("hasDress"):setVisible(false)
			subItem:getWidgetByName("lbl_title_remark"):setVisible(true):setString(previewdata.source)
			subItem.tagTitleId = previewdata.type_id;
			subItem.tagTitleOnlyId = 0;
			subItem:setTouchEnabled(true)
			GUIFocusPoint.addUIPoint(subItem, pushSelectItem)

			local needCellpre = var.title_list_cells[subItem.tag];
			if not needCellpre then
				needCellpre = subItem;
				needCellpre:setName(subItem:getName()..subItem.tag);
			end
			var.title_list_cells[subItem.tag] = needCellpre;

		end)
	end
end

function ContainerCharacter_HunHuan.TryTitleShow(titleid,listindex)
	ContainerCharacter_HunHuan.tryOnTitle(titleid);
	--[[
	if var.curTitleListIndex > 0 and var.title_list_cells[var.curTitleListIndex] then
		var.title_list_cells[var.curTitleListIndex]:getWidgetByName("img_selected"):setVisible(false)
	end
	var.title_list_cells[listindex]:getWidgetByName("img_selected"):setVisible(true)
	]]--
	var.curTitleListIndex = listindex;
end

function ContainerCharacter_HunHuan.openPageTitle()
	local tabhtitle = var.xmlPanel:getWidgetByName("tabhtitle")
	tabhtitle:setSelectedTab(1)
	local guild_name = GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name)
	if not guild_name or guild_name == "" then
		guild_name = "暂无行会"
	end
	
	
	--
	ContainerCharacter_HunHuan:updateGameMoney(var.xmlPanel)
	--
	
	--var.xmlPanel:getWidgetByName("lbl_guild_name"):setString(guild_name)

	ContainerCharacter_HunHuan.freshTitleAttr()
	GameSocket:PushLuaTable("item.chufa.gettitlelook",GameUtilSenior.encode({actionid = "reqtitleData",params={}}))

end


return ContainerCharacter_HunHuan