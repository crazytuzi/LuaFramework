module(..., package.seeall)

g_UICache = {}

function SetSubPanelDepthDeep(luaobj)
	NGUI.NGUITools.SetSubPanelDepthDeep(luaobj.m_GameObject)
end

function SetSubWidgetDepthDeep(luaobj)
	NGUI.NGUITools.SetSubWidgetDepthDeep(luaobj.m_GameObject)
end

function GetPixelSizeAdjustment()
	return UITools.GetUIRoot().pixelSizeAdjustment
end

function SetLabelEffectFactor(factor)
	NGUI.NGUITools.SetLabelEffectFactor(factor)
end

function GetRootSize()
	if not g_UICache["rootsize"] then
		local factor = GetPixelSizeAdjustment()
		local w = UnityEngine.Screen.width * factor
		local h = UnityEngine.Screen.height * factor
		g_UICache["rootsize"] = {w=w, h=h}
	end
	return g_UICache["rootsize"].w, g_UICache["rootsize"].h
end

function GetUIRoot()
	if not g_UICache["uiroot"] then
		local oRoot = UnityEngine.GameObject.Find("GameRoot/UIRoot")
		g_UICache["uiroot"] = oRoot:GetComponent(classtype.UIRoot)
	end
	return g_UICache["uiroot"]
end

function GetUIRootObj(bAlwaysShow)
	if bAlwaysShow then
		if not g_UICache["uiroot_obj_always"] then
			g_UICache["uiroot_obj_always"] = CObject.New(UnityEngine.GameObject.Find("GameRoot/UIRoot/Show/AlwaysShow"))
		end
		return g_UICache["uiroot_obj_always"]
	else
		if not g_UICache["uiroot_obj_normal"] then
			g_UICache["uiroot_obj_normal"] = CObject.New(UnityEngine.GameObject.Find("GameRoot/UIRoot/Show/NormalShow"))
		end
		return g_UICache["uiroot_obj_normal"]
	end
end

function GetRootPanel()
	if not g_UICache["rootpanel"] then
		local oRoot = UnityEngine.GameObject.Find("GameRoot/UIRoot")
		g_UICache["rootpanel"] = oRoot:GetComponent(classtype.UIPanel)
	end
	return g_UICache["rootpanel"]
end

function GetPixelSizeAdjustment()
	if not g_UICache["pixelSizeAdjustment"] then
		local oRoot = GetUIRoot()
		g_UICache["pixelSizeAdjustment"] = oRoot.pixelSizeAdjustment
	end
	return g_UICache["pixelSizeAdjustment"]
end

function ResizeToRootSize(oWidget, iExtWidth, iExtHeight)
	local rootw, rooth = GetRootSize()
	iExtWidth = iExtHeight or 0
	iExtHeight = iExtHeight or 0
	oWidget:SetSize(rootw+iExtWidth, rooth+iExtHeight)
end

function GetDesignSize()
	return 1334, 750
end

function FitToRootSize(oWidget, iAspect)
	local w, h = GetRootSize()
	if iAspect > (w/h) then
		w = h * iAspect
	else
		h = w / iAspect
	end
	oWidget:SetSize(w, h)
end

function FitToRootScale(oWidget, iDesignWith, iDesignHeight)
	local rootW, rootH = GetRootSize()
	local iScaleW = rootW / iDesignWith
	local iScaleH = rootH / iDesignHeight
	local iScale = math.max(iScaleW, iScaleH)
	oWidget:SetLocalScale(Vector3.New(iScale, iScale, 1))
end

function CalculateRelativeWidgetBounds(transform)
	return NGUI.NGUIMath.CalculateRelativeWidgetBounds(transform)
end

function CalculateAbsoluteWidgetBounds(transform)
	return NGUI.NGUIMath.CalculateAbsoluteWidgetBounds(transform)
end

