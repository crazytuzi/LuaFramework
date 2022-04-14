---
--- Created by  Administrator
--- DateTime: 2019/3/11 11:04
---
SevenDayPanel = SevenDayPanel or class("SevenDayPanel", WindowPanel)
local this = SevenDayPanel

function SevenDayPanel:ctor(parent_node, parent_panel)
    self.abName = "sevenDay"
    self.assetName = "SevenDayPanel"
    self.layer = "UI"
    self.events = {}
    self.use_background = true
    self.show_sidebar = false
    self.panel_type = 7
    self.title = "title"
   -- self.is_show_light_decorate = true
    self.model = SevenDayModel:GetInstance()

    self.pageViews = {}
    self.rewards = {}
    self.iconSettors = {}
    self.curDay = 0  --当前选中的天数
    self.curPageIndex = -1 --当前页数


end

function SevenDayPanel:Open()
    if self.model.firstOpen == true then
        self.model.firstOpen = false
        SevenDayController:GetInstance():CheckRedPoint()
    end

    WindowPanel.Open(self)
end

function SevenDayPanel:dctor()
    self.model:RemoveTabListener(self.events)
   -- self.model:RemoveTabListener(self.events)
    for i, v in pairs(self.pageViews) do
        v:destroy()
    end
    self.pageViews = {}
    for i, v in pairs(self.iconSettors) do
        v:destroy()
    end
    self.iconSettors = {}
    if self.monster then
        self.monster:destroy();
    end

    if self.rewardBtn_red then
        self.rewardBtn_red:destroy()
        self.rewardBtn_red = nil
    end

    if self.texlayer then
        self.texlayer:destroy()
    end


    if self.effect then
        self.effect:destroy()
    end

    if self.showLayer then
        self.showLayer:destroy()
    end

    if self.camera_component then
        self.camera_component.targetTexture = nil
    end
    if self.rawImage then
        self.rawImage.texture = nil
    end
    if self.render_texture then
        ReleseRenderTexture(self.render_texture)
        self.render_texture = nil
    end
end

function SevenDayPanel:LoadCallBack()
    self.nodes = {
        "ScrollView/Viewport/itemContent","leftBg","ScrollView","lqBtn","RewardContent",
        "SevenDayPageView","leftBtn","rightBtn","modelCon","showIcon","leftITex","topTex",
        "effParent","modelCon/Camera",
    }
    self:GetChildren(self.nodes)
    self.ScrollView = GetScrollRect(self.ScrollView)
    self.ScrollView.enabled = false
    self.lqBtnImg = GetImage(self.lqBtn)
    self.showIcon = GetImage(self.showIcon)
    self.leftITex = GetImage(self.leftITex)
    self.topTex = GetImage(self.topTex)

    self.rawImage = self.modelCon:GetComponent("RawImage")
    self.camera_component = self.Camera:GetComponent("Camera")
   -- SetLocalRotation(self.leftBtn,0,180,0)
  --  self:InitWinPanel()
    self:AddEvent()
    self:InitUI()
    self:PlayAni()
    self:InitEff()

    self.rewardBtn_red = RedDot(self.lqBtn, nil, RedDot.RedDotType.Nor)
    self.rewardBtn_red:SetPosition(60, 16)

    LayerManager:GetInstance():AddOrderIndexByCls(self,self.modelCon,nil,true,nil,nil,3)
    SevenDayController:GetInstance():RequestLoginInfo()
end



function SevenDayPanel:InitEff()
    if not self.effect then
        self.effect = UIEffect(self.effParent, 10311, false)
        --self.effect:SetOrderIndex(101)
        local cfg = {}
        cfg.scale = 1.25
        cfg.pos = {x=-380,y=-200,z=0}
        self.effect:SetConfig(cfg)
        --self.effect:SetPosition(-411,-144)
        --self.effect:SetScale(125)
    end
end




