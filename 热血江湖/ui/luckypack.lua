
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_luckyPack = i3k_class("wnd_luckyPack",ui.wnd_base)

local BagMaxLvl = #i3k_db_lucky_pack_reward
local PackLevel = 5  --目前福袋档数
local LAYER_XINNIANFUDAIT = "ui/widgets/xinnianfudait"
local LAYER_XINNIANFUDAIT2 = "ui/widgets/xinnianfudait2"

function wnd_luckyPack:ctor()
	self._info = {}
	self._uiType = g_TYPE_PRE
end

function wnd_luckyPack:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)

	self.ui = widgets
	self.root = 
	{
		[g_TYPE_PRE] = widgets.preUI,
		[g_TYPE_VALID] = widgets.validUI,
		[g_TYPE_END] = widgets.endUI,
	}
end

function wnd_luckyPack:refresh(info)
	local uiType = g_i3k_db.i3k_db_get_lucky_pack_ui_type()
	self._uiType = uiType
	for _, v in pairs(self.root) do
		v:hide()
	end
	self._info = info

	self.root[uiType]:show()
	self:updateUI(uiType)
end

function wnd_luckyPack:updateUI(uiType)
	if uiType == g_TYPE_VALID then
		self:updateValidUI()
	elseif uiType == g_TYPE_END then
		self:updateEndUI()
	else
		self:updatePreUI()
	end
end

function wnd_luckyPack:updatePreUI()
	self.ui.desScroll:removeAllChildren()
	g_i3k_ui_mgr:AddTask(self, {}, function(ui)
		local item = require(LAYER_XINNIANFUDAIT2)()
		item.vars.des:setText(i3k_get_string(16992))
		self.ui.desScroll:addItem(item)
		g_i3k_ui_mgr:AddTask(self, {item}, function(ui)
			local textUI = item.vars.des
			local size = item.rootVar:getContentSize()
			local height = textUI:getInnerSize().height
			local width = size.width
			height = size.height > height and size.height or height
			item.rootVar:changeSizeInScroll(self.ui.desScroll, width, height, true)
		end, 1)
	end, 1)

	self.ui.tips1:setText("此活动尚未开启")
	for i = 1, PackLevel do
		self.ui["bagIcon" .. i]:hide()
	end
	for i, v in ipairs(i3k_db_lucky_pack_reward) do
		self.ui["bagBtn" .. i]:onClick(self, self.onShowPackInfo, i)
		self.ui["bagIcon" .. i]:setImage(g_i3k_db.i3k_db_get_icon_path(v.bagIcon))
		self.ui["bagIcon" .. i]:show()
	end
end

function wnd_luckyPack:updateValidUI()
	local curPack = self._info.curPack
	local cfg = i3k_db_lucky_pack_reward[curPack]

	self.ui.bagName:setText(string.format("福袋名称：%s", cfg.bagName))
	self.ui.bagIconVal:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.bagIcon))
	self.ui.bagBtnVal:onClick(self, self.onShowPackInfo, curPack)
	self.ui.openBtn1:onClick(self, self.onOpenPack, curPack)
	if self._info.reward == 1 then
		self.ui.openBtn1:disableWithChildren()
	end

	self:updateTaskProgress(self._info.dayTask)
	self.ui.helpBtn:onClick(self, function()
		g_i3k_ui_mgr:OpenUI(eUIID_RedPacketHelp)
		g_i3k_ui_mgr:RefreshUI(eUIID_RedPacketHelp, i3k_get_string(16992), "福袋说明")
	end)

	local nextBagId = curPack + 1 <= BagMaxLvl and curPack + 1 or BagMaxLvl
	local nextCfg = i3k_db_lucky_pack_reward[nextBagId]

	local curScore = self._info.score
	local needScore = nextCfg.needScore

	self.ui.expbar:setPercent(curScore/needScore*100)
	self.ui.expbarCount:setText(string.format("%s/%s", curScore, needScore))
	self.ui.score:setText(string.format("当前积分：%s", curScore))

	local nowPackId = g_i3k_game_context:GetNowPackID()
	if nowPackId and curPack - nowPackId > 0 then
		self:playUpAni()
		g_i3k_game_context:SetNowPackID(curPack)
	end
end

function wnd_luckyPack:updateTaskProgress(dayTask)
	self.ui.scroll:removeAllChildren()
	local task = {}
	for _, v in ipairs(dayTask) do
		task[v.id] = v.value
	end
	for i, v in ipairs(i3k_db_lucky_pack_task) do
		local item = require(LAYER_XINNIANFUDAIT)()
		item.vars.txtDescpt:setText(v.desc)
		item.vars.txtScore:setText(string.format("%s积分", v.score))
		item.vars.imgSuccess:setVisible(not task[i])  --任务完成显示对勾
		self.ui.scroll:addItem(item)
	end
end

-- 福袋升级动画
function wnd_luckyPack:playUpAni()
	--play()
end

function wnd_luckyPack:updateEndUI()
	local curPack = self._info.curPack
	local cfg = i3k_db_lucky_pack_reward[curPack]
	self.ui.des3:setText(i3k_get_string(16999))
	self.ui.bagIconEnd:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.bagIcon))
	self.ui.bagBtnEnd:onClick(self, self.onShowPackInfo, curPack)
	self.ui.openBtn2:onClick(self, self.onOpenPack, curPack)
	if self._info.reward == 1 then
		self.ui.openBtn2:disableWithChildren()
	end
end

function wnd_luckyPack:onOpenPack(sender, curPack)
	local desc = (curPack == BagMaxLvl or self._uiType == g_TYPE_END) and i3k_get_string(16990, i3k_db_lucky_pack_reward[curPack].bagName) or i3k_get_string(16989)
	local callback  = function(ok)
		if ok then
			local bagSize = g_i3k_game_context:GetBagSize()
			local useCell = g_i3k_game_context:GetBagUseCell()
			if bagSize - useCell >= i3k_db_lucky_pack_reward[curPack].needSpace then
				local callback = function()
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_LuckyPack, "refeshBtnState")
				end
				i3k_sbean.new_year_pack_take(curPack, callback)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16372))
			end
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
end

function wnd_luckyPack:refeshBtnState()
	self.ui.openBtn1:disableWithChildren()
	self.ui.openBtn2:disableWithChildren()
end

function wnd_luckyPack:onShowPackInfo(sender, curPack)
	g_i3k_ui_mgr:OpenUI(eUIID_LuckyPackTip)
	g_i3k_ui_mgr:RefreshUI(eUIID_LuckyPackTip, curPack)
end

function wnd_create(layout, ...)
	local wnd = wnd_luckyPack.new()
	wnd:create(layout, ...)
	return wnd;
end

