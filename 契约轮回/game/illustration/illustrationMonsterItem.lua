--怪物图鉴项
illustrationMonsterItem = illustrationMonsterItem or class("illustrationMonsterItem", BaseItem)

function illustrationMonsterItem:ctor(parent_node, layer)
    self.abName = "illustration"
    self.assetName = "illustrationMonsterItem"
    self.image_ab_name = "illustration_image"
    self.layer = layer

    self.ill_model = illustrationModel:GetInstance()
    self.ill_model_events = {}

    self.bag_model = BagModel.GetInstance()
	self.bag_model_events = {}

    self.data = nil
    self.cur_star_num = nil

    self.red_dot = nil
  

    BaseItem.Load(self)
end

function illustrationMonsterItem:dctor()
    if table.nums(self.ill_model_events) > 0 then
        self.ill_model:RemoveTabListener(self.ill_model_events)
        self.ill_model_events = nil
    end
    if table.nums(self.bag_model_events) > 0 then
        self.bag_model:RemoveTabListener(self.bag_model_events)
        self.bag_model_events = nil
    end

    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function illustrationMonsterItem:LoadCallBack()
    self.nodes = {
        "txt_type","txt_name","img_card","img_card_monster","txt_layer","img_card_bg","img_card_ribbon",
        "star_type1/star2","star_type1/star4","star_type1/star3","star_type1/star5","star_type1/star6","star_type1/star1","star_type1","star_type2/star","star_type2","star_type2/txt_star_num",
        "img_sel",
    }
    self:GetChildren(self.nodes)
   
    self:InitUI()
    self:AddEvent()
    self:UpdateView()
end

function illustrationMonsterItem:InitUI()
    self.img_card = GetImage(self.img_card)
    self.img_card_bg = GetImage(self.img_card_bg)
    self.img_card_monster = GetImage(self.img_card_monster)
    self.img_card_ribbon = GetImage(self.img_card_ribbon)

    self.txt_name = GetText(self.txt_name)
    self.txt_type = GetText(self.txt_type)
    self.txt_layer = GetText(self.txt_layer)
    self.txt_star_num = GetText(self.txt_star_num)
end

function illustrationMonsterItem:AddEvent()

    --选中图鉴项
    local function call_back()
        if not self.data.index then
            return
        end
        self.data.panel:SelectItem(self.data.index)
    end
    AddClickEvent(self.img_card.gameObject,call_back)

    --选中图鉴项，改变选中状态
    local function call_back(index)
        if not self.data.is_show_select then
            return
        end

        SetVisible(self.img_sel,index == self.data.index)
    end
    self.ill_model_events[#self.ill_model_events + 1] = self.ill_model:AddListener(illustrationEvent.SelectItem,call_back)

    --图鉴背包刷新
    local function call_back()
        self:UpdateReddot()
	end
	self.bag_model_events[#self.bag_model_events + 1] = self.bag_model:AddListener(illustrationEvent.LoadillustrationItems,call_back)
end

--data
--index 索引
--ill_id 图鉴id
--name 怪物名
--monster_id 怪物id
--type 左下角类型
--layer 右下角阶级
--color_num 品质颜色数字
--cur_star_num 当前星数
--max_star_num 最大星数
--panel 所在面板
--star_type 星数显示类型 1显示多个星 2显示一个星+数字
--is_default_select 是否默认选中
--is_show_select 是否显示选中框
--is_show_reddot 是否显示红点
-- scale 缩放
function illustrationMonsterItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:UpdateView() 
    end
end

function illustrationMonsterItem:UpdateView()
    self.txt_name.text = self.data.name
    self.txt_type.text = self.data.type
    self.txt_layer.text = self.data.layer
    lua_resMgr:SetImageTexture(self, self.img_card_monster, self.image_ab_name, "card_monster_"..self.data.monster_id,true)
    lua_resMgr:SetImageTexture(self, self.img_card, self.image_ab_name, "card_"..self.data.color_num,true)
    lua_resMgr:SetImageTexture(self, self.img_card_bg, self.image_ab_name, "card_bg_"..self.data.color_num,true)

    --刷新星数信息

    self:UpdateCurStarNum(self.data.cur_star_num)

    if self.data.is_default_select then
        self.data.is_default_select = false
        self.data.panel:SelectItem(self.data.index)
    end

    --刷新红点
    self:UpdateReddot()

    if self.data.scale then
        SetLocalScale(self.transform,self.data.scale,self.data.scale,1)
    end
end

--刷新当前星数
function illustrationMonsterItem:UpdateCurStarNum(cur_star_num)

    self.data.cur_star_num = cur_star_num

    if self.data.star_type == 1 then
        --显示多个星
        SetVisible(self.star_type1,true)
        SetVisible(self.star_type2,false)

        for i=1,6 do
            SetVisible(self["star".. i],i <= self.data.cur_star_num)
        end    
    else
        --显示一个星+数字
        SetVisible(self.star_type1,false)
        SetVisible(self.star_type2,true)

        self.txt_star_num.text = cur_star_num
    end
    
    --未激活的置灰
    if cur_star_num == 0 then
        self:UpdateGray(true)
    else
        self:UpdateGray(false)
    end
end

--刷新置灰效果
function illustrationMonsterItem:UpdateGray(is_gray)
    
    local num = 255
    if is_gray then
        num = 118
    end

    SetColor(self.img_card,num,num,num,255)
    SetColor(self.img_card_bg,num,num,num,255)
    SetColor(self.img_card_monster,num,num,num,255)
    SetColor(self.img_card_ribbon,num,num,num,255)

end

--刷新红点
function illustrationMonsterItem:UpdateReddot()

    if not self.data.is_show_reddot then
        return
    end

    local flag = self.ill_model:CheckReddotByTarget(self.data.ill_id,self.data.cur_star_num)
    if not flag and not self.red_dot then
        return
    end

    self.red_dot = self.red_dot or RedDot(self.transform)
    self.red_dot:SetRedDotParam(flag)
    SetLocalPositionZ(self.red_dot.transform,0)
    SetAnchoredPosition(self.red_dot.transform,48,82)
end