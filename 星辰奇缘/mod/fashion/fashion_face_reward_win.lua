--时装颜值奖励界面
--2017/2/8
--zzl

FashionFaceRewardWindow  =  FashionFaceRewardWindow or BaseClass(BasePanel)

function FashionFaceRewardWindow:__init(model)
    self.name  =  "FashionFaceRewardWindow"
    self.model  =  model
    self.resList  =  {
        {file = AssetConfig.fashion_facereward, type = AssetType.Main}
    }
    self.is_open = false
    return self
end

function FashionFaceRewardWindow:__delete()
    for i = 1, #self.itemList do
        self.itemList[i]:Release()
    end
    self.is_open  =  false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function FashionFaceRewardWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_facereward))
    self.gameObject:SetActive(false)
    self.gameObject.name = "FashionFaceRewardWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.main = self.transform:FindChild("MainCon")
    self.CloseButton = self.main:FindChild("CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function()
        self.model:CloseFashionFaceRewardUI()
    end)
    self.Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    self.Panel.onClick:AddListener(function()
        self.model:CloseFashionFaceRewardUI()
    end)
    self.MaskCon = self.main:FindChild("MaskCon")
    self.scroll_con = self.MaskCon:FindChild("ScrollLayer")
    self.item_con = self.scroll_con:FindChild("Container")
    self.item_con_last_y = self.item_con:GetComponent(RectTransform).anchoredPosition.y
    self.scroll_con_height = self.scroll_con:GetComponent(RectTransform).sizeDelta.y
    self.vScroll = self.scroll_con:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.itemList = {}
    for i = 1, 12 do
        local go = self.scroll_con:FindChild("Container"):FindChild(tostring(i)).gameObject
        local item = FashionFaceRewardItem.New(go, self)
        table.insert(self.itemList, item)
    end
    self.single_item_height = self.itemList[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.setting_data = {
       item_list = self.itemList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.item_con  --item列表的父容器
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

    self:UpdateInfo()
end

function FashionFaceRewardWindow:UpdateInfo()
    local list = {}
    for k , v in pairs(DataFashion.data_face) do
        if v.classes == RoleManager.Instance.RoleData.classes and #v.gain > 0 then
            table.insert(list, v)
        end
    end
    table.sort( list, function(a,b)
        return a.lev < b.lev
    end)
    self.setting_data.data_list = list
    BaseUtils.refresh_circular_list(self.setting_data)
end