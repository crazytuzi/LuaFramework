ShouhuMainItem = ShouhuMainItem or BaseClass()

function ShouhuMainItem:__init(parent, origin_item, data, _index)
    self.parent = parent
    self.gameObject = GameObject.Instantiate(origin_item)
    self.transform = self.gameObject.transform
    -- UIUtils.AddUIChild(origin_item.transform.parent.gameObject, self.gameObject)
    self.transform:SetParent(origin_item.transform.parent)
    self.transform.localScale = Vector3.one

    self.gameObject:SetActive(true)
    self.transform = self.gameObject.transform
    self.ShouhuHeadCon = self.transform:FindChild("ShouhuHeadCon").gameObject
    self.ImgHeadBg = self.ShouhuHeadCon:GetComponent(Image)
    self.ImgHead = self.ShouhuHeadCon.transform:FindChild("ImgHead"):GetComponent(Image)
    self.ImgHead.gameObject:SetActive(false)
    self.ImgLev = self.ShouhuHeadCon.transform:FindChild("ImgLev")
    self.ImgLev_txt = self.ImgLev:FindChild("TxtLev"):GetComponent(Text)
    self.ImgPoint = self.ShouhuHeadCon.transform:FindChild("ImgPoint").gameObject
    self.ImgMask = self.ShouhuHeadCon.transform:FindChild("ImgMask").gameObject
    self.ImgMaskLock = self.ShouhuHeadCon.transform:FindChild("ImgMask/ImgLock").gameObject
    self.ImgMaskIcon = self.ShouhuHeadCon.transform:FindChild("ImgMask/Img")
    self.ImgMaskIcon.sizeDelta = Vector2(60, 60)
    self.ImgMask:SetActive(false)
    self.ImgOutFight = self.transform:FindChild("ImgOutFight").gameObject
    self.ImgOutHelp = self.transform:FindChild("ImgOutHelp").gameObject

    self.ImgOutFight:GetComponent(CanvasGroup).blocksRaycasts = false
    self.ImgOutHelp:GetComponent(CanvasGroup).blocksRaycasts = false

    self.Txt_Name = self.transform:FindChild("Txt_Name"):GetComponent(Text)
    self.ImgClasses = self.transform:FindChild("ImgClasses"):GetComponent(Image)
    self.TxtLev = self.transform:FindChild("TxtLev"):GetComponent(Text)
    self.ImgSelected = self.transform:FindChild("ImgSelected"):GetComponent(Image)
    self.ImgOutFight:SetActive(false)
    self.ImgOutHelp:SetActive(false)
    self.ImgPoint:SetActive(false)
    self.ImgSelected.gameObject:SetActive(false)
    self.colors = {}

    self.gameObject:GetComponent(Button).onClick:AddListener(function() self:on_click_item() end) --item
    self:add_drag2go(self.ImgHead.gameObject)

    local newY = (_index - 1)*-79
    local rect = self.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(6, newY)
end

function ShouhuMainItem:Release()
    self.ImgHead.sprite = nil
    self.ImgClasses.sprite = nil
end

function ShouhuMainItem:InitPanel(_data)

end

function ShouhuMainItem:set_list_sh_base_data(data)
    self.data = data
    self.ImgPoint:SetActive(false)
    self.ImgOutFight:SetActive(false)
    self.ImgOutHelp:SetActive(false)
    self.ImgMask:SetActive(false)


    -- self.ImgHeadBg.sprite = self.colors[self.data.quality]
    self.Txt_Name.text = ColorHelper.color_item_name(data.quality , data.alias)

    self.ImgClasses.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" .. data.classes)

    local resId= tostring(self.data.avatar_id)
    if not BaseUtils.isnull(self.ImgHead) then 
        self.ImgHead.sprite=self.parent.assetWrapper:GetSprite(AssetConfig.guard_head,resId)
        self.ImgHead.gameObject:SetActive(true)
    end

    local tempLev = RoleManager.Instance.RoleData.lev
    if RoleManager.Instance.RoleData.lev_break_times ~= 0 then
        --突破过了
        if tempLev < 100 then
            tempLev = 100
        end
    end
    self.ImgLev_txt.text = tostring(tempLev)

    if self.data.war_id == nil then
        if self.data.recruit_lev <= RoleManager.Instance.RoleData.lev then
            self.ImgMask:SetActive(false)
            self.TxtLev.text = string.format("<color='%s'>%s(%s)</color>", ColorHelper.color[1], TI18N("待招募") , KvData.classes_name[data.classes])
        else
            self.ImgMask:SetActive(true)
            self.TxtLev.text = string.format("%s%s", self.data.recruit_lev, TI18N("级解锁"))
        end
    else
        self.ImgOutFight:SetActive(false)
        self.ImgOutHelp:SetActive(false)
        if self.data.war_id ~= 0 then--上阵
            self.ImgOutFight:SetActive(true)
        else--没有上阵
            if self.data.guard_fight_state == self.parent.model.guard_fight_state.field then--出战
                self.ImgOutHelp:SetActive(true)
            end
        end
        self.TxtLev.text = string.format("%s <color='#205696'>%s</color>", string.format(ColorHelper.DefaultStr, KvData.classes_name[data.classes]), self.data.score)
    end
    self:CheckRedPointState()
end

