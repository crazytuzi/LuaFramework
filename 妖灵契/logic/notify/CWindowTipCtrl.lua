local CWindowTipCtrl = class("CWindowTipCtrl")

function CWindowTipCtrl.ctor(self)
	
end

function CWindowTipCtrl.ResetCtrl(self)
	self.m_TodayMark = nil
end

function CWindowTipCtrl.SetWindowCommitItem(self, sessionidx, taskid)
	CTaskCommitItemView:ShowView(function (oView)
		local task = g_TaskCtrl:GetTaskById(taskid)
		oView:SetContent(task, sessionidx)
	end)
end

-- args = {widget-widget对位锚点, side-side对位, offset-v2偏移量}
function CWindowTipCtrl.SetWindowItemTip(self, itemid, args)
	CWindowItemTipView:ShowView(function (oView)
		oView:SetWindowItemTipInfo(itemid)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(0, 10)
		UITools.NearTarget(args.widget, oView.m_TipWidget, args.side, args.offset, true)
	end)
end

function CWindowTipCtrl.SetWindowEquipEffectTipInfo(self, iEffectId, args)
	CWindowEquipEffectTipView:ShowView(function (oView)
		oView:SetWindowEffectTipInfo(iEffectId)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(0, 10)
		UITools.NearTarget(args.widget, oView.m_TipWidget, args.side, args.offset, true)
	end)
end

function CWindowTipCtrl.SetWindowInstructionInfo(self, content)
	CWindowInstructionView:ShowView(function (oView)
		oView:SetWindowInstructionInfo(content)
	end)
end






----------------------N1------------------------

--弹出物品的基本信息
--tItem 物品信息
--args 配置键盘的配置规则
function CWindowTipCtrl.SetWindowItemTipsBaseItemInfo(self, tItem, args)
	CItemTipsBaseInfoView:ShowView(function (oView)
		oView:SetContent(CItemTipsBaseInfoView.enum.BaseInfo, tItem)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(0, 10)
		args.openView = args.openView or nil
		args.hideMaskWidget = args.hideMaskWidget or false
		if args.hideMaskWidget then
			oView:SetMaskWidget(false)
		end
		oView:SetOwnerView(args.openView)
		--UITools.NearTarget(args.widget, part.m_TipWidget, args.side, args.offset)		
	end)
end

--弹出物品的简单信息
--sid 物品sid
--args 配置规则
--伙伴id
--额外参数
function CWindowTipCtrl.SetWindowItemTipsSimpleItemInfo(self, sid, args, pairId, config)
	local oView = CItemTipsSimpleInfoView:GetView()
	if oView then
		oView:SetOwnerView(args.openView)
		oView:SetInitBox(sid, pairId, config)
		oView.m_ExtendClose = false					--如果该画面本来存在的时候，则第一次打开，跳过 ExtendCloseView 关闭界面
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(120, 5)
		args.openView = args.openView or nil
		if args.behindStrike ~= nil then
			oView.m_BehindStrike = args.behindStrike
		else
			oView.m_BehindStrike = true
		end
		if args.openView then
			args.openView:SetChildView(oView)
		end	
		UITools.NearTarget(args.widget, oView.m_Container, args.side, args.offset, true)		
	else
		CItemTipsSimpleInfoView:ShowView(function (oView)
			oView:SetOwnerView(args.openView)
			oView:SetInitBox(sid, pairId, config)			
			args = args or {}
			args.widget = args.widget or oView
			args.side = args.side or enum.UIAnchor.Side.Top
			args.offset = args.offset or Vector2.New(120, 5)
			args.openView = args.openView or nil
			if args.behindStrike ~= nil then
				oView.m_BehindStrike = args.behindStrike
			else
				oView.m_BehindStrike = true
			end
			if args.openView then
				args.openView:SetChildView(oView)
			end		
			UITools.NearTarget(args.widget, oView.m_Container, args.side, args.offset, true)		
		end)
	end
end

--弹出物品的出售信息
--tItem 物品信息
--args 配置键盘的配置规则
function CWindowTipCtrl.SetWindowItemTipsSellItemInfo(self, tItem, args)
	CItemTipsBaseInfoView:ShowView(function (oView)
		oView:SetContent(CItemTipsBaseInfoView.enum.SellInfo, tItem)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(0, 10)
		args.openView = args.openView or nil
		oView:SetOwnerView(args.openView)
		--UITools.NearTarget(args.widget, part.m_TipWidget, args.side, args.offset)		
	end)
