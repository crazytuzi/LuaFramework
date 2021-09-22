local ContainerFly = {}
local var = {}
local TEXT_COLOR = {
	ENABLED = cc.c4b(20,160,20,255),
	DISABLED = cc.c4b(255,0,0,255),
}
local MAX_WING_LV = 14;
function ContainerFly.initView()
	var = {
		xmlPanel,
		wingIndex,
		panelData,
		wingbg,
		attrModMap,
		loadingbar,
		levelupAction = false,
		isInit = false,
		winglv,
		btn_usevcoin,
		isUsevcoin = false,
		btn_upgrade_ato,
		isupgrade_ato = false,
		act_flag=0,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerFly.uif")
	if var.xmlPanel then
		GameUtilSenior.asyncload(var.xmlPanel, "panel_wing_bg", "ui/image/img_wing_bg.jpg")
		

		cc.EventProxy.new(GameSocket,var.xmlPanel):addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerFly.handlePanelData)
		
		
		ContainerFly.updateGameMoney()
		var.xmlPanel:getWidgetByName("box_tab"):addTabEventListener(pushTabButtons)
		var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab(1)
		
		return var.xmlPanel
	end
end


function pushTabButtons(sender)
	local opened, level, funcName
	opened = true
	local tag = sender:getTag()
end

--金币刷新函数
function ContainerFly:updateGameMoney()
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


local despTable ={
	"<font color=#E7BA52 size=18>翅膀升阶说明</font>",
	"<font color=#f1e8d0>1.翅膀升阶失败后会产生祝福值,提高下次升阶成功率，</font>",
    "<font color=#ff0000>2.祝福值每天早上6点清空(1、2、3阶翅膀升级祝福值不清零)</font>",
    "<font color=#f1e8d0>3.祝福值越高,翅膀升阶的成功率越高,当祝福值达到满值时,翅膀升阶将100%成功</font>",

}

function ContainerFly.onPanelOpen()
	if not var.isInit then
		ContainerFly.initPageChiBang()
		var.isInit = true
		var.act_flag=0
	end
	GameSocket:PushLuaTable("gui.ContainerFly.onPanelData",GameUtilSenior.encode({actionid = "panel"}))
end



function ContainerFly.initPageChiBang()

	var.xmlPanel:getWidgetByName("btn_upgrade"):addClickEventListener(function (sender)
		GameSocket:PushLuaTable("gui.ContainerFly.onPanelData",GameUtilSenior.encode({actionid = "upgrade", param= var.isUsevcoin }))	
	end)
	local btnDesp = var.xmlPanel:getWidgetByName("Button_ask")
	btnDesp:setTouchEnabled(true)
	btnDesp:addTouchEventListener(function (pSender, touchType)
		if touchType == ccui.TouchEventType.began then
			ContainerFly.Desp()
		elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then	
			GDivDialog.handleAlertClose()
		end
	end)

	local function RunAction(  )
		if  var.isupgrade_ato then 
			GameSocket:PushLuaTable("gui.ContainerFly.onPanelData",GameUtilSenior.encode({actionid = "upgrade", param= var.isUsevcoin }))	
			
			if var.panelData.nostuff ==1 then ----------没有材料 自动停止
				var.isupgrade_ato = not var.isupgrade_ato
				var.btn_upgrade_ato:setTitleText( not var.isupgrade_ato and "自动培养" or "停止培养")
				return
			end 
			var.btn_upgrade_ato:runAction(cca.seq({
				cca.delay(0.3),
				cca.cb(RunAction) 
			}))
		end 
	end

	var.btn_upgrade_ato = var.xmlPanel:getWidgetByName("btn_upgrade_ato")

	var.btn_upgrade_ato:addClickEventListener(function (sender)
		
		var.isupgrade_ato = not var.isupgrade_ato
		sender:setTitleText( not var.isupgrade_ato and "自动培养" or "停止培养")
		RunAction()	
	end)

	var.btn_usevcoin = var.xmlPanel:getWidgetByName("btn_usevcoin")
	var.btn_usevcoin:addClickEventListener(function (sender)
		var.isUsevcoin = not var.isUsevcoin
		sender:loadTextureNormal( (var.isUsevcoin and "btn_checkbox_big_sel") or "btn_checkbox_big", ccui.TextureResType.plistType)
	end)

	-- var.wingbg = var.xmlPanel:getWidgetByName("img_wing_view")
	-- var.wingbg2 = var.xmlPanel:getWidgetByName("img_wing_view2")

	--local filepath = "image/typeface/skillname"..skill_type..".png"

	-- local equipBg = var.xmlPanel:getWidgetByName("Image_1")
	-- equipBg:loadTexture("wing_1", ccui.TextureResType.plistType)



	var.loadingbar = var.xmlPanel:getWidgetByName("progressBar"):setLabelVisible(false )
