local PanelZhuanPan = {}
local var = {}

function PanelZhuanPan.initView()
	var = {
		xmlPanel,
		isTen=false,
		curAngle=0,--当前指针所在的角度
		yuTimes=0,--剩余抽奖次数
	}
	-- var.xmlPanel = cc.XmlLayout:widgetFromXml("ui/layout/PanelZhuanPan/PanelZhuanPan.xml")
	var.xmlPanel = GUIAnalysis.load("ui/layout/PanelZhuanPan.uif")
	if var.xmlPanel then
		PanelZhuanPan.onPanelOpen()
		PanelZhuanPan.PanelClick()

		var.btn_ten = var.xmlPanel:getWidgetByName("btn_ten")
		var.btn_ten:addClickEventListener(function (sender)
			var.isTen = not var.isTen
			sender:loadTextureNormal( (var.isTen and "btn_checkbox_big_sel") or "btn_checkbox_big", ccui.TextureResType.plistType)
		end)

		PanelZhuanPan.addEffect()
	
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, PanelZhuanPan.handlePanelData)

			GameSocket:PushLuaTable("gui.PanelZhuanPan.handlePanelData",GameUtilSenior.encode({actionid = "getPanelData"}))
	end
	return var.xmlPanel
end

function PanelZhuanPan.PanelClick()
	local function prsBtnCall(sender)	
		GameSocket:PushLuaTable("gui.PanelZhuanPan.handlePanelData",GameUtilSenior.encode({actionid = "choujiang", param= var.isTen }))
		PanelZhuanPan.PointRotate()
		if var.yuTimes>0 then
			var.xmlPanel:getWidgetByName("btnGet"):setEnabled(false)
		end
	end
	local btnGet = var.xmlPanel:getWidgetByName("btnGet")
	GUIFocusPoint.addUIPoint(btnGet,prsBtnCall)
end

function PanelZhuanPan.onPanelOpen()
	-- local awardItem = var.xmlPanel:getWidgetByName("Img_gezi")
	-- local param={parent=awardItem , typeId=40000001,}
	-- GUIItem.getItem(param)
	
		
end

function PanelZhuanPan.handlePanelData(event)
	if event.type ~= "PanelZhuanPan" then return end
	local data=GameUtilSenior.decode(event.data)
	-- print(event.data)
	if data.cmd=="updateRecord" then
		if data.curWorldRecord then
			PanelZhuanPan.updateContent(data.curWorldRecord,"worldList",236,2,false,18, true)
		end
		var.xmlPanel:getWidgetByName("labYuTimes"):setString("剩余次数："..data.yuTimes.."次")
		var.yuTimes=data.yuTimes
	elseif data.cmd=="updateShowItems" then
		PanelZhuanPan.updateShowItems(data.dataTable)
	elseif data.cmd=="startRotate" then
		PanelZhuanPan.PointRotate(data.index)
	elseif data.cmd=="updateYuTimes" then
		var.xmlPanel:getWidgetByName("labYuTimes"):setString("剩余次数："..data.yuTimes.."次")
	end

end

--刷新转盘显示
function PanelZhuanPan.updateShowItems(data)
	if not data then return end
	for i=1,#data do
		local awardItem=var.xmlPanel:getWidgetByName("icon"..data[i].index)
		local param={parent=awardItem , typeId=data[i].id, num=1}
		GUIItem.getItem(param)
		var.xmlPanel:getWidgetByName("labNum"..i):setString(data[i].num)
	end
end
 
function PanelZhuanPan.updateContent(data,curScrollName,listsize,Margin,removeAll,tsize, action)
	local scroll = var.xmlPanel:getWidgetByName(curScrollName):setItemsMargin(Margin or 0):setClippingEnabled(true)
	scroll:setDirection(ccui.ScrollViewDir.vertical)
	scroll:setScrollBarEnabled(false)
	if removeAll then scroll:removeAllChildren() end
	for i=1, #data do
		local richWidget = GUIRichLabel.new({size=cc.size(listsize,30),space=2})
		local textsize = tsize or 18
		-- local tempInfo = GameUtilSenior.encode(data[i])
		richWidget:setRichLabel(data[i],30,textsize)
		richWidget:setVisible(true)
		--richWidget:setPositionX(30)
		scroll:pushBackCustomItem(richWidget)
		if #scroll:getItems()>30 then
			scroll:removeItem(0)
		end
	end

	if action then
		scroll:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.1),
			cc.CallFunc:create(function ()
					scroll:scrollToBottom(1,true)
				end)
			)
		)
	else
		scroll:scrollToBottom(0,true)
	end
end

function PanelZhuanPan.addEffect()
	for i=1,10 do
		local awardItem = var.xmlPanel:getWidgetByName("icon"..i)
		local effectSprite = cc.Sprite:create()
			:setAnchorPoint(cc.p(0.5,0))
			:setPosition(cc.p(25,-350))
			:addTo(awardItem)
			:setScale(1.2)
			:setLocalZOrder(10)
		--cc.AnimManager:getInstance():getPlistAnimateAsync(effectSprite,4, 65080, 4, 0, 5)
		GameUtilSenior.addEffect(effectSprite,"spriteEffect",GROUP_TYPE.EFFECT,65080,false,false,true)
		effectSprite:setBlendFunc({src=gl.SRC_ALPHA,dst=gl.ONE})
	end

end

-----------------------------------------------------旋转动画----------------------------------------------------------
function PanelZhuanPan.PointRotate(index)
	if not index or index<=0 then return end
	local boxPoint=var.xmlPanel:getWidgetByName("boxPoint")
	local needRotate = 36*index-18-var.curAngle
	var.curAngle=36*index-18

	if needRotate<=0 then needRotate=360+needRotate end

	local needTime = 0.01*(100*needRotate/270)

	-- print(needTime,needRotate)

	local function moveAct2(target)
		target:runAction(cca.seq({
			cc.EaseIn:create(cca.rotateBy(needTime,needRotate),needTime),  --135/270 --度数计算时间
			cca.cb(function ()
				target:stopAllActions()
				--结束后开始抽奖刷新记录+播放飞动画
				GameSocket:PushLuaTable("gui.PanelZhuanPan.handlePanelData",GameUtilSenior.encode({actionid = "rotateStop"}))
				var.xmlPanel:getWidgetByName("btnGet"):setEnabled(true)
			end),
		}))
	end

	local function moveAct(target)
		target:runAction(cca.seq({
			cca.rotateBy(0.3*4,360*4),
			cca.cb(function ()
				target:stopAllActions()
				moveAct2(target)
			end),
		}))
	end
	-- moveAct(iconFly)
	moveAct(boxPoint)
end



return PanelZhuanPan