function NearTarget(targetWid, nearWid, side, offset, bConstrainInPanel)
	if not targetWid or Utils.IsNil(targetWid) then
		print("NearTarget targetWid不存在")
		printtrace()
		return
	end
	offset = offset or Vector2.zero
	side = side or enum.UIAnchor.Side.Top
	local anchor = nearWid:GetMissingComponent(classtype.UIAnchor)
	anchor.side = side
	local oldPivot = nearWid:GetPivot()
	if side == enum.UIAnchor.Side.Top then
		nearWid:SetPivot(enum.UIWidget.Pivot.Bottom)
	elseif side == enum.UIAnchor.Side.TopLeft then
		nearWid:SetPivot(enum.UIWidget.Pivot.BottomRight)
	elseif side == enum.UIAnchor.Side.TopRight then
		nearWid:SetPivot(enum.UIWidget.Pivot.BottomLeft)
	elseif side == enum.UIAnchor.Side.Bottom then
		nearWid:SetPivot(enum.UIWidget.Pivot.Top)
	elseif side == enum.UIAnchor.Side.BottomLeft then
		nearWid:SetPivot(enum.UIWidget.Pivot.TopRight)
	elseif side == enum.UIAnchor.Side.BottomRight then
		nearWid:SetPivot(enum.UIWidget.Pivot.TopLeft)
	elseif side == enum.UIAnchor.Side.Center then
		nearWid:SetPivot(enum.UIWidget.Pivot.Center)
	elseif side == enum.UIAnchor.Side.Left then
		nearWid:SetPivot(enum.UIWidget.Pivot.Right)
	elseif side == enum.UIAnchor.Side.Right then
		nearWid:SetPivot(enum.UIWidget.Pivot.Left)
	end
	anchor.pixelOffset = offset
	anchor.container = targetWid.m_GameObject
	anchor.uiCamera = g_CameraCtrl:GetUICamera().m_Camera
	anchor:ForceUpdate()
	nearWid:SetPivot(oldPivot)
	if bConstrainInPanel then
		local panel = NGUI.UIPanel.Find(nearWid.m_Transform)
		if panel and not panel.gameObject:GetComponent(classtype.UIScrollView) then
			local root = GetRootPanel()
			root:ConstrainTargetToBounds(nearWid.m_Transform, true)
		end
	end
end

function ResizeLabelWidth(oLabel, sText, minW, maxW)
	oLabel:SetOverflow(enum.UILabel.Overflow.ResizeFreely)
	oLabel:SetText(sText)
	local w, h = oLabel:GetSize()
	if w > maxW then
		oLabel:SetOverflow(enum.UILabel.Overflow.ResizeHeight)
		oLabel.m_UIWidget.width = maxW
		oLabel:SetText(sText)
	elseif w < minW then
		oLabel:SetOverflow(enum.UILabel.Overflow.ShrinkContent)
		oLabel.m_UIWidget.width = minW
		oLabel:SetText(sText)
	end
end

function MoveToTarget(oScroll, oTarget, offset)
	offset = offset or 0
	local pos = oTarget:GetLocalPos()
	oScroll:ResetPosition()
	local movement = oScroll:GetMovement()
	if movement == enum.UIScrollView.Movement.Horizontal then
		oScroll:MoveRelative(Vector3.New(-pos.x  - offset, 0, 0))
	elseif movement == enum.UIScrollView.Movement.Vertical then
		oScroll:MoveRelative(Vector3.New(0, -pos.y - offset, 0))
	end
end

function CalculateNextDepth(gameobject)
	return NGUI.NGUITools.CalculateNextDepth(gameobject)
end

function IsChild(parentTrans, childTrans)
	return NGUI.NGUITools.IsChild(parentTrans, childTrans)
end

function GetCenterOffsetPixel(oWidget)
	local v = NGUI.NGUIMath.GetPivotOffset(oWidget:GetPivot())
	local w, h = oWidget:GetSize()
	return (v.x-0.5) * w, (v.y-0.5) * h
end

function MarkParentAsChanged(gameObject)
	NGUI.NGUITools.MarkParentAsChanged(gameObject)
end

function CheckInDistanceXY(pos1, pos2, max)
	if pos1 and pos2 and max then
		return ((pos1.x-pos2.x)^2+(pos1.y - pos2.y)^2) <= max^2
	else
		return false
	end
end

function ScaleToFit(object, minValue)
	local rootw, rooth = GetRootSize()
	local objW, objH = object:GetSize()
	local scaleW = rootw / objW
	local scaleH = rooth / objH
	if scaleW > scaleH then
		if minValue and scaleW < minValue then
			return
		end
		object:SetLocalScale(Vector3.New(scaleW, scaleW, scaleW))
	else
		if minValue and scaleH < minValue then
			return
		end
		object:SetLocalScale(Vector3.New(scaleH, scaleH, scaleH))
	end
end

function HideUI(self)
	if g_SysSettingCtrl:IsLockScreen() then
		return
	end
	local oRootObj = UITools.GetUIRootObj(false)
	oRootObj:SetActive(false)
end

function ShowUI(self)
	local oRootObj = UITools.GetUIRootObj(false)
	oRootObj:SetActive(true)
end



function GetRTPixels(rt)
	local preRT = UnityEngine.RenderTexture.active
	UnityEngine.RenderTexture.active = rt
	local w, h = rt.width, rt.height
	local tex2D = UnityEngine.Texture2D.New(w, h)
	tex2D:ReadPixels(UnityEngine.Rect.New(0, 0, w, h), 0, 0)
	UnityEngine.RenderTexture.active = preRT
	return tex2D
end