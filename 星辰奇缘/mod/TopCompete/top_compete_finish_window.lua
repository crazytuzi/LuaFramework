TopCompeteFinishWindow = TopCompeteFinishWindow or BaseClass(BaseWindow)

function TopCompeteFinishWindow:__init(model)
    self.name = "TopCompeteFinishWindow"
    self.model = model

    self.windowId = WindowConfig.WinID.top_compete_finish_win

    self.resList = {
        {file = AssetConfig.top_compete_finish_win, type = AssetType.Main}
        , {file = AssetConfig.half_length, type = AssetType.Dep}
    }
    self.is_open = false
    self.list_has_init = false
    self.item_list = nil
    return self
end


local find_item_list = nil
local is = false
function TopCompeteFinishWindow:__delete()
    self.ImgMM.sprite = nil
    self.ImgClasses.sprite = nil

    self.item_list = nil
    self.list_has_init = false
    self.is_open = false
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end


function TopCompeteFinishWindow:InitPanel()
    if self.gameObject ~= nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.top_compete_finish_win))
    self.gameObject.name = "top_compete_finish_win"

    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.main_con = self.transform:FindChild("MainCon")

    local close_btn = self.main_con:FindChild("CloseButton"):GetComponent(Button)
    close_btn.onClick:AddListener(function() self.model:CloseFinishUI() end)


    self.Con_top = self.main_con:FindChild("Con_top")
    self.ImgMM = self.Con_top:FindChild("ImgMM"):GetComponent(Image)

    self.NameCon = self.Con_top:FindChild("NameCon")
    self.TxtName = self.NameCon:FindChild("TxtName"):GetComponent(Text)
    self.ImgClasses = self.NameCon:FindChild("ImgClasses"):GetComponent(Image)
    self.TxtClasses = self.NameCon:FindChild("TxtClasses"):GetComponent(Text)

    self.ScoreCon = self.Con_top:FindChild("ScoreCon")
    self.Con1 = self.ScoreCon:FindChild("Con1")
    self.TxtVal_1 = self.Con1:FindChild("TxtVal"):GetComponent(Text)
    self.Con2 = self.ScoreCon:FindChild("Con2")
    self.TxtVal_2 = self.Con2:FindChild("TxtVal"):GetComponent(Text)
    self.Con3 = self.ScoreCon:FindChild("Con3")
    self.TxtVal_3 = self.Con3:FindChild("TxtVal"):GetComponent(Text)

    self.ImgTanhao = self.ScoreCon:FindChild("ImgTanhao"):GetComponent(Button)

    self.TxtVal_1.text = ""
    self.TxtVal_2.text = ""
    self.TxtVal_3.text = ""
    self.ImgMM.gameObject:SetActive(false)
    self.ImgClasses.gameObject:SetActive(false)

    local key = string.format("half_%s%s", RoleManager.Instance.RoleData.classes, RoleManager.Instance.RoleData.sex)
    self.ImgMM.sprite = self.assetWrapper:GetSprite(AssetConfig.half_length, key)
    self.ImgClasses.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(RoleManager.Instance.RoleData.classes))

    self.ImgMM.gameObject:SetActive(true)
    self.ImgClasses.gameObject:SetActive(true)

    self.TxtName.text = RoleManager.Instance.RoleData.name
    self.TxtClasses.text = KvData.classes_name[RoleManager.Instance.RoleData.classes]


    self.Con_right = self.main_con:FindChild("Con_right")
    self.MaskCon = self.Con_right:FindChild("MaskCon")
    self.ScrollLayer = self.MaskCon:FindChild("ScrollLayer")
    self.Container = self.ScrollLayer:FindChild("Container")

    self.item_con_last_y = self.Container:GetComponent(RectTransform).anchoredPosition.y
    self.vScroll = self.ScrollLayer:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.item_list = {}
    for i=1,15 do
        local go = self.Container:FindChild(tostring(i)).gameObject
        local item = TopCompeteItem.New(go, self)
        table.insert(self.item_list, item)
    end
    self.single_item_height = self.item_list[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.scroll_con_height = self.ScrollLayer:GetComponent(RectTransform).sizeDelta.y

    self.setting_data = {
       item_list = self.item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.Container  --item列表的父容器
       ,single_item_height = self.single_item_height --一条item的高度
       ,item_con_last_y = self.item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }


    self.is_open = true
    self:update_info()

    self.ImgTanhao:GetComponent(Button).onClick:AddListener(function()
        local tips = {}
        table.insert(tips, TI18N("1、自由组5人队伍参与活动，获胜获得<color='#23f0f7'>丰厚奖励</color>"))
        table.insert(tips, TI18N("2、各职业最终得分最高的人可获得<color='#23f0f7'>职业首席</color>的荣誉，队长可以额外获得<color='#23f0f7'>50%</color>得分"))
        table.insert(tips, TI18N("3、最终根据<color='#ffff00'>巅峰积分+本周段位最高分*5%</color>决出各职业首席"))
        TipsManager.Instance:ShowText({gameObject = self.ImgTanhao.gameObject, itemData = tips})
    end)
end

--更新
function TopCompeteFinishWindow:update_info()
    if self.is_open == false then
        return
    end

    if self.model.top_compete_finish_data == nil then
        return
    end

    self.TxtVal_1.text = tostring(self.model.top_compete_finish_data.self_score+math.floor(self.model.top_compete_finish_data.sefl_rank_point*0.05))
    self.TxtVal_2.text = tostring(self.model.top_compete_finish_data.self_score)
    self.TxtVal_3.text = tostring(math.floor(self.model.top_compete_finish_data.sefl_rank_point*0.05))

    -- if self.item_list == nil then
    --     self.item_list = {}
    -- else
    --     for i=1,#self.item_list do
    --         local item = self.item_list[i]
    --         item.gameObject:SetActive(false)
    --     end
    -- end

    -- for i=1,#self.model.top_compete_finish_data.top_compete_role do
    --     local data = self.model.top_compete_finish_data.top_compete_role[i]
    --     local item = self.item_list[i]
    --     if item == nil then
    --         item = TopCompeteItem.New(self.Cloner)
    --         table.insert( self.item_list, item)
    --     end
    --     item.gameObject:SetActive(true)
    --     item:SetData(data, i)
    -- end

    self.setting_data.data_list = self.model.top_compete_finish_data.top_compete_role
    BaseUtils.refresh_circular_list(self.setting_data)
end