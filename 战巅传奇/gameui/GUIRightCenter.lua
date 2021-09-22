local GUIRightCenter={}

local topBtnList = {
					{res="menu_container_btn_friend",func="main_friend",tab=0},
					{res="menu_container_btn_guild",func="main_guild",tab=0},
					--{res="menu_container_btn_mail",func="main_mail99",tab=0},
					{res="menu_container_btn_skill",func="main_skill",tab=8},
					{res="menu_container_btn_group",func="main_group",tab=0},
					--{res="menu_container_btn_tujian",func="V8_ContainerTuJian",tab=0},
					{res="menu_container_btn_xingzuo",func="panel_constellation",tab=0},
					{res="menu_container_btn_exchange",func="V8_ContainerXianShiJiangLi",tab=6},
					}
local centerBtnList = {
					--{res="menu_container_btn_shenlu",func="V11_ContainerHeCheng",tab=0},              --神炉
					{res="menu_container_btn_shenlu",npcTalk=2000003},              --神炉
					--{res="chengjiu",func="main_achieve",tab=0},  --成就
					--{res="btn_main_rank",func="btn_main_rank",tab=0},
					--{res="icon_bosspintu_tubiao",func="main_puzzle",tab=0},  -BOSS拼图
					{res="menu_container_btn_qianghua",func="main_forge",tab=0},          --强化
					--{res="menu_container_btn_wing",func="btn_main_wing",tab=0},  --翅膀
					--{res="menu_container_btn_v10_1",npcTalk="1000032"},     --称号
					--{res="guanwei",func="main_official",tab=0},            --官位
					--{res="hecheng",func="main_compose",tab=0},             --合成
					--{res="btn_main_convert",func="main_convert",tab=0},    --积分装备
					--{res="shenlu",func="main_furnace",tab=0},              --神炉
					--{res="icon_youjian_tubiao",func="main_mail",tab=0},     --邮件
					--{res="icon_jishou_tubiao",func="main_consign",tab=0},   --寄售
					--{res="menu_container_btn_title",func="container_title",tab=0},
					--{res="menu_container_btn_hunhuan",func="container_hunhuan",tab=0},
					--{res="extend_dice",func="extend_dice",tab=0},  --摇摇乐
					--{res="extend_exploit",func="extend_exploit",tab=0},
					--{res="menu_container_btn_zuji",func="container_zuji",tab=0},
					--{res="menu_container_btn_wash",func="container_equip_wash",tab=0},  --元素洗炼
					--{res="menu_container_btn_fojing",func="panel_fojing",tab=0},
					--{res="menu_container_btn_jianqiao",func="panel_jianqiao",tab=0},
					--{res="extend_shenqi",func="V9_ContainerShenQi",tab=1},
					--{res="extend_moqi",func="V9_ContainerShenQi",tab=2},
					--{res="extend_guiqi",func="V9_ContainerShenQi",tab=3},
					--{res="extend_breakup",func="extend_breakup",tab=0},
					{res="menu_container_btn_v10_7",npcTalk="1000008"},
					--{res="menu_container_btn_v10_3",npcTalk="1000007"},  --星座锻造
					--{res="menu_container_btn_v10_4",npcTalk="1000010"},  --体力恢复
					--{res="menu_container_btn_v10_5",npcTalk="1000005"},  --巧夺天工
					--{res="menu_container_btn_v10_6",npcTalk="1000006"},  --秒杀勋章
					--{res="menu_container_btn_v10_8",npcTalk="1000004"},   --攻速盾牌
					--{res="menu_container_btn_v10_9",npcTalk="1000031"},   --符文晋升
					--{res="menu_container_btn_v10_10",npcTalk="1000011"},  --血炼
					--{res="menu_container_btn_v10_11",npcTalk="1000012"},   --神力
					--{res="menu_container_btn_fojing",npcTalk="1000146"},  --佛经
					--{res="menu_container_btn_jianqiao",npcTalk="1000147"},   --剑鞘
					{res="extend_xianshijiangli",func="V8_ContainerXianShiJiangLi",tab=2},  --首杀奖励
					--{res="menu_container_btn_shiwuduihuan",func="v4_panel_ShiWuDuiHuan",tab=0},   --实物兑换
					--{res="menu_container_btn_toushi",func="V8_ContainerXianShiJiangLi",tab=7},  --透视
					{res="menu_container_btn_v10_12",npcTalk="1000017"},  --货币整理
					--{res="btn_main_consign",func="main_consign",tab=1},   --市场
					{res="btn_main_consign",npcTalk=2000016},   --市场
					}
local bottomBtnList = {
					{res="menu_container_btn_character",func="main_avatar",tab=1},
					--{res="menu_container_btn_bag",func="menu_bag",tab=0},
					{res="menu_container_btn_rank",func="btn_main_rank",tab=0},
					{res="menu_container_btn_setting",func="menu_setting",tab=0},
					}