end

--弹出装备的基本信息
--tItem 装备信息
--args 配置键盘的配置规则
function CWindowTipCtrl.SetWindowItemTipsEquipItemInfo(self, tItem, args)
	CItemTipsMainView:ShowView(function (oView)
	args = args or {}	
	args.isLink = args.isLink or false
	oView:ShowEquipItemInfo(tItem, args.isLink)
	args.widget = args.widget or oView
	args.side = args.side or enum.UIAnchor.Side.Top
	args.offset = args.offset or Vector2.New(0, 10)
	args.openView = args.openView or nil
	oView:SetOpenView(args.openView)	
	--UITools.NearTarget(args.widget, part.m_TipWidget, args.side, args.offset)
	end)
end

--弹出伙伴装备的基本信息
--tItem 装备信息
--args 配置键盘的配置规则
function CWindowTipCtrl.SetWindowItemTipsPartnerEquipInfo(self, tItem, args)
	CItemTipsMainView:ShowView(function (oView)
		oView:ShowParEquipInfo(tItem, args)
		oView:SetOpenView(args.openView)
		if args.widget then
			UITools.NearTarget(args.widget, oView.m_PartnerSoulInfoPage.m_BG, args.side, args.offset)
		end
	end)
end

--弹出御灵信息
function CWindowTipCtrl.SetWindowItemTipsPartnerSoulInfo(self, tItem, args)
	CItemTipsMainView:ShowView(function (oView)
		oView:ShowPartnerSoulInfo(tItem, args)
		oView:SetOpenView(args.openView)
		if args.widget then
			UITools.NearTarget(args.widget, oView.m_ParEquipInfoPage.m_BG, args.side, args.offset)
		end
	end)
end

--args 弹出伙伴技能的基本信息
function CWindowTipCtrl.SetWindowPartnerSKillInfo(self, skid, level, isawake)
	CItemTipsMainView:ShowView(function (oView)
	oView:ShowPartnerSkillInfo(skid, level, isawake)
	end)
end

--弹出伙伴的基本介绍
--partnerId 伙伴id
--args 配置键盘的配置规则
function CWindowTipCtrl.SetWindowPartnerInfo(self, partnerId, args)
	local oView = CItemTipsPartnerView:GetView()
	if oView then
		oView:SetContent(partnerId)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(120, 5)
		args.openView = args.openView or nil			
		if args.openView then
			args.openView:SetChildView(oView)
		end		
		UITools.NearTarget(args.widget, oView.m_BgSprite, args.side, args.offset, true)		
	else
		CItemTipsPartnerView:ShowView(function (oView)
			oView:SetContent(partnerId)
			args = args or {}
			args.widget = args.widget or oView
			args.side = args.side or enum.UIAnchor.Side.Top
			args.offset = args.offset or Vector2.New(120, 5)
			args.openView = args.openView or nil
			if args.openView then
				args.openView:SetChildView(oView)
			end		
			UITools.NearTarget(args.widget, oView.m_BgSprite, args.side, args.offset, true)		
		end)		
	end
end

--弹出伙伴皮肤的基本介绍
--args 配置键盘的配置规则
function CWindowTipCtrl.SetWindowPartnerSkinInfo(self, itemID, args)
	local oView = CItemTipsSkinView:GetView()
	if oView then
		oView:SetPartnerSkin(itemID)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(120, 5)
		args.openView = args.openView or nil
		if args.openView then
			args.openView:SetChildView(oView)
		end		
		UITools.NearTarget(args.widget, oView.m_Container, args.side, args.offset, true)		
	else
		CItemTipsSkinView:ShowView(function (oView)
			oView:SetPartnerSkin(itemID)
			args = args or {}
			args.widget = args.widget or oView
			args.side = args.side or enum.UIAnchor.Side.Top
			args.offset = args.offset or Vector2.New(120, 5)
			args.openView = args.openView or nil
			if args.openView then
				args.openView:SetChildView(oView)
			end		
			UITools.NearTarget(args.widget, oView.m_Container, args.side, args.offset, true)		
		end)
	end
end