function SevenDayPanel:InitWinPanel()
    self:SetPanelBgImage("iconasset/icon_big_bg_img_book_bg", "img_book_bg")
    self:SetTitleBgImage("system_image", "ui_title_bg_5")
    self:SetTopCenterBg("system_image", "ui_title_bg_6")
    self:SetTileTextImage("sevenDay_image", "yylogin_title")
    self:SetTitleImgPos(500, 279)
    self:SetBtnCloseImg("system_image", "ui_close_btn_3")
end


function SevenDayPanel:InitUI()
    self:InitPageView()
end

function SevenDayPanel:InitPageView()
    for i = 1, 2 do
        self.pageViews[i] = SevenDayPageView(self.SevenDayPageView.gameObject,self.itemContent,"UI")
        self.pageViews[i]:SetData(i)
    end

end

function SevenDayPanel:AddEvent()
    local function call_back(go,go1)

    end
    AddDragBeginEvent(self.ScrollView.gameObject,call_back)
    local function call_back()
        --print2(self.ScrollView.horizontalNormalizedPosition )
        --print2(self.curPageIndex)
        if self.curPageIndex == 1 then
            if self.ScrollView.horizontalNormalizedPosition >= 0.3  then
                self:NextPage()
            else
                --self.ScrollView.horizontalNormalizedPosition = 0
                self:LastPage()

            end
        else
            if self.ScrollView.horizontalNormalizedPosition <= 0.7 then
                self:LastPage()
            else
                self:NextPage()
            end
        end

    end

    AddDragEndEvent(self.ScrollView.gameObject,call_back)



    local function call_back()  --领奖
        if self.model:IsGetReward(self.curDay)  then
            Notify.ShowText("Rewards have been claimed")
            return
        end
        --if  self.curDay > self.model.dayNums  then
        --
        --end
        SevenDayController:GetInstance():RequestReward(self.curDay)

    end
    AddButtonEvent(self.lqBtn.gameObject,call_back)

    local function call_back()
        self:LastPage()
    end
    AddClickEvent(self.leftBtn.gameObject,call_back)
    local function call_back()
        self:NextPage()
    end

    AddClickEvent(self.rightBtn.gameObject,call_back)


    self.events[#self.events + 1] = self.model:AddListener(SevenDayEvent.SevenDayItemClick, handler(self, self.SevenDayItemClick))
    self.events[#self.events + 1] = self.model:AddListener(SevenDayEvent.SevenDayInfo, handler(self, self.SevenDayInfo))
    self.events[#self.events + 1] = self.model:AddListener(SevenDayEvent.SevenDayReward, handler(self, self.SevenDayReward))
    self.events[#self.events + 1] = self.model:AddListener(SevenDayEvent.SevenDatRedInfo, handler(self, self.SevenDatRedInfo))
    
end

function SevenDayPanel:SevenDatRedInfo()
   -- self:CheckRedPoint()
end

function SevenDayPanel:CheckRedPoint()

end

function SevenDayPanel:OpenCallBack()
    self:SetTitleImgPos(-300,274.9)
    local texture = CreateRenderTexture()
    self.camera_component.targetTexture = texture
    self.rawImage.texture = texture
    self.render_texture = texture
end

function SevenDayPanel:CloseCallBack()

    --self.model = nil
end


function SevenDayPanel:NextPage()
    if #self.model.rewardDays < 7 then
        return
    end
    self.curPageIndex = 2
    SetVisible(self.rightBtn,false)
    SetVisible(self.leftBtn,true)
    local action = cc.ValueTo(0.2,1,self.ScrollView,"horizontalNormalizedPosition")
    cc.ActionManager:GetInstance():addAction(action,self.ScrollView)
end
function SevenDayPanel:LastPage()
    if #self.model.rewardDays < 7 then
        return
    end
    self.curPageIndex = 1
    SetVisible(self.rightBtn,true)
    SetVisible(self.leftBtn,false)
    local action = cc.ValueTo(0.2,0,self.ScrollView,"horizontalNormalizedPosition")
    cc.ActionManager:GetInstance():addAction(action,self.ScrollView)
end
function SevenDayPanel:SetScrollView()
    if  #self.model.rewardDays >= 7 then
        self.ScrollView.enabled = true
        if self.curDay <= 7 then
            self.curPageIndex = 1
            SetVisible(self.rightBtn,true)
            SetVisible(self.leftBtn,false)
        else
            SetVisible(self.rightBtn,false)
            SetVisible(self.leftBtn,true)
            self.curPageIndex = 2
        end
        if self.curPageIndex == 1 then
            self.ScrollView.horizontalNormalizedPosition = 0
        else
            self.ScrollView.horizontalNormalizedPosition = 1
        end
    else
        self.ScrollView.enabled = false
        SetVisible(self.rightBtn,false)
        SetVisible(self.leftBtn,false)
    end

end

function SevenDayPanel:SevenDayItemClick(data)
    self.curDay = data
    local db = Config.db_yylogin[self.curDay]
    if db then
      --  print2(db.day)
       self:UpdateRewardInfo(String2Table(db.reward))
        self:SetBtnState()
        if db.modortex == 1 then --图片
            self:InitTexture(db.model)
            SetVisible(self.showIcon.transform,true)
        elseif db.modortex == 2 then --模型
            self:InitModel(db.modeltype,db.model)
            SetVisible(self.showIcon.transform,false)
        end
        self:SetLeftModel(db.lefttex)
        self:SetTopTexture(db.toptex)
       -- self:SetStatic()
    end
end

function SevenDayPanel:InitModel(type,modelId)
    if self.monster then
        self.monster:destroy()
    end
    self.modelType = type
   -- self.monster = UIModelManager:GetInstance():InitModel(self.modelType,modelId,self.modelCon,handler(self, self.HandleMonsterLoaded))
    if type == 1 then
        self.monster = UIFabaoModel(self.modelCon, modelId, handler(self, self.HandleMonsterLoaded))
    elseif type == 2 then
        self.monster = UIMonsterModel(self.modelCon, modelId, handler(self, self.HandleMonsterLoaded))
    elseif type == 3 then
        self.monster = UIMountModel(self.modelCon, "model_mount_"..modelId, handler(self, self.HandleMonsterLoaded),false)
    elseif type == 4 then
        self.monster = UINpcModel(self.modelCon, modelId, handler(self, self.HandleMonsterLoaded))
    elseif type == 5 then
        local role = RoleInfoModel.GetInstance():GetMainRoleData()
        local gender = role.gender
        local modelStr = String2Table(modelId)
        local id = modelStr[1]
        local type = modelStr[2]
        local cfgData = Config.db_fashion[id.."@"..type]
        local roleModelId
        if gender == 1 then
            roleModelId = cfgData.man_model
        else
            roleModelId = cfgData.girl_model
        end

        local ori_weapon
        if role.figure.weapon  then
            ori_weapon = role.figure.weapon.model
        end
        local data = {}
        data.res_id = roleModelId
        data.default_weapon = ori_weapon
        self.monster =  UIRoleModel(self.modelCon, handler(self, self.HandleMonsterLoaded), data)
     --   self.monster = UIRoleModel(self.modelCon, modelId, handler(self, self.HandleMonsterLoaded))
    elseif type == 6 then
        self.monster = UIWingModel(self.modelCon, modelId, handler(self, self.HandleMonsterLoaded))
    elseif type == 7 then
        self.monster = UIPetModel(self.modelCon, modelId, handler(self, self.HandleMonsterLoaded))
    end
end
function SevenDayPanel:HandleMonsterLoaded()
    if self.modelType == 3 then
        SetLocalPosition(self.monster.transform, -977, -54, 866)
        SetLocalRotation(self.monster.transform,0,145,0)
    elseif self.modelType == 6 then
        SetLocalPosition(self.monster.transform, 1065, 125, -200)
        SetLocalRotation(self.monster.transform,0,0,0)
    elseif self.modelType == 5 then
        SetLocalPosition(self.monster.transform, -992, -58, 439)
        SetLocalRotation(self.monster.transform,172,6,178)
    elseif self.modelType == 7 then
        if self.curDay == 14 then
            SetLocalPosition(self.monster.transform, -987, -71, 546)
            SetLocalRotation(self.monster.transform,9,180,-2)
        else
            SetLocalPosition(self.monster.transform, -998, -38, 413)
            SetLocalRotation(self.monster.transform,9,180,0)
        end

    end

end


function SevenDayPanel:InitTexture(name)
    if self.monster then
        self.monster:destroy()
    end
    local function call_back(sp)
        self.showIcon.sprite = sp

        if not self.showLayer then
            self.showLayer = LayerManager:GetInstance():AddOrderIndexByCls(self,self.showIcon.transform,nil,true,nil,nil,4)
        end

    end
    lua_resMgr:SetImageTexture(self,self.showIcon,"iconasset/icon_Active",name, false,call_back)
    --local action = cc.MoveTo(1.5, -380,-5,0)
    --action = cc.Sequence(action, cc.MoveTo(1.5, -380,-35,0))
    --action = cc.Repeat(action, 4)
    --action = cc.RepeatForever(action)
    --cc.ActionManager:GetInstance():addAction(action, self.showIcon.transform)
  --  cc.RepeatForever
end

function SevenDayPanel:PlayAni()
    local action = cc.MoveTo(1.5, -380,-5,0)
    action = cc.Sequence(action, cc.MoveTo(1.5, -380,-35,0))
    action = cc.Repeat(action, 4)
    action = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action, self.showIcon.transform)
end


function SevenDayPanel:SetBtnState()
    if self.model:IsGetReward(self.curDay) or self.curDay > self.model.dayNums then
        ShaderManager.GetInstance():SetImageGray(self.lqBtnImg)
        self.rewardBtn_red:SetRedDotParam(false)
    else
        ShaderManager.GetInstance():SetImageNormal(self.lqBtnImg)
        self.rewardBtn_red:SetRedDotParam(true)
    end
end

function SevenDayPanel:UpdateRewardInfo(list)
    for i, v in pairs(self.iconSettors) do
        v:destroy()
    end
    self.iconSettors = {}
    for i = 1, #list do
        local id = list[i][1]
        local num = list[i][2]
        local param = {}
        param["model"] = self.model
        param["item_id"] = id
        param["num"] = num
        param["can_click"] = true
        param["color_effect"] = 3
        local iconSettor = GoodsIconSettorTwo(self.RewardContent)
        iconSettor:SetIcon(param)
        table.insert(self.iconSettors,iconSettor)
    end
end

function SevenDayPanel:SevenDayInfo(data)
    --self:InitUI()
    self:SetSelect()
   -- self:CheckRedPoint()

end
function SevenDayPanel:SetSelect()
    for i = 1, #self.pageViews do
        self.pageViews[i]:SevenDayItemClick(self.model:SetSeleteDay())
    end
    self:SevenDayItemClick(self.model:SetSeleteDay())
    self:SetScrollView()
end

function SevenDayPanel:SevenDayReward(data)
    self:SetBtnState()
    self:SetSelect()
end

--设置左侧模型或者图片
function SevenDayPanel:SetLeftModel(name)
    local function call_back(sp)
        self.leftITex.sprite = sp
        if not self.texlayer then
            self.texlayer = LayerManager:GetInstance():AddOrderIndexByCls(self,self.leftITex.transform,nil,true,nil,nil,4)
        end

    end
    lua_resMgr:SetImageTexture(self,self.leftITex,"iconasset/icon_sevenday",name, false,call_back)
end
--设置上面的图片描述
function SevenDayPanel:SetTopTexture(name)
    lua_resMgr:SetImageTexture(self,self.topTex,"iconasset/icon_sevenday",name, false)
end

