CreateRoleWindow = CreateRoleWindow or BaseClass(BaseWindow)

function CreateRoleWindow:__init(model)
    self.name = "CreateRoleWindow"
    self.model = model

    self.resList =  {
        -- {file = AssetConfig.create_role_desc_small, type = AssetType.Dep}
        -- , {file = AssetConfig.create_role_desc_big, type = AssetType.Dep}
        -- , {file = AssetConfig.create_role_big, type = AssetType.Dep}
        {file = AssetConfig.create_role, type = AssetType.Main}
        , {file = AssetConfig.create_win_bg, type = AssetType.Dep}
        -- , {file = AssetConfig.base_textures, type = AssetType.Dep}
        , {file = AssetConfig.font, type = AssetType.Dep}

        , {file = AssetConfig.createrole_texture, type = AssetType.Dep}
        , {file = AssetConfig.createrole2_texture, type = AssetType.Dep}

        ---------------------add---------------

        , {file = "prefabs/effect/15100.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = "prefabs/effect/15101.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = "prefabs/effect/15102.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = "prefabs/effect/13100.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = "prefabs/effect/13101.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = "prefabs/effect/12100.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = "prefabs/effect/12101.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = "prefabs/effect/11100.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = "prefabs/effect/11101.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = "prefabs/effect/11102.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = "prefabs/effect/11103.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = "prefabs/effect/14100.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = "prefabs/effect/14101.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = "prefabs/effect/14100.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = "prefabs/effect/17100.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = "prefabs/effect/17101.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = "prefabs/effect/18100.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = "prefabs/effect/18101.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = "prefabs/effect/18102.unity3d", type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}

    }


    ---------------------add---------------
    self.itemList = {}

    self.totalCountClasses = 7   --总职业个数

    self.current_model_id = 51002 --当前模型id，默认是女的，狂剑
    self.current_classes = 1 --当前职业类型，默认是狂剑
    self.current_hair_id = 50002 --当前模型id，默认是女的，狂剑
    self.current_selected_item = nil
    self.current_sex = 0 --当前的角色性别,默认是女
    self.girl = {51002,51004,51006,51008,51010,51012,51014} --男女的模型id
    self.boy = {51001,51003,51005,51007,51009,51011,51013}
    self.has_input_self_name = false
    self.last_ad = nil

    self.maleSound = {204, 208, 212, 210, 206, 206, 206}
    self.femaleSound = {205, 209, 212, 210, 206, 206, 206}

    self.maleTalkSound = {300, 310, 320, 330, 340, 350, 360}
    self.femaleTalkSound = {301, 311, 321, 331, 341, 351, 361}

    self.endTimes = nil
    self.timer_1 = nil
    self.timer_2 = nil

    self.effect = nil
    self.fps = nil
    self.timerId = 0

    self.coldClick = true

    self.textListener = function(fromId, actionType, text) self:OnTextInput(fromId, actionType, text) end
    self.has_init = false
    return self
end

function CreateRoleWindow:__delete()

    ---------------------add---------------
    self:OnHide()

    self.MainBg.sprite = nil
    self.img_small_desc.sprite = nil
    self.img_big_desc.sprite = nil


    self.has_init = false
    -- 记得这里销毁
    EventMgr.Instance:RemoveListener(event_name.input_dialog_callback, self.textListener)
    if self.previewComp1 ~= nil then
        self.previewComp1:DeleteMe()
        self.previewComp1 = nil
    end

    self:stop_timer_2()

    if self.timer_1 ~= 0 and self.timer_1 ~= nil then
        LuaTimer.Delete(self.timer_1)
        self.timer_1 = nil
    end

    self.effect = nil
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil

    self.assetwrapper = nil

    self:AssetClearAll()
    -- LuaTimer.Delete(self.timerId)

end

