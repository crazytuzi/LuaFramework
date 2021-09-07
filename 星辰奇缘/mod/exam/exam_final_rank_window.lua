-- zzl
-- 2016/7/6
ExamFinalRankWindow  =  ExamFinalRankWindow or BaseClass(BaseWindow)

function ExamFinalRankWindow:__init(model)
    self.name  =  "ExamFinalRankWindow"
    self.model  =  model

    -- 缓存
    self.cacheMode = CacheMode.Visible
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.exam_final_rank_win, type  =  AssetType.Main}
    }

    self.has_init = false
    return self
end


function ExamFinalRankWindow:__delete()
    self.has_init = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function ExamFinalRankWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.exam_final_rank_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "ExamFinalRankWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)


    self.transform:GetComponent(RectTransform).localPosition = Vector3.zero

    self.mainCon = self.gameObject.transform:Find("Main")
    local closeBtn = self.gameObject.transform:Find("Main/Close"):GetComponent(Button)
    closeBtn.onClick:AddListener(function()
        self.model:CloseFinalExamRankUI()
    end)


    self.RankPanel = self.mainCon:Find("RankPanel")

    self.TitleBar = self.RankPanel:Find("TitleBar")
    self.TitleLev = self.TitleBar:Find("Lev"):GetComponent(Text)
    self.TitleLev.text = ""

    self.MyScore = self.RankPanel:Find("MyScore")
    self.MyScore.gameObject:SetActive(false)
    self.RankTxt = self.MyScore:Find("Rank"):GetComponent(Text)
    self.RankImg = self.MyScore:Find("Rank"):Find("Image"):GetComponent(Image)
    self.Character = self.MyScore:Find("Character")
    self.Icon = self.Character:Find("Icon")
    self.ImgHead = self.Icon:Find("ImgHead"):GetComponent(Image)

    self.Name = self.Character:Find("Name"):GetComponent(Text)

    self.Lev = self.MyScore:Find("Lev"):GetComponent(Text)
    self.Job = self.MyScore:Find("Job"):GetComponent(Text)
    self.Floor = self.MyScore:Find("Floor"):GetComponent(Text)

    self.MaskCon = self.RankPanel:Find("MaskCon")
    self.ScrollCon = self.MaskCon:Find("ScrollCon")
    self.Container = self.ScrollCon:Find("Container")

    self.rank_item_list = {}
    for i=1,10 do
        local go = self.Container:Find(tostring(i)).gameObject
        local item = ExamFinalRankListItem.New(go, self)
        go:SetActive(false)
        table.insert(self.rank_item_list, item)
    end
    self.single_item_height = self.rank_item_list[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.item_con_last_y = self.Container:GetComponent(RectTransform).anchoredPosition.y
    self.scroll_con_height = self.ScrollCon:GetComponent(RectTransform).sizeDelta.y

    self.setting_data = {
       item_list = self.rank_item_list--放了 item类对象的列表
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

    self.vScroll = self.ScrollCon:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)

     self.has_init = true
    ExamManager.Instance:request14512()

    -- self:update_info()
end


function ExamFinalRankWindow:update_info()
    if  self.has_init == false then
        return
    end
    self.setting_data.data_list = self.model.cur_final_rank_list
    BaseUtils.refresh_circular_list(self.setting_data)

    local hasMySelf = false
    for i=1,#self.model.cur_final_rank_list do
        local temp_data = self.model.cur_final_rank_list[i]
        if temp_data.rid == RoleManager.Instance.RoleData.id and temp_data.platform == RoleManager.Instance.RoleData.platform and temp_data.zone_id == RoleManager.Instance.RoleData.zone_id then
            hasMySelf = true
            if i == 1 then
                self.RankImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "iconFirst")
                self.RankImg.gameObject:SetActive(true)
                self.RankTxt.text = ""
            elseif i == 2 then
                self.RankImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "iconsecond")
                self.RankImg.gameObject:SetActive(true)
                self.RankTxt.text = ""
            elseif i == 3 then
                self.RankImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "iconthree")
                self.RankImg.gameObject:SetActive(true)
                self.RankTxt.text = ""
            else
                if i <= 100 then
                    self.RankTxt.text = tostring(i)
                else
                    self.RankTxt.text = TI18N("榜外")
                end
            end


            self.ImgHead.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads , string.format("%s_%s",tostring(temp_data.classes),tostring(temp_data.sex)))
            self.ImgHead.gameObject:SetActive(true)
            self.Name.text = temp_data.name
            self.Lev.text = "" --tostring(RoleManager.Instance.RoleData.lev)
            self.Job.text = KvData.classes_name[temp_data.classes]
            self.Floor.text = tostring(temp_data.score)
            break
        end
    end
    self.MyScore.gameObject:SetActive(hasMySelf)
    if hasMySelf then
        self.ScrollCon:GetComponent(RectTransform).sizeDelta = Vector2(606, 296)
    else
        self.ScrollCon:GetComponent(RectTransform).sizeDelta = Vector2(606, 350)
    end
end
