-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

--------------------------------------------------------
-- 徒弟出师申请界面

local LAYER_COND = "ui/widgets/chushit"
local LAYER_NUM  = "ui/widgets/chushit2"

local IMG_SUCC = 3602
local IMG_FAIL = 3603
local IMG_COND_DONE = 3701
local IMG_COND_ZERO = 3700

local IMG_NUM = { [0]=3690,[1]=3691,[2]=3692,[3]=3693,[4]=3694,[5]=3695,[6]=3696,[7]=3697,[8]=3698,[9]=3699 } -- 显示分数的数字图片


--------------------------------------------------------
master_chushi = i3k_class("master_chushi", ui.wnd_base)

function master_chushi:ctor()
end

function master_chushi:configure()
	local widgets = self._layout.vars
	widgets.btnClose:onClick(self,self.onCloseUI)
	self.scroll_conds = widgets.scrollConds
	self.scroll_score = widgets.scrollScore
	self.rewards = { }
	-- 0 --
	local rwd0 = { }
	rwd0.root    = widgets.rwd0
	rwd0.btnRwd  = widgets.btnRwd0
	rwd0.imgRwd  = widgets.imgRwd0
	rwd0.txtNum  = widgets.txtRwd0Num
	rwd0.imgLock = widgets.imgLock0
	table.insert(self.rewards,rwd0)
	-- 1 --
	local rwd1 = { }
	rwd1.root    = widgets.rwd1
	rwd1.btnRwd  = widgets.btnRwd1
	rwd1.imgRwd  = widgets.imgRwd1
	rwd1.txtNum  = widgets.txtRwd1Num
	rwd1.imgLock = widgets.imgLock1
	table.insert(self.rewards,rwd1)
	-- 2 --
	local rwd2 = { }
	rwd2.root    = widgets.rwd2
	rwd2.btnRwd  = widgets.btnRwd2
	rwd2.imgRwd  = widgets.imgRwd2
	rwd2.txtNum  = widgets.txtRwd2Num
	rwd2.imgLock = widgets.imgLock2
	table.insert(self.rewards,rwd2)
	-- 3 --
	local rwd3 = { }
	rwd3.root    = widgets.rwd3
	rwd3.btnRwd  = widgets.btnRwd3
	rwd3.imgRwd  = widgets.imgRwd3
	rwd3.txtNum  = widgets.txtRwd3Num
	rwd3.imgLock = widgets.imgLock3
	table.insert(self.rewards,rwd3)


	-- 申请出师按钮
	widgets.btnApplyGrad:onClick(self,self.onClickApplyGrad)
	self.btnApplyGrad = widgets.btnApplyGrad
	self.txtGradDesc = widgets.txtGradDesc

end

function master_chushi:refresh()
	local cfg = i3k_db.i3k_db_master_cfg
	local minScore = cfg.grad_apptc_rwd[1].score
	self.txtGradDesc:setText( i3k_get_string(5025,minScore) )

	-- 发送协议查询完成情况
	i3k_sbean.master_require_grad_progress()
	self.btnApplyGrad:disableWithChildren()

end

function wnd_create(layout)
	local wnd = master_chushi.new()
	wnd:create(layout)
	return wnd
end
-----------------------------------------------------
	-- 更新UI, data is list(i3k_sbean.DBMasterTask)