--弹出主角皮肤的基本介绍
--args 配置键盘的配置规则
function CWindowTipCtrl.SetWindowRoleSkinInfo(self, itemID, args)
	local oView = CItemTipsSkinView:GetView()
	if oView then
		oView:SetRoleSkin(itemID)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(120, 5)
		args.openView = args.openView or nil
		if args.openView then
			args.openView:SetChildView(oView)
		end		
		UITools.NearTarget(args.widget, oView.m_Container, args.side, args.offset, true)		
	else
		CItemTipsSkinView:ShowView(function (oView)
			oView:SetRoleSkin(itemID)
			args = args or {}
			args.widget = args.widget or oView
			args.side = args.side or enum.UIAnchor.Side.Top
			args.offset = args.offset or Vector2.New(120, 5)
			args.openView = args.openView or nil
			if args.openView then
				args.openView:SetChildView(oView)
			end		
			UITools.NearTarget(args.widget, oView.m_Container, args.side, args.offset, true)		
		end)
	end
end

--弹出宅邸伙伴的基本介绍
--house_partnerId 伙伴id
--args 配置键盘的配置规则
function CWindowTipCtrl.SetWindowHousePartnerInfo(self, partnerId, args)
	local oView = CItemTipsHousePartnerView:GetView()
	if oView then
		oView:SetContent(partnerId)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(120, 5)
		args.openView = args.openView or nil			
		if args.openView then
			args.openView:SetChildView(oView)
		end		
		UITools.NearTarget(args.widget, oView.m_BgSprite, args.side, args.offset, true)		
	else
		CItemTipsHousePartnerView:ShowView(function (oView)
			oView:SetContent(partnerId)
			args = args or {}
			args.widget = args.widget or oView
			args.side = args.side or enum.UIAnchor.Side.Top
			args.offset = args.offset or Vector2.New(120, 5)
			args.openView = args.openView or nil
			if args.openView then
				args.openView:SetChildView(oView)
			end		
			UITools.NearTarget(args.widget, oView.m_BgSprite, args.side, args.offset, true)		
		end)		
	end
end

function CWindowTipCtrl.SetTitleSimpleInfoTips(self, titleID, args)
	CTitleSimpleInfoView:ShowView(function (oView)
		oView:SetData(titleID)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(120, 5)
		UITools.NearTarget(args.widget, oView.m_BgSprite, args.side, args.offset, true)		
	end)
end

--弹出装备的更换界面
--tItem 装备信息
--args 配置的适配规则
function CWindowTipCtrl.SetWindowItemTipsEquipItemChange(self, tItem, args)
	CItemTipsAttrEquipChangeView:ShowView(function (oView)
		args = args or {}
		args.equipList = args.equipList			--可换装备列表
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(0, 10)
		args.openView = args.openView or nil
		if args.showCenterMaskWidget == nil then
			args.showCenterMaskWidget = false
		end
		oView:SetData(tItem, args.equipList, CItemTipsEquipChangeView.enum.ChangeInfo, args.showCenterMaskWidget)
		oView:SetOwnerView(args.openView)
		--UITools.NearTarget(args.widget, part.m_TipWidget, args.side, args.offset)
	end)
end

--弹出装备的出售界面
--tItem 装备信息
--args 配置的适配规则
function CWindowTipCtrl.SetWindowItemTipsEquipItemSell(self, tItem, args)
	CItemTipsAttrEquipChangeView:ShowView(function (oView)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(0, 10)
		args.openView = args.openView or nil
		if args.showCenterMaskWidget == nil then
			args.showCenterMaskWidget = false
		end
		oView:SetData(tItem, args.equipList, CItemTipsEquipChangeView.enum.SellInfo, args.showCenterMaskWidget)
		oView:SetOwnerView(args.openView)
		--UITools.NearTarget(args.widget, part.m_TipWidget, args.side, args.offset)
	end)
end

--args 弹出伙伴技能的基本信息
function CWindowTipCtrl.SetWindowAwakeItemInfo(self, info)
	CItemTipsMainView:ShowView(function (oView)
		oView:ShowAwakeItemInfo(info)
	end)
end