end

function ContainerFly.handlePanelData(event)
	
	if event.type == "ContainerFly" then
		var.panelData = GameUtilSenior.decode(event.data)
		if var.panelData.cmd =="update" then
			ContainerFly.updatePageChiBang()
		end
	end
end

--升级成功特效
function ContainerFly.successAnimate()
	local fireworks = cc.Sprite:create():addTo(var.xmlPanel):pos(440, 350)
	local animate = cc.AnimManager:getInstance():getPlistAnimate(4,75000,4,7,false,false,0,function(animate,shouldDownload)
							fireworks:runAction(cca.seq({
								cca.rep(animate, 1),
								cca.removeSelf()
							}))
							if shouldDownload==true then
								fireworks:release()
							end
						end,
						function(animate)
							fireworks:retain()
						end)
	
end

function ContainerFly.updatePageChiBang()
	if var.xmlPanel and var.panelData then
		if var.winglv ~= var.panelData.wingLv then 
			var.isupgrade_ato= false
			var.btn_upgrade_ato:setTitleText( not var.isupgrade_ato and "自动培养" or "停止培养")
		end 
		if var.act_flag ==1 then 
			if var.panelData.isaction==1 then 
				ContainerFly.successAnimate()	
			end
		end 
		var.act_flag =1

		var.winglv = var.panelData.wingLv

		ContainerFly.showWingAnimation(var.winglv)
		local value = var.panelData.blessvalue
		local maxValue = var.panelData.maxValue;
		var.xmlPanel:getWidgetByName("progressBar"):setVisible(false)
		var.xmlPanel:getWidgetByName("btn_upgrade"):setVisible(true)
		var.xmlPanel:getWidgetByName("label_progressbar"):setString(value)
		--var.xmlPanel:getWidgetByName("Txt_lingyu"):setRichLabel(var.panelData.num_of_lingyu.."/"..var.panelData.need_num_of_lingyu)
		--print("---------------------",var.panelData.items)
		var.xmlPanel:getWidgetByName("Txt_lingyu"):setRichLabel("<font size='16'>"..var.panelData.items.."</font>")
		value = value < maxValue and value or maxValue
		var.loadingbar:setPercent(value,maxValue, nil)

		local attr = var.panelData.wingAttr
		local nAttr = var.panelData.nextAttr
		local arrowTag = var.panelData.arrowTag

		var.xmlPanel:getWidgetByName("txt_mdc_now"):setString(attr[1])
		var.xmlPanel:getWidgetByName("txt_mac_now"):setString(attr[4])
		var.xmlPanel:getWidgetByName("txt_mmac_now"):setString(attr[5])
		
		var.xmlPanel:getWidgetByName("txt_mdc_next"):setString(nAttr[1])
		var.xmlPanel:getWidgetByName("txt_mac_next"):setString(nAttr[4])
		var.xmlPanel:getWidgetByName("txt_mmac_next"):setString(nAttr[5])


		-- var.wingbg = var.xmlPanel:getWidgetByName("img_wing_view")
		-- var.wingbg2 = var.xmlPanel:getWidgetByName("img_wing_view2")
		local equipBg1 = var.xmlPanel:getWidgetByName("Image_1")
		local equipBg2 = var.xmlPanel:getWidgetByName("Image_2")
		local equipBg3 = var.xmlPanel:getWidgetByName("Image_3")
		local equipBg4 = var.xmlPanel:getWidgetByName("Image_4")
		local equipBg5 = var.xmlPanel:getWidgetByName("Image_5")

		local equipBg1_ = var.xmlPanel:getWidgetByName("Image_1_0")
		local equipBg2_ = var.xmlPanel:getWidgetByName("Image_2_0")
		local equipBg3_ = var.xmlPanel:getWidgetByName("Image_3_0")
		local equipBg4_ = var.xmlPanel:getWidgetByName("Image_4_0")
		local equipBg5_ = var.xmlPanel:getWidgetByName("Image_5_0")

		local level_left = var.xmlPanel:getWidgetByName("level_left")
		local level_right = var.xmlPanel:getWidgetByName("level_right")
		local wing_Table={
		[0]={img1="ti",img2="yan",},
		[1]={img1="wing_1",img2="jie",img3="wing_1_r",img4="jie_r"},
		[2]={img1="wing_2",img2="jie",img3="wing_2_r",img4="jie_r"},
		[3]={img1="wing_3",img2="jie",img3="wing_3_r",img4="jie_r"},
		[4]={img1="wing_4",img2="jie",img3="wing_4_r",img4="jie_r"},
		[5]={img1="wing_5",img2="jie",img3="wing_5_r",img4="jie_r"},
		[6]={img1="wing_6",img2="jie",img3="wing_6_r",img4="jie_r"},
		[7]={img1="wing_7",img2="jie",img3="wing_7_r",img4="jie_r"},
		[8]={img1="wing_8",img2="jie",img3="wing_8_r",img4="jie_r"},
		[9]={img1="wing_9",img2="jie",img3="wing_9_r",img4="jie_r"},
		[10]={img1="wing_10",img2="jie",img3="wing_10_r",img4="jie_r"},
		[11]={img1="wing_10",img2="wing_1",img3="jie",img4="wing_10_r",img5="wing_1_r",img6="jie_r"},
		[12]={img1="wing_10",img2="wing_2",img3="jie",img4="wing_10_r",img5="wing_2_r",img6="jie_r"},
		}

		--local Level=var.panelData.levelName
		local Level=var.panelData.levelName
		local nextLv=Level+1
		
		if Level==0 then 
			level_left:setString("体验")
			--equipBg2:loadTexture("ti", ccui.TextureResType.plistType)
			--equipBg4:loadTexture("yan", ccui.TextureResType.plistType)
		elseif Level<=10 then 
			level_left:setString(GameConst.nums[Level].."阶")
			--equipBg2:loadTexture(wing_Table[Level].img1, ccui.TextureResType.plistType)
			--equipBg4:loadTexture(wing_Table[Level].img2, ccui.TextureResType.plistType)
		elseif Level>10 then
			level_left:setString(GameConst.nums[Level].."阶")
			--equipBg2:setVisible(false)
			--equipBg4:setVisible(false)
			--equipBg1:loadTexture(wing_Table[Level].img1, ccui.TextureResType.plistType)
			--equipBg3:loadTexture(wing_Table[Level].img2, ccui.TextureResType.plistType)
			--equipBg5:loadTexture(wing_Table[Level].img3, ccui.TextureResType.plistType)	
		end

		if nextLv<=10 then 	
			level_right:setString(GameConst.nums[nextLv].."阶")
			--equipBg2_:loadTexture(wing_Table[nextLv].img3, ccui.TextureResType.plistType)
			--equipBg4_:loadTexture(wing_Table[nextLv].img4, ccui.TextureResType.plistType)
		elseif nextLv>10  and nextLv< 13 then
			level_right:setString(GameConst.nums[nextLv].."阶")
			--equipBg2_:setVisible(false)
			--equipBg4_:setVisible(false) 
			--equipBg1_:loadTexture(wing_Table[nextLv].img4, ccui.TextureResType.plistType)
			--equipBg3_:loadTexture(wing_Table[nextLv].img5, ccui.TextureResType.plistType)
			--equipBg5_:loadTexture(wing_Table[nextLv].img6, ccui.TextureResType.plistType)		
		else 
			level_right:hide()
			--equipBg2_:setVisible(false)
			--equipBg4_:setVisible(false) 
			--equipBg1_:setVisible(false)
			--equipBg3_:setVisible(false)
			--equipBg5_:setVisible(false)
		end
		var.xmlPanel:getWidgetByName("clean_tip"):hide()
		if var.winglv>3 and value>0 then
			--显示倒计时
			local clean_tip = var.xmlPanel:getWidgetByName("clean_tip"):show()
			local last_time

			if tonumber(os.date("%H"))<6 then
				last_time = os.time({day = tonumber(os.date("%d")),month=tonumber(os.date("%m")),year=tonumber(os.date("%Y")),hour=6,minute=0,second=0})-os.time()
			else
				print(tonumber(os.date("%d")))
				last_time = os.time({day =tonumber(os.date("%d")),month=tonumber(os.date("%m")),year=tonumber(os.date("%Y")),hour=24,minute=0,second=0})-os.time()+( os.time({day=tonumber(os.date("%d")),month=tonumber(os.date("%m")),year=tonumber(os.date("%Y")),hour=6,minute=0,second=0})-os.time({day=tonumber(os.date("%d")),month=tonumber(os.date("%m")),year=tonumber(os.date("%Y")),hour=0,minute=0,second=0}) )
			end
			clean_tip:setString("祝福值清理倒计时:"..GameUtilSenior.setTimeFormat(last_time*1000))
			cc.Director:getInstance():getActionManager():removeAllActionsFromTarget(clean_tip)
			clean_tip:runAction(cca.rep(cca.seq({
				cca.delay(1),
				cca.cb(function()
					last_time= last_time-1
					if last_time<0 then
						if tonumber(os.date("%H"))<6 then
							last_time = os.time({day = tonumber(os.date("%d")),month=tonumber(os.date("%m")),year=tonumber(os.date("%Y")),hour=6,minute=0,second=0})-os.time()
						else
							print(tonumber(os.date("%d")))
							last_time = os.time({day =tonumber(os.date("%d")),month=tonumber(os.date("%m")),year=tonumber(os.date("%Y")),hour=24,minute=0,second=0})-os.time()+( os.time({day=tonumber(os.date("%d")),month=tonumber(os.date("%m")),year=tonumber(os.date("%Y")),hour=6,minute=0,second=0})-os.time({day=tonumber(os.date("%d")),month=tonumber(os.date("%m")),year=tonumber(os.date("%Y")),hour=0,minute=0,second=0}) )
						end
					end
					clean_tip:setString("祝福值清理倒计时:"..GameUtilSenior.setTimeFormat(last_time*1000))

				end)
			}),10000))
		end
	end