function CreateRoleWindow:InitPanel()
    if self.gameObject ~= nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.create_role))
    self.gameObject.name = "create_role"
    self.gameObject.transform:SetParent(ctx.CanvasContainer.transform)
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject:GetComponent(Canvas).sortingOrder = 25

    self.gameObject:GetComponent(Canvas).worldCamera = ctx.UICamera
    self.transform = self.gameObject.transform

    ---------------------addBOY---------------
    self.scroll = self.transform:FindChild("Scroll"):GetComponent(ScrollRect)
    self.cloner = self.scroll.transform:FindChild("Cloner").gameObject
    self.container = self.scroll.transform:FindChild("Container")

    self.pageController = self.scroll.gameObject:AddComponent(PageTabbedController)
    self.pageController.onUpEvent:AddListener(function() self:OnUp() end)
    self.pageController.onEndDragEvent:AddListener(function() self:OnUp() end)

    local layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0})

   for i = 1,self.totalCountClasses * 3 do
        self.itemList[i] = CreateRoleAdditionItem.New(self.model,GameObject.Instantiate(self.cloner),self)
        self.itemList[i].assetWrapper = self.assetWrapper
        layout:AddCell(self.itemList[i].gameObject)
        self.itemList[i].clickCallback = function(index) if self.coldClick then
                                                self.coldClick = false
                                                self:OnClick_SetInfo(index)
                                                self:TweenTo(index - 3 )
                                            end
                                        end
    end

    self.cloner:SetActive(false)
    layout:DeleteMe()

    self.setting_data = {
       item_list = self.itemList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.cloner:GetComponent(RectTransform).sizeDelta.y --一条item的高度
       ,item_con_last_y = self.container:GetComponent(RectTransform).anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll:GetComponent(RectTransform).rect.height --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.scroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting_data) self:UpdatePos() end)






    self.MainBg = self.transform:FindChild("MainBg"):GetComponent(Image)
    self.MainBg.sprite = self.assetWrapper:GetSprite(AssetConfig.create_win_bg, "CreateWinBg")

    self.model_preview_container= self.transform:FindChild("Preview").gameObject

    -- local ctrl = self.model_preview_container.gameObject:AddComponent(ModelPreBridge)
    -- ctrl.luaPath = "common/create_role_preview_ctrl"
    -- ctrl.className = "CreateRolePreviewController"
    -- ctrl:CheckInit()


    -- local renderTexture = ctx.ResourcesManager:GetRanderTexture(AssetConfig.modelpreview_rendertexture)
    -- renderTexture:Release()
    -- renderTexture.width = 1280
    -- renderTexture.height = 1280
    -- mod_login.create_role_camera:GetComponent(Camera).targetTexture = renderTexture

    self.desc_con=self.transform:FindChild("DescCon").gameObject
    self.img_small_desc=self.desc_con.transform:FindChild("ImgSmall"):GetComponent(Image)
    self.img_big_desc = self.desc_con.transform:FindChild("ImgBig"):GetComponent(Image)
    self.BtnReturn = self.transform:FindChild("BtnReturn"):GetComponent(Button)

    self.item_con=self.transform:FindChild("ItemCon").gameObject

    self.bottom_con= self.transform:FindChild("BottomCon").gameObject
    self.input_con = self.bottom_con.transform:FindChild("InputCon").gameObject
    self.input_name = self.input_con.transform:FindChild("InputField"):GetComponent(InputField)
    self.input_name.textComponent = self.input_name.transform:FindChild("Text"):GetComponent(Text)

    self.btn_boy = self.transform:FindChild("BtnBoy"):GetComponent(Button)
    self.btn_girl = self.transform:FindChild("BtnGirl"):GetComponent(Button)

    -- self.input_name.characterLimit = 6--CreateRoleManager.NameLimitLength
    self.current_selected_item = nil
    self.has_init_desc = false

    local on_end_edit = function ()
        self:on_end_edit()
    end
    self.input_name.onEndEdit:AddListener(on_end_edit)

    if VersionCheck.FontContainChar() then
        self.font = self.input_name.textComponent.font
        -- self.input_name.onValueChange:AddListener(function(msg) self:OnChange(msg) end)
    end

    self.input_name.text = TI18N("请输入名字") --TI18N("请输入名字")
    self.btn_sezi = self.bottom_con.transform:FindChild("BtnSeZi"):GetComponent(Button)
    self.btn_enter_game = self.bottom_con.transform:FindChild("BtnEnterGame"):GetComponent(Button)

    if BaseUtils.CustomKeyboard() then
        -- 文字输入框
        self.input_name.enabled = false
        self.input_con:GetComponent(Button).onClick:AddListener(function() self:OpenInputDialog() end)
        EventMgr.Instance:AddListener(event_name.input_dialog_callback, self.textListener)
    else
        self.input_name.enabled = true
    end


    self.BtnReturn.onClick:AddListener(function()
        LoginManager.Instance:returnto_login(true)
        --
    end)

    self.btn_boy.transform:GetComponent(Button).onClick:AddListener(function() self:on_sex_btn_click(self.btn_boy) end)
    self.btn_girl.transform:GetComponent(Button).onClick:AddListener(function() self:on_sex_btn_click(self.btn_girl) end)


    self.btn_sezi.transform:GetComponent(Button).onClick:AddListener(function()
        self:on_build_random_name(self.btn_sezi) end)
    self.btn_enter_game.transform:GetComponent(Button).onClick:AddListener(function() self:on_enter_game() end)

    self.has_init = true

    self:OnShow()

    BaseUtils.NewPlayerImport(KvData.newPlayerImportStepType.create_role, LoginManager.Instance.curPlatform)
