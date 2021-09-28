-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
--------------------------------------------------------

local STR_MASTER_DIRECT = 15393
local IMG_MSG_APPLY  = 3677  -- 拜师消息
local IMG_MSG_GRAD   = 3678  -- 出师消息
local IMG_MSG_BETRAY = 3679  -- 叛师消息
local IMG_ID_MASTER = 3680   -- 师傅图标
local IMG_ID_APPRTC = 3681   -- 徒弟图标

--------------------------------------------------------
-- 师徒关系主界面

----- 界面显示需要用到的其他页面
local LAYER_MEMBER = "ui/widgets/shitut"
local LAYER_MSG    = "ui/widgets/shitut2"

--------------------------------------------------------
master_shitu = i3k_class("master_shitu", ui.wnd_base)
function master_shitu:ctor()

end

function master_shitu:configure()
	local widgets = self._layout.vars

	self.tab_member  = widgets.members_tab
	self.layer_member = widgets.member_grid
	widgets.members_tab:onClick(self,self.onClickTabMember)

	self.tab_recruit = widgets.recruit_tab
	self.layer_recruit = widgets.recruit_grid
	widgets.recruit_tab:onClick(self,self.onClickTabRecruit)

	self.tab_msg     = widgets.msg_tab
	self.layer_msg   = widgets.msg_grid
	widgets.msg_tab:onClick(self,self.onClickTabMsg)

	widgets.close_btn:onClick(self,self.onCloseUI)

	---- 招募相关控件 ------
	widgets.direct_words:setText(i3k_db_string[STR_MASTER_DIRECT])
	widgets.cancelAnncBtn:onClick(self,self.onClickCancelAnnc)
	widgets.modifyAnncBtn:onClick(self,self.onClickModifyAnnc)
	self.announce = widgets.announce
	self.labelAnncBtn = widgets.AnncBtnTxt
	self.btnCancelAnnc = widgets.cancelAnncBtn

	-- 成员列表相关控件 --
	widgets.storeBtn:onClick(self,self.onClickMasterStore)
	widgets.activityBtn:onClick(self,self.onClickActivity)
	self.labelMultiFunc = widgets.labelMultiFunc
	self.scrollMembers = widgets.members_scroll
	self.txtReputation = widgets.txtReputation

	-- 消息相关控件 --
	self.scrollMsg = widgets.msg_scroll
	self.imgMsgRedDot = widgets.imgMsgRedDot
	widgets.friendNum2:setText(i3k_get_string(5028))

	widgets.helpBtn:onClick(self, self.onHelpBtn)
	widgets.masterCardBtn:onClick(self, self.onMasterCardBtn)
end

function master_shitu:refresh()
	--根据师徒关系状态刷新界面
	local widgets = self._layout.vars
	local state = g_i3k_game_context:GetMasterRelationState()
	if state==e_State_BeMaster_NoApptc then
		self:onClickTabRecruit()
		self:updateMemberUI()
		self:updateRecruitUI()
		self.labelMultiFunc:setText("查看活跃")
		self._layout.vars.multfuncBtn:onClick(self,self.onClickViewMemberActivity) -- 查看成员活跃
		widgets.masterCardBtn:hide()
	elseif state==e_State_Master then
		self:onClickTabMember()
		self:updateMemberUI()
		self:updateRecruitUI()
		self.labelMultiFunc:setText("查看活跃")
		self._layout.vars.multfuncBtn:onClick(self,self.onClickViewMemberActivity) -- 查看成员活跃
		widgets.masterCardBtn:show()
	elseif state==e_State_Apprtc then
		self:onClickTabMember()
		self:updateMemberUI()
		self.labelMultiFunc:setText("出师")
		self._layout.vars.multfuncBtn:onClick(self,self.onClickApplyGraduate) -- 申请出师
		widgets.recruit_tab:hide()
		widgets.msg_tab:hide()
		widgets.masterCardBtn:show()
	else
	    -- 这种情况应该不可能出现
		self:onCloseUI()
	end