end

function ContainerFly.showWingAnimation(level)
	-- if var.wingbg.tag == level then return end
	-- local filepath = "image/"..(GameConst.WING_TEXTURE_START_ID+level-1)
	-- local wingImg = var.wingbg:getChildByName("wingImg")
	-- if not wingImg then
	-- 	wingImg = cc.Sprite:create():addTo(var.wingbg):scale(0.8):setAnchorPoint(cc.p(0.5,0.5)):pos(40,50)
	-- 	wingImg:setName("wingImg")
	-- else
	-- 	wingImg:stopAllActions()
	-- end
	-- local filelist = GameUtilSenior.getFilelist(filepath, 2, 7, 5)
	-- GameUtilSenior.getAnimateByFileList(filelist,wingImg,0.15,function (anim)
	-- 	wingImg:runAction(cca.repeatForever(anim))
	-- 	if GameUtilSenior.isObjectExist(var.wingbg) then
	-- 		var.wingbg.tag = level

	-- 		if var.levelupAction then
	-- 			var.levelupAction = false
	-- 			local animate = cc.AnimManager:getInstance():getBinAnimate(4,990017,0,true)
	-- 			if animate then
	-- 				local action = cc.Sprite:create()
	-- 					:addTo(var.wingbg,2)
	-- 					:align(display.CENTER,-26,40)
	-- 					:setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
	-- 				action:runAction(
	-- 					cca.seq({
	-- 						animate,
	-- 						cca.removeSelf()
	-- 					})
	-- 				)
	-- 			end
	-- 		end
	-- 	end
	-- end)
	--local filepath = "image/typeface/skillname"..skill_type..".png"
	--local data_wing={50000,50001,50002,50003,50004,50005,50006,50007,50008,50009,50010,50011,50012,50013}
	--称号特效对应170001-170999
	var.xmlPanel:getWidgetByName("img_wing_view"):removeChildByName("spriteEffect")
	var.xmlPanel:getWidgetByName("img_wing_view2"):removeChildByName("spriteEffect")
	GameUtilSenior.addEffect(var.xmlPanel:getWidgetByName("img_wing_view"),"spriteEffect",GROUP_TYPE.WING_REVIEW,70001+level,false,false,true)
	GameUtilSenior.addEffect(var.xmlPanel:getWidgetByName("img_wing_view2"),"spriteEffect",GROUP_TYPE.WING_REVIEW,70001+level+1,false,false,true)
	--if var.wingbg.tag == level then return end
	--[[
	local img_wingl = var.xmlPanel:getWidgetByName("img_wing_view"):getChildByName("img_wing")
	if not img_wingl then
		img_wingl = cc.Sprite:create()
		img_wingl:addTo(var.xmlPanel:getWidgetByName("img_wing_view")):align(display.CENTER, 23, 23):setName("img_wing")
	end
	local filepath = "image/fly/"..data_wing[level+1]..".png"
	asyncload_callback(filepath, img_wingl, function(filepath, texture)
		img_wingl:setTexture(filepath)
	end)
	local img_wingr = var.xmlPanel:getWidgetByName("img_wing_view2"):getChildByName("img_wingr")
	if not img_wingr then
		img_wingr = cc.Sprite:create()
		img_wingr:addTo(var.xmlPanel:getWidgetByName("img_wing_view2")):align(display.CENTER, 23, 23):setName("img_wingr")
	end
	if data_wing[level+2] then 
		local filepath2 = "image/fly/"..data_wing[level+2]..".png"
		asyncload_callback(filepath2, img_wingr, function(filepath2, texture)
			img_wingr:setTexture(filepath2):scale(1)
		end)
	else
		img_wingr:setVisible(false)
	end
	--]]

	-- local filepath = "image/cloth/"..cloth.mIconID..".png"
	-- 	asyncload_callback(filepath, img_role, function(filepath, texture)
	-- 		img_role:setTexture(filepath)
	-- 	end)

	-- local filepath2 = "image/"..(GameConst.WING_TEXTURE_START_ID+level)
	-- local wingImg2 = var.wingbg2:getChildByName("wingImg2")
	-- if not wingImg2 then
	-- 	wingImg2 = cc.Sprite:create():addTo(var.wingbg2):scale(0.6):setAnchorPoint(cc.p(0.5,0.5)):pos(40,50)
	-- 	wingImg2:setName("wingImg2")
	-- else
	-- 	wingImg2:stopAllActions()
	-- end
	-- local filelist2 = GameUtilSenior.getFilelist(filepath2, 2, 7, 5)
	-- GameUtilSenior.getAnimateByFileList(filelist2,wingImg2,0.15,function (anim)
	-- 	wingImg2:runAction(cca.repeatForever(anim))
	-- 	if GameUtilSenior.isObjectExist(var.wingbg2) then
	-- 		var.wingbg2.tag = level

	-- 		if var.levelupAction then
	-- 			var.levelupAction = false
	-- 			local animate = cc.AnimManager:getInstance():getBinAnimate(4,990017,0,true)
	-- 			if animate then
	-- 				local action = cc.Sprite:create()
	-- 					:addTo(var.wingbg2,2)
	-- 					:align(display.CENTER,-26,40)
	-- 					:setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
	-- 				action:runAction(
	-- 					cca.seq({
	-- 						animate,
	-- 						cca.removeSelf()
	-- 					})
	-- 				)
	-- 			end
	-- 		end
	-- 	end
	-- end)
end
--个人信息是每次推新增的，全服信息是每次推10条，所以更新全服信息时要把list的child全remove
function ContainerFly.Desp()
	local mParam = {
	name = GameMessageCode.EVENT_PANEL_ON_ALERT,
	panel = "tips", 
	infoTable = despTable,
	visible = true, 
	}
	GameSocket:dispatchEvent(mParam)

end


function ContainerFly.onPanelClose()
	var.curJie		= -1
	var.curXing		= -1
	var.levelupAction	= false
	var.act_flag =0
	var.isupgrade_ato=false
	var.btn_upgrade_ato:setTitleText("自动培养")
end

return ContainerFly
































-- ---------------------------------------------------------------------------
