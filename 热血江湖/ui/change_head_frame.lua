-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_change_head_frame = i3k_class("wnd_change_head_frame", ui.wnd_base)

local LAYER_XGTXKT = "ui/widgets/xgtxkt"
local ACTIVITE_TYPE = 
{
	ORIGIN 		= 1,  --默认
	VIP_LEVEL 	= 2,  --vip等级激活
	ITEM_COUNT 	= 3,  --道具激活
}

local ACTIVITE_STATE = 
{
	ORIGIN 			= 1,  --默认
	HAVE_ACTIVITE 	= 2,  --已激活
	CAN_ACTIVITE 	= 3,  --可激活
	NOT_ACTIVITE 	= 4,  --未激活
	SELECTED        = 5,  --已选
}

local STATE_SORT = {
	[ACTIVITE_STATE.ORIGIN] = 3,
	[ACTIVITE_STATE.HAVE_ACTIVITE] = 4,
	[ACTIVITE_STATE.CAN_ACTIVITE] = 1,
	[ACTIVITE_STATE.NOT_ACTIVITE] = 5,
	[ACTIVITE_STATE.SELECTED] = 2,
}
function wnd_change_head_frame:ctor()
	self.frameTb = {}  		--头像框列表
	self.curFrameId = 0  	--当前头像框Id
	self.selectFrameId = 0  --当前选择的头像框Id
	self.unlockFrames = {}  --已解锁的头像框
end

function wnd_change_head_frame:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
	self.scroll = self._layout.vars.scroll
	self.save_btn = self._layout.vars.save_btn
	self._layout.vars.save_btn:onClick(self, self.onSaveFrameIcon)
end

function wnd_change_head_frame:refresh(unlockFrames)
	self.unlockFrames = unlockFrames
	self.curFrameId = g_i3k_game_context:GetRoleHeadFrameId()
	self:setFrameData()
end

function wnd_change_head_frame:setFrameData()
	self.frameTb = {}
	local bwType = g_i3k_game_context:GetTransformBWtype()
	for _, v in ipairs(i3k_db_head_frame) do
		if v.bwType == bwType then
			table.insert(self.frameTb, v)
		end
	end
	table.sort(self.frameTb, function(a, b)
		local state_a = self:getFrameState(a)
		local state_b = self:getFrameState(b)
		if STATE_SORT[state_a] == STATE_SORT[state_b] then
		return a.id < b.id
		else
			return STATE_SORT[state_a] < STATE_SORT[state_b]
		end
	end)

	self.scroll:removeAllChildren()
	for i, v in ipairs(self.frameTb) do
		local widget = require(LAYER_XGTXKT)()
		widget.vars.head_icon:hide()
		widget.vars.frame_icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.iconId))
		widget.vars.frame_btn:onClick(self, self.onFrameIcon, v)
		widget.vars.frame_btn:setTag(i)
		widget.vars.select_bg:setVisible(self.curFrameId == v.id)
		local state = self:getFrameState(v)
		local str = self:getFrameStateStr(state)
		widget.vars.condition:setText(str)
		local effect_time = self:getFrameEffectTime(v)
		widget.vars.effect_time:setText(effect_time)
		self.scroll:addItem(widget)
	end
end

--头像框状态
function wnd_change_head_frame:getFrameState(frame)
	if self.curFrameId == frame.id then
		return ACTIVITE_STATE.SELECTED
	else
		if frame.activate_type == ACTIVITE_TYPE.ORIGIN then
			return ACTIVITE_STATE.ORIGIN
		elseif frame.activate_type == ACTIVITE_TYPE.VIP_LEVEL then
			if self.unlockFrames[frame.id] then  --已激活
				return ACTIVITE_STATE.HAVE_ACTIVITE
			elseif g_i3k_game_context:GetVipLevel() >= frame.condition_1 then
				return ACTIVITE_STATE.CAN_ACTIVITE
			else
				return ACTIVITE_STATE.NOT_ACTIVITE
			end
		elseif frame.activate_type == ACTIVITE_TYPE.ITEM_COUNT then
			if self.unlockFrames[frame.id] then  --已激活
				return ACTIVITE_STATE.HAVE_ACTIVITE
			elseif g_i3k_game_context:GetCommonItemCanUseCount(frame.condition_1) >= frame.condition_2 then  --道具数量满足
				return ACTIVITE_STATE.CAN_ACTIVITE
			else
				return ACTIVITE_STATE.NOT_ACTIVITE
			end
		else
			return ACTIVITE_STATE.NOT_ACTIVITE
		end
	end