--设置红点状态
function ShouhuMainItem:CheckRedPointState()
    self.ImgPoint:SetActive(false)
    if self.data.war_id ~= nil and self.parent.model:CheckShouhuCanWakeup(self.data) and self.parent.curSelectedBtn == 2 then --检查该守护是否能够激活星阵
        self.ImgPoint:SetActive(self.parent.model:CheckShouhuCanWakeup(self.data))
    elseif self.data.equip_list ~= nil and self.data.war_id ~= nil  and self.parent.curSelectedBtn == 3 then
        if self.data.war_id ~= 0 or self.data.guard_fight_state == self.parent.model.guard_fight_state.field then
            self.ImgPoint:SetActive(false)
        else
            if self.data.war_id ~= nil then
                self.ImgPoint:SetActive(true)
            end
        end
    elseif self.parent.curSelectedBtn == 1 then
        if self.data.war_id == nil then --这个守护可以招募
            if self.data.recruit_lev <= RoleManager.Instance.RoleData.lev then
                -- if self.parent.model:check_can_recruit(self.data) then --判断下招募材料够不够
                    self.ImgPoint:SetActive(true)
                -- end
            end
        else
            if self.parent.model:check_shouhu_equip_can_up(self.data) == true then
                self.ImgPoint:SetActive(true)
            end
        end
    elseif self.parent.curSelectedBtn == 4 then
        --转换界面  判断该守护是否满足转换条件

        if self.parent.model:CheckIsPurpleShouhu(self.data) == true and self.parent.model:CheckAllGemsBiggerOne(self.data) == true then
            self.ImgMask:SetActive(false)
        else
            self.ImgMask:SetActive(true)
            self.ImgMaskLock:SetActive(false)
        end
    end
end

--设置显示状态
function ShouhuMainItem:SetActive(state)
    self.showState = state
    self.gameObject:SetActive(state)
end

function ShouhuMainItem:on_click_item()
    self.parent:update_right_content(self)
end

-----------------------------------------列表头像拖动上阵逻辑
function ShouhuMainItem:add_drag2go(go)
    --imgHead添加拖动事件
    local cdb = go:GetComponent(CustomDragButton)
    cdb.onClick:AddListener(function(data)
        self:on_click_item()
    end)
    cdb.onBeginDrag:AddListener(function(data) self:on_begin_drag(data) end)
    cdb.onDrag:AddListener(function(data) self:on_drag(data) end)
    cdb.onEndDrag:AddListener(function(data) self:do_end_drag(data) end)
end

function ShouhuMainItem:on_begin_drag(data)
    if self.parent.curSelectedBtn == 1 or self.parent.curSelectedBtn == 2 or self.parent.curSelectedBtn == 4 then
        return
    end

    local cg = self.ImgHead.gameObject:GetComponent(CanvasGroup)
    cg.blocksRaycasts = false

    self:do_clone_action(self.ImgHead.gameObject) --执行克隆
    self.parent:record_drag_item(self)
end

function ShouhuMainItem:on_drag(data)
    if self.parent.curSelectedBtn == 1 or self.parent.curSelectedBtn == 2 or self.parent.curSelectedBtn == 4 then
        return
    end

    local curScreenSpace=Vector3(Input.mousePosition.x*1,Input.mousePosition.y*1,self.screenSpace.z) --执行改变位置
    self.ImgHead.gameObject.transform.position= ctx.UICamera:ScreenToWorldPoint(curScreenSpace)
end

function ShouhuMainItem:do_end_drag()
    if self.parent.curSelectedBtn == 1 or self.parent.curSelectedBtn == 2 or self.parent.curSelectedBtn == 4  then
        return
    end

    --销毁拖动对象
    GameObject.Destroy(self.ImgHead.gameObject)
    self.ImgHead = nil
    self.ImgHead = self.clone
    local cg = self.ImgHead.gameObject:GetComponent(CanvasGroup)
    cg.blocksRaycasts = true
    self.parent:do_shang_zhen(self)
end

--执行克隆逻辑
function ShouhuMainItem:do_clone_action(go)
    self.screenSpace=self.gameObject.transform.position

    --克隆要拖动的对象
    local temp = GameObject.Instantiate(self.ImgHead.gameObject)
    temp.name = "ImgHead"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.ImgHead.transform.parent.gameObject, temp)

    self.clone = temp:GetComponent(Image)
    local dragObject=self.ImgHead
    local dragObject_tr = dragObject.transform
    local clone_rect=self.clone:GetComponent(RectTransform)
    local dragObject_rect = dragObject_tr:GetComponent(RectTransform)
    clone_rect.anchorMax=Vector2(0.5,0.5)
    clone_rect.anchorMin=Vector2(0.5,0.5)
    clone_rect.sizeDelta = Vector2(dragObject_rect.rect.width,dragObject_rect.rect.height)
    --self.clone.transform:SetAsLastSibling()
    self.clone.transform:SetAsFirstSibling()
    dragObject_tr:SetParent(self.parent.gameObject.transform) --设置到最顶层容器
    dragObject_rect.anchoredPosition = Vector2(dragObject_rect.anchoredPosition.x,dragObject_rect.anchoredPosition.y - 20)

    --克隆物体添加事件
    self:add_drag2go(self.clone.gameObject)
end