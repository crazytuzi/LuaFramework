ShouhuStarItem = ShouhuStarItem or BaseClass()

function ShouhuStarItem:__init(parent, origin_item, index)
    self.parent = parent
    self.index = index

    self.gameObject= origin_item
    self.gameObject:SetActive(true)
    self.transform = self.gameObject.transform


    self.ImgRedPt = self.transform:FindChild("ImgRedPt"):GetComponent(Image)
    self.ImgRedPt.gameObject:SetActive(false)
    self.ImgIconWord =  self.transform:FindChild("ImgTxt"):GetComponent(Image)
    self.ImgIconUnActive= self.transform:FindChild("ImgLock"):GetComponent(Image)
    self.ImgIconUnActive.gameObject:SetActive(false)
    self.ImgHead= self.transform:FindChild("ImgHead"):GetComponent(Image)
    self.ImgBottom = self.transform:FindChild("ImgBottom")
    self.TxtOpen =  self.transform:FindChild("ImgBottom"):FindChild("Txt"):GetComponent(Text)
    self.TxtLev = self.transform:FindChild("TxtLev"):GetComponent(Text)
    self.has_act = false

    self.ImgIconWord.transform:GetComponent(Button).onClick:AddListener(function()
        self.parent:GuideEnd()
        self.parent.parent:ShowHelpChangePanel(self.index)
    end)
    self.ImgIconUnActive.transform:GetComponent(Button).onClick:AddListener(function() self:on_click_icon_con(self.ImgIconUnActive.gameObject) end) --对文字加button，对未开启锁头加button 从而加tips

    self:add_drag2go(self.ImgHead.gameObject)

    self.transform:GetComponent(CustomEnterExsitButton).onEnter:AddListener(function(data) self.parent.parent:record_drag_item(self) end)
    self.transform:GetComponent(CustomEnterExsitButton).onExsit:AddListener(function(data) self.parent.parent:record_drag_item(nil) end)
end

function ShouhuStarItem:Release()
end

function ShouhuStarItem:set_icon_bg(bg)
    self.ImgIconUnActive.gameObject:SetActive(false)
    self.ImgIconWord.gameObject:SetActive(false)
    self.ImgHead.gameObject:SetActive(false)
    bg.gameObject:SetActive(true)
end

function ShouhuStarItem:set_sh_tactics_data(data)
    self.myData = data
    if self.myData.has_act then--已激活
        self.has_act = true
        self.ImgIconWord.gameObject:SetActive(true)
        self.TxtLev.gameObject:SetActive(false)
    else
        self.has_act = false
        self.TxtLev.text= string.format("%s%s", self.myData.act_lev, TI18N("级\n开启"))
        self.ImgIconWord.gameObject:SetActive(false)
        self.TxtLev.gameObject:SetActive(true)
        --
    end
end

function ShouhuStarItem:set_star_my_sh_data(data)
    self.myShData = data
    local key = string.format("%s_%s" , self.index, RoleManager.Instance.RoleData.lev)
    local cfg_data = DataShouhu.data_guard_help_fight_prop[key].attrs[1]
    if self.myShData ~= nil then
        local score = ShouhuManager.Instance.model:get_score(self.myShData)
        local show_val =  math.floor(score/600*cfg_data.val)
        self.TxtOpen.text= string.format("<color='#22E3EA'>%s</color><color='#8DE92A'>+%s</color>", KvData.attr_name[cfg_data.attr], show_val)
    else
        self.TxtOpen.text= string.format("<color='#22E3EA'>%s</color><color='#8DE92A'>+%s</color>", KvData.attr_name[cfg_data.attr], tostring("??"))
    end

    self.ImgRedPt.gameObject:SetActive(false)
    if self.myShData ==nil then --没有守护在该阵位上阵
       self.ImgHead.gameObject:SetActive(false)
       if self.myData.has_act then --已经开启
           self:set_icon_bg(self.ImgIconWord)
           self.ImgRedPt.gameObject:SetActive(true) -- 当该阵位已解锁且没有守护在该阵位上阵时，会激活红点以提示玩家
       else
           --
       end
    else--有守护在该阵位上阵
        -- print("===========================dd")
        -- print(self.ImgHead)
        -- print(self.myShData)
        -- print(self.myShData.avatar_id)
       self.ImgHead.sprite=  self.parent.assetWrapper:GetSprite(AssetConfig.guard_head, tostring(self.myShData.avatar_id))
       self.ImgHead.gameObject:SetActive(true)

       if self.myShData.guard_fight_state == ShouhuManager.Instance.model.guard_fight_state.field then--上阵状态可以休息

       elseif self.myShData.guard_fight_state  == ShouhuManager.Instance.model.guard_fight_state.idle then--空闲状态可以上阵

       end
    end