end

function wnd_change_head_frame:getFrameStateStr(state)
	if state == ACTIVITE_STATE.ORIGIN then
		return "默认"
	elseif state == ACTIVITE_STATE.HAVE_ACTIVITE then
		return "已启动"
	elseif state == ACTIVITE_STATE.CAN_ACTIVITE then
		return "可启动"
	elseif state == ACTIVITE_STATE.NOT_ACTIVITE then
		return "未启动"
	elseif state == ACTIVITE_STATE.SELECTED then
		return "已选"
	end
end

--头像框时效
function wnd_change_head_frame:getFrameEffectTime(frame)
	local str = ""
	if frame.effect_time > 0 then
		local end_time = self.unlockFrames[frame.id]
		if end_time then
			local cur_Time = i3k_game_get_time()
			local time = end_time - cur_Time
			local min = time/60%60
			local hour = time/3600%24
			local day = time/3600/24
			str = string.format("%d天%d时%d分",day,hour,min)
		end
	else
		str = "永久"
	end
	return str
end

function wnd_change_head_frame:onFrameIcon(sender, frame)
	self.selectFrameId = frame.id

	local index = sender:getTag()
	self:updateSelectBg(index)

	if frame.activate_type == ACTIVITE_TYPE.VIP_LEVEL then
		if g_i3k_game_context:GetVipLevel() < frame.condition_1 then
			g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(15567, frame.condition_1))
		else			
			if self:getFrameState(frame) == ACTIVITE_STATE.CAN_ACTIVITE then
				local callbackFun = function (ok)
					if ok then
						local callback = function ()
							i3k_sbean.syncPlayerFrameIcon()  --同步一下头像框界面
						end
						i3k_sbean.unlockPlayerFrameIcon(frame.id, callback, false)
					end
				end
				g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(15571), callbackFun)
			end
		end
	elseif frame.activate_type == ACTIVITE_TYPE.ITEM_COUNT then
		if not self.unlockFrames[frame.id] then  --未激活
			g_i3k_ui_mgr:OpenUI(eUIID_UnlockHead)
			g_i3k_ui_mgr:RefreshUI(eUIID_UnlockHead, frame.id, true)
		end
	end
end

function wnd_change_head_frame:updateSelectBg(index)
	local allChild = self.scroll:getAllChildren()
	for i, v in ipairs(allChild) do
		if i == index then
			v.vars.select_bg:show()
		else
			v.vars.select_bg:hide()
		end
	end
end

--保存头像框
function wnd_change_head_frame:onSaveFrameIcon(sender)
	local frame_id = self.selectFrameId
	local frame = {}
	for _, v in ipairs(i3k_db_head_frame) do
		if v.id == frame_id then
			frame = v
			break
		end
	end
	local state = self:getFrameState(frame)
	if state == ACTIVITE_STATE.CAN_ACTIVITE or state == ACTIVITE_STATE.NOT_ACTIVITE then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15568))
	elseif state == ACTIVITE_STATE.SELECTED or frame_id == self.curFrameId then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15569))
	end
	local callback = function ()
		i3k_sbean.syncPlayerFrameIcon()  --同步一下头像框界面
	end
	i3k_sbean.savePlayerFrameIcon(frame_id, callback)
end

function wnd_create(layout)
	local wnd = wnd_change_head_frame.new()
		wnd:create(layout)
	return wnd
end
