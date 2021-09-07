-- @author 黄耀聪
-- @date 2017年8月28日, 星期一

FaceTipsPanel = FaceTipsPanel or BaseClass(BasePanel)

function FaceTipsPanel:__init(model, gameObject)
    self.ui_camera = ctx.UICamera
    self.model = model
    self.gameObject = gameObject
    self.name = "FaceTipsPanel"

    self.isInited = false
    self.faceId = 0
    self.offset = 0

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.freshUpdateListener = function() self:FreshTips() end
    self.refreshTimerId = nil
    self:InitPanel()
end

function FaceTipsPanel:__delete()
    self.OnHideEvent:Fire()

    if self.firstEffect ~= nil then
        self.firstEffect:SetActive(true)
        self.firstEffect = nil
    end
    if self.refreshTimerId ~= nil then
        LuaTimer.Delete(self.refreshTimerId)
        self.refreshTimerId = nil
    end
    if self.faceItem ~= nil then
    	self.faceItem:DeleteMe()
    	self.faceItem = nil
    end
    self.gameObject = nil
    self.model = nil
end

function FaceTipsPanel:InitPanel()
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t
    self.width = self.transform:GetComponent(RectTransform).sizeDelta.x
    self.height = self.transform:GetComponent(RectTransform).sizeDelta.y

    self.image = t:Find("Panel"):GetComponent(RawImage)

    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnHide() end)
    t:Find("Main"):GetComponent(Button).onClick:AddListener(function() self:OnHide() end)
    self.okButton =  t:Find("Main/OkButton"):GetComponent(Button)
    t:Find("Main/OkButton"):GetComponent(Button).onClick:AddListener(function() self:OnOkButtonClick() end)

    self.rectTransform = t:Find("Main"):GetComponent(RectTransform)
    self.faceItem = FaceItem.New(t:Find("Main/Icon"))
    self.nameText = t:Find("Main/Name"):GetComponent(Text)
    -- t:Find("Main/TimeLimit")
    self.descText = t:Find("Main/Desc"):GetComponent(Text)
    self.descText2 = t:Find("Main/Desc2"):GetComponent(Text)
    self.textExt = MsgItemExt.New(self.descText2, 250, 16, 30)
    self.noticeObject = t:Find("Main/Notice").gameObject
    self.noticeObject:GetComponent(Button).onClick:AddListener(function()
    	TipsManager.Instance:ShowText({gameObject = self.noticeObject
            , itemData = { TI18N("花费<color='#ffff00'>3个</color>包子币，可以兑换指定<color='#ffff00'>大表情</color>")
                        }})
    end)
    self.firstEffect = BibleRewardPanel.ShowEffect(20384, self.gameObject.transform, Vector3.one, Vector3(0, 0, -400))
    self.firstEffect:SetActive(false)
    self.bottomGbj = t:Find("Main/BottomText").gameObject
    self.bottomGbj:GetComponent(Text).text = TI18N("使用包子币可兑换<color='#ffff00'>指定</color>大表情获得<color='#ffff00'>重复</color>大表情可获得包子币")
    self.hasGet = t:Find("Main/HasGet").gameObject
end

function FaceTipsPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function FaceTipsPanel:OnOpen()
    self:RemoveListeners()
    FaceManager.Instance.OnFreshTips:AddListener(self.freshUpdateListener)

    if self.gameObject ~= nil then
	    self.gameObject:SetActive(true)

	    if self.openArgs ~= nil and #self.openArgs > 0 then
	    	self.faceId = self.openArgs[1]

	    	self:Update()
	    end
	end
    self.selectGameObject = self.openArgs[2]
    self:Locate(self.selectGameObject.transform,self.transform.gameObject,{w = self.width, h = self.height})
end

function FaceTipsPanel:OnHide()
    self:RemoveListeners()
    self.firstEffect:SetActive(false)
     if self.gameObject ~= nil then
	    self.gameObject:SetActive(false)
	end
end

function FaceTipsPanel:RemoveListeners()
    FaceManager.Instance.OnFreshTips:RemoveListener(self.freshUpdateListener)
end