function master_chushi:updateUI(data)
	local score = 0
	local minScore = i3k_db.i3k_db_master_cfg.grad_apptc_rwd[1].score
	local progress = { }

	-- 不足完成列表
	local db_conds = i3k_db.i3k_db_master_cfg.grad_conds
	for k,v in ipairs(db_conds) do
		progress[k]=0
	end
	if data~=nil then
		for i=1,#data do
			local prog = data[i]
			progress[prog.taskType]=prog.taskProgress
		end
	end
	-- 显示完成进度
	self.scroll_conds:removeAllChildren()
	for k,v in ipairs(db_conds) do
		local prog = progress[k]
		local layer=require(LAYER_COND)()

		layer.vars.txtDescpt:setText(v.desc)
		layer.vars.txtProgress:setText("" .. prog .. "/" .. v.target .. "")
		layer.vars.txtScore:setText( "" .. v.score .. "分")
		layer.vars.progCond:setPercent(prog/v.target * 100)
		if prog>=v.target then
			score = score+v.score
			layer.vars.imgSuccess:setImage( g_i3k_db.i3k_db_get_icon_path(IMG_SUCC) )
			layer.vars.imgScore:setImage( g_i3k_db.i3k_db_get_icon_path(IMG_COND_DONE) )
		else
			layer.vars.imgSuccess:setImage( g_i3k_db.i3k_db_get_icon_path(IMG_FAIL) )
			layer.vars.imgScore:setImage( g_i3k_db.i3k_db_get_icon_path(IMG_COND_ZERO) )
		end
		self.scroll_conds:addItem(layer)
	end
	-- 显示分数
	if score>999 then
		score = 999 --最多显示3位
	end
	local tmpScore = score
	local vNum = { }
	while (tmpScore>=10)
	do
		table.insert(vNum,1,i3k_integer(tmpScore%10))
		tmpScore = i3k_integer(tmpScore/10)
	end
	table.insert(vNum,1,i3k_integer(tmpScore%10))
	self.scroll_score:removeAllChildren()
	for i=1,#vNum do
		local layer=require(LAYER_NUM)()
		layer.vars.imgNum:setImage( g_i3k_db.i3k_db_get_icon_path(IMG_NUM[vNum[i]]) )
		self.scroll_score:addItem(layer)
	end
	--更新出师按钮状态
	if score>=minScore then
		self.btnApplyGrad:enableWithChildren()
	else
		self.btnApplyGrad:disableWithChildren()
	end
	--根据完成进度，显示奖励
	local rwds = i3k_db.i3k_db_master_cfg.grad_apptc_rwd
	local reward = nil
		-- 策划要求小于最小分值，显示最差一档奖励
	local vscore = score
	if vscore<minScore then
		vscore = minScore
	end
	for k,v in ipairs(rwds) do
		if vscore>=v.score then
			reward = v.rwd
		end
	end
	for i=1,4 do
		self.rewards[i].root:hide()
	end
	if reward~=nil then
		for i=1,#reward do
			local r=reward[i]
			local item=self.rewards[i]
			item.root:show()
			item.root:setImage( g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(r.id) )
			item.imgRwd:setImage( g_i3k_db.i3k_db_get_common_item_icon_path(r.id,i3k_game_context:IsFemaleRole()) )
			item.txtNum:setText( "x" .. r.num )
			if r.id > 0 then
				item.imgLock:show()
			else
				item.imgLock:hide()
			end
			item.btnRwd:onClick(self, self.onClickItem, r.id)
		end
	end

end
-----------------------------------------------------
-- 点击奖励物品的图标
function master_chushi:onClickItem(sender, itemId)
	--TODO 显示物品详情
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

-- 点击申请出师按钮
function master_chushi:onClickApplyGrad()
	-- 判断出师条件：等级、冷却
	if g_i3k_game_context:IsApprtcApplyGradCooling() then
		g_i3k_ui_mgr:PopupTipMessage("您已经发出过出师申请了，请耐心等待师傅批准，再次申请冷却期为" .. i3k_integer(g_i3k_db.i3k_db_master_cfg.cfg.apply_grad_cooltime/3600) .. "小时。" )
		return
	end
	local gradLevel = g_i3k_db.i3k_db_master_cfg.cfg.apptc_max_lvl + 1
	if g_i3k_game_context:GetLevel()<g_i3k_db.i3k_db_master_cfg.cfg.apptc_max_lvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5036, gradLevel))
		return
	end
	--
	local desc = i3k_get_string(5026)
	local callback = function(bOK)
		if bOK then
			--发送出师申请协议
			i3k_sbean.master_apprtc_apply_grad()
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
end