end

function CreateRoleWindow:OnShow()
    --初次加载
    self:Reload()
end


function CreateRoleWindow:OnHide()
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
end

-- 加载信息
function CreateRoleWindow:Reload()
    local datalist = {}

    for i=1,self.totalCountClasses * 3 do
        table.insert(datalist, {id = i, isEmpty = false, unknown = false})
    end

    self.setting_data.data_list = datalist
    BaseUtils.refresh_circular_list(self.setting_data)

    --第一次更新初始化
    self:update_head()
    -- 更新位置
    self:UpdatePos()
end

-- 椭圆位置更新
function CreateRoleWindow:UpdatePos()
    local y = nil
    local res = nil

    -- 运动轨迹是椭圆，设坐标原点是左上角，然后标准方程是(x + 123)^2 / 250^2 + (y + 210)^2 / 296.5^2 = 1
    for i,v in ipairs(self.itemList) do
        y = v.transform.anchoredPosition.y + self.container.anchoredPosition.y - v.transform.sizeDelta.y / 2

        res = 1 - ((y + 210)*(y + 210) / (296.5*296.5))
        if res >= 0 then
            v.item.anchoredPosition = Vector2(math.sqrt(res) * 250 - 123 - 138.25 - 11, 0)
            --v:SetScale(1 - (y + 210) * (y + 210) * (1 - 0.6)/44100)
            local value = (1 - (y + 210) * (y + 210) * (1 - 0.5)/44100) - 0.2

            if value < 0.72 then
                value = 0.72
            end
            v:SetScale( value )

        end
    end
end

-- 点击转到
function CreateRoleWindow:TweenTo(index)

    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
    end
    self.tweenId = Tween.Instance:ValueChange(self.container.anchoredPosition.y, 84 * index, 0.5,
        function()
            self.tweenId = nil
            self.coldClick = true
            -------------设置container位置------------------
            self:SetContainerPos(self.container.anchoredPosition.y)
        end
        , LeanTweenType.easeOutQuart,
        function(value)
            self.container.anchoredPosition = Vector2(0, value)
        end).id
end

-- 翻页转到
function CreateRoleWindow:OnUp()

    local y = self.container.anchoredPosition.y
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
    end
    self.tweenId = Tween.Instance:ValueChange(y, 84 * math.ceil(math.floor(y * 2 / 84) / 2), 0.5,
        function()
            self.tweenId = nil
            ----------------------------------翻页时更新位置
            self:SetContainerPos(self.container.anchoredPosition.y)
            ------------------tag-------------翻页时更新数据
            self:OnPage_SetInfo(self.container.anchoredPosition.y)
        end
        , LeanTweenType.easeOutQuart,
        function(value)
            self.container.anchoredPosition = Vector2(0, value)
        end).id
end

    --将条目设置成准确位置
function CreateRoleWindow:SetContainerPos(y)
    local index = math.floor((y - 42) / 84) + 1  + 3

    --根据不同的序号重置条目
    local temp = index
    if temp < self.totalCountClasses + 1  then
        temp = temp +  self.totalCountClasses
    elseif temp > self.totalCountClasses * 2 then
        temp = temp - self.totalCountClasses
    end

    --设置位置
    self.container.anchoredPosition = Vector2(0, 84*(temp - 3))

end


--  翻页更新数据
function CreateRoleWindow:OnPage_SetInfo(y)
    --计算出停留的位置
    local index = math.floor((y - 42) / 84) + 1  + 3

    --根据停留的位置得到当前的职业序号
    local classes = index % self.totalCountClasses
    if classes == 0 then
        classes = self.totalCountClasses
    end
    self:UpdateInfo(classes)
end

--  点击更新数据
function CreateRoleWindow:OnClick_SetInfo(index)
    local classes = index % self.totalCountClasses
    if classes == 0 then
        classes = self.totalCountClasses
    end
    self:UpdateInfo(classes)