--弹出基本确认框
-- {msg-s信息,
-- title-s标题,
-- okCallback-fun确认回调,
-- cancelCallback-fun取消回调, 
-- pivot-Pivot信息对齐, 
-- okStr-s确定按钮文字, 
-- cancelStr-s取消按钮文字
-- cb 画面创建回调函数 
function CWindowTipCtrl.SetWindowConfirm(self, args, cb)
	local windowTipInfo = {
		msg				= args.msg or "-----",
		title			= args.title or "提示",
		okCallback		= args.okCallback,
		cancelCallback	= args.cancelCallback,
		thirdCallback	= args.thirdCallback,
		closeCallback = args.closeCallback,
		pivot			= args.pivot or enum.UIWidget.Pivot.Left,
		okStr			= args.okStr or "确认",
		cancelStr		= args.cancelStr or "取消",
		thirdStr		= args.thirdStr or "",
		forceConfirm 	= args.forceConfirm or false,
		countdown       = args.countdown or 0,
		default         = args.default or 0,
		hideOk 			= args.hideOk or false,
		hideCancel		= args.hideCancel or false,
		simpleRole 	    = args.simpleRole or {},
		uiType 			= args.uiType or CItemTipsConfirmWindowView.UIType.default,
		autoSelectOnDestroy	= args.autoSelectOnDestroy or false,
		showClose		= args.showClose or false,
		selectdata		= args.selectdata,
		alignment		= args.alignment or enum.UILabel.Alignment.Center,
		noCancelCbTouchOut = args.noCancelCbTouchOut or false,
		msgBBCode = args.msgBBCode or false,
		point = args.point,
	}
	CItemTipsConfirmWindowView:ShowView(function (oView)
		if windowTipInfo.forceConfirm then
			oView.m_ExtendClose = "Shelter"
			oView:ExtendClose()
		end
		oView.m_ThirdBtn:SetActive(windowTipInfo.thirdStr ~= "" and windowTipInfo.thirdCallback ~= nil)
		oView.m_CloseBtn:SetActive(windowTipInfo.closeCallback ~= nil)
		oView.m_OKBtn:SetActive(not windowTipInfo.hideOk)
		oView.m_CancelBtn:SetActive(not windowTipInfo.hideCancel)
		oView.m_BtnGrid:Reposition()	

		oView:SetWindowConfirm(windowTipInfo)

		if cb then
			cb(oView)
		end
	end)
end

--弹出基本确认框
-- {msg-s信息,
-- title-s标题,
-- okCallback-fun确认回调,
-- cancelCallback-fun取消回调, 
-- pivot-Pivot信息对齐, 
-- okStr-s确定按钮文字, 
-- cancelStr-s取消按钮文字
-- cb 画面创建回调函数 
function CWindowTipCtrl.SetTeamInviteConfirm(self, args, cb)
	local windowTipInfo = {
		msg				= args.msg or "-----",
		title			= args.title or "提示",
		okCallback		= args.okCallback,
		cancelCallback	= args.cancelCallback,
		thirdCallback	= args.thirdCallback,
		closeCallback = args.closeCallback,
		pivot			= args.pivot or enum.UIWidget.Pivot.Left,
		okStr			= args.okStr or "确认",
		cancelStr		= args.cancelStr or "取消",
		thirdStr		= args.thirdStr or "",
		forceConfirm 	= args.forceConfirm or false,
		countdown       = args.countdown or 0,
		default         = args.default or 0,
		hideOk 			= args.hideOk or false,
		hideCancel		= args.hideCancel or false,
		simpleRole 	    = args.simpleRole or {},
		uiType 			= args.uiType or CItemTipsConfirmWindowView.UIType.default,
		autoSelectOnDestroy	= args.autoSelectOnDestroy or false,
		showClose		= args.showClose or false,
		selectdata		= args.selectdata,
		confirmtype	 	= args.confirmtype,
		relation		= args.relation,
		point = args.point,
	}
	CItemTipsTeamInviteConfirmView:ShowView(function (oView)
		if windowTipInfo.forceConfirm then
			oView.m_ExtendClose = "Shelter"
		end

		if windowTipInfo.closeCallback == nil then
			oView.m_CloseBtn:SetActive(false)
		else
			oView.m_CloseBtn:SetActive(true)
		end
		oView.m_OKBtn:SetActive(not windowTipInfo.hideOk)
		oView.m_CancelBtn:SetActive(not windowTipInfo.hideCancel)
		oView:SetWindowConfirm(windowTipInfo)
		if cb then
			cb(oView)
		end
	end)
end

--弹出基本单行输入框
-- args = {
-- title-s标题, 
-- des-s信息, 
-- defaultCallback-fun默认回调, 
-- okCallback-fun确认回调, 
-- cancelCallback-fun取消回调, 
-- okStr-s确定按钮文字", 
-- cancelStr-s取消按钮文字}
-- cb 画面创建回调函数
function CWindowTipCtrl.SetWindowInput(self, args, cb)
	local windowInputInfo = {
		des				= args.des or "",
		title			= args.title or "提示",
		inputLimit		= args.inputLimit or 30,
		wordLimit		= args.wordLimit,
		cancelCallback	= args.cancelCallback,
		defaultCallback = args.defaultCallback,
		okCallback		= args.okCallback,
		defaultStr		= args.defaultStr or "确认",
		okStr			= args.okStr or "确认",
		cancelStr		= args.cancelStr or "取消",
		thirdStr		= args.thirdStr or "",
		isclose         = args.isclose,
	}
	CItemTipsInputWindowView:ShowView(function ()
		local oView = CItemTipsInputWindowView:GetView()
		oView:SetWindowInput(windowInputInfo)
		if cb then
			cb(oView)
		end
	end)
end

--弹出文字预览tips窗口
--sTitle 预览tips标题
--tContent 正文（table格式的文字数组，用于换行)_
--args 配置键盘的配置规则
function CWindowTipCtrl.SetWindowItemTipsWindow(self, sTitle, tContent, args)
	CItemTipsMainView:ShowView(function (oView)
		oView:ShowTipsWindowPage(sTitle, tContent)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(0, 10)
		args.openView = args.openView or nil
		oView:SetOpenView(args.openView)		
		UITools.NearTarget(args.widget, oView.m_ItemPreviewWindowPage, args.side, args.offset)
	end)
end

--弹出单个物品黑底tips窗口
--sTitle 预览tips标题
--tContent 正文（table格式的文字数组，用于换行)_
--tExtend 拓展
--args 配置键盘的配置规则
function CWindowTipCtrl.SetPreviewItemWindow(self, tExtend, args)
	CItemTipsMainView:ShowView(function (oView)
		oView:ShowPreviewItemPage(tExtend)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(0, 10)
		args.openView = args.openView or nil
		oView:SetOpenView(args.openView)		
		UITools.NearTarget(args.widget, oView.m_PreviewItemPage, args.side, args.offset)
	end)