function GUIRightCenter.init_ui(rightcenter)

	if not rightcenter then return end

	var = {
		rightcenter,
		npcNetId,
		npcNetName,
		npcNetX,
		npcNetY,
	}
	
	var.rightcenter = rightcenter:align(display.RIGHT_TOP, display.width, 0)
	
	var.rightcenter:getWidgetByName("box_container"):setPositionX(465)
	
	GUIFocusPoint.addUIPoint(var.rightcenter:getWidgetByName("btn_bag"), function (sender)
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = 'menu_bag'})
	end)
	
	GUIFocusPoint.addUIPoint(var.rightcenter:getWidgetByName("btn_container_switch"), function (sender)
		var.rightcenter:getWidgetByName("box_container"):runAction(cca.seq({
			cca.moveTo(0.2, 0, var.rightcenter:getWidgetByName("box_container"):getPositionY())
		}))
	end)
	GUIFocusPoint.addUIPoint(var.rightcenter:getWidgetByName("close_btn"), function (sender)
		var.rightcenter:getWidgetByName("box_container"):runAction(cca.seq({
			cca.moveTo(0.2, 465, var.rightcenter:getWidgetByName("box_container"):getPositionY())
		}))
	end)
	var.rightcenter:getWidgetByName("npc_name_bg"):setTouchEnabled(true)
	GUIFocusPoint.addUIPoint(var.rightcenter:getWidgetByName("npc_name_bg"), function (sender)
		GameSocket:NpcTalk(var.npcNetId,"100")
		--GameCharacter._targetNPCName = var.npcNetName
		--GameCharacter.startAutoMoveToMap(GameCharacter._curMap,var.npcNetX,var.npcNetY,1)
	end)
	var.rightcenter:getWidgetByName("npc_name"):setTouchEnabled(true)
	GUIFocusPoint.addUIPoint(var.rightcenter:getWidgetByName("npc_name"), function (sender)
		GameSocket:NpcTalk(var.npcNetId,"100")
		--GameCharacter._targetNPCName = var.npcNetName
		--GameCharacter.startAutoMoveToMap(GameCharacter._curMap,var.npcNetX,var.npcNetY,1)
	end)
	
	local function onTouchBegan(touch,event)
		-- print("GDivControl onTouchBegan")
		return true
	end

	local function onTouchMoved(touch, event)
		-- print("GDivControl onTouchMoved")
	end

	local function onTouchEnded(touch, event)
		-- print("GDivControl onTouchEnded")
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SCREEN_TOUCHED})
	end
	
	var.rightcenter:getWidgetByName("menu_container_bg"):setTouchEnabled(true)
	local eventDispatcher = var.rightcenter:getWidgetByName("menu_container_bg"):getEventDispatcher()
	local _touchListener = cc.EventListenerTouchOneByOne:create()
	_touchListener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	_touchListener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	_touchListener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	_touchListener:setSwallowTouches(false)
	eventDispatcher:addEventListenerWithSceneGraphPriority(_touchListener, var.rightcenter:getWidgetByName("menu_container_bg"))

	cc.EventProxy.new(GameSocket,rightcenter)
		:addEventListener(GameMessageCode.EVENT_BAG_UNFULL, GUIRightCenter.showBagFull)
		:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, GUIRightCenter.handlePanelData)
		:addEventListener(GameMessageCode.EVENT_EXTEND_VISIBLE, function (event)
			if event.lock =="unlock" then
				var.lock = false
			end
			if not var.lock then
				if not event.visible then
					--handleExtendVisible(false)
				else
					--handleExtendVisible(var.extVisible)
				end
			else
				if not event.visible then
					--handleExtendVisible(false)
				end
			end
			if event.lock =="lock" then
				var.lock = true
			end
		end)
		
	GUIRightCenter.initTopBtnList()
	GUIRightCenter.initCenterBtnList()
	GUIRightCenter.initBottomBtnList()
	GUIRightCenter.showTaskContent({"<font size=16>这是标题</font>","<font size=13>这是一个完整内容</font>"})
end

function GUIRightCenter.showNpcName(mNpc,PixesMainAvatar)
	if mNpc then
		local x=math.abs(mNpc:NetAttr(GameConst.net_x)-PixesMainAvatar:NetAttr(GameConst.net_x))
		local y=math.abs(mNpc:NetAttr(GameConst.net_y)-PixesMainAvatar:NetAttr(GameConst.net_y))
		if x<3 and y<3 then
			if not var.rightcenter:getWidgetByName("npc_name_bg"):isVisible() then
				var.rightcenter:getWidgetByName("npc_name_bg"):setVisible(true)
				var.rightcenter:getWidgetByName("npc_name_bg"):runAction(
					cca.seq({
						cca.moveTo(0.5, -255, 300)
					})
				)
			end
			var.rightcenter:getWidgetByName("npc_name"):setString(mNpc:NetAttr(GameConst.net_name));
			var.npcNetId=mNpc:NetAttr(GameConst.net_id)
			--var.npcNetName=mNpc:NetAttr(GameConst.net_name)
			--var.npcNetX=mNpc:NetAttr(GameConst.net_x)
			--var.npcNetY=mNpc:NetAttr(GameConst.net_y)
		else
			if var.rightcenter:getWidgetByName("npc_name_bg"):isVisible() then
				var.rightcenter:getWidgetByName("npc_name_bg"):runAction(
					cca.seq({
						cca.moveTo(0.5, 0, 300),
						cca.callFunc(function ()
								var.rightcenter:getWidgetByName("npc_name_bg"):setVisible(false)
							end
						)
					})
				)
			end
		end
	else
		if var.rightcenter:getWidgetByName("npc_name_bg"):isVisible() then
			var.rightcenter:getWidgetByName("npc_name_bg"):runAction(
				cca.seq({
					cca.moveTo(0.5, 0, 398),
					cca.callFunc(function ()
							var.rightcenter:getWidgetByName("npc_name_bg"):setVisible(false)
						end
					)
				})
			)
		end
	end