end

    --初始化更新信息
function CreateRoleWindow:update_head()
    local temp = self.totalCountClasses - 1

    --随机当前职业
    local index = Random.Range(1,temp+1)
    self.current_classes = math.floor(index)

    --随机当前性别
    local sex_probability =Random.Range(1, 100)
    if sex_probability >= 1 and sex_probability <= 40 then --男的 40%
        self.current_sex = 1
     else  --女  60%
        self.current_sex = 0
     end

    ----------------更新信息 / 跳转位置-------------

     --更新Sex按钮的状态
    self:UpdateSexState()

    --更新Item图标
    self:UpdateItemIcon()

    --随机初始化名字
    if self.has_input_self_name == false then
        self:on_build_random_name(nil)
    end

    self:UpdateInfo(self.current_classes)

    self:TweenTo(self.current_classes + self.totalCountClasses - 3)
end

    --更新信息
function CreateRoleWindow:UpdateInfo(classes)

    --点击相同的Item
    -- if item == self.current_selected_item then
    --     return
    -- end

    --根据职业序号 ，  得到当前模型id
    local model_list = {}
    if self.current_sex == 0 then -- 女
        model_list = self.girl
    else -- 男
        model_list = self.boy
    end
    self.current_model_id = model_list[classes]


    -- 将上次的选中条目置为非选中
    if self.current_selected_item ~= nil then
        local img_selected = self.current_selected_item.transform:FindChild("Item/Selected"):GetComponent(Image)
        img_selected.gameObject:SetActive(false)
    end

    --将更新后的item 、 设置为当前点中的Item
    self.current_selected_item = self.itemList[classes + self.totalCountClasses]
    self.current_classes = classes


    --将新选中的RoleItem设置为选中状态
    local img_selected = self.current_selected_item.transform:FindChild("Item/Selected"):GetComponent(Image)
    img_selected.gameObject:SetActive(true)


    --更新模型
    self:update_model()
    --更新描述
    self:do_update_left(self.current_classes) --更新左边职业描述
end






-------------------------------------------各种监听器
--请求进入游戏
function CreateRoleWindow:on_enter_game()
    if self.input_name.text == TI18N("请输入角色名") or self.input_name.text == "" then
        -- mod_notify.append_scroll_win("请输入角色名") --TI18N("请输入角色名")
        -- mod_notify.append_scroll_win("没有notify，暂时先打印,请输入角色名")
        return
    end

    if ctx.PlatformChanleId == 110 then
       local msg = self.input_name.text
         -- 暂时只有乐视渠道处理过滤
         msg = MessageFilter.Parse(self.input_name.text)
         if msg ~= self.input_name.text then
           NoticeManager.Instance:FloatTipsByString(TI18N("名字存在不和谐词汇，换个试试吧"))
           return
       end
   end

    local strList = StringHelper.ConvertStringTable(self.input_name.text)
    if #strList > 6 then
        NoticeManager.Instance:FloatTipsByString(TI18N("名称长度最多6个字"))
        return
    end

    CreateRoleManager.Instance:do_create_role(self.input_name.text,self.current_sex, self.current_classes) --self.current_classes)
end

function CreateRoleWindow:on_click_input()
    if self.input_name.text == TI18N("请输入名字") then
        self.input_name.text = ""
        self.input_name.textComponent.color = Color(199/255, 249/255, 255/255)
    end
end

function CreateRoleWindow:on_end_edit(temp)
    if temp == "" then
        self.input_name.text = TI18N("请输入角色名") --TI18N("请输入名字")
        self.has_input_self_name = false
    else
        self.has_input_self_name = true
        if VersionCheck.FontContainChar() then
            self:OnChange(self.input_name.text)
        end
    end
end

function CreateRoleWindow:OnChange(msg)
    local str = ""
    local list = StringHelper.ConvertStringTable(msg)
    local change = false
    for i,v in ipairs(list) do
        if Utils.HasCharacter(self.font, v) then
            str = str .. v
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("特殊字符无法显示，请修改"))
            change = true
        end
    end

    if change then
        self.input_name.text = str
    end
end






--性别按钮点击事件
function CreateRoleWindow:on_sex_btn_click(btn)

    --屏蔽重复点击
    if btn == self.current_sex_btn then
        return
    end

    self.current_sex_btn = btn
    if btn == self.btn_boy then
        self.current_sex = 1
    elseif btn == self.btn_girl then
        self.current_sex = 0
    end

    --更换性别按钮状态
    self:UpdateSexState()

    --更换item图标
    self:UpdateItemIcon()

    --更新新的模型
    self:update_model()

    --默认初始化一个名字
    if self.has_input_self_name == false then
        self:on_build_random_name(nil)
    end
