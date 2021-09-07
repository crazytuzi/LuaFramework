--author:zzl
--time:2017/2/13
--武道大会战绩

WorldChampionWarRankPanel= WorldChampionWarRankPanel or BaseClass(BasePanel)

function WorldChampionWarRankPanel:__init(parent)
    self.parent = parent
    self.model = parent.model
    self.resList = {
        {file = AssetConfig.worldchampionno1war, type = AssetType.Main}
    }
    self.hasInit = false
    return self
end

function WorldChampionWarRankPanel:__delete()
    self.hasInit = false

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function WorldChampionWarRankPanel:InitPanel()
    -- 星阵tab
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionno1war))
    self.gameObject.name = "WorldChampionWarRankPanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.Main, self.gameObject)
    self.UnOpen = self.transform:FindChild("UnOpen")
    self.MaskCon = self.transform:FindChild("MaskCon")
    self.ScrollLayer = self.MaskCon:FindChild("ScrollLayer")
    self.Container = self.ScrollLayer:FindChild("Container")
    self.item_con_last_y = self.Container:GetComponent(RectTransform).anchoredPosition.y
    self.vScroll = self.ScrollLayer:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.item_list = {}
    for i=1,12 do
        local go = self.Container:FindChild(tostring(i)).gameObject
        local item = WorldChampionWarRankItem.New(go, self)
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
    WorldChampionManager.Instance:Require16428(self.model.shareData.rid, self.model.shareData.platform, self.model.shareData.zone_id)
end

function WorldChampionWarRankPanel:UpdateInfo(data)
    self.setting_data.data_list = data.last_recent
    BaseUtils.refresh_circular_list(self.setting_data)
    if #data.last_recent == 0 then
      self.UnOpen.gameObject:SetActive(true)
      self.MaskCon.gameObject:SetActive(false)
    else
      self.UnOpen.gameObject:SetActive(false)
      self.MaskCon.gameObject:SetActive(true)
    end
end