end

function GUIRightCenter.initTopBtnList()
	var.rightcenter:getWidgetByName("top_container_list"):reloadData(#topBtnList, GUIRightCenter.updateTopBtnList)
end
function GUIRightCenter.initCenterBtnList()
	var.rightcenter:getWidgetByName("center_container_list"):reloadData(#centerBtnList, GUIRightCenter.updateCenterBtnList)
end
function GUIRightCenter.initBottomBtnList()
	var.rightcenter:getWidgetByName("bottom_container_list"):reloadData(#bottomBtnList, GUIRightCenter.updateBottomBtnList)
end


function GUIRightCenter.updateTopBtnList(item)
	GUIRightCenter.updateBtn(item,topBtnList)
end

function GUIRightCenter.updateCenterBtnList(item)
	GUIRightCenter.updateBtn(item,centerBtnList)
end

function GUIRightCenter.updateBottomBtnList(item)
	GUIRightCenter.updateBtn(item,bottomBtnList)
end

function GUIRightCenter.updateBtn(item,listData)
	local tag = item.tag
	local btn = item:getChildByName("btn")
	btn:loadTexture(listData[tag].res,ccui.TextureResType.plistType)
	if not item:getChildByName(listData[tag].res) then
		local redPoint = ccui.Layout:create()
		redPoint:setName(listData[tag].res)
		redPoint:setContentSize(cc.size(70,70)):setPosition(0,0):setAnchorPoint(cc.p(0,0))
		redPoint:addTo(btn)
	end
	item:setTouchEnabled(true):addClickEventListener(function( sender )
		sender:getChildByName("btn"):setScale(1.1)
		
		local function startShowBtnAnimal()
			sender:stopAllActions()
			sender:getChildByName("btn"):setScale(1)
		end
		sender:stopAllActions()
		sender:runAction(cca.repeatForever(cca.seq({cca.delay(0.1),cca.cb(startShowBtnAnimal)}),2))
		
		var.rightcenter:getWidgetByName("box_container"):runAction(cca.seq({
			cca.moveTo(0.2, 465, var.rightcenter:getWidgetByName("box_container"):getPositionY())
		}))

		if listData[tag].npcTalk then
			GameSocket:NpcTalk(listData[tag].npcTalk,"100")
		else
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = listData[tag].func,tab=listData[tag].tab,index=listData[tag].tab})
		end
		--sender:setScale(1)
	end)
end

function GUIRightCenter.update()
	if not var.rightcenter then return end
end

function GUIRightCenter.handlePanelData(event)
	local data = GameUtilSenior.decode(event.data)
	if event.type=="changeQiangHuaLev" then
		GameBaseLogic.setQiangHuaTable(data)
	elseif event.type=="server_start_day" then
		GameSocket.severDay = data.dayNum
	end
end

--显示背包是否已满
function GUIRightCenter.showBagFull(event)
	local btnMainBag = var.rightcenter:getWidgetByName("btn_bag")
	btnMainBag:getWidgetByName("img_bag_full"):setVisible(event.vis or false)
	local redPoint = btnMainBag:getChildByName("redPoint")
	if not redPoint then return end
	redPoint:setVisible(not event.vis)
end

--封神塔任务框
function GUIRightCenter.showTaskContent(str)
	GUIRightCenter.updateList( var.rightcenter:getWidgetByName("mini_task_name"),str )
	var.rightcenter:getWidgetByName("mini_task_name_bg"):runAction(
		cca.seq({
			cca.moveTo(0.5, -400, 315),
			cca.callFunc(function ()
					--var.rightcenter:getWidgetByName("mini_task_name_bg"):setVisible(false)
				end
			)
		})
	)
end


function GUIRightCenter.updateList( list,strs )
	local t = {}
	if GameUtilSenior.isString(strs) then
		table.insert(t,strs)
	elseif GameUtilSenior.isTable(strs) then
		t = strs
	end
	list:removeAllItems()
	for i,v in ipairs(t) do
		local richLabel = GUIRichLabel.new({size = cc.size(list:getContentSize().width, 40), space=3,name = "hintMsg"..i})
		richLabel:setRichLabel(v,"panel_npctalk")
		list:pushBackCustomItem(richLabel)
	end
end

return GUIRightCenter