end

--更换性别按钮的状态
function CreateRoleWindow:UpdateSexState()

    local btnboy = self.transform:FindChild("BtnBoy"):GetComponent(Image)
    local btngirl = self.transform:FindChild("BtnGirl"):GetComponent(Image)

    if self.current_sex == 1 then
        btnboy.sprite = self.assetWrapper:GetSprite(AssetConfig.createrole_texture, "CreateSexWithGou")
        btngirl.sprite = self.assetWrapper:GetSprite(AssetConfig.createrole_texture, "CreateSexBase")

        btnboy.transform:FindChild("ImgSex"):GetComponent(RectTransform).anchoredPosition = Vector2(-8.21, 0)
        btngirl.transform:FindChild("ImgSex"):GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)

    elseif self.current_sex == 0 then
        btngirl.sprite = self.assetWrapper:GetSprite(AssetConfig.createrole_texture, "CreateSexWithGou")
        btnboy.sprite = self.assetWrapper:GetSprite(AssetConfig.createrole_texture, "CreateSexBase")

        btnboy.transform:FindChild("ImgSex"):GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)
        btngirl.transform:FindChild("ImgSex"):GetComponent(RectTransform).anchoredPosition = Vector2(-8.21, 0)
    end

    btnboy:SetNativeSize()
    btngirl:SetNativeSize()
end


