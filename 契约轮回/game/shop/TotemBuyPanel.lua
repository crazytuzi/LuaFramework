--图腾限购
TotemBuyPanel = TotemBuyPanel or class("TotemBuyPanel", BeastActivityPanel)

function TotemBuyPanel:ctor()
	self.abName = "beast_actvity"
    self.assetName = "TotemBuyPanel"

    self.use_background = true
    self.change_scene_close = true
    self.select_id = 90401
    self.panel_type = 2
    self.item_list = {}
    self.act_type = 5
    self.global_events = {}
    self.model = ShopModel:GetInstance()
end

function TotemBuyPanel:LoadCallBack()
	TotemBuyPanel.super.LoadCallBack(self)
	self:GetChildren(
        {
        "powerObj/power","bg2/Content",

        "menu_group/Toggle2/txt_tog_2","menu_group/Toggle1/txt_tog_1",
        "menu_group/Toggle4/txt_tog_4","menu_group/Toggle3/txt_tog_3",
    
    })
    
    self.power = GetText(self.power)

    self.txt_tog_1 = GetText(self.txt_tog_1)
    self.txt_tog_2 = GetText(self.txt_tog_2)
    self.txt_tog_3 = GetText(self.txt_tog_3)
    self.txt_tog_4 = GetText(self.txt_tog_4)

    SetLocalPosition(self.model_img, -161.3, -12.6)
    SetLocalPosition(self.model_con, -14.7, -15)

    self:UpdateTabName()
end


function TotemBuyPanel:SelectToggle(index)
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.model_img.transform)

    self:SetTextFontSize(index)

    if index == 1 then
        self.select_id = 90401
        SetLocalPosition(self.model_img, -161.3, -12.6)
        self:UpdateView()
        self:PlayAni1()
    elseif index == 2 then
        self.select_id = 90402
        SetLocalPosition(self.model_img, -161.3, -12.6)
        self:UpdateView()
        self:PlayAni()
    elseif index == 3 then
        self.select_id = 90403
        SetLocalPosition(self.model_img, -170.1, 30.2)
        self:UpdateView()
        self:PlayAni3()
    elseif index == 4 then
        self.select_id = 90404
        SetLocalPosition(self.model_img, -192.1, 44.8)
        self:UpdateView()
        self:PlayAni4()
    end
end

function TotemBuyPanel:UpdateView()
    local limitcfg = Config.db_beast_limit[self.select_id]
    self.power.text = limitcfg.power


    if limitcfg.type == 1 then
        --加载图片
        SetVisible(self.model_img, true)
        SetVisible(self.model_con, false)
        local function call_back(sp)
            self.model_img_img.sprite = sp
            if not self.texlayer then
                self.texlayer = LayerManager:GetInstance():AddOrderIndexByCls(self, self.model_img_img.transform, nil, true, nil, nil, 4)
            end
        end
        lua_resMgr:SetImageTexture(self, self.model_img_img, 'beast_actvity_image', "totembuy_model_"..self.select_id, nil, call_back)
    elseif limitcfg.type == 2 then
        --加载模型
        SetVisible(self.model_img, false)
        SetVisible(self.model_con, true)
        if self.ui_model then
        	self.ui_model:destroy()
        	self.ui_model = nil
        end
        if not self.ui_model then
            local cfg = {}
            cfg.pos = { x = -1994, y = -34.83, z = 500 }
            --cfg.scale = {x = ratio,y = ratio,z = ratio}
            cfg.trans_x = 900
            cfg.trans_y = 900
            cfg.trans_offset = { x = -126, y = 0 }
            cfg.carmera_size = 0.5
            self.ui_model = UIModelCommonCamera(self.model_con, nil, limitcfg.model, nil, false)
            self.ui_model:SetConfig(cfg)
            SetLocalScale(self.ui_model.transform, 1)
        end
    end

    --加载广告语
    lua_resMgr:SetImageTexture(self, self.desc, 'beast_actvity_image', "totembuy_desc_"..self.select_id)
  
    --加载展示奖励
    self:PlayAni1()
    for i = 1, #self.item_list do
        self.item_list[i]:destroy()
    end
    self.item_list = {}
    local mallcfg = Config.db_mall[self.select_id]
    local rewards = String2Table(mallcfg.item)
    for i = 1, #rewards do
        local item = GoodsIconSettorTwo(self.Content)
        local reward = rewards[i]
        local param = {}
        param["item_id"] = reward[1]
        param["num"] = reward[2]
        param["bind"] = reward[3]
        param["size"] = { x = 75, y = 75 }
        param["can_click"] = true

        local item_cfg = Config.db_item[param["item_id"]]
        if item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_PET_EQUIP then
            --宠物装备特殊处理配置表
            param["cfg"] = Config.db_pet_equip[param["item_id"].."@"..1]
        end

        item:SetIcon(param)
        self.item_list[i] = item
    end
    

    --加载价格信息
    self.oldprice.text = String2Table(mallcfg.original_price)[2]
    self.price.text = String2Table(mallcfg.price)[2]

    --加载活动剩余时间
    local beast_list = self.model:GetTotemList()
    local mall_item = nil
    local end_time
    for i = 1, #beast_list do
        end_time = beast_list[i].end_time
        if beast_list[i].id == self.select_id then
            mall_item = beast_list[i]
            break
        end
    end
    if end_time then
        local param = {
            duration = 0.033,
            formatText = "%s",
            formatTime = "%d",
            isShowDay = true,
            isShowHour = true,
            isShowMin = true,
            isChineseType = true,
        }
        SetVisible(self.CountDown, true)
        if not self.countdown_item then
            self.countdown_item = CountDownText(self.CountDown, param)
            self.countdown_item:StartSechudle(end_time)
        end
    else
        SetVisible(self.CountDown, false)
    end
    if mall_item then
        SetVisible(self.btn_buy, true)
        SetVisible(self.btn_finish, false)
    else
        SetVisible(self.btn_buy, false)
        SetVisible(self.btn_finish, true)
    end
end

--刷新左侧页签名字
function  TotemBuyPanel:UpdateTabName(  )
    for i=1,4 do
        local id = 90400 + i
        local cfg = Config.db_mall[id]
        self["txt_tog_"..i].text = cfg.name
    end
end

--设置左侧页签字体大小
function TotemBuyPanel:SetTextFontSize( select_index )
    for i=1,4 do
        if i == select_index then
            self["txt_tog_"..i].fontSize = 30
            SetLocalPositionY(self["txt_tog_"..i].transform,-3)
        else
            self["txt_tog_"..i].fontSize = 24
            SetLocalPositionY(self["txt_tog_"..i].transform,-0)
        end
    end
end