end
function master_shitu:updateMasetrCardVisible()
	local widgets = self._layout.vars
	local state = g_i3k_game_context:GetMasterRelationState()
	if state==e_State_BeMaster_NoApptc then
		widgets.masterCardBtn:hide()
	elseif state==e_State_Master then
		widgets.masterCardBtn:show()
	elseif state==e_State_Apprtc then
		widgets.masterCardBtn:show()
	else
		widgets.masterCardBtn:hide()
	end
end

function wnd_create(layout)
	local wnd = master_shitu.new()
	wnd:create(layout)
	return wnd
end

-- 更新招募界面
function master_shitu:updateRecruitUI()
	if g_i3k_game_context:GetMasterAnnounce()==nil then
		self.announce:setText("(您还没有在平台发布收徒资讯)")
		self.labelAnncBtn:setText("发布宣言")
		self.btnCancelAnnc:hide()
	else
		self.announce:setText(g_i3k_game_context:GetMasterAnnounce())
		self.labelAnncBtn:setText("修改宣言")
		self.btnCancelAnnc:show()
	end
end

-- 更新成员列表界面
function master_shitu:updateMemberUI()
	local state = g_i3k_game_context:GetMasterRelationState()
	-- 先清空列表
	self.scrollMembers:removeAllChildren()
	local members = g_i3k_game_context:GetMasterMemberList()

	if state==e_State_Master or state==e_State_BeMaster_NoApptc  then
		self.txtReputation:show()
		self.txtReputation:setText( "良师值:" .. g_i3k_game_context:GetMasterReputation())
	else
		self.txtReputation:hide()
	end
	-- 只有已经成为师傅或者已经成为徒弟，才需要添加成员
	if members~=nil and (state==e_State_Master or state==e_State_Apprtc) then
		for i=1,#members do
			local m=members[i]
			local layer = require(LAYER_MEMBER)()
			if i==1 then
				layer.vars.imgMorA:setImage(g_i3k_db.i3k_db_get_icon_path(IMG_ID_MASTER))
			else
				layer.vars.imgMorA:setImage(g_i3k_db.i3k_db_get_icon_path(IMG_ID_APPRTC))
			end
			local hicon = g_i3k_db.i3k_db_get_head_icon_ex(m.role.headIcon,g_i3k_db.eHeadShapeQuadrate)
			if hicon and hicon > 0 then
				layer.vars.imgHeadIcon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
			end
			layer.vars.imgHeadBgrd:setImage(g_i3k_get_head_bg_path(m.role.bwType, m.role.headBorder))
			layer.vars.txtName:setText(m.role.name)
			layer.vars.imgCls:setImage( g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[m.role.type].classImg) )
			layer.vars.txtLevel:setText( "Lv. " .. m.role.level )
			layer.vars.txtPower:setText( "" .. m.role.fightPower )
			if m.online then
				layer.vars.txtOnline:setText("线上")
			else
				layer.vars.txtOnline:setText("离线")
			end
			layer.vars.txtPoint:setText("" .. m.point)
			if state==e_State_Master then
				layer.vars.btnDismiss:onClick(self,self.onClickMemberDismiss,m)
				layer.vars.txtDismiss:setText("除名")
			else
				layer.vars.btnDismiss:onClick(self,self.onClickMemberBetray,m)
				layer.vars.txtDismiss:setText("叛师")
			end
			if state==e_State_Apprtc then
				if m.role.id==g_i3k_game_context:GetMasterRoleId() then
					layer.vars.btnDismiss:show()
				else
					layer.vars.btnDismiss:hide()
				end
			elseif state==e_State_Master then
				if m.role.id==g_i3k_game_context:GetRoleId() then
					layer.vars.btnDismiss:hide()
				else
					layer.vars.btnDismiss:show()
				end
			end


			layer.vars.btnChat:onClick(self,self.onClickMemberChat,m)
			if m.role.id==g_i3k_game_context:GetRoleId() then
				layer.vars.btnChat:hide()
			end
			self.scrollMembers:addItem(layer)
		end
	end
end