--更换Item的图标
function CreateRoleWindow:UpdateItemIcon()
    local model_ids = nil
    if self.current_sex == 1 then
        model_ids = self.boy
    elseif self.current_sex == 0 then
        model_ids = self.girl
    end

    for i=1, #self.itemList do
        local item = self.itemList[i]

        local tempI = i
        tempI = tempI % self.totalCountClasses
        if tempI == 0 then
            tempI = self.totalCountClasses
        end

        item.transform:FindChild("Item/Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.createrole2_texture, string.format("%s", model_ids[tempI]))
        item.transform:FindChild("Item/Icon"):GetComponent(Image):SetNativeSize()

    end
end


--创建名字
function CreateRoleWindow:on_build_random_name(g)
    if g ~= nil then
        self.has_input_self_name = false
    end

    self.input_name.text = self:get_random_name(self.current_sex)
    self.input_name.textComponent.color = Color(199/255, 249/255, 255/255)
end

--传入性别，随机生成一个名字
function CreateRoleWindow:get_random_name(current_sex)
    local first_name_index = Random.Range(1,  DataRandomName.data_create_role_random_name_length)
    first_name_index = math.floor(first_name_index)
    local sec_name_index = Random.Range(1, DataRandomName.data_create_role_random_name_length)
    sec_name_index = math.floor(sec_name_index)
    local first_name = DataRandomName.data_create_role_random_name[first_name_index].surname
    local sec_name = DataRandomName.data_create_role_random_name[sec_name_index]
    if self.current_sex == 0 then --女
        return first_name..sec_name.woman1
    else --男
        return first_name..sec_name.male1
    end
end




--传入职业设置左边职业描述
function CreateRoleWindow:do_update_left(classes)

    if self.has_init_desc == true then
        local tween_alpha_callback = function()
            self:desc_fade_finish()
        end
        Tween.Instance:Alpha(self.img_small_desc.rectTransform, 0, 0.2, tween_alpha_callback)
        Tween.Instance:Alpha(self.img_big_desc.rectTransform, 0, 0.2, tween_alpha_callback)
    else
        self.img_small_desc.sprite = self.assetWrapper:GetSprite(AssetConfig.createrole_texture, string.format("Desc%s", classes))
        self.img_big_desc.sprite = self.assetWrapper:GetSprite(AssetConfig.createrole_texture, tostring(classes))

        self.img_small_desc:SetNativeSize()
        self.img_small_desc.gameObject:SetActive(true)

        self.img_big_desc:SetNativeSize()
        self.img_big_desc.gameObject:SetActive(true)

        self.has_init_desc = true
    end
end

function CreateRoleWindow:desc_fade_finish()
    self.img_small_desc.sprite = self.assetWrapper:GetSprite(AssetConfig.createrole_texture, string.format("Desc%s", self.current_classes))
    self.img_small_desc:SetNativeSize()
    Tween.Instance:Alpha(self.img_small_desc.rectTransform, 1, 0.2)

    self.img_big_desc.sprite = self.assetWrapper:GetSprite(AssetConfig.createrole_texture, tostring(self.current_classes))
    self.img_big_desc:SetNativeSize()
    Tween.Instance:Alpha(self.img_big_desc.rectTransform, 1, 0.2)
end











--更新守护模型
function CreateRoleWindow:update_model()
    local weapon = self:get_weapon()

    local _looks = {}
    table.insert(_looks, {looks_type=SceneConstData.looktype_weapon, looks_val=weapon, looks_mode = 0})
    table.insert(_looks, {looks_type=SceneConstData.looktype_dress, looks_val= self.current_model_id, looks_mode = 0})

    local previewComp = nil
    local callback = function(composite)
        self:on_model_build_completed(composite)
    end
    local setting = {
        name = "CreateRole"
        ,orthographicSize = 0.75
        ,width = 682
        ,height = 540
        ,offsetY = -0.4
    }

    -- ---------------------------
    --local modelData = {type = PreViewType.Role, classes = self.current_classes, sex = self.current_sex, looks = _looks}
    local modelData = {type = PreViewType.Role, classes = self.current_classes, sex = self.current_sex, looks = _looks}
    if self.previewComp1 == nil then
        self.previewComp1 = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp1:Reload(modelData, callback)
    end
end

--守护模型加载完成
function CreateRoleWindow:on_model_build_completed(composite)

    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.model_preview_container.transform)
    rawImage.transform.localScale = Vector3(1, 1, 1)

    self.last_tpose = composite.tpose
    self.last_tpose.transform.localScale = Vector3(1,1,1)
    self.last_ad = composite.animationData
    self.animator = self.last_tpose:GetComponent(Animator)
    self.animator.cullingMode = AnimatorCullingMode.AlwaysAnimate

    self.model_preview_container.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, 120)

    ----翅膀逻辑
    -- local wing_id = 20000 --男翅膀
    -- if self.current_sex == 0 then
    --     wing_id = 20001 --女翅膀
    -- end

    -- local wing_cfg_data = data_wing.data_base[wing_id]
    -- wing_tpose_loader.New(wing_cfg_data.map_id, wing_cfg_data.model_id, wing_cfg_data.act_id, 1, CreateRoleWindow:build_wing_callback)


    self.animator.cullingMode = AnimatorCullingMode.AlwaysAnimate
    self:PlayModelAction()

     local targetList = nil
     if self.current_sex == 0 then --女
         targetList = self.model.femaleEffectList
     else
         targetList = self.model.maleEffectList
     end
     for i=1,#targetList do
        local ed = targetList[i]
         if ed.Classes == self.current_classes then
             self:fight_effect(ed)
         end
     end
end

--得到武器模型序号
function CreateRoleWindow:get_weapon()
    if self.current_classes == 1 then
        return 10005  --狂剑
    elseif self.current_classes == 2 then
        return 10102  --魔导
    elseif self.current_classes == 3 then
        return 10203  -- 战弓
    elseif self.current_classes == 4 then
        return 10304  --兽灵
    elseif self.current_classes == 5 then
        return 10405  --秘言
    elseif self.current_classes == 6 then
        return 10506  --月魂
    end
    return 10701  --圣骑
end

--翅膀逻辑
function CreateRoleWindow:build_wing_callback(wingtpose, animationData)
    if utils.is_null(self.last_tpose) == false then
        --绑上翅膀d
        local path = BaseUtils.GetChildPath(self.last_tpose.transform, "bp_wing")
        local bind = self.last_tpose.transform:Find(path)
        local t = wingtpose:GetComponent(Transform)
        t:SetParent(bind)
        t.localPosition = Vector3(-0.08, 0, 0)
        t.localRotation = Quaternion.identity
        t:Rotate(Vector3(90, 270, 0))
        t.localScale = Vector3(1, 1, 1)
        t:ChangeLayersRecursively("Model")
    end
end