function FaceTipsPanel:Update()
	local data_new_face = DataChatFace.data_new_face[self.faceId]
	if data_new_face ~= nil then
		self.nameText.text = data_new_face.name
		self.descText.text = string.format(TI18N("表情心语:%s"), data_new_face.dese)

		local cost = data_new_face.cost[1]
		if cost ~= nil then
			local baseData = BackpackManager.Instance:GetItemBase(cost[1])
	        local has = BackpackManager.Instance:GetItemCount(cost[1])
	        local color = "#00ff00"
	        if has < cost[2] then
	        	color = "#ff0000"
	        end
	        self.textExt:SetData(string.format(TI18N("%s{assets_2,%s}:{string_2, %s, %s/%s}"), baseData.name, cost[1], color, has, cost[2]))
		end

        if ChatManager.Instance.bigFaceDic ~= nil then
            if ChatManager.Instance.bigFaceDic[self.faceId] ~= nil then
                self.hasGet.gameObject:SetActive(true)
                self.bottomGbj.gameObject:SetActive(false)
                self.descText2.gameObject:SetActive(false)
                self.okButton.gameObject:SetActive(false)
                self.noticeObject.gameObject:SetActive(false)

                self.rectTransform.sizeDelta = Vector2(270, 250)
                self.height = 250
            else
                self.hasGet.gameObject:SetActive(false)
                self.bottomGbj.gameObject:SetActive(true)
                self.descText2.gameObject:SetActive(true)
                self.okButton.gameObject:SetActive(true)
                self.noticeObject.gameObject:SetActive(false)

                self.rectTransform.sizeDelta = Vector2(270, 325)
                self.height = 325
            end
        else
            self.hasGet.gameObject:SetActive(false)
            self.bottomGbj.gameObject:SetActive(true)
            self.descText2.gameObject:SetActive(true)
            self.okButton.gameObject:SetActive(true)
            self.noticeObject.gameObject:SetActive(true)
        end

		self.faceItem.size = Vector2(56, 56)
        self.faceItem:Show(self.faceId, Vector2(6, -10))
	end
end

function FaceTipsPanel:OnOkButtonClick()
	local data_new_face = DataChatFace.data_new_face[self.faceId]
	if data_new_face ~= nil then
		local cost = data_new_face.cost[1]
		if cost ~= nil then
	        local has = BackpackManager.Instance:GetItemCount(cost[1])
	        if has < cost[2] then
	        	NoticeManager.Instance:FloatTipsByString("物品不足")
	        else
	        	FaceManager.Instance:Send10430(self.faceId)
	        end
		end
	end
end

function FaceTipsPanel:Locate(trans, tips, size, special, tipsOffsetX, tipsOffsetY, forward)
    if tipsOffsetX == nil then tipsOffsetX = 0 end
    if tipsOffsetY == nil then tipsOffsetY = 0 end
    local v2 = self:CameraPosition(trans)
    local half = self:ObjSize(trans)
    local pivot = trans.gameObject:GetComponent(RectTransform).pivot
    local off_x = (0.5 - pivot.x)/0.5 * half.w + tipsOffsetX
    local off_y = (0.5 - pivot.y)/0.5 * half.h + tipsOffsetY
    self:Dolocate(v2.x, off_x, v2.y, off_y, half.w, half.h, tips, size.w, size.h, special)
end
function FaceTipsPanel:Dolocate(x, off_x, y, off_y, ohwidth, ohheight, tips, width, height, special)
    local rect = tips:GetComponent(RectTransform)
    local scaleWidth = ctx.ScreenWidth
    local scaleHeight = ctx.ScreenHeight
    local origin = 960 / 540
    local currentScale = scaleWidth / scaleHeight

    local newx = 0
    local newy = 0
    local cw = 0
    local ch = 0
    if currentScale > origin then
        -- 以宽为准
        ch = 540
        cw = 960 * currentScale / origin
    else
        -- 以高为准
        ch = 540 * origin / currentScale
        cw = 960
    end

    newx = x * cw / scaleWidth
    newy = y * ch / scaleHeight


    local v2 = Vector2(newx + off_x, newy + off_y)
    local right = true
    local guidemark = false --指引旋转标记
    if (v2.x - width - ohwidth) < self.offset then--在图标右边
        if tips.gameObject.name == "GuideTips" then
            guidemark = true
        end
        if (v2.y - height + ohheight) < self.offset then--贴底边
            v2 = Vector2(v2.x + ohwidth, 0)
        else
            v2 = v2 + Vector2(ohwidth, ohheight - height)
        end
    else--在图标左边
        right = false
        if (v2.y - height + ohheight) < self.offset then--贴底边
            v2 = Vector2(v2.x - width - ohwidth, 0)
        else
            v2 = v2 + Vector2(-width - ohwidth, ohheight - height)
        end
    end

    rect.anchoredPosition = Vector2(v2.x, v2.y)

end


--获取对象对应镜头的位置
function FaceTipsPanel:CameraPosition(trans)
    local v3 = nil
    if trans == nil then
        v3 = Vector2(ctx.ScreenWidth/2, ctx.ScreenHeight/2)
    else
        v3 = self.ui_camera.camera:WorldToScreenPoint(trans.position)
    end
    return Vector2(v3.x, v3.y)
end

--获取对象长宽--已经渲染的方可
function FaceTipsPanel:ObjSize(trans)
    local half = nil
    if trans == nil then
        half = {w = 0, h = 0}
    else
        half = {w = trans.gameObject:GetComponent(RectTransform).rect.width/2, h = trans.gameObject:GetComponent(RectTransform).rect.height/2}
    end
    return half
end

function FaceTipsPanel:FreshTips()
    self.firstEffect:SetActive(true)
     if self.refreshTimerId == nil then
        self.refreshTimerId = LuaTimer.Add(300, function()
            self:OnHide()
        end)
    end
end