-- 更新UI，徒弟叛师成功
function master_shitu:onApprtcBetraySuccess()
	self.scrollMembers:removeAllChildren()
	self._layout.vars.multfuncBtn:hide()
	self._layout.vars.activityBtn:hide()
end

	-- 获得“X天X小时X分钟”前
function master_shitu:getTimeDesc(elapse)
	local minute = 60
	local hour = 3600
	local day  = 86400
	if elapse>=day then
		return "" .. i3k_integer(elapse/day) .. "天前"
	elseif elapse>=hour then
		return "" .. i3k_integer(elapse/hour) .. "小时前"
	elseif elapse>=minute then
		return "" .. i3k_integer(elapse/minute) .. "分钟前"
	else
		return "1分钟前"
	end
end
-- 更新消息界面
function master_shitu:updateMasterMsgUI()
	self.scrollMsg:removeAllChildren()
	local msgCount = 0
	local msgs = g_i3k_game_context:GetMasterMsgList()
	g_i3k_game_context:checkClearMasterMessageRedPoint()
	local now = i3k_game_get_time()
	now = i3k_integer(now)
	--出师消息
	if msgs.graduateReqList~=nil then
		local c=#msgs.graduateReqList
		msgCount = msgCount+c
		for i=1,c do
			local m=msgs.graduateReqList[i]
			local r=m.overView
			local layer=require(LAYER_MSG)()
			layer.vars.imgMsgType:setImage(g_i3k_db.i3k_db_get_icon_path(IMG_MSG_GRAD))
			local hicon = g_i3k_db.i3k_db_get_head_icon_ex(r.headIcon,g_i3k_db.eHeadShapeQuadrate)
			if hicon and hicon > 0 then
				layer.vars.imgHeadIcon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
			end
			layer.vars.imgHeadBgrd:setImage(g_i3k_get_head_bg_path(r.bwType, r.headBorder))
			layer.vars.txtName:setText(r.name)
			layer.vars.imgCls:setImage( g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[r.type].classImg) )
			layer.vars.txtLevel:setText( "Lv. " .. r.level )
			layer.vars.btn01:onClick(self,self.onClickGradMsgDisagree,{idx=i,msg=m})
			layer.vars.txtBtn01:setText("拒绝")
			layer.vars.btn02:onClick(self,self.onClickGradMsgAgree,{idx=i,msg=m})
			layer.vars.txtBtn02:setText("同意")
			layer.vars.txtTime:setText(self:getTimeDesc(now-m.applyTime))
			self.scrollMsg:addItem(layer)
		end
	end
	--叛师消息
	if msgs.betrayList~=nil then
		local c=#msgs.betrayList
		msgCount = msgCount+c
		for i=1,c do
			local m=msgs.betrayList[i]
			local r=m.overView
			local layer=require(LAYER_MSG)()
			layer.vars.imgMsgType:setImage(g_i3k_db.i3k_db_get_icon_path(IMG_MSG_BETRAY))
			local hicon = g_i3k_db.i3k_db_get_head_icon_ex(r.headIcon,g_i3k_db.eHeadShapeQuadrate)
			if hicon and hicon > 0 then
				layer.vars.imgHeadIcon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
			end
			layer.vars.imgHeadBgrd:setImage(g_i3k_get_head_bg_path(r.bwType, r.headBorder))
			layer.vars.txtName:setText(r.name)
			layer.vars.imgCls:setImage( g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[r.type].classImg) )
			layer.vars.txtLevel:setText( "Lv. " .. r.level )
			layer.vars.btn01:hide()
			layer.vars.txtBtn01:setText("")
			layer.vars.btn02:onClick(self,self.onClickBetrayMsg,{idx=i,msg=m})
			layer.vars.txtBtn02:setText("知道了")
			layer.vars.txtTime:setText(self:getTimeDesc(now-m.applyTime))
			self.scrollMsg:addItem(layer)
		end
	end
	--拜师消息
	if msgs.applyList~=nil then
		local c=#msgs.applyList
		msgCount = msgCount+c
		for i=1,c do
			local m=msgs.applyList[i]
			local r=m.overView
			local layer=require(LAYER_MSG)()
			layer.vars.imgMsgType:setImage(g_i3k_db.i3k_db_get_icon_path(IMG_MSG_APPLY))
			local hicon = g_i3k_db.i3k_db_get_head_icon_ex(r.headIcon,g_i3k_db.eHeadShapeQuadrate)
			if hicon and hicon > 0 then
				layer.vars.imgHeadIcon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
			end
			layer.vars.imgHeadBgrd:setImage(g_i3k_get_head_bg_path(r.bwType, r.headBorder))
			layer.vars.txtName:setText(r.name)
			layer.vars.imgCls:setImage( g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[r.type].classImg) )
			layer.vars.txtLevel:setText( "Lv. " .. r.level )
			layer.vars.btn01:onClick(self,self.onClickApplyMsgDisagree,{idx=i,msg=m})
			layer.vars.txtBtn01:setText("拒绝")
			layer.vars.btn02:onClick(self,self.onClickApplyMsgAgree,{idx=i,msg=m})
			layer.vars.txtBtn02:setText("同意")
			layer.vars.txtTime:setText(self:getTimeDesc(now-m.applyTime))
			self.scrollMsg:addItem(layer)
		end
	end
	--更新红点
	if msgCount>0 then
		self.imgMsgRedDot:show()
	else
		self.imgMsgRedDot:hide()
	end