function CreateRoleWindow:star_timer_2()
    local state_id = BaseUtils.GetShowActionId(self.current_classes, self.current_sex)
    self.animator:Play(tostring(state_id))

    self.timer_1 = LuaTimer.Add(100, function () self:ActionDelay() end)

    local sound_id = 0
    local talk_id = 0
    if self.current_sex == 0 then --女
        sound_id = self.femaleSound[self.current_classes]
        talk_id = self.femaleTalkSound[self.current_classes]
    else
        sound_id = self.maleSound[self.current_classes]
        talk_id = self.maleTalkSound[self.current_classes]
    end
    SoundManager.Instance:Play(sound_id, true)
    SoundManager.Instance:PlayCombatHiter(talk_id, true)
end

function CreateRoleWindow:ActionDelay()
    local delay = self.animator:GetCurrentAnimatorStateInfo(0).length
    self.timer_2 = LuaTimer.Add(delay*1000, function() self:model_tick_end_callback() end)
end

function CreateRoleWindow:stop_timer_2()
    if self.timer_2 ~= 0 and self.timer_2 ~= nil then
        LuaTimer.Delete(self.timer_2)
        self.timer_2 = nil
    end
end

---模型动作逻辑
-- 创建角色界面播放模型动作
function CreateRoleWindow:PlayModelAction()
    self:stop_timer_2()

    -- if self.current_sex == 0 then -- 女的
    --     self.endTimes = self.femaleShowTimes
    -- else --男
    --     self.endTimes = self.maleShowTimes
    -- end

    -- local endTime = 0
    -- if self.current_classes == 1 then--狂剑
    --     endTime = self.endTimes[1]
    -- elseif self.current_classes == 2 then--魔导
    --     endTime = self.endTimes[2]
    -- elseif self.current_classes == 3 then--战弓
    --     endTime = self.endTimes[3]
    -- elseif self.current_classes == 4 then--兽灵
    --     endTime = self.endTimes[4]
    -- elseif self.current_classes == 5 then--密言
    --     endTime = self.endTimes[5]
    -- end

    if self.current_classes == 1 then--狂剑
        self:star_timer_2()
    else
        self:star_timer_2()
    end
end

--狂剑模型动作回调
function CreateRoleWindow:model_tick_end_gladiator()
    self:star_timer_2()
end

--其他模型动作
function CreateRoleWindow:model_tick_end_callback()
    if self.has_init == false then
        return
    end
    self.timer_2 = id
    self:stop_timer_2()

    if self.last_ad ~= nil and self.last_ad.stand_id ~= nil then
        if BaseUtils.isnull(self.animator) then
            return
        end
        self.animator:Play(string.format("Stand%s", self.last_ad.stand_id))
    end
end

-- 动作特效逻辑
local effectList = {}
function CreateRoleWindow:fight_effect(effectObjectData)
    local attackPos = self.last_tpose.transform.position

    local attackTransform = self.last_tpose.transform
    local tempStr = "prefabs/effect/%s.unity3d"
    tempStr = string.format(tempStr, tostring(effectObjectData.EffectId))

    local effect = self:GetPrefab(tempStr)

    if effect == nil then
        -- mod_notify.append_scroll_win(string.format("缺少特效资源:%s",tostring(effectObjectData.EffectId)))
    end

    local effectObject = GameObject.Instantiate(effect)
    table.insert(effectList, effectObject)

    if effectObjectData.type == 0 then
        return
    end
    if effectObjectData.EffectTargetPoint == EffectTargetPoint.Weapon then
        self:bind_weapon(self.last_tpose, effectObject,effectObjectData.Classes)
    elseif effectObjectData.EffectTargetPoint == EffectTargetPoint.Origin  then
        effectObject.transform:SetParent(attackTransform)
    elseif effectObjectData.EffectTargetPoint == EffectTargetPoint.LHand  then
        self:bind_hand(self.last_tpose, effectObject,effectObjectData.Classes)
    elseif effectObjectData.EffectTargetPoint == EffectTargetPoint.RHand then
        self:bind_hand(self.last_tpose, effectObject,effectObjectData.Classes)
    elseif effectObjectData.EffectTargetPoint == EffectTargetPoint.LWeapon then
        self:bind_left_weapon(self.last_tpose, effectObject,effectObjectData.Classes)
    elseif effectObjectData.EffectTargetPoint == EffectTargetPoint.RWeapon then
        self:bind_right_weapon(self.last_tpose, effectObject,effectObjectData.Classes)
    else
        effectObject.transform:SetParent(attackTransform)
    end

    effectObject.transform.localScale = Vector3(1, 1, 1)
    effectObject.transform.localPosition = Vector3(0, 0, 0)
    effectObject.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(effectObject.transform, "ModelPreview")
    effectObject:SetActive(true)
end