end

--弹出单个物品出售窗口
--args 配置键盘的配置规则
function CWindowTipCtrl.SetWindowItemTipsSellItem(self, tItem, args)
	CItemTipsMoreView:ShowView(function (oView)
		oView:ShowSellPage(tItem)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(0, 10)
		--UITools.NearTarget(args.widget, oView.m_ViewBg, args.side, args.offset)
	end)
end

--弹出单个物品批量使用窗口
--args 配置键盘的配置规则
function CWindowTipCtrl.SetWindowItemTipsBatUseItem(self, tItem, args)
	CItemTipsMoreView:ShowView(function (oView)
		oView:ShowBatUsePage(tItem)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(0, 10)
		--UITools.NearTarget(args.widget, oView.m_ViewBg, args.side, args.offset)
	end)
end

--弹出数字键盘
--config 配置键盘的 当前值，最小值，最大值，同步函数,同步返回的对象
--args 配置键盘的配置规则
function CWindowTipCtrl.SetWindowNumberKeyBorad(self, config, args)
	CItemNumberKeyBoardView:ShowView(function (oView)
		oView:SetNumberKeyBoardConfig(config.num, config.min, config.max, config.syncfunc, config.obj)
		oView:SetPivot(args.side)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(0, 10)
		if args.extendClose then
			oView:SetExtendClose()
		end
		UITools.NearTarget(args.widget, oView.m_ViewBg, args.side, args.offset, true)
	end)
end

--弹出队伍目标选择
--config 参数设置 
--valueCallback
--closeCallback
--args 画面适配
function CWindowTipCtrl.SetWindowTeamTarget(self, config, args)
	CTeamTargetSetView:ShowView(function (oView)
		oView:ShowTargetBox(config.taskId)
		oView:SetTargetListener(config.valueCallback)
		oView:SetCloseListener(config.closeCallback)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Bottom
		args.offset = args.offset or Vector2.New(0, 10)
		UITools.NearTarget(args.widget, oView.m_TargetBox, args.side, args.offset)		
	end)
end

--弹出队伍等级调节
--config 参数设置 
--valueCallback
--closeCallback
--args 画面适配
function CWindowTipCtrl.SetWindowTeamLevel(self, config, args)
	CTeamTargetSetView:ShowView(function (oView)
		oView:ShowLevelBox(config.iTaskId, config.iMinGrade, config.iMaxGrade)
		oView:SetLevelListener(config.valueCallback)
		oView:SetOkListener(config.okCallback)
		args = args or {}
		args.widget = args.widget or oView
		args.side = args.side or enum.UIAnchor.Side.Top
		args.offset = args.offset or Vector2.New(0, 10)
		UITools.NearTarget(args.widget, oView.m_LevelBox, args.side, args.offset)		
	end)