end

--点击阵位监听，出现tips
function ShouhuStarItem:on_click_icon_con(g)
    local tipstr = ""
    if self.myData.has_act  == false then
        tipstr=string.format(ShouhuManager.Instance.model.sh_lang.SH_STAR_ITEM_TIPS_WORD_UNACT,tostring(self.myData.act_lev))
    else
        if self.myData.pos ==1 then
            tipstr = ShouhuManager.Instance.model.sh_lang.SH_STAR_ITEM_TIPS_WORD_1
        elseif self.myData.pos ==2 then
            tipstr = ShouhuManager.Instance.model.sh_lang.SH_STAR_ITEM_TIPS_WORD_2
        elseif self.myData.pos ==3 then
            tipstr =  ShouhuManager.Instance.model.sh_lang.SH_STAR_ITEM_TIPS_WORD_3
        elseif self.myData.pos ==4 then
            tipstr = ShouhuManager.Instance.model.sh_lang.SH_STAR_ITEM_TIPS_WORD_4
        elseif self.myData.pos ==5 then
            tipstr = ShouhuManager.Instance.model.sh_lang.SH_STAR_ITEM_TIPS_WORD_5
        elseif self.myData.pos ==6 then
            tipstr = ShouhuManager.Instance.model.sh_lang.SH_STAR_ITEM_TIPS_WORD_6
        end
    end

    local temp = {}
    table.insert(temp,  tipstr)
    local t = {trans=g.transform,content=temp}



    -- mod_tips.general_tips(t)
end



-- -----------------------------------------列表头像拖动上阵逻辑
function ShouhuStarItem:add_drag2go(go)
    --imgHead添加拖动事件
    local cdb = go:GetComponent(CustomDragButton)
    cdb.onClick:AddListener(function(data)
        self.parent.parent:ShowHelpChangePanel(self.index,1)
    end)
    cdb.onBeginDrag:AddListener(function(data) self:on_begin_drag(data) end)
    cdb.onDrag:AddListener(function(data) self:on_drag(data) end)
    cdb.onEndDrag:AddListener(function(data) self:do_end_drag(data) end)
end

function ShouhuStarItem:on_click_item()
    self.parent:update_right_content(self)
end


function ShouhuStarItem:on_begin_drag(data)
    local cg = self.ImgHead.gameObject:GetComponent(CanvasGroup)
    cg.blocksRaycasts = false
    self:do_clone_action(self.ImgHead.gameObject) --执行克隆
    self.parent.parent:record_drag_item(self)
end

function ShouhuStarItem:on_drag(data)
    local curScreenSpace=Vector3(Input.mousePosition.x*1,Input.mousePosition.y*1,self.screenSpace.z) --执行改变位置
    self.ImgHead.gameObject.transform.position= ctx.UICamera:ScreenToWorldPoint(curScreenSpace)
end

function ShouhuStarItem:do_end_drag(data)
    --销毁拖动对象
    GameObject.Destroy(self.ImgHead.gameObject)
    self.ImgHead = nil
    self.ImgHead = self.clone
    local cg = self.ImgHead.gameObject:GetComponent(CanvasGroup)
    cg.blocksRaycasts = true
    self.parent.parent:switch_tatic_pos(self)
end

--执行克隆逻辑
function ShouhuStarItem:do_clone_action(go)
    self.screenSpace=self.gameObject.transform.position

    --克隆要拖动的对象

    local temp = GameObject.Instantiate(self.ImgHead.gameObject)
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
    self.clone.transform:SetAsLastSibling()

    dragObject_tr:SetParent(self.parent.gameObject.transform) --设置到最顶层容器
    dragObject_rect.anchoredPosition = Vector2(dragObject_rect.anchoredPosition.x,dragObject_rect.anchoredPosition.y - 20)

    --克隆物体添加事件
    self:add_drag2go(self.clone.gameObject)
end