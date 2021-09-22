local ContainerGroupApply={}
local var = {}

local jobNames = {GameConst.str_zs, GameConst.str_fs, GameConst.str_ds}
local headName = {{"new_main_ui_head.png","head_mfs","head_mds"},{"head_fzs","head_ffs","head_fds"}}
local titleimgs = {
	["tip_friend"] = "img_title_friendapply",
	["tip_group"] = "img_title_groupapply",
}
function ContainerGroupApply.initView()
	var = {
		xmlPanel,
		key = "tip_group"
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerGroup_apply.uif");
	if var.xmlPanel then
		--GameUtilSenior.asyncload(var.xmlPanel,"panelBg", "ui/image/img_apply_bg.png")
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_SHOW_BOTTOM, ContainerGroupApply.newGroupApply)
			
			
		ContainerGroupApply.updateGameMoney()
		var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab(1)
		var.xmlPanel:getWidgetByName("box_tab"):addTabEventListener(ContainerGroupApply.pushTabButtons)
		
	end
	return var.xmlPanel
end

function ContainerGroupApply.pushTabButtons(sender)
	local opened, level, funcName
	opened = true
	local tag = sender:getTag()
	--if tag == 2 then
	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="main_group",tab=tag})
	--end
end

--金币刷新函数
function ContainerGroupApply:updateGameMoney()
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

function ContainerGroupApply.onPanelOpen(event)
	if event and event.key then
		var.key = event.key
	end
	if titleimgs[var.key] then
		--var.xmlPanel:getWidgetByName("Image_1"):loadTexture(titleimgs[var.key], ccui.TextureResType.plistType)
		ContainerGroupApply.initAppilList(var.key)
	end
	if var.key == "tip_group" then
		ContainerGroupApply.inviteGroupArrs()
	end
	if extend and extend.tab and GameUtilSenior.isNumber(extend.tab) then
		var.tabh:setSelectedTab(extend.tab)
	end
end

function ContainerGroupApply.onPanelClose()
	GameSocket.tipsMsg[var.key] = {}
end

function ContainerGroupApply.newGroupApply(event)
	if event and event.str==var.key then
		ContainerGroupApply.initAppilList(var.key)
	end
end

--取邀请组队或者是申请的数据
function ContainerGroupApply.inviteGroupArrs()
	local listData = GameSocket.tipsMsg["tip_group"]
	local flag--标记是申请(apply)还是邀请(invite)
	if #listData>0 then
		local endData = listData[#listData]
		print(GameUtilSenior.encode(endData))
		flag=endData.msgType
	end
	local result_apply = {}
	local result_invite = {}
	for i=1,#listData do
		local itemData = listData[i]
		itemData.index=i
		if itemData.msgType=="apply" then
			table.insert(result_apply,itemData)
		else
			table.insert(result_invite,itemData)
		end
	end
	if flag=="apply" then
		--var.xmlPanel:getWidgetByName("Image_1"):loadTexture("img_title_groupapply", ccui.TextureResType.plistType)
		return result_apply
	elseif flag=="invite" then
		--var.xmlPanel:getWidgetByName("Image_1"):loadTexture("title_zdyq", ccui.TextureResType.plistType)
		return result_invite
	end
	return {}
end

--初始化申请列表
function ContainerGroupApply.initAppilList(key)
	local listDataAll = GameSocket.tipsMsg[key] or {}
	if not listDataAll then listDataAll={} end
	local listData={}
	if key=="tip_group" then
		listData=ContainerGroupApply.inviteGroupArrs()
	else
		listData=listDataAll
	end
	local function updateApplyList(item)
		local itemData = listData[item.tag]
		item:getWidgetByName("labName"):setString(itemData.name)
		item:getWidgetByName("labJob"):setString(jobNames[itemData.job-99])
		item:getWidgetByName("labLevel"):setString("Lv."..itemData.level)
		if itemData.gender then
			item:getWidgetByName("head"):loadTexture(headName[itemData.gender-199][itemData.job-99],ccui.TextureResType.plistType):setScale(0.8)
		end
		item:getWidgetByName("btnOk"):addClickEventListener(function(sender)
			if key == "tip_group" then
				if itemData.group_id then
					GameSocket:AgreeInviteGroup(itemData.name, itemData.group_id)
				else
					GameSocket:AgreeJoinGroup(itemData.name)
				end
				ContainerGroupApply.removeCurData(listDataAll,itemData.index)
			elseif key == "tip_friend" then
				GameSocket:FriendApplyAgree(itemData.name,1)
				ContainerGroupApply.removeCurData(listData,item.tag)
			end
			
		end)
		item:getWidgetByName("btnNo"):addClickEventListener(function(sender)
			if key =="tip_group" then
				if itemData.group_id then
					GameSocket:PrivateChat(itemData.name, "["..GameCharacter._mainAvatar:NetAttr(GameConst.net_name).."]的组队邀请被拒绝")
				else
					GameSocket:PrivateChat(itemData.name, "["..GameCharacter._mainAvatar:NetAttr(GameConst.net_name).."]队长拒绝了您的入队申请")
				end
				ContainerGroupApply.removeCurData(listDataAll,itemData.index)
			elseif key =="tip_friend" then
				GameSocket:FriendApplyAgree(itemData.name,0)
				ContainerGroupApply.removeCurData(listData,item.tag)
			end
			
		end)
	end
	local listApply = var.xmlPanel:getWidgetByName("listApply")
	listApply:reloadData(#listData,updateApplyList)
end

--操作后移除本条消息
function ContainerGroupApply.removeCurData(listData,index)
	table.remove(GameSocket.tipsMsg[var.key],index)
	ContainerGroupApply.initAppilList()
	if #listData==0 then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL,str = "panel_groupapply"})
	end
end

return ContainerGroupApply