end

--弹出PopupList选择画面
--valueCallback
--closeCallback
--args 画面适配
function CWindowTipCtrl.SetWindowPopupList(self, config, args)
	CItemTipsPopupOpView:ShowView(function (oView)
		oView:ShowPopupList(config)
		args = args or {}
		args.side = args.side or enum.UIAnchor.Side.Right
		args.offset = args.offset or Vector2.New(0, 10)
		UITools.NearTarget(args.widget, oView.m_Bg, args.side, args.offset)
	end)
end


function CWindowTipCtrl.ShowNoGoldTips(self, itype)
	-- local str = "你的金币不足，是否前往补充？"
	if itype == 2 then
		g_NotifyCtrl:FloatMsg("您的水晶不足")
		g_SdkCtrl:ShowPayView()
	elseif itype == 3 then
		-- str = "你的银币不足，是否前往补充？"
		g_NotifyCtrl:FloatMsg("您的银币不足")
	elseif itype == 9 then
		g_NotifyCtrl:FloatMsg("您的水晶不足")
		g_SdkCtrl:ShowPayView()
	elseif itype == 10 then
		g_NotifyCtrl:FloatMsg("您的体力不足")
		g_NpcShopCtrl:ShowGold2EnergyView()
	else
		g_NotifyCtrl:FloatMsg("您的金币不足")
		g_NpcShopCtrl:ShowGold2CoinView()
	end
end

--弹出任务读进度画面(采集类任务，寻地类任务等)
function CWindowTipCtrl.SetWindowTaskProgress(self, taskid, sessionidx)
	CItemTipsProgressView:ShowView(function (oView)
		oView:SetData(taskid, sessionidx)
	end)
end

--弹出道具货物奖励界面
function CWindowTipCtrl.SetWindowItemRewardList(self, itemList, args)
	local function func()
		CItemRewardListView:CloseView()
		CItemRewardListView:ShowView(function (oView)
			args = args or {}
			oView.m_IgnoreCloseAni =  args.IgnoreCloseAni or false
			oView:SetContent(itemList)
			oView:OpenDOTween()
		end)
	end
	local oView = CTitleRewardView:GetView()
	if oView then
		oView:SetTweenCompleteCB(function ()
			func()
		end)
	else
		func()
	end
end
--弹出道具货物奖励界面（可能带伙伴）
function CWindowTipCtrl.SetWindowAllItemRewardList(self, itemList, args)
	local function func()
		CItemRewardListView:CloseView()
		CItemRewardListView:ShowView(function (oView)
			args = args or {}
			oView.m_IgnoreCloseAni =  args.IgnoreCloseAni or false
			oView:SetAllContent(itemList)
			oView:OpenDOTween()
		end)
	end
	local oView = CTitleRewardView:GetView()
	if oView then
		oView:SetTweenCompleteCB(function ()
			func()
		end)
	else
		func()
	end
end

function CWindowTipCtrl.SetWindowTitleReward(self)
	local oView = CItemRewardListView:GetView()
	if oView then
		oView:SetTweenCompleteCB(function ()
			CTitleRewardView:ShowView()
		end)
	else
		CTitleRewardView:ShowView()
	end
end

--客户端自行读条func回调，iTimeMax修改读条时间
function CWindowTipCtrl.SetWindowClientProgress(self, func, iTimeMax, sKey)
	CItemTipsProgressView:ShowView(function (oView)
		oView:SetCallBackFunc(func, iTimeMax)
		oView:SetActionSrptie(sKey)
	end)
end

--确认框， 今天不在提示勾选
function CWindowTipCtrl.SetTodayTip(self, key, bselect)
	if not self.m_TodayMark then
		self.m_TodayMark = IOTools.GetRoleData("confirmtiptime") or {}
	end
	if bselect then
		self.m_TodayMark[key] = g_TimeCtrl:GetTimeS()
		IOTools.SetRoleData("confirmtiptime", self.m_TodayMark)
	end
end

function CWindowTipCtrl.IsShowTips(self, key)
	if not self.m_TodayMark then
		self.m_TodayMark = IOTools.GetRoleData("confirmtiptime") or {}
	end
	local sc = self.m_TodayMark[key]
	-- local dict = IOTools.GetRoleData("confirmtiptime") or {}
	-- local sc = dict[key]
	if sc and g_TimeCtrl:IsToday(tonumber(sc)) then
		return false
	else
		return true
	end
end

return CWindowTipCtrl