end

-----------------------------------------------

function master_shitu:onClickTabMember()
	self.tab_member:stateToPressed()
	self.layer_member:show()

	self.tab_recruit:stateToNormal()
	self.layer_recruit:hide()

	self.tab_msg:stateToNormal()
	self.layer_msg:hide()
end

function master_shitu:onClickTabRecruit()
	self.tab_member:stateToNormal()
	self.layer_member:hide()

	self.tab_recruit:stateToPressed()
	self.layer_recruit:show()

	self.tab_msg:stateToNormal()
	self.layer_msg:hide()
end

function master_shitu:onClickTabMsg()
	self.tab_member:stateToNormal()
	self.layer_member:hide()

	self.tab_recruit:stateToNormal()
	self.layer_recruit:hide()

	self.tab_msg:stateToPressed()
	self.layer_msg:show()
end
----------- 招募相关响应函数 ------------
function master_shitu:onClickCancelAnnc()
	i3k_sbean.master_cancel_recruit()
end

function master_shitu:onClickModifyAnnc()
	g_i3k_ui_mgr:OpenUI(eUIID_Master_modifyAnnc)
	g_i3k_ui_mgr:RefreshUI(eUIID_Master_modifyAnnc)
end
  --修改界面显示
function master_shitu:modifyAnnounce(ann)
	if self.announce==nil then
		return
	end
	self.announce:setText(ann)
	self:updateRecruitUI()
end

-------- 成员列表响应函数 ----------
	-- 师徒商店
function master_shitu:onClickMasterStore()
	i3k_sbean.master_send_store_sync()
end
	-- 师徒活动
function master_shitu:onClickActivity()
	local tips = g_i3k_game_context:GetNotEnterTips() or g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		return g_i3k_ui_mgr:PopupTipMessage(tips)
	end
	local members = g_i3k_game_context:GetMasterMemberList()
	if not members or #members == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5035))
		return
	end
	self:onCloseUI()
	g_i3k_logic:OpenDungeonUI(true, -1, DUNGEON_DIFF_MASTER)
	
end
	-- 申请出师
function master_shitu:onClickApplyGraduate()
	g_i3k_ui_mgr:OpenUI(eUIID_Master_chushi)
	g_i3k_ui_mgr:RefreshUI(eUIID_Master_chushi)
end
	-- 查看成员活跃
function master_shitu:onClickViewMemberActivity()
	g_i3k_ui_mgr:OpenUI(eUIID_Master_apprtcActv)
	g_i3k_ui_mgr:RefreshUI(eUIID_Master_apprtcActv)
end
	-- 成员列表，师傅开除徒弟按钮, m is {role=m.overView, online=m.online, point=m.point}
