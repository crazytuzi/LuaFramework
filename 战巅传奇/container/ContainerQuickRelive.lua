local ContainerQuickRelive = {}
local this = {
	["close"] = function() GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "panel_relive"}); end,
	["relive"] = function(str) GameSocket:PushLuaTable("gui.ContainerQuickRelive.onPanelData",GameUtilSenior.encode({ actionid = str})); end
}
local var = {}
function ContainerQuickRelive.initView(event)
	print("sfsafasf")
	var = {
		xmlPanel,
	}
	local extend = event.mParam;
	local remainTimes=extend.time
	local reliveflag=extend.reliveflag
	
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerQuickRelive.uif");
	-- GameUtilSenior.asyncload(var.xmlPanel, "tipsbg", "ui/image/prompt_bg.png")

	local lblRemainTime = var.xmlPanel:getWidgetByName("time")
	if var.xmlPanel then
		if G_SwitchEffect < 1 then
			-- local gender = GameCharacter._mainAvatar:NetAttr(GameConst.net_gender)
			-- if gender == GameConst.SEX_MALE then
			-- 	GameMusic.play(GameConst.SOUND.die_male)
			-- else
			-- 	GameMusic.play(GameConst.SOUND.die_female)
			-- end
		end

		local function addOnlineTime()
			remainTimes = remainTimes - 1
			if remainTimes > 0 then
				lblRemainTime:setString(remainTimes.."秒");
			elseif reliveflag==100 then 
				
				lblRemainTime:stopAllActions()
				this.relive("relivelocal_nouse")
				this.close()
			else
				lblRemainTime:stopAllActions()
				this.relive("reliveback")
				this.close()
			end
		end
		local btn_local = var.xmlPanel:getWidgetByName("btn_local");
		local btn_back = var.xmlPanel:getWidgetByName("btn_back");
		local label_2 = var.xmlPanel:getWidgetByName("label_2");
		local label_enemy = var.xmlPanel:getWidgetByName("label_enemy")
		label_enemy:setString(extend.enemy);
		label_2:setPositionX(label_enemy:getContentSize().width)
		var.xmlPanel:getWidgetByName("labXy"):setString("坐标: "..extend.map.." "..extend.x..","..extend.y);
		if extend.btnName2 and #extend.btnName2>0 then
			btn_local:setTitleText(extend.btnName2):setPositionX(300):show()
			btn_back:setTitleText(extend.btnName1):setPositionX(112):show()
		else
			btn_local:setTitleText(extend.btnName2):hide()
			btn_back:setTitleText(extend.btnName1):setPositionX(206):show()
		end
		if extend.freeTimes > 0 then
			var.xmlPanel:getWidgetByName("label_relive_first"):setString("免费");
			var.xmlPanel:getWidgetByName("label_relive_second"):setString(extend.freeTimes);
			var.xmlPanel:getWidgetByName("label_relive_third"):setString("次");
		else
			var.xmlPanel:getWidgetByName("label_relive_first"):setString("消耗");
			var.xmlPanel:getWidgetByName("label_relive_second"):setString(extend.needVcoin);
			var.xmlPanel:getWidgetByName("label_relive_third"):setString("元宝");
		end

		btn_back:setTouchEnabled(true);
		btn_back:addClickEventListener(function (pSender)
			this.relive("reliveback")
			this.close()
		end);
		btn_local:setTouchEnabled(true);
		local enable = extend.freeTimes > 0 or GameSocket.mCharacter.mVCoin >= extend.needVcoin
		-- if enable then
			btn_local:loadTextures("btn_new2","btn_new2","", ccui.TextureResType.plistType)
			btn_local:setTitleColor(GameBaseLogic.getColor(0xF1E8D0))
		-- else
		-- 	btn_local:loadTextures("btn_new_no","btn_new_no","", ccui.TextureResType.plistType)
			-- btn_local:setTitleColor(GameBaseLogic.getColor(0x857e70))
		-- end
		-- btn_local:setTitleColor(GameBaseLogic.getColor(enable and 0xF1E8D0 or 0x857e70))
		btn_local:addClickEventListener(function (pSender)
			if enable then
				this.relive("relivelocal")
				this.close()
			else
				-- GameSocket:alertLocalMsg("元宝不足！", "alert")
				if PLATFORM_BANSHU then
					local param = {
						name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "很抱歉,您元宝不足", btnConfirm = "确定",btnCancel ="取消",
						confirmCallBack = function ()
							this.relive("reliveback")
							this.close()
						end
					}
					GameSocket:dispatchEvent(param)
				else
					GameSocket:PushLuaTable("server.showChongzhi","check")
					-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS, str = "createGuild"})
					-- if GameSocket:getServerParam(19)>0 then
					-- 	local param = {
					-- 		name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "很抱歉,您元宝不足", btnConfirm = "充值",btnCancel ="取消",
					-- 		confirmCallBack = function ()
					-- 			-- GameSocket:PushLuaTable("server.showChongzhi","")
					-- 			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str = "panel_charge"})
					-- 		end
					-- 	}
					-- 	GameSocket:dispatchEvent(param)
					-- else

					-- end
				end
			end
		end);

		lblRemainTime:stopAllActions()
		lblRemainTime:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(addOnlineTime)})))
		addOnlineTime()
		return var.xmlPanel
	end
end

return ContainerQuickRelive