--绑左武器
function CreateRoleWindow:bind_left_weapon(bind, effect, classes)
    local attackTransform = bind.transform:FindChild("tpose") == nil and bind.transform or bind.transform:FindChild("tpose").transform
    local weaponPoint = ""
    weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_L_Weapon")
    effect.transform:SetParent(attackTransform:Find(weaponPoint))
end

function CreateRoleWindow:bind_right_weapon(bind, effect, classes)
    local attackTransform = bind.transform:FindChild("tpose") == nil and bind.transform or bind.transform:FindChild("tpose").transform
    local weaponPoint = ""
    weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_R_Weapon")
    effect.transform:SetParent(attackTransform:Find(weaponPoint))
end

--绑武器
function CreateRoleWindow:bind_weapon(bind, effect, classes)
    local attackTransform = bind.transform:FindChild("tpose") == nil and bind.transform or bind.transform:FindChild("tpose").transform
    local weaponPoint = ""
    if classes == 1 then

    elseif classes == 4 then
        local leffect = GameObject.Instantiate(effect)
        table.insert(effectList, leffect)
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_R_Weapon")
        effect.transform:SetParent(attackTransform:Find(weaponPoint))
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_L_Weapon")
        leffect.transform:SetParent(attackTransform:Find(weaponPoint))
        leffect.transform.localPosition = Vector3.zero
        leffect.transform.localRotation = Quaternion.identity
        leffect.transform.localScale = Vector3(1.0,1.0,1.0)
    elseif classes == 3 then

    elseif classes == 7 then

    elseif classes == 5 then
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_L_Weapon")
        effect.transform:SetParent(attackTransform:Find(weaponPoint))
    else
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_R_Weapon")
        effect.transform:SetParent(attackTransform:Find(weaponPoint))
    end
end

--绑手
function CreateRoleWindow:bind_hand(bind, effect, classes)
    local attackTransform = bind.transform:FindChild("tpose") == nil and bind.transform or bind.transform:FindChild("tpose").transform
    local weaponPoint = ""
    if classes == 1 then

    elseif classes == 4 then
        local leffect = GameObject.Instantiate(effect)
        table.insert(effectList, leffect)
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_R_Hand")
        effect.transform:SetParent(attackTransform:Find(weaponPoint))
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_L_Hand")
        leffect.transform:SetParent(attackTransform:Find(weaponPoint))
        leffect.transform.localPosition = Vector3.zero
        leffect.transform.localRotation = Quaternion.identity
        leffect.transform.localScale = Vector3(1.0,1.0,1.0)
    elseif classes == 3 then

    elseif classes == 7 then

    elseif classes == 5 then
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_L_Hand")
        effect.transform:SetParent(attackTransform:Find(weaponPoint))
    else
        weaponPoint = BaseUtils.GetChildPath(attackTransform,"Bip_R_Hand")
        effect.transform:SetParent(attackTransform:Find(weaponPoint))
    end
end

-- 打开输入框
function CreateRoleWindow:OpenInputDialog()
    self.tempInput = self.input_name.text
    self.input_name.text = ""

    local width = 200 * (ctx.ScreenWidth / 960) -- 同上
    local fontSize = BaseUtils.FontSize(20)
    local cpos = BaseUtils.ConvertPosition(self.input_name.gameObject.transform.position)
    local x = (ctx.ScreenWidth - width) / 2

    local scaleWidth = ctx.ScreenWidth
    local scaleHeight = ctx.ScreenHeight
    local localRate = scaleWidth / scaleHeight
    local y = cpos.py - (ctx.ScreenHeight * 2 / 3) * localRate / (960 / 540)
    SdkManager.Instance:ShowInputDialogWhite(GlobalEumn.InputFormId.CreateRole, GlobalEumn.ShowType.Normal, x, y, fontSize, GlobalEumn.GravityType.Center, width, self.tempInput)
end

function CreateRoleWindow:OnTextInput(fromId, actionType, text)
    if tonumber(fromId) ~= GlobalEumn.InputFormId.CreateRole then
        return
    end
    self.input_name.text = tostring(text)
    -- if tostring(text) ~= "" then
    --     if tonumber(actionType) == GlobalEumn.InputCallbackType.ClickReturn then
    --         -- 点击回车回调
    --         self:SendMsg()
    --     elseif tonumber(actionType) == GlobalEumn.InputCallbackType.ClickBlank then
    --         -- 点击空白回调
    --     end
    -- end
end