function master_shitu:onClickMemberDismiss(sender,m)
	local desc = "确定与'" .. m.role.name .. "解除师徒关系吗？"
	local callback = function(bOK)
		if bOK then
			i3k_sbean.master_mstr_dismiss(m.role.id)
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
end
	-- 成员列表，徒弟叛师按钮, m is {role=m.overView, online=m.online, point=m.point}
function master_shitu:onClickMemberBetray(sender,m)
	local desc = "确定与'" .. m.role.name .. "解除师徒关系吗？"
	local callback = function(bOK)
		if bOK then
			i3k_sbean.master_apprtc_betray()
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
end
	-- 成员列表，私聊按钮, m is {role=m.overView, online=m.online, point=m.point}
function master_shitu:onClickMemberChat(sender,m)
	local player = {}
	player.name = m.role.name
	player.id = m.role.id
	player.level = m.role.level
	player.iconId = m.role.headIcon
	player.bwType = m.role.bwType

	g_i3k_ui_mgr:OpenUI(eUIID_PriviteChat)
	g_i3k_ui_mgr:RefreshUI(eUIID_PriviteChat, player)
	g_i3k_ui_mgr:CloseUI(eUIID_Master_shitu)
end

function master_shitu:onHelpBtn(sender)
	local msg = i3k_get_string(5037)
	g_i3k_ui_mgr:ShowHelp(msg)
end

------ 消息列表响应函数
	-- 拒绝出师，{idx-index of the msg, msg-message}
function master_shitu:onClickGradMsgDisagree(sender,args)
	-- 发送协议
	i3k_sbean.master_agree_apprtc_grad(args.msg.overView.id,false)
	-- 删除消息
	local msginfo = g_i3k_game_context:GetMasterMsgList()
	if msginfo.betrayList~=nil then
		table.remove(msginfo.graduateReqList,args.idx)
		self:updateMasterMsgUI()
	end
end
	-- 同意出师，{idx-index of the msg, msg-message}
function master_shitu:onClickGradMsgAgree(sender,args)
	-- 发送协议
	i3k_sbean.master_agree_apprtc_grad(args.msg.overView.id,true)
	-- 删除消息
	local msginfo = g_i3k_game_context:GetMasterMsgList()
	if msginfo.betrayList~=nil then
		table.remove(msginfo.graduateReqList,args.idx)
		self:updateMasterMsgUI()
	end
end
	-- 叛师消息，{idx-index of the msg, msg-message}
function master_shitu:onClickBetrayMsg(sender,args)
	-- 发送协议
	i3k_sbean.master_remove_betray_msg(args.msg.overView.id)
	-- 删除消息
	local msginfo = g_i3k_game_context:GetMasterMsgList()
	if msginfo.betrayList~=nil then
		table.remove(msginfo.betrayList,args.idx)
		self:updateMasterMsgUI()
	end
end
	-- 拜师消息，拒绝，{idx-index of the msg, msg-message}
function master_shitu:onClickApplyMsgDisagree(sender,args)
	i3k_sbean.master_response_apply(args.msg.overView.id,false,"MSGLIST_UI")
	--删除消息
	local msginfo = g_i3k_game_context:GetMasterMsgList()
	if msginfo.applyList~=nil then
		table.remove(msginfo.applyList,args.idx)
		self:updateMasterMsgUI()
	end
end
	-- 拜师消息，同意，{idx-index of the msg, msg-message}
function master_shitu:onClickApplyMsgAgree(sender,args)
	i3k_sbean.master_response_apply(args.msg.overView.id,true,"MSGLIST_UI")
	--删除消息
	local msginfo = g_i3k_game_context:GetMasterMsgList()
	if msginfo.applyList~=nil then
		table.remove(msginfo.applyList,args.idx)
		self:updateMasterMsgUI()
	end
end
function master_shitu:onMasterCardBtn(sender)
	local members = g_i3k_game_context:GetMasterMemberList()
	if members[1] then
		i3k_sbean.master_card_sync(members[1].role.id)
	end
end
