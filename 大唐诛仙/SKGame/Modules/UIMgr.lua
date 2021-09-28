require "SKGame/Base/LuaMsgWin"
UIMgr = {}
UIMgr.tips = {}

-- 弹出确认框 Alter(标题，显示信息，按钮文字，回调)
function UIMgr.Win_Alter(title, explain, btnText, callBack)
	if not resMgr:AddUIAB("MainTip") then return nil end
	local msgWin = MW_Alter.New()
	if msgWin == nil then return nil end
	msgWin:Open()
	msgWin:SetData(title, explain, btnText, callBack)
	return msgWin
end

-- 弹出询问窗体 Confirm(标题，显示信息，确认按钮文字，取消按钮文字，确认回调， 取消回调, 是否显示关闭按钮)
function UIMgr.Win_Confirm(title, explain, btnConfirmTxt, btnCancelTxt, confirmCallBack, cancelCallBack, isShowClose)
	if not resMgr:AddUIAB("MainTip") then return nil end
	local msgWin = MW_Confirm.New()
	if msgWin == nil then return nil end
	msgWin:Open()
	msgWin:SetData(title, explain, btnConfirmTxt, btnCancelTxt, confirmCallBack, cancelCallBack, isShowClose)
	return msgWin
end

UIMgr.tweener = nil
function UIMgr.Win_FloatTip(str_msg)
	if not resMgr:AddUIAB("MainTip") then return end
	if #UIMgr.tips > 20 then
		table.remove(UIMgr.tips, 1)
	end
	table.insert(UIMgr.tips, str_msg)
	if not UIMgr.tweener then
		UIMgr.tweener = TweenUtils.TweenFloat(0, 1, 0.5, function() end)
		TweenUtils.OnComplete(UIMgr.tweener, function ()
			UIMgr.Float()
		end)
	end
end

function UIMgr.Float()
	-- if not resMgr:AddUIAB("MainTip") then return end
	if #UIMgr.tips ~= 0 then
		local msgWin = MW_FloatTip.New()
		if msgWin == nil then return end
		msgWin:Open()
		msgWin:SetMsg(table.remove(UIMgr.tips,1))
		UIMgr.tweener = TweenUtils.TweenFloat(0, 1, 0.5, function() end)
		TweenUtils.OnComplete(UIMgr.tweener, function ()
			UIMgr.Float()
		end)

	else
		UIMgr.tweener = nil
	end
end

-- 顶级弹出ui，居中弹出显示
function UIMgr.ShowCenterPopup(popup, closeCallback, isCloseDestroy)
	UIMgr.ShowPopup(popup,false,0,0,closeCallback, isCloseDestroy, true)
end
-- 顶级弹出ui，offX, offY 相对于点击处偏移位置 再受限于对象大小与是否超边约束自动调整
function UIMgr.ShowPopup(popup,isUp,offX,offY,closeCallback, isCloseDestroy, isCenter)
	--如果有新手引导存在，新手引导优先，弹窗次之
	if TaskModel then
		local autoExecTaskId = TaskModel:GetInstance():GetAutoExecTaskId()
		if autoExecTaskId ~= 0 then  return end
	end

	if type(popup) == "table" then
		local luaUi = popup
		luaUi.ui.onRemovedFromStage:Add( function (context)
			if closeCallback then closeCallback() end
			if isCloseDestroy == nil or isCloseDestroy == true then
				luaUi:Destroy()
			end
		end)
		popup = popup.ui
	else
		popup.onRemovedFromStage:Add( function (context)
			if closeCallback then closeCallback() end
			if isCloseDestroy == nil or isCloseDestroy == true then
				destroyUI(popup)
			end
		end)
	end
	if not UIMgr.isCleaning then
		GRoot.inst:ShowPopup(popup)
	end
	popup.scaleX = GameConst.scaleX
	popup.scaleY = GameConst.scaleY
		local x = 0
		local y = 0
		local w = popup.width
		local h = popup.height
		if isCenter then
			x = (layerMgr.WIDTH - w + (offX or 0))*0.5
			y = (layerMgr.HEIGHT - h + (offY or 0))*0.5-10
		else
			local cur = layerMgr:GetUILayer():GlobalToLocal(Vector2(Stage.inst.touchPosition.x, Stage.inst.touchPosition.y))
			x = cur.x + (offX or 0)
			if isUp then
				y = cur.y-h + (offY or 0)
			else
				y = cur.y + (offY or 0)
			end
			if x + w > layerMgr.WIDTH then
				x = math.max(0, x - w)
			end
			if y + h > layerMgr.HEIGHT then
				y = math.max(0, y - h)
			end
		end
	popup.x = x * popup.scaleX
	popup.y = y * popup.scaleY
end
-- 顶级弹出ui，x, y ui绝对位置显示
function UIMgr.ShowPopupToPos(popup,x,y,closeCallback, isCloseDestroy)
	--如果有新手引导存在，新手引导优先，弹窗次之
	local autoExecTaskId = TaskModel:GetInstance():GetAutoExecTaskId()
	if autoExecTaskId ~= 0 then return end

	if type(popup) == "table" then
		local luaUi = popup
		luaUi.ui.onRemovedFromStage:Add( function (context)
			if closeCallback then closeCallback() end
			if isCloseDestroy == nil or isCloseDestroy == true then
				luaUi:Destroy()
			end
		end)
		popup = popup.ui
	else
		popup.onRemovedFromStage:Add( function (context)
			if closeCallback then closeCallback() end
			if isCloseDestroy == nil or isCloseDestroy == true then
				destroyUI(popup)
			end
		end)
	end
	GRoot.inst:ShowPopup(popup)
	popup.scaleX = GameConst.scaleX
	popup.scaleY = GameConst.scaleY
	popup.x = (x or 0)*GameConst.scaleX
	popup.y = (y or 0)*GameConst.scaleY
end
function UIMgr.HidePopup(popup)
	if popup then
		GRoot.inst:HidePopup(popup)
	else
		GRoot.inst:HidePopup()
	end
end
--切换场景销毁所有的弹窗
function UIMgr.DestroyAllPopup()
	UIMgr.isCleaning = true
	GRoot.inst:HidePopup()
	UIMgr.isCleaning = false
end
